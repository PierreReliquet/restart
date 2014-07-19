import 'package:unittest/unittest.dart';
import 'package:restart/restart.dart';
import 'dart:async';
import 'dart:io';
import 'mocks/MockHttpRequest.dart';

void main() {
  test('Should make a future from an object', () {
    var future = toFuture("String");
    expect(future is Future, true);
    future.then((value) {
      expect(value, "String");
    });
  });

  test('should return a bad request', () {
    HttpRequest req = new MockHttpRequest();
    MockHttpResponse resp = req.response;
    badRequest(req, "foo");
    expect(resp.statusCode, HttpStatus.BAD_REQUEST);
    expect(resp.body, "foo");
    expect(resp.closeCalled, true);
    expect(resp.writeCalled, true);
  });
}
