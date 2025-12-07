# LaTeX Documentation Build Workflow

This workflow automatically compiles LaTeX documentation and generates a DevOps Project Demo chapter with every push to the main branch.

## Overview

The `latex-build.yml` workflow performs the following tasks:

1. **Version Generation**: Creates semantic versioning based on commit count
2. **Metadata Capture**: Records commit information and timestamps
3. **LaTeX Compilation**: Compiles the main document using pdflatex
4. **Artifact Generation**: Creates PDF releases and GitHub artifacts
5. **Metrics Tracking**: Captures system information during build

## Workflow Triggers

The workflow is triggered on:
- **Push**: Any push to the `main` branch that modifies files in `Book_SSW590_1/` directory
- **Manual Trigger**: Via GitHub Actions workflow_dispatch

## Components

### New Chapter: Project Demo (`itProjectDemo.tex`)

A new chapter has been added that documents:
- Build and deployment information
- Current version and commit details
- DevOps metrics and system resources
- Quality assurance procedures
- Deployment artifacts and release information
- CI/CD pipeline execution details

This chapter is included in the main document and updates with each build.

### Generated Metadata Files

The workflow creates several metadata files in `Book_SSW590_1/`:

| File | Purpose |
|------|---------|
| `version.txt` | Current version (e.g., v1.0.10) |
| `build-timestamp.txt` | Build execution timestamp |
| `commit-info.txt` | Detailed commit information |
| `build-metrics-start.json` | System metrics captured at build start |

These files are referenced in the LaTeX document and committed to the repository.

## Workflow Execution Steps

### 1. Checkout & Version Generation
```
Commit Count → Semantic Version (1.0.PATCH)
```
Extracts commit SHA, author, date, and message.

### 2. Build Metrics Capture
Records system information:
- CPU core count
- Total memory available
- Timestamp

### 3. LaTeX Compilation
Executes the following passes:
```
pdflatex → bibtex → makeindex → pdflatex
```

### 4. Artifact Verification
Confirms PDF generation and checks auxiliary files.

### 5. Metadata Generation
Creates a DevOps build report with:
- Version and commit information
- Workflow execution details
- LaTeX compilation status

### 6. Artifact Upload & Release
- Uploads PDF to GitHub Artifacts (90-day retention)
- Creates GitHub Release with documentation tag
- Attaches compiled PDF to release

## Using Generated Information in LaTeX

The metadata files are automatically loaded in the Project Demo chapter:

```latex
\item \textbf{Version:} \input{Book_SSW590_1/version.txt}
\item \textbf{Build Timestamp:} \input{Book_SSW590_1/build-timestamp.txt}
```

## Important Notes

### LaTeX Installation
The workflow checks for `pdflatex` availability on the runner. If LaTeX is not installed:
- Install via `choco install miktex` (Windows)
- Install via package manager (Linux)
- Install via Homebrew (macOS)

### Self-Hosted Runner
This workflow uses a **self-hosted runner** (`self-hosted`). Ensure your runner:
- Has LaTeX installed (`pdflatex`, `bibtex`)
- Has sufficient disk space for PDF generation
- Has access to the repository

### Skip CI
The metadata commit includes `[skip ci]` to prevent recursive workflow runs.

## Accessing Generated Documentation

### GitHub Artifacts
1. Go to Actions tab in your repository
2. Select the latest "Build LaTeX Documentation" run
3. Download the artifact: `devops-documentation-v1.0.X`

### GitHub Releases
1. Go to Releases page
2. Look for tags like `docs-v1.0.X`
3. Download the PDF from the release assets

## Troubleshooting

### LaTeX Compilation Fails
- Check the build log in the workflow output
- Ensure all required LaTeX packages are installed
- Verify `itManual.tex` includes all necessary files

### PDF Not Generated
- Check for LaTeX errors in the workflow output
- Verify file permissions and paths
- Ensure temporary files are not corrupted

### Workflow Not Triggering
- Verify the workflow file is in `.github/workflows/`
- Check branch protection rules aren't blocking the workflow
- Ensure file paths in the `on.push.paths` filter match your changes

## Configuration

### Environment Variables
Currently defined in the workflow:
- None (all generated dynamically)

### Adjustable Parameters
To modify versioning, edit in the workflow:
```yaml
VERSION_MAJOR: 1
VERSION_MINOR: 0
```

## Future Enhancements

Potential improvements:
- Add LaTeX linting (chktex)
- Generate table of contents metrics
- Track compilation time trends
- Multi-format output (PDF, HTML)
- Automated PDF comparison

## Related Files

- **Workflow**: `.github/workflows/latex-build.yml`
- **LaTeX Document**: `Book_SSW590_1/itManual.tex`
- **New Chapter**: `Book_SSW590_1/itProjectDemo.tex`
- **CI/CD Pipeline**: `.github/workflows/ci-cd.yml`
