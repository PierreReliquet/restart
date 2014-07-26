part of restart;

class Restart {

  /// The Map which stores the many endpoints used by the application.
  static final Map<String, Set<Endpoint>> _endpoints = {};

  /// The singleton private instance which can be only accessed from within the class
  static final Restart _instance = new Restart._internal();

  // Internal constructor to provide the singleton
  Restart._internal() {}

  factory Restart() {
    return _instance;
  }

  static Restart get restart => _instance;

  /**
   * Returns a new copy of the endpoints.
   * The map can be modified without altering the Restart registered endpoints.
   */
  Map<String, Set<Endpoint>> get endpoints => new Map.from(_endpoints);

  void registerEndpoints(Object obj) {
    InstanceMirror instance = reflect(obj);
    ClassMirror clazz = instance.type;

    clazz.instanceMembers.forEach((symbol, methodMirror) {
      methodMirror.metadata.forEach((instanceMirror) {
        if (instanceMirror.reflectee is HttpEndpoint) {
          var uri = (instanceMirror.reflectee as HttpEndpoint).uri;
          // Let's get it to uppercase
          var method = instanceMirror.reflectee.runtimeType.toString().toUpperCase();
          // Create the local endpoint
          var endpoint = new Endpoint(uri, methodMirror, instance);
          // Finally register it
          if(_endpoints.containsKey(method)) {
            if (!_endpoints[method].add(endpoint)) {
              throw new DuplicatedURIHandler(uri);
            }
          } else {
            _endpoints.putIfAbsent(method, () => new Set()..add(endpoint));
          }
        }
      });
    });
  }

  /**
   * Internal method for handling the [HttpRequest] received.
   */
  Future<HttpResponse> _handle(HttpRequest req, Set<Endpoint> set) {
    var endpoints = set.where((e) => e.matches(req.uri.toString()));
    if (endpoints.isEmpty) {
      print("No handler for: ${req.method} ${req.uri}");
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