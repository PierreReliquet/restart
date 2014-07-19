part of restart;

class Restart {
  static final Map<HttpMethod, List<Endpoint>> _endpoints = {};
  static final Restart _instance = new Restart._internal();

  // Internal constructor to provide the singleton
  Restart._internal() {
    _endpoints[HttpMethod.PUT] = [];
    _endpoints[HttpMethod.GET] = [];
    _endpoints[HttpMethod.POST] = [];
    _endpoints[HttpMethod.DELETE] = [];
  }

  factory Restart() {
    return _instance;
  }

  void registerEndpoints(Type type) {

    ClassMirror clazz = reflectClass(type);
    InstanceMirror instance = clazz.newInstance(new Symbol(""), []);

    clazz.instanceMembers.forEach((symbol, MethodMirror methodMirror) {
      methodMirror.metadata.forEach((InstanceMirror im) {
        if (im.reflectee is HttpEndpoint) {
          var uri = (im.reflectee as HttpEndpoint).uri;
          if(im.reflectee is Post) {
            _endpoints[HttpMethod.POST].add(new Endpoint(uri, methodMirror, instance));
          } else if (im.reflectee is Put) {
            _endpoints[HttpMethod.PUT].add(new Endpoint(uri, methodMirror, instance));
          } else if (im.reflectee is Get) {
            _endpoints[HttpMethod.GET].add(new Endpoint(uri, methodMirror, instance));
          } else if (im.reflectee is Delete) {
            _endpoints[HttpMethod.DELETE].add(new Endpoint(uri, methodMirror, instance));
          }
        }
      });
    });
  }

  Future<HttpResponse> _handle(HttpRequest req, List<Endpoint> list) {
    var endpoints = list.where((Endpoint e) => e.regexp.hasMatch(req.uri.toString()));
    if (endpoints.isEmpty || endpoints.length > 1) {
      print("no handler or more than one handler found for " + req.uri.toString());
      return badRequest(req);
    } else {
      var endpoint = endpoints.first;
      var match = endpoint.regexp.firstMatch(req.uri.toString());
      if (match.groupCount != endpoint.params.length) {
        return badRequest(req);
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

  /**
   * Starts an [HttpServer] and configure it with the provided endpoints. It is also been configured
   * with the provided [ip] and [port].
   *
   * If the [ip] is not provided, the default value is "0.0.0.0" (localhost exported even for other computer).
   *
   * If the [port] is not provided the default value has been set to 9000.
   */
  void listen([String ip = "0.0.0.0", int port = 9000]) {
    // Let's bind the server to start listening
    HttpServer.bind(ip, port).then((HttpServer server) {
      server.listen((HttpRequest req) {
        return _handle(req, _endpoints[req.method]);
     });
    });
  }
}