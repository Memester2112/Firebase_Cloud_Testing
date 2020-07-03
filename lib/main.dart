import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baby Names',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text('Baby Name Votes'))),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('baby').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
      //works om each map element of the snapshot list, converts them to a List Item
      //And compiles the iterable to a list
    );
  }

//
//  Widget _buildListItem(BuildContext context, Map data) {
//    final record = Record.fromMap(data); //method defined below
  //record is used to retrieve a JSON Object
  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);
    return Padding(
      key: ValueKey(
          record.name), //unique key to maintain state, parameter chosen is name
      //as that is the only unique field(names,votes)
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
            title: Text(record.name),
            trailing: Text(record.votes.toString()),
            onTap: () => record.reference.updateData(
                {'votes': FieldValue.increment(1)}) //atomic increment
            //only a single user can access the data field to increment it any time. Prevents the race condition
            //onTap: () => record.reference.updateData({'votes': record.votes + 1}),//naive way,creates race condition
            // if 2 users click on the same time the data base will be incremented by only 1, not 2 as it should be
            //thus we use FieldValue.increment(1) to make it so that only one user can change the data base at a time
            //record.reference is used to uniquely identify data
            ),
      ),
    );
  }
}

class Record {
  final String name;
  final int votes;
  final DocumentReference reference;

  //document reference will be used by the actual method
  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null),
        assert(map['votes'] != null),
        name = map['name'],
        votes = map['votes'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override //overrides the method toString() to display the formatted output as :
  //Name:Votes for the class objects of Record type.
  String toString() => "Record<$name:$votes>";
}
