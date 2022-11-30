# FileSysLab

这一章是文件系统的相关章节，主要的内容想复习也最好是看源代码，辅以书本。

## Large files ([moderate](https://pdos.csail.mit.edu/6.828/2022/labs/guidance.html))

In this assignment you'll increase the maximum size of an xv6 file. Currently xv6 files are limited to 268 blocks, or 268*BSIZE bytes (BSIZE is 1024 in xv6). This limit comes from the fact that an xv6 inode contains 12 "direct" block numbers and one "singly-indirect" block number, which refers to a block that holds up to 256 more block numbers, for a total of 12+256=268 blocks.

这个小Lab说实话就是实现inode的二级间接块（当时读课本的时候我还在纳闷怎么没有2级块），是很基础的文件系统知识，对于笔者复习来说一张图应该足够了，这也是书本上对于inode的阐述结构图：

![image-20221130202002659](C:\Users\LJX\AppData\Roaming\Typora\typora-user-images\image-20221130202002659.png)

代码上，我们首先得实现bmap函数，其完成的是对某个inode的第某个块的查找，如果该块没有，那么就去硬盘上分配，也就是调用balloc：

先来看看一些宏定义：

```c
#define NDIRECT 11
#define NDDIRECT NDIRECT+1
#define OneBlkEtyNum (BSIZE / sizeof(uint))  //每个块的地址条目大小 one block entry number
#define NINDIRECT OneBlkEtyNum					//一级间接块
#define NDINDIRECT (BSIZE*NINDIRECT) / sizeof(uint)	//二级间接块
#define MAXFILE (NDIRECT + NINDIRECT + NDINDIRECT)		//一个inode所能达到的总文件块数
```



```c
static uint
bmap(struct inode *ip, uint bn)
{
  uint addr, *a;
  struct buf *bp,*dbp;
  uint *b;
 uint outorder,inorder;
  if(bn < NDIRECT){
  ......
    return addr;
  }
  bn-=NINDIRECT;
  
  if(bn<NDINDIRECT)
  {
     if((addr = ip->addrs[NDDIRECT]) == 0){   //inode层级的地址条目
      addr = balloc(ip->dev);
      if(addr == 0)
        return 0;
      ip->addrs[NDDIRECT] = addr;
    }
    outorder=bn/OneBlkEtyNum;    //外层的，对于间接引导块的标号
      inorder=bn%OneBlkEtyNum;	//找到某一块后，在该块内，对于其中存放的某一个inode地址的标号
      bp = bread(ip->dev, addr);
      a = (uint*)bp->data;
      if((addr=a[outorder])==0)				//一级间接地址条目
      {
        addr = balloc(ip->dev);
      if(addr == 0)
        return 0;
      a[outorder] = addr;
      }
      dbp=bread(ip->dev,addr);
      b=(uint*)dbp->data;
      if((addr=b[inorder])==0)					//二级间接地址条目
      {
        addr = balloc(ip->dev);
      if(addr){
        b[inorder] = addr;
        log_write(bp);
         log_write(dbp);
      }
  }
   brelse(bp);
    brelse(dbp);
  return addr;
  }
  panic("bmap: out of range");
}
```

同时，我们在清除inode时，也要对考虑到二级间接块的存在，同时根据题目提示，我们得修改itrunc（）函数：

```c
void
itrunc(struct inode *ip)
{
  int i, j,m;
  struct buf *bp,*dbp;
  uint *a,*b;

  for(i = 0; i < NDIRECT; i++){
 		......

   if(ip->addrs[NDDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
      if(a[j])
      {
          dbp=bread(ip->dev,a[j]);
          b=(uint*)dbp->data;
          for(m=0;m<OneBlkEtyNum;m++)
          {
            if(b[m])
              bfree(ip->dev,b[m]);  //从内向外清理，首先释放最内部块，即二级间接块
          }
            brelse(dbp);
            bfree(ip->dev, a[j]);		//释放完一级间接块指向的所有二级间接块后，再释放一级间接块
      }
    }
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDDIRECT]);		//最后将整个256*256存在与inode上的地址条目指向的块释放
    ip->addrs[NDDIRECT] = 0;
  }

  ip->size = 0;
  iupdate(ip);
}
```



## Symbolic links ([moderate](https://pdos.csail.mit.edu/6.828/2022/labs/guidance.html))

**In this exercise you will add symbolic links to xv6. Symbolic links (or soft links) refer to a linked file by pathname; when a symbolic link is opened, the kernel follows the link to the referred file. Symbolic links resembles hard links, but hard links are restricted to pointing to file on the same disk, while symbolic links can cross disk devices. Although xv6 doesn't support multiple devices, implementing this system call is a good exercise to understand how pathname lookup works.**

在本练习中，您将添加在xv6中添加符号链接。符号链接（或软链接）指具有路径名的链接文件；当打开符号链接时，内核会遵循指向引用文件的链接。符号链接类似于硬链接，但硬链接仅限于指向同一磁盘上的文件，而符号链接可以跨磁盘设备。虽然xv6不支持多个设备，但实现这个系统调用是理解路径名查找是如何工作的一个很好的练习。

You will implement the `symlink(char *target, char *path)` system call, which creates a new symbolic link at path that refers to file named by target. For further information, see the man page symlink. To test, add symlinktest to the Makefile and run it. Your solution is complete when the tests produce the following output (including usertests succeeding).

您将实现`symlink（char*target，char*path）`系统调用，它将在由target命名的引用文件的路径上创建一个新的符号链接。

**Hints:**

- First, create a new system call number for symlink, add an entry to user/usys.pl, user/user.h, and implement an empty sys_symlink in kernel/sysfile.c.
- Add a new file type (`T_SYMLINK`) to kernel/stat.h to represent a symbolic link.
- Add a new flag to kernel/fcntl.h, (`O_NOFOLLOW`), that can be used with the `open` system call. Note that flags passed to `open` are combined using a bitwise OR operator, so your new flag should not overlap with any existing flags. This will let you compile user/symlinktest.c once you add it to the Makefile.
- Implement the `symlink(target, path)` system call to create a new symbolic link at path that refers to target. Note that target does not need to exist for the system call to succeed. You will need to choose somewhere to store the target path of a symbolic link, for example, in the inode's data blocks. `symlink` should return an integer representing success (0) or failure (-1) similar to `link` and `unlink`.
- **Modify the `open` system call to handle the case where the path refers to a symbolic link. If the file does not exist, `open` must fail. When a process specifies `O_NOFOLLOW` in the flags to `open`, `open` should open the symlink (and not follow the symbolic link).**
- If the linked file is also a symbolic link, you must recursively follow it until a non-link file is reached. If the links form a cycle, you must return an error code. You may approximate this by returning an error code if the depth of links reaches some threshold (e.g., 10).
- Other system calls (e.g., link and unlink) must not follow symbolic links; these system calls operate on the symbolic link itself.
- You do not have to handle symbolic links to directories for this lab.

根据提示，既然我们要写一个syscall,那么我们首先得把一系列准备工作写好，比如加上其对应对的syscall号。在相应的文件添加该函数等等..,这个就不过多阐述了，hints中也有提到。

而题目要求的软连接即是让一个path（路径）指向inode中的某一个块，而这个块中装有一个地址，再用这个块去寻找下一个inode，直到某一个inode被设置为不是软连接，从而找到真正需要的块：

![image-20221130205445866](C:\Users\LJX\AppData\Roaming\Typora\typora-user-images\image-20221130205445866.png)

而我们要实现的symlink就是一个生产软链接inode的函数，题目中说，这个目的地址(target)有没有意义不重要，不由该symlink函数关心，因此我们达到能将目的地址写入inode这个目的就好了。

但我们发现想生成一个inode节点的函数，可以调用ialloc函数，但其不能为inode节点的每个地址条目分配空闲块，而balloc又是一个static函数，这让跨文件的函数调用成为了不可能。因此，我们再同样的sysfile中找到create()函数可以担此重任。

同时对于写入，从路径得到Inode节点，读出等一系列操作，其都有对应的静态内部函数，和我们需要去寻找的对应的外部接口函数，symlink函数内容如下:

```c
uint64
sys_symlink(void)
{
  char target[MAXPATH], path[MAXPATH];

  struct inode *ip;

  if(argstr(0, target, MAXPATH) < 0 || argstr(1, path, MAXPATH) < 0)  //先拿到2个参数，target和path
    return -1; 

  if (namei(path) != 0) {				//path不能是已存在inode，这里做出判断
    return -1;
  }

  begin_op();						//因为我们要写入数据到硬盘，因此我们要考虑到log这一层，而begin_op()，end_op()这些函数都是log层的函数
    								//而此处的begin_op就是确定logging system没有正在提交commit，外面才能进行写入，具体请查看书籍的log层
  if ((ip = create(path, T_SYMLINK, 0, 0)) == 0) {		//这里外面创造一个新inode
     iunlockput(ip);						//需要注意，create()函数返回的是一个被ip.lock锁住的inode，因此这里需要解锁，在写入之后，我们    											//不再需要该节点，因此我们执行iput减少对该inode的一次引用(这里是ref,即进程对其的引用)
    end_op();								//log层函数
    return -1;
  }

  if (writei(ip, 0, (uint64)target, 0, MAXPATH) < 0) {		//这里我们写入target
    iupdate(ip);									//写入到了缓存过后，我们得把内容更新到硬盘中
    iunlockput(ip);									//不用该块了，我们释放
    end_op();									//所谓的写入硬盘其实都是写入到log层中，只有end_op会执行真正的写入到硬盘对应位置的操作
    return -1;
  }
  iunlockput(ip);
  end_op();

  return 0;
}
```

下面是iupdate函数的说明：

```c
// Copy a modified in-memory inode to disk.
// Must be called after every change to an ip->xxx field
// that lives on disk.
// Caller must hold ip->lock.
iupdate(struct inode *ip)
{
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
  dip = (struct dinode*)bp->data + ip->inum%IPB;
  dip->type = ip->type;
  dip->major = ip->major;
  dip->minor = ip->minor;
  dip->nlink = ip->nlink;
  dip->size = ip->size;
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
  log_write(bp);
  brelse(bp);
}
```

但虽然说明中说是写入到硬盘中去，但是其实我们可以看到iupdate调用的其实log_write,即还是对log层进行操作,且是对log层在缓存中的缓存进行操作，而最后真正的写入硬盘是由end_op中的write_log等系列函数操作，end_op所包含的系列函数才会执行每一次的commit。

题目还要求我们修改sys_open函数，题目中hints对其是这么描述的：

- Modify the `open` system call to handle the case where **the path refers to a symbolic link**. If the file does not exist, `open` must fail. When a process specifies `O_NOFOLLOW` in the flags to `open`, `open` should open the symlink (and not follow the symbolic link).

要求我们处理被引用为软连接的路径，即，是软连接的路径。

题目中还要求当软连接过于冗余，或者考虑到出现相互互为软连接的恶意行为，这中软连接不断寻路径的方式是由迭代次数的，题目中参考性的给了10次。

其次则是O_NOFOLLOW宏，题目要求有该宏的情况下就不去迭代寻找了，而直接返回，放在函数中我们不处理就好了，代码如下：

```c
uint64
sys_open(void)
{
  char path[MAXPATH];
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
  if((n = argstr(0, path, MAXPATH)) < 0)
    return -1;

  begin_op();

  if(omode & O_CREATE){
    ip = create(path, T_FILE, 0, 0);
    if(ip == 0){
      end_op();
      return -1;
    }
  } else {
    if((ip = namei(path)) == 0){
      end_op();
      return -1;
    }
    ilock(ip);
    if(ip->type == T_DIR && omode != O_RDONLY){
      iunlockput(ip);
      end_op();
      return -1;
    }

    if (ip->type == T_SYMLINK) {
    

      if (!(omode & O_NOFOLLOW)) {
        int deep = 0;

        while (1) {
          deep++;

          if (deep == 10) {
            iunlockput(ip);
            end_op();
            return -1;
          }

          if (readi(ip, 0, (uint64)path, 0, MAXPATH) < 0) {
            iunlockput(ip);
            end_op();
            return -1;
          }
          iunlockput(ip);
          
          if ((ip = namei(path)) == 0) {
            end_op();
            return -1;
          }

          ilock(ip);
          if (ip->type != T_SYMLINK) {
            break;
          }
        }
      }
    }
  }
    ......
```

