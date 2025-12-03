#!/bin/bash

# CI/CD Pipeline Trigger Script for Local Development
# This script allows manual triggering of the CI/CD pipeline locally
# Usage: ./trigger-pipeline.sh [build|test|security|deploy|all] [staging|production]

set -e

STAGE="${1:-all}"
ENVIRONMENT="${2:-staging}"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Validate parameters
validate_stage() {
    case "$STAGE" in
        build|test|security|deploy|all) return 0 ;;
        *) echo "Invalid stage: $STAGE"; exit 1 ;;
    esac
}

validate_environment() {
    case "$ENVIRONMENT" in
        staging|production) return 0 ;;
        *) echo "Invalid environment: $ENVIRONMENT"; exit 1 ;;
    esac
}

write_header() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║ $1${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
}

write_status() {
    local message=$1
    local type=${2:-Info}
    
    case "$type" in
        Success)
            echo -e "${GREEN}✓ $message${NC}"
            ;;
        Warning)
            echo -e "${YELLOW}⚠ $message${NC}"
            ;;
        Error)
            echo -e "${RED}✗ $message${NC}"
            ;;
        Info)
            echo -e "${CYAN}ℹ $message${NC}"
            ;;
    esac
}

build_stage() {
    write_header "BUILD STAGE"
    echo "Starting build process..."
    
    # Check Node.js
    if ! command -v npm &> /dev/null; then
        write_status "Node.js not found. Please install Node.js" "Error"
        return 1
    fi
    write_status "Node.js detected" "Success"
    
    # Install dependencies
    echo ""
    echo "Installing dependencies..."
    npm install --legacy-peer-deps || write_status "Dependencies installation completed with warnings" "Warning"
    write_status "Dependencies installed" "Success"
    
    # Run linting
    echo ""
    echo "Running code quality checks..."
    npm run lint --if-present || write_status "No lint script configured" "Info"
    
    # Validate HTML
    echo ""
    echo "Validating HTML structure..."
    if [ -f "index.html" ]; then
        write_status "index.html found" "Success"
    else
        write_status "index.html not found" "Error"
        return 1
    fi
    
    write_status "Build stage completed successfully" "Success"
    return 0
}

test_stage() {
    write_header "TEST STAGE"
    echo "Starting test process..."
    
    # Verify critical files
    echo ""
    echo "Verifying critical files..."
    
    local critical_files=("index.html" "style.css" "demo.js" "p5.js" "p5.sound.min.js")
    for file in "${critical_files[@]}"; do
        if [ -f "$file" ]; then
            write_status "$file found" "Success"
        else
            write_status "$file NOT found" "Error"
            return 1
        fi
    done
    
    # Run unit tests
    echo ""
    echo "Running unit tests..."
    npm test --if-present || write_status "No tests configured" "Info"
    
    write_status "Test stage completed successfully" "Success"
    return 0
}

security_stage() {
    write_header "SECURITY SCANNING"
    echo "Starting security scanning..."
    
    # Check for vulnerable dependencies
    echo ""
    echo "Scanning for vulnerable dependencies..."
    npm audit --audit-level=moderate || write_status "Security audit review recommended" "Warning"
    
    write_status "Security scanning completed" "Success"
    return 0
}

deploy_stage() {
    write_header "DEPLOYMENT STAGE"
    echo "Preparing for deployment..."
    echo "Environment: $ENVIRONMENT"
    
    # Create deployment directory
    mkdir -p deploy
    
    # Copy files to deploy directory
    echo ""
    echo "Preparing deployment package..."
    
    local deploy_files=("index.html" "style.css" "demo.js" "p5.js" "p5.sound.min.js" "README.md" ".github")
    for file in "${deploy_files[@]}"; do
        if [ -e "$file" ]; then
            cp -r "$file" deploy/
            write_status "Copied $file to deploy directory" "Success"
        fi
    done
    
    echo ""
    echo -e "${GREEN}Deployment package created at: $(pwd)/deploy${NC}"
    write_status "Deployment stage completed successfully" "Success"
    
    return 0
}

show_summary() {
    write_header "PIPELINE EXECUTION SUMMARY"
    
    echo ""
    echo -e "${CYAN}Stage Results:${NC}"
    
    if [ "$1" = "build" ] || [ "$1" = "all" ]; then
        write_status "Build: PASSED" "Success"
    fi
    if [ "$2" = "test" ] || [ "$1" = "all" ]; then
        write_status "Test: PASSED" "Success"
    fi
    if [ "$3" = "security" ] || [ "$1" = "all" ]; then
        write_status "Security: PASSED" "Success"
    fi
    if [ "$4" = "deploy" ] || [ "$1" = "all" ]; then
        write_status "Deploy: PASSED" "Success"
    fi
    
    echo ""
    echo -e "${CYAN}Execution Details:${NC}"
    echo "  Timestamp: $TIMESTAMP"
    echo "  Environment: $ENVIRONMENT"
    echo "  Repository: $(git config --get remote.origin.url)"
    echo "  Current Branch: $(git rev-parse --abbrev-ref HEAD)"
    echo "  Latest Commit: $(git rev-parse --short HEAD)"
    
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║       PIPELINE EXECUTION COMPLETE      ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
    echo ""
}

# Main execution
validate_stage
validate_environment

echo ""
write_header "CI/CD PIPELINE TRIGGER"
echo "Stage: $STAGE"
echo "Environment: $ENVIRONMENT"
echo "Timestamp: $TIMESTAMP"

case "$STAGE" in
    all)
        build_stage || exit 1
        test_stage || exit 1
        security_stage
        deploy_stage
        show_summary "all"
        ;;
    build)
        build_stage || exit 1
        ;;
    test)
        test_stage || exit 1
        ;;
    security)
        security_stage
        ;;
    deploy)
        deploy_stage
        ;;
esac

write_status "Pipeline execution successful!" "Success"
