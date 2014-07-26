import 'package:restart/restart.dart';
import 'package:unittest/unittest.dart';

class WrongClassWithTwoHandlersForOneRouteAndMethod {
  @Get('/api')
  first(req) {}

  @Get('/api')
  second(req) {}
}

void main() {
  test('Should not manage to register two handlers of the same URI', () {
    try {
      new Restart()..registerEndpoints(new WrongClassWithTwoHandlersForOneRouteAndMethod());
      expect(true, false);
    } catch (e) {
      if (!(e is DuplicatedURIHandler)) {
        expect(true, false);
      }
    }

  });
}