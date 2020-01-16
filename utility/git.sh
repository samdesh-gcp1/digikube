
function mark-x {
   local file_name="${1}"
   chmod +x "${file_name}"
}

function commit {
   local comment="${1}"
   git commit -a -m "${comment}"
}

function checkout {
   git checkout
}

function push {
   git push
}

function identity {
   git config --global user.email "samdesh.gcp1@gmail.com"
   git config --global user.name "samdesh_gcp1"
}

__operation="${1}"
__file_name="${2}"
__comment="${3}"

if [[ "${__operation}" = "mark-x-commit" ]]; then
   cd ~/digikube/
   checkout
   mark-x "${__file_name}"
   identity
   commit "${__comment}"
   push
fi
