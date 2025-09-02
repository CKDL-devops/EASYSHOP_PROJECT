resource "aws_iam_user" "viewer" {
  name = "viewer"

}

resource "aws_iam_policy" "viewer" {
  name        = "viewer"
  description = "My viewer policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "eks:DescribeCluster",
          "eks:listCluster"
        ]
        Effect = "Allow"
        #the below command is to iddentify all the clusters in eks
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_user_policy_attachment" "VIEWER" {
  policy_arn = aws_iam_policy.viewer.arn
  user       = aws_iam_user.viewer.name
}
resource "aws_eks_access_entry" "viewer" {
  cluster_name      = aws_eks_cluster.EKS.name
  principal_arn     = aws_iam_user.viewer.arn
  kubernetes_groups = ["viewer"]

}
