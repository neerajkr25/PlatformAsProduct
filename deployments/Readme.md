# this folder is for Deployment manifests

git clone https://neeraj.kumar:8geR1OdhXBWSy8fzvMbQqcrxjbJeS4OzHQKydzD5p32YhwE5vONTJQQJ99BJACAAAAAczGsNAAASAZDO1zIF@dev.azure.com/TII-Platform/CLoud-POC/_git/platform-as-code

# Attach ACR to AKS so node pool's identity can pull images
az aks update -g rg-tip-stg-uaen -n aks-tip-stg-uaen --attach-acr acrtipstg001

# Push images
az acr build --registry acrtipstg001 --image erdc-fe-pub:v1 .
az acr build --registry acrtipstg001 --image erdc-fe-pvt:v1 .

# in order to create Internal Loadbalancer with istio it should have netowrk contributor access
# Replace <SUBSCRIPTION_ID> only if different; the error shows this subscription already.

az role assignment create --assignee-object-id 0cfd8229-5b6b-4db6-a72f-86d95cdc8c2e --role "Network Contributor" --scope "/subscriptions/29aa10e8-4628-4fa5-993c-3f810af1a699/resourceGroups/rg-tip-stg-uaen/providers/Microsoft.Network/virtualNetworks/vnet-tip-stg-uaen/subnets/snet-stg-k8s-system"



# Grant Network Contributor on the subnet (least privilege)
az role assignment create --assignee 0cfd8229-5b6b-4db6-a72f-86d95cdc8c2e --role "Network Contributor" --scope "/subscriptions/29aa10e8-4628-4fa5-993c-3f810af1a699/resourceGroups/rg-tip-stg-uaen/providers/Microsoft.Network/virtualNetworks/vnet-tip-stg-uaen/subnets/snet-stg-k8s-system"

# re-craete the load balancer :- 
kubectl delete svc aks-istio-ingressgateway-internal -n aks-istio-ingress
# watch for recreation (if managed by helm/flux/ASM)
kubectl get svc -n aks-istio-ingress -w

# Attach ACR to AKS so node pool's identity can pull images
az aks update -n aks-tip-stg-uaen -g rg-tip-stg-uaen --attach-acr acrtipstg001


# t-shooting 
404 not found :- 
curl -vk --resolve poc.powerdreams.app:443:20.233.39.107 https://poc.powerdreams.app/ -H "Host: poc.powerdreams.app" || true

curl -vk --connect-timeout 10 https://20.233.39.107/ || true
# and a simple TCP check
nc -vz 20.233.39.107 443 || true


az network application-gateway show -g rg-uaen-temp-stg-tip -n appgw-uaen-stag-temp-tip-01 --query "{name:name,provisioningState:provisioningState,operationalState:operationalState,frontendIpConfigurations:frontendIpConfigurations,frontendPorts:frontendPorts,httpListeners:httpListeners}" -o json


az network application-gateway frontend-ip create --g rg-uaen-temp-stg-tip --gateway-name appgw-uaen-stag-temp-tip-01 --n publicFrontendIp --public-ip-address /subscriptions/c6abd210-bfee-4c3f-bdd8-38ba2e61daf5/resourceGroups/rg-uaen-temp-stg-tip/providers/Microsoft.Network/publicIPAddresses/appgw-uaen-stag-temp-tip-01-pip


### Tools to be install in jumpbox
sudo apt update 
sudo apt install azure-cli -y
sudo snap install kubectl --classic
sudo apt update
sudo apt install -y curl wget tar
K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep tag_name | cut -d '"' -f4)
wget https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz
tar -xvf k9s_Linux_amd64.tar.gz
sudo mv k9s /usr/local/bin/
