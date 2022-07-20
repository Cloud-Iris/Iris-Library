import 'package:flutter/material.dart';
import './content_pager.dart';

/// 底部导航框架
class TabNavigator extends StatefulWidget {
  const TabNavigator({Key? key}) : super(key: key);

  @override
  State<TabNavigator> createState() => _TabNavigatorState();
}

class _TabNavigatorState extends State<TabNavigator> {
  // 底部导航栏选中与未选中的颜色
  final _defaultColor = Colors.grey;
  final _activeColor = Colors.blue;
  // 默认选中的坐标
  int _currentIndex = 0;
  /// 自定义内容区域（PageView）的控制器
  ///   实现当 底部导航栏 切换时，上面的页面也跟着变化
  final ContentPagerController _contentPagerController = ContentPagerController();

  @override
  Widget build(BuildContext context) {
    /// Scaffold() 组件实现页面布局
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          /// 实现线性渐变背景色
          gradient: LinearGradient(
            colors: [
              Color(0xffedeef0),
              Color(0xffe6e7e9),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        /**
         * 主体的滑动卡片
         */
        child: ContentPager(
          /// 这样，在 PageView 的 index 发生变化的时候，
          /// 就会通过 onPageChanged 这个回调函数 改变 底部导航栏的 _currentIndex
          onPageChanged: (int index){
            setState(() {
              _currentIndex = index;
            });
          },
          /// 而这里，则是在 底部导航栏定义一个 PageView 中的
          /// ContentPagerController 属性的控制器
          /// 用于回调影响，当底部导航栏的 _currentIndex 改变时， PageView也变化
          contentPagerController: _contentPagerController,
        ),
      ),
      /**
       * 底部导航栏
       */
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        /// 这个属性 BottomNavigationBarType.fixed 让
        /// 无论是否选中，都会显示底部文字，
        /// 不过这里选择另外一个 shifting 好像会有问题，显示不出来文字
        /// shifting 原本的效果是，只有选中的标签才会显示文字
        type: BottomNavigationBarType.fixed,
        onTap: (index){
          /// 修改当前页面的状态
          setState(() {
            _currentIndex = index;
          });
          /// 把 PageView 的页面也做相应的更改，滚动到对应页面
          _contentPagerController.jumpToPage(index);
        },
        items: [
          _bottomItem("本周", Icons.folder, 0),
          _bottomItem("分享", Icons.explore, 1),
          _bottomItem("免费", Icons.donut_small, 2),
          _bottomItem("长安", Icons.person, 3),
        ],
      ),
    );
  }

  /// 底部导航标签
  _bottomItem(String title, IconData iconData, int index){
    return BottomNavigationBarItem(
      icon: Icon(iconData, color: _defaultColor,),
      activeIcon: Icon(iconData, color: _activeColor,),
      /// 这里教程里面是title，但是现在的这个类取消了title，官方文档里也没有这个
      /// https://api.flutter-io.cn/flutter/widgets/BottomNavigationBarItem-class.html
      label: title,
    );
  }
}
