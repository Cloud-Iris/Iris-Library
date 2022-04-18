# OS拾贝-2

## 前言

本着虽然我菜但是总得给followers整点东西的原则，暂时开启一个类似这样的笔记上传系列。由于不会写博客也没时间，我只能暂时通过这种方式分享一点点角落里的干货。

## <span id='jump3'>详细解析在系统中出现的三种地址</span>

**目前，在我们的系统内，一共有三种地址，虚拟地址va，物理地址pa，以及物理内存控制块地址。**前两种是u_long类型，后一种是struct Page*类型。**以及物理内存控制块的指针之间做差得到的物理页号**。

<font color='red'>**但是，值得注意的是，这三种地址都是32位。**</font>无论是虚拟地址还是物理控制块地址，在直接转化为物理地址的时候，只要是在kseg0，都可以直接使用PADDR宏，在最高位置0。

### 物理控制块地址直接转为物理地址

物理控制块地址直接转为物理地址的例子——mips\_vm\_init()函数中的

```c
boot_map_segment(pgdir, UPAGES, n, PADDR(pages), PTE_R);
boot_map_segment(pgdir, UPAGES, n, PADDR(envs), PTE_R);
```

### 物理控制块地址间接转为物理地址——以物理页数/物理内存控制块号为中介

这是源自使用page2pa带来的迷惑性——这里实际上是另一种物理控制块地址转为物理地址的方式。这里方式通过page2ppn求出这是第几个物理控制块/物理页，再由物理“页数”左移12位。

<font color='red'>**这里左移12位的不是物理控制块地址，而是物理内存控制块自己的地址减去物理内存控制块数组首地址后的差值——对应着这是第几个物理页。**</font>

上面这个值是两个struct Page\*类型的指针的减法结果。由于指针减法的特性，减法结果实际上自动除以了struct Page\*类型的大小（**两个同类型指针相减的结构不是以字节为单位的,而是以指针指向的数据类型大小为单位的**），得到的就是pages数组的下标索引，反应了它是第几个Page结构体，自然也是第几个物理页面。

因此，这个值就是一个$[0, npage-1]=[0, 2^{14}-1]$之间的数，虽然它也是32位数，但是它的高位全是0，而且有效数字不会超过14位，因此可以将其左移12位得到物理地址。当然，物理内存控制块地址（即struct Page\*类型）本身是$pages(数组基地址)+个数\times12(每个结构体大小)$。

**MOS中物理内存大小是64MB**，则对应地址的范围是0x0000 0000 - 0x0040 0000。正好是除了高位0以外，有效的26位=第几个物理页[不超过14位数]<<12[左移12位]

**总的来说：目前操作的物理地址的高位全是0，有效的数字并不够32位。意识到这一点很重要。**

所以在这种间接转化下：

**物理内存控制块地址 到 物理地址 的转换就是**，当前页数的地址减去pages这个数组的首地址以后的结果，通过左移12位得到物理页数对应的物理地址，然后通过KADDR转换为虚拟地址。因为物理页数本身就是页“数”嘛，所以转换成的物理地址一定是页面大小的整数倍。

**物理地址 到 物理内存控制块地址 的转换就是**，在合法性检查结束以后，将物理地址右移12位得到的结果（即算出它是在哪一页上）作为pages数组的索引。即&pages[PPN(pa)]。

> 为什么要绕一个圈子呢？我想大概是因为间接的方式可以得到这是第几个物理内存控制块，也就是第几个物理页。这个还是比较有用的。

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

### 后言

这里省略掉了物理地址和虚拟地址直接转化的两个宏。主要是这两个宏表示的转换方式是在kseg0特有的，而且也很简单。

其实像这样的细节总结我还做了很多就是了，但是篇幅过长，可能阅读体验并不友好。OS的代码很值得玩味，读懂了以后会感觉蛮有意思的。

记得点点star，谢谢啦。