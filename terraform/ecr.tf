# Create an ECR repository to store our application images
resource "aws_ecr_repository" "ecr_repo" {
  name = "ecs-fargate-test"
}
