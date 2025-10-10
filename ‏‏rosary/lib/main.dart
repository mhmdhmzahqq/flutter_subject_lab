import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SebhaPage(),
    );
  }
}

class SebhaPage extends StatefulWidget {
  const SebhaPage({super.key});

  @override
  State<SebhaPage> createState() => _SebhaPageState();
}

class _SebhaPageState extends State<SebhaPage> {
  int subhanallah = 0;
  int alhamdulillah = 0;
  int allahuakbar = 0;

  void resetCounters() {
    setState(() {
      subhanallah = 0;
      alhamdulillah = 0;
      allahuakbar = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "مسبحة الأذكار",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // زر سبحان الله
          Card(
            color: Colors.blue.shade50,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: const Text(
                "سبحان الله",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "العدد: $subhanallah",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: Colors.black54),
              ),
              onTap: () {
                setState(() {
                  subhanallah++;
                });
              },
            ),
          ),

          // زر الحمد لله
          Card(
            color: Colors.blue.shade50,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: const Text(
                "الحمد لله",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "العدد: $alhamdulillah",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: Colors.black54),
              ),
              onTap: () {
                setState(() {
                  alhamdulillah++;
                });
              },
            ),
          ),

          // زر الله أكبر
          Card(
            color: Colors.blue.shade50,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: const Text(
                "الله أكبر",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "العدد: $allahuakbar",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: Colors.black54),
              ),
              onTap: () {
                setState(() {
                  allahuakbar++;
                });
              },
            ),
          ),

          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: resetCounters,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            child: const Text(
              "تصفير العدادات",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
