
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:map_app/LocationDetails.dart';
import 'package:map_app/SearchResultRow.dart';
import 'package:map_app/SystemManager.dart';

class ServerManager {
  late GoogleSignInAccount? user = null;
  late Map<String, String>? idTokenPost = null;
  late List<LocationDetails> bookmarks = List.empty(growable: true);
  late Timer timer;
  
  ServerManager._privateConstructor() {
    timer = Timer.periodic(Duration(seconds: 3), (timer) {ServerManager().loadBookmarks();});
  }

  static ServerManager manager = ServerManager._privateConstructor();

  factory ServerManager() {
    return manager;
  }

  void googleSignIn() async {
    try {
      final GoogleSignInAccount? user = await GoogleSignIn(scopes: ['email'], clientId: "465811042306-csij9204aao2qut6vjetrru3h6doou8r.apps.googleusercontent.com", serverClientId: "465811042306-dom6qsketvf42g5k2v7uva69memphqg5.apps.googleusercontent.com").signIn();
      if (user != null) {
        this.user = user;
        final GoogleSignInAuthentication auth = await user.authentication;
        idTokenPost = Map<String, String>.from({"id_token": auth.idToken});
        loadBookmarks();
      }
      SystemManager().updateSignInPromptUI();
    } catch (e) {
    }
  }

  void googleSignOut() async {
    try {
      if (user != null) {
        GoogleSignIn().signOut();
        user = null;
        idTokenPost = null;
      }
      SystemManager().updateSignInPromptUI();
    } catch (e) {
    }
  }

  Future<Response> makeRequest(Uri uri) async {
    return http.post(uri, headers: ServerManager().idTokenPost, body: ServerManager().idTokenPost);
  }

  String body = "";
  int responseCode = -1;
  Future<void> loadBookmarks() async {
    try {
      List<SearchResultRow> newBookmarks = List.empty(growable: true);
      if (ServerManager().idTokenPost != null) {
        final searchResponse = await http.post(Uri.parse("http://130.162.169.225/getbookmarks.php"), headers: ServerManager().idTokenPost, body: ServerManager().idTokenPost);
        body = searchResponse.body;
        responseCode = searchResponse.statusCode;
        if (searchResponse.statusCode == 200) {
          Iterable iter = json.decode(searchResponse.body);
          String lookupParams = "";
          for (Map<String, dynamic> i in iter) {
            lookupParams += "${i['osm_type'][0].toUpperCase()}${i['osm_id']},";
          }

          List<LocationDetails>? results = await LocationDetails.listFromNomLookup(lookupParams);
          if (results != null) {
            bookmarks = results;
            SystemManager().updateBookmarkUI(bookmarks);
          }
        }
      } else {
        SystemManager().updateBookmarkUI(List.empty());
      }
    } catch (e) {
    }
  } 

  Future<bool> addBookmark(int osmId, String osmType) async {
    final searchResponse = await http.post(Uri.parse("http://130.162.169.225/createbookmark.php?osm_id=${Uri.encodeComponent("${osmId}")}&osm_type=${Uri.encodeComponent(osmType)}"), headers: idTokenPost, body: idTokenPost);
    if (searchResponse.statusCode == 200) {return true;} else {return false;}
  }

  Future<bool> removeBookmark(int osmId, String osmType) async {
    final searchResponse = await http.post(Uri.parse("http://130.162.169.225/deletebookmark.php?osm_id=${Uri.encodeComponent("${osmId}")}&osm_type=${Uri.encodeComponent(osmType)}"), headers: idTokenPost, body: idTokenPost);
    if (searchResponse.statusCode == 200) {return true;} else {return false;}
  }
}