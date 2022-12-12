locals {
  elasticache_common_tags = {
    service = "AWS/ElastiCache"
  }
}

category "elasticache_cluster" {
  title = "ElastiCache Cluster"
  color = local.database_color
  href  = "/aws_insights.dashboard.elasticache_cluster_detail.url_path?input.elasticache_cluster_arn={{.properties.ARN | @uri}}"
  icon  = "circle-stack"
}

category "elasticache_parameter_group" {
  title = "ElastiCache Parameter Group"
  color = local.database_color
  icon  = "text:PG"
}

category "elasticache_subnet_group" {
  title = "ElastiCache Subnet Group"
  color = local.database_color
  icon  = "text:SG"
}
