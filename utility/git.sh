
function mark-x {
   git update-index --chmod=+x file.sh
   git ls-tree HEAD
}

function commit {
   git commit
}

function checkout {
   git checkout
}

function push {
   git push
}

if [[ "$1" = "mark-x-commit" ]]; then
   checkout
   mark-x $2
   commit
   push  
fi

