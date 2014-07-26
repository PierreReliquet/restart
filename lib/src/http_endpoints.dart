part of restart;

/**
 * Represents an [HttpEndpoint] which can be accessed via REST.
 */
abstract class HttpEndpoint {
  final String uri;
  const HttpEndpoint(this.uri);
}

/**
 * The GET annotation [HttpEndpoint] which indicates that the method should be
 * called on GET on the given URI.
 */
class Get extends HttpEndpoint{
  const Get(String uri) : super(uri);
}

/**
 * The POST annotation [HttpEndpoint] which indicates that the method should be
 * called on POST on the given URI.
 */
class Post extends HttpEndpoint{
  const Post(String uri) : super(uri);
}

/**
 * The PUT annotation [HttpEndpoint] which indicates that the method should be
 * called on PUT on the given URI.
 */
class Put extends HttpEndpoint{
  const Put(String uri) : super(uri);
}

/**
 * The DELETE annotation [HttpEndpoint] which indicates that the method should be
 * called on DELETE on the given URI.
 */
class Delete extends HttpEndpoint{
  const Delete(String uri) : super(uri);
}