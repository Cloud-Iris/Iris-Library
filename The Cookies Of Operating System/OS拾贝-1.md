# OS拾贝-1

## 前言

本着虽然我菜但是总得给followers整点东西的原则，暂时开启一个类似这样的笔记上传系列。由于不会写博客也没时间，我只能暂时通过这种方式分享一点点角落里的干货。

## 如何在$lab2$的链表中访问到elm元素的前一个元素？

通过`*(elm->field.le_prev)`只能拿到前一个元素的le_next指针。但是我们通过指针是没办法得到指向前一个元素本身的指针的。那么我们该如何做到这一点呢？

上面的问题其实可以转换为：**已知结构体type的成员member的地址ptr，求解结构体type的起始地址。**

总体的思路便是：type的起始地址 = ptr - size    (这里需要都转换为char *，因为它为单位字节)。

其中size是结构体type的成员member到结构体起始地址的字节数大小。那么怎么求size呢？

这里需要用到一个叫做`container_of`的宏。该宏定义如下：

```c
#define container_of(ptr, type, member) ({              \
const typeof( ((type *)0)->member ) *__mptr = (ptr);    \
(type *)( (char *)__mptr - offsetof(type,member) );})
```

这里出现了一个老朋友，在lab1的代码中就已经出现的宏`offsetof(type, member)`

```c
#define offsetof(type, member)  ((size_t)(&((type *)0)->member))
```

这个宏是一个size_t类型的值。

> size_t是标准C库中定义的，在64位系统中为long long unsigned int，非64位系统中为long unsigned int。
>
> size_t是一个基本的**无符号整数**的C / C + +类型，它是sizeof操作符返回的结果类型，该类型的大小可选择。因此，它可以存储在理论上是可能的任何类型的数组的最大大小。换句话说，一个指针可以被安全地放进为size_t类型（一个例外是类的函数指针，但是这是一个特殊的情况下）

宏`offsetof(type, member)`的意思是

- `(type *)0` 将内存空间的 0 转换成需要的结构体指针
- `(type *)0)->member` 利用这个结构体指针指向某个成员
- `(&((type *)0)->member)` 取这个成员的地址，这里这个值其实就是结构体type的成员member到结构体起始地址的字节数大小
- `((size_t)(&((type *)0)->member))` 将这个成员的地址转化成 `size_t` 类型

那么显然，凭借宏`offsetof(tyep, member)`的就可以求出size的值，再转为 `size_t` 类型。那为什么不用结构体type的成员member的地址ptr直接减去size呢？

**这里体现了内核编程的严谨性**

第二行额外的中间变赋值

```c
const typeof( ((type *)0)->member ) *__mptr = (ptr);  
```

它的作用是什么呢？ 其实没什么作用，但就形式而言 _mptr = ptr,  那为什么要要定义一个一样的变量呢？？？ 其实这正是内核人员的牛逼之处：如果开发者使用时输入的参数有问题：ptr与member类型不匹配，编译时便会有warnning， 但是如果去掉改行，那个就没有了，

**最后再说下typeof**

这个关键字在宏里面大量使用。常见用法一共有以下几种。

* 不用知道函数返回什么类型，可以使用typeof()定义一个用于接收该函数返回值的变量

<details>
  <summary>展开查看举例代码</summary>
  <pre><code> 
```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
struct apple{
    int weight;
    int color;
};
struct apple *get_apple_info()
{
    struct apple *a1;
    a1 = malloc(sizeof(struct apple));
    if(a1 == NULL)
    {
        printf("malloc error.\n");
        return;
    }
    a1->weight = 2;
    a1->color = 1;
    return a1;
}
int main(int argc, char *argv[])
{
    typeof(get_apple_info()) r1;//定义一个变量r1,用于接收函数get_apple_info()返回的值，由于该函数返回的类型是：struct apple *，所以变量r1也是该类型。注意，函数不会执行。
    r1 = get_apple_info();
    printf("apple weight:%d\n", r1->weight);
    printf("apple color:%d\n", r1->color);
    return 0;
}
```
  </code></pre>
</details>


* 在宏定义中动态获取相关结构体成员的类型

```c
#define max(x, y) ({                \
    typeof(x) _max1 = (x);          \
    typeof(y) _max2 = (y);          \
    (void) (&_max1 == &_max2);      \
    _max1 > _max2 ? _max1 : _max2; })
//如果调用者传参时，x和y两者类型不一致，在编译时就会发出警告。
```

因此第二行额外的中间变赋值

```c
const typeof( ((type *)0)->member ) *__mptr = (ptr);  
```

其实就是利用传入的type参数和member参数，声明一个type结构体的成员member类型的指针承接ptr参数。如果传入的ptr参数类型不是type结构体的成员member类型的指针，那么就会产生warning。在一切正常的情况下，执行第三行代码，通过将ptr-size的结果转为type*类型，得到了成员所在结构体的初始地址。

```c
(type *)( (char *)__mptr - offsetof(type,member) );
```

那么回到最初的问题，在通过`*(elm->field.le_prev)`拿到前一个元素的le_next指针后，我们自然而然就可以通过宏`container_of(ptr, type, member)`用代码访问到前一个元素。

```c
container_of(*(elm->field.le_prev), Page, le_next);
```

## 后言

其实像这样的细节总结我还做了很多就是了，但是篇幅过长，可能阅读体验并不友好。OS的代码很值得玩味，读懂了以后会感觉蛮有意思的。
