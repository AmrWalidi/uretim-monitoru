import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

Future<String> getImagePath(File imageFile) async {
  final appDir = await getApplicationDocumentsDirectory();
  final fileName = p.basename(imageFile.path);
  final savedImage = await imageFile.copy('${appDir.path}/$fileName');
  return savedImage.path;
}