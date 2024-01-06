import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // tambahkan impor ini

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final String username = _usernameController.text;
                final String password = _passwordController.text;

                if (username == 'mahasiswa' && password == '123') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AbsenPage()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Login gagal')),
                  );
                }
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class AbsenPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Absensi'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            final String currentTime = DateTime.now().toString();
            List<Map<String, dynamic>> riwayatAbsensi =
                (prefs.getStringList('riwayat_absensi') ?? []).map((e) {
              Map<String, dynamic> map = Map<String, dynamic>.from(
                  Map<String, dynamic>.from(json.decode(e)));
              return {
                'nama': map['nama'],
                'nim': map['nim'],
                'status': map['status'],
                'waktu': map['waktu'],
              };
            }).toList();
            riwayatAbsensi.add({
              'nama': 'John Doe',
              'nim': '123456',
              'status': 'Sudah Absen',
              'waktu': currentTime
            });
            prefs.setStringList('riwayat_absensi',
                riwayatAbsensi.map((e) => json.encode(e)).toList());

            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Absensi Berhasil'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          },
          child: const Text('Absen'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RiwayatAbsensiPage(),
            ),
          );
        },
        child: const Icon(Icons.history),
      ),
    );
  }
}

class RiwayatAbsensiPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Absensi'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadRiwayatAbsensi(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            List<Map<String, dynamic>>? riwayatAbsensi = snapshot.data;
            return ListView.builder(
              itemCount: riwayatAbsensi?.length ?? 0,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(riwayatAbsensi![index]['nama']!),
                  subtitle: Text('NIM: ${riwayatAbsensi[index]['nim']}'),
                  trailing: Text('Status: ${riwayatAbsensi[index]['status']}'),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _loadRiwayatAbsensi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedRiwayatAbsensi = prefs.getStringList('riwayat_absensi');

    if (savedRiwayatAbsensi != null) {
      return savedRiwayatAbsensi.map((e) {
        Map<String, dynamic> map = Map<String, dynamic>.from(
            Map<String, dynamic>.from(json.decode(e)));
        return {
          'nama': map['nama'],
          'nim': map['nim'],
          'status': map['status'],
          'waktu': map['waktu'],
        };
      }).toList();
    } else {
      return [];
    }
  }
}
