import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_list_app/constants.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key key, this.auth, this.onSignOut}) : super(key: key);

  final FirebaseAuth auth;
  final VoidCallback onSignOut;

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    final currentUser = widget.auth.currentUser;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
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
                currentUser.photoURL != null
                    ? Container(
                        width: 60,
                        height: 60,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.network(currentUser.photoURL)),
                      )
                    : SizedBox(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    currentUser.displayName != null
                        ? Text(
                            currentUser.displayName,
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
          Align(
            alignment: Alignment.bottomLeft,
            child: ListTile(
              leading: Icon(
                Icons.lock,
                size: 30,
              ),
              title: Text(
                'Reset Account',
              ),
              onTap: () {
                widget.auth.sendPasswordResetEmail(email: currentUser.email);
                _showDialogResetPass(context);
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
      actions: [
        Row(
          children: [
            OutlineButton(
              onPressed: () => Navigator.pop(context),
              child: Padding(
                padding: const EdgeInsets.only(left: 40, right: 40),
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
                  padding: const EdgeInsets.only(left: 40, right: 40),
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
}
