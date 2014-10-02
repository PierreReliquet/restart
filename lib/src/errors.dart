part of restart;

/**
 * Indicates a mismatch between the return type of the method (in our case the endpoint) 
 * and the expected one. 
 */
class ReturnTypeError extends Error {
  Type encounteredType;
  Type expectedType;

  ReturnTypeError(this.encounteredType, this.expectedType);

  toString() => "Return type of the method should be $expectedType and was $encounteredType";
}

/**
 * Indicates that a parameter does not have the expected type.
 */
class BadParameterError extends Error {
  Type encounteredType;
  Type expectedType;

  BadParameterError(this.encounteredType, this.expectedType);

  toString() => "Parameter type of the method should be $expectedType and not $encounteredType";
}

/**
 * Indicates that two endpoints have been registered with the same [HttpEndpoint] and the same URI.
 */
class DuplicatedURIHandler extends Error {
  String uri;

  DuplicatedURIHandler(this.uri);

  toString() => "$uri is declared in two handlers which is not compatible with restart";
}