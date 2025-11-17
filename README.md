Prerequesites :- 
1- storage Account for terraform state file as backend
2- Azure DevOps Subscription
3- Setup Service Connection between azure and Azure DevOps and complete the authentication
4- Runner Setup (agents to run the job)
5- After runner setup, Install required tools in it like, Terraform, Build tools like, maven, MS-build, Azure CLI etc. it will use those tools to run your .YAML stages. 

===================================================================================
Terrafrorm 
-----------
Once Agent is ready you can start building the IaC pipeline. Here we are using the Azure DevOps CI-CD.
1- create azure-pipeline.yaml in root repo which can run terraform init, validate, plan and Apply in azure
2- Write IaC tf files with modules for DRY and make the separate environment
3- Create Initial setup like Vnet, 2 subnets and than launch K8s cluster
4- Create NodeJs application and than create Dockerfile and build image
5- Push docker container image to dockerhub docker image registry
