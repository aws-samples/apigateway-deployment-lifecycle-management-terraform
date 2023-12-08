locals {
  last_deployment = element(var.deployments, length(var.deployments) - 1)
  deployment      = var.rollback == true ? element(var.deployments, length(var.deployments) - var.reverse_ids) : local.last_deployment
  cloudwatch_log  = "/aws/apigateway/${var.cloudwatch_log}"
}
