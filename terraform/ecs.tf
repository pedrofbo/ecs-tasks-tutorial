# Create an ECS cluster to run tasks
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs-tasks-tutorial"
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
  family = "ecs-tasks-tutorial"
  container_definitions = jsonencode(
    [
      {
        name  = "ecs-tasks-tutorial"
        image = "${local.account_id}.dkr.ecr.${var.region}.amazonaws.com/ecs-tasks-tutorial:latest"
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
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.tasks_execution_role.arn
}
