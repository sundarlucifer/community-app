import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();
  final _db = Firestore.instance;

  Stream<FirebaseUser> user;

  AuthService() {
    user = _auth.onAuthStateChanged;

    user.map((u) => u != null ? updateUserData(u) : null);
  }

  Future<void> signInWithGoogle() async {
    final googleAuth = await (await _googleSignIn.signIn()).authentication;
    await _auth.signInWithCredential(GoogleAuthProvider.getCredential(
        idToken: googleAuth.idToken, accessToken: googleAuth.accessToken));
    updateUserData(await _auth.currentUser());
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  updateUserData(FirebaseUser user) async {
    DocumentReference ref = _db.collection('users').document(user.uid);

    ref.setData({
      'displayName': user.displayName ?? user.email,
      'email': user.email,
      'photoURL': user.photoUrl,
      'uid': user.uid,
      'lastSeen': DateTime.now()
    }, merge: true);
  }

  Future<FirebaseUser> getUser() async {
    FirebaseUser user = await _auth.currentUser();
    return user;
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
      'user_name': user.displayName,
      'photo_url': user.photoUrl,
    });
  }

  subscribeEvent(String eventId) async {
    FirebaseUser user = await _auth.currentUser();
    await _db
        .collection('users')
        .document(user.uid)
        .collection('events')
        .document(eventId)
        .setData({'time': Timestamp.now()});
  }

  Future<QuerySnapshot> getMyEventIds() async {
    FirebaseUser user = await _auth.currentUser();
    return await _db
        .collection('users')
        .document(user.uid)
        .collection('events')
        .getDocuments();
  }
}

final authService = AuthService();
