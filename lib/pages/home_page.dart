// ignore_for_file: prefer_const_constructors


import 'package:chat_app_firebase/helper/helper_functions.dart';
import 'package:chat_app_firebase/pages/auth/login_page.dart';
import 'package:chat_app_firebase/pages/profile_page.dart';
import 'package:chat_app_firebase/pages/search_page.dart';
import 'package:chat_app_firebase/service/auth_service.dart';
import 'package:chat_app_firebase/service/database_service.dart';
import 'package:chat_app_firebase/widgets/group_tile.dart';
import 'package:chat_app_firebase/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';



class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String username = "";
  String email = "";
  Stream? groups;
  Authentication authService = Authentication();
  bool isLoading = false;
  String groupName = "";
  @override
  void initState() {
    super.initState();
    gettingUserData();
  }

  // string manipulation to get group id and name
  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  String getName(String res) {
    return res.substring(res.indexOf("_") + 1);
  }

  gettingUserData() async {
    await HelperFunctions.getUserEmailFromSF().then((value) {
      setState(() {
        email = value!;
      });
    });
    await HelperFunctions.getUserNameFromSF().then((value) {
      setState(() {
        username = value!;
      });
    });
    // getting list of snapshots from database
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getUserGroups()
        .then((snapshot) {
      setState(() {
        groups = snapshot;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          actions: [
            IconButton(
                onPressed: () {
                  nextScreen(context, SearchPage());
                },
                icon: Icon(Icons.search))
          ],
          centerTitle: true,
          title: Text("Groups"),
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
                username,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),
              Divider(height: 2),
              ListTile(
                onTap: (() {}),
                selected: true,
                selectedColor: Colors.blue,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                leading: Icon(Icons.group),
                title: Text("Groups", style: TextStyle(color: Colors.black)),
              ),
              ListTile(
                onTap: (() {
                  nextScreenReplace(
                      context, ProfilePage(email: email, username: username));
                }),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 5, horizontal: 20),
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
                contentPadding:
                    EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                leading: Icon(Icons.logout_sharp),
                title: Text("Logout", style: TextStyle(color: Colors.black)),
              )
            ],
          ),
        ),
        body: groupList(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            popUpDialog(context);
          },
          elevation: 0,
          child: Icon(Icons.add),
        ));
  }

  popUpDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Create a group", textAlign: TextAlign.left),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : TextField(
                        onChanged: (value) {
                          setState(() {
                            groupName = value;
                          });
                        },
                        decoration: textInputDecoration,
                      )
              ],
            ),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("CANCEL ")),
              ElevatedButton(
                  onPressed: () async {
                    if (groupName != "") {
                      setState(() {
                        isLoading = true;
                      });
                      DatabaseService(
                              uid: FirebaseAuth.instance.currentUser!.uid)
                          .createGroup(
                              username,
                              FirebaseAuth.instance.currentUser!.uid,
                              groupName);
                      setState(() {
                        isLoading = false;
                      });
                      Navigator.pop(context);
                      showsnackbar(
                          color: Colors.green,
                          context: context,
                          message: "group Created Successfully.");
                    } else {}
                  },
                  child: Text("CREATE "))
            ],
          );
        });
  }

  groupList() {
    return StreamBuilder(
      stream: groups,
      builder: (context, AsyncSnapshot snapshot) {
        // make some checks
        if (snapshot.hasData) {
          if (snapshot.data['groups'] != null) {
            if (snapshot.data['groups'].length != 0) {
              return ListView.builder(
                itemCount: snapshot.data['groups'].length,
                itemBuilder: (context, index) {
                  int revIndex = snapshot.data['groups'].length - index - 1;
                  return GroupTile(
                    userName: snapshot.data['fullName'],
                    groupId: getId(snapshot.data['groups'][revIndex]),
                    groupName: getName(snapshot.data['groups'][revIndex]),
                  );
                },
              );
            } else {
              return noGroupWidget();
            }
          } else {
            return noGroupWidget();
          }
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  noGroupWidget() {
    return Center(
      child: GestureDetector(
        onTap: () {
          popUpDialog(context);
        },
        child: Icon(
          Icons.add_circle_outline,
          size: 75,
        ),
      ),
    );
  }
}
