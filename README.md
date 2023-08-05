# Home Assignment: Creating a AWS Lambda function with IaC 

> **The exercise:**  
> 
> 1.  Create a free account in AWS
> 2.  Deploy a lambda that returns X+1 to the number you send as a parameter.
> 3.  Function should be accessible via rest call
> 
> Example: I send : GET 
> www.example.com/increase?i=10
> 
> Response: 11
> 
>   
> 
> **Guidelines:**
>  - Security is very important to us.   
> - Try to be mindful of cost.   
> - Use Terraform
> 
> **Super important**:
> - The environment should be fully automated and be built and torn down with a script.
> - Your repo should include some documentation 
> - The exercise should work out of the box without code tweaks according to the instructions you provided


## Prerequisites
The repository contains all the nessecary files to create and destroy the infrastructure to complete the assignment.

To run it one should have:
 - [The latest version of Terraform CLI](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
 - [The latest version of AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) installed and configured with a user, which should have enough permissions to manage AWS API Gateway and Lambda Function resources
 - Any REST client to run the function. I will provide example with `curl` in this documentation.
 
## Deploying the infrastructure
The code works out-of-the-box and does not require any changes, provided that the user has completed all the prerequisites.
However, there are a few customizable parameters, which can be viewed in the file `inputs.tfvars.example`
Note, that there's no sensitive parameters in the file.
To configure the parameters, rename `inputs.tfvars.example` to `inputs.tfvars` and change them as nessecary.

To deploy the infrastructure clone this repository, navigate to its location and execute following:

    terraform init
    terraform plan

And after making sure that the plan looks good, execute

    terraform apply

When asked for confirmation, type `yes`

On completion we receive two outputs: `api_key` which is sensitive and is not displayed by default, and `invoke_url_default` - URL and path, where the function is available.

That completes the infrastructure deployment.

## Running the Lambda function
As one of the guidelines was about importancy of security, the created API was secured by API key. The API key is generated on executing `terraform apply` and is not changed until its destruction.

So to use the function with `curl` tool, the API key should be specified in the header, for example:
`curl --header "x-api-key:dl0bRWR5" https://061l7.execute-api.us-east-2.amazonaws.com/increase?i=10`

The API key is stored as sensitive output and could be accessed with the command
`terraform output -raw api_key`

There is a shell-script in the repository named `get_curl.sh`
It gets values from terraform outputs and creates ready-to-use command.

    $ ./get_curl.sh
    Use this command to test the API
    curl --header "x-api-key:dlWR5" https://06l7.execute-api.us-east-2.amazonaws.com/increase

Supply a parameter to the script to generate the URL with query parameters

    $ ./get_curl.sh 22
    Use this command to test the API
    curl --header "x-api-key:dlWR5" https://06l7.execute-api.us-east-2.amazonaws.com/increase?i=22

Copy-paste and execute the resulting command to see if Lambda function is available and working

    $ curl --header "x-api-key:dlRWR5" https://06l7.execute-api.us-east-2.amazonaws.com/increase?i=11
    12
The function also checks if input data is correct - there should be only one query parameter `i` with integer value

## Security and costs
As was mentioned before, the API is protected with API key. That provides very basic security, which should be enough for this assignment - the API can be called without setting up a separate IAM account, yet is not publicly available without a key.

To mind the cost I've created a usage plan for the API with decreased quotas and rate limits