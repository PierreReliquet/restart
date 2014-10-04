## Restart

[ ![Build Status](https://drone.io/github.com/PierreReliquet/restart/status.png) ](https://drone.io/github.com/PierreReliquet/restart/latest)

Restart is an implementation of a REST API for Dart.

The aim is to provide a way of registering easily some endpoints by use of annotations which is similar to many Java API.

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
new SimpleRest()..registerEndpoints(new Endpoint())..listen('0.0.0.0', 9000);
```

*One might ask why an instantiated object is provided to the registerEndpoints method? This is a design point of view because the user might have to do some IoC and consequently would not want me to instantiate that Object for him.*

Please, do not hesitate to open issues in case of bugs or if you think I am missing some important features. Pull requests are also welcome.

#### Positional parameters
It is important to understand that when the method is invoked the parameters are provided positionally as they are declared in the URI. This means that if I have the following URI - '/{id}/foo/{bar}'  - my method signature has to be : 
```Dart
anything(HttpRequest req, String id, String bar) {...}
```
And cannot be : 
```Dart
anything(HttpRequest req, String bar, String id) {...}
```
#### Parameter transformation aka Transformer

Shipping with version 0.0.3, the transformers enable to get the parameter in your request directly parsed into a specific type instead of having to declare a String which would have to be parsed manually.

Restart ships with the following transformers: 
* String - this is obvious but for equality any String is going through a String transformer which is nothing but the identity function
* int
* num
* bool
* DateTime

Some "basic" types might have been forgotten, so please do not hesitate to open a pull-request.

It is also possible for you to register your own transformers to extend Restart abilities. To do so, it is required that your transformation function respect the Transformer typedef given below : 
```Dart
typedef dynamic Transformer(String val);
```
Then the final step is just to register the transformer for a given symbol within Restart through the registerTransformer method which takes two parameters: a Symbol and a transformation function. This would give for example : 
```Dart
new Restart().registerTransformer(#int, intTransformer);
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

# Changelog
## 0.0.3
* Adding the parameter transformation through Transformers
 
## 0.0.2
* Updating the SDK version to be compatible with the 1.6.0 project

## 0.0.1
Basic functionnalities: 
* Common REST verbs: GET, POST, PUT, DELETE
* Ability to extend the existing verbs
* Ability to get immediately the parameters extracted positionally (c.f. previously)
