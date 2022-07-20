import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_wechat_read/card_free.dart';
import 'package:flutter_wechat_read/card_recommend.dart';
import 'package:flutter_wechat_read/card_share.dart';
import 'package:flutter_wechat_read/card_special.dart';
import 'package:flutter_wechat_read/custom_appbar.dart';

class ContentPager extends StatefulWidget {

  final ValueChanged<int>? onPageChanged;
  final ContentPagerController? contentPagerController;

  /// 构造方法    key 和 onPageChanged 作为可选参数
  const ContentPager({Key? key, this.onPageChanged, this.contentPagerController})
      /// 初始化列表
      : super(key: key);

  @override
  State<ContentPager> createState() => _ContentPagerState();
}

class _ContentPagerState extends State<ContentPager> {
  /// 可以滑动切换 的组件
  /// PageView 中有一个很重要的属性 controller
  /// PageController? controller, 而 controller又有几个重要的属性
  ///    this.viewportFraction = 1.0,   改变视图比例
  PageController _pageController = PageController(
    /** 视窗比例 **/
    viewportFraction: 0.8,
  );

  static final List<Color> _colors = [
    Colors.blue,
    Colors.red,
    Colors.deepOrange,
    Colors.teal,
  ];

  @override
  void initState() {
    super.initState();

    if(widget.contentPagerController != null){
      /// VERY IMPORTANT
      /// dart 编程技巧  ?. 的方式来安全地调用 对象的 可以为空的属性
      widget.contentPagerController?._pageController = this._pageController;
      /// 这里把 PageView 的 pageController 传给 contentPagerController
      /// 而 contentPagerController 正是 由底部导航组件传给 PageView 的
      /// 这样 底部导航栏 就可以 调用 contentPagerController 的 jumpToPage 方法
      /// （实际上是 PageView 的 pageController 的 jumpToPage 方法）
      /// 就达到了 底部导航栏切换时，改变 PageView 的index 的效果
    }

    /// 状态栏样式-沉浸式主状态栏
    _statusBar();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // appBar
        CustomAppBar(),
        /// Expanded 组件用于撑开 Column 组件的高度，
        /// 否则在 Column 中没有高度会报错
        Expanded(
            child: PageView(
              controller: _pageController,
              /// VERY IMPORTANT 在有状态组件里
              /// 用 widget 关键词就是代表了 State<ContentPager> 中的 ContentPager
              /// 因此在有状态组件必须拆成 两个类来编写时，用 widget 可以很方便地拿到
              /// 前一个类的静态属性
              onPageChanged: widget.onPageChanged,
              /// VERY IMPORTANT
              /// 而内部组件 调用 外部组件的 属性的 常用方法 便是
              /// 内部组件定义一个私有属性，使得外部组件在 调用内部组件的构造方法 的时候
              /// 把包含有 外部类属性的 回调方法 传给内部组件的对应**属性**
              /// 使得内部组件的这一方法属性可以 在某种条件下改变外部组件的属性
              children: [
                _wrapItem(CardRecommend()),
                _wrapItem(CardShare()),
                _wrapItem(CardFree()),
                _wrapItem(CardSpecial()),
              ],
            ),
        )
      ],
    );
  }
  /// 滑动卡片封装
  // Widget _wrapItem(int index) {
  //   return Padding( padding: EdgeInsets.all(15),
  //     child: Container(
  //       decoration: BoxDecoration(
  //         color: _colors[index],
  //       ),
  //     ),
  //   );
  // }
  Widget _wrapItem(Widget widget) {
    return Padding(
      padding: EdgeInsets.all(15),
      child: widget,
    );
  }
  /// 状态栏样式-沉浸式 状态栏
  _statusBar() {
    /// 拷贝 SystemUiOverlayStyle dark 里面的样式
    /// 实现一个 黑色沉浸式状态栏
    SystemUiOverlayStyle uiOverlayStyle = const SystemUiOverlayStyle(
      /// 控制 底部 系统导航图标的颜色 （该属性只在安卓上有）
      systemNavigationBarColor: Color(0xFF000000),
      /// 控制 底部 系统导航图标 （该属性只在安卓上有）
      /// 的颜色是白色 light 还是黑色 dark
      systemNavigationBarIconBrightness: Brightness.light,
      /// 控制系统顶部状态栏的颜色，
      /// statusBarColor          控制安卓
      /// statusBarBrightness     控制 IOS
      statusBarColor: Colors.transparent,   // 透明的话就和APP背景色一样
      /// 控制 顶部 系统状态图标（信号，wifi图标，电池，闹钟等）
      /// 的颜色是白色 light 还是黑色 dark
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    );

    SystemChrome.setSystemUIOverlayStyle(uiOverlayStyle);
  }
}

/// 自定义内容区域（PageView）的控制器
///   实现当 底部导航栏 切换时，PageView 的页面也跟着变化
///   /// VERY IMPORTANT
/// 封装 一个 Controller 是外部组件 调用 内部组件的 属性的 常用方法
/// 通过包裹一个内部组件的 方法属性 a 成为一个新的类 A
/// 把这个新的类作为内部组件的属性 in.A,并令 in.A的方法 in.A.a' = 内部组件的方法属性 a
///
/// 同时， 外部组件也把这个类实例化，作为自己的属性 out.A
/// 外部组件在 调用 调用内部组件的构造方法 的时候
/// 把  out.A  作为 参数 in.A 传给构造的内部组件
/// 这样，外部类通过调用 out.A 的方法，其实是调用 in.A 的方法a'，也就是内部组件的方法属性 a
/// 这样就实现了 外部类调用内部类的方法
class ContentPagerController{
  PageController? _pageController;

  void jumpToPage(int pageIndex) {
    /// VERY IMPORTANT
    /// dart 编程技巧 ?. 的方式来安全地调用可以为空的对象的方法
    _pageController?.jumpToPage(pageIndex);
  }
}