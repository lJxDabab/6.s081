
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	91013103          	ld	sp,-1776(sp) # 80008910 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	1e7050ef          	jal	ra,800059fc <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    8000001c:	1101                	addi	sp,sp,-32
    8000001e:	ec06                	sd	ra,24(sp)
    80000020:	e822                	sd	s0,16(sp)
    80000022:	e426                	sd	s1,8(sp)
    80000024:	e04a                	sd	s2,0(sp)
    80000026:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000028:	03451793          	slli	a5,a0,0x34
    8000002c:	ebb9                	bnez	a5,80000082 <kfree+0x66>
    8000002e:	84aa                	mv	s1,a0
    80000030:	00022797          	auipc	a5,0x22
    80000034:	da078793          	addi	a5,a5,-608 # 80021dd0 <end>
    80000038:	04f56563          	bltu	a0,a5,80000082 <kfree+0x66>
    8000003c:	47c5                	li	a5,17
    8000003e:	07ee                	slli	a5,a5,0x1b
    80000040:	04f57163          	bgeu	a0,a5,80000082 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000044:	6605                	lui	a2,0x1
    80000046:	4585                	li	a1,1
    80000048:	00000097          	auipc	ra,0x0
    8000004c:	130080e7          	jalr	304(ra) # 80000178 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000050:	00009917          	auipc	s2,0x9
    80000054:	91090913          	addi	s2,s2,-1776 # 80008960 <kmem>
    80000058:	854a                	mv	a0,s2
    8000005a:	00006097          	auipc	ra,0x6
    8000005e:	3a2080e7          	jalr	930(ra) # 800063fc <acquire>
  r->next = kmem.freelist;
    80000062:	01893783          	ld	a5,24(s2)
    80000066:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000068:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    8000006c:	854a                	mv	a0,s2
    8000006e:	00006097          	auipc	ra,0x6
    80000072:	442080e7          	jalr	1090(ra) # 800064b0 <release>
}
    80000076:	60e2                	ld	ra,24(sp)
    80000078:	6442                	ld	s0,16(sp)
    8000007a:	64a2                	ld	s1,8(sp)
    8000007c:	6902                	ld	s2,0(sp)
    8000007e:	6105                	addi	sp,sp,32
    80000080:	8082                	ret
    panic("kfree");
    80000082:	00008517          	auipc	a0,0x8
    80000086:	f8e50513          	addi	a0,a0,-114 # 80008010 <etext+0x10>
    8000008a:	00006097          	auipc	ra,0x6
    8000008e:	e28080e7          	jalr	-472(ra) # 80005eb2 <panic>

0000000080000092 <freerange>:
{
    80000092:	7179                	addi	sp,sp,-48
    80000094:	f406                	sd	ra,40(sp)
    80000096:	f022                	sd	s0,32(sp)
    80000098:	ec26                	sd	s1,24(sp)
    8000009a:	e84a                	sd	s2,16(sp)
    8000009c:	e44e                	sd	s3,8(sp)
    8000009e:	e052                	sd	s4,0(sp)
    800000a0:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    800000a2:	6785                	lui	a5,0x1
    800000a4:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    800000a8:	94aa                	add	s1,s1,a0
    800000aa:	757d                	lui	a0,0xfffff
    800000ac:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800000ae:	94be                	add	s1,s1,a5
    800000b0:	0095ee63          	bltu	a1,s1,800000cc <freerange+0x3a>
    800000b4:	892e                	mv	s2,a1
    kfree(p);
    800000b6:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800000b8:	6985                	lui	s3,0x1
    kfree(p);
    800000ba:	01448533          	add	a0,s1,s4
    800000be:	00000097          	auipc	ra,0x0
    800000c2:	f5e080e7          	jalr	-162(ra) # 8000001c <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800000c6:	94ce                	add	s1,s1,s3
    800000c8:	fe9979e3          	bgeu	s2,s1,800000ba <freerange+0x28>
}
    800000cc:	70a2                	ld	ra,40(sp)
    800000ce:	7402                	ld	s0,32(sp)
    800000d0:	64e2                	ld	s1,24(sp)
    800000d2:	6942                	ld	s2,16(sp)
    800000d4:	69a2                	ld	s3,8(sp)
    800000d6:	6a02                	ld	s4,0(sp)
    800000d8:	6145                	addi	sp,sp,48
    800000da:	8082                	ret

00000000800000dc <kinit>:
{
    800000dc:	1141                	addi	sp,sp,-16
    800000de:	e406                	sd	ra,8(sp)
    800000e0:	e022                	sd	s0,0(sp)
    800000e2:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    800000e4:	00008597          	auipc	a1,0x8
    800000e8:	f3458593          	addi	a1,a1,-204 # 80008018 <etext+0x18>
    800000ec:	00009517          	auipc	a0,0x9
    800000f0:	87450513          	addi	a0,a0,-1932 # 80008960 <kmem>
    800000f4:	00006097          	auipc	ra,0x6
    800000f8:	278080e7          	jalr	632(ra) # 8000636c <initlock>
  freerange(end, (void*)PHYSTOP);
    800000fc:	45c5                	li	a1,17
    800000fe:	05ee                	slli	a1,a1,0x1b
    80000100:	00022517          	auipc	a0,0x22
    80000104:	cd050513          	addi	a0,a0,-816 # 80021dd0 <end>
    80000108:	00000097          	auipc	ra,0x0
    8000010c:	f8a080e7          	jalr	-118(ra) # 80000092 <freerange>
}
    80000110:	60a2                	ld	ra,8(sp)
    80000112:	6402                	ld	s0,0(sp)
    80000114:	0141                	addi	sp,sp,16
    80000116:	8082                	ret

0000000080000118 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000118:	1101                	addi	sp,sp,-32
    8000011a:	ec06                	sd	ra,24(sp)
    8000011c:	e822                	sd	s0,16(sp)
    8000011e:	e426                	sd	s1,8(sp)
    80000120:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000122:	00009497          	auipc	s1,0x9
    80000126:	83e48493          	addi	s1,s1,-1986 # 80008960 <kmem>
    8000012a:	8526                	mv	a0,s1
    8000012c:	00006097          	auipc	ra,0x6
    80000130:	2d0080e7          	jalr	720(ra) # 800063fc <acquire>
  r = kmem.freelist;
    80000134:	6c84                	ld	s1,24(s1)
  if(r)
    80000136:	c885                	beqz	s1,80000166 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000138:	609c                	ld	a5,0(s1)
    8000013a:	00009517          	auipc	a0,0x9
    8000013e:	82650513          	addi	a0,a0,-2010 # 80008960 <kmem>
    80000142:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000144:	00006097          	auipc	ra,0x6
    80000148:	36c080e7          	jalr	876(ra) # 800064b0 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    8000014c:	6605                	lui	a2,0x1
    8000014e:	4595                	li	a1,5
    80000150:	8526                	mv	a0,s1
    80000152:	00000097          	auipc	ra,0x0
    80000156:	026080e7          	jalr	38(ra) # 80000178 <memset>
  return (void*)r;
}
    8000015a:	8526                	mv	a0,s1
    8000015c:	60e2                	ld	ra,24(sp)
    8000015e:	6442                	ld	s0,16(sp)
    80000160:	64a2                	ld	s1,8(sp)
    80000162:	6105                	addi	sp,sp,32
    80000164:	8082                	ret
  release(&kmem.lock);
    80000166:	00008517          	auipc	a0,0x8
    8000016a:	7fa50513          	addi	a0,a0,2042 # 80008960 <kmem>
    8000016e:	00006097          	auipc	ra,0x6
    80000172:	342080e7          	jalr	834(ra) # 800064b0 <release>
  if(r)
    80000176:	b7d5                	j	8000015a <kalloc+0x42>

0000000080000178 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000178:	1141                	addi	sp,sp,-16
    8000017a:	e422                	sd	s0,8(sp)
    8000017c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    8000017e:	ce09                	beqz	a2,80000198 <memset+0x20>
    80000180:	87aa                	mv	a5,a0
    80000182:	fff6071b          	addiw	a4,a2,-1
    80000186:	1702                	slli	a4,a4,0x20
    80000188:	9301                	srli	a4,a4,0x20
    8000018a:	0705                	addi	a4,a4,1
    8000018c:	972a                	add	a4,a4,a0
    cdst[i] = c;
    8000018e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000192:	0785                	addi	a5,a5,1
    80000194:	fee79de3          	bne	a5,a4,8000018e <memset+0x16>
  }
  return dst;
}
    80000198:	6422                	ld	s0,8(sp)
    8000019a:	0141                	addi	sp,sp,16
    8000019c:	8082                	ret

000000008000019e <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    8000019e:	1141                	addi	sp,sp,-16
    800001a0:	e422                	sd	s0,8(sp)
    800001a2:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    800001a4:	ca05                	beqz	a2,800001d4 <memcmp+0x36>
    800001a6:	fff6069b          	addiw	a3,a2,-1
    800001aa:	1682                	slli	a3,a3,0x20
    800001ac:	9281                	srli	a3,a3,0x20
    800001ae:	0685                	addi	a3,a3,1
    800001b0:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    800001b2:	00054783          	lbu	a5,0(a0)
    800001b6:	0005c703          	lbu	a4,0(a1)
    800001ba:	00e79863          	bne	a5,a4,800001ca <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    800001be:	0505                	addi	a0,a0,1
    800001c0:	0585                	addi	a1,a1,1
  while(n-- > 0){
    800001c2:	fed518e3          	bne	a0,a3,800001b2 <memcmp+0x14>
  }

  return 0;
    800001c6:	4501                	li	a0,0
    800001c8:	a019                	j	800001ce <memcmp+0x30>
      return *s1 - *s2;
    800001ca:	40e7853b          	subw	a0,a5,a4
}
    800001ce:	6422                	ld	s0,8(sp)
    800001d0:	0141                	addi	sp,sp,16
    800001d2:	8082                	ret
  return 0;
    800001d4:	4501                	li	a0,0
    800001d6:	bfe5                	j	800001ce <memcmp+0x30>

00000000800001d8 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    800001d8:	1141                	addi	sp,sp,-16
    800001da:	e422                	sd	s0,8(sp)
    800001dc:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    800001de:	ca0d                	beqz	a2,80000210 <memmove+0x38>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    800001e0:	00a5f963          	bgeu	a1,a0,800001f2 <memmove+0x1a>
    800001e4:	02061693          	slli	a3,a2,0x20
    800001e8:	9281                	srli	a3,a3,0x20
    800001ea:	00d58733          	add	a4,a1,a3
    800001ee:	02e56463          	bltu	a0,a4,80000216 <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    800001f2:	fff6079b          	addiw	a5,a2,-1
    800001f6:	1782                	slli	a5,a5,0x20
    800001f8:	9381                	srli	a5,a5,0x20
    800001fa:	0785                	addi	a5,a5,1
    800001fc:	97ae                	add	a5,a5,a1
    800001fe:	872a                	mv	a4,a0
      *d++ = *s++;
    80000200:	0585                	addi	a1,a1,1
    80000202:	0705                	addi	a4,a4,1
    80000204:	fff5c683          	lbu	a3,-1(a1)
    80000208:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    8000020c:	fef59ae3          	bne	a1,a5,80000200 <memmove+0x28>

  return dst;
}
    80000210:	6422                	ld	s0,8(sp)
    80000212:	0141                	addi	sp,sp,16
    80000214:	8082                	ret
    d += n;
    80000216:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000218:	fff6079b          	addiw	a5,a2,-1
    8000021c:	1782                	slli	a5,a5,0x20
    8000021e:	9381                	srli	a5,a5,0x20
    80000220:	fff7c793          	not	a5,a5
    80000224:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000226:	177d                	addi	a4,a4,-1
    80000228:	16fd                	addi	a3,a3,-1
    8000022a:	00074603          	lbu	a2,0(a4)
    8000022e:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000232:	fef71ae3          	bne	a4,a5,80000226 <memmove+0x4e>
    80000236:	bfe9                	j	80000210 <memmove+0x38>

0000000080000238 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000238:	1141                	addi	sp,sp,-16
    8000023a:	e406                	sd	ra,8(sp)
    8000023c:	e022                	sd	s0,0(sp)
    8000023e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000240:	00000097          	auipc	ra,0x0
    80000244:	f98080e7          	jalr	-104(ra) # 800001d8 <memmove>
}
    80000248:	60a2                	ld	ra,8(sp)
    8000024a:	6402                	ld	s0,0(sp)
    8000024c:	0141                	addi	sp,sp,16
    8000024e:	8082                	ret

0000000080000250 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000250:	1141                	addi	sp,sp,-16
    80000252:	e422                	sd	s0,8(sp)
    80000254:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000256:	ce11                	beqz	a2,80000272 <strncmp+0x22>
    80000258:	00054783          	lbu	a5,0(a0)
    8000025c:	cf89                	beqz	a5,80000276 <strncmp+0x26>
    8000025e:	0005c703          	lbu	a4,0(a1)
    80000262:	00f71a63          	bne	a4,a5,80000276 <strncmp+0x26>
    n--, p++, q++;
    80000266:	367d                	addiw	a2,a2,-1
    80000268:	0505                	addi	a0,a0,1
    8000026a:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    8000026c:	f675                	bnez	a2,80000258 <strncmp+0x8>
  if(n == 0)
    return 0;
    8000026e:	4501                	li	a0,0
    80000270:	a809                	j	80000282 <strncmp+0x32>
    80000272:	4501                	li	a0,0
    80000274:	a039                	j	80000282 <strncmp+0x32>
  if(n == 0)
    80000276:	ca09                	beqz	a2,80000288 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000278:	00054503          	lbu	a0,0(a0)
    8000027c:	0005c783          	lbu	a5,0(a1)
    80000280:	9d1d                	subw	a0,a0,a5
}
    80000282:	6422                	ld	s0,8(sp)
    80000284:	0141                	addi	sp,sp,16
    80000286:	8082                	ret
    return 0;
    80000288:	4501                	li	a0,0
    8000028a:	bfe5                	j	80000282 <strncmp+0x32>

000000008000028c <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    8000028c:	1141                	addi	sp,sp,-16
    8000028e:	e422                	sd	s0,8(sp)
    80000290:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000292:	872a                	mv	a4,a0
    80000294:	8832                	mv	a6,a2
    80000296:	367d                	addiw	a2,a2,-1
    80000298:	01005963          	blez	a6,800002aa <strncpy+0x1e>
    8000029c:	0705                	addi	a4,a4,1
    8000029e:	0005c783          	lbu	a5,0(a1)
    800002a2:	fef70fa3          	sb	a5,-1(a4)
    800002a6:	0585                	addi	a1,a1,1
    800002a8:	f7f5                	bnez	a5,80000294 <strncpy+0x8>
    ;
  while(n-- > 0)
    800002aa:	00c05d63          	blez	a2,800002c4 <strncpy+0x38>
    800002ae:	86ba                	mv	a3,a4
    *s++ = 0;
    800002b0:	0685                	addi	a3,a3,1
    800002b2:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    800002b6:	fff6c793          	not	a5,a3
    800002ba:	9fb9                	addw	a5,a5,a4
    800002bc:	010787bb          	addw	a5,a5,a6
    800002c0:	fef048e3          	bgtz	a5,800002b0 <strncpy+0x24>
  return os;
}
    800002c4:	6422                	ld	s0,8(sp)
    800002c6:	0141                	addi	sp,sp,16
    800002c8:	8082                	ret

00000000800002ca <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    800002ca:	1141                	addi	sp,sp,-16
    800002cc:	e422                	sd	s0,8(sp)
    800002ce:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    800002d0:	02c05363          	blez	a2,800002f6 <safestrcpy+0x2c>
    800002d4:	fff6069b          	addiw	a3,a2,-1
    800002d8:	1682                	slli	a3,a3,0x20
    800002da:	9281                	srli	a3,a3,0x20
    800002dc:	96ae                	add	a3,a3,a1
    800002de:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    800002e0:	00d58963          	beq	a1,a3,800002f2 <safestrcpy+0x28>
    800002e4:	0585                	addi	a1,a1,1
    800002e6:	0785                	addi	a5,a5,1
    800002e8:	fff5c703          	lbu	a4,-1(a1)
    800002ec:	fee78fa3          	sb	a4,-1(a5)
    800002f0:	fb65                	bnez	a4,800002e0 <safestrcpy+0x16>
    ;
  *s = 0;
    800002f2:	00078023          	sb	zero,0(a5)
  return os;
}
    800002f6:	6422                	ld	s0,8(sp)
    800002f8:	0141                	addi	sp,sp,16
    800002fa:	8082                	ret

00000000800002fc <strlen>:

int
strlen(const char *s)
{
    800002fc:	1141                	addi	sp,sp,-16
    800002fe:	e422                	sd	s0,8(sp)
    80000300:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000302:	00054783          	lbu	a5,0(a0)
    80000306:	cf91                	beqz	a5,80000322 <strlen+0x26>
    80000308:	0505                	addi	a0,a0,1
    8000030a:	87aa                	mv	a5,a0
    8000030c:	4685                	li	a3,1
    8000030e:	9e89                	subw	a3,a3,a0
    80000310:	00f6853b          	addw	a0,a3,a5
    80000314:	0785                	addi	a5,a5,1
    80000316:	fff7c703          	lbu	a4,-1(a5)
    8000031a:	fb7d                	bnez	a4,80000310 <strlen+0x14>
    ;
  return n;
}
    8000031c:	6422                	ld	s0,8(sp)
    8000031e:	0141                	addi	sp,sp,16
    80000320:	8082                	ret
  for(n = 0; s[n]; n++)
    80000322:	4501                	li	a0,0
    80000324:	bfe5                	j	8000031c <strlen+0x20>

0000000080000326 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000326:	1141                	addi	sp,sp,-16
    80000328:	e406                	sd	ra,8(sp)
    8000032a:	e022                	sd	s0,0(sp)
    8000032c:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    8000032e:	00001097          	auipc	ra,0x1
    80000332:	bda080e7          	jalr	-1062(ra) # 80000f08 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000336:	00008717          	auipc	a4,0x8
    8000033a:	5fa70713          	addi	a4,a4,1530 # 80008930 <started>
  if(cpuid() == 0){
    8000033e:	c139                	beqz	a0,80000384 <main+0x5e>
    while(started == 0)
    80000340:	431c                	lw	a5,0(a4)
    80000342:	2781                	sext.w	a5,a5
    80000344:	dff5                	beqz	a5,80000340 <main+0x1a>
      ;
    __sync_synchronize();
    80000346:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    8000034a:	00001097          	auipc	ra,0x1
    8000034e:	bbe080e7          	jalr	-1090(ra) # 80000f08 <cpuid>
    80000352:	85aa                	mv	a1,a0
    80000354:	00008517          	auipc	a0,0x8
    80000358:	ce450513          	addi	a0,a0,-796 # 80008038 <etext+0x38>
    8000035c:	00006097          	auipc	ra,0x6
    80000360:	ba0080e7          	jalr	-1120(ra) # 80005efc <printf>
    kvminithart();    // turn on paging
    80000364:	00000097          	auipc	ra,0x0
    80000368:	0d8080e7          	jalr	216(ra) # 8000043c <kvminithart>
    trapinithart();   // install kernel trap vector
    8000036c:	00002097          	auipc	ra,0x2
    80000370:	966080e7          	jalr	-1690(ra) # 80001cd2 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000374:	00005097          	auipc	ra,0x5
    80000378:	fdc080e7          	jalr	-36(ra) # 80005350 <plicinithart>
  }

  scheduler();        
    8000037c:	00001097          	auipc	ra,0x1
    80000380:	1b0080e7          	jalr	432(ra) # 8000152c <scheduler>
    consoleinit();
    80000384:	00006097          	auipc	ra,0x6
    80000388:	a40080e7          	jalr	-1472(ra) # 80005dc4 <consoleinit>
    printfinit();
    8000038c:	00006097          	auipc	ra,0x6
    80000390:	d56080e7          	jalr	-682(ra) # 800060e2 <printfinit>
    printf("\n");
    80000394:	00008517          	auipc	a0,0x8
    80000398:	cb450513          	addi	a0,a0,-844 # 80008048 <etext+0x48>
    8000039c:	00006097          	auipc	ra,0x6
    800003a0:	b60080e7          	jalr	-1184(ra) # 80005efc <printf>
    printf("xv6 kernel is booting\n");
    800003a4:	00008517          	auipc	a0,0x8
    800003a8:	c7c50513          	addi	a0,a0,-900 # 80008020 <etext+0x20>
    800003ac:	00006097          	auipc	ra,0x6
    800003b0:	b50080e7          	jalr	-1200(ra) # 80005efc <printf>
    printf("\n");
    800003b4:	00008517          	auipc	a0,0x8
    800003b8:	c9450513          	addi	a0,a0,-876 # 80008048 <etext+0x48>
    800003bc:	00006097          	auipc	ra,0x6
    800003c0:	b40080e7          	jalr	-1216(ra) # 80005efc <printf>
    kinit();         // physical page allocator
    800003c4:	00000097          	auipc	ra,0x0
    800003c8:	d18080e7          	jalr	-744(ra) # 800000dc <kinit>
    kvminit();       // create kernel page table
    800003cc:	00000097          	auipc	ra,0x0
    800003d0:	406080e7          	jalr	1030(ra) # 800007d2 <kvminit>
    kvminithart();   // turn on paging
    800003d4:	00000097          	auipc	ra,0x0
    800003d8:	068080e7          	jalr	104(ra) # 8000043c <kvminithart>
    procinit();      // process table
    800003dc:	00001097          	auipc	ra,0x1
    800003e0:	a7a080e7          	jalr	-1414(ra) # 80000e56 <procinit>
    trapinit();      // trap vectors
    800003e4:	00002097          	auipc	ra,0x2
    800003e8:	8c6080e7          	jalr	-1850(ra) # 80001caa <trapinit>
    trapinithart();  // install kernel trap vector
    800003ec:	00002097          	auipc	ra,0x2
    800003f0:	8e6080e7          	jalr	-1818(ra) # 80001cd2 <trapinithart>
    plicinit();      // set up interrupt controller
    800003f4:	00005097          	auipc	ra,0x5
    800003f8:	f46080e7          	jalr	-186(ra) # 8000533a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    800003fc:	00005097          	auipc	ra,0x5
    80000400:	f54080e7          	jalr	-172(ra) # 80005350 <plicinithart>
    binit();         // buffer cache
    80000404:	00002097          	auipc	ra,0x2
    80000408:	0f6080e7          	jalr	246(ra) # 800024fa <binit>
    iinit();         // inode table
    8000040c:	00002097          	auipc	ra,0x2
    80000410:	79a080e7          	jalr	1946(ra) # 80002ba6 <iinit>
    fileinit();      // file table
    80000414:	00003097          	auipc	ra,0x3
    80000418:	738080e7          	jalr	1848(ra) # 80003b4c <fileinit>
    virtio_disk_init(); // emulated hard disk
    8000041c:	00005097          	auipc	ra,0x5
    80000420:	03c080e7          	jalr	60(ra) # 80005458 <virtio_disk_init>
    userinit();      // first user process
    80000424:	00001097          	auipc	ra,0x1
    80000428:	eee080e7          	jalr	-274(ra) # 80001312 <userinit>
    __sync_synchronize();
    8000042c:	0ff0000f          	fence
    started = 1;
    80000430:	4785                	li	a5,1
    80000432:	00008717          	auipc	a4,0x8
    80000436:	4ef72f23          	sw	a5,1278(a4) # 80008930 <started>
    8000043a:	b789                	j	8000037c <main+0x56>

000000008000043c <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    8000043c:	1141                	addi	sp,sp,-16
    8000043e:	e422                	sd	s0,8(sp)
    80000440:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000442:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000446:	00008797          	auipc	a5,0x8
    8000044a:	4f27b783          	ld	a5,1266(a5) # 80008938 <kernel_pagetable>
    8000044e:	83b1                	srli	a5,a5,0xc
    80000450:	577d                	li	a4,-1
    80000452:	177e                	slli	a4,a4,0x3f
    80000454:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000456:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    8000045a:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    8000045e:	6422                	ld	s0,8(sp)
    80000460:	0141                	addi	sp,sp,16
    80000462:	8082                	ret

0000000080000464 <vmprint>:
//"It should take a pagetable_t argument, and print that pagetable in the format described below"
//the function required for the second task of the lab3:page table
void
vmprint(pagetable_t pagetable)
{
    80000464:	711d                	addi	sp,sp,-96
    80000466:	ec86                	sd	ra,88(sp)
    80000468:	e8a2                	sd	s0,80(sp)
    8000046a:	e4a6                	sd	s1,72(sp)
    8000046c:	e0ca                	sd	s2,64(sp)
    8000046e:	fc4e                	sd	s3,56(sp)
    80000470:	f852                	sd	s4,48(sp)
    80000472:	f456                	sd	s5,40(sp)
    80000474:	f05a                	sd	s6,32(sp)
    80000476:	ec5e                	sd	s7,24(sp)
    80000478:	e862                	sd	s8,16(sp)
    8000047a:	e466                	sd	s9,8(sp)
    8000047c:	e06a                	sd	s10,0(sp)
    8000047e:	1080                	addi	s0,sp,96
    80000480:	89aa                	mv	s3,a0
  static int level=-1;
  pte_t pte;
  int n,cnt;
  level++;
    80000482:	00008717          	auipc	a4,0x8
    80000486:	43e70713          	addi	a4,a4,1086 # 800088c0 <level.1529>
    8000048a:	431c                	lw	a5,0(a4)
    8000048c:	2785                	addiw	a5,a5,1
    8000048e:	c31c                	sw	a5,0(a4)
    printf("page table %p\n",pagetable);
    80000490:	85aa                	mv	a1,a0
    80000492:	00008517          	auipc	a0,0x8
    80000496:	bbe50513          	addi	a0,a0,-1090 # 80008050 <etext+0x50>
    8000049a:	00006097          	auipc	ra,0x6
    8000049e:	a62080e7          	jalr	-1438(ra) # 80005efc <printf>
    for(n=0;n<512;n++)
    800004a2:	4901                	li	s2,0
    {
      pte=pagetable[n];
      if(pte&PTE_V)
      {
            for(cnt=level;cnt>=0;cnt--)
    800004a4:	00008c17          	auipc	s8,0x8
    800004a8:	41cc0c13          	addi	s8,s8,1052 # 800088c0 <level.1529>
            {
              printf(" ..");
    800004ac:	00008b17          	auipc	s6,0x8
    800004b0:	bb4b0b13          	addi	s6,s6,-1100 # 80008060 <etext+0x60>
            for(cnt=level;cnt>=0;cnt--)
    800004b4:	5afd                	li	s5,-1
            }
        printf("%d: pte %p pa %p\n",n,pte,PTE2PA(pte));
    800004b6:	00008d17          	auipc	s10,0x8
    800004ba:	bb2d0d13          	addi	s10,s10,-1102 # 80008068 <etext+0x68>
        if(level<=1)
    800004be:	4c85                	li	s9,1
    for(n=0;n<512;n++)
    800004c0:	20000b93          	li	s7,512
    800004c4:	a029                	j	800004ce <vmprint+0x6a>
    800004c6:	2905                	addiw	s2,s2,1
    800004c8:	09a1                	addi	s3,s3,8
    800004ca:	05790863          	beq	s2,s7,8000051a <vmprint+0xb6>
      pte=pagetable[n];
    800004ce:	0009ba03          	ld	s4,0(s3) # 1000 <_entry-0x7ffff000>
      if(pte&PTE_V)
    800004d2:	001a7793          	andi	a5,s4,1
    800004d6:	dbe5                	beqz	a5,800004c6 <vmprint+0x62>
            for(cnt=level;cnt>=0;cnt--)
    800004d8:	000c2483          	lw	s1,0(s8)
    800004dc:	0004ca63          	bltz	s1,800004f0 <vmprint+0x8c>
              printf(" ..");
    800004e0:	855a                	mv	a0,s6
    800004e2:	00006097          	auipc	ra,0x6
    800004e6:	a1a080e7          	jalr	-1510(ra) # 80005efc <printf>
            for(cnt=level;cnt>=0;cnt--)
    800004ea:	34fd                	addiw	s1,s1,-1
    800004ec:	ff549ae3          	bne	s1,s5,800004e0 <vmprint+0x7c>
        printf("%d: pte %p pa %p\n",n,pte,PTE2PA(pte));
    800004f0:	00aa5493          	srli	s1,s4,0xa
    800004f4:	04b2                	slli	s1,s1,0xc
    800004f6:	86a6                	mv	a3,s1
    800004f8:	8652                	mv	a2,s4
    800004fa:	85ca                	mv	a1,s2
    800004fc:	856a                	mv	a0,s10
    800004fe:	00006097          	auipc	ra,0x6
    80000502:	9fe080e7          	jalr	-1538(ra) # 80005efc <printf>
        if(level<=1)
    80000506:	000c2783          	lw	a5,0(s8)
    8000050a:	fafccee3          	blt	s9,a5,800004c6 <vmprint+0x62>
        {
        vmprint((pagetable_t)PTE2PA(pte));
    8000050e:	8526                	mv	a0,s1
    80000510:	00000097          	auipc	ra,0x0
    80000514:	f54080e7          	jalr	-172(ra) # 80000464 <vmprint>
    80000518:	b77d                	j	800004c6 <vmprint+0x62>
        }
      }
    }
    level--;
    8000051a:	00008717          	auipc	a4,0x8
    8000051e:	3a670713          	addi	a4,a4,934 # 800088c0 <level.1529>
    80000522:	431c                	lw	a5,0(a4)
    80000524:	37fd                	addiw	a5,a5,-1
    80000526:	c31c                	sw	a5,0(a4)
}
    80000528:	60e6                	ld	ra,88(sp)
    8000052a:	6446                	ld	s0,80(sp)
    8000052c:	64a6                	ld	s1,72(sp)
    8000052e:	6906                	ld	s2,64(sp)
    80000530:	79e2                	ld	s3,56(sp)
    80000532:	7a42                	ld	s4,48(sp)
    80000534:	7aa2                	ld	s5,40(sp)
    80000536:	7b02                	ld	s6,32(sp)
    80000538:	6be2                	ld	s7,24(sp)
    8000053a:	6c42                	ld	s8,16(sp)
    8000053c:	6ca2                	ld	s9,8(sp)
    8000053e:	6d02                	ld	s10,0(sp)
    80000540:	6125                	addi	sp,sp,96
    80000542:	8082                	ret

0000000080000544 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000544:	7139                	addi	sp,sp,-64
    80000546:	fc06                	sd	ra,56(sp)
    80000548:	f822                	sd	s0,48(sp)
    8000054a:	f426                	sd	s1,40(sp)
    8000054c:	f04a                	sd	s2,32(sp)
    8000054e:	ec4e                	sd	s3,24(sp)
    80000550:	e852                	sd	s4,16(sp)
    80000552:	e456                	sd	s5,8(sp)
    80000554:	e05a                	sd	s6,0(sp)
    80000556:	0080                	addi	s0,sp,64
    80000558:	84aa                	mv	s1,a0
    8000055a:	89ae                	mv	s3,a1
    8000055c:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    8000055e:	57fd                	li	a5,-1
    80000560:	83e9                	srli	a5,a5,0x1a
    80000562:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000564:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000566:	04b7f263          	bgeu	a5,a1,800005aa <walk+0x66>
    panic("walk");
    8000056a:	00008517          	auipc	a0,0x8
    8000056e:	b1650513          	addi	a0,a0,-1258 # 80008080 <etext+0x80>
    80000572:	00006097          	auipc	ra,0x6
    80000576:	940080e7          	jalr	-1728(ra) # 80005eb2 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    8000057a:	060a8663          	beqz	s5,800005e6 <walk+0xa2>
    8000057e:	00000097          	auipc	ra,0x0
    80000582:	b9a080e7          	jalr	-1126(ra) # 80000118 <kalloc>
    80000586:	84aa                	mv	s1,a0
    80000588:	c529                	beqz	a0,800005d2 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    8000058a:	6605                	lui	a2,0x1
    8000058c:	4581                	li	a1,0
    8000058e:	00000097          	auipc	ra,0x0
    80000592:	bea080e7          	jalr	-1046(ra) # 80000178 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000596:	00c4d793          	srli	a5,s1,0xc
    8000059a:	07aa                	slli	a5,a5,0xa
    8000059c:	0017e793          	ori	a5,a5,1
    800005a0:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    800005a4:	3a5d                	addiw	s4,s4,-9
    800005a6:	036a0063          	beq	s4,s6,800005c6 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    800005aa:	0149d933          	srl	s2,s3,s4
    800005ae:	1ff97913          	andi	s2,s2,511
    800005b2:	090e                	slli	s2,s2,0x3
    800005b4:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    800005b6:	00093483          	ld	s1,0(s2)
    800005ba:	0014f793          	andi	a5,s1,1
    800005be:	dfd5                	beqz	a5,8000057a <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    800005c0:	80a9                	srli	s1,s1,0xa
    800005c2:	04b2                	slli	s1,s1,0xc
    800005c4:	b7c5                	j	800005a4 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    800005c6:	00c9d513          	srli	a0,s3,0xc
    800005ca:	1ff57513          	andi	a0,a0,511
    800005ce:	050e                	slli	a0,a0,0x3
    800005d0:	9526                	add	a0,a0,s1
}
    800005d2:	70e2                	ld	ra,56(sp)
    800005d4:	7442                	ld	s0,48(sp)
    800005d6:	74a2                	ld	s1,40(sp)
    800005d8:	7902                	ld	s2,32(sp)
    800005da:	69e2                	ld	s3,24(sp)
    800005dc:	6a42                	ld	s4,16(sp)
    800005de:	6aa2                	ld	s5,8(sp)
    800005e0:	6b02                	ld	s6,0(sp)
    800005e2:	6121                	addi	sp,sp,64
    800005e4:	8082                	ret
        return 0;
    800005e6:	4501                	li	a0,0
    800005e8:	b7ed                	j	800005d2 <walk+0x8e>

00000000800005ea <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    800005ea:	57fd                	li	a5,-1
    800005ec:	83e9                	srli	a5,a5,0x1a
    800005ee:	00b7f463          	bgeu	a5,a1,800005f6 <walkaddr+0xc>
    return 0;
    800005f2:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800005f4:	8082                	ret
{
    800005f6:	1141                	addi	sp,sp,-16
    800005f8:	e406                	sd	ra,8(sp)
    800005fa:	e022                	sd	s0,0(sp)
    800005fc:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800005fe:	4601                	li	a2,0
    80000600:	00000097          	auipc	ra,0x0
    80000604:	f44080e7          	jalr	-188(ra) # 80000544 <walk>
  if(pte == 0)
    80000608:	c105                	beqz	a0,80000628 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000060a:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000060c:	0117f693          	andi	a3,a5,17
    80000610:	4745                	li	a4,17
    return 0;
    80000612:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000614:	00e68663          	beq	a3,a4,80000620 <walkaddr+0x36>
}
    80000618:	60a2                	ld	ra,8(sp)
    8000061a:	6402                	ld	s0,0(sp)
    8000061c:	0141                	addi	sp,sp,16
    8000061e:	8082                	ret
  pa = PTE2PA(*pte);
    80000620:	00a7d513          	srli	a0,a5,0xa
    80000624:	0532                	slli	a0,a0,0xc
  return pa;
    80000626:	bfcd                	j	80000618 <walkaddr+0x2e>
    return 0;
    80000628:	4501                	li	a0,0
    8000062a:	b7fd                	j	80000618 <walkaddr+0x2e>

000000008000062c <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000062c:	715d                	addi	sp,sp,-80
    8000062e:	e486                	sd	ra,72(sp)
    80000630:	e0a2                	sd	s0,64(sp)
    80000632:	fc26                	sd	s1,56(sp)
    80000634:	f84a                	sd	s2,48(sp)
    80000636:	f44e                	sd	s3,40(sp)
    80000638:	f052                	sd	s4,32(sp)
    8000063a:	ec56                	sd	s5,24(sp)
    8000063c:	e85a                	sd	s6,16(sp)
    8000063e:	e45e                	sd	s7,8(sp)
    80000640:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    80000642:	c205                	beqz	a2,80000662 <mappages+0x36>
    80000644:	8aaa                	mv	s5,a0
    80000646:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    80000648:	77fd                	lui	a5,0xfffff
    8000064a:	00f5fa33          	and	s4,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    8000064e:	15fd                	addi	a1,a1,-1
    80000650:	00c589b3          	add	s3,a1,a2
    80000654:	00f9f9b3          	and	s3,s3,a5
  a = PGROUNDDOWN(va);
    80000658:	8952                	mv	s2,s4
    8000065a:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    8000065e:	6b85                	lui	s7,0x1
    80000660:	a015                	j	80000684 <mappages+0x58>
    panic("mappages: size");
    80000662:	00008517          	auipc	a0,0x8
    80000666:	a2650513          	addi	a0,a0,-1498 # 80008088 <etext+0x88>
    8000066a:	00006097          	auipc	ra,0x6
    8000066e:	848080e7          	jalr	-1976(ra) # 80005eb2 <panic>
      panic("mappages: remap");
    80000672:	00008517          	auipc	a0,0x8
    80000676:	a2650513          	addi	a0,a0,-1498 # 80008098 <etext+0x98>
    8000067a:	00006097          	auipc	ra,0x6
    8000067e:	838080e7          	jalr	-1992(ra) # 80005eb2 <panic>
    a += PGSIZE;
    80000682:	995e                	add	s2,s2,s7
  for(;;){
    80000684:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80000688:	4605                	li	a2,1
    8000068a:	85ca                	mv	a1,s2
    8000068c:	8556                	mv	a0,s5
    8000068e:	00000097          	auipc	ra,0x0
    80000692:	eb6080e7          	jalr	-330(ra) # 80000544 <walk>
    80000696:	cd19                	beqz	a0,800006b4 <mappages+0x88>
    if(*pte & PTE_V)
    80000698:	611c                	ld	a5,0(a0)
    8000069a:	8b85                	andi	a5,a5,1
    8000069c:	fbf9                	bnez	a5,80000672 <mappages+0x46>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000069e:	80b1                	srli	s1,s1,0xc
    800006a0:	04aa                	slli	s1,s1,0xa
    800006a2:	0164e4b3          	or	s1,s1,s6
    800006a6:	0014e493          	ori	s1,s1,1
    800006aa:	e104                	sd	s1,0(a0)
    if(a == last)
    800006ac:	fd391be3          	bne	s2,s3,80000682 <mappages+0x56>
    pa += PGSIZE;
  }
  return 0;
    800006b0:	4501                	li	a0,0
    800006b2:	a011                	j	800006b6 <mappages+0x8a>
      return -1;
    800006b4:	557d                	li	a0,-1
}
    800006b6:	60a6                	ld	ra,72(sp)
    800006b8:	6406                	ld	s0,64(sp)
    800006ba:	74e2                	ld	s1,56(sp)
    800006bc:	7942                	ld	s2,48(sp)
    800006be:	79a2                	ld	s3,40(sp)
    800006c0:	7a02                	ld	s4,32(sp)
    800006c2:	6ae2                	ld	s5,24(sp)
    800006c4:	6b42                	ld	s6,16(sp)
    800006c6:	6ba2                	ld	s7,8(sp)
    800006c8:	6161                	addi	sp,sp,80
    800006ca:	8082                	ret

00000000800006cc <kvmmap>:
{
    800006cc:	1141                	addi	sp,sp,-16
    800006ce:	e406                	sd	ra,8(sp)
    800006d0:	e022                	sd	s0,0(sp)
    800006d2:	0800                	addi	s0,sp,16
    800006d4:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800006d6:	86b2                	mv	a3,a2
    800006d8:	863e                	mv	a2,a5
    800006da:	00000097          	auipc	ra,0x0
    800006de:	f52080e7          	jalr	-174(ra) # 8000062c <mappages>
    800006e2:	e509                	bnez	a0,800006ec <kvmmap+0x20>
}
    800006e4:	60a2                	ld	ra,8(sp)
    800006e6:	6402                	ld	s0,0(sp)
    800006e8:	0141                	addi	sp,sp,16
    800006ea:	8082                	ret
    panic("kvmmap");
    800006ec:	00008517          	auipc	a0,0x8
    800006f0:	9bc50513          	addi	a0,a0,-1604 # 800080a8 <etext+0xa8>
    800006f4:	00005097          	auipc	ra,0x5
    800006f8:	7be080e7          	jalr	1982(ra) # 80005eb2 <panic>

00000000800006fc <kvmmake>:
{
    800006fc:	1101                	addi	sp,sp,-32
    800006fe:	ec06                	sd	ra,24(sp)
    80000700:	e822                	sd	s0,16(sp)
    80000702:	e426                	sd	s1,8(sp)
    80000704:	e04a                	sd	s2,0(sp)
    80000706:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80000708:	00000097          	auipc	ra,0x0
    8000070c:	a10080e7          	jalr	-1520(ra) # 80000118 <kalloc>
    80000710:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80000712:	6605                	lui	a2,0x1
    80000714:	4581                	li	a1,0
    80000716:	00000097          	auipc	ra,0x0
    8000071a:	a62080e7          	jalr	-1438(ra) # 80000178 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000071e:	4719                	li	a4,6
    80000720:	6685                	lui	a3,0x1
    80000722:	10000637          	lui	a2,0x10000
    80000726:	100005b7          	lui	a1,0x10000
    8000072a:	8526                	mv	a0,s1
    8000072c:	00000097          	auipc	ra,0x0
    80000730:	fa0080e7          	jalr	-96(ra) # 800006cc <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80000734:	4719                	li	a4,6
    80000736:	6685                	lui	a3,0x1
    80000738:	10001637          	lui	a2,0x10001
    8000073c:	100015b7          	lui	a1,0x10001
    80000740:	8526                	mv	a0,s1
    80000742:	00000097          	auipc	ra,0x0
    80000746:	f8a080e7          	jalr	-118(ra) # 800006cc <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    8000074a:	4719                	li	a4,6
    8000074c:	004006b7          	lui	a3,0x400
    80000750:	0c000637          	lui	a2,0xc000
    80000754:	0c0005b7          	lui	a1,0xc000
    80000758:	8526                	mv	a0,s1
    8000075a:	00000097          	auipc	ra,0x0
    8000075e:	f72080e7          	jalr	-142(ra) # 800006cc <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80000762:	00008917          	auipc	s2,0x8
    80000766:	89e90913          	addi	s2,s2,-1890 # 80008000 <etext>
    8000076a:	4729                	li	a4,10
    8000076c:	80008697          	auipc	a3,0x80008
    80000770:	89468693          	addi	a3,a3,-1900 # 8000 <_entry-0x7fff8000>
    80000774:	4605                	li	a2,1
    80000776:	067e                	slli	a2,a2,0x1f
    80000778:	85b2                	mv	a1,a2
    8000077a:	8526                	mv	a0,s1
    8000077c:	00000097          	auipc	ra,0x0
    80000780:	f50080e7          	jalr	-176(ra) # 800006cc <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80000784:	4719                	li	a4,6
    80000786:	46c5                	li	a3,17
    80000788:	06ee                	slli	a3,a3,0x1b
    8000078a:	412686b3          	sub	a3,a3,s2
    8000078e:	864a                	mv	a2,s2
    80000790:	85ca                	mv	a1,s2
    80000792:	8526                	mv	a0,s1
    80000794:	00000097          	auipc	ra,0x0
    80000798:	f38080e7          	jalr	-200(ra) # 800006cc <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000079c:	4729                	li	a4,10
    8000079e:	6685                	lui	a3,0x1
    800007a0:	00007617          	auipc	a2,0x7
    800007a4:	86060613          	addi	a2,a2,-1952 # 80007000 <_trampoline>
    800007a8:	040005b7          	lui	a1,0x4000
    800007ac:	15fd                	addi	a1,a1,-1
    800007ae:	05b2                	slli	a1,a1,0xc
    800007b0:	8526                	mv	a0,s1
    800007b2:	00000097          	auipc	ra,0x0
    800007b6:	f1a080e7          	jalr	-230(ra) # 800006cc <kvmmap>
  proc_mapstacks(kpgtbl);
    800007ba:	8526                	mv	a0,s1
    800007bc:	00000097          	auipc	ra,0x0
    800007c0:	606080e7          	jalr	1542(ra) # 80000dc2 <proc_mapstacks>
}
    800007c4:	8526                	mv	a0,s1
    800007c6:	60e2                	ld	ra,24(sp)
    800007c8:	6442                	ld	s0,16(sp)
    800007ca:	64a2                	ld	s1,8(sp)
    800007cc:	6902                	ld	s2,0(sp)
    800007ce:	6105                	addi	sp,sp,32
    800007d0:	8082                	ret

00000000800007d2 <kvminit>:
{
    800007d2:	1141                	addi	sp,sp,-16
    800007d4:	e406                	sd	ra,8(sp)
    800007d6:	e022                	sd	s0,0(sp)
    800007d8:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800007da:	00000097          	auipc	ra,0x0
    800007de:	f22080e7          	jalr	-222(ra) # 800006fc <kvmmake>
    800007e2:	00008797          	auipc	a5,0x8
    800007e6:	14a7bb23          	sd	a0,342(a5) # 80008938 <kernel_pagetable>
}
    800007ea:	60a2                	ld	ra,8(sp)
    800007ec:	6402                	ld	s0,0(sp)
    800007ee:	0141                	addi	sp,sp,16
    800007f0:	8082                	ret

00000000800007f2 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800007f2:	715d                	addi	sp,sp,-80
    800007f4:	e486                	sd	ra,72(sp)
    800007f6:	e0a2                	sd	s0,64(sp)
    800007f8:	fc26                	sd	s1,56(sp)
    800007fa:	f84a                	sd	s2,48(sp)
    800007fc:	f44e                	sd	s3,40(sp)
    800007fe:	f052                	sd	s4,32(sp)
    80000800:	ec56                	sd	s5,24(sp)
    80000802:	e85a                	sd	s6,16(sp)
    80000804:	e45e                	sd	s7,8(sp)
    80000806:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80000808:	03459793          	slli	a5,a1,0x34
    8000080c:	e795                	bnez	a5,80000838 <uvmunmap+0x46>
    8000080e:	8a2a                	mv	s4,a0
    80000810:	892e                	mv	s2,a1
    80000812:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80000814:	0632                	slli	a2,a2,0xc
    80000816:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000081a:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000081c:	6b05                	lui	s6,0x1
    8000081e:	0735e863          	bltu	a1,s3,8000088e <uvmunmap+0x9c>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80000822:	60a6                	ld	ra,72(sp)
    80000824:	6406                	ld	s0,64(sp)
    80000826:	74e2                	ld	s1,56(sp)
    80000828:	7942                	ld	s2,48(sp)
    8000082a:	79a2                	ld	s3,40(sp)
    8000082c:	7a02                	ld	s4,32(sp)
    8000082e:	6ae2                	ld	s5,24(sp)
    80000830:	6b42                	ld	s6,16(sp)
    80000832:	6ba2                	ld	s7,8(sp)
    80000834:	6161                	addi	sp,sp,80
    80000836:	8082                	ret
    panic("uvmunmap: not aligned");
    80000838:	00008517          	auipc	a0,0x8
    8000083c:	87850513          	addi	a0,a0,-1928 # 800080b0 <etext+0xb0>
    80000840:	00005097          	auipc	ra,0x5
    80000844:	672080e7          	jalr	1650(ra) # 80005eb2 <panic>
      panic("uvmunmap: walk");
    80000848:	00008517          	auipc	a0,0x8
    8000084c:	88050513          	addi	a0,a0,-1920 # 800080c8 <etext+0xc8>
    80000850:	00005097          	auipc	ra,0x5
    80000854:	662080e7          	jalr	1634(ra) # 80005eb2 <panic>
      panic("uvmunmap: not mapped");
    80000858:	00008517          	auipc	a0,0x8
    8000085c:	88050513          	addi	a0,a0,-1920 # 800080d8 <etext+0xd8>
    80000860:	00005097          	auipc	ra,0x5
    80000864:	652080e7          	jalr	1618(ra) # 80005eb2 <panic>
      panic("uvmunmap: not a leaf");
    80000868:	00008517          	auipc	a0,0x8
    8000086c:	88850513          	addi	a0,a0,-1912 # 800080f0 <etext+0xf0>
    80000870:	00005097          	auipc	ra,0x5
    80000874:	642080e7          	jalr	1602(ra) # 80005eb2 <panic>
      uint64 pa = PTE2PA(*pte);
    80000878:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000087a:	0532                	slli	a0,a0,0xc
    8000087c:	fffff097          	auipc	ra,0xfffff
    80000880:	7a0080e7          	jalr	1952(ra) # 8000001c <kfree>
    *pte = 0;
    80000884:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80000888:	995a                	add	s2,s2,s6
    8000088a:	f9397ce3          	bgeu	s2,s3,80000822 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    8000088e:	4601                	li	a2,0
    80000890:	85ca                	mv	a1,s2
    80000892:	8552                	mv	a0,s4
    80000894:	00000097          	auipc	ra,0x0
    80000898:	cb0080e7          	jalr	-848(ra) # 80000544 <walk>
    8000089c:	84aa                	mv	s1,a0
    8000089e:	d54d                	beqz	a0,80000848 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    800008a0:	6108                	ld	a0,0(a0)
    800008a2:	00157793          	andi	a5,a0,1
    800008a6:	dbcd                	beqz	a5,80000858 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    800008a8:	3ff57793          	andi	a5,a0,1023
    800008ac:	fb778ee3          	beq	a5,s7,80000868 <uvmunmap+0x76>
    if(do_free){
    800008b0:	fc0a8ae3          	beqz	s5,80000884 <uvmunmap+0x92>
    800008b4:	b7d1                	j	80000878 <uvmunmap+0x86>

00000000800008b6 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800008b6:	1101                	addi	sp,sp,-32
    800008b8:	ec06                	sd	ra,24(sp)
    800008ba:	e822                	sd	s0,16(sp)
    800008bc:	e426                	sd	s1,8(sp)
    800008be:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800008c0:	00000097          	auipc	ra,0x0
    800008c4:	858080e7          	jalr	-1960(ra) # 80000118 <kalloc>
    800008c8:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800008ca:	c519                	beqz	a0,800008d8 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800008cc:	6605                	lui	a2,0x1
    800008ce:	4581                	li	a1,0
    800008d0:	00000097          	auipc	ra,0x0
    800008d4:	8a8080e7          	jalr	-1880(ra) # 80000178 <memset>
  return pagetable;
}
    800008d8:	8526                	mv	a0,s1
    800008da:	60e2                	ld	ra,24(sp)
    800008dc:	6442                	ld	s0,16(sp)
    800008de:	64a2                	ld	s1,8(sp)
    800008e0:	6105                	addi	sp,sp,32
    800008e2:	8082                	ret

00000000800008e4 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    800008e4:	7179                	addi	sp,sp,-48
    800008e6:	f406                	sd	ra,40(sp)
    800008e8:	f022                	sd	s0,32(sp)
    800008ea:	ec26                	sd	s1,24(sp)
    800008ec:	e84a                	sd	s2,16(sp)
    800008ee:	e44e                	sd	s3,8(sp)
    800008f0:	e052                	sd	s4,0(sp)
    800008f2:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800008f4:	6785                	lui	a5,0x1
    800008f6:	04f67863          	bgeu	a2,a5,80000946 <uvmfirst+0x62>
    800008fa:	8a2a                	mv	s4,a0
    800008fc:	89ae                	mv	s3,a1
    800008fe:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80000900:	00000097          	auipc	ra,0x0
    80000904:	818080e7          	jalr	-2024(ra) # 80000118 <kalloc>
    80000908:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000090a:	6605                	lui	a2,0x1
    8000090c:	4581                	li	a1,0
    8000090e:	00000097          	auipc	ra,0x0
    80000912:	86a080e7          	jalr	-1942(ra) # 80000178 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80000916:	4779                	li	a4,30
    80000918:	86ca                	mv	a3,s2
    8000091a:	6605                	lui	a2,0x1
    8000091c:	4581                	li	a1,0
    8000091e:	8552                	mv	a0,s4
    80000920:	00000097          	auipc	ra,0x0
    80000924:	d0c080e7          	jalr	-756(ra) # 8000062c <mappages>
  memmove(mem, src, sz);
    80000928:	8626                	mv	a2,s1
    8000092a:	85ce                	mv	a1,s3
    8000092c:	854a                	mv	a0,s2
    8000092e:	00000097          	auipc	ra,0x0
    80000932:	8aa080e7          	jalr	-1878(ra) # 800001d8 <memmove>
}
    80000936:	70a2                	ld	ra,40(sp)
    80000938:	7402                	ld	s0,32(sp)
    8000093a:	64e2                	ld	s1,24(sp)
    8000093c:	6942                	ld	s2,16(sp)
    8000093e:	69a2                	ld	s3,8(sp)
    80000940:	6a02                	ld	s4,0(sp)
    80000942:	6145                	addi	sp,sp,48
    80000944:	8082                	ret
    panic("uvmfirst: more than a page");
    80000946:	00007517          	auipc	a0,0x7
    8000094a:	7c250513          	addi	a0,a0,1986 # 80008108 <etext+0x108>
    8000094e:	00005097          	auipc	ra,0x5
    80000952:	564080e7          	jalr	1380(ra) # 80005eb2 <panic>

0000000080000956 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80000956:	1101                	addi	sp,sp,-32
    80000958:	ec06                	sd	ra,24(sp)
    8000095a:	e822                	sd	s0,16(sp)
    8000095c:	e426                	sd	s1,8(sp)
    8000095e:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80000960:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80000962:	00b67d63          	bgeu	a2,a1,8000097c <uvmdealloc+0x26>
    80000966:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80000968:	6785                	lui	a5,0x1
    8000096a:	17fd                	addi	a5,a5,-1
    8000096c:	00f60733          	add	a4,a2,a5
    80000970:	767d                	lui	a2,0xfffff
    80000972:	8f71                	and	a4,a4,a2
    80000974:	97ae                	add	a5,a5,a1
    80000976:	8ff1                	and	a5,a5,a2
    80000978:	00f76863          	bltu	a4,a5,80000988 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    8000097c:	8526                	mv	a0,s1
    8000097e:	60e2                	ld	ra,24(sp)
    80000980:	6442                	ld	s0,16(sp)
    80000982:	64a2                	ld	s1,8(sp)
    80000984:	6105                	addi	sp,sp,32
    80000986:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80000988:	8f99                	sub	a5,a5,a4
    8000098a:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000098c:	4685                	li	a3,1
    8000098e:	0007861b          	sext.w	a2,a5
    80000992:	85ba                	mv	a1,a4
    80000994:	00000097          	auipc	ra,0x0
    80000998:	e5e080e7          	jalr	-418(ra) # 800007f2 <uvmunmap>
    8000099c:	b7c5                	j	8000097c <uvmdealloc+0x26>

000000008000099e <uvmalloc>:
  if(newsz < oldsz)
    8000099e:	0ab66563          	bltu	a2,a1,80000a48 <uvmalloc+0xaa>
{
    800009a2:	7139                	addi	sp,sp,-64
    800009a4:	fc06                	sd	ra,56(sp)
    800009a6:	f822                	sd	s0,48(sp)
    800009a8:	f426                	sd	s1,40(sp)
    800009aa:	f04a                	sd	s2,32(sp)
    800009ac:	ec4e                	sd	s3,24(sp)
    800009ae:	e852                	sd	s4,16(sp)
    800009b0:	e456                	sd	s5,8(sp)
    800009b2:	e05a                	sd	s6,0(sp)
    800009b4:	0080                	addi	s0,sp,64
    800009b6:	8aaa                	mv	s5,a0
    800009b8:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800009ba:	6985                	lui	s3,0x1
    800009bc:	19fd                	addi	s3,s3,-1
    800009be:	95ce                	add	a1,a1,s3
    800009c0:	79fd                	lui	s3,0xfffff
    800009c2:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    800009c6:	08c9f363          	bgeu	s3,a2,80000a4c <uvmalloc+0xae>
    800009ca:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800009cc:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    800009d0:	fffff097          	auipc	ra,0xfffff
    800009d4:	748080e7          	jalr	1864(ra) # 80000118 <kalloc>
    800009d8:	84aa                	mv	s1,a0
    if(mem == 0){
    800009da:	c51d                	beqz	a0,80000a08 <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    800009dc:	6605                	lui	a2,0x1
    800009de:	4581                	li	a1,0
    800009e0:	fffff097          	auipc	ra,0xfffff
    800009e4:	798080e7          	jalr	1944(ra) # 80000178 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800009e8:	875a                	mv	a4,s6
    800009ea:	86a6                	mv	a3,s1
    800009ec:	6605                	lui	a2,0x1
    800009ee:	85ca                	mv	a1,s2
    800009f0:	8556                	mv	a0,s5
    800009f2:	00000097          	auipc	ra,0x0
    800009f6:	c3a080e7          	jalr	-966(ra) # 8000062c <mappages>
    800009fa:	e90d                	bnez	a0,80000a2c <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800009fc:	6785                	lui	a5,0x1
    800009fe:	993e                	add	s2,s2,a5
    80000a00:	fd4968e3          	bltu	s2,s4,800009d0 <uvmalloc+0x32>
  return newsz;
    80000a04:	8552                	mv	a0,s4
    80000a06:	a809                	j	80000a18 <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    80000a08:	864e                	mv	a2,s3
    80000a0a:	85ca                	mv	a1,s2
    80000a0c:	8556                	mv	a0,s5
    80000a0e:	00000097          	auipc	ra,0x0
    80000a12:	f48080e7          	jalr	-184(ra) # 80000956 <uvmdealloc>
      return 0;
    80000a16:	4501                	li	a0,0
}
    80000a18:	70e2                	ld	ra,56(sp)
    80000a1a:	7442                	ld	s0,48(sp)
    80000a1c:	74a2                	ld	s1,40(sp)
    80000a1e:	7902                	ld	s2,32(sp)
    80000a20:	69e2                	ld	s3,24(sp)
    80000a22:	6a42                	ld	s4,16(sp)
    80000a24:	6aa2                	ld	s5,8(sp)
    80000a26:	6b02                	ld	s6,0(sp)
    80000a28:	6121                	addi	sp,sp,64
    80000a2a:	8082                	ret
      kfree(mem);
    80000a2c:	8526                	mv	a0,s1
    80000a2e:	fffff097          	auipc	ra,0xfffff
    80000a32:	5ee080e7          	jalr	1518(ra) # 8000001c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80000a36:	864e                	mv	a2,s3
    80000a38:	85ca                	mv	a1,s2
    80000a3a:	8556                	mv	a0,s5
    80000a3c:	00000097          	auipc	ra,0x0
    80000a40:	f1a080e7          	jalr	-230(ra) # 80000956 <uvmdealloc>
      return 0;
    80000a44:	4501                	li	a0,0
    80000a46:	bfc9                	j	80000a18 <uvmalloc+0x7a>
    return oldsz;
    80000a48:	852e                	mv	a0,a1
}
    80000a4a:	8082                	ret
  return newsz;
    80000a4c:	8532                	mv	a0,a2
    80000a4e:	b7e9                	j	80000a18 <uvmalloc+0x7a>

0000000080000a50 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80000a50:	7179                	addi	sp,sp,-48
    80000a52:	f406                	sd	ra,40(sp)
    80000a54:	f022                	sd	s0,32(sp)
    80000a56:	ec26                	sd	s1,24(sp)
    80000a58:	e84a                	sd	s2,16(sp)
    80000a5a:	e44e                	sd	s3,8(sp)
    80000a5c:	e052                	sd	s4,0(sp)
    80000a5e:	1800                	addi	s0,sp,48
    80000a60:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80000a62:	84aa                	mv	s1,a0
    80000a64:	6905                	lui	s2,0x1
    80000a66:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80000a68:	4985                	li	s3,1
    80000a6a:	a821                	j	80000a82 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80000a6c:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    80000a6e:	0532                	slli	a0,a0,0xc
    80000a70:	00000097          	auipc	ra,0x0
    80000a74:	fe0080e7          	jalr	-32(ra) # 80000a50 <freewalk>
      pagetable[i] = 0;
    80000a78:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80000a7c:	04a1                	addi	s1,s1,8
    80000a7e:	03248163          	beq	s1,s2,80000aa0 <freewalk+0x50>
    pte_t pte = pagetable[i];
    80000a82:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80000a84:	00f57793          	andi	a5,a0,15
    80000a88:	ff3782e3          	beq	a5,s3,80000a6c <freewalk+0x1c>
    } else if(pte & PTE_V){
    80000a8c:	8905                	andi	a0,a0,1
    80000a8e:	d57d                	beqz	a0,80000a7c <freewalk+0x2c>
      panic("freewalk: leaf");
    80000a90:	00007517          	auipc	a0,0x7
    80000a94:	69850513          	addi	a0,a0,1688 # 80008128 <etext+0x128>
    80000a98:	00005097          	auipc	ra,0x5
    80000a9c:	41a080e7          	jalr	1050(ra) # 80005eb2 <panic>
    }
  }
  kfree((void*)pagetable);
    80000aa0:	8552                	mv	a0,s4
    80000aa2:	fffff097          	auipc	ra,0xfffff
    80000aa6:	57a080e7          	jalr	1402(ra) # 8000001c <kfree>
}
    80000aaa:	70a2                	ld	ra,40(sp)
    80000aac:	7402                	ld	s0,32(sp)
    80000aae:	64e2                	ld	s1,24(sp)
    80000ab0:	6942                	ld	s2,16(sp)
    80000ab2:	69a2                	ld	s3,8(sp)
    80000ab4:	6a02                	ld	s4,0(sp)
    80000ab6:	6145                	addi	sp,sp,48
    80000ab8:	8082                	ret

0000000080000aba <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80000aba:	1101                	addi	sp,sp,-32
    80000abc:	ec06                	sd	ra,24(sp)
    80000abe:	e822                	sd	s0,16(sp)
    80000ac0:	e426                	sd	s1,8(sp)
    80000ac2:	1000                	addi	s0,sp,32
    80000ac4:	84aa                	mv	s1,a0
  if(sz > 0)
    80000ac6:	e999                	bnez	a1,80000adc <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80000ac8:	8526                	mv	a0,s1
    80000aca:	00000097          	auipc	ra,0x0
    80000ace:	f86080e7          	jalr	-122(ra) # 80000a50 <freewalk>
}
    80000ad2:	60e2                	ld	ra,24(sp)
    80000ad4:	6442                	ld	s0,16(sp)
    80000ad6:	64a2                	ld	s1,8(sp)
    80000ad8:	6105                	addi	sp,sp,32
    80000ada:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80000adc:	6605                	lui	a2,0x1
    80000ade:	167d                	addi	a2,a2,-1
    80000ae0:	962e                	add	a2,a2,a1
    80000ae2:	4685                	li	a3,1
    80000ae4:	8231                	srli	a2,a2,0xc
    80000ae6:	4581                	li	a1,0
    80000ae8:	00000097          	auipc	ra,0x0
    80000aec:	d0a080e7          	jalr	-758(ra) # 800007f2 <uvmunmap>
    80000af0:	bfe1                	j	80000ac8 <uvmfree+0xe>

0000000080000af2 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80000af2:	c679                	beqz	a2,80000bc0 <uvmcopy+0xce>
{
    80000af4:	715d                	addi	sp,sp,-80
    80000af6:	e486                	sd	ra,72(sp)
    80000af8:	e0a2                	sd	s0,64(sp)
    80000afa:	fc26                	sd	s1,56(sp)
    80000afc:	f84a                	sd	s2,48(sp)
    80000afe:	f44e                	sd	s3,40(sp)
    80000b00:	f052                	sd	s4,32(sp)
    80000b02:	ec56                	sd	s5,24(sp)
    80000b04:	e85a                	sd	s6,16(sp)
    80000b06:	e45e                	sd	s7,8(sp)
    80000b08:	0880                	addi	s0,sp,80
    80000b0a:	8b2a                	mv	s6,a0
    80000b0c:	8aae                	mv	s5,a1
    80000b0e:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80000b10:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80000b12:	4601                	li	a2,0
    80000b14:	85ce                	mv	a1,s3
    80000b16:	855a                	mv	a0,s6
    80000b18:	00000097          	auipc	ra,0x0
    80000b1c:	a2c080e7          	jalr	-1492(ra) # 80000544 <walk>
    80000b20:	c531                	beqz	a0,80000b6c <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80000b22:	6118                	ld	a4,0(a0)
    80000b24:	00177793          	andi	a5,a4,1
    80000b28:	cbb1                	beqz	a5,80000b7c <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80000b2a:	00a75593          	srli	a1,a4,0xa
    80000b2e:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80000b32:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80000b36:	fffff097          	auipc	ra,0xfffff
    80000b3a:	5e2080e7          	jalr	1506(ra) # 80000118 <kalloc>
    80000b3e:	892a                	mv	s2,a0
    80000b40:	c939                	beqz	a0,80000b96 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80000b42:	6605                	lui	a2,0x1
    80000b44:	85de                	mv	a1,s7
    80000b46:	fffff097          	auipc	ra,0xfffff
    80000b4a:	692080e7          	jalr	1682(ra) # 800001d8 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80000b4e:	8726                	mv	a4,s1
    80000b50:	86ca                	mv	a3,s2
    80000b52:	6605                	lui	a2,0x1
    80000b54:	85ce                	mv	a1,s3
    80000b56:	8556                	mv	a0,s5
    80000b58:	00000097          	auipc	ra,0x0
    80000b5c:	ad4080e7          	jalr	-1324(ra) # 8000062c <mappages>
    80000b60:	e515                	bnez	a0,80000b8c <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    80000b62:	6785                	lui	a5,0x1
    80000b64:	99be                	add	s3,s3,a5
    80000b66:	fb49e6e3          	bltu	s3,s4,80000b12 <uvmcopy+0x20>
    80000b6a:	a081                	j	80000baa <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    80000b6c:	00007517          	auipc	a0,0x7
    80000b70:	5cc50513          	addi	a0,a0,1484 # 80008138 <etext+0x138>
    80000b74:	00005097          	auipc	ra,0x5
    80000b78:	33e080e7          	jalr	830(ra) # 80005eb2 <panic>
      panic("uvmcopy: page not present");
    80000b7c:	00007517          	auipc	a0,0x7
    80000b80:	5dc50513          	addi	a0,a0,1500 # 80008158 <etext+0x158>
    80000b84:	00005097          	auipc	ra,0x5
    80000b88:	32e080e7          	jalr	814(ra) # 80005eb2 <panic>
      kfree(mem);
    80000b8c:	854a                	mv	a0,s2
    80000b8e:	fffff097          	auipc	ra,0xfffff
    80000b92:	48e080e7          	jalr	1166(ra) # 8000001c <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80000b96:	4685                	li	a3,1
    80000b98:	00c9d613          	srli	a2,s3,0xc
    80000b9c:	4581                	li	a1,0
    80000b9e:	8556                	mv	a0,s5
    80000ba0:	00000097          	auipc	ra,0x0
    80000ba4:	c52080e7          	jalr	-942(ra) # 800007f2 <uvmunmap>
  return -1;
    80000ba8:	557d                	li	a0,-1
}
    80000baa:	60a6                	ld	ra,72(sp)
    80000bac:	6406                	ld	s0,64(sp)
    80000bae:	74e2                	ld	s1,56(sp)
    80000bb0:	7942                	ld	s2,48(sp)
    80000bb2:	79a2                	ld	s3,40(sp)
    80000bb4:	7a02                	ld	s4,32(sp)
    80000bb6:	6ae2                	ld	s5,24(sp)
    80000bb8:	6b42                	ld	s6,16(sp)
    80000bba:	6ba2                	ld	s7,8(sp)
    80000bbc:	6161                	addi	sp,sp,80
    80000bbe:	8082                	ret
  return 0;
    80000bc0:	4501                	li	a0,0
}
    80000bc2:	8082                	ret

0000000080000bc4 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80000bc4:	1141                	addi	sp,sp,-16
    80000bc6:	e406                	sd	ra,8(sp)
    80000bc8:	e022                	sd	s0,0(sp)
    80000bca:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80000bcc:	4601                	li	a2,0
    80000bce:	00000097          	auipc	ra,0x0
    80000bd2:	976080e7          	jalr	-1674(ra) # 80000544 <walk>
  if(pte == 0)
    80000bd6:	c901                	beqz	a0,80000be6 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80000bd8:	611c                	ld	a5,0(a0)
    80000bda:	9bbd                	andi	a5,a5,-17
    80000bdc:	e11c                	sd	a5,0(a0)
}
    80000bde:	60a2                	ld	ra,8(sp)
    80000be0:	6402                	ld	s0,0(sp)
    80000be2:	0141                	addi	sp,sp,16
    80000be4:	8082                	ret
    panic("uvmclear");
    80000be6:	00007517          	auipc	a0,0x7
    80000bea:	59250513          	addi	a0,a0,1426 # 80008178 <etext+0x178>
    80000bee:	00005097          	auipc	ra,0x5
    80000bf2:	2c4080e7          	jalr	708(ra) # 80005eb2 <panic>

0000000080000bf6 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80000bf6:	c6bd                	beqz	a3,80000c64 <copyout+0x6e>
{
    80000bf8:	715d                	addi	sp,sp,-80
    80000bfa:	e486                	sd	ra,72(sp)
    80000bfc:	e0a2                	sd	s0,64(sp)
    80000bfe:	fc26                	sd	s1,56(sp)
    80000c00:	f84a                	sd	s2,48(sp)
    80000c02:	f44e                	sd	s3,40(sp)
    80000c04:	f052                	sd	s4,32(sp)
    80000c06:	ec56                	sd	s5,24(sp)
    80000c08:	e85a                	sd	s6,16(sp)
    80000c0a:	e45e                	sd	s7,8(sp)
    80000c0c:	e062                	sd	s8,0(sp)
    80000c0e:	0880                	addi	s0,sp,80
    80000c10:	8b2a                	mv	s6,a0
    80000c12:	8c2e                	mv	s8,a1
    80000c14:	8a32                	mv	s4,a2
    80000c16:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80000c18:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80000c1a:	6a85                	lui	s5,0x1
    80000c1c:	a015                	j	80000c40 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80000c1e:	9562                	add	a0,a0,s8
    80000c20:	0004861b          	sext.w	a2,s1
    80000c24:	85d2                	mv	a1,s4
    80000c26:	41250533          	sub	a0,a0,s2
    80000c2a:	fffff097          	auipc	ra,0xfffff
    80000c2e:	5ae080e7          	jalr	1454(ra) # 800001d8 <memmove>

    len -= n;
    80000c32:	409989b3          	sub	s3,s3,s1
    src += n;
    80000c36:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80000c38:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80000c3c:	02098263          	beqz	s3,80000c60 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80000c40:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80000c44:	85ca                	mv	a1,s2
    80000c46:	855a                	mv	a0,s6
    80000c48:	00000097          	auipc	ra,0x0
    80000c4c:	9a2080e7          	jalr	-1630(ra) # 800005ea <walkaddr>
    if(pa0 == 0)
    80000c50:	cd01                	beqz	a0,80000c68 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80000c52:	418904b3          	sub	s1,s2,s8
    80000c56:	94d6                	add	s1,s1,s5
    if(n > len)
    80000c58:	fc99f3e3          	bgeu	s3,s1,80000c1e <copyout+0x28>
    80000c5c:	84ce                	mv	s1,s3
    80000c5e:	b7c1                	j	80000c1e <copyout+0x28>
  }
  return 0;
    80000c60:	4501                	li	a0,0
    80000c62:	a021                	j	80000c6a <copyout+0x74>
    80000c64:	4501                	li	a0,0
}
    80000c66:	8082                	ret
      return -1;
    80000c68:	557d                	li	a0,-1
}
    80000c6a:	60a6                	ld	ra,72(sp)
    80000c6c:	6406                	ld	s0,64(sp)
    80000c6e:	74e2                	ld	s1,56(sp)
    80000c70:	7942                	ld	s2,48(sp)
    80000c72:	79a2                	ld	s3,40(sp)
    80000c74:	7a02                	ld	s4,32(sp)
    80000c76:	6ae2                	ld	s5,24(sp)
    80000c78:	6b42                	ld	s6,16(sp)
    80000c7a:	6ba2                	ld	s7,8(sp)
    80000c7c:	6c02                	ld	s8,0(sp)
    80000c7e:	6161                	addi	sp,sp,80
    80000c80:	8082                	ret

0000000080000c82 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80000c82:	c6bd                	beqz	a3,80000cf0 <copyin+0x6e>
{
    80000c84:	715d                	addi	sp,sp,-80
    80000c86:	e486                	sd	ra,72(sp)
    80000c88:	e0a2                	sd	s0,64(sp)
    80000c8a:	fc26                	sd	s1,56(sp)
    80000c8c:	f84a                	sd	s2,48(sp)
    80000c8e:	f44e                	sd	s3,40(sp)
    80000c90:	f052                	sd	s4,32(sp)
    80000c92:	ec56                	sd	s5,24(sp)
    80000c94:	e85a                	sd	s6,16(sp)
    80000c96:	e45e                	sd	s7,8(sp)
    80000c98:	e062                	sd	s8,0(sp)
    80000c9a:	0880                	addi	s0,sp,80
    80000c9c:	8b2a                	mv	s6,a0
    80000c9e:	8a2e                	mv	s4,a1
    80000ca0:	8c32                	mv	s8,a2
    80000ca2:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80000ca4:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80000ca6:	6a85                	lui	s5,0x1
    80000ca8:	a015                	j	80000ccc <copyin+0x4a>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80000caa:	9562                	add	a0,a0,s8
    80000cac:	0004861b          	sext.w	a2,s1
    80000cb0:	412505b3          	sub	a1,a0,s2
    80000cb4:	8552                	mv	a0,s4
    80000cb6:	fffff097          	auipc	ra,0xfffff
    80000cba:	522080e7          	jalr	1314(ra) # 800001d8 <memmove>

    len -= n;
    80000cbe:	409989b3          	sub	s3,s3,s1
    dst += n;
    80000cc2:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80000cc4:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80000cc8:	02098263          	beqz	s3,80000cec <copyin+0x6a>
    va0 = PGROUNDDOWN(srcva);
    80000ccc:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80000cd0:	85ca                	mv	a1,s2
    80000cd2:	855a                	mv	a0,s6
    80000cd4:	00000097          	auipc	ra,0x0
    80000cd8:	916080e7          	jalr	-1770(ra) # 800005ea <walkaddr>
    if(pa0 == 0)
    80000cdc:	cd01                	beqz	a0,80000cf4 <copyin+0x72>
    n = PGSIZE - (srcva - va0);
    80000cde:	418904b3          	sub	s1,s2,s8
    80000ce2:	94d6                	add	s1,s1,s5
    if(n > len)
    80000ce4:	fc99f3e3          	bgeu	s3,s1,80000caa <copyin+0x28>
    80000ce8:	84ce                	mv	s1,s3
    80000cea:	b7c1                	j	80000caa <copyin+0x28>
  }
  return 0;
    80000cec:	4501                	li	a0,0
    80000cee:	a021                	j	80000cf6 <copyin+0x74>
    80000cf0:	4501                	li	a0,0
}
    80000cf2:	8082                	ret
      return -1;
    80000cf4:	557d                	li	a0,-1
}
    80000cf6:	60a6                	ld	ra,72(sp)
    80000cf8:	6406                	ld	s0,64(sp)
    80000cfa:	74e2                	ld	s1,56(sp)
    80000cfc:	7942                	ld	s2,48(sp)
    80000cfe:	79a2                	ld	s3,40(sp)
    80000d00:	7a02                	ld	s4,32(sp)
    80000d02:	6ae2                	ld	s5,24(sp)
    80000d04:	6b42                	ld	s6,16(sp)
    80000d06:	6ba2                	ld	s7,8(sp)
    80000d08:	6c02                	ld	s8,0(sp)
    80000d0a:	6161                	addi	sp,sp,80
    80000d0c:	8082                	ret

0000000080000d0e <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80000d0e:	c6c5                	beqz	a3,80000db6 <copyinstr+0xa8>
{
    80000d10:	715d                	addi	sp,sp,-80
    80000d12:	e486                	sd	ra,72(sp)
    80000d14:	e0a2                	sd	s0,64(sp)
    80000d16:	fc26                	sd	s1,56(sp)
    80000d18:	f84a                	sd	s2,48(sp)
    80000d1a:	f44e                	sd	s3,40(sp)
    80000d1c:	f052                	sd	s4,32(sp)
    80000d1e:	ec56                	sd	s5,24(sp)
    80000d20:	e85a                	sd	s6,16(sp)
    80000d22:	e45e                	sd	s7,8(sp)
    80000d24:	0880                	addi	s0,sp,80
    80000d26:	8a2a                	mv	s4,a0
    80000d28:	8b2e                	mv	s6,a1
    80000d2a:	8bb2                	mv	s7,a2
    80000d2c:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80000d2e:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80000d30:	6985                	lui	s3,0x1
    80000d32:	a035                	j	80000d5e <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80000d34:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80000d38:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80000d3a:	0017b793          	seqz	a5,a5
    80000d3e:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80000d42:	60a6                	ld	ra,72(sp)
    80000d44:	6406                	ld	s0,64(sp)
    80000d46:	74e2                	ld	s1,56(sp)
    80000d48:	7942                	ld	s2,48(sp)
    80000d4a:	79a2                	ld	s3,40(sp)
    80000d4c:	7a02                	ld	s4,32(sp)
    80000d4e:	6ae2                	ld	s5,24(sp)
    80000d50:	6b42                	ld	s6,16(sp)
    80000d52:	6ba2                	ld	s7,8(sp)
    80000d54:	6161                	addi	sp,sp,80
    80000d56:	8082                	ret
    srcva = va0 + PGSIZE;
    80000d58:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80000d5c:	c8a9                	beqz	s1,80000dae <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    80000d5e:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80000d62:	85ca                	mv	a1,s2
    80000d64:	8552                	mv	a0,s4
    80000d66:	00000097          	auipc	ra,0x0
    80000d6a:	884080e7          	jalr	-1916(ra) # 800005ea <walkaddr>
    if(pa0 == 0)
    80000d6e:	c131                	beqz	a0,80000db2 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80000d70:	41790833          	sub	a6,s2,s7
    80000d74:	984e                	add	a6,a6,s3
    if(n > max)
    80000d76:	0104f363          	bgeu	s1,a6,80000d7c <copyinstr+0x6e>
    80000d7a:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80000d7c:	955e                	add	a0,a0,s7
    80000d7e:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80000d82:	fc080be3          	beqz	a6,80000d58 <copyinstr+0x4a>
    80000d86:	985a                	add	a6,a6,s6
    80000d88:	87da                	mv	a5,s6
      if(*p == '\0'){
    80000d8a:	41650633          	sub	a2,a0,s6
    80000d8e:	14fd                	addi	s1,s1,-1
    80000d90:	9b26                	add	s6,s6,s1
    80000d92:	00f60733          	add	a4,a2,a5
    80000d96:	00074703          	lbu	a4,0(a4)
    80000d9a:	df49                	beqz	a4,80000d34 <copyinstr+0x26>
        *dst = *p;
    80000d9c:	00e78023          	sb	a4,0(a5)
      --max;
    80000da0:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80000da4:	0785                	addi	a5,a5,1
    while(n > 0){
    80000da6:	ff0796e3          	bne	a5,a6,80000d92 <copyinstr+0x84>
      dst++;
    80000daa:	8b42                	mv	s6,a6
    80000dac:	b775                	j	80000d58 <copyinstr+0x4a>
    80000dae:	4781                	li	a5,0
    80000db0:	b769                	j	80000d3a <copyinstr+0x2c>
      return -1;
    80000db2:	557d                	li	a0,-1
    80000db4:	b779                	j	80000d42 <copyinstr+0x34>
  int got_null = 0;
    80000db6:	4781                	li	a5,0
  if(got_null){
    80000db8:	0017b793          	seqz	a5,a5
    80000dbc:	40f00533          	neg	a0,a5
}
    80000dc0:	8082                	ret

0000000080000dc2 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80000dc2:	7139                	addi	sp,sp,-64
    80000dc4:	fc06                	sd	ra,56(sp)
    80000dc6:	f822                	sd	s0,48(sp)
    80000dc8:	f426                	sd	s1,40(sp)
    80000dca:	f04a                	sd	s2,32(sp)
    80000dcc:	ec4e                	sd	s3,24(sp)
    80000dce:	e852                	sd	s4,16(sp)
    80000dd0:	e456                	sd	s5,8(sp)
    80000dd2:	e05a                	sd	s6,0(sp)
    80000dd4:	0080                	addi	s0,sp,64
    80000dd6:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80000dd8:	00008497          	auipc	s1,0x8
    80000ddc:	fd848493          	addi	s1,s1,-40 # 80008db0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80000de0:	8b26                	mv	s6,s1
    80000de2:	00007a97          	auipc	s5,0x7
    80000de6:	21ea8a93          	addi	s5,s5,542 # 80008000 <etext>
    80000dea:	01000937          	lui	s2,0x1000
    80000dee:	197d                	addi	s2,s2,-1
    80000df0:	093a                	slli	s2,s2,0xe
  for(p = proc; p < &proc[NPROC]; p++) {
    80000df2:	0000ea17          	auipc	s4,0xe
    80000df6:	9bea0a13          	addi	s4,s4,-1602 # 8000e7b0 <tickslock>
    char *pa = kalloc();
    80000dfa:	fffff097          	auipc	ra,0xfffff
    80000dfe:	31e080e7          	jalr	798(ra) # 80000118 <kalloc>
    80000e02:	862a                	mv	a2,a0
    if(pa == 0)
    80000e04:	c129                	beqz	a0,80000e46 <proc_mapstacks+0x84>
    uint64 va = KSTACK((int) (p - proc));
    80000e06:	416485b3          	sub	a1,s1,s6
    80000e0a:	858d                	srai	a1,a1,0x3
    80000e0c:	000ab783          	ld	a5,0(s5)
    80000e10:	02f585b3          	mul	a1,a1,a5
    80000e14:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80000e18:	4719                	li	a4,6
    80000e1a:	6685                	lui	a3,0x1
    80000e1c:	40b905b3          	sub	a1,s2,a1
    80000e20:	854e                	mv	a0,s3
    80000e22:	00000097          	auipc	ra,0x0
    80000e26:	8aa080e7          	jalr	-1878(ra) # 800006cc <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000e2a:	16848493          	addi	s1,s1,360
    80000e2e:	fd4496e3          	bne	s1,s4,80000dfa <proc_mapstacks+0x38>
  }
}
    80000e32:	70e2                	ld	ra,56(sp)
    80000e34:	7442                	ld	s0,48(sp)
    80000e36:	74a2                	ld	s1,40(sp)
    80000e38:	7902                	ld	s2,32(sp)
    80000e3a:	69e2                	ld	s3,24(sp)
    80000e3c:	6a42                	ld	s4,16(sp)
    80000e3e:	6aa2                	ld	s5,8(sp)
    80000e40:	6b02                	ld	s6,0(sp)
    80000e42:	6121                	addi	sp,sp,64
    80000e44:	8082                	ret
      panic("kalloc");
    80000e46:	00007517          	auipc	a0,0x7
    80000e4a:	34250513          	addi	a0,a0,834 # 80008188 <etext+0x188>
    80000e4e:	00005097          	auipc	ra,0x5
    80000e52:	064080e7          	jalr	100(ra) # 80005eb2 <panic>

0000000080000e56 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80000e56:	7139                	addi	sp,sp,-64
    80000e58:	fc06                	sd	ra,56(sp)
    80000e5a:	f822                	sd	s0,48(sp)
    80000e5c:	f426                	sd	s1,40(sp)
    80000e5e:	f04a                	sd	s2,32(sp)
    80000e60:	ec4e                	sd	s3,24(sp)
    80000e62:	e852                	sd	s4,16(sp)
    80000e64:	e456                	sd	s5,8(sp)
    80000e66:	e05a                	sd	s6,0(sp)
    80000e68:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80000e6a:	00007597          	auipc	a1,0x7
    80000e6e:	32658593          	addi	a1,a1,806 # 80008190 <etext+0x190>
    80000e72:	00008517          	auipc	a0,0x8
    80000e76:	b0e50513          	addi	a0,a0,-1266 # 80008980 <pid_lock>
    80000e7a:	00005097          	auipc	ra,0x5
    80000e7e:	4f2080e7          	jalr	1266(ra) # 8000636c <initlock>
  initlock(&wait_lock, "wait_lock");
    80000e82:	00007597          	auipc	a1,0x7
    80000e86:	31658593          	addi	a1,a1,790 # 80008198 <etext+0x198>
    80000e8a:	00008517          	auipc	a0,0x8
    80000e8e:	b0e50513          	addi	a0,a0,-1266 # 80008998 <wait_lock>
    80000e92:	00005097          	auipc	ra,0x5
    80000e96:	4da080e7          	jalr	1242(ra) # 8000636c <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000e9a:	00008497          	auipc	s1,0x8
    80000e9e:	f1648493          	addi	s1,s1,-234 # 80008db0 <proc>
      initlock(&p->lock, "proc");
    80000ea2:	00007b17          	auipc	s6,0x7
    80000ea6:	306b0b13          	addi	s6,s6,774 # 800081a8 <etext+0x1a8>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80000eaa:	8aa6                	mv	s5,s1
    80000eac:	00007a17          	auipc	s4,0x7
    80000eb0:	154a0a13          	addi	s4,s4,340 # 80008000 <etext>
    80000eb4:	01000937          	lui	s2,0x1000
    80000eb8:	197d                	addi	s2,s2,-1
    80000eba:	093a                	slli	s2,s2,0xe
  for(p = proc; p < &proc[NPROC]; p++) {
    80000ebc:	0000e997          	auipc	s3,0xe
    80000ec0:	8f498993          	addi	s3,s3,-1804 # 8000e7b0 <tickslock>
      initlock(&p->lock, "proc");
    80000ec4:	85da                	mv	a1,s6
    80000ec6:	8526                	mv	a0,s1
    80000ec8:	00005097          	auipc	ra,0x5
    80000ecc:	4a4080e7          	jalr	1188(ra) # 8000636c <initlock>
      p->state = UNUSED;
    80000ed0:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80000ed4:	415487b3          	sub	a5,s1,s5
    80000ed8:	878d                	srai	a5,a5,0x3
    80000eda:	000a3703          	ld	a4,0(s4)
    80000ede:	02e787b3          	mul	a5,a5,a4
    80000ee2:	00d7979b          	slliw	a5,a5,0xd
    80000ee6:	40f907b3          	sub	a5,s2,a5
    80000eea:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80000eec:	16848493          	addi	s1,s1,360
    80000ef0:	fd349ae3          	bne	s1,s3,80000ec4 <procinit+0x6e>
  }
}
    80000ef4:	70e2                	ld	ra,56(sp)
    80000ef6:	7442                	ld	s0,48(sp)
    80000ef8:	74a2                	ld	s1,40(sp)
    80000efa:	7902                	ld	s2,32(sp)
    80000efc:	69e2                	ld	s3,24(sp)
    80000efe:	6a42                	ld	s4,16(sp)
    80000f00:	6aa2                	ld	s5,8(sp)
    80000f02:	6b02                	ld	s6,0(sp)
    80000f04:	6121                	addi	sp,sp,64
    80000f06:	8082                	ret

0000000080000f08 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80000f08:	1141                	addi	sp,sp,-16
    80000f0a:	e422                	sd	s0,8(sp)
    80000f0c:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80000f0e:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80000f10:	2501                	sext.w	a0,a0
    80000f12:	6422                	ld	s0,8(sp)
    80000f14:	0141                	addi	sp,sp,16
    80000f16:	8082                	ret

0000000080000f18 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80000f18:	1141                	addi	sp,sp,-16
    80000f1a:	e422                	sd	s0,8(sp)
    80000f1c:	0800                	addi	s0,sp,16
    80000f1e:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80000f20:	2781                	sext.w	a5,a5
    80000f22:	079e                	slli	a5,a5,0x7
  return c;
}
    80000f24:	00008517          	auipc	a0,0x8
    80000f28:	a8c50513          	addi	a0,a0,-1396 # 800089b0 <cpus>
    80000f2c:	953e                	add	a0,a0,a5
    80000f2e:	6422                	ld	s0,8(sp)
    80000f30:	0141                	addi	sp,sp,16
    80000f32:	8082                	ret

0000000080000f34 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80000f34:	1101                	addi	sp,sp,-32
    80000f36:	ec06                	sd	ra,24(sp)
    80000f38:	e822                	sd	s0,16(sp)
    80000f3a:	e426                	sd	s1,8(sp)
    80000f3c:	1000                	addi	s0,sp,32
  push_off();
    80000f3e:	00005097          	auipc	ra,0x5
    80000f42:	472080e7          	jalr	1138(ra) # 800063b0 <push_off>
    80000f46:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80000f48:	2781                	sext.w	a5,a5
    80000f4a:	079e                	slli	a5,a5,0x7
    80000f4c:	00008717          	auipc	a4,0x8
    80000f50:	a3470713          	addi	a4,a4,-1484 # 80008980 <pid_lock>
    80000f54:	97ba                	add	a5,a5,a4
    80000f56:	7b84                	ld	s1,48(a5)
  pop_off();
    80000f58:	00005097          	auipc	ra,0x5
    80000f5c:	4f8080e7          	jalr	1272(ra) # 80006450 <pop_off>
  return p;
}
    80000f60:	8526                	mv	a0,s1
    80000f62:	60e2                	ld	ra,24(sp)
    80000f64:	6442                	ld	s0,16(sp)
    80000f66:	64a2                	ld	s1,8(sp)
    80000f68:	6105                	addi	sp,sp,32
    80000f6a:	8082                	ret

0000000080000f6c <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80000f6c:	1141                	addi	sp,sp,-16
    80000f6e:	e406                	sd	ra,8(sp)
    80000f70:	e022                	sd	s0,0(sp)
    80000f72:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80000f74:	00000097          	auipc	ra,0x0
    80000f78:	fc0080e7          	jalr	-64(ra) # 80000f34 <myproc>
    80000f7c:	00005097          	auipc	ra,0x5
    80000f80:	534080e7          	jalr	1332(ra) # 800064b0 <release>

  if (first) {
    80000f84:	00008797          	auipc	a5,0x8
    80000f88:	9407a783          	lw	a5,-1728(a5) # 800088c4 <first.1686>
    80000f8c:	eb89                	bnez	a5,80000f9e <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80000f8e:	00001097          	auipc	ra,0x1
    80000f92:	d5c080e7          	jalr	-676(ra) # 80001cea <usertrapret>
}
    80000f96:	60a2                	ld	ra,8(sp)
    80000f98:	6402                	ld	s0,0(sp)
    80000f9a:	0141                	addi	sp,sp,16
    80000f9c:	8082                	ret
    first = 0;
    80000f9e:	00008797          	auipc	a5,0x8
    80000fa2:	9207a323          	sw	zero,-1754(a5) # 800088c4 <first.1686>
    fsinit(ROOTDEV);
    80000fa6:	4505                	li	a0,1
    80000fa8:	00002097          	auipc	ra,0x2
    80000fac:	b7e080e7          	jalr	-1154(ra) # 80002b26 <fsinit>
    80000fb0:	bff9                	j	80000f8e <forkret+0x22>

0000000080000fb2 <allocpid>:
{
    80000fb2:	1101                	addi	sp,sp,-32
    80000fb4:	ec06                	sd	ra,24(sp)
    80000fb6:	e822                	sd	s0,16(sp)
    80000fb8:	e426                	sd	s1,8(sp)
    80000fba:	e04a                	sd	s2,0(sp)
    80000fbc:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80000fbe:	00008917          	auipc	s2,0x8
    80000fc2:	9c290913          	addi	s2,s2,-1598 # 80008980 <pid_lock>
    80000fc6:	854a                	mv	a0,s2
    80000fc8:	00005097          	auipc	ra,0x5
    80000fcc:	434080e7          	jalr	1076(ra) # 800063fc <acquire>
  pid = nextpid;
    80000fd0:	00008797          	auipc	a5,0x8
    80000fd4:	8f878793          	addi	a5,a5,-1800 # 800088c8 <nextpid>
    80000fd8:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80000fda:	0014871b          	addiw	a4,s1,1
    80000fde:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80000fe0:	854a                	mv	a0,s2
    80000fe2:	00005097          	auipc	ra,0x5
    80000fe6:	4ce080e7          	jalr	1230(ra) # 800064b0 <release>
}
    80000fea:	8526                	mv	a0,s1
    80000fec:	60e2                	ld	ra,24(sp)
    80000fee:	6442                	ld	s0,16(sp)
    80000ff0:	64a2                	ld	s1,8(sp)
    80000ff2:	6902                	ld	s2,0(sp)
    80000ff4:	6105                	addi	sp,sp,32
    80000ff6:	8082                	ret

0000000080000ff8 <proc_pagetable>:
{
    80000ff8:	7179                	addi	sp,sp,-48
    80000ffa:	f406                	sd	ra,40(sp)
    80000ffc:	f022                	sd	s0,32(sp)
    80000ffe:	ec26                	sd	s1,24(sp)
    80001000:	e84a                	sd	s2,16(sp)
    80001002:	e44e                	sd	s3,8(sp)
    80001004:	1800                	addi	s0,sp,48
    80001006:	892a                	mv	s2,a0
 uint64 commaddr=(uint64)kalloc();
    80001008:	fffff097          	auipc	ra,0xfffff
    8000100c:	110080e7          	jalr	272(ra) # 80000118 <kalloc>
    80001010:	89aa                	mv	s3,a0
  pagetable = uvmcreate();
    80001012:	00000097          	auipc	ra,0x0
    80001016:	8a4080e7          	jalr	-1884(ra) # 800008b6 <uvmcreate>
    8000101a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000101c:	cd31                	beqz	a0,80001078 <proc_pagetable+0x80>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    8000101e:	4729                	li	a4,10
    80001020:	00006697          	auipc	a3,0x6
    80001024:	fe068693          	addi	a3,a3,-32 # 80007000 <_trampoline>
    80001028:	6605                	lui	a2,0x1
    8000102a:	040005b7          	lui	a1,0x4000
    8000102e:	15fd                	addi	a1,a1,-1
    80001030:	05b2                	slli	a1,a1,0xc
    80001032:	fffff097          	auipc	ra,0xfffff
    80001036:	5fa080e7          	jalr	1530(ra) # 8000062c <mappages>
    8000103a:	04054763          	bltz	a0,80001088 <proc_pagetable+0x90>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    8000103e:	4719                	li	a4,6
    80001040:	05893683          	ld	a3,88(s2)
    80001044:	6605                	lui	a2,0x1
    80001046:	020005b7          	lui	a1,0x2000
    8000104a:	15fd                	addi	a1,a1,-1
    8000104c:	05b6                	slli	a1,a1,0xd
    8000104e:	8526                	mv	a0,s1
    80001050:	fffff097          	auipc	ra,0xfffff
    80001054:	5dc080e7          	jalr	1500(ra) # 8000062c <mappages>
    80001058:	04054063          	bltz	a0,80001098 <proc_pagetable+0xa0>
  if(mappages(pagetable, USYSCALL, PGSIZE,
    8000105c:	4719                	li	a4,6
    8000105e:	86ce                	mv	a3,s3
    80001060:	6605                	lui	a2,0x1
    80001062:	040005b7          	lui	a1,0x4000
    80001066:	15f5                	addi	a1,a1,-3
    80001068:	05b2                	slli	a1,a1,0xc
    8000106a:	8526                	mv	a0,s1
    8000106c:	fffff097          	auipc	ra,0xfffff
    80001070:	5c0080e7          	jalr	1472(ra) # 8000062c <mappages>
    80001074:	04054563          	bltz	a0,800010be <proc_pagetable+0xc6>
}
    80001078:	8526                	mv	a0,s1
    8000107a:	70a2                	ld	ra,40(sp)
    8000107c:	7402                	ld	s0,32(sp)
    8000107e:	64e2                	ld	s1,24(sp)
    80001080:	6942                	ld	s2,16(sp)
    80001082:	69a2                	ld	s3,8(sp)
    80001084:	6145                	addi	sp,sp,48
    80001086:	8082                	ret
    uvmfree(pagetable, 0);
    80001088:	4581                	li	a1,0
    8000108a:	8526                	mv	a0,s1
    8000108c:	00000097          	auipc	ra,0x0
    80001090:	a2e080e7          	jalr	-1490(ra) # 80000aba <uvmfree>
    return 0;
    80001094:	4481                	li	s1,0
    80001096:	b7cd                	j	80001078 <proc_pagetable+0x80>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001098:	4681                	li	a3,0
    8000109a:	4605                	li	a2,1
    8000109c:	040005b7          	lui	a1,0x4000
    800010a0:	15fd                	addi	a1,a1,-1
    800010a2:	05b2                	slli	a1,a1,0xc
    800010a4:	8526                	mv	a0,s1
    800010a6:	fffff097          	auipc	ra,0xfffff
    800010aa:	74c080e7          	jalr	1868(ra) # 800007f2 <uvmunmap>
    uvmfree(pagetable, 0);
    800010ae:	4581                	li	a1,0
    800010b0:	8526                	mv	a0,s1
    800010b2:	00000097          	auipc	ra,0x0
    800010b6:	a08080e7          	jalr	-1528(ra) # 80000aba <uvmfree>
    return 0;
    800010ba:	4481                	li	s1,0
    800010bc:	bf75                	j	80001078 <proc_pagetable+0x80>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    800010be:	4681                	li	a3,0
    800010c0:	4605                	li	a2,1
    800010c2:	040005b7          	lui	a1,0x4000
    800010c6:	15fd                	addi	a1,a1,-1
    800010c8:	05b2                	slli	a1,a1,0xc
    800010ca:	8526                	mv	a0,s1
    800010cc:	fffff097          	auipc	ra,0xfffff
    800010d0:	726080e7          	jalr	1830(ra) # 800007f2 <uvmunmap>
    uvmunmap(pagetable, TRAPFRAME, 1, 0);
    800010d4:	4681                	li	a3,0
    800010d6:	4605                	li	a2,1
    800010d8:	020005b7          	lui	a1,0x2000
    800010dc:	15fd                	addi	a1,a1,-1
    800010de:	05b6                	slli	a1,a1,0xd
    800010e0:	8526                	mv	a0,s1
    800010e2:	fffff097          	auipc	ra,0xfffff
    800010e6:	710080e7          	jalr	1808(ra) # 800007f2 <uvmunmap>
    uvmfree(pagetable, 0);
    800010ea:	4581                	li	a1,0
    800010ec:	8526                	mv	a0,s1
    800010ee:	00000097          	auipc	ra,0x0
    800010f2:	9cc080e7          	jalr	-1588(ra) # 80000aba <uvmfree>
    return 0;
    800010f6:	4481                	li	s1,0
    800010f8:	b741                	j	80001078 <proc_pagetable+0x80>

00000000800010fa <proc_freepagetable>:
{
    800010fa:	7179                	addi	sp,sp,-48
    800010fc:	f406                	sd	ra,40(sp)
    800010fe:	f022                	sd	s0,32(sp)
    80001100:	ec26                	sd	s1,24(sp)
    80001102:	e84a                	sd	s2,16(sp)
    80001104:	e44e                	sd	s3,8(sp)
    80001106:	1800                	addi	s0,sp,48
    80001108:	84aa                	mv	s1,a0
    8000110a:	89ae                	mv	s3,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    8000110c:	4681                	li	a3,0
    8000110e:	4605                	li	a2,1
    80001110:	04000937          	lui	s2,0x4000
    80001114:	fff90593          	addi	a1,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001118:	05b2                	slli	a1,a1,0xc
    8000111a:	fffff097          	auipc	ra,0xfffff
    8000111e:	6d8080e7          	jalr	1752(ra) # 800007f2 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001122:	4681                	li	a3,0
    80001124:	4605                	li	a2,1
    80001126:	020005b7          	lui	a1,0x2000
    8000112a:	15fd                	addi	a1,a1,-1
    8000112c:	05b6                	slli	a1,a1,0xd
    8000112e:	8526                	mv	a0,s1
    80001130:	fffff097          	auipc	ra,0xfffff
    80001134:	6c2080e7          	jalr	1730(ra) # 800007f2 <uvmunmap>
  uvmunmap(pagetable, USYSCALL, 1, 0);
    80001138:	4681                	li	a3,0
    8000113a:	4605                	li	a2,1
    8000113c:	1975                	addi	s2,s2,-3
    8000113e:	00c91593          	slli	a1,s2,0xc
    80001142:	8526                	mv	a0,s1
    80001144:	fffff097          	auipc	ra,0xfffff
    80001148:	6ae080e7          	jalr	1710(ra) # 800007f2 <uvmunmap>
  uvmfree(pagetable, sz);
    8000114c:	85ce                	mv	a1,s3
    8000114e:	8526                	mv	a0,s1
    80001150:	00000097          	auipc	ra,0x0
    80001154:	96a080e7          	jalr	-1686(ra) # 80000aba <uvmfree>
}
    80001158:	70a2                	ld	ra,40(sp)
    8000115a:	7402                	ld	s0,32(sp)
    8000115c:	64e2                	ld	s1,24(sp)
    8000115e:	6942                	ld	s2,16(sp)
    80001160:	69a2                	ld	s3,8(sp)
    80001162:	6145                	addi	sp,sp,48
    80001164:	8082                	ret

0000000080001166 <freeproc>:
{
    80001166:	1101                	addi	sp,sp,-32
    80001168:	ec06                	sd	ra,24(sp)
    8000116a:	e822                	sd	s0,16(sp)
    8000116c:	e426                	sd	s1,8(sp)
    8000116e:	1000                	addi	s0,sp,32
    80001170:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001172:	6d28                	ld	a0,88(a0)
    80001174:	c509                	beqz	a0,8000117e <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001176:	fffff097          	auipc	ra,0xfffff
    8000117a:	ea6080e7          	jalr	-346(ra) # 8000001c <kfree>
  if(walk(p->pagetable,USYSCALL,0)) 
    8000117e:	4601                	li	a2,0
    80001180:	040005b7          	lui	a1,0x4000
    80001184:	15f5                	addi	a1,a1,-3
    80001186:	05b2                	slli	a1,a1,0xc
    80001188:	68a8                	ld	a0,80(s1)
    8000118a:	fffff097          	auipc	ra,0xfffff
    8000118e:	3ba080e7          	jalr	954(ra) # 80000544 <walk>
    80001192:	cd11                	beqz	a0,800011ae <freeproc+0x48>
    kfree((void*)walkaddr(p->pagetable,USYSCALL));
    80001194:	040005b7          	lui	a1,0x4000
    80001198:	15f5                	addi	a1,a1,-3
    8000119a:	05b2                	slli	a1,a1,0xc
    8000119c:	68a8                	ld	a0,80(s1)
    8000119e:	fffff097          	auipc	ra,0xfffff
    800011a2:	44c080e7          	jalr	1100(ra) # 800005ea <walkaddr>
    800011a6:	fffff097          	auipc	ra,0xfffff
    800011aa:	e76080e7          	jalr	-394(ra) # 8000001c <kfree>
  p->trapframe = 0;
    800011ae:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    800011b2:	68a8                	ld	a0,80(s1)
    800011b4:	c511                	beqz	a0,800011c0 <freeproc+0x5a>
    proc_freepagetable(p->pagetable, p->sz);
    800011b6:	64ac                	ld	a1,72(s1)
    800011b8:	00000097          	auipc	ra,0x0
    800011bc:	f42080e7          	jalr	-190(ra) # 800010fa <proc_freepagetable>
  p->pagetable = 0;
    800011c0:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    800011c4:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    800011c8:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    800011cc:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    800011d0:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    800011d4:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    800011d8:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    800011dc:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    800011e0:	0004ac23          	sw	zero,24(s1)
}
    800011e4:	60e2                	ld	ra,24(sp)
    800011e6:	6442                	ld	s0,16(sp)
    800011e8:	64a2                	ld	s1,8(sp)
    800011ea:	6105                	addi	sp,sp,32
    800011ec:	8082                	ret

00000000800011ee <allocproc>:
{
    800011ee:	7179                	addi	sp,sp,-48
    800011f0:	f406                	sd	ra,40(sp)
    800011f2:	f022                	sd	s0,32(sp)
    800011f4:	ec26                	sd	s1,24(sp)
    800011f6:	e84a                	sd	s2,16(sp)
    800011f8:	e44e                	sd	s3,8(sp)
    800011fa:	e052                	sd	s4,0(sp)
    800011fc:	1800                	addi	s0,sp,48
  for(p = proc; p < &proc[NPROC]; p++) {
    800011fe:	00008497          	auipc	s1,0x8
    80001202:	bb248493          	addi	s1,s1,-1102 # 80008db0 <proc>
    80001206:	0000d917          	auipc	s2,0xd
    8000120a:	5aa90913          	addi	s2,s2,1450 # 8000e7b0 <tickslock>
    acquire(&p->lock);
    8000120e:	8526                	mv	a0,s1
    80001210:	00005097          	auipc	ra,0x5
    80001214:	1ec080e7          	jalr	492(ra) # 800063fc <acquire>
    if(p->state == UNUSED) {
    80001218:	4c9c                	lw	a5,24(s1)
    8000121a:	cf81                	beqz	a5,80001232 <allocproc+0x44>
      release(&p->lock);
    8000121c:	8526                	mv	a0,s1
    8000121e:	00005097          	auipc	ra,0x5
    80001222:	292080e7          	jalr	658(ra) # 800064b0 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001226:	16848493          	addi	s1,s1,360
    8000122a:	ff2492e3          	bne	s1,s2,8000120e <allocproc+0x20>
  return 0;
    8000122e:	4481                	li	s1,0
    80001230:	a045                	j	800012d0 <allocproc+0xe2>
  p->pid = allocpid();
    80001232:	00000097          	auipc	ra,0x0
    80001236:	d80080e7          	jalr	-640(ra) # 80000fb2 <allocpid>
    8000123a:	8a2a                	mv	s4,a0
    8000123c:	d888                	sw	a0,48(s1)
  p->state = USED;
    8000123e:	4785                	li	a5,1
    80001240:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001242:	fffff097          	auipc	ra,0xfffff
    80001246:	ed6080e7          	jalr	-298(ra) # 80000118 <kalloc>
    8000124a:	892a                	mv	s2,a0
    8000124c:	eca8                	sd	a0,88(s1)
    8000124e:	c951                	beqz	a0,800012e2 <allocproc+0xf4>
  p->pagetable = proc_pagetable(p);
    80001250:	8526                	mv	a0,s1
    80001252:	00000097          	auipc	ra,0x0
    80001256:	da6080e7          	jalr	-602(ra) # 80000ff8 <proc_pagetable>
    8000125a:	e8a8                	sd	a0,80(s1)
  pbuf= walk(p->pagetable,USYSCALL,0);
    8000125c:	4601                	li	a2,0
    8000125e:	040009b7          	lui	s3,0x4000
    80001262:	19f5                	addi	s3,s3,-3
    80001264:	00c99593          	slli	a1,s3,0xc
    80001268:	fffff097          	auipc	ra,0xfffff
    8000126c:	2dc080e7          	jalr	732(ra) # 80000544 <walk>
  pageP=(struct usyscall*)PTE2PA(*pbuf);
    80001270:	00053903          	ld	s2,0(a0)
    80001274:	00a95913          	srli	s2,s2,0xa
    80001278:	0932                	slli	s2,s2,0xc
  *pageP=Usyscall;
    8000127a:	01492023          	sw	s4,0(s2)
  uvmunmap(p->pagetable,USYSCALL,1,0);
    8000127e:	4681                	li	a3,0
    80001280:	4605                	li	a2,1
    80001282:	00c99593          	slli	a1,s3,0xc
    80001286:	68a8                	ld	a0,80(s1)
    80001288:	fffff097          	auipc	ra,0xfffff
    8000128c:	56a080e7          	jalr	1386(ra) # 800007f2 <uvmunmap>
  mappages(p->pagetable,USYSCALL,PGSIZE,(uint64)pageP,PTE_R | PTE_U);
    80001290:	4749                	li	a4,18
    80001292:	86ca                	mv	a3,s2
    80001294:	6605                	lui	a2,0x1
    80001296:	00c99593          	slli	a1,s3,0xc
    8000129a:	68a8                	ld	a0,80(s1)
    8000129c:	fffff097          	auipc	ra,0xfffff
    800012a0:	390080e7          	jalr	912(ra) # 8000062c <mappages>
  if(p->pagetable == 0){
    800012a4:	0504b903          	ld	s2,80(s1)
    800012a8:	04090963          	beqz	s2,800012fa <allocproc+0x10c>
  memset(&p->context, 0, sizeof(p->context));
    800012ac:	07000613          	li	a2,112
    800012b0:	4581                	li	a1,0
    800012b2:	06048513          	addi	a0,s1,96
    800012b6:	fffff097          	auipc	ra,0xfffff
    800012ba:	ec2080e7          	jalr	-318(ra) # 80000178 <memset>
  p->context.ra = (uint64)forkret;
    800012be:	00000797          	auipc	a5,0x0
    800012c2:	cae78793          	addi	a5,a5,-850 # 80000f6c <forkret>
    800012c6:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    800012c8:	60bc                	ld	a5,64(s1)
    800012ca:	6705                	lui	a4,0x1
    800012cc:	97ba                	add	a5,a5,a4
    800012ce:	f4bc                	sd	a5,104(s1)
}
    800012d0:	8526                	mv	a0,s1
    800012d2:	70a2                	ld	ra,40(sp)
    800012d4:	7402                	ld	s0,32(sp)
    800012d6:	64e2                	ld	s1,24(sp)
    800012d8:	6942                	ld	s2,16(sp)
    800012da:	69a2                	ld	s3,8(sp)
    800012dc:	6a02                	ld	s4,0(sp)
    800012de:	6145                	addi	sp,sp,48
    800012e0:	8082                	ret
    freeproc(p);
    800012e2:	8526                	mv	a0,s1
    800012e4:	00000097          	auipc	ra,0x0
    800012e8:	e82080e7          	jalr	-382(ra) # 80001166 <freeproc>
    release(&p->lock);
    800012ec:	8526                	mv	a0,s1
    800012ee:	00005097          	auipc	ra,0x5
    800012f2:	1c2080e7          	jalr	450(ra) # 800064b0 <release>
    return 0;
    800012f6:	84ca                	mv	s1,s2
    800012f8:	bfe1                	j	800012d0 <allocproc+0xe2>
    freeproc(p);
    800012fa:	8526                	mv	a0,s1
    800012fc:	00000097          	auipc	ra,0x0
    80001300:	e6a080e7          	jalr	-406(ra) # 80001166 <freeproc>
    release(&p->lock);
    80001304:	8526                	mv	a0,s1
    80001306:	00005097          	auipc	ra,0x5
    8000130a:	1aa080e7          	jalr	426(ra) # 800064b0 <release>
    return 0;
    8000130e:	84ca                	mv	s1,s2
    80001310:	b7c1                	j	800012d0 <allocproc+0xe2>

0000000080001312 <userinit>:
{
    80001312:	1101                	addi	sp,sp,-32
    80001314:	ec06                	sd	ra,24(sp)
    80001316:	e822                	sd	s0,16(sp)
    80001318:	e426                	sd	s1,8(sp)
    8000131a:	1000                	addi	s0,sp,32
  p = allocproc();
    8000131c:	00000097          	auipc	ra,0x0
    80001320:	ed2080e7          	jalr	-302(ra) # 800011ee <allocproc>
    80001324:	84aa                	mv	s1,a0
  initproc = p;
    80001326:	00007797          	auipc	a5,0x7
    8000132a:	60a7bd23          	sd	a0,1562(a5) # 80008940 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    8000132e:	03400613          	li	a2,52
    80001332:	00007597          	auipc	a1,0x7
    80001336:	59e58593          	addi	a1,a1,1438 # 800088d0 <initcode>
    8000133a:	6928                	ld	a0,80(a0)
    8000133c:	fffff097          	auipc	ra,0xfffff
    80001340:	5a8080e7          	jalr	1448(ra) # 800008e4 <uvmfirst>
  p->sz = PGSIZE;
    80001344:	6785                	lui	a5,0x1
    80001346:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001348:	6cb8                	ld	a4,88(s1)
    8000134a:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    8000134e:	6cb8                	ld	a4,88(s1)
    80001350:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001352:	4641                	li	a2,16
    80001354:	00007597          	auipc	a1,0x7
    80001358:	e5c58593          	addi	a1,a1,-420 # 800081b0 <etext+0x1b0>
    8000135c:	15848513          	addi	a0,s1,344
    80001360:	fffff097          	auipc	ra,0xfffff
    80001364:	f6a080e7          	jalr	-150(ra) # 800002ca <safestrcpy>
  p->cwd = namei("/");
    80001368:	00007517          	auipc	a0,0x7
    8000136c:	e5850513          	addi	a0,a0,-424 # 800081c0 <etext+0x1c0>
    80001370:	00002097          	auipc	ra,0x2
    80001374:	1d8080e7          	jalr	472(ra) # 80003548 <namei>
    80001378:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    8000137c:	478d                	li	a5,3
    8000137e:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001380:	8526                	mv	a0,s1
    80001382:	00005097          	auipc	ra,0x5
    80001386:	12e080e7          	jalr	302(ra) # 800064b0 <release>
}
    8000138a:	60e2                	ld	ra,24(sp)
    8000138c:	6442                	ld	s0,16(sp)
    8000138e:	64a2                	ld	s1,8(sp)
    80001390:	6105                	addi	sp,sp,32
    80001392:	8082                	ret

0000000080001394 <growproc>:
{
    80001394:	1101                	addi	sp,sp,-32
    80001396:	ec06                	sd	ra,24(sp)
    80001398:	e822                	sd	s0,16(sp)
    8000139a:	e426                	sd	s1,8(sp)
    8000139c:	e04a                	sd	s2,0(sp)
    8000139e:	1000                	addi	s0,sp,32
    800013a0:	892a                	mv	s2,a0
  struct proc *p = myproc();
    800013a2:	00000097          	auipc	ra,0x0
    800013a6:	b92080e7          	jalr	-1134(ra) # 80000f34 <myproc>
    800013aa:	84aa                	mv	s1,a0
  sz = p->sz;
    800013ac:	652c                	ld	a1,72(a0)
  if(n > 0){
    800013ae:	01204c63          	bgtz	s2,800013c6 <growproc+0x32>
  } else if(n < 0){
    800013b2:	02094663          	bltz	s2,800013de <growproc+0x4a>
  p->sz = sz;
    800013b6:	e4ac                	sd	a1,72(s1)
  return 0;
    800013b8:	4501                	li	a0,0
}
    800013ba:	60e2                	ld	ra,24(sp)
    800013bc:	6442                	ld	s0,16(sp)
    800013be:	64a2                	ld	s1,8(sp)
    800013c0:	6902                	ld	s2,0(sp)
    800013c2:	6105                	addi	sp,sp,32
    800013c4:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    800013c6:	4691                	li	a3,4
    800013c8:	00b90633          	add	a2,s2,a1
    800013cc:	6928                	ld	a0,80(a0)
    800013ce:	fffff097          	auipc	ra,0xfffff
    800013d2:	5d0080e7          	jalr	1488(ra) # 8000099e <uvmalloc>
    800013d6:	85aa                	mv	a1,a0
    800013d8:	fd79                	bnez	a0,800013b6 <growproc+0x22>
      return -1;
    800013da:	557d                	li	a0,-1
    800013dc:	bff9                	j	800013ba <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    800013de:	00b90633          	add	a2,s2,a1
    800013e2:	6928                	ld	a0,80(a0)
    800013e4:	fffff097          	auipc	ra,0xfffff
    800013e8:	572080e7          	jalr	1394(ra) # 80000956 <uvmdealloc>
    800013ec:	85aa                	mv	a1,a0
    800013ee:	b7e1                	j	800013b6 <growproc+0x22>

00000000800013f0 <fork>:
{
    800013f0:	7179                	addi	sp,sp,-48
    800013f2:	f406                	sd	ra,40(sp)
    800013f4:	f022                	sd	s0,32(sp)
    800013f6:	ec26                	sd	s1,24(sp)
    800013f8:	e84a                	sd	s2,16(sp)
    800013fa:	e44e                	sd	s3,8(sp)
    800013fc:	e052                	sd	s4,0(sp)
    800013fe:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001400:	00000097          	auipc	ra,0x0
    80001404:	b34080e7          	jalr	-1228(ra) # 80000f34 <myproc>
    80001408:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    8000140a:	00000097          	auipc	ra,0x0
    8000140e:	de4080e7          	jalr	-540(ra) # 800011ee <allocproc>
    80001412:	10050b63          	beqz	a0,80001528 <fork+0x138>
    80001416:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001418:	04893603          	ld	a2,72(s2)
    8000141c:	692c                	ld	a1,80(a0)
    8000141e:	05093503          	ld	a0,80(s2)
    80001422:	fffff097          	auipc	ra,0xfffff
    80001426:	6d0080e7          	jalr	1744(ra) # 80000af2 <uvmcopy>
    8000142a:	04054663          	bltz	a0,80001476 <fork+0x86>
  np->sz = p->sz;
    8000142e:	04893783          	ld	a5,72(s2)
    80001432:	04f9b423          	sd	a5,72(s3) # 4000048 <_entry-0x7bffffb8>
  *(np->trapframe) = *(p->trapframe);
    80001436:	05893683          	ld	a3,88(s2)
    8000143a:	87b6                	mv	a5,a3
    8000143c:	0589b703          	ld	a4,88(s3)
    80001440:	12068693          	addi	a3,a3,288
    80001444:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001448:	6788                	ld	a0,8(a5)
    8000144a:	6b8c                	ld	a1,16(a5)
    8000144c:	6f90                	ld	a2,24(a5)
    8000144e:	01073023          	sd	a6,0(a4)
    80001452:	e708                	sd	a0,8(a4)
    80001454:	eb0c                	sd	a1,16(a4)
    80001456:	ef10                	sd	a2,24(a4)
    80001458:	02078793          	addi	a5,a5,32
    8000145c:	02070713          	addi	a4,a4,32
    80001460:	fed792e3          	bne	a5,a3,80001444 <fork+0x54>
  np->trapframe->a0 = 0;
    80001464:	0589b783          	ld	a5,88(s3)
    80001468:	0607b823          	sd	zero,112(a5)
    8000146c:	0d000493          	li	s1,208
  for(i = 0; i < NOFILE; i++)
    80001470:	15000a13          	li	s4,336
    80001474:	a03d                	j	800014a2 <fork+0xb2>
    freeproc(np);
    80001476:	854e                	mv	a0,s3
    80001478:	00000097          	auipc	ra,0x0
    8000147c:	cee080e7          	jalr	-786(ra) # 80001166 <freeproc>
    release(&np->lock);
    80001480:	854e                	mv	a0,s3
    80001482:	00005097          	auipc	ra,0x5
    80001486:	02e080e7          	jalr	46(ra) # 800064b0 <release>
    return -1;
    8000148a:	5a7d                	li	s4,-1
    8000148c:	a069                	j	80001516 <fork+0x126>
      np->ofile[i] = filedup(p->ofile[i]);
    8000148e:	00002097          	auipc	ra,0x2
    80001492:	750080e7          	jalr	1872(ra) # 80003bde <filedup>
    80001496:	009987b3          	add	a5,s3,s1
    8000149a:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    8000149c:	04a1                	addi	s1,s1,8
    8000149e:	01448763          	beq	s1,s4,800014ac <fork+0xbc>
    if(p->ofile[i])
    800014a2:	009907b3          	add	a5,s2,s1
    800014a6:	6388                	ld	a0,0(a5)
    800014a8:	f17d                	bnez	a0,8000148e <fork+0x9e>
    800014aa:	bfcd                	j	8000149c <fork+0xac>
  np->cwd = idup(p->cwd);
    800014ac:	15093503          	ld	a0,336(s2)
    800014b0:	00002097          	auipc	ra,0x2
    800014b4:	8b4080e7          	jalr	-1868(ra) # 80002d64 <idup>
    800014b8:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    800014bc:	4641                	li	a2,16
    800014be:	15890593          	addi	a1,s2,344
    800014c2:	15898513          	addi	a0,s3,344
    800014c6:	fffff097          	auipc	ra,0xfffff
    800014ca:	e04080e7          	jalr	-508(ra) # 800002ca <safestrcpy>
  pid = np->pid;
    800014ce:	0309aa03          	lw	s4,48(s3)
  release(&np->lock);
    800014d2:	854e                	mv	a0,s3
    800014d4:	00005097          	auipc	ra,0x5
    800014d8:	fdc080e7          	jalr	-36(ra) # 800064b0 <release>
  acquire(&wait_lock);
    800014dc:	00007497          	auipc	s1,0x7
    800014e0:	4bc48493          	addi	s1,s1,1212 # 80008998 <wait_lock>
    800014e4:	8526                	mv	a0,s1
    800014e6:	00005097          	auipc	ra,0x5
    800014ea:	f16080e7          	jalr	-234(ra) # 800063fc <acquire>
  np->parent = p;
    800014ee:	0329bc23          	sd	s2,56(s3)
  release(&wait_lock);
    800014f2:	8526                	mv	a0,s1
    800014f4:	00005097          	auipc	ra,0x5
    800014f8:	fbc080e7          	jalr	-68(ra) # 800064b0 <release>
  acquire(&np->lock);
    800014fc:	854e                	mv	a0,s3
    800014fe:	00005097          	auipc	ra,0x5
    80001502:	efe080e7          	jalr	-258(ra) # 800063fc <acquire>
  np->state = RUNNABLE;
    80001506:	478d                	li	a5,3
    80001508:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    8000150c:	854e                	mv	a0,s3
    8000150e:	00005097          	auipc	ra,0x5
    80001512:	fa2080e7          	jalr	-94(ra) # 800064b0 <release>
}
    80001516:	8552                	mv	a0,s4
    80001518:	70a2                	ld	ra,40(sp)
    8000151a:	7402                	ld	s0,32(sp)
    8000151c:	64e2                	ld	s1,24(sp)
    8000151e:	6942                	ld	s2,16(sp)
    80001520:	69a2                	ld	s3,8(sp)
    80001522:	6a02                	ld	s4,0(sp)
    80001524:	6145                	addi	sp,sp,48
    80001526:	8082                	ret
    return -1;
    80001528:	5a7d                	li	s4,-1
    8000152a:	b7f5                	j	80001516 <fork+0x126>

000000008000152c <scheduler>:
{
    8000152c:	7139                	addi	sp,sp,-64
    8000152e:	fc06                	sd	ra,56(sp)
    80001530:	f822                	sd	s0,48(sp)
    80001532:	f426                	sd	s1,40(sp)
    80001534:	f04a                	sd	s2,32(sp)
    80001536:	ec4e                	sd	s3,24(sp)
    80001538:	e852                	sd	s4,16(sp)
    8000153a:	e456                	sd	s5,8(sp)
    8000153c:	e05a                	sd	s6,0(sp)
    8000153e:	0080                	addi	s0,sp,64
    80001540:	8792                	mv	a5,tp
  int id = r_tp();
    80001542:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001544:	00779a93          	slli	s5,a5,0x7
    80001548:	00007717          	auipc	a4,0x7
    8000154c:	43870713          	addi	a4,a4,1080 # 80008980 <pid_lock>
    80001550:	9756                	add	a4,a4,s5
    80001552:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001556:	00007717          	auipc	a4,0x7
    8000155a:	46270713          	addi	a4,a4,1122 # 800089b8 <cpus+0x8>
    8000155e:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001560:	498d                	li	s3,3
        p->state = RUNNING;
    80001562:	4b11                	li	s6,4
        c->proc = p;
    80001564:	079e                	slli	a5,a5,0x7
    80001566:	00007a17          	auipc	s4,0x7
    8000156a:	41aa0a13          	addi	s4,s4,1050 # 80008980 <pid_lock>
    8000156e:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001570:	0000d917          	auipc	s2,0xd
    80001574:	24090913          	addi	s2,s2,576 # 8000e7b0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001578:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000157c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001580:	10079073          	csrw	sstatus,a5
    80001584:	00008497          	auipc	s1,0x8
    80001588:	82c48493          	addi	s1,s1,-2004 # 80008db0 <proc>
    8000158c:	a03d                	j	800015ba <scheduler+0x8e>
        p->state = RUNNING;
    8000158e:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001592:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001596:	06048593          	addi	a1,s1,96
    8000159a:	8556                	mv	a0,s5
    8000159c:	00000097          	auipc	ra,0x0
    800015a0:	6a4080e7          	jalr	1700(ra) # 80001c40 <swtch>
        c->proc = 0;
    800015a4:	020a3823          	sd	zero,48(s4)
      release(&p->lock);
    800015a8:	8526                	mv	a0,s1
    800015aa:	00005097          	auipc	ra,0x5
    800015ae:	f06080e7          	jalr	-250(ra) # 800064b0 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    800015b2:	16848493          	addi	s1,s1,360
    800015b6:	fd2481e3          	beq	s1,s2,80001578 <scheduler+0x4c>
      acquire(&p->lock);
    800015ba:	8526                	mv	a0,s1
    800015bc:	00005097          	auipc	ra,0x5
    800015c0:	e40080e7          	jalr	-448(ra) # 800063fc <acquire>
      if(p->state == RUNNABLE) {
    800015c4:	4c9c                	lw	a5,24(s1)
    800015c6:	ff3791e3          	bne	a5,s3,800015a8 <scheduler+0x7c>
    800015ca:	b7d1                	j	8000158e <scheduler+0x62>

00000000800015cc <sched>:
{
    800015cc:	7179                	addi	sp,sp,-48
    800015ce:	f406                	sd	ra,40(sp)
    800015d0:	f022                	sd	s0,32(sp)
    800015d2:	ec26                	sd	s1,24(sp)
    800015d4:	e84a                	sd	s2,16(sp)
    800015d6:	e44e                	sd	s3,8(sp)
    800015d8:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800015da:	00000097          	auipc	ra,0x0
    800015de:	95a080e7          	jalr	-1702(ra) # 80000f34 <myproc>
    800015e2:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800015e4:	00005097          	auipc	ra,0x5
    800015e8:	d9e080e7          	jalr	-610(ra) # 80006382 <holding>
    800015ec:	c93d                	beqz	a0,80001662 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    800015ee:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800015f0:	2781                	sext.w	a5,a5
    800015f2:	079e                	slli	a5,a5,0x7
    800015f4:	00007717          	auipc	a4,0x7
    800015f8:	38c70713          	addi	a4,a4,908 # 80008980 <pid_lock>
    800015fc:	97ba                	add	a5,a5,a4
    800015fe:	0a87a703          	lw	a4,168(a5)
    80001602:	4785                	li	a5,1
    80001604:	06f71763          	bne	a4,a5,80001672 <sched+0xa6>
  if(p->state == RUNNING)
    80001608:	4c98                	lw	a4,24(s1)
    8000160a:	4791                	li	a5,4
    8000160c:	06f70b63          	beq	a4,a5,80001682 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001610:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001614:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001616:	efb5                	bnez	a5,80001692 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001618:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000161a:	00007917          	auipc	s2,0x7
    8000161e:	36690913          	addi	s2,s2,870 # 80008980 <pid_lock>
    80001622:	2781                	sext.w	a5,a5
    80001624:	079e                	slli	a5,a5,0x7
    80001626:	97ca                	add	a5,a5,s2
    80001628:	0ac7a983          	lw	s3,172(a5)
    8000162c:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000162e:	2781                	sext.w	a5,a5
    80001630:	079e                	slli	a5,a5,0x7
    80001632:	00007597          	auipc	a1,0x7
    80001636:	38658593          	addi	a1,a1,902 # 800089b8 <cpus+0x8>
    8000163a:	95be                	add	a1,a1,a5
    8000163c:	06048513          	addi	a0,s1,96
    80001640:	00000097          	auipc	ra,0x0
    80001644:	600080e7          	jalr	1536(ra) # 80001c40 <swtch>
    80001648:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000164a:	2781                	sext.w	a5,a5
    8000164c:	079e                	slli	a5,a5,0x7
    8000164e:	97ca                	add	a5,a5,s2
    80001650:	0b37a623          	sw	s3,172(a5)
}
    80001654:	70a2                	ld	ra,40(sp)
    80001656:	7402                	ld	s0,32(sp)
    80001658:	64e2                	ld	s1,24(sp)
    8000165a:	6942                	ld	s2,16(sp)
    8000165c:	69a2                	ld	s3,8(sp)
    8000165e:	6145                	addi	sp,sp,48
    80001660:	8082                	ret
    panic("sched p->lock");
    80001662:	00007517          	auipc	a0,0x7
    80001666:	b6650513          	addi	a0,a0,-1178 # 800081c8 <etext+0x1c8>
    8000166a:	00005097          	auipc	ra,0x5
    8000166e:	848080e7          	jalr	-1976(ra) # 80005eb2 <panic>
    panic("sched locks");
    80001672:	00007517          	auipc	a0,0x7
    80001676:	b6650513          	addi	a0,a0,-1178 # 800081d8 <etext+0x1d8>
    8000167a:	00005097          	auipc	ra,0x5
    8000167e:	838080e7          	jalr	-1992(ra) # 80005eb2 <panic>
    panic("sched running");
    80001682:	00007517          	auipc	a0,0x7
    80001686:	b6650513          	addi	a0,a0,-1178 # 800081e8 <etext+0x1e8>
    8000168a:	00005097          	auipc	ra,0x5
    8000168e:	828080e7          	jalr	-2008(ra) # 80005eb2 <panic>
    panic("sched interruptible");
    80001692:	00007517          	auipc	a0,0x7
    80001696:	b6650513          	addi	a0,a0,-1178 # 800081f8 <etext+0x1f8>
    8000169a:	00005097          	auipc	ra,0x5
    8000169e:	818080e7          	jalr	-2024(ra) # 80005eb2 <panic>

00000000800016a2 <yield>:
{
    800016a2:	1101                	addi	sp,sp,-32
    800016a4:	ec06                	sd	ra,24(sp)
    800016a6:	e822                	sd	s0,16(sp)
    800016a8:	e426                	sd	s1,8(sp)
    800016aa:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800016ac:	00000097          	auipc	ra,0x0
    800016b0:	888080e7          	jalr	-1912(ra) # 80000f34 <myproc>
    800016b4:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800016b6:	00005097          	auipc	ra,0x5
    800016ba:	d46080e7          	jalr	-698(ra) # 800063fc <acquire>
  p->state = RUNNABLE;
    800016be:	478d                	li	a5,3
    800016c0:	cc9c                	sw	a5,24(s1)
  sched();
    800016c2:	00000097          	auipc	ra,0x0
    800016c6:	f0a080e7          	jalr	-246(ra) # 800015cc <sched>
  release(&p->lock);
    800016ca:	8526                	mv	a0,s1
    800016cc:	00005097          	auipc	ra,0x5
    800016d0:	de4080e7          	jalr	-540(ra) # 800064b0 <release>
}
    800016d4:	60e2                	ld	ra,24(sp)
    800016d6:	6442                	ld	s0,16(sp)
    800016d8:	64a2                	ld	s1,8(sp)
    800016da:	6105                	addi	sp,sp,32
    800016dc:	8082                	ret

00000000800016de <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800016de:	7179                	addi	sp,sp,-48
    800016e0:	f406                	sd	ra,40(sp)
    800016e2:	f022                	sd	s0,32(sp)
    800016e4:	ec26                	sd	s1,24(sp)
    800016e6:	e84a                	sd	s2,16(sp)
    800016e8:	e44e                	sd	s3,8(sp)
    800016ea:	1800                	addi	s0,sp,48
    800016ec:	89aa                	mv	s3,a0
    800016ee:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800016f0:	00000097          	auipc	ra,0x0
    800016f4:	844080e7          	jalr	-1980(ra) # 80000f34 <myproc>
    800016f8:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800016fa:	00005097          	auipc	ra,0x5
    800016fe:	d02080e7          	jalr	-766(ra) # 800063fc <acquire>
  release(lk);
    80001702:	854a                	mv	a0,s2
    80001704:	00005097          	auipc	ra,0x5
    80001708:	dac080e7          	jalr	-596(ra) # 800064b0 <release>

  // Go to sleep.
  p->chan = chan;
    8000170c:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001710:	4789                	li	a5,2
    80001712:	cc9c                	sw	a5,24(s1)

  sched();
    80001714:	00000097          	auipc	ra,0x0
    80001718:	eb8080e7          	jalr	-328(ra) # 800015cc <sched>

  // Tidy up.
  p->chan = 0;
    8000171c:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001720:	8526                	mv	a0,s1
    80001722:	00005097          	auipc	ra,0x5
    80001726:	d8e080e7          	jalr	-626(ra) # 800064b0 <release>
  acquire(lk);
    8000172a:	854a                	mv	a0,s2
    8000172c:	00005097          	auipc	ra,0x5
    80001730:	cd0080e7          	jalr	-816(ra) # 800063fc <acquire>
}
    80001734:	70a2                	ld	ra,40(sp)
    80001736:	7402                	ld	s0,32(sp)
    80001738:	64e2                	ld	s1,24(sp)
    8000173a:	6942                	ld	s2,16(sp)
    8000173c:	69a2                	ld	s3,8(sp)
    8000173e:	6145                	addi	sp,sp,48
    80001740:	8082                	ret

0000000080001742 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80001742:	7139                	addi	sp,sp,-64
    80001744:	fc06                	sd	ra,56(sp)
    80001746:	f822                	sd	s0,48(sp)
    80001748:	f426                	sd	s1,40(sp)
    8000174a:	f04a                	sd	s2,32(sp)
    8000174c:	ec4e                	sd	s3,24(sp)
    8000174e:	e852                	sd	s4,16(sp)
    80001750:	e456                	sd	s5,8(sp)
    80001752:	0080                	addi	s0,sp,64
    80001754:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001756:	00007497          	auipc	s1,0x7
    8000175a:	65a48493          	addi	s1,s1,1626 # 80008db0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    8000175e:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001760:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001762:	0000d917          	auipc	s2,0xd
    80001766:	04e90913          	addi	s2,s2,78 # 8000e7b0 <tickslock>
    8000176a:	a821                	j	80001782 <wakeup+0x40>
        p->state = RUNNABLE;
    8000176c:	0154ac23          	sw	s5,24(s1)
      }
      release(&p->lock);
    80001770:	8526                	mv	a0,s1
    80001772:	00005097          	auipc	ra,0x5
    80001776:	d3e080e7          	jalr	-706(ra) # 800064b0 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000177a:	16848493          	addi	s1,s1,360
    8000177e:	03248463          	beq	s1,s2,800017a6 <wakeup+0x64>
    if(p != myproc()){
    80001782:	fffff097          	auipc	ra,0xfffff
    80001786:	7b2080e7          	jalr	1970(ra) # 80000f34 <myproc>
    8000178a:	fea488e3          	beq	s1,a0,8000177a <wakeup+0x38>
      acquire(&p->lock);
    8000178e:	8526                	mv	a0,s1
    80001790:	00005097          	auipc	ra,0x5
    80001794:	c6c080e7          	jalr	-916(ra) # 800063fc <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001798:	4c9c                	lw	a5,24(s1)
    8000179a:	fd379be3          	bne	a5,s3,80001770 <wakeup+0x2e>
    8000179e:	709c                	ld	a5,32(s1)
    800017a0:	fd4798e3          	bne	a5,s4,80001770 <wakeup+0x2e>
    800017a4:	b7e1                	j	8000176c <wakeup+0x2a>
    }
  }
}
    800017a6:	70e2                	ld	ra,56(sp)
    800017a8:	7442                	ld	s0,48(sp)
    800017aa:	74a2                	ld	s1,40(sp)
    800017ac:	7902                	ld	s2,32(sp)
    800017ae:	69e2                	ld	s3,24(sp)
    800017b0:	6a42                	ld	s4,16(sp)
    800017b2:	6aa2                	ld	s5,8(sp)
    800017b4:	6121                	addi	sp,sp,64
    800017b6:	8082                	ret

00000000800017b8 <reparent>:
{
    800017b8:	7179                	addi	sp,sp,-48
    800017ba:	f406                	sd	ra,40(sp)
    800017bc:	f022                	sd	s0,32(sp)
    800017be:	ec26                	sd	s1,24(sp)
    800017c0:	e84a                	sd	s2,16(sp)
    800017c2:	e44e                	sd	s3,8(sp)
    800017c4:	e052                	sd	s4,0(sp)
    800017c6:	1800                	addi	s0,sp,48
    800017c8:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800017ca:	00007497          	auipc	s1,0x7
    800017ce:	5e648493          	addi	s1,s1,1510 # 80008db0 <proc>
      pp->parent = initproc;
    800017d2:	00007a17          	auipc	s4,0x7
    800017d6:	16ea0a13          	addi	s4,s4,366 # 80008940 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800017da:	0000d997          	auipc	s3,0xd
    800017de:	fd698993          	addi	s3,s3,-42 # 8000e7b0 <tickslock>
    800017e2:	a029                	j	800017ec <reparent+0x34>
    800017e4:	16848493          	addi	s1,s1,360
    800017e8:	01348d63          	beq	s1,s3,80001802 <reparent+0x4a>
    if(pp->parent == p){
    800017ec:	7c9c                	ld	a5,56(s1)
    800017ee:	ff279be3          	bne	a5,s2,800017e4 <reparent+0x2c>
      pp->parent = initproc;
    800017f2:	000a3503          	ld	a0,0(s4)
    800017f6:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800017f8:	00000097          	auipc	ra,0x0
    800017fc:	f4a080e7          	jalr	-182(ra) # 80001742 <wakeup>
    80001800:	b7d5                	j	800017e4 <reparent+0x2c>
}
    80001802:	70a2                	ld	ra,40(sp)
    80001804:	7402                	ld	s0,32(sp)
    80001806:	64e2                	ld	s1,24(sp)
    80001808:	6942                	ld	s2,16(sp)
    8000180a:	69a2                	ld	s3,8(sp)
    8000180c:	6a02                	ld	s4,0(sp)
    8000180e:	6145                	addi	sp,sp,48
    80001810:	8082                	ret

0000000080001812 <exit>:
{
    80001812:	7179                	addi	sp,sp,-48
    80001814:	f406                	sd	ra,40(sp)
    80001816:	f022                	sd	s0,32(sp)
    80001818:	ec26                	sd	s1,24(sp)
    8000181a:	e84a                	sd	s2,16(sp)
    8000181c:	e44e                	sd	s3,8(sp)
    8000181e:	e052                	sd	s4,0(sp)
    80001820:	1800                	addi	s0,sp,48
    80001822:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80001824:	fffff097          	auipc	ra,0xfffff
    80001828:	710080e7          	jalr	1808(ra) # 80000f34 <myproc>
    8000182c:	89aa                	mv	s3,a0
  if(p == initproc)
    8000182e:	00007797          	auipc	a5,0x7
    80001832:	1127b783          	ld	a5,274(a5) # 80008940 <initproc>
    80001836:	0d050493          	addi	s1,a0,208
    8000183a:	15050913          	addi	s2,a0,336
    8000183e:	02a79363          	bne	a5,a0,80001864 <exit+0x52>
    panic("init exiting");
    80001842:	00007517          	auipc	a0,0x7
    80001846:	9ce50513          	addi	a0,a0,-1586 # 80008210 <etext+0x210>
    8000184a:	00004097          	auipc	ra,0x4
    8000184e:	668080e7          	jalr	1640(ra) # 80005eb2 <panic>
      fileclose(f);
    80001852:	00002097          	auipc	ra,0x2
    80001856:	3de080e7          	jalr	990(ra) # 80003c30 <fileclose>
      p->ofile[fd] = 0;
    8000185a:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000185e:	04a1                	addi	s1,s1,8
    80001860:	01248563          	beq	s1,s2,8000186a <exit+0x58>
    if(p->ofile[fd]){
    80001864:	6088                	ld	a0,0(s1)
    80001866:	f575                	bnez	a0,80001852 <exit+0x40>
    80001868:	bfdd                	j	8000185e <exit+0x4c>
  begin_op();
    8000186a:	00002097          	auipc	ra,0x2
    8000186e:	efa080e7          	jalr	-262(ra) # 80003764 <begin_op>
  iput(p->cwd);
    80001872:	1509b503          	ld	a0,336(s3)
    80001876:	00001097          	auipc	ra,0x1
    8000187a:	6e6080e7          	jalr	1766(ra) # 80002f5c <iput>
  end_op();
    8000187e:	00002097          	auipc	ra,0x2
    80001882:	f66080e7          	jalr	-154(ra) # 800037e4 <end_op>
  p->cwd = 0;
    80001886:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000188a:	00007497          	auipc	s1,0x7
    8000188e:	10e48493          	addi	s1,s1,270 # 80008998 <wait_lock>
    80001892:	8526                	mv	a0,s1
    80001894:	00005097          	auipc	ra,0x5
    80001898:	b68080e7          	jalr	-1176(ra) # 800063fc <acquire>
  reparent(p);
    8000189c:	854e                	mv	a0,s3
    8000189e:	00000097          	auipc	ra,0x0
    800018a2:	f1a080e7          	jalr	-230(ra) # 800017b8 <reparent>
  wakeup(p->parent);
    800018a6:	0389b503          	ld	a0,56(s3)
    800018aa:	00000097          	auipc	ra,0x0
    800018ae:	e98080e7          	jalr	-360(ra) # 80001742 <wakeup>
  acquire(&p->lock);
    800018b2:	854e                	mv	a0,s3
    800018b4:	00005097          	auipc	ra,0x5
    800018b8:	b48080e7          	jalr	-1208(ra) # 800063fc <acquire>
  p->xstate = status;
    800018bc:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800018c0:	4795                	li	a5,5
    800018c2:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800018c6:	8526                	mv	a0,s1
    800018c8:	00005097          	auipc	ra,0x5
    800018cc:	be8080e7          	jalr	-1048(ra) # 800064b0 <release>
  sched();
    800018d0:	00000097          	auipc	ra,0x0
    800018d4:	cfc080e7          	jalr	-772(ra) # 800015cc <sched>
  panic("zombie exit");
    800018d8:	00007517          	auipc	a0,0x7
    800018dc:	94850513          	addi	a0,a0,-1720 # 80008220 <etext+0x220>
    800018e0:	00004097          	auipc	ra,0x4
    800018e4:	5d2080e7          	jalr	1490(ra) # 80005eb2 <panic>

00000000800018e8 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800018e8:	7179                	addi	sp,sp,-48
    800018ea:	f406                	sd	ra,40(sp)
    800018ec:	f022                	sd	s0,32(sp)
    800018ee:	ec26                	sd	s1,24(sp)
    800018f0:	e84a                	sd	s2,16(sp)
    800018f2:	e44e                	sd	s3,8(sp)
    800018f4:	1800                	addi	s0,sp,48
    800018f6:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800018f8:	00007497          	auipc	s1,0x7
    800018fc:	4b848493          	addi	s1,s1,1208 # 80008db0 <proc>
    80001900:	0000d997          	auipc	s3,0xd
    80001904:	eb098993          	addi	s3,s3,-336 # 8000e7b0 <tickslock>
    acquire(&p->lock);
    80001908:	8526                	mv	a0,s1
    8000190a:	00005097          	auipc	ra,0x5
    8000190e:	af2080e7          	jalr	-1294(ra) # 800063fc <acquire>
    if(p->pid == pid){
    80001912:	589c                	lw	a5,48(s1)
    80001914:	01278d63          	beq	a5,s2,8000192e <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80001918:	8526                	mv	a0,s1
    8000191a:	00005097          	auipc	ra,0x5
    8000191e:	b96080e7          	jalr	-1130(ra) # 800064b0 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80001922:	16848493          	addi	s1,s1,360
    80001926:	ff3491e3          	bne	s1,s3,80001908 <kill+0x20>
  }
  return -1;
    8000192a:	557d                	li	a0,-1
    8000192c:	a829                	j	80001946 <kill+0x5e>
      p->killed = 1;
    8000192e:	4785                	li	a5,1
    80001930:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80001932:	4c98                	lw	a4,24(s1)
    80001934:	4789                	li	a5,2
    80001936:	00f70f63          	beq	a4,a5,80001954 <kill+0x6c>
      release(&p->lock);
    8000193a:	8526                	mv	a0,s1
    8000193c:	00005097          	auipc	ra,0x5
    80001940:	b74080e7          	jalr	-1164(ra) # 800064b0 <release>
      return 0;
    80001944:	4501                	li	a0,0
}
    80001946:	70a2                	ld	ra,40(sp)
    80001948:	7402                	ld	s0,32(sp)
    8000194a:	64e2                	ld	s1,24(sp)
    8000194c:	6942                	ld	s2,16(sp)
    8000194e:	69a2                	ld	s3,8(sp)
    80001950:	6145                	addi	sp,sp,48
    80001952:	8082                	ret
        p->state = RUNNABLE;
    80001954:	478d                	li	a5,3
    80001956:	cc9c                	sw	a5,24(s1)
    80001958:	b7cd                	j	8000193a <kill+0x52>

000000008000195a <setkilled>:

void
setkilled(struct proc *p)
{
    8000195a:	1101                	addi	sp,sp,-32
    8000195c:	ec06                	sd	ra,24(sp)
    8000195e:	e822                	sd	s0,16(sp)
    80001960:	e426                	sd	s1,8(sp)
    80001962:	1000                	addi	s0,sp,32
    80001964:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001966:	00005097          	auipc	ra,0x5
    8000196a:	a96080e7          	jalr	-1386(ra) # 800063fc <acquire>
  p->killed = 1;
    8000196e:	4785                	li	a5,1
    80001970:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80001972:	8526                	mv	a0,s1
    80001974:	00005097          	auipc	ra,0x5
    80001978:	b3c080e7          	jalr	-1220(ra) # 800064b0 <release>
}
    8000197c:	60e2                	ld	ra,24(sp)
    8000197e:	6442                	ld	s0,16(sp)
    80001980:	64a2                	ld	s1,8(sp)
    80001982:	6105                	addi	sp,sp,32
    80001984:	8082                	ret

0000000080001986 <killed>:

int
killed(struct proc *p)
{
    80001986:	1101                	addi	sp,sp,-32
    80001988:	ec06                	sd	ra,24(sp)
    8000198a:	e822                	sd	s0,16(sp)
    8000198c:	e426                	sd	s1,8(sp)
    8000198e:	e04a                	sd	s2,0(sp)
    80001990:	1000                	addi	s0,sp,32
    80001992:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80001994:	00005097          	auipc	ra,0x5
    80001998:	a68080e7          	jalr	-1432(ra) # 800063fc <acquire>
  k = p->killed;
    8000199c:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800019a0:	8526                	mv	a0,s1
    800019a2:	00005097          	auipc	ra,0x5
    800019a6:	b0e080e7          	jalr	-1266(ra) # 800064b0 <release>
  return k;
}
    800019aa:	854a                	mv	a0,s2
    800019ac:	60e2                	ld	ra,24(sp)
    800019ae:	6442                	ld	s0,16(sp)
    800019b0:	64a2                	ld	s1,8(sp)
    800019b2:	6902                	ld	s2,0(sp)
    800019b4:	6105                	addi	sp,sp,32
    800019b6:	8082                	ret

00000000800019b8 <wait>:
{
    800019b8:	715d                	addi	sp,sp,-80
    800019ba:	e486                	sd	ra,72(sp)
    800019bc:	e0a2                	sd	s0,64(sp)
    800019be:	fc26                	sd	s1,56(sp)
    800019c0:	f84a                	sd	s2,48(sp)
    800019c2:	f44e                	sd	s3,40(sp)
    800019c4:	f052                	sd	s4,32(sp)
    800019c6:	ec56                	sd	s5,24(sp)
    800019c8:	e85a                	sd	s6,16(sp)
    800019ca:	e45e                	sd	s7,8(sp)
    800019cc:	e062                	sd	s8,0(sp)
    800019ce:	0880                	addi	s0,sp,80
    800019d0:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800019d2:	fffff097          	auipc	ra,0xfffff
    800019d6:	562080e7          	jalr	1378(ra) # 80000f34 <myproc>
    800019da:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800019dc:	00007517          	auipc	a0,0x7
    800019e0:	fbc50513          	addi	a0,a0,-68 # 80008998 <wait_lock>
    800019e4:	00005097          	auipc	ra,0x5
    800019e8:	a18080e7          	jalr	-1512(ra) # 800063fc <acquire>
    havekids = 0;
    800019ec:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800019ee:	4a15                	li	s4,5
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800019f0:	0000d997          	auipc	s3,0xd
    800019f4:	dc098993          	addi	s3,s3,-576 # 8000e7b0 <tickslock>
        havekids = 1;
    800019f8:	4a85                	li	s5,1
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800019fa:	00007c17          	auipc	s8,0x7
    800019fe:	f9ec0c13          	addi	s8,s8,-98 # 80008998 <wait_lock>
    havekids = 0;
    80001a02:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001a04:	00007497          	auipc	s1,0x7
    80001a08:	3ac48493          	addi	s1,s1,940 # 80008db0 <proc>
    80001a0c:	a0bd                	j	80001a7a <wait+0xc2>
          pid = pp->pid;
    80001a0e:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80001a12:	000b0e63          	beqz	s6,80001a2e <wait+0x76>
    80001a16:	4691                	li	a3,4
    80001a18:	02c48613          	addi	a2,s1,44
    80001a1c:	85da                	mv	a1,s6
    80001a1e:	05093503          	ld	a0,80(s2)
    80001a22:	fffff097          	auipc	ra,0xfffff
    80001a26:	1d4080e7          	jalr	468(ra) # 80000bf6 <copyout>
    80001a2a:	02054563          	bltz	a0,80001a54 <wait+0x9c>
          freeproc(pp);
    80001a2e:	8526                	mv	a0,s1
    80001a30:	fffff097          	auipc	ra,0xfffff
    80001a34:	736080e7          	jalr	1846(ra) # 80001166 <freeproc>
          release(&pp->lock);
    80001a38:	8526                	mv	a0,s1
    80001a3a:	00005097          	auipc	ra,0x5
    80001a3e:	a76080e7          	jalr	-1418(ra) # 800064b0 <release>
          release(&wait_lock);
    80001a42:	00007517          	auipc	a0,0x7
    80001a46:	f5650513          	addi	a0,a0,-170 # 80008998 <wait_lock>
    80001a4a:	00005097          	auipc	ra,0x5
    80001a4e:	a66080e7          	jalr	-1434(ra) # 800064b0 <release>
          return pid;
    80001a52:	a0b5                	j	80001abe <wait+0x106>
            release(&pp->lock);
    80001a54:	8526                	mv	a0,s1
    80001a56:	00005097          	auipc	ra,0x5
    80001a5a:	a5a080e7          	jalr	-1446(ra) # 800064b0 <release>
            release(&wait_lock);
    80001a5e:	00007517          	auipc	a0,0x7
    80001a62:	f3a50513          	addi	a0,a0,-198 # 80008998 <wait_lock>
    80001a66:	00005097          	auipc	ra,0x5
    80001a6a:	a4a080e7          	jalr	-1462(ra) # 800064b0 <release>
            return -1;
    80001a6e:	59fd                	li	s3,-1
    80001a70:	a0b9                	j	80001abe <wait+0x106>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001a72:	16848493          	addi	s1,s1,360
    80001a76:	03348463          	beq	s1,s3,80001a9e <wait+0xe6>
      if(pp->parent == p){
    80001a7a:	7c9c                	ld	a5,56(s1)
    80001a7c:	ff279be3          	bne	a5,s2,80001a72 <wait+0xba>
        acquire(&pp->lock);
    80001a80:	8526                	mv	a0,s1
    80001a82:	00005097          	auipc	ra,0x5
    80001a86:	97a080e7          	jalr	-1670(ra) # 800063fc <acquire>
        if(pp->state == ZOMBIE){
    80001a8a:	4c9c                	lw	a5,24(s1)
    80001a8c:	f94781e3          	beq	a5,s4,80001a0e <wait+0x56>
        release(&pp->lock);
    80001a90:	8526                	mv	a0,s1
    80001a92:	00005097          	auipc	ra,0x5
    80001a96:	a1e080e7          	jalr	-1506(ra) # 800064b0 <release>
        havekids = 1;
    80001a9a:	8756                	mv	a4,s5
    80001a9c:	bfd9                	j	80001a72 <wait+0xba>
    if(!havekids || killed(p)){
    80001a9e:	c719                	beqz	a4,80001aac <wait+0xf4>
    80001aa0:	854a                	mv	a0,s2
    80001aa2:	00000097          	auipc	ra,0x0
    80001aa6:	ee4080e7          	jalr	-284(ra) # 80001986 <killed>
    80001aaa:	c51d                	beqz	a0,80001ad8 <wait+0x120>
      release(&wait_lock);
    80001aac:	00007517          	auipc	a0,0x7
    80001ab0:	eec50513          	addi	a0,a0,-276 # 80008998 <wait_lock>
    80001ab4:	00005097          	auipc	ra,0x5
    80001ab8:	9fc080e7          	jalr	-1540(ra) # 800064b0 <release>
      return -1;
    80001abc:	59fd                	li	s3,-1
}
    80001abe:	854e                	mv	a0,s3
    80001ac0:	60a6                	ld	ra,72(sp)
    80001ac2:	6406                	ld	s0,64(sp)
    80001ac4:	74e2                	ld	s1,56(sp)
    80001ac6:	7942                	ld	s2,48(sp)
    80001ac8:	79a2                	ld	s3,40(sp)
    80001aca:	7a02                	ld	s4,32(sp)
    80001acc:	6ae2                	ld	s5,24(sp)
    80001ace:	6b42                	ld	s6,16(sp)
    80001ad0:	6ba2                	ld	s7,8(sp)
    80001ad2:	6c02                	ld	s8,0(sp)
    80001ad4:	6161                	addi	sp,sp,80
    80001ad6:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80001ad8:	85e2                	mv	a1,s8
    80001ada:	854a                	mv	a0,s2
    80001adc:	00000097          	auipc	ra,0x0
    80001ae0:	c02080e7          	jalr	-1022(ra) # 800016de <sleep>
    havekids = 0;
    80001ae4:	bf39                	j	80001a02 <wait+0x4a>

0000000080001ae6 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80001ae6:	7179                	addi	sp,sp,-48
    80001ae8:	f406                	sd	ra,40(sp)
    80001aea:	f022                	sd	s0,32(sp)
    80001aec:	ec26                	sd	s1,24(sp)
    80001aee:	e84a                	sd	s2,16(sp)
    80001af0:	e44e                	sd	s3,8(sp)
    80001af2:	e052                	sd	s4,0(sp)
    80001af4:	1800                	addi	s0,sp,48
    80001af6:	84aa                	mv	s1,a0
    80001af8:	892e                	mv	s2,a1
    80001afa:	89b2                	mv	s3,a2
    80001afc:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80001afe:	fffff097          	auipc	ra,0xfffff
    80001b02:	436080e7          	jalr	1078(ra) # 80000f34 <myproc>
  if(user_dst){
    80001b06:	c08d                	beqz	s1,80001b28 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80001b08:	86d2                	mv	a3,s4
    80001b0a:	864e                	mv	a2,s3
    80001b0c:	85ca                	mv	a1,s2
    80001b0e:	6928                	ld	a0,80(a0)
    80001b10:	fffff097          	auipc	ra,0xfffff
    80001b14:	0e6080e7          	jalr	230(ra) # 80000bf6 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80001b18:	70a2                	ld	ra,40(sp)
    80001b1a:	7402                	ld	s0,32(sp)
    80001b1c:	64e2                	ld	s1,24(sp)
    80001b1e:	6942                	ld	s2,16(sp)
    80001b20:	69a2                	ld	s3,8(sp)
    80001b22:	6a02                	ld	s4,0(sp)
    80001b24:	6145                	addi	sp,sp,48
    80001b26:	8082                	ret
    memmove((char *)dst, src, len);
    80001b28:	000a061b          	sext.w	a2,s4
    80001b2c:	85ce                	mv	a1,s3
    80001b2e:	854a                	mv	a0,s2
    80001b30:	ffffe097          	auipc	ra,0xffffe
    80001b34:	6a8080e7          	jalr	1704(ra) # 800001d8 <memmove>
    return 0;
    80001b38:	8526                	mv	a0,s1
    80001b3a:	bff9                	j	80001b18 <either_copyout+0x32>

0000000080001b3c <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80001b3c:	7179                	addi	sp,sp,-48
    80001b3e:	f406                	sd	ra,40(sp)
    80001b40:	f022                	sd	s0,32(sp)
    80001b42:	ec26                	sd	s1,24(sp)
    80001b44:	e84a                	sd	s2,16(sp)
    80001b46:	e44e                	sd	s3,8(sp)
    80001b48:	e052                	sd	s4,0(sp)
    80001b4a:	1800                	addi	s0,sp,48
    80001b4c:	892a                	mv	s2,a0
    80001b4e:	84ae                	mv	s1,a1
    80001b50:	89b2                	mv	s3,a2
    80001b52:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80001b54:	fffff097          	auipc	ra,0xfffff
    80001b58:	3e0080e7          	jalr	992(ra) # 80000f34 <myproc>
  if(user_src){
    80001b5c:	c08d                	beqz	s1,80001b7e <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80001b5e:	86d2                	mv	a3,s4
    80001b60:	864e                	mv	a2,s3
    80001b62:	85ca                	mv	a1,s2
    80001b64:	6928                	ld	a0,80(a0)
    80001b66:	fffff097          	auipc	ra,0xfffff
    80001b6a:	11c080e7          	jalr	284(ra) # 80000c82 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80001b6e:	70a2                	ld	ra,40(sp)
    80001b70:	7402                	ld	s0,32(sp)
    80001b72:	64e2                	ld	s1,24(sp)
    80001b74:	6942                	ld	s2,16(sp)
    80001b76:	69a2                	ld	s3,8(sp)
    80001b78:	6a02                	ld	s4,0(sp)
    80001b7a:	6145                	addi	sp,sp,48
    80001b7c:	8082                	ret
    memmove(dst, (char*)src, len);
    80001b7e:	000a061b          	sext.w	a2,s4
    80001b82:	85ce                	mv	a1,s3
    80001b84:	854a                	mv	a0,s2
    80001b86:	ffffe097          	auipc	ra,0xffffe
    80001b8a:	652080e7          	jalr	1618(ra) # 800001d8 <memmove>
    return 0;
    80001b8e:	8526                	mv	a0,s1
    80001b90:	bff9                	j	80001b6e <either_copyin+0x32>

0000000080001b92 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80001b92:	715d                	addi	sp,sp,-80
    80001b94:	e486                	sd	ra,72(sp)
    80001b96:	e0a2                	sd	s0,64(sp)
    80001b98:	fc26                	sd	s1,56(sp)
    80001b9a:	f84a                	sd	s2,48(sp)
    80001b9c:	f44e                	sd	s3,40(sp)
    80001b9e:	f052                	sd	s4,32(sp)
    80001ba0:	ec56                	sd	s5,24(sp)
    80001ba2:	e85a                	sd	s6,16(sp)
    80001ba4:	e45e                	sd	s7,8(sp)
    80001ba6:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80001ba8:	00006517          	auipc	a0,0x6
    80001bac:	4a050513          	addi	a0,a0,1184 # 80008048 <etext+0x48>
    80001bb0:	00004097          	auipc	ra,0x4
    80001bb4:	34c080e7          	jalr	844(ra) # 80005efc <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80001bb8:	00007497          	auipc	s1,0x7
    80001bbc:	35048493          	addi	s1,s1,848 # 80008f08 <proc+0x158>
    80001bc0:	0000d917          	auipc	s2,0xd
    80001bc4:	d4890913          	addi	s2,s2,-696 # 8000e908 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001bc8:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80001bca:	00006997          	auipc	s3,0x6
    80001bce:	66698993          	addi	s3,s3,1638 # 80008230 <etext+0x230>
    printf("%d %s %s", p->pid, state, p->name);
    80001bd2:	00006a97          	auipc	s5,0x6
    80001bd6:	666a8a93          	addi	s5,s5,1638 # 80008238 <etext+0x238>
    printf("\n");
    80001bda:	00006a17          	auipc	s4,0x6
    80001bde:	46ea0a13          	addi	s4,s4,1134 # 80008048 <etext+0x48>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001be2:	00006b97          	auipc	s7,0x6
    80001be6:	696b8b93          	addi	s7,s7,1686 # 80008278 <states.1730>
    80001bea:	a00d                	j	80001c0c <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80001bec:	ed86a583          	lw	a1,-296(a3)
    80001bf0:	8556                	mv	a0,s5
    80001bf2:	00004097          	auipc	ra,0x4
    80001bf6:	30a080e7          	jalr	778(ra) # 80005efc <printf>
    printf("\n");
    80001bfa:	8552                	mv	a0,s4
    80001bfc:	00004097          	auipc	ra,0x4
    80001c00:	300080e7          	jalr	768(ra) # 80005efc <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80001c04:	16848493          	addi	s1,s1,360
    80001c08:	03248163          	beq	s1,s2,80001c2a <procdump+0x98>
    if(p->state == UNUSED)
    80001c0c:	86a6                	mv	a3,s1
    80001c0e:	ec04a783          	lw	a5,-320(s1)
    80001c12:	dbed                	beqz	a5,80001c04 <procdump+0x72>
      state = "???";
    80001c14:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001c16:	fcfb6be3          	bltu	s6,a5,80001bec <procdump+0x5a>
    80001c1a:	1782                	slli	a5,a5,0x20
    80001c1c:	9381                	srli	a5,a5,0x20
    80001c1e:	078e                	slli	a5,a5,0x3
    80001c20:	97de                	add	a5,a5,s7
    80001c22:	6390                	ld	a2,0(a5)
    80001c24:	f661                	bnez	a2,80001bec <procdump+0x5a>
      state = "???";
    80001c26:	864e                	mv	a2,s3
    80001c28:	b7d1                	j	80001bec <procdump+0x5a>
  }
}
    80001c2a:	60a6                	ld	ra,72(sp)
    80001c2c:	6406                	ld	s0,64(sp)
    80001c2e:	74e2                	ld	s1,56(sp)
    80001c30:	7942                	ld	s2,48(sp)
    80001c32:	79a2                	ld	s3,40(sp)
    80001c34:	7a02                	ld	s4,32(sp)
    80001c36:	6ae2                	ld	s5,24(sp)
    80001c38:	6b42                	ld	s6,16(sp)
    80001c3a:	6ba2                	ld	s7,8(sp)
    80001c3c:	6161                	addi	sp,sp,80
    80001c3e:	8082                	ret

0000000080001c40 <swtch>:
    80001c40:	00153023          	sd	ra,0(a0)
    80001c44:	00253423          	sd	sp,8(a0)
    80001c48:	e900                	sd	s0,16(a0)
    80001c4a:	ed04                	sd	s1,24(a0)
    80001c4c:	03253023          	sd	s2,32(a0)
    80001c50:	03353423          	sd	s3,40(a0)
    80001c54:	03453823          	sd	s4,48(a0)
    80001c58:	03553c23          	sd	s5,56(a0)
    80001c5c:	05653023          	sd	s6,64(a0)
    80001c60:	05753423          	sd	s7,72(a0)
    80001c64:	05853823          	sd	s8,80(a0)
    80001c68:	05953c23          	sd	s9,88(a0)
    80001c6c:	07a53023          	sd	s10,96(a0)
    80001c70:	07b53423          	sd	s11,104(a0)
    80001c74:	0005b083          	ld	ra,0(a1)
    80001c78:	0085b103          	ld	sp,8(a1)
    80001c7c:	6980                	ld	s0,16(a1)
    80001c7e:	6d84                	ld	s1,24(a1)
    80001c80:	0205b903          	ld	s2,32(a1)
    80001c84:	0285b983          	ld	s3,40(a1)
    80001c88:	0305ba03          	ld	s4,48(a1)
    80001c8c:	0385ba83          	ld	s5,56(a1)
    80001c90:	0405bb03          	ld	s6,64(a1)
    80001c94:	0485bb83          	ld	s7,72(a1)
    80001c98:	0505bc03          	ld	s8,80(a1)
    80001c9c:	0585bc83          	ld	s9,88(a1)
    80001ca0:	0605bd03          	ld	s10,96(a1)
    80001ca4:	0685bd83          	ld	s11,104(a1)
    80001ca8:	8082                	ret

0000000080001caa <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80001caa:	1141                	addi	sp,sp,-16
    80001cac:	e406                	sd	ra,8(sp)
    80001cae:	e022                	sd	s0,0(sp)
    80001cb0:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80001cb2:	00006597          	auipc	a1,0x6
    80001cb6:	5f658593          	addi	a1,a1,1526 # 800082a8 <states.1730+0x30>
    80001cba:	0000d517          	auipc	a0,0xd
    80001cbe:	af650513          	addi	a0,a0,-1290 # 8000e7b0 <tickslock>
    80001cc2:	00004097          	auipc	ra,0x4
    80001cc6:	6aa080e7          	jalr	1706(ra) # 8000636c <initlock>
}
    80001cca:	60a2                	ld	ra,8(sp)
    80001ccc:	6402                	ld	s0,0(sp)
    80001cce:	0141                	addi	sp,sp,16
    80001cd0:	8082                	ret

0000000080001cd2 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80001cd2:	1141                	addi	sp,sp,-16
    80001cd4:	e422                	sd	s0,8(sp)
    80001cd6:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001cd8:	00003797          	auipc	a5,0x3
    80001cdc:	5a878793          	addi	a5,a5,1448 # 80005280 <kernelvec>
    80001ce0:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80001ce4:	6422                	ld	s0,8(sp)
    80001ce6:	0141                	addi	sp,sp,16
    80001ce8:	8082                	ret

0000000080001cea <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80001cea:	1141                	addi	sp,sp,-16
    80001cec:	e406                	sd	ra,8(sp)
    80001cee:	e022                	sd	s0,0(sp)
    80001cf0:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80001cf2:	fffff097          	auipc	ra,0xfffff
    80001cf6:	242080e7          	jalr	578(ra) # 80000f34 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001cfa:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001cfe:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001d00:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80001d04:	00005617          	auipc	a2,0x5
    80001d08:	2fc60613          	addi	a2,a2,764 # 80007000 <_trampoline>
    80001d0c:	00005697          	auipc	a3,0x5
    80001d10:	2f468693          	addi	a3,a3,756 # 80007000 <_trampoline>
    80001d14:	8e91                	sub	a3,a3,a2
    80001d16:	040007b7          	lui	a5,0x4000
    80001d1a:	17fd                	addi	a5,a5,-1
    80001d1c:	07b2                	slli	a5,a5,0xc
    80001d1e:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001d20:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80001d24:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80001d26:	180026f3          	csrr	a3,satp
    80001d2a:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80001d2c:	6d38                	ld	a4,88(a0)
    80001d2e:	6134                	ld	a3,64(a0)
    80001d30:	6585                	lui	a1,0x1
    80001d32:	96ae                	add	a3,a3,a1
    80001d34:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80001d36:	6d38                	ld	a4,88(a0)
    80001d38:	00000697          	auipc	a3,0x0
    80001d3c:	13068693          	addi	a3,a3,304 # 80001e68 <usertrap>
    80001d40:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80001d42:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80001d44:	8692                	mv	a3,tp
    80001d46:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001d48:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80001d4c:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80001d50:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001d54:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80001d58:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001d5a:	6f18                	ld	a4,24(a4)
    80001d5c:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80001d60:	6928                	ld	a0,80(a0)
    80001d62:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001d64:	00005717          	auipc	a4,0x5
    80001d68:	33870713          	addi	a4,a4,824 # 8000709c <userret>
    80001d6c:	8f11                	sub	a4,a4,a2
    80001d6e:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001d70:	577d                	li	a4,-1
    80001d72:	177e                	slli	a4,a4,0x3f
    80001d74:	8d59                	or	a0,a0,a4
    80001d76:	9782                	jalr	a5
}
    80001d78:	60a2                	ld	ra,8(sp)
    80001d7a:	6402                	ld	s0,0(sp)
    80001d7c:	0141                	addi	sp,sp,16
    80001d7e:	8082                	ret

0000000080001d80 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80001d80:	1101                	addi	sp,sp,-32
    80001d82:	ec06                	sd	ra,24(sp)
    80001d84:	e822                	sd	s0,16(sp)
    80001d86:	e426                	sd	s1,8(sp)
    80001d88:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80001d8a:	0000d497          	auipc	s1,0xd
    80001d8e:	a2648493          	addi	s1,s1,-1498 # 8000e7b0 <tickslock>
    80001d92:	8526                	mv	a0,s1
    80001d94:	00004097          	auipc	ra,0x4
    80001d98:	668080e7          	jalr	1640(ra) # 800063fc <acquire>
  ticks++;
    80001d9c:	00007517          	auipc	a0,0x7
    80001da0:	bac50513          	addi	a0,a0,-1108 # 80008948 <ticks>
    80001da4:	411c                	lw	a5,0(a0)
    80001da6:	2785                	addiw	a5,a5,1
    80001da8:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80001daa:	00000097          	auipc	ra,0x0
    80001dae:	998080e7          	jalr	-1640(ra) # 80001742 <wakeup>
  release(&tickslock);
    80001db2:	8526                	mv	a0,s1
    80001db4:	00004097          	auipc	ra,0x4
    80001db8:	6fc080e7          	jalr	1788(ra) # 800064b0 <release>
}
    80001dbc:	60e2                	ld	ra,24(sp)
    80001dbe:	6442                	ld	s0,16(sp)
    80001dc0:	64a2                	ld	s1,8(sp)
    80001dc2:	6105                	addi	sp,sp,32
    80001dc4:	8082                	ret

0000000080001dc6 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80001dc6:	1101                	addi	sp,sp,-32
    80001dc8:	ec06                	sd	ra,24(sp)
    80001dca:	e822                	sd	s0,16(sp)
    80001dcc:	e426                	sd	s1,8(sp)
    80001dce:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001dd0:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80001dd4:	00074d63          	bltz	a4,80001dee <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80001dd8:	57fd                	li	a5,-1
    80001dda:	17fe                	slli	a5,a5,0x3f
    80001ddc:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80001dde:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80001de0:	06f70363          	beq	a4,a5,80001e46 <devintr+0x80>
  }
}
    80001de4:	60e2                	ld	ra,24(sp)
    80001de6:	6442                	ld	s0,16(sp)
    80001de8:	64a2                	ld	s1,8(sp)
    80001dea:	6105                	addi	sp,sp,32
    80001dec:	8082                	ret
     (scause & 0xff) == 9){
    80001dee:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80001df2:	46a5                	li	a3,9
    80001df4:	fed792e3          	bne	a5,a3,80001dd8 <devintr+0x12>
    int irq = plic_claim();
    80001df8:	00003097          	auipc	ra,0x3
    80001dfc:	590080e7          	jalr	1424(ra) # 80005388 <plic_claim>
    80001e00:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80001e02:	47a9                	li	a5,10
    80001e04:	02f50763          	beq	a0,a5,80001e32 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80001e08:	4785                	li	a5,1
    80001e0a:	02f50963          	beq	a0,a5,80001e3c <devintr+0x76>
    return 1;
    80001e0e:	4505                	li	a0,1
    } else if(irq){
    80001e10:	d8f1                	beqz	s1,80001de4 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80001e12:	85a6                	mv	a1,s1
    80001e14:	00006517          	auipc	a0,0x6
    80001e18:	49c50513          	addi	a0,a0,1180 # 800082b0 <states.1730+0x38>
    80001e1c:	00004097          	auipc	ra,0x4
    80001e20:	0e0080e7          	jalr	224(ra) # 80005efc <printf>
      plic_complete(irq);
    80001e24:	8526                	mv	a0,s1
    80001e26:	00003097          	auipc	ra,0x3
    80001e2a:	586080e7          	jalr	1414(ra) # 800053ac <plic_complete>
    return 1;
    80001e2e:	4505                	li	a0,1
    80001e30:	bf55                	j	80001de4 <devintr+0x1e>
      uartintr();
    80001e32:	00004097          	auipc	ra,0x4
    80001e36:	4ea080e7          	jalr	1258(ra) # 8000631c <uartintr>
    80001e3a:	b7ed                	j	80001e24 <devintr+0x5e>
      virtio_disk_intr();
    80001e3c:	00004097          	auipc	ra,0x4
    80001e40:	a9a080e7          	jalr	-1382(ra) # 800058d6 <virtio_disk_intr>
    80001e44:	b7c5                	j	80001e24 <devintr+0x5e>
    if(cpuid() == 0){
    80001e46:	fffff097          	auipc	ra,0xfffff
    80001e4a:	0c2080e7          	jalr	194(ra) # 80000f08 <cpuid>
    80001e4e:	c901                	beqz	a0,80001e5e <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80001e50:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80001e54:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80001e56:	14479073          	csrw	sip,a5
    return 2;
    80001e5a:	4509                	li	a0,2
    80001e5c:	b761                	j	80001de4 <devintr+0x1e>
      clockintr();
    80001e5e:	00000097          	auipc	ra,0x0
    80001e62:	f22080e7          	jalr	-222(ra) # 80001d80 <clockintr>
    80001e66:	b7ed                	j	80001e50 <devintr+0x8a>

0000000080001e68 <usertrap>:
{
    80001e68:	1101                	addi	sp,sp,-32
    80001e6a:	ec06                	sd	ra,24(sp)
    80001e6c:	e822                	sd	s0,16(sp)
    80001e6e:	e426                	sd	s1,8(sp)
    80001e70:	e04a                	sd	s2,0(sp)
    80001e72:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e74:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80001e78:	1007f793          	andi	a5,a5,256
    80001e7c:	e3b1                	bnez	a5,80001ec0 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001e7e:	00003797          	auipc	a5,0x3
    80001e82:	40278793          	addi	a5,a5,1026 # 80005280 <kernelvec>
    80001e86:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80001e8a:	fffff097          	auipc	ra,0xfffff
    80001e8e:	0aa080e7          	jalr	170(ra) # 80000f34 <myproc>
    80001e92:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80001e94:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001e96:	14102773          	csrr	a4,sepc
    80001e9a:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001e9c:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80001ea0:	47a1                	li	a5,8
    80001ea2:	02f70763          	beq	a4,a5,80001ed0 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80001ea6:	00000097          	auipc	ra,0x0
    80001eaa:	f20080e7          	jalr	-224(ra) # 80001dc6 <devintr>
    80001eae:	892a                	mv	s2,a0
    80001eb0:	c151                	beqz	a0,80001f34 <usertrap+0xcc>
  if(killed(p))
    80001eb2:	8526                	mv	a0,s1
    80001eb4:	00000097          	auipc	ra,0x0
    80001eb8:	ad2080e7          	jalr	-1326(ra) # 80001986 <killed>
    80001ebc:	c929                	beqz	a0,80001f0e <usertrap+0xa6>
    80001ebe:	a099                	j	80001f04 <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80001ec0:	00006517          	auipc	a0,0x6
    80001ec4:	41050513          	addi	a0,a0,1040 # 800082d0 <states.1730+0x58>
    80001ec8:	00004097          	auipc	ra,0x4
    80001ecc:	fea080e7          	jalr	-22(ra) # 80005eb2 <panic>
    if(killed(p))
    80001ed0:	00000097          	auipc	ra,0x0
    80001ed4:	ab6080e7          	jalr	-1354(ra) # 80001986 <killed>
    80001ed8:	e921                	bnez	a0,80001f28 <usertrap+0xc0>
    p->trapframe->epc += 4;
    80001eda:	6cb8                	ld	a4,88(s1)
    80001edc:	6f1c                	ld	a5,24(a4)
    80001ede:	0791                	addi	a5,a5,4
    80001ee0:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ee2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001ee6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001eea:	10079073          	csrw	sstatus,a5
    syscall();
    80001eee:	00000097          	auipc	ra,0x0
    80001ef2:	2d4080e7          	jalr	724(ra) # 800021c2 <syscall>
  if(killed(p))
    80001ef6:	8526                	mv	a0,s1
    80001ef8:	00000097          	auipc	ra,0x0
    80001efc:	a8e080e7          	jalr	-1394(ra) # 80001986 <killed>
    80001f00:	c911                	beqz	a0,80001f14 <usertrap+0xac>
    80001f02:	4901                	li	s2,0
    exit(-1);
    80001f04:	557d                	li	a0,-1
    80001f06:	00000097          	auipc	ra,0x0
    80001f0a:	90c080e7          	jalr	-1780(ra) # 80001812 <exit>
  if(which_dev == 2)
    80001f0e:	4789                	li	a5,2
    80001f10:	04f90f63          	beq	s2,a5,80001f6e <usertrap+0x106>
  usertrapret();
    80001f14:	00000097          	auipc	ra,0x0
    80001f18:	dd6080e7          	jalr	-554(ra) # 80001cea <usertrapret>
}
    80001f1c:	60e2                	ld	ra,24(sp)
    80001f1e:	6442                	ld	s0,16(sp)
    80001f20:	64a2                	ld	s1,8(sp)
    80001f22:	6902                	ld	s2,0(sp)
    80001f24:	6105                	addi	sp,sp,32
    80001f26:	8082                	ret
      exit(-1);
    80001f28:	557d                	li	a0,-1
    80001f2a:	00000097          	auipc	ra,0x0
    80001f2e:	8e8080e7          	jalr	-1816(ra) # 80001812 <exit>
    80001f32:	b765                	j	80001eda <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001f34:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80001f38:	5890                	lw	a2,48(s1)
    80001f3a:	00006517          	auipc	a0,0x6
    80001f3e:	3b650513          	addi	a0,a0,950 # 800082f0 <states.1730+0x78>
    80001f42:	00004097          	auipc	ra,0x4
    80001f46:	fba080e7          	jalr	-70(ra) # 80005efc <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001f4a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001f4e:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80001f52:	00006517          	auipc	a0,0x6
    80001f56:	3ce50513          	addi	a0,a0,974 # 80008320 <states.1730+0xa8>
    80001f5a:	00004097          	auipc	ra,0x4
    80001f5e:	fa2080e7          	jalr	-94(ra) # 80005efc <printf>
    setkilled(p);
    80001f62:	8526                	mv	a0,s1
    80001f64:	00000097          	auipc	ra,0x0
    80001f68:	9f6080e7          	jalr	-1546(ra) # 8000195a <setkilled>
    80001f6c:	b769                	j	80001ef6 <usertrap+0x8e>
    yield();
    80001f6e:	fffff097          	auipc	ra,0xfffff
    80001f72:	734080e7          	jalr	1844(ra) # 800016a2 <yield>
    80001f76:	bf79                	j	80001f14 <usertrap+0xac>

0000000080001f78 <kerneltrap>:
{
    80001f78:	7179                	addi	sp,sp,-48
    80001f7a:	f406                	sd	ra,40(sp)
    80001f7c:	f022                	sd	s0,32(sp)
    80001f7e:	ec26                	sd	s1,24(sp)
    80001f80:	e84a                	sd	s2,16(sp)
    80001f82:	e44e                	sd	s3,8(sp)
    80001f84:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001f86:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f8a:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001f8e:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80001f92:	1004f793          	andi	a5,s1,256
    80001f96:	cb85                	beqz	a5,80001fc6 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f98:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001f9c:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80001f9e:	ef85                	bnez	a5,80001fd6 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80001fa0:	00000097          	auipc	ra,0x0
    80001fa4:	e26080e7          	jalr	-474(ra) # 80001dc6 <devintr>
    80001fa8:	cd1d                	beqz	a0,80001fe6 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80001faa:	4789                	li	a5,2
    80001fac:	06f50a63          	beq	a0,a5,80002020 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001fb0:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001fb4:	10049073          	csrw	sstatus,s1
}
    80001fb8:	70a2                	ld	ra,40(sp)
    80001fba:	7402                	ld	s0,32(sp)
    80001fbc:	64e2                	ld	s1,24(sp)
    80001fbe:	6942                	ld	s2,16(sp)
    80001fc0:	69a2                	ld	s3,8(sp)
    80001fc2:	6145                	addi	sp,sp,48
    80001fc4:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80001fc6:	00006517          	auipc	a0,0x6
    80001fca:	37a50513          	addi	a0,a0,890 # 80008340 <states.1730+0xc8>
    80001fce:	00004097          	auipc	ra,0x4
    80001fd2:	ee4080e7          	jalr	-284(ra) # 80005eb2 <panic>
    panic("kerneltrap: interrupts enabled");
    80001fd6:	00006517          	auipc	a0,0x6
    80001fda:	39250513          	addi	a0,a0,914 # 80008368 <states.1730+0xf0>
    80001fde:	00004097          	auipc	ra,0x4
    80001fe2:	ed4080e7          	jalr	-300(ra) # 80005eb2 <panic>
    printf("scause %p\n", scause);
    80001fe6:	85ce                	mv	a1,s3
    80001fe8:	00006517          	auipc	a0,0x6
    80001fec:	3a050513          	addi	a0,a0,928 # 80008388 <states.1730+0x110>
    80001ff0:	00004097          	auipc	ra,0x4
    80001ff4:	f0c080e7          	jalr	-244(ra) # 80005efc <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001ff8:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001ffc:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002000:	00006517          	auipc	a0,0x6
    80002004:	39850513          	addi	a0,a0,920 # 80008398 <states.1730+0x120>
    80002008:	00004097          	auipc	ra,0x4
    8000200c:	ef4080e7          	jalr	-268(ra) # 80005efc <printf>
    panic("kerneltrap");
    80002010:	00006517          	auipc	a0,0x6
    80002014:	3a050513          	addi	a0,a0,928 # 800083b0 <states.1730+0x138>
    80002018:	00004097          	auipc	ra,0x4
    8000201c:	e9a080e7          	jalr	-358(ra) # 80005eb2 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002020:	fffff097          	auipc	ra,0xfffff
    80002024:	f14080e7          	jalr	-236(ra) # 80000f34 <myproc>
    80002028:	d541                	beqz	a0,80001fb0 <kerneltrap+0x38>
    8000202a:	fffff097          	auipc	ra,0xfffff
    8000202e:	f0a080e7          	jalr	-246(ra) # 80000f34 <myproc>
    80002032:	4d18                	lw	a4,24(a0)
    80002034:	4791                	li	a5,4
    80002036:	f6f71de3          	bne	a4,a5,80001fb0 <kerneltrap+0x38>
    yield();
    8000203a:	fffff097          	auipc	ra,0xfffff
    8000203e:	668080e7          	jalr	1640(ra) # 800016a2 <yield>
    80002042:	b7bd                	j	80001fb0 <kerneltrap+0x38>

0000000080002044 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002044:	1101                	addi	sp,sp,-32
    80002046:	ec06                	sd	ra,24(sp)
    80002048:	e822                	sd	s0,16(sp)
    8000204a:	e426                	sd	s1,8(sp)
    8000204c:	1000                	addi	s0,sp,32
    8000204e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002050:	fffff097          	auipc	ra,0xfffff
    80002054:	ee4080e7          	jalr	-284(ra) # 80000f34 <myproc>
  switch (n) {
    80002058:	4795                	li	a5,5
    8000205a:	0497e163          	bltu	a5,s1,8000209c <argraw+0x58>
    8000205e:	048a                	slli	s1,s1,0x2
    80002060:	00006717          	auipc	a4,0x6
    80002064:	38870713          	addi	a4,a4,904 # 800083e8 <states.1730+0x170>
    80002068:	94ba                	add	s1,s1,a4
    8000206a:	409c                	lw	a5,0(s1)
    8000206c:	97ba                	add	a5,a5,a4
    8000206e:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002070:	6d3c                	ld	a5,88(a0)
    80002072:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002074:	60e2                	ld	ra,24(sp)
    80002076:	6442                	ld	s0,16(sp)
    80002078:	64a2                	ld	s1,8(sp)
    8000207a:	6105                	addi	sp,sp,32
    8000207c:	8082                	ret
    return p->trapframe->a1;
    8000207e:	6d3c                	ld	a5,88(a0)
    80002080:	7fa8                	ld	a0,120(a5)
    80002082:	bfcd                	j	80002074 <argraw+0x30>
    return p->trapframe->a2;
    80002084:	6d3c                	ld	a5,88(a0)
    80002086:	63c8                	ld	a0,128(a5)
    80002088:	b7f5                	j	80002074 <argraw+0x30>
    return p->trapframe->a3;
    8000208a:	6d3c                	ld	a5,88(a0)
    8000208c:	67c8                	ld	a0,136(a5)
    8000208e:	b7dd                	j	80002074 <argraw+0x30>
    return p->trapframe->a4;
    80002090:	6d3c                	ld	a5,88(a0)
    80002092:	6bc8                	ld	a0,144(a5)
    80002094:	b7c5                	j	80002074 <argraw+0x30>
    return p->trapframe->a5;
    80002096:	6d3c                	ld	a5,88(a0)
    80002098:	6fc8                	ld	a0,152(a5)
    8000209a:	bfe9                	j	80002074 <argraw+0x30>
  panic("argraw");
    8000209c:	00006517          	auipc	a0,0x6
    800020a0:	32450513          	addi	a0,a0,804 # 800083c0 <states.1730+0x148>
    800020a4:	00004097          	auipc	ra,0x4
    800020a8:	e0e080e7          	jalr	-498(ra) # 80005eb2 <panic>

00000000800020ac <fetchaddr>:
{
    800020ac:	1101                	addi	sp,sp,-32
    800020ae:	ec06                	sd	ra,24(sp)
    800020b0:	e822                	sd	s0,16(sp)
    800020b2:	e426                	sd	s1,8(sp)
    800020b4:	e04a                	sd	s2,0(sp)
    800020b6:	1000                	addi	s0,sp,32
    800020b8:	84aa                	mv	s1,a0
    800020ba:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800020bc:	fffff097          	auipc	ra,0xfffff
    800020c0:	e78080e7          	jalr	-392(ra) # 80000f34 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    800020c4:	653c                	ld	a5,72(a0)
    800020c6:	02f4f863          	bgeu	s1,a5,800020f6 <fetchaddr+0x4a>
    800020ca:	00848713          	addi	a4,s1,8
    800020ce:	02e7e663          	bltu	a5,a4,800020fa <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800020d2:	46a1                	li	a3,8
    800020d4:	8626                	mv	a2,s1
    800020d6:	85ca                	mv	a1,s2
    800020d8:	6928                	ld	a0,80(a0)
    800020da:	fffff097          	auipc	ra,0xfffff
    800020de:	ba8080e7          	jalr	-1112(ra) # 80000c82 <copyin>
    800020e2:	00a03533          	snez	a0,a0
    800020e6:	40a00533          	neg	a0,a0
}
    800020ea:	60e2                	ld	ra,24(sp)
    800020ec:	6442                	ld	s0,16(sp)
    800020ee:	64a2                	ld	s1,8(sp)
    800020f0:	6902                	ld	s2,0(sp)
    800020f2:	6105                	addi	sp,sp,32
    800020f4:	8082                	ret
    return -1;
    800020f6:	557d                	li	a0,-1
    800020f8:	bfcd                	j	800020ea <fetchaddr+0x3e>
    800020fa:	557d                	li	a0,-1
    800020fc:	b7fd                	j	800020ea <fetchaddr+0x3e>

00000000800020fe <fetchstr>:
{
    800020fe:	7179                	addi	sp,sp,-48
    80002100:	f406                	sd	ra,40(sp)
    80002102:	f022                	sd	s0,32(sp)
    80002104:	ec26                	sd	s1,24(sp)
    80002106:	e84a                	sd	s2,16(sp)
    80002108:	e44e                	sd	s3,8(sp)
    8000210a:	1800                	addi	s0,sp,48
    8000210c:	892a                	mv	s2,a0
    8000210e:	84ae                	mv	s1,a1
    80002110:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002112:	fffff097          	auipc	ra,0xfffff
    80002116:	e22080e7          	jalr	-478(ra) # 80000f34 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    8000211a:	86ce                	mv	a3,s3
    8000211c:	864a                	mv	a2,s2
    8000211e:	85a6                	mv	a1,s1
    80002120:	6928                	ld	a0,80(a0)
    80002122:	fffff097          	auipc	ra,0xfffff
    80002126:	bec080e7          	jalr	-1044(ra) # 80000d0e <copyinstr>
    8000212a:	00054e63          	bltz	a0,80002146 <fetchstr+0x48>
  return strlen(buf);
    8000212e:	8526                	mv	a0,s1
    80002130:	ffffe097          	auipc	ra,0xffffe
    80002134:	1cc080e7          	jalr	460(ra) # 800002fc <strlen>
}
    80002138:	70a2                	ld	ra,40(sp)
    8000213a:	7402                	ld	s0,32(sp)
    8000213c:	64e2                	ld	s1,24(sp)
    8000213e:	6942                	ld	s2,16(sp)
    80002140:	69a2                	ld	s3,8(sp)
    80002142:	6145                	addi	sp,sp,48
    80002144:	8082                	ret
    return -1;
    80002146:	557d                	li	a0,-1
    80002148:	bfc5                	j	80002138 <fetchstr+0x3a>

000000008000214a <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    8000214a:	1101                	addi	sp,sp,-32
    8000214c:	ec06                	sd	ra,24(sp)
    8000214e:	e822                	sd	s0,16(sp)
    80002150:	e426                	sd	s1,8(sp)
    80002152:	1000                	addi	s0,sp,32
    80002154:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002156:	00000097          	auipc	ra,0x0
    8000215a:	eee080e7          	jalr	-274(ra) # 80002044 <argraw>
    8000215e:	c088                	sw	a0,0(s1)
}
    80002160:	60e2                	ld	ra,24(sp)
    80002162:	6442                	ld	s0,16(sp)
    80002164:	64a2                	ld	s1,8(sp)
    80002166:	6105                	addi	sp,sp,32
    80002168:	8082                	ret

000000008000216a <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    8000216a:	1101                	addi	sp,sp,-32
    8000216c:	ec06                	sd	ra,24(sp)
    8000216e:	e822                	sd	s0,16(sp)
    80002170:	e426                	sd	s1,8(sp)
    80002172:	1000                	addi	s0,sp,32
    80002174:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002176:	00000097          	auipc	ra,0x0
    8000217a:	ece080e7          	jalr	-306(ra) # 80002044 <argraw>
    8000217e:	e088                	sd	a0,0(s1)
}
    80002180:	60e2                	ld	ra,24(sp)
    80002182:	6442                	ld	s0,16(sp)
    80002184:	64a2                	ld	s1,8(sp)
    80002186:	6105                	addi	sp,sp,32
    80002188:	8082                	ret

000000008000218a <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    8000218a:	7179                	addi	sp,sp,-48
    8000218c:	f406                	sd	ra,40(sp)
    8000218e:	f022                	sd	s0,32(sp)
    80002190:	ec26                	sd	s1,24(sp)
    80002192:	e84a                	sd	s2,16(sp)
    80002194:	1800                	addi	s0,sp,48
    80002196:	84ae                	mv	s1,a1
    80002198:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    8000219a:	fd840593          	addi	a1,s0,-40
    8000219e:	00000097          	auipc	ra,0x0
    800021a2:	fcc080e7          	jalr	-52(ra) # 8000216a <argaddr>
  return fetchstr(addr, buf, max);
    800021a6:	864a                	mv	a2,s2
    800021a8:	85a6                	mv	a1,s1
    800021aa:	fd843503          	ld	a0,-40(s0)
    800021ae:	00000097          	auipc	ra,0x0
    800021b2:	f50080e7          	jalr	-176(ra) # 800020fe <fetchstr>
}
    800021b6:	70a2                	ld	ra,40(sp)
    800021b8:	7402                	ld	s0,32(sp)
    800021ba:	64e2                	ld	s1,24(sp)
    800021bc:	6942                	ld	s2,16(sp)
    800021be:	6145                	addi	sp,sp,48
    800021c0:	8082                	ret

00000000800021c2 <syscall>:



void
syscall(void)
{
    800021c2:	1101                	addi	sp,sp,-32
    800021c4:	ec06                	sd	ra,24(sp)
    800021c6:	e822                	sd	s0,16(sp)
    800021c8:	e426                	sd	s1,8(sp)
    800021ca:	e04a                	sd	s2,0(sp)
    800021cc:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    800021ce:	fffff097          	auipc	ra,0xfffff
    800021d2:	d66080e7          	jalr	-666(ra) # 80000f34 <myproc>
    800021d6:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    800021d8:	05853903          	ld	s2,88(a0)
    800021dc:	0a893783          	ld	a5,168(s2)
    800021e0:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800021e4:	37fd                	addiw	a5,a5,-1
    800021e6:	4775                	li	a4,29
    800021e8:	00f76f63          	bltu	a4,a5,80002206 <syscall+0x44>
    800021ec:	00369713          	slli	a4,a3,0x3
    800021f0:	00006797          	auipc	a5,0x6
    800021f4:	21078793          	addi	a5,a5,528 # 80008400 <syscalls>
    800021f8:	97ba                	add	a5,a5,a4
    800021fa:	639c                	ld	a5,0(a5)
    800021fc:	c789                	beqz	a5,80002206 <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    800021fe:	9782                	jalr	a5
    80002200:	06a93823          	sd	a0,112(s2)
    80002204:	a839                	j	80002222 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002206:	15848613          	addi	a2,s1,344
    8000220a:	588c                	lw	a1,48(s1)
    8000220c:	00006517          	auipc	a0,0x6
    80002210:	1bc50513          	addi	a0,a0,444 # 800083c8 <states.1730+0x150>
    80002214:	00004097          	auipc	ra,0x4
    80002218:	ce8080e7          	jalr	-792(ra) # 80005efc <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    8000221c:	6cbc                	ld	a5,88(s1)
    8000221e:	577d                	li	a4,-1
    80002220:	fbb8                	sd	a4,112(a5)
  }
}
    80002222:	60e2                	ld	ra,24(sp)
    80002224:	6442                	ld	s0,16(sp)
    80002226:	64a2                	ld	s1,8(sp)
    80002228:	6902                	ld	s2,0(sp)
    8000222a:	6105                	addi	sp,sp,32
    8000222c:	8082                	ret

000000008000222e <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    8000222e:	1101                	addi	sp,sp,-32
    80002230:	ec06                	sd	ra,24(sp)
    80002232:	e822                	sd	s0,16(sp)
    80002234:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002236:	fec40593          	addi	a1,s0,-20
    8000223a:	4501                	li	a0,0
    8000223c:	00000097          	auipc	ra,0x0
    80002240:	f0e080e7          	jalr	-242(ra) # 8000214a <argint>
  exit(n);
    80002244:	fec42503          	lw	a0,-20(s0)
    80002248:	fffff097          	auipc	ra,0xfffff
    8000224c:	5ca080e7          	jalr	1482(ra) # 80001812 <exit>
  return 0;  // not reached
}
    80002250:	4501                	li	a0,0
    80002252:	60e2                	ld	ra,24(sp)
    80002254:	6442                	ld	s0,16(sp)
    80002256:	6105                	addi	sp,sp,32
    80002258:	8082                	ret

000000008000225a <sys_getpid>:

uint64
sys_getpid(void)
{
    8000225a:	1141                	addi	sp,sp,-16
    8000225c:	e406                	sd	ra,8(sp)
    8000225e:	e022                	sd	s0,0(sp)
    80002260:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002262:	fffff097          	auipc	ra,0xfffff
    80002266:	cd2080e7          	jalr	-814(ra) # 80000f34 <myproc>
}
    8000226a:	5908                	lw	a0,48(a0)
    8000226c:	60a2                	ld	ra,8(sp)
    8000226e:	6402                	ld	s0,0(sp)
    80002270:	0141                	addi	sp,sp,16
    80002272:	8082                	ret

0000000080002274 <sys_fork>:

uint64
sys_fork(void)
{
    80002274:	1141                	addi	sp,sp,-16
    80002276:	e406                	sd	ra,8(sp)
    80002278:	e022                	sd	s0,0(sp)
    8000227a:	0800                	addi	s0,sp,16
  return fork();
    8000227c:	fffff097          	auipc	ra,0xfffff
    80002280:	174080e7          	jalr	372(ra) # 800013f0 <fork>
}
    80002284:	60a2                	ld	ra,8(sp)
    80002286:	6402                	ld	s0,0(sp)
    80002288:	0141                	addi	sp,sp,16
    8000228a:	8082                	ret

000000008000228c <sys_wait>:

uint64
sys_wait(void)
{
    8000228c:	1101                	addi	sp,sp,-32
    8000228e:	ec06                	sd	ra,24(sp)
    80002290:	e822                	sd	s0,16(sp)
    80002292:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002294:	fe840593          	addi	a1,s0,-24
    80002298:	4501                	li	a0,0
    8000229a:	00000097          	auipc	ra,0x0
    8000229e:	ed0080e7          	jalr	-304(ra) # 8000216a <argaddr>
  return wait(p);
    800022a2:	fe843503          	ld	a0,-24(s0)
    800022a6:	fffff097          	auipc	ra,0xfffff
    800022aa:	712080e7          	jalr	1810(ra) # 800019b8 <wait>
}
    800022ae:	60e2                	ld	ra,24(sp)
    800022b0:	6442                	ld	s0,16(sp)
    800022b2:	6105                	addi	sp,sp,32
    800022b4:	8082                	ret

00000000800022b6 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800022b6:	7179                	addi	sp,sp,-48
    800022b8:	f406                	sd	ra,40(sp)
    800022ba:	f022                	sd	s0,32(sp)
    800022bc:	ec26                	sd	s1,24(sp)
    800022be:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    800022c0:	fdc40593          	addi	a1,s0,-36
    800022c4:	4501                	li	a0,0
    800022c6:	00000097          	auipc	ra,0x0
    800022ca:	e84080e7          	jalr	-380(ra) # 8000214a <argint>
  addr = myproc()->sz;
    800022ce:	fffff097          	auipc	ra,0xfffff
    800022d2:	c66080e7          	jalr	-922(ra) # 80000f34 <myproc>
    800022d6:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    800022d8:	fdc42503          	lw	a0,-36(s0)
    800022dc:	fffff097          	auipc	ra,0xfffff
    800022e0:	0b8080e7          	jalr	184(ra) # 80001394 <growproc>
    800022e4:	00054863          	bltz	a0,800022f4 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    800022e8:	8526                	mv	a0,s1
    800022ea:	70a2                	ld	ra,40(sp)
    800022ec:	7402                	ld	s0,32(sp)
    800022ee:	64e2                	ld	s1,24(sp)
    800022f0:	6145                	addi	sp,sp,48
    800022f2:	8082                	ret
    return -1;
    800022f4:	54fd                	li	s1,-1
    800022f6:	bfcd                	j	800022e8 <sys_sbrk+0x32>

00000000800022f8 <sys_sleep>:

uint64
sys_sleep(void)
{
    800022f8:	7139                	addi	sp,sp,-64
    800022fa:	fc06                	sd	ra,56(sp)
    800022fc:	f822                	sd	s0,48(sp)
    800022fe:	f426                	sd	s1,40(sp)
    80002300:	f04a                	sd	s2,32(sp)
    80002302:	ec4e                	sd	s3,24(sp)
    80002304:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;


  argint(0, &n);
    80002306:	fcc40593          	addi	a1,s0,-52
    8000230a:	4501                	li	a0,0
    8000230c:	00000097          	auipc	ra,0x0
    80002310:	e3e080e7          	jalr	-450(ra) # 8000214a <argint>
  acquire(&tickslock);
    80002314:	0000c517          	auipc	a0,0xc
    80002318:	49c50513          	addi	a0,a0,1180 # 8000e7b0 <tickslock>
    8000231c:	00004097          	auipc	ra,0x4
    80002320:	0e0080e7          	jalr	224(ra) # 800063fc <acquire>
  ticks0 = ticks;
    80002324:	00006917          	auipc	s2,0x6
    80002328:	62492903          	lw	s2,1572(s2) # 80008948 <ticks>
  while(ticks - ticks0 < n){
    8000232c:	fcc42783          	lw	a5,-52(s0)
    80002330:	cf9d                	beqz	a5,8000236e <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002332:	0000c997          	auipc	s3,0xc
    80002336:	47e98993          	addi	s3,s3,1150 # 8000e7b0 <tickslock>
    8000233a:	00006497          	auipc	s1,0x6
    8000233e:	60e48493          	addi	s1,s1,1550 # 80008948 <ticks>
    if(killed(myproc())){
    80002342:	fffff097          	auipc	ra,0xfffff
    80002346:	bf2080e7          	jalr	-1038(ra) # 80000f34 <myproc>
    8000234a:	fffff097          	auipc	ra,0xfffff
    8000234e:	63c080e7          	jalr	1596(ra) # 80001986 <killed>
    80002352:	ed15                	bnez	a0,8000238e <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002354:	85ce                	mv	a1,s3
    80002356:	8526                	mv	a0,s1
    80002358:	fffff097          	auipc	ra,0xfffff
    8000235c:	386080e7          	jalr	902(ra) # 800016de <sleep>
  while(ticks - ticks0 < n){
    80002360:	409c                	lw	a5,0(s1)
    80002362:	412787bb          	subw	a5,a5,s2
    80002366:	fcc42703          	lw	a4,-52(s0)
    8000236a:	fce7ece3          	bltu	a5,a4,80002342 <sys_sleep+0x4a>
  }
  release(&tickslock);
    8000236e:	0000c517          	auipc	a0,0xc
    80002372:	44250513          	addi	a0,a0,1090 # 8000e7b0 <tickslock>
    80002376:	00004097          	auipc	ra,0x4
    8000237a:	13a080e7          	jalr	314(ra) # 800064b0 <release>
  return 0;
    8000237e:	4501                	li	a0,0
}
    80002380:	70e2                	ld	ra,56(sp)
    80002382:	7442                	ld	s0,48(sp)
    80002384:	74a2                	ld	s1,40(sp)
    80002386:	7902                	ld	s2,32(sp)
    80002388:	69e2                	ld	s3,24(sp)
    8000238a:	6121                	addi	sp,sp,64
    8000238c:	8082                	ret
      release(&tickslock);
    8000238e:	0000c517          	auipc	a0,0xc
    80002392:	42250513          	addi	a0,a0,1058 # 8000e7b0 <tickslock>
    80002396:	00004097          	auipc	ra,0x4
    8000239a:	11a080e7          	jalr	282(ra) # 800064b0 <release>
      return -1;
    8000239e:	557d                	li	a0,-1
    800023a0:	b7c5                	j	80002380 <sys_sleep+0x88>

00000000800023a2 <sys_pgaccess>:


#ifdef LAB_PGTBL
int
sys_pgaccess(void)
{
    800023a2:	715d                	addi	sp,sp,-80
    800023a4:	e486                	sd	ra,72(sp)
    800023a6:	e0a2                	sd	s0,64(sp)
    800023a8:	fc26                	sd	s1,56(sp)
    800023aa:	f84a                	sd	s2,48(sp)
    800023ac:	f44e                	sd	s3,40(sp)
    800023ae:	0880                	addi	s0,sp,80
  pte_t* pte;
  int i;
  unsigned int abits=0;
    800023b0:	fc042623          	sw	zero,-52(s0)
  uint64 va,uvmBuf;
  int npage;
    argaddr(0,&va);
    800023b4:	fc040593          	addi	a1,s0,-64
    800023b8:	4501                	li	a0,0
    800023ba:	00000097          	auipc	ra,0x0
    800023be:	db0080e7          	jalr	-592(ra) # 8000216a <argaddr>
    argint(1,&npage);
    800023c2:	fb440593          	addi	a1,s0,-76
    800023c6:	4505                	li	a0,1
    800023c8:	00000097          	auipc	ra,0x0
    800023cc:	d82080e7          	jalr	-638(ra) # 8000214a <argint>
    argaddr(2,&uvmBuf);
    800023d0:	fb840593          	addi	a1,s0,-72
    800023d4:	4509                	li	a0,2
    800023d6:	00000097          	auipc	ra,0x0
    800023da:	d94080e7          	jalr	-620(ra) # 8000216a <argaddr>
    if(va==0||npage==0||uvmBuf==0)
    800023de:	fc043783          	ld	a5,-64(s0)
    800023e2:	cfd1                	beqz	a5,8000247e <sys_pgaccess+0xdc>
    800023e4:	fb442783          	lw	a5,-76(s0)
    800023e8:	cfc9                	beqz	a5,80002482 <sys_pgaccess+0xe0>
    800023ea:	fb843703          	ld	a4,-72(s0)
    800023ee:	cf41                	beqz	a4,80002486 <sys_pgaccess+0xe4>
    {
      return -1;
    }
    if(npage>32)
    800023f0:	02000713          	li	a4,32
    800023f4:	08f74b63          	blt	a4,a5,8000248a <sys_pgaccess+0xe8>
    {
      return -1;
    }
    for(i=0;i<npage;i++)
    800023f8:	04f05c63          	blez	a5,80002450 <sys_pgaccess+0xae>
    800023fc:	4481                	li	s1,0
    {
      pte=walk(myproc()->pagetable,va,0);
        if((*pte)&PTE_A)
        {
           abits+=(1<<i);
    800023fe:	4985                	li	s3,1
           *pte &=(~PTE_A);
        }
        va+=PGSIZE;
    80002400:	6905                	lui	s2,0x1
    80002402:	a819                	j	80002418 <sys_pgaccess+0x76>
    80002404:	fc043783          	ld	a5,-64(s0)
    80002408:	97ca                	add	a5,a5,s2
    8000240a:	fcf43023          	sd	a5,-64(s0)
    for(i=0;i<npage;i++)
    8000240e:	2485                	addiw	s1,s1,1
    80002410:	fb442783          	lw	a5,-76(s0)
    80002414:	02f4de63          	bge	s1,a5,80002450 <sys_pgaccess+0xae>
      pte=walk(myproc()->pagetable,va,0);
    80002418:	fffff097          	auipc	ra,0xfffff
    8000241c:	b1c080e7          	jalr	-1252(ra) # 80000f34 <myproc>
    80002420:	4601                	li	a2,0
    80002422:	fc043583          	ld	a1,-64(s0)
    80002426:	6928                	ld	a0,80(a0)
    80002428:	ffffe097          	auipc	ra,0xffffe
    8000242c:	11c080e7          	jalr	284(ra) # 80000544 <walk>
        if((*pte)&PTE_A)
    80002430:	611c                	ld	a5,0(a0)
    80002432:	0407f793          	andi	a5,a5,64
    80002436:	d7f9                	beqz	a5,80002404 <sys_pgaccess+0x62>
           abits+=(1<<i);
    80002438:	009997bb          	sllw	a5,s3,s1
    8000243c:	fcc42703          	lw	a4,-52(s0)
    80002440:	9fb9                	addw	a5,a5,a4
    80002442:	fcf42623          	sw	a5,-52(s0)
           *pte &=(~PTE_A);
    80002446:	611c                	ld	a5,0(a0)
    80002448:	fbf7f793          	andi	a5,a5,-65
    8000244c:	e11c                	sd	a5,0(a0)
    8000244e:	bf5d                	j	80002404 <sys_pgaccess+0x62>
    }

      if(copyout(myproc()->pagetable,uvmBuf,(char *)&abits,sizeof(abits))<0)
    80002450:	fffff097          	auipc	ra,0xfffff
    80002454:	ae4080e7          	jalr	-1308(ra) # 80000f34 <myproc>
    80002458:	4691                	li	a3,4
    8000245a:	fcc40613          	addi	a2,s0,-52
    8000245e:	fb843583          	ld	a1,-72(s0)
    80002462:	6928                	ld	a0,80(a0)
    80002464:	ffffe097          	auipc	ra,0xffffe
    80002468:	792080e7          	jalr	1938(ra) # 80000bf6 <copyout>
    8000246c:	41f5551b          	sraiw	a0,a0,0x1f
        return -1;
      }
  // lab pgtbl: your code here.
  
  return 0;
}
    80002470:	60a6                	ld	ra,72(sp)
    80002472:	6406                	ld	s0,64(sp)
    80002474:	74e2                	ld	s1,56(sp)
    80002476:	7942                	ld	s2,48(sp)
    80002478:	79a2                	ld	s3,40(sp)
    8000247a:	6161                	addi	sp,sp,80
    8000247c:	8082                	ret
      return -1;
    8000247e:	557d                	li	a0,-1
    80002480:	bfc5                	j	80002470 <sys_pgaccess+0xce>
    80002482:	557d                	li	a0,-1
    80002484:	b7f5                	j	80002470 <sys_pgaccess+0xce>
    80002486:	557d                	li	a0,-1
    80002488:	b7e5                	j	80002470 <sys_pgaccess+0xce>
      return -1;
    8000248a:	557d                	li	a0,-1
    8000248c:	b7d5                	j	80002470 <sys_pgaccess+0xce>

000000008000248e <sys_kill>:
#endif

uint64
sys_kill(void)
{
    8000248e:	1101                	addi	sp,sp,-32
    80002490:	ec06                	sd	ra,24(sp)
    80002492:	e822                	sd	s0,16(sp)
    80002494:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002496:	fec40593          	addi	a1,s0,-20
    8000249a:	4501                	li	a0,0
    8000249c:	00000097          	auipc	ra,0x0
    800024a0:	cae080e7          	jalr	-850(ra) # 8000214a <argint>
  return kill(pid);
    800024a4:	fec42503          	lw	a0,-20(s0)
    800024a8:	fffff097          	auipc	ra,0xfffff
    800024ac:	440080e7          	jalr	1088(ra) # 800018e8 <kill>
}
    800024b0:	60e2                	ld	ra,24(sp)
    800024b2:	6442                	ld	s0,16(sp)
    800024b4:	6105                	addi	sp,sp,32
    800024b6:	8082                	ret

00000000800024b8 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800024b8:	1101                	addi	sp,sp,-32
    800024ba:	ec06                	sd	ra,24(sp)
    800024bc:	e822                	sd	s0,16(sp)
    800024be:	e426                	sd	s1,8(sp)
    800024c0:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800024c2:	0000c517          	auipc	a0,0xc
    800024c6:	2ee50513          	addi	a0,a0,750 # 8000e7b0 <tickslock>
    800024ca:	00004097          	auipc	ra,0x4
    800024ce:	f32080e7          	jalr	-206(ra) # 800063fc <acquire>
  xticks = ticks;
    800024d2:	00006497          	auipc	s1,0x6
    800024d6:	4764a483          	lw	s1,1142(s1) # 80008948 <ticks>
  release(&tickslock);
    800024da:	0000c517          	auipc	a0,0xc
    800024de:	2d650513          	addi	a0,a0,726 # 8000e7b0 <tickslock>
    800024e2:	00004097          	auipc	ra,0x4
    800024e6:	fce080e7          	jalr	-50(ra) # 800064b0 <release>
  return xticks;
}
    800024ea:	02049513          	slli	a0,s1,0x20
    800024ee:	9101                	srli	a0,a0,0x20
    800024f0:	60e2                	ld	ra,24(sp)
    800024f2:	6442                	ld	s0,16(sp)
    800024f4:	64a2                	ld	s1,8(sp)
    800024f6:	6105                	addi	sp,sp,32
    800024f8:	8082                	ret

00000000800024fa <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800024fa:	7179                	addi	sp,sp,-48
    800024fc:	f406                	sd	ra,40(sp)
    800024fe:	f022                	sd	s0,32(sp)
    80002500:	ec26                	sd	s1,24(sp)
    80002502:	e84a                	sd	s2,16(sp)
    80002504:	e44e                	sd	s3,8(sp)
    80002506:	e052                	sd	s4,0(sp)
    80002508:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000250a:	00006597          	auipc	a1,0x6
    8000250e:	fee58593          	addi	a1,a1,-18 # 800084f8 <syscalls+0xf8>
    80002512:	0000c517          	auipc	a0,0xc
    80002516:	2b650513          	addi	a0,a0,694 # 8000e7c8 <bcache>
    8000251a:	00004097          	auipc	ra,0x4
    8000251e:	e52080e7          	jalr	-430(ra) # 8000636c <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002522:	00014797          	auipc	a5,0x14
    80002526:	2a678793          	addi	a5,a5,678 # 800167c8 <bcache+0x8000>
    8000252a:	00014717          	auipc	a4,0x14
    8000252e:	50670713          	addi	a4,a4,1286 # 80016a30 <bcache+0x8268>
    80002532:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002536:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000253a:	0000c497          	auipc	s1,0xc
    8000253e:	2a648493          	addi	s1,s1,678 # 8000e7e0 <bcache+0x18>
    b->next = bcache.head.next;
    80002542:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002544:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002546:	00006a17          	auipc	s4,0x6
    8000254a:	fbaa0a13          	addi	s4,s4,-70 # 80008500 <syscalls+0x100>
    b->next = bcache.head.next;
    8000254e:	2b893783          	ld	a5,696(s2) # 12b8 <_entry-0x7fffed48>
    80002552:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002554:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002558:	85d2                	mv	a1,s4
    8000255a:	01048513          	addi	a0,s1,16
    8000255e:	00001097          	auipc	ra,0x1
    80002562:	4c4080e7          	jalr	1220(ra) # 80003a22 <initsleeplock>
    bcache.head.next->prev = b;
    80002566:	2b893783          	ld	a5,696(s2)
    8000256a:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000256c:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002570:	45848493          	addi	s1,s1,1112
    80002574:	fd349de3          	bne	s1,s3,8000254e <binit+0x54>
  }
}
    80002578:	70a2                	ld	ra,40(sp)
    8000257a:	7402                	ld	s0,32(sp)
    8000257c:	64e2                	ld	s1,24(sp)
    8000257e:	6942                	ld	s2,16(sp)
    80002580:	69a2                	ld	s3,8(sp)
    80002582:	6a02                	ld	s4,0(sp)
    80002584:	6145                	addi	sp,sp,48
    80002586:	8082                	ret

0000000080002588 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002588:	7179                	addi	sp,sp,-48
    8000258a:	f406                	sd	ra,40(sp)
    8000258c:	f022                	sd	s0,32(sp)
    8000258e:	ec26                	sd	s1,24(sp)
    80002590:	e84a                	sd	s2,16(sp)
    80002592:	e44e                	sd	s3,8(sp)
    80002594:	1800                	addi	s0,sp,48
    80002596:	89aa                	mv	s3,a0
    80002598:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    8000259a:	0000c517          	auipc	a0,0xc
    8000259e:	22e50513          	addi	a0,a0,558 # 8000e7c8 <bcache>
    800025a2:	00004097          	auipc	ra,0x4
    800025a6:	e5a080e7          	jalr	-422(ra) # 800063fc <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800025aa:	00014497          	auipc	s1,0x14
    800025ae:	4d64b483          	ld	s1,1238(s1) # 80016a80 <bcache+0x82b8>
    800025b2:	00014797          	auipc	a5,0x14
    800025b6:	47e78793          	addi	a5,a5,1150 # 80016a30 <bcache+0x8268>
    800025ba:	02f48f63          	beq	s1,a5,800025f8 <bread+0x70>
    800025be:	873e                	mv	a4,a5
    800025c0:	a021                	j	800025c8 <bread+0x40>
    800025c2:	68a4                	ld	s1,80(s1)
    800025c4:	02e48a63          	beq	s1,a4,800025f8 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800025c8:	449c                	lw	a5,8(s1)
    800025ca:	ff379ce3          	bne	a5,s3,800025c2 <bread+0x3a>
    800025ce:	44dc                	lw	a5,12(s1)
    800025d0:	ff2799e3          	bne	a5,s2,800025c2 <bread+0x3a>
      b->refcnt++;
    800025d4:	40bc                	lw	a5,64(s1)
    800025d6:	2785                	addiw	a5,a5,1
    800025d8:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800025da:	0000c517          	auipc	a0,0xc
    800025de:	1ee50513          	addi	a0,a0,494 # 8000e7c8 <bcache>
    800025e2:	00004097          	auipc	ra,0x4
    800025e6:	ece080e7          	jalr	-306(ra) # 800064b0 <release>
      acquiresleep(&b->lock);
    800025ea:	01048513          	addi	a0,s1,16
    800025ee:	00001097          	auipc	ra,0x1
    800025f2:	46e080e7          	jalr	1134(ra) # 80003a5c <acquiresleep>
      return b;
    800025f6:	a8b9                	j	80002654 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800025f8:	00014497          	auipc	s1,0x14
    800025fc:	4804b483          	ld	s1,1152(s1) # 80016a78 <bcache+0x82b0>
    80002600:	00014797          	auipc	a5,0x14
    80002604:	43078793          	addi	a5,a5,1072 # 80016a30 <bcache+0x8268>
    80002608:	00f48863          	beq	s1,a5,80002618 <bread+0x90>
    8000260c:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000260e:	40bc                	lw	a5,64(s1)
    80002610:	cf81                	beqz	a5,80002628 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002612:	64a4                	ld	s1,72(s1)
    80002614:	fee49de3          	bne	s1,a4,8000260e <bread+0x86>
  panic("bget: no buffers");
    80002618:	00006517          	auipc	a0,0x6
    8000261c:	ef050513          	addi	a0,a0,-272 # 80008508 <syscalls+0x108>
    80002620:	00004097          	auipc	ra,0x4
    80002624:	892080e7          	jalr	-1902(ra) # 80005eb2 <panic>
      b->dev = dev;
    80002628:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    8000262c:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    80002630:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002634:	4785                	li	a5,1
    80002636:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002638:	0000c517          	auipc	a0,0xc
    8000263c:	19050513          	addi	a0,a0,400 # 8000e7c8 <bcache>
    80002640:	00004097          	auipc	ra,0x4
    80002644:	e70080e7          	jalr	-400(ra) # 800064b0 <release>
      acquiresleep(&b->lock);
    80002648:	01048513          	addi	a0,s1,16
    8000264c:	00001097          	auipc	ra,0x1
    80002650:	410080e7          	jalr	1040(ra) # 80003a5c <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002654:	409c                	lw	a5,0(s1)
    80002656:	cb89                	beqz	a5,80002668 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002658:	8526                	mv	a0,s1
    8000265a:	70a2                	ld	ra,40(sp)
    8000265c:	7402                	ld	s0,32(sp)
    8000265e:	64e2                	ld	s1,24(sp)
    80002660:	6942                	ld	s2,16(sp)
    80002662:	69a2                	ld	s3,8(sp)
    80002664:	6145                	addi	sp,sp,48
    80002666:	8082                	ret
    virtio_disk_rw(b, 0);
    80002668:	4581                	li	a1,0
    8000266a:	8526                	mv	a0,s1
    8000266c:	00003097          	auipc	ra,0x3
    80002670:	fdc080e7          	jalr	-36(ra) # 80005648 <virtio_disk_rw>
    b->valid = 1;
    80002674:	4785                	li	a5,1
    80002676:	c09c                	sw	a5,0(s1)
  return b;
    80002678:	b7c5                	j	80002658 <bread+0xd0>

000000008000267a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000267a:	1101                	addi	sp,sp,-32
    8000267c:	ec06                	sd	ra,24(sp)
    8000267e:	e822                	sd	s0,16(sp)
    80002680:	e426                	sd	s1,8(sp)
    80002682:	1000                	addi	s0,sp,32
    80002684:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002686:	0541                	addi	a0,a0,16
    80002688:	00001097          	auipc	ra,0x1
    8000268c:	46e080e7          	jalr	1134(ra) # 80003af6 <holdingsleep>
    80002690:	cd01                	beqz	a0,800026a8 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002692:	4585                	li	a1,1
    80002694:	8526                	mv	a0,s1
    80002696:	00003097          	auipc	ra,0x3
    8000269a:	fb2080e7          	jalr	-78(ra) # 80005648 <virtio_disk_rw>
}
    8000269e:	60e2                	ld	ra,24(sp)
    800026a0:	6442                	ld	s0,16(sp)
    800026a2:	64a2                	ld	s1,8(sp)
    800026a4:	6105                	addi	sp,sp,32
    800026a6:	8082                	ret
    panic("bwrite");
    800026a8:	00006517          	auipc	a0,0x6
    800026ac:	e7850513          	addi	a0,a0,-392 # 80008520 <syscalls+0x120>
    800026b0:	00004097          	auipc	ra,0x4
    800026b4:	802080e7          	jalr	-2046(ra) # 80005eb2 <panic>

00000000800026b8 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800026b8:	1101                	addi	sp,sp,-32
    800026ba:	ec06                	sd	ra,24(sp)
    800026bc:	e822                	sd	s0,16(sp)
    800026be:	e426                	sd	s1,8(sp)
    800026c0:	e04a                	sd	s2,0(sp)
    800026c2:	1000                	addi	s0,sp,32
    800026c4:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800026c6:	01050913          	addi	s2,a0,16
    800026ca:	854a                	mv	a0,s2
    800026cc:	00001097          	auipc	ra,0x1
    800026d0:	42a080e7          	jalr	1066(ra) # 80003af6 <holdingsleep>
    800026d4:	c92d                	beqz	a0,80002746 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800026d6:	854a                	mv	a0,s2
    800026d8:	00001097          	auipc	ra,0x1
    800026dc:	3da080e7          	jalr	986(ra) # 80003ab2 <releasesleep>

  acquire(&bcache.lock);
    800026e0:	0000c517          	auipc	a0,0xc
    800026e4:	0e850513          	addi	a0,a0,232 # 8000e7c8 <bcache>
    800026e8:	00004097          	auipc	ra,0x4
    800026ec:	d14080e7          	jalr	-748(ra) # 800063fc <acquire>
  b->refcnt--;
    800026f0:	40bc                	lw	a5,64(s1)
    800026f2:	37fd                	addiw	a5,a5,-1
    800026f4:	0007871b          	sext.w	a4,a5
    800026f8:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800026fa:	eb05                	bnez	a4,8000272a <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800026fc:	68bc                	ld	a5,80(s1)
    800026fe:	64b8                	ld	a4,72(s1)
    80002700:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80002702:	64bc                	ld	a5,72(s1)
    80002704:	68b8                	ld	a4,80(s1)
    80002706:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002708:	00014797          	auipc	a5,0x14
    8000270c:	0c078793          	addi	a5,a5,192 # 800167c8 <bcache+0x8000>
    80002710:	2b87b703          	ld	a4,696(a5)
    80002714:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002716:	00014717          	auipc	a4,0x14
    8000271a:	31a70713          	addi	a4,a4,794 # 80016a30 <bcache+0x8268>
    8000271e:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002720:	2b87b703          	ld	a4,696(a5)
    80002724:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002726:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000272a:	0000c517          	auipc	a0,0xc
    8000272e:	09e50513          	addi	a0,a0,158 # 8000e7c8 <bcache>
    80002732:	00004097          	auipc	ra,0x4
    80002736:	d7e080e7          	jalr	-642(ra) # 800064b0 <release>
}
    8000273a:	60e2                	ld	ra,24(sp)
    8000273c:	6442                	ld	s0,16(sp)
    8000273e:	64a2                	ld	s1,8(sp)
    80002740:	6902                	ld	s2,0(sp)
    80002742:	6105                	addi	sp,sp,32
    80002744:	8082                	ret
    panic("brelse");
    80002746:	00006517          	auipc	a0,0x6
    8000274a:	de250513          	addi	a0,a0,-542 # 80008528 <syscalls+0x128>
    8000274e:	00003097          	auipc	ra,0x3
    80002752:	764080e7          	jalr	1892(ra) # 80005eb2 <panic>

0000000080002756 <bpin>:

void
bpin(struct buf *b) {
    80002756:	1101                	addi	sp,sp,-32
    80002758:	ec06                	sd	ra,24(sp)
    8000275a:	e822                	sd	s0,16(sp)
    8000275c:	e426                	sd	s1,8(sp)
    8000275e:	1000                	addi	s0,sp,32
    80002760:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002762:	0000c517          	auipc	a0,0xc
    80002766:	06650513          	addi	a0,a0,102 # 8000e7c8 <bcache>
    8000276a:	00004097          	auipc	ra,0x4
    8000276e:	c92080e7          	jalr	-878(ra) # 800063fc <acquire>
  b->refcnt++;
    80002772:	40bc                	lw	a5,64(s1)
    80002774:	2785                	addiw	a5,a5,1
    80002776:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002778:	0000c517          	auipc	a0,0xc
    8000277c:	05050513          	addi	a0,a0,80 # 8000e7c8 <bcache>
    80002780:	00004097          	auipc	ra,0x4
    80002784:	d30080e7          	jalr	-720(ra) # 800064b0 <release>
}
    80002788:	60e2                	ld	ra,24(sp)
    8000278a:	6442                	ld	s0,16(sp)
    8000278c:	64a2                	ld	s1,8(sp)
    8000278e:	6105                	addi	sp,sp,32
    80002790:	8082                	ret

0000000080002792 <bunpin>:

void
bunpin(struct buf *b) {
    80002792:	1101                	addi	sp,sp,-32
    80002794:	ec06                	sd	ra,24(sp)
    80002796:	e822                	sd	s0,16(sp)
    80002798:	e426                	sd	s1,8(sp)
    8000279a:	1000                	addi	s0,sp,32
    8000279c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000279e:	0000c517          	auipc	a0,0xc
    800027a2:	02a50513          	addi	a0,a0,42 # 8000e7c8 <bcache>
    800027a6:	00004097          	auipc	ra,0x4
    800027aa:	c56080e7          	jalr	-938(ra) # 800063fc <acquire>
  b->refcnt--;
    800027ae:	40bc                	lw	a5,64(s1)
    800027b0:	37fd                	addiw	a5,a5,-1
    800027b2:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800027b4:	0000c517          	auipc	a0,0xc
    800027b8:	01450513          	addi	a0,a0,20 # 8000e7c8 <bcache>
    800027bc:	00004097          	auipc	ra,0x4
    800027c0:	cf4080e7          	jalr	-780(ra) # 800064b0 <release>
}
    800027c4:	60e2                	ld	ra,24(sp)
    800027c6:	6442                	ld	s0,16(sp)
    800027c8:	64a2                	ld	s1,8(sp)
    800027ca:	6105                	addi	sp,sp,32
    800027cc:	8082                	ret

00000000800027ce <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800027ce:	1101                	addi	sp,sp,-32
    800027d0:	ec06                	sd	ra,24(sp)
    800027d2:	e822                	sd	s0,16(sp)
    800027d4:	e426                	sd	s1,8(sp)
    800027d6:	e04a                	sd	s2,0(sp)
    800027d8:	1000                	addi	s0,sp,32
    800027da:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800027dc:	00d5d59b          	srliw	a1,a1,0xd
    800027e0:	00014797          	auipc	a5,0x14
    800027e4:	6c47a783          	lw	a5,1732(a5) # 80016ea4 <sb+0x1c>
    800027e8:	9dbd                	addw	a1,a1,a5
    800027ea:	00000097          	auipc	ra,0x0
    800027ee:	d9e080e7          	jalr	-610(ra) # 80002588 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800027f2:	0074f713          	andi	a4,s1,7
    800027f6:	4785                	li	a5,1
    800027f8:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800027fc:	14ce                	slli	s1,s1,0x33
    800027fe:	90d9                	srli	s1,s1,0x36
    80002800:	00950733          	add	a4,a0,s1
    80002804:	05874703          	lbu	a4,88(a4)
    80002808:	00e7f6b3          	and	a3,a5,a4
    8000280c:	c69d                	beqz	a3,8000283a <bfree+0x6c>
    8000280e:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002810:	94aa                	add	s1,s1,a0
    80002812:	fff7c793          	not	a5,a5
    80002816:	8ff9                	and	a5,a5,a4
    80002818:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    8000281c:	00001097          	auipc	ra,0x1
    80002820:	120080e7          	jalr	288(ra) # 8000393c <log_write>
  brelse(bp);
    80002824:	854a                	mv	a0,s2
    80002826:	00000097          	auipc	ra,0x0
    8000282a:	e92080e7          	jalr	-366(ra) # 800026b8 <brelse>
}
    8000282e:	60e2                	ld	ra,24(sp)
    80002830:	6442                	ld	s0,16(sp)
    80002832:	64a2                	ld	s1,8(sp)
    80002834:	6902                	ld	s2,0(sp)
    80002836:	6105                	addi	sp,sp,32
    80002838:	8082                	ret
    panic("freeing free block");
    8000283a:	00006517          	auipc	a0,0x6
    8000283e:	cf650513          	addi	a0,a0,-778 # 80008530 <syscalls+0x130>
    80002842:	00003097          	auipc	ra,0x3
    80002846:	670080e7          	jalr	1648(ra) # 80005eb2 <panic>

000000008000284a <balloc>:
{
    8000284a:	711d                	addi	sp,sp,-96
    8000284c:	ec86                	sd	ra,88(sp)
    8000284e:	e8a2                	sd	s0,80(sp)
    80002850:	e4a6                	sd	s1,72(sp)
    80002852:	e0ca                	sd	s2,64(sp)
    80002854:	fc4e                	sd	s3,56(sp)
    80002856:	f852                	sd	s4,48(sp)
    80002858:	f456                	sd	s5,40(sp)
    8000285a:	f05a                	sd	s6,32(sp)
    8000285c:	ec5e                	sd	s7,24(sp)
    8000285e:	e862                	sd	s8,16(sp)
    80002860:	e466                	sd	s9,8(sp)
    80002862:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002864:	00014797          	auipc	a5,0x14
    80002868:	6287a783          	lw	a5,1576(a5) # 80016e8c <sb+0x4>
    8000286c:	10078163          	beqz	a5,8000296e <balloc+0x124>
    80002870:	8baa                	mv	s7,a0
    80002872:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002874:	00014b17          	auipc	s6,0x14
    80002878:	614b0b13          	addi	s6,s6,1556 # 80016e88 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000287c:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000287e:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002880:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002882:	6c89                	lui	s9,0x2
    80002884:	a061                	j	8000290c <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002886:	974a                	add	a4,a4,s2
    80002888:	8fd5                	or	a5,a5,a3
    8000288a:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    8000288e:	854a                	mv	a0,s2
    80002890:	00001097          	auipc	ra,0x1
    80002894:	0ac080e7          	jalr	172(ra) # 8000393c <log_write>
        brelse(bp);
    80002898:	854a                	mv	a0,s2
    8000289a:	00000097          	auipc	ra,0x0
    8000289e:	e1e080e7          	jalr	-482(ra) # 800026b8 <brelse>
  bp = bread(dev, bno);
    800028a2:	85a6                	mv	a1,s1
    800028a4:	855e                	mv	a0,s7
    800028a6:	00000097          	auipc	ra,0x0
    800028aa:	ce2080e7          	jalr	-798(ra) # 80002588 <bread>
    800028ae:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800028b0:	40000613          	li	a2,1024
    800028b4:	4581                	li	a1,0
    800028b6:	05850513          	addi	a0,a0,88
    800028ba:	ffffe097          	auipc	ra,0xffffe
    800028be:	8be080e7          	jalr	-1858(ra) # 80000178 <memset>
  log_write(bp);
    800028c2:	854a                	mv	a0,s2
    800028c4:	00001097          	auipc	ra,0x1
    800028c8:	078080e7          	jalr	120(ra) # 8000393c <log_write>
  brelse(bp);
    800028cc:	854a                	mv	a0,s2
    800028ce:	00000097          	auipc	ra,0x0
    800028d2:	dea080e7          	jalr	-534(ra) # 800026b8 <brelse>
}
    800028d6:	8526                	mv	a0,s1
    800028d8:	60e6                	ld	ra,88(sp)
    800028da:	6446                	ld	s0,80(sp)
    800028dc:	64a6                	ld	s1,72(sp)
    800028de:	6906                	ld	s2,64(sp)
    800028e0:	79e2                	ld	s3,56(sp)
    800028e2:	7a42                	ld	s4,48(sp)
    800028e4:	7aa2                	ld	s5,40(sp)
    800028e6:	7b02                	ld	s6,32(sp)
    800028e8:	6be2                	ld	s7,24(sp)
    800028ea:	6c42                	ld	s8,16(sp)
    800028ec:	6ca2                	ld	s9,8(sp)
    800028ee:	6125                	addi	sp,sp,96
    800028f0:	8082                	ret
    brelse(bp);
    800028f2:	854a                	mv	a0,s2
    800028f4:	00000097          	auipc	ra,0x0
    800028f8:	dc4080e7          	jalr	-572(ra) # 800026b8 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800028fc:	015c87bb          	addw	a5,s9,s5
    80002900:	00078a9b          	sext.w	s5,a5
    80002904:	004b2703          	lw	a4,4(s6)
    80002908:	06eaf363          	bgeu	s5,a4,8000296e <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    8000290c:	41fad79b          	sraiw	a5,s5,0x1f
    80002910:	0137d79b          	srliw	a5,a5,0x13
    80002914:	015787bb          	addw	a5,a5,s5
    80002918:	40d7d79b          	sraiw	a5,a5,0xd
    8000291c:	01cb2583          	lw	a1,28(s6)
    80002920:	9dbd                	addw	a1,a1,a5
    80002922:	855e                	mv	a0,s7
    80002924:	00000097          	auipc	ra,0x0
    80002928:	c64080e7          	jalr	-924(ra) # 80002588 <bread>
    8000292c:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000292e:	004b2503          	lw	a0,4(s6)
    80002932:	000a849b          	sext.w	s1,s5
    80002936:	8662                	mv	a2,s8
    80002938:	faa4fde3          	bgeu	s1,a0,800028f2 <balloc+0xa8>
      m = 1 << (bi % 8);
    8000293c:	41f6579b          	sraiw	a5,a2,0x1f
    80002940:	01d7d69b          	srliw	a3,a5,0x1d
    80002944:	00c6873b          	addw	a4,a3,a2
    80002948:	00777793          	andi	a5,a4,7
    8000294c:	9f95                	subw	a5,a5,a3
    8000294e:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002952:	4037571b          	sraiw	a4,a4,0x3
    80002956:	00e906b3          	add	a3,s2,a4
    8000295a:	0586c683          	lbu	a3,88(a3)
    8000295e:	00d7f5b3          	and	a1,a5,a3
    80002962:	d195                	beqz	a1,80002886 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002964:	2605                	addiw	a2,a2,1
    80002966:	2485                	addiw	s1,s1,1
    80002968:	fd4618e3          	bne	a2,s4,80002938 <balloc+0xee>
    8000296c:	b759                	j	800028f2 <balloc+0xa8>
  printf("balloc: out of blocks\n");
    8000296e:	00006517          	auipc	a0,0x6
    80002972:	bda50513          	addi	a0,a0,-1062 # 80008548 <syscalls+0x148>
    80002976:	00003097          	auipc	ra,0x3
    8000297a:	586080e7          	jalr	1414(ra) # 80005efc <printf>
  return 0;
    8000297e:	4481                	li	s1,0
    80002980:	bf99                	j	800028d6 <balloc+0x8c>

0000000080002982 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002982:	7179                	addi	sp,sp,-48
    80002984:	f406                	sd	ra,40(sp)
    80002986:	f022                	sd	s0,32(sp)
    80002988:	ec26                	sd	s1,24(sp)
    8000298a:	e84a                	sd	s2,16(sp)
    8000298c:	e44e                	sd	s3,8(sp)
    8000298e:	e052                	sd	s4,0(sp)
    80002990:	1800                	addi	s0,sp,48
    80002992:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002994:	47ad                	li	a5,11
    80002996:	02b7e763          	bltu	a5,a1,800029c4 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    8000299a:	02059493          	slli	s1,a1,0x20
    8000299e:	9081                	srli	s1,s1,0x20
    800029a0:	048a                	slli	s1,s1,0x2
    800029a2:	94aa                	add	s1,s1,a0
    800029a4:	0504a903          	lw	s2,80(s1)
    800029a8:	06091e63          	bnez	s2,80002a24 <bmap+0xa2>
      addr = balloc(ip->dev);
    800029ac:	4108                	lw	a0,0(a0)
    800029ae:	00000097          	auipc	ra,0x0
    800029b2:	e9c080e7          	jalr	-356(ra) # 8000284a <balloc>
    800029b6:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800029ba:	06090563          	beqz	s2,80002a24 <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    800029be:	0524a823          	sw	s2,80(s1)
    800029c2:	a08d                	j	80002a24 <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    800029c4:	ff45849b          	addiw	s1,a1,-12
    800029c8:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800029cc:	0ff00793          	li	a5,255
    800029d0:	08e7e563          	bltu	a5,a4,80002a5a <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800029d4:	08052903          	lw	s2,128(a0)
    800029d8:	00091d63          	bnez	s2,800029f2 <bmap+0x70>
      addr = balloc(ip->dev);
    800029dc:	4108                	lw	a0,0(a0)
    800029de:	00000097          	auipc	ra,0x0
    800029e2:	e6c080e7          	jalr	-404(ra) # 8000284a <balloc>
    800029e6:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800029ea:	02090d63          	beqz	s2,80002a24 <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    800029ee:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    800029f2:	85ca                	mv	a1,s2
    800029f4:	0009a503          	lw	a0,0(s3)
    800029f8:	00000097          	auipc	ra,0x0
    800029fc:	b90080e7          	jalr	-1136(ra) # 80002588 <bread>
    80002a00:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80002a02:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80002a06:	02049593          	slli	a1,s1,0x20
    80002a0a:	9181                	srli	a1,a1,0x20
    80002a0c:	058a                	slli	a1,a1,0x2
    80002a0e:	00b784b3          	add	s1,a5,a1
    80002a12:	0004a903          	lw	s2,0(s1)
    80002a16:	02090063          	beqz	s2,80002a36 <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002a1a:	8552                	mv	a0,s4
    80002a1c:	00000097          	auipc	ra,0x0
    80002a20:	c9c080e7          	jalr	-868(ra) # 800026b8 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80002a24:	854a                	mv	a0,s2
    80002a26:	70a2                	ld	ra,40(sp)
    80002a28:	7402                	ld	s0,32(sp)
    80002a2a:	64e2                	ld	s1,24(sp)
    80002a2c:	6942                	ld	s2,16(sp)
    80002a2e:	69a2                	ld	s3,8(sp)
    80002a30:	6a02                	ld	s4,0(sp)
    80002a32:	6145                	addi	sp,sp,48
    80002a34:	8082                	ret
      addr = balloc(ip->dev);
    80002a36:	0009a503          	lw	a0,0(s3)
    80002a3a:	00000097          	auipc	ra,0x0
    80002a3e:	e10080e7          	jalr	-496(ra) # 8000284a <balloc>
    80002a42:	0005091b          	sext.w	s2,a0
      if(addr){
    80002a46:	fc090ae3          	beqz	s2,80002a1a <bmap+0x98>
        a[bn] = addr;
    80002a4a:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80002a4e:	8552                	mv	a0,s4
    80002a50:	00001097          	auipc	ra,0x1
    80002a54:	eec080e7          	jalr	-276(ra) # 8000393c <log_write>
    80002a58:	b7c9                	j	80002a1a <bmap+0x98>
  panic("bmap: out of range");
    80002a5a:	00006517          	auipc	a0,0x6
    80002a5e:	b0650513          	addi	a0,a0,-1274 # 80008560 <syscalls+0x160>
    80002a62:	00003097          	auipc	ra,0x3
    80002a66:	450080e7          	jalr	1104(ra) # 80005eb2 <panic>

0000000080002a6a <iget>:
{
    80002a6a:	7179                	addi	sp,sp,-48
    80002a6c:	f406                	sd	ra,40(sp)
    80002a6e:	f022                	sd	s0,32(sp)
    80002a70:	ec26                	sd	s1,24(sp)
    80002a72:	e84a                	sd	s2,16(sp)
    80002a74:	e44e                	sd	s3,8(sp)
    80002a76:	e052                	sd	s4,0(sp)
    80002a78:	1800                	addi	s0,sp,48
    80002a7a:	89aa                	mv	s3,a0
    80002a7c:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80002a7e:	00014517          	auipc	a0,0x14
    80002a82:	42a50513          	addi	a0,a0,1066 # 80016ea8 <itable>
    80002a86:	00004097          	auipc	ra,0x4
    80002a8a:	976080e7          	jalr	-1674(ra) # 800063fc <acquire>
  empty = 0;
    80002a8e:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002a90:	00014497          	auipc	s1,0x14
    80002a94:	43048493          	addi	s1,s1,1072 # 80016ec0 <itable+0x18>
    80002a98:	00016697          	auipc	a3,0x16
    80002a9c:	eb868693          	addi	a3,a3,-328 # 80018950 <log>
    80002aa0:	a039                	j	80002aae <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002aa2:	02090b63          	beqz	s2,80002ad8 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002aa6:	08848493          	addi	s1,s1,136
    80002aaa:	02d48a63          	beq	s1,a3,80002ade <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80002aae:	449c                	lw	a5,8(s1)
    80002ab0:	fef059e3          	blez	a5,80002aa2 <iget+0x38>
    80002ab4:	4098                	lw	a4,0(s1)
    80002ab6:	ff3716e3          	bne	a4,s3,80002aa2 <iget+0x38>
    80002aba:	40d8                	lw	a4,4(s1)
    80002abc:	ff4713e3          	bne	a4,s4,80002aa2 <iget+0x38>
      ip->ref++;
    80002ac0:	2785                	addiw	a5,a5,1
    80002ac2:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80002ac4:	00014517          	auipc	a0,0x14
    80002ac8:	3e450513          	addi	a0,a0,996 # 80016ea8 <itable>
    80002acc:	00004097          	auipc	ra,0x4
    80002ad0:	9e4080e7          	jalr	-1564(ra) # 800064b0 <release>
      return ip;
    80002ad4:	8926                	mv	s2,s1
    80002ad6:	a03d                	j	80002b04 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002ad8:	f7f9                	bnez	a5,80002aa6 <iget+0x3c>
    80002ada:	8926                	mv	s2,s1
    80002adc:	b7e9                	j	80002aa6 <iget+0x3c>
  if(empty == 0)
    80002ade:	02090c63          	beqz	s2,80002b16 <iget+0xac>
  ip->dev = dev;
    80002ae2:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80002ae6:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80002aea:	4785                	li	a5,1
    80002aec:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80002af0:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80002af4:	00014517          	auipc	a0,0x14
    80002af8:	3b450513          	addi	a0,a0,948 # 80016ea8 <itable>
    80002afc:	00004097          	auipc	ra,0x4
    80002b00:	9b4080e7          	jalr	-1612(ra) # 800064b0 <release>
}
    80002b04:	854a                	mv	a0,s2
    80002b06:	70a2                	ld	ra,40(sp)
    80002b08:	7402                	ld	s0,32(sp)
    80002b0a:	64e2                	ld	s1,24(sp)
    80002b0c:	6942                	ld	s2,16(sp)
    80002b0e:	69a2                	ld	s3,8(sp)
    80002b10:	6a02                	ld	s4,0(sp)
    80002b12:	6145                	addi	sp,sp,48
    80002b14:	8082                	ret
    panic("iget: no inodes");
    80002b16:	00006517          	auipc	a0,0x6
    80002b1a:	a6250513          	addi	a0,a0,-1438 # 80008578 <syscalls+0x178>
    80002b1e:	00003097          	auipc	ra,0x3
    80002b22:	394080e7          	jalr	916(ra) # 80005eb2 <panic>

0000000080002b26 <fsinit>:
fsinit(int dev) {
    80002b26:	7179                	addi	sp,sp,-48
    80002b28:	f406                	sd	ra,40(sp)
    80002b2a:	f022                	sd	s0,32(sp)
    80002b2c:	ec26                	sd	s1,24(sp)
    80002b2e:	e84a                	sd	s2,16(sp)
    80002b30:	e44e                	sd	s3,8(sp)
    80002b32:	1800                	addi	s0,sp,48
    80002b34:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80002b36:	4585                	li	a1,1
    80002b38:	00000097          	auipc	ra,0x0
    80002b3c:	a50080e7          	jalr	-1456(ra) # 80002588 <bread>
    80002b40:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80002b42:	00014997          	auipc	s3,0x14
    80002b46:	34698993          	addi	s3,s3,838 # 80016e88 <sb>
    80002b4a:	02000613          	li	a2,32
    80002b4e:	05850593          	addi	a1,a0,88
    80002b52:	854e                	mv	a0,s3
    80002b54:	ffffd097          	auipc	ra,0xffffd
    80002b58:	684080e7          	jalr	1668(ra) # 800001d8 <memmove>
  brelse(bp);
    80002b5c:	8526                	mv	a0,s1
    80002b5e:	00000097          	auipc	ra,0x0
    80002b62:	b5a080e7          	jalr	-1190(ra) # 800026b8 <brelse>
  if(sb.magic != FSMAGIC)
    80002b66:	0009a703          	lw	a4,0(s3)
    80002b6a:	102037b7          	lui	a5,0x10203
    80002b6e:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80002b72:	02f71263          	bne	a4,a5,80002b96 <fsinit+0x70>
  initlog(dev, &sb);
    80002b76:	00014597          	auipc	a1,0x14
    80002b7a:	31258593          	addi	a1,a1,786 # 80016e88 <sb>
    80002b7e:	854a                	mv	a0,s2
    80002b80:	00001097          	auipc	ra,0x1
    80002b84:	b40080e7          	jalr	-1216(ra) # 800036c0 <initlog>
}
    80002b88:	70a2                	ld	ra,40(sp)
    80002b8a:	7402                	ld	s0,32(sp)
    80002b8c:	64e2                	ld	s1,24(sp)
    80002b8e:	6942                	ld	s2,16(sp)
    80002b90:	69a2                	ld	s3,8(sp)
    80002b92:	6145                	addi	sp,sp,48
    80002b94:	8082                	ret
    panic("invalid file system");
    80002b96:	00006517          	auipc	a0,0x6
    80002b9a:	9f250513          	addi	a0,a0,-1550 # 80008588 <syscalls+0x188>
    80002b9e:	00003097          	auipc	ra,0x3
    80002ba2:	314080e7          	jalr	788(ra) # 80005eb2 <panic>

0000000080002ba6 <iinit>:
{
    80002ba6:	7179                	addi	sp,sp,-48
    80002ba8:	f406                	sd	ra,40(sp)
    80002baa:	f022                	sd	s0,32(sp)
    80002bac:	ec26                	sd	s1,24(sp)
    80002bae:	e84a                	sd	s2,16(sp)
    80002bb0:	e44e                	sd	s3,8(sp)
    80002bb2:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80002bb4:	00006597          	auipc	a1,0x6
    80002bb8:	9ec58593          	addi	a1,a1,-1556 # 800085a0 <syscalls+0x1a0>
    80002bbc:	00014517          	auipc	a0,0x14
    80002bc0:	2ec50513          	addi	a0,a0,748 # 80016ea8 <itable>
    80002bc4:	00003097          	auipc	ra,0x3
    80002bc8:	7a8080e7          	jalr	1960(ra) # 8000636c <initlock>
  for(i = 0; i < NINODE; i++) {
    80002bcc:	00014497          	auipc	s1,0x14
    80002bd0:	30448493          	addi	s1,s1,772 # 80016ed0 <itable+0x28>
    80002bd4:	00016997          	auipc	s3,0x16
    80002bd8:	d8c98993          	addi	s3,s3,-628 # 80018960 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80002bdc:	00006917          	auipc	s2,0x6
    80002be0:	9cc90913          	addi	s2,s2,-1588 # 800085a8 <syscalls+0x1a8>
    80002be4:	85ca                	mv	a1,s2
    80002be6:	8526                	mv	a0,s1
    80002be8:	00001097          	auipc	ra,0x1
    80002bec:	e3a080e7          	jalr	-454(ra) # 80003a22 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80002bf0:	08848493          	addi	s1,s1,136
    80002bf4:	ff3498e3          	bne	s1,s3,80002be4 <iinit+0x3e>
}
    80002bf8:	70a2                	ld	ra,40(sp)
    80002bfa:	7402                	ld	s0,32(sp)
    80002bfc:	64e2                	ld	s1,24(sp)
    80002bfe:	6942                	ld	s2,16(sp)
    80002c00:	69a2                	ld	s3,8(sp)
    80002c02:	6145                	addi	sp,sp,48
    80002c04:	8082                	ret

0000000080002c06 <ialloc>:
{
    80002c06:	715d                	addi	sp,sp,-80
    80002c08:	e486                	sd	ra,72(sp)
    80002c0a:	e0a2                	sd	s0,64(sp)
    80002c0c:	fc26                	sd	s1,56(sp)
    80002c0e:	f84a                	sd	s2,48(sp)
    80002c10:	f44e                	sd	s3,40(sp)
    80002c12:	f052                	sd	s4,32(sp)
    80002c14:	ec56                	sd	s5,24(sp)
    80002c16:	e85a                	sd	s6,16(sp)
    80002c18:	e45e                	sd	s7,8(sp)
    80002c1a:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80002c1c:	00014717          	auipc	a4,0x14
    80002c20:	27872703          	lw	a4,632(a4) # 80016e94 <sb+0xc>
    80002c24:	4785                	li	a5,1
    80002c26:	04e7fa63          	bgeu	a5,a4,80002c7a <ialloc+0x74>
    80002c2a:	8aaa                	mv	s5,a0
    80002c2c:	8bae                	mv	s7,a1
    80002c2e:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80002c30:	00014a17          	auipc	s4,0x14
    80002c34:	258a0a13          	addi	s4,s4,600 # 80016e88 <sb>
    80002c38:	00048b1b          	sext.w	s6,s1
    80002c3c:	0044d593          	srli	a1,s1,0x4
    80002c40:	018a2783          	lw	a5,24(s4)
    80002c44:	9dbd                	addw	a1,a1,a5
    80002c46:	8556                	mv	a0,s5
    80002c48:	00000097          	auipc	ra,0x0
    80002c4c:	940080e7          	jalr	-1728(ra) # 80002588 <bread>
    80002c50:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80002c52:	05850993          	addi	s3,a0,88
    80002c56:	00f4f793          	andi	a5,s1,15
    80002c5a:	079a                	slli	a5,a5,0x6
    80002c5c:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80002c5e:	00099783          	lh	a5,0(s3)
    80002c62:	c3a1                	beqz	a5,80002ca2 <ialloc+0x9c>
    brelse(bp);
    80002c64:	00000097          	auipc	ra,0x0
    80002c68:	a54080e7          	jalr	-1452(ra) # 800026b8 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80002c6c:	0485                	addi	s1,s1,1
    80002c6e:	00ca2703          	lw	a4,12(s4)
    80002c72:	0004879b          	sext.w	a5,s1
    80002c76:	fce7e1e3          	bltu	a5,a4,80002c38 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80002c7a:	00006517          	auipc	a0,0x6
    80002c7e:	93650513          	addi	a0,a0,-1738 # 800085b0 <syscalls+0x1b0>
    80002c82:	00003097          	auipc	ra,0x3
    80002c86:	27a080e7          	jalr	634(ra) # 80005efc <printf>
  return 0;
    80002c8a:	4501                	li	a0,0
}
    80002c8c:	60a6                	ld	ra,72(sp)
    80002c8e:	6406                	ld	s0,64(sp)
    80002c90:	74e2                	ld	s1,56(sp)
    80002c92:	7942                	ld	s2,48(sp)
    80002c94:	79a2                	ld	s3,40(sp)
    80002c96:	7a02                	ld	s4,32(sp)
    80002c98:	6ae2                	ld	s5,24(sp)
    80002c9a:	6b42                	ld	s6,16(sp)
    80002c9c:	6ba2                	ld	s7,8(sp)
    80002c9e:	6161                	addi	sp,sp,80
    80002ca0:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80002ca2:	04000613          	li	a2,64
    80002ca6:	4581                	li	a1,0
    80002ca8:	854e                	mv	a0,s3
    80002caa:	ffffd097          	auipc	ra,0xffffd
    80002cae:	4ce080e7          	jalr	1230(ra) # 80000178 <memset>
      dip->type = type;
    80002cb2:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80002cb6:	854a                	mv	a0,s2
    80002cb8:	00001097          	auipc	ra,0x1
    80002cbc:	c84080e7          	jalr	-892(ra) # 8000393c <log_write>
      brelse(bp);
    80002cc0:	854a                	mv	a0,s2
    80002cc2:	00000097          	auipc	ra,0x0
    80002cc6:	9f6080e7          	jalr	-1546(ra) # 800026b8 <brelse>
      return iget(dev, inum);
    80002cca:	85da                	mv	a1,s6
    80002ccc:	8556                	mv	a0,s5
    80002cce:	00000097          	auipc	ra,0x0
    80002cd2:	d9c080e7          	jalr	-612(ra) # 80002a6a <iget>
    80002cd6:	bf5d                	j	80002c8c <ialloc+0x86>

0000000080002cd8 <iupdate>:
{
    80002cd8:	1101                	addi	sp,sp,-32
    80002cda:	ec06                	sd	ra,24(sp)
    80002cdc:	e822                	sd	s0,16(sp)
    80002cde:	e426                	sd	s1,8(sp)
    80002ce0:	e04a                	sd	s2,0(sp)
    80002ce2:	1000                	addi	s0,sp,32
    80002ce4:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80002ce6:	415c                	lw	a5,4(a0)
    80002ce8:	0047d79b          	srliw	a5,a5,0x4
    80002cec:	00014597          	auipc	a1,0x14
    80002cf0:	1b45a583          	lw	a1,436(a1) # 80016ea0 <sb+0x18>
    80002cf4:	9dbd                	addw	a1,a1,a5
    80002cf6:	4108                	lw	a0,0(a0)
    80002cf8:	00000097          	auipc	ra,0x0
    80002cfc:	890080e7          	jalr	-1904(ra) # 80002588 <bread>
    80002d00:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80002d02:	05850793          	addi	a5,a0,88
    80002d06:	40c8                	lw	a0,4(s1)
    80002d08:	893d                	andi	a0,a0,15
    80002d0a:	051a                	slli	a0,a0,0x6
    80002d0c:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80002d0e:	04449703          	lh	a4,68(s1)
    80002d12:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80002d16:	04649703          	lh	a4,70(s1)
    80002d1a:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80002d1e:	04849703          	lh	a4,72(s1)
    80002d22:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80002d26:	04a49703          	lh	a4,74(s1)
    80002d2a:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80002d2e:	44f8                	lw	a4,76(s1)
    80002d30:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80002d32:	03400613          	li	a2,52
    80002d36:	05048593          	addi	a1,s1,80
    80002d3a:	0531                	addi	a0,a0,12
    80002d3c:	ffffd097          	auipc	ra,0xffffd
    80002d40:	49c080e7          	jalr	1180(ra) # 800001d8 <memmove>
  log_write(bp);
    80002d44:	854a                	mv	a0,s2
    80002d46:	00001097          	auipc	ra,0x1
    80002d4a:	bf6080e7          	jalr	-1034(ra) # 8000393c <log_write>
  brelse(bp);
    80002d4e:	854a                	mv	a0,s2
    80002d50:	00000097          	auipc	ra,0x0
    80002d54:	968080e7          	jalr	-1688(ra) # 800026b8 <brelse>
}
    80002d58:	60e2                	ld	ra,24(sp)
    80002d5a:	6442                	ld	s0,16(sp)
    80002d5c:	64a2                	ld	s1,8(sp)
    80002d5e:	6902                	ld	s2,0(sp)
    80002d60:	6105                	addi	sp,sp,32
    80002d62:	8082                	ret

0000000080002d64 <idup>:
{
    80002d64:	1101                	addi	sp,sp,-32
    80002d66:	ec06                	sd	ra,24(sp)
    80002d68:	e822                	sd	s0,16(sp)
    80002d6a:	e426                	sd	s1,8(sp)
    80002d6c:	1000                	addi	s0,sp,32
    80002d6e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80002d70:	00014517          	auipc	a0,0x14
    80002d74:	13850513          	addi	a0,a0,312 # 80016ea8 <itable>
    80002d78:	00003097          	auipc	ra,0x3
    80002d7c:	684080e7          	jalr	1668(ra) # 800063fc <acquire>
  ip->ref++;
    80002d80:	449c                	lw	a5,8(s1)
    80002d82:	2785                	addiw	a5,a5,1
    80002d84:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80002d86:	00014517          	auipc	a0,0x14
    80002d8a:	12250513          	addi	a0,a0,290 # 80016ea8 <itable>
    80002d8e:	00003097          	auipc	ra,0x3
    80002d92:	722080e7          	jalr	1826(ra) # 800064b0 <release>
}
    80002d96:	8526                	mv	a0,s1
    80002d98:	60e2                	ld	ra,24(sp)
    80002d9a:	6442                	ld	s0,16(sp)
    80002d9c:	64a2                	ld	s1,8(sp)
    80002d9e:	6105                	addi	sp,sp,32
    80002da0:	8082                	ret

0000000080002da2 <ilock>:
{
    80002da2:	1101                	addi	sp,sp,-32
    80002da4:	ec06                	sd	ra,24(sp)
    80002da6:	e822                	sd	s0,16(sp)
    80002da8:	e426                	sd	s1,8(sp)
    80002daa:	e04a                	sd	s2,0(sp)
    80002dac:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80002dae:	c115                	beqz	a0,80002dd2 <ilock+0x30>
    80002db0:	84aa                	mv	s1,a0
    80002db2:	451c                	lw	a5,8(a0)
    80002db4:	00f05f63          	blez	a5,80002dd2 <ilock+0x30>
  acquiresleep(&ip->lock);
    80002db8:	0541                	addi	a0,a0,16
    80002dba:	00001097          	auipc	ra,0x1
    80002dbe:	ca2080e7          	jalr	-862(ra) # 80003a5c <acquiresleep>
  if(ip->valid == 0){
    80002dc2:	40bc                	lw	a5,64(s1)
    80002dc4:	cf99                	beqz	a5,80002de2 <ilock+0x40>
}
    80002dc6:	60e2                	ld	ra,24(sp)
    80002dc8:	6442                	ld	s0,16(sp)
    80002dca:	64a2                	ld	s1,8(sp)
    80002dcc:	6902                	ld	s2,0(sp)
    80002dce:	6105                	addi	sp,sp,32
    80002dd0:	8082                	ret
    panic("ilock");
    80002dd2:	00005517          	auipc	a0,0x5
    80002dd6:	7f650513          	addi	a0,a0,2038 # 800085c8 <syscalls+0x1c8>
    80002dda:	00003097          	auipc	ra,0x3
    80002dde:	0d8080e7          	jalr	216(ra) # 80005eb2 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80002de2:	40dc                	lw	a5,4(s1)
    80002de4:	0047d79b          	srliw	a5,a5,0x4
    80002de8:	00014597          	auipc	a1,0x14
    80002dec:	0b85a583          	lw	a1,184(a1) # 80016ea0 <sb+0x18>
    80002df0:	9dbd                	addw	a1,a1,a5
    80002df2:	4088                	lw	a0,0(s1)
    80002df4:	fffff097          	auipc	ra,0xfffff
    80002df8:	794080e7          	jalr	1940(ra) # 80002588 <bread>
    80002dfc:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80002dfe:	05850593          	addi	a1,a0,88
    80002e02:	40dc                	lw	a5,4(s1)
    80002e04:	8bbd                	andi	a5,a5,15
    80002e06:	079a                	slli	a5,a5,0x6
    80002e08:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80002e0a:	00059783          	lh	a5,0(a1)
    80002e0e:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80002e12:	00259783          	lh	a5,2(a1)
    80002e16:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80002e1a:	00459783          	lh	a5,4(a1)
    80002e1e:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80002e22:	00659783          	lh	a5,6(a1)
    80002e26:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80002e2a:	459c                	lw	a5,8(a1)
    80002e2c:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80002e2e:	03400613          	li	a2,52
    80002e32:	05b1                	addi	a1,a1,12
    80002e34:	05048513          	addi	a0,s1,80
    80002e38:	ffffd097          	auipc	ra,0xffffd
    80002e3c:	3a0080e7          	jalr	928(ra) # 800001d8 <memmove>
    brelse(bp);
    80002e40:	854a                	mv	a0,s2
    80002e42:	00000097          	auipc	ra,0x0
    80002e46:	876080e7          	jalr	-1930(ra) # 800026b8 <brelse>
    ip->valid = 1;
    80002e4a:	4785                	li	a5,1
    80002e4c:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80002e4e:	04449783          	lh	a5,68(s1)
    80002e52:	fbb5                	bnez	a5,80002dc6 <ilock+0x24>
      panic("ilock: no type");
    80002e54:	00005517          	auipc	a0,0x5
    80002e58:	77c50513          	addi	a0,a0,1916 # 800085d0 <syscalls+0x1d0>
    80002e5c:	00003097          	auipc	ra,0x3
    80002e60:	056080e7          	jalr	86(ra) # 80005eb2 <panic>

0000000080002e64 <iunlock>:
{
    80002e64:	1101                	addi	sp,sp,-32
    80002e66:	ec06                	sd	ra,24(sp)
    80002e68:	e822                	sd	s0,16(sp)
    80002e6a:	e426                	sd	s1,8(sp)
    80002e6c:	e04a                	sd	s2,0(sp)
    80002e6e:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80002e70:	c905                	beqz	a0,80002ea0 <iunlock+0x3c>
    80002e72:	84aa                	mv	s1,a0
    80002e74:	01050913          	addi	s2,a0,16
    80002e78:	854a                	mv	a0,s2
    80002e7a:	00001097          	auipc	ra,0x1
    80002e7e:	c7c080e7          	jalr	-900(ra) # 80003af6 <holdingsleep>
    80002e82:	cd19                	beqz	a0,80002ea0 <iunlock+0x3c>
    80002e84:	449c                	lw	a5,8(s1)
    80002e86:	00f05d63          	blez	a5,80002ea0 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80002e8a:	854a                	mv	a0,s2
    80002e8c:	00001097          	auipc	ra,0x1
    80002e90:	c26080e7          	jalr	-986(ra) # 80003ab2 <releasesleep>
}
    80002e94:	60e2                	ld	ra,24(sp)
    80002e96:	6442                	ld	s0,16(sp)
    80002e98:	64a2                	ld	s1,8(sp)
    80002e9a:	6902                	ld	s2,0(sp)
    80002e9c:	6105                	addi	sp,sp,32
    80002e9e:	8082                	ret
    panic("iunlock");
    80002ea0:	00005517          	auipc	a0,0x5
    80002ea4:	74050513          	addi	a0,a0,1856 # 800085e0 <syscalls+0x1e0>
    80002ea8:	00003097          	auipc	ra,0x3
    80002eac:	00a080e7          	jalr	10(ra) # 80005eb2 <panic>

0000000080002eb0 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80002eb0:	7179                	addi	sp,sp,-48
    80002eb2:	f406                	sd	ra,40(sp)
    80002eb4:	f022                	sd	s0,32(sp)
    80002eb6:	ec26                	sd	s1,24(sp)
    80002eb8:	e84a                	sd	s2,16(sp)
    80002eba:	e44e                	sd	s3,8(sp)
    80002ebc:	e052                	sd	s4,0(sp)
    80002ebe:	1800                	addi	s0,sp,48
    80002ec0:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80002ec2:	05050493          	addi	s1,a0,80
    80002ec6:	08050913          	addi	s2,a0,128
    80002eca:	a021                	j	80002ed2 <itrunc+0x22>
    80002ecc:	0491                	addi	s1,s1,4
    80002ece:	01248d63          	beq	s1,s2,80002ee8 <itrunc+0x38>
    if(ip->addrs[i]){
    80002ed2:	408c                	lw	a1,0(s1)
    80002ed4:	dde5                	beqz	a1,80002ecc <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80002ed6:	0009a503          	lw	a0,0(s3)
    80002eda:	00000097          	auipc	ra,0x0
    80002ede:	8f4080e7          	jalr	-1804(ra) # 800027ce <bfree>
      ip->addrs[i] = 0;
    80002ee2:	0004a023          	sw	zero,0(s1)
    80002ee6:	b7dd                	j	80002ecc <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80002ee8:	0809a583          	lw	a1,128(s3)
    80002eec:	e185                	bnez	a1,80002f0c <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80002eee:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80002ef2:	854e                	mv	a0,s3
    80002ef4:	00000097          	auipc	ra,0x0
    80002ef8:	de4080e7          	jalr	-540(ra) # 80002cd8 <iupdate>
}
    80002efc:	70a2                	ld	ra,40(sp)
    80002efe:	7402                	ld	s0,32(sp)
    80002f00:	64e2                	ld	s1,24(sp)
    80002f02:	6942                	ld	s2,16(sp)
    80002f04:	69a2                	ld	s3,8(sp)
    80002f06:	6a02                	ld	s4,0(sp)
    80002f08:	6145                	addi	sp,sp,48
    80002f0a:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80002f0c:	0009a503          	lw	a0,0(s3)
    80002f10:	fffff097          	auipc	ra,0xfffff
    80002f14:	678080e7          	jalr	1656(ra) # 80002588 <bread>
    80002f18:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80002f1a:	05850493          	addi	s1,a0,88
    80002f1e:	45850913          	addi	s2,a0,1112
    80002f22:	a811                	j	80002f36 <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80002f24:	0009a503          	lw	a0,0(s3)
    80002f28:	00000097          	auipc	ra,0x0
    80002f2c:	8a6080e7          	jalr	-1882(ra) # 800027ce <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80002f30:	0491                	addi	s1,s1,4
    80002f32:	01248563          	beq	s1,s2,80002f3c <itrunc+0x8c>
      if(a[j])
    80002f36:	408c                	lw	a1,0(s1)
    80002f38:	dde5                	beqz	a1,80002f30 <itrunc+0x80>
    80002f3a:	b7ed                	j	80002f24 <itrunc+0x74>
    brelse(bp);
    80002f3c:	8552                	mv	a0,s4
    80002f3e:	fffff097          	auipc	ra,0xfffff
    80002f42:	77a080e7          	jalr	1914(ra) # 800026b8 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80002f46:	0809a583          	lw	a1,128(s3)
    80002f4a:	0009a503          	lw	a0,0(s3)
    80002f4e:	00000097          	auipc	ra,0x0
    80002f52:	880080e7          	jalr	-1920(ra) # 800027ce <bfree>
    ip->addrs[NDIRECT] = 0;
    80002f56:	0809a023          	sw	zero,128(s3)
    80002f5a:	bf51                	j	80002eee <itrunc+0x3e>

0000000080002f5c <iput>:
{
    80002f5c:	1101                	addi	sp,sp,-32
    80002f5e:	ec06                	sd	ra,24(sp)
    80002f60:	e822                	sd	s0,16(sp)
    80002f62:	e426                	sd	s1,8(sp)
    80002f64:	e04a                	sd	s2,0(sp)
    80002f66:	1000                	addi	s0,sp,32
    80002f68:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80002f6a:	00014517          	auipc	a0,0x14
    80002f6e:	f3e50513          	addi	a0,a0,-194 # 80016ea8 <itable>
    80002f72:	00003097          	auipc	ra,0x3
    80002f76:	48a080e7          	jalr	1162(ra) # 800063fc <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002f7a:	4498                	lw	a4,8(s1)
    80002f7c:	4785                	li	a5,1
    80002f7e:	02f70363          	beq	a4,a5,80002fa4 <iput+0x48>
  ip->ref--;
    80002f82:	449c                	lw	a5,8(s1)
    80002f84:	37fd                	addiw	a5,a5,-1
    80002f86:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80002f88:	00014517          	auipc	a0,0x14
    80002f8c:	f2050513          	addi	a0,a0,-224 # 80016ea8 <itable>
    80002f90:	00003097          	auipc	ra,0x3
    80002f94:	520080e7          	jalr	1312(ra) # 800064b0 <release>
}
    80002f98:	60e2                	ld	ra,24(sp)
    80002f9a:	6442                	ld	s0,16(sp)
    80002f9c:	64a2                	ld	s1,8(sp)
    80002f9e:	6902                	ld	s2,0(sp)
    80002fa0:	6105                	addi	sp,sp,32
    80002fa2:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002fa4:	40bc                	lw	a5,64(s1)
    80002fa6:	dff1                	beqz	a5,80002f82 <iput+0x26>
    80002fa8:	04a49783          	lh	a5,74(s1)
    80002fac:	fbf9                	bnez	a5,80002f82 <iput+0x26>
    acquiresleep(&ip->lock);
    80002fae:	01048913          	addi	s2,s1,16
    80002fb2:	854a                	mv	a0,s2
    80002fb4:	00001097          	auipc	ra,0x1
    80002fb8:	aa8080e7          	jalr	-1368(ra) # 80003a5c <acquiresleep>
    release(&itable.lock);
    80002fbc:	00014517          	auipc	a0,0x14
    80002fc0:	eec50513          	addi	a0,a0,-276 # 80016ea8 <itable>
    80002fc4:	00003097          	auipc	ra,0x3
    80002fc8:	4ec080e7          	jalr	1260(ra) # 800064b0 <release>
    itrunc(ip);
    80002fcc:	8526                	mv	a0,s1
    80002fce:	00000097          	auipc	ra,0x0
    80002fd2:	ee2080e7          	jalr	-286(ra) # 80002eb0 <itrunc>
    ip->type = 0;
    80002fd6:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80002fda:	8526                	mv	a0,s1
    80002fdc:	00000097          	auipc	ra,0x0
    80002fe0:	cfc080e7          	jalr	-772(ra) # 80002cd8 <iupdate>
    ip->valid = 0;
    80002fe4:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80002fe8:	854a                	mv	a0,s2
    80002fea:	00001097          	auipc	ra,0x1
    80002fee:	ac8080e7          	jalr	-1336(ra) # 80003ab2 <releasesleep>
    acquire(&itable.lock);
    80002ff2:	00014517          	auipc	a0,0x14
    80002ff6:	eb650513          	addi	a0,a0,-330 # 80016ea8 <itable>
    80002ffa:	00003097          	auipc	ra,0x3
    80002ffe:	402080e7          	jalr	1026(ra) # 800063fc <acquire>
    80003002:	b741                	j	80002f82 <iput+0x26>

0000000080003004 <iunlockput>:
{
    80003004:	1101                	addi	sp,sp,-32
    80003006:	ec06                	sd	ra,24(sp)
    80003008:	e822                	sd	s0,16(sp)
    8000300a:	e426                	sd	s1,8(sp)
    8000300c:	1000                	addi	s0,sp,32
    8000300e:	84aa                	mv	s1,a0
  iunlock(ip);
    80003010:	00000097          	auipc	ra,0x0
    80003014:	e54080e7          	jalr	-428(ra) # 80002e64 <iunlock>
  iput(ip);
    80003018:	8526                	mv	a0,s1
    8000301a:	00000097          	auipc	ra,0x0
    8000301e:	f42080e7          	jalr	-190(ra) # 80002f5c <iput>
}
    80003022:	60e2                	ld	ra,24(sp)
    80003024:	6442                	ld	s0,16(sp)
    80003026:	64a2                	ld	s1,8(sp)
    80003028:	6105                	addi	sp,sp,32
    8000302a:	8082                	ret

000000008000302c <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000302c:	1141                	addi	sp,sp,-16
    8000302e:	e422                	sd	s0,8(sp)
    80003030:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003032:	411c                	lw	a5,0(a0)
    80003034:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003036:	415c                	lw	a5,4(a0)
    80003038:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000303a:	04451783          	lh	a5,68(a0)
    8000303e:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003042:	04a51783          	lh	a5,74(a0)
    80003046:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000304a:	04c56783          	lwu	a5,76(a0)
    8000304e:	e99c                	sd	a5,16(a1)
}
    80003050:	6422                	ld	s0,8(sp)
    80003052:	0141                	addi	sp,sp,16
    80003054:	8082                	ret

0000000080003056 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003056:	457c                	lw	a5,76(a0)
    80003058:	0ed7e963          	bltu	a5,a3,8000314a <readi+0xf4>
{
    8000305c:	7159                	addi	sp,sp,-112
    8000305e:	f486                	sd	ra,104(sp)
    80003060:	f0a2                	sd	s0,96(sp)
    80003062:	eca6                	sd	s1,88(sp)
    80003064:	e8ca                	sd	s2,80(sp)
    80003066:	e4ce                	sd	s3,72(sp)
    80003068:	e0d2                	sd	s4,64(sp)
    8000306a:	fc56                	sd	s5,56(sp)
    8000306c:	f85a                	sd	s6,48(sp)
    8000306e:	f45e                	sd	s7,40(sp)
    80003070:	f062                	sd	s8,32(sp)
    80003072:	ec66                	sd	s9,24(sp)
    80003074:	e86a                	sd	s10,16(sp)
    80003076:	e46e                	sd	s11,8(sp)
    80003078:	1880                	addi	s0,sp,112
    8000307a:	8b2a                	mv	s6,a0
    8000307c:	8bae                	mv	s7,a1
    8000307e:	8a32                	mv	s4,a2
    80003080:	84b6                	mv	s1,a3
    80003082:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003084:	9f35                	addw	a4,a4,a3
    return 0;
    80003086:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003088:	0ad76063          	bltu	a4,a3,80003128 <readi+0xd2>
  if(off + n > ip->size)
    8000308c:	00e7f463          	bgeu	a5,a4,80003094 <readi+0x3e>
    n = ip->size - off;
    80003090:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003094:	0a0a8963          	beqz	s5,80003146 <readi+0xf0>
    80003098:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000309a:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000309e:	5c7d                	li	s8,-1
    800030a0:	a82d                	j	800030da <readi+0x84>
    800030a2:	020d1d93          	slli	s11,s10,0x20
    800030a6:	020ddd93          	srli	s11,s11,0x20
    800030aa:	05890613          	addi	a2,s2,88
    800030ae:	86ee                	mv	a3,s11
    800030b0:	963a                	add	a2,a2,a4
    800030b2:	85d2                	mv	a1,s4
    800030b4:	855e                	mv	a0,s7
    800030b6:	fffff097          	auipc	ra,0xfffff
    800030ba:	a30080e7          	jalr	-1488(ra) # 80001ae6 <either_copyout>
    800030be:	05850d63          	beq	a0,s8,80003118 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800030c2:	854a                	mv	a0,s2
    800030c4:	fffff097          	auipc	ra,0xfffff
    800030c8:	5f4080e7          	jalr	1524(ra) # 800026b8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800030cc:	013d09bb          	addw	s3,s10,s3
    800030d0:	009d04bb          	addw	s1,s10,s1
    800030d4:	9a6e                	add	s4,s4,s11
    800030d6:	0559f763          	bgeu	s3,s5,80003124 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    800030da:	00a4d59b          	srliw	a1,s1,0xa
    800030de:	855a                	mv	a0,s6
    800030e0:	00000097          	auipc	ra,0x0
    800030e4:	8a2080e7          	jalr	-1886(ra) # 80002982 <bmap>
    800030e8:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800030ec:	cd85                	beqz	a1,80003124 <readi+0xce>
    bp = bread(ip->dev, addr);
    800030ee:	000b2503          	lw	a0,0(s6)
    800030f2:	fffff097          	auipc	ra,0xfffff
    800030f6:	496080e7          	jalr	1174(ra) # 80002588 <bread>
    800030fa:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800030fc:	3ff4f713          	andi	a4,s1,1023
    80003100:	40ec87bb          	subw	a5,s9,a4
    80003104:	413a86bb          	subw	a3,s5,s3
    80003108:	8d3e                	mv	s10,a5
    8000310a:	2781                	sext.w	a5,a5
    8000310c:	0006861b          	sext.w	a2,a3
    80003110:	f8f679e3          	bgeu	a2,a5,800030a2 <readi+0x4c>
    80003114:	8d36                	mv	s10,a3
    80003116:	b771                	j	800030a2 <readi+0x4c>
      brelse(bp);
    80003118:	854a                	mv	a0,s2
    8000311a:	fffff097          	auipc	ra,0xfffff
    8000311e:	59e080e7          	jalr	1438(ra) # 800026b8 <brelse>
      tot = -1;
    80003122:	59fd                	li	s3,-1
  }
  return tot;
    80003124:	0009851b          	sext.w	a0,s3
}
    80003128:	70a6                	ld	ra,104(sp)
    8000312a:	7406                	ld	s0,96(sp)
    8000312c:	64e6                	ld	s1,88(sp)
    8000312e:	6946                	ld	s2,80(sp)
    80003130:	69a6                	ld	s3,72(sp)
    80003132:	6a06                	ld	s4,64(sp)
    80003134:	7ae2                	ld	s5,56(sp)
    80003136:	7b42                	ld	s6,48(sp)
    80003138:	7ba2                	ld	s7,40(sp)
    8000313a:	7c02                	ld	s8,32(sp)
    8000313c:	6ce2                	ld	s9,24(sp)
    8000313e:	6d42                	ld	s10,16(sp)
    80003140:	6da2                	ld	s11,8(sp)
    80003142:	6165                	addi	sp,sp,112
    80003144:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003146:	89d6                	mv	s3,s5
    80003148:	bff1                	j	80003124 <readi+0xce>
    return 0;
    8000314a:	4501                	li	a0,0
}
    8000314c:	8082                	ret

000000008000314e <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000314e:	457c                	lw	a5,76(a0)
    80003150:	10d7e863          	bltu	a5,a3,80003260 <writei+0x112>
{
    80003154:	7159                	addi	sp,sp,-112
    80003156:	f486                	sd	ra,104(sp)
    80003158:	f0a2                	sd	s0,96(sp)
    8000315a:	eca6                	sd	s1,88(sp)
    8000315c:	e8ca                	sd	s2,80(sp)
    8000315e:	e4ce                	sd	s3,72(sp)
    80003160:	e0d2                	sd	s4,64(sp)
    80003162:	fc56                	sd	s5,56(sp)
    80003164:	f85a                	sd	s6,48(sp)
    80003166:	f45e                	sd	s7,40(sp)
    80003168:	f062                	sd	s8,32(sp)
    8000316a:	ec66                	sd	s9,24(sp)
    8000316c:	e86a                	sd	s10,16(sp)
    8000316e:	e46e                	sd	s11,8(sp)
    80003170:	1880                	addi	s0,sp,112
    80003172:	8aaa                	mv	s5,a0
    80003174:	8bae                	mv	s7,a1
    80003176:	8a32                	mv	s4,a2
    80003178:	8936                	mv	s2,a3
    8000317a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000317c:	00e687bb          	addw	a5,a3,a4
    80003180:	0ed7e263          	bltu	a5,a3,80003264 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003184:	00043737          	lui	a4,0x43
    80003188:	0ef76063          	bltu	a4,a5,80003268 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000318c:	0c0b0863          	beqz	s6,8000325c <writei+0x10e>
    80003190:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003192:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003196:	5c7d                	li	s8,-1
    80003198:	a091                	j	800031dc <writei+0x8e>
    8000319a:	020d1d93          	slli	s11,s10,0x20
    8000319e:	020ddd93          	srli	s11,s11,0x20
    800031a2:	05848513          	addi	a0,s1,88
    800031a6:	86ee                	mv	a3,s11
    800031a8:	8652                	mv	a2,s4
    800031aa:	85de                	mv	a1,s7
    800031ac:	953a                	add	a0,a0,a4
    800031ae:	fffff097          	auipc	ra,0xfffff
    800031b2:	98e080e7          	jalr	-1650(ra) # 80001b3c <either_copyin>
    800031b6:	07850263          	beq	a0,s8,8000321a <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    800031ba:	8526                	mv	a0,s1
    800031bc:	00000097          	auipc	ra,0x0
    800031c0:	780080e7          	jalr	1920(ra) # 8000393c <log_write>
    brelse(bp);
    800031c4:	8526                	mv	a0,s1
    800031c6:	fffff097          	auipc	ra,0xfffff
    800031ca:	4f2080e7          	jalr	1266(ra) # 800026b8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800031ce:	013d09bb          	addw	s3,s10,s3
    800031d2:	012d093b          	addw	s2,s10,s2
    800031d6:	9a6e                	add	s4,s4,s11
    800031d8:	0569f663          	bgeu	s3,s6,80003224 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    800031dc:	00a9559b          	srliw	a1,s2,0xa
    800031e0:	8556                	mv	a0,s5
    800031e2:	fffff097          	auipc	ra,0xfffff
    800031e6:	7a0080e7          	jalr	1952(ra) # 80002982 <bmap>
    800031ea:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800031ee:	c99d                	beqz	a1,80003224 <writei+0xd6>
    bp = bread(ip->dev, addr);
    800031f0:	000aa503          	lw	a0,0(s5)
    800031f4:	fffff097          	auipc	ra,0xfffff
    800031f8:	394080e7          	jalr	916(ra) # 80002588 <bread>
    800031fc:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800031fe:	3ff97713          	andi	a4,s2,1023
    80003202:	40ec87bb          	subw	a5,s9,a4
    80003206:	413b06bb          	subw	a3,s6,s3
    8000320a:	8d3e                	mv	s10,a5
    8000320c:	2781                	sext.w	a5,a5
    8000320e:	0006861b          	sext.w	a2,a3
    80003212:	f8f674e3          	bgeu	a2,a5,8000319a <writei+0x4c>
    80003216:	8d36                	mv	s10,a3
    80003218:	b749                	j	8000319a <writei+0x4c>
      brelse(bp);
    8000321a:	8526                	mv	a0,s1
    8000321c:	fffff097          	auipc	ra,0xfffff
    80003220:	49c080e7          	jalr	1180(ra) # 800026b8 <brelse>
  }

  if(off > ip->size)
    80003224:	04caa783          	lw	a5,76(s5)
    80003228:	0127f463          	bgeu	a5,s2,80003230 <writei+0xe2>
    ip->size = off;
    8000322c:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003230:	8556                	mv	a0,s5
    80003232:	00000097          	auipc	ra,0x0
    80003236:	aa6080e7          	jalr	-1370(ra) # 80002cd8 <iupdate>

  return tot;
    8000323a:	0009851b          	sext.w	a0,s3
}
    8000323e:	70a6                	ld	ra,104(sp)
    80003240:	7406                	ld	s0,96(sp)
    80003242:	64e6                	ld	s1,88(sp)
    80003244:	6946                	ld	s2,80(sp)
    80003246:	69a6                	ld	s3,72(sp)
    80003248:	6a06                	ld	s4,64(sp)
    8000324a:	7ae2                	ld	s5,56(sp)
    8000324c:	7b42                	ld	s6,48(sp)
    8000324e:	7ba2                	ld	s7,40(sp)
    80003250:	7c02                	ld	s8,32(sp)
    80003252:	6ce2                	ld	s9,24(sp)
    80003254:	6d42                	ld	s10,16(sp)
    80003256:	6da2                	ld	s11,8(sp)
    80003258:	6165                	addi	sp,sp,112
    8000325a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000325c:	89da                	mv	s3,s6
    8000325e:	bfc9                	j	80003230 <writei+0xe2>
    return -1;
    80003260:	557d                	li	a0,-1
}
    80003262:	8082                	ret
    return -1;
    80003264:	557d                	li	a0,-1
    80003266:	bfe1                	j	8000323e <writei+0xf0>
    return -1;
    80003268:	557d                	li	a0,-1
    8000326a:	bfd1                	j	8000323e <writei+0xf0>

000000008000326c <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000326c:	1141                	addi	sp,sp,-16
    8000326e:	e406                	sd	ra,8(sp)
    80003270:	e022                	sd	s0,0(sp)
    80003272:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003274:	4639                	li	a2,14
    80003276:	ffffd097          	auipc	ra,0xffffd
    8000327a:	fda080e7          	jalr	-38(ra) # 80000250 <strncmp>
}
    8000327e:	60a2                	ld	ra,8(sp)
    80003280:	6402                	ld	s0,0(sp)
    80003282:	0141                	addi	sp,sp,16
    80003284:	8082                	ret

0000000080003286 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003286:	7139                	addi	sp,sp,-64
    80003288:	fc06                	sd	ra,56(sp)
    8000328a:	f822                	sd	s0,48(sp)
    8000328c:	f426                	sd	s1,40(sp)
    8000328e:	f04a                	sd	s2,32(sp)
    80003290:	ec4e                	sd	s3,24(sp)
    80003292:	e852                	sd	s4,16(sp)
    80003294:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003296:	04451703          	lh	a4,68(a0)
    8000329a:	4785                	li	a5,1
    8000329c:	00f71a63          	bne	a4,a5,800032b0 <dirlookup+0x2a>
    800032a0:	892a                	mv	s2,a0
    800032a2:	89ae                	mv	s3,a1
    800032a4:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800032a6:	457c                	lw	a5,76(a0)
    800032a8:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800032aa:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800032ac:	e79d                	bnez	a5,800032da <dirlookup+0x54>
    800032ae:	a8a5                	j	80003326 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    800032b0:	00005517          	auipc	a0,0x5
    800032b4:	33850513          	addi	a0,a0,824 # 800085e8 <syscalls+0x1e8>
    800032b8:	00003097          	auipc	ra,0x3
    800032bc:	bfa080e7          	jalr	-1030(ra) # 80005eb2 <panic>
      panic("dirlookup read");
    800032c0:	00005517          	auipc	a0,0x5
    800032c4:	34050513          	addi	a0,a0,832 # 80008600 <syscalls+0x200>
    800032c8:	00003097          	auipc	ra,0x3
    800032cc:	bea080e7          	jalr	-1046(ra) # 80005eb2 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800032d0:	24c1                	addiw	s1,s1,16
    800032d2:	04c92783          	lw	a5,76(s2)
    800032d6:	04f4f763          	bgeu	s1,a5,80003324 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800032da:	4741                	li	a4,16
    800032dc:	86a6                	mv	a3,s1
    800032de:	fc040613          	addi	a2,s0,-64
    800032e2:	4581                	li	a1,0
    800032e4:	854a                	mv	a0,s2
    800032e6:	00000097          	auipc	ra,0x0
    800032ea:	d70080e7          	jalr	-656(ra) # 80003056 <readi>
    800032ee:	47c1                	li	a5,16
    800032f0:	fcf518e3          	bne	a0,a5,800032c0 <dirlookup+0x3a>
    if(de.inum == 0)
    800032f4:	fc045783          	lhu	a5,-64(s0)
    800032f8:	dfe1                	beqz	a5,800032d0 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    800032fa:	fc240593          	addi	a1,s0,-62
    800032fe:	854e                	mv	a0,s3
    80003300:	00000097          	auipc	ra,0x0
    80003304:	f6c080e7          	jalr	-148(ra) # 8000326c <namecmp>
    80003308:	f561                	bnez	a0,800032d0 <dirlookup+0x4a>
      if(poff)
    8000330a:	000a0463          	beqz	s4,80003312 <dirlookup+0x8c>
        *poff = off;
    8000330e:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003312:	fc045583          	lhu	a1,-64(s0)
    80003316:	00092503          	lw	a0,0(s2)
    8000331a:	fffff097          	auipc	ra,0xfffff
    8000331e:	750080e7          	jalr	1872(ra) # 80002a6a <iget>
    80003322:	a011                	j	80003326 <dirlookup+0xa0>
  return 0;
    80003324:	4501                	li	a0,0
}
    80003326:	70e2                	ld	ra,56(sp)
    80003328:	7442                	ld	s0,48(sp)
    8000332a:	74a2                	ld	s1,40(sp)
    8000332c:	7902                	ld	s2,32(sp)
    8000332e:	69e2                	ld	s3,24(sp)
    80003330:	6a42                	ld	s4,16(sp)
    80003332:	6121                	addi	sp,sp,64
    80003334:	8082                	ret

0000000080003336 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003336:	711d                	addi	sp,sp,-96
    80003338:	ec86                	sd	ra,88(sp)
    8000333a:	e8a2                	sd	s0,80(sp)
    8000333c:	e4a6                	sd	s1,72(sp)
    8000333e:	e0ca                	sd	s2,64(sp)
    80003340:	fc4e                	sd	s3,56(sp)
    80003342:	f852                	sd	s4,48(sp)
    80003344:	f456                	sd	s5,40(sp)
    80003346:	f05a                	sd	s6,32(sp)
    80003348:	ec5e                	sd	s7,24(sp)
    8000334a:	e862                	sd	s8,16(sp)
    8000334c:	e466                	sd	s9,8(sp)
    8000334e:	1080                	addi	s0,sp,96
    80003350:	84aa                	mv	s1,a0
    80003352:	8b2e                	mv	s6,a1
    80003354:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003356:	00054703          	lbu	a4,0(a0)
    8000335a:	02f00793          	li	a5,47
    8000335e:	02f70363          	beq	a4,a5,80003384 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003362:	ffffe097          	auipc	ra,0xffffe
    80003366:	bd2080e7          	jalr	-1070(ra) # 80000f34 <myproc>
    8000336a:	15053503          	ld	a0,336(a0)
    8000336e:	00000097          	auipc	ra,0x0
    80003372:	9f6080e7          	jalr	-1546(ra) # 80002d64 <idup>
    80003376:	89aa                	mv	s3,a0
  while(*path == '/')
    80003378:	02f00913          	li	s2,47
  len = path - s;
    8000337c:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    8000337e:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003380:	4c05                	li	s8,1
    80003382:	a865                	j	8000343a <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003384:	4585                	li	a1,1
    80003386:	4505                	li	a0,1
    80003388:	fffff097          	auipc	ra,0xfffff
    8000338c:	6e2080e7          	jalr	1762(ra) # 80002a6a <iget>
    80003390:	89aa                	mv	s3,a0
    80003392:	b7dd                	j	80003378 <namex+0x42>
      iunlockput(ip);
    80003394:	854e                	mv	a0,s3
    80003396:	00000097          	auipc	ra,0x0
    8000339a:	c6e080e7          	jalr	-914(ra) # 80003004 <iunlockput>
      return 0;
    8000339e:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800033a0:	854e                	mv	a0,s3
    800033a2:	60e6                	ld	ra,88(sp)
    800033a4:	6446                	ld	s0,80(sp)
    800033a6:	64a6                	ld	s1,72(sp)
    800033a8:	6906                	ld	s2,64(sp)
    800033aa:	79e2                	ld	s3,56(sp)
    800033ac:	7a42                	ld	s4,48(sp)
    800033ae:	7aa2                	ld	s5,40(sp)
    800033b0:	7b02                	ld	s6,32(sp)
    800033b2:	6be2                	ld	s7,24(sp)
    800033b4:	6c42                	ld	s8,16(sp)
    800033b6:	6ca2                	ld	s9,8(sp)
    800033b8:	6125                	addi	sp,sp,96
    800033ba:	8082                	ret
      iunlock(ip);
    800033bc:	854e                	mv	a0,s3
    800033be:	00000097          	auipc	ra,0x0
    800033c2:	aa6080e7          	jalr	-1370(ra) # 80002e64 <iunlock>
      return ip;
    800033c6:	bfe9                	j	800033a0 <namex+0x6a>
      iunlockput(ip);
    800033c8:	854e                	mv	a0,s3
    800033ca:	00000097          	auipc	ra,0x0
    800033ce:	c3a080e7          	jalr	-966(ra) # 80003004 <iunlockput>
      return 0;
    800033d2:	89d2                	mv	s3,s4
    800033d4:	b7f1                	j	800033a0 <namex+0x6a>
  len = path - s;
    800033d6:	40b48633          	sub	a2,s1,a1
    800033da:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    800033de:	094cd463          	bge	s9,s4,80003466 <namex+0x130>
    memmove(name, s, DIRSIZ);
    800033e2:	4639                	li	a2,14
    800033e4:	8556                	mv	a0,s5
    800033e6:	ffffd097          	auipc	ra,0xffffd
    800033ea:	df2080e7          	jalr	-526(ra) # 800001d8 <memmove>
  while(*path == '/')
    800033ee:	0004c783          	lbu	a5,0(s1)
    800033f2:	01279763          	bne	a5,s2,80003400 <namex+0xca>
    path++;
    800033f6:	0485                	addi	s1,s1,1
  while(*path == '/')
    800033f8:	0004c783          	lbu	a5,0(s1)
    800033fc:	ff278de3          	beq	a5,s2,800033f6 <namex+0xc0>
    ilock(ip);
    80003400:	854e                	mv	a0,s3
    80003402:	00000097          	auipc	ra,0x0
    80003406:	9a0080e7          	jalr	-1632(ra) # 80002da2 <ilock>
    if(ip->type != T_DIR){
    8000340a:	04499783          	lh	a5,68(s3)
    8000340e:	f98793e3          	bne	a5,s8,80003394 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003412:	000b0563          	beqz	s6,8000341c <namex+0xe6>
    80003416:	0004c783          	lbu	a5,0(s1)
    8000341a:	d3cd                	beqz	a5,800033bc <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000341c:	865e                	mv	a2,s7
    8000341e:	85d6                	mv	a1,s5
    80003420:	854e                	mv	a0,s3
    80003422:	00000097          	auipc	ra,0x0
    80003426:	e64080e7          	jalr	-412(ra) # 80003286 <dirlookup>
    8000342a:	8a2a                	mv	s4,a0
    8000342c:	dd51                	beqz	a0,800033c8 <namex+0x92>
    iunlockput(ip);
    8000342e:	854e                	mv	a0,s3
    80003430:	00000097          	auipc	ra,0x0
    80003434:	bd4080e7          	jalr	-1068(ra) # 80003004 <iunlockput>
    ip = next;
    80003438:	89d2                	mv	s3,s4
  while(*path == '/')
    8000343a:	0004c783          	lbu	a5,0(s1)
    8000343e:	05279763          	bne	a5,s2,8000348c <namex+0x156>
    path++;
    80003442:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003444:	0004c783          	lbu	a5,0(s1)
    80003448:	ff278de3          	beq	a5,s2,80003442 <namex+0x10c>
  if(*path == 0)
    8000344c:	c79d                	beqz	a5,8000347a <namex+0x144>
    path++;
    8000344e:	85a6                	mv	a1,s1
  len = path - s;
    80003450:	8a5e                	mv	s4,s7
    80003452:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003454:	01278963          	beq	a5,s2,80003466 <namex+0x130>
    80003458:	dfbd                	beqz	a5,800033d6 <namex+0xa0>
    path++;
    8000345a:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    8000345c:	0004c783          	lbu	a5,0(s1)
    80003460:	ff279ce3          	bne	a5,s2,80003458 <namex+0x122>
    80003464:	bf8d                	j	800033d6 <namex+0xa0>
    memmove(name, s, len);
    80003466:	2601                	sext.w	a2,a2
    80003468:	8556                	mv	a0,s5
    8000346a:	ffffd097          	auipc	ra,0xffffd
    8000346e:	d6e080e7          	jalr	-658(ra) # 800001d8 <memmove>
    name[len] = 0;
    80003472:	9a56                	add	s4,s4,s5
    80003474:	000a0023          	sb	zero,0(s4)
    80003478:	bf9d                	j	800033ee <namex+0xb8>
  if(nameiparent){
    8000347a:	f20b03e3          	beqz	s6,800033a0 <namex+0x6a>
    iput(ip);
    8000347e:	854e                	mv	a0,s3
    80003480:	00000097          	auipc	ra,0x0
    80003484:	adc080e7          	jalr	-1316(ra) # 80002f5c <iput>
    return 0;
    80003488:	4981                	li	s3,0
    8000348a:	bf19                	j	800033a0 <namex+0x6a>
  if(*path == 0)
    8000348c:	d7fd                	beqz	a5,8000347a <namex+0x144>
  while(*path != '/' && *path != 0)
    8000348e:	0004c783          	lbu	a5,0(s1)
    80003492:	85a6                	mv	a1,s1
    80003494:	b7d1                	j	80003458 <namex+0x122>

0000000080003496 <dirlink>:
{
    80003496:	7139                	addi	sp,sp,-64
    80003498:	fc06                	sd	ra,56(sp)
    8000349a:	f822                	sd	s0,48(sp)
    8000349c:	f426                	sd	s1,40(sp)
    8000349e:	f04a                	sd	s2,32(sp)
    800034a0:	ec4e                	sd	s3,24(sp)
    800034a2:	e852                	sd	s4,16(sp)
    800034a4:	0080                	addi	s0,sp,64
    800034a6:	892a                	mv	s2,a0
    800034a8:	8a2e                	mv	s4,a1
    800034aa:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800034ac:	4601                	li	a2,0
    800034ae:	00000097          	auipc	ra,0x0
    800034b2:	dd8080e7          	jalr	-552(ra) # 80003286 <dirlookup>
    800034b6:	e93d                	bnez	a0,8000352c <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800034b8:	04c92483          	lw	s1,76(s2)
    800034bc:	c49d                	beqz	s1,800034ea <dirlink+0x54>
    800034be:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800034c0:	4741                	li	a4,16
    800034c2:	86a6                	mv	a3,s1
    800034c4:	fc040613          	addi	a2,s0,-64
    800034c8:	4581                	li	a1,0
    800034ca:	854a                	mv	a0,s2
    800034cc:	00000097          	auipc	ra,0x0
    800034d0:	b8a080e7          	jalr	-1142(ra) # 80003056 <readi>
    800034d4:	47c1                	li	a5,16
    800034d6:	06f51163          	bne	a0,a5,80003538 <dirlink+0xa2>
    if(de.inum == 0)
    800034da:	fc045783          	lhu	a5,-64(s0)
    800034de:	c791                	beqz	a5,800034ea <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800034e0:	24c1                	addiw	s1,s1,16
    800034e2:	04c92783          	lw	a5,76(s2)
    800034e6:	fcf4ede3          	bltu	s1,a5,800034c0 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800034ea:	4639                	li	a2,14
    800034ec:	85d2                	mv	a1,s4
    800034ee:	fc240513          	addi	a0,s0,-62
    800034f2:	ffffd097          	auipc	ra,0xffffd
    800034f6:	d9a080e7          	jalr	-614(ra) # 8000028c <strncpy>
  de.inum = inum;
    800034fa:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800034fe:	4741                	li	a4,16
    80003500:	86a6                	mv	a3,s1
    80003502:	fc040613          	addi	a2,s0,-64
    80003506:	4581                	li	a1,0
    80003508:	854a                	mv	a0,s2
    8000350a:	00000097          	auipc	ra,0x0
    8000350e:	c44080e7          	jalr	-956(ra) # 8000314e <writei>
    80003512:	1541                	addi	a0,a0,-16
    80003514:	00a03533          	snez	a0,a0
    80003518:	40a00533          	neg	a0,a0
}
    8000351c:	70e2                	ld	ra,56(sp)
    8000351e:	7442                	ld	s0,48(sp)
    80003520:	74a2                	ld	s1,40(sp)
    80003522:	7902                	ld	s2,32(sp)
    80003524:	69e2                	ld	s3,24(sp)
    80003526:	6a42                	ld	s4,16(sp)
    80003528:	6121                	addi	sp,sp,64
    8000352a:	8082                	ret
    iput(ip);
    8000352c:	00000097          	auipc	ra,0x0
    80003530:	a30080e7          	jalr	-1488(ra) # 80002f5c <iput>
    return -1;
    80003534:	557d                	li	a0,-1
    80003536:	b7dd                	j	8000351c <dirlink+0x86>
      panic("dirlink read");
    80003538:	00005517          	auipc	a0,0x5
    8000353c:	0d850513          	addi	a0,a0,216 # 80008610 <syscalls+0x210>
    80003540:	00003097          	auipc	ra,0x3
    80003544:	972080e7          	jalr	-1678(ra) # 80005eb2 <panic>

0000000080003548 <namei>:

struct inode*
namei(char *path)
{
    80003548:	1101                	addi	sp,sp,-32
    8000354a:	ec06                	sd	ra,24(sp)
    8000354c:	e822                	sd	s0,16(sp)
    8000354e:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003550:	fe040613          	addi	a2,s0,-32
    80003554:	4581                	li	a1,0
    80003556:	00000097          	auipc	ra,0x0
    8000355a:	de0080e7          	jalr	-544(ra) # 80003336 <namex>
}
    8000355e:	60e2                	ld	ra,24(sp)
    80003560:	6442                	ld	s0,16(sp)
    80003562:	6105                	addi	sp,sp,32
    80003564:	8082                	ret

0000000080003566 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003566:	1141                	addi	sp,sp,-16
    80003568:	e406                	sd	ra,8(sp)
    8000356a:	e022                	sd	s0,0(sp)
    8000356c:	0800                	addi	s0,sp,16
    8000356e:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003570:	4585                	li	a1,1
    80003572:	00000097          	auipc	ra,0x0
    80003576:	dc4080e7          	jalr	-572(ra) # 80003336 <namex>
}
    8000357a:	60a2                	ld	ra,8(sp)
    8000357c:	6402                	ld	s0,0(sp)
    8000357e:	0141                	addi	sp,sp,16
    80003580:	8082                	ret

0000000080003582 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003582:	1101                	addi	sp,sp,-32
    80003584:	ec06                	sd	ra,24(sp)
    80003586:	e822                	sd	s0,16(sp)
    80003588:	e426                	sd	s1,8(sp)
    8000358a:	e04a                	sd	s2,0(sp)
    8000358c:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    8000358e:	00015917          	auipc	s2,0x15
    80003592:	3c290913          	addi	s2,s2,962 # 80018950 <log>
    80003596:	01892583          	lw	a1,24(s2)
    8000359a:	02892503          	lw	a0,40(s2)
    8000359e:	fffff097          	auipc	ra,0xfffff
    800035a2:	fea080e7          	jalr	-22(ra) # 80002588 <bread>
    800035a6:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800035a8:	02c92683          	lw	a3,44(s2)
    800035ac:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800035ae:	02d05763          	blez	a3,800035dc <write_head+0x5a>
    800035b2:	00015797          	auipc	a5,0x15
    800035b6:	3ce78793          	addi	a5,a5,974 # 80018980 <log+0x30>
    800035ba:	05c50713          	addi	a4,a0,92
    800035be:	36fd                	addiw	a3,a3,-1
    800035c0:	1682                	slli	a3,a3,0x20
    800035c2:	9281                	srli	a3,a3,0x20
    800035c4:	068a                	slli	a3,a3,0x2
    800035c6:	00015617          	auipc	a2,0x15
    800035ca:	3be60613          	addi	a2,a2,958 # 80018984 <log+0x34>
    800035ce:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800035d0:	4390                	lw	a2,0(a5)
    800035d2:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800035d4:	0791                	addi	a5,a5,4
    800035d6:	0711                	addi	a4,a4,4
    800035d8:	fed79ce3          	bne	a5,a3,800035d0 <write_head+0x4e>
  }
  bwrite(buf);
    800035dc:	8526                	mv	a0,s1
    800035de:	fffff097          	auipc	ra,0xfffff
    800035e2:	09c080e7          	jalr	156(ra) # 8000267a <bwrite>
  brelse(buf);
    800035e6:	8526                	mv	a0,s1
    800035e8:	fffff097          	auipc	ra,0xfffff
    800035ec:	0d0080e7          	jalr	208(ra) # 800026b8 <brelse>
}
    800035f0:	60e2                	ld	ra,24(sp)
    800035f2:	6442                	ld	s0,16(sp)
    800035f4:	64a2                	ld	s1,8(sp)
    800035f6:	6902                	ld	s2,0(sp)
    800035f8:	6105                	addi	sp,sp,32
    800035fa:	8082                	ret

00000000800035fc <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800035fc:	00015797          	auipc	a5,0x15
    80003600:	3807a783          	lw	a5,896(a5) # 8001897c <log+0x2c>
    80003604:	0af05d63          	blez	a5,800036be <install_trans+0xc2>
{
    80003608:	7139                	addi	sp,sp,-64
    8000360a:	fc06                	sd	ra,56(sp)
    8000360c:	f822                	sd	s0,48(sp)
    8000360e:	f426                	sd	s1,40(sp)
    80003610:	f04a                	sd	s2,32(sp)
    80003612:	ec4e                	sd	s3,24(sp)
    80003614:	e852                	sd	s4,16(sp)
    80003616:	e456                	sd	s5,8(sp)
    80003618:	e05a                	sd	s6,0(sp)
    8000361a:	0080                	addi	s0,sp,64
    8000361c:	8b2a                	mv	s6,a0
    8000361e:	00015a97          	auipc	s5,0x15
    80003622:	362a8a93          	addi	s5,s5,866 # 80018980 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003626:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003628:	00015997          	auipc	s3,0x15
    8000362c:	32898993          	addi	s3,s3,808 # 80018950 <log>
    80003630:	a035                	j	8000365c <install_trans+0x60>
      bunpin(dbuf);
    80003632:	8526                	mv	a0,s1
    80003634:	fffff097          	auipc	ra,0xfffff
    80003638:	15e080e7          	jalr	350(ra) # 80002792 <bunpin>
    brelse(lbuf);
    8000363c:	854a                	mv	a0,s2
    8000363e:	fffff097          	auipc	ra,0xfffff
    80003642:	07a080e7          	jalr	122(ra) # 800026b8 <brelse>
    brelse(dbuf);
    80003646:	8526                	mv	a0,s1
    80003648:	fffff097          	auipc	ra,0xfffff
    8000364c:	070080e7          	jalr	112(ra) # 800026b8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003650:	2a05                	addiw	s4,s4,1
    80003652:	0a91                	addi	s5,s5,4
    80003654:	02c9a783          	lw	a5,44(s3)
    80003658:	04fa5963          	bge	s4,a5,800036aa <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000365c:	0189a583          	lw	a1,24(s3)
    80003660:	014585bb          	addw	a1,a1,s4
    80003664:	2585                	addiw	a1,a1,1
    80003666:	0289a503          	lw	a0,40(s3)
    8000366a:	fffff097          	auipc	ra,0xfffff
    8000366e:	f1e080e7          	jalr	-226(ra) # 80002588 <bread>
    80003672:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003674:	000aa583          	lw	a1,0(s5)
    80003678:	0289a503          	lw	a0,40(s3)
    8000367c:	fffff097          	auipc	ra,0xfffff
    80003680:	f0c080e7          	jalr	-244(ra) # 80002588 <bread>
    80003684:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003686:	40000613          	li	a2,1024
    8000368a:	05890593          	addi	a1,s2,88
    8000368e:	05850513          	addi	a0,a0,88
    80003692:	ffffd097          	auipc	ra,0xffffd
    80003696:	b46080e7          	jalr	-1210(ra) # 800001d8 <memmove>
    bwrite(dbuf);  // write dst to disk
    8000369a:	8526                	mv	a0,s1
    8000369c:	fffff097          	auipc	ra,0xfffff
    800036a0:	fde080e7          	jalr	-34(ra) # 8000267a <bwrite>
    if(recovering == 0)
    800036a4:	f80b1ce3          	bnez	s6,8000363c <install_trans+0x40>
    800036a8:	b769                	j	80003632 <install_trans+0x36>
}
    800036aa:	70e2                	ld	ra,56(sp)
    800036ac:	7442                	ld	s0,48(sp)
    800036ae:	74a2                	ld	s1,40(sp)
    800036b0:	7902                	ld	s2,32(sp)
    800036b2:	69e2                	ld	s3,24(sp)
    800036b4:	6a42                	ld	s4,16(sp)
    800036b6:	6aa2                	ld	s5,8(sp)
    800036b8:	6b02                	ld	s6,0(sp)
    800036ba:	6121                	addi	sp,sp,64
    800036bc:	8082                	ret
    800036be:	8082                	ret

00000000800036c0 <initlog>:
{
    800036c0:	7179                	addi	sp,sp,-48
    800036c2:	f406                	sd	ra,40(sp)
    800036c4:	f022                	sd	s0,32(sp)
    800036c6:	ec26                	sd	s1,24(sp)
    800036c8:	e84a                	sd	s2,16(sp)
    800036ca:	e44e                	sd	s3,8(sp)
    800036cc:	1800                	addi	s0,sp,48
    800036ce:	892a                	mv	s2,a0
    800036d0:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800036d2:	00015497          	auipc	s1,0x15
    800036d6:	27e48493          	addi	s1,s1,638 # 80018950 <log>
    800036da:	00005597          	auipc	a1,0x5
    800036de:	f4658593          	addi	a1,a1,-186 # 80008620 <syscalls+0x220>
    800036e2:	8526                	mv	a0,s1
    800036e4:	00003097          	auipc	ra,0x3
    800036e8:	c88080e7          	jalr	-888(ra) # 8000636c <initlock>
  log.start = sb->logstart;
    800036ec:	0149a583          	lw	a1,20(s3)
    800036f0:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800036f2:	0109a783          	lw	a5,16(s3)
    800036f6:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800036f8:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800036fc:	854a                	mv	a0,s2
    800036fe:	fffff097          	auipc	ra,0xfffff
    80003702:	e8a080e7          	jalr	-374(ra) # 80002588 <bread>
  log.lh.n = lh->n;
    80003706:	4d3c                	lw	a5,88(a0)
    80003708:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000370a:	02f05563          	blez	a5,80003734 <initlog+0x74>
    8000370e:	05c50713          	addi	a4,a0,92
    80003712:	00015697          	auipc	a3,0x15
    80003716:	26e68693          	addi	a3,a3,622 # 80018980 <log+0x30>
    8000371a:	37fd                	addiw	a5,a5,-1
    8000371c:	1782                	slli	a5,a5,0x20
    8000371e:	9381                	srli	a5,a5,0x20
    80003720:	078a                	slli	a5,a5,0x2
    80003722:	06050613          	addi	a2,a0,96
    80003726:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    80003728:	4310                	lw	a2,0(a4)
    8000372a:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    8000372c:	0711                	addi	a4,a4,4
    8000372e:	0691                	addi	a3,a3,4
    80003730:	fef71ce3          	bne	a4,a5,80003728 <initlog+0x68>
  brelse(buf);
    80003734:	fffff097          	auipc	ra,0xfffff
    80003738:	f84080e7          	jalr	-124(ra) # 800026b8 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000373c:	4505                	li	a0,1
    8000373e:	00000097          	auipc	ra,0x0
    80003742:	ebe080e7          	jalr	-322(ra) # 800035fc <install_trans>
  log.lh.n = 0;
    80003746:	00015797          	auipc	a5,0x15
    8000374a:	2207ab23          	sw	zero,566(a5) # 8001897c <log+0x2c>
  write_head(); // clear the log
    8000374e:	00000097          	auipc	ra,0x0
    80003752:	e34080e7          	jalr	-460(ra) # 80003582 <write_head>
}
    80003756:	70a2                	ld	ra,40(sp)
    80003758:	7402                	ld	s0,32(sp)
    8000375a:	64e2                	ld	s1,24(sp)
    8000375c:	6942                	ld	s2,16(sp)
    8000375e:	69a2                	ld	s3,8(sp)
    80003760:	6145                	addi	sp,sp,48
    80003762:	8082                	ret

0000000080003764 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003764:	1101                	addi	sp,sp,-32
    80003766:	ec06                	sd	ra,24(sp)
    80003768:	e822                	sd	s0,16(sp)
    8000376a:	e426                	sd	s1,8(sp)
    8000376c:	e04a                	sd	s2,0(sp)
    8000376e:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003770:	00015517          	auipc	a0,0x15
    80003774:	1e050513          	addi	a0,a0,480 # 80018950 <log>
    80003778:	00003097          	auipc	ra,0x3
    8000377c:	c84080e7          	jalr	-892(ra) # 800063fc <acquire>
  while(1){
    if(log.committing){
    80003780:	00015497          	auipc	s1,0x15
    80003784:	1d048493          	addi	s1,s1,464 # 80018950 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003788:	4979                	li	s2,30
    8000378a:	a039                	j	80003798 <begin_op+0x34>
      sleep(&log, &log.lock);
    8000378c:	85a6                	mv	a1,s1
    8000378e:	8526                	mv	a0,s1
    80003790:	ffffe097          	auipc	ra,0xffffe
    80003794:	f4e080e7          	jalr	-178(ra) # 800016de <sleep>
    if(log.committing){
    80003798:	50dc                	lw	a5,36(s1)
    8000379a:	fbed                	bnez	a5,8000378c <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000379c:	509c                	lw	a5,32(s1)
    8000379e:	0017871b          	addiw	a4,a5,1
    800037a2:	0007069b          	sext.w	a3,a4
    800037a6:	0027179b          	slliw	a5,a4,0x2
    800037aa:	9fb9                	addw	a5,a5,a4
    800037ac:	0017979b          	slliw	a5,a5,0x1
    800037b0:	54d8                	lw	a4,44(s1)
    800037b2:	9fb9                	addw	a5,a5,a4
    800037b4:	00f95963          	bge	s2,a5,800037c6 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800037b8:	85a6                	mv	a1,s1
    800037ba:	8526                	mv	a0,s1
    800037bc:	ffffe097          	auipc	ra,0xffffe
    800037c0:	f22080e7          	jalr	-222(ra) # 800016de <sleep>
    800037c4:	bfd1                	j	80003798 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800037c6:	00015517          	auipc	a0,0x15
    800037ca:	18a50513          	addi	a0,a0,394 # 80018950 <log>
    800037ce:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800037d0:	00003097          	auipc	ra,0x3
    800037d4:	ce0080e7          	jalr	-800(ra) # 800064b0 <release>
      break;
    }
  }
}
    800037d8:	60e2                	ld	ra,24(sp)
    800037da:	6442                	ld	s0,16(sp)
    800037dc:	64a2                	ld	s1,8(sp)
    800037de:	6902                	ld	s2,0(sp)
    800037e0:	6105                	addi	sp,sp,32
    800037e2:	8082                	ret

00000000800037e4 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800037e4:	7139                	addi	sp,sp,-64
    800037e6:	fc06                	sd	ra,56(sp)
    800037e8:	f822                	sd	s0,48(sp)
    800037ea:	f426                	sd	s1,40(sp)
    800037ec:	f04a                	sd	s2,32(sp)
    800037ee:	ec4e                	sd	s3,24(sp)
    800037f0:	e852                	sd	s4,16(sp)
    800037f2:	e456                	sd	s5,8(sp)
    800037f4:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800037f6:	00015497          	auipc	s1,0x15
    800037fa:	15a48493          	addi	s1,s1,346 # 80018950 <log>
    800037fe:	8526                	mv	a0,s1
    80003800:	00003097          	auipc	ra,0x3
    80003804:	bfc080e7          	jalr	-1028(ra) # 800063fc <acquire>
  log.outstanding -= 1;
    80003808:	509c                	lw	a5,32(s1)
    8000380a:	37fd                	addiw	a5,a5,-1
    8000380c:	0007891b          	sext.w	s2,a5
    80003810:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80003812:	50dc                	lw	a5,36(s1)
    80003814:	efb9                	bnez	a5,80003872 <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    80003816:	06091663          	bnez	s2,80003882 <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    8000381a:	00015497          	auipc	s1,0x15
    8000381e:	13648493          	addi	s1,s1,310 # 80018950 <log>
    80003822:	4785                	li	a5,1
    80003824:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003826:	8526                	mv	a0,s1
    80003828:	00003097          	auipc	ra,0x3
    8000382c:	c88080e7          	jalr	-888(ra) # 800064b0 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003830:	54dc                	lw	a5,44(s1)
    80003832:	06f04763          	bgtz	a5,800038a0 <end_op+0xbc>
    acquire(&log.lock);
    80003836:	00015497          	auipc	s1,0x15
    8000383a:	11a48493          	addi	s1,s1,282 # 80018950 <log>
    8000383e:	8526                	mv	a0,s1
    80003840:	00003097          	auipc	ra,0x3
    80003844:	bbc080e7          	jalr	-1092(ra) # 800063fc <acquire>
    log.committing = 0;
    80003848:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000384c:	8526                	mv	a0,s1
    8000384e:	ffffe097          	auipc	ra,0xffffe
    80003852:	ef4080e7          	jalr	-268(ra) # 80001742 <wakeup>
    release(&log.lock);
    80003856:	8526                	mv	a0,s1
    80003858:	00003097          	auipc	ra,0x3
    8000385c:	c58080e7          	jalr	-936(ra) # 800064b0 <release>
}
    80003860:	70e2                	ld	ra,56(sp)
    80003862:	7442                	ld	s0,48(sp)
    80003864:	74a2                	ld	s1,40(sp)
    80003866:	7902                	ld	s2,32(sp)
    80003868:	69e2                	ld	s3,24(sp)
    8000386a:	6a42                	ld	s4,16(sp)
    8000386c:	6aa2                	ld	s5,8(sp)
    8000386e:	6121                	addi	sp,sp,64
    80003870:	8082                	ret
    panic("log.committing");
    80003872:	00005517          	auipc	a0,0x5
    80003876:	db650513          	addi	a0,a0,-586 # 80008628 <syscalls+0x228>
    8000387a:	00002097          	auipc	ra,0x2
    8000387e:	638080e7          	jalr	1592(ra) # 80005eb2 <panic>
    wakeup(&log);
    80003882:	00015497          	auipc	s1,0x15
    80003886:	0ce48493          	addi	s1,s1,206 # 80018950 <log>
    8000388a:	8526                	mv	a0,s1
    8000388c:	ffffe097          	auipc	ra,0xffffe
    80003890:	eb6080e7          	jalr	-330(ra) # 80001742 <wakeup>
  release(&log.lock);
    80003894:	8526                	mv	a0,s1
    80003896:	00003097          	auipc	ra,0x3
    8000389a:	c1a080e7          	jalr	-998(ra) # 800064b0 <release>
  if(do_commit){
    8000389e:	b7c9                	j	80003860 <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    800038a0:	00015a97          	auipc	s5,0x15
    800038a4:	0e0a8a93          	addi	s5,s5,224 # 80018980 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800038a8:	00015a17          	auipc	s4,0x15
    800038ac:	0a8a0a13          	addi	s4,s4,168 # 80018950 <log>
    800038b0:	018a2583          	lw	a1,24(s4)
    800038b4:	012585bb          	addw	a1,a1,s2
    800038b8:	2585                	addiw	a1,a1,1
    800038ba:	028a2503          	lw	a0,40(s4)
    800038be:	fffff097          	auipc	ra,0xfffff
    800038c2:	cca080e7          	jalr	-822(ra) # 80002588 <bread>
    800038c6:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800038c8:	000aa583          	lw	a1,0(s5)
    800038cc:	028a2503          	lw	a0,40(s4)
    800038d0:	fffff097          	auipc	ra,0xfffff
    800038d4:	cb8080e7          	jalr	-840(ra) # 80002588 <bread>
    800038d8:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800038da:	40000613          	li	a2,1024
    800038de:	05850593          	addi	a1,a0,88
    800038e2:	05848513          	addi	a0,s1,88
    800038e6:	ffffd097          	auipc	ra,0xffffd
    800038ea:	8f2080e7          	jalr	-1806(ra) # 800001d8 <memmove>
    bwrite(to);  // write the log
    800038ee:	8526                	mv	a0,s1
    800038f0:	fffff097          	auipc	ra,0xfffff
    800038f4:	d8a080e7          	jalr	-630(ra) # 8000267a <bwrite>
    brelse(from);
    800038f8:	854e                	mv	a0,s3
    800038fa:	fffff097          	auipc	ra,0xfffff
    800038fe:	dbe080e7          	jalr	-578(ra) # 800026b8 <brelse>
    brelse(to);
    80003902:	8526                	mv	a0,s1
    80003904:	fffff097          	auipc	ra,0xfffff
    80003908:	db4080e7          	jalr	-588(ra) # 800026b8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000390c:	2905                	addiw	s2,s2,1
    8000390e:	0a91                	addi	s5,s5,4
    80003910:	02ca2783          	lw	a5,44(s4)
    80003914:	f8f94ee3          	blt	s2,a5,800038b0 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003918:	00000097          	auipc	ra,0x0
    8000391c:	c6a080e7          	jalr	-918(ra) # 80003582 <write_head>
    install_trans(0); // Now install writes to home locations
    80003920:	4501                	li	a0,0
    80003922:	00000097          	auipc	ra,0x0
    80003926:	cda080e7          	jalr	-806(ra) # 800035fc <install_trans>
    log.lh.n = 0;
    8000392a:	00015797          	auipc	a5,0x15
    8000392e:	0407a923          	sw	zero,82(a5) # 8001897c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80003932:	00000097          	auipc	ra,0x0
    80003936:	c50080e7          	jalr	-944(ra) # 80003582 <write_head>
    8000393a:	bdf5                	j	80003836 <end_op+0x52>

000000008000393c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000393c:	1101                	addi	sp,sp,-32
    8000393e:	ec06                	sd	ra,24(sp)
    80003940:	e822                	sd	s0,16(sp)
    80003942:	e426                	sd	s1,8(sp)
    80003944:	e04a                	sd	s2,0(sp)
    80003946:	1000                	addi	s0,sp,32
    80003948:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000394a:	00015917          	auipc	s2,0x15
    8000394e:	00690913          	addi	s2,s2,6 # 80018950 <log>
    80003952:	854a                	mv	a0,s2
    80003954:	00003097          	auipc	ra,0x3
    80003958:	aa8080e7          	jalr	-1368(ra) # 800063fc <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000395c:	02c92603          	lw	a2,44(s2)
    80003960:	47f5                	li	a5,29
    80003962:	06c7c563          	blt	a5,a2,800039cc <log_write+0x90>
    80003966:	00015797          	auipc	a5,0x15
    8000396a:	0067a783          	lw	a5,6(a5) # 8001896c <log+0x1c>
    8000396e:	37fd                	addiw	a5,a5,-1
    80003970:	04f65e63          	bge	a2,a5,800039cc <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003974:	00015797          	auipc	a5,0x15
    80003978:	ffc7a783          	lw	a5,-4(a5) # 80018970 <log+0x20>
    8000397c:	06f05063          	blez	a5,800039dc <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003980:	4781                	li	a5,0
    80003982:	06c05563          	blez	a2,800039ec <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003986:	44cc                	lw	a1,12(s1)
    80003988:	00015717          	auipc	a4,0x15
    8000398c:	ff870713          	addi	a4,a4,-8 # 80018980 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003990:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003992:	4314                	lw	a3,0(a4)
    80003994:	04b68c63          	beq	a3,a1,800039ec <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80003998:	2785                	addiw	a5,a5,1
    8000399a:	0711                	addi	a4,a4,4
    8000399c:	fef61be3          	bne	a2,a5,80003992 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800039a0:	0621                	addi	a2,a2,8
    800039a2:	060a                	slli	a2,a2,0x2
    800039a4:	00015797          	auipc	a5,0x15
    800039a8:	fac78793          	addi	a5,a5,-84 # 80018950 <log>
    800039ac:	963e                	add	a2,a2,a5
    800039ae:	44dc                	lw	a5,12(s1)
    800039b0:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800039b2:	8526                	mv	a0,s1
    800039b4:	fffff097          	auipc	ra,0xfffff
    800039b8:	da2080e7          	jalr	-606(ra) # 80002756 <bpin>
    log.lh.n++;
    800039bc:	00015717          	auipc	a4,0x15
    800039c0:	f9470713          	addi	a4,a4,-108 # 80018950 <log>
    800039c4:	575c                	lw	a5,44(a4)
    800039c6:	2785                	addiw	a5,a5,1
    800039c8:	d75c                	sw	a5,44(a4)
    800039ca:	a835                	j	80003a06 <log_write+0xca>
    panic("too big a transaction");
    800039cc:	00005517          	auipc	a0,0x5
    800039d0:	c6c50513          	addi	a0,a0,-916 # 80008638 <syscalls+0x238>
    800039d4:	00002097          	auipc	ra,0x2
    800039d8:	4de080e7          	jalr	1246(ra) # 80005eb2 <panic>
    panic("log_write outside of trans");
    800039dc:	00005517          	auipc	a0,0x5
    800039e0:	c7450513          	addi	a0,a0,-908 # 80008650 <syscalls+0x250>
    800039e4:	00002097          	auipc	ra,0x2
    800039e8:	4ce080e7          	jalr	1230(ra) # 80005eb2 <panic>
  log.lh.block[i] = b->blockno;
    800039ec:	00878713          	addi	a4,a5,8
    800039f0:	00271693          	slli	a3,a4,0x2
    800039f4:	00015717          	auipc	a4,0x15
    800039f8:	f5c70713          	addi	a4,a4,-164 # 80018950 <log>
    800039fc:	9736                	add	a4,a4,a3
    800039fe:	44d4                	lw	a3,12(s1)
    80003a00:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003a02:	faf608e3          	beq	a2,a5,800039b2 <log_write+0x76>
  }
  release(&log.lock);
    80003a06:	00015517          	auipc	a0,0x15
    80003a0a:	f4a50513          	addi	a0,a0,-182 # 80018950 <log>
    80003a0e:	00003097          	auipc	ra,0x3
    80003a12:	aa2080e7          	jalr	-1374(ra) # 800064b0 <release>
}
    80003a16:	60e2                	ld	ra,24(sp)
    80003a18:	6442                	ld	s0,16(sp)
    80003a1a:	64a2                	ld	s1,8(sp)
    80003a1c:	6902                	ld	s2,0(sp)
    80003a1e:	6105                	addi	sp,sp,32
    80003a20:	8082                	ret

0000000080003a22 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003a22:	1101                	addi	sp,sp,-32
    80003a24:	ec06                	sd	ra,24(sp)
    80003a26:	e822                	sd	s0,16(sp)
    80003a28:	e426                	sd	s1,8(sp)
    80003a2a:	e04a                	sd	s2,0(sp)
    80003a2c:	1000                	addi	s0,sp,32
    80003a2e:	84aa                	mv	s1,a0
    80003a30:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003a32:	00005597          	auipc	a1,0x5
    80003a36:	c3e58593          	addi	a1,a1,-962 # 80008670 <syscalls+0x270>
    80003a3a:	0521                	addi	a0,a0,8
    80003a3c:	00003097          	auipc	ra,0x3
    80003a40:	930080e7          	jalr	-1744(ra) # 8000636c <initlock>
  lk->name = name;
    80003a44:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003a48:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003a4c:	0204a423          	sw	zero,40(s1)
}
    80003a50:	60e2                	ld	ra,24(sp)
    80003a52:	6442                	ld	s0,16(sp)
    80003a54:	64a2                	ld	s1,8(sp)
    80003a56:	6902                	ld	s2,0(sp)
    80003a58:	6105                	addi	sp,sp,32
    80003a5a:	8082                	ret

0000000080003a5c <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003a5c:	1101                	addi	sp,sp,-32
    80003a5e:	ec06                	sd	ra,24(sp)
    80003a60:	e822                	sd	s0,16(sp)
    80003a62:	e426                	sd	s1,8(sp)
    80003a64:	e04a                	sd	s2,0(sp)
    80003a66:	1000                	addi	s0,sp,32
    80003a68:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003a6a:	00850913          	addi	s2,a0,8
    80003a6e:	854a                	mv	a0,s2
    80003a70:	00003097          	auipc	ra,0x3
    80003a74:	98c080e7          	jalr	-1652(ra) # 800063fc <acquire>
  while (lk->locked) {
    80003a78:	409c                	lw	a5,0(s1)
    80003a7a:	cb89                	beqz	a5,80003a8c <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80003a7c:	85ca                	mv	a1,s2
    80003a7e:	8526                	mv	a0,s1
    80003a80:	ffffe097          	auipc	ra,0xffffe
    80003a84:	c5e080e7          	jalr	-930(ra) # 800016de <sleep>
  while (lk->locked) {
    80003a88:	409c                	lw	a5,0(s1)
    80003a8a:	fbed                	bnez	a5,80003a7c <acquiresleep+0x20>
  }
  lk->locked = 1;
    80003a8c:	4785                	li	a5,1
    80003a8e:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003a90:	ffffd097          	auipc	ra,0xffffd
    80003a94:	4a4080e7          	jalr	1188(ra) # 80000f34 <myproc>
    80003a98:	591c                	lw	a5,48(a0)
    80003a9a:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003a9c:	854a                	mv	a0,s2
    80003a9e:	00003097          	auipc	ra,0x3
    80003aa2:	a12080e7          	jalr	-1518(ra) # 800064b0 <release>
}
    80003aa6:	60e2                	ld	ra,24(sp)
    80003aa8:	6442                	ld	s0,16(sp)
    80003aaa:	64a2                	ld	s1,8(sp)
    80003aac:	6902                	ld	s2,0(sp)
    80003aae:	6105                	addi	sp,sp,32
    80003ab0:	8082                	ret

0000000080003ab2 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003ab2:	1101                	addi	sp,sp,-32
    80003ab4:	ec06                	sd	ra,24(sp)
    80003ab6:	e822                	sd	s0,16(sp)
    80003ab8:	e426                	sd	s1,8(sp)
    80003aba:	e04a                	sd	s2,0(sp)
    80003abc:	1000                	addi	s0,sp,32
    80003abe:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003ac0:	00850913          	addi	s2,a0,8
    80003ac4:	854a                	mv	a0,s2
    80003ac6:	00003097          	auipc	ra,0x3
    80003aca:	936080e7          	jalr	-1738(ra) # 800063fc <acquire>
  lk->locked = 0;
    80003ace:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003ad2:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003ad6:	8526                	mv	a0,s1
    80003ad8:	ffffe097          	auipc	ra,0xffffe
    80003adc:	c6a080e7          	jalr	-918(ra) # 80001742 <wakeup>
  release(&lk->lk);
    80003ae0:	854a                	mv	a0,s2
    80003ae2:	00003097          	auipc	ra,0x3
    80003ae6:	9ce080e7          	jalr	-1586(ra) # 800064b0 <release>
}
    80003aea:	60e2                	ld	ra,24(sp)
    80003aec:	6442                	ld	s0,16(sp)
    80003aee:	64a2                	ld	s1,8(sp)
    80003af0:	6902                	ld	s2,0(sp)
    80003af2:	6105                	addi	sp,sp,32
    80003af4:	8082                	ret

0000000080003af6 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003af6:	7179                	addi	sp,sp,-48
    80003af8:	f406                	sd	ra,40(sp)
    80003afa:	f022                	sd	s0,32(sp)
    80003afc:	ec26                	sd	s1,24(sp)
    80003afe:	e84a                	sd	s2,16(sp)
    80003b00:	e44e                	sd	s3,8(sp)
    80003b02:	1800                	addi	s0,sp,48
    80003b04:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003b06:	00850913          	addi	s2,a0,8
    80003b0a:	854a                	mv	a0,s2
    80003b0c:	00003097          	auipc	ra,0x3
    80003b10:	8f0080e7          	jalr	-1808(ra) # 800063fc <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003b14:	409c                	lw	a5,0(s1)
    80003b16:	ef99                	bnez	a5,80003b34 <holdingsleep+0x3e>
    80003b18:	4481                	li	s1,0
  release(&lk->lk);
    80003b1a:	854a                	mv	a0,s2
    80003b1c:	00003097          	auipc	ra,0x3
    80003b20:	994080e7          	jalr	-1644(ra) # 800064b0 <release>
  return r;
}
    80003b24:	8526                	mv	a0,s1
    80003b26:	70a2                	ld	ra,40(sp)
    80003b28:	7402                	ld	s0,32(sp)
    80003b2a:	64e2                	ld	s1,24(sp)
    80003b2c:	6942                	ld	s2,16(sp)
    80003b2e:	69a2                	ld	s3,8(sp)
    80003b30:	6145                	addi	sp,sp,48
    80003b32:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80003b34:	0284a983          	lw	s3,40(s1)
    80003b38:	ffffd097          	auipc	ra,0xffffd
    80003b3c:	3fc080e7          	jalr	1020(ra) # 80000f34 <myproc>
    80003b40:	5904                	lw	s1,48(a0)
    80003b42:	413484b3          	sub	s1,s1,s3
    80003b46:	0014b493          	seqz	s1,s1
    80003b4a:	bfc1                	j	80003b1a <holdingsleep+0x24>

0000000080003b4c <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80003b4c:	1141                	addi	sp,sp,-16
    80003b4e:	e406                	sd	ra,8(sp)
    80003b50:	e022                	sd	s0,0(sp)
    80003b52:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80003b54:	00005597          	auipc	a1,0x5
    80003b58:	b2c58593          	addi	a1,a1,-1236 # 80008680 <syscalls+0x280>
    80003b5c:	00015517          	auipc	a0,0x15
    80003b60:	f3c50513          	addi	a0,a0,-196 # 80018a98 <ftable>
    80003b64:	00003097          	auipc	ra,0x3
    80003b68:	808080e7          	jalr	-2040(ra) # 8000636c <initlock>
}
    80003b6c:	60a2                	ld	ra,8(sp)
    80003b6e:	6402                	ld	s0,0(sp)
    80003b70:	0141                	addi	sp,sp,16
    80003b72:	8082                	ret

0000000080003b74 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80003b74:	1101                	addi	sp,sp,-32
    80003b76:	ec06                	sd	ra,24(sp)
    80003b78:	e822                	sd	s0,16(sp)
    80003b7a:	e426                	sd	s1,8(sp)
    80003b7c:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80003b7e:	00015517          	auipc	a0,0x15
    80003b82:	f1a50513          	addi	a0,a0,-230 # 80018a98 <ftable>
    80003b86:	00003097          	auipc	ra,0x3
    80003b8a:	876080e7          	jalr	-1930(ra) # 800063fc <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003b8e:	00015497          	auipc	s1,0x15
    80003b92:	f2248493          	addi	s1,s1,-222 # 80018ab0 <ftable+0x18>
    80003b96:	00016717          	auipc	a4,0x16
    80003b9a:	eba70713          	addi	a4,a4,-326 # 80019a50 <disk>
    if(f->ref == 0){
    80003b9e:	40dc                	lw	a5,4(s1)
    80003ba0:	cf99                	beqz	a5,80003bbe <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003ba2:	02848493          	addi	s1,s1,40
    80003ba6:	fee49ce3          	bne	s1,a4,80003b9e <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80003baa:	00015517          	auipc	a0,0x15
    80003bae:	eee50513          	addi	a0,a0,-274 # 80018a98 <ftable>
    80003bb2:	00003097          	auipc	ra,0x3
    80003bb6:	8fe080e7          	jalr	-1794(ra) # 800064b0 <release>
  return 0;
    80003bba:	4481                	li	s1,0
    80003bbc:	a819                	j	80003bd2 <filealloc+0x5e>
      f->ref = 1;
    80003bbe:	4785                	li	a5,1
    80003bc0:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80003bc2:	00015517          	auipc	a0,0x15
    80003bc6:	ed650513          	addi	a0,a0,-298 # 80018a98 <ftable>
    80003bca:	00003097          	auipc	ra,0x3
    80003bce:	8e6080e7          	jalr	-1818(ra) # 800064b0 <release>
}
    80003bd2:	8526                	mv	a0,s1
    80003bd4:	60e2                	ld	ra,24(sp)
    80003bd6:	6442                	ld	s0,16(sp)
    80003bd8:	64a2                	ld	s1,8(sp)
    80003bda:	6105                	addi	sp,sp,32
    80003bdc:	8082                	ret

0000000080003bde <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80003bde:	1101                	addi	sp,sp,-32
    80003be0:	ec06                	sd	ra,24(sp)
    80003be2:	e822                	sd	s0,16(sp)
    80003be4:	e426                	sd	s1,8(sp)
    80003be6:	1000                	addi	s0,sp,32
    80003be8:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003bea:	00015517          	auipc	a0,0x15
    80003bee:	eae50513          	addi	a0,a0,-338 # 80018a98 <ftable>
    80003bf2:	00003097          	auipc	ra,0x3
    80003bf6:	80a080e7          	jalr	-2038(ra) # 800063fc <acquire>
  if(f->ref < 1)
    80003bfa:	40dc                	lw	a5,4(s1)
    80003bfc:	02f05263          	blez	a5,80003c20 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80003c00:	2785                	addiw	a5,a5,1
    80003c02:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003c04:	00015517          	auipc	a0,0x15
    80003c08:	e9450513          	addi	a0,a0,-364 # 80018a98 <ftable>
    80003c0c:	00003097          	auipc	ra,0x3
    80003c10:	8a4080e7          	jalr	-1884(ra) # 800064b0 <release>
  return f;
}
    80003c14:	8526                	mv	a0,s1
    80003c16:	60e2                	ld	ra,24(sp)
    80003c18:	6442                	ld	s0,16(sp)
    80003c1a:	64a2                	ld	s1,8(sp)
    80003c1c:	6105                	addi	sp,sp,32
    80003c1e:	8082                	ret
    panic("filedup");
    80003c20:	00005517          	auipc	a0,0x5
    80003c24:	a6850513          	addi	a0,a0,-1432 # 80008688 <syscalls+0x288>
    80003c28:	00002097          	auipc	ra,0x2
    80003c2c:	28a080e7          	jalr	650(ra) # 80005eb2 <panic>

0000000080003c30 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80003c30:	7139                	addi	sp,sp,-64
    80003c32:	fc06                	sd	ra,56(sp)
    80003c34:	f822                	sd	s0,48(sp)
    80003c36:	f426                	sd	s1,40(sp)
    80003c38:	f04a                	sd	s2,32(sp)
    80003c3a:	ec4e                	sd	s3,24(sp)
    80003c3c:	e852                	sd	s4,16(sp)
    80003c3e:	e456                	sd	s5,8(sp)
    80003c40:	0080                	addi	s0,sp,64
    80003c42:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80003c44:	00015517          	auipc	a0,0x15
    80003c48:	e5450513          	addi	a0,a0,-428 # 80018a98 <ftable>
    80003c4c:	00002097          	auipc	ra,0x2
    80003c50:	7b0080e7          	jalr	1968(ra) # 800063fc <acquire>
  if(f->ref < 1)
    80003c54:	40dc                	lw	a5,4(s1)
    80003c56:	06f05163          	blez	a5,80003cb8 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80003c5a:	37fd                	addiw	a5,a5,-1
    80003c5c:	0007871b          	sext.w	a4,a5
    80003c60:	c0dc                	sw	a5,4(s1)
    80003c62:	06e04363          	bgtz	a4,80003cc8 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80003c66:	0004a903          	lw	s2,0(s1)
    80003c6a:	0094ca83          	lbu	s5,9(s1)
    80003c6e:	0104ba03          	ld	s4,16(s1)
    80003c72:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80003c76:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80003c7a:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80003c7e:	00015517          	auipc	a0,0x15
    80003c82:	e1a50513          	addi	a0,a0,-486 # 80018a98 <ftable>
    80003c86:	00003097          	auipc	ra,0x3
    80003c8a:	82a080e7          	jalr	-2006(ra) # 800064b0 <release>

  if(ff.type == FD_PIPE){
    80003c8e:	4785                	li	a5,1
    80003c90:	04f90d63          	beq	s2,a5,80003cea <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80003c94:	3979                	addiw	s2,s2,-2
    80003c96:	4785                	li	a5,1
    80003c98:	0527e063          	bltu	a5,s2,80003cd8 <fileclose+0xa8>
    begin_op();
    80003c9c:	00000097          	auipc	ra,0x0
    80003ca0:	ac8080e7          	jalr	-1336(ra) # 80003764 <begin_op>
    iput(ff.ip);
    80003ca4:	854e                	mv	a0,s3
    80003ca6:	fffff097          	auipc	ra,0xfffff
    80003caa:	2b6080e7          	jalr	694(ra) # 80002f5c <iput>
    end_op();
    80003cae:	00000097          	auipc	ra,0x0
    80003cb2:	b36080e7          	jalr	-1226(ra) # 800037e4 <end_op>
    80003cb6:	a00d                	j	80003cd8 <fileclose+0xa8>
    panic("fileclose");
    80003cb8:	00005517          	auipc	a0,0x5
    80003cbc:	9d850513          	addi	a0,a0,-1576 # 80008690 <syscalls+0x290>
    80003cc0:	00002097          	auipc	ra,0x2
    80003cc4:	1f2080e7          	jalr	498(ra) # 80005eb2 <panic>
    release(&ftable.lock);
    80003cc8:	00015517          	auipc	a0,0x15
    80003ccc:	dd050513          	addi	a0,a0,-560 # 80018a98 <ftable>
    80003cd0:	00002097          	auipc	ra,0x2
    80003cd4:	7e0080e7          	jalr	2016(ra) # 800064b0 <release>
  }
}
    80003cd8:	70e2                	ld	ra,56(sp)
    80003cda:	7442                	ld	s0,48(sp)
    80003cdc:	74a2                	ld	s1,40(sp)
    80003cde:	7902                	ld	s2,32(sp)
    80003ce0:	69e2                	ld	s3,24(sp)
    80003ce2:	6a42                	ld	s4,16(sp)
    80003ce4:	6aa2                	ld	s5,8(sp)
    80003ce6:	6121                	addi	sp,sp,64
    80003ce8:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80003cea:	85d6                	mv	a1,s5
    80003cec:	8552                	mv	a0,s4
    80003cee:	00000097          	auipc	ra,0x0
    80003cf2:	34c080e7          	jalr	844(ra) # 8000403a <pipeclose>
    80003cf6:	b7cd                	j	80003cd8 <fileclose+0xa8>

0000000080003cf8 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80003cf8:	715d                	addi	sp,sp,-80
    80003cfa:	e486                	sd	ra,72(sp)
    80003cfc:	e0a2                	sd	s0,64(sp)
    80003cfe:	fc26                	sd	s1,56(sp)
    80003d00:	f84a                	sd	s2,48(sp)
    80003d02:	f44e                	sd	s3,40(sp)
    80003d04:	0880                	addi	s0,sp,80
    80003d06:	84aa                	mv	s1,a0
    80003d08:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80003d0a:	ffffd097          	auipc	ra,0xffffd
    80003d0e:	22a080e7          	jalr	554(ra) # 80000f34 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80003d12:	409c                	lw	a5,0(s1)
    80003d14:	37f9                	addiw	a5,a5,-2
    80003d16:	4705                	li	a4,1
    80003d18:	04f76763          	bltu	a4,a5,80003d66 <filestat+0x6e>
    80003d1c:	892a                	mv	s2,a0
    ilock(f->ip);
    80003d1e:	6c88                	ld	a0,24(s1)
    80003d20:	fffff097          	auipc	ra,0xfffff
    80003d24:	082080e7          	jalr	130(ra) # 80002da2 <ilock>
    stati(f->ip, &st);
    80003d28:	fb840593          	addi	a1,s0,-72
    80003d2c:	6c88                	ld	a0,24(s1)
    80003d2e:	fffff097          	auipc	ra,0xfffff
    80003d32:	2fe080e7          	jalr	766(ra) # 8000302c <stati>
    iunlock(f->ip);
    80003d36:	6c88                	ld	a0,24(s1)
    80003d38:	fffff097          	auipc	ra,0xfffff
    80003d3c:	12c080e7          	jalr	300(ra) # 80002e64 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80003d40:	46e1                	li	a3,24
    80003d42:	fb840613          	addi	a2,s0,-72
    80003d46:	85ce                	mv	a1,s3
    80003d48:	05093503          	ld	a0,80(s2)
    80003d4c:	ffffd097          	auipc	ra,0xffffd
    80003d50:	eaa080e7          	jalr	-342(ra) # 80000bf6 <copyout>
    80003d54:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80003d58:	60a6                	ld	ra,72(sp)
    80003d5a:	6406                	ld	s0,64(sp)
    80003d5c:	74e2                	ld	s1,56(sp)
    80003d5e:	7942                	ld	s2,48(sp)
    80003d60:	79a2                	ld	s3,40(sp)
    80003d62:	6161                	addi	sp,sp,80
    80003d64:	8082                	ret
  return -1;
    80003d66:	557d                	li	a0,-1
    80003d68:	bfc5                	j	80003d58 <filestat+0x60>

0000000080003d6a <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80003d6a:	7179                	addi	sp,sp,-48
    80003d6c:	f406                	sd	ra,40(sp)
    80003d6e:	f022                	sd	s0,32(sp)
    80003d70:	ec26                	sd	s1,24(sp)
    80003d72:	e84a                	sd	s2,16(sp)
    80003d74:	e44e                	sd	s3,8(sp)
    80003d76:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80003d78:	00854783          	lbu	a5,8(a0)
    80003d7c:	c3d5                	beqz	a5,80003e20 <fileread+0xb6>
    80003d7e:	84aa                	mv	s1,a0
    80003d80:	89ae                	mv	s3,a1
    80003d82:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80003d84:	411c                	lw	a5,0(a0)
    80003d86:	4705                	li	a4,1
    80003d88:	04e78963          	beq	a5,a4,80003dda <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80003d8c:	470d                	li	a4,3
    80003d8e:	04e78d63          	beq	a5,a4,80003de8 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80003d92:	4709                	li	a4,2
    80003d94:	06e79e63          	bne	a5,a4,80003e10 <fileread+0xa6>
    ilock(f->ip);
    80003d98:	6d08                	ld	a0,24(a0)
    80003d9a:	fffff097          	auipc	ra,0xfffff
    80003d9e:	008080e7          	jalr	8(ra) # 80002da2 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80003da2:	874a                	mv	a4,s2
    80003da4:	5094                	lw	a3,32(s1)
    80003da6:	864e                	mv	a2,s3
    80003da8:	4585                	li	a1,1
    80003daa:	6c88                	ld	a0,24(s1)
    80003dac:	fffff097          	auipc	ra,0xfffff
    80003db0:	2aa080e7          	jalr	682(ra) # 80003056 <readi>
    80003db4:	892a                	mv	s2,a0
    80003db6:	00a05563          	blez	a0,80003dc0 <fileread+0x56>
      f->off += r;
    80003dba:	509c                	lw	a5,32(s1)
    80003dbc:	9fa9                	addw	a5,a5,a0
    80003dbe:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80003dc0:	6c88                	ld	a0,24(s1)
    80003dc2:	fffff097          	auipc	ra,0xfffff
    80003dc6:	0a2080e7          	jalr	162(ra) # 80002e64 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80003dca:	854a                	mv	a0,s2
    80003dcc:	70a2                	ld	ra,40(sp)
    80003dce:	7402                	ld	s0,32(sp)
    80003dd0:	64e2                	ld	s1,24(sp)
    80003dd2:	6942                	ld	s2,16(sp)
    80003dd4:	69a2                	ld	s3,8(sp)
    80003dd6:	6145                	addi	sp,sp,48
    80003dd8:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80003dda:	6908                	ld	a0,16(a0)
    80003ddc:	00000097          	auipc	ra,0x0
    80003de0:	3ce080e7          	jalr	974(ra) # 800041aa <piperead>
    80003de4:	892a                	mv	s2,a0
    80003de6:	b7d5                	j	80003dca <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80003de8:	02451783          	lh	a5,36(a0)
    80003dec:	03079693          	slli	a3,a5,0x30
    80003df0:	92c1                	srli	a3,a3,0x30
    80003df2:	4725                	li	a4,9
    80003df4:	02d76863          	bltu	a4,a3,80003e24 <fileread+0xba>
    80003df8:	0792                	slli	a5,a5,0x4
    80003dfa:	00015717          	auipc	a4,0x15
    80003dfe:	bfe70713          	addi	a4,a4,-1026 # 800189f8 <devsw>
    80003e02:	97ba                	add	a5,a5,a4
    80003e04:	639c                	ld	a5,0(a5)
    80003e06:	c38d                	beqz	a5,80003e28 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80003e08:	4505                	li	a0,1
    80003e0a:	9782                	jalr	a5
    80003e0c:	892a                	mv	s2,a0
    80003e0e:	bf75                	j	80003dca <fileread+0x60>
    panic("fileread");
    80003e10:	00005517          	auipc	a0,0x5
    80003e14:	89050513          	addi	a0,a0,-1904 # 800086a0 <syscalls+0x2a0>
    80003e18:	00002097          	auipc	ra,0x2
    80003e1c:	09a080e7          	jalr	154(ra) # 80005eb2 <panic>
    return -1;
    80003e20:	597d                	li	s2,-1
    80003e22:	b765                	j	80003dca <fileread+0x60>
      return -1;
    80003e24:	597d                	li	s2,-1
    80003e26:	b755                	j	80003dca <fileread+0x60>
    80003e28:	597d                	li	s2,-1
    80003e2a:	b745                	j	80003dca <fileread+0x60>

0000000080003e2c <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80003e2c:	715d                	addi	sp,sp,-80
    80003e2e:	e486                	sd	ra,72(sp)
    80003e30:	e0a2                	sd	s0,64(sp)
    80003e32:	fc26                	sd	s1,56(sp)
    80003e34:	f84a                	sd	s2,48(sp)
    80003e36:	f44e                	sd	s3,40(sp)
    80003e38:	f052                	sd	s4,32(sp)
    80003e3a:	ec56                	sd	s5,24(sp)
    80003e3c:	e85a                	sd	s6,16(sp)
    80003e3e:	e45e                	sd	s7,8(sp)
    80003e40:	e062                	sd	s8,0(sp)
    80003e42:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80003e44:	00954783          	lbu	a5,9(a0)
    80003e48:	10078663          	beqz	a5,80003f54 <filewrite+0x128>
    80003e4c:	892a                	mv	s2,a0
    80003e4e:	8aae                	mv	s5,a1
    80003e50:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80003e52:	411c                	lw	a5,0(a0)
    80003e54:	4705                	li	a4,1
    80003e56:	02e78263          	beq	a5,a4,80003e7a <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80003e5a:	470d                	li	a4,3
    80003e5c:	02e78663          	beq	a5,a4,80003e88 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80003e60:	4709                	li	a4,2
    80003e62:	0ee79163          	bne	a5,a4,80003f44 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80003e66:	0ac05d63          	blez	a2,80003f20 <filewrite+0xf4>
    int i = 0;
    80003e6a:	4981                	li	s3,0
    80003e6c:	6b05                	lui	s6,0x1
    80003e6e:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80003e72:	6b85                	lui	s7,0x1
    80003e74:	c00b8b9b          	addiw	s7,s7,-1024
    80003e78:	a861                	j	80003f10 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80003e7a:	6908                	ld	a0,16(a0)
    80003e7c:	00000097          	auipc	ra,0x0
    80003e80:	22e080e7          	jalr	558(ra) # 800040aa <pipewrite>
    80003e84:	8a2a                	mv	s4,a0
    80003e86:	a045                	j	80003f26 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80003e88:	02451783          	lh	a5,36(a0)
    80003e8c:	03079693          	slli	a3,a5,0x30
    80003e90:	92c1                	srli	a3,a3,0x30
    80003e92:	4725                	li	a4,9
    80003e94:	0cd76263          	bltu	a4,a3,80003f58 <filewrite+0x12c>
    80003e98:	0792                	slli	a5,a5,0x4
    80003e9a:	00015717          	auipc	a4,0x15
    80003e9e:	b5e70713          	addi	a4,a4,-1186 # 800189f8 <devsw>
    80003ea2:	97ba                	add	a5,a5,a4
    80003ea4:	679c                	ld	a5,8(a5)
    80003ea6:	cbdd                	beqz	a5,80003f5c <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80003ea8:	4505                	li	a0,1
    80003eaa:	9782                	jalr	a5
    80003eac:	8a2a                	mv	s4,a0
    80003eae:	a8a5                	j	80003f26 <filewrite+0xfa>
    80003eb0:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80003eb4:	00000097          	auipc	ra,0x0
    80003eb8:	8b0080e7          	jalr	-1872(ra) # 80003764 <begin_op>
      ilock(f->ip);
    80003ebc:	01893503          	ld	a0,24(s2)
    80003ec0:	fffff097          	auipc	ra,0xfffff
    80003ec4:	ee2080e7          	jalr	-286(ra) # 80002da2 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80003ec8:	8762                	mv	a4,s8
    80003eca:	02092683          	lw	a3,32(s2)
    80003ece:	01598633          	add	a2,s3,s5
    80003ed2:	4585                	li	a1,1
    80003ed4:	01893503          	ld	a0,24(s2)
    80003ed8:	fffff097          	auipc	ra,0xfffff
    80003edc:	276080e7          	jalr	630(ra) # 8000314e <writei>
    80003ee0:	84aa                	mv	s1,a0
    80003ee2:	00a05763          	blez	a0,80003ef0 <filewrite+0xc4>
        f->off += r;
    80003ee6:	02092783          	lw	a5,32(s2)
    80003eea:	9fa9                	addw	a5,a5,a0
    80003eec:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80003ef0:	01893503          	ld	a0,24(s2)
    80003ef4:	fffff097          	auipc	ra,0xfffff
    80003ef8:	f70080e7          	jalr	-144(ra) # 80002e64 <iunlock>
      end_op();
    80003efc:	00000097          	auipc	ra,0x0
    80003f00:	8e8080e7          	jalr	-1816(ra) # 800037e4 <end_op>

      if(r != n1){
    80003f04:	009c1f63          	bne	s8,s1,80003f22 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80003f08:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80003f0c:	0149db63          	bge	s3,s4,80003f22 <filewrite+0xf6>
      int n1 = n - i;
    80003f10:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80003f14:	84be                	mv	s1,a5
    80003f16:	2781                	sext.w	a5,a5
    80003f18:	f8fb5ce3          	bge	s6,a5,80003eb0 <filewrite+0x84>
    80003f1c:	84de                	mv	s1,s7
    80003f1e:	bf49                	j	80003eb0 <filewrite+0x84>
    int i = 0;
    80003f20:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80003f22:	013a1f63          	bne	s4,s3,80003f40 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80003f26:	8552                	mv	a0,s4
    80003f28:	60a6                	ld	ra,72(sp)
    80003f2a:	6406                	ld	s0,64(sp)
    80003f2c:	74e2                	ld	s1,56(sp)
    80003f2e:	7942                	ld	s2,48(sp)
    80003f30:	79a2                	ld	s3,40(sp)
    80003f32:	7a02                	ld	s4,32(sp)
    80003f34:	6ae2                	ld	s5,24(sp)
    80003f36:	6b42                	ld	s6,16(sp)
    80003f38:	6ba2                	ld	s7,8(sp)
    80003f3a:	6c02                	ld	s8,0(sp)
    80003f3c:	6161                	addi	sp,sp,80
    80003f3e:	8082                	ret
    ret = (i == n ? n : -1);
    80003f40:	5a7d                	li	s4,-1
    80003f42:	b7d5                	j	80003f26 <filewrite+0xfa>
    panic("filewrite");
    80003f44:	00004517          	auipc	a0,0x4
    80003f48:	76c50513          	addi	a0,a0,1900 # 800086b0 <syscalls+0x2b0>
    80003f4c:	00002097          	auipc	ra,0x2
    80003f50:	f66080e7          	jalr	-154(ra) # 80005eb2 <panic>
    return -1;
    80003f54:	5a7d                	li	s4,-1
    80003f56:	bfc1                	j	80003f26 <filewrite+0xfa>
      return -1;
    80003f58:	5a7d                	li	s4,-1
    80003f5a:	b7f1                	j	80003f26 <filewrite+0xfa>
    80003f5c:	5a7d                	li	s4,-1
    80003f5e:	b7e1                	j	80003f26 <filewrite+0xfa>

0000000080003f60 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80003f60:	7179                	addi	sp,sp,-48
    80003f62:	f406                	sd	ra,40(sp)
    80003f64:	f022                	sd	s0,32(sp)
    80003f66:	ec26                	sd	s1,24(sp)
    80003f68:	e84a                	sd	s2,16(sp)
    80003f6a:	e44e                	sd	s3,8(sp)
    80003f6c:	e052                	sd	s4,0(sp)
    80003f6e:	1800                	addi	s0,sp,48
    80003f70:	84aa                	mv	s1,a0
    80003f72:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80003f74:	0005b023          	sd	zero,0(a1)
    80003f78:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80003f7c:	00000097          	auipc	ra,0x0
    80003f80:	bf8080e7          	jalr	-1032(ra) # 80003b74 <filealloc>
    80003f84:	e088                	sd	a0,0(s1)
    80003f86:	c551                	beqz	a0,80004012 <pipealloc+0xb2>
    80003f88:	00000097          	auipc	ra,0x0
    80003f8c:	bec080e7          	jalr	-1044(ra) # 80003b74 <filealloc>
    80003f90:	00aa3023          	sd	a0,0(s4)
    80003f94:	c92d                	beqz	a0,80004006 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80003f96:	ffffc097          	auipc	ra,0xffffc
    80003f9a:	182080e7          	jalr	386(ra) # 80000118 <kalloc>
    80003f9e:	892a                	mv	s2,a0
    80003fa0:	c125                	beqz	a0,80004000 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80003fa2:	4985                	li	s3,1
    80003fa4:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80003fa8:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80003fac:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80003fb0:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80003fb4:	00004597          	auipc	a1,0x4
    80003fb8:	70c58593          	addi	a1,a1,1804 # 800086c0 <syscalls+0x2c0>
    80003fbc:	00002097          	auipc	ra,0x2
    80003fc0:	3b0080e7          	jalr	944(ra) # 8000636c <initlock>
  (*f0)->type = FD_PIPE;
    80003fc4:	609c                	ld	a5,0(s1)
    80003fc6:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80003fca:	609c                	ld	a5,0(s1)
    80003fcc:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80003fd0:	609c                	ld	a5,0(s1)
    80003fd2:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80003fd6:	609c                	ld	a5,0(s1)
    80003fd8:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80003fdc:	000a3783          	ld	a5,0(s4)
    80003fe0:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80003fe4:	000a3783          	ld	a5,0(s4)
    80003fe8:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80003fec:	000a3783          	ld	a5,0(s4)
    80003ff0:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80003ff4:	000a3783          	ld	a5,0(s4)
    80003ff8:	0127b823          	sd	s2,16(a5)
  return 0;
    80003ffc:	4501                	li	a0,0
    80003ffe:	a025                	j	80004026 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004000:	6088                	ld	a0,0(s1)
    80004002:	e501                	bnez	a0,8000400a <pipealloc+0xaa>
    80004004:	a039                	j	80004012 <pipealloc+0xb2>
    80004006:	6088                	ld	a0,0(s1)
    80004008:	c51d                	beqz	a0,80004036 <pipealloc+0xd6>
    fileclose(*f0);
    8000400a:	00000097          	auipc	ra,0x0
    8000400e:	c26080e7          	jalr	-986(ra) # 80003c30 <fileclose>
  if(*f1)
    80004012:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004016:	557d                	li	a0,-1
  if(*f1)
    80004018:	c799                	beqz	a5,80004026 <pipealloc+0xc6>
    fileclose(*f1);
    8000401a:	853e                	mv	a0,a5
    8000401c:	00000097          	auipc	ra,0x0
    80004020:	c14080e7          	jalr	-1004(ra) # 80003c30 <fileclose>
  return -1;
    80004024:	557d                	li	a0,-1
}
    80004026:	70a2                	ld	ra,40(sp)
    80004028:	7402                	ld	s0,32(sp)
    8000402a:	64e2                	ld	s1,24(sp)
    8000402c:	6942                	ld	s2,16(sp)
    8000402e:	69a2                	ld	s3,8(sp)
    80004030:	6a02                	ld	s4,0(sp)
    80004032:	6145                	addi	sp,sp,48
    80004034:	8082                	ret
  return -1;
    80004036:	557d                	li	a0,-1
    80004038:	b7fd                	j	80004026 <pipealloc+0xc6>

000000008000403a <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000403a:	1101                	addi	sp,sp,-32
    8000403c:	ec06                	sd	ra,24(sp)
    8000403e:	e822                	sd	s0,16(sp)
    80004040:	e426                	sd	s1,8(sp)
    80004042:	e04a                	sd	s2,0(sp)
    80004044:	1000                	addi	s0,sp,32
    80004046:	84aa                	mv	s1,a0
    80004048:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000404a:	00002097          	auipc	ra,0x2
    8000404e:	3b2080e7          	jalr	946(ra) # 800063fc <acquire>
  if(writable){
    80004052:	02090d63          	beqz	s2,8000408c <pipeclose+0x52>
    pi->writeopen = 0;
    80004056:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000405a:	21848513          	addi	a0,s1,536
    8000405e:	ffffd097          	auipc	ra,0xffffd
    80004062:	6e4080e7          	jalr	1764(ra) # 80001742 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004066:	2204b783          	ld	a5,544(s1)
    8000406a:	eb95                	bnez	a5,8000409e <pipeclose+0x64>
    release(&pi->lock);
    8000406c:	8526                	mv	a0,s1
    8000406e:	00002097          	auipc	ra,0x2
    80004072:	442080e7          	jalr	1090(ra) # 800064b0 <release>
    kfree((char*)pi);
    80004076:	8526                	mv	a0,s1
    80004078:	ffffc097          	auipc	ra,0xffffc
    8000407c:	fa4080e7          	jalr	-92(ra) # 8000001c <kfree>
  } else
    release(&pi->lock);
}
    80004080:	60e2                	ld	ra,24(sp)
    80004082:	6442                	ld	s0,16(sp)
    80004084:	64a2                	ld	s1,8(sp)
    80004086:	6902                	ld	s2,0(sp)
    80004088:	6105                	addi	sp,sp,32
    8000408a:	8082                	ret
    pi->readopen = 0;
    8000408c:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004090:	21c48513          	addi	a0,s1,540
    80004094:	ffffd097          	auipc	ra,0xffffd
    80004098:	6ae080e7          	jalr	1710(ra) # 80001742 <wakeup>
    8000409c:	b7e9                	j	80004066 <pipeclose+0x2c>
    release(&pi->lock);
    8000409e:	8526                	mv	a0,s1
    800040a0:	00002097          	auipc	ra,0x2
    800040a4:	410080e7          	jalr	1040(ra) # 800064b0 <release>
}
    800040a8:	bfe1                	j	80004080 <pipeclose+0x46>

00000000800040aa <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800040aa:	7159                	addi	sp,sp,-112
    800040ac:	f486                	sd	ra,104(sp)
    800040ae:	f0a2                	sd	s0,96(sp)
    800040b0:	eca6                	sd	s1,88(sp)
    800040b2:	e8ca                	sd	s2,80(sp)
    800040b4:	e4ce                	sd	s3,72(sp)
    800040b6:	e0d2                	sd	s4,64(sp)
    800040b8:	fc56                	sd	s5,56(sp)
    800040ba:	f85a                	sd	s6,48(sp)
    800040bc:	f45e                	sd	s7,40(sp)
    800040be:	f062                	sd	s8,32(sp)
    800040c0:	ec66                	sd	s9,24(sp)
    800040c2:	1880                	addi	s0,sp,112
    800040c4:	84aa                	mv	s1,a0
    800040c6:	8aae                	mv	s5,a1
    800040c8:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800040ca:	ffffd097          	auipc	ra,0xffffd
    800040ce:	e6a080e7          	jalr	-406(ra) # 80000f34 <myproc>
    800040d2:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800040d4:	8526                	mv	a0,s1
    800040d6:	00002097          	auipc	ra,0x2
    800040da:	326080e7          	jalr	806(ra) # 800063fc <acquire>
  while(i < n){
    800040de:	0d405463          	blez	s4,800041a6 <pipewrite+0xfc>
    800040e2:	8ba6                	mv	s7,s1
  int i = 0;
    800040e4:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800040e6:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800040e8:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800040ec:	21c48c13          	addi	s8,s1,540
    800040f0:	a08d                	j	80004152 <pipewrite+0xa8>
      release(&pi->lock);
    800040f2:	8526                	mv	a0,s1
    800040f4:	00002097          	auipc	ra,0x2
    800040f8:	3bc080e7          	jalr	956(ra) # 800064b0 <release>
      return -1;
    800040fc:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800040fe:	854a                	mv	a0,s2
    80004100:	70a6                	ld	ra,104(sp)
    80004102:	7406                	ld	s0,96(sp)
    80004104:	64e6                	ld	s1,88(sp)
    80004106:	6946                	ld	s2,80(sp)
    80004108:	69a6                	ld	s3,72(sp)
    8000410a:	6a06                	ld	s4,64(sp)
    8000410c:	7ae2                	ld	s5,56(sp)
    8000410e:	7b42                	ld	s6,48(sp)
    80004110:	7ba2                	ld	s7,40(sp)
    80004112:	7c02                	ld	s8,32(sp)
    80004114:	6ce2                	ld	s9,24(sp)
    80004116:	6165                	addi	sp,sp,112
    80004118:	8082                	ret
      wakeup(&pi->nread);
    8000411a:	8566                	mv	a0,s9
    8000411c:	ffffd097          	auipc	ra,0xffffd
    80004120:	626080e7          	jalr	1574(ra) # 80001742 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004124:	85de                	mv	a1,s7
    80004126:	8562                	mv	a0,s8
    80004128:	ffffd097          	auipc	ra,0xffffd
    8000412c:	5b6080e7          	jalr	1462(ra) # 800016de <sleep>
    80004130:	a839                	j	8000414e <pipewrite+0xa4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004132:	21c4a783          	lw	a5,540(s1)
    80004136:	0017871b          	addiw	a4,a5,1
    8000413a:	20e4ae23          	sw	a4,540(s1)
    8000413e:	1ff7f793          	andi	a5,a5,511
    80004142:	97a6                	add	a5,a5,s1
    80004144:	f9f44703          	lbu	a4,-97(s0)
    80004148:	00e78c23          	sb	a4,24(a5)
      i++;
    8000414c:	2905                	addiw	s2,s2,1
  while(i < n){
    8000414e:	05495063          	bge	s2,s4,8000418e <pipewrite+0xe4>
    if(pi->readopen == 0 || killed(pr)){
    80004152:	2204a783          	lw	a5,544(s1)
    80004156:	dfd1                	beqz	a5,800040f2 <pipewrite+0x48>
    80004158:	854e                	mv	a0,s3
    8000415a:	ffffe097          	auipc	ra,0xffffe
    8000415e:	82c080e7          	jalr	-2004(ra) # 80001986 <killed>
    80004162:	f941                	bnez	a0,800040f2 <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004164:	2184a783          	lw	a5,536(s1)
    80004168:	21c4a703          	lw	a4,540(s1)
    8000416c:	2007879b          	addiw	a5,a5,512
    80004170:	faf705e3          	beq	a4,a5,8000411a <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004174:	4685                	li	a3,1
    80004176:	01590633          	add	a2,s2,s5
    8000417a:	f9f40593          	addi	a1,s0,-97
    8000417e:	0509b503          	ld	a0,80(s3)
    80004182:	ffffd097          	auipc	ra,0xffffd
    80004186:	b00080e7          	jalr	-1280(ra) # 80000c82 <copyin>
    8000418a:	fb6514e3          	bne	a0,s6,80004132 <pipewrite+0x88>
  wakeup(&pi->nread);
    8000418e:	21848513          	addi	a0,s1,536
    80004192:	ffffd097          	auipc	ra,0xffffd
    80004196:	5b0080e7          	jalr	1456(ra) # 80001742 <wakeup>
  release(&pi->lock);
    8000419a:	8526                	mv	a0,s1
    8000419c:	00002097          	auipc	ra,0x2
    800041a0:	314080e7          	jalr	788(ra) # 800064b0 <release>
  return i;
    800041a4:	bfa9                	j	800040fe <pipewrite+0x54>
  int i = 0;
    800041a6:	4901                	li	s2,0
    800041a8:	b7dd                	j	8000418e <pipewrite+0xe4>

00000000800041aa <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800041aa:	715d                	addi	sp,sp,-80
    800041ac:	e486                	sd	ra,72(sp)
    800041ae:	e0a2                	sd	s0,64(sp)
    800041b0:	fc26                	sd	s1,56(sp)
    800041b2:	f84a                	sd	s2,48(sp)
    800041b4:	f44e                	sd	s3,40(sp)
    800041b6:	f052                	sd	s4,32(sp)
    800041b8:	ec56                	sd	s5,24(sp)
    800041ba:	e85a                	sd	s6,16(sp)
    800041bc:	0880                	addi	s0,sp,80
    800041be:	84aa                	mv	s1,a0
    800041c0:	892e                	mv	s2,a1
    800041c2:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800041c4:	ffffd097          	auipc	ra,0xffffd
    800041c8:	d70080e7          	jalr	-656(ra) # 80000f34 <myproc>
    800041cc:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800041ce:	8b26                	mv	s6,s1
    800041d0:	8526                	mv	a0,s1
    800041d2:	00002097          	auipc	ra,0x2
    800041d6:	22a080e7          	jalr	554(ra) # 800063fc <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800041da:	2184a703          	lw	a4,536(s1)
    800041de:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800041e2:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800041e6:	02f71763          	bne	a4,a5,80004214 <piperead+0x6a>
    800041ea:	2244a783          	lw	a5,548(s1)
    800041ee:	c39d                	beqz	a5,80004214 <piperead+0x6a>
    if(killed(pr)){
    800041f0:	8552                	mv	a0,s4
    800041f2:	ffffd097          	auipc	ra,0xffffd
    800041f6:	794080e7          	jalr	1940(ra) # 80001986 <killed>
    800041fa:	e941                	bnez	a0,8000428a <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800041fc:	85da                	mv	a1,s6
    800041fe:	854e                	mv	a0,s3
    80004200:	ffffd097          	auipc	ra,0xffffd
    80004204:	4de080e7          	jalr	1246(ra) # 800016de <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004208:	2184a703          	lw	a4,536(s1)
    8000420c:	21c4a783          	lw	a5,540(s1)
    80004210:	fcf70de3          	beq	a4,a5,800041ea <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004214:	09505263          	blez	s5,80004298 <piperead+0xee>
    80004218:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000421a:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    8000421c:	2184a783          	lw	a5,536(s1)
    80004220:	21c4a703          	lw	a4,540(s1)
    80004224:	02f70d63          	beq	a4,a5,8000425e <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004228:	0017871b          	addiw	a4,a5,1
    8000422c:	20e4ac23          	sw	a4,536(s1)
    80004230:	1ff7f793          	andi	a5,a5,511
    80004234:	97a6                	add	a5,a5,s1
    80004236:	0187c783          	lbu	a5,24(a5)
    8000423a:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000423e:	4685                	li	a3,1
    80004240:	fbf40613          	addi	a2,s0,-65
    80004244:	85ca                	mv	a1,s2
    80004246:	050a3503          	ld	a0,80(s4)
    8000424a:	ffffd097          	auipc	ra,0xffffd
    8000424e:	9ac080e7          	jalr	-1620(ra) # 80000bf6 <copyout>
    80004252:	01650663          	beq	a0,s6,8000425e <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004256:	2985                	addiw	s3,s3,1
    80004258:	0905                	addi	s2,s2,1
    8000425a:	fd3a91e3          	bne	s5,s3,8000421c <piperead+0x72>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000425e:	21c48513          	addi	a0,s1,540
    80004262:	ffffd097          	auipc	ra,0xffffd
    80004266:	4e0080e7          	jalr	1248(ra) # 80001742 <wakeup>
  release(&pi->lock);
    8000426a:	8526                	mv	a0,s1
    8000426c:	00002097          	auipc	ra,0x2
    80004270:	244080e7          	jalr	580(ra) # 800064b0 <release>
  return i;
}
    80004274:	854e                	mv	a0,s3
    80004276:	60a6                	ld	ra,72(sp)
    80004278:	6406                	ld	s0,64(sp)
    8000427a:	74e2                	ld	s1,56(sp)
    8000427c:	7942                	ld	s2,48(sp)
    8000427e:	79a2                	ld	s3,40(sp)
    80004280:	7a02                	ld	s4,32(sp)
    80004282:	6ae2                	ld	s5,24(sp)
    80004284:	6b42                	ld	s6,16(sp)
    80004286:	6161                	addi	sp,sp,80
    80004288:	8082                	ret
      release(&pi->lock);
    8000428a:	8526                	mv	a0,s1
    8000428c:	00002097          	auipc	ra,0x2
    80004290:	224080e7          	jalr	548(ra) # 800064b0 <release>
      return -1;
    80004294:	59fd                	li	s3,-1
    80004296:	bff9                	j	80004274 <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004298:	4981                	li	s3,0
    8000429a:	b7d1                	j	8000425e <piperead+0xb4>

000000008000429c <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    8000429c:	1141                	addi	sp,sp,-16
    8000429e:	e422                	sd	s0,8(sp)
    800042a0:	0800                	addi	s0,sp,16
    800042a2:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800042a4:	8905                	andi	a0,a0,1
    800042a6:	c111                	beqz	a0,800042aa <flags2perm+0xe>
      perm = PTE_X;
    800042a8:	4521                	li	a0,8
    if(flags & 0x2)
    800042aa:	8b89                	andi	a5,a5,2
    800042ac:	c399                	beqz	a5,800042b2 <flags2perm+0x16>
      perm |= PTE_W;
    800042ae:	00456513          	ori	a0,a0,4
    return perm;
}
    800042b2:	6422                	ld	s0,8(sp)
    800042b4:	0141                	addi	sp,sp,16
    800042b6:	8082                	ret

00000000800042b8 <exec>:

int
exec(char *path, char **argv)
{
    800042b8:	df010113          	addi	sp,sp,-528
    800042bc:	20113423          	sd	ra,520(sp)
    800042c0:	20813023          	sd	s0,512(sp)
    800042c4:	ffa6                	sd	s1,504(sp)
    800042c6:	fbca                	sd	s2,496(sp)
    800042c8:	f7ce                	sd	s3,488(sp)
    800042ca:	f3d2                	sd	s4,480(sp)
    800042cc:	efd6                	sd	s5,472(sp)
    800042ce:	ebda                	sd	s6,464(sp)
    800042d0:	e7de                	sd	s7,456(sp)
    800042d2:	e3e2                	sd	s8,448(sp)
    800042d4:	ff66                	sd	s9,440(sp)
    800042d6:	fb6a                	sd	s10,432(sp)
    800042d8:	f76e                	sd	s11,424(sp)
    800042da:	0c00                	addi	s0,sp,528
    800042dc:	84aa                	mv	s1,a0
    800042de:	dea43c23          	sd	a0,-520(s0)
    800042e2:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800042e6:	ffffd097          	auipc	ra,0xffffd
    800042ea:	c4e080e7          	jalr	-946(ra) # 80000f34 <myproc>
    800042ee:	892a                	mv	s2,a0

  begin_op();
    800042f0:	fffff097          	auipc	ra,0xfffff
    800042f4:	474080e7          	jalr	1140(ra) # 80003764 <begin_op>

  if((ip = namei(path)) == 0){
    800042f8:	8526                	mv	a0,s1
    800042fa:	fffff097          	auipc	ra,0xfffff
    800042fe:	24e080e7          	jalr	590(ra) # 80003548 <namei>
    80004302:	c92d                	beqz	a0,80004374 <exec+0xbc>
    80004304:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004306:	fffff097          	auipc	ra,0xfffff
    8000430a:	a9c080e7          	jalr	-1380(ra) # 80002da2 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000430e:	04000713          	li	a4,64
    80004312:	4681                	li	a3,0
    80004314:	e5040613          	addi	a2,s0,-432
    80004318:	4581                	li	a1,0
    8000431a:	8526                	mv	a0,s1
    8000431c:	fffff097          	auipc	ra,0xfffff
    80004320:	d3a080e7          	jalr	-710(ra) # 80003056 <readi>
    80004324:	04000793          	li	a5,64
    80004328:	00f51a63          	bne	a0,a5,8000433c <exec+0x84>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    8000432c:	e5042703          	lw	a4,-432(s0)
    80004330:	464c47b7          	lui	a5,0x464c4
    80004334:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004338:	04f70463          	beq	a4,a5,80004380 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000433c:	8526                	mv	a0,s1
    8000433e:	fffff097          	auipc	ra,0xfffff
    80004342:	cc6080e7          	jalr	-826(ra) # 80003004 <iunlockput>
    end_op();
    80004346:	fffff097          	auipc	ra,0xfffff
    8000434a:	49e080e7          	jalr	1182(ra) # 800037e4 <end_op>
  }
  return -1;
    8000434e:	557d                	li	a0,-1
}
    80004350:	20813083          	ld	ra,520(sp)
    80004354:	20013403          	ld	s0,512(sp)
    80004358:	74fe                	ld	s1,504(sp)
    8000435a:	795e                	ld	s2,496(sp)
    8000435c:	79be                	ld	s3,488(sp)
    8000435e:	7a1e                	ld	s4,480(sp)
    80004360:	6afe                	ld	s5,472(sp)
    80004362:	6b5e                	ld	s6,464(sp)
    80004364:	6bbe                	ld	s7,456(sp)
    80004366:	6c1e                	ld	s8,448(sp)
    80004368:	7cfa                	ld	s9,440(sp)
    8000436a:	7d5a                	ld	s10,432(sp)
    8000436c:	7dba                	ld	s11,424(sp)
    8000436e:	21010113          	addi	sp,sp,528
    80004372:	8082                	ret
    end_op();
    80004374:	fffff097          	auipc	ra,0xfffff
    80004378:	470080e7          	jalr	1136(ra) # 800037e4 <end_op>
    return -1;
    8000437c:	557d                	li	a0,-1
    8000437e:	bfc9                	j	80004350 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80004380:	854a                	mv	a0,s2
    80004382:	ffffd097          	auipc	ra,0xffffd
    80004386:	c76080e7          	jalr	-906(ra) # 80000ff8 <proc_pagetable>
    8000438a:	8baa                	mv	s7,a0
    8000438c:	d945                	beqz	a0,8000433c <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000438e:	e7042983          	lw	s3,-400(s0)
    80004392:	e8845783          	lhu	a5,-376(s0)
    80004396:	c7ad                	beqz	a5,80004400 <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004398:	4a01                	li	s4,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000439a:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    8000439c:	6c85                	lui	s9,0x1
    8000439e:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800043a2:	def43823          	sd	a5,-528(s0)
    800043a6:	a4a9                	j	800045f0 <exec+0x338>
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800043a8:	00004517          	auipc	a0,0x4
    800043ac:	32050513          	addi	a0,a0,800 # 800086c8 <syscalls+0x2c8>
    800043b0:	00002097          	auipc	ra,0x2
    800043b4:	b02080e7          	jalr	-1278(ra) # 80005eb2 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800043b8:	8756                	mv	a4,s5
    800043ba:	012d86bb          	addw	a3,s11,s2
    800043be:	4581                	li	a1,0
    800043c0:	8526                	mv	a0,s1
    800043c2:	fffff097          	auipc	ra,0xfffff
    800043c6:	c94080e7          	jalr	-876(ra) # 80003056 <readi>
    800043ca:	2501                	sext.w	a0,a0
    800043cc:	1caa9663          	bne	s5,a0,80004598 <exec+0x2e0>
  for(i = 0; i < sz; i += PGSIZE){
    800043d0:	6785                	lui	a5,0x1
    800043d2:	0127893b          	addw	s2,a5,s2
    800043d6:	77fd                	lui	a5,0xfffff
    800043d8:	01478a3b          	addw	s4,a5,s4
    800043dc:	21897163          	bgeu	s2,s8,800045de <exec+0x326>
    pa = walkaddr(pagetable, va + i);
    800043e0:	02091593          	slli	a1,s2,0x20
    800043e4:	9181                	srli	a1,a1,0x20
    800043e6:	95ea                	add	a1,a1,s10
    800043e8:	855e                	mv	a0,s7
    800043ea:	ffffc097          	auipc	ra,0xffffc
    800043ee:	200080e7          	jalr	512(ra) # 800005ea <walkaddr>
    800043f2:	862a                	mv	a2,a0
    if(pa == 0)
    800043f4:	d955                	beqz	a0,800043a8 <exec+0xf0>
      n = PGSIZE;
    800043f6:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    800043f8:	fd9a70e3          	bgeu	s4,s9,800043b8 <exec+0x100>
      n = sz - i;
    800043fc:	8ad2                	mv	s5,s4
    800043fe:	bf6d                	j	800043b8 <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004400:	4a01                	li	s4,0
  iunlockput(ip);
    80004402:	8526                	mv	a0,s1
    80004404:	fffff097          	auipc	ra,0xfffff
    80004408:	c00080e7          	jalr	-1024(ra) # 80003004 <iunlockput>
  end_op();
    8000440c:	fffff097          	auipc	ra,0xfffff
    80004410:	3d8080e7          	jalr	984(ra) # 800037e4 <end_op>
  p = myproc();
    80004414:	ffffd097          	auipc	ra,0xffffd
    80004418:	b20080e7          	jalr	-1248(ra) # 80000f34 <myproc>
    8000441c:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    8000441e:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004422:	6785                	lui	a5,0x1
    80004424:	17fd                	addi	a5,a5,-1
    80004426:	9a3e                	add	s4,s4,a5
    80004428:	757d                	lui	a0,0xfffff
    8000442a:	00aa77b3          	and	a5,s4,a0
    8000442e:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004432:	4691                	li	a3,4
    80004434:	6609                	lui	a2,0x2
    80004436:	963e                	add	a2,a2,a5
    80004438:	85be                	mv	a1,a5
    8000443a:	855e                	mv	a0,s7
    8000443c:	ffffc097          	auipc	ra,0xffffc
    80004440:	562080e7          	jalr	1378(ra) # 8000099e <uvmalloc>
    80004444:	8b2a                	mv	s6,a0
  ip = 0;
    80004446:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004448:	14050863          	beqz	a0,80004598 <exec+0x2e0>
  uvmclear(pagetable, sz-2*PGSIZE);
    8000444c:	75f9                	lui	a1,0xffffe
    8000444e:	95aa                	add	a1,a1,a0
    80004450:	855e                	mv	a0,s7
    80004452:	ffffc097          	auipc	ra,0xffffc
    80004456:	772080e7          	jalr	1906(ra) # 80000bc4 <uvmclear>
  stackbase = sp - PGSIZE;
    8000445a:	7c7d                	lui	s8,0xfffff
    8000445c:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    8000445e:	e0043783          	ld	a5,-512(s0)
    80004462:	6388                	ld	a0,0(a5)
    80004464:	c535                	beqz	a0,800044d0 <exec+0x218>
    80004466:	e9040993          	addi	s3,s0,-368
    8000446a:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    8000446e:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    80004470:	ffffc097          	auipc	ra,0xffffc
    80004474:	e8c080e7          	jalr	-372(ra) # 800002fc <strlen>
    80004478:	2505                	addiw	a0,a0,1
    8000447a:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000447e:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004482:	15896263          	bltu	s2,s8,800045c6 <exec+0x30e>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004486:	e0043d83          	ld	s11,-512(s0)
    8000448a:	000dba03          	ld	s4,0(s11)
    8000448e:	8552                	mv	a0,s4
    80004490:	ffffc097          	auipc	ra,0xffffc
    80004494:	e6c080e7          	jalr	-404(ra) # 800002fc <strlen>
    80004498:	0015069b          	addiw	a3,a0,1
    8000449c:	8652                	mv	a2,s4
    8000449e:	85ca                	mv	a1,s2
    800044a0:	855e                	mv	a0,s7
    800044a2:	ffffc097          	auipc	ra,0xffffc
    800044a6:	754080e7          	jalr	1876(ra) # 80000bf6 <copyout>
    800044aa:	12054263          	bltz	a0,800045ce <exec+0x316>
    ustack[argc] = sp;
    800044ae:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800044b2:	0485                	addi	s1,s1,1
    800044b4:	008d8793          	addi	a5,s11,8
    800044b8:	e0f43023          	sd	a5,-512(s0)
    800044bc:	008db503          	ld	a0,8(s11)
    800044c0:	c911                	beqz	a0,800044d4 <exec+0x21c>
    if(argc >= MAXARG)
    800044c2:	09a1                	addi	s3,s3,8
    800044c4:	fb3c96e3          	bne	s9,s3,80004470 <exec+0x1b8>
  sz = sz1;
    800044c8:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800044cc:	4481                	li	s1,0
    800044ce:	a0e9                	j	80004598 <exec+0x2e0>
  sp = sz;
    800044d0:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    800044d2:	4481                	li	s1,0
  ustack[argc] = 0;
    800044d4:	00349793          	slli	a5,s1,0x3
    800044d8:	f9040713          	addi	a4,s0,-112
    800044dc:	97ba                	add	a5,a5,a4
    800044de:	f007b023          	sd	zero,-256(a5) # f00 <_entry-0x7ffff100>
  sp -= (argc+1) * sizeof(uint64);
    800044e2:	00148693          	addi	a3,s1,1
    800044e6:	068e                	slli	a3,a3,0x3
    800044e8:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800044ec:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800044f0:	01897663          	bgeu	s2,s8,800044fc <exec+0x244>
  sz = sz1;
    800044f4:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800044f8:	4481                	li	s1,0
    800044fa:	a879                	j	80004598 <exec+0x2e0>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800044fc:	e9040613          	addi	a2,s0,-368
    80004500:	85ca                	mv	a1,s2
    80004502:	855e                	mv	a0,s7
    80004504:	ffffc097          	auipc	ra,0xffffc
    80004508:	6f2080e7          	jalr	1778(ra) # 80000bf6 <copyout>
    8000450c:	0c054563          	bltz	a0,800045d6 <exec+0x31e>
  p->trapframe->a1 = sp;
    80004510:	058ab783          	ld	a5,88(s5)
    80004514:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004518:	df843783          	ld	a5,-520(s0)
    8000451c:	0007c703          	lbu	a4,0(a5)
    80004520:	cf11                	beqz	a4,8000453c <exec+0x284>
    80004522:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004524:	02f00693          	li	a3,47
    80004528:	a039                	j	80004536 <exec+0x27e>
      last = s+1;
    8000452a:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    8000452e:	0785                	addi	a5,a5,1
    80004530:	fff7c703          	lbu	a4,-1(a5)
    80004534:	c701                	beqz	a4,8000453c <exec+0x284>
    if(*s == '/')
    80004536:	fed71ce3          	bne	a4,a3,8000452e <exec+0x276>
    8000453a:	bfc5                	j	8000452a <exec+0x272>
  safestrcpy(p->name, last, sizeof(p->name));
    8000453c:	4641                	li	a2,16
    8000453e:	df843583          	ld	a1,-520(s0)
    80004542:	158a8513          	addi	a0,s5,344
    80004546:	ffffc097          	auipc	ra,0xffffc
    8000454a:	d84080e7          	jalr	-636(ra) # 800002ca <safestrcpy>
  oldpagetable = p->pagetable;
    8000454e:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004552:	057ab823          	sd	s7,80(s5)
  p->sz = sz;
    80004556:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    8000455a:	058ab783          	ld	a5,88(s5)
    8000455e:	e6843703          	ld	a4,-408(s0)
    80004562:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004564:	058ab783          	ld	a5,88(s5)
    80004568:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000456c:	85ea                	mv	a1,s10
    8000456e:	ffffd097          	auipc	ra,0xffffd
    80004572:	b8c080e7          	jalr	-1140(ra) # 800010fa <proc_freepagetable>
  if(p->pid==1)
    80004576:	030aa703          	lw	a4,48(s5)
    8000457a:	4785                	li	a5,1
    8000457c:	00f70563          	beq	a4,a5,80004586 <exec+0x2ce>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004580:	0004851b          	sext.w	a0,s1
    80004584:	b3f1                	j	80004350 <exec+0x98>
  vmprint(p->pagetable);
    80004586:	050ab503          	ld	a0,80(s5)
    8000458a:	ffffc097          	auipc	ra,0xffffc
    8000458e:	eda080e7          	jalr	-294(ra) # 80000464 <vmprint>
    80004592:	b7fd                	j	80004580 <exec+0x2c8>
    80004594:	e1443423          	sd	s4,-504(s0)
    proc_freepagetable(pagetable, sz);
    80004598:	e0843583          	ld	a1,-504(s0)
    8000459c:	855e                	mv	a0,s7
    8000459e:	ffffd097          	auipc	ra,0xffffd
    800045a2:	b5c080e7          	jalr	-1188(ra) # 800010fa <proc_freepagetable>
  if(ip){
    800045a6:	d8049be3          	bnez	s1,8000433c <exec+0x84>
  return -1;
    800045aa:	557d                	li	a0,-1
    800045ac:	b355                	j	80004350 <exec+0x98>
    800045ae:	e1443423          	sd	s4,-504(s0)
    800045b2:	b7dd                	j	80004598 <exec+0x2e0>
    800045b4:	e1443423          	sd	s4,-504(s0)
    800045b8:	b7c5                	j	80004598 <exec+0x2e0>
    800045ba:	e1443423          	sd	s4,-504(s0)
    800045be:	bfe9                	j	80004598 <exec+0x2e0>
    800045c0:	e1443423          	sd	s4,-504(s0)
    800045c4:	bfd1                	j	80004598 <exec+0x2e0>
  sz = sz1;
    800045c6:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800045ca:	4481                	li	s1,0
    800045cc:	b7f1                	j	80004598 <exec+0x2e0>
  sz = sz1;
    800045ce:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800045d2:	4481                	li	s1,0
    800045d4:	b7d1                	j	80004598 <exec+0x2e0>
  sz = sz1;
    800045d6:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800045da:	4481                	li	s1,0
    800045dc:	bf75                	j	80004598 <exec+0x2e0>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800045de:	e0843a03          	ld	s4,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800045e2:	2b05                	addiw	s6,s6,1
    800045e4:	0389899b          	addiw	s3,s3,56
    800045e8:	e8845783          	lhu	a5,-376(s0)
    800045ec:	e0fb5be3          	bge	s6,a5,80004402 <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800045f0:	2981                	sext.w	s3,s3
    800045f2:	03800713          	li	a4,56
    800045f6:	86ce                	mv	a3,s3
    800045f8:	e1840613          	addi	a2,s0,-488
    800045fc:	4581                	li	a1,0
    800045fe:	8526                	mv	a0,s1
    80004600:	fffff097          	auipc	ra,0xfffff
    80004604:	a56080e7          	jalr	-1450(ra) # 80003056 <readi>
    80004608:	03800793          	li	a5,56
    8000460c:	f8f514e3          	bne	a0,a5,80004594 <exec+0x2dc>
    if(ph.type != ELF_PROG_LOAD)
    80004610:	e1842783          	lw	a5,-488(s0)
    80004614:	4705                	li	a4,1
    80004616:	fce796e3          	bne	a5,a4,800045e2 <exec+0x32a>
    if(ph.memsz < ph.filesz)
    8000461a:	e4043903          	ld	s2,-448(s0)
    8000461e:	e3843783          	ld	a5,-456(s0)
    80004622:	f8f966e3          	bltu	s2,a5,800045ae <exec+0x2f6>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004626:	e2843783          	ld	a5,-472(s0)
    8000462a:	993e                	add	s2,s2,a5
    8000462c:	f8f964e3          	bltu	s2,a5,800045b4 <exec+0x2fc>
    if(ph.vaddr % PGSIZE != 0)
    80004630:	df043703          	ld	a4,-528(s0)
    80004634:	8ff9                	and	a5,a5,a4
    80004636:	f3d1                	bnez	a5,800045ba <exec+0x302>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004638:	e1c42503          	lw	a0,-484(s0)
    8000463c:	00000097          	auipc	ra,0x0
    80004640:	c60080e7          	jalr	-928(ra) # 8000429c <flags2perm>
    80004644:	86aa                	mv	a3,a0
    80004646:	864a                	mv	a2,s2
    80004648:	85d2                	mv	a1,s4
    8000464a:	855e                	mv	a0,s7
    8000464c:	ffffc097          	auipc	ra,0xffffc
    80004650:	352080e7          	jalr	850(ra) # 8000099e <uvmalloc>
    80004654:	e0a43423          	sd	a0,-504(s0)
    80004658:	d525                	beqz	a0,800045c0 <exec+0x308>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000465a:	e2843d03          	ld	s10,-472(s0)
    8000465e:	e2042d83          	lw	s11,-480(s0)
    80004662:	e3842c03          	lw	s8,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004666:	f60c0ce3          	beqz	s8,800045de <exec+0x326>
    8000466a:	8a62                	mv	s4,s8
    8000466c:	4901                	li	s2,0
    8000466e:	bb8d                	j	800043e0 <exec+0x128>

0000000080004670 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004670:	7179                	addi	sp,sp,-48
    80004672:	f406                	sd	ra,40(sp)
    80004674:	f022                	sd	s0,32(sp)
    80004676:	ec26                	sd	s1,24(sp)
    80004678:	e84a                	sd	s2,16(sp)
    8000467a:	1800                	addi	s0,sp,48
    8000467c:	892e                	mv	s2,a1
    8000467e:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004680:	fdc40593          	addi	a1,s0,-36
    80004684:	ffffe097          	auipc	ra,0xffffe
    80004688:	ac6080e7          	jalr	-1338(ra) # 8000214a <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000468c:	fdc42703          	lw	a4,-36(s0)
    80004690:	47bd                	li	a5,15
    80004692:	02e7eb63          	bltu	a5,a4,800046c8 <argfd+0x58>
    80004696:	ffffd097          	auipc	ra,0xffffd
    8000469a:	89e080e7          	jalr	-1890(ra) # 80000f34 <myproc>
    8000469e:	fdc42703          	lw	a4,-36(s0)
    800046a2:	01a70793          	addi	a5,a4,26
    800046a6:	078e                	slli	a5,a5,0x3
    800046a8:	953e                	add	a0,a0,a5
    800046aa:	611c                	ld	a5,0(a0)
    800046ac:	c385                	beqz	a5,800046cc <argfd+0x5c>
    return -1;
  if(pfd)
    800046ae:	00090463          	beqz	s2,800046b6 <argfd+0x46>
    *pfd = fd;
    800046b2:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800046b6:	4501                	li	a0,0
  if(pf)
    800046b8:	c091                	beqz	s1,800046bc <argfd+0x4c>
    *pf = f;
    800046ba:	e09c                	sd	a5,0(s1)
}
    800046bc:	70a2                	ld	ra,40(sp)
    800046be:	7402                	ld	s0,32(sp)
    800046c0:	64e2                	ld	s1,24(sp)
    800046c2:	6942                	ld	s2,16(sp)
    800046c4:	6145                	addi	sp,sp,48
    800046c6:	8082                	ret
    return -1;
    800046c8:	557d                	li	a0,-1
    800046ca:	bfcd                	j	800046bc <argfd+0x4c>
    800046cc:	557d                	li	a0,-1
    800046ce:	b7fd                	j	800046bc <argfd+0x4c>

00000000800046d0 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800046d0:	1101                	addi	sp,sp,-32
    800046d2:	ec06                	sd	ra,24(sp)
    800046d4:	e822                	sd	s0,16(sp)
    800046d6:	e426                	sd	s1,8(sp)
    800046d8:	1000                	addi	s0,sp,32
    800046da:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800046dc:	ffffd097          	auipc	ra,0xffffd
    800046e0:	858080e7          	jalr	-1960(ra) # 80000f34 <myproc>
    800046e4:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800046e6:	0d050793          	addi	a5,a0,208 # fffffffffffff0d0 <end+0xffffffff7ffdd300>
    800046ea:	4501                	li	a0,0
    800046ec:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800046ee:	6398                	ld	a4,0(a5)
    800046f0:	cb19                	beqz	a4,80004706 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800046f2:	2505                	addiw	a0,a0,1
    800046f4:	07a1                	addi	a5,a5,8
    800046f6:	fed51ce3          	bne	a0,a3,800046ee <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800046fa:	557d                	li	a0,-1
}
    800046fc:	60e2                	ld	ra,24(sp)
    800046fe:	6442                	ld	s0,16(sp)
    80004700:	64a2                	ld	s1,8(sp)
    80004702:	6105                	addi	sp,sp,32
    80004704:	8082                	ret
      p->ofile[fd] = f;
    80004706:	01a50793          	addi	a5,a0,26
    8000470a:	078e                	slli	a5,a5,0x3
    8000470c:	963e                	add	a2,a2,a5
    8000470e:	e204                	sd	s1,0(a2)
      return fd;
    80004710:	b7f5                	j	800046fc <fdalloc+0x2c>

0000000080004712 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004712:	715d                	addi	sp,sp,-80
    80004714:	e486                	sd	ra,72(sp)
    80004716:	e0a2                	sd	s0,64(sp)
    80004718:	fc26                	sd	s1,56(sp)
    8000471a:	f84a                	sd	s2,48(sp)
    8000471c:	f44e                	sd	s3,40(sp)
    8000471e:	f052                	sd	s4,32(sp)
    80004720:	ec56                	sd	s5,24(sp)
    80004722:	e85a                	sd	s6,16(sp)
    80004724:	0880                	addi	s0,sp,80
    80004726:	8b2e                	mv	s6,a1
    80004728:	89b2                	mv	s3,a2
    8000472a:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000472c:	fb040593          	addi	a1,s0,-80
    80004730:	fffff097          	auipc	ra,0xfffff
    80004734:	e36080e7          	jalr	-458(ra) # 80003566 <nameiparent>
    80004738:	84aa                	mv	s1,a0
    8000473a:	16050063          	beqz	a0,8000489a <create+0x188>
    return 0;

  ilock(dp);
    8000473e:	ffffe097          	auipc	ra,0xffffe
    80004742:	664080e7          	jalr	1636(ra) # 80002da2 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004746:	4601                	li	a2,0
    80004748:	fb040593          	addi	a1,s0,-80
    8000474c:	8526                	mv	a0,s1
    8000474e:	fffff097          	auipc	ra,0xfffff
    80004752:	b38080e7          	jalr	-1224(ra) # 80003286 <dirlookup>
    80004756:	8aaa                	mv	s5,a0
    80004758:	c931                	beqz	a0,800047ac <create+0x9a>
    iunlockput(dp);
    8000475a:	8526                	mv	a0,s1
    8000475c:	fffff097          	auipc	ra,0xfffff
    80004760:	8a8080e7          	jalr	-1880(ra) # 80003004 <iunlockput>
    ilock(ip);
    80004764:	8556                	mv	a0,s5
    80004766:	ffffe097          	auipc	ra,0xffffe
    8000476a:	63c080e7          	jalr	1596(ra) # 80002da2 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000476e:	000b059b          	sext.w	a1,s6
    80004772:	4789                	li	a5,2
    80004774:	02f59563          	bne	a1,a5,8000479e <create+0x8c>
    80004778:	044ad783          	lhu	a5,68(s5)
    8000477c:	37f9                	addiw	a5,a5,-2
    8000477e:	17c2                	slli	a5,a5,0x30
    80004780:	93c1                	srli	a5,a5,0x30
    80004782:	4705                	li	a4,1
    80004784:	00f76d63          	bltu	a4,a5,8000479e <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004788:	8556                	mv	a0,s5
    8000478a:	60a6                	ld	ra,72(sp)
    8000478c:	6406                	ld	s0,64(sp)
    8000478e:	74e2                	ld	s1,56(sp)
    80004790:	7942                	ld	s2,48(sp)
    80004792:	79a2                	ld	s3,40(sp)
    80004794:	7a02                	ld	s4,32(sp)
    80004796:	6ae2                	ld	s5,24(sp)
    80004798:	6b42                	ld	s6,16(sp)
    8000479a:	6161                	addi	sp,sp,80
    8000479c:	8082                	ret
    iunlockput(ip);
    8000479e:	8556                	mv	a0,s5
    800047a0:	fffff097          	auipc	ra,0xfffff
    800047a4:	864080e7          	jalr	-1948(ra) # 80003004 <iunlockput>
    return 0;
    800047a8:	4a81                	li	s5,0
    800047aa:	bff9                	j	80004788 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    800047ac:	85da                	mv	a1,s6
    800047ae:	4088                	lw	a0,0(s1)
    800047b0:	ffffe097          	auipc	ra,0xffffe
    800047b4:	456080e7          	jalr	1110(ra) # 80002c06 <ialloc>
    800047b8:	8a2a                	mv	s4,a0
    800047ba:	c921                	beqz	a0,8000480a <create+0xf8>
  ilock(ip);
    800047bc:	ffffe097          	auipc	ra,0xffffe
    800047c0:	5e6080e7          	jalr	1510(ra) # 80002da2 <ilock>
  ip->major = major;
    800047c4:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800047c8:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800047cc:	4785                	li	a5,1
    800047ce:	04fa1523          	sh	a5,74(s4)
  iupdate(ip);
    800047d2:	8552                	mv	a0,s4
    800047d4:	ffffe097          	auipc	ra,0xffffe
    800047d8:	504080e7          	jalr	1284(ra) # 80002cd8 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800047dc:	000b059b          	sext.w	a1,s6
    800047e0:	4785                	li	a5,1
    800047e2:	02f58b63          	beq	a1,a5,80004818 <create+0x106>
  if(dirlink(dp, name, ip->inum) < 0)
    800047e6:	004a2603          	lw	a2,4(s4)
    800047ea:	fb040593          	addi	a1,s0,-80
    800047ee:	8526                	mv	a0,s1
    800047f0:	fffff097          	auipc	ra,0xfffff
    800047f4:	ca6080e7          	jalr	-858(ra) # 80003496 <dirlink>
    800047f8:	06054f63          	bltz	a0,80004876 <create+0x164>
  iunlockput(dp);
    800047fc:	8526                	mv	a0,s1
    800047fe:	fffff097          	auipc	ra,0xfffff
    80004802:	806080e7          	jalr	-2042(ra) # 80003004 <iunlockput>
  return ip;
    80004806:	8ad2                	mv	s5,s4
    80004808:	b741                	j	80004788 <create+0x76>
    iunlockput(dp);
    8000480a:	8526                	mv	a0,s1
    8000480c:	ffffe097          	auipc	ra,0xffffe
    80004810:	7f8080e7          	jalr	2040(ra) # 80003004 <iunlockput>
    return 0;
    80004814:	8ad2                	mv	s5,s4
    80004816:	bf8d                	j	80004788 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004818:	004a2603          	lw	a2,4(s4)
    8000481c:	00004597          	auipc	a1,0x4
    80004820:	ecc58593          	addi	a1,a1,-308 # 800086e8 <syscalls+0x2e8>
    80004824:	8552                	mv	a0,s4
    80004826:	fffff097          	auipc	ra,0xfffff
    8000482a:	c70080e7          	jalr	-912(ra) # 80003496 <dirlink>
    8000482e:	04054463          	bltz	a0,80004876 <create+0x164>
    80004832:	40d0                	lw	a2,4(s1)
    80004834:	00004597          	auipc	a1,0x4
    80004838:	ebc58593          	addi	a1,a1,-324 # 800086f0 <syscalls+0x2f0>
    8000483c:	8552                	mv	a0,s4
    8000483e:	fffff097          	auipc	ra,0xfffff
    80004842:	c58080e7          	jalr	-936(ra) # 80003496 <dirlink>
    80004846:	02054863          	bltz	a0,80004876 <create+0x164>
  if(dirlink(dp, name, ip->inum) < 0)
    8000484a:	004a2603          	lw	a2,4(s4)
    8000484e:	fb040593          	addi	a1,s0,-80
    80004852:	8526                	mv	a0,s1
    80004854:	fffff097          	auipc	ra,0xfffff
    80004858:	c42080e7          	jalr	-958(ra) # 80003496 <dirlink>
    8000485c:	00054d63          	bltz	a0,80004876 <create+0x164>
    dp->nlink++;  // for ".."
    80004860:	04a4d783          	lhu	a5,74(s1)
    80004864:	2785                	addiw	a5,a5,1
    80004866:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000486a:	8526                	mv	a0,s1
    8000486c:	ffffe097          	auipc	ra,0xffffe
    80004870:	46c080e7          	jalr	1132(ra) # 80002cd8 <iupdate>
    80004874:	b761                	j	800047fc <create+0xea>
  ip->nlink = 0;
    80004876:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    8000487a:	8552                	mv	a0,s4
    8000487c:	ffffe097          	auipc	ra,0xffffe
    80004880:	45c080e7          	jalr	1116(ra) # 80002cd8 <iupdate>
  iunlockput(ip);
    80004884:	8552                	mv	a0,s4
    80004886:	ffffe097          	auipc	ra,0xffffe
    8000488a:	77e080e7          	jalr	1918(ra) # 80003004 <iunlockput>
  iunlockput(dp);
    8000488e:	8526                	mv	a0,s1
    80004890:	ffffe097          	auipc	ra,0xffffe
    80004894:	774080e7          	jalr	1908(ra) # 80003004 <iunlockput>
  return 0;
    80004898:	bdc5                	j	80004788 <create+0x76>
    return 0;
    8000489a:	8aaa                	mv	s5,a0
    8000489c:	b5f5                	j	80004788 <create+0x76>

000000008000489e <sys_dup>:
{
    8000489e:	7179                	addi	sp,sp,-48
    800048a0:	f406                	sd	ra,40(sp)
    800048a2:	f022                	sd	s0,32(sp)
    800048a4:	ec26                	sd	s1,24(sp)
    800048a6:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800048a8:	fd840613          	addi	a2,s0,-40
    800048ac:	4581                	li	a1,0
    800048ae:	4501                	li	a0,0
    800048b0:	00000097          	auipc	ra,0x0
    800048b4:	dc0080e7          	jalr	-576(ra) # 80004670 <argfd>
    return -1;
    800048b8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800048ba:	02054363          	bltz	a0,800048e0 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800048be:	fd843503          	ld	a0,-40(s0)
    800048c2:	00000097          	auipc	ra,0x0
    800048c6:	e0e080e7          	jalr	-498(ra) # 800046d0 <fdalloc>
    800048ca:	84aa                	mv	s1,a0
    return -1;
    800048cc:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800048ce:	00054963          	bltz	a0,800048e0 <sys_dup+0x42>
  filedup(f);
    800048d2:	fd843503          	ld	a0,-40(s0)
    800048d6:	fffff097          	auipc	ra,0xfffff
    800048da:	308080e7          	jalr	776(ra) # 80003bde <filedup>
  return fd;
    800048de:	87a6                	mv	a5,s1
}
    800048e0:	853e                	mv	a0,a5
    800048e2:	70a2                	ld	ra,40(sp)
    800048e4:	7402                	ld	s0,32(sp)
    800048e6:	64e2                	ld	s1,24(sp)
    800048e8:	6145                	addi	sp,sp,48
    800048ea:	8082                	ret

00000000800048ec <sys_read>:
{
    800048ec:	7179                	addi	sp,sp,-48
    800048ee:	f406                	sd	ra,40(sp)
    800048f0:	f022                	sd	s0,32(sp)
    800048f2:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800048f4:	fd840593          	addi	a1,s0,-40
    800048f8:	4505                	li	a0,1
    800048fa:	ffffe097          	auipc	ra,0xffffe
    800048fe:	870080e7          	jalr	-1936(ra) # 8000216a <argaddr>
  argint(2, &n);
    80004902:	fe440593          	addi	a1,s0,-28
    80004906:	4509                	li	a0,2
    80004908:	ffffe097          	auipc	ra,0xffffe
    8000490c:	842080e7          	jalr	-1982(ra) # 8000214a <argint>
  if(argfd(0, 0, &f) < 0)
    80004910:	fe840613          	addi	a2,s0,-24
    80004914:	4581                	li	a1,0
    80004916:	4501                	li	a0,0
    80004918:	00000097          	auipc	ra,0x0
    8000491c:	d58080e7          	jalr	-680(ra) # 80004670 <argfd>
    80004920:	87aa                	mv	a5,a0
    return -1;
    80004922:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004924:	0007cc63          	bltz	a5,8000493c <sys_read+0x50>
  return fileread(f, p, n);
    80004928:	fe442603          	lw	a2,-28(s0)
    8000492c:	fd843583          	ld	a1,-40(s0)
    80004930:	fe843503          	ld	a0,-24(s0)
    80004934:	fffff097          	auipc	ra,0xfffff
    80004938:	436080e7          	jalr	1078(ra) # 80003d6a <fileread>
}
    8000493c:	70a2                	ld	ra,40(sp)
    8000493e:	7402                	ld	s0,32(sp)
    80004940:	6145                	addi	sp,sp,48
    80004942:	8082                	ret

0000000080004944 <sys_write>:
{
    80004944:	7179                	addi	sp,sp,-48
    80004946:	f406                	sd	ra,40(sp)
    80004948:	f022                	sd	s0,32(sp)
    8000494a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000494c:	fd840593          	addi	a1,s0,-40
    80004950:	4505                	li	a0,1
    80004952:	ffffe097          	auipc	ra,0xffffe
    80004956:	818080e7          	jalr	-2024(ra) # 8000216a <argaddr>
  argint(2, &n);
    8000495a:	fe440593          	addi	a1,s0,-28
    8000495e:	4509                	li	a0,2
    80004960:	ffffd097          	auipc	ra,0xffffd
    80004964:	7ea080e7          	jalr	2026(ra) # 8000214a <argint>
  if(argfd(0, 0, &f) < 0)
    80004968:	fe840613          	addi	a2,s0,-24
    8000496c:	4581                	li	a1,0
    8000496e:	4501                	li	a0,0
    80004970:	00000097          	auipc	ra,0x0
    80004974:	d00080e7          	jalr	-768(ra) # 80004670 <argfd>
    80004978:	87aa                	mv	a5,a0
    return -1;
    8000497a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000497c:	0007cc63          	bltz	a5,80004994 <sys_write+0x50>
  return filewrite(f, p, n);
    80004980:	fe442603          	lw	a2,-28(s0)
    80004984:	fd843583          	ld	a1,-40(s0)
    80004988:	fe843503          	ld	a0,-24(s0)
    8000498c:	fffff097          	auipc	ra,0xfffff
    80004990:	4a0080e7          	jalr	1184(ra) # 80003e2c <filewrite>
}
    80004994:	70a2                	ld	ra,40(sp)
    80004996:	7402                	ld	s0,32(sp)
    80004998:	6145                	addi	sp,sp,48
    8000499a:	8082                	ret

000000008000499c <sys_close>:
{
    8000499c:	1101                	addi	sp,sp,-32
    8000499e:	ec06                	sd	ra,24(sp)
    800049a0:	e822                	sd	s0,16(sp)
    800049a2:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800049a4:	fe040613          	addi	a2,s0,-32
    800049a8:	fec40593          	addi	a1,s0,-20
    800049ac:	4501                	li	a0,0
    800049ae:	00000097          	auipc	ra,0x0
    800049b2:	cc2080e7          	jalr	-830(ra) # 80004670 <argfd>
    return -1;
    800049b6:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800049b8:	02054463          	bltz	a0,800049e0 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800049bc:	ffffc097          	auipc	ra,0xffffc
    800049c0:	578080e7          	jalr	1400(ra) # 80000f34 <myproc>
    800049c4:	fec42783          	lw	a5,-20(s0)
    800049c8:	07e9                	addi	a5,a5,26
    800049ca:	078e                	slli	a5,a5,0x3
    800049cc:	97aa                	add	a5,a5,a0
    800049ce:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    800049d2:	fe043503          	ld	a0,-32(s0)
    800049d6:	fffff097          	auipc	ra,0xfffff
    800049da:	25a080e7          	jalr	602(ra) # 80003c30 <fileclose>
  return 0;
    800049de:	4781                	li	a5,0
}
    800049e0:	853e                	mv	a0,a5
    800049e2:	60e2                	ld	ra,24(sp)
    800049e4:	6442                	ld	s0,16(sp)
    800049e6:	6105                	addi	sp,sp,32
    800049e8:	8082                	ret

00000000800049ea <sys_fstat>:
{
    800049ea:	1101                	addi	sp,sp,-32
    800049ec:	ec06                	sd	ra,24(sp)
    800049ee:	e822                	sd	s0,16(sp)
    800049f0:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800049f2:	fe040593          	addi	a1,s0,-32
    800049f6:	4505                	li	a0,1
    800049f8:	ffffd097          	auipc	ra,0xffffd
    800049fc:	772080e7          	jalr	1906(ra) # 8000216a <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004a00:	fe840613          	addi	a2,s0,-24
    80004a04:	4581                	li	a1,0
    80004a06:	4501                	li	a0,0
    80004a08:	00000097          	auipc	ra,0x0
    80004a0c:	c68080e7          	jalr	-920(ra) # 80004670 <argfd>
    80004a10:	87aa                	mv	a5,a0
    return -1;
    80004a12:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004a14:	0007ca63          	bltz	a5,80004a28 <sys_fstat+0x3e>
  return filestat(f, st);
    80004a18:	fe043583          	ld	a1,-32(s0)
    80004a1c:	fe843503          	ld	a0,-24(s0)
    80004a20:	fffff097          	auipc	ra,0xfffff
    80004a24:	2d8080e7          	jalr	728(ra) # 80003cf8 <filestat>
}
    80004a28:	60e2                	ld	ra,24(sp)
    80004a2a:	6442                	ld	s0,16(sp)
    80004a2c:	6105                	addi	sp,sp,32
    80004a2e:	8082                	ret

0000000080004a30 <sys_link>:
{
    80004a30:	7169                	addi	sp,sp,-304
    80004a32:	f606                	sd	ra,296(sp)
    80004a34:	f222                	sd	s0,288(sp)
    80004a36:	ee26                	sd	s1,280(sp)
    80004a38:	ea4a                	sd	s2,272(sp)
    80004a3a:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004a3c:	08000613          	li	a2,128
    80004a40:	ed040593          	addi	a1,s0,-304
    80004a44:	4501                	li	a0,0
    80004a46:	ffffd097          	auipc	ra,0xffffd
    80004a4a:	744080e7          	jalr	1860(ra) # 8000218a <argstr>
    return -1;
    80004a4e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004a50:	10054e63          	bltz	a0,80004b6c <sys_link+0x13c>
    80004a54:	08000613          	li	a2,128
    80004a58:	f5040593          	addi	a1,s0,-176
    80004a5c:	4505                	li	a0,1
    80004a5e:	ffffd097          	auipc	ra,0xffffd
    80004a62:	72c080e7          	jalr	1836(ra) # 8000218a <argstr>
    return -1;
    80004a66:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004a68:	10054263          	bltz	a0,80004b6c <sys_link+0x13c>
  begin_op();
    80004a6c:	fffff097          	auipc	ra,0xfffff
    80004a70:	cf8080e7          	jalr	-776(ra) # 80003764 <begin_op>
  if((ip = namei(old)) == 0){
    80004a74:	ed040513          	addi	a0,s0,-304
    80004a78:	fffff097          	auipc	ra,0xfffff
    80004a7c:	ad0080e7          	jalr	-1328(ra) # 80003548 <namei>
    80004a80:	84aa                	mv	s1,a0
    80004a82:	c551                	beqz	a0,80004b0e <sys_link+0xde>
  ilock(ip);
    80004a84:	ffffe097          	auipc	ra,0xffffe
    80004a88:	31e080e7          	jalr	798(ra) # 80002da2 <ilock>
  if(ip->type == T_DIR){
    80004a8c:	04449703          	lh	a4,68(s1)
    80004a90:	4785                	li	a5,1
    80004a92:	08f70463          	beq	a4,a5,80004b1a <sys_link+0xea>
  ip->nlink++;
    80004a96:	04a4d783          	lhu	a5,74(s1)
    80004a9a:	2785                	addiw	a5,a5,1
    80004a9c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004aa0:	8526                	mv	a0,s1
    80004aa2:	ffffe097          	auipc	ra,0xffffe
    80004aa6:	236080e7          	jalr	566(ra) # 80002cd8 <iupdate>
  iunlock(ip);
    80004aaa:	8526                	mv	a0,s1
    80004aac:	ffffe097          	auipc	ra,0xffffe
    80004ab0:	3b8080e7          	jalr	952(ra) # 80002e64 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004ab4:	fd040593          	addi	a1,s0,-48
    80004ab8:	f5040513          	addi	a0,s0,-176
    80004abc:	fffff097          	auipc	ra,0xfffff
    80004ac0:	aaa080e7          	jalr	-1366(ra) # 80003566 <nameiparent>
    80004ac4:	892a                	mv	s2,a0
    80004ac6:	c935                	beqz	a0,80004b3a <sys_link+0x10a>
  ilock(dp);
    80004ac8:	ffffe097          	auipc	ra,0xffffe
    80004acc:	2da080e7          	jalr	730(ra) # 80002da2 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004ad0:	00092703          	lw	a4,0(s2)
    80004ad4:	409c                	lw	a5,0(s1)
    80004ad6:	04f71d63          	bne	a4,a5,80004b30 <sys_link+0x100>
    80004ada:	40d0                	lw	a2,4(s1)
    80004adc:	fd040593          	addi	a1,s0,-48
    80004ae0:	854a                	mv	a0,s2
    80004ae2:	fffff097          	auipc	ra,0xfffff
    80004ae6:	9b4080e7          	jalr	-1612(ra) # 80003496 <dirlink>
    80004aea:	04054363          	bltz	a0,80004b30 <sys_link+0x100>
  iunlockput(dp);
    80004aee:	854a                	mv	a0,s2
    80004af0:	ffffe097          	auipc	ra,0xffffe
    80004af4:	514080e7          	jalr	1300(ra) # 80003004 <iunlockput>
  iput(ip);
    80004af8:	8526                	mv	a0,s1
    80004afa:	ffffe097          	auipc	ra,0xffffe
    80004afe:	462080e7          	jalr	1122(ra) # 80002f5c <iput>
  end_op();
    80004b02:	fffff097          	auipc	ra,0xfffff
    80004b06:	ce2080e7          	jalr	-798(ra) # 800037e4 <end_op>
  return 0;
    80004b0a:	4781                	li	a5,0
    80004b0c:	a085                	j	80004b6c <sys_link+0x13c>
    end_op();
    80004b0e:	fffff097          	auipc	ra,0xfffff
    80004b12:	cd6080e7          	jalr	-810(ra) # 800037e4 <end_op>
    return -1;
    80004b16:	57fd                	li	a5,-1
    80004b18:	a891                	j	80004b6c <sys_link+0x13c>
    iunlockput(ip);
    80004b1a:	8526                	mv	a0,s1
    80004b1c:	ffffe097          	auipc	ra,0xffffe
    80004b20:	4e8080e7          	jalr	1256(ra) # 80003004 <iunlockput>
    end_op();
    80004b24:	fffff097          	auipc	ra,0xfffff
    80004b28:	cc0080e7          	jalr	-832(ra) # 800037e4 <end_op>
    return -1;
    80004b2c:	57fd                	li	a5,-1
    80004b2e:	a83d                	j	80004b6c <sys_link+0x13c>
    iunlockput(dp);
    80004b30:	854a                	mv	a0,s2
    80004b32:	ffffe097          	auipc	ra,0xffffe
    80004b36:	4d2080e7          	jalr	1234(ra) # 80003004 <iunlockput>
  ilock(ip);
    80004b3a:	8526                	mv	a0,s1
    80004b3c:	ffffe097          	auipc	ra,0xffffe
    80004b40:	266080e7          	jalr	614(ra) # 80002da2 <ilock>
  ip->nlink--;
    80004b44:	04a4d783          	lhu	a5,74(s1)
    80004b48:	37fd                	addiw	a5,a5,-1
    80004b4a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004b4e:	8526                	mv	a0,s1
    80004b50:	ffffe097          	auipc	ra,0xffffe
    80004b54:	188080e7          	jalr	392(ra) # 80002cd8 <iupdate>
  iunlockput(ip);
    80004b58:	8526                	mv	a0,s1
    80004b5a:	ffffe097          	auipc	ra,0xffffe
    80004b5e:	4aa080e7          	jalr	1194(ra) # 80003004 <iunlockput>
  end_op();
    80004b62:	fffff097          	auipc	ra,0xfffff
    80004b66:	c82080e7          	jalr	-894(ra) # 800037e4 <end_op>
  return -1;
    80004b6a:	57fd                	li	a5,-1
}
    80004b6c:	853e                	mv	a0,a5
    80004b6e:	70b2                	ld	ra,296(sp)
    80004b70:	7412                	ld	s0,288(sp)
    80004b72:	64f2                	ld	s1,280(sp)
    80004b74:	6952                	ld	s2,272(sp)
    80004b76:	6155                	addi	sp,sp,304
    80004b78:	8082                	ret

0000000080004b7a <sys_unlink>:
{
    80004b7a:	7151                	addi	sp,sp,-240
    80004b7c:	f586                	sd	ra,232(sp)
    80004b7e:	f1a2                	sd	s0,224(sp)
    80004b80:	eda6                	sd	s1,216(sp)
    80004b82:	e9ca                	sd	s2,208(sp)
    80004b84:	e5ce                	sd	s3,200(sp)
    80004b86:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004b88:	08000613          	li	a2,128
    80004b8c:	f3040593          	addi	a1,s0,-208
    80004b90:	4501                	li	a0,0
    80004b92:	ffffd097          	auipc	ra,0xffffd
    80004b96:	5f8080e7          	jalr	1528(ra) # 8000218a <argstr>
    80004b9a:	18054163          	bltz	a0,80004d1c <sys_unlink+0x1a2>
  begin_op();
    80004b9e:	fffff097          	auipc	ra,0xfffff
    80004ba2:	bc6080e7          	jalr	-1082(ra) # 80003764 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004ba6:	fb040593          	addi	a1,s0,-80
    80004baa:	f3040513          	addi	a0,s0,-208
    80004bae:	fffff097          	auipc	ra,0xfffff
    80004bb2:	9b8080e7          	jalr	-1608(ra) # 80003566 <nameiparent>
    80004bb6:	84aa                	mv	s1,a0
    80004bb8:	c979                	beqz	a0,80004c8e <sys_unlink+0x114>
  ilock(dp);
    80004bba:	ffffe097          	auipc	ra,0xffffe
    80004bbe:	1e8080e7          	jalr	488(ra) # 80002da2 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004bc2:	00004597          	auipc	a1,0x4
    80004bc6:	b2658593          	addi	a1,a1,-1242 # 800086e8 <syscalls+0x2e8>
    80004bca:	fb040513          	addi	a0,s0,-80
    80004bce:	ffffe097          	auipc	ra,0xffffe
    80004bd2:	69e080e7          	jalr	1694(ra) # 8000326c <namecmp>
    80004bd6:	14050a63          	beqz	a0,80004d2a <sys_unlink+0x1b0>
    80004bda:	00004597          	auipc	a1,0x4
    80004bde:	b1658593          	addi	a1,a1,-1258 # 800086f0 <syscalls+0x2f0>
    80004be2:	fb040513          	addi	a0,s0,-80
    80004be6:	ffffe097          	auipc	ra,0xffffe
    80004bea:	686080e7          	jalr	1670(ra) # 8000326c <namecmp>
    80004bee:	12050e63          	beqz	a0,80004d2a <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004bf2:	f2c40613          	addi	a2,s0,-212
    80004bf6:	fb040593          	addi	a1,s0,-80
    80004bfa:	8526                	mv	a0,s1
    80004bfc:	ffffe097          	auipc	ra,0xffffe
    80004c00:	68a080e7          	jalr	1674(ra) # 80003286 <dirlookup>
    80004c04:	892a                	mv	s2,a0
    80004c06:	12050263          	beqz	a0,80004d2a <sys_unlink+0x1b0>
  ilock(ip);
    80004c0a:	ffffe097          	auipc	ra,0xffffe
    80004c0e:	198080e7          	jalr	408(ra) # 80002da2 <ilock>
  if(ip->nlink < 1)
    80004c12:	04a91783          	lh	a5,74(s2)
    80004c16:	08f05263          	blez	a5,80004c9a <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004c1a:	04491703          	lh	a4,68(s2)
    80004c1e:	4785                	li	a5,1
    80004c20:	08f70563          	beq	a4,a5,80004caa <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80004c24:	4641                	li	a2,16
    80004c26:	4581                	li	a1,0
    80004c28:	fc040513          	addi	a0,s0,-64
    80004c2c:	ffffb097          	auipc	ra,0xffffb
    80004c30:	54c080e7          	jalr	1356(ra) # 80000178 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004c34:	4741                	li	a4,16
    80004c36:	f2c42683          	lw	a3,-212(s0)
    80004c3a:	fc040613          	addi	a2,s0,-64
    80004c3e:	4581                	li	a1,0
    80004c40:	8526                	mv	a0,s1
    80004c42:	ffffe097          	auipc	ra,0xffffe
    80004c46:	50c080e7          	jalr	1292(ra) # 8000314e <writei>
    80004c4a:	47c1                	li	a5,16
    80004c4c:	0af51563          	bne	a0,a5,80004cf6 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80004c50:	04491703          	lh	a4,68(s2)
    80004c54:	4785                	li	a5,1
    80004c56:	0af70863          	beq	a4,a5,80004d06 <sys_unlink+0x18c>
  iunlockput(dp);
    80004c5a:	8526                	mv	a0,s1
    80004c5c:	ffffe097          	auipc	ra,0xffffe
    80004c60:	3a8080e7          	jalr	936(ra) # 80003004 <iunlockput>
  ip->nlink--;
    80004c64:	04a95783          	lhu	a5,74(s2)
    80004c68:	37fd                	addiw	a5,a5,-1
    80004c6a:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004c6e:	854a                	mv	a0,s2
    80004c70:	ffffe097          	auipc	ra,0xffffe
    80004c74:	068080e7          	jalr	104(ra) # 80002cd8 <iupdate>
  iunlockput(ip);
    80004c78:	854a                	mv	a0,s2
    80004c7a:	ffffe097          	auipc	ra,0xffffe
    80004c7e:	38a080e7          	jalr	906(ra) # 80003004 <iunlockput>
  end_op();
    80004c82:	fffff097          	auipc	ra,0xfffff
    80004c86:	b62080e7          	jalr	-1182(ra) # 800037e4 <end_op>
  return 0;
    80004c8a:	4501                	li	a0,0
    80004c8c:	a84d                	j	80004d3e <sys_unlink+0x1c4>
    end_op();
    80004c8e:	fffff097          	auipc	ra,0xfffff
    80004c92:	b56080e7          	jalr	-1194(ra) # 800037e4 <end_op>
    return -1;
    80004c96:	557d                	li	a0,-1
    80004c98:	a05d                	j	80004d3e <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80004c9a:	00004517          	auipc	a0,0x4
    80004c9e:	a5e50513          	addi	a0,a0,-1442 # 800086f8 <syscalls+0x2f8>
    80004ca2:	00001097          	auipc	ra,0x1
    80004ca6:	210080e7          	jalr	528(ra) # 80005eb2 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004caa:	04c92703          	lw	a4,76(s2)
    80004cae:	02000793          	li	a5,32
    80004cb2:	f6e7f9e3          	bgeu	a5,a4,80004c24 <sys_unlink+0xaa>
    80004cb6:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004cba:	4741                	li	a4,16
    80004cbc:	86ce                	mv	a3,s3
    80004cbe:	f1840613          	addi	a2,s0,-232
    80004cc2:	4581                	li	a1,0
    80004cc4:	854a                	mv	a0,s2
    80004cc6:	ffffe097          	auipc	ra,0xffffe
    80004cca:	390080e7          	jalr	912(ra) # 80003056 <readi>
    80004cce:	47c1                	li	a5,16
    80004cd0:	00f51b63          	bne	a0,a5,80004ce6 <sys_unlink+0x16c>
    if(de.inum != 0)
    80004cd4:	f1845783          	lhu	a5,-232(s0)
    80004cd8:	e7a1                	bnez	a5,80004d20 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004cda:	29c1                	addiw	s3,s3,16
    80004cdc:	04c92783          	lw	a5,76(s2)
    80004ce0:	fcf9ede3          	bltu	s3,a5,80004cba <sys_unlink+0x140>
    80004ce4:	b781                	j	80004c24 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80004ce6:	00004517          	auipc	a0,0x4
    80004cea:	a2a50513          	addi	a0,a0,-1494 # 80008710 <syscalls+0x310>
    80004cee:	00001097          	auipc	ra,0x1
    80004cf2:	1c4080e7          	jalr	452(ra) # 80005eb2 <panic>
    panic("unlink: writei");
    80004cf6:	00004517          	auipc	a0,0x4
    80004cfa:	a3250513          	addi	a0,a0,-1486 # 80008728 <syscalls+0x328>
    80004cfe:	00001097          	auipc	ra,0x1
    80004d02:	1b4080e7          	jalr	436(ra) # 80005eb2 <panic>
    dp->nlink--;
    80004d06:	04a4d783          	lhu	a5,74(s1)
    80004d0a:	37fd                	addiw	a5,a5,-1
    80004d0c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004d10:	8526                	mv	a0,s1
    80004d12:	ffffe097          	auipc	ra,0xffffe
    80004d16:	fc6080e7          	jalr	-58(ra) # 80002cd8 <iupdate>
    80004d1a:	b781                	j	80004c5a <sys_unlink+0xe0>
    return -1;
    80004d1c:	557d                	li	a0,-1
    80004d1e:	a005                	j	80004d3e <sys_unlink+0x1c4>
    iunlockput(ip);
    80004d20:	854a                	mv	a0,s2
    80004d22:	ffffe097          	auipc	ra,0xffffe
    80004d26:	2e2080e7          	jalr	738(ra) # 80003004 <iunlockput>
  iunlockput(dp);
    80004d2a:	8526                	mv	a0,s1
    80004d2c:	ffffe097          	auipc	ra,0xffffe
    80004d30:	2d8080e7          	jalr	728(ra) # 80003004 <iunlockput>
  end_op();
    80004d34:	fffff097          	auipc	ra,0xfffff
    80004d38:	ab0080e7          	jalr	-1360(ra) # 800037e4 <end_op>
  return -1;
    80004d3c:	557d                	li	a0,-1
}
    80004d3e:	70ae                	ld	ra,232(sp)
    80004d40:	740e                	ld	s0,224(sp)
    80004d42:	64ee                	ld	s1,216(sp)
    80004d44:	694e                	ld	s2,208(sp)
    80004d46:	69ae                	ld	s3,200(sp)
    80004d48:	616d                	addi	sp,sp,240
    80004d4a:	8082                	ret

0000000080004d4c <sys_open>:

uint64
sys_open(void)
{
    80004d4c:	7131                	addi	sp,sp,-192
    80004d4e:	fd06                	sd	ra,184(sp)
    80004d50:	f922                	sd	s0,176(sp)
    80004d52:	f526                	sd	s1,168(sp)
    80004d54:	f14a                	sd	s2,160(sp)
    80004d56:	ed4e                	sd	s3,152(sp)
    80004d58:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80004d5a:	f4c40593          	addi	a1,s0,-180
    80004d5e:	4505                	li	a0,1
    80004d60:	ffffd097          	auipc	ra,0xffffd
    80004d64:	3ea080e7          	jalr	1002(ra) # 8000214a <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004d68:	08000613          	li	a2,128
    80004d6c:	f5040593          	addi	a1,s0,-176
    80004d70:	4501                	li	a0,0
    80004d72:	ffffd097          	auipc	ra,0xffffd
    80004d76:	418080e7          	jalr	1048(ra) # 8000218a <argstr>
    80004d7a:	87aa                	mv	a5,a0
    return -1;
    80004d7c:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004d7e:	0a07c963          	bltz	a5,80004e30 <sys_open+0xe4>

  begin_op();
    80004d82:	fffff097          	auipc	ra,0xfffff
    80004d86:	9e2080e7          	jalr	-1566(ra) # 80003764 <begin_op>

  if(omode & O_CREATE){
    80004d8a:	f4c42783          	lw	a5,-180(s0)
    80004d8e:	2007f793          	andi	a5,a5,512
    80004d92:	cfc5                	beqz	a5,80004e4a <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80004d94:	4681                	li	a3,0
    80004d96:	4601                	li	a2,0
    80004d98:	4589                	li	a1,2
    80004d9a:	f5040513          	addi	a0,s0,-176
    80004d9e:	00000097          	auipc	ra,0x0
    80004da2:	974080e7          	jalr	-1676(ra) # 80004712 <create>
    80004da6:	84aa                	mv	s1,a0
    if(ip == 0){
    80004da8:	c959                	beqz	a0,80004e3e <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80004daa:	04449703          	lh	a4,68(s1)
    80004dae:	478d                	li	a5,3
    80004db0:	00f71763          	bne	a4,a5,80004dbe <sys_open+0x72>
    80004db4:	0464d703          	lhu	a4,70(s1)
    80004db8:	47a5                	li	a5,9
    80004dba:	0ce7ed63          	bltu	a5,a4,80004e94 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004dbe:	fffff097          	auipc	ra,0xfffff
    80004dc2:	db6080e7          	jalr	-586(ra) # 80003b74 <filealloc>
    80004dc6:	89aa                	mv	s3,a0
    80004dc8:	10050363          	beqz	a0,80004ece <sys_open+0x182>
    80004dcc:	00000097          	auipc	ra,0x0
    80004dd0:	904080e7          	jalr	-1788(ra) # 800046d0 <fdalloc>
    80004dd4:	892a                	mv	s2,a0
    80004dd6:	0e054763          	bltz	a0,80004ec4 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80004dda:	04449703          	lh	a4,68(s1)
    80004dde:	478d                	li	a5,3
    80004de0:	0cf70563          	beq	a4,a5,80004eaa <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004de4:	4789                	li	a5,2
    80004de6:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80004dea:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80004dee:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80004df2:	f4c42783          	lw	a5,-180(s0)
    80004df6:	0017c713          	xori	a4,a5,1
    80004dfa:	8b05                	andi	a4,a4,1
    80004dfc:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004e00:	0037f713          	andi	a4,a5,3
    80004e04:	00e03733          	snez	a4,a4
    80004e08:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80004e0c:	4007f793          	andi	a5,a5,1024
    80004e10:	c791                	beqz	a5,80004e1c <sys_open+0xd0>
    80004e12:	04449703          	lh	a4,68(s1)
    80004e16:	4789                	li	a5,2
    80004e18:	0af70063          	beq	a4,a5,80004eb8 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80004e1c:	8526                	mv	a0,s1
    80004e1e:	ffffe097          	auipc	ra,0xffffe
    80004e22:	046080e7          	jalr	70(ra) # 80002e64 <iunlock>
  end_op();
    80004e26:	fffff097          	auipc	ra,0xfffff
    80004e2a:	9be080e7          	jalr	-1602(ra) # 800037e4 <end_op>

  return fd;
    80004e2e:	854a                	mv	a0,s2
}
    80004e30:	70ea                	ld	ra,184(sp)
    80004e32:	744a                	ld	s0,176(sp)
    80004e34:	74aa                	ld	s1,168(sp)
    80004e36:	790a                	ld	s2,160(sp)
    80004e38:	69ea                	ld	s3,152(sp)
    80004e3a:	6129                	addi	sp,sp,192
    80004e3c:	8082                	ret
      end_op();
    80004e3e:	fffff097          	auipc	ra,0xfffff
    80004e42:	9a6080e7          	jalr	-1626(ra) # 800037e4 <end_op>
      return -1;
    80004e46:	557d                	li	a0,-1
    80004e48:	b7e5                	j	80004e30 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80004e4a:	f5040513          	addi	a0,s0,-176
    80004e4e:	ffffe097          	auipc	ra,0xffffe
    80004e52:	6fa080e7          	jalr	1786(ra) # 80003548 <namei>
    80004e56:	84aa                	mv	s1,a0
    80004e58:	c905                	beqz	a0,80004e88 <sys_open+0x13c>
    ilock(ip);
    80004e5a:	ffffe097          	auipc	ra,0xffffe
    80004e5e:	f48080e7          	jalr	-184(ra) # 80002da2 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80004e62:	04449703          	lh	a4,68(s1)
    80004e66:	4785                	li	a5,1
    80004e68:	f4f711e3          	bne	a4,a5,80004daa <sys_open+0x5e>
    80004e6c:	f4c42783          	lw	a5,-180(s0)
    80004e70:	d7b9                	beqz	a5,80004dbe <sys_open+0x72>
      iunlockput(ip);
    80004e72:	8526                	mv	a0,s1
    80004e74:	ffffe097          	auipc	ra,0xffffe
    80004e78:	190080e7          	jalr	400(ra) # 80003004 <iunlockput>
      end_op();
    80004e7c:	fffff097          	auipc	ra,0xfffff
    80004e80:	968080e7          	jalr	-1688(ra) # 800037e4 <end_op>
      return -1;
    80004e84:	557d                	li	a0,-1
    80004e86:	b76d                	j	80004e30 <sys_open+0xe4>
      end_op();
    80004e88:	fffff097          	auipc	ra,0xfffff
    80004e8c:	95c080e7          	jalr	-1700(ra) # 800037e4 <end_op>
      return -1;
    80004e90:	557d                	li	a0,-1
    80004e92:	bf79                	j	80004e30 <sys_open+0xe4>
    iunlockput(ip);
    80004e94:	8526                	mv	a0,s1
    80004e96:	ffffe097          	auipc	ra,0xffffe
    80004e9a:	16e080e7          	jalr	366(ra) # 80003004 <iunlockput>
    end_op();
    80004e9e:	fffff097          	auipc	ra,0xfffff
    80004ea2:	946080e7          	jalr	-1722(ra) # 800037e4 <end_op>
    return -1;
    80004ea6:	557d                	li	a0,-1
    80004ea8:	b761                	j	80004e30 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80004eaa:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80004eae:	04649783          	lh	a5,70(s1)
    80004eb2:	02f99223          	sh	a5,36(s3)
    80004eb6:	bf25                	j	80004dee <sys_open+0xa2>
    itrunc(ip);
    80004eb8:	8526                	mv	a0,s1
    80004eba:	ffffe097          	auipc	ra,0xffffe
    80004ebe:	ff6080e7          	jalr	-10(ra) # 80002eb0 <itrunc>
    80004ec2:	bfa9                	j	80004e1c <sys_open+0xd0>
      fileclose(f);
    80004ec4:	854e                	mv	a0,s3
    80004ec6:	fffff097          	auipc	ra,0xfffff
    80004eca:	d6a080e7          	jalr	-662(ra) # 80003c30 <fileclose>
    iunlockput(ip);
    80004ece:	8526                	mv	a0,s1
    80004ed0:	ffffe097          	auipc	ra,0xffffe
    80004ed4:	134080e7          	jalr	308(ra) # 80003004 <iunlockput>
    end_op();
    80004ed8:	fffff097          	auipc	ra,0xfffff
    80004edc:	90c080e7          	jalr	-1780(ra) # 800037e4 <end_op>
    return -1;
    80004ee0:	557d                	li	a0,-1
    80004ee2:	b7b9                	j	80004e30 <sys_open+0xe4>

0000000080004ee4 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80004ee4:	7175                	addi	sp,sp,-144
    80004ee6:	e506                	sd	ra,136(sp)
    80004ee8:	e122                	sd	s0,128(sp)
    80004eea:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80004eec:	fffff097          	auipc	ra,0xfffff
    80004ef0:	878080e7          	jalr	-1928(ra) # 80003764 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80004ef4:	08000613          	li	a2,128
    80004ef8:	f7040593          	addi	a1,s0,-144
    80004efc:	4501                	li	a0,0
    80004efe:	ffffd097          	auipc	ra,0xffffd
    80004f02:	28c080e7          	jalr	652(ra) # 8000218a <argstr>
    80004f06:	02054963          	bltz	a0,80004f38 <sys_mkdir+0x54>
    80004f0a:	4681                	li	a3,0
    80004f0c:	4601                	li	a2,0
    80004f0e:	4585                	li	a1,1
    80004f10:	f7040513          	addi	a0,s0,-144
    80004f14:	fffff097          	auipc	ra,0xfffff
    80004f18:	7fe080e7          	jalr	2046(ra) # 80004712 <create>
    80004f1c:	cd11                	beqz	a0,80004f38 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004f1e:	ffffe097          	auipc	ra,0xffffe
    80004f22:	0e6080e7          	jalr	230(ra) # 80003004 <iunlockput>
  end_op();
    80004f26:	fffff097          	auipc	ra,0xfffff
    80004f2a:	8be080e7          	jalr	-1858(ra) # 800037e4 <end_op>
  return 0;
    80004f2e:	4501                	li	a0,0
}
    80004f30:	60aa                	ld	ra,136(sp)
    80004f32:	640a                	ld	s0,128(sp)
    80004f34:	6149                	addi	sp,sp,144
    80004f36:	8082                	ret
    end_op();
    80004f38:	fffff097          	auipc	ra,0xfffff
    80004f3c:	8ac080e7          	jalr	-1876(ra) # 800037e4 <end_op>
    return -1;
    80004f40:	557d                	li	a0,-1
    80004f42:	b7fd                	j	80004f30 <sys_mkdir+0x4c>

0000000080004f44 <sys_mknod>:

uint64
sys_mknod(void)
{
    80004f44:	7135                	addi	sp,sp,-160
    80004f46:	ed06                	sd	ra,152(sp)
    80004f48:	e922                	sd	s0,144(sp)
    80004f4a:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80004f4c:	fffff097          	auipc	ra,0xfffff
    80004f50:	818080e7          	jalr	-2024(ra) # 80003764 <begin_op>
  argint(1, &major);
    80004f54:	f6c40593          	addi	a1,s0,-148
    80004f58:	4505                	li	a0,1
    80004f5a:	ffffd097          	auipc	ra,0xffffd
    80004f5e:	1f0080e7          	jalr	496(ra) # 8000214a <argint>
  argint(2, &minor);
    80004f62:	f6840593          	addi	a1,s0,-152
    80004f66:	4509                	li	a0,2
    80004f68:	ffffd097          	auipc	ra,0xffffd
    80004f6c:	1e2080e7          	jalr	482(ra) # 8000214a <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004f70:	08000613          	li	a2,128
    80004f74:	f7040593          	addi	a1,s0,-144
    80004f78:	4501                	li	a0,0
    80004f7a:	ffffd097          	auipc	ra,0xffffd
    80004f7e:	210080e7          	jalr	528(ra) # 8000218a <argstr>
    80004f82:	02054b63          	bltz	a0,80004fb8 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80004f86:	f6841683          	lh	a3,-152(s0)
    80004f8a:	f6c41603          	lh	a2,-148(s0)
    80004f8e:	458d                	li	a1,3
    80004f90:	f7040513          	addi	a0,s0,-144
    80004f94:	fffff097          	auipc	ra,0xfffff
    80004f98:	77e080e7          	jalr	1918(ra) # 80004712 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004f9c:	cd11                	beqz	a0,80004fb8 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004f9e:	ffffe097          	auipc	ra,0xffffe
    80004fa2:	066080e7          	jalr	102(ra) # 80003004 <iunlockput>
  end_op();
    80004fa6:	fffff097          	auipc	ra,0xfffff
    80004faa:	83e080e7          	jalr	-1986(ra) # 800037e4 <end_op>
  return 0;
    80004fae:	4501                	li	a0,0
}
    80004fb0:	60ea                	ld	ra,152(sp)
    80004fb2:	644a                	ld	s0,144(sp)
    80004fb4:	610d                	addi	sp,sp,160
    80004fb6:	8082                	ret
    end_op();
    80004fb8:	fffff097          	auipc	ra,0xfffff
    80004fbc:	82c080e7          	jalr	-2004(ra) # 800037e4 <end_op>
    return -1;
    80004fc0:	557d                	li	a0,-1
    80004fc2:	b7fd                	j	80004fb0 <sys_mknod+0x6c>

0000000080004fc4 <sys_chdir>:

uint64
sys_chdir(void)
{
    80004fc4:	7135                	addi	sp,sp,-160
    80004fc6:	ed06                	sd	ra,152(sp)
    80004fc8:	e922                	sd	s0,144(sp)
    80004fca:	e526                	sd	s1,136(sp)
    80004fcc:	e14a                	sd	s2,128(sp)
    80004fce:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80004fd0:	ffffc097          	auipc	ra,0xffffc
    80004fd4:	f64080e7          	jalr	-156(ra) # 80000f34 <myproc>
    80004fd8:	892a                	mv	s2,a0
  
  begin_op();
    80004fda:	ffffe097          	auipc	ra,0xffffe
    80004fde:	78a080e7          	jalr	1930(ra) # 80003764 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80004fe2:	08000613          	li	a2,128
    80004fe6:	f6040593          	addi	a1,s0,-160
    80004fea:	4501                	li	a0,0
    80004fec:	ffffd097          	auipc	ra,0xffffd
    80004ff0:	19e080e7          	jalr	414(ra) # 8000218a <argstr>
    80004ff4:	04054b63          	bltz	a0,8000504a <sys_chdir+0x86>
    80004ff8:	f6040513          	addi	a0,s0,-160
    80004ffc:	ffffe097          	auipc	ra,0xffffe
    80005000:	54c080e7          	jalr	1356(ra) # 80003548 <namei>
    80005004:	84aa                	mv	s1,a0
    80005006:	c131                	beqz	a0,8000504a <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005008:	ffffe097          	auipc	ra,0xffffe
    8000500c:	d9a080e7          	jalr	-614(ra) # 80002da2 <ilock>
  if(ip->type != T_DIR){
    80005010:	04449703          	lh	a4,68(s1)
    80005014:	4785                	li	a5,1
    80005016:	04f71063          	bne	a4,a5,80005056 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000501a:	8526                	mv	a0,s1
    8000501c:	ffffe097          	auipc	ra,0xffffe
    80005020:	e48080e7          	jalr	-440(ra) # 80002e64 <iunlock>
  iput(p->cwd);
    80005024:	15093503          	ld	a0,336(s2)
    80005028:	ffffe097          	auipc	ra,0xffffe
    8000502c:	f34080e7          	jalr	-204(ra) # 80002f5c <iput>
  end_op();
    80005030:	ffffe097          	auipc	ra,0xffffe
    80005034:	7b4080e7          	jalr	1972(ra) # 800037e4 <end_op>
  p->cwd = ip;
    80005038:	14993823          	sd	s1,336(s2)
  return 0;
    8000503c:	4501                	li	a0,0
}
    8000503e:	60ea                	ld	ra,152(sp)
    80005040:	644a                	ld	s0,144(sp)
    80005042:	64aa                	ld	s1,136(sp)
    80005044:	690a                	ld	s2,128(sp)
    80005046:	610d                	addi	sp,sp,160
    80005048:	8082                	ret
    end_op();
    8000504a:	ffffe097          	auipc	ra,0xffffe
    8000504e:	79a080e7          	jalr	1946(ra) # 800037e4 <end_op>
    return -1;
    80005052:	557d                	li	a0,-1
    80005054:	b7ed                	j	8000503e <sys_chdir+0x7a>
    iunlockput(ip);
    80005056:	8526                	mv	a0,s1
    80005058:	ffffe097          	auipc	ra,0xffffe
    8000505c:	fac080e7          	jalr	-84(ra) # 80003004 <iunlockput>
    end_op();
    80005060:	ffffe097          	auipc	ra,0xffffe
    80005064:	784080e7          	jalr	1924(ra) # 800037e4 <end_op>
    return -1;
    80005068:	557d                	li	a0,-1
    8000506a:	bfd1                	j	8000503e <sys_chdir+0x7a>

000000008000506c <sys_exec>:

uint64
sys_exec(void)
{
    8000506c:	7145                	addi	sp,sp,-464
    8000506e:	e786                	sd	ra,456(sp)
    80005070:	e3a2                	sd	s0,448(sp)
    80005072:	ff26                	sd	s1,440(sp)
    80005074:	fb4a                	sd	s2,432(sp)
    80005076:	f74e                	sd	s3,424(sp)
    80005078:	f352                	sd	s4,416(sp)
    8000507a:	ef56                	sd	s5,408(sp)
    8000507c:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    8000507e:	e3840593          	addi	a1,s0,-456
    80005082:	4505                	li	a0,1
    80005084:	ffffd097          	auipc	ra,0xffffd
    80005088:	0e6080e7          	jalr	230(ra) # 8000216a <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    8000508c:	08000613          	li	a2,128
    80005090:	f4040593          	addi	a1,s0,-192
    80005094:	4501                	li	a0,0
    80005096:	ffffd097          	auipc	ra,0xffffd
    8000509a:	0f4080e7          	jalr	244(ra) # 8000218a <argstr>
    8000509e:	87aa                	mv	a5,a0
    return -1;
    800050a0:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800050a2:	0c07c263          	bltz	a5,80005166 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    800050a6:	10000613          	li	a2,256
    800050aa:	4581                	li	a1,0
    800050ac:	e4040513          	addi	a0,s0,-448
    800050b0:	ffffb097          	auipc	ra,0xffffb
    800050b4:	0c8080e7          	jalr	200(ra) # 80000178 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800050b8:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    800050bc:	89a6                	mv	s3,s1
    800050be:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800050c0:	02000a13          	li	s4,32
    800050c4:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800050c8:	00391513          	slli	a0,s2,0x3
    800050cc:	e3040593          	addi	a1,s0,-464
    800050d0:	e3843783          	ld	a5,-456(s0)
    800050d4:	953e                	add	a0,a0,a5
    800050d6:	ffffd097          	auipc	ra,0xffffd
    800050da:	fd6080e7          	jalr	-42(ra) # 800020ac <fetchaddr>
    800050de:	02054a63          	bltz	a0,80005112 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    800050e2:	e3043783          	ld	a5,-464(s0)
    800050e6:	c3b9                	beqz	a5,8000512c <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800050e8:	ffffb097          	auipc	ra,0xffffb
    800050ec:	030080e7          	jalr	48(ra) # 80000118 <kalloc>
    800050f0:	85aa                	mv	a1,a0
    800050f2:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800050f6:	cd11                	beqz	a0,80005112 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800050f8:	6605                	lui	a2,0x1
    800050fa:	e3043503          	ld	a0,-464(s0)
    800050fe:	ffffd097          	auipc	ra,0xffffd
    80005102:	000080e7          	jalr	ra # 800020fe <fetchstr>
    80005106:	00054663          	bltz	a0,80005112 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    8000510a:	0905                	addi	s2,s2,1
    8000510c:	09a1                	addi	s3,s3,8
    8000510e:	fb491be3          	bne	s2,s4,800050c4 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005112:	10048913          	addi	s2,s1,256
    80005116:	6088                	ld	a0,0(s1)
    80005118:	c531                	beqz	a0,80005164 <sys_exec+0xf8>
    kfree(argv[i]);
    8000511a:	ffffb097          	auipc	ra,0xffffb
    8000511e:	f02080e7          	jalr	-254(ra) # 8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005122:	04a1                	addi	s1,s1,8
    80005124:	ff2499e3          	bne	s1,s2,80005116 <sys_exec+0xaa>
  return -1;
    80005128:	557d                	li	a0,-1
    8000512a:	a835                	j	80005166 <sys_exec+0xfa>
      argv[i] = 0;
    8000512c:	0a8e                	slli	s5,s5,0x3
    8000512e:	fc040793          	addi	a5,s0,-64
    80005132:	9abe                	add	s5,s5,a5
    80005134:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005138:	e4040593          	addi	a1,s0,-448
    8000513c:	f4040513          	addi	a0,s0,-192
    80005140:	fffff097          	auipc	ra,0xfffff
    80005144:	178080e7          	jalr	376(ra) # 800042b8 <exec>
    80005148:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000514a:	10048993          	addi	s3,s1,256
    8000514e:	6088                	ld	a0,0(s1)
    80005150:	c901                	beqz	a0,80005160 <sys_exec+0xf4>
    kfree(argv[i]);
    80005152:	ffffb097          	auipc	ra,0xffffb
    80005156:	eca080e7          	jalr	-310(ra) # 8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000515a:	04a1                	addi	s1,s1,8
    8000515c:	ff3499e3          	bne	s1,s3,8000514e <sys_exec+0xe2>
  return ret;
    80005160:	854a                	mv	a0,s2
    80005162:	a011                	j	80005166 <sys_exec+0xfa>
  return -1;
    80005164:	557d                	li	a0,-1
}
    80005166:	60be                	ld	ra,456(sp)
    80005168:	641e                	ld	s0,448(sp)
    8000516a:	74fa                	ld	s1,440(sp)
    8000516c:	795a                	ld	s2,432(sp)
    8000516e:	79ba                	ld	s3,424(sp)
    80005170:	7a1a                	ld	s4,416(sp)
    80005172:	6afa                	ld	s5,408(sp)
    80005174:	6179                	addi	sp,sp,464
    80005176:	8082                	ret

0000000080005178 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005178:	7139                	addi	sp,sp,-64
    8000517a:	fc06                	sd	ra,56(sp)
    8000517c:	f822                	sd	s0,48(sp)
    8000517e:	f426                	sd	s1,40(sp)
    80005180:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005182:	ffffc097          	auipc	ra,0xffffc
    80005186:	db2080e7          	jalr	-590(ra) # 80000f34 <myproc>
    8000518a:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    8000518c:	fd840593          	addi	a1,s0,-40
    80005190:	4501                	li	a0,0
    80005192:	ffffd097          	auipc	ra,0xffffd
    80005196:	fd8080e7          	jalr	-40(ra) # 8000216a <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    8000519a:	fc840593          	addi	a1,s0,-56
    8000519e:	fd040513          	addi	a0,s0,-48
    800051a2:	fffff097          	auipc	ra,0xfffff
    800051a6:	dbe080e7          	jalr	-578(ra) # 80003f60 <pipealloc>
    return -1;
    800051aa:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800051ac:	0c054463          	bltz	a0,80005274 <sys_pipe+0xfc>
  fd0 = -1;
    800051b0:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800051b4:	fd043503          	ld	a0,-48(s0)
    800051b8:	fffff097          	auipc	ra,0xfffff
    800051bc:	518080e7          	jalr	1304(ra) # 800046d0 <fdalloc>
    800051c0:	fca42223          	sw	a0,-60(s0)
    800051c4:	08054b63          	bltz	a0,8000525a <sys_pipe+0xe2>
    800051c8:	fc843503          	ld	a0,-56(s0)
    800051cc:	fffff097          	auipc	ra,0xfffff
    800051d0:	504080e7          	jalr	1284(ra) # 800046d0 <fdalloc>
    800051d4:	fca42023          	sw	a0,-64(s0)
    800051d8:	06054863          	bltz	a0,80005248 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800051dc:	4691                	li	a3,4
    800051de:	fc440613          	addi	a2,s0,-60
    800051e2:	fd843583          	ld	a1,-40(s0)
    800051e6:	68a8                	ld	a0,80(s1)
    800051e8:	ffffc097          	auipc	ra,0xffffc
    800051ec:	a0e080e7          	jalr	-1522(ra) # 80000bf6 <copyout>
    800051f0:	02054063          	bltz	a0,80005210 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800051f4:	4691                	li	a3,4
    800051f6:	fc040613          	addi	a2,s0,-64
    800051fa:	fd843583          	ld	a1,-40(s0)
    800051fe:	0591                	addi	a1,a1,4
    80005200:	68a8                	ld	a0,80(s1)
    80005202:	ffffc097          	auipc	ra,0xffffc
    80005206:	9f4080e7          	jalr	-1548(ra) # 80000bf6 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000520a:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000520c:	06055463          	bgez	a0,80005274 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005210:	fc442783          	lw	a5,-60(s0)
    80005214:	07e9                	addi	a5,a5,26
    80005216:	078e                	slli	a5,a5,0x3
    80005218:	97a6                	add	a5,a5,s1
    8000521a:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    8000521e:	fc042503          	lw	a0,-64(s0)
    80005222:	0569                	addi	a0,a0,26
    80005224:	050e                	slli	a0,a0,0x3
    80005226:	94aa                	add	s1,s1,a0
    80005228:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    8000522c:	fd043503          	ld	a0,-48(s0)
    80005230:	fffff097          	auipc	ra,0xfffff
    80005234:	a00080e7          	jalr	-1536(ra) # 80003c30 <fileclose>
    fileclose(wf);
    80005238:	fc843503          	ld	a0,-56(s0)
    8000523c:	fffff097          	auipc	ra,0xfffff
    80005240:	9f4080e7          	jalr	-1548(ra) # 80003c30 <fileclose>
    return -1;
    80005244:	57fd                	li	a5,-1
    80005246:	a03d                	j	80005274 <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005248:	fc442783          	lw	a5,-60(s0)
    8000524c:	0007c763          	bltz	a5,8000525a <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005250:	07e9                	addi	a5,a5,26
    80005252:	078e                	slli	a5,a5,0x3
    80005254:	94be                	add	s1,s1,a5
    80005256:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    8000525a:	fd043503          	ld	a0,-48(s0)
    8000525e:	fffff097          	auipc	ra,0xfffff
    80005262:	9d2080e7          	jalr	-1582(ra) # 80003c30 <fileclose>
    fileclose(wf);
    80005266:	fc843503          	ld	a0,-56(s0)
    8000526a:	fffff097          	auipc	ra,0xfffff
    8000526e:	9c6080e7          	jalr	-1594(ra) # 80003c30 <fileclose>
    return -1;
    80005272:	57fd                	li	a5,-1
}
    80005274:	853e                	mv	a0,a5
    80005276:	70e2                	ld	ra,56(sp)
    80005278:	7442                	ld	s0,48(sp)
    8000527a:	74a2                	ld	s1,40(sp)
    8000527c:	6121                	addi	sp,sp,64
    8000527e:	8082                	ret

0000000080005280 <kernelvec>:
    80005280:	7111                	addi	sp,sp,-256
    80005282:	e006                	sd	ra,0(sp)
    80005284:	e40a                	sd	sp,8(sp)
    80005286:	e80e                	sd	gp,16(sp)
    80005288:	ec12                	sd	tp,24(sp)
    8000528a:	f016                	sd	t0,32(sp)
    8000528c:	f41a                	sd	t1,40(sp)
    8000528e:	f81e                	sd	t2,48(sp)
    80005290:	fc22                	sd	s0,56(sp)
    80005292:	e0a6                	sd	s1,64(sp)
    80005294:	e4aa                	sd	a0,72(sp)
    80005296:	e8ae                	sd	a1,80(sp)
    80005298:	ecb2                	sd	a2,88(sp)
    8000529a:	f0b6                	sd	a3,96(sp)
    8000529c:	f4ba                	sd	a4,104(sp)
    8000529e:	f8be                	sd	a5,112(sp)
    800052a0:	fcc2                	sd	a6,120(sp)
    800052a2:	e146                	sd	a7,128(sp)
    800052a4:	e54a                	sd	s2,136(sp)
    800052a6:	e94e                	sd	s3,144(sp)
    800052a8:	ed52                	sd	s4,152(sp)
    800052aa:	f156                	sd	s5,160(sp)
    800052ac:	f55a                	sd	s6,168(sp)
    800052ae:	f95e                	sd	s7,176(sp)
    800052b0:	fd62                	sd	s8,184(sp)
    800052b2:	e1e6                	sd	s9,192(sp)
    800052b4:	e5ea                	sd	s10,200(sp)
    800052b6:	e9ee                	sd	s11,208(sp)
    800052b8:	edf2                	sd	t3,216(sp)
    800052ba:	f1f6                	sd	t4,224(sp)
    800052bc:	f5fa                	sd	t5,232(sp)
    800052be:	f9fe                	sd	t6,240(sp)
    800052c0:	cb9fc0ef          	jal	ra,80001f78 <kerneltrap>
    800052c4:	6082                	ld	ra,0(sp)
    800052c6:	6122                	ld	sp,8(sp)
    800052c8:	61c2                	ld	gp,16(sp)
    800052ca:	7282                	ld	t0,32(sp)
    800052cc:	7322                	ld	t1,40(sp)
    800052ce:	73c2                	ld	t2,48(sp)
    800052d0:	7462                	ld	s0,56(sp)
    800052d2:	6486                	ld	s1,64(sp)
    800052d4:	6526                	ld	a0,72(sp)
    800052d6:	65c6                	ld	a1,80(sp)
    800052d8:	6666                	ld	a2,88(sp)
    800052da:	7686                	ld	a3,96(sp)
    800052dc:	7726                	ld	a4,104(sp)
    800052de:	77c6                	ld	a5,112(sp)
    800052e0:	7866                	ld	a6,120(sp)
    800052e2:	688a                	ld	a7,128(sp)
    800052e4:	692a                	ld	s2,136(sp)
    800052e6:	69ca                	ld	s3,144(sp)
    800052e8:	6a6a                	ld	s4,152(sp)
    800052ea:	7a8a                	ld	s5,160(sp)
    800052ec:	7b2a                	ld	s6,168(sp)
    800052ee:	7bca                	ld	s7,176(sp)
    800052f0:	7c6a                	ld	s8,184(sp)
    800052f2:	6c8e                	ld	s9,192(sp)
    800052f4:	6d2e                	ld	s10,200(sp)
    800052f6:	6dce                	ld	s11,208(sp)
    800052f8:	6e6e                	ld	t3,216(sp)
    800052fa:	7e8e                	ld	t4,224(sp)
    800052fc:	7f2e                	ld	t5,232(sp)
    800052fe:	7fce                	ld	t6,240(sp)
    80005300:	6111                	addi	sp,sp,256
    80005302:	10200073          	sret
    80005306:	00000013          	nop
    8000530a:	00000013          	nop
    8000530e:	0001                	nop

0000000080005310 <timervec>:
    80005310:	34051573          	csrrw	a0,mscratch,a0
    80005314:	e10c                	sd	a1,0(a0)
    80005316:	e510                	sd	a2,8(a0)
    80005318:	e914                	sd	a3,16(a0)
    8000531a:	6d0c                	ld	a1,24(a0)
    8000531c:	7110                	ld	a2,32(a0)
    8000531e:	6194                	ld	a3,0(a1)
    80005320:	96b2                	add	a3,a3,a2
    80005322:	e194                	sd	a3,0(a1)
    80005324:	4589                	li	a1,2
    80005326:	14459073          	csrw	sip,a1
    8000532a:	6914                	ld	a3,16(a0)
    8000532c:	6510                	ld	a2,8(a0)
    8000532e:	610c                	ld	a1,0(a0)
    80005330:	34051573          	csrrw	a0,mscratch,a0
    80005334:	30200073          	mret
	...

000000008000533a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000533a:	1141                	addi	sp,sp,-16
    8000533c:	e422                	sd	s0,8(sp)
    8000533e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005340:	0c0007b7          	lui	a5,0xc000
    80005344:	4705                	li	a4,1
    80005346:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005348:	c3d8                	sw	a4,4(a5)
}
    8000534a:	6422                	ld	s0,8(sp)
    8000534c:	0141                	addi	sp,sp,16
    8000534e:	8082                	ret

0000000080005350 <plicinithart>:

void
plicinithart(void)
{
    80005350:	1141                	addi	sp,sp,-16
    80005352:	e406                	sd	ra,8(sp)
    80005354:	e022                	sd	s0,0(sp)
    80005356:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005358:	ffffc097          	auipc	ra,0xffffc
    8000535c:	bb0080e7          	jalr	-1104(ra) # 80000f08 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005360:	0085171b          	slliw	a4,a0,0x8
    80005364:	0c0027b7          	lui	a5,0xc002
    80005368:	97ba                	add	a5,a5,a4
    8000536a:	40200713          	li	a4,1026
    8000536e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005372:	00d5151b          	slliw	a0,a0,0xd
    80005376:	0c2017b7          	lui	a5,0xc201
    8000537a:	953e                	add	a0,a0,a5
    8000537c:	00052023          	sw	zero,0(a0)
}
    80005380:	60a2                	ld	ra,8(sp)
    80005382:	6402                	ld	s0,0(sp)
    80005384:	0141                	addi	sp,sp,16
    80005386:	8082                	ret

0000000080005388 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005388:	1141                	addi	sp,sp,-16
    8000538a:	e406                	sd	ra,8(sp)
    8000538c:	e022                	sd	s0,0(sp)
    8000538e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005390:	ffffc097          	auipc	ra,0xffffc
    80005394:	b78080e7          	jalr	-1160(ra) # 80000f08 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005398:	00d5179b          	slliw	a5,a0,0xd
    8000539c:	0c201537          	lui	a0,0xc201
    800053a0:	953e                	add	a0,a0,a5
  return irq;
}
    800053a2:	4148                	lw	a0,4(a0)
    800053a4:	60a2                	ld	ra,8(sp)
    800053a6:	6402                	ld	s0,0(sp)
    800053a8:	0141                	addi	sp,sp,16
    800053aa:	8082                	ret

00000000800053ac <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800053ac:	1101                	addi	sp,sp,-32
    800053ae:	ec06                	sd	ra,24(sp)
    800053b0:	e822                	sd	s0,16(sp)
    800053b2:	e426                	sd	s1,8(sp)
    800053b4:	1000                	addi	s0,sp,32
    800053b6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800053b8:	ffffc097          	auipc	ra,0xffffc
    800053bc:	b50080e7          	jalr	-1200(ra) # 80000f08 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800053c0:	00d5151b          	slliw	a0,a0,0xd
    800053c4:	0c2017b7          	lui	a5,0xc201
    800053c8:	97aa                	add	a5,a5,a0
    800053ca:	c3c4                	sw	s1,4(a5)
}
    800053cc:	60e2                	ld	ra,24(sp)
    800053ce:	6442                	ld	s0,16(sp)
    800053d0:	64a2                	ld	s1,8(sp)
    800053d2:	6105                	addi	sp,sp,32
    800053d4:	8082                	ret

00000000800053d6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800053d6:	1141                	addi	sp,sp,-16
    800053d8:	e406                	sd	ra,8(sp)
    800053da:	e022                	sd	s0,0(sp)
    800053dc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800053de:	479d                	li	a5,7
    800053e0:	04a7cc63          	blt	a5,a0,80005438 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    800053e4:	00014797          	auipc	a5,0x14
    800053e8:	66c78793          	addi	a5,a5,1644 # 80019a50 <disk>
    800053ec:	97aa                	add	a5,a5,a0
    800053ee:	0187c783          	lbu	a5,24(a5)
    800053f2:	ebb9                	bnez	a5,80005448 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800053f4:	00451613          	slli	a2,a0,0x4
    800053f8:	00014797          	auipc	a5,0x14
    800053fc:	65878793          	addi	a5,a5,1624 # 80019a50 <disk>
    80005400:	6394                	ld	a3,0(a5)
    80005402:	96b2                	add	a3,a3,a2
    80005404:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005408:	6398                	ld	a4,0(a5)
    8000540a:	9732                	add	a4,a4,a2
    8000540c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005410:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005414:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005418:	953e                	add	a0,a0,a5
    8000541a:	4785                	li	a5,1
    8000541c:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80005420:	00014517          	auipc	a0,0x14
    80005424:	64850513          	addi	a0,a0,1608 # 80019a68 <disk+0x18>
    80005428:	ffffc097          	auipc	ra,0xffffc
    8000542c:	31a080e7          	jalr	794(ra) # 80001742 <wakeup>
}
    80005430:	60a2                	ld	ra,8(sp)
    80005432:	6402                	ld	s0,0(sp)
    80005434:	0141                	addi	sp,sp,16
    80005436:	8082                	ret
    panic("free_desc 1");
    80005438:	00003517          	auipc	a0,0x3
    8000543c:	30050513          	addi	a0,a0,768 # 80008738 <syscalls+0x338>
    80005440:	00001097          	auipc	ra,0x1
    80005444:	a72080e7          	jalr	-1422(ra) # 80005eb2 <panic>
    panic("free_desc 2");
    80005448:	00003517          	auipc	a0,0x3
    8000544c:	30050513          	addi	a0,a0,768 # 80008748 <syscalls+0x348>
    80005450:	00001097          	auipc	ra,0x1
    80005454:	a62080e7          	jalr	-1438(ra) # 80005eb2 <panic>

0000000080005458 <virtio_disk_init>:
{
    80005458:	1101                	addi	sp,sp,-32
    8000545a:	ec06                	sd	ra,24(sp)
    8000545c:	e822                	sd	s0,16(sp)
    8000545e:	e426                	sd	s1,8(sp)
    80005460:	e04a                	sd	s2,0(sp)
    80005462:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005464:	00003597          	auipc	a1,0x3
    80005468:	2f458593          	addi	a1,a1,756 # 80008758 <syscalls+0x358>
    8000546c:	00014517          	auipc	a0,0x14
    80005470:	70c50513          	addi	a0,a0,1804 # 80019b78 <disk+0x128>
    80005474:	00001097          	auipc	ra,0x1
    80005478:	ef8080e7          	jalr	-264(ra) # 8000636c <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000547c:	100017b7          	lui	a5,0x10001
    80005480:	4398                	lw	a4,0(a5)
    80005482:	2701                	sext.w	a4,a4
    80005484:	747277b7          	lui	a5,0x74727
    80005488:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000548c:	14f71e63          	bne	a4,a5,800055e8 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005490:	100017b7          	lui	a5,0x10001
    80005494:	43dc                	lw	a5,4(a5)
    80005496:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005498:	4709                	li	a4,2
    8000549a:	14e79763          	bne	a5,a4,800055e8 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000549e:	100017b7          	lui	a5,0x10001
    800054a2:	479c                	lw	a5,8(a5)
    800054a4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800054a6:	14e79163          	bne	a5,a4,800055e8 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800054aa:	100017b7          	lui	a5,0x10001
    800054ae:	47d8                	lw	a4,12(a5)
    800054b0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800054b2:	554d47b7          	lui	a5,0x554d4
    800054b6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800054ba:	12f71763          	bne	a4,a5,800055e8 <virtio_disk_init+0x190>
  *R(VIRTIO_MMIO_STATUS) = status;
    800054be:	100017b7          	lui	a5,0x10001
    800054c2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800054c6:	4705                	li	a4,1
    800054c8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800054ca:	470d                	li	a4,3
    800054cc:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800054ce:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800054d0:	c7ffe737          	lui	a4,0xc7ffe
    800054d4:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc98f>
    800054d8:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800054da:	2701                	sext.w	a4,a4
    800054dc:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800054de:	472d                	li	a4,11
    800054e0:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    800054e2:	0707a903          	lw	s2,112(a5)
    800054e6:	2901                	sext.w	s2,s2
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800054e8:	00897793          	andi	a5,s2,8
    800054ec:	10078663          	beqz	a5,800055f8 <virtio_disk_init+0x1a0>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800054f0:	100017b7          	lui	a5,0x10001
    800054f4:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800054f8:	43fc                	lw	a5,68(a5)
    800054fa:	2781                	sext.w	a5,a5
    800054fc:	10079663          	bnez	a5,80005608 <virtio_disk_init+0x1b0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005500:	100017b7          	lui	a5,0x10001
    80005504:	5bdc                	lw	a5,52(a5)
    80005506:	2781                	sext.w	a5,a5
  if(max == 0)
    80005508:	10078863          	beqz	a5,80005618 <virtio_disk_init+0x1c0>
  if(max < NUM)
    8000550c:	471d                	li	a4,7
    8000550e:	10f77d63          	bgeu	a4,a5,80005628 <virtio_disk_init+0x1d0>
  disk.desc = kalloc();
    80005512:	ffffb097          	auipc	ra,0xffffb
    80005516:	c06080e7          	jalr	-1018(ra) # 80000118 <kalloc>
    8000551a:	00014497          	auipc	s1,0x14
    8000551e:	53648493          	addi	s1,s1,1334 # 80019a50 <disk>
    80005522:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005524:	ffffb097          	auipc	ra,0xffffb
    80005528:	bf4080e7          	jalr	-1036(ra) # 80000118 <kalloc>
    8000552c:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000552e:	ffffb097          	auipc	ra,0xffffb
    80005532:	bea080e7          	jalr	-1046(ra) # 80000118 <kalloc>
    80005536:	87aa                	mv	a5,a0
    80005538:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    8000553a:	6088                	ld	a0,0(s1)
    8000553c:	cd75                	beqz	a0,80005638 <virtio_disk_init+0x1e0>
    8000553e:	00014717          	auipc	a4,0x14
    80005542:	51a73703          	ld	a4,1306(a4) # 80019a58 <disk+0x8>
    80005546:	cb6d                	beqz	a4,80005638 <virtio_disk_init+0x1e0>
    80005548:	cbe5                	beqz	a5,80005638 <virtio_disk_init+0x1e0>
  memset(disk.desc, 0, PGSIZE);
    8000554a:	6605                	lui	a2,0x1
    8000554c:	4581                	li	a1,0
    8000554e:	ffffb097          	auipc	ra,0xffffb
    80005552:	c2a080e7          	jalr	-982(ra) # 80000178 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005556:	00014497          	auipc	s1,0x14
    8000555a:	4fa48493          	addi	s1,s1,1274 # 80019a50 <disk>
    8000555e:	6605                	lui	a2,0x1
    80005560:	4581                	li	a1,0
    80005562:	6488                	ld	a0,8(s1)
    80005564:	ffffb097          	auipc	ra,0xffffb
    80005568:	c14080e7          	jalr	-1004(ra) # 80000178 <memset>
  memset(disk.used, 0, PGSIZE);
    8000556c:	6605                	lui	a2,0x1
    8000556e:	4581                	li	a1,0
    80005570:	6888                	ld	a0,16(s1)
    80005572:	ffffb097          	auipc	ra,0xffffb
    80005576:	c06080e7          	jalr	-1018(ra) # 80000178 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000557a:	100017b7          	lui	a5,0x10001
    8000557e:	4721                	li	a4,8
    80005580:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005582:	4098                	lw	a4,0(s1)
    80005584:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005588:	40d8                	lw	a4,4(s1)
    8000558a:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000558e:	6498                	ld	a4,8(s1)
    80005590:	0007069b          	sext.w	a3,a4
    80005594:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005598:	9701                	srai	a4,a4,0x20
    8000559a:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000559e:	6898                	ld	a4,16(s1)
    800055a0:	0007069b          	sext.w	a3,a4
    800055a4:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800055a8:	9701                	srai	a4,a4,0x20
    800055aa:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800055ae:	4685                	li	a3,1
    800055b0:	c3f4                	sw	a3,68(a5)
    disk.free[i] = 1;
    800055b2:	4705                	li	a4,1
    800055b4:	00d48c23          	sb	a3,24(s1)
    800055b8:	00e48ca3          	sb	a4,25(s1)
    800055bc:	00e48d23          	sb	a4,26(s1)
    800055c0:	00e48da3          	sb	a4,27(s1)
    800055c4:	00e48e23          	sb	a4,28(s1)
    800055c8:	00e48ea3          	sb	a4,29(s1)
    800055cc:	00e48f23          	sb	a4,30(s1)
    800055d0:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800055d4:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800055d8:	0727a823          	sw	s2,112(a5)
}
    800055dc:	60e2                	ld	ra,24(sp)
    800055de:	6442                	ld	s0,16(sp)
    800055e0:	64a2                	ld	s1,8(sp)
    800055e2:	6902                	ld	s2,0(sp)
    800055e4:	6105                	addi	sp,sp,32
    800055e6:	8082                	ret
    panic("could not find virtio disk");
    800055e8:	00003517          	auipc	a0,0x3
    800055ec:	18050513          	addi	a0,a0,384 # 80008768 <syscalls+0x368>
    800055f0:	00001097          	auipc	ra,0x1
    800055f4:	8c2080e7          	jalr	-1854(ra) # 80005eb2 <panic>
    panic("virtio disk FEATURES_OK unset");
    800055f8:	00003517          	auipc	a0,0x3
    800055fc:	19050513          	addi	a0,a0,400 # 80008788 <syscalls+0x388>
    80005600:	00001097          	auipc	ra,0x1
    80005604:	8b2080e7          	jalr	-1870(ra) # 80005eb2 <panic>
    panic("virtio disk should not be ready");
    80005608:	00003517          	auipc	a0,0x3
    8000560c:	1a050513          	addi	a0,a0,416 # 800087a8 <syscalls+0x3a8>
    80005610:	00001097          	auipc	ra,0x1
    80005614:	8a2080e7          	jalr	-1886(ra) # 80005eb2 <panic>
    panic("virtio disk has no queue 0");
    80005618:	00003517          	auipc	a0,0x3
    8000561c:	1b050513          	addi	a0,a0,432 # 800087c8 <syscalls+0x3c8>
    80005620:	00001097          	auipc	ra,0x1
    80005624:	892080e7          	jalr	-1902(ra) # 80005eb2 <panic>
    panic("virtio disk max queue too short");
    80005628:	00003517          	auipc	a0,0x3
    8000562c:	1c050513          	addi	a0,a0,448 # 800087e8 <syscalls+0x3e8>
    80005630:	00001097          	auipc	ra,0x1
    80005634:	882080e7          	jalr	-1918(ra) # 80005eb2 <panic>
    panic("virtio disk kalloc");
    80005638:	00003517          	auipc	a0,0x3
    8000563c:	1d050513          	addi	a0,a0,464 # 80008808 <syscalls+0x408>
    80005640:	00001097          	auipc	ra,0x1
    80005644:	872080e7          	jalr	-1934(ra) # 80005eb2 <panic>

0000000080005648 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005648:	7159                	addi	sp,sp,-112
    8000564a:	f486                	sd	ra,104(sp)
    8000564c:	f0a2                	sd	s0,96(sp)
    8000564e:	eca6                	sd	s1,88(sp)
    80005650:	e8ca                	sd	s2,80(sp)
    80005652:	e4ce                	sd	s3,72(sp)
    80005654:	e0d2                	sd	s4,64(sp)
    80005656:	fc56                	sd	s5,56(sp)
    80005658:	f85a                	sd	s6,48(sp)
    8000565a:	f45e                	sd	s7,40(sp)
    8000565c:	f062                	sd	s8,32(sp)
    8000565e:	ec66                	sd	s9,24(sp)
    80005660:	e86a                	sd	s10,16(sp)
    80005662:	1880                	addi	s0,sp,112
    80005664:	892a                	mv	s2,a0
    80005666:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005668:	00c52c83          	lw	s9,12(a0)
    8000566c:	001c9c9b          	slliw	s9,s9,0x1
    80005670:	1c82                	slli	s9,s9,0x20
    80005672:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80005676:	00014517          	auipc	a0,0x14
    8000567a:	50250513          	addi	a0,a0,1282 # 80019b78 <disk+0x128>
    8000567e:	00001097          	auipc	ra,0x1
    80005682:	d7e080e7          	jalr	-642(ra) # 800063fc <acquire>
  for(int i = 0; i < 3; i++){
    80005686:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005688:	4ba1                	li	s7,8
      disk.free[i] = 0;
    8000568a:	00014b17          	auipc	s6,0x14
    8000568e:	3c6b0b13          	addi	s6,s6,966 # 80019a50 <disk>
  for(int i = 0; i < 3; i++){
    80005692:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    80005694:	8a4e                	mv	s4,s3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005696:	00014c17          	auipc	s8,0x14
    8000569a:	4e2c0c13          	addi	s8,s8,1250 # 80019b78 <disk+0x128>
    8000569e:	a8b5                	j	8000571a <virtio_disk_rw+0xd2>
      disk.free[i] = 0;
    800056a0:	00fb06b3          	add	a3,s6,a5
    800056a4:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    800056a8:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    800056aa:	0207c563          	bltz	a5,800056d4 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    800056ae:	2485                	addiw	s1,s1,1
    800056b0:	0711                	addi	a4,a4,4
    800056b2:	1f548a63          	beq	s1,s5,800058a6 <virtio_disk_rw+0x25e>
    idx[i] = alloc_desc();
    800056b6:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    800056b8:	00014697          	auipc	a3,0x14
    800056bc:	39868693          	addi	a3,a3,920 # 80019a50 <disk>
    800056c0:	87d2                	mv	a5,s4
    if(disk.free[i]){
    800056c2:	0186c583          	lbu	a1,24(a3)
    800056c6:	fde9                	bnez	a1,800056a0 <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    800056c8:	2785                	addiw	a5,a5,1
    800056ca:	0685                	addi	a3,a3,1
    800056cc:	ff779be3          	bne	a5,s7,800056c2 <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    800056d0:	57fd                	li	a5,-1
    800056d2:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    800056d4:	02905a63          	blez	s1,80005708 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    800056d8:	f9042503          	lw	a0,-112(s0)
    800056dc:	00000097          	auipc	ra,0x0
    800056e0:	cfa080e7          	jalr	-774(ra) # 800053d6 <free_desc>
      for(int j = 0; j < i; j++)
    800056e4:	4785                	li	a5,1
    800056e6:	0297d163          	bge	a5,s1,80005708 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    800056ea:	f9442503          	lw	a0,-108(s0)
    800056ee:	00000097          	auipc	ra,0x0
    800056f2:	ce8080e7          	jalr	-792(ra) # 800053d6 <free_desc>
      for(int j = 0; j < i; j++)
    800056f6:	4789                	li	a5,2
    800056f8:	0097d863          	bge	a5,s1,80005708 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    800056fc:	f9842503          	lw	a0,-104(s0)
    80005700:	00000097          	auipc	ra,0x0
    80005704:	cd6080e7          	jalr	-810(ra) # 800053d6 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005708:	85e2                	mv	a1,s8
    8000570a:	00014517          	auipc	a0,0x14
    8000570e:	35e50513          	addi	a0,a0,862 # 80019a68 <disk+0x18>
    80005712:	ffffc097          	auipc	ra,0xffffc
    80005716:	fcc080e7          	jalr	-52(ra) # 800016de <sleep>
  for(int i = 0; i < 3; i++){
    8000571a:	f9040713          	addi	a4,s0,-112
    8000571e:	84ce                	mv	s1,s3
    80005720:	bf59                	j	800056b6 <virtio_disk_rw+0x6e>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    80005722:	00a60793          	addi	a5,a2,10 # 100a <_entry-0x7fffeff6>
    80005726:	00479693          	slli	a3,a5,0x4
    8000572a:	00014797          	auipc	a5,0x14
    8000572e:	32678793          	addi	a5,a5,806 # 80019a50 <disk>
    80005732:	97b6                	add	a5,a5,a3
    80005734:	4685                	li	a3,1
    80005736:	c794                	sw	a3,8(a5)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005738:	00014597          	auipc	a1,0x14
    8000573c:	31858593          	addi	a1,a1,792 # 80019a50 <disk>
    80005740:	00a60793          	addi	a5,a2,10
    80005744:	0792                	slli	a5,a5,0x4
    80005746:	97ae                	add	a5,a5,a1
    80005748:	0007a623          	sw	zero,12(a5)
  buf0->sector = sector;
    8000574c:	0197b823          	sd	s9,16(a5)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005750:	f6070693          	addi	a3,a4,-160
    80005754:	619c                	ld	a5,0(a1)
    80005756:	97b6                	add	a5,a5,a3
    80005758:	e388                	sd	a0,0(a5)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000575a:	6188                	ld	a0,0(a1)
    8000575c:	96aa                	add	a3,a3,a0
    8000575e:	47c1                	li	a5,16
    80005760:	c69c                	sw	a5,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005762:	4785                	li	a5,1
    80005764:	00f69623          	sh	a5,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80005768:	f9442783          	lw	a5,-108(s0)
    8000576c:	00f69723          	sh	a5,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005770:	0792                	slli	a5,a5,0x4
    80005772:	953e                	add	a0,a0,a5
    80005774:	05890693          	addi	a3,s2,88
    80005778:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    8000577a:	6188                	ld	a0,0(a1)
    8000577c:	97aa                	add	a5,a5,a0
    8000577e:	40000693          	li	a3,1024
    80005782:	c794                	sw	a3,8(a5)
  if(write)
    80005784:	100d0d63          	beqz	s10,8000589e <virtio_disk_rw+0x256>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80005788:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000578c:	00c7d683          	lhu	a3,12(a5)
    80005790:	0016e693          	ori	a3,a3,1
    80005794:	00d79623          	sh	a3,12(a5)
  disk.desc[idx[1]].next = idx[2];
    80005798:	f9842583          	lw	a1,-104(s0)
    8000579c:	00b79723          	sh	a1,14(a5)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800057a0:	00014697          	auipc	a3,0x14
    800057a4:	2b068693          	addi	a3,a3,688 # 80019a50 <disk>
    800057a8:	00260793          	addi	a5,a2,2
    800057ac:	0792                	slli	a5,a5,0x4
    800057ae:	97b6                	add	a5,a5,a3
    800057b0:	587d                	li	a6,-1
    800057b2:	01078823          	sb	a6,16(a5)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800057b6:	0592                	slli	a1,a1,0x4
    800057b8:	952e                	add	a0,a0,a1
    800057ba:	f9070713          	addi	a4,a4,-112
    800057be:	9736                	add	a4,a4,a3
    800057c0:	e118                	sd	a4,0(a0)
  disk.desc[idx[2]].len = 1;
    800057c2:	6298                	ld	a4,0(a3)
    800057c4:	972e                	add	a4,a4,a1
    800057c6:	4585                	li	a1,1
    800057c8:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800057ca:	4509                	li	a0,2
    800057cc:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[2]].next = 0;
    800057d0:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800057d4:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    800057d8:	0127b423          	sd	s2,8(a5)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800057dc:	6698                	ld	a4,8(a3)
    800057de:	00275783          	lhu	a5,2(a4)
    800057e2:	8b9d                	andi	a5,a5,7
    800057e4:	0786                	slli	a5,a5,0x1
    800057e6:	97ba                	add	a5,a5,a4
    800057e8:	00c79223          	sh	a2,4(a5)

  __sync_synchronize();
    800057ec:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800057f0:	6698                	ld	a4,8(a3)
    800057f2:	00275783          	lhu	a5,2(a4)
    800057f6:	2785                	addiw	a5,a5,1
    800057f8:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800057fc:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005800:	100017b7          	lui	a5,0x10001
    80005804:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005808:	00492703          	lw	a4,4(s2)
    8000580c:	4785                	li	a5,1
    8000580e:	02f71163          	bne	a4,a5,80005830 <virtio_disk_rw+0x1e8>
    sleep(b, &disk.vdisk_lock);
    80005812:	00014997          	auipc	s3,0x14
    80005816:	36698993          	addi	s3,s3,870 # 80019b78 <disk+0x128>
  while(b->disk == 1) {
    8000581a:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    8000581c:	85ce                	mv	a1,s3
    8000581e:	854a                	mv	a0,s2
    80005820:	ffffc097          	auipc	ra,0xffffc
    80005824:	ebe080e7          	jalr	-322(ra) # 800016de <sleep>
  while(b->disk == 1) {
    80005828:	00492783          	lw	a5,4(s2)
    8000582c:	fe9788e3          	beq	a5,s1,8000581c <virtio_disk_rw+0x1d4>
  }

  disk.info[idx[0]].b = 0;
    80005830:	f9042903          	lw	s2,-112(s0)
    80005834:	00290793          	addi	a5,s2,2
    80005838:	00479713          	slli	a4,a5,0x4
    8000583c:	00014797          	auipc	a5,0x14
    80005840:	21478793          	addi	a5,a5,532 # 80019a50 <disk>
    80005844:	97ba                	add	a5,a5,a4
    80005846:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000584a:	00014997          	auipc	s3,0x14
    8000584e:	20698993          	addi	s3,s3,518 # 80019a50 <disk>
    80005852:	00491713          	slli	a4,s2,0x4
    80005856:	0009b783          	ld	a5,0(s3)
    8000585a:	97ba                	add	a5,a5,a4
    8000585c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005860:	854a                	mv	a0,s2
    80005862:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005866:	00000097          	auipc	ra,0x0
    8000586a:	b70080e7          	jalr	-1168(ra) # 800053d6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000586e:	8885                	andi	s1,s1,1
    80005870:	f0ed                	bnez	s1,80005852 <virtio_disk_rw+0x20a>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005872:	00014517          	auipc	a0,0x14
    80005876:	30650513          	addi	a0,a0,774 # 80019b78 <disk+0x128>
    8000587a:	00001097          	auipc	ra,0x1
    8000587e:	c36080e7          	jalr	-970(ra) # 800064b0 <release>
}
    80005882:	70a6                	ld	ra,104(sp)
    80005884:	7406                	ld	s0,96(sp)
    80005886:	64e6                	ld	s1,88(sp)
    80005888:	6946                	ld	s2,80(sp)
    8000588a:	69a6                	ld	s3,72(sp)
    8000588c:	6a06                	ld	s4,64(sp)
    8000588e:	7ae2                	ld	s5,56(sp)
    80005890:	7b42                	ld	s6,48(sp)
    80005892:	7ba2                	ld	s7,40(sp)
    80005894:	7c02                	ld	s8,32(sp)
    80005896:	6ce2                	ld	s9,24(sp)
    80005898:	6d42                	ld	s10,16(sp)
    8000589a:	6165                	addi	sp,sp,112
    8000589c:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000589e:	4689                	li	a3,2
    800058a0:	00d79623          	sh	a3,12(a5)
    800058a4:	b5e5                	j	8000578c <virtio_disk_rw+0x144>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800058a6:	f9042603          	lw	a2,-112(s0)
    800058aa:	00a60713          	addi	a4,a2,10
    800058ae:	0712                	slli	a4,a4,0x4
    800058b0:	00014517          	auipc	a0,0x14
    800058b4:	1a850513          	addi	a0,a0,424 # 80019a58 <disk+0x8>
    800058b8:	953a                	add	a0,a0,a4
  if(write)
    800058ba:	e60d14e3          	bnez	s10,80005722 <virtio_disk_rw+0xda>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    800058be:	00a60793          	addi	a5,a2,10
    800058c2:	00479693          	slli	a3,a5,0x4
    800058c6:	00014797          	auipc	a5,0x14
    800058ca:	18a78793          	addi	a5,a5,394 # 80019a50 <disk>
    800058ce:	97b6                	add	a5,a5,a3
    800058d0:	0007a423          	sw	zero,8(a5)
    800058d4:	b595                	j	80005738 <virtio_disk_rw+0xf0>

00000000800058d6 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800058d6:	1101                	addi	sp,sp,-32
    800058d8:	ec06                	sd	ra,24(sp)
    800058da:	e822                	sd	s0,16(sp)
    800058dc:	e426                	sd	s1,8(sp)
    800058de:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800058e0:	00014497          	auipc	s1,0x14
    800058e4:	17048493          	addi	s1,s1,368 # 80019a50 <disk>
    800058e8:	00014517          	auipc	a0,0x14
    800058ec:	29050513          	addi	a0,a0,656 # 80019b78 <disk+0x128>
    800058f0:	00001097          	auipc	ra,0x1
    800058f4:	b0c080e7          	jalr	-1268(ra) # 800063fc <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800058f8:	10001737          	lui	a4,0x10001
    800058fc:	533c                	lw	a5,96(a4)
    800058fe:	8b8d                	andi	a5,a5,3
    80005900:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80005902:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005906:	689c                	ld	a5,16(s1)
    80005908:	0204d703          	lhu	a4,32(s1)
    8000590c:	0027d783          	lhu	a5,2(a5)
    80005910:	04f70863          	beq	a4,a5,80005960 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80005914:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005918:	6898                	ld	a4,16(s1)
    8000591a:	0204d783          	lhu	a5,32(s1)
    8000591e:	8b9d                	andi	a5,a5,7
    80005920:	078e                	slli	a5,a5,0x3
    80005922:	97ba                	add	a5,a5,a4
    80005924:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005926:	00278713          	addi	a4,a5,2
    8000592a:	0712                	slli	a4,a4,0x4
    8000592c:	9726                	add	a4,a4,s1
    8000592e:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80005932:	e721                	bnez	a4,8000597a <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005934:	0789                	addi	a5,a5,2
    80005936:	0792                	slli	a5,a5,0x4
    80005938:	97a6                	add	a5,a5,s1
    8000593a:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000593c:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005940:	ffffc097          	auipc	ra,0xffffc
    80005944:	e02080e7          	jalr	-510(ra) # 80001742 <wakeup>

    disk.used_idx += 1;
    80005948:	0204d783          	lhu	a5,32(s1)
    8000594c:	2785                	addiw	a5,a5,1
    8000594e:	17c2                	slli	a5,a5,0x30
    80005950:	93c1                	srli	a5,a5,0x30
    80005952:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005956:	6898                	ld	a4,16(s1)
    80005958:	00275703          	lhu	a4,2(a4)
    8000595c:	faf71ce3          	bne	a4,a5,80005914 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005960:	00014517          	auipc	a0,0x14
    80005964:	21850513          	addi	a0,a0,536 # 80019b78 <disk+0x128>
    80005968:	00001097          	auipc	ra,0x1
    8000596c:	b48080e7          	jalr	-1208(ra) # 800064b0 <release>
}
    80005970:	60e2                	ld	ra,24(sp)
    80005972:	6442                	ld	s0,16(sp)
    80005974:	64a2                	ld	s1,8(sp)
    80005976:	6105                	addi	sp,sp,32
    80005978:	8082                	ret
      panic("virtio_disk_intr status");
    8000597a:	00003517          	auipc	a0,0x3
    8000597e:	ea650513          	addi	a0,a0,-346 # 80008820 <syscalls+0x420>
    80005982:	00000097          	auipc	ra,0x0
    80005986:	530080e7          	jalr	1328(ra) # 80005eb2 <panic>

000000008000598a <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000598a:	1141                	addi	sp,sp,-16
    8000598c:	e422                	sd	s0,8(sp)
    8000598e:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80005990:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80005994:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    80005998:	0037979b          	slliw	a5,a5,0x3
    8000599c:	02004737          	lui	a4,0x2004
    800059a0:	97ba                	add	a5,a5,a4
    800059a2:	0200c737          	lui	a4,0x200c
    800059a6:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    800059aa:	000f4637          	lui	a2,0xf4
    800059ae:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    800059b2:	95b2                	add	a1,a1,a2
    800059b4:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    800059b6:	00269713          	slli	a4,a3,0x2
    800059ba:	9736                	add	a4,a4,a3
    800059bc:	00371693          	slli	a3,a4,0x3
    800059c0:	00014717          	auipc	a4,0x14
    800059c4:	1d070713          	addi	a4,a4,464 # 80019b90 <timer_scratch>
    800059c8:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    800059ca:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    800059cc:	f310                	sd	a2,32(a4)
  asm volatile("csrw mscratch, %0" : : "r" (x));
    800059ce:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    800059d2:	00000797          	auipc	a5,0x0
    800059d6:	93e78793          	addi	a5,a5,-1730 # 80005310 <timervec>
    800059da:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    800059de:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    800059e2:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800059e6:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    800059ea:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    800059ee:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    800059f2:	30479073          	csrw	mie,a5
}
    800059f6:	6422                	ld	s0,8(sp)
    800059f8:	0141                	addi	sp,sp,16
    800059fa:	8082                	ret

00000000800059fc <start>:
{
    800059fc:	1141                	addi	sp,sp,-16
    800059fe:	e406                	sd	ra,8(sp)
    80005a00:	e022                	sd	s0,0(sp)
    80005a02:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80005a04:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80005a08:	7779                	lui	a4,0xffffe
    80005a0a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdca2f>
    80005a0e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80005a10:	6705                	lui	a4,0x1
    80005a12:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    80005a16:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80005a18:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80005a1c:	ffffb797          	auipc	a5,0xffffb
    80005a20:	90a78793          	addi	a5,a5,-1782 # 80000326 <main>
    80005a24:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    80005a28:	4781                	li	a5,0
    80005a2a:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80005a2e:	67c1                	lui	a5,0x10
    80005a30:	17fd                	addi	a5,a5,-1
    80005a32:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    80005a36:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    80005a3a:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80005a3e:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80005a42:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    80005a46:	57fd                	li	a5,-1
    80005a48:	83a9                	srli	a5,a5,0xa
    80005a4a:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    80005a4e:	47bd                	li	a5,15
    80005a50:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    80005a54:	00000097          	auipc	ra,0x0
    80005a58:	f36080e7          	jalr	-202(ra) # 8000598a <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80005a5c:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    80005a60:	2781                	sext.w	a5,a5
  asm volatile("mv tp, %0" : : "r" (x));
    80005a62:	823e                	mv	tp,a5
  asm volatile("mret");
    80005a64:	30200073          	mret
}
    80005a68:	60a2                	ld	ra,8(sp)
    80005a6a:	6402                	ld	s0,0(sp)
    80005a6c:	0141                	addi	sp,sp,16
    80005a6e:	8082                	ret

0000000080005a70 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80005a70:	715d                	addi	sp,sp,-80
    80005a72:	e486                	sd	ra,72(sp)
    80005a74:	e0a2                	sd	s0,64(sp)
    80005a76:	fc26                	sd	s1,56(sp)
    80005a78:	f84a                	sd	s2,48(sp)
    80005a7a:	f44e                	sd	s3,40(sp)
    80005a7c:	f052                	sd	s4,32(sp)
    80005a7e:	ec56                	sd	s5,24(sp)
    80005a80:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80005a82:	04c05663          	blez	a2,80005ace <consolewrite+0x5e>
    80005a86:	8a2a                	mv	s4,a0
    80005a88:	84ae                	mv	s1,a1
    80005a8a:	89b2                	mv	s3,a2
    80005a8c:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80005a8e:	5afd                	li	s5,-1
    80005a90:	4685                	li	a3,1
    80005a92:	8626                	mv	a2,s1
    80005a94:	85d2                	mv	a1,s4
    80005a96:	fbf40513          	addi	a0,s0,-65
    80005a9a:	ffffc097          	auipc	ra,0xffffc
    80005a9e:	0a2080e7          	jalr	162(ra) # 80001b3c <either_copyin>
    80005aa2:	01550c63          	beq	a0,s5,80005aba <consolewrite+0x4a>
      break;
    uartputc(c);
    80005aa6:	fbf44503          	lbu	a0,-65(s0)
    80005aaa:	00000097          	auipc	ra,0x0
    80005aae:	794080e7          	jalr	1940(ra) # 8000623e <uartputc>
  for(i = 0; i < n; i++){
    80005ab2:	2905                	addiw	s2,s2,1
    80005ab4:	0485                	addi	s1,s1,1
    80005ab6:	fd299de3          	bne	s3,s2,80005a90 <consolewrite+0x20>
  }

  return i;
}
    80005aba:	854a                	mv	a0,s2
    80005abc:	60a6                	ld	ra,72(sp)
    80005abe:	6406                	ld	s0,64(sp)
    80005ac0:	74e2                	ld	s1,56(sp)
    80005ac2:	7942                	ld	s2,48(sp)
    80005ac4:	79a2                	ld	s3,40(sp)
    80005ac6:	7a02                	ld	s4,32(sp)
    80005ac8:	6ae2                	ld	s5,24(sp)
    80005aca:	6161                	addi	sp,sp,80
    80005acc:	8082                	ret
  for(i = 0; i < n; i++){
    80005ace:	4901                	li	s2,0
    80005ad0:	b7ed                	j	80005aba <consolewrite+0x4a>

0000000080005ad2 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80005ad2:	7119                	addi	sp,sp,-128
    80005ad4:	fc86                	sd	ra,120(sp)
    80005ad6:	f8a2                	sd	s0,112(sp)
    80005ad8:	f4a6                	sd	s1,104(sp)
    80005ada:	f0ca                	sd	s2,96(sp)
    80005adc:	ecce                	sd	s3,88(sp)
    80005ade:	e8d2                	sd	s4,80(sp)
    80005ae0:	e4d6                	sd	s5,72(sp)
    80005ae2:	e0da                	sd	s6,64(sp)
    80005ae4:	fc5e                	sd	s7,56(sp)
    80005ae6:	f862                	sd	s8,48(sp)
    80005ae8:	f466                	sd	s9,40(sp)
    80005aea:	f06a                	sd	s10,32(sp)
    80005aec:	ec6e                	sd	s11,24(sp)
    80005aee:	0100                	addi	s0,sp,128
    80005af0:	8b2a                	mv	s6,a0
    80005af2:	8aae                	mv	s5,a1
    80005af4:	8a32                	mv	s4,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80005af6:	00060b9b          	sext.w	s7,a2
  acquire(&cons.lock);
    80005afa:	0001c517          	auipc	a0,0x1c
    80005afe:	1d650513          	addi	a0,a0,470 # 80021cd0 <cons>
    80005b02:	00001097          	auipc	ra,0x1
    80005b06:	8fa080e7          	jalr	-1798(ra) # 800063fc <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80005b0a:	0001c497          	auipc	s1,0x1c
    80005b0e:	1c648493          	addi	s1,s1,454 # 80021cd0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80005b12:	89a6                	mv	s3,s1
    80005b14:	0001c917          	auipc	s2,0x1c
    80005b18:	25490913          	addi	s2,s2,596 # 80021d68 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    80005b1c:	4c91                	li	s9,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80005b1e:	5d7d                	li	s10,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    80005b20:	4da9                	li	s11,10
  while(n > 0){
    80005b22:	07405b63          	blez	s4,80005b98 <consoleread+0xc6>
    while(cons.r == cons.w){
    80005b26:	0984a783          	lw	a5,152(s1)
    80005b2a:	09c4a703          	lw	a4,156(s1)
    80005b2e:	02f71763          	bne	a4,a5,80005b5c <consoleread+0x8a>
      if(killed(myproc())){
    80005b32:	ffffb097          	auipc	ra,0xffffb
    80005b36:	402080e7          	jalr	1026(ra) # 80000f34 <myproc>
    80005b3a:	ffffc097          	auipc	ra,0xffffc
    80005b3e:	e4c080e7          	jalr	-436(ra) # 80001986 <killed>
    80005b42:	e535                	bnez	a0,80005bae <consoleread+0xdc>
      sleep(&cons.r, &cons.lock);
    80005b44:	85ce                	mv	a1,s3
    80005b46:	854a                	mv	a0,s2
    80005b48:	ffffc097          	auipc	ra,0xffffc
    80005b4c:	b96080e7          	jalr	-1130(ra) # 800016de <sleep>
    while(cons.r == cons.w){
    80005b50:	0984a783          	lw	a5,152(s1)
    80005b54:	09c4a703          	lw	a4,156(s1)
    80005b58:	fcf70de3          	beq	a4,a5,80005b32 <consoleread+0x60>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    80005b5c:	0017871b          	addiw	a4,a5,1
    80005b60:	08e4ac23          	sw	a4,152(s1)
    80005b64:	07f7f713          	andi	a4,a5,127
    80005b68:	9726                	add	a4,a4,s1
    80005b6a:	01874703          	lbu	a4,24(a4)
    80005b6e:	00070c1b          	sext.w	s8,a4
    if(c == C('D')){  // end-of-file
    80005b72:	079c0663          	beq	s8,s9,80005bde <consoleread+0x10c>
    cbuf = c;
    80005b76:	f8e407a3          	sb	a4,-113(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80005b7a:	4685                	li	a3,1
    80005b7c:	f8f40613          	addi	a2,s0,-113
    80005b80:	85d6                	mv	a1,s5
    80005b82:	855a                	mv	a0,s6
    80005b84:	ffffc097          	auipc	ra,0xffffc
    80005b88:	f62080e7          	jalr	-158(ra) # 80001ae6 <either_copyout>
    80005b8c:	01a50663          	beq	a0,s10,80005b98 <consoleread+0xc6>
    dst++;
    80005b90:	0a85                	addi	s5,s5,1
    --n;
    80005b92:	3a7d                	addiw	s4,s4,-1
    if(c == '\n'){
    80005b94:	f9bc17e3          	bne	s8,s11,80005b22 <consoleread+0x50>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80005b98:	0001c517          	auipc	a0,0x1c
    80005b9c:	13850513          	addi	a0,a0,312 # 80021cd0 <cons>
    80005ba0:	00001097          	auipc	ra,0x1
    80005ba4:	910080e7          	jalr	-1776(ra) # 800064b0 <release>

  return target - n;
    80005ba8:	414b853b          	subw	a0,s7,s4
    80005bac:	a811                	j	80005bc0 <consoleread+0xee>
        release(&cons.lock);
    80005bae:	0001c517          	auipc	a0,0x1c
    80005bb2:	12250513          	addi	a0,a0,290 # 80021cd0 <cons>
    80005bb6:	00001097          	auipc	ra,0x1
    80005bba:	8fa080e7          	jalr	-1798(ra) # 800064b0 <release>
        return -1;
    80005bbe:	557d                	li	a0,-1
}
    80005bc0:	70e6                	ld	ra,120(sp)
    80005bc2:	7446                	ld	s0,112(sp)
    80005bc4:	74a6                	ld	s1,104(sp)
    80005bc6:	7906                	ld	s2,96(sp)
    80005bc8:	69e6                	ld	s3,88(sp)
    80005bca:	6a46                	ld	s4,80(sp)
    80005bcc:	6aa6                	ld	s5,72(sp)
    80005bce:	6b06                	ld	s6,64(sp)
    80005bd0:	7be2                	ld	s7,56(sp)
    80005bd2:	7c42                	ld	s8,48(sp)
    80005bd4:	7ca2                	ld	s9,40(sp)
    80005bd6:	7d02                	ld	s10,32(sp)
    80005bd8:	6de2                	ld	s11,24(sp)
    80005bda:	6109                	addi	sp,sp,128
    80005bdc:	8082                	ret
      if(n < target){
    80005bde:	000a071b          	sext.w	a4,s4
    80005be2:	fb777be3          	bgeu	a4,s7,80005b98 <consoleread+0xc6>
        cons.r--;
    80005be6:	0001c717          	auipc	a4,0x1c
    80005bea:	18f72123          	sw	a5,386(a4) # 80021d68 <cons+0x98>
    80005bee:	b76d                	j	80005b98 <consoleread+0xc6>

0000000080005bf0 <consputc>:
{
    80005bf0:	1141                	addi	sp,sp,-16
    80005bf2:	e406                	sd	ra,8(sp)
    80005bf4:	e022                	sd	s0,0(sp)
    80005bf6:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80005bf8:	10000793          	li	a5,256
    80005bfc:	00f50a63          	beq	a0,a5,80005c10 <consputc+0x20>
    uartputc_sync(c);
    80005c00:	00000097          	auipc	ra,0x0
    80005c04:	564080e7          	jalr	1380(ra) # 80006164 <uartputc_sync>
}
    80005c08:	60a2                	ld	ra,8(sp)
    80005c0a:	6402                	ld	s0,0(sp)
    80005c0c:	0141                	addi	sp,sp,16
    80005c0e:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80005c10:	4521                	li	a0,8
    80005c12:	00000097          	auipc	ra,0x0
    80005c16:	552080e7          	jalr	1362(ra) # 80006164 <uartputc_sync>
    80005c1a:	02000513          	li	a0,32
    80005c1e:	00000097          	auipc	ra,0x0
    80005c22:	546080e7          	jalr	1350(ra) # 80006164 <uartputc_sync>
    80005c26:	4521                	li	a0,8
    80005c28:	00000097          	auipc	ra,0x0
    80005c2c:	53c080e7          	jalr	1340(ra) # 80006164 <uartputc_sync>
    80005c30:	bfe1                	j	80005c08 <consputc+0x18>

0000000080005c32 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    80005c32:	1101                	addi	sp,sp,-32
    80005c34:	ec06                	sd	ra,24(sp)
    80005c36:	e822                	sd	s0,16(sp)
    80005c38:	e426                	sd	s1,8(sp)
    80005c3a:	e04a                	sd	s2,0(sp)
    80005c3c:	1000                	addi	s0,sp,32
    80005c3e:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    80005c40:	0001c517          	auipc	a0,0x1c
    80005c44:	09050513          	addi	a0,a0,144 # 80021cd0 <cons>
    80005c48:	00000097          	auipc	ra,0x0
    80005c4c:	7b4080e7          	jalr	1972(ra) # 800063fc <acquire>

  switch(c){
    80005c50:	47d5                	li	a5,21
    80005c52:	0af48663          	beq	s1,a5,80005cfe <consoleintr+0xcc>
    80005c56:	0297ca63          	blt	a5,s1,80005c8a <consoleintr+0x58>
    80005c5a:	47a1                	li	a5,8
    80005c5c:	0ef48763          	beq	s1,a5,80005d4a <consoleintr+0x118>
    80005c60:	47c1                	li	a5,16
    80005c62:	10f49a63          	bne	s1,a5,80005d76 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    80005c66:	ffffc097          	auipc	ra,0xffffc
    80005c6a:	f2c080e7          	jalr	-212(ra) # 80001b92 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80005c6e:	0001c517          	auipc	a0,0x1c
    80005c72:	06250513          	addi	a0,a0,98 # 80021cd0 <cons>
    80005c76:	00001097          	auipc	ra,0x1
    80005c7a:	83a080e7          	jalr	-1990(ra) # 800064b0 <release>
}
    80005c7e:	60e2                	ld	ra,24(sp)
    80005c80:	6442                	ld	s0,16(sp)
    80005c82:	64a2                	ld	s1,8(sp)
    80005c84:	6902                	ld	s2,0(sp)
    80005c86:	6105                	addi	sp,sp,32
    80005c88:	8082                	ret
  switch(c){
    80005c8a:	07f00793          	li	a5,127
    80005c8e:	0af48e63          	beq	s1,a5,80005d4a <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80005c92:	0001c717          	auipc	a4,0x1c
    80005c96:	03e70713          	addi	a4,a4,62 # 80021cd0 <cons>
    80005c9a:	0a072783          	lw	a5,160(a4)
    80005c9e:	09872703          	lw	a4,152(a4)
    80005ca2:	9f99                	subw	a5,a5,a4
    80005ca4:	07f00713          	li	a4,127
    80005ca8:	fcf763e3          	bltu	a4,a5,80005c6e <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80005cac:	47b5                	li	a5,13
    80005cae:	0cf48763          	beq	s1,a5,80005d7c <consoleintr+0x14a>
      consputc(c);
    80005cb2:	8526                	mv	a0,s1
    80005cb4:	00000097          	auipc	ra,0x0
    80005cb8:	f3c080e7          	jalr	-196(ra) # 80005bf0 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80005cbc:	0001c797          	auipc	a5,0x1c
    80005cc0:	01478793          	addi	a5,a5,20 # 80021cd0 <cons>
    80005cc4:	0a07a683          	lw	a3,160(a5)
    80005cc8:	0016871b          	addiw	a4,a3,1
    80005ccc:	0007061b          	sext.w	a2,a4
    80005cd0:	0ae7a023          	sw	a4,160(a5)
    80005cd4:	07f6f693          	andi	a3,a3,127
    80005cd8:	97b6                	add	a5,a5,a3
    80005cda:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80005cde:	47a9                	li	a5,10
    80005ce0:	0cf48563          	beq	s1,a5,80005daa <consoleintr+0x178>
    80005ce4:	4791                	li	a5,4
    80005ce6:	0cf48263          	beq	s1,a5,80005daa <consoleintr+0x178>
    80005cea:	0001c797          	auipc	a5,0x1c
    80005cee:	07e7a783          	lw	a5,126(a5) # 80021d68 <cons+0x98>
    80005cf2:	9f1d                	subw	a4,a4,a5
    80005cf4:	08000793          	li	a5,128
    80005cf8:	f6f71be3          	bne	a4,a5,80005c6e <consoleintr+0x3c>
    80005cfc:	a07d                	j	80005daa <consoleintr+0x178>
    while(cons.e != cons.w &&
    80005cfe:	0001c717          	auipc	a4,0x1c
    80005d02:	fd270713          	addi	a4,a4,-46 # 80021cd0 <cons>
    80005d06:	0a072783          	lw	a5,160(a4)
    80005d0a:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80005d0e:	0001c497          	auipc	s1,0x1c
    80005d12:	fc248493          	addi	s1,s1,-62 # 80021cd0 <cons>
    while(cons.e != cons.w &&
    80005d16:	4929                	li	s2,10
    80005d18:	f4f70be3          	beq	a4,a5,80005c6e <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80005d1c:	37fd                	addiw	a5,a5,-1
    80005d1e:	07f7f713          	andi	a4,a5,127
    80005d22:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80005d24:	01874703          	lbu	a4,24(a4)
    80005d28:	f52703e3          	beq	a4,s2,80005c6e <consoleintr+0x3c>
      cons.e--;
    80005d2c:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80005d30:	10000513          	li	a0,256
    80005d34:	00000097          	auipc	ra,0x0
    80005d38:	ebc080e7          	jalr	-324(ra) # 80005bf0 <consputc>
    while(cons.e != cons.w &&
    80005d3c:	0a04a783          	lw	a5,160(s1)
    80005d40:	09c4a703          	lw	a4,156(s1)
    80005d44:	fcf71ce3          	bne	a4,a5,80005d1c <consoleintr+0xea>
    80005d48:	b71d                	j	80005c6e <consoleintr+0x3c>
    if(cons.e != cons.w){
    80005d4a:	0001c717          	auipc	a4,0x1c
    80005d4e:	f8670713          	addi	a4,a4,-122 # 80021cd0 <cons>
    80005d52:	0a072783          	lw	a5,160(a4)
    80005d56:	09c72703          	lw	a4,156(a4)
    80005d5a:	f0f70ae3          	beq	a4,a5,80005c6e <consoleintr+0x3c>
      cons.e--;
    80005d5e:	37fd                	addiw	a5,a5,-1
    80005d60:	0001c717          	auipc	a4,0x1c
    80005d64:	00f72823          	sw	a5,16(a4) # 80021d70 <cons+0xa0>
      consputc(BACKSPACE);
    80005d68:	10000513          	li	a0,256
    80005d6c:	00000097          	auipc	ra,0x0
    80005d70:	e84080e7          	jalr	-380(ra) # 80005bf0 <consputc>
    80005d74:	bded                	j	80005c6e <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80005d76:	ee048ce3          	beqz	s1,80005c6e <consoleintr+0x3c>
    80005d7a:	bf21                	j	80005c92 <consoleintr+0x60>
      consputc(c);
    80005d7c:	4529                	li	a0,10
    80005d7e:	00000097          	auipc	ra,0x0
    80005d82:	e72080e7          	jalr	-398(ra) # 80005bf0 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80005d86:	0001c797          	auipc	a5,0x1c
    80005d8a:	f4a78793          	addi	a5,a5,-182 # 80021cd0 <cons>
    80005d8e:	0a07a703          	lw	a4,160(a5)
    80005d92:	0017069b          	addiw	a3,a4,1
    80005d96:	0006861b          	sext.w	a2,a3
    80005d9a:	0ad7a023          	sw	a3,160(a5)
    80005d9e:	07f77713          	andi	a4,a4,127
    80005da2:	97ba                	add	a5,a5,a4
    80005da4:	4729                	li	a4,10
    80005da6:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80005daa:	0001c797          	auipc	a5,0x1c
    80005dae:	fcc7a123          	sw	a2,-62(a5) # 80021d6c <cons+0x9c>
        wakeup(&cons.r);
    80005db2:	0001c517          	auipc	a0,0x1c
    80005db6:	fb650513          	addi	a0,a0,-74 # 80021d68 <cons+0x98>
    80005dba:	ffffc097          	auipc	ra,0xffffc
    80005dbe:	988080e7          	jalr	-1656(ra) # 80001742 <wakeup>
    80005dc2:	b575                	j	80005c6e <consoleintr+0x3c>

0000000080005dc4 <consoleinit>:

void
consoleinit(void)
{
    80005dc4:	1141                	addi	sp,sp,-16
    80005dc6:	e406                	sd	ra,8(sp)
    80005dc8:	e022                	sd	s0,0(sp)
    80005dca:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80005dcc:	00003597          	auipc	a1,0x3
    80005dd0:	a6c58593          	addi	a1,a1,-1428 # 80008838 <syscalls+0x438>
    80005dd4:	0001c517          	auipc	a0,0x1c
    80005dd8:	efc50513          	addi	a0,a0,-260 # 80021cd0 <cons>
    80005ddc:	00000097          	auipc	ra,0x0
    80005de0:	590080e7          	jalr	1424(ra) # 8000636c <initlock>

  uartinit();
    80005de4:	00000097          	auipc	ra,0x0
    80005de8:	330080e7          	jalr	816(ra) # 80006114 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80005dec:	00013797          	auipc	a5,0x13
    80005df0:	c0c78793          	addi	a5,a5,-1012 # 800189f8 <devsw>
    80005df4:	00000717          	auipc	a4,0x0
    80005df8:	cde70713          	addi	a4,a4,-802 # 80005ad2 <consoleread>
    80005dfc:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80005dfe:	00000717          	auipc	a4,0x0
    80005e02:	c7270713          	addi	a4,a4,-910 # 80005a70 <consolewrite>
    80005e06:	ef98                	sd	a4,24(a5)
}
    80005e08:	60a2                	ld	ra,8(sp)
    80005e0a:	6402                	ld	s0,0(sp)
    80005e0c:	0141                	addi	sp,sp,16
    80005e0e:	8082                	ret

0000000080005e10 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    80005e10:	7179                	addi	sp,sp,-48
    80005e12:	f406                	sd	ra,40(sp)
    80005e14:	f022                	sd	s0,32(sp)
    80005e16:	ec26                	sd	s1,24(sp)
    80005e18:	e84a                	sd	s2,16(sp)
    80005e1a:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    80005e1c:	c219                	beqz	a2,80005e22 <printint+0x12>
    80005e1e:	08054663          	bltz	a0,80005eaa <printint+0x9a>
    x = -xx;
  else
    x = xx;
    80005e22:	2501                	sext.w	a0,a0
    80005e24:	4881                	li	a7,0
    80005e26:	fd040693          	addi	a3,s0,-48

  i = 0;
    80005e2a:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    80005e2c:	2581                	sext.w	a1,a1
    80005e2e:	00003617          	auipc	a2,0x3
    80005e32:	a3a60613          	addi	a2,a2,-1478 # 80008868 <digits>
    80005e36:	883a                	mv	a6,a4
    80005e38:	2705                	addiw	a4,a4,1
    80005e3a:	02b577bb          	remuw	a5,a0,a1
    80005e3e:	1782                	slli	a5,a5,0x20
    80005e40:	9381                	srli	a5,a5,0x20
    80005e42:	97b2                	add	a5,a5,a2
    80005e44:	0007c783          	lbu	a5,0(a5)
    80005e48:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    80005e4c:	0005079b          	sext.w	a5,a0
    80005e50:	02b5553b          	divuw	a0,a0,a1
    80005e54:	0685                	addi	a3,a3,1
    80005e56:	feb7f0e3          	bgeu	a5,a1,80005e36 <printint+0x26>

  if(sign)
    80005e5a:	00088b63          	beqz	a7,80005e70 <printint+0x60>
    buf[i++] = '-';
    80005e5e:	fe040793          	addi	a5,s0,-32
    80005e62:	973e                	add	a4,a4,a5
    80005e64:	02d00793          	li	a5,45
    80005e68:	fef70823          	sb	a5,-16(a4)
    80005e6c:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    80005e70:	02e05763          	blez	a4,80005e9e <printint+0x8e>
    80005e74:	fd040793          	addi	a5,s0,-48
    80005e78:	00e784b3          	add	s1,a5,a4
    80005e7c:	fff78913          	addi	s2,a5,-1
    80005e80:	993a                	add	s2,s2,a4
    80005e82:	377d                	addiw	a4,a4,-1
    80005e84:	1702                	slli	a4,a4,0x20
    80005e86:	9301                	srli	a4,a4,0x20
    80005e88:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80005e8c:	fff4c503          	lbu	a0,-1(s1)
    80005e90:	00000097          	auipc	ra,0x0
    80005e94:	d60080e7          	jalr	-672(ra) # 80005bf0 <consputc>
  while(--i >= 0)
    80005e98:	14fd                	addi	s1,s1,-1
    80005e9a:	ff2499e3          	bne	s1,s2,80005e8c <printint+0x7c>
}
    80005e9e:	70a2                	ld	ra,40(sp)
    80005ea0:	7402                	ld	s0,32(sp)
    80005ea2:	64e2                	ld	s1,24(sp)
    80005ea4:	6942                	ld	s2,16(sp)
    80005ea6:	6145                	addi	sp,sp,48
    80005ea8:	8082                	ret
    x = -xx;
    80005eaa:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80005eae:	4885                	li	a7,1
    x = -xx;
    80005eb0:	bf9d                	j	80005e26 <printint+0x16>

0000000080005eb2 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80005eb2:	1101                	addi	sp,sp,-32
    80005eb4:	ec06                	sd	ra,24(sp)
    80005eb6:	e822                	sd	s0,16(sp)
    80005eb8:	e426                	sd	s1,8(sp)
    80005eba:	1000                	addi	s0,sp,32
    80005ebc:	84aa                	mv	s1,a0
  pr.locking = 0;
    80005ebe:	0001c797          	auipc	a5,0x1c
    80005ec2:	ec07a923          	sw	zero,-302(a5) # 80021d90 <pr+0x18>
  printf("panic: ");
    80005ec6:	00003517          	auipc	a0,0x3
    80005eca:	97a50513          	addi	a0,a0,-1670 # 80008840 <syscalls+0x440>
    80005ece:	00000097          	auipc	ra,0x0
    80005ed2:	02e080e7          	jalr	46(ra) # 80005efc <printf>
  printf(s);
    80005ed6:	8526                	mv	a0,s1
    80005ed8:	00000097          	auipc	ra,0x0
    80005edc:	024080e7          	jalr	36(ra) # 80005efc <printf>
  printf("\n");
    80005ee0:	00002517          	auipc	a0,0x2
    80005ee4:	16850513          	addi	a0,a0,360 # 80008048 <etext+0x48>
    80005ee8:	00000097          	auipc	ra,0x0
    80005eec:	014080e7          	jalr	20(ra) # 80005efc <printf>
  panicked = 1; // freeze uart output from other CPUs
    80005ef0:	4785                	li	a5,1
    80005ef2:	00003717          	auipc	a4,0x3
    80005ef6:	a4f72d23          	sw	a5,-1446(a4) # 8000894c <panicked>
  for(;;)
    80005efa:	a001                	j	80005efa <panic+0x48>

0000000080005efc <printf>:
{
    80005efc:	7131                	addi	sp,sp,-192
    80005efe:	fc86                	sd	ra,120(sp)
    80005f00:	f8a2                	sd	s0,112(sp)
    80005f02:	f4a6                	sd	s1,104(sp)
    80005f04:	f0ca                	sd	s2,96(sp)
    80005f06:	ecce                	sd	s3,88(sp)
    80005f08:	e8d2                	sd	s4,80(sp)
    80005f0a:	e4d6                	sd	s5,72(sp)
    80005f0c:	e0da                	sd	s6,64(sp)
    80005f0e:	fc5e                	sd	s7,56(sp)
    80005f10:	f862                	sd	s8,48(sp)
    80005f12:	f466                	sd	s9,40(sp)
    80005f14:	f06a                	sd	s10,32(sp)
    80005f16:	ec6e                	sd	s11,24(sp)
    80005f18:	0100                	addi	s0,sp,128
    80005f1a:	8a2a                	mv	s4,a0
    80005f1c:	e40c                	sd	a1,8(s0)
    80005f1e:	e810                	sd	a2,16(s0)
    80005f20:	ec14                	sd	a3,24(s0)
    80005f22:	f018                	sd	a4,32(s0)
    80005f24:	f41c                	sd	a5,40(s0)
    80005f26:	03043823          	sd	a6,48(s0)
    80005f2a:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    80005f2e:	0001cd97          	auipc	s11,0x1c
    80005f32:	e62dad83          	lw	s11,-414(s11) # 80021d90 <pr+0x18>
  if(locking)
    80005f36:	020d9b63          	bnez	s11,80005f6c <printf+0x70>
  if (fmt == 0)
    80005f3a:	040a0263          	beqz	s4,80005f7e <printf+0x82>
  va_start(ap, fmt);
    80005f3e:	00840793          	addi	a5,s0,8
    80005f42:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80005f46:	000a4503          	lbu	a0,0(s4)
    80005f4a:	16050263          	beqz	a0,800060ae <printf+0x1b2>
    80005f4e:	4481                	li	s1,0
    if(c != '%'){
    80005f50:	02500a93          	li	s5,37
    switch(c){
    80005f54:	07000b13          	li	s6,112
  consputc('x');
    80005f58:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80005f5a:	00003b97          	auipc	s7,0x3
    80005f5e:	90eb8b93          	addi	s7,s7,-1778 # 80008868 <digits>
    switch(c){
    80005f62:	07300c93          	li	s9,115
    80005f66:	06400c13          	li	s8,100
    80005f6a:	a82d                	j	80005fa4 <printf+0xa8>
    acquire(&pr.lock);
    80005f6c:	0001c517          	auipc	a0,0x1c
    80005f70:	e0c50513          	addi	a0,a0,-500 # 80021d78 <pr>
    80005f74:	00000097          	auipc	ra,0x0
    80005f78:	488080e7          	jalr	1160(ra) # 800063fc <acquire>
    80005f7c:	bf7d                	j	80005f3a <printf+0x3e>
    panic("null fmt");
    80005f7e:	00003517          	auipc	a0,0x3
    80005f82:	8d250513          	addi	a0,a0,-1838 # 80008850 <syscalls+0x450>
    80005f86:	00000097          	auipc	ra,0x0
    80005f8a:	f2c080e7          	jalr	-212(ra) # 80005eb2 <panic>
      consputc(c);
    80005f8e:	00000097          	auipc	ra,0x0
    80005f92:	c62080e7          	jalr	-926(ra) # 80005bf0 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80005f96:	2485                	addiw	s1,s1,1
    80005f98:	009a07b3          	add	a5,s4,s1
    80005f9c:	0007c503          	lbu	a0,0(a5)
    80005fa0:	10050763          	beqz	a0,800060ae <printf+0x1b2>
    if(c != '%'){
    80005fa4:	ff5515e3          	bne	a0,s5,80005f8e <printf+0x92>
    c = fmt[++i] & 0xff;
    80005fa8:	2485                	addiw	s1,s1,1
    80005faa:	009a07b3          	add	a5,s4,s1
    80005fae:	0007c783          	lbu	a5,0(a5)
    80005fb2:	0007891b          	sext.w	s2,a5
    if(c == 0)
    80005fb6:	cfe5                	beqz	a5,800060ae <printf+0x1b2>
    switch(c){
    80005fb8:	05678a63          	beq	a5,s6,8000600c <printf+0x110>
    80005fbc:	02fb7663          	bgeu	s6,a5,80005fe8 <printf+0xec>
    80005fc0:	09978963          	beq	a5,s9,80006052 <printf+0x156>
    80005fc4:	07800713          	li	a4,120
    80005fc8:	0ce79863          	bne	a5,a4,80006098 <printf+0x19c>
      printint(va_arg(ap, int), 16, 1);
    80005fcc:	f8843783          	ld	a5,-120(s0)
    80005fd0:	00878713          	addi	a4,a5,8
    80005fd4:	f8e43423          	sd	a4,-120(s0)
    80005fd8:	4605                	li	a2,1
    80005fda:	85ea                	mv	a1,s10
    80005fdc:	4388                	lw	a0,0(a5)
    80005fde:	00000097          	auipc	ra,0x0
    80005fe2:	e32080e7          	jalr	-462(ra) # 80005e10 <printint>
      break;
    80005fe6:	bf45                	j	80005f96 <printf+0x9a>
    switch(c){
    80005fe8:	0b578263          	beq	a5,s5,8000608c <printf+0x190>
    80005fec:	0b879663          	bne	a5,s8,80006098 <printf+0x19c>
      printint(va_arg(ap, int), 10, 1);
    80005ff0:	f8843783          	ld	a5,-120(s0)
    80005ff4:	00878713          	addi	a4,a5,8
    80005ff8:	f8e43423          	sd	a4,-120(s0)
    80005ffc:	4605                	li	a2,1
    80005ffe:	45a9                	li	a1,10
    80006000:	4388                	lw	a0,0(a5)
    80006002:	00000097          	auipc	ra,0x0
    80006006:	e0e080e7          	jalr	-498(ra) # 80005e10 <printint>
      break;
    8000600a:	b771                	j	80005f96 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    8000600c:	f8843783          	ld	a5,-120(s0)
    80006010:	00878713          	addi	a4,a5,8
    80006014:	f8e43423          	sd	a4,-120(s0)
    80006018:	0007b983          	ld	s3,0(a5)
  consputc('0');
    8000601c:	03000513          	li	a0,48
    80006020:	00000097          	auipc	ra,0x0
    80006024:	bd0080e7          	jalr	-1072(ra) # 80005bf0 <consputc>
  consputc('x');
    80006028:	07800513          	li	a0,120
    8000602c:	00000097          	auipc	ra,0x0
    80006030:	bc4080e7          	jalr	-1084(ra) # 80005bf0 <consputc>
    80006034:	896a                	mv	s2,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80006036:	03c9d793          	srli	a5,s3,0x3c
    8000603a:	97de                	add	a5,a5,s7
    8000603c:	0007c503          	lbu	a0,0(a5)
    80006040:	00000097          	auipc	ra,0x0
    80006044:	bb0080e7          	jalr	-1104(ra) # 80005bf0 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80006048:	0992                	slli	s3,s3,0x4
    8000604a:	397d                	addiw	s2,s2,-1
    8000604c:	fe0915e3          	bnez	s2,80006036 <printf+0x13a>
    80006050:	b799                	j	80005f96 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    80006052:	f8843783          	ld	a5,-120(s0)
    80006056:	00878713          	addi	a4,a5,8
    8000605a:	f8e43423          	sd	a4,-120(s0)
    8000605e:	0007b903          	ld	s2,0(a5)
    80006062:	00090e63          	beqz	s2,8000607e <printf+0x182>
      for(; *s; s++)
    80006066:	00094503          	lbu	a0,0(s2)
    8000606a:	d515                	beqz	a0,80005f96 <printf+0x9a>
        consputc(*s);
    8000606c:	00000097          	auipc	ra,0x0
    80006070:	b84080e7          	jalr	-1148(ra) # 80005bf0 <consputc>
      for(; *s; s++)
    80006074:	0905                	addi	s2,s2,1
    80006076:	00094503          	lbu	a0,0(s2)
    8000607a:	f96d                	bnez	a0,8000606c <printf+0x170>
    8000607c:	bf29                	j	80005f96 <printf+0x9a>
        s = "(null)";
    8000607e:	00002917          	auipc	s2,0x2
    80006082:	7ca90913          	addi	s2,s2,1994 # 80008848 <syscalls+0x448>
      for(; *s; s++)
    80006086:	02800513          	li	a0,40
    8000608a:	b7cd                	j	8000606c <printf+0x170>
      consputc('%');
    8000608c:	8556                	mv	a0,s5
    8000608e:	00000097          	auipc	ra,0x0
    80006092:	b62080e7          	jalr	-1182(ra) # 80005bf0 <consputc>
      break;
    80006096:	b701                	j	80005f96 <printf+0x9a>
      consputc('%');
    80006098:	8556                	mv	a0,s5
    8000609a:	00000097          	auipc	ra,0x0
    8000609e:	b56080e7          	jalr	-1194(ra) # 80005bf0 <consputc>
      consputc(c);
    800060a2:	854a                	mv	a0,s2
    800060a4:	00000097          	auipc	ra,0x0
    800060a8:	b4c080e7          	jalr	-1204(ra) # 80005bf0 <consputc>
      break;
    800060ac:	b5ed                	j	80005f96 <printf+0x9a>
  if(locking)
    800060ae:	020d9163          	bnez	s11,800060d0 <printf+0x1d4>
}
    800060b2:	70e6                	ld	ra,120(sp)
    800060b4:	7446                	ld	s0,112(sp)
    800060b6:	74a6                	ld	s1,104(sp)
    800060b8:	7906                	ld	s2,96(sp)
    800060ba:	69e6                	ld	s3,88(sp)
    800060bc:	6a46                	ld	s4,80(sp)
    800060be:	6aa6                	ld	s5,72(sp)
    800060c0:	6b06                	ld	s6,64(sp)
    800060c2:	7be2                	ld	s7,56(sp)
    800060c4:	7c42                	ld	s8,48(sp)
    800060c6:	7ca2                	ld	s9,40(sp)
    800060c8:	7d02                	ld	s10,32(sp)
    800060ca:	6de2                	ld	s11,24(sp)
    800060cc:	6129                	addi	sp,sp,192
    800060ce:	8082                	ret
    release(&pr.lock);
    800060d0:	0001c517          	auipc	a0,0x1c
    800060d4:	ca850513          	addi	a0,a0,-856 # 80021d78 <pr>
    800060d8:	00000097          	auipc	ra,0x0
    800060dc:	3d8080e7          	jalr	984(ra) # 800064b0 <release>
}
    800060e0:	bfc9                	j	800060b2 <printf+0x1b6>

00000000800060e2 <printfinit>:
    ;
}

void
printfinit(void)
{
    800060e2:	1101                	addi	sp,sp,-32
    800060e4:	ec06                	sd	ra,24(sp)
    800060e6:	e822                	sd	s0,16(sp)
    800060e8:	e426                	sd	s1,8(sp)
    800060ea:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    800060ec:	0001c497          	auipc	s1,0x1c
    800060f0:	c8c48493          	addi	s1,s1,-884 # 80021d78 <pr>
    800060f4:	00002597          	auipc	a1,0x2
    800060f8:	76c58593          	addi	a1,a1,1900 # 80008860 <syscalls+0x460>
    800060fc:	8526                	mv	a0,s1
    800060fe:	00000097          	auipc	ra,0x0
    80006102:	26e080e7          	jalr	622(ra) # 8000636c <initlock>
  pr.locking = 1;
    80006106:	4785                	li	a5,1
    80006108:	cc9c                	sw	a5,24(s1)
}
    8000610a:	60e2                	ld	ra,24(sp)
    8000610c:	6442                	ld	s0,16(sp)
    8000610e:	64a2                	ld	s1,8(sp)
    80006110:	6105                	addi	sp,sp,32
    80006112:	8082                	ret

0000000080006114 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80006114:	1141                	addi	sp,sp,-16
    80006116:	e406                	sd	ra,8(sp)
    80006118:	e022                	sd	s0,0(sp)
    8000611a:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    8000611c:	100007b7          	lui	a5,0x10000
    80006120:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80006124:	f8000713          	li	a4,-128
    80006128:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    8000612c:	470d                	li	a4,3
    8000612e:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80006132:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80006136:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    8000613a:	469d                	li	a3,7
    8000613c:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80006140:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    80006144:	00002597          	auipc	a1,0x2
    80006148:	73c58593          	addi	a1,a1,1852 # 80008880 <digits+0x18>
    8000614c:	0001c517          	auipc	a0,0x1c
    80006150:	c4c50513          	addi	a0,a0,-948 # 80021d98 <uart_tx_lock>
    80006154:	00000097          	auipc	ra,0x0
    80006158:	218080e7          	jalr	536(ra) # 8000636c <initlock>
}
    8000615c:	60a2                	ld	ra,8(sp)
    8000615e:	6402                	ld	s0,0(sp)
    80006160:	0141                	addi	sp,sp,16
    80006162:	8082                	ret

0000000080006164 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80006164:	1101                	addi	sp,sp,-32
    80006166:	ec06                	sd	ra,24(sp)
    80006168:	e822                	sd	s0,16(sp)
    8000616a:	e426                	sd	s1,8(sp)
    8000616c:	1000                	addi	s0,sp,32
    8000616e:	84aa                	mv	s1,a0
  push_off();
    80006170:	00000097          	auipc	ra,0x0
    80006174:	240080e7          	jalr	576(ra) # 800063b0 <push_off>

  if(panicked){
    80006178:	00002797          	auipc	a5,0x2
    8000617c:	7d47a783          	lw	a5,2004(a5) # 8000894c <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80006180:	10000737          	lui	a4,0x10000
  if(panicked){
    80006184:	c391                	beqz	a5,80006188 <uartputc_sync+0x24>
    for(;;)
    80006186:	a001                	j	80006186 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80006188:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    8000618c:	0ff7f793          	andi	a5,a5,255
    80006190:	0207f793          	andi	a5,a5,32
    80006194:	dbf5                	beqz	a5,80006188 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80006196:	0ff4f793          	andi	a5,s1,255
    8000619a:	10000737          	lui	a4,0x10000
    8000619e:	00f70023          	sb	a5,0(a4) # 10000000 <_entry-0x70000000>

  pop_off();
    800061a2:	00000097          	auipc	ra,0x0
    800061a6:	2ae080e7          	jalr	686(ra) # 80006450 <pop_off>
}
    800061aa:	60e2                	ld	ra,24(sp)
    800061ac:	6442                	ld	s0,16(sp)
    800061ae:	64a2                	ld	s1,8(sp)
    800061b0:	6105                	addi	sp,sp,32
    800061b2:	8082                	ret

00000000800061b4 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    800061b4:	00002717          	auipc	a4,0x2
    800061b8:	79c73703          	ld	a4,1948(a4) # 80008950 <uart_tx_r>
    800061bc:	00002797          	auipc	a5,0x2
    800061c0:	79c7b783          	ld	a5,1948(a5) # 80008958 <uart_tx_w>
    800061c4:	06e78c63          	beq	a5,a4,8000623c <uartstart+0x88>
{
    800061c8:	7139                	addi	sp,sp,-64
    800061ca:	fc06                	sd	ra,56(sp)
    800061cc:	f822                	sd	s0,48(sp)
    800061ce:	f426                	sd	s1,40(sp)
    800061d0:	f04a                	sd	s2,32(sp)
    800061d2:	ec4e                	sd	s3,24(sp)
    800061d4:	e852                	sd	s4,16(sp)
    800061d6:	e456                	sd	s5,8(sp)
    800061d8:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800061da:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800061de:	0001ca17          	auipc	s4,0x1c
    800061e2:	bbaa0a13          	addi	s4,s4,-1094 # 80021d98 <uart_tx_lock>
    uart_tx_r += 1;
    800061e6:	00002497          	auipc	s1,0x2
    800061ea:	76a48493          	addi	s1,s1,1898 # 80008950 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    800061ee:	00002997          	auipc	s3,0x2
    800061f2:	76a98993          	addi	s3,s3,1898 # 80008958 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800061f6:	00594783          	lbu	a5,5(s2) # 10000005 <_entry-0x6ffffffb>
    800061fa:	0ff7f793          	andi	a5,a5,255
    800061fe:	0207f793          	andi	a5,a5,32
    80006202:	c785                	beqz	a5,8000622a <uartstart+0x76>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80006204:	01f77793          	andi	a5,a4,31
    80006208:	97d2                	add	a5,a5,s4
    8000620a:	0187ca83          	lbu	s5,24(a5)
    uart_tx_r += 1;
    8000620e:	0705                	addi	a4,a4,1
    80006210:	e098                	sd	a4,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    80006212:	8526                	mv	a0,s1
    80006214:	ffffb097          	auipc	ra,0xffffb
    80006218:	52e080e7          	jalr	1326(ra) # 80001742 <wakeup>
    
    WriteReg(THR, c);
    8000621c:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    80006220:	6098                	ld	a4,0(s1)
    80006222:	0009b783          	ld	a5,0(s3)
    80006226:	fce798e3          	bne	a5,a4,800061f6 <uartstart+0x42>
  }
}
    8000622a:	70e2                	ld	ra,56(sp)
    8000622c:	7442                	ld	s0,48(sp)
    8000622e:	74a2                	ld	s1,40(sp)
    80006230:	7902                	ld	s2,32(sp)
    80006232:	69e2                	ld	s3,24(sp)
    80006234:	6a42                	ld	s4,16(sp)
    80006236:	6aa2                	ld	s5,8(sp)
    80006238:	6121                	addi	sp,sp,64
    8000623a:	8082                	ret
    8000623c:	8082                	ret

000000008000623e <uartputc>:
{
    8000623e:	7179                	addi	sp,sp,-48
    80006240:	f406                	sd	ra,40(sp)
    80006242:	f022                	sd	s0,32(sp)
    80006244:	ec26                	sd	s1,24(sp)
    80006246:	e84a                	sd	s2,16(sp)
    80006248:	e44e                	sd	s3,8(sp)
    8000624a:	e052                	sd	s4,0(sp)
    8000624c:	1800                	addi	s0,sp,48
    8000624e:	89aa                	mv	s3,a0
  acquire(&uart_tx_lock);
    80006250:	0001c517          	auipc	a0,0x1c
    80006254:	b4850513          	addi	a0,a0,-1208 # 80021d98 <uart_tx_lock>
    80006258:	00000097          	auipc	ra,0x0
    8000625c:	1a4080e7          	jalr	420(ra) # 800063fc <acquire>
  if(panicked){
    80006260:	00002797          	auipc	a5,0x2
    80006264:	6ec7a783          	lw	a5,1772(a5) # 8000894c <panicked>
    80006268:	e7c9                	bnez	a5,800062f2 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000626a:	00002797          	auipc	a5,0x2
    8000626e:	6ee7b783          	ld	a5,1774(a5) # 80008958 <uart_tx_w>
    80006272:	00002717          	auipc	a4,0x2
    80006276:	6de73703          	ld	a4,1758(a4) # 80008950 <uart_tx_r>
    8000627a:	02070713          	addi	a4,a4,32
    sleep(&uart_tx_r, &uart_tx_lock);
    8000627e:	0001ca17          	auipc	s4,0x1c
    80006282:	b1aa0a13          	addi	s4,s4,-1254 # 80021d98 <uart_tx_lock>
    80006286:	00002497          	auipc	s1,0x2
    8000628a:	6ca48493          	addi	s1,s1,1738 # 80008950 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000628e:	00002917          	auipc	s2,0x2
    80006292:	6ca90913          	addi	s2,s2,1738 # 80008958 <uart_tx_w>
    80006296:	00f71f63          	bne	a4,a5,800062b4 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000629a:	85d2                	mv	a1,s4
    8000629c:	8526                	mv	a0,s1
    8000629e:	ffffb097          	auipc	ra,0xffffb
    800062a2:	440080e7          	jalr	1088(ra) # 800016de <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800062a6:	00093783          	ld	a5,0(s2)
    800062aa:	6098                	ld	a4,0(s1)
    800062ac:	02070713          	addi	a4,a4,32
    800062b0:	fef705e3          	beq	a4,a5,8000629a <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800062b4:	0001c497          	auipc	s1,0x1c
    800062b8:	ae448493          	addi	s1,s1,-1308 # 80021d98 <uart_tx_lock>
    800062bc:	01f7f713          	andi	a4,a5,31
    800062c0:	9726                	add	a4,a4,s1
    800062c2:	01370c23          	sb	s3,24(a4)
  uart_tx_w += 1;
    800062c6:	0785                	addi	a5,a5,1
    800062c8:	00002717          	auipc	a4,0x2
    800062cc:	68f73823          	sd	a5,1680(a4) # 80008958 <uart_tx_w>
  uartstart();
    800062d0:	00000097          	auipc	ra,0x0
    800062d4:	ee4080e7          	jalr	-284(ra) # 800061b4 <uartstart>
  release(&uart_tx_lock);
    800062d8:	8526                	mv	a0,s1
    800062da:	00000097          	auipc	ra,0x0
    800062de:	1d6080e7          	jalr	470(ra) # 800064b0 <release>
}
    800062e2:	70a2                	ld	ra,40(sp)
    800062e4:	7402                	ld	s0,32(sp)
    800062e6:	64e2                	ld	s1,24(sp)
    800062e8:	6942                	ld	s2,16(sp)
    800062ea:	69a2                	ld	s3,8(sp)
    800062ec:	6a02                	ld	s4,0(sp)
    800062ee:	6145                	addi	sp,sp,48
    800062f0:	8082                	ret
    for(;;)
    800062f2:	a001                	j	800062f2 <uartputc+0xb4>

00000000800062f4 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800062f4:	1141                	addi	sp,sp,-16
    800062f6:	e422                	sd	s0,8(sp)
    800062f8:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800062fa:	100007b7          	lui	a5,0x10000
    800062fe:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80006302:	8b85                	andi	a5,a5,1
    80006304:	cb91                	beqz	a5,80006318 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80006306:	100007b7          	lui	a5,0x10000
    8000630a:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    8000630e:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    80006312:	6422                	ld	s0,8(sp)
    80006314:	0141                	addi	sp,sp,16
    80006316:	8082                	ret
    return -1;
    80006318:	557d                	li	a0,-1
    8000631a:	bfe5                	j	80006312 <uartgetc+0x1e>

000000008000631c <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    8000631c:	1101                	addi	sp,sp,-32
    8000631e:	ec06                	sd	ra,24(sp)
    80006320:	e822                	sd	s0,16(sp)
    80006322:	e426                	sd	s1,8(sp)
    80006324:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80006326:	54fd                	li	s1,-1
    int c = uartgetc();
    80006328:	00000097          	auipc	ra,0x0
    8000632c:	fcc080e7          	jalr	-52(ra) # 800062f4 <uartgetc>
    if(c == -1)
    80006330:	00950763          	beq	a0,s1,8000633e <uartintr+0x22>
      break;
    consoleintr(c);
    80006334:	00000097          	auipc	ra,0x0
    80006338:	8fe080e7          	jalr	-1794(ra) # 80005c32 <consoleintr>
  while(1){
    8000633c:	b7f5                	j	80006328 <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    8000633e:	0001c497          	auipc	s1,0x1c
    80006342:	a5a48493          	addi	s1,s1,-1446 # 80021d98 <uart_tx_lock>
    80006346:	8526                	mv	a0,s1
    80006348:	00000097          	auipc	ra,0x0
    8000634c:	0b4080e7          	jalr	180(ra) # 800063fc <acquire>
  uartstart();
    80006350:	00000097          	auipc	ra,0x0
    80006354:	e64080e7          	jalr	-412(ra) # 800061b4 <uartstart>
  release(&uart_tx_lock);
    80006358:	8526                	mv	a0,s1
    8000635a:	00000097          	auipc	ra,0x0
    8000635e:	156080e7          	jalr	342(ra) # 800064b0 <release>
}
    80006362:	60e2                	ld	ra,24(sp)
    80006364:	6442                	ld	s0,16(sp)
    80006366:	64a2                	ld	s1,8(sp)
    80006368:	6105                	addi	sp,sp,32
    8000636a:	8082                	ret

000000008000636c <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    8000636c:	1141                	addi	sp,sp,-16
    8000636e:	e422                	sd	s0,8(sp)
    80006370:	0800                	addi	s0,sp,16
  lk->name = name;
    80006372:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80006374:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80006378:	00053823          	sd	zero,16(a0)
}
    8000637c:	6422                	ld	s0,8(sp)
    8000637e:	0141                	addi	sp,sp,16
    80006380:	8082                	ret

0000000080006382 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80006382:	411c                	lw	a5,0(a0)
    80006384:	e399                	bnez	a5,8000638a <holding+0x8>
    80006386:	4501                	li	a0,0
  return r;
}
    80006388:	8082                	ret
{
    8000638a:	1101                	addi	sp,sp,-32
    8000638c:	ec06                	sd	ra,24(sp)
    8000638e:	e822                	sd	s0,16(sp)
    80006390:	e426                	sd	s1,8(sp)
    80006392:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80006394:	6904                	ld	s1,16(a0)
    80006396:	ffffb097          	auipc	ra,0xffffb
    8000639a:	b82080e7          	jalr	-1150(ra) # 80000f18 <mycpu>
    8000639e:	40a48533          	sub	a0,s1,a0
    800063a2:	00153513          	seqz	a0,a0
}
    800063a6:	60e2                	ld	ra,24(sp)
    800063a8:	6442                	ld	s0,16(sp)
    800063aa:	64a2                	ld	s1,8(sp)
    800063ac:	6105                	addi	sp,sp,32
    800063ae:	8082                	ret

00000000800063b0 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    800063b0:	1101                	addi	sp,sp,-32
    800063b2:	ec06                	sd	ra,24(sp)
    800063b4:	e822                	sd	s0,16(sp)
    800063b6:	e426                	sd	s1,8(sp)
    800063b8:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800063ba:	100024f3          	csrr	s1,sstatus
    800063be:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800063c2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800063c4:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    800063c8:	ffffb097          	auipc	ra,0xffffb
    800063cc:	b50080e7          	jalr	-1200(ra) # 80000f18 <mycpu>
    800063d0:	5d3c                	lw	a5,120(a0)
    800063d2:	cf89                	beqz	a5,800063ec <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    800063d4:	ffffb097          	auipc	ra,0xffffb
    800063d8:	b44080e7          	jalr	-1212(ra) # 80000f18 <mycpu>
    800063dc:	5d3c                	lw	a5,120(a0)
    800063de:	2785                	addiw	a5,a5,1
    800063e0:	dd3c                	sw	a5,120(a0)
}
    800063e2:	60e2                	ld	ra,24(sp)
    800063e4:	6442                	ld	s0,16(sp)
    800063e6:	64a2                	ld	s1,8(sp)
    800063e8:	6105                	addi	sp,sp,32
    800063ea:	8082                	ret
    mycpu()->intena = old;
    800063ec:	ffffb097          	auipc	ra,0xffffb
    800063f0:	b2c080e7          	jalr	-1236(ra) # 80000f18 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    800063f4:	8085                	srli	s1,s1,0x1
    800063f6:	8885                	andi	s1,s1,1
    800063f8:	dd64                	sw	s1,124(a0)
    800063fa:	bfe9                	j	800063d4 <push_off+0x24>

00000000800063fc <acquire>:
{
    800063fc:	1101                	addi	sp,sp,-32
    800063fe:	ec06                	sd	ra,24(sp)
    80006400:	e822                	sd	s0,16(sp)
    80006402:	e426                	sd	s1,8(sp)
    80006404:	1000                	addi	s0,sp,32
    80006406:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80006408:	00000097          	auipc	ra,0x0
    8000640c:	fa8080e7          	jalr	-88(ra) # 800063b0 <push_off>
  if(holding(lk))
    80006410:	8526                	mv	a0,s1
    80006412:	00000097          	auipc	ra,0x0
    80006416:	f70080e7          	jalr	-144(ra) # 80006382 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    8000641a:	4705                	li	a4,1
  if(holding(lk))
    8000641c:	e115                	bnez	a0,80006440 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    8000641e:	87ba                	mv	a5,a4
    80006420:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80006424:	2781                	sext.w	a5,a5
    80006426:	ffe5                	bnez	a5,8000641e <acquire+0x22>
  __sync_synchronize();
    80006428:	0ff0000f          	fence
  lk->cpu = mycpu();
    8000642c:	ffffb097          	auipc	ra,0xffffb
    80006430:	aec080e7          	jalr	-1300(ra) # 80000f18 <mycpu>
    80006434:	e888                	sd	a0,16(s1)
}
    80006436:	60e2                	ld	ra,24(sp)
    80006438:	6442                	ld	s0,16(sp)
    8000643a:	64a2                	ld	s1,8(sp)
    8000643c:	6105                	addi	sp,sp,32
    8000643e:	8082                	ret
    panic("acquire");
    80006440:	00002517          	auipc	a0,0x2
    80006444:	44850513          	addi	a0,a0,1096 # 80008888 <digits+0x20>
    80006448:	00000097          	auipc	ra,0x0
    8000644c:	a6a080e7          	jalr	-1430(ra) # 80005eb2 <panic>

0000000080006450 <pop_off>:

void
pop_off(void)
{
    80006450:	1141                	addi	sp,sp,-16
    80006452:	e406                	sd	ra,8(sp)
    80006454:	e022                	sd	s0,0(sp)
    80006456:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80006458:	ffffb097          	auipc	ra,0xffffb
    8000645c:	ac0080e7          	jalr	-1344(ra) # 80000f18 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80006460:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80006464:	8b89                	andi	a5,a5,2
  if(intr_get())
    80006466:	e78d                	bnez	a5,80006490 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80006468:	5d3c                	lw	a5,120(a0)
    8000646a:	02f05b63          	blez	a5,800064a0 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    8000646e:	37fd                	addiw	a5,a5,-1
    80006470:	0007871b          	sext.w	a4,a5
    80006474:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80006476:	eb09                	bnez	a4,80006488 <pop_off+0x38>
    80006478:	5d7c                	lw	a5,124(a0)
    8000647a:	c799                	beqz	a5,80006488 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000647c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80006480:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80006484:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80006488:	60a2                	ld	ra,8(sp)
    8000648a:	6402                	ld	s0,0(sp)
    8000648c:	0141                	addi	sp,sp,16
    8000648e:	8082                	ret
    panic("pop_off - interruptible");
    80006490:	00002517          	auipc	a0,0x2
    80006494:	40050513          	addi	a0,a0,1024 # 80008890 <digits+0x28>
    80006498:	00000097          	auipc	ra,0x0
    8000649c:	a1a080e7          	jalr	-1510(ra) # 80005eb2 <panic>
    panic("pop_off");
    800064a0:	00002517          	auipc	a0,0x2
    800064a4:	40850513          	addi	a0,a0,1032 # 800088a8 <digits+0x40>
    800064a8:	00000097          	auipc	ra,0x0
    800064ac:	a0a080e7          	jalr	-1526(ra) # 80005eb2 <panic>

00000000800064b0 <release>:
{
    800064b0:	1101                	addi	sp,sp,-32
    800064b2:	ec06                	sd	ra,24(sp)
    800064b4:	e822                	sd	s0,16(sp)
    800064b6:	e426                	sd	s1,8(sp)
    800064b8:	1000                	addi	s0,sp,32
    800064ba:	84aa                	mv	s1,a0
  if(!holding(lk))
    800064bc:	00000097          	auipc	ra,0x0
    800064c0:	ec6080e7          	jalr	-314(ra) # 80006382 <holding>
    800064c4:	c115                	beqz	a0,800064e8 <release+0x38>
  lk->cpu = 0;
    800064c6:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    800064ca:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    800064ce:	0f50000f          	fence	iorw,ow
    800064d2:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    800064d6:	00000097          	auipc	ra,0x0
    800064da:	f7a080e7          	jalr	-134(ra) # 80006450 <pop_off>
}
    800064de:	60e2                	ld	ra,24(sp)
    800064e0:	6442                	ld	s0,16(sp)
    800064e2:	64a2                	ld	s1,8(sp)
    800064e4:	6105                	addi	sp,sp,32
    800064e6:	8082                	ret
    panic("release");
    800064e8:	00002517          	auipc	a0,0x2
    800064ec:	3c850513          	addi	a0,a0,968 # 800088b0 <digits+0x48>
    800064f0:	00000097          	auipc	ra,0x0
    800064f4:	9c2080e7          	jalr	-1598(ra) # 80005eb2 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
