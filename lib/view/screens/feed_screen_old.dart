import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:get/get.dart';
import 'package:quiz_first/constants/common_size.dart';
import 'package:quiz_first/view/screens/feed/quiz_detail_screen.dart';
import 'package:quiz_first/view/widgets/rounded_avatar.dart';

class FeedScreenOld extends StatelessWidget {
  FeedScreenOld({Key? key}) : super(key: key);

  final sizedBoxH = SizedBox(
    height: 12,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              flexibleSpace: FlexibleSpaceBar(
                background: Row(
                  children: [
                    Expanded(
                      child: Container(),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        CupertinoIcons.plus_app,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        CupertinoIcons.ellipsis_circle,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        CupertinoIcons.bell,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                  ],
                ),
              ),
              expandedHeight: 90,
              backgroundColor: Colors.white,
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  _question1(),
                  _question2(),
                  _question3(),
                  _question4(),
                  _question5(),
                  Container(
                    child: ExtendedImage.asset('assets/imgs/monimo.jpeg'),
                  ),
                  Container(
                    child: ExtendedImage.asset('assets/imgs/monimo2.jpeg'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _question5() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          common_l_gap, 0, common_l_gap, common_l_gap),
      child: Card(
        elevation: 20,
        shadowColor: Colors.black87,
        // color: Color(0xFF56637a),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            shape: BoxShape.rectangle,
          ),
          // height: 300,
          // color: Color(0xFF56637a),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(common_xxl_gap,
                    common_xxl_gap, common_xxl_gap, common_xs_gap),
                child: Text(
                  '??????',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 14,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: common_xxl_gap),
                child: Text(
                  '??????????????? ????????? ????????? ???????????? ????????? ????????????????',
                  style: TextStyle(
                    fontFamily: 'SDneoSB',
                    color: Colors.black87,
                    fontSize: 19,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(common_xxl_gap,
                    common_xl_gap, common_xxl_gap, common_xxl_gap + 4),
                child: Container(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            // padding: EdgeInsets.all(10),
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(25),
                              shape: BoxShape.rectangle,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 50),
                              child: Text(
                                '???????????????',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontFamily: 'SDneoR',
                                  fontSize: 17,
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
                                  '1',
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
                      sizedBoxH,
                      Stack(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            // padding: EdgeInsets.all(10),
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(25),
                              shape: BoxShape.rectangle,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 50),
                              child: Text(
                                '?????????',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontFamily: 'SDneoR',
                                  fontSize: 17,
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
                                  '2',
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
                      sizedBoxH,
                      Stack(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            // padding: EdgeInsets.all(10),
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(25),
                              shape: BoxShape.rectangle,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 50),
                              child: Text(
                                '??????',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontFamily: 'SDneoR',
                                  fontSize: 17,
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
                                  '3',
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
                      sizedBoxH,
                      Stack(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            // padding: EdgeInsets.all(10),
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(25),
                              shape: BoxShape.rectangle,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 50),
                              child: Text(
                                '????????????',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontFamily: 'SDneoR',
                                  fontSize: 17,
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
                                  '4',
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
                      // SizedBox(
                      //   height: 16,
                      // ),
                    ],
                  ),
                ),
              ),
              Divider(
                height: 1,
                color: Colors.grey[400],
                // indent: common_padding,
                // endIndent: common_padding,
              ),
              Container(
                height: 44,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '?????? ?????? ??? ??????',
                      style: TextStyle(color: Colors.black54),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Icon(CupertinoIcons.arrow_right_circle_fill,
                        color: Colors.black54),
                    SizedBox(
                      width: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _question4() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          common_l_gap, 0, common_l_gap, common_l_gap),
      child: Card(
        elevation: 20,
        shadowColor: Colors.black87,
        // color: Color(0xFF56637a),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            shape: BoxShape.rectangle,
          ),
          // height: 300,
          // color: Color(0xFF56637a),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(common_xxl_gap,
                    common_xxl_gap, common_xxl_gap, common_xs_gap),
                child: Text(
                  '??????',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 14,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: common_xxl_gap),
                child: Text(
                  '??????????????? ????????? ????????? ???????????? ????????? ????????????????',
                  style: TextStyle(
                    fontFamily: 'SDneoSB',
                    color: Colors.black87,
                    fontSize: 19,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(common_xxl_gap,
                    common_xl_gap, common_xxl_gap, common_xxl_gap + 4),
                child: Container(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            // padding: EdgeInsets.all(10),
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(10),
                              shape: BoxShape.rectangle,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 50),
                              child: Text(
                                '???????????????',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontFamily: 'SDneoR',
                                  fontSize: 17,
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
                                borderRadius: BorderRadius.circular(10),
                                shape: BoxShape.rectangle,
                              ),
                              child: Center(
                                child: Text(
                                  '1',
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
                      sizedBoxH,
                      Stack(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            // padding: EdgeInsets.all(10),
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(10),
                              shape: BoxShape.rectangle,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 50),
                              child: Text(
                                '?????????',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontFamily: 'SDneoR',
                                  fontSize: 17,
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
                                borderRadius: BorderRadius.circular(10),
                                shape: BoxShape.rectangle,
                              ),
                              child: Center(
                                child: Text(
                                  '2',
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
                      sizedBoxH,
                      Stack(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            // padding: EdgeInsets.all(10),
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(10),
                              shape: BoxShape.rectangle,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 50),
                              child: Text(
                                '??????',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontFamily: 'SDneoR',
                                  fontSize: 17,
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
                                borderRadius: BorderRadius.circular(10),
                                shape: BoxShape.rectangle,
                              ),
                              child: Center(
                                child: Text(
                                  '3',
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
                      sizedBoxH,
                      Stack(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            // padding: EdgeInsets.all(10),
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(10),
                              shape: BoxShape.rectangle,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 50),
                              child: Text(
                                '????????????',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontFamily: 'SDneoR',
                                  fontSize: 17,
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
                                borderRadius: BorderRadius.circular(10),
                                shape: BoxShape.rectangle,
                              ),
                              child: Center(
                                child: Text(
                                  '4',
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
                      // SizedBox(
                      //   height: 16,
                      // ),
                    ],
                  ),
                ),
              ),
              Divider(
                height: 1,
                color: Colors.grey[400],
                // indent: common_padding,
                // endIndent: common_padding,
              ),
              Container(
                height: 44,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '?????? ?????? ??? ??????',
                      style: TextStyle(color: Colors.black54),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Icon(CupertinoIcons.arrow_right_circle_fill,
                        color: Colors.black54),
                    SizedBox(
                      width: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _question3() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          common_l_gap, 0, common_l_gap, common_l_gap),
      child: Card(
        elevation: 20,
        shadowColor: Colors.black87,
        // color: Color(0xFF56637a),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            shape: BoxShape.rectangle,
          ),
          // height: 300,
          // color: Color(0xFF56637a),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(common_xxl_gap,
                    common_xxl_gap, common_xxl_gap, common_xs_gap),
                child: Text(
                  '??????',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 14,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: common_xxl_gap),
                child: Text(
                  '??????????????? ????????? ????????? ???????????? ????????? ????????????????',
                  style: TextStyle(
                    fontFamily: 'SDneoSB',
                    color: Colors.black87,
                    fontSize: 19,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(common_xxl_gap,
                    common_xl_gap, common_xxl_gap, common_xxl_gap + 4),
                child: Container(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(10),
                              shape: BoxShape.rectangle,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 50),
                              child: Text(
                                '???????????????',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontFamily: 'SDneoR',
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  bottomLeft: Radius.circular(10)),
                              shape: BoxShape.rectangle,
                            ),
                            child: Center(
                              child: Text(
                                '1',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'SDneoEB',
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Stack(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(10),
                              shape: BoxShape.rectangle,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 50),
                              child: Text(
                                '?????????',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontFamily: 'SDneoR',
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  bottomLeft: Radius.circular(10)),
                              shape: BoxShape.rectangle,
                            ),
                            child: Center(
                              child: Text(
                                '2',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'SDneoEB',
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Stack(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(10),
                              shape: BoxShape.rectangle,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 50),
                              child: Text(
                                '??????',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontFamily: 'SDneoR',
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  bottomLeft: Radius.circular(10)),
                              shape: BoxShape.rectangle,
                            ),
                            child: Center(
                              child: Text(
                                '3',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'SDneoEB',
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Stack(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(10),
                              shape: BoxShape.rectangle,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 50),
                              child: Text(
                                '????????????',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontFamily: 'SDneoR',
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  bottomLeft: Radius.circular(10)),
                              shape: BoxShape.rectangle,
                            ),
                            child: Center(
                              child: Text(
                                '4',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'SDneoEB',
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // SizedBox(
                      //   height: 10,
                      // ),
                    ],
                  ),
                ),
              ),
              Divider(
                height: 1,
                color: Colors.grey[400],
                // indent: common_padding,
                // endIndent: common_padding,
              ),
              Container(
                height: 44,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '?????? ?????? ??? ??????',
                      style: TextStyle(color: Colors.black54),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Icon(CupertinoIcons.arrow_right_circle_fill,
                        color: Colors.black54),
                    SizedBox(
                      width: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _question2() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          common_l_gap, 0, common_l_gap, common_l_gap),
      child: Card(
        elevation: 20,
        shadowColor: Colors.black87,
        // color: Color(0xFF56637a),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            shape: BoxShape.rectangle,
          ),
          // height: 400,
          // color: Color(0xFF56637a),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Container(
              //   height: 180,
              //   width: double.infinity,
              //   decoration: BoxDecoration(
              //     shape: BoxShape.rectangle,
              //     borderRadius: BorderRadius.only(
              //       topLeft: Radius.circular(20),
              //       topRight: Radius.circular(20),
              //     ),
              //     color: Colors.amber,
              //   ),
              //   child: ExtendedImage.asset(
              //     'assets/imgs/match01.jpg',
              //     fit: BoxFit.cover,
              //     shape: BoxShape.rectangle,
              //     borderRadius: BorderRadius.only(
              //       topLeft: Radius.circular(20),
              //       topRight: Radius.circular(20),
              //     ),
              //   ),
              // ),
              Container(
                height: 4,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    common_l_gap, common_l_gap, common_l_gap, common_xs_gap),
                child: Text(
                  '????????? ??? ??? ?????? ?????? ??????',
                  style: TextStyle(
                    fontFamily: 'SDneoB',
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: common_l_gap),
                child: Container(
                  height: 100,
                  child: Text(
                    '????????? ???????????? ???????????? ????????????. ????????? ?????? ?????? ????????????, ????????? ????????? ?????? ????????? ?????? ???????????? ???????????? ???????????? ????????? ??????????! ?????? HTML ?????? 3?????? ',
                    style: TextStyle(
                      fontFamily: 'SDneoR',
                      color: Colors.black87,
                      fontSize: 15,
                      height: 1.5,
                      letterSpacing: -0.5,
                      wordSpacing: 3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: common_l_gap),
                child: Row(
                  children: [
                    Text(
                      '2022??? 8??? 20???',
                      style: TextStyle(
                        fontFamily: 'SDneoR',
                        color: Colors.black38,
                        fontSize: 13,
                        height: 1.5,
                        letterSpacing: -0.5,
                        wordSpacing: 3,
                      ),
                    ),
                    Text(
                      '???0?????? ??????',
                      style: TextStyle(
                        fontFamily: 'SDneoR',
                        color: Colors.black38,
                        fontSize: 13,
                        height: 1.5,
                        letterSpacing: -0.5,
                        wordSpacing: 3,
                      ),
                    ),
                  ],
                ),
              ),
              sizedBoxH,
              Divider(
                height: 1,
                color: Colors.grey[400],
                // indent: common_padding,
                // endIndent: common_padding,
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20)),
                  shape: BoxShape.rectangle,
                ),
                height: 54,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: common_l_gap),
                  child: Row(
                    // ?????? ????????? ?????? ??????
                    children: [
                      // RoundedAvatar(
                      //   avatarSize: 28,
                      // ),
                      SizedBox(
                        width: 6,
                      ),
                      Expanded(
                        child: Text(
                          '?????????',
                          style: TextStyle(fontFamily: 'SDneoSB', fontSize: 15),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        padding: const EdgeInsets.all(8),
                        constraints: BoxConstraints(),
                        iconSize: 22,
                        icon: Icon(
                          CupertinoIcons.suit_heart,
                        ),
                      ),
                      Text(
                        '5',
                        style: TextStyle(fontFamily: 'SDneoB'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _question1() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          common_l_gap, 0, common_l_gap, common_l_gap),
      child: Card(
        elevation: 20,
        shadowColor: Colors.black87,
        // color: Color(0xFF56637a),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            Container(
              child: Opacity(
                opacity: 1,
                child: ExtendedImage.asset(
                  'assets/imgs/match01.jpg',
                  fit: BoxFit.fitHeight,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                shape: BoxShape.rectangle,
              ),
            ),
            //????????? ??????????????? ?????? ??????
            Container(
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                shape: BoxShape.rectangle,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black87,
                    Colors.black54,
                    Colors.black26,
                    Colors.black12,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            //????????? ??????????????? ?????? ???
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                shape: BoxShape.rectangle,

                // image: DecorationImage(
                //   fit: BoxFit.cover,
                //   image: AssetImage('assets/imgs/testBG.png'),
                // ),
              ),
              // height: 300,
              // color: Color(0xFF56637a),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(common_xxl_gap,
                        common_xxl_gap, common_xxl_gap, common_xs_gap),
                    child: Text(
                      '?????????',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: common_xxl_gap),
                    child: Text(
                      '?????? ????????? ?????? ????????????? ?????? ?????? ?????? ???????????????. ?????? ????????? ?????????..',
                      style: TextStyle(
                        fontFamily: 'SDneoSB',
                        color: Colors.white,
                        fontSize: 19,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
