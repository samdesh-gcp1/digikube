


function get-cloud-project {

if [[ "$1" = "gce" ]]; then
    echo "$(gcloud info |tr -d '[]' | awk '/project:/ {print $2}')"
fi

}
