# variables.tf

variable "aws_region" {
  description = "The AWS region things are created in"
  default     = "us-east-1"
}

variable "ecs_task_execution_role_name" {
  description = "ECS task execution role name"
  default = "IM_EcsTaskExecutionRole"
} 

variable "postgres_DB_NAME" {
  description = "postgres DB name"
  default = "im_dev"
} 

variable "postgres_DB_USER" {
  description = "postgres DB user name"
  default = "admin2"
} 

variable "postgres_DB_PASSWORD" {
  description = "Enter the password for postgres DB"
  
} 
variable "REDIS_URL_SIDEKIQ" {
  description = "REDIS_URL_SIDEKIQ"
  default = "redis://localhost:6379/1"
}

variable "REACT_APP_API_BASE_URL" {
    description = "REACT_APP_API_BASE_URL"
    default = "web://localhost:3000"
} 

variable "health_check_path" {
    description = "health_check_path"
    default = "/"
} 

