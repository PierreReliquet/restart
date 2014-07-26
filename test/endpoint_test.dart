import 'package:unittest/unittest.dart';
import 'dart:mirrors';
import 'package:restart/restart.dart';
import 'dart:io';

class TestClass {
  HttpResponse testFn(HttpRequest req) {return null;}

  HttpRequest badReturnType(HttpRequest req) {return null;}

  correctReturnType(HttpRequest req) {}

  badFirstParameter(HttpResponse resp) {}

  correctFirstParameter(var req) {}

}


void main() {
  InstanceMirror im = reflect(new TestClass());

  var methodMirror = im.type.instanceMembers[new Symbol('testFn')];
  Endpoint endpoint = new Endpoint('/{foo}/api/{bar}', methodMirror, im);

  test('Testing the endpoint constructor', () {
    expect(endpoint.regexp.pattern, '^/(.+)/api/(.+)\$');
    expect(endpoint.mirror, methodMirror);
    expect(endpoint.instance, im);
    expect(endpoint.params, ['foo', 'bar']);
  });

  test('Testing the method invokation', () {
    expect(endpoint.invoke([null]), null);
  });

  test('Testing the matches method', () {
    expect(endpoint.matches('/1/api/2'), true);
  });

  test('Should fail while constructing the endpoint because of the return type', () {
    var methodMirror = im.type.instanceMembers[new Symbol('badReturnType')];
    try {
      Endpoint endpoint = new Endpoint('/{foo}/api/{bar}', methodMirror, im);
      expect(false, true);
    } catch(e) {
      if (e is ReturnTypeError) {
        expect(true, true);
      } else {
        expect(false, true);
      }
    }
  });

  test('Dynamic return type should be accepted', () {
     var methodMirror = im.type.instanceMembers[new Symbol('correctReturnType')];
     Endpoint endpoint = new Endpoint('/{foo}/api/{bar}', methodMirror, im);
     // We should not have an exception
   });

  test('Should fail while constructing the endpoint because of the first parameter', () {
     var methodMirror = im.type.instanceMembers[new Symbol('badFirstParameter')];

     try {
       Endpoint endpoint = new Endpoint('/{foo}/api/{bar}', methodMirror, im);
       expect(true, false);
     } catch (e) {
       if (e is BadParameterError) {
         expect(true, true);
       } else {
         expect(true, false);
       }
     }
     // We should not have an exception
   });


  test('Dynamic return type should be accepted', () {
     var methodMirror = im.type.instanceMembers[new Symbol('correctFirstParameter')];
     Endpoint endpoint = new Endpoint('/{foo}/api/{bar}', methodMirror, im);
     // We should not have an exception
   });
}