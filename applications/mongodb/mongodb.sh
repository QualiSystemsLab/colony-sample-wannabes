#!/bin/bash
apt update -y
apt upgrade -y
echo 'Install MongoDB'
apt install -y mongodb
echo 'Change mongoDB Listening IP Address from local 127.0.0.1 to All IPs 0.0.0.0'
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongodb.conf

echo 'Start the mongo service'
systemctl restart mongodb
<< EOF
echo 'Enable automatically starting MongoDB when the system starts.'
systemctl enable mongodb
echo 'Extracting user data db artifact'
mkdir $ARTIFACTS_PATH/drop
tar -xvf $ARTIFACTS_PATH/*.* -C $ARTIFACTS_PATH/drop/

echo 'Waiting for db to be ready'
sleep 30

echo 'Import all collections from artifact'
cd $ARTIFACTS_PATH/drop
for f in ./*.json; do
	temp_var="${f%.*}"
	collection="${temp_var:2}"
	mongoimport --db promo-manager --collection $collection --file $ARTIFACTS_PATH/drop/$f
done

EOF
