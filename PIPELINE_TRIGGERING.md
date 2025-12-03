# CI/CD Pipeline Triggering Guide

## Overview

This project implements automated CI/CD pipeline triggering with two methods:
1. **Automatic triggering** - on every commit to the `main` branch
2. **Manual triggering** - via GitHub Actions UI or local scripts

## Pipeline Architecture

The CI/CD pipeline consists of 5 stages executed sequentially:

```
┌─────────────┐
│   Build     │ - Install dependencies
│             │ - Run linting checks
│             │ - Validate HTML
└──────┬──────┘
       │
       ▼
┌─────────────┐
│    Test     │ - Verify critical files
│             │ - Run unit tests
│             │ - Validate integrity
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Security   │ - Vulnerability scanning
│             │ - Dependency audit
│             │ - Security checks
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   Deploy    │ - Prepare deployment
│             │ - Package application
│             │ - Verify readiness
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   Notify    │ - Send notifications
│             │ - Generate reports
│             │ - Pipeline summary
└─────────────┘
```

## Automatic Triggering (GitHub Actions)

### When Pipeline Runs Automatically

The pipeline runs automatically when:
1. **Code is pushed to `main` branch**
   ```bash
   git push origin main
   ```
2. **Pull requests are created against `main`**
3. **Changes are merged into `main`**

### Viewing Pipeline Status

1. Navigate to your GitHub repository
2. Click the **"Actions"** tab
3. Select **"CI/CD Pipeline"** workflow
4. View current and past pipeline runs

### Pipeline Status Badge

Add this badge to your `README.md` to show pipeline status:

```markdown
[![CI/CD Pipeline](https://github.com/YOUR_USERNAME/devops-final-project/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/YOUR_USERNAME/devops-final-project/actions)
```

## Manual Triggering (GitHub Actions UI)

### Step-by-Step Manual Trigger

1. **Go to GitHub Actions**
   - Navigate to your repository
   - Click the **"Actions"** tab

2. **Select Workflow**
   - Click **"CI/CD Pipeline"** in the left sidebar

3. **Trigger Workflow**
   - Click **"Run workflow"** button (top right)
   - Select branch: `main`
   - Choose environment: `staging` or `production`
   - Click **"Run workflow"**

### Expected Output

After triggering, you'll see:
- ✅ Build stage with dependency installation
- ✅ Test stage validating critical files
- ✅ Security stage scanning for vulnerabilities
- ✅ Deploy stage preparing deployment package
- ✅ Notification stage with execution summary

## Manual Triggering (Local Scripts)

### PowerShell Script (Windows)

#### Prerequisites
- PowerShell 5.1 or higher
- Node.js and npm installed
- Git configured

#### Usage

**Run all stages:**
```powershell
.\trigger-pipeline.ps1
```

**Run specific stage:**
```powershell
.\trigger-pipeline.ps1 -Stage build
.\trigger-pipeline.ps1 -Stage test
.\trigger-pipeline.ps1 -Stage security
.\trigger-pipeline.ps1 -Stage deploy
```

**Run with specific environment:**
```powershell
.\trigger-pipeline.ps1 -Stage all -Environment production
.\trigger-pipeline.ps1 -Stage deploy -Environment staging
```

**Enable verbose output:**
```powershell
.\trigger-pipeline.ps1 -Verbose
```

#### Stage Options
- `build` - Install dependencies, run linting, validate HTML
- `test` - Verify files, run unit tests
- `security` - Scan vulnerabilities, audit dependencies
- `deploy` - Prepare deployment package
- `all` - Run all stages (default)

#### Environment Options
- `staging` - Pre-production environment (default)
- `production` - Production environment

#### Example Output
```
╔════════════════════════════════════════╗
║     CI/CD PIPELINE TRIGGER            ║
╚════════════════════════════════════════╝

Stage: all
Environment: staging
Timestamp: 2025-12-02 14:30:00

╔════════════════════════════════════════╗
║        BUILD STAGE                     ║
╚════════════════════════════════════════╝

Starting build process...
✓ Node.js detected
✓ Dependencies installed
✓ Code quality checks passed
✓ index.html found
✓ Build stage completed successfully

[... test, security, and deploy stages ...]

╔════════════════════════════════════════╗
║     PIPELINE EXECUTION SUMMARY        ║
╚════════════════════════════════════════╝

Stage Results:
✓ Build: PASSED
✓ Test: PASSED
✓ Security: PASSED
✓ Deploy: PASSED
```

### Bash Script (macOS/Linux)

#### Prerequisites
- Bash shell
- Node.js and npm installed
- Git configured
- Script must be executable: `chmod +x trigger-pipeline.sh`

#### Usage

**Run all stages:**
```bash
./trigger-pipeline.sh
```

**Run specific stage:**
```bash
./trigger-pipeline.sh build
./trigger-pipeline.sh test
./trigger-pipeline.sh security
./trigger-pipeline.sh deploy
```

**Run with specific environment:**
```bash
./trigger-pipeline.sh all staging
./trigger-pipeline.sh deploy production
```

#### Make Script Executable
```bash
chmod +x trigger-pipeline.sh
```

## GitHub Actions Workflow File

The main workflow file is located at: `.github/workflows/ci-cd.yml`

### Key Components

#### Triggers
```yaml
on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main
  workflow_dispatch:  # Manual trigger from GitHub UI
```

#### Environment Variables Available
- `${{ github.sha }}` - Commit hash
- `${{ github.ref }}` - Branch reference
- `${{ github.event_name }}` - Event type (push, pull_request, workflow_dispatch)
- `${{ github.actor }}` - Who triggered the workflow

#### Conditional Execution
Deploy stage only runs on:
- Push events to main branch, OR
- Manual workflow dispatch

```yaml
if: github.event_name == 'push' && github.ref == 'refs/heads/main' || github.event_name == 'workflow_dispatch'
```

## Pipeline Artifacts

### Build Artifacts
After successful build, artifacts are saved for 7 days:
- `index.html`
- `style.css`
- `demo.js`
- `p5.js`
- `p5.sound.min.js`
- `README.md`

#### Download Artifacts from GitHub
1. Go to Actions tab
2. Click completed workflow run
3. Scroll to "Artifacts" section
4. Click artifact to download

### Deployment Package
Local scripts create a `deploy/` directory containing all production files.

## Pipeline Configuration

### Modifying Build Steps

Edit `.github/workflows/ci-cd.yml`:

```yaml
- name: Custom Build Step
  run: |
    echo "Your custom build command"
    npm run custom-script
```

### Adding Custom Scripts to package.json

```json
{
  "scripts": {
    "build": "your-build-command",
    "test": "your-test-command",
    "lint": "your-lint-command"
  }
}
```

### Conditional Dependencies

If dependencies fail to install:
```yaml
- name: Install dependencies
  run: npm install --legacy-peer-deps
  continue-on-error: true
```

## Troubleshooting

### Pipeline Won't Trigger

**Issue**: Workflow not appearing in Actions tab

**Solutions**:
1. Ensure workflow file is at `.github/workflows/ci-cd.yml`
2. Verify workflow syntax: `yaml` file must be valid
3. Wait 5-10 seconds and refresh GitHub Actions page
4. Check branch is `main`

### Build Fails on Commit

**Issue**: Pipeline starts but build stage fails

**Solutions**:
1. Run local script to debug: `./trigger-pipeline.ps1 -Stage build`
2. Check `npm install` output for errors
3. Verify all required files exist
4. Review build logs in GitHub Actions

### Deployment Artifacts Not Available

**Issue**: Can't download build artifacts

**Solutions**:
1. Wait for job to complete (shows ✓ green checkmark)
2. Artifacts retain for 7 days - check upload timestamp
3. Re-run workflow to generate fresh artifacts

### Manual Trigger Not Working

**Issue**: "Run workflow" button disabled or not responding

**Solutions**:
1. Ensure you have admin or write permissions
2. Verify workflow file is syntactically correct
3. Check that workflow file has `workflow_dispatch` trigger
4. Refresh GitHub page

## Best Practices

### 1. Meaningful Commit Messages
```bash
git commit -m "Feature: Add audio visualization improvements"
git push origin main  # Triggers pipeline
```

### 2. Run Local Tests First
```powershell
./trigger-pipeline.ps1 -Stage test
```

### 3. Monitor Pipeline Status
- Check Actions tab regularly
- Set up GitHub notifications
- Review failed logs immediately

### 4. Use Staging Environment First
```powershell
./trigger-pipeline.ps1 -Stage deploy -Environment staging
```

### 5. Document Changes
Include in commit message:
- What changed
- Why it changed
- Any breaking changes

## Integration Examples

### Triggering from Git Hooks

Create `.git/hooks/post-commit` (local only):
```bash
#!/bin/bash
echo "Running post-commit pipeline..."
./trigger-pipeline.sh test
```

### Slack Notifications

Add to workflow after notify job:
```yaml
- name: Notify Slack
  uses: slackapi/slack-github-action@v1.24.0
  with:
    payload: |
      {
        "text": "Pipeline completed: ${{ needs.deploy.result }}"
      }
```

### Custom Deployment Step

Modify `.github/workflows/ci-cd.yml`:
```yaml
- name: Deploy to Server
  run: |
    scp -r deploy/* user@server:/app/
    ssh user@server "cd /app && npm start"
```

## Monitoring and Metrics

### View Pipeline Metrics
1. Go to Actions tab
2. Click "CI/CD Pipeline" workflow
3. See execution history with timing

### Performance Tips
- Parallel jobs reduce total execution time
- Current: 4 parallel stages (build, test, security, deploy)
- Caching speeds up dependency installation

## Next Steps

1. **Push your code**: `git push origin main`
2. **View pipeline**: Go to Actions tab
3. **Monitor stages**: Watch build, test, security, deploy
4. **Fix issues**: Use local scripts to debug
5. **Customize**: Modify workflow for your needs

---

**For questions or issues**, refer to:
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Workflow Syntax Reference](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- GitHub Issues in this repository
