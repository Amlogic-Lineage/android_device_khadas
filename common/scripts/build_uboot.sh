cd $1
echo $3
export PATH=$2:$PATH &&
./mk $3
cd -
