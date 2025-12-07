# DevOps LaTeX Workflow Documentation

## Overview

This document describes the automated LaTeX compilation and PDF generation workflow for the DevOps SSW590 project documentation. The system automatically captures build and deployment metrics on every commit and generates updated PDF documentation.

## Workflow Components

### 1. **New LaTeX Chapter: Project Demo** (`Book_SSW590_1/itProjectDemo.tex`)

A new chapter that documents:
- Build and deployment information
- Continuous integration pipeline details
- Version history tracking
- Deployment artifacts
- DevOps best practices implemented
- How to view current build information

This chapter is automatically updated with each build and provides a comprehensive overview of the project's DevOps practices.

### 2. **Version Generation Script** (`Book_SSW590_1/generate-version.ps1`)

A PowerShell script that:
- Extracts version information from git tags
- Captures the latest commit hash, message, and author
- Records the build timestamp and branch name
- Generates three types of output files:
  - `version.txt` - Version number only (for LaTeX)
  - `buildinfo.tex` - LaTeX commands with all build metadata
  - `buildinfo.json` - JSON format for programmatic access

**Usage (Local):**
```powershell
# From the project root
.\Book_SSW590_1\generate-version.ps1 -WorkspacePath .

# Or from Book_SSW590_1 directory
.\generate-version.ps1
```

### 3. **GitHub Actions Workflow** (`.github/workflows/build-latex.yml`)

An automated CI/CD pipeline triggered on:
- Every push to `main` or `develop` branches
- Changes to LaTeX files in `Book_SSW590_1/`
- Manual workflow dispatch

The workflow:
1. Checks out the repository with full history
2. Generates version and build information
3. Installs LaTeX dependencies
4. Compiles LaTeX to PDF (3 passes for proper references)
5. Validates the build
6. Uploads PDF and metadata as artifacts
7. Creates releases on version tags
8. Auto-commits version updates to the repository

### 4. **Version and Build Info Files**

#### `Book_SSW590_1/version.txt`
- Contains only the version number
- Used by LaTeX via `\input{version.txt}`
- Auto-updated on each build

#### `Book_SSW590_1/buildinfo.tex`
- Contains LaTeX command definitions
- Provides:
  - `\buildversion` - Current version
  - `\commitHash` - Latest commit hash
  - `\commitMessage` - Latest commit message
  - `\authorName` - Commit author
  - `\buildTimestamp` - Build timestamp
  - `\branchName` - Current branch
  - `\totalCommits` - Total commit count

#### `buildinfo.json`
- Machine-readable format of build information
- Can be used by other tools and dashboards
- Contains repository URL and workflow run link

## Version Information Tracking

### Semantic Versioning

The system supports semantic versioning (MAJOR.MINOR.PATCH):

- **MAJOR**: Significant architecture changes or breaking changes
- **MINOR**: New features or non-breaking changes
- **PATCH**: Bug fixes and hotfixes

### Git Tags for Versioning

Create version tags to trigger releases:

```bash
# Create a new version tag
git tag v0.2.0
git push origin v0.2.0

# List all tags
git tag -l

# List tags with annotations
git tag -l -n
```

## LaTeX Integration

### Using Version Information in LaTeX

The version and build information can be used in the LaTeX document:

```latex
% Include the build information commands
\input{buildinfo}

% In your document, use the commands:
Version: \buildversion
Commit: \commitHash
Author: \authorName
Built: \buildTimestamp
```

### Current Implementation

In `itManual.tex`:
- Version appears in the footer: `Version \version`
- The `prologue.tex` displays document metadata
- The new `itProjectDemo` chapter references these values

## Workflow Steps

### Local Development

1. **Make changes to LaTeX files**
   ```bash
   # Edit files in Book_SSW590_1/
   ```

2. **Generate version locally (optional)**
   ```powershell
   .\Book_SSW590_1\generate-version.ps1
   ```

3. **Compile locally (if LaTeX installed)**
   ```bash
   cd Book_SSW590_1
   pdflatex -interaction=nonstopmode itManual.tex
   ```

4. **Commit and push**
   ```bash
   git add .
   git commit -m "Update documentation"
   git push origin main
   ```

### Automated CI/CD

1. **Push triggers workflow** - GitHub Actions automatically starts
2. **Version generated** - Captures git commit info
3. **LaTeX compiled** - PDF generated from source
4. **Artifacts uploaded** - PDF and metadata available for download
5. **Auto-commit** - Version files committed back (if changed)
6. **Release created** - On version tags, a GitHub release is created

## Accessing Build Artifacts

### GitHub Actions UI

1. Go to repository → Actions tab
2. Select "Build LaTeX Document and Generate PDF" workflow
3. Choose the latest run
4. Download artifacts from the run summary:
   - `LaTeX-PDF-[RUN-ID]` - Contains the compiled PDF
   - `Build-Metadata-[RUN-ID]` - Contains version.txt and buildinfo files

### GitHub Releases

For tagged releases:
1. Go to repository → Releases
2. Download the PDF from the release assets

### Command Line

```bash
# View workflow runs
gh run list --workflow build-latex.yml

# Download artifacts from latest successful run
gh run download -n LaTeX-PDF-<run-id>
```

## PDF Contents

The generated PDF includes:

- **Title Page**: Project title, authors, date
- **Abstract**: Project overview
- **Table of Contents**: All chapters and sections
- **Document Update History**: Version tracking
- **All Chapters**: Including the new Project Demo chapter
- **Project Demo Chapter**: DevOps metrics and build information
- **Appendices**: Supporting materials
- **Bibliography**: References
- **Index**: Searchable terms and concepts

The PDF footer displays:
- Current chapter number
- Copyright notice
- Current date
- Page numbers

## Version Metadata in PDF

The PDF includes version information in:
- Title page date (auto-generated)
- Version footer on each page
- Project Demo chapter (documents the build process)
- PDF metadata (creation date, modification date)

## Troubleshooting

### PDF Not Generated

1. **Check build log**: View the "Build LaTeX to PDF" step in the workflow
2. **Common issues**:
   - Missing packages: Workflow installs basic LaTeX
   - Undefined references: Run pdflatex multiple times (workflow does 3 passes)
   - Syntax errors: Check LaTeX file syntax

### Version Not Updating

1. **Check git configuration**: Ensure you have commits in the repository
2. **Check workflow logs**: View the "Generate version and build information" step
3. **Manual update**: Run `generate-version.ps1` locally and commit

### Artifacts Not Uploading

1. **Check workflow permissions**: Repository needs to allow artifacts
2. **Check branch**: Workflow runs on `main` and `develop` branches only
3. **Check paths**: Workflow only triggers on changes to `Book_SSW590_1/` or the workflow itself

## Best Practices

1. **Frequent commits**: More commits = better history tracking
2. **Meaningful commit messages**: Clearly describe changes
3. **Use version tags**: Tag releases with semantic versions
4. **Review build logs**: Check for warnings in the workflow output
5. **Update Project Demo chapter**: Document major changes in the chapter
6. **Archive PDFs**: Keep important versions as releases

## Advanced Configuration

### Customizing Trigger Events

Edit `.github/workflows/build-latex.yml` to trigger on:
- Scheduled times: `schedule: [cron: '0 0 * * 0']`
- Pull requests: Add `pull_request:` event
- Specific paths: Modify the `paths:` section

### Customizing LaTeX Compilation

Modify the compilation steps in the workflow:
- Change output directory: Adjust `-output-directory` parameter
- Add auxiliary tools: Bibtex, Makeindex, etc.
- Enable draft mode: Add `\documentclass[draft]{cornell}`

### Creating Pre-releases

Tag versions with pre-release identifiers:
```bash
git tag v0.2.0-alpha.1
git push origin v0.2.0-alpha.1
```

## Integration with Development Workflow

### Recommended Git Workflow

1. **Create feature branch**
   ```bash
   git checkout -b feature/update-docs
   ```

2. **Make LaTeX updates**
   ```bash
   # Edit files in Book_SSW590_1/
   ```

3. **Verify locally (optional)**
   ```powershell
   .\Book_SSW590_1\generate-version.ps1
   ```

4. **Create pull request**
   ```bash
   git push origin feature/update-docs
   # Create PR on GitHub
   ```

5. **Merge to main**
   - GitHub Actions auto-builds and generates PDF
   - Artifacts available in workflow run
   - Version auto-updates

6. **Create release (when stable)**
   ```bash
   git tag v0.2.0
   git push origin v0.2.0
   # GitHub creates release with PDF attached
   ```

## Dependencies

### Required for GitHub Actions Workflow
- Ubuntu Linux (provided by GitHub)
- `texlive-latex-base`
- `texlive-latex-extra`
- `texlive-fonts-recommended`
- Git (for version information)

### Required for Local Compilation
- MiKTeX or TeX Live (full LaTeX installation)
- PowerShell 5.1+ (for version script)
- Git (for version information)

### LaTeX Packages Used (in cornell.cls)
- `hyperref` - Hyperlinks and PDF bookmarks
- `listings` - Code listings
- `fancyhdr` - Header and footer customization
- `glossaries` - Glossary support
- `minted` - Syntax highlighting
- And others defined in `itManual.tex`

## File Structure

```
devops-final-project/
├── .github/
│   └── workflows/
│       └── build-latex.yml          ← CI/CD workflow
├── Book_SSW590_1/
│   ├── itManual.tex                 ← Main document
│   ├── itProjectDemo.tex            ← New chapter (auto-included)
│   ├── prologue.tex                 ← Title page and metadata
│   ├── version.txt                  ← Version number
│   ├── buildinfo.tex                ← LaTeX build commands
│   ├── buildinfo.json               ← JSON metadata
│   ├── generate-version.ps1         ← Version generation script
│   ├── itManual.pdf                 ← Compiled output
│   └── [other chapter files]
├── buildinfo.json                   ← Latest build info
└── README_LATEX_WORKFLOW.md         ← This file
```

## Summary

This comprehensive workflow provides:

✅ **Automatic PDF Generation** - Every commit triggers a rebuild
✅ **Version Tracking** - Git-based semantic versioning
✅ **Build Metadata** - Captures commit, author, timestamp info
✅ **DevOps Documentation** - New chapter documenting the process
✅ **Artifact Management** - PDFs and metadata stored in artifacts and releases
✅ **CI/CD Integration** - Fully automated using GitHub Actions
✅ **Best Practices** - Implements standard DevOps workflows

The system ensures that your documentation is always up-to-date with the latest build information and compiled into an easily distributable PDF format.
