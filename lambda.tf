# --- IAM Role ---

resource "aws_iam_role" "lambda" {
  name = "lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# --- Lambda ---

resource "aws_cloudwatch_log_group" "api" {
  name              = "/aws/lambda/api"
  retention_in_days = 14
}

resource "aws_lambda_function" "api" {
  function_name    = "api"
  role             = aws_iam_role.lambda.arn
  image_uri        = "${aws_ecr_repository.api.repository_url}:latest"
  package_type     = "Image"
  source_code_hash = trimprefix(data.aws_ecr_image.latest.id, "sha256:")
  timeout          = 10

  environment {
    variables = {}
  }

  depends_on = [
    null_resource.image,
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.api,
  ]
}