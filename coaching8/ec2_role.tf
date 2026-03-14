resource "aws_iam_role" "ec2-role" {
  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

# WARM UP Policy with EC2 Describe and S3 List permissions
locals {
  ec2_role_policy_arn_by_option = {
    option1 = aws_iam_policy.policy_option1.arn
    option2 = aws_iam_policy.policy_option2.arn
    option3 = aws_iam_policy.policy_option3.arn
  }
}

data "aws_iam_policy_document" "policy_option1_doc" {
  statement {
    effect    = "Allow"
    actions   = ["ec2:Describe*"]
    resources = ["*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["s3:ListAllMyBuckets"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "policy_option1" {
  name = "${var.project_name}-policy-option1"

  ## Option 1: Attach data block policy document
  policy = data.aws_iam_policy_document.policy_option1_doc.json
}

resource "aws_iam_policy" "policy_option2" {
  name = "${var.project_name}-policy-option2"

  ## Option 2: Inline using jsonencode
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["ec2:Describe*"]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = ["s3:ListAllMyBuckets"]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_policy" "policy_option3" {
  name = "${var.project_name}-policy-option3"

  ## Option 3: Inline using heredoc
  policy = <<POLICY
   {
       "Statement": [
           {
               "Action": "ec2:Describe*",
               "Effect": "Allow",
               "Resource": "*"
           },
           {
               "Action": "s3:ListAllMyBuckets",
               "Effect": "Allow",
               "Resource": "*"
           }
       ],
       "Version": "2012-10-17"
   }
   POLICY
}

resource "aws_iam_role_policy_attachment" "attach_ec2_role" {
  role       = aws_iam_role.ec2-role.name
  policy_arn = local.ec2_role_policy_arn_by_option[var.ec2_role_policy_option]
}

resource "aws_iam_instance_profile" "profile_ec2" {
  name = "${var.project_name}-profile-ec2"
  role = aws_iam_role.ec2-role.name
}

# ACTIVITY 1 Policy for DynamoDB access
data "aws_iam_policy_document" "dynamodb_policy_doc" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:DescribeImport",
      "dynamodb:ListTables",
      "dynamodb:DescribeContributorInsights",
      "dynamodb:ListTagsOfResource",
      "dynamodb:GetAbacStatus",
      "dynamodb:DescribeReservedCapacityOfferings",
      "dynamodb:PartiQLSelect",
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:DescribeContinuousBackups",
      "dynamodb:DescribeExport",
      "dynamodb:ListImports",
      "dynamodb:GetResourcePolicy",
      "dynamodb:DescribeKinesisStreamingDestination",
      "dynamodb:ListExports",
      "dynamodb:DescribeLimits",
      "dynamodb:BatchGetItem",
      "dynamodb:ReadDataForReplication",
      "dynamodb:ConditionCheckItem",
      "dynamodb:ListBackups",
      "dynamodb:Scan",
      "dynamodb:Query",
      "dynamodb:DescribeStream",
      "dynamodb:DescribeTimeToLive",
      "dynamodb:ListStreams",
      "dynamodb:ListContributorInsights",
      "dynamodb:DescribeGlobalTableSettings",
      "dynamodb:ListGlobalTables",
      "dynamodb:GetShardIterator",
      "dynamodb:DescribeGlobalTable",
      "dynamodb:DescribeReservedCapacity",
      "dynamodb:DescribeBackup",
      "dynamodb:DescribeEndpoints",
      "dynamodb:GetRecords",
      "dynamodb:DescribeTableReplicaAutoScaling"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "dynamodb_policy" {
  name   = "${var.project_name}-dynamodb-policy"
  policy = data.aws_iam_policy_document.dynamodb_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "attach_dynamodb" {
  role       = aws_iam_role.ec2-role.name
  policy_arn = aws_iam_policy.dynamodb_policy.arn
}
