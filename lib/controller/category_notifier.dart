import 'package:flutter/material.dart';

CategoryNotifier categoryNotifier = CategoryNotifier();

class CategoryNotifier extends ChangeNotifier {
  String _selectedCategoryInEng = 'none';

  String get selectedCategoryInEng => _selectedCategoryInEng;
  String get SelectedCategoryInKor => categoriesMapEngToKor[_selectedCategoryInEng]!;

  void setNewCategoryWithEng(String newCategory) {
    if (categoriesMapEngToKor.keys.contains(newCategory)) {
      _selectedCategoryInEng = newCategory;
      notifyListeners();
    }
  }

  void setNewCategoryWithKor(String newCategory) {
    if (categoriesMapEngToKor.values.contains(newCategory)) {
      _selectedCategoryInEng = categoriesMapKorToEng[newCategory]!;
      notifyListeners();
    }
  }
}

const Map<String, String> categoriesMapEngToKor = {
  'none': '카테고리',
  'number': '숫자',
  'puzzle': '퍼즐',
  'common_sense': '상식',
  'non_sense': '넌센스',
  'detective': '추리',
};

const Map<String, String> categoriesMapKorToEng = {
  '카테고리': 'none',
  '숫자': 'number',
  '퍼즐': 'puzzle',
  '상식': 'common_sense',
  '넌센스': 'non_sense',
  '추리': 'detective',
};


// Map<String, String> categoriesMapKorToEng =
//     categoriesMapEngToKor.map((key, value) => MapEntry(value, key));
