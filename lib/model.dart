import 'package:flutter/material.dart';

class Model extends ChangeNotifier {
  bool? _isDriverRole;

  bool? get isDriverRole => _isDriverRole;

  void setFinalRole(bool value) {
    _isDriverRole = value;
    notifyListeners();
  }

  void clearRole() {
    _isDriverRole = null;
    notifyListeners();
  }
}

// import 'package:flutter/material.dart';

// class Model extends ChangeNotifier {
//   bool? _isDriverRole;

//   bool? get isDriverRole => _isDriverRole;

//   void setFinalRole(bool value) {
//     _isDriverRole = value;
//     notifyListeners();
//   }

//   void clearRole() {
//     _isDriverRole = null;
//     notifyListeners();
//   }
// }


// import 'package:flutter/material.dart';

// // 🟩 كلاس المستودع المركزي لحفظ حالات المنظومة اللوجستية
// class Model extends ChangeNotifier {
  
//   // 1. البيانات المركزية المحفوظة في المستودع (سائق = true / شركة = false)
//   bool isDriverRole = true; 

//   // 2. دالة قنص وتخزين الدور النهائي القادم من شاشة الدخول
//   void setFinalRole(bool value) {
//     isDriverRole = value;
//     notifyListeners(); // 📢 إعلام بقية الشاشات المستقبلية بالدور الجديد!
//   }
// }
