import 'dart:io';
import 'package:excel/excel.dart';
import 'package:permission_handler/permission_handler.dart';

class ExcelHelper {
  //  إنشاء ملف Excel
  Future<void> createExcel(String fileName) async {
    // طلب الأذونات
    if (await Permission.storage.request().isGranted ||
        await Permission.manageExternalStorage.request().isGranted) {
      var excel = Excel.createExcel();
      Sheet sheet = excel['Sheet1'];

      // إعداد العناوين
      List<String> headers = ["اسم المنتج", "السعر", "الكمية", "الفئة"];
      for (int i = 0; i < headers.length; i++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
            .value = TextCellValue(
          headers[i],
        );
      }

      // بيانات تجريبية
      List<Map<String, dynamic>> products = [
        {
          'name': 'هاتف',
          'price': 1500,
          'quantity': 10,
          'category': 'إلكترونيات',
        },
        {'name': 'قبعة', 'price': 50, 'quantity': 25, 'category': 'ملابس'},
        {'name': 'طاولة', 'price': 1200, 'quantity': 5, 'category': 'أثاث'},
        {
          'name': 'لابتوب',
          'price': 3000,
          'quantity': 8,
          'category': 'إلكترونيات',
        },
      ];

      // تعبئة البيانات
      for (int i = 0; i < products.length; i++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1))
            .value = TextCellValue(
          products[i]['name'],
        );
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1))
            .value = TextCellValue(
          products[i]['price'].toString(),
        );
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1))
            .value = TextCellValue(
          products[i]['quantity'].toString(),
        );
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1))
            .value = TextCellValue(
          products[i]['category'],
        );
      }

      // الحفظ في مجلد التنزيلات
      final String path = "/storage/emulated/0/Download/excel/$fileName.xlsx";
      File file = File(path);

      var bytes = excel.encode();
      if (bytes != null) {
        await file.writeAsBytes(bytes, flush: true);
        print("تم الحفظ في: $path");
      }
    } else {
      print("لا يوجد إذن تخزين");
    }
  }

  Future<void> createExceldir() async {
    final directory = Directory("/storage/emulated/0/Download/excel");
    if (!await directory.exists()) {
      await directory.create(recursive: true);
      print("تم إنشاء المجلد: ${directory.path}");
    }
  }

  //  قراءة الملف  وتحويله لقائمة
  Future<List<Map<String, dynamic>>> readExcel(String filePath) async {
    try {
      var bytes = File(filePath).readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      List<Map<String, dynamic>> data = [];

      for (var table in excel.tables.keys) {
        var sheet = excel.tables[table]!;
        if (sheet.maxRows == 0) continue;

        // قراءة العناوين (الصف الأول)
        List<String> headers = [];
        for (int col = 0; col < sheet.maxColumns; col++) {
          var cellValue = sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0))
              .value;
          headers.add(cellValue?.toString() ?? "col_$col");
        }

        // قراءة الصفوف
        for (int row = 1; row < sheet.maxRows; row++) {
          Map<String, dynamic> rowData = {};
          bool isEmptyRow = true;

          for (int col = 0; col < sheet.maxColumns; col++) {
            var cellValue = sheet
                .cell(
                  CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row),
                )
                .value;
            String value = cellValue?.toString() ?? ""; // تحويل القيمة لنص

            // تنظيف القيمة من أنواع البيانات الخاصة بالمكتبة إن وجدت
            if (cellValue is TextCellValue) value = cellValue.value.toString();
            if (cellValue is IntCellValue) value = cellValue.value.toString();
            if (cellValue is DoubleCellValue)
              value = cellValue.value.toString();

            if (value.isNotEmpty) isEmptyRow = false;

            if (col < headers.length) {
              // إزالة المسافات الزائدة من مفتاح العنوان لضمان التطابق
              rowData[headers[col].trim()] = value;
            }
          }

          if (!isEmptyRow) {
            data.add(rowData);
          }
        }
      }
      return data;
    } catch (e) {
      print("Error reading excel: $e");
      rethrow;
    }
  }

  //  البحث عن الملفات
  Future<List<String>> findExcelFiles() async {
    final directory = Directory("/storage/emulated/0/Download/excel");
    if (await directory.exists()) {
      var files = directory.listSync();
      return files
          .where((file) => file.path.toLowerCase().endsWith('.xlsx'))
          .map((file) => file.path)
          .toList();
    }
    return [];
  }
}
