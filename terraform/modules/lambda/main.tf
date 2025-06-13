variable "stage" { type = string }
variable "func_name" { type = string }
variable "env_vars" { type = map(string) }

data "archive_file" "func_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../../../src/functions/${var.func_name}"
  output_path = "${path.module}/../../../dist/${var.func_name}.zip"
  excludes    = ["tests/**", "*.pyc", "__pycache__/**"]
}

resource "aws_lambda_layer_version" "shared" {
  filename            = "${path.module}/../../../dist/shared_layer.zip"
  layer_name          = "shared-${var.stage}"
  compatible_runtimes = ["python3.12"]

  # 変更検知用ハッシュもファイルから
  source_code_hash    = filebase64sha256("${path.module}/../../../dist/shared_layer.zip")
}
resource "aws_iam_role" "lambda_exec" {
  name = "${var.stage}-${var.func_name}-exec"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement : [{
      Action : "sts:AssumeRole",
      Effect : "Allow",
      Principal : { Service : "lambda.amazonaws.com" }
    }]
  })
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]
}

resource "aws_lambda_function" "this" {
  function_name    = "${var.stage}-${var.func_name}"
  filename         = data.archive_file.func_zip.output_path
  handler          = "handler.lambda_handler"
  runtime          = "python3.12"
  role             = aws_iam_role.lambda_exec.arn
  layers           = [aws_lambda_layer_version.shared.arn]
  source_code_hash = data.archive_file.func_zip.output_base64sha256
  environment {
    variables = var.env_vars
  }
}

output "function_name" { value = aws_lambda_function.this.function_name }
