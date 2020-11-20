import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  TextEditingController _controllerName = TextEditingController();
  File _image;
  String _idLoggedUser;
  bool _imageUpload = false;
  String _urlRecoverImage;

  Future _recoverImage(String imageOrigin) async {
    File selectedImage;
    switch(imageOrigin) {
      case "Camara" :
        selectedImage = await ImagePicker.pickImage(source: ImageSource.camera);
        break;
      case "Gallery" :
        selectedImage = await ImagePicker.pickImage(source: ImageSource.gallery);
        break;
    }
    setState(() {
      _image = selectedImage;
      if (_image != null){
        _imageUpload = true;
        _uploadImage();
      }
    });
  }

  Future _uploadImage() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference rootFolder = storage.ref();
    StorageReference arquive = rootFolder.child("profile").child( _idLoggedUser + ".jpg");
    //Upload da imagem
    StorageUploadTask task = arquive.putFile(_image);
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
    _updateUrlImageFirestore(url);
    setState(() {  _urlRecoverImage = url;  });
  }

  _updateUrlImageFirestore(String url){
    Firestore db = Firestore.instance;
    Map<String, dynamic> dataUpdate = {  "urlImage" : url  };

    db.collection("user").document(_idLoggedUser).updateData(dataUpdate);
  }

  _updateNameFirestore(){
    String name = _controllerName.text;
    Firestore db = Firestore.instance;
    Map<String, dynamic> dataUpdate = {  "name" : name  };

    db.collection("user").document(_idLoggedUser).updateData(dataUpdate);
  }

  _recoverUserData() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser userLogged = await auth.currentUser();
    _idLoggedUser = userLogged.uid;
    
    Firestore db = Firestore.instance;
    DocumentSnapshot snapshot = await db.collection("user")
        .document(_idLoggedUser).get();

    Map<String, dynamic> data = snapshot.data;
    _controllerName.text = data["name"];
    if(data["urlImage"] != null ){
      setState(() {  _urlRecoverImage = data["urlImage"];  });
    }
  }

  @override
  void initState() {
    super.initState();
    _recoverUserData();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings"),),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  child: _imageUpload ? CircularProgressIndicator() : Container()
                ),
                CircleAvatar(
                  radius: 100,
                  backgroundColor: Colors.grey,
                  backgroundImage:
                  _urlRecoverImage != null ? NetworkImage( _urlRecoverImage) : null
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FlatButton(
                        child: Text("Camara"),
                        onPressed: (){
                          _recoverImage("Camera");
                        }
                    ),
                    FlatButton(
                        child: Text("Gallery"),
                        onPressed: (){
                          _recoverImage("Gallery");
                        }
                    )
                  ],
                ),
                Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: TextField(
                        controller: _controllerName,
                        autofocus: true,
                        keyboardType: TextInputType.text,
                        style: TextStyle( fontSize: 20),
                        //Para atualizar logo e não ser preciso carregar salvar
                        //onChanged: (text){  _updateNameFirestore(text);  },
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                            hintText: "Name",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(32)
                            )
                        )
                    )
                ),
                Padding(
                    padding: EdgeInsets.only(top: 16, bottom: 10),
                    child: RaisedButton(
                        child: Text( "Save",
                          style: TextStyle( color: Colors.white, fontSize: 20),
                        ),
                        color: Colors.green,
                        padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32)
                        ),
                        onPressed: ( ){  _updateNameFirestore();  }
                    )
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
