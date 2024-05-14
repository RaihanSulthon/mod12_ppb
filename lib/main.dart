import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primarySwatch: Colors.blue, scaffoldBackgroundColor: Colors.white),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, String>> _data = [];

  TextEditingController nama = TextEditingController();
  TextEditingController kategori = TextEditingController();
  TextEditingController deskripsi = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      String uri = "http://10.0.2.2/gudang_api/get_data.php";
      var res = await http.get(Uri.parse(uri));
      var response = jsonDecode(res.body);
      if (response["success"] == "true") {
        setState(() {
          _data = List<Map<String, String>>.from(
              response["data"].map((item) => Map<String, String>.from(item)));
        });
      } else {
        print("Failed to fetch data");
        setState(() {
          _data = [];
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        _data = [];
      });
    }
  }

  Future<void> insertData() async {
    if (nama.text.isNotEmpty &&
        kategori.text.isNotEmpty &&
        deskripsi.text.isNotEmpty) {
      try {
        String uri = "http://10.0.2.2/gudang_api/insert_data.php";

        var res = await http.post(Uri.parse(uri), body: {
          "nama": nama.text,
          "kategori": kategori.text,
          "deskripsi": deskripsi.text
        });

        var response = jsonDecode(res.body);
        if (response["success"] == "true") {
          print("Data telah ditemukan");
          fetchData();
        } else {
          print("Ada masalah!");
        }
      } catch (e) {
        print(e);
      }
    } else {
      print("Tolong isikan semua data yang ada");
    }
  }

  Future<void> deleteData(String id) async {
    try {
      String uri = "http://10.0.2.2/gudang_api/delete_data.php";
      var res = await http.post(Uri.parse(uri), body: {"id": id});
      var response = jsonDecode(res.body);
      if (response["success"] == "true") {
        print("Data telah dihapus");
        fetchData();
      } else {
        print("Gagal menghapus data");
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateData(
      String id, String nama, String kategori, String deskripsi) async {
    try {
      String uri = "http://10.0.2.2/gudang_api/update_data.php";
      var res = await http.post(Uri.parse(uri), body: {
        "id": id,
        "nama": nama,
        "kategori": kategori,
        "deskripsi": deskripsi
      });

      var response = jsonDecode(res.body);
      if (response["success"] == "true") {
        print("Data berhasil diperbarui");
        fetchData();
      } else {
        print("Gagal memperbarui data: ${response["message"]}");
      }
    } catch (e) {
      print("Terjadi kesalahan : $e");
    }
  }

  Future<void> editData(Map<String, String> item) async {
    nama.text = item['nama']!;
    kategori.text = item['kategori']!;
    deskripsi.text = item['deskripsi']!;
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Edit Data Gudang'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(height: 15),
                TextField(
                  controller: nama,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Masukkan Data Barang',
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: kategori,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Masukkan Kategori Barang',
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: deskripsi,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Masukkan Deskripsi Barang'),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  updateData(
                      item['id']!, nama.text, kategori.text, deskripsi.text);
                  Navigator.of(context).pop();
                  nama.clear();
                  kategori.clear();
                  deskripsi.clear();
                },
                child: Text('Simpan'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Batal'),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Data Gudang',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        itemCount: _data.length,
        itemBuilder: (context, index) {
          final item = _data[index];
          return ItemCard(
              item: item,
              onDelete: () {
                deleteData(item['id']!);
              },
              onTap: () {
                editData(item);
              });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Tambah Data Gudang'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const SizedBox(height: 15),
                    TextField(
                      controller: nama,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Masukkan Data Barang',
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: kategori,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Masukkan Kategori Barang',
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: deskripsi,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Masukkan Deskripsi Barang',
                      ),
                    )
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      insertData();
                      Navigator.of(context).pop();
                      nama.clear();
                      kategori.clear();
                      deskripsi.clear();
                    },
                    child: const Text('Simpan'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Batal'),
                  )
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ItemCard extends StatelessWidget {
  final Map<String, String> item;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  ItemCard({required this.item, required this.onDelete, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(item['nama']!),
        subtitle: Text(item['kategori']!),
        onTap: onTap,
        onLongPress: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Hapus Data'),
                  content:
                      const Text('Apakah Anda yakin ingin menghapus data ini'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () {
                        onDelete();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Hapus'),
                    )
                  ],
                );
              });
        },
      ),
    );
  }
}
