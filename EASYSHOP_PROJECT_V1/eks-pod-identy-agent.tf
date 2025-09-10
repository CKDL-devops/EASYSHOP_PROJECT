resource "aws_eks_addon" "pod_identy" {
  cluster_name                = aws_eks_cluster.EKS.name
  addon_name                  = "pod_identity"
  addon_version               = "v1.2.0-eksbuild.1" #e.g., previous version v1.9.3-eksbuild.3 and the new version is v1.10.1-eksbuild.1
}