import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:jiffy/jiffy.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'firebase_options.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zimbabwe Fire Conference Access Control',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Zimbabwe Fire Conference Access Control'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _passed = false;
  final passwordController = TextEditingController();
  final receiptController = TextEditingController();
  final lastNameController = TextEditingController();
  // Initial Selected Value
  String dropdownvalue = 'Friday Session';

  // List of items in our dropdown menu
  var items = [
    'Friday Session',
    'Saturday Singles Session',
    'Saturday Marriage Session',
    'Saturday Evening Session',
    'Sunday Session',
  ];

  var _loading = false;
  var _added = false;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    passwordController.dispose();
    receiptController.dispose();
    super.dispose();
  }

  Future<void> _getItem(String receipt, BuildContext context) async {
    final appDir = await getApplicationDocumentsDirectory();
    await appDir.create(recursive: true);
    final databasePath = join(appDir.path, "sembast.db");
    final sembastDb = await databaseFactoryIo.openDatabase(databasePath);
    var store = intMapStoreFactory.store('registrations');

    var records = (await (store.find(sembastDb,
        finder: Finder(filter: Filter.matches('receipt', receipt)))));

    _added = false;
    setState(() {});

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Search result'),
            content: setupAlertDialoadContainer(records),
          );
        });
  }

  Future<void> _getPerson(String last, BuildContext context) async {
    final appDir = await getApplicationDocumentsDirectory();
    await appDir.create(recursive: true);
    final databasePath = join(appDir.path, "sembast.db");
    final sembastDb = await databaseFactoryIo.openDatabase(databasePath);
    var store = intMapStoreFactory.store('registrations');

    var records = (await (store.find(sembastDb,
        finder: Finder(filter: Filter.matches('last', last)))));

    _added = false;
    setState(() {});

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Search result'),
            content: setupAlertDialoadContainer(records),
          );
        });
  }

  Widget setupAlertDialoadContainer(dynamic results) {
    return Container(
      height: 300.0, // Change as per your requirement
      width: 300.0, // Change as per your requirement
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: results.length,
        itemBuilder: (BuildContext context, int index) {
          return RadioListTile(
            onChanged: (value) => {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                        title: Text('${value['first']} ${value['last']} '),
                        content: _loading
                            ? loader(context)
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size.fromHeight(
                                      40), // fromHeight use double.infinity as width and 40 is the height
                                ),
                                onPressed: () async {
                                  final appDir =
                                      await getApplicationDocumentsDirectory();
                                  await appDir.create(recursive: true);
                                  final databasePath =
                                      join(appDir.path, "sembast.db");
                                  final sembastDb = await databaseFactoryIo
                                      .openDatabase(databasePath);
                                  var store =
                                      intMapStoreFactory.store('attendance');

                                  await store.add(sembastDb, {
                                    'id': value['id'],
                                    'designation': value['designation'],
                                    'first': value['first'],
                                    'last': value['last'],
                                    'phone': value['phone'],
                                    'email': value['email'],
                                    'chapter': value['chapter'],
                                    'paid': value['paid'],
                                    'receipt': value['receipt'].toString(),
                                    'date': value['date']
                                  });

                                  _added = false;

                                  setState(() {});

                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    backgroundColor: Colors.green,
                                    duration: Duration(seconds: 10),
                                    content: Text(
                                        '${value['first']} ${value['last']} marked as attended'),
                                  ));
                                },
                                child: Text(_added
                                    ? '${value['first']} ${value['last']} marked as attended'
                                    : 'Confirm  as attended'),
                              ));
                  })
            },
            value: results[index],
            title: Text(results[index]['first'] +
                " " +
                results[index]['last'] +
                " " +
                results[index]['receipt'] +
                results[index]['chapter']),
            groupValue: results,
          );
        },
      ),
    );
  }

  Widget getPortal(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DropdownButton(
            // Initial Value
            value: dropdownvalue,

            // Down Arrow Icon
            icon: const Icon(Icons.keyboard_arrow_down),

            // Array list of items
            items: items.map((String items) {
              return DropdownMenuItem(
                value: items,
                child: Text(items),
              );
            }).toList(),
            // After selecting the desired option,it will
            // change button value to selected value
            onChanged: (String? newValue) {
              setState(() {
                dropdownvalue = newValue!;
              });
            },
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: TextField(
              controller: receiptController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter receipt number',
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: TextField(
              controller: lastNameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter last name',
              ),
            ),
          ),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(
                      40), // fromHeight use double.infinity as width and 40 is the height
                ),
                onPressed: () {
                  if (receiptController.text == "") {
                    _getPerson(lastNameController.text, context);
                  } else if (lastNameController.text == "") {
                    _getItem(receiptController.text, context);
                  }
                },
                child: Text('Confirm Attendance'),
              )),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(
                      40), // fromHeight use double.infinity as width and 40 is the height
                ),
                onPressed: () async {
                  _loading = true;

                  setState(() {});

                  final appDir = await getApplicationDocumentsDirectory();
                  await appDir.create(recursive: true);
                  final databasePath = join(appDir.path, "sembast.db");
                  final sembastDb =
                      await databaseFactoryIo.openDatabase(databasePath);
                  var store = intMapStoreFactory.store('attendance');

                  var records = (await (store.find(
                    sembastDb,
                  )));

                  await Firebase.initializeApp(
                    options: DefaultFirebaseOptions.currentPlatform,
                  );
                  var db = FirebaseFirestore.instance;
                  var session = dropdownvalue;

                  if (session == "Friday Session") {
                    for (var record in records) {
                      await db
                          .collection("registration")
                          .doc('${record['id']}')
                          .update({"FridaySession": true});
                    }
                  } else if (session == "Saturday Singles Session") {
                    for (var record in records) {
                      await db
                          .collection("registration")
                          .doc('${record['id']}')
                          .update({"SaturdaySinglesSession": true});
                    }
                  } else if (session == "Saturday Marriage Session") {
                    for (var record in records) {
                      await db
                          .collection("registration")
                          .doc('${record['id']}')
                          .update({"SaturdayMarriageSession": true});
                    }
                  } else if (session == "Saturday Evening Session") {
                    for (var record in records) {
                      await db
                          .collection("registration")
                          .doc('${record['id']}')
                          .update({"SaturdayEveningSession": true});
                    }
                  } else if (session == "Sunday Session") {
                    for (var record in records) {
                      await db
                          .collection("registration")
                          .doc('${record['id']}')
                          .update({"SundaySession": true});
                    }
                  }
                  _loading = false;

                  setState(() {});
                },
                child: Text('Upload Attendance Report'),
              )),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(
                      40), // fromHeight use double.infinity as width and 40 is the height
                ),
                onPressed: () async {
                  _loading = true;

                  setState(() {});

                  // File path to a file in the current directory
                  final appDir = await getApplicationDocumentsDirectory();
                  await appDir.create(recursive: true);
                  final databasePath = join(appDir.path, "sembast.db");
                  final sembastDb =
                      await databaseFactoryIo.openDatabase(databasePath);
                  var store = intMapStoreFactory.store('registrations');

                  await store.delete(sembastDb);

                  await Firebase.initializeApp(
                    options: DefaultFirebaseOptions.currentPlatform,
                  );
                  var db = FirebaseFirestore.instance;
                  await db.collection("registration").get().then((event) async {
                    int noOfTimes = 0;
                    for (var doc in event.docs) {
                      Map<String, dynamic> data = doc.data();
                      await store.add(sembastDb, {
                        'id': doc.reference.id,
                        'designation': data['Designation'],
                        'first': data['FirstName'],
                        'last': data['LastName'],
                        'phone': data['PhoneNumber'],
                        'email': data['Email'],
                        'chapter': data['Chapter'],
                        'paid': data['Paid'],
                        'receipt': data['ReceiptNo'].toString(),
                        'date': data['date']
                      });
                    }

                    _loading = false;

                    setState(() {});

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      backgroundColor: Colors.blue,
                      duration: Duration(seconds: 10),
                      content: Text("Database Synchronized"),
                    ));
                  });
                },
                child: Text('Sync with database'),
              ))
        ],
      ),
    );
  }

  Widget loader(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(top: 20),
        child: CircularProgressIndicator(
          value: 0.8,
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue),
        ));
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: Container(
            // Center is a layout widget. It takes a single child and positions it
            // in the middle of the parent.
            child: _loading ? loader(context) : getPortal(context))
        // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}
