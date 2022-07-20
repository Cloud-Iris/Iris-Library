import 'package:flutter/material.dart';
import 'package:flutter_wechat_read/base_card.dart';

/// 分享得到联名卡

class CardShare extends BaseCard{
  @override
  State<BaseCard> createState() => _CardShareState();
}

class _CardShareState extends BaseCardState{
  @override
  Widget topTitle(String title) {
    return super.topTitle('分享得联名卡');
  }
  @override
  Widget subTitle(String title) {
    return super.subTitle('分享给朋友最多可得12天无限卡');
  }
  @override
  Widget topTitle2(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 5),
      child: Text(" / 第19期", style: TextStyle(fontSize: 10),),
    );
  }

  @override
  bottomContent() {
    /// 撑满高度
    return Expanded(child: Container(
      /// 通过 BoxConstraints 尽可能撑满父容器，是为了不同机型的适配
      constraints: BoxConstraints.expand(),
      margin: EdgeInsets.only(top: 20),
      decoration: BoxDecoration(color: Color(0xfff6f7f9)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          /// 除了底部文字，希望让图片占据所有的大小，所以再来一个 Expanded
          Expanded(child: Padding(
            padding: EdgeInsets.fromLTRB(15, 20, 0, 20),
            child: Image.network("http://www.devio.org/io/flutter_beauty/card_list.png"),
          )),
          Container(
            /// 重写父布局的位置约束，位于父布局中间，
            /// 避免因为 Cross的影响导致文字也居于右边
            alignment: AlignmentDirectional.center,
            child: Padding(padding: EdgeInsets.only(bottom: 20),
              child: bottomTitle("29997867人 参与活动"),
            ),
          )
        ],
      ),
    ));
  }
}
