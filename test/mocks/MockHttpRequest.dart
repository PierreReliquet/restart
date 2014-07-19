import 'dart:io';
import 'dart:async';

class MockHttpRequest extends HttpRequest {

  HttpResponse response = new MockHttpResponse();

  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockHttpResponse extends HttpResponse {

  var body;

  bool writeCalled = false;
  bool closeCalled = false;

  @override
  Future close() {
   closeCalled = true;
   return new Future(() => body);
  }

  @override
  void write(Object obj) {
    writeCalled = true;
    body = obj;
  }

  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}