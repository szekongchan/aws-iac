data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
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
