import 'package:flutter/material.dart';
import 'package:flutter_wechat_read/base_card.dart';

class CardSpecial extends BaseCard{
  @override
  State<BaseCard> createState() => _CardSpecialState();
}

class _CardSpecialState extends BaseCardState{
  @override
  void initState() {
    bottomTitleColor = Colors.blue;
    super.initState();
  }
  
  @override
  topContent() {
    return Column(
      children: [
        Container(
          /// 图书的外层背景
          padding: EdgeInsets.fromLTRB(66, 36, 66, 30),
          decoration: BoxDecoration(color: Color(0xFFFFFCF7),),
          child: Container(
            /// 图书的内层容器，创造图书的阴影
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 20,   /// 模糊半径
                  offset: Offset(0, 10),  /// 分别是水平偏移距离和垂直偏移距离
                ),
              ],
            ),
            child: Image.network("http://www.devio.org/io/flutter_beauty/changan_book.jpg"),
          ),
        ),
        /// 腰封
        Container(
          padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          decoration: BoxDecoration(color: Color(0xFFF7F3EA)),
          child: Row(children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '长安十二时辰',
                  style: TextStyle(fontSize: 18, color: Color(0xFF473B25),),
                ),
                Padding(padding: EdgeInsets.only(top: 5),
                  child: Text(
                    '马伯庸',
                    style: TextStyle(fontSize: 13, color: Color(0xFF7d725c),),
                  ),
                ),
            ],),
            /// 渐变按钮
            Container(
              margin: EdgeInsets.only(left: 20),
              padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(colors: [
                  Color(0xffd9bc82),
                  Color(0xffecd9ae),
                ]),
              ),
              child: Text(
                '分享免费领取',
                style: TextStyle(color: Color(0xff4f3b1a), fontSize: 13,),
              ),
            )
          ],),
        ),
      ],
    );
  }

  @override
  bottomContent() {
    return Expanded(
      child: Column(
        /// 水平方向：让 Column 组件的子组件 撑开到 Column 组件的宽度
        crossAxisAlignment: CrossAxisAlignment.stretch,
        /// 垂直方向：让 Column 组件的子组件 在 Column 组件的高度里均匀分布
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Padding(padding: EdgeInsets.only(left: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  "http://www.devio.org/io/flutter_beauty/double_quotes.jpg",
                  height: 26,
                  width: 26,
                ),
                Text('揭露历史真相'),
            ],),
          ),
          
          bottomTitle("更多免费好物"),
        ],
      ),
    );
  }

  @override
  Widget bottomTitle(String title) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: bottomTitleColor,
        fontSize: 12,
      ),
    );
  }
}