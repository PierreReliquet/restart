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
  List<String> params;
  MethodMirror mirror;
  InstanceMirror instance;

  Endpoint(String rawUri, this.mirror, this.instance) {
    Type returnType = this.mirror.returnType.reflectedType;
    //TODO get that String comparison out of the way
    if (!(returnType.toString() == "HttpResponse" || returnType.toString() == "Future<HttpResponse>")) {
      throw new _ReturnTypeError();
    }
    if (this.mirror.parameters.first.type.reflectedType != HttpRequest) {
      throw new TypeError();
    }

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

    // The generated regexp needs to be strictly what has been provided by the developer.
    this.regexp = new RegExp("^" + rawUri + r"$");
    this.params = params;
   }

  bool matches(String uri) => regexp.hasMatch(uri);

  /**
   * Invokes the associated method with the provided params.
   * /!\ The first param has to be an HttpRequest
   * @param List params the list of parameters (positional) to pass to the function.
   * @return the result of the function execution which is either a HttpResponse or a
   * Future<HttpResponse>
   */
  invoke(List params) => this.instance.invoke(this.mirror.simpleName, params).reflectee;

}
