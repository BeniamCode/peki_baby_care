import 'package:flutter/foundation.dart';
import '../../../data/models/baby_model.dart';

class SelectedBabyProvider extends ChangeNotifier {
  BabyModel? _selectedBaby;
  
  BabyModel? get selectedBaby => _selectedBaby;
  String? get selectedBabyId => _selectedBaby?.id;
  
  void setSelectedBaby(BabyModel? baby) {
    _selectedBaby = baby;
    notifyListeners();
  }
  
  void clearSelectedBaby() {
    _selectedBaby = null;
    notifyListeners();
  }
}