
obj/fs/fs:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 d3 1a 00 00       	call   801b04 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <ide_wait_ready>:

static int diskno = 1;

static int
ide_wait_ready(bool check_error)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	89 c1                	mov    %eax,%ecx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800039:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80003e:	ec                   	in     (%dx),%al
  80003f:	89 c3                	mov    %eax,%ebx
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
  800041:	83 e0 c0             	and    $0xffffffc0,%eax
  800044:	3c 40                	cmp    $0x40,%al
  800046:	75 f6                	jne    80003e <ide_wait_ready+0xb>
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
		return -1;
	return 0;
  800048:	b8 00 00 00 00       	mov    $0x0,%eax
	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
  80004d:	84 c9                	test   %cl,%cl
  80004f:	74 0b                	je     80005c <ide_wait_ready+0x29>
  800051:	f6 c3 21             	test   $0x21,%bl
  800054:	0f 95 c0             	setne  %al
  800057:	0f b6 c0             	movzbl %al,%eax
  80005a:	f7 d8                	neg    %eax
}
  80005c:	5b                   	pop    %ebx
  80005d:	5d                   	pop    %ebp
  80005e:	c3                   	ret    

0080005f <ide_probe_disk1>:

bool
ide_probe_disk1(void)
{
  80005f:	55                   	push   %ebp
  800060:	89 e5                	mov    %esp,%ebp
  800062:	53                   	push   %ebx
  800063:	83 ec 04             	sub    $0x4,%esp
	int r, x;

	// wait for Device 0 to be ready
	ide_wait_ready(0);
  800066:	b8 00 00 00 00       	mov    $0x0,%eax
  80006b:	e8 c3 ff ff ff       	call   800033 <ide_wait_ready>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800070:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  800075:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80007a:	ee                   	out    %al,(%dx)

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80007b:	b9 00 00 00 00       	mov    $0x0,%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800080:	ba f7 01 00 00       	mov    $0x1f7,%edx
  800085:	ec                   	in     (%dx),%al
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
  800086:	a8 a1                	test   $0xa1,%al
  800088:	74 0b                	je     800095 <ide_probe_disk1+0x36>
	     x++)
  80008a:	83 c1 01             	add    $0x1,%ecx
	for (x = 0;
  80008d:	81 f9 e8 03 00 00    	cmp    $0x3e8,%ecx
  800093:	75 f0                	jne    800085 <ide_probe_disk1+0x26>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800095:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
  80009a:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80009f:	ee                   	out    %al,(%dx)
		/* do nothing */;

	// switch back to Device 0
	outb(0x1F6, 0xE0 | (0<<4));

	cprintf("Device 1 presence: %d\n", (x < 1000));
  8000a0:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
  8000a6:	0f 9e c3             	setle  %bl
  8000a9:	83 ec 08             	sub    $0x8,%esp
  8000ac:	0f b6 c3             	movzbl %bl,%eax
  8000af:	50                   	push   %eax
  8000b0:	68 20 39 80 00       	push   $0x803920
  8000b5:	e8 85 1b 00 00       	call   801c3f <cprintf>
	return (x < 1000);
}
  8000ba:	89 d8                	mov    %ebx,%eax
  8000bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000bf:	c9                   	leave  
  8000c0:	c3                   	ret    

008000c1 <ide_set_disk>:

void
ide_set_disk(int d)
{
  8000c1:	55                   	push   %ebp
  8000c2:	89 e5                	mov    %esp,%ebp
  8000c4:	83 ec 08             	sub    $0x8,%esp
  8000c7:	8b 45 08             	mov    0x8(%ebp),%eax
	if (d != 0 && d != 1)
  8000ca:	83 f8 01             	cmp    $0x1,%eax
  8000cd:	77 07                	ja     8000d6 <ide_set_disk+0x15>
		panic("bad disk number");
	diskno = d;
  8000cf:	a3 00 50 80 00       	mov    %eax,0x805000
}
  8000d4:	c9                   	leave  
  8000d5:	c3                   	ret    
		panic("bad disk number");
  8000d6:	83 ec 04             	sub    $0x4,%esp
  8000d9:	68 37 39 80 00       	push   $0x803937
  8000de:	6a 3a                	push   $0x3a
  8000e0:	68 47 39 80 00       	push   $0x803947
  8000e5:	e8 7a 1a 00 00       	call   801b64 <_panic>

008000ea <ide_read>:


int
ide_read(uint32_t secno, void *dst, size_t nsecs)
{
  8000ea:	55                   	push   %ebp
  8000eb:	89 e5                	mov    %esp,%ebp
  8000ed:	57                   	push   %edi
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
  8000f0:	83 ec 0c             	sub    $0xc,%esp
  8000f3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8000f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000f9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	assert(nsecs <= 256);
  8000fc:	81 fe 00 01 00 00    	cmp    $0x100,%esi
  800102:	0f 87 87 00 00 00    	ja     80018f <ide_read+0xa5>

	ide_wait_ready(0);
  800108:	b8 00 00 00 00       	mov    $0x0,%eax
  80010d:	e8 21 ff ff ff       	call   800033 <ide_wait_ready>
  800112:	ba f2 01 00 00       	mov    $0x1f2,%edx
  800117:	89 f0                	mov    %esi,%eax
  800119:	ee                   	out    %al,(%dx)
  80011a:	ba f3 01 00 00       	mov    $0x1f3,%edx
  80011f:	89 f8                	mov    %edi,%eax
  800121:	ee                   	out    %al,(%dx)

	outb(0x1F2, nsecs);
	outb(0x1F3, secno & 0xFF);
	outb(0x1F4, (secno >> 8) & 0xFF);
  800122:	89 f8                	mov    %edi,%eax
  800124:	c1 e8 08             	shr    $0x8,%eax
  800127:	ba f4 01 00 00       	mov    $0x1f4,%edx
  80012c:	ee                   	out    %al,(%dx)
	outb(0x1F5, (secno >> 16) & 0xFF);
  80012d:	89 f8                	mov    %edi,%eax
  80012f:	c1 e8 10             	shr    $0x10,%eax
  800132:	ba f5 01 00 00       	mov    $0x1f5,%edx
  800137:	ee                   	out    %al,(%dx)
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
  800138:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
  80013f:	c1 e0 04             	shl    $0x4,%eax
  800142:	83 e0 10             	and    $0x10,%eax
  800145:	83 c8 e0             	or     $0xffffffe0,%eax
  800148:	c1 ef 18             	shr    $0x18,%edi
  80014b:	83 e7 0f             	and    $0xf,%edi
  80014e:	09 f8                	or     %edi,%eax
  800150:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800155:	ee                   	out    %al,(%dx)
  800156:	b8 20 00 00 00       	mov    $0x20,%eax
  80015b:	ba f7 01 00 00       	mov    $0x1f7,%edx
  800160:	ee                   	out    %al,(%dx)
  800161:	c1 e6 09             	shl    $0x9,%esi
  800164:	01 de                	add    %ebx,%esi
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  800166:	39 f3                	cmp    %esi,%ebx
  800168:	74 3b                	je     8001a5 <ide_read+0xbb>
		if ((r = ide_wait_ready(1)) < 0)
  80016a:	b8 01 00 00 00       	mov    $0x1,%eax
  80016f:	e8 bf fe ff ff       	call   800033 <ide_wait_ready>
  800174:	85 c0                	test   %eax,%eax
  800176:	78 32                	js     8001aa <ide_read+0xc0>
	asm volatile("cld\n\trepne\n\tinsl"
  800178:	89 df                	mov    %ebx,%edi
  80017a:	b9 80 00 00 00       	mov    $0x80,%ecx
  80017f:	ba f0 01 00 00       	mov    $0x1f0,%edx
  800184:	fc                   	cld    
  800185:	f2 6d                	repnz insl (%dx),%es:(%edi)
	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  800187:	81 c3 00 02 00 00    	add    $0x200,%ebx
  80018d:	eb d7                	jmp    800166 <ide_read+0x7c>
	assert(nsecs <= 256);
  80018f:	68 50 39 80 00       	push   $0x803950
  800194:	68 5d 39 80 00       	push   $0x80395d
  800199:	6a 44                	push   $0x44
  80019b:	68 47 39 80 00       	push   $0x803947
  8001a0:	e8 bf 19 00 00       	call   801b64 <_panic>
			return r;
		insl(0x1F0, dst, SECTSIZE/4);
	}

	return 0;
  8001a5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8001aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ad:	5b                   	pop    %ebx
  8001ae:	5e                   	pop    %esi
  8001af:	5f                   	pop    %edi
  8001b0:	5d                   	pop    %ebp
  8001b1:	c3                   	ret    

008001b2 <ide_write>:

int
ide_write(uint32_t secno, const void *src, size_t nsecs)
{
  8001b2:	55                   	push   %ebp
  8001b3:	89 e5                	mov    %esp,%ebp
  8001b5:	57                   	push   %edi
  8001b6:	56                   	push   %esi
  8001b7:	53                   	push   %ebx
  8001b8:	83 ec 0c             	sub    $0xc,%esp
  8001bb:	8b 75 08             	mov    0x8(%ebp),%esi
  8001be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8001c1:	8b 7d 10             	mov    0x10(%ebp),%edi
	int r;

	assert(nsecs <= 256);
  8001c4:	81 ff 00 01 00 00    	cmp    $0x100,%edi
  8001ca:	0f 87 87 00 00 00    	ja     800257 <ide_write+0xa5>

	ide_wait_ready(0);
  8001d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8001d5:	e8 59 fe ff ff       	call   800033 <ide_wait_ready>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8001da:	ba f2 01 00 00       	mov    $0x1f2,%edx
  8001df:	89 f8                	mov    %edi,%eax
  8001e1:	ee                   	out    %al,(%dx)
  8001e2:	ba f3 01 00 00       	mov    $0x1f3,%edx
  8001e7:	89 f0                	mov    %esi,%eax
  8001e9:	ee                   	out    %al,(%dx)

	outb(0x1F2, nsecs);
	outb(0x1F3, secno & 0xFF);
	outb(0x1F4, (secno >> 8) & 0xFF);
  8001ea:	89 f0                	mov    %esi,%eax
  8001ec:	c1 e8 08             	shr    $0x8,%eax
  8001ef:	ba f4 01 00 00       	mov    $0x1f4,%edx
  8001f4:	ee                   	out    %al,(%dx)
	outb(0x1F5, (secno >> 16) & 0xFF);
  8001f5:	89 f0                	mov    %esi,%eax
  8001f7:	c1 e8 10             	shr    $0x10,%eax
  8001fa:	ba f5 01 00 00       	mov    $0x1f5,%edx
  8001ff:	ee                   	out    %al,(%dx)
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
  800200:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
  800207:	c1 e0 04             	shl    $0x4,%eax
  80020a:	83 e0 10             	and    $0x10,%eax
  80020d:	83 c8 e0             	or     $0xffffffe0,%eax
  800210:	c1 ee 18             	shr    $0x18,%esi
  800213:	83 e6 0f             	and    $0xf,%esi
  800216:	09 f0                	or     %esi,%eax
  800218:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80021d:	ee                   	out    %al,(%dx)
  80021e:	b8 30 00 00 00       	mov    $0x30,%eax
  800223:	ba f7 01 00 00       	mov    $0x1f7,%edx
  800228:	ee                   	out    %al,(%dx)
  800229:	c1 e7 09             	shl    $0x9,%edi
  80022c:	01 df                	add    %ebx,%edi
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  80022e:	39 fb                	cmp    %edi,%ebx
  800230:	74 3b                	je     80026d <ide_write+0xbb>
		if ((r = ide_wait_ready(1)) < 0)
  800232:	b8 01 00 00 00       	mov    $0x1,%eax
  800237:	e8 f7 fd ff ff       	call   800033 <ide_wait_ready>
  80023c:	85 c0                	test   %eax,%eax
  80023e:	78 32                	js     800272 <ide_write+0xc0>
}

static inline void
outsl(int port, const void *addr, int cnt)
{
	asm volatile("cld\n\trepne\n\toutsl"
  800240:	89 de                	mov    %ebx,%esi
  800242:	b9 80 00 00 00       	mov    $0x80,%ecx
  800247:	ba f0 01 00 00       	mov    $0x1f0,%edx
  80024c:	fc                   	cld    
  80024d:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  80024f:	81 c3 00 02 00 00    	add    $0x200,%ebx
  800255:	eb d7                	jmp    80022e <ide_write+0x7c>
	assert(nsecs <= 256);
  800257:	68 50 39 80 00       	push   $0x803950
  80025c:	68 5d 39 80 00       	push   $0x80395d
  800261:	6a 5d                	push   $0x5d
  800263:	68 47 39 80 00       	push   $0x803947
  800268:	e8 f7 18 00 00       	call   801b64 <_panic>
			return r;
		outsl(0x1F0, src, SECTSIZE/4);
	}

	return 0;
  80026d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800272:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800275:	5b                   	pop    %ebx
  800276:	5e                   	pop    %esi
  800277:	5f                   	pop    %edi
  800278:	5d                   	pop    %ebp
  800279:	c3                   	ret    

0080027a <bc_pgfault>:

// Fault any disk block that is read in to memory by
// loading it from disk.
static void
bc_pgfault(struct UTrapframe *utf)
{
  80027a:	55                   	push   %ebp
  80027b:	89 e5                	mov    %esp,%ebp
  80027d:	56                   	push   %esi
  80027e:	53                   	push   %ebx
  80027f:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800282:	8b 1a                	mov    (%edx),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  800284:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  80028a:	89 c6                	mov    %eax,%esi
  80028c:	c1 ee 0c             	shr    $0xc,%esi
	int r;

	// Check that the fault was within the block cache region
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  80028f:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  800294:	0f 87 95 00 00 00    	ja     80032f <bc_pgfault+0xb5>
		panic("page fault in FS: eip %08x, va %08x, err %04x",
		      utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  80029a:	a1 08 a0 80 00       	mov    0x80a008,%eax
  80029f:	85 c0                	test   %eax,%eax
  8002a1:	74 09                	je     8002ac <bc_pgfault+0x32>
  8002a3:	39 70 04             	cmp    %esi,0x4(%eax)
  8002a6:	0f 86 9e 00 00 00    	jbe    80034a <bc_pgfault+0xd0>
	// of the block from the disk into that page.
	// Hint: first round addr to page boundary. fs/ide.c has code to read
	// the disk.
	//
	// LAB 5: you code here:
        addr = ROUNDDOWN(addr,PGSIZE);
  8002ac:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
        
	if((r=sys_page_alloc(0,addr,PTE_U|PTE_P|PTE_W))<0)
  8002b2:	83 ec 04             	sub    $0x4,%esp
  8002b5:	6a 07                	push   $0x7
  8002b7:	53                   	push   %ebx
  8002b8:	6a 00                	push   $0x0
  8002ba:	e8 98 23 00 00       	call   802657 <sys_page_alloc>
  8002bf:	83 c4 10             	add    $0x10,%esp
  8002c2:	85 c0                	test   %eax,%eax
  8002c4:	0f 88 92 00 00 00    	js     80035c <bc_pgfault+0xe2>
		panic("bc_pgfault:sys_page_alloc failed: %e\n",r);
	if((r=ide_read(blockno * BLKSECTS,addr,BLKSECTS))<0)
  8002ca:	83 ec 04             	sub    $0x4,%esp
  8002cd:	6a 08                	push   $0x8
  8002cf:	53                   	push   %ebx
  8002d0:	8d 04 f5 00 00 00 00 	lea    0x0(,%esi,8),%eax
  8002d7:	50                   	push   %eax
  8002d8:	e8 0d fe ff ff       	call   8000ea <ide_read>
  8002dd:	83 c4 10             	add    $0x10,%esp
  8002e0:	85 c0                	test   %eax,%eax
  8002e2:	0f 88 86 00 00 00    	js     80036e <bc_pgfault+0xf4>
		panic("ba_pgfault:ide_read:%e\n",r);

	// Clear the dirty bit for the disk block page since we just read the
	// block from disk
	if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  8002e8:	89 d8                	mov    %ebx,%eax
  8002ea:	c1 e8 0c             	shr    $0xc,%eax
  8002ed:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8002f4:	83 ec 0c             	sub    $0xc,%esp
  8002f7:	25 07 0e 00 00       	and    $0xe07,%eax
  8002fc:	50                   	push   %eax
  8002fd:	53                   	push   %ebx
  8002fe:	6a 00                	push   $0x0
  800300:	53                   	push   %ebx
  800301:	6a 00                	push   $0x0
  800303:	e8 92 23 00 00       	call   80269a <sys_page_map>
  800308:	83 c4 20             	add    $0x20,%esp
  80030b:	85 c0                	test   %eax,%eax
  80030d:	78 71                	js     800380 <bc_pgfault+0x106>
		panic("in bc_pgfault, sys_page_map: %e", r);

	// Check that the block we read was allocated. (exercise for
	// the reader: why do we do this *after* reading the block
	// in?)
	if (bitmap && block_is_free(blockno))
  80030f:	83 3d 04 a0 80 00 00 	cmpl   $0x0,0x80a004
  800316:	74 10                	je     800328 <bc_pgfault+0xae>
  800318:	83 ec 0c             	sub    $0xc,%esp
  80031b:	56                   	push   %esi
  80031c:	e8 0d 05 00 00       	call   80082e <block_is_free>
  800321:	83 c4 10             	add    $0x10,%esp
  800324:	84 c0                	test   %al,%al
  800326:	75 6a                	jne    800392 <bc_pgfault+0x118>
		panic("reading free block %08x\n", blockno);
}
  800328:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80032b:	5b                   	pop    %ebx
  80032c:	5e                   	pop    %esi
  80032d:	5d                   	pop    %ebp
  80032e:	c3                   	ret    
		panic("page fault in FS: eip %08x, va %08x, err %04x",
  80032f:	83 ec 08             	sub    $0x8,%esp
  800332:	ff 72 04             	pushl  0x4(%edx)
  800335:	53                   	push   %ebx
  800336:	ff 72 28             	pushl  0x28(%edx)
  800339:	68 74 39 80 00       	push   $0x803974
  80033e:	6a 27                	push   $0x27
  800340:	68 7c 3a 80 00       	push   $0x803a7c
  800345:	e8 1a 18 00 00       	call   801b64 <_panic>
		panic("reading non-existent block %08x\n", blockno);
  80034a:	56                   	push   %esi
  80034b:	68 a4 39 80 00       	push   $0x8039a4
  800350:	6a 2b                	push   $0x2b
  800352:	68 7c 3a 80 00       	push   $0x803a7c
  800357:	e8 08 18 00 00       	call   801b64 <_panic>
		panic("bc_pgfault:sys_page_alloc failed: %e\n",r);
  80035c:	50                   	push   %eax
  80035d:	68 c8 39 80 00       	push   $0x8039c8
  800362:	6a 36                	push   $0x36
  800364:	68 7c 3a 80 00       	push   $0x803a7c
  800369:	e8 f6 17 00 00       	call   801b64 <_panic>
		panic("ba_pgfault:ide_read:%e\n",r);
  80036e:	50                   	push   %eax
  80036f:	68 84 3a 80 00       	push   $0x803a84
  800374:	6a 38                	push   $0x38
  800376:	68 7c 3a 80 00       	push   $0x803a7c
  80037b:	e8 e4 17 00 00       	call   801b64 <_panic>
		panic("in bc_pgfault, sys_page_map: %e", r);
  800380:	50                   	push   %eax
  800381:	68 f0 39 80 00       	push   $0x8039f0
  800386:	6a 3d                	push   $0x3d
  800388:	68 7c 3a 80 00       	push   $0x803a7c
  80038d:	e8 d2 17 00 00       	call   801b64 <_panic>
		panic("reading free block %08x\n", blockno);
  800392:	56                   	push   %esi
  800393:	68 9c 3a 80 00       	push   $0x803a9c
  800398:	6a 43                	push   $0x43
  80039a:	68 7c 3a 80 00       	push   $0x803a7c
  80039f:	e8 c0 17 00 00       	call   801b64 <_panic>

008003a4 <diskaddr>:
{
  8003a4:	55                   	push   %ebp
  8003a5:	89 e5                	mov    %esp,%ebp
  8003a7:	83 ec 08             	sub    $0x8,%esp
  8003aa:	8b 45 08             	mov    0x8(%ebp),%eax
	if (blockno == 0 || (super && blockno >= super->s_nblocks))
  8003ad:	85 c0                	test   %eax,%eax
  8003af:	74 19                	je     8003ca <diskaddr+0x26>
  8003b1:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  8003b7:	85 d2                	test   %edx,%edx
  8003b9:	74 05                	je     8003c0 <diskaddr+0x1c>
  8003bb:	39 42 04             	cmp    %eax,0x4(%edx)
  8003be:	76 0a                	jbe    8003ca <diskaddr+0x26>
	return (char*) (DISKMAP + blockno * BLKSIZE);
  8003c0:	05 00 00 01 00       	add    $0x10000,%eax
  8003c5:	c1 e0 0c             	shl    $0xc,%eax
}
  8003c8:	c9                   	leave  
  8003c9:	c3                   	ret    
		panic("bad block number %08x in diskaddr", blockno);
  8003ca:	50                   	push   %eax
  8003cb:	68 10 3a 80 00       	push   $0x803a10
  8003d0:	6a 09                	push   $0x9
  8003d2:	68 7c 3a 80 00       	push   $0x803a7c
  8003d7:	e8 88 17 00 00       	call   801b64 <_panic>

008003dc <va_is_mapped>:
{
  8003dc:	55                   	push   %ebp
  8003dd:	89 e5                	mov    %esp,%ebp
  8003df:	8b 55 08             	mov    0x8(%ebp),%edx
	return (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P);
  8003e2:	89 d0                	mov    %edx,%eax
  8003e4:	c1 e8 16             	shr    $0x16,%eax
  8003e7:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  8003ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8003f3:	f6 c1 01             	test   $0x1,%cl
  8003f6:	74 0d                	je     800405 <va_is_mapped+0x29>
  8003f8:	c1 ea 0c             	shr    $0xc,%edx
  8003fb:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800402:	83 e0 01             	and    $0x1,%eax
  800405:	83 e0 01             	and    $0x1,%eax
}
  800408:	5d                   	pop    %ebp
  800409:	c3                   	ret    

0080040a <va_is_dirty>:
{
  80040a:	55                   	push   %ebp
  80040b:	89 e5                	mov    %esp,%ebp
	return (uvpt[PGNUM(va)] & PTE_D) != 0;
  80040d:	8b 45 08             	mov    0x8(%ebp),%eax
  800410:	c1 e8 0c             	shr    $0xc,%eax
  800413:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80041a:	c1 e8 06             	shr    $0x6,%eax
  80041d:	83 e0 01             	and    $0x1,%eax
}
  800420:	5d                   	pop    %ebp
  800421:	c3                   	ret    

00800422 <flush_block>:
// Hint: Use va_is_mapped, va_is_dirty, and ide_write.
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
  800422:	55                   	push   %ebp
  800423:	89 e5                	mov    %esp,%ebp
  800425:	56                   	push   %esi
  800426:	53                   	push   %ebx
  800427:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;

	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  80042a:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  800430:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  800435:	77 1f                	ja     800456 <flush_block+0x34>
		panic("flush_block of bad va %08x", addr);

	// LAB 5: Your code here.
	//panic("flush_block not implemented");
	int r;
	addr = ROUNDDOWN(addr,PGSIZE);
  800437:	89 de                	mov    %ebx,%esi
  800439:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if(va_is_mapped(addr) && va_is_dirty(addr)){
  80043f:	83 ec 0c             	sub    $0xc,%esp
  800442:	56                   	push   %esi
  800443:	e8 94 ff ff ff       	call   8003dc <va_is_mapped>
  800448:	83 c4 10             	add    $0x10,%esp
  80044b:	84 c0                	test   %al,%al
  80044d:	75 19                	jne    800468 <flush_block+0x46>
	  if((r=ide_write(blockno*BLKSECTS,addr,BLKSECTS))<0)
		  panic("flush_block:ide_write failed %e\n",r);
	  if((r=sys_page_map(0,addr,0,addr,uvpt[PGNUM(addr)]&PTE_SYSCALL))<0)
		  panic("flush_block:sys_page_map: %e\n",r);
	}
}
  80044f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800452:	5b                   	pop    %ebx
  800453:	5e                   	pop    %esi
  800454:	5d                   	pop    %ebp
  800455:	c3                   	ret    
		panic("flush_block of bad va %08x", addr);
  800456:	53                   	push   %ebx
  800457:	68 b5 3a 80 00       	push   $0x803ab5
  80045c:	6a 53                	push   $0x53
  80045e:	68 7c 3a 80 00       	push   $0x803a7c
  800463:	e8 fc 16 00 00       	call   801b64 <_panic>
	if(va_is_mapped(addr) && va_is_dirty(addr)){
  800468:	83 ec 0c             	sub    $0xc,%esp
  80046b:	56                   	push   %esi
  80046c:	e8 99 ff ff ff       	call   80040a <va_is_dirty>
  800471:	83 c4 10             	add    $0x10,%esp
  800474:	84 c0                	test   %al,%al
  800476:	74 d7                	je     80044f <flush_block+0x2d>
	  if((r=ide_write(blockno*BLKSECTS,addr,BLKSECTS))<0)
  800478:	83 ec 04             	sub    $0x4,%esp
  80047b:	6a 08                	push   $0x8
  80047d:	56                   	push   %esi
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  80047e:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
  800484:	c1 eb 0c             	shr    $0xc,%ebx
	  if((r=ide_write(blockno*BLKSECTS,addr,BLKSECTS))<0)
  800487:	c1 e3 03             	shl    $0x3,%ebx
  80048a:	53                   	push   %ebx
  80048b:	e8 22 fd ff ff       	call   8001b2 <ide_write>
  800490:	83 c4 10             	add    $0x10,%esp
  800493:	85 c0                	test   %eax,%eax
  800495:	78 39                	js     8004d0 <flush_block+0xae>
	  if((r=sys_page_map(0,addr,0,addr,uvpt[PGNUM(addr)]&PTE_SYSCALL))<0)
  800497:	89 f0                	mov    %esi,%eax
  800499:	c1 e8 0c             	shr    $0xc,%eax
  80049c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8004a3:	83 ec 0c             	sub    $0xc,%esp
  8004a6:	25 07 0e 00 00       	and    $0xe07,%eax
  8004ab:	50                   	push   %eax
  8004ac:	56                   	push   %esi
  8004ad:	6a 00                	push   $0x0
  8004af:	56                   	push   %esi
  8004b0:	6a 00                	push   $0x0
  8004b2:	e8 e3 21 00 00       	call   80269a <sys_page_map>
  8004b7:	83 c4 20             	add    $0x20,%esp
  8004ba:	85 c0                	test   %eax,%eax
  8004bc:	79 91                	jns    80044f <flush_block+0x2d>
		  panic("flush_block:sys_page_map: %e\n",r);
  8004be:	50                   	push   %eax
  8004bf:	68 d0 3a 80 00       	push   $0x803ad0
  8004c4:	6a 5d                	push   $0x5d
  8004c6:	68 7c 3a 80 00       	push   $0x803a7c
  8004cb:	e8 94 16 00 00       	call   801b64 <_panic>
		  panic("flush_block:ide_write failed %e\n",r);
  8004d0:	50                   	push   %eax
  8004d1:	68 34 3a 80 00       	push   $0x803a34
  8004d6:	6a 5b                	push   $0x5b
  8004d8:	68 7c 3a 80 00       	push   $0x803a7c
  8004dd:	e8 82 16 00 00       	call   801b64 <_panic>

008004e2 <bc_init>:
	cprintf("block cache is good\n");
}

void
bc_init(void)
{
  8004e2:	55                   	push   %ebp
  8004e3:	89 e5                	mov    %esp,%ebp
  8004e5:	53                   	push   %ebx
  8004e6:	81 ec 20 02 00 00    	sub    $0x220,%esp
	struct Super super;
	set_pgfault_handler(bc_pgfault);
  8004ec:	68 7a 02 80 00       	push   $0x80027a
  8004f1:	e8 52 23 00 00       	call   802848 <set_pgfault_handler>
	memmove(&backup, diskaddr(1), sizeof backup);
  8004f6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8004fd:	e8 a2 fe ff ff       	call   8003a4 <diskaddr>
  800502:	83 c4 0c             	add    $0xc,%esp
  800505:	68 08 01 00 00       	push   $0x108
  80050a:	50                   	push   %eax
  80050b:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  800511:	50                   	push   %eax
  800512:	e8 d5 1e 00 00       	call   8023ec <memmove>
	strcpy(diskaddr(1), "OOPS!\n");
  800517:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80051e:	e8 81 fe ff ff       	call   8003a4 <diskaddr>
  800523:	83 c4 08             	add    $0x8,%esp
  800526:	68 ee 3a 80 00       	push   $0x803aee
  80052b:	50                   	push   %eax
  80052c:	e8 2d 1d 00 00       	call   80225e <strcpy>
	flush_block(diskaddr(1));
  800531:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800538:	e8 67 fe ff ff       	call   8003a4 <diskaddr>
  80053d:	89 04 24             	mov    %eax,(%esp)
  800540:	e8 dd fe ff ff       	call   800422 <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  800545:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80054c:	e8 53 fe ff ff       	call   8003a4 <diskaddr>
  800551:	89 04 24             	mov    %eax,(%esp)
  800554:	e8 83 fe ff ff       	call   8003dc <va_is_mapped>
  800559:	83 c4 10             	add    $0x10,%esp
  80055c:	84 c0                	test   %al,%al
  80055e:	0f 84 d1 01 00 00    	je     800735 <bc_init+0x253>
	assert(!va_is_dirty(diskaddr(1)));
  800564:	83 ec 0c             	sub    $0xc,%esp
  800567:	6a 01                	push   $0x1
  800569:	e8 36 fe ff ff       	call   8003a4 <diskaddr>
  80056e:	89 04 24             	mov    %eax,(%esp)
  800571:	e8 94 fe ff ff       	call   80040a <va_is_dirty>
  800576:	83 c4 10             	add    $0x10,%esp
  800579:	84 c0                	test   %al,%al
  80057b:	0f 85 ca 01 00 00    	jne    80074b <bc_init+0x269>
	sys_page_unmap(0, diskaddr(1));
  800581:	83 ec 0c             	sub    $0xc,%esp
  800584:	6a 01                	push   $0x1
  800586:	e8 19 fe ff ff       	call   8003a4 <diskaddr>
  80058b:	83 c4 08             	add    $0x8,%esp
  80058e:	50                   	push   %eax
  80058f:	6a 00                	push   $0x0
  800591:	e8 46 21 00 00       	call   8026dc <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  800596:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80059d:	e8 02 fe ff ff       	call   8003a4 <diskaddr>
  8005a2:	89 04 24             	mov    %eax,(%esp)
  8005a5:	e8 32 fe ff ff       	call   8003dc <va_is_mapped>
  8005aa:	83 c4 10             	add    $0x10,%esp
  8005ad:	84 c0                	test   %al,%al
  8005af:	0f 85 ac 01 00 00    	jne    800761 <bc_init+0x27f>
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8005b5:	83 ec 0c             	sub    $0xc,%esp
  8005b8:	6a 01                	push   $0x1
  8005ba:	e8 e5 fd ff ff       	call   8003a4 <diskaddr>
  8005bf:	83 c4 08             	add    $0x8,%esp
  8005c2:	68 ee 3a 80 00       	push   $0x803aee
  8005c7:	50                   	push   %eax
  8005c8:	e8 37 1d 00 00       	call   802304 <strcmp>
  8005cd:	83 c4 10             	add    $0x10,%esp
  8005d0:	85 c0                	test   %eax,%eax
  8005d2:	0f 85 9f 01 00 00    	jne    800777 <bc_init+0x295>
	memmove(diskaddr(1), &backup, sizeof backup);
  8005d8:	83 ec 0c             	sub    $0xc,%esp
  8005db:	6a 01                	push   $0x1
  8005dd:	e8 c2 fd ff ff       	call   8003a4 <diskaddr>
  8005e2:	83 c4 0c             	add    $0xc,%esp
  8005e5:	68 08 01 00 00       	push   $0x108
  8005ea:	8d 9d e8 fd ff ff    	lea    -0x218(%ebp),%ebx
  8005f0:	53                   	push   %ebx
  8005f1:	50                   	push   %eax
  8005f2:	e8 f5 1d 00 00       	call   8023ec <memmove>
	flush_block(diskaddr(1));
  8005f7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005fe:	e8 a1 fd ff ff       	call   8003a4 <diskaddr>
  800603:	89 04 24             	mov    %eax,(%esp)
  800606:	e8 17 fe ff ff       	call   800422 <flush_block>
	memmove(&backup, diskaddr(1), sizeof backup);
  80060b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800612:	e8 8d fd ff ff       	call   8003a4 <diskaddr>
  800617:	83 c4 0c             	add    $0xc,%esp
  80061a:	68 08 01 00 00       	push   $0x108
  80061f:	50                   	push   %eax
  800620:	53                   	push   %ebx
  800621:	e8 c6 1d 00 00       	call   8023ec <memmove>
	strcpy(diskaddr(1), "OOPS!\n");
  800626:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80062d:	e8 72 fd ff ff       	call   8003a4 <diskaddr>
  800632:	83 c4 08             	add    $0x8,%esp
  800635:	68 ee 3a 80 00       	push   $0x803aee
  80063a:	50                   	push   %eax
  80063b:	e8 1e 1c 00 00       	call   80225e <strcpy>
	flush_block(diskaddr(1) + 20);
  800640:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800647:	e8 58 fd ff ff       	call   8003a4 <diskaddr>
  80064c:	83 c0 14             	add    $0x14,%eax
  80064f:	89 04 24             	mov    %eax,(%esp)
  800652:	e8 cb fd ff ff       	call   800422 <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  800657:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80065e:	e8 41 fd ff ff       	call   8003a4 <diskaddr>
  800663:	89 04 24             	mov    %eax,(%esp)
  800666:	e8 71 fd ff ff       	call   8003dc <va_is_mapped>
  80066b:	83 c4 10             	add    $0x10,%esp
  80066e:	84 c0                	test   %al,%al
  800670:	0f 84 17 01 00 00    	je     80078d <bc_init+0x2ab>
	sys_page_unmap(0, diskaddr(1));
  800676:	83 ec 0c             	sub    $0xc,%esp
  800679:	6a 01                	push   $0x1
  80067b:	e8 24 fd ff ff       	call   8003a4 <diskaddr>
  800680:	83 c4 08             	add    $0x8,%esp
  800683:	50                   	push   %eax
  800684:	6a 00                	push   $0x0
  800686:	e8 51 20 00 00       	call   8026dc <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  80068b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800692:	e8 0d fd ff ff       	call   8003a4 <diskaddr>
  800697:	89 04 24             	mov    %eax,(%esp)
  80069a:	e8 3d fd ff ff       	call   8003dc <va_is_mapped>
  80069f:	83 c4 10             	add    $0x10,%esp
  8006a2:	84 c0                	test   %al,%al
  8006a4:	0f 85 fc 00 00 00    	jne    8007a6 <bc_init+0x2c4>
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8006aa:	83 ec 0c             	sub    $0xc,%esp
  8006ad:	6a 01                	push   $0x1
  8006af:	e8 f0 fc ff ff       	call   8003a4 <diskaddr>
  8006b4:	83 c4 08             	add    $0x8,%esp
  8006b7:	68 ee 3a 80 00       	push   $0x803aee
  8006bc:	50                   	push   %eax
  8006bd:	e8 42 1c 00 00       	call   802304 <strcmp>
  8006c2:	83 c4 10             	add    $0x10,%esp
  8006c5:	85 c0                	test   %eax,%eax
  8006c7:	0f 85 f2 00 00 00    	jne    8007bf <bc_init+0x2dd>
	memmove(diskaddr(1), &backup, sizeof backup);
  8006cd:	83 ec 0c             	sub    $0xc,%esp
  8006d0:	6a 01                	push   $0x1
  8006d2:	e8 cd fc ff ff       	call   8003a4 <diskaddr>
  8006d7:	83 c4 0c             	add    $0xc,%esp
  8006da:	68 08 01 00 00       	push   $0x108
  8006df:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  8006e5:	52                   	push   %edx
  8006e6:	50                   	push   %eax
  8006e7:	e8 00 1d 00 00       	call   8023ec <memmove>
	flush_block(diskaddr(1));
  8006ec:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006f3:	e8 ac fc ff ff       	call   8003a4 <diskaddr>
  8006f8:	89 04 24             	mov    %eax,(%esp)
  8006fb:	e8 22 fd ff ff       	call   800422 <flush_block>
	cprintf("block cache is good\n");
  800700:	c7 04 24 2a 3b 80 00 	movl   $0x803b2a,(%esp)
  800707:	e8 33 15 00 00       	call   801c3f <cprintf>
	check_bc();

	// cache the super block by reading it once
	memmove(&super, diskaddr(1), sizeof super);
  80070c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800713:	e8 8c fc ff ff       	call   8003a4 <diskaddr>
  800718:	83 c4 0c             	add    $0xc,%esp
  80071b:	68 08 01 00 00       	push   $0x108
  800720:	50                   	push   %eax
  800721:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800727:	50                   	push   %eax
  800728:	e8 bf 1c 00 00       	call   8023ec <memmove>
}
  80072d:	83 c4 10             	add    $0x10,%esp
  800730:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800733:	c9                   	leave  
  800734:	c3                   	ret    
	assert(va_is_mapped(diskaddr(1)));
  800735:	68 10 3b 80 00       	push   $0x803b10
  80073a:	68 5d 39 80 00       	push   $0x80395d
  80073f:	6a 6e                	push   $0x6e
  800741:	68 7c 3a 80 00       	push   $0x803a7c
  800746:	e8 19 14 00 00       	call   801b64 <_panic>
	assert(!va_is_dirty(diskaddr(1)));
  80074b:	68 f5 3a 80 00       	push   $0x803af5
  800750:	68 5d 39 80 00       	push   $0x80395d
  800755:	6a 6f                	push   $0x6f
  800757:	68 7c 3a 80 00       	push   $0x803a7c
  80075c:	e8 03 14 00 00       	call   801b64 <_panic>
	assert(!va_is_mapped(diskaddr(1)));
  800761:	68 0f 3b 80 00       	push   $0x803b0f
  800766:	68 5d 39 80 00       	push   $0x80395d
  80076b:	6a 73                	push   $0x73
  80076d:	68 7c 3a 80 00       	push   $0x803a7c
  800772:	e8 ed 13 00 00       	call   801b64 <_panic>
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  800777:	68 58 3a 80 00       	push   $0x803a58
  80077c:	68 5d 39 80 00       	push   $0x80395d
  800781:	6a 76                	push   $0x76
  800783:	68 7c 3a 80 00       	push   $0x803a7c
  800788:	e8 d7 13 00 00       	call   801b64 <_panic>
	assert(va_is_mapped(diskaddr(1)));
  80078d:	68 10 3b 80 00       	push   $0x803b10
  800792:	68 5d 39 80 00       	push   $0x80395d
  800797:	68 87 00 00 00       	push   $0x87
  80079c:	68 7c 3a 80 00       	push   $0x803a7c
  8007a1:	e8 be 13 00 00       	call   801b64 <_panic>
	assert(!va_is_mapped(diskaddr(1)));
  8007a6:	68 0f 3b 80 00       	push   $0x803b0f
  8007ab:	68 5d 39 80 00       	push   $0x80395d
  8007b0:	68 8f 00 00 00       	push   $0x8f
  8007b5:	68 7c 3a 80 00       	push   $0x803a7c
  8007ba:	e8 a5 13 00 00       	call   801b64 <_panic>
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8007bf:	68 58 3a 80 00       	push   $0x803a58
  8007c4:	68 5d 39 80 00       	push   $0x80395d
  8007c9:	68 92 00 00 00       	push   $0x92
  8007ce:	68 7c 3a 80 00       	push   $0x803a7c
  8007d3:	e8 8c 13 00 00       	call   801b64 <_panic>

008007d8 <check_super>:
// --------------------------------------------------------------

// Validate the file system super-block.
void
check_super(void)
{
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	83 ec 08             	sub    $0x8,%esp
	if (super->s_magic != FS_MAGIC)
  8007de:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8007e3:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  8007e9:	75 1b                	jne    800806 <check_super+0x2e>
		panic("bad file system magic number");

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  8007eb:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  8007f2:	77 26                	ja     80081a <check_super+0x42>
		panic("file system is too large");

	cprintf("superblock is good\n");
  8007f4:	83 ec 0c             	sub    $0xc,%esp
  8007f7:	68 7d 3b 80 00       	push   $0x803b7d
  8007fc:	e8 3e 14 00 00       	call   801c3f <cprintf>
}
  800801:	83 c4 10             	add    $0x10,%esp
  800804:	c9                   	leave  
  800805:	c3                   	ret    
		panic("bad file system magic number");
  800806:	83 ec 04             	sub    $0x4,%esp
  800809:	68 3f 3b 80 00       	push   $0x803b3f
  80080e:	6a 0f                	push   $0xf
  800810:	68 5c 3b 80 00       	push   $0x803b5c
  800815:	e8 4a 13 00 00       	call   801b64 <_panic>
		panic("file system is too large");
  80081a:	83 ec 04             	sub    $0x4,%esp
  80081d:	68 64 3b 80 00       	push   $0x803b64
  800822:	6a 12                	push   $0x12
  800824:	68 5c 3b 80 00       	push   $0x803b5c
  800829:	e8 36 13 00 00       	call   801b64 <_panic>

0080082e <block_is_free>:

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
  80082e:	55                   	push   %ebp
  80082f:	89 e5                	mov    %esp,%ebp
  800831:	53                   	push   %ebx
  800832:	8b 4d 08             	mov    0x8(%ebp),%ecx
	if (super == 0 || blockno >= super->s_nblocks)
  800835:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
		return 0;
  80083b:	b8 00 00 00 00       	mov    $0x0,%eax
	if (super == 0 || blockno >= super->s_nblocks)
  800840:	85 d2                	test   %edx,%edx
  800842:	74 1d                	je     800861 <block_is_free+0x33>
  800844:	39 4a 04             	cmp    %ecx,0x4(%edx)
  800847:	76 18                	jbe    800861 <block_is_free+0x33>
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
  800849:	89 cb                	mov    %ecx,%ebx
  80084b:	c1 eb 05             	shr    $0x5,%ebx
  80084e:	b8 01 00 00 00       	mov    $0x1,%eax
  800853:	d3 e0                	shl    %cl,%eax
  800855:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
  80085b:	85 04 9a             	test   %eax,(%edx,%ebx,4)
  80085e:	0f 95 c0             	setne  %al
		return 1;
	return 0;
}
  800861:	5b                   	pop    %ebx
  800862:	5d                   	pop    %ebp
  800863:	c3                   	ret    

00800864 <free_block>:

// Mark a block free in the bitmap
void
free_block(uint32_t blockno)
{
  800864:	55                   	push   %ebp
  800865:	89 e5                	mov    %esp,%ebp
  800867:	53                   	push   %ebx
  800868:	83 ec 04             	sub    $0x4,%esp
  80086b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	// Blockno zero is the null pointer of block numbers.
	if (blockno == 0)
  80086e:	85 c9                	test   %ecx,%ecx
  800870:	74 1a                	je     80088c <free_block+0x28>
		panic("attempt to free zero block");
	bitmap[blockno/32] |= 1<<(blockno%32);
  800872:	89 cb                	mov    %ecx,%ebx
  800874:	c1 eb 05             	shr    $0x5,%ebx
  800877:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
  80087d:	b8 01 00 00 00       	mov    $0x1,%eax
  800882:	d3 e0                	shl    %cl,%eax
  800884:	09 04 9a             	or     %eax,(%edx,%ebx,4)
}
  800887:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80088a:	c9                   	leave  
  80088b:	c3                   	ret    
		panic("attempt to free zero block");
  80088c:	83 ec 04             	sub    $0x4,%esp
  80088f:	68 91 3b 80 00       	push   $0x803b91
  800894:	6a 2d                	push   $0x2d
  800896:	68 5c 3b 80 00       	push   $0x803b5c
  80089b:	e8 c4 12 00 00       	call   801b64 <_panic>

008008a0 <alloc_block>:
// -E_NO_DISK if we are out of blocks.
//
// Hint: use free_block as an example for manipulating the bitmap.
int
alloc_block(void)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	56                   	push   %esi
  8008a4:	53                   	push   %ebx
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
        //	panic("alloc_block not implemented");
	uint32_t blockno;
	for(blockno = 2; blockno <= super->s_nblocks; blockno++){
  8008a5:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8008aa:	8b 70 04             	mov    0x4(%eax),%esi
  8008ad:	bb 02 00 00 00       	mov    $0x2,%ebx
  8008b2:	39 de                	cmp    %ebx,%esi
  8008b4:	72 41                	jb     8008f7 <alloc_block+0x57>
	   if(block_is_free(blockno)){
  8008b6:	53                   	push   %ebx
  8008b7:	e8 72 ff ff ff       	call   80082e <block_is_free>
  8008bc:	83 c4 04             	add    $0x4,%esp
  8008bf:	84 c0                	test   %al,%al
  8008c1:	75 05                	jne    8008c8 <alloc_block+0x28>
	for(blockno = 2; blockno <= super->s_nblocks; blockno++){
  8008c3:	83 c3 01             	add    $0x1,%ebx
  8008c6:	eb ea                	jmp    8008b2 <alloc_block+0x12>
	     bitmap[blockno/32] ^= (1<<(blockno % 32));
  8008c8:	89 de                	mov    %ebx,%esi
  8008ca:	c1 ee 05             	shr    $0x5,%esi
  8008cd:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
  8008d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8008d8:	89 d9                	mov    %ebx,%ecx
  8008da:	d3 e0                	shl    %cl,%eax
  8008dc:	31 04 b2             	xor    %eax,(%edx,%esi,4)
	     flush_block(diskaddr(blockno));
  8008df:	83 ec 0c             	sub    $0xc,%esp
  8008e2:	53                   	push   %ebx
  8008e3:	e8 bc fa ff ff       	call   8003a4 <diskaddr>
  8008e8:	89 04 24             	mov    %eax,(%esp)
  8008eb:	e8 32 fb ff ff       	call   800422 <flush_block>
	     return blockno;
  8008f0:	89 d8                	mov    %ebx,%eax
  8008f2:	83 c4 10             	add    $0x10,%esp
  8008f5:	eb 05                	jmp    8008fc <alloc_block+0x5c>
	   }
	}
	return -E_NO_DISK;
  8008f7:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
}
  8008fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008ff:	5b                   	pop    %ebx
  800900:	5e                   	pop    %esi
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    

00800903 <file_block_walk>:
//
// Analogy: This is like pgdir_walk for files.
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	57                   	push   %edi
  800907:	56                   	push   %esi
  800908:	53                   	push   %ebx
  800909:	83 ec 1c             	sub    $0x1c,%esp
  80090c:	8b 7d 08             	mov    0x8(%ebp),%edi
       // LAB 5: Your code here.
       //panic("file_block_walk not implemented");
       int r;

       if(filebno<NDIRECT){
  80090f:	83 fa 09             	cmp    $0x9,%edx
  800912:	0f 86 89 00 00 00    	jbe    8009a1 <file_block_walk+0x9e>
          *ppdiskbno = f->f_direct + filebno;
          return 0;
         
       }
       
       if(filebno>=NDIRECT+NINDIRECT)
  800918:	81 fa 09 04 00 00    	cmp    $0x409,%edx
  80091e:	0f 87 8d 00 00 00    	ja     8009b1 <file_block_walk+0xae>
  800924:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800927:	89 d3                	mov    %edx,%ebx
  800929:	89 c6                	mov    %eax,%esi
               return -E_INVAL;

       if(!f->f_indirect){
  80092b:	83 b8 b0 00 00 00 00 	cmpl   $0x0,0xb0(%eax)
  800932:	75 43                	jne    800977 <file_block_walk+0x74>
         if(!alloc) return -E_NOT_FOUND;
  800934:	89 f8                	mov    %edi,%eax
  800936:	84 c0                	test   %al,%al
  800938:	74 7e                	je     8009b8 <file_block_walk+0xb5>
	 if((r=alloc_block())<0)  return -E_NO_DISK;
  80093a:	e8 61 ff ff ff       	call   8008a0 <alloc_block>
  80093f:	89 c7                	mov    %eax,%edi
  800941:	85 c0                	test   %eax,%eax
  800943:	78 7a                	js     8009bf <file_block_walk+0xbc>
           f->f_indirect = r;
  800945:	89 86 b0 00 00 00    	mov    %eax,0xb0(%esi)
	   memset(diskaddr(r),0,BLKSIZE);
  80094b:	83 ec 0c             	sub    $0xc,%esp
  80094e:	50                   	push   %eax
  80094f:	e8 50 fa ff ff       	call   8003a4 <diskaddr>
  800954:	83 c4 0c             	add    $0xc,%esp
  800957:	68 00 10 00 00       	push   $0x1000
  80095c:	6a 00                	push   $0x0
  80095e:	50                   	push   %eax
  80095f:	e8 3b 1a 00 00       	call   80239f <memset>
	   flush_block(diskaddr(r));
  800964:	89 3c 24             	mov    %edi,(%esp)
  800967:	e8 38 fa ff ff       	call   8003a4 <diskaddr>
  80096c:	89 04 24             	mov    %eax,(%esp)
  80096f:	e8 ae fa ff ff       	call   800422 <flush_block>
  800974:	83 c4 10             	add    $0x10,%esp
       }
	  *ppdiskbno = (uint32_t *)diskaddr(f->f_indirect) + filebno -NINDIRECT;
  800977:	83 ec 0c             	sub    $0xc,%esp
  80097a:	ff b6 b0 00 00 00    	pushl  0xb0(%esi)
  800980:	e8 1f fa ff ff       	call   8003a4 <diskaddr>
  800985:	8d 84 98 00 f0 ff ff 	lea    -0x1000(%eax,%ebx,4),%eax
  80098c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80098f:	89 03                	mov    %eax,(%ebx)
          return 0;
  800991:	83 c4 10             	add    $0x10,%esp
  800994:	b8 00 00 00 00       	mov    $0x0,%eax

}
  800999:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80099c:	5b                   	pop    %ebx
  80099d:	5e                   	pop    %esi
  80099e:	5f                   	pop    %edi
  80099f:	5d                   	pop    %ebp
  8009a0:	c3                   	ret    
          *ppdiskbno = f->f_direct + filebno;
  8009a1:	8d 84 90 88 00 00 00 	lea    0x88(%eax,%edx,4),%eax
  8009a8:	89 01                	mov    %eax,(%ecx)
          return 0;
  8009aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8009af:	eb e8                	jmp    800999 <file_block_walk+0x96>
               return -E_INVAL;
  8009b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009b6:	eb e1                	jmp    800999 <file_block_walk+0x96>
         if(!alloc) return -E_NOT_FOUND;
  8009b8:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  8009bd:	eb da                	jmp    800999 <file_block_walk+0x96>
	 if((r=alloc_block())<0)  return -E_NO_DISK;
  8009bf:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
  8009c4:	eb d3                	jmp    800999 <file_block_walk+0x96>

008009c6 <check_bitmap>:
{
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	56                   	push   %esi
  8009ca:	53                   	push   %ebx
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  8009cb:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8009d0:	8b 70 04             	mov    0x4(%eax),%esi
  8009d3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8009d8:	89 d8                	mov    %ebx,%eax
  8009da:	c1 e0 0f             	shl    $0xf,%eax
  8009dd:	39 c6                	cmp    %eax,%esi
  8009df:	76 2b                	jbe    800a0c <check_bitmap+0x46>
		assert(!block_is_free(2+i));
  8009e1:	8d 43 02             	lea    0x2(%ebx),%eax
  8009e4:	50                   	push   %eax
  8009e5:	e8 44 fe ff ff       	call   80082e <block_is_free>
  8009ea:	83 c4 04             	add    $0x4,%esp
  8009ed:	84 c0                	test   %al,%al
  8009ef:	75 05                	jne    8009f6 <check_bitmap+0x30>
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  8009f1:	83 c3 01             	add    $0x1,%ebx
  8009f4:	eb e2                	jmp    8009d8 <check_bitmap+0x12>
		assert(!block_is_free(2+i));
  8009f6:	68 ac 3b 80 00       	push   $0x803bac
  8009fb:	68 5d 39 80 00       	push   $0x80395d
  800a00:	6a 58                	push   $0x58
  800a02:	68 5c 3b 80 00       	push   $0x803b5c
  800a07:	e8 58 11 00 00       	call   801b64 <_panic>
	assert(!block_is_free(0));
  800a0c:	83 ec 0c             	sub    $0xc,%esp
  800a0f:	6a 00                	push   $0x0
  800a11:	e8 18 fe ff ff       	call   80082e <block_is_free>
  800a16:	83 c4 10             	add    $0x10,%esp
  800a19:	84 c0                	test   %al,%al
  800a1b:	75 28                	jne    800a45 <check_bitmap+0x7f>
	assert(!block_is_free(1));
  800a1d:	83 ec 0c             	sub    $0xc,%esp
  800a20:	6a 01                	push   $0x1
  800a22:	e8 07 fe ff ff       	call   80082e <block_is_free>
  800a27:	83 c4 10             	add    $0x10,%esp
  800a2a:	84 c0                	test   %al,%al
  800a2c:	75 2d                	jne    800a5b <check_bitmap+0x95>
	cprintf("bitmap is good\n");
  800a2e:	83 ec 0c             	sub    $0xc,%esp
  800a31:	68 e4 3b 80 00       	push   $0x803be4
  800a36:	e8 04 12 00 00       	call   801c3f <cprintf>
}
  800a3b:	83 c4 10             	add    $0x10,%esp
  800a3e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a41:	5b                   	pop    %ebx
  800a42:	5e                   	pop    %esi
  800a43:	5d                   	pop    %ebp
  800a44:	c3                   	ret    
	assert(!block_is_free(0));
  800a45:	68 c0 3b 80 00       	push   $0x803bc0
  800a4a:	68 5d 39 80 00       	push   $0x80395d
  800a4f:	6a 5b                	push   $0x5b
  800a51:	68 5c 3b 80 00       	push   $0x803b5c
  800a56:	e8 09 11 00 00       	call   801b64 <_panic>
	assert(!block_is_free(1));
  800a5b:	68 d2 3b 80 00       	push   $0x803bd2
  800a60:	68 5d 39 80 00       	push   $0x80395d
  800a65:	6a 5c                	push   $0x5c
  800a67:	68 5c 3b 80 00       	push   $0x803b5c
  800a6c:	e8 f3 10 00 00       	call   801b64 <_panic>

00800a71 <fs_init>:
{
  800a71:	55                   	push   %ebp
  800a72:	89 e5                	mov    %esp,%ebp
  800a74:	83 ec 08             	sub    $0x8,%esp
	if (ide_probe_disk1())
  800a77:	e8 e3 f5 ff ff       	call   80005f <ide_probe_disk1>
  800a7c:	84 c0                	test   %al,%al
  800a7e:	75 41                	jne    800ac1 <fs_init+0x50>
		ide_set_disk(0);
  800a80:	83 ec 0c             	sub    $0xc,%esp
  800a83:	6a 00                	push   $0x0
  800a85:	e8 37 f6 ff ff       	call   8000c1 <ide_set_disk>
  800a8a:	83 c4 10             	add    $0x10,%esp
	bc_init();
  800a8d:	e8 50 fa ff ff       	call   8004e2 <bc_init>
	super = diskaddr(1);
  800a92:	83 ec 0c             	sub    $0xc,%esp
  800a95:	6a 01                	push   $0x1
  800a97:	e8 08 f9 ff ff       	call   8003a4 <diskaddr>
  800a9c:	a3 08 a0 80 00       	mov    %eax,0x80a008
	check_super();
  800aa1:	e8 32 fd ff ff       	call   8007d8 <check_super>
	bitmap = diskaddr(2);
  800aa6:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800aad:	e8 f2 f8 ff ff       	call   8003a4 <diskaddr>
  800ab2:	a3 04 a0 80 00       	mov    %eax,0x80a004
	check_bitmap();
  800ab7:	e8 0a ff ff ff       	call   8009c6 <check_bitmap>
}
  800abc:	83 c4 10             	add    $0x10,%esp
  800abf:	c9                   	leave  
  800ac0:	c3                   	ret    
		ide_set_disk(1);
  800ac1:	83 ec 0c             	sub    $0xc,%esp
  800ac4:	6a 01                	push   $0x1
  800ac6:	e8 f6 f5 ff ff       	call   8000c1 <ide_set_disk>
  800acb:	83 c4 10             	add    $0x10,%esp
  800ace:	eb bd                	jmp    800a8d <fs_init+0x1c>

00800ad0 <file_get_block>:
//	-E_INVAL if filebno is out of range.
//
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
  800ad0:	55                   	push   %ebp
  800ad1:	89 e5                	mov    %esp,%ebp
  800ad3:	53                   	push   %ebx
  800ad4:	83 ec 20             	sub    $0x20,%esp
       // LAB 5: Your code here.
       //panic("file_get_block not implemented");
       int r;
       uint32_t *ppdiskbno;

       if((r=file_block_walk(f,filebno,&ppdiskbno,1))<0){
  800ad7:	6a 01                	push   $0x1
  800ad9:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800adc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800adf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae2:	e8 1c fe ff ff       	call   800903 <file_block_walk>
  800ae7:	83 c4 10             	add    $0x10,%esp
  800aea:	85 c0                	test   %eax,%eax
  800aec:	78 5e                	js     800b4c <file_get_block+0x7c>
         return r;
       }
       if(*ppdiskbno==0){
  800aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800af1:	83 38 00             	cmpl   $0x0,(%eax)
  800af4:	75 3c                	jne    800b32 <file_get_block+0x62>
         if((r=alloc_block())<0)
  800af6:	e8 a5 fd ff ff       	call   8008a0 <alloc_block>
  800afb:	89 c3                	mov    %eax,%ebx
  800afd:	85 c0                	test   %eax,%eax
  800aff:	78 50                	js     800b51 <file_get_block+0x81>
		 return -E_NO_DISK;
	 *ppdiskbno = r;
  800b01:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b04:	89 18                	mov    %ebx,(%eax)
	 memset(diskaddr(r),0,BLKSIZE);
  800b06:	83 ec 0c             	sub    $0xc,%esp
  800b09:	53                   	push   %ebx
  800b0a:	e8 95 f8 ff ff       	call   8003a4 <diskaddr>
  800b0f:	83 c4 0c             	add    $0xc,%esp
  800b12:	68 00 10 00 00       	push   $0x1000
  800b17:	6a 00                	push   $0x0
  800b19:	50                   	push   %eax
  800b1a:	e8 80 18 00 00       	call   80239f <memset>
	 flush_block(diskaddr(r));
  800b1f:	89 1c 24             	mov    %ebx,(%esp)
  800b22:	e8 7d f8 ff ff       	call   8003a4 <diskaddr>
  800b27:	89 04 24             	mov    %eax,(%esp)
  800b2a:	e8 f3 f8 ff ff       	call   800422 <flush_block>
  800b2f:	83 c4 10             	add    $0x10,%esp
       }
       *blk = diskaddr(*ppdiskbno);
  800b32:	83 ec 0c             	sub    $0xc,%esp
  800b35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b38:	ff 30                	pushl  (%eax)
  800b3a:	e8 65 f8 ff ff       	call   8003a4 <diskaddr>
  800b3f:	8b 55 10             	mov    0x10(%ebp),%edx
  800b42:	89 02                	mov    %eax,(%edx)
       return 0;
  800b44:	83 c4 10             	add    $0x10,%esp
  800b47:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b4c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b4f:	c9                   	leave  
  800b50:	c3                   	ret    
		 return -E_NO_DISK;
  800b51:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
  800b56:	eb f4                	jmp    800b4c <file_get_block+0x7c>

00800b58 <walk_path>:
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	57                   	push   %edi
  800b5c:	56                   	push   %esi
  800b5d:	53                   	push   %ebx
  800b5e:	81 ec bc 00 00 00    	sub    $0xbc,%esp
  800b64:	89 95 40 ff ff ff    	mov    %edx,-0xc0(%ebp)
  800b6a:	89 8d 3c ff ff ff    	mov    %ecx,-0xc4(%ebp)
  800b70:	eb 03                	jmp    800b75 <walk_path+0x1d>
		p++;
  800b72:	83 c0 01             	add    $0x1,%eax
	while (*p == '/')
  800b75:	80 38 2f             	cmpb   $0x2f,(%eax)
  800b78:	74 f8                	je     800b72 <walk_path+0x1a>
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
  800b7a:	8b 0d 08 a0 80 00    	mov    0x80a008,%ecx
  800b80:	83 c1 08             	add    $0x8,%ecx
  800b83:	89 8d 4c ff ff ff    	mov    %ecx,-0xb4(%ebp)
	dir = 0;
	name[0] = 0;
  800b89:	c6 85 68 ff ff ff 00 	movb   $0x0,-0x98(%ebp)

	if (pdir)
  800b90:	8b 8d 40 ff ff ff    	mov    -0xc0(%ebp),%ecx
  800b96:	85 c9                	test   %ecx,%ecx
  800b98:	74 06                	je     800ba0 <walk_path+0x48>
		*pdir = 0;
  800b9a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	*pf = 0;
  800ba0:	8b 8d 3c ff ff ff    	mov    -0xc4(%ebp),%ecx
  800ba6:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	dir = 0;
  800bac:	ba 00 00 00 00       	mov    $0x0,%edx
	while (*path != '\0') {
  800bb1:	e9 b4 01 00 00       	jmp    800d6a <walk_path+0x212>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
  800bb6:	83 c7 01             	add    $0x1,%edi
		while (*path != '/' && *path != '\0')
  800bb9:	0f b6 17             	movzbl (%edi),%edx
  800bbc:	80 fa 2f             	cmp    $0x2f,%dl
  800bbf:	74 04                	je     800bc5 <walk_path+0x6d>
  800bc1:	84 d2                	test   %dl,%dl
  800bc3:	75 f1                	jne    800bb6 <walk_path+0x5e>
		if (path - p >= MAXNAMELEN)
  800bc5:	89 fb                	mov    %edi,%ebx
  800bc7:	29 c3                	sub    %eax,%ebx
  800bc9:	83 fb 7f             	cmp    $0x7f,%ebx
  800bcc:	0f 8f 70 01 00 00    	jg     800d42 <walk_path+0x1ea>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800bd2:	83 ec 04             	sub    $0x4,%esp
  800bd5:	53                   	push   %ebx
  800bd6:	50                   	push   %eax
  800bd7:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800bdd:	50                   	push   %eax
  800bde:	e8 09 18 00 00       	call   8023ec <memmove>
		name[path - p] = '\0';
  800be3:	c6 84 1d 68 ff ff ff 	movb   $0x0,-0x98(%ebp,%ebx,1)
  800bea:	00 
  800beb:	83 c4 10             	add    $0x10,%esp
  800bee:	eb 03                	jmp    800bf3 <walk_path+0x9b>
		p++;
  800bf0:	83 c7 01             	add    $0x1,%edi
	while (*p == '/')
  800bf3:	80 3f 2f             	cmpb   $0x2f,(%edi)
  800bf6:	74 f8                	je     800bf0 <walk_path+0x98>
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
  800bf8:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
  800bfe:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  800c05:	0f 85 3e 01 00 00    	jne    800d49 <walk_path+0x1f1>
	assert((dir->f_size % BLKSIZE) == 0);
  800c0b:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  800c11:	a9 ff 0f 00 00       	test   $0xfff,%eax
  800c16:	0f 85 98 00 00 00    	jne    800cb4 <walk_path+0x15c>
	nblock = dir->f_size / BLKSIZE;
  800c1c:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  800c22:	85 c0                	test   %eax,%eax
  800c24:	0f 48 c2             	cmovs  %edx,%eax
  800c27:	c1 f8 0c             	sar    $0xc,%eax
  800c2a:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)
	for (i = 0; i < nblock; i++) {
  800c30:	c7 85 50 ff ff ff 00 	movl   $0x0,-0xb0(%ebp)
  800c37:	00 00 00 
			if (strcmp(f[j].f_name, name) == 0) {
  800c3a:	8d b5 68 ff ff ff    	lea    -0x98(%ebp),%esi
  800c40:	89 bd 44 ff ff ff    	mov    %edi,-0xbc(%ebp)
	for (i = 0; i < nblock; i++) {
  800c46:	8b 8d 50 ff ff ff    	mov    -0xb0(%ebp),%ecx
  800c4c:	39 8d 48 ff ff ff    	cmp    %ecx,-0xb8(%ebp)
  800c52:	74 79                	je     800ccd <walk_path+0x175>
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800c54:	83 ec 04             	sub    $0x4,%esp
  800c57:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
  800c5d:	50                   	push   %eax
  800c5e:	ff b5 50 ff ff ff    	pushl  -0xb0(%ebp)
  800c64:	ff b5 4c ff ff ff    	pushl  -0xb4(%ebp)
  800c6a:	e8 61 fe ff ff       	call   800ad0 <file_get_block>
  800c6f:	83 c4 10             	add    $0x10,%esp
  800c72:	85 c0                	test   %eax,%eax
  800c74:	0f 88 fc 00 00 00    	js     800d76 <walk_path+0x21e>
  800c7a:	8b 9d 64 ff ff ff    	mov    -0x9c(%ebp),%ebx
  800c80:	8d bb 00 10 00 00    	lea    0x1000(%ebx),%edi
			if (strcmp(f[j].f_name, name) == 0) {
  800c86:	89 9d 54 ff ff ff    	mov    %ebx,-0xac(%ebp)
  800c8c:	83 ec 08             	sub    $0x8,%esp
  800c8f:	56                   	push   %esi
  800c90:	53                   	push   %ebx
  800c91:	e8 6e 16 00 00       	call   802304 <strcmp>
  800c96:	83 c4 10             	add    $0x10,%esp
  800c99:	85 c0                	test   %eax,%eax
  800c9b:	0f 84 af 00 00 00    	je     800d50 <walk_path+0x1f8>
  800ca1:	81 c3 00 01 00 00    	add    $0x100,%ebx
		for (j = 0; j < BLKFILES; j++)
  800ca7:	39 fb                	cmp    %edi,%ebx
  800ca9:	75 db                	jne    800c86 <walk_path+0x12e>
	for (i = 0; i < nblock; i++) {
  800cab:	83 85 50 ff ff ff 01 	addl   $0x1,-0xb0(%ebp)
  800cb2:	eb 92                	jmp    800c46 <walk_path+0xee>
	assert((dir->f_size % BLKSIZE) == 0);
  800cb4:	68 f4 3b 80 00       	push   $0x803bf4
  800cb9:	68 5d 39 80 00       	push   $0x80395d
  800cbe:	68 d7 00 00 00       	push   $0xd7
  800cc3:	68 5c 3b 80 00       	push   $0x803b5c
  800cc8:	e8 97 0e 00 00       	call   801b64 <_panic>
  800ccd:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
					*pdir = dir;
				if (lastelem)
					strcpy(lastelem, name);
				*pf = 0;
			}
			return r;
  800cd3:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
			if (r == -E_NOT_FOUND && *path == '\0') {
  800cd8:	80 3f 00             	cmpb   $0x0,(%edi)
  800cdb:	0f 85 a4 00 00 00    	jne    800d85 <walk_path+0x22d>
				if (pdir)
  800ce1:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800ce7:	85 c0                	test   %eax,%eax
  800ce9:	74 08                	je     800cf3 <walk_path+0x19b>
					*pdir = dir;
  800ceb:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800cf1:	89 08                	mov    %ecx,(%eax)
				if (lastelem)
  800cf3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800cf7:	74 15                	je     800d0e <walk_path+0x1b6>
					strcpy(lastelem, name);
  800cf9:	83 ec 08             	sub    $0x8,%esp
  800cfc:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800d02:	50                   	push   %eax
  800d03:	ff 75 08             	pushl  0x8(%ebp)
  800d06:	e8 53 15 00 00       	call   80225e <strcpy>
  800d0b:	83 c4 10             	add    $0x10,%esp
				*pf = 0;
  800d0e:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800d14:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			return r;
  800d1a:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800d1f:	eb 64                	jmp    800d85 <walk_path+0x22d>
		}
	}

	if (pdir)
  800d21:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800d27:	85 c0                	test   %eax,%eax
  800d29:	74 02                	je     800d2d <walk_path+0x1d5>
		*pdir = dir;
  800d2b:	89 10                	mov    %edx,(%eax)
	*pf = f;
  800d2d:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800d33:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800d39:	89 08                	mov    %ecx,(%eax)
	return 0;
  800d3b:	b8 00 00 00 00       	mov    $0x0,%eax
  800d40:	eb 43                	jmp    800d85 <walk_path+0x22d>
			return -E_BAD_PATH;
  800d42:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800d47:	eb 3c                	jmp    800d85 <walk_path+0x22d>
			return -E_NOT_FOUND;
  800d49:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800d4e:	eb 35                	jmp    800d85 <walk_path+0x22d>
  800d50:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
  800d56:	89 f8                	mov    %edi,%eax
  800d58:	8b 95 4c ff ff ff    	mov    -0xb4(%ebp),%edx
			if (strcmp(f[j].f_name, name) == 0) {
  800d5e:	8b 8d 54 ff ff ff    	mov    -0xac(%ebp),%ecx
  800d64:	89 8d 4c ff ff ff    	mov    %ecx,-0xb4(%ebp)
	while (*path != '\0') {
  800d6a:	80 38 00             	cmpb   $0x0,(%eax)
  800d6d:	74 b2                	je     800d21 <walk_path+0x1c9>
  800d6f:	89 c7                	mov    %eax,%edi
  800d71:	e9 43 fe ff ff       	jmp    800bb9 <walk_path+0x61>
  800d76:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
			if (r == -E_NOT_FOUND && *path == '\0') {
  800d7c:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800d7f:	0f 84 4e ff ff ff    	je     800cd3 <walk_path+0x17b>
}
  800d85:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d88:	5b                   	pop    %ebx
  800d89:	5e                   	pop    %esi
  800d8a:	5f                   	pop    %edi
  800d8b:	5d                   	pop    %ebp
  800d8c:	c3                   	ret    

00800d8d <file_open>:

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
  800d8d:	55                   	push   %ebp
  800d8e:	89 e5                	mov    %esp,%ebp
  800d90:	83 ec 14             	sub    $0x14,%esp
	return walk_path(path, 0, pf, 0);
  800d93:	6a 00                	push   $0x0
  800d95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d98:	ba 00 00 00 00       	mov    $0x0,%edx
  800d9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800da0:	e8 b3 fd ff ff       	call   800b58 <walk_path>
}
  800da5:	c9                   	leave  
  800da6:	c3                   	ret    

00800da7 <file_read>:
// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
  800da7:	55                   	push   %ebp
  800da8:	89 e5                	mov    %esp,%ebp
  800daa:	57                   	push   %edi
  800dab:	56                   	push   %esi
  800dac:	53                   	push   %ebx
  800dad:	83 ec 2c             	sub    $0x2c,%esp
  800db0:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800db3:	8b 4d 14             	mov    0x14(%ebp),%ecx
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800db6:	8b 45 08             	mov    0x8(%ebp),%eax
  800db9:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
		return 0;
  800dbf:	b8 00 00 00 00       	mov    $0x0,%eax
	if (offset >= f->f_size)
  800dc4:	39 ca                	cmp    %ecx,%edx
  800dc6:	0f 8e 80 00 00 00    	jle    800e4c <file_read+0xa5>

	count = MIN(count, f->f_size - offset);
  800dcc:	29 ca                	sub    %ecx,%edx
  800dce:	3b 55 10             	cmp    0x10(%ebp),%edx
  800dd1:	89 d0                	mov    %edx,%eax
  800dd3:	0f 47 45 10          	cmova  0x10(%ebp),%eax
  800dd7:	89 45 d0             	mov    %eax,-0x30(%ebp)

	for (pos = offset; pos < offset + count; ) {
  800dda:	89 ce                	mov    %ecx,%esi
  800ddc:	01 c1                	add    %eax,%ecx
  800dde:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800de1:	89 f3                	mov    %esi,%ebx
  800de3:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
  800de6:	76 61                	jbe    800e49 <file_read+0xa2>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800de8:	83 ec 04             	sub    $0x4,%esp
  800deb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800dee:	50                   	push   %eax
  800def:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
  800df5:	85 f6                	test   %esi,%esi
  800df7:	0f 49 c6             	cmovns %esi,%eax
  800dfa:	c1 f8 0c             	sar    $0xc,%eax
  800dfd:	50                   	push   %eax
  800dfe:	ff 75 08             	pushl  0x8(%ebp)
  800e01:	e8 ca fc ff ff       	call   800ad0 <file_get_block>
  800e06:	83 c4 10             	add    $0x10,%esp
  800e09:	85 c0                	test   %eax,%eax
  800e0b:	78 3f                	js     800e4c <file_read+0xa5>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800e0d:	89 f2                	mov    %esi,%edx
  800e0f:	c1 fa 1f             	sar    $0x1f,%edx
  800e12:	c1 ea 14             	shr    $0x14,%edx
  800e15:	8d 04 16             	lea    (%esi,%edx,1),%eax
  800e18:	25 ff 0f 00 00       	and    $0xfff,%eax
  800e1d:	29 d0                	sub    %edx,%eax
  800e1f:	ba 00 10 00 00       	mov    $0x1000,%edx
  800e24:	29 c2                	sub    %eax,%edx
  800e26:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800e29:	29 d9                	sub    %ebx,%ecx
  800e2b:	89 cb                	mov    %ecx,%ebx
  800e2d:	39 ca                	cmp    %ecx,%edx
  800e2f:	0f 46 da             	cmovbe %edx,%ebx
		memmove(buf, blk + pos % BLKSIZE, bn);
  800e32:	83 ec 04             	sub    $0x4,%esp
  800e35:	53                   	push   %ebx
  800e36:	03 45 e4             	add    -0x1c(%ebp),%eax
  800e39:	50                   	push   %eax
  800e3a:	57                   	push   %edi
  800e3b:	e8 ac 15 00 00       	call   8023ec <memmove>
		pos += bn;
  800e40:	01 de                	add    %ebx,%esi
		buf += bn;
  800e42:	01 df                	add    %ebx,%edi
  800e44:	83 c4 10             	add    $0x10,%esp
  800e47:	eb 98                	jmp    800de1 <file_read+0x3a>
	}

	return count;
  800e49:	8b 45 d0             	mov    -0x30(%ebp),%eax
}
  800e4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e4f:	5b                   	pop    %ebx
  800e50:	5e                   	pop    %esi
  800e51:	5f                   	pop    %edi
  800e52:	5d                   	pop    %ebp
  800e53:	c3                   	ret    

00800e54 <file_set_size>:
}

// Set the size of file f, truncating or extending as necessary.
int
file_set_size(struct File *f, off_t newsize)
{
  800e54:	55                   	push   %ebp
  800e55:	89 e5                	mov    %esp,%ebp
  800e57:	57                   	push   %edi
  800e58:	56                   	push   %esi
  800e59:	53                   	push   %ebx
  800e5a:	83 ec 2c             	sub    $0x2c,%esp
  800e5d:	8b 75 08             	mov    0x8(%ebp),%esi
	if (f->f_size > newsize)
  800e60:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  800e66:	3b 45 0c             	cmp    0xc(%ebp),%eax
  800e69:	7f 1f                	jg     800e8a <file_set_size+0x36>
		file_truncate_blocks(f, newsize);
	f->f_size = newsize;
  800e6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e6e:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	flush_block(f);
  800e74:	83 ec 0c             	sub    $0xc,%esp
  800e77:	56                   	push   %esi
  800e78:	e8 a5 f5 ff ff       	call   800422 <flush_block>
	return 0;
}
  800e7d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e85:	5b                   	pop    %ebx
  800e86:	5e                   	pop    %esi
  800e87:	5f                   	pop    %edi
  800e88:	5d                   	pop    %ebp
  800e89:	c3                   	ret    
	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
  800e8a:	8d b8 fe 1f 00 00    	lea    0x1ffe(%eax),%edi
  800e90:	05 ff 0f 00 00       	add    $0xfff,%eax
  800e95:	0f 49 f8             	cmovns %eax,%edi
  800e98:	c1 ff 0c             	sar    $0xc,%edi
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  800e9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e9e:	05 fe 1f 00 00       	add    $0x1ffe,%eax
  800ea3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ea6:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
  800eac:	0f 49 c2             	cmovns %edx,%eax
  800eaf:	c1 f8 0c             	sar    $0xc,%eax
  800eb2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800eb5:	89 c3                	mov    %eax,%ebx
  800eb7:	eb 3c                	jmp    800ef5 <file_set_size+0xa1>
	if (new_nblocks <= NDIRECT && f->f_indirect) {
  800eb9:	83 7d d4 0a          	cmpl   $0xa,-0x2c(%ebp)
  800ebd:	77 ac                	ja     800e6b <file_set_size+0x17>
  800ebf:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800ec5:	85 c0                	test   %eax,%eax
  800ec7:	74 a2                	je     800e6b <file_set_size+0x17>
		free_block(f->f_indirect);
  800ec9:	83 ec 0c             	sub    $0xc,%esp
  800ecc:	50                   	push   %eax
  800ecd:	e8 92 f9 ff ff       	call   800864 <free_block>
		f->f_indirect = 0;
  800ed2:	c7 86 b0 00 00 00 00 	movl   $0x0,0xb0(%esi)
  800ed9:	00 00 00 
  800edc:	83 c4 10             	add    $0x10,%esp
  800edf:	eb 8a                	jmp    800e6b <file_set_size+0x17>
			cprintf("warning: file_free_block: %e", r);
  800ee1:	83 ec 08             	sub    $0x8,%esp
  800ee4:	50                   	push   %eax
  800ee5:	68 11 3c 80 00       	push   $0x803c11
  800eea:	e8 50 0d 00 00       	call   801c3f <cprintf>
  800eef:	83 c4 10             	add    $0x10,%esp
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800ef2:	83 c3 01             	add    $0x1,%ebx
  800ef5:	39 df                	cmp    %ebx,%edi
  800ef7:	76 c0                	jbe    800eb9 <file_set_size+0x65>
	if ((r = file_block_walk(f, filebno, &ptr, 0)) < 0)
  800ef9:	83 ec 0c             	sub    $0xc,%esp
  800efc:	6a 00                	push   $0x0
  800efe:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800f01:	89 da                	mov    %ebx,%edx
  800f03:	89 f0                	mov    %esi,%eax
  800f05:	e8 f9 f9 ff ff       	call   800903 <file_block_walk>
  800f0a:	83 c4 10             	add    $0x10,%esp
  800f0d:	85 c0                	test   %eax,%eax
  800f0f:	78 d0                	js     800ee1 <file_set_size+0x8d>
	if (*ptr) {
  800f11:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f14:	8b 00                	mov    (%eax),%eax
  800f16:	85 c0                	test   %eax,%eax
  800f18:	74 d8                	je     800ef2 <file_set_size+0x9e>
		free_block(*ptr);
  800f1a:	83 ec 0c             	sub    $0xc,%esp
  800f1d:	50                   	push   %eax
  800f1e:	e8 41 f9 ff ff       	call   800864 <free_block>
		*ptr = 0;
  800f23:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f26:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  800f2c:	83 c4 10             	add    $0x10,%esp
  800f2f:	eb c1                	jmp    800ef2 <file_set_size+0x9e>

00800f31 <file_write>:
{
  800f31:	55                   	push   %ebp
  800f32:	89 e5                	mov    %esp,%ebp
  800f34:	57                   	push   %edi
  800f35:	56                   	push   %esi
  800f36:	53                   	push   %ebx
  800f37:	83 ec 2c             	sub    $0x2c,%esp
  800f3a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800f3d:	8b 75 14             	mov    0x14(%ebp),%esi
	if (offset + count > f->f_size)
  800f40:	89 f0                	mov    %esi,%eax
  800f42:	03 45 10             	add    0x10(%ebp),%eax
  800f45:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800f48:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f4b:	3b 81 80 00 00 00    	cmp    0x80(%ecx),%eax
  800f51:	77 68                	ja     800fbb <file_write+0x8a>
	for (pos = offset; pos < offset + count; ) {
  800f53:	89 f3                	mov    %esi,%ebx
  800f55:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
  800f58:	76 74                	jbe    800fce <file_write+0x9d>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800f5a:	83 ec 04             	sub    $0x4,%esp
  800f5d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f60:	50                   	push   %eax
  800f61:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
  800f67:	85 f6                	test   %esi,%esi
  800f69:	0f 49 c6             	cmovns %esi,%eax
  800f6c:	c1 f8 0c             	sar    $0xc,%eax
  800f6f:	50                   	push   %eax
  800f70:	ff 75 08             	pushl  0x8(%ebp)
  800f73:	e8 58 fb ff ff       	call   800ad0 <file_get_block>
  800f78:	83 c4 10             	add    $0x10,%esp
  800f7b:	85 c0                	test   %eax,%eax
  800f7d:	78 52                	js     800fd1 <file_write+0xa0>
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800f7f:	89 f2                	mov    %esi,%edx
  800f81:	c1 fa 1f             	sar    $0x1f,%edx
  800f84:	c1 ea 14             	shr    $0x14,%edx
  800f87:	8d 04 16             	lea    (%esi,%edx,1),%eax
  800f8a:	25 ff 0f 00 00       	and    $0xfff,%eax
  800f8f:	29 d0                	sub    %edx,%eax
  800f91:	b9 00 10 00 00       	mov    $0x1000,%ecx
  800f96:	29 c1                	sub    %eax,%ecx
  800f98:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800f9b:	29 da                	sub    %ebx,%edx
  800f9d:	39 d1                	cmp    %edx,%ecx
  800f9f:	89 d3                	mov    %edx,%ebx
  800fa1:	0f 46 d9             	cmovbe %ecx,%ebx
		memmove(blk + pos % BLKSIZE, buf, bn);
  800fa4:	83 ec 04             	sub    $0x4,%esp
  800fa7:	53                   	push   %ebx
  800fa8:	57                   	push   %edi
  800fa9:	03 45 e4             	add    -0x1c(%ebp),%eax
  800fac:	50                   	push   %eax
  800fad:	e8 3a 14 00 00       	call   8023ec <memmove>
		pos += bn;
  800fb2:	01 de                	add    %ebx,%esi
		buf += bn;
  800fb4:	01 df                	add    %ebx,%edi
  800fb6:	83 c4 10             	add    $0x10,%esp
  800fb9:	eb 98                	jmp    800f53 <file_write+0x22>
		if ((r = file_set_size(f, offset + count)) < 0)
  800fbb:	83 ec 08             	sub    $0x8,%esp
  800fbe:	50                   	push   %eax
  800fbf:	51                   	push   %ecx
  800fc0:	e8 8f fe ff ff       	call   800e54 <file_set_size>
  800fc5:	83 c4 10             	add    $0x10,%esp
  800fc8:	85 c0                	test   %eax,%eax
  800fca:	79 87                	jns    800f53 <file_write+0x22>
  800fcc:	eb 03                	jmp    800fd1 <file_write+0xa0>
	return count;
  800fce:	8b 45 10             	mov    0x10(%ebp),%eax
}
  800fd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fd4:	5b                   	pop    %ebx
  800fd5:	5e                   	pop    %esi
  800fd6:	5f                   	pop    %edi
  800fd7:	5d                   	pop    %ebp
  800fd8:	c3                   	ret    

00800fd9 <file_flush>:
// Loop over all the blocks in file.
// Translate the file block number into a disk block number
// and then check whether that disk block is dirty.  If so, write it out.
void
file_flush(struct File *f)
{
  800fd9:	55                   	push   %ebp
  800fda:	89 e5                	mov    %esp,%ebp
  800fdc:	56                   	push   %esi
  800fdd:	53                   	push   %ebx
  800fde:	83 ec 10             	sub    $0x10,%esp
  800fe1:	8b 75 08             	mov    0x8(%ebp),%esi
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800fe4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fe9:	eb 03                	jmp    800fee <file_flush+0x15>
  800feb:	83 c3 01             	add    $0x1,%ebx
  800fee:	8b 96 80 00 00 00    	mov    0x80(%esi),%edx
  800ff4:	8d 8a ff 0f 00 00    	lea    0xfff(%edx),%ecx
  800ffa:	8d 82 fe 1f 00 00    	lea    0x1ffe(%edx),%eax
  801000:	85 c9                	test   %ecx,%ecx
  801002:	0f 49 c1             	cmovns %ecx,%eax
  801005:	c1 f8 0c             	sar    $0xc,%eax
  801008:	39 d8                	cmp    %ebx,%eax
  80100a:	7e 3b                	jle    801047 <file_flush+0x6e>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  80100c:	83 ec 0c             	sub    $0xc,%esp
  80100f:	6a 00                	push   $0x0
  801011:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  801014:	89 da                	mov    %ebx,%edx
  801016:	89 f0                	mov    %esi,%eax
  801018:	e8 e6 f8 ff ff       	call   800903 <file_block_walk>
  80101d:	83 c4 10             	add    $0x10,%esp
  801020:	85 c0                	test   %eax,%eax
  801022:	78 c7                	js     800feb <file_flush+0x12>
		    pdiskbno == NULL || *pdiskbno == 0)
  801024:	8b 45 f4             	mov    -0xc(%ebp),%eax
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  801027:	85 c0                	test   %eax,%eax
  801029:	74 c0                	je     800feb <file_flush+0x12>
		    pdiskbno == NULL || *pdiskbno == 0)
  80102b:	8b 00                	mov    (%eax),%eax
  80102d:	85 c0                	test   %eax,%eax
  80102f:	74 ba                	je     800feb <file_flush+0x12>
			continue;
		flush_block(diskaddr(*pdiskbno));
  801031:	83 ec 0c             	sub    $0xc,%esp
  801034:	50                   	push   %eax
  801035:	e8 6a f3 ff ff       	call   8003a4 <diskaddr>
  80103a:	89 04 24             	mov    %eax,(%esp)
  80103d:	e8 e0 f3 ff ff       	call   800422 <flush_block>
  801042:	83 c4 10             	add    $0x10,%esp
  801045:	eb a4                	jmp    800feb <file_flush+0x12>
	}
	flush_block(f);
  801047:	83 ec 0c             	sub    $0xc,%esp
  80104a:	56                   	push   %esi
  80104b:	e8 d2 f3 ff ff       	call   800422 <flush_block>
	if (f->f_indirect)
  801050:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  801056:	83 c4 10             	add    $0x10,%esp
  801059:	85 c0                	test   %eax,%eax
  80105b:	75 07                	jne    801064 <file_flush+0x8b>
		flush_block(diskaddr(f->f_indirect));
}
  80105d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801060:	5b                   	pop    %ebx
  801061:	5e                   	pop    %esi
  801062:	5d                   	pop    %ebp
  801063:	c3                   	ret    
		flush_block(diskaddr(f->f_indirect));
  801064:	83 ec 0c             	sub    $0xc,%esp
  801067:	50                   	push   %eax
  801068:	e8 37 f3 ff ff       	call   8003a4 <diskaddr>
  80106d:	89 04 24             	mov    %eax,(%esp)
  801070:	e8 ad f3 ff ff       	call   800422 <flush_block>
  801075:	83 c4 10             	add    $0x10,%esp
}
  801078:	eb e3                	jmp    80105d <file_flush+0x84>

0080107a <file_create>:
{
  80107a:	55                   	push   %ebp
  80107b:	89 e5                	mov    %esp,%ebp
  80107d:	57                   	push   %edi
  80107e:	56                   	push   %esi
  80107f:	53                   	push   %ebx
  801080:	81 ec b8 00 00 00    	sub    $0xb8,%esp
	if ((r = walk_path(path, &dir, &f, name)) == 0)
  801086:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  80108c:	50                   	push   %eax
  80108d:	8d 8d 60 ff ff ff    	lea    -0xa0(%ebp),%ecx
  801093:	8d 95 64 ff ff ff    	lea    -0x9c(%ebp),%edx
  801099:	8b 45 08             	mov    0x8(%ebp),%eax
  80109c:	e8 b7 fa ff ff       	call   800b58 <walk_path>
  8010a1:	83 c4 10             	add    $0x10,%esp
  8010a4:	85 c0                	test   %eax,%eax
  8010a6:	0f 84 0e 01 00 00    	je     8011ba <file_create+0x140>
	if (r != -E_NOT_FOUND || dir == 0)
  8010ac:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8010af:	74 08                	je     8010b9 <file_create+0x3f>
}
  8010b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010b4:	5b                   	pop    %ebx
  8010b5:	5e                   	pop    %esi
  8010b6:	5f                   	pop    %edi
  8010b7:	5d                   	pop    %ebp
  8010b8:	c3                   	ret    
	if (r != -E_NOT_FOUND || dir == 0)
  8010b9:	8b 9d 64 ff ff ff    	mov    -0x9c(%ebp),%ebx
  8010bf:	85 db                	test   %ebx,%ebx
  8010c1:	74 ee                	je     8010b1 <file_create+0x37>
	assert((dir->f_size % BLKSIZE) == 0);
  8010c3:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
  8010c9:	a9 ff 0f 00 00       	test   $0xfff,%eax
  8010ce:	75 5c                	jne    80112c <file_create+0xb2>
	nblock = dir->f_size / BLKSIZE;
  8010d0:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  8010d6:	85 c0                	test   %eax,%eax
  8010d8:	0f 48 c2             	cmovs  %edx,%eax
  8010db:	c1 f8 0c             	sar    $0xc,%eax
  8010de:	89 85 54 ff ff ff    	mov    %eax,-0xac(%ebp)
	for (i = 0; i < nblock; i++) {
  8010e4:	be 00 00 00 00       	mov    $0x0,%esi
		if ((r = file_get_block(dir, i, &blk)) < 0)
  8010e9:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
	for (i = 0; i < nblock; i++) {
  8010ef:	39 b5 54 ff ff ff    	cmp    %esi,-0xac(%ebp)
  8010f5:	0f 84 8b 00 00 00    	je     801186 <file_create+0x10c>
		if ((r = file_get_block(dir, i, &blk)) < 0)
  8010fb:	83 ec 04             	sub    $0x4,%esp
  8010fe:	57                   	push   %edi
  8010ff:	56                   	push   %esi
  801100:	53                   	push   %ebx
  801101:	e8 ca f9 ff ff       	call   800ad0 <file_get_block>
  801106:	83 c4 10             	add    $0x10,%esp
  801109:	85 c0                	test   %eax,%eax
  80110b:	78 a4                	js     8010b1 <file_create+0x37>
  80110d:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  801113:	8d 88 00 10 00 00    	lea    0x1000(%eax),%ecx
			if (f[j].f_name[0] == '\0') {
  801119:	80 38 00             	cmpb   $0x0,(%eax)
  80111c:	74 27                	je     801145 <file_create+0xcb>
  80111e:	05 00 01 00 00       	add    $0x100,%eax
		for (j = 0; j < BLKFILES; j++)
  801123:	39 c8                	cmp    %ecx,%eax
  801125:	75 f2                	jne    801119 <file_create+0x9f>
	for (i = 0; i < nblock; i++) {
  801127:	83 c6 01             	add    $0x1,%esi
  80112a:	eb c3                	jmp    8010ef <file_create+0x75>
	assert((dir->f_size % BLKSIZE) == 0);
  80112c:	68 f4 3b 80 00       	push   $0x803bf4
  801131:	68 5d 39 80 00       	push   $0x80395d
  801136:	68 f0 00 00 00       	push   $0xf0
  80113b:	68 5c 3b 80 00       	push   $0x803b5c
  801140:	e8 1f 0a 00 00       	call   801b64 <_panic>
				*file = &f[j];
  801145:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
	strcpy(f->f_name, name);
  80114b:	83 ec 08             	sub    $0x8,%esp
  80114e:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  801154:	50                   	push   %eax
  801155:	ff b5 60 ff ff ff    	pushl  -0xa0(%ebp)
  80115b:	e8 fe 10 00 00       	call   80225e <strcpy>
	*pf = f;
  801160:	8b 45 0c             	mov    0xc(%ebp),%eax
  801163:	8b 95 60 ff ff ff    	mov    -0xa0(%ebp),%edx
  801169:	89 10                	mov    %edx,(%eax)
	file_flush(dir);
  80116b:	83 c4 04             	add    $0x4,%esp
  80116e:	ff b5 64 ff ff ff    	pushl  -0x9c(%ebp)
  801174:	e8 60 fe ff ff       	call   800fd9 <file_flush>
	return 0;
  801179:	83 c4 10             	add    $0x10,%esp
  80117c:	b8 00 00 00 00       	mov    $0x0,%eax
  801181:	e9 2b ff ff ff       	jmp    8010b1 <file_create+0x37>
	dir->f_size += BLKSIZE;
  801186:	81 83 80 00 00 00 00 	addl   $0x1000,0x80(%ebx)
  80118d:	10 00 00 
	if ((r = file_get_block(dir, i, &blk)) < 0)
  801190:	83 ec 04             	sub    $0x4,%esp
  801193:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
  801199:	50                   	push   %eax
  80119a:	56                   	push   %esi
  80119b:	53                   	push   %ebx
  80119c:	e8 2f f9 ff ff       	call   800ad0 <file_get_block>
  8011a1:	83 c4 10             	add    $0x10,%esp
  8011a4:	85 c0                	test   %eax,%eax
  8011a6:	0f 88 05 ff ff ff    	js     8010b1 <file_create+0x37>
	*file = &f[0];
  8011ac:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  8011b2:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  8011b8:	eb 91                	jmp    80114b <file_create+0xd1>
		return -E_FILE_EXISTS;
  8011ba:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax
  8011bf:	e9 ed fe ff ff       	jmp    8010b1 <file_create+0x37>

008011c4 <fs_sync>:


// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
  8011c4:	55                   	push   %ebp
  8011c5:	89 e5                	mov    %esp,%ebp
  8011c7:	53                   	push   %ebx
  8011c8:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  8011cb:	bb 01 00 00 00       	mov    $0x1,%ebx
  8011d0:	eb 17                	jmp    8011e9 <fs_sync+0x25>
		flush_block(diskaddr(i));
  8011d2:	83 ec 0c             	sub    $0xc,%esp
  8011d5:	53                   	push   %ebx
  8011d6:	e8 c9 f1 ff ff       	call   8003a4 <diskaddr>
  8011db:	89 04 24             	mov    %eax,(%esp)
  8011de:	e8 3f f2 ff ff       	call   800422 <flush_block>
	for (i = 1; i < super->s_nblocks; i++)
  8011e3:	83 c3 01             	add    $0x1,%ebx
  8011e6:	83 c4 10             	add    $0x10,%esp
  8011e9:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8011ee:	39 58 04             	cmp    %ebx,0x4(%eax)
  8011f1:	77 df                	ja     8011d2 <fs_sync+0xe>
}
  8011f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011f6:	c9                   	leave  
  8011f7:	c3                   	ret    

008011f8 <serve_sync>:
}


int
serve_sync(envid_t envid, union Fsipc *req)
{
  8011f8:	55                   	push   %ebp
  8011f9:	89 e5                	mov    %esp,%ebp
  8011fb:	83 ec 08             	sub    $0x8,%esp
	fs_sync();
  8011fe:	e8 c1 ff ff ff       	call   8011c4 <fs_sync>
	return 0;
}
  801203:	b8 00 00 00 00       	mov    $0x0,%eax
  801208:	c9                   	leave  
  801209:	c3                   	ret    

0080120a <serve_init>:
{
  80120a:	55                   	push   %ebp
  80120b:	89 e5                	mov    %esp,%ebp
  80120d:	ba 60 50 80 00       	mov    $0x805060,%edx
	uintptr_t va = FILEVA;
  801212:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  801217:	b8 00 00 00 00       	mov    $0x0,%eax
		opentab[i].o_fileid = i;
  80121c:	89 02                	mov    %eax,(%edx)
		opentab[i].o_fd = (struct Fd*) va;
  80121e:	89 4a 0c             	mov    %ecx,0xc(%edx)
		va += PGSIZE;
  801221:	81 c1 00 10 00 00    	add    $0x1000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  801227:	83 c0 01             	add    $0x1,%eax
  80122a:	83 c2 10             	add    $0x10,%edx
  80122d:	3d 00 04 00 00       	cmp    $0x400,%eax
  801232:	75 e8                	jne    80121c <serve_init+0x12>
}
  801234:	5d                   	pop    %ebp
  801235:	c3                   	ret    

00801236 <openfile_alloc>:
{
  801236:	55                   	push   %ebp
  801237:	89 e5                	mov    %esp,%ebp
  801239:	57                   	push   %edi
  80123a:	56                   	push   %esi
  80123b:	53                   	push   %ebx
  80123c:	83 ec 0c             	sub    $0xc,%esp
  80123f:	8b 7d 08             	mov    0x8(%ebp),%edi
	for (i = 0; i < MAXOPEN; i++) {
  801242:	bb 00 00 00 00       	mov    $0x0,%ebx
  801247:	89 de                	mov    %ebx,%esi
  801249:	c1 e6 04             	shl    $0x4,%esi
		switch (pageref(opentab[i].o_fd)) {
  80124c:	83 ec 0c             	sub    $0xc,%esp
  80124f:	ff b6 6c 50 80 00    	pushl  0x80506c(%esi)
  801255:	e8 6f 1f 00 00       	call   8031c9 <pageref>
  80125a:	83 c4 10             	add    $0x10,%esp
  80125d:	85 c0                	test   %eax,%eax
  80125f:	74 17                	je     801278 <openfile_alloc+0x42>
  801261:	83 f8 01             	cmp    $0x1,%eax
  801264:	74 30                	je     801296 <openfile_alloc+0x60>
	for (i = 0; i < MAXOPEN; i++) {
  801266:	83 c3 01             	add    $0x1,%ebx
  801269:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  80126f:	75 d6                	jne    801247 <openfile_alloc+0x11>
	return -E_MAX_OPEN;
  801271:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801276:	eb 4f                	jmp    8012c7 <openfile_alloc+0x91>
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  801278:	83 ec 04             	sub    $0x4,%esp
  80127b:	6a 07                	push   $0x7
  80127d:	89 d8                	mov    %ebx,%eax
  80127f:	c1 e0 04             	shl    $0x4,%eax
  801282:	ff b0 6c 50 80 00    	pushl  0x80506c(%eax)
  801288:	6a 00                	push   $0x0
  80128a:	e8 c8 13 00 00       	call   802657 <sys_page_alloc>
  80128f:	83 c4 10             	add    $0x10,%esp
  801292:	85 c0                	test   %eax,%eax
  801294:	78 31                	js     8012c7 <openfile_alloc+0x91>
			opentab[i].o_fileid += MAXOPEN;
  801296:	c1 e3 04             	shl    $0x4,%ebx
  801299:	81 83 60 50 80 00 00 	addl   $0x400,0x805060(%ebx)
  8012a0:	04 00 00 
			*o = &opentab[i];
  8012a3:	81 c6 60 50 80 00    	add    $0x805060,%esi
  8012a9:	89 37                	mov    %esi,(%edi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  8012ab:	83 ec 04             	sub    $0x4,%esp
  8012ae:	68 00 10 00 00       	push   $0x1000
  8012b3:	6a 00                	push   $0x0
  8012b5:	ff b3 6c 50 80 00    	pushl  0x80506c(%ebx)
  8012bb:	e8 df 10 00 00       	call   80239f <memset>
			return (*o)->o_fileid;
  8012c0:	8b 07                	mov    (%edi),%eax
  8012c2:	8b 00                	mov    (%eax),%eax
  8012c4:	83 c4 10             	add    $0x10,%esp
}
  8012c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012ca:	5b                   	pop    %ebx
  8012cb:	5e                   	pop    %esi
  8012cc:	5f                   	pop    %edi
  8012cd:	5d                   	pop    %ebp
  8012ce:	c3                   	ret    

008012cf <openfile_lookup>:
{
  8012cf:	55                   	push   %ebp
  8012d0:	89 e5                	mov    %esp,%ebp
  8012d2:	57                   	push   %edi
  8012d3:	56                   	push   %esi
  8012d4:	53                   	push   %ebx
  8012d5:	83 ec 18             	sub    $0x18,%esp
  8012d8:	8b 7d 0c             	mov    0xc(%ebp),%edi
	o = &opentab[fileid % MAXOPEN];
  8012db:	89 fb                	mov    %edi,%ebx
  8012dd:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  8012e3:	89 de                	mov    %ebx,%esi
  8012e5:	c1 e6 04             	shl    $0x4,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  8012e8:	ff b6 6c 50 80 00    	pushl  0x80506c(%esi)
	o = &opentab[fileid % MAXOPEN];
  8012ee:	81 c6 60 50 80 00    	add    $0x805060,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  8012f4:	e8 d0 1e 00 00       	call   8031c9 <pageref>
  8012f9:	83 c4 10             	add    $0x10,%esp
  8012fc:	83 f8 01             	cmp    $0x1,%eax
  8012ff:	7e 1d                	jle    80131e <openfile_lookup+0x4f>
  801301:	c1 e3 04             	shl    $0x4,%ebx
  801304:	39 bb 60 50 80 00    	cmp    %edi,0x805060(%ebx)
  80130a:	75 19                	jne    801325 <openfile_lookup+0x56>
	*po = o;
  80130c:	8b 45 10             	mov    0x10(%ebp),%eax
  80130f:	89 30                	mov    %esi,(%eax)
	return 0;
  801311:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801316:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801319:	5b                   	pop    %ebx
  80131a:	5e                   	pop    %esi
  80131b:	5f                   	pop    %edi
  80131c:	5d                   	pop    %ebp
  80131d:	c3                   	ret    
		return -E_INVAL;
  80131e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801323:	eb f1                	jmp    801316 <openfile_lookup+0x47>
  801325:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80132a:	eb ea                	jmp    801316 <openfile_lookup+0x47>

0080132c <serve_set_size>:
{
  80132c:	55                   	push   %ebp
  80132d:	89 e5                	mov    %esp,%ebp
  80132f:	53                   	push   %ebx
  801330:	83 ec 18             	sub    $0x18,%esp
  801333:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801336:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801339:	50                   	push   %eax
  80133a:	ff 33                	pushl  (%ebx)
  80133c:	ff 75 08             	pushl  0x8(%ebp)
  80133f:	e8 8b ff ff ff       	call   8012cf <openfile_lookup>
  801344:	83 c4 10             	add    $0x10,%esp
  801347:	85 c0                	test   %eax,%eax
  801349:	78 14                	js     80135f <serve_set_size+0x33>
	return file_set_size(o->o_file, req->req_size);
  80134b:	83 ec 08             	sub    $0x8,%esp
  80134e:	ff 73 04             	pushl  0x4(%ebx)
  801351:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801354:	ff 70 04             	pushl  0x4(%eax)
  801357:	e8 f8 fa ff ff       	call   800e54 <file_set_size>
  80135c:	83 c4 10             	add    $0x10,%esp
}
  80135f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801362:	c9                   	leave  
  801363:	c3                   	ret    

00801364 <serve_read>:
{
  801364:	55                   	push   %ebp
  801365:	89 e5                	mov    %esp,%ebp
  801367:	53                   	push   %ebx
  801368:	83 ec 18             	sub    $0x18,%esp
  80136b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if((r = openfile_lookup(envid,req->req_fileid,&o))<0)
  80136e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801371:	50                   	push   %eax
  801372:	ff 33                	pushl  (%ebx)
  801374:	ff 75 08             	pushl  0x8(%ebp)
  801377:	e8 53 ff ff ff       	call   8012cf <openfile_lookup>
  80137c:	83 c4 10             	add    $0x10,%esp
  80137f:	85 c0                	test   %eax,%eax
  801381:	78 25                	js     8013a8 <serve_read+0x44>
	if((r=file_read(o->o_file,ret->ret_buf,req->req_n,o->o_fd->fd_offset))<0)
  801383:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801386:	8b 50 0c             	mov    0xc(%eax),%edx
  801389:	ff 72 04             	pushl  0x4(%edx)
  80138c:	ff 73 04             	pushl  0x4(%ebx)
  80138f:	53                   	push   %ebx
  801390:	ff 70 04             	pushl  0x4(%eax)
  801393:	e8 0f fa ff ff       	call   800da7 <file_read>
  801398:	83 c4 10             	add    $0x10,%esp
  80139b:	85 c0                	test   %eax,%eax
  80139d:	78 09                	js     8013a8 <serve_read+0x44>
	o->o_fd->fd_offset += r;
  80139f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013a2:	8b 52 0c             	mov    0xc(%edx),%edx
  8013a5:	01 42 04             	add    %eax,0x4(%edx)
}
  8013a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ab:	c9                   	leave  
  8013ac:	c3                   	ret    

008013ad <serve_write>:
{
  8013ad:	55                   	push   %ebp
  8013ae:	89 e5                	mov    %esp,%ebp
  8013b0:	53                   	push   %ebx
  8013b1:	83 ec 18             	sub    $0x18,%esp
  8013b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if((r=openfile_lookup(envid,req->req_fileid,&o))<0)
  8013b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ba:	50                   	push   %eax
  8013bb:	ff 33                	pushl  (%ebx)
  8013bd:	ff 75 08             	pushl  0x8(%ebp)
  8013c0:	e8 0a ff ff ff       	call   8012cf <openfile_lookup>
  8013c5:	83 c4 10             	add    $0x10,%esp
  8013c8:	85 c0                	test   %eax,%eax
  8013ca:	78 36                	js     801402 <serve_write+0x55>
	if((r=file_write(o->o_file,req->req_buf,req_n,o->o_fd->fd_offset))<0)
  8013cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013cf:	8b 42 0c             	mov    0xc(%edx),%eax
  8013d2:	ff 70 04             	pushl  0x4(%eax)
	req_n = req->req_n > PGSIZE ? PGSIZE:req->req_n;
  8013d5:	81 7b 04 00 10 00 00 	cmpl   $0x1000,0x4(%ebx)
  8013dc:	b8 00 10 00 00       	mov    $0x1000,%eax
  8013e1:	0f 46 43 04          	cmovbe 0x4(%ebx),%eax
	if((r=file_write(o->o_file,req->req_buf,req_n,o->o_fd->fd_offset))<0)
  8013e5:	50                   	push   %eax
  8013e6:	83 c3 08             	add    $0x8,%ebx
  8013e9:	53                   	push   %ebx
  8013ea:	ff 72 04             	pushl  0x4(%edx)
  8013ed:	e8 3f fb ff ff       	call   800f31 <file_write>
  8013f2:	83 c4 10             	add    $0x10,%esp
  8013f5:	85 c0                	test   %eax,%eax
  8013f7:	78 09                	js     801402 <serve_write+0x55>
	o->o_fd->fd_offset += r;
  8013f9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013fc:	8b 52 0c             	mov    0xc(%edx),%edx
  8013ff:	01 42 04             	add    %eax,0x4(%edx)
}
  801402:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801405:	c9                   	leave  
  801406:	c3                   	ret    

00801407 <serve_stat>:
{
  801407:	55                   	push   %ebp
  801408:	89 e5                	mov    %esp,%ebp
  80140a:	53                   	push   %ebx
  80140b:	83 ec 18             	sub    $0x18,%esp
  80140e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801411:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801414:	50                   	push   %eax
  801415:	ff 33                	pushl  (%ebx)
  801417:	ff 75 08             	pushl  0x8(%ebp)
  80141a:	e8 b0 fe ff ff       	call   8012cf <openfile_lookup>
  80141f:	83 c4 10             	add    $0x10,%esp
  801422:	85 c0                	test   %eax,%eax
  801424:	78 3f                	js     801465 <serve_stat+0x5e>
	strcpy(ret->ret_name, o->o_file->f_name);
  801426:	83 ec 08             	sub    $0x8,%esp
  801429:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80142c:	ff 70 04             	pushl  0x4(%eax)
  80142f:	53                   	push   %ebx
  801430:	e8 29 0e 00 00       	call   80225e <strcpy>
	ret->ret_size = o->o_file->f_size;
  801435:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801438:	8b 50 04             	mov    0x4(%eax),%edx
  80143b:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  801441:	89 93 80 00 00 00    	mov    %edx,0x80(%ebx)
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  801447:	8b 40 04             	mov    0x4(%eax),%eax
  80144a:	83 c4 10             	add    $0x10,%esp
  80144d:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  801454:	0f 94 c0             	sete   %al
  801457:	0f b6 c0             	movzbl %al,%eax
  80145a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801460:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801465:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801468:	c9                   	leave  
  801469:	c3                   	ret    

0080146a <serve_flush>:
{
  80146a:	55                   	push   %ebp
  80146b:	89 e5                	mov    %esp,%ebp
  80146d:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801470:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801473:	50                   	push   %eax
  801474:	8b 45 0c             	mov    0xc(%ebp),%eax
  801477:	ff 30                	pushl  (%eax)
  801479:	ff 75 08             	pushl  0x8(%ebp)
  80147c:	e8 4e fe ff ff       	call   8012cf <openfile_lookup>
  801481:	83 c4 10             	add    $0x10,%esp
  801484:	85 c0                	test   %eax,%eax
  801486:	78 16                	js     80149e <serve_flush+0x34>
	file_flush(o->o_file);
  801488:	83 ec 0c             	sub    $0xc,%esp
  80148b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80148e:	ff 70 04             	pushl  0x4(%eax)
  801491:	e8 43 fb ff ff       	call   800fd9 <file_flush>
	return 0;
  801496:	83 c4 10             	add    $0x10,%esp
  801499:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80149e:	c9                   	leave  
  80149f:	c3                   	ret    

008014a0 <serve_open>:
{
  8014a0:	55                   	push   %ebp
  8014a1:	89 e5                	mov    %esp,%ebp
  8014a3:	53                   	push   %ebx
  8014a4:	81 ec 18 04 00 00    	sub    $0x418,%esp
  8014aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	memmove(path, req->req_path, MAXPATHLEN);
  8014ad:	68 00 04 00 00       	push   $0x400
  8014b2:	53                   	push   %ebx
  8014b3:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8014b9:	50                   	push   %eax
  8014ba:	e8 2d 0f 00 00       	call   8023ec <memmove>
	path[MAXPATHLEN-1] = 0;
  8014bf:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)
	if ((r = openfile_alloc(&o)) < 0) {
  8014c3:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  8014c9:	89 04 24             	mov    %eax,(%esp)
  8014cc:	e8 65 fd ff ff       	call   801236 <openfile_alloc>
  8014d1:	83 c4 10             	add    $0x10,%esp
  8014d4:	85 c0                	test   %eax,%eax
  8014d6:	0f 88 f0 00 00 00    	js     8015cc <serve_open+0x12c>
	if (req->req_omode & O_CREAT) {
  8014dc:	f6 83 01 04 00 00 01 	testb  $0x1,0x401(%ebx)
  8014e3:	74 33                	je     801518 <serve_open+0x78>
		if ((r = file_create(path, &f)) < 0) {
  8014e5:	83 ec 08             	sub    $0x8,%esp
  8014e8:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  8014ee:	50                   	push   %eax
  8014ef:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8014f5:	50                   	push   %eax
  8014f6:	e8 7f fb ff ff       	call   80107a <file_create>
  8014fb:	83 c4 10             	add    $0x10,%esp
  8014fe:	85 c0                	test   %eax,%eax
  801500:	79 37                	jns    801539 <serve_open+0x99>
			if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
  801502:	f6 83 01 04 00 00 04 	testb  $0x4,0x401(%ebx)
  801509:	0f 85 bd 00 00 00    	jne    8015cc <serve_open+0x12c>
  80150f:	83 f8 f3             	cmp    $0xfffffff3,%eax
  801512:	0f 85 b4 00 00 00    	jne    8015cc <serve_open+0x12c>
		if ((r = file_open(path, &f)) < 0) {
  801518:	83 ec 08             	sub    $0x8,%esp
  80151b:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801521:	50                   	push   %eax
  801522:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801528:	50                   	push   %eax
  801529:	e8 5f f8 ff ff       	call   800d8d <file_open>
  80152e:	83 c4 10             	add    $0x10,%esp
  801531:	85 c0                	test   %eax,%eax
  801533:	0f 88 93 00 00 00    	js     8015cc <serve_open+0x12c>
	if (req->req_omode & O_TRUNC) {
  801539:	f6 83 01 04 00 00 02 	testb  $0x2,0x401(%ebx)
  801540:	74 17                	je     801559 <serve_open+0xb9>
		if ((r = file_set_size(f, 0)) < 0) {
  801542:	83 ec 08             	sub    $0x8,%esp
  801545:	6a 00                	push   $0x0
  801547:	ff b5 f4 fb ff ff    	pushl  -0x40c(%ebp)
  80154d:	e8 02 f9 ff ff       	call   800e54 <file_set_size>
  801552:	83 c4 10             	add    $0x10,%esp
  801555:	85 c0                	test   %eax,%eax
  801557:	78 73                	js     8015cc <serve_open+0x12c>
	if ((r = file_open(path, &f)) < 0) {
  801559:	83 ec 08             	sub    $0x8,%esp
  80155c:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801562:	50                   	push   %eax
  801563:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801569:	50                   	push   %eax
  80156a:	e8 1e f8 ff ff       	call   800d8d <file_open>
  80156f:	83 c4 10             	add    $0x10,%esp
  801572:	85 c0                	test   %eax,%eax
  801574:	78 56                	js     8015cc <serve_open+0x12c>
	o->o_file = f;
  801576:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  80157c:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  801582:	89 50 04             	mov    %edx,0x4(%eax)
	o->o_fd->fd_file.id = o->o_fileid;
  801585:	8b 50 0c             	mov    0xc(%eax),%edx
  801588:	8b 08                	mov    (%eax),%ecx
  80158a:	89 4a 0c             	mov    %ecx,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  80158d:	8b 48 0c             	mov    0xc(%eax),%ecx
  801590:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  801596:	83 e2 03             	and    $0x3,%edx
  801599:	89 51 08             	mov    %edx,0x8(%ecx)
	o->o_fd->fd_dev_id = devfile.dev_id;
  80159c:	8b 40 0c             	mov    0xc(%eax),%eax
  80159f:	8b 15 64 90 80 00    	mov    0x809064,%edx
  8015a5:	89 10                	mov    %edx,(%eax)
	o->o_mode = req->req_omode;
  8015a7:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  8015ad:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  8015b3:	89 50 08             	mov    %edx,0x8(%eax)
	*pg_store = o->o_fd;
  8015b6:	8b 50 0c             	mov    0xc(%eax),%edx
  8015b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8015bc:	89 10                	mov    %edx,(%eax)
	*perm_store = PTE_P|PTE_U|PTE_W|PTE_SHARE;
  8015be:	8b 45 14             	mov    0x14(%ebp),%eax
  8015c1:	c7 00 07 04 00 00    	movl   $0x407,(%eax)
	return 0;
  8015c7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015cf:	c9                   	leave  
  8015d0:	c3                   	ret    

008015d1 <serve>:
	[FSREQ_SYNC] =		serve_sync
};

void
serve(void)
{
  8015d1:	55                   	push   %ebp
  8015d2:	89 e5                	mov    %esp,%ebp
  8015d4:	56                   	push   %esi
  8015d5:	53                   	push   %ebx
  8015d6:	83 ec 10             	sub    $0x10,%esp
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  8015d9:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  8015dc:	8d 75 f4             	lea    -0xc(%ebp),%esi
  8015df:	eb 68                	jmp    801649 <serve+0x78>
			cprintf("fs req %d from %08x [page %08x: %s]\n",
				req, whom, uvpt[PGNUM(fsreq)], fsreq);

		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
			cprintf("Invalid request from %08x: no argument page\n",
  8015e1:	83 ec 08             	sub    $0x8,%esp
  8015e4:	ff 75 f4             	pushl  -0xc(%ebp)
  8015e7:	68 30 3c 80 00       	push   $0x803c30
  8015ec:	e8 4e 06 00 00       	call   801c3f <cprintf>
				whom);
			continue; // just leave it hanging...
  8015f1:	83 c4 10             	add    $0x10,%esp
  8015f4:	eb 53                	jmp    801649 <serve+0x78>
		}

		pg = NULL;
		if (req == FSREQ_OPEN) {
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  8015f6:	53                   	push   %ebx
  8015f7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8015fa:	50                   	push   %eax
  8015fb:	ff 35 44 50 80 00    	pushl  0x805044
  801601:	ff 75 f4             	pushl  -0xc(%ebp)
  801604:	e8 97 fe ff ff       	call   8014a0 <serve_open>
  801609:	83 c4 10             	add    $0x10,%esp
  80160c:	eb 19                	jmp    801627 <serve+0x56>
		} else if (req < ARRAY_SIZE(handlers) && handlers[req]) {
			r = handlers[req](whom, fsreq);
		} else {
			cprintf("Invalid request code %d from %08x\n", req, whom);
  80160e:	83 ec 04             	sub    $0x4,%esp
  801611:	ff 75 f4             	pushl  -0xc(%ebp)
  801614:	50                   	push   %eax
  801615:	68 60 3c 80 00       	push   $0x803c60
  80161a:	e8 20 06 00 00       	call   801c3f <cprintf>
  80161f:	83 c4 10             	add    $0x10,%esp
			r = -E_INVAL;
  801622:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		ipc_send(whom, r, pg, perm);
  801627:	ff 75 f0             	pushl  -0x10(%ebp)
  80162a:	ff 75 ec             	pushl  -0x14(%ebp)
  80162d:	50                   	push   %eax
  80162e:	ff 75 f4             	pushl  -0xc(%ebp)
  801631:	e8 13 13 00 00       	call   802949 <ipc_send>
		sys_page_unmap(0, fsreq);
  801636:	83 c4 08             	add    $0x8,%esp
  801639:	ff 35 44 50 80 00    	pushl  0x805044
  80163f:	6a 00                	push   $0x0
  801641:	e8 96 10 00 00       	call   8026dc <sys_page_unmap>
  801646:	83 c4 10             	add    $0x10,%esp
		perm = 0;
  801649:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  801650:	83 ec 04             	sub    $0x4,%esp
  801653:	53                   	push   %ebx
  801654:	ff 35 44 50 80 00    	pushl  0x805044
  80165a:	56                   	push   %esi
  80165b:	e8 74 12 00 00       	call   8028d4 <ipc_recv>
		if (!(perm & PTE_P)) {
  801660:	83 c4 10             	add    $0x10,%esp
  801663:	f6 45 f0 01          	testb  $0x1,-0x10(%ebp)
  801667:	0f 84 74 ff ff ff    	je     8015e1 <serve+0x10>
		pg = NULL;
  80166d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		if (req == FSREQ_OPEN) {
  801674:	83 f8 01             	cmp    $0x1,%eax
  801677:	0f 84 79 ff ff ff    	je     8015f6 <serve+0x25>
		} else if (req < ARRAY_SIZE(handlers) && handlers[req]) {
  80167d:	83 f8 08             	cmp    $0x8,%eax
  801680:	77 8c                	ja     80160e <serve+0x3d>
  801682:	8b 14 85 20 50 80 00 	mov    0x805020(,%eax,4),%edx
  801689:	85 d2                	test   %edx,%edx
  80168b:	74 81                	je     80160e <serve+0x3d>
			r = handlers[req](whom, fsreq);
  80168d:	83 ec 08             	sub    $0x8,%esp
  801690:	ff 35 44 50 80 00    	pushl  0x805044
  801696:	ff 75 f4             	pushl  -0xc(%ebp)
  801699:	ff d2                	call   *%edx
  80169b:	83 c4 10             	add    $0x10,%esp
  80169e:	eb 87                	jmp    801627 <serve+0x56>

008016a0 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8016a0:	55                   	push   %ebp
  8016a1:	89 e5                	mov    %esp,%ebp
  8016a3:	83 ec 14             	sub    $0x14,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  8016a6:	c7 05 60 90 80 00 83 	movl   $0x803c83,0x809060
  8016ad:	3c 80 00 
	cprintf("FS is running\n");
  8016b0:	68 86 3c 80 00       	push   $0x803c86
  8016b5:	e8 85 05 00 00       	call   801c3f <cprintf>
	asm volatile("outw %0,%w1" : : "a" (data), "d" (port));
  8016ba:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  8016bf:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  8016c4:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  8016c6:	c7 04 24 95 3c 80 00 	movl   $0x803c95,(%esp)
  8016cd:	e8 6d 05 00 00       	call   801c3f <cprintf>

	serve_init();
  8016d2:	e8 33 fb ff ff       	call   80120a <serve_init>
	fs_init();
  8016d7:	e8 95 f3 ff ff       	call   800a71 <fs_init>
        fs_test();
  8016dc:	e8 05 00 00 00       	call   8016e6 <fs_test>
	serve();
  8016e1:	e8 eb fe ff ff       	call   8015d1 <serve>

008016e6 <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  8016e6:	55                   	push   %ebp
  8016e7:	89 e5                	mov    %esp,%ebp
  8016e9:	53                   	push   %ebx
  8016ea:	83 ec 18             	sub    $0x18,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  8016ed:	6a 07                	push   $0x7
  8016ef:	68 00 10 00 00       	push   $0x1000
  8016f4:	6a 00                	push   $0x0
  8016f6:	e8 5c 0f 00 00       	call   802657 <sys_page_alloc>
  8016fb:	83 c4 10             	add    $0x10,%esp
  8016fe:	85 c0                	test   %eax,%eax
  801700:	0f 88 6a 02 00 00    	js     801970 <fs_test+0x28a>
		panic("sys_page_alloc: %e", r);
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  801706:	83 ec 04             	sub    $0x4,%esp
  801709:	68 00 10 00 00       	push   $0x1000
  80170e:	ff 35 04 a0 80 00    	pushl  0x80a004
  801714:	68 00 10 00 00       	push   $0x1000
  801719:	e8 ce 0c 00 00       	call   8023ec <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  80171e:	e8 7d f1 ff ff       	call   8008a0 <alloc_block>
  801723:	83 c4 10             	add    $0x10,%esp
  801726:	85 c0                	test   %eax,%eax
  801728:	0f 88 54 02 00 00    	js     801982 <fs_test+0x29c>
		panic("alloc_block: %e", r);
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  80172e:	8d 50 1f             	lea    0x1f(%eax),%edx
  801731:	85 c0                	test   %eax,%eax
  801733:	0f 49 d0             	cmovns %eax,%edx
  801736:	c1 fa 05             	sar    $0x5,%edx
  801739:	89 c3                	mov    %eax,%ebx
  80173b:	c1 fb 1f             	sar    $0x1f,%ebx
  80173e:	c1 eb 1b             	shr    $0x1b,%ebx
  801741:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
  801744:	83 e1 1f             	and    $0x1f,%ecx
  801747:	29 d9                	sub    %ebx,%ecx
  801749:	b8 01 00 00 00       	mov    $0x1,%eax
  80174e:	d3 e0                	shl    %cl,%eax
  801750:	85 04 95 00 10 00 00 	test   %eax,0x1000(,%edx,4)
  801757:	0f 84 37 02 00 00    	je     801994 <fs_test+0x2ae>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  80175d:	8b 0d 04 a0 80 00    	mov    0x80a004,%ecx
  801763:	85 04 91             	test   %eax,(%ecx,%edx,4)
  801766:	0f 85 3e 02 00 00    	jne    8019aa <fs_test+0x2c4>
	cprintf("alloc_block is good\n");
  80176c:	83 ec 0c             	sub    $0xc,%esp
  80176f:	68 ec 3c 80 00       	push   $0x803cec
  801774:	e8 c6 04 00 00       	call   801c3f <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  801779:	83 c4 08             	add    $0x8,%esp
  80177c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80177f:	50                   	push   %eax
  801780:	68 01 3d 80 00       	push   $0x803d01
  801785:	e8 03 f6 ff ff       	call   800d8d <file_open>
  80178a:	83 c4 10             	add    $0x10,%esp
  80178d:	83 f8 f5             	cmp    $0xfffffff5,%eax
  801790:	74 08                	je     80179a <fs_test+0xb4>
  801792:	85 c0                	test   %eax,%eax
  801794:	0f 88 26 02 00 00    	js     8019c0 <fs_test+0x2da>
		panic("file_open /not-found: %e", r);
	else if (r == 0)
  80179a:	85 c0                	test   %eax,%eax
  80179c:	0f 84 30 02 00 00    	je     8019d2 <fs_test+0x2ec>
		panic("file_open /not-found succeeded!");
	if ((r = file_open("/newmotd", &f)) < 0)
  8017a2:	83 ec 08             	sub    $0x8,%esp
  8017a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017a8:	50                   	push   %eax
  8017a9:	68 25 3d 80 00       	push   $0x803d25
  8017ae:	e8 da f5 ff ff       	call   800d8d <file_open>
  8017b3:	83 c4 10             	add    $0x10,%esp
  8017b6:	85 c0                	test   %eax,%eax
  8017b8:	0f 88 28 02 00 00    	js     8019e6 <fs_test+0x300>
		panic("file_open /newmotd: %e", r);
	cprintf("file_open is good\n");
  8017be:	83 ec 0c             	sub    $0xc,%esp
  8017c1:	68 45 3d 80 00       	push   $0x803d45
  8017c6:	e8 74 04 00 00       	call   801c3f <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  8017cb:	83 c4 0c             	add    $0xc,%esp
  8017ce:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017d1:	50                   	push   %eax
  8017d2:	6a 00                	push   $0x0
  8017d4:	ff 75 f4             	pushl  -0xc(%ebp)
  8017d7:	e8 f4 f2 ff ff       	call   800ad0 <file_get_block>
  8017dc:	83 c4 10             	add    $0x10,%esp
  8017df:	85 c0                	test   %eax,%eax
  8017e1:	0f 88 11 02 00 00    	js     8019f8 <fs_test+0x312>
		panic("file_get_block: %e", r);
	if (strcmp(blk, msg) != 0)
  8017e7:	83 ec 08             	sub    $0x8,%esp
  8017ea:	68 8c 3e 80 00       	push   $0x803e8c
  8017ef:	ff 75 f0             	pushl  -0x10(%ebp)
  8017f2:	e8 0d 0b 00 00       	call   802304 <strcmp>
  8017f7:	83 c4 10             	add    $0x10,%esp
  8017fa:	85 c0                	test   %eax,%eax
  8017fc:	0f 85 08 02 00 00    	jne    801a0a <fs_test+0x324>
		panic("file_get_block returned wrong data");
	cprintf("file_get_block is good\n");
  801802:	83 ec 0c             	sub    $0xc,%esp
  801805:	68 6b 3d 80 00       	push   $0x803d6b
  80180a:	e8 30 04 00 00       	call   801c3f <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  80180f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801812:	0f b6 10             	movzbl (%eax),%edx
  801815:	88 10                	mov    %dl,(%eax)
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801817:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80181a:	c1 e8 0c             	shr    $0xc,%eax
  80181d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801824:	83 c4 10             	add    $0x10,%esp
  801827:	a8 40                	test   $0x40,%al
  801829:	0f 84 ef 01 00 00    	je     801a1e <fs_test+0x338>
	file_flush(f);
  80182f:	83 ec 0c             	sub    $0xc,%esp
  801832:	ff 75 f4             	pushl  -0xc(%ebp)
  801835:	e8 9f f7 ff ff       	call   800fd9 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  80183a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80183d:	c1 e8 0c             	shr    $0xc,%eax
  801840:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801847:	83 c4 10             	add    $0x10,%esp
  80184a:	a8 40                	test   $0x40,%al
  80184c:	0f 85 e2 01 00 00    	jne    801a34 <fs_test+0x34e>
	cprintf("file_flush is good\n");
  801852:	83 ec 0c             	sub    $0xc,%esp
  801855:	68 9f 3d 80 00       	push   $0x803d9f
  80185a:	e8 e0 03 00 00       	call   801c3f <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  80185f:	83 c4 08             	add    $0x8,%esp
  801862:	6a 00                	push   $0x0
  801864:	ff 75 f4             	pushl  -0xc(%ebp)
  801867:	e8 e8 f5 ff ff       	call   800e54 <file_set_size>
  80186c:	83 c4 10             	add    $0x10,%esp
  80186f:	85 c0                	test   %eax,%eax
  801871:	0f 88 d3 01 00 00    	js     801a4a <fs_test+0x364>
		panic("file_set_size: %e", r);
	assert(f->f_direct[0] == 0);
  801877:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80187a:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  801881:	0f 85 d5 01 00 00    	jne    801a5c <fs_test+0x376>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801887:	c1 e8 0c             	shr    $0xc,%eax
  80188a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801891:	a8 40                	test   $0x40,%al
  801893:	0f 85 d9 01 00 00    	jne    801a72 <fs_test+0x38c>
	cprintf("file_truncate is good\n");
  801899:	83 ec 0c             	sub    $0xc,%esp
  80189c:	68 f3 3d 80 00       	push   $0x803df3
  8018a1:	e8 99 03 00 00       	call   801c3f <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  8018a6:	c7 04 24 8c 3e 80 00 	movl   $0x803e8c,(%esp)
  8018ad:	e8 75 09 00 00       	call   802227 <strlen>
  8018b2:	83 c4 08             	add    $0x8,%esp
  8018b5:	50                   	push   %eax
  8018b6:	ff 75 f4             	pushl  -0xc(%ebp)
  8018b9:	e8 96 f5 ff ff       	call   800e54 <file_set_size>
  8018be:	83 c4 10             	add    $0x10,%esp
  8018c1:	85 c0                	test   %eax,%eax
  8018c3:	0f 88 bf 01 00 00    	js     801a88 <fs_test+0x3a2>
		panic("file_set_size 2: %e", r);
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8018c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018cc:	89 c2                	mov    %eax,%edx
  8018ce:	c1 ea 0c             	shr    $0xc,%edx
  8018d1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8018d8:	f6 c2 40             	test   $0x40,%dl
  8018db:	0f 85 b9 01 00 00    	jne    801a9a <fs_test+0x3b4>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  8018e1:	83 ec 04             	sub    $0x4,%esp
  8018e4:	8d 55 f0             	lea    -0x10(%ebp),%edx
  8018e7:	52                   	push   %edx
  8018e8:	6a 00                	push   $0x0
  8018ea:	50                   	push   %eax
  8018eb:	e8 e0 f1 ff ff       	call   800ad0 <file_get_block>
  8018f0:	83 c4 10             	add    $0x10,%esp
  8018f3:	85 c0                	test   %eax,%eax
  8018f5:	0f 88 b5 01 00 00    	js     801ab0 <fs_test+0x3ca>
		panic("file_get_block 2: %e", r);
	strcpy(blk, msg);
  8018fb:	83 ec 08             	sub    $0x8,%esp
  8018fe:	68 8c 3e 80 00       	push   $0x803e8c
  801903:	ff 75 f0             	pushl  -0x10(%ebp)
  801906:	e8 53 09 00 00       	call   80225e <strcpy>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  80190b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80190e:	c1 e8 0c             	shr    $0xc,%eax
  801911:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801918:	83 c4 10             	add    $0x10,%esp
  80191b:	a8 40                	test   $0x40,%al
  80191d:	0f 84 9f 01 00 00    	je     801ac2 <fs_test+0x3dc>
	file_flush(f);
  801923:	83 ec 0c             	sub    $0xc,%esp
  801926:	ff 75 f4             	pushl  -0xc(%ebp)
  801929:	e8 ab f6 ff ff       	call   800fd9 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  80192e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801931:	c1 e8 0c             	shr    $0xc,%eax
  801934:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80193b:	83 c4 10             	add    $0x10,%esp
  80193e:	a8 40                	test   $0x40,%al
  801940:	0f 85 92 01 00 00    	jne    801ad8 <fs_test+0x3f2>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801946:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801949:	c1 e8 0c             	shr    $0xc,%eax
  80194c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801953:	a8 40                	test   $0x40,%al
  801955:	0f 85 93 01 00 00    	jne    801aee <fs_test+0x408>
	cprintf("file rewrite is good\n");
  80195b:	83 ec 0c             	sub    $0xc,%esp
  80195e:	68 33 3e 80 00       	push   $0x803e33
  801963:	e8 d7 02 00 00       	call   801c3f <cprintf>
}
  801968:	83 c4 10             	add    $0x10,%esp
  80196b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80196e:	c9                   	leave  
  80196f:	c3                   	ret    
		panic("sys_page_alloc: %e", r);
  801970:	50                   	push   %eax
  801971:	68 a4 3c 80 00       	push   $0x803ca4
  801976:	6a 12                	push   $0x12
  801978:	68 b7 3c 80 00       	push   $0x803cb7
  80197d:	e8 e2 01 00 00       	call   801b64 <_panic>
		panic("alloc_block: %e", r);
  801982:	50                   	push   %eax
  801983:	68 c1 3c 80 00       	push   $0x803cc1
  801988:	6a 17                	push   $0x17
  80198a:	68 b7 3c 80 00       	push   $0x803cb7
  80198f:	e8 d0 01 00 00       	call   801b64 <_panic>
	assert(bits[r/32] & (1 << (r%32)));
  801994:	68 d1 3c 80 00       	push   $0x803cd1
  801999:	68 5d 39 80 00       	push   $0x80395d
  80199e:	6a 19                	push   $0x19
  8019a0:	68 b7 3c 80 00       	push   $0x803cb7
  8019a5:	e8 ba 01 00 00       	call   801b64 <_panic>
	assert(!(bitmap[r/32] & (1 << (r%32))));
  8019aa:	68 4c 3e 80 00       	push   $0x803e4c
  8019af:	68 5d 39 80 00       	push   $0x80395d
  8019b4:	6a 1b                	push   $0x1b
  8019b6:	68 b7 3c 80 00       	push   $0x803cb7
  8019bb:	e8 a4 01 00 00       	call   801b64 <_panic>
		panic("file_open /not-found: %e", r);
  8019c0:	50                   	push   %eax
  8019c1:	68 0c 3d 80 00       	push   $0x803d0c
  8019c6:	6a 1f                	push   $0x1f
  8019c8:	68 b7 3c 80 00       	push   $0x803cb7
  8019cd:	e8 92 01 00 00       	call   801b64 <_panic>
		panic("file_open /not-found succeeded!");
  8019d2:	83 ec 04             	sub    $0x4,%esp
  8019d5:	68 6c 3e 80 00       	push   $0x803e6c
  8019da:	6a 21                	push   $0x21
  8019dc:	68 b7 3c 80 00       	push   $0x803cb7
  8019e1:	e8 7e 01 00 00       	call   801b64 <_panic>
		panic("file_open /newmotd: %e", r);
  8019e6:	50                   	push   %eax
  8019e7:	68 2e 3d 80 00       	push   $0x803d2e
  8019ec:	6a 23                	push   $0x23
  8019ee:	68 b7 3c 80 00       	push   $0x803cb7
  8019f3:	e8 6c 01 00 00       	call   801b64 <_panic>
		panic("file_get_block: %e", r);
  8019f8:	50                   	push   %eax
  8019f9:	68 58 3d 80 00       	push   $0x803d58
  8019fe:	6a 27                	push   $0x27
  801a00:	68 b7 3c 80 00       	push   $0x803cb7
  801a05:	e8 5a 01 00 00       	call   801b64 <_panic>
		panic("file_get_block returned wrong data");
  801a0a:	83 ec 04             	sub    $0x4,%esp
  801a0d:	68 b4 3e 80 00       	push   $0x803eb4
  801a12:	6a 29                	push   $0x29
  801a14:	68 b7 3c 80 00       	push   $0x803cb7
  801a19:	e8 46 01 00 00       	call   801b64 <_panic>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801a1e:	68 84 3d 80 00       	push   $0x803d84
  801a23:	68 5d 39 80 00       	push   $0x80395d
  801a28:	6a 2d                	push   $0x2d
  801a2a:	68 b7 3c 80 00       	push   $0x803cb7
  801a2f:	e8 30 01 00 00       	call   801b64 <_panic>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801a34:	68 83 3d 80 00       	push   $0x803d83
  801a39:	68 5d 39 80 00       	push   $0x80395d
  801a3e:	6a 2f                	push   $0x2f
  801a40:	68 b7 3c 80 00       	push   $0x803cb7
  801a45:	e8 1a 01 00 00       	call   801b64 <_panic>
		panic("file_set_size: %e", r);
  801a4a:	50                   	push   %eax
  801a4b:	68 b3 3d 80 00       	push   $0x803db3
  801a50:	6a 33                	push   $0x33
  801a52:	68 b7 3c 80 00       	push   $0x803cb7
  801a57:	e8 08 01 00 00       	call   801b64 <_panic>
	assert(f->f_direct[0] == 0);
  801a5c:	68 c5 3d 80 00       	push   $0x803dc5
  801a61:	68 5d 39 80 00       	push   $0x80395d
  801a66:	6a 34                	push   $0x34
  801a68:	68 b7 3c 80 00       	push   $0x803cb7
  801a6d:	e8 f2 00 00 00       	call   801b64 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801a72:	68 d9 3d 80 00       	push   $0x803dd9
  801a77:	68 5d 39 80 00       	push   $0x80395d
  801a7c:	6a 35                	push   $0x35
  801a7e:	68 b7 3c 80 00       	push   $0x803cb7
  801a83:	e8 dc 00 00 00       	call   801b64 <_panic>
		panic("file_set_size 2: %e", r);
  801a88:	50                   	push   %eax
  801a89:	68 0a 3e 80 00       	push   $0x803e0a
  801a8e:	6a 39                	push   $0x39
  801a90:	68 b7 3c 80 00       	push   $0x803cb7
  801a95:	e8 ca 00 00 00       	call   801b64 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801a9a:	68 d9 3d 80 00       	push   $0x803dd9
  801a9f:	68 5d 39 80 00       	push   $0x80395d
  801aa4:	6a 3a                	push   $0x3a
  801aa6:	68 b7 3c 80 00       	push   $0x803cb7
  801aab:	e8 b4 00 00 00       	call   801b64 <_panic>
		panic("file_get_block 2: %e", r);
  801ab0:	50                   	push   %eax
  801ab1:	68 1e 3e 80 00       	push   $0x803e1e
  801ab6:	6a 3c                	push   $0x3c
  801ab8:	68 b7 3c 80 00       	push   $0x803cb7
  801abd:	e8 a2 00 00 00       	call   801b64 <_panic>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801ac2:	68 84 3d 80 00       	push   $0x803d84
  801ac7:	68 5d 39 80 00       	push   $0x80395d
  801acc:	6a 3e                	push   $0x3e
  801ace:	68 b7 3c 80 00       	push   $0x803cb7
  801ad3:	e8 8c 00 00 00       	call   801b64 <_panic>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801ad8:	68 83 3d 80 00       	push   $0x803d83
  801add:	68 5d 39 80 00       	push   $0x80395d
  801ae2:	6a 40                	push   $0x40
  801ae4:	68 b7 3c 80 00       	push   $0x803cb7
  801ae9:	e8 76 00 00 00       	call   801b64 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801aee:	68 d9 3d 80 00       	push   $0x803dd9
  801af3:	68 5d 39 80 00       	push   $0x80395d
  801af8:	6a 41                	push   $0x41
  801afa:	68 b7 3c 80 00       	push   $0x803cb7
  801aff:	e8 60 00 00 00       	call   801b64 <_panic>

00801b04 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  801b04:	55                   	push   %ebp
  801b05:	89 e5                	mov    %esp,%ebp
  801b07:	56                   	push   %esi
  801b08:	53                   	push   %ebx
  801b09:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801b0c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  801b0f:	e8 05 0b 00 00       	call   802619 <sys_getenvid>
  801b14:	25 ff 03 00 00       	and    $0x3ff,%eax
  801b19:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b1c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b21:	a3 0c a0 80 00       	mov    %eax,0x80a00c
	// save the name of the program so that panic() can use it
	if (argc > 0)
  801b26:	85 db                	test   %ebx,%ebx
  801b28:	7e 07                	jle    801b31 <libmain+0x2d>
		binaryname = argv[0];
  801b2a:	8b 06                	mov    (%esi),%eax
  801b2c:	a3 60 90 80 00       	mov    %eax,0x809060

	// call user main routine
	umain(argc, argv);
  801b31:	83 ec 08             	sub    $0x8,%esp
  801b34:	56                   	push   %esi
  801b35:	53                   	push   %ebx
  801b36:	e8 65 fb ff ff       	call   8016a0 <umain>

	// exit gracefully
	exit();
  801b3b:	e8 0a 00 00 00       	call   801b4a <exit>
}
  801b40:	83 c4 10             	add    $0x10,%esp
  801b43:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b46:	5b                   	pop    %ebx
  801b47:	5e                   	pop    %esi
  801b48:	5d                   	pop    %ebp
  801b49:	c3                   	ret    

00801b4a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  801b4a:	55                   	push   %ebp
  801b4b:	89 e5                	mov    %esp,%ebp
  801b4d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  801b50:	e8 59 10 00 00       	call   802bae <close_all>
	sys_env_destroy(0);
  801b55:	83 ec 0c             	sub    $0xc,%esp
  801b58:	6a 00                	push   $0x0
  801b5a:	e8 79 0a 00 00       	call   8025d8 <sys_env_destroy>
}
  801b5f:	83 c4 10             	add    $0x10,%esp
  801b62:	c9                   	leave  
  801b63:	c3                   	ret    

00801b64 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801b64:	55                   	push   %ebp
  801b65:	89 e5                	mov    %esp,%ebp
  801b67:	56                   	push   %esi
  801b68:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801b69:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801b6c:	8b 35 60 90 80 00    	mov    0x809060,%esi
  801b72:	e8 a2 0a 00 00       	call   802619 <sys_getenvid>
  801b77:	83 ec 0c             	sub    $0xc,%esp
  801b7a:	ff 75 0c             	pushl  0xc(%ebp)
  801b7d:	ff 75 08             	pushl  0x8(%ebp)
  801b80:	56                   	push   %esi
  801b81:	50                   	push   %eax
  801b82:	68 e4 3e 80 00       	push   $0x803ee4
  801b87:	e8 b3 00 00 00       	call   801c3f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b8c:	83 c4 18             	add    $0x18,%esp
  801b8f:	53                   	push   %ebx
  801b90:	ff 75 10             	pushl  0x10(%ebp)
  801b93:	e8 56 00 00 00       	call   801bee <vcprintf>
	cprintf("\n");
  801b98:	c7 04 24 f3 3a 80 00 	movl   $0x803af3,(%esp)
  801b9f:	e8 9b 00 00 00       	call   801c3f <cprintf>
  801ba4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ba7:	cc                   	int3   
  801ba8:	eb fd                	jmp    801ba7 <_panic+0x43>

00801baa <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801baa:	55                   	push   %ebp
  801bab:	89 e5                	mov    %esp,%ebp
  801bad:	53                   	push   %ebx
  801bae:	83 ec 04             	sub    $0x4,%esp
  801bb1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801bb4:	8b 13                	mov    (%ebx),%edx
  801bb6:	8d 42 01             	lea    0x1(%edx),%eax
  801bb9:	89 03                	mov    %eax,(%ebx)
  801bbb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bbe:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801bc2:	3d ff 00 00 00       	cmp    $0xff,%eax
  801bc7:	74 09                	je     801bd2 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801bc9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801bcd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bd0:	c9                   	leave  
  801bd1:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801bd2:	83 ec 08             	sub    $0x8,%esp
  801bd5:	68 ff 00 00 00       	push   $0xff
  801bda:	8d 43 08             	lea    0x8(%ebx),%eax
  801bdd:	50                   	push   %eax
  801bde:	e8 b8 09 00 00       	call   80259b <sys_cputs>
		b->idx = 0;
  801be3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801be9:	83 c4 10             	add    $0x10,%esp
  801bec:	eb db                	jmp    801bc9 <putch+0x1f>

00801bee <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801bee:	55                   	push   %ebp
  801bef:	89 e5                	mov    %esp,%ebp
  801bf1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801bf7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801bfe:	00 00 00 
	b.cnt = 0;
  801c01:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801c08:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801c0b:	ff 75 0c             	pushl  0xc(%ebp)
  801c0e:	ff 75 08             	pushl  0x8(%ebp)
  801c11:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801c17:	50                   	push   %eax
  801c18:	68 aa 1b 80 00       	push   $0x801baa
  801c1d:	e8 1a 01 00 00       	call   801d3c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801c22:	83 c4 08             	add    $0x8,%esp
  801c25:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801c2b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801c31:	50                   	push   %eax
  801c32:	e8 64 09 00 00       	call   80259b <sys_cputs>

	return b.cnt;
}
  801c37:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801c3d:	c9                   	leave  
  801c3e:	c3                   	ret    

00801c3f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801c3f:	55                   	push   %ebp
  801c40:	89 e5                	mov    %esp,%ebp
  801c42:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801c45:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801c48:	50                   	push   %eax
  801c49:	ff 75 08             	pushl  0x8(%ebp)
  801c4c:	e8 9d ff ff ff       	call   801bee <vcprintf>
	va_end(ap);

	return cnt;
}
  801c51:	c9                   	leave  
  801c52:	c3                   	ret    

00801c53 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801c53:	55                   	push   %ebp
  801c54:	89 e5                	mov    %esp,%ebp
  801c56:	57                   	push   %edi
  801c57:	56                   	push   %esi
  801c58:	53                   	push   %ebx
  801c59:	83 ec 1c             	sub    $0x1c,%esp
  801c5c:	89 c7                	mov    %eax,%edi
  801c5e:	89 d6                	mov    %edx,%esi
  801c60:	8b 45 08             	mov    0x8(%ebp),%eax
  801c63:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c66:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801c69:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801c6c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801c6f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c74:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801c77:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801c7a:	39 d3                	cmp    %edx,%ebx
  801c7c:	72 05                	jb     801c83 <printnum+0x30>
  801c7e:	39 45 10             	cmp    %eax,0x10(%ebp)
  801c81:	77 7a                	ja     801cfd <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801c83:	83 ec 0c             	sub    $0xc,%esp
  801c86:	ff 75 18             	pushl  0x18(%ebp)
  801c89:	8b 45 14             	mov    0x14(%ebp),%eax
  801c8c:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801c8f:	53                   	push   %ebx
  801c90:	ff 75 10             	pushl  0x10(%ebp)
  801c93:	83 ec 08             	sub    $0x8,%esp
  801c96:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c99:	ff 75 e0             	pushl  -0x20(%ebp)
  801c9c:	ff 75 dc             	pushl  -0x24(%ebp)
  801c9f:	ff 75 d8             	pushl  -0x28(%ebp)
  801ca2:	e8 29 1a 00 00       	call   8036d0 <__udivdi3>
  801ca7:	83 c4 18             	add    $0x18,%esp
  801caa:	52                   	push   %edx
  801cab:	50                   	push   %eax
  801cac:	89 f2                	mov    %esi,%edx
  801cae:	89 f8                	mov    %edi,%eax
  801cb0:	e8 9e ff ff ff       	call   801c53 <printnum>
  801cb5:	83 c4 20             	add    $0x20,%esp
  801cb8:	eb 13                	jmp    801ccd <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801cba:	83 ec 08             	sub    $0x8,%esp
  801cbd:	56                   	push   %esi
  801cbe:	ff 75 18             	pushl  0x18(%ebp)
  801cc1:	ff d7                	call   *%edi
  801cc3:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801cc6:	83 eb 01             	sub    $0x1,%ebx
  801cc9:	85 db                	test   %ebx,%ebx
  801ccb:	7f ed                	jg     801cba <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801ccd:	83 ec 08             	sub    $0x8,%esp
  801cd0:	56                   	push   %esi
  801cd1:	83 ec 04             	sub    $0x4,%esp
  801cd4:	ff 75 e4             	pushl  -0x1c(%ebp)
  801cd7:	ff 75 e0             	pushl  -0x20(%ebp)
  801cda:	ff 75 dc             	pushl  -0x24(%ebp)
  801cdd:	ff 75 d8             	pushl  -0x28(%ebp)
  801ce0:	e8 0b 1b 00 00       	call   8037f0 <__umoddi3>
  801ce5:	83 c4 14             	add    $0x14,%esp
  801ce8:	0f be 80 07 3f 80 00 	movsbl 0x803f07(%eax),%eax
  801cef:	50                   	push   %eax
  801cf0:	ff d7                	call   *%edi
}
  801cf2:	83 c4 10             	add    $0x10,%esp
  801cf5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cf8:	5b                   	pop    %ebx
  801cf9:	5e                   	pop    %esi
  801cfa:	5f                   	pop    %edi
  801cfb:	5d                   	pop    %ebp
  801cfc:	c3                   	ret    
  801cfd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801d00:	eb c4                	jmp    801cc6 <printnum+0x73>

00801d02 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801d02:	55                   	push   %ebp
  801d03:	89 e5                	mov    %esp,%ebp
  801d05:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801d08:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801d0c:	8b 10                	mov    (%eax),%edx
  801d0e:	3b 50 04             	cmp    0x4(%eax),%edx
  801d11:	73 0a                	jae    801d1d <sprintputch+0x1b>
		*b->buf++ = ch;
  801d13:	8d 4a 01             	lea    0x1(%edx),%ecx
  801d16:	89 08                	mov    %ecx,(%eax)
  801d18:	8b 45 08             	mov    0x8(%ebp),%eax
  801d1b:	88 02                	mov    %al,(%edx)
}
  801d1d:	5d                   	pop    %ebp
  801d1e:	c3                   	ret    

00801d1f <printfmt>:
{
  801d1f:	55                   	push   %ebp
  801d20:	89 e5                	mov    %esp,%ebp
  801d22:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  801d25:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801d28:	50                   	push   %eax
  801d29:	ff 75 10             	pushl  0x10(%ebp)
  801d2c:	ff 75 0c             	pushl  0xc(%ebp)
  801d2f:	ff 75 08             	pushl  0x8(%ebp)
  801d32:	e8 05 00 00 00       	call   801d3c <vprintfmt>
}
  801d37:	83 c4 10             	add    $0x10,%esp
  801d3a:	c9                   	leave  
  801d3b:	c3                   	ret    

00801d3c <vprintfmt>:
{
  801d3c:	55                   	push   %ebp
  801d3d:	89 e5                	mov    %esp,%ebp
  801d3f:	57                   	push   %edi
  801d40:	56                   	push   %esi
  801d41:	53                   	push   %ebx
  801d42:	83 ec 2c             	sub    $0x2c,%esp
  801d45:	8b 75 08             	mov    0x8(%ebp),%esi
  801d48:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801d4b:	8b 7d 10             	mov    0x10(%ebp),%edi
  801d4e:	e9 c1 03 00 00       	jmp    802114 <vprintfmt+0x3d8>
		padc = ' ';
  801d53:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  801d57:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  801d5e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  801d65:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  801d6c:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801d71:	8d 47 01             	lea    0x1(%edi),%eax
  801d74:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801d77:	0f b6 17             	movzbl (%edi),%edx
  801d7a:	8d 42 dd             	lea    -0x23(%edx),%eax
  801d7d:	3c 55                	cmp    $0x55,%al
  801d7f:	0f 87 12 04 00 00    	ja     802197 <vprintfmt+0x45b>
  801d85:	0f b6 c0             	movzbl %al,%eax
  801d88:	ff 24 85 40 40 80 00 	jmp    *0x804040(,%eax,4)
  801d8f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801d92:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  801d96:	eb d9                	jmp    801d71 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  801d98:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  801d9b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801d9f:	eb d0                	jmp    801d71 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  801da1:	0f b6 d2             	movzbl %dl,%edx
  801da4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801da7:	b8 00 00 00 00       	mov    $0x0,%eax
  801dac:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801daf:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801db2:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801db6:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801db9:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801dbc:	83 f9 09             	cmp    $0x9,%ecx
  801dbf:	77 55                	ja     801e16 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  801dc1:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801dc4:	eb e9                	jmp    801daf <vprintfmt+0x73>
			precision = va_arg(ap, int);
  801dc6:	8b 45 14             	mov    0x14(%ebp),%eax
  801dc9:	8b 00                	mov    (%eax),%eax
  801dcb:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801dce:	8b 45 14             	mov    0x14(%ebp),%eax
  801dd1:	8d 40 04             	lea    0x4(%eax),%eax
  801dd4:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801dd7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801dda:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801dde:	79 91                	jns    801d71 <vprintfmt+0x35>
				width = precision, precision = -1;
  801de0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801de3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801de6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801ded:	eb 82                	jmp    801d71 <vprintfmt+0x35>
  801def:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801df2:	85 c0                	test   %eax,%eax
  801df4:	ba 00 00 00 00       	mov    $0x0,%edx
  801df9:	0f 49 d0             	cmovns %eax,%edx
  801dfc:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801dff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801e02:	e9 6a ff ff ff       	jmp    801d71 <vprintfmt+0x35>
  801e07:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  801e0a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801e11:	e9 5b ff ff ff       	jmp    801d71 <vprintfmt+0x35>
  801e16:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801e19:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801e1c:	eb bc                	jmp    801dda <vprintfmt+0x9e>
			lflag++;
  801e1e:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801e21:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801e24:	e9 48 ff ff ff       	jmp    801d71 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  801e29:	8b 45 14             	mov    0x14(%ebp),%eax
  801e2c:	8d 78 04             	lea    0x4(%eax),%edi
  801e2f:	83 ec 08             	sub    $0x8,%esp
  801e32:	53                   	push   %ebx
  801e33:	ff 30                	pushl  (%eax)
  801e35:	ff d6                	call   *%esi
			break;
  801e37:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  801e3a:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  801e3d:	e9 cf 02 00 00       	jmp    802111 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  801e42:	8b 45 14             	mov    0x14(%ebp),%eax
  801e45:	8d 78 04             	lea    0x4(%eax),%edi
  801e48:	8b 00                	mov    (%eax),%eax
  801e4a:	99                   	cltd   
  801e4b:	31 d0                	xor    %edx,%eax
  801e4d:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801e4f:	83 f8 0f             	cmp    $0xf,%eax
  801e52:	7f 23                	jg     801e77 <vprintfmt+0x13b>
  801e54:	8b 14 85 a0 41 80 00 	mov    0x8041a0(,%eax,4),%edx
  801e5b:	85 d2                	test   %edx,%edx
  801e5d:	74 18                	je     801e77 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  801e5f:	52                   	push   %edx
  801e60:	68 6f 39 80 00       	push   $0x80396f
  801e65:	53                   	push   %ebx
  801e66:	56                   	push   %esi
  801e67:	e8 b3 fe ff ff       	call   801d1f <printfmt>
  801e6c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801e6f:	89 7d 14             	mov    %edi,0x14(%ebp)
  801e72:	e9 9a 02 00 00       	jmp    802111 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  801e77:	50                   	push   %eax
  801e78:	68 1f 3f 80 00       	push   $0x803f1f
  801e7d:	53                   	push   %ebx
  801e7e:	56                   	push   %esi
  801e7f:	e8 9b fe ff ff       	call   801d1f <printfmt>
  801e84:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801e87:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  801e8a:	e9 82 02 00 00       	jmp    802111 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  801e8f:	8b 45 14             	mov    0x14(%ebp),%eax
  801e92:	83 c0 04             	add    $0x4,%eax
  801e95:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801e98:	8b 45 14             	mov    0x14(%ebp),%eax
  801e9b:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801e9d:	85 ff                	test   %edi,%edi
  801e9f:	b8 18 3f 80 00       	mov    $0x803f18,%eax
  801ea4:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801ea7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801eab:	0f 8e bd 00 00 00    	jle    801f6e <vprintfmt+0x232>
  801eb1:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801eb5:	75 0e                	jne    801ec5 <vprintfmt+0x189>
  801eb7:	89 75 08             	mov    %esi,0x8(%ebp)
  801eba:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801ebd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801ec0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801ec3:	eb 6d                	jmp    801f32 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  801ec5:	83 ec 08             	sub    $0x8,%esp
  801ec8:	ff 75 d0             	pushl  -0x30(%ebp)
  801ecb:	57                   	push   %edi
  801ecc:	e8 6e 03 00 00       	call   80223f <strnlen>
  801ed1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801ed4:	29 c1                	sub    %eax,%ecx
  801ed6:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  801ed9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801edc:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801ee0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ee3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801ee6:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  801ee8:	eb 0f                	jmp    801ef9 <vprintfmt+0x1bd>
					putch(padc, putdat);
  801eea:	83 ec 08             	sub    $0x8,%esp
  801eed:	53                   	push   %ebx
  801eee:	ff 75 e0             	pushl  -0x20(%ebp)
  801ef1:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  801ef3:	83 ef 01             	sub    $0x1,%edi
  801ef6:	83 c4 10             	add    $0x10,%esp
  801ef9:	85 ff                	test   %edi,%edi
  801efb:	7f ed                	jg     801eea <vprintfmt+0x1ae>
  801efd:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801f00:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  801f03:	85 c9                	test   %ecx,%ecx
  801f05:	b8 00 00 00 00       	mov    $0x0,%eax
  801f0a:	0f 49 c1             	cmovns %ecx,%eax
  801f0d:	29 c1                	sub    %eax,%ecx
  801f0f:	89 75 08             	mov    %esi,0x8(%ebp)
  801f12:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801f15:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801f18:	89 cb                	mov    %ecx,%ebx
  801f1a:	eb 16                	jmp    801f32 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  801f1c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801f20:	75 31                	jne    801f53 <vprintfmt+0x217>
					putch(ch, putdat);
  801f22:	83 ec 08             	sub    $0x8,%esp
  801f25:	ff 75 0c             	pushl  0xc(%ebp)
  801f28:	50                   	push   %eax
  801f29:	ff 55 08             	call   *0x8(%ebp)
  801f2c:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801f2f:	83 eb 01             	sub    $0x1,%ebx
  801f32:	83 c7 01             	add    $0x1,%edi
  801f35:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  801f39:	0f be c2             	movsbl %dl,%eax
  801f3c:	85 c0                	test   %eax,%eax
  801f3e:	74 59                	je     801f99 <vprintfmt+0x25d>
  801f40:	85 f6                	test   %esi,%esi
  801f42:	78 d8                	js     801f1c <vprintfmt+0x1e0>
  801f44:	83 ee 01             	sub    $0x1,%esi
  801f47:	79 d3                	jns    801f1c <vprintfmt+0x1e0>
  801f49:	89 df                	mov    %ebx,%edi
  801f4b:	8b 75 08             	mov    0x8(%ebp),%esi
  801f4e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801f51:	eb 37                	jmp    801f8a <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  801f53:	0f be d2             	movsbl %dl,%edx
  801f56:	83 ea 20             	sub    $0x20,%edx
  801f59:	83 fa 5e             	cmp    $0x5e,%edx
  801f5c:	76 c4                	jbe    801f22 <vprintfmt+0x1e6>
					putch('?', putdat);
  801f5e:	83 ec 08             	sub    $0x8,%esp
  801f61:	ff 75 0c             	pushl  0xc(%ebp)
  801f64:	6a 3f                	push   $0x3f
  801f66:	ff 55 08             	call   *0x8(%ebp)
  801f69:	83 c4 10             	add    $0x10,%esp
  801f6c:	eb c1                	jmp    801f2f <vprintfmt+0x1f3>
  801f6e:	89 75 08             	mov    %esi,0x8(%ebp)
  801f71:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801f74:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801f77:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801f7a:	eb b6                	jmp    801f32 <vprintfmt+0x1f6>
				putch(' ', putdat);
  801f7c:	83 ec 08             	sub    $0x8,%esp
  801f7f:	53                   	push   %ebx
  801f80:	6a 20                	push   $0x20
  801f82:	ff d6                	call   *%esi
			for (; width > 0; width--)
  801f84:	83 ef 01             	sub    $0x1,%edi
  801f87:	83 c4 10             	add    $0x10,%esp
  801f8a:	85 ff                	test   %edi,%edi
  801f8c:	7f ee                	jg     801f7c <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  801f8e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801f91:	89 45 14             	mov    %eax,0x14(%ebp)
  801f94:	e9 78 01 00 00       	jmp    802111 <vprintfmt+0x3d5>
  801f99:	89 df                	mov    %ebx,%edi
  801f9b:	8b 75 08             	mov    0x8(%ebp),%esi
  801f9e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801fa1:	eb e7                	jmp    801f8a <vprintfmt+0x24e>
	if (lflag >= 2)
  801fa3:	83 f9 01             	cmp    $0x1,%ecx
  801fa6:	7e 3f                	jle    801fe7 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  801fa8:	8b 45 14             	mov    0x14(%ebp),%eax
  801fab:	8b 50 04             	mov    0x4(%eax),%edx
  801fae:	8b 00                	mov    (%eax),%eax
  801fb0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801fb3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801fb6:	8b 45 14             	mov    0x14(%ebp),%eax
  801fb9:	8d 40 08             	lea    0x8(%eax),%eax
  801fbc:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  801fbf:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801fc3:	79 5c                	jns    802021 <vprintfmt+0x2e5>
				putch('-', putdat);
  801fc5:	83 ec 08             	sub    $0x8,%esp
  801fc8:	53                   	push   %ebx
  801fc9:	6a 2d                	push   $0x2d
  801fcb:	ff d6                	call   *%esi
				num = -(long long) num;
  801fcd:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801fd0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801fd3:	f7 da                	neg    %edx
  801fd5:	83 d1 00             	adc    $0x0,%ecx
  801fd8:	f7 d9                	neg    %ecx
  801fda:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801fdd:	b8 0a 00 00 00       	mov    $0xa,%eax
  801fe2:	e9 10 01 00 00       	jmp    8020f7 <vprintfmt+0x3bb>
	else if (lflag)
  801fe7:	85 c9                	test   %ecx,%ecx
  801fe9:	75 1b                	jne    802006 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  801feb:	8b 45 14             	mov    0x14(%ebp),%eax
  801fee:	8b 00                	mov    (%eax),%eax
  801ff0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801ff3:	89 c1                	mov    %eax,%ecx
  801ff5:	c1 f9 1f             	sar    $0x1f,%ecx
  801ff8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801ffb:	8b 45 14             	mov    0x14(%ebp),%eax
  801ffe:	8d 40 04             	lea    0x4(%eax),%eax
  802001:	89 45 14             	mov    %eax,0x14(%ebp)
  802004:	eb b9                	jmp    801fbf <vprintfmt+0x283>
		return va_arg(*ap, long);
  802006:	8b 45 14             	mov    0x14(%ebp),%eax
  802009:	8b 00                	mov    (%eax),%eax
  80200b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80200e:	89 c1                	mov    %eax,%ecx
  802010:	c1 f9 1f             	sar    $0x1f,%ecx
  802013:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  802016:	8b 45 14             	mov    0x14(%ebp),%eax
  802019:	8d 40 04             	lea    0x4(%eax),%eax
  80201c:	89 45 14             	mov    %eax,0x14(%ebp)
  80201f:	eb 9e                	jmp    801fbf <vprintfmt+0x283>
			num = getint(&ap, lflag);
  802021:	8b 55 d8             	mov    -0x28(%ebp),%edx
  802024:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  802027:	b8 0a 00 00 00       	mov    $0xa,%eax
  80202c:	e9 c6 00 00 00       	jmp    8020f7 <vprintfmt+0x3bb>
	if (lflag >= 2)
  802031:	83 f9 01             	cmp    $0x1,%ecx
  802034:	7e 18                	jle    80204e <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  802036:	8b 45 14             	mov    0x14(%ebp),%eax
  802039:	8b 10                	mov    (%eax),%edx
  80203b:	8b 48 04             	mov    0x4(%eax),%ecx
  80203e:	8d 40 08             	lea    0x8(%eax),%eax
  802041:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  802044:	b8 0a 00 00 00       	mov    $0xa,%eax
  802049:	e9 a9 00 00 00       	jmp    8020f7 <vprintfmt+0x3bb>
	else if (lflag)
  80204e:	85 c9                	test   %ecx,%ecx
  802050:	75 1a                	jne    80206c <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  802052:	8b 45 14             	mov    0x14(%ebp),%eax
  802055:	8b 10                	mov    (%eax),%edx
  802057:	b9 00 00 00 00       	mov    $0x0,%ecx
  80205c:	8d 40 04             	lea    0x4(%eax),%eax
  80205f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  802062:	b8 0a 00 00 00       	mov    $0xa,%eax
  802067:	e9 8b 00 00 00       	jmp    8020f7 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80206c:	8b 45 14             	mov    0x14(%ebp),%eax
  80206f:	8b 10                	mov    (%eax),%edx
  802071:	b9 00 00 00 00       	mov    $0x0,%ecx
  802076:	8d 40 04             	lea    0x4(%eax),%eax
  802079:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80207c:	b8 0a 00 00 00       	mov    $0xa,%eax
  802081:	eb 74                	jmp    8020f7 <vprintfmt+0x3bb>
	if (lflag >= 2)
  802083:	83 f9 01             	cmp    $0x1,%ecx
  802086:	7e 15                	jle    80209d <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  802088:	8b 45 14             	mov    0x14(%ebp),%eax
  80208b:	8b 10                	mov    (%eax),%edx
  80208d:	8b 48 04             	mov    0x4(%eax),%ecx
  802090:	8d 40 08             	lea    0x8(%eax),%eax
  802093:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  802096:	b8 08 00 00 00       	mov    $0x8,%eax
  80209b:	eb 5a                	jmp    8020f7 <vprintfmt+0x3bb>
	else if (lflag)
  80209d:	85 c9                	test   %ecx,%ecx
  80209f:	75 17                	jne    8020b8 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  8020a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8020a4:	8b 10                	mov    (%eax),%edx
  8020a6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8020ab:	8d 40 04             	lea    0x4(%eax),%eax
  8020ae:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8020b1:	b8 08 00 00 00       	mov    $0x8,%eax
  8020b6:	eb 3f                	jmp    8020f7 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8020b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8020bb:	8b 10                	mov    (%eax),%edx
  8020bd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8020c2:	8d 40 04             	lea    0x4(%eax),%eax
  8020c5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8020c8:	b8 08 00 00 00       	mov    $0x8,%eax
  8020cd:	eb 28                	jmp    8020f7 <vprintfmt+0x3bb>
			putch('0', putdat);
  8020cf:	83 ec 08             	sub    $0x8,%esp
  8020d2:	53                   	push   %ebx
  8020d3:	6a 30                	push   $0x30
  8020d5:	ff d6                	call   *%esi
			putch('x', putdat);
  8020d7:	83 c4 08             	add    $0x8,%esp
  8020da:	53                   	push   %ebx
  8020db:	6a 78                	push   $0x78
  8020dd:	ff d6                	call   *%esi
			num = (unsigned long long)
  8020df:	8b 45 14             	mov    0x14(%ebp),%eax
  8020e2:	8b 10                	mov    (%eax),%edx
  8020e4:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8020e9:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8020ec:	8d 40 04             	lea    0x4(%eax),%eax
  8020ef:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8020f2:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8020f7:	83 ec 0c             	sub    $0xc,%esp
  8020fa:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8020fe:	57                   	push   %edi
  8020ff:	ff 75 e0             	pushl  -0x20(%ebp)
  802102:	50                   	push   %eax
  802103:	51                   	push   %ecx
  802104:	52                   	push   %edx
  802105:	89 da                	mov    %ebx,%edx
  802107:	89 f0                	mov    %esi,%eax
  802109:	e8 45 fb ff ff       	call   801c53 <printnum>
			break;
  80210e:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  802111:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  802114:	83 c7 01             	add    $0x1,%edi
  802117:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80211b:	83 f8 25             	cmp    $0x25,%eax
  80211e:	0f 84 2f fc ff ff    	je     801d53 <vprintfmt+0x17>
			if (ch == '\0')
  802124:	85 c0                	test   %eax,%eax
  802126:	0f 84 8b 00 00 00    	je     8021b7 <vprintfmt+0x47b>
			putch(ch, putdat);
  80212c:	83 ec 08             	sub    $0x8,%esp
  80212f:	53                   	push   %ebx
  802130:	50                   	push   %eax
  802131:	ff d6                	call   *%esi
  802133:	83 c4 10             	add    $0x10,%esp
  802136:	eb dc                	jmp    802114 <vprintfmt+0x3d8>
	if (lflag >= 2)
  802138:	83 f9 01             	cmp    $0x1,%ecx
  80213b:	7e 15                	jle    802152 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  80213d:	8b 45 14             	mov    0x14(%ebp),%eax
  802140:	8b 10                	mov    (%eax),%edx
  802142:	8b 48 04             	mov    0x4(%eax),%ecx
  802145:	8d 40 08             	lea    0x8(%eax),%eax
  802148:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80214b:	b8 10 00 00 00       	mov    $0x10,%eax
  802150:	eb a5                	jmp    8020f7 <vprintfmt+0x3bb>
	else if (lflag)
  802152:	85 c9                	test   %ecx,%ecx
  802154:	75 17                	jne    80216d <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  802156:	8b 45 14             	mov    0x14(%ebp),%eax
  802159:	8b 10                	mov    (%eax),%edx
  80215b:	b9 00 00 00 00       	mov    $0x0,%ecx
  802160:	8d 40 04             	lea    0x4(%eax),%eax
  802163:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  802166:	b8 10 00 00 00       	mov    $0x10,%eax
  80216b:	eb 8a                	jmp    8020f7 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80216d:	8b 45 14             	mov    0x14(%ebp),%eax
  802170:	8b 10                	mov    (%eax),%edx
  802172:	b9 00 00 00 00       	mov    $0x0,%ecx
  802177:	8d 40 04             	lea    0x4(%eax),%eax
  80217a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80217d:	b8 10 00 00 00       	mov    $0x10,%eax
  802182:	e9 70 ff ff ff       	jmp    8020f7 <vprintfmt+0x3bb>
			putch(ch, putdat);
  802187:	83 ec 08             	sub    $0x8,%esp
  80218a:	53                   	push   %ebx
  80218b:	6a 25                	push   $0x25
  80218d:	ff d6                	call   *%esi
			break;
  80218f:	83 c4 10             	add    $0x10,%esp
  802192:	e9 7a ff ff ff       	jmp    802111 <vprintfmt+0x3d5>
			putch('%', putdat);
  802197:	83 ec 08             	sub    $0x8,%esp
  80219a:	53                   	push   %ebx
  80219b:	6a 25                	push   $0x25
  80219d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80219f:	83 c4 10             	add    $0x10,%esp
  8021a2:	89 f8                	mov    %edi,%eax
  8021a4:	eb 03                	jmp    8021a9 <vprintfmt+0x46d>
  8021a6:	83 e8 01             	sub    $0x1,%eax
  8021a9:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8021ad:	75 f7                	jne    8021a6 <vprintfmt+0x46a>
  8021af:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8021b2:	e9 5a ff ff ff       	jmp    802111 <vprintfmt+0x3d5>
}
  8021b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021ba:	5b                   	pop    %ebx
  8021bb:	5e                   	pop    %esi
  8021bc:	5f                   	pop    %edi
  8021bd:	5d                   	pop    %ebp
  8021be:	c3                   	ret    

008021bf <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8021bf:	55                   	push   %ebp
  8021c0:	89 e5                	mov    %esp,%ebp
  8021c2:	83 ec 18             	sub    $0x18,%esp
  8021c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8021c8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8021cb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8021ce:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8021d2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8021d5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8021dc:	85 c0                	test   %eax,%eax
  8021de:	74 26                	je     802206 <vsnprintf+0x47>
  8021e0:	85 d2                	test   %edx,%edx
  8021e2:	7e 22                	jle    802206 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8021e4:	ff 75 14             	pushl  0x14(%ebp)
  8021e7:	ff 75 10             	pushl  0x10(%ebp)
  8021ea:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8021ed:	50                   	push   %eax
  8021ee:	68 02 1d 80 00       	push   $0x801d02
  8021f3:	e8 44 fb ff ff       	call   801d3c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8021f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8021fb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8021fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802201:	83 c4 10             	add    $0x10,%esp
}
  802204:	c9                   	leave  
  802205:	c3                   	ret    
		return -E_INVAL;
  802206:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80220b:	eb f7                	jmp    802204 <vsnprintf+0x45>

0080220d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80220d:	55                   	push   %ebp
  80220e:	89 e5                	mov    %esp,%ebp
  802210:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  802213:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  802216:	50                   	push   %eax
  802217:	ff 75 10             	pushl  0x10(%ebp)
  80221a:	ff 75 0c             	pushl  0xc(%ebp)
  80221d:	ff 75 08             	pushl  0x8(%ebp)
  802220:	e8 9a ff ff ff       	call   8021bf <vsnprintf>
	va_end(ap);

	return rc;
}
  802225:	c9                   	leave  
  802226:	c3                   	ret    

00802227 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  802227:	55                   	push   %ebp
  802228:	89 e5                	mov    %esp,%ebp
  80222a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80222d:	b8 00 00 00 00       	mov    $0x0,%eax
  802232:	eb 03                	jmp    802237 <strlen+0x10>
		n++;
  802234:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  802237:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80223b:	75 f7                	jne    802234 <strlen+0xd>
	return n;
}
  80223d:	5d                   	pop    %ebp
  80223e:	c3                   	ret    

0080223f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80223f:	55                   	push   %ebp
  802240:	89 e5                	mov    %esp,%ebp
  802242:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802245:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  802248:	b8 00 00 00 00       	mov    $0x0,%eax
  80224d:	eb 03                	jmp    802252 <strnlen+0x13>
		n++;
  80224f:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  802252:	39 d0                	cmp    %edx,%eax
  802254:	74 06                	je     80225c <strnlen+0x1d>
  802256:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80225a:	75 f3                	jne    80224f <strnlen+0x10>
	return n;
}
  80225c:	5d                   	pop    %ebp
  80225d:	c3                   	ret    

0080225e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80225e:	55                   	push   %ebp
  80225f:	89 e5                	mov    %esp,%ebp
  802261:	53                   	push   %ebx
  802262:	8b 45 08             	mov    0x8(%ebp),%eax
  802265:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  802268:	89 c2                	mov    %eax,%edx
  80226a:	83 c1 01             	add    $0x1,%ecx
  80226d:	83 c2 01             	add    $0x1,%edx
  802270:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  802274:	88 5a ff             	mov    %bl,-0x1(%edx)
  802277:	84 db                	test   %bl,%bl
  802279:	75 ef                	jne    80226a <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80227b:	5b                   	pop    %ebx
  80227c:	5d                   	pop    %ebp
  80227d:	c3                   	ret    

0080227e <strcat>:

char *
strcat(char *dst, const char *src)
{
  80227e:	55                   	push   %ebp
  80227f:	89 e5                	mov    %esp,%ebp
  802281:	53                   	push   %ebx
  802282:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  802285:	53                   	push   %ebx
  802286:	e8 9c ff ff ff       	call   802227 <strlen>
  80228b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80228e:	ff 75 0c             	pushl  0xc(%ebp)
  802291:	01 d8                	add    %ebx,%eax
  802293:	50                   	push   %eax
  802294:	e8 c5 ff ff ff       	call   80225e <strcpy>
	return dst;
}
  802299:	89 d8                	mov    %ebx,%eax
  80229b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80229e:	c9                   	leave  
  80229f:	c3                   	ret    

008022a0 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8022a0:	55                   	push   %ebp
  8022a1:	89 e5                	mov    %esp,%ebp
  8022a3:	56                   	push   %esi
  8022a4:	53                   	push   %ebx
  8022a5:	8b 75 08             	mov    0x8(%ebp),%esi
  8022a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8022ab:	89 f3                	mov    %esi,%ebx
  8022ad:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8022b0:	89 f2                	mov    %esi,%edx
  8022b2:	eb 0f                	jmp    8022c3 <strncpy+0x23>
		*dst++ = *src;
  8022b4:	83 c2 01             	add    $0x1,%edx
  8022b7:	0f b6 01             	movzbl (%ecx),%eax
  8022ba:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8022bd:	80 39 01             	cmpb   $0x1,(%ecx)
  8022c0:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8022c3:	39 da                	cmp    %ebx,%edx
  8022c5:	75 ed                	jne    8022b4 <strncpy+0x14>
	}
	return ret;
}
  8022c7:	89 f0                	mov    %esi,%eax
  8022c9:	5b                   	pop    %ebx
  8022ca:	5e                   	pop    %esi
  8022cb:	5d                   	pop    %ebp
  8022cc:	c3                   	ret    

008022cd <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8022cd:	55                   	push   %ebp
  8022ce:	89 e5                	mov    %esp,%ebp
  8022d0:	56                   	push   %esi
  8022d1:	53                   	push   %ebx
  8022d2:	8b 75 08             	mov    0x8(%ebp),%esi
  8022d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022d8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8022db:	89 f0                	mov    %esi,%eax
  8022dd:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8022e1:	85 c9                	test   %ecx,%ecx
  8022e3:	75 0b                	jne    8022f0 <strlcpy+0x23>
  8022e5:	eb 17                	jmp    8022fe <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8022e7:	83 c2 01             	add    $0x1,%edx
  8022ea:	83 c0 01             	add    $0x1,%eax
  8022ed:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8022f0:	39 d8                	cmp    %ebx,%eax
  8022f2:	74 07                	je     8022fb <strlcpy+0x2e>
  8022f4:	0f b6 0a             	movzbl (%edx),%ecx
  8022f7:	84 c9                	test   %cl,%cl
  8022f9:	75 ec                	jne    8022e7 <strlcpy+0x1a>
		*dst = '\0';
  8022fb:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8022fe:	29 f0                	sub    %esi,%eax
}
  802300:	5b                   	pop    %ebx
  802301:	5e                   	pop    %esi
  802302:	5d                   	pop    %ebp
  802303:	c3                   	ret    

00802304 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  802304:	55                   	push   %ebp
  802305:	89 e5                	mov    %esp,%ebp
  802307:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80230a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80230d:	eb 06                	jmp    802315 <strcmp+0x11>
		p++, q++;
  80230f:	83 c1 01             	add    $0x1,%ecx
  802312:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  802315:	0f b6 01             	movzbl (%ecx),%eax
  802318:	84 c0                	test   %al,%al
  80231a:	74 04                	je     802320 <strcmp+0x1c>
  80231c:	3a 02                	cmp    (%edx),%al
  80231e:	74 ef                	je     80230f <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  802320:	0f b6 c0             	movzbl %al,%eax
  802323:	0f b6 12             	movzbl (%edx),%edx
  802326:	29 d0                	sub    %edx,%eax
}
  802328:	5d                   	pop    %ebp
  802329:	c3                   	ret    

0080232a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80232a:	55                   	push   %ebp
  80232b:	89 e5                	mov    %esp,%ebp
  80232d:	53                   	push   %ebx
  80232e:	8b 45 08             	mov    0x8(%ebp),%eax
  802331:	8b 55 0c             	mov    0xc(%ebp),%edx
  802334:	89 c3                	mov    %eax,%ebx
  802336:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  802339:	eb 06                	jmp    802341 <strncmp+0x17>
		n--, p++, q++;
  80233b:	83 c0 01             	add    $0x1,%eax
  80233e:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  802341:	39 d8                	cmp    %ebx,%eax
  802343:	74 16                	je     80235b <strncmp+0x31>
  802345:	0f b6 08             	movzbl (%eax),%ecx
  802348:	84 c9                	test   %cl,%cl
  80234a:	74 04                	je     802350 <strncmp+0x26>
  80234c:	3a 0a                	cmp    (%edx),%cl
  80234e:	74 eb                	je     80233b <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  802350:	0f b6 00             	movzbl (%eax),%eax
  802353:	0f b6 12             	movzbl (%edx),%edx
  802356:	29 d0                	sub    %edx,%eax
}
  802358:	5b                   	pop    %ebx
  802359:	5d                   	pop    %ebp
  80235a:	c3                   	ret    
		return 0;
  80235b:	b8 00 00 00 00       	mov    $0x0,%eax
  802360:	eb f6                	jmp    802358 <strncmp+0x2e>

00802362 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  802362:	55                   	push   %ebp
  802363:	89 e5                	mov    %esp,%ebp
  802365:	8b 45 08             	mov    0x8(%ebp),%eax
  802368:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80236c:	0f b6 10             	movzbl (%eax),%edx
  80236f:	84 d2                	test   %dl,%dl
  802371:	74 09                	je     80237c <strchr+0x1a>
		if (*s == c)
  802373:	38 ca                	cmp    %cl,%dl
  802375:	74 0a                	je     802381 <strchr+0x1f>
	for (; *s; s++)
  802377:	83 c0 01             	add    $0x1,%eax
  80237a:	eb f0                	jmp    80236c <strchr+0xa>
			return (char *) s;
	return 0;
  80237c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802381:	5d                   	pop    %ebp
  802382:	c3                   	ret    

00802383 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  802383:	55                   	push   %ebp
  802384:	89 e5                	mov    %esp,%ebp
  802386:	8b 45 08             	mov    0x8(%ebp),%eax
  802389:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80238d:	eb 03                	jmp    802392 <strfind+0xf>
  80238f:	83 c0 01             	add    $0x1,%eax
  802392:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  802395:	38 ca                	cmp    %cl,%dl
  802397:	74 04                	je     80239d <strfind+0x1a>
  802399:	84 d2                	test   %dl,%dl
  80239b:	75 f2                	jne    80238f <strfind+0xc>
			break;
	return (char *) s;
}
  80239d:	5d                   	pop    %ebp
  80239e:	c3                   	ret    

0080239f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80239f:	55                   	push   %ebp
  8023a0:	89 e5                	mov    %esp,%ebp
  8023a2:	57                   	push   %edi
  8023a3:	56                   	push   %esi
  8023a4:	53                   	push   %ebx
  8023a5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8023a8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8023ab:	85 c9                	test   %ecx,%ecx
  8023ad:	74 13                	je     8023c2 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8023af:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8023b5:	75 05                	jne    8023bc <memset+0x1d>
  8023b7:	f6 c1 03             	test   $0x3,%cl
  8023ba:	74 0d                	je     8023c9 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8023bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023bf:	fc                   	cld    
  8023c0:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8023c2:	89 f8                	mov    %edi,%eax
  8023c4:	5b                   	pop    %ebx
  8023c5:	5e                   	pop    %esi
  8023c6:	5f                   	pop    %edi
  8023c7:	5d                   	pop    %ebp
  8023c8:	c3                   	ret    
		c &= 0xFF;
  8023c9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8023cd:	89 d3                	mov    %edx,%ebx
  8023cf:	c1 e3 08             	shl    $0x8,%ebx
  8023d2:	89 d0                	mov    %edx,%eax
  8023d4:	c1 e0 18             	shl    $0x18,%eax
  8023d7:	89 d6                	mov    %edx,%esi
  8023d9:	c1 e6 10             	shl    $0x10,%esi
  8023dc:	09 f0                	or     %esi,%eax
  8023de:	09 c2                	or     %eax,%edx
  8023e0:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  8023e2:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8023e5:	89 d0                	mov    %edx,%eax
  8023e7:	fc                   	cld    
  8023e8:	f3 ab                	rep stos %eax,%es:(%edi)
  8023ea:	eb d6                	jmp    8023c2 <memset+0x23>

008023ec <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8023ec:	55                   	push   %ebp
  8023ed:	89 e5                	mov    %esp,%ebp
  8023ef:	57                   	push   %edi
  8023f0:	56                   	push   %esi
  8023f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8023f4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8023f7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8023fa:	39 c6                	cmp    %eax,%esi
  8023fc:	73 35                	jae    802433 <memmove+0x47>
  8023fe:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  802401:	39 c2                	cmp    %eax,%edx
  802403:	76 2e                	jbe    802433 <memmove+0x47>
		s += n;
		d += n;
  802405:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802408:	89 d6                	mov    %edx,%esi
  80240a:	09 fe                	or     %edi,%esi
  80240c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  802412:	74 0c                	je     802420 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  802414:	83 ef 01             	sub    $0x1,%edi
  802417:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80241a:	fd                   	std    
  80241b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80241d:	fc                   	cld    
  80241e:	eb 21                	jmp    802441 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802420:	f6 c1 03             	test   $0x3,%cl
  802423:	75 ef                	jne    802414 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  802425:	83 ef 04             	sub    $0x4,%edi
  802428:	8d 72 fc             	lea    -0x4(%edx),%esi
  80242b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80242e:	fd                   	std    
  80242f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  802431:	eb ea                	jmp    80241d <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802433:	89 f2                	mov    %esi,%edx
  802435:	09 c2                	or     %eax,%edx
  802437:	f6 c2 03             	test   $0x3,%dl
  80243a:	74 09                	je     802445 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80243c:	89 c7                	mov    %eax,%edi
  80243e:	fc                   	cld    
  80243f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  802441:	5e                   	pop    %esi
  802442:	5f                   	pop    %edi
  802443:	5d                   	pop    %ebp
  802444:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802445:	f6 c1 03             	test   $0x3,%cl
  802448:	75 f2                	jne    80243c <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80244a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80244d:	89 c7                	mov    %eax,%edi
  80244f:	fc                   	cld    
  802450:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  802452:	eb ed                	jmp    802441 <memmove+0x55>

00802454 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  802454:	55                   	push   %ebp
  802455:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  802457:	ff 75 10             	pushl  0x10(%ebp)
  80245a:	ff 75 0c             	pushl  0xc(%ebp)
  80245d:	ff 75 08             	pushl  0x8(%ebp)
  802460:	e8 87 ff ff ff       	call   8023ec <memmove>
}
  802465:	c9                   	leave  
  802466:	c3                   	ret    

00802467 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  802467:	55                   	push   %ebp
  802468:	89 e5                	mov    %esp,%ebp
  80246a:	56                   	push   %esi
  80246b:	53                   	push   %ebx
  80246c:	8b 45 08             	mov    0x8(%ebp),%eax
  80246f:	8b 55 0c             	mov    0xc(%ebp),%edx
  802472:	89 c6                	mov    %eax,%esi
  802474:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  802477:	39 f0                	cmp    %esi,%eax
  802479:	74 1c                	je     802497 <memcmp+0x30>
		if (*s1 != *s2)
  80247b:	0f b6 08             	movzbl (%eax),%ecx
  80247e:	0f b6 1a             	movzbl (%edx),%ebx
  802481:	38 d9                	cmp    %bl,%cl
  802483:	75 08                	jne    80248d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  802485:	83 c0 01             	add    $0x1,%eax
  802488:	83 c2 01             	add    $0x1,%edx
  80248b:	eb ea                	jmp    802477 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  80248d:	0f b6 c1             	movzbl %cl,%eax
  802490:	0f b6 db             	movzbl %bl,%ebx
  802493:	29 d8                	sub    %ebx,%eax
  802495:	eb 05                	jmp    80249c <memcmp+0x35>
	}

	return 0;
  802497:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80249c:	5b                   	pop    %ebx
  80249d:	5e                   	pop    %esi
  80249e:	5d                   	pop    %ebp
  80249f:	c3                   	ret    

008024a0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8024a0:	55                   	push   %ebp
  8024a1:	89 e5                	mov    %esp,%ebp
  8024a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8024a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8024a9:	89 c2                	mov    %eax,%edx
  8024ab:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8024ae:	39 d0                	cmp    %edx,%eax
  8024b0:	73 09                	jae    8024bb <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8024b2:	38 08                	cmp    %cl,(%eax)
  8024b4:	74 05                	je     8024bb <memfind+0x1b>
	for (; s < ends; s++)
  8024b6:	83 c0 01             	add    $0x1,%eax
  8024b9:	eb f3                	jmp    8024ae <memfind+0xe>
			break;
	return (void *) s;
}
  8024bb:	5d                   	pop    %ebp
  8024bc:	c3                   	ret    

008024bd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8024bd:	55                   	push   %ebp
  8024be:	89 e5                	mov    %esp,%ebp
  8024c0:	57                   	push   %edi
  8024c1:	56                   	push   %esi
  8024c2:	53                   	push   %ebx
  8024c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8024c6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8024c9:	eb 03                	jmp    8024ce <strtol+0x11>
		s++;
  8024cb:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  8024ce:	0f b6 01             	movzbl (%ecx),%eax
  8024d1:	3c 20                	cmp    $0x20,%al
  8024d3:	74 f6                	je     8024cb <strtol+0xe>
  8024d5:	3c 09                	cmp    $0x9,%al
  8024d7:	74 f2                	je     8024cb <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8024d9:	3c 2b                	cmp    $0x2b,%al
  8024db:	74 2e                	je     80250b <strtol+0x4e>
	int neg = 0;
  8024dd:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8024e2:	3c 2d                	cmp    $0x2d,%al
  8024e4:	74 2f                	je     802515 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8024e6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8024ec:	75 05                	jne    8024f3 <strtol+0x36>
  8024ee:	80 39 30             	cmpb   $0x30,(%ecx)
  8024f1:	74 2c                	je     80251f <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8024f3:	85 db                	test   %ebx,%ebx
  8024f5:	75 0a                	jne    802501 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8024f7:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  8024fc:	80 39 30             	cmpb   $0x30,(%ecx)
  8024ff:	74 28                	je     802529 <strtol+0x6c>
		base = 10;
  802501:	b8 00 00 00 00       	mov    $0x0,%eax
  802506:	89 5d 10             	mov    %ebx,0x10(%ebp)
  802509:	eb 50                	jmp    80255b <strtol+0x9e>
		s++;
  80250b:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  80250e:	bf 00 00 00 00       	mov    $0x0,%edi
  802513:	eb d1                	jmp    8024e6 <strtol+0x29>
		s++, neg = 1;
  802515:	83 c1 01             	add    $0x1,%ecx
  802518:	bf 01 00 00 00       	mov    $0x1,%edi
  80251d:	eb c7                	jmp    8024e6 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80251f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  802523:	74 0e                	je     802533 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  802525:	85 db                	test   %ebx,%ebx
  802527:	75 d8                	jne    802501 <strtol+0x44>
		s++, base = 8;
  802529:	83 c1 01             	add    $0x1,%ecx
  80252c:	bb 08 00 00 00       	mov    $0x8,%ebx
  802531:	eb ce                	jmp    802501 <strtol+0x44>
		s += 2, base = 16;
  802533:	83 c1 02             	add    $0x2,%ecx
  802536:	bb 10 00 00 00       	mov    $0x10,%ebx
  80253b:	eb c4                	jmp    802501 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  80253d:	8d 72 9f             	lea    -0x61(%edx),%esi
  802540:	89 f3                	mov    %esi,%ebx
  802542:	80 fb 19             	cmp    $0x19,%bl
  802545:	77 29                	ja     802570 <strtol+0xb3>
			dig = *s - 'a' + 10;
  802547:	0f be d2             	movsbl %dl,%edx
  80254a:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  80254d:	3b 55 10             	cmp    0x10(%ebp),%edx
  802550:	7d 30                	jge    802582 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  802552:	83 c1 01             	add    $0x1,%ecx
  802555:	0f af 45 10          	imul   0x10(%ebp),%eax
  802559:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  80255b:	0f b6 11             	movzbl (%ecx),%edx
  80255e:	8d 72 d0             	lea    -0x30(%edx),%esi
  802561:	89 f3                	mov    %esi,%ebx
  802563:	80 fb 09             	cmp    $0x9,%bl
  802566:	77 d5                	ja     80253d <strtol+0x80>
			dig = *s - '0';
  802568:	0f be d2             	movsbl %dl,%edx
  80256b:	83 ea 30             	sub    $0x30,%edx
  80256e:	eb dd                	jmp    80254d <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  802570:	8d 72 bf             	lea    -0x41(%edx),%esi
  802573:	89 f3                	mov    %esi,%ebx
  802575:	80 fb 19             	cmp    $0x19,%bl
  802578:	77 08                	ja     802582 <strtol+0xc5>
			dig = *s - 'A' + 10;
  80257a:	0f be d2             	movsbl %dl,%edx
  80257d:	83 ea 37             	sub    $0x37,%edx
  802580:	eb cb                	jmp    80254d <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  802582:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802586:	74 05                	je     80258d <strtol+0xd0>
		*endptr = (char *) s;
  802588:	8b 75 0c             	mov    0xc(%ebp),%esi
  80258b:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  80258d:	89 c2                	mov    %eax,%edx
  80258f:	f7 da                	neg    %edx
  802591:	85 ff                	test   %edi,%edi
  802593:	0f 45 c2             	cmovne %edx,%eax
}
  802596:	5b                   	pop    %ebx
  802597:	5e                   	pop    %esi
  802598:	5f                   	pop    %edi
  802599:	5d                   	pop    %ebp
  80259a:	c3                   	ret    

0080259b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80259b:	55                   	push   %ebp
  80259c:	89 e5                	mov    %esp,%ebp
  80259e:	57                   	push   %edi
  80259f:	56                   	push   %esi
  8025a0:	53                   	push   %ebx
	asm volatile("int %1\n"
  8025a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8025a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8025a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025ac:	89 c3                	mov    %eax,%ebx
  8025ae:	89 c7                	mov    %eax,%edi
  8025b0:	89 c6                	mov    %eax,%esi
  8025b2:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8025b4:	5b                   	pop    %ebx
  8025b5:	5e                   	pop    %esi
  8025b6:	5f                   	pop    %edi
  8025b7:	5d                   	pop    %ebp
  8025b8:	c3                   	ret    

008025b9 <sys_cgetc>:

int
sys_cgetc(void)
{
  8025b9:	55                   	push   %ebp
  8025ba:	89 e5                	mov    %esp,%ebp
  8025bc:	57                   	push   %edi
  8025bd:	56                   	push   %esi
  8025be:	53                   	push   %ebx
	asm volatile("int %1\n"
  8025bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8025c4:	b8 01 00 00 00       	mov    $0x1,%eax
  8025c9:	89 d1                	mov    %edx,%ecx
  8025cb:	89 d3                	mov    %edx,%ebx
  8025cd:	89 d7                	mov    %edx,%edi
  8025cf:	89 d6                	mov    %edx,%esi
  8025d1:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8025d3:	5b                   	pop    %ebx
  8025d4:	5e                   	pop    %esi
  8025d5:	5f                   	pop    %edi
  8025d6:	5d                   	pop    %ebp
  8025d7:	c3                   	ret    

008025d8 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8025d8:	55                   	push   %ebp
  8025d9:	89 e5                	mov    %esp,%ebp
  8025db:	57                   	push   %edi
  8025dc:	56                   	push   %esi
  8025dd:	53                   	push   %ebx
  8025de:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8025e1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8025e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8025e9:	b8 03 00 00 00       	mov    $0x3,%eax
  8025ee:	89 cb                	mov    %ecx,%ebx
  8025f0:	89 cf                	mov    %ecx,%edi
  8025f2:	89 ce                	mov    %ecx,%esi
  8025f4:	cd 30                	int    $0x30
	if(check && ret > 0)
  8025f6:	85 c0                	test   %eax,%eax
  8025f8:	7f 08                	jg     802602 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8025fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025fd:	5b                   	pop    %ebx
  8025fe:	5e                   	pop    %esi
  8025ff:	5f                   	pop    %edi
  802600:	5d                   	pop    %ebp
  802601:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  802602:	83 ec 0c             	sub    $0xc,%esp
  802605:	50                   	push   %eax
  802606:	6a 03                	push   $0x3
  802608:	68 ff 41 80 00       	push   $0x8041ff
  80260d:	6a 23                	push   $0x23
  80260f:	68 1c 42 80 00       	push   $0x80421c
  802614:	e8 4b f5 ff ff       	call   801b64 <_panic>

00802619 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  802619:	55                   	push   %ebp
  80261a:	89 e5                	mov    %esp,%ebp
  80261c:	57                   	push   %edi
  80261d:	56                   	push   %esi
  80261e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80261f:	ba 00 00 00 00       	mov    $0x0,%edx
  802624:	b8 02 00 00 00       	mov    $0x2,%eax
  802629:	89 d1                	mov    %edx,%ecx
  80262b:	89 d3                	mov    %edx,%ebx
  80262d:	89 d7                	mov    %edx,%edi
  80262f:	89 d6                	mov    %edx,%esi
  802631:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  802633:	5b                   	pop    %ebx
  802634:	5e                   	pop    %esi
  802635:	5f                   	pop    %edi
  802636:	5d                   	pop    %ebp
  802637:	c3                   	ret    

00802638 <sys_yield>:

void
sys_yield(void)
{
  802638:	55                   	push   %ebp
  802639:	89 e5                	mov    %esp,%ebp
  80263b:	57                   	push   %edi
  80263c:	56                   	push   %esi
  80263d:	53                   	push   %ebx
	asm volatile("int %1\n"
  80263e:	ba 00 00 00 00       	mov    $0x0,%edx
  802643:	b8 0b 00 00 00       	mov    $0xb,%eax
  802648:	89 d1                	mov    %edx,%ecx
  80264a:	89 d3                	mov    %edx,%ebx
  80264c:	89 d7                	mov    %edx,%edi
  80264e:	89 d6                	mov    %edx,%esi
  802650:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  802652:	5b                   	pop    %ebx
  802653:	5e                   	pop    %esi
  802654:	5f                   	pop    %edi
  802655:	5d                   	pop    %ebp
  802656:	c3                   	ret    

00802657 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  802657:	55                   	push   %ebp
  802658:	89 e5                	mov    %esp,%ebp
  80265a:	57                   	push   %edi
  80265b:	56                   	push   %esi
  80265c:	53                   	push   %ebx
  80265d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  802660:	be 00 00 00 00       	mov    $0x0,%esi
  802665:	8b 55 08             	mov    0x8(%ebp),%edx
  802668:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80266b:	b8 04 00 00 00       	mov    $0x4,%eax
  802670:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802673:	89 f7                	mov    %esi,%edi
  802675:	cd 30                	int    $0x30
	if(check && ret > 0)
  802677:	85 c0                	test   %eax,%eax
  802679:	7f 08                	jg     802683 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80267b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80267e:	5b                   	pop    %ebx
  80267f:	5e                   	pop    %esi
  802680:	5f                   	pop    %edi
  802681:	5d                   	pop    %ebp
  802682:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  802683:	83 ec 0c             	sub    $0xc,%esp
  802686:	50                   	push   %eax
  802687:	6a 04                	push   $0x4
  802689:	68 ff 41 80 00       	push   $0x8041ff
  80268e:	6a 23                	push   $0x23
  802690:	68 1c 42 80 00       	push   $0x80421c
  802695:	e8 ca f4 ff ff       	call   801b64 <_panic>

0080269a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80269a:	55                   	push   %ebp
  80269b:	89 e5                	mov    %esp,%ebp
  80269d:	57                   	push   %edi
  80269e:	56                   	push   %esi
  80269f:	53                   	push   %ebx
  8026a0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8026a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8026a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8026a9:	b8 05 00 00 00       	mov    $0x5,%eax
  8026ae:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8026b1:	8b 7d 14             	mov    0x14(%ebp),%edi
  8026b4:	8b 75 18             	mov    0x18(%ebp),%esi
  8026b7:	cd 30                	int    $0x30
	if(check && ret > 0)
  8026b9:	85 c0                	test   %eax,%eax
  8026bb:	7f 08                	jg     8026c5 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8026bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8026c0:	5b                   	pop    %ebx
  8026c1:	5e                   	pop    %esi
  8026c2:	5f                   	pop    %edi
  8026c3:	5d                   	pop    %ebp
  8026c4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8026c5:	83 ec 0c             	sub    $0xc,%esp
  8026c8:	50                   	push   %eax
  8026c9:	6a 05                	push   $0x5
  8026cb:	68 ff 41 80 00       	push   $0x8041ff
  8026d0:	6a 23                	push   $0x23
  8026d2:	68 1c 42 80 00       	push   $0x80421c
  8026d7:	e8 88 f4 ff ff       	call   801b64 <_panic>

008026dc <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8026dc:	55                   	push   %ebp
  8026dd:	89 e5                	mov    %esp,%ebp
  8026df:	57                   	push   %edi
  8026e0:	56                   	push   %esi
  8026e1:	53                   	push   %ebx
  8026e2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8026e5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8026ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8026ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8026f0:	b8 06 00 00 00       	mov    $0x6,%eax
  8026f5:	89 df                	mov    %ebx,%edi
  8026f7:	89 de                	mov    %ebx,%esi
  8026f9:	cd 30                	int    $0x30
	if(check && ret > 0)
  8026fb:	85 c0                	test   %eax,%eax
  8026fd:	7f 08                	jg     802707 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8026ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802702:	5b                   	pop    %ebx
  802703:	5e                   	pop    %esi
  802704:	5f                   	pop    %edi
  802705:	5d                   	pop    %ebp
  802706:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  802707:	83 ec 0c             	sub    $0xc,%esp
  80270a:	50                   	push   %eax
  80270b:	6a 06                	push   $0x6
  80270d:	68 ff 41 80 00       	push   $0x8041ff
  802712:	6a 23                	push   $0x23
  802714:	68 1c 42 80 00       	push   $0x80421c
  802719:	e8 46 f4 ff ff       	call   801b64 <_panic>

0080271e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80271e:	55                   	push   %ebp
  80271f:	89 e5                	mov    %esp,%ebp
  802721:	57                   	push   %edi
  802722:	56                   	push   %esi
  802723:	53                   	push   %ebx
  802724:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  802727:	bb 00 00 00 00       	mov    $0x0,%ebx
  80272c:	8b 55 08             	mov    0x8(%ebp),%edx
  80272f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802732:	b8 08 00 00 00       	mov    $0x8,%eax
  802737:	89 df                	mov    %ebx,%edi
  802739:	89 de                	mov    %ebx,%esi
  80273b:	cd 30                	int    $0x30
	if(check && ret > 0)
  80273d:	85 c0                	test   %eax,%eax
  80273f:	7f 08                	jg     802749 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  802741:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802744:	5b                   	pop    %ebx
  802745:	5e                   	pop    %esi
  802746:	5f                   	pop    %edi
  802747:	5d                   	pop    %ebp
  802748:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  802749:	83 ec 0c             	sub    $0xc,%esp
  80274c:	50                   	push   %eax
  80274d:	6a 08                	push   $0x8
  80274f:	68 ff 41 80 00       	push   $0x8041ff
  802754:	6a 23                	push   $0x23
  802756:	68 1c 42 80 00       	push   $0x80421c
  80275b:	e8 04 f4 ff ff       	call   801b64 <_panic>

00802760 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  802760:	55                   	push   %ebp
  802761:	89 e5                	mov    %esp,%ebp
  802763:	57                   	push   %edi
  802764:	56                   	push   %esi
  802765:	53                   	push   %ebx
  802766:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  802769:	bb 00 00 00 00       	mov    $0x0,%ebx
  80276e:	8b 55 08             	mov    0x8(%ebp),%edx
  802771:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802774:	b8 09 00 00 00       	mov    $0x9,%eax
  802779:	89 df                	mov    %ebx,%edi
  80277b:	89 de                	mov    %ebx,%esi
  80277d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80277f:	85 c0                	test   %eax,%eax
  802781:	7f 08                	jg     80278b <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  802783:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802786:	5b                   	pop    %ebx
  802787:	5e                   	pop    %esi
  802788:	5f                   	pop    %edi
  802789:	5d                   	pop    %ebp
  80278a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80278b:	83 ec 0c             	sub    $0xc,%esp
  80278e:	50                   	push   %eax
  80278f:	6a 09                	push   $0x9
  802791:	68 ff 41 80 00       	push   $0x8041ff
  802796:	6a 23                	push   $0x23
  802798:	68 1c 42 80 00       	push   $0x80421c
  80279d:	e8 c2 f3 ff ff       	call   801b64 <_panic>

008027a2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8027a2:	55                   	push   %ebp
  8027a3:	89 e5                	mov    %esp,%ebp
  8027a5:	57                   	push   %edi
  8027a6:	56                   	push   %esi
  8027a7:	53                   	push   %ebx
  8027a8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8027ab:	bb 00 00 00 00       	mov    $0x0,%ebx
  8027b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8027b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8027b6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8027bb:	89 df                	mov    %ebx,%edi
  8027bd:	89 de                	mov    %ebx,%esi
  8027bf:	cd 30                	int    $0x30
	if(check && ret > 0)
  8027c1:	85 c0                	test   %eax,%eax
  8027c3:	7f 08                	jg     8027cd <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8027c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8027c8:	5b                   	pop    %ebx
  8027c9:	5e                   	pop    %esi
  8027ca:	5f                   	pop    %edi
  8027cb:	5d                   	pop    %ebp
  8027cc:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8027cd:	83 ec 0c             	sub    $0xc,%esp
  8027d0:	50                   	push   %eax
  8027d1:	6a 0a                	push   $0xa
  8027d3:	68 ff 41 80 00       	push   $0x8041ff
  8027d8:	6a 23                	push   $0x23
  8027da:	68 1c 42 80 00       	push   $0x80421c
  8027df:	e8 80 f3 ff ff       	call   801b64 <_panic>

008027e4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8027e4:	55                   	push   %ebp
  8027e5:	89 e5                	mov    %esp,%ebp
  8027e7:	57                   	push   %edi
  8027e8:	56                   	push   %esi
  8027e9:	53                   	push   %ebx
	asm volatile("int %1\n"
  8027ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8027ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8027f0:	b8 0c 00 00 00       	mov    $0xc,%eax
  8027f5:	be 00 00 00 00       	mov    $0x0,%esi
  8027fa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8027fd:	8b 7d 14             	mov    0x14(%ebp),%edi
  802800:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  802802:	5b                   	pop    %ebx
  802803:	5e                   	pop    %esi
  802804:	5f                   	pop    %edi
  802805:	5d                   	pop    %ebp
  802806:	c3                   	ret    

00802807 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  802807:	55                   	push   %ebp
  802808:	89 e5                	mov    %esp,%ebp
  80280a:	57                   	push   %edi
  80280b:	56                   	push   %esi
  80280c:	53                   	push   %ebx
  80280d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  802810:	b9 00 00 00 00       	mov    $0x0,%ecx
  802815:	8b 55 08             	mov    0x8(%ebp),%edx
  802818:	b8 0d 00 00 00       	mov    $0xd,%eax
  80281d:	89 cb                	mov    %ecx,%ebx
  80281f:	89 cf                	mov    %ecx,%edi
  802821:	89 ce                	mov    %ecx,%esi
  802823:	cd 30                	int    $0x30
	if(check && ret > 0)
  802825:	85 c0                	test   %eax,%eax
  802827:	7f 08                	jg     802831 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  802829:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80282c:	5b                   	pop    %ebx
  80282d:	5e                   	pop    %esi
  80282e:	5f                   	pop    %edi
  80282f:	5d                   	pop    %ebp
  802830:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  802831:	83 ec 0c             	sub    $0xc,%esp
  802834:	50                   	push   %eax
  802835:	6a 0d                	push   $0xd
  802837:	68 ff 41 80 00       	push   $0x8041ff
  80283c:	6a 23                	push   $0x23
  80283e:	68 1c 42 80 00       	push   $0x80421c
  802843:	e8 1c f3 ff ff       	call   801b64 <_panic>

00802848 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802848:	55                   	push   %ebp
  802849:	89 e5                	mov    %esp,%ebp
  80284b:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80284e:	83 3d 10 a0 80 00 00 	cmpl   $0x0,0x80a010
  802855:	74 0a                	je     802861 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler %e",r);
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
	}
       
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802857:	8b 45 08             	mov    0x8(%ebp),%eax
  80285a:	a3 10 a0 80 00       	mov    %eax,0x80a010
}
  80285f:	c9                   	leave  
  802860:	c3                   	ret    
		if((r=sys_page_alloc(thisenv->env_id,(void *)UXSTACKTOP-PGSIZE,PTE_P|PTE_W|PTE_U))<0)
  802861:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802866:	8b 40 48             	mov    0x48(%eax),%eax
  802869:	83 ec 04             	sub    $0x4,%esp
  80286c:	6a 07                	push   $0x7
  80286e:	68 00 f0 bf ee       	push   $0xeebff000
  802873:	50                   	push   %eax
  802874:	e8 de fd ff ff       	call   802657 <sys_page_alloc>
  802879:	83 c4 10             	add    $0x10,%esp
  80287c:	85 c0                	test   %eax,%eax
  80287e:	78 1b                	js     80289b <set_pgfault_handler+0x53>
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
  802880:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802885:	8b 40 48             	mov    0x48(%eax),%eax
  802888:	83 ec 08             	sub    $0x8,%esp
  80288b:	68 ad 28 80 00       	push   $0x8028ad
  802890:	50                   	push   %eax
  802891:	e8 0c ff ff ff       	call   8027a2 <sys_env_set_pgfault_upcall>
  802896:	83 c4 10             	add    $0x10,%esp
  802899:	eb bc                	jmp    802857 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler %e",r);
  80289b:	50                   	push   %eax
  80289c:	68 2a 42 80 00       	push   $0x80422a
  8028a1:	6a 22                	push   $0x22
  8028a3:	68 41 42 80 00       	push   $0x804241
  8028a8:	e8 b7 f2 ff ff       	call   801b64 <_panic>

008028ad <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8028ad:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8028ae:	a1 10 a0 80 00       	mov    0x80a010,%eax
	call *%eax
  8028b3:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8028b5:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 48(%esp), %ebp
  8028b8:	8b 6c 24 30          	mov    0x30(%esp),%ebp
        subl $4, %ebp
  8028bc:	83 ed 04             	sub    $0x4,%ebp
        movl %ebp, 48(%esp)
  8028bf:	89 6c 24 30          	mov    %ebp,0x30(%esp)
        movl 40(%esp), %eax
  8028c3:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl %eax, (%ebp)
  8028c7:	89 45 00             	mov    %eax,0x0(%ebp)
	// Restore the trap-time registers.  After you do this, you
 	// can no longer modify any general-purpose registers.
 	// LAB 4: Your code here.
        addl $8, %esp
  8028ca:	83 c4 08             	add    $0x8,%esp
        popal
  8028cd:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $4, %esp
  8028ce:	83 c4 04             	add    $0x4,%esp
        popfl
  8028d1:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  8028d2:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  8028d3:	c3                   	ret    

008028d4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8028d4:	55                   	push   %ebp
  8028d5:	89 e5                	mov    %esp,%ebp
  8028d7:	56                   	push   %esi
  8028d8:	53                   	push   %ebx
  8028d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8028dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8028df:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        //	panic("ipc_recv not implemented");
        int r;
       	if(pg!=NULL){
  8028e2:	85 c0                	test   %eax,%eax
  8028e4:	74 3b                	je     802921 <ipc_recv+0x4d>
	  r = sys_ipc_recv(pg);
  8028e6:	83 ec 0c             	sub    $0xc,%esp
  8028e9:	50                   	push   %eax
  8028ea:	e8 18 ff ff ff       	call   802807 <sys_ipc_recv>
  8028ef:	83 c4 10             	add    $0x10,%esp
	}else
	  r = sys_ipc_recv((void *)UTOP);
	if(r<0){
  8028f2:	85 c0                	test   %eax,%eax
  8028f4:	78 3d                	js     802933 <ipc_recv+0x5f>
	if(perm_store!=NULL){
		*perm_store = 0;
            }
        	return r;
           }else{
	     if(from_env_store!=NULL)
  8028f6:	85 f6                	test   %esi,%esi
  8028f8:	74 0a                	je     802904 <ipc_recv+0x30>
		     *from_env_store = thisenv->env_ipc_from;
  8028fa:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8028ff:	8b 40 74             	mov    0x74(%eax),%eax
  802902:	89 06                	mov    %eax,(%esi)
	     if(perm_store != NULL)
  802904:	85 db                	test   %ebx,%ebx
  802906:	74 0a                	je     802912 <ipc_recv+0x3e>
		     *perm_store = thisenv->env_ipc_perm;
  802908:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  80290d:	8b 40 78             	mov    0x78(%eax),%eax
  802910:	89 03                	mov    %eax,(%ebx)
	     return thisenv->env_ipc_value;
  802912:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802917:	8b 40 70             	mov    0x70(%eax),%eax
	   }

}
  80291a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80291d:	5b                   	pop    %ebx
  80291e:	5e                   	pop    %esi
  80291f:	5d                   	pop    %ebp
  802920:	c3                   	ret    
	  r = sys_ipc_recv((void *)UTOP);
  802921:	83 ec 0c             	sub    $0xc,%esp
  802924:	68 00 00 c0 ee       	push   $0xeec00000
  802929:	e8 d9 fe ff ff       	call   802807 <sys_ipc_recv>
  80292e:	83 c4 10             	add    $0x10,%esp
  802931:	eb bf                	jmp    8028f2 <ipc_recv+0x1e>
	if(from_env_store!=NULL){
  802933:	85 f6                	test   %esi,%esi
  802935:	74 06                	je     80293d <ipc_recv+0x69>
	  *from_env_store = 0;
  802937:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if(perm_store!=NULL){
  80293d:	85 db                	test   %ebx,%ebx
  80293f:	74 d9                	je     80291a <ipc_recv+0x46>
		*perm_store = 0;
  802941:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802947:	eb d1                	jmp    80291a <ipc_recv+0x46>

00802949 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802949:	55                   	push   %ebp
  80294a:	89 e5                	mov    %esp,%ebp
  80294c:	57                   	push   %edi
  80294d:	56                   	push   %esi
  80294e:	53                   	push   %ebx
  80294f:	83 ec 0c             	sub    $0xc,%esp
  802952:	8b 7d 08             	mov    0x8(%ebp),%edi
  802955:	8b 75 0c             	mov    0xc(%ebp),%esi
  802958:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if(pg==NULL) pg = (void *)UTOP;
  80295b:	85 db                	test   %ebx,%ebx
  80295d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802962:	0f 44 d8             	cmove  %eax,%ebx
	while((r=sys_ipc_try_send(to_env,val,pg,perm))<0){
  802965:	ff 75 14             	pushl  0x14(%ebp)
  802968:	53                   	push   %ebx
  802969:	56                   	push   %esi
  80296a:	57                   	push   %edi
  80296b:	e8 74 fe ff ff       	call   8027e4 <sys_ipc_try_send>
  802970:	83 c4 10             	add    $0x10,%esp
  802973:	85 c0                	test   %eax,%eax
  802975:	79 20                	jns    802997 <ipc_send+0x4e>
	    if(r!=-E_IPC_NOT_RECV){
  802977:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80297a:	75 07                	jne    802983 <ipc_send+0x3a>
		    panic("ipc_send:send message failed\n");
	    }
	    sys_yield();
  80297c:	e8 b7 fc ff ff       	call   802638 <sys_yield>
  802981:	eb e2                	jmp    802965 <ipc_send+0x1c>
		    panic("ipc_send:send message failed\n");
  802983:	83 ec 04             	sub    $0x4,%esp
  802986:	68 4f 42 80 00       	push   $0x80424f
  80298b:	6a 43                	push   $0x43
  80298d:	68 6d 42 80 00       	push   $0x80426d
  802992:	e8 cd f1 ff ff       	call   801b64 <_panic>
	}

}
  802997:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80299a:	5b                   	pop    %ebx
  80299b:	5e                   	pop    %esi
  80299c:	5f                   	pop    %edi
  80299d:	5d                   	pop    %ebp
  80299e:	c3                   	ret    

0080299f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80299f:	55                   	push   %ebp
  8029a0:	89 e5                	mov    %esp,%ebp
  8029a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8029a5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8029aa:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8029ad:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8029b3:	8b 52 50             	mov    0x50(%edx),%edx
  8029b6:	39 ca                	cmp    %ecx,%edx
  8029b8:	74 11                	je     8029cb <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  8029ba:	83 c0 01             	add    $0x1,%eax
  8029bd:	3d 00 04 00 00       	cmp    $0x400,%eax
  8029c2:	75 e6                	jne    8029aa <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8029c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8029c9:	eb 0b                	jmp    8029d6 <ipc_find_env+0x37>
			return envs[i].env_id;
  8029cb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8029ce:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8029d3:	8b 40 48             	mov    0x48(%eax),%eax
}
  8029d6:	5d                   	pop    %ebp
  8029d7:	c3                   	ret    

008029d8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8029d8:	55                   	push   %ebp
  8029d9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8029db:	8b 45 08             	mov    0x8(%ebp),%eax
  8029de:	05 00 00 00 30       	add    $0x30000000,%eax
  8029e3:	c1 e8 0c             	shr    $0xc,%eax
}
  8029e6:	5d                   	pop    %ebp
  8029e7:	c3                   	ret    

008029e8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8029e8:	55                   	push   %ebp
  8029e9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8029eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8029ee:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8029f3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8029f8:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8029fd:	5d                   	pop    %ebp
  8029fe:	c3                   	ret    

008029ff <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8029ff:	55                   	push   %ebp
  802a00:	89 e5                	mov    %esp,%ebp
  802a02:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802a05:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  802a0a:	89 c2                	mov    %eax,%edx
  802a0c:	c1 ea 16             	shr    $0x16,%edx
  802a0f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802a16:	f6 c2 01             	test   $0x1,%dl
  802a19:	74 2a                	je     802a45 <fd_alloc+0x46>
  802a1b:	89 c2                	mov    %eax,%edx
  802a1d:	c1 ea 0c             	shr    $0xc,%edx
  802a20:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802a27:	f6 c2 01             	test   $0x1,%dl
  802a2a:	74 19                	je     802a45 <fd_alloc+0x46>
  802a2c:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  802a31:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  802a36:	75 d2                	jne    802a0a <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  802a38:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  802a3e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  802a43:	eb 07                	jmp    802a4c <fd_alloc+0x4d>
			*fd_store = fd;
  802a45:	89 01                	mov    %eax,(%ecx)
			return 0;
  802a47:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802a4c:	5d                   	pop    %ebp
  802a4d:	c3                   	ret    

00802a4e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  802a4e:	55                   	push   %ebp
  802a4f:	89 e5                	mov    %esp,%ebp
  802a51:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  802a54:	83 f8 1f             	cmp    $0x1f,%eax
  802a57:	77 36                	ja     802a8f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  802a59:	c1 e0 0c             	shl    $0xc,%eax
  802a5c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  802a61:	89 c2                	mov    %eax,%edx
  802a63:	c1 ea 16             	shr    $0x16,%edx
  802a66:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802a6d:	f6 c2 01             	test   $0x1,%dl
  802a70:	74 24                	je     802a96 <fd_lookup+0x48>
  802a72:	89 c2                	mov    %eax,%edx
  802a74:	c1 ea 0c             	shr    $0xc,%edx
  802a77:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802a7e:	f6 c2 01             	test   $0x1,%dl
  802a81:	74 1a                	je     802a9d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  802a83:	8b 55 0c             	mov    0xc(%ebp),%edx
  802a86:	89 02                	mov    %eax,(%edx)
	return 0;
  802a88:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802a8d:	5d                   	pop    %ebp
  802a8e:	c3                   	ret    
		return -E_INVAL;
  802a8f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802a94:	eb f7                	jmp    802a8d <fd_lookup+0x3f>
		return -E_INVAL;
  802a96:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802a9b:	eb f0                	jmp    802a8d <fd_lookup+0x3f>
  802a9d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802aa2:	eb e9                	jmp    802a8d <fd_lookup+0x3f>

00802aa4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  802aa4:	55                   	push   %ebp
  802aa5:	89 e5                	mov    %esp,%ebp
  802aa7:	83 ec 08             	sub    $0x8,%esp
  802aaa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802aad:	ba f8 42 80 00       	mov    $0x8042f8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  802ab2:	b8 64 90 80 00       	mov    $0x809064,%eax
		if (devtab[i]->dev_id == dev_id) {
  802ab7:	39 08                	cmp    %ecx,(%eax)
  802ab9:	74 33                	je     802aee <dev_lookup+0x4a>
  802abb:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  802abe:	8b 02                	mov    (%edx),%eax
  802ac0:	85 c0                	test   %eax,%eax
  802ac2:	75 f3                	jne    802ab7 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  802ac4:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802ac9:	8b 40 48             	mov    0x48(%eax),%eax
  802acc:	83 ec 04             	sub    $0x4,%esp
  802acf:	51                   	push   %ecx
  802ad0:	50                   	push   %eax
  802ad1:	68 78 42 80 00       	push   $0x804278
  802ad6:	e8 64 f1 ff ff       	call   801c3f <cprintf>
	*dev = 0;
  802adb:	8b 45 0c             	mov    0xc(%ebp),%eax
  802ade:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  802ae4:	83 c4 10             	add    $0x10,%esp
  802ae7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  802aec:	c9                   	leave  
  802aed:	c3                   	ret    
			*dev = devtab[i];
  802aee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802af1:	89 01                	mov    %eax,(%ecx)
			return 0;
  802af3:	b8 00 00 00 00       	mov    $0x0,%eax
  802af8:	eb f2                	jmp    802aec <dev_lookup+0x48>

00802afa <fd_close>:
{
  802afa:	55                   	push   %ebp
  802afb:	89 e5                	mov    %esp,%ebp
  802afd:	57                   	push   %edi
  802afe:	56                   	push   %esi
  802aff:	53                   	push   %ebx
  802b00:	83 ec 1c             	sub    $0x1c,%esp
  802b03:	8b 75 08             	mov    0x8(%ebp),%esi
  802b06:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802b09:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802b0c:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  802b0d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  802b13:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802b16:	50                   	push   %eax
  802b17:	e8 32 ff ff ff       	call   802a4e <fd_lookup>
  802b1c:	89 c3                	mov    %eax,%ebx
  802b1e:	83 c4 08             	add    $0x8,%esp
  802b21:	85 c0                	test   %eax,%eax
  802b23:	78 05                	js     802b2a <fd_close+0x30>
	    || fd != fd2)
  802b25:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  802b28:	74 16                	je     802b40 <fd_close+0x46>
		return (must_exist ? r : 0);
  802b2a:	89 f8                	mov    %edi,%eax
  802b2c:	84 c0                	test   %al,%al
  802b2e:	b8 00 00 00 00       	mov    $0x0,%eax
  802b33:	0f 44 d8             	cmove  %eax,%ebx
}
  802b36:	89 d8                	mov    %ebx,%eax
  802b38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802b3b:	5b                   	pop    %ebx
  802b3c:	5e                   	pop    %esi
  802b3d:	5f                   	pop    %edi
  802b3e:	5d                   	pop    %ebp
  802b3f:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  802b40:	83 ec 08             	sub    $0x8,%esp
  802b43:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802b46:	50                   	push   %eax
  802b47:	ff 36                	pushl  (%esi)
  802b49:	e8 56 ff ff ff       	call   802aa4 <dev_lookup>
  802b4e:	89 c3                	mov    %eax,%ebx
  802b50:	83 c4 10             	add    $0x10,%esp
  802b53:	85 c0                	test   %eax,%eax
  802b55:	78 15                	js     802b6c <fd_close+0x72>
		if (dev->dev_close)
  802b57:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802b5a:	8b 40 10             	mov    0x10(%eax),%eax
  802b5d:	85 c0                	test   %eax,%eax
  802b5f:	74 1b                	je     802b7c <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  802b61:	83 ec 0c             	sub    $0xc,%esp
  802b64:	56                   	push   %esi
  802b65:	ff d0                	call   *%eax
  802b67:	89 c3                	mov    %eax,%ebx
  802b69:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  802b6c:	83 ec 08             	sub    $0x8,%esp
  802b6f:	56                   	push   %esi
  802b70:	6a 00                	push   $0x0
  802b72:	e8 65 fb ff ff       	call   8026dc <sys_page_unmap>
	return r;
  802b77:	83 c4 10             	add    $0x10,%esp
  802b7a:	eb ba                	jmp    802b36 <fd_close+0x3c>
			r = 0;
  802b7c:	bb 00 00 00 00       	mov    $0x0,%ebx
  802b81:	eb e9                	jmp    802b6c <fd_close+0x72>

00802b83 <close>:

int
close(int fdnum)
{
  802b83:	55                   	push   %ebp
  802b84:	89 e5                	mov    %esp,%ebp
  802b86:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802b89:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802b8c:	50                   	push   %eax
  802b8d:	ff 75 08             	pushl  0x8(%ebp)
  802b90:	e8 b9 fe ff ff       	call   802a4e <fd_lookup>
  802b95:	83 c4 08             	add    $0x8,%esp
  802b98:	85 c0                	test   %eax,%eax
  802b9a:	78 10                	js     802bac <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  802b9c:	83 ec 08             	sub    $0x8,%esp
  802b9f:	6a 01                	push   $0x1
  802ba1:	ff 75 f4             	pushl  -0xc(%ebp)
  802ba4:	e8 51 ff ff ff       	call   802afa <fd_close>
  802ba9:	83 c4 10             	add    $0x10,%esp
}
  802bac:	c9                   	leave  
  802bad:	c3                   	ret    

00802bae <close_all>:

void
close_all(void)
{
  802bae:	55                   	push   %ebp
  802baf:	89 e5                	mov    %esp,%ebp
  802bb1:	53                   	push   %ebx
  802bb2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  802bb5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  802bba:	83 ec 0c             	sub    $0xc,%esp
  802bbd:	53                   	push   %ebx
  802bbe:	e8 c0 ff ff ff       	call   802b83 <close>
	for (i = 0; i < MAXFD; i++)
  802bc3:	83 c3 01             	add    $0x1,%ebx
  802bc6:	83 c4 10             	add    $0x10,%esp
  802bc9:	83 fb 20             	cmp    $0x20,%ebx
  802bcc:	75 ec                	jne    802bba <close_all+0xc>
}
  802bce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802bd1:	c9                   	leave  
  802bd2:	c3                   	ret    

00802bd3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  802bd3:	55                   	push   %ebp
  802bd4:	89 e5                	mov    %esp,%ebp
  802bd6:	57                   	push   %edi
  802bd7:	56                   	push   %esi
  802bd8:	53                   	push   %ebx
  802bd9:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  802bdc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802bdf:	50                   	push   %eax
  802be0:	ff 75 08             	pushl  0x8(%ebp)
  802be3:	e8 66 fe ff ff       	call   802a4e <fd_lookup>
  802be8:	89 c3                	mov    %eax,%ebx
  802bea:	83 c4 08             	add    $0x8,%esp
  802bed:	85 c0                	test   %eax,%eax
  802bef:	0f 88 81 00 00 00    	js     802c76 <dup+0xa3>
		return r;
	close(newfdnum);
  802bf5:	83 ec 0c             	sub    $0xc,%esp
  802bf8:	ff 75 0c             	pushl  0xc(%ebp)
  802bfb:	e8 83 ff ff ff       	call   802b83 <close>

	newfd = INDEX2FD(newfdnum);
  802c00:	8b 75 0c             	mov    0xc(%ebp),%esi
  802c03:	c1 e6 0c             	shl    $0xc,%esi
  802c06:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  802c0c:	83 c4 04             	add    $0x4,%esp
  802c0f:	ff 75 e4             	pushl  -0x1c(%ebp)
  802c12:	e8 d1 fd ff ff       	call   8029e8 <fd2data>
  802c17:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  802c19:	89 34 24             	mov    %esi,(%esp)
  802c1c:	e8 c7 fd ff ff       	call   8029e8 <fd2data>
  802c21:	83 c4 10             	add    $0x10,%esp
  802c24:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  802c26:	89 d8                	mov    %ebx,%eax
  802c28:	c1 e8 16             	shr    $0x16,%eax
  802c2b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802c32:	a8 01                	test   $0x1,%al
  802c34:	74 11                	je     802c47 <dup+0x74>
  802c36:	89 d8                	mov    %ebx,%eax
  802c38:	c1 e8 0c             	shr    $0xc,%eax
  802c3b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802c42:	f6 c2 01             	test   $0x1,%dl
  802c45:	75 39                	jne    802c80 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802c47:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  802c4a:	89 d0                	mov    %edx,%eax
  802c4c:	c1 e8 0c             	shr    $0xc,%eax
  802c4f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802c56:	83 ec 0c             	sub    $0xc,%esp
  802c59:	25 07 0e 00 00       	and    $0xe07,%eax
  802c5e:	50                   	push   %eax
  802c5f:	56                   	push   %esi
  802c60:	6a 00                	push   $0x0
  802c62:	52                   	push   %edx
  802c63:	6a 00                	push   $0x0
  802c65:	e8 30 fa ff ff       	call   80269a <sys_page_map>
  802c6a:	89 c3                	mov    %eax,%ebx
  802c6c:	83 c4 20             	add    $0x20,%esp
  802c6f:	85 c0                	test   %eax,%eax
  802c71:	78 31                	js     802ca4 <dup+0xd1>
		goto err;

	return newfdnum;
  802c73:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  802c76:	89 d8                	mov    %ebx,%eax
  802c78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802c7b:	5b                   	pop    %ebx
  802c7c:	5e                   	pop    %esi
  802c7d:	5f                   	pop    %edi
  802c7e:	5d                   	pop    %ebp
  802c7f:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  802c80:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802c87:	83 ec 0c             	sub    $0xc,%esp
  802c8a:	25 07 0e 00 00       	and    $0xe07,%eax
  802c8f:	50                   	push   %eax
  802c90:	57                   	push   %edi
  802c91:	6a 00                	push   $0x0
  802c93:	53                   	push   %ebx
  802c94:	6a 00                	push   $0x0
  802c96:	e8 ff f9 ff ff       	call   80269a <sys_page_map>
  802c9b:	89 c3                	mov    %eax,%ebx
  802c9d:	83 c4 20             	add    $0x20,%esp
  802ca0:	85 c0                	test   %eax,%eax
  802ca2:	79 a3                	jns    802c47 <dup+0x74>
	sys_page_unmap(0, newfd);
  802ca4:	83 ec 08             	sub    $0x8,%esp
  802ca7:	56                   	push   %esi
  802ca8:	6a 00                	push   $0x0
  802caa:	e8 2d fa ff ff       	call   8026dc <sys_page_unmap>
	sys_page_unmap(0, nva);
  802caf:	83 c4 08             	add    $0x8,%esp
  802cb2:	57                   	push   %edi
  802cb3:	6a 00                	push   $0x0
  802cb5:	e8 22 fa ff ff       	call   8026dc <sys_page_unmap>
	return r;
  802cba:	83 c4 10             	add    $0x10,%esp
  802cbd:	eb b7                	jmp    802c76 <dup+0xa3>

00802cbf <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  802cbf:	55                   	push   %ebp
  802cc0:	89 e5                	mov    %esp,%ebp
  802cc2:	53                   	push   %ebx
  802cc3:	83 ec 14             	sub    $0x14,%esp
  802cc6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802cc9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802ccc:	50                   	push   %eax
  802ccd:	53                   	push   %ebx
  802cce:	e8 7b fd ff ff       	call   802a4e <fd_lookup>
  802cd3:	83 c4 08             	add    $0x8,%esp
  802cd6:	85 c0                	test   %eax,%eax
  802cd8:	78 3f                	js     802d19 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802cda:	83 ec 08             	sub    $0x8,%esp
  802cdd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802ce0:	50                   	push   %eax
  802ce1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802ce4:	ff 30                	pushl  (%eax)
  802ce6:	e8 b9 fd ff ff       	call   802aa4 <dev_lookup>
  802ceb:	83 c4 10             	add    $0x10,%esp
  802cee:	85 c0                	test   %eax,%eax
  802cf0:	78 27                	js     802d19 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802cf2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802cf5:	8b 42 08             	mov    0x8(%edx),%eax
  802cf8:	83 e0 03             	and    $0x3,%eax
  802cfb:	83 f8 01             	cmp    $0x1,%eax
  802cfe:	74 1e                	je     802d1e <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  802d00:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d03:	8b 40 08             	mov    0x8(%eax),%eax
  802d06:	85 c0                	test   %eax,%eax
  802d08:	74 35                	je     802d3f <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  802d0a:	83 ec 04             	sub    $0x4,%esp
  802d0d:	ff 75 10             	pushl  0x10(%ebp)
  802d10:	ff 75 0c             	pushl  0xc(%ebp)
  802d13:	52                   	push   %edx
  802d14:	ff d0                	call   *%eax
  802d16:	83 c4 10             	add    $0x10,%esp
}
  802d19:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802d1c:	c9                   	leave  
  802d1d:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802d1e:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802d23:	8b 40 48             	mov    0x48(%eax),%eax
  802d26:	83 ec 04             	sub    $0x4,%esp
  802d29:	53                   	push   %ebx
  802d2a:	50                   	push   %eax
  802d2b:	68 bc 42 80 00       	push   $0x8042bc
  802d30:	e8 0a ef ff ff       	call   801c3f <cprintf>
		return -E_INVAL;
  802d35:	83 c4 10             	add    $0x10,%esp
  802d38:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802d3d:	eb da                	jmp    802d19 <read+0x5a>
		return -E_NOT_SUPP;
  802d3f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802d44:	eb d3                	jmp    802d19 <read+0x5a>

00802d46 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  802d46:	55                   	push   %ebp
  802d47:	89 e5                	mov    %esp,%ebp
  802d49:	57                   	push   %edi
  802d4a:	56                   	push   %esi
  802d4b:	53                   	push   %ebx
  802d4c:	83 ec 0c             	sub    $0xc,%esp
  802d4f:	8b 7d 08             	mov    0x8(%ebp),%edi
  802d52:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802d55:	bb 00 00 00 00       	mov    $0x0,%ebx
  802d5a:	39 f3                	cmp    %esi,%ebx
  802d5c:	73 25                	jae    802d83 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802d5e:	83 ec 04             	sub    $0x4,%esp
  802d61:	89 f0                	mov    %esi,%eax
  802d63:	29 d8                	sub    %ebx,%eax
  802d65:	50                   	push   %eax
  802d66:	89 d8                	mov    %ebx,%eax
  802d68:	03 45 0c             	add    0xc(%ebp),%eax
  802d6b:	50                   	push   %eax
  802d6c:	57                   	push   %edi
  802d6d:	e8 4d ff ff ff       	call   802cbf <read>
		if (m < 0)
  802d72:	83 c4 10             	add    $0x10,%esp
  802d75:	85 c0                	test   %eax,%eax
  802d77:	78 08                	js     802d81 <readn+0x3b>
			return m;
		if (m == 0)
  802d79:	85 c0                	test   %eax,%eax
  802d7b:	74 06                	je     802d83 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  802d7d:	01 c3                	add    %eax,%ebx
  802d7f:	eb d9                	jmp    802d5a <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802d81:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  802d83:	89 d8                	mov    %ebx,%eax
  802d85:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802d88:	5b                   	pop    %ebx
  802d89:	5e                   	pop    %esi
  802d8a:	5f                   	pop    %edi
  802d8b:	5d                   	pop    %ebp
  802d8c:	c3                   	ret    

00802d8d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802d8d:	55                   	push   %ebp
  802d8e:	89 e5                	mov    %esp,%ebp
  802d90:	53                   	push   %ebx
  802d91:	83 ec 14             	sub    $0x14,%esp
  802d94:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802d97:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802d9a:	50                   	push   %eax
  802d9b:	53                   	push   %ebx
  802d9c:	e8 ad fc ff ff       	call   802a4e <fd_lookup>
  802da1:	83 c4 08             	add    $0x8,%esp
  802da4:	85 c0                	test   %eax,%eax
  802da6:	78 3a                	js     802de2 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802da8:	83 ec 08             	sub    $0x8,%esp
  802dab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802dae:	50                   	push   %eax
  802daf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802db2:	ff 30                	pushl  (%eax)
  802db4:	e8 eb fc ff ff       	call   802aa4 <dev_lookup>
  802db9:	83 c4 10             	add    $0x10,%esp
  802dbc:	85 c0                	test   %eax,%eax
  802dbe:	78 22                	js     802de2 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802dc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802dc3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802dc7:	74 1e                	je     802de7 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802dc9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802dcc:	8b 52 0c             	mov    0xc(%edx),%edx
  802dcf:	85 d2                	test   %edx,%edx
  802dd1:	74 35                	je     802e08 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802dd3:	83 ec 04             	sub    $0x4,%esp
  802dd6:	ff 75 10             	pushl  0x10(%ebp)
  802dd9:	ff 75 0c             	pushl  0xc(%ebp)
  802ddc:	50                   	push   %eax
  802ddd:	ff d2                	call   *%edx
  802ddf:	83 c4 10             	add    $0x10,%esp
}
  802de2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802de5:	c9                   	leave  
  802de6:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802de7:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802dec:	8b 40 48             	mov    0x48(%eax),%eax
  802def:	83 ec 04             	sub    $0x4,%esp
  802df2:	53                   	push   %ebx
  802df3:	50                   	push   %eax
  802df4:	68 d8 42 80 00       	push   $0x8042d8
  802df9:	e8 41 ee ff ff       	call   801c3f <cprintf>
		return -E_INVAL;
  802dfe:	83 c4 10             	add    $0x10,%esp
  802e01:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802e06:	eb da                	jmp    802de2 <write+0x55>
		return -E_NOT_SUPP;
  802e08:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802e0d:	eb d3                	jmp    802de2 <write+0x55>

00802e0f <seek>:

int
seek(int fdnum, off_t offset)
{
  802e0f:	55                   	push   %ebp
  802e10:	89 e5                	mov    %esp,%ebp
  802e12:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802e15:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802e18:	50                   	push   %eax
  802e19:	ff 75 08             	pushl  0x8(%ebp)
  802e1c:	e8 2d fc ff ff       	call   802a4e <fd_lookup>
  802e21:	83 c4 08             	add    $0x8,%esp
  802e24:	85 c0                	test   %eax,%eax
  802e26:	78 0e                	js     802e36 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  802e28:	8b 55 0c             	mov    0xc(%ebp),%edx
  802e2b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802e2e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802e31:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802e36:	c9                   	leave  
  802e37:	c3                   	ret    

00802e38 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802e38:	55                   	push   %ebp
  802e39:	89 e5                	mov    %esp,%ebp
  802e3b:	53                   	push   %ebx
  802e3c:	83 ec 14             	sub    $0x14,%esp
  802e3f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802e42:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802e45:	50                   	push   %eax
  802e46:	53                   	push   %ebx
  802e47:	e8 02 fc ff ff       	call   802a4e <fd_lookup>
  802e4c:	83 c4 08             	add    $0x8,%esp
  802e4f:	85 c0                	test   %eax,%eax
  802e51:	78 37                	js     802e8a <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802e53:	83 ec 08             	sub    $0x8,%esp
  802e56:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802e59:	50                   	push   %eax
  802e5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802e5d:	ff 30                	pushl  (%eax)
  802e5f:	e8 40 fc ff ff       	call   802aa4 <dev_lookup>
  802e64:	83 c4 10             	add    $0x10,%esp
  802e67:	85 c0                	test   %eax,%eax
  802e69:	78 1f                	js     802e8a <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802e6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802e6e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802e72:	74 1b                	je     802e8f <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  802e74:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802e77:	8b 52 18             	mov    0x18(%edx),%edx
  802e7a:	85 d2                	test   %edx,%edx
  802e7c:	74 32                	je     802eb0 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802e7e:	83 ec 08             	sub    $0x8,%esp
  802e81:	ff 75 0c             	pushl  0xc(%ebp)
  802e84:	50                   	push   %eax
  802e85:	ff d2                	call   *%edx
  802e87:	83 c4 10             	add    $0x10,%esp
}
  802e8a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802e8d:	c9                   	leave  
  802e8e:	c3                   	ret    
			thisenv->env_id, fdnum);
  802e8f:	a1 0c a0 80 00       	mov    0x80a00c,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802e94:	8b 40 48             	mov    0x48(%eax),%eax
  802e97:	83 ec 04             	sub    $0x4,%esp
  802e9a:	53                   	push   %ebx
  802e9b:	50                   	push   %eax
  802e9c:	68 98 42 80 00       	push   $0x804298
  802ea1:	e8 99 ed ff ff       	call   801c3f <cprintf>
		return -E_INVAL;
  802ea6:	83 c4 10             	add    $0x10,%esp
  802ea9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802eae:	eb da                	jmp    802e8a <ftruncate+0x52>
		return -E_NOT_SUPP;
  802eb0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802eb5:	eb d3                	jmp    802e8a <ftruncate+0x52>

00802eb7 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802eb7:	55                   	push   %ebp
  802eb8:	89 e5                	mov    %esp,%ebp
  802eba:	53                   	push   %ebx
  802ebb:	83 ec 14             	sub    $0x14,%esp
  802ebe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802ec1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802ec4:	50                   	push   %eax
  802ec5:	ff 75 08             	pushl  0x8(%ebp)
  802ec8:	e8 81 fb ff ff       	call   802a4e <fd_lookup>
  802ecd:	83 c4 08             	add    $0x8,%esp
  802ed0:	85 c0                	test   %eax,%eax
  802ed2:	78 4b                	js     802f1f <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802ed4:	83 ec 08             	sub    $0x8,%esp
  802ed7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802eda:	50                   	push   %eax
  802edb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802ede:	ff 30                	pushl  (%eax)
  802ee0:	e8 bf fb ff ff       	call   802aa4 <dev_lookup>
  802ee5:	83 c4 10             	add    $0x10,%esp
  802ee8:	85 c0                	test   %eax,%eax
  802eea:	78 33                	js     802f1f <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  802eec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802eef:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802ef3:	74 2f                	je     802f24 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802ef5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802ef8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802eff:	00 00 00 
	stat->st_isdir = 0;
  802f02:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802f09:	00 00 00 
	stat->st_dev = dev;
  802f0c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802f12:	83 ec 08             	sub    $0x8,%esp
  802f15:	53                   	push   %ebx
  802f16:	ff 75 f0             	pushl  -0x10(%ebp)
  802f19:	ff 50 14             	call   *0x14(%eax)
  802f1c:	83 c4 10             	add    $0x10,%esp
}
  802f1f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802f22:	c9                   	leave  
  802f23:	c3                   	ret    
		return -E_NOT_SUPP;
  802f24:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802f29:	eb f4                	jmp    802f1f <fstat+0x68>

00802f2b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802f2b:	55                   	push   %ebp
  802f2c:	89 e5                	mov    %esp,%ebp
  802f2e:	56                   	push   %esi
  802f2f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802f30:	83 ec 08             	sub    $0x8,%esp
  802f33:	6a 00                	push   $0x0
  802f35:	ff 75 08             	pushl  0x8(%ebp)
  802f38:	e8 e7 01 00 00       	call   803124 <open>
  802f3d:	89 c3                	mov    %eax,%ebx
  802f3f:	83 c4 10             	add    $0x10,%esp
  802f42:	85 c0                	test   %eax,%eax
  802f44:	78 1b                	js     802f61 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802f46:	83 ec 08             	sub    $0x8,%esp
  802f49:	ff 75 0c             	pushl  0xc(%ebp)
  802f4c:	50                   	push   %eax
  802f4d:	e8 65 ff ff ff       	call   802eb7 <fstat>
  802f52:	89 c6                	mov    %eax,%esi
	close(fd);
  802f54:	89 1c 24             	mov    %ebx,(%esp)
  802f57:	e8 27 fc ff ff       	call   802b83 <close>
	return r;
  802f5c:	83 c4 10             	add    $0x10,%esp
  802f5f:	89 f3                	mov    %esi,%ebx
}
  802f61:	89 d8                	mov    %ebx,%eax
  802f63:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802f66:	5b                   	pop    %ebx
  802f67:	5e                   	pop    %esi
  802f68:	5d                   	pop    %ebp
  802f69:	c3                   	ret    

00802f6a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802f6a:	55                   	push   %ebp
  802f6b:	89 e5                	mov    %esp,%ebp
  802f6d:	56                   	push   %esi
  802f6e:	53                   	push   %ebx
  802f6f:	89 c6                	mov    %eax,%esi
  802f71:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  802f73:	83 3d 00 a0 80 00 00 	cmpl   $0x0,0x80a000
  802f7a:	74 27                	je     802fa3 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802f7c:	6a 07                	push   $0x7
  802f7e:	68 00 b0 80 00       	push   $0x80b000
  802f83:	56                   	push   %esi
  802f84:	ff 35 00 a0 80 00    	pushl  0x80a000
  802f8a:	e8 ba f9 ff ff       	call   802949 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802f8f:	83 c4 0c             	add    $0xc,%esp
  802f92:	6a 00                	push   $0x0
  802f94:	53                   	push   %ebx
  802f95:	6a 00                	push   $0x0
  802f97:	e8 38 f9 ff ff       	call   8028d4 <ipc_recv>
}
  802f9c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802f9f:	5b                   	pop    %ebx
  802fa0:	5e                   	pop    %esi
  802fa1:	5d                   	pop    %ebp
  802fa2:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802fa3:	83 ec 0c             	sub    $0xc,%esp
  802fa6:	6a 01                	push   $0x1
  802fa8:	e8 f2 f9 ff ff       	call   80299f <ipc_find_env>
  802fad:	a3 00 a0 80 00       	mov    %eax,0x80a000
  802fb2:	83 c4 10             	add    $0x10,%esp
  802fb5:	eb c5                	jmp    802f7c <fsipc+0x12>

00802fb7 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802fb7:	55                   	push   %ebp
  802fb8:	89 e5                	mov    %esp,%ebp
  802fba:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802fbd:	8b 45 08             	mov    0x8(%ebp),%eax
  802fc0:	8b 40 0c             	mov    0xc(%eax),%eax
  802fc3:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.set_size.req_size = newsize;
  802fc8:	8b 45 0c             	mov    0xc(%ebp),%eax
  802fcb:	a3 04 b0 80 00       	mov    %eax,0x80b004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802fd0:	ba 00 00 00 00       	mov    $0x0,%edx
  802fd5:	b8 02 00 00 00       	mov    $0x2,%eax
  802fda:	e8 8b ff ff ff       	call   802f6a <fsipc>
}
  802fdf:	c9                   	leave  
  802fe0:	c3                   	ret    

00802fe1 <devfile_flush>:
{
  802fe1:	55                   	push   %ebp
  802fe2:	89 e5                	mov    %esp,%ebp
  802fe4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802fe7:	8b 45 08             	mov    0x8(%ebp),%eax
  802fea:	8b 40 0c             	mov    0xc(%eax),%eax
  802fed:	a3 00 b0 80 00       	mov    %eax,0x80b000
	return fsipc(FSREQ_FLUSH, NULL);
  802ff2:	ba 00 00 00 00       	mov    $0x0,%edx
  802ff7:	b8 06 00 00 00       	mov    $0x6,%eax
  802ffc:	e8 69 ff ff ff       	call   802f6a <fsipc>
}
  803001:	c9                   	leave  
  803002:	c3                   	ret    

00803003 <devfile_stat>:
{
  803003:	55                   	push   %ebp
  803004:	89 e5                	mov    %esp,%ebp
  803006:	53                   	push   %ebx
  803007:	83 ec 04             	sub    $0x4,%esp
  80300a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80300d:	8b 45 08             	mov    0x8(%ebp),%eax
  803010:	8b 40 0c             	mov    0xc(%eax),%eax
  803013:	a3 00 b0 80 00       	mov    %eax,0x80b000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  803018:	ba 00 00 00 00       	mov    $0x0,%edx
  80301d:	b8 05 00 00 00       	mov    $0x5,%eax
  803022:	e8 43 ff ff ff       	call   802f6a <fsipc>
  803027:	85 c0                	test   %eax,%eax
  803029:	78 2c                	js     803057 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80302b:	83 ec 08             	sub    $0x8,%esp
  80302e:	68 00 b0 80 00       	push   $0x80b000
  803033:	53                   	push   %ebx
  803034:	e8 25 f2 ff ff       	call   80225e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  803039:	a1 80 b0 80 00       	mov    0x80b080,%eax
  80303e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  803044:	a1 84 b0 80 00       	mov    0x80b084,%eax
  803049:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80304f:	83 c4 10             	add    $0x10,%esp
  803052:	b8 00 00 00 00       	mov    $0x0,%eax
}
  803057:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80305a:	c9                   	leave  
  80305b:	c3                   	ret    

0080305c <devfile_write>:
{
  80305c:	55                   	push   %ebp
  80305d:	89 e5                	mov    %esp,%ebp
  80305f:	83 ec 0c             	sub    $0xc,%esp
  803062:	8b 45 10             	mov    0x10(%ebp),%eax
  803065:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80306a:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80306f:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  803072:	8b 55 08             	mov    0x8(%ebp),%edx
  803075:	8b 52 0c             	mov    0xc(%edx),%edx
  803078:	89 15 00 b0 80 00    	mov    %edx,0x80b000
	fsipcbuf.write.req_n = n;
  80307e:	a3 04 b0 80 00       	mov    %eax,0x80b004
	memmove(fsipcbuf.write.req_buf,buf,n);
  803083:	50                   	push   %eax
  803084:	ff 75 0c             	pushl  0xc(%ebp)
  803087:	68 08 b0 80 00       	push   $0x80b008
  80308c:	e8 5b f3 ff ff       	call   8023ec <memmove>
	if((r = fsipc(FSREQ_WRITE,NULL))<0)
  803091:	ba 00 00 00 00       	mov    $0x0,%edx
  803096:	b8 04 00 00 00       	mov    $0x4,%eax
  80309b:	e8 ca fe ff ff       	call   802f6a <fsipc>
}
  8030a0:	c9                   	leave  
  8030a1:	c3                   	ret    

008030a2 <devfile_read>:
{
  8030a2:	55                   	push   %ebp
  8030a3:	89 e5                	mov    %esp,%ebp
  8030a5:	56                   	push   %esi
  8030a6:	53                   	push   %ebx
  8030a7:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8030aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8030ad:	8b 40 0c             	mov    0xc(%eax),%eax
  8030b0:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.read.req_n = n;
  8030b5:	89 35 04 b0 80 00    	mov    %esi,0x80b004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8030bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8030c0:	b8 03 00 00 00       	mov    $0x3,%eax
  8030c5:	e8 a0 fe ff ff       	call   802f6a <fsipc>
  8030ca:	89 c3                	mov    %eax,%ebx
  8030cc:	85 c0                	test   %eax,%eax
  8030ce:	78 1f                	js     8030ef <devfile_read+0x4d>
	assert(r <= n);
  8030d0:	39 f0                	cmp    %esi,%eax
  8030d2:	77 24                	ja     8030f8 <devfile_read+0x56>
	assert(r <= PGSIZE);
  8030d4:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8030d9:	7f 33                	jg     80310e <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8030db:	83 ec 04             	sub    $0x4,%esp
  8030de:	50                   	push   %eax
  8030df:	68 00 b0 80 00       	push   $0x80b000
  8030e4:	ff 75 0c             	pushl  0xc(%ebp)
  8030e7:	e8 00 f3 ff ff       	call   8023ec <memmove>
	return r;
  8030ec:	83 c4 10             	add    $0x10,%esp
}
  8030ef:	89 d8                	mov    %ebx,%eax
  8030f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8030f4:	5b                   	pop    %ebx
  8030f5:	5e                   	pop    %esi
  8030f6:	5d                   	pop    %ebp
  8030f7:	c3                   	ret    
	assert(r <= n);
  8030f8:	68 08 43 80 00       	push   $0x804308
  8030fd:	68 5d 39 80 00       	push   $0x80395d
  803102:	6a 7c                	push   $0x7c
  803104:	68 0f 43 80 00       	push   $0x80430f
  803109:	e8 56 ea ff ff       	call   801b64 <_panic>
	assert(r <= PGSIZE);
  80310e:	68 1a 43 80 00       	push   $0x80431a
  803113:	68 5d 39 80 00       	push   $0x80395d
  803118:	6a 7d                	push   $0x7d
  80311a:	68 0f 43 80 00       	push   $0x80430f
  80311f:	e8 40 ea ff ff       	call   801b64 <_panic>

00803124 <open>:
{
  803124:	55                   	push   %ebp
  803125:	89 e5                	mov    %esp,%ebp
  803127:	56                   	push   %esi
  803128:	53                   	push   %ebx
  803129:	83 ec 1c             	sub    $0x1c,%esp
  80312c:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80312f:	56                   	push   %esi
  803130:	e8 f2 f0 ff ff       	call   802227 <strlen>
  803135:	83 c4 10             	add    $0x10,%esp
  803138:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80313d:	7f 6c                	jg     8031ab <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  80313f:	83 ec 0c             	sub    $0xc,%esp
  803142:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803145:	50                   	push   %eax
  803146:	e8 b4 f8 ff ff       	call   8029ff <fd_alloc>
  80314b:	89 c3                	mov    %eax,%ebx
  80314d:	83 c4 10             	add    $0x10,%esp
  803150:	85 c0                	test   %eax,%eax
  803152:	78 3c                	js     803190 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  803154:	83 ec 08             	sub    $0x8,%esp
  803157:	56                   	push   %esi
  803158:	68 00 b0 80 00       	push   $0x80b000
  80315d:	e8 fc f0 ff ff       	call   80225e <strcpy>
	fsipcbuf.open.req_omode = mode;
  803162:	8b 45 0c             	mov    0xc(%ebp),%eax
  803165:	a3 00 b4 80 00       	mov    %eax,0x80b400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80316a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80316d:	b8 01 00 00 00       	mov    $0x1,%eax
  803172:	e8 f3 fd ff ff       	call   802f6a <fsipc>
  803177:	89 c3                	mov    %eax,%ebx
  803179:	83 c4 10             	add    $0x10,%esp
  80317c:	85 c0                	test   %eax,%eax
  80317e:	78 19                	js     803199 <open+0x75>
	return fd2num(fd);
  803180:	83 ec 0c             	sub    $0xc,%esp
  803183:	ff 75 f4             	pushl  -0xc(%ebp)
  803186:	e8 4d f8 ff ff       	call   8029d8 <fd2num>
  80318b:	89 c3                	mov    %eax,%ebx
  80318d:	83 c4 10             	add    $0x10,%esp
}
  803190:	89 d8                	mov    %ebx,%eax
  803192:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803195:	5b                   	pop    %ebx
  803196:	5e                   	pop    %esi
  803197:	5d                   	pop    %ebp
  803198:	c3                   	ret    
		fd_close(fd, 0);
  803199:	83 ec 08             	sub    $0x8,%esp
  80319c:	6a 00                	push   $0x0
  80319e:	ff 75 f4             	pushl  -0xc(%ebp)
  8031a1:	e8 54 f9 ff ff       	call   802afa <fd_close>
		return r;
  8031a6:	83 c4 10             	add    $0x10,%esp
  8031a9:	eb e5                	jmp    803190 <open+0x6c>
		return -E_BAD_PATH;
  8031ab:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8031b0:	eb de                	jmp    803190 <open+0x6c>

008031b2 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8031b2:	55                   	push   %ebp
  8031b3:	89 e5                	mov    %esp,%ebp
  8031b5:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8031b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8031bd:	b8 08 00 00 00       	mov    $0x8,%eax
  8031c2:	e8 a3 fd ff ff       	call   802f6a <fsipc>
}
  8031c7:	c9                   	leave  
  8031c8:	c3                   	ret    

008031c9 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8031c9:	55                   	push   %ebp
  8031ca:	89 e5                	mov    %esp,%ebp
  8031cc:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8031cf:	89 d0                	mov    %edx,%eax
  8031d1:	c1 e8 16             	shr    $0x16,%eax
  8031d4:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8031db:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  8031e0:	f6 c1 01             	test   $0x1,%cl
  8031e3:	74 1d                	je     803202 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  8031e5:	c1 ea 0c             	shr    $0xc,%edx
  8031e8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8031ef:	f6 c2 01             	test   $0x1,%dl
  8031f2:	74 0e                	je     803202 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8031f4:	c1 ea 0c             	shr    $0xc,%edx
  8031f7:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8031fe:	ef 
  8031ff:	0f b7 c0             	movzwl %ax,%eax
}
  803202:	5d                   	pop    %ebp
  803203:	c3                   	ret    

00803204 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  803204:	55                   	push   %ebp
  803205:	89 e5                	mov    %esp,%ebp
  803207:	56                   	push   %esi
  803208:	53                   	push   %ebx
  803209:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80320c:	83 ec 0c             	sub    $0xc,%esp
  80320f:	ff 75 08             	pushl  0x8(%ebp)
  803212:	e8 d1 f7 ff ff       	call   8029e8 <fd2data>
  803217:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  803219:	83 c4 08             	add    $0x8,%esp
  80321c:	68 26 43 80 00       	push   $0x804326
  803221:	53                   	push   %ebx
  803222:	e8 37 f0 ff ff       	call   80225e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  803227:	8b 46 04             	mov    0x4(%esi),%eax
  80322a:	2b 06                	sub    (%esi),%eax
  80322c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  803232:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  803239:	00 00 00 
	stat->st_dev = &devpipe;
  80323c:	c7 83 88 00 00 00 80 	movl   $0x809080,0x88(%ebx)
  803243:	90 80 00 
	return 0;
}
  803246:	b8 00 00 00 00       	mov    $0x0,%eax
  80324b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80324e:	5b                   	pop    %ebx
  80324f:	5e                   	pop    %esi
  803250:	5d                   	pop    %ebp
  803251:	c3                   	ret    

00803252 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  803252:	55                   	push   %ebp
  803253:	89 e5                	mov    %esp,%ebp
  803255:	53                   	push   %ebx
  803256:	83 ec 0c             	sub    $0xc,%esp
  803259:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80325c:	53                   	push   %ebx
  80325d:	6a 00                	push   $0x0
  80325f:	e8 78 f4 ff ff       	call   8026dc <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  803264:	89 1c 24             	mov    %ebx,(%esp)
  803267:	e8 7c f7 ff ff       	call   8029e8 <fd2data>
  80326c:	83 c4 08             	add    $0x8,%esp
  80326f:	50                   	push   %eax
  803270:	6a 00                	push   $0x0
  803272:	e8 65 f4 ff ff       	call   8026dc <sys_page_unmap>
}
  803277:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80327a:	c9                   	leave  
  80327b:	c3                   	ret    

0080327c <_pipeisclosed>:
{
  80327c:	55                   	push   %ebp
  80327d:	89 e5                	mov    %esp,%ebp
  80327f:	57                   	push   %edi
  803280:	56                   	push   %esi
  803281:	53                   	push   %ebx
  803282:	83 ec 1c             	sub    $0x1c,%esp
  803285:	89 c7                	mov    %eax,%edi
  803287:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  803289:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  80328e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  803291:	83 ec 0c             	sub    $0xc,%esp
  803294:	57                   	push   %edi
  803295:	e8 2f ff ff ff       	call   8031c9 <pageref>
  80329a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80329d:	89 34 24             	mov    %esi,(%esp)
  8032a0:	e8 24 ff ff ff       	call   8031c9 <pageref>
		nn = thisenv->env_runs;
  8032a5:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  8032ab:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8032ae:	83 c4 10             	add    $0x10,%esp
  8032b1:	39 cb                	cmp    %ecx,%ebx
  8032b3:	74 1b                	je     8032d0 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8032b5:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8032b8:	75 cf                	jne    803289 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8032ba:	8b 42 58             	mov    0x58(%edx),%eax
  8032bd:	6a 01                	push   $0x1
  8032bf:	50                   	push   %eax
  8032c0:	53                   	push   %ebx
  8032c1:	68 2d 43 80 00       	push   $0x80432d
  8032c6:	e8 74 e9 ff ff       	call   801c3f <cprintf>
  8032cb:	83 c4 10             	add    $0x10,%esp
  8032ce:	eb b9                	jmp    803289 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8032d0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8032d3:	0f 94 c0             	sete   %al
  8032d6:	0f b6 c0             	movzbl %al,%eax
}
  8032d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8032dc:	5b                   	pop    %ebx
  8032dd:	5e                   	pop    %esi
  8032de:	5f                   	pop    %edi
  8032df:	5d                   	pop    %ebp
  8032e0:	c3                   	ret    

008032e1 <devpipe_write>:
{
  8032e1:	55                   	push   %ebp
  8032e2:	89 e5                	mov    %esp,%ebp
  8032e4:	57                   	push   %edi
  8032e5:	56                   	push   %esi
  8032e6:	53                   	push   %ebx
  8032e7:	83 ec 28             	sub    $0x28,%esp
  8032ea:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8032ed:	56                   	push   %esi
  8032ee:	e8 f5 f6 ff ff       	call   8029e8 <fd2data>
  8032f3:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8032f5:	83 c4 10             	add    $0x10,%esp
  8032f8:	bf 00 00 00 00       	mov    $0x0,%edi
  8032fd:	3b 7d 10             	cmp    0x10(%ebp),%edi
  803300:	74 4f                	je     803351 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  803302:	8b 43 04             	mov    0x4(%ebx),%eax
  803305:	8b 0b                	mov    (%ebx),%ecx
  803307:	8d 51 20             	lea    0x20(%ecx),%edx
  80330a:	39 d0                	cmp    %edx,%eax
  80330c:	72 14                	jb     803322 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  80330e:	89 da                	mov    %ebx,%edx
  803310:	89 f0                	mov    %esi,%eax
  803312:	e8 65 ff ff ff       	call   80327c <_pipeisclosed>
  803317:	85 c0                	test   %eax,%eax
  803319:	75 3a                	jne    803355 <devpipe_write+0x74>
			sys_yield();
  80331b:	e8 18 f3 ff ff       	call   802638 <sys_yield>
  803320:	eb e0                	jmp    803302 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  803322:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803325:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  803329:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80332c:	89 c2                	mov    %eax,%edx
  80332e:	c1 fa 1f             	sar    $0x1f,%edx
  803331:	89 d1                	mov    %edx,%ecx
  803333:	c1 e9 1b             	shr    $0x1b,%ecx
  803336:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  803339:	83 e2 1f             	and    $0x1f,%edx
  80333c:	29 ca                	sub    %ecx,%edx
  80333e:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  803342:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  803346:	83 c0 01             	add    $0x1,%eax
  803349:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80334c:	83 c7 01             	add    $0x1,%edi
  80334f:	eb ac                	jmp    8032fd <devpipe_write+0x1c>
	return i;
  803351:	89 f8                	mov    %edi,%eax
  803353:	eb 05                	jmp    80335a <devpipe_write+0x79>
				return 0;
  803355:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80335a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80335d:	5b                   	pop    %ebx
  80335e:	5e                   	pop    %esi
  80335f:	5f                   	pop    %edi
  803360:	5d                   	pop    %ebp
  803361:	c3                   	ret    

00803362 <devpipe_read>:
{
  803362:	55                   	push   %ebp
  803363:	89 e5                	mov    %esp,%ebp
  803365:	57                   	push   %edi
  803366:	56                   	push   %esi
  803367:	53                   	push   %ebx
  803368:	83 ec 18             	sub    $0x18,%esp
  80336b:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  80336e:	57                   	push   %edi
  80336f:	e8 74 f6 ff ff       	call   8029e8 <fd2data>
  803374:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  803376:	83 c4 10             	add    $0x10,%esp
  803379:	be 00 00 00 00       	mov    $0x0,%esi
  80337e:	3b 75 10             	cmp    0x10(%ebp),%esi
  803381:	74 47                	je     8033ca <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  803383:	8b 03                	mov    (%ebx),%eax
  803385:	3b 43 04             	cmp    0x4(%ebx),%eax
  803388:	75 22                	jne    8033ac <devpipe_read+0x4a>
			if (i > 0)
  80338a:	85 f6                	test   %esi,%esi
  80338c:	75 14                	jne    8033a2 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  80338e:	89 da                	mov    %ebx,%edx
  803390:	89 f8                	mov    %edi,%eax
  803392:	e8 e5 fe ff ff       	call   80327c <_pipeisclosed>
  803397:	85 c0                	test   %eax,%eax
  803399:	75 33                	jne    8033ce <devpipe_read+0x6c>
			sys_yield();
  80339b:	e8 98 f2 ff ff       	call   802638 <sys_yield>
  8033a0:	eb e1                	jmp    803383 <devpipe_read+0x21>
				return i;
  8033a2:	89 f0                	mov    %esi,%eax
}
  8033a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8033a7:	5b                   	pop    %ebx
  8033a8:	5e                   	pop    %esi
  8033a9:	5f                   	pop    %edi
  8033aa:	5d                   	pop    %ebp
  8033ab:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8033ac:	99                   	cltd   
  8033ad:	c1 ea 1b             	shr    $0x1b,%edx
  8033b0:	01 d0                	add    %edx,%eax
  8033b2:	83 e0 1f             	and    $0x1f,%eax
  8033b5:	29 d0                	sub    %edx,%eax
  8033b7:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8033bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8033bf:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8033c2:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8033c5:	83 c6 01             	add    $0x1,%esi
  8033c8:	eb b4                	jmp    80337e <devpipe_read+0x1c>
	return i;
  8033ca:	89 f0                	mov    %esi,%eax
  8033cc:	eb d6                	jmp    8033a4 <devpipe_read+0x42>
				return 0;
  8033ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8033d3:	eb cf                	jmp    8033a4 <devpipe_read+0x42>

008033d5 <pipe>:
{
  8033d5:	55                   	push   %ebp
  8033d6:	89 e5                	mov    %esp,%ebp
  8033d8:	56                   	push   %esi
  8033d9:	53                   	push   %ebx
  8033da:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8033dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8033e0:	50                   	push   %eax
  8033e1:	e8 19 f6 ff ff       	call   8029ff <fd_alloc>
  8033e6:	89 c3                	mov    %eax,%ebx
  8033e8:	83 c4 10             	add    $0x10,%esp
  8033eb:	85 c0                	test   %eax,%eax
  8033ed:	78 5b                	js     80344a <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8033ef:	83 ec 04             	sub    $0x4,%esp
  8033f2:	68 07 04 00 00       	push   $0x407
  8033f7:	ff 75 f4             	pushl  -0xc(%ebp)
  8033fa:	6a 00                	push   $0x0
  8033fc:	e8 56 f2 ff ff       	call   802657 <sys_page_alloc>
  803401:	89 c3                	mov    %eax,%ebx
  803403:	83 c4 10             	add    $0x10,%esp
  803406:	85 c0                	test   %eax,%eax
  803408:	78 40                	js     80344a <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  80340a:	83 ec 0c             	sub    $0xc,%esp
  80340d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  803410:	50                   	push   %eax
  803411:	e8 e9 f5 ff ff       	call   8029ff <fd_alloc>
  803416:	89 c3                	mov    %eax,%ebx
  803418:	83 c4 10             	add    $0x10,%esp
  80341b:	85 c0                	test   %eax,%eax
  80341d:	78 1b                	js     80343a <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80341f:	83 ec 04             	sub    $0x4,%esp
  803422:	68 07 04 00 00       	push   $0x407
  803427:	ff 75 f0             	pushl  -0x10(%ebp)
  80342a:	6a 00                	push   $0x0
  80342c:	e8 26 f2 ff ff       	call   802657 <sys_page_alloc>
  803431:	89 c3                	mov    %eax,%ebx
  803433:	83 c4 10             	add    $0x10,%esp
  803436:	85 c0                	test   %eax,%eax
  803438:	79 19                	jns    803453 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  80343a:	83 ec 08             	sub    $0x8,%esp
  80343d:	ff 75 f4             	pushl  -0xc(%ebp)
  803440:	6a 00                	push   $0x0
  803442:	e8 95 f2 ff ff       	call   8026dc <sys_page_unmap>
  803447:	83 c4 10             	add    $0x10,%esp
}
  80344a:	89 d8                	mov    %ebx,%eax
  80344c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80344f:	5b                   	pop    %ebx
  803450:	5e                   	pop    %esi
  803451:	5d                   	pop    %ebp
  803452:	c3                   	ret    
	va = fd2data(fd0);
  803453:	83 ec 0c             	sub    $0xc,%esp
  803456:	ff 75 f4             	pushl  -0xc(%ebp)
  803459:	e8 8a f5 ff ff       	call   8029e8 <fd2data>
  80345e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803460:	83 c4 0c             	add    $0xc,%esp
  803463:	68 07 04 00 00       	push   $0x407
  803468:	50                   	push   %eax
  803469:	6a 00                	push   $0x0
  80346b:	e8 e7 f1 ff ff       	call   802657 <sys_page_alloc>
  803470:	89 c3                	mov    %eax,%ebx
  803472:	83 c4 10             	add    $0x10,%esp
  803475:	85 c0                	test   %eax,%eax
  803477:	0f 88 8c 00 00 00    	js     803509 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80347d:	83 ec 0c             	sub    $0xc,%esp
  803480:	ff 75 f0             	pushl  -0x10(%ebp)
  803483:	e8 60 f5 ff ff       	call   8029e8 <fd2data>
  803488:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80348f:	50                   	push   %eax
  803490:	6a 00                	push   $0x0
  803492:	56                   	push   %esi
  803493:	6a 00                	push   $0x0
  803495:	e8 00 f2 ff ff       	call   80269a <sys_page_map>
  80349a:	89 c3                	mov    %eax,%ebx
  80349c:	83 c4 20             	add    $0x20,%esp
  80349f:	85 c0                	test   %eax,%eax
  8034a1:	78 58                	js     8034fb <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  8034a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8034a6:	8b 15 80 90 80 00    	mov    0x809080,%edx
  8034ac:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8034ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8034b1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  8034b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8034bb:	8b 15 80 90 80 00    	mov    0x809080,%edx
  8034c1:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8034c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8034c6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8034cd:	83 ec 0c             	sub    $0xc,%esp
  8034d0:	ff 75 f4             	pushl  -0xc(%ebp)
  8034d3:	e8 00 f5 ff ff       	call   8029d8 <fd2num>
  8034d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8034db:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8034dd:	83 c4 04             	add    $0x4,%esp
  8034e0:	ff 75 f0             	pushl  -0x10(%ebp)
  8034e3:	e8 f0 f4 ff ff       	call   8029d8 <fd2num>
  8034e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8034eb:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8034ee:	83 c4 10             	add    $0x10,%esp
  8034f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8034f6:	e9 4f ff ff ff       	jmp    80344a <pipe+0x75>
	sys_page_unmap(0, va);
  8034fb:	83 ec 08             	sub    $0x8,%esp
  8034fe:	56                   	push   %esi
  8034ff:	6a 00                	push   $0x0
  803501:	e8 d6 f1 ff ff       	call   8026dc <sys_page_unmap>
  803506:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  803509:	83 ec 08             	sub    $0x8,%esp
  80350c:	ff 75 f0             	pushl  -0x10(%ebp)
  80350f:	6a 00                	push   $0x0
  803511:	e8 c6 f1 ff ff       	call   8026dc <sys_page_unmap>
  803516:	83 c4 10             	add    $0x10,%esp
  803519:	e9 1c ff ff ff       	jmp    80343a <pipe+0x65>

0080351e <pipeisclosed>:
{
  80351e:	55                   	push   %ebp
  80351f:	89 e5                	mov    %esp,%ebp
  803521:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803524:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803527:	50                   	push   %eax
  803528:	ff 75 08             	pushl  0x8(%ebp)
  80352b:	e8 1e f5 ff ff       	call   802a4e <fd_lookup>
  803530:	83 c4 10             	add    $0x10,%esp
  803533:	85 c0                	test   %eax,%eax
  803535:	78 18                	js     80354f <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  803537:	83 ec 0c             	sub    $0xc,%esp
  80353a:	ff 75 f4             	pushl  -0xc(%ebp)
  80353d:	e8 a6 f4 ff ff       	call   8029e8 <fd2data>
	return _pipeisclosed(fd, p);
  803542:	89 c2                	mov    %eax,%edx
  803544:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803547:	e8 30 fd ff ff       	call   80327c <_pipeisclosed>
  80354c:	83 c4 10             	add    $0x10,%esp
}
  80354f:	c9                   	leave  
  803550:	c3                   	ret    

00803551 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  803551:	55                   	push   %ebp
  803552:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  803554:	b8 00 00 00 00       	mov    $0x0,%eax
  803559:	5d                   	pop    %ebp
  80355a:	c3                   	ret    

0080355b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80355b:	55                   	push   %ebp
  80355c:	89 e5                	mov    %esp,%ebp
  80355e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  803561:	68 45 43 80 00       	push   $0x804345
  803566:	ff 75 0c             	pushl  0xc(%ebp)
  803569:	e8 f0 ec ff ff       	call   80225e <strcpy>
	return 0;
}
  80356e:	b8 00 00 00 00       	mov    $0x0,%eax
  803573:	c9                   	leave  
  803574:	c3                   	ret    

00803575 <devcons_write>:
{
  803575:	55                   	push   %ebp
  803576:	89 e5                	mov    %esp,%ebp
  803578:	57                   	push   %edi
  803579:	56                   	push   %esi
  80357a:	53                   	push   %ebx
  80357b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  803581:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  803586:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  80358c:	eb 2f                	jmp    8035bd <devcons_write+0x48>
		m = n - tot;
  80358e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  803591:	29 f3                	sub    %esi,%ebx
  803593:	83 fb 7f             	cmp    $0x7f,%ebx
  803596:	b8 7f 00 00 00       	mov    $0x7f,%eax
  80359b:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  80359e:	83 ec 04             	sub    $0x4,%esp
  8035a1:	53                   	push   %ebx
  8035a2:	89 f0                	mov    %esi,%eax
  8035a4:	03 45 0c             	add    0xc(%ebp),%eax
  8035a7:	50                   	push   %eax
  8035a8:	57                   	push   %edi
  8035a9:	e8 3e ee ff ff       	call   8023ec <memmove>
		sys_cputs(buf, m);
  8035ae:	83 c4 08             	add    $0x8,%esp
  8035b1:	53                   	push   %ebx
  8035b2:	57                   	push   %edi
  8035b3:	e8 e3 ef ff ff       	call   80259b <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8035b8:	01 de                	add    %ebx,%esi
  8035ba:	83 c4 10             	add    $0x10,%esp
  8035bd:	3b 75 10             	cmp    0x10(%ebp),%esi
  8035c0:	72 cc                	jb     80358e <devcons_write+0x19>
}
  8035c2:	89 f0                	mov    %esi,%eax
  8035c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8035c7:	5b                   	pop    %ebx
  8035c8:	5e                   	pop    %esi
  8035c9:	5f                   	pop    %edi
  8035ca:	5d                   	pop    %ebp
  8035cb:	c3                   	ret    

008035cc <devcons_read>:
{
  8035cc:	55                   	push   %ebp
  8035cd:	89 e5                	mov    %esp,%ebp
  8035cf:	83 ec 08             	sub    $0x8,%esp
  8035d2:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8035d7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8035db:	75 07                	jne    8035e4 <devcons_read+0x18>
}
  8035dd:	c9                   	leave  
  8035de:	c3                   	ret    
		sys_yield();
  8035df:	e8 54 f0 ff ff       	call   802638 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8035e4:	e8 d0 ef ff ff       	call   8025b9 <sys_cgetc>
  8035e9:	85 c0                	test   %eax,%eax
  8035eb:	74 f2                	je     8035df <devcons_read+0x13>
	if (c < 0)
  8035ed:	85 c0                	test   %eax,%eax
  8035ef:	78 ec                	js     8035dd <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  8035f1:	83 f8 04             	cmp    $0x4,%eax
  8035f4:	74 0c                	je     803602 <devcons_read+0x36>
	*(char*)vbuf = c;
  8035f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8035f9:	88 02                	mov    %al,(%edx)
	return 1;
  8035fb:	b8 01 00 00 00       	mov    $0x1,%eax
  803600:	eb db                	jmp    8035dd <devcons_read+0x11>
		return 0;
  803602:	b8 00 00 00 00       	mov    $0x0,%eax
  803607:	eb d4                	jmp    8035dd <devcons_read+0x11>

00803609 <cputchar>:
{
  803609:	55                   	push   %ebp
  80360a:	89 e5                	mov    %esp,%ebp
  80360c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80360f:	8b 45 08             	mov    0x8(%ebp),%eax
  803612:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  803615:	6a 01                	push   $0x1
  803617:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80361a:	50                   	push   %eax
  80361b:	e8 7b ef ff ff       	call   80259b <sys_cputs>
}
  803620:	83 c4 10             	add    $0x10,%esp
  803623:	c9                   	leave  
  803624:	c3                   	ret    

00803625 <getchar>:
{
  803625:	55                   	push   %ebp
  803626:	89 e5                	mov    %esp,%ebp
  803628:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80362b:	6a 01                	push   $0x1
  80362d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  803630:	50                   	push   %eax
  803631:	6a 00                	push   $0x0
  803633:	e8 87 f6 ff ff       	call   802cbf <read>
	if (r < 0)
  803638:	83 c4 10             	add    $0x10,%esp
  80363b:	85 c0                	test   %eax,%eax
  80363d:	78 08                	js     803647 <getchar+0x22>
	if (r < 1)
  80363f:	85 c0                	test   %eax,%eax
  803641:	7e 06                	jle    803649 <getchar+0x24>
	return c;
  803643:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  803647:	c9                   	leave  
  803648:	c3                   	ret    
		return -E_EOF;
  803649:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80364e:	eb f7                	jmp    803647 <getchar+0x22>

00803650 <iscons>:
{
  803650:	55                   	push   %ebp
  803651:	89 e5                	mov    %esp,%ebp
  803653:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803656:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803659:	50                   	push   %eax
  80365a:	ff 75 08             	pushl  0x8(%ebp)
  80365d:	e8 ec f3 ff ff       	call   802a4e <fd_lookup>
  803662:	83 c4 10             	add    $0x10,%esp
  803665:	85 c0                	test   %eax,%eax
  803667:	78 11                	js     80367a <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  803669:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80366c:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  803672:	39 10                	cmp    %edx,(%eax)
  803674:	0f 94 c0             	sete   %al
  803677:	0f b6 c0             	movzbl %al,%eax
}
  80367a:	c9                   	leave  
  80367b:	c3                   	ret    

0080367c <opencons>:
{
  80367c:	55                   	push   %ebp
  80367d:	89 e5                	mov    %esp,%ebp
  80367f:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  803682:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803685:	50                   	push   %eax
  803686:	e8 74 f3 ff ff       	call   8029ff <fd_alloc>
  80368b:	83 c4 10             	add    $0x10,%esp
  80368e:	85 c0                	test   %eax,%eax
  803690:	78 3a                	js     8036cc <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  803692:	83 ec 04             	sub    $0x4,%esp
  803695:	68 07 04 00 00       	push   $0x407
  80369a:	ff 75 f4             	pushl  -0xc(%ebp)
  80369d:	6a 00                	push   $0x0
  80369f:	e8 b3 ef ff ff       	call   802657 <sys_page_alloc>
  8036a4:	83 c4 10             	add    $0x10,%esp
  8036a7:	85 c0                	test   %eax,%eax
  8036a9:	78 21                	js     8036cc <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8036ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8036ae:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  8036b4:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8036b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8036b9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8036c0:	83 ec 0c             	sub    $0xc,%esp
  8036c3:	50                   	push   %eax
  8036c4:	e8 0f f3 ff ff       	call   8029d8 <fd2num>
  8036c9:	83 c4 10             	add    $0x10,%esp
}
  8036cc:	c9                   	leave  
  8036cd:	c3                   	ret    
  8036ce:	66 90                	xchg   %ax,%ax

008036d0 <__udivdi3>:
  8036d0:	55                   	push   %ebp
  8036d1:	57                   	push   %edi
  8036d2:	56                   	push   %esi
  8036d3:	53                   	push   %ebx
  8036d4:	83 ec 1c             	sub    $0x1c,%esp
  8036d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8036db:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8036df:	8b 74 24 34          	mov    0x34(%esp),%esi
  8036e3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8036e7:	85 d2                	test   %edx,%edx
  8036e9:	75 35                	jne    803720 <__udivdi3+0x50>
  8036eb:	39 f3                	cmp    %esi,%ebx
  8036ed:	0f 87 bd 00 00 00    	ja     8037b0 <__udivdi3+0xe0>
  8036f3:	85 db                	test   %ebx,%ebx
  8036f5:	89 d9                	mov    %ebx,%ecx
  8036f7:	75 0b                	jne    803704 <__udivdi3+0x34>
  8036f9:	b8 01 00 00 00       	mov    $0x1,%eax
  8036fe:	31 d2                	xor    %edx,%edx
  803700:	f7 f3                	div    %ebx
  803702:	89 c1                	mov    %eax,%ecx
  803704:	31 d2                	xor    %edx,%edx
  803706:	89 f0                	mov    %esi,%eax
  803708:	f7 f1                	div    %ecx
  80370a:	89 c6                	mov    %eax,%esi
  80370c:	89 e8                	mov    %ebp,%eax
  80370e:	89 f7                	mov    %esi,%edi
  803710:	f7 f1                	div    %ecx
  803712:	89 fa                	mov    %edi,%edx
  803714:	83 c4 1c             	add    $0x1c,%esp
  803717:	5b                   	pop    %ebx
  803718:	5e                   	pop    %esi
  803719:	5f                   	pop    %edi
  80371a:	5d                   	pop    %ebp
  80371b:	c3                   	ret    
  80371c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803720:	39 f2                	cmp    %esi,%edx
  803722:	77 7c                	ja     8037a0 <__udivdi3+0xd0>
  803724:	0f bd fa             	bsr    %edx,%edi
  803727:	83 f7 1f             	xor    $0x1f,%edi
  80372a:	0f 84 98 00 00 00    	je     8037c8 <__udivdi3+0xf8>
  803730:	89 f9                	mov    %edi,%ecx
  803732:	b8 20 00 00 00       	mov    $0x20,%eax
  803737:	29 f8                	sub    %edi,%eax
  803739:	d3 e2                	shl    %cl,%edx
  80373b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80373f:	89 c1                	mov    %eax,%ecx
  803741:	89 da                	mov    %ebx,%edx
  803743:	d3 ea                	shr    %cl,%edx
  803745:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  803749:	09 d1                	or     %edx,%ecx
  80374b:	89 f2                	mov    %esi,%edx
  80374d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803751:	89 f9                	mov    %edi,%ecx
  803753:	d3 e3                	shl    %cl,%ebx
  803755:	89 c1                	mov    %eax,%ecx
  803757:	d3 ea                	shr    %cl,%edx
  803759:	89 f9                	mov    %edi,%ecx
  80375b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80375f:	d3 e6                	shl    %cl,%esi
  803761:	89 eb                	mov    %ebp,%ebx
  803763:	89 c1                	mov    %eax,%ecx
  803765:	d3 eb                	shr    %cl,%ebx
  803767:	09 de                	or     %ebx,%esi
  803769:	89 f0                	mov    %esi,%eax
  80376b:	f7 74 24 08          	divl   0x8(%esp)
  80376f:	89 d6                	mov    %edx,%esi
  803771:	89 c3                	mov    %eax,%ebx
  803773:	f7 64 24 0c          	mull   0xc(%esp)
  803777:	39 d6                	cmp    %edx,%esi
  803779:	72 0c                	jb     803787 <__udivdi3+0xb7>
  80377b:	89 f9                	mov    %edi,%ecx
  80377d:	d3 e5                	shl    %cl,%ebp
  80377f:	39 c5                	cmp    %eax,%ebp
  803781:	73 5d                	jae    8037e0 <__udivdi3+0x110>
  803783:	39 d6                	cmp    %edx,%esi
  803785:	75 59                	jne    8037e0 <__udivdi3+0x110>
  803787:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80378a:	31 ff                	xor    %edi,%edi
  80378c:	89 fa                	mov    %edi,%edx
  80378e:	83 c4 1c             	add    $0x1c,%esp
  803791:	5b                   	pop    %ebx
  803792:	5e                   	pop    %esi
  803793:	5f                   	pop    %edi
  803794:	5d                   	pop    %ebp
  803795:	c3                   	ret    
  803796:	8d 76 00             	lea    0x0(%esi),%esi
  803799:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8037a0:	31 ff                	xor    %edi,%edi
  8037a2:	31 c0                	xor    %eax,%eax
  8037a4:	89 fa                	mov    %edi,%edx
  8037a6:	83 c4 1c             	add    $0x1c,%esp
  8037a9:	5b                   	pop    %ebx
  8037aa:	5e                   	pop    %esi
  8037ab:	5f                   	pop    %edi
  8037ac:	5d                   	pop    %ebp
  8037ad:	c3                   	ret    
  8037ae:	66 90                	xchg   %ax,%ax
  8037b0:	31 ff                	xor    %edi,%edi
  8037b2:	89 e8                	mov    %ebp,%eax
  8037b4:	89 f2                	mov    %esi,%edx
  8037b6:	f7 f3                	div    %ebx
  8037b8:	89 fa                	mov    %edi,%edx
  8037ba:	83 c4 1c             	add    $0x1c,%esp
  8037bd:	5b                   	pop    %ebx
  8037be:	5e                   	pop    %esi
  8037bf:	5f                   	pop    %edi
  8037c0:	5d                   	pop    %ebp
  8037c1:	c3                   	ret    
  8037c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8037c8:	39 f2                	cmp    %esi,%edx
  8037ca:	72 06                	jb     8037d2 <__udivdi3+0x102>
  8037cc:	31 c0                	xor    %eax,%eax
  8037ce:	39 eb                	cmp    %ebp,%ebx
  8037d0:	77 d2                	ja     8037a4 <__udivdi3+0xd4>
  8037d2:	b8 01 00 00 00       	mov    $0x1,%eax
  8037d7:	eb cb                	jmp    8037a4 <__udivdi3+0xd4>
  8037d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8037e0:	89 d8                	mov    %ebx,%eax
  8037e2:	31 ff                	xor    %edi,%edi
  8037e4:	eb be                	jmp    8037a4 <__udivdi3+0xd4>
  8037e6:	66 90                	xchg   %ax,%ax
  8037e8:	66 90                	xchg   %ax,%ax
  8037ea:	66 90                	xchg   %ax,%ax
  8037ec:	66 90                	xchg   %ax,%ax
  8037ee:	66 90                	xchg   %ax,%ax

008037f0 <__umoddi3>:
  8037f0:	55                   	push   %ebp
  8037f1:	57                   	push   %edi
  8037f2:	56                   	push   %esi
  8037f3:	53                   	push   %ebx
  8037f4:	83 ec 1c             	sub    $0x1c,%esp
  8037f7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  8037fb:	8b 74 24 30          	mov    0x30(%esp),%esi
  8037ff:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  803803:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803807:	85 ed                	test   %ebp,%ebp
  803809:	89 f0                	mov    %esi,%eax
  80380b:	89 da                	mov    %ebx,%edx
  80380d:	75 19                	jne    803828 <__umoddi3+0x38>
  80380f:	39 df                	cmp    %ebx,%edi
  803811:	0f 86 b1 00 00 00    	jbe    8038c8 <__umoddi3+0xd8>
  803817:	f7 f7                	div    %edi
  803819:	89 d0                	mov    %edx,%eax
  80381b:	31 d2                	xor    %edx,%edx
  80381d:	83 c4 1c             	add    $0x1c,%esp
  803820:	5b                   	pop    %ebx
  803821:	5e                   	pop    %esi
  803822:	5f                   	pop    %edi
  803823:	5d                   	pop    %ebp
  803824:	c3                   	ret    
  803825:	8d 76 00             	lea    0x0(%esi),%esi
  803828:	39 dd                	cmp    %ebx,%ebp
  80382a:	77 f1                	ja     80381d <__umoddi3+0x2d>
  80382c:	0f bd cd             	bsr    %ebp,%ecx
  80382f:	83 f1 1f             	xor    $0x1f,%ecx
  803832:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  803836:	0f 84 b4 00 00 00    	je     8038f0 <__umoddi3+0x100>
  80383c:	b8 20 00 00 00       	mov    $0x20,%eax
  803841:	89 c2                	mov    %eax,%edx
  803843:	8b 44 24 04          	mov    0x4(%esp),%eax
  803847:	29 c2                	sub    %eax,%edx
  803849:	89 c1                	mov    %eax,%ecx
  80384b:	89 f8                	mov    %edi,%eax
  80384d:	d3 e5                	shl    %cl,%ebp
  80384f:	89 d1                	mov    %edx,%ecx
  803851:	89 54 24 0c          	mov    %edx,0xc(%esp)
  803855:	d3 e8                	shr    %cl,%eax
  803857:	09 c5                	or     %eax,%ebp
  803859:	8b 44 24 04          	mov    0x4(%esp),%eax
  80385d:	89 c1                	mov    %eax,%ecx
  80385f:	d3 e7                	shl    %cl,%edi
  803861:	89 d1                	mov    %edx,%ecx
  803863:	89 7c 24 08          	mov    %edi,0x8(%esp)
  803867:	89 df                	mov    %ebx,%edi
  803869:	d3 ef                	shr    %cl,%edi
  80386b:	89 c1                	mov    %eax,%ecx
  80386d:	89 f0                	mov    %esi,%eax
  80386f:	d3 e3                	shl    %cl,%ebx
  803871:	89 d1                	mov    %edx,%ecx
  803873:	89 fa                	mov    %edi,%edx
  803875:	d3 e8                	shr    %cl,%eax
  803877:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80387c:	09 d8                	or     %ebx,%eax
  80387e:	f7 f5                	div    %ebp
  803880:	d3 e6                	shl    %cl,%esi
  803882:	89 d1                	mov    %edx,%ecx
  803884:	f7 64 24 08          	mull   0x8(%esp)
  803888:	39 d1                	cmp    %edx,%ecx
  80388a:	89 c3                	mov    %eax,%ebx
  80388c:	89 d7                	mov    %edx,%edi
  80388e:	72 06                	jb     803896 <__umoddi3+0xa6>
  803890:	75 0e                	jne    8038a0 <__umoddi3+0xb0>
  803892:	39 c6                	cmp    %eax,%esi
  803894:	73 0a                	jae    8038a0 <__umoddi3+0xb0>
  803896:	2b 44 24 08          	sub    0x8(%esp),%eax
  80389a:	19 ea                	sbb    %ebp,%edx
  80389c:	89 d7                	mov    %edx,%edi
  80389e:	89 c3                	mov    %eax,%ebx
  8038a0:	89 ca                	mov    %ecx,%edx
  8038a2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8038a7:	29 de                	sub    %ebx,%esi
  8038a9:	19 fa                	sbb    %edi,%edx
  8038ab:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  8038af:	89 d0                	mov    %edx,%eax
  8038b1:	d3 e0                	shl    %cl,%eax
  8038b3:	89 d9                	mov    %ebx,%ecx
  8038b5:	d3 ee                	shr    %cl,%esi
  8038b7:	d3 ea                	shr    %cl,%edx
  8038b9:	09 f0                	or     %esi,%eax
  8038bb:	83 c4 1c             	add    $0x1c,%esp
  8038be:	5b                   	pop    %ebx
  8038bf:	5e                   	pop    %esi
  8038c0:	5f                   	pop    %edi
  8038c1:	5d                   	pop    %ebp
  8038c2:	c3                   	ret    
  8038c3:	90                   	nop
  8038c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8038c8:	85 ff                	test   %edi,%edi
  8038ca:	89 f9                	mov    %edi,%ecx
  8038cc:	75 0b                	jne    8038d9 <__umoddi3+0xe9>
  8038ce:	b8 01 00 00 00       	mov    $0x1,%eax
  8038d3:	31 d2                	xor    %edx,%edx
  8038d5:	f7 f7                	div    %edi
  8038d7:	89 c1                	mov    %eax,%ecx
  8038d9:	89 d8                	mov    %ebx,%eax
  8038db:	31 d2                	xor    %edx,%edx
  8038dd:	f7 f1                	div    %ecx
  8038df:	89 f0                	mov    %esi,%eax
  8038e1:	f7 f1                	div    %ecx
  8038e3:	e9 31 ff ff ff       	jmp    803819 <__umoddi3+0x29>
  8038e8:	90                   	nop
  8038e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8038f0:	39 dd                	cmp    %ebx,%ebp
  8038f2:	72 08                	jb     8038fc <__umoddi3+0x10c>
  8038f4:	39 f7                	cmp    %esi,%edi
  8038f6:	0f 87 21 ff ff ff    	ja     80381d <__umoddi3+0x2d>
  8038fc:	89 da                	mov    %ebx,%edx
  8038fe:	89 f0                	mov    %esi,%eax
  803900:	29 f8                	sub    %edi,%eax
  803902:	19 ea                	sbb    %ebp,%edx
  803904:	e9 14 ff ff ff       	jmp    80381d <__umoddi3+0x2d>
