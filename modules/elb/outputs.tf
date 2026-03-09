output "elb_id" {
  description = "ID of ELB."
  value       = aws_elb.this.id
}

output "elb_arn" {
  description = "ARN of ELB, when available."
  value       = try(aws_elb.this.arn, null)
}

output "elb_name" {
  description = "Name of ELB."
  value       = aws_elb.this.name
}

output "elb_dns_name" {
  description = "DNS name of ELB."
  value       = aws_elb.this.dns_name
}

output "elb_zone_id" {
  description = "Canonical hosted zone ID of ELB."
  value       = aws_elb.this.zone_id
}

output "source_security_group_id" {
  description = "Source security group ID created by ELB."
  value       = aws_elb.this.source_security_group_id
}

output "registered_instance_ids" {
  description = "Instance IDs registered in ELB."
  value       = aws_elb.this.instances
}
