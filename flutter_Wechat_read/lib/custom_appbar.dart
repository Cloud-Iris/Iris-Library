import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// 对于一些手机的刘海屏或者异形屏，上边距应该是不固定的
    double paddingTop = MediaQuery.of(context).padding.top;

    return Container(
      margin: EdgeInsets.fromLTRB(20, paddingTop+10, 20, 5),
      /// padding 设置的小一些是为了让 容器内容去撑开
      padding: EdgeInsets.fromLTRB(20, 7, 20, 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white60,
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.search, color: Colors.grey,),
          /// 撑开宽度
          Expanded(
            child: Text(
              "长安十二时辰",
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
          ),
          /// 竖线
          Container(
            width: 1,
            height: 20,
            margin: EdgeInsets.only(right: 13),
            decoration: BoxDecoration(color: Colors.grey),
          ),
          Text(
            "书城",
            style: TextStyle(fontSize: 13),
          )
        ],
      ),
    );
  }
}
