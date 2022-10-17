import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:quiz_first/constants/common_size.dart';
import 'package:quiz_first/controller/edit_profile_controller.dart';
import 'package:quiz_first/controller/select_image_notifier.dart';
import 'package:quiz_first/controller/user_model_state.dart';
import 'package:quiz_first/model/user_model.dart';
import 'package:image_picker/image_picker.dart';

class RoundedAvatarEdit extends StatefulWidget {
  final double avatarSize;

  const RoundedAvatarEdit({
    Key? key,
    this.avatarSize = avatar_size,
  }) : super(key: key);

  @override
  State<RoundedAvatarEdit> createState() => _RoundedAvatarEditState();
}

class _RoundedAvatarEditState extends State<RoundedAvatarEdit> {
  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: context.watch<SelectImageNotifier>().profileImages.isNotEmpty
          ? ExtendedImage.memory(
              context.watch<SelectImageNotifier>().profileImages[0],
              width: widget.avatarSize,
              height: widget.avatarSize,
              fit: BoxFit.cover,
            )
          : (Get.find<EditProfileController>().tempUrls.isNotEmpty)
              ? ExtendedImage.network(
                  Get.find<EditProfileController>().tempUrls[0],
                  width: widget.avatarSize,
                  height: widget.avatarSize,
                  fit: BoxFit.cover,
                )
              : Stack(
                  children: [
                    Container(
                      width: widget.avatarSize,
                      height: widget.avatarSize,
                      color: Colors.grey[200],
                    ),
                    Positioned(
                      left:
                          (widget.avatarSize - (widget.avatarSize / 3 * 2)) / 2,
                      top:
                          (widget.avatarSize - (widget.avatarSize / 3 * 2)) / 2,
                      child: Icon(
                        CupertinoIcons.person_fill,
                        size: widget.avatarSize / 3 * 2,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
    );
  }
}
