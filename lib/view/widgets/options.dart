import 'package:flutter/material.dart';
import 'package:quiz_first/model/item_model.dart';
import 'package:quiz_first/view/widgets/option_box.dart';

class Options extends StatefulWidget {
  final Widget sizedBoxH;
  final ItemModel itemModel;
  final getSelectedOptionsSet;
  final itemIndex;
  final List<List<String>> selectedOptionsSet;
  Options({
    Key? key,
    required this.itemModel,
    required this.sizedBoxH,
    this.getSelectedOptionsSet,
    this.itemIndex,
    required this.selectedOptionsSet,
  }) : super(key: key);

  @override
  State<Options> createState() => _OptionsState();
}

// --------------------------
// OptionBox위젯을 별도로 분리하면 중복을 허용하지 않는 기능이 구현되질 않아서 다시 합침
// 아래의 코드는 OptionBox위젯이 분리되었을때의 코드
// --------------------------
// class _OptionsState extends State<Options> {
//   List<String> _selectedOptions = [];

//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: NeverScrollableScrollPhysics(),
//       itemCount: widget.itemModel.options.length,
//       itemBuilder: (context, index) {
//         if (widget.itemModel.options[index] != '') {
//           return OptionBox(
//               itemModel: widget.itemModel,
//               sizedBoxH: widget.sizedBoxH,
//               optionsIndex: index,
//               getSelectedOptionsSet: widget.getSelectedOptionsSet,
//               selectedOptions: _selectedOptions,
//               itemIndex: widget.itemIndex,
//               selectedOptionsSet: widget.selectedOptionsSet);
//         } else {
//           return Container();
//         }
//       },
//     );
//   }
// }

class _OptionsState extends State<Options> {
  List<String> _selectedOptions = [];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: widget.itemModel.options.length,
      itemBuilder: (context, index) {
        if (widget.itemModel.options[index] != '') {
          return Column(
            children: [
              Stack(
                children: [
                  InkWell(
                    onTap: () {
                      // option 중복 선택 허용 코드
                      // if (widget.selectedOptionsSet[widget.itemIndex]
                      //     .contains((index + 1).toString())) {
                      //   widget.selectedOptionsSet[widget.itemIndex]
                      //       .remove((index + 1).toString());
                      //   widget.selectedOptionsSet[widget.itemIndex].sort();
                      // } else {
                      //   widget.selectedOptionsSet[widget.itemIndex]
                      //       .add((index + 1).toString());
                      //   widget.selectedOptionsSet[widget.itemIndex].sort();
                      // }

                      // option 1개만 선택 가능 코드
                      if (!widget.selectedOptionsSet[widget.itemIndex].contains((index + 1).toString())) {
                        widget.selectedOptionsSet[widget.itemIndex].clear();
                        widget.selectedOptionsSet[widget.itemIndex].add((index + 1).toString());
                        widget.selectedOptionsSet[widget.itemIndex].sort();
                      }

                      widget.getSelectedOptionsSet(widget.selectedOptionsSet);
                      setState(() {});
                      print('widget.selectedOptionsSet: ${widget.selectedOptionsSet}');
                    },
                    child: Container(
                      alignment: Alignment.centerLeft,
                      // padding: EdgeInsets.all(10),
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: widget.selectedOptionsSet[widget.itemIndex].contains((index + 1).toString()) ? Colors.amber : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        shape: BoxShape.rectangle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 50),
                        child: Text(
                          '${widget.itemModel.options[index]}',
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
                          '${index + 1}',
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
        } else {
          return Container();
        }
      },
    );
  }
}
