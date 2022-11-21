
	

	data "aws_caller_identity" "current" {}
	data "aws_region" "current" {}
	

	#####
	# VPC and subnets
	#####
	data "aws_vpc" "default" {
	  default = true
	}
	

	data "aws_subnets" "all" {
	  filter {
	    name   = "vpc-id"
	    values = [data.aws_vpc.default.id]
	  }
	}
	

	#####
	# External Security Group
	#####
	resource "aws_security_group" "other_sg" {
	  vpc_id = data.aws_vpc.default.id
	}




module "redis" {
  source = "umotif-public/elasticache-redis/aws"
  version = "~> 3.0.0"

  name_prefix           = "core-example"
  num_cache_clusters    = 2
  node_type             = "cache.t4g.small"

  engine_version           = "6.x"
  port                     = 6379
  maintenance_window       = "mon:03:00-mon:04:00"
  snapshot_window          = "04:00-06:00"
  snapshot_retention_limit = 7

  automatic_failover_enabled = true

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  auth_token                 = "1234567890asdfghjkl"

  apply_immediately = true
  family            = "redis6.x"
  description       = "Test elasticache redis."

  #subnet_ids = module.vpc.private_subnets
  #vpc_id     = module.vpc.vpc_id
subnet_ids = data.aws_subnets.all.ids
	  vpc_id     = data.aws_vpc.default.id
  ingress_cidr_blocks = ["0.0.0.0/0"]

  parameter = [
    {
      name  = "repl-backlog-size"
      value = "16384"
    }
  ]


  tags = {
    Project = "Test"
  }
}
