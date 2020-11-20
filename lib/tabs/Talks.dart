import 'dart:async';
import 'package:flutter/material.dart';
import 'package:whats_app/model/Talk.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:whats_app/model/User.dart';

class Talks extends StatefulWidget {
  @override
  _TalksState createState() => _TalksState();
}

class _TalksState extends State<Talks> {

  List<Talk> _talksList = List();
  final _controller = StreamController<QuerySnapshot>.broadcast();
  Firestore db = Firestore.instance;
  String _idLoggedUser;


  @override
  void initState() {
    super.initState();
    _loadInitialData();

    Talk talk = Talk();
    talk.name = "Ana Clara";
    talk.message = "Olá tudo bem?";
    talk.photoPath = "https://firebasestorage.googleapis.com/v0/b/what-saap-b8ed9.appspot.com/o/profile%2Fperfil1.jpg?alt=media&token=cb9d5cd4-2c53-4744-9135-ff1adbd842ba";
    _talksList.add(talk);
  }

  Stream<QuerySnapshot> _addListenerTalks() {
    final stream = db.collection("talks")
        .document(_idLoggedUser)
        .collection("last_talk")
        .snapshots()
        .listen((data) { _controller.add(data);});
  }

  _loadInitialData() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser userLogged = await auth.currentUser();
    _idLoggedUser = userLogged.uid;
    _addListenerTalks();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.close();
  }


  @override
  Widget build(BuildContext context) {

    return StreamBuilder<QuerySnapshot>(
      stream: _controller.stream,
      // ignore: missing_return
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
          return Center(
              child: Column(children: [
                Text("Loading talks"),
                CircularProgressIndicator()
              ]));
          break;
          case ConnectionState.active:
          case ConnectionState.done:
          if (snapshot.hasError) {
            return Text("Error loading data!");
          } else {
            QuerySnapshot querySnapshot = snapshot.data;
            if( querySnapshot.documents.length == 0){
              return Center(
                  child: Column(children: [
                    Text("Loading talks"),
                    CircularProgressIndicator()
                  ]));
            }
            return ListView.builder(
                itemCount: _talksList.length,
                itemBuilder: (context, index) {
                  List<DocumentSnapshot> talks = querySnapshot.documents.toList();
                  DocumentSnapshot item = talks[index];

                  String urlImage = item["photoPath"];
                  String type = item["messageType"];
                  String message = item["message"];
                  String name = item["name"];
                  String idReceiver = item["idReceiver"];

                  User user = User();
                  user.name = name;
                  user.urlImage = urlImage;
                  user.idUser = idReceiver;

                  return ListTile(
                      onTap: (){  Navigator.pushNamed(context, "/messages", arguments: user);  },
                      contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                      leading: CircleAvatar(
                          maxRadius: 30,
                          backgroundColor: Colors.grey,
                          backgroundImage: urlImage != null
                              ? NetworkImage(urlImage)
                              : null
                      ),
                      title: Text( name,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16
                          )
                      ),
                      subtitle: Text(
                          type == "text" ? message : "Image...",
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14
                          )
                      )
                  );
                }
            );
          }
        }
      },
    );


  }
}
