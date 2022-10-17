import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SelectImageNotifier extends ChangeNotifier {
  List<Uint8List> _images = [];
  List<Uint8List> _profileImages = [];

  Future? setNewImage(List<XFile>? newImages) async {
    _images.clear();
    for (int i = 0; i < newImages!.length; i++) {
      _images.add(await newImages[i].readAsBytes());
    }
    notifyListeners();
  }

  Future? setNewProfielImage(XFile? newImage) async {
    _profileImages.clear();
    _profileImages.add(await newImage!.readAsBytes());
    notifyListeners();
  }

  void removeImage(int index) {
    if (_images.length >= index) {
      _images.removeAt(index);
      notifyListeners();
    }
  }

  void removeProfileImage() {
    _profileImages.clear();
    notifyListeners();
  }

  List<Uint8List> get images => _images;
  List<Uint8List> get profileImages => _profileImages;
}
