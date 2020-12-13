import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_app/models/user.dart';

class Post {
  String id;
  String content;
  DateTime dateTime;
  String userId;
  String userName;
  String photoUrl;

  static Post from(DocumentSnapshot snap, User user) {
    Post post = Post();
    post.id = snap.documentID;
    post.content = snap.data['content'];
    post.dateTime = snap.data['time'].toDate();
    post.userId = user.uid;
    post.userName = user.displayName;
    post.photoUrl = user.photoUrl;
    return post;
  }
}