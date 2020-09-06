
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 00 12 00       	mov    $0x120000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 00 12 f0       	mov    $0xf0120000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 5e 00 00 00       	call   f010009c <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100048:	83 3d 80 5e 21 f0 00 	cmpl   $0x0,0xf0215e80
f010004f:	74 0f                	je     f0100060 <_panic+0x20>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100051:	83 ec 0c             	sub    $0xc,%esp
f0100054:	6a 00                	push   $0x0
f0100056:	e8 ff 08 00 00       	call   f010095a <monitor>
f010005b:	83 c4 10             	add    $0x10,%esp
f010005e:	eb f1                	jmp    f0100051 <_panic+0x11>
	panicstr = fmt;
f0100060:	89 35 80 5e 21 f0    	mov    %esi,0xf0215e80
	asm volatile("cli; cld");
f0100066:	fa                   	cli    
f0100067:	fc                   	cld    
	va_start(ap, fmt);
f0100068:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010006b:	e8 b3 5e 00 00       	call   f0105f23 <cpunum>
f0100070:	ff 75 0c             	pushl  0xc(%ebp)
f0100073:	ff 75 08             	pushl  0x8(%ebp)
f0100076:	50                   	push   %eax
f0100077:	68 60 65 10 f0       	push   $0xf0106560
f010007c:	e8 c7 38 00 00       	call   f0103948 <cprintf>
	vcprintf(fmt, ap);
f0100081:	83 c4 08             	add    $0x8,%esp
f0100084:	53                   	push   %ebx
f0100085:	56                   	push   %esi
f0100086:	e8 97 38 00 00       	call   f0103922 <vcprintf>
	cprintf("\n");
f010008b:	c7 04 24 c9 68 10 f0 	movl   $0xf01068c9,(%esp)
f0100092:	e8 b1 38 00 00       	call   f0103948 <cprintf>
f0100097:	83 c4 10             	add    $0x10,%esp
f010009a:	eb b5                	jmp    f0100051 <_panic+0x11>

f010009c <i386_init>:
{
f010009c:	55                   	push   %ebp
f010009d:	89 e5                	mov    %esp,%ebp
f010009f:	53                   	push   %ebx
f01000a0:	83 ec 04             	sub    $0x4,%esp
	cons_init();
f01000a3:	e8 a9 05 00 00       	call   f0100651 <cons_init>
	mem_init();
f01000a8:	e8 a8 12 00 00       	call   f0101355 <mem_init>
	env_init();
f01000ad:	e8 c3 30 00 00       	call   f0103175 <env_init>
	trap_init();
f01000b2:	e8 73 39 00 00       	call   f0103a2a <trap_init>
	mp_init();
f01000b7:	e8 55 5b 00 00       	call   f0105c11 <mp_init>
	lapic_init();
f01000bc:	e8 7c 5e 00 00       	call   f0105f3d <lapic_init>
	pic_init();
f01000c1:	e8 a5 37 00 00       	call   f010386b <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000c6:	83 ec 0c             	sub    $0xc,%esp
f01000c9:	68 c0 23 12 f0       	push   $0xf01223c0
f01000ce:	e8 c0 60 00 00       	call   f0106193 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000d3:	83 c4 10             	add    $0x10,%esp
f01000d6:	83 3d 88 5e 21 f0 07 	cmpl   $0x7,0xf0215e88
f01000dd:	76 27                	jbe    f0100106 <i386_init+0x6a>
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01000df:	83 ec 04             	sub    $0x4,%esp
f01000e2:	b8 76 5b 10 f0       	mov    $0xf0105b76,%eax
f01000e7:	2d fc 5a 10 f0       	sub    $0xf0105afc,%eax
f01000ec:	50                   	push   %eax
f01000ed:	68 fc 5a 10 f0       	push   $0xf0105afc
f01000f2:	68 00 70 00 f0       	push   $0xf0007000
f01000f7:	e8 50 58 00 00       	call   f010594c <memmove>
f01000fc:	83 c4 10             	add    $0x10,%esp
	for (c = cpus; c < cpus + ncpu; c++) {
f01000ff:	bb 20 60 21 f0       	mov    $0xf0216020,%ebx
f0100104:	eb 19                	jmp    f010011f <i386_init+0x83>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100106:	68 00 70 00 00       	push   $0x7000
f010010b:	68 84 65 10 f0       	push   $0xf0106584
f0100110:	6a 64                	push   $0x64
f0100112:	68 cc 65 10 f0       	push   $0xf01065cc
f0100117:	e8 24 ff ff ff       	call   f0100040 <_panic>
f010011c:	83 c3 74             	add    $0x74,%ebx
f010011f:	6b 05 c4 63 21 f0 74 	imul   $0x74,0xf02163c4,%eax
f0100126:	05 20 60 21 f0       	add    $0xf0216020,%eax
f010012b:	39 c3                	cmp    %eax,%ebx
f010012d:	73 4c                	jae    f010017b <i386_init+0xdf>
		if (c == cpus + cpunum())  // We've started already.
f010012f:	e8 ef 5d 00 00       	call   f0105f23 <cpunum>
f0100134:	6b c0 74             	imul   $0x74,%eax,%eax
f0100137:	05 20 60 21 f0       	add    $0xf0216020,%eax
f010013c:	39 c3                	cmp    %eax,%ebx
f010013e:	74 dc                	je     f010011c <i386_init+0x80>
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100140:	89 d8                	mov    %ebx,%eax
f0100142:	2d 20 60 21 f0       	sub    $0xf0216020,%eax
f0100147:	c1 f8 02             	sar    $0x2,%eax
f010014a:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100150:	c1 e0 0f             	shl    $0xf,%eax
f0100153:	05 00 f0 21 f0       	add    $0xf021f000,%eax
f0100158:	a3 84 5e 21 f0       	mov    %eax,0xf0215e84
		lapic_startap(c->cpu_id, PADDR(code));
f010015d:	83 ec 08             	sub    $0x8,%esp
f0100160:	68 00 70 00 00       	push   $0x7000
f0100165:	0f b6 03             	movzbl (%ebx),%eax
f0100168:	50                   	push   %eax
f0100169:	e8 20 5f 00 00       	call   f010608e <lapic_startap>
f010016e:	83 c4 10             	add    $0x10,%esp
		while(c->cpu_status != CPU_STARTED)
f0100171:	8b 43 04             	mov    0x4(%ebx),%eax
f0100174:	83 f8 01             	cmp    $0x1,%eax
f0100177:	75 f8                	jne    f0100171 <i386_init+0xd5>
f0100179:	eb a1                	jmp    f010011c <i386_init+0x80>
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f010017b:	83 ec 08             	sub    $0x8,%esp
f010017e:	6a 01                	push   $0x1
f0100180:	68 a8 28 1d f0       	push   $0xf01d28a8
f0100185:	e8 a8 31 00 00       	call   f0103332 <env_create>
	ENV_CREATE(TEST, ENV_TYPE_USER);
f010018a:	83 c4 08             	add    $0x8,%esp
f010018d:	6a 00                	push   $0x0
f010018f:	68 50 48 20 f0       	push   $0xf0204850
f0100194:	e8 99 31 00 00       	call   f0103332 <env_create>
	kbd_intr();
f0100199:	e8 58 04 00 00       	call   f01005f6 <kbd_intr>
         sched_yield();
f010019e:	e8 e7 43 00 00       	call   f010458a <sched_yield>

f01001a3 <mp_main>:
{
f01001a3:	55                   	push   %ebp
f01001a4:	89 e5                	mov    %esp,%ebp
f01001a6:	83 ec 08             	sub    $0x8,%esp
	lcr3(PADDR(kern_pgdir));
f01001a9:	a1 8c 5e 21 f0       	mov    0xf0215e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01001ae:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001b3:	77 12                	ja     f01001c7 <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001b5:	50                   	push   %eax
f01001b6:	68 a8 65 10 f0       	push   $0xf01065a8
f01001bb:	6a 7b                	push   $0x7b
f01001bd:	68 cc 65 10 f0       	push   $0xf01065cc
f01001c2:	e8 79 fe ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01001c7:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01001cc:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001cf:	e8 4f 5d 00 00       	call   f0105f23 <cpunum>
f01001d4:	83 ec 08             	sub    $0x8,%esp
f01001d7:	50                   	push   %eax
f01001d8:	68 d8 65 10 f0       	push   $0xf01065d8
f01001dd:	e8 66 37 00 00       	call   f0103948 <cprintf>
	lapic_init();
f01001e2:	e8 56 5d 00 00       	call   f0105f3d <lapic_init>
	env_init_percpu();
f01001e7:	e8 59 2f 00 00       	call   f0103145 <env_init_percpu>
	trap_init_percpu();
f01001ec:	e8 6b 37 00 00       	call   f010395c <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f01001f1:	e8 2d 5d 00 00       	call   f0105f23 <cpunum>
f01001f6:	6b d0 74             	imul   $0x74,%eax,%edx
f01001f9:	83 c2 04             	add    $0x4,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01001fc:	b8 01 00 00 00       	mov    $0x1,%eax
f0100201:	f0 87 82 20 60 21 f0 	lock xchg %eax,-0xfde9fe0(%edx)
f0100208:	c7 04 24 c0 23 12 f0 	movl   $0xf01223c0,(%esp)
f010020f:	e8 7f 5f 00 00       	call   f0106193 <spin_lock>
	cprintf("test...\n");
f0100214:	c7 04 24 ee 65 10 f0 	movl   $0xf01065ee,(%esp)
f010021b:	e8 28 37 00 00       	call   f0103948 <cprintf>
	sched_yield();
f0100220:	e8 65 43 00 00       	call   f010458a <sched_yield>

f0100225 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100225:	55                   	push   %ebp
f0100226:	89 e5                	mov    %esp,%ebp
f0100228:	53                   	push   %ebx
f0100229:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f010022c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f010022f:	ff 75 0c             	pushl  0xc(%ebp)
f0100232:	ff 75 08             	pushl  0x8(%ebp)
f0100235:	68 f7 65 10 f0       	push   $0xf01065f7
f010023a:	e8 09 37 00 00       	call   f0103948 <cprintf>
	vcprintf(fmt, ap);
f010023f:	83 c4 08             	add    $0x8,%esp
f0100242:	53                   	push   %ebx
f0100243:	ff 75 10             	pushl  0x10(%ebp)
f0100246:	e8 d7 36 00 00       	call   f0103922 <vcprintf>
	cprintf("\n");
f010024b:	c7 04 24 c9 68 10 f0 	movl   $0xf01068c9,(%esp)
f0100252:	e8 f1 36 00 00       	call   f0103948 <cprintf>
	va_end(ap);
}
f0100257:	83 c4 10             	add    $0x10,%esp
f010025a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010025d:	c9                   	leave  
f010025e:	c3                   	ret    

f010025f <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010025f:	55                   	push   %ebp
f0100260:	89 e5                	mov    %esp,%ebp
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100262:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100267:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100268:	a8 01                	test   $0x1,%al
f010026a:	74 0b                	je     f0100277 <serial_proc_data+0x18>
f010026c:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100271:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100272:	0f b6 c0             	movzbl %al,%eax
}
f0100275:	5d                   	pop    %ebp
f0100276:	c3                   	ret    
		return -1;
f0100277:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010027c:	eb f7                	jmp    f0100275 <serial_proc_data+0x16>

f010027e <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010027e:	55                   	push   %ebp
f010027f:	89 e5                	mov    %esp,%ebp
f0100281:	53                   	push   %ebx
f0100282:	83 ec 04             	sub    $0x4,%esp
f0100285:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100287:	ff d3                	call   *%ebx
f0100289:	83 f8 ff             	cmp    $0xffffffff,%eax
f010028c:	74 2d                	je     f01002bb <cons_intr+0x3d>
		if (c == 0)
f010028e:	85 c0                	test   %eax,%eax
f0100290:	74 f5                	je     f0100287 <cons_intr+0x9>
			continue;
		cons.buf[cons.wpos++] = c;
f0100292:	8b 0d 24 52 21 f0    	mov    0xf0215224,%ecx
f0100298:	8d 51 01             	lea    0x1(%ecx),%edx
f010029b:	89 15 24 52 21 f0    	mov    %edx,0xf0215224
f01002a1:	88 81 20 50 21 f0    	mov    %al,-0xfdeafe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01002a7:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01002ad:	75 d8                	jne    f0100287 <cons_intr+0x9>
			cons.wpos = 0;
f01002af:	c7 05 24 52 21 f0 00 	movl   $0x0,0xf0215224
f01002b6:	00 00 00 
f01002b9:	eb cc                	jmp    f0100287 <cons_intr+0x9>
	}
}
f01002bb:	83 c4 04             	add    $0x4,%esp
f01002be:	5b                   	pop    %ebx
f01002bf:	5d                   	pop    %ebp
f01002c0:	c3                   	ret    

f01002c1 <kbd_proc_data>:
{
f01002c1:	55                   	push   %ebp
f01002c2:	89 e5                	mov    %esp,%ebp
f01002c4:	53                   	push   %ebx
f01002c5:	83 ec 04             	sub    $0x4,%esp
f01002c8:	ba 64 00 00 00       	mov    $0x64,%edx
f01002cd:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f01002ce:	a8 01                	test   $0x1,%al
f01002d0:	0f 84 fa 00 00 00    	je     f01003d0 <kbd_proc_data+0x10f>
	if (stat & KBS_TERR)
f01002d6:	a8 20                	test   $0x20,%al
f01002d8:	0f 85 f9 00 00 00    	jne    f01003d7 <kbd_proc_data+0x116>
f01002de:	ba 60 00 00 00       	mov    $0x60,%edx
f01002e3:	ec                   	in     (%dx),%al
f01002e4:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f01002e6:	3c e0                	cmp    $0xe0,%al
f01002e8:	0f 84 8e 00 00 00    	je     f010037c <kbd_proc_data+0xbb>
	} else if (data & 0x80) {
f01002ee:	84 c0                	test   %al,%al
f01002f0:	0f 88 99 00 00 00    	js     f010038f <kbd_proc_data+0xce>
	} else if (shift & E0ESC) {
f01002f6:	8b 0d 00 50 21 f0    	mov    0xf0215000,%ecx
f01002fc:	f6 c1 40             	test   $0x40,%cl
f01002ff:	74 0e                	je     f010030f <kbd_proc_data+0x4e>
		data |= 0x80;
f0100301:	83 c8 80             	or     $0xffffff80,%eax
f0100304:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100306:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100309:	89 0d 00 50 21 f0    	mov    %ecx,0xf0215000
	shift |= shiftcode[data];
f010030f:	0f b6 d2             	movzbl %dl,%edx
f0100312:	0f b6 82 60 67 10 f0 	movzbl -0xfef98a0(%edx),%eax
f0100319:	0b 05 00 50 21 f0    	or     0xf0215000,%eax
	shift ^= togglecode[data];
f010031f:	0f b6 8a 60 66 10 f0 	movzbl -0xfef99a0(%edx),%ecx
f0100326:	31 c8                	xor    %ecx,%eax
f0100328:	a3 00 50 21 f0       	mov    %eax,0xf0215000
	c = charcode[shift & (CTL | SHIFT)][data];
f010032d:	89 c1                	mov    %eax,%ecx
f010032f:	83 e1 03             	and    $0x3,%ecx
f0100332:	8b 0c 8d 40 66 10 f0 	mov    -0xfef99c0(,%ecx,4),%ecx
f0100339:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f010033d:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100340:	a8 08                	test   $0x8,%al
f0100342:	74 0d                	je     f0100351 <kbd_proc_data+0x90>
		if ('a' <= c && c <= 'z')
f0100344:	89 da                	mov    %ebx,%edx
f0100346:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100349:	83 f9 19             	cmp    $0x19,%ecx
f010034c:	77 74                	ja     f01003c2 <kbd_proc_data+0x101>
			c += 'A' - 'a';
f010034e:	83 eb 20             	sub    $0x20,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100351:	f7 d0                	not    %eax
f0100353:	a8 06                	test   $0x6,%al
f0100355:	75 31                	jne    f0100388 <kbd_proc_data+0xc7>
f0100357:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f010035d:	75 29                	jne    f0100388 <kbd_proc_data+0xc7>
		cprintf("Rebooting!\n");
f010035f:	83 ec 0c             	sub    $0xc,%esp
f0100362:	68 11 66 10 f0       	push   $0xf0106611
f0100367:	e8 dc 35 00 00       	call   f0103948 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010036c:	b8 03 00 00 00       	mov    $0x3,%eax
f0100371:	ba 92 00 00 00       	mov    $0x92,%edx
f0100376:	ee                   	out    %al,(%dx)
f0100377:	83 c4 10             	add    $0x10,%esp
f010037a:	eb 0c                	jmp    f0100388 <kbd_proc_data+0xc7>
		shift |= E0ESC;
f010037c:	83 0d 00 50 21 f0 40 	orl    $0x40,0xf0215000
		return 0;
f0100383:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0100388:	89 d8                	mov    %ebx,%eax
f010038a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010038d:	c9                   	leave  
f010038e:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f010038f:	8b 0d 00 50 21 f0    	mov    0xf0215000,%ecx
f0100395:	89 cb                	mov    %ecx,%ebx
f0100397:	83 e3 40             	and    $0x40,%ebx
f010039a:	83 e0 7f             	and    $0x7f,%eax
f010039d:	85 db                	test   %ebx,%ebx
f010039f:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01003a2:	0f b6 d2             	movzbl %dl,%edx
f01003a5:	0f b6 82 60 67 10 f0 	movzbl -0xfef98a0(%edx),%eax
f01003ac:	83 c8 40             	or     $0x40,%eax
f01003af:	0f b6 c0             	movzbl %al,%eax
f01003b2:	f7 d0                	not    %eax
f01003b4:	21 c8                	and    %ecx,%eax
f01003b6:	a3 00 50 21 f0       	mov    %eax,0xf0215000
		return 0;
f01003bb:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003c0:	eb c6                	jmp    f0100388 <kbd_proc_data+0xc7>
		else if ('A' <= c && c <= 'Z')
f01003c2:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01003c5:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01003c8:	83 fa 1a             	cmp    $0x1a,%edx
f01003cb:	0f 42 d9             	cmovb  %ecx,%ebx
f01003ce:	eb 81                	jmp    f0100351 <kbd_proc_data+0x90>
		return -1;
f01003d0:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01003d5:	eb b1                	jmp    f0100388 <kbd_proc_data+0xc7>
		return -1;
f01003d7:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01003dc:	eb aa                	jmp    f0100388 <kbd_proc_data+0xc7>

f01003de <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003de:	55                   	push   %ebp
f01003df:	89 e5                	mov    %esp,%ebp
f01003e1:	57                   	push   %edi
f01003e2:	56                   	push   %esi
f01003e3:	53                   	push   %ebx
f01003e4:	83 ec 1c             	sub    $0x1c,%esp
f01003e7:	89 c7                	mov    %eax,%edi
	for (i = 0;
f01003e9:	bb 00 00 00 00       	mov    $0x0,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003ee:	be fd 03 00 00       	mov    $0x3fd,%esi
f01003f3:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003f8:	eb 09                	jmp    f0100403 <cons_putc+0x25>
f01003fa:	89 ca                	mov    %ecx,%edx
f01003fc:	ec                   	in     (%dx),%al
f01003fd:	ec                   	in     (%dx),%al
f01003fe:	ec                   	in     (%dx),%al
f01003ff:	ec                   	in     (%dx),%al
	     i++)
f0100400:	83 c3 01             	add    $0x1,%ebx
f0100403:	89 f2                	mov    %esi,%edx
f0100405:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100406:	a8 20                	test   $0x20,%al
f0100408:	75 08                	jne    f0100412 <cons_putc+0x34>
f010040a:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100410:	7e e8                	jle    f01003fa <cons_putc+0x1c>
	outb(COM1 + COM_TX, c);
f0100412:	89 f8                	mov    %edi,%eax
f0100414:	88 45 e7             	mov    %al,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100417:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010041c:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010041d:	bb 00 00 00 00       	mov    $0x0,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100422:	be 79 03 00 00       	mov    $0x379,%esi
f0100427:	b9 84 00 00 00       	mov    $0x84,%ecx
f010042c:	eb 09                	jmp    f0100437 <cons_putc+0x59>
f010042e:	89 ca                	mov    %ecx,%edx
f0100430:	ec                   	in     (%dx),%al
f0100431:	ec                   	in     (%dx),%al
f0100432:	ec                   	in     (%dx),%al
f0100433:	ec                   	in     (%dx),%al
f0100434:	83 c3 01             	add    $0x1,%ebx
f0100437:	89 f2                	mov    %esi,%edx
f0100439:	ec                   	in     (%dx),%al
f010043a:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100440:	7f 04                	jg     f0100446 <cons_putc+0x68>
f0100442:	84 c0                	test   %al,%al
f0100444:	79 e8                	jns    f010042e <cons_putc+0x50>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100446:	ba 78 03 00 00       	mov    $0x378,%edx
f010044b:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f010044f:	ee                   	out    %al,(%dx)
f0100450:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100455:	b8 0d 00 00 00       	mov    $0xd,%eax
f010045a:	ee                   	out    %al,(%dx)
f010045b:	b8 08 00 00 00       	mov    $0x8,%eax
f0100460:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f0100461:	89 fa                	mov    %edi,%edx
f0100463:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100469:	89 f8                	mov    %edi,%eax
f010046b:	80 cc 07             	or     $0x7,%ah
f010046e:	85 d2                	test   %edx,%edx
f0100470:	0f 44 f8             	cmove  %eax,%edi
	switch (c & 0xff) {
f0100473:	89 f8                	mov    %edi,%eax
f0100475:	0f b6 c0             	movzbl %al,%eax
f0100478:	83 f8 09             	cmp    $0x9,%eax
f010047b:	0f 84 b6 00 00 00    	je     f0100537 <cons_putc+0x159>
f0100481:	83 f8 09             	cmp    $0x9,%eax
f0100484:	7e 73                	jle    f01004f9 <cons_putc+0x11b>
f0100486:	83 f8 0a             	cmp    $0xa,%eax
f0100489:	0f 84 9b 00 00 00    	je     f010052a <cons_putc+0x14c>
f010048f:	83 f8 0d             	cmp    $0xd,%eax
f0100492:	0f 85 d6 00 00 00    	jne    f010056e <cons_putc+0x190>
		crt_pos -= (crt_pos % CRT_COLS);
f0100498:	0f b7 05 28 52 21 f0 	movzwl 0xf0215228,%eax
f010049f:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004a5:	c1 e8 16             	shr    $0x16,%eax
f01004a8:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004ab:	c1 e0 04             	shl    $0x4,%eax
f01004ae:	66 a3 28 52 21 f0    	mov    %ax,0xf0215228
	if (crt_pos >= CRT_SIZE) {
f01004b4:	66 81 3d 28 52 21 f0 	cmpw   $0x7cf,0xf0215228
f01004bb:	cf 07 
f01004bd:	0f 87 ce 00 00 00    	ja     f0100591 <cons_putc+0x1b3>
	outb(addr_6845, 14);
f01004c3:	8b 0d 30 52 21 f0    	mov    0xf0215230,%ecx
f01004c9:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004ce:	89 ca                	mov    %ecx,%edx
f01004d0:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004d1:	0f b7 1d 28 52 21 f0 	movzwl 0xf0215228,%ebx
f01004d8:	8d 71 01             	lea    0x1(%ecx),%esi
f01004db:	89 d8                	mov    %ebx,%eax
f01004dd:	66 c1 e8 08          	shr    $0x8,%ax
f01004e1:	89 f2                	mov    %esi,%edx
f01004e3:	ee                   	out    %al,(%dx)
f01004e4:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004e9:	89 ca                	mov    %ecx,%edx
f01004eb:	ee                   	out    %al,(%dx)
f01004ec:	89 d8                	mov    %ebx,%eax
f01004ee:	89 f2                	mov    %esi,%edx
f01004f0:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004f4:	5b                   	pop    %ebx
f01004f5:	5e                   	pop    %esi
f01004f6:	5f                   	pop    %edi
f01004f7:	5d                   	pop    %ebp
f01004f8:	c3                   	ret    
	switch (c & 0xff) {
f01004f9:	83 f8 08             	cmp    $0x8,%eax
f01004fc:	75 70                	jne    f010056e <cons_putc+0x190>
		if (crt_pos > 0) {
f01004fe:	0f b7 05 28 52 21 f0 	movzwl 0xf0215228,%eax
f0100505:	66 85 c0             	test   %ax,%ax
f0100508:	74 b9                	je     f01004c3 <cons_putc+0xe5>
			crt_pos--;
f010050a:	83 e8 01             	sub    $0x1,%eax
f010050d:	66 a3 28 52 21 f0    	mov    %ax,0xf0215228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100513:	0f b7 c0             	movzwl %ax,%eax
f0100516:	66 81 e7 00 ff       	and    $0xff00,%di
f010051b:	83 cf 20             	or     $0x20,%edi
f010051e:	8b 15 2c 52 21 f0    	mov    0xf021522c,%edx
f0100524:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100528:	eb 8a                	jmp    f01004b4 <cons_putc+0xd6>
		crt_pos += CRT_COLS;
f010052a:	66 83 05 28 52 21 f0 	addw   $0x50,0xf0215228
f0100531:	50 
f0100532:	e9 61 ff ff ff       	jmp    f0100498 <cons_putc+0xba>
		cons_putc(' ');
f0100537:	b8 20 00 00 00       	mov    $0x20,%eax
f010053c:	e8 9d fe ff ff       	call   f01003de <cons_putc>
		cons_putc(' ');
f0100541:	b8 20 00 00 00       	mov    $0x20,%eax
f0100546:	e8 93 fe ff ff       	call   f01003de <cons_putc>
		cons_putc(' ');
f010054b:	b8 20 00 00 00       	mov    $0x20,%eax
f0100550:	e8 89 fe ff ff       	call   f01003de <cons_putc>
		cons_putc(' ');
f0100555:	b8 20 00 00 00       	mov    $0x20,%eax
f010055a:	e8 7f fe ff ff       	call   f01003de <cons_putc>
		cons_putc(' ');
f010055f:	b8 20 00 00 00       	mov    $0x20,%eax
f0100564:	e8 75 fe ff ff       	call   f01003de <cons_putc>
f0100569:	e9 46 ff ff ff       	jmp    f01004b4 <cons_putc+0xd6>
		crt_buf[crt_pos++] = c;		/* write the character */
f010056e:	0f b7 05 28 52 21 f0 	movzwl 0xf0215228,%eax
f0100575:	8d 50 01             	lea    0x1(%eax),%edx
f0100578:	66 89 15 28 52 21 f0 	mov    %dx,0xf0215228
f010057f:	0f b7 c0             	movzwl %ax,%eax
f0100582:	8b 15 2c 52 21 f0    	mov    0xf021522c,%edx
f0100588:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f010058c:	e9 23 ff ff ff       	jmp    f01004b4 <cons_putc+0xd6>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100591:	a1 2c 52 21 f0       	mov    0xf021522c,%eax
f0100596:	83 ec 04             	sub    $0x4,%esp
f0100599:	68 00 0f 00 00       	push   $0xf00
f010059e:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01005a4:	52                   	push   %edx
f01005a5:	50                   	push   %eax
f01005a6:	e8 a1 53 00 00       	call   f010594c <memmove>
			crt_buf[i] = 0x0700 | ' ';
f01005ab:	8b 15 2c 52 21 f0    	mov    0xf021522c,%edx
f01005b1:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01005b7:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01005bd:	83 c4 10             	add    $0x10,%esp
f01005c0:	66 c7 00 20 07       	movw   $0x720,(%eax)
f01005c5:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005c8:	39 d0                	cmp    %edx,%eax
f01005ca:	75 f4                	jne    f01005c0 <cons_putc+0x1e2>
		crt_pos -= CRT_COLS;
f01005cc:	66 83 2d 28 52 21 f0 	subw   $0x50,0xf0215228
f01005d3:	50 
f01005d4:	e9 ea fe ff ff       	jmp    f01004c3 <cons_putc+0xe5>

f01005d9 <serial_intr>:
	if (serial_exists)
f01005d9:	80 3d 34 52 21 f0 00 	cmpb   $0x0,0xf0215234
f01005e0:	75 02                	jne    f01005e4 <serial_intr+0xb>
f01005e2:	f3 c3                	repz ret 
{
f01005e4:	55                   	push   %ebp
f01005e5:	89 e5                	mov    %esp,%ebp
f01005e7:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f01005ea:	b8 5f 02 10 f0       	mov    $0xf010025f,%eax
f01005ef:	e8 8a fc ff ff       	call   f010027e <cons_intr>
}
f01005f4:	c9                   	leave  
f01005f5:	c3                   	ret    

f01005f6 <kbd_intr>:
{
f01005f6:	55                   	push   %ebp
f01005f7:	89 e5                	mov    %esp,%ebp
f01005f9:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01005fc:	b8 c1 02 10 f0       	mov    $0xf01002c1,%eax
f0100601:	e8 78 fc ff ff       	call   f010027e <cons_intr>
}
f0100606:	c9                   	leave  
f0100607:	c3                   	ret    

f0100608 <cons_getc>:
{
f0100608:	55                   	push   %ebp
f0100609:	89 e5                	mov    %esp,%ebp
f010060b:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f010060e:	e8 c6 ff ff ff       	call   f01005d9 <serial_intr>
	kbd_intr();
f0100613:	e8 de ff ff ff       	call   f01005f6 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f0100618:	8b 15 20 52 21 f0    	mov    0xf0215220,%edx
	return 0;
f010061e:	b8 00 00 00 00       	mov    $0x0,%eax
	if (cons.rpos != cons.wpos) {
f0100623:	3b 15 24 52 21 f0    	cmp    0xf0215224,%edx
f0100629:	74 18                	je     f0100643 <cons_getc+0x3b>
		c = cons.buf[cons.rpos++];
f010062b:	8d 4a 01             	lea    0x1(%edx),%ecx
f010062e:	89 0d 20 52 21 f0    	mov    %ecx,0xf0215220
f0100634:	0f b6 82 20 50 21 f0 	movzbl -0xfdeafe0(%edx),%eax
		if (cons.rpos == CONSBUFSIZE)
f010063b:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f0100641:	74 02                	je     f0100645 <cons_getc+0x3d>
}
f0100643:	c9                   	leave  
f0100644:	c3                   	ret    
			cons.rpos = 0;
f0100645:	c7 05 20 52 21 f0 00 	movl   $0x0,0xf0215220
f010064c:	00 00 00 
f010064f:	eb f2                	jmp    f0100643 <cons_getc+0x3b>

f0100651 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100651:	55                   	push   %ebp
f0100652:	89 e5                	mov    %esp,%ebp
f0100654:	57                   	push   %edi
f0100655:	56                   	push   %esi
f0100656:	53                   	push   %ebx
f0100657:	83 ec 0c             	sub    $0xc,%esp
	was = *cp;
f010065a:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100661:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100668:	5a a5 
	if (*cp != 0xA55A) {
f010066a:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100671:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100675:	0f 84 de 00 00 00    	je     f0100759 <cons_init+0x108>
		addr_6845 = MONO_BASE;
f010067b:	c7 05 30 52 21 f0 b4 	movl   $0x3b4,0xf0215230
f0100682:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100685:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
	outb(addr_6845, 14);
f010068a:	8b 3d 30 52 21 f0    	mov    0xf0215230,%edi
f0100690:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100695:	89 fa                	mov    %edi,%edx
f0100697:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100698:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010069b:	89 ca                	mov    %ecx,%edx
f010069d:	ec                   	in     (%dx),%al
f010069e:	0f b6 c0             	movzbl %al,%eax
f01006a1:	c1 e0 08             	shl    $0x8,%eax
f01006a4:	89 c3                	mov    %eax,%ebx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006a6:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006ab:	89 fa                	mov    %edi,%edx
f01006ad:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006ae:	89 ca                	mov    %ecx,%edx
f01006b0:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f01006b1:	89 35 2c 52 21 f0    	mov    %esi,0xf021522c
	pos |= inb(addr_6845 + 1);
f01006b7:	0f b6 c0             	movzbl %al,%eax
f01006ba:	09 d8                	or     %ebx,%eax
	crt_pos = pos;
f01006bc:	66 a3 28 52 21 f0    	mov    %ax,0xf0215228
	kbd_intr();
f01006c2:	e8 2f ff ff ff       	call   f01005f6 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01006c7:	83 ec 0c             	sub    $0xc,%esp
f01006ca:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f01006d1:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006d6:	50                   	push   %eax
f01006d7:	e8 11 31 00 00       	call   f01037ed <irq_setmask_8259A>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006dc:	bb 00 00 00 00       	mov    $0x0,%ebx
f01006e1:	b9 fa 03 00 00       	mov    $0x3fa,%ecx
f01006e6:	89 d8                	mov    %ebx,%eax
f01006e8:	89 ca                	mov    %ecx,%edx
f01006ea:	ee                   	out    %al,(%dx)
f01006eb:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01006f0:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006f5:	89 fa                	mov    %edi,%edx
f01006f7:	ee                   	out    %al,(%dx)
f01006f8:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006fd:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100702:	ee                   	out    %al,(%dx)
f0100703:	be f9 03 00 00       	mov    $0x3f9,%esi
f0100708:	89 d8                	mov    %ebx,%eax
f010070a:	89 f2                	mov    %esi,%edx
f010070c:	ee                   	out    %al,(%dx)
f010070d:	b8 03 00 00 00       	mov    $0x3,%eax
f0100712:	89 fa                	mov    %edi,%edx
f0100714:	ee                   	out    %al,(%dx)
f0100715:	ba fc 03 00 00       	mov    $0x3fc,%edx
f010071a:	89 d8                	mov    %ebx,%eax
f010071c:	ee                   	out    %al,(%dx)
f010071d:	b8 01 00 00 00       	mov    $0x1,%eax
f0100722:	89 f2                	mov    %esi,%edx
f0100724:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100725:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010072a:	ec                   	in     (%dx),%al
f010072b:	89 c3                	mov    %eax,%ebx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010072d:	83 c4 10             	add    $0x10,%esp
f0100730:	3c ff                	cmp    $0xff,%al
f0100732:	0f 95 05 34 52 21 f0 	setne  0xf0215234
f0100739:	89 ca                	mov    %ecx,%edx
f010073b:	ec                   	in     (%dx),%al
f010073c:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100741:	ec                   	in     (%dx),%al
	if (serial_exists)
f0100742:	80 fb ff             	cmp    $0xff,%bl
f0100745:	75 2d                	jne    f0100774 <cons_init+0x123>
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
		cprintf("Serial port does not exist!\n");
f0100747:	83 ec 0c             	sub    $0xc,%esp
f010074a:	68 1d 66 10 f0       	push   $0xf010661d
f010074f:	e8 f4 31 00 00       	call   f0103948 <cprintf>
f0100754:	83 c4 10             	add    $0x10,%esp
}
f0100757:	eb 3c                	jmp    f0100795 <cons_init+0x144>
		*cp = was;
f0100759:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100760:	c7 05 30 52 21 f0 d4 	movl   $0x3d4,0xf0215230
f0100767:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010076a:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f010076f:	e9 16 ff ff ff       	jmp    f010068a <cons_init+0x39>
		irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_SERIAL));
f0100774:	83 ec 0c             	sub    $0xc,%esp
f0100777:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f010077e:	25 ef ff 00 00       	and    $0xffef,%eax
f0100783:	50                   	push   %eax
f0100784:	e8 64 30 00 00       	call   f01037ed <irq_setmask_8259A>
	if (!serial_exists)
f0100789:	83 c4 10             	add    $0x10,%esp
f010078c:	80 3d 34 52 21 f0 00 	cmpb   $0x0,0xf0215234
f0100793:	74 b2                	je     f0100747 <cons_init+0xf6>
}
f0100795:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100798:	5b                   	pop    %ebx
f0100799:	5e                   	pop    %esi
f010079a:	5f                   	pop    %edi
f010079b:	5d                   	pop    %ebp
f010079c:	c3                   	ret    

f010079d <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010079d:	55                   	push   %ebp
f010079e:	89 e5                	mov    %esp,%ebp
f01007a0:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01007a3:	8b 45 08             	mov    0x8(%ebp),%eax
f01007a6:	e8 33 fc ff ff       	call   f01003de <cons_putc>
}
f01007ab:	c9                   	leave  
f01007ac:	c3                   	ret    

f01007ad <getchar>:

int
getchar(void)
{
f01007ad:	55                   	push   %ebp
f01007ae:	89 e5                	mov    %esp,%ebp
f01007b0:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007b3:	e8 50 fe ff ff       	call   f0100608 <cons_getc>
f01007b8:	85 c0                	test   %eax,%eax
f01007ba:	74 f7                	je     f01007b3 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007bc:	c9                   	leave  
f01007bd:	c3                   	ret    

f01007be <iscons>:

int
iscons(int fdnum)
{
f01007be:	55                   	push   %ebp
f01007bf:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007c1:	b8 01 00 00 00       	mov    $0x1,%eax
f01007c6:	5d                   	pop    %ebp
f01007c7:	c3                   	ret    

f01007c8 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007c8:	55                   	push   %ebp
f01007c9:	89 e5                	mov    %esp,%ebp
f01007cb:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007ce:	68 60 68 10 f0       	push   $0xf0106860
f01007d3:	68 7e 68 10 f0       	push   $0xf010687e
f01007d8:	68 83 68 10 f0       	push   $0xf0106883
f01007dd:	e8 66 31 00 00       	call   f0103948 <cprintf>
f01007e2:	83 c4 0c             	add    $0xc,%esp
f01007e5:	68 24 69 10 f0       	push   $0xf0106924
f01007ea:	68 8c 68 10 f0       	push   $0xf010688c
f01007ef:	68 83 68 10 f0       	push   $0xf0106883
f01007f4:	e8 4f 31 00 00       	call   f0103948 <cprintf>
f01007f9:	83 c4 0c             	add    $0xc,%esp
f01007fc:	68 4c 69 10 f0       	push   $0xf010694c
f0100801:	68 95 68 10 f0       	push   $0xf0106895
f0100806:	68 83 68 10 f0       	push   $0xf0106883
f010080b:	e8 38 31 00 00       	call   f0103948 <cprintf>
	return 0;
}
f0100810:	b8 00 00 00 00       	mov    $0x0,%eax
f0100815:	c9                   	leave  
f0100816:	c3                   	ret    

f0100817 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100817:	55                   	push   %ebp
f0100818:	89 e5                	mov    %esp,%ebp
f010081a:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010081d:	68 9f 68 10 f0       	push   $0xf010689f
f0100822:	e8 21 31 00 00       	call   f0103948 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100827:	83 c4 08             	add    $0x8,%esp
f010082a:	68 0c 00 10 00       	push   $0x10000c
f010082f:	68 78 69 10 f0       	push   $0xf0106978
f0100834:	e8 0f 31 00 00       	call   f0103948 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100839:	83 c4 0c             	add    $0xc,%esp
f010083c:	68 0c 00 10 00       	push   $0x10000c
f0100841:	68 0c 00 10 f0       	push   $0xf010000c
f0100846:	68 a0 69 10 f0       	push   $0xf01069a0
f010084b:	e8 f8 30 00 00       	call   f0103948 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100850:	83 c4 0c             	add    $0xc,%esp
f0100853:	68 59 65 10 00       	push   $0x106559
f0100858:	68 59 65 10 f0       	push   $0xf0106559
f010085d:	68 c4 69 10 f0       	push   $0xf01069c4
f0100862:	e8 e1 30 00 00       	call   f0103948 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100867:	83 c4 0c             	add    $0xc,%esp
f010086a:	68 00 50 21 00       	push   $0x215000
f010086f:	68 00 50 21 f0       	push   $0xf0215000
f0100874:	68 e8 69 10 f0       	push   $0xf01069e8
f0100879:	e8 ca 30 00 00       	call   f0103948 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010087e:	83 c4 0c             	add    $0xc,%esp
f0100881:	68 08 70 25 00       	push   $0x257008
f0100886:	68 08 70 25 f0       	push   $0xf0257008
f010088b:	68 0c 6a 10 f0       	push   $0xf0106a0c
f0100890:	e8 b3 30 00 00       	call   f0103948 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100895:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100898:	b8 07 74 25 f0       	mov    $0xf0257407,%eax
f010089d:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f01008a2:	c1 f8 0a             	sar    $0xa,%eax
f01008a5:	50                   	push   %eax
f01008a6:	68 30 6a 10 f0       	push   $0xf0106a30
f01008ab:	e8 98 30 00 00       	call   f0103948 <cprintf>
	return 0;
}
f01008b0:	b8 00 00 00 00       	mov    $0x0,%eax
f01008b5:	c9                   	leave  
f01008b6:	c3                   	ret    

f01008b7 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008b7:	55                   	push   %ebp
f01008b8:	89 e5                	mov    %esp,%ebp
f01008ba:	56                   	push   %esi
f01008bb:	53                   	push   %ebx
f01008bc:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008bf:	89 eb                	mov    %ebp,%ebx
	}*/
	uint32_t *ebp;
	struct Eipdebuginfo info;
	int result;
	ebp = (uint32_t*)read_ebp();
	cprintf("Stack backtrace:\r\n");
f01008c1:	68 b8 68 10 f0       	push   $0xf01068b8
f01008c6:	e8 7d 30 00 00       	call   f0103948 <cprintf>

	while(ebp){
f01008cb:	83 c4 10             	add    $0x10,%esp
	cprintf("    ebp %08x eip %08x args %08x %08x %08x %08x %08x\r\n",ebp,ebp[1],ebp[2],ebp[3],ebp[4],ebp[5],ebp[6]);//ebp[i] what meaning?
	memset(&info,0,sizeof(struct Eipdebuginfo));
f01008ce:	8d 75 e0             	lea    -0x20(%ebp),%esi
	while(ebp){
f01008d1:	eb 25                	jmp    f01008f8 <mon_backtrace+0x41>
	result = debuginfo_eip(ebp[1],&info);
	if(result){
	   cprintf("failed\r\n",ebp[1]);
	}else{
	cprintf("\t%s:%d: %.*s+%u\r\n",info.eip_file,info.eip_line,info.eip_fn_namelen,info.eip_fn_name,ebp[1]-info.eip_fn_addr);
f01008d3:	83 ec 08             	sub    $0x8,%esp
f01008d6:	8b 43 04             	mov    0x4(%ebx),%eax
f01008d9:	2b 45 f0             	sub    -0x10(%ebp),%eax
f01008dc:	50                   	push   %eax
f01008dd:	ff 75 e8             	pushl  -0x18(%ebp)
f01008e0:	ff 75 ec             	pushl  -0x14(%ebp)
f01008e3:	ff 75 e4             	pushl  -0x1c(%ebp)
f01008e6:	ff 75 e0             	pushl  -0x20(%ebp)
f01008e9:	68 d4 68 10 f0       	push   $0xf01068d4
f01008ee:	e8 55 30 00 00       	call   f0103948 <cprintf>
f01008f3:	83 c4 20             	add    $0x20,%esp
	}
	ebp = (uint32_t*)*ebp;
f01008f6:	8b 1b                	mov    (%ebx),%ebx
	while(ebp){
f01008f8:	85 db                	test   %ebx,%ebx
f01008fa:	74 52                	je     f010094e <mon_backtrace+0x97>
	cprintf("    ebp %08x eip %08x args %08x %08x %08x %08x %08x\r\n",ebp,ebp[1],ebp[2],ebp[3],ebp[4],ebp[5],ebp[6]);//ebp[i] what meaning?
f01008fc:	ff 73 18             	pushl  0x18(%ebx)
f01008ff:	ff 73 14             	pushl  0x14(%ebx)
f0100902:	ff 73 10             	pushl  0x10(%ebx)
f0100905:	ff 73 0c             	pushl  0xc(%ebx)
f0100908:	ff 73 08             	pushl  0x8(%ebx)
f010090b:	ff 73 04             	pushl  0x4(%ebx)
f010090e:	53                   	push   %ebx
f010090f:	68 5c 6a 10 f0       	push   $0xf0106a5c
f0100914:	e8 2f 30 00 00       	call   f0103948 <cprintf>
	memset(&info,0,sizeof(struct Eipdebuginfo));
f0100919:	83 c4 1c             	add    $0x1c,%esp
f010091c:	6a 18                	push   $0x18
f010091e:	6a 00                	push   $0x0
f0100920:	56                   	push   %esi
f0100921:	e8 d9 4f 00 00       	call   f01058ff <memset>
	result = debuginfo_eip(ebp[1],&info);
f0100926:	83 c4 08             	add    $0x8,%esp
f0100929:	56                   	push   %esi
f010092a:	ff 73 04             	pushl  0x4(%ebx)
f010092d:	e8 74 44 00 00       	call   f0104da6 <debuginfo_eip>
	if(result){
f0100932:	83 c4 10             	add    $0x10,%esp
f0100935:	85 c0                	test   %eax,%eax
f0100937:	74 9a                	je     f01008d3 <mon_backtrace+0x1c>
	   cprintf("failed\r\n",ebp[1]);
f0100939:	83 ec 08             	sub    $0x8,%esp
f010093c:	ff 73 04             	pushl  0x4(%ebx)
f010093f:	68 cb 68 10 f0       	push   $0xf01068cb
f0100944:	e8 ff 2f 00 00       	call   f0103948 <cprintf>
f0100949:	83 c4 10             	add    $0x10,%esp
f010094c:	eb a8                	jmp    f01008f6 <mon_backtrace+0x3f>
	}
	return 0;
}
f010094e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100953:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100956:	5b                   	pop    %ebx
f0100957:	5e                   	pop    %esi
f0100958:	5d                   	pop    %ebp
f0100959:	c3                   	ret    

f010095a <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010095a:	55                   	push   %ebp
f010095b:	89 e5                	mov    %esp,%ebp
f010095d:	57                   	push   %edi
f010095e:	56                   	push   %esi
f010095f:	53                   	push   %ebx
f0100960:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100963:	68 94 6a 10 f0       	push   $0xf0106a94
f0100968:	e8 db 2f 00 00       	call   f0103948 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010096d:	c7 04 24 b8 6a 10 f0 	movl   $0xf0106ab8,(%esp)
f0100974:	e8 cf 2f 00 00       	call   f0103948 <cprintf>

	if (tf != NULL)
f0100979:	83 c4 10             	add    $0x10,%esp
f010097c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100980:	74 57                	je     f01009d9 <monitor+0x7f>
		print_trapframe(tf);
f0100982:	83 ec 0c             	sub    $0xc,%esp
f0100985:	ff 75 08             	pushl  0x8(%ebp)
f0100988:	e8 6b 35 00 00       	call   f0103ef8 <print_trapframe>
f010098d:	83 c4 10             	add    $0x10,%esp
f0100990:	eb 47                	jmp    f01009d9 <monitor+0x7f>
		while (*buf && strchr(WHITESPACE, *buf))
f0100992:	83 ec 08             	sub    $0x8,%esp
f0100995:	0f be c0             	movsbl %al,%eax
f0100998:	50                   	push   %eax
f0100999:	68 ea 68 10 f0       	push   $0xf01068ea
f010099e:	e8 1f 4f 00 00       	call   f01058c2 <strchr>
f01009a3:	83 c4 10             	add    $0x10,%esp
f01009a6:	85 c0                	test   %eax,%eax
f01009a8:	74 0a                	je     f01009b4 <monitor+0x5a>
			*buf++ = 0;
f01009aa:	c6 03 00             	movb   $0x0,(%ebx)
f01009ad:	89 f7                	mov    %esi,%edi
f01009af:	8d 5b 01             	lea    0x1(%ebx),%ebx
f01009b2:	eb 6b                	jmp    f0100a1f <monitor+0xc5>
		if (*buf == 0)
f01009b4:	80 3b 00             	cmpb   $0x0,(%ebx)
f01009b7:	74 73                	je     f0100a2c <monitor+0xd2>
		if (argc == MAXARGS-1) {
f01009b9:	83 fe 0f             	cmp    $0xf,%esi
f01009bc:	74 09                	je     f01009c7 <monitor+0x6d>
		argv[argc++] = buf;
f01009be:	8d 7e 01             	lea    0x1(%esi),%edi
f01009c1:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01009c5:	eb 39                	jmp    f0100a00 <monitor+0xa6>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01009c7:	83 ec 08             	sub    $0x8,%esp
f01009ca:	6a 10                	push   $0x10
f01009cc:	68 ef 68 10 f0       	push   $0xf01068ef
f01009d1:	e8 72 2f 00 00       	call   f0103948 <cprintf>
f01009d6:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f01009d9:	83 ec 0c             	sub    $0xc,%esp
f01009dc:	68 e6 68 10 f0       	push   $0xf01068e6
f01009e1:	e8 b3 4c 00 00       	call   f0105699 <readline>
f01009e6:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01009e8:	83 c4 10             	add    $0x10,%esp
f01009eb:	85 c0                	test   %eax,%eax
f01009ed:	74 ea                	je     f01009d9 <monitor+0x7f>
	argv[argc] = 0;
f01009ef:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f01009f6:	be 00 00 00 00       	mov    $0x0,%esi
f01009fb:	eb 24                	jmp    f0100a21 <monitor+0xc7>
			buf++;
f01009fd:	83 c3 01             	add    $0x1,%ebx
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a00:	0f b6 03             	movzbl (%ebx),%eax
f0100a03:	84 c0                	test   %al,%al
f0100a05:	74 18                	je     f0100a1f <monitor+0xc5>
f0100a07:	83 ec 08             	sub    $0x8,%esp
f0100a0a:	0f be c0             	movsbl %al,%eax
f0100a0d:	50                   	push   %eax
f0100a0e:	68 ea 68 10 f0       	push   $0xf01068ea
f0100a13:	e8 aa 4e 00 00       	call   f01058c2 <strchr>
f0100a18:	83 c4 10             	add    $0x10,%esp
f0100a1b:	85 c0                	test   %eax,%eax
f0100a1d:	74 de                	je     f01009fd <monitor+0xa3>
			*buf++ = 0;
f0100a1f:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f0100a21:	0f b6 03             	movzbl (%ebx),%eax
f0100a24:	84 c0                	test   %al,%al
f0100a26:	0f 85 66 ff ff ff    	jne    f0100992 <monitor+0x38>
	argv[argc] = 0;
f0100a2c:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100a33:	00 
	if (argc == 0)
f0100a34:	85 f6                	test   %esi,%esi
f0100a36:	74 a1                	je     f01009d9 <monitor+0x7f>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a38:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a3d:	83 ec 08             	sub    $0x8,%esp
f0100a40:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a43:	ff 34 85 e0 6a 10 f0 	pushl  -0xfef9520(,%eax,4)
f0100a4a:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a4d:	e8 12 4e 00 00       	call   f0105864 <strcmp>
f0100a52:	83 c4 10             	add    $0x10,%esp
f0100a55:	85 c0                	test   %eax,%eax
f0100a57:	74 20                	je     f0100a79 <monitor+0x11f>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a59:	83 c3 01             	add    $0x1,%ebx
f0100a5c:	83 fb 03             	cmp    $0x3,%ebx
f0100a5f:	75 dc                	jne    f0100a3d <monitor+0xe3>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a61:	83 ec 08             	sub    $0x8,%esp
f0100a64:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a67:	68 0c 69 10 f0       	push   $0xf010690c
f0100a6c:	e8 d7 2e 00 00       	call   f0103948 <cprintf>
f0100a71:	83 c4 10             	add    $0x10,%esp
f0100a74:	e9 60 ff ff ff       	jmp    f01009d9 <monitor+0x7f>
			return commands[i].func(argc, argv, tf);
f0100a79:	83 ec 04             	sub    $0x4,%esp
f0100a7c:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a7f:	ff 75 08             	pushl  0x8(%ebp)
f0100a82:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a85:	52                   	push   %edx
f0100a86:	56                   	push   %esi
f0100a87:	ff 14 85 e8 6a 10 f0 	call   *-0xfef9518(,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100a8e:	83 c4 10             	add    $0x10,%esp
f0100a91:	85 c0                	test   %eax,%eax
f0100a93:	0f 89 40 ff ff ff    	jns    f01009d9 <monitor+0x7f>
				break;
	}
}
f0100a99:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a9c:	5b                   	pop    %ebx
f0100a9d:	5e                   	pop    %esi
f0100a9e:	5f                   	pop    %edi
f0100a9f:	5d                   	pop    %ebp
f0100aa0:	c3                   	ret    

f0100aa1 <boot_alloc>:
// before the page_free_list list has been set up.
// Note that when this function is called, we are still using entry_pgdir,
// which only maps the first 4MB of physical memory.
static void *
boot_alloc(uint32_t n)
{
f0100aa1:	55                   	push   %ebp
f0100aa2:	89 e5                	mov    %esp,%ebp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100aa4:	83 3d 38 52 21 f0 00 	cmpl   $0x0,0xf0215238
f0100aab:	74 1d                	je     f0100aca <boot_alloc+0x29>
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
        result = nextfree;
f0100aad:	8b 0d 38 52 21 f0    	mov    0xf0215238,%ecx
	nextfree = ROUNDUP(nextfree+n,PGSIZE);
f0100ab3:	8d 94 01 ff 0f 00 00 	lea    0xfff(%ecx,%eax,1),%edx
f0100aba:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100ac0:	89 15 38 52 21 f0    	mov    %edx,0xf0215238
	return result;
}
f0100ac6:	89 c8                	mov    %ecx,%eax
f0100ac8:	5d                   	pop    %ebp
f0100ac9:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100aca:	ba 07 80 25 f0       	mov    $0xf0258007,%edx
f0100acf:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100ad5:	89 15 38 52 21 f0    	mov    %edx,0xf0215238
f0100adb:	eb d0                	jmp    f0100aad <boot_alloc+0xc>

f0100add <nvram_read>:
{
f0100add:	55                   	push   %ebp
f0100ade:	89 e5                	mov    %esp,%ebp
f0100ae0:	56                   	push   %esi
f0100ae1:	53                   	push   %ebx
f0100ae2:	89 c6                	mov    %eax,%esi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100ae4:	83 ec 0c             	sub    $0xc,%esp
f0100ae7:	50                   	push   %eax
f0100ae8:	e8 d2 2c 00 00       	call   f01037bf <mc146818_read>
f0100aed:	89 c3                	mov    %eax,%ebx
f0100aef:	83 c6 01             	add    $0x1,%esi
f0100af2:	89 34 24             	mov    %esi,(%esp)
f0100af5:	e8 c5 2c 00 00       	call   f01037bf <mc146818_read>
f0100afa:	c1 e0 08             	shl    $0x8,%eax
f0100afd:	09 d8                	or     %ebx,%eax
}
f0100aff:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100b02:	5b                   	pop    %ebx
f0100b03:	5e                   	pop    %esi
f0100b04:	5d                   	pop    %ebp
f0100b05:	c3                   	ret    

f0100b06 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100b06:	89 d1                	mov    %edx,%ecx
f0100b08:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100b0b:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100b0e:	a8 01                	test   $0x1,%al
f0100b10:	74 52                	je     f0100b64 <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b12:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0100b17:	89 c1                	mov    %eax,%ecx
f0100b19:	c1 e9 0c             	shr    $0xc,%ecx
f0100b1c:	3b 0d 88 5e 21 f0    	cmp    0xf0215e88,%ecx
f0100b22:	73 25                	jae    f0100b49 <check_va2pa+0x43>
	if (!(p[PTX(va)] & PTE_P))
f0100b24:	c1 ea 0c             	shr    $0xc,%edx
f0100b27:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b2d:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100b34:	89 c2                	mov    %eax,%edx
f0100b36:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b39:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b3e:	85 d2                	test   %edx,%edx
f0100b40:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b45:	0f 44 c2             	cmove  %edx,%eax
f0100b48:	c3                   	ret    
{
f0100b49:	55                   	push   %ebp
f0100b4a:	89 e5                	mov    %esp,%ebp
f0100b4c:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b4f:	50                   	push   %eax
f0100b50:	68 84 65 10 f0       	push   $0xf0106584
f0100b55:	68 95 03 00 00       	push   $0x395
f0100b5a:	68 49 74 10 f0       	push   $0xf0107449
f0100b5f:	e8 dc f4 ff ff       	call   f0100040 <_panic>
		return ~0;
f0100b64:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100b69:	c3                   	ret    

f0100b6a <check_page_free_list>:
{
f0100b6a:	55                   	push   %ebp
f0100b6b:	89 e5                	mov    %esp,%ebp
f0100b6d:	57                   	push   %edi
f0100b6e:	56                   	push   %esi
f0100b6f:	53                   	push   %ebx
f0100b70:	83 ec 2c             	sub    $0x2c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b73:	84 c0                	test   %al,%al
f0100b75:	0f 85 86 02 00 00    	jne    f0100e01 <check_page_free_list+0x297>
	if (!page_free_list)
f0100b7b:	83 3d 40 52 21 f0 00 	cmpl   $0x0,0xf0215240
f0100b82:	74 0a                	je     f0100b8e <check_page_free_list+0x24>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b84:	be 00 04 00 00       	mov    $0x400,%esi
f0100b89:	e9 ce 02 00 00       	jmp    f0100e5c <check_page_free_list+0x2f2>
		panic("'page_free_list' is a null pointer!");
f0100b8e:	83 ec 04             	sub    $0x4,%esp
f0100b91:	68 04 6b 10 f0       	push   $0xf0106b04
f0100b96:	68 c8 02 00 00       	push   $0x2c8
f0100b9b:	68 49 74 10 f0       	push   $0xf0107449
f0100ba0:	e8 9b f4 ff ff       	call   f0100040 <_panic>
f0100ba5:	50                   	push   %eax
f0100ba6:	68 84 65 10 f0       	push   $0xf0106584
f0100bab:	6a 58                	push   $0x58
f0100bad:	68 55 74 10 f0       	push   $0xf0107455
f0100bb2:	e8 89 f4 ff ff       	call   f0100040 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100bb7:	8b 1b                	mov    (%ebx),%ebx
f0100bb9:	85 db                	test   %ebx,%ebx
f0100bbb:	74 41                	je     f0100bfe <check_page_free_list+0x94>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100bbd:	89 d8                	mov    %ebx,%eax
f0100bbf:	2b 05 90 5e 21 f0    	sub    0xf0215e90,%eax
f0100bc5:	c1 f8 03             	sar    $0x3,%eax
f0100bc8:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100bcb:	89 c2                	mov    %eax,%edx
f0100bcd:	c1 ea 16             	shr    $0x16,%edx
f0100bd0:	39 f2                	cmp    %esi,%edx
f0100bd2:	73 e3                	jae    f0100bb7 <check_page_free_list+0x4d>
	if (PGNUM(pa) >= npages)
f0100bd4:	89 c2                	mov    %eax,%edx
f0100bd6:	c1 ea 0c             	shr    $0xc,%edx
f0100bd9:	3b 15 88 5e 21 f0    	cmp    0xf0215e88,%edx
f0100bdf:	73 c4                	jae    f0100ba5 <check_page_free_list+0x3b>
			memset(page2kva(pp), 0x97, 128);
f0100be1:	83 ec 04             	sub    $0x4,%esp
f0100be4:	68 80 00 00 00       	push   $0x80
f0100be9:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100bee:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100bf3:	50                   	push   %eax
f0100bf4:	e8 06 4d 00 00       	call   f01058ff <memset>
f0100bf9:	83 c4 10             	add    $0x10,%esp
f0100bfc:	eb b9                	jmp    f0100bb7 <check_page_free_list+0x4d>
	first_free_page = (char *) boot_alloc(0);
f0100bfe:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c03:	e8 99 fe ff ff       	call   f0100aa1 <boot_alloc>
f0100c08:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c0b:	8b 15 40 52 21 f0    	mov    0xf0215240,%edx
		assert(pp >= pages);
f0100c11:	8b 0d 90 5e 21 f0    	mov    0xf0215e90,%ecx
		assert(pp < pages + npages);
f0100c17:	a1 88 5e 21 f0       	mov    0xf0215e88,%eax
f0100c1c:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100c1f:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100c22:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c25:	89 4d d0             	mov    %ecx,-0x30(%ebp)
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c28:	be 00 00 00 00       	mov    $0x0,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c2d:	e9 04 01 00 00       	jmp    f0100d36 <check_page_free_list+0x1cc>
		assert(pp >= pages);
f0100c32:	68 63 74 10 f0       	push   $0xf0107463
f0100c37:	68 6f 74 10 f0       	push   $0xf010746f
f0100c3c:	68 e2 02 00 00       	push   $0x2e2
f0100c41:	68 49 74 10 f0       	push   $0xf0107449
f0100c46:	e8 f5 f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100c4b:	68 84 74 10 f0       	push   $0xf0107484
f0100c50:	68 6f 74 10 f0       	push   $0xf010746f
f0100c55:	68 e3 02 00 00       	push   $0x2e3
f0100c5a:	68 49 74 10 f0       	push   $0xf0107449
f0100c5f:	e8 dc f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c64:	68 28 6b 10 f0       	push   $0xf0106b28
f0100c69:	68 6f 74 10 f0       	push   $0xf010746f
f0100c6e:	68 e4 02 00 00       	push   $0x2e4
f0100c73:	68 49 74 10 f0       	push   $0xf0107449
f0100c78:	e8 c3 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != 0);
f0100c7d:	68 98 74 10 f0       	push   $0xf0107498
f0100c82:	68 6f 74 10 f0       	push   $0xf010746f
f0100c87:	68 e7 02 00 00       	push   $0x2e7
f0100c8c:	68 49 74 10 f0       	push   $0xf0107449
f0100c91:	e8 aa f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100c96:	68 a9 74 10 f0       	push   $0xf01074a9
f0100c9b:	68 6f 74 10 f0       	push   $0xf010746f
f0100ca0:	68 e8 02 00 00       	push   $0x2e8
f0100ca5:	68 49 74 10 f0       	push   $0xf0107449
f0100caa:	e8 91 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100caf:	68 5c 6b 10 f0       	push   $0xf0106b5c
f0100cb4:	68 6f 74 10 f0       	push   $0xf010746f
f0100cb9:	68 e9 02 00 00       	push   $0x2e9
f0100cbe:	68 49 74 10 f0       	push   $0xf0107449
f0100cc3:	e8 78 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100cc8:	68 c2 74 10 f0       	push   $0xf01074c2
f0100ccd:	68 6f 74 10 f0       	push   $0xf010746f
f0100cd2:	68 ea 02 00 00       	push   $0x2ea
f0100cd7:	68 49 74 10 f0       	push   $0xf0107449
f0100cdc:	e8 5f f3 ff ff       	call   f0100040 <_panic>
	if (PGNUM(pa) >= npages)
f0100ce1:	89 c7                	mov    %eax,%edi
f0100ce3:	c1 ef 0c             	shr    $0xc,%edi
f0100ce6:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0100ce9:	76 1b                	jbe    f0100d06 <check_page_free_list+0x19c>
	return (void *)(pa + KERNBASE);
f0100ceb:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100cf1:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f0100cf4:	77 22                	ja     f0100d18 <check_page_free_list+0x1ae>
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100cf6:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100cfb:	0f 84 98 00 00 00    	je     f0100d99 <check_page_free_list+0x22f>
			++nfree_extmem;
f0100d01:	83 c3 01             	add    $0x1,%ebx
f0100d04:	eb 2e                	jmp    f0100d34 <check_page_free_list+0x1ca>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d06:	50                   	push   %eax
f0100d07:	68 84 65 10 f0       	push   $0xf0106584
f0100d0c:	6a 58                	push   $0x58
f0100d0e:	68 55 74 10 f0       	push   $0xf0107455
f0100d13:	e8 28 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d18:	68 80 6b 10 f0       	push   $0xf0106b80
f0100d1d:	68 6f 74 10 f0       	push   $0xf010746f
f0100d22:	68 eb 02 00 00       	push   $0x2eb
f0100d27:	68 49 74 10 f0       	push   $0xf0107449
f0100d2c:	e8 0f f3 ff ff       	call   f0100040 <_panic>
			++nfree_basemem;
f0100d31:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d34:	8b 12                	mov    (%edx),%edx
f0100d36:	85 d2                	test   %edx,%edx
f0100d38:	74 78                	je     f0100db2 <check_page_free_list+0x248>
		assert(pp >= pages);
f0100d3a:	39 d1                	cmp    %edx,%ecx
f0100d3c:	0f 87 f0 fe ff ff    	ja     f0100c32 <check_page_free_list+0xc8>
		assert(pp < pages + npages);
f0100d42:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0100d45:	0f 86 00 ff ff ff    	jbe    f0100c4b <check_page_free_list+0xe1>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d4b:	89 d0                	mov    %edx,%eax
f0100d4d:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100d50:	a8 07                	test   $0x7,%al
f0100d52:	0f 85 0c ff ff ff    	jne    f0100c64 <check_page_free_list+0xfa>
	return (pp - pages) << PGSHIFT;
f0100d58:	c1 f8 03             	sar    $0x3,%eax
f0100d5b:	c1 e0 0c             	shl    $0xc,%eax
		assert(page2pa(pp) != 0);
f0100d5e:	85 c0                	test   %eax,%eax
f0100d60:	0f 84 17 ff ff ff    	je     f0100c7d <check_page_free_list+0x113>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d66:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d6b:	0f 84 25 ff ff ff    	je     f0100c96 <check_page_free_list+0x12c>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d71:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d76:	0f 84 33 ff ff ff    	je     f0100caf <check_page_free_list+0x145>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d7c:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d81:	0f 84 41 ff ff ff    	je     f0100cc8 <check_page_free_list+0x15e>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d87:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100d8c:	0f 87 4f ff ff ff    	ja     f0100ce1 <check_page_free_list+0x177>
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100d92:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100d97:	75 98                	jne    f0100d31 <check_page_free_list+0x1c7>
f0100d99:	68 dc 74 10 f0       	push   $0xf01074dc
f0100d9e:	68 6f 74 10 f0       	push   $0xf010746f
f0100da3:	68 ed 02 00 00       	push   $0x2ed
f0100da8:	68 49 74 10 f0       	push   $0xf0107449
f0100dad:	e8 8e f2 ff ff       	call   f0100040 <_panic>
	assert(nfree_basemem > 0);
f0100db2:	85 f6                	test   %esi,%esi
f0100db4:	7e 19                	jle    f0100dcf <check_page_free_list+0x265>
	assert(nfree_extmem > 0);
f0100db6:	85 db                	test   %ebx,%ebx
f0100db8:	7e 2e                	jle    f0100de8 <check_page_free_list+0x27e>
	cprintf("check_page_free_list() succeeded!\n");
f0100dba:	83 ec 0c             	sub    $0xc,%esp
f0100dbd:	68 c8 6b 10 f0       	push   $0xf0106bc8
f0100dc2:	e8 81 2b 00 00       	call   f0103948 <cprintf>
}
f0100dc7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100dca:	5b                   	pop    %ebx
f0100dcb:	5e                   	pop    %esi
f0100dcc:	5f                   	pop    %edi
f0100dcd:	5d                   	pop    %ebp
f0100dce:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100dcf:	68 f9 74 10 f0       	push   $0xf01074f9
f0100dd4:	68 6f 74 10 f0       	push   $0xf010746f
f0100dd9:	68 f5 02 00 00       	push   $0x2f5
f0100dde:	68 49 74 10 f0       	push   $0xf0107449
f0100de3:	e8 58 f2 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100de8:	68 0b 75 10 f0       	push   $0xf010750b
f0100ded:	68 6f 74 10 f0       	push   $0xf010746f
f0100df2:	68 f6 02 00 00       	push   $0x2f6
f0100df7:	68 49 74 10 f0       	push   $0xf0107449
f0100dfc:	e8 3f f2 ff ff       	call   f0100040 <_panic>
	if (!page_free_list)
f0100e01:	a1 40 52 21 f0       	mov    0xf0215240,%eax
f0100e06:	85 c0                	test   %eax,%eax
f0100e08:	0f 84 80 fd ff ff    	je     f0100b8e <check_page_free_list+0x24>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100e0e:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100e11:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100e14:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100e17:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100e1a:	89 c2                	mov    %eax,%edx
f0100e1c:	2b 15 90 5e 21 f0    	sub    0xf0215e90,%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100e22:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100e28:	0f 95 c2             	setne  %dl
f0100e2b:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100e2e:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100e32:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100e34:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e38:	8b 00                	mov    (%eax),%eax
f0100e3a:	85 c0                	test   %eax,%eax
f0100e3c:	75 dc                	jne    f0100e1a <check_page_free_list+0x2b0>
		*tp[1] = 0;
f0100e3e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100e41:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100e47:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100e4a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e4d:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100e4f:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100e52:	a3 40 52 21 f0       	mov    %eax,0xf0215240
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100e57:	be 01 00 00 00       	mov    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100e5c:	8b 1d 40 52 21 f0    	mov    0xf0215240,%ebx
f0100e62:	e9 52 fd ff ff       	jmp    f0100bb9 <check_page_free_list+0x4f>

f0100e67 <page_init>:
{
f0100e67:	55                   	push   %ebp
f0100e68:	89 e5                	mov    %esp,%ebp
f0100e6a:	57                   	push   %edi
f0100e6b:	56                   	push   %esi
f0100e6c:	53                   	push   %ebx
f0100e6d:	83 ec 0c             	sub    $0xc,%esp
        page_free_list = NULL;
f0100e70:	c7 05 40 52 21 f0 00 	movl   $0x0,0xf0215240
f0100e77:	00 00 00 
	size_t first_free_extend_addr = PADDR (boot_alloc(0));
f0100e7a:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e7f:	e8 1d fc ff ff       	call   f0100aa1 <boot_alloc>
	if ((uint32_t)kva < KERNBASE)
f0100e84:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100e89:	76 1b                	jbe    f0100ea6 <page_init+0x3f>
	return (physaddr_t)kva - KERNBASE;
f0100e8b:	05 00 00 00 10       	add    $0x10000000,%eax
	for (i = 0; i < npages; i++) {
f0100e90:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100e95:	be 00 00 00 00       	mov    $0x0,%esi
f0100e9a:	ba 00 00 00 00       	mov    $0x0,%edx
		 page_free_list = &pages[i];
f0100e9f:	bf 01 00 00 00       	mov    $0x1,%edi
	for (i = 0; i < npages; i++) {
f0100ea4:	eb 36                	jmp    f0100edc <page_init+0x75>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100ea6:	50                   	push   %eax
f0100ea7:	68 a8 65 10 f0       	push   $0xf01065a8
f0100eac:	68 42 01 00 00       	push   $0x142
f0100eb1:	68 49 74 10 f0       	push   $0xf0107449
f0100eb6:	e8 85 f1 ff ff       	call   f0100040 <_panic>
f0100ebb:	8d 8a 60 ff 0f 00    	lea    0xfff60(%edx),%ecx
f0100ec1:	c1 e1 0c             	shl    $0xc,%ecx
		}else if(i*PGSIZE>=IOPHYSMEM && i*PGSIZE<EXTPHYSMEM){
f0100ec4:	81 f9 ff ff 05 00    	cmp    $0x5ffff,%ecx
f0100eca:	77 2a                	ja     f0100ef6 <page_init+0x8f>
		        pages[i].pp_ref = 1;
f0100ecc:	8b 0d 90 5e 21 f0    	mov    0xf0215e90,%ecx
f0100ed2:	66 c7 44 d1 04 01 00 	movw   $0x1,0x4(%ecx,%edx,8)
	for (i = 0; i < npages; i++) {
f0100ed9:	83 c2 01             	add    $0x1,%edx
f0100edc:	39 15 88 5e 21 f0    	cmp    %edx,0xf0215e88
f0100ee2:	76 6d                	jbe    f0100f51 <page_init+0xea>
		if(i==0){
f0100ee4:	85 d2                	test   %edx,%edx
f0100ee6:	75 d3                	jne    f0100ebb <page_init+0x54>
		  pages[i].pp_ref = 1;
f0100ee8:	8b 0d 90 5e 21 f0    	mov    0xf0215e90,%ecx
f0100eee:	66 c7 41 04 01 00    	movw   $0x1,0x4(%ecx)
f0100ef4:	eb e3                	jmp    f0100ed9 <page_init+0x72>
f0100ef6:	81 c1 00 00 0a 00    	add    $0xa0000,%ecx
		}else if(i*PGSIZE>=EXTPHYSMEM && i*PGSIZE <= first_free_extend_addr){
f0100efc:	39 c8                	cmp    %ecx,%eax
f0100efe:	72 08                	jb     f0100f08 <page_init+0xa1>
f0100f00:	81 f9 ff ff 0f 00    	cmp    $0xfffff,%ecx
f0100f06:	77 2b                	ja     f0100f33 <page_init+0xcc>
		}else if(i*PGSIZE==MPENTRY_PADDR){
f0100f08:	81 f9 00 70 00 00    	cmp    $0x7000,%ecx
f0100f0e:	74 32                	je     f0100f42 <page_init+0xdb>
f0100f10:	8d 0c d5 00 00 00 00 	lea    0x0(,%edx,8),%ecx
                 pages[i].pp_ref = 0;
f0100f17:	89 cb                	mov    %ecx,%ebx
f0100f19:	03 1d 90 5e 21 f0    	add    0xf0215e90,%ebx
f0100f1f:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
		 pages[i].pp_link = page_free_list;
f0100f25:	89 33                	mov    %esi,(%ebx)
		 page_free_list = &pages[i];
f0100f27:	89 ce                	mov    %ecx,%esi
f0100f29:	03 35 90 5e 21 f0    	add    0xf0215e90,%esi
f0100f2f:	89 fb                	mov    %edi,%ebx
f0100f31:	eb a6                	jmp    f0100ed9 <page_init+0x72>
		       pages[i].pp_ref = 1;
f0100f33:	8b 0d 90 5e 21 f0    	mov    0xf0215e90,%ecx
f0100f39:	66 c7 44 d1 04 01 00 	movw   $0x1,0x4(%ecx,%edx,8)
f0100f40:	eb 97                	jmp    f0100ed9 <page_init+0x72>
		        pages[i].pp_ref = 1;
f0100f42:	8b 0d 90 5e 21 f0    	mov    0xf0215e90,%ecx
f0100f48:	66 c7 44 d1 04 01 00 	movw   $0x1,0x4(%ecx,%edx,8)
f0100f4f:	eb 88                	jmp    f0100ed9 <page_init+0x72>
f0100f51:	84 db                	test   %bl,%bl
f0100f53:	75 08                	jne    f0100f5d <page_init+0xf6>
}
f0100f55:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f58:	5b                   	pop    %ebx
f0100f59:	5e                   	pop    %esi
f0100f5a:	5f                   	pop    %edi
f0100f5b:	5d                   	pop    %ebp
f0100f5c:	c3                   	ret    
f0100f5d:	89 35 40 52 21 f0    	mov    %esi,0xf0215240
f0100f63:	eb f0                	jmp    f0100f55 <page_init+0xee>

f0100f65 <page_alloc>:
{
f0100f65:	55                   	push   %ebp
f0100f66:	89 e5                	mov    %esp,%ebp
f0100f68:	53                   	push   %ebx
f0100f69:	83 ec 04             	sub    $0x4,%esp
	if(page_free_list ==NULL)
f0100f6c:	8b 1d 40 52 21 f0    	mov    0xf0215240,%ebx
f0100f72:	85 db                	test   %ebx,%ebx
f0100f74:	74 13                	je     f0100f89 <page_alloc+0x24>
	page_free_list = alloc_space->pp_link;
f0100f76:	8b 03                	mov    (%ebx),%eax
f0100f78:	a3 40 52 21 f0       	mov    %eax,0xf0215240
	alloc_space->pp_link = NULL;
f0100f7d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if(alloc_flags & ALLOC_ZERO){
f0100f83:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100f87:	75 07                	jne    f0100f90 <page_alloc+0x2b>
}
f0100f89:	89 d8                	mov    %ebx,%eax
f0100f8b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f8e:	c9                   	leave  
f0100f8f:	c3                   	ret    
	return (pp - pages) << PGSHIFT;
f0100f90:	89 d8                	mov    %ebx,%eax
f0100f92:	2b 05 90 5e 21 f0    	sub    0xf0215e90,%eax
f0100f98:	c1 f8 03             	sar    $0x3,%eax
f0100f9b:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0100f9e:	89 c2                	mov    %eax,%edx
f0100fa0:	c1 ea 0c             	shr    $0xc,%edx
f0100fa3:	3b 15 88 5e 21 f0    	cmp    0xf0215e88,%edx
f0100fa9:	73 1a                	jae    f0100fc5 <page_alloc+0x60>
	   memset(page2kva(alloc_space),0,PGSIZE);
f0100fab:	83 ec 04             	sub    $0x4,%esp
f0100fae:	68 00 10 00 00       	push   $0x1000
f0100fb3:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0100fb5:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100fba:	50                   	push   %eax
f0100fbb:	e8 3f 49 00 00       	call   f01058ff <memset>
f0100fc0:	83 c4 10             	add    $0x10,%esp
f0100fc3:	eb c4                	jmp    f0100f89 <page_alloc+0x24>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fc5:	50                   	push   %eax
f0100fc6:	68 84 65 10 f0       	push   $0xf0106584
f0100fcb:	6a 58                	push   $0x58
f0100fcd:	68 55 74 10 f0       	push   $0xf0107455
f0100fd2:	e8 69 f0 ff ff       	call   f0100040 <_panic>

f0100fd7 <page_free>:
{
f0100fd7:	55                   	push   %ebp
f0100fd8:	89 e5                	mov    %esp,%ebp
f0100fda:	83 ec 08             	sub    $0x8,%esp
f0100fdd:	8b 45 08             	mov    0x8(%ebp),%eax
	if(pp->pp_ref==0 && pp->pp_link == NULL){
f0100fe0:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100fe5:	75 14                	jne    f0100ffb <page_free+0x24>
f0100fe7:	83 38 00             	cmpl   $0x0,(%eax)
f0100fea:	75 0f                	jne    f0100ffb <page_free+0x24>
	  pp->pp_link = page_free_list;
f0100fec:	8b 15 40 52 21 f0    	mov    0xf0215240,%edx
f0100ff2:	89 10                	mov    %edx,(%eax)
	  page_free_list = pp;
f0100ff4:	a3 40 52 21 f0       	mov    %eax,0xf0215240
}
f0100ff9:	c9                   	leave  
f0100ffa:	c3                   	ret    
	 panic("This page is being used!\n");
f0100ffb:	83 ec 04             	sub    $0x4,%esp
f0100ffe:	68 1c 75 10 f0       	push   $0xf010751c
f0101003:	68 84 01 00 00       	push   $0x184
f0101008:	68 49 74 10 f0       	push   $0xf0107449
f010100d:	e8 2e f0 ff ff       	call   f0100040 <_panic>

f0101012 <page_decref>:
{
f0101012:	55                   	push   %ebp
f0101013:	89 e5                	mov    %esp,%ebp
f0101015:	83 ec 08             	sub    $0x8,%esp
f0101018:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f010101b:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f010101f:	83 e8 01             	sub    $0x1,%eax
f0101022:	66 89 42 04          	mov    %ax,0x4(%edx)
f0101026:	66 85 c0             	test   %ax,%ax
f0101029:	74 02                	je     f010102d <page_decref+0x1b>
}
f010102b:	c9                   	leave  
f010102c:	c3                   	ret    
		page_free(pp);
f010102d:	83 ec 0c             	sub    $0xc,%esp
f0101030:	52                   	push   %edx
f0101031:	e8 a1 ff ff ff       	call   f0100fd7 <page_free>
f0101036:	83 c4 10             	add    $0x10,%esp
}
f0101039:	eb f0                	jmp    f010102b <page_decref+0x19>

f010103b <pgdir_walk>:
{
f010103b:	55                   	push   %ebp
f010103c:	89 e5                	mov    %esp,%ebp
f010103e:	57                   	push   %edi
f010103f:	56                   	push   %esi
f0101040:	53                   	push   %ebx
f0101041:	83 ec 0c             	sub    $0xc,%esp
f0101044:	8b 45 0c             	mov    0xc(%ebp),%eax
        uint32_t ptx = PTX(va);              
f0101047:	89 c6                	mov    %eax,%esi
f0101049:	c1 ee 0c             	shr    $0xc,%esi
f010104c:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	 uint32_t pdx = PDX(va);               
f0101052:	c1 e8 16             	shr    $0x16,%eax
        pte_t *page_dir_entry = pgdir + pdx;  
f0101055:	8d 1c 85 00 00 00 00 	lea    0x0(,%eax,4),%ebx
f010105c:	03 5d 08             	add    0x8(%ebp),%ebx
        if(*page_dir_entry& PTE_P){
f010105f:	8b 03                	mov    (%ebx),%eax
f0101061:	a8 01                	test   $0x1,%al
f0101063:	74 38                	je     f010109d <pgdir_walk+0x62>
          page_table_entry = KADDR(PTE_ADDR(*page_dir_entry));
f0101065:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f010106a:	89 c2                	mov    %eax,%edx
f010106c:	c1 ea 0c             	shr    $0xc,%edx
f010106f:	39 15 88 5e 21 f0    	cmp    %edx,0xf0215e88
f0101075:	76 11                	jbe    f0101088 <pgdir_walk+0x4d>
	return (void *)(pa + KERNBASE);
f0101077:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
        return &page_table_entry[ptx];
f010107d:	8d 04 b2             	lea    (%edx,%esi,4),%eax
}
f0101080:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101083:	5b                   	pop    %ebx
f0101084:	5e                   	pop    %esi
f0101085:	5f                   	pop    %edi
f0101086:	5d                   	pop    %ebp
f0101087:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101088:	50                   	push   %eax
f0101089:	68 84 65 10 f0       	push   $0xf0106584
f010108e:	68 b4 01 00 00       	push   $0x1b4
f0101093:	68 49 74 10 f0       	push   $0xf0107449
f0101098:	e8 a3 ef ff ff       	call   f0100040 <_panic>
         if(!create) return NULL;
f010109d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01010a1:	74 6f                	je     f0101112 <pgdir_walk+0xd7>
         pp = page_alloc(1);
f01010a3:	83 ec 0c             	sub    $0xc,%esp
f01010a6:	6a 01                	push   $0x1
f01010a8:	e8 b8 fe ff ff       	call   f0100f65 <page_alloc>
         if(!pp) return NULL;
f01010ad:	83 c4 10             	add    $0x10,%esp
f01010b0:	85 c0                	test   %eax,%eax
f01010b2:	74 68                	je     f010111c <pgdir_walk+0xe1>
	return (pp - pages) << PGSHIFT;
f01010b4:	89 c1                	mov    %eax,%ecx
f01010b6:	2b 0d 90 5e 21 f0    	sub    0xf0215e90,%ecx
f01010bc:	c1 f9 03             	sar    $0x3,%ecx
f01010bf:	c1 e1 0c             	shl    $0xc,%ecx
	if (PGNUM(pa) >= npages)
f01010c2:	89 ca                	mov    %ecx,%edx
f01010c4:	c1 ea 0c             	shr    $0xc,%edx
f01010c7:	3b 15 88 5e 21 f0    	cmp    0xf0215e88,%edx
f01010cd:	73 1c                	jae    f01010eb <pgdir_walk+0xb0>
	return (void *)(pa + KERNBASE);
f01010cf:	8d b9 00 00 00 f0    	lea    -0x10000000(%ecx),%edi
f01010d5:	89 fa                	mov    %edi,%edx
         pp->pp_ref++;
f01010d7:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	if ((uint32_t)kva < KERNBASE)
f01010dc:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f01010e2:	76 19                	jbe    f01010fd <pgdir_walk+0xc2>
         *page_dir_entry = PADDR(page_table_entry)|PTE_P|PTE_W|PTE_U;
f01010e4:	83 c9 07             	or     $0x7,%ecx
f01010e7:	89 0b                	mov    %ecx,(%ebx)
f01010e9:	eb 92                	jmp    f010107d <pgdir_walk+0x42>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010eb:	51                   	push   %ecx
f01010ec:	68 84 65 10 f0       	push   $0xf0106584
f01010f1:	6a 58                	push   $0x58
f01010f3:	68 55 74 10 f0       	push   $0xf0107455
f01010f8:	e8 43 ef ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01010fd:	57                   	push   %edi
f01010fe:	68 a8 65 10 f0       	push   $0xf01065a8
f0101103:	68 bc 01 00 00       	push   $0x1bc
f0101108:	68 49 74 10 f0       	push   $0xf0107449
f010110d:	e8 2e ef ff ff       	call   f0100040 <_panic>
         if(!create) return NULL;
f0101112:	b8 00 00 00 00       	mov    $0x0,%eax
f0101117:	e9 64 ff ff ff       	jmp    f0101080 <pgdir_walk+0x45>
         if(!pp) return NULL;
f010111c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101121:	e9 5a ff ff ff       	jmp    f0101080 <pgdir_walk+0x45>

f0101126 <boot_map_region>:
{
f0101126:	55                   	push   %ebp
f0101127:	89 e5                	mov    %esp,%ebp
f0101129:	57                   	push   %edi
f010112a:	56                   	push   %esi
f010112b:	53                   	push   %ebx
f010112c:	83 ec 1c             	sub    $0x1c,%esp
f010112f:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101132:	8b 45 08             	mov    0x8(%ebp),%eax
	size_t numpage = size/PGSIZE;
f0101135:	89 cb                	mov    %ecx,%ebx
f0101137:	c1 eb 0c             	shr    $0xc,%ebx
	if(size % PGSIZE !=0) numpage++;
f010113a:	81 e1 ff 0f 00 00    	and    $0xfff,%ecx
f0101140:	83 f9 01             	cmp    $0x1,%ecx
f0101143:	83 db ff             	sbb    $0xffffffff,%ebx
f0101146:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	for(i=0;i<numpage;i++){
f0101149:	89 c3                	mov    %eax,%ebx
f010114b:	be 00 00 00 00       	mov    $0x0,%esi
	  pte_t *pte = pgdir_walk(pgdir,(void *)va,1);
f0101150:	89 d7                	mov    %edx,%edi
f0101152:	29 c7                	sub    %eax,%edi
	  *pte = pa|PTE_P|perm;
f0101154:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101157:	83 c8 01             	or     $0x1,%eax
f010115a:	89 45 dc             	mov    %eax,-0x24(%ebp)
	for(i=0;i<numpage;i++){
f010115d:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
f0101160:	74 41                	je     f01011a3 <boot_map_region+0x7d>
	  pte_t *pte = pgdir_walk(pgdir,(void *)va,1);
f0101162:	83 ec 04             	sub    $0x4,%esp
f0101165:	6a 01                	push   $0x1
f0101167:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f010116a:	50                   	push   %eax
f010116b:	ff 75 e0             	pushl  -0x20(%ebp)
f010116e:	e8 c8 fe ff ff       	call   f010103b <pgdir_walk>
	  if(!pte) panic("boot_map_region:out ouf memory!\n");
f0101173:	83 c4 10             	add    $0x10,%esp
f0101176:	85 c0                	test   %eax,%eax
f0101178:	74 12                	je     f010118c <boot_map_region+0x66>
	  *pte = pa|PTE_P|perm;
f010117a:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010117d:	09 da                	or     %ebx,%edx
f010117f:	89 10                	mov    %edx,(%eax)
	  pa+=PGSIZE;
f0101181:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for(i=0;i<numpage;i++){
f0101187:	83 c6 01             	add    $0x1,%esi
f010118a:	eb d1                	jmp    f010115d <boot_map_region+0x37>
	  if(!pte) panic("boot_map_region:out ouf memory!\n");
f010118c:	83 ec 04             	sub    $0x4,%esp
f010118f:	68 ec 6b 10 f0       	push   $0xf0106bec
f0101194:	68 d6 01 00 00       	push   $0x1d6
f0101199:	68 49 74 10 f0       	push   $0xf0107449
f010119e:	e8 9d ee ff ff       	call   f0100040 <_panic>
}
f01011a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01011a6:	5b                   	pop    %ebx
f01011a7:	5e                   	pop    %esi
f01011a8:	5f                   	pop    %edi
f01011a9:	5d                   	pop    %ebp
f01011aa:	c3                   	ret    

f01011ab <page_lookup>:
{
f01011ab:	55                   	push   %ebp
f01011ac:	89 e5                	mov    %esp,%ebp
f01011ae:	53                   	push   %ebx
f01011af:	83 ec 08             	sub    $0x8,%esp
f01011b2:	8b 5d 10             	mov    0x10(%ebp),%ebx
       	pte_t *pt = pgdir_walk(pgdir,va,0);
f01011b5:	6a 00                	push   $0x0
f01011b7:	ff 75 0c             	pushl  0xc(%ebp)
f01011ba:	ff 75 08             	pushl  0x8(%ebp)
f01011bd:	e8 79 fe ff ff       	call   f010103b <pgdir_walk>
	if(!pt) return NULL;
f01011c2:	83 c4 10             	add    $0x10,%esp
f01011c5:	85 c0                	test   %eax,%eax
f01011c7:	74 35                	je     f01011fe <page_lookup+0x53>
	if(pte_store)
f01011c9:	85 db                	test   %ebx,%ebx
f01011cb:	74 02                	je     f01011cf <page_lookup+0x24>
		*pte_store = pt;
f01011cd:	89 03                	mov    %eax,(%ebx)
f01011cf:	8b 00                	mov    (%eax),%eax
f01011d1:	c1 e8 0c             	shr    $0xc,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01011d4:	39 05 88 5e 21 f0    	cmp    %eax,0xf0215e88
f01011da:	76 0e                	jbe    f01011ea <page_lookup+0x3f>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f01011dc:	8b 15 90 5e 21 f0    	mov    0xf0215e90,%edx
f01011e2:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f01011e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01011e8:	c9                   	leave  
f01011e9:	c3                   	ret    
		panic("pa2page called with invalid pa");
f01011ea:	83 ec 04             	sub    $0x4,%esp
f01011ed:	68 10 6c 10 f0       	push   $0xf0106c10
f01011f2:	6a 51                	push   $0x51
f01011f4:	68 55 74 10 f0       	push   $0xf0107455
f01011f9:	e8 42 ee ff ff       	call   f0100040 <_panic>
	if(!pt) return NULL;
f01011fe:	b8 00 00 00 00       	mov    $0x0,%eax
f0101203:	eb e0                	jmp    f01011e5 <page_lookup+0x3a>

f0101205 <tlb_invalidate>:
{
f0101205:	55                   	push   %ebp
f0101206:	89 e5                	mov    %esp,%ebp
f0101208:	83 ec 08             	sub    $0x8,%esp
	if (!curenv || curenv->env_pgdir == pgdir)
f010120b:	e8 13 4d 00 00       	call   f0105f23 <cpunum>
f0101210:	6b c0 74             	imul   $0x74,%eax,%eax
f0101213:	83 b8 28 60 21 f0 00 	cmpl   $0x0,-0xfde9fd8(%eax)
f010121a:	74 16                	je     f0101232 <tlb_invalidate+0x2d>
f010121c:	e8 02 4d 00 00       	call   f0105f23 <cpunum>
f0101221:	6b c0 74             	imul   $0x74,%eax,%eax
f0101224:	8b 80 28 60 21 f0    	mov    -0xfde9fd8(%eax),%eax
f010122a:	8b 55 08             	mov    0x8(%ebp),%edx
f010122d:	39 50 60             	cmp    %edx,0x60(%eax)
f0101230:	75 06                	jne    f0101238 <tlb_invalidate+0x33>
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101232:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101235:	0f 01 38             	invlpg (%eax)
}
f0101238:	c9                   	leave  
f0101239:	c3                   	ret    

f010123a <page_remove>:
{
f010123a:	55                   	push   %ebp
f010123b:	89 e5                	mov    %esp,%ebp
f010123d:	56                   	push   %esi
f010123e:	53                   	push   %ebx
f010123f:	83 ec 14             	sub    $0x14,%esp
f0101242:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101245:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct PageInfo* pageinfo = page_lookup(pgdir,va,&pte);
f0101248:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010124b:	50                   	push   %eax
f010124c:	56                   	push   %esi
f010124d:	53                   	push   %ebx
f010124e:	e8 58 ff ff ff       	call   f01011ab <page_lookup>
        if(pageinfo && (*pte &PTE_P)){
f0101253:	83 c4 10             	add    $0x10,%esp
f0101256:	85 c0                	test   %eax,%eax
f0101258:	74 08                	je     f0101262 <page_remove+0x28>
f010125a:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010125d:	f6 02 01             	testb  $0x1,(%edx)
f0101260:	75 07                	jne    f0101269 <page_remove+0x2f>
}
f0101262:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101265:	5b                   	pop    %ebx
f0101266:	5e                   	pop    %esi
f0101267:	5d                   	pop    %ebp
f0101268:	c3                   	ret    
	page_decref(pageinfo);
f0101269:	83 ec 0c             	sub    $0xc,%esp
f010126c:	50                   	push   %eax
f010126d:	e8 a0 fd ff ff       	call   f0101012 <page_decref>
	*pte = 0;
f0101272:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101275:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	tlb_invalidate(pgdir,va);
f010127b:	83 c4 08             	add    $0x8,%esp
f010127e:	56                   	push   %esi
f010127f:	53                   	push   %ebx
f0101280:	e8 80 ff ff ff       	call   f0101205 <tlb_invalidate>
f0101285:	83 c4 10             	add    $0x10,%esp
}
f0101288:	eb d8                	jmp    f0101262 <page_remove+0x28>

f010128a <page_insert>:
{
f010128a:	55                   	push   %ebp
f010128b:	89 e5                	mov    %esp,%ebp
f010128d:	57                   	push   %edi
f010128e:	56                   	push   %esi
f010128f:	53                   	push   %ebx
f0101290:	83 ec 10             	sub    $0x10,%esp
f0101293:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101296:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t *pte=pgdir_walk(pgdir,va,1);
f0101299:	6a 01                	push   $0x1
f010129b:	57                   	push   %edi
f010129c:	ff 75 08             	pushl  0x8(%ebp)
f010129f:	e8 97 fd ff ff       	call   f010103b <pgdir_walk>
	if(!pte) return -E_NO_MEM;
f01012a4:	83 c4 10             	add    $0x10,%esp
f01012a7:	85 c0                	test   %eax,%eax
f01012a9:	74 40                	je     f01012eb <page_insert+0x61>
f01012ab:	89 c6                	mov    %eax,%esi
	pp->pp_ref++;
f01012ad:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	if(*pte & PTE_P){
f01012b2:	f6 00 01             	testb  $0x1,(%eax)
f01012b5:	75 23                	jne    f01012da <page_insert+0x50>
	return (pp - pages) << PGSHIFT;
f01012b7:	2b 1d 90 5e 21 f0    	sub    0xf0215e90,%ebx
f01012bd:	c1 fb 03             	sar    $0x3,%ebx
f01012c0:	c1 e3 0c             	shl    $0xc,%ebx
	*pte = PTE_ADDR(page2pa(pp))|perm|PTE_P;
f01012c3:	8b 45 14             	mov    0x14(%ebp),%eax
f01012c6:	83 c8 01             	or     $0x1,%eax
f01012c9:	09 c3                	or     %eax,%ebx
f01012cb:	89 1e                	mov    %ebx,(%esi)
	return 0;
f01012cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01012d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012d5:	5b                   	pop    %ebx
f01012d6:	5e                   	pop    %esi
f01012d7:	5f                   	pop    %edi
f01012d8:	5d                   	pop    %ebp
f01012d9:	c3                   	ret    
		page_remove(pgdir,va);
f01012da:	83 ec 08             	sub    $0x8,%esp
f01012dd:	57                   	push   %edi
f01012de:	ff 75 08             	pushl  0x8(%ebp)
f01012e1:	e8 54 ff ff ff       	call   f010123a <page_remove>
f01012e6:	83 c4 10             	add    $0x10,%esp
f01012e9:	eb cc                	jmp    f01012b7 <page_insert+0x2d>
	if(!pte) return -E_NO_MEM;
f01012eb:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01012f0:	eb e0                	jmp    f01012d2 <page_insert+0x48>

f01012f2 <mmio_map_region>:
{
f01012f2:	55                   	push   %ebp
f01012f3:	89 e5                	mov    %esp,%ebp
f01012f5:	56                   	push   %esi
f01012f6:	53                   	push   %ebx
        size = ROUNDUP(size,PGSIZE);
f01012f7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01012fa:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f0101300:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	void *ret = (void*) base;
f0101306:	8b 35 00 23 12 f0    	mov    0xf0122300,%esi
	if(base+size>MMIOLIM || base+size < base)
f010130c:	89 f0                	mov    %esi,%eax
f010130e:	01 d8                	add    %ebx,%eax
f0101310:	72 2c                	jb     f010133e <mmio_map_region+0x4c>
f0101312:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f0101317:	77 25                	ja     f010133e <mmio_map_region+0x4c>
	boot_map_region(kern_pgdir,base,size,pa,PTE_W|PTE_PCD|PTE_PWT);
f0101319:	83 ec 08             	sub    $0x8,%esp
f010131c:	6a 1a                	push   $0x1a
f010131e:	ff 75 08             	pushl  0x8(%ebp)
f0101321:	89 d9                	mov    %ebx,%ecx
f0101323:	89 f2                	mov    %esi,%edx
f0101325:	a1 8c 5e 21 f0       	mov    0xf0215e8c,%eax
f010132a:	e8 f7 fd ff ff       	call   f0101126 <boot_map_region>
	base+=size;
f010132f:	01 1d 00 23 12 f0    	add    %ebx,0xf0122300
}
f0101335:	89 f0                	mov    %esi,%eax
f0101337:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010133a:	5b                   	pop    %ebx
f010133b:	5e                   	pop    %esi
f010133c:	5d                   	pop    %ebp
f010133d:	c3                   	ret    
		panic("mmio_map_region failed\n");
f010133e:	83 ec 04             	sub    $0x4,%esp
f0101341:	68 36 75 10 f0       	push   $0xf0107536
f0101346:	68 77 02 00 00       	push   $0x277
f010134b:	68 49 74 10 f0       	push   $0xf0107449
f0101350:	e8 eb ec ff ff       	call   f0100040 <_panic>

f0101355 <mem_init>:
{
f0101355:	55                   	push   %ebp
f0101356:	89 e5                	mov    %esp,%ebp
f0101358:	57                   	push   %edi
f0101359:	56                   	push   %esi
f010135a:	53                   	push   %ebx
f010135b:	83 ec 3c             	sub    $0x3c,%esp
	basemem = nvram_read(NVRAM_BASELO);
f010135e:	b8 15 00 00 00       	mov    $0x15,%eax
f0101363:	e8 75 f7 ff ff       	call   f0100add <nvram_read>
f0101368:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f010136a:	b8 17 00 00 00       	mov    $0x17,%eax
f010136f:	e8 69 f7 ff ff       	call   f0100add <nvram_read>
f0101374:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0101376:	b8 34 00 00 00       	mov    $0x34,%eax
f010137b:	e8 5d f7 ff ff       	call   f0100add <nvram_read>
f0101380:	c1 e0 06             	shl    $0x6,%eax
	if (ext16mem)
f0101383:	85 c0                	test   %eax,%eax
f0101385:	0f 85 d9 00 00 00    	jne    f0101464 <mem_init+0x10f>
		totalmem = 1 * 1024 + extmem;
f010138b:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0101391:	85 f6                	test   %esi,%esi
f0101393:	0f 44 c3             	cmove  %ebx,%eax
	npages = totalmem / (PGSIZE / 1024);
f0101396:	89 c2                	mov    %eax,%edx
f0101398:	c1 ea 02             	shr    $0x2,%edx
f010139b:	89 15 88 5e 21 f0    	mov    %edx,0xf0215e88
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01013a1:	89 c2                	mov    %eax,%edx
f01013a3:	29 da                	sub    %ebx,%edx
f01013a5:	52                   	push   %edx
f01013a6:	53                   	push   %ebx
f01013a7:	50                   	push   %eax
f01013a8:	68 30 6c 10 f0       	push   $0xf0106c30
f01013ad:	e8 96 25 00 00       	call   f0103948 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01013b2:	b8 00 10 00 00       	mov    $0x1000,%eax
f01013b7:	e8 e5 f6 ff ff       	call   f0100aa1 <boot_alloc>
f01013bc:	a3 8c 5e 21 f0       	mov    %eax,0xf0215e8c
	memset(kern_pgdir, 0, PGSIZE);
f01013c1:	83 c4 0c             	add    $0xc,%esp
f01013c4:	68 00 10 00 00       	push   $0x1000
f01013c9:	6a 00                	push   $0x0
f01013cb:	50                   	push   %eax
f01013cc:	e8 2e 45 00 00       	call   f01058ff <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01013d1:	a1 8c 5e 21 f0       	mov    0xf0215e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01013d6:	83 c4 10             	add    $0x10,%esp
f01013d9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01013de:	0f 86 8a 00 00 00    	jbe    f010146e <mem_init+0x119>
	return (physaddr_t)kva - KERNBASE;
f01013e4:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01013ea:	83 ca 05             	or     $0x5,%edx
f01013ed:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
        pages =(struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f01013f3:	a1 88 5e 21 f0       	mov    0xf0215e88,%eax
f01013f8:	c1 e0 03             	shl    $0x3,%eax
f01013fb:	e8 a1 f6 ff ff       	call   f0100aa1 <boot_alloc>
f0101400:	a3 90 5e 21 f0       	mov    %eax,0xf0215e90
        memset(pages,0, npages * sizeof(struct PageInfo));
f0101405:	83 ec 04             	sub    $0x4,%esp
f0101408:	8b 0d 88 5e 21 f0    	mov    0xf0215e88,%ecx
f010140e:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f0101415:	52                   	push   %edx
f0101416:	6a 00                	push   $0x0
f0101418:	50                   	push   %eax
f0101419:	e8 e1 44 00 00       	call   f01058ff <memset>
        envs = (struct Env*) boot_alloc(sizeof(struct Env)*NENV);
f010141e:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0101423:	e8 79 f6 ff ff       	call   f0100aa1 <boot_alloc>
f0101428:	a3 44 52 21 f0       	mov    %eax,0xf0215244
	memset(envs,0,sizeof(struct Env) * NENV);
f010142d:	83 c4 0c             	add    $0xc,%esp
f0101430:	68 00 f0 01 00       	push   $0x1f000
f0101435:	6a 00                	push   $0x0
f0101437:	50                   	push   %eax
f0101438:	e8 c2 44 00 00       	call   f01058ff <memset>
	page_init();
f010143d:	e8 25 fa ff ff       	call   f0100e67 <page_init>
	check_page_free_list(1);
f0101442:	b8 01 00 00 00       	mov    $0x1,%eax
f0101447:	e8 1e f7 ff ff       	call   f0100b6a <check_page_free_list>
	if (!pages)
f010144c:	83 c4 10             	add    $0x10,%esp
f010144f:	83 3d 90 5e 21 f0 00 	cmpl   $0x0,0xf0215e90
f0101456:	74 2b                	je     f0101483 <mem_init+0x12e>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101458:	a1 40 52 21 f0       	mov    0xf0215240,%eax
f010145d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101462:	eb 3b                	jmp    f010149f <mem_init+0x14a>
		totalmem = 16 * 1024 + ext16mem;
f0101464:	05 00 40 00 00       	add    $0x4000,%eax
f0101469:	e9 28 ff ff ff       	jmp    f0101396 <mem_init+0x41>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010146e:	50                   	push   %eax
f010146f:	68 a8 65 10 f0       	push   $0xf01065a8
f0101474:	68 95 00 00 00       	push   $0x95
f0101479:	68 49 74 10 f0       	push   $0xf0107449
f010147e:	e8 bd eb ff ff       	call   f0100040 <_panic>
		panic("'pages' is a null pointer!");
f0101483:	83 ec 04             	sub    $0x4,%esp
f0101486:	68 4e 75 10 f0       	push   $0xf010754e
f010148b:	68 09 03 00 00       	push   $0x309
f0101490:	68 49 74 10 f0       	push   $0xf0107449
f0101495:	e8 a6 eb ff ff       	call   f0100040 <_panic>
		++nfree;
f010149a:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010149d:	8b 00                	mov    (%eax),%eax
f010149f:	85 c0                	test   %eax,%eax
f01014a1:	75 f7                	jne    f010149a <mem_init+0x145>
	assert((pp0 = page_alloc(0)));
f01014a3:	83 ec 0c             	sub    $0xc,%esp
f01014a6:	6a 00                	push   $0x0
f01014a8:	e8 b8 fa ff ff       	call   f0100f65 <page_alloc>
f01014ad:	89 c7                	mov    %eax,%edi
f01014af:	83 c4 10             	add    $0x10,%esp
f01014b2:	85 c0                	test   %eax,%eax
f01014b4:	0f 84 12 02 00 00    	je     f01016cc <mem_init+0x377>
	assert((pp1 = page_alloc(0)));
f01014ba:	83 ec 0c             	sub    $0xc,%esp
f01014bd:	6a 00                	push   $0x0
f01014bf:	e8 a1 fa ff ff       	call   f0100f65 <page_alloc>
f01014c4:	89 c6                	mov    %eax,%esi
f01014c6:	83 c4 10             	add    $0x10,%esp
f01014c9:	85 c0                	test   %eax,%eax
f01014cb:	0f 84 14 02 00 00    	je     f01016e5 <mem_init+0x390>
	assert((pp2 = page_alloc(0)));
f01014d1:	83 ec 0c             	sub    $0xc,%esp
f01014d4:	6a 00                	push   $0x0
f01014d6:	e8 8a fa ff ff       	call   f0100f65 <page_alloc>
f01014db:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01014de:	83 c4 10             	add    $0x10,%esp
f01014e1:	85 c0                	test   %eax,%eax
f01014e3:	0f 84 15 02 00 00    	je     f01016fe <mem_init+0x3a9>
	assert(pp1 && pp1 != pp0);
f01014e9:	39 f7                	cmp    %esi,%edi
f01014eb:	0f 84 26 02 00 00    	je     f0101717 <mem_init+0x3c2>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01014f1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01014f4:	39 c7                	cmp    %eax,%edi
f01014f6:	0f 84 34 02 00 00    	je     f0101730 <mem_init+0x3db>
f01014fc:	39 c6                	cmp    %eax,%esi
f01014fe:	0f 84 2c 02 00 00    	je     f0101730 <mem_init+0x3db>
	return (pp - pages) << PGSHIFT;
f0101504:	8b 0d 90 5e 21 f0    	mov    0xf0215e90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f010150a:	8b 15 88 5e 21 f0    	mov    0xf0215e88,%edx
f0101510:	c1 e2 0c             	shl    $0xc,%edx
f0101513:	89 f8                	mov    %edi,%eax
f0101515:	29 c8                	sub    %ecx,%eax
f0101517:	c1 f8 03             	sar    $0x3,%eax
f010151a:	c1 e0 0c             	shl    $0xc,%eax
f010151d:	39 d0                	cmp    %edx,%eax
f010151f:	0f 83 24 02 00 00    	jae    f0101749 <mem_init+0x3f4>
f0101525:	89 f0                	mov    %esi,%eax
f0101527:	29 c8                	sub    %ecx,%eax
f0101529:	c1 f8 03             	sar    $0x3,%eax
f010152c:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f010152f:	39 c2                	cmp    %eax,%edx
f0101531:	0f 86 2b 02 00 00    	jbe    f0101762 <mem_init+0x40d>
f0101537:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010153a:	29 c8                	sub    %ecx,%eax
f010153c:	c1 f8 03             	sar    $0x3,%eax
f010153f:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f0101542:	39 c2                	cmp    %eax,%edx
f0101544:	0f 86 31 02 00 00    	jbe    f010177b <mem_init+0x426>
	fl = page_free_list;
f010154a:	a1 40 52 21 f0       	mov    0xf0215240,%eax
f010154f:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101552:	c7 05 40 52 21 f0 00 	movl   $0x0,0xf0215240
f0101559:	00 00 00 
	assert(!page_alloc(0));
f010155c:	83 ec 0c             	sub    $0xc,%esp
f010155f:	6a 00                	push   $0x0
f0101561:	e8 ff f9 ff ff       	call   f0100f65 <page_alloc>
f0101566:	83 c4 10             	add    $0x10,%esp
f0101569:	85 c0                	test   %eax,%eax
f010156b:	0f 85 23 02 00 00    	jne    f0101794 <mem_init+0x43f>
	page_free(pp0);
f0101571:	83 ec 0c             	sub    $0xc,%esp
f0101574:	57                   	push   %edi
f0101575:	e8 5d fa ff ff       	call   f0100fd7 <page_free>
	page_free(pp1);
f010157a:	89 34 24             	mov    %esi,(%esp)
f010157d:	e8 55 fa ff ff       	call   f0100fd7 <page_free>
	page_free(pp2);
f0101582:	83 c4 04             	add    $0x4,%esp
f0101585:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101588:	e8 4a fa ff ff       	call   f0100fd7 <page_free>
	assert((pp0 = page_alloc(0)));
f010158d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101594:	e8 cc f9 ff ff       	call   f0100f65 <page_alloc>
f0101599:	89 c6                	mov    %eax,%esi
f010159b:	83 c4 10             	add    $0x10,%esp
f010159e:	85 c0                	test   %eax,%eax
f01015a0:	0f 84 07 02 00 00    	je     f01017ad <mem_init+0x458>
	assert((pp1 = page_alloc(0)));
f01015a6:	83 ec 0c             	sub    $0xc,%esp
f01015a9:	6a 00                	push   $0x0
f01015ab:	e8 b5 f9 ff ff       	call   f0100f65 <page_alloc>
f01015b0:	89 c7                	mov    %eax,%edi
f01015b2:	83 c4 10             	add    $0x10,%esp
f01015b5:	85 c0                	test   %eax,%eax
f01015b7:	0f 84 09 02 00 00    	je     f01017c6 <mem_init+0x471>
	assert((pp2 = page_alloc(0)));
f01015bd:	83 ec 0c             	sub    $0xc,%esp
f01015c0:	6a 00                	push   $0x0
f01015c2:	e8 9e f9 ff ff       	call   f0100f65 <page_alloc>
f01015c7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01015ca:	83 c4 10             	add    $0x10,%esp
f01015cd:	85 c0                	test   %eax,%eax
f01015cf:	0f 84 0a 02 00 00    	je     f01017df <mem_init+0x48a>
	assert(pp1 && pp1 != pp0);
f01015d5:	39 fe                	cmp    %edi,%esi
f01015d7:	0f 84 1b 02 00 00    	je     f01017f8 <mem_init+0x4a3>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01015dd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01015e0:	39 c7                	cmp    %eax,%edi
f01015e2:	0f 84 29 02 00 00    	je     f0101811 <mem_init+0x4bc>
f01015e8:	39 c6                	cmp    %eax,%esi
f01015ea:	0f 84 21 02 00 00    	je     f0101811 <mem_init+0x4bc>
	assert(!page_alloc(0));
f01015f0:	83 ec 0c             	sub    $0xc,%esp
f01015f3:	6a 00                	push   $0x0
f01015f5:	e8 6b f9 ff ff       	call   f0100f65 <page_alloc>
f01015fa:	83 c4 10             	add    $0x10,%esp
f01015fd:	85 c0                	test   %eax,%eax
f01015ff:	0f 85 25 02 00 00    	jne    f010182a <mem_init+0x4d5>
f0101605:	89 f0                	mov    %esi,%eax
f0101607:	2b 05 90 5e 21 f0    	sub    0xf0215e90,%eax
f010160d:	c1 f8 03             	sar    $0x3,%eax
f0101610:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101613:	89 c2                	mov    %eax,%edx
f0101615:	c1 ea 0c             	shr    $0xc,%edx
f0101618:	3b 15 88 5e 21 f0    	cmp    0xf0215e88,%edx
f010161e:	0f 83 1f 02 00 00    	jae    f0101843 <mem_init+0x4ee>
	memset(page2kva(pp0), 1, PGSIZE);
f0101624:	83 ec 04             	sub    $0x4,%esp
f0101627:	68 00 10 00 00       	push   $0x1000
f010162c:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f010162e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101633:	50                   	push   %eax
f0101634:	e8 c6 42 00 00       	call   f01058ff <memset>
	page_free(pp0);
f0101639:	89 34 24             	mov    %esi,(%esp)
f010163c:	e8 96 f9 ff ff       	call   f0100fd7 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101641:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101648:	e8 18 f9 ff ff       	call   f0100f65 <page_alloc>
f010164d:	83 c4 10             	add    $0x10,%esp
f0101650:	85 c0                	test   %eax,%eax
f0101652:	0f 84 fd 01 00 00    	je     f0101855 <mem_init+0x500>
	assert(pp && pp0 == pp);
f0101658:	39 c6                	cmp    %eax,%esi
f010165a:	0f 85 0e 02 00 00    	jne    f010186e <mem_init+0x519>
	return (pp - pages) << PGSHIFT;
f0101660:	89 f2                	mov    %esi,%edx
f0101662:	2b 15 90 5e 21 f0    	sub    0xf0215e90,%edx
f0101668:	c1 fa 03             	sar    $0x3,%edx
f010166b:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f010166e:	89 d0                	mov    %edx,%eax
f0101670:	c1 e8 0c             	shr    $0xc,%eax
f0101673:	3b 05 88 5e 21 f0    	cmp    0xf0215e88,%eax
f0101679:	0f 83 08 02 00 00    	jae    f0101887 <mem_init+0x532>
	return (void *)(pa + KERNBASE);
f010167f:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101685:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f010168b:	80 38 00             	cmpb   $0x0,(%eax)
f010168e:	0f 85 05 02 00 00    	jne    f0101899 <mem_init+0x544>
f0101694:	83 c0 01             	add    $0x1,%eax
	for (i = 0; i < PGSIZE; i++)
f0101697:	39 d0                	cmp    %edx,%eax
f0101699:	75 f0                	jne    f010168b <mem_init+0x336>
	page_free_list = fl;
f010169b:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010169e:	a3 40 52 21 f0       	mov    %eax,0xf0215240
	page_free(pp0);
f01016a3:	83 ec 0c             	sub    $0xc,%esp
f01016a6:	56                   	push   %esi
f01016a7:	e8 2b f9 ff ff       	call   f0100fd7 <page_free>
	page_free(pp1);
f01016ac:	89 3c 24             	mov    %edi,(%esp)
f01016af:	e8 23 f9 ff ff       	call   f0100fd7 <page_free>
	page_free(pp2);
f01016b4:	83 c4 04             	add    $0x4,%esp
f01016b7:	ff 75 d4             	pushl  -0x2c(%ebp)
f01016ba:	e8 18 f9 ff ff       	call   f0100fd7 <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01016bf:	a1 40 52 21 f0       	mov    0xf0215240,%eax
f01016c4:	83 c4 10             	add    $0x10,%esp
f01016c7:	e9 eb 01 00 00       	jmp    f01018b7 <mem_init+0x562>
	assert((pp0 = page_alloc(0)));
f01016cc:	68 69 75 10 f0       	push   $0xf0107569
f01016d1:	68 6f 74 10 f0       	push   $0xf010746f
f01016d6:	68 11 03 00 00       	push   $0x311
f01016db:	68 49 74 10 f0       	push   $0xf0107449
f01016e0:	e8 5b e9 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01016e5:	68 7f 75 10 f0       	push   $0xf010757f
f01016ea:	68 6f 74 10 f0       	push   $0xf010746f
f01016ef:	68 12 03 00 00       	push   $0x312
f01016f4:	68 49 74 10 f0       	push   $0xf0107449
f01016f9:	e8 42 e9 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01016fe:	68 95 75 10 f0       	push   $0xf0107595
f0101703:	68 6f 74 10 f0       	push   $0xf010746f
f0101708:	68 13 03 00 00       	push   $0x313
f010170d:	68 49 74 10 f0       	push   $0xf0107449
f0101712:	e8 29 e9 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f0101717:	68 ab 75 10 f0       	push   $0xf01075ab
f010171c:	68 6f 74 10 f0       	push   $0xf010746f
f0101721:	68 16 03 00 00       	push   $0x316
f0101726:	68 49 74 10 f0       	push   $0xf0107449
f010172b:	e8 10 e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101730:	68 6c 6c 10 f0       	push   $0xf0106c6c
f0101735:	68 6f 74 10 f0       	push   $0xf010746f
f010173a:	68 17 03 00 00       	push   $0x317
f010173f:	68 49 74 10 f0       	push   $0xf0107449
f0101744:	e8 f7 e8 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f0101749:	68 bd 75 10 f0       	push   $0xf01075bd
f010174e:	68 6f 74 10 f0       	push   $0xf010746f
f0101753:	68 18 03 00 00       	push   $0x318
f0101758:	68 49 74 10 f0       	push   $0xf0107449
f010175d:	e8 de e8 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101762:	68 da 75 10 f0       	push   $0xf01075da
f0101767:	68 6f 74 10 f0       	push   $0xf010746f
f010176c:	68 19 03 00 00       	push   $0x319
f0101771:	68 49 74 10 f0       	push   $0xf0107449
f0101776:	e8 c5 e8 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f010177b:	68 f7 75 10 f0       	push   $0xf01075f7
f0101780:	68 6f 74 10 f0       	push   $0xf010746f
f0101785:	68 1a 03 00 00       	push   $0x31a
f010178a:	68 49 74 10 f0       	push   $0xf0107449
f010178f:	e8 ac e8 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101794:	68 14 76 10 f0       	push   $0xf0107614
f0101799:	68 6f 74 10 f0       	push   $0xf010746f
f010179e:	68 21 03 00 00       	push   $0x321
f01017a3:	68 49 74 10 f0       	push   $0xf0107449
f01017a8:	e8 93 e8 ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f01017ad:	68 69 75 10 f0       	push   $0xf0107569
f01017b2:	68 6f 74 10 f0       	push   $0xf010746f
f01017b7:	68 28 03 00 00       	push   $0x328
f01017bc:	68 49 74 10 f0       	push   $0xf0107449
f01017c1:	e8 7a e8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01017c6:	68 7f 75 10 f0       	push   $0xf010757f
f01017cb:	68 6f 74 10 f0       	push   $0xf010746f
f01017d0:	68 29 03 00 00       	push   $0x329
f01017d5:	68 49 74 10 f0       	push   $0xf0107449
f01017da:	e8 61 e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01017df:	68 95 75 10 f0       	push   $0xf0107595
f01017e4:	68 6f 74 10 f0       	push   $0xf010746f
f01017e9:	68 2a 03 00 00       	push   $0x32a
f01017ee:	68 49 74 10 f0       	push   $0xf0107449
f01017f3:	e8 48 e8 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f01017f8:	68 ab 75 10 f0       	push   $0xf01075ab
f01017fd:	68 6f 74 10 f0       	push   $0xf010746f
f0101802:	68 2c 03 00 00       	push   $0x32c
f0101807:	68 49 74 10 f0       	push   $0xf0107449
f010180c:	e8 2f e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101811:	68 6c 6c 10 f0       	push   $0xf0106c6c
f0101816:	68 6f 74 10 f0       	push   $0xf010746f
f010181b:	68 2d 03 00 00       	push   $0x32d
f0101820:	68 49 74 10 f0       	push   $0xf0107449
f0101825:	e8 16 e8 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f010182a:	68 14 76 10 f0       	push   $0xf0107614
f010182f:	68 6f 74 10 f0       	push   $0xf010746f
f0101834:	68 2e 03 00 00       	push   $0x32e
f0101839:	68 49 74 10 f0       	push   $0xf0107449
f010183e:	e8 fd e7 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101843:	50                   	push   %eax
f0101844:	68 84 65 10 f0       	push   $0xf0106584
f0101849:	6a 58                	push   $0x58
f010184b:	68 55 74 10 f0       	push   $0xf0107455
f0101850:	e8 eb e7 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101855:	68 23 76 10 f0       	push   $0xf0107623
f010185a:	68 6f 74 10 f0       	push   $0xf010746f
f010185f:	68 33 03 00 00       	push   $0x333
f0101864:	68 49 74 10 f0       	push   $0xf0107449
f0101869:	e8 d2 e7 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f010186e:	68 41 76 10 f0       	push   $0xf0107641
f0101873:	68 6f 74 10 f0       	push   $0xf010746f
f0101878:	68 34 03 00 00       	push   $0x334
f010187d:	68 49 74 10 f0       	push   $0xf0107449
f0101882:	e8 b9 e7 ff ff       	call   f0100040 <_panic>
f0101887:	52                   	push   %edx
f0101888:	68 84 65 10 f0       	push   $0xf0106584
f010188d:	6a 58                	push   $0x58
f010188f:	68 55 74 10 f0       	push   $0xf0107455
f0101894:	e8 a7 e7 ff ff       	call   f0100040 <_panic>
		assert(c[i] == 0);
f0101899:	68 51 76 10 f0       	push   $0xf0107651
f010189e:	68 6f 74 10 f0       	push   $0xf010746f
f01018a3:	68 37 03 00 00       	push   $0x337
f01018a8:	68 49 74 10 f0       	push   $0xf0107449
f01018ad:	e8 8e e7 ff ff       	call   f0100040 <_panic>
		--nfree;
f01018b2:	83 eb 01             	sub    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01018b5:	8b 00                	mov    (%eax),%eax
f01018b7:	85 c0                	test   %eax,%eax
f01018b9:	75 f7                	jne    f01018b2 <mem_init+0x55d>
	assert(nfree == 0);
f01018bb:	85 db                	test   %ebx,%ebx
f01018bd:	0f 85 64 09 00 00    	jne    f0102227 <mem_init+0xed2>
	cprintf("check_page_alloc() succeeded!\n");
f01018c3:	83 ec 0c             	sub    $0xc,%esp
f01018c6:	68 8c 6c 10 f0       	push   $0xf0106c8c
f01018cb:	e8 78 20 00 00       	call   f0103948 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01018d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01018d7:	e8 89 f6 ff ff       	call   f0100f65 <page_alloc>
f01018dc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01018df:	83 c4 10             	add    $0x10,%esp
f01018e2:	85 c0                	test   %eax,%eax
f01018e4:	0f 84 56 09 00 00    	je     f0102240 <mem_init+0xeeb>
	assert((pp1 = page_alloc(0)));
f01018ea:	83 ec 0c             	sub    $0xc,%esp
f01018ed:	6a 00                	push   $0x0
f01018ef:	e8 71 f6 ff ff       	call   f0100f65 <page_alloc>
f01018f4:	89 c3                	mov    %eax,%ebx
f01018f6:	83 c4 10             	add    $0x10,%esp
f01018f9:	85 c0                	test   %eax,%eax
f01018fb:	0f 84 58 09 00 00    	je     f0102259 <mem_init+0xf04>
	assert((pp2 = page_alloc(0)));
f0101901:	83 ec 0c             	sub    $0xc,%esp
f0101904:	6a 00                	push   $0x0
f0101906:	e8 5a f6 ff ff       	call   f0100f65 <page_alloc>
f010190b:	89 c6                	mov    %eax,%esi
f010190d:	83 c4 10             	add    $0x10,%esp
f0101910:	85 c0                	test   %eax,%eax
f0101912:	0f 84 5a 09 00 00    	je     f0102272 <mem_init+0xf1d>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101918:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f010191b:	0f 84 6a 09 00 00    	je     f010228b <mem_init+0xf36>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101921:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101924:	0f 84 7a 09 00 00    	je     f01022a4 <mem_init+0xf4f>
f010192a:	39 c3                	cmp    %eax,%ebx
f010192c:	0f 84 72 09 00 00    	je     f01022a4 <mem_init+0xf4f>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101932:	a1 40 52 21 f0       	mov    0xf0215240,%eax
f0101937:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f010193a:	c7 05 40 52 21 f0 00 	movl   $0x0,0xf0215240
f0101941:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101944:	83 ec 0c             	sub    $0xc,%esp
f0101947:	6a 00                	push   $0x0
f0101949:	e8 17 f6 ff ff       	call   f0100f65 <page_alloc>
f010194e:	83 c4 10             	add    $0x10,%esp
f0101951:	85 c0                	test   %eax,%eax
f0101953:	0f 85 64 09 00 00    	jne    f01022bd <mem_init+0xf68>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101959:	83 ec 04             	sub    $0x4,%esp
f010195c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010195f:	50                   	push   %eax
f0101960:	6a 00                	push   $0x0
f0101962:	ff 35 8c 5e 21 f0    	pushl  0xf0215e8c
f0101968:	e8 3e f8 ff ff       	call   f01011ab <page_lookup>
f010196d:	83 c4 10             	add    $0x10,%esp
f0101970:	85 c0                	test   %eax,%eax
f0101972:	0f 85 5e 09 00 00    	jne    f01022d6 <mem_init+0xf81>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101978:	6a 02                	push   $0x2
f010197a:	6a 00                	push   $0x0
f010197c:	53                   	push   %ebx
f010197d:	ff 35 8c 5e 21 f0    	pushl  0xf0215e8c
f0101983:	e8 02 f9 ff ff       	call   f010128a <page_insert>
f0101988:	83 c4 10             	add    $0x10,%esp
f010198b:	85 c0                	test   %eax,%eax
f010198d:	0f 89 5c 09 00 00    	jns    f01022ef <mem_init+0xf9a>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101993:	83 ec 0c             	sub    $0xc,%esp
f0101996:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101999:	e8 39 f6 ff ff       	call   f0100fd7 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f010199e:	6a 02                	push   $0x2
f01019a0:	6a 00                	push   $0x0
f01019a2:	53                   	push   %ebx
f01019a3:	ff 35 8c 5e 21 f0    	pushl  0xf0215e8c
f01019a9:	e8 dc f8 ff ff       	call   f010128a <page_insert>
f01019ae:	83 c4 20             	add    $0x20,%esp
f01019b1:	85 c0                	test   %eax,%eax
f01019b3:	0f 85 4f 09 00 00    	jne    f0102308 <mem_init+0xfb3>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01019b9:	8b 3d 8c 5e 21 f0    	mov    0xf0215e8c,%edi
	return (pp - pages) << PGSHIFT;
f01019bf:	8b 0d 90 5e 21 f0    	mov    0xf0215e90,%ecx
f01019c5:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f01019c8:	8b 17                	mov    (%edi),%edx
f01019ca:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01019d0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019d3:	29 c8                	sub    %ecx,%eax
f01019d5:	c1 f8 03             	sar    $0x3,%eax
f01019d8:	c1 e0 0c             	shl    $0xc,%eax
f01019db:	39 c2                	cmp    %eax,%edx
f01019dd:	0f 85 3e 09 00 00    	jne    f0102321 <mem_init+0xfcc>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01019e3:	ba 00 00 00 00       	mov    $0x0,%edx
f01019e8:	89 f8                	mov    %edi,%eax
f01019ea:	e8 17 f1 ff ff       	call   f0100b06 <check_va2pa>
f01019ef:	89 da                	mov    %ebx,%edx
f01019f1:	2b 55 d0             	sub    -0x30(%ebp),%edx
f01019f4:	c1 fa 03             	sar    $0x3,%edx
f01019f7:	c1 e2 0c             	shl    $0xc,%edx
f01019fa:	39 d0                	cmp    %edx,%eax
f01019fc:	0f 85 38 09 00 00    	jne    f010233a <mem_init+0xfe5>
	assert(pp1->pp_ref == 1);
f0101a02:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101a07:	0f 85 46 09 00 00    	jne    f0102353 <mem_init+0xffe>
	assert(pp0->pp_ref == 1);
f0101a0d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a10:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101a15:	0f 85 51 09 00 00    	jne    f010236c <mem_init+0x1017>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a1b:	6a 02                	push   $0x2
f0101a1d:	68 00 10 00 00       	push   $0x1000
f0101a22:	56                   	push   %esi
f0101a23:	57                   	push   %edi
f0101a24:	e8 61 f8 ff ff       	call   f010128a <page_insert>
f0101a29:	83 c4 10             	add    $0x10,%esp
f0101a2c:	85 c0                	test   %eax,%eax
f0101a2e:	0f 85 51 09 00 00    	jne    f0102385 <mem_init+0x1030>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a34:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a39:	a1 8c 5e 21 f0       	mov    0xf0215e8c,%eax
f0101a3e:	e8 c3 f0 ff ff       	call   f0100b06 <check_va2pa>
f0101a43:	89 f2                	mov    %esi,%edx
f0101a45:	2b 15 90 5e 21 f0    	sub    0xf0215e90,%edx
f0101a4b:	c1 fa 03             	sar    $0x3,%edx
f0101a4e:	c1 e2 0c             	shl    $0xc,%edx
f0101a51:	39 d0                	cmp    %edx,%eax
f0101a53:	0f 85 45 09 00 00    	jne    f010239e <mem_init+0x1049>
	assert(pp2->pp_ref == 1);
f0101a59:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101a5e:	0f 85 53 09 00 00    	jne    f01023b7 <mem_init+0x1062>

	// should be no free memory
	assert(!page_alloc(0));
f0101a64:	83 ec 0c             	sub    $0xc,%esp
f0101a67:	6a 00                	push   $0x0
f0101a69:	e8 f7 f4 ff ff       	call   f0100f65 <page_alloc>
f0101a6e:	83 c4 10             	add    $0x10,%esp
f0101a71:	85 c0                	test   %eax,%eax
f0101a73:	0f 85 57 09 00 00    	jne    f01023d0 <mem_init+0x107b>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a79:	6a 02                	push   $0x2
f0101a7b:	68 00 10 00 00       	push   $0x1000
f0101a80:	56                   	push   %esi
f0101a81:	ff 35 8c 5e 21 f0    	pushl  0xf0215e8c
f0101a87:	e8 fe f7 ff ff       	call   f010128a <page_insert>
f0101a8c:	83 c4 10             	add    $0x10,%esp
f0101a8f:	85 c0                	test   %eax,%eax
f0101a91:	0f 85 52 09 00 00    	jne    f01023e9 <mem_init+0x1094>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a97:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a9c:	a1 8c 5e 21 f0       	mov    0xf0215e8c,%eax
f0101aa1:	e8 60 f0 ff ff       	call   f0100b06 <check_va2pa>
f0101aa6:	89 f2                	mov    %esi,%edx
f0101aa8:	2b 15 90 5e 21 f0    	sub    0xf0215e90,%edx
f0101aae:	c1 fa 03             	sar    $0x3,%edx
f0101ab1:	c1 e2 0c             	shl    $0xc,%edx
f0101ab4:	39 d0                	cmp    %edx,%eax
f0101ab6:	0f 85 46 09 00 00    	jne    f0102402 <mem_init+0x10ad>
	assert(pp2->pp_ref == 1);
f0101abc:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101ac1:	0f 85 54 09 00 00    	jne    f010241b <mem_init+0x10c6>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101ac7:	83 ec 0c             	sub    $0xc,%esp
f0101aca:	6a 00                	push   $0x0
f0101acc:	e8 94 f4 ff ff       	call   f0100f65 <page_alloc>
f0101ad1:	83 c4 10             	add    $0x10,%esp
f0101ad4:	85 c0                	test   %eax,%eax
f0101ad6:	0f 85 58 09 00 00    	jne    f0102434 <mem_init+0x10df>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101adc:	8b 15 8c 5e 21 f0    	mov    0xf0215e8c,%edx
f0101ae2:	8b 02                	mov    (%edx),%eax
f0101ae4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101ae9:	89 c1                	mov    %eax,%ecx
f0101aeb:	c1 e9 0c             	shr    $0xc,%ecx
f0101aee:	3b 0d 88 5e 21 f0    	cmp    0xf0215e88,%ecx
f0101af4:	0f 83 53 09 00 00    	jae    f010244d <mem_init+0x10f8>
	return (void *)(pa + KERNBASE);
f0101afa:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101aff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101b02:	83 ec 04             	sub    $0x4,%esp
f0101b05:	6a 00                	push   $0x0
f0101b07:	68 00 10 00 00       	push   $0x1000
f0101b0c:	52                   	push   %edx
f0101b0d:	e8 29 f5 ff ff       	call   f010103b <pgdir_walk>
f0101b12:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101b15:	8d 51 04             	lea    0x4(%ecx),%edx
f0101b18:	83 c4 10             	add    $0x10,%esp
f0101b1b:	39 d0                	cmp    %edx,%eax
f0101b1d:	0f 85 3f 09 00 00    	jne    f0102462 <mem_init+0x110d>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101b23:	6a 06                	push   $0x6
f0101b25:	68 00 10 00 00       	push   $0x1000
f0101b2a:	56                   	push   %esi
f0101b2b:	ff 35 8c 5e 21 f0    	pushl  0xf0215e8c
f0101b31:	e8 54 f7 ff ff       	call   f010128a <page_insert>
f0101b36:	83 c4 10             	add    $0x10,%esp
f0101b39:	85 c0                	test   %eax,%eax
f0101b3b:	0f 85 3a 09 00 00    	jne    f010247b <mem_init+0x1126>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b41:	8b 3d 8c 5e 21 f0    	mov    0xf0215e8c,%edi
f0101b47:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b4c:	89 f8                	mov    %edi,%eax
f0101b4e:	e8 b3 ef ff ff       	call   f0100b06 <check_va2pa>
	return (pp - pages) << PGSHIFT;
f0101b53:	89 f2                	mov    %esi,%edx
f0101b55:	2b 15 90 5e 21 f0    	sub    0xf0215e90,%edx
f0101b5b:	c1 fa 03             	sar    $0x3,%edx
f0101b5e:	c1 e2 0c             	shl    $0xc,%edx
f0101b61:	39 d0                	cmp    %edx,%eax
f0101b63:	0f 85 2b 09 00 00    	jne    f0102494 <mem_init+0x113f>
	assert(pp2->pp_ref == 1);
f0101b69:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101b6e:	0f 85 39 09 00 00    	jne    f01024ad <mem_init+0x1158>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101b74:	83 ec 04             	sub    $0x4,%esp
f0101b77:	6a 00                	push   $0x0
f0101b79:	68 00 10 00 00       	push   $0x1000
f0101b7e:	57                   	push   %edi
f0101b7f:	e8 b7 f4 ff ff       	call   f010103b <pgdir_walk>
f0101b84:	83 c4 10             	add    $0x10,%esp
f0101b87:	f6 00 04             	testb  $0x4,(%eax)
f0101b8a:	0f 84 36 09 00 00    	je     f01024c6 <mem_init+0x1171>
	assert(kern_pgdir[0] & PTE_U);
f0101b90:	a1 8c 5e 21 f0       	mov    0xf0215e8c,%eax
f0101b95:	f6 00 04             	testb  $0x4,(%eax)
f0101b98:	0f 84 41 09 00 00    	je     f01024df <mem_init+0x118a>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b9e:	6a 02                	push   $0x2
f0101ba0:	68 00 10 00 00       	push   $0x1000
f0101ba5:	56                   	push   %esi
f0101ba6:	50                   	push   %eax
f0101ba7:	e8 de f6 ff ff       	call   f010128a <page_insert>
f0101bac:	83 c4 10             	add    $0x10,%esp
f0101baf:	85 c0                	test   %eax,%eax
f0101bb1:	0f 85 41 09 00 00    	jne    f01024f8 <mem_init+0x11a3>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101bb7:	83 ec 04             	sub    $0x4,%esp
f0101bba:	6a 00                	push   $0x0
f0101bbc:	68 00 10 00 00       	push   $0x1000
f0101bc1:	ff 35 8c 5e 21 f0    	pushl  0xf0215e8c
f0101bc7:	e8 6f f4 ff ff       	call   f010103b <pgdir_walk>
f0101bcc:	83 c4 10             	add    $0x10,%esp
f0101bcf:	f6 00 02             	testb  $0x2,(%eax)
f0101bd2:	0f 84 39 09 00 00    	je     f0102511 <mem_init+0x11bc>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101bd8:	83 ec 04             	sub    $0x4,%esp
f0101bdb:	6a 00                	push   $0x0
f0101bdd:	68 00 10 00 00       	push   $0x1000
f0101be2:	ff 35 8c 5e 21 f0    	pushl  0xf0215e8c
f0101be8:	e8 4e f4 ff ff       	call   f010103b <pgdir_walk>
f0101bed:	83 c4 10             	add    $0x10,%esp
f0101bf0:	f6 00 04             	testb  $0x4,(%eax)
f0101bf3:	0f 85 31 09 00 00    	jne    f010252a <mem_init+0x11d5>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101bf9:	6a 02                	push   $0x2
f0101bfb:	68 00 00 40 00       	push   $0x400000
f0101c00:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101c03:	ff 35 8c 5e 21 f0    	pushl  0xf0215e8c
f0101c09:	e8 7c f6 ff ff       	call   f010128a <page_insert>
f0101c0e:	83 c4 10             	add    $0x10,%esp
f0101c11:	85 c0                	test   %eax,%eax
f0101c13:	0f 89 2a 09 00 00    	jns    f0102543 <mem_init+0x11ee>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101c19:	6a 02                	push   $0x2
f0101c1b:	68 00 10 00 00       	push   $0x1000
f0101c20:	53                   	push   %ebx
f0101c21:	ff 35 8c 5e 21 f0    	pushl  0xf0215e8c
f0101c27:	e8 5e f6 ff ff       	call   f010128a <page_insert>
f0101c2c:	83 c4 10             	add    $0x10,%esp
f0101c2f:	85 c0                	test   %eax,%eax
f0101c31:	0f 85 25 09 00 00    	jne    f010255c <mem_init+0x1207>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101c37:	83 ec 04             	sub    $0x4,%esp
f0101c3a:	6a 00                	push   $0x0
f0101c3c:	68 00 10 00 00       	push   $0x1000
f0101c41:	ff 35 8c 5e 21 f0    	pushl  0xf0215e8c
f0101c47:	e8 ef f3 ff ff       	call   f010103b <pgdir_walk>
f0101c4c:	83 c4 10             	add    $0x10,%esp
f0101c4f:	f6 00 04             	testb  $0x4,(%eax)
f0101c52:	0f 85 1d 09 00 00    	jne    f0102575 <mem_init+0x1220>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101c58:	8b 3d 8c 5e 21 f0    	mov    0xf0215e8c,%edi
f0101c5e:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c63:	89 f8                	mov    %edi,%eax
f0101c65:	e8 9c ee ff ff       	call   f0100b06 <check_va2pa>
f0101c6a:	89 c1                	mov    %eax,%ecx
f0101c6c:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101c6f:	89 d8                	mov    %ebx,%eax
f0101c71:	2b 05 90 5e 21 f0    	sub    0xf0215e90,%eax
f0101c77:	c1 f8 03             	sar    $0x3,%eax
f0101c7a:	c1 e0 0c             	shl    $0xc,%eax
f0101c7d:	39 c1                	cmp    %eax,%ecx
f0101c7f:	0f 85 09 09 00 00    	jne    f010258e <mem_init+0x1239>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101c85:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c8a:	89 f8                	mov    %edi,%eax
f0101c8c:	e8 75 ee ff ff       	call   f0100b06 <check_va2pa>
f0101c91:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101c94:	0f 85 0d 09 00 00    	jne    f01025a7 <mem_init+0x1252>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101c9a:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101c9f:	0f 85 1b 09 00 00    	jne    f01025c0 <mem_init+0x126b>
	assert(pp2->pp_ref == 0);
f0101ca5:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101caa:	0f 85 29 09 00 00    	jne    f01025d9 <mem_init+0x1284>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101cb0:	83 ec 0c             	sub    $0xc,%esp
f0101cb3:	6a 00                	push   $0x0
f0101cb5:	e8 ab f2 ff ff       	call   f0100f65 <page_alloc>
f0101cba:	83 c4 10             	add    $0x10,%esp
f0101cbd:	39 c6                	cmp    %eax,%esi
f0101cbf:	0f 85 2d 09 00 00    	jne    f01025f2 <mem_init+0x129d>
f0101cc5:	85 c0                	test   %eax,%eax
f0101cc7:	0f 84 25 09 00 00    	je     f01025f2 <mem_init+0x129d>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101ccd:	83 ec 08             	sub    $0x8,%esp
f0101cd0:	6a 00                	push   $0x0
f0101cd2:	ff 35 8c 5e 21 f0    	pushl  0xf0215e8c
f0101cd8:	e8 5d f5 ff ff       	call   f010123a <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101cdd:	8b 3d 8c 5e 21 f0    	mov    0xf0215e8c,%edi
f0101ce3:	ba 00 00 00 00       	mov    $0x0,%edx
f0101ce8:	89 f8                	mov    %edi,%eax
f0101cea:	e8 17 ee ff ff       	call   f0100b06 <check_va2pa>
f0101cef:	83 c4 10             	add    $0x10,%esp
f0101cf2:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101cf5:	0f 85 10 09 00 00    	jne    f010260b <mem_init+0x12b6>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101cfb:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d00:	89 f8                	mov    %edi,%eax
f0101d02:	e8 ff ed ff ff       	call   f0100b06 <check_va2pa>
f0101d07:	89 da                	mov    %ebx,%edx
f0101d09:	2b 15 90 5e 21 f0    	sub    0xf0215e90,%edx
f0101d0f:	c1 fa 03             	sar    $0x3,%edx
f0101d12:	c1 e2 0c             	shl    $0xc,%edx
f0101d15:	39 d0                	cmp    %edx,%eax
f0101d17:	0f 85 07 09 00 00    	jne    f0102624 <mem_init+0x12cf>
	assert(pp1->pp_ref == 1);
f0101d1d:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101d22:	0f 85 15 09 00 00    	jne    f010263d <mem_init+0x12e8>
	assert(pp2->pp_ref == 0);
f0101d28:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101d2d:	0f 85 23 09 00 00    	jne    f0102656 <mem_init+0x1301>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101d33:	6a 00                	push   $0x0
f0101d35:	68 00 10 00 00       	push   $0x1000
f0101d3a:	53                   	push   %ebx
f0101d3b:	57                   	push   %edi
f0101d3c:	e8 49 f5 ff ff       	call   f010128a <page_insert>
f0101d41:	83 c4 10             	add    $0x10,%esp
f0101d44:	85 c0                	test   %eax,%eax
f0101d46:	0f 85 23 09 00 00    	jne    f010266f <mem_init+0x131a>
	assert(pp1->pp_ref);
f0101d4c:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101d51:	0f 84 31 09 00 00    	je     f0102688 <mem_init+0x1333>
	assert(pp1->pp_link == NULL);
f0101d57:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101d5a:	0f 85 41 09 00 00    	jne    f01026a1 <mem_init+0x134c>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101d60:	83 ec 08             	sub    $0x8,%esp
f0101d63:	68 00 10 00 00       	push   $0x1000
f0101d68:	ff 35 8c 5e 21 f0    	pushl  0xf0215e8c
f0101d6e:	e8 c7 f4 ff ff       	call   f010123a <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101d73:	8b 3d 8c 5e 21 f0    	mov    0xf0215e8c,%edi
f0101d79:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d7e:	89 f8                	mov    %edi,%eax
f0101d80:	e8 81 ed ff ff       	call   f0100b06 <check_va2pa>
f0101d85:	83 c4 10             	add    $0x10,%esp
f0101d88:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d8b:	0f 85 29 09 00 00    	jne    f01026ba <mem_init+0x1365>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101d91:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d96:	89 f8                	mov    %edi,%eax
f0101d98:	e8 69 ed ff ff       	call   f0100b06 <check_va2pa>
f0101d9d:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101da0:	0f 85 2d 09 00 00    	jne    f01026d3 <mem_init+0x137e>
	assert(pp1->pp_ref == 0);
f0101da6:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101dab:	0f 85 3b 09 00 00    	jne    f01026ec <mem_init+0x1397>
	assert(pp2->pp_ref == 0);
f0101db1:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101db6:	0f 85 49 09 00 00    	jne    f0102705 <mem_init+0x13b0>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101dbc:	83 ec 0c             	sub    $0xc,%esp
f0101dbf:	6a 00                	push   $0x0
f0101dc1:	e8 9f f1 ff ff       	call   f0100f65 <page_alloc>
f0101dc6:	83 c4 10             	add    $0x10,%esp
f0101dc9:	85 c0                	test   %eax,%eax
f0101dcb:	0f 84 4d 09 00 00    	je     f010271e <mem_init+0x13c9>
f0101dd1:	39 c3                	cmp    %eax,%ebx
f0101dd3:	0f 85 45 09 00 00    	jne    f010271e <mem_init+0x13c9>

	// should be no free memory
	assert(!page_alloc(0));
f0101dd9:	83 ec 0c             	sub    $0xc,%esp
f0101ddc:	6a 00                	push   $0x0
f0101dde:	e8 82 f1 ff ff       	call   f0100f65 <page_alloc>
f0101de3:	83 c4 10             	add    $0x10,%esp
f0101de6:	85 c0                	test   %eax,%eax
f0101de8:	0f 85 49 09 00 00    	jne    f0102737 <mem_init+0x13e2>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101dee:	8b 0d 8c 5e 21 f0    	mov    0xf0215e8c,%ecx
f0101df4:	8b 11                	mov    (%ecx),%edx
f0101df6:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101dfc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101dff:	2b 05 90 5e 21 f0    	sub    0xf0215e90,%eax
f0101e05:	c1 f8 03             	sar    $0x3,%eax
f0101e08:	c1 e0 0c             	shl    $0xc,%eax
f0101e0b:	39 c2                	cmp    %eax,%edx
f0101e0d:	0f 85 3d 09 00 00    	jne    f0102750 <mem_init+0x13fb>
	kern_pgdir[0] = 0;
f0101e13:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101e19:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e1c:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101e21:	0f 85 42 09 00 00    	jne    f0102769 <mem_init+0x1414>
	pp0->pp_ref = 0;
f0101e27:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e2a:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101e30:	83 ec 0c             	sub    $0xc,%esp
f0101e33:	50                   	push   %eax
f0101e34:	e8 9e f1 ff ff       	call   f0100fd7 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101e39:	83 c4 0c             	add    $0xc,%esp
f0101e3c:	6a 01                	push   $0x1
f0101e3e:	68 00 10 40 00       	push   $0x401000
f0101e43:	ff 35 8c 5e 21 f0    	pushl  0xf0215e8c
f0101e49:	e8 ed f1 ff ff       	call   f010103b <pgdir_walk>
f0101e4e:	89 c7                	mov    %eax,%edi
f0101e50:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101e53:	a1 8c 5e 21 f0       	mov    0xf0215e8c,%eax
f0101e58:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101e5b:	8b 40 04             	mov    0x4(%eax),%eax
f0101e5e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101e63:	8b 0d 88 5e 21 f0    	mov    0xf0215e88,%ecx
f0101e69:	89 c2                	mov    %eax,%edx
f0101e6b:	c1 ea 0c             	shr    $0xc,%edx
f0101e6e:	83 c4 10             	add    $0x10,%esp
f0101e71:	39 ca                	cmp    %ecx,%edx
f0101e73:	0f 83 09 09 00 00    	jae    f0102782 <mem_init+0x142d>
	assert(ptep == ptep1 + PTX(va));
f0101e79:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0101e7e:	39 c7                	cmp    %eax,%edi
f0101e80:	0f 85 11 09 00 00    	jne    f0102797 <mem_init+0x1442>
	kern_pgdir[PDX(va)] = 0;
f0101e86:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101e89:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0101e90:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e93:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101e99:	2b 05 90 5e 21 f0    	sub    0xf0215e90,%eax
f0101e9f:	c1 f8 03             	sar    $0x3,%eax
f0101ea2:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101ea5:	89 c2                	mov    %eax,%edx
f0101ea7:	c1 ea 0c             	shr    $0xc,%edx
f0101eaa:	39 d1                	cmp    %edx,%ecx
f0101eac:	0f 86 fe 08 00 00    	jbe    f01027b0 <mem_init+0x145b>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101eb2:	83 ec 04             	sub    $0x4,%esp
f0101eb5:	68 00 10 00 00       	push   $0x1000
f0101eba:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0101ebf:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101ec4:	50                   	push   %eax
f0101ec5:	e8 35 3a 00 00       	call   f01058ff <memset>
	page_free(pp0);
f0101eca:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101ecd:	89 3c 24             	mov    %edi,(%esp)
f0101ed0:	e8 02 f1 ff ff       	call   f0100fd7 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101ed5:	83 c4 0c             	add    $0xc,%esp
f0101ed8:	6a 01                	push   $0x1
f0101eda:	6a 00                	push   $0x0
f0101edc:	ff 35 8c 5e 21 f0    	pushl  0xf0215e8c
f0101ee2:	e8 54 f1 ff ff       	call   f010103b <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0101ee7:	89 fa                	mov    %edi,%edx
f0101ee9:	2b 15 90 5e 21 f0    	sub    0xf0215e90,%edx
f0101eef:	c1 fa 03             	sar    $0x3,%edx
f0101ef2:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101ef5:	89 d0                	mov    %edx,%eax
f0101ef7:	c1 e8 0c             	shr    $0xc,%eax
f0101efa:	83 c4 10             	add    $0x10,%esp
f0101efd:	3b 05 88 5e 21 f0    	cmp    0xf0215e88,%eax
f0101f03:	0f 83 b9 08 00 00    	jae    f01027c2 <mem_init+0x146d>
	return (void *)(pa + KERNBASE);
f0101f09:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0101f0f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101f12:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0101f18:	f6 00 01             	testb  $0x1,(%eax)
f0101f1b:	0f 85 b3 08 00 00    	jne    f01027d4 <mem_init+0x147f>
f0101f21:	83 c0 04             	add    $0x4,%eax
	for(i=0; i<NPTENTRIES; i++)
f0101f24:	39 d0                	cmp    %edx,%eax
f0101f26:	75 f0                	jne    f0101f18 <mem_init+0xbc3>
	kern_pgdir[0] = 0;
f0101f28:	a1 8c 5e 21 f0       	mov    0xf0215e8c,%eax
f0101f2d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0101f33:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f36:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0101f3c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0101f3f:	89 0d 40 52 21 f0    	mov    %ecx,0xf0215240

	// free the pages we took
	page_free(pp0);
f0101f45:	83 ec 0c             	sub    $0xc,%esp
f0101f48:	50                   	push   %eax
f0101f49:	e8 89 f0 ff ff       	call   f0100fd7 <page_free>
	page_free(pp1);
f0101f4e:	89 1c 24             	mov    %ebx,(%esp)
f0101f51:	e8 81 f0 ff ff       	call   f0100fd7 <page_free>
	page_free(pp2);
f0101f56:	89 34 24             	mov    %esi,(%esp)
f0101f59:	e8 79 f0 ff ff       	call   f0100fd7 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0101f5e:	83 c4 08             	add    $0x8,%esp
f0101f61:	68 01 10 00 00       	push   $0x1001
f0101f66:	6a 00                	push   $0x0
f0101f68:	e8 85 f3 ff ff       	call   f01012f2 <mmio_map_region>
f0101f6d:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0101f6f:	83 c4 08             	add    $0x8,%esp
f0101f72:	68 00 10 00 00       	push   $0x1000
f0101f77:	6a 00                	push   $0x0
f0101f79:	e8 74 f3 ff ff       	call   f01012f2 <mmio_map_region>
f0101f7e:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f0101f80:	8d 83 00 20 00 00    	lea    0x2000(%ebx),%eax
f0101f86:	83 c4 10             	add    $0x10,%esp
f0101f89:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0101f8f:	0f 86 58 08 00 00    	jbe    f01027ed <mem_init+0x1498>
f0101f95:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0101f9a:	0f 87 4d 08 00 00    	ja     f01027ed <mem_init+0x1498>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f0101fa0:	8d 96 00 20 00 00    	lea    0x2000(%esi),%edx
f0101fa6:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0101fac:	0f 87 54 08 00 00    	ja     f0102806 <mem_init+0x14b1>
f0101fb2:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0101fb8:	0f 86 48 08 00 00    	jbe    f0102806 <mem_init+0x14b1>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0101fbe:	89 da                	mov    %ebx,%edx
f0101fc0:	09 f2                	or     %esi,%edx
f0101fc2:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0101fc8:	0f 85 51 08 00 00    	jne    f010281f <mem_init+0x14ca>
	// check that they don't overlap
	assert(mm1 + 8192 <= mm2);
f0101fce:	39 c6                	cmp    %eax,%esi
f0101fd0:	0f 82 62 08 00 00    	jb     f0102838 <mem_init+0x14e3>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0101fd6:	8b 3d 8c 5e 21 f0    	mov    0xf0215e8c,%edi
f0101fdc:	89 da                	mov    %ebx,%edx
f0101fde:	89 f8                	mov    %edi,%eax
f0101fe0:	e8 21 eb ff ff       	call   f0100b06 <check_va2pa>
f0101fe5:	85 c0                	test   %eax,%eax
f0101fe7:	0f 85 64 08 00 00    	jne    f0102851 <mem_init+0x14fc>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0101fed:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0101ff3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101ff6:	89 c2                	mov    %eax,%edx
f0101ff8:	89 f8                	mov    %edi,%eax
f0101ffa:	e8 07 eb ff ff       	call   f0100b06 <check_va2pa>
f0101fff:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102004:	0f 85 60 08 00 00    	jne    f010286a <mem_init+0x1515>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f010200a:	89 f2                	mov    %esi,%edx
f010200c:	89 f8                	mov    %edi,%eax
f010200e:	e8 f3 ea ff ff       	call   f0100b06 <check_va2pa>
f0102013:	85 c0                	test   %eax,%eax
f0102015:	0f 85 68 08 00 00    	jne    f0102883 <mem_init+0x152e>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f010201b:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102021:	89 f8                	mov    %edi,%eax
f0102023:	e8 de ea ff ff       	call   f0100b06 <check_va2pa>
f0102028:	83 f8 ff             	cmp    $0xffffffff,%eax
f010202b:	0f 85 6b 08 00 00    	jne    f010289c <mem_init+0x1547>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102031:	83 ec 04             	sub    $0x4,%esp
f0102034:	6a 00                	push   $0x0
f0102036:	53                   	push   %ebx
f0102037:	57                   	push   %edi
f0102038:	e8 fe ef ff ff       	call   f010103b <pgdir_walk>
f010203d:	83 c4 10             	add    $0x10,%esp
f0102040:	f6 00 1a             	testb  $0x1a,(%eax)
f0102043:	0f 84 6c 08 00 00    	je     f01028b5 <mem_init+0x1560>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102049:	83 ec 04             	sub    $0x4,%esp
f010204c:	6a 00                	push   $0x0
f010204e:	53                   	push   %ebx
f010204f:	ff 35 8c 5e 21 f0    	pushl  0xf0215e8c
f0102055:	e8 e1 ef ff ff       	call   f010103b <pgdir_walk>
f010205a:	83 c4 10             	add    $0x10,%esp
f010205d:	f6 00 04             	testb  $0x4,(%eax)
f0102060:	0f 85 68 08 00 00    	jne    f01028ce <mem_init+0x1579>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102066:	83 ec 04             	sub    $0x4,%esp
f0102069:	6a 00                	push   $0x0
f010206b:	53                   	push   %ebx
f010206c:	ff 35 8c 5e 21 f0    	pushl  0xf0215e8c
f0102072:	e8 c4 ef ff ff       	call   f010103b <pgdir_walk>
f0102077:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f010207d:	83 c4 0c             	add    $0xc,%esp
f0102080:	6a 00                	push   $0x0
f0102082:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102085:	ff 35 8c 5e 21 f0    	pushl  0xf0215e8c
f010208b:	e8 ab ef ff ff       	call   f010103b <pgdir_walk>
f0102090:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102096:	83 c4 0c             	add    $0xc,%esp
f0102099:	6a 00                	push   $0x0
f010209b:	56                   	push   %esi
f010209c:	ff 35 8c 5e 21 f0    	pushl  0xf0215e8c
f01020a2:	e8 94 ef ff ff       	call   f010103b <pgdir_walk>
f01020a7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f01020ad:	c7 04 24 44 77 10 f0 	movl   $0xf0107744,(%esp)
f01020b4:	e8 8f 18 00 00       	call   f0103948 <cprintf>
        boot_map_region(kern_pgdir,UPAGES,PTSIZE,PADDR(pages),PTE_U|PTE_P);
f01020b9:	a1 90 5e 21 f0       	mov    0xf0215e90,%eax
	if ((uint32_t)kva < KERNBASE)
f01020be:	83 c4 10             	add    $0x10,%esp
f01020c1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01020c6:	0f 86 1b 08 00 00    	jbe    f01028e7 <mem_init+0x1592>
f01020cc:	83 ec 08             	sub    $0x8,%esp
f01020cf:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f01020d1:	05 00 00 00 10       	add    $0x10000000,%eax
f01020d6:	50                   	push   %eax
f01020d7:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01020dc:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01020e1:	a1 8c 5e 21 f0       	mov    0xf0215e8c,%eax
f01020e6:	e8 3b f0 ff ff       	call   f0101126 <boot_map_region>
         boot_map_region(kern_pgdir,UENVS,PTSIZE,PADDR(envs),PTE_U|PTE_P);
f01020eb:	a1 44 52 21 f0       	mov    0xf0215244,%eax
	if ((uint32_t)kva < KERNBASE)
f01020f0:	83 c4 10             	add    $0x10,%esp
f01020f3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01020f8:	0f 86 fe 07 00 00    	jbe    f01028fc <mem_init+0x15a7>
f01020fe:	83 ec 08             	sub    $0x8,%esp
f0102101:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f0102103:	05 00 00 00 10       	add    $0x10000000,%eax
f0102108:	50                   	push   %eax
f0102109:	b9 00 00 40 00       	mov    $0x400000,%ecx
f010210e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102113:	a1 8c 5e 21 f0       	mov    0xf0215e8c,%eax
f0102118:	e8 09 f0 ff ff       	call   f0101126 <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f010211d:	83 c4 10             	add    $0x10,%esp
f0102120:	b8 00 80 11 f0       	mov    $0xf0118000,%eax
f0102125:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010212a:	0f 86 e1 07 00 00    	jbe    f0102911 <mem_init+0x15bc>
        boot_map_region(kern_pgdir,KSTACKTOP-KSTKSIZE,KSTKSIZE,PADDR(bootstack),PTE_W|PTE_P);
f0102130:	83 ec 08             	sub    $0x8,%esp
f0102133:	6a 03                	push   $0x3
f0102135:	68 00 80 11 00       	push   $0x118000
f010213a:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010213f:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102144:	a1 8c 5e 21 f0       	mov    0xf0215e8c,%eax
f0102149:	e8 d8 ef ff ff       	call   f0101126 <boot_map_region>
        boot_map_region(kern_pgdir,KERNBASE,0xffffffff-KERNBASE,0,PTE_W|PTE_P);
f010214e:	83 c4 08             	add    $0x8,%esp
f0102151:	6a 03                	push   $0x3
f0102153:	6a 00                	push   $0x0
f0102155:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f010215a:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f010215f:	a1 8c 5e 21 f0       	mov    0xf0215e8c,%eax
f0102164:	e8 bd ef ff ff       	call   f0101126 <boot_map_region>
f0102169:	c7 45 cc 00 70 21 f0 	movl   $0xf0217000,-0x34(%ebp)
f0102170:	bf 00 70 25 f0       	mov    $0xf0257000,%edi
f0102175:	83 c4 10             	add    $0x10,%esp
f0102178:	bb 00 70 21 f0       	mov    $0xf0217000,%ebx
f010217d:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102182:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102188:	0f 86 98 07 00 00    	jbe    f0102926 <mem_init+0x15d1>
	  boot_map_region(kern_pgdir,kstacktop_i-KSTKSIZE,KSTKSIZE,PADDR(&percpu_kstacks[i]),PTE_W);
f010218e:	83 ec 08             	sub    $0x8,%esp
f0102191:	6a 02                	push   $0x2
f0102193:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0102199:	50                   	push   %eax
f010219a:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010219f:	89 f2                	mov    %esi,%edx
f01021a1:	a1 8c 5e 21 f0       	mov    0xf0215e8c,%eax
f01021a6:	e8 7b ef ff ff       	call   f0101126 <boot_map_region>
f01021ab:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f01021b1:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	for(i=0;i<NCPU;i++){
f01021b7:	83 c4 10             	add    $0x10,%esp
f01021ba:	39 fb                	cmp    %edi,%ebx
f01021bc:	75 c4                	jne    f0102182 <mem_init+0xe2d>
	pgdir = kern_pgdir;
f01021be:	8b 3d 8c 5e 21 f0    	mov    0xf0215e8c,%edi
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01021c4:	a1 88 5e 21 f0       	mov    0xf0215e88,%eax
f01021c9:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01021cc:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01021d3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01021d8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01021db:	a1 90 5e 21 f0       	mov    0xf0215e90,%eax
f01021e0:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f01021e3:	89 45 d0             	mov    %eax,-0x30(%ebp)
	return (physaddr_t)kva - KERNBASE;
f01021e6:	8d b0 00 00 00 10    	lea    0x10000000(%eax),%esi
	for (i = 0; i < n; i += PGSIZE)
f01021ec:	bb 00 00 00 00       	mov    $0x0,%ebx
f01021f1:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01021f4:	0f 86 71 07 00 00    	jbe    f010296b <mem_init+0x1616>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01021fa:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102200:	89 f8                	mov    %edi,%eax
f0102202:	e8 ff e8 ff ff       	call   f0100b06 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102207:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f010220e:	0f 86 27 07 00 00    	jbe    f010293b <mem_init+0x15e6>
f0102214:	8d 14 33             	lea    (%ebx,%esi,1),%edx
f0102217:	39 d0                	cmp    %edx,%eax
f0102219:	0f 85 33 07 00 00    	jne    f0102952 <mem_init+0x15fd>
	for (i = 0; i < n; i += PGSIZE)
f010221f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102225:	eb ca                	jmp    f01021f1 <mem_init+0xe9c>
	assert(nfree == 0);
f0102227:	68 5b 76 10 f0       	push   $0xf010765b
f010222c:	68 6f 74 10 f0       	push   $0xf010746f
f0102231:	68 44 03 00 00       	push   $0x344
f0102236:	68 49 74 10 f0       	push   $0xf0107449
f010223b:	e8 00 de ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f0102240:	68 69 75 10 f0       	push   $0xf0107569
f0102245:	68 6f 74 10 f0       	push   $0xf010746f
f010224a:	68 aa 03 00 00       	push   $0x3aa
f010224f:	68 49 74 10 f0       	push   $0xf0107449
f0102254:	e8 e7 dd ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102259:	68 7f 75 10 f0       	push   $0xf010757f
f010225e:	68 6f 74 10 f0       	push   $0xf010746f
f0102263:	68 ab 03 00 00       	push   $0x3ab
f0102268:	68 49 74 10 f0       	push   $0xf0107449
f010226d:	e8 ce dd ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102272:	68 95 75 10 f0       	push   $0xf0107595
f0102277:	68 6f 74 10 f0       	push   $0xf010746f
f010227c:	68 ac 03 00 00       	push   $0x3ac
f0102281:	68 49 74 10 f0       	push   $0xf0107449
f0102286:	e8 b5 dd ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f010228b:	68 ab 75 10 f0       	push   $0xf01075ab
f0102290:	68 6f 74 10 f0       	push   $0xf010746f
f0102295:	68 af 03 00 00       	push   $0x3af
f010229a:	68 49 74 10 f0       	push   $0xf0107449
f010229f:	e8 9c dd ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01022a4:	68 6c 6c 10 f0       	push   $0xf0106c6c
f01022a9:	68 6f 74 10 f0       	push   $0xf010746f
f01022ae:	68 b0 03 00 00       	push   $0x3b0
f01022b3:	68 49 74 10 f0       	push   $0xf0107449
f01022b8:	e8 83 dd ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01022bd:	68 14 76 10 f0       	push   $0xf0107614
f01022c2:	68 6f 74 10 f0       	push   $0xf010746f
f01022c7:	68 b7 03 00 00       	push   $0x3b7
f01022cc:	68 49 74 10 f0       	push   $0xf0107449
f01022d1:	e8 6a dd ff ff       	call   f0100040 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01022d6:	68 ac 6c 10 f0       	push   $0xf0106cac
f01022db:	68 6f 74 10 f0       	push   $0xf010746f
f01022e0:	68 ba 03 00 00       	push   $0x3ba
f01022e5:	68 49 74 10 f0       	push   $0xf0107449
f01022ea:	e8 51 dd ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01022ef:	68 e4 6c 10 f0       	push   $0xf0106ce4
f01022f4:	68 6f 74 10 f0       	push   $0xf010746f
f01022f9:	68 bd 03 00 00       	push   $0x3bd
f01022fe:	68 49 74 10 f0       	push   $0xf0107449
f0102303:	e8 38 dd ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0102308:	68 14 6d 10 f0       	push   $0xf0106d14
f010230d:	68 6f 74 10 f0       	push   $0xf010746f
f0102312:	68 c1 03 00 00       	push   $0x3c1
f0102317:	68 49 74 10 f0       	push   $0xf0107449
f010231c:	e8 1f dd ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102321:	68 44 6d 10 f0       	push   $0xf0106d44
f0102326:	68 6f 74 10 f0       	push   $0xf010746f
f010232b:	68 c2 03 00 00       	push   $0x3c2
f0102330:	68 49 74 10 f0       	push   $0xf0107449
f0102335:	e8 06 dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f010233a:	68 6c 6d 10 f0       	push   $0xf0106d6c
f010233f:	68 6f 74 10 f0       	push   $0xf010746f
f0102344:	68 c3 03 00 00       	push   $0x3c3
f0102349:	68 49 74 10 f0       	push   $0xf0107449
f010234e:	e8 ed dc ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102353:	68 66 76 10 f0       	push   $0xf0107666
f0102358:	68 6f 74 10 f0       	push   $0xf010746f
f010235d:	68 c4 03 00 00       	push   $0x3c4
f0102362:	68 49 74 10 f0       	push   $0xf0107449
f0102367:	e8 d4 dc ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f010236c:	68 77 76 10 f0       	push   $0xf0107677
f0102371:	68 6f 74 10 f0       	push   $0xf010746f
f0102376:	68 c5 03 00 00       	push   $0x3c5
f010237b:	68 49 74 10 f0       	push   $0xf0107449
f0102380:	e8 bb dc ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102385:	68 9c 6d 10 f0       	push   $0xf0106d9c
f010238a:	68 6f 74 10 f0       	push   $0xf010746f
f010238f:	68 c8 03 00 00       	push   $0x3c8
f0102394:	68 49 74 10 f0       	push   $0xf0107449
f0102399:	e8 a2 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010239e:	68 d8 6d 10 f0       	push   $0xf0106dd8
f01023a3:	68 6f 74 10 f0       	push   $0xf010746f
f01023a8:	68 c9 03 00 00       	push   $0x3c9
f01023ad:	68 49 74 10 f0       	push   $0xf0107449
f01023b2:	e8 89 dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01023b7:	68 88 76 10 f0       	push   $0xf0107688
f01023bc:	68 6f 74 10 f0       	push   $0xf010746f
f01023c1:	68 ca 03 00 00       	push   $0x3ca
f01023c6:	68 49 74 10 f0       	push   $0xf0107449
f01023cb:	e8 70 dc ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01023d0:	68 14 76 10 f0       	push   $0xf0107614
f01023d5:	68 6f 74 10 f0       	push   $0xf010746f
f01023da:	68 cd 03 00 00       	push   $0x3cd
f01023df:	68 49 74 10 f0       	push   $0xf0107449
f01023e4:	e8 57 dc ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01023e9:	68 9c 6d 10 f0       	push   $0xf0106d9c
f01023ee:	68 6f 74 10 f0       	push   $0xf010746f
f01023f3:	68 d0 03 00 00       	push   $0x3d0
f01023f8:	68 49 74 10 f0       	push   $0xf0107449
f01023fd:	e8 3e dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102402:	68 d8 6d 10 f0       	push   $0xf0106dd8
f0102407:	68 6f 74 10 f0       	push   $0xf010746f
f010240c:	68 d1 03 00 00       	push   $0x3d1
f0102411:	68 49 74 10 f0       	push   $0xf0107449
f0102416:	e8 25 dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010241b:	68 88 76 10 f0       	push   $0xf0107688
f0102420:	68 6f 74 10 f0       	push   $0xf010746f
f0102425:	68 d2 03 00 00       	push   $0x3d2
f010242a:	68 49 74 10 f0       	push   $0xf0107449
f010242f:	e8 0c dc ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0102434:	68 14 76 10 f0       	push   $0xf0107614
f0102439:	68 6f 74 10 f0       	push   $0xf010746f
f010243e:	68 d6 03 00 00       	push   $0x3d6
f0102443:	68 49 74 10 f0       	push   $0xf0107449
f0102448:	e8 f3 db ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010244d:	50                   	push   %eax
f010244e:	68 84 65 10 f0       	push   $0xf0106584
f0102453:	68 d9 03 00 00       	push   $0x3d9
f0102458:	68 49 74 10 f0       	push   $0xf0107449
f010245d:	e8 de db ff ff       	call   f0100040 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0102462:	68 08 6e 10 f0       	push   $0xf0106e08
f0102467:	68 6f 74 10 f0       	push   $0xf010746f
f010246c:	68 da 03 00 00       	push   $0x3da
f0102471:	68 49 74 10 f0       	push   $0xf0107449
f0102476:	e8 c5 db ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f010247b:	68 48 6e 10 f0       	push   $0xf0106e48
f0102480:	68 6f 74 10 f0       	push   $0xf010746f
f0102485:	68 dd 03 00 00       	push   $0x3dd
f010248a:	68 49 74 10 f0       	push   $0xf0107449
f010248f:	e8 ac db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102494:	68 d8 6d 10 f0       	push   $0xf0106dd8
f0102499:	68 6f 74 10 f0       	push   $0xf010746f
f010249e:	68 de 03 00 00       	push   $0x3de
f01024a3:	68 49 74 10 f0       	push   $0xf0107449
f01024a8:	e8 93 db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01024ad:	68 88 76 10 f0       	push   $0xf0107688
f01024b2:	68 6f 74 10 f0       	push   $0xf010746f
f01024b7:	68 df 03 00 00       	push   $0x3df
f01024bc:	68 49 74 10 f0       	push   $0xf0107449
f01024c1:	e8 7a db ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01024c6:	68 88 6e 10 f0       	push   $0xf0106e88
f01024cb:	68 6f 74 10 f0       	push   $0xf010746f
f01024d0:	68 e0 03 00 00       	push   $0x3e0
f01024d5:	68 49 74 10 f0       	push   $0xf0107449
f01024da:	e8 61 db ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01024df:	68 99 76 10 f0       	push   $0xf0107699
f01024e4:	68 6f 74 10 f0       	push   $0xf010746f
f01024e9:	68 e1 03 00 00       	push   $0x3e1
f01024ee:	68 49 74 10 f0       	push   $0xf0107449
f01024f3:	e8 48 db ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01024f8:	68 9c 6d 10 f0       	push   $0xf0106d9c
f01024fd:	68 6f 74 10 f0       	push   $0xf010746f
f0102502:	68 e4 03 00 00       	push   $0x3e4
f0102507:	68 49 74 10 f0       	push   $0xf0107449
f010250c:	e8 2f db ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102511:	68 bc 6e 10 f0       	push   $0xf0106ebc
f0102516:	68 6f 74 10 f0       	push   $0xf010746f
f010251b:	68 e5 03 00 00       	push   $0x3e5
f0102520:	68 49 74 10 f0       	push   $0xf0107449
f0102525:	e8 16 db ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010252a:	68 f0 6e 10 f0       	push   $0xf0106ef0
f010252f:	68 6f 74 10 f0       	push   $0xf010746f
f0102534:	68 e6 03 00 00       	push   $0x3e6
f0102539:	68 49 74 10 f0       	push   $0xf0107449
f010253e:	e8 fd da ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102543:	68 28 6f 10 f0       	push   $0xf0106f28
f0102548:	68 6f 74 10 f0       	push   $0xf010746f
f010254d:	68 e9 03 00 00       	push   $0x3e9
f0102552:	68 49 74 10 f0       	push   $0xf0107449
f0102557:	e8 e4 da ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f010255c:	68 60 6f 10 f0       	push   $0xf0106f60
f0102561:	68 6f 74 10 f0       	push   $0xf010746f
f0102566:	68 ec 03 00 00       	push   $0x3ec
f010256b:	68 49 74 10 f0       	push   $0xf0107449
f0102570:	e8 cb da ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102575:	68 f0 6e 10 f0       	push   $0xf0106ef0
f010257a:	68 6f 74 10 f0       	push   $0xf010746f
f010257f:	68 ed 03 00 00       	push   $0x3ed
f0102584:	68 49 74 10 f0       	push   $0xf0107449
f0102589:	e8 b2 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f010258e:	68 9c 6f 10 f0       	push   $0xf0106f9c
f0102593:	68 6f 74 10 f0       	push   $0xf010746f
f0102598:	68 f0 03 00 00       	push   $0x3f0
f010259d:	68 49 74 10 f0       	push   $0xf0107449
f01025a2:	e8 99 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01025a7:	68 c8 6f 10 f0       	push   $0xf0106fc8
f01025ac:	68 6f 74 10 f0       	push   $0xf010746f
f01025b1:	68 f1 03 00 00       	push   $0x3f1
f01025b6:	68 49 74 10 f0       	push   $0xf0107449
f01025bb:	e8 80 da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 2);
f01025c0:	68 af 76 10 f0       	push   $0xf01076af
f01025c5:	68 6f 74 10 f0       	push   $0xf010746f
f01025ca:	68 f3 03 00 00       	push   $0x3f3
f01025cf:	68 49 74 10 f0       	push   $0xf0107449
f01025d4:	e8 67 da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01025d9:	68 c0 76 10 f0       	push   $0xf01076c0
f01025de:	68 6f 74 10 f0       	push   $0xf010746f
f01025e3:	68 f4 03 00 00       	push   $0x3f4
f01025e8:	68 49 74 10 f0       	push   $0xf0107449
f01025ed:	e8 4e da ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f01025f2:	68 f8 6f 10 f0       	push   $0xf0106ff8
f01025f7:	68 6f 74 10 f0       	push   $0xf010746f
f01025fc:	68 f7 03 00 00       	push   $0x3f7
f0102601:	68 49 74 10 f0       	push   $0xf0107449
f0102606:	e8 35 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010260b:	68 1c 70 10 f0       	push   $0xf010701c
f0102610:	68 6f 74 10 f0       	push   $0xf010746f
f0102615:	68 fb 03 00 00       	push   $0x3fb
f010261a:	68 49 74 10 f0       	push   $0xf0107449
f010261f:	e8 1c da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102624:	68 c8 6f 10 f0       	push   $0xf0106fc8
f0102629:	68 6f 74 10 f0       	push   $0xf010746f
f010262e:	68 fc 03 00 00       	push   $0x3fc
f0102633:	68 49 74 10 f0       	push   $0xf0107449
f0102638:	e8 03 da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f010263d:	68 66 76 10 f0       	push   $0xf0107666
f0102642:	68 6f 74 10 f0       	push   $0xf010746f
f0102647:	68 fd 03 00 00       	push   $0x3fd
f010264c:	68 49 74 10 f0       	push   $0xf0107449
f0102651:	e8 ea d9 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102656:	68 c0 76 10 f0       	push   $0xf01076c0
f010265b:	68 6f 74 10 f0       	push   $0xf010746f
f0102660:	68 fe 03 00 00       	push   $0x3fe
f0102665:	68 49 74 10 f0       	push   $0xf0107449
f010266a:	e8 d1 d9 ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f010266f:	68 40 70 10 f0       	push   $0xf0107040
f0102674:	68 6f 74 10 f0       	push   $0xf010746f
f0102679:	68 01 04 00 00       	push   $0x401
f010267e:	68 49 74 10 f0       	push   $0xf0107449
f0102683:	e8 b8 d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f0102688:	68 d1 76 10 f0       	push   $0xf01076d1
f010268d:	68 6f 74 10 f0       	push   $0xf010746f
f0102692:	68 02 04 00 00       	push   $0x402
f0102697:	68 49 74 10 f0       	push   $0xf0107449
f010269c:	e8 9f d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f01026a1:	68 dd 76 10 f0       	push   $0xf01076dd
f01026a6:	68 6f 74 10 f0       	push   $0xf010746f
f01026ab:	68 03 04 00 00       	push   $0x403
f01026b0:	68 49 74 10 f0       	push   $0xf0107449
f01026b5:	e8 86 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01026ba:	68 1c 70 10 f0       	push   $0xf010701c
f01026bf:	68 6f 74 10 f0       	push   $0xf010746f
f01026c4:	68 07 04 00 00       	push   $0x407
f01026c9:	68 49 74 10 f0       	push   $0xf0107449
f01026ce:	e8 6d d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01026d3:	68 78 70 10 f0       	push   $0xf0107078
f01026d8:	68 6f 74 10 f0       	push   $0xf010746f
f01026dd:	68 08 04 00 00       	push   $0x408
f01026e2:	68 49 74 10 f0       	push   $0xf0107449
f01026e7:	e8 54 d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f01026ec:	68 f2 76 10 f0       	push   $0xf01076f2
f01026f1:	68 6f 74 10 f0       	push   $0xf010746f
f01026f6:	68 09 04 00 00       	push   $0x409
f01026fb:	68 49 74 10 f0       	push   $0xf0107449
f0102700:	e8 3b d9 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102705:	68 c0 76 10 f0       	push   $0xf01076c0
f010270a:	68 6f 74 10 f0       	push   $0xf010746f
f010270f:	68 0a 04 00 00       	push   $0x40a
f0102714:	68 49 74 10 f0       	push   $0xf0107449
f0102719:	e8 22 d9 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f010271e:	68 a0 70 10 f0       	push   $0xf01070a0
f0102723:	68 6f 74 10 f0       	push   $0xf010746f
f0102728:	68 0d 04 00 00       	push   $0x40d
f010272d:	68 49 74 10 f0       	push   $0xf0107449
f0102732:	e8 09 d9 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0102737:	68 14 76 10 f0       	push   $0xf0107614
f010273c:	68 6f 74 10 f0       	push   $0xf010746f
f0102741:	68 10 04 00 00       	push   $0x410
f0102746:	68 49 74 10 f0       	push   $0xf0107449
f010274b:	e8 f0 d8 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102750:	68 44 6d 10 f0       	push   $0xf0106d44
f0102755:	68 6f 74 10 f0       	push   $0xf010746f
f010275a:	68 13 04 00 00       	push   $0x413
f010275f:	68 49 74 10 f0       	push   $0xf0107449
f0102764:	e8 d7 d8 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0102769:	68 77 76 10 f0       	push   $0xf0107677
f010276e:	68 6f 74 10 f0       	push   $0xf010746f
f0102773:	68 15 04 00 00       	push   $0x415
f0102778:	68 49 74 10 f0       	push   $0xf0107449
f010277d:	e8 be d8 ff ff       	call   f0100040 <_panic>
f0102782:	50                   	push   %eax
f0102783:	68 84 65 10 f0       	push   $0xf0106584
f0102788:	68 1c 04 00 00       	push   $0x41c
f010278d:	68 49 74 10 f0       	push   $0xf0107449
f0102792:	e8 a9 d8 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102797:	68 03 77 10 f0       	push   $0xf0107703
f010279c:	68 6f 74 10 f0       	push   $0xf010746f
f01027a1:	68 1d 04 00 00       	push   $0x41d
f01027a6:	68 49 74 10 f0       	push   $0xf0107449
f01027ab:	e8 90 d8 ff ff       	call   f0100040 <_panic>
f01027b0:	50                   	push   %eax
f01027b1:	68 84 65 10 f0       	push   $0xf0106584
f01027b6:	6a 58                	push   $0x58
f01027b8:	68 55 74 10 f0       	push   $0xf0107455
f01027bd:	e8 7e d8 ff ff       	call   f0100040 <_panic>
f01027c2:	52                   	push   %edx
f01027c3:	68 84 65 10 f0       	push   $0xf0106584
f01027c8:	6a 58                	push   $0x58
f01027ca:	68 55 74 10 f0       	push   $0xf0107455
f01027cf:	e8 6c d8 ff ff       	call   f0100040 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f01027d4:	68 1b 77 10 f0       	push   $0xf010771b
f01027d9:	68 6f 74 10 f0       	push   $0xf010746f
f01027de:	68 27 04 00 00       	push   $0x427
f01027e3:	68 49 74 10 f0       	push   $0xf0107449
f01027e8:	e8 53 d8 ff ff       	call   f0100040 <_panic>
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f01027ed:	68 c4 70 10 f0       	push   $0xf01070c4
f01027f2:	68 6f 74 10 f0       	push   $0xf010746f
f01027f7:	68 37 04 00 00       	push   $0x437
f01027fc:	68 49 74 10 f0       	push   $0xf0107449
f0102801:	e8 3a d8 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f0102806:	68 ec 70 10 f0       	push   $0xf01070ec
f010280b:	68 6f 74 10 f0       	push   $0xf010746f
f0102810:	68 38 04 00 00       	push   $0x438
f0102815:	68 49 74 10 f0       	push   $0xf0107449
f010281a:	e8 21 d8 ff ff       	call   f0100040 <_panic>
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f010281f:	68 14 71 10 f0       	push   $0xf0107114
f0102824:	68 6f 74 10 f0       	push   $0xf010746f
f0102829:	68 3a 04 00 00       	push   $0x43a
f010282e:	68 49 74 10 f0       	push   $0xf0107449
f0102833:	e8 08 d8 ff ff       	call   f0100040 <_panic>
	assert(mm1 + 8192 <= mm2);
f0102838:	68 32 77 10 f0       	push   $0xf0107732
f010283d:	68 6f 74 10 f0       	push   $0xf010746f
f0102842:	68 3c 04 00 00       	push   $0x43c
f0102847:	68 49 74 10 f0       	push   $0xf0107449
f010284c:	e8 ef d7 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102851:	68 3c 71 10 f0       	push   $0xf010713c
f0102856:	68 6f 74 10 f0       	push   $0xf010746f
f010285b:	68 3e 04 00 00       	push   $0x43e
f0102860:	68 49 74 10 f0       	push   $0xf0107449
f0102865:	e8 d6 d7 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f010286a:	68 60 71 10 f0       	push   $0xf0107160
f010286f:	68 6f 74 10 f0       	push   $0xf010746f
f0102874:	68 3f 04 00 00       	push   $0x43f
f0102879:	68 49 74 10 f0       	push   $0xf0107449
f010287e:	e8 bd d7 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102883:	68 90 71 10 f0       	push   $0xf0107190
f0102888:	68 6f 74 10 f0       	push   $0xf010746f
f010288d:	68 40 04 00 00       	push   $0x440
f0102892:	68 49 74 10 f0       	push   $0xf0107449
f0102897:	e8 a4 d7 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f010289c:	68 b4 71 10 f0       	push   $0xf01071b4
f01028a1:	68 6f 74 10 f0       	push   $0xf010746f
f01028a6:	68 41 04 00 00       	push   $0x441
f01028ab:	68 49 74 10 f0       	push   $0xf0107449
f01028b0:	e8 8b d7 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f01028b5:	68 e0 71 10 f0       	push   $0xf01071e0
f01028ba:	68 6f 74 10 f0       	push   $0xf010746f
f01028bf:	68 43 04 00 00       	push   $0x443
f01028c4:	68 49 74 10 f0       	push   $0xf0107449
f01028c9:	e8 72 d7 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f01028ce:	68 24 72 10 f0       	push   $0xf0107224
f01028d3:	68 6f 74 10 f0       	push   $0xf010746f
f01028d8:	68 44 04 00 00       	push   $0x444
f01028dd:	68 49 74 10 f0       	push   $0xf0107449
f01028e2:	e8 59 d7 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01028e7:	50                   	push   %eax
f01028e8:	68 a8 65 10 f0       	push   $0xf01065a8
f01028ed:	68 bb 00 00 00       	push   $0xbb
f01028f2:	68 49 74 10 f0       	push   $0xf0107449
f01028f7:	e8 44 d7 ff ff       	call   f0100040 <_panic>
f01028fc:	50                   	push   %eax
f01028fd:	68 a8 65 10 f0       	push   $0xf01065a8
f0102902:	68 c3 00 00 00       	push   $0xc3
f0102907:	68 49 74 10 f0       	push   $0xf0107449
f010290c:	e8 2f d7 ff ff       	call   f0100040 <_panic>
f0102911:	50                   	push   %eax
f0102912:	68 a8 65 10 f0       	push   $0xf01065a8
f0102917:	68 cf 00 00 00       	push   $0xcf
f010291c:	68 49 74 10 f0       	push   $0xf0107449
f0102921:	e8 1a d7 ff ff       	call   f0100040 <_panic>
f0102926:	53                   	push   %ebx
f0102927:	68 a8 65 10 f0       	push   $0xf01065a8
f010292c:	68 11 01 00 00       	push   $0x111
f0102931:	68 49 74 10 f0       	push   $0xf0107449
f0102936:	e8 05 d7 ff ff       	call   f0100040 <_panic>
f010293b:	ff 75 c4             	pushl  -0x3c(%ebp)
f010293e:	68 a8 65 10 f0       	push   $0xf01065a8
f0102943:	68 5c 03 00 00       	push   $0x35c
f0102948:	68 49 74 10 f0       	push   $0xf0107449
f010294d:	e8 ee d6 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102952:	68 58 72 10 f0       	push   $0xf0107258
f0102957:	68 6f 74 10 f0       	push   $0xf010746f
f010295c:	68 5c 03 00 00       	push   $0x35c
f0102961:	68 49 74 10 f0       	push   $0xf0107449
f0102966:	e8 d5 d6 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010296b:	a1 44 52 21 f0       	mov    0xf0215244,%eax
f0102970:	89 45 d0             	mov    %eax,-0x30(%ebp)
	if ((uint32_t)kva < KERNBASE)
f0102973:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102976:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f010297b:	8d b0 00 00 40 21    	lea    0x21400000(%eax),%esi
f0102981:	89 da                	mov    %ebx,%edx
f0102983:	89 f8                	mov    %edi,%eax
f0102985:	e8 7c e1 ff ff       	call   f0100b06 <check_va2pa>
f010298a:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102991:	76 22                	jbe    f01029b5 <mem_init+0x1660>
f0102993:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f0102996:	39 d0                	cmp    %edx,%eax
f0102998:	75 32                	jne    f01029cc <mem_init+0x1677>
f010299a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
f01029a0:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f01029a6:	75 d9                	jne    f0102981 <mem_init+0x162c>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01029a8:	8b 75 c8             	mov    -0x38(%ebp),%esi
f01029ab:	c1 e6 0c             	shl    $0xc,%esi
f01029ae:	bb 00 00 00 00       	mov    $0x0,%ebx
f01029b3:	eb 4b                	jmp    f0102a00 <mem_init+0x16ab>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01029b5:	ff 75 d0             	pushl  -0x30(%ebp)
f01029b8:	68 a8 65 10 f0       	push   $0xf01065a8
f01029bd:	68 61 03 00 00       	push   $0x361
f01029c2:	68 49 74 10 f0       	push   $0xf0107449
f01029c7:	e8 74 d6 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01029cc:	68 8c 72 10 f0       	push   $0xf010728c
f01029d1:	68 6f 74 10 f0       	push   $0xf010746f
f01029d6:	68 61 03 00 00       	push   $0x361
f01029db:	68 49 74 10 f0       	push   $0xf0107449
f01029e0:	e8 5b d6 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01029e5:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f01029eb:	89 f8                	mov    %edi,%eax
f01029ed:	e8 14 e1 ff ff       	call   f0100b06 <check_va2pa>
f01029f2:	39 c3                	cmp    %eax,%ebx
f01029f4:	0f 85 f9 00 00 00    	jne    f0102af3 <mem_init+0x179e>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01029fa:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102a00:	39 f3                	cmp    %esi,%ebx
f0102a02:	72 e1                	jb     f01029e5 <mem_init+0x1690>
f0102a04:	c7 45 d4 00 70 21 f0 	movl   $0xf0217000,-0x2c(%ebp)
f0102a0b:	be 00 80 ff ef       	mov    $0xefff8000,%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102a10:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102a13:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0102a16:	8d 86 00 80 00 00    	lea    0x8000(%esi),%eax
f0102a1c:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102a1f:	89 f3                	mov    %esi,%ebx
f0102a21:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102a24:	05 00 80 00 20       	add    $0x20008000,%eax
f0102a29:	89 75 c8             	mov    %esi,-0x38(%ebp)
f0102a2c:	89 c6                	mov    %eax,%esi
f0102a2e:	89 da                	mov    %ebx,%edx
f0102a30:	89 f8                	mov    %edi,%eax
f0102a32:	e8 cf e0 ff ff       	call   f0100b06 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102a37:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102a3e:	0f 86 c8 00 00 00    	jbe    f0102b0c <mem_init+0x17b7>
f0102a44:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f0102a47:	39 d0                	cmp    %edx,%eax
f0102a49:	0f 85 d4 00 00 00    	jne    f0102b23 <mem_init+0x17ce>
f0102a4f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102a55:	3b 5d d0             	cmp    -0x30(%ebp),%ebx
f0102a58:	75 d4                	jne    f0102a2e <mem_init+0x16d9>
f0102a5a:	8b 75 c8             	mov    -0x38(%ebp),%esi
f0102a5d:	8d 9e 00 80 ff ff    	lea    -0x8000(%esi),%ebx
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102a63:	89 da                	mov    %ebx,%edx
f0102a65:	89 f8                	mov    %edi,%eax
f0102a67:	e8 9a e0 ff ff       	call   f0100b06 <check_va2pa>
f0102a6c:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a6f:	0f 85 c7 00 00 00    	jne    f0102b3c <mem_init+0x17e7>
f0102a75:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102a7b:	39 f3                	cmp    %esi,%ebx
f0102a7d:	75 e4                	jne    f0102a63 <mem_init+0x170e>
f0102a7f:	81 ee 00 00 01 00    	sub    $0x10000,%esi
f0102a85:	81 45 cc 00 80 01 00 	addl   $0x18000,-0x34(%ebp)
f0102a8c:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102a8f:	81 45 d4 00 80 00 00 	addl   $0x8000,-0x2c(%ebp)
	for (n = 0; n < NCPU; n++) {
f0102a96:	3d 00 70 2d f0       	cmp    $0xf02d7000,%eax
f0102a9b:	0f 85 6f ff ff ff    	jne    f0102a10 <mem_init+0x16bb>
	for (i = 0; i < NPDENTRIES; i++) {
f0102aa1:	b8 00 00 00 00       	mov    $0x0,%eax
			if (i >= PDX(KERNBASE)) {
f0102aa6:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102aab:	0f 87 a4 00 00 00    	ja     f0102b55 <mem_init+0x1800>
				assert(pgdir[i] == 0);
f0102ab1:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102ab5:	0f 85 dd 00 00 00    	jne    f0102b98 <mem_init+0x1843>
	for (i = 0; i < NPDENTRIES; i++) {
f0102abb:	83 c0 01             	add    $0x1,%eax
f0102abe:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102ac3:	0f 87 e8 00 00 00    	ja     f0102bb1 <mem_init+0x185c>
		switch (i) {
f0102ac9:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102acf:	83 fa 04             	cmp    $0x4,%edx
f0102ad2:	77 d2                	ja     f0102aa6 <mem_init+0x1751>
			assert(pgdir[i] & PTE_P);
f0102ad4:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102ad8:	75 e1                	jne    f0102abb <mem_init+0x1766>
f0102ada:	68 5d 77 10 f0       	push   $0xf010775d
f0102adf:	68 6f 74 10 f0       	push   $0xf010746f
f0102ae4:	68 7a 03 00 00       	push   $0x37a
f0102ae9:	68 49 74 10 f0       	push   $0xf0107449
f0102aee:	e8 4d d5 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102af3:	68 c0 72 10 f0       	push   $0xf01072c0
f0102af8:	68 6f 74 10 f0       	push   $0xf010746f
f0102afd:	68 65 03 00 00       	push   $0x365
f0102b02:	68 49 74 10 f0       	push   $0xf0107449
f0102b07:	e8 34 d5 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b0c:	ff 75 c4             	pushl  -0x3c(%ebp)
f0102b0f:	68 a8 65 10 f0       	push   $0xf01065a8
f0102b14:	68 6d 03 00 00       	push   $0x36d
f0102b19:	68 49 74 10 f0       	push   $0xf0107449
f0102b1e:	e8 1d d5 ff ff       	call   f0100040 <_panic>
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102b23:	68 e8 72 10 f0       	push   $0xf01072e8
f0102b28:	68 6f 74 10 f0       	push   $0xf010746f
f0102b2d:	68 6d 03 00 00       	push   $0x36d
f0102b32:	68 49 74 10 f0       	push   $0xf0107449
f0102b37:	e8 04 d5 ff ff       	call   f0100040 <_panic>
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102b3c:	68 30 73 10 f0       	push   $0xf0107330
f0102b41:	68 6f 74 10 f0       	push   $0xf010746f
f0102b46:	68 6f 03 00 00       	push   $0x36f
f0102b4b:	68 49 74 10 f0       	push   $0xf0107449
f0102b50:	e8 eb d4 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_P);
f0102b55:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0102b58:	f6 c2 01             	test   $0x1,%dl
f0102b5b:	74 22                	je     f0102b7f <mem_init+0x182a>
				assert(pgdir[i] & PTE_W);
f0102b5d:	f6 c2 02             	test   $0x2,%dl
f0102b60:	0f 85 55 ff ff ff    	jne    f0102abb <mem_init+0x1766>
f0102b66:	68 6e 77 10 f0       	push   $0xf010776e
f0102b6b:	68 6f 74 10 f0       	push   $0xf010746f
f0102b70:	68 7f 03 00 00       	push   $0x37f
f0102b75:	68 49 74 10 f0       	push   $0xf0107449
f0102b7a:	e8 c1 d4 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_P);
f0102b7f:	68 5d 77 10 f0       	push   $0xf010775d
f0102b84:	68 6f 74 10 f0       	push   $0xf010746f
f0102b89:	68 7e 03 00 00       	push   $0x37e
f0102b8e:	68 49 74 10 f0       	push   $0xf0107449
f0102b93:	e8 a8 d4 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] == 0);
f0102b98:	68 7f 77 10 f0       	push   $0xf010777f
f0102b9d:	68 6f 74 10 f0       	push   $0xf010746f
f0102ba2:	68 81 03 00 00       	push   $0x381
f0102ba7:	68 49 74 10 f0       	push   $0xf0107449
f0102bac:	e8 8f d4 ff ff       	call   f0100040 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102bb1:	83 ec 0c             	sub    $0xc,%esp
f0102bb4:	68 54 73 10 f0       	push   $0xf0107354
f0102bb9:	e8 8a 0d 00 00       	call   f0103948 <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102bbe:	a1 8c 5e 21 f0       	mov    0xf0215e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0102bc3:	83 c4 10             	add    $0x10,%esp
f0102bc6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102bcb:	0f 86 fe 01 00 00    	jbe    f0102dcf <mem_init+0x1a7a>
	return (physaddr_t)kva - KERNBASE;
f0102bd1:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102bd6:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102bd9:	b8 00 00 00 00       	mov    $0x0,%eax
f0102bde:	e8 87 df ff ff       	call   f0100b6a <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102be3:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102be6:	83 e0 f3             	and    $0xfffffff3,%eax
f0102be9:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102bee:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102bf1:	83 ec 0c             	sub    $0xc,%esp
f0102bf4:	6a 00                	push   $0x0
f0102bf6:	e8 6a e3 ff ff       	call   f0100f65 <page_alloc>
f0102bfb:	89 c3                	mov    %eax,%ebx
f0102bfd:	83 c4 10             	add    $0x10,%esp
f0102c00:	85 c0                	test   %eax,%eax
f0102c02:	0f 84 dc 01 00 00    	je     f0102de4 <mem_init+0x1a8f>
	assert((pp1 = page_alloc(0)));
f0102c08:	83 ec 0c             	sub    $0xc,%esp
f0102c0b:	6a 00                	push   $0x0
f0102c0d:	e8 53 e3 ff ff       	call   f0100f65 <page_alloc>
f0102c12:	89 c7                	mov    %eax,%edi
f0102c14:	83 c4 10             	add    $0x10,%esp
f0102c17:	85 c0                	test   %eax,%eax
f0102c19:	0f 84 de 01 00 00    	je     f0102dfd <mem_init+0x1aa8>
	assert((pp2 = page_alloc(0)));
f0102c1f:	83 ec 0c             	sub    $0xc,%esp
f0102c22:	6a 00                	push   $0x0
f0102c24:	e8 3c e3 ff ff       	call   f0100f65 <page_alloc>
f0102c29:	89 c6                	mov    %eax,%esi
f0102c2b:	83 c4 10             	add    $0x10,%esp
f0102c2e:	85 c0                	test   %eax,%eax
f0102c30:	0f 84 e0 01 00 00    	je     f0102e16 <mem_init+0x1ac1>
	page_free(pp0);
f0102c36:	83 ec 0c             	sub    $0xc,%esp
f0102c39:	53                   	push   %ebx
f0102c3a:	e8 98 e3 ff ff       	call   f0100fd7 <page_free>
	return (pp - pages) << PGSHIFT;
f0102c3f:	89 f8                	mov    %edi,%eax
f0102c41:	2b 05 90 5e 21 f0    	sub    0xf0215e90,%eax
f0102c47:	c1 f8 03             	sar    $0x3,%eax
f0102c4a:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102c4d:	89 c2                	mov    %eax,%edx
f0102c4f:	c1 ea 0c             	shr    $0xc,%edx
f0102c52:	83 c4 10             	add    $0x10,%esp
f0102c55:	3b 15 88 5e 21 f0    	cmp    0xf0215e88,%edx
f0102c5b:	0f 83 ce 01 00 00    	jae    f0102e2f <mem_init+0x1ada>
	memset(page2kva(pp1), 1, PGSIZE);
f0102c61:	83 ec 04             	sub    $0x4,%esp
f0102c64:	68 00 10 00 00       	push   $0x1000
f0102c69:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102c6b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c70:	50                   	push   %eax
f0102c71:	e8 89 2c 00 00       	call   f01058ff <memset>
	return (pp - pages) << PGSHIFT;
f0102c76:	89 f0                	mov    %esi,%eax
f0102c78:	2b 05 90 5e 21 f0    	sub    0xf0215e90,%eax
f0102c7e:	c1 f8 03             	sar    $0x3,%eax
f0102c81:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102c84:	89 c2                	mov    %eax,%edx
f0102c86:	c1 ea 0c             	shr    $0xc,%edx
f0102c89:	83 c4 10             	add    $0x10,%esp
f0102c8c:	3b 15 88 5e 21 f0    	cmp    0xf0215e88,%edx
f0102c92:	0f 83 a9 01 00 00    	jae    f0102e41 <mem_init+0x1aec>
	memset(page2kva(pp2), 2, PGSIZE);
f0102c98:	83 ec 04             	sub    $0x4,%esp
f0102c9b:	68 00 10 00 00       	push   $0x1000
f0102ca0:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102ca2:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102ca7:	50                   	push   %eax
f0102ca8:	e8 52 2c 00 00       	call   f01058ff <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102cad:	6a 02                	push   $0x2
f0102caf:	68 00 10 00 00       	push   $0x1000
f0102cb4:	57                   	push   %edi
f0102cb5:	ff 35 8c 5e 21 f0    	pushl  0xf0215e8c
f0102cbb:	e8 ca e5 ff ff       	call   f010128a <page_insert>
	assert(pp1->pp_ref == 1);
f0102cc0:	83 c4 20             	add    $0x20,%esp
f0102cc3:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102cc8:	0f 85 85 01 00 00    	jne    f0102e53 <mem_init+0x1afe>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102cce:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102cd5:	01 01 01 
f0102cd8:	0f 85 8e 01 00 00    	jne    f0102e6c <mem_init+0x1b17>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102cde:	6a 02                	push   $0x2
f0102ce0:	68 00 10 00 00       	push   $0x1000
f0102ce5:	56                   	push   %esi
f0102ce6:	ff 35 8c 5e 21 f0    	pushl  0xf0215e8c
f0102cec:	e8 99 e5 ff ff       	call   f010128a <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102cf1:	83 c4 10             	add    $0x10,%esp
f0102cf4:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102cfb:	02 02 02 
f0102cfe:	0f 85 81 01 00 00    	jne    f0102e85 <mem_init+0x1b30>
	assert(pp2->pp_ref == 1);
f0102d04:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102d09:	0f 85 8f 01 00 00    	jne    f0102e9e <mem_init+0x1b49>
	assert(pp1->pp_ref == 0);
f0102d0f:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102d14:	0f 85 9d 01 00 00    	jne    f0102eb7 <mem_init+0x1b62>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102d1a:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102d21:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0102d24:	89 f0                	mov    %esi,%eax
f0102d26:	2b 05 90 5e 21 f0    	sub    0xf0215e90,%eax
f0102d2c:	c1 f8 03             	sar    $0x3,%eax
f0102d2f:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102d32:	89 c2                	mov    %eax,%edx
f0102d34:	c1 ea 0c             	shr    $0xc,%edx
f0102d37:	3b 15 88 5e 21 f0    	cmp    0xf0215e88,%edx
f0102d3d:	0f 83 8d 01 00 00    	jae    f0102ed0 <mem_init+0x1b7b>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102d43:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102d4a:	03 03 03 
f0102d4d:	0f 85 8f 01 00 00    	jne    f0102ee2 <mem_init+0x1b8d>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102d53:	83 ec 08             	sub    $0x8,%esp
f0102d56:	68 00 10 00 00       	push   $0x1000
f0102d5b:	ff 35 8c 5e 21 f0    	pushl  0xf0215e8c
f0102d61:	e8 d4 e4 ff ff       	call   f010123a <page_remove>
	assert(pp2->pp_ref == 0);
f0102d66:	83 c4 10             	add    $0x10,%esp
f0102d69:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102d6e:	0f 85 87 01 00 00    	jne    f0102efb <mem_init+0x1ba6>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102d74:	8b 0d 8c 5e 21 f0    	mov    0xf0215e8c,%ecx
f0102d7a:	8b 11                	mov    (%ecx),%edx
f0102d7c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0102d82:	89 d8                	mov    %ebx,%eax
f0102d84:	2b 05 90 5e 21 f0    	sub    0xf0215e90,%eax
f0102d8a:	c1 f8 03             	sar    $0x3,%eax
f0102d8d:	c1 e0 0c             	shl    $0xc,%eax
f0102d90:	39 c2                	cmp    %eax,%edx
f0102d92:	0f 85 7c 01 00 00    	jne    f0102f14 <mem_init+0x1bbf>
	kern_pgdir[0] = 0;
f0102d98:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102d9e:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102da3:	0f 85 84 01 00 00    	jne    f0102f2d <mem_init+0x1bd8>
	pp0->pp_ref = 0;
f0102da9:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102daf:	83 ec 0c             	sub    $0xc,%esp
f0102db2:	53                   	push   %ebx
f0102db3:	e8 1f e2 ff ff       	call   f0100fd7 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102db8:	c7 04 24 e8 73 10 f0 	movl   $0xf01073e8,(%esp)
f0102dbf:	e8 84 0b 00 00       	call   f0103948 <cprintf>
}
f0102dc4:	83 c4 10             	add    $0x10,%esp
f0102dc7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102dca:	5b                   	pop    %ebx
f0102dcb:	5e                   	pop    %esi
f0102dcc:	5f                   	pop    %edi
f0102dcd:	5d                   	pop    %ebp
f0102dce:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102dcf:	50                   	push   %eax
f0102dd0:	68 a8 65 10 f0       	push   $0xf01065a8
f0102dd5:	68 e6 00 00 00       	push   $0xe6
f0102dda:	68 49 74 10 f0       	push   $0xf0107449
f0102ddf:	e8 5c d2 ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f0102de4:	68 69 75 10 f0       	push   $0xf0107569
f0102de9:	68 6f 74 10 f0       	push   $0xf010746f
f0102dee:	68 59 04 00 00       	push   $0x459
f0102df3:	68 49 74 10 f0       	push   $0xf0107449
f0102df8:	e8 43 d2 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102dfd:	68 7f 75 10 f0       	push   $0xf010757f
f0102e02:	68 6f 74 10 f0       	push   $0xf010746f
f0102e07:	68 5a 04 00 00       	push   $0x45a
f0102e0c:	68 49 74 10 f0       	push   $0xf0107449
f0102e11:	e8 2a d2 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102e16:	68 95 75 10 f0       	push   $0xf0107595
f0102e1b:	68 6f 74 10 f0       	push   $0xf010746f
f0102e20:	68 5b 04 00 00       	push   $0x45b
f0102e25:	68 49 74 10 f0       	push   $0xf0107449
f0102e2a:	e8 11 d2 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102e2f:	50                   	push   %eax
f0102e30:	68 84 65 10 f0       	push   $0xf0106584
f0102e35:	6a 58                	push   $0x58
f0102e37:	68 55 74 10 f0       	push   $0xf0107455
f0102e3c:	e8 ff d1 ff ff       	call   f0100040 <_panic>
f0102e41:	50                   	push   %eax
f0102e42:	68 84 65 10 f0       	push   $0xf0106584
f0102e47:	6a 58                	push   $0x58
f0102e49:	68 55 74 10 f0       	push   $0xf0107455
f0102e4e:	e8 ed d1 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102e53:	68 66 76 10 f0       	push   $0xf0107666
f0102e58:	68 6f 74 10 f0       	push   $0xf010746f
f0102e5d:	68 60 04 00 00       	push   $0x460
f0102e62:	68 49 74 10 f0       	push   $0xf0107449
f0102e67:	e8 d4 d1 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102e6c:	68 74 73 10 f0       	push   $0xf0107374
f0102e71:	68 6f 74 10 f0       	push   $0xf010746f
f0102e76:	68 61 04 00 00       	push   $0x461
f0102e7b:	68 49 74 10 f0       	push   $0xf0107449
f0102e80:	e8 bb d1 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102e85:	68 98 73 10 f0       	push   $0xf0107398
f0102e8a:	68 6f 74 10 f0       	push   $0xf010746f
f0102e8f:	68 63 04 00 00       	push   $0x463
f0102e94:	68 49 74 10 f0       	push   $0xf0107449
f0102e99:	e8 a2 d1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102e9e:	68 88 76 10 f0       	push   $0xf0107688
f0102ea3:	68 6f 74 10 f0       	push   $0xf010746f
f0102ea8:	68 64 04 00 00       	push   $0x464
f0102ead:	68 49 74 10 f0       	push   $0xf0107449
f0102eb2:	e8 89 d1 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102eb7:	68 f2 76 10 f0       	push   $0xf01076f2
f0102ebc:	68 6f 74 10 f0       	push   $0xf010746f
f0102ec1:	68 65 04 00 00       	push   $0x465
f0102ec6:	68 49 74 10 f0       	push   $0xf0107449
f0102ecb:	e8 70 d1 ff ff       	call   f0100040 <_panic>
f0102ed0:	50                   	push   %eax
f0102ed1:	68 84 65 10 f0       	push   $0xf0106584
f0102ed6:	6a 58                	push   $0x58
f0102ed8:	68 55 74 10 f0       	push   $0xf0107455
f0102edd:	e8 5e d1 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102ee2:	68 bc 73 10 f0       	push   $0xf01073bc
f0102ee7:	68 6f 74 10 f0       	push   $0xf010746f
f0102eec:	68 67 04 00 00       	push   $0x467
f0102ef1:	68 49 74 10 f0       	push   $0xf0107449
f0102ef6:	e8 45 d1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102efb:	68 c0 76 10 f0       	push   $0xf01076c0
f0102f00:	68 6f 74 10 f0       	push   $0xf010746f
f0102f05:	68 69 04 00 00       	push   $0x469
f0102f0a:	68 49 74 10 f0       	push   $0xf0107449
f0102f0f:	e8 2c d1 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102f14:	68 44 6d 10 f0       	push   $0xf0106d44
f0102f19:	68 6f 74 10 f0       	push   $0xf010746f
f0102f1e:	68 6c 04 00 00       	push   $0x46c
f0102f23:	68 49 74 10 f0       	push   $0xf0107449
f0102f28:	e8 13 d1 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0102f2d:	68 77 76 10 f0       	push   $0xf0107677
f0102f32:	68 6f 74 10 f0       	push   $0xf010746f
f0102f37:	68 6e 04 00 00       	push   $0x46e
f0102f3c:	68 49 74 10 f0       	push   $0xf0107449
f0102f41:	e8 fa d0 ff ff       	call   f0100040 <_panic>

f0102f46 <user_mem_check>:
{
f0102f46:	55                   	push   %ebp
f0102f47:	89 e5                	mov    %esp,%ebp
f0102f49:	57                   	push   %edi
f0102f4a:	56                   	push   %esi
f0102f4b:	53                   	push   %ebx
f0102f4c:	83 ec 1c             	sub    $0x1c,%esp
        uintptr_t start = ROUNDDOWN((uintptr_t)va,PGSIZE);
f0102f4f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102f52:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0102f58:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	uintptr_t end = ROUNDUP((uintptr_t)va+len,PGSIZE);
f0102f5b:	8b 45 10             	mov    0x10(%ebp),%eax
f0102f5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102f61:	8d bc 01 ff 0f 00 00 	lea    0xfff(%ecx,%eax,1),%edi
f0102f68:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	  if(cur_va>ULIM || cur_pte==NULL || (*cur_pte&(perm|PTE_P))!=(perm|PTE_P)){
f0102f6e:	8b 75 14             	mov    0x14(%ebp),%esi
f0102f71:	83 ce 01             	or     $0x1,%esi
	for(uintptr_t cur_va =start; cur_va < end;cur_va+=PGSIZE){
f0102f74:	39 fb                	cmp    %edi,%ebx
f0102f76:	73 57                	jae    f0102fcf <user_mem_check+0x89>
	  cur_pte = pgdir_walk(env->env_pgdir,(void *)cur_va,0);
f0102f78:	83 ec 04             	sub    $0x4,%esp
f0102f7b:	6a 00                	push   $0x0
f0102f7d:	53                   	push   %ebx
f0102f7e:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f81:	ff 70 60             	pushl  0x60(%eax)
f0102f84:	e8 b2 e0 ff ff       	call   f010103b <pgdir_walk>
	  if(cur_va>ULIM || cur_pte==NULL || (*cur_pte&(perm|PTE_P))!=(perm|PTE_P)){
f0102f89:	83 c4 10             	add    $0x10,%esp
f0102f8c:	81 fb 00 00 80 ef    	cmp    $0xef800000,%ebx
f0102f92:	77 14                	ja     f0102fa8 <user_mem_check+0x62>
f0102f94:	85 c0                	test   %eax,%eax
f0102f96:	74 10                	je     f0102fa8 <user_mem_check+0x62>
f0102f98:	89 f2                	mov    %esi,%edx
f0102f9a:	23 10                	and    (%eax),%edx
f0102f9c:	39 d6                	cmp    %edx,%esi
f0102f9e:	75 08                	jne    f0102fa8 <user_mem_check+0x62>
	for(uintptr_t cur_va =start; cur_va < end;cur_va+=PGSIZE){
f0102fa0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102fa6:	eb cc                	jmp    f0102f74 <user_mem_check+0x2e>
	   if(cur_va==start)
f0102fa8:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102fab:	74 13                	je     f0102fc0 <user_mem_check+0x7a>
		 user_mem_check_addr = (uintptr_t)cur_va;
f0102fad:	89 1d 3c 52 21 f0    	mov    %ebx,0xf021523c
	    return -E_FAULT;  
f0102fb3:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
}
f0102fb8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102fbb:	5b                   	pop    %ebx
f0102fbc:	5e                   	pop    %esi
f0102fbd:	5f                   	pop    %edi
f0102fbe:	5d                   	pop    %ebp
f0102fbf:	c3                   	ret    
		 user_mem_check_addr = (uintptr_t)va;
f0102fc0:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102fc3:	a3 3c 52 21 f0       	mov    %eax,0xf021523c
	    return -E_FAULT;  
f0102fc8:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102fcd:	eb e9                	jmp    f0102fb8 <user_mem_check+0x72>
	return 0;
f0102fcf:	b8 00 00 00 00       	mov    $0x0,%eax
f0102fd4:	eb e2                	jmp    f0102fb8 <user_mem_check+0x72>

f0102fd6 <user_mem_assert>:
{
f0102fd6:	55                   	push   %ebp
f0102fd7:	89 e5                	mov    %esp,%ebp
f0102fd9:	53                   	push   %ebx
f0102fda:	83 ec 04             	sub    $0x4,%esp
f0102fdd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102fe0:	8b 45 14             	mov    0x14(%ebp),%eax
f0102fe3:	83 c8 04             	or     $0x4,%eax
f0102fe6:	50                   	push   %eax
f0102fe7:	ff 75 10             	pushl  0x10(%ebp)
f0102fea:	ff 75 0c             	pushl  0xc(%ebp)
f0102fed:	53                   	push   %ebx
f0102fee:	e8 53 ff ff ff       	call   f0102f46 <user_mem_check>
f0102ff3:	83 c4 10             	add    $0x10,%esp
f0102ff6:	85 c0                	test   %eax,%eax
f0102ff8:	78 05                	js     f0102fff <user_mem_assert+0x29>
}
f0102ffa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102ffd:	c9                   	leave  
f0102ffe:	c3                   	ret    
		cprintf("[%08x] user_mem_check assertion failure for "
f0102fff:	83 ec 04             	sub    $0x4,%esp
f0103002:	ff 35 3c 52 21 f0    	pushl  0xf021523c
f0103008:	ff 73 48             	pushl  0x48(%ebx)
f010300b:	68 14 74 10 f0       	push   $0xf0107414
f0103010:	e8 33 09 00 00       	call   f0103948 <cprintf>
		env_destroy(env);	// may not return
f0103015:	89 1c 24             	mov    %ebx,(%esp)
f0103018:	e8 2f 06 00 00       	call   f010364c <env_destroy>
f010301d:	83 c4 10             	add    $0x10,%esp
}
f0103020:	eb d8                	jmp    f0102ffa <user_mem_assert+0x24>

f0103022 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0103022:	55                   	push   %ebp
f0103023:	89 e5                	mov    %esp,%ebp
f0103025:	57                   	push   %edi
f0103026:	56                   	push   %esi
f0103027:	53                   	push   %ebx
f0103028:	83 ec 0c             	sub    $0xc,%esp
f010302b:	89 c7                	mov    %eax,%edi
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
        struct PageInfo *pp;
	uint32_t start = ROUNDDOWN((uint32_t)va,PGSIZE);
	uint32_t end = ROUNDUP((uint32_t)va+len,PGSIZE);
f010302d:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0103034:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	uint32_t start = ROUNDDOWN((uint32_t)va,PGSIZE);
f010303a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0103040:	89 d3                	mov    %edx,%ebx
	int i;
	for(i=start;i<end;i+=PGSIZE){
f0103042:	39 f3                	cmp    %esi,%ebx
f0103044:	73 5a                	jae    f01030a0 <region_alloc+0x7e>
	  pp = (struct PageInfo *)page_alloc(0);
f0103046:	83 ec 0c             	sub    $0xc,%esp
f0103049:	6a 00                	push   $0x0
f010304b:	e8 15 df ff ff       	call   f0100f65 <page_alloc>
	 if(!pp){
f0103050:	83 c4 10             	add    $0x10,%esp
f0103053:	85 c0                	test   %eax,%eax
f0103055:	74 1b                	je     f0103072 <region_alloc+0x50>
	  panic("region_alloc failed!\n");
	 }
	 if(page_insert(e->env_pgdir,pp,(void*)i,PTE_W|PTE_U)!=0)
f0103057:	6a 06                	push   $0x6
f0103059:	53                   	push   %ebx
f010305a:	50                   	push   %eax
f010305b:	ff 77 60             	pushl  0x60(%edi)
f010305e:	e8 27 e2 ff ff       	call   f010128a <page_insert>
f0103063:	83 c4 10             	add    $0x10,%esp
f0103066:	85 c0                	test   %eax,%eax
f0103068:	75 1f                	jne    f0103089 <region_alloc+0x67>
	for(i=start;i<end;i+=PGSIZE){
f010306a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103070:	eb d0                	jmp    f0103042 <region_alloc+0x20>
	  panic("region_alloc failed!\n");
f0103072:	83 ec 04             	sub    $0x4,%esp
f0103075:	68 8d 77 10 f0       	push   $0xf010778d
f010307a:	68 30 01 00 00       	push   $0x130
f010307f:	68 a3 77 10 f0       	push   $0xf01077a3
f0103084:	e8 b7 cf ff ff       	call   f0100040 <_panic>
		panic("region alloc error\n"); 
f0103089:	83 ec 04             	sub    $0x4,%esp
f010308c:	68 ae 77 10 f0       	push   $0xf01077ae
f0103091:	68 33 01 00 00       	push   $0x133
f0103096:	68 a3 77 10 f0       	push   $0xf01077a3
f010309b:	e8 a0 cf ff ff       	call   f0100040 <_panic>
	}
}
f01030a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01030a3:	5b                   	pop    %ebx
f01030a4:	5e                   	pop    %esi
f01030a5:	5f                   	pop    %edi
f01030a6:	5d                   	pop    %ebp
f01030a7:	c3                   	ret    

f01030a8 <envid2env>:
{
f01030a8:	55                   	push   %ebp
f01030a9:	89 e5                	mov    %esp,%ebp
f01030ab:	56                   	push   %esi
f01030ac:	53                   	push   %ebx
f01030ad:	8b 45 08             	mov    0x8(%ebp),%eax
f01030b0:	8b 55 10             	mov    0x10(%ebp),%edx
	if (envid == 0) {
f01030b3:	85 c0                	test   %eax,%eax
f01030b5:	74 2e                	je     f01030e5 <envid2env+0x3d>
	e = &envs[ENVX(envid)];
f01030b7:	89 c3                	mov    %eax,%ebx
f01030b9:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f01030bf:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f01030c2:	03 1d 44 52 21 f0    	add    0xf0215244,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01030c8:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f01030cc:	74 31                	je     f01030ff <envid2env+0x57>
f01030ce:	39 43 48             	cmp    %eax,0x48(%ebx)
f01030d1:	75 2c                	jne    f01030ff <envid2env+0x57>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01030d3:	84 d2                	test   %dl,%dl
f01030d5:	75 38                	jne    f010310f <envid2env+0x67>
	*env_store = e;
f01030d7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01030da:	89 18                	mov    %ebx,(%eax)
	return 0;
f01030dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01030e1:	5b                   	pop    %ebx
f01030e2:	5e                   	pop    %esi
f01030e3:	5d                   	pop    %ebp
f01030e4:	c3                   	ret    
		*env_store = curenv;
f01030e5:	e8 39 2e 00 00       	call   f0105f23 <cpunum>
f01030ea:	6b c0 74             	imul   $0x74,%eax,%eax
f01030ed:	8b 80 28 60 21 f0    	mov    -0xfde9fd8(%eax),%eax
f01030f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01030f6:	89 01                	mov    %eax,(%ecx)
		return 0;
f01030f8:	b8 00 00 00 00       	mov    $0x0,%eax
f01030fd:	eb e2                	jmp    f01030e1 <envid2env+0x39>
		*env_store = 0;
f01030ff:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103102:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103108:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010310d:	eb d2                	jmp    f01030e1 <envid2env+0x39>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f010310f:	e8 0f 2e 00 00       	call   f0105f23 <cpunum>
f0103114:	6b c0 74             	imul   $0x74,%eax,%eax
f0103117:	39 98 28 60 21 f0    	cmp    %ebx,-0xfde9fd8(%eax)
f010311d:	74 b8                	je     f01030d7 <envid2env+0x2f>
f010311f:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0103122:	e8 fc 2d 00 00       	call   f0105f23 <cpunum>
f0103127:	6b c0 74             	imul   $0x74,%eax,%eax
f010312a:	8b 80 28 60 21 f0    	mov    -0xfde9fd8(%eax),%eax
f0103130:	3b 70 48             	cmp    0x48(%eax),%esi
f0103133:	74 a2                	je     f01030d7 <envid2env+0x2f>
		*env_store = 0;
f0103135:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103138:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f010313e:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103143:	eb 9c                	jmp    f01030e1 <envid2env+0x39>

f0103145 <env_init_percpu>:
{
f0103145:	55                   	push   %ebp
f0103146:	89 e5                	mov    %esp,%ebp
	asm volatile("lgdt (%0)" : : "r" (p));
f0103148:	b8 20 23 12 f0       	mov    $0xf0122320,%eax
f010314d:	0f 01 10             	lgdtl  (%eax)
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0103150:	b8 23 00 00 00       	mov    $0x23,%eax
f0103155:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0103157:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0103159:	b8 10 00 00 00       	mov    $0x10,%eax
f010315e:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0103160:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0103162:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0103164:	ea 6b 31 10 f0 08 00 	ljmp   $0x8,$0xf010316b
	asm volatile("lldt %0" : : "r" (sel));
f010316b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103170:	0f 00 d0             	lldt   %ax
}
f0103173:	5d                   	pop    %ebp
f0103174:	c3                   	ret    

f0103175 <env_init>:
{
f0103175:	55                   	push   %ebp
f0103176:	89 e5                	mov    %esp,%ebp
f0103178:	56                   	push   %esi
f0103179:	53                   	push   %ebx
	  envs[i].env_id = 0;
f010317a:	8b 35 44 52 21 f0    	mov    0xf0215244,%esi
f0103180:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0103186:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f0103189:	ba 00 00 00 00       	mov    $0x0,%edx
f010318e:	89 c1                	mov    %eax,%ecx
f0103190:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
	  envs[i].env_status = ENV_FREE;
f0103197:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
	  envs[i].env_link = env_free_list;
f010319e:	89 50 44             	mov    %edx,0x44(%eax)
f01031a1:	83 e8 7c             	sub    $0x7c,%eax
	  env_free_list = &envs[i];
f01031a4:	89 ca                	mov    %ecx,%edx
	for(i=NENV-1;i>=0;i--){
f01031a6:	39 d8                	cmp    %ebx,%eax
f01031a8:	75 e4                	jne    f010318e <env_init+0x19>
f01031aa:	89 35 48 52 21 f0    	mov    %esi,0xf0215248
	env_init_percpu();
f01031b0:	e8 90 ff ff ff       	call   f0103145 <env_init_percpu>
}
f01031b5:	5b                   	pop    %ebx
f01031b6:	5e                   	pop    %esi
f01031b7:	5d                   	pop    %ebp
f01031b8:	c3                   	ret    

f01031b9 <env_alloc>:
{
f01031b9:	55                   	push   %ebp
f01031ba:	89 e5                	mov    %esp,%ebp
f01031bc:	53                   	push   %ebx
f01031bd:	83 ec 04             	sub    $0x4,%esp
	if (!(e = env_free_list))
f01031c0:	8b 1d 48 52 21 f0    	mov    0xf0215248,%ebx
f01031c6:	85 db                	test   %ebx,%ebx
f01031c8:	0f 84 56 01 00 00    	je     f0103324 <env_alloc+0x16b>
	if (!(p = page_alloc(ALLOC_ZERO)))
f01031ce:	83 ec 0c             	sub    $0xc,%esp
f01031d1:	6a 01                	push   $0x1
f01031d3:	e8 8d dd ff ff       	call   f0100f65 <page_alloc>
f01031d8:	83 c4 10             	add    $0x10,%esp
f01031db:	85 c0                	test   %eax,%eax
f01031dd:	0f 84 48 01 00 00    	je     f010332b <env_alloc+0x172>
	return (pp - pages) << PGSHIFT;
f01031e3:	89 c2                	mov    %eax,%edx
f01031e5:	2b 15 90 5e 21 f0    	sub    0xf0215e90,%edx
f01031eb:	c1 fa 03             	sar    $0x3,%edx
f01031ee:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01031f1:	89 d1                	mov    %edx,%ecx
f01031f3:	c1 e9 0c             	shr    $0xc,%ecx
f01031f6:	3b 0d 88 5e 21 f0    	cmp    0xf0215e88,%ecx
f01031fc:	0f 83 fb 00 00 00    	jae    f01032fd <env_alloc+0x144>
	return (void *)(pa + KERNBASE);
f0103202:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0103208:	89 53 60             	mov    %edx,0x60(%ebx)
        p->pp_ref++;
f010320b:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f0103210:	b8 00 00 00 00       	mov    $0x0,%eax
	  e->env_pgdir[i] = 0;
f0103215:	8b 53 60             	mov    0x60(%ebx),%edx
f0103218:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
f010321f:	83 c0 04             	add    $0x4,%eax
	for(i=0;i<PDX(UTOP);i++){
f0103222:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f0103227:	75 ec                	jne    f0103215 <env_alloc+0x5c>
	  e->env_pgdir[i] = kern_pgdir[i];
f0103229:	8b 15 8c 5e 21 f0    	mov    0xf0215e8c,%edx
f010322f:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f0103232:	8b 53 60             	mov    0x60(%ebx),%edx
f0103235:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f0103238:	83 c0 04             	add    $0x4,%eax
	for(i=PDX(UTOP);i<NPDENTRIES;i++){
f010323b:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0103240:	75 e7                	jne    f0103229 <env_alloc+0x70>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103242:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0103245:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010324a:	0f 86 bf 00 00 00    	jbe    f010330f <env_alloc+0x156>
	return (physaddr_t)kva - KERNBASE;
f0103250:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103256:	83 ca 05             	or     $0x5,%edx
f0103259:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f010325f:	8b 43 48             	mov    0x48(%ebx),%eax
f0103262:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103267:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f010326c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103271:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103274:	89 da                	mov    %ebx,%edx
f0103276:	2b 15 44 52 21 f0    	sub    0xf0215244,%edx
f010327c:	c1 fa 02             	sar    $0x2,%edx
f010327f:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f0103285:	09 d0                	or     %edx,%eax
f0103287:	89 43 48             	mov    %eax,0x48(%ebx)
	e->env_parent_id = parent_id;
f010328a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010328d:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103290:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103297:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f010329e:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01032a5:	83 ec 04             	sub    $0x4,%esp
f01032a8:	6a 44                	push   $0x44
f01032aa:	6a 00                	push   $0x0
f01032ac:	53                   	push   %ebx
f01032ad:	e8 4d 26 00 00       	call   f01058ff <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f01032b2:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01032b8:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f01032be:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f01032c4:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01032cb:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
        e->env_tf.tf_eflags |= FL_IF;
f01032d1:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	e->env_pgfault_upcall = 0;
f01032d8:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)
	e->env_ipc_recving = 0;
f01032df:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	env_free_list = e->env_link;
f01032e3:	8b 43 44             	mov    0x44(%ebx),%eax
f01032e6:	a3 48 52 21 f0       	mov    %eax,0xf0215248
	*newenv_store = e;
f01032eb:	8b 45 08             	mov    0x8(%ebp),%eax
f01032ee:	89 18                	mov    %ebx,(%eax)
	return 0;
f01032f0:	83 c4 10             	add    $0x10,%esp
f01032f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01032f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01032fb:	c9                   	leave  
f01032fc:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01032fd:	52                   	push   %edx
f01032fe:	68 84 65 10 f0       	push   $0xf0106584
f0103303:	6a 58                	push   $0x58
f0103305:	68 55 74 10 f0       	push   $0xf0107455
f010330a:	e8 31 cd ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010330f:	50                   	push   %eax
f0103310:	68 a8 65 10 f0       	push   $0xf01065a8
f0103315:	68 cc 00 00 00       	push   $0xcc
f010331a:	68 a3 77 10 f0       	push   $0xf01077a3
f010331f:	e8 1c cd ff ff       	call   f0100040 <_panic>
		return -E_NO_FREE_ENV;
f0103324:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103329:	eb cd                	jmp    f01032f8 <env_alloc+0x13f>
		return -E_NO_MEM;
f010332b:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0103330:	eb c6                	jmp    f01032f8 <env_alloc+0x13f>

f0103332 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103332:	55                   	push   %ebp
f0103333:	89 e5                	mov    %esp,%ebp
f0103335:	57                   	push   %edi
f0103336:	56                   	push   %esi
f0103337:	53                   	push   %ebx
f0103338:	83 ec 34             	sub    $0x34,%esp
f010333b:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here
	struct Env *e;
     if(env_alloc(&e,0) < 0)
f010333e:	6a 00                	push   $0x0
f0103340:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103343:	50                   	push   %eax
f0103344:	e8 70 fe ff ff       	call   f01031b9 <env_alloc>
f0103349:	83 c4 10             	add    $0x10,%esp
f010334c:	85 c0                	test   %eax,%eax
f010334e:	78 33                	js     f0103383 <env_create+0x51>
	     panic("env create failed\n");
        load_icode(e,binary);
f0103350:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103353:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	if(elfhdr->e_magic != ELF_MAGIC) 
f0103356:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f010335c:	75 3c                	jne    f010339a <env_create+0x68>
	ph = (struct Proghdr *)((uint8_t *) elfhdr + elfhdr->e_phoff);
f010335e:	89 fb                	mov    %edi,%ebx
f0103360:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph + elfhdr->e_phnum;
f0103363:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f0103367:	c1 e6 05             	shl    $0x5,%esi
f010336a:	01 de                	add    %ebx,%esi
	lcr3(PADDR(e->env_pgdir));
f010336c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010336f:	8b 40 60             	mov    0x60(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103372:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103377:	76 38                	jbe    f01033b1 <env_create+0x7f>
	return (physaddr_t)kva - KERNBASE;
f0103379:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010337e:	0f 22 d8             	mov    %eax,%cr3
f0103381:	eb 5d                	jmp    f01033e0 <env_create+0xae>
	     panic("env create failed\n");
f0103383:	83 ec 04             	sub    $0x4,%esp
f0103386:	68 c2 77 10 f0       	push   $0xf01077c2
f010338b:	68 9c 01 00 00       	push   $0x19c
f0103390:	68 a3 77 10 f0       	push   $0xf01077a3
f0103395:	e8 a6 cc ff ff       	call   f0100040 <_panic>
		panic("elf header's magic is wrong\n");
f010339a:	83 ec 04             	sub    $0x4,%esp
f010339d:	68 d5 77 10 f0       	push   $0xf01077d5
f01033a2:	68 76 01 00 00       	push   $0x176
f01033a7:	68 a3 77 10 f0       	push   $0xf01077a3
f01033ac:	e8 8f cc ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033b1:	50                   	push   %eax
f01033b2:	68 a8 65 10 f0       	push   $0xf01065a8
f01033b7:	68 7c 01 00 00       	push   $0x17c
f01033bc:	68 a3 77 10 f0       	push   $0xf01077a3
f01033c1:	e8 7a cc ff ff       	call   f0100040 <_panic>
		   panic("filesz is larger than memsz, error\n");
f01033c6:	83 ec 04             	sub    $0x4,%esp
f01033c9:	68 00 78 10 f0       	push   $0xf0107800
f01033ce:	68 81 01 00 00       	push   $0x181
f01033d3:	68 a3 77 10 f0       	push   $0xf01077a3
f01033d8:	e8 63 cc ff ff       	call   f0100040 <_panic>
	for(; ph<eph; ph++){
f01033dd:	83 c3 20             	add    $0x20,%ebx
f01033e0:	39 de                	cmp    %ebx,%esi
f01033e2:	76 41                	jbe    f0103425 <env_create+0xf3>
	   if(ph->p_type != ELF_PROG_LOAD)
f01033e4:	83 3b 01             	cmpl   $0x1,(%ebx)
f01033e7:	75 f4                	jne    f01033dd <env_create+0xab>
	   if(ph->p_filesz > ph->p_memsz)
f01033e9:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01033ec:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f01033ef:	77 d5                	ja     f01033c6 <env_create+0x94>
	   region_alloc(e,(void *)ph->p_va, ph->p_memsz);
f01033f1:	8b 53 08             	mov    0x8(%ebx),%edx
f01033f4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01033f7:	e8 26 fc ff ff       	call   f0103022 <region_alloc>
	   memset((void *)ph->p_va,0,ph->p_memsz);  
f01033fc:	83 ec 04             	sub    $0x4,%esp
f01033ff:	ff 73 14             	pushl  0x14(%ebx)
f0103402:	6a 00                	push   $0x0
f0103404:	ff 73 08             	pushl  0x8(%ebx)
f0103407:	e8 f3 24 00 00       	call   f01058ff <memset>
	   memcpy((void *)ph->p_va,binary+ph->p_offset,ph->p_filesz);
f010340c:	83 c4 0c             	add    $0xc,%esp
f010340f:	ff 73 10             	pushl  0x10(%ebx)
f0103412:	89 f8                	mov    %edi,%eax
f0103414:	03 43 04             	add    0x4(%ebx),%eax
f0103417:	50                   	push   %eax
f0103418:	ff 73 08             	pushl  0x8(%ebx)
f010341b:	e8 94 25 00 00       	call   f01059b4 <memcpy>
f0103420:	83 c4 10             	add    $0x10,%esp
f0103423:	eb b8                	jmp    f01033dd <env_create+0xab>
	 e->env_tf.tf_eip = elfhdr->e_entry; //???
f0103425:	8b 47 18             	mov    0x18(%edi),%eax
f0103428:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010342b:	89 47 30             	mov    %eax,0x30(%edi)
        lcr3(PADDR(kern_pgdir));
f010342e:	a1 8c 5e 21 f0       	mov    0xf0215e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0103433:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103438:	76 37                	jbe    f0103471 <env_create+0x13f>
	return (physaddr_t)kva - KERNBASE;
f010343a:	05 00 00 00 10       	add    $0x10000000,%eax
f010343f:	0f 22 d8             	mov    %eax,%cr3
	region_alloc(e,(void *)(USTACKTOP-PGSIZE),PGSIZE);
f0103442:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103447:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f010344c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010344f:	e8 ce fb ff ff       	call   f0103022 <region_alloc>
	e->env_type = type;
f0103454:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103457:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010345a:	89 78 50             	mov    %edi,0x50(%eax)
        e->env_parent_id = 0;
f010345d:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
 // If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
        // LAB 5: Your code here.
	if(type == ENV_TYPE_FS){
f0103464:	83 ff 01             	cmp    $0x1,%edi
f0103467:	74 1d                	je     f0103486 <env_create+0x154>
	  e->env_tf.tf_eflags |= FL_IOPL_MASK;
	}

}
f0103469:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010346c:	5b                   	pop    %ebx
f010346d:	5e                   	pop    %esi
f010346e:	5f                   	pop    %edi
f010346f:	5d                   	pop    %ebp
f0103470:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103471:	50                   	push   %eax
f0103472:	68 a8 65 10 f0       	push   $0xf01065a8
f0103477:	68 8a 01 00 00       	push   $0x18a
f010347c:	68 a3 77 10 f0       	push   $0xf01077a3
f0103481:	e8 ba cb ff ff       	call   f0100040 <_panic>
	  e->env_tf.tf_eflags |= FL_IOPL_MASK;
f0103486:	81 48 38 00 30 00 00 	orl    $0x3000,0x38(%eax)
}
f010348d:	eb da                	jmp    f0103469 <env_create+0x137>

f010348f <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f010348f:	55                   	push   %ebp
f0103490:	89 e5                	mov    %esp,%ebp
f0103492:	57                   	push   %edi
f0103493:	56                   	push   %esi
f0103494:	53                   	push   %ebx
f0103495:	83 ec 1c             	sub    $0x1c,%esp
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103498:	e8 86 2a 00 00       	call   f0105f23 <cpunum>
f010349d:	6b c0 74             	imul   $0x74,%eax,%eax
f01034a0:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f01034a7:	8b 55 08             	mov    0x8(%ebp),%edx
f01034aa:	8b 7d 08             	mov    0x8(%ebp),%edi
f01034ad:	39 90 28 60 21 f0    	cmp    %edx,-0xfde9fd8(%eax)
f01034b3:	0f 85 b2 00 00 00    	jne    f010356b <env_free+0xdc>
		lcr3(PADDR(kern_pgdir));
f01034b9:	a1 8c 5e 21 f0       	mov    0xf0215e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01034be:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01034c3:	76 17                	jbe    f01034dc <env_free+0x4d>
	return (physaddr_t)kva - KERNBASE;
f01034c5:	05 00 00 00 10       	add    $0x10000000,%eax
f01034ca:	0f 22 d8             	mov    %eax,%cr3
f01034cd:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f01034d4:	8b 7d 08             	mov    0x8(%ebp),%edi
f01034d7:	e9 8f 00 00 00       	jmp    f010356b <env_free+0xdc>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01034dc:	50                   	push   %eax
f01034dd:	68 a8 65 10 f0       	push   $0xf01065a8
f01034e2:	68 b6 01 00 00       	push   $0x1b6
f01034e7:	68 a3 77 10 f0       	push   $0xf01077a3
f01034ec:	e8 4f cb ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01034f1:	50                   	push   %eax
f01034f2:	68 84 65 10 f0       	push   $0xf0106584
f01034f7:	68 c5 01 00 00       	push   $0x1c5
f01034fc:	68 a3 77 10 f0       	push   $0xf01077a3
f0103501:	e8 3a cb ff ff       	call   f0100040 <_panic>
f0103506:	83 c3 04             	add    $0x4,%ebx
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103509:	39 de                	cmp    %ebx,%esi
f010350b:	74 21                	je     f010352e <env_free+0x9f>
			if (pt[pteno] & PTE_P)
f010350d:	f6 03 01             	testb  $0x1,(%ebx)
f0103510:	74 f4                	je     f0103506 <env_free+0x77>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103512:	83 ec 08             	sub    $0x8,%esp
f0103515:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103518:	01 d8                	add    %ebx,%eax
f010351a:	c1 e0 0a             	shl    $0xa,%eax
f010351d:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103520:	50                   	push   %eax
f0103521:	ff 77 60             	pushl  0x60(%edi)
f0103524:	e8 11 dd ff ff       	call   f010123a <page_remove>
f0103529:	83 c4 10             	add    $0x10,%esp
f010352c:	eb d8                	jmp    f0103506 <env_free+0x77>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f010352e:	8b 47 60             	mov    0x60(%edi),%eax
f0103531:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103534:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f010353b:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010353e:	3b 05 88 5e 21 f0    	cmp    0xf0215e88,%eax
f0103544:	73 6a                	jae    f01035b0 <env_free+0x121>
		page_decref(pa2page(pa));
f0103546:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103549:	a1 90 5e 21 f0       	mov    0xf0215e90,%eax
f010354e:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103551:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0103554:	50                   	push   %eax
f0103555:	e8 b8 da ff ff       	call   f0101012 <page_decref>
f010355a:	83 c4 10             	add    $0x10,%esp
f010355d:	83 45 dc 04          	addl   $0x4,-0x24(%ebp)
f0103561:	8b 45 dc             	mov    -0x24(%ebp),%eax
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103564:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f0103569:	74 59                	je     f01035c4 <env_free+0x135>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f010356b:	8b 47 60             	mov    0x60(%edi),%eax
f010356e:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103571:	8b 04 10             	mov    (%eax,%edx,1),%eax
f0103574:	a8 01                	test   $0x1,%al
f0103576:	74 e5                	je     f010355d <env_free+0xce>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103578:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f010357d:	89 c2                	mov    %eax,%edx
f010357f:	c1 ea 0c             	shr    $0xc,%edx
f0103582:	89 55 d8             	mov    %edx,-0x28(%ebp)
f0103585:	39 15 88 5e 21 f0    	cmp    %edx,0xf0215e88
f010358b:	0f 86 60 ff ff ff    	jbe    f01034f1 <env_free+0x62>
	return (void *)(pa + KERNBASE);
f0103591:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103597:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010359a:	c1 e2 14             	shl    $0x14,%edx
f010359d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01035a0:	8d b0 00 10 00 f0    	lea    -0xffff000(%eax),%esi
f01035a6:	f7 d8                	neg    %eax
f01035a8:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01035ab:	e9 5d ff ff ff       	jmp    f010350d <env_free+0x7e>
		panic("pa2page called with invalid pa");
f01035b0:	83 ec 04             	sub    $0x4,%esp
f01035b3:	68 10 6c 10 f0       	push   $0xf0106c10
f01035b8:	6a 51                	push   $0x51
f01035ba:	68 55 74 10 f0       	push   $0xf0107455
f01035bf:	e8 7c ca ff ff       	call   f0100040 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f01035c4:	8b 45 08             	mov    0x8(%ebp),%eax
f01035c7:	8b 40 60             	mov    0x60(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f01035ca:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01035cf:	76 52                	jbe    f0103623 <env_free+0x194>
	e->env_pgdir = 0;
f01035d1:	8b 55 08             	mov    0x8(%ebp),%edx
f01035d4:	c7 42 60 00 00 00 00 	movl   $0x0,0x60(%edx)
	return (physaddr_t)kva - KERNBASE;
f01035db:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f01035e0:	c1 e8 0c             	shr    $0xc,%eax
f01035e3:	3b 05 88 5e 21 f0    	cmp    0xf0215e88,%eax
f01035e9:	73 4d                	jae    f0103638 <env_free+0x1a9>
	page_decref(pa2page(pa));
f01035eb:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f01035ee:	8b 15 90 5e 21 f0    	mov    0xf0215e90,%edx
f01035f4:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f01035f7:	50                   	push   %eax
f01035f8:	e8 15 da ff ff       	call   f0101012 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01035fd:	8b 45 08             	mov    0x8(%ebp),%eax
f0103600:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
	e->env_link = env_free_list;
f0103607:	a1 48 52 21 f0       	mov    0xf0215248,%eax
f010360c:	8b 55 08             	mov    0x8(%ebp),%edx
f010360f:	89 42 44             	mov    %eax,0x44(%edx)
	env_free_list = e;
f0103612:	89 15 48 52 21 f0    	mov    %edx,0xf0215248
}
f0103618:	83 c4 10             	add    $0x10,%esp
f010361b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010361e:	5b                   	pop    %ebx
f010361f:	5e                   	pop    %esi
f0103620:	5f                   	pop    %edi
f0103621:	5d                   	pop    %ebp
f0103622:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103623:	50                   	push   %eax
f0103624:	68 a8 65 10 f0       	push   $0xf01065a8
f0103629:	68 d3 01 00 00       	push   $0x1d3
f010362e:	68 a3 77 10 f0       	push   $0xf01077a3
f0103633:	e8 08 ca ff ff       	call   f0100040 <_panic>
		panic("pa2page called with invalid pa");
f0103638:	83 ec 04             	sub    $0x4,%esp
f010363b:	68 10 6c 10 f0       	push   $0xf0106c10
f0103640:	6a 51                	push   $0x51
f0103642:	68 55 74 10 f0       	push   $0xf0107455
f0103647:	e8 f4 c9 ff ff       	call   f0100040 <_panic>

f010364c <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f010364c:	55                   	push   %ebp
f010364d:	89 e5                	mov    %esp,%ebp
f010364f:	53                   	push   %ebx
f0103650:	83 ec 04             	sub    $0x4,%esp
f0103653:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103656:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f010365a:	74 21                	je     f010367d <env_destroy+0x31>
		e->env_status = ENV_DYING;
		return;
	}

	env_free(e);
f010365c:	83 ec 0c             	sub    $0xc,%esp
f010365f:	53                   	push   %ebx
f0103660:	e8 2a fe ff ff       	call   f010348f <env_free>

	if (curenv == e) {
f0103665:	e8 b9 28 00 00       	call   f0105f23 <cpunum>
f010366a:	6b c0 74             	imul   $0x74,%eax,%eax
f010366d:	83 c4 10             	add    $0x10,%esp
f0103670:	39 98 28 60 21 f0    	cmp    %ebx,-0xfde9fd8(%eax)
f0103676:	74 1e                	je     f0103696 <env_destroy+0x4a>
		curenv = NULL;
		sched_yield();
	}
}
f0103678:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010367b:	c9                   	leave  
f010367c:	c3                   	ret    
	if (e->env_status == ENV_RUNNING && curenv != e) {
f010367d:	e8 a1 28 00 00       	call   f0105f23 <cpunum>
f0103682:	6b c0 74             	imul   $0x74,%eax,%eax
f0103685:	39 98 28 60 21 f0    	cmp    %ebx,-0xfde9fd8(%eax)
f010368b:	74 cf                	je     f010365c <env_destroy+0x10>
		e->env_status = ENV_DYING;
f010368d:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103694:	eb e2                	jmp    f0103678 <env_destroy+0x2c>
		curenv = NULL;
f0103696:	e8 88 28 00 00       	call   f0105f23 <cpunum>
f010369b:	6b c0 74             	imul   $0x74,%eax,%eax
f010369e:	c7 80 28 60 21 f0 00 	movl   $0x0,-0xfde9fd8(%eax)
f01036a5:	00 00 00 
		sched_yield();
f01036a8:	e8 dd 0e 00 00       	call   f010458a <sched_yield>

f01036ad <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01036ad:	55                   	push   %ebp
f01036ae:	89 e5                	mov    %esp,%ebp
f01036b0:	53                   	push   %ebx
f01036b1:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f01036b4:	e8 6a 28 00 00       	call   f0105f23 <cpunum>
f01036b9:	6b c0 74             	imul   $0x74,%eax,%eax
f01036bc:	8b 98 28 60 21 f0    	mov    -0xfde9fd8(%eax),%ebx
f01036c2:	e8 5c 28 00 00       	call   f0105f23 <cpunum>
f01036c7:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f01036ca:	8b 65 08             	mov    0x8(%ebp),%esp
f01036cd:	61                   	popa   
f01036ce:	07                   	pop    %es
f01036cf:	1f                   	pop    %ds
f01036d0:	83 c4 08             	add    $0x8,%esp
f01036d3:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01036d4:	83 ec 04             	sub    $0x4,%esp
f01036d7:	68 f2 77 10 f0       	push   $0xf01077f2
f01036dc:	68 0a 02 00 00       	push   $0x20a
f01036e1:	68 a3 77 10 f0       	push   $0xf01077a3
f01036e6:	e8 55 c9 ff ff       	call   f0100040 <_panic>

f01036eb <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01036eb:	55                   	push   %ebp
f01036ec:	89 e5                	mov    %esp,%ebp
f01036ee:	83 ec 08             	sub    $0x8,%esp
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
        if(curenv && curenv->env_status == ENV_RUNNING){
f01036f1:	e8 2d 28 00 00       	call   f0105f23 <cpunum>
f01036f6:	6b c0 74             	imul   $0x74,%eax,%eax
f01036f9:	83 b8 28 60 21 f0 00 	cmpl   $0x0,-0xfde9fd8(%eax)
f0103700:	74 14                	je     f0103716 <env_run+0x2b>
f0103702:	e8 1c 28 00 00       	call   f0105f23 <cpunum>
f0103707:	6b c0 74             	imul   $0x74,%eax,%eax
f010370a:	8b 80 28 60 21 f0    	mov    -0xfde9fd8(%eax),%eax
f0103710:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103714:	74 65                	je     f010377b <env_run+0x90>
	   curenv->env_status = ENV_RUNNABLE;
	}

	curenv = e;
f0103716:	e8 08 28 00 00       	call   f0105f23 <cpunum>
f010371b:	6b c0 74             	imul   $0x74,%eax,%eax
f010371e:	8b 55 08             	mov    0x8(%ebp),%edx
f0103721:	89 90 28 60 21 f0    	mov    %edx,-0xfde9fd8(%eax)
	curenv->env_status = ENV_RUNNING;
f0103727:	e8 f7 27 00 00       	call   f0105f23 <cpunum>
f010372c:	6b c0 74             	imul   $0x74,%eax,%eax
f010372f:	8b 80 28 60 21 f0    	mov    -0xfde9fd8(%eax),%eax
f0103735:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f010373c:	e8 e2 27 00 00       	call   f0105f23 <cpunum>
f0103741:	6b c0 74             	imul   $0x74,%eax,%eax
f0103744:	8b 80 28 60 21 f0    	mov    -0xfde9fd8(%eax),%eax
f010374a:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3(PADDR(curenv->env_pgdir)); //why?
f010374e:	e8 d0 27 00 00       	call   f0105f23 <cpunum>
f0103753:	6b c0 74             	imul   $0x74,%eax,%eax
f0103756:	8b 80 28 60 21 f0    	mov    -0xfde9fd8(%eax),%eax
f010375c:	8b 40 60             	mov    0x60(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f010375f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103764:	77 2c                	ja     f0103792 <env_run+0xa7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103766:	50                   	push   %eax
f0103767:	68 a8 65 10 f0       	push   $0xf01065a8
f010376c:	68 2f 02 00 00       	push   $0x22f
f0103771:	68 a3 77 10 f0       	push   $0xf01077a3
f0103776:	e8 c5 c8 ff ff       	call   f0100040 <_panic>
	   curenv->env_status = ENV_RUNNABLE;
f010377b:	e8 a3 27 00 00       	call   f0105f23 <cpunum>
f0103780:	6b c0 74             	imul   $0x74,%eax,%eax
f0103783:	8b 80 28 60 21 f0    	mov    -0xfde9fd8(%eax),%eax
f0103789:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f0103790:	eb 84                	jmp    f0103716 <env_run+0x2b>
	return (physaddr_t)kva - KERNBASE;
f0103792:	05 00 00 00 10       	add    $0x10000000,%eax
f0103797:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f010379a:	83 ec 0c             	sub    $0xc,%esp
f010379d:	68 c0 23 12 f0       	push   $0xf01223c0
f01037a2:	e8 89 2a 00 00       	call   f0106230 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01037a7:	f3 90                	pause  
        
        unlock_kernel();

	env_pop_tf(&curenv->env_tf);//what meaning?
f01037a9:	e8 75 27 00 00       	call   f0105f23 <cpunum>
f01037ae:	83 c4 04             	add    $0x4,%esp
f01037b1:	6b c0 74             	imul   $0x74,%eax,%eax
f01037b4:	ff b0 28 60 21 f0    	pushl  -0xfde9fd8(%eax)
f01037ba:	e8 ee fe ff ff       	call   f01036ad <env_pop_tf>

f01037bf <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01037bf:	55                   	push   %ebp
f01037c0:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01037c2:	8b 45 08             	mov    0x8(%ebp),%eax
f01037c5:	ba 70 00 00 00       	mov    $0x70,%edx
f01037ca:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01037cb:	ba 71 00 00 00       	mov    $0x71,%edx
f01037d0:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01037d1:	0f b6 c0             	movzbl %al,%eax
}
f01037d4:	5d                   	pop    %ebp
f01037d5:	c3                   	ret    

f01037d6 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01037d6:	55                   	push   %ebp
f01037d7:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01037d9:	8b 45 08             	mov    0x8(%ebp),%eax
f01037dc:	ba 70 00 00 00       	mov    $0x70,%edx
f01037e1:	ee                   	out    %al,(%dx)
f01037e2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01037e5:	ba 71 00 00 00       	mov    $0x71,%edx
f01037ea:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01037eb:	5d                   	pop    %ebp
f01037ec:	c3                   	ret    

f01037ed <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f01037ed:	55                   	push   %ebp
f01037ee:	89 e5                	mov    %esp,%ebp
f01037f0:	56                   	push   %esi
f01037f1:	53                   	push   %ebx
f01037f2:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f01037f5:	66 a3 a8 23 12 f0    	mov    %ax,0xf01223a8
	if (!didinit)
f01037fb:	80 3d 4c 52 21 f0 00 	cmpb   $0x0,0xf021524c
f0103802:	75 07                	jne    f010380b <irq_setmask_8259A+0x1e>
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
}
f0103804:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103807:	5b                   	pop    %ebx
f0103808:	5e                   	pop    %esi
f0103809:	5d                   	pop    %ebp
f010380a:	c3                   	ret    
f010380b:	89 c6                	mov    %eax,%esi
f010380d:	ba 21 00 00 00       	mov    $0x21,%edx
f0103812:	ee                   	out    %al,(%dx)
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103813:	66 c1 e8 08          	shr    $0x8,%ax
f0103817:	ba a1 00 00 00       	mov    $0xa1,%edx
f010381c:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f010381d:	83 ec 0c             	sub    $0xc,%esp
f0103820:	68 24 78 10 f0       	push   $0xf0107824
f0103825:	e8 1e 01 00 00       	call   f0103948 <cprintf>
f010382a:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f010382d:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103832:	0f b7 f6             	movzwl %si,%esi
f0103835:	f7 d6                	not    %esi
f0103837:	eb 08                	jmp    f0103841 <irq_setmask_8259A+0x54>
	for (i = 0; i < 16; i++)
f0103839:	83 c3 01             	add    $0x1,%ebx
f010383c:	83 fb 10             	cmp    $0x10,%ebx
f010383f:	74 18                	je     f0103859 <irq_setmask_8259A+0x6c>
		if (~mask & (1<<i))
f0103841:	0f a3 de             	bt     %ebx,%esi
f0103844:	73 f3                	jae    f0103839 <irq_setmask_8259A+0x4c>
			cprintf(" %d", i);
f0103846:	83 ec 08             	sub    $0x8,%esp
f0103849:	53                   	push   %ebx
f010384a:	68 2a 7d 10 f0       	push   $0xf0107d2a
f010384f:	e8 f4 00 00 00       	call   f0103948 <cprintf>
f0103854:	83 c4 10             	add    $0x10,%esp
f0103857:	eb e0                	jmp    f0103839 <irq_setmask_8259A+0x4c>
	cprintf("\n");
f0103859:	83 ec 0c             	sub    $0xc,%esp
f010385c:	68 c9 68 10 f0       	push   $0xf01068c9
f0103861:	e8 e2 00 00 00       	call   f0103948 <cprintf>
f0103866:	83 c4 10             	add    $0x10,%esp
f0103869:	eb 99                	jmp    f0103804 <irq_setmask_8259A+0x17>

f010386b <pic_init>:
{
f010386b:	55                   	push   %ebp
f010386c:	89 e5                	mov    %esp,%ebp
f010386e:	57                   	push   %edi
f010386f:	56                   	push   %esi
f0103870:	53                   	push   %ebx
f0103871:	83 ec 0c             	sub    $0xc,%esp
	didinit = 1;
f0103874:	c6 05 4c 52 21 f0 01 	movb   $0x1,0xf021524c
f010387b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103880:	bb 21 00 00 00       	mov    $0x21,%ebx
f0103885:	89 da                	mov    %ebx,%edx
f0103887:	ee                   	out    %al,(%dx)
f0103888:	b9 a1 00 00 00       	mov    $0xa1,%ecx
f010388d:	89 ca                	mov    %ecx,%edx
f010388f:	ee                   	out    %al,(%dx)
f0103890:	bf 11 00 00 00       	mov    $0x11,%edi
f0103895:	be 20 00 00 00       	mov    $0x20,%esi
f010389a:	89 f8                	mov    %edi,%eax
f010389c:	89 f2                	mov    %esi,%edx
f010389e:	ee                   	out    %al,(%dx)
f010389f:	b8 20 00 00 00       	mov    $0x20,%eax
f01038a4:	89 da                	mov    %ebx,%edx
f01038a6:	ee                   	out    %al,(%dx)
f01038a7:	b8 04 00 00 00       	mov    $0x4,%eax
f01038ac:	ee                   	out    %al,(%dx)
f01038ad:	b8 03 00 00 00       	mov    $0x3,%eax
f01038b2:	ee                   	out    %al,(%dx)
f01038b3:	bb a0 00 00 00       	mov    $0xa0,%ebx
f01038b8:	89 f8                	mov    %edi,%eax
f01038ba:	89 da                	mov    %ebx,%edx
f01038bc:	ee                   	out    %al,(%dx)
f01038bd:	b8 28 00 00 00       	mov    $0x28,%eax
f01038c2:	89 ca                	mov    %ecx,%edx
f01038c4:	ee                   	out    %al,(%dx)
f01038c5:	b8 02 00 00 00       	mov    $0x2,%eax
f01038ca:	ee                   	out    %al,(%dx)
f01038cb:	b8 01 00 00 00       	mov    $0x1,%eax
f01038d0:	ee                   	out    %al,(%dx)
f01038d1:	bf 68 00 00 00       	mov    $0x68,%edi
f01038d6:	89 f8                	mov    %edi,%eax
f01038d8:	89 f2                	mov    %esi,%edx
f01038da:	ee                   	out    %al,(%dx)
f01038db:	b9 0a 00 00 00       	mov    $0xa,%ecx
f01038e0:	89 c8                	mov    %ecx,%eax
f01038e2:	ee                   	out    %al,(%dx)
f01038e3:	89 f8                	mov    %edi,%eax
f01038e5:	89 da                	mov    %ebx,%edx
f01038e7:	ee                   	out    %al,(%dx)
f01038e8:	89 c8                	mov    %ecx,%eax
f01038ea:	ee                   	out    %al,(%dx)
	if (irq_mask_8259A != 0xFFFF)
f01038eb:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f01038f2:	66 83 f8 ff          	cmp    $0xffff,%ax
f01038f6:	74 0f                	je     f0103907 <pic_init+0x9c>
		irq_setmask_8259A(irq_mask_8259A);
f01038f8:	83 ec 0c             	sub    $0xc,%esp
f01038fb:	0f b7 c0             	movzwl %ax,%eax
f01038fe:	50                   	push   %eax
f01038ff:	e8 e9 fe ff ff       	call   f01037ed <irq_setmask_8259A>
f0103904:	83 c4 10             	add    $0x10,%esp
}
f0103907:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010390a:	5b                   	pop    %ebx
f010390b:	5e                   	pop    %esi
f010390c:	5f                   	pop    %edi
f010390d:	5d                   	pop    %ebp
f010390e:	c3                   	ret    

f010390f <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f010390f:	55                   	push   %ebp
f0103910:	89 e5                	mov    %esp,%ebp
f0103912:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0103915:	ff 75 08             	pushl  0x8(%ebp)
f0103918:	e8 80 ce ff ff       	call   f010079d <cputchar>
	*cnt++;
}
f010391d:	83 c4 10             	add    $0x10,%esp
f0103920:	c9                   	leave  
f0103921:	c3                   	ret    

f0103922 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103922:	55                   	push   %ebp
f0103923:	89 e5                	mov    %esp,%ebp
f0103925:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103928:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f010392f:	ff 75 0c             	pushl  0xc(%ebp)
f0103932:	ff 75 08             	pushl  0x8(%ebp)
f0103935:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103938:	50                   	push   %eax
f0103939:	68 0f 39 10 f0       	push   $0xf010390f
f010393e:	e8 6b 18 00 00       	call   f01051ae <vprintfmt>
	return cnt;
}
f0103943:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103946:	c9                   	leave  
f0103947:	c3                   	ret    

f0103948 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103948:	55                   	push   %ebp
f0103949:	89 e5                	mov    %esp,%ebp
f010394b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f010394e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103951:	50                   	push   %eax
f0103952:	ff 75 08             	pushl  0x8(%ebp)
f0103955:	e8 c8 ff ff ff       	call   f0103922 <vcprintf>
	va_end(ap);

	return cnt;
}
f010395a:	c9                   	leave  
f010395b:	c3                   	ret    

f010395c <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f010395c:	55                   	push   %ebp
f010395d:	89 e5                	mov    %esp,%ebp
f010395f:	57                   	push   %edi
f0103960:	56                   	push   %esi
f0103961:	53                   	push   %ebx
f0103962:	83 ec 1c             	sub    $0x1c,%esp
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	int i=cpunum();
f0103965:	e8 b9 25 00 00       	call   f0105f23 <cpunum>
f010396a:	89 c6                	mov    %eax,%esi
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP-i*(KSTKSIZE+KSTKGAP);
f010396c:	e8 b2 25 00 00       	call   f0105f23 <cpunum>
f0103971:	6b c0 74             	imul   $0x74,%eax,%eax
f0103974:	89 f1                	mov    %esi,%ecx
f0103976:	c1 e1 10             	shl    $0x10,%ecx
f0103979:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f010397e:	29 ca                	sub    %ecx,%edx
f0103980:	89 90 30 60 21 f0    	mov    %edx,-0xfde9fd0(%eax)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103986:	e8 98 25 00 00       	call   f0105f23 <cpunum>
f010398b:	6b c0 74             	imul   $0x74,%eax,%eax
f010398e:	66 c7 80 34 60 21 f0 	movw   $0x10,-0xfde9fcc(%eax)
f0103995:	10 00 
	thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);
f0103997:	e8 87 25 00 00       	call   f0105f23 <cpunum>
f010399c:	6b c0 74             	imul   $0x74,%eax,%eax
f010399f:	66 c7 80 92 60 21 f0 	movw   $0x68,-0xfde9f6e(%eax)
f01039a6:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3)+i] = SEG16(STS_T32A, (uint32_t) (&thiscpu->cpu_ts),
f01039a8:	8d 5e 05             	lea    0x5(%esi),%ebx
f01039ab:	e8 73 25 00 00       	call   f0105f23 <cpunum>
f01039b0:	89 c7                	mov    %eax,%edi
f01039b2:	e8 6c 25 00 00       	call   f0105f23 <cpunum>
f01039b7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01039ba:	e8 64 25 00 00       	call   f0105f23 <cpunum>
f01039bf:	66 c7 04 dd 40 23 12 	movw   $0x67,-0xfeddcc0(,%ebx,8)
f01039c6:	f0 67 00 
f01039c9:	6b ff 74             	imul   $0x74,%edi,%edi
f01039cc:	81 c7 2c 60 21 f0    	add    $0xf021602c,%edi
f01039d2:	66 89 3c dd 42 23 12 	mov    %di,-0xfeddcbe(,%ebx,8)
f01039d9:	f0 
f01039da:	6b 55 e4 74          	imul   $0x74,-0x1c(%ebp),%edx
f01039de:	81 c2 2c 60 21 f0    	add    $0xf021602c,%edx
f01039e4:	c1 ea 10             	shr    $0x10,%edx
f01039e7:	88 14 dd 44 23 12 f0 	mov    %dl,-0xfeddcbc(,%ebx,8)
f01039ee:	c6 04 dd 46 23 12 f0 	movb   $0x40,-0xfeddcba(,%ebx,8)
f01039f5:	40 
f01039f6:	6b c0 74             	imul   $0x74,%eax,%eax
f01039f9:	05 2c 60 21 f0       	add    $0xf021602c,%eax
f01039fe:	c1 e8 18             	shr    $0x18,%eax
f0103a01:	88 04 dd 47 23 12 f0 	mov    %al,-0xfeddcb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3)+i].sd_s = 0;
f0103a08:	c6 04 dd 45 23 12 f0 	movb   $0x89,-0xfeddcbb(,%ebx,8)
f0103a0f:	89 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0+(i<<3));
f0103a10:	8d 34 f5 28 00 00 00 	lea    0x28(,%esi,8),%esi
	asm volatile("ltr %0" : : "r" (sel));
f0103a17:	0f 00 de             	ltr    %si
	asm volatile("lidt (%0)" : : "r" (p));
f0103a1a:	b8 ac 23 12 f0       	mov    $0xf01223ac,%eax
f0103a1f:	0f 01 18             	lidtl  (%eax)
	ts.ts_iomb = sizeof(struct Taskstate);
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A,(uint32_t)(&ts),sizeof(struct Taskstate)-1,0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
	ltr(GD_TSS0);
        lidt(&idt_pd);*/
}
f0103a22:	83 c4 1c             	add    $0x1c,%esp
f0103a25:	5b                   	pop    %ebx
f0103a26:	5e                   	pop    %esi
f0103a27:	5f                   	pop    %edi
f0103a28:	5d                   	pop    %ebp
f0103a29:	c3                   	ret    

f0103a2a <trap_init>:
{
f0103a2a:	55                   	push   %ebp
f0103a2b:	89 e5                	mov    %esp,%ebp
f0103a2d:	83 ec 08             	sub    $0x8,%esp
    SETGATE(idt[T_DIVIDE], 0, GD_KT, divide_handler, 0);
f0103a30:	b8 1a 44 10 f0       	mov    $0xf010441a,%eax
f0103a35:	66 a3 60 52 21 f0    	mov    %ax,0xf0215260
f0103a3b:	66 c7 05 62 52 21 f0 	movw   $0x8,0xf0215262
f0103a42:	08 00 
f0103a44:	c6 05 64 52 21 f0 00 	movb   $0x0,0xf0215264
f0103a4b:	c6 05 65 52 21 f0 8e 	movb   $0x8e,0xf0215265
f0103a52:	c1 e8 10             	shr    $0x10,%eax
f0103a55:	66 a3 66 52 21 f0    	mov    %ax,0xf0215266
    SETGATE(idt[T_DEBUG], 0, GD_KT, debug_handler, 0);
f0103a5b:	b8 24 44 10 f0       	mov    $0xf0104424,%eax
f0103a60:	66 a3 68 52 21 f0    	mov    %ax,0xf0215268
f0103a66:	66 c7 05 6a 52 21 f0 	movw   $0x8,0xf021526a
f0103a6d:	08 00 
f0103a6f:	c6 05 6c 52 21 f0 00 	movb   $0x0,0xf021526c
f0103a76:	c6 05 6d 52 21 f0 8e 	movb   $0x8e,0xf021526d
f0103a7d:	c1 e8 10             	shr    $0x10,%eax
f0103a80:	66 a3 6e 52 21 f0    	mov    %ax,0xf021526e
    SETGATE(idt[T_NMI], 0, GD_KT, nmi_handler, 0);
f0103a86:	b8 2a 44 10 f0       	mov    $0xf010442a,%eax
f0103a8b:	66 a3 70 52 21 f0    	mov    %ax,0xf0215270
f0103a91:	66 c7 05 72 52 21 f0 	movw   $0x8,0xf0215272
f0103a98:	08 00 
f0103a9a:	c6 05 74 52 21 f0 00 	movb   $0x0,0xf0215274
f0103aa1:	c6 05 75 52 21 f0 8e 	movb   $0x8e,0xf0215275
f0103aa8:	c1 e8 10             	shr    $0x10,%eax
f0103aab:	66 a3 76 52 21 f0    	mov    %ax,0xf0215276
    SETGATE(idt[T_BRKPT], 0, GD_KT, brkpt_handler, 3);
f0103ab1:	b8 30 44 10 f0       	mov    $0xf0104430,%eax
f0103ab6:	66 a3 78 52 21 f0    	mov    %ax,0xf0215278
f0103abc:	66 c7 05 7a 52 21 f0 	movw   $0x8,0xf021527a
f0103ac3:	08 00 
f0103ac5:	c6 05 7c 52 21 f0 00 	movb   $0x0,0xf021527c
f0103acc:	c6 05 7d 52 21 f0 ee 	movb   $0xee,0xf021527d
f0103ad3:	c1 e8 10             	shr    $0x10,%eax
f0103ad6:	66 a3 7e 52 21 f0    	mov    %ax,0xf021527e
    SETGATE(idt[T_OFLOW], 0, GD_KT, oflow_handler, 0);
f0103adc:	b8 36 44 10 f0       	mov    $0xf0104436,%eax
f0103ae1:	66 a3 80 52 21 f0    	mov    %ax,0xf0215280
f0103ae7:	66 c7 05 82 52 21 f0 	movw   $0x8,0xf0215282
f0103aee:	08 00 
f0103af0:	c6 05 84 52 21 f0 00 	movb   $0x0,0xf0215284
f0103af7:	c6 05 85 52 21 f0 8e 	movb   $0x8e,0xf0215285
f0103afe:	c1 e8 10             	shr    $0x10,%eax
f0103b01:	66 a3 86 52 21 f0    	mov    %ax,0xf0215286
    SETGATE(idt[T_BOUND], 0, GD_KT, bound_handler, 0);
f0103b07:	b8 3c 44 10 f0       	mov    $0xf010443c,%eax
f0103b0c:	66 a3 88 52 21 f0    	mov    %ax,0xf0215288
f0103b12:	66 c7 05 8a 52 21 f0 	movw   $0x8,0xf021528a
f0103b19:	08 00 
f0103b1b:	c6 05 8c 52 21 f0 00 	movb   $0x0,0xf021528c
f0103b22:	c6 05 8d 52 21 f0 8e 	movb   $0x8e,0xf021528d
f0103b29:	c1 e8 10             	shr    $0x10,%eax
f0103b2c:	66 a3 8e 52 21 f0    	mov    %ax,0xf021528e
    SETGATE(idt[T_DEVICE], 0, GD_KT, device_handler, 0);
f0103b32:	b8 48 44 10 f0       	mov    $0xf0104448,%eax
f0103b37:	66 a3 98 52 21 f0    	mov    %ax,0xf0215298
f0103b3d:	66 c7 05 9a 52 21 f0 	movw   $0x8,0xf021529a
f0103b44:	08 00 
f0103b46:	c6 05 9c 52 21 f0 00 	movb   $0x0,0xf021529c
f0103b4d:	c6 05 9d 52 21 f0 8e 	movb   $0x8e,0xf021529d
f0103b54:	c1 e8 10             	shr    $0x10,%eax
f0103b57:	66 a3 9e 52 21 f0    	mov    %ax,0xf021529e
    SETGATE(idt[T_ILLOP], 0, GD_KT, illop_handler, 0);
f0103b5d:	b8 42 44 10 f0       	mov    $0xf0104442,%eax
f0103b62:	66 a3 90 52 21 f0    	mov    %ax,0xf0215290
f0103b68:	66 c7 05 92 52 21 f0 	movw   $0x8,0xf0215292
f0103b6f:	08 00 
f0103b71:	c6 05 94 52 21 f0 00 	movb   $0x0,0xf0215294
f0103b78:	c6 05 95 52 21 f0 8e 	movb   $0x8e,0xf0215295
f0103b7f:	c1 e8 10             	shr    $0x10,%eax
f0103b82:	66 a3 96 52 21 f0    	mov    %ax,0xf0215296
    SETGATE(idt[T_DBLFLT], 0, GD_KT, dblflt_handler, 0);
f0103b88:	b8 4e 44 10 f0       	mov    $0xf010444e,%eax
f0103b8d:	66 a3 a0 52 21 f0    	mov    %ax,0xf02152a0
f0103b93:	66 c7 05 a2 52 21 f0 	movw   $0x8,0xf02152a2
f0103b9a:	08 00 
f0103b9c:	c6 05 a4 52 21 f0 00 	movb   $0x0,0xf02152a4
f0103ba3:	c6 05 a5 52 21 f0 8e 	movb   $0x8e,0xf02152a5
f0103baa:	c1 e8 10             	shr    $0x10,%eax
f0103bad:	66 a3 a6 52 21 f0    	mov    %ax,0xf02152a6
    SETGATE(idt[T_TSS], 0, GD_KT, tss_handler, 0);
f0103bb3:	b8 52 44 10 f0       	mov    $0xf0104452,%eax
f0103bb8:	66 a3 b0 52 21 f0    	mov    %ax,0xf02152b0
f0103bbe:	66 c7 05 b2 52 21 f0 	movw   $0x8,0xf02152b2
f0103bc5:	08 00 
f0103bc7:	c6 05 b4 52 21 f0 00 	movb   $0x0,0xf02152b4
f0103bce:	c6 05 b5 52 21 f0 8e 	movb   $0x8e,0xf02152b5
f0103bd5:	c1 e8 10             	shr    $0x10,%eax
f0103bd8:	66 a3 b6 52 21 f0    	mov    %ax,0xf02152b6
    SETGATE(idt[T_SEGNP], 0, GD_KT, segnp_handler, 0);
f0103bde:	b8 56 44 10 f0       	mov    $0xf0104456,%eax
f0103be3:	66 a3 b8 52 21 f0    	mov    %ax,0xf02152b8
f0103be9:	66 c7 05 ba 52 21 f0 	movw   $0x8,0xf02152ba
f0103bf0:	08 00 
f0103bf2:	c6 05 bc 52 21 f0 00 	movb   $0x0,0xf02152bc
f0103bf9:	c6 05 bd 52 21 f0 8e 	movb   $0x8e,0xf02152bd
f0103c00:	c1 e8 10             	shr    $0x10,%eax
f0103c03:	66 a3 be 52 21 f0    	mov    %ax,0xf02152be
    SETGATE(idt[T_STACK], 0, GD_KT, stack_handler, 0);
f0103c09:	b8 5a 44 10 f0       	mov    $0xf010445a,%eax
f0103c0e:	66 a3 c0 52 21 f0    	mov    %ax,0xf02152c0
f0103c14:	66 c7 05 c2 52 21 f0 	movw   $0x8,0xf02152c2
f0103c1b:	08 00 
f0103c1d:	c6 05 c4 52 21 f0 00 	movb   $0x0,0xf02152c4
f0103c24:	c6 05 c5 52 21 f0 8e 	movb   $0x8e,0xf02152c5
f0103c2b:	c1 e8 10             	shr    $0x10,%eax
f0103c2e:	66 a3 c6 52 21 f0    	mov    %ax,0xf02152c6
    SETGATE(idt[T_GPFLT], 0, GD_KT, gpflt_handler, 0);
f0103c34:	b8 5e 44 10 f0       	mov    $0xf010445e,%eax
f0103c39:	66 a3 c8 52 21 f0    	mov    %ax,0xf02152c8
f0103c3f:	66 c7 05 ca 52 21 f0 	movw   $0x8,0xf02152ca
f0103c46:	08 00 
f0103c48:	c6 05 cc 52 21 f0 00 	movb   $0x0,0xf02152cc
f0103c4f:	c6 05 cd 52 21 f0 8e 	movb   $0x8e,0xf02152cd
f0103c56:	c1 e8 10             	shr    $0x10,%eax
f0103c59:	66 a3 ce 52 21 f0    	mov    %ax,0xf02152ce
    SETGATE(idt[T_PGFLT], 0, GD_KT, pgflt_handler, 0);
f0103c5f:	b8 62 44 10 f0       	mov    $0xf0104462,%eax
f0103c64:	66 a3 d0 52 21 f0    	mov    %ax,0xf02152d0
f0103c6a:	66 c7 05 d2 52 21 f0 	movw   $0x8,0xf02152d2
f0103c71:	08 00 
f0103c73:	c6 05 d4 52 21 f0 00 	movb   $0x0,0xf02152d4
f0103c7a:	c6 05 d5 52 21 f0 8e 	movb   $0x8e,0xf02152d5
f0103c81:	c1 e8 10             	shr    $0x10,%eax
f0103c84:	66 a3 d6 52 21 f0    	mov    %ax,0xf02152d6
    SETGATE(idt[T_FPERR], 0, GD_KT, fperr_handler, 0);
f0103c8a:	b8 66 44 10 f0       	mov    $0xf0104466,%eax
f0103c8f:	66 a3 e0 52 21 f0    	mov    %ax,0xf02152e0
f0103c95:	66 c7 05 e2 52 21 f0 	movw   $0x8,0xf02152e2
f0103c9c:	08 00 
f0103c9e:	c6 05 e4 52 21 f0 00 	movb   $0x0,0xf02152e4
f0103ca5:	c6 05 e5 52 21 f0 8e 	movb   $0x8e,0xf02152e5
f0103cac:	c1 e8 10             	shr    $0x10,%eax
f0103caf:	66 a3 e6 52 21 f0    	mov    %ax,0xf02152e6
    SETGATE(idt[T_ALIGN], 0, GD_KT, align_handler, 0);
f0103cb5:	b8 6c 44 10 f0       	mov    $0xf010446c,%eax
f0103cba:	66 a3 e8 52 21 f0    	mov    %ax,0xf02152e8
f0103cc0:	66 c7 05 ea 52 21 f0 	movw   $0x8,0xf02152ea
f0103cc7:	08 00 
f0103cc9:	c6 05 ec 52 21 f0 00 	movb   $0x0,0xf02152ec
f0103cd0:	c6 05 ed 52 21 f0 8e 	movb   $0x8e,0xf02152ed
f0103cd7:	c1 e8 10             	shr    $0x10,%eax
f0103cda:	66 a3 ee 52 21 f0    	mov    %ax,0xf02152ee
    SETGATE(idt[T_MCHK], 0, GD_KT, mchk_handler, 0);
f0103ce0:	b8 70 44 10 f0       	mov    $0xf0104470,%eax
f0103ce5:	66 a3 f0 52 21 f0    	mov    %ax,0xf02152f0
f0103ceb:	66 c7 05 f2 52 21 f0 	movw   $0x8,0xf02152f2
f0103cf2:	08 00 
f0103cf4:	c6 05 f4 52 21 f0 00 	movb   $0x0,0xf02152f4
f0103cfb:	c6 05 f5 52 21 f0 8e 	movb   $0x8e,0xf02152f5
f0103d02:	c1 e8 10             	shr    $0x10,%eax
f0103d05:	66 a3 f6 52 21 f0    	mov    %ax,0xf02152f6
    SETGATE(idt[T_SIMDERR], 0, GD_KT, simderr_handler, 0);
f0103d0b:	b8 76 44 10 f0       	mov    $0xf0104476,%eax
f0103d10:	66 a3 f8 52 21 f0    	mov    %ax,0xf02152f8
f0103d16:	66 c7 05 fa 52 21 f0 	movw   $0x8,0xf02152fa
f0103d1d:	08 00 
f0103d1f:	c6 05 fc 52 21 f0 00 	movb   $0x0,0xf02152fc
f0103d26:	c6 05 fd 52 21 f0 8e 	movb   $0x8e,0xf02152fd
f0103d2d:	c1 e8 10             	shr    $0x10,%eax
f0103d30:	66 a3 fe 52 21 f0    	mov    %ax,0xf02152fe
    SETGATE(idt[T_SYSCALL], 0, GD_KT, syscall_handler, 3);
f0103d36:	b8 7c 44 10 f0       	mov    $0xf010447c,%eax
f0103d3b:	66 a3 e0 53 21 f0    	mov    %ax,0xf02153e0
f0103d41:	66 c7 05 e2 53 21 f0 	movw   $0x8,0xf02153e2
f0103d48:	08 00 
f0103d4a:	c6 05 e4 53 21 f0 00 	movb   $0x0,0xf02153e4
f0103d51:	c6 05 e5 53 21 f0 ee 	movb   $0xee,0xf02153e5
f0103d58:	c1 e8 10             	shr    $0x10,%eax
f0103d5b:	66 a3 e6 53 21 f0    	mov    %ax,0xf02153e6
    SETGATE(idt[IRQ_OFFSET+IRQ_TIMER],0,GD_KT,timer_handler,3);
f0103d61:	b8 82 44 10 f0       	mov    $0xf0104482,%eax
f0103d66:	66 a3 60 53 21 f0    	mov    %ax,0xf0215360
f0103d6c:	66 c7 05 62 53 21 f0 	movw   $0x8,0xf0215362
f0103d73:	08 00 
f0103d75:	c6 05 64 53 21 f0 00 	movb   $0x0,0xf0215364
f0103d7c:	c6 05 65 53 21 f0 ee 	movb   $0xee,0xf0215365
f0103d83:	c1 e8 10             	shr    $0x10,%eax
f0103d86:	66 a3 66 53 21 f0    	mov    %ax,0xf0215366
    SETGATE(idt[IRQ_OFFSET+IRQ_KBD],0,GD_KT,kbd_handler,3);
f0103d8c:	b8 88 44 10 f0       	mov    $0xf0104488,%eax
f0103d91:	66 a3 68 53 21 f0    	mov    %ax,0xf0215368
f0103d97:	66 c7 05 6a 53 21 f0 	movw   $0x8,0xf021536a
f0103d9e:	08 00 
f0103da0:	c6 05 6c 53 21 f0 00 	movb   $0x0,0xf021536c
f0103da7:	c6 05 6d 53 21 f0 ee 	movb   $0xee,0xf021536d
f0103dae:	c1 e8 10             	shr    $0x10,%eax
f0103db1:	66 a3 6e 53 21 f0    	mov    %ax,0xf021536e
    SETGATE(idt[IRQ_OFFSET+IRQ_SERIAL],0,GD_KT,serial_handler,3);
f0103db7:	b8 8e 44 10 f0       	mov    $0xf010448e,%eax
f0103dbc:	66 a3 80 53 21 f0    	mov    %ax,0xf0215380
f0103dc2:	66 c7 05 82 53 21 f0 	movw   $0x8,0xf0215382
f0103dc9:	08 00 
f0103dcb:	c6 05 84 53 21 f0 00 	movb   $0x0,0xf0215384
f0103dd2:	c6 05 85 53 21 f0 ee 	movb   $0xee,0xf0215385
f0103dd9:	c1 e8 10             	shr    $0x10,%eax
f0103ddc:	66 a3 86 53 21 f0    	mov    %ax,0xf0215386
    SETGATE(idt[IRQ_OFFSET+IRQ_SPURIOUS],0,GD_KT,spurious_handler,3);
f0103de2:	b8 94 44 10 f0       	mov    $0xf0104494,%eax
f0103de7:	66 a3 98 53 21 f0    	mov    %ax,0xf0215398
f0103ded:	66 c7 05 9a 53 21 f0 	movw   $0x8,0xf021539a
f0103df4:	08 00 
f0103df6:	c6 05 9c 53 21 f0 00 	movb   $0x0,0xf021539c
f0103dfd:	c6 05 9d 53 21 f0 ee 	movb   $0xee,0xf021539d
f0103e04:	c1 e8 10             	shr    $0x10,%eax
f0103e07:	66 a3 9e 53 21 f0    	mov    %ax,0xf021539e
    SETGATE(idt[IRQ_OFFSET+IRQ_IDE],0,GD_KT,ide_handler,3);
f0103e0d:	b8 9a 44 10 f0       	mov    $0xf010449a,%eax
f0103e12:	66 a3 d0 53 21 f0    	mov    %ax,0xf02153d0
f0103e18:	66 c7 05 d2 53 21 f0 	movw   $0x8,0xf02153d2
f0103e1f:	08 00 
f0103e21:	c6 05 d4 53 21 f0 00 	movb   $0x0,0xf02153d4
f0103e28:	c6 05 d5 53 21 f0 ee 	movb   $0xee,0xf02153d5
f0103e2f:	c1 e8 10             	shr    $0x10,%eax
f0103e32:	66 a3 d6 53 21 f0    	mov    %ax,0xf02153d6
    SETGATE(idt[IRQ_OFFSET+IRQ_ERROR],0,GD_KT,error_handler,3);
f0103e38:	b8 a0 44 10 f0       	mov    $0xf01044a0,%eax
f0103e3d:	66 a3 f8 53 21 f0    	mov    %ax,0xf02153f8
f0103e43:	66 c7 05 fa 53 21 f0 	movw   $0x8,0xf02153fa
f0103e4a:	08 00 
f0103e4c:	c6 05 fc 53 21 f0 00 	movb   $0x0,0xf02153fc
f0103e53:	c6 05 fd 53 21 f0 ee 	movb   $0xee,0xf02153fd
f0103e5a:	c1 e8 10             	shr    $0x10,%eax
f0103e5d:	66 a3 fe 53 21 f0    	mov    %ax,0xf02153fe
	trap_init_percpu();
f0103e63:	e8 f4 fa ff ff       	call   f010395c <trap_init_percpu>
}
f0103e68:	c9                   	leave  
f0103e69:	c3                   	ret    

f0103e6a <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103e6a:	55                   	push   %ebp
f0103e6b:	89 e5                	mov    %esp,%ebp
f0103e6d:	53                   	push   %ebx
f0103e6e:	83 ec 0c             	sub    $0xc,%esp
f0103e71:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103e74:	ff 33                	pushl  (%ebx)
f0103e76:	68 38 78 10 f0       	push   $0xf0107838
f0103e7b:	e8 c8 fa ff ff       	call   f0103948 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103e80:	83 c4 08             	add    $0x8,%esp
f0103e83:	ff 73 04             	pushl  0x4(%ebx)
f0103e86:	68 47 78 10 f0       	push   $0xf0107847
f0103e8b:	e8 b8 fa ff ff       	call   f0103948 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103e90:	83 c4 08             	add    $0x8,%esp
f0103e93:	ff 73 08             	pushl  0x8(%ebx)
f0103e96:	68 56 78 10 f0       	push   $0xf0107856
f0103e9b:	e8 a8 fa ff ff       	call   f0103948 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103ea0:	83 c4 08             	add    $0x8,%esp
f0103ea3:	ff 73 0c             	pushl  0xc(%ebx)
f0103ea6:	68 65 78 10 f0       	push   $0xf0107865
f0103eab:	e8 98 fa ff ff       	call   f0103948 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103eb0:	83 c4 08             	add    $0x8,%esp
f0103eb3:	ff 73 10             	pushl  0x10(%ebx)
f0103eb6:	68 74 78 10 f0       	push   $0xf0107874
f0103ebb:	e8 88 fa ff ff       	call   f0103948 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103ec0:	83 c4 08             	add    $0x8,%esp
f0103ec3:	ff 73 14             	pushl  0x14(%ebx)
f0103ec6:	68 83 78 10 f0       	push   $0xf0107883
f0103ecb:	e8 78 fa ff ff       	call   f0103948 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103ed0:	83 c4 08             	add    $0x8,%esp
f0103ed3:	ff 73 18             	pushl  0x18(%ebx)
f0103ed6:	68 92 78 10 f0       	push   $0xf0107892
f0103edb:	e8 68 fa ff ff       	call   f0103948 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103ee0:	83 c4 08             	add    $0x8,%esp
f0103ee3:	ff 73 1c             	pushl  0x1c(%ebx)
f0103ee6:	68 a1 78 10 f0       	push   $0xf01078a1
f0103eeb:	e8 58 fa ff ff       	call   f0103948 <cprintf>
}
f0103ef0:	83 c4 10             	add    $0x10,%esp
f0103ef3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103ef6:	c9                   	leave  
f0103ef7:	c3                   	ret    

f0103ef8 <print_trapframe>:
{
f0103ef8:	55                   	push   %ebp
f0103ef9:	89 e5                	mov    %esp,%ebp
f0103efb:	56                   	push   %esi
f0103efc:	53                   	push   %ebx
f0103efd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103f00:	e8 1e 20 00 00       	call   f0105f23 <cpunum>
f0103f05:	83 ec 04             	sub    $0x4,%esp
f0103f08:	50                   	push   %eax
f0103f09:	53                   	push   %ebx
f0103f0a:	68 05 79 10 f0       	push   $0xf0107905
f0103f0f:	e8 34 fa ff ff       	call   f0103948 <cprintf>
	print_regs(&tf->tf_regs);
f0103f14:	89 1c 24             	mov    %ebx,(%esp)
f0103f17:	e8 4e ff ff ff       	call   f0103e6a <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103f1c:	83 c4 08             	add    $0x8,%esp
f0103f1f:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103f23:	50                   	push   %eax
f0103f24:	68 23 79 10 f0       	push   $0xf0107923
f0103f29:	e8 1a fa ff ff       	call   f0103948 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103f2e:	83 c4 08             	add    $0x8,%esp
f0103f31:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103f35:	50                   	push   %eax
f0103f36:	68 36 79 10 f0       	push   $0xf0107936
f0103f3b:	e8 08 fa ff ff       	call   f0103948 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103f40:	8b 43 28             	mov    0x28(%ebx),%eax
	if (trapno < ARRAY_SIZE(excnames))
f0103f43:	83 c4 10             	add    $0x10,%esp
f0103f46:	83 f8 13             	cmp    $0x13,%eax
f0103f49:	76 1f                	jbe    f0103f6a <print_trapframe+0x72>
		return "System call";
f0103f4b:	ba b0 78 10 f0       	mov    $0xf01078b0,%edx
	if (trapno == T_SYSCALL)
f0103f50:	83 f8 30             	cmp    $0x30,%eax
f0103f53:	74 1c                	je     f0103f71 <print_trapframe+0x79>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103f55:	8d 50 e0             	lea    -0x20(%eax),%edx
	return "(unknown trap)";
f0103f58:	83 fa 10             	cmp    $0x10,%edx
f0103f5b:	ba bc 78 10 f0       	mov    $0xf01078bc,%edx
f0103f60:	b9 cf 78 10 f0       	mov    $0xf01078cf,%ecx
f0103f65:	0f 43 d1             	cmovae %ecx,%edx
f0103f68:	eb 07                	jmp    f0103f71 <print_trapframe+0x79>
		return excnames[trapno];
f0103f6a:	8b 14 85 c0 7b 10 f0 	mov    -0xfef8440(,%eax,4),%edx
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103f71:	83 ec 04             	sub    $0x4,%esp
f0103f74:	52                   	push   %edx
f0103f75:	50                   	push   %eax
f0103f76:	68 49 79 10 f0       	push   $0xf0107949
f0103f7b:	e8 c8 f9 ff ff       	call   f0103948 <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103f80:	83 c4 10             	add    $0x10,%esp
f0103f83:	39 1d 60 5a 21 f0    	cmp    %ebx,0xf0215a60
f0103f89:	0f 84 a6 00 00 00    	je     f0104035 <print_trapframe+0x13d>
	cprintf("  err  0x%08x", tf->tf_err);
f0103f8f:	83 ec 08             	sub    $0x8,%esp
f0103f92:	ff 73 2c             	pushl  0x2c(%ebx)
f0103f95:	68 6a 79 10 f0       	push   $0xf010796a
f0103f9a:	e8 a9 f9 ff ff       	call   f0103948 <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f0103f9f:	83 c4 10             	add    $0x10,%esp
f0103fa2:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103fa6:	0f 85 ac 00 00 00    	jne    f0104058 <print_trapframe+0x160>
			tf->tf_err & 1 ? "protection" : "not-present");
f0103fac:	8b 43 2c             	mov    0x2c(%ebx),%eax
		cprintf(" [%s, %s, %s]\n",
f0103faf:	89 c2                	mov    %eax,%edx
f0103fb1:	83 e2 01             	and    $0x1,%edx
f0103fb4:	b9 de 78 10 f0       	mov    $0xf01078de,%ecx
f0103fb9:	ba e9 78 10 f0       	mov    $0xf01078e9,%edx
f0103fbe:	0f 44 ca             	cmove  %edx,%ecx
f0103fc1:	89 c2                	mov    %eax,%edx
f0103fc3:	83 e2 02             	and    $0x2,%edx
f0103fc6:	be f5 78 10 f0       	mov    $0xf01078f5,%esi
f0103fcb:	ba fb 78 10 f0       	mov    $0xf01078fb,%edx
f0103fd0:	0f 45 d6             	cmovne %esi,%edx
f0103fd3:	83 e0 04             	and    $0x4,%eax
f0103fd6:	b8 00 79 10 f0       	mov    $0xf0107900,%eax
f0103fdb:	be 50 7a 10 f0       	mov    $0xf0107a50,%esi
f0103fe0:	0f 44 c6             	cmove  %esi,%eax
f0103fe3:	51                   	push   %ecx
f0103fe4:	52                   	push   %edx
f0103fe5:	50                   	push   %eax
f0103fe6:	68 78 79 10 f0       	push   $0xf0107978
f0103feb:	e8 58 f9 ff ff       	call   f0103948 <cprintf>
f0103ff0:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103ff3:	83 ec 08             	sub    $0x8,%esp
f0103ff6:	ff 73 30             	pushl  0x30(%ebx)
f0103ff9:	68 87 79 10 f0       	push   $0xf0107987
f0103ffe:	e8 45 f9 ff ff       	call   f0103948 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0104003:	83 c4 08             	add    $0x8,%esp
f0104006:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f010400a:	50                   	push   %eax
f010400b:	68 96 79 10 f0       	push   $0xf0107996
f0104010:	e8 33 f9 ff ff       	call   f0103948 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0104015:	83 c4 08             	add    $0x8,%esp
f0104018:	ff 73 38             	pushl  0x38(%ebx)
f010401b:	68 a9 79 10 f0       	push   $0xf01079a9
f0104020:	e8 23 f9 ff ff       	call   f0103948 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0104025:	83 c4 10             	add    $0x10,%esp
f0104028:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f010402c:	75 3c                	jne    f010406a <print_trapframe+0x172>
}
f010402e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104031:	5b                   	pop    %ebx
f0104032:	5e                   	pop    %esi
f0104033:	5d                   	pop    %ebp
f0104034:	c3                   	ret    
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104035:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104039:	0f 85 50 ff ff ff    	jne    f0103f8f <print_trapframe+0x97>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f010403f:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0104042:	83 ec 08             	sub    $0x8,%esp
f0104045:	50                   	push   %eax
f0104046:	68 5b 79 10 f0       	push   $0xf010795b
f010404b:	e8 f8 f8 ff ff       	call   f0103948 <cprintf>
f0104050:	83 c4 10             	add    $0x10,%esp
f0104053:	e9 37 ff ff ff       	jmp    f0103f8f <print_trapframe+0x97>
		cprintf("\n");
f0104058:	83 ec 0c             	sub    $0xc,%esp
f010405b:	68 c9 68 10 f0       	push   $0xf01068c9
f0104060:	e8 e3 f8 ff ff       	call   f0103948 <cprintf>
f0104065:	83 c4 10             	add    $0x10,%esp
f0104068:	eb 89                	jmp    f0103ff3 <print_trapframe+0xfb>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f010406a:	83 ec 08             	sub    $0x8,%esp
f010406d:	ff 73 3c             	pushl  0x3c(%ebx)
f0104070:	68 b8 79 10 f0       	push   $0xf01079b8
f0104075:	e8 ce f8 ff ff       	call   f0103948 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f010407a:	83 c4 08             	add    $0x8,%esp
f010407d:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0104081:	50                   	push   %eax
f0104082:	68 c7 79 10 f0       	push   $0xf01079c7
f0104087:	e8 bc f8 ff ff       	call   f0103948 <cprintf>
f010408c:	83 c4 10             	add    $0x10,%esp
}
f010408f:	eb 9d                	jmp    f010402e <print_trapframe+0x136>

f0104091 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0104091:	55                   	push   %ebp
f0104092:	89 e5                	mov    %esp,%ebp
f0104094:	57                   	push   %edi
f0104095:	56                   	push   %esi
f0104096:	53                   	push   %ebx
f0104097:	83 ec 0c             	sub    $0xc,%esp
f010409a:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010409d:	0f 20 d6             	mov    %cr2,%esi

	// Handle kernel-mode page faults.
        
	// LAB 3: Your code here.
//	cprintf("tf->tf_cs= %08x\n",tf->tf_cs);
        if((tf->tf_cs & 0x3) == 0){
f01040a0:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01040a4:	74 5d                	je     f0104103 <page_fault_handler+0x72>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
        struct UTrapframe *utf;

	if(curenv->env_pgfault_upcall){
f01040a6:	e8 78 1e 00 00       	call   f0105f23 <cpunum>
f01040ab:	6b c0 74             	imul   $0x74,%eax,%eax
f01040ae:	8b 80 28 60 21 f0    	mov    -0xfde9fd8(%eax),%eax
f01040b4:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f01040b8:	75 60                	jne    f010411a <page_fault_handler+0x89>
        

         
     	
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01040ba:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f01040bd:	e8 61 1e 00 00       	call   f0105f23 <cpunum>
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01040c2:	57                   	push   %edi
f01040c3:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f01040c4:	6b c0 74             	imul   $0x74,%eax,%eax
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01040c7:	8b 80 28 60 21 f0    	mov    -0xfde9fd8(%eax),%eax
f01040cd:	ff 70 48             	pushl  0x48(%eax)
f01040d0:	68 9c 7b 10 f0       	push   $0xf0107b9c
f01040d5:	e8 6e f8 ff ff       	call   f0103948 <cprintf>
	print_trapframe(tf);
f01040da:	89 1c 24             	mov    %ebx,(%esp)
f01040dd:	e8 16 fe ff ff       	call   f0103ef8 <print_trapframe>
	env_destroy(curenv);
f01040e2:	e8 3c 1e 00 00       	call   f0105f23 <cpunum>
f01040e7:	83 c4 04             	add    $0x4,%esp
f01040ea:	6b c0 74             	imul   $0x74,%eax,%eax
f01040ed:	ff b0 28 60 21 f0    	pushl  -0xfde9fd8(%eax)
f01040f3:	e8 54 f5 ff ff       	call   f010364c <env_destroy>
}
f01040f8:	83 c4 10             	add    $0x10,%esp
f01040fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01040fe:	5b                   	pop    %ebx
f01040ff:	5e                   	pop    %esi
f0104100:	5f                   	pop    %edi
f0104101:	5d                   	pop    %ebp
f0104102:	c3                   	ret    
	  panic("page fault in kernel node\n");
f0104103:	83 ec 04             	sub    $0x4,%esp
f0104106:	68 da 79 10 f0       	push   $0xf01079da
f010410b:	68 7c 01 00 00       	push   $0x17c
f0104110:	68 f5 79 10 f0       	push   $0xf01079f5
f0104115:	e8 26 bf ff ff       	call   f0100040 <_panic>
	  if(tf->tf_esp>=UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP)
f010411a:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010411d:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
		  utf = (struct UTrapframe *)(UXSTACKTOP-sizeof(struct UTrapframe));
f0104123:	bf cc ff bf ee       	mov    $0xeebfffcc,%edi
	  if(tf->tf_esp>=UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP)
f0104128:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f010412e:	77 05                	ja     f0104135 <page_fault_handler+0xa4>
		  utf = (struct UTrapframe *)(tf->tf_esp-4-sizeof(struct UTrapframe));
f0104130:	83 e8 38             	sub    $0x38,%eax
f0104133:	89 c7                	mov    %eax,%edi
	  user_mem_assert(curenv,(void *)utf,sizeof(struct UTrapframe),PTE_U|PTE_W|PTE_P);
f0104135:	e8 e9 1d 00 00       	call   f0105f23 <cpunum>
f010413a:	6a 07                	push   $0x7
f010413c:	6a 34                	push   $0x34
f010413e:	57                   	push   %edi
f010413f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104142:	ff b0 28 60 21 f0    	pushl  -0xfde9fd8(%eax)
f0104148:	e8 89 ee ff ff       	call   f0102fd6 <user_mem_assert>
	  utf->utf_fault_va = fault_va;
f010414d:	89 fa                	mov    %edi,%edx
f010414f:	89 37                	mov    %esi,(%edi)
	  utf->utf_err = tf->tf_trapno;
f0104151:	8b 43 28             	mov    0x28(%ebx),%eax
f0104154:	89 47 04             	mov    %eax,0x4(%edi)
	  utf->utf_regs = tf->tf_regs;
f0104157:	8d 7f 08             	lea    0x8(%edi),%edi
f010415a:	b9 08 00 00 00       	mov    $0x8,%ecx
f010415f:	89 de                	mov    %ebx,%esi
f0104161:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	  utf->utf_eip = tf->tf_eip;
f0104163:	8b 43 30             	mov    0x30(%ebx),%eax
f0104166:	89 42 28             	mov    %eax,0x28(%edx)
	  utf->utf_eflags = tf->tf_eflags;
f0104169:	8b 43 38             	mov    0x38(%ebx),%eax
f010416c:	89 d7                	mov    %edx,%edi
f010416e:	89 42 2c             	mov    %eax,0x2c(%edx)
	  utf->utf_esp = tf->tf_esp;
f0104171:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104174:	89 42 30             	mov    %eax,0x30(%edx)
	  tf->tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
f0104177:	e8 a7 1d 00 00       	call   f0105f23 <cpunum>
f010417c:	6b c0 74             	imul   $0x74,%eax,%eax
f010417f:	8b 80 28 60 21 f0    	mov    -0xfde9fd8(%eax),%eax
f0104185:	8b 40 64             	mov    0x64(%eax),%eax
f0104188:	89 43 30             	mov    %eax,0x30(%ebx)
	  tf->tf_esp = (uintptr_t)utf;
f010418b:	89 7b 3c             	mov    %edi,0x3c(%ebx)
	  env_run(curenv);
f010418e:	e8 90 1d 00 00       	call   f0105f23 <cpunum>
f0104193:	83 c4 04             	add    $0x4,%esp
f0104196:	6b c0 74             	imul   $0x74,%eax,%eax
f0104199:	ff b0 28 60 21 f0    	pushl  -0xfde9fd8(%eax)
f010419f:	e8 47 f5 ff ff       	call   f01036eb <env_run>

f01041a4 <trap>:
{
f01041a4:	55                   	push   %ebp
f01041a5:	89 e5                	mov    %esp,%ebp
f01041a7:	57                   	push   %edi
f01041a8:	56                   	push   %esi
f01041a9:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::: "cc");
f01041ac:	fc                   	cld    
	if (panicstr)
f01041ad:	83 3d 80 5e 21 f0 00 	cmpl   $0x0,0xf0215e80
f01041b4:	74 01                	je     f01041b7 <trap+0x13>
		asm volatile("hlt");
f01041b6:	f4                   	hlt    
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f01041b7:	e8 67 1d 00 00       	call   f0105f23 <cpunum>
f01041bc:	6b d0 74             	imul   $0x74,%eax,%edx
f01041bf:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f01041c2:	b8 01 00 00 00       	mov    $0x1,%eax
f01041c7:	f0 87 82 20 60 21 f0 	lock xchg %eax,-0xfde9fe0(%edx)
f01041ce:	83 f8 02             	cmp    $0x2,%eax
f01041d1:	0f 84 c2 00 00 00    	je     f0104299 <trap+0xf5>
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f01041d7:	9c                   	pushf  
f01041d8:	58                   	pop    %eax
	assert(!(read_eflags() & FL_IF));
f01041d9:	f6 c4 02             	test   $0x2,%ah
f01041dc:	0f 85 cc 00 00 00    	jne    f01042ae <trap+0x10a>
	if ((tf->tf_cs & 3) == 3) {
f01041e2:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01041e6:	83 e0 03             	and    $0x3,%eax
f01041e9:	66 83 f8 03          	cmp    $0x3,%ax
f01041ed:	0f 84 d4 00 00 00    	je     f01042c7 <trap+0x123>
	last_tf = tf;
f01041f3:	89 35 60 5a 21 f0    	mov    %esi,0xf0215a60
	 if(tf->tf_trapno == T_PGFLT){
f01041f9:	8b 46 28             	mov    0x28(%esi),%eax
f01041fc:	83 f8 0e             	cmp    $0xe,%eax
f01041ff:	0f 84 67 01 00 00    	je     f010436c <trap+0x1c8>
        if(tf->tf_trapno==T_BRKPT){
f0104205:	83 f8 03             	cmp    $0x3,%eax
f0104208:	0f 84 6f 01 00 00    	je     f010437d <trap+0x1d9>
        if(tf->tf_trapno == T_SYSCALL){
f010420e:	83 f8 30             	cmp    $0x30,%eax
f0104211:	0f 84 77 01 00 00    	je     f010438e <trap+0x1ea>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104217:	83 f8 27             	cmp    $0x27,%eax
f010421a:	0f 84 92 01 00 00    	je     f01043b2 <trap+0x20e>
        if(tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER){
f0104220:	83 f8 20             	cmp    $0x20,%eax
f0104223:	0f 84 a6 01 00 00    	je     f01043cf <trap+0x22b>
        if(tf->tf_trapno == IRQ_OFFSET + IRQ_KBD){
f0104229:	83 f8 21             	cmp    $0x21,%eax
f010422c:	0f 84 a7 01 00 00    	je     f01043d9 <trap+0x235>
        if(tf->tf_trapno == IRQ_OFFSET + IRQ_SERIAL){
f0104232:	83 f8 24             	cmp    $0x24,%eax
f0104235:	0f 84 a8 01 00 00    	je     f01043e3 <trap+0x23f>
        	print_trapframe(tf);
f010423b:	83 ec 0c             	sub    $0xc,%esp
f010423e:	56                   	push   %esi
f010423f:	e8 b4 fc ff ff       	call   f0103ef8 <print_trapframe>
        	if (tf->tf_cs == GD_KT)
f0104244:	83 c4 10             	add    $0x10,%esp
f0104247:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f010424c:	0f 84 9b 01 00 00    	je     f01043ed <trap+0x249>
		env_destroy(curenv);
f0104252:	e8 cc 1c 00 00       	call   f0105f23 <cpunum>
f0104257:	83 ec 0c             	sub    $0xc,%esp
f010425a:	6b c0 74             	imul   $0x74,%eax,%eax
f010425d:	ff b0 28 60 21 f0    	pushl  -0xfde9fd8(%eax)
f0104263:	e8 e4 f3 ff ff       	call   f010364c <env_destroy>
f0104268:	83 c4 10             	add    $0x10,%esp
	if (curenv && curenv->env_status == ENV_RUNNING)
f010426b:	e8 b3 1c 00 00       	call   f0105f23 <cpunum>
f0104270:	6b c0 74             	imul   $0x74,%eax,%eax
f0104273:	83 b8 28 60 21 f0 00 	cmpl   $0x0,-0xfde9fd8(%eax)
f010427a:	74 18                	je     f0104294 <trap+0xf0>
f010427c:	e8 a2 1c 00 00       	call   f0105f23 <cpunum>
f0104281:	6b c0 74             	imul   $0x74,%eax,%eax
f0104284:	8b 80 28 60 21 f0    	mov    -0xfde9fd8(%eax),%eax
f010428a:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010428e:	0f 84 70 01 00 00    	je     f0104404 <trap+0x260>
		sched_yield();
f0104294:	e8 f1 02 00 00       	call   f010458a <sched_yield>
	spin_lock(&kernel_lock);
f0104299:	83 ec 0c             	sub    $0xc,%esp
f010429c:	68 c0 23 12 f0       	push   $0xf01223c0
f01042a1:	e8 ed 1e 00 00       	call   f0106193 <spin_lock>
f01042a6:	83 c4 10             	add    $0x10,%esp
f01042a9:	e9 29 ff ff ff       	jmp    f01041d7 <trap+0x33>
	assert(!(read_eflags() & FL_IF));
f01042ae:	68 01 7a 10 f0       	push   $0xf0107a01
f01042b3:	68 6f 74 10 f0       	push   $0xf010746f
f01042b8:	68 46 01 00 00       	push   $0x146
f01042bd:	68 f5 79 10 f0       	push   $0xf01079f5
f01042c2:	e8 79 bd ff ff       	call   f0100040 <_panic>
f01042c7:	83 ec 0c             	sub    $0xc,%esp
f01042ca:	68 c0 23 12 f0       	push   $0xf01223c0
f01042cf:	e8 bf 1e 00 00       	call   f0106193 <spin_lock>
		assert(curenv);
f01042d4:	e8 4a 1c 00 00       	call   f0105f23 <cpunum>
f01042d9:	6b c0 74             	imul   $0x74,%eax,%eax
f01042dc:	83 c4 10             	add    $0x10,%esp
f01042df:	83 b8 28 60 21 f0 00 	cmpl   $0x0,-0xfde9fd8(%eax)
f01042e6:	74 3e                	je     f0104326 <trap+0x182>
		if (curenv->env_status == ENV_DYING) {
f01042e8:	e8 36 1c 00 00       	call   f0105f23 <cpunum>
f01042ed:	6b c0 74             	imul   $0x74,%eax,%eax
f01042f0:	8b 80 28 60 21 f0    	mov    -0xfde9fd8(%eax),%eax
f01042f6:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01042fa:	74 43                	je     f010433f <trap+0x19b>
		curenv->env_tf = *tf;
f01042fc:	e8 22 1c 00 00       	call   f0105f23 <cpunum>
f0104301:	6b c0 74             	imul   $0x74,%eax,%eax
f0104304:	8b 80 28 60 21 f0    	mov    -0xfde9fd8(%eax),%eax
f010430a:	b9 11 00 00 00       	mov    $0x11,%ecx
f010430f:	89 c7                	mov    %eax,%edi
f0104311:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f0104313:	e8 0b 1c 00 00       	call   f0105f23 <cpunum>
f0104318:	6b c0 74             	imul   $0x74,%eax,%eax
f010431b:	8b b0 28 60 21 f0    	mov    -0xfde9fd8(%eax),%esi
f0104321:	e9 cd fe ff ff       	jmp    f01041f3 <trap+0x4f>
		assert(curenv);
f0104326:	68 1a 7a 10 f0       	push   $0xf0107a1a
f010432b:	68 6f 74 10 f0       	push   $0xf010746f
f0104330:	68 4e 01 00 00       	push   $0x14e
f0104335:	68 f5 79 10 f0       	push   $0xf01079f5
f010433a:	e8 01 bd ff ff       	call   f0100040 <_panic>
			env_free(curenv);
f010433f:	e8 df 1b 00 00       	call   f0105f23 <cpunum>
f0104344:	83 ec 0c             	sub    $0xc,%esp
f0104347:	6b c0 74             	imul   $0x74,%eax,%eax
f010434a:	ff b0 28 60 21 f0    	pushl  -0xfde9fd8(%eax)
f0104350:	e8 3a f1 ff ff       	call   f010348f <env_free>
			curenv = NULL;
f0104355:	e8 c9 1b 00 00       	call   f0105f23 <cpunum>
f010435a:	6b c0 74             	imul   $0x74,%eax,%eax
f010435d:	c7 80 28 60 21 f0 00 	movl   $0x0,-0xfde9fd8(%eax)
f0104364:	00 00 00 
			sched_yield();
f0104367:	e8 1e 02 00 00       	call   f010458a <sched_yield>
           page_fault_handler(tf);
f010436c:	83 ec 0c             	sub    $0xc,%esp
f010436f:	56                   	push   %esi
f0104370:	e8 1c fd ff ff       	call   f0104091 <page_fault_handler>
f0104375:	83 c4 10             	add    $0x10,%esp
f0104378:	e9 ee fe ff ff       	jmp    f010426b <trap+0xc7>
          monitor(tf);
f010437d:	83 ec 0c             	sub    $0xc,%esp
f0104380:	56                   	push   %esi
f0104381:	e8 d4 c5 ff ff       	call   f010095a <monitor>
f0104386:	83 c4 10             	add    $0x10,%esp
f0104389:	e9 dd fe ff ff       	jmp    f010426b <trap+0xc7>
           ret = syscall(
f010438e:	83 ec 08             	sub    $0x8,%esp
f0104391:	ff 76 04             	pushl  0x4(%esi)
f0104394:	ff 36                	pushl  (%esi)
f0104396:	ff 76 10             	pushl  0x10(%esi)
f0104399:	ff 76 18             	pushl  0x18(%esi)
f010439c:	ff 76 14             	pushl  0x14(%esi)
f010439f:	ff 76 1c             	pushl  0x1c(%esi)
f01043a2:	e8 7a 02 00 00       	call   f0104621 <syscall>
           tf->tf_regs.reg_eax = ret;
f01043a7:	89 46 1c             	mov    %eax,0x1c(%esi)
f01043aa:	83 c4 20             	add    $0x20,%esp
f01043ad:	e9 b9 fe ff ff       	jmp    f010426b <trap+0xc7>
		cprintf("Spurious interrupt on irq 7\n");
f01043b2:	83 ec 0c             	sub    $0xc,%esp
f01043b5:	68 21 7a 10 f0       	push   $0xf0107a21
f01043ba:	e8 89 f5 ff ff       	call   f0103948 <cprintf>
		print_trapframe(tf);
f01043bf:	89 34 24             	mov    %esi,(%esp)
f01043c2:	e8 31 fb ff ff       	call   f0103ef8 <print_trapframe>
f01043c7:	83 c4 10             	add    $0x10,%esp
f01043ca:	e9 9c fe ff ff       	jmp    f010426b <trap+0xc7>
                lapic_eoi();
f01043cf:	e8 9b 1c 00 00       	call   f010606f <lapic_eoi>
                sched_yield();
f01043d4:	e8 b1 01 00 00       	call   f010458a <sched_yield>
	        kbd_intr();
f01043d9:	e8 18 c2 ff ff       	call   f01005f6 <kbd_intr>
f01043de:	e9 88 fe ff ff       	jmp    f010426b <trap+0xc7>
	       serial_intr();
f01043e3:	e8 f1 c1 ff ff       	call   f01005d9 <serial_intr>
f01043e8:	e9 7e fe ff ff       	jmp    f010426b <trap+0xc7>
		panic("unhandled trap in kernel");
f01043ed:	83 ec 04             	sub    $0x4,%esp
f01043f0:	68 3e 7a 10 f0       	push   $0xf0107a3e
f01043f5:	68 2c 01 00 00       	push   $0x12c
f01043fa:	68 f5 79 10 f0       	push   $0xf01079f5
f01043ff:	e8 3c bc ff ff       	call   f0100040 <_panic>
		env_run(curenv);
f0104404:	e8 1a 1b 00 00       	call   f0105f23 <cpunum>
f0104409:	83 ec 0c             	sub    $0xc,%esp
f010440c:	6b c0 74             	imul   $0x74,%eax,%eax
f010440f:	ff b0 28 60 21 f0    	pushl  -0xfde9fd8(%eax)
f0104415:	e8 d1 f2 ff ff       	call   f01036eb <env_run>

f010441a <divide_handler>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(divide_handler,T_DIVIDE);
f010441a:	6a 00                	push   $0x0
f010441c:	6a 00                	push   $0x0
f010441e:	e9 83 00 00 00       	jmp    f01044a6 <_alltraps>
f0104423:	90                   	nop

f0104424 <debug_handler>:
TRAPHANDLER_NOEC(debug_handler,T_DEBUG);
f0104424:	6a 00                	push   $0x0
f0104426:	6a 01                	push   $0x1
f0104428:	eb 7c                	jmp    f01044a6 <_alltraps>

f010442a <nmi_handler>:
TRAPHANDLER_NOEC(nmi_handler,T_NMI);
f010442a:	6a 00                	push   $0x0
f010442c:	6a 02                	push   $0x2
f010442e:	eb 76                	jmp    f01044a6 <_alltraps>

f0104430 <brkpt_handler>:
TRAPHANDLER_NOEC(brkpt_handler,T_BRKPT);
f0104430:	6a 00                	push   $0x0
f0104432:	6a 03                	push   $0x3
f0104434:	eb 70                	jmp    f01044a6 <_alltraps>

f0104436 <oflow_handler>:
TRAPHANDLER_NOEC(oflow_handler,T_OFLOW);
f0104436:	6a 00                	push   $0x0
f0104438:	6a 04                	push   $0x4
f010443a:	eb 6a                	jmp    f01044a6 <_alltraps>

f010443c <bound_handler>:
TRAPHANDLER_NOEC(bound_handler,T_BOUND);
f010443c:	6a 00                	push   $0x0
f010443e:	6a 05                	push   $0x5
f0104440:	eb 64                	jmp    f01044a6 <_alltraps>

f0104442 <illop_handler>:
TRAPHANDLER_NOEC(illop_handler,T_ILLOP);
f0104442:	6a 00                	push   $0x0
f0104444:	6a 06                	push   $0x6
f0104446:	eb 5e                	jmp    f01044a6 <_alltraps>

f0104448 <device_handler>:
TRAPHANDLER_NOEC(device_handler,T_DEVICE);
f0104448:	6a 00                	push   $0x0
f010444a:	6a 07                	push   $0x7
f010444c:	eb 58                	jmp    f01044a6 <_alltraps>

f010444e <dblflt_handler>:
TRAPHANDLER(dblflt_handler,T_DBLFLT);
f010444e:	6a 08                	push   $0x8
f0104450:	eb 54                	jmp    f01044a6 <_alltraps>

f0104452 <tss_handler>:
TRAPHANDLER(tss_handler,T_TSS);
f0104452:	6a 0a                	push   $0xa
f0104454:	eb 50                	jmp    f01044a6 <_alltraps>

f0104456 <segnp_handler>:
TRAPHANDLER(segnp_handler,T_SEGNP);
f0104456:	6a 0b                	push   $0xb
f0104458:	eb 4c                	jmp    f01044a6 <_alltraps>

f010445a <stack_handler>:
TRAPHANDLER(stack_handler,T_STACK);
f010445a:	6a 0c                	push   $0xc
f010445c:	eb 48                	jmp    f01044a6 <_alltraps>

f010445e <gpflt_handler>:
TRAPHANDLER(gpflt_handler,T_GPFLT);
f010445e:	6a 0d                	push   $0xd
f0104460:	eb 44                	jmp    f01044a6 <_alltraps>

f0104462 <pgflt_handler>:
TRAPHANDLER(pgflt_handler,T_PGFLT);
f0104462:	6a 0e                	push   $0xe
f0104464:	eb 40                	jmp    f01044a6 <_alltraps>

f0104466 <fperr_handler>:
TRAPHANDLER_NOEC(fperr_handler,T_FPERR);
f0104466:	6a 00                	push   $0x0
f0104468:	6a 10                	push   $0x10
f010446a:	eb 3a                	jmp    f01044a6 <_alltraps>

f010446c <align_handler>:
TRAPHANDLER(align_handler,T_ALIGN);
f010446c:	6a 11                	push   $0x11
f010446e:	eb 36                	jmp    f01044a6 <_alltraps>

f0104470 <mchk_handler>:
TRAPHANDLER_NOEC(mchk_handler,T_MCHK);
f0104470:	6a 00                	push   $0x0
f0104472:	6a 12                	push   $0x12
f0104474:	eb 30                	jmp    f01044a6 <_alltraps>

f0104476 <simderr_handler>:
TRAPHANDLER_NOEC(simderr_handler,T_SIMDERR);
f0104476:	6a 00                	push   $0x0
f0104478:	6a 13                	push   $0x13
f010447a:	eb 2a                	jmp    f01044a6 <_alltraps>

f010447c <syscall_handler>:
TRAPHANDLER_NOEC(syscall_handler,T_SYSCALL);
f010447c:	6a 00                	push   $0x0
f010447e:	6a 30                	push   $0x30
f0104480:	eb 24                	jmp    f01044a6 <_alltraps>

f0104482 <timer_handler>:

TRAPHANDLER_NOEC(timer_handler,IRQ_OFFSET+IRQ_TIMER);
f0104482:	6a 00                	push   $0x0
f0104484:	6a 20                	push   $0x20
f0104486:	eb 1e                	jmp    f01044a6 <_alltraps>

f0104488 <kbd_handler>:
TRAPHANDLER_NOEC(kbd_handler,IRQ_OFFSET+IRQ_KBD);
f0104488:	6a 00                	push   $0x0
f010448a:	6a 21                	push   $0x21
f010448c:	eb 18                	jmp    f01044a6 <_alltraps>

f010448e <serial_handler>:
TRAPHANDLER_NOEC(serial_handler,IRQ_OFFSET+IRQ_SERIAL);
f010448e:	6a 00                	push   $0x0
f0104490:	6a 24                	push   $0x24
f0104492:	eb 12                	jmp    f01044a6 <_alltraps>

f0104494 <spurious_handler>:
TRAPHANDLER_NOEC(spurious_handler,IRQ_OFFSET+IRQ_SPURIOUS);
f0104494:	6a 00                	push   $0x0
f0104496:	6a 27                	push   $0x27
f0104498:	eb 0c                	jmp    f01044a6 <_alltraps>

f010449a <ide_handler>:
TRAPHANDLER_NOEC(ide_handler,IRQ_OFFSET+IRQ_IDE);
f010449a:	6a 00                	push   $0x0
f010449c:	6a 2e                	push   $0x2e
f010449e:	eb 06                	jmp    f01044a6 <_alltraps>

f01044a0 <error_handler>:
TRAPHANDLER_NOEC(error_handler,IRQ_OFFSET+IRQ_ERROR);
f01044a0:	6a 00                	push   $0x0
f01044a2:	6a 33                	push   $0x33
f01044a4:	eb 00                	jmp    f01044a6 <_alltraps>

f01044a6 <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
pushl %ds
f01044a6:	1e                   	push   %ds
pushl %es
f01044a7:	06                   	push   %es
pushal
f01044a8:	60                   	pusha  

movl $GD_KD, %eax
f01044a9:	b8 10 00 00 00       	mov    $0x10,%eax
movl %eax, %ds
f01044ae:	8e d8                	mov    %eax,%ds
movl %eax, %es
f01044b0:	8e c0                	mov    %eax,%es

pushl %esp
f01044b2:	54                   	push   %esp

call trap     
f01044b3:	e8 ec fc ff ff       	call   f01041a4 <trap>

f01044b8 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f01044b8:	55                   	push   %ebp
f01044b9:	89 e5                	mov    %esp,%ebp
f01044bb:	83 ec 08             	sub    $0x8,%esp
f01044be:	a1 44 52 21 f0       	mov    0xf0215244,%eax
f01044c3:	83 c0 54             	add    $0x54,%eax
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01044c6:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f01044cb:	8b 10                	mov    (%eax),%edx
f01044cd:	83 ea 01             	sub    $0x1,%edx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f01044d0:	83 fa 02             	cmp    $0x2,%edx
f01044d3:	76 2d                	jbe    f0104502 <sched_halt+0x4a>
	for (i = 0; i < NENV; i++) {
f01044d5:	83 c1 01             	add    $0x1,%ecx
f01044d8:	83 c0 7c             	add    $0x7c,%eax
f01044db:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f01044e1:	75 e8                	jne    f01044cb <sched_halt+0x13>
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
		cprintf("No runnable environments in the system!\n");
f01044e3:	83 ec 0c             	sub    $0xc,%esp
f01044e6:	68 10 7c 10 f0       	push   $0xf0107c10
f01044eb:	e8 58 f4 ff ff       	call   f0103948 <cprintf>
f01044f0:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f01044f3:	83 ec 0c             	sub    $0xc,%esp
f01044f6:	6a 00                	push   $0x0
f01044f8:	e8 5d c4 ff ff       	call   f010095a <monitor>
f01044fd:	83 c4 10             	add    $0x10,%esp
f0104500:	eb f1                	jmp    f01044f3 <sched_halt+0x3b>
	if (i == NENV) {
f0104502:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104508:	74 d9                	je     f01044e3 <sched_halt+0x2b>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f010450a:	e8 14 1a 00 00       	call   f0105f23 <cpunum>
f010450f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104512:	c7 80 28 60 21 f0 00 	movl   $0x0,-0xfde9fd8(%eax)
f0104519:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f010451c:	a1 8c 5e 21 f0       	mov    0xf0215e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0104521:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104526:	76 50                	jbe    f0104578 <sched_halt+0xc0>
	return (physaddr_t)kva - KERNBASE;
f0104528:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010452d:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104530:	e8 ee 19 00 00       	call   f0105f23 <cpunum>
f0104535:	6b d0 74             	imul   $0x74,%eax,%edx
f0104538:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f010453b:	b8 02 00 00 00       	mov    $0x2,%eax
f0104540:	f0 87 82 20 60 21 f0 	lock xchg %eax,-0xfde9fe0(%edx)
	spin_unlock(&kernel_lock);
f0104547:	83 ec 0c             	sub    $0xc,%esp
f010454a:	68 c0 23 12 f0       	push   $0xf01223c0
f010454f:	e8 dc 1c 00 00       	call   f0106230 <spin_unlock>
	asm volatile("pause");
f0104554:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104556:	e8 c8 19 00 00       	call   f0105f23 <cpunum>
f010455b:	6b c0 74             	imul   $0x74,%eax,%eax
	asm volatile (
f010455e:	8b 80 30 60 21 f0    	mov    -0xfde9fd0(%eax),%eax
f0104564:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104569:	89 c4                	mov    %eax,%esp
f010456b:	6a 00                	push   $0x0
f010456d:	6a 00                	push   $0x0
f010456f:	fb                   	sti    
f0104570:	f4                   	hlt    
f0104571:	eb fd                	jmp    f0104570 <sched_halt+0xb8>
}
f0104573:	83 c4 10             	add    $0x10,%esp
f0104576:	c9                   	leave  
f0104577:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104578:	50                   	push   %eax
f0104579:	68 a8 65 10 f0       	push   $0xf01065a8
f010457e:	6a 4e                	push   $0x4e
f0104580:	68 39 7c 10 f0       	push   $0xf0107c39
f0104585:	e8 b6 ba ff ff       	call   f0100040 <_panic>

f010458a <sched_yield>:
{
f010458a:	55                   	push   %ebp
f010458b:	89 e5                	mov    %esp,%ebp
f010458d:	57                   	push   %edi
f010458e:	56                   	push   %esi
f010458f:	53                   	push   %ebx
f0104590:	83 ec 0c             	sub    $0xc,%esp
	idle = thiscpu->cpu_env;
f0104593:	e8 8b 19 00 00       	call   f0105f23 <cpunum>
f0104598:	6b c0 74             	imul   $0x74,%eax,%eax
f010459b:	8b 80 28 60 21 f0    	mov    -0xfde9fd8(%eax),%eax
	int curenv_id=0;
f01045a1:	ba 00 00 00 00       	mov    $0x0,%edx
	if(idle!=NULL){
f01045a6:	85 c0                	test   %eax,%eax
f01045a8:	74 09                	je     f01045b3 <sched_yield+0x29>
	 curenv_id = ENVX(idle->env_id);
f01045aa:	8b 50 48             	mov    0x48(%eax),%edx
f01045ad:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
	 if(envs[j].env_status == ENV_RUNNABLE){
f01045b3:	8b 0d 44 52 21 f0    	mov    0xf0215244,%ecx
f01045b9:	89 d6                	mov    %edx,%esi
f01045bb:	8d 9a 00 04 00 00    	lea    0x400(%edx),%ebx
	 j = (curenv_id+i)%NENV;
f01045c1:	89 d7                	mov    %edx,%edi
f01045c3:	c1 ff 1f             	sar    $0x1f,%edi
f01045c6:	c1 ef 16             	shr    $0x16,%edi
f01045c9:	8d 04 3a             	lea    (%edx,%edi,1),%eax
f01045cc:	25 ff 03 00 00       	and    $0x3ff,%eax
f01045d1:	29 f8                	sub    %edi,%eax
	 if(envs[j].env_status == ENV_RUNNABLE){
f01045d3:	6b c0 7c             	imul   $0x7c,%eax,%eax
f01045d6:	01 c8                	add    %ecx,%eax
f01045d8:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f01045dc:	74 1f                	je     f01045fd <sched_yield+0x73>
f01045de:	83 c2 01             	add    $0x1,%edx
	for(i=0;i<NENV;i++){
f01045e1:	39 da                	cmp    %ebx,%edx
f01045e3:	75 dc                	jne    f01045c1 <sched_yield+0x37>
	if(envs[curenv_id].env_status==ENV_RUNNING && envs[curenv_id].env_cpunum==cpunum()){
f01045e5:	6b f6 7c             	imul   $0x7c,%esi,%esi
f01045e8:	01 f1                	add    %esi,%ecx
f01045ea:	83 79 54 03          	cmpl   $0x3,0x54(%ecx)
f01045ee:	74 16                	je     f0104606 <sched_yield+0x7c>
	sched_halt();
f01045f0:	e8 c3 fe ff ff       	call   f01044b8 <sched_halt>
}
f01045f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01045f8:	5b                   	pop    %ebx
f01045f9:	5e                   	pop    %esi
f01045fa:	5f                   	pop    %edi
f01045fb:	5d                   	pop    %ebp
f01045fc:	c3                   	ret    
	   env_run(&envs[j]);
f01045fd:	83 ec 0c             	sub    $0xc,%esp
f0104600:	50                   	push   %eax
f0104601:	e8 e5 f0 ff ff       	call   f01036eb <env_run>
	if(envs[curenv_id].env_status==ENV_RUNNING && envs[curenv_id].env_cpunum==cpunum()){
f0104606:	8b 59 5c             	mov    0x5c(%ecx),%ebx
f0104609:	e8 15 19 00 00       	call   f0105f23 <cpunum>
f010460e:	39 c3                	cmp    %eax,%ebx
f0104610:	75 de                	jne    f01045f0 <sched_yield+0x66>
	   env_run(&envs[curenv_id]);
f0104612:	83 ec 0c             	sub    $0xc,%esp
f0104615:	03 35 44 52 21 f0    	add    0xf0215244,%esi
f010461b:	56                   	push   %esi
f010461c:	e8 ca f0 ff ff       	call   f01036eb <env_run>

f0104621 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104621:	55                   	push   %ebp
f0104622:	89 e5                	mov    %esp,%ebp
f0104624:	57                   	push   %edi
f0104625:	56                   	push   %esi
f0104626:	53                   	push   %ebx
f0104627:	83 ec 1c             	sub    $0x1c,%esp
f010462a:	8b 45 08             	mov    0x8(%ebp),%eax
f010462d:	8b 75 10             	mov    0x10(%ebp),%esi
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

       //	panic("syscall not implemented");
	switch (syscallno) {
f0104630:	83 f8 0d             	cmp    $0xd,%eax
f0104633:	0f 87 73 06 00 00    	ja     f0104cac <syscall+0x68b>
f0104639:	ff 24 85 bc 7c 10 f0 	jmp    *-0xfef8344(,%eax,4)
        user_mem_assert(curenv,s,len,0);
f0104640:	e8 de 18 00 00       	call   f0105f23 <cpunum>
f0104645:	6a 00                	push   $0x0
f0104647:	56                   	push   %esi
f0104648:	ff 75 0c             	pushl  0xc(%ebp)
f010464b:	6b c0 74             	imul   $0x74,%eax,%eax
f010464e:	ff b0 28 60 21 f0    	pushl  -0xfde9fd8(%eax)
f0104654:	e8 7d e9 ff ff       	call   f0102fd6 <user_mem_assert>
	cprintf("%.*s", len, s);
f0104659:	83 c4 0c             	add    $0xc,%esp
f010465c:	ff 75 0c             	pushl  0xc(%ebp)
f010465f:	56                   	push   %esi
f0104660:	68 46 7c 10 f0       	push   $0xf0107c46
f0104665:	e8 de f2 ff ff       	call   f0103948 <cprintf>
f010466a:	83 c4 10             	add    $0x10,%esp
       case SYS_env_set_trapframe:
		 return sys_env_set_trapframe((envid_t)a1,(struct Trapframe*)a2);
       	default:
		return -E_INVAL;
	}
	return 0;
f010466d:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0104672:	89 d8                	mov    %ebx,%eax
f0104674:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104677:	5b                   	pop    %ebx
f0104678:	5e                   	pop    %esi
f0104679:	5f                   	pop    %edi
f010467a:	5d                   	pop    %ebp
f010467b:	c3                   	ret    
	return cons_getc();
f010467c:	e8 87 bf ff ff       	call   f0100608 <cons_getc>
f0104681:	89 c3                	mov    %eax,%ebx
	       return  sys_cgetc();
f0104683:	eb ed                	jmp    f0104672 <syscall+0x51>
	return curenv->env_id;
f0104685:	e8 99 18 00 00       	call   f0105f23 <cpunum>
f010468a:	6b c0 74             	imul   $0x74,%eax,%eax
f010468d:	8b 80 28 60 21 f0    	mov    -0xfde9fd8(%eax),%eax
f0104693:	8b 58 48             	mov    0x48(%eax),%ebx
                return sys_getenvid();
f0104696:	eb da                	jmp    f0104672 <syscall+0x51>
	if ((r = envid2env(envid, &e, 1)) < 0)
f0104698:	83 ec 04             	sub    $0x4,%esp
f010469b:	6a 01                	push   $0x1
f010469d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01046a0:	50                   	push   %eax
f01046a1:	ff 75 0c             	pushl  0xc(%ebp)
f01046a4:	e8 ff e9 ff ff       	call   f01030a8 <envid2env>
f01046a9:	89 c3                	mov    %eax,%ebx
f01046ab:	83 c4 10             	add    $0x10,%esp
f01046ae:	85 c0                	test   %eax,%eax
f01046b0:	78 c0                	js     f0104672 <syscall+0x51>
	env_destroy(e);
f01046b2:	83 ec 0c             	sub    $0xc,%esp
f01046b5:	ff 75 e4             	pushl  -0x1c(%ebp)
f01046b8:	e8 8f ef ff ff       	call   f010364c <env_destroy>
f01046bd:	83 c4 10             	add    $0x10,%esp
	return 0;
f01046c0:	bb 00 00 00 00       	mov    $0x0,%ebx
		return sys_env_destroy(a1);
f01046c5:	eb ab                	jmp    f0104672 <syscall+0x51>
	sched_yield();
f01046c7:	e8 be fe ff ff       	call   f010458a <sched_yield>
	return curenv->env_id;
f01046cc:	e8 52 18 00 00       	call   f0105f23 <cpunum>
      if((ret = env_alloc(&childenv,sys_getenvid()))<0)
f01046d1:	83 ec 08             	sub    $0x8,%esp
	return curenv->env_id;
f01046d4:	6b c0 74             	imul   $0x74,%eax,%eax
f01046d7:	8b 80 28 60 21 f0    	mov    -0xfde9fd8(%eax),%eax
      if((ret = env_alloc(&childenv,sys_getenvid()))<0)
f01046dd:	ff 70 48             	pushl  0x48(%eax)
f01046e0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01046e3:	50                   	push   %eax
f01046e4:	e8 d0 ea ff ff       	call   f01031b9 <env_alloc>
f01046e9:	89 c3                	mov    %eax,%ebx
f01046eb:	83 c4 10             	add    $0x10,%esp
f01046ee:	85 c0                	test   %eax,%eax
f01046f0:	78 80                	js     f0104672 <syscall+0x51>
      childenv->env_status = ENV_NOT_RUNNABLE;
f01046f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01046f5:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
      childenv->env_tf = curenv->env_tf;
f01046fc:	e8 22 18 00 00       	call   f0105f23 <cpunum>
f0104701:	6b c0 74             	imul   $0x74,%eax,%eax
f0104704:	8b b0 28 60 21 f0    	mov    -0xfde9fd8(%eax),%esi
f010470a:	b9 11 00 00 00       	mov    $0x11,%ecx
f010470f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104712:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
      childenv->env_tf.tf_regs.reg_eax = 0; //attention
f0104714:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104717:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
      return childenv->env_id;
f010471e:	8b 58 48             	mov    0x48(%eax),%ebx
		 return sys_exofork();
f0104721:	e9 4c ff ff ff       	jmp    f0104672 <syscall+0x51>
       if((ret = envid2env(envid,&env,1))<0)
f0104726:	83 ec 04             	sub    $0x4,%esp
f0104729:	6a 01                	push   $0x1
f010472b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010472e:	50                   	push   %eax
f010472f:	ff 75 0c             	pushl  0xc(%ebp)
f0104732:	e8 71 e9 ff ff       	call   f01030a8 <envid2env>
f0104737:	89 c3                	mov    %eax,%ebx
f0104739:	83 c4 10             	add    $0x10,%esp
f010473c:	85 c0                	test   %eax,%eax
f010473e:	0f 88 2e ff ff ff    	js     f0104672 <syscall+0x51>
       if(env->env_status!=ENV_RUNNABLE && env->env_status!=ENV_NOT_RUNNABLE)
f0104744:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104747:	8b 42 54             	mov    0x54(%edx),%eax
f010474a:	83 e8 02             	sub    $0x2,%eax
f010474d:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f0104752:	75 0d                	jne    f0104761 <syscall+0x140>
       env->env_status = status;
f0104754:	89 72 54             	mov    %esi,0x54(%edx)
       return 0;
f0104757:	bb 00 00 00 00       	mov    $0x0,%ebx
f010475c:	e9 11 ff ff ff       	jmp    f0104672 <syscall+0x51>
	       return -E_INVAL;
f0104761:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		 return sys_env_set_status(a1,a2);
f0104766:	e9 07 ff ff ff       	jmp    f0104672 <syscall+0x51>
	if(envid2env(envid,&env,1)<0)
f010476b:	83 ec 04             	sub    $0x4,%esp
f010476e:	6a 01                	push   $0x1
f0104770:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104773:	50                   	push   %eax
f0104774:	ff 75 0c             	pushl  0xc(%ebp)
f0104777:	e8 2c e9 ff ff       	call   f01030a8 <envid2env>
f010477c:	83 c4 10             	add    $0x10,%esp
f010477f:	85 c0                	test   %eax,%eax
f0104781:	78 6e                	js     f01047f1 <syscall+0x1d0>
	if((uintptr_t)va>=UTOP || PGOFF(va))
f0104783:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0104789:	77 70                	ja     f01047fb <syscall+0x1da>
f010478b:	f7 c6 ff 0f 00 00    	test   $0xfff,%esi
f0104791:	75 72                	jne    f0104805 <syscall+0x1e4>
        if((perm&PTE_U)==0 || (perm&PTE_P)==0)
f0104793:	8b 45 14             	mov    0x14(%ebp),%eax
f0104796:	83 e0 05             	and    $0x5,%eax
f0104799:	83 f8 05             	cmp    $0x5,%eax
f010479c:	75 71                	jne    f010480f <syscall+0x1ee>
        if((perm&PTE_SYSCALL)==0 || perm & ~PTE_SYSCALL)
f010479e:	f7 45 14 07 0e 00 00 	testl  $0xe07,0x14(%ebp)
f01047a5:	74 72                	je     f0104819 <syscall+0x1f8>
f01047a7:	f7 45 14 f8 f1 ff ff 	testl  $0xfffff1f8,0x14(%ebp)
f01047ae:	75 73                	jne    f0104823 <syscall+0x202>
	pp = page_alloc(1);
f01047b0:	83 ec 0c             	sub    $0xc,%esp
f01047b3:	6a 01                	push   $0x1
f01047b5:	e8 ab c7 ff ff       	call   f0100f65 <page_alloc>
f01047ba:	89 c7                	mov    %eax,%edi
	if(!pp) return -E_NO_MEM;
f01047bc:	83 c4 10             	add    $0x10,%esp
f01047bf:	85 c0                	test   %eax,%eax
f01047c1:	74 6a                	je     f010482d <syscall+0x20c>
	ret=page_insert(env->env_pgdir,pp,va,perm);
f01047c3:	ff 75 14             	pushl  0x14(%ebp)
f01047c6:	56                   	push   %esi
f01047c7:	50                   	push   %eax
f01047c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01047cb:	ff 70 60             	pushl  0x60(%eax)
f01047ce:	e8 b7 ca ff ff       	call   f010128a <page_insert>
f01047d3:	89 c3                	mov    %eax,%ebx
        if(ret!=0){
f01047d5:	83 c4 10             	add    $0x10,%esp
f01047d8:	85 c0                	test   %eax,%eax
f01047da:	0f 84 92 fe ff ff    	je     f0104672 <syscall+0x51>
	  page_free(pp);
f01047e0:	83 ec 0c             	sub    $0xc,%esp
f01047e3:	57                   	push   %edi
f01047e4:	e8 ee c7 ff ff       	call   f0100fd7 <page_free>
f01047e9:	83 c4 10             	add    $0x10,%esp
f01047ec:	e9 81 fe ff ff       	jmp    f0104672 <syscall+0x51>
        	return -E_BAD_ENV;
f01047f1:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f01047f6:	e9 77 fe ff ff       	jmp    f0104672 <syscall+0x51>
		return -E_INVAL;
f01047fb:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104800:	e9 6d fe ff ff       	jmp    f0104672 <syscall+0x51>
f0104805:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010480a:	e9 63 fe ff ff       	jmp    f0104672 <syscall+0x51>
	        return -E_INVAL;
f010480f:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104814:	e9 59 fe ff ff       	jmp    f0104672 <syscall+0x51>
	        return -E_INVAL;
f0104819:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010481e:	e9 4f fe ff ff       	jmp    f0104672 <syscall+0x51>
f0104823:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104828:	e9 45 fe ff ff       	jmp    f0104672 <syscall+0x51>
	if(!pp) return -E_NO_MEM;
f010482d:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
		 return sys_page_alloc(a1,(void *)a2, a3);
f0104832:	e9 3b fe ff ff       	jmp    f0104672 <syscall+0x51>
	if(envid2env(srcenvid,&srcenv,1)<0 || envid2env(dstenvid,&dstenv,1)<0)
f0104837:	83 ec 04             	sub    $0x4,%esp
f010483a:	6a 01                	push   $0x1
f010483c:	8d 45 dc             	lea    -0x24(%ebp),%eax
f010483f:	50                   	push   %eax
f0104840:	ff 75 0c             	pushl  0xc(%ebp)
f0104843:	e8 60 e8 ff ff       	call   f01030a8 <envid2env>
f0104848:	83 c4 10             	add    $0x10,%esp
f010484b:	85 c0                	test   %eax,%eax
f010484d:	0f 88 a7 00 00 00    	js     f01048fa <syscall+0x2d9>
f0104853:	83 ec 04             	sub    $0x4,%esp
f0104856:	6a 01                	push   $0x1
f0104858:	8d 45 e0             	lea    -0x20(%ebp),%eax
f010485b:	50                   	push   %eax
f010485c:	ff 75 14             	pushl  0x14(%ebp)
f010485f:	e8 44 e8 ff ff       	call   f01030a8 <envid2env>
f0104864:	83 c4 10             	add    $0x10,%esp
f0104867:	85 c0                	test   %eax,%eax
f0104869:	0f 88 95 00 00 00    	js     f0104904 <syscall+0x2e3>
	if((uintptr_t)srcva >= UTOP || PGOFF(srcva) || (uintptr_t)dstva >= UTOP || PGOFF(dstva))
f010486f:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0104875:	0f 87 93 00 00 00    	ja     f010490e <syscall+0x2ed>
f010487b:	f7 c6 ff 0f 00 00    	test   $0xfff,%esi
f0104881:	0f 85 91 00 00 00    	jne    f0104918 <syscall+0x2f7>
f0104887:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f010488e:	0f 87 84 00 00 00    	ja     f0104918 <syscall+0x2f7>
f0104894:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f010489b:	0f 85 81 00 00 00    	jne    f0104922 <syscall+0x301>
	if((pp=page_lookup(srcenv->env_pgdir,srcva,&pte))<0)
f01048a1:	83 ec 04             	sub    $0x4,%esp
f01048a4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01048a7:	50                   	push   %eax
f01048a8:	56                   	push   %esi
f01048a9:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01048ac:	ff 70 60             	pushl  0x60(%eax)
f01048af:	e8 f7 c8 ff ff       	call   f01011ab <page_lookup>
	 if((perm&PTE_U)==0 || (perm&PTE_P)==0)
f01048b4:	8b 55 1c             	mov    0x1c(%ebp),%edx
f01048b7:	83 e2 05             	and    $0x5,%edx
f01048ba:	83 c4 10             	add    $0x10,%esp
f01048bd:	83 fa 05             	cmp    $0x5,%edx
f01048c0:	75 6a                	jne    f010492c <syscall+0x30b>
        if((perm&PTE_SYSCALL)==0 || perm & ~PTE_SYSCALL)
f01048c2:	f7 45 1c 07 0e 00 00 	testl  $0xe07,0x1c(%ebp)
f01048c9:	74 6b                	je     f0104936 <syscall+0x315>
f01048cb:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
f01048ce:	81 e3 f8 f1 ff ff    	and    $0xfffff1f8,%ebx
f01048d4:	75 6a                	jne    f0104940 <syscall+0x31f>
	if(page_insert(dstenv->env_pgdir,pp,dstva,perm)<0)
f01048d6:	ff 75 1c             	pushl  0x1c(%ebp)
f01048d9:	ff 75 18             	pushl  0x18(%ebp)
f01048dc:	50                   	push   %eax
f01048dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01048e0:	ff 70 60             	pushl  0x60(%eax)
f01048e3:	e8 a2 c9 ff ff       	call   f010128a <page_insert>
f01048e8:	83 c4 10             	add    $0x10,%esp
		return -E_NO_MEM;
f01048eb:	85 c0                	test   %eax,%eax
f01048ed:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01048f2:	0f 48 d8             	cmovs  %eax,%ebx
f01048f5:	e9 78 fd ff ff       	jmp    f0104672 <syscall+0x51>
		return -E_BAD_ENV;
f01048fa:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f01048ff:	e9 6e fd ff ff       	jmp    f0104672 <syscall+0x51>
f0104904:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104909:	e9 64 fd ff ff       	jmp    f0104672 <syscall+0x51>
		return -E_INVAL;
f010490e:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104913:	e9 5a fd ff ff       	jmp    f0104672 <syscall+0x51>
f0104918:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010491d:	e9 50 fd ff ff       	jmp    f0104672 <syscall+0x51>
f0104922:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104927:	e9 46 fd ff ff       	jmp    f0104672 <syscall+0x51>
                return -E_INVAL;
f010492c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104931:	e9 3c fd ff ff       	jmp    f0104672 <syscall+0x51>
                return -E_INVAL;
f0104936:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010493b:	e9 32 fd ff ff       	jmp    f0104672 <syscall+0x51>
f0104940:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104945:	e9 28 fd ff ff       	jmp    f0104672 <syscall+0x51>
	if(envid2env(envid,&env,1)<0)
f010494a:	83 ec 04             	sub    $0x4,%esp
f010494d:	6a 01                	push   $0x1
f010494f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104952:	50                   	push   %eax
f0104953:	ff 75 0c             	pushl  0xc(%ebp)
f0104956:	e8 4d e7 ff ff       	call   f01030a8 <envid2env>
f010495b:	83 c4 10             	add    $0x10,%esp
f010495e:	85 c0                	test   %eax,%eax
f0104960:	78 2c                	js     f010498e <syscall+0x36d>
	if((uintptr_t)va >= UTOP || PGOFF(va))
f0104962:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0104968:	77 2e                	ja     f0104998 <syscall+0x377>
f010496a:	f7 c6 ff 0f 00 00    	test   $0xfff,%esi
f0104970:	75 30                	jne    f01049a2 <syscall+0x381>
	page_remove(env->env_pgdir,va);
f0104972:	83 ec 08             	sub    $0x8,%esp
f0104975:	56                   	push   %esi
f0104976:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104979:	ff 70 60             	pushl  0x60(%eax)
f010497c:	e8 b9 c8 ff ff       	call   f010123a <page_remove>
f0104981:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104984:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104989:	e9 e4 fc ff ff       	jmp    f0104672 <syscall+0x51>
		return -E_BAD_ENV;
f010498e:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104993:	e9 da fc ff ff       	jmp    f0104672 <syscall+0x51>
		return -E_INVAL;
f0104998:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010499d:	e9 d0 fc ff ff       	jmp    f0104672 <syscall+0x51>
f01049a2:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		 return sys_page_unmap(a1,(void *)a2);
f01049a7:	e9 c6 fc ff ff       	jmp    f0104672 <syscall+0x51>
	if(envid2env(envid,&env,1)<0)
f01049ac:	83 ec 04             	sub    $0x4,%esp
f01049af:	6a 01                	push   $0x1
f01049b1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01049b4:	50                   	push   %eax
f01049b5:	ff 75 0c             	pushl  0xc(%ebp)
f01049b8:	e8 eb e6 ff ff       	call   f01030a8 <envid2env>
f01049bd:	83 c4 10             	add    $0x10,%esp
f01049c0:	85 c0                	test   %eax,%eax
f01049c2:	78 10                	js     f01049d4 <syscall+0x3b3>
	env->env_pgfault_upcall = func;
f01049c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01049c7:	89 70 64             	mov    %esi,0x64(%eax)
	return 0;
f01049ca:	bb 00 00 00 00       	mov    $0x0,%ebx
f01049cf:	e9 9e fc ff ff       	jmp    f0104672 <syscall+0x51>
		return -E_BAD_ENV;
f01049d4:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
		 return sys_env_set_pgfault_upcall(a1,(void *)a2);
f01049d9:	e9 94 fc ff ff       	jmp    f0104672 <syscall+0x51>
	if((r=envid2env(envid,&dstenv,0))<0){
f01049de:	83 ec 04             	sub    $0x4,%esp
f01049e1:	6a 00                	push   $0x0
f01049e3:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01049e6:	50                   	push   %eax
f01049e7:	ff 75 0c             	pushl  0xc(%ebp)
f01049ea:	e8 b9 e6 ff ff       	call   f01030a8 <envid2env>
f01049ef:	83 c4 10             	add    $0x10,%esp
f01049f2:	85 c0                	test   %eax,%eax
f01049f4:	0f 88 cb 00 00 00    	js     f0104ac5 <syscall+0x4a4>
        if(dstenv->env_ipc_recving!=true||dstenv->env_ipc_from!=0){
f01049fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01049fd:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0104a01:	0f 84 b3 01 00 00    	je     f0104bba <syscall+0x599>
f0104a07:	83 78 74 00          	cmpl   $0x0,0x74(%eax)
f0104a0b:	0f 85 b3 01 00 00    	jne    f0104bc4 <syscall+0x5a3>
	if(srcva<(void *)UTOP && PGOFF(srcva)){
f0104a11:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0104a18:	0f 87 0f 01 00 00    	ja     f0104b2d <syscall+0x50c>
f0104a1e:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f0104a25:	0f 85 b4 00 00 00    	jne    f0104adf <syscall+0x4be>
	   if((perm&PTE_U)==0 || (perm&PTE_P)==0){
f0104a2b:	8b 45 18             	mov    0x18(%ebp),%eax
f0104a2e:	83 e0 05             	and    $0x5,%eax
f0104a31:	83 f8 05             	cmp    $0x5,%eax
f0104a34:	0f 85 bf 00 00 00    	jne    f0104af9 <syscall+0x4d8>
           if((perm&PTE_SYSCALL)==0 || perm & ~PTE_SYSCALL){
f0104a3a:	f7 45 18 07 0e 00 00 	testl  $0xe07,0x18(%ebp)
f0104a41:	0f 84 cc 00 00 00    	je     f0104b13 <syscall+0x4f2>
f0104a47:	f7 45 18 f8 f1 ff ff 	testl  $0xfffff1f8,0x18(%ebp)
f0104a4e:	0f 85 bf 00 00 00    	jne    f0104b13 <syscall+0x4f2>
	pp=page_lookup(curenv->env_pgdir,srcva,&pte);
f0104a54:	e8 ca 14 00 00       	call   f0105f23 <cpunum>
f0104a59:	83 ec 04             	sub    $0x4,%esp
f0104a5c:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104a5f:	52                   	push   %edx
f0104a60:	ff 75 14             	pushl  0x14(%ebp)
f0104a63:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a66:	8b 80 28 60 21 f0    	mov    -0xfde9fd8(%eax),%eax
f0104a6c:	ff 70 60             	pushl  0x60(%eax)
f0104a6f:	e8 37 c7 ff ff       	call   f01011ab <page_lookup>
	if(srcva<(void *)UTOP && (pp==NULL)){
f0104a74:	83 c4 10             	add    $0x10,%esp
f0104a77:	85 c0                	test   %eax,%eax
f0104a79:	0f 84 07 01 00 00    	je     f0104b86 <syscall+0x565>
	if((srcva<(void *)UTOP)&&  (perm & PTE_W) && (*pte&PTE_W)==0)
f0104a7f:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0104a83:	74 0c                	je     f0104a91 <syscall+0x470>
f0104a85:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104a88:	f6 02 02             	testb  $0x2,(%edx)
f0104a8b:	0f 84 3d 01 00 00    	je     f0104bce <syscall+0x5ad>
	if(srcva<(void *)UTOP && dstenv->env_ipc_dstva!=0){
f0104a91:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104a94:	8b 4a 6c             	mov    0x6c(%edx),%ecx
f0104a97:	85 c9                	test   %ecx,%ecx
f0104a99:	0f 84 b1 00 00 00    	je     f0104b50 <syscall+0x52f>
	  if((r=page_insert(dstenv->env_pgdir,pp,dstenv->env_ipc_dstva,perm))<0){
f0104a9f:	ff 75 18             	pushl  0x18(%ebp)
f0104aa2:	51                   	push   %ecx
f0104aa3:	50                   	push   %eax
f0104aa4:	ff 72 60             	pushl  0x60(%edx)
f0104aa7:	e8 de c7 ff ff       	call   f010128a <page_insert>
f0104aac:	83 c4 10             	add    $0x10,%esp
f0104aaf:	85 c0                	test   %eax,%eax
f0104ab1:	0f 88 e9 00 00 00    	js     f0104ba0 <syscall+0x57f>
	    dstenv->env_ipc_perm = perm;
f0104ab7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104aba:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0104abd:	89 48 78             	mov    %ecx,0x78(%eax)
f0104ac0:	e9 8b 00 00 00       	jmp    f0104b50 <syscall+0x52f>
		cprintf("error in envid2env\n");
f0104ac5:	83 ec 0c             	sub    $0xc,%esp
f0104ac8:	68 4b 7c 10 f0       	push   $0xf0107c4b
f0104acd:	e8 76 ee ff ff       	call   f0103948 <cprintf>
f0104ad2:	83 c4 10             	add    $0x10,%esp
		return -E_BAD_ENV;
f0104ad5:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104ada:	e9 93 fb ff ff       	jmp    f0104672 <syscall+0x51>
		cprintf("error in PFOFF\n");
f0104adf:	83 ec 0c             	sub    $0xc,%esp
f0104ae2:	68 5f 7c 10 f0       	push   $0xf0107c5f
f0104ae7:	e8 5c ee ff ff       	call   f0103948 <cprintf>
f0104aec:	83 c4 10             	add    $0x10,%esp
		return -E_INVAL;
f0104aef:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104af4:	e9 79 fb ff ff       	jmp    f0104672 <syscall+0x51>
		   cprintf("error in perm\n");
f0104af9:	83 ec 0c             	sub    $0xc,%esp
f0104afc:	68 6f 7c 10 f0       	push   $0xf0107c6f
f0104b01:	e8 42 ee ff ff       	call   f0103948 <cprintf>
f0104b06:	83 c4 10             	add    $0x10,%esp
                return -E_INVAL;
f0104b09:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b0e:	e9 5f fb ff ff       	jmp    f0104672 <syscall+0x51>
		   cprintf("error in perm\n");
f0104b13:	83 ec 0c             	sub    $0xc,%esp
f0104b16:	68 6f 7c 10 f0       	push   $0xf0107c6f
f0104b1b:	e8 28 ee ff ff       	call   f0103948 <cprintf>
f0104b20:	83 c4 10             	add    $0x10,%esp
                return -E_INVAL;
f0104b23:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b28:	e9 45 fb ff ff       	jmp    f0104672 <syscall+0x51>
	pp=page_lookup(curenv->env_pgdir,srcva,&pte);
f0104b2d:	e8 f1 13 00 00       	call   f0105f23 <cpunum>
f0104b32:	83 ec 04             	sub    $0x4,%esp
f0104b35:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104b38:	52                   	push   %edx
f0104b39:	ff 75 14             	pushl  0x14(%ebp)
f0104b3c:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b3f:	8b 80 28 60 21 f0    	mov    -0xfde9fd8(%eax),%eax
f0104b45:	ff 70 60             	pushl  0x60(%eax)
f0104b48:	e8 5e c6 ff ff       	call   f01011ab <page_lookup>
f0104b4d:	83 c4 10             	add    $0x10,%esp
	dstenv->env_ipc_from = curenv->env_id;
f0104b50:	e8 ce 13 00 00       	call   f0105f23 <cpunum>
f0104b55:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104b58:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b5b:	8b 80 28 60 21 f0    	mov    -0xfde9fd8(%eax),%eax
f0104b61:	8b 40 48             	mov    0x48(%eax),%eax
f0104b64:	89 42 74             	mov    %eax,0x74(%edx)
	dstenv->env_ipc_recving =false;
f0104b67:	c6 42 68 00          	movb   $0x0,0x68(%edx)
	dstenv->env_ipc_value = value;
f0104b6b:	89 72 70             	mov    %esi,0x70(%edx)
	dstenv->env_status = ENV_RUNNABLE;
f0104b6e:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
	dstenv->env_tf.tf_regs.reg_eax = 0;
f0104b75:	c7 42 1c 00 00 00 00 	movl   $0x0,0x1c(%edx)
	return 0;
f0104b7c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104b81:	e9 ec fa ff ff       	jmp    f0104672 <syscall+0x51>
		cprintf("error in pp NULL\n");
f0104b86:	83 ec 0c             	sub    $0xc,%esp
f0104b89:	68 7e 7c 10 f0       	push   $0xf0107c7e
f0104b8e:	e8 b5 ed ff ff       	call   f0103948 <cprintf>
f0104b93:	83 c4 10             	add    $0x10,%esp
		return -E_INVAL;
f0104b96:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b9b:	e9 d2 fa ff ff       	jmp    f0104672 <syscall+0x51>
		  cprintf("error in page insert\n");
f0104ba0:	83 ec 0c             	sub    $0xc,%esp
f0104ba3:	68 90 7c 10 f0       	push   $0xf0107c90
f0104ba8:	e8 9b ed ff ff       	call   f0103948 <cprintf>
f0104bad:	83 c4 10             	add    $0x10,%esp
		  return -E_NO_MEM;
f0104bb0:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f0104bb5:	e9 b8 fa ff ff       	jmp    f0104672 <syscall+0x51>
		return -E_IPC_NOT_RECV;
f0104bba:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
f0104bbf:	e9 ae fa ff ff       	jmp    f0104672 <syscall+0x51>
f0104bc4:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
f0104bc9:	e9 a4 fa ff ff       	jmp    f0104672 <syscall+0x51>
		return -E_INVAL;
f0104bce:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		 return sys_ipc_try_send(a1,a2,(void *)a3,a4);
f0104bd3:	e9 9a fa ff ff       	jmp    f0104672 <syscall+0x51>
        if(dstva < (void *)UTOP && PGOFF(dstva)){
f0104bd8:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0104bdf:	77 23                	ja     f0104c04 <syscall+0x5e3>
f0104be1:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f0104be8:	74 1a                	je     f0104c04 <syscall+0x5e3>
		cprintf("sys_ipc_recv:dstva\n");
f0104bea:	83 ec 0c             	sub    $0xc,%esp
f0104bed:	68 a6 7c 10 f0       	push   $0xf0107ca6
f0104bf2:	e8 51 ed ff ff       	call   f0103948 <cprintf>
		 return sys_ipc_recv((void *)a1);
f0104bf7:	83 c4 10             	add    $0x10,%esp
f0104bfa:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104bff:	e9 6e fa ff ff       	jmp    f0104672 <syscall+0x51>
        curenv->env_ipc_recving = true;
f0104c04:	e8 1a 13 00 00       	call   f0105f23 <cpunum>
f0104c09:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c0c:	8b 80 28 60 21 f0    	mov    -0xfde9fd8(%eax),%eax
f0104c12:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_ipc_dstva = dstva;
f0104c16:	e8 08 13 00 00       	call   f0105f23 <cpunum>
f0104c1b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c1e:	8b 80 28 60 21 f0    	mov    -0xfde9fd8(%eax),%eax
f0104c24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104c27:	89 48 6c             	mov    %ecx,0x6c(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f0104c2a:	e8 f4 12 00 00       	call   f0105f23 <cpunum>
f0104c2f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c32:	8b 80 28 60 21 f0    	mov    -0xfde9fd8(%eax),%eax
f0104c38:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
        curenv->env_ipc_from = 0;
f0104c3f:	e8 df 12 00 00       	call   f0105f23 <cpunum>
f0104c44:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c47:	8b 80 28 60 21 f0    	mov    -0xfde9fd8(%eax),%eax
f0104c4d:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
	sched_yield();
f0104c54:	e8 31 f9 ff ff       	call   f010458a <sched_yield>
	if((r=envid2env(envid,&e,true))<0)
f0104c59:	83 ec 04             	sub    $0x4,%esp
f0104c5c:	6a 01                	push   $0x1
f0104c5e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104c61:	50                   	push   %eax
f0104c62:	ff 75 0c             	pushl  0xc(%ebp)
f0104c65:	e8 3e e4 ff ff       	call   f01030a8 <envid2env>
f0104c6a:	89 c3                	mov    %eax,%ebx
f0104c6c:	83 c4 10             	add    $0x10,%esp
f0104c6f:	85 c0                	test   %eax,%eax
f0104c71:	0f 88 fb f9 ff ff    	js     f0104672 <syscall+0x51>
	user_mem_assert(e,tf,sizeof(struct Trapframe),PTE_U);
f0104c77:	6a 04                	push   $0x4
f0104c79:	6a 44                	push   $0x44
f0104c7b:	56                   	push   %esi
f0104c7c:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104c7f:	e8 52 e3 ff ff       	call   f0102fd6 <user_mem_assert>
	tf->tf_eflags &= ~FL_IOPL_MASK;
f0104c84:	8b 46 38             	mov    0x38(%esi),%eax
f0104c87:	80 e4 cf             	and    $0xcf,%ah
f0104c8a:	80 cc 02             	or     $0x2,%ah
f0104c8d:	89 46 38             	mov    %eax,0x38(%esi)
	tf->tf_cs |= 3;
f0104c90:	66 83 4e 34 03       	orw    $0x3,0x34(%esi)
	e->env_tf = *tf;
f0104c95:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104c9a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104c9d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104c9f:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104ca2:	bb 00 00 00 00       	mov    $0x0,%ebx
		 return sys_env_set_trapframe((envid_t)a1,(struct Trapframe*)a2);
f0104ca7:	e9 c6 f9 ff ff       	jmp    f0104672 <syscall+0x51>
		return -E_INVAL;
f0104cac:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104cb1:	e9 bc f9 ff ff       	jmp    f0104672 <syscall+0x51>

f0104cb6 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104cb6:	55                   	push   %ebp
f0104cb7:	89 e5                	mov    %esp,%ebp
f0104cb9:	57                   	push   %edi
f0104cba:	56                   	push   %esi
f0104cbb:	53                   	push   %ebx
f0104cbc:	83 ec 14             	sub    $0x14,%esp
f0104cbf:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104cc2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104cc5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104cc8:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104ccb:	8b 32                	mov    (%edx),%esi
f0104ccd:	8b 01                	mov    (%ecx),%eax
f0104ccf:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104cd2:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104cd9:	eb 2f                	jmp    f0104d0a <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0104cdb:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0104cde:	39 c6                	cmp    %eax,%esi
f0104ce0:	7f 49                	jg     f0104d2b <stab_binsearch+0x75>
f0104ce2:	0f b6 0a             	movzbl (%edx),%ecx
f0104ce5:	83 ea 0c             	sub    $0xc,%edx
f0104ce8:	39 f9                	cmp    %edi,%ecx
f0104cea:	75 ef                	jne    f0104cdb <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104cec:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104cef:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104cf2:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104cf6:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104cf9:	73 35                	jae    f0104d30 <stab_binsearch+0x7a>
			*region_left = m;
f0104cfb:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104cfe:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f0104d00:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f0104d03:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0104d0a:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0104d0d:	7f 4e                	jg     f0104d5d <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f0104d0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104d12:	01 f0                	add    %esi,%eax
f0104d14:	89 c3                	mov    %eax,%ebx
f0104d16:	c1 eb 1f             	shr    $0x1f,%ebx
f0104d19:	01 c3                	add    %eax,%ebx
f0104d1b:	d1 fb                	sar    %ebx
f0104d1d:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104d20:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104d23:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0104d27:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f0104d29:	eb b3                	jmp    f0104cde <stab_binsearch+0x28>
			l = true_m + 1;
f0104d2b:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f0104d2e:	eb da                	jmp    f0104d0a <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0104d30:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104d33:	76 14                	jbe    f0104d49 <stab_binsearch+0x93>
			*region_right = m - 1;
f0104d35:	83 e8 01             	sub    $0x1,%eax
f0104d38:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104d3b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104d3e:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f0104d40:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104d47:	eb c1                	jmp    f0104d0a <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104d49:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104d4c:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0104d4e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104d52:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f0104d54:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104d5b:	eb ad                	jmp    f0104d0a <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0104d5d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104d61:	74 16                	je     f0104d79 <stab_binsearch+0xc3>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104d63:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104d66:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104d68:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104d6b:	8b 0e                	mov    (%esi),%ecx
f0104d6d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104d70:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0104d73:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f0104d77:	eb 12                	jmp    f0104d8b <stab_binsearch+0xd5>
		*region_right = *region_left - 1;
f0104d79:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104d7c:	8b 00                	mov    (%eax),%eax
f0104d7e:	83 e8 01             	sub    $0x1,%eax
f0104d81:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104d84:	89 07                	mov    %eax,(%edi)
f0104d86:	eb 16                	jmp    f0104d9e <stab_binsearch+0xe8>
		     l--)
f0104d88:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0104d8b:	39 c1                	cmp    %eax,%ecx
f0104d8d:	7d 0a                	jge    f0104d99 <stab_binsearch+0xe3>
		     l > *region_left && stabs[l].n_type != type;
f0104d8f:	0f b6 1a             	movzbl (%edx),%ebx
f0104d92:	83 ea 0c             	sub    $0xc,%edx
f0104d95:	39 fb                	cmp    %edi,%ebx
f0104d97:	75 ef                	jne    f0104d88 <stab_binsearch+0xd2>
			/* do nothing */;
		*region_left = l;
f0104d99:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104d9c:	89 07                	mov    %eax,(%edi)
	}
}
f0104d9e:	83 c4 14             	add    $0x14,%esp
f0104da1:	5b                   	pop    %ebx
f0104da2:	5e                   	pop    %esi
f0104da3:	5f                   	pop    %edi
f0104da4:	5d                   	pop    %ebp
f0104da5:	c3                   	ret    

f0104da6 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104da6:	55                   	push   %ebp
f0104da7:	89 e5                	mov    %esp,%ebp
f0104da9:	57                   	push   %edi
f0104daa:	56                   	push   %esi
f0104dab:	53                   	push   %ebx
f0104dac:	83 ec 4c             	sub    $0x4c,%esp
f0104daf:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104db2:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104db5:	c7 06 f4 7c 10 f0    	movl   $0xf0107cf4,(%esi)
	info->eip_line = 0;
f0104dbb:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0104dc2:	c7 46 08 f4 7c 10 f0 	movl   $0xf0107cf4,0x8(%esi)
	info->eip_fn_namelen = 9;
f0104dc9:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0104dd0:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0104dd3:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104dda:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0104de0:	0f 86 2e 01 00 00    	jbe    f0104f14 <debuginfo_eip+0x16e>
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104de6:	c7 45 b8 71 72 11 f0 	movl   $0xf0117271,-0x48(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0104ded:	c7 45 b4 15 3a 11 f0 	movl   $0xf0113a15,-0x4c(%ebp)
		stab_end = __STAB_END__;
f0104df4:	bb 14 3a 11 f0       	mov    $0xf0113a14,%ebx
		stabs = __STAB_BEGIN__;
f0104df9:	c7 45 bc 90 82 10 f0 	movl   $0xf0108290,-0x44(%ebp)
		if(user_mem_check(curenv,(void *)stabstr,stabstr_end-stabstr,PTE_U)<0)
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104e00:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0104e03:	39 4d b4             	cmp    %ecx,-0x4c(%ebp)
f0104e06:	0f 83 97 02 00 00    	jae    f01050a3 <debuginfo_eip+0x2fd>
f0104e0c:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f0104e10:	0f 85 94 02 00 00    	jne    f01050aa <debuginfo_eip+0x304>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104e16:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104e1d:	2b 5d bc             	sub    -0x44(%ebp),%ebx
f0104e20:	c1 fb 02             	sar    $0x2,%ebx
f0104e23:	69 c3 ab aa aa aa    	imul   $0xaaaaaaab,%ebx,%eax
f0104e29:	83 e8 01             	sub    $0x1,%eax
f0104e2c:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104e2f:	83 ec 08             	sub    $0x8,%esp
f0104e32:	57                   	push   %edi
f0104e33:	6a 64                	push   $0x64
f0104e35:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0104e38:	89 d1                	mov    %edx,%ecx
f0104e3a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104e3d:	8b 5d bc             	mov    -0x44(%ebp),%ebx
f0104e40:	89 d8                	mov    %ebx,%eax
f0104e42:	e8 6f fe ff ff       	call   f0104cb6 <stab_binsearch>
	if (lfile == 0)
f0104e47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e4a:	83 c4 10             	add    $0x10,%esp
f0104e4d:	85 c0                	test   %eax,%eax
f0104e4f:	0f 84 5c 02 00 00    	je     f01050b1 <debuginfo_eip+0x30b>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104e55:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104e58:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104e5b:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104e5e:	83 ec 08             	sub    $0x8,%esp
f0104e61:	57                   	push   %edi
f0104e62:	6a 24                	push   $0x24
f0104e64:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0104e67:	89 d1                	mov    %edx,%ecx
f0104e69:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104e6c:	89 d8                	mov    %ebx,%eax
f0104e6e:	e8 43 fe ff ff       	call   f0104cb6 <stab_binsearch>

	if (lfun <= rfun) {
f0104e73:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104e76:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104e79:	83 c4 10             	add    $0x10,%esp
f0104e7c:	39 d0                	cmp    %edx,%eax
f0104e7e:	0f 8f 3d 01 00 00    	jg     f0104fc1 <debuginfo_eip+0x21b>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104e84:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0104e87:	8d 1c 8b             	lea    (%ebx,%ecx,4),%ebx
f0104e8a:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
f0104e8d:	8b 1b                	mov    (%ebx),%ebx
f0104e8f:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0104e92:	2b 4d b4             	sub    -0x4c(%ebp),%ecx
f0104e95:	39 cb                	cmp    %ecx,%ebx
f0104e97:	73 06                	jae    f0104e9f <debuginfo_eip+0xf9>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104e99:	03 5d b4             	add    -0x4c(%ebp),%ebx
f0104e9c:	89 5e 08             	mov    %ebx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104e9f:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0104ea2:	8b 4b 08             	mov    0x8(%ebx),%ecx
f0104ea5:	89 4e 10             	mov    %ecx,0x10(%esi)
		addr -= info->eip_fn_addr;
f0104ea8:	29 cf                	sub    %ecx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0104eaa:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104ead:	89 55 d0             	mov    %edx,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104eb0:	83 ec 08             	sub    $0x8,%esp
f0104eb3:	6a 3a                	push   $0x3a
f0104eb5:	ff 76 08             	pushl  0x8(%esi)
f0104eb8:	e8 26 0a 00 00       	call   f01058e3 <strfind>
f0104ebd:	2b 46 08             	sub    0x8(%esi),%eax
f0104ec0:	89 46 0c             	mov    %eax,0xc(%esi)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
        stab_binsearch(stabs,&lline,&rline,N_SLINE,addr);
f0104ec3:	83 c4 08             	add    $0x8,%esp
f0104ec6:	57                   	push   %edi
f0104ec7:	6a 44                	push   $0x44
f0104ec9:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104ecc:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104ecf:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0104ed2:	89 f8                	mov    %edi,%eax
f0104ed4:	e8 dd fd ff ff       	call   f0104cb6 <stab_binsearch>
	if(lline<=rline){
f0104ed9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104edc:	83 c4 10             	add    $0x10,%esp
f0104edf:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0104ee2:	0f 8f ed 00 00 00    	jg     f0104fd5 <debuginfo_eip+0x22f>
           info->eip_line = stabs[lline].n_desc;
f0104ee8:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104eeb:	0f b7 44 87 06       	movzwl 0x6(%edi,%eax,4),%eax
f0104ef0:	89 46 04             	mov    %eax,0x4(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104ef3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104ef6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104ef9:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104efc:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0104eff:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f0104f03:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0104f07:	bf 01 00 00 00       	mov    $0x1,%edi
f0104f0c:	89 75 0c             	mov    %esi,0xc(%ebp)
f0104f0f:	e9 e1 00 00 00       	jmp    f0104ff5 <debuginfo_eip+0x24f>
		stabs = usd->stabs;
f0104f14:	8b 0d 00 00 20 00    	mov    0x200000,%ecx
f0104f1a:	89 4d bc             	mov    %ecx,-0x44(%ebp)
		stab_end = usd->stab_end;
f0104f1d:	8b 1d 04 00 20 00    	mov    0x200004,%ebx
		stabstr = usd->stabstr;
f0104f23:	a1 08 00 20 00       	mov    0x200008,%eax
f0104f28:	89 45 b4             	mov    %eax,-0x4c(%ebp)
		stabstr_end = usd->stabstr_end;
f0104f2b:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0104f31:	89 55 b8             	mov    %edx,-0x48(%ebp)
		if(user_mem_check(curenv,(void *)usd,sizeof(struct UserStabData),PTE_U)<0)
f0104f34:	e8 ea 0f 00 00       	call   f0105f23 <cpunum>
f0104f39:	6a 04                	push   $0x4
f0104f3b:	6a 10                	push   $0x10
f0104f3d:	68 00 00 20 00       	push   $0x200000
f0104f42:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f45:	ff b0 28 60 21 f0    	pushl  -0xfde9fd8(%eax)
f0104f4b:	e8 f6 df ff ff       	call   f0102f46 <user_mem_check>
f0104f50:	83 c4 10             	add    $0x10,%esp
f0104f53:	85 c0                	test   %eax,%eax
f0104f55:	0f 88 3a 01 00 00    	js     f0105095 <debuginfo_eip+0x2ef>
		if(user_mem_check(curenv,(void *)stabs,stab_end-stabs,PTE_U)<0)
f0104f5b:	e8 c3 0f 00 00       	call   f0105f23 <cpunum>
f0104f60:	6a 04                	push   $0x4
f0104f62:	89 da                	mov    %ebx,%edx
f0104f64:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0104f67:	29 ca                	sub    %ecx,%edx
f0104f69:	c1 fa 02             	sar    $0x2,%edx
f0104f6c:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0104f72:	52                   	push   %edx
f0104f73:	51                   	push   %ecx
f0104f74:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f77:	ff b0 28 60 21 f0    	pushl  -0xfde9fd8(%eax)
f0104f7d:	e8 c4 df ff ff       	call   f0102f46 <user_mem_check>
f0104f82:	83 c4 10             	add    $0x10,%esp
f0104f85:	85 c0                	test   %eax,%eax
f0104f87:	0f 88 0f 01 00 00    	js     f010509c <debuginfo_eip+0x2f6>
		if(user_mem_check(curenv,(void *)stabstr,stabstr_end-stabstr,PTE_U)<0)
f0104f8d:	e8 91 0f 00 00       	call   f0105f23 <cpunum>
f0104f92:	6a 04                	push   $0x4
f0104f94:	8b 55 b8             	mov    -0x48(%ebp),%edx
f0104f97:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
f0104f9a:	29 ca                	sub    %ecx,%edx
f0104f9c:	52                   	push   %edx
f0104f9d:	51                   	push   %ecx
f0104f9e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104fa1:	ff b0 28 60 21 f0    	pushl  -0xfde9fd8(%eax)
f0104fa7:	e8 9a df ff ff       	call   f0102f46 <user_mem_check>
f0104fac:	83 c4 10             	add    $0x10,%esp
f0104faf:	85 c0                	test   %eax,%eax
f0104fb1:	0f 89 49 fe ff ff    	jns    f0104e00 <debuginfo_eip+0x5a>
			return -1;
f0104fb7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104fbc:	e9 fc 00 00 00       	jmp    f01050bd <debuginfo_eip+0x317>
		info->eip_fn_addr = addr;
f0104fc1:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0104fc4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104fc7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0104fca:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104fcd:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104fd0:	e9 db fe ff ff       	jmp    f0104eb0 <debuginfo_eip+0x10a>
		cprintf("line not find\n");
f0104fd5:	83 ec 0c             	sub    $0xc,%esp
f0104fd8:	68 fe 7c 10 f0       	push   $0xf0107cfe
f0104fdd:	e8 66 e9 ff ff       	call   f0103948 <cprintf>
f0104fe2:	83 c4 10             	add    $0x10,%esp
f0104fe5:	e9 09 ff ff ff       	jmp    f0104ef3 <debuginfo_eip+0x14d>
f0104fea:	83 e8 01             	sub    $0x1,%eax
f0104fed:	83 ea 0c             	sub    $0xc,%edx
f0104ff0:	89 f9                	mov    %edi,%ecx
f0104ff2:	88 4d c4             	mov    %cl,-0x3c(%ebp)
f0104ff5:	89 45 c0             	mov    %eax,-0x40(%ebp)
	while (lline >= lfile
f0104ff8:	39 c3                	cmp    %eax,%ebx
f0104ffa:	7f 24                	jg     f0105020 <debuginfo_eip+0x27a>
	       && stabs[lline].n_type != N_SOL
f0104ffc:	0f b6 0a             	movzbl (%edx),%ecx
f0104fff:	80 f9 84             	cmp    $0x84,%cl
f0105002:	74 46                	je     f010504a <debuginfo_eip+0x2a4>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105004:	80 f9 64             	cmp    $0x64,%cl
f0105007:	75 e1                	jne    f0104fea <debuginfo_eip+0x244>
f0105009:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f010500d:	74 db                	je     f0104fea <debuginfo_eip+0x244>
f010500f:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105012:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0105016:	74 3b                	je     f0105053 <debuginfo_eip+0x2ad>
f0105018:	8b 7d c0             	mov    -0x40(%ebp),%edi
f010501b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010501e:	eb 33                	jmp    f0105053 <debuginfo_eip+0x2ad>
f0105020:	8b 75 0c             	mov    0xc(%ebp),%esi
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105023:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105026:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105029:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f010502e:	39 da                	cmp    %ebx,%edx
f0105030:	0f 8d 87 00 00 00    	jge    f01050bd <debuginfo_eip+0x317>
		for (lline = lfun + 1;
f0105036:	83 c2 01             	add    $0x1,%edx
f0105039:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010503c:	89 d0                	mov    %edx,%eax
f010503e:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0105041:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0105044:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f0105048:	eb 32                	jmp    f010507c <debuginfo_eip+0x2d6>
f010504a:	8b 75 0c             	mov    0xc(%ebp),%esi
f010504d:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0105051:	75 1d                	jne    f0105070 <debuginfo_eip+0x2ca>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0105053:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0105056:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0105059:	8b 14 87             	mov    (%edi,%eax,4),%edx
f010505c:	8b 45 b8             	mov    -0x48(%ebp),%eax
f010505f:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f0105062:	29 f8                	sub    %edi,%eax
f0105064:	39 c2                	cmp    %eax,%edx
f0105066:	73 bb                	jae    f0105023 <debuginfo_eip+0x27d>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0105068:	89 f8                	mov    %edi,%eax
f010506a:	01 d0                	add    %edx,%eax
f010506c:	89 06                	mov    %eax,(%esi)
f010506e:	eb b3                	jmp    f0105023 <debuginfo_eip+0x27d>
f0105070:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0105073:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0105076:	eb db                	jmp    f0105053 <debuginfo_eip+0x2ad>
			info->eip_fn_narg++;
f0105078:	83 46 14 01          	addl   $0x1,0x14(%esi)
		for (lline = lfun + 1;
f010507c:	39 c3                	cmp    %eax,%ebx
f010507e:	7e 38                	jle    f01050b8 <debuginfo_eip+0x312>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105080:	0f b6 0a             	movzbl (%edx),%ecx
f0105083:	83 c0 01             	add    $0x1,%eax
f0105086:	83 c2 0c             	add    $0xc,%edx
f0105089:	80 f9 a0             	cmp    $0xa0,%cl
f010508c:	74 ea                	je     f0105078 <debuginfo_eip+0x2d2>
	return 0;
f010508e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105093:	eb 28                	jmp    f01050bd <debuginfo_eip+0x317>
			return -1;
f0105095:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010509a:	eb 21                	jmp    f01050bd <debuginfo_eip+0x317>
			return -1;
f010509c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01050a1:	eb 1a                	jmp    f01050bd <debuginfo_eip+0x317>
		return -1;
f01050a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01050a8:	eb 13                	jmp    f01050bd <debuginfo_eip+0x317>
f01050aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01050af:	eb 0c                	jmp    f01050bd <debuginfo_eip+0x317>
		return -1;
f01050b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01050b6:	eb 05                	jmp    f01050bd <debuginfo_eip+0x317>
	return 0;
f01050b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01050bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01050c0:	5b                   	pop    %ebx
f01050c1:	5e                   	pop    %esi
f01050c2:	5f                   	pop    %edi
f01050c3:	5d                   	pop    %ebp
f01050c4:	c3                   	ret    

f01050c5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01050c5:	55                   	push   %ebp
f01050c6:	89 e5                	mov    %esp,%ebp
f01050c8:	57                   	push   %edi
f01050c9:	56                   	push   %esi
f01050ca:	53                   	push   %ebx
f01050cb:	83 ec 1c             	sub    $0x1c,%esp
f01050ce:	89 c7                	mov    %eax,%edi
f01050d0:	89 d6                	mov    %edx,%esi
f01050d2:	8b 45 08             	mov    0x8(%ebp),%eax
f01050d5:	8b 55 0c             	mov    0xc(%ebp),%edx
f01050d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01050db:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01050de:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01050e1:	bb 00 00 00 00       	mov    $0x0,%ebx
f01050e6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01050e9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f01050ec:	39 d3                	cmp    %edx,%ebx
f01050ee:	72 05                	jb     f01050f5 <printnum+0x30>
f01050f0:	39 45 10             	cmp    %eax,0x10(%ebp)
f01050f3:	77 7a                	ja     f010516f <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01050f5:	83 ec 0c             	sub    $0xc,%esp
f01050f8:	ff 75 18             	pushl  0x18(%ebp)
f01050fb:	8b 45 14             	mov    0x14(%ebp),%eax
f01050fe:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0105101:	53                   	push   %ebx
f0105102:	ff 75 10             	pushl  0x10(%ebp)
f0105105:	83 ec 08             	sub    $0x8,%esp
f0105108:	ff 75 e4             	pushl  -0x1c(%ebp)
f010510b:	ff 75 e0             	pushl  -0x20(%ebp)
f010510e:	ff 75 dc             	pushl  -0x24(%ebp)
f0105111:	ff 75 d8             	pushl  -0x28(%ebp)
f0105114:	e8 07 12 00 00       	call   f0106320 <__udivdi3>
f0105119:	83 c4 18             	add    $0x18,%esp
f010511c:	52                   	push   %edx
f010511d:	50                   	push   %eax
f010511e:	89 f2                	mov    %esi,%edx
f0105120:	89 f8                	mov    %edi,%eax
f0105122:	e8 9e ff ff ff       	call   f01050c5 <printnum>
f0105127:	83 c4 20             	add    $0x20,%esp
f010512a:	eb 13                	jmp    f010513f <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f010512c:	83 ec 08             	sub    $0x8,%esp
f010512f:	56                   	push   %esi
f0105130:	ff 75 18             	pushl  0x18(%ebp)
f0105133:	ff d7                	call   *%edi
f0105135:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0105138:	83 eb 01             	sub    $0x1,%ebx
f010513b:	85 db                	test   %ebx,%ebx
f010513d:	7f ed                	jg     f010512c <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010513f:	83 ec 08             	sub    $0x8,%esp
f0105142:	56                   	push   %esi
f0105143:	83 ec 04             	sub    $0x4,%esp
f0105146:	ff 75 e4             	pushl  -0x1c(%ebp)
f0105149:	ff 75 e0             	pushl  -0x20(%ebp)
f010514c:	ff 75 dc             	pushl  -0x24(%ebp)
f010514f:	ff 75 d8             	pushl  -0x28(%ebp)
f0105152:	e8 e9 12 00 00       	call   f0106440 <__umoddi3>
f0105157:	83 c4 14             	add    $0x14,%esp
f010515a:	0f be 80 0d 7d 10 f0 	movsbl -0xfef82f3(%eax),%eax
f0105161:	50                   	push   %eax
f0105162:	ff d7                	call   *%edi
}
f0105164:	83 c4 10             	add    $0x10,%esp
f0105167:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010516a:	5b                   	pop    %ebx
f010516b:	5e                   	pop    %esi
f010516c:	5f                   	pop    %edi
f010516d:	5d                   	pop    %ebp
f010516e:	c3                   	ret    
f010516f:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0105172:	eb c4                	jmp    f0105138 <printnum+0x73>

f0105174 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105174:	55                   	push   %ebp
f0105175:	89 e5                	mov    %esp,%ebp
f0105177:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f010517a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f010517e:	8b 10                	mov    (%eax),%edx
f0105180:	3b 50 04             	cmp    0x4(%eax),%edx
f0105183:	73 0a                	jae    f010518f <sprintputch+0x1b>
		*b->buf++ = ch;
f0105185:	8d 4a 01             	lea    0x1(%edx),%ecx
f0105188:	89 08                	mov    %ecx,(%eax)
f010518a:	8b 45 08             	mov    0x8(%ebp),%eax
f010518d:	88 02                	mov    %al,(%edx)
}
f010518f:	5d                   	pop    %ebp
f0105190:	c3                   	ret    

f0105191 <printfmt>:
{
f0105191:	55                   	push   %ebp
f0105192:	89 e5                	mov    %esp,%ebp
f0105194:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0105197:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010519a:	50                   	push   %eax
f010519b:	ff 75 10             	pushl  0x10(%ebp)
f010519e:	ff 75 0c             	pushl  0xc(%ebp)
f01051a1:	ff 75 08             	pushl  0x8(%ebp)
f01051a4:	e8 05 00 00 00       	call   f01051ae <vprintfmt>
}
f01051a9:	83 c4 10             	add    $0x10,%esp
f01051ac:	c9                   	leave  
f01051ad:	c3                   	ret    

f01051ae <vprintfmt>:
{
f01051ae:	55                   	push   %ebp
f01051af:	89 e5                	mov    %esp,%ebp
f01051b1:	57                   	push   %edi
f01051b2:	56                   	push   %esi
f01051b3:	53                   	push   %ebx
f01051b4:	83 ec 2c             	sub    $0x2c,%esp
f01051b7:	8b 75 08             	mov    0x8(%ebp),%esi
f01051ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01051bd:	8b 7d 10             	mov    0x10(%ebp),%edi
f01051c0:	e9 c1 03 00 00       	jmp    f0105586 <vprintfmt+0x3d8>
		padc = ' ';
f01051c5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f01051c9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f01051d0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
f01051d7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f01051de:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f01051e3:	8d 47 01             	lea    0x1(%edi),%eax
f01051e6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01051e9:	0f b6 17             	movzbl (%edi),%edx
f01051ec:	8d 42 dd             	lea    -0x23(%edx),%eax
f01051ef:	3c 55                	cmp    $0x55,%al
f01051f1:	0f 87 12 04 00 00    	ja     f0105609 <vprintfmt+0x45b>
f01051f7:	0f b6 c0             	movzbl %al,%eax
f01051fa:	ff 24 85 40 7e 10 f0 	jmp    *-0xfef81c0(,%eax,4)
f0105201:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0105204:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0105208:	eb d9                	jmp    f01051e3 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f010520a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f010520d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0105211:	eb d0                	jmp    f01051e3 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f0105213:	0f b6 d2             	movzbl %dl,%edx
f0105216:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0105219:	b8 00 00 00 00       	mov    $0x0,%eax
f010521e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f0105221:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0105224:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0105228:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f010522b:	8d 4a d0             	lea    -0x30(%edx),%ecx
f010522e:	83 f9 09             	cmp    $0x9,%ecx
f0105231:	77 55                	ja     f0105288 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
f0105233:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f0105236:	eb e9                	jmp    f0105221 <vprintfmt+0x73>
			precision = va_arg(ap, int);
f0105238:	8b 45 14             	mov    0x14(%ebp),%eax
f010523b:	8b 00                	mov    (%eax),%eax
f010523d:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0105240:	8b 45 14             	mov    0x14(%ebp),%eax
f0105243:	8d 40 04             	lea    0x4(%eax),%eax
f0105246:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0105249:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f010524c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105250:	79 91                	jns    f01051e3 <vprintfmt+0x35>
				width = precision, precision = -1;
f0105252:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105255:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105258:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f010525f:	eb 82                	jmp    f01051e3 <vprintfmt+0x35>
f0105261:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105264:	85 c0                	test   %eax,%eax
f0105266:	ba 00 00 00 00       	mov    $0x0,%edx
f010526b:	0f 49 d0             	cmovns %eax,%edx
f010526e:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0105271:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105274:	e9 6a ff ff ff       	jmp    f01051e3 <vprintfmt+0x35>
f0105279:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f010527c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0105283:	e9 5b ff ff ff       	jmp    f01051e3 <vprintfmt+0x35>
f0105288:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f010528b:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010528e:	eb bc                	jmp    f010524c <vprintfmt+0x9e>
			lflag++;
f0105290:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0105293:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0105296:	e9 48 ff ff ff       	jmp    f01051e3 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
f010529b:	8b 45 14             	mov    0x14(%ebp),%eax
f010529e:	8d 78 04             	lea    0x4(%eax),%edi
f01052a1:	83 ec 08             	sub    $0x8,%esp
f01052a4:	53                   	push   %ebx
f01052a5:	ff 30                	pushl  (%eax)
f01052a7:	ff d6                	call   *%esi
			break;
f01052a9:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f01052ac:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f01052af:	e9 cf 02 00 00       	jmp    f0105583 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
f01052b4:	8b 45 14             	mov    0x14(%ebp),%eax
f01052b7:	8d 78 04             	lea    0x4(%eax),%edi
f01052ba:	8b 00                	mov    (%eax),%eax
f01052bc:	99                   	cltd   
f01052bd:	31 d0                	xor    %edx,%eax
f01052bf:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01052c1:	83 f8 0f             	cmp    $0xf,%eax
f01052c4:	7f 23                	jg     f01052e9 <vprintfmt+0x13b>
f01052c6:	8b 14 85 a0 7f 10 f0 	mov    -0xfef8060(,%eax,4),%edx
f01052cd:	85 d2                	test   %edx,%edx
f01052cf:	74 18                	je     f01052e9 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
f01052d1:	52                   	push   %edx
f01052d2:	68 81 74 10 f0       	push   $0xf0107481
f01052d7:	53                   	push   %ebx
f01052d8:	56                   	push   %esi
f01052d9:	e8 b3 fe ff ff       	call   f0105191 <printfmt>
f01052de:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01052e1:	89 7d 14             	mov    %edi,0x14(%ebp)
f01052e4:	e9 9a 02 00 00       	jmp    f0105583 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
f01052e9:	50                   	push   %eax
f01052ea:	68 25 7d 10 f0       	push   $0xf0107d25
f01052ef:	53                   	push   %ebx
f01052f0:	56                   	push   %esi
f01052f1:	e8 9b fe ff ff       	call   f0105191 <printfmt>
f01052f6:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01052f9:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f01052fc:	e9 82 02 00 00       	jmp    f0105583 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
f0105301:	8b 45 14             	mov    0x14(%ebp),%eax
f0105304:	83 c0 04             	add    $0x4,%eax
f0105307:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010530a:	8b 45 14             	mov    0x14(%ebp),%eax
f010530d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f010530f:	85 ff                	test   %edi,%edi
f0105311:	b8 1e 7d 10 f0       	mov    $0xf0107d1e,%eax
f0105316:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0105319:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010531d:	0f 8e bd 00 00 00    	jle    f01053e0 <vprintfmt+0x232>
f0105323:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0105327:	75 0e                	jne    f0105337 <vprintfmt+0x189>
f0105329:	89 75 08             	mov    %esi,0x8(%ebp)
f010532c:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010532f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105332:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105335:	eb 6d                	jmp    f01053a4 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105337:	83 ec 08             	sub    $0x8,%esp
f010533a:	ff 75 d0             	pushl  -0x30(%ebp)
f010533d:	57                   	push   %edi
f010533e:	e8 5c 04 00 00       	call   f010579f <strnlen>
f0105343:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105346:	29 c1                	sub    %eax,%ecx
f0105348:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f010534b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f010534e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0105352:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105355:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0105358:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f010535a:	eb 0f                	jmp    f010536b <vprintfmt+0x1bd>
					putch(padc, putdat);
f010535c:	83 ec 08             	sub    $0x8,%esp
f010535f:	53                   	push   %ebx
f0105360:	ff 75 e0             	pushl  -0x20(%ebp)
f0105363:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0105365:	83 ef 01             	sub    $0x1,%edi
f0105368:	83 c4 10             	add    $0x10,%esp
f010536b:	85 ff                	test   %edi,%edi
f010536d:	7f ed                	jg     f010535c <vprintfmt+0x1ae>
f010536f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0105372:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0105375:	85 c9                	test   %ecx,%ecx
f0105377:	b8 00 00 00 00       	mov    $0x0,%eax
f010537c:	0f 49 c1             	cmovns %ecx,%eax
f010537f:	29 c1                	sub    %eax,%ecx
f0105381:	89 75 08             	mov    %esi,0x8(%ebp)
f0105384:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105387:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f010538a:	89 cb                	mov    %ecx,%ebx
f010538c:	eb 16                	jmp    f01053a4 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
f010538e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0105392:	75 31                	jne    f01053c5 <vprintfmt+0x217>
					putch(ch, putdat);
f0105394:	83 ec 08             	sub    $0x8,%esp
f0105397:	ff 75 0c             	pushl  0xc(%ebp)
f010539a:	50                   	push   %eax
f010539b:	ff 55 08             	call   *0x8(%ebp)
f010539e:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01053a1:	83 eb 01             	sub    $0x1,%ebx
f01053a4:	83 c7 01             	add    $0x1,%edi
f01053a7:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f01053ab:	0f be c2             	movsbl %dl,%eax
f01053ae:	85 c0                	test   %eax,%eax
f01053b0:	74 59                	je     f010540b <vprintfmt+0x25d>
f01053b2:	85 f6                	test   %esi,%esi
f01053b4:	78 d8                	js     f010538e <vprintfmt+0x1e0>
f01053b6:	83 ee 01             	sub    $0x1,%esi
f01053b9:	79 d3                	jns    f010538e <vprintfmt+0x1e0>
f01053bb:	89 df                	mov    %ebx,%edi
f01053bd:	8b 75 08             	mov    0x8(%ebp),%esi
f01053c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01053c3:	eb 37                	jmp    f01053fc <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
f01053c5:	0f be d2             	movsbl %dl,%edx
f01053c8:	83 ea 20             	sub    $0x20,%edx
f01053cb:	83 fa 5e             	cmp    $0x5e,%edx
f01053ce:	76 c4                	jbe    f0105394 <vprintfmt+0x1e6>
					putch('?', putdat);
f01053d0:	83 ec 08             	sub    $0x8,%esp
f01053d3:	ff 75 0c             	pushl  0xc(%ebp)
f01053d6:	6a 3f                	push   $0x3f
f01053d8:	ff 55 08             	call   *0x8(%ebp)
f01053db:	83 c4 10             	add    $0x10,%esp
f01053de:	eb c1                	jmp    f01053a1 <vprintfmt+0x1f3>
f01053e0:	89 75 08             	mov    %esi,0x8(%ebp)
f01053e3:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01053e6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01053e9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01053ec:	eb b6                	jmp    f01053a4 <vprintfmt+0x1f6>
				putch(' ', putdat);
f01053ee:	83 ec 08             	sub    $0x8,%esp
f01053f1:	53                   	push   %ebx
f01053f2:	6a 20                	push   $0x20
f01053f4:	ff d6                	call   *%esi
			for (; width > 0; width--)
f01053f6:	83 ef 01             	sub    $0x1,%edi
f01053f9:	83 c4 10             	add    $0x10,%esp
f01053fc:	85 ff                	test   %edi,%edi
f01053fe:	7f ee                	jg     f01053ee <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
f0105400:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0105403:	89 45 14             	mov    %eax,0x14(%ebp)
f0105406:	e9 78 01 00 00       	jmp    f0105583 <vprintfmt+0x3d5>
f010540b:	89 df                	mov    %ebx,%edi
f010540d:	8b 75 08             	mov    0x8(%ebp),%esi
f0105410:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105413:	eb e7                	jmp    f01053fc <vprintfmt+0x24e>
	if (lflag >= 2)
f0105415:	83 f9 01             	cmp    $0x1,%ecx
f0105418:	7e 3f                	jle    f0105459 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
f010541a:	8b 45 14             	mov    0x14(%ebp),%eax
f010541d:	8b 50 04             	mov    0x4(%eax),%edx
f0105420:	8b 00                	mov    (%eax),%eax
f0105422:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105425:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105428:	8b 45 14             	mov    0x14(%ebp),%eax
f010542b:	8d 40 08             	lea    0x8(%eax),%eax
f010542e:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0105431:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105435:	79 5c                	jns    f0105493 <vprintfmt+0x2e5>
				putch('-', putdat);
f0105437:	83 ec 08             	sub    $0x8,%esp
f010543a:	53                   	push   %ebx
f010543b:	6a 2d                	push   $0x2d
f010543d:	ff d6                	call   *%esi
				num = -(long long) num;
f010543f:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105442:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0105445:	f7 da                	neg    %edx
f0105447:	83 d1 00             	adc    $0x0,%ecx
f010544a:	f7 d9                	neg    %ecx
f010544c:	83 c4 10             	add    $0x10,%esp
			base = 10;
f010544f:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105454:	e9 10 01 00 00       	jmp    f0105569 <vprintfmt+0x3bb>
	else if (lflag)
f0105459:	85 c9                	test   %ecx,%ecx
f010545b:	75 1b                	jne    f0105478 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
f010545d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105460:	8b 00                	mov    (%eax),%eax
f0105462:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105465:	89 c1                	mov    %eax,%ecx
f0105467:	c1 f9 1f             	sar    $0x1f,%ecx
f010546a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010546d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105470:	8d 40 04             	lea    0x4(%eax),%eax
f0105473:	89 45 14             	mov    %eax,0x14(%ebp)
f0105476:	eb b9                	jmp    f0105431 <vprintfmt+0x283>
		return va_arg(*ap, long);
f0105478:	8b 45 14             	mov    0x14(%ebp),%eax
f010547b:	8b 00                	mov    (%eax),%eax
f010547d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105480:	89 c1                	mov    %eax,%ecx
f0105482:	c1 f9 1f             	sar    $0x1f,%ecx
f0105485:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105488:	8b 45 14             	mov    0x14(%ebp),%eax
f010548b:	8d 40 04             	lea    0x4(%eax),%eax
f010548e:	89 45 14             	mov    %eax,0x14(%ebp)
f0105491:	eb 9e                	jmp    f0105431 <vprintfmt+0x283>
			num = getint(&ap, lflag);
f0105493:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105496:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f0105499:	b8 0a 00 00 00       	mov    $0xa,%eax
f010549e:	e9 c6 00 00 00       	jmp    f0105569 <vprintfmt+0x3bb>
	if (lflag >= 2)
f01054a3:	83 f9 01             	cmp    $0x1,%ecx
f01054a6:	7e 18                	jle    f01054c0 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
f01054a8:	8b 45 14             	mov    0x14(%ebp),%eax
f01054ab:	8b 10                	mov    (%eax),%edx
f01054ad:	8b 48 04             	mov    0x4(%eax),%ecx
f01054b0:	8d 40 08             	lea    0x8(%eax),%eax
f01054b3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01054b6:	b8 0a 00 00 00       	mov    $0xa,%eax
f01054bb:	e9 a9 00 00 00       	jmp    f0105569 <vprintfmt+0x3bb>
	else if (lflag)
f01054c0:	85 c9                	test   %ecx,%ecx
f01054c2:	75 1a                	jne    f01054de <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
f01054c4:	8b 45 14             	mov    0x14(%ebp),%eax
f01054c7:	8b 10                	mov    (%eax),%edx
f01054c9:	b9 00 00 00 00       	mov    $0x0,%ecx
f01054ce:	8d 40 04             	lea    0x4(%eax),%eax
f01054d1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01054d4:	b8 0a 00 00 00       	mov    $0xa,%eax
f01054d9:	e9 8b 00 00 00       	jmp    f0105569 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
f01054de:	8b 45 14             	mov    0x14(%ebp),%eax
f01054e1:	8b 10                	mov    (%eax),%edx
f01054e3:	b9 00 00 00 00       	mov    $0x0,%ecx
f01054e8:	8d 40 04             	lea    0x4(%eax),%eax
f01054eb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01054ee:	b8 0a 00 00 00       	mov    $0xa,%eax
f01054f3:	eb 74                	jmp    f0105569 <vprintfmt+0x3bb>
	if (lflag >= 2)
f01054f5:	83 f9 01             	cmp    $0x1,%ecx
f01054f8:	7e 15                	jle    f010550f <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
f01054fa:	8b 45 14             	mov    0x14(%ebp),%eax
f01054fd:	8b 10                	mov    (%eax),%edx
f01054ff:	8b 48 04             	mov    0x4(%eax),%ecx
f0105502:	8d 40 08             	lea    0x8(%eax),%eax
f0105505:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0105508:	b8 08 00 00 00       	mov    $0x8,%eax
f010550d:	eb 5a                	jmp    f0105569 <vprintfmt+0x3bb>
	else if (lflag)
f010550f:	85 c9                	test   %ecx,%ecx
f0105511:	75 17                	jne    f010552a <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
f0105513:	8b 45 14             	mov    0x14(%ebp),%eax
f0105516:	8b 10                	mov    (%eax),%edx
f0105518:	b9 00 00 00 00       	mov    $0x0,%ecx
f010551d:	8d 40 04             	lea    0x4(%eax),%eax
f0105520:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0105523:	b8 08 00 00 00       	mov    $0x8,%eax
f0105528:	eb 3f                	jmp    f0105569 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
f010552a:	8b 45 14             	mov    0x14(%ebp),%eax
f010552d:	8b 10                	mov    (%eax),%edx
f010552f:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105534:	8d 40 04             	lea    0x4(%eax),%eax
f0105537:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f010553a:	b8 08 00 00 00       	mov    $0x8,%eax
f010553f:	eb 28                	jmp    f0105569 <vprintfmt+0x3bb>
			putch('0', putdat);
f0105541:	83 ec 08             	sub    $0x8,%esp
f0105544:	53                   	push   %ebx
f0105545:	6a 30                	push   $0x30
f0105547:	ff d6                	call   *%esi
			putch('x', putdat);
f0105549:	83 c4 08             	add    $0x8,%esp
f010554c:	53                   	push   %ebx
f010554d:	6a 78                	push   $0x78
f010554f:	ff d6                	call   *%esi
			num = (unsigned long long)
f0105551:	8b 45 14             	mov    0x14(%ebp),%eax
f0105554:	8b 10                	mov    (%eax),%edx
f0105556:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f010555b:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f010555e:	8d 40 04             	lea    0x4(%eax),%eax
f0105561:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105564:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f0105569:	83 ec 0c             	sub    $0xc,%esp
f010556c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0105570:	57                   	push   %edi
f0105571:	ff 75 e0             	pushl  -0x20(%ebp)
f0105574:	50                   	push   %eax
f0105575:	51                   	push   %ecx
f0105576:	52                   	push   %edx
f0105577:	89 da                	mov    %ebx,%edx
f0105579:	89 f0                	mov    %esi,%eax
f010557b:	e8 45 fb ff ff       	call   f01050c5 <printnum>
			break;
f0105580:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f0105583:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105586:	83 c7 01             	add    $0x1,%edi
f0105589:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f010558d:	83 f8 25             	cmp    $0x25,%eax
f0105590:	0f 84 2f fc ff ff    	je     f01051c5 <vprintfmt+0x17>
			if (ch == '\0')
f0105596:	85 c0                	test   %eax,%eax
f0105598:	0f 84 8b 00 00 00    	je     f0105629 <vprintfmt+0x47b>
			putch(ch, putdat);
f010559e:	83 ec 08             	sub    $0x8,%esp
f01055a1:	53                   	push   %ebx
f01055a2:	50                   	push   %eax
f01055a3:	ff d6                	call   *%esi
f01055a5:	83 c4 10             	add    $0x10,%esp
f01055a8:	eb dc                	jmp    f0105586 <vprintfmt+0x3d8>
	if (lflag >= 2)
f01055aa:	83 f9 01             	cmp    $0x1,%ecx
f01055ad:	7e 15                	jle    f01055c4 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
f01055af:	8b 45 14             	mov    0x14(%ebp),%eax
f01055b2:	8b 10                	mov    (%eax),%edx
f01055b4:	8b 48 04             	mov    0x4(%eax),%ecx
f01055b7:	8d 40 08             	lea    0x8(%eax),%eax
f01055ba:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01055bd:	b8 10 00 00 00       	mov    $0x10,%eax
f01055c2:	eb a5                	jmp    f0105569 <vprintfmt+0x3bb>
	else if (lflag)
f01055c4:	85 c9                	test   %ecx,%ecx
f01055c6:	75 17                	jne    f01055df <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
f01055c8:	8b 45 14             	mov    0x14(%ebp),%eax
f01055cb:	8b 10                	mov    (%eax),%edx
f01055cd:	b9 00 00 00 00       	mov    $0x0,%ecx
f01055d2:	8d 40 04             	lea    0x4(%eax),%eax
f01055d5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01055d8:	b8 10 00 00 00       	mov    $0x10,%eax
f01055dd:	eb 8a                	jmp    f0105569 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
f01055df:	8b 45 14             	mov    0x14(%ebp),%eax
f01055e2:	8b 10                	mov    (%eax),%edx
f01055e4:	b9 00 00 00 00       	mov    $0x0,%ecx
f01055e9:	8d 40 04             	lea    0x4(%eax),%eax
f01055ec:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01055ef:	b8 10 00 00 00       	mov    $0x10,%eax
f01055f4:	e9 70 ff ff ff       	jmp    f0105569 <vprintfmt+0x3bb>
			putch(ch, putdat);
f01055f9:	83 ec 08             	sub    $0x8,%esp
f01055fc:	53                   	push   %ebx
f01055fd:	6a 25                	push   $0x25
f01055ff:	ff d6                	call   *%esi
			break;
f0105601:	83 c4 10             	add    $0x10,%esp
f0105604:	e9 7a ff ff ff       	jmp    f0105583 <vprintfmt+0x3d5>
			putch('%', putdat);
f0105609:	83 ec 08             	sub    $0x8,%esp
f010560c:	53                   	push   %ebx
f010560d:	6a 25                	push   $0x25
f010560f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105611:	83 c4 10             	add    $0x10,%esp
f0105614:	89 f8                	mov    %edi,%eax
f0105616:	eb 03                	jmp    f010561b <vprintfmt+0x46d>
f0105618:	83 e8 01             	sub    $0x1,%eax
f010561b:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f010561f:	75 f7                	jne    f0105618 <vprintfmt+0x46a>
f0105621:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105624:	e9 5a ff ff ff       	jmp    f0105583 <vprintfmt+0x3d5>
}
f0105629:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010562c:	5b                   	pop    %ebx
f010562d:	5e                   	pop    %esi
f010562e:	5f                   	pop    %edi
f010562f:	5d                   	pop    %ebp
f0105630:	c3                   	ret    

f0105631 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105631:	55                   	push   %ebp
f0105632:	89 e5                	mov    %esp,%ebp
f0105634:	83 ec 18             	sub    $0x18,%esp
f0105637:	8b 45 08             	mov    0x8(%ebp),%eax
f010563a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010563d:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105640:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105644:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105647:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010564e:	85 c0                	test   %eax,%eax
f0105650:	74 26                	je     f0105678 <vsnprintf+0x47>
f0105652:	85 d2                	test   %edx,%edx
f0105654:	7e 22                	jle    f0105678 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105656:	ff 75 14             	pushl  0x14(%ebp)
f0105659:	ff 75 10             	pushl  0x10(%ebp)
f010565c:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010565f:	50                   	push   %eax
f0105660:	68 74 51 10 f0       	push   $0xf0105174
f0105665:	e8 44 fb ff ff       	call   f01051ae <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010566a:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010566d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105670:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105673:	83 c4 10             	add    $0x10,%esp
}
f0105676:	c9                   	leave  
f0105677:	c3                   	ret    
		return -E_INVAL;
f0105678:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010567d:	eb f7                	jmp    f0105676 <vsnprintf+0x45>

f010567f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010567f:	55                   	push   %ebp
f0105680:	89 e5                	mov    %esp,%ebp
f0105682:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105685:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105688:	50                   	push   %eax
f0105689:	ff 75 10             	pushl  0x10(%ebp)
f010568c:	ff 75 0c             	pushl  0xc(%ebp)
f010568f:	ff 75 08             	pushl  0x8(%ebp)
f0105692:	e8 9a ff ff ff       	call   f0105631 <vsnprintf>
	va_end(ap);

	return rc;
}
f0105697:	c9                   	leave  
f0105698:	c3                   	ret    

f0105699 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105699:	55                   	push   %ebp
f010569a:	89 e5                	mov    %esp,%ebp
f010569c:	57                   	push   %edi
f010569d:	56                   	push   %esi
f010569e:	53                   	push   %ebx
f010569f:	83 ec 0c             	sub    $0xc,%esp
f01056a2:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f01056a5:	85 c0                	test   %eax,%eax
f01056a7:	74 11                	je     f01056ba <readline+0x21>
		cprintf("%s", prompt);
f01056a9:	83 ec 08             	sub    $0x8,%esp
f01056ac:	50                   	push   %eax
f01056ad:	68 81 74 10 f0       	push   $0xf0107481
f01056b2:	e8 91 e2 ff ff       	call   f0103948 <cprintf>
f01056b7:	83 c4 10             	add    $0x10,%esp
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f01056ba:	83 ec 0c             	sub    $0xc,%esp
f01056bd:	6a 00                	push   $0x0
f01056bf:	e8 fa b0 ff ff       	call   f01007be <iscons>
f01056c4:	89 c7                	mov    %eax,%edi
f01056c6:	83 c4 10             	add    $0x10,%esp
	i = 0;
f01056c9:	be 00 00 00 00       	mov    $0x0,%esi
f01056ce:	eb 4b                	jmp    f010571b <readline+0x82>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f01056d0:	b8 00 00 00 00       	mov    $0x0,%eax
			if (c != -E_EOF)
f01056d5:	83 fb f8             	cmp    $0xfffffff8,%ebx
f01056d8:	75 08                	jne    f01056e2 <readline+0x49>
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f01056da:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01056dd:	5b                   	pop    %ebx
f01056de:	5e                   	pop    %esi
f01056df:	5f                   	pop    %edi
f01056e0:	5d                   	pop    %ebp
f01056e1:	c3                   	ret    
				cprintf("read error: %e\n", c);
f01056e2:	83 ec 08             	sub    $0x8,%esp
f01056e5:	53                   	push   %ebx
f01056e6:	68 ff 7f 10 f0       	push   $0xf0107fff
f01056eb:	e8 58 e2 ff ff       	call   f0103948 <cprintf>
f01056f0:	83 c4 10             	add    $0x10,%esp
			return NULL;
f01056f3:	b8 00 00 00 00       	mov    $0x0,%eax
f01056f8:	eb e0                	jmp    f01056da <readline+0x41>
			if (echoing)
f01056fa:	85 ff                	test   %edi,%edi
f01056fc:	75 05                	jne    f0105703 <readline+0x6a>
			i--;
f01056fe:	83 ee 01             	sub    $0x1,%esi
f0105701:	eb 18                	jmp    f010571b <readline+0x82>
				cputchar('\b');
f0105703:	83 ec 0c             	sub    $0xc,%esp
f0105706:	6a 08                	push   $0x8
f0105708:	e8 90 b0 ff ff       	call   f010079d <cputchar>
f010570d:	83 c4 10             	add    $0x10,%esp
f0105710:	eb ec                	jmp    f01056fe <readline+0x65>
			buf[i++] = c;
f0105712:	88 9e 80 5a 21 f0    	mov    %bl,-0xfdea580(%esi)
f0105718:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
f010571b:	e8 8d b0 ff ff       	call   f01007ad <getchar>
f0105720:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105722:	85 c0                	test   %eax,%eax
f0105724:	78 aa                	js     f01056d0 <readline+0x37>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105726:	83 f8 08             	cmp    $0x8,%eax
f0105729:	0f 94 c2             	sete   %dl
f010572c:	83 f8 7f             	cmp    $0x7f,%eax
f010572f:	0f 94 c0             	sete   %al
f0105732:	08 c2                	or     %al,%dl
f0105734:	74 04                	je     f010573a <readline+0xa1>
f0105736:	85 f6                	test   %esi,%esi
f0105738:	7f c0                	jg     f01056fa <readline+0x61>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010573a:	83 fb 1f             	cmp    $0x1f,%ebx
f010573d:	7e 1a                	jle    f0105759 <readline+0xc0>
f010573f:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105745:	7f 12                	jg     f0105759 <readline+0xc0>
			if (echoing)
f0105747:	85 ff                	test   %edi,%edi
f0105749:	74 c7                	je     f0105712 <readline+0x79>
				cputchar(c);
f010574b:	83 ec 0c             	sub    $0xc,%esp
f010574e:	53                   	push   %ebx
f010574f:	e8 49 b0 ff ff       	call   f010079d <cputchar>
f0105754:	83 c4 10             	add    $0x10,%esp
f0105757:	eb b9                	jmp    f0105712 <readline+0x79>
		} else if (c == '\n' || c == '\r') {
f0105759:	83 fb 0a             	cmp    $0xa,%ebx
f010575c:	74 05                	je     f0105763 <readline+0xca>
f010575e:	83 fb 0d             	cmp    $0xd,%ebx
f0105761:	75 b8                	jne    f010571b <readline+0x82>
			if (echoing)
f0105763:	85 ff                	test   %edi,%edi
f0105765:	75 11                	jne    f0105778 <readline+0xdf>
			buf[i] = 0;
f0105767:	c6 86 80 5a 21 f0 00 	movb   $0x0,-0xfdea580(%esi)
			return buf;
f010576e:	b8 80 5a 21 f0       	mov    $0xf0215a80,%eax
f0105773:	e9 62 ff ff ff       	jmp    f01056da <readline+0x41>
				cputchar('\n');
f0105778:	83 ec 0c             	sub    $0xc,%esp
f010577b:	6a 0a                	push   $0xa
f010577d:	e8 1b b0 ff ff       	call   f010079d <cputchar>
f0105782:	83 c4 10             	add    $0x10,%esp
f0105785:	eb e0                	jmp    f0105767 <readline+0xce>

f0105787 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105787:	55                   	push   %ebp
f0105788:	89 e5                	mov    %esp,%ebp
f010578a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010578d:	b8 00 00 00 00       	mov    $0x0,%eax
f0105792:	eb 03                	jmp    f0105797 <strlen+0x10>
		n++;
f0105794:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f0105797:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010579b:	75 f7                	jne    f0105794 <strlen+0xd>
	return n;
}
f010579d:	5d                   	pop    %ebp
f010579e:	c3                   	ret    

f010579f <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010579f:	55                   	push   %ebp
f01057a0:	89 e5                	mov    %esp,%ebp
f01057a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01057a5:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01057a8:	b8 00 00 00 00       	mov    $0x0,%eax
f01057ad:	eb 03                	jmp    f01057b2 <strnlen+0x13>
		n++;
f01057af:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01057b2:	39 d0                	cmp    %edx,%eax
f01057b4:	74 06                	je     f01057bc <strnlen+0x1d>
f01057b6:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01057ba:	75 f3                	jne    f01057af <strnlen+0x10>
	return n;
}
f01057bc:	5d                   	pop    %ebp
f01057bd:	c3                   	ret    

f01057be <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01057be:	55                   	push   %ebp
f01057bf:	89 e5                	mov    %esp,%ebp
f01057c1:	53                   	push   %ebx
f01057c2:	8b 45 08             	mov    0x8(%ebp),%eax
f01057c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01057c8:	89 c2                	mov    %eax,%edx
f01057ca:	83 c1 01             	add    $0x1,%ecx
f01057cd:	83 c2 01             	add    $0x1,%edx
f01057d0:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01057d4:	88 5a ff             	mov    %bl,-0x1(%edx)
f01057d7:	84 db                	test   %bl,%bl
f01057d9:	75 ef                	jne    f01057ca <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01057db:	5b                   	pop    %ebx
f01057dc:	5d                   	pop    %ebp
f01057dd:	c3                   	ret    

f01057de <strcat>:

char *
strcat(char *dst, const char *src)
{
f01057de:	55                   	push   %ebp
f01057df:	89 e5                	mov    %esp,%ebp
f01057e1:	53                   	push   %ebx
f01057e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01057e5:	53                   	push   %ebx
f01057e6:	e8 9c ff ff ff       	call   f0105787 <strlen>
f01057eb:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01057ee:	ff 75 0c             	pushl  0xc(%ebp)
f01057f1:	01 d8                	add    %ebx,%eax
f01057f3:	50                   	push   %eax
f01057f4:	e8 c5 ff ff ff       	call   f01057be <strcpy>
	return dst;
}
f01057f9:	89 d8                	mov    %ebx,%eax
f01057fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01057fe:	c9                   	leave  
f01057ff:	c3                   	ret    

f0105800 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105800:	55                   	push   %ebp
f0105801:	89 e5                	mov    %esp,%ebp
f0105803:	56                   	push   %esi
f0105804:	53                   	push   %ebx
f0105805:	8b 75 08             	mov    0x8(%ebp),%esi
f0105808:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010580b:	89 f3                	mov    %esi,%ebx
f010580d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105810:	89 f2                	mov    %esi,%edx
f0105812:	eb 0f                	jmp    f0105823 <strncpy+0x23>
		*dst++ = *src;
f0105814:	83 c2 01             	add    $0x1,%edx
f0105817:	0f b6 01             	movzbl (%ecx),%eax
f010581a:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010581d:	80 39 01             	cmpb   $0x1,(%ecx)
f0105820:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
f0105823:	39 da                	cmp    %ebx,%edx
f0105825:	75 ed                	jne    f0105814 <strncpy+0x14>
	}
	return ret;
}
f0105827:	89 f0                	mov    %esi,%eax
f0105829:	5b                   	pop    %ebx
f010582a:	5e                   	pop    %esi
f010582b:	5d                   	pop    %ebp
f010582c:	c3                   	ret    

f010582d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010582d:	55                   	push   %ebp
f010582e:	89 e5                	mov    %esp,%ebp
f0105830:	56                   	push   %esi
f0105831:	53                   	push   %ebx
f0105832:	8b 75 08             	mov    0x8(%ebp),%esi
f0105835:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105838:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010583b:	89 f0                	mov    %esi,%eax
f010583d:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105841:	85 c9                	test   %ecx,%ecx
f0105843:	75 0b                	jne    f0105850 <strlcpy+0x23>
f0105845:	eb 17                	jmp    f010585e <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105847:	83 c2 01             	add    $0x1,%edx
f010584a:	83 c0 01             	add    $0x1,%eax
f010584d:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f0105850:	39 d8                	cmp    %ebx,%eax
f0105852:	74 07                	je     f010585b <strlcpy+0x2e>
f0105854:	0f b6 0a             	movzbl (%edx),%ecx
f0105857:	84 c9                	test   %cl,%cl
f0105859:	75 ec                	jne    f0105847 <strlcpy+0x1a>
		*dst = '\0';
f010585b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f010585e:	29 f0                	sub    %esi,%eax
}
f0105860:	5b                   	pop    %ebx
f0105861:	5e                   	pop    %esi
f0105862:	5d                   	pop    %ebp
f0105863:	c3                   	ret    

f0105864 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105864:	55                   	push   %ebp
f0105865:	89 e5                	mov    %esp,%ebp
f0105867:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010586a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010586d:	eb 06                	jmp    f0105875 <strcmp+0x11>
		p++, q++;
f010586f:	83 c1 01             	add    $0x1,%ecx
f0105872:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f0105875:	0f b6 01             	movzbl (%ecx),%eax
f0105878:	84 c0                	test   %al,%al
f010587a:	74 04                	je     f0105880 <strcmp+0x1c>
f010587c:	3a 02                	cmp    (%edx),%al
f010587e:	74 ef                	je     f010586f <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105880:	0f b6 c0             	movzbl %al,%eax
f0105883:	0f b6 12             	movzbl (%edx),%edx
f0105886:	29 d0                	sub    %edx,%eax
}
f0105888:	5d                   	pop    %ebp
f0105889:	c3                   	ret    

f010588a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010588a:	55                   	push   %ebp
f010588b:	89 e5                	mov    %esp,%ebp
f010588d:	53                   	push   %ebx
f010588e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105891:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105894:	89 c3                	mov    %eax,%ebx
f0105896:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105899:	eb 06                	jmp    f01058a1 <strncmp+0x17>
		n--, p++, q++;
f010589b:	83 c0 01             	add    $0x1,%eax
f010589e:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f01058a1:	39 d8                	cmp    %ebx,%eax
f01058a3:	74 16                	je     f01058bb <strncmp+0x31>
f01058a5:	0f b6 08             	movzbl (%eax),%ecx
f01058a8:	84 c9                	test   %cl,%cl
f01058aa:	74 04                	je     f01058b0 <strncmp+0x26>
f01058ac:	3a 0a                	cmp    (%edx),%cl
f01058ae:	74 eb                	je     f010589b <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01058b0:	0f b6 00             	movzbl (%eax),%eax
f01058b3:	0f b6 12             	movzbl (%edx),%edx
f01058b6:	29 d0                	sub    %edx,%eax
}
f01058b8:	5b                   	pop    %ebx
f01058b9:	5d                   	pop    %ebp
f01058ba:	c3                   	ret    
		return 0;
f01058bb:	b8 00 00 00 00       	mov    $0x0,%eax
f01058c0:	eb f6                	jmp    f01058b8 <strncmp+0x2e>

f01058c2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01058c2:	55                   	push   %ebp
f01058c3:	89 e5                	mov    %esp,%ebp
f01058c5:	8b 45 08             	mov    0x8(%ebp),%eax
f01058c8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01058cc:	0f b6 10             	movzbl (%eax),%edx
f01058cf:	84 d2                	test   %dl,%dl
f01058d1:	74 09                	je     f01058dc <strchr+0x1a>
		if (*s == c)
f01058d3:	38 ca                	cmp    %cl,%dl
f01058d5:	74 0a                	je     f01058e1 <strchr+0x1f>
	for (; *s; s++)
f01058d7:	83 c0 01             	add    $0x1,%eax
f01058da:	eb f0                	jmp    f01058cc <strchr+0xa>
			return (char *) s;
	return 0;
f01058dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01058e1:	5d                   	pop    %ebp
f01058e2:	c3                   	ret    

f01058e3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01058e3:	55                   	push   %ebp
f01058e4:	89 e5                	mov    %esp,%ebp
f01058e6:	8b 45 08             	mov    0x8(%ebp),%eax
f01058e9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01058ed:	eb 03                	jmp    f01058f2 <strfind+0xf>
f01058ef:	83 c0 01             	add    $0x1,%eax
f01058f2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01058f5:	38 ca                	cmp    %cl,%dl
f01058f7:	74 04                	je     f01058fd <strfind+0x1a>
f01058f9:	84 d2                	test   %dl,%dl
f01058fb:	75 f2                	jne    f01058ef <strfind+0xc>
			break;
	return (char *) s;
}
f01058fd:	5d                   	pop    %ebp
f01058fe:	c3                   	ret    

f01058ff <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01058ff:	55                   	push   %ebp
f0105900:	89 e5                	mov    %esp,%ebp
f0105902:	57                   	push   %edi
f0105903:	56                   	push   %esi
f0105904:	53                   	push   %ebx
f0105905:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105908:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f010590b:	85 c9                	test   %ecx,%ecx
f010590d:	74 13                	je     f0105922 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010590f:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105915:	75 05                	jne    f010591c <memset+0x1d>
f0105917:	f6 c1 03             	test   $0x3,%cl
f010591a:	74 0d                	je     f0105929 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010591c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010591f:	fc                   	cld    
f0105920:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105922:	89 f8                	mov    %edi,%eax
f0105924:	5b                   	pop    %ebx
f0105925:	5e                   	pop    %esi
f0105926:	5f                   	pop    %edi
f0105927:	5d                   	pop    %ebp
f0105928:	c3                   	ret    
		c &= 0xFF;
f0105929:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010592d:	89 d3                	mov    %edx,%ebx
f010592f:	c1 e3 08             	shl    $0x8,%ebx
f0105932:	89 d0                	mov    %edx,%eax
f0105934:	c1 e0 18             	shl    $0x18,%eax
f0105937:	89 d6                	mov    %edx,%esi
f0105939:	c1 e6 10             	shl    $0x10,%esi
f010593c:	09 f0                	or     %esi,%eax
f010593e:	09 c2                	or     %eax,%edx
f0105940:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f0105942:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0105945:	89 d0                	mov    %edx,%eax
f0105947:	fc                   	cld    
f0105948:	f3 ab                	rep stos %eax,%es:(%edi)
f010594a:	eb d6                	jmp    f0105922 <memset+0x23>

f010594c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010594c:	55                   	push   %ebp
f010594d:	89 e5                	mov    %esp,%ebp
f010594f:	57                   	push   %edi
f0105950:	56                   	push   %esi
f0105951:	8b 45 08             	mov    0x8(%ebp),%eax
f0105954:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105957:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010595a:	39 c6                	cmp    %eax,%esi
f010595c:	73 35                	jae    f0105993 <memmove+0x47>
f010595e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105961:	39 c2                	cmp    %eax,%edx
f0105963:	76 2e                	jbe    f0105993 <memmove+0x47>
		s += n;
		d += n;
f0105965:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105968:	89 d6                	mov    %edx,%esi
f010596a:	09 fe                	or     %edi,%esi
f010596c:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105972:	74 0c                	je     f0105980 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0105974:	83 ef 01             	sub    $0x1,%edi
f0105977:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f010597a:	fd                   	std    
f010597b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010597d:	fc                   	cld    
f010597e:	eb 21                	jmp    f01059a1 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105980:	f6 c1 03             	test   $0x3,%cl
f0105983:	75 ef                	jne    f0105974 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0105985:	83 ef 04             	sub    $0x4,%edi
f0105988:	8d 72 fc             	lea    -0x4(%edx),%esi
f010598b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f010598e:	fd                   	std    
f010598f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105991:	eb ea                	jmp    f010597d <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105993:	89 f2                	mov    %esi,%edx
f0105995:	09 c2                	or     %eax,%edx
f0105997:	f6 c2 03             	test   $0x3,%dl
f010599a:	74 09                	je     f01059a5 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f010599c:	89 c7                	mov    %eax,%edi
f010599e:	fc                   	cld    
f010599f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01059a1:	5e                   	pop    %esi
f01059a2:	5f                   	pop    %edi
f01059a3:	5d                   	pop    %ebp
f01059a4:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01059a5:	f6 c1 03             	test   $0x3,%cl
f01059a8:	75 f2                	jne    f010599c <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01059aa:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f01059ad:	89 c7                	mov    %eax,%edi
f01059af:	fc                   	cld    
f01059b0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01059b2:	eb ed                	jmp    f01059a1 <memmove+0x55>

f01059b4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01059b4:	55                   	push   %ebp
f01059b5:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01059b7:	ff 75 10             	pushl  0x10(%ebp)
f01059ba:	ff 75 0c             	pushl  0xc(%ebp)
f01059bd:	ff 75 08             	pushl  0x8(%ebp)
f01059c0:	e8 87 ff ff ff       	call   f010594c <memmove>
}
f01059c5:	c9                   	leave  
f01059c6:	c3                   	ret    

f01059c7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01059c7:	55                   	push   %ebp
f01059c8:	89 e5                	mov    %esp,%ebp
f01059ca:	56                   	push   %esi
f01059cb:	53                   	push   %ebx
f01059cc:	8b 45 08             	mov    0x8(%ebp),%eax
f01059cf:	8b 55 0c             	mov    0xc(%ebp),%edx
f01059d2:	89 c6                	mov    %eax,%esi
f01059d4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01059d7:	39 f0                	cmp    %esi,%eax
f01059d9:	74 1c                	je     f01059f7 <memcmp+0x30>
		if (*s1 != *s2)
f01059db:	0f b6 08             	movzbl (%eax),%ecx
f01059de:	0f b6 1a             	movzbl (%edx),%ebx
f01059e1:	38 d9                	cmp    %bl,%cl
f01059e3:	75 08                	jne    f01059ed <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f01059e5:	83 c0 01             	add    $0x1,%eax
f01059e8:	83 c2 01             	add    $0x1,%edx
f01059eb:	eb ea                	jmp    f01059d7 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f01059ed:	0f b6 c1             	movzbl %cl,%eax
f01059f0:	0f b6 db             	movzbl %bl,%ebx
f01059f3:	29 d8                	sub    %ebx,%eax
f01059f5:	eb 05                	jmp    f01059fc <memcmp+0x35>
	}

	return 0;
f01059f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01059fc:	5b                   	pop    %ebx
f01059fd:	5e                   	pop    %esi
f01059fe:	5d                   	pop    %ebp
f01059ff:	c3                   	ret    

f0105a00 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105a00:	55                   	push   %ebp
f0105a01:	89 e5                	mov    %esp,%ebp
f0105a03:	8b 45 08             	mov    0x8(%ebp),%eax
f0105a06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0105a09:	89 c2                	mov    %eax,%edx
f0105a0b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0105a0e:	39 d0                	cmp    %edx,%eax
f0105a10:	73 09                	jae    f0105a1b <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105a12:	38 08                	cmp    %cl,(%eax)
f0105a14:	74 05                	je     f0105a1b <memfind+0x1b>
	for (; s < ends; s++)
f0105a16:	83 c0 01             	add    $0x1,%eax
f0105a19:	eb f3                	jmp    f0105a0e <memfind+0xe>
			break;
	return (void *) s;
}
f0105a1b:	5d                   	pop    %ebp
f0105a1c:	c3                   	ret    

f0105a1d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105a1d:	55                   	push   %ebp
f0105a1e:	89 e5                	mov    %esp,%ebp
f0105a20:	57                   	push   %edi
f0105a21:	56                   	push   %esi
f0105a22:	53                   	push   %ebx
f0105a23:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105a26:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105a29:	eb 03                	jmp    f0105a2e <strtol+0x11>
		s++;
f0105a2b:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f0105a2e:	0f b6 01             	movzbl (%ecx),%eax
f0105a31:	3c 20                	cmp    $0x20,%al
f0105a33:	74 f6                	je     f0105a2b <strtol+0xe>
f0105a35:	3c 09                	cmp    $0x9,%al
f0105a37:	74 f2                	je     f0105a2b <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0105a39:	3c 2b                	cmp    $0x2b,%al
f0105a3b:	74 2e                	je     f0105a6b <strtol+0x4e>
	int neg = 0;
f0105a3d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0105a42:	3c 2d                	cmp    $0x2d,%al
f0105a44:	74 2f                	je     f0105a75 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105a46:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0105a4c:	75 05                	jne    f0105a53 <strtol+0x36>
f0105a4e:	80 39 30             	cmpb   $0x30,(%ecx)
f0105a51:	74 2c                	je     f0105a7f <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105a53:	85 db                	test   %ebx,%ebx
f0105a55:	75 0a                	jne    f0105a61 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105a57:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
f0105a5c:	80 39 30             	cmpb   $0x30,(%ecx)
f0105a5f:	74 28                	je     f0105a89 <strtol+0x6c>
		base = 10;
f0105a61:	b8 00 00 00 00       	mov    $0x0,%eax
f0105a66:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0105a69:	eb 50                	jmp    f0105abb <strtol+0x9e>
		s++;
f0105a6b:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f0105a6e:	bf 00 00 00 00       	mov    $0x0,%edi
f0105a73:	eb d1                	jmp    f0105a46 <strtol+0x29>
		s++, neg = 1;
f0105a75:	83 c1 01             	add    $0x1,%ecx
f0105a78:	bf 01 00 00 00       	mov    $0x1,%edi
f0105a7d:	eb c7                	jmp    f0105a46 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105a7f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0105a83:	74 0e                	je     f0105a93 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f0105a85:	85 db                	test   %ebx,%ebx
f0105a87:	75 d8                	jne    f0105a61 <strtol+0x44>
		s++, base = 8;
f0105a89:	83 c1 01             	add    $0x1,%ecx
f0105a8c:	bb 08 00 00 00       	mov    $0x8,%ebx
f0105a91:	eb ce                	jmp    f0105a61 <strtol+0x44>
		s += 2, base = 16;
f0105a93:	83 c1 02             	add    $0x2,%ecx
f0105a96:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105a9b:	eb c4                	jmp    f0105a61 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f0105a9d:	8d 72 9f             	lea    -0x61(%edx),%esi
f0105aa0:	89 f3                	mov    %esi,%ebx
f0105aa2:	80 fb 19             	cmp    $0x19,%bl
f0105aa5:	77 29                	ja     f0105ad0 <strtol+0xb3>
			dig = *s - 'a' + 10;
f0105aa7:	0f be d2             	movsbl %dl,%edx
f0105aaa:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0105aad:	3b 55 10             	cmp    0x10(%ebp),%edx
f0105ab0:	7d 30                	jge    f0105ae2 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f0105ab2:	83 c1 01             	add    $0x1,%ecx
f0105ab5:	0f af 45 10          	imul   0x10(%ebp),%eax
f0105ab9:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0105abb:	0f b6 11             	movzbl (%ecx),%edx
f0105abe:	8d 72 d0             	lea    -0x30(%edx),%esi
f0105ac1:	89 f3                	mov    %esi,%ebx
f0105ac3:	80 fb 09             	cmp    $0x9,%bl
f0105ac6:	77 d5                	ja     f0105a9d <strtol+0x80>
			dig = *s - '0';
f0105ac8:	0f be d2             	movsbl %dl,%edx
f0105acb:	83 ea 30             	sub    $0x30,%edx
f0105ace:	eb dd                	jmp    f0105aad <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
f0105ad0:	8d 72 bf             	lea    -0x41(%edx),%esi
f0105ad3:	89 f3                	mov    %esi,%ebx
f0105ad5:	80 fb 19             	cmp    $0x19,%bl
f0105ad8:	77 08                	ja     f0105ae2 <strtol+0xc5>
			dig = *s - 'A' + 10;
f0105ada:	0f be d2             	movsbl %dl,%edx
f0105add:	83 ea 37             	sub    $0x37,%edx
f0105ae0:	eb cb                	jmp    f0105aad <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
f0105ae2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105ae6:	74 05                	je     f0105aed <strtol+0xd0>
		*endptr = (char *) s;
f0105ae8:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105aeb:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0105aed:	89 c2                	mov    %eax,%edx
f0105aef:	f7 da                	neg    %edx
f0105af1:	85 ff                	test   %edi,%edi
f0105af3:	0f 45 c2             	cmovne %edx,%eax
}
f0105af6:	5b                   	pop    %ebx
f0105af7:	5e                   	pop    %esi
f0105af8:	5f                   	pop    %edi
f0105af9:	5d                   	pop    %ebp
f0105afa:	c3                   	ret    
f0105afb:	90                   	nop

f0105afc <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105afc:	fa                   	cli    

	xorw    %ax, %ax
f0105afd:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105aff:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105b01:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105b03:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105b05:	0f 01 16             	lgdtl  (%esi)
f0105b08:	74 70                	je     f0105b7a <mpsearch1+0x3>
	movl    %cr0, %eax
f0105b0a:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105b0d:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105b11:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105b14:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105b1a:	08 00                	or     %al,(%eax)

f0105b1c <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105b1c:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105b20:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105b22:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105b24:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105b26:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105b2a:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105b2c:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105b2e:	b8 00 00 12 00       	mov    $0x120000,%eax
	movl    %eax, %cr3
f0105b33:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105b36:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105b39:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105b3e:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105b41:	8b 25 84 5e 21 f0    	mov    0xf0215e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105b47:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105b4c:	b8 a3 01 10 f0       	mov    $0xf01001a3,%eax
	call    *%eax
f0105b51:	ff d0                	call   *%eax

f0105b53 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105b53:	eb fe                	jmp    f0105b53 <spin>
f0105b55:	8d 76 00             	lea    0x0(%esi),%esi

f0105b58 <gdt>:
	...
f0105b60:	ff                   	(bad)  
f0105b61:	ff 00                	incl   (%eax)
f0105b63:	00 00                	add    %al,(%eax)
f0105b65:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105b6c:	00                   	.byte 0x0
f0105b6d:	92                   	xchg   %eax,%edx
f0105b6e:	cf                   	iret   
	...

f0105b70 <gdtdesc>:
f0105b70:	17                   	pop    %ss
f0105b71:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105b76 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105b76:	90                   	nop

f0105b77 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105b77:	55                   	push   %ebp
f0105b78:	89 e5                	mov    %esp,%ebp
f0105b7a:	57                   	push   %edi
f0105b7b:	56                   	push   %esi
f0105b7c:	53                   	push   %ebx
f0105b7d:	83 ec 0c             	sub    $0xc,%esp
	if (PGNUM(pa) >= npages)
f0105b80:	8b 0d 88 5e 21 f0    	mov    0xf0215e88,%ecx
f0105b86:	89 c3                	mov    %eax,%ebx
f0105b88:	c1 eb 0c             	shr    $0xc,%ebx
f0105b8b:	39 cb                	cmp    %ecx,%ebx
f0105b8d:	73 1a                	jae    f0105ba9 <mpsearch1+0x32>
	return (void *)(pa + KERNBASE);
f0105b8f:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105b95:	8d 34 02             	lea    (%edx,%eax,1),%esi
	if (PGNUM(pa) >= npages)
f0105b98:	89 f0                	mov    %esi,%eax
f0105b9a:	c1 e8 0c             	shr    $0xc,%eax
f0105b9d:	39 c8                	cmp    %ecx,%eax
f0105b9f:	73 1a                	jae    f0105bbb <mpsearch1+0x44>
	return (void *)(pa + KERNBASE);
f0105ba1:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f0105ba7:	eb 27                	jmp    f0105bd0 <mpsearch1+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105ba9:	50                   	push   %eax
f0105baa:	68 84 65 10 f0       	push   $0xf0106584
f0105baf:	6a 57                	push   $0x57
f0105bb1:	68 9d 81 10 f0       	push   $0xf010819d
f0105bb6:	e8 85 a4 ff ff       	call   f0100040 <_panic>
f0105bbb:	56                   	push   %esi
f0105bbc:	68 84 65 10 f0       	push   $0xf0106584
f0105bc1:	6a 57                	push   $0x57
f0105bc3:	68 9d 81 10 f0       	push   $0xf010819d
f0105bc8:	e8 73 a4 ff ff       	call   f0100040 <_panic>
f0105bcd:	83 c3 10             	add    $0x10,%ebx
f0105bd0:	39 f3                	cmp    %esi,%ebx
f0105bd2:	73 2e                	jae    f0105c02 <mpsearch1+0x8b>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105bd4:	83 ec 04             	sub    $0x4,%esp
f0105bd7:	6a 04                	push   $0x4
f0105bd9:	68 ad 81 10 f0       	push   $0xf01081ad
f0105bde:	53                   	push   %ebx
f0105bdf:	e8 e3 fd ff ff       	call   f01059c7 <memcmp>
f0105be4:	83 c4 10             	add    $0x10,%esp
f0105be7:	85 c0                	test   %eax,%eax
f0105be9:	75 e2                	jne    f0105bcd <mpsearch1+0x56>
f0105beb:	89 da                	mov    %ebx,%edx
f0105bed:	8d 7b 10             	lea    0x10(%ebx),%edi
		sum += ((uint8_t *)addr)[i];
f0105bf0:	0f b6 0a             	movzbl (%edx),%ecx
f0105bf3:	01 c8                	add    %ecx,%eax
f0105bf5:	83 c2 01             	add    $0x1,%edx
	for (i = 0; i < len; i++)
f0105bf8:	39 fa                	cmp    %edi,%edx
f0105bfa:	75 f4                	jne    f0105bf0 <mpsearch1+0x79>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105bfc:	84 c0                	test   %al,%al
f0105bfe:	75 cd                	jne    f0105bcd <mpsearch1+0x56>
f0105c00:	eb 05                	jmp    f0105c07 <mpsearch1+0x90>
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0105c02:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0105c07:	89 d8                	mov    %ebx,%eax
f0105c09:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105c0c:	5b                   	pop    %ebx
f0105c0d:	5e                   	pop    %esi
f0105c0e:	5f                   	pop    %edi
f0105c0f:	5d                   	pop    %ebp
f0105c10:	c3                   	ret    

f0105c11 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105c11:	55                   	push   %ebp
f0105c12:	89 e5                	mov    %esp,%ebp
f0105c14:	57                   	push   %edi
f0105c15:	56                   	push   %esi
f0105c16:	53                   	push   %ebx
f0105c17:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105c1a:	c7 05 c0 63 21 f0 20 	movl   $0xf0216020,0xf02163c0
f0105c21:	60 21 f0 
	if (PGNUM(pa) >= npages)
f0105c24:	83 3d 88 5e 21 f0 00 	cmpl   $0x0,0xf0215e88
f0105c2b:	0f 84 87 00 00 00    	je     f0105cb8 <mp_init+0xa7>
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105c31:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105c38:	85 c0                	test   %eax,%eax
f0105c3a:	0f 84 8e 00 00 00    	je     f0105cce <mp_init+0xbd>
		p <<= 4;	// Translate from segment to PA
f0105c40:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0105c43:	ba 00 04 00 00       	mov    $0x400,%edx
f0105c48:	e8 2a ff ff ff       	call   f0105b77 <mpsearch1>
f0105c4d:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105c50:	85 c0                	test   %eax,%eax
f0105c52:	0f 84 9a 00 00 00    	je     f0105cf2 <mp_init+0xe1>
	if (mp->physaddr == 0 || mp->type != 0) {
f0105c58:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105c5b:	8b 41 04             	mov    0x4(%ecx),%eax
f0105c5e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105c61:	85 c0                	test   %eax,%eax
f0105c63:	0f 84 a8 00 00 00    	je     f0105d11 <mp_init+0x100>
f0105c69:	80 79 0b 00          	cmpb   $0x0,0xb(%ecx)
f0105c6d:	0f 85 9e 00 00 00    	jne    f0105d11 <mp_init+0x100>
f0105c73:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105c76:	c1 e8 0c             	shr    $0xc,%eax
f0105c79:	3b 05 88 5e 21 f0    	cmp    0xf0215e88,%eax
f0105c7f:	0f 83 a1 00 00 00    	jae    f0105d26 <mp_init+0x115>
	return (void *)(pa + KERNBASE);
f0105c85:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105c88:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f0105c8e:	89 de                	mov    %ebx,%esi
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105c90:	83 ec 04             	sub    $0x4,%esp
f0105c93:	6a 04                	push   $0x4
f0105c95:	68 b2 81 10 f0       	push   $0xf01081b2
f0105c9a:	53                   	push   %ebx
f0105c9b:	e8 27 fd ff ff       	call   f01059c7 <memcmp>
f0105ca0:	83 c4 10             	add    $0x10,%esp
f0105ca3:	85 c0                	test   %eax,%eax
f0105ca5:	0f 85 92 00 00 00    	jne    f0105d3d <mp_init+0x12c>
f0105cab:	0f b7 7b 04          	movzwl 0x4(%ebx),%edi
f0105caf:	01 df                	add    %ebx,%edi
	sum = 0;
f0105cb1:	89 c2                	mov    %eax,%edx
f0105cb3:	e9 a2 00 00 00       	jmp    f0105d5a <mp_init+0x149>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105cb8:	68 00 04 00 00       	push   $0x400
f0105cbd:	68 84 65 10 f0       	push   $0xf0106584
f0105cc2:	6a 6f                	push   $0x6f
f0105cc4:	68 9d 81 10 f0       	push   $0xf010819d
f0105cc9:	e8 72 a3 ff ff       	call   f0100040 <_panic>
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0105cce:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105cd5:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105cd8:	2d 00 04 00 00       	sub    $0x400,%eax
f0105cdd:	ba 00 04 00 00       	mov    $0x400,%edx
f0105ce2:	e8 90 fe ff ff       	call   f0105b77 <mpsearch1>
f0105ce7:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105cea:	85 c0                	test   %eax,%eax
f0105cec:	0f 85 66 ff ff ff    	jne    f0105c58 <mp_init+0x47>
	return mpsearch1(0xF0000, 0x10000);
f0105cf2:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105cf7:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105cfc:	e8 76 fe ff ff       	call   f0105b77 <mpsearch1>
f0105d01:	89 45 e0             	mov    %eax,-0x20(%ebp)
	if ((mp = mpsearch()) == 0)
f0105d04:	85 c0                	test   %eax,%eax
f0105d06:	0f 85 4c ff ff ff    	jne    f0105c58 <mp_init+0x47>
f0105d0c:	e9 a8 01 00 00       	jmp    f0105eb9 <mp_init+0x2a8>
		cprintf("SMP: Default configurations not implemented\n");
f0105d11:	83 ec 0c             	sub    $0xc,%esp
f0105d14:	68 10 80 10 f0       	push   $0xf0108010
f0105d19:	e8 2a dc ff ff       	call   f0103948 <cprintf>
f0105d1e:	83 c4 10             	add    $0x10,%esp
f0105d21:	e9 93 01 00 00       	jmp    f0105eb9 <mp_init+0x2a8>
f0105d26:	ff 75 e4             	pushl  -0x1c(%ebp)
f0105d29:	68 84 65 10 f0       	push   $0xf0106584
f0105d2e:	68 90 00 00 00       	push   $0x90
f0105d33:	68 9d 81 10 f0       	push   $0xf010819d
f0105d38:	e8 03 a3 ff ff       	call   f0100040 <_panic>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105d3d:	83 ec 0c             	sub    $0xc,%esp
f0105d40:	68 40 80 10 f0       	push   $0xf0108040
f0105d45:	e8 fe db ff ff       	call   f0103948 <cprintf>
f0105d4a:	83 c4 10             	add    $0x10,%esp
f0105d4d:	e9 67 01 00 00       	jmp    f0105eb9 <mp_init+0x2a8>
		sum += ((uint8_t *)addr)[i];
f0105d52:	0f b6 0b             	movzbl (%ebx),%ecx
f0105d55:	01 ca                	add    %ecx,%edx
f0105d57:	83 c3 01             	add    $0x1,%ebx
	for (i = 0; i < len; i++)
f0105d5a:	39 fb                	cmp    %edi,%ebx
f0105d5c:	75 f4                	jne    f0105d52 <mp_init+0x141>
	if (sum(conf, conf->length) != 0) {
f0105d5e:	84 d2                	test   %dl,%dl
f0105d60:	75 16                	jne    f0105d78 <mp_init+0x167>
	if (conf->version != 1 && conf->version != 4) {
f0105d62:	0f b6 56 06          	movzbl 0x6(%esi),%edx
f0105d66:	80 fa 01             	cmp    $0x1,%dl
f0105d69:	74 05                	je     f0105d70 <mp_init+0x15f>
f0105d6b:	80 fa 04             	cmp    $0x4,%dl
f0105d6e:	75 1d                	jne    f0105d8d <mp_init+0x17c>
f0105d70:	0f b7 4e 28          	movzwl 0x28(%esi),%ecx
f0105d74:	01 d9                	add    %ebx,%ecx
f0105d76:	eb 36                	jmp    f0105dae <mp_init+0x19d>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105d78:	83 ec 0c             	sub    $0xc,%esp
f0105d7b:	68 74 80 10 f0       	push   $0xf0108074
f0105d80:	e8 c3 db ff ff       	call   f0103948 <cprintf>
f0105d85:	83 c4 10             	add    $0x10,%esp
f0105d88:	e9 2c 01 00 00       	jmp    f0105eb9 <mp_init+0x2a8>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105d8d:	83 ec 08             	sub    $0x8,%esp
f0105d90:	0f b6 d2             	movzbl %dl,%edx
f0105d93:	52                   	push   %edx
f0105d94:	68 98 80 10 f0       	push   $0xf0108098
f0105d99:	e8 aa db ff ff       	call   f0103948 <cprintf>
f0105d9e:	83 c4 10             	add    $0x10,%esp
f0105da1:	e9 13 01 00 00       	jmp    f0105eb9 <mp_init+0x2a8>
		sum += ((uint8_t *)addr)[i];
f0105da6:	0f b6 13             	movzbl (%ebx),%edx
f0105da9:	01 d0                	add    %edx,%eax
f0105dab:	83 c3 01             	add    $0x1,%ebx
	for (i = 0; i < len; i++)
f0105dae:	39 d9                	cmp    %ebx,%ecx
f0105db0:	75 f4                	jne    f0105da6 <mp_init+0x195>
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105db2:	02 46 2a             	add    0x2a(%esi),%al
f0105db5:	75 29                	jne    f0105de0 <mp_init+0x1cf>
	if ((conf = mpconfig(&mp)) == 0)
f0105db7:	81 7d e4 00 00 00 10 	cmpl   $0x10000000,-0x1c(%ebp)
f0105dbe:	0f 84 f5 00 00 00    	je     f0105eb9 <mp_init+0x2a8>
		return;
	ismp = 1;
f0105dc4:	c7 05 00 60 21 f0 01 	movl   $0x1,0xf0216000
f0105dcb:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105dce:	8b 46 24             	mov    0x24(%esi),%eax
f0105dd1:	a3 00 70 25 f0       	mov    %eax,0xf0257000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105dd6:	8d 7e 2c             	lea    0x2c(%esi),%edi
f0105dd9:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105dde:	eb 4d                	jmp    f0105e2d <mp_init+0x21c>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105de0:	83 ec 0c             	sub    $0xc,%esp
f0105de3:	68 b8 80 10 f0       	push   $0xf01080b8
f0105de8:	e8 5b db ff ff       	call   f0103948 <cprintf>
f0105ded:	83 c4 10             	add    $0x10,%esp
f0105df0:	e9 c4 00 00 00       	jmp    f0105eb9 <mp_init+0x2a8>
		switch (*p) {
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105df5:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105df9:	74 11                	je     f0105e0c <mp_init+0x1fb>
				bootcpu = &cpus[ncpu];
f0105dfb:	6b 05 c4 63 21 f0 74 	imul   $0x74,0xf02163c4,%eax
f0105e02:	05 20 60 21 f0       	add    $0xf0216020,%eax
f0105e07:	a3 c0 63 21 f0       	mov    %eax,0xf02163c0
			if (ncpu < NCPU) {
f0105e0c:	a1 c4 63 21 f0       	mov    0xf02163c4,%eax
f0105e11:	83 f8 07             	cmp    $0x7,%eax
f0105e14:	7f 2f                	jg     f0105e45 <mp_init+0x234>
				cpus[ncpu].cpu_id = ncpu;
f0105e16:	6b d0 74             	imul   $0x74,%eax,%edx
f0105e19:	88 82 20 60 21 f0    	mov    %al,-0xfde9fe0(%edx)
				ncpu++;
f0105e1f:	83 c0 01             	add    $0x1,%eax
f0105e22:	a3 c4 63 21 f0       	mov    %eax,0xf02163c4
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105e27:	83 c7 14             	add    $0x14,%edi
	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105e2a:	83 c3 01             	add    $0x1,%ebx
f0105e2d:	0f b7 46 22          	movzwl 0x22(%esi),%eax
f0105e31:	39 d8                	cmp    %ebx,%eax
f0105e33:	76 4b                	jbe    f0105e80 <mp_init+0x26f>
		switch (*p) {
f0105e35:	0f b6 07             	movzbl (%edi),%eax
f0105e38:	84 c0                	test   %al,%al
f0105e3a:	74 b9                	je     f0105df5 <mp_init+0x1e4>
f0105e3c:	3c 04                	cmp    $0x4,%al
f0105e3e:	77 1c                	ja     f0105e5c <mp_init+0x24b>
			continue;
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105e40:	83 c7 08             	add    $0x8,%edi
			continue;
f0105e43:	eb e5                	jmp    f0105e2a <mp_init+0x219>
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105e45:	83 ec 08             	sub    $0x8,%esp
f0105e48:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0105e4c:	50                   	push   %eax
f0105e4d:	68 e8 80 10 f0       	push   $0xf01080e8
f0105e52:	e8 f1 da ff ff       	call   f0103948 <cprintf>
f0105e57:	83 c4 10             	add    $0x10,%esp
f0105e5a:	eb cb                	jmp    f0105e27 <mp_init+0x216>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105e5c:	83 ec 08             	sub    $0x8,%esp
		switch (*p) {
f0105e5f:	0f b6 c0             	movzbl %al,%eax
			cprintf("mpinit: unknown config type %x\n", *p);
f0105e62:	50                   	push   %eax
f0105e63:	68 10 81 10 f0       	push   $0xf0108110
f0105e68:	e8 db da ff ff       	call   f0103948 <cprintf>
			ismp = 0;
f0105e6d:	c7 05 00 60 21 f0 00 	movl   $0x0,0xf0216000
f0105e74:	00 00 00 
			i = conf->entry;
f0105e77:	0f b7 5e 22          	movzwl 0x22(%esi),%ebx
f0105e7b:	83 c4 10             	add    $0x10,%esp
f0105e7e:	eb aa                	jmp    f0105e2a <mp_init+0x219>
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105e80:	a1 c0 63 21 f0       	mov    0xf02163c0,%eax
f0105e85:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105e8c:	83 3d 00 60 21 f0 00 	cmpl   $0x0,0xf0216000
f0105e93:	75 2c                	jne    f0105ec1 <mp_init+0x2b0>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105e95:	c7 05 c4 63 21 f0 01 	movl   $0x1,0xf02163c4
f0105e9c:	00 00 00 
		lapicaddr = 0;
f0105e9f:	c7 05 00 70 25 f0 00 	movl   $0x0,0xf0257000
f0105ea6:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105ea9:	83 ec 0c             	sub    $0xc,%esp
f0105eac:	68 30 81 10 f0       	push   $0xf0108130
f0105eb1:	e8 92 da ff ff       	call   f0103948 <cprintf>
		return;
f0105eb6:	83 c4 10             	add    $0x10,%esp
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0105eb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105ebc:	5b                   	pop    %ebx
f0105ebd:	5e                   	pop    %esi
f0105ebe:	5f                   	pop    %edi
f0105ebf:	5d                   	pop    %ebp
f0105ec0:	c3                   	ret    
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105ec1:	83 ec 04             	sub    $0x4,%esp
f0105ec4:	ff 35 c4 63 21 f0    	pushl  0xf02163c4
f0105eca:	0f b6 00             	movzbl (%eax),%eax
f0105ecd:	50                   	push   %eax
f0105ece:	68 b7 81 10 f0       	push   $0xf01081b7
f0105ed3:	e8 70 da ff ff       	call   f0103948 <cprintf>
	if (mp->imcrp) {
f0105ed8:	83 c4 10             	add    $0x10,%esp
f0105edb:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105ede:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105ee2:	74 d5                	je     f0105eb9 <mp_init+0x2a8>
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105ee4:	83 ec 0c             	sub    $0xc,%esp
f0105ee7:	68 5c 81 10 f0       	push   $0xf010815c
f0105eec:	e8 57 da ff ff       	call   f0103948 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105ef1:	b8 70 00 00 00       	mov    $0x70,%eax
f0105ef6:	ba 22 00 00 00       	mov    $0x22,%edx
f0105efb:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105efc:	ba 23 00 00 00       	mov    $0x23,%edx
f0105f01:	ec                   	in     (%dx),%al
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0105f02:	83 c8 01             	or     $0x1,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105f05:	ee                   	out    %al,(%dx)
f0105f06:	83 c4 10             	add    $0x10,%esp
f0105f09:	eb ae                	jmp    f0105eb9 <mp_init+0x2a8>

f0105f0b <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0105f0b:	55                   	push   %ebp
f0105f0c:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0105f0e:	8b 0d 04 70 25 f0    	mov    0xf0257004,%ecx
f0105f14:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0105f17:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105f19:	a1 04 70 25 f0       	mov    0xf0257004,%eax
f0105f1e:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105f21:	5d                   	pop    %ebp
f0105f22:	c3                   	ret    

f0105f23 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0105f23:	55                   	push   %ebp
f0105f24:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105f26:	8b 15 04 70 25 f0    	mov    0xf0257004,%edx
		return lapic[ID] >> 24;
	return 0;
f0105f2c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lapic)
f0105f31:	85 d2                	test   %edx,%edx
f0105f33:	74 06                	je     f0105f3b <cpunum+0x18>
		return lapic[ID] >> 24;
f0105f35:	8b 42 20             	mov    0x20(%edx),%eax
f0105f38:	c1 e8 18             	shr    $0x18,%eax
}
f0105f3b:	5d                   	pop    %ebp
f0105f3c:	c3                   	ret    

f0105f3d <lapic_init>:
	if (!lapicaddr)
f0105f3d:	a1 00 70 25 f0       	mov    0xf0257000,%eax
f0105f42:	85 c0                	test   %eax,%eax
f0105f44:	75 02                	jne    f0105f48 <lapic_init+0xb>
f0105f46:	f3 c3                	repz ret 
{
f0105f48:	55                   	push   %ebp
f0105f49:	89 e5                	mov    %esp,%ebp
f0105f4b:	83 ec 10             	sub    $0x10,%esp
	lapic = mmio_map_region(lapicaddr, 4096);
f0105f4e:	68 00 10 00 00       	push   $0x1000
f0105f53:	50                   	push   %eax
f0105f54:	e8 99 b3 ff ff       	call   f01012f2 <mmio_map_region>
f0105f59:	a3 04 70 25 f0       	mov    %eax,0xf0257004
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105f5e:	ba 27 01 00 00       	mov    $0x127,%edx
f0105f63:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105f68:	e8 9e ff ff ff       	call   f0105f0b <lapicw>
	lapicw(TDCR, X1);
f0105f6d:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105f72:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105f77:	e8 8f ff ff ff       	call   f0105f0b <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105f7c:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105f81:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105f86:	e8 80 ff ff ff       	call   f0105f0b <lapicw>
	lapicw(TICR, 10000000); 
f0105f8b:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105f90:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105f95:	e8 71 ff ff ff       	call   f0105f0b <lapicw>
	if (thiscpu != bootcpu)
f0105f9a:	e8 84 ff ff ff       	call   f0105f23 <cpunum>
f0105f9f:	6b c0 74             	imul   $0x74,%eax,%eax
f0105fa2:	05 20 60 21 f0       	add    $0xf0216020,%eax
f0105fa7:	83 c4 10             	add    $0x10,%esp
f0105faa:	39 05 c0 63 21 f0    	cmp    %eax,0xf02163c0
f0105fb0:	74 0f                	je     f0105fc1 <lapic_init+0x84>
		lapicw(LINT0, MASKED);
f0105fb2:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105fb7:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105fbc:	e8 4a ff ff ff       	call   f0105f0b <lapicw>
	lapicw(LINT1, MASKED);
f0105fc1:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105fc6:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105fcb:	e8 3b ff ff ff       	call   f0105f0b <lapicw>
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105fd0:	a1 04 70 25 f0       	mov    0xf0257004,%eax
f0105fd5:	8b 40 30             	mov    0x30(%eax),%eax
f0105fd8:	c1 e8 10             	shr    $0x10,%eax
f0105fdb:	3c 03                	cmp    $0x3,%al
f0105fdd:	77 7c                	ja     f010605b <lapic_init+0x11e>
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105fdf:	ba 33 00 00 00       	mov    $0x33,%edx
f0105fe4:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105fe9:	e8 1d ff ff ff       	call   f0105f0b <lapicw>
	lapicw(ESR, 0);
f0105fee:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ff3:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105ff8:	e8 0e ff ff ff       	call   f0105f0b <lapicw>
	lapicw(ESR, 0);
f0105ffd:	ba 00 00 00 00       	mov    $0x0,%edx
f0106002:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106007:	e8 ff fe ff ff       	call   f0105f0b <lapicw>
	lapicw(EOI, 0);
f010600c:	ba 00 00 00 00       	mov    $0x0,%edx
f0106011:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106016:	e8 f0 fe ff ff       	call   f0105f0b <lapicw>
	lapicw(ICRHI, 0);
f010601b:	ba 00 00 00 00       	mov    $0x0,%edx
f0106020:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106025:	e8 e1 fe ff ff       	call   f0105f0b <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f010602a:	ba 00 85 08 00       	mov    $0x88500,%edx
f010602f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106034:	e8 d2 fe ff ff       	call   f0105f0b <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0106039:	8b 15 04 70 25 f0    	mov    0xf0257004,%edx
f010603f:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106045:	f6 c4 10             	test   $0x10,%ah
f0106048:	75 f5                	jne    f010603f <lapic_init+0x102>
	lapicw(TPR, 0);
f010604a:	ba 00 00 00 00       	mov    $0x0,%edx
f010604f:	b8 20 00 00 00       	mov    $0x20,%eax
f0106054:	e8 b2 fe ff ff       	call   f0105f0b <lapicw>
}
f0106059:	c9                   	leave  
f010605a:	c3                   	ret    
		lapicw(PCINT, MASKED);
f010605b:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106060:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0106065:	e8 a1 fe ff ff       	call   f0105f0b <lapicw>
f010606a:	e9 70 ff ff ff       	jmp    f0105fdf <lapic_init+0xa2>

f010606f <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f010606f:	83 3d 04 70 25 f0 00 	cmpl   $0x0,0xf0257004
f0106076:	74 14                	je     f010608c <lapic_eoi+0x1d>
{
f0106078:	55                   	push   %ebp
f0106079:	89 e5                	mov    %esp,%ebp
		lapicw(EOI, 0);
f010607b:	ba 00 00 00 00       	mov    $0x0,%edx
f0106080:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106085:	e8 81 fe ff ff       	call   f0105f0b <lapicw>
}
f010608a:	5d                   	pop    %ebp
f010608b:	c3                   	ret    
f010608c:	f3 c3                	repz ret 

f010608e <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f010608e:	55                   	push   %ebp
f010608f:	89 e5                	mov    %esp,%ebp
f0106091:	56                   	push   %esi
f0106092:	53                   	push   %ebx
f0106093:	8b 75 08             	mov    0x8(%ebp),%esi
f0106096:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0106099:	b8 0f 00 00 00       	mov    $0xf,%eax
f010609e:	ba 70 00 00 00       	mov    $0x70,%edx
f01060a3:	ee                   	out    %al,(%dx)
f01060a4:	b8 0a 00 00 00       	mov    $0xa,%eax
f01060a9:	ba 71 00 00 00       	mov    $0x71,%edx
f01060ae:	ee                   	out    %al,(%dx)
	if (PGNUM(pa) >= npages)
f01060af:	83 3d 88 5e 21 f0 00 	cmpl   $0x0,0xf0215e88
f01060b6:	74 7e                	je     f0106136 <lapic_startap+0xa8>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f01060b8:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f01060bf:	00 00 
	wrv[1] = addr >> 4;
f01060c1:	89 d8                	mov    %ebx,%eax
f01060c3:	c1 e8 04             	shr    $0x4,%eax
f01060c6:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f01060cc:	c1 e6 18             	shl    $0x18,%esi
f01060cf:	89 f2                	mov    %esi,%edx
f01060d1:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01060d6:	e8 30 fe ff ff       	call   f0105f0b <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f01060db:	ba 00 c5 00 00       	mov    $0xc500,%edx
f01060e0:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01060e5:	e8 21 fe ff ff       	call   f0105f0b <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f01060ea:	ba 00 85 00 00       	mov    $0x8500,%edx
f01060ef:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01060f4:	e8 12 fe ff ff       	call   f0105f0b <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01060f9:	c1 eb 0c             	shr    $0xc,%ebx
f01060fc:	80 cf 06             	or     $0x6,%bh
		lapicw(ICRHI, apicid << 24);
f01060ff:	89 f2                	mov    %esi,%edx
f0106101:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106106:	e8 00 fe ff ff       	call   f0105f0b <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010610b:	89 da                	mov    %ebx,%edx
f010610d:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106112:	e8 f4 fd ff ff       	call   f0105f0b <lapicw>
		lapicw(ICRHI, apicid << 24);
f0106117:	89 f2                	mov    %esi,%edx
f0106119:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010611e:	e8 e8 fd ff ff       	call   f0105f0b <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106123:	89 da                	mov    %ebx,%edx
f0106125:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010612a:	e8 dc fd ff ff       	call   f0105f0b <lapicw>
		microdelay(200);
	}
}
f010612f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106132:	5b                   	pop    %ebx
f0106133:	5e                   	pop    %esi
f0106134:	5d                   	pop    %ebp
f0106135:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106136:	68 67 04 00 00       	push   $0x467
f010613b:	68 84 65 10 f0       	push   $0xf0106584
f0106140:	68 98 00 00 00       	push   $0x98
f0106145:	68 d4 81 10 f0       	push   $0xf01081d4
f010614a:	e8 f1 9e ff ff       	call   f0100040 <_panic>

f010614f <lapic_ipi>:

void
lapic_ipi(int vector)
{
f010614f:	55                   	push   %ebp
f0106150:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0106152:	8b 55 08             	mov    0x8(%ebp),%edx
f0106155:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f010615b:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106160:	e8 a6 fd ff ff       	call   f0105f0b <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0106165:	8b 15 04 70 25 f0    	mov    0xf0257004,%edx
f010616b:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106171:	f6 c4 10             	test   $0x10,%ah
f0106174:	75 f5                	jne    f010616b <lapic_ipi+0x1c>
		;
}
f0106176:	5d                   	pop    %ebp
f0106177:	c3                   	ret    

f0106178 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0106178:	55                   	push   %ebp
f0106179:	89 e5                	mov    %esp,%ebp
f010617b:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f010617e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0106184:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106187:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f010618a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0106191:	5d                   	pop    %ebp
f0106192:	c3                   	ret    

f0106193 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0106193:	55                   	push   %ebp
f0106194:	89 e5                	mov    %esp,%ebp
f0106196:	56                   	push   %esi
f0106197:	53                   	push   %ebx
f0106198:	8b 5d 08             	mov    0x8(%ebp),%ebx
	return lock->locked && lock->cpu == thiscpu;
f010619b:	83 3b 00             	cmpl   $0x0,(%ebx)
f010619e:	75 07                	jne    f01061a7 <spin_lock+0x14>
	asm volatile("lock; xchgl %0, %1"
f01061a0:	ba 01 00 00 00       	mov    $0x1,%edx
f01061a5:	eb 34                	jmp    f01061db <spin_lock+0x48>
f01061a7:	8b 73 08             	mov    0x8(%ebx),%esi
f01061aa:	e8 74 fd ff ff       	call   f0105f23 <cpunum>
f01061af:	6b c0 74             	imul   $0x74,%eax,%eax
f01061b2:	05 20 60 21 f0       	add    $0xf0216020,%eax
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f01061b7:	39 c6                	cmp    %eax,%esi
f01061b9:	75 e5                	jne    f01061a0 <spin_lock+0xd>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f01061bb:	8b 5b 04             	mov    0x4(%ebx),%ebx
f01061be:	e8 60 fd ff ff       	call   f0105f23 <cpunum>
f01061c3:	83 ec 0c             	sub    $0xc,%esp
f01061c6:	53                   	push   %ebx
f01061c7:	50                   	push   %eax
f01061c8:	68 e4 81 10 f0       	push   $0xf01081e4
f01061cd:	6a 41                	push   $0x41
f01061cf:	68 48 82 10 f0       	push   $0xf0108248
f01061d4:	e8 67 9e ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f01061d9:	f3 90                	pause  
f01061db:	89 d0                	mov    %edx,%eax
f01061dd:	f0 87 03             	lock xchg %eax,(%ebx)
	while (xchg(&lk->locked, 1) != 0)
f01061e0:	85 c0                	test   %eax,%eax
f01061e2:	75 f5                	jne    f01061d9 <spin_lock+0x46>

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f01061e4:	e8 3a fd ff ff       	call   f0105f23 <cpunum>
f01061e9:	6b c0 74             	imul   $0x74,%eax,%eax
f01061ec:	05 20 60 21 f0       	add    $0xf0216020,%eax
f01061f1:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f01061f4:	83 c3 0c             	add    $0xc,%ebx
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01061f7:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f01061f9:	b8 00 00 00 00       	mov    $0x0,%eax
f01061fe:	eb 0b                	jmp    f010620b <spin_lock+0x78>
		pcs[i] = ebp[1];          // saved %eip
f0106200:	8b 4a 04             	mov    0x4(%edx),%ecx
f0106203:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106206:	8b 12                	mov    (%edx),%edx
	for (i = 0; i < 10; i++){
f0106208:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f010620b:	83 f8 09             	cmp    $0x9,%eax
f010620e:	7f 14                	jg     f0106224 <spin_lock+0x91>
f0106210:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0106216:	77 e8                	ja     f0106200 <spin_lock+0x6d>
f0106218:	eb 0a                	jmp    f0106224 <spin_lock+0x91>
		pcs[i] = 0;
f010621a:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
	for (; i < 10; i++)
f0106221:	83 c0 01             	add    $0x1,%eax
f0106224:	83 f8 09             	cmp    $0x9,%eax
f0106227:	7e f1                	jle    f010621a <spin_lock+0x87>
#endif
}
f0106229:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010622c:	5b                   	pop    %ebx
f010622d:	5e                   	pop    %esi
f010622e:	5d                   	pop    %ebp
f010622f:	c3                   	ret    

f0106230 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106230:	55                   	push   %ebp
f0106231:	89 e5                	mov    %esp,%ebp
f0106233:	57                   	push   %edi
f0106234:	56                   	push   %esi
f0106235:	53                   	push   %ebx
f0106236:	83 ec 4c             	sub    $0x4c,%esp
f0106239:	8b 75 08             	mov    0x8(%ebp),%esi
	return lock->locked && lock->cpu == thiscpu;
f010623c:	83 3e 00             	cmpl   $0x0,(%esi)
f010623f:	75 35                	jne    f0106276 <spin_unlock+0x46>
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0106241:	83 ec 04             	sub    $0x4,%esp
f0106244:	6a 28                	push   $0x28
f0106246:	8d 46 0c             	lea    0xc(%esi),%eax
f0106249:	50                   	push   %eax
f010624a:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f010624d:	53                   	push   %ebx
f010624e:	e8 f9 f6 ff ff       	call   f010594c <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0106253:	8b 46 08             	mov    0x8(%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0106256:	0f b6 38             	movzbl (%eax),%edi
f0106259:	8b 76 04             	mov    0x4(%esi),%esi
f010625c:	e8 c2 fc ff ff       	call   f0105f23 <cpunum>
f0106261:	57                   	push   %edi
f0106262:	56                   	push   %esi
f0106263:	50                   	push   %eax
f0106264:	68 10 82 10 f0       	push   $0xf0108210
f0106269:	e8 da d6 ff ff       	call   f0103948 <cprintf>
f010626e:	83 c4 20             	add    $0x20,%esp
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106271:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0106274:	eb 61                	jmp    f01062d7 <spin_unlock+0xa7>
	return lock->locked && lock->cpu == thiscpu;
f0106276:	8b 5e 08             	mov    0x8(%esi),%ebx
f0106279:	e8 a5 fc ff ff       	call   f0105f23 <cpunum>
f010627e:	6b c0 74             	imul   $0x74,%eax,%eax
f0106281:	05 20 60 21 f0       	add    $0xf0216020,%eax
	if (!holding(lk)) {
f0106286:	39 c3                	cmp    %eax,%ebx
f0106288:	75 b7                	jne    f0106241 <spin_unlock+0x11>
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
	}

	lk->pcs[0] = 0;
f010628a:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0106291:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
	asm volatile("lock; xchgl %0, %1"
f0106298:	b8 00 00 00 00       	mov    $0x0,%eax
f010629d:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f01062a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01062a3:	5b                   	pop    %ebx
f01062a4:	5e                   	pop    %esi
f01062a5:	5f                   	pop    %edi
f01062a6:	5d                   	pop    %ebp
f01062a7:	c3                   	ret    
					pcs[i] - info.eip_fn_addr);
f01062a8:	8b 06                	mov    (%esi),%eax
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f01062aa:	83 ec 04             	sub    $0x4,%esp
f01062ad:	89 c2                	mov    %eax,%edx
f01062af:	2b 55 b8             	sub    -0x48(%ebp),%edx
f01062b2:	52                   	push   %edx
f01062b3:	ff 75 b0             	pushl  -0x50(%ebp)
f01062b6:	ff 75 b4             	pushl  -0x4c(%ebp)
f01062b9:	ff 75 ac             	pushl  -0x54(%ebp)
f01062bc:	ff 75 a8             	pushl  -0x58(%ebp)
f01062bf:	50                   	push   %eax
f01062c0:	68 58 82 10 f0       	push   $0xf0108258
f01062c5:	e8 7e d6 ff ff       	call   f0103948 <cprintf>
f01062ca:	83 c4 20             	add    $0x20,%esp
f01062cd:	83 c3 04             	add    $0x4,%ebx
		for (i = 0; i < 10 && pcs[i]; i++) {
f01062d0:	8d 45 e8             	lea    -0x18(%ebp),%eax
f01062d3:	39 c3                	cmp    %eax,%ebx
f01062d5:	74 2d                	je     f0106304 <spin_unlock+0xd4>
f01062d7:	89 de                	mov    %ebx,%esi
f01062d9:	8b 03                	mov    (%ebx),%eax
f01062db:	85 c0                	test   %eax,%eax
f01062dd:	74 25                	je     f0106304 <spin_unlock+0xd4>
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01062df:	83 ec 08             	sub    $0x8,%esp
f01062e2:	57                   	push   %edi
f01062e3:	50                   	push   %eax
f01062e4:	e8 bd ea ff ff       	call   f0104da6 <debuginfo_eip>
f01062e9:	83 c4 10             	add    $0x10,%esp
f01062ec:	85 c0                	test   %eax,%eax
f01062ee:	79 b8                	jns    f01062a8 <spin_unlock+0x78>
				cprintf("  %08x\n", pcs[i]);
f01062f0:	83 ec 08             	sub    $0x8,%esp
f01062f3:	ff 36                	pushl  (%esi)
f01062f5:	68 6f 82 10 f0       	push   $0xf010826f
f01062fa:	e8 49 d6 ff ff       	call   f0103948 <cprintf>
f01062ff:	83 c4 10             	add    $0x10,%esp
f0106302:	eb c9                	jmp    f01062cd <spin_unlock+0x9d>
		panic("spin_unlock");
f0106304:	83 ec 04             	sub    $0x4,%esp
f0106307:	68 77 82 10 f0       	push   $0xf0108277
f010630c:	6a 67                	push   $0x67
f010630e:	68 48 82 10 f0       	push   $0xf0108248
f0106313:	e8 28 9d ff ff       	call   f0100040 <_panic>
f0106318:	66 90                	xchg   %ax,%ax
f010631a:	66 90                	xchg   %ax,%ax
f010631c:	66 90                	xchg   %ax,%ax
f010631e:	66 90                	xchg   %ax,%ax

f0106320 <__udivdi3>:
f0106320:	55                   	push   %ebp
f0106321:	57                   	push   %edi
f0106322:	56                   	push   %esi
f0106323:	53                   	push   %ebx
f0106324:	83 ec 1c             	sub    $0x1c,%esp
f0106327:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010632b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f010632f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0106333:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0106337:	85 d2                	test   %edx,%edx
f0106339:	75 35                	jne    f0106370 <__udivdi3+0x50>
f010633b:	39 f3                	cmp    %esi,%ebx
f010633d:	0f 87 bd 00 00 00    	ja     f0106400 <__udivdi3+0xe0>
f0106343:	85 db                	test   %ebx,%ebx
f0106345:	89 d9                	mov    %ebx,%ecx
f0106347:	75 0b                	jne    f0106354 <__udivdi3+0x34>
f0106349:	b8 01 00 00 00       	mov    $0x1,%eax
f010634e:	31 d2                	xor    %edx,%edx
f0106350:	f7 f3                	div    %ebx
f0106352:	89 c1                	mov    %eax,%ecx
f0106354:	31 d2                	xor    %edx,%edx
f0106356:	89 f0                	mov    %esi,%eax
f0106358:	f7 f1                	div    %ecx
f010635a:	89 c6                	mov    %eax,%esi
f010635c:	89 e8                	mov    %ebp,%eax
f010635e:	89 f7                	mov    %esi,%edi
f0106360:	f7 f1                	div    %ecx
f0106362:	89 fa                	mov    %edi,%edx
f0106364:	83 c4 1c             	add    $0x1c,%esp
f0106367:	5b                   	pop    %ebx
f0106368:	5e                   	pop    %esi
f0106369:	5f                   	pop    %edi
f010636a:	5d                   	pop    %ebp
f010636b:	c3                   	ret    
f010636c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106370:	39 f2                	cmp    %esi,%edx
f0106372:	77 7c                	ja     f01063f0 <__udivdi3+0xd0>
f0106374:	0f bd fa             	bsr    %edx,%edi
f0106377:	83 f7 1f             	xor    $0x1f,%edi
f010637a:	0f 84 98 00 00 00    	je     f0106418 <__udivdi3+0xf8>
f0106380:	89 f9                	mov    %edi,%ecx
f0106382:	b8 20 00 00 00       	mov    $0x20,%eax
f0106387:	29 f8                	sub    %edi,%eax
f0106389:	d3 e2                	shl    %cl,%edx
f010638b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010638f:	89 c1                	mov    %eax,%ecx
f0106391:	89 da                	mov    %ebx,%edx
f0106393:	d3 ea                	shr    %cl,%edx
f0106395:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0106399:	09 d1                	or     %edx,%ecx
f010639b:	89 f2                	mov    %esi,%edx
f010639d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01063a1:	89 f9                	mov    %edi,%ecx
f01063a3:	d3 e3                	shl    %cl,%ebx
f01063a5:	89 c1                	mov    %eax,%ecx
f01063a7:	d3 ea                	shr    %cl,%edx
f01063a9:	89 f9                	mov    %edi,%ecx
f01063ab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01063af:	d3 e6                	shl    %cl,%esi
f01063b1:	89 eb                	mov    %ebp,%ebx
f01063b3:	89 c1                	mov    %eax,%ecx
f01063b5:	d3 eb                	shr    %cl,%ebx
f01063b7:	09 de                	or     %ebx,%esi
f01063b9:	89 f0                	mov    %esi,%eax
f01063bb:	f7 74 24 08          	divl   0x8(%esp)
f01063bf:	89 d6                	mov    %edx,%esi
f01063c1:	89 c3                	mov    %eax,%ebx
f01063c3:	f7 64 24 0c          	mull   0xc(%esp)
f01063c7:	39 d6                	cmp    %edx,%esi
f01063c9:	72 0c                	jb     f01063d7 <__udivdi3+0xb7>
f01063cb:	89 f9                	mov    %edi,%ecx
f01063cd:	d3 e5                	shl    %cl,%ebp
f01063cf:	39 c5                	cmp    %eax,%ebp
f01063d1:	73 5d                	jae    f0106430 <__udivdi3+0x110>
f01063d3:	39 d6                	cmp    %edx,%esi
f01063d5:	75 59                	jne    f0106430 <__udivdi3+0x110>
f01063d7:	8d 43 ff             	lea    -0x1(%ebx),%eax
f01063da:	31 ff                	xor    %edi,%edi
f01063dc:	89 fa                	mov    %edi,%edx
f01063de:	83 c4 1c             	add    $0x1c,%esp
f01063e1:	5b                   	pop    %ebx
f01063e2:	5e                   	pop    %esi
f01063e3:	5f                   	pop    %edi
f01063e4:	5d                   	pop    %ebp
f01063e5:	c3                   	ret    
f01063e6:	8d 76 00             	lea    0x0(%esi),%esi
f01063e9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f01063f0:	31 ff                	xor    %edi,%edi
f01063f2:	31 c0                	xor    %eax,%eax
f01063f4:	89 fa                	mov    %edi,%edx
f01063f6:	83 c4 1c             	add    $0x1c,%esp
f01063f9:	5b                   	pop    %ebx
f01063fa:	5e                   	pop    %esi
f01063fb:	5f                   	pop    %edi
f01063fc:	5d                   	pop    %ebp
f01063fd:	c3                   	ret    
f01063fe:	66 90                	xchg   %ax,%ax
f0106400:	31 ff                	xor    %edi,%edi
f0106402:	89 e8                	mov    %ebp,%eax
f0106404:	89 f2                	mov    %esi,%edx
f0106406:	f7 f3                	div    %ebx
f0106408:	89 fa                	mov    %edi,%edx
f010640a:	83 c4 1c             	add    $0x1c,%esp
f010640d:	5b                   	pop    %ebx
f010640e:	5e                   	pop    %esi
f010640f:	5f                   	pop    %edi
f0106410:	5d                   	pop    %ebp
f0106411:	c3                   	ret    
f0106412:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106418:	39 f2                	cmp    %esi,%edx
f010641a:	72 06                	jb     f0106422 <__udivdi3+0x102>
f010641c:	31 c0                	xor    %eax,%eax
f010641e:	39 eb                	cmp    %ebp,%ebx
f0106420:	77 d2                	ja     f01063f4 <__udivdi3+0xd4>
f0106422:	b8 01 00 00 00       	mov    $0x1,%eax
f0106427:	eb cb                	jmp    f01063f4 <__udivdi3+0xd4>
f0106429:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106430:	89 d8                	mov    %ebx,%eax
f0106432:	31 ff                	xor    %edi,%edi
f0106434:	eb be                	jmp    f01063f4 <__udivdi3+0xd4>
f0106436:	66 90                	xchg   %ax,%ax
f0106438:	66 90                	xchg   %ax,%ax
f010643a:	66 90                	xchg   %ax,%ax
f010643c:	66 90                	xchg   %ax,%ax
f010643e:	66 90                	xchg   %ax,%ax

f0106440 <__umoddi3>:
f0106440:	55                   	push   %ebp
f0106441:	57                   	push   %edi
f0106442:	56                   	push   %esi
f0106443:	53                   	push   %ebx
f0106444:	83 ec 1c             	sub    $0x1c,%esp
f0106447:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f010644b:	8b 74 24 30          	mov    0x30(%esp),%esi
f010644f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0106453:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106457:	85 ed                	test   %ebp,%ebp
f0106459:	89 f0                	mov    %esi,%eax
f010645b:	89 da                	mov    %ebx,%edx
f010645d:	75 19                	jne    f0106478 <__umoddi3+0x38>
f010645f:	39 df                	cmp    %ebx,%edi
f0106461:	0f 86 b1 00 00 00    	jbe    f0106518 <__umoddi3+0xd8>
f0106467:	f7 f7                	div    %edi
f0106469:	89 d0                	mov    %edx,%eax
f010646b:	31 d2                	xor    %edx,%edx
f010646d:	83 c4 1c             	add    $0x1c,%esp
f0106470:	5b                   	pop    %ebx
f0106471:	5e                   	pop    %esi
f0106472:	5f                   	pop    %edi
f0106473:	5d                   	pop    %ebp
f0106474:	c3                   	ret    
f0106475:	8d 76 00             	lea    0x0(%esi),%esi
f0106478:	39 dd                	cmp    %ebx,%ebp
f010647a:	77 f1                	ja     f010646d <__umoddi3+0x2d>
f010647c:	0f bd cd             	bsr    %ebp,%ecx
f010647f:	83 f1 1f             	xor    $0x1f,%ecx
f0106482:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0106486:	0f 84 b4 00 00 00    	je     f0106540 <__umoddi3+0x100>
f010648c:	b8 20 00 00 00       	mov    $0x20,%eax
f0106491:	89 c2                	mov    %eax,%edx
f0106493:	8b 44 24 04          	mov    0x4(%esp),%eax
f0106497:	29 c2                	sub    %eax,%edx
f0106499:	89 c1                	mov    %eax,%ecx
f010649b:	89 f8                	mov    %edi,%eax
f010649d:	d3 e5                	shl    %cl,%ebp
f010649f:	89 d1                	mov    %edx,%ecx
f01064a1:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01064a5:	d3 e8                	shr    %cl,%eax
f01064a7:	09 c5                	or     %eax,%ebp
f01064a9:	8b 44 24 04          	mov    0x4(%esp),%eax
f01064ad:	89 c1                	mov    %eax,%ecx
f01064af:	d3 e7                	shl    %cl,%edi
f01064b1:	89 d1                	mov    %edx,%ecx
f01064b3:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01064b7:	89 df                	mov    %ebx,%edi
f01064b9:	d3 ef                	shr    %cl,%edi
f01064bb:	89 c1                	mov    %eax,%ecx
f01064bd:	89 f0                	mov    %esi,%eax
f01064bf:	d3 e3                	shl    %cl,%ebx
f01064c1:	89 d1                	mov    %edx,%ecx
f01064c3:	89 fa                	mov    %edi,%edx
f01064c5:	d3 e8                	shr    %cl,%eax
f01064c7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01064cc:	09 d8                	or     %ebx,%eax
f01064ce:	f7 f5                	div    %ebp
f01064d0:	d3 e6                	shl    %cl,%esi
f01064d2:	89 d1                	mov    %edx,%ecx
f01064d4:	f7 64 24 08          	mull   0x8(%esp)
f01064d8:	39 d1                	cmp    %edx,%ecx
f01064da:	89 c3                	mov    %eax,%ebx
f01064dc:	89 d7                	mov    %edx,%edi
f01064de:	72 06                	jb     f01064e6 <__umoddi3+0xa6>
f01064e0:	75 0e                	jne    f01064f0 <__umoddi3+0xb0>
f01064e2:	39 c6                	cmp    %eax,%esi
f01064e4:	73 0a                	jae    f01064f0 <__umoddi3+0xb0>
f01064e6:	2b 44 24 08          	sub    0x8(%esp),%eax
f01064ea:	19 ea                	sbb    %ebp,%edx
f01064ec:	89 d7                	mov    %edx,%edi
f01064ee:	89 c3                	mov    %eax,%ebx
f01064f0:	89 ca                	mov    %ecx,%edx
f01064f2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f01064f7:	29 de                	sub    %ebx,%esi
f01064f9:	19 fa                	sbb    %edi,%edx
f01064fb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f01064ff:	89 d0                	mov    %edx,%eax
f0106501:	d3 e0                	shl    %cl,%eax
f0106503:	89 d9                	mov    %ebx,%ecx
f0106505:	d3 ee                	shr    %cl,%esi
f0106507:	d3 ea                	shr    %cl,%edx
f0106509:	09 f0                	or     %esi,%eax
f010650b:	83 c4 1c             	add    $0x1c,%esp
f010650e:	5b                   	pop    %ebx
f010650f:	5e                   	pop    %esi
f0106510:	5f                   	pop    %edi
f0106511:	5d                   	pop    %ebp
f0106512:	c3                   	ret    
f0106513:	90                   	nop
f0106514:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106518:	85 ff                	test   %edi,%edi
f010651a:	89 f9                	mov    %edi,%ecx
f010651c:	75 0b                	jne    f0106529 <__umoddi3+0xe9>
f010651e:	b8 01 00 00 00       	mov    $0x1,%eax
f0106523:	31 d2                	xor    %edx,%edx
f0106525:	f7 f7                	div    %edi
f0106527:	89 c1                	mov    %eax,%ecx
f0106529:	89 d8                	mov    %ebx,%eax
f010652b:	31 d2                	xor    %edx,%edx
f010652d:	f7 f1                	div    %ecx
f010652f:	89 f0                	mov    %esi,%eax
f0106531:	f7 f1                	div    %ecx
f0106533:	e9 31 ff ff ff       	jmp    f0106469 <__umoddi3+0x29>
f0106538:	90                   	nop
f0106539:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106540:	39 dd                	cmp    %ebx,%ebp
f0106542:	72 08                	jb     f010654c <__umoddi3+0x10c>
f0106544:	39 f7                	cmp    %esi,%edi
f0106546:	0f 87 21 ff ff ff    	ja     f010646d <__umoddi3+0x2d>
f010654c:	89 da                	mov    %ebx,%edx
f010654e:	89 f0                	mov    %esi,%eax
f0106550:	29 f8                	sub    %edi,%eax
f0106552:	19 ea                	sbb    %ebp,%edx
f0106554:	e9 14 ff ff ff       	jmp    f010646d <__umoddi3+0x2d>
