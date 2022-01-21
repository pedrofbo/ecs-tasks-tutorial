# Create an ECS cluster to run tasks
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs-fargate-test-1"
  tags                     = {
    "project" = "fargate_test_1"
  }
}

resource "aws_ecs_cluster" "ecs_cluster_2" {
  name = "ecs-fargate-test-2"
  tags                     = {
    "project" = "fargate_test_2"
  }
}
resource "aws_ecs_cluster" "ecs_cluster_3" {
  name = "ecs-fargate-test-3"
  tags                     = {
    "project" = "fargate_test_3"
  }
}
resource "aws_ecs_cluster" "ecs_cluster_4" {
  name = "ecs-fargate-test-4"
  tags                     = {
    "project" = "fargate_test_4"
  }
}

# Create an IAM role for task execution to assume
resource "aws_iam_role" "tasks_execution_role" {
  name = "ecs-tasks-tutorial-execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}
resource "aws_iam_role_policy_attachment" "sto-readonly-role-policy-attach" {
  role       = aws_iam_role.tasks_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Create task definition
resource "aws_ecs_task_definition" "ecs_task" {
  family = "ecs-fargate-test-1"
  container_definitions = jsonencode(
    [
      {
        name  = "ecs-fargate-test-1"
        image = "${local.account_id}.dkr.ecr.${var.region}.amazonaws.com/ecs-fargate-test:latest"
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = aws_cloudwatch_log_group.ecs_tasks_log_group.name
            awslogs-region        = var.region
            awslogs-stream-prefix = "tasks"
          }
        }
      }
    ]
  )
  cpu                      = "512"
  memory                   = "1024"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.tasks_execution_role.arn
  tags                     = {
    "project" = "fargate_test_1"
  }
}

resource "aws_ecs_task_definition" "ecs_task_2" {
  family = "ecs-fargate-test-2"
  container_definitions = jsonencode(
    [
      {
        name  = "ecs-fargate-test-2"
        image = "${local.account_id}.dkr.ecr.${var.region}.amazonaws.com/ecs-fargate-test:latest"
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = aws_cloudwatch_log_group.ecs_tasks_log_group.name
            awslogs-region        = var.region
            awslogs-stream-prefix = "tasks"
          }
        }
      }
    ]
  )
  cpu                      = "512"
  memory                   = "1024"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.tasks_execution_role.arn
  tags                     = {
    "project" = "fargate_test_2"
  }
}
resource "aws_ecs_task_definition" "ecs_task_3" {
  family = "ecs-fargate-test-3"
  container_definitions = jsonencode(
    [
      {
        name  = "ecs-fargate-test-3"
        image = "${local.account_id}.dkr.ecr.${var.region}.amazonaws.com/ecs-fargate-test:latest"
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = aws_cloudwatch_log_group.ecs_tasks_log_group.name
            awslogs-region        = var.region
            awslogs-stream-prefix = "tasks"
          }
        }
      }
    ]
  )
  cpu                      = "512"
  memory                   = "1024"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.tasks_execution_role.arn
  tags                     = {
    "project" = "fargate_test_3"
  }
}
resource "aws_ecs_task_definition" "ecs_task_4" {
  family = "ecs-fargate-test-4"
  container_definitions = jsonencode(
    [
      {
        name  = "ecs-fargate-test-4"
        image = "${local.account_id}.dkr.ecr.${var.region}.amazonaws.com/ecs-fargate-test:latest"
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = aws_cloudwatch_log_group.ecs_tasks_log_group.name
            awslogs-region        = var.region
            awslogs-stream-prefix = "tasks"
          }
        }
      }
    ]
  )
  cpu                      = "1024"
  memory                   = "2048"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.tasks_execution_role.arn
  tags                     = {
    "project" = "fargate_test_4"
  }
}
