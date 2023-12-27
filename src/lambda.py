from uuid import uuid4
from os import environ
from datetime import datetime
from boto3 import client as boto3_client
from json import dumps as json_dumps, loads as json_loads


s3_logging_bucket = environ.get(
    "S3_LOGGING_BUCKET", "varonis-logging-bucket-20231225")
s3_restaurants_bucket = environ.get(
    "S3_RESTAURANTS_BUCKET", "varonis-retaurants-20231225")
s3_restaurants_key = environ.get("S3_RESTAURANTS_KEY", "restaurants.json")
max_returned_results = environ.get("MAX_RETURNED_RESULTS", 5)
client = boto3_client('s3')


def log_request(lambda_request, lambda_response, at_time=datetime.now()):
    current_log_key = f"{at_time.strftime('%Y/%m/%d/%H%M%S')}-{uuid4().hex}"
    client.put_object(
        Bucket=s3_logging_bucket,
        ContentType="application/json",
        Key=current_log_key,
        Body=json_dumps(
            {
                "request": lambda_request,
                "response": lambda_response
            }
        )
    )


def generate_sql_expression(query_params, at_time=datetime.now()):
    # we can sanitize the input more thoroughly, however this Lambda function
    # will have read-only access to the S3 bucket, so it's not that crucial.

    expression_list = ["SELECT * FROM S3Object[*].restaurants[*] s"]

    if query_params:
        for key, value in query_params.items():
            if key in ["name", "style", "address"]:
                expression_list.append(
                    f" {' WHERE' if len(expression_list) == 1 else ' AND'} \
                    LOWER(s.{key}) like '%{value.lower()}%'")
            elif key == "vegetarian":
                requested_vegetarian = value in ["true", "1", "yes"]
                expression_list.append(
                    f" {' WHERE' if len(expression_list) == 1 else ' AND'} \
                    s.{key} = {'true' if requested_vegetarian else 'false'}")
            elif key == "open":
                # an integer hhmm (military time) UTC timezone
                current_time = int(at_time.strftime("%H%M"))
                requested_open = value in ["true", "1", "yes"]
                expression_list.append(
                    f" {' WHERE' if len(expression_list) == 1 else ' AND'} \
                    {'' if requested_open else 'NOT '} (({current_time} >= s.openHour \
                    AND {current_time} < s.closeHour) OR (s.openHour >= s.closeHour AND \
                    ({current_time} >= s.openHour OR {current_time} < s.closeHour)))"  # noqa
                )
    expression_list.append(f" LIMIT {max_returned_results}")
    return "".join(expression_list)


def query_with_s3_select(sql_expression):
    matching_restaurants = []

    # query and filter restaurants from S3 object using S3 Select feature
    response = client.select_object_content(
        Bucket=s3_restaurants_bucket,
        Key=s3_restaurants_key,
        ExpressionType='SQL',
        Expression=sql_expression,
        InputSerialization={'JSON': {"Type": "DOCUMENT"}},
        OutputSerialization={'JSON': {}}
    )

    # process S3 Select response
    for event in response['Payload']:
        if 'Records' in event:
            records = event['Records']['Payload'].decode('utf-8')
            matching_restaurants = [json_loads(
                record) for record in records.strip().split('\n')]

    return matching_restaurants


def lambda_handler(event, context):
    at_time = datetime.now()
    query_params = event['queryStringParameters'] if 'queryStringParameters' \
        in event and event['queryStringParameters'] is not None else None
    sql_expression = generate_sql_expression(query_params, at_time=at_time)
    matching_restaurants = query_with_s3_select(sql_expression)

    lambda_response = {
        "restaurants": matching_restaurants,
        "total": len(matching_restaurants)
    }

    log_request(lambda_request=event,
                lambda_response=lambda_response, at_time=at_time)

    return lambda_response
