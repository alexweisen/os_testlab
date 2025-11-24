data "aws_eks_cluster" "os_eks_cluster" {
  name = "os-eks-cluster-name"
}

data "aws_iam_openid_connect_provider" "os_idp" {
  url = data.aws_eks_cluster.os_eks_cluster.identity[0].oidc[0].issuer
}
