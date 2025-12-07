# Script to generate version and build information for LaTeX documentation
# This script captures git commit information and generates metadata files

param(
    [string]$WorkspacePath = "."
)

# Change to workspace directory
Push-Location $WorkspacePath

# Get version information
$gitTag = git describe --tags --always 2>$null
if (-not $gitTag) {
    $gitTag = "0.1.0"
}

# Extract version number (without commit hash if present)
if ($gitTag -match '^v?(\d+\.\d+\.\d+)') {
    $version = $matches[1]
} else {
    $version = $gitTag
}

# Get commit information
$commitHash = git rev-parse --short HEAD 2>$null
if (-not $commitHash) { $commitHash = "unknown" }

$commitMessage = git log -1 --pretty=%B 2>$null
if (-not $commitMessage) { $commitMessage = "No commits yet" }

$author = git log -1 --pretty=%an 2>$null
if (-not $author) { $author = "unknown" }

$timestamp = git log -1 --pretty=%ai 2>$null
if (-not $timestamp) { $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss" }

$branch = git rev-parse --abbrev-ref HEAD 2>$null
if (-not $branch) { $branch = "unknown" }

# Get total commit count
$commitCount = git rev-list --count HEAD 2>$null
if (-not $commitCount) { $commitCount = 0 }

# Create version file for LaTeX
$versionContent = $version
Set-Content -Path "Book_SSW590_1/version.txt" -Value $versionContent -Encoding UTF8
Write-Host "Version file created: Book_SSW590_1/version.txt (v$version)"

# Create a build info file with all metadata
$buildInfoContent = @"
% Auto-generated build information
% Generated on: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

\newcommand{\buildversion}{$version}
\newcommand{\commitHash}{$commitHash}
\newcommand{\commitMessage}{$($commitMessage -replace '\', '/' -replace '_', '\_')}
\newcommand{\authorName}{$author}
\newcommand{\buildTimestamp}{$timestamp}
\newcommand{\branchName}{$branch}
\newcommand{\totalCommits}{$commitCount}
"@

Set-Content -Path "Book_SSW590_1/buildinfo.tex" -Value $buildInfoContent -Encoding UTF8
Write-Host "Build info file created: Book_SSW590_1/buildinfo.tex"

# Create a JSON file for programmatic access
$buildInfoJson = @{
    version = $version
    commitHash = $commitHash
    commitMessage = $commitMessage
    author = $author
    timestamp = $timestamp
    branch = $branch
    totalCommits = $commitCount
    generatedAt = (Get-Date -Format "o")
} | ConvertTo-Json

Set-Content -Path "buildinfo.json" -Value $buildInfoJson -Encoding UTF8
Write-Host "Build info JSON created: buildinfo.json"

# Create a summary for display
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Build Information Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Version:        $version"
Write-Host "Commit:         $commitHash"
Write-Host "Author:         $author"
Write-Host "Timestamp:      $timestamp"
Write-Host "Branch:         $branch"
Write-Host "Total Commits:  $commitCount"
Write-Host "Message:        $commitMessage"
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Pop-Location
