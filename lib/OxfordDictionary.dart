import 'package:http/http.dart' as http;

Future<String> getRequest(String head) async {
  head = head.toLowerCase();

  final _language = "en-us";
  final _appId = "<your app id>";
  final _appKey = "<your app key>";

  final _link = "https://od-api.oxforddictionaries.com:443/api/v2/entries/" +
      _language + "/" + head +
      "?fields=definitions%2Cexamples%2Cpronunciations&strictMatch=false";

  try {
    final response = await http.get(_link,
        headers: {
          "Accept": "application/json",
          "app_id": _appId,
          "app_key": _appKey
        });

    return response.body.toString();
  } catch (e, stackTrace) {
    return e + " " + stackTrace;
  }
}
