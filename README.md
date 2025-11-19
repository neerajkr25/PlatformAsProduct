# PlatformAsProduct

**Author:** NeerajKumar(NeerajKr25) 
**Purpose:** This repo will be creating below resources.


**1- /iac/ :-** Vnet, Private AKS, Public AppGateway, Bastion Host, JumpBox VM, Postgress Flexible server, 2 VM, Key Vault. 


**2- **/deployment/**** :- it contains all the `yaml manifests1` you can deploy application, it also deploy the Istio Ingress gateway with private IP for internal routing. later connect it with AppGateway. 


**3- **/apps/**** :- We can have application code and create Docker file to create ACR image.     
This README gives clean, actionable instructions to bootstrap, develop, and operate this repo.

---

## Table of contents
1. [Repo layout](#repo-layout)  
2. [Prerequisites](#prerequisites)  
3. [Quickstart — local dev & infra bootstrap](#quickstart)  
4. [Terraform (iac) — usage & best practice](#terraform)  
5. [Build & push Docker images](#docker)  
6. [AKS & deployments (apps/ and deployments/)](#aks-deploy)    
7. [CI/CD — Azure DevOps pipeline notes](#ci-cd)  
8. [Common issues & fixes (big one: large file already committed)](#common-issues)  
9. [Helpful references](#references)

---

## Repo layout
```

/apps/           # application source code (node/java/etc)
/deployments/    # k8s manifests, Helm charts, Istio configs
/iac/            # terraform modules & environment tf files
README.md
azure-pipeline.yaml (expected at repo root for Azure DevOps CI/CD)

````

> The repo is structured to keep infra (IaC) separate from app code and k8s manifests. Keep binaries and provider plugins out of source control.

---

## Prerequisites
- A resource group and Storage account to store the `tfstate file`. 
- Azure subscription (owner/contributor access to create resources)  
- Azure DevOps organization (or CI provider of your choice)  
- Service principal or Managed Identity and a service connection from Azure DevOps → Azure  
- Terraform (>= 1.4 recommended) installed locally on your runner/agent  
- Azure CLI (az) installed and authenticated  
- Docker (to build/push images)  
- kubectl and Helm (for AKS deployments)  
- `git` command-line (and `git-lfs` if you intend to store big files)  

---

## Quickstart — local dev & infra bootstrap

### 1. Clone repo
```bash
git clone https://<github>PlatformAsProduct.git
cd PlatformAsProduct
````

### 2. Protect repo from committing local terraform state / providers

Create/update `.gitignore` at repo root:

```
.terraform/
*.tfstate
*.tfstate.*
.terraform.lock.hcl
```

### 3. Recommended: create a remote backend (Azure Storage) for terraform state

Create a resource group and storage account manually or with a small terraform script. Example:

```bash
az group create -n myInfraRG -l uaenorth
az storage account create -n mystatestorage123 -g myInfraRG --sku Standard_LRS
az storage container create -n tfstate --account-name mystatestorage123
```

Then use a `backend "azurerm"` block in your `terrafrom` configuration (see `iac/`).

### 4. Change all the variables in `variables.tf file and terraform.auto.tfvars` and make necessary changes in environment file `\iac\env\sandbox\main.tf` and  `\iac\env\sandbox\providers.tf` according to the environment. 
---

## Terraform (iac) — usage & best practice

### Initialize & plan for an environment (example: sandbox)

```bash

**Notes:**

* Keep provider versions pinned in `.terraform.lock.hcl`.
* Do **NOT** commit `.terraform/` or provider binaries, If you're running terraform commands from local machine. Terraform providers will be downloaded locally by `terraform init`.
cd iac/env/sandbox
# create or export backend variables needed (ARM_SUBSCRIPTION_ID, etc.)
terraform init
terraform validate
terraform plan -var-file="sandbox.tfvars"
# when ready
terraform apply -var-file="sandbox.tfvars"
---

## Build & push Docker images

1. Build (example: Node app)

```bash
cd apps/my-app
docker build -t <acr_repo> .
docker tag
```

2. Push to registry

```bash
docker login
docker push <acr_repo>:latest
```

Use a private container registry (ACR) for production. In Azure, `az acr login --name <acrName>`.

---

## AKS & deployments (apps/ and deployments/)

* Create AKS during terraform apply or separately. Ensure node pools, network, subnet rules match Application Gateway design.
* Deploy apps using Helm or kubectl manifests from `deployments/`:

```bash
kubectl apply -f deployments/namespace.yaml
kubectl apply -f deployments/istio-gateway.yaml
kubectl apply -f deployments/<your-app>-deployment.yaml
```

* Use Istio for internal routing. Keep the Istio ingress gateway **internal** (private) and front it with Application Gateway (regional public L7).

---

## Traffic Manager → Application Gateway (region failover) — practical notes <a name="tm-agw"></a>

**Important rules** (based on your architecture needs):

* Azure Traffic Manager is **DNS-based**; it **returns a public endpoint** (FQDN). TM cannot return private IPs or point clients to internal-only endpoints. See Azure docs for details. ([Microsoft Learn][1])
* Traffic Manager should reference the **public FQDN** of your regional Application Gateway(s) (e.g. `agw-eastus-01.cloudapp.azure.com`).
* Cloudflare must be configured carefully:

  * If you CNAME your domain to the Traffic Manager profile, **do not enable Cloudflare proxy (orange-cloud)** on that CNAME; use DNS-only (grey-cloud) for TM CNAME, otherwise Cloudflare edge will bypass TM DNS decisions.
* Health probes:

  * Configure Traffic Manager health check path to a **stable 200 OK** path on Application Gateway (or behind it) so TM accurately sees health. Avoid probe paths that return redirects or 302.
* If you want to remove public App Gateway later, replacing it with Azure Front Door (with Private Link) is the supported approach; do not expose Istio directly to public internet.

**Useful reading:** Azure Traffic Manager + Application Gateway docs. ([Microsoft Learn][1])

---

## CI/CD — Azure DevOps pipeline notes

Place a pipeline file at repo root (e.g., `azure-pipeline.yaml`) and configure these stages:

1. **Lint / build** apps (maven/npm)
2. **Docker build** + push to registry (ACR/DockerHub)
3. **Terraform plan** (in PR) — run `terraform init/plan` in iac folder
4. **Terraform apply** (protected; run on main or specific branches, via service principal)
5. **Kubernetes deploy** — run `kubectl/helm` commands or use `kubectl apply` tasks

**Runner/agent requirements**

* Runners must have terraform, az cli, docker, kubectl, helm installed (or install it during the job).

---

## Common issues & fixes (you hit the big one)

### A. Large file >100MB rejected by GitHub when pushing

You already saw this error about `terraform-provider-azurerm_v4.30.0_x5.exe` >100MB. GitHub rejects files >100MB. The fix is **remove the file from git history**, add `.terraform/` to `.gitignore`, and push cleaned history. For large binary management, consider Git LFS. ([GitHub Docs][2])

**Fast, recommended cleanup (use `git-filter-repo`):**

> *Back up your local branches first — rewriting history is destructive.*

```bash
# 1. Make a backup branch of your current main
git checkout main
git branch backup-main-local

# 2. Install git-filter-repo (if not installed)
pip install git-filter-repo

# 3. Remove the .terraform directory and all its files from history
git filter-repo --path .terraform --invert-paths

# 4. Add .terraform to .gitignore
echo ".terraform/" >> .gitignore
git add .gitignore
git commit -m "Add .terraform to gitignore"

# 5. Force-push cleaned history to origin (only if you understand implications)
git push origin --force --all
git push origin --force --tags
```

`git-filter-repo` is the recommended tool for rewriting history. If you cannot install it, you can use the older `git filter-branch` commands (slower, more error-prone). ([GitHub][3])

**Alternative: Git LFS**
If you actually need large files in the repo, use Git LFS and follow GitHub LFS docs to track filetypes, but avoid shipping provider binaries into source control. ([Git Large File Storage][4])

### B. "refusing to merge unrelated histories" or non-fast-forward

If someone force-pushed and your local history diverges, follow the backup-and-reset approach:

```bash
git branch backup-main-local
git fetch origin
git reset --hard origin/main
# look at backup branch commits and cherry-pick what you need
```

---
### C. Connection reset while applying terraform apply
* You will see the connection reset while applying `terraform apply`.
 To resolve just re-run the terraform init/plan/apply 
## Security & secrets

* Never commit `.tfvars` with secrets, nor Kubernetes secret manifests with plain keys.
* Use Azure Key Vault or pipeline variables for secrets. Use `az keyvault` or managed identity to inject secrets at runtime.

---

## Recommended workflows & notes (practical)

* Keep `iac/` modules DRY: modules for networking, aks, appgw, keyvault. Keep env-specific tfvars under `iac/env/<env>/`.
* Keep manifests templated (Helm/ Kustomize) and render per environment during deployment.
* Keep the Application Gateway rules minimal: let Istio handle service-level routing. AGW should terminate TLS, apply WAF policies, and forward to internal Istio ingress.
* Health probe path for TM should be a simple `/healthz` or `/_status` route that App Gateway forwards to an always-available backend.

---

## Useful commands snapshot

```bash
# terraform
cd iac/env/sandbox
terraform init
terraform plan -out plan.out
terraform apply plan.out

# docker (change the ACR repo and apply the tags)
cd apps/my-app
docker build -t mydockerhubuser/myapp:tag .
docker push mydockerhubuser/myapp:tag

# kubernetes
kubectl apply -f deployments/namespace.yaml
kubectl apply -f deployments/my-app-deployment.yaml

# git filter-repo example (remove a path)
git filter-repo --path .terraform --invert-paths
```

---

## References

* This repository: `https://github.com/<user>/PlatformAsProduct`. ([GitHub][5])
* Git LFS docs — managing large files and Git LFS setup. ([GitHub Docs][6])
* `git-filter-repo` (recommended) for rewriting history. ([GitHub][3])
* Azure Traffic Manager docs (DNS-based global traffic routing). ([Microsoft Learn][1])
* Azure Application Gateway docs (Layer-7 entry, WAF). ([Microsoft Learn][7])

---

## Final notes
* **Do not commit .terraform, provider binaries or .tfstate files** — they do not belong in Git.
* All the pipeline code is available on each directory. You can simply use the predefined pipelines to do all the automation jobs

---
