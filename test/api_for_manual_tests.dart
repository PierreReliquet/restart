import 'package:restart/restart.dart';
import 'dart:io';
class Endpoints {
  @Get('/foo/{id}')
  HttpResponse get(HttpRequest req, int id) {
    return req.response..statusCode = 200..write("Hello $id")..close();
  }
}

main() {
  new Restart()..registerEndpoints(new Endpoints())..listen(port: 9999);
}