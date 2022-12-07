locals {
  iam_common_tags = {
    service = "AWS/IAM"
  }
}

category "iam_access_key" {
  title = "IAM Access Key"
  color = local.iam_color
  icon  = "heroicons-outline:key"
}

category "iam_federated_principal" {
  icon  = "heroicons-outline:heroicons-outline:user-group"
  color = "orange"
  title = "Federated"
}

category "iam_group" {
  title = "IAM Group"
  color = local.iam_color
  href  = "/aws_insights.dashboard.iam_group_detail?input.group_arn={{.properties.'ARN' | @uri}}"
  icon  = "heroicons-outline:user-group"
}

category "iam_policy" {
  title = "IAM Policy"
  color = local.iam_color
  href  = "/aws_insights.dashboard.iam_policy_detail?input.policy_arn={{.properties.'ARN' | @uri}}"
  icon  = "heroicons-outline:document-check"
}

category "iam_instance_profile" {
  title = "IAM Profile"
  icon  = "heroicons-outline:user-plus"
  color = local.iam_color
}

category "iam_role" {
  title = "IAM Role"
  href  = "/aws_insights.dashboard.iam_role_detail?input.role_arn={{.properties.'ARN' | @uri}}"
  icon  = "heroicons-outline:user-plus"
  color = local.iam_color
}

category "iam_service_principal" {
  icon  = "heroicons-outline:heroicons-outline:cog-6-tooth"
  color = "orange"
  title = "Service"
}

category "iam_user" {
  title = "IAM User"
  color = local.iam_color
  href  = "/aws_insights.dashboard.iam_user_detail?input.user_arn={{.properties.'ARN' | @uri}}"
  icon  = "heroicons-outline:user"
}

category "iam_inline_policy" {
  icon  = "heroicons-outline:heroicons-outline:clipboard-document"
  color = "red"
  title = "IAM Policy"
}

category "iam_policy_statement" {
  icon  = "heroicons-outline:heroicons-outline:clipboard-document"
  color = "red"
  title = "Statement"
}

category "iam_policy_action" {
  href  = "/aws_insights.dashboard.iam_action_glob_report?input.action_glob={{.title | @uri}}"
  icon  = "heroicons-outline:heroicons-outline:bolt"
  color = "red"
  title = "Action"
}

category "iam_policy_notaction" {
  icon  = "heroicons-outline:heroicons-outline:bolt-slash"
  color = "red"
  title = "NotAction"
}

category "iam_policy_resource" {
  icon  = "heroicons-outline:heroicons-outline:bookmark"
  color = "red"
  title = "Resource"
}

category "iam_policy_notresource" {
  icon  = "heroicons-outline:heroicons-outline:bookmark-slash"
  color = "red"
  title = "NotResource"
}

category "iam_policy_condition" {
  icon  = "heroicons-outline:heroicons-outline:question-mark-circle"
  color = "red"
  title = "Condition"
}

category "iam_policy_condition_key" {
  icon  = "text:key"
  color = "red"
  title = "Condition Key"
}

category "iam_policy_condition_value" {
  icon  = "text:val"
  color = "red"
  title = "Condition Value"
}
