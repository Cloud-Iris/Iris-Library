import 'package:flutter/material.dart';

import './base_card.dart';
/// 本周推荐卡片

class CardRecommend extends BaseCard{

  @override
  State<BaseCard> createState() => _CardRecommendState();
}

class _CardRecommendState extends BaseCardState {
  @override
  void initState() {
    subTitleColor = Color(0xFFB99444);
    super.initState();
  }
  @override
  Widget topTitle(String title) {
    return super.topTitle('本周推荐');
  }
  @override
  Widget subTitle(String title) {
    return super.subTitle("送你一天无限卡，全场书籍免费读");
  }
  @override
  bottomContent() {
    /// 撑满高度
    return Expanded(child: Container(
      margin: EdgeInsets.only(top: 20),
      // constraints: BoxConstraints(
      //   maxWidth: double.infinity,
      //   maxHeight: 600,
      // ),
      child: Image.network(
        "http://www.devio.org/io/flutter_beauty/card_1.jpg",
        fit: BoxFit.cover,
      ),
    ));
  }
}