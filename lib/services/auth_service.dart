import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_app/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();
  final _db = Firestore.instance;

  User user;

  get authState => _auth.currentUser();

  AuthService() {
    _auth.currentUser().then((u) => getUser(u.uid).then((val) => user = val));
  }

  Future<dynamic> signInWithGoogle() async {
    final googleAuth = await (await _googleSignIn.signIn()).authentication;
    final authResult = await _auth.signInWithCredential(
      GoogleAuthProvider.getCredential(
          idToken: googleAuth.idToken, accessToken: googleAuth.accessToken),
    );

    if (authResult.additionalUserInfo.isNewUser)
      _createUserData(authResult.user);
    else
      _updateLastSeen(authResult.user);

    user = await getUser(authResult.user.uid);

    return user;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  _createUserData(FirebaseUser user) async {
    await _db.collection('users').document(user.uid).setData({
      'display_name': user.displayName ?? user.email,
      'email': user.email,
      'photo_url': user.photoUrl,
      'last_seen': DateTime.now() // TODO: change to server time
    }, merge: true);
  }

  _updateLastSeen(FirebaseUser user) async {
    _db
        .collection('users')
        .document(user.uid)
        .setData({'last_seen': DateTime.now()}, merge: true);
  }

  updateDisplayName(String name) async {
    _db.collection('users').document(user.uid).setData({'display_name': name},
        merge: true).then((value) async => user = await getUser(user.uid));
  }

  Future<User> getUser(String uid) async {
    final userData = await _db.collection('users').document(uid).get();
    return User.from(userData);
  }

  Stream<QuerySnapshot> getEvents() {
    return _db.collection('events').snapshots();
  }

  postEvent(String title, String content, Timestamp date) async {
    FirebaseUser user = await _auth.currentUser();
    return await _db.collection('events').add({
      'title': title,
      'content': content,
      'date': date,
      'user_id': user.uid,
    });
  }

  Future subscribeEvent(String eventId) async {
    FirebaseUser user = await _auth.currentUser();
    return await _db
        .collection('subscriptions')
        .document(user.uid)
        .collection('events')
        .document(eventId)
        .setData({});
  }

  Future unSubscribeEvent(String eventId) async {
    FirebaseUser user = await _auth.currentUser();
    return await _db
        .collection('subscriptions')
        .document(user.uid)
        .collection('events')
        .document(eventId)
        .delete();
  }

  Future<List<String>> getMyEventIds() async {
    FirebaseUser user = await _auth.currentUser();
    List<DocumentSnapshot> docs = (await _db
            .collection('subscriptions')
            .document(user.uid)
            .collection('events')
            .getDocuments())
        .documents;
    return docs.map<String>((e) => e.documentID).toList();
  }

  Stream<QuerySnapshot> getPosts() {
    return _db.collection('posts').snapshots();
  }

  Future createPost(String content) async {
    FirebaseUser user = await _auth.currentUser();
    return await _db.collection('posts').add({
      'content': content,
      'time': DateTime.now(),
      'user_id': user.uid,
    });
  }

  deletePost(String postId) {
    _db.collection('posts').document(postId).delete();
  }
}

final authService = AuthService();
