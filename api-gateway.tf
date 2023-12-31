resource "aws_api_gateway_rest_api" "lambda" {
  name        = "${var.name}-api"
  description = "API for AWS Lambda"
  tags        = var.tags
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  disable_execute_api_endpoint = false
}

resource "aws_api_gateway_method" "lambda" {
  authorization = "NONE"
  http_method   = "GET"
  api_key_required = true
  resource_id   = aws_api_gateway_rest_api.lambda.root_resource_id
  rest_api_id   = aws_api_gateway_rest_api.lambda.id
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id             = aws_api_gateway_rest_api.lambda.id
  resource_id             = aws_api_gateway_rest_api.lambda.root_resource_id
  http_method             = aws_api_gateway_method.lambda.http_method
  integration_http_method = "POST" #  Lambda function can only be invoked via POST
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.increase_int.invoke_arn
  content_handling        = "CONVERT_TO_TEXT"
}

resource "aws_api_gateway_method_response" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.lambda.id
  resource_id = aws_api_gateway_rest_api.lambda.root_resource_id
  http_method = aws_api_gateway_method.lambda.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.lambda.id
  resource_id = aws_api_gateway_rest_api.lambda.root_resource_id
  http_method = aws_api_gateway_method.lambda.http_method
  status_code = aws_api_gateway_method_response.lambda.status_code
  depends_on  = [aws_api_gateway_integration.lambda]
}


resource "aws_lambda_permission" "lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.increase_int.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.lambda.execution_arn}/*"
}

resource "aws_api_gateway_deployment" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.lambda.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_method.lambda.id,
      aws_api_gateway_integration.lambda.id,
      aws_api_gateway_method_response.lambda,
      aws_api_gateway_integration_response.lambda,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "lambda" {
  deployment_id = aws_api_gateway_deployment.lambda.id
  rest_api_id   = aws_api_gateway_rest_api.lambda.id
  stage_name    = "increase"
  tags          = var.tags
}

# Add API Key to protect our lambda function
resource "aws_api_gateway_api_key" "lambda_api_key" {
  name = "LambdaApiKey"
}

resource "aws_api_gateway_usage_plan" "lambda_usage_plan" {
  name        = "LambdaFuncUsagePlan"
  description = "Define ratelimits and throttle settings to our function, so we won't waste resources if something goes bad"

  quota_settings {
    limit  = var.quota_limit     # By default 1000 requests per day is sure more than enough in our case
    offset = var.quota_offset    # By default reset the quota every day
    period = var.quota_period
  }
  throttle_settings {
    burst_limit = var.throttle_burst     # Default: 5
    rate_limit  = var.throttle_ratelimit # Default: 2
  }

  api_stages {
    api_id     = aws_api_gateway_rest_api.lambda.id
    stage      = aws_api_gateway_stage.lambda.stage_name
  }
}

# Assosiate our API key with the plan
resource "aws_api_gateway_usage_plan_key" "lambda_usage_plan_key" {
  key_id        = aws_api_gateway_api_key.lambda_api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.lambda_usage_plan.id
}
