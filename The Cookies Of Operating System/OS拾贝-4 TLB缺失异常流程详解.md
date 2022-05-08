# OS拾贝-4 ：TLB缺失异常详解

如题，这次主要是分享一下TLB缺失异常的流程解析。有不足之处还请各位大佬海涵。

## $TLB$ 中断何时被调用？

从上面的分析看，操作系统在实时钟的驱动下，通过时间片轮转算法实现进程的并发执行，不过如果没有 TLB 中断，真的可以正确的运行吗，当然不行。 

因为每当硬件在取数据或者取指令的时候，都会发出一个所需数据所在的虚拟地址，TLB 就是将这个虚拟地址转换为对应的物理地址，进而才能够驱动内存取得正确的所期望的数据。但是当 TLB 在转换的时候发现 **没有 对应于该虚拟地址 的项**，那么此时就会**产生一个 TLB 异常**。

> MyNote: 这里对于每一个进程来说，转化过程如下：在进程页目录映射的二级页表体系所代表的4G空间（也就是进程空间）里的某一个地址env_vaddr，对应的二级页表是额外申请的一页物理内存，二级页表的地址存放在进程的页目录的一级页表项，而二级页表本身的二级页表项中，存放了env_vaddr所代表的进程需要的数据、资源等在内存中实际存放在的物理地址。

TLB 对应的中断处理函数是 handle_tlb，通过宏映射到了 do_refill 函数上： 这个函数完成 TLB 的填充，在 lab2 中我们已经学习了 TLB 的基本结构，简单 来说就是对于不同进程的同一个虚拟地址，结合 ASID 和虚拟地址可以定位到不 同的物理地址（虚拟页号12-31共20位 + ASID 6-11共6位 + 0-5是NULL），下面重点介绍 TLB 缺失处理的过程。

> PTE_ADDR(va) | GET_ENV_ASID(curenv->env_id) 刚好拼成一个entryHi的域。



### 硬件为我们做了什么？

在发生 TLB 缺失的时候，会把引发 TLB 缺失的虚拟 地址填入到 BadVAddr Register 中，这个寄存器具体的含义请参看 MIPS 手册。接 着触发一个 TLB 缺失异常。

### BadVAddr Register 

该寄存器保存导致异常的地址。它被设置的情形如下：

* 任何MMU相关的问题；

* 如果用户程序试图访问kuseg之外的地址
* 或者地址对齐错误

在发生任何其他异常之后，BadVAddr Register 都是未定义的。特别要注意的是，它不是在总线错误后设置的。如果CPU为64位是，它是64位。

### 我们需要做什么？

从 BadVAddr 寄存器中获取使 TLB 缺失的虚拟地址，接着 拿着这个虚拟地址通过手动查询页表（MyNote: mContext 所指向的，在一开始它是boot_pgdir，后来又指向进程的页目录），找到这个虚拟地址所对应的二级页表项中的物理页面号，并将这个页面号填入到 PFN 中，也就是 EntryLo 寄存器，填写 好之后，tlbwr 指令就会将EntryHi和EntryLo的内容随机填入到具体的某一项 TLB 表项中。



## mCONTEXT轨迹查询

### 定义

mCONTEXT定义在start.S里

```assembly
.data
			.globl mCONTEXT
mCONTEXT:
			.word 0

			.globl delay
delay:
			.word 0

			.globl tlbra
tlbra:
			.word 0

			.section .data.stk
KERNEL_STACK:
			.space 0x8000


			.text
LEAF(_start)

	.set	mips2
	.set	reorder

	/* Disable interrupts */
	mtc0	zero, CP0_STATUS

    /* Disable watch exception. */
    mtc0    zero, CP0_WATCHLO
    mtc0    zero, CP0_WATCHHI

	/* disable kernel mode cache */
	mfc0	t0, CP0_CONFIG
	and	t0, ~0x7
	ori	t0, 0x2
	mtc0	t0, CP0_CONFIG

	/* set up stack */
	li	sp, 0x80400000

	li	t0,0x80400000
	sw	t0,mCONTEXT

	/* jump to main */
	jal	main

loop:
	j	loop
	nop
END(_start)
```

### 初次赋值为boot_pgdir基地址

并在pmap.s里的mips_vm_init()出现

```c
extern char end[];
extern int mCONTEXT;

Pde *pgdir;
u_int n;

pgdir = alloc(BY2PG, BY2PG, 1);
printf("to memory %x for struct page directory.\n", freemem);
mCONTEXT = (int)pgdir;  // 这里赋值也是boot_pgdir基地址 0x8040 1000
boot_pgdir = pgdir;
```

### 赋值为当前进程页目录基地址

最为常用的是在env_asm.s的lcontext宏函数里面出现，这是在env.c的env_run里设置全局变量mCONTEXT为当前进程页目录地址。

```asm
LEAF(lcontext)
		.extern	mCONTEXT
		sw		a0,mCONTEXT
		jr	ra
		nop
END(lcontext)
```



```c
/* Step 3: 设置全局变量mCONTEXT为当前进程页目录地址，这个值将在TLB重填时用到 */
lcontext((u_int)(e->env_pgdir));
```

### 在TLB重填时发挥作用

然后是具体体现 **在TLB重填时发挥作用**——genex.S中的 do_refill 宏函数。

具体解析参考上期甜点。
