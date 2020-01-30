


function get-cloud-project {

if [[ "$1" = "gce" ]]; then
    echo "$(who am i)"
    echo "$(gcloud info |tr -d '[]' | awk '/project:/ {print $2}')"
fi

}
