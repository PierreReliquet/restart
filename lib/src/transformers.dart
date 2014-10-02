part of restart;

/**
 * Defines the signature which should be respected for a transformer.
 */
typedef dynamic Transformer(String val);

/**
 * Transforms easily a string in string (identity function). 
 * This method has been designed to show that all types are considered equally.
 */
String stringTransformer(String s) => s;
/**
 * Transforms a String into an int by calling the int.parse method.
 */
int intTransformer(String s) => int.parse(s);
/**
 * Transforms a String into num by calling the num.parse method.
 */
num numTransformer(String s) => num.parse(s);
/**
 * Transforms a String into a boolean value. 
 */
bool boolTransformer(String s) => s.trim() == "true";
/**
 * Transforms a String into a DateTime.
 */
DateTime dateTimeTransformer(String s) => DateTime.parse(s);
  