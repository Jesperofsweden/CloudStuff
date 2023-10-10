#/bin/bash
trap exit INT
INSTANCES=$( aws --profile=%YOURPROFILEGOESHERE% ec2 describe-instances --query 'Reservations[].Instances[].InstanceId[]' | sed -e 's/\[//g' -e 's/\]//g')
SUM=0
echo $INSTANCES
for i in $( echo $INSTANCES | sed -e 's/"//g' -e 's/,//g' -e 's/\[//g' -e 's/\]//g' ) ;do
	echo "---------------------------$i-------------------------------\n"
	 aws --profile=%YOURPROFILEGOESHERE% ec2 describe-instances --instance-ids $i --query 'Reservations[].Instances[].Tags[?Key==`Name`].Value' --output text 
	 aws --profile=%YOURPROFILEGOESHERE% ec2 describe-instance-attribute --instance-id $( echo $i |  sed -e 's/"//g'  -e 's/,//' -e 's/\[//g' -e 's/\]//g' ) --attribute userData \
	 	| jq '.UserData.Value' | sed 's/"//g' |  base64 --decode
	((SUM += 1))
	echo "\n"
done
echo "Total Number of Servers: $SUM"