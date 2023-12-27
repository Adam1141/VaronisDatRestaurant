# DatRestaurant

## Serverless API to query restaurants

![Design overview](./overview.png?raw=true 'Design overview')

API endpoint: https://7hbesjy6xi.execute-api.us-east-1.amazonaws.com/restaurants

## Setup

### Requirements
<ol>
  <li>Terraform CLI (~> v1.6.6)</li>
  <li>AWS access tokens</li>
</ol>
To run locally, a few changes would have to be made (inside tf/ directory):

<ol>
  <li>comment out the remote s3 backend block in tf/providers.tf, tf/s3_backend.tf and outputs.tf using:<br/>
    <code> sed -i -e '/backend "s3" {/,/}/ s/^/# /' providers.tf</code><br/>
    <code> sed -i -e 's/^/# /' -e 's/^# # /# /' s3_backend.tf </code><br/>
    <code>sed -i -e '/output "s3_tf_state_bucket" {/,/}/ s/^/# /' -e '/output "dynamodb_state_locking_table_name" {/,/}/ s/^/# /' outputs.tf</code>
   </li>
  <li>configure AWS credentials either with <em>aws cli</em> or export IAM credentials as environment variables
    <ul>
      <li>using aws cli run <strong>aws configure</strong> and follow the instructions</li>
      <li>using environment variables export both <strong>AWS_ACCESS_KEY_ID</strong> and <strong>AWS_SECRET_ACCESS_KEY</strong>
        <br/><code>
export AWS_ACCESS_KEY_ID=&lt;SECRET&gt;

export AWS_SECRET_ACCESS_KEY=&lt;SECRET&gt; </code> </li> </ul>

  </li>
  <li>since S3 bucket names are globally unique you would have to specify different names for:
    <ul>
      <li><strong>logging_s3_bucket_name</strong></li>
      <li><strong>restaurants_s3_bucket_name</strong></li>
    </ul>
    you could do that with:<br/>
    <code> current_timestamp=$(date +%s) </code><br/>
    <code>export TF_VAR_logging_s3_bucket_name=varonis-restaurants-s3-logging-$current_timestamp</code><br/>
    <code>export TF_VAR_restaurants_s3_bucket_name=varonis-restaurants-s3-restaurants-$current_timestamp</code></br>
    </code>
  </li>
  <li>initialize and apply using:<br/>
    <code>
      terraform init && terraform apply -auto-approve
    </code>
  </li>
  <li>view the API endpoint using:<br/>
    <code>
    terraform output api_endpoint
    </code>
  </li>
  <li>to destroy everything when done, use::<br/>
    <code>
    terraform destroy -auto-approve
    </code>
  </li>
</ol>

## Usage

### available filters:

<strong>boolean filter</strong> truthy values are "yes", "true" and "1",
everything else is false

<ul>
  <li>boolean filter on:
    <ul>
      <li>vegetarian</li>
      <li>open</li>
    </ul>
  </li>
  <li>case-insensitive partial text search on:
    <ul>
      <li>name</li>
      <li>style</li>
      <li>address</li>
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
