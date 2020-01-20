#All logging to be done to std out.  No log file required.

function download_file {

   local __function_name="download_file"
   local __resultvar=""
   local __exit_code=0

   local source_url
   local dest_file_path="/tmp/"
   local dest_file_name=""
   
   if [ $# -lt 2 ]; then
      echo "Error: ${__function_name} : Insufficient arguments provided."
      eval $__resultvar="''"
      exit 1
   else
      source_url=$1                                                     #should check the format
      dest_file_name="${dest_file_path}digikube-${RANDOM}"
      wget -q --no-cache -O $dest_file_name - $source_url
      # Seems that wget is always returning exit code as 4.  Currently ignoring exit code.
      #__exit_code=$?
      __exit_code=0
      if [[ $__exit_code -eq 0 ]]; then
         if [[ -f $dest_file_name ]]; then
                __resultvar=$2
                eval $__resultvar="'$dest_file_name'"
         else
                echo "Error: ${__function_name} : Error while downloading file: $dest_file_name from: $source_url.  Unable to access downloaded file."
                eval $__resultvar="''"
                exit 1
         fi
      else
         echo "Error: ${__function_name}: Error while downloading file: $dest_file_name from: $source_url.  Command wget returned non zero exit code."
         eval $__resultvar="''"
         exit 1
      fi
   fi
}

function unzip_file {
   
   local __function_name="unzip_file"
   local __resultvar=""
   local __exit_code=0

   local source_url
   local dest_file_path="/tmp/"
   local dest_file_name=""
   
   if [ $# -lt 3 ]; then
      echo "Error: ${__function_name} : Insufficient arguments provided."
      eval $__resultvar="''"
      exit 1
   else
      source_file=$1
      unzipped_file_name=$2
      dest_file_name="${dest_file_path}${unzipped_file_name}"
      tar xz --overwrite --file=${source_file}
      __exit_code=$?
      if [[ $__exit_code -eq 0 ]]; then
         if [[ -f $dest_file_name ]]; then
                __resultvar=$3
                eval $__resultvar="'$dest_file_name'"
         else
                echo "Error: ${__function_name} : Error while unzipping file: $dest_file_name from: $source_file.  Unable to access unzipped file."
                eval $__resultvar="''"
                exit 1
         fi
      else
         echo "Error: ${__function_name}: Error while unzipping file: $dest_file_name from: $source_file.  Command tar returned non zero exit code."
         eval $__resultvar="''"
         exit 1
      fi
   fi
   
}

function parse_yaml_temp {
   local __function_name="parse_yaml_temp"
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

function parse_yaml {
      eval $(parse_yaml_temp "$1" "$2")
}

function replace_substring1 {
   
        local __function_name="replace_substring"
         
        if [[ $# -lt 3 ]]; then
                #echo "Error: ${__function_name} : Insufficient arguments provided."
                echo ""
                exit 1 
        else
                f=$1
                #echo $f
                t=$2
                #echo $t
                s=$3
                #echo $s
                [ "${f%$t*}" != "$f" ] && n="${f%$t*}$s${f#*$t}"
                echo $n
                #return "$n"
        fi
}

function replace_substring {
   
        local __function_name="replace_substring"
         
        if [[ $# -lt 3 ]]; then
                #echo "Error: ${__function_name} : Insufficient arguments provided."
                echo ""
                exit 1 
        else
                f=$1
                #echo $f
                t=$2
                #echo $t
                s=$3
                #echo $s
                n=${f//$t/$s}
                echo "$n"
        fi
}
