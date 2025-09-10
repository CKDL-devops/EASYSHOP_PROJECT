resource "aws_iam_role" "cluster-autoscaler-ROLE" {
  name = "${local.env}-${local.eks_name}-CAS"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = ["sts:AssumeRole","sts:TagSession"]
      Effect = "Allow"
      Principal = {
        Service = "pods.eks.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}


resource "aws_iam_policy" "cluster_autoscaler" {
  name = "${aws_eks_cluster.EKS.name}-cluster-autoscaler"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeScalingActivities",
          "autoscaling:DescribeTags",
          "ec2:DescribeImages",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:GetInstanceTypesFromInstanceRequirements",
          "eks:DescribeNodegroup"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup"
        ]
        Resource = "*"
      },
    ]
  })
}


resource "aws_iam_role_policy_attachment" "cluster-autoscaler-BINDING" {
  policy_arn = aws_iam_policy.cluster_autoscaler.arn
  role       = aws_iam_role.cluster-autoscaler-ROLE.name
}




resource "aws_eks_pod_identity_association" "cluster_autoscaler" {
  cluster_name    = aws_eks_cluster.EKS.name
  namespace       = "kube-system"
  service_account = "cluster-autoscaler"
  role_arn        = aws_iam_role.cluster-autoscaler-ROLE.arn
}



  #DEPLOYING CLUSTER-AUTOSCALER USING HELM
resource "helm_release" "cluster_autoscaler" {
  name = "autoscaler"

  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"
  version    = "9.37.0" 


  set = {
    "rbac.serviceAccount.name"  = "cluster-autoscaler"
    "autoDiscovery.clusterName" = aws_eks_cluster.EKS.name
    "awsRegion"                 = "eu-north-1"
  }

  # # MUST be updated to match your region 
  # set {
  #   name  = "awsRegion"
  #   value = "EU-NORTH-1"
  # }

  depends_on = [helm_release.metrics_server]
}
