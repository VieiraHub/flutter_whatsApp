import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Home.dart';
import 'Signup.dart';
import 'model/User.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  TextEditingController _controllerEmail = TextEditingController(text: "bruno@gmail.com");
  TextEditingController _controllerPass = TextEditingController(text: "123456");
  String _errorMessage = "";

  _validateFields(){
    //Recuperar dados dos campos
    String email = _controllerEmail.text;
    String pass = _controllerPass.text;

    if(email.isNotEmpty && email.contains("@")) {
      if(pass.isNotEmpty) {
        setState(() {  _errorMessage = "";  });

        User user = User();
        user.email = email;
        user.pass = pass;
        _loginUser(user);

      } else {  setState(() {  _errorMessage = "Fill the password!";  });  }
    } else {  setState(() {  _errorMessage = "Fill the email, must have @";  });  }
  }

  _loginUser(User user) {
    FirebaseAuth auth = FirebaseAuth.instance;
    auth.signInWithEmailAndPassword(email: user.email, password: user.pass)
        .then((firebaseUser) {
          Navigator.pushReplacementNamed(context, "/home");
        }).catchError((error) {
          setState(() {
            _errorMessage = "Error authenticating the user check email, password and try again"; });
    });

  }

  Future _checkLoggedUser() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser loggedUser = await auth.currentUser();
    if(loggedUser != null) {  Navigator.pushReplacementNamed(context, "/home");  }
  }

  @override
  void initState() {
    _checkLoggedUser();
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Color(0xff075E54)),
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                    padding: EdgeInsets.only(bottom: 32),
                    child: Image.asset("images/logo.png",
                      width: 200,
                      height: 150
                    )
                ),
                Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: TextField(
                      controller: _controllerEmail,
                      autofocus: true,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle( fontSize: 20),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                        hintText: "E-mail",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32)
                        )
                      )
                  )
                ),
                TextField(
                  controller: _controllerPass,
                  keyboardType: TextInputType.text,
                  obscureText: true,
                  style: TextStyle( fontSize: 20),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "Password",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32)
                      )
                  )
                ),
                Padding(
                    padding: EdgeInsets.only(top: 16, bottom: 10),
                    child: RaisedButton(
                      child: Text( "Log in",
                        style: TextStyle( color: Colors.white, fontSize: 20),
                      ),
                      color: Colors.green,
                      padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32)
                      ),
                      onPressed: ( ){  _validateFields();  }
                    )
                ),
                Center(
                  child: GestureDetector(
                    child: Text( "Don't have account? Sign up!",
                      style: TextStyle(
                        color: Colors.white
                      )
                    ),
                    onTap: ( ){
                      Navigator.push(context,
                          MaterialPageRoute(
                            builder: (context) => Signup()
                          )
                      );
                    }
                  )
                ),
                Padding(
                    padding: EdgeInsets.only(top: 16),
                  child: Center(
                      child: Text(_errorMessage,
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 20
                          )
                      )
                  )
                )
              ]
            )
          )
        )
      )
    );
  }
}
