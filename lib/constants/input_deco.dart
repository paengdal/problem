import 'package:flutter/material.dart';

import 'common_size.dart';

InputDecoration textInputDeco(String hintText) {
  return InputDecoration(
    isDense: true,
    hintText: hintText,
    hintStyle: TextStyle(color: Colors.grey[400]),
    enabledBorder: enableBorder(),
    errorBorder: errorBorder(),
    focusedBorder: focusedBorder(),
    focusedErrorBorder: errorBorder(),
    focusColor: Color(0xff454137),
    fillColor: Colors.grey[50],
    filled: true,
    contentPadding: EdgeInsets.fromLTRB(14, 12, 14, 12),
  );
}

OutlineInputBorder focusedBorder() {
  return OutlineInputBorder(
    borderSide: BorderSide(
      color: Color(0xff454137),
      // color: Colors.blue,
    ),
    // borderRadius: BorderRadius.circular(common_s_gap),
  );
}

OutlineInputBorder errorBorder() {
  return OutlineInputBorder(
    borderSide: BorderSide(
      color: (Colors.redAccent),
    ),
    // borderRadius: BorderRadius.circular(common_s_gap),
  );
}

OutlineInputBorder enableBorder() {
  return OutlineInputBorder(
    borderSide: BorderSide(
      color: (Colors.grey[300]!),
    ),
    // borderRadius: BorderRadius.circular(common_s_gap),
  );
}

InputDecoration textInputDecoShortAnswer(String hintText) {
  return InputDecoration(
    isDense: true,
    hintText: hintText,
    hintStyle: TextStyle(color: Colors.grey[400]),
    enabledBorder: enableBordeShortAnswer(),
    errorBorder: errorBorderShortAnswer(),
    focusedBorder: focusedBorderShortAnswer(),
    focusedErrorBorder: errorBorderShortAnswer(),
    focusColor: Color(0xff454137),
    fillColor: Colors.grey[50],
    filled: true,
    contentPadding: EdgeInsets.fromLTRB(10, 12, 10, 12),
  );
}

OutlineInputBorder enableBordeShortAnswer() {
  return OutlineInputBorder(
    borderSide: BorderSide(
      color: (Colors.grey[400]!),
    ),
  );
}

OutlineInputBorder errorBorderShortAnswer() {
  return OutlineInputBorder(
    borderSide: BorderSide(
      color: (Colors.redAccent),
    ),
  );
}

OutlineInputBorder focusedBorderShortAnswer() {
  return OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.black,
      width: 2,
      // color: Colors.blue,
    ),
  );
}

InputDecoration textInputDecoSearch(String hintText) {
  return InputDecoration(
    isDense: true,
    hintText: hintText,
    hintStyle: TextStyle(color: Colors.grey[400]),
    enabledBorder: enableBordeSearch(),
    errorBorder: errorBorderSearch(),
    focusedBorder: focusedBorderSearch(),
    focusedErrorBorder: errorBorderSearch(),
    focusColor: Color(0xff454137),
    fillColor: Colors.grey[200],
    filled: true,
    contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
  );
}

OutlineInputBorder enableBordeSearch() {
  return OutlineInputBorder(
    borderSide: BorderSide(
      color: (Colors.transparent),
    ),
  );
}

OutlineInputBorder errorBorderSearch() {
  return OutlineInputBorder(
    borderSide: BorderSide(
      color: (Colors.redAccent),
    ),
  );
}

OutlineInputBorder focusedBorderSearch() {
  return OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.transparent,
      width: 2,
      // color: Colors.blue,
    ),
  );
}
