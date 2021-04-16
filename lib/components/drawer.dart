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
  Future _handleSignOut() async {
    await widget.auth.signOut();
    widget.onSignOut();
  }

  @override
  Widget build(BuildContext context) {
    String userEmail = widget.auth.currentUser.email;
    String userName =
        userEmail.replaceRange(userEmail.indexOf("@"), userEmail.length, "");

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: new BoxDecoration(
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
            child: Text(
              'Hello $userName',
              style: TextStyle(
                color: kTextColor,
                fontSize: 16,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                _showDeleteYesNoDialog(
                    context, "", "Are you sure you want to log out?");
              },
            ),
          ),
        ],
      ),
    );
  }

  // Form dialog Yes, No
  void _showDeleteYesNoDialog(
      BuildContext context, String title, String content) {
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
                  _handleSignOut();
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
}
