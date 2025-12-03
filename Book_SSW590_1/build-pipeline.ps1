# Pipeline Build Script - LaTeX Report + Project Code
# Shows progress of compilation pipeline
# Usage: .\build-pipeline.ps1 -OutputDir build -SkipZip:$false

param(
    [string]$OutputDir = "build",
    [switch]$SkipZip = $false
)

# Color codes for progress output
$Colors = @{
    Success = "Green"
    Error = "Red"
    Warning = "Yellow"
    Info = "Cyan"
    Progress = "Magenta"
}

function Write-ProgressStep {
    param(
        [string]$Step,
        [string]$Status,
        [string]$Color = "Info"
    )
    
    $timestamp = Get-Date -Format "HH:mm:ss"
    Write-Host "[$timestamp] " -NoNewline
    Write-Host "$Step" -ForegroundColor $Colors[$Color] -NoNewline
    Write-Host " ... $Status"
}

function Write-Header {
    param([string]$Title)
    Write-Host ""
    Write-Host "=" * 70 -ForegroundColor $Colors["Progress"]
    Write-Host $Title -ForegroundColor $Colors["Progress"]
    Write-Host "=" * 70 -ForegroundColor $Colors["Progress"]
}

function Write-SubHeader {
    param([string]$Text)
    Write-Host ""
    Write-Host "-" * 50 -ForegroundColor $Colors["Progress"]
    Write-Host $Text -ForegroundColor $Colors["Progress"]
    Write-Host "-" * 50 -ForegroundColor $Colors["Progress"]
}

# Main pipeline execution
Write-Header "DEVOPS FINAL PROJECT - LATEX COMPILATION PIPELINE"

# Step 1: Verify dependencies
Write-SubHeader "Step 1/5: Verifying Dependencies"

if (-not (Get-Command pdflatex -ErrorAction SilentlyContinue)) {
    Write-ProgressStep "LaTeX" "NOT FOUND" "Error"
    Write-Host ""
    Write-Host "Please install LaTeX distribution:" -ForegroundColor $Colors["Warning"]
    Write-Host "  Windows: https://miktex.org/download" -ForegroundColor $Colors["Warning"]
    exit 1
}
Write-ProgressStep "pdflatex" "Found" "Success"

if (-not (Get-Command bibtex -ErrorAction SilentlyContinue)) {
    Write-ProgressStep "bibtex" "NOT FOUND" "Error"
    exit 1
}
Write-ProgressStep "bibtex" "Found" "Success"

# Step 2: Setup output directory
Write-SubHeader "Step 2/5: Setting Up Build Directory"

if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
    Write-ProgressStep "Directory" "Created $OutputDir" "Success"
} else {
    Write-ProgressStep "Directory" "Already exists at $OutputDir" "Info"
    Remove-Item "$OutputDir\*" -Force -Recurse -ErrorAction SilentlyContinue
    Write-ProgressStep "Cleanup" "Cleared previous build artifacts" "Info"
}

# Step 3: Compile LaTeX Report
Write-SubHeader "Step 3/5: Compiling LaTeX Report (Multiple Passes)"

$ReportName = "itManual"
$TexFile = "itManual.tex"

if (-not (Test-Path $TexFile)) {
    Write-ProgressStep "LaTeX Compilation" "itManual.tex not found" "Error"
    exit 1
}

try {
    Write-Host ""
    Write-ProgressStep "Pass 1" "Running pdflatex (initial pass)..." "Progress"
    $output = pdflatex -interaction=nonstopmode -output-directory=$OutputDir $TexFile 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ⚠ pdflatex completed with warnings" -ForegroundColor $Colors["Warning"]
    } else {
        Write-Host "  ✓ Pass 1 complete" -ForegroundColor $Colors["Success"]
    }
    
    Write-Host ""
    Write-ProgressStep "Bibliography" "Running bibtex..." "Progress"
    Push-Location $OutputDir
    $bibOutput = bibtex $ReportName 2>&1
    Pop-Location
    Write-Host "  ✓ Bibliography processed" -ForegroundColor $Colors["Success"]
    
    Write-Host ""
    Write-ProgressStep "Pass 2" "Running pdflatex (bibliography pass)..." "Progress"
    $output = pdflatex -interaction=nonstopmode -output-directory=$OutputDir $TexFile 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ⚠ pdflatex completed with warnings" -ForegroundColor $Colors["Warning"]
    } else {
        Write-Host "  ✓ Pass 2 complete" -ForegroundColor $Colors["Success"]
    }
    
    Write-Host ""
    Write-ProgressStep "Pass 3" "Running pdflatex (final pass)..." "Progress"
    $output = pdflatex -interaction=nonstopmode -output-directory=$OutputDir $TexFile 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ⚠ pdflatex completed with warnings" -ForegroundColor $Colors["Warning"]
    } else {
        Write-Host "  ✓ Pass 3 complete" -ForegroundColor $Colors["Success"]
    }
    
    Write-Host ""
    
    if (Test-Path "$OutputDir\$ReportName.pdf") {
        $pdfSize = (Get-Item "$OutputDir\$ReportName.pdf").Length / 1MB
        Write-ProgressStep "✓ LaTeX" "Successfully compiled to $ReportName.pdf ($($pdfSize.ToString('F2')) MB)" "Success"
    } else {
        Write-ProgressStep "✗ LaTeX" "PDF not created - check for errors" "Error"
    }
} catch {
    Write-ProgressStep "✗ LaTeX Compilation" "Error: $_" "Error"
}

# Step 4: Prepare Project Files
Write-SubHeader "Step 4/5: Preparing Project Files for Packaging"

$ProjectFiles = @(
    "demo.js",
    "index.html",
    "style.css",
    "p5.js",
    "p5.sound.min.js",
    "README.md"
)

$ProjectDir = "$OutputDir\project"
if (-not (Test-Path $ProjectDir)) {
    New-Item -ItemType Directory -Path $ProjectDir -Force | Out-Null
}

$CopiedCount = 0
$RootDir = Split-Path -Parent $PSScriptRoot

foreach ($file in $ProjectFiles) {
    $sourcePath = Join-Path $RootDir $file
    if (Test-Path $sourcePath) {
        Copy-Item -Path $sourcePath -Destination $ProjectDir -Force
        Write-Host "  ✓ Copied $file" -ForegroundColor $Colors["Success"]
        $CopiedCount++
    } else {
        Write-Host "  ⚠ Skipped $file (not found)" -ForegroundColor $Colors["Warning"]
    }
}

Write-Host ""
Write-ProgressStep "Project Files" "Prepared $CopiedCount files" "Success"

# Step 5: Create Project Archive
Write-SubHeader "Step 5/5: Creating Project Archive"

if (-not $SkipZip) {
    $ZipPath = "$OutputDir\project.zip"
    
    try {
        if (Test-Path $ZipPath) {
            Remove-Item $ZipPath -Force
        }
        
        Write-ProgressStep "Compressing" "Creating project.zip..." "Progress"
        
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::CreateFromDirectory($ProjectDir, $ZipPath, [System.IO.Compression.CompressionLevel]::Optimal, $false)
        
        $ZipSize = (Get-Item $ZipPath).Length / 1MB
        Write-ProgressStep "✓ Archive" "Created project.zip ($($ZipSize.ToString('F2')) MB)" "Success"
    } catch {
        Write-ProgressStep "✗ Archive" "Error: $_" "Error"
    }
} else {
    Write-ProgressStep "Archive" "Skipped (--SkipZip flag set)" "Info"
}

# Pipeline Summary
Write-Header "BUILD PIPELINE SUMMARY"

Write-Host "Generated Artifacts:" -ForegroundColor $Colors["Progress"]
Write-Host ""

if (Test-Path "$OutputDir\$ReportName.pdf") {
    $pdfSize = (Get-Item "$OutputDir\$ReportName.pdf").Length / 1MB
    Write-Host "  ✓ $ReportName.pdf" -ForegroundColor $Colors["Success"]
    Write-Host "    Size: $($pdfSize.ToString('F2')) MB"
}

if (Test-Path "$OutputDir\project") {
    Write-Host "  ✓ project/ (directory)" -ForegroundColor $Colors["Success"]
    Write-Host "    Files: $CopiedCount"
}

if (Test-Path "$OutputDir\project.zip") {
    $zipSize = (Get-Item "$OutputDir\project.zip").Length / 1MB
    Write-Host "  ✓ project.zip" -ForegroundColor $Colors["Success"]
    Write-Host "    Size: $($zipSize.ToString('F2')) MB"
}

Write-Host ""
Write-Host "Output Directory: $(Resolve-Path $OutputDir)" -ForegroundColor $Colors["Cyan"]
Write-Host ""
Write-Host "Pipeline Status: " -NoNewline -ForegroundColor $Colors["Progress"]
Write-Host "✓ COMPLETE" -ForegroundColor $Colors["Success"]
Write-Host ""
