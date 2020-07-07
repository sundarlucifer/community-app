import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_app/models/user.dart';

class Event {
  String id;
  String title;
  String content;
  DateTime date;
  String userId;
  String userName;
  String photoUrl;

  static Event from(DocumentSnapshot snapshot, User user) {
    Event event = Event();
    event.id = snapshot.documentID;
    event.title = snapshot['title'];
    event.content = snapshot['content'];
    event.date = snapshot['date'].toDate();
    event.userId = snapshot['user_id'];
    event.userName = user.displayName;
    event.photoUrl = user.photoUrl;
    return event;
  }
}
