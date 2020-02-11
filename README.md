# private

1. Clone the digikube-instance repository: https://github.com/samdesh-gcp1/c1-dev1.git
2. Edit the configurations as per your requirements
3. Login to GCP console
4  (If not done already) create master project 'digikube-base' to hold master data across clusters
		4.a. Secrets: Github.com access token
		4.b. Master bucket
		4.c. Master private image registry	
5. Execute the following command for creating the Digikube cluster invironment
		5.a. Create new project
		5.b. Create cluster
		
		

4. Start Google Cloud Shell.  If the shell does not start in the newly created project then switch to the newly created project.
5. Execute the following command to deploy Digikube on GCE
  
      #Replace the repo url by the repo you have created (by cloning digikube)
      
read -p "Please enter digikube-core repo access token: " digikubeCoreRepoAccessToken; digikubeCodeRawRepoUrl="https://raw.githubusercontent.com/samdesh-gcp1/digikube/master"; digikubeInstanceRawRepoUrl="https://raw.githubusercontent.com/samdesh-gcp1/c1-dev1/master"; tmpExecDir=$(mktemp -d --suffix="-digikube"); bootstrapShell="${tmpExecDir}/bootstrap"; wget -q --no-cache --header="Authorization: Bearer  ${digikubeCoreRepoAccessToken}" -O ${bootstrapShell} - "${digikubeCodeRawRepoUrl}/cloud-init/bootstrap"; chmod +x ${bootstrapShell}; ${bootstrapShell} ${digikubeCodeRawRepoUrl} ${digikubeInstanceRawRepoUrl} create; rm -rf "${tmpExecDir}"
  
  
6. Execute the following command to delete Digikube on GCE

      #Replace the repo url by the repo you have created (by cloning digikube)
      
digikubeCodeRawRepoUrl="https://raw.githubusercontent.com/samdesh-gcp1/digikube/master"; digikubeInstanceRawRepoUrl="https://raw.githubusercontent.com/samdesh-gcp1/c1-dev1/master"; tmpExecDir=$(mktemp -d --suffix="-digikube"); bootstrapShell="${tmpExecDir}/bootstrap"; wget -q --no-cache -O ${bootstrapShell} - "${digikubeCodeRawRepoUrl}/cloud-init/bootstrap"; chmod +x ${bootstrapShell}; ${bootstrapShell} ${digikubeCodeRawRepoUrl} ${digikubeInstanceRawRepoUrl} delete --forced; rm -rf "${tmpExecDir}" 

wget --no-cache --header="Authorization: Bearer $(gcloud beta secrets versions access latest --secret='access-token' --project='dkube1')" - "https://raw.githubus
ercontent.com/samdesh-gcp1/digikube/master/README.md"
