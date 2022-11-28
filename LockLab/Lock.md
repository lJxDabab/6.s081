# LockLab

在这个实验中，您将获得重新设计代码以增加并行性的经验。在多核机器上并行性差的一个常见症状是高锁争用。改进并行性通常需要改变数据结构和锁定策略，以减少争用。您将对xv6内存分配器和块缓存这样做。

(本章节的Lab基于一个思想，即把不同公共资源分化，再对这些块进行上锁，因为这样锁阻塞的情况会有所好转，最极端的情况即每个资源都上一个锁，当然太浪费资源了)

## Memory allocator

程序 user/kalloctest 强调xv6的内存分配器：三个进程增长和缩小它们的地址空间，导致许多对于kalloc和kfree的调用。kalloc和kfree获得kmem.lock。kaletest打印（如“#test-and-set”）由于试图获取其他进程已经持有的kmem锁和其他一些锁的循环迭代次数。获取中的循环迭代次数是锁争用（contention）的粗略度量。在开始实验室之前，kalloctest测试的输出看起来与此类似：

```shell
$ kalloctest
start test1
test1 results:
--- lock kmem/bcache stats
lock: kmem: #test-and-set 83375 #acquire() 433015
lock: bcache: #test-and-set 0 #acquire() 1260
--- top 5 contended locks:
lock: kmem: #test-and-set 83375 #acquire() 433015
lock: proc: #test-and-set 23737 #acquire() 130718
lock: virtio_disk: #test-and-set 11159 #acquire() 114
lock: proc: #test-and-set 5937 #acquire() 130786
lock: proc: #test-and-set 4080 #acquire() 130786
tot= 83375
test1 FAIL
start test2
total free number of pages: 32497 (out of 32768)
.....
test2 OK
start test3
child done 1
child done 100000
test3 OK
start test2
total free number of pages: 32497 (out of 32768)
.....
test2 OK
start test3
child done 1
child done 100000
test3 OK
```

You'll likely see different counts than shown here, and a different order for the top 5 contended locks.

`acquire` maintains, for each lock, the count of calls to `acquire` for that lock, and the number of times the loop in `acquire` tried but failed to set the lock. kalloctest calls a system call that causes the kernel to print those counts for the kmem and bcache locks (which are the focus of this lab) and for the 5 most contended locks. If there is lock contention the number of `acquire` loop iterations will be large. The system call returns the sum of the number of loop iterations for the kmem and bcache locks.（在不改动的情况下，单锁的lock contention是很激烈的）

For this lab, you must use a dedicated unloaded machine with multiple cores. If you use a machine that is doing other things, the counts that kalloctest prints will be nonsense. You can use a dedicated Athena workstation, or your own laptop, but don't use a dialup machine.(必须使用多核的电脑，因为这是基于多核进行的)

The root cause of lock contention in kalloctest is that `kalloc()` has a single free list, protected by a single lock. To remove lock contention, you will have to redesign the memory allocator to avoid a single lock and list. The basic idea is to maintain a free list per CPU, each list with its own lock. Allocations and frees on different CPUs can run in parallel, because each CPU will operate on a different list. The main challenge will be to deal with the case in which one CPU's free list is empty, but another CPU's list has free memory; in that case, the one CPU must "steal" part of the other CPU's free list. Stealing may introduce lock contention, but that will hopefully be infrequent.（kalloctest测试中锁争用的根本原因是`kalloc（）`有一个自由列表，由一个锁保护。要消除锁争用，您必须重新设计内存分配器，以避免单个锁和单个列表。其基本思想是为每个CPU维护一个自由列表，**每个列表都有自己的锁**。在不同的CPU上的分配和释放可以并行运行，因为每个CPU将在不同的列表上运行。主要的挑战将是处理一个CPU的空闲列表是空的，但另一个CPU的列表有空闲内存的情况；在这种情况下，一个CPU必须“窃取”另一个CPU的空闲列表的一部分。偷窃可能会引发锁的争用，但这种情况可能很少见。）

Your job is to implement per-CPU freelists, and stealing when a CPU's free list is empty. You must give all of your locks names that start with "kmem". That is, you should call `initlock` for each of your locks, and pass a name that starts with "kmem". Run kalloctest to see if your implementation has reduced lock contention. To check that it can still allocate all of memory, run `usertests sbrkmuch`. Your output will look similar to that shown below, with much-reduced contention in total on kmem locks, although the specific numbers will differ. Make sure all tests in `usertests -q` pass. `make grade` should say that the kalloctests pass.

您的工作是实现每个CPU的空闲列表，并在CPU的空闲列表为空时进行窃取。你必须给出你所有以“kmem”开头的锁的名称。也就是说，您应该为每个锁调用`initlock`，并传递一个以“kmem”开头的名称。运行kalactest(你不管也行)，查看您的实现是否减少了锁争用。要检查它仍然可以分配所有内存，运行`用户测试sbrkmuly`。您的输出将看起来与下面所示的类似，在kmem锁上的争用总数将大大减少，尽管具体的数字将会有所不同。

Some hints:

- You can use the constant `NCPU` from kernel/param.h
- Let `freerange` give all free memory to the CPU running `freerange`.
- The function `cpuid` returns the current core number, but it's only safe to call it and use its result when interrupts are turned off. You should use `push_off()` and `pop_off()` to turn interrupts off and on.
- Have a look at the `snprintf` function in kernel/sprintf.c for string formatting ideas. **It is OK to just name all locks "kmem" though**.

这个题其实难度不高，认真读了课本的笔者（虽然笔者的英文一坨，不是很看的明白）其实在课本中看到了这种减少锁竞争的方法，即，：![image-20221128145854978](C:\Users\LJX\AppData\Roaming\Typora\typora-user-images\image-20221128145854978.png)

我上文提到的，将资源给分块话管理，应用到这里就是将公共内存资源分配给不同的CPU处理，每个CPU都自带一个锁来保护部分内存资源，这样本CPU通常只会使用本CPU所保护的内存，一定程度上缓解了锁竞争。现在我们来看题。

### 思路

首先，我们先给每个CPU配一套锁：

```c
struct {
  struct spinlock lock;
  struct run *freelist;
} kmem[NCPU];//这里是数组

```

初始化我们也进行相应的修改:

```c
void
kinit()
{
  for(int i=0;i<NCPU;i++)
  {
  initlock(&kmem[i].lock, "kmem");
  }
  freerange(end, (void*)PHYSTOP);
}
```

随后是kfree,也进行相应的修改：

```c
void
kfree(void *pa)
{
  struct run *r;
  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);

  r = (struct run*)pa;

  push_off();
  int cpunum=cpuid();		//取cpu号
  pop_off();
  acquire(&kmem[cpunum].lock);
  r->next = kmem[cpunum].freelist;  	//对每个cpu的freelist进行修改，其实一套一套的，每个函数修改都差不多
  kmem[cpunum].freelist = r;
  release(&kmem[cpunum].lock);
}
```

这里需要注意的是

push_off()与pop_off()函数他们的作用分别是禁止中断与开启中断。为什么要对中断进行操作呢？是因为如果该锁同时对中断处理函数的内容进行了保护，那么，如果在该段代码（比如这里的kfree）中得到了锁，此时进行中断，那么就产生死锁了（中断处理程序因为要获取锁而等待，但kfree又需要在中断处理函数返回后才能继续运行）。详情可以看课本的6.5节（ Locks and interrupt handlers）

最后是kalloc()函数，这里除了历程的修改，还要实现如果该CPU分配的可用空间用完了，那么就要去别的CPU核中借用的功能，实现也不复杂，代码如下：

```c
void *
kalloc(void)
{
  struct run *r;
  push_off();
  int cpunum=cpuid();
  pop_off();
  int pre=cpunum;
  acquire(&kmem[cpunum].lock);
  r = kmem[cpunum].freelist;
  if(r)
  {
    kmem[cpunum].freelist = r->next; //如果该CPU的freelist还有可用块，就直接得到
    release(&kmem[cpunum].lock);
  }
  else{
    release(&kmem[cpunum].lock);
    while((cpunum+1)%NCPU!=pre)
    {
      cpunum=(1+cpunum)%NCPU;
      acquire(&kmem[cpunum].lock);   //如果没有可用块，那就从别的CPU的freelist里拿一个块直接返回。
      r=kmem[cpunum].freelist;
      if(r)
      {
        kmem[cpunum].freelist = r->next;
        release(&kmem[cpunum].lock);
        break;
      }
       release(&kmem[cpunum].lock);
    }
  }

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
  return (void*)r;
}
```



## Buffer cache ( )

If multiple processes use the file system intensively, they will likely contend for `bcache.lock`, which protects the disk block cache in kernel/bio.c. `bcachetest` creates several processes that repeatedly read different files in order to generate contention on `bcache.lock`; its output looks like this (before you complete this lab):

如果多个进程集中使用文件系统，他们可能会争夺`bcache.lock`，它可以保护`kernel/bio.c`中的磁盘块高速缓存。

修改块高速缓存，以便在运行高速缓存测试时，该高速缓存中的所有锁的获取循环迭代次数接近于零。理想情况下，块缓存中涉及的所有锁的计数之和应该为零，但如果之和小于500也可以。修改bget和brelse，以便对高速缓存中**不同块的并发查找和释放**不太可能在锁上发生冲突（例如，不必都等待bcache.lock，实际上题目里面我把这个东西删了，至少题目里它可以是多余的）。您必须保持每个块最多可以缓存一个副本的不变性（缓存中最多只能有一个块的一个副本）。

Please give all of your locks names that start with "bcache". That is, you should call `initlock` for each of your locks, and pass a name that starts with "bcache".请给你所有的锁以bcache开头的名字。那意味着你需要调用为每一个锁调用initlock()，并且以bcache开头。

Reducing contention in the block cache is more tricky than for kalloc, because bcache buffers are truly shared among processes (and thus CPUs). For kalloc, one could eliminate most contention by giving each CPU its own allocator; that won't work for the block cache. We suggest you look up block numbers in the cache with a hash table that has a lock per hash bucket.减少块缓存中的争用比减少块kalloc更棘手，因为块缓存缓冲区是真正在进程（以及cpu）之间共享的。对于kalloc，我们可以通过给每个CPU提供自己的分配器来消除大多数争用；这对块缓存不起作用。我们建议您使用一个每个哈希桶都有一个锁的哈希表来查找缓存中的块号。（是的又是哈希表，当然这里主要用到的还是桶这个概念）

There are some circumstances in which it's OK if your solution has lock conflicts:（感觉这段没啥用，笔者反正没用上这些信息）

- When two processes concurrently use the same block number. `bcachetest` `test0` doesn't ever do this.
- When two processes concurrently miss in the cache, and need to find an unused block to replace. `bcachetest` `test0` doesn't ever do this.
- When two processes concurrently use blocks that conflict in whatever scheme you use to partition the blocks and locks; for example, if two processes use blocks whose block numbers hash to the same slot in a hash table. `bcachetest` `test0` might do this, depending on your design, but you should try to adjust your scheme's details to avoid conflicts (e.g., change the size of your hash table).

`bcachetest`'s `test1` uses more distinct blocks than there are buffers, and exercises lots of file system code paths.

Here are some hints:（可能笔者之前接触过lock的概念，hint的提示效果没有之前的好）

- Read the description of the block cache in the xv6 book (Section 8.1-8.3). （这是对文件系统底层（即硬盘、缓存和log（没见过这一层)）的介绍，当然主要还是cache这一层）
- It is OK to use a fixed number of buckets and not resize the hash table dynamically. Use a prime number of buckets (e.g., 13) to reduce the likelihood of hashing conflicts.可以使用固定数量的桶，而不是动态地调整哈希表的大小。使用素数的桶（例如，13)来减少哈希冲突的可能性。（用素数这个规律我查了一下，好像没有什么原理，只是规律）
- Searching in the hash table for a buffer and allocating an entry for that buffer when the buffer is not found must be atomic.
- 在哈希表中搜索缓冲区，并在未找到缓冲区时为该缓冲区分配条目必须是原子的。
- Remove the list of all buffers (`bcache.head` etc.) and don't implement LRU. With this change `brelse` doesn't need to acquire the bcache lock. In `bget` you can select any block that has `refcnt == 0` instead of the least-recently used one.
- 删除所有缓冲区的列表（`bcache.heade`等）并且不要实现LRU。有了这个变化，`brelse`不需要获取高速缓存锁。在`bget`中，您可以选择任何具有`refcnt==0`的块，而不是最近使用过的最少的块。
- You probably won't be able to atomically check for a cached buf and (if not cached) find an unused buf; you will likely have to drop all locks and start from scratch if the buffer isn't in the cache. It is OK to serialize finding an unused buf in `bget` (i.e., the part of `bget` that selects a buffer to re-use when a lookup misses in the cache).
- 您可能无法原子检查缓存的buf和（如果没有缓存）找到未使用的buf；如果缓冲区（buf）不在缓存中，您可能不得不删除所有锁并从头开始。在`bget`中序列化查找一个未使用的buf是可以接受的（即，`bget`的一部分，它在缓存中查找失败时选择一个缓冲区来重复使用）。(没读懂这段话什么意思，感觉也没什么用)
- Your solution might need to hold two locks in some cases; for example, during eviction you may need to hold the bcache lock and a lock per bucket. Make sure you avoid deadlock.
- 在某些情况下，您的解决方案可能需要持有两个锁；例如，在驱逐期间，您可能需要持有高速缓存锁和每个桶的一个锁。请确保您避免了死锁。
- When replacing a block, you might move a `struct buf` from one bucket to another bucket, because the new block hashes to a different bucket. You might have a tricky case: the new block might hash to the same bucket as the old block. Make sure you avoid deadlock in that case.
- 替换块时，可以将`struct buf`从一个桶移动到另一个桶，因为新的块要转移到另一个桶。您可能有一个棘手的情况：新块可能会与旧块相同的桶。确保在这种情况下避免出现死锁。
- Some debugging tips: implement bucket locks but leave the global bcache.lock acquire/release at the beginning/end of bget to serialize the code. Once you are sure it is correct without race conditions, remove the global locks and deal with concurrency issues. You can also run `make CPUS=1 qemu` to test with one core.
- Use xv6's race detector to find potential races (see above how to use the race detector).

感觉提示又丑又长，我们还是来看看题解吧：

### 思路

本节对是对原代码的修改，如果想看原代码，可以点击[这里](https://github.com/mit-pdos/xv6-riscv/blob/riscv/kernel/bio.c)。

```c
#define NBUCKET 13   //桶的数量

struct buf *table[NBUCKET];   //每个桶的指针（又不熟悉的可以去看Treadlab的md）
struct spinlock bullock[NBUCKET];//每个桶配的锁
struct {
  struct buf buf[NBUF];
} bcache;  //它原本给的缓存结构，被我删的只剩下缓存buf了
struct buf conbuf[NBUCKET];//这个是对桶指针进行初始化，本身作为头节点没有什么实际意义(处于这个位置的内核程序不能调用stdlib.h,用不了malloc)
```

下面是binit函数：

```c
void
binit(void)
{
  struct buf *b;
  int num;
    for(num=0;num<NBUCKET;num++)
    {
      table[num]=&conbuf[num];
      table[num]->next=table[num];				//我对新的链表设计是让每个链表作为一个环形的单项连边，因此把头结点的next指向它本身。
       initlock(&bullock[num], "bcache");		//同样对每个桶的锁进行初始化
    }
  for(b = bcache.buf,num=0; b < bcache.buf+NBUF; b++){
    initsleeplock(&b->lock, "buffer");			//这是睡锁，当一个操作用时太长时，其他想进行该操作的进程就会进入长时间的等待，这显然是低效的，而睡  											//锁则是为此而打造的，它会让等待的进程sleep从而释放出CPU来运作别的进程原文中有这样的描述
     										 //Spin-locks are best suited to short critical sections, since waiting for them wastes 											//CPU time;sleep-locks work well for lengthy operations.		
    b->next=table[num]->next;
    table[num]->next =b; 
    // printf("num:%d,e:%p,e->next:%p\n",num,e,e->next);
  }
}
```

下面是bget函数，也是我们改动的主要内容:

```c
static struct buf*
bget(uint dev, uint blockno)
{
  struct buf *e;
  struct buf *nod=0;
  int i=blockno%NBUCKET;
  int n=0;
   // Is the block already cached?
    // acquire(&bcache.lock);
        acquire(&bullock[i]);
      for(e=table[i]->next;e!=table[i];e=e->next) 			//part 1
      {
        if(e->dev==dev && e->blockno==blockno)
        {
          e->refcnt++;
          release(&bullock[i]);
          // release(&bcache.lock);
          acquiresleep(&e->lock);
          return e;
        }
      }	
      release(&bullock[i]);
  // Not cached.
  for(n=0;n<NBUCKET;n++)								//part2&part3
  {
    acquire(&bullock[n]);
     e=table[n]->next;
   while(e!=table[n])
   {
        if(e->refcnt == 0)
         {
          if(n!=i)
          {
          acquire(&bullock[i]);
         for(nod=table[n];nod->next!=table[n];nod=nod->next)
         {
                // printf("table:%p,table->next:%p,e:%p,e->next:%p\n",table[n],table[n]->next,nod,nod->next);
                    if(nod->next->blockno==e->blockno)
                    {
                     
                      nod->next=e->next;
                      e->next=table[i]->next;
                      table[i]->next=e;
                      break;
                    }
         }
          release(&bullock[i]);
          }
          e->dev = dev;
          e->blockno = blockno;
          e->valid = 0;
          e->refcnt = 1;
          release(&bullock[n]);
          // release(&bcache.lock);
          acquiresleep(&e->lock);
          return e;
          }
           e=e->next;
    }
        //
  release(&bullock[n]);
  }
  panic("bget: no buffers");
}
```

bget()分为3部分，首先从该进程对应的桶里面去寻找有没有已经缓存的块（这里的hash算法就是简单的取余）。找到了则返回，没找到的话就在该链里面找空闲块（代码里面体现为对其的引用为0,refcnt==0），如果没找到，就去别的桶里面找，找到的节点将其数据进行修改，并且把该节点移动到原来的链上。（因为我们的blockno经过hash算法后会在原来的桶中去寻找，因此我们要迁移该节点到原来的链，避免因为没有迁移导致重复引入一个块）。



最后是brelse():

```c
void
brelse(struct buf *b)
{
  if(!holdingsleep(&b->lock))
    panic("brelse");
  releasesleep(&b->lock);
    acquire(&bullock[b->blockno%NBUCKET]);
  b->refcnt--;
  release(&bullock[b->blockno%NBUCKET]);  
}
```

brelse的主要作用就是将睡锁（sleeplock）释放，并且让该块的引用减一。

