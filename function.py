from __future__ import print_function
import json
import boto3
import time
import urllib
print('Loading function')

s3 = boto3.client('s3')

def lambda_handler(event, context):
    source_bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.unquote_plus(event['Records'][0]['s3']['object']['key'])
    target_bucket = context.function_name
    copy_source = {'Bucket':mysourcebucketraj, 'Key':}
    
    try:
        print("Using waiter to waiting for object to persist thru s3 service")
        waiter = s3.get_waiter('object_exists')
        waiter.wait(Bucket=source_bucket, Key=key)
        
        print ("Copying object from Source S3 bucket to Traget S3 bucket ")
        s3.copy_object(Bucket=mydestinationbucketraj, Key=key, CopySource=copy_source)
        
    except Exception as e:
        print(e)
        print('Error getting object {} from bucket {}. Make sure they exist '
              'and your bucket is in the same region as this '
              'function.'.format(key, source_bucket))
        raise e
		