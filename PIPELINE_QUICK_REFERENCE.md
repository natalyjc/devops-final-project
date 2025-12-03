# Pipeline Triggering Quick Reference

## 🚀 Quick Start

### Automatic (GitHub)
```bash
git push origin main  # Pipeline starts automatically
```

### Manual (GitHub UI)
1. Go to **Actions** tab
2. Click **"CI/CD Pipeline"**
3. Click **"Run workflow"**
4. Select environment: **staging** or **production**
5. Click **"Run workflow"**

### Manual (Local - Windows)
```powershell
# All stages
.\trigger-pipeline.ps1

# Specific stage
.\trigger-pipeline.ps1 -Stage build
.\trigger-pipeline.ps1 -Stage test
.\trigger-pipeline.ps1 -Stage security
.\trigger-pipeline.ps1 -Stage deploy

# With environment
.\trigger-pipeline.ps1 -Stage deploy -Environment production
```

### Manual (Local - Mac/Linux)
```bash
# Make executable
chmod +x trigger-pipeline.sh

# All stages
./trigger-pipeline.sh

# Specific stage
./trigger-pipeline.sh build
./trigger-pipeline.sh test
./trigger-pipeline.sh security
./trigger-pipeline.sh deploy

# With environment
./trigger-pipeline.sh deploy production
```

---

## 📊 Pipeline Stages

### 1️⃣ Build
- ✓ Install dependencies (`npm install`)
- ✓ Run linting checks
- ✓ Validate HTML structure
- ⏱️ ~30 seconds

### 2️⃣ Test
- ✓ Verify critical files exist
- ✓ Run unit tests
- ✓ Validate code integrity
- ⏱️ ~20 seconds

### 3️⃣ Security
- ✓ Scan for vulnerabilities
- ✓ Audit dependencies
- ✓ Check for CVEs
- ⏱️ ~40 seconds

### 4️⃣ Deploy
- ✓ Create deployment package
- ✓ Prepare application files
- ✓ Verify deployment readiness
- ⏱️ ~15 seconds

### 5️⃣ Notify
- ✓ Generate execution summary
- ✓ Report final status
- ✓ List all results
- ⏱️ ~5 seconds

---

## 📁 Files Created

```
.github/
├── workflows/
│   └── ci-cd.yml                  ← GitHub Actions workflow
└── ISSUE_TEMPLATE/                ← Existing templates

project-root/
├── trigger-pipeline.ps1           ← Windows local trigger
├── trigger-pipeline.sh            ← Linux/Mac local trigger
└── PIPELINE_TRIGGERING.md         ← Full documentation
```

---

## ✅ Triggering Methods Summary

| Method | Trigger | Speed | Control |
|--------|---------|-------|---------|
| **Auto Commit** | `git push` | Immediate | Automatic |
| **GitHub UI** | Actions → Run workflow | 1-2 sec | Full |
| **PowerShell** | `.\trigger-pipeline.ps1` | Immediate | Full |
| **Bash** | `./trigger-pipeline.sh` | Immediate | Full |

---

## 🔍 Monitoring Pipeline

### GitHub Actions
1. Go to repository **Actions** tab
2. Click **CI/CD Pipeline**
3. Click latest run
4. View stages and logs

### Status Indicators
- 🟢 **Success** - All stages passed
- 🟡 **In Progress** - Currently running
- 🔴 **Failed** - One or more stages failed
- ⚪ **Skipped** - Stage didn't run (conditional)

---

## 🐛 Troubleshooting

| Problem | Solution |
|---------|----------|
| Pipeline not starting | Push to `main` branch, wait 5 sec |
| Build fails locally | Run `npm install --legacy-peer-deps` |
| Files not found | Check file names and paths |
| No artifacts | Wait for job to complete (✓ symbol) |
| Permission denied | Run `chmod +x trigger-pipeline.sh` |

---

## 📌 Important Notes

- Pipeline runs on **every push to main**
- Manual trigger available via **GitHub Actions UI**
- Local scripts work without GitHub (for testing)
- All stages must pass for deployment
- Artifacts kept for **7 days**
- Environment can be **staging** or **production**

---

## 🔗 View Logs

### GitHub Actions
1. Actions → CI/CD Pipeline → Latest Run
2. Click stage name to expand logs
3. Search for errors with `Ctrl+F`

### Local Scripts
Output shown directly in terminal with color coding:
- 🟢 Success (Green)
- 🟡 Warning (Yellow)
- 🔴 Error (Red)
- 🔵 Info (Cyan)

---

## 📈 Next Steps

1. ✅ Push code: `git push origin main`
2. ✅ Monitor: Go to Actions tab
3. ✅ Test locally: `.\trigger-pipeline.ps1 -Stage test`
4. ✅ Deploy when ready: `.\trigger-pipeline.ps1 -Stage deploy`
5. ✅ Check artifacts: Download from Actions page

---

For detailed information, see **PIPELINE_TRIGGERING.md**
