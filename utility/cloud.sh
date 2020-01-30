


function get-cloud-project {

if [[ "$1" == "gce" ]]; then
    #echo "$(who am i)"
    
    echo "$(/snap/bin/gcloud info |tr -d '[]' | awk '/project:/ {print $2}')"
fi

}
