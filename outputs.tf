output "invoke_url_default" {
  value = aws_api_gateway_stage.lambda.invoke_url
}

output "api_key" {
  value = aws_api_gateway_api_key.lambda_api_key.value
  sensitive = true
}