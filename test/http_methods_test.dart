import 'package:unittest/unittest.dart';
import 'package:restart/restart.dart' show HttpMethod;

void main() {
  test('Verifying the HttpMethods', () {
    expect(HttpMethod.GET, 'GET');
    expect(HttpMethod.POST, 'POST');
    expect(HttpMethod.PUT, 'PUT');
    expect(HttpMethod.DELETE, 'DELETE');
  });
}