import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  String id;
  String title;
  String content;
  DateTime date;
  String userName;
  String photoUrl; // TODO: Change to uid and get data from cloud

  Event(DocumentSnapshot snapshot) {
    id = snapshot.documentID;
    title = snapshot['title'];
    content = snapshot['content'];
    date = snapshot['date'].toDate();
    userName = snapshot['user_name'];
    photoUrl = snapshot['photo_url'];
  }
}
