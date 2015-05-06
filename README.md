This is just a little test to play around with SQS, SNS, S3, Cloudwatch and EC2. These scripts allow for a torrent box to only be running when there are torrents to download in the queue

To set this up you'll need a VPC with internet access, a security group with torrent ports open, an SNS topic, a SQS queue.

You'll also need to configure Cloudwatch alerts to check for items in the queue to add an instance and for it to remove an instance when the user defined cloudwatch for transmission count is 0

Naturally this will require configuring an autoscaling group and profile.

This is intended to only scale up to 1 node for my purposes. Code would require changing to limit the number of torrents per box.


Warning
==
This is a dirty hack. It's not intended for production, just as a project. It's not cost effective to use this. It's also bad for the community as you never end up seeding data.
