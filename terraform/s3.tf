resource "aws_s3_bucket" "os_test" {
  bucket = "os-test-24112025"

  tags = {
    Name = "OS test bucket"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "os_test" {
  bucket = aws_s3_bucket.os_test.bucket

  rule {
    bucket_key_enabled = false
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

data "aws_iam_policy_document" "os_test" {
  statement {
    sid    = "AllowSSLrequestsOnly"
    effect = "Deny"

    actions = [
      "s3:*"
    ]

    resources = [
      aws_s3_bucket.os_test.arn,
      "${aws_s3_bucket.os_test.arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "os_test" {
  bucket = aws_s3_bucket.os_test.id
  policy = data.aws_iam_policy_document.os_test.json
}

resource "aws_s3_bucket_lifecycle_configuration" "os_test" {
  bucket = aws_s3_bucket.os_test.bucket

  rule {
    id     = "Expire files after 7 days"
    status = "Enabled"

    expiration {
      days = 7
    }
  }
}
