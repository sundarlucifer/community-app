import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_app/models/event.dart';
import 'package:community_app/screens/add_event_screen.dart';
import 'package:community_app/services/auth_service.dart';
import 'package:community_app/utils/drawer.dart';
import 'package:flutter/material.dart';

class EventsScreen extends StatelessWidget {
  static const TAG = 'events-screen';

  List<String> myEvents = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      appBar: AppBar(
        title: Text('DashBoard'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EventForm())),
      ),
      body: StreamBuilder(
        stream: authService.getEvents(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            default:
              return ListView(
                children: snapshot.data.documents
                    .map<Widget>((DocumentSnapshot document) {
                  return CustomCard(
                    document: document,
                  );
                }).toList(),
              );
          }
        },
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final Event _event;

  CustomCard({
    Key key,
    @required DocumentSnapshot document,
  })  : _event = Event(document),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8.0,
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
      child: Container(
        child: makeListTile(),
      ),
    );
  }

  Widget makeListTile() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                child: Image.network(_event.photoUrl),
              ),
              SizedBox(width: 10.0),
              Text(_event.userName),
            ],
          ),
          SizedBox(height: 12.0),
          Text(_event.title, style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w600),),
          Divider(thickness: 2.0,),
          SizedBox(height: 8.0),
          Text(_event.content),
          SizedBox(height: 8.0),
          Text('Event date: ' + _event.date.toString().substring(0,10)),
          RaisedButton(
            child: Text('Subscribe'),
            onPressed: _subscribe,
          ),
        ],
      ),
    );
  }

  _subscribe() {
    authService.subscribeEvent(_event.id);
  }
}
