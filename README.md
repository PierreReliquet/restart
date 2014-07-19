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