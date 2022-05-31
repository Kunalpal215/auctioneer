import 'package:auctioneer/pages/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String email="";
  String password="";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              decoration: InputDecoration(
                hintText: "Email"
              ),
              onChanged: (value){
                email=value;
              },
              validator: (value){
                if(value==null || value=="") return "This field cannot be null";
              },
            ),
            TextFormField(
              decoration: InputDecoration(
                  hintText: "Password"
              ),
              onChanged: (value){
                password=value;
              },
              validator: (value){
                if(value==null || value=="") return "This field cannot be null";
              },
            ),
            ElevatedButton(
                onPressed: () async {
                  bool validate = formKey.currentState!.validate();
                  if(!validate){
                    return;
                  }
                  try{
                    await FirebaseAuth.instance.signInWithEmailAndPassword(email: email.trim(), password: password.trim());
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
                  }
                  catch (err){
                    try{
                      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email.trim(), password: password.trim());
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
                    }
                    catch (err){
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${err}")));
                    }
                  }

                },
                child: Text("Continue"))
          ],
        ),
      ),
    );
  }
}
