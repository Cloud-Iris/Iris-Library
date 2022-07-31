# FutureBuilder 详细解析



源码如下：

```dart
class FutureBuilder<T> extends StatefulWidget {
  const FutureBuilder({
    Key? key,
    this.future,
    this.initialData,
    required this.builder,
  }) : assert(builder != null),
       super(key: key);

  final AsyncWidgetBuilder<T> builder;
    
  final Future<T>? future;
    
  final T? initialData;
    
  static bool debugRethrowError = false;

  @override
  State<FutureBuilder<T>> createState() => _FutureBuilderState<T>();
}
```



* **final AsyncWidgetBuilder<T> builder**

> ```dart
typedef AsyncWidgetBuilder<T> 
    = Widget Function(BuildContext context, AsyncSnapshot<T> snapshot);
    ```

> The build strategy currently used by this builder.

当前 [builder] 使用的 build 策略。

> The builder is provided with an [AsyncSnapshot] object whose [AsyncSnapshot.connectionState] property will be one of the following values:

[builder] 由 一个 [AsyncSnapshot] 对象提供，这个异步对象的 [AsyncSnapshot.connectionState] 属性必须是下面几种之一：

`[ConnectionState.none]`

[future] 为空，[AsyncSnapshot.data] 将被设置为 [initialData]。除非在此之前已经完成了一个future，在这种情况下，先前的结果仍然存在。

`[ConnectionState.waiting]`

[future] 不为空但是还没有结束，[AsyncSnapshot.data] 将被设置为 [initialData]。除非在此之前已经完成了一个future，在这种情况下，先前的结果仍然存在。

`[ConnectionState.done]`

[future] 不为空并且已经结束，如果 [future] 成功结束，[AsyncSnapshot.data] 将被设置为该 [future] 结束的结果。如果 [future] 以一个错误结束，[AsyncSnapshot.hasError] 将被设置为 true 并且 [AsyncSnapshot.error] 将被设置为 the error object。

>This builder must only return a widget and should not have any side effects as it may be called multiple times.

这个 builder 必须返回一个 widget，而且重复调用多次时没有副作用。



* **final Future<T>? future;**

> The asynchronous computation to which this builder is currently connected, possibly null.

这个属性是 当前的[builder] 连接到的异步计算，可能为null。

> If no future has yet completed, including in the case where [future] is null, the data provided to the [builder] will be set to [initialData].

如果尚未完成任何future，包括在 [future] 为 null 的情况下，则提供给 [builder] 的数据将设置为[initialData]。




* **final T? initialData**

>The data that will be used to create the snapshots provided until a non-null [future] has completed.

这个 `data` 用于创建提供的快照（`snapshots`）的数据，直到一个非空的[future]完成。

> If the future completes with an error, the data in the [AsyncSnapshot] provided to the [builder] will become null, regardless of [initialData]. (The error itself will be available in [AsyncSnapshot.error], and [AsyncSnapshot.hasError] will be true.)

如果 [future] 的创建出现错误，则提供给 [builder] 的参数 [AsyncSnapshot] 中的数据将变为null，而不管[initialData]如何。（错误本身将在[AsyncSnapshot.error]中可用，并且[AsyncSnapshot.hasError]将为true。）



举一个例子

```dart
/// 未来要做的事情：对 HiCache 进行初始化
future: HiCache.preInit(),
/// 在 HiCache 初始化完成之前我们可以返回一个表示正在加载的状态的组件 比如说 Loading
builder: (BuildContext context, AsyncSnapshot<HiCache> snapshot){
    /// 定义 route
    var widget =
    /// 如果完成了初始化的状态，返回 router；如果还在初始化过程中，则返回加载中页面
        snapshot.connectionState == ConnectionState.done 
        ? Router(routerDelegate: _myAppRouteDelegate,) 
        : Scaffold(
            body: Center(
                child: CircularProgressIndicator(),
            ),
        );
    return MaterialApp(
        home: widget,
        theme: ThemeData(primarySwatch: appWhite),
        debugShowCheckedModeBanner: false,
    );
}
```



