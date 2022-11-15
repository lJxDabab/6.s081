// Physical memory allocator, for user processes,
// kernel stacks, page-table pages,
// and pipe buffers. Allocates whole 4096-byte pages.

#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "riscv.h"
#include "defs.h"

void freerange(void *pa_start, void *pa_end);
extern char end[]; // first address after kernel.
                   // defined by kernel.ld.

struct run
{
  struct run *next;
};

struct
{
  struct spinlock lock;
  struct run *freelist;
} kmem;
uint refcntarry[(PHYSTOP-KERNBASE)/PGSIZE]={0};
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
    refcntarry[((uint64)p-KERNBASE)/PGSIZE]=1;
    kfree(p);
  }
}

// Free the page of physical memory pointed at by pa,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void kfree(void *pa)
{
  struct run *r;
  if (((uint64)pa % PGSIZE) != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
    panic("kfree");
  r = (struct run *)pa;
  // Fill with junk to catch dangling refs.
  acquire(&kmem.lock);
  
    refcntarry[((uint64)r-KERNBASE)/PGSIZE]--;
  if(refcntarry[((uint64)r-KERNBASE)/PGSIZE]!=0)
  {
    release(&kmem.lock);
      return;
  }
  memset(pa, 1, PGSIZE);
  r->next = kmem.freelist;
  kmem.freelist = r;
  release(&kmem.lock);
}

// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
  struct run *r;

  acquire(&kmem.lock);
  r = kmem.freelist;

  if (r){
    refcntarry[((uint64)r-KERNBASE)/PGSIZE]=1;
   kmem.freelist = r->next;
  }
  release(&kmem.lock);

  if (r)
    memset((char *)r, 5, PGSIZE); // fill with junk
  return (void *)r;
}
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
