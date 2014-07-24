## Restart

Restart is an implementation of a REST API for Dart.
The is to provide a way of registering easily some endpoints by use of annotations which is similar to many Java API.


The use would be as follow for the declaration of endpoints: 
```Dart
class Endpoint {
  @Get('/api/todo')
  HttpResponse list(HttpRequest req) {...}

  @Put('/api/todo/{id}') // ability to have parameters passed as positional parameters
  HttpResponse update(HttpRequest req, String id) {...}
}
```

And as follow for the launch of the HTTP server:  
```Dart
new SimpleRest()..registerEndpoints(TodoEndpoint)..listen('0.0.0.0', 9000);
```

#### Adding new HTTP method to restart
It is now also possible to add support for non supported HTTP method with the following code : 
```Dart
/// Adds the support for the PATCH method
class Patch implements HttpEndpoint {
  final String uri;
  const Patch(this.uri);
}
```

And this can be then be used : 
```Dart
class Endpoints {
  @Patch('/foo/bar')
  HttpResponse anything(HttpRequest req) {...}
}
```
