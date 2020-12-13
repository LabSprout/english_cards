import 'dart:convert';

class Word {
  String head;
  String json;

  Word(this.head, this.json);
}

class WordData {
  String head;
  List<Entry> entries;

  WordData(this.head, this.entries);
}

class Entry {
  String audioURL;
  String ipa;
  List<Sense> senses;
  String category;

  Entry(this.audioURL, this.ipa, this.senses, this.category);
}

class Sense {
  String def;
  String example;

  Sense(this.def, this.example);
}

WordData convertToWordData(Word word) {
  List<Entry> entries = [];
  Map map = jsonDecode(word.json);

  List jsonEntries = map["results"][0]["lexicalEntries"];

  jsonEntries.forEach((element) {
    String audioFile = element["entries"][0]["pronunciations"][1]["audioFile"];
    String ipa = element["entries"][0]["pronunciations"][1]["phoneticSpelling"];

    List jsonSenses = element["entries"][0]["senses"];
    List<Sense> senses = [];

    jsonSenses.forEach((element1) {
      String def = element1["definitions"][0];

      print(def);
      print(element1);
      String example = "";
      if (element1.containsKey("examples")) {
        print("yes");
        example = element1["examples"][0]["text"];
      }
      print("all");

      Sense sense = new Sense(def, example);

      senses.add(sense);
    });

    String category = element["lexicalCategory"]["text"];

    Entry entry = new Entry(audioFile, ipa, senses, category);

    entries.add(entry);
  });

  return new WordData(word.head, entries);
}