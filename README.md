# Amazon API Gateway Deployment Lifecycle Management via Terraform

Maintaining a comprehensive deployment history is crucial for ensuring the ability to revert to prior versions when necessary or assign different API stages to different API deployments. This ensures that you can smoothly transition between different states of your infrastructure.

This project provides a steps by step guide and reusable sample code to deploy and manage API deployments and API stages of an Amazon API Gateway via Terraform. By using this solution, the history of API deployment will be maintain and will be possible to assign different stages or rollback to previous versions. This overcomes the problem that, by default, Terraform considers deployments as resources and so at every change only the last deployment will be maintain. 

This repository will not focus on delivering a fully featured Amazon API Gateway and the one defined is for demonstration purpose. The API-GW definition is inspired by Terraform documentation, [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_rest_api)

## How to use it

The variable `deployments` contains the memory of the deployments that needs to be performed.

Everytime that thre is a new deployment to be done this needs to be extended.

Each deployment is saved in the Terraform state file so each of element of
`deployments` variable refers to a resource in the state file.

In case of removal of the element Terraform will try to remove the deployment as well.

### 1. First deployment

Set the variable as:

- `deployments = ['a']` (you can change the value element as you prefer.)
- `rollback = false`
- `reverse_ids = 2`

you can now run terraform apply and check the `Stage` `example` is attached to
the first deployment.

### 2. Deploy a new version and attach the stage to the latest

Set the variable as:

- `deployments = ['a','b']` (you can change the value element as you prefer.)
- `rollback = false`
- `reverse_ids = 2`

you can now run terraform apply and check the `Stage` `example` is attached to
the last deployment and the previous is kept in the history

### 3. Roll back to a previous version

Set the variable as:

- `deployments = ['a','b']` (you can change the value element as you prefer.)
- `rollback = true`
- `reverse_ids = 2`

you can now run terraform apply and check the `Stage` `example` is rolled back to
the first deployment and you still have the latest kept in the history

### 4. Delete a deployment

Change the attribute `prevent_destroy` to false in the lifecycle rule of the `aws_api_gateway_deployment`

```yaml
  lifecycle {
    create_before_destroy = true
    ignore_changes = all
    prevent_destroy = false    # <-------------
  }
```

Remove the deployment from the `deployments` var.
E.g. With the configuration we will remove the first deployment.

- `deployments = ['b']` (you can change the value element as you prefer.)
- `rollback = false`
- `reverse_ids = 2`

you can now run terraform apply and check the `Stage` `example` is poiting to the
latest deployment and the first or `a` deployment has been removed.


## Amazon API Gateway Authorization

**The API Gateway examples in this repo do not include usage of API Gateway authorizers for simplicity, but it is recommended to implement authorization in a production API using API Gateway authorizers.** Authorizers allow you to implement authentication and authorization for your API methods, such as via OAuth2, JWT tokens, Lambda authorizers, etc. You can find more information about contrloling and maanging accesss to a REST API in API Gateway in the following link:
https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-control-access-to-api.html

 
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >4.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_api_gateway_deployment.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_deployment) | resource |
| [aws_api_gateway_integration.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_integration_response.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration_response) | resource |
| [aws_api_gateway_method.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method) | resource |
| [aws_api_gateway_method_response.response_200](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_response) | resource |
| [aws_api_gateway_resource.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_resource) | resource |
| [aws_api_gateway_rest_api.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_rest_api) | resource |
| [aws_api_gateway_stage.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_stage) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_deployments"></a> [deployments](#input\_deployments) | List of deployments, this is used to build the deployment ids | `list(string)` | `["a"]` | no |
| <a name="input_reverse_ids"></a> [reverse\_ids](#input\_reverse\_ids) | Roll back to a previous version, by default to the previous of the latest. Works together with rollback true | `number` | `2` | no |
| <a name="input_rollback"></a> [rollback](#input\_rollback) | Set to true if you want to roll back the stage to a previous version. Details of the version in reverse\_ids | `bool` | `false` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
