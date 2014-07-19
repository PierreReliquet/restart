import 'package:unittest/unittest.dart';
import 'package:restart/restart.dart';
import 'dart:mirrors';

class AnnotationsTest {
  @Get('/get')
  var get;
  @Post('/post')
  var post;
  @Put('/put')
  var put;
  @Delete('/delete')
  var delete;
}

void main() {
  test("Testing the http endpoints annotations", () {
    ClassMirror clazz = reflectClass(AnnotationsTest);
    var annotation = clazz.declarations[new Symbol("get")].metadata[0].reflectee;
    expect(annotation is Get, true);
    expect((annotation as Get).uri, '/get');

    annotation = clazz.declarations[new Symbol("post")].metadata[0].reflectee;
    expect(annotation is Post, true);
    expect((annotation as Post).uri, '/post');

    annotation = clazz.declarations[new Symbol("put")].metadata[0].reflectee;
    expect(annotation is Put, true);
    expect((annotation as Put).uri, '/put');

    annotation = clazz.declarations[new Symbol("delete")].metadata[0].reflectee;
    expect(annotation is Delete, true);
    expect((annotation as Delete).uri, '/delete');
  });
}