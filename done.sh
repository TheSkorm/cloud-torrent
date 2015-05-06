#!/bin/bash
export BUCKET=mwheeler-pirate
export TOPIC=arn:aws:sns:ap-southeast-2:082208999166:Pirate
export REGION=ap-southeast-2
export FILE="`ls`"
zip -r "$FILE.zip" .
aws s3 cp "$FILE.zip" s3://$BUCKET/
export FILELINK=`/root/get-s3-signed-url.py $BUCKET "$FILE.zip" 259200`
aws configure set region $REGION
aws sns publish --topic-arn $TOPIC --message "Download ready at $FILELINK"

