module "vpc" {
  source = "./modules/vpc"
  name   = "medusa-vpc"
  cidr   = "10.0.0.0/16"
}


module "rds" {
  source          = "./modules/rds"
  db_name         = "medusa_db"
  db_username     = "medusa-user"
  db_password     = var.db_password
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
}


module "ecr" {
  source = "./modules/ecr"
  repositories = ["medusa-backend", "medusa-frontend"]
}

module "alb" {
  source         = "./modules/alb"
  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
  alb_sg_id      = module.vpc.alb_sg_id
}

module "ecs" {
  source                = "./modules/ecs"
  cluster_name          = "medusa-cluster"
  vpc-id                = module.vpc.vpc_id
  subnets               = module.vpc.private_subnets
  alb_target_group_arn  = module.alb.target_group_arn
  container_definitions = file("ecs-container.json")
}
