resource "aws_api_gateway_rest_api" "example" {
  name = var.name
}

resource "aws_api_gateway_resource" "example" {
  parent_id   = aws_api_gateway_rest_api.example.root_resource_id
  path_part   = "example"
  rest_api_id = aws_api_gateway_rest_api.example.id
}

resource "aws_api_gateway_request_validator" "example" {
  name                        = var.name
  rest_api_id                 = aws_api_gateway_rest_api.example.id
  validate_request_body       = true
  validate_request_parameters = true
}

resource "aws_api_gateway_method" "example" {
  authorization        = "NONE"
  http_method          = "PUT"
  api_key_required     = true
  request_validator_id = aws_api_gateway_request_validator.example.id
  resource_id          = aws_api_gateway_resource.example.id
  rest_api_id          = aws_api_gateway_rest_api.example.id
}

resource "aws_api_gateway_integration" "example" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  resource_id = aws_api_gateway_resource.example.id
  http_method = aws_api_gateway_method.example.http_method
  type        = "MOCK"
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  resource_id = aws_api_gateway_resource.example.id
  http_method = aws_api_gateway_method.example.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "example" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  resource_id = aws_api_gateway_resource.example.id
  http_method = aws_api_gateway_method.example.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code

  # Transforms the backend JSON response to XML
  response_templates = {
    "application/xml" = <<EOF
#set($inputRoot = $input.path('$'))
<?xml version="1.0" encoding="UTF-8"?>
<message>
    $inputRoot.body
</message>
EOF
  }
}

resource "aws_api_gateway_deployment" "example" {
  for_each    = toset(var.deployments)
  rest_api_id = aws_api_gateway_rest_api.example.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.example.id,
      aws_api_gateway_method.example.id,
      aws_api_gateway_integration.example.id,
    ]))
  }

  # In case of removal of API-GW deployments "prevent_destroy" needs to be set to "false".
  lifecycle {
    create_before_destroy = true
    ignore_changes        = all
    prevent_destroy       = true
  }
}

resource "aws_api_gateway_stage" "example" {
  # For the purpose of this example the API GW will not be protected by WAF and SSL certificate.
  # The users is anyway encorauged to protect configure WAF and SSL certificate.
  # checkov:skip=CKV2_AWS_51: "Ensure AWS API Gateway endpoints uses client certificate authentication"
  # checkov:skip=CKV2_AWS_29: "Ensure public API gateway are protected by WAF"
  # depends_on            = [aws_cloudwatch_log_group.example]
  deployment_id         = aws_api_gateway_deployment.example[local.deployment].id
  rest_api_id           = aws_api_gateway_rest_api.example.id
  stage_name            = "example"
  cache_cluster_enabled = true
  xray_tracing_enabled  = true
  cache_cluster_size    = "0.5"
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.example.arn
    format          = "$context.identity.sourceIp - $context.identity.caller - $context.identity.user [$context.requestTime] \"$context.httpMethod $context.resourcePath $context.protocol\" $context.status $context.responseLength $context.requestId"
  }
}

resource "aws_api_gateway_method_settings" "example" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  stage_name  = aws_api_gateway_stage.example.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled      = true
    logging_level        = "INFO"
    caching_enabled      = true
    cache_data_encrypted = true
  }
}
