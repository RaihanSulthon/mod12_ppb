import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';

void main() {
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List dataBarang = [];
  var namaBarang = "";
  var jenisBarang = "";
  var deskripsiBarang = "";

  Future<void> readDataGudang() async {
    final connect = await MySqlConnection.connect(ConnectionSettings(
        host: '10.0.2.2', port: 3306, user: 'root', db: 'pbbmod12'));
    try {
      var result = await connect.query('SELECT * FROM gudang');
      setState(() {
        dataBarang.clear();
        for (var row in result) {
          dataBarang.add(row);
          print(row['namaBarang']);
        }
      });
    } catch (e) {
      print("Error reading data: $e");
    } finally {
      await connect.close();
    }
  }

  Future<void> createDataGudang() async {
    final connect = await MySqlConnection.connect(ConnectionSettings(
        host: '10.0.2.2', port: 3306, user: 'root', db: 'pbbmod12'));

    try {
      await connect.query(
        'INSERT INTO gudang (namaBarang, jenisBarang, deskripsiBarang) VALUES (?, ?, ?)',
        [namaBarang, jenisBarang, deskripsiBarang],
      );
    } catch (e) {
      print("Error inserting data: $e");
    } finally {
      await connect.close();
    }
  }

  @override
  void initState() {
    super.initState();
    readDataGudang();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "Data Gudang",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
        ),
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            child: dataBarang.isEmpty
                ? Center(child: Text("Tidak ada Barang"))
                : ListView.builder(
                    itemCount: dataBarang.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
                        decoration:
                            BoxDecoration(color: Colors.white, boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 0.5,
                            blurRadius: 3,
                            offset: Offset(0, 1),
                          ),
                        ]),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dataBarang[index]['namaBarang'],
                                style: TextStyle(fontSize: 20),
                              ),
                              Text(
                                dataBarang[index]['jenisBarang'],
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black.withOpacity(0.5)),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: Colors.white,
                  title: Text('Tambah Data Gudang'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Masukkan Nama Barang',
                          labelStyle:
                              TextStyle(color: Colors.black.withOpacity(0.60)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                                color: Colors.black.withOpacity(0.60)),
                          ),
                        ),
                        onChanged: (value) {
                          namaBarang = value;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        onChanged: (value) {
                          jenisBarang = value;
                        },
                        decoration: InputDecoration(
                          labelText: 'Masukkan Kategori Barang',
                          labelStyle:
                              TextStyle(color: Colors.black.withOpacity(0.6)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                                color: Colors.black.withOpacity(0.60)),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)),
                            ),
                            onPressed: () async {
                              if (namaBarang != "" &&
                                  jenisBarang != "" &&
                                  deskripsiBarang != "") {
                                await createDataGudang();
                                await readDataGudang();
                                Navigator.of(context).pop();
                              }
                            },
                            child: Text(
                              "Save",
                              style: TextStyle(color: Colors.white),
                            )),
                      )
                    ],
                  ),
                );
              },
            );
          },
          child: Icon(Icons.add),
          foregroundColor: Colors.white,
          shape: CircleBorder(),
          backgroundColor: Colors.blue,
        ),
      ),
    );
  }
}
