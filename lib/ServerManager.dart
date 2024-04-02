
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';

class ServerManager {
  late Map<String, String>? idTokenPost = null;
  ServerManager._privateConstructor();

  static ServerManager manager = ServerManager._privateConstructor();
  factory ServerManager() {
    return manager;
  }

  void googleSignIn() async {
    final GoogleSignInAccount? user = await GoogleSignIn(scopes: ['email'], clientId: "465811042306-csij9204aao2qut6vjetrru3h6doou8r.apps.googleusercontent.com", serverClientId: "465811042306-dom6qsketvf42g5k2v7uva69memphqg5.apps.googleusercontent.com").signIn();
    
    if (user != null) {
      final GoogleSignInAuthentication auth = await user.authentication;
      idTokenPost = Map<String, String>.from({"id_token": auth.idToken});

      //Map<String, String> headers = Map<String, String>.from({"id_token": auth.idToken, "access_token": auth.accessToken});

      //var response = await http.post(Uri.parse("http://130.162.169.225/test.php"), headers: headers, body: headers);
      //var test = response.body;
      //print(test);
      //print(auth.accessToken);
    }
  }

  Future<bool> addBookmark(int osmId, String osmType) async {
    final searchResponse = await http.post(Uri.parse("http://130.162.169.225/createbookmark.php?osm_id=${Uri.encodeComponent("${osmId}")}&osm_type=${Uri.encodeComponent(osmType)}"), headers: idTokenPost, body: idTokenPost);
    if (searchResponse.statusCode == 200) {return true;} else {return false;}
  }
}