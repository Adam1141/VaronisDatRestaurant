# DatRestaurant

## Serverless API to query restaurants

![Design overview](./overview.png?raw=true 'Design overview')

API endpoint: https://7hbesjy6xi.execute-api.us-east-1.amazonaws.com/restaurants

## Setup

To run locally, a few changes would have to be made:

<ol>
  <li>comment out the remote s3 backend block in tf/providers.tf </li>
  <li>configure AWS credentials either with <em>aws cli</em> or export IAM credentials as environment variables
    <ul>
      <li>using aws cli run <strong>aws configure</strong></li>
      <li>using environment variables export both <strong>AWS_ACCESS_KEY_ID</strong> and <strong>AWS_SECRET_ACCESS_KEY</strong></li>      
    </ul>
  </li>
  <li>since S3 bucket names are globally unique and DynamoDB table names are regionally unique you would have change some Terraform variable values
    <ul>
      <li><strong>logging_s3_bucket_name</strong></li>
      <li><strong>restaurants_s3_bucket_name</strong></li>
      <li><strong>s3_terraform_state_bucket_name</strong> or feel free to delete tf/s3_backend.tf</li>
      <li><strong>dynamodb_state_locking_name</strong> or feel free to delete tf/s3_backend.tf</li>
    </ul>
  </li>
  <li>initialize and apply
    <ul>
      <li>cd ./tf</li>
      <li>terraform init</li>
      <li>terraform apply -auto-approve</li>      
    </ul>
  </li>
  <li>to view the API endpoint, run <strong>terraform output api_endpoint</strong></li>
</ol>

## Usage

### available filters:
<strong>boolean filter</strong> truthy values are "yes", "true" and "1", everything else is false
<ul>
  <li>case-insensitive partial text search on:
    <ul>
      <li>name</li>
      <li>style</li>
      <li>address</li>
    </ul>
  </li>
  <li>boolean filter on:
    <ul>
      <li>vegetarian</li>
      <li>open</li>
    </ul>
  </li>
</ul>

pass filters as query params such as, GET /restaurants?name=a&style=b&address=c

## Examples

```
curl --silent 'https://7hbesjy6xi.execute-api.us-east-1.amazonaws.com/restaurants?vegetarian=no&style=italian&open=yes' | jq
{
  "restaurants": [
    {
      "name": "Pizza Hut",
      "style": "Italian",
      "address": "Tel Aviv, 23st",
      "openHour": 1000,
      "closeHour": 2300,
      "vegetarian": false
    },
    {
      "name": "Pizza Hut 2",
      "style": "Italian",
      "address": "Tel Aviv, 23st",
      "openHour": 1000,
      "closeHour": 2300,
      "vegetarian": false
    }
  ],
  "total": 2
}
```

```
curl --silent 'https://7hbesjy6xi.execute-api.us-east-1.amazonaws.com/restaurants?vegetarian=yes&open=false' | jq
{
  "restaurants": [
    {
      "name": "Hummus King",
      "style": "Israeli",
      "address": "Tel Aviv, 27st",
      "openHour": 300,
      "closeHour": 1240,
      "vegetarian": true
    },
    {
      "name": "Hummus King 2",
      "style": "Israeli",
      "address": "Tel Aviv, 27st",
      "openHour": 300,
      "closeHour": 1240,
      "vegetarian": true
    }
  ],
  "total": 2
}

```
