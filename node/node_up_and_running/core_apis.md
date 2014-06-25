#Core APIs

###Events
Events is a fundamental piece of making every other API work.

In browser, the event model cones from the DOM rather than JavaScript itself.

The DOM has a user-driven event model base on user interaction with a set of interface elements arranged in a tree structure (HTML, XML, etc..). This mean when a user interacts with a particularpart of the interface, there is an **event** and a **context**, which is the HTML/XML element on which the click or other activity took place. Because the context is within a tree, which allow elements either up or down the tree to receive the event that was called.

Example: in an HTML list, a click event on an `<li>` can be captured by a listener on the `<ul>` that is its parent. Conversely, a click on the <ul> can be bubbled down to a listener on the <li>. Because JavaScript objects don’t have this kind of tree structure, the model in Node is much simpler.

#####EventEmmiter
Node create the `EventEmmiter` class to provide some basic event functionality. All event functionality in Node revoles around `EventEmitter` because it is also designed to be an interface class for other class to extend.

`EventEmitter` has a handful of methods, the main two being `on` and `emit`. The class provides these methods for use by other classes. The `on` method creates an event listener for an event.

```javascript
server.on('event', function(a, b, c) {
  //do things
});
```

The `on` method takes two parameters: the _name of the event_ to listen for and the _function to _call_ when that event is emmitted. Because `EventEmmiter` is an interface pseudoclass, the class that inherits from `EventEmitter` is expected to be invoked with the new keyword.

```javascript
var utils = require('utils'),
    EventEmitter = require('events').EventEmitter;

var Server = function() {
  console.log('init');
};

utils.inherits(Server, EventEmitter);

var s = new Server();

s.on('abc', function() {
  console.log('abc');
});
```

`inherits` method in the `utils` module provides a way for the EventEmitter class to add its methods to `Server` class.

When we want to use the Server class, we instantiate it with new Server(). This instance of Server will have access to the methods in the superclass (EventEmitter), which means we can add a listener to our instance using the on method.

However, the listener will never be called, because the `abc` event is not fired. To emit event, use this:

    s.emit('abc');

It’s important to note that these events are instance-based. There are no global events. When you call the `on` method, you attach to a specific `EventEmitter`-based object. Even the various instances of the `Server` class do not share events. `s` will not share the same events as another `Server` instance, such as one created by `var z = new Server()`;

#####Callback Syntax
When calling emit, in addition to the event name, you can also pass an arbitrary list of parameters. These parameters will be passed to the function listening to the event. When you receive a request event from the http server, for example, you receive two parameters: `req` and `res`. When the request event was emitted, those parameters were passed as the second and third arguments to the emit.

Example, Passing parameters when emitting an event

```javascript
s.emit('abc', a, b, c);
```
Calling event listeners from emit

```javascript
if (arguments.length <= 3) {
  // fast case
  handler.call(this, arguments[1], arguments[2]);
} else {
  // slower
  var args = Array.prototype.slice.call(arguments, 1);
  handler.apply(this, args);
}
```

If `emit()` is passed with three or fewer arguments, the method takes a shortcut and uses call. Otherwise, it uses the slower `apply` to pass all the arguments as an `array`.

The important thing to recognize here, though, is that Node makes both of these calls using the this argument directly. This means that the context in which the event listeners are called is the context of EventEmitter—not their original context.

###HTTP
HTTP uses a pattern that is common in Node. Pseudoclass factories provide an easy way to create a new server. The `http.createServer()` method provides us with a new instance of the `HTTP Server` class, which is the class we use to define the actions taken when Node receives incoming HTTP requests.

#####HTTP Servers
Acting as an HTTP server is probably the most common current use case for Node. The server component of the HTTP module provides the raw tools to build complex and comprehensive web servers.

The first step in using HTTP servers is to create a new server using the `http.createServer()` method. This returns a new instance of the `Server` class, which has only a few methods because most of the functionality is going to be provided through using events.

The `http` server class has six events and three methods. Most of the method are used to initialize the server, whereas events are used during its opreation.

Example: A simple and very short, HTTP server

```javascript
require('http').createServer(function(req,res){res.writeHead(200, {}); 
res.end('hello world');}).listen(8125);
```

This example is `not` good code. However, it illustrate some important point. The first is the require if the `http` module. Notice the chain methods to access module without first asigning it to a variable. Many thing on Node return a function, which allows to invoke functions immediately. From the included http module, we call createServer. This doesn’t have to take any arguments, but we pass it a function to attach to the request event. Finally, we tell the server created with createServer to listen on port 8125.

Example: A simple, but more descriptive, HTTP server

```javascript
var http = require('http');
var server = http.createServer();
var handleReq = function(req,res){
  res.writeHead(200, {});
  res.end('hello world');
};
server.on('request', handleReq);
server.listen(8125);
```

Because we didn’t pass the `request` event listener as part of the factory method for the `http Server` object, we need to add an event listener explicitly. Calling the on method from `EventEmitter` does this.

The `http` server supports a number of events, which are associated with either the TCP or HTTP connection to the client. The `connection` and `close` events indicate the buildup (connect) or teardown (disconnect) of a TCP connection to a client.

The `request`, `checkContinue`, `upgrade`, and `clientError` events are associated with HTTP requests. The `request` event signals a new HTTP request.

The `checkContinue` event indicates a special event. It allows you to take more direct control of an HTTP request in which the client streams chunks of data to the server. As the client sends data to the server, it will check whether it can continue, at which point this event will fire. If an event handler is created for this event, the `request` event **will not** be emitted.

The `upgrade` event is emitted when a client asks for a protocol upgrade. The http server will deny HTTP upgrade requests unless there is an event handler for this event.

Finally, the clientError event passes on any error events sent by the client.

When a new TCP stream is created for a request, a `connection` event is emitted. This event passes the TCP stream for the request as a parameter. The stream is also available as a `request.connection` variable for each request that happens through it. However, only one `connection` event will be emitted for each stream. This means that many requests can happen from a client with only one connection event.

#####HTTP Clients
Node is also great when you eant to make outgoing HTTP connection (for using a web services, connecting to a document store databases, or scraping websites). The `http` module can be used to make a HTTP request by using `http.ClientRequest` class. There are two factory method for this class: 
 - A general purpose (request).
 - A convenience method (get, post).

Example of a general purpose method

```javascript
var http = require('http');

var options = {
  host: 'www.google.com',
  port: 80,
  path: '/',
  method: 'GET'
};

var req = http.request(options, function(response) {
  console.log(response);
  response.on('data', function(data) {
    console.log(data);
  });
});

req.end();
```

The `options` object defines the functionality of the request. We must provide the host name (or IP address), the port and the path. The method is optional and the default value is GET if none specify. The example is specifing that the request should be an `HTTP GET request to http://www.google.com/ on port 80`.

Next, the `options` object is used to construct an instance of `http.ClientRequest` using the factory method `http.request()`. This method takes an `options object and an optional callback argument. The passed callback listens to the `response` event, and when a `response` event is received, we can process the results of the request. It’s important to notice that the body of the HTTP request is actually received via a stream in the `response` object.

The final important point to notice is that we had to `end()` the request. Because this was a GET request, we didn’t write any data to the server, but for other HTTP methods, such as PUT or POST, you may need to. Until we call the `end()` method, request won’t initiate the HTTP request, because it doesn’t know whether it should still be waiting for us to send data.

######Making HTTP GET requests
Since GET is such a common HTTP use case, there is a special factory method to support it in a more convenient way.

```javascript
var http = require('http');

var opts = {
  host: 'www.google.com',
  port: 80,
  path: '/',
};

var req = http.get(opts, function(res) {
  console.log(res);
  res.on('data', function(data) {
    console.log(data);
  });
});
```

This example of `http.get()` does exactly the same thing as the previous example, but it’s slightly more concise. We’ve lost the `method` attribute of the config object, and left out the call `request.end()` because it’s implied.

######Uploading data for HTTP POST and PUT
Example, writing data to an upstream service

```javascript
var options = {
  host: 'www.example.com',
  port: 80,
  path: '/submit',
  method: 'POST'
};

var req = http.request(options, function(res) {
  res.setEncoding('utf8');
  res.on('data', function (chunk) {
    console.log('BODY: ' + chunk);
  });
});

req.write("my data");
req.write("more of my data");

req.end();
```

This example uses the `http.ClientRequest.write()`method. This method allows you to send data upstream, and it requires you to explicitly call `http.ClientRequest.end()` to indicate you’re finished sending data. Whenever `ClientRequest.write()` is called, the data is sent upstream **(it isn’t buffered)**, but the server will not respond until `ClientRequest.end()` is called.

You can stream data to a server using `ClientRequest.write()` by coupling the writes to the data event of a Stream. This is ideal if you need to, for example, send a file from disk to a remote server over HTTP.

**The ClientResponse object**

The `ClientResponse` object stores a variety of information about the request. Some of its obvious properties that are often useful include `statusCode` (which contains the HTTP status) and `header` (which is the response header object). Also hung off of `ClientResponse` are various streams and properties that you may or may not want to interact with directly.


###URL
The URL module provides tools for easily parsing and dealing with URL strings. It’s extremely useful when you have to deal with URLs. The module offers three methods: `parse`, `format`, and `resolve`.

_Example. Parsing a URL using the URL module_

```javascript
> var URL = require('url');
> var myUrl = "https://www.google.com/search?q=node+js&oq=node+js"
> parsedUrl = URL.parse(myUrl);
{ protocol: 'https:',
  slashes: true,
  auth: null,
  host: 'www.google.com',
  port: null,
  hostname: 'www.google.com',
  hash: null,
  search: '?q=node+js&oq=node+js',
  query: 'q=node+js&oq=node+js',
  pathname: '/search',
  path: '/search?q=node+js&oq=node+js',
  href: 'https://www.google.com/search?q=node+js&oq=node+js' }
> parsedUrl = URL.parse(myUrl, true);
{ protocol: 'https:',
  slashes: true,
  auth: null,
  host: 'www.google.com',
  port: null,
  hostname: 'www.google.com',
  hash: null,
  search: '?q=node+js&oq=node+js',
  query: { q: 'node js', oq: 'node js' },
  pathname: '/search',
  path: '/search?q=node+js&oq=node+js',
  href: 'https://www.google.com/search?q=node+js&oq=node+js' }
```

The datastruct representing the parts of the parsed URL returned from `parse()` method are:
 - href
 - protocol
 - host
 - auth
 - hostname
 - port
 - pathname
 - search
 - query
 - hash

The `href` is the full URL that was originally passed to `parse`. The `protocol` is the protocol used in the URL (e.g., http://, https://, ftp://, etc.). `host` is the fully qualified hostname of the URL. It might also include a port number, such as 8080, or username and password credentials like un:pw@ftpserver.com. The various parts of the hostname are broken down further into `auth`, containing just the user credentials; `port`, containing just the port; and `hostname`, containing the hostname portion of the URL.

The next set of components of the URL relates to everything after the host. The `pathname` is the entire filepath after the `host`. In `http://sports.yahoo.com/nhl`, it is `/nhl`. The next component is the `search` component, which stores the HTTP GET parameters in the URL. The query parameter is similar to the search component.

`parse` takes two arguments:
1. the `url` string
2. an optional Boolean that determines whether the queryString should be parsed using the querystring module.

If the second argument is false, `query` will just contain a string similar to that of search but without the leading ?. If the second argument is left blank, its defaults to false.

The final component is the fragment portion of the URL. This is the part of the URL after the `#`. Commonly, this is used to refer to named anchors in HTML pages. For instance, `http://abook.com/#chapter2` might refer to the second chapter on a web page hosting a whole book. The `hash` component in this case would contain `#chapter2`.

Some sites, such as `http://twitter.com`, use more complex fragments for AJAX applications, but the same rules apply. So the URL for the Twitter mentions account, `http://twitter.com/#!/mentions`, would have a pathname of `/` but a hash of `#!/mentions`.

#####querystring
The `querystring` module provides an easy way to create objects from the query strings. The main methods it offers are `parse` and `decode`, but some internal helper functions, —such as `escape`, `unescape`, `unescapeBuffer`, `encode`, and `stringify`, are also exposed. If you have a query string, you can use parse to turn it into an object.

Example:

```javascript
> var qs = require('querystring');
> qs.parse('a=1&b=2&c=d');
{ a: '1', b: '2', c: 'd' }
```

Here, the `parse` function turns the query string into an object in which the properties are the keys and the values correspond to the ones in the query string.

It’s important to note that you must pass the query string without the leading `?` that demarks it in the URL. The query string starts with a `?` to indicate where the filepath ends, but if you include the `?` in the string you pass to `parse`, the first key will start with a `?`.

This library is really useful in a bunch of contexts because query strings are used in situations other than URLs. When you get content from an HTTP POST that is x-form-encoded, it will also be in query string form. All the browser manufacturers have standardized around this approach. By default, forms in HTML will send data to the server in this way also.

Another important part of querystring is `encode`. This function takes a query string’s key-value pair object and stringifies it. Any JavaScript object can be used, but ideally you should use an object that has only the data that you want in it because the encode method will add all properties of the object. However, if the property value isn’t a string, Boolean, or number, it won’t be serialized and the key will just be included with an empty value.

Example

```javascript
> var myObj = {'a':1, 'b':5, 'c':'cats', 'func': function(){console.log('dogs')}}
> qs.encode(myObj);
'a=1&b=5&c=cats&func='
```

###I/O
#####Streams
Many components in Node provide continuous output or can process continuous input. To make these components act in a consistent way, the stream API provides an abstract interface for them. This API provides common methods and properties that are available in specific implementations of streams. Streams can be readable, writable, or both. All streams are `EventEmitter` instances, allowing them to emit events.

######Readable streams
The readable stream API is a set of methods and events that provides access to chunks of data as they are sent by an underlying data source. Fundamentally, readable streams are about emitting `data` events. These events represent the stream of data as a stream of events.

Example. Create a readable file stream

```javascript
var fs = require('fs');
var filehandle = fs.readFile('data.txt', function(err, data) {
  console.log(data);
});
```

This basic stream simply reads data from a file in chucks. Every time a new chunk is arrived, it is exposed a callback in the variable called data.

One of the common pattern used in dealing with stream is spooling pattern. The _spooling pattern_ is used when we need an entire resource avaiable before dealing with it. In this scenario, a stream is used to _get_ data, but _use_ the data only if enough data is avaiable. Typically this mean when the stream ends or another event or condition.

Example. Using the spooling pattern to read a complete stream

```javascript
//abstract stream

var spool = "";
stream.on('data', function(data) {
  spool += data;
});
stream.on('end', function() {
  console.log(spool);
});
```

#####Filesystem
The filesystem module is obviously very helpful because you need it in order to access files on disk. It is a module that all of the methods have both asynchronous and synchronous version. The asynchronous method is strongly recommended to use, unless building a command-line scripts with Node. Even then, it is often much better to use the async versions, even though doing so adds a little extra code, so that you can access multiple files in parallel and reduce the running time of your script.

The main issuse while dealing with asynchronous calls is ordering. It’s common to want to do a number of moves, renames, copies, reads, or writes at one time. However, if one of the operations depends on another, this can create issues because return order is not guaranteed. This means that the first operation in the code could happen after the second operation in the code.

Consider the case of reading and then deleting a file. If the delete (unlink) happens before the read, it will be impossible to read the contents of the file.

Example. Reading and deleting a file asynchronously - wrong.

```javascript
var fs = require('fs');

fs.readFile('warandpeace.txt', function(e, data) {
  console.log('War and Peace: ' + data);
});

fs.unlink('warandpeace.txt');
```

Example. Reading and deleting a file asynchronously using nested callbacks

```javascript
var fs = require('fs');

fs.readFile('warandpeace.txt', function(e, data) {
  console.log('War and Peace: ' + data);
  fs.unlink('warandpeace.txt');
});
```

This approach is often very effective for discrete sets of operations. In our example with just two operations, it’s easy to read and understand, but this pattern can potentially get out of control.

###Buffers
`Buffers` are an extension to the V8 engine. Buffers are actually a direct allocation of memory. Unlike the data types in JavaScript, `Buffer` provides direct memory access, warts and all. Once a `Buffer` is created, it is a fixed size. If you want to add more data, you must _clone_ the `Buffer` into a larger `Buffer`.

#####A quick primer on binary
Computers, as almost everyone knows, work by manipulating states of "on" and "off." We call this a _binary_ state because there are only two possibilities. Everything in computers is built on top of this, which means that working directly with binary can often be the fastest method on the computer. To do more complex things, we collect “bits” (each representing a single binary state) into groups of eights, often called a _byte_.

By creating sets of 8 bits, we are able to represent any number from 0 to 255. The rightmost bit represents 1, but then we double the value of the number represented by each bit as we move left. To find out what number it represents, we simply sum the numbers in column headers.

Example:

```
128 64 32 16 8 4 2 1
--- -- -- -- - - - -
0   0  0  0  0 0 0 0 = 0 (00000000)

128 64 32 16 8 4 2 1
--- -- -- -- - - - -
1   1  1  1  1 1 1 1 = 255 (11111111)

128 64 32 16 8 4 2 1
--- -- -- -- - - - -
1   0  0  1  0 1 0 1 = 149 (10010101)
```

You’ll also see the use of hexadecimal notation, or "hex." Because bytes need to easily described and a string of eight 0s and 1s isn’t very convenient, hex notation has become popular. Binary notation is base 2, in that there are only two possible states per digit (0 or 1). Hex uses base 16, and each digit in hex can have a value from 0 to F, where the letters A through F (or their lowercase equivalents) stand for 10 through 15, respectively. What’s very convenient about hex is that with two digits we can represent a whole byte. The right most digit represent 1s, and the left digit represents 16s. If we want to represent decimal 123, it is `(16 x 7) + (1 x 11(B))`, or the hex value `7B`.

Example:

```
Hex to Decimal:

0 1 2 3 4 5 6 7 8 9 A  B  C  D  E  F
- - - - - - - - - - -- -- -- -- -- --
0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15


Counting in hex:

16 1
-- -
0  0 = 0

16 1
-- -
F  F = 255

16 1
-- -
7  B = 123
```

In JavaScript, you can create a number from a hex value using the notation `0x` in front of the hex value. For instance, 0x7B is decimal 123. In Node, you’ll commonly see `Buffers` represented by hex values in `console.log()` output or Node REPL.

Example, creating a 3-byte Buffer from an array of octets

```javascript
> new Buffer([255,0,123]);
<Buffer ff 00 7b>
>
```

#####Binary and strings
Once you copy thing to `Buffer`, they will be stored as their binary representations. You can always convert the binary representation in the buffer back into other things, such as strings, later. So a `Buffer` is defined only by its size, not by the encoding or any other indication of its meaning.

Given that Buffer is opaque, how big does it need to be in order to store a particular string of input? As we’ve said, a UTF character can occupy up to 4 bytes, so to be safe, you should define a Buffer to be four times the size of the largest input you can accept, measured in UTF characters.

#####Using Buffers
`Buffers` can be created using three possible parameters: _the length_ of the `Buffer` in bytes, an array of bytes to copy into the `Buffer`, or a string to copy into the `Buffer`.

Creating a Buffer of a particular size is a very common scenario and easy to deal with. Simply put, you specify the number of bytes as your argument when creating the Buffer.

Example:

```javascript
> new Buffer(10);
<Buffer 0a 00 00 00 00 00 00 00 78 c2>
>
```

`Buffer` is just getting an allocation of memory directly, so it is _uninitialized_ and the contents are left over from whatever happened to occupy them before. This is unlike all the native JavaScript types, which initialize all memory so that when you create a new primitive or object, it doesn’t assign whatever was already in the memory space to the primitive or object you just created. If you want to have a nicely zeroed set of bits, you’ll need to do it yourself (or find a helper library).

Creating a `Buffer` using byte length is most common when you are working with things such as network transport protocols that have very specifically defined structures. When you know exactly how big the data is going to be and you want to allocate and reuse a `Buffer` for performance reasons, this is the way to go.

Probably the most common way to use a Buffer is to create it with a string. Although a `Buffer` can hold any data, it is particularly useful for I/O with character data because the constraints we’ve already seen on `Buffer` can make their operations much faster than operations on regular strings. So when you are building really highly scalable apps, it’s often worth using Buffers to hold strings. This is especially true if you are just shunting the strings around the application without modifying them.

When we create a Buffer with a string, it defaults to UTF-8. That is not to say that Buffer pads the string to fit any Unicode character (blindly allocating 4 bytes per character), but rather that it will not truncate characters.

Example

```javascript
> new Buffer('foobarbaz');
<Buffer 66 6f 6f 62 61 72 62 61 7a>
> new Buffer('foobarbaz', 'ascii');
<Buffer 66 6f 6f 62 61 72 62 61 7a>
> new Buffer('foobarbaz', 'utf8');
<Buffer 66 6f 6f 62 61 72 62 61 7a>
> new Buffer('é');
<Buffer c3 a9>
> new Buffer('é', 'utf8');
<Buffer c3 a9>
> new Buffer('é', 'ascii');
<Buffer e9>
>
```

#####Working with strings
You don’t need to compute the length of a string before creating a `Buffer` to hold it; just assign the string as the argument when creating the Buffer. Alternatively, you can use the `Buffer.byteLength()`. This method takes a string and an encoding and returns the string’s length in bytes, rather than in characters as String.length does.

The `Buffer.write()` method writes a string to a specific index of a `Buffer`. If there is room in the `Buffer` starting from the specified offset, the entire string will be written. Otherwise, characters are truncated from the end of the string to fit the Buffer. In either case, `Buffer.write()` will return the number of bytes that were written. 




