import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:permission_handler/permission_handler.dart';

class ExcelLogic {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== 1. دوال الملفات ====================

  // إنشاء مجلد التحميلات إذا لم يكن موجوداً
  Future<void> createFolder() async {
    final directory = Directory("/storage/emulated/0/Download/excel");
    if (!await directory.exists()) {
      await directory.create(recursive: true);
      print("✅ تم إنشاء المجلد: ${directory.path}");
    }
  }

  // إنشاء ملف Excel جديد وحفظه
  Future<String?> createExcelFile(String fileName) async {
    if (await Permission.storage.request().isGranted ||
        await Permission.manageExternalStorage.request().isGranted) {
      var excel = Excel.createExcel();
      Sheet sheet = excel['Sheet1'];

      // إضافة العناوين
      List<String> headers = ["اسم المنتج", "السعر", "الكمية", "الفئة"];
      for (int i = 0; i < headers.length; i++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
            .value = TextCellValue(
          headers[i],
        );
      }

      // بيانات تجريبية
      List<Map<String, dynamic>> sampleData = [
        {
          'name': 'هاتف',
          'price': '1500',
          'quantity': '10',
          'category': 'إلكترونيات',
        },
        {'name': 'قبعة', 'price': '50', 'quantity': '25', 'category': 'ملابس'},
        {'name': 'طاولة', 'price': '1200', 'quantity': '5', 'category': 'أثاث'},
        {
          'name': 'لابتوب',
          'price': '3000',
          'quantity': '8',
          'category': 'إلكترونيات',
        },
        {'name': 'قميص', 'price': '80', 'quantity': '15', 'category': 'ملابس'},
        {'name': 'كرسي', 'price': '250', 'quantity': '12', 'category': 'أثاث'},
        {
          'name': 'ساعة',
          'price': '500',
          'quantity': '7',
          'category': 'إلكترونيات',
        },
      ];

      // تعبئة البيانات
      for (int i = 0; i < sampleData.length; i++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1))
            .value = TextCellValue(
          sampleData[i]['name'],
        );
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1))
            .value = TextCellValue(
          sampleData[i]['price'],
        );
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1))
            .value = TextCellValue(
          sampleData[i]['quantity'],
        );
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1))
            .value = TextCellValue(
          sampleData[i]['category'],
        );
      }

      // حفظ الملف
      final String path = "/storage/emulated/0/Download/excel/$fileName.xlsx";
      File file = File(path);
      var bytes = excel.encode();

      if (bytes != null) {
        await file.writeAsBytes(bytes, flush: true);
        print("✅ تم حفظ الملف في: $path");
        return path;
      }
    } else {
      print("❌ لا يوجد إذن تخزين");
    }
    return null;
  }

  // قراءة ملف Excel وتحويله إلى قائمة بيانات
  Future<List<Map<String, dynamic>>> readExcelFile(String filePath) async {
    try {
      var bytes = File(filePath).readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);
      List<Map<String, dynamic>> data = [];

      for (var table in excel.tables.keys) {
        var sheet = excel.tables[table]!;
        if (sheet.maxRows == 0) continue;

        // قراءة العناوين
        List<String> headers = [];
        for (int col = 0; col < sheet.maxColumns; col++) {
          var cell = sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0),
          );
          headers.add(cell.value?.toString() ?? "col_$col");
        }

        // قراءة البيانات
        for (int row = 1; row < sheet.maxRows; row++) {
          Map<String, dynamic> rowData = {};
          bool isEmptyRow = true;

          for (int col = 0; col < sheet.maxColumns; col++) {
            var cell = sheet.cell(
              CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row),
            );
            String value = cell.value?.toString() ?? "";

            if (value.isNotEmpty) isEmptyRow = false;

            if (col < headers.length) {
              rowData[headers[col].trim()] = value;
            }
          }

          if (!isEmptyRow) {
            data.add(rowData);
          }
        }
      }

      print("✅ تم قراءة ${data.length} صف من الملف");
      return data;
    } catch (e) {
      print("❌ خطأ في قراءة الملف: $e");
      return [];
    }
  }

  // الحصول على قائمة بجميع ملفات Excel الموجودة
  Future<List<Map<String, dynamic>>> getAllExcelFiles() async {
    final directory = Directory("/storage/emulated/0/Download/excel");
    List<Map<String, dynamic>> files = [];

    if (await directory.exists()) {
      var allFiles = directory.listSync();
      for (var file in allFiles) {
        if (file.path.toLowerCase().endsWith('.xlsx')) {
          String fileName = file.path.split('/').last;
          files.add({'path': file.path, 'name': fileName});
        }
      }
    }

    print("✅ تم العثور على ${files.length} ملف");
    return files;
  }

  // ==================== 2. دوال Firebase ====================

  // رفع البيانات من Excel إلى Firebase
  Future<Map<String, dynamic>> uploadToFirebase(
    String filePath,
    String fileName,
  ) async {
    try {
      List<Map<String, dynamic>> excelData = await readExcelFile(filePath);

      if (excelData.isEmpty) {
        return {
          'success': false,
          'message': 'الملف فارغ، لا توجد بيانات للرفع',
        };
      }

      DocumentReference fileDoc = _firestore.collection('excel_files').doc();
      String fileDocId = fileDoc.id;

      await fileDoc.set({
        'fileName': fileName,
        'uploadedAt': FieldValue.serverTimestamp(),
        'totalItems': excelData.length,
      });

      for (var item in excelData) {
        await fileDoc.collection('products').add({
          'name': item['اسم المنتج'] ?? item['name'] ?? 'بدون اسم',
          'price': int.tryParse(item['السعر'] ?? item['price'] ?? '0') ?? 0,
          'quantity':
              int.tryParse(item['الكمية'] ?? item['quantity'] ?? '0') ?? 0,
          'category': item['الفئة'] ?? item['category'] ?? 'عام',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return {
        'success': true,
        'message': '✅ تم رفع ${excelData.length} منتج بنجاح',
        'fileDocId': fileDocId,
      };
    } catch (e) {
      return {'success': false, 'message': '❌ خطأ في الرفع: $e'};
    }
  }

  // التحقق من رفع الملف مسبقاً
  Future<bool> isFileUploaded(String fileName) async {
    try {
      QuerySnapshot query = await _firestore
          .collection('excel_files')
          .where('fileName', isEqualTo: fileName)
          .limit(1)
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      print('❌ خطأ في التحقق: $e');
      return false;
    }
  }

  // الحصول على ID الملف من اسمه
  Future<String?> getFileId(String fileName) async {
    try {
      QuerySnapshot query = await _firestore
          .collection('excel_files')
          .where('fileName', isEqualTo: fileName)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return query.docs.first.id;
      }
      return null;
    } catch (e) {
      print('❌ خطأ: $e');
      return null;
    }
  }

  // ==================== 3. دوال القراءة من Firebase ====================

  // جلب منتجات ملف محدد
  Stream<QuerySnapshot> getProductsByFileId(String fileId) {
    return _firestore
        .collection('excel_files')
        .doc(fileId)
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // جلب منتجات حسب الفئة (فلترة) لملف محدد
  Stream<QuerySnapshot> getProductsByFileIdAndCategory(
    String fileId,
    String category,
  ) {
    if (category.isEmpty) {
      return getProductsByFileId(fileId);
    }
    return _firestore
        .collection('excel_files')
        .doc(fileId)
        .collection('products')
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // جلب جميع الفئات المتوفرة في ملف محدد
  Future<List<String>> getCategoriesByFileId(String fileId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('excel_files')
          .doc(fileId)
          .collection('products')
          .get();

      Set<String> categories = {};

      for (var doc in snapshot.docs) {
        String category = doc.get('category') ?? 'عام';
        categories.add(category);
      }

      return categories.toList()..sort();
    } catch (e) {
      print('❌ خطأ في جلب الفئات: $e');
      return [];
    }
  }

  // جلب إحصائيات الملف (عدد المنتجات، إجمالي القيمة)
  Future<Map<String, dynamic>> getFileStatistics(String fileId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('excel_files')
          .doc(fileId)
          .collection('products')
          .get();

      int totalProducts = snapshot.docs.length;
      int totalValue = 0;

      for (var doc in snapshot.docs) {
        int price = doc.get('price') ?? 0;
        int quantity = doc.get('quantity') ?? 0;
        totalValue += (price * quantity);
      }

      return {'totalProducts': totalProducts, 'totalValue': totalValue};
    } catch (e) {
      return {'totalProducts': 0, 'totalValue': 0};
    }
  }
}
