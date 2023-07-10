import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> data = [];

  Future<List<String>> fetchData() async {
    final response = await http.get(Uri.parse('https://nomor-2-b9c18-default-rtdb.firebaseio.com/'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return jsonData.values.toList().cast<String>();
    } else {
      throw Exception('Gagal mengambil data');
    }
  }

  Future<void> addData(String newData) async {
    final response = await http.post(
      Uri.parse('https://nomor-2-b9c18-default-rtdb.firebaseio.com/'),
      body: json.encode(newData),
    );

    if (response.statusCode == 200) {
      setState(() {
        data.add(newData);
      });
    } else {
      throw Exception('Gagal menambahkan data');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData().then((result) {
      setState(() {
        data = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('UAS NOMOR 2'),
      ),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(data[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              TextEditingController controller = TextEditingController();
              return AlertDialog(
                title: Text('Tambah Data'),
                content: TextField(
                  controller: controller,
                  decoration: InputDecoration(labelText: 'Data'),
                ),
                actions: <Widget>[
                  FloatingActionButton(
                    child: Text('Batal'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  FloatingActionButton(
                    child: Text('Simpan'),
                    onPressed: () {
                      addData(controller.text);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
