library restart;

import 'package:restart/restart.dart';
import 'package:unittest/unittest.dart';

class WrongClassWithTwoHandlersForOneRouteAndMethod {
  @Get('/wrongapi')
  first(req) {}

  @Get('/wrongapi')
  second(req) {}
}

class ValidRestAPI {
  @Get('/api')
  get(req) {}

  @Post('/api')
  post(req) {}
}

class AnotherValidRestAPI {
  @Put('/api')
  put(req) {}
}

void main() {
  test('Should not manage to register two handlers of the same URI', () {
    try {
      new Restart()..registerEndpoints(new WrongClassWithTwoHandlersForOneRouteAndMethod());
      expect(true, false);
    } catch (e) {
      if (e is DuplicatedURIHandler) {
        expect(true, true);
      } else {
        expect(true, false);
      }
    }
  });

  test('should register three endpoints from two classes', () {
    new Restart()..registerEndpoints(new ValidRestAPI());
    // Let's register another one without using method cascades (to also test the factory)
    new Restart()..registerEndpoints(new AnotherValidRestAPI());

    Map<String, Set<Endpoint>> endpoints = new Restart().endpoints;
    expect(endpoints.length, 3);
    expect(endpoints['GET'].where((e) => e.regexp.pattern == r'^/api$').length, 1);
    expect(endpoints['POST'].where((e) => e.regexp.pattern == r'^/api$').length, 1);
    expect(endpoints['PUT'].where((e) => e.regexp.pattern == r'^/api$').length, 1);
    expect(endpoints['PUT'].first.mirror.simpleName, new Symbol('put'));
  });
}