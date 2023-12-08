data "aws_iam_policy_document" "cw_log" {
  # Disable false policy on admin of the key
  # checkov:skip=CKV_AWS_111: "Ensure IAM policies does not allow write access without constraints"
  # checkov:skip=CKV_AWS_109: "Ensure IAM policies does not allow write access without constraints"
  # checkov:skip=CKV_AWS_356: "Ensure no IAM policies documents allow "*" as a statement's resource for restrictable actions"

  statement {
    sid    = "AllowUsageOfTheKeyFromCloudWatch"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["logs.${data.aws_region.current.name}.amazonaws.com"]
    }
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowKeyAdministration"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions = [
      "kms:*"
    ]
    resources = ["*"]
  }
}

resource "aws_kms_key_policy" "cw_logs" {
  key_id = aws_kms_alias.cw_log.target_key_id
  policy = data.aws_iam_policy_document.cw_log.json
}

resource "aws_kms_key" "cw_log" {
  description             = "KMS key to encrypt API-GW logs"
  enable_key_rotation     = true
  deletion_window_in_days = 7
}

resource "aws_kms_alias" "cw_log" {
  name_prefix   = "alias/${var.name}-cw-logs"
  target_key_id = aws_kms_key.cw_log.key_id
}

resource "aws_cloudwatch_log_group" "example" {
  name              = local.cloudwatch_log
  retention_in_days = 365
  kms_key_id        = aws_kms_alias.cw_log.target_key_arn
}

resource "aws_api_gateway_account" "api" {
  cloudwatch_role_arn = aws_iam_role.cloudwatch.arn
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "cloudwatch" {
  name               = "api_gateway_cloudwatch_global_${var.name}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "cloudwatch" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:FilterLogEvents",
    ]

    resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/apigateway/*"]
  }
}

resource "aws_iam_role_policy" "cloudwatch" {
  name   = "example"
  role   = aws_iam_role.cloudwatch.id
  policy = data.aws_iam_policy_document.cloudwatch.json
}
