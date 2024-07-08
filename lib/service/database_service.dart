import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;

  DatabaseService({this.uid});
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection("users");

  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection("groups");

  //updating the user daTa
  Future updateUserData(String fullName, String email) async {
    return await usersCollection.doc(uid).set({
      "fullName": fullName,
      "email": email,
      "groups": [],
      "profilePic": "",
      "uid": uid
    });
  }

  //getting user data after
  Future gettingUserData(String email) async {
    QuerySnapshot snapshot =
        await usersCollection.where("email", isEqualTo: email).get();
    return snapshot;
  }
  //get user groups

  getUserGroups() async {
    return usersCollection.doc(uid).snapshots();
  }

  // creating group for user
  Future createGroup(String UserName, String id, String groupName) async {
    DocumentReference groupDocumentReference = await groupCollection.add({
      "groupName": groupName,
      "groupIcon": "",
      "admin": "${id}_$UserName",
      "members": [],
      "groupId": "",
      "recentMessage": "",
      "recentMessageSender": "",
    });
    await groupDocumentReference.update({
      "members": FieldValue.arrayUnion(["${uid}_$UserName"]),
      "groupId": groupDocumentReference.id,
    });
    DocumentReference userDocumentReference = usersCollection.doc(uid);
    return await userDocumentReference.update({
      "groups":
          FieldValue.arrayUnion(["${groupDocumentReference.id}_$groupName"])
    });
  }

  //getting chat
  getChat(String groupId) async {
    return groupCollection
        .doc(groupId)
        .collection("messages")
        .orderBy('time')
        .snapshots();
  }

  //getting admin
  Future getAdmin(String groupId) async {
    DocumentReference d = groupCollection.doc(groupId);
    DocumentSnapshot documentsnap = await d.get();
    return documentsnap['admin'];
  }

  //getting members
  getGroupMembers(groupId) async {
    return groupCollection.doc(groupId).snapshots();
  }

  //searching for a group
  searchGroup(String groupName) {
    return groupCollection.where("groupName", isEqualTo: groupName).get();
  }

  // to check wheter user is in group or not
  Future<bool> isUserJoined(
      String groupName, String groupId, String userName) async {
    DocumentReference userDocumentReference = usersCollection.doc(uid);
    DocumentSnapshot snapshot = await userDocumentReference.get();
    List<dynamic> groups = snapshot['groups'];
    if (groups.contains("${groupId}_$groupName")) {
      return true;
    } else {
      return false;
    }
  }

  // for joining and exiting a group

  Future toggleGroupJoin(
      String groupName, String groupId, String userName) async {
    DocumentReference userDocumentReference = usersCollection.doc(uid);
    DocumentReference groupDocumentReference = groupCollection.doc(groupId);
    DocumentSnapshot documentSnapshot = await userDocumentReference.get();
    List<dynamic> groups = await documentSnapshot['groups'];
    // if ggroup
    if (groups.contains("${groupId}_$groupName")) {
      await userDocumentReference.update({
        "groups": FieldValue.arrayRemove(["${groupId}_$groupName"])
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayRemove(["${uid}_$userName"])
      });
    } else {
      await userDocumentReference.update({
        "groups": FieldValue.arrayUnion(["${groupId}_$groupName"])
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayUnion(["${uid}_$userName"])
      });
    }
  }

// send message
  sendMessage(String groupId, Map<String, dynamic> chatMessageData) async {
    groupCollection.doc(groupId).collection("messages").add(chatMessageData);
    groupCollection.doc(groupId).update({
      "recentMessage":chatMessageData['message'],
      "recentMessageSender": chatMessageData['sender'],
      "recentMessageTime": chatMessageData['time'].toString(),
    });

  }
}
