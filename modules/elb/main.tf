locals {
  elb_name = coalesce(var.elb_name, "${var.name}-elb")

  common_tags = merge(var.tags, {
    ManagedBy = "Terraform"
    Module    = "elb"
    Workload  = var.name
  })
}

check "subnets_are_provided" {
  assert {
    condition     = length(var.subnet_ids) > 0
    error_message = "Provide at least one subnet ID for ELB."
  }
}

check "security_groups_are_provided" {
  assert {
    condition     = length(var.security_group_ids) > 0
    error_message = "Provide at least one security group ID for ELB."
  }
}

check "health_check_timeout_is_less_than_interval" {
  assert {
    condition     = var.health_check_timeout < var.health_check_interval
    error_message = "health_check_timeout must be lower than health_check_interval."
  }
}

check "https_or_ssl_listener_requires_certificate" {
  assert {
    condition = alltrue([
      for listener in var.listeners :
      contains(["HTTPS", "SSL"], upper(listener.lb_protocol)) ? try(listener.ssl_certificate_id, null) != null : true
    ])
    error_message = "Listeners using HTTPS or SSL require ssl_certificate_id."
  }
}

resource "aws_elb" "this" {
  name                        = local.elb_name
  subnets                     = var.subnet_ids
  security_groups             = var.security_group_ids
  internal                    = var.internal
  cross_zone_load_balancing   = var.cross_zone_load_balancing
  idle_timeout                = var.idle_timeout
  connection_draining         = var.connection_draining
  connection_draining_timeout = var.connection_draining_timeout
  instances                   = var.instances

  dynamic "listener" {
    for_each = var.listeners
    content {
      instance_port      = listener.value.instance_port
      instance_protocol  = upper(listener.value.instance_protocol)
      lb_port            = listener.value.lb_port
      lb_protocol        = upper(listener.value.lb_protocol)
      ssl_certificate_id = try(listener.value.ssl_certificate_id, null)
    }
  }

  health_check {
    target              = var.health_check_target
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
  }

  dynamic "access_logs" {
    for_each = var.access_logs == null ? [] : [var.access_logs]
    content {
      bucket        = access_logs.value.bucket
      bucket_prefix = try(access_logs.value.bucket_prefix, null)
      interval      = try(access_logs.value.interval, 60)
      enabled       = try(access_logs.value.enabled, true)
    }
  }

  tags = merge(local.common_tags, var.elb_tags, {
    Name = local.elb_name
  })
}
