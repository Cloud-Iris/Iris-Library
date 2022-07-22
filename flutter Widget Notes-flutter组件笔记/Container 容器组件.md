# Container容器



```dart
Container(
    decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
        ),
    ),
),
```

`BorderRadius.all` 就是对 `BorderRadius.only` 的二次封装，也就是重定向构造函数。

```dart
const BorderRadius.all(Radius radius) : this.only(
    topLeft: radius,
    topRight: radius,
    bottomLeft: radius,
    bottomRight: radius,
);
const BorderRadius.only({
    this.topLeft = Radius.zero,
    this.topRight = Radius.zero,
    this.bottomLeft = Radius.zero,
    this.bottomRight = Radius.zero,
});
```

