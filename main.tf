provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "aws_s3_bucket" "s3_source_bucket" {
  bucket = "${var.source_bucket_s3}"
  acl    = "private"

  tags {
    Name        = "Source_Bucket"
  }
}
resource "aws_s3_bucket" "s3_destination_bucket" {
  bucket = "${var.destination_bucket_s3}"
  acl    = "private"

  tags {
    Name        = "Destination_Bucket"
  }
}
resource "aws_s3_bucket" "logs_bucket" {
  bucket = "mylogsbucketraj"
  acl    = "private"
  
   policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::mylogsbucketraj"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::mylogsbucketraj/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
  tags {
    Name        = "logs_Bucket"
  }
}
resource "aws_cloudtrail" "s3_cloudtrail" {
  name                          = "terraform_ct"
  s3_bucket_name                = "${aws_s3_bucket.logs_bucket.id}"
  s3_key_prefix                 = "prefix"
  include_global_service_events = false
  event_selector {
    read_write_type = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::S3::Object"
	  values = ["${aws_s3_bucket.s3_source_bucket.arn}/"]
    }
  }
}
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "archive_file" "lambda_zip" {
    type        = "zip"
    source_dir  = "function.py"
    output_path = "function.zip"
}

resource "aws_lambda_function" "test_lambda" {
  filename         = "function.zip"
  function_name    = "function.lambda"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  handler          = "function.sample"
  source_code_hash = "${data.archive_file.lambda_zip.output_base64sha256}"
  runtime          = "python2.7"
}
resource "aws_iam_role_policy" "lambda_policy" {
  name = "test_policy"
  role = "${aws_iam_role.iam_for_lambda.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_cloudwatch_event_rule" "s3" {
  name        = "capture-s3-upload"
  description = "Capture each upload to s3"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.s3"
  ],
  "detail-type": [
    "AWS API Call via CloudTrail"
  ],
  "detail": {
    "eventSource": [
      "s3.amazonaws.com"
    ],
    "eventName": [
      "PutObject"
    ],
    "requestParameters": {
      "bucketName": [
        "${var.source_bucket_s3}"
      ]
    }
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "s3" {
  target_id = "trigger-lambda"
  rule      = "${aws_cloudwatch_event_rule.s3.name}"
  arn       = "${aws_lambda_function.test_lambda.arn}"
}
