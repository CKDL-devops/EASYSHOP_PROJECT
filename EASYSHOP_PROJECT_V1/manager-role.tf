data "aws_caller_identity" "current" {}


resource "aws_iam_role" "ADMIN" {
  name = "${local.env}-${local.eks_name}-ADMIN"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
         AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" 
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_policy" "ADMIN" {
  name        = "AmazonEKSAdminPolicy"
  description = "My admin policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
 
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "eks:*"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:PassedToService": "eks.amazonaws.com"
                }
            }
        }
    ]
}
POLICY
}



resource "aws_iam_role_policy_attachment" "ADMIN-ROLE-BINDING" {
  policy_arn = aws_iam_policy.ADMIN.arn
  role       = aws_iam_role.ADMIN.name
}



resource "aws_iam_user" "devops" {
  name = "ADMIN"

}
resource "aws_iam_policy" "eks_assume_admin" {
  name = "AmazonEKSAssumeAdminPolicy"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Resource": "${aws_iam_role.ADMIN.arn}"
        }
    ]
}
POLICY
}

resource "aws_iam_user_policy_attachment" "ADMIN" {
  policy_arn = aws_iam_policy.ADMIN.arn
  user      = aws_iam_user.devops.name
}

# Best practice: use IAM roles due to temporary credentials
resource "aws_eks_access_entry" "ADMIN" {
  cluster_name      = aws_eks_cluster.EKS.name
  principal_arn     = aws_iam_user.devops.arn
  kubernetes_groups = ["devops-admin"]

}




# data "aws_caller_identity" "current" {}

# resource "aws_iam_role" "eks_admin" {
#   name = "${local.env}-${local.eks_name}-eks-admin"

#   assume_role_policy = <<POLICY
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Action": "sts:AssumeRole",
#       "Principal": {
#         "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
#       }
#     }
#   ]
# }
# POLICY
# }

# resource "aws_iam_policy" "eks_admin" {
#   name = "AmazonEKSAdminPolicya"

#   policy = <<POLICY
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Action": [
#                 "eks:*"
#             ],
#             "Resource": "*"
#         },
#         {
#             "Effect": "Allow",
#             "Action": "iam:PassRole",
#             "Resource": "*",
#             "Condition": {
#                 "StringEquals": {
#                     "iam:PassedToService": "eks.amazonaws.com"
#                 }
#             }
#         }
#     ]
# }
# POLICY
# }

# resource "aws_iam_role_policy_attachment" "eks_admin" {
#   role       = aws_iam_role.eks_admin.name
#   policy_arn = aws_iam_policy.eks_admin.arn
# }

# resource "aws_iam_user" "devops" {
#   name = "ADMIN"
# }

# resource "aws_iam_policy" "eks_assume_admin" {
#   name = "AmazonEKSAssumeAdminPolicya"

#   policy = <<POLICY
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Action": [
#                 "sts:AssumeRole"
#             ],
#             "Resource": "${aws_iam_role.eks_admin.arn}"
#         }
#     ]
# }
# POLICY
# }

# resource "aws_iam_user_policy_attachment" "manager" {
#   user       = aws_iam_user.devops.name
#   policy_arn = aws_iam_policy.eks_assume_admin.arn
# }

# # Best practice: use IAM roles due to temporary credentials
# resource "aws_eks_access_entry" "manager" {
#   cluster_name      = aws_eks_cluster.EKS.name
#   principal_arn     = aws_iam_role.eks_admin.arn
#   kubernetes_groups = ["devops-admin"]
# }