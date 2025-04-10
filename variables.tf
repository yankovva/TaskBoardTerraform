variable "resource_group_name" {
  type        = string
  description = "the nME OF THE RSOURCE GROUP"
}

variable "resource_group_location" {
  type        = string
  description = "the RG location"
}

variable "app_service_plan_name" {
  type        = string
  description = "the name servide plan"
}

variable "app_service_name" {
  type        = string
  description = "the name of the app"
}

variable "sql_server_name" {
  type        = string
  description = "the name of the sql server"
}

variable "sql_server_db_name" {
  type        = string
  description = "the name of the db"
}

variable "sql_admin_login" {
  type        = string
  description = "the sql user"
}

variable "sql_admin_pasword" {
  type        = string
  description = "the sql password"
}

variable "firewall_rule_name" {
  type        = string
  description = "the name of the firewall rule"
}

variable "repo_url" {
  type        = string
  description = "the location of the github repo"
}
