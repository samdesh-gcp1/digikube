


function get-cloud-project {

if [[ "$1" = "gce" ]]; then
    return "$(gcloud info |tr -d '[]' | awk '/project:/ {print $2}')"
fi

}
