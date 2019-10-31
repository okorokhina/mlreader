import 'package:file_picker/file_picker.dart';

class Picker{

  Future<String> openFileExplorer() async {
    return  FilePicker.getFilePath(type: FileType.AUDIO );
  }
}