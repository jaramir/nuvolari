resource "aws_ecs_cluster" "nuvolari_ecs_cluster" {
  name = "nuvolari-ecs-cluster"
}

resource "aws_launch_configuration" "nuvolari_instance" {
  name_prefix = "nuvolari-instance-"
  instance_type = "t2.micro"
  image_id = "ami-b2df2ca4"
  iam_instance_profile = "ecsInstanceRole"
  user_data = <<EOF
#!/bin/bash
echo ECS_CLUSTER=nuvolari-ecs-cluster >> /etc/ecs/ecs.config
EOF
}

resource "aws_autoscaling_group" "nuvolari_cluster_instances" {
  availability_zones = ["us-east-1a"]
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
