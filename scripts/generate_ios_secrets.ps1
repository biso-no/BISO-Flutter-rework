# iOS Deployment Secrets Generator
# This script generates all required secrets for iOS deployment automation

param(
    [Parameter(Mandatory=$false)]
    [string]$SecretsDir = "ios_secrets"
)

# Helper functions
function Write-Success($text) { 
    Write-Host "[SUCCESS] $text" -ForegroundColor Green 
}

function Write-Error($text) { 
    Write-Host "[ERROR] $text" -ForegroundColor Red 
}

function Write-Warning($text) { 
    Write-Host "[WARNING] $text" -ForegroundColor Yellow 
}

function Write-Info($text) { 
    Write-Host "[INFO] $text" -ForegroundColor Cyan 
}

Write-Host "iOS Deployment Secrets Generator" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Check if secrets directory exists
if (-not (Test-Path $SecretsDir)) {
    Write-Error "Secrets directory not found: $SecretsDir"
    exit 1
}

Write-Info "Reading files from: $SecretsDir"

# Read app information
$appInfoPath = Join-Path $SecretsDir "app_info.txt"
if (-not (Test-Path $appInfoPath)) {
    Write-Error "app_info.txt not found in $SecretsDir"
    exit 1
}

$appInfo = @{}
Get-Content $appInfoPath | ForEach-Object {
    if ($_ -match "^(.+?):\s*(.+)$") {
        $appInfo[$matches[1].Trim()] = $matches[2].Trim()
    }
}

Write-Success "App information loaded:"
Write-Host "  Bundle ID: $($appInfo['Bundle ID'])"
Write-Host "  Team ID: $($appInfo['Team ID'])"
Write-Host "  Apple ID: $($appInfo['Apple ID'])"
Write-Host ""

# Find and read API key
$apiKeyPath = Get-ChildItem -Path $SecretsDir -Filter "AuthKey*.p8" | Select-Object -First 1
if (-not $apiKeyPath) {
    Write-Error "No AuthKey*.p8 file found in $SecretsDir"
    exit 1
}

$apiKeyId = "YJD6N4U4S4"
Write-Success "Found API key: $($apiKeyPath.Name) (ID: $apiKeyId)"

# Base64 encode the API key
$apiKeyBytes = [System.IO.File]::ReadAllBytes($apiKeyPath.FullName)
$apiKeyBase64 = [System.Convert]::ToBase64String($apiKeyBytes)

# Generate SSH key for fastlane match
$sshKeyPath = "$env:USERPROFILE\.ssh\github_actions_ios_deploy"
Write-Info "Generating SSH key for fastlane match..."

# Ensure .ssh directory exists
$sshDir = "$env:USERPROFILE\.ssh"
if (-not (Test-Path $sshDir)) {
    New-Item -ItemType Directory -Path $sshDir -Force | Out-Null
}

# Remove existing key if it exists
if (Test-Path $sshKeyPath) {
    Remove-Item $sshKeyPath -Force
}
if (Test-Path "$sshKeyPath.pub") {
    Remove-Item "$sshKeyPath.pub" -Force
}

# Generate new SSH key - Windows ssh-keygen syntax
Write-Info "Generating SSH key..."
Write-Info "When prompted for passphrase, just press ENTER (leave empty)"

$process = Start-Process -FilePath "ssh-keygen" -ArgumentList @(
    "-t", "ed25519",
    "-C", "github-actions-ios-biso", 
    "-f", $sshKeyPath
) -Wait -PassThru -NoNewWindow

if ($process.ExitCode -ne 0) {
    Write-Error "SSH key generation failed with exit code: $($process.ExitCode)"
    exit 1
}

if (-not (Test-Path $sshKeyPath)) {
    Write-Error "Failed to generate SSH key"
    exit 1
}

# Read SSH keys
$sshPrivateKey = Get-Content $sshKeyPath -Raw
$sshPublicKey = Get-Content "$sshKeyPath.pub" -Raw
$sshPrivateKeyBase64 = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($sshPrivateKey))

Write-Success "SSH key generated successfully"

# Get issuer ID from user
Write-Warning "We need your App Store Connect Issuer ID"
Write-Info "Find it at: App Store Connect -> Users and Access -> Keys -> View API Key Details"
Write-Info "It should be a UUID format like: 12345678-1234-1234-1234-123456789012"
$issuerIdInput = Read-Host "Enter your App Store Connect Issuer ID"

# Generate match password
Write-Info "Generating secure password for fastlane match..."
$matchPassword = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 24 | ForEach-Object {[char]$_})

Write-Success "All secrets generated!"
Write-Host ""

# Output results
Write-Host "GITHUB SECRETS TO ADD" -ForegroundColor Cyan
Write-Host "=====================" -ForegroundColor Cyan
Write-Host "Go to your repository -> Settings -> Secrets and variables -> Actions" -ForegroundColor Cyan
Write-Host ""

Write-Host "APPLE_API_KEY_ID:" -ForegroundColor Yellow
Write-Host $apiKeyId
Write-Host ""

Write-Host "APPLE_API_ISSUER_ID:" -ForegroundColor Yellow
Write-Host $issuerIdInput
Write-Host ""

Write-Host "APPLE_API_PRIVATE_KEY:" -ForegroundColor Yellow
Write-Host $apiKeyBase64
Write-Host ""

Write-Host "MATCH_PASSWORD:" -ForegroundColor Yellow
Write-Host $matchPassword
Write-Host ""

Write-Host "MATCH_SSH_KEY:" -ForegroundColor Yellow
Write-Host $sshPrivateKeyBase64
Write-Host ""

Write-Host "APP_STORE_CONNECT_TEAM_ID:" -ForegroundColor Yellow
Write-Host $appInfo['Team ID']
Write-Host ""

# Save secrets to file
$secretsContent = "APPLE_API_KEY_ID=$apiKeyId`r`n"
$secretsContent += "APPLE_API_ISSUER_ID=$issuerIdInput`r`n"
$secretsContent += "APPLE_API_PRIVATE_KEY=$apiKeyBase64`r`n"
$secretsContent += "MATCH_PASSWORD=$matchPassword`r`n"
$secretsContent += "MATCH_SSH_KEY=$sshPrivateKeyBase64`r`n"
$secretsContent += "APP_STORE_CONNECT_TEAM_ID=$($appInfo['Team ID'])`r`n"

$secretsContent | Out-File -FilePath "github_secrets.txt" -Encoding UTF8
Write-Success "Secrets saved to: github_secrets.txt"

# Show SSH public key for certificates repo
Write-Host ""
Write-Host "CERTIFICATES REPOSITORY SETUP" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan
Write-Host ""

Write-Info "1. Go to: https://github.com/biso-no/ios-certificates"
Write-Info "2. Go to Settings -> Deploy keys -> Add deploy key"
Write-Info "3. Title: GitHub Actions iOS Deploy"
Write-Info "4. Allow write access: YES"
Write-Info "5. Key (copy the text below):"
Write-Host ""
Write-Host $sshPublicKey -ForegroundColor Green
Write-Host ""

Write-Host "NEXT STEPS" -ForegroundColor Cyan
Write-Host "==========" -ForegroundColor Cyan
Write-Host ""

Write-Info "1. Add the SSH deploy key to ios-certificates repo"
Write-Info "2. Add all GitHub Secrets from github_secrets.txt"
Write-Info "3. Run: cd ios"
Write-Info "4. Run: bundle install"
Write-Info "5. Run: bundle exec fastlane match appstore"
Write-Info "6. Test: bundle exec fastlane beta"

Write-Warning "IMPORTANT: Delete github_secrets.txt after adding secrets to GitHub!"
Write-Success "Setup complete!"