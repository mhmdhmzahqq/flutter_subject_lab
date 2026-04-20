import 'package:exel/logic.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مدير Excel و Firebase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

// ==================== الصفحة الرئيسية ====================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ExcelLogic _logic = ExcelLogic();
  final TextEditingController _fileNameController = TextEditingController();
  
  List<Map<String, dynamic>> _files = [];
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _logic.createFolder();
    await _loadFiles();
  }

  // تحميل قائمة الملفات
  Future<void> _loadFiles() async {
    List<Map<String, dynamic>> files = await _logic.getAllExcelFiles();
    
    // التحقق من حالة رفع كل ملف
    for (var file in files) {
      bool isUploaded = await _logic.isFileUploaded(file['name']);
      file['isUploaded'] = isUploaded;
      if (isUploaded) {
        file['fileId'] = await _logic.getFileId(file['name']);
      }
    }
    
    setState(() {
      _files = files;
    });
  }

  // إنشاء ملف جديد
  Future<void> _createNewFile() async {
    if (_fileNameController.text.isEmpty) {
      _showMessage('الرجاء إدخال اسم الملف', Colors.orange);
      return;
    }

    String? filePath = await _logic.createExcelFile(_fileNameController.text);
    
    if (filePath != null) {
      _showMessage('✅ تم إنشاء الملف بنجاح', Colors.green);
      _fileNameController.clear();
      await _loadFiles();
    } else {
      _showMessage('❌ فشل إنشاء الملف', Colors.red);
    }
  }

  // رفع ملف إلى Firebase
  Future<void> _uploadFile(String filePath, String fileName) async {
    setState(() {
      _isUploading = true;
    });

    var result = await _logic.uploadToFirebase(filePath, fileName);
    _showMessage(result['message'], 
        result['success'] ? Colors.green : Colors.red);
    
    if (result['success']) {
      await _loadFiles();
    }

    setState(() {
      _isUploading = false;
    });
  }

  // عرض البيانات من Firebase (مع الفلترة داخل الصفحة)
  void _viewData(String fileName, String fileId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DataViewPage(
          fileName: fileName,
          fileId: fileId,
        ),
      ),
    );
  }

  void _showMessage(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 مدير Excel و Firebase'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFiles,
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: Column(
        children: [
          // قسم إنشاء ملف جديد
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.teal.shade50,
            child: Column(
              children: [
                TextField(
                  controller: _fileNameController,
                  decoration: InputDecoration(
                    labelText: 'اسم الملف الجديد',
                    hintText: 'مثال: منتجاتي',
                    prefixIcon: const Icon(Icons.insert_drive_file),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.create_new_folder),
                  label: const Text('إنشاء ملف Excel جديد'),
                  onPressed: _createNewFile,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 45),
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // عنوان قائمة الملفات
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '📁 ملفات Excel المحفوظة:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_files.length} ملفات',
                    style: TextStyle(color: Colors.teal.shade800),
                  ),
                ),
              ],
            ),
          ),

          // قائمة الملفات
          Expanded(
            child: _files.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد ملفات',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'قم بإنشاء ملف جديد من الأعلى',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _files.length,
                    itemBuilder: (context, index) {
                      final file = _files[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: file['isUploaded'] ? Colors.green : Colors.orange,
                            child: Icon(
                              file['isUploaded'] ? Icons.cloud_done : Icons.cloud_off,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            file['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            file['isUploaded'] ? '✅ تم الرفع إلى Firebase' : '⏳ لم يتم الرفع بعد',
                            style: TextStyle(
                              color: file['isUploaded'] ? Colors.green : Colors.orange,
                              fontSize: 12,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // زر الرفع
                              IconButton(
                                icon: Icon(
                                  Icons.cloud_upload,
                                  color: file['isUploaded'] ? Colors.grey : Colors.teal,
                                ),
                                onPressed: _isUploading || file['isUploaded']
                                    ? null
                                    : () => _uploadFile(file['path'], file['name']),
                                tooltip: 'رفع إلى Firebase',
                              ),
                              // زر العرض (يظهر فقط بعد الرفع)
                              if (file['isUploaded'])
                                IconButton(
                                  icon: const Icon(Icons.visibility, color: Colors.teal),
                                  onPressed: () => _viewData(file['name'], file['fileId']),
                                  tooltip: 'عرض البيانات من Firebase',
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ==================== صفحة عرض البيانات مع الفلترة ====================
class DataViewPage extends StatefulWidget {
  final String fileName;
  final String fileId;

  const DataViewPage({
    super.key,
    required this.fileName,
    required this.fileId,
  });

  @override
  State<DataViewPage> createState() => _DataViewPageState();
}

class _DataViewPageState extends State<DataViewPage> {
  final ExcelLogic _logic = ExcelLogic();
  
  String _selectedCategory = 'الكل';
  List<String> _categories = ['الكل'];
  Map<String, dynamic> _statistics = {};

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadStatistics();
  }

  // تحميل الفئات المتوفرة في هذا الملف
  Future<void> _loadCategories() async {
    List<String> cats = await _logic.getCategoriesByFileId(widget.fileId);
    setState(() {
      _categories = ['الكل', ...cats];
    });
  }

  // تحميل الإحصائيات
  Future<void> _loadStatistics() async {
    Map<String, dynamic> stats = await _logic.getFileStatistics(widget.fileId);
    setState(() {
      _statistics = stats;
    });
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('📋 ${widget.fileName}'),
      backgroundColor: Colors.teal,
      foregroundColor: Colors.white,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          padding: const EdgeInsets.all(12),
          color: Colors.teal.shade700,
          child: Row(
            children: [
              const Icon(Icons.category, color: Colors.white),
              const SizedBox(width: 8),
              const Text(
                'فلترة حسب الفئة:',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    underline: const SizedBox(),
                    value: _selectedCategory,
                    items: _categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(cat == 'الكل' ? '📋 عرض الكل' : '📌 $cat'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value ?? 'الكل';
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    body: Column(
      children: [
        // بطاقات الإحصائيات
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.teal.shade50,
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.inventory,
                  label: 'عدد المنتجات',
                  value: '${_statistics['totalProducts'] ?? 0}',
                  color: Colors.teal,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.attach_money,
                  label: 'القيمة الإجمالية',
                  value: '\$${_statistics['totalValue'] ?? 0}',
                  color: Colors.teal,
                ),
              ),
            ],
          ),
        ),
        
        // قائمة المنتجات مع الفلترة
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _selectedCategory == 'الكل'
                ? _logic.getProductsByFileId(widget.fileId)
                : _logic.getProductsByFileIdAndCategory(widget.fileId, _selectedCategory),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('خطأ: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              var products = snapshot.data!.docs;

              if (products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        _selectedCategory == 'الكل'
                            ? 'لا توجد منتجات في هذا الملف'
                            : 'لا توجد منتجات في فئة "$_selectedCategory"',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  var data = products[index].data() as Map<String, dynamic>;
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white,
                            _getCategoryColor(data['category']).withOpacity(0.05),
                          ],
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: Container(
                          width: 55,
                          height: 55,
                          decoration: BoxDecoration(
                            color: _getCategoryColor(data['category']),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: _getCategoryColor(data['category']).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            _getCategoryIcon(data['category']),
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        title: Text(
                          data['name'] ?? 'بدون اسم',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getCategoryColor(data['category']).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.category, size: 14, color: _getCategoryColor(data['category'])),
                                      const SizedBox(width: 4),
                                      Text(
                                        data['category'] ?? 'عام',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _getCategoryColor(data['category']),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.inventory, size: 14, color: Colors.blue.shade700),
                                      const SizedBox(width: 4),
                                      Text(
                                        'الكمية: ${data['quantity']}',
                                        style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade100,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.teal.withOpacity(0.2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Text(
                            '\$${data['price']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.teal.shade800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    ),
  );
}

  // بطاقة إحصائية
  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // لون الفئة
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'إلكترونيات':
        return Colors.blue;
      case 'ملابس':
        return Colors.pink;
      case 'أثاث':
        return Colors.orange;
      default:
        return Colors.teal;
    }
  }

  // أيقونة الفئة
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'إلكترونيات':
        return Icons.computer;
      case 'ملابس':
        return Icons.checkroom;
      case 'أثاث':
        return Icons.weekend;
      default:
        return Icons.category;
    }
  }
}