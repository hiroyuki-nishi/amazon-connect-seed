module "prefix_xxx" {
  source = "../../modules"

  env = var.env

  vpc_id                 = var.vpc_id
  vpc_public_subnet_id   = var.vpc_public_subnet_id
  vpc_private_subnet_ids = var.vpc_private_subnet_ids
}
