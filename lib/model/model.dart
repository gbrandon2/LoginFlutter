import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:login/model/course.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Model extends ChangeNotifier {
  String username;
  String name;
  String token;
  List<Course> cursos;
  bool logged;

  Model({this.token, this.username, this.name});

  factory Model.fromJson(Map<String, dynamic> json) {
    return Model(
        token: json['token'], username: json['username'], name: json['name']);
  }

  update(Model user) {
    this.username = user.username;
    this.name = user.name;
    this.token = user.token;
    notifyListeners();
  }

  Future<Model> login(String email, String password) async {
    final http.Response response = await http.post(
        "https://movil-api.herokuapp.com/signin",
        headers: <String, String>{
          'Content-type': 'application/json; charset=UTF-8'
        },
        body:
            jsonEncode(<String, String>{'email': email, 'password': password}));

    if (response.statusCode != 200) {
      Map mapREf = json.decode(response.body);

      return throw Exception(mapREf['error'].toString());
    }

    return Model.fromJson(json.decode(response.body));
  }

  Future<Model> signup(
      String username, String password, String email, String name) async {
    final http.Response response = await http.post(
        "https://movil-api.herokuapp.com/signup",
        headers: <String, String>{
          'Content-type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'username': username,
          'password': password,
          'name': name
        }));

    if (response.statusCode != 200) {
      Map mapREf = json.decode(response.body);

      return throw Exception(mapREf['error'].toString());
    }

    return Model.fromJson(json.decode(response.body));
  }

  // Caches logging information
  cacheIt(Model user) async {
    logged = true;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("logged", true);
    await prefs.setString("username", user.username);
    await prefs.setString("name", user.name);
    await prefs.setString("token", user.token);

    notifyListeners();
  }

  logout() async {
    logged = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("logged");
    await prefs.remove("username");
    await prefs.remove("name");
    await prefs.remove("token");
    notifyListeners();
  }

  obtenerCursos() async {
    Uri uri = Uri.https("movil-api.herokuapp.com", '${this.username}/courses');
    final http.Response response = await http.get(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: "Bearer " + this.token,
      },
    );
    print(response.body);
    if (response.statusCode == 200) {
        final data=jsonDecode(response.body);
        for(Map i in data){
          
          this.cursos.add(Course.fromJson(i));
        }
    }
  }

  void addCourse() async {
    Uri uri = Uri.https("movil-api.herokuapp.com", '${this.username}/courses');
    final http.Response response =
        await http.post(uri, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      HttpHeaders.authorizationHeader: "Bearer " + this.token,
    });

    print(uri);
    print('${response.statusCode}');
    print('response -> ${response.body}');
  }
}
