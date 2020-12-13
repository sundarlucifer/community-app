import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_app/models/event.dart';
import 'package:community_app/models/user.dart';
import 'package:community_app/screens/add_event_screen.dart';
import 'package:community_app/services/auth_service.dart';
import 'package:community_app/utils/drawer.dart';
import 'package:flutter/material.dart';

class EventsScreen extends StatefulWidget {
  static const TAG = 'events-screen';

  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  List<String> myEvents = [];

  fetchMySubs() async {
    myEvents.clear();
    myEvents.addAll(await authService.getMyEventIds());
    setState(() => myEvents = myEvents);
  }

  @override
  void initState() {
    fetchMySubs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      appBar: AppBar(
        title: Text('Events'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => EventForm())),
      ),
      body: StreamBuilder(
        stream: authService.getEvents(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
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
                            print(snapshot.data);
                            if (snapshot.connectionState ==
                                    ConnectionState.done &&
                                snapshot.hasData) {
                              final event = Event.from(doc, snapshot.data);
                              return _buildCard(event);
                            }
                            return Center();
                          },
                        ))
                    .toList(),
              );
          }
        },
      ),
    );
  }

  Widget _buildCard(Event event) {
    return Card(
      elevation: 8.0,
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    child: Image.network(event.photoUrl),
                  ),
                  SizedBox(width: 10.0),
                  Text(event.userName),
                ],
              ),
              SizedBox(height: 12.0),
              Text(
                event.title,
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w600),
              ),
              Divider(
                thickness: 2.0,
              ),
              SizedBox(height: 8.0),
              Text(event.content),
              SizedBox(height: 8.0),
              Text('Event date: ' + event.date.toString().substring(0, 10)),
              Divider(
                thickness: 2.0,
              ),
              myEvents.contains(event.id)
                  ? Text('Subscribed! Available in dashboard')
                  : RaisedButton(
                      child: Text('Subscribe'),
                      onPressed: () => _subscribe(event),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  _subscribe(Event event) async {
    await authService.subscribeEvent(event.id);
    fetchMySubs();
  }
}

class CustomCard extends StatelessWidget {
  final Event event;

  const CustomCard({Key key, this.event}) : super(key: key);

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
                child: Image.network(event.photoUrl),
              ),
              SizedBox(width: 10.0),
              Text(event.userName),
            ],
          ),
          SizedBox(height: 12.0),
          Text(
            event.title,
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w600),
          ),
          Divider(
            thickness: 2.0,
          ),
          SizedBox(height: 8.0),
          Text(event.content),
          SizedBox(height: 8.0),
          Text('Event date: ' + event.date.toString().substring(0, 10)),
          RaisedButton(
            child: Text('Subscribe'),
            onPressed: _subscribe,
          ),
        ],
      ),
    );
  }

  _subscribe() {
    authService.subscribeEvent(event.id);
  }
}
