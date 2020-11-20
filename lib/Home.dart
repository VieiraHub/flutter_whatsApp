import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'Login.dart';
import 'tabs/Contacts.dart';
import 'tabs/Talks.dart';


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {

  TabController _tabController;
  List<String> itemsMenu = ["Settings", "Logout"];
  String _emailUser = "";

  Future _getUserData() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser loggedUser = await auth.currentUser();

    setState(() {
      _emailUser = loggedUser.email;
    });
  }

  Future _checkLoggedUser() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser loggedUser = await auth.currentUser();

    if(loggedUser == null) {  Navigator.pushReplacementNamed(context, "/login");  }
  }

  @override
  void initState() {
    super.initState();
    _checkLoggedUser();
    _getUserData();
    _tabController = TabController(length: 2, vsync: this);
  }

  _chooseMenuItem(String choosenItem){
    switch (choosenItem){
      case "Settings":
        Navigator.pushNamed(context, "/settings");
        break;
      case "Logout":
        _logoutUser();
        break;
    }
  }

  _logoutUser() async{
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
    Navigator.pushReplacementNamed(context, "/login");
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("WhatsApp"),
        elevation: Platform.isIOS ? 0 : 4,
        bottom: TabBar(
            indicatorWeight: 4,
            labelStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold
            ),
            controller: _tabController,
            indicatorColor: Platform.isIOS ? Colors.grey[400] : Colors.white,
            tabs: [
              Tab(text: "Talks",),
              Tab(text: "Contacts",)
            ]
        ),
        actions: [
          PopupMenuButton<String>(
              onSelected: _chooseMenuItem,
              itemBuilder: (context) {
                return itemsMenu.map((String item) {
                  return PopupMenuItem<String>(
                      value: item,
                      child: Text(item),
                  );
                }).toList();
              }
          )
        ],
      ),


      body: TabBarView(
        controller: _tabController,
        children: [
          Talks(),
          Contacts()
        ],
      )
    );
  }
}
