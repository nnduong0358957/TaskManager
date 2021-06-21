import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:todo_list_app/components/color_loader_2.dart';
import 'package:todo_list_app/screens/home_page/home.dart';
import 'package:todo_list_app/screens/login_page/forgot_pass.dart';
import 'package:todo_list_app/screens/login_page/signUp.dart';
import 'package:todo_list_app/constants.dart';
import 'package:connectivity/connectivity.dart';
import 'package:google_fonts/google_fonts.dart';

class MyLoginPage extends StatefulWidget {
  MyLoginPage({Key key}) : super(key: key);

  @override
  _MyLoginPageState createState() => _MyLoginPageState();
}

class _MyLoginPageState extends State<MyLoginPage> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  final ref = FirebaseDatabase.instance.reference();
  GlobalKey<FormState> _formState = GlobalKey<FormState>();

  FirebaseAuth _auth;
  GoogleSignIn _googleSignIn;

  var loginStatus = 0;
  String _message;
  String _email;
  String _password;
  bool _resetPage = true;
  bool _obscureText = true;
  bool isConnected;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    FirebaseDatabase database = new FirebaseDatabase();
    database.setPersistenceEnabled(true);
    database.setPersistenceCacheSizeBytes(3000);

    checkConnection();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        // Kiểm tra xem có bị lỗi khi initialize không
        if (snapshot.hasError) {
          return Text('Có lỗi');
        }
        // Nếu thành công thì hiển thị như lúc đầu chúng ta đã tạo
        if (snapshot.connectionState == ConnectionState.done) {
          // Chỉ có thể thực hiện các dịch vụ Google sau khi initializeApp hoàn tất

          _auth = FirebaseAuth.instance;
          _googleSignIn = GoogleSignIn();
          loginStatus = _checkLogin();

          if (loginStatus == 0) {
            return SafeArea(
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
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 50.0, bottom: 30, right: 10, left: 10),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            buildForm(context),
                            SizedBox(height: 20),
                            Row(children: <Widget>[
                              Expanded(
                                  child: Divider(
                                color: Colors.black,
                                thickness: 1,
                              )),
                              Text("  OR  "),
                              Expanded(
                                  child: Divider(
                                color: Colors.black,
                                thickness: 1,
                              )),
                            ]),
                            SizedBox(height: 20),
                            InkWell(
                              onTap: () {
                                _SignInWithGoogle();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: kPrimaryColor,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Ink(
                                    child: Padding(
                                      padding: EdgeInsets.only(right: 20),
                                      child: Wrap(
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            child: Image.asset(
                                              'assets/images/google.jpg',
                                              width: 30,
                                              height: 30,
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Text('Đăng nhập bằng Google',
                                              style:
                                                  TextStyle(color: kTextColor)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            FlatButton(
                              onPressed: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  // do something
                                  return ForgotPass();
                                }));
                              },
                              child: Text(
                                "Quên mật khẩu?",
                                style: TextStyle(color: kPrimaryColor),
                              ),
                            ),
                            FlatButton(
                              onPressed: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  // do something
                                  return SignUpPage(onSignIn: _onSignIn);
                                }));
                              },
                              child: Text(
                                "Tạo tài khoản",
                                style: TextStyle(color: Colors.orange[800]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )));
          } else if (loginStatus == 1) {
            print("Sign in with ${_auth.currentUser.email}");
            return MyHomePage(auth: _auth, onSignOut: _onSignOut);
          }
        }

        // Đang load
        return SafeArea(
            child: Scaffold(
                body: Center(
                    child: Transform.scale(
          scale: 2,
          child: ColorLoader2(
            color1: Colors.redAccent,
            color2: Colors.green,
            color3: Colors.amber,
          ),
        ))));
      },
    );
  }

  Form buildForm(BuildContext context) {
    return Form(
      key: _formState,
      autovalidateMode: AutovalidateMode.disabled,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            child: Text(
              'Đăng nhập',
              style: GoogleFonts.lato(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue[800]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            child: TextFormField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email),
                  labelText: 'Email',
                ),
                onSaved: (newValue) {
                  _email = newValue;
                },
                validator: (value) => value.isEmpty
                    ? "Bạn chưa nhập email"
                    : EmailValidator.validate(value)
                        ? null
                        : "Email không hợp lệ"),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 20.0),
            child: TextFormField(
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock),
                  labelText: 'Mật khẩu',
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
              validator: (value) =>
                  value.isEmpty ? "Bạn chưa nhập mật khẩu" : null,
              obscureText: _obscureText,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20),
                    child: RaisedButton(
                      textColor: kTextColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Text(
                          'Đăng nhập',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      color: kPrimaryColor,
                      onPressed: () {
                        if (_formState.currentState.validate()) {
                          _formState.currentState.save();
                          _SignInWithEmailPassword(_email, _password);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // ignore: non_constant_identifier_names
  Future _SignInWithEmailPassword(String email, String pass) async {
    await checkConnection();
    if (isConnected) {
      setState(() {
        _message = null;
      });
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: pass);
        _onSignIn();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          setState(() {
            _message = "Tài khoản sai hoặc bạn chưa đăng ký tài khoản này";
          });
        } else if (e.code == 'wrong-password') {
          setState(() {
            _message = "Sai mật khẩu";
          });
        }
      }

      if (_message != null) _showAlertDialog(context, _message);
      _refreshPage();
    } else
      _showAlertDialog(context, "Không có kết nối internet!");
  }

  // ignore: non_constant_identifier_names
  Future _SignInWithGoogle() async {
    await checkConnection();
    if (isConnected) {
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final User user = (await _auth.signInWithCredential(credential)).user;
      print("signed in " + user.displayName);
      _onSignIn();
    } else
      _showAlertDialog(context, "Không có kết nối internet");
  }

  int _checkLogin() {
    // Khi mở app lên thì check xem user đã login chưa
    final user = _auth.currentUser;
    if (user != null) {
      return 1;
    } else
      return 0;
  }

  void _refreshPage() {
    setState(() {
      _resetPage = !_resetPage;
    });
  }

  Future _onSignIn() async {
    setState(() {
      loginStatus = 1;
    });
  }

  void _onSignOut() {
    _googleSignIn.disconnect();
    setState(() {
      loginStatus = 0;
    });
  }

  // Toggles the password show status
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future _showAlertDialog(BuildContext context, String content) async {
    AlertDialog alertDialog = AlertDialog(
      title: Container(
        width: 100,
        height: 100,
        child: Image.asset("assets/images/error.png"),
      ),
      content: Text(
        content,
        style: TextStyle(color: Colors.red, fontSize: 14),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      actions: [
        FlatButton(onPressed: () => Navigator.pop(context), child: Text('Ok'))
      ],
    );
    await showDialog(
      context: context,
      builder: (context) => alertDialog,
    );
  }

  Future checkConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      // I am connected to a mobile network.
      setState(() {
        isConnected = true;
      });
    } else if (connectivityResult == ConnectivityResult.wifi) {
      // I am connected to a wifi network.
      setState(() {
        isConnected = true;
      });
    } else {
      setState(() {
        isConnected = false;
      });
    }
  }
}
