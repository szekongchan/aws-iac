resource "aws_iam_role" "ec2-role" {
  name = "${var.project_name}-ec2-role"

  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json
}

resource "aws_iam_instance_profile" "profile_ec2" {
  name = "${var.project_name}-profile-ec2"
  role = aws_iam_role.ec2-role.name
}

resource "aws_iam_role_policy_attachment" "attach_ec2_role" {
  role       = aws_iam_role.ec2-role.name
  policy_arn = local.ec2_role_policy_arn_by_option[var.ec2_role_policy_option]
}

resource "aws_iam_role_policy_attachment" "attach_dynamodb" {
  role       = aws_iam_role.ec2-role.name
  policy_arn = aws_iam_policy.dynamodb_policy.arn
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ec2-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# WARM UP Policy with EC2 Describe and S3 List permissions
locals {
  ec2_role_policy_arn_by_option = {
    option1 = aws_iam_policy.policy_option1.arn
    option2 = aws_iam_policy.policy_option2.arn
    option3 = aws_iam_policy.policy_option3.arn
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

resource "aws_iam_policy" "dynamodb_policy" {
  name   = "${var.project_name}-dynamodb-policy"
  policy = data.aws_iam_policy_document.dynamodb_policy_doc.json
}
