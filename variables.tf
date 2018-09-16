variable "region" {
  description = "Please Specify The Region"
}

variable "access_key" {
  description = "Please Provide Access Key"
}

variable "secret_key" {
  description = "Please Provide Secret Key"
}

variable "source_bucket_s3" {
  default = "mysourcebucketraj"
}

variable "destination_bucket_s3" {
  default = "mydestinationbucketraj"
}

variable "logs_bucket_s3" {
  default = "mylogsbucketraj"
}
