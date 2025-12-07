# LaTeX Workflow - Visual File Structure & Guide

## 📂 Complete Project Structure

```
devops-final-project/
│
├── .github/
│   └── workflows/
│       ├── build-latex.yml          ← ✨ NEW: GitHub Actions workflow (auto-compiles LaTeX)
│       └── ci-cd.yml                (existing)
│
├── Book_SSW590_1/
│   ├── itManual.tex                 ← Main LaTeX document (includes itProjectDemo)
│   ├── itProjectDemo.tex             ← ✨ NEW: Project Demo & DevOps Metrics chapter
│   ├── prologue.tex                 (existing - title page, abstract)
│   ├── abstract.tex                 (existing)
│   ├── itIntroduction.tex           (existing)
│   ├── itKanbanSetup.tex            (existing)
│   ├── itPasswords.tex              (existing)
│   ├── itHosts.tex                  (existing)
│   ├── itLinuxCommands.tex          (existing)
│   ├── itProjectProposal.tex        (existing)
│   ├── itAWSDeployment.tex          (existing)
│   ├── itLaTeXDocker.tex            (existing)
│   ├── itBugzilla.tex               (existing)
│   ├── itOverleaf.tex               (existing)
│   ├── itDomainSSLSetup.tex         (existing)
│   ├── itGithub.tex                 (existing)
│   ├── itPrometheusGrafana.tex      (existing)
│   ├── itJenkinsWithPytest.tex      (existing)
│   ├── itLoadBalancer.tex           (existing)
│   ├── itProject.tex                (existing)
│   ├── itAppendix.tex               (existing)
│   ├── itGlossary.tex               (existing)
│   │
│   ├── version.txt                   ← ✨ NEW: Version number (e.g., "0.1.0")
│   ├── buildinfo.tex                ← ✨ NEW: LaTeX build metadata commands
│   ├── generate-version.ps1         ← ✨ NEW: PowerShell script to generate version
│   │
│   ├── cornell.cls                  (LaTeX class definition)
│   ├── IEEEtran.cls                 (bibliography style)
│   ├── IEEEbib.bst                  (bibliography style)
│   ├── IEEEtran.bst                 (bibliography style)
│   ├── bibfile.bib                  (bibliography)
│   │
│   ├── itManual.pdf                 ← Generated PDF (created by GitHub Actions)
│   ├── build.log                    ← Build log (created by pdflatex)
│   │
│   ├── eps/
│   │   └── Screenshots/
│   └── png/
│
├── README_LATEX_WORKFLOW.md         ← ✨ NEW: Full workflow documentation
├── LATEX_WORKFLOW_QUICKSTART.md     ← ✨ NEW: Quick start guide
├── LATEX_WORKFLOW_IMPLEMENTATION_SUMMARY.md ← ✨ NEW: This implementation summary
├── LATEX_WORKFLOW_FILE_GUIDE.md    ← ✨ NEW: Visual guide (this file)
│
├── buildinfo.json                   ← ✨ NEW: Build metadata in JSON format
├── README.md                        (existing)
├── COMPLETION_SUMMARY.md            (existing)
├── ISSUE_TRACKING.md                (existing)
├── index.html                       (existing)
├── style.css                        (existing)
└── demo.js                          (existing)
```

## 🆕 Files You Need to Know About

### 1️⃣ **GitHub Actions Workflow** (`.github/workflows/build-latex.yml`)
```
PURPOSE: Automatically compiles LaTeX to PDF on every push
TRIGGERED: Push to main/develop branches with changes to LaTeX files
DOES:
  ✓ Installs LaTeX packages
  ✓ Generates version info from git
  ✓ Compiles LaTeX document 3 times
  ✓ Uploads PDF as artifact
  ✓ Creates releases on version tags
  ✓ Auto-commits version files

WHERE TO FIND OUTPUT:
  → GitHub Actions tab → Latest run → Artifacts section
```

### 2️⃣ **New LaTeX Chapter** (`Book_SSW590_1/itProjectDemo.tex`)
```
PURPOSE: Documenting DevOps metrics and build information
CONTENT:
  ✓ Build and deployment information table
  ✓ CI/CD pipeline description
  ✓ Version history and semantic versioning
  ✓ Deployment artifacts documentation
  ✓ DevOps best practices
  ✓ Build status timeline instructions
  ✓ How to view current build information

WHERE IT APPEARS:
  → Automatically included in compiled PDF
  → Chapter title: "Project Demo and DevOps Metrics"
  → Located after itProject chapter
```

### 3️⃣ **Version Files** (3 related files)

#### `Book_SSW590_1/version.txt`
```
PURPOSE: Store current version number
FORMAT: Plain text (e.g., "0.1.0")
USED BY: LaTeX document (\input{version.txt})
UPDATED: Automatically by GitHub Actions on each build
LOCATION IN PDF: Footer of every page
```

#### `Book_SSW590_1/buildinfo.tex`
```
PURPOSE: Store build metadata as LaTeX commands
FORMAT: LaTeX command definitions
COMMANDS DEFINED:
  \buildversion       → Current version (e.g., 0.1.0)
  \commitHash         → Latest commit hash (e.g., a1b2c3d)
  \commitMessage      → Latest commit message
  \authorName         → Git commit author
  \buildTimestamp     → Build date/time
  \branchName         → Current git branch
  \totalCommits       → Total commits in repo

USAGE IN LATEX:
  \input{buildinfo}
  Version: \buildversion
  Author: \authorName
```

#### `buildinfo.json`
```
PURPOSE: Store build metadata in JSON format
FORMAT: JSON (machine-readable)
CONTAINS:
  {
    "version": "0.1.0",
    "commitHash": "a1b2c3d",
    "commitMessage": "...",
    "author": "John Doe",
    "timestamp": "2024-12-07 14:30:45",
    "branch": "main",
    "totalCommits": 42,
    "buildDate": "2024-12-07T14:35:22Z",
    "pdfPath": "Book_SSW590_1/itManual.pdf",
    "repository": "natalyjc/devops-final-project",
    "workflowRun": "https://github.com/.../actions/runs/123456789"
  }

USED BY: External tools, dashboards, automated systems
```

### 4️⃣ **Version Generation Script** (`Book_SSW590_1/generate-version.ps1`)
```
PURPOSE: Generate version and build info files locally
LANGUAGE: PowerShell 5.1+
USAGE:
  .\Book_SSW590_1\generate-version.ps1

GENERATES:
  ✓ version.txt
  ✓ buildinfo.tex
  ✓ buildinfo.json (not in script, but used by workflow)

WHEN TO RUN:
  - For local testing before pushing
  - To generate version info without GitHub Actions
  - For CI/CD integration
```

## 📊 Information Flow Diagram

```
┌─────────────────────────────────────────────────────┐
│            Your Git Repository                      │
│  (commits with authors, messages, timestamps)       │
└──────────────────┬──────────────────────────────────┘
                   │
                   │ git push origin main
                   ▼
┌─────────────────────────────────────────────────────┐
│    GitHub Actions Workflow Triggered                │
│          (build-latex.yml)                          │
└──────────────────┬──────────────────────────────────┘
                   │
        ┌──────────┴──────────┐
        │                     │
        ▼                     ▼
┌───────────────────┐  ┌──────────────────────┐
│ Extract from Git  │  │ Install LaTeX        │
├───────────────────┤  └──────────────────────┘
│ • Version number  │
│ • Commit hash     │         │
│ • Author name     │         │
│ • Timestamp       │         ▼
│ • Branch name     │  ┌──────────────────────┐
│ • Commit count    │  │ Create version files │
└────────┬──────────┘  ├──────────────────────┤
         │             │ version.txt          │
         │             │ buildinfo.tex        │
         └─────┬───────┤ buildinfo.json       │
               │       └──────────────────────┘
               │
               ▼
        ┌──────────────────────┐
        │  Compile LaTeX       │
        │  (3 passes)          │
        ├──────────────────────┤
        │ itManual.tex         │
        │ +                    │
        │ itProjectDemo.tex    │
        │ +                    │
        │ All other chapters   │
        │ +                    │
        │ version.txt          │
        │ buildinfo.tex        │
        └──────────────────────┘
               │
               ▼
        ┌──────────────────────┐
        │   itManual.pdf       │
        │  (Your compiled PDF) │
        └──────────────────────┘
               │
        ┌──────┴──────┬──────────────┐
        │             │              │
        ▼             ▼              ▼
    ┌────────┐  ┌─────────┐  ┌──────────────┐
    │Artifact│  │ Release │  │Auto-commit   │
    │Storage │  │Creation │  │version files │
    └────────┘  └─────────┘  └──────────────┘
```

## 🔄 Data Flow Through the PDF

```
buildinfo.tex & version.txt
        │
        ├──→ Read by itManual.tex (via \input commands)
        │
        ├──→ Inserted into:
        │    • Title page (date: \today)
        │    • Document footer (version: \version)
        │    • Project Demo chapter (if referenced)
        │    • Metadata section
        │
        └──→ Compiled into itManual.pdf
```

## 🎯 What Happens When You Push

```
SEQUENCE OF EVENTS:

1. You commit and push changes
   → git push origin main

2. GitHub detects the push
   → Checks if files in Book_SSW590_1/ changed

3. Workflow starts (1-2 min delay for setup)
   → checkout
   → install LaTeX
   → generate version

4. Version generation extracts:
   → version (from git describe)
   → commit hash (git rev-parse --short HEAD)
   → author (git log -1 --pretty=%an)
   → timestamp (git log -1 --pretty=%ai)
   → etc.

5. Creates files:
   → Book_SSW590_1/version.txt (e.g., "0.1.0")
   → Book_SSW590_1/buildinfo.tex (LaTeX commands)
   → buildinfo.json (JSON metadata)

6. LaTeX compilation
   → pdflatex reads itManual.tex
   → \input{version.txt} inserts "0.1.0"
   → \input{buildinfo} inserts metadata commands
   → Compiles to PDF 3 times
   → Creates itManual.pdf

7. Upload and commit
   → PDF uploaded as artifact
   → Version files auto-committed
   → GitHub Release created (if version tag)

8. You download
   → Go to Actions → Latest build
   → Download LaTeX-PDF artifact
   → View PDF in itManual.pdf
```

## 📋 File Update Timeline

```
BEFORE PUSH:
  version.txt        → "0.1.0" (from last build)
  buildinfo.tex      → Last build's metadata
  buildinfo.json     → Last build's metadata

AFTER YOU PUSH:
  (GitHub Actions runs)

DURING WORKFLOW:
  step 1: Extract new version from git
  step 2: Write new version.txt      → "0.1.5" (example)
  step 3: Write new buildinfo.tex    → Latest commit info
  step 4: Compile LaTeX with new files
  step 5: Upload PDF with version 0.1.5

AFTER WORKFLOW COMPLETES:
  version.txt        → "0.1.5" (auto-committed)
  buildinfo.tex      → Latest metadata (auto-committed)
  buildinfo.json     → Latest metadata (auto-committed)
  itManual.pdf       → Available as artifact
```

## 🚀 Quick Reference

### For Documentation Writers
```
EDITING FLOW:
1. Edit any .tex file in Book_SSW590_1/
2. Commit: git commit -m "docs: ..."
3. Push: git push origin main
4. Wait 1-2 minutes
5. Download PDF from Actions

NO NEED TO:
✗ Run pdflatex manually
✗ Edit version files (done automatically)
✗ Create artifacts manually
```

### For Developers
```
VERSION TRACKING:
1. Version auto-updates from git
2. Commit count tracked automatically
3. Author names captured per commit
4. Create tags for releases: git tag v0.2.0

ACCESSING BUILDS:
- GitHub Actions: repo → Actions → Latest build
- Artifacts: Artifacts section in the run
- Releases: repo → Releases (for tagged versions)
```

### For CI/CD Integration
```
METADATA AVAILABLE:
- buildinfo.json has all technical info
- Can parse JSON for automated deployment
- PDF path available in metadata
- Repository and workflow run URLs included
```

## 📖 Reading Guide

```
START HERE:
  1. This file (overview)
  2. LATEX_WORKFLOW_QUICKSTART.md (4 easy steps)
  3. README_LATEX_WORKFLOW.md (detailed reference)

FOR SPECIFIC TASKS:
  - Creating releases: See LATEX_WORKFLOW_QUICKSTART.md
  - Troubleshooting: See README_LATEX_WORKFLOW.md
  - Technical details: See LATEX_WORKFLOW_IMPLEMENTATION_SUMMARY.md
  - Configuration: See README_LATEX_WORKFLOW.md → Advanced Configuration
```

## ✅ Everything Is Ready

```
CREATED FILES:
  ✓ .github/workflows/build-latex.yml
  ✓ Book_SSW590_1/itProjectDemo.tex
  ✓ Book_SSW590_1/generate-version.ps1
  ✓ Book_SSW590_1/version.txt
  ✓ Book_SSW590_1/buildinfo.tex
  ✓ buildinfo.json
  ✓ README_LATEX_WORKFLOW.md
  ✓ LATEX_WORKFLOW_QUICKSTART.md
  ✓ LATEX_WORKFLOW_IMPLEMENTATION_SUMMARY.md
  ✓ This file

NEXT STEP:
  git push origin main
  
THEN:
  Watch GitHub Actions compile your PDF with version info! 🎉
```

---

**Status**: ✅ Complete and ready to use!
