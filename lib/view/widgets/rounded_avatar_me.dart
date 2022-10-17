import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_first/constants/common_size.dart';
import 'package:quiz_first/controller/select_image_notifier.dart';
import 'package:quiz_first/controller/user_model_state.dart';
import 'package:quiz_first/model/user_model.dart';
import 'package:image_picker/image_picker.dart';

class RoundedAvatarMe extends StatelessWidget {
  // final UserModel userModel;
  final double avatarSize;
  // final XFile image;

  const RoundedAvatarMe({
    Key? key,
    this.avatarSize = avatar_size,
    // required this.userModel,
    // required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModelState>(
      builder:
          (BuildContext context, UserModelState userModelState, Widget? child) {
        return ClipOval(
          // child: CachedNetworkImage(
          //   imageUrl: 'https://picsum.photos/100',
          //   width: avatarSize,
          //   height: avatarSize,
          // ),
          // child: ExtendedImage.network(
          //     'https://firebasestorage.googleapis.com/v0/b/quizfirst-d98f7.appspot.com/o/images%2FvD3muzjYSmUyvkZzpzuFNBCy67t2_1661778458874865%2F0.jpg?alt=media&token=816f0d7b-7a3c-4cf9-8f40-d46aa068e541'),
          child: (userModelState.userModel != null &&
                  userModelState.userModel!.imageDownloadUrls.isNotEmpty)
              ? ExtendedImage.network(
                  userModelState.userModel!.imageDownloadUrls[0],
                  width: avatarSize,
                  height: avatarSize,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: avatarSize,
                  child: Stack(
                    children: [
                      Container(
                        width: avatarSize,
                        height: avatarSize,
                        color: Colors.grey[200],
                      ),
                      Positioned(
                        left: (avatarSize - (avatarSize / 3 * 2)) / 2,
                        top: (avatarSize - (avatarSize / 3 * 2)) / 2,
                        child: Icon(
                          CupertinoIcons.person_fill,
                          size: avatarSize / 3 * 2,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
