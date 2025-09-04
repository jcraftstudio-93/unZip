import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class Unzipper {
  static Future<List<String>?> pickAndExtractZipFile() async {
    // zip 파일 선택
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );

    if (result == null || result.files.isEmpty) return null;

    final file = File(result.files.single.path!);
    final bytes = file.readAsBytesSync();

    // 압축 해제
    final archive = ZipDecoder().decodeBytes(bytes);

    // 압축 해제 위치
    final outputDir = await getApplicationDocumentsDirectory();
    final extractionPath = Directory('${outputDir.path}/unzipped');
    if (!extractionPath.existsSync()) {
      extractionPath.createSync(recursive: true);
    }

    List<String> files = [];

    for (final file in archive) {
      final filePath = p.join(extractionPath.path, file.name);
      if (file.isFile) {
        final outFile = File(filePath);
        outFile.createSync(recursive: true);
        outFile.writeAsBytesSync(file.content as List<int>);
        files.add(file.name);
      } else {
        Directory(filePath).createSync(recursive: true);
      }
    }

    return files;
  }
}
