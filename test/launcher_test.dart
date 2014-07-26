library restart_test;

import 'endpoint_test.dart' as endpoint;
import 'http_endpoints_test.dart' as httpEndpoints;
import 'responses_test.dart' as responses;

void main() {
  endpoint.main();
  httpEndpoints.main();
  responses.main();
}