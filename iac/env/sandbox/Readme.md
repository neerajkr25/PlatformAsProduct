Manual resources creation :-
    1- Resources Group --> to store the tf state file
    2- Storage account --> For tf state file
    3- Create Service Connection for ADO to Subscription --> To create resources with azure pipeline
    4- Add that SA to subscription to authorize the operation from ADO

What we are creating :- 
    1- A resource group 
    2- A Vnet 
    3- AKS private cluster with 2 nodes and custom networking and autoscalling enable feature
    4- ACR and integrating it to the AKS cluster to Pull Images
    5- BastionHost setup
    6- JumpBox VM to connect AKS cluster securly

Post AKS cluster creation instal below tools in jump box :- 
# Update and install prerequisites
sudo apt-get update
sudo apt-get install -y ca-certificates curl apt-transport-https lsb-release gnupg
curl -sL https://packages.microsoft.com/keys/microsoft.asc | \
  gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | \
  sudo tee /etc/apt/sources.list.d/azure-cli.list
sudo apt-get update
sudo apt-get install -y azure-cli
az version

##### Kubectl 
sudo apt-get update
sudo apt-get install -y ca-certificates curl apt-transport-https
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg \
  https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] \
  https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | \
  sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl
kubectl version --client
