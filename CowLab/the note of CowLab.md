# Copy-on-write Lab(CowLab)

**Your goal in implementing copy-on-write (COW) fork() is to defer allocating and copying physical memory pages until the copies are actually needed**, if ever.

COW fork() creates just a pagetable for the child, with PTEs for user memory pointing to the parent's physical pages. COW fork() marks all the user PTEs in both parent and child as read-only.（COW fork（）只为子进程创建一个页表，用于储存用户虚拟内存的PTEs，并指向父节点的物理页面。COW fork（）将父项和子项中的所有用户pte标记为只读的）

<img src="C:\Users\LJX\AppData\Roaming\Typora\typora-user-images\image-20221115170334798.png" alt="image-20221115170334798" style="zoom:50%;" />

 When either process tries to write one of these COW pages, the CPU will force a page fault. The kernel page-fault handler detects this case, allocates a page of physical memory for the faulting process, copies the original page into the new page, and modifies the relevant PTE in the faulting process to refer to the new page, this time with the PTE marked writeable. When the page fault handler returns, the user process will be able to write its copy of the page.（当任何一个进程试图编写这些COW页面时，CPU将强制出现页错误（pagefault）。内核页错误处理程序检测到这种情况，为报错误的进程分配一个物理内存页面，将原始页面复制到新页面中，并在页错误过程中修改相关的PTE以引用新页面，这次PTE标记为可写。当页错误处理程序返回时，用户进程将能够写入该页面的副本。）

<img src="C:\Users\LJX\AppData\Roaming\Typora\typora-user-images\image-20221115171004740.png" alt="image-20221115171004740" style="zoom:50%;" />

COW fork() makes freeing of the physical pages that implement user memory a little trickier. A given physical page may be referred to by multiple processes' page tables, and should be freed only when the last reference disappears. In a simple kernel like xv6 this bookkeeping is reasonably straightforward, but in production kernels this can be difficult to get right; see, for example, [Patching until the COWs come home](https://lwn.net/Articles/849638/).（COW fork（）使得释放实现用户内存的物理页面变得有点棘手。一个给定的物理页面可以被多个进程的页面表引用，并且只能在最后一个引用消失时被释放。在像xv6这样的简单内核中，这种记账相当简单，但在生产内核中，这可能很难正确进行；例如， [Patching until the COWs come home](https://lwn.net/Articles/849638/).

## Implement copy-on-write

您的任务是在xv6内核中实现 copy-on-write 。如果修改后的内核同时成功执行cowertest-q程序，那么就完成了。

When you are done, your kernel should pass all the tests in both cowtest and usertests -q. That is:

```
$ cowtest
simple: ok
simple: ok
three: zombie!
ok
three: zombie!
ok
three: zombie!
ok
file: ok
ALL COW TESTS PASSED
$ usertests -q
...
ALL TESTS PASSED
$
```

Here's a reasonable plan of attack.

1. Modify uvmcopy() to map the parent's physical pages into the child, instead of allocating new pages. Clear `PTE_W` in the PTEs of both child and parent for pages that have `PTE_W` set.
2. Modify usertrap() to recognize page faults. When a write page-fault occurs on a COW page that was originally writeable, allocate a new page with kalloc(), copy the old page to the new page, and install the new page in the PTE with `PTE_W` set. Pages that were originally read-only (not mapped `PTE_W`, like pages in the text segment) should remain read-only and shared between parent and child; a process that tries to write such a page should be killed.
3. Ensure that each physical page is freed when the last PTE reference to it goes away -- but not before. A good way to do this is to keep, for each physical page, a "reference count" of the number of user page tables that refer to that page. Set a page's reference count to one when `kalloc()` allocates it. Increment a page's reference count when fork causes a child to share the page, and decrement a page's count each time any process drops the page from its page table. `kfree()` should only place a page back on the free list if its reference count is zero. It's OK to to keep these counts in a fixed-size array of integers. You'll have to work out a scheme for how to index the array and how to choose its size. For example, you could index the array with the page's physical address divided by 4096, and give the array a number of elements equal to highest physical address of any page placed on the free list by `kinit()` in kalloc.c. Feel free to modify kalloc.c (e.g., `kalloc()` and `kfree()`) to maintain the reference counts.
4. Modify copyout() to use the same scheme as page faults when it encounters a COW page.

Some hints:

- It may be useful to have a way to record, for each PTE, whether it is a COW mapping. You can use the RSW (reserved for software) bits in the RISC-V PTE for this.
- `usertests -q` explores scenarios that `cowtest` does not test, so don't forget to check that all tests pass for both.
- Some helpful macros and definitions for page table flags are at the end of `kernel/riscv.h`.
- If a COW page fault occurs and there's no free memory, the process should be killed.

### 代码及思路分析

对于是否该释放一个被引用的物理页面的数组初始化（上述第2点）

所有的代码都位于kalloc.c，若其他.c文件的函数需要调用，作为外部引用函数即可，这里因为有kmem.lock现成的锁，因此放在同一个文件里才能避免对全局变量的混乱修改，起到锁的作用。

```c
uint refcntarry[(PHYSTOP-KERNBASE)/PGSIZE]={0};//数组的大小为可用的物理内存的大小
```

<img src="C:\Users\LJX\AppData\Roaming\Typora\typora-user-images\image-20221115172543147.png" alt="image-20221115172543147" style="zoom: 80%;" />

### 一、refcntarry

我们在**kinit()**函数中对refcntarry进行初始化（下文简称为计数数组），因为在kfree里要减1，因此这里初始化为1。

```c
void kinit()
{
  initlock(&kmem.lock, "kmem");
  freerange(end, (void *)PHYSTOP);
}

void freerange(void *pa_start, void *pa_end)
{
  char *p;
  p = (char *)PGROUNDUP((uint64)pa_start);
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
  {
    refcntarry[((uint64)p-KERNBASE)/PGSIZE]=1; //here the refcntarry
    kfree(p);
  }
}
```

当我们分配内存(**kalloc**)后，也要对该内存对应的技术数组单元进行置一。

```c
void *
kalloc(void)
{
  struct run *r;

  acquire(&kmem.lock);
  r = kmem.freelist;

  if (r){
    refcntarry[((uint64)r-KERNBASE)/PGSIZE]=1; //here the refcntarry
   kmem.freelist = r->next;
  }
  release(&kmem.lock);

  if (r)
    memset((char *)r, 5, PGSIZE); // fill with junk
  return (void *)r;
}
```

在**kfree()**的时候,我们要判断是否还有进程在引用该进程，若没有进程在引用（即计数数组对应单元置0），则进行释放该页，若不为零，则直接返回即可。

```c
void kfree(void *pa)
{
  struct run *r;
  if (((uint64)pa % PGSIZE) != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
    panic("kfree");
  r = (struct run *)pa;
  // Fill with junk to catch dangling refs.
  acquire(&kmem.lock);								//access the refcntarry must be with a lock
  
    refcntarry[((uint64)r-KERNBASE)/PGSIZE]--;		//here the refcntarry
  if(refcntarry[((uint64)r-KERNBASE)/PGSIZE]!=0)
  {
    release(&kmem.lock);
      return;
  }
  memset(pa, 1, PGSIZE);						//为了避免回滚，一些对物理页等重要资源有影响的操作应该放在一些存在提前返回分支的代码之后，例如此
    										  //处的对refcntarry的是否为0的判断就是一种存在返回的分支。
  r->next = kmem.freelist;
  kmem.freelist = r;
  release(&kmem.lock);
}
```

最后在**fork()**函数，进行复制物理页时，因为我们会先将子进程的虚拟地址指向父进程的物理页（即同一个页），因此父进程的对应物理页的计数数组会同样加一，对应操作计数数组的函数我们写在kalloc.c中，记为**refinc()**而在**fork()**函数中，进行复制页操作的函数即**uvmcopy()**：

```c
void
refinc(void *pa)
{
  if ((uint64)pa % PGSIZE != 0) {
    panic("refinc");
  }

  acquire(&kmem.lock);
 refcntarry[((uint64)pa-KERNBASE)/PGSIZE]++;
  release(&kmem.lock);
}
```

```c
int
uvmcopy(pagetable_t old, pagetable_t new, uint64 sz)
{
  pte_t *pte;
  uint64 pa, i;
  uint flags;

  for(i = 0; i < sz; i += PGSIZE){
  		 ......
    pa = PTE2PA(*pte);

     if((*pte)&PTE_W)
    {
      *pte=(*pte)|PTE_RSW_COW_W;
      *pte=(*pte)&(~PTE_W);
    }
    else if((*pte)&PTE_R)
    {
        *pte=(*pte)|PTE_RSW_COW_R;
    }
    // *pte=(*pte)|PTE_R;
    flags = PTE_FLAGS(*pte);
   mappages(new, i, PGSIZE, pa, flags) ;
   refinc((void *)pa);							//here the refcntarry
  }
  return 0;
}
```

### 二、指向同一个页，uvmcopy()

在进行完计数数组的操作过后，将进行最基础的，把原来的分配页的操作，即，分配一个新物理页给子进程，改为，将子进程的指向物理页的虚拟地址，指向与父进程相同的物理地址（可见最开始的草图），这个过程是在每次创建子进程的时候发生的，由fork函数调用的uvmcopy()函数执行。

题目中对这种曾被多个进程指向访问，且未被请求写入的页，我们记为COW页，为了对其进行标记，文章建议我们使用PTE中闲置的标志位——RSW位：

<img src="C:\Users\LJX\AppData\Roaming\Typora\typora-user-images\image-20221115191505733.png" alt="image-20221115191505733" style="zoom:50%;" />

这里笔者把8位置为COW页中原来可写的页，9位置为COW页中原来只读的页，两个宏在uvmcopy函数中有作用的体现。

```c
#define PTE_RSW_COW_W (1L<<8)
#define PTE_RSW_COW_R (1L<<9)
```

uvmcopy的相关代码如下：

```c
int
uvmcopy(pagetable_t old, pagetable_t new, uint64 sz)
{
  pte_t *pte;
  uint64 pa, i;
  uint flags;

  for(i = 0; i < sz; i += PGSIZE){
    		......
    pa = PTE2PA(*pte);

     if((*pte)&PTE_W)
    {
      *pte=(*pte)|PTE_RSW_COW_W;
      *pte=(*pte)&(~PTE_W);		//题目要求如果原来页可写，可以置位进行标记(PTE_RSW_COW_W)，同时必须去除PTE_W位，不然触发不了页错误（page Fault）
    }
    else if((*pte)&PTE_R)
    {
        *pte=(*pte)|PTE_RSW_COW_R;
    }
    flags = PTE_FLAGS(*pte);
   mappages(new, i, PGSIZE, pa, flags) ; 
   refinc((void *)pa);
  }
  return 0;
}
```

### 三、陷入陷阱

当我们尝试读取这样一个COW页，必定会产生页错误，因此我们接下来要修改**usertrap()**函数，

修改之前，我们要看看如何判断是Store Page Fault并且被报页错误的物理页的虚拟地址为多少：

一般来说指令会带来fault，而fault的信息往往都储存在scause寄存器里，其结构如下：

![image-20221115193752578](C:\Users\LJX\AppData\Roaming\Typora\typora-user-images\image-20221115193752578.png)

其中第一位为标志位，可以理解为整个为一个二维数组，纵向长度为2^1.

<img src="C:\Users\LJX\AppData\Roaming\Typora\typora-user-images\image-20221115193636303.png" alt="image-20221115193636303" style="zoom: 50%;" />

上表则为具体的scause所储存的信息，我们可以看到，储存页错误（及写页错误为，标记位为0，而异常代码位为15，即0xf）。

我们还需要知道，页错误所在的虚拟地址在哪里，通过翻阅，实验提供的risc-v的书籍可以看到：

<img src="C:\Users\LJX\AppData\Roaming\Typora\typora-user-images\image-20221115194330599.png" alt="image-20221115194330599" style="zoom: 67%;" />

stval寄存器保存了该信息。

下见trap.c的**usertrap()**函数：

```c
   		......
else if(r_scause()==15){
    pte_t *pte;
    while(1)
    {
      uint64 pgvaddr=r_stval();
       if (pgvaddr >= MAXVA) {
          setkilled(p);
          break;
          }
        pte=walk(p->pagetable,pgvaddr,0);
        if(!(*pte))
        {
          setkilled(p);
          break;
        }
        if(!((*pte)&PTE_V))
        {
          setkilled(p);
          break;
        }
        //上述为对一些异常条件的判断
       if((*pte)&PTE_RSW_COW_W)  		//如果是cow页且之前为可写页
        { 				
          uint64 newpgpa=(uint64)kalloc();			//我们就分配一块新的内存，该内存在kalloc时就已经被置1，并且因为该 											//进程不再引用父进程指向的物理页，因此原先的物理页对应的计数数组单元需要减一
          if(newpgpa==0)
          {
            printf("no mem enough\n");				//物理内存不够，要杀死进程
            setkilled(p);
            break;
          }
            memmove((void *)newpgpa, (void*)PGROUNDDOWN(PTE2PA(*pte)), PGSIZE);		
            kfree((void*)PTE2PA(*pte));
          uint flag=PTE_FLAGS(*pte);
          flag|=PTE_W;			
          flag&=(~PTE_RSW_COW_W);				//新页要取消该标记位，它是由页错误引起的页分配，因此不再为COW页
         (*pte)=PA2PTE(newpgpa)|flag;			//这里要注意旧页的标志位为父进程的状态，而我们需要改动的为子进程的，因此											  //父进程的标记位不变
         break;
        }
        else{
          printf("read-only page can't be writen,process killed\n"); //这里为umvcopy()之前只读的页，尝试读取该页的进程							//应该被杀死，经过后面的考虑，其实PTE_RSW_COW_R为非必要的，但是因为是闲置位，因此没有选择删除
            setkilled(p);
            break;
        }
    }
  }
else if()
{
    											......
}
```

### 四、其他一些改动（copyout）

题目还要求对copyout函数碰到COW页，也要进行同样的策略，这里不再赘述：

```c
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;
  pte_t *pte;
  while(len > 0){
   				......
    if((*pte)&PTE_RSW_COW_W)
    {
        uint64 newpgpa=(uint64)kalloc();
         if(newpgpa==0)
          {
            printf("no mem enough\n");
           return -1;
          }
         memmove((void *)newpgpa, (void*)PGROUNDDOWN(PTE2PA(*pte)), PGSIZE);
         kfree((void*)PTE2PA(*pte));
         uint flag=PTE_FLAGS(*pte);
          flag|=PTE_W;
          flag&=(~PTE_RSW_COW_W);
         (*pte)=PA2PTE(newpgpa)|flag;
    }
   					......
    len -= n;
    src += n;
    dstva = va0 + PGSIZE;
  }
  return 0;
}
```

## **结语**

笔者对于该lab的实验花了不少时间，主要错误是在将*pte当做物理地址操作与傻乎乎的把计数数组的减一单独又做了一个函数出来，该函数也只有减一的功能，而没有去判断释放的功能，多此一举地没有意识到可以将释放与对计数数组的减一都写入到kfree中，耗费了不少时间，最后还是写完啦，还是很高兴的(〃'▽'〃)。