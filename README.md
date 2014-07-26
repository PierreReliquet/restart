## Restart

[ ![Build Status](https://drone.io/github.com/PierreReliquet/restart/status.png) ](https://drone.io/github.com/PierreReliquet/restart/latest)

Restart is an implementation of a REST API for Dart.

The is to provide a way of registering easily some endpoints by use of annotations which is similar to many Java API.

Restart focuses on doing only one thing : providing a way to handle HTTP methods easily which means that no DI nor anything else is used and the user can consequently use any other library.


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
new SimpleRest()..registerEndpoints(new TodoEndpoint())..listen('0.0.0.0', 9000);
```

*One might ask why an instantiated object is provided to the registerEndpoints method? This is a design point of view because the user might have to do some IoC and consequently would not want me to instantiate that Object for him.*

#### Positional parameters
It is important to understand that when the method is invoked the parameters are provided positionally as they are declared in the URI. This means that if I have the following URI - '/{id}/foo/{bar}'  - my method signature has to be : 
```Dart
anything(HttpRequest req, String id, String bar) {...}
```
And cannot be : 
```Dart
anything(HttpRequest req, String bar, String id) {...}
```

#### Adding new HTTP method to restart
It is now also possible to add support for non supported HTTP method with the following code : 
```Dart
/// Adds the support for the PATCH method
class Patch extends HttpEndpoint{
  const Patch(String uri) : super(uri);
}

```

And this can be then be used : 
```Dart
class Endpoints {
  @Patch('/foo/bar')
  HttpResponse anything(HttpRequest req) {...}
}
```
