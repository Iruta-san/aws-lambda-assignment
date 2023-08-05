new_line = '\n'

def lambda_handler(event, context):
    try:
        # Check if the request contains exactly one query parameter named "i"
        if not event['queryStringParameters'] or len(event['queryStringParameters']) != 1 or 'i' not in event['queryStringParameters']:
            error_message = f"Invalid request.{new_line}The request should contain exactly one query parameter named 'i'.{new_line}I.e. '?i=15'{new_line}"
            return {
                "statusCode": 400,
                "headers": {
                    "Content-Type": "text/plain"
                },
                "body": error_message
            }

        input_number = int(event['queryStringParameters']['i'])
        result = input_number + 1

        return {
            "statusCode": 200,
            "headers": {
                "Content-Type": "text/plain"
            },
            "body": str(result)
        }
    except (ValueError, KeyError):
        # If "i" is not an integer or the query parameter is missing
        # Print all received query parameters in the error message
        error_message = f"Invalid request.{new_line}Query param should be an integer!{new_line}Received parameters: {event['queryStringParameters']}{new_line}"
        return {
            "statusCode": 400,
            "headers": {
                "Content-Type": "text/plain"
            },
            "body": error_message
        }