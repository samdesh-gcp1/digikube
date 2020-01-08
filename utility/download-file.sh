function download_file {
        
   local dest_file_path="/tmp/"
   local dest_file_name=""

   if [ $# -lt 2 ]; then
      echo "Insufficient parameters provided."
      eval $__resultvar="''"
      exit 1
   else
      local source_url=$1   #should check the format
      echo $source_url
      local dest_file_name="${dest_file_path}digikube-${RANDOM}"
      echo $dest_file_name
      echo "wget -q --no-cache -O $dest_file_name - $source_url"
      wget -q --no-cache -O $dest_file_name - $source_url
      echo $?
      if [ $? -eq 0 ]; then
         local  __resultvar=$2
         eval $__resultvar="'$dest_file_name'"
      else
         echo "Error while downloading file. Do something"
         eval $__resultvar="''"
         exit 1
      fi
   fi



   echo "test"
}
