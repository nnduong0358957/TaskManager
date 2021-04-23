import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo_list_app/constants.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({this.onSignIn});

  final VoidCallback onSignIn;

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  FirebaseAuth auth = FirebaseAuth.instance;

  GlobalKey<FormState> _formState = GlobalKey<FormState>();
  String _email, _password;
  String _error;

  void _onSignUp(String email, String pass) async {
    setState(() {
      _error = null;
    });
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: pass);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('Password too weak');
        setState(() {
          _error = 'Password too weak';
        });
      } else if (e.code == 'email-already-in-use') {
        print('Email already in use');
        setState(() {
          _error = 'Email already in use';
        });
      }
    } catch (e) {
      print(e);
    }

    // True là báo thành công, false là báo thất bại
    if (_error == null)
      _showAlertDialog(context, true, "Success!", "Welcome to our app");
    else
      _showAlertDialog(context, false, "Error!", _error);
  }

  Future _showAlertDialog(
      BuildContext context, bool type, String title, String content) async {
    AlertDialog alertDialog = AlertDialog(
      title: Container(
        width: 100,
        height: 100,
        child: type
            ? Image.asset("assets/images/success.png")
            : Image.asset("assets/images/error.png"),
      ),
      content: Text(
        content,
        style: TextStyle(color: Colors.red),
      ),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
      actions: [
        FlatButton(onPressed: () => Navigator.pop(context), child: Text('Ok'))
      ],
    );
    await showDialog(
      context: context,
      builder: (context) => alertDialog,
    );
    if (type) Navigator.pop(context);
    widget.onSignIn();
  }

  bool _obscureText = true;

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 50.0, top: 60),
                          child: Text(
                            'Register',
                            style: GoogleFonts.lato(
                                fontSize: 40,
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
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 20.0, right: 20.0),
                                child: TextFormField(
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
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 20.0, right: 20.0, top: 20.0),
                                child: TextFormField(
                                  decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.lock),
                                      labelText: 'Password',
                                      suffixIcon: IconButton(
                                        icon: _obscureText
                                            ? Icon(Icons.visibility_off)
                                            : Icon(Icons.visibility),
                                        onPressed: _toggle,
                                      )),
                                  onSaved: (newValue) {
                                    _password = newValue;
                                  },
                                  // ignore: missing_return
                                  validator: (value) => value.isEmpty
                                      ? "Please enter the password"
                                      : value.length < 6
                                          ? "Password must be longer than 6 characters"
                                          : null,
                                  obscureText: _obscureText,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 50, bottom: 20),
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
                                          'Register',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        color: kPrimaryColor,
                                        onPressed: () {
                                          if (_formState.currentState
                                              .validate()) {
                                            _formState.currentState.save();
                                            _onSignUp(_email, _password);
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
    );
  }
}
