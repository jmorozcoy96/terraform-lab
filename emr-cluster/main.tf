terraform {
  required_providers {
    aws    = { source = "hashicorp/aws", version = ">= 5.0" }
    random = { source = "hashicorp/random", version = ">= 3.0" }
  }
}

provider "aws" {
  region = var.region
}

# ---------------------------
# Auto-descubrir una SUBRED PUBLICA en la VPC por defecto
# ---------------------------
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "public_defaults" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  # Subredes que asignan IP pública al lanzar (públicas)
  filter {
    name   = "map-public-ip-on-launch"
    values = ["true"]
  }
}

locals {
  # Tomamos la primera subred pública disponible
  subnet_id = element(data.aws_subnets.public_defaults.ids, 0)
}

# ---------------------------
# S3 para logs de EMR
# ---------------------------
resource "random_id" "suffix" {
  byte_length = 3
}

resource "aws_s3_bucket" "emr_logs" {
  bucket        = "emr-logs-${var.project}-${random_id.suffix.hex}"
  force_destroy = true
}

# ---------------------------
# IAM ROLES
# ---------------------------
# Rol de servicio de EMR
resource "aws_iam_role" "emr_service_role" {
  name = "${var.project}-EMRServiceRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "elasticmapreduce.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "emr_service_attach" {
  role       = aws_iam_role.emr_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceRole"
}

# Rol para las instancias EC2 del cluster
resource "aws_iam_role" "emr_ec2_role" {
  name = "${var.project}-EMREC2Role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

# Permisos requeridos por EMR en EC2
resource "aws_iam_role_policy_attachment" "emr_ec2_attach" {
  role       = aws_iam_role.emr_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role"
}

# (Opcional recomendado) Permitir SSM (Session Manager) a los nodos
resource "aws_iam_role_policy_attachment" "emr_ec2_ssm" {
  role       = aws_iam_role.emr_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "emr_ec2_profile" {
  name = "${var.project}-EMREC2InstanceProfile"
  role = aws_iam_role.emr_ec2_role.name
}

# ---------------------------
# EMR CLUSTER (Spark distribuido)
# ---------------------------
resource "aws_emr_cluster" "this" {
  name          = "${var.project}-emr-spark-cluster"
  release_label = var.emr_release
  applications  = ["Hadoop", "Spark"]

  ec2_attributes {
    subnet_id        = local.subnet_id
    instance_profile = aws_iam_instance_profile.emr_ec2_profile.arn
    # (Si quisieras SSH: key_name = var.key_name y abre 22, pero para el taller usaremos SSM)
  }

  master_instance_group {
    instance_type  = var.master_instance_type
    instance_count = 1
  }

  core_instance_group {
    instance_type  = var.core_instance_type
    instance_count = var.core_instance_count  # >=2 para Spark distribuido
  }

  service_role  = aws_iam_role.emr_service_role.arn
  log_uri       = "s3://${aws_s3_bucket.emr_logs.bucket}/logs/"
  visible_to_all_users              = true
  keep_job_flow_alive_when_no_steps = true
  step_concurrency_level            = 1

  # ---------------------------
  # ✅ Step de validación (SparkPi)
  # ---------------------------
  step {
    name              = "validate-spark"
    action_on_failure = "CONTINUE"
    hadoop_jar_step {
      jar  = "command-runner.jar"
      args = [
        "spark-submit", "--master", "yarn", "--deploy-mode", "cluster",
        "/usr/lib/spark/examples/jars/spark-examples.jar", "1000"
      ]
    }
  }

  tags = {
    Project = var.project
    Name    = "${var.project}-emr"
  }
}