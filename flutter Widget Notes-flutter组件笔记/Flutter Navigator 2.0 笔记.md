# Flutter Navigator 2.0 笔记

Navigator 2.0 引入了一套全新的声明式 API，与 Navigator 1.0 不同，这类 API 可以实现用一组声明式的不可变的 Page 页面列表表示应用中的历史路由页面，从而转换成实际代码中 Navigator 的 Routes，这与 Flutter 中将不可变的 Widgets 解析成 Elements 并在页面中渲染的原理不谋而合。

## Navigator 1.0

在 Navigator 2.0 推出之前，我们在应用中通常使用下面这两个类来管理各个页面：

* Navigator，管理一组 Route 对象。
* Route，一个 Route 通常可以表示一个页面，被 Navigator 持有，常用的两个实现类是 MaterialPageRoute 和 CupertinoPageRoute 。

Route 可以通过命名路由和组件路由（匿名路由）的方式被 push 进或者 pop 出 Navigator 的路由栈。我们先来简单回顾一下之前的传统用法。

### 传统用法-组件路由

传统路由的实现中，Flutter 的各个页面由 Navigator 组织，彼此叠放成一个 “路由栈”，常用的根组件 MaterialApp和CupertinoApp 底层就是通过 Navigator 来实现全局路由的管理的，我们可以通过 Navigator.of() 或者 Navigator.push()、Navigator.pop() 等接口实现多个页面之间的导航，具体做法如下：

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(Nav2App());
}

class Nav2App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: FlatButton(
          child: Text('View Details'),
          onPressed: () {
            // 打开页面
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) {
                return DetailScreen();
              }),
            );
          },
        ),
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: FlatButton(
          child: Text('Pop!'),
          onPressed: () {
            // 弹出页面
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
```



当调用 push() 方法时，DetailScreen 组件就会被放置在 HomeScreen 的顶部，如图所示。

<img src='/NoteImg/Navigator-01.png'>

此时，上一个页面（HomeScreen）仍在组件树中，因此当 DetailScreen 打开时它的状态依旧会被保留。

### 传统用法-命名路由

Flutter 还支持通过命名路由的方式打开页面，各个页面的名称组成 “路由表” 通过参数（routes）传递给 MaterialApp 、CupertinoApp，如下：

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(Nav2App());
}

class Nav2App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 路由表
      routes: {
        '/': (context) => HomeScreen(),
        '/details': (context) => DetailScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: FlatButton(
          child: Text('View Details'),
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/details',
            );
          },
        ),
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: FlatButton(
          child: Text('Pop!'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
```



使用命名路由时都需要预先定义好需要打开的页面，尽管我们也可以在各个页面之间传递数据，但这种方式原生并不支持直接解析路由参数，如不能使用 Web 应用中的链接形式 /details/:id 的路由名称。



当然，我们可以使用 onGenerateRoute 来接受路由的完整路径，如下：

```dart
onGenerateRoute: (settings) {
  // Handle '/'
  if (settings.name == '/') {
    return MaterialPageRoute(builder: (context) => HomeScreen());
  }

  // Handle '/details/:id'
  var uri = Uri.parse(settings.name);
  if (uri.pathSegments.length == 2 &&
      uri.pathSegments.first == 'details') {
    var id = uri.pathSegments[1];
    return MaterialPageRoute(builder: (context) => DetailScreen(id: id));
  }

  return MaterialPageRoute(builder: (context) => UnknownScreen());
},
```



这里，我们可以通过 RouteSettings 类型的对象 settings 可以拿到 Navigator.pushNamed 调用时传入的参数。

完整的例子如下：

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(Nav2App());
}

class Nav2App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: (settings) {
        // Handle '/'
        if (settings.name == '/') {
          return MaterialPageRoute(builder: (context) => HomeScreen());
        }

        // Handle '/details/:id'
        var uri = Uri.parse(settings.name);
        if (uri.pathSegments.length == 2 &&
            uri.pathSegments.first == 'details') {
          var id = uri.pathSegments[1];
          return MaterialPageRoute(builder: (context) => DetailScreen(id: id));
        }

        return MaterialPageRoute(builder: (context) => UnknownScreen());
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: FlatButton(
          child: Text('View Details'),
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/details/1',
            );
          },
        ),
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  String id;
  DetailScreen({ this.id, });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Viewing details for item $id'),
            FlatButton(
              child: Text('Pop!'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class UnknownScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text('404!'),
      ),
    );
  }
}
```



## Navigator 2.0

Navigator 2.0 提供了一系列全新的接口，可以实现将路由状态成为应用状态的一部分，并能够通过底层 API 实现参数解析的功能，新增的 API 如下：

* Page，用来表示 Navigator 路由栈中各个页面的配置信息（不可变对象）。

  > Page本身是一个抽象类，通常使用它的派生类 MaterialPage 和 CupertinoPage 。

* Router，用来制定要由 Navigator 展示的页面列表，通常，该页面列表会根据系统或应用程序的状态改变而改变。

  > 除了直接使用 Router 本身外还可以使用 MaterialApp.router() 来创建 Router。

* RouteInformationParser，持有 RouteInformationProvider 提供的 RouteInformation ，可以将其解析为我们定义的数据类型。

  > 可以缺省，主要应用与web。

* RouterDelegate，定义应用程序中的路由行为，例如 Router 如何知道应用程序状态的变化以及如何响应。主要的工作就是监听 RouteInformationParser 和应用状态并通过当前页面列表构建。

* BackButtonDispatcher，响应后退按钮，并通知 Router

下图展示了 RouterDelegate 与 Router、RouteInformationParser 以及用用状态的交互原理。

<img src='/NoteImg/Navigator-02.png'>



### 大致流程如下（非常重要）：

1. 当系统打开新页面（如 “/detail”）时，RouteInformationParser 会将其转换为应用中的具体数据类型 T（如我们自己命名的 BooksRoutePath、BiliRoutePath、 MyAppRoutePath）。
2. 该数据类型会被传递给 RouterDelegate 的 setNewRoutePath 方法，我们可以在这里更新路由状态（如通过设置 selectedBookId、videoId等）。
3. 调用 notifyListeners 响应该操作。
   notifyListeners 会通知 Router 重建 RouterDelegate（通过 build() 方法）。
4. RouterDelegate.build() 返回一个新的 Navigator 实例，并最终展示出我们想要打开的页面。

那么，实现页面的跳转，实际上就是

<font color='red' size='4px'>**调用 notifyListeners 完成页面数据更新，并通知 Router 用 build() 方法重建 RouterDelegate**</font>

这里结合老师带我们写的例子来梳理一下这个流程。

**第一步：定义泛型。**也就是上面提到的具体数据类型 T。

**第二步：编写 setNewRoutePath 方法，更新路由状态。**

**第三步：调用 notifyListeners 响应 setNewRoutePath 方法。**

**第四步：编写 RouterDelegate.build()，返回一个新的 Navigator 实例。**

### main.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bilibili/db/hi_cache.dart';
import 'package:flutter_bilibili/http/core/hi_error.dart';
import 'package:flutter_bilibili/http/core/hi_net.dart';
import 'package:flutter_bilibili/http/dao/login_dao.dart';
import 'package:flutter_bilibili/http/request/notice_request.dart';
import 'package:flutter_bilibili/http/request/test_request.dart';
import 'package:flutter_bilibili/model/owner.dart';
import 'package:flutter_bilibili/model/video_model.dart';
import 'package:flutter_bilibili/page/home_page.dart';
import 'package:flutter_bilibili/page/login_page.dart';
import 'package:flutter_bilibili/page/registration_page.dart';
import 'package:flutter_bilibili/page/video_detail_page.dart';
import 'package:flutter_bilibili/util/color.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  MyAppRouteDelegate _myAppRouteDelegate = MyAppRouteDelegate();

  @override
  Widget build(BuildContext context) {
    /// 定义route
    var widget = Router(
      routerDelegate: _myAppRouteDelegate,
    );
    return MaterialApp(
      home: widget,
    );
  }
}

/// VERY IMPOARTANT Navigator 2.0  Step 1
/// 当系统打开新页面（如 “/detail”）时，RouteInformationParser 会将其转换为应用中的具体数据类型 T
///   也就是我们在这里定义的 泛型类 MyAppRoutePath。
/// 这里也正是 抽象类 RouterDelegate 需要的泛型类
/// 表示路由的path，建立路由的路径path和页面的联系
class MyAppRoutePath {
  final String location;
  MyAppRoutePath.home(): location="/";
  MyAppRoutePath.detail(): location="/detail";
}
/// 创建页面的方法 这里选用 material page
pageWrap(Widget child) {
  return MaterialPage(
    key: ValueKey(child.hashCode),
    child: child
  );
}

/// VERY IMPORTANT Navigator 2.0  Step 2
/// 我们自己定义的数据类型数据类型会被传递给 RouterDelegate 的 setNewRoutePath 方法，我们可以在这里更新路由状态（如通过设置 selectedBookId、videoId等）
/// RouterDelegate 是 Navigator2.0 中管理路由的栈的类
/// 最为核心的一点就是build方法中来实现对路由栈的管理
/// 两个 mixins 分别是
/// ChangeNotifier 用于代替 setState
/// PopNavigatorRouterDelegateMixin 作为RouterDelegate的混合，调用其中的一些API
class MyAppRouteDelegate extends RouterDelegate<MyAppRoutePath> with
    ChangeNotifier, PopNavigatorRouterDelegateMixin<MyAppRoutePath>{

  /// VERY IMPORTANT
  /// 这里是 PopNavigatorRouterDelegateMixin 要求含有“navigatorKey”这个名字的属性
  final GlobalKey<NavigatorState> navigatorKey;
  /// Navigator设置一个key，
  /// 必要的时候可以通过navigatorKey.currentState来获取到NavigatorState对象
  MyAppRouteDelegate() : navigatorKey = GlobalKey<NavigatorState>();
  /// 页面列表
  List<MaterialPage> pages = [];
  VideoModel? videoModel;
  MyAppRoutePath? path;

  @override
  Future<void> setNewRoutePath(MyAppRoutePath configuration) async {
    this.path = configuration;
  }

  /// VERY IMPORTANT Navigator 2.0  Step 4
  /// RouterDelegate.build() 返回一个新的 Navigator 实例，并最终展示出我们想要打开的页面。
  @override
  Widget build(BuildContext context) {
    /// 构建路由堆栈
    pages = [
      pageWrap(HomePage(
        onJumpToDetail: (videoModel){
          this.videoModel = videoModel;
          /// VERY IMPORTANT Navigator 2.0  Step 3
          /// 调用 notifyListeners 响应 Step 2 中的操作。（响应 Step 2 中的 setNewRoutePath 方法）
          /// notifyListeners 会通知 Router 重建 RouterDelegate（通过 build() 方法）。
          /// 和 setState 对于组件的效果类似
          notifyListeners();
        },
      )),
      if(videoModel != null) pageWrap(VideoDetailPage(videoModel: videoModel!))
    ];

    return Navigator(
      key: navigatorKey,
      pages: pages,
      /// VERY IMPORTANT onPopPage 就是 一个返回布尔值的回调函数
      /// final PopPageCallback? onPopPage;
      /// typedef PopPageCallback = bool Function(Route<dynamic> route, dynamic result);
      onPopPage: (route, result){
        /// 在这里可以控制是否可以返回上一页面
        /// TODO 比如说这里可以扩展，当用户没有填写完表单，就不允许返回
        /// 这里仅仅只是判断有没有执行 didPop
        if (!route.didPop(result)){
          return false;
        }
        return true;
      },
    );
  }

}

```



### home_page.dart

```dart
class HomePage extends StatefulWidget {
  final ValueChanged<VideoModel>? onJumpToDetail;

  const HomePage({Key? key, this.onJumpToDetail}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: Column(
          children: [
            Text('首页'),
            MaterialButton(
                onPressed: () {
                  widget.onJumpToDetail!(VideoModel(111222));
                },
              child: Text('跳转到详情页'),
            )
          ],
        ),
      ),
    );
  }
}
```



### video_detail.dart

```dart
class VideoDetailPage extends StatefulWidget {
  final VideoModel videoModel;

  const VideoDetailPage({Key? key, required this.videoModel}) : super(key: key);

  @override
  State<VideoDetailPage> createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: Text("视频详情页 vid: ${widget.videoModel.videoId}"),
      ),
    );
  }
}
```



默认情况下，导航系统是不支持 监测页面跳转 的，

页面有没有被压后台，页面有没有重新打开，以及路由堆栈的管理、为了实现未登录的拦截、底部tab的切换。







