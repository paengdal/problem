import 'package:flutter/material.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FloatingActionButton(
            onPressed: () => {},
            child: Icon(Icons.navigate_before_rounded),
            heroTag: "fab1",
          ),
          FloatingActionButton(
            onPressed: () => {},
            child: Icon(Icons.navigate_next_rounded),
            heroTag: "fab2",
          ),
        ],
      ),
    );
  }
}
