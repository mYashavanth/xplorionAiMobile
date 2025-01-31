import 'package:flutter/cupertino.dart';

class CIDateProvider extends ChangeNotifier {
  List<DateTime?> rangeDatePickerValueWithDefaultValue = [
    DateTime.now(),
    DateTime.now().add(const Duration(days: 7)),
  ];

  void changeDate(dates) {
    rangeDatePickerValueWithDefaultValue = dates;
    notifyListeners();
  }

  void resetDate() {
    rangeDatePickerValueWithDefaultValue = [
      DateTime.now(),
      DateTime.now(),
    ];

    notifyListeners();
  }
}
