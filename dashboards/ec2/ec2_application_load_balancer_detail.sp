dashboard "aws_ec2_application_load_balancer_detail" {
  title         = "AWS EC2 Application Load Balancer Detail"
  documentation = file("./dashboards/ec2/docs/ec2_application_load_balancer_detail.md")

  tags = merge(local.ec2_common_tags, {
    type = "Detail"
  })

  input "alb" {
    title = "Select an Application Load balancer:"
    query = query.aws_alb_input
    width = 4
  }

  container {

    card {
      width = 2
      query = query.aws_alb_state
      args = {
        arn = self.input.alb.value
      }
    }

    card {
      width = 2
      query = query.aws_alb_scheme
      args = {
        arn = self.input.alb.value
      }
    }

    card {
      width = 2
      query = query.aws_alb_ip_type
      args = {
        arn = self.input.alb.value
      }
    }

    card {
      width = 2
      query = query.aws_alb_az_zone
      args = {
        arn = self.input.alb.value
      }
    }

    card {
      width = 2
      query = query.aws_alb_logging_enabled
      args = {
        arn = self.input.alb.value
      }
    }

    card {
      width = 2
      query = query.aws_alb_deletion_protection
      args = {
        arn = self.input.alb.value
      }
    }

  }

  container {
    graph {
      type      = "graph"
      direction = "TD"


      nodes = [
        node.aws_ec2_application_load_balancer_node,
        node.aws_ec2_alb_to_vpc_security_group_node,
        node.aws_ec2_alb_to_target_group_node,
        node.aws_ec2_alb_to_ec2_instance_node,
        node.aws_ec2_alb_to_s3_bucket_node,
        node.aws_ec2_alb_to_vpc_node,
        node.aws_ec2_alb_from_ec2_load_balancer_listener_node
      ]

      edges = [
        edge.aws_ec2_alb_to_vpc_security_group_edge,
        edge.aws_ec2_alb_to_target_group_edge,
        edge.aws_ec2_alb_to_ec2_instance_edge,
        edge.aws_ec2_alb_to_s3_bucket_edge,
        edge.aws_ec2_alb_to_vpc_edge,
        edge.aws_ec2_alb_from_ec2_load_balancer_listener_edge
      ]

      args = {
        arn = self.input.alb.value
      }
    }
  }

  container {

    table {
      title = "Overview"
      type  = "line"
      width = 3
      query = query.aws_ec2_alb_overview
      args = {
        arn = self.input.alb.value
      }

    }

    table {
      title = "Tags"
      width = 3
      query = query.aws_ec2_alb_tags
      args = {
        arn = self.input.alb.value
      }
    }

    table {
      title = "Attributes"
      width = 6
      query = query.aws_ec2_alb_attributes
      args = {
        arn = self.input.alb.value
      }
    }
  }

}

query "aws_ec2_alb_overview" {
  sql = <<-EOQ
    select
      title as "Title",
      created_time as "Created Time",
      dns_name as "DNS Name",
      canonical_hosted_zone_id as "Route 53 hosted zone ID",
      account_id as "Account ID",
      region as "Region",
      arn as "ARN"
    from
      aws_ec2_application_load_balancer
    where
      aws_ec2_application_load_balancer.arn = $1;
  EOQ

  param "arn" {}
}

query "aws_ec2_alb_tags" {
  sql = <<-EOQ
    select
      tag ->> 'Key' as "Key",
      tag ->> 'Value' as "Value"
    from
      aws_ec2_application_load_balancer,
      jsonb_array_elements(tags_src) as tag
    where
      arn = $1
    order by
      tag ->> 'Key';
    EOQ

  param "arn" {}
}

query "aws_ec2_alb_attributes" {
  sql = <<-EOQ
    select
      lb ->> 'Key' as "Key",
      lb ->> 'Value' as "Value"
    from
      aws_ec2_application_load_balancer
      cross join jsonb_array_elements(load_balancer_attributes) as lb
    where
      aws_ec2_application_load_balancer.arn = $1
      and lb ->> 'Key' not in ( 'deletion_protection.enabled' ,'access_logs.s3.enabled' )
    order by
      lb ->> 'Key';
    EOQ

  param "arn" {}
}

query "aws_alb_ip_type" {
  sql = <<-EOQ
    select
      'IP Address Type' as label,
      case when ip_address_type = 'ipv4' then 'IPv4' else initcap(ip_address_type) end as value
    from
      aws_ec2_application_load_balancer
    where
      aws_ec2_application_load_balancer.arn = $1;
  EOQ

  param "arn" {}
}

query "aws_alb_logging_enabled" {
  sql = <<-EOQ
    select
      'Logging' as label,
      case when lb ->> 'Value' = 'false' then 'Disabled' else 'Enabled' end as value,
      case when lb ->> 'Value' = 'false' then 'alert' else 'ok' end as type
    from
      aws_ec2_application_load_balancer
      cross join jsonb_array_elements(load_balancer_attributes) as lb
    where
      lb ->> 'Key' = 'access_logs.s3.enabled'
      and aws_ec2_application_load_balancer.arn = $1;
  EOQ

  param "arn" {}
}

query "aws_alb_deletion_protection" {
  sql = <<-EOQ
    select
      'Deletion Protection' as label,
      case when lb ->> 'Value' = 'false' then 'Disabled' else 'Enabled' end as value,
      case when lb ->> 'Value' = 'false' then 'alert' else 'ok' end as type
    from
      aws_ec2_application_load_balancer
      cross join jsonb_array_elements(load_balancer_attributes) as lb
    where
      lb ->> 'Key' = 'deletion_protection.enabled'
      and aws_ec2_application_load_balancer.arn = $1;
  EOQ

  param "arn" {}
}

query "aws_alb_az_zone" {
  sql = <<-EOQ
    select
      'Availibility Zones' as label,
      count(az ->> 'ZoneName') as value,
      case when count(az ->> 'ZoneName') > 1 then 'ok' else 'alert' end as type
    from
      aws_ec2_application_load_balancer
      cross join jsonb_array_elements(availability_zones) as az
    where
      arn = $1;
  EOQ

  param "arn" {}
}

query "aws_alb_state" {
  sql = <<-EOQ
    select
      'State' as label,
      initcap(state_code) as value
    from
      aws_ec2_application_load_balancer
    where
      arn = $1;
  EOQ

  param "arn" {}
}

query "aws_alb_scheme" {
  sql = <<-EOQ
    select
      'Scheme' as label,
      initcap(scheme) as value
    from
      aws_ec2_application_load_balancer
    where
      arn = $1;
  EOQ

  param "arn" {}
}

node "aws_ec2_application_load_balancer_node" {
  category = category.aws_ec2_application_load_balancer

  sql = <<-EOQ
    select
      arn as id,
      name as title,
      jsonb_build_object(
        'ARN', arn,
        'Account ID', account_id,
        'Region', region,
        'DNS Name', dns_name
      ) as properties
    from
      aws_ec2_application_load_balancer
    where
      arn = $1;
  EOQ

  param "arn" {}
}

node "aws_ec2_alb_to_vpc_security_group_node" {
  category = category.aws_vpc_security_group

  sql = <<-EOQ
    select
      sg.arn as id,
      sg.title as title,
      jsonb_build_object(
        'Group Name', sg.group_name,
        'Group ID', sg.group_id,
        'ARN', sg.arn,
        'Account ID', sg.account_id,
        'Region', sg.region,
        'VPC ID', sg.vpc_id
      ) as properties
    from
      aws_vpc_security_group sg,
      aws_ec2_application_load_balancer as alb
    where
      alb.arn = $1
      and sg.group_id in
      (
        select
          jsonb_array_elements_text(alb.security_groups)
      );
  EOQ

  param "arn" {}
}

edge "aws_ec2_alb_to_vpc_security_group_edge" {
  title = "security group"

  sql = <<-EOQ
    select
      alb.arn as from_id,
      sg.arn as to_id,
      jsonb_build_object(
        'Account ID', sg.account_id
      ) as properties
    from
      aws_vpc_security_group sg,
      aws_ec2_application_load_balancer as alb
    where
      alb.arn = $1
      and sg.group_id in
      (
        select
          jsonb_array_elements_text(alb.security_groups)
      );
  EOQ

  param "arn" {}
}

node "aws_ec2_alb_to_target_group_node" {
  category = category.aws_ec2_target_group

  sql = <<-EOQ
    select
      tg.target_group_arn as id,
      tg.title as title,
      jsonb_build_object(
        'Group Name', tg.target_group_name,
        'ARN', tg.target_group_arn,
        'Account ID', tg.account_id,
        'Region', tg.region
      ) as properties
    from
      aws_ec2_target_group tg
    where
      $1 in
      (
        select
          jsonb_array_elements_text(tg.load_balancer_arns)
      );
  EOQ

  param "arn" {}
}

edge "aws_ec2_alb_to_target_group_edge" {
  title = "target group"

  sql = <<-EOQ
    select
      $1 as from_id,
      tg.target_group_arn as to_id,
      jsonb_build_object(
        'Account ID', tg.account_id
      ) as properties
    from
      aws_ec2_target_group tg
    where
      $1 in
      (
        select
          jsonb_array_elements_text(tg.load_balancer_arns)
      );
  EOQ

  param "arn" {}
}

node "aws_ec2_alb_to_ec2_instance_node" {
  category = category.aws_ec2_instance

  sql = <<-EOQ
    select
      instance.instance_id as id,
      instance.title as title,
      jsonb_build_object(
        'Instance ID', instance.instance_id,
        'ARN', instance.arn,
        'Account ID', instance.account_id,
        'Region', instance.region
      ) as properties
    from
      aws_ec2_target_group tg,
      aws_ec2_instance instance,
      jsonb_array_elements(tg.target_health_descriptions) thd
    where
      instance.instance_id = thd -> 'Target' ->> 'Id'
      and $1 in
      (
        select
          jsonb_array_elements_text(tg.load_balancer_arns)
      );
  EOQ

  param "arn" {}
}

edge "aws_ec2_alb_to_ec2_instance_edge" {
  title = "ec2 instance"

  sql = <<-EOQ
    select
      tg.target_group_arn as from_id,
      instance.instance_id as to_id,
      jsonb_build_object(
        'Account ID', instance.account_id,
        'Health Check Port', thd['HealthCheckPort'],
        'Health Check State', thd['TargetHealth']['State']
      ) as properties
    from
      aws_ec2_target_group tg,
      aws_ec2_instance instance,
      jsonb_array_elements(tg.target_health_descriptions) thd
    where
      instance.instance_id = thd -> 'Target' ->> 'Id'
      and $1 in
      (
        select
          jsonb_array_elements_text(tg.load_balancer_arns)
      );
  EOQ

  param "arn" {}
}

node "aws_ec2_alb_to_s3_bucket_node" {
  category = category.aws_s3_bucket

  sql = <<-EOQ
    select
      buckets.arn as id,
      buckets.title as title,
      jsonb_build_object(
        'Name', buckets.name,
        'ARN', buckets.arn,
        'Account ID', alb.account_id,
        'Region', alb.region,
        'Logs to', attributes ->> 'Value'
      ) as properties
    from
      aws_s3_bucket buckets,
      aws_ec2_application_load_balancer as alb,
      jsonb_array_elements(alb.load_balancer_attributes) attributes
    where
      alb.arn = $1
      and attributes ->> 'Key' = 'access_logs.s3.bucket'
      and buckets.name = attributes ->> 'Value';
  EOQ

  param "arn" {}
}

edge "aws_ec2_alb_to_s3_bucket_edge" {
  title = "logs to"

  sql = <<-EOQ
    select
      alb.arn as from_id,
      buckets.arn as to_id,
      jsonb_build_object(
        'Account ID', alb.account_id,
        'Log Prefix', (
          select
            a ->> 'Value'
          from
            jsonb_array_elements(alb.load_balancer_attributes) as a
          where
            a ->> 'Key' = 'access_logs.s3.prefix'
        )
      ) as properties
    from
      aws_s3_bucket buckets,
      aws_ec2_application_load_balancer as alb,
      jsonb_array_elements(alb.load_balancer_attributes) attributes
    where
      alb.arn = $1
      and attributes ->> 'Key' = 'access_logs.s3.bucket'
      and buckets.name = attributes ->> 'Value';
  EOQ

  param "arn" {}
}

node "aws_ec2_alb_to_vpc_node" {
  category = category.aws_vpc

  sql = <<-EOQ
    select
      vpc.vpc_id as id,
      vpc.title as title,
      jsonb_build_object(
        'VPC ID', vpc.vpc_id,
        'Account ID', vpc.account_id,
        'Region', vpc.region,
        'CIDR Block', vpc.cidr_block
      ) as properties
    from
      aws_vpc vpc,
      aws_ec2_application_load_balancer as alb
    where
      alb.arn = $1
      and alb.vpc_id = vpc.vpc_id;
  EOQ

  param "arn" {}
}

edge "aws_ec2_alb_to_vpc_edge" {
  title = "vpc"

  sql = <<-EOQ
    select
      sg.arn as from_id,
      vpc.vpc_id as to_id,
      jsonb_build_object(
        'Account ID', vpc.account_id
      ) as properties
    from
      aws_vpc vpc,
      aws_ec2_application_load_balancer as alb
      left join aws_vpc_security_group sg 
        on sg.group_id in (select jsonb_array_elements_text(alb.security_groups))
    where
      alb.arn = $1
      and alb.vpc_id = vpc.vpc_id;
  EOQ

  param "arn" {}
}

node "aws_ec2_alb_from_ec2_load_balancer_listener_node" {
  category = category.aws_ec2_load_balancer_listener

  sql = <<-EOQ
    select
      lblistener.arn as id,
      lblistener.title as title,
      jsonb_build_object(
        'ARN', lblistener.arn,
        'Account ID', lblistener.account_id,
        'Region', lblistener.region,
        'Protocol', lblistener.protocol,
        'Port', lblistener.port,
        'SSL Policy', coalesce(lblistener.ssl_policy, 'None')
      ) as properties
    from
      aws_ec2_load_balancer_listener lblistener
    where
      lblistener.load_balancer_arn = $1;
  EOQ

  param "arn" {}
}

edge "aws_ec2_alb_from_ec2_load_balancer_listener_edge" {
  title = "listens with"

  sql = <<-EOQ
    select
      lblistener.arn as from_id,
      $1 as to_id,
      jsonb_build_object(
        'Account ID', lblistener.account_id
      ) as properties
    from
      aws_ec2_load_balancer_listener lblistener
    where
      lblistener.load_balancer_arn = $1
  EOQ

  param "arn" {}
}

query "aws_alb_input" {
  sql = <<-EOQ
    select
      title as label,
      arn as value,
      json_build_object(
        'account_id', account_id,
        'region', region
      ) as tags
    from
      aws_ec2_application_load_balancer
    order by
      title;
  EOQ
}
