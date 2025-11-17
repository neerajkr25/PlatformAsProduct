# Attach ACR to AKS so node pool's identity can pull images
az aks update -g rg-tip-stg-uaen -n aks-tip-stg-uaen --attach-acr erdcuaenpocimages

# upload image in acr
az acr build --registry acrtipstg001 --image erdc-be-pub:v1 .
