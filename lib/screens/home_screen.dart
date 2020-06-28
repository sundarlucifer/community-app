import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_app/models/event.dart';
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
    myEvents = (await authService.getMyEventIds()).documents.map((d) => d.documentID).toList();
    setState(() => myEvents);
    print('Mine: '+myEvents.toString());
  }

  @override
  void initState() {
    getEventIds();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width * 0.7,
        child: MyDrawer(),
      ),
      appBar: AppBar(
        title: Text('DashBoard'),
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
            print(snapshot.data.documents.map((d) => d.documentID));
              return ListView(
                children: snapshot.data.documents
                    .where((DocumentSnapshot snap) => myEvents.contains(snap.documentID))
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
          Text(
            _event.title,
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w600),
          ),
          Divider(
            thickness: 2.0,
          ),
          SizedBox(height: 8.0),
          Text(_event.content),
          SizedBox(height: 8.0),
          Text('Event date: ' + _event.date.toString().substring(0, 10)),
          // RaisedButton(
          //   child: Text('Subscribe'),
          //   onPressed: _subscribe,
          // ),
        ],
      ),
    );
  }

  // _unSubscribe() {
  //   authService.unSubscribeEvent(_event.id);
  // }
}
