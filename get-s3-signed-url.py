#!/usr/bin/env python
# Latest copy of this will be found at https://gist.github.com/joech4n/3c2e79b440655e77f692

import argparse
import boto
import sys

parser = argparse.ArgumentParser(description='Generate an S3 signed URL')
parser.add_argument('bucket', help='bucket name')
parser.add_argument('key', help='prefix/key')
parser.add_argument('seconds', type=int, help='time in seconds until the URL will expire')
parser.add_argument('-4', '--sigv4', action='store_true', help='use sigv4')
args = parser.parse_args()

def getS3Connection():
  if args.sigv4:
    init = boto.connect_s3() # initial connection to get bucket region (required to set host parameter below)
    region = init.get_bucket(args.bucket).get_location()
    if region:
      host = 's3-' + region + '.amazonaws.com'
    else:
      host = 's3.amazonaws.com'

    if not boto.config.get('s3', 'use-sigv4'): # shamelessly taken from http://stackoverflow.com/q/27400105/908640
        boto.config.add_section('s3')
        boto.config.set('s3', 'use-sigv4', 'True')
    return boto.connect_s3(host=host)       # host required for Sigv4 per http://stackoverflow.com/a/26748746/908640
  else:
    return boto.connect_s3()

s3 = getS3Connection()
bucket = s3.get_bucket(args.bucket)
key = bucket.get_key(args.key)
if not bucket.get_key(args.key):
  sys.exit('ERROR: s3://' + args.bucket + '/' + args.key + ' does not exist')

if args.sigv4:
  print 'Signed URL (Sigv4): ' + key.generate_url(args.seconds)
else: # regular Sigv2 signed URL
  print 'Signed URL (Sigv2): ' + key.generate_url(args.seconds)
