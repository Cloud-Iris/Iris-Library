# Divider 分割线组件

Divider的构造方法

```kotlin
const Divider({
    Key key,
    this.height,
    this.thickness,
    this.indent,
    this.endIndent,
    this.color,
  }) : assert(height == null || height >= 0.0),
       assert(thickness == null || thickness >= 0.0),
       assert(indent == null || indent >= 0.0),
       assert(endIndent == null || endIndent >= 0.0),
       super(key: key);
```

可以看出Divider组件只有5个属性，一目了然，使用也非常简单

 **indent:** 起点缩进距离
 **endIndent:** 终点缩进距离
 **color:** 分割线颜色
 **height:** 分割线区域的高度，并非分割线的高度（实际整个组件占据的高度）
 **thickness:** 分割线的厚度，真正的分割线（可见部分）的高度

**注意:**
 1.当height为null的时候会去查看 DividerThemeData.space的高度，如果同样为null，则默认分割线区间为16
 2.如果不设置thickness的高度，分割线默认为1px且居中显示
 3.如果想设置真实的分割线高度，需要把height和thickness设置为一样高即可。
 4.flutter还提供了竖直方向上的分割线组件VerticalDivider,用法一至，不在赘述。

**Demo**

```css
Divider(
          color: Colors.grey,
          height: 10,
          thickness: 10,
          indent: 15.0,
          endIndent: 15.0,
        )
```

![img](https:////upload-images.jianshu.io/upload_images/2760539-840831db1ec3cef5.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200/format/webp)



作者：Peter杰
链接：https://www.jianshu.com/p/37184256007e
来源：简书
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。