import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_app/models/event.dart';
import 'package:community_app/models/user.dart';
import 'package:community_app/services/auth_service.dart';
import 'package:community_app/utils/drawer.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  static const TAG = 'home-screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> myEvents = [];

  getEventIds() async {
    myEvents.clear();
    myEvents.addAll(await authService.getMyEventIds());
    setState(() => myEvents = myEvents);
    print('Mine: ' + myEvents.toString());
  }

  @override
  void initState() {
    getEventIds();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      appBar: AppBar(
        title: Text('DashBoard'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text(
                'Subscibed events',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 32),
              ),
            ),
            StreamBuilder(
              stream: authService.getEvents(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Center(child: CircularProgressIndicator());
                  default:
                    return Column(
                      children: snapshot.data.documents
                          .where((DocumentSnapshot snap) =>
                              myEvents.contains(snap.documentID))
                          .map((doc) => FutureBuilder(
                                future:
                                    authService.getUser(doc.data['user_id']),
                                builder:
                                    (context, AsyncSnapshot<User> snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    final event =
                                        Event.from(doc, snapshot.data);
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
          ],
        ),
      ),
    );
  }

  Widget _buildCard(Event event) {
    return Card(
      elevation: 2.0,
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
                  Text(
                    event.userName,
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 24),
                  ),
                ],
              ),
              Divider(
                thickness: 2.0,
              ),
              Text(
                event.title,
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Text(event.content),
              SizedBox(height: 8.0),
              Text('Event date: ' + event.date.toString().substring(0, 10)),
              SizedBox(height: 8.0),
              RaisedButton(
                child: Text('UnSubscribe'),
                onPressed: () => _unSubscribe(event),
                color: Colors.red,
                textColor: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _unSubscribe(Event event) async {
    await authService.unSubscribeEvent(event.id);
    getEventIds();
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
            child: Text('UnSubscribe'),
            onPressed: _unSubscribe,
            color: Colors.red,
            textColor: Colors.white,
          ),
        ],
      ),
    );
  }

  _unSubscribe() {
    authService.unSubscribeEvent(event.id);
  }
}
