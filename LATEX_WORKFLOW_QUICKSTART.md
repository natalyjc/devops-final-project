# LaTeX Workflow Quick Start Guide

## What Was Created

A complete automated workflow for documenting your DevOps project with version tracking and PDF generation.

## Files Added

### 1. New LaTeX Chapter
- **`Book_SSW590_1/itProjectDemo.tex`** - New chapter documenting DevOps metrics and build information

### 2. Version Management
- **`Book_SSW590_1/version.txt`** - Current version number
- **`Book_SSW590_1/buildinfo.tex`** - LaTeX commands with build metadata
- **`Book_SSW590_1/generate-version.ps1`** - PowerShell script to generate version info

### 3. CI/CD Automation
- **`.github/workflows/build-latex.yml`** - GitHub Actions workflow for automatic PDF compilation

### 4. Documentation
- **`README_LATEX_WORKFLOW.md`** - Complete workflow documentation
- **`LATEX_WORKFLOW_QUICKSTART.md`** - This quick start guide

## How It Works

```
You push code → GitHub detects changes → 
  Generates version info from git → 
  Compiles LaTeX to PDF → 
  Stores PDF as artifact → 
  Auto-commits version files
```

## Quick Setup Steps

### 1. Commit These Files

```bash
git add .github/workflows/build-latex.yml
git add Book_SSW590_1/itProjectDemo.tex
git add Book_SSW590_1/generate-version.ps1
git add Book_SSW590_1/version.txt
git add Book_SSW590_1/buildinfo.tex
git add README_LATEX_WORKFLOW.md
git add LATEX_WORKFLOW_QUICKSTART.md

git commit -m "ci: add automated LaTeX compilation workflow with version tracking"
git push origin main
```

### 2. GitHub Actions Will Automatically

1. Detect the changes
2. Generate build information from your git history
3. Compile the LaTeX document
4. Generate `itManual.pdf`
5. Upload the PDF to the workflow artifacts
6. Auto-commit the version files

### 3. Download Your First PDF

1. Go to your GitHub repository
2. Click the **Actions** tab
3. Click the latest **"Build LaTeX Document and Generate PDF"** workflow
4. Scroll down to **Artifacts** section
5. Download **`LaTeX-PDF-*`** - This is your compiled PDF!

## Using the Version Information

The PDF footer automatically shows the current version. The version comes from:
1. Git tags (if you create them)
2. Commit count (if no tags exist)
3. Default: `0.1.0`

## Creating a Version Release

To create a new version:

```bash
# Create a version tag
git tag v0.2.0

# Push the tag to GitHub
git push origin v0.2.0
```

GitHub Actions will:
- Compile the PDF
- Create a GitHub Release
- Attach the PDF to the release
- Store metadata

## Local Testing (Optional)

If you have LaTeX installed:

```powershell
# Generate version info locally
.\Book_SSW590_1\generate-version.ps1

# Compile to PDF
cd Book_SSW590_1
pdflatex -interaction=nonstopmode itManual.tex
pdflatex -interaction=nonstopmode itManual.tex
pdflatex -interaction=nonstopmode itManual.tex
cd ..
```

## What Gets Tracked in Your PDF

Every time you commit and push:

| Information | Source |
|---|---|
| Version | Git tags or commit count |
| Commit Hash | Latest git commit |
| Author | Git commit author |
| Timestamp | Git commit date |
| Branch | Current git branch |
| Commit Message | Latest git commit message |
| Total Commits | Git commit count |

All of this appears in:
1. PDF footer (version number)
2. Project Demo chapter (full details)
3. Build metadata files (JSON/LaTeX)

## Important Notes

⚠️ **First Build**: After pushing, GitHub Actions may take 1-2 minutes to:
1. Set up the virtual machine
2. Install LaTeX packages
3. Compile the document

✅ **Automatic Commits**: The workflow automatically commits version files back to the repository. This is expected behavior.

✅ **Multiple Passes**: LaTeX is compiled 3 times to ensure all references and table of contents are correct.

## Troubleshooting

### "PDF not found in artifacts"
- Check that the push was to `main` or `develop` branch
- Check the workflow status in the Actions tab
- View the workflow logs for error messages

### "Version not updating"
- Ensure you've made commits before running
- Check `buildinfo.json` for the generated information
- Manually run the version script: `.\Book_SSW590_1\generate-version.ps1`

### "LaTeX errors in build log"
- This is usually non-critical (references, warnings)
- The PDF still generates if pdflatex completes
- Check the build log for specific error messages

## Next Steps

1. **Update commit messages**: Make meaningful commit messages, they'll appear in the PDF
2. **Create version tags**: Tag important releases with `git tag`
3. **Update Project Demo chapter**: Add more DevOps metrics and deployment info
4. **Set up releases**: GitHub will automatically create releases for tagged versions
5. **Integrate with CI/CD**: Connect to your actual deployment pipeline

## File Locations After Build

```
Your GitHub Repository:
├── Artifacts (download from Actions tab):
│   ├── LaTeX-PDF-*
│   │   └── Book_SSW590_1/itManual.pdf
│   └── Build-Metadata-*
│       ├── buildinfo.json
│       ├── version.txt
│       └── buildinfo.tex
│
├── Auto-committed files:
│   ├── Book_SSW590_1/version.txt (updated)
│   ├── Book_SSW590_1/buildinfo.tex (updated)
│   └── buildinfo.json (updated)
│
└── Releases (if you create version tags):
    └── v0.2.0
        └── itManual.pdf
```

## Architecture Diagram

```
Git Repository
    │
    ├─→ commit/push
    │
    └─→ GitHub Actions Workflow Triggers
        │
        ├─→ Generate Version Info (from git)
        │   ├─→ extract version
        │   ├─→ get commit hash
        │   └─→ capture author/timestamp
        │
        ├─→ Install LaTeX Packages
        │
        ├─→ Compile LaTeX
        │   ├─→ pdflatex pass 1
        │   ├─→ pdflatex pass 2
        │   └─→ pdflatex pass 3
        │
        └─→ Upload Artifacts
            ├─→ PDF to Actions artifacts
            ├─→ Metadata (JSON/LaTeX)
            └─→ Auto-commit version files
```

## Commands You'll Use Most

```bash
# After updating LaTeX files
git add .
git commit -m "docs: update documentation"
git push origin main
# → Workflow automatically builds PDF

# When ready to release
git tag v0.2.0
git push origin v0.2.0
# → Workflow creates GitHub Release with PDF

# To view all versions
git tag -l

# To download artifacts locally
gh run download <run-id> -n LaTeX-PDF-<run-id>
```

## Support

For detailed information, see: **`README_LATEX_WORKFLOW.md`**

This document covers:
- Detailed workflow explanation
- All available commands
- Integration with development workflow
- Advanced configuration options
- Troubleshooting guide
- File structure reference

---

**Status**: ✅ Ready to use! Just push your changes and check the Actions tab.
