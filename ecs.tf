# ecs.tf

resource "aws_ecs_cluster" "main" {
  name = "IM_cluster"
}


resource "aws_ecs_service" "bar" {
  name             = "IM_service" 
  enable_execute_command = true
  cluster          = aws_ecs_cluster.main.id
  task_definition  = aws_ecs_task_definition.efs-task.arn
  desired_count    = 1
  launch_type      = "FARGATE"
  platform_version = "1.4.0" //not specfying this version explictly will not currently work for mounting EFS to Fargate
  
  network_configuration {
    security_groups  = [aws_security_group.ecs.id]
    subnets          = [aws_subnet.public.id]
    assign_public_ip = true
  } 

  load_balancer {
    target_group_arn = aws_alb_target_group.frontend_tg.id
    container_name   = "web"
    container_port   = 3000
  }

 depends_on = [aws_iam_role_policy_attachment.ecs_task_execution_role]
}

resource "aws_ecs_task_definition" "efs-task" {
  family                   = "IM_fargate-task" 
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "2048"
  memory                   = "4096"

  container_definitions = <<DEFINITION
[
  

  {
      
      "portMappings": [
          {
              "hostPort": 3000,
              "containerPort": 3000,
              "protocol": "tcp"
          }
      ],
      "essential": true,
      "name": "web",
      "image": "837630247226.dkr.ecr.us-east-1.amazonaws.com/imsurvey:sidekiq", 
      "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-region" : "${var.aws_region}",
                    "awslogs-create-group" : "true",
                    "awslogs-group" : "IM_web",
                    "awslogs-stream-prefix" : "web"
                }
            },
      "containerDependsOn": [{"containerName": "redis"}], 
      "environment": [ 
            {"name": "DB_HOST", "value": "${aws_db_instance.default.address}"},
            {"name": "DB_NAME", "value": "${var.postgres_DB_NAME}"},
            {"name": "DB_USER", "value": "${var.postgres_DB_USER}"},
            {"name": "DB_PASSWORD", "value": "${var.postgres_DB_PASSWORD}"}, 
            {"name": "REDIS_URL_SIDEKIQ", "value": "${var.REDIS_URL_SIDEKIQ}"}
		    ],
      "command": [
        "bash",
        "-c",
        "rm -f tmp/pids/server.pid && bundle exec rails s -p 3000 -b '0.0.0.0'"
      ]
      
      
  },
  {   "portMappings": [
          {
              "hostPort": 6379,
              "containerPort": 6379,
              "protocol": "tcp"
          }
      ],
      "essential": true,
      "name": "redis",
      "image": "837630247226.dkr.ecr.us-east-1.amazonaws.com/imsurvey:latest",
      "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-region" : "${var.aws_region}",
                    "awslogs-create-group" : "true",
                    "awslogs-group" : "IM_redis",
                    "awslogs-stream-prefix" : "redis"
                }
            },
      "command": [ "redis-server", "/usr/local/etc/redis/redis.conf" ]
  }, {
      "essential": true,
      "name": "sidekiq",
      "image": "837630247226.dkr.ecr.us-east-1.amazonaws.com/imsurvey:sidekiq", 
      "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-region" : "${var.aws_region}",
                    "awslogs-create-group" : "true",
                    "awslogs-group" : "IM_sidekiq",
                    "awslogs-stream-prefix" : "sidekiq"
                }
            },
      "containerDependsOn": [{"containerName": "redis"}], 
      "environment": [ 
            {"name": "DB_HOST", "value": "${aws_db_instance.default.address}"},
            {"name": "DB_NAME", "value": "${var.postgres_DB_NAME}"},
            {"name": "DB_USER", "value": "${var.postgres_DB_USER}"},
            {"name": "DB_PASSWORD", "value": "${var.postgres_DB_PASSWORD}"}, 
            {"name": "REDIS_URL_SIDEKIQ", "value": "${var.REDIS_URL_SIDEKIQ}"}
		    ],
      "command": ["bundle", "exec", "sidekiq"]
  }, {
      "portMappings": [
          {
              "hostPort": 3001,
              "containerPort": 3001,
              "protocol": "tcp"
          }
      ],
      "essential": true,
      "name": "frontend",
      "image": "837630247226.dkr.ecr.us-east-1.amazonaws.com/imsurvey:frontend", 
      "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-region" : "${var.aws_region}",
                    "awslogs-create-group" : "true",
                    "awslogs-group" : "IM_frontend",
                    "awslogs-stream-prefix" : "frontend"
                }
            },
      "containerDependsOn": [{"containerName": "web"}],
      "environment": [ 
            {"name": "PORT", "value": "3001"},
            {"name": "REACT_APP_API_BASE_URL", "value": "${var.REACT_APP_API_BASE_URL}"}
            
        ],
      "command": ["yarn", "start"]
  }
  
]
DEFINITION

depends_on = [aws_db_instance.default]

}
