## **The Event Loop**
---
Node takes the approach that all I/O activities should be nonblocking. This means that **HTTP requests**, **database queries**, **file I/O**, and other things that require the program to wait _do not halt_** execution until they return data. Instead, they run independently, and then emit an event when their data is available. 

_Event-loop blocking code_**

```javascript
EE = require('events').EventEmitter;
ee = new EE();

die = false;

ee.on('die', function() {
    die = true;
});

setTimeout(function() {
    ee.emit('die');
}, 100);

while(!die) {
}

console.log('done');
```
`Console.log('done')` will never be called, because the while loop stops Node to
call back the time out and emit the `die` event.

_A basic HTTP server_**
```javascript
var http = require('http');
http.createServer(function (req, res) {
  res.writeHead(200, {'Content-Type': 'text/plain'});
  res.end('Hello World\n');
}).listen(8124, "127.0.0.1");
console.log('Server running at http://127.0.0.1:8124/');
```

The example creates an HTTP server using a _factory method_ in the `http` library. The factory method creates a new HTTP server and attaches a callback to the `request` event. The first thing Node.js does is run the code in the example from top to bottom. This can be considered the “setup” phase of Node programming. Because we attached some event listeners, Node.js doesn’t exit, but instead waits for an event to be fired.

When the server gets an request, Nodejs emit the `request` event, which causes the callbacks attached to that event to be run in order. In this example, there is only one callback, the anonymous function that is passed as an argument to `createServer`. When the request occur, the event is handled and the call back function is execute.

Assume that there are a lot of request to the example http server. If the callback takes 1 second and the second request come shortly after the first one, the second request is not going to be acted for another second or so. The problem of blocking the event loop becomes more damaging to the user experience. The operating system kernel actually handles the TCP connections to clients for the HTTP server, so there isn’t a risk of rejecting new connections, but the real danger are not acting on them. The upshot of this is that we want to keep Node.js as event-driven and nonblocking as possible. In the same way that a slow I/O event should use callbacks to indicate the presence of data that Node.js can act on, the Node.js program itself should be written in such a way that no single callback ties up the event loop for extended periods of time.

There are 2 strategies when writting a Nodejs server:
 - Once setup has been completed, make all actions event-driven.
 - If Node.js is required to process something that will take a long time, consider delegating it to web workers.

It is important to write event-driven code in a way that is easy to read and understand. In the previous example, we use anonymous function as the event callback, which make thing hard when debugging and understanding code. First, we have no control over where the code is used. An anonymous function’s call stack starts from when it is used, rather than when the callback is attached to an event. If everything is an anonymous event, it can be hard to distinguish similar callbacks when an exception occurs.

## **Patterns**

Event-driven programming is focused on solving problems with I/O. When it is working with data in memory that doesn’t require I/O, Node can be completely procedural.

### **The I/O Problem Space**
The first obvious distinction to look at is serial versus parallel I/O:
 - Serial is obvious: do this I/O, and after it is finished, do that I/O.
 - Parallel is more complicated to implement but also easy to understand: do this I/O and that I/O at the same time. 

Groups of serial and parallel work can also be combined. For example, two groups of parallel requests could execute serially: do this and that together, then do _other_ and _another_ together.

In Node, any I/O tasks could take from 0 to infinite time. Instead of waiting, use placeholders (events), which then fire callbacks when the I/O happens. Because the latency is unbounded, it is easy to perform parallel tasks. Simply make number of call for various I/O tasks. Ordered serial requests can be archives by making nesting or referencing callbacks together so that the first callback will initiate the second I/O request, the second will initiate the third and so on. This pattern of ordered requests is useful when the results of one I/O operation have to inform the details of the next I/O request.

Ordered parallel requests are also a useful pattern; they happen when we allow the I/O to take place in parallel, but we deal with the results in a particular sequence. Unordered serial I/O offers no particular benefits, so we won’t consider it as a pattern.

#### **Unordered parallel I/O**

All I/O in Node is unordered parallel by default. 
_Example: Unordered parallel I/O in Node_
```javascript
fs.readFile('foo.txt', 'utf8', function(err, data) {
  console.log(data);
};
fs.readFile('bar.txt', 'utf8', function(err, data) {
  console.log(data);
};
```
Simply making I/O requests with callbacks will create unordered parallel I/O. At some point in the future, both of these callbacks will fire. Which happens first is unknown, and either one could return an error rather than data without affecting the other request.

#### **Ordered parallel I/O**
In this pattern, each previous task must be completed before the next task is started. In Node, this means nesting callbacks so that the callback from each task starts the next task.

_Example: Unordered parallel I/O in Node_
```javascript
server.on('request', function(req, res) {
  //get session information from memcached
  memcached.getSession(req, function(session) {
    //get information from db
    db.get(session.user, function(userData) {
      //some other web service call
      ws.get(req, function(wsData) {
        //render page
        page = pageRender(req, session, userData, wsData);
        //output the response
        res.write(page);
      });
    });
  });
});
```
Although nesting callbacks allows easy creation of ordered serial I/O, it also creates so-called “pyramid” code, which is hard to read and understand.i There are a few ways to make this code more readable without breaking the fundamental ordered serial pattern.

First, name the inline function declarations:
```javascript
server.on('request', getMemCached(req, res) {
  memcached.getSession(req, getDbInfo(session) {
    db.get(session.user, getWsInfo(userData) {
      ws.get(req, render(wsData) {
        //render page
        page = pageRender(req, session, userData, wsData);
        //output the response
        res.write(page);
      });
    });
  });
});
```

Use declared functions instead of just anonymous or named ones.
```javascript
server.on('request', function(req, res) {
  var render = function(wsData) {
    page = pageRender(req, session, userData, wsData);
  };

  var getWsInfo = function(userData) {
    ws.get(req, render);
  };

  var getDbInfo = function(session) {
    db.get(session.user, getWsInfo);
  };

  var getMemCached = function(req, res) {
    memcached.getSession(req, getDbInfo);
  };
}
```

Sometimes there is code you want to reuse across many functions. This is the province of middleware. One of the most popular in Node is the model used by the Connect framework. The general idea behind its implementation is that we pass around some variables that represent not only the state but also the methods of interacting with that state.

When something modifies an object used by a callback, it can often be very difficult to figure out when that change happened because it happens in a nonlinear order. If object is changed by passing as arguments, be considerate of where those objects are going to be used.

The basic idea is to take something that represents the state and pass it between all functions that need to act on that state. This means that all the things acting on the state need to have the same interface so they can pass between themselves. This is why Connect (and therefore Express) middleware all takes the form function(req, res, next).


## **Writing Code for Production**

### **Error Handling**
Error handling can be split from other activities in Node. Javascript includes
try/catch functionality, but it is appropirate only for errors that happen inline. In Node, non blocking I/O is handled by passing callback to the function. This means the callback is going to run when the event happens outside of the try/catch block. 
_Example: Fail when trying to catch an error in a callback_
```javascript
var http = require('http')
var opts = {
  host: 'sfnsdkfjdsnk.com',
  port: 80,
  path: '/'
}
try {
  http.get(opts, function(res) {
    console.log('Will this get called?')
  })
}
catch (e) {
  console.log('Will we catch an error?')
}
```
When `http.get()` is called, what is actually happening is when the I/O completes, the callback function will be fired. However, the `http.get()` call will succeed simply by issuing the callback. An error during GET cannot be caught by a try/catch block.

Node dealing with this by using the `error` event. This is a special event that is fired when an error occurs. It allows a module engaging in I/O to fire an alternative event to the one the callback was listening for to deal with the error.
_Example: Catching an I/O error with the error event_
```javascript
var http = require('http')
var opts = {
  host: 'dskjvnfskcsjsdkcds.net',
  port: 80,
  path: '/'
}
var req = http.get(opts, function(res) {
  console.log('This will never get called')
})
req.on('error', function(e) {
  console.log('Got that pesky error trapped')
})
```

### **Using multiple Processors**
Node provides a module called cluster that allows you to delegate work to child processes. This means that Node creates a copy of its current program in another process (on Windows, it is actually another thread). Each child process has some special abilities, such as the ability to share a socket with other children. So a Node program can start many other Node programs and then delegate work to them.

When works are shared between a nnumber of copies of a Node program using `cluster`, request do not go through master process, but directly to the children program. Hence, dispatching requests does not create a bottleneck in the system.

By using the cluster API, you can distribute work to a Node process on every available core of your server.
_Example: Using cluster to distribute work_
```javascript
var cluster = require('cluster');
var http = require('http');
var numCPUs = require('os').cpus().length;
if (cluster.isMaster) {
  // Fork workers.
  for (var i = 0; i < numCPUs; i++) {
    cluster.fork();
  }
  cluster.on('death', function(worker) {
    console.log('worker ' + worker.pid + ' died');
  });
} else {
  // Worker processes have a http server.
  http.Server(function(req, res) {
    res.writeHead(200);
    res.end("hello world\n");
  }).listen(8000);
}
```




