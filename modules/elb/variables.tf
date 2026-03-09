variable "name" {
  description = "Base name used for ELB resources."
  type        = string
}

variable "elb_name" {
  description = "Optional explicit name for ELB."
  type        = string
  default     = null
}

variable "internal" {
  description = "Whether the ELB is internal."
  type        = bool
  default     = false
}

variable "subnet_ids" {
  description = "Subnet IDs attached to ELB."
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs attached to ELB."
  type        = list(string)
  default     = []
}

variable "cross_zone_load_balancing" {
  description = "Enable cross-zone load balancing."
  type        = bool
  default     = true
}

variable "idle_timeout" {
  description = "Idle timeout in seconds."
  type        = number
  default     = 60

  validation {
    condition     = var.idle_timeout >= 1 && var.idle_timeout <= 4000
    error_message = "idle_timeout must be between 1 and 4000."
  }
}

variable "connection_draining" {
  description = "Enable connection draining."
  type        = bool
  default     = true
}

variable "connection_draining_timeout" {
  description = "Connection draining timeout in seconds."
  type        = number
  default     = 300

  validation {
    condition     = var.connection_draining_timeout >= 1 && var.connection_draining_timeout <= 3600
    error_message = "connection_draining_timeout must be between 1 and 3600."
  }
}

variable "listeners" {
  description = "ELB listeners."
  type = list(object({
    instance_port      = number
    instance_protocol  = string
    lb_port            = number
    lb_protocol        = string
    ssl_certificate_id = optional(string)
  }))
  default = [
    {
      instance_port      = 80
      instance_protocol  = "http"
      lb_port            = 80
      lb_protocol        = "http"
      ssl_certificate_id = null
    }
  ]

  validation {
    condition = alltrue([
      for listener in var.listeners :
      listener.instance_port >= 1 && listener.instance_port <= 65535
    ])
    error_message = "listeners.instance_port must be between 1 and 65535."
  }

  validation {
    condition = alltrue([
      for listener in var.listeners :
      listener.lb_port >= 1 && listener.lb_port <= 65535
    ])
    error_message = "listeners.lb_port must be between 1 and 65535."
  }

  validation {
    condition = alltrue([
      for listener in var.listeners :
      contains(["HTTP", "HTTPS", "TCP", "SSL"], upper(listener.lb_protocol))
    ])
    error_message = "listeners.lb_protocol must be HTTP, HTTPS, TCP, or SSL."
  }

  validation {
    condition = alltrue([
      for listener in var.listeners :
      contains(["HTTP", "HTTPS", "TCP", "SSL"], upper(listener.instance_protocol))
    ])
    error_message = "listeners.instance_protocol must be HTTP, HTTPS, TCP, or SSL."
  }
}

variable "instances" {
  description = "Instance IDs registered in ELB."
  type        = list(string)
  default     = []
}

variable "health_check_target" {
  description = "Health check target in ELB format, for example HTTP:80/."
  type        = string
  default     = "HTTP:80/"
}

variable "health_check_healthy_threshold" {
  description = "Healthy threshold for ELB health check."
  type        = number
  default     = 3

  validation {
    condition     = var.health_check_healthy_threshold >= 2 && var.health_check_healthy_threshold <= 10
    error_message = "health_check_healthy_threshold must be between 2 and 10."
  }
}

variable "health_check_unhealthy_threshold" {
  description = "Unhealthy threshold for ELB health check."
  type        = number
  default     = 3

  validation {
    condition     = var.health_check_unhealthy_threshold >= 2 && var.health_check_unhealthy_threshold <= 10
    error_message = "health_check_unhealthy_threshold must be between 2 and 10."
  }
}

variable "health_check_interval" {
  description = "Health check interval in seconds."
  type        = number
  default     = 30

  validation {
    condition     = var.health_check_interval >= 5 && var.health_check_interval <= 300
    error_message = "health_check_interval must be between 5 and 300."
  }
}

variable "health_check_timeout" {
  description = "Health check timeout in seconds."
  type        = number
  default     = 5

  validation {
    condition     = var.health_check_timeout >= 2 && var.health_check_timeout <= 120
    error_message = "health_check_timeout must be between 2 and 120."
  }
}

variable "access_logs" {
  description = "Optional ELB access logs configuration."
  type = object({
    bucket        = string
    bucket_prefix = optional(string)
    interval      = optional(number, 60)
    enabled       = optional(bool, true)
  })
  default = null
}

variable "tags" {
  description = "Common tags applied to all resources."
  type        = map(string)
  default     = {}
}

variable "elb_tags" {
  description = "Additional tags for ELB resource."
  type        = map(string)
  default     = {}
}
