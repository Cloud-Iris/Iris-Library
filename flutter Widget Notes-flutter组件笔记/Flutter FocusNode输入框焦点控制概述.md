# Flutter FocusNode输入框焦点控制概述

在Flutter使用FocusNode来捕捉监听TextField的焦点获取与失去，同时也可通过FocusNode来使用绑定对应的TextField获取焦点与失去焦点，FocusNode的使用分四步，如下：

第一步创建FocusNode，代码如下：

```dart
//创建FocusNode对象实例
 FocusNode focusNode = FocusNode();
```



第二步初始化函数中添加焦点监听，代码如下：

```dart
/// 输入框焦点事件的捕捉与监听
@override
void initState() {
  super.initState();

   //添加listener监听
   //对应的TextField失去或者获取焦点都会回调此监听
    focusNode.addListener((){
      if (focusNode.hasFocus) {
        print('得到焦点');
      }else{
      print('失去焦点');
      }
    });
}
```



第三步在TextField中引用FocusNode，代码如下：

```dart
new TextField(
  //引用FocusNode
  focusNode: focusNode,
),
```



第四步在页面Widget销毁时，释放focusNode，代码如下：

```dart
//页面销毁
@override
void dispose() {
  super.dispose();
  //释放
  focusNode.dispose();
}
```



## 在项目开发中，关于focusNode的常用方法代码如下：

```dart
//获取焦点
void getFocusFunction(BuildContext context){
  FocusScope.of(context).requestFocus(focusNode);
}

//失去焦点
void unFocusFunction(){
  focusNode.unfocus();
}

//隐藏键盘而不丢失文本字段焦点：
void hideKeyBoard(){
  SystemChannels.textInput.invokeMethod('TextInput.hide');
}
```



在实际项目中的一个用户操作习惯就是当输入键盘是弹出状态时，用户点击屏幕的空白处，键盘要隐藏，处理实现思路就是在MaterialApp组件中的第一个根布局设置一上手势兼听，然后在手势兼听中处理隐藏键盘的功能，代码如下：

```dart
/// 全局点击空白处理隐藏键盘
Widget buildMainBody(BuildContext context) {
    return GestureDetector(
        onTap: () {
            //隐藏键盘
            SystemChannels.textInput.invokeMethod('TextInput.hide');
        },
        child: ... ... 省略
    );
}
```

