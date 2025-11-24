resource "aws_iam_role" "os_test_role" {
  name               = "os-test-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "os_test_policy" {
  name   = "os-test-policy"
  policy = data.aws_iam_policy_document.os_test_s3_permissions.json
}

resource "aws_iam_policy_attachment" "os_test_policy_attachment" {
  name       = "os-test-policy-attachment"
  roles      = [aws_iam_role.os_test_role.name]
  policy_arn = aws_iam_policy.os_test_policy.arn
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type = "Federated"
      identifiers = [
        data.aws_iam_openid_connect_provider.os_idp.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "${data.aws_eks_cluster.os_eks_cluster.identity[0].oidc[0].issuer}:aud"
      values   = ["sts:amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${data.aws_eks_cluster.os_eks_cluster.identity[0].oidc[0].issuer}:sub"
      values   = ["system:serviceaccount:${var.os_eks_namespace}:${var.os_eks_service_account}"]
    }
  }
}

data "aws_iam_policy_document" "os_test_s3_permissions" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.os_test.arn,
      "${aws_s3_bucket.os_test.arn}:/*"
    ]
  }
}