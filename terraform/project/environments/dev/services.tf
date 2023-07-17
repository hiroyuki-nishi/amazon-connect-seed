module "dev" {
  source = "../../dev_modules"

  env = var.env

  lambdas_security_group_id = module.prefix_xxx.lambdas_security_group_id
}

module "prefix_xxx" {
  source = "../../modules"

  env = var.env

  vpc_id                 = module.dev.vpc_id
  vpc_public_subnet_id   = module.dev.vpc_public_subnet_id
  vpc_private_subnet_ids = module.dev.vpc_private_subnet_ids
}
