# ===================================================================
# Terraform automation script (runs from current directory)
# Steps: init → validate → plan → apply --auto-approve
# ===================================================================

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

Write-Host "`n🚀 Starting Terraform deployment..." -ForegroundColor Cyan

# Step 1: Init
Write-Host "`n==================== Terraform Init ====================" -ForegroundColor Yellow
terraform init -input=false
if ($LASTEXITCODE -ne 0) { throw "❌ Terraform init failed." }

# Step 2: Validate
Write-Host "`n================== Terraform Validate ==================" -ForegroundColor Yellow
terraform validate
if ($LASTEXITCODE -ne 0) { throw "❌ Terraform validate failed." }

# Step 3: Plan
Write-Host "`n==================== Terraform Plan ====================" -ForegroundColor Yellow
terraform plan -out=tfplan
if ($LASTEXITCODE -ne 0) { throw "❌ Terraform plan failed." }

# Step 4: Apply
Write-Host "`n==================== Terraform Apply ===================" -ForegroundColor Yellow
terraform apply --auto-approve tfplan
if ($LASTEXITCODE -ne 0) { throw "❌ Terraform apply failed." }

Write-Host "`n✅ Terraform execution completed successfully!" -ForegroundColor Green
