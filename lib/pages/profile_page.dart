// ignore_for_file: prefer_const_constructors

import 'package:chat_app_firebase/pages/home_page.dart';
import 'package:chat_app_firebase/service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../helper/helper_functions.dart';
import '../widgets/widgets.dart';
import 'auth/login_page.dart';

class ProfilePage extends StatefulWidget {
  String? username;
  String? email;
  ProfilePage({Key? key, required this.email, required this.username})
      : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Authentication authService = Authentication();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Profile Page",
          style: TextStyle(fontSize: 24),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 50),
          children: [
            Icon(
              Icons.account_circle_outlined,
              size: 150,
              color: Colors.black,
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              widget.username.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            Divider(height: 2),
            ListTile(
              onTap: (() {
                nextScreen(context, HomePage());
              }),
              contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              leading: Icon(Icons.group),
              title: Text("Groups", style: TextStyle(color: Colors.black)),
            ),
            ListTile(
              onTap: (() {}),
              selected: true,
              selectedColor: Colors.blue,
              contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              leading: Icon(Icons.person),
              title: Text("Profile", style: TextStyle(color: Colors.black)),
            ),
            ListTile(
              onTap: (() {
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Logout"),
                        content: Text("Are you sure you want to logout ?"),
                        actions: [
                          IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(
                                Icons.cancel_presentation_sharp,
                                color: Colors.red,
                              )),
                          IconButton(
                              onPressed: () async {
                                await authService.signOut();
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginPage()),
                                    (route) => false);
                              },
                              icon: Icon(
                                Icons.done,
                                color: Colors.green,
                              ))
                        ],
                      );
                    });
              }),
              contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              leading: Icon(Icons.logout_sharp),
              title: Text("Logout", style: TextStyle(color: Colors.black)),
            )
          ],
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 170),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              Icons.account_circle,
              size: 200,
              color: Colors.grey[700],
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Full Name",
                  style: TextStyle(fontSize: 17),
                ),
                Text(
                  widget.username.toString(),
                  style: TextStyle(fontSize: 17),
                )
              ],
            ),
            Divider(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Email",
                  style: TextStyle(fontSize: 17),
                ),
                Text(
                  widget.email.toString(),
                  style: TextStyle(fontSize: 17),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
