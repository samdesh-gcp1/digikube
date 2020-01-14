
function mark-x {  chmod +x "$1" }

function commit { git commit -m "$1" }

function checkout { git checkout }

function push { git push }

function identity {
   git config --global user.email "samdesh.gcp1@gmail.com"
   git config --global user.name "samdesh_gcp1"
}

if [[ "$1" = "mark-x-commit" ]]; then
   cd ~/digikube/
   checkout
   mark-x "$2"
   identity
   commit "$3"
   push
fi
