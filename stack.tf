variable "access_key" {}
variable "secret_key" {}

variable "region" {
  default = "us-west-2"
}
variable "zones" {
  default = [
    "us-west-2a",
    "us-west-2b"
  ]
}

# http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html
variable "amis" {
  default = {
    us-east-1 = "ami-b2df2ca4"
    us-east-2 = "ami-832b0ee6"
    us-west-1 = "ami-dd104dbd"
    us-west-2 = "ami-022b9262"
    eu-west-1 = "ami-a7f2acc1"
    eu-west-2 = "ami-3fb6bc5b"
    eu-central-1 = "ami-ec2be583"
    ap-northeast-1 = "ami-c393d6a4"
    ap-southeast-1 = "ami-a88530cb"
    ap-southeast-2 = "ami-8af8ffe9"
    ca-central-1 = "ami-ead5688e"
  }
}

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "aws_ecs_cluster" "nuvolari_ecs_cluster" {
  name = "nuvolari-ecs-cluster"
}

resource "aws_launch_configuration" "nuvolari_instance" {
  name_prefix = "nuvolari-instance-"
  instance_type = "t2.micro"
  image_id = "${lookup(var.amis, var.region)}"
  iam_instance_profile = "ecsInstanceRole"
  user_data = <<EOF
#!/bin/bash
echo ECS_CLUSTER=nuvolari-ecs-cluster >> /etc/ecs/ecs.config
EOF
}

resource "aws_autoscaling_group" "nuvolari_cluster_instances" {
  availability_zones = "${var.zones}"
  name = "nuvolari-cluster-instances"
  min_size = 1
  max_size = 1
  launch_configuration = "${aws_launch_configuration.nuvolari_instance.name}"
}

resource "aws_ecs_task_definition" "pier_task" {
  family = "pier-task"
  container_definitions = <<EOF
    [{
      "name": "pier-task",
      "image": "jaramir/pier:latest",
      "memory": 300,
      "cpu": 10,
      "essential": true,
      "portMappings": [{
        "hostPort": 80,
        "containerPort": 3000
      }]
    }]
EOF
}

resource "aws_ecs_service" "pier_service" {
  name = "pier-service"
  cluster = "${aws_ecs_cluster.nuvolari_ecs_cluster.id}"
  task_definition = "${aws_ecs_task_definition.pier_task.arn}"
  desired_count = 1
}
