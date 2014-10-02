part of restart;

/**
 * A simple wrapper to transform any object into a [Future]
 * to be compatible with the restart API which expects responses
 * to be [Future].
 */
Future toFuture(obj) => new Future(() => obj);

/**
 * Helper making it easy to indicate a bad request (401 status code) for developpers.
 */
Future<HttpResponse> badRequest(HttpRequest req, [message = ""]) =>
    toFuture(req.response..statusCode = HttpStatus.BAD_REQUEST..write(message)..close());

