import 'package:flutter/material.dart';
import 'package:quiz_first/model/item_model.dart';
import 'package:quiz_first/util/logger.dart';

class OptionBox extends StatefulWidget {
  final ItemModel itemModel;
  final int optionsIndex;
  final Widget sizedBoxH;
  final getSelectedOptionsSet;
  final List<String> selectedOptions;
  final itemIndex;
  final List<List<String>> selectedOptionsSet;

  OptionBox({
    Key? key,
    required this.itemModel,
    required this.sizedBoxH,
    required this.optionsIndex,
    this.getSelectedOptionsSet,
    required this.selectedOptions,
    this.itemIndex,
    required this.selectedOptionsSet,
  }) : super(key: key);

  @override
  State<OptionBox> createState() => _OptionBoxState();
}

class _OptionBoxState extends State<OptionBox> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            InkWell(
              onTap: () {
                // 중복 선택 허용 코드
                // if (widget.selectedOptionsSet[widget.itemIndex]
                //     .contains((widget.optionsIndex + 1).toString())) {
                //   widget.selectedOptionsSet[widget.itemIndex]
                //       .remove((widget.optionsIndex + 1).toString());
                //   widget.selectedOptionsSet[widget.itemIndex].sort();
                // } else {
                //   widget.selectedOptionsSet[widget.itemIndex]
                //       .add((widget.optionsIndex + 1).toString());
                //   widget.selectedOptionsSet[widget.itemIndex].sort();
                // }

                if (!widget.selectedOptionsSet[widget.itemIndex]
                    .contains((widget.optionsIndex + 1).toString())) {
                  widget.selectedOptionsSet[widget.itemIndex].clear();
                  widget.selectedOptionsSet[widget.itemIndex]
                      .add((widget.optionsIndex + 1).toString());
                  widget.selectedOptionsSet[widget.itemIndex].sort();
                }

                widget.getSelectedOptionsSet(widget.selectedOptionsSet);
                setState(() {});
                print(
                    'widget.selectedOptionsSet: ${widget.selectedOptionsSet}');
              },
              child: Container(
                alignment: Alignment.centerLeft,
                // padding: EdgeInsets.all(10),
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: widget.selectedOptionsSet[widget.itemIndex]
                          .contains((widget.optionsIndex + 1).toString())
                      ? Colors.amber
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  shape: BoxShape.rectangle,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 50),
                  child: Text(
                    '${widget.itemModel.options[widget.optionsIndex]}',
                    style: TextStyle(
                      color: Colors.black87,
                      fontFamily: 'SDneoR',
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 13,
              left: 13,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(12),
                  shape: BoxShape.rectangle,
                ),
                child: Center(
                  child: Text(
                    '${widget.optionsIndex + 1}',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'SDneoEB',
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        widget.sizedBoxH,
      ],
    );
  }
}
