provider "aws" {
  region = var.region
}

module "s3" {
  source = "../../"

  bucket_name = var.bucket_name
  acl         = "private"

  versioning = {
    enabled = true
  }

  lifecycle_rule = [
    {
      rule_name = "transition-rule"
      enabled   = true

      transition = [
        {
          days          = 90
          storage_class = "STANDARD_IA"
        },
        {
          days          = 360
          storage_class = "GLACIER"
        }
      ]
    },
    {
      rule_name = "expiration-rule"
      enabled   = true

      noncurrent_version_expiration = {
        days = 90
      }
    }
  ]

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowSourceIP",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:List*",
      "Resource": "arn:aws:s3:::${var.bucket_name}/*",
      "Condition": {
        "IpAddress": {
          "aws:SourceIp": [
            "187.32.22.45/32"
          ]
        }
      }
    }
  ]
}
EOF

  tags = {
    Project = var.bucket_name
  }
}