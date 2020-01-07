

DEST_FILE_PATH="/tmp/"
DEST_FILE_NAME=""

if [ $# -lt 1 ]; then
   echo "No file specified for download."
   exit 1
else
   SOURCE_URL=$1   #should check the format
   DEST_FILE_NAME="${DEST_FILE_PATH}digikube-${RANDOM}"
   wget -q --no-cache -O $DEST_FILE_NAME - $SOURCE_URL
fi
