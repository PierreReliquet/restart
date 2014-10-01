part of restart;

typedef dynamic Transformer(String val);


class NativeTransformers {
  
  static String stringTransformer(String s) => s;
  
  static int intTransformer(String s) => int.parse(s);
  
  static num numTransformer(String s) => num.parse(s);
  
  static bool boolTransformer(String s) => s.trim() == "true";
  
  static DateTime dateTimeTransformer(String s) => DateTime.parse(s);
  
}