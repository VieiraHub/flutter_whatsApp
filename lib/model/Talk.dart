import 'package:cloud_firestore/cloud_firestore.dart';

class Talk {

  String _idSender;
  String _idReceiver;
  String _name;
  String _message;
  String _photoPath;
  String _messageType;


  Talk();

  save() async {
    Firestore db = Firestore.instance;
    await db.collection("talks")
        .document(this.idSender)
        .collection("last_talk")
        .document(this.idReceiver)
        .setData(this.toMap());
  }

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {
      "idSender" : this.idSender,
      "idReceiver" : this.idReceiver,
      "name" : this.name,
      "message" : this.message,
      "photoPath" : this.photoPath,
      "messageType" : this.messageType
    };
    return map;
  }


  String get idSender => _idSender;

  set idSender(String value) {  _idSender = value;  }

  String get name => _name;

  set name(String value) {  _name = value;  }

  String get message => _message;

  String get photoPath => _photoPath;

  set photoPath(String value) {  _photoPath = value;  }

  set message(String value) {  _message = value;  }

  String get idReceiver => _idReceiver;

  set idReceiver(String value) {  _idReceiver = value;  }

  String get messageType => _messageType;

  set messageType(String value) {  _messageType = value;  }
}