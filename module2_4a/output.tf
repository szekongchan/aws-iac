output "nat_gateway_ids" {
  value = module.vpc.natgw_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnets
}
