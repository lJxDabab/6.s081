// Buffer cache.
//
// The buffer cache is a linked list of buf structures holding
// cached copies of disk block contents.  Caching disk blocks
// in memory reduces the number of disk reads and also provides
// a synchronization point for disk blocks used by multiple processes.
//
// Interface:
// * To get a buffer for a particular disk block, call bread.
// * After changing buffer data, call bwrite to write it to disk.
// * When done with the buffer, call brelse.
// * Do not use the buffer after calling brelse.
// * Only one process at a time can use a buffer,
//     so do not keep them longer than necessary.


#include "types.h"
#include "param.h"
#include "spinlock.h"
#include "sleeplock.h"
#include "riscv.h"
#include "defs.h"
#include "fs.h"
#include "buf.h"
#define NBUCKET 13

struct buf *table[NBUCKET];
struct spinlock bullock[NBUCKET];
struct {
  struct buf buf[NBUF];
  
  // Linked list of all buffers, through prev/next. 
  // Sorted by how recently the buffer was used.
  // head.next is most recent, head.prev is least.
} bcache;
struct buf conbuf[NBUCKET];

void
binit(void)
{
  struct buf *b;
  int num;
    for(num=0;num<NBUCKET;num++)
    {
      table[num]=&conbuf[num];
      table[num]->next=table[num];
       initlock(&bullock[num], "bcache");
    }
  for(b = bcache.buf,num=0; b < bcache.buf+NBUF; b++){
    initsleeplock(&b->lock, "buffer");
    b->next=table[num]->next;
    table[num]->next =b; 
    // printf("num:%d,e:%p,e->next:%p\n",num,e,e->next);
  }
}

// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
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
      for(e=table[i]->next;e!=table[i];e=e->next)
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
  for(n=0;n<NBUCKET;n++)
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

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
  if(!holdingsleep(&b->lock))
    panic("bwrite");
  virtio_disk_rw(b, 1);
}

// Release a locked buffer.
// Move to the head of the most-recently-used list.
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

void
bpin(struct buf *b) {
  acquire(&bullock[b->blockno%NBUCKET]);
  b->refcnt++;
  release(&bullock[b->blockno%NBUCKET]);
}

void
bunpin(struct buf *b) {
  acquire(&bullock[b->blockno%NBUCKET]);
  b->refcnt--;
  release(&bullock[b->blockno%NBUCKET]);
}


