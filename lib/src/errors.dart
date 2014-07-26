part of restart;

class ReturnTypeError extends Error {
  Type encounteredType;
  Type expectedType;

  ReturnTypeError(this.encounteredType, this.expectedType);

  toString() => "Return type of the method should be $expectedType and was $encounteredType";

}

class BadParameterError extends Error {
  Type encounteredType;
  Type expectedType;

  BadParameterError(this.encounteredType, this.expectedType);

  toString() => "Parameter type of the method should be $expectedType and not $encounteredType";
}