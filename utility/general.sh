#All logging to be done to std out.  No log file required.

function download_file {

   local __function_name="download_file"
   local __resultvar=""
   local __exit_code=0

   local source_url
   local dest_file_path="/tmp/"
   local dest_file_name=""
   
   if [ $# -lt 2 ]; then
      echo "Error: ($function_name): Insufficient arguments provided."
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
                echo "Info: ($function_name): Downloaded file: $dest_file_name from: $source_url."
                __resultvar=$2
                eval $__resultvar="'$dest_file_name'"
         else
                echo "Error: ($function_name): Error while downloading file: $dest_file_name from: $source_url.  Unable to access downloaded file."
                eval $__resultvar="''"
                exit 1
         fi
      else
         echo "Error: ($function_name): Error while downloading file: $dest_file_name from: $source_url.  Command wget returned non zero exit code."
         eval $__resultvar="''"
         exit 1
      fi
   fi
}

function parse_yaml {

        local __function_name="parse_yaml"
                
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

function replace_substring {

        local __function_name="replace_substring"
        local __resultvar=""
        
        local f=""
        local t=""
        local s=""
        local n=""
        
        if [[ $# -lt 3 ]]; then
                echo "Error: ($function_name): Insufficient arguments provided."
                eval $__resultvar="''"
                exit 1 
        else
                f=$1
                t=$2
                s=$3
                echo $f
                echo $t
                echo $s
                
                [ "${f%$t*}" != "$f" ] && n="${f%$t*}$s${f#*$t}"
                eval $__resultvar="'$n'"
        fi
}
