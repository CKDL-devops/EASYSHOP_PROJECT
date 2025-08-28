resource "aws_iam_role" "NODES" {
  name = "${local.env}-${local.eks_name}-WK-NODES"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

# This policy allows Amazon EKS worker nodes to connect to my Amazon  EKS Clusters.
resource "aws_iam_role_policy_attachment" "WK-NODES" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.NODES.name
}

# this is to allow each pods running inside the node to get an ip address (known as secondary ip address)
resource "aws_iam_role_policy_attachment" "WK-NODES-CNI" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.NODES.name
}


# this policy is to allow access to ECR for image pulling 
resource "aws_iam_role_policy_attachment" "WK-NODES-ECR" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.NODES.name
}


resource "aws_eks_node_group" "WK-NODE" {
  cluster_name    = aws_eks_cluster.EKS.name
  node_group_name = "FIRST"
  version         = local.eks_version
  node_role_arn   = aws_iam_role.NODES.arn
  subnet_ids = [aws_subnet.private_zone1.id,
    aws_subnet.private_zone2.id
  ]

  capacity_type  = "SPOT"
  instance_types = ["t3.large"]

  scaling_config {
    desired_size = 1
    max_size     = 10
    min_size     = 0
  }

  update_config {
    max_unavailable = 1
  }
  labels = {
    role = "FIRST"
  }

  depends_on = [
    aws_iam_role_policy_attachment.WK-NODES,
    aws_iam_role_policy_attachment.WK-NODES-CNI,
    aws_iam_role_policy_attachment.WK-NODES-ECR
  ]

  # Optional: Allow external changes without Terraform plan difference 
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }


}