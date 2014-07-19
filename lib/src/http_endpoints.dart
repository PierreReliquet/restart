part of restart;

/**
 * Represents an [HttpEndpoint] which can be accessed via REST.
 */
abstract class HttpEndpoint {
  String get uri;
}

/**
 * The GET annotation [HttpEndpoint] which indicates that the method should be
 * called on GET on the given URI.
 */
class Get implements HttpEndpoint{
  final String uri;
  const Get(this.uri);
}

/**
 * The POST annotation [HttpEndpoint] which indicates that the method should be
 * called on POST on the given URI.
 */
class Post implements HttpEndpoint{
  final String uri;
  const Post(this.uri);
}

/**
 * The PUT annotation [HttpEndpoint] which indicates that the method should be
 * called on PUT on the given URI.
 */
class Put implements HttpEndpoint{
  final String uri;
  const Put(this.uri);
}

/**
 * The DELETE annotation [HttpEndpoint] which indicates that the method should be
 * called on DELETE on the given URI.
 */
class Delete implements HttpEndpoint{
  final String uri;
  const Delete(this.uri);
}
