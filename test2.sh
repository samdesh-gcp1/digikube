echo "Hi $1"

echo "    +++++++++++++++++++++++++++++++ "
wget -q --no-cache -O - "$1/test.sh" | bash
