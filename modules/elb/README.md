# Module: ELB (Classic)

## Purpose
Provisiona Classic ELB com listeners, health check e registro opcional de instancias.

## What This Module Builds
- `aws_elb` com listeners configuraveis.
- `health_check` customizavel.
- Registro opcional de instancias EC2.
- Access logs opcionais.

## Key Inputs
- `name`, `subnet_ids`, `security_group_ids`
- `listeners`
- `health_check_target`, `health_check_interval`, `health_check_timeout`
- `instances`

## Key Outputs
- `elb_name`, `elb_dns_name`
- `elb_zone_id`
- `registered_instance_ids`

## Notes
- Classic ELB nao usa target groups. Para target groups com health check, use o modulo `alb`.
