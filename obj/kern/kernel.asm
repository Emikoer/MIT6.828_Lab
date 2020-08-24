
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
f0100048:	83 3d 80 4e 23 f0 00 	cmpl   $0x0,0xf0234e80
f010004f:	74 0f                	je     f0100060 <_panic+0x20>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100051:	83 ec 0c             	sub    $0xc,%esp
f0100054:	6a 00                	push   $0x0
f0100056:	e8 ca 08 00 00       	call   f0100925 <monitor>
f010005b:	83 c4 10             	add    $0x10,%esp
f010005e:	eb f1                	jmp    f0100051 <_panic+0x11>
	panicstr = fmt;
f0100060:	89 35 80 4e 23 f0    	mov    %esi,0xf0234e80
	asm volatile("cli; cld");
f0100066:	fa                   	cli    
f0100067:	fc                   	cld    
	va_start(ap, fmt);
f0100068:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010006b:	e8 bb 5e 00 00       	call   f0105f2b <cpunum>
f0100070:	ff 75 0c             	pushl  0xc(%ebp)
f0100073:	ff 75 08             	pushl  0x8(%ebp)
f0100076:	50                   	push   %eax
f0100077:	68 60 65 10 f0       	push   $0xf0106560
f010007c:	e8 c3 38 00 00       	call   f0103944 <cprintf>
	vcprintf(fmt, ap);
f0100081:	83 c4 08             	add    $0x8,%esp
f0100084:	53                   	push   %ebx
f0100085:	56                   	push   %esi
f0100086:	e8 93 38 00 00       	call   f010391e <vcprintf>
	cprintf("\n");
f010008b:	c7 04 24 c9 68 10 f0 	movl   $0xf01068c9,(%esp)
f0100092:	e8 ad 38 00 00       	call   f0103944 <cprintf>
f0100097:	83 c4 10             	add    $0x10,%esp
f010009a:	eb b5                	jmp    f0100051 <_panic+0x11>

f010009c <i386_init>:
{
f010009c:	55                   	push   %ebp
f010009d:	89 e5                	mov    %esp,%ebp
f010009f:	53                   	push   %ebx
f01000a0:	83 ec 04             	sub    $0x4,%esp
	cons_init();
f01000a3:	e8 95 05 00 00       	call   f010063d <cons_init>
	mem_init();
f01000a8:	e8 4c 12 00 00       	call   f01012f9 <mem_init>
	env_init();
f01000ad:	e8 67 30 00 00       	call   f0103119 <env_init>
	trap_init();
f01000b2:	e8 6f 39 00 00       	call   f0103a26 <trap_init>
	mp_init();
f01000b7:	e8 5d 5b 00 00       	call   f0105c19 <mp_init>
	lapic_init();
f01000bc:	e8 84 5e 00 00       	call   f0105f45 <lapic_init>
	pic_init();
f01000c1:	e8 a1 37 00 00       	call   f0103867 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000c6:	83 ec 0c             	sub    $0xc,%esp
f01000c9:	68 c0 23 12 f0       	push   $0xf01223c0
f01000ce:	e8 c8 60 00 00       	call   f010619b <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000d3:	83 c4 10             	add    $0x10,%esp
f01000d6:	83 3d 88 4e 23 f0 07 	cmpl   $0x7,0xf0234e88
f01000dd:	76 27                	jbe    f0100106 <i386_init+0x6a>
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01000df:	83 ec 04             	sub    $0x4,%esp
f01000e2:	b8 7e 5b 10 f0       	mov    $0xf0105b7e,%eax
f01000e7:	2d 04 5b 10 f0       	sub    $0xf0105b04,%eax
f01000ec:	50                   	push   %eax
f01000ed:	68 04 5b 10 f0       	push   $0xf0105b04
f01000f2:	68 00 70 00 f0       	push   $0xf0007000
f01000f7:	e8 58 58 00 00       	call   f0105954 <memmove>
f01000fc:	83 c4 10             	add    $0x10,%esp
	for (c = cpus; c < cpus + ncpu; c++) {
f01000ff:	bb 20 50 23 f0       	mov    $0xf0235020,%ebx
f0100104:	eb 19                	jmp    f010011f <i386_init+0x83>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100106:	68 00 70 00 00       	push   $0x7000
f010010b:	68 84 65 10 f0       	push   $0xf0106584
f0100110:	6a 5a                	push   $0x5a
f0100112:	68 cc 65 10 f0       	push   $0xf01065cc
f0100117:	e8 24 ff ff ff       	call   f0100040 <_panic>
f010011c:	83 c3 74             	add    $0x74,%ebx
f010011f:	6b 05 c4 53 23 f0 74 	imul   $0x74,0xf02353c4,%eax
f0100126:	05 20 50 23 f0       	add    $0xf0235020,%eax
f010012b:	39 c3                	cmp    %eax,%ebx
f010012d:	73 4c                	jae    f010017b <i386_init+0xdf>
		if (c == cpus + cpunum())  // We've started already.
f010012f:	e8 f7 5d 00 00       	call   f0105f2b <cpunum>
f0100134:	6b c0 74             	imul   $0x74,%eax,%eax
f0100137:	05 20 50 23 f0       	add    $0xf0235020,%eax
f010013c:	39 c3                	cmp    %eax,%ebx
f010013e:	74 dc                	je     f010011c <i386_init+0x80>
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100140:	89 d8                	mov    %ebx,%eax
f0100142:	2d 20 50 23 f0       	sub    $0xf0235020,%eax
f0100147:	c1 f8 02             	sar    $0x2,%eax
f010014a:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100150:	c1 e0 0f             	shl    $0xf,%eax
f0100153:	05 00 e0 23 f0       	add    $0xf023e000,%eax
f0100158:	a3 84 4e 23 f0       	mov    %eax,0xf0234e84
		lapic_startap(c->cpu_id, PADDR(code));
f010015d:	83 ec 08             	sub    $0x8,%esp
f0100160:	68 00 70 00 00       	push   $0x7000
f0100165:	0f b6 03             	movzbl (%ebx),%eax
f0100168:	50                   	push   %eax
f0100169:	e8 28 5f 00 00       	call   f0106096 <lapic_startap>
f010016e:	83 c4 10             	add    $0x10,%esp
		while(c->cpu_status != CPU_STARTED)
f0100171:	8b 43 04             	mov    0x4(%ebx),%eax
f0100174:	83 f8 01             	cmp    $0x1,%eax
f0100177:	75 f8                	jne    f0100171 <i386_init+0xd5>
f0100179:	eb a1                	jmp    f010011c <i386_init+0x80>
	ENV_CREATE(TEST, ENV_TYPE_USER);
f010017b:	83 ec 08             	sub    $0x8,%esp
f010017e:	6a 00                	push   $0x0
f0100180:	68 c0 67 21 f0       	push   $0xf02167c0
f0100185:	e8 88 31 00 00       	call   f0103312 <env_create>
         sched_yield();
f010018a:	e8 d1 43 00 00       	call   f0104560 <sched_yield>

f010018f <mp_main>:
{
f010018f:	55                   	push   %ebp
f0100190:	89 e5                	mov    %esp,%ebp
f0100192:	83 ec 08             	sub    $0x8,%esp
	lcr3(PADDR(kern_pgdir));
f0100195:	a1 8c 4e 23 f0       	mov    0xf0234e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f010019a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010019f:	77 12                	ja     f01001b3 <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001a1:	50                   	push   %eax
f01001a2:	68 a8 65 10 f0       	push   $0xf01065a8
f01001a7:	6a 71                	push   $0x71
f01001a9:	68 cc 65 10 f0       	push   $0xf01065cc
f01001ae:	e8 8d fe ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01001b3:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01001b8:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001bb:	e8 6b 5d 00 00       	call   f0105f2b <cpunum>
f01001c0:	83 ec 08             	sub    $0x8,%esp
f01001c3:	50                   	push   %eax
f01001c4:	68 d8 65 10 f0       	push   $0xf01065d8
f01001c9:	e8 76 37 00 00       	call   f0103944 <cprintf>
	lapic_init();
f01001ce:	e8 72 5d 00 00       	call   f0105f45 <lapic_init>
	env_init_percpu();
f01001d3:	e8 11 2f 00 00       	call   f01030e9 <env_init_percpu>
	trap_init_percpu();
f01001d8:	e8 7b 37 00 00       	call   f0103958 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f01001dd:	e8 49 5d 00 00       	call   f0105f2b <cpunum>
f01001e2:	6b d0 74             	imul   $0x74,%eax,%edx
f01001e5:	83 c2 04             	add    $0x4,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01001e8:	b8 01 00 00 00       	mov    $0x1,%eax
f01001ed:	f0 87 82 20 50 23 f0 	lock xchg %eax,-0xfdcafe0(%edx)
f01001f4:	c7 04 24 c0 23 12 f0 	movl   $0xf01223c0,(%esp)
f01001fb:	e8 9b 5f 00 00       	call   f010619b <spin_lock>
	cprintf("test...\n");
f0100200:	c7 04 24 ee 65 10 f0 	movl   $0xf01065ee,(%esp)
f0100207:	e8 38 37 00 00       	call   f0103944 <cprintf>
	sched_yield();
f010020c:	e8 4f 43 00 00       	call   f0104560 <sched_yield>

f0100211 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100211:	55                   	push   %ebp
f0100212:	89 e5                	mov    %esp,%ebp
f0100214:	53                   	push   %ebx
f0100215:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100218:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f010021b:	ff 75 0c             	pushl  0xc(%ebp)
f010021e:	ff 75 08             	pushl  0x8(%ebp)
f0100221:	68 f7 65 10 f0       	push   $0xf01065f7
f0100226:	e8 19 37 00 00       	call   f0103944 <cprintf>
	vcprintf(fmt, ap);
f010022b:	83 c4 08             	add    $0x8,%esp
f010022e:	53                   	push   %ebx
f010022f:	ff 75 10             	pushl  0x10(%ebp)
f0100232:	e8 e7 36 00 00       	call   f010391e <vcprintf>
	cprintf("\n");
f0100237:	c7 04 24 c9 68 10 f0 	movl   $0xf01068c9,(%esp)
f010023e:	e8 01 37 00 00       	call   f0103944 <cprintf>
	va_end(ap);
}
f0100243:	83 c4 10             	add    $0x10,%esp
f0100246:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100249:	c9                   	leave  
f010024a:	c3                   	ret    

f010024b <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010024b:	55                   	push   %ebp
f010024c:	89 e5                	mov    %esp,%ebp
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010024e:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100253:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100254:	a8 01                	test   $0x1,%al
f0100256:	74 0b                	je     f0100263 <serial_proc_data+0x18>
f0100258:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010025d:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010025e:	0f b6 c0             	movzbl %al,%eax
}
f0100261:	5d                   	pop    %ebp
f0100262:	c3                   	ret    
		return -1;
f0100263:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100268:	eb f7                	jmp    f0100261 <serial_proc_data+0x16>

f010026a <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010026a:	55                   	push   %ebp
f010026b:	89 e5                	mov    %esp,%ebp
f010026d:	53                   	push   %ebx
f010026e:	83 ec 04             	sub    $0x4,%esp
f0100271:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100273:	ff d3                	call   *%ebx
f0100275:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100278:	74 2d                	je     f01002a7 <cons_intr+0x3d>
		if (c == 0)
f010027a:	85 c0                	test   %eax,%eax
f010027c:	74 f5                	je     f0100273 <cons_intr+0x9>
			continue;
		cons.buf[cons.wpos++] = c;
f010027e:	8b 0d 24 42 23 f0    	mov    0xf0234224,%ecx
f0100284:	8d 51 01             	lea    0x1(%ecx),%edx
f0100287:	89 15 24 42 23 f0    	mov    %edx,0xf0234224
f010028d:	88 81 20 40 23 f0    	mov    %al,-0xfdcbfe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f0100293:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100299:	75 d8                	jne    f0100273 <cons_intr+0x9>
			cons.wpos = 0;
f010029b:	c7 05 24 42 23 f0 00 	movl   $0x0,0xf0234224
f01002a2:	00 00 00 
f01002a5:	eb cc                	jmp    f0100273 <cons_intr+0x9>
	}
}
f01002a7:	83 c4 04             	add    $0x4,%esp
f01002aa:	5b                   	pop    %ebx
f01002ab:	5d                   	pop    %ebp
f01002ac:	c3                   	ret    

f01002ad <kbd_proc_data>:
{
f01002ad:	55                   	push   %ebp
f01002ae:	89 e5                	mov    %esp,%ebp
f01002b0:	53                   	push   %ebx
f01002b1:	83 ec 04             	sub    $0x4,%esp
f01002b4:	ba 64 00 00 00       	mov    $0x64,%edx
f01002b9:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f01002ba:	a8 01                	test   $0x1,%al
f01002bc:	0f 84 fa 00 00 00    	je     f01003bc <kbd_proc_data+0x10f>
	if (stat & KBS_TERR)
f01002c2:	a8 20                	test   $0x20,%al
f01002c4:	0f 85 f9 00 00 00    	jne    f01003c3 <kbd_proc_data+0x116>
f01002ca:	ba 60 00 00 00       	mov    $0x60,%edx
f01002cf:	ec                   	in     (%dx),%al
f01002d0:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f01002d2:	3c e0                	cmp    $0xe0,%al
f01002d4:	0f 84 8e 00 00 00    	je     f0100368 <kbd_proc_data+0xbb>
	} else if (data & 0x80) {
f01002da:	84 c0                	test   %al,%al
f01002dc:	0f 88 99 00 00 00    	js     f010037b <kbd_proc_data+0xce>
	} else if (shift & E0ESC) {
f01002e2:	8b 0d 00 40 23 f0    	mov    0xf0234000,%ecx
f01002e8:	f6 c1 40             	test   $0x40,%cl
f01002eb:	74 0e                	je     f01002fb <kbd_proc_data+0x4e>
		data |= 0x80;
f01002ed:	83 c8 80             	or     $0xffffff80,%eax
f01002f0:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f01002f2:	83 e1 bf             	and    $0xffffffbf,%ecx
f01002f5:	89 0d 00 40 23 f0    	mov    %ecx,0xf0234000
	shift |= shiftcode[data];
f01002fb:	0f b6 d2             	movzbl %dl,%edx
f01002fe:	0f b6 82 60 67 10 f0 	movzbl -0xfef98a0(%edx),%eax
f0100305:	0b 05 00 40 23 f0    	or     0xf0234000,%eax
	shift ^= togglecode[data];
f010030b:	0f b6 8a 60 66 10 f0 	movzbl -0xfef99a0(%edx),%ecx
f0100312:	31 c8                	xor    %ecx,%eax
f0100314:	a3 00 40 23 f0       	mov    %eax,0xf0234000
	c = charcode[shift & (CTL | SHIFT)][data];
f0100319:	89 c1                	mov    %eax,%ecx
f010031b:	83 e1 03             	and    $0x3,%ecx
f010031e:	8b 0c 8d 40 66 10 f0 	mov    -0xfef99c0(,%ecx,4),%ecx
f0100325:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100329:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f010032c:	a8 08                	test   $0x8,%al
f010032e:	74 0d                	je     f010033d <kbd_proc_data+0x90>
		if ('a' <= c && c <= 'z')
f0100330:	89 da                	mov    %ebx,%edx
f0100332:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100335:	83 f9 19             	cmp    $0x19,%ecx
f0100338:	77 74                	ja     f01003ae <kbd_proc_data+0x101>
			c += 'A' - 'a';
f010033a:	83 eb 20             	sub    $0x20,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010033d:	f7 d0                	not    %eax
f010033f:	a8 06                	test   $0x6,%al
f0100341:	75 31                	jne    f0100374 <kbd_proc_data+0xc7>
f0100343:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100349:	75 29                	jne    f0100374 <kbd_proc_data+0xc7>
		cprintf("Rebooting!\n");
f010034b:	83 ec 0c             	sub    $0xc,%esp
f010034e:	68 11 66 10 f0       	push   $0xf0106611
f0100353:	e8 ec 35 00 00       	call   f0103944 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100358:	b8 03 00 00 00       	mov    $0x3,%eax
f010035d:	ba 92 00 00 00       	mov    $0x92,%edx
f0100362:	ee                   	out    %al,(%dx)
f0100363:	83 c4 10             	add    $0x10,%esp
f0100366:	eb 0c                	jmp    f0100374 <kbd_proc_data+0xc7>
		shift |= E0ESC;
f0100368:	83 0d 00 40 23 f0 40 	orl    $0x40,0xf0234000
		return 0;
f010036f:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0100374:	89 d8                	mov    %ebx,%eax
f0100376:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100379:	c9                   	leave  
f010037a:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f010037b:	8b 0d 00 40 23 f0    	mov    0xf0234000,%ecx
f0100381:	89 cb                	mov    %ecx,%ebx
f0100383:	83 e3 40             	and    $0x40,%ebx
f0100386:	83 e0 7f             	and    $0x7f,%eax
f0100389:	85 db                	test   %ebx,%ebx
f010038b:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010038e:	0f b6 d2             	movzbl %dl,%edx
f0100391:	0f b6 82 60 67 10 f0 	movzbl -0xfef98a0(%edx),%eax
f0100398:	83 c8 40             	or     $0x40,%eax
f010039b:	0f b6 c0             	movzbl %al,%eax
f010039e:	f7 d0                	not    %eax
f01003a0:	21 c8                	and    %ecx,%eax
f01003a2:	a3 00 40 23 f0       	mov    %eax,0xf0234000
		return 0;
f01003a7:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003ac:	eb c6                	jmp    f0100374 <kbd_proc_data+0xc7>
		else if ('A' <= c && c <= 'Z')
f01003ae:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01003b1:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01003b4:	83 fa 1a             	cmp    $0x1a,%edx
f01003b7:	0f 42 d9             	cmovb  %ecx,%ebx
f01003ba:	eb 81                	jmp    f010033d <kbd_proc_data+0x90>
		return -1;
f01003bc:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01003c1:	eb b1                	jmp    f0100374 <kbd_proc_data+0xc7>
		return -1;
f01003c3:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01003c8:	eb aa                	jmp    f0100374 <kbd_proc_data+0xc7>

f01003ca <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003ca:	55                   	push   %ebp
f01003cb:	89 e5                	mov    %esp,%ebp
f01003cd:	57                   	push   %edi
f01003ce:	56                   	push   %esi
f01003cf:	53                   	push   %ebx
f01003d0:	83 ec 1c             	sub    $0x1c,%esp
f01003d3:	89 c7                	mov    %eax,%edi
	for (i = 0;
f01003d5:	bb 00 00 00 00       	mov    $0x0,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003da:	be fd 03 00 00       	mov    $0x3fd,%esi
f01003df:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003e4:	eb 09                	jmp    f01003ef <cons_putc+0x25>
f01003e6:	89 ca                	mov    %ecx,%edx
f01003e8:	ec                   	in     (%dx),%al
f01003e9:	ec                   	in     (%dx),%al
f01003ea:	ec                   	in     (%dx),%al
f01003eb:	ec                   	in     (%dx),%al
	     i++)
f01003ec:	83 c3 01             	add    $0x1,%ebx
f01003ef:	89 f2                	mov    %esi,%edx
f01003f1:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01003f2:	a8 20                	test   $0x20,%al
f01003f4:	75 08                	jne    f01003fe <cons_putc+0x34>
f01003f6:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01003fc:	7e e8                	jle    f01003e6 <cons_putc+0x1c>
	outb(COM1 + COM_TX, c);
f01003fe:	89 f8                	mov    %edi,%eax
f0100400:	88 45 e7             	mov    %al,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100403:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100408:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100409:	bb 00 00 00 00       	mov    $0x0,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010040e:	be 79 03 00 00       	mov    $0x379,%esi
f0100413:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100418:	eb 09                	jmp    f0100423 <cons_putc+0x59>
f010041a:	89 ca                	mov    %ecx,%edx
f010041c:	ec                   	in     (%dx),%al
f010041d:	ec                   	in     (%dx),%al
f010041e:	ec                   	in     (%dx),%al
f010041f:	ec                   	in     (%dx),%al
f0100420:	83 c3 01             	add    $0x1,%ebx
f0100423:	89 f2                	mov    %esi,%edx
f0100425:	ec                   	in     (%dx),%al
f0100426:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f010042c:	7f 04                	jg     f0100432 <cons_putc+0x68>
f010042e:	84 c0                	test   %al,%al
f0100430:	79 e8                	jns    f010041a <cons_putc+0x50>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100432:	ba 78 03 00 00       	mov    $0x378,%edx
f0100437:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f010043b:	ee                   	out    %al,(%dx)
f010043c:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100441:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100446:	ee                   	out    %al,(%dx)
f0100447:	b8 08 00 00 00       	mov    $0x8,%eax
f010044c:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f010044d:	89 fa                	mov    %edi,%edx
f010044f:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100455:	89 f8                	mov    %edi,%eax
f0100457:	80 cc 07             	or     $0x7,%ah
f010045a:	85 d2                	test   %edx,%edx
f010045c:	0f 44 f8             	cmove  %eax,%edi
	switch (c & 0xff) {
f010045f:	89 f8                	mov    %edi,%eax
f0100461:	0f b6 c0             	movzbl %al,%eax
f0100464:	83 f8 09             	cmp    $0x9,%eax
f0100467:	0f 84 b6 00 00 00    	je     f0100523 <cons_putc+0x159>
f010046d:	83 f8 09             	cmp    $0x9,%eax
f0100470:	7e 73                	jle    f01004e5 <cons_putc+0x11b>
f0100472:	83 f8 0a             	cmp    $0xa,%eax
f0100475:	0f 84 9b 00 00 00    	je     f0100516 <cons_putc+0x14c>
f010047b:	83 f8 0d             	cmp    $0xd,%eax
f010047e:	0f 85 d6 00 00 00    	jne    f010055a <cons_putc+0x190>
		crt_pos -= (crt_pos % CRT_COLS);
f0100484:	0f b7 05 28 42 23 f0 	movzwl 0xf0234228,%eax
f010048b:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100491:	c1 e8 16             	shr    $0x16,%eax
f0100494:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100497:	c1 e0 04             	shl    $0x4,%eax
f010049a:	66 a3 28 42 23 f0    	mov    %ax,0xf0234228
	if (crt_pos >= CRT_SIZE) {
f01004a0:	66 81 3d 28 42 23 f0 	cmpw   $0x7cf,0xf0234228
f01004a7:	cf 07 
f01004a9:	0f 87 ce 00 00 00    	ja     f010057d <cons_putc+0x1b3>
	outb(addr_6845, 14);
f01004af:	8b 0d 30 42 23 f0    	mov    0xf0234230,%ecx
f01004b5:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004ba:	89 ca                	mov    %ecx,%edx
f01004bc:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004bd:	0f b7 1d 28 42 23 f0 	movzwl 0xf0234228,%ebx
f01004c4:	8d 71 01             	lea    0x1(%ecx),%esi
f01004c7:	89 d8                	mov    %ebx,%eax
f01004c9:	66 c1 e8 08          	shr    $0x8,%ax
f01004cd:	89 f2                	mov    %esi,%edx
f01004cf:	ee                   	out    %al,(%dx)
f01004d0:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004d5:	89 ca                	mov    %ecx,%edx
f01004d7:	ee                   	out    %al,(%dx)
f01004d8:	89 d8                	mov    %ebx,%eax
f01004da:	89 f2                	mov    %esi,%edx
f01004dc:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004e0:	5b                   	pop    %ebx
f01004e1:	5e                   	pop    %esi
f01004e2:	5f                   	pop    %edi
f01004e3:	5d                   	pop    %ebp
f01004e4:	c3                   	ret    
	switch (c & 0xff) {
f01004e5:	83 f8 08             	cmp    $0x8,%eax
f01004e8:	75 70                	jne    f010055a <cons_putc+0x190>
		if (crt_pos > 0) {
f01004ea:	0f b7 05 28 42 23 f0 	movzwl 0xf0234228,%eax
f01004f1:	66 85 c0             	test   %ax,%ax
f01004f4:	74 b9                	je     f01004af <cons_putc+0xe5>
			crt_pos--;
f01004f6:	83 e8 01             	sub    $0x1,%eax
f01004f9:	66 a3 28 42 23 f0    	mov    %ax,0xf0234228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004ff:	0f b7 c0             	movzwl %ax,%eax
f0100502:	66 81 e7 00 ff       	and    $0xff00,%di
f0100507:	83 cf 20             	or     $0x20,%edi
f010050a:	8b 15 2c 42 23 f0    	mov    0xf023422c,%edx
f0100510:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100514:	eb 8a                	jmp    f01004a0 <cons_putc+0xd6>
		crt_pos += CRT_COLS;
f0100516:	66 83 05 28 42 23 f0 	addw   $0x50,0xf0234228
f010051d:	50 
f010051e:	e9 61 ff ff ff       	jmp    f0100484 <cons_putc+0xba>
		cons_putc(' ');
f0100523:	b8 20 00 00 00       	mov    $0x20,%eax
f0100528:	e8 9d fe ff ff       	call   f01003ca <cons_putc>
		cons_putc(' ');
f010052d:	b8 20 00 00 00       	mov    $0x20,%eax
f0100532:	e8 93 fe ff ff       	call   f01003ca <cons_putc>
		cons_putc(' ');
f0100537:	b8 20 00 00 00       	mov    $0x20,%eax
f010053c:	e8 89 fe ff ff       	call   f01003ca <cons_putc>
		cons_putc(' ');
f0100541:	b8 20 00 00 00       	mov    $0x20,%eax
f0100546:	e8 7f fe ff ff       	call   f01003ca <cons_putc>
		cons_putc(' ');
f010054b:	b8 20 00 00 00       	mov    $0x20,%eax
f0100550:	e8 75 fe ff ff       	call   f01003ca <cons_putc>
f0100555:	e9 46 ff ff ff       	jmp    f01004a0 <cons_putc+0xd6>
		crt_buf[crt_pos++] = c;		/* write the character */
f010055a:	0f b7 05 28 42 23 f0 	movzwl 0xf0234228,%eax
f0100561:	8d 50 01             	lea    0x1(%eax),%edx
f0100564:	66 89 15 28 42 23 f0 	mov    %dx,0xf0234228
f010056b:	0f b7 c0             	movzwl %ax,%eax
f010056e:	8b 15 2c 42 23 f0    	mov    0xf023422c,%edx
f0100574:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100578:	e9 23 ff ff ff       	jmp    f01004a0 <cons_putc+0xd6>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010057d:	a1 2c 42 23 f0       	mov    0xf023422c,%eax
f0100582:	83 ec 04             	sub    $0x4,%esp
f0100585:	68 00 0f 00 00       	push   $0xf00
f010058a:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100590:	52                   	push   %edx
f0100591:	50                   	push   %eax
f0100592:	e8 bd 53 00 00       	call   f0105954 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f0100597:	8b 15 2c 42 23 f0    	mov    0xf023422c,%edx
f010059d:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01005a3:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01005a9:	83 c4 10             	add    $0x10,%esp
f01005ac:	66 c7 00 20 07       	movw   $0x720,(%eax)
f01005b1:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005b4:	39 d0                	cmp    %edx,%eax
f01005b6:	75 f4                	jne    f01005ac <cons_putc+0x1e2>
		crt_pos -= CRT_COLS;
f01005b8:	66 83 2d 28 42 23 f0 	subw   $0x50,0xf0234228
f01005bf:	50 
f01005c0:	e9 ea fe ff ff       	jmp    f01004af <cons_putc+0xe5>

f01005c5 <serial_intr>:
	if (serial_exists)
f01005c5:	80 3d 34 42 23 f0 00 	cmpb   $0x0,0xf0234234
f01005cc:	75 02                	jne    f01005d0 <serial_intr+0xb>
f01005ce:	f3 c3                	repz ret 
{
f01005d0:	55                   	push   %ebp
f01005d1:	89 e5                	mov    %esp,%ebp
f01005d3:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f01005d6:	b8 4b 02 10 f0       	mov    $0xf010024b,%eax
f01005db:	e8 8a fc ff ff       	call   f010026a <cons_intr>
}
f01005e0:	c9                   	leave  
f01005e1:	c3                   	ret    

f01005e2 <kbd_intr>:
{
f01005e2:	55                   	push   %ebp
f01005e3:	89 e5                	mov    %esp,%ebp
f01005e5:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01005e8:	b8 ad 02 10 f0       	mov    $0xf01002ad,%eax
f01005ed:	e8 78 fc ff ff       	call   f010026a <cons_intr>
}
f01005f2:	c9                   	leave  
f01005f3:	c3                   	ret    

f01005f4 <cons_getc>:
{
f01005f4:	55                   	push   %ebp
f01005f5:	89 e5                	mov    %esp,%ebp
f01005f7:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f01005fa:	e8 c6 ff ff ff       	call   f01005c5 <serial_intr>
	kbd_intr();
f01005ff:	e8 de ff ff ff       	call   f01005e2 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f0100604:	8b 15 20 42 23 f0    	mov    0xf0234220,%edx
	return 0;
f010060a:	b8 00 00 00 00       	mov    $0x0,%eax
	if (cons.rpos != cons.wpos) {
f010060f:	3b 15 24 42 23 f0    	cmp    0xf0234224,%edx
f0100615:	74 18                	je     f010062f <cons_getc+0x3b>
		c = cons.buf[cons.rpos++];
f0100617:	8d 4a 01             	lea    0x1(%edx),%ecx
f010061a:	89 0d 20 42 23 f0    	mov    %ecx,0xf0234220
f0100620:	0f b6 82 20 40 23 f0 	movzbl -0xfdcbfe0(%edx),%eax
		if (cons.rpos == CONSBUFSIZE)
f0100627:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f010062d:	74 02                	je     f0100631 <cons_getc+0x3d>
}
f010062f:	c9                   	leave  
f0100630:	c3                   	ret    
			cons.rpos = 0;
f0100631:	c7 05 20 42 23 f0 00 	movl   $0x0,0xf0234220
f0100638:	00 00 00 
f010063b:	eb f2                	jmp    f010062f <cons_getc+0x3b>

f010063d <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f010063d:	55                   	push   %ebp
f010063e:	89 e5                	mov    %esp,%ebp
f0100640:	57                   	push   %edi
f0100641:	56                   	push   %esi
f0100642:	53                   	push   %ebx
f0100643:	83 ec 0c             	sub    $0xc,%esp
	was = *cp;
f0100646:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010064d:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100654:	5a a5 
	if (*cp != 0xA55A) {
f0100656:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010065d:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100661:	0f 84 d4 00 00 00    	je     f010073b <cons_init+0xfe>
		addr_6845 = MONO_BASE;
f0100667:	c7 05 30 42 23 f0 b4 	movl   $0x3b4,0xf0234230
f010066e:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100671:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
	outb(addr_6845, 14);
f0100676:	8b 3d 30 42 23 f0    	mov    0xf0234230,%edi
f010067c:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100681:	89 fa                	mov    %edi,%edx
f0100683:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100684:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100687:	89 ca                	mov    %ecx,%edx
f0100689:	ec                   	in     (%dx),%al
f010068a:	0f b6 c0             	movzbl %al,%eax
f010068d:	c1 e0 08             	shl    $0x8,%eax
f0100690:	89 c3                	mov    %eax,%ebx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100692:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100697:	89 fa                	mov    %edi,%edx
f0100699:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010069a:	89 ca                	mov    %ecx,%edx
f010069c:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f010069d:	89 35 2c 42 23 f0    	mov    %esi,0xf023422c
	pos |= inb(addr_6845 + 1);
f01006a3:	0f b6 c0             	movzbl %al,%eax
f01006a6:	09 d8                	or     %ebx,%eax
	crt_pos = pos;
f01006a8:	66 a3 28 42 23 f0    	mov    %ax,0xf0234228
	kbd_intr();
f01006ae:	e8 2f ff ff ff       	call   f01005e2 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01006b3:	83 ec 0c             	sub    $0xc,%esp
f01006b6:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f01006bd:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006c2:	50                   	push   %eax
f01006c3:	e8 21 31 00 00       	call   f01037e9 <irq_setmask_8259A>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006c8:	bb 00 00 00 00       	mov    $0x0,%ebx
f01006cd:	b9 fa 03 00 00       	mov    $0x3fa,%ecx
f01006d2:	89 d8                	mov    %ebx,%eax
f01006d4:	89 ca                	mov    %ecx,%edx
f01006d6:	ee                   	out    %al,(%dx)
f01006d7:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01006dc:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006e1:	89 fa                	mov    %edi,%edx
f01006e3:	ee                   	out    %al,(%dx)
f01006e4:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006e9:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006ee:	ee                   	out    %al,(%dx)
f01006ef:	be f9 03 00 00       	mov    $0x3f9,%esi
f01006f4:	89 d8                	mov    %ebx,%eax
f01006f6:	89 f2                	mov    %esi,%edx
f01006f8:	ee                   	out    %al,(%dx)
f01006f9:	b8 03 00 00 00       	mov    $0x3,%eax
f01006fe:	89 fa                	mov    %edi,%edx
f0100700:	ee                   	out    %al,(%dx)
f0100701:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100706:	89 d8                	mov    %ebx,%eax
f0100708:	ee                   	out    %al,(%dx)
f0100709:	b8 01 00 00 00       	mov    $0x1,%eax
f010070e:	89 f2                	mov    %esi,%edx
f0100710:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100711:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100716:	ec                   	in     (%dx),%al
f0100717:	89 c3                	mov    %eax,%ebx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100719:	83 c4 10             	add    $0x10,%esp
f010071c:	3c ff                	cmp    $0xff,%al
f010071e:	0f 95 05 34 42 23 f0 	setne  0xf0234234
f0100725:	89 ca                	mov    %ecx,%edx
f0100727:	ec                   	in     (%dx),%al
f0100728:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010072d:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010072e:	80 fb ff             	cmp    $0xff,%bl
f0100731:	74 23                	je     f0100756 <cons_init+0x119>
		cprintf("Serial port does not exist!\n");
}
f0100733:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100736:	5b                   	pop    %ebx
f0100737:	5e                   	pop    %esi
f0100738:	5f                   	pop    %edi
f0100739:	5d                   	pop    %ebp
f010073a:	c3                   	ret    
		*cp = was;
f010073b:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100742:	c7 05 30 42 23 f0 d4 	movl   $0x3d4,0xf0234230
f0100749:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010074c:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f0100751:	e9 20 ff ff ff       	jmp    f0100676 <cons_init+0x39>
		cprintf("Serial port does not exist!\n");
f0100756:	83 ec 0c             	sub    $0xc,%esp
f0100759:	68 1d 66 10 f0       	push   $0xf010661d
f010075e:	e8 e1 31 00 00       	call   f0103944 <cprintf>
f0100763:	83 c4 10             	add    $0x10,%esp
}
f0100766:	eb cb                	jmp    f0100733 <cons_init+0xf6>

f0100768 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100768:	55                   	push   %ebp
f0100769:	89 e5                	mov    %esp,%ebp
f010076b:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010076e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100771:	e8 54 fc ff ff       	call   f01003ca <cons_putc>
}
f0100776:	c9                   	leave  
f0100777:	c3                   	ret    

f0100778 <getchar>:

int
getchar(void)
{
f0100778:	55                   	push   %ebp
f0100779:	89 e5                	mov    %esp,%ebp
f010077b:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010077e:	e8 71 fe ff ff       	call   f01005f4 <cons_getc>
f0100783:	85 c0                	test   %eax,%eax
f0100785:	74 f7                	je     f010077e <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100787:	c9                   	leave  
f0100788:	c3                   	ret    

f0100789 <iscons>:

int
iscons(int fdnum)
{
f0100789:	55                   	push   %ebp
f010078a:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010078c:	b8 01 00 00 00       	mov    $0x1,%eax
f0100791:	5d                   	pop    %ebp
f0100792:	c3                   	ret    

f0100793 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100793:	55                   	push   %ebp
f0100794:	89 e5                	mov    %esp,%ebp
f0100796:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100799:	68 60 68 10 f0       	push   $0xf0106860
f010079e:	68 7e 68 10 f0       	push   $0xf010687e
f01007a3:	68 83 68 10 f0       	push   $0xf0106883
f01007a8:	e8 97 31 00 00       	call   f0103944 <cprintf>
f01007ad:	83 c4 0c             	add    $0xc,%esp
f01007b0:	68 24 69 10 f0       	push   $0xf0106924
f01007b5:	68 8c 68 10 f0       	push   $0xf010688c
f01007ba:	68 83 68 10 f0       	push   $0xf0106883
f01007bf:	e8 80 31 00 00       	call   f0103944 <cprintf>
f01007c4:	83 c4 0c             	add    $0xc,%esp
f01007c7:	68 4c 69 10 f0       	push   $0xf010694c
f01007cc:	68 95 68 10 f0       	push   $0xf0106895
f01007d1:	68 83 68 10 f0       	push   $0xf0106883
f01007d6:	e8 69 31 00 00       	call   f0103944 <cprintf>
	return 0;
}
f01007db:	b8 00 00 00 00       	mov    $0x0,%eax
f01007e0:	c9                   	leave  
f01007e1:	c3                   	ret    

f01007e2 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007e2:	55                   	push   %ebp
f01007e3:	89 e5                	mov    %esp,%ebp
f01007e5:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007e8:	68 9f 68 10 f0       	push   $0xf010689f
f01007ed:	e8 52 31 00 00       	call   f0103944 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007f2:	83 c4 08             	add    $0x8,%esp
f01007f5:	68 0c 00 10 00       	push   $0x10000c
f01007fa:	68 78 69 10 f0       	push   $0xf0106978
f01007ff:	e8 40 31 00 00       	call   f0103944 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100804:	83 c4 0c             	add    $0xc,%esp
f0100807:	68 0c 00 10 00       	push   $0x10000c
f010080c:	68 0c 00 10 f0       	push   $0xf010000c
f0100811:	68 a0 69 10 f0       	push   $0xf01069a0
f0100816:	e8 29 31 00 00       	call   f0103944 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010081b:	83 c4 0c             	add    $0xc,%esp
f010081e:	68 59 65 10 00       	push   $0x106559
f0100823:	68 59 65 10 f0       	push   $0xf0106559
f0100828:	68 c4 69 10 f0       	push   $0xf01069c4
f010082d:	e8 12 31 00 00       	call   f0103944 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100832:	83 c4 0c             	add    $0xc,%esp
f0100835:	68 00 40 23 00       	push   $0x234000
f010083a:	68 00 40 23 f0       	push   $0xf0234000
f010083f:	68 e8 69 10 f0       	push   $0xf01069e8
f0100844:	e8 fb 30 00 00       	call   f0103944 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100849:	83 c4 0c             	add    $0xc,%esp
f010084c:	68 08 60 27 00       	push   $0x276008
f0100851:	68 08 60 27 f0       	push   $0xf0276008
f0100856:	68 0c 6a 10 f0       	push   $0xf0106a0c
f010085b:	e8 e4 30 00 00       	call   f0103944 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100860:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100863:	b8 07 64 27 f0       	mov    $0xf0276407,%eax
f0100868:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f010086d:	c1 f8 0a             	sar    $0xa,%eax
f0100870:	50                   	push   %eax
f0100871:	68 30 6a 10 f0       	push   $0xf0106a30
f0100876:	e8 c9 30 00 00       	call   f0103944 <cprintf>
	return 0;
}
f010087b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100880:	c9                   	leave  
f0100881:	c3                   	ret    

f0100882 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100882:	55                   	push   %ebp
f0100883:	89 e5                	mov    %esp,%ebp
f0100885:	56                   	push   %esi
f0100886:	53                   	push   %ebx
f0100887:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f010088a:	89 eb                	mov    %ebp,%ebx
	}*/
	uint32_t *ebp;
	struct Eipdebuginfo info;
	int result;
	ebp = (uint32_t*)read_ebp();
	cprintf("Stack backtrace:\r\n");
f010088c:	68 b8 68 10 f0       	push   $0xf01068b8
f0100891:	e8 ae 30 00 00       	call   f0103944 <cprintf>

	while(ebp){
f0100896:	83 c4 10             	add    $0x10,%esp
	cprintf("    ebp %08x eip %08x args %08x %08x %08x %08x %08x\r\n",ebp,ebp[1],ebp[2],ebp[3],ebp[4],ebp[5],ebp[6]);//ebp[i] what meaning?
	memset(&info,0,sizeof(struct Eipdebuginfo));
f0100899:	8d 75 e0             	lea    -0x20(%ebp),%esi
	while(ebp){
f010089c:	eb 25                	jmp    f01008c3 <mon_backtrace+0x41>
	result = debuginfo_eip(ebp[1],&info);
	if(result){
	   cprintf("failed\r\n",ebp[1]);
	}else{
	cprintf("\t%s:%d: %.*s+%u\r\n",info.eip_file,info.eip_line,info.eip_fn_namelen,info.eip_fn_name,ebp[1]-info.eip_fn_addr);
f010089e:	83 ec 08             	sub    $0x8,%esp
f01008a1:	8b 43 04             	mov    0x4(%ebx),%eax
f01008a4:	2b 45 f0             	sub    -0x10(%ebp),%eax
f01008a7:	50                   	push   %eax
f01008a8:	ff 75 e8             	pushl  -0x18(%ebp)
f01008ab:	ff 75 ec             	pushl  -0x14(%ebp)
f01008ae:	ff 75 e4             	pushl  -0x1c(%ebp)
f01008b1:	ff 75 e0             	pushl  -0x20(%ebp)
f01008b4:	68 d4 68 10 f0       	push   $0xf01068d4
f01008b9:	e8 86 30 00 00       	call   f0103944 <cprintf>
f01008be:	83 c4 20             	add    $0x20,%esp
	}
	ebp = (uint32_t*)*ebp;
f01008c1:	8b 1b                	mov    (%ebx),%ebx
	while(ebp){
f01008c3:	85 db                	test   %ebx,%ebx
f01008c5:	74 52                	je     f0100919 <mon_backtrace+0x97>
	cprintf("    ebp %08x eip %08x args %08x %08x %08x %08x %08x\r\n",ebp,ebp[1],ebp[2],ebp[3],ebp[4],ebp[5],ebp[6]);//ebp[i] what meaning?
f01008c7:	ff 73 18             	pushl  0x18(%ebx)
f01008ca:	ff 73 14             	pushl  0x14(%ebx)
f01008cd:	ff 73 10             	pushl  0x10(%ebx)
f01008d0:	ff 73 0c             	pushl  0xc(%ebx)
f01008d3:	ff 73 08             	pushl  0x8(%ebx)
f01008d6:	ff 73 04             	pushl  0x4(%ebx)
f01008d9:	53                   	push   %ebx
f01008da:	68 5c 6a 10 f0       	push   $0xf0106a5c
f01008df:	e8 60 30 00 00       	call   f0103944 <cprintf>
	memset(&info,0,sizeof(struct Eipdebuginfo));
f01008e4:	83 c4 1c             	add    $0x1c,%esp
f01008e7:	6a 18                	push   $0x18
f01008e9:	6a 00                	push   $0x0
f01008eb:	56                   	push   %esi
f01008ec:	e8 16 50 00 00       	call   f0105907 <memset>
	result = debuginfo_eip(ebp[1],&info);
f01008f1:	83 c4 08             	add    $0x8,%esp
f01008f4:	56                   	push   %esi
f01008f5:	ff 73 04             	pushl  0x4(%ebx)
f01008f8:	e8 bd 44 00 00       	call   f0104dba <debuginfo_eip>
	if(result){
f01008fd:	83 c4 10             	add    $0x10,%esp
f0100900:	85 c0                	test   %eax,%eax
f0100902:	74 9a                	je     f010089e <mon_backtrace+0x1c>
	   cprintf("failed\r\n",ebp[1]);
f0100904:	83 ec 08             	sub    $0x8,%esp
f0100907:	ff 73 04             	pushl  0x4(%ebx)
f010090a:	68 cb 68 10 f0       	push   $0xf01068cb
f010090f:	e8 30 30 00 00       	call   f0103944 <cprintf>
f0100914:	83 c4 10             	add    $0x10,%esp
f0100917:	eb a8                	jmp    f01008c1 <mon_backtrace+0x3f>
	}
	return 0;
}
f0100919:	b8 00 00 00 00       	mov    $0x0,%eax
f010091e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100921:	5b                   	pop    %ebx
f0100922:	5e                   	pop    %esi
f0100923:	5d                   	pop    %ebp
f0100924:	c3                   	ret    

f0100925 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100925:	55                   	push   %ebp
f0100926:	89 e5                	mov    %esp,%ebp
f0100928:	57                   	push   %edi
f0100929:	56                   	push   %esi
f010092a:	53                   	push   %ebx
f010092b:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010092e:	68 94 6a 10 f0       	push   $0xf0106a94
f0100933:	e8 0c 30 00 00       	call   f0103944 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100938:	c7 04 24 b8 6a 10 f0 	movl   $0xf0106ab8,(%esp)
f010093f:	e8 00 30 00 00       	call   f0103944 <cprintf>

	if (tf != NULL)
f0100944:	83 c4 10             	add    $0x10,%esp
f0100947:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f010094b:	74 57                	je     f01009a4 <monitor+0x7f>
		print_trapframe(tf);
f010094d:	83 ec 0c             	sub    $0xc,%esp
f0100950:	ff 75 08             	pushl  0x8(%ebp)
f0100953:	e8 9c 35 00 00       	call   f0103ef4 <print_trapframe>
f0100958:	83 c4 10             	add    $0x10,%esp
f010095b:	eb 47                	jmp    f01009a4 <monitor+0x7f>
		while (*buf && strchr(WHITESPACE, *buf))
f010095d:	83 ec 08             	sub    $0x8,%esp
f0100960:	0f be c0             	movsbl %al,%eax
f0100963:	50                   	push   %eax
f0100964:	68 ea 68 10 f0       	push   $0xf01068ea
f0100969:	e8 5c 4f 00 00       	call   f01058ca <strchr>
f010096e:	83 c4 10             	add    $0x10,%esp
f0100971:	85 c0                	test   %eax,%eax
f0100973:	74 0a                	je     f010097f <monitor+0x5a>
			*buf++ = 0;
f0100975:	c6 03 00             	movb   $0x0,(%ebx)
f0100978:	89 f7                	mov    %esi,%edi
f010097a:	8d 5b 01             	lea    0x1(%ebx),%ebx
f010097d:	eb 6b                	jmp    f01009ea <monitor+0xc5>
		if (*buf == 0)
f010097f:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100982:	74 73                	je     f01009f7 <monitor+0xd2>
		if (argc == MAXARGS-1) {
f0100984:	83 fe 0f             	cmp    $0xf,%esi
f0100987:	74 09                	je     f0100992 <monitor+0x6d>
		argv[argc++] = buf;
f0100989:	8d 7e 01             	lea    0x1(%esi),%edi
f010098c:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100990:	eb 39                	jmp    f01009cb <monitor+0xa6>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100992:	83 ec 08             	sub    $0x8,%esp
f0100995:	6a 10                	push   $0x10
f0100997:	68 ef 68 10 f0       	push   $0xf01068ef
f010099c:	e8 a3 2f 00 00       	call   f0103944 <cprintf>
f01009a1:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f01009a4:	83 ec 0c             	sub    $0xc,%esp
f01009a7:	68 e6 68 10 f0       	push   $0xf01068e6
f01009ac:	e8 fc 4c 00 00       	call   f01056ad <readline>
f01009b1:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01009b3:	83 c4 10             	add    $0x10,%esp
f01009b6:	85 c0                	test   %eax,%eax
f01009b8:	74 ea                	je     f01009a4 <monitor+0x7f>
	argv[argc] = 0;
f01009ba:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f01009c1:	be 00 00 00 00       	mov    $0x0,%esi
f01009c6:	eb 24                	jmp    f01009ec <monitor+0xc7>
			buf++;
f01009c8:	83 c3 01             	add    $0x1,%ebx
		while (*buf && !strchr(WHITESPACE, *buf))
f01009cb:	0f b6 03             	movzbl (%ebx),%eax
f01009ce:	84 c0                	test   %al,%al
f01009d0:	74 18                	je     f01009ea <monitor+0xc5>
f01009d2:	83 ec 08             	sub    $0x8,%esp
f01009d5:	0f be c0             	movsbl %al,%eax
f01009d8:	50                   	push   %eax
f01009d9:	68 ea 68 10 f0       	push   $0xf01068ea
f01009de:	e8 e7 4e 00 00       	call   f01058ca <strchr>
f01009e3:	83 c4 10             	add    $0x10,%esp
f01009e6:	85 c0                	test   %eax,%eax
f01009e8:	74 de                	je     f01009c8 <monitor+0xa3>
			*buf++ = 0;
f01009ea:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f01009ec:	0f b6 03             	movzbl (%ebx),%eax
f01009ef:	84 c0                	test   %al,%al
f01009f1:	0f 85 66 ff ff ff    	jne    f010095d <monitor+0x38>
	argv[argc] = 0;
f01009f7:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01009fe:	00 
	if (argc == 0)
f01009ff:	85 f6                	test   %esi,%esi
f0100a01:	74 a1                	je     f01009a4 <monitor+0x7f>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a03:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a08:	83 ec 08             	sub    $0x8,%esp
f0100a0b:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a0e:	ff 34 85 e0 6a 10 f0 	pushl  -0xfef9520(,%eax,4)
f0100a15:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a18:	e8 4f 4e 00 00       	call   f010586c <strcmp>
f0100a1d:	83 c4 10             	add    $0x10,%esp
f0100a20:	85 c0                	test   %eax,%eax
f0100a22:	74 20                	je     f0100a44 <monitor+0x11f>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a24:	83 c3 01             	add    $0x1,%ebx
f0100a27:	83 fb 03             	cmp    $0x3,%ebx
f0100a2a:	75 dc                	jne    f0100a08 <monitor+0xe3>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a2c:	83 ec 08             	sub    $0x8,%esp
f0100a2f:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a32:	68 0c 69 10 f0       	push   $0xf010690c
f0100a37:	e8 08 2f 00 00       	call   f0103944 <cprintf>
f0100a3c:	83 c4 10             	add    $0x10,%esp
f0100a3f:	e9 60 ff ff ff       	jmp    f01009a4 <monitor+0x7f>
			return commands[i].func(argc, argv, tf);
f0100a44:	83 ec 04             	sub    $0x4,%esp
f0100a47:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a4a:	ff 75 08             	pushl  0x8(%ebp)
f0100a4d:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a50:	52                   	push   %edx
f0100a51:	56                   	push   %esi
f0100a52:	ff 14 85 e8 6a 10 f0 	call   *-0xfef9518(,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100a59:	83 c4 10             	add    $0x10,%esp
f0100a5c:	85 c0                	test   %eax,%eax
f0100a5e:	0f 89 40 ff ff ff    	jns    f01009a4 <monitor+0x7f>
				break;
	}
}
f0100a64:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a67:	5b                   	pop    %ebx
f0100a68:	5e                   	pop    %esi
f0100a69:	5f                   	pop    %edi
f0100a6a:	5d                   	pop    %ebp
f0100a6b:	c3                   	ret    

f0100a6c <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100a6c:	55                   	push   %ebp
f0100a6d:	89 e5                	mov    %esp,%ebp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100a6f:	83 3d 38 42 23 f0 00 	cmpl   $0x0,0xf0234238
f0100a76:	74 1d                	je     f0100a95 <boot_alloc+0x29>
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
        result = nextfree;
f0100a78:	8b 0d 38 42 23 f0    	mov    0xf0234238,%ecx
	nextfree = ROUNDUP(nextfree+n,PGSIZE);
f0100a7e:	8d 94 01 ff 0f 00 00 	lea    0xfff(%ecx,%eax,1),%edx
f0100a85:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100a8b:	89 15 38 42 23 f0    	mov    %edx,0xf0234238
	return result;
}
f0100a91:	89 c8                	mov    %ecx,%eax
f0100a93:	5d                   	pop    %ebp
f0100a94:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100a95:	ba 07 70 27 f0       	mov    $0xf0277007,%edx
f0100a9a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100aa0:	89 15 38 42 23 f0    	mov    %edx,0xf0234238
f0100aa6:	eb d0                	jmp    f0100a78 <boot_alloc+0xc>

f0100aa8 <nvram_read>:
{
f0100aa8:	55                   	push   %ebp
f0100aa9:	89 e5                	mov    %esp,%ebp
f0100aab:	56                   	push   %esi
f0100aac:	53                   	push   %ebx
f0100aad:	89 c6                	mov    %eax,%esi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100aaf:	83 ec 0c             	sub    $0xc,%esp
f0100ab2:	50                   	push   %eax
f0100ab3:	e8 03 2d 00 00       	call   f01037bb <mc146818_read>
f0100ab8:	89 c3                	mov    %eax,%ebx
f0100aba:	83 c6 01             	add    $0x1,%esi
f0100abd:	89 34 24             	mov    %esi,(%esp)
f0100ac0:	e8 f6 2c 00 00       	call   f01037bb <mc146818_read>
f0100ac5:	c1 e0 08             	shl    $0x8,%eax
f0100ac8:	09 d8                	or     %ebx,%eax
}
f0100aca:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100acd:	5b                   	pop    %ebx
f0100ace:	5e                   	pop    %esi
f0100acf:	5d                   	pop    %ebp
f0100ad0:	c3                   	ret    

f0100ad1 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100ad1:	89 d1                	mov    %edx,%ecx
f0100ad3:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100ad6:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100ad9:	a8 01                	test   $0x1,%al
f0100adb:	74 52                	je     f0100b2f <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100add:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0100ae2:	89 c1                	mov    %eax,%ecx
f0100ae4:	c1 e9 0c             	shr    $0xc,%ecx
f0100ae7:	3b 0d 88 4e 23 f0    	cmp    0xf0234e88,%ecx
f0100aed:	73 25                	jae    f0100b14 <check_va2pa+0x43>
	if (!(p[PTX(va)] & PTE_P))
f0100aef:	c1 ea 0c             	shr    $0xc,%edx
f0100af2:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100af8:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100aff:	89 c2                	mov    %eax,%edx
f0100b01:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b04:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b09:	85 d2                	test   %edx,%edx
f0100b0b:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b10:	0f 44 c2             	cmove  %edx,%eax
f0100b13:	c3                   	ret    
{
f0100b14:	55                   	push   %ebp
f0100b15:	89 e5                	mov    %esp,%ebp
f0100b17:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b1a:	50                   	push   %eax
f0100b1b:	68 84 65 10 f0       	push   $0xf0106584
f0100b20:	68 84 03 00 00       	push   $0x384
f0100b25:	68 49 74 10 f0       	push   $0xf0107449
f0100b2a:	e8 11 f5 ff ff       	call   f0100040 <_panic>
		return ~0;
f0100b2f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100b34:	c3                   	ret    

f0100b35 <check_page_free_list>:
{
f0100b35:	55                   	push   %ebp
f0100b36:	89 e5                	mov    %esp,%ebp
f0100b38:	57                   	push   %edi
f0100b39:	56                   	push   %esi
f0100b3a:	53                   	push   %ebx
f0100b3b:	83 ec 2c             	sub    $0x2c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b3e:	84 c0                	test   %al,%al
f0100b40:	0f 85 86 02 00 00    	jne    f0100dcc <check_page_free_list+0x297>
	if (!page_free_list)
f0100b46:	83 3d 40 42 23 f0 00 	cmpl   $0x0,0xf0234240
f0100b4d:	74 0a                	je     f0100b59 <check_page_free_list+0x24>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b4f:	be 00 04 00 00       	mov    $0x400,%esi
f0100b54:	e9 ce 02 00 00       	jmp    f0100e27 <check_page_free_list+0x2f2>
		panic("'page_free_list' is a null pointer!");
f0100b59:	83 ec 04             	sub    $0x4,%esp
f0100b5c:	68 04 6b 10 f0       	push   $0xf0106b04
f0100b61:	68 b7 02 00 00       	push   $0x2b7
f0100b66:	68 49 74 10 f0       	push   $0xf0107449
f0100b6b:	e8 d0 f4 ff ff       	call   f0100040 <_panic>
f0100b70:	50                   	push   %eax
f0100b71:	68 84 65 10 f0       	push   $0xf0106584
f0100b76:	6a 58                	push   $0x58
f0100b78:	68 55 74 10 f0       	push   $0xf0107455
f0100b7d:	e8 be f4 ff ff       	call   f0100040 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100b82:	8b 1b                	mov    (%ebx),%ebx
f0100b84:	85 db                	test   %ebx,%ebx
f0100b86:	74 41                	je     f0100bc9 <check_page_free_list+0x94>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b88:	89 d8                	mov    %ebx,%eax
f0100b8a:	2b 05 90 4e 23 f0    	sub    0xf0234e90,%eax
f0100b90:	c1 f8 03             	sar    $0x3,%eax
f0100b93:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100b96:	89 c2                	mov    %eax,%edx
f0100b98:	c1 ea 16             	shr    $0x16,%edx
f0100b9b:	39 f2                	cmp    %esi,%edx
f0100b9d:	73 e3                	jae    f0100b82 <check_page_free_list+0x4d>
	if (PGNUM(pa) >= npages)
f0100b9f:	89 c2                	mov    %eax,%edx
f0100ba1:	c1 ea 0c             	shr    $0xc,%edx
f0100ba4:	3b 15 88 4e 23 f0    	cmp    0xf0234e88,%edx
f0100baa:	73 c4                	jae    f0100b70 <check_page_free_list+0x3b>
			memset(page2kva(pp), 0x97, 128);
f0100bac:	83 ec 04             	sub    $0x4,%esp
f0100baf:	68 80 00 00 00       	push   $0x80
f0100bb4:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100bb9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100bbe:	50                   	push   %eax
f0100bbf:	e8 43 4d 00 00       	call   f0105907 <memset>
f0100bc4:	83 c4 10             	add    $0x10,%esp
f0100bc7:	eb b9                	jmp    f0100b82 <check_page_free_list+0x4d>
	first_free_page = (char *) boot_alloc(0);
f0100bc9:	b8 00 00 00 00       	mov    $0x0,%eax
f0100bce:	e8 99 fe ff ff       	call   f0100a6c <boot_alloc>
f0100bd3:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100bd6:	8b 15 40 42 23 f0    	mov    0xf0234240,%edx
		assert(pp >= pages);
f0100bdc:	8b 0d 90 4e 23 f0    	mov    0xf0234e90,%ecx
		assert(pp < pages + npages);
f0100be2:	a1 88 4e 23 f0       	mov    0xf0234e88,%eax
f0100be7:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100bea:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100bed:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100bf0:	89 4d d0             	mov    %ecx,-0x30(%ebp)
	int nfree_basemem = 0, nfree_extmem = 0;
f0100bf3:	be 00 00 00 00       	mov    $0x0,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100bf8:	e9 04 01 00 00       	jmp    f0100d01 <check_page_free_list+0x1cc>
		assert(pp >= pages);
f0100bfd:	68 63 74 10 f0       	push   $0xf0107463
f0100c02:	68 6f 74 10 f0       	push   $0xf010746f
f0100c07:	68 d1 02 00 00       	push   $0x2d1
f0100c0c:	68 49 74 10 f0       	push   $0xf0107449
f0100c11:	e8 2a f4 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100c16:	68 84 74 10 f0       	push   $0xf0107484
f0100c1b:	68 6f 74 10 f0       	push   $0xf010746f
f0100c20:	68 d2 02 00 00       	push   $0x2d2
f0100c25:	68 49 74 10 f0       	push   $0xf0107449
f0100c2a:	e8 11 f4 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c2f:	68 28 6b 10 f0       	push   $0xf0106b28
f0100c34:	68 6f 74 10 f0       	push   $0xf010746f
f0100c39:	68 d3 02 00 00       	push   $0x2d3
f0100c3e:	68 49 74 10 f0       	push   $0xf0107449
f0100c43:	e8 f8 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != 0);
f0100c48:	68 98 74 10 f0       	push   $0xf0107498
f0100c4d:	68 6f 74 10 f0       	push   $0xf010746f
f0100c52:	68 d6 02 00 00       	push   $0x2d6
f0100c57:	68 49 74 10 f0       	push   $0xf0107449
f0100c5c:	e8 df f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100c61:	68 a9 74 10 f0       	push   $0xf01074a9
f0100c66:	68 6f 74 10 f0       	push   $0xf010746f
f0100c6b:	68 d7 02 00 00       	push   $0x2d7
f0100c70:	68 49 74 10 f0       	push   $0xf0107449
f0100c75:	e8 c6 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100c7a:	68 5c 6b 10 f0       	push   $0xf0106b5c
f0100c7f:	68 6f 74 10 f0       	push   $0xf010746f
f0100c84:	68 d8 02 00 00       	push   $0x2d8
f0100c89:	68 49 74 10 f0       	push   $0xf0107449
f0100c8e:	e8 ad f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100c93:	68 c2 74 10 f0       	push   $0xf01074c2
f0100c98:	68 6f 74 10 f0       	push   $0xf010746f
f0100c9d:	68 d9 02 00 00       	push   $0x2d9
f0100ca2:	68 49 74 10 f0       	push   $0xf0107449
f0100ca7:	e8 94 f3 ff ff       	call   f0100040 <_panic>
	if (PGNUM(pa) >= npages)
f0100cac:	89 c7                	mov    %eax,%edi
f0100cae:	c1 ef 0c             	shr    $0xc,%edi
f0100cb1:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0100cb4:	76 1b                	jbe    f0100cd1 <check_page_free_list+0x19c>
	return (void *)(pa + KERNBASE);
f0100cb6:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100cbc:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f0100cbf:	77 22                	ja     f0100ce3 <check_page_free_list+0x1ae>
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100cc1:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100cc6:	0f 84 98 00 00 00    	je     f0100d64 <check_page_free_list+0x22f>
			++nfree_extmem;
f0100ccc:	83 c3 01             	add    $0x1,%ebx
f0100ccf:	eb 2e                	jmp    f0100cff <check_page_free_list+0x1ca>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100cd1:	50                   	push   %eax
f0100cd2:	68 84 65 10 f0       	push   $0xf0106584
f0100cd7:	6a 58                	push   $0x58
f0100cd9:	68 55 74 10 f0       	push   $0xf0107455
f0100cde:	e8 5d f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100ce3:	68 80 6b 10 f0       	push   $0xf0106b80
f0100ce8:	68 6f 74 10 f0       	push   $0xf010746f
f0100ced:	68 da 02 00 00       	push   $0x2da
f0100cf2:	68 49 74 10 f0       	push   $0xf0107449
f0100cf7:	e8 44 f3 ff ff       	call   f0100040 <_panic>
			++nfree_basemem;
f0100cfc:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100cff:	8b 12                	mov    (%edx),%edx
f0100d01:	85 d2                	test   %edx,%edx
f0100d03:	74 78                	je     f0100d7d <check_page_free_list+0x248>
		assert(pp >= pages);
f0100d05:	39 d1                	cmp    %edx,%ecx
f0100d07:	0f 87 f0 fe ff ff    	ja     f0100bfd <check_page_free_list+0xc8>
		assert(pp < pages + npages);
f0100d0d:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0100d10:	0f 86 00 ff ff ff    	jbe    f0100c16 <check_page_free_list+0xe1>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d16:	89 d0                	mov    %edx,%eax
f0100d18:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100d1b:	a8 07                	test   $0x7,%al
f0100d1d:	0f 85 0c ff ff ff    	jne    f0100c2f <check_page_free_list+0xfa>
	return (pp - pages) << PGSHIFT;
f0100d23:	c1 f8 03             	sar    $0x3,%eax
f0100d26:	c1 e0 0c             	shl    $0xc,%eax
		assert(page2pa(pp) != 0);
f0100d29:	85 c0                	test   %eax,%eax
f0100d2b:	0f 84 17 ff ff ff    	je     f0100c48 <check_page_free_list+0x113>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d31:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d36:	0f 84 25 ff ff ff    	je     f0100c61 <check_page_free_list+0x12c>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d3c:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d41:	0f 84 33 ff ff ff    	je     f0100c7a <check_page_free_list+0x145>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d47:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d4c:	0f 84 41 ff ff ff    	je     f0100c93 <check_page_free_list+0x15e>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d52:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100d57:	0f 87 4f ff ff ff    	ja     f0100cac <check_page_free_list+0x177>
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100d5d:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100d62:	75 98                	jne    f0100cfc <check_page_free_list+0x1c7>
f0100d64:	68 dc 74 10 f0       	push   $0xf01074dc
f0100d69:	68 6f 74 10 f0       	push   $0xf010746f
f0100d6e:	68 dc 02 00 00       	push   $0x2dc
f0100d73:	68 49 74 10 f0       	push   $0xf0107449
f0100d78:	e8 c3 f2 ff ff       	call   f0100040 <_panic>
	assert(nfree_basemem > 0);
f0100d7d:	85 f6                	test   %esi,%esi
f0100d7f:	7e 19                	jle    f0100d9a <check_page_free_list+0x265>
	assert(nfree_extmem > 0);
f0100d81:	85 db                	test   %ebx,%ebx
f0100d83:	7e 2e                	jle    f0100db3 <check_page_free_list+0x27e>
	cprintf("check_page_free_list() succeeded!\n");
f0100d85:	83 ec 0c             	sub    $0xc,%esp
f0100d88:	68 c8 6b 10 f0       	push   $0xf0106bc8
f0100d8d:	e8 b2 2b 00 00       	call   f0103944 <cprintf>
}
f0100d92:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d95:	5b                   	pop    %ebx
f0100d96:	5e                   	pop    %esi
f0100d97:	5f                   	pop    %edi
f0100d98:	5d                   	pop    %ebp
f0100d99:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100d9a:	68 f9 74 10 f0       	push   $0xf01074f9
f0100d9f:	68 6f 74 10 f0       	push   $0xf010746f
f0100da4:	68 e4 02 00 00       	push   $0x2e4
f0100da9:	68 49 74 10 f0       	push   $0xf0107449
f0100dae:	e8 8d f2 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100db3:	68 0b 75 10 f0       	push   $0xf010750b
f0100db8:	68 6f 74 10 f0       	push   $0xf010746f
f0100dbd:	68 e5 02 00 00       	push   $0x2e5
f0100dc2:	68 49 74 10 f0       	push   $0xf0107449
f0100dc7:	e8 74 f2 ff ff       	call   f0100040 <_panic>
	if (!page_free_list)
f0100dcc:	a1 40 42 23 f0       	mov    0xf0234240,%eax
f0100dd1:	85 c0                	test   %eax,%eax
f0100dd3:	0f 84 80 fd ff ff    	je     f0100b59 <check_page_free_list+0x24>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100dd9:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100ddc:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100ddf:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100de2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100de5:	89 c2                	mov    %eax,%edx
f0100de7:	2b 15 90 4e 23 f0    	sub    0xf0234e90,%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100ded:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100df3:	0f 95 c2             	setne  %dl
f0100df6:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100df9:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100dfd:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100dff:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e03:	8b 00                	mov    (%eax),%eax
f0100e05:	85 c0                	test   %eax,%eax
f0100e07:	75 dc                	jne    f0100de5 <check_page_free_list+0x2b0>
		*tp[1] = 0;
f0100e09:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100e0c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100e12:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100e15:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e18:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100e1a:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100e1d:	a3 40 42 23 f0       	mov    %eax,0xf0234240
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100e22:	be 01 00 00 00       	mov    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100e27:	8b 1d 40 42 23 f0    	mov    0xf0234240,%ebx
f0100e2d:	e9 52 fd ff ff       	jmp    f0100b84 <check_page_free_list+0x4f>

f0100e32 <page_init>:
{
f0100e32:	55                   	push   %ebp
f0100e33:	89 e5                	mov    %esp,%ebp
f0100e35:	57                   	push   %edi
f0100e36:	56                   	push   %esi
f0100e37:	53                   	push   %ebx
f0100e38:	83 ec 0c             	sub    $0xc,%esp
        page_free_list = NULL;
f0100e3b:	c7 05 40 42 23 f0 00 	movl   $0x0,0xf0234240
f0100e42:	00 00 00 
	size_t first_free_extend_addr = PADDR (boot_alloc(0));
f0100e45:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e4a:	e8 1d fc ff ff       	call   f0100a6c <boot_alloc>
	if ((uint32_t)kva < KERNBASE)
f0100e4f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100e54:	76 1b                	jbe    f0100e71 <page_init+0x3f>
	return (physaddr_t)kva - KERNBASE;
f0100e56:	05 00 00 00 10       	add    $0x10000000,%eax
	for (i = 0; i < npages; i++) {
f0100e5b:	be 00 00 00 00       	mov    $0x0,%esi
f0100e60:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100e65:	ba 00 00 00 00       	mov    $0x0,%edx
		 page_free_list = &pages[i];
f0100e6a:	bf 01 00 00 00       	mov    $0x1,%edi
	for (i = 0; i < npages; i++) {
f0100e6f:	eb 52                	jmp    f0100ec3 <page_init+0x91>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100e71:	50                   	push   %eax
f0100e72:	68 a8 65 10 f0       	push   $0xf01065a8
f0100e77:	68 40 01 00 00       	push   $0x140
f0100e7c:	68 49 74 10 f0       	push   $0xf0107449
f0100e81:	e8 ba f1 ff ff       	call   f0100040 <_panic>
f0100e86:	89 d1                	mov    %edx,%ecx
f0100e88:	c1 e1 0c             	shl    $0xc,%ecx
		}else if(i*PGSIZE>=IOPHYSMEM && i*PGSIZE<=first_free_extend_addr){
f0100e8b:	39 c8                	cmp    %ecx,%eax
f0100e8d:	72 08                	jb     f0100e97 <page_init+0x65>
f0100e8f:	81 f9 ff ff 09 00    	cmp    $0x9ffff,%ecx
f0100e95:	77 46                	ja     f0100edd <page_init+0xab>
		}else if(i*PGSIZE==MPENTRY_PADDR){
f0100e97:	81 f9 00 70 00 00    	cmp    $0x7000,%ecx
f0100e9d:	74 4d                	je     f0100eec <page_init+0xba>
f0100e9f:	8d 0c d5 00 00 00 00 	lea    0x0(,%edx,8),%ecx
                 pages[i].pp_ref = 0;
f0100ea6:	89 ce                	mov    %ecx,%esi
f0100ea8:	03 35 90 4e 23 f0    	add    0xf0234e90,%esi
f0100eae:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
		 pages[i].pp_link = page_free_list;
f0100eb4:	89 1e                	mov    %ebx,(%esi)
		 page_free_list = &pages[i];
f0100eb6:	89 cb                	mov    %ecx,%ebx
f0100eb8:	03 1d 90 4e 23 f0    	add    0xf0234e90,%ebx
f0100ebe:	89 fe                	mov    %edi,%esi
	for (i = 0; i < npages; i++) {
f0100ec0:	83 c2 01             	add    $0x1,%edx
f0100ec3:	39 15 88 4e 23 f0    	cmp    %edx,0xf0234e88
f0100ec9:	76 30                	jbe    f0100efb <page_init+0xc9>
		if(i==0){
f0100ecb:	85 d2                	test   %edx,%edx
f0100ecd:	75 b7                	jne    f0100e86 <page_init+0x54>
		  pages[i].pp_ref = 1;
f0100ecf:	8b 0d 90 4e 23 f0    	mov    0xf0234e90,%ecx
f0100ed5:	66 c7 41 04 01 00    	movw   $0x1,0x4(%ecx)
f0100edb:	eb e3                	jmp    f0100ec0 <page_init+0x8e>
		        pages[i].pp_ref = 1;
f0100edd:	8b 0d 90 4e 23 f0    	mov    0xf0234e90,%ecx
f0100ee3:	66 c7 44 d1 04 01 00 	movw   $0x1,0x4(%ecx,%edx,8)
f0100eea:	eb d4                	jmp    f0100ec0 <page_init+0x8e>
		        pages[i].pp_ref = 1;
f0100eec:	8b 0d 90 4e 23 f0    	mov    0xf0234e90,%ecx
f0100ef2:	66 c7 44 d1 04 01 00 	movw   $0x1,0x4(%ecx,%edx,8)
f0100ef9:	eb c5                	jmp    f0100ec0 <page_init+0x8e>
f0100efb:	89 f0                	mov    %esi,%eax
f0100efd:	84 c0                	test   %al,%al
f0100eff:	75 08                	jne    f0100f09 <page_init+0xd7>
}
f0100f01:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f04:	5b                   	pop    %ebx
f0100f05:	5e                   	pop    %esi
f0100f06:	5f                   	pop    %edi
f0100f07:	5d                   	pop    %ebp
f0100f08:	c3                   	ret    
f0100f09:	89 1d 40 42 23 f0    	mov    %ebx,0xf0234240
f0100f0f:	eb f0                	jmp    f0100f01 <page_init+0xcf>

f0100f11 <page_alloc>:
{
f0100f11:	55                   	push   %ebp
f0100f12:	89 e5                	mov    %esp,%ebp
f0100f14:	53                   	push   %ebx
f0100f15:	83 ec 04             	sub    $0x4,%esp
	if(page_free_list ==NULL)
f0100f18:	8b 1d 40 42 23 f0    	mov    0xf0234240,%ebx
f0100f1e:	85 db                	test   %ebx,%ebx
f0100f20:	74 13                	je     f0100f35 <page_alloc+0x24>
	page_free_list = alloc_space->pp_link;
f0100f22:	8b 03                	mov    (%ebx),%eax
f0100f24:	a3 40 42 23 f0       	mov    %eax,0xf0234240
	alloc_space->pp_link = NULL;
f0100f29:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if(alloc_flags && ALLOC_ZERO){
f0100f2f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100f33:	75 07                	jne    f0100f3c <page_alloc+0x2b>
}
f0100f35:	89 d8                	mov    %ebx,%eax
f0100f37:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f3a:	c9                   	leave  
f0100f3b:	c3                   	ret    
	return (pp - pages) << PGSHIFT;
f0100f3c:	89 d8                	mov    %ebx,%eax
f0100f3e:	2b 05 90 4e 23 f0    	sub    0xf0234e90,%eax
f0100f44:	c1 f8 03             	sar    $0x3,%eax
f0100f47:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0100f4a:	89 c2                	mov    %eax,%edx
f0100f4c:	c1 ea 0c             	shr    $0xc,%edx
f0100f4f:	3b 15 88 4e 23 f0    	cmp    0xf0234e88,%edx
f0100f55:	73 1a                	jae    f0100f71 <page_alloc+0x60>
	   memset(page2kva(alloc_space),0,PGSIZE);
f0100f57:	83 ec 04             	sub    $0x4,%esp
f0100f5a:	68 00 10 00 00       	push   $0x1000
f0100f5f:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0100f61:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100f66:	50                   	push   %eax
f0100f67:	e8 9b 49 00 00       	call   f0105907 <memset>
f0100f6c:	83 c4 10             	add    $0x10,%esp
f0100f6f:	eb c4                	jmp    f0100f35 <page_alloc+0x24>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f71:	50                   	push   %eax
f0100f72:	68 84 65 10 f0       	push   $0xf0106584
f0100f77:	6a 58                	push   $0x58
f0100f79:	68 55 74 10 f0       	push   $0xf0107455
f0100f7e:	e8 bd f0 ff ff       	call   f0100040 <_panic>

f0100f83 <page_free>:
{
f0100f83:	55                   	push   %ebp
f0100f84:	89 e5                	mov    %esp,%ebp
f0100f86:	83 ec 08             	sub    $0x8,%esp
f0100f89:	8b 45 08             	mov    0x8(%ebp),%eax
	if(pp->pp_ref==0 && pp->pp_link == NULL){
f0100f8c:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100f91:	75 14                	jne    f0100fa7 <page_free+0x24>
f0100f93:	83 38 00             	cmpl   $0x0,(%eax)
f0100f96:	75 0f                	jne    f0100fa7 <page_free+0x24>
	  pp->pp_link = page_free_list;
f0100f98:	8b 15 40 42 23 f0    	mov    0xf0234240,%edx
f0100f9e:	89 10                	mov    %edx,(%eax)
	  page_free_list = pp;
f0100fa0:	a3 40 42 23 f0       	mov    %eax,0xf0234240
}
f0100fa5:	c9                   	leave  
f0100fa6:	c3                   	ret    
	 panic("This page is being used!\n");
f0100fa7:	83 ec 04             	sub    $0x4,%esp
f0100faa:	68 1c 75 10 f0       	push   $0xf010751c
f0100faf:	68 80 01 00 00       	push   $0x180
f0100fb4:	68 49 74 10 f0       	push   $0xf0107449
f0100fb9:	e8 82 f0 ff ff       	call   f0100040 <_panic>

f0100fbe <page_decref>:
{
f0100fbe:	55                   	push   %ebp
f0100fbf:	89 e5                	mov    %esp,%ebp
f0100fc1:	83 ec 08             	sub    $0x8,%esp
f0100fc4:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100fc7:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100fcb:	83 e8 01             	sub    $0x1,%eax
f0100fce:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100fd2:	66 85 c0             	test   %ax,%ax
f0100fd5:	74 02                	je     f0100fd9 <page_decref+0x1b>
}
f0100fd7:	c9                   	leave  
f0100fd8:	c3                   	ret    
		page_free(pp);
f0100fd9:	83 ec 0c             	sub    $0xc,%esp
f0100fdc:	52                   	push   %edx
f0100fdd:	e8 a1 ff ff ff       	call   f0100f83 <page_free>
f0100fe2:	83 c4 10             	add    $0x10,%esp
}
f0100fe5:	eb f0                	jmp    f0100fd7 <page_decref+0x19>

f0100fe7 <pgdir_walk>:
{
f0100fe7:	55                   	push   %ebp
f0100fe8:	89 e5                	mov    %esp,%ebp
f0100fea:	57                   	push   %edi
f0100feb:	56                   	push   %esi
f0100fec:	53                   	push   %ebx
f0100fed:	83 ec 0c             	sub    $0xc,%esp
f0100ff0:	8b 45 0c             	mov    0xc(%ebp),%eax
        uint32_t ptx = PTX(va);              
f0100ff3:	89 c6                	mov    %eax,%esi
f0100ff5:	c1 ee 0c             	shr    $0xc,%esi
f0100ff8:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	 uint32_t pdx = PDX(va);               
f0100ffe:	c1 e8 16             	shr    $0x16,%eax
        pte_t *page_dir_entry = pgdir + pdx;  
f0101001:	8d 1c 85 00 00 00 00 	lea    0x0(,%eax,4),%ebx
f0101008:	03 5d 08             	add    0x8(%ebp),%ebx
        if(*page_dir_entry& PTE_P){
f010100b:	8b 03                	mov    (%ebx),%eax
f010100d:	a8 01                	test   $0x1,%al
f010100f:	74 38                	je     f0101049 <pgdir_walk+0x62>
          page_table_entry = KADDR(PTE_ADDR(*page_dir_entry));
f0101011:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101016:	89 c2                	mov    %eax,%edx
f0101018:	c1 ea 0c             	shr    $0xc,%edx
f010101b:	39 15 88 4e 23 f0    	cmp    %edx,0xf0234e88
f0101021:	76 11                	jbe    f0101034 <pgdir_walk+0x4d>
	return (void *)(pa + KERNBASE);
f0101023:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
        return &page_table_entry[ptx];
f0101029:	8d 04 b2             	lea    (%edx,%esi,4),%eax
}
f010102c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010102f:	5b                   	pop    %ebx
f0101030:	5e                   	pop    %esi
f0101031:	5f                   	pop    %edi
f0101032:	5d                   	pop    %ebp
f0101033:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101034:	50                   	push   %eax
f0101035:	68 84 65 10 f0       	push   $0xf0106584
f010103a:	68 b0 01 00 00       	push   $0x1b0
f010103f:	68 49 74 10 f0       	push   $0xf0107449
f0101044:	e8 f7 ef ff ff       	call   f0100040 <_panic>
         if(!create) return NULL;
f0101049:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010104d:	74 6f                	je     f01010be <pgdir_walk+0xd7>
         pp = page_alloc(1);
f010104f:	83 ec 0c             	sub    $0xc,%esp
f0101052:	6a 01                	push   $0x1
f0101054:	e8 b8 fe ff ff       	call   f0100f11 <page_alloc>
         if(!pp) return NULL;
f0101059:	83 c4 10             	add    $0x10,%esp
f010105c:	85 c0                	test   %eax,%eax
f010105e:	74 68                	je     f01010c8 <pgdir_walk+0xe1>
	return (pp - pages) << PGSHIFT;
f0101060:	89 c1                	mov    %eax,%ecx
f0101062:	2b 0d 90 4e 23 f0    	sub    0xf0234e90,%ecx
f0101068:	c1 f9 03             	sar    $0x3,%ecx
f010106b:	c1 e1 0c             	shl    $0xc,%ecx
	if (PGNUM(pa) >= npages)
f010106e:	89 ca                	mov    %ecx,%edx
f0101070:	c1 ea 0c             	shr    $0xc,%edx
f0101073:	3b 15 88 4e 23 f0    	cmp    0xf0234e88,%edx
f0101079:	73 1c                	jae    f0101097 <pgdir_walk+0xb0>
	return (void *)(pa + KERNBASE);
f010107b:	8d b9 00 00 00 f0    	lea    -0x10000000(%ecx),%edi
f0101081:	89 fa                	mov    %edi,%edx
         pp->pp_ref++;
f0101083:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	if ((uint32_t)kva < KERNBASE)
f0101088:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f010108e:	76 19                	jbe    f01010a9 <pgdir_walk+0xc2>
         *page_dir_entry = PADDR(page_table_entry)|PTE_P|PTE_W|PTE_U;
f0101090:	83 c9 07             	or     $0x7,%ecx
f0101093:	89 0b                	mov    %ecx,(%ebx)
f0101095:	eb 92                	jmp    f0101029 <pgdir_walk+0x42>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101097:	51                   	push   %ecx
f0101098:	68 84 65 10 f0       	push   $0xf0106584
f010109d:	6a 58                	push   $0x58
f010109f:	68 55 74 10 f0       	push   $0xf0107455
f01010a4:	e8 97 ef ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01010a9:	57                   	push   %edi
f01010aa:	68 a8 65 10 f0       	push   $0xf01065a8
f01010af:	68 b8 01 00 00       	push   $0x1b8
f01010b4:	68 49 74 10 f0       	push   $0xf0107449
f01010b9:	e8 82 ef ff ff       	call   f0100040 <_panic>
         if(!create) return NULL;
f01010be:	b8 00 00 00 00       	mov    $0x0,%eax
f01010c3:	e9 64 ff ff ff       	jmp    f010102c <pgdir_walk+0x45>
         if(!pp) return NULL;
f01010c8:	b8 00 00 00 00       	mov    $0x0,%eax
f01010cd:	e9 5a ff ff ff       	jmp    f010102c <pgdir_walk+0x45>

f01010d2 <boot_map_region>:
{
f01010d2:	55                   	push   %ebp
f01010d3:	89 e5                	mov    %esp,%ebp
f01010d5:	57                   	push   %edi
f01010d6:	56                   	push   %esi
f01010d7:	53                   	push   %ebx
f01010d8:	83 ec 1c             	sub    $0x1c,%esp
f01010db:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01010de:	8b 45 08             	mov    0x8(%ebp),%eax
	size_t numpage = size/PGSIZE;
f01010e1:	89 cb                	mov    %ecx,%ebx
f01010e3:	c1 eb 0c             	shr    $0xc,%ebx
	if(size % PGSIZE !=0) numpage++;
f01010e6:	81 e1 ff 0f 00 00    	and    $0xfff,%ecx
f01010ec:	83 f9 01             	cmp    $0x1,%ecx
f01010ef:	83 db ff             	sbb    $0xffffffff,%ebx
f01010f2:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	for(i=0;i<numpage;i++){
f01010f5:	89 c3                	mov    %eax,%ebx
f01010f7:	be 00 00 00 00       	mov    $0x0,%esi
	  pte_t *pte = pgdir_walk(pgdir,(void *)va,1);
f01010fc:	89 d7                	mov    %edx,%edi
f01010fe:	29 c7                	sub    %eax,%edi
	  *pte = pa|PTE_P|perm;
f0101100:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101103:	83 c8 01             	or     $0x1,%eax
f0101106:	89 45 dc             	mov    %eax,-0x24(%ebp)
	for(i=0;i<numpage;i++){
f0101109:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
f010110c:	74 41                	je     f010114f <boot_map_region+0x7d>
	  pte_t *pte = pgdir_walk(pgdir,(void *)va,1);
f010110e:	83 ec 04             	sub    $0x4,%esp
f0101111:	6a 01                	push   $0x1
f0101113:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f0101116:	50                   	push   %eax
f0101117:	ff 75 e0             	pushl  -0x20(%ebp)
f010111a:	e8 c8 fe ff ff       	call   f0100fe7 <pgdir_walk>
	  if(!pte) panic("boot_map_region:out ouf memory!\n");
f010111f:	83 c4 10             	add    $0x10,%esp
f0101122:	85 c0                	test   %eax,%eax
f0101124:	74 12                	je     f0101138 <boot_map_region+0x66>
	  *pte = pa|PTE_P|perm;
f0101126:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101129:	09 da                	or     %ebx,%edx
f010112b:	89 10                	mov    %edx,(%eax)
	  pa+=PGSIZE;
f010112d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for(i=0;i<numpage;i++){
f0101133:	83 c6 01             	add    $0x1,%esi
f0101136:	eb d1                	jmp    f0101109 <boot_map_region+0x37>
	  if(!pte) panic("boot_map_region:out ouf memory!\n");
f0101138:	83 ec 04             	sub    $0x4,%esp
f010113b:	68 ec 6b 10 f0       	push   $0xf0106bec
f0101140:	68 d2 01 00 00       	push   $0x1d2
f0101145:	68 49 74 10 f0       	push   $0xf0107449
f010114a:	e8 f1 ee ff ff       	call   f0100040 <_panic>
}
f010114f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101152:	5b                   	pop    %ebx
f0101153:	5e                   	pop    %esi
f0101154:	5f                   	pop    %edi
f0101155:	5d                   	pop    %ebp
f0101156:	c3                   	ret    

f0101157 <page_lookup>:
{
f0101157:	55                   	push   %ebp
f0101158:	89 e5                	mov    %esp,%ebp
f010115a:	53                   	push   %ebx
f010115b:	83 ec 08             	sub    $0x8,%esp
f010115e:	8b 5d 10             	mov    0x10(%ebp),%ebx
       	pte_t *pt = pgdir_walk(pgdir,va,0);
f0101161:	6a 00                	push   $0x0
f0101163:	ff 75 0c             	pushl  0xc(%ebp)
f0101166:	ff 75 08             	pushl  0x8(%ebp)
f0101169:	e8 79 fe ff ff       	call   f0100fe7 <pgdir_walk>
	if(!pt) return NULL;
f010116e:	83 c4 10             	add    $0x10,%esp
f0101171:	85 c0                	test   %eax,%eax
f0101173:	74 35                	je     f01011aa <page_lookup+0x53>
	if(pte_store)
f0101175:	85 db                	test   %ebx,%ebx
f0101177:	74 02                	je     f010117b <page_lookup+0x24>
		*pte_store = pt;
f0101179:	89 03                	mov    %eax,(%ebx)
f010117b:	8b 00                	mov    (%eax),%eax
f010117d:	c1 e8 0c             	shr    $0xc,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101180:	39 05 88 4e 23 f0    	cmp    %eax,0xf0234e88
f0101186:	76 0e                	jbe    f0101196 <page_lookup+0x3f>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f0101188:	8b 15 90 4e 23 f0    	mov    0xf0234e90,%edx
f010118e:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f0101191:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101194:	c9                   	leave  
f0101195:	c3                   	ret    
		panic("pa2page called with invalid pa");
f0101196:	83 ec 04             	sub    $0x4,%esp
f0101199:	68 10 6c 10 f0       	push   $0xf0106c10
f010119e:	6a 51                	push   $0x51
f01011a0:	68 55 74 10 f0       	push   $0xf0107455
f01011a5:	e8 96 ee ff ff       	call   f0100040 <_panic>
	if(!pt) return NULL;
f01011aa:	b8 00 00 00 00       	mov    $0x0,%eax
f01011af:	eb e0                	jmp    f0101191 <page_lookup+0x3a>

f01011b1 <tlb_invalidate>:
{
f01011b1:	55                   	push   %ebp
f01011b2:	89 e5                	mov    %esp,%ebp
f01011b4:	83 ec 08             	sub    $0x8,%esp
	if (!curenv || curenv->env_pgdir == pgdir)
f01011b7:	e8 6f 4d 00 00       	call   f0105f2b <cpunum>
f01011bc:	6b c0 74             	imul   $0x74,%eax,%eax
f01011bf:	83 b8 28 50 23 f0 00 	cmpl   $0x0,-0xfdcafd8(%eax)
f01011c6:	74 16                	je     f01011de <tlb_invalidate+0x2d>
f01011c8:	e8 5e 4d 00 00       	call   f0105f2b <cpunum>
f01011cd:	6b c0 74             	imul   $0x74,%eax,%eax
f01011d0:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f01011d6:	8b 55 08             	mov    0x8(%ebp),%edx
f01011d9:	39 50 60             	cmp    %edx,0x60(%eax)
f01011dc:	75 06                	jne    f01011e4 <tlb_invalidate+0x33>
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01011de:	8b 45 0c             	mov    0xc(%ebp),%eax
f01011e1:	0f 01 38             	invlpg (%eax)
}
f01011e4:	c9                   	leave  
f01011e5:	c3                   	ret    

f01011e6 <page_remove>:
{
f01011e6:	55                   	push   %ebp
f01011e7:	89 e5                	mov    %esp,%ebp
f01011e9:	56                   	push   %esi
f01011ea:	53                   	push   %ebx
f01011eb:	83 ec 14             	sub    $0x14,%esp
f01011ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01011f1:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct PageInfo* pageinfo = page_lookup(pgdir,va,&pt);
f01011f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01011f7:	50                   	push   %eax
f01011f8:	56                   	push   %esi
f01011f9:	53                   	push   %ebx
f01011fa:	e8 58 ff ff ff       	call   f0101157 <page_lookup>
        if(!pageinfo) return;
f01011ff:	83 c4 10             	add    $0x10,%esp
f0101202:	85 c0                	test   %eax,%eax
f0101204:	75 07                	jne    f010120d <page_remove+0x27>
}
f0101206:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101209:	5b                   	pop    %ebx
f010120a:	5e                   	pop    %esi
f010120b:	5d                   	pop    %ebp
f010120c:	c3                   	ret    
	page_decref(pageinfo);
f010120d:	83 ec 0c             	sub    $0xc,%esp
f0101210:	50                   	push   %eax
f0101211:	e8 a8 fd ff ff       	call   f0100fbe <page_decref>
	*pt = 0;
f0101216:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101219:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	tlb_invalidate(pgdir,va);
f010121f:	83 c4 08             	add    $0x8,%esp
f0101222:	56                   	push   %esi
f0101223:	53                   	push   %ebx
f0101224:	e8 88 ff ff ff       	call   f01011b1 <tlb_invalidate>
f0101229:	83 c4 10             	add    $0x10,%esp
f010122c:	eb d8                	jmp    f0101206 <page_remove+0x20>

f010122e <page_insert>:
{
f010122e:	55                   	push   %ebp
f010122f:	89 e5                	mov    %esp,%ebp
f0101231:	57                   	push   %edi
f0101232:	56                   	push   %esi
f0101233:	53                   	push   %ebx
f0101234:	83 ec 10             	sub    $0x10,%esp
f0101237:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010123a:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t *pt=pgdir_walk(pgdir,va,1);
f010123d:	6a 01                	push   $0x1
f010123f:	57                   	push   %edi
f0101240:	ff 75 08             	pushl  0x8(%ebp)
f0101243:	e8 9f fd ff ff       	call   f0100fe7 <pgdir_walk>
	if(!pt) return -E_NO_MEM;
f0101248:	83 c4 10             	add    $0x10,%esp
f010124b:	85 c0                	test   %eax,%eax
f010124d:	74 40                	je     f010128f <page_insert+0x61>
f010124f:	89 c6                	mov    %eax,%esi
	pp->pp_ref++;
f0101251:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	if(*pt & PTE_P){
f0101256:	f6 00 01             	testb  $0x1,(%eax)
f0101259:	75 23                	jne    f010127e <page_insert+0x50>
	return (pp - pages) << PGSHIFT;
f010125b:	2b 1d 90 4e 23 f0    	sub    0xf0234e90,%ebx
f0101261:	c1 fb 03             	sar    $0x3,%ebx
f0101264:	c1 e3 0c             	shl    $0xc,%ebx
	*pt = page2pa(pp)|perm|PTE_P;
f0101267:	8b 45 14             	mov    0x14(%ebp),%eax
f010126a:	83 c8 01             	or     $0x1,%eax
f010126d:	09 c3                	or     %eax,%ebx
f010126f:	89 1e                	mov    %ebx,(%esi)
	return 0;
f0101271:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101276:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101279:	5b                   	pop    %ebx
f010127a:	5e                   	pop    %esi
f010127b:	5f                   	pop    %edi
f010127c:	5d                   	pop    %ebp
f010127d:	c3                   	ret    
		page_remove(pgdir,va);
f010127e:	83 ec 08             	sub    $0x8,%esp
f0101281:	57                   	push   %edi
f0101282:	ff 75 08             	pushl  0x8(%ebp)
f0101285:	e8 5c ff ff ff       	call   f01011e6 <page_remove>
f010128a:	83 c4 10             	add    $0x10,%esp
f010128d:	eb cc                	jmp    f010125b <page_insert+0x2d>
	if(!pt) return -E_NO_MEM;
f010128f:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0101294:	eb e0                	jmp    f0101276 <page_insert+0x48>

f0101296 <mmio_map_region>:
{
f0101296:	55                   	push   %ebp
f0101297:	89 e5                	mov    %esp,%ebp
f0101299:	56                   	push   %esi
f010129a:	53                   	push   %ebx
        size = ROUNDUP(size,PGSIZE);
f010129b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010129e:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f01012a4:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	void *ret = (void*) base;
f01012aa:	8b 35 00 23 12 f0    	mov    0xf0122300,%esi
	if(base+size>MMIOLIM || base+size < base)
f01012b0:	89 f0                	mov    %esi,%eax
f01012b2:	01 d8                	add    %ebx,%eax
f01012b4:	72 2c                	jb     f01012e2 <mmio_map_region+0x4c>
f01012b6:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f01012bb:	77 25                	ja     f01012e2 <mmio_map_region+0x4c>
	boot_map_region(kern_pgdir,base,size,pa,PTE_W|PTE_PCD|PTE_PWT);
f01012bd:	83 ec 08             	sub    $0x8,%esp
f01012c0:	6a 1a                	push   $0x1a
f01012c2:	ff 75 08             	pushl  0x8(%ebp)
f01012c5:	89 d9                	mov    %ebx,%ecx
f01012c7:	89 f2                	mov    %esi,%edx
f01012c9:	a1 8c 4e 23 f0       	mov    0xf0234e8c,%eax
f01012ce:	e8 ff fd ff ff       	call   f01010d2 <boot_map_region>
	base+=size;
f01012d3:	01 1d 00 23 12 f0    	add    %ebx,0xf0122300
}
f01012d9:	89 f0                	mov    %esi,%eax
f01012db:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01012de:	5b                   	pop    %ebx
f01012df:	5e                   	pop    %esi
f01012e0:	5d                   	pop    %ebp
f01012e1:	c3                   	ret    
		panic("mmio_map_region failed\n");
f01012e2:	83 ec 04             	sub    $0x4,%esp
f01012e5:	68 36 75 10 f0       	push   $0xf0107536
f01012ea:	68 66 02 00 00       	push   $0x266
f01012ef:	68 49 74 10 f0       	push   $0xf0107449
f01012f4:	e8 47 ed ff ff       	call   f0100040 <_panic>

f01012f9 <mem_init>:
{
f01012f9:	55                   	push   %ebp
f01012fa:	89 e5                	mov    %esp,%ebp
f01012fc:	57                   	push   %edi
f01012fd:	56                   	push   %esi
f01012fe:	53                   	push   %ebx
f01012ff:	83 ec 3c             	sub    $0x3c,%esp
	basemem = nvram_read(NVRAM_BASELO);
f0101302:	b8 15 00 00 00       	mov    $0x15,%eax
f0101307:	e8 9c f7 ff ff       	call   f0100aa8 <nvram_read>
f010130c:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f010130e:	b8 17 00 00 00       	mov    $0x17,%eax
f0101313:	e8 90 f7 ff ff       	call   f0100aa8 <nvram_read>
f0101318:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f010131a:	b8 34 00 00 00       	mov    $0x34,%eax
f010131f:	e8 84 f7 ff ff       	call   f0100aa8 <nvram_read>
f0101324:	c1 e0 06             	shl    $0x6,%eax
	if (ext16mem)
f0101327:	85 c0                	test   %eax,%eax
f0101329:	0f 85 d9 00 00 00    	jne    f0101408 <mem_init+0x10f>
		totalmem = 1 * 1024 + extmem;
f010132f:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0101335:	85 f6                	test   %esi,%esi
f0101337:	0f 44 c3             	cmove  %ebx,%eax
	npages = totalmem / (PGSIZE / 1024);
f010133a:	89 c2                	mov    %eax,%edx
f010133c:	c1 ea 02             	shr    $0x2,%edx
f010133f:	89 15 88 4e 23 f0    	mov    %edx,0xf0234e88
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101345:	89 c2                	mov    %eax,%edx
f0101347:	29 da                	sub    %ebx,%edx
f0101349:	52                   	push   %edx
f010134a:	53                   	push   %ebx
f010134b:	50                   	push   %eax
f010134c:	68 30 6c 10 f0       	push   $0xf0106c30
f0101351:	e8 ee 25 00 00       	call   f0103944 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101356:	b8 00 10 00 00       	mov    $0x1000,%eax
f010135b:	e8 0c f7 ff ff       	call   f0100a6c <boot_alloc>
f0101360:	a3 8c 4e 23 f0       	mov    %eax,0xf0234e8c
	memset(kern_pgdir, 0, PGSIZE);
f0101365:	83 c4 0c             	add    $0xc,%esp
f0101368:	68 00 10 00 00       	push   $0x1000
f010136d:	6a 00                	push   $0x0
f010136f:	50                   	push   %eax
f0101370:	e8 92 45 00 00       	call   f0105907 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101375:	a1 8c 4e 23 f0       	mov    0xf0234e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f010137a:	83 c4 10             	add    $0x10,%esp
f010137d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101382:	0f 86 8a 00 00 00    	jbe    f0101412 <mem_init+0x119>
	return (physaddr_t)kva - KERNBASE;
f0101388:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010138e:	83 ca 05             	or     $0x5,%edx
f0101391:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
        pages =(struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f0101397:	a1 88 4e 23 f0       	mov    0xf0234e88,%eax
f010139c:	c1 e0 03             	shl    $0x3,%eax
f010139f:	e8 c8 f6 ff ff       	call   f0100a6c <boot_alloc>
f01013a4:	a3 90 4e 23 f0       	mov    %eax,0xf0234e90
        memset(pages,0, npages * sizeof(struct PageInfo));
f01013a9:	83 ec 04             	sub    $0x4,%esp
f01013ac:	8b 0d 88 4e 23 f0    	mov    0xf0234e88,%ecx
f01013b2:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f01013b9:	52                   	push   %edx
f01013ba:	6a 00                	push   $0x0
f01013bc:	50                   	push   %eax
f01013bd:	e8 45 45 00 00       	call   f0105907 <memset>
        envs = (struct Env*) boot_alloc(sizeof(struct Env)*NENV);
f01013c2:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f01013c7:	e8 a0 f6 ff ff       	call   f0100a6c <boot_alloc>
f01013cc:	a3 44 42 23 f0       	mov    %eax,0xf0234244
	memset(envs,0,sizeof(struct Env) * NENV);
f01013d1:	83 c4 0c             	add    $0xc,%esp
f01013d4:	68 00 f0 01 00       	push   $0x1f000
f01013d9:	6a 00                	push   $0x0
f01013db:	50                   	push   %eax
f01013dc:	e8 26 45 00 00       	call   f0105907 <memset>
	page_init();
f01013e1:	e8 4c fa ff ff       	call   f0100e32 <page_init>
	check_page_free_list(1);
f01013e6:	b8 01 00 00 00       	mov    $0x1,%eax
f01013eb:	e8 45 f7 ff ff       	call   f0100b35 <check_page_free_list>
	if (!pages)
f01013f0:	83 c4 10             	add    $0x10,%esp
f01013f3:	83 3d 90 4e 23 f0 00 	cmpl   $0x0,0xf0234e90
f01013fa:	74 2b                	je     f0101427 <mem_init+0x12e>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01013fc:	a1 40 42 23 f0       	mov    0xf0234240,%eax
f0101401:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101406:	eb 3b                	jmp    f0101443 <mem_init+0x14a>
		totalmem = 16 * 1024 + ext16mem;
f0101408:	05 00 40 00 00       	add    $0x4000,%eax
f010140d:	e9 28 ff ff ff       	jmp    f010133a <mem_init+0x41>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101412:	50                   	push   %eax
f0101413:	68 a8 65 10 f0       	push   $0xf01065a8
f0101418:	68 93 00 00 00       	push   $0x93
f010141d:	68 49 74 10 f0       	push   $0xf0107449
f0101422:	e8 19 ec ff ff       	call   f0100040 <_panic>
		panic("'pages' is a null pointer!");
f0101427:	83 ec 04             	sub    $0x4,%esp
f010142a:	68 4e 75 10 f0       	push   $0xf010754e
f010142f:	68 f8 02 00 00       	push   $0x2f8
f0101434:	68 49 74 10 f0       	push   $0xf0107449
f0101439:	e8 02 ec ff ff       	call   f0100040 <_panic>
		++nfree;
f010143e:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101441:	8b 00                	mov    (%eax),%eax
f0101443:	85 c0                	test   %eax,%eax
f0101445:	75 f7                	jne    f010143e <mem_init+0x145>
	assert((pp0 = page_alloc(0)));
f0101447:	83 ec 0c             	sub    $0xc,%esp
f010144a:	6a 00                	push   $0x0
f010144c:	e8 c0 fa ff ff       	call   f0100f11 <page_alloc>
f0101451:	89 c7                	mov    %eax,%edi
f0101453:	83 c4 10             	add    $0x10,%esp
f0101456:	85 c0                	test   %eax,%eax
f0101458:	0f 84 12 02 00 00    	je     f0101670 <mem_init+0x377>
	assert((pp1 = page_alloc(0)));
f010145e:	83 ec 0c             	sub    $0xc,%esp
f0101461:	6a 00                	push   $0x0
f0101463:	e8 a9 fa ff ff       	call   f0100f11 <page_alloc>
f0101468:	89 c6                	mov    %eax,%esi
f010146a:	83 c4 10             	add    $0x10,%esp
f010146d:	85 c0                	test   %eax,%eax
f010146f:	0f 84 14 02 00 00    	je     f0101689 <mem_init+0x390>
	assert((pp2 = page_alloc(0)));
f0101475:	83 ec 0c             	sub    $0xc,%esp
f0101478:	6a 00                	push   $0x0
f010147a:	e8 92 fa ff ff       	call   f0100f11 <page_alloc>
f010147f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101482:	83 c4 10             	add    $0x10,%esp
f0101485:	85 c0                	test   %eax,%eax
f0101487:	0f 84 15 02 00 00    	je     f01016a2 <mem_init+0x3a9>
	assert(pp1 && pp1 != pp0);
f010148d:	39 f7                	cmp    %esi,%edi
f010148f:	0f 84 26 02 00 00    	je     f01016bb <mem_init+0x3c2>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101495:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101498:	39 c7                	cmp    %eax,%edi
f010149a:	0f 84 34 02 00 00    	je     f01016d4 <mem_init+0x3db>
f01014a0:	39 c6                	cmp    %eax,%esi
f01014a2:	0f 84 2c 02 00 00    	je     f01016d4 <mem_init+0x3db>
	return (pp - pages) << PGSHIFT;
f01014a8:	8b 0d 90 4e 23 f0    	mov    0xf0234e90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01014ae:	8b 15 88 4e 23 f0    	mov    0xf0234e88,%edx
f01014b4:	c1 e2 0c             	shl    $0xc,%edx
f01014b7:	89 f8                	mov    %edi,%eax
f01014b9:	29 c8                	sub    %ecx,%eax
f01014bb:	c1 f8 03             	sar    $0x3,%eax
f01014be:	c1 e0 0c             	shl    $0xc,%eax
f01014c1:	39 d0                	cmp    %edx,%eax
f01014c3:	0f 83 24 02 00 00    	jae    f01016ed <mem_init+0x3f4>
f01014c9:	89 f0                	mov    %esi,%eax
f01014cb:	29 c8                	sub    %ecx,%eax
f01014cd:	c1 f8 03             	sar    $0x3,%eax
f01014d0:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f01014d3:	39 c2                	cmp    %eax,%edx
f01014d5:	0f 86 2b 02 00 00    	jbe    f0101706 <mem_init+0x40d>
f01014db:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01014de:	29 c8                	sub    %ecx,%eax
f01014e0:	c1 f8 03             	sar    $0x3,%eax
f01014e3:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f01014e6:	39 c2                	cmp    %eax,%edx
f01014e8:	0f 86 31 02 00 00    	jbe    f010171f <mem_init+0x426>
	fl = page_free_list;
f01014ee:	a1 40 42 23 f0       	mov    0xf0234240,%eax
f01014f3:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01014f6:	c7 05 40 42 23 f0 00 	movl   $0x0,0xf0234240
f01014fd:	00 00 00 
	assert(!page_alloc(0));
f0101500:	83 ec 0c             	sub    $0xc,%esp
f0101503:	6a 00                	push   $0x0
f0101505:	e8 07 fa ff ff       	call   f0100f11 <page_alloc>
f010150a:	83 c4 10             	add    $0x10,%esp
f010150d:	85 c0                	test   %eax,%eax
f010150f:	0f 85 23 02 00 00    	jne    f0101738 <mem_init+0x43f>
	page_free(pp0);
f0101515:	83 ec 0c             	sub    $0xc,%esp
f0101518:	57                   	push   %edi
f0101519:	e8 65 fa ff ff       	call   f0100f83 <page_free>
	page_free(pp1);
f010151e:	89 34 24             	mov    %esi,(%esp)
f0101521:	e8 5d fa ff ff       	call   f0100f83 <page_free>
	page_free(pp2);
f0101526:	83 c4 04             	add    $0x4,%esp
f0101529:	ff 75 d4             	pushl  -0x2c(%ebp)
f010152c:	e8 52 fa ff ff       	call   f0100f83 <page_free>
	assert((pp0 = page_alloc(0)));
f0101531:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101538:	e8 d4 f9 ff ff       	call   f0100f11 <page_alloc>
f010153d:	89 c6                	mov    %eax,%esi
f010153f:	83 c4 10             	add    $0x10,%esp
f0101542:	85 c0                	test   %eax,%eax
f0101544:	0f 84 07 02 00 00    	je     f0101751 <mem_init+0x458>
	assert((pp1 = page_alloc(0)));
f010154a:	83 ec 0c             	sub    $0xc,%esp
f010154d:	6a 00                	push   $0x0
f010154f:	e8 bd f9 ff ff       	call   f0100f11 <page_alloc>
f0101554:	89 c7                	mov    %eax,%edi
f0101556:	83 c4 10             	add    $0x10,%esp
f0101559:	85 c0                	test   %eax,%eax
f010155b:	0f 84 09 02 00 00    	je     f010176a <mem_init+0x471>
	assert((pp2 = page_alloc(0)));
f0101561:	83 ec 0c             	sub    $0xc,%esp
f0101564:	6a 00                	push   $0x0
f0101566:	e8 a6 f9 ff ff       	call   f0100f11 <page_alloc>
f010156b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010156e:	83 c4 10             	add    $0x10,%esp
f0101571:	85 c0                	test   %eax,%eax
f0101573:	0f 84 0a 02 00 00    	je     f0101783 <mem_init+0x48a>
	assert(pp1 && pp1 != pp0);
f0101579:	39 fe                	cmp    %edi,%esi
f010157b:	0f 84 1b 02 00 00    	je     f010179c <mem_init+0x4a3>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101581:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101584:	39 c7                	cmp    %eax,%edi
f0101586:	0f 84 29 02 00 00    	je     f01017b5 <mem_init+0x4bc>
f010158c:	39 c6                	cmp    %eax,%esi
f010158e:	0f 84 21 02 00 00    	je     f01017b5 <mem_init+0x4bc>
	assert(!page_alloc(0));
f0101594:	83 ec 0c             	sub    $0xc,%esp
f0101597:	6a 00                	push   $0x0
f0101599:	e8 73 f9 ff ff       	call   f0100f11 <page_alloc>
f010159e:	83 c4 10             	add    $0x10,%esp
f01015a1:	85 c0                	test   %eax,%eax
f01015a3:	0f 85 25 02 00 00    	jne    f01017ce <mem_init+0x4d5>
f01015a9:	89 f0                	mov    %esi,%eax
f01015ab:	2b 05 90 4e 23 f0    	sub    0xf0234e90,%eax
f01015b1:	c1 f8 03             	sar    $0x3,%eax
f01015b4:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01015b7:	89 c2                	mov    %eax,%edx
f01015b9:	c1 ea 0c             	shr    $0xc,%edx
f01015bc:	3b 15 88 4e 23 f0    	cmp    0xf0234e88,%edx
f01015c2:	0f 83 1f 02 00 00    	jae    f01017e7 <mem_init+0x4ee>
	memset(page2kva(pp0), 1, PGSIZE);
f01015c8:	83 ec 04             	sub    $0x4,%esp
f01015cb:	68 00 10 00 00       	push   $0x1000
f01015d0:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f01015d2:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01015d7:	50                   	push   %eax
f01015d8:	e8 2a 43 00 00       	call   f0105907 <memset>
	page_free(pp0);
f01015dd:	89 34 24             	mov    %esi,(%esp)
f01015e0:	e8 9e f9 ff ff       	call   f0100f83 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01015e5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01015ec:	e8 20 f9 ff ff       	call   f0100f11 <page_alloc>
f01015f1:	83 c4 10             	add    $0x10,%esp
f01015f4:	85 c0                	test   %eax,%eax
f01015f6:	0f 84 fd 01 00 00    	je     f01017f9 <mem_init+0x500>
	assert(pp && pp0 == pp);
f01015fc:	39 c6                	cmp    %eax,%esi
f01015fe:	0f 85 0e 02 00 00    	jne    f0101812 <mem_init+0x519>
	return (pp - pages) << PGSHIFT;
f0101604:	89 f2                	mov    %esi,%edx
f0101606:	2b 15 90 4e 23 f0    	sub    0xf0234e90,%edx
f010160c:	c1 fa 03             	sar    $0x3,%edx
f010160f:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101612:	89 d0                	mov    %edx,%eax
f0101614:	c1 e8 0c             	shr    $0xc,%eax
f0101617:	3b 05 88 4e 23 f0    	cmp    0xf0234e88,%eax
f010161d:	0f 83 08 02 00 00    	jae    f010182b <mem_init+0x532>
	return (void *)(pa + KERNBASE);
f0101623:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101629:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f010162f:	80 38 00             	cmpb   $0x0,(%eax)
f0101632:	0f 85 05 02 00 00    	jne    f010183d <mem_init+0x544>
f0101638:	83 c0 01             	add    $0x1,%eax
	for (i = 0; i < PGSIZE; i++)
f010163b:	39 d0                	cmp    %edx,%eax
f010163d:	75 f0                	jne    f010162f <mem_init+0x336>
	page_free_list = fl;
f010163f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101642:	a3 40 42 23 f0       	mov    %eax,0xf0234240
	page_free(pp0);
f0101647:	83 ec 0c             	sub    $0xc,%esp
f010164a:	56                   	push   %esi
f010164b:	e8 33 f9 ff ff       	call   f0100f83 <page_free>
	page_free(pp1);
f0101650:	89 3c 24             	mov    %edi,(%esp)
f0101653:	e8 2b f9 ff ff       	call   f0100f83 <page_free>
	page_free(pp2);
f0101658:	83 c4 04             	add    $0x4,%esp
f010165b:	ff 75 d4             	pushl  -0x2c(%ebp)
f010165e:	e8 20 f9 ff ff       	call   f0100f83 <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101663:	a1 40 42 23 f0       	mov    0xf0234240,%eax
f0101668:	83 c4 10             	add    $0x10,%esp
f010166b:	e9 eb 01 00 00       	jmp    f010185b <mem_init+0x562>
	assert((pp0 = page_alloc(0)));
f0101670:	68 69 75 10 f0       	push   $0xf0107569
f0101675:	68 6f 74 10 f0       	push   $0xf010746f
f010167a:	68 00 03 00 00       	push   $0x300
f010167f:	68 49 74 10 f0       	push   $0xf0107449
f0101684:	e8 b7 e9 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101689:	68 7f 75 10 f0       	push   $0xf010757f
f010168e:	68 6f 74 10 f0       	push   $0xf010746f
f0101693:	68 01 03 00 00       	push   $0x301
f0101698:	68 49 74 10 f0       	push   $0xf0107449
f010169d:	e8 9e e9 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01016a2:	68 95 75 10 f0       	push   $0xf0107595
f01016a7:	68 6f 74 10 f0       	push   $0xf010746f
f01016ac:	68 02 03 00 00       	push   $0x302
f01016b1:	68 49 74 10 f0       	push   $0xf0107449
f01016b6:	e8 85 e9 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f01016bb:	68 ab 75 10 f0       	push   $0xf01075ab
f01016c0:	68 6f 74 10 f0       	push   $0xf010746f
f01016c5:	68 05 03 00 00       	push   $0x305
f01016ca:	68 49 74 10 f0       	push   $0xf0107449
f01016cf:	e8 6c e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01016d4:	68 6c 6c 10 f0       	push   $0xf0106c6c
f01016d9:	68 6f 74 10 f0       	push   $0xf010746f
f01016de:	68 06 03 00 00       	push   $0x306
f01016e3:	68 49 74 10 f0       	push   $0xf0107449
f01016e8:	e8 53 e9 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f01016ed:	68 bd 75 10 f0       	push   $0xf01075bd
f01016f2:	68 6f 74 10 f0       	push   $0xf010746f
f01016f7:	68 07 03 00 00       	push   $0x307
f01016fc:	68 49 74 10 f0       	push   $0xf0107449
f0101701:	e8 3a e9 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101706:	68 da 75 10 f0       	push   $0xf01075da
f010170b:	68 6f 74 10 f0       	push   $0xf010746f
f0101710:	68 08 03 00 00       	push   $0x308
f0101715:	68 49 74 10 f0       	push   $0xf0107449
f010171a:	e8 21 e9 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f010171f:	68 f7 75 10 f0       	push   $0xf01075f7
f0101724:	68 6f 74 10 f0       	push   $0xf010746f
f0101729:	68 09 03 00 00       	push   $0x309
f010172e:	68 49 74 10 f0       	push   $0xf0107449
f0101733:	e8 08 e9 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101738:	68 14 76 10 f0       	push   $0xf0107614
f010173d:	68 6f 74 10 f0       	push   $0xf010746f
f0101742:	68 10 03 00 00       	push   $0x310
f0101747:	68 49 74 10 f0       	push   $0xf0107449
f010174c:	e8 ef e8 ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f0101751:	68 69 75 10 f0       	push   $0xf0107569
f0101756:	68 6f 74 10 f0       	push   $0xf010746f
f010175b:	68 17 03 00 00       	push   $0x317
f0101760:	68 49 74 10 f0       	push   $0xf0107449
f0101765:	e8 d6 e8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010176a:	68 7f 75 10 f0       	push   $0xf010757f
f010176f:	68 6f 74 10 f0       	push   $0xf010746f
f0101774:	68 18 03 00 00       	push   $0x318
f0101779:	68 49 74 10 f0       	push   $0xf0107449
f010177e:	e8 bd e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101783:	68 95 75 10 f0       	push   $0xf0107595
f0101788:	68 6f 74 10 f0       	push   $0xf010746f
f010178d:	68 19 03 00 00       	push   $0x319
f0101792:	68 49 74 10 f0       	push   $0xf0107449
f0101797:	e8 a4 e8 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f010179c:	68 ab 75 10 f0       	push   $0xf01075ab
f01017a1:	68 6f 74 10 f0       	push   $0xf010746f
f01017a6:	68 1b 03 00 00       	push   $0x31b
f01017ab:	68 49 74 10 f0       	push   $0xf0107449
f01017b0:	e8 8b e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017b5:	68 6c 6c 10 f0       	push   $0xf0106c6c
f01017ba:	68 6f 74 10 f0       	push   $0xf010746f
f01017bf:	68 1c 03 00 00       	push   $0x31c
f01017c4:	68 49 74 10 f0       	push   $0xf0107449
f01017c9:	e8 72 e8 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01017ce:	68 14 76 10 f0       	push   $0xf0107614
f01017d3:	68 6f 74 10 f0       	push   $0xf010746f
f01017d8:	68 1d 03 00 00       	push   $0x31d
f01017dd:	68 49 74 10 f0       	push   $0xf0107449
f01017e2:	e8 59 e8 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01017e7:	50                   	push   %eax
f01017e8:	68 84 65 10 f0       	push   $0xf0106584
f01017ed:	6a 58                	push   $0x58
f01017ef:	68 55 74 10 f0       	push   $0xf0107455
f01017f4:	e8 47 e8 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01017f9:	68 23 76 10 f0       	push   $0xf0107623
f01017fe:	68 6f 74 10 f0       	push   $0xf010746f
f0101803:	68 22 03 00 00       	push   $0x322
f0101808:	68 49 74 10 f0       	push   $0xf0107449
f010180d:	e8 2e e8 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101812:	68 41 76 10 f0       	push   $0xf0107641
f0101817:	68 6f 74 10 f0       	push   $0xf010746f
f010181c:	68 23 03 00 00       	push   $0x323
f0101821:	68 49 74 10 f0       	push   $0xf0107449
f0101826:	e8 15 e8 ff ff       	call   f0100040 <_panic>
f010182b:	52                   	push   %edx
f010182c:	68 84 65 10 f0       	push   $0xf0106584
f0101831:	6a 58                	push   $0x58
f0101833:	68 55 74 10 f0       	push   $0xf0107455
f0101838:	e8 03 e8 ff ff       	call   f0100040 <_panic>
		assert(c[i] == 0);
f010183d:	68 51 76 10 f0       	push   $0xf0107651
f0101842:	68 6f 74 10 f0       	push   $0xf010746f
f0101847:	68 26 03 00 00       	push   $0x326
f010184c:	68 49 74 10 f0       	push   $0xf0107449
f0101851:	e8 ea e7 ff ff       	call   f0100040 <_panic>
		--nfree;
f0101856:	83 eb 01             	sub    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101859:	8b 00                	mov    (%eax),%eax
f010185b:	85 c0                	test   %eax,%eax
f010185d:	75 f7                	jne    f0101856 <mem_init+0x55d>
	assert(nfree == 0);
f010185f:	85 db                	test   %ebx,%ebx
f0101861:	0f 85 64 09 00 00    	jne    f01021cb <mem_init+0xed2>
	cprintf("check_page_alloc() succeeded!\n");
f0101867:	83 ec 0c             	sub    $0xc,%esp
f010186a:	68 8c 6c 10 f0       	push   $0xf0106c8c
f010186f:	e8 d0 20 00 00       	call   f0103944 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101874:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010187b:	e8 91 f6 ff ff       	call   f0100f11 <page_alloc>
f0101880:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101883:	83 c4 10             	add    $0x10,%esp
f0101886:	85 c0                	test   %eax,%eax
f0101888:	0f 84 56 09 00 00    	je     f01021e4 <mem_init+0xeeb>
	assert((pp1 = page_alloc(0)));
f010188e:	83 ec 0c             	sub    $0xc,%esp
f0101891:	6a 00                	push   $0x0
f0101893:	e8 79 f6 ff ff       	call   f0100f11 <page_alloc>
f0101898:	89 c3                	mov    %eax,%ebx
f010189a:	83 c4 10             	add    $0x10,%esp
f010189d:	85 c0                	test   %eax,%eax
f010189f:	0f 84 58 09 00 00    	je     f01021fd <mem_init+0xf04>
	assert((pp2 = page_alloc(0)));
f01018a5:	83 ec 0c             	sub    $0xc,%esp
f01018a8:	6a 00                	push   $0x0
f01018aa:	e8 62 f6 ff ff       	call   f0100f11 <page_alloc>
f01018af:	89 c6                	mov    %eax,%esi
f01018b1:	83 c4 10             	add    $0x10,%esp
f01018b4:	85 c0                	test   %eax,%eax
f01018b6:	0f 84 5a 09 00 00    	je     f0102216 <mem_init+0xf1d>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01018bc:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01018bf:	0f 84 6a 09 00 00    	je     f010222f <mem_init+0xf36>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01018c5:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01018c8:	0f 84 7a 09 00 00    	je     f0102248 <mem_init+0xf4f>
f01018ce:	39 c3                	cmp    %eax,%ebx
f01018d0:	0f 84 72 09 00 00    	je     f0102248 <mem_init+0xf4f>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01018d6:	a1 40 42 23 f0       	mov    0xf0234240,%eax
f01018db:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f01018de:	c7 05 40 42 23 f0 00 	movl   $0x0,0xf0234240
f01018e5:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01018e8:	83 ec 0c             	sub    $0xc,%esp
f01018eb:	6a 00                	push   $0x0
f01018ed:	e8 1f f6 ff ff       	call   f0100f11 <page_alloc>
f01018f2:	83 c4 10             	add    $0x10,%esp
f01018f5:	85 c0                	test   %eax,%eax
f01018f7:	0f 85 64 09 00 00    	jne    f0102261 <mem_init+0xf68>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01018fd:	83 ec 04             	sub    $0x4,%esp
f0101900:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101903:	50                   	push   %eax
f0101904:	6a 00                	push   $0x0
f0101906:	ff 35 8c 4e 23 f0    	pushl  0xf0234e8c
f010190c:	e8 46 f8 ff ff       	call   f0101157 <page_lookup>
f0101911:	83 c4 10             	add    $0x10,%esp
f0101914:	85 c0                	test   %eax,%eax
f0101916:	0f 85 5e 09 00 00    	jne    f010227a <mem_init+0xf81>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f010191c:	6a 02                	push   $0x2
f010191e:	6a 00                	push   $0x0
f0101920:	53                   	push   %ebx
f0101921:	ff 35 8c 4e 23 f0    	pushl  0xf0234e8c
f0101927:	e8 02 f9 ff ff       	call   f010122e <page_insert>
f010192c:	83 c4 10             	add    $0x10,%esp
f010192f:	85 c0                	test   %eax,%eax
f0101931:	0f 89 5c 09 00 00    	jns    f0102293 <mem_init+0xf9a>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101937:	83 ec 0c             	sub    $0xc,%esp
f010193a:	ff 75 d4             	pushl  -0x2c(%ebp)
f010193d:	e8 41 f6 ff ff       	call   f0100f83 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101942:	6a 02                	push   $0x2
f0101944:	6a 00                	push   $0x0
f0101946:	53                   	push   %ebx
f0101947:	ff 35 8c 4e 23 f0    	pushl  0xf0234e8c
f010194d:	e8 dc f8 ff ff       	call   f010122e <page_insert>
f0101952:	83 c4 20             	add    $0x20,%esp
f0101955:	85 c0                	test   %eax,%eax
f0101957:	0f 85 4f 09 00 00    	jne    f01022ac <mem_init+0xfb3>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010195d:	8b 3d 8c 4e 23 f0    	mov    0xf0234e8c,%edi
	return (pp - pages) << PGSHIFT;
f0101963:	8b 0d 90 4e 23 f0    	mov    0xf0234e90,%ecx
f0101969:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f010196c:	8b 17                	mov    (%edi),%edx
f010196e:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101974:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101977:	29 c8                	sub    %ecx,%eax
f0101979:	c1 f8 03             	sar    $0x3,%eax
f010197c:	c1 e0 0c             	shl    $0xc,%eax
f010197f:	39 c2                	cmp    %eax,%edx
f0101981:	0f 85 3e 09 00 00    	jne    f01022c5 <mem_init+0xfcc>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101987:	ba 00 00 00 00       	mov    $0x0,%edx
f010198c:	89 f8                	mov    %edi,%eax
f010198e:	e8 3e f1 ff ff       	call   f0100ad1 <check_va2pa>
f0101993:	89 da                	mov    %ebx,%edx
f0101995:	2b 55 d0             	sub    -0x30(%ebp),%edx
f0101998:	c1 fa 03             	sar    $0x3,%edx
f010199b:	c1 e2 0c             	shl    $0xc,%edx
f010199e:	39 d0                	cmp    %edx,%eax
f01019a0:	0f 85 38 09 00 00    	jne    f01022de <mem_init+0xfe5>
	assert(pp1->pp_ref == 1);
f01019a6:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01019ab:	0f 85 46 09 00 00    	jne    f01022f7 <mem_init+0xffe>
	assert(pp0->pp_ref == 1);
f01019b1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019b4:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01019b9:	0f 85 51 09 00 00    	jne    f0102310 <mem_init+0x1017>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01019bf:	6a 02                	push   $0x2
f01019c1:	68 00 10 00 00       	push   $0x1000
f01019c6:	56                   	push   %esi
f01019c7:	57                   	push   %edi
f01019c8:	e8 61 f8 ff ff       	call   f010122e <page_insert>
f01019cd:	83 c4 10             	add    $0x10,%esp
f01019d0:	85 c0                	test   %eax,%eax
f01019d2:	0f 85 51 09 00 00    	jne    f0102329 <mem_init+0x1030>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01019d8:	ba 00 10 00 00       	mov    $0x1000,%edx
f01019dd:	a1 8c 4e 23 f0       	mov    0xf0234e8c,%eax
f01019e2:	e8 ea f0 ff ff       	call   f0100ad1 <check_va2pa>
f01019e7:	89 f2                	mov    %esi,%edx
f01019e9:	2b 15 90 4e 23 f0    	sub    0xf0234e90,%edx
f01019ef:	c1 fa 03             	sar    $0x3,%edx
f01019f2:	c1 e2 0c             	shl    $0xc,%edx
f01019f5:	39 d0                	cmp    %edx,%eax
f01019f7:	0f 85 45 09 00 00    	jne    f0102342 <mem_init+0x1049>
	assert(pp2->pp_ref == 1);
f01019fd:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101a02:	0f 85 53 09 00 00    	jne    f010235b <mem_init+0x1062>

	// should be no free memory
	assert(!page_alloc(0));
f0101a08:	83 ec 0c             	sub    $0xc,%esp
f0101a0b:	6a 00                	push   $0x0
f0101a0d:	e8 ff f4 ff ff       	call   f0100f11 <page_alloc>
f0101a12:	83 c4 10             	add    $0x10,%esp
f0101a15:	85 c0                	test   %eax,%eax
f0101a17:	0f 85 57 09 00 00    	jne    f0102374 <mem_init+0x107b>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a1d:	6a 02                	push   $0x2
f0101a1f:	68 00 10 00 00       	push   $0x1000
f0101a24:	56                   	push   %esi
f0101a25:	ff 35 8c 4e 23 f0    	pushl  0xf0234e8c
f0101a2b:	e8 fe f7 ff ff       	call   f010122e <page_insert>
f0101a30:	83 c4 10             	add    $0x10,%esp
f0101a33:	85 c0                	test   %eax,%eax
f0101a35:	0f 85 52 09 00 00    	jne    f010238d <mem_init+0x1094>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a3b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a40:	a1 8c 4e 23 f0       	mov    0xf0234e8c,%eax
f0101a45:	e8 87 f0 ff ff       	call   f0100ad1 <check_va2pa>
f0101a4a:	89 f2                	mov    %esi,%edx
f0101a4c:	2b 15 90 4e 23 f0    	sub    0xf0234e90,%edx
f0101a52:	c1 fa 03             	sar    $0x3,%edx
f0101a55:	c1 e2 0c             	shl    $0xc,%edx
f0101a58:	39 d0                	cmp    %edx,%eax
f0101a5a:	0f 85 46 09 00 00    	jne    f01023a6 <mem_init+0x10ad>
	assert(pp2->pp_ref == 1);
f0101a60:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101a65:	0f 85 54 09 00 00    	jne    f01023bf <mem_init+0x10c6>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101a6b:	83 ec 0c             	sub    $0xc,%esp
f0101a6e:	6a 00                	push   $0x0
f0101a70:	e8 9c f4 ff ff       	call   f0100f11 <page_alloc>
f0101a75:	83 c4 10             	add    $0x10,%esp
f0101a78:	85 c0                	test   %eax,%eax
f0101a7a:	0f 85 58 09 00 00    	jne    f01023d8 <mem_init+0x10df>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101a80:	8b 15 8c 4e 23 f0    	mov    0xf0234e8c,%edx
f0101a86:	8b 02                	mov    (%edx),%eax
f0101a88:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101a8d:	89 c1                	mov    %eax,%ecx
f0101a8f:	c1 e9 0c             	shr    $0xc,%ecx
f0101a92:	3b 0d 88 4e 23 f0    	cmp    0xf0234e88,%ecx
f0101a98:	0f 83 53 09 00 00    	jae    f01023f1 <mem_init+0x10f8>
	return (void *)(pa + KERNBASE);
f0101a9e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101aa3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101aa6:	83 ec 04             	sub    $0x4,%esp
f0101aa9:	6a 00                	push   $0x0
f0101aab:	68 00 10 00 00       	push   $0x1000
f0101ab0:	52                   	push   %edx
f0101ab1:	e8 31 f5 ff ff       	call   f0100fe7 <pgdir_walk>
f0101ab6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101ab9:	8d 51 04             	lea    0x4(%ecx),%edx
f0101abc:	83 c4 10             	add    $0x10,%esp
f0101abf:	39 d0                	cmp    %edx,%eax
f0101ac1:	0f 85 3f 09 00 00    	jne    f0102406 <mem_init+0x110d>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101ac7:	6a 06                	push   $0x6
f0101ac9:	68 00 10 00 00       	push   $0x1000
f0101ace:	56                   	push   %esi
f0101acf:	ff 35 8c 4e 23 f0    	pushl  0xf0234e8c
f0101ad5:	e8 54 f7 ff ff       	call   f010122e <page_insert>
f0101ada:	83 c4 10             	add    $0x10,%esp
f0101add:	85 c0                	test   %eax,%eax
f0101adf:	0f 85 3a 09 00 00    	jne    f010241f <mem_init+0x1126>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ae5:	8b 3d 8c 4e 23 f0    	mov    0xf0234e8c,%edi
f0101aeb:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101af0:	89 f8                	mov    %edi,%eax
f0101af2:	e8 da ef ff ff       	call   f0100ad1 <check_va2pa>
	return (pp - pages) << PGSHIFT;
f0101af7:	89 f2                	mov    %esi,%edx
f0101af9:	2b 15 90 4e 23 f0    	sub    0xf0234e90,%edx
f0101aff:	c1 fa 03             	sar    $0x3,%edx
f0101b02:	c1 e2 0c             	shl    $0xc,%edx
f0101b05:	39 d0                	cmp    %edx,%eax
f0101b07:	0f 85 2b 09 00 00    	jne    f0102438 <mem_init+0x113f>
	assert(pp2->pp_ref == 1);
f0101b0d:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101b12:	0f 85 39 09 00 00    	jne    f0102451 <mem_init+0x1158>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101b18:	83 ec 04             	sub    $0x4,%esp
f0101b1b:	6a 00                	push   $0x0
f0101b1d:	68 00 10 00 00       	push   $0x1000
f0101b22:	57                   	push   %edi
f0101b23:	e8 bf f4 ff ff       	call   f0100fe7 <pgdir_walk>
f0101b28:	83 c4 10             	add    $0x10,%esp
f0101b2b:	f6 00 04             	testb  $0x4,(%eax)
f0101b2e:	0f 84 36 09 00 00    	je     f010246a <mem_init+0x1171>
	assert(kern_pgdir[0] & PTE_U);
f0101b34:	a1 8c 4e 23 f0       	mov    0xf0234e8c,%eax
f0101b39:	f6 00 04             	testb  $0x4,(%eax)
f0101b3c:	0f 84 41 09 00 00    	je     f0102483 <mem_init+0x118a>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b42:	6a 02                	push   $0x2
f0101b44:	68 00 10 00 00       	push   $0x1000
f0101b49:	56                   	push   %esi
f0101b4a:	50                   	push   %eax
f0101b4b:	e8 de f6 ff ff       	call   f010122e <page_insert>
f0101b50:	83 c4 10             	add    $0x10,%esp
f0101b53:	85 c0                	test   %eax,%eax
f0101b55:	0f 85 41 09 00 00    	jne    f010249c <mem_init+0x11a3>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101b5b:	83 ec 04             	sub    $0x4,%esp
f0101b5e:	6a 00                	push   $0x0
f0101b60:	68 00 10 00 00       	push   $0x1000
f0101b65:	ff 35 8c 4e 23 f0    	pushl  0xf0234e8c
f0101b6b:	e8 77 f4 ff ff       	call   f0100fe7 <pgdir_walk>
f0101b70:	83 c4 10             	add    $0x10,%esp
f0101b73:	f6 00 02             	testb  $0x2,(%eax)
f0101b76:	0f 84 39 09 00 00    	je     f01024b5 <mem_init+0x11bc>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101b7c:	83 ec 04             	sub    $0x4,%esp
f0101b7f:	6a 00                	push   $0x0
f0101b81:	68 00 10 00 00       	push   $0x1000
f0101b86:	ff 35 8c 4e 23 f0    	pushl  0xf0234e8c
f0101b8c:	e8 56 f4 ff ff       	call   f0100fe7 <pgdir_walk>
f0101b91:	83 c4 10             	add    $0x10,%esp
f0101b94:	f6 00 04             	testb  $0x4,(%eax)
f0101b97:	0f 85 31 09 00 00    	jne    f01024ce <mem_init+0x11d5>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101b9d:	6a 02                	push   $0x2
f0101b9f:	68 00 00 40 00       	push   $0x400000
f0101ba4:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101ba7:	ff 35 8c 4e 23 f0    	pushl  0xf0234e8c
f0101bad:	e8 7c f6 ff ff       	call   f010122e <page_insert>
f0101bb2:	83 c4 10             	add    $0x10,%esp
f0101bb5:	85 c0                	test   %eax,%eax
f0101bb7:	0f 89 2a 09 00 00    	jns    f01024e7 <mem_init+0x11ee>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101bbd:	6a 02                	push   $0x2
f0101bbf:	68 00 10 00 00       	push   $0x1000
f0101bc4:	53                   	push   %ebx
f0101bc5:	ff 35 8c 4e 23 f0    	pushl  0xf0234e8c
f0101bcb:	e8 5e f6 ff ff       	call   f010122e <page_insert>
f0101bd0:	83 c4 10             	add    $0x10,%esp
f0101bd3:	85 c0                	test   %eax,%eax
f0101bd5:	0f 85 25 09 00 00    	jne    f0102500 <mem_init+0x1207>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101bdb:	83 ec 04             	sub    $0x4,%esp
f0101bde:	6a 00                	push   $0x0
f0101be0:	68 00 10 00 00       	push   $0x1000
f0101be5:	ff 35 8c 4e 23 f0    	pushl  0xf0234e8c
f0101beb:	e8 f7 f3 ff ff       	call   f0100fe7 <pgdir_walk>
f0101bf0:	83 c4 10             	add    $0x10,%esp
f0101bf3:	f6 00 04             	testb  $0x4,(%eax)
f0101bf6:	0f 85 1d 09 00 00    	jne    f0102519 <mem_init+0x1220>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101bfc:	8b 3d 8c 4e 23 f0    	mov    0xf0234e8c,%edi
f0101c02:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c07:	89 f8                	mov    %edi,%eax
f0101c09:	e8 c3 ee ff ff       	call   f0100ad1 <check_va2pa>
f0101c0e:	89 c1                	mov    %eax,%ecx
f0101c10:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101c13:	89 d8                	mov    %ebx,%eax
f0101c15:	2b 05 90 4e 23 f0    	sub    0xf0234e90,%eax
f0101c1b:	c1 f8 03             	sar    $0x3,%eax
f0101c1e:	c1 e0 0c             	shl    $0xc,%eax
f0101c21:	39 c1                	cmp    %eax,%ecx
f0101c23:	0f 85 09 09 00 00    	jne    f0102532 <mem_init+0x1239>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101c29:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c2e:	89 f8                	mov    %edi,%eax
f0101c30:	e8 9c ee ff ff       	call   f0100ad1 <check_va2pa>
f0101c35:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101c38:	0f 85 0d 09 00 00    	jne    f010254b <mem_init+0x1252>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101c3e:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101c43:	0f 85 1b 09 00 00    	jne    f0102564 <mem_init+0x126b>
	assert(pp2->pp_ref == 0);
f0101c49:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101c4e:	0f 85 29 09 00 00    	jne    f010257d <mem_init+0x1284>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101c54:	83 ec 0c             	sub    $0xc,%esp
f0101c57:	6a 00                	push   $0x0
f0101c59:	e8 b3 f2 ff ff       	call   f0100f11 <page_alloc>
f0101c5e:	83 c4 10             	add    $0x10,%esp
f0101c61:	39 c6                	cmp    %eax,%esi
f0101c63:	0f 85 2d 09 00 00    	jne    f0102596 <mem_init+0x129d>
f0101c69:	85 c0                	test   %eax,%eax
f0101c6b:	0f 84 25 09 00 00    	je     f0102596 <mem_init+0x129d>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101c71:	83 ec 08             	sub    $0x8,%esp
f0101c74:	6a 00                	push   $0x0
f0101c76:	ff 35 8c 4e 23 f0    	pushl  0xf0234e8c
f0101c7c:	e8 65 f5 ff ff       	call   f01011e6 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101c81:	8b 3d 8c 4e 23 f0    	mov    0xf0234e8c,%edi
f0101c87:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c8c:	89 f8                	mov    %edi,%eax
f0101c8e:	e8 3e ee ff ff       	call   f0100ad1 <check_va2pa>
f0101c93:	83 c4 10             	add    $0x10,%esp
f0101c96:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101c99:	0f 85 10 09 00 00    	jne    f01025af <mem_init+0x12b6>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101c9f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ca4:	89 f8                	mov    %edi,%eax
f0101ca6:	e8 26 ee ff ff       	call   f0100ad1 <check_va2pa>
f0101cab:	89 da                	mov    %ebx,%edx
f0101cad:	2b 15 90 4e 23 f0    	sub    0xf0234e90,%edx
f0101cb3:	c1 fa 03             	sar    $0x3,%edx
f0101cb6:	c1 e2 0c             	shl    $0xc,%edx
f0101cb9:	39 d0                	cmp    %edx,%eax
f0101cbb:	0f 85 07 09 00 00    	jne    f01025c8 <mem_init+0x12cf>
	assert(pp1->pp_ref == 1);
f0101cc1:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101cc6:	0f 85 15 09 00 00    	jne    f01025e1 <mem_init+0x12e8>
	assert(pp2->pp_ref == 0);
f0101ccc:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101cd1:	0f 85 23 09 00 00    	jne    f01025fa <mem_init+0x1301>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101cd7:	6a 00                	push   $0x0
f0101cd9:	68 00 10 00 00       	push   $0x1000
f0101cde:	53                   	push   %ebx
f0101cdf:	57                   	push   %edi
f0101ce0:	e8 49 f5 ff ff       	call   f010122e <page_insert>
f0101ce5:	83 c4 10             	add    $0x10,%esp
f0101ce8:	85 c0                	test   %eax,%eax
f0101cea:	0f 85 23 09 00 00    	jne    f0102613 <mem_init+0x131a>
	assert(pp1->pp_ref);
f0101cf0:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101cf5:	0f 84 31 09 00 00    	je     f010262c <mem_init+0x1333>
	assert(pp1->pp_link == NULL);
f0101cfb:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101cfe:	0f 85 41 09 00 00    	jne    f0102645 <mem_init+0x134c>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101d04:	83 ec 08             	sub    $0x8,%esp
f0101d07:	68 00 10 00 00       	push   $0x1000
f0101d0c:	ff 35 8c 4e 23 f0    	pushl  0xf0234e8c
f0101d12:	e8 cf f4 ff ff       	call   f01011e6 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101d17:	8b 3d 8c 4e 23 f0    	mov    0xf0234e8c,%edi
f0101d1d:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d22:	89 f8                	mov    %edi,%eax
f0101d24:	e8 a8 ed ff ff       	call   f0100ad1 <check_va2pa>
f0101d29:	83 c4 10             	add    $0x10,%esp
f0101d2c:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d2f:	0f 85 29 09 00 00    	jne    f010265e <mem_init+0x1365>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101d35:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d3a:	89 f8                	mov    %edi,%eax
f0101d3c:	e8 90 ed ff ff       	call   f0100ad1 <check_va2pa>
f0101d41:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d44:	0f 85 2d 09 00 00    	jne    f0102677 <mem_init+0x137e>
	assert(pp1->pp_ref == 0);
f0101d4a:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101d4f:	0f 85 3b 09 00 00    	jne    f0102690 <mem_init+0x1397>
	assert(pp2->pp_ref == 0);
f0101d55:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101d5a:	0f 85 49 09 00 00    	jne    f01026a9 <mem_init+0x13b0>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101d60:	83 ec 0c             	sub    $0xc,%esp
f0101d63:	6a 00                	push   $0x0
f0101d65:	e8 a7 f1 ff ff       	call   f0100f11 <page_alloc>
f0101d6a:	83 c4 10             	add    $0x10,%esp
f0101d6d:	85 c0                	test   %eax,%eax
f0101d6f:	0f 84 4d 09 00 00    	je     f01026c2 <mem_init+0x13c9>
f0101d75:	39 c3                	cmp    %eax,%ebx
f0101d77:	0f 85 45 09 00 00    	jne    f01026c2 <mem_init+0x13c9>

	// should be no free memory
	assert(!page_alloc(0));
f0101d7d:	83 ec 0c             	sub    $0xc,%esp
f0101d80:	6a 00                	push   $0x0
f0101d82:	e8 8a f1 ff ff       	call   f0100f11 <page_alloc>
f0101d87:	83 c4 10             	add    $0x10,%esp
f0101d8a:	85 c0                	test   %eax,%eax
f0101d8c:	0f 85 49 09 00 00    	jne    f01026db <mem_init+0x13e2>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101d92:	8b 0d 8c 4e 23 f0    	mov    0xf0234e8c,%ecx
f0101d98:	8b 11                	mov    (%ecx),%edx
f0101d9a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101da0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101da3:	2b 05 90 4e 23 f0    	sub    0xf0234e90,%eax
f0101da9:	c1 f8 03             	sar    $0x3,%eax
f0101dac:	c1 e0 0c             	shl    $0xc,%eax
f0101daf:	39 c2                	cmp    %eax,%edx
f0101db1:	0f 85 3d 09 00 00    	jne    f01026f4 <mem_init+0x13fb>
	kern_pgdir[0] = 0;
f0101db7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101dbd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101dc0:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101dc5:	0f 85 42 09 00 00    	jne    f010270d <mem_init+0x1414>
	pp0->pp_ref = 0;
f0101dcb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101dce:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101dd4:	83 ec 0c             	sub    $0xc,%esp
f0101dd7:	50                   	push   %eax
f0101dd8:	e8 a6 f1 ff ff       	call   f0100f83 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101ddd:	83 c4 0c             	add    $0xc,%esp
f0101de0:	6a 01                	push   $0x1
f0101de2:	68 00 10 40 00       	push   $0x401000
f0101de7:	ff 35 8c 4e 23 f0    	pushl  0xf0234e8c
f0101ded:	e8 f5 f1 ff ff       	call   f0100fe7 <pgdir_walk>
f0101df2:	89 c7                	mov    %eax,%edi
f0101df4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101df7:	a1 8c 4e 23 f0       	mov    0xf0234e8c,%eax
f0101dfc:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101dff:	8b 40 04             	mov    0x4(%eax),%eax
f0101e02:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101e07:	8b 0d 88 4e 23 f0    	mov    0xf0234e88,%ecx
f0101e0d:	89 c2                	mov    %eax,%edx
f0101e0f:	c1 ea 0c             	shr    $0xc,%edx
f0101e12:	83 c4 10             	add    $0x10,%esp
f0101e15:	39 ca                	cmp    %ecx,%edx
f0101e17:	0f 83 09 09 00 00    	jae    f0102726 <mem_init+0x142d>
	assert(ptep == ptep1 + PTX(va));
f0101e1d:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0101e22:	39 c7                	cmp    %eax,%edi
f0101e24:	0f 85 11 09 00 00    	jne    f010273b <mem_init+0x1442>
	kern_pgdir[PDX(va)] = 0;
f0101e2a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101e2d:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0101e34:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e37:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101e3d:	2b 05 90 4e 23 f0    	sub    0xf0234e90,%eax
f0101e43:	c1 f8 03             	sar    $0x3,%eax
f0101e46:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101e49:	89 c2                	mov    %eax,%edx
f0101e4b:	c1 ea 0c             	shr    $0xc,%edx
f0101e4e:	39 d1                	cmp    %edx,%ecx
f0101e50:	0f 86 fe 08 00 00    	jbe    f0102754 <mem_init+0x145b>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101e56:	83 ec 04             	sub    $0x4,%esp
f0101e59:	68 00 10 00 00       	push   $0x1000
f0101e5e:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0101e63:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101e68:	50                   	push   %eax
f0101e69:	e8 99 3a 00 00       	call   f0105907 <memset>
	page_free(pp0);
f0101e6e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101e71:	89 3c 24             	mov    %edi,(%esp)
f0101e74:	e8 0a f1 ff ff       	call   f0100f83 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101e79:	83 c4 0c             	add    $0xc,%esp
f0101e7c:	6a 01                	push   $0x1
f0101e7e:	6a 00                	push   $0x0
f0101e80:	ff 35 8c 4e 23 f0    	pushl  0xf0234e8c
f0101e86:	e8 5c f1 ff ff       	call   f0100fe7 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0101e8b:	89 fa                	mov    %edi,%edx
f0101e8d:	2b 15 90 4e 23 f0    	sub    0xf0234e90,%edx
f0101e93:	c1 fa 03             	sar    $0x3,%edx
f0101e96:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101e99:	89 d0                	mov    %edx,%eax
f0101e9b:	c1 e8 0c             	shr    $0xc,%eax
f0101e9e:	83 c4 10             	add    $0x10,%esp
f0101ea1:	3b 05 88 4e 23 f0    	cmp    0xf0234e88,%eax
f0101ea7:	0f 83 b9 08 00 00    	jae    f0102766 <mem_init+0x146d>
	return (void *)(pa + KERNBASE);
f0101ead:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0101eb3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101eb6:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0101ebc:	f6 00 01             	testb  $0x1,(%eax)
f0101ebf:	0f 85 b3 08 00 00    	jne    f0102778 <mem_init+0x147f>
f0101ec5:	83 c0 04             	add    $0x4,%eax
	for(i=0; i<NPTENTRIES; i++)
f0101ec8:	39 d0                	cmp    %edx,%eax
f0101eca:	75 f0                	jne    f0101ebc <mem_init+0xbc3>
	kern_pgdir[0] = 0;
f0101ecc:	a1 8c 4e 23 f0       	mov    0xf0234e8c,%eax
f0101ed1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0101ed7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101eda:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0101ee0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0101ee3:	89 0d 40 42 23 f0    	mov    %ecx,0xf0234240

	// free the pages we took
	page_free(pp0);
f0101ee9:	83 ec 0c             	sub    $0xc,%esp
f0101eec:	50                   	push   %eax
f0101eed:	e8 91 f0 ff ff       	call   f0100f83 <page_free>
	page_free(pp1);
f0101ef2:	89 1c 24             	mov    %ebx,(%esp)
f0101ef5:	e8 89 f0 ff ff       	call   f0100f83 <page_free>
	page_free(pp2);
f0101efa:	89 34 24             	mov    %esi,(%esp)
f0101efd:	e8 81 f0 ff ff       	call   f0100f83 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0101f02:	83 c4 08             	add    $0x8,%esp
f0101f05:	68 01 10 00 00       	push   $0x1001
f0101f0a:	6a 00                	push   $0x0
f0101f0c:	e8 85 f3 ff ff       	call   f0101296 <mmio_map_region>
f0101f11:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0101f13:	83 c4 08             	add    $0x8,%esp
f0101f16:	68 00 10 00 00       	push   $0x1000
f0101f1b:	6a 00                	push   $0x0
f0101f1d:	e8 74 f3 ff ff       	call   f0101296 <mmio_map_region>
f0101f22:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f0101f24:	8d 83 00 20 00 00    	lea    0x2000(%ebx),%eax
f0101f2a:	83 c4 10             	add    $0x10,%esp
f0101f2d:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0101f33:	0f 86 58 08 00 00    	jbe    f0102791 <mem_init+0x1498>
f0101f39:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0101f3e:	0f 87 4d 08 00 00    	ja     f0102791 <mem_init+0x1498>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f0101f44:	8d 96 00 20 00 00    	lea    0x2000(%esi),%edx
f0101f4a:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0101f50:	0f 87 54 08 00 00    	ja     f01027aa <mem_init+0x14b1>
f0101f56:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0101f5c:	0f 86 48 08 00 00    	jbe    f01027aa <mem_init+0x14b1>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0101f62:	89 da                	mov    %ebx,%edx
f0101f64:	09 f2                	or     %esi,%edx
f0101f66:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0101f6c:	0f 85 51 08 00 00    	jne    f01027c3 <mem_init+0x14ca>
	// check that they don't overlap
	assert(mm1 + 8192 <= mm2);
f0101f72:	39 c6                	cmp    %eax,%esi
f0101f74:	0f 82 62 08 00 00    	jb     f01027dc <mem_init+0x14e3>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0101f7a:	8b 3d 8c 4e 23 f0    	mov    0xf0234e8c,%edi
f0101f80:	89 da                	mov    %ebx,%edx
f0101f82:	89 f8                	mov    %edi,%eax
f0101f84:	e8 48 eb ff ff       	call   f0100ad1 <check_va2pa>
f0101f89:	85 c0                	test   %eax,%eax
f0101f8b:	0f 85 64 08 00 00    	jne    f01027f5 <mem_init+0x14fc>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0101f91:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0101f97:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101f9a:	89 c2                	mov    %eax,%edx
f0101f9c:	89 f8                	mov    %edi,%eax
f0101f9e:	e8 2e eb ff ff       	call   f0100ad1 <check_va2pa>
f0101fa3:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0101fa8:	0f 85 60 08 00 00    	jne    f010280e <mem_init+0x1515>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0101fae:	89 f2                	mov    %esi,%edx
f0101fb0:	89 f8                	mov    %edi,%eax
f0101fb2:	e8 1a eb ff ff       	call   f0100ad1 <check_va2pa>
f0101fb7:	85 c0                	test   %eax,%eax
f0101fb9:	0f 85 68 08 00 00    	jne    f0102827 <mem_init+0x152e>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0101fbf:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0101fc5:	89 f8                	mov    %edi,%eax
f0101fc7:	e8 05 eb ff ff       	call   f0100ad1 <check_va2pa>
f0101fcc:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101fcf:	0f 85 6b 08 00 00    	jne    f0102840 <mem_init+0x1547>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0101fd5:	83 ec 04             	sub    $0x4,%esp
f0101fd8:	6a 00                	push   $0x0
f0101fda:	53                   	push   %ebx
f0101fdb:	57                   	push   %edi
f0101fdc:	e8 06 f0 ff ff       	call   f0100fe7 <pgdir_walk>
f0101fe1:	83 c4 10             	add    $0x10,%esp
f0101fe4:	f6 00 1a             	testb  $0x1a,(%eax)
f0101fe7:	0f 84 6c 08 00 00    	je     f0102859 <mem_init+0x1560>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0101fed:	83 ec 04             	sub    $0x4,%esp
f0101ff0:	6a 00                	push   $0x0
f0101ff2:	53                   	push   %ebx
f0101ff3:	ff 35 8c 4e 23 f0    	pushl  0xf0234e8c
f0101ff9:	e8 e9 ef ff ff       	call   f0100fe7 <pgdir_walk>
f0101ffe:	83 c4 10             	add    $0x10,%esp
f0102001:	f6 00 04             	testb  $0x4,(%eax)
f0102004:	0f 85 68 08 00 00    	jne    f0102872 <mem_init+0x1579>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f010200a:	83 ec 04             	sub    $0x4,%esp
f010200d:	6a 00                	push   $0x0
f010200f:	53                   	push   %ebx
f0102010:	ff 35 8c 4e 23 f0    	pushl  0xf0234e8c
f0102016:	e8 cc ef ff ff       	call   f0100fe7 <pgdir_walk>
f010201b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102021:	83 c4 0c             	add    $0xc,%esp
f0102024:	6a 00                	push   $0x0
f0102026:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102029:	ff 35 8c 4e 23 f0    	pushl  0xf0234e8c
f010202f:	e8 b3 ef ff ff       	call   f0100fe7 <pgdir_walk>
f0102034:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f010203a:	83 c4 0c             	add    $0xc,%esp
f010203d:	6a 00                	push   $0x0
f010203f:	56                   	push   %esi
f0102040:	ff 35 8c 4e 23 f0    	pushl  0xf0234e8c
f0102046:	e8 9c ef ff ff       	call   f0100fe7 <pgdir_walk>
f010204b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102051:	c7 04 24 44 77 10 f0 	movl   $0xf0107744,(%esp)
f0102058:	e8 e7 18 00 00       	call   f0103944 <cprintf>
        boot_map_region(kern_pgdir,UPAGES,PTSIZE,PADDR(pages),PTE_U|PTE_P);
f010205d:	a1 90 4e 23 f0       	mov    0xf0234e90,%eax
	if ((uint32_t)kva < KERNBASE)
f0102062:	83 c4 10             	add    $0x10,%esp
f0102065:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010206a:	0f 86 1b 08 00 00    	jbe    f010288b <mem_init+0x1592>
f0102070:	83 ec 08             	sub    $0x8,%esp
f0102073:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f0102075:	05 00 00 00 10       	add    $0x10000000,%eax
f010207a:	50                   	push   %eax
f010207b:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102080:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102085:	a1 8c 4e 23 f0       	mov    0xf0234e8c,%eax
f010208a:	e8 43 f0 ff ff       	call   f01010d2 <boot_map_region>
         boot_map_region(kern_pgdir,UENVS,PTSIZE,PADDR(envs),PTE_U|PTE_P);
f010208f:	a1 44 42 23 f0       	mov    0xf0234244,%eax
	if ((uint32_t)kva < KERNBASE)
f0102094:	83 c4 10             	add    $0x10,%esp
f0102097:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010209c:	0f 86 fe 07 00 00    	jbe    f01028a0 <mem_init+0x15a7>
f01020a2:	83 ec 08             	sub    $0x8,%esp
f01020a5:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f01020a7:	05 00 00 00 10       	add    $0x10000000,%eax
f01020ac:	50                   	push   %eax
f01020ad:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01020b2:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01020b7:	a1 8c 4e 23 f0       	mov    0xf0234e8c,%eax
f01020bc:	e8 11 f0 ff ff       	call   f01010d2 <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f01020c1:	83 c4 10             	add    $0x10,%esp
f01020c4:	b8 00 80 11 f0       	mov    $0xf0118000,%eax
f01020c9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01020ce:	0f 86 e1 07 00 00    	jbe    f01028b5 <mem_init+0x15bc>
        boot_map_region(kern_pgdir,KSTACKTOP-KSTKSIZE,KSTKSIZE,PADDR(bootstack),PTE_W|PTE_P);
f01020d4:	83 ec 08             	sub    $0x8,%esp
f01020d7:	6a 03                	push   $0x3
f01020d9:	68 00 80 11 00       	push   $0x118000
f01020de:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01020e3:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01020e8:	a1 8c 4e 23 f0       	mov    0xf0234e8c,%eax
f01020ed:	e8 e0 ef ff ff       	call   f01010d2 <boot_map_region>
        boot_map_region(kern_pgdir,KERNBASE,0xffffffff-KERNBASE,0,PTE_W|PTE_P);
f01020f2:	83 c4 08             	add    $0x8,%esp
f01020f5:	6a 03                	push   $0x3
f01020f7:	6a 00                	push   $0x0
f01020f9:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f01020fe:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102103:	a1 8c 4e 23 f0       	mov    0xf0234e8c,%eax
f0102108:	e8 c5 ef ff ff       	call   f01010d2 <boot_map_region>
f010210d:	c7 45 cc 00 60 23 f0 	movl   $0xf0236000,-0x34(%ebp)
f0102114:	bf 00 60 27 f0       	mov    $0xf0276000,%edi
f0102119:	83 c4 10             	add    $0x10,%esp
f010211c:	bb 00 60 23 f0       	mov    $0xf0236000,%ebx
f0102121:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102126:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f010212c:	0f 86 98 07 00 00    	jbe    f01028ca <mem_init+0x15d1>
	  boot_map_region(kern_pgdir,kstacktop_i-KSTKSIZE,KSTKSIZE,PADDR(&percpu_kstacks[i]),PTE_W);
f0102132:	83 ec 08             	sub    $0x8,%esp
f0102135:	6a 02                	push   $0x2
f0102137:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f010213d:	50                   	push   %eax
f010213e:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102143:	89 f2                	mov    %esi,%edx
f0102145:	a1 8c 4e 23 f0       	mov    0xf0234e8c,%eax
f010214a:	e8 83 ef ff ff       	call   f01010d2 <boot_map_region>
f010214f:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102155:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	for(i=0;i<NCPU;i++){
f010215b:	83 c4 10             	add    $0x10,%esp
f010215e:	39 fb                	cmp    %edi,%ebx
f0102160:	75 c4                	jne    f0102126 <mem_init+0xe2d>
	pgdir = kern_pgdir;
f0102162:	8b 3d 8c 4e 23 f0    	mov    0xf0234e8c,%edi
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102168:	a1 88 4e 23 f0       	mov    0xf0234e88,%eax
f010216d:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102170:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102177:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010217c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010217f:	a1 90 4e 23 f0       	mov    0xf0234e90,%eax
f0102184:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0102187:	89 45 d0             	mov    %eax,-0x30(%ebp)
	return (physaddr_t)kva - KERNBASE;
f010218a:	8d b0 00 00 00 10    	lea    0x10000000(%eax),%esi
	for (i = 0; i < n; i += PGSIZE)
f0102190:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102195:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0102198:	0f 86 71 07 00 00    	jbe    f010290f <mem_init+0x1616>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010219e:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f01021a4:	89 f8                	mov    %edi,%eax
f01021a6:	e8 26 e9 ff ff       	call   f0100ad1 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f01021ab:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f01021b2:	0f 86 27 07 00 00    	jbe    f01028df <mem_init+0x15e6>
f01021b8:	8d 14 33             	lea    (%ebx,%esi,1),%edx
f01021bb:	39 d0                	cmp    %edx,%eax
f01021bd:	0f 85 33 07 00 00    	jne    f01028f6 <mem_init+0x15fd>
	for (i = 0; i < n; i += PGSIZE)
f01021c3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01021c9:	eb ca                	jmp    f0102195 <mem_init+0xe9c>
	assert(nfree == 0);
f01021cb:	68 5b 76 10 f0       	push   $0xf010765b
f01021d0:	68 6f 74 10 f0       	push   $0xf010746f
f01021d5:	68 33 03 00 00       	push   $0x333
f01021da:	68 49 74 10 f0       	push   $0xf0107449
f01021df:	e8 5c de ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f01021e4:	68 69 75 10 f0       	push   $0xf0107569
f01021e9:	68 6f 74 10 f0       	push   $0xf010746f
f01021ee:	68 99 03 00 00       	push   $0x399
f01021f3:	68 49 74 10 f0       	push   $0xf0107449
f01021f8:	e8 43 de ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01021fd:	68 7f 75 10 f0       	push   $0xf010757f
f0102202:	68 6f 74 10 f0       	push   $0xf010746f
f0102207:	68 9a 03 00 00       	push   $0x39a
f010220c:	68 49 74 10 f0       	push   $0xf0107449
f0102211:	e8 2a de ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102216:	68 95 75 10 f0       	push   $0xf0107595
f010221b:	68 6f 74 10 f0       	push   $0xf010746f
f0102220:	68 9b 03 00 00       	push   $0x39b
f0102225:	68 49 74 10 f0       	push   $0xf0107449
f010222a:	e8 11 de ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f010222f:	68 ab 75 10 f0       	push   $0xf01075ab
f0102234:	68 6f 74 10 f0       	push   $0xf010746f
f0102239:	68 9e 03 00 00       	push   $0x39e
f010223e:	68 49 74 10 f0       	push   $0xf0107449
f0102243:	e8 f8 dd ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102248:	68 6c 6c 10 f0       	push   $0xf0106c6c
f010224d:	68 6f 74 10 f0       	push   $0xf010746f
f0102252:	68 9f 03 00 00       	push   $0x39f
f0102257:	68 49 74 10 f0       	push   $0xf0107449
f010225c:	e8 df dd ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0102261:	68 14 76 10 f0       	push   $0xf0107614
f0102266:	68 6f 74 10 f0       	push   $0xf010746f
f010226b:	68 a6 03 00 00       	push   $0x3a6
f0102270:	68 49 74 10 f0       	push   $0xf0107449
f0102275:	e8 c6 dd ff ff       	call   f0100040 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010227a:	68 ac 6c 10 f0       	push   $0xf0106cac
f010227f:	68 6f 74 10 f0       	push   $0xf010746f
f0102284:	68 a9 03 00 00       	push   $0x3a9
f0102289:	68 49 74 10 f0       	push   $0xf0107449
f010228e:	e8 ad dd ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102293:	68 e4 6c 10 f0       	push   $0xf0106ce4
f0102298:	68 6f 74 10 f0       	push   $0xf010746f
f010229d:	68 ac 03 00 00       	push   $0x3ac
f01022a2:	68 49 74 10 f0       	push   $0xf0107449
f01022a7:	e8 94 dd ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01022ac:	68 14 6d 10 f0       	push   $0xf0106d14
f01022b1:	68 6f 74 10 f0       	push   $0xf010746f
f01022b6:	68 b0 03 00 00       	push   $0x3b0
f01022bb:	68 49 74 10 f0       	push   $0xf0107449
f01022c0:	e8 7b dd ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01022c5:	68 44 6d 10 f0       	push   $0xf0106d44
f01022ca:	68 6f 74 10 f0       	push   $0xf010746f
f01022cf:	68 b1 03 00 00       	push   $0x3b1
f01022d4:	68 49 74 10 f0       	push   $0xf0107449
f01022d9:	e8 62 dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01022de:	68 6c 6d 10 f0       	push   $0xf0106d6c
f01022e3:	68 6f 74 10 f0       	push   $0xf010746f
f01022e8:	68 b2 03 00 00       	push   $0x3b2
f01022ed:	68 49 74 10 f0       	push   $0xf0107449
f01022f2:	e8 49 dd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01022f7:	68 66 76 10 f0       	push   $0xf0107666
f01022fc:	68 6f 74 10 f0       	push   $0xf010746f
f0102301:	68 b3 03 00 00       	push   $0x3b3
f0102306:	68 49 74 10 f0       	push   $0xf0107449
f010230b:	e8 30 dd ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0102310:	68 77 76 10 f0       	push   $0xf0107677
f0102315:	68 6f 74 10 f0       	push   $0xf010746f
f010231a:	68 b4 03 00 00       	push   $0x3b4
f010231f:	68 49 74 10 f0       	push   $0xf0107449
f0102324:	e8 17 dd ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102329:	68 9c 6d 10 f0       	push   $0xf0106d9c
f010232e:	68 6f 74 10 f0       	push   $0xf010746f
f0102333:	68 b7 03 00 00       	push   $0x3b7
f0102338:	68 49 74 10 f0       	push   $0xf0107449
f010233d:	e8 fe dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102342:	68 d8 6d 10 f0       	push   $0xf0106dd8
f0102347:	68 6f 74 10 f0       	push   $0xf010746f
f010234c:	68 b8 03 00 00       	push   $0x3b8
f0102351:	68 49 74 10 f0       	push   $0xf0107449
f0102356:	e8 e5 dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010235b:	68 88 76 10 f0       	push   $0xf0107688
f0102360:	68 6f 74 10 f0       	push   $0xf010746f
f0102365:	68 b9 03 00 00       	push   $0x3b9
f010236a:	68 49 74 10 f0       	push   $0xf0107449
f010236f:	e8 cc dc ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0102374:	68 14 76 10 f0       	push   $0xf0107614
f0102379:	68 6f 74 10 f0       	push   $0xf010746f
f010237e:	68 bc 03 00 00       	push   $0x3bc
f0102383:	68 49 74 10 f0       	push   $0xf0107449
f0102388:	e8 b3 dc ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010238d:	68 9c 6d 10 f0       	push   $0xf0106d9c
f0102392:	68 6f 74 10 f0       	push   $0xf010746f
f0102397:	68 bf 03 00 00       	push   $0x3bf
f010239c:	68 49 74 10 f0       	push   $0xf0107449
f01023a1:	e8 9a dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01023a6:	68 d8 6d 10 f0       	push   $0xf0106dd8
f01023ab:	68 6f 74 10 f0       	push   $0xf010746f
f01023b0:	68 c0 03 00 00       	push   $0x3c0
f01023b5:	68 49 74 10 f0       	push   $0xf0107449
f01023ba:	e8 81 dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01023bf:	68 88 76 10 f0       	push   $0xf0107688
f01023c4:	68 6f 74 10 f0       	push   $0xf010746f
f01023c9:	68 c1 03 00 00       	push   $0x3c1
f01023ce:	68 49 74 10 f0       	push   $0xf0107449
f01023d3:	e8 68 dc ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01023d8:	68 14 76 10 f0       	push   $0xf0107614
f01023dd:	68 6f 74 10 f0       	push   $0xf010746f
f01023e2:	68 c5 03 00 00       	push   $0x3c5
f01023e7:	68 49 74 10 f0       	push   $0xf0107449
f01023ec:	e8 4f dc ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01023f1:	50                   	push   %eax
f01023f2:	68 84 65 10 f0       	push   $0xf0106584
f01023f7:	68 c8 03 00 00       	push   $0x3c8
f01023fc:	68 49 74 10 f0       	push   $0xf0107449
f0102401:	e8 3a dc ff ff       	call   f0100040 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0102406:	68 08 6e 10 f0       	push   $0xf0106e08
f010240b:	68 6f 74 10 f0       	push   $0xf010746f
f0102410:	68 c9 03 00 00       	push   $0x3c9
f0102415:	68 49 74 10 f0       	push   $0xf0107449
f010241a:	e8 21 dc ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f010241f:	68 48 6e 10 f0       	push   $0xf0106e48
f0102424:	68 6f 74 10 f0       	push   $0xf010746f
f0102429:	68 cc 03 00 00       	push   $0x3cc
f010242e:	68 49 74 10 f0       	push   $0xf0107449
f0102433:	e8 08 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102438:	68 d8 6d 10 f0       	push   $0xf0106dd8
f010243d:	68 6f 74 10 f0       	push   $0xf010746f
f0102442:	68 cd 03 00 00       	push   $0x3cd
f0102447:	68 49 74 10 f0       	push   $0xf0107449
f010244c:	e8 ef db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102451:	68 88 76 10 f0       	push   $0xf0107688
f0102456:	68 6f 74 10 f0       	push   $0xf010746f
f010245b:	68 ce 03 00 00       	push   $0x3ce
f0102460:	68 49 74 10 f0       	push   $0xf0107449
f0102465:	e8 d6 db ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f010246a:	68 88 6e 10 f0       	push   $0xf0106e88
f010246f:	68 6f 74 10 f0       	push   $0xf010746f
f0102474:	68 cf 03 00 00       	push   $0x3cf
f0102479:	68 49 74 10 f0       	push   $0xf0107449
f010247e:	e8 bd db ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102483:	68 99 76 10 f0       	push   $0xf0107699
f0102488:	68 6f 74 10 f0       	push   $0xf010746f
f010248d:	68 d0 03 00 00       	push   $0x3d0
f0102492:	68 49 74 10 f0       	push   $0xf0107449
f0102497:	e8 a4 db ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010249c:	68 9c 6d 10 f0       	push   $0xf0106d9c
f01024a1:	68 6f 74 10 f0       	push   $0xf010746f
f01024a6:	68 d3 03 00 00       	push   $0x3d3
f01024ab:	68 49 74 10 f0       	push   $0xf0107449
f01024b0:	e8 8b db ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01024b5:	68 bc 6e 10 f0       	push   $0xf0106ebc
f01024ba:	68 6f 74 10 f0       	push   $0xf010746f
f01024bf:	68 d4 03 00 00       	push   $0x3d4
f01024c4:	68 49 74 10 f0       	push   $0xf0107449
f01024c9:	e8 72 db ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01024ce:	68 f0 6e 10 f0       	push   $0xf0106ef0
f01024d3:	68 6f 74 10 f0       	push   $0xf010746f
f01024d8:	68 d5 03 00 00       	push   $0x3d5
f01024dd:	68 49 74 10 f0       	push   $0xf0107449
f01024e2:	e8 59 db ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01024e7:	68 28 6f 10 f0       	push   $0xf0106f28
f01024ec:	68 6f 74 10 f0       	push   $0xf010746f
f01024f1:	68 d8 03 00 00       	push   $0x3d8
f01024f6:	68 49 74 10 f0       	push   $0xf0107449
f01024fb:	e8 40 db ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102500:	68 60 6f 10 f0       	push   $0xf0106f60
f0102505:	68 6f 74 10 f0       	push   $0xf010746f
f010250a:	68 db 03 00 00       	push   $0x3db
f010250f:	68 49 74 10 f0       	push   $0xf0107449
f0102514:	e8 27 db ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102519:	68 f0 6e 10 f0       	push   $0xf0106ef0
f010251e:	68 6f 74 10 f0       	push   $0xf010746f
f0102523:	68 dc 03 00 00       	push   $0x3dc
f0102528:	68 49 74 10 f0       	push   $0xf0107449
f010252d:	e8 0e db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102532:	68 9c 6f 10 f0       	push   $0xf0106f9c
f0102537:	68 6f 74 10 f0       	push   $0xf010746f
f010253c:	68 df 03 00 00       	push   $0x3df
f0102541:	68 49 74 10 f0       	push   $0xf0107449
f0102546:	e8 f5 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010254b:	68 c8 6f 10 f0       	push   $0xf0106fc8
f0102550:	68 6f 74 10 f0       	push   $0xf010746f
f0102555:	68 e0 03 00 00       	push   $0x3e0
f010255a:	68 49 74 10 f0       	push   $0xf0107449
f010255f:	e8 dc da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 2);
f0102564:	68 af 76 10 f0       	push   $0xf01076af
f0102569:	68 6f 74 10 f0       	push   $0xf010746f
f010256e:	68 e2 03 00 00       	push   $0x3e2
f0102573:	68 49 74 10 f0       	push   $0xf0107449
f0102578:	e8 c3 da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010257d:	68 c0 76 10 f0       	push   $0xf01076c0
f0102582:	68 6f 74 10 f0       	push   $0xf010746f
f0102587:	68 e3 03 00 00       	push   $0x3e3
f010258c:	68 49 74 10 f0       	push   $0xf0107449
f0102591:	e8 aa da ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f0102596:	68 f8 6f 10 f0       	push   $0xf0106ff8
f010259b:	68 6f 74 10 f0       	push   $0xf010746f
f01025a0:	68 e6 03 00 00       	push   $0x3e6
f01025a5:	68 49 74 10 f0       	push   $0xf0107449
f01025aa:	e8 91 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01025af:	68 1c 70 10 f0       	push   $0xf010701c
f01025b4:	68 6f 74 10 f0       	push   $0xf010746f
f01025b9:	68 ea 03 00 00       	push   $0x3ea
f01025be:	68 49 74 10 f0       	push   $0xf0107449
f01025c3:	e8 78 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01025c8:	68 c8 6f 10 f0       	push   $0xf0106fc8
f01025cd:	68 6f 74 10 f0       	push   $0xf010746f
f01025d2:	68 eb 03 00 00       	push   $0x3eb
f01025d7:	68 49 74 10 f0       	push   $0xf0107449
f01025dc:	e8 5f da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01025e1:	68 66 76 10 f0       	push   $0xf0107666
f01025e6:	68 6f 74 10 f0       	push   $0xf010746f
f01025eb:	68 ec 03 00 00       	push   $0x3ec
f01025f0:	68 49 74 10 f0       	push   $0xf0107449
f01025f5:	e8 46 da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01025fa:	68 c0 76 10 f0       	push   $0xf01076c0
f01025ff:	68 6f 74 10 f0       	push   $0xf010746f
f0102604:	68 ed 03 00 00       	push   $0x3ed
f0102609:	68 49 74 10 f0       	push   $0xf0107449
f010260e:	e8 2d da ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102613:	68 40 70 10 f0       	push   $0xf0107040
f0102618:	68 6f 74 10 f0       	push   $0xf010746f
f010261d:	68 f0 03 00 00       	push   $0x3f0
f0102622:	68 49 74 10 f0       	push   $0xf0107449
f0102627:	e8 14 da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f010262c:	68 d1 76 10 f0       	push   $0xf01076d1
f0102631:	68 6f 74 10 f0       	push   $0xf010746f
f0102636:	68 f1 03 00 00       	push   $0x3f1
f010263b:	68 49 74 10 f0       	push   $0xf0107449
f0102640:	e8 fb d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f0102645:	68 dd 76 10 f0       	push   $0xf01076dd
f010264a:	68 6f 74 10 f0       	push   $0xf010746f
f010264f:	68 f2 03 00 00       	push   $0x3f2
f0102654:	68 49 74 10 f0       	push   $0xf0107449
f0102659:	e8 e2 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010265e:	68 1c 70 10 f0       	push   $0xf010701c
f0102663:	68 6f 74 10 f0       	push   $0xf010746f
f0102668:	68 f6 03 00 00       	push   $0x3f6
f010266d:	68 49 74 10 f0       	push   $0xf0107449
f0102672:	e8 c9 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102677:	68 78 70 10 f0       	push   $0xf0107078
f010267c:	68 6f 74 10 f0       	push   $0xf010746f
f0102681:	68 f7 03 00 00       	push   $0x3f7
f0102686:	68 49 74 10 f0       	push   $0xf0107449
f010268b:	e8 b0 d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102690:	68 f2 76 10 f0       	push   $0xf01076f2
f0102695:	68 6f 74 10 f0       	push   $0xf010746f
f010269a:	68 f8 03 00 00       	push   $0x3f8
f010269f:	68 49 74 10 f0       	push   $0xf0107449
f01026a4:	e8 97 d9 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01026a9:	68 c0 76 10 f0       	push   $0xf01076c0
f01026ae:	68 6f 74 10 f0       	push   $0xf010746f
f01026b3:	68 f9 03 00 00       	push   $0x3f9
f01026b8:	68 49 74 10 f0       	push   $0xf0107449
f01026bd:	e8 7e d9 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f01026c2:	68 a0 70 10 f0       	push   $0xf01070a0
f01026c7:	68 6f 74 10 f0       	push   $0xf010746f
f01026cc:	68 fc 03 00 00       	push   $0x3fc
f01026d1:	68 49 74 10 f0       	push   $0xf0107449
f01026d6:	e8 65 d9 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01026db:	68 14 76 10 f0       	push   $0xf0107614
f01026e0:	68 6f 74 10 f0       	push   $0xf010746f
f01026e5:	68 ff 03 00 00       	push   $0x3ff
f01026ea:	68 49 74 10 f0       	push   $0xf0107449
f01026ef:	e8 4c d9 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01026f4:	68 44 6d 10 f0       	push   $0xf0106d44
f01026f9:	68 6f 74 10 f0       	push   $0xf010746f
f01026fe:	68 02 04 00 00       	push   $0x402
f0102703:	68 49 74 10 f0       	push   $0xf0107449
f0102708:	e8 33 d9 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f010270d:	68 77 76 10 f0       	push   $0xf0107677
f0102712:	68 6f 74 10 f0       	push   $0xf010746f
f0102717:	68 04 04 00 00       	push   $0x404
f010271c:	68 49 74 10 f0       	push   $0xf0107449
f0102721:	e8 1a d9 ff ff       	call   f0100040 <_panic>
f0102726:	50                   	push   %eax
f0102727:	68 84 65 10 f0       	push   $0xf0106584
f010272c:	68 0b 04 00 00       	push   $0x40b
f0102731:	68 49 74 10 f0       	push   $0xf0107449
f0102736:	e8 05 d9 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f010273b:	68 03 77 10 f0       	push   $0xf0107703
f0102740:	68 6f 74 10 f0       	push   $0xf010746f
f0102745:	68 0c 04 00 00       	push   $0x40c
f010274a:	68 49 74 10 f0       	push   $0xf0107449
f010274f:	e8 ec d8 ff ff       	call   f0100040 <_panic>
f0102754:	50                   	push   %eax
f0102755:	68 84 65 10 f0       	push   $0xf0106584
f010275a:	6a 58                	push   $0x58
f010275c:	68 55 74 10 f0       	push   $0xf0107455
f0102761:	e8 da d8 ff ff       	call   f0100040 <_panic>
f0102766:	52                   	push   %edx
f0102767:	68 84 65 10 f0       	push   $0xf0106584
f010276c:	6a 58                	push   $0x58
f010276e:	68 55 74 10 f0       	push   $0xf0107455
f0102773:	e8 c8 d8 ff ff       	call   f0100040 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f0102778:	68 1b 77 10 f0       	push   $0xf010771b
f010277d:	68 6f 74 10 f0       	push   $0xf010746f
f0102782:	68 16 04 00 00       	push   $0x416
f0102787:	68 49 74 10 f0       	push   $0xf0107449
f010278c:	e8 af d8 ff ff       	call   f0100040 <_panic>
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f0102791:	68 c4 70 10 f0       	push   $0xf01070c4
f0102796:	68 6f 74 10 f0       	push   $0xf010746f
f010279b:	68 26 04 00 00       	push   $0x426
f01027a0:	68 49 74 10 f0       	push   $0xf0107449
f01027a5:	e8 96 d8 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f01027aa:	68 ec 70 10 f0       	push   $0xf01070ec
f01027af:	68 6f 74 10 f0       	push   $0xf010746f
f01027b4:	68 27 04 00 00       	push   $0x427
f01027b9:	68 49 74 10 f0       	push   $0xf0107449
f01027be:	e8 7d d8 ff ff       	call   f0100040 <_panic>
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f01027c3:	68 14 71 10 f0       	push   $0xf0107114
f01027c8:	68 6f 74 10 f0       	push   $0xf010746f
f01027cd:	68 29 04 00 00       	push   $0x429
f01027d2:	68 49 74 10 f0       	push   $0xf0107449
f01027d7:	e8 64 d8 ff ff       	call   f0100040 <_panic>
	assert(mm1 + 8192 <= mm2);
f01027dc:	68 32 77 10 f0       	push   $0xf0107732
f01027e1:	68 6f 74 10 f0       	push   $0xf010746f
f01027e6:	68 2b 04 00 00       	push   $0x42b
f01027eb:	68 49 74 10 f0       	push   $0xf0107449
f01027f0:	e8 4b d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01027f5:	68 3c 71 10 f0       	push   $0xf010713c
f01027fa:	68 6f 74 10 f0       	push   $0xf010746f
f01027ff:	68 2d 04 00 00       	push   $0x42d
f0102804:	68 49 74 10 f0       	push   $0xf0107449
f0102809:	e8 32 d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f010280e:	68 60 71 10 f0       	push   $0xf0107160
f0102813:	68 6f 74 10 f0       	push   $0xf010746f
f0102818:	68 2e 04 00 00       	push   $0x42e
f010281d:	68 49 74 10 f0       	push   $0xf0107449
f0102822:	e8 19 d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102827:	68 90 71 10 f0       	push   $0xf0107190
f010282c:	68 6f 74 10 f0       	push   $0xf010746f
f0102831:	68 2f 04 00 00       	push   $0x42f
f0102836:	68 49 74 10 f0       	push   $0xf0107449
f010283b:	e8 00 d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102840:	68 b4 71 10 f0       	push   $0xf01071b4
f0102845:	68 6f 74 10 f0       	push   $0xf010746f
f010284a:	68 30 04 00 00       	push   $0x430
f010284f:	68 49 74 10 f0       	push   $0xf0107449
f0102854:	e8 e7 d7 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102859:	68 e0 71 10 f0       	push   $0xf01071e0
f010285e:	68 6f 74 10 f0       	push   $0xf010746f
f0102863:	68 32 04 00 00       	push   $0x432
f0102868:	68 49 74 10 f0       	push   $0xf0107449
f010286d:	e8 ce d7 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102872:	68 24 72 10 f0       	push   $0xf0107224
f0102877:	68 6f 74 10 f0       	push   $0xf010746f
f010287c:	68 33 04 00 00       	push   $0x433
f0102881:	68 49 74 10 f0       	push   $0xf0107449
f0102886:	e8 b5 d7 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010288b:	50                   	push   %eax
f010288c:	68 a8 65 10 f0       	push   $0xf01065a8
f0102891:	68 b9 00 00 00       	push   $0xb9
f0102896:	68 49 74 10 f0       	push   $0xf0107449
f010289b:	e8 a0 d7 ff ff       	call   f0100040 <_panic>
f01028a0:	50                   	push   %eax
f01028a1:	68 a8 65 10 f0       	push   $0xf01065a8
f01028a6:	68 c1 00 00 00       	push   $0xc1
f01028ab:	68 49 74 10 f0       	push   $0xf0107449
f01028b0:	e8 8b d7 ff ff       	call   f0100040 <_panic>
f01028b5:	50                   	push   %eax
f01028b6:	68 a8 65 10 f0       	push   $0xf01065a8
f01028bb:	68 cd 00 00 00       	push   $0xcd
f01028c0:	68 49 74 10 f0       	push   $0xf0107449
f01028c5:	e8 76 d7 ff ff       	call   f0100040 <_panic>
f01028ca:	53                   	push   %ebx
f01028cb:	68 a8 65 10 f0       	push   $0xf01065a8
f01028d0:	68 0f 01 00 00       	push   $0x10f
f01028d5:	68 49 74 10 f0       	push   $0xf0107449
f01028da:	e8 61 d7 ff ff       	call   f0100040 <_panic>
f01028df:	ff 75 c4             	pushl  -0x3c(%ebp)
f01028e2:	68 a8 65 10 f0       	push   $0xf01065a8
f01028e7:	68 4b 03 00 00       	push   $0x34b
f01028ec:	68 49 74 10 f0       	push   $0xf0107449
f01028f1:	e8 4a d7 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01028f6:	68 58 72 10 f0       	push   $0xf0107258
f01028fb:	68 6f 74 10 f0       	push   $0xf010746f
f0102900:	68 4b 03 00 00       	push   $0x34b
f0102905:	68 49 74 10 f0       	push   $0xf0107449
f010290a:	e8 31 d7 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010290f:	a1 44 42 23 f0       	mov    0xf0234244,%eax
f0102914:	89 45 d0             	mov    %eax,-0x30(%ebp)
	if ((uint32_t)kva < KERNBASE)
f0102917:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010291a:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f010291f:	8d b0 00 00 40 21    	lea    0x21400000(%eax),%esi
f0102925:	89 da                	mov    %ebx,%edx
f0102927:	89 f8                	mov    %edi,%eax
f0102929:	e8 a3 e1 ff ff       	call   f0100ad1 <check_va2pa>
f010292e:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102935:	76 22                	jbe    f0102959 <mem_init+0x1660>
f0102937:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f010293a:	39 d0                	cmp    %edx,%eax
f010293c:	75 32                	jne    f0102970 <mem_init+0x1677>
f010293e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
f0102944:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f010294a:	75 d9                	jne    f0102925 <mem_init+0x162c>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010294c:	8b 75 c8             	mov    -0x38(%ebp),%esi
f010294f:	c1 e6 0c             	shl    $0xc,%esi
f0102952:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102957:	eb 4b                	jmp    f01029a4 <mem_init+0x16ab>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102959:	ff 75 d0             	pushl  -0x30(%ebp)
f010295c:	68 a8 65 10 f0       	push   $0xf01065a8
f0102961:	68 50 03 00 00       	push   $0x350
f0102966:	68 49 74 10 f0       	push   $0xf0107449
f010296b:	e8 d0 d6 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102970:	68 8c 72 10 f0       	push   $0xf010728c
f0102975:	68 6f 74 10 f0       	push   $0xf010746f
f010297a:	68 50 03 00 00       	push   $0x350
f010297f:	68 49 74 10 f0       	push   $0xf0107449
f0102984:	e8 b7 d6 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102989:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f010298f:	89 f8                	mov    %edi,%eax
f0102991:	e8 3b e1 ff ff       	call   f0100ad1 <check_va2pa>
f0102996:	39 c3                	cmp    %eax,%ebx
f0102998:	0f 85 f9 00 00 00    	jne    f0102a97 <mem_init+0x179e>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010299e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01029a4:	39 f3                	cmp    %esi,%ebx
f01029a6:	72 e1                	jb     f0102989 <mem_init+0x1690>
f01029a8:	c7 45 d4 00 60 23 f0 	movl   $0xf0236000,-0x2c(%ebp)
f01029af:	be 00 80 ff ef       	mov    $0xefff8000,%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f01029b4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01029b7:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f01029ba:	8d 86 00 80 00 00    	lea    0x8000(%esi),%eax
f01029c0:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01029c3:	89 f3                	mov    %esi,%ebx
f01029c5:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01029c8:	05 00 80 00 20       	add    $0x20008000,%eax
f01029cd:	89 75 c8             	mov    %esi,-0x38(%ebp)
f01029d0:	89 c6                	mov    %eax,%esi
f01029d2:	89 da                	mov    %ebx,%edx
f01029d4:	89 f8                	mov    %edi,%eax
f01029d6:	e8 f6 e0 ff ff       	call   f0100ad1 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f01029db:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f01029e2:	0f 86 c8 00 00 00    	jbe    f0102ab0 <mem_init+0x17b7>
f01029e8:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f01029eb:	39 d0                	cmp    %edx,%eax
f01029ed:	0f 85 d4 00 00 00    	jne    f0102ac7 <mem_init+0x17ce>
f01029f3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01029f9:	3b 5d d0             	cmp    -0x30(%ebp),%ebx
f01029fc:	75 d4                	jne    f01029d2 <mem_init+0x16d9>
f01029fe:	8b 75 c8             	mov    -0x38(%ebp),%esi
f0102a01:	8d 9e 00 80 ff ff    	lea    -0x8000(%esi),%ebx
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102a07:	89 da                	mov    %ebx,%edx
f0102a09:	89 f8                	mov    %edi,%eax
f0102a0b:	e8 c1 e0 ff ff       	call   f0100ad1 <check_va2pa>
f0102a10:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a13:	0f 85 c7 00 00 00    	jne    f0102ae0 <mem_init+0x17e7>
f0102a19:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102a1f:	39 f3                	cmp    %esi,%ebx
f0102a21:	75 e4                	jne    f0102a07 <mem_init+0x170e>
f0102a23:	81 ee 00 00 01 00    	sub    $0x10000,%esi
f0102a29:	81 45 cc 00 80 01 00 	addl   $0x18000,-0x34(%ebp)
f0102a30:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102a33:	81 45 d4 00 80 00 00 	addl   $0x8000,-0x2c(%ebp)
	for (n = 0; n < NCPU; n++) {
f0102a3a:	3d 00 60 2f f0       	cmp    $0xf02f6000,%eax
f0102a3f:	0f 85 6f ff ff ff    	jne    f01029b4 <mem_init+0x16bb>
	for (i = 0; i < NPDENTRIES; i++) {
f0102a45:	b8 00 00 00 00       	mov    $0x0,%eax
			if (i >= PDX(KERNBASE)) {
f0102a4a:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102a4f:	0f 87 a4 00 00 00    	ja     f0102af9 <mem_init+0x1800>
				assert(pgdir[i] == 0);
f0102a55:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102a59:	0f 85 dd 00 00 00    	jne    f0102b3c <mem_init+0x1843>
	for (i = 0; i < NPDENTRIES; i++) {
f0102a5f:	83 c0 01             	add    $0x1,%eax
f0102a62:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102a67:	0f 87 e8 00 00 00    	ja     f0102b55 <mem_init+0x185c>
		switch (i) {
f0102a6d:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102a73:	83 fa 04             	cmp    $0x4,%edx
f0102a76:	77 d2                	ja     f0102a4a <mem_init+0x1751>
			assert(pgdir[i] & PTE_P);
f0102a78:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102a7c:	75 e1                	jne    f0102a5f <mem_init+0x1766>
f0102a7e:	68 5d 77 10 f0       	push   $0xf010775d
f0102a83:	68 6f 74 10 f0       	push   $0xf010746f
f0102a88:	68 69 03 00 00       	push   $0x369
f0102a8d:	68 49 74 10 f0       	push   $0xf0107449
f0102a92:	e8 a9 d5 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102a97:	68 c0 72 10 f0       	push   $0xf01072c0
f0102a9c:	68 6f 74 10 f0       	push   $0xf010746f
f0102aa1:	68 54 03 00 00       	push   $0x354
f0102aa6:	68 49 74 10 f0       	push   $0xf0107449
f0102aab:	e8 90 d5 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ab0:	ff 75 c4             	pushl  -0x3c(%ebp)
f0102ab3:	68 a8 65 10 f0       	push   $0xf01065a8
f0102ab8:	68 5c 03 00 00       	push   $0x35c
f0102abd:	68 49 74 10 f0       	push   $0xf0107449
f0102ac2:	e8 79 d5 ff ff       	call   f0100040 <_panic>
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102ac7:	68 e8 72 10 f0       	push   $0xf01072e8
f0102acc:	68 6f 74 10 f0       	push   $0xf010746f
f0102ad1:	68 5c 03 00 00       	push   $0x35c
f0102ad6:	68 49 74 10 f0       	push   $0xf0107449
f0102adb:	e8 60 d5 ff ff       	call   f0100040 <_panic>
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102ae0:	68 30 73 10 f0       	push   $0xf0107330
f0102ae5:	68 6f 74 10 f0       	push   $0xf010746f
f0102aea:	68 5e 03 00 00       	push   $0x35e
f0102aef:	68 49 74 10 f0       	push   $0xf0107449
f0102af4:	e8 47 d5 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_P);
f0102af9:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0102afc:	f6 c2 01             	test   $0x1,%dl
f0102aff:	74 22                	je     f0102b23 <mem_init+0x182a>
				assert(pgdir[i] & PTE_W);
f0102b01:	f6 c2 02             	test   $0x2,%dl
f0102b04:	0f 85 55 ff ff ff    	jne    f0102a5f <mem_init+0x1766>
f0102b0a:	68 6e 77 10 f0       	push   $0xf010776e
f0102b0f:	68 6f 74 10 f0       	push   $0xf010746f
f0102b14:	68 6e 03 00 00       	push   $0x36e
f0102b19:	68 49 74 10 f0       	push   $0xf0107449
f0102b1e:	e8 1d d5 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_P);
f0102b23:	68 5d 77 10 f0       	push   $0xf010775d
f0102b28:	68 6f 74 10 f0       	push   $0xf010746f
f0102b2d:	68 6d 03 00 00       	push   $0x36d
f0102b32:	68 49 74 10 f0       	push   $0xf0107449
f0102b37:	e8 04 d5 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] == 0);
f0102b3c:	68 7f 77 10 f0       	push   $0xf010777f
f0102b41:	68 6f 74 10 f0       	push   $0xf010746f
f0102b46:	68 70 03 00 00       	push   $0x370
f0102b4b:	68 49 74 10 f0       	push   $0xf0107449
f0102b50:	e8 eb d4 ff ff       	call   f0100040 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102b55:	83 ec 0c             	sub    $0xc,%esp
f0102b58:	68 54 73 10 f0       	push   $0xf0107354
f0102b5d:	e8 e2 0d 00 00       	call   f0103944 <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102b62:	a1 8c 4e 23 f0       	mov    0xf0234e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0102b67:	83 c4 10             	add    $0x10,%esp
f0102b6a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b6f:	0f 86 fe 01 00 00    	jbe    f0102d73 <mem_init+0x1a7a>
	return (physaddr_t)kva - KERNBASE;
f0102b75:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102b7a:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102b7d:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b82:	e8 ae df ff ff       	call   f0100b35 <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102b87:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102b8a:	83 e0 f3             	and    $0xfffffff3,%eax
f0102b8d:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102b92:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102b95:	83 ec 0c             	sub    $0xc,%esp
f0102b98:	6a 00                	push   $0x0
f0102b9a:	e8 72 e3 ff ff       	call   f0100f11 <page_alloc>
f0102b9f:	89 c3                	mov    %eax,%ebx
f0102ba1:	83 c4 10             	add    $0x10,%esp
f0102ba4:	85 c0                	test   %eax,%eax
f0102ba6:	0f 84 dc 01 00 00    	je     f0102d88 <mem_init+0x1a8f>
	assert((pp1 = page_alloc(0)));
f0102bac:	83 ec 0c             	sub    $0xc,%esp
f0102baf:	6a 00                	push   $0x0
f0102bb1:	e8 5b e3 ff ff       	call   f0100f11 <page_alloc>
f0102bb6:	89 c7                	mov    %eax,%edi
f0102bb8:	83 c4 10             	add    $0x10,%esp
f0102bbb:	85 c0                	test   %eax,%eax
f0102bbd:	0f 84 de 01 00 00    	je     f0102da1 <mem_init+0x1aa8>
	assert((pp2 = page_alloc(0)));
f0102bc3:	83 ec 0c             	sub    $0xc,%esp
f0102bc6:	6a 00                	push   $0x0
f0102bc8:	e8 44 e3 ff ff       	call   f0100f11 <page_alloc>
f0102bcd:	89 c6                	mov    %eax,%esi
f0102bcf:	83 c4 10             	add    $0x10,%esp
f0102bd2:	85 c0                	test   %eax,%eax
f0102bd4:	0f 84 e0 01 00 00    	je     f0102dba <mem_init+0x1ac1>
	page_free(pp0);
f0102bda:	83 ec 0c             	sub    $0xc,%esp
f0102bdd:	53                   	push   %ebx
f0102bde:	e8 a0 e3 ff ff       	call   f0100f83 <page_free>
	return (pp - pages) << PGSHIFT;
f0102be3:	89 f8                	mov    %edi,%eax
f0102be5:	2b 05 90 4e 23 f0    	sub    0xf0234e90,%eax
f0102beb:	c1 f8 03             	sar    $0x3,%eax
f0102bee:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102bf1:	89 c2                	mov    %eax,%edx
f0102bf3:	c1 ea 0c             	shr    $0xc,%edx
f0102bf6:	83 c4 10             	add    $0x10,%esp
f0102bf9:	3b 15 88 4e 23 f0    	cmp    0xf0234e88,%edx
f0102bff:	0f 83 ce 01 00 00    	jae    f0102dd3 <mem_init+0x1ada>
	memset(page2kva(pp1), 1, PGSIZE);
f0102c05:	83 ec 04             	sub    $0x4,%esp
f0102c08:	68 00 10 00 00       	push   $0x1000
f0102c0d:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102c0f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c14:	50                   	push   %eax
f0102c15:	e8 ed 2c 00 00       	call   f0105907 <memset>
	return (pp - pages) << PGSHIFT;
f0102c1a:	89 f0                	mov    %esi,%eax
f0102c1c:	2b 05 90 4e 23 f0    	sub    0xf0234e90,%eax
f0102c22:	c1 f8 03             	sar    $0x3,%eax
f0102c25:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102c28:	89 c2                	mov    %eax,%edx
f0102c2a:	c1 ea 0c             	shr    $0xc,%edx
f0102c2d:	83 c4 10             	add    $0x10,%esp
f0102c30:	3b 15 88 4e 23 f0    	cmp    0xf0234e88,%edx
f0102c36:	0f 83 a9 01 00 00    	jae    f0102de5 <mem_init+0x1aec>
	memset(page2kva(pp2), 2, PGSIZE);
f0102c3c:	83 ec 04             	sub    $0x4,%esp
f0102c3f:	68 00 10 00 00       	push   $0x1000
f0102c44:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102c46:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c4b:	50                   	push   %eax
f0102c4c:	e8 b6 2c 00 00       	call   f0105907 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102c51:	6a 02                	push   $0x2
f0102c53:	68 00 10 00 00       	push   $0x1000
f0102c58:	57                   	push   %edi
f0102c59:	ff 35 8c 4e 23 f0    	pushl  0xf0234e8c
f0102c5f:	e8 ca e5 ff ff       	call   f010122e <page_insert>
	assert(pp1->pp_ref == 1);
f0102c64:	83 c4 20             	add    $0x20,%esp
f0102c67:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102c6c:	0f 85 85 01 00 00    	jne    f0102df7 <mem_init+0x1afe>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102c72:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102c79:	01 01 01 
f0102c7c:	0f 85 8e 01 00 00    	jne    f0102e10 <mem_init+0x1b17>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102c82:	6a 02                	push   $0x2
f0102c84:	68 00 10 00 00       	push   $0x1000
f0102c89:	56                   	push   %esi
f0102c8a:	ff 35 8c 4e 23 f0    	pushl  0xf0234e8c
f0102c90:	e8 99 e5 ff ff       	call   f010122e <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102c95:	83 c4 10             	add    $0x10,%esp
f0102c98:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102c9f:	02 02 02 
f0102ca2:	0f 85 81 01 00 00    	jne    f0102e29 <mem_init+0x1b30>
	assert(pp2->pp_ref == 1);
f0102ca8:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102cad:	0f 85 8f 01 00 00    	jne    f0102e42 <mem_init+0x1b49>
	assert(pp1->pp_ref == 0);
f0102cb3:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102cb8:	0f 85 9d 01 00 00    	jne    f0102e5b <mem_init+0x1b62>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102cbe:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102cc5:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0102cc8:	89 f0                	mov    %esi,%eax
f0102cca:	2b 05 90 4e 23 f0    	sub    0xf0234e90,%eax
f0102cd0:	c1 f8 03             	sar    $0x3,%eax
f0102cd3:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102cd6:	89 c2                	mov    %eax,%edx
f0102cd8:	c1 ea 0c             	shr    $0xc,%edx
f0102cdb:	3b 15 88 4e 23 f0    	cmp    0xf0234e88,%edx
f0102ce1:	0f 83 8d 01 00 00    	jae    f0102e74 <mem_init+0x1b7b>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102ce7:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102cee:	03 03 03 
f0102cf1:	0f 85 8f 01 00 00    	jne    f0102e86 <mem_init+0x1b8d>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102cf7:	83 ec 08             	sub    $0x8,%esp
f0102cfa:	68 00 10 00 00       	push   $0x1000
f0102cff:	ff 35 8c 4e 23 f0    	pushl  0xf0234e8c
f0102d05:	e8 dc e4 ff ff       	call   f01011e6 <page_remove>
	assert(pp2->pp_ref == 0);
f0102d0a:	83 c4 10             	add    $0x10,%esp
f0102d0d:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102d12:	0f 85 87 01 00 00    	jne    f0102e9f <mem_init+0x1ba6>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102d18:	8b 0d 8c 4e 23 f0    	mov    0xf0234e8c,%ecx
f0102d1e:	8b 11                	mov    (%ecx),%edx
f0102d20:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0102d26:	89 d8                	mov    %ebx,%eax
f0102d28:	2b 05 90 4e 23 f0    	sub    0xf0234e90,%eax
f0102d2e:	c1 f8 03             	sar    $0x3,%eax
f0102d31:	c1 e0 0c             	shl    $0xc,%eax
f0102d34:	39 c2                	cmp    %eax,%edx
f0102d36:	0f 85 7c 01 00 00    	jne    f0102eb8 <mem_init+0x1bbf>
	kern_pgdir[0] = 0;
f0102d3c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102d42:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102d47:	0f 85 84 01 00 00    	jne    f0102ed1 <mem_init+0x1bd8>
	pp0->pp_ref = 0;
f0102d4d:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102d53:	83 ec 0c             	sub    $0xc,%esp
f0102d56:	53                   	push   %ebx
f0102d57:	e8 27 e2 ff ff       	call   f0100f83 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102d5c:	c7 04 24 e8 73 10 f0 	movl   $0xf01073e8,(%esp)
f0102d63:	e8 dc 0b 00 00       	call   f0103944 <cprintf>
}
f0102d68:	83 c4 10             	add    $0x10,%esp
f0102d6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102d6e:	5b                   	pop    %ebx
f0102d6f:	5e                   	pop    %esi
f0102d70:	5f                   	pop    %edi
f0102d71:	5d                   	pop    %ebp
f0102d72:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d73:	50                   	push   %eax
f0102d74:	68 a8 65 10 f0       	push   $0xf01065a8
f0102d79:	68 e4 00 00 00       	push   $0xe4
f0102d7e:	68 49 74 10 f0       	push   $0xf0107449
f0102d83:	e8 b8 d2 ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f0102d88:	68 69 75 10 f0       	push   $0xf0107569
f0102d8d:	68 6f 74 10 f0       	push   $0xf010746f
f0102d92:	68 48 04 00 00       	push   $0x448
f0102d97:	68 49 74 10 f0       	push   $0xf0107449
f0102d9c:	e8 9f d2 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102da1:	68 7f 75 10 f0       	push   $0xf010757f
f0102da6:	68 6f 74 10 f0       	push   $0xf010746f
f0102dab:	68 49 04 00 00       	push   $0x449
f0102db0:	68 49 74 10 f0       	push   $0xf0107449
f0102db5:	e8 86 d2 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102dba:	68 95 75 10 f0       	push   $0xf0107595
f0102dbf:	68 6f 74 10 f0       	push   $0xf010746f
f0102dc4:	68 4a 04 00 00       	push   $0x44a
f0102dc9:	68 49 74 10 f0       	push   $0xf0107449
f0102dce:	e8 6d d2 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102dd3:	50                   	push   %eax
f0102dd4:	68 84 65 10 f0       	push   $0xf0106584
f0102dd9:	6a 58                	push   $0x58
f0102ddb:	68 55 74 10 f0       	push   $0xf0107455
f0102de0:	e8 5b d2 ff ff       	call   f0100040 <_panic>
f0102de5:	50                   	push   %eax
f0102de6:	68 84 65 10 f0       	push   $0xf0106584
f0102deb:	6a 58                	push   $0x58
f0102ded:	68 55 74 10 f0       	push   $0xf0107455
f0102df2:	e8 49 d2 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102df7:	68 66 76 10 f0       	push   $0xf0107666
f0102dfc:	68 6f 74 10 f0       	push   $0xf010746f
f0102e01:	68 4f 04 00 00       	push   $0x44f
f0102e06:	68 49 74 10 f0       	push   $0xf0107449
f0102e0b:	e8 30 d2 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102e10:	68 74 73 10 f0       	push   $0xf0107374
f0102e15:	68 6f 74 10 f0       	push   $0xf010746f
f0102e1a:	68 50 04 00 00       	push   $0x450
f0102e1f:	68 49 74 10 f0       	push   $0xf0107449
f0102e24:	e8 17 d2 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102e29:	68 98 73 10 f0       	push   $0xf0107398
f0102e2e:	68 6f 74 10 f0       	push   $0xf010746f
f0102e33:	68 52 04 00 00       	push   $0x452
f0102e38:	68 49 74 10 f0       	push   $0xf0107449
f0102e3d:	e8 fe d1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102e42:	68 88 76 10 f0       	push   $0xf0107688
f0102e47:	68 6f 74 10 f0       	push   $0xf010746f
f0102e4c:	68 53 04 00 00       	push   $0x453
f0102e51:	68 49 74 10 f0       	push   $0xf0107449
f0102e56:	e8 e5 d1 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102e5b:	68 f2 76 10 f0       	push   $0xf01076f2
f0102e60:	68 6f 74 10 f0       	push   $0xf010746f
f0102e65:	68 54 04 00 00       	push   $0x454
f0102e6a:	68 49 74 10 f0       	push   $0xf0107449
f0102e6f:	e8 cc d1 ff ff       	call   f0100040 <_panic>
f0102e74:	50                   	push   %eax
f0102e75:	68 84 65 10 f0       	push   $0xf0106584
f0102e7a:	6a 58                	push   $0x58
f0102e7c:	68 55 74 10 f0       	push   $0xf0107455
f0102e81:	e8 ba d1 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102e86:	68 bc 73 10 f0       	push   $0xf01073bc
f0102e8b:	68 6f 74 10 f0       	push   $0xf010746f
f0102e90:	68 56 04 00 00       	push   $0x456
f0102e95:	68 49 74 10 f0       	push   $0xf0107449
f0102e9a:	e8 a1 d1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102e9f:	68 c0 76 10 f0       	push   $0xf01076c0
f0102ea4:	68 6f 74 10 f0       	push   $0xf010746f
f0102ea9:	68 58 04 00 00       	push   $0x458
f0102eae:	68 49 74 10 f0       	push   $0xf0107449
f0102eb3:	e8 88 d1 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102eb8:	68 44 6d 10 f0       	push   $0xf0106d44
f0102ebd:	68 6f 74 10 f0       	push   $0xf010746f
f0102ec2:	68 5b 04 00 00       	push   $0x45b
f0102ec7:	68 49 74 10 f0       	push   $0xf0107449
f0102ecc:	e8 6f d1 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0102ed1:	68 77 76 10 f0       	push   $0xf0107677
f0102ed6:	68 6f 74 10 f0       	push   $0xf010746f
f0102edb:	68 5d 04 00 00       	push   $0x45d
f0102ee0:	68 49 74 10 f0       	push   $0xf0107449
f0102ee5:	e8 56 d1 ff ff       	call   f0100040 <_panic>

f0102eea <user_mem_check>:
{
f0102eea:	55                   	push   %ebp
f0102eeb:	89 e5                	mov    %esp,%ebp
f0102eed:	57                   	push   %edi
f0102eee:	56                   	push   %esi
f0102eef:	53                   	push   %ebx
f0102ef0:	83 ec 1c             	sub    $0x1c,%esp
        uintptr_t start = ROUNDDOWN((uintptr_t)va,PGSIZE);
f0102ef3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102ef6:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0102efc:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	uintptr_t end = ROUNDUP((uintptr_t)va+len,PGSIZE);
f0102eff:	8b 45 10             	mov    0x10(%ebp),%eax
f0102f02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102f05:	8d bc 01 ff 0f 00 00 	lea    0xfff(%ecx,%eax,1),%edi
f0102f0c:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	  if(cur_va>ULIM || cur_pte==NULL || (*cur_pte&(perm|PTE_P))!=(perm|PTE_P)){
f0102f12:	8b 75 14             	mov    0x14(%ebp),%esi
f0102f15:	83 ce 01             	or     $0x1,%esi
	for(uintptr_t cur_va =start; cur_va < end;cur_va+=PGSIZE){
f0102f18:	39 fb                	cmp    %edi,%ebx
f0102f1a:	73 57                	jae    f0102f73 <user_mem_check+0x89>
	  cur_pte = pgdir_walk(env->env_pgdir,(void *)cur_va,0);
f0102f1c:	83 ec 04             	sub    $0x4,%esp
f0102f1f:	6a 00                	push   $0x0
f0102f21:	53                   	push   %ebx
f0102f22:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f25:	ff 70 60             	pushl  0x60(%eax)
f0102f28:	e8 ba e0 ff ff       	call   f0100fe7 <pgdir_walk>
	  if(cur_va>ULIM || cur_pte==NULL || (*cur_pte&(perm|PTE_P))!=(perm|PTE_P)){
f0102f2d:	83 c4 10             	add    $0x10,%esp
f0102f30:	81 fb 00 00 80 ef    	cmp    $0xef800000,%ebx
f0102f36:	77 14                	ja     f0102f4c <user_mem_check+0x62>
f0102f38:	85 c0                	test   %eax,%eax
f0102f3a:	74 10                	je     f0102f4c <user_mem_check+0x62>
f0102f3c:	89 f2                	mov    %esi,%edx
f0102f3e:	23 10                	and    (%eax),%edx
f0102f40:	39 d6                	cmp    %edx,%esi
f0102f42:	75 08                	jne    f0102f4c <user_mem_check+0x62>
	for(uintptr_t cur_va =start; cur_va < end;cur_va+=PGSIZE){
f0102f44:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102f4a:	eb cc                	jmp    f0102f18 <user_mem_check+0x2e>
	   if(cur_va==start)
f0102f4c:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102f4f:	74 13                	je     f0102f64 <user_mem_check+0x7a>
		 user_mem_check_addr = (uintptr_t)cur_va;
f0102f51:	89 1d 3c 42 23 f0    	mov    %ebx,0xf023423c
	    return -E_FAULT;  
f0102f57:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
}
f0102f5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f5f:	5b                   	pop    %ebx
f0102f60:	5e                   	pop    %esi
f0102f61:	5f                   	pop    %edi
f0102f62:	5d                   	pop    %ebp
f0102f63:	c3                   	ret    
		 user_mem_check_addr = (uintptr_t)va;
f0102f64:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f67:	a3 3c 42 23 f0       	mov    %eax,0xf023423c
	    return -E_FAULT;  
f0102f6c:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102f71:	eb e9                	jmp    f0102f5c <user_mem_check+0x72>
	return 0;
f0102f73:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f78:	eb e2                	jmp    f0102f5c <user_mem_check+0x72>

f0102f7a <user_mem_assert>:
{
f0102f7a:	55                   	push   %ebp
f0102f7b:	89 e5                	mov    %esp,%ebp
f0102f7d:	53                   	push   %ebx
f0102f7e:	83 ec 04             	sub    $0x4,%esp
f0102f81:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102f84:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f87:	83 c8 04             	or     $0x4,%eax
f0102f8a:	50                   	push   %eax
f0102f8b:	ff 75 10             	pushl  0x10(%ebp)
f0102f8e:	ff 75 0c             	pushl  0xc(%ebp)
f0102f91:	53                   	push   %ebx
f0102f92:	e8 53 ff ff ff       	call   f0102eea <user_mem_check>
f0102f97:	83 c4 10             	add    $0x10,%esp
f0102f9a:	85 c0                	test   %eax,%eax
f0102f9c:	78 05                	js     f0102fa3 <user_mem_assert+0x29>
}
f0102f9e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102fa1:	c9                   	leave  
f0102fa2:	c3                   	ret    
		cprintf("[%08x] user_mem_check assertion failure for "
f0102fa3:	83 ec 04             	sub    $0x4,%esp
f0102fa6:	ff 35 3c 42 23 f0    	pushl  0xf023423c
f0102fac:	ff 73 48             	pushl  0x48(%ebx)
f0102faf:	68 14 74 10 f0       	push   $0xf0107414
f0102fb4:	e8 8b 09 00 00       	call   f0103944 <cprintf>
		env_destroy(env);	// may not return
f0102fb9:	89 1c 24             	mov    %ebx,(%esp)
f0102fbc:	e8 87 06 00 00       	call   f0103648 <env_destroy>
f0102fc1:	83 c4 10             	add    $0x10,%esp
}
f0102fc4:	eb d8                	jmp    f0102f9e <user_mem_assert+0x24>

f0102fc6 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102fc6:	55                   	push   %ebp
f0102fc7:	89 e5                	mov    %esp,%ebp
f0102fc9:	57                   	push   %edi
f0102fca:	56                   	push   %esi
f0102fcb:	53                   	push   %ebx
f0102fcc:	83 ec 0c             	sub    $0xc,%esp
f0102fcf:	89 c7                	mov    %eax,%edi
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
        struct PageInfo *pp;
	uint32_t start = ROUNDDOWN((uint32_t)va,PGSIZE);
	uint32_t end = ROUNDUP((uint32_t)va+len,PGSIZE);
f0102fd1:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0102fd8:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	uint32_t start = ROUNDDOWN((uint32_t)va,PGSIZE);
f0102fde:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102fe4:	89 d3                	mov    %edx,%ebx
	int i;
	for(i=start;i<end;i+=PGSIZE){
f0102fe6:	39 f3                	cmp    %esi,%ebx
f0102fe8:	73 5a                	jae    f0103044 <region_alloc+0x7e>
	  pp = (struct PageInfo *)page_alloc(0);
f0102fea:	83 ec 0c             	sub    $0xc,%esp
f0102fed:	6a 00                	push   $0x0
f0102fef:	e8 1d df ff ff       	call   f0100f11 <page_alloc>
	 if(!pp){
f0102ff4:	83 c4 10             	add    $0x10,%esp
f0102ff7:	85 c0                	test   %eax,%eax
f0102ff9:	74 1b                	je     f0103016 <region_alloc+0x50>
	  panic("region_alloc failed!\n");
	 }
	 if(page_insert(e->env_pgdir,pp,(void*)i,PTE_W|PTE_U)!=0)
f0102ffb:	6a 06                	push   $0x6
f0102ffd:	53                   	push   %ebx
f0102ffe:	50                   	push   %eax
f0102fff:	ff 77 60             	pushl  0x60(%edi)
f0103002:	e8 27 e2 ff ff       	call   f010122e <page_insert>
f0103007:	83 c4 10             	add    $0x10,%esp
f010300a:	85 c0                	test   %eax,%eax
f010300c:	75 1f                	jne    f010302d <region_alloc+0x67>
	for(i=start;i<end;i+=PGSIZE){
f010300e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103014:	eb d0                	jmp    f0102fe6 <region_alloc+0x20>
	  panic("region_alloc failed!\n");
f0103016:	83 ec 04             	sub    $0x4,%esp
f0103019:	68 8d 77 10 f0       	push   $0xf010778d
f010301e:	68 30 01 00 00       	push   $0x130
f0103023:	68 a3 77 10 f0       	push   $0xf01077a3
f0103028:	e8 13 d0 ff ff       	call   f0100040 <_panic>
		panic("region alloc error\n"); 
f010302d:	83 ec 04             	sub    $0x4,%esp
f0103030:	68 ae 77 10 f0       	push   $0xf01077ae
f0103035:	68 33 01 00 00       	push   $0x133
f010303a:	68 a3 77 10 f0       	push   $0xf01077a3
f010303f:	e8 fc cf ff ff       	call   f0100040 <_panic>
	}
}
f0103044:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103047:	5b                   	pop    %ebx
f0103048:	5e                   	pop    %esi
f0103049:	5f                   	pop    %edi
f010304a:	5d                   	pop    %ebp
f010304b:	c3                   	ret    

f010304c <envid2env>:
{
f010304c:	55                   	push   %ebp
f010304d:	89 e5                	mov    %esp,%ebp
f010304f:	56                   	push   %esi
f0103050:	53                   	push   %ebx
f0103051:	8b 45 08             	mov    0x8(%ebp),%eax
f0103054:	8b 55 10             	mov    0x10(%ebp),%edx
	if (envid == 0) {
f0103057:	85 c0                	test   %eax,%eax
f0103059:	74 2e                	je     f0103089 <envid2env+0x3d>
	e = &envs[ENVX(envid)];
f010305b:	89 c3                	mov    %eax,%ebx
f010305d:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0103063:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0103066:	03 1d 44 42 23 f0    	add    0xf0234244,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f010306c:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0103070:	74 31                	je     f01030a3 <envid2env+0x57>
f0103072:	39 43 48             	cmp    %eax,0x48(%ebx)
f0103075:	75 2c                	jne    f01030a3 <envid2env+0x57>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103077:	84 d2                	test   %dl,%dl
f0103079:	75 38                	jne    f01030b3 <envid2env+0x67>
	*env_store = e;
f010307b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010307e:	89 18                	mov    %ebx,(%eax)
	return 0;
f0103080:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103085:	5b                   	pop    %ebx
f0103086:	5e                   	pop    %esi
f0103087:	5d                   	pop    %ebp
f0103088:	c3                   	ret    
		*env_store = curenv;
f0103089:	e8 9d 2e 00 00       	call   f0105f2b <cpunum>
f010308e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103091:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f0103097:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010309a:	89 01                	mov    %eax,(%ecx)
		return 0;
f010309c:	b8 00 00 00 00       	mov    $0x0,%eax
f01030a1:	eb e2                	jmp    f0103085 <envid2env+0x39>
		*env_store = 0;
f01030a3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01030a6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01030ac:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01030b1:	eb d2                	jmp    f0103085 <envid2env+0x39>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01030b3:	e8 73 2e 00 00       	call   f0105f2b <cpunum>
f01030b8:	6b c0 74             	imul   $0x74,%eax,%eax
f01030bb:	39 98 28 50 23 f0    	cmp    %ebx,-0xfdcafd8(%eax)
f01030c1:	74 b8                	je     f010307b <envid2env+0x2f>
f01030c3:	8b 73 4c             	mov    0x4c(%ebx),%esi
f01030c6:	e8 60 2e 00 00       	call   f0105f2b <cpunum>
f01030cb:	6b c0 74             	imul   $0x74,%eax,%eax
f01030ce:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f01030d4:	3b 70 48             	cmp    0x48(%eax),%esi
f01030d7:	74 a2                	je     f010307b <envid2env+0x2f>
		*env_store = 0;
f01030d9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01030dc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01030e2:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01030e7:	eb 9c                	jmp    f0103085 <envid2env+0x39>

f01030e9 <env_init_percpu>:
{
f01030e9:	55                   	push   %ebp
f01030ea:	89 e5                	mov    %esp,%ebp
	asm volatile("lgdt (%0)" : : "r" (p));
f01030ec:	b8 20 23 12 f0       	mov    $0xf0122320,%eax
f01030f1:	0f 01 10             	lgdtl  (%eax)
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f01030f4:	b8 23 00 00 00       	mov    $0x23,%eax
f01030f9:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f01030fb:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f01030fd:	b8 10 00 00 00       	mov    $0x10,%eax
f0103102:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0103104:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0103106:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0103108:	ea 0f 31 10 f0 08 00 	ljmp   $0x8,$0xf010310f
	asm volatile("lldt %0" : : "r" (sel));
f010310f:	b8 00 00 00 00       	mov    $0x0,%eax
f0103114:	0f 00 d0             	lldt   %ax
}
f0103117:	5d                   	pop    %ebp
f0103118:	c3                   	ret    

f0103119 <env_init>:
{
f0103119:	55                   	push   %ebp
f010311a:	89 e5                	mov    %esp,%ebp
f010311c:	56                   	push   %esi
f010311d:	53                   	push   %ebx
	  envs[i].env_id = 0;
f010311e:	8b 35 44 42 23 f0    	mov    0xf0234244,%esi
f0103124:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f010312a:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f010312d:	ba 00 00 00 00       	mov    $0x0,%edx
f0103132:	89 c1                	mov    %eax,%ecx
f0103134:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
	  envs[i].env_status = ENV_FREE;
f010313b:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
	  envs[i].env_link = env_free_list;
f0103142:	89 50 44             	mov    %edx,0x44(%eax)
f0103145:	83 e8 7c             	sub    $0x7c,%eax
	  env_free_list = &envs[i];
f0103148:	89 ca                	mov    %ecx,%edx
	for(i=NENV-1;i>=0;i--){
f010314a:	39 d8                	cmp    %ebx,%eax
f010314c:	75 e4                	jne    f0103132 <env_init+0x19>
f010314e:	89 35 48 42 23 f0    	mov    %esi,0xf0234248
	env_init_percpu();
f0103154:	e8 90 ff ff ff       	call   f01030e9 <env_init_percpu>
}
f0103159:	5b                   	pop    %ebx
f010315a:	5e                   	pop    %esi
f010315b:	5d                   	pop    %ebp
f010315c:	c3                   	ret    

f010315d <env_alloc>:
{
f010315d:	55                   	push   %ebp
f010315e:	89 e5                	mov    %esp,%ebp
f0103160:	53                   	push   %ebx
f0103161:	83 ec 04             	sub    $0x4,%esp
	if (!(e = env_free_list))
f0103164:	8b 1d 48 42 23 f0    	mov    0xf0234248,%ebx
f010316a:	85 db                	test   %ebx,%ebx
f010316c:	0f 84 92 01 00 00    	je     f0103304 <env_alloc+0x1a7>
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103172:	83 ec 0c             	sub    $0xc,%esp
f0103175:	6a 01                	push   $0x1
f0103177:	e8 95 dd ff ff       	call   f0100f11 <page_alloc>
f010317c:	83 c4 10             	add    $0x10,%esp
f010317f:	85 c0                	test   %eax,%eax
f0103181:	0f 84 84 01 00 00    	je     f010330b <env_alloc+0x1ae>
	return (pp - pages) << PGSHIFT;
f0103187:	89 c2                	mov    %eax,%edx
f0103189:	2b 15 90 4e 23 f0    	sub    0xf0234e90,%edx
f010318f:	c1 fa 03             	sar    $0x3,%edx
f0103192:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0103195:	89 d1                	mov    %edx,%ecx
f0103197:	c1 e9 0c             	shr    $0xc,%ecx
f010319a:	3b 0d 88 4e 23 f0    	cmp    0xf0234e88,%ecx
f01031a0:	0f 83 37 01 00 00    	jae    f01032dd <env_alloc+0x180>
	return (void *)(pa + KERNBASE);
f01031a6:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01031ac:	89 53 60             	mov    %edx,0x60(%ebx)
        p->pp_ref++;
f01031af:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f01031b4:	b8 00 00 00 00       	mov    $0x0,%eax
	  e->env_pgdir[i] = 0;
f01031b9:	8b 53 60             	mov    0x60(%ebx),%edx
f01031bc:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
f01031c3:	83 c0 04             	add    $0x4,%eax
	for(i=0;i<PDX(UTOP);i++){
f01031c6:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f01031cb:	75 ec                	jne    f01031b9 <env_alloc+0x5c>
	  e->env_pgdir[i] = kern_pgdir[i];
f01031cd:	8b 15 8c 4e 23 f0    	mov    0xf0234e8c,%edx
f01031d3:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f01031d6:	8b 53 60             	mov    0x60(%ebx),%edx
f01031d9:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f01031dc:	83 c0 04             	add    $0x4,%eax
	for(i=PDX(UTOP);i<NPDENTRIES;i++){
f01031df:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01031e4:	75 e7                	jne    f01031cd <env_alloc+0x70>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01031e6:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f01031e9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01031ee:	0f 86 fb 00 00 00    	jbe    f01032ef <env_alloc+0x192>
	return (physaddr_t)kva - KERNBASE;
f01031f4:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01031fa:	83 ca 05             	or     $0x5,%edx
f01031fd:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103203:	8b 43 48             	mov    0x48(%ebx),%eax
f0103206:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f010320b:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0103210:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103215:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103218:	89 da                	mov    %ebx,%edx
f010321a:	2b 15 44 42 23 f0    	sub    0xf0234244,%edx
f0103220:	c1 fa 02             	sar    $0x2,%edx
f0103223:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f0103229:	09 d0                	or     %edx,%eax
f010322b:	89 43 48             	mov    %eax,0x48(%ebx)
	e->env_parent_id = parent_id;
f010322e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103231:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103234:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f010323b:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103242:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103249:	83 ec 04             	sub    $0x4,%esp
f010324c:	6a 44                	push   $0x44
f010324e:	6a 00                	push   $0x0
f0103250:	53                   	push   %ebx
f0103251:	e8 b1 26 00 00       	call   f0105907 <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f0103256:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f010325c:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103262:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103268:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f010326f:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
        e->env_tf.tf_eflags |= FL_IF;
f0103275:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	e->env_pgfault_upcall = 0;
f010327c:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)
	e->env_ipc_recving = 0;
f0103283:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	env_free_list = e->env_link;
f0103287:	8b 43 44             	mov    0x44(%ebx),%eax
f010328a:	a3 48 42 23 f0       	mov    %eax,0xf0234248
	*newenv_store = e;
f010328f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103292:	89 18                	mov    %ebx,(%eax)
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103294:	8b 5b 48             	mov    0x48(%ebx),%ebx
f0103297:	e8 8f 2c 00 00       	call   f0105f2b <cpunum>
f010329c:	6b c0 74             	imul   $0x74,%eax,%eax
f010329f:	83 c4 10             	add    $0x10,%esp
f01032a2:	ba 00 00 00 00       	mov    $0x0,%edx
f01032a7:	83 b8 28 50 23 f0 00 	cmpl   $0x0,-0xfdcafd8(%eax)
f01032ae:	74 11                	je     f01032c1 <env_alloc+0x164>
f01032b0:	e8 76 2c 00 00       	call   f0105f2b <cpunum>
f01032b5:	6b c0 74             	imul   $0x74,%eax,%eax
f01032b8:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f01032be:	8b 50 48             	mov    0x48(%eax),%edx
f01032c1:	83 ec 04             	sub    $0x4,%esp
f01032c4:	53                   	push   %ebx
f01032c5:	52                   	push   %edx
f01032c6:	68 c2 77 10 f0       	push   $0xf01077c2
f01032cb:	e8 74 06 00 00       	call   f0103944 <cprintf>
	return 0;
f01032d0:	83 c4 10             	add    $0x10,%esp
f01032d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01032d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01032db:	c9                   	leave  
f01032dc:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01032dd:	52                   	push   %edx
f01032de:	68 84 65 10 f0       	push   $0xf0106584
f01032e3:	6a 58                	push   $0x58
f01032e5:	68 55 74 10 f0       	push   $0xf0107455
f01032ea:	e8 51 cd ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032ef:	50                   	push   %eax
f01032f0:	68 a8 65 10 f0       	push   $0xf01065a8
f01032f5:	68 cc 00 00 00       	push   $0xcc
f01032fa:	68 a3 77 10 f0       	push   $0xf01077a3
f01032ff:	e8 3c cd ff ff       	call   f0100040 <_panic>
		return -E_NO_FREE_ENV;
f0103304:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103309:	eb cd                	jmp    f01032d8 <env_alloc+0x17b>
		return -E_NO_MEM;
f010330b:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0103310:	eb c6                	jmp    f01032d8 <env_alloc+0x17b>

f0103312 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103312:	55                   	push   %ebp
f0103313:	89 e5                	mov    %esp,%ebp
f0103315:	57                   	push   %edi
f0103316:	56                   	push   %esi
f0103317:	53                   	push   %ebx
f0103318:	83 ec 34             	sub    $0x34,%esp
f010331b:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env *e;
     if(env_alloc(&e,0) < 0)
f010331e:	6a 00                	push   $0x0
f0103320:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103323:	50                   	push   %eax
f0103324:	e8 34 fe ff ff       	call   f010315d <env_alloc>
f0103329:	83 c4 10             	add    $0x10,%esp
f010332c:	85 c0                	test   %eax,%eax
f010332e:	78 33                	js     f0103363 <env_create+0x51>
	     panic("env create failed\n");
        load_icode(e,binary);
f0103330:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103333:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	if(elfhdr->e_magic != ELF_MAGIC) 
f0103336:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f010333c:	75 3c                	jne    f010337a <env_create+0x68>
	ph = (struct Proghdr *)((uint8_t *) elfhdr + elfhdr->e_phoff);
f010333e:	89 fb                	mov    %edi,%ebx
f0103340:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph + elfhdr->e_phnum;
f0103343:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f0103347:	c1 e6 05             	shl    $0x5,%esi
f010334a:	01 de                	add    %ebx,%esi
	lcr3(PADDR(e->env_pgdir));
f010334c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010334f:	8b 40 60             	mov    0x60(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103352:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103357:	76 38                	jbe    f0103391 <env_create+0x7f>
	return (physaddr_t)kva - KERNBASE;
f0103359:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010335e:	0f 22 d8             	mov    %eax,%cr3
f0103361:	eb 5d                	jmp    f01033c0 <env_create+0xae>
	     panic("env create failed\n");
f0103363:	83 ec 04             	sub    $0x4,%esp
f0103366:	68 d7 77 10 f0       	push   $0xf01077d7
f010336b:	68 9c 01 00 00       	push   $0x19c
f0103370:	68 a3 77 10 f0       	push   $0xf01077a3
f0103375:	e8 c6 cc ff ff       	call   f0100040 <_panic>
		panic("elf header's magic is wrong\n");
f010337a:	83 ec 04             	sub    $0x4,%esp
f010337d:	68 ea 77 10 f0       	push   $0xf01077ea
f0103382:	68 76 01 00 00       	push   $0x176
f0103387:	68 a3 77 10 f0       	push   $0xf01077a3
f010338c:	e8 af cc ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103391:	50                   	push   %eax
f0103392:	68 a8 65 10 f0       	push   $0xf01065a8
f0103397:	68 7c 01 00 00       	push   $0x17c
f010339c:	68 a3 77 10 f0       	push   $0xf01077a3
f01033a1:	e8 9a cc ff ff       	call   f0100040 <_panic>
		   panic("filesz is larger than memsz, error\n");
f01033a6:	83 ec 04             	sub    $0x4,%esp
f01033a9:	68 2c 78 10 f0       	push   $0xf010782c
f01033ae:	68 81 01 00 00       	push   $0x181
f01033b3:	68 a3 77 10 f0       	push   $0xf01077a3
f01033b8:	e8 83 cc ff ff       	call   f0100040 <_panic>
	for(; ph<eph; ph++){
f01033bd:	83 c3 20             	add    $0x20,%ebx
f01033c0:	39 de                	cmp    %ebx,%esi
f01033c2:	76 41                	jbe    f0103405 <env_create+0xf3>
	   if(ph->p_type != ELF_PROG_LOAD)
f01033c4:	83 3b 01             	cmpl   $0x1,(%ebx)
f01033c7:	75 f4                	jne    f01033bd <env_create+0xab>
	   if(ph->p_filesz > ph->p_memsz)
f01033c9:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01033cc:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f01033cf:	77 d5                	ja     f01033a6 <env_create+0x94>
	   region_alloc(e,(void *)ph->p_va, ph->p_memsz);
f01033d1:	8b 53 08             	mov    0x8(%ebx),%edx
f01033d4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01033d7:	e8 ea fb ff ff       	call   f0102fc6 <region_alloc>
	   memset((void *)ph->p_va,0,ph->p_memsz);  
f01033dc:	83 ec 04             	sub    $0x4,%esp
f01033df:	ff 73 14             	pushl  0x14(%ebx)
f01033e2:	6a 00                	push   $0x0
f01033e4:	ff 73 08             	pushl  0x8(%ebx)
f01033e7:	e8 1b 25 00 00       	call   f0105907 <memset>
	   memcpy((void *)ph->p_va,binary+ph->p_offset,ph->p_filesz);
f01033ec:	83 c4 0c             	add    $0xc,%esp
f01033ef:	ff 73 10             	pushl  0x10(%ebx)
f01033f2:	89 f8                	mov    %edi,%eax
f01033f4:	03 43 04             	add    0x4(%ebx),%eax
f01033f7:	50                   	push   %eax
f01033f8:	ff 73 08             	pushl  0x8(%ebx)
f01033fb:	e8 bc 25 00 00       	call   f01059bc <memcpy>
f0103400:	83 c4 10             	add    $0x10,%esp
f0103403:	eb b8                	jmp    f01033bd <env_create+0xab>
	 e->env_tf.tf_eip = elfhdr->e_entry; //???
f0103405:	8b 47 18             	mov    0x18(%edi),%eax
f0103408:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010340b:	89 47 30             	mov    %eax,0x30(%edi)
        lcr3(PADDR(kern_pgdir));
f010340e:	a1 8c 4e 23 f0       	mov    0xf0234e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0103413:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103418:	76 2b                	jbe    f0103445 <env_create+0x133>
	return (physaddr_t)kva - KERNBASE;
f010341a:	05 00 00 00 10       	add    $0x10000000,%eax
f010341f:	0f 22 d8             	mov    %eax,%cr3
	region_alloc(e,(void *)(USTACKTOP-PGSIZE),PGSIZE);
f0103422:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103427:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f010342c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010342f:	e8 92 fb ff ff       	call   f0102fc6 <region_alloc>
	e->env_type = type;
f0103434:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103437:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010343a:	89 50 50             	mov    %edx,0x50(%eax)
}
f010343d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103440:	5b                   	pop    %ebx
f0103441:	5e                   	pop    %esi
f0103442:	5f                   	pop    %edi
f0103443:	5d                   	pop    %ebp
f0103444:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103445:	50                   	push   %eax
f0103446:	68 a8 65 10 f0       	push   $0xf01065a8
f010344b:	68 8a 01 00 00       	push   $0x18a
f0103450:	68 a3 77 10 f0       	push   $0xf01077a3
f0103455:	e8 e6 cb ff ff       	call   f0100040 <_panic>

f010345a <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f010345a:	55                   	push   %ebp
f010345b:	89 e5                	mov    %esp,%ebp
f010345d:	57                   	push   %edi
f010345e:	56                   	push   %esi
f010345f:	53                   	push   %ebx
f0103460:	83 ec 1c             	sub    $0x1c,%esp
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103463:	e8 c3 2a 00 00       	call   f0105f2b <cpunum>
f0103468:	6b c0 74             	imul   $0x74,%eax,%eax
f010346b:	8b 55 08             	mov    0x8(%ebp),%edx
f010346e:	39 90 28 50 23 f0    	cmp    %edx,-0xfdcafd8(%eax)
f0103474:	75 14                	jne    f010348a <env_free+0x30>
		lcr3(PADDR(kern_pgdir));
f0103476:	a1 8c 4e 23 f0       	mov    0xf0234e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f010347b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103480:	76 56                	jbe    f01034d8 <env_free+0x7e>
	return (physaddr_t)kva - KERNBASE;
f0103482:	05 00 00 00 10       	add    $0x10000000,%eax
f0103487:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010348a:	8b 45 08             	mov    0x8(%ebp),%eax
f010348d:	8b 58 48             	mov    0x48(%eax),%ebx
f0103490:	e8 96 2a 00 00       	call   f0105f2b <cpunum>
f0103495:	6b c0 74             	imul   $0x74,%eax,%eax
f0103498:	ba 00 00 00 00       	mov    $0x0,%edx
f010349d:	83 b8 28 50 23 f0 00 	cmpl   $0x0,-0xfdcafd8(%eax)
f01034a4:	74 11                	je     f01034b7 <env_free+0x5d>
f01034a6:	e8 80 2a 00 00       	call   f0105f2b <cpunum>
f01034ab:	6b c0 74             	imul   $0x74,%eax,%eax
f01034ae:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f01034b4:	8b 50 48             	mov    0x48(%eax),%edx
f01034b7:	83 ec 04             	sub    $0x4,%esp
f01034ba:	53                   	push   %ebx
f01034bb:	52                   	push   %edx
f01034bc:	68 07 78 10 f0       	push   $0xf0107807
f01034c1:	e8 7e 04 00 00       	call   f0103944 <cprintf>
f01034c6:	83 c4 10             	add    $0x10,%esp
f01034c9:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f01034d0:	8b 7d 08             	mov    0x8(%ebp),%edi
f01034d3:	e9 8f 00 00 00       	jmp    f0103567 <env_free+0x10d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01034d8:	50                   	push   %eax
f01034d9:	68 a8 65 10 f0       	push   $0xf01065a8
f01034de:	68 af 01 00 00       	push   $0x1af
f01034e3:	68 a3 77 10 f0       	push   $0xf01077a3
f01034e8:	e8 53 cb ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01034ed:	50                   	push   %eax
f01034ee:	68 84 65 10 f0       	push   $0xf0106584
f01034f3:	68 be 01 00 00       	push   $0x1be
f01034f8:	68 a3 77 10 f0       	push   $0xf01077a3
f01034fd:	e8 3e cb ff ff       	call   f0100040 <_panic>
f0103502:	83 c3 04             	add    $0x4,%ebx
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103505:	39 f3                	cmp    %esi,%ebx
f0103507:	74 21                	je     f010352a <env_free+0xd0>
			if (pt[pteno] & PTE_P)
f0103509:	f6 03 01             	testb  $0x1,(%ebx)
f010350c:	74 f4                	je     f0103502 <env_free+0xa8>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010350e:	83 ec 08             	sub    $0x8,%esp
f0103511:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103514:	01 d8                	add    %ebx,%eax
f0103516:	c1 e0 0a             	shl    $0xa,%eax
f0103519:	0b 45 e4             	or     -0x1c(%ebp),%eax
f010351c:	50                   	push   %eax
f010351d:	ff 77 60             	pushl  0x60(%edi)
f0103520:	e8 c1 dc ff ff       	call   f01011e6 <page_remove>
f0103525:	83 c4 10             	add    $0x10,%esp
f0103528:	eb d8                	jmp    f0103502 <env_free+0xa8>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f010352a:	8b 47 60             	mov    0x60(%edi),%eax
f010352d:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103530:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f0103537:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010353a:	3b 05 88 4e 23 f0    	cmp    0xf0234e88,%eax
f0103540:	73 6a                	jae    f01035ac <env_free+0x152>
		page_decref(pa2page(pa));
f0103542:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103545:	a1 90 4e 23 f0       	mov    0xf0234e90,%eax
f010354a:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010354d:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0103550:	50                   	push   %eax
f0103551:	e8 68 da ff ff       	call   f0100fbe <page_decref>
f0103556:	83 c4 10             	add    $0x10,%esp
f0103559:	83 45 dc 04          	addl   $0x4,-0x24(%ebp)
f010355d:	8b 45 dc             	mov    -0x24(%ebp),%eax
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103560:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f0103565:	74 59                	je     f01035c0 <env_free+0x166>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103567:	8b 47 60             	mov    0x60(%edi),%eax
f010356a:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010356d:	8b 04 10             	mov    (%eax,%edx,1),%eax
f0103570:	a8 01                	test   $0x1,%al
f0103572:	74 e5                	je     f0103559 <env_free+0xff>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103574:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0103579:	89 c2                	mov    %eax,%edx
f010357b:	c1 ea 0c             	shr    $0xc,%edx
f010357e:	89 55 d8             	mov    %edx,-0x28(%ebp)
f0103581:	39 15 88 4e 23 f0    	cmp    %edx,0xf0234e88
f0103587:	0f 86 60 ff ff ff    	jbe    f01034ed <env_free+0x93>
	return (void *)(pa + KERNBASE);
f010358d:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103593:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103596:	c1 e2 14             	shl    $0x14,%edx
f0103599:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010359c:	8d b0 00 10 00 f0    	lea    -0xffff000(%eax),%esi
f01035a2:	f7 d8                	neg    %eax
f01035a4:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01035a7:	e9 5d ff ff ff       	jmp    f0103509 <env_free+0xaf>
		panic("pa2page called with invalid pa");
f01035ac:	83 ec 04             	sub    $0x4,%esp
f01035af:	68 10 6c 10 f0       	push   $0xf0106c10
f01035b4:	6a 51                	push   $0x51
f01035b6:	68 55 74 10 f0       	push   $0xf0107455
f01035bb:	e8 80 ca ff ff       	call   f0100040 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f01035c0:	8b 45 08             	mov    0x8(%ebp),%eax
f01035c3:	8b 40 60             	mov    0x60(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f01035c6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01035cb:	76 52                	jbe    f010361f <env_free+0x1c5>
	e->env_pgdir = 0;
f01035cd:	8b 55 08             	mov    0x8(%ebp),%edx
f01035d0:	c7 42 60 00 00 00 00 	movl   $0x0,0x60(%edx)
	return (physaddr_t)kva - KERNBASE;
f01035d7:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f01035dc:	c1 e8 0c             	shr    $0xc,%eax
f01035df:	3b 05 88 4e 23 f0    	cmp    0xf0234e88,%eax
f01035e5:	73 4d                	jae    f0103634 <env_free+0x1da>
	page_decref(pa2page(pa));
f01035e7:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f01035ea:	8b 15 90 4e 23 f0    	mov    0xf0234e90,%edx
f01035f0:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f01035f3:	50                   	push   %eax
f01035f4:	e8 c5 d9 ff ff       	call   f0100fbe <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01035f9:	8b 45 08             	mov    0x8(%ebp),%eax
f01035fc:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
	e->env_link = env_free_list;
f0103603:	a1 48 42 23 f0       	mov    0xf0234248,%eax
f0103608:	8b 55 08             	mov    0x8(%ebp),%edx
f010360b:	89 42 44             	mov    %eax,0x44(%edx)
	env_free_list = e;
f010360e:	89 15 48 42 23 f0    	mov    %edx,0xf0234248
}
f0103614:	83 c4 10             	add    $0x10,%esp
f0103617:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010361a:	5b                   	pop    %ebx
f010361b:	5e                   	pop    %esi
f010361c:	5f                   	pop    %edi
f010361d:	5d                   	pop    %ebp
f010361e:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010361f:	50                   	push   %eax
f0103620:	68 a8 65 10 f0       	push   $0xf01065a8
f0103625:	68 cc 01 00 00       	push   $0x1cc
f010362a:	68 a3 77 10 f0       	push   $0xf01077a3
f010362f:	e8 0c ca ff ff       	call   f0100040 <_panic>
		panic("pa2page called with invalid pa");
f0103634:	83 ec 04             	sub    $0x4,%esp
f0103637:	68 10 6c 10 f0       	push   $0xf0106c10
f010363c:	6a 51                	push   $0x51
f010363e:	68 55 74 10 f0       	push   $0xf0107455
f0103643:	e8 f8 c9 ff ff       	call   f0100040 <_panic>

f0103648 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103648:	55                   	push   %ebp
f0103649:	89 e5                	mov    %esp,%ebp
f010364b:	53                   	push   %ebx
f010364c:	83 ec 04             	sub    $0x4,%esp
f010364f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103652:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103656:	74 21                	je     f0103679 <env_destroy+0x31>
		e->env_status = ENV_DYING;
		return;
	}

	env_free(e);
f0103658:	83 ec 0c             	sub    $0xc,%esp
f010365b:	53                   	push   %ebx
f010365c:	e8 f9 fd ff ff       	call   f010345a <env_free>

	if (curenv == e) {
f0103661:	e8 c5 28 00 00       	call   f0105f2b <cpunum>
f0103666:	6b c0 74             	imul   $0x74,%eax,%eax
f0103669:	83 c4 10             	add    $0x10,%esp
f010366c:	39 98 28 50 23 f0    	cmp    %ebx,-0xfdcafd8(%eax)
f0103672:	74 1e                	je     f0103692 <env_destroy+0x4a>
		curenv = NULL;
		sched_yield();
	}
}
f0103674:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103677:	c9                   	leave  
f0103678:	c3                   	ret    
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103679:	e8 ad 28 00 00       	call   f0105f2b <cpunum>
f010367e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103681:	39 98 28 50 23 f0    	cmp    %ebx,-0xfdcafd8(%eax)
f0103687:	74 cf                	je     f0103658 <env_destroy+0x10>
		e->env_status = ENV_DYING;
f0103689:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103690:	eb e2                	jmp    f0103674 <env_destroy+0x2c>
		curenv = NULL;
f0103692:	e8 94 28 00 00       	call   f0105f2b <cpunum>
f0103697:	6b c0 74             	imul   $0x74,%eax,%eax
f010369a:	c7 80 28 50 23 f0 00 	movl   $0x0,-0xfdcafd8(%eax)
f01036a1:	00 00 00 
		sched_yield();
f01036a4:	e8 b7 0e 00 00       	call   f0104560 <sched_yield>

f01036a9 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01036a9:	55                   	push   %ebp
f01036aa:	89 e5                	mov    %esp,%ebp
f01036ac:	53                   	push   %ebx
f01036ad:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f01036b0:	e8 76 28 00 00       	call   f0105f2b <cpunum>
f01036b5:	6b c0 74             	imul   $0x74,%eax,%eax
f01036b8:	8b 98 28 50 23 f0    	mov    -0xfdcafd8(%eax),%ebx
f01036be:	e8 68 28 00 00       	call   f0105f2b <cpunum>
f01036c3:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f01036c6:	8b 65 08             	mov    0x8(%ebp),%esp
f01036c9:	61                   	popa   
f01036ca:	07                   	pop    %es
f01036cb:	1f                   	pop    %ds
f01036cc:	83 c4 08             	add    $0x8,%esp
f01036cf:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01036d0:	83 ec 04             	sub    $0x4,%esp
f01036d3:	68 1d 78 10 f0       	push   $0xf010781d
f01036d8:	68 03 02 00 00       	push   $0x203
f01036dd:	68 a3 77 10 f0       	push   $0xf01077a3
f01036e2:	e8 59 c9 ff ff       	call   f0100040 <_panic>

f01036e7 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01036e7:	55                   	push   %ebp
f01036e8:	89 e5                	mov    %esp,%ebp
f01036ea:	83 ec 08             	sub    $0x8,%esp
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
        if(curenv && curenv->env_status == ENV_RUNNING){
f01036ed:	e8 39 28 00 00       	call   f0105f2b <cpunum>
f01036f2:	6b c0 74             	imul   $0x74,%eax,%eax
f01036f5:	83 b8 28 50 23 f0 00 	cmpl   $0x0,-0xfdcafd8(%eax)
f01036fc:	74 14                	je     f0103712 <env_run+0x2b>
f01036fe:	e8 28 28 00 00       	call   f0105f2b <cpunum>
f0103703:	6b c0 74             	imul   $0x74,%eax,%eax
f0103706:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f010370c:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103710:	74 65                	je     f0103777 <env_run+0x90>
	   curenv->env_status = ENV_RUNNABLE;
	}

	curenv = e;
f0103712:	e8 14 28 00 00       	call   f0105f2b <cpunum>
f0103717:	6b c0 74             	imul   $0x74,%eax,%eax
f010371a:	8b 55 08             	mov    0x8(%ebp),%edx
f010371d:	89 90 28 50 23 f0    	mov    %edx,-0xfdcafd8(%eax)
	curenv->env_status = ENV_RUNNING;
f0103723:	e8 03 28 00 00       	call   f0105f2b <cpunum>
f0103728:	6b c0 74             	imul   $0x74,%eax,%eax
f010372b:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f0103731:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f0103738:	e8 ee 27 00 00       	call   f0105f2b <cpunum>
f010373d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103740:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f0103746:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3(PADDR(curenv->env_pgdir)); //why?
f010374a:	e8 dc 27 00 00       	call   f0105f2b <cpunum>
f010374f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103752:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f0103758:	8b 40 60             	mov    0x60(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f010375b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103760:	77 2c                	ja     f010378e <env_run+0xa7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103762:	50                   	push   %eax
f0103763:	68 a8 65 10 f0       	push   $0xf01065a8
f0103768:	68 28 02 00 00       	push   $0x228
f010376d:	68 a3 77 10 f0       	push   $0xf01077a3
f0103772:	e8 c9 c8 ff ff       	call   f0100040 <_panic>
	   curenv->env_status = ENV_RUNNABLE;
f0103777:	e8 af 27 00 00       	call   f0105f2b <cpunum>
f010377c:	6b c0 74             	imul   $0x74,%eax,%eax
f010377f:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f0103785:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f010378c:	eb 84                	jmp    f0103712 <env_run+0x2b>
	return (physaddr_t)kva - KERNBASE;
f010378e:	05 00 00 00 10       	add    $0x10000000,%eax
f0103793:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103796:	83 ec 0c             	sub    $0xc,%esp
f0103799:	68 c0 23 12 f0       	push   $0xf01223c0
f010379e:	e8 95 2a 00 00       	call   f0106238 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01037a3:	f3 90                	pause  
        
        unlock_kernel();

	env_pop_tf(&curenv->env_tf);//what meaning?
f01037a5:	e8 81 27 00 00       	call   f0105f2b <cpunum>
f01037aa:	83 c4 04             	add    $0x4,%esp
f01037ad:	6b c0 74             	imul   $0x74,%eax,%eax
f01037b0:	ff b0 28 50 23 f0    	pushl  -0xfdcafd8(%eax)
f01037b6:	e8 ee fe ff ff       	call   f01036a9 <env_pop_tf>

f01037bb <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01037bb:	55                   	push   %ebp
f01037bc:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01037be:	8b 45 08             	mov    0x8(%ebp),%eax
f01037c1:	ba 70 00 00 00       	mov    $0x70,%edx
f01037c6:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01037c7:	ba 71 00 00 00       	mov    $0x71,%edx
f01037cc:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01037cd:	0f b6 c0             	movzbl %al,%eax
}
f01037d0:	5d                   	pop    %ebp
f01037d1:	c3                   	ret    

f01037d2 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01037d2:	55                   	push   %ebp
f01037d3:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01037d5:	8b 45 08             	mov    0x8(%ebp),%eax
f01037d8:	ba 70 00 00 00       	mov    $0x70,%edx
f01037dd:	ee                   	out    %al,(%dx)
f01037de:	8b 45 0c             	mov    0xc(%ebp),%eax
f01037e1:	ba 71 00 00 00       	mov    $0x71,%edx
f01037e6:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01037e7:	5d                   	pop    %ebp
f01037e8:	c3                   	ret    

f01037e9 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f01037e9:	55                   	push   %ebp
f01037ea:	89 e5                	mov    %esp,%ebp
f01037ec:	56                   	push   %esi
f01037ed:	53                   	push   %ebx
f01037ee:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f01037f1:	66 a3 a8 23 12 f0    	mov    %ax,0xf01223a8
	if (!didinit)
f01037f7:	80 3d 4c 42 23 f0 00 	cmpb   $0x0,0xf023424c
f01037fe:	75 07                	jne    f0103807 <irq_setmask_8259A+0x1e>
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
}
f0103800:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103803:	5b                   	pop    %ebx
f0103804:	5e                   	pop    %esi
f0103805:	5d                   	pop    %ebp
f0103806:	c3                   	ret    
f0103807:	89 c6                	mov    %eax,%esi
f0103809:	ba 21 00 00 00       	mov    $0x21,%edx
f010380e:	ee                   	out    %al,(%dx)
	outb(IO_PIC2+1, (char)(mask >> 8));
f010380f:	66 c1 e8 08          	shr    $0x8,%ax
f0103813:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103818:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103819:	83 ec 0c             	sub    $0xc,%esp
f010381c:	68 50 78 10 f0       	push   $0xf0107850
f0103821:	e8 1e 01 00 00       	call   f0103944 <cprintf>
f0103826:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103829:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f010382e:	0f b7 f6             	movzwl %si,%esi
f0103831:	f7 d6                	not    %esi
f0103833:	eb 08                	jmp    f010383d <irq_setmask_8259A+0x54>
	for (i = 0; i < 16; i++)
f0103835:	83 c3 01             	add    $0x1,%ebx
f0103838:	83 fb 10             	cmp    $0x10,%ebx
f010383b:	74 18                	je     f0103855 <irq_setmask_8259A+0x6c>
		if (~mask & (1<<i))
f010383d:	0f a3 de             	bt     %ebx,%esi
f0103840:	73 f3                	jae    f0103835 <irq_setmask_8259A+0x4c>
			cprintf(" %d", i);
f0103842:	83 ec 08             	sub    $0x8,%esp
f0103845:	53                   	push   %ebx
f0103846:	68 ba 7d 10 f0       	push   $0xf0107dba
f010384b:	e8 f4 00 00 00       	call   f0103944 <cprintf>
f0103850:	83 c4 10             	add    $0x10,%esp
f0103853:	eb e0                	jmp    f0103835 <irq_setmask_8259A+0x4c>
	cprintf("\n");
f0103855:	83 ec 0c             	sub    $0xc,%esp
f0103858:	68 c9 68 10 f0       	push   $0xf01068c9
f010385d:	e8 e2 00 00 00       	call   f0103944 <cprintf>
f0103862:	83 c4 10             	add    $0x10,%esp
f0103865:	eb 99                	jmp    f0103800 <irq_setmask_8259A+0x17>

f0103867 <pic_init>:
{
f0103867:	55                   	push   %ebp
f0103868:	89 e5                	mov    %esp,%ebp
f010386a:	57                   	push   %edi
f010386b:	56                   	push   %esi
f010386c:	53                   	push   %ebx
f010386d:	83 ec 0c             	sub    $0xc,%esp
	didinit = 1;
f0103870:	c6 05 4c 42 23 f0 01 	movb   $0x1,0xf023424c
f0103877:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010387c:	bb 21 00 00 00       	mov    $0x21,%ebx
f0103881:	89 da                	mov    %ebx,%edx
f0103883:	ee                   	out    %al,(%dx)
f0103884:	b9 a1 00 00 00       	mov    $0xa1,%ecx
f0103889:	89 ca                	mov    %ecx,%edx
f010388b:	ee                   	out    %al,(%dx)
f010388c:	bf 11 00 00 00       	mov    $0x11,%edi
f0103891:	be 20 00 00 00       	mov    $0x20,%esi
f0103896:	89 f8                	mov    %edi,%eax
f0103898:	89 f2                	mov    %esi,%edx
f010389a:	ee                   	out    %al,(%dx)
f010389b:	b8 20 00 00 00       	mov    $0x20,%eax
f01038a0:	89 da                	mov    %ebx,%edx
f01038a2:	ee                   	out    %al,(%dx)
f01038a3:	b8 04 00 00 00       	mov    $0x4,%eax
f01038a8:	ee                   	out    %al,(%dx)
f01038a9:	b8 03 00 00 00       	mov    $0x3,%eax
f01038ae:	ee                   	out    %al,(%dx)
f01038af:	bb a0 00 00 00       	mov    $0xa0,%ebx
f01038b4:	89 f8                	mov    %edi,%eax
f01038b6:	89 da                	mov    %ebx,%edx
f01038b8:	ee                   	out    %al,(%dx)
f01038b9:	b8 28 00 00 00       	mov    $0x28,%eax
f01038be:	89 ca                	mov    %ecx,%edx
f01038c0:	ee                   	out    %al,(%dx)
f01038c1:	b8 02 00 00 00       	mov    $0x2,%eax
f01038c6:	ee                   	out    %al,(%dx)
f01038c7:	b8 01 00 00 00       	mov    $0x1,%eax
f01038cc:	ee                   	out    %al,(%dx)
f01038cd:	bf 68 00 00 00       	mov    $0x68,%edi
f01038d2:	89 f8                	mov    %edi,%eax
f01038d4:	89 f2                	mov    %esi,%edx
f01038d6:	ee                   	out    %al,(%dx)
f01038d7:	b9 0a 00 00 00       	mov    $0xa,%ecx
f01038dc:	89 c8                	mov    %ecx,%eax
f01038de:	ee                   	out    %al,(%dx)
f01038df:	89 f8                	mov    %edi,%eax
f01038e1:	89 da                	mov    %ebx,%edx
f01038e3:	ee                   	out    %al,(%dx)
f01038e4:	89 c8                	mov    %ecx,%eax
f01038e6:	ee                   	out    %al,(%dx)
	if (irq_mask_8259A != 0xFFFF)
f01038e7:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f01038ee:	66 83 f8 ff          	cmp    $0xffff,%ax
f01038f2:	74 0f                	je     f0103903 <pic_init+0x9c>
		irq_setmask_8259A(irq_mask_8259A);
f01038f4:	83 ec 0c             	sub    $0xc,%esp
f01038f7:	0f b7 c0             	movzwl %ax,%eax
f01038fa:	50                   	push   %eax
f01038fb:	e8 e9 fe ff ff       	call   f01037e9 <irq_setmask_8259A>
f0103900:	83 c4 10             	add    $0x10,%esp
}
f0103903:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103906:	5b                   	pop    %ebx
f0103907:	5e                   	pop    %esi
f0103908:	5f                   	pop    %edi
f0103909:	5d                   	pop    %ebp
f010390a:	c3                   	ret    

f010390b <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f010390b:	55                   	push   %ebp
f010390c:	89 e5                	mov    %esp,%ebp
f010390e:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0103911:	ff 75 08             	pushl  0x8(%ebp)
f0103914:	e8 4f ce ff ff       	call   f0100768 <cputchar>
	*cnt++;
}
f0103919:	83 c4 10             	add    $0x10,%esp
f010391c:	c9                   	leave  
f010391d:	c3                   	ret    

f010391e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010391e:	55                   	push   %ebp
f010391f:	89 e5                	mov    %esp,%ebp
f0103921:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103924:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f010392b:	ff 75 0c             	pushl  0xc(%ebp)
f010392e:	ff 75 08             	pushl  0x8(%ebp)
f0103931:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103934:	50                   	push   %eax
f0103935:	68 0b 39 10 f0       	push   $0xf010390b
f010393a:	e8 83 18 00 00       	call   f01051c2 <vprintfmt>
	return cnt;
}
f010393f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103942:	c9                   	leave  
f0103943:	c3                   	ret    

f0103944 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103944:	55                   	push   %ebp
f0103945:	89 e5                	mov    %esp,%ebp
f0103947:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f010394a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f010394d:	50                   	push   %eax
f010394e:	ff 75 08             	pushl  0x8(%ebp)
f0103951:	e8 c8 ff ff ff       	call   f010391e <vcprintf>
	va_end(ap);

	return cnt;
}
f0103956:	c9                   	leave  
f0103957:	c3                   	ret    

f0103958 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103958:	55                   	push   %ebp
f0103959:	89 e5                	mov    %esp,%ebp
f010395b:	57                   	push   %edi
f010395c:	56                   	push   %esi
f010395d:	53                   	push   %ebx
f010395e:	83 ec 1c             	sub    $0x1c,%esp
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	int i=cpunum();
f0103961:	e8 c5 25 00 00       	call   f0105f2b <cpunum>
f0103966:	89 c6                	mov    %eax,%esi
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP-i*(KSTKSIZE+KSTKGAP);
f0103968:	e8 be 25 00 00       	call   f0105f2b <cpunum>
f010396d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103970:	89 f1                	mov    %esi,%ecx
f0103972:	c1 e1 10             	shl    $0x10,%ecx
f0103975:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f010397a:	29 ca                	sub    %ecx,%edx
f010397c:	89 90 30 50 23 f0    	mov    %edx,-0xfdcafd0(%eax)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103982:	e8 a4 25 00 00       	call   f0105f2b <cpunum>
f0103987:	6b c0 74             	imul   $0x74,%eax,%eax
f010398a:	66 c7 80 34 50 23 f0 	movw   $0x10,-0xfdcafcc(%eax)
f0103991:	10 00 
	thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);
f0103993:	e8 93 25 00 00       	call   f0105f2b <cpunum>
f0103998:	6b c0 74             	imul   $0x74,%eax,%eax
f010399b:	66 c7 80 92 50 23 f0 	movw   $0x68,-0xfdcaf6e(%eax)
f01039a2:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3)+i] = SEG16(STS_T32A, (uint32_t) (&thiscpu->cpu_ts),
f01039a4:	8d 5e 05             	lea    0x5(%esi),%ebx
f01039a7:	e8 7f 25 00 00       	call   f0105f2b <cpunum>
f01039ac:	89 c7                	mov    %eax,%edi
f01039ae:	e8 78 25 00 00       	call   f0105f2b <cpunum>
f01039b3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01039b6:	e8 70 25 00 00       	call   f0105f2b <cpunum>
f01039bb:	66 c7 04 dd 40 23 12 	movw   $0x67,-0xfeddcc0(,%ebx,8)
f01039c2:	f0 67 00 
f01039c5:	6b ff 74             	imul   $0x74,%edi,%edi
f01039c8:	81 c7 2c 50 23 f0    	add    $0xf023502c,%edi
f01039ce:	66 89 3c dd 42 23 12 	mov    %di,-0xfeddcbe(,%ebx,8)
f01039d5:	f0 
f01039d6:	6b 55 e4 74          	imul   $0x74,-0x1c(%ebp),%edx
f01039da:	81 c2 2c 50 23 f0    	add    $0xf023502c,%edx
f01039e0:	c1 ea 10             	shr    $0x10,%edx
f01039e3:	88 14 dd 44 23 12 f0 	mov    %dl,-0xfeddcbc(,%ebx,8)
f01039ea:	c6 04 dd 46 23 12 f0 	movb   $0x40,-0xfeddcba(,%ebx,8)
f01039f1:	40 
f01039f2:	6b c0 74             	imul   $0x74,%eax,%eax
f01039f5:	05 2c 50 23 f0       	add    $0xf023502c,%eax
f01039fa:	c1 e8 18             	shr    $0x18,%eax
f01039fd:	88 04 dd 47 23 12 f0 	mov    %al,-0xfeddcb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3)+i].sd_s = 0;
f0103a04:	c6 04 dd 45 23 12 f0 	movb   $0x89,-0xfeddcbb(,%ebx,8)
f0103a0b:	89 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0+(i<<3));
f0103a0c:	8d 34 f5 28 00 00 00 	lea    0x28(,%esi,8),%esi
	asm volatile("ltr %0" : : "r" (sel));
f0103a13:	0f 00 de             	ltr    %si
	asm volatile("lidt (%0)" : : "r" (p));
f0103a16:	b8 ac 23 12 f0       	mov    $0xf01223ac,%eax
f0103a1b:	0f 01 18             	lidtl  (%eax)
	ts.ts_iomb = sizeof(struct Taskstate);
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A,(uint32_t)(&ts),sizeof(struct Taskstate)-1,0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
	ltr(GD_TSS0);
        lidt(&idt_pd);*/
}
f0103a1e:	83 c4 1c             	add    $0x1c,%esp
f0103a21:	5b                   	pop    %ebx
f0103a22:	5e                   	pop    %esi
f0103a23:	5f                   	pop    %edi
f0103a24:	5d                   	pop    %ebp
f0103a25:	c3                   	ret    

f0103a26 <trap_init>:
{
f0103a26:	55                   	push   %ebp
f0103a27:	89 e5                	mov    %esp,%ebp
f0103a29:	83 ec 08             	sub    $0x8,%esp
    SETGATE(idt[T_DIVIDE], 0, GD_KT, divide_handler, 0);
f0103a2c:	b8 f0 43 10 f0       	mov    $0xf01043f0,%eax
f0103a31:	66 a3 60 42 23 f0    	mov    %ax,0xf0234260
f0103a37:	66 c7 05 62 42 23 f0 	movw   $0x8,0xf0234262
f0103a3e:	08 00 
f0103a40:	c6 05 64 42 23 f0 00 	movb   $0x0,0xf0234264
f0103a47:	c6 05 65 42 23 f0 8e 	movb   $0x8e,0xf0234265
f0103a4e:	c1 e8 10             	shr    $0x10,%eax
f0103a51:	66 a3 66 42 23 f0    	mov    %ax,0xf0234266
    SETGATE(idt[T_DEBUG], 0, GD_KT, debug_handler, 0);
f0103a57:	b8 fa 43 10 f0       	mov    $0xf01043fa,%eax
f0103a5c:	66 a3 68 42 23 f0    	mov    %ax,0xf0234268
f0103a62:	66 c7 05 6a 42 23 f0 	movw   $0x8,0xf023426a
f0103a69:	08 00 
f0103a6b:	c6 05 6c 42 23 f0 00 	movb   $0x0,0xf023426c
f0103a72:	c6 05 6d 42 23 f0 8e 	movb   $0x8e,0xf023426d
f0103a79:	c1 e8 10             	shr    $0x10,%eax
f0103a7c:	66 a3 6e 42 23 f0    	mov    %ax,0xf023426e
    SETGATE(idt[T_NMI], 0, GD_KT, nmi_handler, 0);
f0103a82:	b8 00 44 10 f0       	mov    $0xf0104400,%eax
f0103a87:	66 a3 70 42 23 f0    	mov    %ax,0xf0234270
f0103a8d:	66 c7 05 72 42 23 f0 	movw   $0x8,0xf0234272
f0103a94:	08 00 
f0103a96:	c6 05 74 42 23 f0 00 	movb   $0x0,0xf0234274
f0103a9d:	c6 05 75 42 23 f0 8e 	movb   $0x8e,0xf0234275
f0103aa4:	c1 e8 10             	shr    $0x10,%eax
f0103aa7:	66 a3 76 42 23 f0    	mov    %ax,0xf0234276
    SETGATE(idt[T_BRKPT], 0, GD_KT, brkpt_handler, 3);
f0103aad:	b8 06 44 10 f0       	mov    $0xf0104406,%eax
f0103ab2:	66 a3 78 42 23 f0    	mov    %ax,0xf0234278
f0103ab8:	66 c7 05 7a 42 23 f0 	movw   $0x8,0xf023427a
f0103abf:	08 00 
f0103ac1:	c6 05 7c 42 23 f0 00 	movb   $0x0,0xf023427c
f0103ac8:	c6 05 7d 42 23 f0 ee 	movb   $0xee,0xf023427d
f0103acf:	c1 e8 10             	shr    $0x10,%eax
f0103ad2:	66 a3 7e 42 23 f0    	mov    %ax,0xf023427e
    SETGATE(idt[T_OFLOW], 0, GD_KT, oflow_handler, 0);
f0103ad8:	b8 0c 44 10 f0       	mov    $0xf010440c,%eax
f0103add:	66 a3 80 42 23 f0    	mov    %ax,0xf0234280
f0103ae3:	66 c7 05 82 42 23 f0 	movw   $0x8,0xf0234282
f0103aea:	08 00 
f0103aec:	c6 05 84 42 23 f0 00 	movb   $0x0,0xf0234284
f0103af3:	c6 05 85 42 23 f0 8e 	movb   $0x8e,0xf0234285
f0103afa:	c1 e8 10             	shr    $0x10,%eax
f0103afd:	66 a3 86 42 23 f0    	mov    %ax,0xf0234286
    SETGATE(idt[T_BOUND], 0, GD_KT, bound_handler, 0);
f0103b03:	b8 12 44 10 f0       	mov    $0xf0104412,%eax
f0103b08:	66 a3 88 42 23 f0    	mov    %ax,0xf0234288
f0103b0e:	66 c7 05 8a 42 23 f0 	movw   $0x8,0xf023428a
f0103b15:	08 00 
f0103b17:	c6 05 8c 42 23 f0 00 	movb   $0x0,0xf023428c
f0103b1e:	c6 05 8d 42 23 f0 8e 	movb   $0x8e,0xf023428d
f0103b25:	c1 e8 10             	shr    $0x10,%eax
f0103b28:	66 a3 8e 42 23 f0    	mov    %ax,0xf023428e
    SETGATE(idt[T_DEVICE], 0, GD_KT, device_handler, 0);
f0103b2e:	b8 1e 44 10 f0       	mov    $0xf010441e,%eax
f0103b33:	66 a3 98 42 23 f0    	mov    %ax,0xf0234298
f0103b39:	66 c7 05 9a 42 23 f0 	movw   $0x8,0xf023429a
f0103b40:	08 00 
f0103b42:	c6 05 9c 42 23 f0 00 	movb   $0x0,0xf023429c
f0103b49:	c6 05 9d 42 23 f0 8e 	movb   $0x8e,0xf023429d
f0103b50:	c1 e8 10             	shr    $0x10,%eax
f0103b53:	66 a3 9e 42 23 f0    	mov    %ax,0xf023429e
    SETGATE(idt[T_ILLOP], 0, GD_KT, illop_handler, 0);
f0103b59:	b8 18 44 10 f0       	mov    $0xf0104418,%eax
f0103b5e:	66 a3 90 42 23 f0    	mov    %ax,0xf0234290
f0103b64:	66 c7 05 92 42 23 f0 	movw   $0x8,0xf0234292
f0103b6b:	08 00 
f0103b6d:	c6 05 94 42 23 f0 00 	movb   $0x0,0xf0234294
f0103b74:	c6 05 95 42 23 f0 8e 	movb   $0x8e,0xf0234295
f0103b7b:	c1 e8 10             	shr    $0x10,%eax
f0103b7e:	66 a3 96 42 23 f0    	mov    %ax,0xf0234296
    SETGATE(idt[T_DBLFLT], 0, GD_KT, dblflt_handler, 0);
f0103b84:	b8 24 44 10 f0       	mov    $0xf0104424,%eax
f0103b89:	66 a3 a0 42 23 f0    	mov    %ax,0xf02342a0
f0103b8f:	66 c7 05 a2 42 23 f0 	movw   $0x8,0xf02342a2
f0103b96:	08 00 
f0103b98:	c6 05 a4 42 23 f0 00 	movb   $0x0,0xf02342a4
f0103b9f:	c6 05 a5 42 23 f0 8e 	movb   $0x8e,0xf02342a5
f0103ba6:	c1 e8 10             	shr    $0x10,%eax
f0103ba9:	66 a3 a6 42 23 f0    	mov    %ax,0xf02342a6
    SETGATE(idt[T_TSS], 0, GD_KT, tss_handler, 0);
f0103baf:	b8 28 44 10 f0       	mov    $0xf0104428,%eax
f0103bb4:	66 a3 b0 42 23 f0    	mov    %ax,0xf02342b0
f0103bba:	66 c7 05 b2 42 23 f0 	movw   $0x8,0xf02342b2
f0103bc1:	08 00 
f0103bc3:	c6 05 b4 42 23 f0 00 	movb   $0x0,0xf02342b4
f0103bca:	c6 05 b5 42 23 f0 8e 	movb   $0x8e,0xf02342b5
f0103bd1:	c1 e8 10             	shr    $0x10,%eax
f0103bd4:	66 a3 b6 42 23 f0    	mov    %ax,0xf02342b6
    SETGATE(idt[T_SEGNP], 0, GD_KT, segnp_handler, 0);
f0103bda:	b8 2c 44 10 f0       	mov    $0xf010442c,%eax
f0103bdf:	66 a3 b8 42 23 f0    	mov    %ax,0xf02342b8
f0103be5:	66 c7 05 ba 42 23 f0 	movw   $0x8,0xf02342ba
f0103bec:	08 00 
f0103bee:	c6 05 bc 42 23 f0 00 	movb   $0x0,0xf02342bc
f0103bf5:	c6 05 bd 42 23 f0 8e 	movb   $0x8e,0xf02342bd
f0103bfc:	c1 e8 10             	shr    $0x10,%eax
f0103bff:	66 a3 be 42 23 f0    	mov    %ax,0xf02342be
    SETGATE(idt[T_STACK], 0, GD_KT, stack_handler, 0);
f0103c05:	b8 30 44 10 f0       	mov    $0xf0104430,%eax
f0103c0a:	66 a3 c0 42 23 f0    	mov    %ax,0xf02342c0
f0103c10:	66 c7 05 c2 42 23 f0 	movw   $0x8,0xf02342c2
f0103c17:	08 00 
f0103c19:	c6 05 c4 42 23 f0 00 	movb   $0x0,0xf02342c4
f0103c20:	c6 05 c5 42 23 f0 8e 	movb   $0x8e,0xf02342c5
f0103c27:	c1 e8 10             	shr    $0x10,%eax
f0103c2a:	66 a3 c6 42 23 f0    	mov    %ax,0xf02342c6
    SETGATE(idt[T_GPFLT], 0, GD_KT, gpflt_handler, 0);
f0103c30:	b8 34 44 10 f0       	mov    $0xf0104434,%eax
f0103c35:	66 a3 c8 42 23 f0    	mov    %ax,0xf02342c8
f0103c3b:	66 c7 05 ca 42 23 f0 	movw   $0x8,0xf02342ca
f0103c42:	08 00 
f0103c44:	c6 05 cc 42 23 f0 00 	movb   $0x0,0xf02342cc
f0103c4b:	c6 05 cd 42 23 f0 8e 	movb   $0x8e,0xf02342cd
f0103c52:	c1 e8 10             	shr    $0x10,%eax
f0103c55:	66 a3 ce 42 23 f0    	mov    %ax,0xf02342ce
    SETGATE(idt[T_PGFLT], 0, GD_KT, pgflt_handler, 0);
f0103c5b:	b8 38 44 10 f0       	mov    $0xf0104438,%eax
f0103c60:	66 a3 d0 42 23 f0    	mov    %ax,0xf02342d0
f0103c66:	66 c7 05 d2 42 23 f0 	movw   $0x8,0xf02342d2
f0103c6d:	08 00 
f0103c6f:	c6 05 d4 42 23 f0 00 	movb   $0x0,0xf02342d4
f0103c76:	c6 05 d5 42 23 f0 8e 	movb   $0x8e,0xf02342d5
f0103c7d:	c1 e8 10             	shr    $0x10,%eax
f0103c80:	66 a3 d6 42 23 f0    	mov    %ax,0xf02342d6
    SETGATE(idt[T_FPERR], 0, GD_KT, fperr_handler, 0);
f0103c86:	b8 3c 44 10 f0       	mov    $0xf010443c,%eax
f0103c8b:	66 a3 e0 42 23 f0    	mov    %ax,0xf02342e0
f0103c91:	66 c7 05 e2 42 23 f0 	movw   $0x8,0xf02342e2
f0103c98:	08 00 
f0103c9a:	c6 05 e4 42 23 f0 00 	movb   $0x0,0xf02342e4
f0103ca1:	c6 05 e5 42 23 f0 8e 	movb   $0x8e,0xf02342e5
f0103ca8:	c1 e8 10             	shr    $0x10,%eax
f0103cab:	66 a3 e6 42 23 f0    	mov    %ax,0xf02342e6
    SETGATE(idt[T_ALIGN], 0, GD_KT, align_handler, 0);
f0103cb1:	b8 42 44 10 f0       	mov    $0xf0104442,%eax
f0103cb6:	66 a3 e8 42 23 f0    	mov    %ax,0xf02342e8
f0103cbc:	66 c7 05 ea 42 23 f0 	movw   $0x8,0xf02342ea
f0103cc3:	08 00 
f0103cc5:	c6 05 ec 42 23 f0 00 	movb   $0x0,0xf02342ec
f0103ccc:	c6 05 ed 42 23 f0 8e 	movb   $0x8e,0xf02342ed
f0103cd3:	c1 e8 10             	shr    $0x10,%eax
f0103cd6:	66 a3 ee 42 23 f0    	mov    %ax,0xf02342ee
    SETGATE(idt[T_MCHK], 0, GD_KT, mchk_handler, 0);
f0103cdc:	b8 46 44 10 f0       	mov    $0xf0104446,%eax
f0103ce1:	66 a3 f0 42 23 f0    	mov    %ax,0xf02342f0
f0103ce7:	66 c7 05 f2 42 23 f0 	movw   $0x8,0xf02342f2
f0103cee:	08 00 
f0103cf0:	c6 05 f4 42 23 f0 00 	movb   $0x0,0xf02342f4
f0103cf7:	c6 05 f5 42 23 f0 8e 	movb   $0x8e,0xf02342f5
f0103cfe:	c1 e8 10             	shr    $0x10,%eax
f0103d01:	66 a3 f6 42 23 f0    	mov    %ax,0xf02342f6
    SETGATE(idt[T_SIMDERR], 0, GD_KT, simderr_handler, 0);
f0103d07:	b8 4c 44 10 f0       	mov    $0xf010444c,%eax
f0103d0c:	66 a3 f8 42 23 f0    	mov    %ax,0xf02342f8
f0103d12:	66 c7 05 fa 42 23 f0 	movw   $0x8,0xf02342fa
f0103d19:	08 00 
f0103d1b:	c6 05 fc 42 23 f0 00 	movb   $0x0,0xf02342fc
f0103d22:	c6 05 fd 42 23 f0 8e 	movb   $0x8e,0xf02342fd
f0103d29:	c1 e8 10             	shr    $0x10,%eax
f0103d2c:	66 a3 fe 42 23 f0    	mov    %ax,0xf02342fe
    SETGATE(idt[T_SYSCALL], 0, GD_KT, syscall_handler, 3);
f0103d32:	b8 52 44 10 f0       	mov    $0xf0104452,%eax
f0103d37:	66 a3 e0 43 23 f0    	mov    %ax,0xf02343e0
f0103d3d:	66 c7 05 e2 43 23 f0 	movw   $0x8,0xf02343e2
f0103d44:	08 00 
f0103d46:	c6 05 e4 43 23 f0 00 	movb   $0x0,0xf02343e4
f0103d4d:	c6 05 e5 43 23 f0 ee 	movb   $0xee,0xf02343e5
f0103d54:	c1 e8 10             	shr    $0x10,%eax
f0103d57:	66 a3 e6 43 23 f0    	mov    %ax,0xf02343e6
    SETGATE(idt[IRQ_OFFSET+IRQ_TIMER],0,GD_KT,timer_handler,3);
f0103d5d:	b8 58 44 10 f0       	mov    $0xf0104458,%eax
f0103d62:	66 a3 60 43 23 f0    	mov    %ax,0xf0234360
f0103d68:	66 c7 05 62 43 23 f0 	movw   $0x8,0xf0234362
f0103d6f:	08 00 
f0103d71:	c6 05 64 43 23 f0 00 	movb   $0x0,0xf0234364
f0103d78:	c6 05 65 43 23 f0 ee 	movb   $0xee,0xf0234365
f0103d7f:	c1 e8 10             	shr    $0x10,%eax
f0103d82:	66 a3 66 43 23 f0    	mov    %ax,0xf0234366
    SETGATE(idt[IRQ_OFFSET+IRQ_KBD],0,GD_KT,kbd_handler,3);
f0103d88:	b8 5e 44 10 f0       	mov    $0xf010445e,%eax
f0103d8d:	66 a3 68 43 23 f0    	mov    %ax,0xf0234368
f0103d93:	66 c7 05 6a 43 23 f0 	movw   $0x8,0xf023436a
f0103d9a:	08 00 
f0103d9c:	c6 05 6c 43 23 f0 00 	movb   $0x0,0xf023436c
f0103da3:	c6 05 6d 43 23 f0 ee 	movb   $0xee,0xf023436d
f0103daa:	c1 e8 10             	shr    $0x10,%eax
f0103dad:	66 a3 6e 43 23 f0    	mov    %ax,0xf023436e
    SETGATE(idt[IRQ_OFFSET+IRQ_SERIAL],0,GD_KT,serial_handler,3);
f0103db3:	b8 64 44 10 f0       	mov    $0xf0104464,%eax
f0103db8:	66 a3 80 43 23 f0    	mov    %ax,0xf0234380
f0103dbe:	66 c7 05 82 43 23 f0 	movw   $0x8,0xf0234382
f0103dc5:	08 00 
f0103dc7:	c6 05 84 43 23 f0 00 	movb   $0x0,0xf0234384
f0103dce:	c6 05 85 43 23 f0 ee 	movb   $0xee,0xf0234385
f0103dd5:	c1 e8 10             	shr    $0x10,%eax
f0103dd8:	66 a3 86 43 23 f0    	mov    %ax,0xf0234386
    SETGATE(idt[IRQ_OFFSET+IRQ_SPURIOUS],0,GD_KT,spurious_handler,3);
f0103dde:	b8 6a 44 10 f0       	mov    $0xf010446a,%eax
f0103de3:	66 a3 98 43 23 f0    	mov    %ax,0xf0234398
f0103de9:	66 c7 05 9a 43 23 f0 	movw   $0x8,0xf023439a
f0103df0:	08 00 
f0103df2:	c6 05 9c 43 23 f0 00 	movb   $0x0,0xf023439c
f0103df9:	c6 05 9d 43 23 f0 ee 	movb   $0xee,0xf023439d
f0103e00:	c1 e8 10             	shr    $0x10,%eax
f0103e03:	66 a3 9e 43 23 f0    	mov    %ax,0xf023439e
    SETGATE(idt[IRQ_OFFSET+IRQ_IDE],0,GD_KT,ide_handler,3);
f0103e09:	b8 70 44 10 f0       	mov    $0xf0104470,%eax
f0103e0e:	66 a3 d0 43 23 f0    	mov    %ax,0xf02343d0
f0103e14:	66 c7 05 d2 43 23 f0 	movw   $0x8,0xf02343d2
f0103e1b:	08 00 
f0103e1d:	c6 05 d4 43 23 f0 00 	movb   $0x0,0xf02343d4
f0103e24:	c6 05 d5 43 23 f0 ee 	movb   $0xee,0xf02343d5
f0103e2b:	c1 e8 10             	shr    $0x10,%eax
f0103e2e:	66 a3 d6 43 23 f0    	mov    %ax,0xf02343d6
    SETGATE(idt[IRQ_OFFSET+IRQ_ERROR],0,GD_KT,error_handler,3);
f0103e34:	b8 76 44 10 f0       	mov    $0xf0104476,%eax
f0103e39:	66 a3 f8 43 23 f0    	mov    %ax,0xf02343f8
f0103e3f:	66 c7 05 fa 43 23 f0 	movw   $0x8,0xf02343fa
f0103e46:	08 00 
f0103e48:	c6 05 fc 43 23 f0 00 	movb   $0x0,0xf02343fc
f0103e4f:	c6 05 fd 43 23 f0 ee 	movb   $0xee,0xf02343fd
f0103e56:	c1 e8 10             	shr    $0x10,%eax
f0103e59:	66 a3 fe 43 23 f0    	mov    %ax,0xf02343fe
	trap_init_percpu();
f0103e5f:	e8 f4 fa ff ff       	call   f0103958 <trap_init_percpu>
}
f0103e64:	c9                   	leave  
f0103e65:	c3                   	ret    

f0103e66 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103e66:	55                   	push   %ebp
f0103e67:	89 e5                	mov    %esp,%ebp
f0103e69:	53                   	push   %ebx
f0103e6a:	83 ec 0c             	sub    $0xc,%esp
f0103e6d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103e70:	ff 33                	pushl  (%ebx)
f0103e72:	68 64 78 10 f0       	push   $0xf0107864
f0103e77:	e8 c8 fa ff ff       	call   f0103944 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103e7c:	83 c4 08             	add    $0x8,%esp
f0103e7f:	ff 73 04             	pushl  0x4(%ebx)
f0103e82:	68 73 78 10 f0       	push   $0xf0107873
f0103e87:	e8 b8 fa ff ff       	call   f0103944 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103e8c:	83 c4 08             	add    $0x8,%esp
f0103e8f:	ff 73 08             	pushl  0x8(%ebx)
f0103e92:	68 82 78 10 f0       	push   $0xf0107882
f0103e97:	e8 a8 fa ff ff       	call   f0103944 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103e9c:	83 c4 08             	add    $0x8,%esp
f0103e9f:	ff 73 0c             	pushl  0xc(%ebx)
f0103ea2:	68 91 78 10 f0       	push   $0xf0107891
f0103ea7:	e8 98 fa ff ff       	call   f0103944 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103eac:	83 c4 08             	add    $0x8,%esp
f0103eaf:	ff 73 10             	pushl  0x10(%ebx)
f0103eb2:	68 a0 78 10 f0       	push   $0xf01078a0
f0103eb7:	e8 88 fa ff ff       	call   f0103944 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103ebc:	83 c4 08             	add    $0x8,%esp
f0103ebf:	ff 73 14             	pushl  0x14(%ebx)
f0103ec2:	68 af 78 10 f0       	push   $0xf01078af
f0103ec7:	e8 78 fa ff ff       	call   f0103944 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103ecc:	83 c4 08             	add    $0x8,%esp
f0103ecf:	ff 73 18             	pushl  0x18(%ebx)
f0103ed2:	68 be 78 10 f0       	push   $0xf01078be
f0103ed7:	e8 68 fa ff ff       	call   f0103944 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103edc:	83 c4 08             	add    $0x8,%esp
f0103edf:	ff 73 1c             	pushl  0x1c(%ebx)
f0103ee2:	68 cd 78 10 f0       	push   $0xf01078cd
f0103ee7:	e8 58 fa ff ff       	call   f0103944 <cprintf>
}
f0103eec:	83 c4 10             	add    $0x10,%esp
f0103eef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103ef2:	c9                   	leave  
f0103ef3:	c3                   	ret    

f0103ef4 <print_trapframe>:
{
f0103ef4:	55                   	push   %ebp
f0103ef5:	89 e5                	mov    %esp,%ebp
f0103ef7:	56                   	push   %esi
f0103ef8:	53                   	push   %ebx
f0103ef9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103efc:	e8 2a 20 00 00       	call   f0105f2b <cpunum>
f0103f01:	83 ec 04             	sub    $0x4,%esp
f0103f04:	50                   	push   %eax
f0103f05:	53                   	push   %ebx
f0103f06:	68 31 79 10 f0       	push   $0xf0107931
f0103f0b:	e8 34 fa ff ff       	call   f0103944 <cprintf>
	print_regs(&tf->tf_regs);
f0103f10:	89 1c 24             	mov    %ebx,(%esp)
f0103f13:	e8 4e ff ff ff       	call   f0103e66 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103f18:	83 c4 08             	add    $0x8,%esp
f0103f1b:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103f1f:	50                   	push   %eax
f0103f20:	68 4f 79 10 f0       	push   $0xf010794f
f0103f25:	e8 1a fa ff ff       	call   f0103944 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103f2a:	83 c4 08             	add    $0x8,%esp
f0103f2d:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103f31:	50                   	push   %eax
f0103f32:	68 62 79 10 f0       	push   $0xf0107962
f0103f37:	e8 08 fa ff ff       	call   f0103944 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103f3c:	8b 43 28             	mov    0x28(%ebx),%eax
	if (trapno < ARRAY_SIZE(excnames))
f0103f3f:	83 c4 10             	add    $0x10,%esp
f0103f42:	83 f8 13             	cmp    $0x13,%eax
f0103f45:	76 1f                	jbe    f0103f66 <print_trapframe+0x72>
		return "System call";
f0103f47:	ba dc 78 10 f0       	mov    $0xf01078dc,%edx
	if (trapno == T_SYSCALL)
f0103f4c:	83 f8 30             	cmp    $0x30,%eax
f0103f4f:	74 1c                	je     f0103f6d <print_trapframe+0x79>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103f51:	8d 50 e0             	lea    -0x20(%eax),%edx
	return "(unknown trap)";
f0103f54:	83 fa 10             	cmp    $0x10,%edx
f0103f57:	ba e8 78 10 f0       	mov    $0xf01078e8,%edx
f0103f5c:	b9 fb 78 10 f0       	mov    $0xf01078fb,%ecx
f0103f61:	0f 43 d1             	cmovae %ecx,%edx
f0103f64:	eb 07                	jmp    f0103f6d <print_trapframe+0x79>
		return excnames[trapno];
f0103f66:	8b 14 85 00 7c 10 f0 	mov    -0xfef8400(,%eax,4),%edx
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103f6d:	83 ec 04             	sub    $0x4,%esp
f0103f70:	52                   	push   %edx
f0103f71:	50                   	push   %eax
f0103f72:	68 75 79 10 f0       	push   $0xf0107975
f0103f77:	e8 c8 f9 ff ff       	call   f0103944 <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103f7c:	83 c4 10             	add    $0x10,%esp
f0103f7f:	39 1d 60 4a 23 f0    	cmp    %ebx,0xf0234a60
f0103f85:	0f 84 a6 00 00 00    	je     f0104031 <print_trapframe+0x13d>
	cprintf("  err  0x%08x", tf->tf_err);
f0103f8b:	83 ec 08             	sub    $0x8,%esp
f0103f8e:	ff 73 2c             	pushl  0x2c(%ebx)
f0103f91:	68 96 79 10 f0       	push   $0xf0107996
f0103f96:	e8 a9 f9 ff ff       	call   f0103944 <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f0103f9b:	83 c4 10             	add    $0x10,%esp
f0103f9e:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103fa2:	0f 85 ac 00 00 00    	jne    f0104054 <print_trapframe+0x160>
			tf->tf_err & 1 ? "protection" : "not-present");
f0103fa8:	8b 43 2c             	mov    0x2c(%ebx),%eax
		cprintf(" [%s, %s, %s]\n",
f0103fab:	89 c2                	mov    %eax,%edx
f0103fad:	83 e2 01             	and    $0x1,%edx
f0103fb0:	b9 0a 79 10 f0       	mov    $0xf010790a,%ecx
f0103fb5:	ba 15 79 10 f0       	mov    $0xf0107915,%edx
f0103fba:	0f 44 ca             	cmove  %edx,%ecx
f0103fbd:	89 c2                	mov    %eax,%edx
f0103fbf:	83 e2 02             	and    $0x2,%edx
f0103fc2:	be 21 79 10 f0       	mov    $0xf0107921,%esi
f0103fc7:	ba 27 79 10 f0       	mov    $0xf0107927,%edx
f0103fcc:	0f 45 d6             	cmovne %esi,%edx
f0103fcf:	83 e0 04             	and    $0x4,%eax
f0103fd2:	b8 2c 79 10 f0       	mov    $0xf010792c,%eax
f0103fd7:	be 7c 7a 10 f0       	mov    $0xf0107a7c,%esi
f0103fdc:	0f 44 c6             	cmove  %esi,%eax
f0103fdf:	51                   	push   %ecx
f0103fe0:	52                   	push   %edx
f0103fe1:	50                   	push   %eax
f0103fe2:	68 a4 79 10 f0       	push   $0xf01079a4
f0103fe7:	e8 58 f9 ff ff       	call   f0103944 <cprintf>
f0103fec:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103fef:	83 ec 08             	sub    $0x8,%esp
f0103ff2:	ff 73 30             	pushl  0x30(%ebx)
f0103ff5:	68 b3 79 10 f0       	push   $0xf01079b3
f0103ffa:	e8 45 f9 ff ff       	call   f0103944 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103fff:	83 c4 08             	add    $0x8,%esp
f0104002:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0104006:	50                   	push   %eax
f0104007:	68 c2 79 10 f0       	push   $0xf01079c2
f010400c:	e8 33 f9 ff ff       	call   f0103944 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0104011:	83 c4 08             	add    $0x8,%esp
f0104014:	ff 73 38             	pushl  0x38(%ebx)
f0104017:	68 d5 79 10 f0       	push   $0xf01079d5
f010401c:	e8 23 f9 ff ff       	call   f0103944 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0104021:	83 c4 10             	add    $0x10,%esp
f0104024:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104028:	75 3c                	jne    f0104066 <print_trapframe+0x172>
}
f010402a:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010402d:	5b                   	pop    %ebx
f010402e:	5e                   	pop    %esi
f010402f:	5d                   	pop    %ebp
f0104030:	c3                   	ret    
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104031:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104035:	0f 85 50 ff ff ff    	jne    f0103f8b <print_trapframe+0x97>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f010403b:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f010403e:	83 ec 08             	sub    $0x8,%esp
f0104041:	50                   	push   %eax
f0104042:	68 87 79 10 f0       	push   $0xf0107987
f0104047:	e8 f8 f8 ff ff       	call   f0103944 <cprintf>
f010404c:	83 c4 10             	add    $0x10,%esp
f010404f:	e9 37 ff ff ff       	jmp    f0103f8b <print_trapframe+0x97>
		cprintf("\n");
f0104054:	83 ec 0c             	sub    $0xc,%esp
f0104057:	68 c9 68 10 f0       	push   $0xf01068c9
f010405c:	e8 e3 f8 ff ff       	call   f0103944 <cprintf>
f0104061:	83 c4 10             	add    $0x10,%esp
f0104064:	eb 89                	jmp    f0103fef <print_trapframe+0xfb>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0104066:	83 ec 08             	sub    $0x8,%esp
f0104069:	ff 73 3c             	pushl  0x3c(%ebx)
f010406c:	68 e4 79 10 f0       	push   $0xf01079e4
f0104071:	e8 ce f8 ff ff       	call   f0103944 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0104076:	83 c4 08             	add    $0x8,%esp
f0104079:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f010407d:	50                   	push   %eax
f010407e:	68 f3 79 10 f0       	push   $0xf01079f3
f0104083:	e8 bc f8 ff ff       	call   f0103944 <cprintf>
f0104088:	83 c4 10             	add    $0x10,%esp
}
f010408b:	eb 9d                	jmp    f010402a <print_trapframe+0x136>

f010408d <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f010408d:	55                   	push   %ebp
f010408e:	89 e5                	mov    %esp,%ebp
f0104090:	57                   	push   %edi
f0104091:	56                   	push   %esi
f0104092:	53                   	push   %ebx
f0104093:	83 ec 0c             	sub    $0xc,%esp
f0104096:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104099:	0f 20 d6             	mov    %cr2,%esi

	// Handle kernel-mode page faults.
        
	// LAB 3: Your code here.
//	cprintf("tf->tf_cs= %08x\n",tf->tf_cs);
        if((tf->tf_cs & 0x3) == 0){
f010409c:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01040a0:	74 5d                	je     f01040ff <page_fault_handler+0x72>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
        struct UTrapframe *utf;

	if(curenv->env_pgfault_upcall){
f01040a2:	e8 84 1e 00 00       	call   f0105f2b <cpunum>
f01040a7:	6b c0 74             	imul   $0x74,%eax,%eax
f01040aa:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f01040b0:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f01040b4:	75 60                	jne    f0104116 <page_fault_handler+0x89>
        

         
     	
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01040b6:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f01040b9:	e8 6d 1e 00 00       	call   f0105f2b <cpunum>
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01040be:	57                   	push   %edi
f01040bf:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f01040c0:	6b c0 74             	imul   $0x74,%eax,%eax
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01040c3:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f01040c9:	ff 70 48             	pushl  0x48(%eax)
f01040cc:	68 c8 7b 10 f0       	push   $0xf0107bc8
f01040d1:	e8 6e f8 ff ff       	call   f0103944 <cprintf>
	print_trapframe(tf);
f01040d6:	89 1c 24             	mov    %ebx,(%esp)
f01040d9:	e8 16 fe ff ff       	call   f0103ef4 <print_trapframe>
	env_destroy(curenv);
f01040de:	e8 48 1e 00 00       	call   f0105f2b <cpunum>
f01040e3:	83 c4 04             	add    $0x4,%esp
f01040e6:	6b c0 74             	imul   $0x74,%eax,%eax
f01040e9:	ff b0 28 50 23 f0    	pushl  -0xfdcafd8(%eax)
f01040ef:	e8 54 f5 ff ff       	call   f0103648 <env_destroy>
}
f01040f4:	83 c4 10             	add    $0x10,%esp
f01040f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01040fa:	5b                   	pop    %ebx
f01040fb:	5e                   	pop    %esi
f01040fc:	5f                   	pop    %edi
f01040fd:	5d                   	pop    %ebp
f01040fe:	c3                   	ret    
	  panic("page fault in kernel node\n");
f01040ff:	83 ec 04             	sub    $0x4,%esp
f0104102:	68 06 7a 10 f0       	push   $0xf0107a06
f0104107:	68 72 01 00 00       	push   $0x172
f010410c:	68 21 7a 10 f0       	push   $0xf0107a21
f0104111:	e8 2a bf ff ff       	call   f0100040 <_panic>
	  if(tf->tf_esp>=UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP)
f0104116:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104119:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
		  utf = (struct UTrapframe *)(UXSTACKTOP-sizeof(struct UTrapframe));
f010411f:	bf cc ff bf ee       	mov    $0xeebfffcc,%edi
	  if(tf->tf_esp>=UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP)
f0104124:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f010412a:	77 05                	ja     f0104131 <page_fault_handler+0xa4>
		  utf = (struct UTrapframe *)(tf->tf_esp-4-sizeof(struct UTrapframe));
f010412c:	83 e8 38             	sub    $0x38,%eax
f010412f:	89 c7                	mov    %eax,%edi
	  user_mem_assert(curenv,(void *)utf,sizeof(struct UTrapframe),PTE_U|PTE_W|PTE_P);
f0104131:	e8 f5 1d 00 00       	call   f0105f2b <cpunum>
f0104136:	6a 07                	push   $0x7
f0104138:	6a 34                	push   $0x34
f010413a:	57                   	push   %edi
f010413b:	6b c0 74             	imul   $0x74,%eax,%eax
f010413e:	ff b0 28 50 23 f0    	pushl  -0xfdcafd8(%eax)
f0104144:	e8 31 ee ff ff       	call   f0102f7a <user_mem_assert>
	  utf->utf_fault_va = fault_va;
f0104149:	89 fa                	mov    %edi,%edx
f010414b:	89 37                	mov    %esi,(%edi)
	  utf->utf_err = tf->tf_trapno;
f010414d:	8b 43 28             	mov    0x28(%ebx),%eax
f0104150:	89 47 04             	mov    %eax,0x4(%edi)
	  utf->utf_regs = tf->tf_regs;
f0104153:	8d 7f 08             	lea    0x8(%edi),%edi
f0104156:	b9 08 00 00 00       	mov    $0x8,%ecx
f010415b:	89 de                	mov    %ebx,%esi
f010415d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	  utf->utf_eip = tf->tf_eip;
f010415f:	8b 43 30             	mov    0x30(%ebx),%eax
f0104162:	89 42 28             	mov    %eax,0x28(%edx)
	  utf->utf_eflags = tf->tf_eflags;
f0104165:	8b 43 38             	mov    0x38(%ebx),%eax
f0104168:	89 d7                	mov    %edx,%edi
f010416a:	89 42 2c             	mov    %eax,0x2c(%edx)
	  utf->utf_esp = tf->tf_esp;
f010416d:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104170:	89 42 30             	mov    %eax,0x30(%edx)
	  tf->tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
f0104173:	e8 b3 1d 00 00       	call   f0105f2b <cpunum>
f0104178:	6b c0 74             	imul   $0x74,%eax,%eax
f010417b:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f0104181:	8b 40 64             	mov    0x64(%eax),%eax
f0104184:	89 43 30             	mov    %eax,0x30(%ebx)
	  tf->tf_esp = (uintptr_t)utf;
f0104187:	89 7b 3c             	mov    %edi,0x3c(%ebx)
	  env_run(curenv);
f010418a:	e8 9c 1d 00 00       	call   f0105f2b <cpunum>
f010418f:	83 c4 04             	add    $0x4,%esp
f0104192:	6b c0 74             	imul   $0x74,%eax,%eax
f0104195:	ff b0 28 50 23 f0    	pushl  -0xfdcafd8(%eax)
f010419b:	e8 47 f5 ff ff       	call   f01036e7 <env_run>

f01041a0 <trap>:
{
f01041a0:	55                   	push   %ebp
f01041a1:	89 e5                	mov    %esp,%ebp
f01041a3:	57                   	push   %edi
f01041a4:	56                   	push   %esi
f01041a5:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::: "cc");
f01041a8:	fc                   	cld    
	if (panicstr)
f01041a9:	83 3d 80 4e 23 f0 00 	cmpl   $0x0,0xf0234e80
f01041b0:	74 01                	je     f01041b3 <trap+0x13>
		asm volatile("hlt");
f01041b2:	f4                   	hlt    
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f01041b3:	e8 73 1d 00 00       	call   f0105f2b <cpunum>
f01041b8:	6b d0 74             	imul   $0x74,%eax,%edx
f01041bb:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f01041be:	b8 01 00 00 00       	mov    $0x1,%eax
f01041c3:	f0 87 82 20 50 23 f0 	lock xchg %eax,-0xfdcafe0(%edx)
f01041ca:	83 f8 02             	cmp    $0x2,%eax
f01041cd:	0f 84 b0 00 00 00    	je     f0104283 <trap+0xe3>
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f01041d3:	9c                   	pushf  
f01041d4:	58                   	pop    %eax
	assert(!(read_eflags() & FL_IF));
f01041d5:	f6 c4 02             	test   $0x2,%ah
f01041d8:	0f 85 ba 00 00 00    	jne    f0104298 <trap+0xf8>
	if ((tf->tf_cs & 3) == 3) {
f01041de:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01041e2:	83 e0 03             	and    $0x3,%eax
f01041e5:	66 83 f8 03          	cmp    $0x3,%ax
f01041e9:	0f 84 c2 00 00 00    	je     f01042b1 <trap+0x111>
	last_tf = tf;
f01041ef:	89 35 60 4a 23 f0    	mov    %esi,0xf0234a60
	 if(tf->tf_trapno == T_PGFLT){
f01041f5:	8b 46 28             	mov    0x28(%esi),%eax
f01041f8:	83 f8 0e             	cmp    $0xe,%eax
f01041fb:	0f 84 55 01 00 00    	je     f0104356 <trap+0x1b6>
        if(tf->tf_trapno==T_BRKPT){
f0104201:	83 f8 03             	cmp    $0x3,%eax
f0104204:	0f 84 5d 01 00 00    	je     f0104367 <trap+0x1c7>
        if(tf->tf_trapno == T_SYSCALL){
f010420a:	83 f8 30             	cmp    $0x30,%eax
f010420d:	0f 84 65 01 00 00    	je     f0104378 <trap+0x1d8>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104213:	83 f8 27             	cmp    $0x27,%eax
f0104216:	0f 84 80 01 00 00    	je     f010439c <trap+0x1fc>
        if(tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER){
f010421c:	83 f8 20             	cmp    $0x20,%eax
f010421f:	0f 84 94 01 00 00    	je     f01043b9 <trap+0x219>
        	print_trapframe(tf);
f0104225:	83 ec 0c             	sub    $0xc,%esp
f0104228:	56                   	push   %esi
f0104229:	e8 c6 fc ff ff       	call   f0103ef4 <print_trapframe>
        	if (tf->tf_cs == GD_KT)
f010422e:	83 c4 10             	add    $0x10,%esp
f0104231:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104236:	0f 84 87 01 00 00    	je     f01043c3 <trap+0x223>
		env_destroy(curenv);
f010423c:	e8 ea 1c 00 00       	call   f0105f2b <cpunum>
f0104241:	83 ec 0c             	sub    $0xc,%esp
f0104244:	6b c0 74             	imul   $0x74,%eax,%eax
f0104247:	ff b0 28 50 23 f0    	pushl  -0xfdcafd8(%eax)
f010424d:	e8 f6 f3 ff ff       	call   f0103648 <env_destroy>
f0104252:	83 c4 10             	add    $0x10,%esp
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104255:	e8 d1 1c 00 00       	call   f0105f2b <cpunum>
f010425a:	6b c0 74             	imul   $0x74,%eax,%eax
f010425d:	83 b8 28 50 23 f0 00 	cmpl   $0x0,-0xfdcafd8(%eax)
f0104264:	74 18                	je     f010427e <trap+0xde>
f0104266:	e8 c0 1c 00 00       	call   f0105f2b <cpunum>
f010426b:	6b c0 74             	imul   $0x74,%eax,%eax
f010426e:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f0104274:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104278:	0f 84 5c 01 00 00    	je     f01043da <trap+0x23a>
		sched_yield();
f010427e:	e8 dd 02 00 00       	call   f0104560 <sched_yield>
	spin_lock(&kernel_lock);
f0104283:	83 ec 0c             	sub    $0xc,%esp
f0104286:	68 c0 23 12 f0       	push   $0xf01223c0
f010428b:	e8 0b 1f 00 00       	call   f010619b <spin_lock>
f0104290:	83 c4 10             	add    $0x10,%esp
f0104293:	e9 3b ff ff ff       	jmp    f01041d3 <trap+0x33>
	assert(!(read_eflags() & FL_IF));
f0104298:	68 2d 7a 10 f0       	push   $0xf0107a2d
f010429d:	68 6f 74 10 f0       	push   $0xf010746f
f01042a2:	68 3c 01 00 00       	push   $0x13c
f01042a7:	68 21 7a 10 f0       	push   $0xf0107a21
f01042ac:	e8 8f bd ff ff       	call   f0100040 <_panic>
f01042b1:	83 ec 0c             	sub    $0xc,%esp
f01042b4:	68 c0 23 12 f0       	push   $0xf01223c0
f01042b9:	e8 dd 1e 00 00       	call   f010619b <spin_lock>
		assert(curenv);
f01042be:	e8 68 1c 00 00       	call   f0105f2b <cpunum>
f01042c3:	6b c0 74             	imul   $0x74,%eax,%eax
f01042c6:	83 c4 10             	add    $0x10,%esp
f01042c9:	83 b8 28 50 23 f0 00 	cmpl   $0x0,-0xfdcafd8(%eax)
f01042d0:	74 3e                	je     f0104310 <trap+0x170>
		if (curenv->env_status == ENV_DYING) {
f01042d2:	e8 54 1c 00 00       	call   f0105f2b <cpunum>
f01042d7:	6b c0 74             	imul   $0x74,%eax,%eax
f01042da:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f01042e0:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01042e4:	74 43                	je     f0104329 <trap+0x189>
		curenv->env_tf = *tf;
f01042e6:	e8 40 1c 00 00       	call   f0105f2b <cpunum>
f01042eb:	6b c0 74             	imul   $0x74,%eax,%eax
f01042ee:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f01042f4:	b9 11 00 00 00       	mov    $0x11,%ecx
f01042f9:	89 c7                	mov    %eax,%edi
f01042fb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f01042fd:	e8 29 1c 00 00       	call   f0105f2b <cpunum>
f0104302:	6b c0 74             	imul   $0x74,%eax,%eax
f0104305:	8b b0 28 50 23 f0    	mov    -0xfdcafd8(%eax),%esi
f010430b:	e9 df fe ff ff       	jmp    f01041ef <trap+0x4f>
		assert(curenv);
f0104310:	68 46 7a 10 f0       	push   $0xf0107a46
f0104315:	68 6f 74 10 f0       	push   $0xf010746f
f010431a:	68 44 01 00 00       	push   $0x144
f010431f:	68 21 7a 10 f0       	push   $0xf0107a21
f0104324:	e8 17 bd ff ff       	call   f0100040 <_panic>
			env_free(curenv);
f0104329:	e8 fd 1b 00 00       	call   f0105f2b <cpunum>
f010432e:	83 ec 0c             	sub    $0xc,%esp
f0104331:	6b c0 74             	imul   $0x74,%eax,%eax
f0104334:	ff b0 28 50 23 f0    	pushl  -0xfdcafd8(%eax)
f010433a:	e8 1b f1 ff ff       	call   f010345a <env_free>
			curenv = NULL;
f010433f:	e8 e7 1b 00 00       	call   f0105f2b <cpunum>
f0104344:	6b c0 74             	imul   $0x74,%eax,%eax
f0104347:	c7 80 28 50 23 f0 00 	movl   $0x0,-0xfdcafd8(%eax)
f010434e:	00 00 00 
			sched_yield();
f0104351:	e8 0a 02 00 00       	call   f0104560 <sched_yield>
           page_fault_handler(tf);
f0104356:	83 ec 0c             	sub    $0xc,%esp
f0104359:	56                   	push   %esi
f010435a:	e8 2e fd ff ff       	call   f010408d <page_fault_handler>
f010435f:	83 c4 10             	add    $0x10,%esp
f0104362:	e9 ee fe ff ff       	jmp    f0104255 <trap+0xb5>
          monitor(tf);
f0104367:	83 ec 0c             	sub    $0xc,%esp
f010436a:	56                   	push   %esi
f010436b:	e8 b5 c5 ff ff       	call   f0100925 <monitor>
f0104370:	83 c4 10             	add    $0x10,%esp
f0104373:	e9 dd fe ff ff       	jmp    f0104255 <trap+0xb5>
           ret = syscall(
f0104378:	83 ec 08             	sub    $0x8,%esp
f010437b:	ff 76 04             	pushl  0x4(%esi)
f010437e:	ff 36                	pushl  (%esi)
f0104380:	ff 76 10             	pushl  0x10(%esi)
f0104383:	ff 76 18             	pushl  0x18(%esi)
f0104386:	ff 76 14             	pushl  0x14(%esi)
f0104389:	ff 76 1c             	pushl  0x1c(%esi)
f010438c:	e8 66 02 00 00       	call   f01045f7 <syscall>
           tf->tf_regs.reg_eax = ret;
f0104391:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104394:	83 c4 20             	add    $0x20,%esp
f0104397:	e9 b9 fe ff ff       	jmp    f0104255 <trap+0xb5>
		cprintf("Spurious interrupt on irq 7\n");
f010439c:	83 ec 0c             	sub    $0xc,%esp
f010439f:	68 4d 7a 10 f0       	push   $0xf0107a4d
f01043a4:	e8 9b f5 ff ff       	call   f0103944 <cprintf>
		print_trapframe(tf);
f01043a9:	89 34 24             	mov    %esi,(%esp)
f01043ac:	e8 43 fb ff ff       	call   f0103ef4 <print_trapframe>
f01043b1:	83 c4 10             	add    $0x10,%esp
f01043b4:	e9 9c fe ff ff       	jmp    f0104255 <trap+0xb5>
	        lapic_eoi();
f01043b9:	e8 b9 1c 00 00       	call   f0106077 <lapic_eoi>
		sched_yield();
f01043be:	e8 9d 01 00 00       	call   f0104560 <sched_yield>
		panic("unhandled trap in kernel");
f01043c3:	83 ec 04             	sub    $0x4,%esp
f01043c6:	68 6a 7a 10 f0       	push   $0xf0107a6a
f01043cb:	68 22 01 00 00       	push   $0x122
f01043d0:	68 21 7a 10 f0       	push   $0xf0107a21
f01043d5:	e8 66 bc ff ff       	call   f0100040 <_panic>
		env_run(curenv);
f01043da:	e8 4c 1b 00 00       	call   f0105f2b <cpunum>
f01043df:	83 ec 0c             	sub    $0xc,%esp
f01043e2:	6b c0 74             	imul   $0x74,%eax,%eax
f01043e5:	ff b0 28 50 23 f0    	pushl  -0xfdcafd8(%eax)
f01043eb:	e8 f7 f2 ff ff       	call   f01036e7 <env_run>

f01043f0 <divide_handler>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(divide_handler,T_DIVIDE);
f01043f0:	6a 00                	push   $0x0
f01043f2:	6a 00                	push   $0x0
f01043f4:	e9 83 00 00 00       	jmp    f010447c <_alltraps>
f01043f9:	90                   	nop

f01043fa <debug_handler>:
TRAPHANDLER_NOEC(debug_handler,T_DEBUG);
f01043fa:	6a 00                	push   $0x0
f01043fc:	6a 01                	push   $0x1
f01043fe:	eb 7c                	jmp    f010447c <_alltraps>

f0104400 <nmi_handler>:
TRAPHANDLER_NOEC(nmi_handler,T_NMI);
f0104400:	6a 00                	push   $0x0
f0104402:	6a 02                	push   $0x2
f0104404:	eb 76                	jmp    f010447c <_alltraps>

f0104406 <brkpt_handler>:
TRAPHANDLER_NOEC(brkpt_handler,T_BRKPT);
f0104406:	6a 00                	push   $0x0
f0104408:	6a 03                	push   $0x3
f010440a:	eb 70                	jmp    f010447c <_alltraps>

f010440c <oflow_handler>:
TRAPHANDLER_NOEC(oflow_handler,T_OFLOW);
f010440c:	6a 00                	push   $0x0
f010440e:	6a 04                	push   $0x4
f0104410:	eb 6a                	jmp    f010447c <_alltraps>

f0104412 <bound_handler>:
TRAPHANDLER_NOEC(bound_handler,T_BOUND);
f0104412:	6a 00                	push   $0x0
f0104414:	6a 05                	push   $0x5
f0104416:	eb 64                	jmp    f010447c <_alltraps>

f0104418 <illop_handler>:
TRAPHANDLER_NOEC(illop_handler,T_ILLOP);
f0104418:	6a 00                	push   $0x0
f010441a:	6a 06                	push   $0x6
f010441c:	eb 5e                	jmp    f010447c <_alltraps>

f010441e <device_handler>:
TRAPHANDLER_NOEC(device_handler,T_DEVICE);
f010441e:	6a 00                	push   $0x0
f0104420:	6a 07                	push   $0x7
f0104422:	eb 58                	jmp    f010447c <_alltraps>

f0104424 <dblflt_handler>:
TRAPHANDLER(dblflt_handler,T_DBLFLT);
f0104424:	6a 08                	push   $0x8
f0104426:	eb 54                	jmp    f010447c <_alltraps>

f0104428 <tss_handler>:
TRAPHANDLER(tss_handler,T_TSS);
f0104428:	6a 0a                	push   $0xa
f010442a:	eb 50                	jmp    f010447c <_alltraps>

f010442c <segnp_handler>:
TRAPHANDLER(segnp_handler,T_SEGNP);
f010442c:	6a 0b                	push   $0xb
f010442e:	eb 4c                	jmp    f010447c <_alltraps>

f0104430 <stack_handler>:
TRAPHANDLER(stack_handler,T_STACK);
f0104430:	6a 0c                	push   $0xc
f0104432:	eb 48                	jmp    f010447c <_alltraps>

f0104434 <gpflt_handler>:
TRAPHANDLER(gpflt_handler,T_GPFLT);
f0104434:	6a 0d                	push   $0xd
f0104436:	eb 44                	jmp    f010447c <_alltraps>

f0104438 <pgflt_handler>:
TRAPHANDLER(pgflt_handler,T_PGFLT);
f0104438:	6a 0e                	push   $0xe
f010443a:	eb 40                	jmp    f010447c <_alltraps>

f010443c <fperr_handler>:
TRAPHANDLER_NOEC(fperr_handler,T_FPERR);
f010443c:	6a 00                	push   $0x0
f010443e:	6a 10                	push   $0x10
f0104440:	eb 3a                	jmp    f010447c <_alltraps>

f0104442 <align_handler>:
TRAPHANDLER(align_handler,T_ALIGN);
f0104442:	6a 11                	push   $0x11
f0104444:	eb 36                	jmp    f010447c <_alltraps>

f0104446 <mchk_handler>:
TRAPHANDLER_NOEC(mchk_handler,T_MCHK);
f0104446:	6a 00                	push   $0x0
f0104448:	6a 12                	push   $0x12
f010444a:	eb 30                	jmp    f010447c <_alltraps>

f010444c <simderr_handler>:
TRAPHANDLER_NOEC(simderr_handler,T_SIMDERR);
f010444c:	6a 00                	push   $0x0
f010444e:	6a 13                	push   $0x13
f0104450:	eb 2a                	jmp    f010447c <_alltraps>

f0104452 <syscall_handler>:
TRAPHANDLER_NOEC(syscall_handler,T_SYSCALL);
f0104452:	6a 00                	push   $0x0
f0104454:	6a 30                	push   $0x30
f0104456:	eb 24                	jmp    f010447c <_alltraps>

f0104458 <timer_handler>:

TRAPHANDLER_NOEC(timer_handler,IRQ_OFFSET+IRQ_TIMER);
f0104458:	6a 00                	push   $0x0
f010445a:	6a 20                	push   $0x20
f010445c:	eb 1e                	jmp    f010447c <_alltraps>

f010445e <kbd_handler>:
TRAPHANDLER_NOEC(kbd_handler,IRQ_OFFSET+IRQ_KBD);
f010445e:	6a 00                	push   $0x0
f0104460:	6a 21                	push   $0x21
f0104462:	eb 18                	jmp    f010447c <_alltraps>

f0104464 <serial_handler>:
TRAPHANDLER_NOEC(serial_handler,IRQ_OFFSET+IRQ_SERIAL);
f0104464:	6a 00                	push   $0x0
f0104466:	6a 24                	push   $0x24
f0104468:	eb 12                	jmp    f010447c <_alltraps>

f010446a <spurious_handler>:
TRAPHANDLER_NOEC(spurious_handler,IRQ_OFFSET+IRQ_SPURIOUS);
f010446a:	6a 00                	push   $0x0
f010446c:	6a 27                	push   $0x27
f010446e:	eb 0c                	jmp    f010447c <_alltraps>

f0104470 <ide_handler>:
TRAPHANDLER_NOEC(ide_handler,IRQ_OFFSET+IRQ_IDE);
f0104470:	6a 00                	push   $0x0
f0104472:	6a 2e                	push   $0x2e
f0104474:	eb 06                	jmp    f010447c <_alltraps>

f0104476 <error_handler>:
TRAPHANDLER_NOEC(error_handler,IRQ_OFFSET+IRQ_ERROR);
f0104476:	6a 00                	push   $0x0
f0104478:	6a 33                	push   $0x33
f010447a:	eb 00                	jmp    f010447c <_alltraps>

f010447c <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
pushl %ds
f010447c:	1e                   	push   %ds
pushl %es
f010447d:	06                   	push   %es
pushal
f010447e:	60                   	pusha  

movl $GD_KD, %eax
f010447f:	b8 10 00 00 00       	mov    $0x10,%eax
movl %eax, %ds
f0104484:	8e d8                	mov    %eax,%ds
movl %eax, %es
f0104486:	8e c0                	mov    %eax,%es

pushl %esp
f0104488:	54                   	push   %esp

call trap     
f0104489:	e8 12 fd ff ff       	call   f01041a0 <trap>

f010448e <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f010448e:	55                   	push   %ebp
f010448f:	89 e5                	mov    %esp,%ebp
f0104491:	83 ec 08             	sub    $0x8,%esp
f0104494:	a1 44 42 23 f0       	mov    0xf0234244,%eax
f0104499:	83 c0 54             	add    $0x54,%eax
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f010449c:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f01044a1:	8b 10                	mov    (%eax),%edx
f01044a3:	83 ea 01             	sub    $0x1,%edx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f01044a6:	83 fa 02             	cmp    $0x2,%edx
f01044a9:	76 2d                	jbe    f01044d8 <sched_halt+0x4a>
	for (i = 0; i < NENV; i++) {
f01044ab:	83 c1 01             	add    $0x1,%ecx
f01044ae:	83 c0 7c             	add    $0x7c,%eax
f01044b1:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f01044b7:	75 e8                	jne    f01044a1 <sched_halt+0x13>
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
		cprintf("No runnable environments in the system!\n");
f01044b9:	83 ec 0c             	sub    $0xc,%esp
f01044bc:	68 50 7c 10 f0       	push   $0xf0107c50
f01044c1:	e8 7e f4 ff ff       	call   f0103944 <cprintf>
f01044c6:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f01044c9:	83 ec 0c             	sub    $0xc,%esp
f01044cc:	6a 00                	push   $0x0
f01044ce:	e8 52 c4 ff ff       	call   f0100925 <monitor>
f01044d3:	83 c4 10             	add    $0x10,%esp
f01044d6:	eb f1                	jmp    f01044c9 <sched_halt+0x3b>
	if (i == NENV) {
f01044d8:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f01044de:	74 d9                	je     f01044b9 <sched_halt+0x2b>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f01044e0:	e8 46 1a 00 00       	call   f0105f2b <cpunum>
f01044e5:	6b c0 74             	imul   $0x74,%eax,%eax
f01044e8:	c7 80 28 50 23 f0 00 	movl   $0x0,-0xfdcafd8(%eax)
f01044ef:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f01044f2:	a1 8c 4e 23 f0       	mov    0xf0234e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01044f7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01044fc:	76 50                	jbe    f010454e <sched_halt+0xc0>
	return (physaddr_t)kva - KERNBASE;
f01044fe:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0104503:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104506:	e8 20 1a 00 00       	call   f0105f2b <cpunum>
f010450b:	6b d0 74             	imul   $0x74,%eax,%edx
f010450e:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f0104511:	b8 02 00 00 00       	mov    $0x2,%eax
f0104516:	f0 87 82 20 50 23 f0 	lock xchg %eax,-0xfdcafe0(%edx)
	spin_unlock(&kernel_lock);
f010451d:	83 ec 0c             	sub    $0xc,%esp
f0104520:	68 c0 23 12 f0       	push   $0xf01223c0
f0104525:	e8 0e 1d 00 00       	call   f0106238 <spin_unlock>
	asm volatile("pause");
f010452a:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f010452c:	e8 fa 19 00 00       	call   f0105f2b <cpunum>
f0104531:	6b c0 74             	imul   $0x74,%eax,%eax
	asm volatile (
f0104534:	8b 80 30 50 23 f0    	mov    -0xfdcafd0(%eax),%eax
f010453a:	bd 00 00 00 00       	mov    $0x0,%ebp
f010453f:	89 c4                	mov    %eax,%esp
f0104541:	6a 00                	push   $0x0
f0104543:	6a 00                	push   $0x0
f0104545:	fb                   	sti    
f0104546:	f4                   	hlt    
f0104547:	eb fd                	jmp    f0104546 <sched_halt+0xb8>
}
f0104549:	83 c4 10             	add    $0x10,%esp
f010454c:	c9                   	leave  
f010454d:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010454e:	50                   	push   %eax
f010454f:	68 a8 65 10 f0       	push   $0xf01065a8
f0104554:	6a 4d                	push   $0x4d
f0104556:	68 79 7c 10 f0       	push   $0xf0107c79
f010455b:	e8 e0 ba ff ff       	call   f0100040 <_panic>

f0104560 <sched_yield>:
{
f0104560:	55                   	push   %ebp
f0104561:	89 e5                	mov    %esp,%ebp
f0104563:	57                   	push   %edi
f0104564:	56                   	push   %esi
f0104565:	53                   	push   %ebx
f0104566:	83 ec 0c             	sub    $0xc,%esp
	idle = thiscpu->cpu_env;
f0104569:	e8 bd 19 00 00       	call   f0105f2b <cpunum>
f010456e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104571:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
	int curenv_id=0;
f0104577:	ba 00 00 00 00       	mov    $0x0,%edx
	if(idle!=NULL){
f010457c:	85 c0                	test   %eax,%eax
f010457e:	74 09                	je     f0104589 <sched_yield+0x29>
	 curenv_id = ENVX(idle->env_id);
f0104580:	8b 50 48             	mov    0x48(%eax),%edx
f0104583:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
	 if(envs[j].env_status == ENV_RUNNABLE){
f0104589:	8b 0d 44 42 23 f0    	mov    0xf0234244,%ecx
f010458f:	89 d6                	mov    %edx,%esi
f0104591:	8d 9a 00 04 00 00    	lea    0x400(%edx),%ebx
	 j = (curenv_id+i)%NENV;
f0104597:	89 d7                	mov    %edx,%edi
f0104599:	c1 ff 1f             	sar    $0x1f,%edi
f010459c:	c1 ef 16             	shr    $0x16,%edi
f010459f:	8d 04 3a             	lea    (%edx,%edi,1),%eax
f01045a2:	25 ff 03 00 00       	and    $0x3ff,%eax
f01045a7:	29 f8                	sub    %edi,%eax
	 if(envs[j].env_status == ENV_RUNNABLE){
f01045a9:	6b c0 7c             	imul   $0x7c,%eax,%eax
f01045ac:	01 c8                	add    %ecx,%eax
f01045ae:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f01045b2:	74 1f                	je     f01045d3 <sched_yield+0x73>
f01045b4:	83 c2 01             	add    $0x1,%edx
	for(i=0;i<NENV;i++){
f01045b7:	39 da                	cmp    %ebx,%edx
f01045b9:	75 dc                	jne    f0104597 <sched_yield+0x37>
	if(envs[curenv_id].env_status==ENV_RUNNING && envs[curenv_id].env_cpunum==cpunum()){
f01045bb:	6b f6 7c             	imul   $0x7c,%esi,%esi
f01045be:	01 f1                	add    %esi,%ecx
f01045c0:	83 79 54 03          	cmpl   $0x3,0x54(%ecx)
f01045c4:	74 16                	je     f01045dc <sched_yield+0x7c>
	sched_halt();
f01045c6:	e8 c3 fe ff ff       	call   f010448e <sched_halt>
}
f01045cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01045ce:	5b                   	pop    %ebx
f01045cf:	5e                   	pop    %esi
f01045d0:	5f                   	pop    %edi
f01045d1:	5d                   	pop    %ebp
f01045d2:	c3                   	ret    
	   env_run(&envs[j]);
f01045d3:	83 ec 0c             	sub    $0xc,%esp
f01045d6:	50                   	push   %eax
f01045d7:	e8 0b f1 ff ff       	call   f01036e7 <env_run>
	if(envs[curenv_id].env_status==ENV_RUNNING && envs[curenv_id].env_cpunum==cpunum()){
f01045dc:	8b 59 5c             	mov    0x5c(%ecx),%ebx
f01045df:	e8 47 19 00 00       	call   f0105f2b <cpunum>
f01045e4:	39 c3                	cmp    %eax,%ebx
f01045e6:	75 de                	jne    f01045c6 <sched_yield+0x66>
	   env_run(&envs[curenv_id]);
f01045e8:	83 ec 0c             	sub    $0xc,%esp
f01045eb:	03 35 44 42 23 f0    	add    0xf0234244,%esi
f01045f1:	56                   	push   %esi
f01045f2:	e8 f0 f0 ff ff       	call   f01036e7 <env_run>

f01045f7 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f01045f7:	55                   	push   %ebp
f01045f8:	89 e5                	mov    %esp,%ebp
f01045fa:	57                   	push   %edi
f01045fb:	56                   	push   %esi
f01045fc:	53                   	push   %ebx
f01045fd:	83 ec 1c             	sub    $0x1c,%esp
f0104600:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

       //	panic("syscall not implemented");
	switch (syscallno) {
f0104603:	83 f8 0c             	cmp    $0xc,%eax
f0104606:	0f 87 b4 06 00 00    	ja     f0104cc0 <syscall+0x6c9>
f010460c:	ff 24 85 50 7d 10 f0 	jmp    *-0xfef82b0(,%eax,4)
        user_mem_assert(curenv,s,len,0);
f0104613:	e8 13 19 00 00       	call   f0105f2b <cpunum>
f0104618:	6a 00                	push   $0x0
f010461a:	ff 75 10             	pushl  0x10(%ebp)
f010461d:	ff 75 0c             	pushl  0xc(%ebp)
f0104620:	6b c0 74             	imul   $0x74,%eax,%eax
f0104623:	ff b0 28 50 23 f0    	pushl  -0xfdcafd8(%eax)
f0104629:	e8 4c e9 ff ff       	call   f0102f7a <user_mem_assert>
	cprintf("%.*s", len, s);
f010462e:	83 c4 0c             	add    $0xc,%esp
f0104631:	ff 75 0c             	pushl  0xc(%ebp)
f0104634:	ff 75 10             	pushl  0x10(%ebp)
f0104637:	68 86 7c 10 f0       	push   $0xf0107c86
f010463c:	e8 03 f3 ff ff       	call   f0103944 <cprintf>
f0104641:	83 c4 10             	add    $0x10,%esp
	case SYS_ipc_recv:
		 return sys_ipc_recv((void *)a1);
       	default:
		return -E_INVAL;
	}
	return 0;
f0104644:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0104649:	89 d8                	mov    %ebx,%eax
f010464b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010464e:	5b                   	pop    %ebx
f010464f:	5e                   	pop    %esi
f0104650:	5f                   	pop    %edi
f0104651:	5d                   	pop    %ebp
f0104652:	c3                   	ret    
	return cons_getc();
f0104653:	e8 9c bf ff ff       	call   f01005f4 <cons_getc>
f0104658:	89 c3                	mov    %eax,%ebx
	       return  sys_cgetc();
f010465a:	eb ed                	jmp    f0104649 <syscall+0x52>
	return curenv->env_id;
f010465c:	e8 ca 18 00 00       	call   f0105f2b <cpunum>
f0104661:	6b c0 74             	imul   $0x74,%eax,%eax
f0104664:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f010466a:	8b 58 48             	mov    0x48(%eax),%ebx
                return sys_getenvid();
f010466d:	eb da                	jmp    f0104649 <syscall+0x52>
	if ((r = envid2env(envid, &e, 1)) < 0)
f010466f:	83 ec 04             	sub    $0x4,%esp
f0104672:	6a 01                	push   $0x1
f0104674:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104677:	50                   	push   %eax
f0104678:	ff 75 0c             	pushl  0xc(%ebp)
f010467b:	e8 cc e9 ff ff       	call   f010304c <envid2env>
f0104680:	89 c3                	mov    %eax,%ebx
f0104682:	83 c4 10             	add    $0x10,%esp
f0104685:	85 c0                	test   %eax,%eax
f0104687:	78 c0                	js     f0104649 <syscall+0x52>
	if (e == curenv)
f0104689:	e8 9d 18 00 00       	call   f0105f2b <cpunum>
f010468e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104691:	6b c0 74             	imul   $0x74,%eax,%eax
f0104694:	39 90 28 50 23 f0    	cmp    %edx,-0xfdcafd8(%eax)
f010469a:	74 3d                	je     f01046d9 <syscall+0xe2>
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f010469c:	8b 5a 48             	mov    0x48(%edx),%ebx
f010469f:	e8 87 18 00 00       	call   f0105f2b <cpunum>
f01046a4:	83 ec 04             	sub    $0x4,%esp
f01046a7:	53                   	push   %ebx
f01046a8:	6b c0 74             	imul   $0x74,%eax,%eax
f01046ab:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f01046b1:	ff 70 48             	pushl  0x48(%eax)
f01046b4:	68 a6 7c 10 f0       	push   $0xf0107ca6
f01046b9:	e8 86 f2 ff ff       	call   f0103944 <cprintf>
f01046be:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f01046c1:	83 ec 0c             	sub    $0xc,%esp
f01046c4:	ff 75 e4             	pushl  -0x1c(%ebp)
f01046c7:	e8 7c ef ff ff       	call   f0103648 <env_destroy>
f01046cc:	83 c4 10             	add    $0x10,%esp
	return 0;
f01046cf:	bb 00 00 00 00       	mov    $0x0,%ebx
		return sys_env_destroy(a1);
f01046d4:	e9 70 ff ff ff       	jmp    f0104649 <syscall+0x52>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f01046d9:	e8 4d 18 00 00       	call   f0105f2b <cpunum>
f01046de:	83 ec 08             	sub    $0x8,%esp
f01046e1:	6b c0 74             	imul   $0x74,%eax,%eax
f01046e4:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f01046ea:	ff 70 48             	pushl  0x48(%eax)
f01046ed:	68 8b 7c 10 f0       	push   $0xf0107c8b
f01046f2:	e8 4d f2 ff ff       	call   f0103944 <cprintf>
f01046f7:	83 c4 10             	add    $0x10,%esp
f01046fa:	eb c5                	jmp    f01046c1 <syscall+0xca>
	sched_yield();
f01046fc:	e8 5f fe ff ff       	call   f0104560 <sched_yield>
	return curenv->env_id;
f0104701:	e8 25 18 00 00       	call   f0105f2b <cpunum>
      if((ret = env_alloc(&childenv,sys_getenvid()))<0)
f0104706:	83 ec 08             	sub    $0x8,%esp
	return curenv->env_id;
f0104709:	6b c0 74             	imul   $0x74,%eax,%eax
f010470c:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
      if((ret = env_alloc(&childenv,sys_getenvid()))<0)
f0104712:	ff 70 48             	pushl  0x48(%eax)
f0104715:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104718:	50                   	push   %eax
f0104719:	e8 3f ea ff ff       	call   f010315d <env_alloc>
f010471e:	89 c3                	mov    %eax,%ebx
f0104720:	83 c4 10             	add    $0x10,%esp
f0104723:	85 c0                	test   %eax,%eax
f0104725:	0f 88 1e ff ff ff    	js     f0104649 <syscall+0x52>
      childenv->env_status = ENV_NOT_RUNNABLE;
f010472b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010472e:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
      childenv->env_tf = curenv->env_tf;
f0104735:	e8 f1 17 00 00       	call   f0105f2b <cpunum>
f010473a:	6b c0 74             	imul   $0x74,%eax,%eax
f010473d:	8b b0 28 50 23 f0    	mov    -0xfdcafd8(%eax),%esi
f0104743:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104748:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010474b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
      childenv->env_tf.tf_regs.reg_eax = 0; //attention
f010474d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104750:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
      return childenv->env_id;
f0104757:	8b 58 48             	mov    0x48(%eax),%ebx
		 return sys_exofork();
f010475a:	e9 ea fe ff ff       	jmp    f0104649 <syscall+0x52>
       if((ret = envid2env(envid,&env,1))<0)
f010475f:	83 ec 04             	sub    $0x4,%esp
f0104762:	6a 01                	push   $0x1
f0104764:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104767:	50                   	push   %eax
f0104768:	ff 75 0c             	pushl  0xc(%ebp)
f010476b:	e8 dc e8 ff ff       	call   f010304c <envid2env>
f0104770:	89 c3                	mov    %eax,%ebx
f0104772:	83 c4 10             	add    $0x10,%esp
f0104775:	85 c0                	test   %eax,%eax
f0104777:	0f 88 cc fe ff ff    	js     f0104649 <syscall+0x52>
       if(env->env_status!=ENV_RUNNABLE && env->env_status!=ENV_NOT_RUNNABLE)
f010477d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104780:	8b 42 54             	mov    0x54(%edx),%eax
f0104783:	83 e8 02             	sub    $0x2,%eax
f0104786:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f010478b:	75 10                	jne    f010479d <syscall+0x1a6>
       env->env_status = status;
f010478d:	8b 45 10             	mov    0x10(%ebp),%eax
f0104790:	89 42 54             	mov    %eax,0x54(%edx)
       return 0;
f0104793:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104798:	e9 ac fe ff ff       	jmp    f0104649 <syscall+0x52>
	       return -E_INVAL;
f010479d:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		 return sys_env_set_status(a1,a2);
f01047a2:	e9 a2 fe ff ff       	jmp    f0104649 <syscall+0x52>
	if(envid2env(envid,&env,1)<0)
f01047a7:	83 ec 04             	sub    $0x4,%esp
f01047aa:	6a 01                	push   $0x1
f01047ac:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01047af:	50                   	push   %eax
f01047b0:	ff 75 0c             	pushl  0xc(%ebp)
f01047b3:	e8 94 e8 ff ff       	call   f010304c <envid2env>
f01047b8:	83 c4 10             	add    $0x10,%esp
f01047bb:	85 c0                	test   %eax,%eax
f01047bd:	78 72                	js     f0104831 <syscall+0x23a>
	if((uintptr_t)va>=UTOP || PGOFF(va))
f01047bf:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01047c6:	77 73                	ja     f010483b <syscall+0x244>
f01047c8:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01047cf:	75 74                	jne    f0104845 <syscall+0x24e>
        if((perm&PTE_U)==0 || (perm&PTE_P)==0)
f01047d1:	8b 45 14             	mov    0x14(%ebp),%eax
f01047d4:	83 e0 05             	and    $0x5,%eax
f01047d7:	83 f8 05             	cmp    $0x5,%eax
f01047da:	75 73                	jne    f010484f <syscall+0x258>
        if((perm&PTE_SYSCALL)==0 || perm & ~PTE_SYSCALL)
f01047dc:	f7 45 14 07 0e 00 00 	testl  $0xe07,0x14(%ebp)
f01047e3:	74 74                	je     f0104859 <syscall+0x262>
f01047e5:	f7 45 14 f8 f1 ff ff 	testl  $0xfffff1f8,0x14(%ebp)
f01047ec:	75 75                	jne    f0104863 <syscall+0x26c>
	pp = page_alloc(1);
f01047ee:	83 ec 0c             	sub    $0xc,%esp
f01047f1:	6a 01                	push   $0x1
f01047f3:	e8 19 c7 ff ff       	call   f0100f11 <page_alloc>
f01047f8:	89 c6                	mov    %eax,%esi
	if(!pp) return -E_NO_MEM;
f01047fa:	83 c4 10             	add    $0x10,%esp
f01047fd:	85 c0                	test   %eax,%eax
f01047ff:	74 6c                	je     f010486d <syscall+0x276>
	ret=page_insert(env->env_pgdir,pp,va,perm);
f0104801:	ff 75 14             	pushl  0x14(%ebp)
f0104804:	ff 75 10             	pushl  0x10(%ebp)
f0104807:	50                   	push   %eax
f0104808:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010480b:	ff 70 60             	pushl  0x60(%eax)
f010480e:	e8 1b ca ff ff       	call   f010122e <page_insert>
f0104813:	89 c3                	mov    %eax,%ebx
        if(ret!=0){
f0104815:	83 c4 10             	add    $0x10,%esp
f0104818:	85 c0                	test   %eax,%eax
f010481a:	0f 84 29 fe ff ff    	je     f0104649 <syscall+0x52>
	  page_free(pp);
f0104820:	83 ec 0c             	sub    $0xc,%esp
f0104823:	56                   	push   %esi
f0104824:	e8 5a c7 ff ff       	call   f0100f83 <page_free>
f0104829:	83 c4 10             	add    $0x10,%esp
f010482c:	e9 18 fe ff ff       	jmp    f0104649 <syscall+0x52>
        	return -E_BAD_ENV;
f0104831:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104836:	e9 0e fe ff ff       	jmp    f0104649 <syscall+0x52>
		return -E_INVAL;
f010483b:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104840:	e9 04 fe ff ff       	jmp    f0104649 <syscall+0x52>
f0104845:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010484a:	e9 fa fd ff ff       	jmp    f0104649 <syscall+0x52>
	        return -E_INVAL;
f010484f:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104854:	e9 f0 fd ff ff       	jmp    f0104649 <syscall+0x52>
	        return -E_INVAL;
f0104859:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010485e:	e9 e6 fd ff ff       	jmp    f0104649 <syscall+0x52>
f0104863:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104868:	e9 dc fd ff ff       	jmp    f0104649 <syscall+0x52>
	if(!pp) return -E_NO_MEM;
f010486d:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
		 return sys_page_alloc(a1,(void *)a2, a3);
f0104872:	e9 d2 fd ff ff       	jmp    f0104649 <syscall+0x52>
	if(envid2env(srcenvid,&srcenv,1)<0 || envid2env(dstenvid,&dstenv,1)<0)
f0104877:	83 ec 04             	sub    $0x4,%esp
f010487a:	6a 01                	push   $0x1
f010487c:	8d 45 dc             	lea    -0x24(%ebp),%eax
f010487f:	50                   	push   %eax
f0104880:	ff 75 0c             	pushl  0xc(%ebp)
f0104883:	e8 c4 e7 ff ff       	call   f010304c <envid2env>
f0104888:	83 c4 10             	add    $0x10,%esp
f010488b:	85 c0                	test   %eax,%eax
f010488d:	0f 88 ab 00 00 00    	js     f010493e <syscall+0x347>
f0104893:	83 ec 04             	sub    $0x4,%esp
f0104896:	6a 01                	push   $0x1
f0104898:	8d 45 e0             	lea    -0x20(%ebp),%eax
f010489b:	50                   	push   %eax
f010489c:	ff 75 14             	pushl  0x14(%ebp)
f010489f:	e8 a8 e7 ff ff       	call   f010304c <envid2env>
f01048a4:	83 c4 10             	add    $0x10,%esp
f01048a7:	85 c0                	test   %eax,%eax
f01048a9:	0f 88 99 00 00 00    	js     f0104948 <syscall+0x351>
	if((uintptr_t)srcva >= UTOP || PGOFF(srcva) || (uintptr_t)dstva >= UTOP || PGOFF(dstva))
f01048af:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01048b6:	0f 87 96 00 00 00    	ja     f0104952 <syscall+0x35b>
f01048bc:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01048c3:	0f 85 93 00 00 00    	jne    f010495c <syscall+0x365>
f01048c9:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f01048d0:	0f 87 86 00 00 00    	ja     f010495c <syscall+0x365>
f01048d6:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f01048dd:	0f 85 83 00 00 00    	jne    f0104966 <syscall+0x36f>
	if((pp=page_lookup(srcenv->env_pgdir,srcva,&pte))<0)
f01048e3:	83 ec 04             	sub    $0x4,%esp
f01048e6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01048e9:	50                   	push   %eax
f01048ea:	ff 75 10             	pushl  0x10(%ebp)
f01048ed:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01048f0:	ff 70 60             	pushl  0x60(%eax)
f01048f3:	e8 5f c8 ff ff       	call   f0101157 <page_lookup>
	 if((perm&PTE_U)==0 || (perm&PTE_P)==0)
f01048f8:	8b 55 1c             	mov    0x1c(%ebp),%edx
f01048fb:	83 e2 05             	and    $0x5,%edx
f01048fe:	83 c4 10             	add    $0x10,%esp
f0104901:	83 fa 05             	cmp    $0x5,%edx
f0104904:	75 6a                	jne    f0104970 <syscall+0x379>
        if((perm&PTE_SYSCALL)==0 || perm & ~PTE_SYSCALL)
f0104906:	f7 45 1c 07 0e 00 00 	testl  $0xe07,0x1c(%ebp)
f010490d:	74 6b                	je     f010497a <syscall+0x383>
f010490f:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
f0104912:	81 e3 f8 f1 ff ff    	and    $0xfffff1f8,%ebx
f0104918:	75 6a                	jne    f0104984 <syscall+0x38d>
	if(page_insert(dstenv->env_pgdir,pp,dstva,perm)<0)
f010491a:	ff 75 1c             	pushl  0x1c(%ebp)
f010491d:	ff 75 18             	pushl  0x18(%ebp)
f0104920:	50                   	push   %eax
f0104921:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104924:	ff 70 60             	pushl  0x60(%eax)
f0104927:	e8 02 c9 ff ff       	call   f010122e <page_insert>
f010492c:	83 c4 10             	add    $0x10,%esp
		return -E_NO_MEM;
f010492f:	85 c0                	test   %eax,%eax
f0104931:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104936:	0f 48 d8             	cmovs  %eax,%ebx
f0104939:	e9 0b fd ff ff       	jmp    f0104649 <syscall+0x52>
		return -E_BAD_ENV;
f010493e:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104943:	e9 01 fd ff ff       	jmp    f0104649 <syscall+0x52>
f0104948:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f010494d:	e9 f7 fc ff ff       	jmp    f0104649 <syscall+0x52>
		return -E_INVAL;
f0104952:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104957:	e9 ed fc ff ff       	jmp    f0104649 <syscall+0x52>
f010495c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104961:	e9 e3 fc ff ff       	jmp    f0104649 <syscall+0x52>
f0104966:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010496b:	e9 d9 fc ff ff       	jmp    f0104649 <syscall+0x52>
                return -E_INVAL;
f0104970:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104975:	e9 cf fc ff ff       	jmp    f0104649 <syscall+0x52>
                return -E_INVAL;
f010497a:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010497f:	e9 c5 fc ff ff       	jmp    f0104649 <syscall+0x52>
f0104984:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104989:	e9 bb fc ff ff       	jmp    f0104649 <syscall+0x52>
	if(envid2env(envid,&env,1)<0)
f010498e:	83 ec 04             	sub    $0x4,%esp
f0104991:	6a 01                	push   $0x1
f0104993:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104996:	50                   	push   %eax
f0104997:	ff 75 0c             	pushl  0xc(%ebp)
f010499a:	e8 ad e6 ff ff       	call   f010304c <envid2env>
f010499f:	83 c4 10             	add    $0x10,%esp
f01049a2:	85 c0                	test   %eax,%eax
f01049a4:	78 30                	js     f01049d6 <syscall+0x3df>
	if((uintptr_t)va >= UTOP || PGOFF(va))
f01049a6:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01049ad:	77 31                	ja     f01049e0 <syscall+0x3e9>
f01049af:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01049b6:	75 32                	jne    f01049ea <syscall+0x3f3>
	page_remove(env->env_pgdir,va);
f01049b8:	83 ec 08             	sub    $0x8,%esp
f01049bb:	ff 75 10             	pushl  0x10(%ebp)
f01049be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01049c1:	ff 70 60             	pushl  0x60(%eax)
f01049c4:	e8 1d c8 ff ff       	call   f01011e6 <page_remove>
f01049c9:	83 c4 10             	add    $0x10,%esp
	return 0;
f01049cc:	bb 00 00 00 00       	mov    $0x0,%ebx
f01049d1:	e9 73 fc ff ff       	jmp    f0104649 <syscall+0x52>
		return -E_BAD_ENV;
f01049d6:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f01049db:	e9 69 fc ff ff       	jmp    f0104649 <syscall+0x52>
		return -E_INVAL;
f01049e0:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01049e5:	e9 5f fc ff ff       	jmp    f0104649 <syscall+0x52>
f01049ea:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		 return sys_page_unmap(a1,(void *)a2);
f01049ef:	e9 55 fc ff ff       	jmp    f0104649 <syscall+0x52>
	if(envid2env(envid,&env,1)<0)
f01049f4:	83 ec 04             	sub    $0x4,%esp
f01049f7:	6a 01                	push   $0x1
f01049f9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01049fc:	50                   	push   %eax
f01049fd:	ff 75 0c             	pushl  0xc(%ebp)
f0104a00:	e8 47 e6 ff ff       	call   f010304c <envid2env>
f0104a05:	83 c4 10             	add    $0x10,%esp
f0104a08:	85 c0                	test   %eax,%eax
f0104a0a:	78 13                	js     f0104a1f <syscall+0x428>
	env->env_pgfault_upcall = func;
f0104a0c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104a0f:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104a12:	89 78 64             	mov    %edi,0x64(%eax)
	return 0;
f0104a15:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104a1a:	e9 2a fc ff ff       	jmp    f0104649 <syscall+0x52>
		return -E_BAD_ENV;
f0104a1f:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
		 return sys_env_set_pgfault_upcall(a1,(void *)a2);
f0104a24:	e9 20 fc ff ff       	jmp    f0104649 <syscall+0x52>
	if((r=envid2env(envid,&dstenv,0))<0){
f0104a29:	83 ec 04             	sub    $0x4,%esp
f0104a2c:	6a 00                	push   $0x0
f0104a2e:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104a31:	50                   	push   %eax
f0104a32:	ff 75 0c             	pushl  0xc(%ebp)
f0104a35:	e8 12 e6 ff ff       	call   f010304c <envid2env>
f0104a3a:	83 c4 10             	add    $0x10,%esp
f0104a3d:	85 c0                	test   %eax,%eax
f0104a3f:	0f 88 cb 00 00 00    	js     f0104b10 <syscall+0x519>
        if(dstenv->env_ipc_recving!=true||dstenv->env_ipc_from!=0){
f0104a45:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104a48:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0104a4c:	0f 84 d8 00 00 00    	je     f0104b2a <syscall+0x533>
f0104a52:	83 78 74 00          	cmpl   $0x0,0x74(%eax)
f0104a56:	0f 85 ce 00 00 00    	jne    f0104b2a <syscall+0x533>
	if(srcva<(void *)UTOP && PGOFF(srcva)){
f0104a5c:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0104a63:	0f 87 29 01 00 00    	ja     f0104b92 <syscall+0x59b>
f0104a69:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f0104a70:	0f 85 ce 00 00 00    	jne    f0104b44 <syscall+0x54d>
	   if((perm&PTE_U)==0 || (perm&PTE_P)==0){
f0104a76:	8b 45 18             	mov    0x18(%ebp),%eax
f0104a79:	83 e0 05             	and    $0x5,%eax
f0104a7c:	83 f8 05             	cmp    $0x5,%eax
f0104a7f:	0f 85 d9 00 00 00    	jne    f0104b5e <syscall+0x567>
           if((perm&PTE_SYSCALL)==0 || perm & ~PTE_SYSCALL){
f0104a85:	f7 45 18 07 0e 00 00 	testl  $0xe07,0x18(%ebp)
f0104a8c:	0f 84 e6 00 00 00    	je     f0104b78 <syscall+0x581>
f0104a92:	f7 45 18 f8 f1 ff ff 	testl  $0xfffff1f8,0x18(%ebp)
f0104a99:	0f 85 d9 00 00 00    	jne    f0104b78 <syscall+0x581>
	pp=page_lookup(curenv->env_pgdir,srcva,&pte);
f0104a9f:	e8 87 14 00 00       	call   f0105f2b <cpunum>
f0104aa4:	83 ec 04             	sub    $0x4,%esp
f0104aa7:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104aaa:	52                   	push   %edx
f0104aab:	ff 75 14             	pushl  0x14(%ebp)
f0104aae:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ab1:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f0104ab7:	ff 70 60             	pushl  0x60(%eax)
f0104aba:	e8 98 c6 ff ff       	call   f0101157 <page_lookup>
	if(srcva<(void *)UTOP && (pp==NULL)){
f0104abf:	83 c4 10             	add    $0x10,%esp
f0104ac2:	85 c0                	test   %eax,%eax
f0104ac4:	0f 84 37 01 00 00    	je     f0104c01 <syscall+0x60a>
	if((srcva<(void *)UTOP)&&  (perm & PTE_W) && (*pte&PTE_W)==0)
f0104aca:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0104ace:	74 0c                	je     f0104adc <syscall+0x4e5>
f0104ad0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104ad3:	f6 02 02             	testb  $0x2,(%edx)
f0104ad6:	0f 84 59 01 00 00    	je     f0104c35 <syscall+0x63e>
	if(srcva<(void *)UTOP && dstenv->env_ipc_dstva!=0){
f0104adc:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104adf:	8b 4a 6c             	mov    0x6c(%edx),%ecx
f0104ae2:	85 c9                	test   %ecx,%ecx
f0104ae4:	0f 84 cb 00 00 00    	je     f0104bb5 <syscall+0x5be>
	  if((r=page_insert(dstenv->env_pgdir,pp,dstenv->env_ipc_dstva,perm))<0){
f0104aea:	ff 75 18             	pushl  0x18(%ebp)
f0104aed:	51                   	push   %ecx
f0104aee:	50                   	push   %eax
f0104aef:	ff 72 60             	pushl  0x60(%edx)
f0104af2:	e8 37 c7 ff ff       	call   f010122e <page_insert>
f0104af7:	83 c4 10             	add    $0x10,%esp
f0104afa:	85 c0                	test   %eax,%eax
f0104afc:	0f 88 19 01 00 00    	js     f0104c1b <syscall+0x624>
	    dstenv->env_ipc_perm = perm;
f0104b02:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104b05:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0104b08:	89 48 78             	mov    %ecx,0x78(%eax)
f0104b0b:	e9 a5 00 00 00       	jmp    f0104bb5 <syscall+0x5be>
		cprintf("error in envid2env\n");
f0104b10:	83 ec 0c             	sub    $0xc,%esp
f0104b13:	68 be 7c 10 f0       	push   $0xf0107cbe
f0104b18:	e8 27 ee ff ff       	call   f0103944 <cprintf>
f0104b1d:	83 c4 10             	add    $0x10,%esp
		return -E_BAD_ENV;
f0104b20:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104b25:	e9 1f fb ff ff       	jmp    f0104649 <syscall+0x52>
		cprintf("error in recving\n");
f0104b2a:	83 ec 0c             	sub    $0xc,%esp
f0104b2d:	68 d2 7c 10 f0       	push   $0xf0107cd2
f0104b32:	e8 0d ee ff ff       	call   f0103944 <cprintf>
f0104b37:	83 c4 10             	add    $0x10,%esp
		return -E_IPC_NOT_RECV;
f0104b3a:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
f0104b3f:	e9 05 fb ff ff       	jmp    f0104649 <syscall+0x52>
		cprintf("error in PFOFF\n");
f0104b44:	83 ec 0c             	sub    $0xc,%esp
f0104b47:	68 e4 7c 10 f0       	push   $0xf0107ce4
f0104b4c:	e8 f3 ed ff ff       	call   f0103944 <cprintf>
f0104b51:	83 c4 10             	add    $0x10,%esp
		return -E_INVAL;
f0104b54:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b59:	e9 eb fa ff ff       	jmp    f0104649 <syscall+0x52>
		   cprintf("error in perm\n");
f0104b5e:	83 ec 0c             	sub    $0xc,%esp
f0104b61:	68 f4 7c 10 f0       	push   $0xf0107cf4
f0104b66:	e8 d9 ed ff ff       	call   f0103944 <cprintf>
f0104b6b:	83 c4 10             	add    $0x10,%esp
                return -E_INVAL;
f0104b6e:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b73:	e9 d1 fa ff ff       	jmp    f0104649 <syscall+0x52>
		   cprintf("error in perm\n");
f0104b78:	83 ec 0c             	sub    $0xc,%esp
f0104b7b:	68 f4 7c 10 f0       	push   $0xf0107cf4
f0104b80:	e8 bf ed ff ff       	call   f0103944 <cprintf>
f0104b85:	83 c4 10             	add    $0x10,%esp
                return -E_INVAL;
f0104b88:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b8d:	e9 b7 fa ff ff       	jmp    f0104649 <syscall+0x52>
	pp=page_lookup(curenv->env_pgdir,srcva,&pte);
f0104b92:	e8 94 13 00 00       	call   f0105f2b <cpunum>
f0104b97:	83 ec 04             	sub    $0x4,%esp
f0104b9a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104b9d:	52                   	push   %edx
f0104b9e:	ff 75 14             	pushl  0x14(%ebp)
f0104ba1:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ba4:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f0104baa:	ff 70 60             	pushl  0x60(%eax)
f0104bad:	e8 a5 c5 ff ff       	call   f0101157 <page_lookup>
f0104bb2:	83 c4 10             	add    $0x10,%esp
	dstenv->env_ipc_from = curenv->env_id;
f0104bb5:	e8 71 13 00 00       	call   f0105f2b <cpunum>
f0104bba:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104bbd:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bc0:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f0104bc6:	8b 40 48             	mov    0x48(%eax),%eax
f0104bc9:	89 42 74             	mov    %eax,0x74(%edx)
	dstenv->env_ipc_recving =false;
f0104bcc:	c6 42 68 00          	movb   $0x0,0x68(%edx)
	dstenv->env_ipc_value = value;
f0104bd0:	8b 45 10             	mov    0x10(%ebp),%eax
f0104bd3:	89 42 70             	mov    %eax,0x70(%edx)
	dstenv->env_status = ENV_RUNNABLE;
f0104bd6:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
        cprintf("sending success\n");
f0104bdd:	83 ec 0c             	sub    $0xc,%esp
f0104be0:	68 2b 7d 10 f0       	push   $0xf0107d2b
f0104be5:	e8 5a ed ff ff       	call   f0103944 <cprintf>
	dstenv->env_tf.tf_regs.reg_eax = 0;
f0104bea:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104bed:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
f0104bf4:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104bf7:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104bfc:	e9 48 fa ff ff       	jmp    f0104649 <syscall+0x52>
		cprintf("error in pp NULL\n");
f0104c01:	83 ec 0c             	sub    $0xc,%esp
f0104c04:	68 03 7d 10 f0       	push   $0xf0107d03
f0104c09:	e8 36 ed ff ff       	call   f0103944 <cprintf>
f0104c0e:	83 c4 10             	add    $0x10,%esp
		return -E_INVAL;
f0104c11:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104c16:	e9 2e fa ff ff       	jmp    f0104649 <syscall+0x52>
		  cprintf("error in page insert\n");
f0104c1b:	83 ec 0c             	sub    $0xc,%esp
f0104c1e:	68 15 7d 10 f0       	push   $0xf0107d15
f0104c23:	e8 1c ed ff ff       	call   f0103944 <cprintf>
f0104c28:	83 c4 10             	add    $0x10,%esp
		  return -E_NO_MEM;
f0104c2b:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f0104c30:	e9 14 fa ff ff       	jmp    f0104649 <syscall+0x52>
		return -E_INVAL;
f0104c35:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		 return sys_ipc_try_send(a1,a2,(void *)a3,a4);
f0104c3a:	e9 0a fa ff ff       	jmp    f0104649 <syscall+0x52>
        if(dstva < (void *)UTOP && PGOFF(dstva)){
f0104c3f:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0104c46:	77 23                	ja     f0104c6b <syscall+0x674>
f0104c48:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f0104c4f:	74 1a                	je     f0104c6b <syscall+0x674>
		cprintf("sys_ipc_recv:dstva\n");
f0104c51:	83 ec 0c             	sub    $0xc,%esp
f0104c54:	68 3c 7d 10 f0       	push   $0xf0107d3c
f0104c59:	e8 e6 ec ff ff       	call   f0103944 <cprintf>
		 return sys_ipc_recv((void *)a1);
f0104c5e:	83 c4 10             	add    $0x10,%esp
f0104c61:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104c66:	e9 de f9 ff ff       	jmp    f0104649 <syscall+0x52>
        curenv->env_ipc_recving = true;
f0104c6b:	e8 bb 12 00 00       	call   f0105f2b <cpunum>
f0104c70:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c73:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f0104c79:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_ipc_dstva = dstva;
f0104c7d:	e8 a9 12 00 00       	call   f0105f2b <cpunum>
f0104c82:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c85:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f0104c8b:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104c8e:	89 78 6c             	mov    %edi,0x6c(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f0104c91:	e8 95 12 00 00       	call   f0105f2b <cpunum>
f0104c96:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c99:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f0104c9f:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
        curenv->env_ipc_from = 0;
f0104ca6:	e8 80 12 00 00       	call   f0105f2b <cpunum>
f0104cab:	6b c0 74             	imul   $0x74,%eax,%eax
f0104cae:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f0104cb4:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
	sched_yield();
f0104cbb:	e8 a0 f8 ff ff       	call   f0104560 <sched_yield>
		return -E_INVAL;
f0104cc0:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104cc5:	e9 7f f9 ff ff       	jmp    f0104649 <syscall+0x52>

f0104cca <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104cca:	55                   	push   %ebp
f0104ccb:	89 e5                	mov    %esp,%ebp
f0104ccd:	57                   	push   %edi
f0104cce:	56                   	push   %esi
f0104ccf:	53                   	push   %ebx
f0104cd0:	83 ec 14             	sub    $0x14,%esp
f0104cd3:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104cd6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104cd9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104cdc:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104cdf:	8b 32                	mov    (%edx),%esi
f0104ce1:	8b 01                	mov    (%ecx),%eax
f0104ce3:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104ce6:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104ced:	eb 2f                	jmp    f0104d1e <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0104cef:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0104cf2:	39 c6                	cmp    %eax,%esi
f0104cf4:	7f 49                	jg     f0104d3f <stab_binsearch+0x75>
f0104cf6:	0f b6 0a             	movzbl (%edx),%ecx
f0104cf9:	83 ea 0c             	sub    $0xc,%edx
f0104cfc:	39 f9                	cmp    %edi,%ecx
f0104cfe:	75 ef                	jne    f0104cef <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104d00:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104d03:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104d06:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104d0a:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104d0d:	73 35                	jae    f0104d44 <stab_binsearch+0x7a>
			*region_left = m;
f0104d0f:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104d12:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f0104d14:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f0104d17:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0104d1e:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0104d21:	7f 4e                	jg     f0104d71 <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f0104d23:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104d26:	01 f0                	add    %esi,%eax
f0104d28:	89 c3                	mov    %eax,%ebx
f0104d2a:	c1 eb 1f             	shr    $0x1f,%ebx
f0104d2d:	01 c3                	add    %eax,%ebx
f0104d2f:	d1 fb                	sar    %ebx
f0104d31:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104d34:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104d37:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0104d3b:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f0104d3d:	eb b3                	jmp    f0104cf2 <stab_binsearch+0x28>
			l = true_m + 1;
f0104d3f:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f0104d42:	eb da                	jmp    f0104d1e <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0104d44:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104d47:	76 14                	jbe    f0104d5d <stab_binsearch+0x93>
			*region_right = m - 1;
f0104d49:	83 e8 01             	sub    $0x1,%eax
f0104d4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104d4f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104d52:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f0104d54:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104d5b:	eb c1                	jmp    f0104d1e <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104d5d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104d60:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0104d62:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104d66:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f0104d68:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104d6f:	eb ad                	jmp    f0104d1e <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0104d71:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104d75:	74 16                	je     f0104d8d <stab_binsearch+0xc3>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104d77:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104d7a:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104d7c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104d7f:	8b 0e                	mov    (%esi),%ecx
f0104d81:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104d84:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0104d87:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f0104d8b:	eb 12                	jmp    f0104d9f <stab_binsearch+0xd5>
		*region_right = *region_left - 1;
f0104d8d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104d90:	8b 00                	mov    (%eax),%eax
f0104d92:	83 e8 01             	sub    $0x1,%eax
f0104d95:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104d98:	89 07                	mov    %eax,(%edi)
f0104d9a:	eb 16                	jmp    f0104db2 <stab_binsearch+0xe8>
		     l--)
f0104d9c:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0104d9f:	39 c1                	cmp    %eax,%ecx
f0104da1:	7d 0a                	jge    f0104dad <stab_binsearch+0xe3>
		     l > *region_left && stabs[l].n_type != type;
f0104da3:	0f b6 1a             	movzbl (%edx),%ebx
f0104da6:	83 ea 0c             	sub    $0xc,%edx
f0104da9:	39 fb                	cmp    %edi,%ebx
f0104dab:	75 ef                	jne    f0104d9c <stab_binsearch+0xd2>
			/* do nothing */;
		*region_left = l;
f0104dad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104db0:	89 07                	mov    %eax,(%edi)
	}
}
f0104db2:	83 c4 14             	add    $0x14,%esp
f0104db5:	5b                   	pop    %ebx
f0104db6:	5e                   	pop    %esi
f0104db7:	5f                   	pop    %edi
f0104db8:	5d                   	pop    %ebp
f0104db9:	c3                   	ret    

f0104dba <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104dba:	55                   	push   %ebp
f0104dbb:	89 e5                	mov    %esp,%ebp
f0104dbd:	57                   	push   %edi
f0104dbe:	56                   	push   %esi
f0104dbf:	53                   	push   %ebx
f0104dc0:	83 ec 4c             	sub    $0x4c,%esp
f0104dc3:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104dc6:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104dc9:	c7 06 84 7d 10 f0    	movl   $0xf0107d84,(%esi)
	info->eip_line = 0;
f0104dcf:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0104dd6:	c7 46 08 84 7d 10 f0 	movl   $0xf0107d84,0x8(%esi)
	info->eip_fn_namelen = 9;
f0104ddd:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0104de4:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0104de7:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104dee:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0104df4:	0f 86 2e 01 00 00    	jbe    f0104f28 <debuginfo_eip+0x16e>
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104dfa:	c7 45 b8 2e 71 11 f0 	movl   $0xf011712e,-0x48(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0104e01:	c7 45 b4 5d 39 11 f0 	movl   $0xf011395d,-0x4c(%ebp)
		stab_end = __STAB_END__;
f0104e08:	bb 5c 39 11 f0       	mov    $0xf011395c,%ebx
		stabs = __STAB_BEGIN__;
f0104e0d:	c7 45 bc 74 82 10 f0 	movl   $0xf0108274,-0x44(%ebp)
		if(user_mem_check(curenv,(void *)stabstr,stabstr_end-stabstr,PTE_U)<0)
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104e14:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0104e17:	39 4d b4             	cmp    %ecx,-0x4c(%ebp)
f0104e1a:	0f 83 97 02 00 00    	jae    f01050b7 <debuginfo_eip+0x2fd>
f0104e20:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f0104e24:	0f 85 94 02 00 00    	jne    f01050be <debuginfo_eip+0x304>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104e2a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104e31:	2b 5d bc             	sub    -0x44(%ebp),%ebx
f0104e34:	c1 fb 02             	sar    $0x2,%ebx
f0104e37:	69 c3 ab aa aa aa    	imul   $0xaaaaaaab,%ebx,%eax
f0104e3d:	83 e8 01             	sub    $0x1,%eax
f0104e40:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104e43:	83 ec 08             	sub    $0x8,%esp
f0104e46:	57                   	push   %edi
f0104e47:	6a 64                	push   $0x64
f0104e49:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0104e4c:	89 d1                	mov    %edx,%ecx
f0104e4e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104e51:	8b 5d bc             	mov    -0x44(%ebp),%ebx
f0104e54:	89 d8                	mov    %ebx,%eax
f0104e56:	e8 6f fe ff ff       	call   f0104cca <stab_binsearch>
	if (lfile == 0)
f0104e5b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e5e:	83 c4 10             	add    $0x10,%esp
f0104e61:	85 c0                	test   %eax,%eax
f0104e63:	0f 84 5c 02 00 00    	je     f01050c5 <debuginfo_eip+0x30b>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104e69:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104e6c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104e6f:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104e72:	83 ec 08             	sub    $0x8,%esp
f0104e75:	57                   	push   %edi
f0104e76:	6a 24                	push   $0x24
f0104e78:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0104e7b:	89 d1                	mov    %edx,%ecx
f0104e7d:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104e80:	89 d8                	mov    %ebx,%eax
f0104e82:	e8 43 fe ff ff       	call   f0104cca <stab_binsearch>

	if (lfun <= rfun) {
f0104e87:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104e8a:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104e8d:	83 c4 10             	add    $0x10,%esp
f0104e90:	39 d0                	cmp    %edx,%eax
f0104e92:	0f 8f 3d 01 00 00    	jg     f0104fd5 <debuginfo_eip+0x21b>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104e98:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0104e9b:	8d 1c 8b             	lea    (%ebx,%ecx,4),%ebx
f0104e9e:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
f0104ea1:	8b 1b                	mov    (%ebx),%ebx
f0104ea3:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0104ea6:	2b 4d b4             	sub    -0x4c(%ebp),%ecx
f0104ea9:	39 cb                	cmp    %ecx,%ebx
f0104eab:	73 06                	jae    f0104eb3 <debuginfo_eip+0xf9>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104ead:	03 5d b4             	add    -0x4c(%ebp),%ebx
f0104eb0:	89 5e 08             	mov    %ebx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104eb3:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0104eb6:	8b 4b 08             	mov    0x8(%ebx),%ecx
f0104eb9:	89 4e 10             	mov    %ecx,0x10(%esi)
		addr -= info->eip_fn_addr;
f0104ebc:	29 cf                	sub    %ecx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0104ebe:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104ec1:	89 55 d0             	mov    %edx,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104ec4:	83 ec 08             	sub    $0x8,%esp
f0104ec7:	6a 3a                	push   $0x3a
f0104ec9:	ff 76 08             	pushl  0x8(%esi)
f0104ecc:	e8 1a 0a 00 00       	call   f01058eb <strfind>
f0104ed1:	2b 46 08             	sub    0x8(%esi),%eax
f0104ed4:	89 46 0c             	mov    %eax,0xc(%esi)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
        stab_binsearch(stabs,&lline,&rline,N_SLINE,addr);
f0104ed7:	83 c4 08             	add    $0x8,%esp
f0104eda:	57                   	push   %edi
f0104edb:	6a 44                	push   $0x44
f0104edd:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104ee0:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104ee3:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0104ee6:	89 f8                	mov    %edi,%eax
f0104ee8:	e8 dd fd ff ff       	call   f0104cca <stab_binsearch>
	if(lline<=rline){
f0104eed:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104ef0:	83 c4 10             	add    $0x10,%esp
f0104ef3:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0104ef6:	0f 8f ed 00 00 00    	jg     f0104fe9 <debuginfo_eip+0x22f>
           info->eip_line = stabs[lline].n_desc;
f0104efc:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104eff:	0f b7 44 87 06       	movzwl 0x6(%edi,%eax,4),%eax
f0104f04:	89 46 04             	mov    %eax,0x4(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104f07:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104f0a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104f0d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104f10:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0104f13:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f0104f17:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0104f1b:	bf 01 00 00 00       	mov    $0x1,%edi
f0104f20:	89 75 0c             	mov    %esi,0xc(%ebp)
f0104f23:	e9 e1 00 00 00       	jmp    f0105009 <debuginfo_eip+0x24f>
		stabs = usd->stabs;
f0104f28:	8b 0d 00 00 20 00    	mov    0x200000,%ecx
f0104f2e:	89 4d bc             	mov    %ecx,-0x44(%ebp)
		stab_end = usd->stab_end;
f0104f31:	8b 1d 04 00 20 00    	mov    0x200004,%ebx
		stabstr = usd->stabstr;
f0104f37:	a1 08 00 20 00       	mov    0x200008,%eax
f0104f3c:	89 45 b4             	mov    %eax,-0x4c(%ebp)
		stabstr_end = usd->stabstr_end;
f0104f3f:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0104f45:	89 55 b8             	mov    %edx,-0x48(%ebp)
		if(user_mem_check(curenv,(void *)usd,sizeof(struct UserStabData),PTE_U)<0)
f0104f48:	e8 de 0f 00 00       	call   f0105f2b <cpunum>
f0104f4d:	6a 04                	push   $0x4
f0104f4f:	6a 10                	push   $0x10
f0104f51:	68 00 00 20 00       	push   $0x200000
f0104f56:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f59:	ff b0 28 50 23 f0    	pushl  -0xfdcafd8(%eax)
f0104f5f:	e8 86 df ff ff       	call   f0102eea <user_mem_check>
f0104f64:	83 c4 10             	add    $0x10,%esp
f0104f67:	85 c0                	test   %eax,%eax
f0104f69:	0f 88 3a 01 00 00    	js     f01050a9 <debuginfo_eip+0x2ef>
		if(user_mem_check(curenv,(void *)stabs,stab_end-stabs,PTE_U)<0)
f0104f6f:	e8 b7 0f 00 00       	call   f0105f2b <cpunum>
f0104f74:	6a 04                	push   $0x4
f0104f76:	89 da                	mov    %ebx,%edx
f0104f78:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0104f7b:	29 ca                	sub    %ecx,%edx
f0104f7d:	c1 fa 02             	sar    $0x2,%edx
f0104f80:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0104f86:	52                   	push   %edx
f0104f87:	51                   	push   %ecx
f0104f88:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f8b:	ff b0 28 50 23 f0    	pushl  -0xfdcafd8(%eax)
f0104f91:	e8 54 df ff ff       	call   f0102eea <user_mem_check>
f0104f96:	83 c4 10             	add    $0x10,%esp
f0104f99:	85 c0                	test   %eax,%eax
f0104f9b:	0f 88 0f 01 00 00    	js     f01050b0 <debuginfo_eip+0x2f6>
		if(user_mem_check(curenv,(void *)stabstr,stabstr_end-stabstr,PTE_U)<0)
f0104fa1:	e8 85 0f 00 00       	call   f0105f2b <cpunum>
f0104fa6:	6a 04                	push   $0x4
f0104fa8:	8b 55 b8             	mov    -0x48(%ebp),%edx
f0104fab:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
f0104fae:	29 ca                	sub    %ecx,%edx
f0104fb0:	52                   	push   %edx
f0104fb1:	51                   	push   %ecx
f0104fb2:	6b c0 74             	imul   $0x74,%eax,%eax
f0104fb5:	ff b0 28 50 23 f0    	pushl  -0xfdcafd8(%eax)
f0104fbb:	e8 2a df ff ff       	call   f0102eea <user_mem_check>
f0104fc0:	83 c4 10             	add    $0x10,%esp
f0104fc3:	85 c0                	test   %eax,%eax
f0104fc5:	0f 89 49 fe ff ff    	jns    f0104e14 <debuginfo_eip+0x5a>
			return -1;
f0104fcb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104fd0:	e9 fc 00 00 00       	jmp    f01050d1 <debuginfo_eip+0x317>
		info->eip_fn_addr = addr;
f0104fd5:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0104fd8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104fdb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0104fde:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104fe1:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104fe4:	e9 db fe ff ff       	jmp    f0104ec4 <debuginfo_eip+0x10a>
		cprintf("line not find\n");
f0104fe9:	83 ec 0c             	sub    $0xc,%esp
f0104fec:	68 8e 7d 10 f0       	push   $0xf0107d8e
f0104ff1:	e8 4e e9 ff ff       	call   f0103944 <cprintf>
f0104ff6:	83 c4 10             	add    $0x10,%esp
f0104ff9:	e9 09 ff ff ff       	jmp    f0104f07 <debuginfo_eip+0x14d>
f0104ffe:	83 e8 01             	sub    $0x1,%eax
f0105001:	83 ea 0c             	sub    $0xc,%edx
f0105004:	89 f9                	mov    %edi,%ecx
f0105006:	88 4d c4             	mov    %cl,-0x3c(%ebp)
f0105009:	89 45 c0             	mov    %eax,-0x40(%ebp)
	while (lline >= lfile
f010500c:	39 c3                	cmp    %eax,%ebx
f010500e:	7f 24                	jg     f0105034 <debuginfo_eip+0x27a>
	       && stabs[lline].n_type != N_SOL
f0105010:	0f b6 0a             	movzbl (%edx),%ecx
f0105013:	80 f9 84             	cmp    $0x84,%cl
f0105016:	74 46                	je     f010505e <debuginfo_eip+0x2a4>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105018:	80 f9 64             	cmp    $0x64,%cl
f010501b:	75 e1                	jne    f0104ffe <debuginfo_eip+0x244>
f010501d:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f0105021:	74 db                	je     f0104ffe <debuginfo_eip+0x244>
f0105023:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105026:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f010502a:	74 3b                	je     f0105067 <debuginfo_eip+0x2ad>
f010502c:	8b 7d c0             	mov    -0x40(%ebp),%edi
f010502f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0105032:	eb 33                	jmp    f0105067 <debuginfo_eip+0x2ad>
f0105034:	8b 75 0c             	mov    0xc(%ebp),%esi
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105037:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010503a:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010503d:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0105042:	39 da                	cmp    %ebx,%edx
f0105044:	0f 8d 87 00 00 00    	jge    f01050d1 <debuginfo_eip+0x317>
		for (lline = lfun + 1;
f010504a:	83 c2 01             	add    $0x1,%edx
f010504d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0105050:	89 d0                	mov    %edx,%eax
f0105052:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0105055:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0105058:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f010505c:	eb 32                	jmp    f0105090 <debuginfo_eip+0x2d6>
f010505e:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105061:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0105065:	75 1d                	jne    f0105084 <debuginfo_eip+0x2ca>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0105067:	8d 04 40             	lea    (%eax,%eax,2),%eax
f010506a:	8b 7d bc             	mov    -0x44(%ebp),%edi
f010506d:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0105070:	8b 45 b8             	mov    -0x48(%ebp),%eax
f0105073:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f0105076:	29 f8                	sub    %edi,%eax
f0105078:	39 c2                	cmp    %eax,%edx
f010507a:	73 bb                	jae    f0105037 <debuginfo_eip+0x27d>
		info->eip_file = stabstr + stabs[lline].n_strx;
f010507c:	89 f8                	mov    %edi,%eax
f010507e:	01 d0                	add    %edx,%eax
f0105080:	89 06                	mov    %eax,(%esi)
f0105082:	eb b3                	jmp    f0105037 <debuginfo_eip+0x27d>
f0105084:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0105087:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010508a:	eb db                	jmp    f0105067 <debuginfo_eip+0x2ad>
			info->eip_fn_narg++;
f010508c:	83 46 14 01          	addl   $0x1,0x14(%esi)
		for (lline = lfun + 1;
f0105090:	39 c3                	cmp    %eax,%ebx
f0105092:	7e 38                	jle    f01050cc <debuginfo_eip+0x312>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105094:	0f b6 0a             	movzbl (%edx),%ecx
f0105097:	83 c0 01             	add    $0x1,%eax
f010509a:	83 c2 0c             	add    $0xc,%edx
f010509d:	80 f9 a0             	cmp    $0xa0,%cl
f01050a0:	74 ea                	je     f010508c <debuginfo_eip+0x2d2>
	return 0;
f01050a2:	b8 00 00 00 00       	mov    $0x0,%eax
f01050a7:	eb 28                	jmp    f01050d1 <debuginfo_eip+0x317>
			return -1;
f01050a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01050ae:	eb 21                	jmp    f01050d1 <debuginfo_eip+0x317>
			return -1;
f01050b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01050b5:	eb 1a                	jmp    f01050d1 <debuginfo_eip+0x317>
		return -1;
f01050b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01050bc:	eb 13                	jmp    f01050d1 <debuginfo_eip+0x317>
f01050be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01050c3:	eb 0c                	jmp    f01050d1 <debuginfo_eip+0x317>
		return -1;
f01050c5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01050ca:	eb 05                	jmp    f01050d1 <debuginfo_eip+0x317>
	return 0;
f01050cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01050d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01050d4:	5b                   	pop    %ebx
f01050d5:	5e                   	pop    %esi
f01050d6:	5f                   	pop    %edi
f01050d7:	5d                   	pop    %ebp
f01050d8:	c3                   	ret    

f01050d9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01050d9:	55                   	push   %ebp
f01050da:	89 e5                	mov    %esp,%ebp
f01050dc:	57                   	push   %edi
f01050dd:	56                   	push   %esi
f01050de:	53                   	push   %ebx
f01050df:	83 ec 1c             	sub    $0x1c,%esp
f01050e2:	89 c7                	mov    %eax,%edi
f01050e4:	89 d6                	mov    %edx,%esi
f01050e6:	8b 45 08             	mov    0x8(%ebp),%eax
f01050e9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01050ec:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01050ef:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01050f2:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01050f5:	bb 00 00 00 00       	mov    $0x0,%ebx
f01050fa:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01050fd:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0105100:	39 d3                	cmp    %edx,%ebx
f0105102:	72 05                	jb     f0105109 <printnum+0x30>
f0105104:	39 45 10             	cmp    %eax,0x10(%ebp)
f0105107:	77 7a                	ja     f0105183 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0105109:	83 ec 0c             	sub    $0xc,%esp
f010510c:	ff 75 18             	pushl  0x18(%ebp)
f010510f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105112:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0105115:	53                   	push   %ebx
f0105116:	ff 75 10             	pushl  0x10(%ebp)
f0105119:	83 ec 08             	sub    $0x8,%esp
f010511c:	ff 75 e4             	pushl  -0x1c(%ebp)
f010511f:	ff 75 e0             	pushl  -0x20(%ebp)
f0105122:	ff 75 dc             	pushl  -0x24(%ebp)
f0105125:	ff 75 d8             	pushl  -0x28(%ebp)
f0105128:	e8 f3 11 00 00       	call   f0106320 <__udivdi3>
f010512d:	83 c4 18             	add    $0x18,%esp
f0105130:	52                   	push   %edx
f0105131:	50                   	push   %eax
f0105132:	89 f2                	mov    %esi,%edx
f0105134:	89 f8                	mov    %edi,%eax
f0105136:	e8 9e ff ff ff       	call   f01050d9 <printnum>
f010513b:	83 c4 20             	add    $0x20,%esp
f010513e:	eb 13                	jmp    f0105153 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0105140:	83 ec 08             	sub    $0x8,%esp
f0105143:	56                   	push   %esi
f0105144:	ff 75 18             	pushl  0x18(%ebp)
f0105147:	ff d7                	call   *%edi
f0105149:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f010514c:	83 eb 01             	sub    $0x1,%ebx
f010514f:	85 db                	test   %ebx,%ebx
f0105151:	7f ed                	jg     f0105140 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0105153:	83 ec 08             	sub    $0x8,%esp
f0105156:	56                   	push   %esi
f0105157:	83 ec 04             	sub    $0x4,%esp
f010515a:	ff 75 e4             	pushl  -0x1c(%ebp)
f010515d:	ff 75 e0             	pushl  -0x20(%ebp)
f0105160:	ff 75 dc             	pushl  -0x24(%ebp)
f0105163:	ff 75 d8             	pushl  -0x28(%ebp)
f0105166:	e8 d5 12 00 00       	call   f0106440 <__umoddi3>
f010516b:	83 c4 14             	add    $0x14,%esp
f010516e:	0f be 80 9d 7d 10 f0 	movsbl -0xfef8263(%eax),%eax
f0105175:	50                   	push   %eax
f0105176:	ff d7                	call   *%edi
}
f0105178:	83 c4 10             	add    $0x10,%esp
f010517b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010517e:	5b                   	pop    %ebx
f010517f:	5e                   	pop    %esi
f0105180:	5f                   	pop    %edi
f0105181:	5d                   	pop    %ebp
f0105182:	c3                   	ret    
f0105183:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0105186:	eb c4                	jmp    f010514c <printnum+0x73>

f0105188 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105188:	55                   	push   %ebp
f0105189:	89 e5                	mov    %esp,%ebp
f010518b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f010518e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0105192:	8b 10                	mov    (%eax),%edx
f0105194:	3b 50 04             	cmp    0x4(%eax),%edx
f0105197:	73 0a                	jae    f01051a3 <sprintputch+0x1b>
		*b->buf++ = ch;
f0105199:	8d 4a 01             	lea    0x1(%edx),%ecx
f010519c:	89 08                	mov    %ecx,(%eax)
f010519e:	8b 45 08             	mov    0x8(%ebp),%eax
f01051a1:	88 02                	mov    %al,(%edx)
}
f01051a3:	5d                   	pop    %ebp
f01051a4:	c3                   	ret    

f01051a5 <printfmt>:
{
f01051a5:	55                   	push   %ebp
f01051a6:	89 e5                	mov    %esp,%ebp
f01051a8:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f01051ab:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01051ae:	50                   	push   %eax
f01051af:	ff 75 10             	pushl  0x10(%ebp)
f01051b2:	ff 75 0c             	pushl  0xc(%ebp)
f01051b5:	ff 75 08             	pushl  0x8(%ebp)
f01051b8:	e8 05 00 00 00       	call   f01051c2 <vprintfmt>
}
f01051bd:	83 c4 10             	add    $0x10,%esp
f01051c0:	c9                   	leave  
f01051c1:	c3                   	ret    

f01051c2 <vprintfmt>:
{
f01051c2:	55                   	push   %ebp
f01051c3:	89 e5                	mov    %esp,%ebp
f01051c5:	57                   	push   %edi
f01051c6:	56                   	push   %esi
f01051c7:	53                   	push   %ebx
f01051c8:	83 ec 2c             	sub    $0x2c,%esp
f01051cb:	8b 75 08             	mov    0x8(%ebp),%esi
f01051ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01051d1:	8b 7d 10             	mov    0x10(%ebp),%edi
f01051d4:	e9 c1 03 00 00       	jmp    f010559a <vprintfmt+0x3d8>
		padc = ' ';
f01051d9:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f01051dd:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f01051e4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
f01051eb:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f01051f2:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f01051f7:	8d 47 01             	lea    0x1(%edi),%eax
f01051fa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01051fd:	0f b6 17             	movzbl (%edi),%edx
f0105200:	8d 42 dd             	lea    -0x23(%edx),%eax
f0105203:	3c 55                	cmp    $0x55,%al
f0105205:	0f 87 12 04 00 00    	ja     f010561d <vprintfmt+0x45b>
f010520b:	0f b6 c0             	movzbl %al,%eax
f010520e:	ff 24 85 60 7e 10 f0 	jmp    *-0xfef81a0(,%eax,4)
f0105215:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0105218:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f010521c:	eb d9                	jmp    f01051f7 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f010521e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f0105221:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0105225:	eb d0                	jmp    f01051f7 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f0105227:	0f b6 d2             	movzbl %dl,%edx
f010522a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f010522d:	b8 00 00 00 00       	mov    $0x0,%eax
f0105232:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f0105235:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0105238:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f010523c:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f010523f:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0105242:	83 f9 09             	cmp    $0x9,%ecx
f0105245:	77 55                	ja     f010529c <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
f0105247:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f010524a:	eb e9                	jmp    f0105235 <vprintfmt+0x73>
			precision = va_arg(ap, int);
f010524c:	8b 45 14             	mov    0x14(%ebp),%eax
f010524f:	8b 00                	mov    (%eax),%eax
f0105251:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0105254:	8b 45 14             	mov    0x14(%ebp),%eax
f0105257:	8d 40 04             	lea    0x4(%eax),%eax
f010525a:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010525d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0105260:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105264:	79 91                	jns    f01051f7 <vprintfmt+0x35>
				width = precision, precision = -1;
f0105266:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105269:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010526c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0105273:	eb 82                	jmp    f01051f7 <vprintfmt+0x35>
f0105275:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105278:	85 c0                	test   %eax,%eax
f010527a:	ba 00 00 00 00       	mov    $0x0,%edx
f010527f:	0f 49 d0             	cmovns %eax,%edx
f0105282:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0105285:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105288:	e9 6a ff ff ff       	jmp    f01051f7 <vprintfmt+0x35>
f010528d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0105290:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0105297:	e9 5b ff ff ff       	jmp    f01051f7 <vprintfmt+0x35>
f010529c:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f010529f:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01052a2:	eb bc                	jmp    f0105260 <vprintfmt+0x9e>
			lflag++;
f01052a4:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f01052a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f01052aa:	e9 48 ff ff ff       	jmp    f01051f7 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
f01052af:	8b 45 14             	mov    0x14(%ebp),%eax
f01052b2:	8d 78 04             	lea    0x4(%eax),%edi
f01052b5:	83 ec 08             	sub    $0x8,%esp
f01052b8:	53                   	push   %ebx
f01052b9:	ff 30                	pushl  (%eax)
f01052bb:	ff d6                	call   *%esi
			break;
f01052bd:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f01052c0:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f01052c3:	e9 cf 02 00 00       	jmp    f0105597 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
f01052c8:	8b 45 14             	mov    0x14(%ebp),%eax
f01052cb:	8d 78 04             	lea    0x4(%eax),%edi
f01052ce:	8b 00                	mov    (%eax),%eax
f01052d0:	99                   	cltd   
f01052d1:	31 d0                	xor    %edx,%eax
f01052d3:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01052d5:	83 f8 08             	cmp    $0x8,%eax
f01052d8:	7f 23                	jg     f01052fd <vprintfmt+0x13b>
f01052da:	8b 14 85 c0 7f 10 f0 	mov    -0xfef8040(,%eax,4),%edx
f01052e1:	85 d2                	test   %edx,%edx
f01052e3:	74 18                	je     f01052fd <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
f01052e5:	52                   	push   %edx
f01052e6:	68 81 74 10 f0       	push   $0xf0107481
f01052eb:	53                   	push   %ebx
f01052ec:	56                   	push   %esi
f01052ed:	e8 b3 fe ff ff       	call   f01051a5 <printfmt>
f01052f2:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01052f5:	89 7d 14             	mov    %edi,0x14(%ebp)
f01052f8:	e9 9a 02 00 00       	jmp    f0105597 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
f01052fd:	50                   	push   %eax
f01052fe:	68 b5 7d 10 f0       	push   $0xf0107db5
f0105303:	53                   	push   %ebx
f0105304:	56                   	push   %esi
f0105305:	e8 9b fe ff ff       	call   f01051a5 <printfmt>
f010530a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f010530d:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0105310:	e9 82 02 00 00       	jmp    f0105597 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
f0105315:	8b 45 14             	mov    0x14(%ebp),%eax
f0105318:	83 c0 04             	add    $0x4,%eax
f010531b:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010531e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105321:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0105323:	85 ff                	test   %edi,%edi
f0105325:	b8 ae 7d 10 f0       	mov    $0xf0107dae,%eax
f010532a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f010532d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105331:	0f 8e bd 00 00 00    	jle    f01053f4 <vprintfmt+0x232>
f0105337:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f010533b:	75 0e                	jne    f010534b <vprintfmt+0x189>
f010533d:	89 75 08             	mov    %esi,0x8(%ebp)
f0105340:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105343:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105346:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105349:	eb 6d                	jmp    f01053b8 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
f010534b:	83 ec 08             	sub    $0x8,%esp
f010534e:	ff 75 d0             	pushl  -0x30(%ebp)
f0105351:	57                   	push   %edi
f0105352:	e8 50 04 00 00       	call   f01057a7 <strnlen>
f0105357:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010535a:	29 c1                	sub    %eax,%ecx
f010535c:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f010535f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0105362:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0105366:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105369:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010536c:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f010536e:	eb 0f                	jmp    f010537f <vprintfmt+0x1bd>
					putch(padc, putdat);
f0105370:	83 ec 08             	sub    $0x8,%esp
f0105373:	53                   	push   %ebx
f0105374:	ff 75 e0             	pushl  -0x20(%ebp)
f0105377:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0105379:	83 ef 01             	sub    $0x1,%edi
f010537c:	83 c4 10             	add    $0x10,%esp
f010537f:	85 ff                	test   %edi,%edi
f0105381:	7f ed                	jg     f0105370 <vprintfmt+0x1ae>
f0105383:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0105386:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0105389:	85 c9                	test   %ecx,%ecx
f010538b:	b8 00 00 00 00       	mov    $0x0,%eax
f0105390:	0f 49 c1             	cmovns %ecx,%eax
f0105393:	29 c1                	sub    %eax,%ecx
f0105395:	89 75 08             	mov    %esi,0x8(%ebp)
f0105398:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010539b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f010539e:	89 cb                	mov    %ecx,%ebx
f01053a0:	eb 16                	jmp    f01053b8 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
f01053a2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01053a6:	75 31                	jne    f01053d9 <vprintfmt+0x217>
					putch(ch, putdat);
f01053a8:	83 ec 08             	sub    $0x8,%esp
f01053ab:	ff 75 0c             	pushl  0xc(%ebp)
f01053ae:	50                   	push   %eax
f01053af:	ff 55 08             	call   *0x8(%ebp)
f01053b2:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01053b5:	83 eb 01             	sub    $0x1,%ebx
f01053b8:	83 c7 01             	add    $0x1,%edi
f01053bb:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f01053bf:	0f be c2             	movsbl %dl,%eax
f01053c2:	85 c0                	test   %eax,%eax
f01053c4:	74 59                	je     f010541f <vprintfmt+0x25d>
f01053c6:	85 f6                	test   %esi,%esi
f01053c8:	78 d8                	js     f01053a2 <vprintfmt+0x1e0>
f01053ca:	83 ee 01             	sub    $0x1,%esi
f01053cd:	79 d3                	jns    f01053a2 <vprintfmt+0x1e0>
f01053cf:	89 df                	mov    %ebx,%edi
f01053d1:	8b 75 08             	mov    0x8(%ebp),%esi
f01053d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01053d7:	eb 37                	jmp    f0105410 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
f01053d9:	0f be d2             	movsbl %dl,%edx
f01053dc:	83 ea 20             	sub    $0x20,%edx
f01053df:	83 fa 5e             	cmp    $0x5e,%edx
f01053e2:	76 c4                	jbe    f01053a8 <vprintfmt+0x1e6>
					putch('?', putdat);
f01053e4:	83 ec 08             	sub    $0x8,%esp
f01053e7:	ff 75 0c             	pushl  0xc(%ebp)
f01053ea:	6a 3f                	push   $0x3f
f01053ec:	ff 55 08             	call   *0x8(%ebp)
f01053ef:	83 c4 10             	add    $0x10,%esp
f01053f2:	eb c1                	jmp    f01053b5 <vprintfmt+0x1f3>
f01053f4:	89 75 08             	mov    %esi,0x8(%ebp)
f01053f7:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01053fa:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01053fd:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105400:	eb b6                	jmp    f01053b8 <vprintfmt+0x1f6>
				putch(' ', putdat);
f0105402:	83 ec 08             	sub    $0x8,%esp
f0105405:	53                   	push   %ebx
f0105406:	6a 20                	push   $0x20
f0105408:	ff d6                	call   *%esi
			for (; width > 0; width--)
f010540a:	83 ef 01             	sub    $0x1,%edi
f010540d:	83 c4 10             	add    $0x10,%esp
f0105410:	85 ff                	test   %edi,%edi
f0105412:	7f ee                	jg     f0105402 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
f0105414:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0105417:	89 45 14             	mov    %eax,0x14(%ebp)
f010541a:	e9 78 01 00 00       	jmp    f0105597 <vprintfmt+0x3d5>
f010541f:	89 df                	mov    %ebx,%edi
f0105421:	8b 75 08             	mov    0x8(%ebp),%esi
f0105424:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105427:	eb e7                	jmp    f0105410 <vprintfmt+0x24e>
	if (lflag >= 2)
f0105429:	83 f9 01             	cmp    $0x1,%ecx
f010542c:	7e 3f                	jle    f010546d <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
f010542e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105431:	8b 50 04             	mov    0x4(%eax),%edx
f0105434:	8b 00                	mov    (%eax),%eax
f0105436:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105439:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010543c:	8b 45 14             	mov    0x14(%ebp),%eax
f010543f:	8d 40 08             	lea    0x8(%eax),%eax
f0105442:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0105445:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105449:	79 5c                	jns    f01054a7 <vprintfmt+0x2e5>
				putch('-', putdat);
f010544b:	83 ec 08             	sub    $0x8,%esp
f010544e:	53                   	push   %ebx
f010544f:	6a 2d                	push   $0x2d
f0105451:	ff d6                	call   *%esi
				num = -(long long) num;
f0105453:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105456:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0105459:	f7 da                	neg    %edx
f010545b:	83 d1 00             	adc    $0x0,%ecx
f010545e:	f7 d9                	neg    %ecx
f0105460:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0105463:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105468:	e9 10 01 00 00       	jmp    f010557d <vprintfmt+0x3bb>
	else if (lflag)
f010546d:	85 c9                	test   %ecx,%ecx
f010546f:	75 1b                	jne    f010548c <vprintfmt+0x2ca>
		return va_arg(*ap, int);
f0105471:	8b 45 14             	mov    0x14(%ebp),%eax
f0105474:	8b 00                	mov    (%eax),%eax
f0105476:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105479:	89 c1                	mov    %eax,%ecx
f010547b:	c1 f9 1f             	sar    $0x1f,%ecx
f010547e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105481:	8b 45 14             	mov    0x14(%ebp),%eax
f0105484:	8d 40 04             	lea    0x4(%eax),%eax
f0105487:	89 45 14             	mov    %eax,0x14(%ebp)
f010548a:	eb b9                	jmp    f0105445 <vprintfmt+0x283>
		return va_arg(*ap, long);
f010548c:	8b 45 14             	mov    0x14(%ebp),%eax
f010548f:	8b 00                	mov    (%eax),%eax
f0105491:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105494:	89 c1                	mov    %eax,%ecx
f0105496:	c1 f9 1f             	sar    $0x1f,%ecx
f0105499:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010549c:	8b 45 14             	mov    0x14(%ebp),%eax
f010549f:	8d 40 04             	lea    0x4(%eax),%eax
f01054a2:	89 45 14             	mov    %eax,0x14(%ebp)
f01054a5:	eb 9e                	jmp    f0105445 <vprintfmt+0x283>
			num = getint(&ap, lflag);
f01054a7:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01054aa:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f01054ad:	b8 0a 00 00 00       	mov    $0xa,%eax
f01054b2:	e9 c6 00 00 00       	jmp    f010557d <vprintfmt+0x3bb>
	if (lflag >= 2)
f01054b7:	83 f9 01             	cmp    $0x1,%ecx
f01054ba:	7e 18                	jle    f01054d4 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
f01054bc:	8b 45 14             	mov    0x14(%ebp),%eax
f01054bf:	8b 10                	mov    (%eax),%edx
f01054c1:	8b 48 04             	mov    0x4(%eax),%ecx
f01054c4:	8d 40 08             	lea    0x8(%eax),%eax
f01054c7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01054ca:	b8 0a 00 00 00       	mov    $0xa,%eax
f01054cf:	e9 a9 00 00 00       	jmp    f010557d <vprintfmt+0x3bb>
	else if (lflag)
f01054d4:	85 c9                	test   %ecx,%ecx
f01054d6:	75 1a                	jne    f01054f2 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
f01054d8:	8b 45 14             	mov    0x14(%ebp),%eax
f01054db:	8b 10                	mov    (%eax),%edx
f01054dd:	b9 00 00 00 00       	mov    $0x0,%ecx
f01054e2:	8d 40 04             	lea    0x4(%eax),%eax
f01054e5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01054e8:	b8 0a 00 00 00       	mov    $0xa,%eax
f01054ed:	e9 8b 00 00 00       	jmp    f010557d <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
f01054f2:	8b 45 14             	mov    0x14(%ebp),%eax
f01054f5:	8b 10                	mov    (%eax),%edx
f01054f7:	b9 00 00 00 00       	mov    $0x0,%ecx
f01054fc:	8d 40 04             	lea    0x4(%eax),%eax
f01054ff:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0105502:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105507:	eb 74                	jmp    f010557d <vprintfmt+0x3bb>
	if (lflag >= 2)
f0105509:	83 f9 01             	cmp    $0x1,%ecx
f010550c:	7e 15                	jle    f0105523 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
f010550e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105511:	8b 10                	mov    (%eax),%edx
f0105513:	8b 48 04             	mov    0x4(%eax),%ecx
f0105516:	8d 40 08             	lea    0x8(%eax),%eax
f0105519:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f010551c:	b8 08 00 00 00       	mov    $0x8,%eax
f0105521:	eb 5a                	jmp    f010557d <vprintfmt+0x3bb>
	else if (lflag)
f0105523:	85 c9                	test   %ecx,%ecx
f0105525:	75 17                	jne    f010553e <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
f0105527:	8b 45 14             	mov    0x14(%ebp),%eax
f010552a:	8b 10                	mov    (%eax),%edx
f010552c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105531:	8d 40 04             	lea    0x4(%eax),%eax
f0105534:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0105537:	b8 08 00 00 00       	mov    $0x8,%eax
f010553c:	eb 3f                	jmp    f010557d <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
f010553e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105541:	8b 10                	mov    (%eax),%edx
f0105543:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105548:	8d 40 04             	lea    0x4(%eax),%eax
f010554b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f010554e:	b8 08 00 00 00       	mov    $0x8,%eax
f0105553:	eb 28                	jmp    f010557d <vprintfmt+0x3bb>
			putch('0', putdat);
f0105555:	83 ec 08             	sub    $0x8,%esp
f0105558:	53                   	push   %ebx
f0105559:	6a 30                	push   $0x30
f010555b:	ff d6                	call   *%esi
			putch('x', putdat);
f010555d:	83 c4 08             	add    $0x8,%esp
f0105560:	53                   	push   %ebx
f0105561:	6a 78                	push   $0x78
f0105563:	ff d6                	call   *%esi
			num = (unsigned long long)
f0105565:	8b 45 14             	mov    0x14(%ebp),%eax
f0105568:	8b 10                	mov    (%eax),%edx
f010556a:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f010556f:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0105572:	8d 40 04             	lea    0x4(%eax),%eax
f0105575:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105578:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f010557d:	83 ec 0c             	sub    $0xc,%esp
f0105580:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0105584:	57                   	push   %edi
f0105585:	ff 75 e0             	pushl  -0x20(%ebp)
f0105588:	50                   	push   %eax
f0105589:	51                   	push   %ecx
f010558a:	52                   	push   %edx
f010558b:	89 da                	mov    %ebx,%edx
f010558d:	89 f0                	mov    %esi,%eax
f010558f:	e8 45 fb ff ff       	call   f01050d9 <printnum>
			break;
f0105594:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f0105597:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f010559a:	83 c7 01             	add    $0x1,%edi
f010559d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01055a1:	83 f8 25             	cmp    $0x25,%eax
f01055a4:	0f 84 2f fc ff ff    	je     f01051d9 <vprintfmt+0x17>
			if (ch == '\0')
f01055aa:	85 c0                	test   %eax,%eax
f01055ac:	0f 84 8b 00 00 00    	je     f010563d <vprintfmt+0x47b>
			putch(ch, putdat);
f01055b2:	83 ec 08             	sub    $0x8,%esp
f01055b5:	53                   	push   %ebx
f01055b6:	50                   	push   %eax
f01055b7:	ff d6                	call   *%esi
f01055b9:	83 c4 10             	add    $0x10,%esp
f01055bc:	eb dc                	jmp    f010559a <vprintfmt+0x3d8>
	if (lflag >= 2)
f01055be:	83 f9 01             	cmp    $0x1,%ecx
f01055c1:	7e 15                	jle    f01055d8 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
f01055c3:	8b 45 14             	mov    0x14(%ebp),%eax
f01055c6:	8b 10                	mov    (%eax),%edx
f01055c8:	8b 48 04             	mov    0x4(%eax),%ecx
f01055cb:	8d 40 08             	lea    0x8(%eax),%eax
f01055ce:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01055d1:	b8 10 00 00 00       	mov    $0x10,%eax
f01055d6:	eb a5                	jmp    f010557d <vprintfmt+0x3bb>
	else if (lflag)
f01055d8:	85 c9                	test   %ecx,%ecx
f01055da:	75 17                	jne    f01055f3 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
f01055dc:	8b 45 14             	mov    0x14(%ebp),%eax
f01055df:	8b 10                	mov    (%eax),%edx
f01055e1:	b9 00 00 00 00       	mov    $0x0,%ecx
f01055e6:	8d 40 04             	lea    0x4(%eax),%eax
f01055e9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01055ec:	b8 10 00 00 00       	mov    $0x10,%eax
f01055f1:	eb 8a                	jmp    f010557d <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
f01055f3:	8b 45 14             	mov    0x14(%ebp),%eax
f01055f6:	8b 10                	mov    (%eax),%edx
f01055f8:	b9 00 00 00 00       	mov    $0x0,%ecx
f01055fd:	8d 40 04             	lea    0x4(%eax),%eax
f0105600:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105603:	b8 10 00 00 00       	mov    $0x10,%eax
f0105608:	e9 70 ff ff ff       	jmp    f010557d <vprintfmt+0x3bb>
			putch(ch, putdat);
f010560d:	83 ec 08             	sub    $0x8,%esp
f0105610:	53                   	push   %ebx
f0105611:	6a 25                	push   $0x25
f0105613:	ff d6                	call   *%esi
			break;
f0105615:	83 c4 10             	add    $0x10,%esp
f0105618:	e9 7a ff ff ff       	jmp    f0105597 <vprintfmt+0x3d5>
			putch('%', putdat);
f010561d:	83 ec 08             	sub    $0x8,%esp
f0105620:	53                   	push   %ebx
f0105621:	6a 25                	push   $0x25
f0105623:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105625:	83 c4 10             	add    $0x10,%esp
f0105628:	89 f8                	mov    %edi,%eax
f010562a:	eb 03                	jmp    f010562f <vprintfmt+0x46d>
f010562c:	83 e8 01             	sub    $0x1,%eax
f010562f:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0105633:	75 f7                	jne    f010562c <vprintfmt+0x46a>
f0105635:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105638:	e9 5a ff ff ff       	jmp    f0105597 <vprintfmt+0x3d5>
}
f010563d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105640:	5b                   	pop    %ebx
f0105641:	5e                   	pop    %esi
f0105642:	5f                   	pop    %edi
f0105643:	5d                   	pop    %ebp
f0105644:	c3                   	ret    

f0105645 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105645:	55                   	push   %ebp
f0105646:	89 e5                	mov    %esp,%ebp
f0105648:	83 ec 18             	sub    $0x18,%esp
f010564b:	8b 45 08             	mov    0x8(%ebp),%eax
f010564e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105651:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105654:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105658:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010565b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105662:	85 c0                	test   %eax,%eax
f0105664:	74 26                	je     f010568c <vsnprintf+0x47>
f0105666:	85 d2                	test   %edx,%edx
f0105668:	7e 22                	jle    f010568c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010566a:	ff 75 14             	pushl  0x14(%ebp)
f010566d:	ff 75 10             	pushl  0x10(%ebp)
f0105670:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105673:	50                   	push   %eax
f0105674:	68 88 51 10 f0       	push   $0xf0105188
f0105679:	e8 44 fb ff ff       	call   f01051c2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010567e:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105681:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105684:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105687:	83 c4 10             	add    $0x10,%esp
}
f010568a:	c9                   	leave  
f010568b:	c3                   	ret    
		return -E_INVAL;
f010568c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105691:	eb f7                	jmp    f010568a <vsnprintf+0x45>

f0105693 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105693:	55                   	push   %ebp
f0105694:	89 e5                	mov    %esp,%ebp
f0105696:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105699:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010569c:	50                   	push   %eax
f010569d:	ff 75 10             	pushl  0x10(%ebp)
f01056a0:	ff 75 0c             	pushl  0xc(%ebp)
f01056a3:	ff 75 08             	pushl  0x8(%ebp)
f01056a6:	e8 9a ff ff ff       	call   f0105645 <vsnprintf>
	va_end(ap);

	return rc;
}
f01056ab:	c9                   	leave  
f01056ac:	c3                   	ret    

f01056ad <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01056ad:	55                   	push   %ebp
f01056ae:	89 e5                	mov    %esp,%ebp
f01056b0:	57                   	push   %edi
f01056b1:	56                   	push   %esi
f01056b2:	53                   	push   %ebx
f01056b3:	83 ec 0c             	sub    $0xc,%esp
f01056b6:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01056b9:	85 c0                	test   %eax,%eax
f01056bb:	74 11                	je     f01056ce <readline+0x21>
		cprintf("%s", prompt);
f01056bd:	83 ec 08             	sub    $0x8,%esp
f01056c0:	50                   	push   %eax
f01056c1:	68 81 74 10 f0       	push   $0xf0107481
f01056c6:	e8 79 e2 ff ff       	call   f0103944 <cprintf>
f01056cb:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01056ce:	83 ec 0c             	sub    $0xc,%esp
f01056d1:	6a 00                	push   $0x0
f01056d3:	e8 b1 b0 ff ff       	call   f0100789 <iscons>
f01056d8:	89 c7                	mov    %eax,%edi
f01056da:	83 c4 10             	add    $0x10,%esp
	i = 0;
f01056dd:	be 00 00 00 00       	mov    $0x0,%esi
f01056e2:	eb 3f                	jmp    f0105723 <readline+0x76>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f01056e4:	83 ec 08             	sub    $0x8,%esp
f01056e7:	50                   	push   %eax
f01056e8:	68 e4 7f 10 f0       	push   $0xf0107fe4
f01056ed:	e8 52 e2 ff ff       	call   f0103944 <cprintf>
			return NULL;
f01056f2:	83 c4 10             	add    $0x10,%esp
f01056f5:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f01056fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01056fd:	5b                   	pop    %ebx
f01056fe:	5e                   	pop    %esi
f01056ff:	5f                   	pop    %edi
f0105700:	5d                   	pop    %ebp
f0105701:	c3                   	ret    
			if (echoing)
f0105702:	85 ff                	test   %edi,%edi
f0105704:	75 05                	jne    f010570b <readline+0x5e>
			i--;
f0105706:	83 ee 01             	sub    $0x1,%esi
f0105709:	eb 18                	jmp    f0105723 <readline+0x76>
				cputchar('\b');
f010570b:	83 ec 0c             	sub    $0xc,%esp
f010570e:	6a 08                	push   $0x8
f0105710:	e8 53 b0 ff ff       	call   f0100768 <cputchar>
f0105715:	83 c4 10             	add    $0x10,%esp
f0105718:	eb ec                	jmp    f0105706 <readline+0x59>
			buf[i++] = c;
f010571a:	88 9e 80 4a 23 f0    	mov    %bl,-0xfdcb580(%esi)
f0105720:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
f0105723:	e8 50 b0 ff ff       	call   f0100778 <getchar>
f0105728:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010572a:	85 c0                	test   %eax,%eax
f010572c:	78 b6                	js     f01056e4 <readline+0x37>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010572e:	83 f8 08             	cmp    $0x8,%eax
f0105731:	0f 94 c2             	sete   %dl
f0105734:	83 f8 7f             	cmp    $0x7f,%eax
f0105737:	0f 94 c0             	sete   %al
f010573a:	08 c2                	or     %al,%dl
f010573c:	74 04                	je     f0105742 <readline+0x95>
f010573e:	85 f6                	test   %esi,%esi
f0105740:	7f c0                	jg     f0105702 <readline+0x55>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105742:	83 fb 1f             	cmp    $0x1f,%ebx
f0105745:	7e 1a                	jle    f0105761 <readline+0xb4>
f0105747:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010574d:	7f 12                	jg     f0105761 <readline+0xb4>
			if (echoing)
f010574f:	85 ff                	test   %edi,%edi
f0105751:	74 c7                	je     f010571a <readline+0x6d>
				cputchar(c);
f0105753:	83 ec 0c             	sub    $0xc,%esp
f0105756:	53                   	push   %ebx
f0105757:	e8 0c b0 ff ff       	call   f0100768 <cputchar>
f010575c:	83 c4 10             	add    $0x10,%esp
f010575f:	eb b9                	jmp    f010571a <readline+0x6d>
		} else if (c == '\n' || c == '\r') {
f0105761:	83 fb 0a             	cmp    $0xa,%ebx
f0105764:	74 05                	je     f010576b <readline+0xbe>
f0105766:	83 fb 0d             	cmp    $0xd,%ebx
f0105769:	75 b8                	jne    f0105723 <readline+0x76>
			if (echoing)
f010576b:	85 ff                	test   %edi,%edi
f010576d:	75 11                	jne    f0105780 <readline+0xd3>
			buf[i] = 0;
f010576f:	c6 86 80 4a 23 f0 00 	movb   $0x0,-0xfdcb580(%esi)
			return buf;
f0105776:	b8 80 4a 23 f0       	mov    $0xf0234a80,%eax
f010577b:	e9 7a ff ff ff       	jmp    f01056fa <readline+0x4d>
				cputchar('\n');
f0105780:	83 ec 0c             	sub    $0xc,%esp
f0105783:	6a 0a                	push   $0xa
f0105785:	e8 de af ff ff       	call   f0100768 <cputchar>
f010578a:	83 c4 10             	add    $0x10,%esp
f010578d:	eb e0                	jmp    f010576f <readline+0xc2>

f010578f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010578f:	55                   	push   %ebp
f0105790:	89 e5                	mov    %esp,%ebp
f0105792:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105795:	b8 00 00 00 00       	mov    $0x0,%eax
f010579a:	eb 03                	jmp    f010579f <strlen+0x10>
		n++;
f010579c:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f010579f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01057a3:	75 f7                	jne    f010579c <strlen+0xd>
	return n;
}
f01057a5:	5d                   	pop    %ebp
f01057a6:	c3                   	ret    

f01057a7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01057a7:	55                   	push   %ebp
f01057a8:	89 e5                	mov    %esp,%ebp
f01057aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01057ad:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01057b0:	b8 00 00 00 00       	mov    $0x0,%eax
f01057b5:	eb 03                	jmp    f01057ba <strnlen+0x13>
		n++;
f01057b7:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01057ba:	39 d0                	cmp    %edx,%eax
f01057bc:	74 06                	je     f01057c4 <strnlen+0x1d>
f01057be:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01057c2:	75 f3                	jne    f01057b7 <strnlen+0x10>
	return n;
}
f01057c4:	5d                   	pop    %ebp
f01057c5:	c3                   	ret    

f01057c6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01057c6:	55                   	push   %ebp
f01057c7:	89 e5                	mov    %esp,%ebp
f01057c9:	53                   	push   %ebx
f01057ca:	8b 45 08             	mov    0x8(%ebp),%eax
f01057cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01057d0:	89 c2                	mov    %eax,%edx
f01057d2:	83 c1 01             	add    $0x1,%ecx
f01057d5:	83 c2 01             	add    $0x1,%edx
f01057d8:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01057dc:	88 5a ff             	mov    %bl,-0x1(%edx)
f01057df:	84 db                	test   %bl,%bl
f01057e1:	75 ef                	jne    f01057d2 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01057e3:	5b                   	pop    %ebx
f01057e4:	5d                   	pop    %ebp
f01057e5:	c3                   	ret    

f01057e6 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01057e6:	55                   	push   %ebp
f01057e7:	89 e5                	mov    %esp,%ebp
f01057e9:	53                   	push   %ebx
f01057ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01057ed:	53                   	push   %ebx
f01057ee:	e8 9c ff ff ff       	call   f010578f <strlen>
f01057f3:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01057f6:	ff 75 0c             	pushl  0xc(%ebp)
f01057f9:	01 d8                	add    %ebx,%eax
f01057fb:	50                   	push   %eax
f01057fc:	e8 c5 ff ff ff       	call   f01057c6 <strcpy>
	return dst;
}
f0105801:	89 d8                	mov    %ebx,%eax
f0105803:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105806:	c9                   	leave  
f0105807:	c3                   	ret    

f0105808 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105808:	55                   	push   %ebp
f0105809:	89 e5                	mov    %esp,%ebp
f010580b:	56                   	push   %esi
f010580c:	53                   	push   %ebx
f010580d:	8b 75 08             	mov    0x8(%ebp),%esi
f0105810:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105813:	89 f3                	mov    %esi,%ebx
f0105815:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105818:	89 f2                	mov    %esi,%edx
f010581a:	eb 0f                	jmp    f010582b <strncpy+0x23>
		*dst++ = *src;
f010581c:	83 c2 01             	add    $0x1,%edx
f010581f:	0f b6 01             	movzbl (%ecx),%eax
f0105822:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105825:	80 39 01             	cmpb   $0x1,(%ecx)
f0105828:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
f010582b:	39 da                	cmp    %ebx,%edx
f010582d:	75 ed                	jne    f010581c <strncpy+0x14>
	}
	return ret;
}
f010582f:	89 f0                	mov    %esi,%eax
f0105831:	5b                   	pop    %ebx
f0105832:	5e                   	pop    %esi
f0105833:	5d                   	pop    %ebp
f0105834:	c3                   	ret    

f0105835 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105835:	55                   	push   %ebp
f0105836:	89 e5                	mov    %esp,%ebp
f0105838:	56                   	push   %esi
f0105839:	53                   	push   %ebx
f010583a:	8b 75 08             	mov    0x8(%ebp),%esi
f010583d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105840:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0105843:	89 f0                	mov    %esi,%eax
f0105845:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105849:	85 c9                	test   %ecx,%ecx
f010584b:	75 0b                	jne    f0105858 <strlcpy+0x23>
f010584d:	eb 17                	jmp    f0105866 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010584f:	83 c2 01             	add    $0x1,%edx
f0105852:	83 c0 01             	add    $0x1,%eax
f0105855:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f0105858:	39 d8                	cmp    %ebx,%eax
f010585a:	74 07                	je     f0105863 <strlcpy+0x2e>
f010585c:	0f b6 0a             	movzbl (%edx),%ecx
f010585f:	84 c9                	test   %cl,%cl
f0105861:	75 ec                	jne    f010584f <strlcpy+0x1a>
		*dst = '\0';
f0105863:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105866:	29 f0                	sub    %esi,%eax
}
f0105868:	5b                   	pop    %ebx
f0105869:	5e                   	pop    %esi
f010586a:	5d                   	pop    %ebp
f010586b:	c3                   	ret    

f010586c <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010586c:	55                   	push   %ebp
f010586d:	89 e5                	mov    %esp,%ebp
f010586f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105872:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105875:	eb 06                	jmp    f010587d <strcmp+0x11>
		p++, q++;
f0105877:	83 c1 01             	add    $0x1,%ecx
f010587a:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f010587d:	0f b6 01             	movzbl (%ecx),%eax
f0105880:	84 c0                	test   %al,%al
f0105882:	74 04                	je     f0105888 <strcmp+0x1c>
f0105884:	3a 02                	cmp    (%edx),%al
f0105886:	74 ef                	je     f0105877 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105888:	0f b6 c0             	movzbl %al,%eax
f010588b:	0f b6 12             	movzbl (%edx),%edx
f010588e:	29 d0                	sub    %edx,%eax
}
f0105890:	5d                   	pop    %ebp
f0105891:	c3                   	ret    

f0105892 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105892:	55                   	push   %ebp
f0105893:	89 e5                	mov    %esp,%ebp
f0105895:	53                   	push   %ebx
f0105896:	8b 45 08             	mov    0x8(%ebp),%eax
f0105899:	8b 55 0c             	mov    0xc(%ebp),%edx
f010589c:	89 c3                	mov    %eax,%ebx
f010589e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01058a1:	eb 06                	jmp    f01058a9 <strncmp+0x17>
		n--, p++, q++;
f01058a3:	83 c0 01             	add    $0x1,%eax
f01058a6:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f01058a9:	39 d8                	cmp    %ebx,%eax
f01058ab:	74 16                	je     f01058c3 <strncmp+0x31>
f01058ad:	0f b6 08             	movzbl (%eax),%ecx
f01058b0:	84 c9                	test   %cl,%cl
f01058b2:	74 04                	je     f01058b8 <strncmp+0x26>
f01058b4:	3a 0a                	cmp    (%edx),%cl
f01058b6:	74 eb                	je     f01058a3 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01058b8:	0f b6 00             	movzbl (%eax),%eax
f01058bb:	0f b6 12             	movzbl (%edx),%edx
f01058be:	29 d0                	sub    %edx,%eax
}
f01058c0:	5b                   	pop    %ebx
f01058c1:	5d                   	pop    %ebp
f01058c2:	c3                   	ret    
		return 0;
f01058c3:	b8 00 00 00 00       	mov    $0x0,%eax
f01058c8:	eb f6                	jmp    f01058c0 <strncmp+0x2e>

f01058ca <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01058ca:	55                   	push   %ebp
f01058cb:	89 e5                	mov    %esp,%ebp
f01058cd:	8b 45 08             	mov    0x8(%ebp),%eax
f01058d0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01058d4:	0f b6 10             	movzbl (%eax),%edx
f01058d7:	84 d2                	test   %dl,%dl
f01058d9:	74 09                	je     f01058e4 <strchr+0x1a>
		if (*s == c)
f01058db:	38 ca                	cmp    %cl,%dl
f01058dd:	74 0a                	je     f01058e9 <strchr+0x1f>
	for (; *s; s++)
f01058df:	83 c0 01             	add    $0x1,%eax
f01058e2:	eb f0                	jmp    f01058d4 <strchr+0xa>
			return (char *) s;
	return 0;
f01058e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01058e9:	5d                   	pop    %ebp
f01058ea:	c3                   	ret    

f01058eb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01058eb:	55                   	push   %ebp
f01058ec:	89 e5                	mov    %esp,%ebp
f01058ee:	8b 45 08             	mov    0x8(%ebp),%eax
f01058f1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01058f5:	eb 03                	jmp    f01058fa <strfind+0xf>
f01058f7:	83 c0 01             	add    $0x1,%eax
f01058fa:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01058fd:	38 ca                	cmp    %cl,%dl
f01058ff:	74 04                	je     f0105905 <strfind+0x1a>
f0105901:	84 d2                	test   %dl,%dl
f0105903:	75 f2                	jne    f01058f7 <strfind+0xc>
			break;
	return (char *) s;
}
f0105905:	5d                   	pop    %ebp
f0105906:	c3                   	ret    

f0105907 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105907:	55                   	push   %ebp
f0105908:	89 e5                	mov    %esp,%ebp
f010590a:	57                   	push   %edi
f010590b:	56                   	push   %esi
f010590c:	53                   	push   %ebx
f010590d:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105910:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105913:	85 c9                	test   %ecx,%ecx
f0105915:	74 13                	je     f010592a <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105917:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010591d:	75 05                	jne    f0105924 <memset+0x1d>
f010591f:	f6 c1 03             	test   $0x3,%cl
f0105922:	74 0d                	je     f0105931 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105924:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105927:	fc                   	cld    
f0105928:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010592a:	89 f8                	mov    %edi,%eax
f010592c:	5b                   	pop    %ebx
f010592d:	5e                   	pop    %esi
f010592e:	5f                   	pop    %edi
f010592f:	5d                   	pop    %ebp
f0105930:	c3                   	ret    
		c &= 0xFF;
f0105931:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105935:	89 d3                	mov    %edx,%ebx
f0105937:	c1 e3 08             	shl    $0x8,%ebx
f010593a:	89 d0                	mov    %edx,%eax
f010593c:	c1 e0 18             	shl    $0x18,%eax
f010593f:	89 d6                	mov    %edx,%esi
f0105941:	c1 e6 10             	shl    $0x10,%esi
f0105944:	09 f0                	or     %esi,%eax
f0105946:	09 c2                	or     %eax,%edx
f0105948:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f010594a:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f010594d:	89 d0                	mov    %edx,%eax
f010594f:	fc                   	cld    
f0105950:	f3 ab                	rep stos %eax,%es:(%edi)
f0105952:	eb d6                	jmp    f010592a <memset+0x23>

f0105954 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105954:	55                   	push   %ebp
f0105955:	89 e5                	mov    %esp,%ebp
f0105957:	57                   	push   %edi
f0105958:	56                   	push   %esi
f0105959:	8b 45 08             	mov    0x8(%ebp),%eax
f010595c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010595f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105962:	39 c6                	cmp    %eax,%esi
f0105964:	73 35                	jae    f010599b <memmove+0x47>
f0105966:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105969:	39 c2                	cmp    %eax,%edx
f010596b:	76 2e                	jbe    f010599b <memmove+0x47>
		s += n;
		d += n;
f010596d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105970:	89 d6                	mov    %edx,%esi
f0105972:	09 fe                	or     %edi,%esi
f0105974:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010597a:	74 0c                	je     f0105988 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010597c:	83 ef 01             	sub    $0x1,%edi
f010597f:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0105982:	fd                   	std    
f0105983:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105985:	fc                   	cld    
f0105986:	eb 21                	jmp    f01059a9 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105988:	f6 c1 03             	test   $0x3,%cl
f010598b:	75 ef                	jne    f010597c <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f010598d:	83 ef 04             	sub    $0x4,%edi
f0105990:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105993:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0105996:	fd                   	std    
f0105997:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105999:	eb ea                	jmp    f0105985 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010599b:	89 f2                	mov    %esi,%edx
f010599d:	09 c2                	or     %eax,%edx
f010599f:	f6 c2 03             	test   $0x3,%dl
f01059a2:	74 09                	je     f01059ad <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01059a4:	89 c7                	mov    %eax,%edi
f01059a6:	fc                   	cld    
f01059a7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01059a9:	5e                   	pop    %esi
f01059aa:	5f                   	pop    %edi
f01059ab:	5d                   	pop    %ebp
f01059ac:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01059ad:	f6 c1 03             	test   $0x3,%cl
f01059b0:	75 f2                	jne    f01059a4 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01059b2:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f01059b5:	89 c7                	mov    %eax,%edi
f01059b7:	fc                   	cld    
f01059b8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01059ba:	eb ed                	jmp    f01059a9 <memmove+0x55>

f01059bc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01059bc:	55                   	push   %ebp
f01059bd:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01059bf:	ff 75 10             	pushl  0x10(%ebp)
f01059c2:	ff 75 0c             	pushl  0xc(%ebp)
f01059c5:	ff 75 08             	pushl  0x8(%ebp)
f01059c8:	e8 87 ff ff ff       	call   f0105954 <memmove>
}
f01059cd:	c9                   	leave  
f01059ce:	c3                   	ret    

f01059cf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01059cf:	55                   	push   %ebp
f01059d0:	89 e5                	mov    %esp,%ebp
f01059d2:	56                   	push   %esi
f01059d3:	53                   	push   %ebx
f01059d4:	8b 45 08             	mov    0x8(%ebp),%eax
f01059d7:	8b 55 0c             	mov    0xc(%ebp),%edx
f01059da:	89 c6                	mov    %eax,%esi
f01059dc:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01059df:	39 f0                	cmp    %esi,%eax
f01059e1:	74 1c                	je     f01059ff <memcmp+0x30>
		if (*s1 != *s2)
f01059e3:	0f b6 08             	movzbl (%eax),%ecx
f01059e6:	0f b6 1a             	movzbl (%edx),%ebx
f01059e9:	38 d9                	cmp    %bl,%cl
f01059eb:	75 08                	jne    f01059f5 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f01059ed:	83 c0 01             	add    $0x1,%eax
f01059f0:	83 c2 01             	add    $0x1,%edx
f01059f3:	eb ea                	jmp    f01059df <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f01059f5:	0f b6 c1             	movzbl %cl,%eax
f01059f8:	0f b6 db             	movzbl %bl,%ebx
f01059fb:	29 d8                	sub    %ebx,%eax
f01059fd:	eb 05                	jmp    f0105a04 <memcmp+0x35>
	}

	return 0;
f01059ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105a04:	5b                   	pop    %ebx
f0105a05:	5e                   	pop    %esi
f0105a06:	5d                   	pop    %ebp
f0105a07:	c3                   	ret    

f0105a08 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105a08:	55                   	push   %ebp
f0105a09:	89 e5                	mov    %esp,%ebp
f0105a0b:	8b 45 08             	mov    0x8(%ebp),%eax
f0105a0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0105a11:	89 c2                	mov    %eax,%edx
f0105a13:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0105a16:	39 d0                	cmp    %edx,%eax
f0105a18:	73 09                	jae    f0105a23 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105a1a:	38 08                	cmp    %cl,(%eax)
f0105a1c:	74 05                	je     f0105a23 <memfind+0x1b>
	for (; s < ends; s++)
f0105a1e:	83 c0 01             	add    $0x1,%eax
f0105a21:	eb f3                	jmp    f0105a16 <memfind+0xe>
			break;
	return (void *) s;
}
f0105a23:	5d                   	pop    %ebp
f0105a24:	c3                   	ret    

f0105a25 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105a25:	55                   	push   %ebp
f0105a26:	89 e5                	mov    %esp,%ebp
f0105a28:	57                   	push   %edi
f0105a29:	56                   	push   %esi
f0105a2a:	53                   	push   %ebx
f0105a2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105a2e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105a31:	eb 03                	jmp    f0105a36 <strtol+0x11>
		s++;
f0105a33:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f0105a36:	0f b6 01             	movzbl (%ecx),%eax
f0105a39:	3c 20                	cmp    $0x20,%al
f0105a3b:	74 f6                	je     f0105a33 <strtol+0xe>
f0105a3d:	3c 09                	cmp    $0x9,%al
f0105a3f:	74 f2                	je     f0105a33 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0105a41:	3c 2b                	cmp    $0x2b,%al
f0105a43:	74 2e                	je     f0105a73 <strtol+0x4e>
	int neg = 0;
f0105a45:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0105a4a:	3c 2d                	cmp    $0x2d,%al
f0105a4c:	74 2f                	je     f0105a7d <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105a4e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0105a54:	75 05                	jne    f0105a5b <strtol+0x36>
f0105a56:	80 39 30             	cmpb   $0x30,(%ecx)
f0105a59:	74 2c                	je     f0105a87 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105a5b:	85 db                	test   %ebx,%ebx
f0105a5d:	75 0a                	jne    f0105a69 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105a5f:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
f0105a64:	80 39 30             	cmpb   $0x30,(%ecx)
f0105a67:	74 28                	je     f0105a91 <strtol+0x6c>
		base = 10;
f0105a69:	b8 00 00 00 00       	mov    $0x0,%eax
f0105a6e:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0105a71:	eb 50                	jmp    f0105ac3 <strtol+0x9e>
		s++;
f0105a73:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f0105a76:	bf 00 00 00 00       	mov    $0x0,%edi
f0105a7b:	eb d1                	jmp    f0105a4e <strtol+0x29>
		s++, neg = 1;
f0105a7d:	83 c1 01             	add    $0x1,%ecx
f0105a80:	bf 01 00 00 00       	mov    $0x1,%edi
f0105a85:	eb c7                	jmp    f0105a4e <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105a87:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0105a8b:	74 0e                	je     f0105a9b <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f0105a8d:	85 db                	test   %ebx,%ebx
f0105a8f:	75 d8                	jne    f0105a69 <strtol+0x44>
		s++, base = 8;
f0105a91:	83 c1 01             	add    $0x1,%ecx
f0105a94:	bb 08 00 00 00       	mov    $0x8,%ebx
f0105a99:	eb ce                	jmp    f0105a69 <strtol+0x44>
		s += 2, base = 16;
f0105a9b:	83 c1 02             	add    $0x2,%ecx
f0105a9e:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105aa3:	eb c4                	jmp    f0105a69 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f0105aa5:	8d 72 9f             	lea    -0x61(%edx),%esi
f0105aa8:	89 f3                	mov    %esi,%ebx
f0105aaa:	80 fb 19             	cmp    $0x19,%bl
f0105aad:	77 29                	ja     f0105ad8 <strtol+0xb3>
			dig = *s - 'a' + 10;
f0105aaf:	0f be d2             	movsbl %dl,%edx
f0105ab2:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0105ab5:	3b 55 10             	cmp    0x10(%ebp),%edx
f0105ab8:	7d 30                	jge    f0105aea <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f0105aba:	83 c1 01             	add    $0x1,%ecx
f0105abd:	0f af 45 10          	imul   0x10(%ebp),%eax
f0105ac1:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0105ac3:	0f b6 11             	movzbl (%ecx),%edx
f0105ac6:	8d 72 d0             	lea    -0x30(%edx),%esi
f0105ac9:	89 f3                	mov    %esi,%ebx
f0105acb:	80 fb 09             	cmp    $0x9,%bl
f0105ace:	77 d5                	ja     f0105aa5 <strtol+0x80>
			dig = *s - '0';
f0105ad0:	0f be d2             	movsbl %dl,%edx
f0105ad3:	83 ea 30             	sub    $0x30,%edx
f0105ad6:	eb dd                	jmp    f0105ab5 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
f0105ad8:	8d 72 bf             	lea    -0x41(%edx),%esi
f0105adb:	89 f3                	mov    %esi,%ebx
f0105add:	80 fb 19             	cmp    $0x19,%bl
f0105ae0:	77 08                	ja     f0105aea <strtol+0xc5>
			dig = *s - 'A' + 10;
f0105ae2:	0f be d2             	movsbl %dl,%edx
f0105ae5:	83 ea 37             	sub    $0x37,%edx
f0105ae8:	eb cb                	jmp    f0105ab5 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
f0105aea:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105aee:	74 05                	je     f0105af5 <strtol+0xd0>
		*endptr = (char *) s;
f0105af0:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105af3:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0105af5:	89 c2                	mov    %eax,%edx
f0105af7:	f7 da                	neg    %edx
f0105af9:	85 ff                	test   %edi,%edi
f0105afb:	0f 45 c2             	cmovne %edx,%eax
}
f0105afe:	5b                   	pop    %ebx
f0105aff:	5e                   	pop    %esi
f0105b00:	5f                   	pop    %edi
f0105b01:	5d                   	pop    %ebp
f0105b02:	c3                   	ret    
f0105b03:	90                   	nop

f0105b04 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105b04:	fa                   	cli    

	xorw    %ax, %ax
f0105b05:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105b07:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105b09:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105b0b:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105b0d:	0f 01 16             	lgdtl  (%esi)
f0105b10:	74 70                	je     f0105b82 <mpsearch1+0x3>
	movl    %cr0, %eax
f0105b12:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105b15:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105b19:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105b1c:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105b22:	08 00                	or     %al,(%eax)

f0105b24 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105b24:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105b28:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105b2a:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105b2c:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105b2e:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105b32:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105b34:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105b36:	b8 00 00 12 00       	mov    $0x120000,%eax
	movl    %eax, %cr3
f0105b3b:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105b3e:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105b41:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105b46:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105b49:	8b 25 84 4e 23 f0    	mov    0xf0234e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105b4f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105b54:	b8 8f 01 10 f0       	mov    $0xf010018f,%eax
	call    *%eax
f0105b59:	ff d0                	call   *%eax

f0105b5b <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105b5b:	eb fe                	jmp    f0105b5b <spin>
f0105b5d:	8d 76 00             	lea    0x0(%esi),%esi

f0105b60 <gdt>:
	...
f0105b68:	ff                   	(bad)  
f0105b69:	ff 00                	incl   (%eax)
f0105b6b:	00 00                	add    %al,(%eax)
f0105b6d:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105b74:	00                   	.byte 0x0
f0105b75:	92                   	xchg   %eax,%edx
f0105b76:	cf                   	iret   
	...

f0105b78 <gdtdesc>:
f0105b78:	17                   	pop    %ss
f0105b79:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105b7e <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105b7e:	90                   	nop

f0105b7f <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105b7f:	55                   	push   %ebp
f0105b80:	89 e5                	mov    %esp,%ebp
f0105b82:	57                   	push   %edi
f0105b83:	56                   	push   %esi
f0105b84:	53                   	push   %ebx
f0105b85:	83 ec 0c             	sub    $0xc,%esp
	if (PGNUM(pa) >= npages)
f0105b88:	8b 0d 88 4e 23 f0    	mov    0xf0234e88,%ecx
f0105b8e:	89 c3                	mov    %eax,%ebx
f0105b90:	c1 eb 0c             	shr    $0xc,%ebx
f0105b93:	39 cb                	cmp    %ecx,%ebx
f0105b95:	73 1a                	jae    f0105bb1 <mpsearch1+0x32>
	return (void *)(pa + KERNBASE);
f0105b97:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105b9d:	8d 34 02             	lea    (%edx,%eax,1),%esi
	if (PGNUM(pa) >= npages)
f0105ba0:	89 f0                	mov    %esi,%eax
f0105ba2:	c1 e8 0c             	shr    $0xc,%eax
f0105ba5:	39 c8                	cmp    %ecx,%eax
f0105ba7:	73 1a                	jae    f0105bc3 <mpsearch1+0x44>
	return (void *)(pa + KERNBASE);
f0105ba9:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f0105baf:	eb 27                	jmp    f0105bd8 <mpsearch1+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105bb1:	50                   	push   %eax
f0105bb2:	68 84 65 10 f0       	push   $0xf0106584
f0105bb7:	6a 57                	push   $0x57
f0105bb9:	68 81 81 10 f0       	push   $0xf0108181
f0105bbe:	e8 7d a4 ff ff       	call   f0100040 <_panic>
f0105bc3:	56                   	push   %esi
f0105bc4:	68 84 65 10 f0       	push   $0xf0106584
f0105bc9:	6a 57                	push   $0x57
f0105bcb:	68 81 81 10 f0       	push   $0xf0108181
f0105bd0:	e8 6b a4 ff ff       	call   f0100040 <_panic>
f0105bd5:	83 c3 10             	add    $0x10,%ebx
f0105bd8:	39 f3                	cmp    %esi,%ebx
f0105bda:	73 2e                	jae    f0105c0a <mpsearch1+0x8b>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105bdc:	83 ec 04             	sub    $0x4,%esp
f0105bdf:	6a 04                	push   $0x4
f0105be1:	68 91 81 10 f0       	push   $0xf0108191
f0105be6:	53                   	push   %ebx
f0105be7:	e8 e3 fd ff ff       	call   f01059cf <memcmp>
f0105bec:	83 c4 10             	add    $0x10,%esp
f0105bef:	85 c0                	test   %eax,%eax
f0105bf1:	75 e2                	jne    f0105bd5 <mpsearch1+0x56>
f0105bf3:	89 da                	mov    %ebx,%edx
f0105bf5:	8d 7b 10             	lea    0x10(%ebx),%edi
		sum += ((uint8_t *)addr)[i];
f0105bf8:	0f b6 0a             	movzbl (%edx),%ecx
f0105bfb:	01 c8                	add    %ecx,%eax
f0105bfd:	83 c2 01             	add    $0x1,%edx
	for (i = 0; i < len; i++)
f0105c00:	39 fa                	cmp    %edi,%edx
f0105c02:	75 f4                	jne    f0105bf8 <mpsearch1+0x79>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105c04:	84 c0                	test   %al,%al
f0105c06:	75 cd                	jne    f0105bd5 <mpsearch1+0x56>
f0105c08:	eb 05                	jmp    f0105c0f <mpsearch1+0x90>
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0105c0a:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0105c0f:	89 d8                	mov    %ebx,%eax
f0105c11:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105c14:	5b                   	pop    %ebx
f0105c15:	5e                   	pop    %esi
f0105c16:	5f                   	pop    %edi
f0105c17:	5d                   	pop    %ebp
f0105c18:	c3                   	ret    

f0105c19 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105c19:	55                   	push   %ebp
f0105c1a:	89 e5                	mov    %esp,%ebp
f0105c1c:	57                   	push   %edi
f0105c1d:	56                   	push   %esi
f0105c1e:	53                   	push   %ebx
f0105c1f:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105c22:	c7 05 c0 53 23 f0 20 	movl   $0xf0235020,0xf02353c0
f0105c29:	50 23 f0 
	if (PGNUM(pa) >= npages)
f0105c2c:	83 3d 88 4e 23 f0 00 	cmpl   $0x0,0xf0234e88
f0105c33:	0f 84 87 00 00 00    	je     f0105cc0 <mp_init+0xa7>
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105c39:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105c40:	85 c0                	test   %eax,%eax
f0105c42:	0f 84 8e 00 00 00    	je     f0105cd6 <mp_init+0xbd>
		p <<= 4;	// Translate from segment to PA
f0105c48:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0105c4b:	ba 00 04 00 00       	mov    $0x400,%edx
f0105c50:	e8 2a ff ff ff       	call   f0105b7f <mpsearch1>
f0105c55:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105c58:	85 c0                	test   %eax,%eax
f0105c5a:	0f 84 9a 00 00 00    	je     f0105cfa <mp_init+0xe1>
	if (mp->physaddr == 0 || mp->type != 0) {
f0105c60:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105c63:	8b 41 04             	mov    0x4(%ecx),%eax
f0105c66:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105c69:	85 c0                	test   %eax,%eax
f0105c6b:	0f 84 a8 00 00 00    	je     f0105d19 <mp_init+0x100>
f0105c71:	80 79 0b 00          	cmpb   $0x0,0xb(%ecx)
f0105c75:	0f 85 9e 00 00 00    	jne    f0105d19 <mp_init+0x100>
f0105c7b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105c7e:	c1 e8 0c             	shr    $0xc,%eax
f0105c81:	3b 05 88 4e 23 f0    	cmp    0xf0234e88,%eax
f0105c87:	0f 83 a1 00 00 00    	jae    f0105d2e <mp_init+0x115>
	return (void *)(pa + KERNBASE);
f0105c8d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105c90:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f0105c96:	89 de                	mov    %ebx,%esi
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105c98:	83 ec 04             	sub    $0x4,%esp
f0105c9b:	6a 04                	push   $0x4
f0105c9d:	68 96 81 10 f0       	push   $0xf0108196
f0105ca2:	53                   	push   %ebx
f0105ca3:	e8 27 fd ff ff       	call   f01059cf <memcmp>
f0105ca8:	83 c4 10             	add    $0x10,%esp
f0105cab:	85 c0                	test   %eax,%eax
f0105cad:	0f 85 92 00 00 00    	jne    f0105d45 <mp_init+0x12c>
f0105cb3:	0f b7 7b 04          	movzwl 0x4(%ebx),%edi
f0105cb7:	01 df                	add    %ebx,%edi
	sum = 0;
f0105cb9:	89 c2                	mov    %eax,%edx
f0105cbb:	e9 a2 00 00 00       	jmp    f0105d62 <mp_init+0x149>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105cc0:	68 00 04 00 00       	push   $0x400
f0105cc5:	68 84 65 10 f0       	push   $0xf0106584
f0105cca:	6a 6f                	push   $0x6f
f0105ccc:	68 81 81 10 f0       	push   $0xf0108181
f0105cd1:	e8 6a a3 ff ff       	call   f0100040 <_panic>
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0105cd6:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105cdd:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105ce0:	2d 00 04 00 00       	sub    $0x400,%eax
f0105ce5:	ba 00 04 00 00       	mov    $0x400,%edx
f0105cea:	e8 90 fe ff ff       	call   f0105b7f <mpsearch1>
f0105cef:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105cf2:	85 c0                	test   %eax,%eax
f0105cf4:	0f 85 66 ff ff ff    	jne    f0105c60 <mp_init+0x47>
	return mpsearch1(0xF0000, 0x10000);
f0105cfa:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105cff:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105d04:	e8 76 fe ff ff       	call   f0105b7f <mpsearch1>
f0105d09:	89 45 e0             	mov    %eax,-0x20(%ebp)
	if ((mp = mpsearch()) == 0)
f0105d0c:	85 c0                	test   %eax,%eax
f0105d0e:	0f 85 4c ff ff ff    	jne    f0105c60 <mp_init+0x47>
f0105d14:	e9 a8 01 00 00       	jmp    f0105ec1 <mp_init+0x2a8>
		cprintf("SMP: Default configurations not implemented\n");
f0105d19:	83 ec 0c             	sub    $0xc,%esp
f0105d1c:	68 f4 7f 10 f0       	push   $0xf0107ff4
f0105d21:	e8 1e dc ff ff       	call   f0103944 <cprintf>
f0105d26:	83 c4 10             	add    $0x10,%esp
f0105d29:	e9 93 01 00 00       	jmp    f0105ec1 <mp_init+0x2a8>
f0105d2e:	ff 75 e4             	pushl  -0x1c(%ebp)
f0105d31:	68 84 65 10 f0       	push   $0xf0106584
f0105d36:	68 90 00 00 00       	push   $0x90
f0105d3b:	68 81 81 10 f0       	push   $0xf0108181
f0105d40:	e8 fb a2 ff ff       	call   f0100040 <_panic>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105d45:	83 ec 0c             	sub    $0xc,%esp
f0105d48:	68 24 80 10 f0       	push   $0xf0108024
f0105d4d:	e8 f2 db ff ff       	call   f0103944 <cprintf>
f0105d52:	83 c4 10             	add    $0x10,%esp
f0105d55:	e9 67 01 00 00       	jmp    f0105ec1 <mp_init+0x2a8>
		sum += ((uint8_t *)addr)[i];
f0105d5a:	0f b6 0b             	movzbl (%ebx),%ecx
f0105d5d:	01 ca                	add    %ecx,%edx
f0105d5f:	83 c3 01             	add    $0x1,%ebx
	for (i = 0; i < len; i++)
f0105d62:	39 fb                	cmp    %edi,%ebx
f0105d64:	75 f4                	jne    f0105d5a <mp_init+0x141>
	if (sum(conf, conf->length) != 0) {
f0105d66:	84 d2                	test   %dl,%dl
f0105d68:	75 16                	jne    f0105d80 <mp_init+0x167>
	if (conf->version != 1 && conf->version != 4) {
f0105d6a:	0f b6 56 06          	movzbl 0x6(%esi),%edx
f0105d6e:	80 fa 01             	cmp    $0x1,%dl
f0105d71:	74 05                	je     f0105d78 <mp_init+0x15f>
f0105d73:	80 fa 04             	cmp    $0x4,%dl
f0105d76:	75 1d                	jne    f0105d95 <mp_init+0x17c>
f0105d78:	0f b7 4e 28          	movzwl 0x28(%esi),%ecx
f0105d7c:	01 d9                	add    %ebx,%ecx
f0105d7e:	eb 36                	jmp    f0105db6 <mp_init+0x19d>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105d80:	83 ec 0c             	sub    $0xc,%esp
f0105d83:	68 58 80 10 f0       	push   $0xf0108058
f0105d88:	e8 b7 db ff ff       	call   f0103944 <cprintf>
f0105d8d:	83 c4 10             	add    $0x10,%esp
f0105d90:	e9 2c 01 00 00       	jmp    f0105ec1 <mp_init+0x2a8>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105d95:	83 ec 08             	sub    $0x8,%esp
f0105d98:	0f b6 d2             	movzbl %dl,%edx
f0105d9b:	52                   	push   %edx
f0105d9c:	68 7c 80 10 f0       	push   $0xf010807c
f0105da1:	e8 9e db ff ff       	call   f0103944 <cprintf>
f0105da6:	83 c4 10             	add    $0x10,%esp
f0105da9:	e9 13 01 00 00       	jmp    f0105ec1 <mp_init+0x2a8>
		sum += ((uint8_t *)addr)[i];
f0105dae:	0f b6 13             	movzbl (%ebx),%edx
f0105db1:	01 d0                	add    %edx,%eax
f0105db3:	83 c3 01             	add    $0x1,%ebx
	for (i = 0; i < len; i++)
f0105db6:	39 d9                	cmp    %ebx,%ecx
f0105db8:	75 f4                	jne    f0105dae <mp_init+0x195>
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105dba:	02 46 2a             	add    0x2a(%esi),%al
f0105dbd:	75 29                	jne    f0105de8 <mp_init+0x1cf>
	if ((conf = mpconfig(&mp)) == 0)
f0105dbf:	81 7d e4 00 00 00 10 	cmpl   $0x10000000,-0x1c(%ebp)
f0105dc6:	0f 84 f5 00 00 00    	je     f0105ec1 <mp_init+0x2a8>
		return;
	ismp = 1;
f0105dcc:	c7 05 00 50 23 f0 01 	movl   $0x1,0xf0235000
f0105dd3:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105dd6:	8b 46 24             	mov    0x24(%esi),%eax
f0105dd9:	a3 00 60 27 f0       	mov    %eax,0xf0276000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105dde:	8d 7e 2c             	lea    0x2c(%esi),%edi
f0105de1:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105de6:	eb 4d                	jmp    f0105e35 <mp_init+0x21c>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105de8:	83 ec 0c             	sub    $0xc,%esp
f0105deb:	68 9c 80 10 f0       	push   $0xf010809c
f0105df0:	e8 4f db ff ff       	call   f0103944 <cprintf>
f0105df5:	83 c4 10             	add    $0x10,%esp
f0105df8:	e9 c4 00 00 00       	jmp    f0105ec1 <mp_init+0x2a8>
		switch (*p) {
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105dfd:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105e01:	74 11                	je     f0105e14 <mp_init+0x1fb>
				bootcpu = &cpus[ncpu];
f0105e03:	6b 05 c4 53 23 f0 74 	imul   $0x74,0xf02353c4,%eax
f0105e0a:	05 20 50 23 f0       	add    $0xf0235020,%eax
f0105e0f:	a3 c0 53 23 f0       	mov    %eax,0xf02353c0
			if (ncpu < NCPU) {
f0105e14:	a1 c4 53 23 f0       	mov    0xf02353c4,%eax
f0105e19:	83 f8 07             	cmp    $0x7,%eax
f0105e1c:	7f 2f                	jg     f0105e4d <mp_init+0x234>
				cpus[ncpu].cpu_id = ncpu;
f0105e1e:	6b d0 74             	imul   $0x74,%eax,%edx
f0105e21:	88 82 20 50 23 f0    	mov    %al,-0xfdcafe0(%edx)
				ncpu++;
f0105e27:	83 c0 01             	add    $0x1,%eax
f0105e2a:	a3 c4 53 23 f0       	mov    %eax,0xf02353c4
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105e2f:	83 c7 14             	add    $0x14,%edi
	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105e32:	83 c3 01             	add    $0x1,%ebx
f0105e35:	0f b7 46 22          	movzwl 0x22(%esi),%eax
f0105e39:	39 d8                	cmp    %ebx,%eax
f0105e3b:	76 4b                	jbe    f0105e88 <mp_init+0x26f>
		switch (*p) {
f0105e3d:	0f b6 07             	movzbl (%edi),%eax
f0105e40:	84 c0                	test   %al,%al
f0105e42:	74 b9                	je     f0105dfd <mp_init+0x1e4>
f0105e44:	3c 04                	cmp    $0x4,%al
f0105e46:	77 1c                	ja     f0105e64 <mp_init+0x24b>
			continue;
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105e48:	83 c7 08             	add    $0x8,%edi
			continue;
f0105e4b:	eb e5                	jmp    f0105e32 <mp_init+0x219>
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105e4d:	83 ec 08             	sub    $0x8,%esp
f0105e50:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0105e54:	50                   	push   %eax
f0105e55:	68 cc 80 10 f0       	push   $0xf01080cc
f0105e5a:	e8 e5 da ff ff       	call   f0103944 <cprintf>
f0105e5f:	83 c4 10             	add    $0x10,%esp
f0105e62:	eb cb                	jmp    f0105e2f <mp_init+0x216>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105e64:	83 ec 08             	sub    $0x8,%esp
		switch (*p) {
f0105e67:	0f b6 c0             	movzbl %al,%eax
			cprintf("mpinit: unknown config type %x\n", *p);
f0105e6a:	50                   	push   %eax
f0105e6b:	68 f4 80 10 f0       	push   $0xf01080f4
f0105e70:	e8 cf da ff ff       	call   f0103944 <cprintf>
			ismp = 0;
f0105e75:	c7 05 00 50 23 f0 00 	movl   $0x0,0xf0235000
f0105e7c:	00 00 00 
			i = conf->entry;
f0105e7f:	0f b7 5e 22          	movzwl 0x22(%esi),%ebx
f0105e83:	83 c4 10             	add    $0x10,%esp
f0105e86:	eb aa                	jmp    f0105e32 <mp_init+0x219>
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105e88:	a1 c0 53 23 f0       	mov    0xf02353c0,%eax
f0105e8d:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105e94:	83 3d 00 50 23 f0 00 	cmpl   $0x0,0xf0235000
f0105e9b:	75 2c                	jne    f0105ec9 <mp_init+0x2b0>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105e9d:	c7 05 c4 53 23 f0 01 	movl   $0x1,0xf02353c4
f0105ea4:	00 00 00 
		lapicaddr = 0;
f0105ea7:	c7 05 00 60 27 f0 00 	movl   $0x0,0xf0276000
f0105eae:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105eb1:	83 ec 0c             	sub    $0xc,%esp
f0105eb4:	68 14 81 10 f0       	push   $0xf0108114
f0105eb9:	e8 86 da ff ff       	call   f0103944 <cprintf>
		return;
f0105ebe:	83 c4 10             	add    $0x10,%esp
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0105ec1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105ec4:	5b                   	pop    %ebx
f0105ec5:	5e                   	pop    %esi
f0105ec6:	5f                   	pop    %edi
f0105ec7:	5d                   	pop    %ebp
f0105ec8:	c3                   	ret    
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105ec9:	83 ec 04             	sub    $0x4,%esp
f0105ecc:	ff 35 c4 53 23 f0    	pushl  0xf02353c4
f0105ed2:	0f b6 00             	movzbl (%eax),%eax
f0105ed5:	50                   	push   %eax
f0105ed6:	68 9b 81 10 f0       	push   $0xf010819b
f0105edb:	e8 64 da ff ff       	call   f0103944 <cprintf>
	if (mp->imcrp) {
f0105ee0:	83 c4 10             	add    $0x10,%esp
f0105ee3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105ee6:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105eea:	74 d5                	je     f0105ec1 <mp_init+0x2a8>
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105eec:	83 ec 0c             	sub    $0xc,%esp
f0105eef:	68 40 81 10 f0       	push   $0xf0108140
f0105ef4:	e8 4b da ff ff       	call   f0103944 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105ef9:	b8 70 00 00 00       	mov    $0x70,%eax
f0105efe:	ba 22 00 00 00       	mov    $0x22,%edx
f0105f03:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105f04:	ba 23 00 00 00       	mov    $0x23,%edx
f0105f09:	ec                   	in     (%dx),%al
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0105f0a:	83 c8 01             	or     $0x1,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105f0d:	ee                   	out    %al,(%dx)
f0105f0e:	83 c4 10             	add    $0x10,%esp
f0105f11:	eb ae                	jmp    f0105ec1 <mp_init+0x2a8>

f0105f13 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0105f13:	55                   	push   %ebp
f0105f14:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0105f16:	8b 0d 04 60 27 f0    	mov    0xf0276004,%ecx
f0105f1c:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0105f1f:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105f21:	a1 04 60 27 f0       	mov    0xf0276004,%eax
f0105f26:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105f29:	5d                   	pop    %ebp
f0105f2a:	c3                   	ret    

f0105f2b <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0105f2b:	55                   	push   %ebp
f0105f2c:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105f2e:	8b 15 04 60 27 f0    	mov    0xf0276004,%edx
		return lapic[ID] >> 24;
	return 0;
f0105f34:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lapic)
f0105f39:	85 d2                	test   %edx,%edx
f0105f3b:	74 06                	je     f0105f43 <cpunum+0x18>
		return lapic[ID] >> 24;
f0105f3d:	8b 42 20             	mov    0x20(%edx),%eax
f0105f40:	c1 e8 18             	shr    $0x18,%eax
}
f0105f43:	5d                   	pop    %ebp
f0105f44:	c3                   	ret    

f0105f45 <lapic_init>:
	if (!lapicaddr)
f0105f45:	a1 00 60 27 f0       	mov    0xf0276000,%eax
f0105f4a:	85 c0                	test   %eax,%eax
f0105f4c:	75 02                	jne    f0105f50 <lapic_init+0xb>
f0105f4e:	f3 c3                	repz ret 
{
f0105f50:	55                   	push   %ebp
f0105f51:	89 e5                	mov    %esp,%ebp
f0105f53:	83 ec 10             	sub    $0x10,%esp
	lapic = mmio_map_region(lapicaddr, 4096);
f0105f56:	68 00 10 00 00       	push   $0x1000
f0105f5b:	50                   	push   %eax
f0105f5c:	e8 35 b3 ff ff       	call   f0101296 <mmio_map_region>
f0105f61:	a3 04 60 27 f0       	mov    %eax,0xf0276004
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105f66:	ba 27 01 00 00       	mov    $0x127,%edx
f0105f6b:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105f70:	e8 9e ff ff ff       	call   f0105f13 <lapicw>
	lapicw(TDCR, X1);
f0105f75:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105f7a:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105f7f:	e8 8f ff ff ff       	call   f0105f13 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105f84:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105f89:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105f8e:	e8 80 ff ff ff       	call   f0105f13 <lapicw>
	lapicw(TICR, 10000000); 
f0105f93:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105f98:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105f9d:	e8 71 ff ff ff       	call   f0105f13 <lapicw>
	if (thiscpu != bootcpu)
f0105fa2:	e8 84 ff ff ff       	call   f0105f2b <cpunum>
f0105fa7:	6b c0 74             	imul   $0x74,%eax,%eax
f0105faa:	05 20 50 23 f0       	add    $0xf0235020,%eax
f0105faf:	83 c4 10             	add    $0x10,%esp
f0105fb2:	39 05 c0 53 23 f0    	cmp    %eax,0xf02353c0
f0105fb8:	74 0f                	je     f0105fc9 <lapic_init+0x84>
		lapicw(LINT0, MASKED);
f0105fba:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105fbf:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105fc4:	e8 4a ff ff ff       	call   f0105f13 <lapicw>
	lapicw(LINT1, MASKED);
f0105fc9:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105fce:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105fd3:	e8 3b ff ff ff       	call   f0105f13 <lapicw>
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105fd8:	a1 04 60 27 f0       	mov    0xf0276004,%eax
f0105fdd:	8b 40 30             	mov    0x30(%eax),%eax
f0105fe0:	c1 e8 10             	shr    $0x10,%eax
f0105fe3:	3c 03                	cmp    $0x3,%al
f0105fe5:	77 7c                	ja     f0106063 <lapic_init+0x11e>
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105fe7:	ba 33 00 00 00       	mov    $0x33,%edx
f0105fec:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105ff1:	e8 1d ff ff ff       	call   f0105f13 <lapicw>
	lapicw(ESR, 0);
f0105ff6:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ffb:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106000:	e8 0e ff ff ff       	call   f0105f13 <lapicw>
	lapicw(ESR, 0);
f0106005:	ba 00 00 00 00       	mov    $0x0,%edx
f010600a:	b8 a0 00 00 00       	mov    $0xa0,%eax
f010600f:	e8 ff fe ff ff       	call   f0105f13 <lapicw>
	lapicw(EOI, 0);
f0106014:	ba 00 00 00 00       	mov    $0x0,%edx
f0106019:	b8 2c 00 00 00       	mov    $0x2c,%eax
f010601e:	e8 f0 fe ff ff       	call   f0105f13 <lapicw>
	lapicw(ICRHI, 0);
f0106023:	ba 00 00 00 00       	mov    $0x0,%edx
f0106028:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010602d:	e8 e1 fe ff ff       	call   f0105f13 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0106032:	ba 00 85 08 00       	mov    $0x88500,%edx
f0106037:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010603c:	e8 d2 fe ff ff       	call   f0105f13 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0106041:	8b 15 04 60 27 f0    	mov    0xf0276004,%edx
f0106047:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f010604d:	f6 c4 10             	test   $0x10,%ah
f0106050:	75 f5                	jne    f0106047 <lapic_init+0x102>
	lapicw(TPR, 0);
f0106052:	ba 00 00 00 00       	mov    $0x0,%edx
f0106057:	b8 20 00 00 00       	mov    $0x20,%eax
f010605c:	e8 b2 fe ff ff       	call   f0105f13 <lapicw>
}
f0106061:	c9                   	leave  
f0106062:	c3                   	ret    
		lapicw(PCINT, MASKED);
f0106063:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106068:	b8 d0 00 00 00       	mov    $0xd0,%eax
f010606d:	e8 a1 fe ff ff       	call   f0105f13 <lapicw>
f0106072:	e9 70 ff ff ff       	jmp    f0105fe7 <lapic_init+0xa2>

f0106077 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0106077:	83 3d 04 60 27 f0 00 	cmpl   $0x0,0xf0276004
f010607e:	74 14                	je     f0106094 <lapic_eoi+0x1d>
{
f0106080:	55                   	push   %ebp
f0106081:	89 e5                	mov    %esp,%ebp
		lapicw(EOI, 0);
f0106083:	ba 00 00 00 00       	mov    $0x0,%edx
f0106088:	b8 2c 00 00 00       	mov    $0x2c,%eax
f010608d:	e8 81 fe ff ff       	call   f0105f13 <lapicw>
}
f0106092:	5d                   	pop    %ebp
f0106093:	c3                   	ret    
f0106094:	f3 c3                	repz ret 

f0106096 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0106096:	55                   	push   %ebp
f0106097:	89 e5                	mov    %esp,%ebp
f0106099:	56                   	push   %esi
f010609a:	53                   	push   %ebx
f010609b:	8b 75 08             	mov    0x8(%ebp),%esi
f010609e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01060a1:	b8 0f 00 00 00       	mov    $0xf,%eax
f01060a6:	ba 70 00 00 00       	mov    $0x70,%edx
f01060ab:	ee                   	out    %al,(%dx)
f01060ac:	b8 0a 00 00 00       	mov    $0xa,%eax
f01060b1:	ba 71 00 00 00       	mov    $0x71,%edx
f01060b6:	ee                   	out    %al,(%dx)
	if (PGNUM(pa) >= npages)
f01060b7:	83 3d 88 4e 23 f0 00 	cmpl   $0x0,0xf0234e88
f01060be:	74 7e                	je     f010613e <lapic_startap+0xa8>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f01060c0:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f01060c7:	00 00 
	wrv[1] = addr >> 4;
f01060c9:	89 d8                	mov    %ebx,%eax
f01060cb:	c1 e8 04             	shr    $0x4,%eax
f01060ce:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f01060d4:	c1 e6 18             	shl    $0x18,%esi
f01060d7:	89 f2                	mov    %esi,%edx
f01060d9:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01060de:	e8 30 fe ff ff       	call   f0105f13 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f01060e3:	ba 00 c5 00 00       	mov    $0xc500,%edx
f01060e8:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01060ed:	e8 21 fe ff ff       	call   f0105f13 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f01060f2:	ba 00 85 00 00       	mov    $0x8500,%edx
f01060f7:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01060fc:	e8 12 fe ff ff       	call   f0105f13 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106101:	c1 eb 0c             	shr    $0xc,%ebx
f0106104:	80 cf 06             	or     $0x6,%bh
		lapicw(ICRHI, apicid << 24);
f0106107:	89 f2                	mov    %esi,%edx
f0106109:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010610e:	e8 00 fe ff ff       	call   f0105f13 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106113:	89 da                	mov    %ebx,%edx
f0106115:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010611a:	e8 f4 fd ff ff       	call   f0105f13 <lapicw>
		lapicw(ICRHI, apicid << 24);
f010611f:	89 f2                	mov    %esi,%edx
f0106121:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106126:	e8 e8 fd ff ff       	call   f0105f13 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010612b:	89 da                	mov    %ebx,%edx
f010612d:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106132:	e8 dc fd ff ff       	call   f0105f13 <lapicw>
		microdelay(200);
	}
}
f0106137:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010613a:	5b                   	pop    %ebx
f010613b:	5e                   	pop    %esi
f010613c:	5d                   	pop    %ebp
f010613d:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010613e:	68 67 04 00 00       	push   $0x467
f0106143:	68 84 65 10 f0       	push   $0xf0106584
f0106148:	68 98 00 00 00       	push   $0x98
f010614d:	68 b8 81 10 f0       	push   $0xf01081b8
f0106152:	e8 e9 9e ff ff       	call   f0100040 <_panic>

f0106157 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0106157:	55                   	push   %ebp
f0106158:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f010615a:	8b 55 08             	mov    0x8(%ebp),%edx
f010615d:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0106163:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106168:	e8 a6 fd ff ff       	call   f0105f13 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f010616d:	8b 15 04 60 27 f0    	mov    0xf0276004,%edx
f0106173:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106179:	f6 c4 10             	test   $0x10,%ah
f010617c:	75 f5                	jne    f0106173 <lapic_ipi+0x1c>
		;
}
f010617e:	5d                   	pop    %ebp
f010617f:	c3                   	ret    

f0106180 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0106180:	55                   	push   %ebp
f0106181:	89 e5                	mov    %esp,%ebp
f0106183:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0106186:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f010618c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010618f:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0106192:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0106199:	5d                   	pop    %ebp
f010619a:	c3                   	ret    

f010619b <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f010619b:	55                   	push   %ebp
f010619c:	89 e5                	mov    %esp,%ebp
f010619e:	56                   	push   %esi
f010619f:	53                   	push   %ebx
f01061a0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	return lock->locked && lock->cpu == thiscpu;
f01061a3:	83 3b 00             	cmpl   $0x0,(%ebx)
f01061a6:	75 07                	jne    f01061af <spin_lock+0x14>
	asm volatile("lock; xchgl %0, %1"
f01061a8:	ba 01 00 00 00       	mov    $0x1,%edx
f01061ad:	eb 34                	jmp    f01061e3 <spin_lock+0x48>
f01061af:	8b 73 08             	mov    0x8(%ebx),%esi
f01061b2:	e8 74 fd ff ff       	call   f0105f2b <cpunum>
f01061b7:	6b c0 74             	imul   $0x74,%eax,%eax
f01061ba:	05 20 50 23 f0       	add    $0xf0235020,%eax
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f01061bf:	39 c6                	cmp    %eax,%esi
f01061c1:	75 e5                	jne    f01061a8 <spin_lock+0xd>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f01061c3:	8b 5b 04             	mov    0x4(%ebx),%ebx
f01061c6:	e8 60 fd ff ff       	call   f0105f2b <cpunum>
f01061cb:	83 ec 0c             	sub    $0xc,%esp
f01061ce:	53                   	push   %ebx
f01061cf:	50                   	push   %eax
f01061d0:	68 c8 81 10 f0       	push   $0xf01081c8
f01061d5:	6a 41                	push   $0x41
f01061d7:	68 2c 82 10 f0       	push   $0xf010822c
f01061dc:	e8 5f 9e ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f01061e1:	f3 90                	pause  
f01061e3:	89 d0                	mov    %edx,%eax
f01061e5:	f0 87 03             	lock xchg %eax,(%ebx)
	while (xchg(&lk->locked, 1) != 0)
f01061e8:	85 c0                	test   %eax,%eax
f01061ea:	75 f5                	jne    f01061e1 <spin_lock+0x46>

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f01061ec:	e8 3a fd ff ff       	call   f0105f2b <cpunum>
f01061f1:	6b c0 74             	imul   $0x74,%eax,%eax
f01061f4:	05 20 50 23 f0       	add    $0xf0235020,%eax
f01061f9:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f01061fc:	83 c3 0c             	add    $0xc,%ebx
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01061ff:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f0106201:	b8 00 00 00 00       	mov    $0x0,%eax
f0106206:	eb 0b                	jmp    f0106213 <spin_lock+0x78>
		pcs[i] = ebp[1];          // saved %eip
f0106208:	8b 4a 04             	mov    0x4(%edx),%ecx
f010620b:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f010620e:	8b 12                	mov    (%edx),%edx
	for (i = 0; i < 10; i++){
f0106210:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106213:	83 f8 09             	cmp    $0x9,%eax
f0106216:	7f 14                	jg     f010622c <spin_lock+0x91>
f0106218:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f010621e:	77 e8                	ja     f0106208 <spin_lock+0x6d>
f0106220:	eb 0a                	jmp    f010622c <spin_lock+0x91>
		pcs[i] = 0;
f0106222:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
	for (; i < 10; i++)
f0106229:	83 c0 01             	add    $0x1,%eax
f010622c:	83 f8 09             	cmp    $0x9,%eax
f010622f:	7e f1                	jle    f0106222 <spin_lock+0x87>
#endif
}
f0106231:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106234:	5b                   	pop    %ebx
f0106235:	5e                   	pop    %esi
f0106236:	5d                   	pop    %ebp
f0106237:	c3                   	ret    

f0106238 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106238:	55                   	push   %ebp
f0106239:	89 e5                	mov    %esp,%ebp
f010623b:	57                   	push   %edi
f010623c:	56                   	push   %esi
f010623d:	53                   	push   %ebx
f010623e:	83 ec 4c             	sub    $0x4c,%esp
f0106241:	8b 75 08             	mov    0x8(%ebp),%esi
	return lock->locked && lock->cpu == thiscpu;
f0106244:	83 3e 00             	cmpl   $0x0,(%esi)
f0106247:	75 35                	jne    f010627e <spin_unlock+0x46>
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0106249:	83 ec 04             	sub    $0x4,%esp
f010624c:	6a 28                	push   $0x28
f010624e:	8d 46 0c             	lea    0xc(%esi),%eax
f0106251:	50                   	push   %eax
f0106252:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0106255:	53                   	push   %ebx
f0106256:	e8 f9 f6 ff ff       	call   f0105954 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f010625b:	8b 46 08             	mov    0x8(%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f010625e:	0f b6 38             	movzbl (%eax),%edi
f0106261:	8b 76 04             	mov    0x4(%esi),%esi
f0106264:	e8 c2 fc ff ff       	call   f0105f2b <cpunum>
f0106269:	57                   	push   %edi
f010626a:	56                   	push   %esi
f010626b:	50                   	push   %eax
f010626c:	68 f4 81 10 f0       	push   $0xf01081f4
f0106271:	e8 ce d6 ff ff       	call   f0103944 <cprintf>
f0106276:	83 c4 20             	add    $0x20,%esp
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106279:	8d 7d a8             	lea    -0x58(%ebp),%edi
f010627c:	eb 61                	jmp    f01062df <spin_unlock+0xa7>
	return lock->locked && lock->cpu == thiscpu;
f010627e:	8b 5e 08             	mov    0x8(%esi),%ebx
f0106281:	e8 a5 fc ff ff       	call   f0105f2b <cpunum>
f0106286:	6b c0 74             	imul   $0x74,%eax,%eax
f0106289:	05 20 50 23 f0       	add    $0xf0235020,%eax
	if (!holding(lk)) {
f010628e:	39 c3                	cmp    %eax,%ebx
f0106290:	75 b7                	jne    f0106249 <spin_unlock+0x11>
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
	}

	lk->pcs[0] = 0;
f0106292:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0106299:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
	asm volatile("lock; xchgl %0, %1"
f01062a0:	b8 00 00 00 00       	mov    $0x0,%eax
f01062a5:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f01062a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01062ab:	5b                   	pop    %ebx
f01062ac:	5e                   	pop    %esi
f01062ad:	5f                   	pop    %edi
f01062ae:	5d                   	pop    %ebp
f01062af:	c3                   	ret    
					pcs[i] - info.eip_fn_addr);
f01062b0:	8b 06                	mov    (%esi),%eax
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f01062b2:	83 ec 04             	sub    $0x4,%esp
f01062b5:	89 c2                	mov    %eax,%edx
f01062b7:	2b 55 b8             	sub    -0x48(%ebp),%edx
f01062ba:	52                   	push   %edx
f01062bb:	ff 75 b0             	pushl  -0x50(%ebp)
f01062be:	ff 75 b4             	pushl  -0x4c(%ebp)
f01062c1:	ff 75 ac             	pushl  -0x54(%ebp)
f01062c4:	ff 75 a8             	pushl  -0x58(%ebp)
f01062c7:	50                   	push   %eax
f01062c8:	68 3c 82 10 f0       	push   $0xf010823c
f01062cd:	e8 72 d6 ff ff       	call   f0103944 <cprintf>
f01062d2:	83 c4 20             	add    $0x20,%esp
f01062d5:	83 c3 04             	add    $0x4,%ebx
		for (i = 0; i < 10 && pcs[i]; i++) {
f01062d8:	8d 45 e8             	lea    -0x18(%ebp),%eax
f01062db:	39 c3                	cmp    %eax,%ebx
f01062dd:	74 2d                	je     f010630c <spin_unlock+0xd4>
f01062df:	89 de                	mov    %ebx,%esi
f01062e1:	8b 03                	mov    (%ebx),%eax
f01062e3:	85 c0                	test   %eax,%eax
f01062e5:	74 25                	je     f010630c <spin_unlock+0xd4>
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01062e7:	83 ec 08             	sub    $0x8,%esp
f01062ea:	57                   	push   %edi
f01062eb:	50                   	push   %eax
f01062ec:	e8 c9 ea ff ff       	call   f0104dba <debuginfo_eip>
f01062f1:	83 c4 10             	add    $0x10,%esp
f01062f4:	85 c0                	test   %eax,%eax
f01062f6:	79 b8                	jns    f01062b0 <spin_unlock+0x78>
				cprintf("  %08x\n", pcs[i]);
f01062f8:	83 ec 08             	sub    $0x8,%esp
f01062fb:	ff 36                	pushl  (%esi)
f01062fd:	68 53 82 10 f0       	push   $0xf0108253
f0106302:	e8 3d d6 ff ff       	call   f0103944 <cprintf>
f0106307:	83 c4 10             	add    $0x10,%esp
f010630a:	eb c9                	jmp    f01062d5 <spin_unlock+0x9d>
		panic("spin_unlock");
f010630c:	83 ec 04             	sub    $0x4,%esp
f010630f:	68 5b 82 10 f0       	push   $0xf010825b
f0106314:	6a 67                	push   $0x67
f0106316:	68 2c 82 10 f0       	push   $0xf010822c
f010631b:	e8 20 9d ff ff       	call   f0100040 <_panic>

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
