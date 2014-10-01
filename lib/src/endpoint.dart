part of restart;

/**
 * The modelisation of an [Endpoint] for the REST API.
 */
class Endpoint {
  /// This defines the format of a URI parameter as an alphanumeric chain between brackets {}.
  static final RegExp _paramMatcher = new RegExp(r"{[a-zA-Z0-9]+}");

  // Here we specify that a parameter cannot be empty
  static final String _regexParam = "(.+)";
  RegExp regexp;
  List<String> params = [];
  List<Symbol> paramsType = [];
  MethodMirror mirror;
  InstanceMirror instance;

  Endpoint(String rawUri, this.mirror, this.instance) {
    _validateReturnType();
    _validateFirstParameter();
    _registerParameterTypes();

    rawUri = _initParamsAndGetFormattedURI(rawUri);

    // The generated regexp needs to be strictly what has been provided by the developer.
    this.regexp = new RegExp("^" + rawUri + r"$");
   }
  
  /**
   * Registers the type of each parameter to be able to transform them
   * from String to the right type.
   */
  void _registerParameterTypes() {
    this.mirror.parameters.forEach((ParameterMirror pm) {
      paramsType.add(pm.type.simpleName);
    });
  }

  String _initParamsAndGetFormattedURI(String rawUri) {
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
    this.params = params;
    return rawUri;
  }

  void _validateFirstParameter() {
    // Here we handle the case dynamic just in case people would rather write var instead of HttpRequest
    var reqType = this.mirror.parameters.first.type.reflectedType;
    if (!(reqType.toString() == 'HttpRequest' || reqType.toString() == 'dynamic')) {
      throw new BadParameterError(reqType, HttpRequest);
    }
  }

  void _validateReturnType() {
    Type returnType = this.mirror.returnType.reflectedType;
      //TODO get that String comparison out of the way
      if (!(returnType.toString() == "HttpResponse" || returnType.toString() == "Future<HttpResponse>" || returnType.toString() == "dynamic")) {
        throw new ReturnTypeError(returnType, HttpResponse);
      }
  }

  // TODO find a better way because this is not right two endpoints are equal if and only if
  // they have same URI
  // they have same HttpMethod
  bool operator==(e)=> (e is Endpoint && (e as Endpoint).regexp.pattern == regexp.pattern);
  int get hashCode => regexp.pattern.hashCode;

  bool matches(String uri) => regexp.hasMatch(uri);

  /**
   * Invokes the associated method with the provided params.
   * /!\ The first param has to be an HttpRequest
   * @param List params the list of parameters (positional) to pass to the function.
   * @return the result of the function execution which is either a HttpResponse or a
   * Future<HttpResponse>
   */
  invoke(List invokationParams) {
    if (!(invokationParams[0] is HttpRequest)) {
      // First param should be an HttpRequest
      throw new Error();
    }
    var i = 0;
    var transformedParams = [];
    
    // Let's transform the parameters if required
    invokationParams.forEach((s) {
      if(s is String) {
        var transformer = new Restart().getTransformer(paramsType[i]);
        if (transformer != null) {
          s = transformer(s);
        }
      }
      transformedParams.add(s);
      i++;
    });
    
    return this.instance.invoke(this.mirror.simpleName, transformedParams).reflectee;
  }

}
