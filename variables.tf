variable "name" {
  description = "Name of the project used as prefix"
  default     = "example"
  type        = string
}

variable "deployments" {
  description = "List of deployments, this is used to build the deployment ids"
  default     = ["a"]
  type        = list(string)
}

variable "rollback" {
  description = "Set to true if you want to roll back the stage to a previous version. Details of the version in reverse_ids"
  default     = false
  type        = bool
}

variable "reverse_ids" {
  description = "Roll back to a previous version, by default to the previous of the latest. Works together with rollback true"
  default     = 2
  type        = number
}

variable "cloudwatch_log" {
  description = "Provides CloudWatch Log group name"
  default     = "apigateway-deployment-management-log"
  type        = string
}
