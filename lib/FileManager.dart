import 'package:english_cards/WordData.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

saveWordText(String word, String json) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File(directory.path + '/word_' + word + '.txt');

  file.writeAsString(json);
}

deleteWordText(String word) async {
  final directory = await getApplicationDocumentsDirectory();
  File file = new File(directory.path + '/word_' + word + '.txt');

  if (file.existsSync()) {
    file.delete();
  }
}

Future<String> getWordText(String word) async {
  final directory = await getApplicationDocumentsDirectory();

  File file = new File(directory.path + '/word_' + word + '.txt');
  if (await file.exists()) {
    return file.readAsString();
  } else {
    return "";
  }
}

saveWordsList(List<Word> list) async {
  String str = "";
  list.forEach((element) {
    str += element.head + "\n";
  });

  final directory = await getApplicationDocumentsDirectory();
  final file = File(directory.path + '/words_list.txt');

  if (file.existsSync()) {
    file.delete();
  }

  file.writeAsString(str);
}

Future<List<Word>> getWordsList() async {
  final directory = await getApplicationDocumentsDirectory();

  File file = new File(directory.path + '/words_list.txt');
  if (await file.exists()) {
    List<String> list = await file.readAsLines();
    List<Word> result = [];
    list.forEach((element) {
      result.add(new Word(element, ""));
    });

    return result;
  } else {
    return [];
  }
}