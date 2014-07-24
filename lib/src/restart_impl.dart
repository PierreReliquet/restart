part of restart;

class Restart {
  static final Map<String, List<Endpoint>> _endpoints = {};
  static final Restart _instance = new Restart._internal();

  // Internal constructor to provide the singleton
  Restart._internal() {}

  factory Restart() {
    return _instance;
  }

  /**
   * Returns a new copy of the endpoints.
   * The map can be modified without altering the Restart registered endpoints.
   */
  Map<String, List<Endpoint>> get endpoints => new Map.from(_endpoints);

  void registerEndpoints(Object obj) {
    InstanceMirror instance = reflect(obj);
    ClassMirror clazz = instance.type;

    clazz.instanceMembers.forEach((symbol, MethodMirror methodMirror) {
      methodMirror.metadata.forEach((InstanceMirror im) {
        if (im.reflectee is HttpEndpoint) {
          var uri = (im.reflectee as HttpEndpoint).uri;
          // Let's get it to uppercase
          var method = im.reflectee.runtimeType.toString().toUpperCase();
          // Create the local endpoint
          var endpoint = new Endpoint(uri, methodMirror, instance);
          // Finally register it
          if(_endpoints.containsKey(method)) {
            _endpoints[method].add(endpoint);
          } else {
            _endpoints.putIfAbsent(method, () => [endpoint]);
          }
        }
      });
    });
  }

  /**
   * Internal method for handling the [HttpRequest] received.
   */
  Future<HttpResponse> _handle(HttpRequest req, List<Endpoint> list) {
    var endpoints = list.where((e) => e.matches(req.uri.toString()));
    if (endpoints.isEmpty || endpoints.length > 1) {
      print("${endpoints.length} handler(s) found for ${req.method} - ${req.uri}");
      return badRequest(req);
    } else {
      var endpoint = endpoints.first;
      Match match = endpoint.regexp.firstMatch(req.uri.toString());
      var urlParams = match.groupCount;
      if (urlParams != endpoint.params.length) {
        // Here we don't have the right number of parameters
        return badRequest(req);
      } else {
        // Here we generate the parameters which are for now positional
        var invokeParams = [req];
        for (var i = 1; i <= urlParams; i++) {
          invokeParams.add(match.group(i));
        }

        // Finally let's call the method
        var response = endpoint.invoke(invokeParams);

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
  void listen({String ip: "0.0.0.0", int port: 9000}) {
    // Let's bind the server to start listening
    HttpServer.bind(ip, port).then((HttpServer server) {
      server.listen((HttpRequest req) {
        return _handle(req, _endpoints[req.method]);
     });
    });
  }
}