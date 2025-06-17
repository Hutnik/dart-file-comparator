import 'dart:io';
import 'dart:typed_data';

import 'package:args/args.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

const String version = '0.0.1';

String firstFileHash = "";
String secondFileHash = "";

ArgParser buildParser() {
  return ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Print this usage information.',
    )
    ..addFlag(
      'verbose',
      abbr: 'v',
      negatable: false,
      help: 'Show additional command output.',
    )
    ..addFlag('version', negatable: false, help: 'Print the tool version.');
}

void printUsage(ArgParser argParser) {
  print('Usage: dart dart_file_comparator.dart <flags> [arguments]');
  print(argParser.usage);
}

Future<void> main(List<String> arguments) async {
  final ArgParser argParser = buildParser();
  try {
    final ArgResults results = argParser.parse(arguments);
    bool verbose = false;

    // Process the parsed arguments.
    if (results.flag('help')) {
      printUsage(argParser);
      return;
    }
    if (results.flag('version')) {
      print('dart_file_comparator version: $version');
      return;
    }
    if (results.flag('verbose')) {
      verbose = true;
    }

    // Act on the arguments provided.
    print('Positional arguments: ${results.rest}');
    if (verbose) {
      print('[VERBOSE] All arguments: ${results.arguments}');
    }

    if (results.rest.length < 2) {
      print("at least 2 files are required");
      return;
    }
    var firstFile = File(results.rest[0]);
    var secondFile = File(results.rest[1]);

    firstFileHash = await getFileMd5(firstFile);
    secondFileHash = await getFileMd5(secondFile);
    if (firstFileHash == secondFileHash) {
      print("The files are matching");
    } else {
      print(firstFileHash);
      print(secondFileHash);
    }

  } on FormatException catch (e) {
    // Print usage information if an invalid argument was provided.
    print(e.message);
    print('');
    printUsage(argParser);
  }
}

String generateMd5(String input) {
  return md5.convert(utf8.encode(input)).toString();
}

Future<String> getFileMd5(File file) async {
  var fileData = await file.readAsBytes();
  return md5.convert(fileData).toString();
}
