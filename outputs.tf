output "s3 source bucket arn" {
  value = "${aws_s3_bucket.s3_source_bucket.arn}"
}

output "s3 destination bucket arn" {
  value = "${aws_s3_bucket.s3_destination_bucket.arn}"
}

output "s3 logs bucket arn" {
  value = "${aws_s3_bucket.logs_bucket.arn}"
}

output "Lambda arn" {
  value = "${aws_lambda_function.test_lambda.arn}"
}
