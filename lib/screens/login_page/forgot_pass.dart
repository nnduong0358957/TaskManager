import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo_list_app/constants.dart';

class ForgotPass extends StatefulWidget {
  @override
  _ForgotPassState createState() => _ForgotPassState();
}

class _ForgotPassState extends State<ForgotPass> {
  FirebaseAuth auth = FirebaseAuth.instance;

  GlobalKey<FormState> _formState = GlobalKey<FormState>();
  String _email;
  bool error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: kPrimaryColor,
      ),
      home: SafeArea(
        child: Scaffold(
          body: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/bg_login.jpg"),
                    fit: BoxFit.cover)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15)),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: 50.0, top: 60),
                            child: Text(
                              'Find your password',
                              style: GoogleFonts.lato(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.blue[800]),
                            ),
                          ),
                          Form(
                            key: _formState,
                            autovalidateMode: AutovalidateMode.disabled,
                            child: Column(
                              children: [
                                Text(
                                    "Please enter your email to find your password"),
                                TextFormField(
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.email),
                                      labelText: 'Email',
                                    ),
                                    onSaved: (newValue) {
                                      _email = newValue;
                                    },
                                    validator: (value) => value.isEmpty
                                        ? "Please enter the email"
                                        : EmailValidator.validate(value)
                                            ? null
                                            : "Invalid email"),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 50, bottom: 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                          padding:
                                              const EdgeInsets.only(right: 20),
                                          child: FlatButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text("Back"),
                                          )),
                                      ButtonTheme(
                                        minWidth: 150,
                                        child: RaisedButton(
                                          textColor: kTextColor,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Text(
                                            'Find',
                                            style: TextStyle(fontSize: 18),
                                          ),
                                          color: kPrimaryColor,
                                          onPressed: () async {
                                            if (_formState.currentState
                                                .validate()) {
                                              _formState.currentState.save();
                                              await auth
                                                  .sendPasswordResetEmail(
                                                      email: _email)
                                                  .catchError((e) {
                                                if (e.code ==
                                                    "too-many-requests") {
                                                  _showAlertDialog(context,
                                                      "You requests too much. Please try again later.");
                                                  setState(() {
                                                    error = true;
                                                  });
                                                }
                                              });
                                              if (error != true)
                                                _showDialogResetPass(context);
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Thông báo reset password
  void _showDialogResetPass(BuildContext context) {
    AlertDialog alertDialog = AlertDialog(
      content: Text(
          "An email will be sent to your email.\nPlease change the password there."),
      actions: [
        FlatButton(onPressed: () => Navigator.pop(context), child: Text('Ok'))
      ],
    );
    showDialog(
      context: context,
      builder: (context) => alertDialog,
    );
  }

  void _showAlertDialog(BuildContext context, String content) {
    AlertDialog alertDialog = AlertDialog(
      title: Container(
        width: 100,
        height: 100,
        child: Image.asset("assets/images/warning.png"),
      ),
      content: Text(content),
      actions: [
        FlatButton(onPressed: () => Navigator.pop(context), child: Text('Ok'))
      ],
    );
    showDialog(
      context: context,
      builder: (context) => alertDialog,
    );
  }
}
