part of restart;

/**
 * The modelisation of an [Endpoint] for the REST API.
 */
class Endpoint {
  static final RegExp _paramMatcher = new RegExp(r"{[a-zA-Z0-9]+}");
  static final String _regexParam = "(.*)";
  RegExp regexp;
  List<String> params;
  MethodMirror mirror;
  InstanceMirror instance;

  Endpoint(String rawUri, this.mirror, this.instance) {
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

     this.regexp = new RegExp("^" + rawUri + r"$");
     this.params = params;
   }

  bool matches(String uri) => regexp.hasMatch(uri);

}
