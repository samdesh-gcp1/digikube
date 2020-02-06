# private

1. Clone the Digikube repository
2. Login to GCP console
3. Create new project
4. Start Google Cloud Shell.  If the shell does not start in the newly created project then switch to the newly created project.
5. Execute the following command to deploy Digikube on GCE
  
      #Replace the repo url by the repo you have created (by cloning digikube)

      digikube_code_repo="https://raw.githubusercontent.com/samdesh-gcp1/digikube/master";	
      digikube_config_file="https://raw.githubusercontent.com/samdesh-gcp1/digikube/master/config/templates/digikube-base-config-template.yaml";	
      bootstrap_shell="/tmp/digikube-${RANDOM}";
      wget -q --no-cache -O ${bootstrap_shell} - "${digikube_code_repo}/cloud-init/bootstrap";		
      chmod +x ${bootstrap_shell};								
      ${bootstrap_shell} ${digikube_code_repo} ${digikube_config_file} create
  
  
6. Execute the following command to delete Digikube on GCE

      #Replace the repo url by the repo you have created (by cloning digikube)
      
      digikube_code_repo="https://raw.githubusercontent.com/samdesh-gcp1/digikube/master";
      digikube_config_file="https://raw.githubusercontent.com/samdesh-gcp1/digikube/master/config/templates/digikube-base-config-template.yaml";	
      bootstrap_shell="/tmp/digikube-${RANDOM}";
      wget -q --no-cache -O ${bootstrap_shell} - "${digikube_code_repo}/cloud-init/bootstrap";
      chmod +x ${bootstrap_shell};
      . ${bootstrap_shell} ${digikube_code_repo} ${digikube_config_file} delete 
