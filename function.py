import boto3
def sample(event, context):
    client = boto3.client('s3','us-east-1')
    s3 = boto3.resource('s3','us-east-1')
    last_modified = []
    bucket_keys = []
    response = client.list_objects(
    Bucket='mysourcebucketraj')
    for res in response['Contents']:
        last_modified.append(res['LastModified'])
        bucket_keys.append(res['Key'])
    latest = max(last_modified)
    latest_key = last_modified.index(latest)
    new_file = bucket_keys[latest_key]
    
    copy_source = {
    'Bucket': 'mysourcebucketraj',
    'Key': new_file
    }
    s3.meta.client.copy(copy_source, 'mydestinationbucketraj', new_file)