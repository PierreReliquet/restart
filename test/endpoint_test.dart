import 'package:unittest/unittest.dart';
import 'dart:mirrors';
import 'package:restart/restart.dart';
import 'dart:io';
import 'mocks/MockHttpRequest.dart';

class TestClass {
  HttpResponse testFn(HttpRequest req) {return null;}

  HttpRequest badReturnType(HttpRequest req) {return null;}

  correctReturnType(HttpRequest req) {}

  badFirstParameter(HttpResponse resp) {}

  correctFirstParameter(var req) {}

  HttpResponse testingParameters(HttpRequest req, int id, String name, bool test) {
    return req.response..write({
      'id': id,
      'name': name,
      'test': test
    });
  }
}


void main() {
  InstanceMirror im = reflect(new TestClass());

  var methodMirror = im.type.instanceMembers[#testFn];
  Endpoint endpoint = new Endpoint('/{foo}/api/{bar}', methodMirror, im);

  test('Testing the endpoint constructor', () {
    expect(endpoint.regexp.pattern, '^/(.+)/api/(.+)\$');
    expect(endpoint.mirror, methodMirror);
    expect(endpoint.instance, im);
    expect(endpoint.params, ['foo', 'bar']);
  });

  test('Testing the method invokation', () {
    expect(endpoint.invoke([new MockHttpRequest()]), null);
  });
  
  test('Invoking the method with parameters to validate the transformers', () {
    var m = im.type.instanceMembers[#testingParameters];
    Endpoint e = new Endpoint('/{id}/api/{name}/test/{test}', m, im);
    MockHttpResponse result = e.invoke([new MockHttpRequest(), '2', 'pierre', 'true']);
    expect(result.body, {'id': 2, 'name': 'pierre', 'test': true});
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