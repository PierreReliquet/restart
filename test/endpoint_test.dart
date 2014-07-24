import 'package:unittest/unittest.dart';
import 'dart:mirrors';
import 'package:restart/restart.dart';

class TestClass {
  testFn() {}
}


void main() {
  InstanceMirror im = reflect(new TestClass());
  var methodMirror = im.type.instanceMembers[new Symbol('testFn')];
  test('Testing the endpoint constructor', () {
    Endpoint endpoint = new Endpoint('/{foo}/api/{bar}', methodMirror, im);
    expect(endpoint.regexp.pattern, '^/(.*)/api/(.*)\$');
    expect(endpoint.mirror, methodMirror);
    expect(endpoint.instance, im);
    expect(endpoint.params, ['foo', 'bar']);
  });
}