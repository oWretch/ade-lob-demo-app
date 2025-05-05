variable "resource_group_name" {
  description = "Name of the Resource Group where the app will be deployed"
  type        = string
}

variable "ade_env_name" {
  description = "Name of the ADE Environment"
  type        = string
}

variable "ade_subscription" {
  description = "ID of the subcription into which we deploy"
  type        = string
}

variable "ade_location" {
  description = "Azure region to deploy resources"
  type        = string
}

variable "ade_environment_type" {
  description = "Deployment Environment Type"
  type        = string
}

variable "app_version" {
  description = "Version of the application to deploy"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Project   = "Line of Business App"
    CreatedBy = "Azure Deployment Environment"
  }
}

variable "greeting" {
  description = "Greeting to display"
  type        = string
}
