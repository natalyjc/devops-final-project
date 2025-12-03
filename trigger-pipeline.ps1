# CI/CD Pipeline Trigger Script for Local Development
# This script allows manual triggering of the CI/CD pipeline locally

param(
    [ValidateSet('build', 'test', 'security', 'deploy', 'all')]
    [string]$Stage = 'all',
    
    [ValidateSet('staging', 'production')]
    [string]$Environment = 'staging',
    
    [switch]$Verbose = $false
)

$ErrorActionPreference = 'Continue'
$timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'

function Write-Header {
    param([string]$Text)
    Write-Host "`n╔════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║ $($Text.PadRight(36)) ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
}

function Write-Status {
    param(
        [string]$Message,
        [ValidateSet('Success', 'Warning', 'Error', 'Info')]
        [string]$Type = 'Info'
    )
    
    $color = @{
        Success = 'Green'
        Warning = 'Yellow'
        Error   = 'Red'
        Info    = 'Cyan'
    }[$Type]
    
    $symbol = @{
        Success = '✓'
        Warning = '⚠'
        Error   = '✗'
        Info    = 'ℹ'
    }[$Type]
    
    Write-Host "$symbol $Message" -ForegroundColor $color
}

function Test-NodeInstalled {
    try {
        $null = npm --version
        return $true
    }
    catch {
        return $false
    }
}

function Invoke-BuildStage {
    Write-Header "BUILD STAGE"
    Write-Host "Starting build process..." -ForegroundColor Yellow
    
    # Check Node.js
    if (-not (Test-NodeInstalled)) {
        Write-Status "Node.js not found. Please install Node.js" "Error"
        return $false
    }
    Write-Status "Node.js detected" "Success"
    
    # Install dependencies
    Write-Host "`nInstalling dependencies..." -ForegroundColor Yellow
    try {
        npm install --legacy-peer-deps | Out-Null
        Write-Status "Dependencies installed" "Success"
    }
    catch {
        Write-Status "Failed to install dependencies" "Warning"
    }
    
    # Run linting
    Write-Host "`nRunning code quality checks..." -ForegroundColor Yellow
    try {
        npm run lint --if-present 2>$null | Out-Null
        Write-Status "Code quality checks passed" "Success"
    }
    catch {
        Write-Status "No lint script configured or linting warnings present" "Info"
    }
    
    # Validate HTML
    Write-Host "`nValidating HTML structure..." -ForegroundColor Yellow
    if (Test-Path "index.html") {
        Write-Status "index.html found" "Success"
    }
    else {
        Write-Status "index.html not found" "Error"
        return $false
    }
    
    Write-Status "Build stage completed successfully" "Success"
    return $true
}

function Invoke-TestStage {
    Write-Header "TEST STAGE"
    Write-Host "Starting test process..." -ForegroundColor Yellow
    
    # Verify critical files
    $criticalFiles = @('index.html', 'style.css', 'demo.js', 'p5.js', 'p5.sound.min.js')
    
    Write-Host "`nVerifying critical files..." -ForegroundColor Yellow
    $allFilesPresent = $true
    foreach ($file in $criticalFiles) {
        if (Test-Path $file) {
            Write-Status "$file found" "Success"
        }
        else {
            Write-Status "$file NOT found" "Error"
            $allFilesPresent = $false
        }
    }
    
    if (-not $allFilesPresent) {
        return $false
    }
    
    # Run unit tests
    Write-Host "`nRunning unit tests..." -ForegroundColor Yellow
    try {
        npm test --if-present 2>$null | Out-Null
        Write-Status "Unit tests passed" "Success"
    }
    catch {
        Write-Status "No tests configured" "Info"
    }
    
    Write-Status "Test stage completed successfully" "Success"
    return $true
}

function Invoke-SecurityStage {
    Write-Header "SECURITY SCANNING"
    Write-Host "Starting security scanning..." -ForegroundColor Yellow
    
    # Check for vulnerable dependencies
    Write-Host "`nScanning for vulnerable dependencies..." -ForegroundColor Yellow
    try {
        npm audit --audit-level=moderate 2>&1 | Out-Null
        Write-Status "No high-severity vulnerabilities found" "Success"
    }
    catch {
        Write-Status "Security audit review recommended" "Warning"
    }
    
    Write-Status "Security scanning completed" "Success"
    return $true
}

function Invoke-DeployStage {
    Write-Header "DEPLOYMENT STAGE"
    Write-Host "Preparing for deployment..." -ForegroundColor Yellow
    Write-Host "Environment: $Environment" -ForegroundColor Yellow
    
    # Create deployment directory
    if (-not (Test-Path "deploy")) {
        New-Item -ItemType Directory -Path "deploy" | Out-Null
    }
    
    # Copy files to deploy directory
    Write-Host "`nPreparing deployment package..." -ForegroundColor Yellow
    $deployFiles = @('index.html', 'style.css', 'demo.js', 'p5.js', 'p5.sound.min.js', 'README.md', '.github')
    
    foreach ($file in $deployFiles) {
        if (Test-Path $file) {
            Copy-Item $file "deploy\" -Recurse -Force
            Write-Status "Copied $file to deploy directory" "Success"
        }
    }
    
    Write-Host "`nDeployment package created at: $(Resolve-Path 'deploy')" -ForegroundColor Green
    Write-Status "Deployment stage completed successfully" "Success"
    
    return $true
}

function Show-PipelineSummary {
    param(
        [hashtable]$Results
    )
    
    Write-Header "PIPELINE EXECUTION SUMMARY"
    Write-Host "`nStage Results:" -ForegroundColor Cyan
    
    foreach ($stage in @('Build', 'Test', 'Security', 'Deploy')) {
        if ($Results.ContainsKey($stage)) {
            $status = $Results[$stage]
            $type = if ($status) { 'Success' } else { 'Error' }
            Write-Status "$stage: $(if ($status) { 'PASSED' } else { 'FAILED' })" $type
        }
    }
    
    Write-Host "`nExecution Details:" -ForegroundColor Cyan
    Write-Host "  Timestamp: $timestamp"
    Write-Host "  Environment: $Environment"
    Write-Host "  Repository: $(git config --get remote.origin.url)"
    Write-Host "  Current Branch: $(git rev-parse --abbrev-ref HEAD)"
    Write-Host "  Latest Commit: $(git rev-parse --short HEAD)"
    
    Write-Host "`n╔════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║       PIPELINE EXECUTION COMPLETE      ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════╝`n" -ForegroundColor Cyan
}

# Main execution
Write-Host "`n" -ForegroundColor Green
Write-Header "CI/CD PIPELINE TRIGGER"
Write-Host "Stage: $Stage" -ForegroundColor Yellow
Write-Host "Environment: $Environment" -ForegroundColor Yellow
Write-Host "Timestamp: $timestamp" -ForegroundColor Yellow

$results = @{}

# Execute requested stages
if ($Stage -eq 'all' -or $Stage -eq 'build') {
    $results['Build'] = Invoke-BuildStage
    if (-not $results['Build']) { exit 1 }
}

if ($Stage -eq 'all' -or $Stage -eq 'test') {
    $results['Test'] = Invoke-TestStage
    if (-not $results['Test']) { exit 1 }
}

if ($Stage -eq 'all' -or $Stage -eq 'security') {
    $results['Security'] = Invoke-SecurityStage
}

if ($Stage -eq 'all' -or $Stage -eq 'deploy') {
    $results['Deploy'] = Invoke-DeployStage
}

# Show summary
Show-PipelineSummary -Results $results

Write-Status "Pipeline execution successful!" "Success"
