import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todo_list_app/constants.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as Path;

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key key, this.auth, this.onSignOut}) : super(key: key);

  final FirebaseAuth auth;
  final VoidCallback onSignOut;

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  firebase_storage.Reference ref;

  TextEditingController displayNameController = TextEditingController();
  final picker = ImagePicker();
  File _imageFile;
  String _imageUrl, _displayName;
  bool isConnected = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    displayNameController.text = widget.auth.currentUser.displayName;
    _imageUrl = widget.auth.currentUser.photoURL;
    _displayName = widget.auth.currentUser.displayName;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = widget.auth.currentUser;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            height: 220,
            child: DrawerHeader(
              decoration: new BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/drawer_header.jpg"),
                    fit: BoxFit.cover),
                gradient: new LinearGradient(
                    colors: [
                      const Color(0xFF3366FF),
                      const Color(0xFF00CCFF),
                    ],
                    begin: const FractionalOffset(0.0, 1.0),
                    end: const FractionalOffset(3.0, 0.0),
                    stops: [0.0, 1.0],
                    tileMode: TileMode.clamp),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      onTap: () async {
                        await checkConnection(context);
                        if (isConnected)
                          _pickImageDialog(context);
                        else
                          _showDialogResetPass(
                              context, "No network connection.");
                      },
                      child: buildContainerImage(100, 100),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _displayName != null
                          ? Text(
                              _displayName,
                              style: TextStyle(
                                color: kTextColor,
                                fontSize: 16,
                              ),
                            )
                          : SizedBox(),
                      Text(
                        currentUser.email,
                        style: TextStyle(
                          color: kTextColor,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: ListTile(
              leading: Icon(
                Icons.lock,
                size: 30,
              ),
              title: Text(
                'Reset Password',
              ),
              onTap: () {
                widget.auth.sendPasswordResetEmail(email: currentUser.email);
                _showDialogResetPass(context,
                    "An email will be sent to your email.\nPlease change the password there.");
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: ListTile(
              leading: Icon(
                Icons.clear,
                size: 30,
              ),
              title: Text(
                'Delete Account',
              ),
              onTap: () {
                _showDeleteYesNoDialog(
                    context,
                    "",
                    "Are you sure you want to delete account?\nIt will delete all of your tasks and history. You can't undo this.",
                    _handleDelete);
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: ListTile(
              leading: Icon(
                Icons.logout,
                color: Colors.red,
                size: 30,
              ),
              title: Text(
                'Log Out',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                _showDeleteYesNoDialog(context, "",
                    "Are you sure you want to log out?", _handleSignOut);
              },
            ),
          ),
        ],
      ),
    );
  }

  ClipRRect buildContainerImage(double imgWidth, double imgHeight) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(1000),
      child: Container(
        width: imgWidth,
        height: imgHeight,
        child: _imageUrl != null
            ? Image.network(
                _imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                      alignment: Alignment.center,
                      color: Colors.white,
                      child: Image.asset(
                        "assets/images/loadImgFailed.png",
                        width: 40,
                        height: 40,
                      ));
                },
              )
            : Image.asset("assets/images/defaultImage.png"),
      ),
    );
  }

  Future pickImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      _imageFile = File(pickedFile.path);
    });

    if (pickedFile.path == null) retrieveLostData();
  }

  Future retrieveLostData() async {
    final LostData response = await picker.getLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _imageFile = File(response.file.path);
      });
    }
  }

  Future uploadFile() async {
    if (_imageFile != null) {
      ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child("images/${Path.basename(_imageFile.path)}");

      await ref.putFile(_imageFile).whenComplete(() async {
        await ref.getDownloadURL().then((value) async {
          deleteImgFile(_imageUrl);

          setState(() {
            _imageUrl = value;
          });

          await updateUserInfo(displayNameController.text.trim(), _imageUrl);
        });
      });
    } else
      await updateUserInfo(displayNameController.text.trim(), null);
  }

  Future deleteImgFile(String path) async {
    String fileName = path.replaceAll("/o/", "*");
    fileName = fileName.replaceAll("?", "*");
    fileName = fileName.split("*")[1];
    fileName = fileName.replaceAll("%2F", "/");

    print("$fileName");
    ref = firebase_storage.FirebaseStorage.instance.ref().child(fileName);

    await ref
        .delete()
        .then((_) => print('Successfully deleted $fileName storage item'));
  }

  Future updateUserInfo(String displayName, String url) async {
    User user = widget.auth.currentUser;

    if (url != null) {
      user.updateProfile(displayName: displayName, photoURL: url);
    } else {
      user.updateProfile(displayName: displayName);
    }

    setState(() {
      _displayName = displayName;
    });
  }

// Dialog pick image
  void _pickImageDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          bool refresh = false;
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text(
                "User info",
                style: GoogleFonts.lato(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                    color: kPrimaryColor),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () async {
                        await pickImage();
                        setState(() {
                          refresh = !refresh;
                        });
                      },
                      child: buildContainerImage(200, 200),
                    ),
                    SizedBox(height: 40),
                    buildTextField(
                        "User name", "", displayNameController, false)
                  ],
                ),
              ),
              elevation: 24,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              actions: [
                Row(
                  children: [
                    OutlineButton(
                      onPressed: () {
                        resetFileImg();
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Text('Cancel'),
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: OutlineButton(
                        onPressed: () async {
                          await uploadFile();
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: Text(
                            'Save',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ],
                ),
              ],
            );
          });
        });
  }

  TextField buildTextField(String labelText, String hintText,
      TextEditingController controller, bool readOnly) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      maxLines: null, // để có thể nhập nhiều dòng trong TextField
      decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5))),
    );
  }

// Thông báo reset password
  void _showDialogResetPass(BuildContext context, String content) {
    AlertDialog alertDialog = AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 20,
          ),
          Text(content),
        ],
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      actions: [
        FlatButton(onPressed: () => Navigator.pop(context), child: Text('Ok'))
      ],
    );
    showDialog(
      context: context,
      builder: (context) => alertDialog,
    );
  }

  Future _handleSignOut() async {
    await widget.auth.signOut();
    widget.onSignOut();
  }

  Future _handleDelete() async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    await _auth.currentUser.delete().catchError((onError) {
      print(onError);
    });
    widget.onSignOut();
  }

  void resetFileImg() {
    setState(() {
      _imageFile = null;
    });
  }

  Future checkConnection(BuildContext context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      print("Connect with wifi mobile");
      setState(() {
        isConnected = true;
      });
    } else if (connectivityResult == ConnectivityResult.wifi) {
      print("Connect with wifi");
      setState(() {
        isConnected = true;
      });
    } else
      setState(() {
        isConnected = false;
      });

    // if (widget.auth.currentUser)
  }

// BoxDecoration boxDecorationShowImg() {
//   return new BoxDecoration(
//       shape: BoxShape.circle,
//       border: Border.all(color: Colors.blueAccent, width: 2),
//       image: new DecorationImage(
//           fit: BoxFit.cover,
//           image: _imageFile != null
//               ? FileImage(_imageFile)
//               : _imageUrl != null
//                   ? isConnected
//                       ? NetworkImage(_imageUrl)
//                       : AssetImage("assets/images/defaultImage.png")
//                   : AssetImage("assets/images/loadImgFailed.png")));
// }

// Form dialog Yes, No
  void _showDeleteYesNoDialog(BuildContext context, String title,
      String content, final VoidCallback function) {
    AlertDialog alertDialog = AlertDialog(
      title: Container(
        width: 100,
        height: 100,
        child: Image.asset("assets/images/warning.png"),
      ),
      content: Text(
        content,
        style: TextStyle(color: Colors.red, fontSize: 18),
      ),
      elevation: 24,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      actions: [
        Row(
          children: [
            OutlineButton(
              onPressed: () => Navigator.pop(context),
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Text('No'),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: OutlineButton(
                onPressed: () {
                  function();
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Text(
                    'Yes',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ],
        ),
      ],
    );
    showDialog(
      context: context,
      builder: (context) => alertDialog,
    );
  }
}
