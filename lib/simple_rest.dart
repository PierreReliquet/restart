library simplerest;
import 'dart:mirrors';
import 'dart:async';
import 'dart:io';

abstract class HttpEndpoint {
  String get uri;
}

class Get implements HttpEndpoint{
  final String uri;
  const Get(this.uri);
}

class Post implements HttpEndpoint{
  final String uri;
  const Post(this.uri);
}

class Put implements HttpEndpoint{
  final String uri;
  const Put(this.uri);
}

class Delete implements HttpEndpoint{
  final String uri;
  const Delete(this.uri);
}

class HttpMethod {
  static const GET = "GET";
  static const POST = "POST";
  static const PUT = "PUT";
  static const DELETE = "DELETE";
}

class Endpoint {
  RegExp regexp;
  List<String> params;
  MethodMirror mirror;
  InstanceMirror instance;
}

class SimpleRest {
  static final Map<HttpMethod, List<Endpoint>> _endpoints = {};
  static final SimpleRest _instance = new SimpleRest._internal();

  static final RegExp _paramMatcher = new RegExp(r"{[a-zA-Z0-9]+}");

  static final String _regexParam = "(.*)";

  // Internal constructor to provide the singleton
  SimpleRest._internal();

  factory SimpleRest() {
    return _instance;
  }

  void registerEndpoints(Type type) {
    _endpoints[HttpMethod.PUT] = [];
    _endpoints[HttpMethod.GET] = [];
    _endpoints[HttpMethod.POST] = [];
    _endpoints[HttpMethod.DELETE] = [];

    ClassMirror clazz = reflectClass(type);
    InstanceMirror instance = clazz.newInstance(new Symbol(""), []);

    clazz.instanceMembers.forEach((symbol, MethodMirror methodMirror) {
      methodMirror.metadata.forEach((InstanceMirror im) {
        if (im.reflectee is HttpEndpoint) {
          var uri = (im.reflectee as HttpEndpoint).uri;
          if(im.reflectee is Post) {
            _endpoints[HttpMethod.POST].add(createEndpoint(uri, methodMirror, instance));
          } else if (im.reflectee is Put) {
            _endpoints[HttpMethod.PUT].add(createEndpoint(uri, methodMirror, instance));
          } else if (im.reflectee is Get) {
            _endpoints[HttpMethod.GET].add(createEndpoint(uri, methodMirror, instance));
          } else if (im.reflectee is Delete) {
            _endpoints[HttpMethod.DELETE].add(createEndpoint(uri, methodMirror, instance));
          }
        }
      });
    });
    print(_endpoints);
  }

  Endpoint createEndpoint(String rawUri, MethodMirror methodMirror, InstanceMirror instance) {
    // TODO check that the method mirror returns an HttpResponse or Future<HttpResponse>
    // TODO check that the method takes two arguments HttpRequest + Map
    var params = [];
    var param = _paramMatcher.stringMatch(rawUri);
    while(param != null) {
      rawUri = rawUri.replaceFirst(param, _regexParam);
      param = param.substring(1);
      param = param.substring(0, param.length - 1);
      params.add(param);
      // Taking next
      param = _paramMatcher.stringMatch(rawUri);
    }

    return new Endpoint()
      ..regexp = new RegExp("^" + rawUri + r"$")
      ..params = params
      ..mirror = methodMirror
      ..instance = instance;
  }

  void listen(String ip, int port) {
    // Let's bind the server to start listening
    HttpServer.bind(ip, port).then((HttpServer server) {
      server.listen((HttpRequest req) {
        return _handle(req, _endpoints[req.method]);
     });
    });
  }


  Future<HttpResponse> _handle(HttpRequest req, List<Endpoint> list) {
    var endpoints = list.where((Endpoint e) => e.regexp.hasMatch(req.uri.toString()));
    if (endpoints.isEmpty || endpoints.length > 1) {
      print("no handler or more than one handler found for " + req.uri.toString());
      return _badRequest(req);
    } else {
      var endpoint = endpoints.first;
      var match = endpoint.regexp.firstMatch(req.uri.toString());
      if (match.groupCount != endpoint.params.length) {
        return _badRequest(req);
      } else {
        Map params = {};
        int i = 1;
        endpoint.params.forEach((String value) {
          params[value] = match.group(i);
          i += 1;
        });

        var response = endpoint.instance.invoke(endpoint.mirror.simpleName, [req, params]).reflectee;
        if (response is HttpResponse) { // if we just have a HttpResponse let's wrap it in a future
          response = new Future(() => response);
        }
        return response;
      }
    }
  }

  Future<HttpResponse> _badRequest(HttpRequest req) {
    return new Future(() => req.response..statusCode = HttpStatus.BAD_REQUEST..close());
  }
}