import 'dart:convert';

import 'package:english_cards/WordData.dart';
import 'package:english_cards/FileManager.dart';
import 'package:english_cards/OxfordDictionary.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

void main() => runApp(MyApp());

List<Word> wordList = [];

String search = "";
bool dictionary = false;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'English Cards',
        theme: ThemeData(
          primarySwatch: Colors.yellow,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          accentColor: Colors.lightBlueAccent,
        ),
        home: FutureBuilder(
          future: getWordsList(),
          builder: (BuildContext context,
              AsyncSnapshot<List<Word>> snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Scaffold(
                appBar: AppBar(
                ),
              );
            }
            wordList.addAll(snapshot.data);
            return MyHomePage();
          },
        )
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: Icon(
              Icons.search
          ),
          title: TextField(
            onChanged: (s) {
              setState(() {
                search = s;
                dictionary = true;
                if (s != null && s != '') {
                  wordList.forEach((element) {
                    if (element.head == s) {
                      dictionary = false;
                    }
                  });
                } else {
                  dictionary = false;
                  search = "";
                }
              });
            },
            style: TextStyle(fontSize: 18.0),
          ),
        ),
        body: Container(
            child: Column(
                children: <Widget>[
                  Visibility(
                      visible: dictionary,
                      child: ListTile(
                        title: Text(
                          "Do you want to consult Oxford dictionary?",
                          style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.blue
                          ),
                        ),
                        trailing: RaisedButton(
                          onPressed: () {
                            _onButtonClicked(search);
                          },
                          color: Colors.blue,
                          textColor: Colors.white,
                          child: Text(
                              'Look Up!'
                          ),
                        ),
                      )
                  ),
                  Expanded(
                      child: WordListView()
                  )
                ]
            )
        )
    );
  }

  void _onButtonClicked(String head) {
    setState(() {
      dictionary = false;
    });

    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text(
              head,
              style: TextStyle(color: Colors.blue),
            ),
            children: <Widget>[
              FutureBuilder(
                future: getRequest(head),
                builder: (BuildContext context,
                    AsyncSnapshot<String> snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return LinearProgressIndicator(
                        backgroundColor: Colors.white
                    );
                  } else {
                    if (snapshot.data == null) {
                      return Text('Please check your Internet connection.');
                    }
                    Map map = jsonDecode(snapshot.data);
                    if (!map.containsKey("results")) {
                      return Text('The word "' + head + '" was not found.');
                    }
                    Word word = new Word(head, snapshot.data);
                    WordData wordData = convertToWordData(word);

                    List<Widget> widgets = [];
                    wordData.entries.forEach((entry) {
                      widgets.add(new Divider());

                      widgets.add(new Text(
                        head + ' (' + entry.category + ') [' + entry.ipa + ']',
                        style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.blue
                        ),
                      ));
                      entry.senses.forEach((sense) {
                        widgets.add(new Text(
                            sense.def,
                            style: TextStyle(
                                fontSize: 16.0
                            )
                        ));
                        if (sense.example != "") {
                          widgets.add(new Text(
                            ' ex.) ' + sense.example,
                            style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.grey[700]
                            ),
                          ));
                        }
                      });
                    });

                    wordList.add(word);
                    saveWordText(word.head, word.json);
                    saveWordsList(wordList);

                    return Column(
                      children: widgets,
                      crossAxisAlignment: CrossAxisAlignment.start,
                    );
                  }
                },
              )
            ],
          );
        }
    );
  }
}

class WordListView extends StatefulWidget {
  @override
  _WordListViewState createState() => _WordListViewState();
}

class _WordListViewState extends State<WordListView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: EdgeInsets.all(0),
        itemCount: wordList.length,
        itemBuilder: (context, index) =>
            _buildListView(wordList[wordList.length - index - 1])
    );
  }

  Widget _buildListView(Word data) {
    return Dismissible(
        key: Key(data.head),
        onDismissed: (direction) {
          setState(() {
            wordList.remove(data);
            saveWordsList(wordList);
          });
          Scaffold.of(context).showSnackBar(
              SnackBar(content: Text('"' + data.head + '" has been removed.'))
          );
        },

        background: Container(color: Colors.red),
        child: Visibility(
          visible: (data.head.contains(search)),
          child: ListTile(
            title: Text(
                data.head,
                style: TextStyle(fontSize: 18.0)
            ),
            onTap: () {
              _onListTileClicked(data);
            },
          ),
        )
    );
  }

  void _onListTileClicked(Word data) {
    if (data.json == "") {
      showDialog(
          context: context,
          builder: (context) {
            return SimpleDialog(
              title: Text(
                data.head,
                style: TextStyle(color: Colors.blue),
              ),
              children: <Widget>[
                FutureBuilder(
                    future: getWordText(data.head),
                    builder: (BuildContext context,
                        AsyncSnapshot<String> snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return LinearProgressIndicator();
                      } else {
                        data.json = snapshot.data;
                        return _getDialogWidget(data);
                      }
                    }
                ),
              ],
            );
          }
      );
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return SimpleDialog(
                title: Text(
                  data.head,
                  style: TextStyle(color: Colors.blue),
                ),
                children: <Widget>[_getDialogWidget(data)]
            );
          }
      );
    }
  }

  Widget _getDialogWidget(Word data) {
    WordData wordData = convertToWordData(data);

    List<Widget> widgets = [];
    wordData.entries.forEach((entry) {
      widgets.add(new Divider());

      widgets.add(new Text(
        data.head + ' (' + entry.category + ') [' + entry.ipa + ']',
        style: TextStyle(
            fontSize: 18.0,
            color: Colors.blue
        ),
      ));
      entry.senses.forEach((sense) {
        widgets.add(new Text(
            sense.def,
            style: TextStyle(
                fontSize: 16.0
            )
        ));
        if (sense.example != "") {
          widgets.add(new Text(
            ' ex.) ' + sense.example,
            style: TextStyle(
                fontSize: 16.0,
                color: Colors.grey[700]
            ),
          ));
        }
      });
    });

    return Column(
      children: widgets,
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }
}