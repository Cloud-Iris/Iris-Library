# OS拾贝-2

## 前言

本着虽然我菜但是总得给followers整点东西的原则，暂时开启一个类似这样的笔记上传系列。由于不会写博客也没时间，我只能暂时通过这种方式分享一点点角落里的干货。

## 详细解析在系统中出现的三种地址

**目前，在我们的系统内，一共有三种地址，虚拟地址va，物理地址pa，以及物理内存控制块地址**。前两种是u_long类型，后一种是struct Page\*类型。**以及物理内存控制块的指针之间做差得到的物理页号**。

<font color='red'>**但是，值得注意的是，这三种地址都是32位，**</font>之所以会出现“物理内存控制块地址到物理地址需要左移12位”，<font color='red'>**是因为左移12位的不是物理控制块地址，而是物理内存控制块自己的地址减去物理内存控制块数组首地址后的差值——对应着这是第几个物理页。**</font>

这个值是两个struct Page\*类型的指针的减法结果。由于指针减法的特性，减法结果实际上自动除以了struct Page\*类型的大小（**两个同类型指针相减的结构不是以字节为单位的,而是以指针指向的数据类型大小为单位的**），得到的就是pages数组的下标索引，反应了它是第几个Page结构体，自然也是第几个物理页面。因此这个值就是一个$[0, npage-1]=[0, 2^{14}-1]$之间的数，虽然它也是32位数，但是它的高位全是0，而且有效数字不会超过14位，因此可以将其左移12位得到物理地址。当然，物理内存控制块地址（即struct Page*类型）本身是$pages(数组基地址)+个数\times12(每个结构体大小)$。

**MOS中物理内存大小是64MB**，则对应地址的范围是0x0000 0000 - 0x0040 0000。

正好是26位=第几个物理页[不超过14位数]<<12[左移12位]

**总的来说：目前操作的物理地址的高位全是0，有效的数字并不够32位。意识到这一点很重要。**

**物理内存控制块地址 到 物理地址 的转换就是**，当前页数的地址减去pages这个数组的首地址以后的结果，通过左移12位得到物理页数对应的物理地址，然后通过KADDR转换为虚拟地址。因为物理页数本身就是页“数”嘛，所以转换成的物理地址一定是页面大小的整数倍。

**物理地址 到 物理内存控制块地址 的转换就是**，在合法性检查结束以后，将物理地址右移12位得到的结果（即算出它是在哪一页上）作为pages数组的索引。即&pages[PPN(pa)]。

### 下面是相应的地址转换的函数

```c
/* Get the Page struct whose physical address is 'pa'. */
static inline struct Page *pa2page(u_long pa)
{
   if (PPN(pa) >= npage) {
      panic("pa2page called with invalid pa: %x", pa);
   }
   return &pages[PPN(pa)];
}
/* Get the Page struct whose physical address is 'pa'. */
static inline u_long page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT; // PGSHIFT = 12
}
/* Get the kernel virtual address of Page 'pp'. */
static inline u_long page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
}
// 得到page地址对应的物理页数
static inline u_long page2ppn(struct Page *pp)
{
	return pp - pages;
}
```

### 到这里，我们不妨来熟悉一个这个链表的一些基本寻址操作

规定：

>elm是当前元素的指针，类型为Type*。
>
>Type结构体中的链表项（即两个指针组成的结构体）记作field。
>
>下面代码均假定在宏中编写，因此会有相比起正常代码多余的()

当前元素的前一个元素的le\_next指针：

```c
*((elm)->field.le_prev)
```

指向当前元素的后一个元素的指针：

```c
LIST_NEXT((elm), field)   // 其实就是elm->field.le_next
```

当前元素的后一个元素的le_next指针 / 指向当前元素的下下一个元素的指针：

```c
LIST_NEXT(LIST_NEXT((elm), field), field)
```

## 后言

其实像这样的细节总结我还做了很多就是了，但是篇幅过长，可能阅读体验并不友好。OS的代码很值得玩味，读懂了以后会感觉蛮有意思的。

记得点点star，谢谢啦。

GitHub的公式渲染是不是有点问题啊。好烦orz。
