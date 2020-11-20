import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whats_app/model/Talk.dart';
import 'dart:io';
import 'model/Message.dart';
import 'model/User.dart';

class Messages extends StatefulWidget {
  User contact;
  Messages(this.contact);

  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  File _image;
  bool _imageUpload = false;
  String _idLoggedUser;
  String _idUserReceiver;
  TextEditingController _controllerMessage = TextEditingController();
  Firestore db = Firestore.instance;
  final _controller = StreamController<QuerySnapshot>.broadcast();
  ScrollController _scrollController = ScrollController();


  _sendMessage() {
    String messageText = _controllerMessage.text;
    if (messageText.isNotEmpty) {
      Message message = Message();
      message.idUser = _idLoggedUser;
      message.message = messageText;
      message.urlImage = "";
      message.date = Timestamp.now().toString();
      message.type = "text";

      //salvar mensagem para o sender
      _saveMessage(_idLoggedUser, _idUserReceiver, message);
      //salvar mensagem para o receiver
      _saveMessage(_idUserReceiver, _idLoggedUser, message);
      //salvar conversa
      _saveTalk( message );
    }
  }

  _saveTalk(Message msg){

    //Salvar conversa sender
    Talk talkSender = Talk();
    talkSender.idSender = _idLoggedUser;
    talkSender.idReceiver = _idUserReceiver;
    talkSender.message = msg.message;
    talkSender.name = widget.contact.name;
    talkSender.photoPath = widget.contact.urlImage;
    talkSender.messageType = msg.type;
    talkSender.save();

    //Salvar conversa receiver
    Talk talkReceiver = Talk();
    talkReceiver.idSender = _idUserReceiver;
    talkReceiver.idReceiver = _idLoggedUser;
    talkReceiver.message = msg.message;
    talkReceiver.name = widget.contact.name;
    talkReceiver.photoPath = widget.contact.urlImage;
    talkReceiver.messageType = msg.type;
    talkReceiver.save();

  }

  _saveMessage(String idSender, String idReceiver, Message msg) async {
    await db
        .collection("messages")
        .document(idSender)
        .collection(idReceiver)
        .add(msg.toMap());

    _controllerMessage.clear();
  }

  _sendPhoto() async {
    File selectedImage;
    selectedImage = await ImagePicker.pickImage(source: ImageSource.gallery);

    _imageUpload = true;
    String imageName = DateTime.now().millisecondsSinceEpoch.toString();
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference rootFolder = storage.ref();
    StorageReference arquive = rootFolder
        .child("messages")
        .child(_idLoggedUser)
        .child( imageName + ".jpg");
    //Upload da imagem
    StorageUploadTask task = arquive.putFile(selectedImage);
    //Controlar progresso do upload
    task.events.listen((StorageTaskEvent storageEvent) {
      if(storageEvent.type == StorageTaskEventType.progress){
        setState(() {  _imageUpload = true;  });
      } else if (storageEvent.type == StorageTaskEventType.success){
        setState(() {  _imageUpload = false;  });
      }
    });
    //Recuperar url da imagem
    task.onComplete.then((StorageTaskSnapshot snapshot) {
      _recoverImageURL(snapshot);
    });
  }

  Future _recoverImageURL(StorageTaskSnapshot snapshot) async {
    String url = await snapshot.ref.getDownloadURL();

    Message message = Message();
    message.idUser = _idLoggedUser;
    message.message = "";
    message.urlImage = url;
    message.date = Timestamp.now().toString();
    message.type = "image";
    //salvar mensagem para o sender
    _saveMessage(_idLoggedUser, _idUserReceiver, message);
    //salvar mensagem para o receiver
    _saveMessage(_idUserReceiver, _idLoggedUser, message);
  }

  _loadInitialData() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser userLogged = await auth.currentUser();
    _idLoggedUser = userLogged.uid;
    _idUserReceiver = widget.contact.idUser;
    _addListenerMessages();
  }

  Stream<QuerySnapshot> _addListenerMessages() {
    final stream = db
        .collection("messages")
        .document(_idLoggedUser)
        .collection(_idUserReceiver).orderBy("date", descending: false)
        .snapshots();

    stream.listen((data) {
      _controller.add(data);
      Timer(Duration(seconds: 1), () {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    var messageBox = Container(
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
              child: Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: TextField(
                      controller: _controllerMessage,
                      autofocus: true,
                      keyboardType: TextInputType.text,
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                          hintText: "Type a message...",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32)),
                          prefixIcon:
                            _imageUpload
                                ? CircularProgressIndicator()
                                : IconButton(icon: Icon(Icons.camera_alt), onPressed:() => _sendPhoto())
                      )))
          ),
          Platform.isIOS
              ? CupertinoButton(
                  child: Text("Send"),
                  onPressed: _sendMessage,
                )
              : FloatingActionButton(
                  backgroundColor: Color(0xff075E54),
                  child: Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                  mini: true,
                  onPressed: _sendMessage
            )
        ],
      ),
    );

    var stream = StreamBuilder(
        stream: _controller.stream,
        // ignore: missing_return
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                  child: Column(children: [
                     Text("Loading messages"),
                     CircularProgressIndicator()
              ]));
              break;
            case ConnectionState.active:
            case ConnectionState.done:

              QuerySnapshot querySnapshot = snapshot.data;
              if (snapshot.hasError) {
                return Expanded(child: Text("Error loading data!"));
              } else {
                return Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                      itemCount: querySnapshot.documents.length,
                      itemBuilder: (context, index) {
                        //recuperar mensagem
                        List<DocumentSnapshot> messages =querySnapshot.documents.toList();
                        DocumentSnapshot item = messages[index];
                        //Define cores e alinhamentos
                        Alignment alignment = Alignment.centerRight;
                        Color color = Color(0xffd2ffa5);
                        if (_idLoggedUser != item["idUser"]) {
                          color = Colors.white;
                          alignment = Alignment.centerLeft;
                        }

                        return Align(
                          alignment: alignment,
                          child: Padding(
                            padding: EdgeInsets.all(6),
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.8,
                              ),
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                  color: color,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8))),
                              child:
                              item["type"] == "text"
                                ? Text(item["message"], style: TextStyle(fontSize: 18),)
                                : Image.network(item["urlImage"]),
                            ),
                          ),
                        );
                      }),
                );
              }
              break;
          }
        });


    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
                maxRadius: 20,
                backgroundColor: Colors.grey,
                backgroundImage: widget.contact.urlImage != null
                    ? NetworkImage(widget.contact.urlImage)
                    : null),
            Padding(
                padding: EdgeInsets.only(left: 8),
                child: Text(widget.contact.name))
          ],
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("images/bg.png"), fit: BoxFit.cover)),
        child: SafeArea(
            child: Container(
          padding: EdgeInsets.all(8),
          child: Column(
            children: [stream, messageBox],
          ),
        )),
      ),
    );
  }
}
