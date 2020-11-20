import 'package:flutter/material.dart';
import 'package:whats_app/model/Talk.dart';
import 'package:whats_app/model/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Contacts extends StatefulWidget {
  @override
  _ContactsState createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {

  String _idLoggedUser;
  String _emailLoggedUser;

  _recoverUserData() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser userLogged = await auth.currentUser();
    _idLoggedUser = userLogged.uid;
    _emailLoggedUser = userLogged.email;
  }

  Future<List<User>> _recoverContacts() async {
    Firestore db = Firestore.instance;
    QuerySnapshot querySnapshot = await db.collection("user").getDocuments();
    List<User> userList = List();
    for (DocumentSnapshot item in querySnapshot.documents) {
      var data = item.data;
      if( data["email"] == _emailLoggedUser) continue;

      User user = User();
      user.idUser = item.documentID;
      user.email = data["email"];
      user.name = data["name"];
      user.urlImage = data["urlImage"];
      userList.add(user);
    }
    return userList;
  }

  @override
  void initState() {
    super.initState();
    _recoverUserData();
  }



  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<User>>(
      future: _recoverContacts(),
      // ignore: missing_return
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: Column(
                children: [
                  Text("Loading contacts"),
                  CircularProgressIndicator()
                ]
              )
            );
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (_, index) {
                  List<User> itemsList = snapshot.data;
                  User user = itemsList[index];
                  return ListTile(
                      onTap: (){
                        Navigator.pushNamed(context, "/messages", arguments: user);
                      },
                      contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                      leading: CircleAvatar(
                          maxRadius: 30,
                          backgroundColor: Colors.grey,
                          backgroundImage: user.urlImage != null
                              ? NetworkImage(user.urlImage)
                              : null),
                      title: Text(user.name,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16))
                  );
                });
            break;
        }
      },
    );
  }
}
