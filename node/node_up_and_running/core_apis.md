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



###URL





###I/O

