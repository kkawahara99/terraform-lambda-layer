import json
from mylib import validators

def lambda_handler(event, context):
    try:
        validators.validate_request(event)
    except ValueError as err:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": str(err)})
        }
    return {
        "statusCode": 200,
        "body": json.dumps({"message": "Account request accepted!", "input": event})
    }
