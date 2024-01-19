import logging
import azure.functions as func
from os import environ
from uuid import uuid4
from datetime import datetime
from azure.identity import DefaultAzureCredential
from json import dumps as json_dumps, loads as json_loads
from azure.storage.blob import BlobServiceClient, DelimitedJsonDialect


default_credential = DefaultAzureCredential()
sa = environ.get("SA", "varonisdatrestaurant2024")
sa_logging_container = environ.get(
    "SA_LOGGING_CONTAINER", "varonis-logging-container")
sa_restaurants_container = environ.get(
    "SA_RESTAURANTS_CONTAINER", "varonis-restaurants-container")
sa_restaurants_blob = environ.get("SA_RESTAURANTS_BLOB", "restaurants.json")
max_returned_results = environ.get("MAX_RETURNED_RESULTS", 5)
logging_client = BlobServiceClient(
    f"https://{sa}.blob.core.windows.net/",
    credential=default_credential
)
restaurants_client = BlobServiceClient(
    f"https://{sa}.blob.core.windows.net/",
    credential=default_credential
)


def log_request(function_request, function_response, at_time=datetime.now()):
    current_log_key = f"{at_time.strftime('%Y/%m/%d/%H%M%S')}-{uuid4().hex}"
    blob_client = logging_client.get_blob_client(
        container=sa_logging_container,
        blob=current_log_key
    )

    blob_client.upload_blob(
        data=json_dumps(
            {
                "request": function_request,
                "response": function_response
            }
        ),
        blob_type="BlockBlob"
    )


def generate_sql_expression(query_params, at_time=datetime.now()):
    # we can sanitize the input more thoroughly, however this
    # Azure Function will have read-only access to the restaurants
    # container, so it's not that crucial.

    expression_list = ["SELECT name, style, address, openHour, closeHour, vegetarian FROM BlobStorage[*].restaurants[*]"]  # noqa

    if query_params:
        for key, value in query_params.items():
            if key in ["name", "style", "address"]:
                expression_list.append(
                    f" {' WHERE' if len(expression_list) == 1 else ' AND'} \
                    LOWER({key}) = '{value.lower()}'")
            elif key == "vegetarian":
                requested_vegetarian = value in ["true", "1", "yes"]
                expression_list.append(
                    f" {' WHERE' if len(expression_list) == 1 else ' AND'} \
                    {key} = {'true' if requested_vegetarian else 'false'}")
            elif key == "open":
                # an integer hhmm (military time) UTC timezone
                current_time = int(at_time.strftime("%H%M"))
                requested_open = value in ["true", "1", "yes"]

                '''
                for some reason the NOT operator doesn't work (doesn't negate) a boolean expression
                in Blob Query using SQL, also (boolean expression) = true|false doesn't work.
                it worked with AWS S3 Select, but not with the Azure implementation.

                so I just wrote 2 expressions that are the opposites of each other (dumb but works),
                one for opened and one for closed restaurants.
                ''' # noqa
                expression_list.append(
                    f" {' WHERE' if len(expression_list) == 1 else ' AND'} \
                    {f'(({current_time} >= openHour AND {current_time} < closeHour) OR (openHour >= closeHour AND ({current_time} >= openHour OR {current_time} < closeHour)))' if requested_open else f'(({current_time} < openHour OR {current_time} >= closeHour) AND (openHour < closeHour OR ({current_time} < openHour AND {current_time} >= closeHour)))'}"  # noqa
                )
    expression_list.append(f" LIMIT {max_returned_results}")
    return "".join(expression_list)


def query_with_blob_query(sql_expression):
    matching_restaurants = []
    format = DelimitedJsonDialect()
    blob_client = restaurants_client.get_blob_client(
        container=sa_restaurants_container,
        blob=sa_restaurants_blob
    )

    query_results = blob_client.query_blob(
        sql_expression,
        blob_format=format,
        output_format=format
    )

    result_text = query_results.readall()
    if result_text:
        lines = result_text.splitlines()
        matching_restaurants = [json_loads(line.decode()) for line in lines]

    return matching_restaurants


def main(req: func.HttpRequest) -> func.HttpResponse:
    try:
        at_time = datetime.now()
        query_params = req.params if req.params else None
        sql_expression = generate_sql_expression(query_params, at_time=at_time)
        matching_restaurants = query_with_blob_query(sql_expression)

        function_response = {
            "restaurants": matching_restaurants,
            "total": len(matching_restaurants)
        }

        log_request(
            function_request={
                'method': req.method,
                'url': req.url,
                'headers': dict(req.headers),
                'params': dict(req.params),
                'get_body': req.get_body().decode()
            },
            function_response=function_response,
            at_time=at_time
        )
        return func.HttpResponse(json_dumps(function_response))
    except Exception as e:
        logging.error(e)
        return func.HttpResponse(body="something went wrong, try again soon.", status_code=500)  # noqa
