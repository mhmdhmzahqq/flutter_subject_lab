import 'package:exel/excel.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Excel Manager',
      theme: ThemeData(primarySwatch: Colors.teal, useMaterial3: true),
      home: const MyHomePage(),
    );
  }
}

// ------------------- الشاشة الرئيسية -------------------
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _textController = TextEditingController();
  final ExcelHelper _excelHelper = ExcelHelper();
  List<String> _files = []; // تخزن الملفات الموجودة

  @override
  void initState() {
    super.initState();
    _excelHelper.createExceldir(); // إنشاء مجلد التنزيلات
    _refreshFiles(); // تحميل الملفات
  }

  Future<void> _refreshFiles() async {
    await Permission.storage.request(); // طلب الإذن
    var files = await _excelHelper.findExcelFiles();
    setState(() {
      _files = files;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("مدير ملفات الاكسل")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // قسم إنشاء الملف
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'اسم الملف الجديد',
                        prefixIcon: Icon(Icons.description),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (_textController.text.isNotEmpty) {
                          await _excelHelper.createExcel(_textController.text);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("تم إنشاء الملف بنجاح"),
                            ),
                          );
                          _refreshFiles(); // تحديث القائمة
                          _textController.clear();
                        }
                      },
                      icon: const Icon(Icons.save),
                      label: const Text("إنشاء وحفظ ملف Excel"),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                "الملفات المحفوظة (اضغط للفتح):",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 10),

            // قائمة الملفات الموجودة
            Expanded(
              child: _files.isEmpty
                  ? const Center(child: Text("لا توجد ملفات، قم بإنشاء واحد."))
                  : ListView.builder(
                      itemCount: _files.length,
                      itemBuilder: (context, index) {
                        String filePath = _files[index];
                        String fileName = filePath.split('/').last;
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            leading: const Icon(
                              Icons.table_view,
                              color: Colors.green,
                            ),
                            title: Text(fileName),
                            subtitle: Text(
                              filePath,
                              style: const TextStyle(fontSize: 10),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () async {
                              try {
                                var data = await _excelHelper.readExcel(
                                  filePath,
                                );
                                if (context.mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DataDisplayPage(
                                        fileName: fileName,
                                        data: data,
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("خطأ: $e")),
                                );
                              }
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshFiles,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

// ------------------- شاشة العرض  -------------------
class DataDisplayPage extends StatelessWidget {
  final String fileName;
  final List<Map<String, dynamic>> data;

  const DataDisplayPage({
    super.key,
    required this.fileName,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(fileName)),
      backgroundColor: Colors.grey[100],
      body: data.isEmpty
          ? const Center(child: Text("الملف فارغ"))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];

                // هنا نقوم بتخصيص العرض حسب الرغبة
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item['اسم المنتج'] ?? 'بدون اسم',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "${item['السعر']} \$",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepOrange,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          children: [
                            _buildInfoChip(
                              Icons.category,
                              item['الفئة'] ?? '-',
                            ),
                            const SizedBox(width: 15),
                            _buildInfoChip(
                              Icons.inventory,
                              "العدد: ${item['الكمية']}",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
