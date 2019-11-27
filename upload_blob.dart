import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:dio/dio.dart';
import 'package:dio_http2_adapter/dio_http2_adapter.dart'; 

main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption("target", abbr: 't')
    ..addOption("file", abbr: 'f')
    ..addFlag("http2");
  var argResults = parser.parse(arguments);
  var dio = Dio();
  if(argResults["http2"]) {
    print("Using http2");
    dio.httpClientAdapter = Http2Adapter(ConnectionManager(idleTimeout: 10000));
  } else {
    print("Using http1");
  }
  var formData = FormData.fromMap({
    "file": await MultipartFile.fromFile(argResults["file"], filename: "file"),
  });
  var startTime = new DateTime.now();
  print("Started at $startTime");
  try {
    var response = await dio.put(argResults["target"], data: formData);
    print(response);
  } catch (e) {
    print(e);
    
  };
  var endTime = new DateTime.now();
  print("Ended at $endTime");
  print("Upload took ${endTime.difference(startTime)}");
}
