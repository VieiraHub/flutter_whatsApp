
class User {

  String _idUser;
  String _name;
  String _email;
  String _pass;
  String _urlImage;


  User();

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {
      "name" : this.name,
      "email" : this.email
    };
    return map;
  }


  String get idUser => _idUser;

  set idUser(String value) {  _idUser = value;  }

  String get pass => _pass;

  set pass(String value) {  _pass = value;  }

  String get urlImage => _urlImage;

  set urlImage(String value) {  _urlImage = value;  }

  String get email => _email;

  set email(String value) {  _email = value;  }

  String get name => _name;

  set name(String value) {  _name = value;  }
}