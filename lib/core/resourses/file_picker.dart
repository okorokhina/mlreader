import 'dart:io';

import 'package:file_picker/file_picker.dart';

class Picker{

  Future<String> openFileExplorer() async {
    if(Platform.isAndroid){
      return  FilePicker.getFilePath(type: FileType.AUDIO);
    }
    else{
      return FilePicker.getFilePath(type: FileType.CUSTOM, fileExtension: 'mp3');
    }
    
  }
}