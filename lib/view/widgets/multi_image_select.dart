import 'dart:typed_data';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:quiz_first/constants/common_size.dart';
import 'package:quiz_first/controller/select_image_notifier.dart';

class MultiImageSelect extends StatefulWidget {
  MultiImageSelect({
    Key? key,
  }) : super(key: key);

  @override
  State<MultiImageSelect> createState() => _MultiImageSelectState();
}

class _MultiImageSelectState extends State<MultiImageSelect> {
  bool _isPickingImages = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        Size _size = MediaQuery.of(context).size;
        var imageSize = _size.width / 3 - (common_l_gap * 2);
        var imageRadius = 16.0;

        return SizedBox(
          height: _size.width / 3,
          width: _size.width,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Padding(
                padding: const EdgeInsets.all(common_l_gap),
                child: InkWell(
                  onTap: () async {
                    _isPickingImages = true;
                    setState(() {});
                    final ImagePicker _picker = ImagePicker();
                    final List<XFile>? images = await _picker.pickMultiImage(
                      imageQuality: 20,
                    );
                    if (images != null && images.isNotEmpty) {
                      if (images.length > 1) {
                        Get.dialog(
                          barrierDismissible: false,
                          AlertDialog(
                            content: Text('이미지는 1개만 첨부 가능합니다.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Get.back();
                                  setState(() {
                                    _isPickingImages = false;
                                  });
                                },
                                child: Text('확인'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        await context
                            .read<SelectImageNotifier>()
                            .setNewImage(images);
                      }
                    }
                    _isPickingImages = false;

                    setState(() {});
                  },
                  child: Container(
                    width: imageSize,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(imageRadius),
                      border: Border.all(color: Colors.grey[400]!, width: 1),
                    ),
                    child: _isPickingImages
                        ? Padding(
                            padding: EdgeInsets.all(imageSize / 3),
                            child: CircularProgressIndicator(),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.camera_fill,
                                color: Colors.grey,
                              ),
                              Text(
                                '1개만 가능',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              ...List.generate(
                context.watch<SelectImageNotifier>().images.length,
                (index) => Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          0, common_l_gap, common_l_gap, common_l_gap),
                      child: ExtendedImage.memory(
                        context.watch<SelectImageNotifier>().images[index],
                        fit: BoxFit.cover,
                        loadStateChanged: (state) {
                          switch (state.extendedImageLoadState) {
                            case LoadState.loading:
                              return Container(
                                  padding: EdgeInsets.all(imageSize / 3),
                                  width: imageSize,
                                  height: imageSize,
                                  child: CircularProgressIndicator(
                                    color: Colors.red,
                                  ));
                            case LoadState.completed:
                              return null;
                            case LoadState.failed:
                              return Icon(Icons.cancel);
                          }
                        },
                        width: imageSize,
                        height: imageSize,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(imageRadius),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      width: 40,
                      height: 40,
                      child: IconButton(
                        padding: EdgeInsets.all(8),
                        onPressed: () {
                          context
                              .read<SelectImageNotifier>()
                              .removeImage(index);
                        },
                        icon: Icon(
                          CupertinoIcons.xmark_circle_fill,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
