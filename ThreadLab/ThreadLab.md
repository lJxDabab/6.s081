# Lab: Multithreading

## Uthread: switching between threads

In this exercise you will design the context switch mechanism for a user-level threading system, and then implement it. To get you started, your xv6 has two files user/uthread.c and user/uthread_switch.S, and a rule in the Makefile to build a uthread program. uthread.c contains most of a user-level threading package, and code for three simple test threads. The threading package is missing some of the code to create a thread and to switch between threads.

在本练习中，您将为用户级线程系统设计上下文切换机制，然后实现它。在你开始之际，xv6有给你提供了两个文件user/utled.c和user/uthread_switch.S，以及在Makefile中构建一个uthread程序的指令规则。uthread.c包含大多数用户级线程包，以及三个简单测试线程的代码。线程包缺少一些用于创建线程和在线程之间切换的代码。

Your job is to come up with a plan to create threads and save/restore registers to switch between threads, and implement that plan. When you're done, `make grade` should say that your solution passes the `uthread` test.

嘿我的老伙计，您的工作是提出一个计划来创建线程和保存/恢复寄存器，以在线程之间切换，并实现该计划。

You will need to add code to `thread_create()` and `thread_schedule()` in `user/uthread.c`, and `thread_switch` in `user/uthread_switch.S`. One goal is ensure that when `thread_schedule()` runs a given thread for the first time, the thread executes the function passed to `thread_create()`, on its own stack. Another goal is to ensure that `thread_switch` saves the registers of the thread being switched away from, restores the registers of the thread being switched to, and returns to the point in the latter thread's instructions where it last left off. You will have to decide where to save/restore registers; modifying `struct thread` to hold registers is a good plan. You'll need to add a call to `thread_switch` in `thread_schedule`; you can pass whatever arguments you need to `thread_switch`, but the intent is to switch from thread `t` to `next_thread`.

您将需要在user/uthread.c_创建thread_create()与thread_schedule()，在user/uthread_switch.S中添加thread_switch。.一个目标是确保当`thread_schedule()`第一次运行给定线程时，线程在自己的堆栈上执行传递给`thread_create()`的函数。另一个目标是确保`thread_switch`保存被切换的线程的寄存器，恢复被切换到的线程的寄存器，并返回到后一个线程指令中最后停止的位置。你必须决定在哪里保存/恢复寄存器；修改`struct thread`以保持寄存器是一个很好的计划。你需要在`thread_schedule`中添加一个调用`thread_switch`；你可以将任何你需要的参数传递到`thread_switch`，但目的是从线程`t`切换到next_thread。

- `thread_switch` needs to save/restore only the callee-save registers. Why?

  我们先来看看网上百度查到到关于caller-save register与callee-save register 的定义。

Caller-saved register(又名易失性寄存器AKA volatile registers, or call-clobbered）用于保存不需要在各个调用之间保留的临时数据。因此，如果要在过程调用后恢复该值，则调用方有责任将这些寄存器压入堆栈或将其复制到其他位置。不过，让调用销毁这些寄存器中的临时值是正常的。从被调用方的角度来看，您的函数可以自由覆盖（也就是破坏）这些寄存器，而无需保存/恢复。

Callee-saved register（又称非易失性寄存器AKA non-volatile registers, or call-preserved）用于保存应在每次调用中保留的长寿命值。

当调用者进行过程调用时，可以期望这些寄存器在被调用者返回后将保持相同的值，这使被调用者有责任在返回调用者之前保存它们并恢复它们, 还是不要碰它们。

笔者认为，在这里线程的调用中，我认为，schedule与switcher的环境是不重要的，只是中间的对前后线程切换的一个过渡，因此它们为caller-saved register，它们的环境被覆盖不会产生什么影响。而线程的切换中重要的是线程的上下文环境（比较对于每个线程，它们都有自己是连贯运行完自己代码的假象），因此它们是作为callee-saved register，它们的环境需要被保存，某种需求上说才能满足这种连贯运行完自己代码假象的要求。



而关于题目，我们先来看看**thread_schedule()**函数

```c
void 
thread_schedule(void)
{
  struct thread *t, *next_thread;

  /* Find another runnable thread. */
 ......//这段代码正如上述所说

  if (next_thread == 0) {
    printf("thread_schedule: no runnable threads\n");
    exit(-1);
  }

  if (current_thread != next_thread) {         /* switch threads?  */
    next_thread->state = RUNNING;
    t = current_thread;
    current_thread = next_thread;
    /* YOUR CODE HERE
     * Invoke thread_switch to switch from t to next_thread:
     * thread_switch(??, ??);
     */
   thread_switch((uint64)&t->thread_content,(uint64)&current_thread->thread_content);
  } else
    next_thread = 0;
}
```


在thread_schedule函数中，题目为我们做的是在线程表中找到可运行的线程（runnable），而我们需要做的是调用thread_switch（）函数，其中的两个参数在书中有提到类似函数的定义，我们可以从中找到灵感：![image-20221119021050503](C:\Users\LJX\AppData\Roaming\Typora\typora-user-images\image-20221119021050503.png)

传入的两个为每个线程保存寄存器的结构体，而题目又暗示我们可以在struct thread中添加一点东西来保存这些寄存器，因此我们可以这么做：



```c
struct content
{
  uint64 ra;
  uint64 sp;
  uint64 s0;
  uint64 s1;
  uint64 s2;
  uint64 s3;
  uint64 s4;
  uint64 s5;
  uint64 s6;
  uint64 s7;
  uint64 s8;
  uint64 s9;
  uint64 s10;
  uint64 s11;
};


struct thread {
  char       stack[STACK_SIZE]; /* the thread's stack */
  int        state;             /* FREE, RUNNING, RUNNABLE */
  struct content thread_content;
  
};
```

在线程添加了一个结构体即可解决问题。我们进入,**thread_switch()**函数：

```assembly
.text

	/*
         * save the old thread's registers,
         * restore the new thread's registers.
         */

	.globl thread_switch
thread_switch:
	/* YOUR CODE HERE */

	sd ra,0(a0)
	sd sp, 8(a0)
	sd s0, 16(a0)
	sd s1, 24(a0)
	sd s2, 32(a0)
	sd s3, 40(a0)
	sd s4, 48(a0)
	sd s5, 56(a0)
	sd s6, 64(a0)
	sd s7, 72(a0)
	sd s8, 80(a0)
	sd s9, 88(a0)
	sd s10, 96(a0)
	sd s11, 104(a0)
	ld ra,0(a1)
	ld sp, 8(a1)
	ld s0, 16(a1)
	ld s1, 24(a1)
	ld s2, 32(a1)
	ld s3, 40(a1)
	ld s4, 48(a1)
	ld s5, 56(a1)
	ld s6, 64(a1)
	ld s7, 72(a1)
	ld s8, 80(a1)
	ld s9, 88(a1)
	ld s10, 96(a1)
	ld s11, 104(a1)
	ret    /* return to ra */
```

因为线程的调用涉及寄存器的储存与复原，因此这里用汇编语言编写是个正确的选择，索性实验没有难为我们，汇编代码还是比较简单的。

该函数就是将当前线程的环境保存到它的content中，把下一个要切换的线程环境从content中复原到对应寄存器中（这样就造成了好像线程从来就是连贯、没有停止过的假象），而我们设计的thread结构体如下：

![image-20221119021849546](C:\Users\LJX\AppData\Roaming\Typora\typora-user-images\image-20221119021849546.png)

而我们传入的是content的地址，因此为图中指针所指向的位置（根据它risc-v的指令集，这些在6004_isa_reference书中有，传入的参数会依次排在a0、a1....）。因此我们在save&restore过后，进行ret，它会自动跳转到ra所在的地址，开始下一个调度器所期望运行线程的地址。

那么还有一个问题，第一个线程它的ra和sp由谁来装填呢？，这里，实验给予我们一个**thread_create()**函数，用它来进行这关键两者的初始化（真正的线程调度中肯定不止这两个寄存器的初始化，但这里应该是做了简化这样干的）

```c
void 
thread_create(void (*func)())
{
  struct thread *t;

  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
    if (t->state == FREE) break;
  }
  t->state = RUNNABLE;
  // YOUR CODE HERE
  memset(t->stack,0,STACK_SIZE);
  memset(&t->thread_content,0,sizeof(struct content));
  t->thread_content.ra=(uint64)func;
  t->thread_content.sp=(uint64)(t->stack+STACK_SIZE);
}
```

这里没有什么好说的，就是对没有运行过的线程进行初始化，原因和动机在上面也说过了，唯一需要注意到点是，栈顶是在地址高的位置，因此为

t->stack+STACK_SIZE



## Using threads ([moderate](https://pdos.csail.mit.edu/6.828/2022/labs/guidance.html))

In this assignment you will explore parallel programming with threads and locks using a hash table. You should do this assignment on a real Linux or MacOS computer (not xv6, not qemu) that has multiple cores. Most recent laptops have multicore processors.

This assignment uses the UNIX `pthread` threading library. You can find information about it from the manual page, with `man pthreads`, and you can look on the web, for example [here](https://pubs.opengroup.org/onlinepubs/007908799/xsh/pthread_mutex_lock.html), [here](https://pubs.opengroup.org/onlinepubs/007908799/xsh/pthread_mutex_init.html), and [here](https://pubs.opengroup.org/onlinepubs/007908799/xsh/pthread_create.html).

The file `notxv6/ph.c` contains a simple hash table that is correct if used from a single thread, but incorrect when used from multiple threads. In your main xv6 directory (perhaps `~/xv6-labs-2021`), type this:

```
$ make ph
$ ./ph 1
```

Note that to build `ph` the Makefile uses your OS's gcc, not the 6.S081 tools. The argument to `ph` specifies the number of threads that execute put and get operations on the the hash table. After running for a little while, `ph 1` will produce output similar to this:

```
100000 puts, 3.991 seconds, 25056 puts/second
0: 0 keys missing
100000 gets, 3.981 seconds, 25118 gets/second
```

The numbers you see may differ from this sample output by a factor of two or more, depending on how fast your computer is, whether it has multiple cores, and whether it's busy doing other things.

`ph` runs two benchmarks. First it adds lots of keys to the hash table by calling `put()`, and prints the achieved rate in puts per second. The it fetches keys from the hash table with `get()`. It prints the number keys that should have been in the hash table as a result of the puts but are missing (zero in this case), and it prints the number of gets per second it achieved.

You can tell `ph` to use its hash table from multiple threads at the same time by giving it an argument greater than one. Try `ph 2`:

```
$ ./ph 2
100000 puts, 1.885 seconds, 53044 puts/second
1: 16579 keys missing
0: 16579 keys missing
200000 gets, 4.322 seconds, 46274 gets/second
```

The first line of this `ph 2` output indicates that when two threads concurrently add entries to the hash table, they achieve a total rate of 53,044 inserts per second. That's about twice the rate of the single thread from running `ph 1`. That's an excellent "parallel speedup" of about 2x, as much as one could possibly hope for (i.e. twice as many cores yielding twice as much work per unit time).

However, the two lines saying `16579 keys missing` indicate that a large number of keys that should have been in the hash table are not there. That is, the puts were supposed to add those keys to the hash table, but something went wrong. Have a look at `notxv6/ph.c`, particularly at `put()` and `insert()`.

简单来说，该任务是对全局变量的一个保护机制，2个线程动用同一个全局变量，有一些条目的计数就不对啦！而题目的情景是，对于一个hash table来说，我要向它的索引表填充条目，而索引表是全局变量，因此导致了一些条目的丢失，我们的目标就是解决这个问题。

为了让笔者和可能的读者读到这里不会觉得迷迷糊糊，我还是介绍一下这个hash table的大体构成（笔者算法一窍不通：(   ）

```c
#define NBUCKET 5
#define NKEYS 100000
//这是整个hash table的核心变量
struct entry {
  int key;
  int value;
  struct entry *next;
};//这是一个储存键值对的基本单位
struct entry *table[NBUCKET];//这是一个指针数组，是hash talbe中的桶集
int keys[NKEYS];//这是索引，你能通过下标得到对应真正的key值,即keys[i]，它可以用来在table[]中寻找到对应的单元
```

对于**struct entry**来说，正如代码中注释所言，它是一个储存键值对的基本单位，因此包含key与value，而其对应类型的指针next，则源于hash table储存结构的需要，这就不得不提一下struct entry *table[NBUCKET] 这个指针数组了，它其实是作为整个hash table储存的核心，整个哈希表只有这个指针数组，而每一个指针，都被串起作为一个链表进行连接，而链表每一个单位，即为储存的键值对，在题目中我们可以从insert函数中可以看出：

```c
static void 
insert(int key, int value, struct entry **p, struct entry *n)
{
  struct entry *e = malloc(sizeof(struct entry));
  e->key = key;
  e->value = value;
  e->next = n;   //let table[i] point to e and e->next point to the entry what the former table[i] point to
  *p = e;
}
```

在一般的插入中，会把当前这个entry插入到链表之间，可见其结构。这里顺便解释代码块中的注释，是对应如下的参数传递：

```c
    insert(key, value, &table[i], table[i]);
```

这里是想插入一个新的entry的一种处理方式，在这种操作情况下，table[i]实际上是作为一个链表头来操作的。

而对于keys[NKEYS]来说，我们可见 NKEYS 的值非常大，题目中是吧下标的值均分给了每一个线程，然后对每一个keys[i]的值赋予random()随机化，再将这个值mod 5，达到能散布到table[i]中的0-5的大小，即bucket cnt 的大小，而bucket则可以理解为装有一系列单位的一个集合,这里表现为一个链表。

```c
int n = (int) (long) xa; // thread number
  int b = NKEYS/nthread;

  for (int i = 0; i < b; i++) {
    put(keys[b*n + i], n);
  }
..................
    //另一个函数内
    for (int i = 0; i < NKEYS; i++) {
    keys[i] = random();
  }
```

，那么知道了这个哈希表的结构过后，我们再来看看这个题目的要求：

Why are there missing keys with 2 threads, but not with 1 thread? Identify a sequence of events with 2 threads that can lead to a key being missing. Submit your sequence with a short explanation in **answers-thread.txt:**

Q:Why are there missing keys with 2 threads, but not with 1 thread? Identify a sequence of events with
 2 threads that can lead to a key being missing. Submit your sequence with a short explanation in answers-thread.txt

A:当线程a要新插入一个哈希表项时，线程a被取下，开始执行线程b，而b和a的keys的值相同，采用同一个table[i],也要新插入一个哈希表项时，这时
两者会同时在table[i]所指向的那个entry项中都写入自己的key值，因此会有一项被覆盖，或者导致信息的错乱.

To avoid this sequence of events, insert lock and unlock statements in `put` and `get` in `notxv6/ph.c` so that the number of keys missing is always 0 with two threads. The relevant pthread calls are:

```
pthread_mutex_t lock;            // declare a lock
pthread_mutex_init(&lock, NULL); // initialize the lock
pthread_mutex_lock(&lock);       // acquire lock
pthread_mutex_unlock(&lock);     // release lock
```

You're done when `make grade` says that your code passes the `ph_safe` test, which requires zero missing keys with two threads. It's OK at this point to fail the `ph_fast` test.

这里其实也非常简单，其实我们只要对table[ i ]这个全局变量上锁就好了：

```c
static 
void put(int key, int value)
{
  int i = key % NBUCKET;

  // is the key already present?
  struct entry *e = 0;
  pthread_mutex_lock(&lock[i]);   //acquire lock
  for (e = table[i]; e != 0; e = e->next) {
    if (e->key == key)
      break;
  }
  if(e){
    // update the existing key.
    e->value = value;
    pthread_mutex_unlock(&lock[i]);// here release lock 2
  } else {
    // the new is new.
    insert(key, value, &table[i], table[i]);
    pthread_mutex_unlock(&lock[i]);   //release lock

  }
//锁一定要初始化哦，这个在main函数里就已经完成了。
}
```

下一个问题：

There are situations where concurrent `put()`s have no overlap in the memory they read or write in the hash table, and thus don't need a lock to protect against each other. Can you change `ph.c` to take advantage of such situations to obtain parallel speedup for some `put()`s? Hint: how about a lock per hash bucket?

在某些情况下，并发`put（）`在哈希表中读取或写取的内存中没有重叠，因此不需要锁来相互保护。你可以改变`ph.c`利用这种情况获得一些`put（）`并行加速？提示：每个哈希桶都有一个锁怎么样？

Modify your code so that some `put` operations run in parallel while maintaining correctness. You're done when `make grade` says your code passes both the `ph_safe` and `ph_fast` tests. The `ph_fast` test requires that two threads yield at least 1.25 times as many puts/second as one thread.

题目其实都明摆着告诉你了，我们只要把锁变成一个锁数组就好了，每个桶对应一个锁，相比于单个锁，每次访问我们都把桶集给锁住，这样就能让我们在修改不同的bucket时，不会再因为全部被锁住而浪费时间在等解锁上了。其实代码在上面的代码块里也展示出来了，我也就不再赘述了。

## Barrier([moderate](https://pdos.csail.mit.edu/6.828/2022/labs/guidance.html))

在这个题目里，所有线程都会去跑多个循环，而你的目的是让所有线程都进入同一个循环后(即都是第i次),再去进行下一个循环，题目本身也很简单，可能会花点时间的可能是它给你的一些看上去意义不明，实际上是在帮助你构建的参数，还有就是wait和broadcast函数，解释还是写在题目给的代码块里吧，这里我就直接上代码了。

**In this assignment you'll implement a [barrier](http://en.wikipedia.org/wiki/Barrier_(computer_science)): a point in an application at which all participating threads must wait until all other participating threads reach that point too. You'll use pthread condition variables, which are a sequence coordination technique similar to xv6's sleep and wakeup.**

**You should do this assignment on a real computer (not xv6, not qemu).**

**The file `notxv6/barrier.c` contains a broken barrier.**

```
$ make barrier
$ ./barrier 2
barrier: notxv6/barrier.c:42: thread: Assertion `i == t' failed.
```

**The 2 specifies the number of threads that synchronize on the barrier ( `nthread` in `barrier.c`). Each thread executes a loop. In each loop iteration a thread calls `barrier()` and then sleeps for a random number of microseconds. The assert triggers, because one thread leaves the barrier before the other thread has reached the barrier. The desired behavior is that each thread blocks in `barrier()` until all `nthreads` of them have called `barrier()`.**

**Your goal is to achieve the desired barrier behavior. In addition to the lock primitives that you have seen in the `ph` assignment, you will need the following new pthread primitives; look [here](https://pubs.opengroup.org/onlinepubs/007908799/xsh/pthread_cond_wait.html) and [here](https://pubs.opengroup.org/onlinepubs/007908799/xsh/pthread_cond_broadcast.html) for details.**

```
pthread_cond_wait(&cond, &mutex);  // go to sleep on cond, releasing lock mutex, acquiring upon wake up
//wait会释放一个保护前面全局变量的互斥锁，并让该线程进入一个序列cond（比较抽象，这里就理解为一种标记或者链表的那种形式吧）中睡觉，而之所以要添加一个锁为参数，是为了释放它，而之前之所以要获得这个锁，是为了防止在其他线程在sleep之前就唤醒这个线程，我们在wait中，先添加proc->lock再释放我们传进来的锁，修改线程状态后，再释放proc这个锁，从而起到在sleep后才能wake up的作用，具体可参考书中7.6的前后
pthread_cond_broadcast(&cond);     // wake up every thread sleeping on cond
```

**Make sure your solution passes `make grade`'s `barrier` test.**

**`pthread_cond_wait` releases the `mutex` when called, and re-acquires the `mutex` before returning.**

**We have given you `barrier_init()`. Your job is to implement `barrier()` so that the panic doesn't occur. We've defined `struct barrier` for you; its fields are for your use.**

**There are two issues that complicate your task:**

- **You have to deal with a succession of barrier calls, each of which we'll call a round. `bstate.round` records the current round. You should increment `bstate.round` each time all threads have reached the barrier.**
- **即，round为线程所达到的第几次循环**
- **You have to handle the case in which one thread races around the loop before the others have exited the barrier. In particular, you are re-using the `bstate.nthread` variable from one round to the next. Make sure that a thread that leaves the barrier and races around the loop doesn't increase `bstate.nthread` while a previous round is still using it.**
- **nthread就为有多少个线程进入当前这一个round了**

**Test your code with one, two, and more than two threads.**

```c
static int nthread = 1;
static int round = 0;

struct barrier {
  pthread_mutex_t barrier_mutex;
  pthread_cond_t barrier_cond;
  int nthread;      // Number of threads that have reached this round of the barrier
  int round;     // Barrier round
} bstate;

static void
barrier_init(void)
{
  assert(pthread_mutex_init(&bstate.barrier_mutex, NULL) == 0);
  assert(pthread_cond_init(&bstate.barrier_cond, NULL) == 0);
  bstate.nthread = 0;
  bstate.round=0;
}

static void 
barrier()
{
  // YOUR CODE HERE
  //
  // Block until all threads have called barrier() and
  // then increment bstate.round.
  //
  pthread_mutex_lock(&bstate.barrier_mutex);
  if(++bstate.nthread!=nthread)
  {
  pthread_cond_wait(&bstate.barrier_cond,&bstate.barrier_mutex);
  }
  else{
  pthread_cond_broadcast(&bstate.barrier_cond);
  bstate.round++;
  bstate.nthread=0;
  }
  pthread_mutex_unlock(&bstate.barrier_mutex);
}

static void *
thread(void *xa)
{
  long n = (long) xa;
  long delay;
  int i;

  for (i = 0; i < 20000; i++) {
    int t = bstate.round;
    assert (i == t);
    barrier();
    usleep(random() % 100);
  }

  return 0;
}
```

