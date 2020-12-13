import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_app/models/post.dart';
import 'package:community_app/models/user.dart';
import 'package:community_app/screens/add_post_screen.dart';
import 'package:community_app/services/auth_service.dart';
import 'package:community_app/utils/drawer.dart';
import 'package:flutter/material.dart';

class PostScreen extends StatefulWidget {
  static const TAG = 'post-screen';

  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      appBar: _appBar(),
      body: _body(),
      floatingActionButton: _addPostButton(),
    );
  }

  Widget _appBar() {
    return AppBar(
      title: Text('Posts'),
    );
  }

  Widget _body() {
    return StreamBuilder(
        stream: authService.getPosts(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong!'));
          }
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            default:
              if (!snapshot.hasData || snapshot.data.documents.length == 0)
                return Center(child: Text('No post has been created yet'));
              return ListView(
                children: snapshot.data.documents
                    .map((doc) => FutureBuilder(
                          future: authService.getUser(doc.data['user_id']),
                          builder: (context, AsyncSnapshot<User> snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.done &&
                                snapshot.hasData) {
                              final post = Post.from(doc, snapshot.data);
                              return _buildCard(post);
                            }
                            return Center(child: CircularProgressIndicator());
                          },
                        ))
                    .toList(),
              );
          }
        });
  }

  _buildCard(Post post) {
    return Card(
      elevation: 8.0,
      margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    child: Image.network(post.photoUrl),
                    radius: 16,
                  ),
                  SizedBox(width: 10.0),
                  Text(
                    post.userName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Spacer(),
                  GestureDetector(
                    child: Icon(Icons.more_vert),
                    onTap: () => _showOptions(post),
                  ),
                ],
              ),
              SizedBox(height: 12.0),
              Text(post.content),
              SizedBox(height: 8.0),
              Divider(),
              Text('Posted on: ' + post.dateTime.toString().substring(0, 16)),
            ],
          ),
        ),
      ),
    );
  }

  _showOptions(Post post) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        contentPadding: EdgeInsets.all(12),
        children: <Widget>[
          if(authService.user.uid == post.userId)
            FlatButton(
              child: Text('Delete post'),
              onPressed: () {
                authService.deletePost(post.id);
                Navigator.pop(context);
              },
            )
          else
            Text('No options available for this post')
        ],
      ),
    );
  }

  Widget _addPostButton() {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => PostForm())),
    );
  }
}
