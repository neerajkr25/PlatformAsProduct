# Attach ACR to AKS so node pool's identity can pull images
az aks update -g rg-erdc-poc-k8s -n erdc-k8s-cluster --attach-acr erdcuaenpocimages


