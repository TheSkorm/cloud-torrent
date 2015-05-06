#!/bin/bash
export BUCKET=mwheeler-pirate
export TOPIC="arn:aws:sns:ap-southeast-2:082208999166:Pirate"
INSTANCE_ID=`wget -qO- http://169.254.169.254/latest/meta-data/instance-id`
REGION=ap-southeast-2
QUEUE="https://sqs.ap-southeast-2.amazonaws.com/082208999166/pirate"

mkdir /root/download
yum -y install --enablerepo=epel transmission-daemon transmission jq
sysctl net.core.rmem_max=4194304
sysctl net.core.wmem_max=1048576
 
aws s3 cp s3://mwheeler-pirate-bin/done.sh /root/done.sh
aws s3 cp s3://mwheeler-pirate-bin/get-s3-signed-url.py /root/get-s3-signed-url.py
aws s3 cp s3://mwheeler-pirate-bin/processMessage.sh /root/processMessage.sh

chmod +x /root/done.sh
chmod +x /root/get-s3-signed-url.py
chmod +x /root/processMessage.sh
 
mkdir -p /root/.config/transmission/
 
echo "* * * * * aws cloudwatch put-metric-data --metric-name Transmission-Instances --namespace \"Transmission\" --value \`ps -ef | grep -v grep | grep transmission-cli | wc -l\` --region ap-southeast-2" > mycrontab
crontab mycrontab


echo "{
\"peer-limit-global\": 1000,
\"peer-limit-per-torrent\": 1000,
\"ratio-limit\": 0,
\"ratio-limit-enabled\": true,
\"peer-port-random-enabled\": true,
\"peer-port-random-on-start\": true,
\"peer-port-random-low\": 2108,
\"peer-port-random-high\": 2308
}" > /root/.config/transmission/settings.json
 



echo "shutdown -h now" | at now + 12 hours

while true
do
    aws sqs receive-message --region $REGION --queue-url "$QUEUE" --max-number-of-messages 1 --wait-time-seconds 20 > /tmp/awsqueue
    RECIEPT=`cat /tmp/awsqueue | jq -r '.Messages[] | .ReceiptHandle'`
    TORRENT=`cat /tmp/awsqueue | jq -r '.Messages[] | .Body'`
    MD5=`cat /tmp/awsqueue | jq -r '.Messages[] | .MD5OfBody'`
    if [ -n "${TORRENT+1}"  ];
    then
	if [ ! -d "/tmp/$MD5" ]; then
   	  mkdir /tmp/$MD5
          aws sqs delete-message --queue-url "$QUEUE" --receipt-handle "$RECIEPT" --region "$REGION" #deletes old torrent
      	  /root/processMessage.sh "$TORRENT" "/tmp/$MD5" &
	fi
    fi
    TORRENT=
    sleep 60
done


