# Push akdamia scaffold to GitHub
# Usage:
#  - Option A (recommended): authenticate with GitHub CLI (gh auth login), then run this script.
#  - Option B: set environment variable GITHUB_TOKEN with a personal access token (repo scope) and run the script.
# Notes: If using GITHUB_TOKEN, be careful not to leave it in shell history or remote configs.

param()

$repoUrl = 'https://github.com/treesbeats/akdamia.git'
$projectDir = Join-Path (Get-Location).ProviderPath 'akdamia'
if (-not (Test-Path $projectDir)) {
  Write-Error "Directory not found: $projectDir. Run this script from the folder that contains the 'akdamia' directory."
  exit 1
}

Set-Location $projectDir

if (Test-Path .git) {
  Write-Host ".git already exists — will perform an add/commit and push to origin." -ForegroundColor Yellow
} else {
  git init
  git checkout -b main
}

git add .
try {
  git commit -m "Initial scaffold"
} catch {
  Write-Host "No changes to commit or git commit failed: $_" -ForegroundColor Yellow
}

# Prefer GH CLI if available
$gh = Get-Command gh -ErrorAction SilentlyContinue
if ($gh) {
  Write-Host "Detected GitHub CLI. Ensuring remote 'origin' is set to $repoUrl"
  git remote remove origin 2>$null | Out-Null
  git remote add origin $repoUrl
  git push -u origin main
  exit $LASTEXITCODE
}

# If GITHUB_TOKEN provided, use it (CAUTION: token in URL is sensitive)
if ($env:GITHUB_TOKEN) {
  $token = $env:GITHUB_TOKEN
  $authUrl = $repoUrl -replace 'https://', "https://$token@"
  Write-Host "Pushing using GITHUB_TOKEN environment variable (token will be used in remote URL temporarily)."
  git remote remove origin 2>$null | Out-Null
  git remote add origin $authUrl
  git push -u origin main
  Write-Host "Removing tokenized remote and re-adding the normal remote URL."
  git remote remove origin
  git remote add origin $repoUrl
  exit $LASTEXITCODE
}

# Fallback: try pushing to normal https remote (user will be prompted to login if required)
Write-Host "No GH CLI and no GITHUB_TOKEN detected. Attempting to add normal https remote and push (you may be prompted for credentials)."
git remote remove origin 2>$null | Out-Null
git remote add origin $repoUrl
git push -u origin main
exit $LASTEXITCODE
