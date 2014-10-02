part of restart;

class Restart {

  /// The Map which stores the many endpoints used by the application.
  static final Map<String, Set<Endpoint>> _endpoints = {};
  
  /// The map storing all the transformers registered to transform String into some specific object types.
  static final Map<Symbol, Transformer> _transformers = {};

  /// The singleton private instance which can be only accessed from within the class
  static final Restart _instance = new Restart._internal();

  /// Internal constructor to provide the singleton
  Restart._internal() {
    _initializeTransformers();
  }

  /**
   * A factory constructor which returns the singleton instance.
   */
  factory Restart() {
    return _instance;
  }

  /**
   * Returns a new copy of the endpoints.
   * The map can be modified without altering the Restart registered endpoints.
   */
  Map<String, Set<Endpoint>> get endpoints => new Map.from(_endpoints);
  
  /**
   * Registers a new transformer to enhance the Restart conversion ability. 
   * @param [Symbol] s the symbol targetted by the transformer : String => Symbol
   * @param [Transformer] transformer the transformer enabling the transformation
   * @return a boolean indicating if the transformer has been registered or if one was
   * already present. 
   */
  bool registerTransformer(Symbol s, Transformer transformer) {
    if(_transformers.containsKey(s)) {
      return false;
    } else {
      _transformers[s] = transformer;
      return true;
    }
  }
  
  /**
   * Gets the transformer associated with the given symbol.
   * @param [Symbol] s the provided symbol for which a transformer should be get.
   * @return [Transformer] the transformer corresponding or null if none can be found.
   */
  Transformer getTransformer(Symbol s) => _transformers[s];

  /**
   * Starts an [HttpServer] and configure it with the provided endpoints. It is also been configured
   * with the provided [ip] and [port].
   *
   * If the [ip] is not provided, the default value is "0.0.0.0" (localhost exported even for other computer).
   *
   * If the [port] is not provided the default value has been set to 9000.
   * 
   * If an incoming request does not match any endpoint a 401 (bad request) status code is responded.
   * 
   * @param [String] ip the IP exposed
   * @param [int] port the port to which restart is going to be bound
   */
  void listen({String ip: "0.0.0.0", int port: 9000}) {
    // Let's bind the server to start listening
    HttpServer.bind(ip, port).then((HttpServer server) {
      server.listen((HttpRequest req) {
        return _handle(req, _endpoints[req.method]);
     });
    });
  }

  /**
   * Reflects on an object to get all the endpoints from it. 
   * This means that this method is going to parse the object to find
   * all the methods declared inside and check for each method if it
   * has been annotated with an annotation inheriting from [HttpEndpoint].
   * @param Object obj the obj which is going introspected.
   */
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
            // If the endpoint already exists for the given HttpMethod let's throw an exception
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
   * Registers all the standard transformers to ensure that Restart provides
   * the automatic transformation for the "standard types" which are the following:
   * - int
   * - num
   * - bool
   * - String (obviously)
   * - DateTime
   */
  void _initializeTransformers() {
    registerTransformer(#int, intTransformer);
    registerTransformer(#num, numTransformer);
    registerTransformer(#bool, boolTransformer);
    registerTransformer(#DateTime, dateTimeTransformer);
    registerTransformer(#String, stringTransformer);
  }

  /**
   * Internal method for handling the [HttpRequest] received.
   * - Returns a 401 if no endpoint can be found for the requested URI.
   */
  Future<HttpResponse> _handle(HttpRequest req, Set<Endpoint> set) {
    // Let's find the endpoints matching the request
    var endpoints = set.where((e) => e.matches(req.uri.toString()));
    
    // If no endpoints are found so let's return a 401
    if (endpoints.isEmpty) {
      print("No handler for: ${req.method} ${req.uri}");
      return badRequest(req);
    } else {
      var endpoint = endpoints.first;
      // Get the received params
      var receivedParams = _getParamsForIncomingRequest(endpoint, req.uri.toString());
      if (receivedParams.length != endpoint.params.length) {
        // If we do not have the right amount of parameters
        return badRequest(req);
      }
      
      receivedParams.insert(0, req);

      // Finally let's call the method
      var response = endpoint.invoke(receivedParams);
      return _wrapResponse(response);
    }
  }
  
  /**
   * Gets the parameters extracted from an incoming request.
   * @param [Endpoint] the matching endpoint
   * @param [String] uri the requested URI
   * @return [List] the list of parameters (not typed to be able to insert the 
   * [HttpRequest] later.
   */
  List _getParamsForIncomingRequest(Endpoint endpoint, String uri) {
    var params = [];
    Match match = endpoint.regexp.firstMatch(uri);
    var urlParams = match.groupCount;
    for (var i = 1; i <= urlParams; i++) {
      params.add(match.group(i));
    }
    return params;
  }
  
  /**
   * Wraps the HttpResponse into a future if this is required.
   * @param a [HttpResponse] or a [Future]<[HttpResponse]> 
   */
  Future<HttpResponse> _wrapResponse(response) {
    // if we just have a HttpResponse let's wrap it in a future
    if (response is HttpResponse) { 
      return toFuture(response);
    }
    return response;
  }
}