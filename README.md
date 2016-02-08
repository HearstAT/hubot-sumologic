# hubot-sumologic
[![NPM version][npm-image]][npm-url] [![Build Status][travis-image]][travis-url] [![Coverage Status][coveralls-image]][coveralls-url]

Sumologic integration for Hubot

See [`src/sumologic.coffee`](src/sumologic.coffee) for full documentation.

## Installation

In hubot project repo, run:

`npm install hubot-sumologic --save`

Then add **hubot-sumologic** to your `external-scripts.json`:

```json
["hubot-sumologic"]
```

## Configuration

`sumologic` requires a bit of configuration to get everything working:

* HUBOT_SUMOLOGIC_API_URL - One of the URL's listed here: https://github.com/SumoLogic/sumo-api-doc/wiki
* HUBOT_SUMOLOGIC_UI_URL - One of the URL's listed here: https://github.com/SumoLogic/sumo-api-doc/wiki
* HUBOT_SUMOLOGIC_ACCESS_ID - https://service.sumologic.com/help/Generating_Collector_Installation_API_Keys.htm
* HUBOT_SUMOLOGIC_ACCESS_KEY - https://service.sumologic.com/help/Generating_Collector_Installation_API_Keys.htm

## Example Interaction

URL Link to the UI

```
user1>> hubot sumo ui url
hubot>> https://service.sumologic.com
```

List of dashboards

```
user1>> hubot sumo dashboards
hubot>> ID: 1234567, Name: Nginx - Visitor Locations 
ID: 1234568, Name: Linux Login Status 
ID: 1234569, Name: Nginx - Visitor Traffic Insight
...
```

Data in specific dashboards

```
user1>> hubot sumo dashboard 1234567 data
hubot>> | count | client_ip | 
| 8619 | 10.0.0.1 |
| 9 | 10.0.0.2 |

**log_level** **count**  
ID: 7654321 no results 

**message** **count**  
ID: 7654322 no results 

**bot_name** **count**  
ID: 7654323 no results 

| count | url | 
| 8619 | /rest/something/failing/alot/json |
| 2 | /favicon.ico |
 
| status_code | count | 
| 404 | 8621 |
| 302 | 882 |
| 304 | 49 |
| 401 | 7 |
...
```

Count of a occurence of a specific query

```
user1>> hubot sumo search count error
hubot>> Count 100, Category: linux_apps_logs, Host: example-host1.com
        Count 10, Category: docker/local/json, Host: example-host2.com
```

Count of a occurence of a specific query

```
user1>> hubot sumo search count error last 30
hubot>> Count 50, Category: linux_apps_logs, Host: example-host1.com
        Count 5, Category: docker/local/json, Host: example-host2.com
```

## Resources

* https://service.sumologic.com/help/Generating_Collector_Installation_API_Keys.htm
* https://github.com/SumoLogic/sumo-api-doc/wiki
