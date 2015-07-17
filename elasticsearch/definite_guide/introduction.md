#1 Introduction

Elasticsearch is an open-source _search engine_ built on top of [Apache Lucene™](https://lucene.apache.org/core/), a full-text search-engine library.

But Lucene is a Java library, which means to work with it, user has to use Java to integrate Lucene directly with the application. Also Lucene is very complex.

Elasticsearch, which is also written in Java, uses Lucene for all of its indexing and searching, but it provide a Restful API to hide the complexities of Lucene and make it able for any other programming language to integrate with Lucene for full-text search.

However, Elasticsearch is more that _just_ Lucene wrapper. It can also be described as:

  - A **distributed real-time document store** where **every field** is indexed and searchable.

  - A **distributed search engine** with **real-time analytics**

  - Capable of scaling to hundreds of servers and petabytes of structured and unstructured data

Elasticsearch packages up all this functionality into a standalone server with a simple Restful API of other web client to interact with.

##1.1 Installing Elasticsearch

**Requirement**:

Elasticsearch require Java to run (since it is written in Java).

**Download and install**:

Latest version of Elasticsearch can be downloaded from [elasticsearch.org/download](http://www.elasticsearch.org/download/)

```
curl -L -O http://download.elasticsearch.org/PATH/TO/VERSION.zip
unzip elasticsearch-$VERSION.zip
cd  elasticsearch-$VERSION
```

> When installing Elasticsearch in production, either use the above method or use the Debian or RPM packages provided on the [downloads page](http://www.elasticsearch.org/download/).

Refer to this [tutorial](https://www.digitalocean.com/community/tutorials/how-to-install-elasticsearch-on-an-ubuntu-vps) for deploying elasticsearch on Ubuntu vps.

**Installing Marvel**

[Marvel](http://www.elasticsearch.com/products/marvel) is a management and monitoring tool for Elasticsearch. It has an interactive console called **Sense**, which can easy talk to Elasticsearch directly from the browser.

Marvel is available as a plug-in. To download and install it, run this command in the Elasticsearch directory:

    ./bin/plugin -i elasticsearch/marvel/latest

Disable data collection on local cluster:

    echo 'marvel.agent.enabled: false' >> ./config/elasticsearch.yml

##1.2 Running Elasticsearch

Elasticsearch can run with:

    ./bin/elasticsearch

in the foreground and add `-d`:

    ./bin/elasticsearch -d

to run it in the background as a daemon.

Test it with:

    curl 'http://localhost:9200/?pretty'

Example respond:

```
{
  "status" : 200,
  "name" : "Bora",
  "cluster_name" : "elasticsearch",
  "version" : {
    "number" : "1.7.0",
    "build_hash" : "929b9739cae115e73c346cb5f9a6f24ba735a743",
    "build_timestamp" : "2015-07-16T14:31:07Z",
    "build_snapshot" : false,
    "lucene_version" : "4.10.4"
  },
  "tagline" : "You Know, for Search"
}
```

This mean the Elasticsearch _cluster_ is up and running.

> A **node** is a running instance of Elasticsearch. A **cluster** is a **group of nodes** with the same `cluster_name` that are working together to share data and to provide failover and scale. Single node can form a cluster by itself.

Because elasticsearch's nodes will try to join another cluster _on the same network_(LAN) with the same `cluster_name`, the default `cluster_name` should be changed. It can be edited in the `elasticsearch.yml` in `config/` directory or `/etc/elasticsearch` directory.

Elasticsearch can be shutdown through `shutdown` API:

    curl -XPOST 'http://localhost:9200/_shutdown'

**Viewing Marvel and Sense**

If Marvel is installed, it can be viewed in a web browser by visiting:

    http://localhost:9200/_plugin/marvel/

Sense developer console can be reached by either clicking the Marvel Dashboards drop-down in Marvel, or by visiting:

    http://localhost:9200/_plugin/marvel/sense/

##1.3 Talking to Elasticsearch

There are two ways to talk to Elasticsearch. First, using JavaAPI for elasticsearch. For more information about the Java client, read the elasticsearch [Guide](http://www.elasticsearch.org/guide/)

The second way is using Restful API with JSON over HTTP.

All other languages can communicate with Elasticsearch over port 9200 using a RESTful API.

> Elasticsearch provides official clients for several languages - Groovy, JavaScript, .NET, PHP, Perl, Python, and Ruby - all of which can be found in the [Guide](http://www.elasticsearch.org/guide/)

A Elasticsearch's request can be described like so:

    'http(s)://<HOST>/<PATH>?<QUERY_STRING>' -d '<BODY>`

with:

|Term|Definition|
|:-----|:-----|
|HOST|The hostname of any node in Elasticsearch cluster, or `localhost` for a node on local machine|
|PORT|The port running the Elasticsearch HTTP service, which defaults to `9200`|
|QUERY_STRING|Any optional query-string parameters (for example `?pretty` will pretty-print the JSON)|
|BODY|A JSON-encoded request body (if the request needs one - POST request)|

Example: Count number of documents in the cluster

    curl -XGET 'http://localhost:9200/_count?pretty' -d '{"query": {"match_all": {}}}'

Elasticsearch returns an HTTP status code like `200 OK` and (except for `HEAD` requests) a JSON-encoded response body. The respond for the above curl request:

```json
{
  "count" : 0,
  "_shards" : {
    "total" : 0,
    "successful" : 0,
    "failed" : 0
  }
}
```

##1.4 Document Oriented

Elasticsearch is _document oriented_, meaning that it **stores entire objects or _documents_**. It also **indexes the contents of each document** in order to make them searchable. Elasticsearch indexes, searches, sorts and filters documents - not rows of columnar data.

**JSON**

Elasticsearch uses JSON as the serialization format for documents.

##1.5 Simple tutorial: Employee Directory

Requirements:

  - Enable data to contain multi value tags, numbers, and full text

  - Retrieve the full details of any employee

  - Allow structured search (finding employees whose age > 30)

  - Return highlighted search snippets from the text in the matching documents

  - Enable management to build analytic dashboards over the data

###1.5.1 Indexing Employee Documents

The first order is storing employee data. The act of **storing data in Elasticsearch** is **called _indexing_**.

Each record (employee) is represented by a single _document_. A document belongs to a type and those types live inside an _index_. The Elasticsearch hierarchy can be represented like so:

    Elasticsearch  =>  Indices    =>  Types   =>  Documents  =>  Fields
    Relational DB  =>  Databases  =>  Tables  =>  Rows       =>  Columns

An Elasticsearch cluster can contain multiple _indices_ which in turn contain multiple _types_ (tables). These types hold multiple _documents_, and each document has multiple _fields_

In Elasticsearch, index can mean many things:

  - Index (noun): _index_ is like a database in a traditional relational DB. It's place to store related documents. Indices is its plural.

  - Index (verb): This mean storing the document in an index (DB) so it can be retrieved and queried. If the document already exists, the new document will replace the old one.

  - [Inverted index](): Every field in a document is _indexed_ (has an inverted index) and thus is searchable. A field without an inverted index is not searchable.

The hierarchy for this employee example will be as follow:

  - Each employee data will be stored in a document which has the **type** `employee`.

  - `employee` type will live in the `megacorp` index.

  - Of course `megacorp` index live in Elasticsearch cluster.

These actions can be performed in a single command:

```bash
curl -XPUT 'http://localhost:9200/megacorp/employee/1' -d '{
  "first_name" : "John",
  "last_name" : "Smith",
  "age" : 25,
  "about" : "I love to go rock climbing",
  "interests": ["sports", "music"]
}'
```

The path `/megacorp/employee/1` contains:

  - The index `megacorp`

  - The type `employee`

  - The ID of the employee document `1`

The request body (JSON document) contains all the information about the employee.

The typical request for adding new document can be describe as follow:

```json
PUT /{index}/{type}/{id of document}
{
  key: value
}
```

Let's add few more employees to the directory:

```json
{
    "first_name" :  "Jane",
    "last_name" :   "Smith",
    "age" :         32,
    "about" :       "I like to collect rock albums",
    "interests":  [ "music" ]
}
{
    "first_name" :  "Douglas",
    "last_name" :   "Fir",
    "age" :         35,
    "about":        "I like to build cabinets",
    "interests":  [ "forestry" ]
}
```

###1.5.2 Retrieving Document

Document can be retrieved via `GET` request:

    GET http://localhost:9200/megacorp/employee/1

The response contains some metadata about the document, and the employee's original JSON document as the `_source` field:

```json
{
  "_index" :   "megacorp",
  "_type" :    "employee",
  "_id" :      "1",
  "_version" : 1,
  "found" :    true,
  "_source" :  {
      "first_name" :  "John",
      "last_name" :   "Smith",
      "age" :         25,
      "about" :       "I love to go rock climbing",
      "interests":  [ "sports", "music" ]
  }
}
```

###1.5.3 Search Lite

The api for search in Elasticsearch is:

    GET http://localhost:9200/megacorp/employee/search

This request will list all the employees in `megacorp` index. To search with condition, use this request:

    GET http://localhost:9200/{index}/{type}/_search?q=({key}:{value})*

Example: Searching with employee's last name

    GET http://localhost:9200/megacorp/employee/_search?q=last_name:Smith

For more on this query-string search, see on [Search Lite Guide](https://www.elastic.co/guide/en/elasticsearch/guide/current/search-lite.html)

###1.5.4 Search with Query DSL

Elasticsearch provides a rich, flexible, query language called the _query DSL_. The DSL query is specified using a JSON request body. Example for searching with the employee's last name:

```json
GET http://localhost:9200/megacorp/employee/_search -d
{
    "query" : {
        "match" : {
            "last_name" : "Smith"
        }
    }
}
```

More-Complicated Search:

Search for employees whose last name is Smith and age is greater than 30

```json
GET http://localhost:9200/megacorp/employee/_search -d
{
  "query" : {
    "filtered" : {
      "filter" : {
        "range" : {
          "age" : { "gt" : 30 }
        }
      },
      "query" : {
        "match" : {
          "last_name" : "smith"
        }
      }
    }
  }
}
```

###1.5.5 Full-Text Search

Example: Search for employees who enjoy rock climbing:

```json
GET http://localhost:9200/megacorp/employee/_search
{
  "query" : {
    "match" : {
      "about" : "rock climbing"
    }
  }
}
```

Result:

```json
{
   ...
   "hits": {
      "total":      2,
      "max_score":  0.16273327,
      "hits": [
         {
            ...
            "_score":         0.16273327, //The relevance score
            "_source": {
               "first_name":  "John",
               "last_name":   "Smith",
               "age":         25,
               "about":       "I love to go rock climbing",
               "interests": [ "sports", "music" ]
            }
         },
         {
            ...
            "_score":         0.016878016, //The relevance score
            "_source": {
               "first_name":  "Jane",
               "last_name":   "Smith",
               "age":         32,
               "about":       "I like to collect rock albums",
               "interests": [ "music" ]
            }
         }
      ]
   }
}
```

By default, Elasticsearch sorts matching results by their **relevance score** (how well each document matches the query)

John Smith's `about` field clearly has `rock climbing` in it so it has the highest score. Jane Smith's `about` field only has `rock` in it so the score is much lower but still be returned in the result set.

**Pharse Search**

To find exact matching sequences of words or phrases, for example searching for an employee records that contain the whole phrase _"rock climbing"_, use the `match_phrase` query:

```json
GET /megacorp/employee/_search
{
  "query" : {
    "match_phrase" : {
      "about" : "rock climbing"
    }
  }
}
```

This will only return the John Smith's document.

###1.5.6Highlighting searches

To highlight the result from the query, adding a `highlight` parameter in the request data:

```json
GET /megacorp/employee/_search
{
    "query" : {
        "match_phrase" : {
            "about" : "rock climbing"
        }
    },
    "highlight": {
        "fields" : {
            "about" : {}
        }
    }
}
```

This query will return the same result but it wrap the `<em></em>` tags around the matching words.

For more about highlighting of search snippets, read the [highlighting reference documentation](http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/search-request-highlighting.html)

###1.5.7 Analytics

Elasticsearch has functionality called **aggregations**, which is similar to `GROUP BY` in SQL with more powerful.

Example, let's find the most popular interests enjoyed by the employees:

```json
GET /megacorp/employee/_search
{
  "aggs": {
    "all_interests": {
      "terms": { "field": "interests" }
    }
  }
}
```

Results:

```json
{
  ...
  "hits": { ... },
  "aggregations": {
    "all_interests": {
      "buckets": [
      {
        "key":       "music",
        "doc_count": 2
      },
      {
        "key":       "forestry",
        "doc_count": 1
      },
      {
        "key":       "sports",
        "doc_count": 1
      }
      ]
    }
  }
}
```

To know the popular interest of people called Smith, add the appropriate query into the mix:

```json
GET /megacorp/employee/_search
{
  "query": {
    "match": {
      "last_name": "smith"
    }
  },
  "aggs": {
    "all_interests": {
      "terms": {
        "field": "interests"
      }
    }
  }
}
```

The aggregation results:

```json
"aggregations" : {
  "all_interests" : {
    "doc_count_error_upper_bound" : 0,
    "sum_other_doc_count" : 0,
    "buckets" : [ {
      "key" : "music",
      "doc_count" : 2
    }, {
      "key" : "sports",
      "doc_count" : 1
    } ]
  }
}
```

Aggregations allow hierarchical roll ups too. Example, let's find the average age of employees who share a particular interest:

```json
GET /megacorp/employee/_search
{
  "aggs" : {
    "all_interests" : {
      "terms" : { "field" : "interests" },
      "aggs" : {
        "avg_age" : {
          "avg" : { "field" : "age" }
        }
      }
    }
  }
}
```

###Not yet reading chapters

[Distributed nature](https://www.elastic.co/guide/en/elasticsearch/guide/current/_distributed_nature.html)

[Life Inside a Cluster]()

[Distributed Document Store]()

[Distributed Search Execution]()

[Inside a shard]()
