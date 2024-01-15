# DatRestaurant

## Serverless API to query restaurants

![Design overview](./overview.png?raw=true 'Design overview')



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
  <li>case-insensitive text search on:
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
      "name": "Hummus King 2",
      "style": "Israeli",
      "address": "Tel Aviv, 27st",
      "openHour": 2000,
      "closeHour": 800,
      "vegetarian": true
    }
  ],
  "total": 1
}
```
