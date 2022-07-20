import 'package:flutter/material.dart';
/// 卡片基类
class BaseCard extends StatefulWidget {
  const BaseCard({Key? key}) : super(key: key);

  @override
  State<BaseCard> createState() => BaseCardState();
}
/// 由于是基础类，所以不可以定义为私有类，去掉下划线
class BaseCardState extends State<BaseCard> {
  /// 这里把这俩个颜色取出来，也是为了 便于在子类里面 复写改变
  Color subTitleColor = Colors.grey;
  Color bottomTitleColor = Colors.grey;

  @override
  Widget build(BuildContext context) {
    /// 通过裁切方式创造圆角的卡片
    /// PhysicalModel ，主要的功能就是设置widget四边圆角，可以设置阴影颜色，和z轴高度
    // PhysicalModel({
    //     //裁剪模式
    //     this.clipBehavior = Clip.none,
    //     //四角圆度半径
    //     this.borderRadius,
    //     //z轴高度
    //     this.elevation = 0.0,
    //    //设置阴影颜色
    //     this.shadowColor = const Color(0xFF000000),
    //   })
    return PhysicalModel(
      // 裁切补充的颜色
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      // 裁切行为：抗锯齿
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(color: Colors.white,),
        child: Column(
          /// VERY IMPORTANT
          /// 由于是基类，要考虑到子类的重写，这里要进行抽象
          children: [
            topContent(),
            bottomContent(),
          ],
        ),
      ),
    );
  }

  Widget topTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 22),
    );
  }

  Widget topTitle2(String title) {
    return Container();
  }

  Widget subTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(top: 5),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          color: subTitleColor,
        ),
      ),
    );
  }

  Widget bottomTitle(String title) {
    return Text(
      title,
      style: TextStyle(
          fontSize: 12,
          color: bottomTitleColor,
      ),
    );
  }

  topContent() {
    return Padding(padding: EdgeInsets.fromLTRB(20, 26, 20, 10),
      child: Column(
        /// 对于列来说，侧轴就是 水平方向，这样让标题都右对齐
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Row(
              /// 这里主要是使得小标题居下对齐
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
              topTitle(""),
              topTitle2(""),
            ],
          ),
          subTitle(""),
        ],
      ),
    );
  }

  bottomContent() {
    return Container();
  }

}
