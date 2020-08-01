
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
f0100015:	b8 00 c0 18 00       	mov    $0x18c000,%eax
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
f0100034:	bc 00 90 11 f0       	mov    $0xf0119000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/trap.h>


void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 18             	sub    $0x18,%esp
f0100047:	e8 5a 01 00 00       	call   f01001a6 <__x86.get_pc_thunk.bx>
f010004c:	81 c3 d4 af 08 00    	add    $0x8afd4,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100052:	c7 c0 00 e0 18 f0    	mov    $0xf018e000,%eax
f0100058:	c7 c2 00 d1 18 f0    	mov    $0xf018d100,%edx
f010005e:	29 d0                	sub    %edx,%eax
f0100060:	50                   	push   %eax
f0100061:	6a 00                	push   $0x0
f0100063:	52                   	push   %edx
f0100064:	e8 1e 47 00 00       	call   f0104787 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100069:	e8 8d 05 00 00       	call   f01005fb <cons_init>
        
	//LAB1 Exercise 8
	cprintf("Lab1_exercise8:\n");
f010006e:	8d 83 c0 9b f7 ff    	lea    -0x86440(%ebx),%eax
f0100074:	89 04 24             	mov    %eax,(%esp)
f0100077:	e8 5a 36 00 00       	call   f01036d6 <cprintf>
	int x=1, y=3, z=4;
	cprintf("x %d, y %x, z %d\n",x,y,z);
f010007c:	6a 04                	push   $0x4
f010007e:	6a 03                	push   $0x3
f0100080:	6a 01                	push   $0x1
f0100082:	8d 83 d1 9b f7 ff    	lea    -0x8642f(%ebx),%eax
f0100088:	50                   	push   %eax
f0100089:	e8 48 36 00 00       	call   f01036d6 <cprintf>

	unsigned i = 0x00646c72;
f010008e:	c7 45 f4 72 6c 64 00 	movl   $0x646c72,-0xc(%ebp)
	cprintf("H%x Wo%s\n",57616,&i);
f0100095:	83 c4 1c             	add    $0x1c,%esp
f0100098:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010009b:	50                   	push   %eax
f010009c:	68 10 e1 00 00       	push   $0xe110
f01000a1:	8d 83 e3 9b f7 ff    	lea    -0x8641d(%ebx),%eax
f01000a7:	50                   	push   %eax
f01000a8:	e8 29 36 00 00       	call   f01036d6 <cprintf>
	cprintf("6828 decimal is %o octal!\n", 6828);
f01000ad:	83 c4 08             	add    $0x8,%esp
f01000b0:	68 ac 1a 00 00       	push   $0x1aac
f01000b5:	8d 83 ed 9b f7 ff    	lea    -0x86413(%ebx),%eax
f01000bb:	50                   	push   %eax
f01000bc:	e8 15 36 00 00       	call   f01036d6 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000c1:	e8 43 13 00 00       	call   f0101409 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000c6:	e8 a7 31 00 00       	call   f0103272 <env_init>
	trap_init();
f01000cb:	e8 b9 36 00 00       	call   f0103789 <trap_init>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01000d0:	83 c4 08             	add    $0x8,%esp
f01000d3:	6a 00                	push   $0x0
f01000d5:	ff b3 f4 ff ff ff    	pushl  -0xc(%ebx)
f01000db:	e8 cb 32 00 00       	call   f01033ab <env_create>
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f01000e0:	83 c4 04             	add    $0x4,%esp
f01000e3:	c7 c0 44 d3 18 f0    	mov    $0xf018d344,%eax
f01000e9:	ff 30                	pushl  (%eax)
f01000eb:	e8 35 35 00 00       	call   f0103625 <env_run>

f01000f0 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000f0:	55                   	push   %ebp
f01000f1:	89 e5                	mov    %esp,%ebp
f01000f3:	57                   	push   %edi
f01000f4:	56                   	push   %esi
f01000f5:	53                   	push   %ebx
f01000f6:	83 ec 0c             	sub    $0xc,%esp
f01000f9:	e8 a8 00 00 00       	call   f01001a6 <__x86.get_pc_thunk.bx>
f01000fe:	81 c3 22 af 08 00    	add    $0x8af22,%ebx
f0100104:	8b 7d 10             	mov    0x10(%ebp),%edi
	va_list ap;

	if (panicstr)
f0100107:	c7 c0 04 e0 18 f0    	mov    $0xf018e004,%eax
f010010d:	83 38 00             	cmpl   $0x0,(%eax)
f0100110:	74 0f                	je     f0100121 <_panic+0x31>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100112:	83 ec 0c             	sub    $0xc,%esp
f0100115:	6a 00                	push   $0x0
f0100117:	e8 25 08 00 00       	call   f0100941 <monitor>
f010011c:	83 c4 10             	add    $0x10,%esp
f010011f:	eb f1                	jmp    f0100112 <_panic+0x22>
	panicstr = fmt;
f0100121:	89 38                	mov    %edi,(%eax)
	asm volatile("cli; cld");
f0100123:	fa                   	cli    
f0100124:	fc                   	cld    
	va_start(ap, fmt);
f0100125:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f0100128:	83 ec 04             	sub    $0x4,%esp
f010012b:	ff 75 0c             	pushl  0xc(%ebp)
f010012e:	ff 75 08             	pushl  0x8(%ebp)
f0100131:	8d 83 08 9c f7 ff    	lea    -0x863f8(%ebx),%eax
f0100137:	50                   	push   %eax
f0100138:	e8 99 35 00 00       	call   f01036d6 <cprintf>
	vcprintf(fmt, ap);
f010013d:	83 c4 08             	add    $0x8,%esp
f0100140:	56                   	push   %esi
f0100141:	57                   	push   %edi
f0100142:	e8 58 35 00 00       	call   f010369f <vcprintf>
	cprintf("\n");
f0100147:	8d 83 e9 9e f7 ff    	lea    -0x86117(%ebx),%eax
f010014d:	89 04 24             	mov    %eax,(%esp)
f0100150:	e8 81 35 00 00       	call   f01036d6 <cprintf>
f0100155:	83 c4 10             	add    $0x10,%esp
f0100158:	eb b8                	jmp    f0100112 <_panic+0x22>

f010015a <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010015a:	55                   	push   %ebp
f010015b:	89 e5                	mov    %esp,%ebp
f010015d:	56                   	push   %esi
f010015e:	53                   	push   %ebx
f010015f:	e8 42 00 00 00       	call   f01001a6 <__x86.get_pc_thunk.bx>
f0100164:	81 c3 bc ae 08 00    	add    $0x8aebc,%ebx
	va_list ap;

	va_start(ap, fmt);
f010016a:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f010016d:	83 ec 04             	sub    $0x4,%esp
f0100170:	ff 75 0c             	pushl  0xc(%ebp)
f0100173:	ff 75 08             	pushl  0x8(%ebp)
f0100176:	8d 83 20 9c f7 ff    	lea    -0x863e0(%ebx),%eax
f010017c:	50                   	push   %eax
f010017d:	e8 54 35 00 00       	call   f01036d6 <cprintf>
	vcprintf(fmt, ap);
f0100182:	83 c4 08             	add    $0x8,%esp
f0100185:	56                   	push   %esi
f0100186:	ff 75 10             	pushl  0x10(%ebp)
f0100189:	e8 11 35 00 00       	call   f010369f <vcprintf>
	cprintf("\n");
f010018e:	8d 83 e9 9e f7 ff    	lea    -0x86117(%ebx),%eax
f0100194:	89 04 24             	mov    %eax,(%esp)
f0100197:	e8 3a 35 00 00       	call   f01036d6 <cprintf>
	va_end(ap);
}
f010019c:	83 c4 10             	add    $0x10,%esp
f010019f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01001a2:	5b                   	pop    %ebx
f01001a3:	5e                   	pop    %esi
f01001a4:	5d                   	pop    %ebp
f01001a5:	c3                   	ret    

f01001a6 <__x86.get_pc_thunk.bx>:
f01001a6:	8b 1c 24             	mov    (%esp),%ebx
f01001a9:	c3                   	ret    

f01001aa <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01001aa:	55                   	push   %ebp
f01001ab:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001ad:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001b2:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001b3:	a8 01                	test   $0x1,%al
f01001b5:	74 0b                	je     f01001c2 <serial_proc_data+0x18>
f01001b7:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001bc:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001bd:	0f b6 c0             	movzbl %al,%eax
}
f01001c0:	5d                   	pop    %ebp
f01001c1:	c3                   	ret    
		return -1;
f01001c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01001c7:	eb f7                	jmp    f01001c0 <serial_proc_data+0x16>

f01001c9 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001c9:	55                   	push   %ebp
f01001ca:	89 e5                	mov    %esp,%ebp
f01001cc:	56                   	push   %esi
f01001cd:	53                   	push   %ebx
f01001ce:	e8 d3 ff ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f01001d3:	81 c3 4d ae 08 00    	add    $0x8ae4d,%ebx
f01001d9:	89 c6                	mov    %eax,%esi
	int c;

	while ((c = (*proc)()) != -1) {
f01001db:	ff d6                	call   *%esi
f01001dd:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001e0:	74 2e                	je     f0100210 <cons_intr+0x47>
		if (c == 0)
f01001e2:	85 c0                	test   %eax,%eax
f01001e4:	74 f5                	je     f01001db <cons_intr+0x12>
			continue;
		cons.buf[cons.wpos++] = c;
f01001e6:	8b 8b 04 23 00 00    	mov    0x2304(%ebx),%ecx
f01001ec:	8d 51 01             	lea    0x1(%ecx),%edx
f01001ef:	89 93 04 23 00 00    	mov    %edx,0x2304(%ebx)
f01001f5:	88 84 0b 00 21 00 00 	mov    %al,0x2100(%ebx,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f01001fc:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100202:	75 d7                	jne    f01001db <cons_intr+0x12>
			cons.wpos = 0;
f0100204:	c7 83 04 23 00 00 00 	movl   $0x0,0x2304(%ebx)
f010020b:	00 00 00 
f010020e:	eb cb                	jmp    f01001db <cons_intr+0x12>
	}
}
f0100210:	5b                   	pop    %ebx
f0100211:	5e                   	pop    %esi
f0100212:	5d                   	pop    %ebp
f0100213:	c3                   	ret    

f0100214 <kbd_proc_data>:
{
f0100214:	55                   	push   %ebp
f0100215:	89 e5                	mov    %esp,%ebp
f0100217:	56                   	push   %esi
f0100218:	53                   	push   %ebx
f0100219:	e8 88 ff ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f010021e:	81 c3 02 ae 08 00    	add    $0x8ae02,%ebx
f0100224:	ba 64 00 00 00       	mov    $0x64,%edx
f0100229:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f010022a:	a8 01                	test   $0x1,%al
f010022c:	0f 84 06 01 00 00    	je     f0100338 <kbd_proc_data+0x124>
	if (stat & KBS_TERR)
f0100232:	a8 20                	test   $0x20,%al
f0100234:	0f 85 05 01 00 00    	jne    f010033f <kbd_proc_data+0x12b>
f010023a:	ba 60 00 00 00       	mov    $0x60,%edx
f010023f:	ec                   	in     (%dx),%al
f0100240:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f0100242:	3c e0                	cmp    $0xe0,%al
f0100244:	0f 84 93 00 00 00    	je     f01002dd <kbd_proc_data+0xc9>
	} else if (data & 0x80) {
f010024a:	84 c0                	test   %al,%al
f010024c:	0f 88 a0 00 00 00    	js     f01002f2 <kbd_proc_data+0xde>
	} else if (shift & E0ESC) {
f0100252:	8b 8b e0 20 00 00    	mov    0x20e0(%ebx),%ecx
f0100258:	f6 c1 40             	test   $0x40,%cl
f010025b:	74 0e                	je     f010026b <kbd_proc_data+0x57>
		data |= 0x80;
f010025d:	83 c8 80             	or     $0xffffff80,%eax
f0100260:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100262:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100265:	89 8b e0 20 00 00    	mov    %ecx,0x20e0(%ebx)
	shift |= shiftcode[data];
f010026b:	0f b6 d2             	movzbl %dl,%edx
f010026e:	0f b6 84 13 80 9d f7 	movzbl -0x86280(%ebx,%edx,1),%eax
f0100275:	ff 
f0100276:	0b 83 e0 20 00 00    	or     0x20e0(%ebx),%eax
	shift ^= togglecode[data];
f010027c:	0f b6 8c 13 80 9c f7 	movzbl -0x86380(%ebx,%edx,1),%ecx
f0100283:	ff 
f0100284:	31 c8                	xor    %ecx,%eax
f0100286:	89 83 e0 20 00 00    	mov    %eax,0x20e0(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f010028c:	89 c1                	mov    %eax,%ecx
f010028e:	83 e1 03             	and    $0x3,%ecx
f0100291:	8b 8c 8b 00 20 00 00 	mov    0x2000(%ebx,%ecx,4),%ecx
f0100298:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f010029c:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f010029f:	a8 08                	test   $0x8,%al
f01002a1:	74 0d                	je     f01002b0 <kbd_proc_data+0x9c>
		if ('a' <= c && c <= 'z')
f01002a3:	89 f2                	mov    %esi,%edx
f01002a5:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f01002a8:	83 f9 19             	cmp    $0x19,%ecx
f01002ab:	77 7a                	ja     f0100327 <kbd_proc_data+0x113>
			c += 'A' - 'a';
f01002ad:	83 ee 20             	sub    $0x20,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002b0:	f7 d0                	not    %eax
f01002b2:	a8 06                	test   $0x6,%al
f01002b4:	75 33                	jne    f01002e9 <kbd_proc_data+0xd5>
f01002b6:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f01002bc:	75 2b                	jne    f01002e9 <kbd_proc_data+0xd5>
		cprintf("Rebooting!\n");
f01002be:	83 ec 0c             	sub    $0xc,%esp
f01002c1:	8d 83 3a 9c f7 ff    	lea    -0x863c6(%ebx),%eax
f01002c7:	50                   	push   %eax
f01002c8:	e8 09 34 00 00       	call   f01036d6 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002cd:	b8 03 00 00 00       	mov    $0x3,%eax
f01002d2:	ba 92 00 00 00       	mov    $0x92,%edx
f01002d7:	ee                   	out    %al,(%dx)
f01002d8:	83 c4 10             	add    $0x10,%esp
f01002db:	eb 0c                	jmp    f01002e9 <kbd_proc_data+0xd5>
		shift |= E0ESC;
f01002dd:	83 8b e0 20 00 00 40 	orl    $0x40,0x20e0(%ebx)
		return 0;
f01002e4:	be 00 00 00 00       	mov    $0x0,%esi
}
f01002e9:	89 f0                	mov    %esi,%eax
f01002eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01002ee:	5b                   	pop    %ebx
f01002ef:	5e                   	pop    %esi
f01002f0:	5d                   	pop    %ebp
f01002f1:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f01002f2:	8b 8b e0 20 00 00    	mov    0x20e0(%ebx),%ecx
f01002f8:	89 ce                	mov    %ecx,%esi
f01002fa:	83 e6 40             	and    $0x40,%esi
f01002fd:	83 e0 7f             	and    $0x7f,%eax
f0100300:	85 f6                	test   %esi,%esi
f0100302:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100305:	0f b6 d2             	movzbl %dl,%edx
f0100308:	0f b6 84 13 80 9d f7 	movzbl -0x86280(%ebx,%edx,1),%eax
f010030f:	ff 
f0100310:	83 c8 40             	or     $0x40,%eax
f0100313:	0f b6 c0             	movzbl %al,%eax
f0100316:	f7 d0                	not    %eax
f0100318:	21 c8                	and    %ecx,%eax
f010031a:	89 83 e0 20 00 00    	mov    %eax,0x20e0(%ebx)
		return 0;
f0100320:	be 00 00 00 00       	mov    $0x0,%esi
f0100325:	eb c2                	jmp    f01002e9 <kbd_proc_data+0xd5>
		else if ('A' <= c && c <= 'Z')
f0100327:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f010032a:	8d 4e 20             	lea    0x20(%esi),%ecx
f010032d:	83 fa 1a             	cmp    $0x1a,%edx
f0100330:	0f 42 f1             	cmovb  %ecx,%esi
f0100333:	e9 78 ff ff ff       	jmp    f01002b0 <kbd_proc_data+0x9c>
		return -1;
f0100338:	be ff ff ff ff       	mov    $0xffffffff,%esi
f010033d:	eb aa                	jmp    f01002e9 <kbd_proc_data+0xd5>
		return -1;
f010033f:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100344:	eb a3                	jmp    f01002e9 <kbd_proc_data+0xd5>

f0100346 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100346:	55                   	push   %ebp
f0100347:	89 e5                	mov    %esp,%ebp
f0100349:	57                   	push   %edi
f010034a:	56                   	push   %esi
f010034b:	53                   	push   %ebx
f010034c:	83 ec 1c             	sub    $0x1c,%esp
f010034f:	e8 52 fe ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f0100354:	81 c3 cc ac 08 00    	add    $0x8accc,%ebx
f010035a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (i = 0;
f010035d:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100362:	bf fd 03 00 00       	mov    $0x3fd,%edi
f0100367:	b9 84 00 00 00       	mov    $0x84,%ecx
f010036c:	eb 09                	jmp    f0100377 <cons_putc+0x31>
f010036e:	89 ca                	mov    %ecx,%edx
f0100370:	ec                   	in     (%dx),%al
f0100371:	ec                   	in     (%dx),%al
f0100372:	ec                   	in     (%dx),%al
f0100373:	ec                   	in     (%dx),%al
	     i++)
f0100374:	83 c6 01             	add    $0x1,%esi
f0100377:	89 fa                	mov    %edi,%edx
f0100379:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010037a:	a8 20                	test   $0x20,%al
f010037c:	75 08                	jne    f0100386 <cons_putc+0x40>
f010037e:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f0100384:	7e e8                	jle    f010036e <cons_putc+0x28>
	outb(COM1 + COM_TX, c);
f0100386:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100389:	89 f8                	mov    %edi,%eax
f010038b:	88 45 e3             	mov    %al,-0x1d(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010038e:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100393:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100394:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100399:	bf 79 03 00 00       	mov    $0x379,%edi
f010039e:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003a3:	eb 09                	jmp    f01003ae <cons_putc+0x68>
f01003a5:	89 ca                	mov    %ecx,%edx
f01003a7:	ec                   	in     (%dx),%al
f01003a8:	ec                   	in     (%dx),%al
f01003a9:	ec                   	in     (%dx),%al
f01003aa:	ec                   	in     (%dx),%al
f01003ab:	83 c6 01             	add    $0x1,%esi
f01003ae:	89 fa                	mov    %edi,%edx
f01003b0:	ec                   	in     (%dx),%al
f01003b1:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003b7:	7f 04                	jg     f01003bd <cons_putc+0x77>
f01003b9:	84 c0                	test   %al,%al
f01003bb:	79 e8                	jns    f01003a5 <cons_putc+0x5f>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003bd:	ba 78 03 00 00       	mov    $0x378,%edx
f01003c2:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f01003c6:	ee                   	out    %al,(%dx)
f01003c7:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01003cc:	b8 0d 00 00 00       	mov    $0xd,%eax
f01003d1:	ee                   	out    %al,(%dx)
f01003d2:	b8 08 00 00 00       	mov    $0x8,%eax
f01003d7:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f01003d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01003db:	89 fa                	mov    %edi,%edx
f01003dd:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f01003e3:	89 f8                	mov    %edi,%eax
f01003e5:	80 cc 07             	or     $0x7,%ah
f01003e8:	85 d2                	test   %edx,%edx
f01003ea:	0f 45 c7             	cmovne %edi,%eax
f01003ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	switch (c & 0xff) {
f01003f0:	0f b6 c0             	movzbl %al,%eax
f01003f3:	83 f8 09             	cmp    $0x9,%eax
f01003f6:	0f 84 b9 00 00 00    	je     f01004b5 <cons_putc+0x16f>
f01003fc:	83 f8 09             	cmp    $0x9,%eax
f01003ff:	7e 74                	jle    f0100475 <cons_putc+0x12f>
f0100401:	83 f8 0a             	cmp    $0xa,%eax
f0100404:	0f 84 9e 00 00 00    	je     f01004a8 <cons_putc+0x162>
f010040a:	83 f8 0d             	cmp    $0xd,%eax
f010040d:	0f 85 d9 00 00 00    	jne    f01004ec <cons_putc+0x1a6>
		crt_pos -= (crt_pos % CRT_COLS);
f0100413:	0f b7 83 08 23 00 00 	movzwl 0x2308(%ebx),%eax
f010041a:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100420:	c1 e8 16             	shr    $0x16,%eax
f0100423:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100426:	c1 e0 04             	shl    $0x4,%eax
f0100429:	66 89 83 08 23 00 00 	mov    %ax,0x2308(%ebx)
	if (crt_pos >= CRT_SIZE) {
f0100430:	66 81 bb 08 23 00 00 	cmpw   $0x7cf,0x2308(%ebx)
f0100437:	cf 07 
f0100439:	0f 87 d4 00 00 00    	ja     f0100513 <cons_putc+0x1cd>
	outb(addr_6845, 14);
f010043f:	8b 8b 10 23 00 00    	mov    0x2310(%ebx),%ecx
f0100445:	b8 0e 00 00 00       	mov    $0xe,%eax
f010044a:	89 ca                	mov    %ecx,%edx
f010044c:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010044d:	0f b7 9b 08 23 00 00 	movzwl 0x2308(%ebx),%ebx
f0100454:	8d 71 01             	lea    0x1(%ecx),%esi
f0100457:	89 d8                	mov    %ebx,%eax
f0100459:	66 c1 e8 08          	shr    $0x8,%ax
f010045d:	89 f2                	mov    %esi,%edx
f010045f:	ee                   	out    %al,(%dx)
f0100460:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100465:	89 ca                	mov    %ecx,%edx
f0100467:	ee                   	out    %al,(%dx)
f0100468:	89 d8                	mov    %ebx,%eax
f010046a:	89 f2                	mov    %esi,%edx
f010046c:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010046d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100470:	5b                   	pop    %ebx
f0100471:	5e                   	pop    %esi
f0100472:	5f                   	pop    %edi
f0100473:	5d                   	pop    %ebp
f0100474:	c3                   	ret    
	switch (c & 0xff) {
f0100475:	83 f8 08             	cmp    $0x8,%eax
f0100478:	75 72                	jne    f01004ec <cons_putc+0x1a6>
		if (crt_pos > 0) {
f010047a:	0f b7 83 08 23 00 00 	movzwl 0x2308(%ebx),%eax
f0100481:	66 85 c0             	test   %ax,%ax
f0100484:	74 b9                	je     f010043f <cons_putc+0xf9>
			crt_pos--;
f0100486:	83 e8 01             	sub    $0x1,%eax
f0100489:	66 89 83 08 23 00 00 	mov    %ax,0x2308(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100490:	0f b7 c0             	movzwl %ax,%eax
f0100493:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
f0100497:	b2 00                	mov    $0x0,%dl
f0100499:	83 ca 20             	or     $0x20,%edx
f010049c:	8b 8b 0c 23 00 00    	mov    0x230c(%ebx),%ecx
f01004a2:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f01004a6:	eb 88                	jmp    f0100430 <cons_putc+0xea>
		crt_pos += CRT_COLS;
f01004a8:	66 83 83 08 23 00 00 	addw   $0x50,0x2308(%ebx)
f01004af:	50 
f01004b0:	e9 5e ff ff ff       	jmp    f0100413 <cons_putc+0xcd>
		cons_putc(' ');
f01004b5:	b8 20 00 00 00       	mov    $0x20,%eax
f01004ba:	e8 87 fe ff ff       	call   f0100346 <cons_putc>
		cons_putc(' ');
f01004bf:	b8 20 00 00 00       	mov    $0x20,%eax
f01004c4:	e8 7d fe ff ff       	call   f0100346 <cons_putc>
		cons_putc(' ');
f01004c9:	b8 20 00 00 00       	mov    $0x20,%eax
f01004ce:	e8 73 fe ff ff       	call   f0100346 <cons_putc>
		cons_putc(' ');
f01004d3:	b8 20 00 00 00       	mov    $0x20,%eax
f01004d8:	e8 69 fe ff ff       	call   f0100346 <cons_putc>
		cons_putc(' ');
f01004dd:	b8 20 00 00 00       	mov    $0x20,%eax
f01004e2:	e8 5f fe ff ff       	call   f0100346 <cons_putc>
f01004e7:	e9 44 ff ff ff       	jmp    f0100430 <cons_putc+0xea>
		crt_buf[crt_pos++] = c;		/* write the character */
f01004ec:	0f b7 83 08 23 00 00 	movzwl 0x2308(%ebx),%eax
f01004f3:	8d 50 01             	lea    0x1(%eax),%edx
f01004f6:	66 89 93 08 23 00 00 	mov    %dx,0x2308(%ebx)
f01004fd:	0f b7 c0             	movzwl %ax,%eax
f0100500:	8b 93 0c 23 00 00    	mov    0x230c(%ebx),%edx
f0100506:	0f b7 7d e4          	movzwl -0x1c(%ebp),%edi
f010050a:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f010050e:	e9 1d ff ff ff       	jmp    f0100430 <cons_putc+0xea>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100513:	8b 83 0c 23 00 00    	mov    0x230c(%ebx),%eax
f0100519:	83 ec 04             	sub    $0x4,%esp
f010051c:	68 00 0f 00 00       	push   $0xf00
f0100521:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100527:	52                   	push   %edx
f0100528:	50                   	push   %eax
f0100529:	e8 a6 42 00 00       	call   f01047d4 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f010052e:	8b 93 0c 23 00 00    	mov    0x230c(%ebx),%edx
f0100534:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010053a:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100540:	83 c4 10             	add    $0x10,%esp
f0100543:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100548:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010054b:	39 d0                	cmp    %edx,%eax
f010054d:	75 f4                	jne    f0100543 <cons_putc+0x1fd>
		crt_pos -= CRT_COLS;
f010054f:	66 83 ab 08 23 00 00 	subw   $0x50,0x2308(%ebx)
f0100556:	50 
f0100557:	e9 e3 fe ff ff       	jmp    f010043f <cons_putc+0xf9>

f010055c <serial_intr>:
{
f010055c:	e8 e7 01 00 00       	call   f0100748 <__x86.get_pc_thunk.ax>
f0100561:	05 bf aa 08 00       	add    $0x8aabf,%eax
	if (serial_exists)
f0100566:	80 b8 14 23 00 00 00 	cmpb   $0x0,0x2314(%eax)
f010056d:	75 02                	jne    f0100571 <serial_intr+0x15>
f010056f:	f3 c3                	repz ret 
{
f0100571:	55                   	push   %ebp
f0100572:	89 e5                	mov    %esp,%ebp
f0100574:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f0100577:	8d 80 8a 51 f7 ff    	lea    -0x8ae76(%eax),%eax
f010057d:	e8 47 fc ff ff       	call   f01001c9 <cons_intr>
}
f0100582:	c9                   	leave  
f0100583:	c3                   	ret    

f0100584 <kbd_intr>:
{
f0100584:	55                   	push   %ebp
f0100585:	89 e5                	mov    %esp,%ebp
f0100587:	83 ec 08             	sub    $0x8,%esp
f010058a:	e8 b9 01 00 00       	call   f0100748 <__x86.get_pc_thunk.ax>
f010058f:	05 91 aa 08 00       	add    $0x8aa91,%eax
	cons_intr(kbd_proc_data);
f0100594:	8d 80 f4 51 f7 ff    	lea    -0x8ae0c(%eax),%eax
f010059a:	e8 2a fc ff ff       	call   f01001c9 <cons_intr>
}
f010059f:	c9                   	leave  
f01005a0:	c3                   	ret    

f01005a1 <cons_getc>:
{
f01005a1:	55                   	push   %ebp
f01005a2:	89 e5                	mov    %esp,%ebp
f01005a4:	53                   	push   %ebx
f01005a5:	83 ec 04             	sub    $0x4,%esp
f01005a8:	e8 f9 fb ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f01005ad:	81 c3 73 aa 08 00    	add    $0x8aa73,%ebx
	serial_intr();
f01005b3:	e8 a4 ff ff ff       	call   f010055c <serial_intr>
	kbd_intr();
f01005b8:	e8 c7 ff ff ff       	call   f0100584 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01005bd:	8b 93 00 23 00 00    	mov    0x2300(%ebx),%edx
	return 0;
f01005c3:	b8 00 00 00 00       	mov    $0x0,%eax
	if (cons.rpos != cons.wpos) {
f01005c8:	3b 93 04 23 00 00    	cmp    0x2304(%ebx),%edx
f01005ce:	74 19                	je     f01005e9 <cons_getc+0x48>
		c = cons.buf[cons.rpos++];
f01005d0:	8d 4a 01             	lea    0x1(%edx),%ecx
f01005d3:	89 8b 00 23 00 00    	mov    %ecx,0x2300(%ebx)
f01005d9:	0f b6 84 13 00 21 00 	movzbl 0x2100(%ebx,%edx,1),%eax
f01005e0:	00 
		if (cons.rpos == CONSBUFSIZE)
f01005e1:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f01005e7:	74 06                	je     f01005ef <cons_getc+0x4e>
}
f01005e9:	83 c4 04             	add    $0x4,%esp
f01005ec:	5b                   	pop    %ebx
f01005ed:	5d                   	pop    %ebp
f01005ee:	c3                   	ret    
			cons.rpos = 0;
f01005ef:	c7 83 00 23 00 00 00 	movl   $0x0,0x2300(%ebx)
f01005f6:	00 00 00 
f01005f9:	eb ee                	jmp    f01005e9 <cons_getc+0x48>

f01005fb <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f01005fb:	55                   	push   %ebp
f01005fc:	89 e5                	mov    %esp,%ebp
f01005fe:	57                   	push   %edi
f01005ff:	56                   	push   %esi
f0100600:	53                   	push   %ebx
f0100601:	83 ec 1c             	sub    $0x1c,%esp
f0100604:	e8 9d fb ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f0100609:	81 c3 17 aa 08 00    	add    $0x8aa17,%ebx
	was = *cp;
f010060f:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100616:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010061d:	5a a5 
	if (*cp != 0xA55A) {
f010061f:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100626:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010062a:	0f 84 bc 00 00 00    	je     f01006ec <cons_init+0xf1>
		addr_6845 = MONO_BASE;
f0100630:	c7 83 10 23 00 00 b4 	movl   $0x3b4,0x2310(%ebx)
f0100637:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010063a:	c7 45 e4 00 00 0b f0 	movl   $0xf00b0000,-0x1c(%ebp)
	outb(addr_6845, 14);
f0100641:	8b bb 10 23 00 00    	mov    0x2310(%ebx),%edi
f0100647:	b8 0e 00 00 00       	mov    $0xe,%eax
f010064c:	89 fa                	mov    %edi,%edx
f010064e:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010064f:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100652:	89 ca                	mov    %ecx,%edx
f0100654:	ec                   	in     (%dx),%al
f0100655:	0f b6 f0             	movzbl %al,%esi
f0100658:	c1 e6 08             	shl    $0x8,%esi
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010065b:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100660:	89 fa                	mov    %edi,%edx
f0100662:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100663:	89 ca                	mov    %ecx,%edx
f0100665:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f0100666:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100669:	89 bb 0c 23 00 00    	mov    %edi,0x230c(%ebx)
	pos |= inb(addr_6845 + 1);
f010066f:	0f b6 c0             	movzbl %al,%eax
f0100672:	09 c6                	or     %eax,%esi
	crt_pos = pos;
f0100674:	66 89 b3 08 23 00 00 	mov    %si,0x2308(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010067b:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100680:	89 c8                	mov    %ecx,%eax
f0100682:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100687:	ee                   	out    %al,(%dx)
f0100688:	bf fb 03 00 00       	mov    $0x3fb,%edi
f010068d:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100692:	89 fa                	mov    %edi,%edx
f0100694:	ee                   	out    %al,(%dx)
f0100695:	b8 0c 00 00 00       	mov    $0xc,%eax
f010069a:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010069f:	ee                   	out    %al,(%dx)
f01006a0:	be f9 03 00 00       	mov    $0x3f9,%esi
f01006a5:	89 c8                	mov    %ecx,%eax
f01006a7:	89 f2                	mov    %esi,%edx
f01006a9:	ee                   	out    %al,(%dx)
f01006aa:	b8 03 00 00 00       	mov    $0x3,%eax
f01006af:	89 fa                	mov    %edi,%edx
f01006b1:	ee                   	out    %al,(%dx)
f01006b2:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01006b7:	89 c8                	mov    %ecx,%eax
f01006b9:	ee                   	out    %al,(%dx)
f01006ba:	b8 01 00 00 00       	mov    $0x1,%eax
f01006bf:	89 f2                	mov    %esi,%edx
f01006c1:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006c2:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01006c7:	ec                   	in     (%dx),%al
f01006c8:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01006ca:	3c ff                	cmp    $0xff,%al
f01006cc:	0f 95 83 14 23 00 00 	setne  0x2314(%ebx)
f01006d3:	ba fa 03 00 00       	mov    $0x3fa,%edx
f01006d8:	ec                   	in     (%dx),%al
f01006d9:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006de:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01006df:	80 f9 ff             	cmp    $0xff,%cl
f01006e2:	74 25                	je     f0100709 <cons_init+0x10e>
		cprintf("Serial port does not exist!\n");
}
f01006e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01006e7:	5b                   	pop    %ebx
f01006e8:	5e                   	pop    %esi
f01006e9:	5f                   	pop    %edi
f01006ea:	5d                   	pop    %ebp
f01006eb:	c3                   	ret    
		*cp = was;
f01006ec:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01006f3:	c7 83 10 23 00 00 d4 	movl   $0x3d4,0x2310(%ebx)
f01006fa:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006fd:	c7 45 e4 00 80 0b f0 	movl   $0xf00b8000,-0x1c(%ebp)
f0100704:	e9 38 ff ff ff       	jmp    f0100641 <cons_init+0x46>
		cprintf("Serial port does not exist!\n");
f0100709:	83 ec 0c             	sub    $0xc,%esp
f010070c:	8d 83 46 9c f7 ff    	lea    -0x863ba(%ebx),%eax
f0100712:	50                   	push   %eax
f0100713:	e8 be 2f 00 00       	call   f01036d6 <cprintf>
f0100718:	83 c4 10             	add    $0x10,%esp
}
f010071b:	eb c7                	jmp    f01006e4 <cons_init+0xe9>

f010071d <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010071d:	55                   	push   %ebp
f010071e:	89 e5                	mov    %esp,%ebp
f0100720:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100723:	8b 45 08             	mov    0x8(%ebp),%eax
f0100726:	e8 1b fc ff ff       	call   f0100346 <cons_putc>
}
f010072b:	c9                   	leave  
f010072c:	c3                   	ret    

f010072d <getchar>:

int
getchar(void)
{
f010072d:	55                   	push   %ebp
f010072e:	89 e5                	mov    %esp,%ebp
f0100730:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100733:	e8 69 fe ff ff       	call   f01005a1 <cons_getc>
f0100738:	85 c0                	test   %eax,%eax
f010073a:	74 f7                	je     f0100733 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010073c:	c9                   	leave  
f010073d:	c3                   	ret    

f010073e <iscons>:

int
iscons(int fdnum)
{
f010073e:	55                   	push   %ebp
f010073f:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100741:	b8 01 00 00 00       	mov    $0x1,%eax
f0100746:	5d                   	pop    %ebp
f0100747:	c3                   	ret    

f0100748 <__x86.get_pc_thunk.ax>:
f0100748:	8b 04 24             	mov    (%esp),%eax
f010074b:	c3                   	ret    

f010074c <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010074c:	55                   	push   %ebp
f010074d:	89 e5                	mov    %esp,%ebp
f010074f:	56                   	push   %esi
f0100750:	53                   	push   %ebx
f0100751:	e8 50 fa ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f0100756:	81 c3 ca a8 08 00    	add    $0x8a8ca,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010075c:	83 ec 04             	sub    $0x4,%esp
f010075f:	8d 83 80 9e f7 ff    	lea    -0x86180(%ebx),%eax
f0100765:	50                   	push   %eax
f0100766:	8d 83 9e 9e f7 ff    	lea    -0x86162(%ebx),%eax
f010076c:	50                   	push   %eax
f010076d:	8d b3 a3 9e f7 ff    	lea    -0x8615d(%ebx),%esi
f0100773:	56                   	push   %esi
f0100774:	e8 5d 2f 00 00       	call   f01036d6 <cprintf>
f0100779:	83 c4 0c             	add    $0xc,%esp
f010077c:	8d 83 44 9f f7 ff    	lea    -0x860bc(%ebx),%eax
f0100782:	50                   	push   %eax
f0100783:	8d 83 ac 9e f7 ff    	lea    -0x86154(%ebx),%eax
f0100789:	50                   	push   %eax
f010078a:	56                   	push   %esi
f010078b:	e8 46 2f 00 00       	call   f01036d6 <cprintf>
f0100790:	83 c4 0c             	add    $0xc,%esp
f0100793:	8d 83 6c 9f f7 ff    	lea    -0x86094(%ebx),%eax
f0100799:	50                   	push   %eax
f010079a:	8d 83 b5 9e f7 ff    	lea    -0x8614b(%ebx),%eax
f01007a0:	50                   	push   %eax
f01007a1:	56                   	push   %esi
f01007a2:	e8 2f 2f 00 00       	call   f01036d6 <cprintf>
	return 0;
}
f01007a7:	b8 00 00 00 00       	mov    $0x0,%eax
f01007ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01007af:	5b                   	pop    %ebx
f01007b0:	5e                   	pop    %esi
f01007b1:	5d                   	pop    %ebp
f01007b2:	c3                   	ret    

f01007b3 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007b3:	55                   	push   %ebp
f01007b4:	89 e5                	mov    %esp,%ebp
f01007b6:	57                   	push   %edi
f01007b7:	56                   	push   %esi
f01007b8:	53                   	push   %ebx
f01007b9:	83 ec 18             	sub    $0x18,%esp
f01007bc:	e8 e5 f9 ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f01007c1:	81 c3 5f a8 08 00    	add    $0x8a85f,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007c7:	8d 83 bf 9e f7 ff    	lea    -0x86141(%ebx),%eax
f01007cd:	50                   	push   %eax
f01007ce:	e8 03 2f 00 00       	call   f01036d6 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007d3:	83 c4 08             	add    $0x8,%esp
f01007d6:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
f01007dc:	8d 83 98 9f f7 ff    	lea    -0x86068(%ebx),%eax
f01007e2:	50                   	push   %eax
f01007e3:	e8 ee 2e 00 00       	call   f01036d6 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007e8:	83 c4 0c             	add    $0xc,%esp
f01007eb:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f01007f1:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f01007f7:	50                   	push   %eax
f01007f8:	57                   	push   %edi
f01007f9:	8d 83 c0 9f f7 ff    	lea    -0x86040(%ebx),%eax
f01007ff:	50                   	push   %eax
f0100800:	e8 d1 2e 00 00       	call   f01036d6 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100805:	83 c4 0c             	add    $0xc,%esp
f0100808:	c7 c0 c9 4b 10 f0    	mov    $0xf0104bc9,%eax
f010080e:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100814:	52                   	push   %edx
f0100815:	50                   	push   %eax
f0100816:	8d 83 e4 9f f7 ff    	lea    -0x8601c(%ebx),%eax
f010081c:	50                   	push   %eax
f010081d:	e8 b4 2e 00 00       	call   f01036d6 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100822:	83 c4 0c             	add    $0xc,%esp
f0100825:	c7 c0 00 d1 18 f0    	mov    $0xf018d100,%eax
f010082b:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100831:	52                   	push   %edx
f0100832:	50                   	push   %eax
f0100833:	8d 83 08 a0 f7 ff    	lea    -0x85ff8(%ebx),%eax
f0100839:	50                   	push   %eax
f010083a:	e8 97 2e 00 00       	call   f01036d6 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010083f:	83 c4 0c             	add    $0xc,%esp
f0100842:	c7 c6 00 e0 18 f0    	mov    $0xf018e000,%esi
f0100848:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f010084e:	50                   	push   %eax
f010084f:	56                   	push   %esi
f0100850:	8d 83 2c a0 f7 ff    	lea    -0x85fd4(%ebx),%eax
f0100856:	50                   	push   %eax
f0100857:	e8 7a 2e 00 00       	call   f01036d6 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f010085c:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f010085f:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
f0100865:	29 fe                	sub    %edi,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100867:	c1 fe 0a             	sar    $0xa,%esi
f010086a:	56                   	push   %esi
f010086b:	8d 83 50 a0 f7 ff    	lea    -0x85fb0(%ebx),%eax
f0100871:	50                   	push   %eax
f0100872:	e8 5f 2e 00 00       	call   f01036d6 <cprintf>
	return 0;
}
f0100877:	b8 00 00 00 00       	mov    $0x0,%eax
f010087c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010087f:	5b                   	pop    %ebx
f0100880:	5e                   	pop    %esi
f0100881:	5f                   	pop    %edi
f0100882:	5d                   	pop    %ebp
f0100883:	c3                   	ret    

f0100884 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100884:	55                   	push   %ebp
f0100885:	89 e5                	mov    %esp,%ebp
f0100887:	57                   	push   %edi
f0100888:	56                   	push   %esi
f0100889:	53                   	push   %ebx
f010088a:	83 ec 48             	sub    $0x48,%esp
f010088d:	e8 14 f9 ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f0100892:	81 c3 8e a7 08 00    	add    $0x8a78e,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100898:	89 ee                	mov    %ebp,%esi
	}*/
	uint32_t *ebp;
	struct Eipdebuginfo info;
	int result;
	ebp = (uint32_t*)read_ebp();
	cprintf("Stack backtrace:\r\n");
f010089a:	8d 83 d8 9e f7 ff    	lea    -0x86128(%ebx),%eax
f01008a0:	50                   	push   %eax
f01008a1:	e8 30 2e 00 00       	call   f01036d6 <cprintf>

	while(ebp){
f01008a6:	83 c4 10             	add    $0x10,%esp
	cprintf("    ebp %08x eip %08x args %08x %08x %08x %08x %08x\r\n",ebp,ebp[1],ebp[2],ebp[3],ebp[4],ebp[5],ebp[6]);//ebp[i] what meaning?
f01008a9:	8d 83 7c a0 f7 ff    	lea    -0x85f84(%ebx),%eax
f01008af:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	memset(&info,0,sizeof(struct Eipdebuginfo));
f01008b2:	8d 7d d0             	lea    -0x30(%ebp),%edi
	while(ebp){
f01008b5:	eb 27                	jmp    f01008de <mon_backtrace+0x5a>
	result = debuginfo_eip(ebp[1],&info);
	if(result){
	   cprintf("failed\r\n",ebp[1]);
	}else{
	cprintf("\t%s:%d: %.*s+%u\r\n",info.eip_file,info.eip_line,info.eip_fn_namelen,info.eip_fn_name,ebp[1]-info.eip_fn_addr);
f01008b7:	83 ec 08             	sub    $0x8,%esp
f01008ba:	8b 46 04             	mov    0x4(%esi),%eax
f01008bd:	2b 45 e0             	sub    -0x20(%ebp),%eax
f01008c0:	50                   	push   %eax
f01008c1:	ff 75 d8             	pushl  -0x28(%ebp)
f01008c4:	ff 75 dc             	pushl  -0x24(%ebp)
f01008c7:	ff 75 d4             	pushl  -0x2c(%ebp)
f01008ca:	ff 75 d0             	pushl  -0x30(%ebp)
f01008cd:	8d 83 f4 9e f7 ff    	lea    -0x8610c(%ebx),%eax
f01008d3:	50                   	push   %eax
f01008d4:	e8 fd 2d 00 00       	call   f01036d6 <cprintf>
f01008d9:	83 c4 20             	add    $0x20,%esp
	}
	ebp = (uint32_t*)*ebp;
f01008dc:	8b 36                	mov    (%esi),%esi
	while(ebp){
f01008de:	85 f6                	test   %esi,%esi
f01008e0:	74 52                	je     f0100934 <mon_backtrace+0xb0>
	cprintf("    ebp %08x eip %08x args %08x %08x %08x %08x %08x\r\n",ebp,ebp[1],ebp[2],ebp[3],ebp[4],ebp[5],ebp[6]);//ebp[i] what meaning?
f01008e2:	ff 76 18             	pushl  0x18(%esi)
f01008e5:	ff 76 14             	pushl  0x14(%esi)
f01008e8:	ff 76 10             	pushl  0x10(%esi)
f01008eb:	ff 76 0c             	pushl  0xc(%esi)
f01008ee:	ff 76 08             	pushl  0x8(%esi)
f01008f1:	ff 76 04             	pushl  0x4(%esi)
f01008f4:	56                   	push   %esi
f01008f5:	ff 75 c4             	pushl  -0x3c(%ebp)
f01008f8:	e8 d9 2d 00 00       	call   f01036d6 <cprintf>
	memset(&info,0,sizeof(struct Eipdebuginfo));
f01008fd:	83 c4 1c             	add    $0x1c,%esp
f0100900:	6a 18                	push   $0x18
f0100902:	6a 00                	push   $0x0
f0100904:	57                   	push   %edi
f0100905:	e8 7d 3e 00 00       	call   f0104787 <memset>
	result = debuginfo_eip(ebp[1],&info);
f010090a:	83 c4 08             	add    $0x8,%esp
f010090d:	57                   	push   %edi
f010090e:	ff 76 04             	pushl  0x4(%esi)
f0100911:	e8 66 33 00 00       	call   f0103c7c <debuginfo_eip>
	if(result){
f0100916:	83 c4 10             	add    $0x10,%esp
f0100919:	85 c0                	test   %eax,%eax
f010091b:	74 9a                	je     f01008b7 <mon_backtrace+0x33>
	   cprintf("failed\r\n",ebp[1]);
f010091d:	83 ec 08             	sub    $0x8,%esp
f0100920:	ff 76 04             	pushl  0x4(%esi)
f0100923:	8d 83 eb 9e f7 ff    	lea    -0x86115(%ebx),%eax
f0100929:	50                   	push   %eax
f010092a:	e8 a7 2d 00 00       	call   f01036d6 <cprintf>
f010092f:	83 c4 10             	add    $0x10,%esp
f0100932:	eb a8                	jmp    f01008dc <mon_backtrace+0x58>
	}
	return 0;
}
f0100934:	b8 00 00 00 00       	mov    $0x0,%eax
f0100939:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010093c:	5b                   	pop    %ebx
f010093d:	5e                   	pop    %esi
f010093e:	5f                   	pop    %edi
f010093f:	5d                   	pop    %ebp
f0100940:	c3                   	ret    

f0100941 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100941:	55                   	push   %ebp
f0100942:	89 e5                	mov    %esp,%ebp
f0100944:	57                   	push   %edi
f0100945:	56                   	push   %esi
f0100946:	53                   	push   %ebx
f0100947:	83 ec 68             	sub    $0x68,%esp
f010094a:	e8 57 f8 ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f010094f:	81 c3 d1 a6 08 00    	add    $0x8a6d1,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100955:	8d 83 b4 a0 f7 ff    	lea    -0x85f4c(%ebx),%eax
f010095b:	50                   	push   %eax
f010095c:	e8 75 2d 00 00       	call   f01036d6 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100961:	8d 83 d8 a0 f7 ff    	lea    -0x85f28(%ebx),%eax
f0100967:	89 04 24             	mov    %eax,(%esp)
f010096a:	e8 67 2d 00 00       	call   f01036d6 <cprintf>

	if (tf != NULL)
f010096f:	83 c4 10             	add    $0x10,%esp
f0100972:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100976:	74 0e                	je     f0100986 <monitor+0x45>
		print_trapframe(tf);
f0100978:	83 ec 0c             	sub    $0xc,%esp
f010097b:	ff 75 08             	pushl  0x8(%ebp)
f010097e:	e8 bc 2e 00 00       	call   f010383f <print_trapframe>
f0100983:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f0100986:	8d bb 0a 9f f7 ff    	lea    -0x860f6(%ebx),%edi
f010098c:	eb 4a                	jmp    f01009d8 <monitor+0x97>
f010098e:	83 ec 08             	sub    $0x8,%esp
f0100991:	0f be c0             	movsbl %al,%eax
f0100994:	50                   	push   %eax
f0100995:	57                   	push   %edi
f0100996:	e8 af 3d 00 00       	call   f010474a <strchr>
f010099b:	83 c4 10             	add    $0x10,%esp
f010099e:	85 c0                	test   %eax,%eax
f01009a0:	74 08                	je     f01009aa <monitor+0x69>
			*buf++ = 0;
f01009a2:	c6 06 00             	movb   $0x0,(%esi)
f01009a5:	8d 76 01             	lea    0x1(%esi),%esi
f01009a8:	eb 76                	jmp    f0100a20 <monitor+0xdf>
		if (*buf == 0)
f01009aa:	80 3e 00             	cmpb   $0x0,(%esi)
f01009ad:	74 7c                	je     f0100a2b <monitor+0xea>
		if (argc == MAXARGS-1) {
f01009af:	83 7d a4 0f          	cmpl   $0xf,-0x5c(%ebp)
f01009b3:	74 0f                	je     f01009c4 <monitor+0x83>
		argv[argc++] = buf;
f01009b5:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f01009b8:	8d 48 01             	lea    0x1(%eax),%ecx
f01009bb:	89 4d a4             	mov    %ecx,-0x5c(%ebp)
f01009be:	89 74 85 a8          	mov    %esi,-0x58(%ebp,%eax,4)
f01009c2:	eb 41                	jmp    f0100a05 <monitor+0xc4>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01009c4:	83 ec 08             	sub    $0x8,%esp
f01009c7:	6a 10                	push   $0x10
f01009c9:	8d 83 0f 9f f7 ff    	lea    -0x860f1(%ebx),%eax
f01009cf:	50                   	push   %eax
f01009d0:	e8 01 2d 00 00       	call   f01036d6 <cprintf>
f01009d5:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f01009d8:	8d 83 06 9f f7 ff    	lea    -0x860fa(%ebx),%eax
f01009de:	89 c6                	mov    %eax,%esi
f01009e0:	83 ec 0c             	sub    $0xc,%esp
f01009e3:	56                   	push   %esi
f01009e4:	e8 29 3b 00 00       	call   f0104512 <readline>
		if (buf != NULL)
f01009e9:	83 c4 10             	add    $0x10,%esp
f01009ec:	85 c0                	test   %eax,%eax
f01009ee:	74 f0                	je     f01009e0 <monitor+0x9f>
f01009f0:	89 c6                	mov    %eax,%esi
	argv[argc] = 0;
f01009f2:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f01009f9:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f0100a00:	eb 1e                	jmp    f0100a20 <monitor+0xdf>
			buf++;
f0100a02:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a05:	0f b6 06             	movzbl (%esi),%eax
f0100a08:	84 c0                	test   %al,%al
f0100a0a:	74 14                	je     f0100a20 <monitor+0xdf>
f0100a0c:	83 ec 08             	sub    $0x8,%esp
f0100a0f:	0f be c0             	movsbl %al,%eax
f0100a12:	50                   	push   %eax
f0100a13:	57                   	push   %edi
f0100a14:	e8 31 3d 00 00       	call   f010474a <strchr>
f0100a19:	83 c4 10             	add    $0x10,%esp
f0100a1c:	85 c0                	test   %eax,%eax
f0100a1e:	74 e2                	je     f0100a02 <monitor+0xc1>
		while (*buf && strchr(WHITESPACE, *buf))
f0100a20:	0f b6 06             	movzbl (%esi),%eax
f0100a23:	84 c0                	test   %al,%al
f0100a25:	0f 85 63 ff ff ff    	jne    f010098e <monitor+0x4d>
	argv[argc] = 0;
f0100a2b:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0100a2e:	c7 44 85 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%eax,4)
f0100a35:	00 
	if (argc == 0)
f0100a36:	85 c0                	test   %eax,%eax
f0100a38:	74 9e                	je     f01009d8 <monitor+0x97>
f0100a3a:	8d b3 20 20 00 00    	lea    0x2020(%ebx),%esi
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a40:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a45:	89 7d a0             	mov    %edi,-0x60(%ebp)
f0100a48:	89 c7                	mov    %eax,%edi
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a4a:	83 ec 08             	sub    $0x8,%esp
f0100a4d:	ff 36                	pushl  (%esi)
f0100a4f:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a52:	e8 95 3c 00 00       	call   f01046ec <strcmp>
f0100a57:	83 c4 10             	add    $0x10,%esp
f0100a5a:	85 c0                	test   %eax,%eax
f0100a5c:	74 28                	je     f0100a86 <monitor+0x145>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a5e:	83 c7 01             	add    $0x1,%edi
f0100a61:	83 c6 0c             	add    $0xc,%esi
f0100a64:	83 ff 03             	cmp    $0x3,%edi
f0100a67:	75 e1                	jne    f0100a4a <monitor+0x109>
f0100a69:	8b 7d a0             	mov    -0x60(%ebp),%edi
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a6c:	83 ec 08             	sub    $0x8,%esp
f0100a6f:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a72:	8d 83 2c 9f f7 ff    	lea    -0x860d4(%ebx),%eax
f0100a78:	50                   	push   %eax
f0100a79:	e8 58 2c 00 00       	call   f01036d6 <cprintf>
f0100a7e:	83 c4 10             	add    $0x10,%esp
f0100a81:	e9 52 ff ff ff       	jmp    f01009d8 <monitor+0x97>
f0100a86:	89 f8                	mov    %edi,%eax
f0100a88:	8b 7d a0             	mov    -0x60(%ebp),%edi
			return commands[i].func(argc, argv, tf);
f0100a8b:	83 ec 04             	sub    $0x4,%esp
f0100a8e:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100a91:	ff 75 08             	pushl  0x8(%ebp)
f0100a94:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a97:	52                   	push   %edx
f0100a98:	ff 75 a4             	pushl  -0x5c(%ebp)
f0100a9b:	ff 94 83 28 20 00 00 	call   *0x2028(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100aa2:	83 c4 10             	add    $0x10,%esp
f0100aa5:	85 c0                	test   %eax,%eax
f0100aa7:	0f 89 2b ff ff ff    	jns    f01009d8 <monitor+0x97>
				break;
	}
}
f0100aad:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ab0:	5b                   	pop    %ebx
f0100ab1:	5e                   	pop    %esi
f0100ab2:	5f                   	pop    %edi
f0100ab3:	5d                   	pop    %ebp
f0100ab4:	c3                   	ret    

f0100ab5 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100ab5:	55                   	push   %ebp
f0100ab6:	89 e5                	mov    %esp,%ebp
f0100ab8:	53                   	push   %ebx
f0100ab9:	e8 e1 26 00 00       	call   f010319f <__x86.get_pc_thunk.dx>
f0100abe:	81 c2 62 a5 08 00    	add    $0x8a562,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100ac4:	83 ba 18 23 00 00 00 	cmpl   $0x0,0x2318(%edx)
f0100acb:	74 1e                	je     f0100aeb <boot_alloc+0x36>
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
        result = nextfree;
f0100acd:	8b 9a 18 23 00 00    	mov    0x2318(%edx),%ebx
	nextfree = ROUNDUP(nextfree+n,PGSIZE);
f0100ad3:	8d 8c 03 ff 0f 00 00 	lea    0xfff(%ebx,%eax,1),%ecx
f0100ada:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0100ae0:	89 8a 18 23 00 00    	mov    %ecx,0x2318(%edx)
	return result;
}
f0100ae6:	89 d8                	mov    %ebx,%eax
f0100ae8:	5b                   	pop    %ebx
f0100ae9:	5d                   	pop    %ebp
f0100aea:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100aeb:	c7 c1 00 e0 18 f0    	mov    $0xf018e000,%ecx
f0100af1:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
f0100af7:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0100afd:	89 8a 18 23 00 00    	mov    %ecx,0x2318(%edx)
f0100b03:	eb c8                	jmp    f0100acd <boot_alloc+0x18>

f0100b05 <nvram_read>:
{
f0100b05:	55                   	push   %ebp
f0100b06:	89 e5                	mov    %esp,%ebp
f0100b08:	57                   	push   %edi
f0100b09:	56                   	push   %esi
f0100b0a:	53                   	push   %ebx
f0100b0b:	83 ec 18             	sub    $0x18,%esp
f0100b0e:	e8 93 f6 ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f0100b13:	81 c3 0d a5 08 00    	add    $0x8a50d,%ebx
f0100b19:	89 c7                	mov    %eax,%edi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100b1b:	50                   	push   %eax
f0100b1c:	e8 2e 2b 00 00       	call   f010364f <mc146818_read>
f0100b21:	89 c6                	mov    %eax,%esi
f0100b23:	83 c7 01             	add    $0x1,%edi
f0100b26:	89 3c 24             	mov    %edi,(%esp)
f0100b29:	e8 21 2b 00 00       	call   f010364f <mc146818_read>
f0100b2e:	c1 e0 08             	shl    $0x8,%eax
f0100b31:	09 f0                	or     %esi,%eax
}
f0100b33:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100b36:	5b                   	pop    %ebx
f0100b37:	5e                   	pop    %esi
f0100b38:	5f                   	pop    %edi
f0100b39:	5d                   	pop    %ebp
f0100b3a:	c3                   	ret    

f0100b3b <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100b3b:	55                   	push   %ebp
f0100b3c:	89 e5                	mov    %esp,%ebp
f0100b3e:	56                   	push   %esi
f0100b3f:	53                   	push   %ebx
f0100b40:	e8 5e 26 00 00       	call   f01031a3 <__x86.get_pc_thunk.cx>
f0100b45:	81 c1 db a4 08 00    	add    $0x8a4db,%ecx
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100b4b:	89 d3                	mov    %edx,%ebx
f0100b4d:	c1 eb 16             	shr    $0x16,%ebx
	if (!(*pgdir & PTE_P))
f0100b50:	8b 04 98             	mov    (%eax,%ebx,4),%eax
f0100b53:	a8 01                	test   $0x1,%al
f0100b55:	74 5a                	je     f0100bb1 <check_va2pa+0x76>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b57:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b5c:	89 c6                	mov    %eax,%esi
f0100b5e:	c1 ee 0c             	shr    $0xc,%esi
f0100b61:	c7 c3 08 e0 18 f0    	mov    $0xf018e008,%ebx
f0100b67:	3b 33                	cmp    (%ebx),%esi
f0100b69:	73 2b                	jae    f0100b96 <check_va2pa+0x5b>
	if (!(p[PTX(va)] & PTE_P))
f0100b6b:	c1 ea 0c             	shr    $0xc,%edx
f0100b6e:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b74:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100b7b:	89 c2                	mov    %eax,%edx
f0100b7d:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b80:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b85:	85 d2                	test   %edx,%edx
f0100b87:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b8c:	0f 44 c2             	cmove  %edx,%eax
}
f0100b8f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100b92:	5b                   	pop    %ebx
f0100b93:	5e                   	pop    %esi
f0100b94:	5d                   	pop    %ebp
f0100b95:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b96:	50                   	push   %eax
f0100b97:	8d 81 00 a1 f7 ff    	lea    -0x85f00(%ecx),%eax
f0100b9d:	50                   	push   %eax
f0100b9e:	68 12 03 00 00       	push   $0x312
f0100ba3:	8d 81 cd a8 f7 ff    	lea    -0x85733(%ecx),%eax
f0100ba9:	50                   	push   %eax
f0100baa:	89 cb                	mov    %ecx,%ebx
f0100bac:	e8 3f f5 ff ff       	call   f01000f0 <_panic>
		return ~0;
f0100bb1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100bb6:	eb d7                	jmp    f0100b8f <check_va2pa+0x54>

f0100bb8 <check_page_free_list>:
{
f0100bb8:	55                   	push   %ebp
f0100bb9:	89 e5                	mov    %esp,%ebp
f0100bbb:	57                   	push   %edi
f0100bbc:	56                   	push   %esi
f0100bbd:	53                   	push   %ebx
f0100bbe:	83 ec 3c             	sub    $0x3c,%esp
f0100bc1:	e8 e1 25 00 00       	call   f01031a7 <__x86.get_pc_thunk.di>
f0100bc6:	81 c7 5a a4 08 00    	add    $0x8a45a,%edi
f0100bcc:	89 7d c4             	mov    %edi,-0x3c(%ebp)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100bcf:	84 c0                	test   %al,%al
f0100bd1:	0f 85 dd 02 00 00    	jne    f0100eb4 <check_page_free_list+0x2fc>
	if (!page_free_list)
f0100bd7:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100bda:	83 b8 1c 23 00 00 00 	cmpl   $0x0,0x231c(%eax)
f0100be1:	74 0c                	je     f0100bef <check_page_free_list+0x37>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100be3:	c7 45 d4 00 04 00 00 	movl   $0x400,-0x2c(%ebp)
f0100bea:	e9 2f 03 00 00       	jmp    f0100f1e <check_page_free_list+0x366>
		panic("'page_free_list' is a null pointer!");
f0100bef:	83 ec 04             	sub    $0x4,%esp
f0100bf2:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100bf5:	8d 83 24 a1 f7 ff    	lea    -0x85edc(%ebx),%eax
f0100bfb:	50                   	push   %eax
f0100bfc:	68 4e 02 00 00       	push   $0x24e
f0100c01:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0100c07:	50                   	push   %eax
f0100c08:	e8 e3 f4 ff ff       	call   f01000f0 <_panic>
f0100c0d:	50                   	push   %eax
f0100c0e:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100c11:	8d 83 00 a1 f7 ff    	lea    -0x85f00(%ebx),%eax
f0100c17:	50                   	push   %eax
f0100c18:	6a 56                	push   $0x56
f0100c1a:	8d 83 d9 a8 f7 ff    	lea    -0x85727(%ebx),%eax
f0100c20:	50                   	push   %eax
f0100c21:	e8 ca f4 ff ff       	call   f01000f0 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c26:	8b 36                	mov    (%esi),%esi
f0100c28:	85 f6                	test   %esi,%esi
f0100c2a:	74 40                	je     f0100c6c <check_page_free_list+0xb4>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c2c:	89 f0                	mov    %esi,%eax
f0100c2e:	2b 07                	sub    (%edi),%eax
f0100c30:	c1 f8 03             	sar    $0x3,%eax
f0100c33:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100c36:	89 c2                	mov    %eax,%edx
f0100c38:	c1 ea 16             	shr    $0x16,%edx
f0100c3b:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100c3e:	73 e6                	jae    f0100c26 <check_page_free_list+0x6e>
	if (PGNUM(pa) >= npages)
f0100c40:	89 c2                	mov    %eax,%edx
f0100c42:	c1 ea 0c             	shr    $0xc,%edx
f0100c45:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0100c48:	3b 11                	cmp    (%ecx),%edx
f0100c4a:	73 c1                	jae    f0100c0d <check_page_free_list+0x55>
			memset(page2kva(pp), 0x97, 128);
f0100c4c:	83 ec 04             	sub    $0x4,%esp
f0100c4f:	68 80 00 00 00       	push   $0x80
f0100c54:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100c59:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c5e:	50                   	push   %eax
f0100c5f:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100c62:	e8 20 3b 00 00       	call   f0104787 <memset>
f0100c67:	83 c4 10             	add    $0x10,%esp
f0100c6a:	eb ba                	jmp    f0100c26 <check_page_free_list+0x6e>
	first_free_page = (char *) boot_alloc(0);
f0100c6c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c71:	e8 3f fe ff ff       	call   f0100ab5 <boot_alloc>
f0100c76:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c79:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100c7c:	8b 97 1c 23 00 00    	mov    0x231c(%edi),%edx
		assert(pp >= pages);
f0100c82:	c7 c0 10 e0 18 f0    	mov    $0xf018e010,%eax
f0100c88:	8b 08                	mov    (%eax),%ecx
		assert(pp < pages + npages);
f0100c8a:	c7 c0 08 e0 18 f0    	mov    $0xf018e008,%eax
f0100c90:	8b 00                	mov    (%eax),%eax
f0100c92:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100c95:	8d 1c c1             	lea    (%ecx,%eax,8),%ebx
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c98:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c9b:	bf 00 00 00 00       	mov    $0x0,%edi
f0100ca0:	89 75 d0             	mov    %esi,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ca3:	e9 08 01 00 00       	jmp    f0100db0 <check_page_free_list+0x1f8>
		assert(pp >= pages);
f0100ca8:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100cab:	8d 83 e7 a8 f7 ff    	lea    -0x85719(%ebx),%eax
f0100cb1:	50                   	push   %eax
f0100cb2:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0100cb8:	50                   	push   %eax
f0100cb9:	68 68 02 00 00       	push   $0x268
f0100cbe:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0100cc4:	50                   	push   %eax
f0100cc5:	e8 26 f4 ff ff       	call   f01000f0 <_panic>
		assert(pp < pages + npages);
f0100cca:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100ccd:	8d 83 08 a9 f7 ff    	lea    -0x856f8(%ebx),%eax
f0100cd3:	50                   	push   %eax
f0100cd4:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0100cda:	50                   	push   %eax
f0100cdb:	68 69 02 00 00       	push   $0x269
f0100ce0:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0100ce6:	50                   	push   %eax
f0100ce7:	e8 04 f4 ff ff       	call   f01000f0 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100cec:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100cef:	8d 83 48 a1 f7 ff    	lea    -0x85eb8(%ebx),%eax
f0100cf5:	50                   	push   %eax
f0100cf6:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0100cfc:	50                   	push   %eax
f0100cfd:	68 6a 02 00 00       	push   $0x26a
f0100d02:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0100d08:	50                   	push   %eax
f0100d09:	e8 e2 f3 ff ff       	call   f01000f0 <_panic>
		assert(page2pa(pp) != 0);
f0100d0e:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100d11:	8d 83 1c a9 f7 ff    	lea    -0x856e4(%ebx),%eax
f0100d17:	50                   	push   %eax
f0100d18:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0100d1e:	50                   	push   %eax
f0100d1f:	68 6d 02 00 00       	push   $0x26d
f0100d24:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0100d2a:	50                   	push   %eax
f0100d2b:	e8 c0 f3 ff ff       	call   f01000f0 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d30:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100d33:	8d 83 2d a9 f7 ff    	lea    -0x856d3(%ebx),%eax
f0100d39:	50                   	push   %eax
f0100d3a:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0100d40:	50                   	push   %eax
f0100d41:	68 6e 02 00 00       	push   $0x26e
f0100d46:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0100d4c:	50                   	push   %eax
f0100d4d:	e8 9e f3 ff ff       	call   f01000f0 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d52:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100d55:	8d 83 7c a1 f7 ff    	lea    -0x85e84(%ebx),%eax
f0100d5b:	50                   	push   %eax
f0100d5c:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0100d62:	50                   	push   %eax
f0100d63:	68 6f 02 00 00       	push   $0x26f
f0100d68:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0100d6e:	50                   	push   %eax
f0100d6f:	e8 7c f3 ff ff       	call   f01000f0 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d74:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100d77:	8d 83 46 a9 f7 ff    	lea    -0x856ba(%ebx),%eax
f0100d7d:	50                   	push   %eax
f0100d7e:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0100d84:	50                   	push   %eax
f0100d85:	68 70 02 00 00       	push   $0x270
f0100d8a:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0100d90:	50                   	push   %eax
f0100d91:	e8 5a f3 ff ff       	call   f01000f0 <_panic>
	if (PGNUM(pa) >= npages)
f0100d96:	89 c6                	mov    %eax,%esi
f0100d98:	c1 ee 0c             	shr    $0xc,%esi
f0100d9b:	39 75 cc             	cmp    %esi,-0x34(%ebp)
f0100d9e:	76 70                	jbe    f0100e10 <check_page_free_list+0x258>
	return (void *)(pa + KERNBASE);
f0100da0:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100da5:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f0100da8:	77 7f                	ja     f0100e29 <check_page_free_list+0x271>
			++nfree_extmem;
f0100daa:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100dae:	8b 12                	mov    (%edx),%edx
f0100db0:	85 d2                	test   %edx,%edx
f0100db2:	0f 84 93 00 00 00    	je     f0100e4b <check_page_free_list+0x293>
		assert(pp >= pages);
f0100db8:	39 d1                	cmp    %edx,%ecx
f0100dba:	0f 87 e8 fe ff ff    	ja     f0100ca8 <check_page_free_list+0xf0>
		assert(pp < pages + npages);
f0100dc0:	39 d3                	cmp    %edx,%ebx
f0100dc2:	0f 86 02 ff ff ff    	jbe    f0100cca <check_page_free_list+0x112>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100dc8:	89 d0                	mov    %edx,%eax
f0100dca:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100dcd:	a8 07                	test   $0x7,%al
f0100dcf:	0f 85 17 ff ff ff    	jne    f0100cec <check_page_free_list+0x134>
	return (pp - pages) << PGSHIFT;
f0100dd5:	c1 f8 03             	sar    $0x3,%eax
f0100dd8:	c1 e0 0c             	shl    $0xc,%eax
		assert(page2pa(pp) != 0);
f0100ddb:	85 c0                	test   %eax,%eax
f0100ddd:	0f 84 2b ff ff ff    	je     f0100d0e <check_page_free_list+0x156>
		assert(page2pa(pp) != IOPHYSMEM);
f0100de3:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100de8:	0f 84 42 ff ff ff    	je     f0100d30 <check_page_free_list+0x178>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100dee:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100df3:	0f 84 59 ff ff ff    	je     f0100d52 <check_page_free_list+0x19a>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100df9:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100dfe:	0f 84 70 ff ff ff    	je     f0100d74 <check_page_free_list+0x1bc>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100e04:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100e09:	77 8b                	ja     f0100d96 <check_page_free_list+0x1de>
			++nfree_basemem;
f0100e0b:	83 c7 01             	add    $0x1,%edi
f0100e0e:	eb 9e                	jmp    f0100dae <check_page_free_list+0x1f6>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e10:	50                   	push   %eax
f0100e11:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100e14:	8d 83 00 a1 f7 ff    	lea    -0x85f00(%ebx),%eax
f0100e1a:	50                   	push   %eax
f0100e1b:	6a 56                	push   $0x56
f0100e1d:	8d 83 d9 a8 f7 ff    	lea    -0x85727(%ebx),%eax
f0100e23:	50                   	push   %eax
f0100e24:	e8 c7 f2 ff ff       	call   f01000f0 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100e29:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100e2c:	8d 83 a0 a1 f7 ff    	lea    -0x85e60(%ebx),%eax
f0100e32:	50                   	push   %eax
f0100e33:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0100e39:	50                   	push   %eax
f0100e3a:	68 71 02 00 00       	push   $0x271
f0100e3f:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0100e45:	50                   	push   %eax
f0100e46:	e8 a5 f2 ff ff       	call   f01000f0 <_panic>
f0100e4b:	8b 75 d0             	mov    -0x30(%ebp),%esi
	assert(nfree_basemem > 0);
f0100e4e:	85 ff                	test   %edi,%edi
f0100e50:	7e 1e                	jle    f0100e70 <check_page_free_list+0x2b8>
	assert(nfree_extmem > 0);
f0100e52:	85 f6                	test   %esi,%esi
f0100e54:	7e 3c                	jle    f0100e92 <check_page_free_list+0x2da>
	cprintf("check_page_free_list() succeeded!\n");
f0100e56:	83 ec 0c             	sub    $0xc,%esp
f0100e59:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100e5c:	8d 83 e8 a1 f7 ff    	lea    -0x85e18(%ebx),%eax
f0100e62:	50                   	push   %eax
f0100e63:	e8 6e 28 00 00       	call   f01036d6 <cprintf>
}
f0100e68:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e6b:	5b                   	pop    %ebx
f0100e6c:	5e                   	pop    %esi
f0100e6d:	5f                   	pop    %edi
f0100e6e:	5d                   	pop    %ebp
f0100e6f:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100e70:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100e73:	8d 83 60 a9 f7 ff    	lea    -0x856a0(%ebx),%eax
f0100e79:	50                   	push   %eax
f0100e7a:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0100e80:	50                   	push   %eax
f0100e81:	68 79 02 00 00       	push   $0x279
f0100e86:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0100e8c:	50                   	push   %eax
f0100e8d:	e8 5e f2 ff ff       	call   f01000f0 <_panic>
	assert(nfree_extmem > 0);
f0100e92:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100e95:	8d 83 72 a9 f7 ff    	lea    -0x8568e(%ebx),%eax
f0100e9b:	50                   	push   %eax
f0100e9c:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0100ea2:	50                   	push   %eax
f0100ea3:	68 7a 02 00 00       	push   $0x27a
f0100ea8:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0100eae:	50                   	push   %eax
f0100eaf:	e8 3c f2 ff ff       	call   f01000f0 <_panic>
	if (!page_free_list)
f0100eb4:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100eb7:	8b 80 1c 23 00 00    	mov    0x231c(%eax),%eax
f0100ebd:	85 c0                	test   %eax,%eax
f0100ebf:	0f 84 2a fd ff ff    	je     f0100bef <check_page_free_list+0x37>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100ec5:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100ec8:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100ecb:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100ece:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	return (pp - pages) << PGSHIFT;
f0100ed1:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100ed4:	c7 c3 10 e0 18 f0    	mov    $0xf018e010,%ebx
f0100eda:	89 c2                	mov    %eax,%edx
f0100edc:	2b 13                	sub    (%ebx),%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100ede:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100ee4:	0f 95 c2             	setne  %dl
f0100ee7:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100eea:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100eee:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100ef0:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ef4:	8b 00                	mov    (%eax),%eax
f0100ef6:	85 c0                	test   %eax,%eax
f0100ef8:	75 e0                	jne    f0100eda <check_page_free_list+0x322>
		*tp[1] = 0;
f0100efa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100efd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100f03:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100f06:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100f09:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100f0b:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100f0e:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100f11:	89 87 1c 23 00 00    	mov    %eax,0x231c(%edi)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100f17:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100f1e:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100f21:	8b b0 1c 23 00 00    	mov    0x231c(%eax),%esi
f0100f27:	c7 c7 10 e0 18 f0    	mov    $0xf018e010,%edi
	if (PGNUM(pa) >= npages)
f0100f2d:	c7 c0 08 e0 18 f0    	mov    $0xf018e008,%eax
f0100f33:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100f36:	e9 ed fc ff ff       	jmp    f0100c28 <check_page_free_list+0x70>

f0100f3b <page_init>:
{
f0100f3b:	55                   	push   %ebp
f0100f3c:	89 e5                	mov    %esp,%ebp
f0100f3e:	57                   	push   %edi
f0100f3f:	56                   	push   %esi
f0100f40:	53                   	push   %ebx
f0100f41:	83 ec 2c             	sub    $0x2c,%esp
f0100f44:	e8 5d f2 ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f0100f49:	81 c3 d7 a0 08 00    	add    $0x8a0d7,%ebx
        page_free_list = NULL;
f0100f4f:	c7 83 1c 23 00 00 00 	movl   $0x0,0x231c(%ebx)
f0100f56:	00 00 00 
	size_t first_free_extend_addr = PADDR (boot_alloc(0));
f0100f59:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f5e:	e8 52 fb ff ff       	call   f0100ab5 <boot_alloc>
	if ((uint32_t)kva < KERNBASE)
f0100f63:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100f68:	76 30                	jbe    f0100f9a <page_init+0x5f>
	return (physaddr_t)kva - KERNBASE;
f0100f6a:	05 00 00 00 10       	add    $0x10000000,%eax
f0100f6f:	89 45 dc             	mov    %eax,-0x24(%ebp)
	for (i = 0; i < npages; i++) {
f0100f72:	be 00 00 00 00       	mov    $0x0,%esi
f0100f77:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0100f7e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f83:	c7 c2 08 e0 18 f0    	mov    $0xf018e008,%edx
                 pages[i].pp_ref = 0;
f0100f89:	c7 c7 10 e0 18 f0    	mov    $0xf018e010,%edi
f0100f8f:	89 7d e0             	mov    %edi,-0x20(%ebp)
		        pages[i].pp_ref = 1;
f0100f92:	89 7d d4             	mov    %edi,-0x2c(%ebp)
		  pages[i].pp_ref = 1;
f0100f95:	89 7d d8             	mov    %edi,-0x28(%ebp)
	for (i = 0; i < npages; i++) {
f0100f98:	eb 56                	jmp    f0100ff0 <page_init+0xb5>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100f9a:	50                   	push   %eax
f0100f9b:	8d 83 0c a2 f7 ff    	lea    -0x85df4(%ebx),%eax
f0100fa1:	50                   	push   %eax
f0100fa2:	68 10 01 00 00       	push   $0x110
f0100fa7:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0100fad:	50                   	push   %eax
f0100fae:	e8 3d f1 ff ff       	call   f01000f0 <_panic>
f0100fb3:	89 c1                	mov    %eax,%ecx
f0100fb5:	c1 e1 0c             	shl    $0xc,%ecx
		}else if(i*PGSIZE>=IOPHYSMEM && i*PGSIZE<=first_free_extend_addr){
f0100fb8:	39 4d dc             	cmp    %ecx,-0x24(%ebp)
f0100fbb:	72 08                	jb     f0100fc5 <page_init+0x8a>
f0100fbd:	81 f9 ff ff 09 00    	cmp    $0x9ffff,%ecx
f0100fc3:	77 40                	ja     f0101005 <page_init+0xca>
f0100fc5:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
                 pages[i].pp_ref = 0;
f0100fcc:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100fcf:	89 cf                	mov    %ecx,%edi
f0100fd1:	03 3e                	add    (%esi),%edi
f0100fd3:	89 fe                	mov    %edi,%esi
f0100fd5:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
		 pages[i].pp_link = page_free_list;
f0100fdb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100fde:	89 3e                	mov    %edi,(%esi)
		 page_free_list = &pages[i];
f0100fe0:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100fe3:	03 0e                	add    (%esi),%ecx
f0100fe5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0100fe8:	be 01 00 00 00       	mov    $0x1,%esi
	for (i = 0; i < npages; i++) {
f0100fed:	83 c0 01             	add    $0x1,%eax
f0100ff0:	39 02                	cmp    %eax,(%edx)
f0100ff2:	76 1f                	jbe    f0101013 <page_init+0xd8>
		if(i==0){
f0100ff4:	85 c0                	test   %eax,%eax
f0100ff6:	75 bb                	jne    f0100fb3 <page_init+0x78>
		  pages[i].pp_ref = 1;
f0100ff8:	8b 7d d8             	mov    -0x28(%ebp),%edi
f0100ffb:	8b 0f                	mov    (%edi),%ecx
f0100ffd:	66 c7 41 04 01 00    	movw   $0x1,0x4(%ecx)
f0101003:	eb e8                	jmp    f0100fed <page_init+0xb2>
		        pages[i].pp_ref = 1;
f0101005:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101008:	8b 0f                	mov    (%edi),%ecx
f010100a:	66 c7 44 c1 04 01 00 	movw   $0x1,0x4(%ecx,%eax,8)
f0101011:	eb da                	jmp    f0100fed <page_init+0xb2>
f0101013:	89 f0                	mov    %esi,%eax
f0101015:	84 c0                	test   %al,%al
f0101017:	75 08                	jne    f0101021 <page_init+0xe6>
}
f0101019:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010101c:	5b                   	pop    %ebx
f010101d:	5e                   	pop    %esi
f010101e:	5f                   	pop    %edi
f010101f:	5d                   	pop    %ebp
f0101020:	c3                   	ret    
f0101021:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101024:	89 83 1c 23 00 00    	mov    %eax,0x231c(%ebx)
f010102a:	eb ed                	jmp    f0101019 <page_init+0xde>

f010102c <page_alloc>:
{
f010102c:	55                   	push   %ebp
f010102d:	89 e5                	mov    %esp,%ebp
f010102f:	56                   	push   %esi
f0101030:	53                   	push   %ebx
f0101031:	e8 70 f1 ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f0101036:	81 c3 ea 9f 08 00    	add    $0x89fea,%ebx
	if(page_free_list ==NULL)
f010103c:	8b b3 1c 23 00 00    	mov    0x231c(%ebx),%esi
f0101042:	85 f6                	test   %esi,%esi
f0101044:	74 14                	je     f010105a <page_alloc+0x2e>
	page_free_list = alloc_space->pp_link;
f0101046:	8b 06                	mov    (%esi),%eax
f0101048:	89 83 1c 23 00 00    	mov    %eax,0x231c(%ebx)
	alloc_space->pp_link = NULL;
f010104e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if(alloc_flags && ALLOC_ZERO){
f0101054:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0101058:	75 09                	jne    f0101063 <page_alloc+0x37>
}
f010105a:	89 f0                	mov    %esi,%eax
f010105c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010105f:	5b                   	pop    %ebx
f0101060:	5e                   	pop    %esi
f0101061:	5d                   	pop    %ebp
f0101062:	c3                   	ret    
	return (pp - pages) << PGSHIFT;
f0101063:	c7 c0 10 e0 18 f0    	mov    $0xf018e010,%eax
f0101069:	89 f2                	mov    %esi,%edx
f010106b:	2b 10                	sub    (%eax),%edx
f010106d:	89 d0                	mov    %edx,%eax
f010106f:	c1 f8 03             	sar    $0x3,%eax
f0101072:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101075:	89 c1                	mov    %eax,%ecx
f0101077:	c1 e9 0c             	shr    $0xc,%ecx
f010107a:	c7 c2 08 e0 18 f0    	mov    $0xf018e008,%edx
f0101080:	3b 0a                	cmp    (%edx),%ecx
f0101082:	73 1a                	jae    f010109e <page_alloc+0x72>
	   memset(page2kva(alloc_space),0,PGSIZE);
f0101084:	83 ec 04             	sub    $0x4,%esp
f0101087:	68 00 10 00 00       	push   $0x1000
f010108c:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f010108e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101093:	50                   	push   %eax
f0101094:	e8 ee 36 00 00       	call   f0104787 <memset>
f0101099:	83 c4 10             	add    $0x10,%esp
f010109c:	eb bc                	jmp    f010105a <page_alloc+0x2e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010109e:	50                   	push   %eax
f010109f:	8d 83 00 a1 f7 ff    	lea    -0x85f00(%ebx),%eax
f01010a5:	50                   	push   %eax
f01010a6:	6a 56                	push   $0x56
f01010a8:	8d 83 d9 a8 f7 ff    	lea    -0x85727(%ebx),%eax
f01010ae:	50                   	push   %eax
f01010af:	e8 3c f0 ff ff       	call   f01000f0 <_panic>

f01010b4 <page_free>:
{
f01010b4:	55                   	push   %ebp
f01010b5:	89 e5                	mov    %esp,%ebp
f01010b7:	53                   	push   %ebx
f01010b8:	83 ec 04             	sub    $0x4,%esp
f01010bb:	e8 e6 f0 ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f01010c0:	81 c3 60 9f 08 00    	add    $0x89f60,%ebx
f01010c6:	8b 45 08             	mov    0x8(%ebp),%eax
	if(pp->pp_ref==0 && pp->pp_link == NULL){
f01010c9:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01010ce:	75 18                	jne    f01010e8 <page_free+0x34>
f01010d0:	83 38 00             	cmpl   $0x0,(%eax)
f01010d3:	75 13                	jne    f01010e8 <page_free+0x34>
	  pp->pp_link = page_free_list;
f01010d5:	8b 8b 1c 23 00 00    	mov    0x231c(%ebx),%ecx
f01010db:	89 08                	mov    %ecx,(%eax)
	  page_free_list = pp;
f01010dd:	89 83 1c 23 00 00    	mov    %eax,0x231c(%ebx)
}
f01010e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01010e6:	c9                   	leave  
f01010e7:	c3                   	ret    
	 panic("This page is being used!\n");
f01010e8:	83 ec 04             	sub    $0x4,%esp
f01010eb:	8d 83 83 a9 f7 ff    	lea    -0x8567d(%ebx),%eax
f01010f1:	50                   	push   %eax
f01010f2:	68 4e 01 00 00       	push   $0x14e
f01010f7:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f01010fd:	50                   	push   %eax
f01010fe:	e8 ed ef ff ff       	call   f01000f0 <_panic>

f0101103 <page_decref>:
{
f0101103:	55                   	push   %ebp
f0101104:	89 e5                	mov    %esp,%ebp
f0101106:	83 ec 08             	sub    $0x8,%esp
f0101109:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f010110c:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0101110:	83 e8 01             	sub    $0x1,%eax
f0101113:	66 89 42 04          	mov    %ax,0x4(%edx)
f0101117:	66 85 c0             	test   %ax,%ax
f010111a:	74 02                	je     f010111e <page_decref+0x1b>
}
f010111c:	c9                   	leave  
f010111d:	c3                   	ret    
		page_free(pp);
f010111e:	83 ec 0c             	sub    $0xc,%esp
f0101121:	52                   	push   %edx
f0101122:	e8 8d ff ff ff       	call   f01010b4 <page_free>
f0101127:	83 c4 10             	add    $0x10,%esp
}
f010112a:	eb f0                	jmp    f010111c <page_decref+0x19>

f010112c <pgdir_walk>:
{
f010112c:	55                   	push   %ebp
f010112d:	89 e5                	mov    %esp,%ebp
f010112f:	57                   	push   %edi
f0101130:	56                   	push   %esi
f0101131:	53                   	push   %ebx
f0101132:	83 ec 1c             	sub    $0x1c,%esp
f0101135:	e8 6c f0 ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f010113a:	81 c3 e6 9e 08 00    	add    $0x89ee6,%ebx
f0101140:	8b 75 0c             	mov    0xc(%ebp),%esi
        uint32_t ptx = PTX(va);              
f0101143:	89 f0                	mov    %esi,%eax
f0101145:	c1 e8 0c             	shr    $0xc,%eax
f0101148:	25 ff 03 00 00       	and    $0x3ff,%eax
f010114d:	89 c7                	mov    %eax,%edi
	 uint32_t pdx = PDX(va);               
f010114f:	c1 ee 16             	shr    $0x16,%esi
        pte_t *page_dir_entry = pgdir + pdx;  
f0101152:	c1 e6 02             	shl    $0x2,%esi
f0101155:	03 75 08             	add    0x8(%ebp),%esi
        if(*page_dir_entry& PTE_P){
f0101158:	8b 16                	mov    (%esi),%edx
f010115a:	f6 c2 01             	test   $0x1,%dl
f010115d:	74 3f                	je     f010119e <pgdir_walk+0x72>
          page_table_entry = KADDR(PTE_ADDR(*page_dir_entry));
f010115f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0101165:	89 d0                	mov    %edx,%eax
f0101167:	c1 e8 0c             	shr    $0xc,%eax
f010116a:	c7 c1 08 e0 18 f0    	mov    $0xf018e008,%ecx
f0101170:	39 01                	cmp    %eax,(%ecx)
f0101172:	76 11                	jbe    f0101185 <pgdir_walk+0x59>
	return (void *)(pa + KERNBASE);
f0101174:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
        return &page_table_entry[ptx];
f010117a:	8d 04 ba             	lea    (%edx,%edi,4),%eax
}
f010117d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101180:	5b                   	pop    %ebx
f0101181:	5e                   	pop    %esi
f0101182:	5f                   	pop    %edi
f0101183:	5d                   	pop    %ebp
f0101184:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101185:	52                   	push   %edx
f0101186:	8d 83 00 a1 f7 ff    	lea    -0x85f00(%ebx),%eax
f010118c:	50                   	push   %eax
f010118d:	68 7e 01 00 00       	push   $0x17e
f0101192:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0101198:	50                   	push   %eax
f0101199:	e8 52 ef ff ff       	call   f01000f0 <_panic>
         if(!create) return NULL;
f010119e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01011a2:	0f 84 8e 00 00 00    	je     f0101236 <pgdir_walk+0x10a>
         pp = page_alloc(1);
f01011a8:	83 ec 0c             	sub    $0xc,%esp
f01011ab:	6a 01                	push   $0x1
f01011ad:	e8 7a fe ff ff       	call   f010102c <page_alloc>
f01011b2:	89 45 e0             	mov    %eax,-0x20(%ebp)
         if(!pp) return NULL;
f01011b5:	83 c4 10             	add    $0x10,%esp
f01011b8:	85 c0                	test   %eax,%eax
f01011ba:	0f 84 80 00 00 00    	je     f0101240 <pgdir_walk+0x114>
	return (pp - pages) << PGSHIFT;
f01011c0:	c7 c2 10 e0 18 f0    	mov    $0xf018e010,%edx
f01011c6:	89 c1                	mov    %eax,%ecx
f01011c8:	2b 0a                	sub    (%edx),%ecx
f01011ca:	c1 f9 03             	sar    $0x3,%ecx
f01011cd:	c1 e1 0c             	shl    $0xc,%ecx
	if (PGNUM(pa) >= npages)
f01011d0:	89 ca                	mov    %ecx,%edx
f01011d2:	c1 ea 0c             	shr    $0xc,%edx
f01011d5:	89 d0                	mov    %edx,%eax
f01011d7:	c7 c2 08 e0 18 f0    	mov    $0xf018e008,%edx
f01011dd:	3b 02                	cmp    (%edx),%eax
f01011df:	73 26                	jae    f0101207 <pgdir_walk+0xdb>
	return (void *)(pa + KERNBASE);
f01011e1:	8d 91 00 00 00 f0    	lea    -0x10000000(%ecx),%edx
f01011e7:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01011ea:	89 55 e4             	mov    %edx,-0x1c(%ebp)
         pp->pp_ref++;
f01011ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01011f0:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	if ((uint32_t)kva < KERNBASE)
f01011f5:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01011fb:	76 20                	jbe    f010121d <pgdir_walk+0xf1>
         *page_dir_entry = PADDR(page_table_entry)|PTE_P|PTE_W|PTE_U;
f01011fd:	83 c9 07             	or     $0x7,%ecx
f0101200:	89 0e                	mov    %ecx,(%esi)
f0101202:	e9 73 ff ff ff       	jmp    f010117a <pgdir_walk+0x4e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101207:	51                   	push   %ecx
f0101208:	8d 83 00 a1 f7 ff    	lea    -0x85f00(%ebx),%eax
f010120e:	50                   	push   %eax
f010120f:	6a 56                	push   $0x56
f0101211:	8d 83 d9 a8 f7 ff    	lea    -0x85727(%ebx),%eax
f0101217:	50                   	push   %eax
f0101218:	e8 d3 ee ff ff       	call   f01000f0 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010121d:	52                   	push   %edx
f010121e:	8d 83 0c a2 f7 ff    	lea    -0x85df4(%ebx),%eax
f0101224:	50                   	push   %eax
f0101225:	68 86 01 00 00       	push   $0x186
f010122a:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0101230:	50                   	push   %eax
f0101231:	e8 ba ee ff ff       	call   f01000f0 <_panic>
         if(!create) return NULL;
f0101236:	b8 00 00 00 00       	mov    $0x0,%eax
f010123b:	e9 3d ff ff ff       	jmp    f010117d <pgdir_walk+0x51>
         if(!pp) return NULL;
f0101240:	b8 00 00 00 00       	mov    $0x0,%eax
f0101245:	e9 33 ff ff ff       	jmp    f010117d <pgdir_walk+0x51>

f010124a <boot_map_region>:
{
f010124a:	55                   	push   %ebp
f010124b:	89 e5                	mov    %esp,%ebp
f010124d:	57                   	push   %edi
f010124e:	56                   	push   %esi
f010124f:	53                   	push   %ebx
f0101250:	83 ec 1c             	sub    $0x1c,%esp
f0101253:	e8 4f 1f 00 00       	call   f01031a7 <__x86.get_pc_thunk.di>
f0101258:	81 c7 c8 9d 08 00    	add    $0x89dc8,%edi
f010125e:	89 7d d8             	mov    %edi,-0x28(%ebp)
f0101261:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101264:	8b 45 08             	mov    0x8(%ebp),%eax
	size_t numpage = size/PGSIZE;
f0101267:	89 cb                	mov    %ecx,%ebx
f0101269:	c1 eb 0c             	shr    $0xc,%ebx
	if(size % PGSIZE !=0) numpage++;
f010126c:	81 e1 ff 0f 00 00    	and    $0xfff,%ecx
f0101272:	83 f9 01             	cmp    $0x1,%ecx
f0101275:	83 db ff             	sbb    $0xffffffff,%ebx
f0101278:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	for(i=0;i<numpage;i++){
f010127b:	89 c3                	mov    %eax,%ebx
f010127d:	be 00 00 00 00       	mov    $0x0,%esi
	  pte_t *pte = pgdir_walk(pgdir,(void *)va,1);
f0101282:	89 d7                	mov    %edx,%edi
f0101284:	29 c7                	sub    %eax,%edi
	  *pte = pa|PTE_P|perm;
f0101286:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101289:	83 c8 01             	or     $0x1,%eax
f010128c:	89 45 dc             	mov    %eax,-0x24(%ebp)
	for(i=0;i<numpage;i++){
f010128f:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
f0101292:	74 48                	je     f01012dc <boot_map_region+0x92>
	  pte_t *pte = pgdir_walk(pgdir,(void *)va,1);
f0101294:	83 ec 04             	sub    $0x4,%esp
f0101297:	6a 01                	push   $0x1
f0101299:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f010129c:	50                   	push   %eax
f010129d:	ff 75 e0             	pushl  -0x20(%ebp)
f01012a0:	e8 87 fe ff ff       	call   f010112c <pgdir_walk>
	  if(!pte) panic("boot_map_region:out ouf memory!\n");
f01012a5:	83 c4 10             	add    $0x10,%esp
f01012a8:	85 c0                	test   %eax,%eax
f01012aa:	74 12                	je     f01012be <boot_map_region+0x74>
	  *pte = pa|PTE_P|perm;
f01012ac:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01012af:	09 da                	or     %ebx,%edx
f01012b1:	89 10                	mov    %edx,(%eax)
	  pa+=PGSIZE;
f01012b3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for(i=0;i<numpage;i++){
f01012b9:	83 c6 01             	add    $0x1,%esi
f01012bc:	eb d1                	jmp    f010128f <boot_map_region+0x45>
	  if(!pte) panic("boot_map_region:out ouf memory!\n");
f01012be:	83 ec 04             	sub    $0x4,%esp
f01012c1:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f01012c4:	8d 83 30 a2 f7 ff    	lea    -0x85dd0(%ebx),%eax
f01012ca:	50                   	push   %eax
f01012cb:	68 a0 01 00 00       	push   $0x1a0
f01012d0:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f01012d6:	50                   	push   %eax
f01012d7:	e8 14 ee ff ff       	call   f01000f0 <_panic>
}
f01012dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012df:	5b                   	pop    %ebx
f01012e0:	5e                   	pop    %esi
f01012e1:	5f                   	pop    %edi
f01012e2:	5d                   	pop    %ebp
f01012e3:	c3                   	ret    

f01012e4 <page_lookup>:
{
f01012e4:	55                   	push   %ebp
f01012e5:	89 e5                	mov    %esp,%ebp
f01012e7:	56                   	push   %esi
f01012e8:	53                   	push   %ebx
f01012e9:	e8 b8 ee ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f01012ee:	81 c3 32 9d 08 00    	add    $0x89d32,%ebx
f01012f4:	8b 75 10             	mov    0x10(%ebp),%esi
       	pte_t *pt = pgdir_walk(pgdir,va,0);
f01012f7:	83 ec 04             	sub    $0x4,%esp
f01012fa:	6a 00                	push   $0x0
f01012fc:	ff 75 0c             	pushl  0xc(%ebp)
f01012ff:	ff 75 08             	pushl  0x8(%ebp)
f0101302:	e8 25 fe ff ff       	call   f010112c <pgdir_walk>
	if(!pt) return NULL;
f0101307:	83 c4 10             	add    $0x10,%esp
f010130a:	85 c0                	test   %eax,%eax
f010130c:	74 3f                	je     f010134d <page_lookup+0x69>
	if(pte_store)
f010130e:	85 f6                	test   %esi,%esi
f0101310:	74 02                	je     f0101314 <page_lookup+0x30>
		*pte_store = pt;
f0101312:	89 06                	mov    %eax,(%esi)
f0101314:	8b 00                	mov    (%eax),%eax
f0101316:	c1 e8 0c             	shr    $0xc,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101319:	c7 c2 08 e0 18 f0    	mov    $0xf018e008,%edx
f010131f:	39 02                	cmp    %eax,(%edx)
f0101321:	76 12                	jbe    f0101335 <page_lookup+0x51>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f0101323:	c7 c2 10 e0 18 f0    	mov    $0xf018e010,%edx
f0101329:	8b 12                	mov    (%edx),%edx
f010132b:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f010132e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101331:	5b                   	pop    %ebx
f0101332:	5e                   	pop    %esi
f0101333:	5d                   	pop    %ebp
f0101334:	c3                   	ret    
		panic("pa2page called with invalid pa");
f0101335:	83 ec 04             	sub    $0x4,%esp
f0101338:	8d 83 54 a2 f7 ff    	lea    -0x85dac(%ebx),%eax
f010133e:	50                   	push   %eax
f010133f:	6a 4f                	push   $0x4f
f0101341:	8d 83 d9 a8 f7 ff    	lea    -0x85727(%ebx),%eax
f0101347:	50                   	push   %eax
f0101348:	e8 a3 ed ff ff       	call   f01000f0 <_panic>
	if(!pt) return NULL;
f010134d:	b8 00 00 00 00       	mov    $0x0,%eax
f0101352:	eb da                	jmp    f010132e <page_lookup+0x4a>

f0101354 <page_remove>:
{
f0101354:	55                   	push   %ebp
f0101355:	89 e5                	mov    %esp,%ebp
f0101357:	53                   	push   %ebx
f0101358:	83 ec 18             	sub    $0x18,%esp
f010135b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct PageInfo* pageinfo = page_lookup(pgdir,va,&pt);
f010135e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101361:	50                   	push   %eax
f0101362:	53                   	push   %ebx
f0101363:	ff 75 08             	pushl  0x8(%ebp)
f0101366:	e8 79 ff ff ff       	call   f01012e4 <page_lookup>
        if(!pageinfo) return;
f010136b:	83 c4 10             	add    $0x10,%esp
f010136e:	85 c0                	test   %eax,%eax
f0101370:	75 05                	jne    f0101377 <page_remove+0x23>
}
f0101372:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101375:	c9                   	leave  
f0101376:	c3                   	ret    
	page_decref(pageinfo);
f0101377:	83 ec 0c             	sub    $0xc,%esp
f010137a:	50                   	push   %eax
f010137b:	e8 83 fd ff ff       	call   f0101103 <page_decref>
	*pt = 0;
f0101380:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101383:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101389:	0f 01 3b             	invlpg (%ebx)
f010138c:	83 c4 10             	add    $0x10,%esp
f010138f:	eb e1                	jmp    f0101372 <page_remove+0x1e>

f0101391 <page_insert>:
{
f0101391:	55                   	push   %ebp
f0101392:	89 e5                	mov    %esp,%ebp
f0101394:	57                   	push   %edi
f0101395:	56                   	push   %esi
f0101396:	53                   	push   %ebx
f0101397:	83 ec 10             	sub    $0x10,%esp
f010139a:	e8 08 1e 00 00       	call   f01031a7 <__x86.get_pc_thunk.di>
f010139f:	81 c7 81 9c 08 00    	add    $0x89c81,%edi
f01013a5:	8b 75 0c             	mov    0xc(%ebp),%esi
	pte_t *pt=pgdir_walk(pgdir,va,1);
f01013a8:	6a 01                	push   $0x1
f01013aa:	ff 75 10             	pushl  0x10(%ebp)
f01013ad:	ff 75 08             	pushl  0x8(%ebp)
f01013b0:	e8 77 fd ff ff       	call   f010112c <pgdir_walk>
	if(!pt) return -E_NO_MEM;
f01013b5:	83 c4 10             	add    $0x10,%esp
f01013b8:	85 c0                	test   %eax,%eax
f01013ba:	74 46                	je     f0101402 <page_insert+0x71>
f01013bc:	89 c3                	mov    %eax,%ebx
	pp->pp_ref++;
f01013be:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
	if(*pt & PTE_P){
f01013c3:	f6 00 01             	testb  $0x1,(%eax)
f01013c6:	75 27                	jne    f01013ef <page_insert+0x5e>
	return (pp - pages) << PGSHIFT;
f01013c8:	c7 c0 10 e0 18 f0    	mov    $0xf018e010,%eax
f01013ce:	2b 30                	sub    (%eax),%esi
f01013d0:	89 f0                	mov    %esi,%eax
f01013d2:	c1 f8 03             	sar    $0x3,%eax
f01013d5:	c1 e0 0c             	shl    $0xc,%eax
	*pt = page2pa(pp)|perm|PTE_P;
f01013d8:	8b 55 14             	mov    0x14(%ebp),%edx
f01013db:	83 ca 01             	or     $0x1,%edx
f01013de:	09 d0                	or     %edx,%eax
f01013e0:	89 03                	mov    %eax,(%ebx)
	return 0;
f01013e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01013e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01013ea:	5b                   	pop    %ebx
f01013eb:	5e                   	pop    %esi
f01013ec:	5f                   	pop    %edi
f01013ed:	5d                   	pop    %ebp
f01013ee:	c3                   	ret    
		page_remove(pgdir,va);
f01013ef:	83 ec 08             	sub    $0x8,%esp
f01013f2:	ff 75 10             	pushl  0x10(%ebp)
f01013f5:	ff 75 08             	pushl  0x8(%ebp)
f01013f8:	e8 57 ff ff ff       	call   f0101354 <page_remove>
f01013fd:	83 c4 10             	add    $0x10,%esp
f0101400:	eb c6                	jmp    f01013c8 <page_insert+0x37>
	if(!pt) return -E_NO_MEM;
f0101402:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0101407:	eb de                	jmp    f01013e7 <page_insert+0x56>

f0101409 <mem_init>:
{
f0101409:	55                   	push   %ebp
f010140a:	89 e5                	mov    %esp,%ebp
f010140c:	57                   	push   %edi
f010140d:	56                   	push   %esi
f010140e:	53                   	push   %ebx
f010140f:	83 ec 3c             	sub    $0x3c,%esp
f0101412:	e8 31 f3 ff ff       	call   f0100748 <__x86.get_pc_thunk.ax>
f0101417:	05 09 9c 08 00       	add    $0x89c09,%eax
f010141c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	basemem = nvram_read(NVRAM_BASELO);
f010141f:	b8 15 00 00 00       	mov    $0x15,%eax
f0101424:	e8 dc f6 ff ff       	call   f0100b05 <nvram_read>
f0101429:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f010142b:	b8 17 00 00 00       	mov    $0x17,%eax
f0101430:	e8 d0 f6 ff ff       	call   f0100b05 <nvram_read>
f0101435:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0101437:	b8 34 00 00 00       	mov    $0x34,%eax
f010143c:	e8 c4 f6 ff ff       	call   f0100b05 <nvram_read>
f0101441:	c1 e0 06             	shl    $0x6,%eax
	if (ext16mem)
f0101444:	85 c0                	test   %eax,%eax
f0101446:	0f 85 c2 00 00 00    	jne    f010150e <mem_init+0x105>
		totalmem = 1 * 1024 + extmem;
f010144c:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0101452:	85 f6                	test   %esi,%esi
f0101454:	0f 44 c3             	cmove  %ebx,%eax
	npages = totalmem / (PGSIZE / 1024);
f0101457:	89 c1                	mov    %eax,%ecx
f0101459:	c1 e9 02             	shr    $0x2,%ecx
f010145c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010145f:	c7 c2 08 e0 18 f0    	mov    $0xf018e008,%edx
f0101465:	89 0a                	mov    %ecx,(%edx)
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101467:	89 c2                	mov    %eax,%edx
f0101469:	29 da                	sub    %ebx,%edx
f010146b:	52                   	push   %edx
f010146c:	53                   	push   %ebx
f010146d:	50                   	push   %eax
f010146e:	8d 87 74 a2 f7 ff    	lea    -0x85d8c(%edi),%eax
f0101474:	50                   	push   %eax
f0101475:	89 fb                	mov    %edi,%ebx
f0101477:	e8 5a 22 00 00       	call   f01036d6 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010147c:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101481:	e8 2f f6 ff ff       	call   f0100ab5 <boot_alloc>
f0101486:	c7 c6 0c e0 18 f0    	mov    $0xf018e00c,%esi
f010148c:	89 06                	mov    %eax,(%esi)
	memset(kern_pgdir, 0, PGSIZE);
f010148e:	83 c4 0c             	add    $0xc,%esp
f0101491:	68 00 10 00 00       	push   $0x1000
f0101496:	6a 00                	push   $0x0
f0101498:	50                   	push   %eax
f0101499:	e8 e9 32 00 00       	call   f0104787 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010149e:	8b 06                	mov    (%esi),%eax
	if ((uint32_t)kva < KERNBASE)
f01014a0:	83 c4 10             	add    $0x10,%esp
f01014a3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01014a8:	76 6e                	jbe    f0101518 <mem_init+0x10f>
	return (physaddr_t)kva - KERNBASE;
f01014aa:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01014b0:	83 ca 05             	or     $0x5,%edx
f01014b3:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
        pages =(struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f01014b9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01014bc:	c7 c3 08 e0 18 f0    	mov    $0xf018e008,%ebx
f01014c2:	8b 03                	mov    (%ebx),%eax
f01014c4:	c1 e0 03             	shl    $0x3,%eax
f01014c7:	e8 e9 f5 ff ff       	call   f0100ab5 <boot_alloc>
f01014cc:	c7 c6 10 e0 18 f0    	mov    $0xf018e010,%esi
f01014d2:	89 06                	mov    %eax,(%esi)
        memset(pages,0, npages * sizeof(struct PageInfo));
f01014d4:	83 ec 04             	sub    $0x4,%esp
f01014d7:	8b 13                	mov    (%ebx),%edx
f01014d9:	c1 e2 03             	shl    $0x3,%edx
f01014dc:	52                   	push   %edx
f01014dd:	6a 00                	push   $0x0
f01014df:	50                   	push   %eax
f01014e0:	89 fb                	mov    %edi,%ebx
f01014e2:	e8 a0 32 00 00       	call   f0104787 <memset>
	page_init();
f01014e7:	e8 4f fa ff ff       	call   f0100f3b <page_init>
	check_page_free_list(1);
f01014ec:	b8 01 00 00 00       	mov    $0x1,%eax
f01014f1:	e8 c2 f6 ff ff       	call   f0100bb8 <check_page_free_list>
	if (!pages)
f01014f6:	83 c4 10             	add    $0x10,%esp
f01014f9:	83 3e 00             	cmpl   $0x0,(%esi)
f01014fc:	74 36                	je     f0101534 <mem_init+0x12b>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01014fe:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101501:	8b 80 1c 23 00 00    	mov    0x231c(%eax),%eax
f0101507:	be 00 00 00 00       	mov    $0x0,%esi
f010150c:	eb 49                	jmp    f0101557 <mem_init+0x14e>
		totalmem = 16 * 1024 + ext16mem;
f010150e:	05 00 40 00 00       	add    $0x4000,%eax
f0101513:	e9 3f ff ff ff       	jmp    f0101457 <mem_init+0x4e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101518:	50                   	push   %eax
f0101519:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010151c:	8d 83 0c a2 f7 ff    	lea    -0x85df4(%ebx),%eax
f0101522:	50                   	push   %eax
f0101523:	68 90 00 00 00       	push   $0x90
f0101528:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f010152e:	50                   	push   %eax
f010152f:	e8 bc eb ff ff       	call   f01000f0 <_panic>
		panic("'pages' is a null pointer!");
f0101534:	83 ec 04             	sub    $0x4,%esp
f0101537:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010153a:	8d 83 9d a9 f7 ff    	lea    -0x85663(%ebx),%eax
f0101540:	50                   	push   %eax
f0101541:	68 8d 02 00 00       	push   $0x28d
f0101546:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f010154c:	50                   	push   %eax
f010154d:	e8 9e eb ff ff       	call   f01000f0 <_panic>
		++nfree;
f0101552:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101555:	8b 00                	mov    (%eax),%eax
f0101557:	85 c0                	test   %eax,%eax
f0101559:	75 f7                	jne    f0101552 <mem_init+0x149>
	assert((pp0 = page_alloc(0)));
f010155b:	83 ec 0c             	sub    $0xc,%esp
f010155e:	6a 00                	push   $0x0
f0101560:	e8 c7 fa ff ff       	call   f010102c <page_alloc>
f0101565:	89 c3                	mov    %eax,%ebx
f0101567:	83 c4 10             	add    $0x10,%esp
f010156a:	85 c0                	test   %eax,%eax
f010156c:	0f 84 3b 02 00 00    	je     f01017ad <mem_init+0x3a4>
	assert((pp1 = page_alloc(0)));
f0101572:	83 ec 0c             	sub    $0xc,%esp
f0101575:	6a 00                	push   $0x0
f0101577:	e8 b0 fa ff ff       	call   f010102c <page_alloc>
f010157c:	89 c7                	mov    %eax,%edi
f010157e:	83 c4 10             	add    $0x10,%esp
f0101581:	85 c0                	test   %eax,%eax
f0101583:	0f 84 46 02 00 00    	je     f01017cf <mem_init+0x3c6>
	assert((pp2 = page_alloc(0)));
f0101589:	83 ec 0c             	sub    $0xc,%esp
f010158c:	6a 00                	push   $0x0
f010158e:	e8 99 fa ff ff       	call   f010102c <page_alloc>
f0101593:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101596:	83 c4 10             	add    $0x10,%esp
f0101599:	85 c0                	test   %eax,%eax
f010159b:	0f 84 50 02 00 00    	je     f01017f1 <mem_init+0x3e8>
	assert(pp1 && pp1 != pp0);
f01015a1:	39 fb                	cmp    %edi,%ebx
f01015a3:	0f 84 6a 02 00 00    	je     f0101813 <mem_init+0x40a>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01015a9:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01015ac:	39 c3                	cmp    %eax,%ebx
f01015ae:	0f 84 81 02 00 00    	je     f0101835 <mem_init+0x42c>
f01015b4:	39 c7                	cmp    %eax,%edi
f01015b6:	0f 84 79 02 00 00    	je     f0101835 <mem_init+0x42c>
	return (pp - pages) << PGSHIFT;
f01015bc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01015bf:	c7 c0 10 e0 18 f0    	mov    $0xf018e010,%eax
f01015c5:	8b 08                	mov    (%eax),%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01015c7:	c7 c0 08 e0 18 f0    	mov    $0xf018e008,%eax
f01015cd:	8b 10                	mov    (%eax),%edx
f01015cf:	c1 e2 0c             	shl    $0xc,%edx
f01015d2:	89 d8                	mov    %ebx,%eax
f01015d4:	29 c8                	sub    %ecx,%eax
f01015d6:	c1 f8 03             	sar    $0x3,%eax
f01015d9:	c1 e0 0c             	shl    $0xc,%eax
f01015dc:	39 d0                	cmp    %edx,%eax
f01015de:	0f 83 73 02 00 00    	jae    f0101857 <mem_init+0x44e>
f01015e4:	89 f8                	mov    %edi,%eax
f01015e6:	29 c8                	sub    %ecx,%eax
f01015e8:	c1 f8 03             	sar    $0x3,%eax
f01015eb:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f01015ee:	39 c2                	cmp    %eax,%edx
f01015f0:	0f 86 83 02 00 00    	jbe    f0101879 <mem_init+0x470>
f01015f6:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01015f9:	29 c8                	sub    %ecx,%eax
f01015fb:	c1 f8 03             	sar    $0x3,%eax
f01015fe:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f0101601:	39 c2                	cmp    %eax,%edx
f0101603:	0f 86 92 02 00 00    	jbe    f010189b <mem_init+0x492>
	fl = page_free_list;
f0101609:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010160c:	8b 88 1c 23 00 00    	mov    0x231c(%eax),%ecx
f0101612:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	page_free_list = 0;
f0101615:	c7 80 1c 23 00 00 00 	movl   $0x0,0x231c(%eax)
f010161c:	00 00 00 
	assert(!page_alloc(0));
f010161f:	83 ec 0c             	sub    $0xc,%esp
f0101622:	6a 00                	push   $0x0
f0101624:	e8 03 fa ff ff       	call   f010102c <page_alloc>
f0101629:	83 c4 10             	add    $0x10,%esp
f010162c:	85 c0                	test   %eax,%eax
f010162e:	0f 85 89 02 00 00    	jne    f01018bd <mem_init+0x4b4>
	page_free(pp0);
f0101634:	83 ec 0c             	sub    $0xc,%esp
f0101637:	53                   	push   %ebx
f0101638:	e8 77 fa ff ff       	call   f01010b4 <page_free>
	page_free(pp1);
f010163d:	89 3c 24             	mov    %edi,(%esp)
f0101640:	e8 6f fa ff ff       	call   f01010b4 <page_free>
	page_free(pp2);
f0101645:	83 c4 04             	add    $0x4,%esp
f0101648:	ff 75 d0             	pushl  -0x30(%ebp)
f010164b:	e8 64 fa ff ff       	call   f01010b4 <page_free>
	assert((pp0 = page_alloc(0)));
f0101650:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101657:	e8 d0 f9 ff ff       	call   f010102c <page_alloc>
f010165c:	89 c7                	mov    %eax,%edi
f010165e:	83 c4 10             	add    $0x10,%esp
f0101661:	85 c0                	test   %eax,%eax
f0101663:	0f 84 76 02 00 00    	je     f01018df <mem_init+0x4d6>
	assert((pp1 = page_alloc(0)));
f0101669:	83 ec 0c             	sub    $0xc,%esp
f010166c:	6a 00                	push   $0x0
f010166e:	e8 b9 f9 ff ff       	call   f010102c <page_alloc>
f0101673:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101676:	83 c4 10             	add    $0x10,%esp
f0101679:	85 c0                	test   %eax,%eax
f010167b:	0f 84 80 02 00 00    	je     f0101901 <mem_init+0x4f8>
	assert((pp2 = page_alloc(0)));
f0101681:	83 ec 0c             	sub    $0xc,%esp
f0101684:	6a 00                	push   $0x0
f0101686:	e8 a1 f9 ff ff       	call   f010102c <page_alloc>
f010168b:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010168e:	83 c4 10             	add    $0x10,%esp
f0101691:	85 c0                	test   %eax,%eax
f0101693:	0f 84 8a 02 00 00    	je     f0101923 <mem_init+0x51a>
	assert(pp1 && pp1 != pp0);
f0101699:	3b 7d d0             	cmp    -0x30(%ebp),%edi
f010169c:	0f 84 a3 02 00 00    	je     f0101945 <mem_init+0x53c>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01016a2:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01016a5:	39 c7                	cmp    %eax,%edi
f01016a7:	0f 84 ba 02 00 00    	je     f0101967 <mem_init+0x55e>
f01016ad:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f01016b0:	0f 84 b1 02 00 00    	je     f0101967 <mem_init+0x55e>
	assert(!page_alloc(0));
f01016b6:	83 ec 0c             	sub    $0xc,%esp
f01016b9:	6a 00                	push   $0x0
f01016bb:	e8 6c f9 ff ff       	call   f010102c <page_alloc>
f01016c0:	83 c4 10             	add    $0x10,%esp
f01016c3:	85 c0                	test   %eax,%eax
f01016c5:	0f 85 be 02 00 00    	jne    f0101989 <mem_init+0x580>
f01016cb:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01016ce:	c7 c0 10 e0 18 f0    	mov    $0xf018e010,%eax
f01016d4:	89 f9                	mov    %edi,%ecx
f01016d6:	2b 08                	sub    (%eax),%ecx
f01016d8:	89 c8                	mov    %ecx,%eax
f01016da:	c1 f8 03             	sar    $0x3,%eax
f01016dd:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01016e0:	89 c1                	mov    %eax,%ecx
f01016e2:	c1 e9 0c             	shr    $0xc,%ecx
f01016e5:	c7 c2 08 e0 18 f0    	mov    $0xf018e008,%edx
f01016eb:	3b 0a                	cmp    (%edx),%ecx
f01016ed:	0f 83 b8 02 00 00    	jae    f01019ab <mem_init+0x5a2>
	memset(page2kva(pp0), 1, PGSIZE);
f01016f3:	83 ec 04             	sub    $0x4,%esp
f01016f6:	68 00 10 00 00       	push   $0x1000
f01016fb:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f01016fd:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101702:	50                   	push   %eax
f0101703:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101706:	e8 7c 30 00 00       	call   f0104787 <memset>
	page_free(pp0);
f010170b:	89 3c 24             	mov    %edi,(%esp)
f010170e:	e8 a1 f9 ff ff       	call   f01010b4 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101713:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010171a:	e8 0d f9 ff ff       	call   f010102c <page_alloc>
f010171f:	83 c4 10             	add    $0x10,%esp
f0101722:	85 c0                	test   %eax,%eax
f0101724:	0f 84 97 02 00 00    	je     f01019c1 <mem_init+0x5b8>
	assert(pp && pp0 == pp);
f010172a:	39 c7                	cmp    %eax,%edi
f010172c:	0f 85 b1 02 00 00    	jne    f01019e3 <mem_init+0x5da>
	return (pp - pages) << PGSHIFT;
f0101732:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101735:	c7 c0 10 e0 18 f0    	mov    $0xf018e010,%eax
f010173b:	89 fa                	mov    %edi,%edx
f010173d:	2b 10                	sub    (%eax),%edx
f010173f:	c1 fa 03             	sar    $0x3,%edx
f0101742:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101745:	89 d1                	mov    %edx,%ecx
f0101747:	c1 e9 0c             	shr    $0xc,%ecx
f010174a:	c7 c0 08 e0 18 f0    	mov    $0xf018e008,%eax
f0101750:	3b 08                	cmp    (%eax),%ecx
f0101752:	0f 83 ad 02 00 00    	jae    f0101a05 <mem_init+0x5fc>
	return (void *)(pa + KERNBASE);
f0101758:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f010175e:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f0101764:	80 38 00             	cmpb   $0x0,(%eax)
f0101767:	0f 85 ae 02 00 00    	jne    f0101a1b <mem_init+0x612>
f010176d:	83 c0 01             	add    $0x1,%eax
	for (i = 0; i < PGSIZE; i++)
f0101770:	39 d0                	cmp    %edx,%eax
f0101772:	75 f0                	jne    f0101764 <mem_init+0x35b>
	page_free_list = fl;
f0101774:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101777:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010177a:	89 8b 1c 23 00 00    	mov    %ecx,0x231c(%ebx)
	page_free(pp0);
f0101780:	83 ec 0c             	sub    $0xc,%esp
f0101783:	57                   	push   %edi
f0101784:	e8 2b f9 ff ff       	call   f01010b4 <page_free>
	page_free(pp1);
f0101789:	83 c4 04             	add    $0x4,%esp
f010178c:	ff 75 d0             	pushl  -0x30(%ebp)
f010178f:	e8 20 f9 ff ff       	call   f01010b4 <page_free>
	page_free(pp2);
f0101794:	83 c4 04             	add    $0x4,%esp
f0101797:	ff 75 cc             	pushl  -0x34(%ebp)
f010179a:	e8 15 f9 ff ff       	call   f01010b4 <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010179f:	8b 83 1c 23 00 00    	mov    0x231c(%ebx),%eax
f01017a5:	83 c4 10             	add    $0x10,%esp
f01017a8:	e9 95 02 00 00       	jmp    f0101a42 <mem_init+0x639>
	assert((pp0 = page_alloc(0)));
f01017ad:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01017b0:	8d 83 b8 a9 f7 ff    	lea    -0x85648(%ebx),%eax
f01017b6:	50                   	push   %eax
f01017b7:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f01017bd:	50                   	push   %eax
f01017be:	68 95 02 00 00       	push   $0x295
f01017c3:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f01017c9:	50                   	push   %eax
f01017ca:	e8 21 e9 ff ff       	call   f01000f0 <_panic>
	assert((pp1 = page_alloc(0)));
f01017cf:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01017d2:	8d 83 ce a9 f7 ff    	lea    -0x85632(%ebx),%eax
f01017d8:	50                   	push   %eax
f01017d9:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f01017df:	50                   	push   %eax
f01017e0:	68 96 02 00 00       	push   $0x296
f01017e5:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f01017eb:	50                   	push   %eax
f01017ec:	e8 ff e8 ff ff       	call   f01000f0 <_panic>
	assert((pp2 = page_alloc(0)));
f01017f1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01017f4:	8d 83 e4 a9 f7 ff    	lea    -0x8561c(%ebx),%eax
f01017fa:	50                   	push   %eax
f01017fb:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0101801:	50                   	push   %eax
f0101802:	68 97 02 00 00       	push   $0x297
f0101807:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f010180d:	50                   	push   %eax
f010180e:	e8 dd e8 ff ff       	call   f01000f0 <_panic>
	assert(pp1 && pp1 != pp0);
f0101813:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101816:	8d 83 fa a9 f7 ff    	lea    -0x85606(%ebx),%eax
f010181c:	50                   	push   %eax
f010181d:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0101823:	50                   	push   %eax
f0101824:	68 9a 02 00 00       	push   $0x29a
f0101829:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f010182f:	50                   	push   %eax
f0101830:	e8 bb e8 ff ff       	call   f01000f0 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101835:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101838:	8d 83 b0 a2 f7 ff    	lea    -0x85d50(%ebx),%eax
f010183e:	50                   	push   %eax
f010183f:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0101845:	50                   	push   %eax
f0101846:	68 9b 02 00 00       	push   $0x29b
f010184b:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0101851:	50                   	push   %eax
f0101852:	e8 99 e8 ff ff       	call   f01000f0 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f0101857:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010185a:	8d 83 0c aa f7 ff    	lea    -0x855f4(%ebx),%eax
f0101860:	50                   	push   %eax
f0101861:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0101867:	50                   	push   %eax
f0101868:	68 9c 02 00 00       	push   $0x29c
f010186d:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0101873:	50                   	push   %eax
f0101874:	e8 77 e8 ff ff       	call   f01000f0 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101879:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010187c:	8d 83 29 aa f7 ff    	lea    -0x855d7(%ebx),%eax
f0101882:	50                   	push   %eax
f0101883:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0101889:	50                   	push   %eax
f010188a:	68 9d 02 00 00       	push   $0x29d
f010188f:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0101895:	50                   	push   %eax
f0101896:	e8 55 e8 ff ff       	call   f01000f0 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f010189b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010189e:	8d 83 46 aa f7 ff    	lea    -0x855ba(%ebx),%eax
f01018a4:	50                   	push   %eax
f01018a5:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f01018ab:	50                   	push   %eax
f01018ac:	68 9e 02 00 00       	push   $0x29e
f01018b1:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f01018b7:	50                   	push   %eax
f01018b8:	e8 33 e8 ff ff       	call   f01000f0 <_panic>
	assert(!page_alloc(0));
f01018bd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01018c0:	8d 83 63 aa f7 ff    	lea    -0x8559d(%ebx),%eax
f01018c6:	50                   	push   %eax
f01018c7:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f01018cd:	50                   	push   %eax
f01018ce:	68 a5 02 00 00       	push   $0x2a5
f01018d3:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f01018d9:	50                   	push   %eax
f01018da:	e8 11 e8 ff ff       	call   f01000f0 <_panic>
	assert((pp0 = page_alloc(0)));
f01018df:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01018e2:	8d 83 b8 a9 f7 ff    	lea    -0x85648(%ebx),%eax
f01018e8:	50                   	push   %eax
f01018e9:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f01018ef:	50                   	push   %eax
f01018f0:	68 ac 02 00 00       	push   $0x2ac
f01018f5:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f01018fb:	50                   	push   %eax
f01018fc:	e8 ef e7 ff ff       	call   f01000f0 <_panic>
	assert((pp1 = page_alloc(0)));
f0101901:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101904:	8d 83 ce a9 f7 ff    	lea    -0x85632(%ebx),%eax
f010190a:	50                   	push   %eax
f010190b:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0101911:	50                   	push   %eax
f0101912:	68 ad 02 00 00       	push   $0x2ad
f0101917:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f010191d:	50                   	push   %eax
f010191e:	e8 cd e7 ff ff       	call   f01000f0 <_panic>
	assert((pp2 = page_alloc(0)));
f0101923:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101926:	8d 83 e4 a9 f7 ff    	lea    -0x8561c(%ebx),%eax
f010192c:	50                   	push   %eax
f010192d:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0101933:	50                   	push   %eax
f0101934:	68 ae 02 00 00       	push   $0x2ae
f0101939:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f010193f:	50                   	push   %eax
f0101940:	e8 ab e7 ff ff       	call   f01000f0 <_panic>
	assert(pp1 && pp1 != pp0);
f0101945:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101948:	8d 83 fa a9 f7 ff    	lea    -0x85606(%ebx),%eax
f010194e:	50                   	push   %eax
f010194f:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0101955:	50                   	push   %eax
f0101956:	68 b0 02 00 00       	push   $0x2b0
f010195b:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0101961:	50                   	push   %eax
f0101962:	e8 89 e7 ff ff       	call   f01000f0 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101967:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010196a:	8d 83 b0 a2 f7 ff    	lea    -0x85d50(%ebx),%eax
f0101970:	50                   	push   %eax
f0101971:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0101977:	50                   	push   %eax
f0101978:	68 b1 02 00 00       	push   $0x2b1
f010197d:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0101983:	50                   	push   %eax
f0101984:	e8 67 e7 ff ff       	call   f01000f0 <_panic>
	assert(!page_alloc(0));
f0101989:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010198c:	8d 83 63 aa f7 ff    	lea    -0x8559d(%ebx),%eax
f0101992:	50                   	push   %eax
f0101993:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0101999:	50                   	push   %eax
f010199a:	68 b2 02 00 00       	push   $0x2b2
f010199f:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f01019a5:	50                   	push   %eax
f01019a6:	e8 45 e7 ff ff       	call   f01000f0 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01019ab:	50                   	push   %eax
f01019ac:	8d 83 00 a1 f7 ff    	lea    -0x85f00(%ebx),%eax
f01019b2:	50                   	push   %eax
f01019b3:	6a 56                	push   $0x56
f01019b5:	8d 83 d9 a8 f7 ff    	lea    -0x85727(%ebx),%eax
f01019bb:	50                   	push   %eax
f01019bc:	e8 2f e7 ff ff       	call   f01000f0 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01019c1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01019c4:	8d 83 72 aa f7 ff    	lea    -0x8558e(%ebx),%eax
f01019ca:	50                   	push   %eax
f01019cb:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f01019d1:	50                   	push   %eax
f01019d2:	68 b7 02 00 00       	push   $0x2b7
f01019d7:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f01019dd:	50                   	push   %eax
f01019de:	e8 0d e7 ff ff       	call   f01000f0 <_panic>
	assert(pp && pp0 == pp);
f01019e3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01019e6:	8d 83 90 aa f7 ff    	lea    -0x85570(%ebx),%eax
f01019ec:	50                   	push   %eax
f01019ed:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f01019f3:	50                   	push   %eax
f01019f4:	68 b8 02 00 00       	push   $0x2b8
f01019f9:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f01019ff:	50                   	push   %eax
f0101a00:	e8 eb e6 ff ff       	call   f01000f0 <_panic>
f0101a05:	52                   	push   %edx
f0101a06:	8d 83 00 a1 f7 ff    	lea    -0x85f00(%ebx),%eax
f0101a0c:	50                   	push   %eax
f0101a0d:	6a 56                	push   $0x56
f0101a0f:	8d 83 d9 a8 f7 ff    	lea    -0x85727(%ebx),%eax
f0101a15:	50                   	push   %eax
f0101a16:	e8 d5 e6 ff ff       	call   f01000f0 <_panic>
		assert(c[i] == 0);
f0101a1b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101a1e:	8d 83 a0 aa f7 ff    	lea    -0x85560(%ebx),%eax
f0101a24:	50                   	push   %eax
f0101a25:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0101a2b:	50                   	push   %eax
f0101a2c:	68 bb 02 00 00       	push   $0x2bb
f0101a31:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0101a37:	50                   	push   %eax
f0101a38:	e8 b3 e6 ff ff       	call   f01000f0 <_panic>
		--nfree;
f0101a3d:	83 ee 01             	sub    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101a40:	8b 00                	mov    (%eax),%eax
f0101a42:	85 c0                	test   %eax,%eax
f0101a44:	75 f7                	jne    f0101a3d <mem_init+0x634>
	assert(nfree == 0);
f0101a46:	85 f6                	test   %esi,%esi
f0101a48:	0f 85 55 08 00 00    	jne    f01022a3 <mem_init+0xe9a>
	cprintf("check_page_alloc() succeeded!\n");
f0101a4e:	83 ec 0c             	sub    $0xc,%esp
f0101a51:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101a54:	8d 83 d0 a2 f7 ff    	lea    -0x85d30(%ebx),%eax
f0101a5a:	50                   	push   %eax
f0101a5b:	e8 76 1c 00 00       	call   f01036d6 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101a60:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a67:	e8 c0 f5 ff ff       	call   f010102c <page_alloc>
f0101a6c:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101a6f:	83 c4 10             	add    $0x10,%esp
f0101a72:	85 c0                	test   %eax,%eax
f0101a74:	0f 84 4b 08 00 00    	je     f01022c5 <mem_init+0xebc>
	assert((pp1 = page_alloc(0)));
f0101a7a:	83 ec 0c             	sub    $0xc,%esp
f0101a7d:	6a 00                	push   $0x0
f0101a7f:	e8 a8 f5 ff ff       	call   f010102c <page_alloc>
f0101a84:	89 c7                	mov    %eax,%edi
f0101a86:	83 c4 10             	add    $0x10,%esp
f0101a89:	85 c0                	test   %eax,%eax
f0101a8b:	0f 84 56 08 00 00    	je     f01022e7 <mem_init+0xede>
	assert((pp2 = page_alloc(0)));
f0101a91:	83 ec 0c             	sub    $0xc,%esp
f0101a94:	6a 00                	push   $0x0
f0101a96:	e8 91 f5 ff ff       	call   f010102c <page_alloc>
f0101a9b:	89 c6                	mov    %eax,%esi
f0101a9d:	83 c4 10             	add    $0x10,%esp
f0101aa0:	85 c0                	test   %eax,%eax
f0101aa2:	0f 84 61 08 00 00    	je     f0102309 <mem_init+0xf00>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101aa8:	39 7d d0             	cmp    %edi,-0x30(%ebp)
f0101aab:	0f 84 7a 08 00 00    	je     f010232b <mem_init+0xf22>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101ab1:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101ab4:	0f 84 93 08 00 00    	je     f010234d <mem_init+0xf44>
f0101aba:	39 c7                	cmp    %eax,%edi
f0101abc:	0f 84 8b 08 00 00    	je     f010234d <mem_init+0xf44>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101ac2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ac5:	8b 88 1c 23 00 00    	mov    0x231c(%eax),%ecx
f0101acb:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	page_free_list = 0;
f0101ace:	c7 80 1c 23 00 00 00 	movl   $0x0,0x231c(%eax)
f0101ad5:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101ad8:	83 ec 0c             	sub    $0xc,%esp
f0101adb:	6a 00                	push   $0x0
f0101add:	e8 4a f5 ff ff       	call   f010102c <page_alloc>
f0101ae2:	83 c4 10             	add    $0x10,%esp
f0101ae5:	85 c0                	test   %eax,%eax
f0101ae7:	0f 85 82 08 00 00    	jne    f010236f <mem_init+0xf66>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101aed:	83 ec 04             	sub    $0x4,%esp
f0101af0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101af3:	50                   	push   %eax
f0101af4:	6a 00                	push   $0x0
f0101af6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101af9:	c7 c0 0c e0 18 f0    	mov    $0xf018e00c,%eax
f0101aff:	ff 30                	pushl  (%eax)
f0101b01:	e8 de f7 ff ff       	call   f01012e4 <page_lookup>
f0101b06:	83 c4 10             	add    $0x10,%esp
f0101b09:	85 c0                	test   %eax,%eax
f0101b0b:	0f 85 80 08 00 00    	jne    f0102391 <mem_init+0xf88>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101b11:	6a 02                	push   $0x2
f0101b13:	6a 00                	push   $0x0
f0101b15:	57                   	push   %edi
f0101b16:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b19:	c7 c0 0c e0 18 f0    	mov    $0xf018e00c,%eax
f0101b1f:	ff 30                	pushl  (%eax)
f0101b21:	e8 6b f8 ff ff       	call   f0101391 <page_insert>
f0101b26:	83 c4 10             	add    $0x10,%esp
f0101b29:	85 c0                	test   %eax,%eax
f0101b2b:	0f 89 82 08 00 00    	jns    f01023b3 <mem_init+0xfaa>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101b31:	83 ec 0c             	sub    $0xc,%esp
f0101b34:	ff 75 d0             	pushl  -0x30(%ebp)
f0101b37:	e8 78 f5 ff ff       	call   f01010b4 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101b3c:	6a 02                	push   $0x2
f0101b3e:	6a 00                	push   $0x0
f0101b40:	57                   	push   %edi
f0101b41:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b44:	c7 c0 0c e0 18 f0    	mov    $0xf018e00c,%eax
f0101b4a:	ff 30                	pushl  (%eax)
f0101b4c:	e8 40 f8 ff ff       	call   f0101391 <page_insert>
f0101b51:	83 c4 20             	add    $0x20,%esp
f0101b54:	85 c0                	test   %eax,%eax
f0101b56:	0f 85 79 08 00 00    	jne    f01023d5 <mem_init+0xfcc>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101b5c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101b5f:	c7 c0 0c e0 18 f0    	mov    $0xf018e00c,%eax
f0101b65:	8b 18                	mov    (%eax),%ebx
	return (pp - pages) << PGSHIFT;
f0101b67:	c7 c0 10 e0 18 f0    	mov    $0xf018e010,%eax
f0101b6d:	8b 08                	mov    (%eax),%ecx
f0101b6f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0101b72:	8b 13                	mov    (%ebx),%edx
f0101b74:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101b7a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101b7d:	29 c8                	sub    %ecx,%eax
f0101b7f:	c1 f8 03             	sar    $0x3,%eax
f0101b82:	c1 e0 0c             	shl    $0xc,%eax
f0101b85:	39 c2                	cmp    %eax,%edx
f0101b87:	0f 85 6a 08 00 00    	jne    f01023f7 <mem_init+0xfee>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101b8d:	ba 00 00 00 00       	mov    $0x0,%edx
f0101b92:	89 d8                	mov    %ebx,%eax
f0101b94:	e8 a2 ef ff ff       	call   f0100b3b <check_va2pa>
f0101b99:	89 fa                	mov    %edi,%edx
f0101b9b:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101b9e:	c1 fa 03             	sar    $0x3,%edx
f0101ba1:	c1 e2 0c             	shl    $0xc,%edx
f0101ba4:	39 d0                	cmp    %edx,%eax
f0101ba6:	0f 85 6d 08 00 00    	jne    f0102419 <mem_init+0x1010>
	assert(pp1->pp_ref == 1);
f0101bac:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101bb1:	0f 85 84 08 00 00    	jne    f010243b <mem_init+0x1032>
	assert(pp0->pp_ref == 1);
f0101bb7:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101bba:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101bbf:	0f 85 98 08 00 00    	jne    f010245d <mem_init+0x1054>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101bc5:	6a 02                	push   $0x2
f0101bc7:	68 00 10 00 00       	push   $0x1000
f0101bcc:	56                   	push   %esi
f0101bcd:	53                   	push   %ebx
f0101bce:	e8 be f7 ff ff       	call   f0101391 <page_insert>
f0101bd3:	83 c4 10             	add    $0x10,%esp
f0101bd6:	85 c0                	test   %eax,%eax
f0101bd8:	0f 85 a1 08 00 00    	jne    f010247f <mem_init+0x1076>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101bde:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101be3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101be6:	c7 c0 0c e0 18 f0    	mov    $0xf018e00c,%eax
f0101bec:	8b 00                	mov    (%eax),%eax
f0101bee:	e8 48 ef ff ff       	call   f0100b3b <check_va2pa>
f0101bf3:	c7 c2 10 e0 18 f0    	mov    $0xf018e010,%edx
f0101bf9:	89 f1                	mov    %esi,%ecx
f0101bfb:	2b 0a                	sub    (%edx),%ecx
f0101bfd:	89 ca                	mov    %ecx,%edx
f0101bff:	c1 fa 03             	sar    $0x3,%edx
f0101c02:	c1 e2 0c             	shl    $0xc,%edx
f0101c05:	39 d0                	cmp    %edx,%eax
f0101c07:	0f 85 94 08 00 00    	jne    f01024a1 <mem_init+0x1098>
	assert(pp2->pp_ref == 1);
f0101c0d:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101c12:	0f 85 ab 08 00 00    	jne    f01024c3 <mem_init+0x10ba>

	// should be no free memory
	assert(!page_alloc(0));
f0101c18:	83 ec 0c             	sub    $0xc,%esp
f0101c1b:	6a 00                	push   $0x0
f0101c1d:	e8 0a f4 ff ff       	call   f010102c <page_alloc>
f0101c22:	83 c4 10             	add    $0x10,%esp
f0101c25:	85 c0                	test   %eax,%eax
f0101c27:	0f 85 b8 08 00 00    	jne    f01024e5 <mem_init+0x10dc>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c2d:	6a 02                	push   $0x2
f0101c2f:	68 00 10 00 00       	push   $0x1000
f0101c34:	56                   	push   %esi
f0101c35:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c38:	c7 c0 0c e0 18 f0    	mov    $0xf018e00c,%eax
f0101c3e:	ff 30                	pushl  (%eax)
f0101c40:	e8 4c f7 ff ff       	call   f0101391 <page_insert>
f0101c45:	83 c4 10             	add    $0x10,%esp
f0101c48:	85 c0                	test   %eax,%eax
f0101c4a:	0f 85 b7 08 00 00    	jne    f0102507 <mem_init+0x10fe>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c50:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c55:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101c58:	c7 c0 0c e0 18 f0    	mov    $0xf018e00c,%eax
f0101c5e:	8b 00                	mov    (%eax),%eax
f0101c60:	e8 d6 ee ff ff       	call   f0100b3b <check_va2pa>
f0101c65:	c7 c2 10 e0 18 f0    	mov    $0xf018e010,%edx
f0101c6b:	89 f1                	mov    %esi,%ecx
f0101c6d:	2b 0a                	sub    (%edx),%ecx
f0101c6f:	89 ca                	mov    %ecx,%edx
f0101c71:	c1 fa 03             	sar    $0x3,%edx
f0101c74:	c1 e2 0c             	shl    $0xc,%edx
f0101c77:	39 d0                	cmp    %edx,%eax
f0101c79:	0f 85 aa 08 00 00    	jne    f0102529 <mem_init+0x1120>
	assert(pp2->pp_ref == 1);
f0101c7f:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101c84:	0f 85 c1 08 00 00    	jne    f010254b <mem_init+0x1142>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101c8a:	83 ec 0c             	sub    $0xc,%esp
f0101c8d:	6a 00                	push   $0x0
f0101c8f:	e8 98 f3 ff ff       	call   f010102c <page_alloc>
f0101c94:	83 c4 10             	add    $0x10,%esp
f0101c97:	85 c0                	test   %eax,%eax
f0101c99:	0f 85 ce 08 00 00    	jne    f010256d <mem_init+0x1164>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101c9f:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101ca2:	c7 c0 0c e0 18 f0    	mov    $0xf018e00c,%eax
f0101ca8:	8b 10                	mov    (%eax),%edx
f0101caa:	8b 02                	mov    (%edx),%eax
f0101cac:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101cb1:	89 c3                	mov    %eax,%ebx
f0101cb3:	c1 eb 0c             	shr    $0xc,%ebx
f0101cb6:	c7 c1 08 e0 18 f0    	mov    $0xf018e008,%ecx
f0101cbc:	3b 19                	cmp    (%ecx),%ebx
f0101cbe:	0f 83 cb 08 00 00    	jae    f010258f <mem_init+0x1186>
	return (void *)(pa + KERNBASE);
f0101cc4:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101cc9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101ccc:	83 ec 04             	sub    $0x4,%esp
f0101ccf:	6a 00                	push   $0x0
f0101cd1:	68 00 10 00 00       	push   $0x1000
f0101cd6:	52                   	push   %edx
f0101cd7:	e8 50 f4 ff ff       	call   f010112c <pgdir_walk>
f0101cdc:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101cdf:	8d 51 04             	lea    0x4(%ecx),%edx
f0101ce2:	83 c4 10             	add    $0x10,%esp
f0101ce5:	39 d0                	cmp    %edx,%eax
f0101ce7:	0f 85 be 08 00 00    	jne    f01025ab <mem_init+0x11a2>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101ced:	6a 06                	push   $0x6
f0101cef:	68 00 10 00 00       	push   $0x1000
f0101cf4:	56                   	push   %esi
f0101cf5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101cf8:	c7 c0 0c e0 18 f0    	mov    $0xf018e00c,%eax
f0101cfe:	ff 30                	pushl  (%eax)
f0101d00:	e8 8c f6 ff ff       	call   f0101391 <page_insert>
f0101d05:	83 c4 10             	add    $0x10,%esp
f0101d08:	85 c0                	test   %eax,%eax
f0101d0a:	0f 85 bd 08 00 00    	jne    f01025cd <mem_init+0x11c4>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d10:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d13:	c7 c0 0c e0 18 f0    	mov    $0xf018e00c,%eax
f0101d19:	8b 18                	mov    (%eax),%ebx
f0101d1b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d20:	89 d8                	mov    %ebx,%eax
f0101d22:	e8 14 ee ff ff       	call   f0100b3b <check_va2pa>
	return (pp - pages) << PGSHIFT;
f0101d27:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101d2a:	c7 c2 10 e0 18 f0    	mov    $0xf018e010,%edx
f0101d30:	89 f1                	mov    %esi,%ecx
f0101d32:	2b 0a                	sub    (%edx),%ecx
f0101d34:	89 ca                	mov    %ecx,%edx
f0101d36:	c1 fa 03             	sar    $0x3,%edx
f0101d39:	c1 e2 0c             	shl    $0xc,%edx
f0101d3c:	39 d0                	cmp    %edx,%eax
f0101d3e:	0f 85 ab 08 00 00    	jne    f01025ef <mem_init+0x11e6>
	assert(pp2->pp_ref == 1);
f0101d44:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d49:	0f 85 c2 08 00 00    	jne    f0102611 <mem_init+0x1208>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101d4f:	83 ec 04             	sub    $0x4,%esp
f0101d52:	6a 00                	push   $0x0
f0101d54:	68 00 10 00 00       	push   $0x1000
f0101d59:	53                   	push   %ebx
f0101d5a:	e8 cd f3 ff ff       	call   f010112c <pgdir_walk>
f0101d5f:	83 c4 10             	add    $0x10,%esp
f0101d62:	f6 00 04             	testb  $0x4,(%eax)
f0101d65:	0f 84 c8 08 00 00    	je     f0102633 <mem_init+0x122a>
	assert(kern_pgdir[0] & PTE_U);
f0101d6b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d6e:	c7 c0 0c e0 18 f0    	mov    $0xf018e00c,%eax
f0101d74:	8b 00                	mov    (%eax),%eax
f0101d76:	f6 00 04             	testb  $0x4,(%eax)
f0101d79:	0f 84 d6 08 00 00    	je     f0102655 <mem_init+0x124c>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101d7f:	6a 02                	push   $0x2
f0101d81:	68 00 10 00 00       	push   $0x1000
f0101d86:	56                   	push   %esi
f0101d87:	50                   	push   %eax
f0101d88:	e8 04 f6 ff ff       	call   f0101391 <page_insert>
f0101d8d:	83 c4 10             	add    $0x10,%esp
f0101d90:	85 c0                	test   %eax,%eax
f0101d92:	0f 85 df 08 00 00    	jne    f0102677 <mem_init+0x126e>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101d98:	83 ec 04             	sub    $0x4,%esp
f0101d9b:	6a 00                	push   $0x0
f0101d9d:	68 00 10 00 00       	push   $0x1000
f0101da2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101da5:	c7 c0 0c e0 18 f0    	mov    $0xf018e00c,%eax
f0101dab:	ff 30                	pushl  (%eax)
f0101dad:	e8 7a f3 ff ff       	call   f010112c <pgdir_walk>
f0101db2:	83 c4 10             	add    $0x10,%esp
f0101db5:	f6 00 02             	testb  $0x2,(%eax)
f0101db8:	0f 84 db 08 00 00    	je     f0102699 <mem_init+0x1290>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101dbe:	83 ec 04             	sub    $0x4,%esp
f0101dc1:	6a 00                	push   $0x0
f0101dc3:	68 00 10 00 00       	push   $0x1000
f0101dc8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101dcb:	c7 c0 0c e0 18 f0    	mov    $0xf018e00c,%eax
f0101dd1:	ff 30                	pushl  (%eax)
f0101dd3:	e8 54 f3 ff ff       	call   f010112c <pgdir_walk>
f0101dd8:	83 c4 10             	add    $0x10,%esp
f0101ddb:	f6 00 04             	testb  $0x4,(%eax)
f0101dde:	0f 85 d7 08 00 00    	jne    f01026bb <mem_init+0x12b2>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101de4:	6a 02                	push   $0x2
f0101de6:	68 00 00 40 00       	push   $0x400000
f0101deb:	ff 75 d0             	pushl  -0x30(%ebp)
f0101dee:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101df1:	c7 c0 0c e0 18 f0    	mov    $0xf018e00c,%eax
f0101df7:	ff 30                	pushl  (%eax)
f0101df9:	e8 93 f5 ff ff       	call   f0101391 <page_insert>
f0101dfe:	83 c4 10             	add    $0x10,%esp
f0101e01:	85 c0                	test   %eax,%eax
f0101e03:	0f 89 d4 08 00 00    	jns    f01026dd <mem_init+0x12d4>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101e09:	6a 02                	push   $0x2
f0101e0b:	68 00 10 00 00       	push   $0x1000
f0101e10:	57                   	push   %edi
f0101e11:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e14:	c7 c0 0c e0 18 f0    	mov    $0xf018e00c,%eax
f0101e1a:	ff 30                	pushl  (%eax)
f0101e1c:	e8 70 f5 ff ff       	call   f0101391 <page_insert>
f0101e21:	83 c4 10             	add    $0x10,%esp
f0101e24:	85 c0                	test   %eax,%eax
f0101e26:	0f 85 d3 08 00 00    	jne    f01026ff <mem_init+0x12f6>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101e2c:	83 ec 04             	sub    $0x4,%esp
f0101e2f:	6a 00                	push   $0x0
f0101e31:	68 00 10 00 00       	push   $0x1000
f0101e36:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e39:	c7 c0 0c e0 18 f0    	mov    $0xf018e00c,%eax
f0101e3f:	ff 30                	pushl  (%eax)
f0101e41:	e8 e6 f2 ff ff       	call   f010112c <pgdir_walk>
f0101e46:	83 c4 10             	add    $0x10,%esp
f0101e49:	f6 00 04             	testb  $0x4,(%eax)
f0101e4c:	0f 85 cf 08 00 00    	jne    f0102721 <mem_init+0x1318>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101e52:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e55:	c7 c0 0c e0 18 f0    	mov    $0xf018e00c,%eax
f0101e5b:	8b 18                	mov    (%eax),%ebx
f0101e5d:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e62:	89 d8                	mov    %ebx,%eax
f0101e64:	e8 d2 ec ff ff       	call   f0100b3b <check_va2pa>
f0101e69:	89 c2                	mov    %eax,%edx
f0101e6b:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101e6e:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101e71:	c7 c0 10 e0 18 f0    	mov    $0xf018e010,%eax
f0101e77:	89 f9                	mov    %edi,%ecx
f0101e79:	2b 08                	sub    (%eax),%ecx
f0101e7b:	89 c8                	mov    %ecx,%eax
f0101e7d:	c1 f8 03             	sar    $0x3,%eax
f0101e80:	c1 e0 0c             	shl    $0xc,%eax
f0101e83:	39 c2                	cmp    %eax,%edx
f0101e85:	0f 85 b8 08 00 00    	jne    f0102743 <mem_init+0x133a>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101e8b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e90:	89 d8                	mov    %ebx,%eax
f0101e92:	e8 a4 ec ff ff       	call   f0100b3b <check_va2pa>
f0101e97:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101e9a:	0f 85 c5 08 00 00    	jne    f0102765 <mem_init+0x135c>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101ea0:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0101ea5:	0f 85 dc 08 00 00    	jne    f0102787 <mem_init+0x137e>
	assert(pp2->pp_ref == 0);
f0101eab:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101eb0:	0f 85 f3 08 00 00    	jne    f01027a9 <mem_init+0x13a0>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101eb6:	83 ec 0c             	sub    $0xc,%esp
f0101eb9:	6a 00                	push   $0x0
f0101ebb:	e8 6c f1 ff ff       	call   f010102c <page_alloc>
f0101ec0:	83 c4 10             	add    $0x10,%esp
f0101ec3:	39 c6                	cmp    %eax,%esi
f0101ec5:	0f 85 00 09 00 00    	jne    f01027cb <mem_init+0x13c2>
f0101ecb:	85 c0                	test   %eax,%eax
f0101ecd:	0f 84 f8 08 00 00    	je     f01027cb <mem_init+0x13c2>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101ed3:	83 ec 08             	sub    $0x8,%esp
f0101ed6:	6a 00                	push   $0x0
f0101ed8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101edb:	c7 c3 0c e0 18 f0    	mov    $0xf018e00c,%ebx
f0101ee1:	ff 33                	pushl  (%ebx)
f0101ee3:	e8 6c f4 ff ff       	call   f0101354 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101ee8:	8b 1b                	mov    (%ebx),%ebx
f0101eea:	ba 00 00 00 00       	mov    $0x0,%edx
f0101eef:	89 d8                	mov    %ebx,%eax
f0101ef1:	e8 45 ec ff ff       	call   f0100b3b <check_va2pa>
f0101ef6:	83 c4 10             	add    $0x10,%esp
f0101ef9:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101efc:	0f 85 eb 08 00 00    	jne    f01027ed <mem_init+0x13e4>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101f02:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f07:	89 d8                	mov    %ebx,%eax
f0101f09:	e8 2d ec ff ff       	call   f0100b3b <check_va2pa>
f0101f0e:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101f11:	c7 c2 10 e0 18 f0    	mov    $0xf018e010,%edx
f0101f17:	89 f9                	mov    %edi,%ecx
f0101f19:	2b 0a                	sub    (%edx),%ecx
f0101f1b:	89 ca                	mov    %ecx,%edx
f0101f1d:	c1 fa 03             	sar    $0x3,%edx
f0101f20:	c1 e2 0c             	shl    $0xc,%edx
f0101f23:	39 d0                	cmp    %edx,%eax
f0101f25:	0f 85 e4 08 00 00    	jne    f010280f <mem_init+0x1406>
	assert(pp1->pp_ref == 1);
f0101f2b:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101f30:	0f 85 fb 08 00 00    	jne    f0102831 <mem_init+0x1428>
	assert(pp2->pp_ref == 0);
f0101f36:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101f3b:	0f 85 12 09 00 00    	jne    f0102853 <mem_init+0x144a>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101f41:	6a 00                	push   $0x0
f0101f43:	68 00 10 00 00       	push   $0x1000
f0101f48:	57                   	push   %edi
f0101f49:	53                   	push   %ebx
f0101f4a:	e8 42 f4 ff ff       	call   f0101391 <page_insert>
f0101f4f:	83 c4 10             	add    $0x10,%esp
f0101f52:	85 c0                	test   %eax,%eax
f0101f54:	0f 85 1b 09 00 00    	jne    f0102875 <mem_init+0x146c>
	assert(pp1->pp_ref);
f0101f5a:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101f5f:	0f 84 32 09 00 00    	je     f0102897 <mem_init+0x148e>
	assert(pp1->pp_link == NULL);
f0101f65:	83 3f 00             	cmpl   $0x0,(%edi)
f0101f68:	0f 85 4b 09 00 00    	jne    f01028b9 <mem_init+0x14b0>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101f6e:	83 ec 08             	sub    $0x8,%esp
f0101f71:	68 00 10 00 00       	push   $0x1000
f0101f76:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f79:	c7 c3 0c e0 18 f0    	mov    $0xf018e00c,%ebx
f0101f7f:	ff 33                	pushl  (%ebx)
f0101f81:	e8 ce f3 ff ff       	call   f0101354 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101f86:	8b 1b                	mov    (%ebx),%ebx
f0101f88:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f8d:	89 d8                	mov    %ebx,%eax
f0101f8f:	e8 a7 eb ff ff       	call   f0100b3b <check_va2pa>
f0101f94:	83 c4 10             	add    $0x10,%esp
f0101f97:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f9a:	0f 85 3b 09 00 00    	jne    f01028db <mem_init+0x14d2>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101fa0:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101fa5:	89 d8                	mov    %ebx,%eax
f0101fa7:	e8 8f eb ff ff       	call   f0100b3b <check_va2pa>
f0101fac:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101faf:	0f 85 48 09 00 00    	jne    f01028fd <mem_init+0x14f4>
	assert(pp1->pp_ref == 0);
f0101fb5:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101fba:	0f 85 5f 09 00 00    	jne    f010291f <mem_init+0x1516>
	assert(pp2->pp_ref == 0);
f0101fc0:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101fc5:	0f 85 76 09 00 00    	jne    f0102941 <mem_init+0x1538>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101fcb:	83 ec 0c             	sub    $0xc,%esp
f0101fce:	6a 00                	push   $0x0
f0101fd0:	e8 57 f0 ff ff       	call   f010102c <page_alloc>
f0101fd5:	83 c4 10             	add    $0x10,%esp
f0101fd8:	39 c7                	cmp    %eax,%edi
f0101fda:	0f 85 83 09 00 00    	jne    f0102963 <mem_init+0x155a>
f0101fe0:	85 c0                	test   %eax,%eax
f0101fe2:	0f 84 7b 09 00 00    	je     f0102963 <mem_init+0x155a>

	// should be no free memory
	assert(!page_alloc(0));
f0101fe8:	83 ec 0c             	sub    $0xc,%esp
f0101feb:	6a 00                	push   $0x0
f0101fed:	e8 3a f0 ff ff       	call   f010102c <page_alloc>
f0101ff2:	83 c4 10             	add    $0x10,%esp
f0101ff5:	85 c0                	test   %eax,%eax
f0101ff7:	0f 85 88 09 00 00    	jne    f0102985 <mem_init+0x157c>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101ffd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102000:	c7 c0 0c e0 18 f0    	mov    $0xf018e00c,%eax
f0102006:	8b 08                	mov    (%eax),%ecx
f0102008:	8b 11                	mov    (%ecx),%edx
f010200a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102010:	c7 c0 10 e0 18 f0    	mov    $0xf018e010,%eax
f0102016:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0102019:	2b 18                	sub    (%eax),%ebx
f010201b:	89 d8                	mov    %ebx,%eax
f010201d:	c1 f8 03             	sar    $0x3,%eax
f0102020:	c1 e0 0c             	shl    $0xc,%eax
f0102023:	39 c2                	cmp    %eax,%edx
f0102025:	0f 85 7c 09 00 00    	jne    f01029a7 <mem_init+0x159e>
	kern_pgdir[0] = 0;
f010202b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102031:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102034:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102039:	0f 85 8a 09 00 00    	jne    f01029c9 <mem_init+0x15c0>
	pp0->pp_ref = 0;
f010203f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102042:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102048:	83 ec 0c             	sub    $0xc,%esp
f010204b:	50                   	push   %eax
f010204c:	e8 63 f0 ff ff       	call   f01010b4 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102051:	83 c4 0c             	add    $0xc,%esp
f0102054:	6a 01                	push   $0x1
f0102056:	68 00 10 40 00       	push   $0x401000
f010205b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010205e:	c7 c3 0c e0 18 f0    	mov    $0xf018e00c,%ebx
f0102064:	ff 33                	pushl  (%ebx)
f0102066:	e8 c1 f0 ff ff       	call   f010112c <pgdir_walk>
f010206b:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010206e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102071:	8b 1b                	mov    (%ebx),%ebx
f0102073:	8b 53 04             	mov    0x4(%ebx),%edx
f0102076:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f010207c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010207f:	c7 c1 08 e0 18 f0    	mov    $0xf018e008,%ecx
f0102085:	8b 09                	mov    (%ecx),%ecx
f0102087:	89 d0                	mov    %edx,%eax
f0102089:	c1 e8 0c             	shr    $0xc,%eax
f010208c:	83 c4 10             	add    $0x10,%esp
f010208f:	39 c8                	cmp    %ecx,%eax
f0102091:	0f 83 54 09 00 00    	jae    f01029eb <mem_init+0x15e2>
	assert(ptep == ptep1 + PTX(va));
f0102097:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f010209d:	39 55 cc             	cmp    %edx,-0x34(%ebp)
f01020a0:	0f 85 61 09 00 00    	jne    f0102a07 <mem_init+0x15fe>
	kern_pgdir[PDX(va)] = 0;
f01020a6:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	pp0->pp_ref = 0;
f01020ad:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f01020b0:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
	return (pp - pages) << PGSHIFT;
f01020b6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020b9:	c7 c0 10 e0 18 f0    	mov    $0xf018e010,%eax
f01020bf:	2b 18                	sub    (%eax),%ebx
f01020c1:	89 d8                	mov    %ebx,%eax
f01020c3:	c1 f8 03             	sar    $0x3,%eax
f01020c6:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01020c9:	89 c2                	mov    %eax,%edx
f01020cb:	c1 ea 0c             	shr    $0xc,%edx
f01020ce:	39 d1                	cmp    %edx,%ecx
f01020d0:	0f 86 53 09 00 00    	jbe    f0102a29 <mem_init+0x1620>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01020d6:	83 ec 04             	sub    $0x4,%esp
f01020d9:	68 00 10 00 00       	push   $0x1000
f01020de:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f01020e3:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01020e8:	50                   	push   %eax
f01020e9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01020ec:	e8 96 26 00 00       	call   f0104787 <memset>
	page_free(pp0);
f01020f1:	83 c4 04             	add    $0x4,%esp
f01020f4:	ff 75 d0             	pushl  -0x30(%ebp)
f01020f7:	e8 b8 ef ff ff       	call   f01010b4 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01020fc:	83 c4 0c             	add    $0xc,%esp
f01020ff:	6a 01                	push   $0x1
f0102101:	6a 00                	push   $0x0
f0102103:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102106:	c7 c0 0c e0 18 f0    	mov    $0xf018e00c,%eax
f010210c:	ff 30                	pushl  (%eax)
f010210e:	e8 19 f0 ff ff       	call   f010112c <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0102113:	c7 c0 10 e0 18 f0    	mov    $0xf018e010,%eax
f0102119:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010211c:	2b 10                	sub    (%eax),%edx
f010211e:	c1 fa 03             	sar    $0x3,%edx
f0102121:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102124:	89 d1                	mov    %edx,%ecx
f0102126:	c1 e9 0c             	shr    $0xc,%ecx
f0102129:	83 c4 10             	add    $0x10,%esp
f010212c:	c7 c0 08 e0 18 f0    	mov    $0xf018e008,%eax
f0102132:	3b 08                	cmp    (%eax),%ecx
f0102134:	0f 83 08 09 00 00    	jae    f0102a42 <mem_init+0x1639>
	return (void *)(pa + KERNBASE);
f010213a:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102140:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102143:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102149:	f6 00 01             	testb  $0x1,(%eax)
f010214c:	0f 85 09 09 00 00    	jne    f0102a5b <mem_init+0x1652>
f0102152:	83 c0 04             	add    $0x4,%eax
	for(i=0; i<NPTENTRIES; i++)
f0102155:	39 d0                	cmp    %edx,%eax
f0102157:	75 f0                	jne    f0102149 <mem_init+0xd40>
	kern_pgdir[0] = 0;
f0102159:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010215c:	c7 c0 0c e0 18 f0    	mov    $0xf018e00c,%eax
f0102162:	8b 00                	mov    (%eax),%eax
f0102164:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010216a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010216d:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0102173:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0102176:	89 93 1c 23 00 00    	mov    %edx,0x231c(%ebx)

	// free the pages we took
	page_free(pp0);
f010217c:	83 ec 0c             	sub    $0xc,%esp
f010217f:	50                   	push   %eax
f0102180:	e8 2f ef ff ff       	call   f01010b4 <page_free>
	page_free(pp1);
f0102185:	89 3c 24             	mov    %edi,(%esp)
f0102188:	e8 27 ef ff ff       	call   f01010b4 <page_free>
	page_free(pp2);
f010218d:	89 34 24             	mov    %esi,(%esp)
f0102190:	e8 1f ef ff ff       	call   f01010b4 <page_free>

	cprintf("check_page() succeeded!\n");
f0102195:	8d 83 81 ab f7 ff    	lea    -0x8547f(%ebx),%eax
f010219b:	89 04 24             	mov    %eax,(%esp)
f010219e:	e8 33 15 00 00       	call   f01036d6 <cprintf>
        boot_map_region(kern_pgdir,UPAGES,PTSIZE,PADDR(pages),PTE_U|PTE_P);
f01021a3:	c7 c0 10 e0 18 f0    	mov    $0xf018e010,%eax
f01021a9:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f01021ab:	83 c4 10             	add    $0x10,%esp
f01021ae:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01021b3:	0f 86 c4 08 00 00    	jbe    f0102a7d <mem_init+0x1674>
f01021b9:	83 ec 08             	sub    $0x8,%esp
f01021bc:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f01021be:	05 00 00 00 10       	add    $0x10000000,%eax
f01021c3:	50                   	push   %eax
f01021c4:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01021c9:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01021ce:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01021d1:	c7 c0 0c e0 18 f0    	mov    $0xf018e00c,%eax
f01021d7:	8b 00                	mov    (%eax),%eax
f01021d9:	e8 6c f0 ff ff       	call   f010124a <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f01021de:	c7 c0 00 10 11 f0    	mov    $0xf0111000,%eax
f01021e4:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01021e7:	83 c4 10             	add    $0x10,%esp
f01021ea:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01021ef:	0f 86 a4 08 00 00    	jbe    f0102a99 <mem_init+0x1690>
        boot_map_region(kern_pgdir,KSTACKTOP-KSTKSIZE,KSTKSIZE,PADDR(bootstack),PTE_W|PTE_P);
f01021f5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01021f8:	c7 c3 0c e0 18 f0    	mov    $0xf018e00c,%ebx
f01021fe:	83 ec 08             	sub    $0x8,%esp
f0102201:	6a 03                	push   $0x3
	return (physaddr_t)kva - KERNBASE;
f0102203:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102206:	05 00 00 00 10       	add    $0x10000000,%eax
f010220b:	50                   	push   %eax
f010220c:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102211:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102216:	8b 03                	mov    (%ebx),%eax
f0102218:	e8 2d f0 ff ff       	call   f010124a <boot_map_region>
        boot_map_region(kern_pgdir,KERNBASE,0xffffffff-KERNBASE,0,PTE_W|PTE_P);
f010221d:	83 c4 08             	add    $0x8,%esp
f0102220:	6a 03                	push   $0x3
f0102222:	6a 00                	push   $0x0
f0102224:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f0102229:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f010222e:	8b 03                	mov    (%ebx),%eax
f0102230:	e8 15 f0 ff ff       	call   f010124a <boot_map_region>
	pgdir = kern_pgdir;
f0102235:	8b 33                	mov    (%ebx),%esi
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102237:	c7 c0 08 e0 18 f0    	mov    $0xf018e008,%eax
f010223d:	8b 00                	mov    (%eax),%eax
f010223f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0102242:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102249:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010224e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102251:	c7 c0 10 e0 18 f0    	mov    $0xf018e010,%eax
f0102257:	8b 00                	mov    (%eax),%eax
f0102259:	89 45 c0             	mov    %eax,-0x40(%ebp)
	if ((uint32_t)kva < KERNBASE)
f010225c:	89 45 cc             	mov    %eax,-0x34(%ebp)
	return (physaddr_t)kva - KERNBASE;
f010225f:	8d b8 00 00 00 10    	lea    0x10000000(%eax),%edi
f0102265:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < n; i += PGSIZE)
f0102268:	bb 00 00 00 00       	mov    $0x0,%ebx
f010226d:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f0102270:	0f 86 84 08 00 00    	jbe    f0102afa <mem_init+0x16f1>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102276:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f010227c:	89 f0                	mov    %esi,%eax
f010227e:	e8 b8 e8 ff ff       	call   f0100b3b <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102283:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f010228a:	0f 86 2a 08 00 00    	jbe    f0102aba <mem_init+0x16b1>
f0102290:	8d 14 3b             	lea    (%ebx,%edi,1),%edx
f0102293:	39 d0                	cmp    %edx,%eax
f0102295:	0f 85 3d 08 00 00    	jne    f0102ad8 <mem_init+0x16cf>
	for (i = 0; i < n; i += PGSIZE)
f010229b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01022a1:	eb ca                	jmp    f010226d <mem_init+0xe64>
	assert(nfree == 0);
f01022a3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01022a6:	8d 83 aa aa f7 ff    	lea    -0x85556(%ebx),%eax
f01022ac:	50                   	push   %eax
f01022ad:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f01022b3:	50                   	push   %eax
f01022b4:	68 c8 02 00 00       	push   $0x2c8
f01022b9:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f01022bf:	50                   	push   %eax
f01022c0:	e8 2b de ff ff       	call   f01000f0 <_panic>
	assert((pp0 = page_alloc(0)));
f01022c5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01022c8:	8d 83 b8 a9 f7 ff    	lea    -0x85648(%ebx),%eax
f01022ce:	50                   	push   %eax
f01022cf:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f01022d5:	50                   	push   %eax
f01022d6:	68 26 03 00 00       	push   $0x326
f01022db:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f01022e1:	50                   	push   %eax
f01022e2:	e8 09 de ff ff       	call   f01000f0 <_panic>
	assert((pp1 = page_alloc(0)));
f01022e7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01022ea:	8d 83 ce a9 f7 ff    	lea    -0x85632(%ebx),%eax
f01022f0:	50                   	push   %eax
f01022f1:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f01022f7:	50                   	push   %eax
f01022f8:	68 27 03 00 00       	push   $0x327
f01022fd:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0102303:	50                   	push   %eax
f0102304:	e8 e7 dd ff ff       	call   f01000f0 <_panic>
	assert((pp2 = page_alloc(0)));
f0102309:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010230c:	8d 83 e4 a9 f7 ff    	lea    -0x8561c(%ebx),%eax
f0102312:	50                   	push   %eax
f0102313:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0102319:	50                   	push   %eax
f010231a:	68 28 03 00 00       	push   $0x328
f010231f:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0102325:	50                   	push   %eax
f0102326:	e8 c5 dd ff ff       	call   f01000f0 <_panic>
	assert(pp1 && pp1 != pp0);
f010232b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010232e:	8d 83 fa a9 f7 ff    	lea    -0x85606(%ebx),%eax
f0102334:	50                   	push   %eax
f0102335:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f010233b:	50                   	push   %eax
f010233c:	68 2b 03 00 00       	push   $0x32b
f0102341:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0102347:	50                   	push   %eax
f0102348:	e8 a3 dd ff ff       	call   f01000f0 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010234d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102350:	8d 83 b0 a2 f7 ff    	lea    -0x85d50(%ebx),%eax
f0102356:	50                   	push   %eax
f0102357:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f010235d:	50                   	push   %eax
f010235e:	68 2c 03 00 00       	push   $0x32c
f0102363:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0102369:	50                   	push   %eax
f010236a:	e8 81 dd ff ff       	call   f01000f0 <_panic>
	assert(!page_alloc(0));
f010236f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102372:	8d 83 63 aa f7 ff    	lea    -0x8559d(%ebx),%eax
f0102378:	50                   	push   %eax
f0102379:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f010237f:	50                   	push   %eax
f0102380:	68 33 03 00 00       	push   $0x333
f0102385:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f010238b:	50                   	push   %eax
f010238c:	e8 5f dd ff ff       	call   f01000f0 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0102391:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102394:	8d 83 f0 a2 f7 ff    	lea    -0x85d10(%ebx),%eax
f010239a:	50                   	push   %eax
f010239b:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f01023a1:	50                   	push   %eax
f01023a2:	68 36 03 00 00       	push   $0x336
f01023a7:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f01023ad:	50                   	push   %eax
f01023ae:	e8 3d dd ff ff       	call   f01000f0 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01023b3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01023b6:	8d 83 28 a3 f7 ff    	lea    -0x85cd8(%ebx),%eax
f01023bc:	50                   	push   %eax
f01023bd:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f01023c3:	50                   	push   %eax
f01023c4:	68 39 03 00 00       	push   $0x339
f01023c9:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f01023cf:	50                   	push   %eax
f01023d0:	e8 1b dd ff ff       	call   f01000f0 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01023d5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01023d8:	8d 83 58 a3 f7 ff    	lea    -0x85ca8(%ebx),%eax
f01023de:	50                   	push   %eax
f01023df:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f01023e5:	50                   	push   %eax
f01023e6:	68 3d 03 00 00       	push   $0x33d
f01023eb:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f01023f1:	50                   	push   %eax
f01023f2:	e8 f9 dc ff ff       	call   f01000f0 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01023f7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01023fa:	8d 83 88 a3 f7 ff    	lea    -0x85c78(%ebx),%eax
f0102400:	50                   	push   %eax
f0102401:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0102407:	50                   	push   %eax
f0102408:	68 3e 03 00 00       	push   $0x33e
f010240d:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0102413:	50                   	push   %eax
f0102414:	e8 d7 dc ff ff       	call   f01000f0 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0102419:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010241c:	8d 83 b0 a3 f7 ff    	lea    -0x85c50(%ebx),%eax
f0102422:	50                   	push   %eax
f0102423:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0102429:	50                   	push   %eax
f010242a:	68 3f 03 00 00       	push   $0x33f
f010242f:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0102435:	50                   	push   %eax
f0102436:	e8 b5 dc ff ff       	call   f01000f0 <_panic>
	assert(pp1->pp_ref == 1);
f010243b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010243e:	8d 83 b5 aa f7 ff    	lea    -0x8554b(%ebx),%eax
f0102444:	50                   	push   %eax
f0102445:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f010244b:	50                   	push   %eax
f010244c:	68 40 03 00 00       	push   $0x340
f0102451:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0102457:	50                   	push   %eax
f0102458:	e8 93 dc ff ff       	call   f01000f0 <_panic>
	assert(pp0->pp_ref == 1);
f010245d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102460:	8d 83 c6 aa f7 ff    	lea    -0x8553a(%ebx),%eax
f0102466:	50                   	push   %eax
f0102467:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f010246d:	50                   	push   %eax
f010246e:	68 41 03 00 00       	push   $0x341
f0102473:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0102479:	50                   	push   %eax
f010247a:	e8 71 dc ff ff       	call   f01000f0 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010247f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102482:	8d 83 e0 a3 f7 ff    	lea    -0x85c20(%ebx),%eax
f0102488:	50                   	push   %eax
f0102489:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f010248f:	50                   	push   %eax
f0102490:	68 44 03 00 00       	push   $0x344
f0102495:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f010249b:	50                   	push   %eax
f010249c:	e8 4f dc ff ff       	call   f01000f0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01024a1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024a4:	8d 83 1c a4 f7 ff    	lea    -0x85be4(%ebx),%eax
f01024aa:	50                   	push   %eax
f01024ab:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f01024b1:	50                   	push   %eax
f01024b2:	68 45 03 00 00       	push   $0x345
f01024b7:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f01024bd:	50                   	push   %eax
f01024be:	e8 2d dc ff ff       	call   f01000f0 <_panic>
	assert(pp2->pp_ref == 1);
f01024c3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024c6:	8d 83 d7 aa f7 ff    	lea    -0x85529(%ebx),%eax
f01024cc:	50                   	push   %eax
f01024cd:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f01024d3:	50                   	push   %eax
f01024d4:	68 46 03 00 00       	push   $0x346
f01024d9:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f01024df:	50                   	push   %eax
f01024e0:	e8 0b dc ff ff       	call   f01000f0 <_panic>
	assert(!page_alloc(0));
f01024e5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024e8:	8d 83 63 aa f7 ff    	lea    -0x8559d(%ebx),%eax
f01024ee:	50                   	push   %eax
f01024ef:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f01024f5:	50                   	push   %eax
f01024f6:	68 49 03 00 00       	push   $0x349
f01024fb:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0102501:	50                   	push   %eax
f0102502:	e8 e9 db ff ff       	call   f01000f0 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102507:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010250a:	8d 83 e0 a3 f7 ff    	lea    -0x85c20(%ebx),%eax
f0102510:	50                   	push   %eax
f0102511:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0102517:	50                   	push   %eax
f0102518:	68 4c 03 00 00       	push   $0x34c
f010251d:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0102523:	50                   	push   %eax
f0102524:	e8 c7 db ff ff       	call   f01000f0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102529:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010252c:	8d 83 1c a4 f7 ff    	lea    -0x85be4(%ebx),%eax
f0102532:	50                   	push   %eax
f0102533:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0102539:	50                   	push   %eax
f010253a:	68 4d 03 00 00       	push   $0x34d
f010253f:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0102545:	50                   	push   %eax
f0102546:	e8 a5 db ff ff       	call   f01000f0 <_panic>
	assert(pp2->pp_ref == 1);
f010254b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010254e:	8d 83 d7 aa f7 ff    	lea    -0x85529(%ebx),%eax
f0102554:	50                   	push   %eax
f0102555:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f010255b:	50                   	push   %eax
f010255c:	68 4e 03 00 00       	push   $0x34e
f0102561:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0102567:	50                   	push   %eax
f0102568:	e8 83 db ff ff       	call   f01000f0 <_panic>
	assert(!page_alloc(0));
f010256d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102570:	8d 83 63 aa f7 ff    	lea    -0x8559d(%ebx),%eax
f0102576:	50                   	push   %eax
f0102577:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f010257d:	50                   	push   %eax
f010257e:	68 52 03 00 00       	push   $0x352
f0102583:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0102589:	50                   	push   %eax
f010258a:	e8 61 db ff ff       	call   f01000f0 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010258f:	50                   	push   %eax
f0102590:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102593:	8d 83 00 a1 f7 ff    	lea    -0x85f00(%ebx),%eax
f0102599:	50                   	push   %eax
f010259a:	68 55 03 00 00       	push   $0x355
f010259f:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f01025a5:	50                   	push   %eax
f01025a6:	e8 45 db ff ff       	call   f01000f0 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01025ab:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025ae:	8d 83 4c a4 f7 ff    	lea    -0x85bb4(%ebx),%eax
f01025b4:	50                   	push   %eax
f01025b5:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f01025bb:	50                   	push   %eax
f01025bc:	68 56 03 00 00       	push   $0x356
f01025c1:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f01025c7:	50                   	push   %eax
f01025c8:	e8 23 db ff ff       	call   f01000f0 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01025cd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025d0:	8d 83 8c a4 f7 ff    	lea    -0x85b74(%ebx),%eax
f01025d6:	50                   	push   %eax
f01025d7:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f01025dd:	50                   	push   %eax
f01025de:	68 59 03 00 00       	push   $0x359
f01025e3:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f01025e9:	50                   	push   %eax
f01025ea:	e8 01 db ff ff       	call   f01000f0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01025ef:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025f2:	8d 83 1c a4 f7 ff    	lea    -0x85be4(%ebx),%eax
f01025f8:	50                   	push   %eax
f01025f9:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f01025ff:	50                   	push   %eax
f0102600:	68 5a 03 00 00       	push   $0x35a
f0102605:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f010260b:	50                   	push   %eax
f010260c:	e8 df da ff ff       	call   f01000f0 <_panic>
	assert(pp2->pp_ref == 1);
f0102611:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102614:	8d 83 d7 aa f7 ff    	lea    -0x85529(%ebx),%eax
f010261a:	50                   	push   %eax
f010261b:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0102621:	50                   	push   %eax
f0102622:	68 5b 03 00 00       	push   $0x35b
f0102627:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f010262d:	50                   	push   %eax
f010262e:	e8 bd da ff ff       	call   f01000f0 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102633:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102636:	8d 83 cc a4 f7 ff    	lea    -0x85b34(%ebx),%eax
f010263c:	50                   	push   %eax
f010263d:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0102643:	50                   	push   %eax
f0102644:	68 5c 03 00 00       	push   $0x35c
f0102649:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f010264f:	50                   	push   %eax
f0102650:	e8 9b da ff ff       	call   f01000f0 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102655:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102658:	8d 83 e8 aa f7 ff    	lea    -0x85518(%ebx),%eax
f010265e:	50                   	push   %eax
f010265f:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0102665:	50                   	push   %eax
f0102666:	68 5d 03 00 00       	push   $0x35d
f010266b:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0102671:	50                   	push   %eax
f0102672:	e8 79 da ff ff       	call   f01000f0 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102677:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010267a:	8d 83 e0 a3 f7 ff    	lea    -0x85c20(%ebx),%eax
f0102680:	50                   	push   %eax
f0102681:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0102687:	50                   	push   %eax
f0102688:	68 60 03 00 00       	push   $0x360
f010268d:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0102693:	50                   	push   %eax
f0102694:	e8 57 da ff ff       	call   f01000f0 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102699:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010269c:	8d 83 00 a5 f7 ff    	lea    -0x85b00(%ebx),%eax
f01026a2:	50                   	push   %eax
f01026a3:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f01026a9:	50                   	push   %eax
f01026aa:	68 61 03 00 00       	push   $0x361
f01026af:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f01026b5:	50                   	push   %eax
f01026b6:	e8 35 da ff ff       	call   f01000f0 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01026bb:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026be:	8d 83 34 a5 f7 ff    	lea    -0x85acc(%ebx),%eax
f01026c4:	50                   	push   %eax
f01026c5:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f01026cb:	50                   	push   %eax
f01026cc:	68 62 03 00 00       	push   $0x362
f01026d1:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f01026d7:	50                   	push   %eax
f01026d8:	e8 13 da ff ff       	call   f01000f0 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01026dd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026e0:	8d 83 6c a5 f7 ff    	lea    -0x85a94(%ebx),%eax
f01026e6:	50                   	push   %eax
f01026e7:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f01026ed:	50                   	push   %eax
f01026ee:	68 65 03 00 00       	push   $0x365
f01026f3:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f01026f9:	50                   	push   %eax
f01026fa:	e8 f1 d9 ff ff       	call   f01000f0 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01026ff:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102702:	8d 83 a4 a5 f7 ff    	lea    -0x85a5c(%ebx),%eax
f0102708:	50                   	push   %eax
f0102709:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f010270f:	50                   	push   %eax
f0102710:	68 68 03 00 00       	push   $0x368
f0102715:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f010271b:	50                   	push   %eax
f010271c:	e8 cf d9 ff ff       	call   f01000f0 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102721:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102724:	8d 83 34 a5 f7 ff    	lea    -0x85acc(%ebx),%eax
f010272a:	50                   	push   %eax
f010272b:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0102731:	50                   	push   %eax
f0102732:	68 69 03 00 00       	push   $0x369
f0102737:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f010273d:	50                   	push   %eax
f010273e:	e8 ad d9 ff ff       	call   f01000f0 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102743:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102746:	8d 83 e0 a5 f7 ff    	lea    -0x85a20(%ebx),%eax
f010274c:	50                   	push   %eax
f010274d:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0102753:	50                   	push   %eax
f0102754:	68 6c 03 00 00       	push   $0x36c
f0102759:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f010275f:	50                   	push   %eax
f0102760:	e8 8b d9 ff ff       	call   f01000f0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102765:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102768:	8d 83 0c a6 f7 ff    	lea    -0x859f4(%ebx),%eax
f010276e:	50                   	push   %eax
f010276f:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0102775:	50                   	push   %eax
f0102776:	68 6d 03 00 00       	push   $0x36d
f010277b:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0102781:	50                   	push   %eax
f0102782:	e8 69 d9 ff ff       	call   f01000f0 <_panic>
	assert(pp1->pp_ref == 2);
f0102787:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010278a:	8d 83 fe aa f7 ff    	lea    -0x85502(%ebx),%eax
f0102790:	50                   	push   %eax
f0102791:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0102797:	50                   	push   %eax
f0102798:	68 6f 03 00 00       	push   $0x36f
f010279d:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f01027a3:	50                   	push   %eax
f01027a4:	e8 47 d9 ff ff       	call   f01000f0 <_panic>
	assert(pp2->pp_ref == 0);
f01027a9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027ac:	8d 83 0f ab f7 ff    	lea    -0x854f1(%ebx),%eax
f01027b2:	50                   	push   %eax
f01027b3:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f01027b9:	50                   	push   %eax
f01027ba:	68 70 03 00 00       	push   $0x370
f01027bf:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f01027c5:	50                   	push   %eax
f01027c6:	e8 25 d9 ff ff       	call   f01000f0 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f01027cb:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027ce:	8d 83 3c a6 f7 ff    	lea    -0x859c4(%ebx),%eax
f01027d4:	50                   	push   %eax
f01027d5:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f01027db:	50                   	push   %eax
f01027dc:	68 73 03 00 00       	push   $0x373
f01027e1:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f01027e7:	50                   	push   %eax
f01027e8:	e8 03 d9 ff ff       	call   f01000f0 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01027ed:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027f0:	8d 83 60 a6 f7 ff    	lea    -0x859a0(%ebx),%eax
f01027f6:	50                   	push   %eax
f01027f7:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f01027fd:	50                   	push   %eax
f01027fe:	68 77 03 00 00       	push   $0x377
f0102803:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0102809:	50                   	push   %eax
f010280a:	e8 e1 d8 ff ff       	call   f01000f0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010280f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102812:	8d 83 0c a6 f7 ff    	lea    -0x859f4(%ebx),%eax
f0102818:	50                   	push   %eax
f0102819:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f010281f:	50                   	push   %eax
f0102820:	68 78 03 00 00       	push   $0x378
f0102825:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f010282b:	50                   	push   %eax
f010282c:	e8 bf d8 ff ff       	call   f01000f0 <_panic>
	assert(pp1->pp_ref == 1);
f0102831:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102834:	8d 83 b5 aa f7 ff    	lea    -0x8554b(%ebx),%eax
f010283a:	50                   	push   %eax
f010283b:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0102841:	50                   	push   %eax
f0102842:	68 79 03 00 00       	push   $0x379
f0102847:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f010284d:	50                   	push   %eax
f010284e:	e8 9d d8 ff ff       	call   f01000f0 <_panic>
	assert(pp2->pp_ref == 0);
f0102853:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102856:	8d 83 0f ab f7 ff    	lea    -0x854f1(%ebx),%eax
f010285c:	50                   	push   %eax
f010285d:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0102863:	50                   	push   %eax
f0102864:	68 7a 03 00 00       	push   $0x37a
f0102869:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f010286f:	50                   	push   %eax
f0102870:	e8 7b d8 ff ff       	call   f01000f0 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102875:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102878:	8d 83 84 a6 f7 ff    	lea    -0x8597c(%ebx),%eax
f010287e:	50                   	push   %eax
f010287f:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0102885:	50                   	push   %eax
f0102886:	68 7d 03 00 00       	push   $0x37d
f010288b:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0102891:	50                   	push   %eax
f0102892:	e8 59 d8 ff ff       	call   f01000f0 <_panic>
	assert(pp1->pp_ref);
f0102897:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010289a:	8d 83 20 ab f7 ff    	lea    -0x854e0(%ebx),%eax
f01028a0:	50                   	push   %eax
f01028a1:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f01028a7:	50                   	push   %eax
f01028a8:	68 7e 03 00 00       	push   $0x37e
f01028ad:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f01028b3:	50                   	push   %eax
f01028b4:	e8 37 d8 ff ff       	call   f01000f0 <_panic>
	assert(pp1->pp_link == NULL);
f01028b9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028bc:	8d 83 2c ab f7 ff    	lea    -0x854d4(%ebx),%eax
f01028c2:	50                   	push   %eax
f01028c3:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f01028c9:	50                   	push   %eax
f01028ca:	68 7f 03 00 00       	push   $0x37f
f01028cf:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f01028d5:	50                   	push   %eax
f01028d6:	e8 15 d8 ff ff       	call   f01000f0 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01028db:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028de:	8d 83 60 a6 f7 ff    	lea    -0x859a0(%ebx),%eax
f01028e4:	50                   	push   %eax
f01028e5:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f01028eb:	50                   	push   %eax
f01028ec:	68 83 03 00 00       	push   $0x383
f01028f1:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f01028f7:	50                   	push   %eax
f01028f8:	e8 f3 d7 ff ff       	call   f01000f0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01028fd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102900:	8d 83 bc a6 f7 ff    	lea    -0x85944(%ebx),%eax
f0102906:	50                   	push   %eax
f0102907:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f010290d:	50                   	push   %eax
f010290e:	68 84 03 00 00       	push   $0x384
f0102913:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0102919:	50                   	push   %eax
f010291a:	e8 d1 d7 ff ff       	call   f01000f0 <_panic>
	assert(pp1->pp_ref == 0);
f010291f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102922:	8d 83 41 ab f7 ff    	lea    -0x854bf(%ebx),%eax
f0102928:	50                   	push   %eax
f0102929:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f010292f:	50                   	push   %eax
f0102930:	68 85 03 00 00       	push   $0x385
f0102935:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f010293b:	50                   	push   %eax
f010293c:	e8 af d7 ff ff       	call   f01000f0 <_panic>
	assert(pp2->pp_ref == 0);
f0102941:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102944:	8d 83 0f ab f7 ff    	lea    -0x854f1(%ebx),%eax
f010294a:	50                   	push   %eax
f010294b:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0102951:	50                   	push   %eax
f0102952:	68 86 03 00 00       	push   $0x386
f0102957:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f010295d:	50                   	push   %eax
f010295e:	e8 8d d7 ff ff       	call   f01000f0 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f0102963:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102966:	8d 83 e4 a6 f7 ff    	lea    -0x8591c(%ebx),%eax
f010296c:	50                   	push   %eax
f010296d:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0102973:	50                   	push   %eax
f0102974:	68 89 03 00 00       	push   $0x389
f0102979:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f010297f:	50                   	push   %eax
f0102980:	e8 6b d7 ff ff       	call   f01000f0 <_panic>
	assert(!page_alloc(0));
f0102985:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102988:	8d 83 63 aa f7 ff    	lea    -0x8559d(%ebx),%eax
f010298e:	50                   	push   %eax
f010298f:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0102995:	50                   	push   %eax
f0102996:	68 8c 03 00 00       	push   $0x38c
f010299b:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f01029a1:	50                   	push   %eax
f01029a2:	e8 49 d7 ff ff       	call   f01000f0 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01029a7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029aa:	8d 83 88 a3 f7 ff    	lea    -0x85c78(%ebx),%eax
f01029b0:	50                   	push   %eax
f01029b1:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f01029b7:	50                   	push   %eax
f01029b8:	68 8f 03 00 00       	push   $0x38f
f01029bd:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f01029c3:	50                   	push   %eax
f01029c4:	e8 27 d7 ff ff       	call   f01000f0 <_panic>
	assert(pp0->pp_ref == 1);
f01029c9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029cc:	8d 83 c6 aa f7 ff    	lea    -0x8553a(%ebx),%eax
f01029d2:	50                   	push   %eax
f01029d3:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f01029d9:	50                   	push   %eax
f01029da:	68 91 03 00 00       	push   $0x391
f01029df:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f01029e5:	50                   	push   %eax
f01029e6:	e8 05 d7 ff ff       	call   f01000f0 <_panic>
f01029eb:	52                   	push   %edx
f01029ec:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029ef:	8d 83 00 a1 f7 ff    	lea    -0x85f00(%ebx),%eax
f01029f5:	50                   	push   %eax
f01029f6:	68 98 03 00 00       	push   $0x398
f01029fb:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0102a01:	50                   	push   %eax
f0102a02:	e8 e9 d6 ff ff       	call   f01000f0 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102a07:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a0a:	8d 83 52 ab f7 ff    	lea    -0x854ae(%ebx),%eax
f0102a10:	50                   	push   %eax
f0102a11:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0102a17:	50                   	push   %eax
f0102a18:	68 99 03 00 00       	push   $0x399
f0102a1d:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0102a23:	50                   	push   %eax
f0102a24:	e8 c7 d6 ff ff       	call   f01000f0 <_panic>
f0102a29:	50                   	push   %eax
f0102a2a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a2d:	8d 83 00 a1 f7 ff    	lea    -0x85f00(%ebx),%eax
f0102a33:	50                   	push   %eax
f0102a34:	6a 56                	push   $0x56
f0102a36:	8d 83 d9 a8 f7 ff    	lea    -0x85727(%ebx),%eax
f0102a3c:	50                   	push   %eax
f0102a3d:	e8 ae d6 ff ff       	call   f01000f0 <_panic>
f0102a42:	52                   	push   %edx
f0102a43:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a46:	8d 83 00 a1 f7 ff    	lea    -0x85f00(%ebx),%eax
f0102a4c:	50                   	push   %eax
f0102a4d:	6a 56                	push   $0x56
f0102a4f:	8d 83 d9 a8 f7 ff    	lea    -0x85727(%ebx),%eax
f0102a55:	50                   	push   %eax
f0102a56:	e8 95 d6 ff ff       	call   f01000f0 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f0102a5b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a5e:	8d 83 6a ab f7 ff    	lea    -0x85496(%ebx),%eax
f0102a64:	50                   	push   %eax
f0102a65:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0102a6b:	50                   	push   %eax
f0102a6c:	68 a3 03 00 00       	push   $0x3a3
f0102a71:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0102a77:	50                   	push   %eax
f0102a78:	e8 73 d6 ff ff       	call   f01000f0 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a7d:	50                   	push   %eax
f0102a7e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a81:	8d 83 0c a2 f7 ff    	lea    -0x85df4(%ebx),%eax
f0102a87:	50                   	push   %eax
f0102a88:	68 b5 00 00 00       	push   $0xb5
f0102a8d:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0102a93:	50                   	push   %eax
f0102a94:	e8 57 d6 ff ff       	call   f01000f0 <_panic>
f0102a99:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a9c:	ff b3 fc ff ff ff    	pushl  -0x4(%ebx)
f0102aa2:	8d 83 0c a2 f7 ff    	lea    -0x85df4(%ebx),%eax
f0102aa8:	50                   	push   %eax
f0102aa9:	68 c9 00 00 00       	push   $0xc9
f0102aae:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0102ab4:	50                   	push   %eax
f0102ab5:	e8 36 d6 ff ff       	call   f01000f0 <_panic>
f0102aba:	ff 75 c0             	pushl  -0x40(%ebp)
f0102abd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ac0:	8d 83 0c a2 f7 ff    	lea    -0x85df4(%ebx),%eax
f0102ac6:	50                   	push   %eax
f0102ac7:	68 e0 02 00 00       	push   $0x2e0
f0102acc:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0102ad2:	50                   	push   %eax
f0102ad3:	e8 18 d6 ff ff       	call   f01000f0 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102ad8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102adb:	8d 83 08 a7 f7 ff    	lea    -0x858f8(%ebx),%eax
f0102ae1:	50                   	push   %eax
f0102ae2:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0102ae8:	50                   	push   %eax
f0102ae9:	68 e0 02 00 00       	push   $0x2e0
f0102aee:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0102af4:	50                   	push   %eax
f0102af5:	e8 f6 d5 ff ff       	call   f01000f0 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102afa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102afd:	c7 c0 44 d3 18 f0    	mov    $0xf018d344,%eax
f0102b03:	8b 00                	mov    (%eax),%eax
f0102b05:	89 45 cc             	mov    %eax,-0x34(%ebp)
	if ((uint32_t)kva < KERNBASE)
f0102b08:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102b0b:	bf 00 00 c0 ee       	mov    $0xeec00000,%edi
f0102b10:	8d 98 00 00 40 21    	lea    0x21400000(%eax),%ebx
f0102b16:	89 fa                	mov    %edi,%edx
f0102b18:	89 f0                	mov    %esi,%eax
f0102b1a:	e8 1c e0 ff ff       	call   f0100b3b <check_va2pa>
f0102b1f:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102b26:	76 22                	jbe    f0102b4a <mem_init+0x1741>
f0102b28:	8d 14 3b             	lea    (%ebx,%edi,1),%edx
f0102b2b:	39 d0                	cmp    %edx,%eax
f0102b2d:	75 39                	jne    f0102b68 <mem_init+0x175f>
f0102b2f:	81 c7 00 10 00 00    	add    $0x1000,%edi
	for (i = 0; i < n; i += PGSIZE)
f0102b35:	81 ff 00 80 c1 ee    	cmp    $0xeec18000,%edi
f0102b3b:	75 d9                	jne    f0102b16 <mem_init+0x170d>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102b3d:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0102b40:	c1 e7 0c             	shl    $0xc,%edi
f0102b43:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102b48:	eb 57                	jmp    f0102ba1 <mem_init+0x1798>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b4a:	ff 75 cc             	pushl  -0x34(%ebp)
f0102b4d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b50:	8d 83 0c a2 f7 ff    	lea    -0x85df4(%ebx),%eax
f0102b56:	50                   	push   %eax
f0102b57:	68 e5 02 00 00       	push   $0x2e5
f0102b5c:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0102b62:	50                   	push   %eax
f0102b63:	e8 88 d5 ff ff       	call   f01000f0 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102b68:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b6b:	8d 83 3c a7 f7 ff    	lea    -0x858c4(%ebx),%eax
f0102b71:	50                   	push   %eax
f0102b72:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0102b78:	50                   	push   %eax
f0102b79:	68 e5 02 00 00       	push   $0x2e5
f0102b7e:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0102b84:	50                   	push   %eax
f0102b85:	e8 66 d5 ff ff       	call   f01000f0 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102b8a:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102b90:	89 f0                	mov    %esi,%eax
f0102b92:	e8 a4 df ff ff       	call   f0100b3b <check_va2pa>
f0102b97:	39 c3                	cmp    %eax,%ebx
f0102b99:	75 51                	jne    f0102bec <mem_init+0x17e3>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102b9b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102ba1:	39 fb                	cmp    %edi,%ebx
f0102ba3:	72 e5                	jb     f0102b8a <mem_init+0x1781>
f0102ba5:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102baa:	8b 7d c8             	mov    -0x38(%ebp),%edi
f0102bad:	81 c7 00 80 00 20    	add    $0x20008000,%edi
f0102bb3:	89 da                	mov    %ebx,%edx
f0102bb5:	89 f0                	mov    %esi,%eax
f0102bb7:	e8 7f df ff ff       	call   f0100b3b <check_va2pa>
f0102bbc:	8d 14 1f             	lea    (%edi,%ebx,1),%edx
f0102bbf:	39 c2                	cmp    %eax,%edx
f0102bc1:	75 4b                	jne    f0102c0e <mem_init+0x1805>
f0102bc3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102bc9:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f0102bcf:	75 e2                	jne    f0102bb3 <mem_init+0x17aa>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102bd1:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102bd6:	89 f0                	mov    %esi,%eax
f0102bd8:	e8 5e df ff ff       	call   f0100b3b <check_va2pa>
f0102bdd:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102be0:	75 4e                	jne    f0102c30 <mem_init+0x1827>
	for (i = 0; i < NPDENTRIES; i++) {
f0102be2:	b8 00 00 00 00       	mov    $0x0,%eax
f0102be7:	e9 8f 00 00 00       	jmp    f0102c7b <mem_init+0x1872>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102bec:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102bef:	8d 83 70 a7 f7 ff    	lea    -0x85890(%ebx),%eax
f0102bf5:	50                   	push   %eax
f0102bf6:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0102bfc:	50                   	push   %eax
f0102bfd:	68 e9 02 00 00       	push   $0x2e9
f0102c02:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0102c08:	50                   	push   %eax
f0102c09:	e8 e2 d4 ff ff       	call   f01000f0 <_panic>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102c0e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c11:	8d 83 98 a7 f7 ff    	lea    -0x85868(%ebx),%eax
f0102c17:	50                   	push   %eax
f0102c18:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0102c1e:	50                   	push   %eax
f0102c1f:	68 ed 02 00 00       	push   $0x2ed
f0102c24:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0102c2a:	50                   	push   %eax
f0102c2b:	e8 c0 d4 ff ff       	call   f01000f0 <_panic>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102c30:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c33:	8d 83 e0 a7 f7 ff    	lea    -0x85820(%ebx),%eax
f0102c39:	50                   	push   %eax
f0102c3a:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0102c40:	50                   	push   %eax
f0102c41:	68 ee 02 00 00       	push   $0x2ee
f0102c46:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0102c4c:	50                   	push   %eax
f0102c4d:	e8 9e d4 ff ff       	call   f01000f0 <_panic>
			assert(pgdir[i] & PTE_P);
f0102c52:	f6 04 86 01          	testb  $0x1,(%esi,%eax,4)
f0102c56:	74 52                	je     f0102caa <mem_init+0x18a1>
	for (i = 0; i < NPDENTRIES; i++) {
f0102c58:	83 c0 01             	add    $0x1,%eax
f0102c5b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102c60:	0f 87 bb 00 00 00    	ja     f0102d21 <mem_init+0x1918>
		switch (i) {
f0102c66:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0102c6b:	72 0e                	jb     f0102c7b <mem_init+0x1872>
f0102c6d:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0102c72:	76 de                	jbe    f0102c52 <mem_init+0x1849>
f0102c74:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102c79:	74 d7                	je     f0102c52 <mem_init+0x1849>
			if (i >= PDX(KERNBASE)) {
f0102c7b:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102c80:	77 4a                	ja     f0102ccc <mem_init+0x18c3>
				assert(pgdir[i] == 0);
f0102c82:	83 3c 86 00          	cmpl   $0x0,(%esi,%eax,4)
f0102c86:	74 d0                	je     f0102c58 <mem_init+0x184f>
f0102c88:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c8b:	8d 83 bc ab f7 ff    	lea    -0x85444(%ebx),%eax
f0102c91:	50                   	push   %eax
f0102c92:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0102c98:	50                   	push   %eax
f0102c99:	68 fe 02 00 00       	push   $0x2fe
f0102c9e:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0102ca4:	50                   	push   %eax
f0102ca5:	e8 46 d4 ff ff       	call   f01000f0 <_panic>
			assert(pgdir[i] & PTE_P);
f0102caa:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102cad:	8d 83 9a ab f7 ff    	lea    -0x85466(%ebx),%eax
f0102cb3:	50                   	push   %eax
f0102cb4:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0102cba:	50                   	push   %eax
f0102cbb:	68 f7 02 00 00       	push   $0x2f7
f0102cc0:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0102cc6:	50                   	push   %eax
f0102cc7:	e8 24 d4 ff ff       	call   f01000f0 <_panic>
				assert(pgdir[i] & PTE_P);
f0102ccc:	8b 14 86             	mov    (%esi,%eax,4),%edx
f0102ccf:	f6 c2 01             	test   $0x1,%dl
f0102cd2:	74 2b                	je     f0102cff <mem_init+0x18f6>
				assert(pgdir[i] & PTE_W);
f0102cd4:	f6 c2 02             	test   $0x2,%dl
f0102cd7:	0f 85 7b ff ff ff    	jne    f0102c58 <mem_init+0x184f>
f0102cdd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ce0:	8d 83 ab ab f7 ff    	lea    -0x85455(%ebx),%eax
f0102ce6:	50                   	push   %eax
f0102ce7:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0102ced:	50                   	push   %eax
f0102cee:	68 fc 02 00 00       	push   $0x2fc
f0102cf3:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0102cf9:	50                   	push   %eax
f0102cfa:	e8 f1 d3 ff ff       	call   f01000f0 <_panic>
				assert(pgdir[i] & PTE_P);
f0102cff:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d02:	8d 83 9a ab f7 ff    	lea    -0x85466(%ebx),%eax
f0102d08:	50                   	push   %eax
f0102d09:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0102d0f:	50                   	push   %eax
f0102d10:	68 fb 02 00 00       	push   $0x2fb
f0102d15:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0102d1b:	50                   	push   %eax
f0102d1c:	e8 cf d3 ff ff       	call   f01000f0 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102d21:	83 ec 0c             	sub    $0xc,%esp
f0102d24:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102d27:	8d 87 10 a8 f7 ff    	lea    -0x857f0(%edi),%eax
f0102d2d:	50                   	push   %eax
f0102d2e:	89 fb                	mov    %edi,%ebx
f0102d30:	e8 a1 09 00 00       	call   f01036d6 <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102d35:	c7 c0 0c e0 18 f0    	mov    $0xf018e00c,%eax
f0102d3b:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0102d3d:	83 c4 10             	add    $0x10,%esp
f0102d40:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102d45:	0f 86 44 02 00 00    	jbe    f0102f8f <mem_init+0x1b86>
	return (physaddr_t)kva - KERNBASE;
f0102d4b:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102d50:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102d53:	b8 00 00 00 00       	mov    $0x0,%eax
f0102d58:	e8 5b de ff ff       	call   f0100bb8 <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102d5d:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102d60:	83 e0 f3             	and    $0xfffffff3,%eax
f0102d63:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102d68:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102d6b:	83 ec 0c             	sub    $0xc,%esp
f0102d6e:	6a 00                	push   $0x0
f0102d70:	e8 b7 e2 ff ff       	call   f010102c <page_alloc>
f0102d75:	89 c6                	mov    %eax,%esi
f0102d77:	83 c4 10             	add    $0x10,%esp
f0102d7a:	85 c0                	test   %eax,%eax
f0102d7c:	0f 84 29 02 00 00    	je     f0102fab <mem_init+0x1ba2>
	assert((pp1 = page_alloc(0)));
f0102d82:	83 ec 0c             	sub    $0xc,%esp
f0102d85:	6a 00                	push   $0x0
f0102d87:	e8 a0 e2 ff ff       	call   f010102c <page_alloc>
f0102d8c:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102d8f:	83 c4 10             	add    $0x10,%esp
f0102d92:	85 c0                	test   %eax,%eax
f0102d94:	0f 84 33 02 00 00    	je     f0102fcd <mem_init+0x1bc4>
	assert((pp2 = page_alloc(0)));
f0102d9a:	83 ec 0c             	sub    $0xc,%esp
f0102d9d:	6a 00                	push   $0x0
f0102d9f:	e8 88 e2 ff ff       	call   f010102c <page_alloc>
f0102da4:	89 c7                	mov    %eax,%edi
f0102da6:	83 c4 10             	add    $0x10,%esp
f0102da9:	85 c0                	test   %eax,%eax
f0102dab:	0f 84 3e 02 00 00    	je     f0102fef <mem_init+0x1be6>
	page_free(pp0);
f0102db1:	83 ec 0c             	sub    $0xc,%esp
f0102db4:	56                   	push   %esi
f0102db5:	e8 fa e2 ff ff       	call   f01010b4 <page_free>
	return (pp - pages) << PGSHIFT;
f0102dba:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102dbd:	c7 c0 10 e0 18 f0    	mov    $0xf018e010,%eax
f0102dc3:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102dc6:	2b 08                	sub    (%eax),%ecx
f0102dc8:	89 c8                	mov    %ecx,%eax
f0102dca:	c1 f8 03             	sar    $0x3,%eax
f0102dcd:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102dd0:	89 c1                	mov    %eax,%ecx
f0102dd2:	c1 e9 0c             	shr    $0xc,%ecx
f0102dd5:	83 c4 10             	add    $0x10,%esp
f0102dd8:	c7 c2 08 e0 18 f0    	mov    $0xf018e008,%edx
f0102dde:	3b 0a                	cmp    (%edx),%ecx
f0102de0:	0f 83 2b 02 00 00    	jae    f0103011 <mem_init+0x1c08>
	memset(page2kva(pp1), 1, PGSIZE);
f0102de6:	83 ec 04             	sub    $0x4,%esp
f0102de9:	68 00 10 00 00       	push   $0x1000
f0102dee:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102df0:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102df5:	50                   	push   %eax
f0102df6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102df9:	e8 89 19 00 00       	call   f0104787 <memset>
	return (pp - pages) << PGSHIFT;
f0102dfe:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e01:	c7 c0 10 e0 18 f0    	mov    $0xf018e010,%eax
f0102e07:	89 f9                	mov    %edi,%ecx
f0102e09:	2b 08                	sub    (%eax),%ecx
f0102e0b:	89 c8                	mov    %ecx,%eax
f0102e0d:	c1 f8 03             	sar    $0x3,%eax
f0102e10:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102e13:	89 c1                	mov    %eax,%ecx
f0102e15:	c1 e9 0c             	shr    $0xc,%ecx
f0102e18:	83 c4 10             	add    $0x10,%esp
f0102e1b:	c7 c2 08 e0 18 f0    	mov    $0xf018e008,%edx
f0102e21:	3b 0a                	cmp    (%edx),%ecx
f0102e23:	0f 83 fe 01 00 00    	jae    f0103027 <mem_init+0x1c1e>
	memset(page2kva(pp2), 2, PGSIZE);
f0102e29:	83 ec 04             	sub    $0x4,%esp
f0102e2c:	68 00 10 00 00       	push   $0x1000
f0102e31:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102e33:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102e38:	50                   	push   %eax
f0102e39:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e3c:	e8 46 19 00 00       	call   f0104787 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102e41:	6a 02                	push   $0x2
f0102e43:	68 00 10 00 00       	push   $0x1000
f0102e48:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0102e4b:	53                   	push   %ebx
f0102e4c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102e4f:	c7 c0 0c e0 18 f0    	mov    $0xf018e00c,%eax
f0102e55:	ff 30                	pushl  (%eax)
f0102e57:	e8 35 e5 ff ff       	call   f0101391 <page_insert>
	assert(pp1->pp_ref == 1);
f0102e5c:	83 c4 20             	add    $0x20,%esp
f0102e5f:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102e64:	0f 85 d3 01 00 00    	jne    f010303d <mem_init+0x1c34>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102e6a:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102e71:	01 01 01 
f0102e74:	0f 85 e5 01 00 00    	jne    f010305f <mem_init+0x1c56>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102e7a:	6a 02                	push   $0x2
f0102e7c:	68 00 10 00 00       	push   $0x1000
f0102e81:	57                   	push   %edi
f0102e82:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102e85:	c7 c0 0c e0 18 f0    	mov    $0xf018e00c,%eax
f0102e8b:	ff 30                	pushl  (%eax)
f0102e8d:	e8 ff e4 ff ff       	call   f0101391 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102e92:	83 c4 10             	add    $0x10,%esp
f0102e95:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102e9c:	02 02 02 
f0102e9f:	0f 85 dc 01 00 00    	jne    f0103081 <mem_init+0x1c78>
	assert(pp2->pp_ref == 1);
f0102ea5:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102eaa:	0f 85 f3 01 00 00    	jne    f01030a3 <mem_init+0x1c9a>
	assert(pp1->pp_ref == 0);
f0102eb0:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102eb3:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0102eb8:	0f 85 07 02 00 00    	jne    f01030c5 <mem_init+0x1cbc>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102ebe:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102ec5:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0102ec8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ecb:	c7 c0 10 e0 18 f0    	mov    $0xf018e010,%eax
f0102ed1:	89 f9                	mov    %edi,%ecx
f0102ed3:	2b 08                	sub    (%eax),%ecx
f0102ed5:	89 c8                	mov    %ecx,%eax
f0102ed7:	c1 f8 03             	sar    $0x3,%eax
f0102eda:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102edd:	89 c1                	mov    %eax,%ecx
f0102edf:	c1 e9 0c             	shr    $0xc,%ecx
f0102ee2:	c7 c2 08 e0 18 f0    	mov    $0xf018e008,%edx
f0102ee8:	3b 0a                	cmp    (%edx),%ecx
f0102eea:	0f 83 f7 01 00 00    	jae    f01030e7 <mem_init+0x1cde>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102ef0:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102ef7:	03 03 03 
f0102efa:	0f 85 fd 01 00 00    	jne    f01030fd <mem_init+0x1cf4>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102f00:	83 ec 08             	sub    $0x8,%esp
f0102f03:	68 00 10 00 00       	push   $0x1000
f0102f08:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102f0b:	c7 c0 0c e0 18 f0    	mov    $0xf018e00c,%eax
f0102f11:	ff 30                	pushl  (%eax)
f0102f13:	e8 3c e4 ff ff       	call   f0101354 <page_remove>
	assert(pp2->pp_ref == 0);
f0102f18:	83 c4 10             	add    $0x10,%esp
f0102f1b:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102f20:	0f 85 f9 01 00 00    	jne    f010311f <mem_init+0x1d16>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102f26:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102f29:	c7 c0 0c e0 18 f0    	mov    $0xf018e00c,%eax
f0102f2f:	8b 08                	mov    (%eax),%ecx
f0102f31:	8b 11                	mov    (%ecx),%edx
f0102f33:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0102f39:	c7 c0 10 e0 18 f0    	mov    $0xf018e010,%eax
f0102f3f:	89 f7                	mov    %esi,%edi
f0102f41:	2b 38                	sub    (%eax),%edi
f0102f43:	89 f8                	mov    %edi,%eax
f0102f45:	c1 f8 03             	sar    $0x3,%eax
f0102f48:	c1 e0 0c             	shl    $0xc,%eax
f0102f4b:	39 c2                	cmp    %eax,%edx
f0102f4d:	0f 85 ee 01 00 00    	jne    f0103141 <mem_init+0x1d38>
	kern_pgdir[0] = 0;
f0102f53:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102f59:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102f5e:	0f 85 ff 01 00 00    	jne    f0103163 <mem_init+0x1d5a>
	pp0->pp_ref = 0;
f0102f64:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102f6a:	83 ec 0c             	sub    $0xc,%esp
f0102f6d:	56                   	push   %esi
f0102f6e:	e8 41 e1 ff ff       	call   f01010b4 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102f73:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f76:	8d 83 a4 a8 f7 ff    	lea    -0x8575c(%ebx),%eax
f0102f7c:	89 04 24             	mov    %eax,(%esp)
f0102f7f:	e8 52 07 00 00       	call   f01036d6 <cprintf>
}
f0102f84:	83 c4 10             	add    $0x10,%esp
f0102f87:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f8a:	5b                   	pop    %ebx
f0102f8b:	5e                   	pop    %esi
f0102f8c:	5f                   	pop    %edi
f0102f8d:	5d                   	pop    %ebp
f0102f8e:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102f8f:	50                   	push   %eax
f0102f90:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f93:	8d 83 0c a2 f7 ff    	lea    -0x85df4(%ebx),%eax
f0102f99:	50                   	push   %eax
f0102f9a:	68 dd 00 00 00       	push   $0xdd
f0102f9f:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0102fa5:	50                   	push   %eax
f0102fa6:	e8 45 d1 ff ff       	call   f01000f0 <_panic>
	assert((pp0 = page_alloc(0)));
f0102fab:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102fae:	8d 83 b8 a9 f7 ff    	lea    -0x85648(%ebx),%eax
f0102fb4:	50                   	push   %eax
f0102fb5:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0102fbb:	50                   	push   %eax
f0102fbc:	68 be 03 00 00       	push   $0x3be
f0102fc1:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0102fc7:	50                   	push   %eax
f0102fc8:	e8 23 d1 ff ff       	call   f01000f0 <_panic>
	assert((pp1 = page_alloc(0)));
f0102fcd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102fd0:	8d 83 ce a9 f7 ff    	lea    -0x85632(%ebx),%eax
f0102fd6:	50                   	push   %eax
f0102fd7:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0102fdd:	50                   	push   %eax
f0102fde:	68 bf 03 00 00       	push   $0x3bf
f0102fe3:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0102fe9:	50                   	push   %eax
f0102fea:	e8 01 d1 ff ff       	call   f01000f0 <_panic>
	assert((pp2 = page_alloc(0)));
f0102fef:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ff2:	8d 83 e4 a9 f7 ff    	lea    -0x8561c(%ebx),%eax
f0102ff8:	50                   	push   %eax
f0102ff9:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0102fff:	50                   	push   %eax
f0103000:	68 c0 03 00 00       	push   $0x3c0
f0103005:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f010300b:	50                   	push   %eax
f010300c:	e8 df d0 ff ff       	call   f01000f0 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103011:	50                   	push   %eax
f0103012:	8d 83 00 a1 f7 ff    	lea    -0x85f00(%ebx),%eax
f0103018:	50                   	push   %eax
f0103019:	6a 56                	push   $0x56
f010301b:	8d 83 d9 a8 f7 ff    	lea    -0x85727(%ebx),%eax
f0103021:	50                   	push   %eax
f0103022:	e8 c9 d0 ff ff       	call   f01000f0 <_panic>
f0103027:	50                   	push   %eax
f0103028:	8d 83 00 a1 f7 ff    	lea    -0x85f00(%ebx),%eax
f010302e:	50                   	push   %eax
f010302f:	6a 56                	push   $0x56
f0103031:	8d 83 d9 a8 f7 ff    	lea    -0x85727(%ebx),%eax
f0103037:	50                   	push   %eax
f0103038:	e8 b3 d0 ff ff       	call   f01000f0 <_panic>
	assert(pp1->pp_ref == 1);
f010303d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103040:	8d 83 b5 aa f7 ff    	lea    -0x8554b(%ebx),%eax
f0103046:	50                   	push   %eax
f0103047:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f010304d:	50                   	push   %eax
f010304e:	68 c5 03 00 00       	push   $0x3c5
f0103053:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0103059:	50                   	push   %eax
f010305a:	e8 91 d0 ff ff       	call   f01000f0 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f010305f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103062:	8d 83 30 a8 f7 ff    	lea    -0x857d0(%ebx),%eax
f0103068:	50                   	push   %eax
f0103069:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f010306f:	50                   	push   %eax
f0103070:	68 c6 03 00 00       	push   $0x3c6
f0103075:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f010307b:	50                   	push   %eax
f010307c:	e8 6f d0 ff ff       	call   f01000f0 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0103081:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103084:	8d 83 54 a8 f7 ff    	lea    -0x857ac(%ebx),%eax
f010308a:	50                   	push   %eax
f010308b:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0103091:	50                   	push   %eax
f0103092:	68 c8 03 00 00       	push   $0x3c8
f0103097:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f010309d:	50                   	push   %eax
f010309e:	e8 4d d0 ff ff       	call   f01000f0 <_panic>
	assert(pp2->pp_ref == 1);
f01030a3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01030a6:	8d 83 d7 aa f7 ff    	lea    -0x85529(%ebx),%eax
f01030ac:	50                   	push   %eax
f01030ad:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f01030b3:	50                   	push   %eax
f01030b4:	68 c9 03 00 00       	push   $0x3c9
f01030b9:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f01030bf:	50                   	push   %eax
f01030c0:	e8 2b d0 ff ff       	call   f01000f0 <_panic>
	assert(pp1->pp_ref == 0);
f01030c5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01030c8:	8d 83 41 ab f7 ff    	lea    -0x854bf(%ebx),%eax
f01030ce:	50                   	push   %eax
f01030cf:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f01030d5:	50                   	push   %eax
f01030d6:	68 ca 03 00 00       	push   $0x3ca
f01030db:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f01030e1:	50                   	push   %eax
f01030e2:	e8 09 d0 ff ff       	call   f01000f0 <_panic>
f01030e7:	50                   	push   %eax
f01030e8:	8d 83 00 a1 f7 ff    	lea    -0x85f00(%ebx),%eax
f01030ee:	50                   	push   %eax
f01030ef:	6a 56                	push   $0x56
f01030f1:	8d 83 d9 a8 f7 ff    	lea    -0x85727(%ebx),%eax
f01030f7:	50                   	push   %eax
f01030f8:	e8 f3 cf ff ff       	call   f01000f0 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01030fd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103100:	8d 83 78 a8 f7 ff    	lea    -0x85788(%ebx),%eax
f0103106:	50                   	push   %eax
f0103107:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f010310d:	50                   	push   %eax
f010310e:	68 cc 03 00 00       	push   $0x3cc
f0103113:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f0103119:	50                   	push   %eax
f010311a:	e8 d1 cf ff ff       	call   f01000f0 <_panic>
	assert(pp2->pp_ref == 0);
f010311f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103122:	8d 83 0f ab f7 ff    	lea    -0x854f1(%ebx),%eax
f0103128:	50                   	push   %eax
f0103129:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f010312f:	50                   	push   %eax
f0103130:	68 ce 03 00 00       	push   $0x3ce
f0103135:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f010313b:	50                   	push   %eax
f010313c:	e8 af cf ff ff       	call   f01000f0 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103141:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103144:	8d 83 88 a3 f7 ff    	lea    -0x85c78(%ebx),%eax
f010314a:	50                   	push   %eax
f010314b:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0103151:	50                   	push   %eax
f0103152:	68 d1 03 00 00       	push   $0x3d1
f0103157:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f010315d:	50                   	push   %eax
f010315e:	e8 8d cf ff ff       	call   f01000f0 <_panic>
	assert(pp0->pp_ref == 1);
f0103163:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103166:	8d 83 c6 aa f7 ff    	lea    -0x8553a(%ebx),%eax
f010316c:	50                   	push   %eax
f010316d:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0103173:	50                   	push   %eax
f0103174:	68 d3 03 00 00       	push   $0x3d3
f0103179:	8d 83 cd a8 f7 ff    	lea    -0x85733(%ebx),%eax
f010317f:	50                   	push   %eax
f0103180:	e8 6b cf ff ff       	call   f01000f0 <_panic>

f0103185 <tlb_invalidate>:
{
f0103185:	55                   	push   %ebp
f0103186:	89 e5                	mov    %esp,%ebp
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0103188:	8b 45 0c             	mov    0xc(%ebp),%eax
f010318b:	0f 01 38             	invlpg (%eax)
}
f010318e:	5d                   	pop    %ebp
f010318f:	c3                   	ret    

f0103190 <user_mem_check>:
{
f0103190:	55                   	push   %ebp
f0103191:	89 e5                	mov    %esp,%ebp
}
f0103193:	b8 00 00 00 00       	mov    $0x0,%eax
f0103198:	5d                   	pop    %ebp
f0103199:	c3                   	ret    

f010319a <user_mem_assert>:
{
f010319a:	55                   	push   %ebp
f010319b:	89 e5                	mov    %esp,%ebp
}
f010319d:	5d                   	pop    %ebp
f010319e:	c3                   	ret    

f010319f <__x86.get_pc_thunk.dx>:
f010319f:	8b 14 24             	mov    (%esp),%edx
f01031a2:	c3                   	ret    

f01031a3 <__x86.get_pc_thunk.cx>:
f01031a3:	8b 0c 24             	mov    (%esp),%ecx
f01031a6:	c3                   	ret    

f01031a7 <__x86.get_pc_thunk.di>:
f01031a7:	8b 3c 24             	mov    (%esp),%edi
f01031aa:	c3                   	ret    

f01031ab <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f01031ab:	55                   	push   %ebp
f01031ac:	89 e5                	mov    %esp,%ebp
f01031ae:	53                   	push   %ebx
f01031af:	e8 ef ff ff ff       	call   f01031a3 <__x86.get_pc_thunk.cx>
f01031b4:	81 c1 6c 7e 08 00    	add    $0x87e6c,%ecx
f01031ba:	8b 55 08             	mov    0x8(%ebp),%edx
f01031bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f01031c0:	85 d2                	test   %edx,%edx
f01031c2:	74 41                	je     f0103205 <envid2env+0x5a>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f01031c4:	89 d0                	mov    %edx,%eax
f01031c6:	25 ff 03 00 00       	and    $0x3ff,%eax
f01031cb:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01031ce:	c1 e0 05             	shl    $0x5,%eax
f01031d1:	03 81 24 23 00 00    	add    0x2324(%ecx),%eax
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01031d7:	83 78 54 00          	cmpl   $0x0,0x54(%eax)
f01031db:	74 3a                	je     f0103217 <envid2env+0x6c>
f01031dd:	39 50 48             	cmp    %edx,0x48(%eax)
f01031e0:	75 35                	jne    f0103217 <envid2env+0x6c>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01031e2:	84 db                	test   %bl,%bl
f01031e4:	74 12                	je     f01031f8 <envid2env+0x4d>
f01031e6:	8b 91 20 23 00 00    	mov    0x2320(%ecx),%edx
f01031ec:	39 c2                	cmp    %eax,%edx
f01031ee:	74 08                	je     f01031f8 <envid2env+0x4d>
f01031f0:	8b 5a 48             	mov    0x48(%edx),%ebx
f01031f3:	39 58 4c             	cmp    %ebx,0x4c(%eax)
f01031f6:	75 2f                	jne    f0103227 <envid2env+0x7c>
		*env_store = 0;
		return -E_BAD_ENV;
	}

	*env_store = e;
f01031f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01031fb:	89 03                	mov    %eax,(%ebx)
	return 0;
f01031fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103202:	5b                   	pop    %ebx
f0103203:	5d                   	pop    %ebp
f0103204:	c3                   	ret    
		*env_store = curenv;
f0103205:	8b 81 20 23 00 00    	mov    0x2320(%ecx),%eax
f010320b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010320e:	89 01                	mov    %eax,(%ecx)
		return 0;
f0103210:	b8 00 00 00 00       	mov    $0x0,%eax
f0103215:	eb eb                	jmp    f0103202 <envid2env+0x57>
		*env_store = 0;
f0103217:	8b 45 0c             	mov    0xc(%ebp),%eax
f010321a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103220:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103225:	eb db                	jmp    f0103202 <envid2env+0x57>
		*env_store = 0;
f0103227:	8b 45 0c             	mov    0xc(%ebp),%eax
f010322a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103230:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103235:	eb cb                	jmp    f0103202 <envid2env+0x57>

f0103237 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0103237:	55                   	push   %ebp
f0103238:	89 e5                	mov    %esp,%ebp
f010323a:	e8 09 d5 ff ff       	call   f0100748 <__x86.get_pc_thunk.ax>
f010323f:	05 e1 7d 08 00       	add    $0x87de1,%eax
	asm volatile("lgdt (%0)" : : "r" (p));
f0103244:	8d 80 e0 1f 00 00    	lea    0x1fe0(%eax),%eax
f010324a:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f010324d:	b8 23 00 00 00       	mov    $0x23,%eax
f0103252:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0103254:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0103256:	b8 10 00 00 00       	mov    $0x10,%eax
f010325b:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f010325d:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f010325f:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0103261:	ea 68 32 10 f0 08 00 	ljmp   $0x8,$0xf0103268
	asm volatile("lldt %0" : : "r" (sel));
f0103268:	b8 00 00 00 00       	mov    $0x0,%eax
f010326d:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0103270:	5d                   	pop    %ebp
f0103271:	c3                   	ret    

f0103272 <env_init>:
{
f0103272:	55                   	push   %ebp
f0103273:	89 e5                	mov    %esp,%ebp
	env_init_percpu();
f0103275:	e8 bd ff ff ff       	call   f0103237 <env_init_percpu>
}
f010327a:	5d                   	pop    %ebp
f010327b:	c3                   	ret    

f010327c <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f010327c:	55                   	push   %ebp
f010327d:	89 e5                	mov    %esp,%ebp
f010327f:	56                   	push   %esi
f0103280:	53                   	push   %ebx
f0103281:	e8 20 cf ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f0103286:	81 c3 9a 7d 08 00    	add    $0x87d9a,%ebx
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f010328c:	8b b3 28 23 00 00    	mov    0x2328(%ebx),%esi
f0103292:	85 f6                	test   %esi,%esi
f0103294:	0f 84 03 01 00 00    	je     f010339d <env_alloc+0x121>
	if (!(p = page_alloc(ALLOC_ZERO)))
f010329a:	83 ec 0c             	sub    $0xc,%esp
f010329d:	6a 01                	push   $0x1
f010329f:	e8 88 dd ff ff       	call   f010102c <page_alloc>
f01032a4:	83 c4 10             	add    $0x10,%esp
f01032a7:	85 c0                	test   %eax,%eax
f01032a9:	0f 84 f5 00 00 00    	je     f01033a4 <env_alloc+0x128>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01032af:	8b 46 5c             	mov    0x5c(%esi),%eax
	if ((uint32_t)kva < KERNBASE)
f01032b2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01032b7:	0f 86 c7 00 00 00    	jbe    f0103384 <env_alloc+0x108>
	return (physaddr_t)kva - KERNBASE;
f01032bd:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01032c3:	83 ca 05             	or     $0x5,%edx
f01032c6:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01032cc:	8b 46 48             	mov    0x48(%esi),%eax
f01032cf:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f01032d4:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f01032d9:	ba 00 10 00 00       	mov    $0x1000,%edx
f01032de:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f01032e1:	89 f2                	mov    %esi,%edx
f01032e3:	2b 93 24 23 00 00    	sub    0x2324(%ebx),%edx
f01032e9:	c1 fa 05             	sar    $0x5,%edx
f01032ec:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f01032f2:	09 d0                	or     %edx,%eax
f01032f4:	89 46 48             	mov    %eax,0x48(%esi)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f01032f7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01032fa:	89 46 4c             	mov    %eax,0x4c(%esi)
	e->env_type = ENV_TYPE_USER;
f01032fd:	c7 46 50 00 00 00 00 	movl   $0x0,0x50(%esi)
	e->env_status = ENV_RUNNABLE;
f0103304:	c7 46 54 02 00 00 00 	movl   $0x2,0x54(%esi)
	e->env_runs = 0;
f010330b:	c7 46 58 00 00 00 00 	movl   $0x0,0x58(%esi)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103312:	83 ec 04             	sub    $0x4,%esp
f0103315:	6a 44                	push   $0x44
f0103317:	6a 00                	push   $0x0
f0103319:	56                   	push   %esi
f010331a:	e8 68 14 00 00       	call   f0104787 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f010331f:	66 c7 46 24 23 00    	movw   $0x23,0x24(%esi)
	e->env_tf.tf_es = GD_UD | 3;
f0103325:	66 c7 46 20 23 00    	movw   $0x23,0x20(%esi)
	e->env_tf.tf_ss = GD_UD | 3;
f010332b:	66 c7 46 40 23 00    	movw   $0x23,0x40(%esi)
	e->env_tf.tf_esp = USTACKTOP;
f0103331:	c7 46 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%esi)
	e->env_tf.tf_cs = GD_UT | 3;
f0103338:	66 c7 46 34 1b 00    	movw   $0x1b,0x34(%esi)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f010333e:	8b 46 44             	mov    0x44(%esi),%eax
f0103341:	89 83 28 23 00 00    	mov    %eax,0x2328(%ebx)
	*newenv_store = e;
f0103347:	8b 45 08             	mov    0x8(%ebp),%eax
f010334a:	89 30                	mov    %esi,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010334c:	8b 4e 48             	mov    0x48(%esi),%ecx
f010334f:	8b 83 20 23 00 00    	mov    0x2320(%ebx),%eax
f0103355:	83 c4 10             	add    $0x10,%esp
f0103358:	ba 00 00 00 00       	mov    $0x0,%edx
f010335d:	85 c0                	test   %eax,%eax
f010335f:	74 03                	je     f0103364 <env_alloc+0xe8>
f0103361:	8b 50 48             	mov    0x48(%eax),%edx
f0103364:	83 ec 04             	sub    $0x4,%esp
f0103367:	51                   	push   %ecx
f0103368:	52                   	push   %edx
f0103369:	8d 83 0d ac f7 ff    	lea    -0x853f3(%ebx),%eax
f010336f:	50                   	push   %eax
f0103370:	e8 61 03 00 00       	call   f01036d6 <cprintf>
	return 0;
f0103375:	83 c4 10             	add    $0x10,%esp
f0103378:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010337d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103380:	5b                   	pop    %ebx
f0103381:	5e                   	pop    %esi
f0103382:	5d                   	pop    %ebp
f0103383:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103384:	50                   	push   %eax
f0103385:	8d 83 0c a2 f7 ff    	lea    -0x85df4(%ebx),%eax
f010338b:	50                   	push   %eax
f010338c:	68 b9 00 00 00       	push   $0xb9
f0103391:	8d 83 02 ac f7 ff    	lea    -0x853fe(%ebx),%eax
f0103397:	50                   	push   %eax
f0103398:	e8 53 cd ff ff       	call   f01000f0 <_panic>
		return -E_NO_FREE_ENV;
f010339d:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01033a2:	eb d9                	jmp    f010337d <env_alloc+0x101>
		return -E_NO_MEM;
f01033a4:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01033a9:	eb d2                	jmp    f010337d <env_alloc+0x101>

f01033ab <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f01033ab:	55                   	push   %ebp
f01033ac:	89 e5                	mov    %esp,%ebp
	// LAB 3: Your code here.
}
f01033ae:	5d                   	pop    %ebp
f01033af:	c3                   	ret    

f01033b0 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01033b0:	55                   	push   %ebp
f01033b1:	89 e5                	mov    %esp,%ebp
f01033b3:	57                   	push   %edi
f01033b4:	56                   	push   %esi
f01033b5:	53                   	push   %ebx
f01033b6:	83 ec 2c             	sub    $0x2c,%esp
f01033b9:	e8 e8 cd ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f01033be:	81 c3 62 7c 08 00    	add    $0x87c62,%ebx
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01033c4:	8b 93 20 23 00 00    	mov    0x2320(%ebx),%edx
f01033ca:	3b 55 08             	cmp    0x8(%ebp),%edx
f01033cd:	75 17                	jne    f01033e6 <env_free+0x36>
		lcr3(PADDR(kern_pgdir));
f01033cf:	c7 c0 0c e0 18 f0    	mov    $0xf018e00c,%eax
f01033d5:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f01033d7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01033dc:	76 46                	jbe    f0103424 <env_free+0x74>
	return (physaddr_t)kva - KERNBASE;
f01033de:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01033e3:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01033e6:	8b 45 08             	mov    0x8(%ebp),%eax
f01033e9:	8b 48 48             	mov    0x48(%eax),%ecx
f01033ec:	b8 00 00 00 00       	mov    $0x0,%eax
f01033f1:	85 d2                	test   %edx,%edx
f01033f3:	74 03                	je     f01033f8 <env_free+0x48>
f01033f5:	8b 42 48             	mov    0x48(%edx),%eax
f01033f8:	83 ec 04             	sub    $0x4,%esp
f01033fb:	51                   	push   %ecx
f01033fc:	50                   	push   %eax
f01033fd:	8d 83 22 ac f7 ff    	lea    -0x853de(%ebx),%eax
f0103403:	50                   	push   %eax
f0103404:	e8 cd 02 00 00       	call   f01036d6 <cprintf>
f0103409:	83 c4 10             	add    $0x10,%esp
f010340c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	if (PGNUM(pa) >= npages)
f0103413:	c7 c0 08 e0 18 f0    	mov    $0xf018e008,%eax
f0103419:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	if (PGNUM(pa) >= npages)
f010341c:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010341f:	e9 9f 00 00 00       	jmp    f01034c3 <env_free+0x113>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103424:	50                   	push   %eax
f0103425:	8d 83 0c a2 f7 ff    	lea    -0x85df4(%ebx),%eax
f010342b:	50                   	push   %eax
f010342c:	68 68 01 00 00       	push   $0x168
f0103431:	8d 83 02 ac f7 ff    	lea    -0x853fe(%ebx),%eax
f0103437:	50                   	push   %eax
f0103438:	e8 b3 cc ff ff       	call   f01000f0 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010343d:	50                   	push   %eax
f010343e:	8d 83 00 a1 f7 ff    	lea    -0x85f00(%ebx),%eax
f0103444:	50                   	push   %eax
f0103445:	68 77 01 00 00       	push   $0x177
f010344a:	8d 83 02 ac f7 ff    	lea    -0x853fe(%ebx),%eax
f0103450:	50                   	push   %eax
f0103451:	e8 9a cc ff ff       	call   f01000f0 <_panic>
f0103456:	83 c6 04             	add    $0x4,%esi
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103459:	39 fe                	cmp    %edi,%esi
f010345b:	74 24                	je     f0103481 <env_free+0xd1>
			if (pt[pteno] & PTE_P)
f010345d:	f6 06 01             	testb  $0x1,(%esi)
f0103460:	74 f4                	je     f0103456 <env_free+0xa6>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103462:	83 ec 08             	sub    $0x8,%esp
f0103465:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103468:	01 f0                	add    %esi,%eax
f010346a:	c1 e0 0a             	shl    $0xa,%eax
f010346d:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103470:	50                   	push   %eax
f0103471:	8b 45 08             	mov    0x8(%ebp),%eax
f0103474:	ff 70 5c             	pushl  0x5c(%eax)
f0103477:	e8 d8 de ff ff       	call   f0101354 <page_remove>
f010347c:	83 c4 10             	add    $0x10,%esp
f010347f:	eb d5                	jmp    f0103456 <env_free+0xa6>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103481:	8b 45 08             	mov    0x8(%ebp),%eax
f0103484:	8b 40 5c             	mov    0x5c(%eax),%eax
f0103487:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010348a:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f0103491:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103494:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103497:	3b 10                	cmp    (%eax),%edx
f0103499:	73 6f                	jae    f010350a <env_free+0x15a>
		page_decref(pa2page(pa));
f010349b:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f010349e:	c7 c0 10 e0 18 f0    	mov    $0xf018e010,%eax
f01034a4:	8b 00                	mov    (%eax),%eax
f01034a6:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01034a9:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f01034ac:	50                   	push   %eax
f01034ad:	e8 51 dc ff ff       	call   f0101103 <page_decref>
f01034b2:	83 c4 10             	add    $0x10,%esp
f01034b5:	83 45 dc 04          	addl   $0x4,-0x24(%ebp)
f01034b9:	8b 45 dc             	mov    -0x24(%ebp),%eax
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01034bc:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f01034c1:	74 5f                	je     f0103522 <env_free+0x172>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01034c3:	8b 45 08             	mov    0x8(%ebp),%eax
f01034c6:	8b 40 5c             	mov    0x5c(%eax),%eax
f01034c9:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01034cc:	8b 04 10             	mov    (%eax,%edx,1),%eax
f01034cf:	a8 01                	test   $0x1,%al
f01034d1:	74 e2                	je     f01034b5 <env_free+0x105>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01034d3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f01034d8:	89 c2                	mov    %eax,%edx
f01034da:	c1 ea 0c             	shr    $0xc,%edx
f01034dd:	89 55 d8             	mov    %edx,-0x28(%ebp)
f01034e0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01034e3:	39 11                	cmp    %edx,(%ecx)
f01034e5:	0f 86 52 ff ff ff    	jbe    f010343d <env_free+0x8d>
	return (void *)(pa + KERNBASE);
f01034eb:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01034f1:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01034f4:	c1 e2 14             	shl    $0x14,%edx
f01034f7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01034fa:	8d b8 00 10 00 f0    	lea    -0xffff000(%eax),%edi
f0103500:	f7 d8                	neg    %eax
f0103502:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103505:	e9 53 ff ff ff       	jmp    f010345d <env_free+0xad>
		panic("pa2page called with invalid pa");
f010350a:	83 ec 04             	sub    $0x4,%esp
f010350d:	8d 83 54 a2 f7 ff    	lea    -0x85dac(%ebx),%eax
f0103513:	50                   	push   %eax
f0103514:	6a 4f                	push   $0x4f
f0103516:	8d 83 d9 a8 f7 ff    	lea    -0x85727(%ebx),%eax
f010351c:	50                   	push   %eax
f010351d:	e8 ce cb ff ff       	call   f01000f0 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103522:	8b 45 08             	mov    0x8(%ebp),%eax
f0103525:	8b 40 5c             	mov    0x5c(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103528:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010352d:	76 57                	jbe    f0103586 <env_free+0x1d6>
	e->env_pgdir = 0;
f010352f:	8b 55 08             	mov    0x8(%ebp),%edx
f0103532:	c7 42 5c 00 00 00 00 	movl   $0x0,0x5c(%edx)
	return (physaddr_t)kva - KERNBASE;
f0103539:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f010353e:	c1 e8 0c             	shr    $0xc,%eax
f0103541:	c7 c2 08 e0 18 f0    	mov    $0xf018e008,%edx
f0103547:	3b 02                	cmp    (%edx),%eax
f0103549:	73 54                	jae    f010359f <env_free+0x1ef>
	page_decref(pa2page(pa));
f010354b:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f010354e:	c7 c2 10 e0 18 f0    	mov    $0xf018e010,%edx
f0103554:	8b 12                	mov    (%edx),%edx
f0103556:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103559:	50                   	push   %eax
f010355a:	e8 a4 db ff ff       	call   f0101103 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f010355f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103562:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
	e->env_link = env_free_list;
f0103569:	8b 83 28 23 00 00    	mov    0x2328(%ebx),%eax
f010356f:	8b 55 08             	mov    0x8(%ebp),%edx
f0103572:	89 42 44             	mov    %eax,0x44(%edx)
	env_free_list = e;
f0103575:	89 93 28 23 00 00    	mov    %edx,0x2328(%ebx)
}
f010357b:	83 c4 10             	add    $0x10,%esp
f010357e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103581:	5b                   	pop    %ebx
f0103582:	5e                   	pop    %esi
f0103583:	5f                   	pop    %edi
f0103584:	5d                   	pop    %ebp
f0103585:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103586:	50                   	push   %eax
f0103587:	8d 83 0c a2 f7 ff    	lea    -0x85df4(%ebx),%eax
f010358d:	50                   	push   %eax
f010358e:	68 85 01 00 00       	push   $0x185
f0103593:	8d 83 02 ac f7 ff    	lea    -0x853fe(%ebx),%eax
f0103599:	50                   	push   %eax
f010359a:	e8 51 cb ff ff       	call   f01000f0 <_panic>
		panic("pa2page called with invalid pa");
f010359f:	83 ec 04             	sub    $0x4,%esp
f01035a2:	8d 83 54 a2 f7 ff    	lea    -0x85dac(%ebx),%eax
f01035a8:	50                   	push   %eax
f01035a9:	6a 4f                	push   $0x4f
f01035ab:	8d 83 d9 a8 f7 ff    	lea    -0x85727(%ebx),%eax
f01035b1:	50                   	push   %eax
f01035b2:	e8 39 cb ff ff       	call   f01000f0 <_panic>

f01035b7 <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f01035b7:	55                   	push   %ebp
f01035b8:	89 e5                	mov    %esp,%ebp
f01035ba:	53                   	push   %ebx
f01035bb:	83 ec 10             	sub    $0x10,%esp
f01035be:	e8 e3 cb ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f01035c3:	81 c3 5d 7a 08 00    	add    $0x87a5d,%ebx
	env_free(e);
f01035c9:	ff 75 08             	pushl  0x8(%ebp)
f01035cc:	e8 df fd ff ff       	call   f01033b0 <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f01035d1:	8d 83 cc ab f7 ff    	lea    -0x85434(%ebx),%eax
f01035d7:	89 04 24             	mov    %eax,(%esp)
f01035da:	e8 f7 00 00 00       	call   f01036d6 <cprintf>
f01035df:	83 c4 10             	add    $0x10,%esp
	while (1)
		monitor(NULL);
f01035e2:	83 ec 0c             	sub    $0xc,%esp
f01035e5:	6a 00                	push   $0x0
f01035e7:	e8 55 d3 ff ff       	call   f0100941 <monitor>
f01035ec:	83 c4 10             	add    $0x10,%esp
f01035ef:	eb f1                	jmp    f01035e2 <env_destroy+0x2b>

f01035f1 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01035f1:	55                   	push   %ebp
f01035f2:	89 e5                	mov    %esp,%ebp
f01035f4:	53                   	push   %ebx
f01035f5:	83 ec 08             	sub    $0x8,%esp
f01035f8:	e8 a9 cb ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f01035fd:	81 c3 23 7a 08 00    	add    $0x87a23,%ebx
	asm volatile(
f0103603:	8b 65 08             	mov    0x8(%ebp),%esp
f0103606:	61                   	popa   
f0103607:	07                   	pop    %es
f0103608:	1f                   	pop    %ds
f0103609:	83 c4 08             	add    $0x8,%esp
f010360c:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f010360d:	8d 83 38 ac f7 ff    	lea    -0x853c8(%ebx),%eax
f0103613:	50                   	push   %eax
f0103614:	68 ae 01 00 00       	push   $0x1ae
f0103619:	8d 83 02 ac f7 ff    	lea    -0x853fe(%ebx),%eax
f010361f:	50                   	push   %eax
f0103620:	e8 cb ca ff ff       	call   f01000f0 <_panic>

f0103625 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103625:	55                   	push   %ebp
f0103626:	89 e5                	mov    %esp,%ebp
f0103628:	53                   	push   %ebx
f0103629:	83 ec 08             	sub    $0x8,%esp
f010362c:	e8 75 cb ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f0103631:	81 c3 ef 79 08 00    	add    $0x879ef,%ebx
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

	panic("env_run not yet implemented");
f0103637:	8d 83 44 ac f7 ff    	lea    -0x853bc(%ebx),%eax
f010363d:	50                   	push   %eax
f010363e:	68 cd 01 00 00       	push   $0x1cd
f0103643:	8d 83 02 ac f7 ff    	lea    -0x853fe(%ebx),%eax
f0103649:	50                   	push   %eax
f010364a:	e8 a1 ca ff ff       	call   f01000f0 <_panic>

f010364f <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f010364f:	55                   	push   %ebp
f0103650:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103652:	8b 45 08             	mov    0x8(%ebp),%eax
f0103655:	ba 70 00 00 00       	mov    $0x70,%edx
f010365a:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010365b:	ba 71 00 00 00       	mov    $0x71,%edx
f0103660:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103661:	0f b6 c0             	movzbl %al,%eax
}
f0103664:	5d                   	pop    %ebp
f0103665:	c3                   	ret    

f0103666 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103666:	55                   	push   %ebp
f0103667:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103669:	8b 45 08             	mov    0x8(%ebp),%eax
f010366c:	ba 70 00 00 00       	mov    $0x70,%edx
f0103671:	ee                   	out    %al,(%dx)
f0103672:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103675:	ba 71 00 00 00       	mov    $0x71,%edx
f010367a:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010367b:	5d                   	pop    %ebp
f010367c:	c3                   	ret    

f010367d <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f010367d:	55                   	push   %ebp
f010367e:	89 e5                	mov    %esp,%ebp
f0103680:	53                   	push   %ebx
f0103681:	83 ec 10             	sub    $0x10,%esp
f0103684:	e8 1d cb ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f0103689:	81 c3 97 79 08 00    	add    $0x87997,%ebx
	cputchar(ch);
f010368f:	ff 75 08             	pushl  0x8(%ebp)
f0103692:	e8 86 d0 ff ff       	call   f010071d <cputchar>
	*cnt++;
}
f0103697:	83 c4 10             	add    $0x10,%esp
f010369a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010369d:	c9                   	leave  
f010369e:	c3                   	ret    

f010369f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010369f:	55                   	push   %ebp
f01036a0:	89 e5                	mov    %esp,%ebp
f01036a2:	53                   	push   %ebx
f01036a3:	83 ec 14             	sub    $0x14,%esp
f01036a6:	e8 fb ca ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f01036ab:	81 c3 75 79 08 00    	add    $0x87975,%ebx
	int cnt = 0;
f01036b1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01036b8:	ff 75 0c             	pushl  0xc(%ebp)
f01036bb:	ff 75 08             	pushl  0x8(%ebp)
f01036be:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01036c1:	50                   	push   %eax
f01036c2:	8d 83 5d 86 f7 ff    	lea    -0x879a3(%ebx),%eax
f01036c8:	50                   	push   %eax
f01036c9:	e8 38 09 00 00       	call   f0104006 <vprintfmt>
	return cnt;
}
f01036ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01036d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01036d4:	c9                   	leave  
f01036d5:	c3                   	ret    

f01036d6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01036d6:	55                   	push   %ebp
f01036d7:	89 e5                	mov    %esp,%ebp
f01036d9:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01036dc:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01036df:	50                   	push   %eax
f01036e0:	ff 75 08             	pushl  0x8(%ebp)
f01036e3:	e8 b7 ff ff ff       	call   f010369f <vcprintf>
	va_end(ap);

	return cnt;
}
f01036e8:	c9                   	leave  
f01036e9:	c3                   	ret    

f01036ea <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f01036ea:	55                   	push   %ebp
f01036eb:	89 e5                	mov    %esp,%ebp
f01036ed:	57                   	push   %edi
f01036ee:	56                   	push   %esi
f01036ef:	53                   	push   %ebx
f01036f0:	83 ec 04             	sub    $0x4,%esp
f01036f3:	e8 ae ca ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f01036f8:	81 c3 28 79 08 00    	add    $0x87928,%ebx
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f01036fe:	c7 83 64 2b 00 00 00 	movl   $0xf0000000,0x2b64(%ebx)
f0103705:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f0103708:	66 c7 83 68 2b 00 00 	movw   $0x10,0x2b68(%ebx)
f010370f:	10 00 
	ts.ts_iomb = sizeof(struct Taskstate);
f0103711:	66 c7 83 c6 2b 00 00 	movw   $0x68,0x2bc6(%ebx)
f0103718:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f010371a:	c7 c0 00 a3 11 f0    	mov    $0xf011a300,%eax
f0103720:	66 c7 40 28 67 00    	movw   $0x67,0x28(%eax)
f0103726:	8d b3 60 2b 00 00    	lea    0x2b60(%ebx),%esi
f010372c:	66 89 70 2a          	mov    %si,0x2a(%eax)
f0103730:	89 f2                	mov    %esi,%edx
f0103732:	c1 ea 10             	shr    $0x10,%edx
f0103735:	88 50 2c             	mov    %dl,0x2c(%eax)
f0103738:	0f b6 50 2d          	movzbl 0x2d(%eax),%edx
f010373c:	83 e2 f0             	and    $0xfffffff0,%edx
f010373f:	83 ca 09             	or     $0x9,%edx
f0103742:	83 e2 9f             	and    $0xffffff9f,%edx
f0103745:	83 ca 80             	or     $0xffffff80,%edx
f0103748:	88 55 f3             	mov    %dl,-0xd(%ebp)
f010374b:	88 50 2d             	mov    %dl,0x2d(%eax)
f010374e:	0f b6 48 2e          	movzbl 0x2e(%eax),%ecx
f0103752:	83 e1 c0             	and    $0xffffffc0,%ecx
f0103755:	83 c9 40             	or     $0x40,%ecx
f0103758:	83 e1 7f             	and    $0x7f,%ecx
f010375b:	88 48 2e             	mov    %cl,0x2e(%eax)
f010375e:	c1 ee 18             	shr    $0x18,%esi
f0103761:	89 f1                	mov    %esi,%ecx
f0103763:	88 48 2f             	mov    %cl,0x2f(%eax)
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0103766:	0f b6 55 f3          	movzbl -0xd(%ebp),%edx
f010376a:	83 e2 ef             	and    $0xffffffef,%edx
f010376d:	88 50 2d             	mov    %dl,0x2d(%eax)
	asm volatile("ltr %0" : : "r" (sel));
f0103770:	b8 28 00 00 00       	mov    $0x28,%eax
f0103775:	0f 00 d8             	ltr    %ax
	asm volatile("lidt (%0)" : : "r" (p));
f0103778:	8d 83 e8 1f 00 00    	lea    0x1fe8(%ebx),%eax
f010377e:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f0103781:	83 c4 04             	add    $0x4,%esp
f0103784:	5b                   	pop    %ebx
f0103785:	5e                   	pop    %esi
f0103786:	5f                   	pop    %edi
f0103787:	5d                   	pop    %ebp
f0103788:	c3                   	ret    

f0103789 <trap_init>:
{
f0103789:	55                   	push   %ebp
f010378a:	89 e5                	mov    %esp,%ebp
	trap_init_percpu();
f010378c:	e8 59 ff ff ff       	call   f01036ea <trap_init_percpu>
}
f0103791:	5d                   	pop    %ebp
f0103792:	c3                   	ret    

f0103793 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103793:	55                   	push   %ebp
f0103794:	89 e5                	mov    %esp,%ebp
f0103796:	56                   	push   %esi
f0103797:	53                   	push   %ebx
f0103798:	e8 09 ca ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f010379d:	81 c3 83 78 08 00    	add    $0x87883,%ebx
f01037a3:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01037a6:	83 ec 08             	sub    $0x8,%esp
f01037a9:	ff 36                	pushl  (%esi)
f01037ab:	8d 83 60 ac f7 ff    	lea    -0x853a0(%ebx),%eax
f01037b1:	50                   	push   %eax
f01037b2:	e8 1f ff ff ff       	call   f01036d6 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01037b7:	83 c4 08             	add    $0x8,%esp
f01037ba:	ff 76 04             	pushl  0x4(%esi)
f01037bd:	8d 83 6f ac f7 ff    	lea    -0x85391(%ebx),%eax
f01037c3:	50                   	push   %eax
f01037c4:	e8 0d ff ff ff       	call   f01036d6 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01037c9:	83 c4 08             	add    $0x8,%esp
f01037cc:	ff 76 08             	pushl  0x8(%esi)
f01037cf:	8d 83 7e ac f7 ff    	lea    -0x85382(%ebx),%eax
f01037d5:	50                   	push   %eax
f01037d6:	e8 fb fe ff ff       	call   f01036d6 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01037db:	83 c4 08             	add    $0x8,%esp
f01037de:	ff 76 0c             	pushl  0xc(%esi)
f01037e1:	8d 83 8d ac f7 ff    	lea    -0x85373(%ebx),%eax
f01037e7:	50                   	push   %eax
f01037e8:	e8 e9 fe ff ff       	call   f01036d6 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f01037ed:	83 c4 08             	add    $0x8,%esp
f01037f0:	ff 76 10             	pushl  0x10(%esi)
f01037f3:	8d 83 9c ac f7 ff    	lea    -0x85364(%ebx),%eax
f01037f9:	50                   	push   %eax
f01037fa:	e8 d7 fe ff ff       	call   f01036d6 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f01037ff:	83 c4 08             	add    $0x8,%esp
f0103802:	ff 76 14             	pushl  0x14(%esi)
f0103805:	8d 83 ab ac f7 ff    	lea    -0x85355(%ebx),%eax
f010380b:	50                   	push   %eax
f010380c:	e8 c5 fe ff ff       	call   f01036d6 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103811:	83 c4 08             	add    $0x8,%esp
f0103814:	ff 76 18             	pushl  0x18(%esi)
f0103817:	8d 83 ba ac f7 ff    	lea    -0x85346(%ebx),%eax
f010381d:	50                   	push   %eax
f010381e:	e8 b3 fe ff ff       	call   f01036d6 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103823:	83 c4 08             	add    $0x8,%esp
f0103826:	ff 76 1c             	pushl  0x1c(%esi)
f0103829:	8d 83 c9 ac f7 ff    	lea    -0x85337(%ebx),%eax
f010382f:	50                   	push   %eax
f0103830:	e8 a1 fe ff ff       	call   f01036d6 <cprintf>
}
f0103835:	83 c4 10             	add    $0x10,%esp
f0103838:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010383b:	5b                   	pop    %ebx
f010383c:	5e                   	pop    %esi
f010383d:	5d                   	pop    %ebp
f010383e:	c3                   	ret    

f010383f <print_trapframe>:
{
f010383f:	55                   	push   %ebp
f0103840:	89 e5                	mov    %esp,%ebp
f0103842:	57                   	push   %edi
f0103843:	56                   	push   %esi
f0103844:	53                   	push   %ebx
f0103845:	83 ec 14             	sub    $0x14,%esp
f0103848:	e8 59 c9 ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f010384d:	81 c3 d3 77 08 00    	add    $0x877d3,%ebx
f0103853:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("TRAP frame at %p\n", tf);
f0103856:	56                   	push   %esi
f0103857:	8d 83 ff ad f7 ff    	lea    -0x85201(%ebx),%eax
f010385d:	50                   	push   %eax
f010385e:	e8 73 fe ff ff       	call   f01036d6 <cprintf>
	print_regs(&tf->tf_regs);
f0103863:	89 34 24             	mov    %esi,(%esp)
f0103866:	e8 28 ff ff ff       	call   f0103793 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f010386b:	83 c4 08             	add    $0x8,%esp
f010386e:	0f b7 46 20          	movzwl 0x20(%esi),%eax
f0103872:	50                   	push   %eax
f0103873:	8d 83 1a ad f7 ff    	lea    -0x852e6(%ebx),%eax
f0103879:	50                   	push   %eax
f010387a:	e8 57 fe ff ff       	call   f01036d6 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f010387f:	83 c4 08             	add    $0x8,%esp
f0103882:	0f b7 46 24          	movzwl 0x24(%esi),%eax
f0103886:	50                   	push   %eax
f0103887:	8d 83 2d ad f7 ff    	lea    -0x852d3(%ebx),%eax
f010388d:	50                   	push   %eax
f010388e:	e8 43 fe ff ff       	call   f01036d6 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103893:	8b 56 28             	mov    0x28(%esi),%edx
	if (trapno < ARRAY_SIZE(excnames))
f0103896:	83 c4 10             	add    $0x10,%esp
f0103899:	83 fa 13             	cmp    $0x13,%edx
f010389c:	0f 86 e9 00 00 00    	jbe    f010398b <print_trapframe+0x14c>
	return "(unknown trap)";
f01038a2:	83 fa 30             	cmp    $0x30,%edx
f01038a5:	8d 83 d8 ac f7 ff    	lea    -0x85328(%ebx),%eax
f01038ab:	8d 8b e4 ac f7 ff    	lea    -0x8531c(%ebx),%ecx
f01038b1:	0f 45 c1             	cmovne %ecx,%eax
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01038b4:	83 ec 04             	sub    $0x4,%esp
f01038b7:	50                   	push   %eax
f01038b8:	52                   	push   %edx
f01038b9:	8d 83 40 ad f7 ff    	lea    -0x852c0(%ebx),%eax
f01038bf:	50                   	push   %eax
f01038c0:	e8 11 fe ff ff       	call   f01036d6 <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01038c5:	83 c4 10             	add    $0x10,%esp
f01038c8:	39 b3 40 2b 00 00    	cmp    %esi,0x2b40(%ebx)
f01038ce:	0f 84 c3 00 00 00    	je     f0103997 <print_trapframe+0x158>
	cprintf("  err  0x%08x", tf->tf_err);
f01038d4:	83 ec 08             	sub    $0x8,%esp
f01038d7:	ff 76 2c             	pushl  0x2c(%esi)
f01038da:	8d 83 61 ad f7 ff    	lea    -0x8529f(%ebx),%eax
f01038e0:	50                   	push   %eax
f01038e1:	e8 f0 fd ff ff       	call   f01036d6 <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f01038e6:	83 c4 10             	add    $0x10,%esp
f01038e9:	83 7e 28 0e          	cmpl   $0xe,0x28(%esi)
f01038ed:	0f 85 c9 00 00 00    	jne    f01039bc <print_trapframe+0x17d>
			tf->tf_err & 1 ? "protection" : "not-present");
f01038f3:	8b 46 2c             	mov    0x2c(%esi),%eax
		cprintf(" [%s, %s, %s]\n",
f01038f6:	89 c2                	mov    %eax,%edx
f01038f8:	83 e2 01             	and    $0x1,%edx
f01038fb:	8d 8b f3 ac f7 ff    	lea    -0x8530d(%ebx),%ecx
f0103901:	8d 93 fe ac f7 ff    	lea    -0x85302(%ebx),%edx
f0103907:	0f 44 ca             	cmove  %edx,%ecx
f010390a:	89 c2                	mov    %eax,%edx
f010390c:	83 e2 02             	and    $0x2,%edx
f010390f:	8d 93 0a ad f7 ff    	lea    -0x852f6(%ebx),%edx
f0103915:	8d bb 10 ad f7 ff    	lea    -0x852f0(%ebx),%edi
f010391b:	0f 44 d7             	cmove  %edi,%edx
f010391e:	83 e0 04             	and    $0x4,%eax
f0103921:	8d 83 15 ad f7 ff    	lea    -0x852eb(%ebx),%eax
f0103927:	8d bb 2a ae f7 ff    	lea    -0x851d6(%ebx),%edi
f010392d:	0f 44 c7             	cmove  %edi,%eax
f0103930:	51                   	push   %ecx
f0103931:	52                   	push   %edx
f0103932:	50                   	push   %eax
f0103933:	8d 83 6f ad f7 ff    	lea    -0x85291(%ebx),%eax
f0103939:	50                   	push   %eax
f010393a:	e8 97 fd ff ff       	call   f01036d6 <cprintf>
f010393f:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103942:	83 ec 08             	sub    $0x8,%esp
f0103945:	ff 76 30             	pushl  0x30(%esi)
f0103948:	8d 83 7e ad f7 ff    	lea    -0x85282(%ebx),%eax
f010394e:	50                   	push   %eax
f010394f:	e8 82 fd ff ff       	call   f01036d6 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103954:	83 c4 08             	add    $0x8,%esp
f0103957:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f010395b:	50                   	push   %eax
f010395c:	8d 83 8d ad f7 ff    	lea    -0x85273(%ebx),%eax
f0103962:	50                   	push   %eax
f0103963:	e8 6e fd ff ff       	call   f01036d6 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103968:	83 c4 08             	add    $0x8,%esp
f010396b:	ff 76 38             	pushl  0x38(%esi)
f010396e:	8d 83 a0 ad f7 ff    	lea    -0x85260(%ebx),%eax
f0103974:	50                   	push   %eax
f0103975:	e8 5c fd ff ff       	call   f01036d6 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f010397a:	83 c4 10             	add    $0x10,%esp
f010397d:	f6 46 34 03          	testb  $0x3,0x34(%esi)
f0103981:	75 50                	jne    f01039d3 <print_trapframe+0x194>
}
f0103983:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103986:	5b                   	pop    %ebx
f0103987:	5e                   	pop    %esi
f0103988:	5f                   	pop    %edi
f0103989:	5d                   	pop    %ebp
f010398a:	c3                   	ret    
		return excnames[trapno];
f010398b:	8b 84 93 60 20 00 00 	mov    0x2060(%ebx,%edx,4),%eax
f0103992:	e9 1d ff ff ff       	jmp    f01038b4 <print_trapframe+0x75>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103997:	83 7e 28 0e          	cmpl   $0xe,0x28(%esi)
f010399b:	0f 85 33 ff ff ff    	jne    f01038d4 <print_trapframe+0x95>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f01039a1:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f01039a4:	83 ec 08             	sub    $0x8,%esp
f01039a7:	50                   	push   %eax
f01039a8:	8d 83 52 ad f7 ff    	lea    -0x852ae(%ebx),%eax
f01039ae:	50                   	push   %eax
f01039af:	e8 22 fd ff ff       	call   f01036d6 <cprintf>
f01039b4:	83 c4 10             	add    $0x10,%esp
f01039b7:	e9 18 ff ff ff       	jmp    f01038d4 <print_trapframe+0x95>
		cprintf("\n");
f01039bc:	83 ec 0c             	sub    $0xc,%esp
f01039bf:	8d 83 e9 9e f7 ff    	lea    -0x86117(%ebx),%eax
f01039c5:	50                   	push   %eax
f01039c6:	e8 0b fd ff ff       	call   f01036d6 <cprintf>
f01039cb:	83 c4 10             	add    $0x10,%esp
f01039ce:	e9 6f ff ff ff       	jmp    f0103942 <print_trapframe+0x103>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01039d3:	83 ec 08             	sub    $0x8,%esp
f01039d6:	ff 76 3c             	pushl  0x3c(%esi)
f01039d9:	8d 83 af ad f7 ff    	lea    -0x85251(%ebx),%eax
f01039df:	50                   	push   %eax
f01039e0:	e8 f1 fc ff ff       	call   f01036d6 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01039e5:	83 c4 08             	add    $0x8,%esp
f01039e8:	0f b7 46 40          	movzwl 0x40(%esi),%eax
f01039ec:	50                   	push   %eax
f01039ed:	8d 83 be ad f7 ff    	lea    -0x85242(%ebx),%eax
f01039f3:	50                   	push   %eax
f01039f4:	e8 dd fc ff ff       	call   f01036d6 <cprintf>
f01039f9:	83 c4 10             	add    $0x10,%esp
}
f01039fc:	eb 85                	jmp    f0103983 <print_trapframe+0x144>

f01039fe <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f01039fe:	55                   	push   %ebp
f01039ff:	89 e5                	mov    %esp,%ebp
f0103a01:	57                   	push   %edi
f0103a02:	56                   	push   %esi
f0103a03:	53                   	push   %ebx
f0103a04:	83 ec 0c             	sub    $0xc,%esp
f0103a07:	e8 9a c7 ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f0103a0c:	81 c3 14 76 08 00    	add    $0x87614,%ebx
f0103a12:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103a15:	fc                   	cld    
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0103a16:	9c                   	pushf  
f0103a17:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0103a18:	f6 c4 02             	test   $0x2,%ah
f0103a1b:	74 1f                	je     f0103a3c <trap+0x3e>
f0103a1d:	8d 83 d1 ad f7 ff    	lea    -0x8522f(%ebx),%eax
f0103a23:	50                   	push   %eax
f0103a24:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0103a2a:	50                   	push   %eax
f0103a2b:	68 a8 00 00 00       	push   $0xa8
f0103a30:	8d 83 ea ad f7 ff    	lea    -0x85216(%ebx),%eax
f0103a36:	50                   	push   %eax
f0103a37:	e8 b4 c6 ff ff       	call   f01000f0 <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f0103a3c:	83 ec 08             	sub    $0x8,%esp
f0103a3f:	56                   	push   %esi
f0103a40:	8d 83 f6 ad f7 ff    	lea    -0x8520a(%ebx),%eax
f0103a46:	50                   	push   %eax
f0103a47:	e8 8a fc ff ff       	call   f01036d6 <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f0103a4c:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103a50:	83 e0 03             	and    $0x3,%eax
f0103a53:	83 c4 10             	add    $0x10,%esp
f0103a56:	66 83 f8 03          	cmp    $0x3,%ax
f0103a5a:	75 1d                	jne    f0103a79 <trap+0x7b>
		// Trapped from user mode.
		assert(curenv);
f0103a5c:	c7 c0 40 d3 18 f0    	mov    $0xf018d340,%eax
f0103a62:	8b 00                	mov    (%eax),%eax
f0103a64:	85 c0                	test   %eax,%eax
f0103a66:	74 68                	je     f0103ad0 <trap+0xd2>

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0103a68:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103a6d:	89 c7                	mov    %eax,%edi
f0103a6f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0103a71:	c7 c0 40 d3 18 f0    	mov    $0xf018d340,%eax
f0103a77:	8b 30                	mov    (%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0103a79:	89 b3 40 2b 00 00    	mov    %esi,0x2b40(%ebx)
	print_trapframe(tf);
f0103a7f:	83 ec 0c             	sub    $0xc,%esp
f0103a82:	56                   	push   %esi
f0103a83:	e8 b7 fd ff ff       	call   f010383f <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0103a88:	83 c4 10             	add    $0x10,%esp
f0103a8b:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103a90:	74 5d                	je     f0103aef <trap+0xf1>
		env_destroy(curenv);
f0103a92:	83 ec 0c             	sub    $0xc,%esp
f0103a95:	c7 c6 40 d3 18 f0    	mov    $0xf018d340,%esi
f0103a9b:	ff 36                	pushl  (%esi)
f0103a9d:	e8 15 fb ff ff       	call   f01035b7 <env_destroy>

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f0103aa2:	8b 06                	mov    (%esi),%eax
f0103aa4:	83 c4 10             	add    $0x10,%esp
f0103aa7:	85 c0                	test   %eax,%eax
f0103aa9:	74 06                	je     f0103ab1 <trap+0xb3>
f0103aab:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103aaf:	74 59                	je     f0103b0a <trap+0x10c>
f0103ab1:	8d 83 74 af f7 ff    	lea    -0x8508c(%ebx),%eax
f0103ab7:	50                   	push   %eax
f0103ab8:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0103abe:	50                   	push   %eax
f0103abf:	68 c0 00 00 00       	push   $0xc0
f0103ac4:	8d 83 ea ad f7 ff    	lea    -0x85216(%ebx),%eax
f0103aca:	50                   	push   %eax
f0103acb:	e8 20 c6 ff ff       	call   f01000f0 <_panic>
		assert(curenv);
f0103ad0:	8d 83 11 ae f7 ff    	lea    -0x851ef(%ebx),%eax
f0103ad6:	50                   	push   %eax
f0103ad7:	8d 83 f3 a8 f7 ff    	lea    -0x8570d(%ebx),%eax
f0103add:	50                   	push   %eax
f0103ade:	68 ae 00 00 00       	push   $0xae
f0103ae3:	8d 83 ea ad f7 ff    	lea    -0x85216(%ebx),%eax
f0103ae9:	50                   	push   %eax
f0103aea:	e8 01 c6 ff ff       	call   f01000f0 <_panic>
		panic("unhandled trap in kernel");
f0103aef:	83 ec 04             	sub    $0x4,%esp
f0103af2:	8d 83 18 ae f7 ff    	lea    -0x851e8(%ebx),%eax
f0103af8:	50                   	push   %eax
f0103af9:	68 97 00 00 00       	push   $0x97
f0103afe:	8d 83 ea ad f7 ff    	lea    -0x85216(%ebx),%eax
f0103b04:	50                   	push   %eax
f0103b05:	e8 e6 c5 ff ff       	call   f01000f0 <_panic>
	env_run(curenv);
f0103b0a:	83 ec 0c             	sub    $0xc,%esp
f0103b0d:	50                   	push   %eax
f0103b0e:	e8 12 fb ff ff       	call   f0103625 <env_run>

f0103b13 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103b13:	55                   	push   %ebp
f0103b14:	89 e5                	mov    %esp,%ebp
f0103b16:	57                   	push   %edi
f0103b17:	56                   	push   %esi
f0103b18:	53                   	push   %ebx
f0103b19:	83 ec 0c             	sub    $0xc,%esp
f0103b1c:	e8 85 c6 ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f0103b21:	81 c3 ff 74 08 00    	add    $0x874ff,%ebx
f0103b27:	8b 7d 08             	mov    0x8(%ebp),%edi
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103b2a:	0f 20 d0             	mov    %cr2,%eax

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103b2d:	ff 77 30             	pushl  0x30(%edi)
f0103b30:	50                   	push   %eax
f0103b31:	c7 c6 40 d3 18 f0    	mov    $0xf018d340,%esi
f0103b37:	8b 06                	mov    (%esi),%eax
f0103b39:	ff 70 48             	pushl  0x48(%eax)
f0103b3c:	8d 83 a0 af f7 ff    	lea    -0x85060(%ebx),%eax
f0103b42:	50                   	push   %eax
f0103b43:	e8 8e fb ff ff       	call   f01036d6 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103b48:	89 3c 24             	mov    %edi,(%esp)
f0103b4b:	e8 ef fc ff ff       	call   f010383f <print_trapframe>
	env_destroy(curenv);
f0103b50:	83 c4 04             	add    $0x4,%esp
f0103b53:	ff 36                	pushl  (%esi)
f0103b55:	e8 5d fa ff ff       	call   f01035b7 <env_destroy>
}
f0103b5a:	83 c4 10             	add    $0x10,%esp
f0103b5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103b60:	5b                   	pop    %ebx
f0103b61:	5e                   	pop    %esi
f0103b62:	5f                   	pop    %edi
f0103b63:	5d                   	pop    %ebp
f0103b64:	c3                   	ret    

f0103b65 <syscall>:
f0103b65:	55                   	push   %ebp
f0103b66:	89 e5                	mov    %esp,%ebp
f0103b68:	53                   	push   %ebx
f0103b69:	83 ec 08             	sub    $0x8,%esp
f0103b6c:	e8 35 c6 ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f0103b71:	81 c3 af 74 08 00    	add    $0x874af,%ebx
f0103b77:	8d 83 c4 af f7 ff    	lea    -0x8503c(%ebx),%eax
f0103b7d:	50                   	push   %eax
f0103b7e:	6a 49                	push   $0x49
f0103b80:	8d 83 dc af f7 ff    	lea    -0x85024(%ebx),%eax
f0103b86:	50                   	push   %eax
f0103b87:	e8 64 c5 ff ff       	call   f01000f0 <_panic>

f0103b8c <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0103b8c:	55                   	push   %ebp
f0103b8d:	89 e5                	mov    %esp,%ebp
f0103b8f:	57                   	push   %edi
f0103b90:	56                   	push   %esi
f0103b91:	53                   	push   %ebx
f0103b92:	83 ec 14             	sub    $0x14,%esp
f0103b95:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103b98:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0103b9b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103b9e:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0103ba1:	8b 32                	mov    (%edx),%esi
f0103ba3:	8b 01                	mov    (%ecx),%eax
f0103ba5:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103ba8:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0103baf:	eb 2f                	jmp    f0103be0 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0103bb1:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0103bb4:	39 c6                	cmp    %eax,%esi
f0103bb6:	7f 49                	jg     f0103c01 <stab_binsearch+0x75>
f0103bb8:	0f b6 0a             	movzbl (%edx),%ecx
f0103bbb:	83 ea 0c             	sub    $0xc,%edx
f0103bbe:	39 f9                	cmp    %edi,%ecx
f0103bc0:	75 ef                	jne    f0103bb1 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0103bc2:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103bc5:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103bc8:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0103bcc:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103bcf:	73 35                	jae    f0103c06 <stab_binsearch+0x7a>
			*region_left = m;
f0103bd1:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103bd4:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f0103bd6:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f0103bd9:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0103be0:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0103be3:	7f 4e                	jg     f0103c33 <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f0103be5:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103be8:	01 f0                	add    %esi,%eax
f0103bea:	89 c3                	mov    %eax,%ebx
f0103bec:	c1 eb 1f             	shr    $0x1f,%ebx
f0103bef:	01 c3                	add    %eax,%ebx
f0103bf1:	d1 fb                	sar    %ebx
f0103bf3:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0103bf6:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103bf9:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0103bfd:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f0103bff:	eb b3                	jmp    f0103bb4 <stab_binsearch+0x28>
			l = true_m + 1;
f0103c01:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f0103c04:	eb da                	jmp    f0103be0 <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0103c06:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103c09:	76 14                	jbe    f0103c1f <stab_binsearch+0x93>
			*region_right = m - 1;
f0103c0b:	83 e8 01             	sub    $0x1,%eax
f0103c0e:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103c11:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0103c14:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f0103c16:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103c1d:	eb c1                	jmp    f0103be0 <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0103c1f:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103c22:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0103c24:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0103c28:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f0103c2a:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103c31:	eb ad                	jmp    f0103be0 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0103c33:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0103c37:	74 16                	je     f0103c4f <stab_binsearch+0xc3>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103c39:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103c3c:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0103c3e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103c41:	8b 0e                	mov    (%esi),%ecx
f0103c43:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103c46:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0103c49:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f0103c4d:	eb 12                	jmp    f0103c61 <stab_binsearch+0xd5>
		*region_right = *region_left - 1;
f0103c4f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103c52:	8b 00                	mov    (%eax),%eax
f0103c54:	83 e8 01             	sub    $0x1,%eax
f0103c57:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0103c5a:	89 07                	mov    %eax,(%edi)
f0103c5c:	eb 16                	jmp    f0103c74 <stab_binsearch+0xe8>
		     l--)
f0103c5e:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0103c61:	39 c1                	cmp    %eax,%ecx
f0103c63:	7d 0a                	jge    f0103c6f <stab_binsearch+0xe3>
		     l > *region_left && stabs[l].n_type != type;
f0103c65:	0f b6 1a             	movzbl (%edx),%ebx
f0103c68:	83 ea 0c             	sub    $0xc,%edx
f0103c6b:	39 fb                	cmp    %edi,%ebx
f0103c6d:	75 ef                	jne    f0103c5e <stab_binsearch+0xd2>
			/* do nothing */;
		*region_left = l;
f0103c6f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103c72:	89 07                	mov    %eax,(%edi)
	}
}
f0103c74:	83 c4 14             	add    $0x14,%esp
f0103c77:	5b                   	pop    %ebx
f0103c78:	5e                   	pop    %esi
f0103c79:	5f                   	pop    %edi
f0103c7a:	5d                   	pop    %ebp
f0103c7b:	c3                   	ret    

f0103c7c <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0103c7c:	55                   	push   %ebp
f0103c7d:	89 e5                	mov    %esp,%ebp
f0103c7f:	57                   	push   %edi
f0103c80:	56                   	push   %esi
f0103c81:	53                   	push   %ebx
f0103c82:	83 ec 4c             	sub    $0x4c,%esp
f0103c85:	e8 1d f5 ff ff       	call   f01031a7 <__x86.get_pc_thunk.di>
f0103c8a:	81 c7 96 73 08 00    	add    $0x87396,%edi
f0103c90:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103c93:	8d 87 eb af f7 ff    	lea    -0x85015(%edi),%eax
f0103c99:	89 06                	mov    %eax,(%esi)
	info->eip_line = 0;
f0103c9b:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0103ca2:	89 46 08             	mov    %eax,0x8(%esi)
	info->eip_fn_namelen = 9;
f0103ca5:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0103cac:	8b 45 08             	mov    0x8(%ebp),%eax
f0103caf:	89 46 10             	mov    %eax,0x10(%esi)
	info->eip_fn_narg = 0;
f0103cb2:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103cb9:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f0103cbe:	77 21                	ja     f0103ce1 <debuginfo_eip+0x65>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0103cc0:	a1 00 00 20 00       	mov    0x200000,%eax
f0103cc5:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stab_end = usd->stab_end;
f0103cc8:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f0103ccd:	8b 1d 08 00 20 00    	mov    0x200008,%ebx
f0103cd3:	89 5d b4             	mov    %ebx,-0x4c(%ebp)
		stabstr_end = usd->stabstr_end;
f0103cd6:	8b 1d 0c 00 20 00    	mov    0x20000c,%ebx
f0103cdc:	89 5d b8             	mov    %ebx,-0x48(%ebp)
f0103cdf:	eb 21                	jmp    f0103d02 <debuginfo_eip+0x86>
		stabstr_end = __STABSTR_END__;
f0103ce1:	c7 c0 8f 0c 11 f0    	mov    $0xf0110c8f,%eax
f0103ce7:	89 45 b8             	mov    %eax,-0x48(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0103cea:	c7 c0 71 e2 10 f0    	mov    $0xf010e271,%eax
f0103cf0:	89 45 b4             	mov    %eax,-0x4c(%ebp)
		stab_end = __STAB_END__;
f0103cf3:	c7 c0 70 e2 10 f0    	mov    $0xf010e270,%eax
		stabs = __STAB_BEGIN__;
f0103cf9:	c7 c3 18 62 10 f0    	mov    $0xf0106218,%ebx
f0103cff:	89 5d bc             	mov    %ebx,-0x44(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103d02:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0103d05:	39 4d b4             	cmp    %ecx,-0x4c(%ebp)
f0103d08:	0f 83 d2 01 00 00    	jae    f0103ee0 <debuginfo_eip+0x264>
f0103d0e:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f0103d12:	0f 85 cf 01 00 00    	jne    f0103ee7 <debuginfo_eip+0x26b>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0103d18:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0103d1f:	8b 5d bc             	mov    -0x44(%ebp),%ebx
f0103d22:	29 d8                	sub    %ebx,%eax
f0103d24:	c1 f8 02             	sar    $0x2,%eax
f0103d27:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0103d2d:	83 e8 01             	sub    $0x1,%eax
f0103d30:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0103d33:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0103d36:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0103d39:	ff 75 08             	pushl  0x8(%ebp)
f0103d3c:	6a 64                	push   $0x64
f0103d3e:	89 d8                	mov    %ebx,%eax
f0103d40:	e8 47 fe ff ff       	call   f0103b8c <stab_binsearch>
	if (lfile == 0)
f0103d45:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103d48:	83 c4 08             	add    $0x8,%esp
f0103d4b:	85 c0                	test   %eax,%eax
f0103d4d:	0f 84 9b 01 00 00    	je     f0103eee <debuginfo_eip+0x272>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0103d53:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0103d56:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103d59:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0103d5c:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0103d5f:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0103d62:	ff 75 08             	pushl  0x8(%ebp)
f0103d65:	6a 24                	push   $0x24
f0103d67:	89 d8                	mov    %ebx,%eax
f0103d69:	e8 1e fe ff ff       	call   f0103b8c <stab_binsearch>

	if (lfun <= rfun) {
f0103d6e:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103d71:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103d74:	83 c4 08             	add    $0x8,%esp
f0103d77:	39 d0                	cmp    %edx,%eax
f0103d79:	0f 8f 90 00 00 00    	jg     f0103e0f <debuginfo_eip+0x193>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0103d7f:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0103d82:	8d 1c 8b             	lea    (%ebx,%ecx,4),%ebx
f0103d85:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
f0103d88:	8b 0b                	mov    (%ebx),%ecx
f0103d8a:	89 cb                	mov    %ecx,%ebx
f0103d8c:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0103d8f:	2b 4d b4             	sub    -0x4c(%ebp),%ecx
f0103d92:	39 cb                	cmp    %ecx,%ebx
f0103d94:	73 06                	jae    f0103d9c <debuginfo_eip+0x120>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0103d96:	03 5d b4             	add    -0x4c(%ebp),%ebx
f0103d99:	89 5e 08             	mov    %ebx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0103d9c:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0103d9f:	8b 4b 08             	mov    0x8(%ebx),%ecx
f0103da2:	89 4e 10             	mov    %ecx,0x10(%esi)
		addr -= info->eip_fn_addr;
f0103da5:	29 4d 08             	sub    %ecx,0x8(%ebp)
		// Search within the function definition for the line number.
		lline = lfun;
f0103da8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0103dab:	89 55 d0             	mov    %edx,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0103dae:	83 ec 08             	sub    $0x8,%esp
f0103db1:	6a 3a                	push   $0x3a
f0103db3:	ff 76 08             	pushl  0x8(%esi)
f0103db6:	89 fb                	mov    %edi,%ebx
f0103db8:	e8 ae 09 00 00       	call   f010476b <strfind>
f0103dbd:	2b 46 08             	sub    0x8(%esi),%eax
f0103dc0:	89 46 0c             	mov    %eax,0xc(%esi)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
        stab_binsearch(stabs,&lline,&rline,N_SLINE,addr);
f0103dc3:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0103dc6:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0103dc9:	83 c4 08             	add    $0x8,%esp
f0103dcc:	ff 75 08             	pushl  0x8(%ebp)
f0103dcf:	6a 44                	push   $0x44
f0103dd1:	8b 5d bc             	mov    -0x44(%ebp),%ebx
f0103dd4:	89 d8                	mov    %ebx,%eax
f0103dd6:	e8 b1 fd ff ff       	call   f0103b8c <stab_binsearch>
	if(lline<=rline){
f0103ddb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103dde:	83 c4 10             	add    $0x10,%esp
f0103de1:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0103de4:	7f 3d                	jg     f0103e23 <debuginfo_eip+0x1a7>
           info->eip_line = stabs[lline].n_desc;
f0103de6:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0103de9:	0f b7 44 83 06       	movzwl 0x6(%ebx,%eax,4),%eax
f0103dee:	89 46 04             	mov    %eax,0x4(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103df1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0103df4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103df7:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103dfa:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0103dfd:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f0103e01:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0103e05:	bf 01 00 00 00       	mov    $0x1,%edi
f0103e0a:	89 75 0c             	mov    %esi,0xc(%ebp)
f0103e0d:	eb 35                	jmp    f0103e44 <debuginfo_eip+0x1c8>
		info->eip_fn_addr = addr;
f0103e0f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e12:	89 46 10             	mov    %eax,0x10(%esi)
		lline = lfile;
f0103e15:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103e18:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0103e1b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103e1e:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103e21:	eb 8b                	jmp    f0103dae <debuginfo_eip+0x132>
		cprintf("line not find\n");
f0103e23:	83 ec 0c             	sub    $0xc,%esp
f0103e26:	8d 87 f5 af f7 ff    	lea    -0x8500b(%edi),%eax
f0103e2c:	50                   	push   %eax
f0103e2d:	89 fb                	mov    %edi,%ebx
f0103e2f:	e8 a2 f8 ff ff       	call   f01036d6 <cprintf>
f0103e34:	83 c4 10             	add    $0x10,%esp
f0103e37:	eb b8                	jmp    f0103df1 <debuginfo_eip+0x175>
f0103e39:	83 e8 01             	sub    $0x1,%eax
f0103e3c:	83 ea 0c             	sub    $0xc,%edx
f0103e3f:	89 f9                	mov    %edi,%ecx
f0103e41:	88 4d c4             	mov    %cl,-0x3c(%ebp)
f0103e44:	89 45 c0             	mov    %eax,-0x40(%ebp)
	while (lline >= lfile
f0103e47:	39 c3                	cmp    %eax,%ebx
f0103e49:	7f 24                	jg     f0103e6f <debuginfo_eip+0x1f3>
	       && stabs[lline].n_type != N_SOL
f0103e4b:	0f b6 0a             	movzbl (%edx),%ecx
f0103e4e:	80 f9 84             	cmp    $0x84,%cl
f0103e51:	74 42                	je     f0103e95 <debuginfo_eip+0x219>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103e53:	80 f9 64             	cmp    $0x64,%cl
f0103e56:	75 e1                	jne    f0103e39 <debuginfo_eip+0x1bd>
f0103e58:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f0103e5c:	74 db                	je     f0103e39 <debuginfo_eip+0x1bd>
f0103e5e:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103e61:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0103e65:	74 37                	je     f0103e9e <debuginfo_eip+0x222>
f0103e67:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0103e6a:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0103e6d:	eb 2f                	jmp    f0103e9e <debuginfo_eip+0x222>
f0103e6f:	8b 75 0c             	mov    0xc(%ebp),%esi
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103e72:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103e75:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103e78:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0103e7d:	39 da                	cmp    %ebx,%edx
f0103e7f:	7d 79                	jge    f0103efa <debuginfo_eip+0x27e>
		for (lline = lfun + 1;
f0103e81:	83 c2 01             	add    $0x1,%edx
f0103e84:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0103e87:	89 d0                	mov    %edx,%eax
f0103e89:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0103e8c:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0103e8f:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f0103e93:	eb 32                	jmp    f0103ec7 <debuginfo_eip+0x24b>
f0103e95:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103e98:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0103e9c:	75 1d                	jne    f0103ebb <debuginfo_eip+0x23f>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0103e9e:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0103ea1:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0103ea4:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0103ea7:	8b 45 b8             	mov    -0x48(%ebp),%eax
f0103eaa:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f0103ead:	29 f8                	sub    %edi,%eax
f0103eaf:	39 c2                	cmp    %eax,%edx
f0103eb1:	73 bf                	jae    f0103e72 <debuginfo_eip+0x1f6>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103eb3:	89 f8                	mov    %edi,%eax
f0103eb5:	01 d0                	add    %edx,%eax
f0103eb7:	89 06                	mov    %eax,(%esi)
f0103eb9:	eb b7                	jmp    f0103e72 <debuginfo_eip+0x1f6>
f0103ebb:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0103ebe:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0103ec1:	eb db                	jmp    f0103e9e <debuginfo_eip+0x222>
			info->eip_fn_narg++;
f0103ec3:	83 46 14 01          	addl   $0x1,0x14(%esi)
		for (lline = lfun + 1;
f0103ec7:	39 c3                	cmp    %eax,%ebx
f0103ec9:	7e 2a                	jle    f0103ef5 <debuginfo_eip+0x279>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103ecb:	0f b6 0a             	movzbl (%edx),%ecx
f0103ece:	83 c0 01             	add    $0x1,%eax
f0103ed1:	83 c2 0c             	add    $0xc,%edx
f0103ed4:	80 f9 a0             	cmp    $0xa0,%cl
f0103ed7:	74 ea                	je     f0103ec3 <debuginfo_eip+0x247>
	return 0;
f0103ed9:	b8 00 00 00 00       	mov    $0x0,%eax
f0103ede:	eb 1a                	jmp    f0103efa <debuginfo_eip+0x27e>
		return -1;
f0103ee0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103ee5:	eb 13                	jmp    f0103efa <debuginfo_eip+0x27e>
f0103ee7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103eec:	eb 0c                	jmp    f0103efa <debuginfo_eip+0x27e>
		return -1;
f0103eee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103ef3:	eb 05                	jmp    f0103efa <debuginfo_eip+0x27e>
	return 0;
f0103ef5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103efa:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103efd:	5b                   	pop    %ebx
f0103efe:	5e                   	pop    %esi
f0103eff:	5f                   	pop    %edi
f0103f00:	5d                   	pop    %ebp
f0103f01:	c3                   	ret    

f0103f02 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103f02:	55                   	push   %ebp
f0103f03:	89 e5                	mov    %esp,%ebp
f0103f05:	57                   	push   %edi
f0103f06:	56                   	push   %esi
f0103f07:	53                   	push   %ebx
f0103f08:	83 ec 2c             	sub    $0x2c,%esp
f0103f0b:	e8 93 f2 ff ff       	call   f01031a3 <__x86.get_pc_thunk.cx>
f0103f10:	81 c1 10 71 08 00    	add    $0x87110,%ecx
f0103f16:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0103f19:	89 c7                	mov    %eax,%edi
f0103f1b:	89 d6                	mov    %edx,%esi
f0103f1d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f20:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103f23:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103f26:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103f29:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0103f2c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103f31:	89 4d d8             	mov    %ecx,-0x28(%ebp)
f0103f34:	89 5d dc             	mov    %ebx,-0x24(%ebp)
f0103f37:	39 d3                	cmp    %edx,%ebx
f0103f39:	72 09                	jb     f0103f44 <printnum+0x42>
f0103f3b:	39 45 10             	cmp    %eax,0x10(%ebp)
f0103f3e:	0f 87 83 00 00 00    	ja     f0103fc7 <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103f44:	83 ec 0c             	sub    $0xc,%esp
f0103f47:	ff 75 18             	pushl  0x18(%ebp)
f0103f4a:	8b 45 14             	mov    0x14(%ebp),%eax
f0103f4d:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0103f50:	53                   	push   %ebx
f0103f51:	ff 75 10             	pushl  0x10(%ebp)
f0103f54:	83 ec 08             	sub    $0x8,%esp
f0103f57:	ff 75 dc             	pushl  -0x24(%ebp)
f0103f5a:	ff 75 d8             	pushl  -0x28(%ebp)
f0103f5d:	ff 75 d4             	pushl  -0x2c(%ebp)
f0103f60:	ff 75 d0             	pushl  -0x30(%ebp)
f0103f63:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0103f66:	e8 25 0a 00 00       	call   f0104990 <__udivdi3>
f0103f6b:	83 c4 18             	add    $0x18,%esp
f0103f6e:	52                   	push   %edx
f0103f6f:	50                   	push   %eax
f0103f70:	89 f2                	mov    %esi,%edx
f0103f72:	89 f8                	mov    %edi,%eax
f0103f74:	e8 89 ff ff ff       	call   f0103f02 <printnum>
f0103f79:	83 c4 20             	add    $0x20,%esp
f0103f7c:	eb 13                	jmp    f0103f91 <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103f7e:	83 ec 08             	sub    $0x8,%esp
f0103f81:	56                   	push   %esi
f0103f82:	ff 75 18             	pushl  0x18(%ebp)
f0103f85:	ff d7                	call   *%edi
f0103f87:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0103f8a:	83 eb 01             	sub    $0x1,%ebx
f0103f8d:	85 db                	test   %ebx,%ebx
f0103f8f:	7f ed                	jg     f0103f7e <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103f91:	83 ec 08             	sub    $0x8,%esp
f0103f94:	56                   	push   %esi
f0103f95:	83 ec 04             	sub    $0x4,%esp
f0103f98:	ff 75 dc             	pushl  -0x24(%ebp)
f0103f9b:	ff 75 d8             	pushl  -0x28(%ebp)
f0103f9e:	ff 75 d4             	pushl  -0x2c(%ebp)
f0103fa1:	ff 75 d0             	pushl  -0x30(%ebp)
f0103fa4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103fa7:	89 f3                	mov    %esi,%ebx
f0103fa9:	e8 02 0b 00 00       	call   f0104ab0 <__umoddi3>
f0103fae:	83 c4 14             	add    $0x14,%esp
f0103fb1:	0f be 84 06 04 b0 f7 	movsbl -0x84ffc(%esi,%eax,1),%eax
f0103fb8:	ff 
f0103fb9:	50                   	push   %eax
f0103fba:	ff d7                	call   *%edi
}
f0103fbc:	83 c4 10             	add    $0x10,%esp
f0103fbf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103fc2:	5b                   	pop    %ebx
f0103fc3:	5e                   	pop    %esi
f0103fc4:	5f                   	pop    %edi
f0103fc5:	5d                   	pop    %ebp
f0103fc6:	c3                   	ret    
f0103fc7:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0103fca:	eb be                	jmp    f0103f8a <printnum+0x88>

f0103fcc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0103fcc:	55                   	push   %ebp
f0103fcd:	89 e5                	mov    %esp,%ebp
f0103fcf:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103fd2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0103fd6:	8b 10                	mov    (%eax),%edx
f0103fd8:	3b 50 04             	cmp    0x4(%eax),%edx
f0103fdb:	73 0a                	jae    f0103fe7 <sprintputch+0x1b>
		*b->buf++ = ch;
f0103fdd:	8d 4a 01             	lea    0x1(%edx),%ecx
f0103fe0:	89 08                	mov    %ecx,(%eax)
f0103fe2:	8b 45 08             	mov    0x8(%ebp),%eax
f0103fe5:	88 02                	mov    %al,(%edx)
}
f0103fe7:	5d                   	pop    %ebp
f0103fe8:	c3                   	ret    

f0103fe9 <printfmt>:
{
f0103fe9:	55                   	push   %ebp
f0103fea:	89 e5                	mov    %esp,%ebp
f0103fec:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0103fef:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0103ff2:	50                   	push   %eax
f0103ff3:	ff 75 10             	pushl  0x10(%ebp)
f0103ff6:	ff 75 0c             	pushl  0xc(%ebp)
f0103ff9:	ff 75 08             	pushl  0x8(%ebp)
f0103ffc:	e8 05 00 00 00       	call   f0104006 <vprintfmt>
}
f0104001:	83 c4 10             	add    $0x10,%esp
f0104004:	c9                   	leave  
f0104005:	c3                   	ret    

f0104006 <vprintfmt>:
{
f0104006:	55                   	push   %ebp
f0104007:	89 e5                	mov    %esp,%ebp
f0104009:	57                   	push   %edi
f010400a:	56                   	push   %esi
f010400b:	53                   	push   %ebx
f010400c:	83 ec 2c             	sub    $0x2c,%esp
f010400f:	e8 92 c1 ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f0104014:	81 c3 0c 70 08 00    	add    $0x8700c,%ebx
f010401a:	8b 75 0c             	mov    0xc(%ebp),%esi
f010401d:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104020:	e9 c3 03 00 00       	jmp    f01043e8 <.L35+0x48>
		padc = ' ';
f0104025:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f0104029:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f0104030:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
f0104037:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f010403e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104043:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0104046:	8d 47 01             	lea    0x1(%edi),%eax
f0104049:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010404c:	0f b6 17             	movzbl (%edi),%edx
f010404f:	8d 42 dd             	lea    -0x23(%edx),%eax
f0104052:	3c 55                	cmp    $0x55,%al
f0104054:	0f 87 16 04 00 00    	ja     f0104470 <.L22>
f010405a:	0f b6 c0             	movzbl %al,%eax
f010405d:	89 d9                	mov    %ebx,%ecx
f010405f:	03 8c 83 90 b0 f7 ff 	add    -0x84f70(%ebx,%eax,4),%ecx
f0104066:	ff e1                	jmp    *%ecx

f0104068 <.L69>:
f0104068:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f010406b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f010406f:	eb d5                	jmp    f0104046 <vprintfmt+0x40>

f0104071 <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
f0104071:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f0104074:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0104078:	eb cc                	jmp    f0104046 <vprintfmt+0x40>

f010407a <.L29>:
		switch (ch = *(unsigned char *) fmt++) {
f010407a:	0f b6 d2             	movzbl %dl,%edx
f010407d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0104080:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
f0104085:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0104088:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f010408c:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f010408f:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0104092:	83 f9 09             	cmp    $0x9,%ecx
f0104095:	77 55                	ja     f01040ec <.L23+0xf>
			for (precision = 0; ; ++fmt) {
f0104097:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f010409a:	eb e9                	jmp    f0104085 <.L29+0xb>

f010409c <.L26>:
			precision = va_arg(ap, int);
f010409c:	8b 45 14             	mov    0x14(%ebp),%eax
f010409f:	8b 00                	mov    (%eax),%eax
f01040a1:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01040a4:	8b 45 14             	mov    0x14(%ebp),%eax
f01040a7:	8d 40 04             	lea    0x4(%eax),%eax
f01040aa:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01040ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f01040b0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01040b4:	79 90                	jns    f0104046 <vprintfmt+0x40>
				width = precision, precision = -1;
f01040b6:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01040b9:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01040bc:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f01040c3:	eb 81                	jmp    f0104046 <vprintfmt+0x40>

f01040c5 <.L27>:
f01040c5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01040c8:	85 c0                	test   %eax,%eax
f01040ca:	ba 00 00 00 00       	mov    $0x0,%edx
f01040cf:	0f 49 d0             	cmovns %eax,%edx
f01040d2:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01040d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01040d8:	e9 69 ff ff ff       	jmp    f0104046 <vprintfmt+0x40>

f01040dd <.L23>:
f01040dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f01040e0:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f01040e7:	e9 5a ff ff ff       	jmp    f0104046 <vprintfmt+0x40>
f01040ec:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01040ef:	eb bf                	jmp    f01040b0 <.L26+0x14>

f01040f1 <.L33>:
			lflag++;
f01040f1:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01040f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f01040f8:	e9 49 ff ff ff       	jmp    f0104046 <vprintfmt+0x40>

f01040fd <.L30>:
			putch(va_arg(ap, int), putdat);
f01040fd:	8b 45 14             	mov    0x14(%ebp),%eax
f0104100:	8d 78 04             	lea    0x4(%eax),%edi
f0104103:	83 ec 08             	sub    $0x8,%esp
f0104106:	56                   	push   %esi
f0104107:	ff 30                	pushl  (%eax)
f0104109:	ff 55 08             	call   *0x8(%ebp)
			break;
f010410c:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f010410f:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0104112:	e9 ce 02 00 00       	jmp    f01043e5 <.L35+0x45>

f0104117 <.L32>:
			err = va_arg(ap, int);
f0104117:	8b 45 14             	mov    0x14(%ebp),%eax
f010411a:	8d 78 04             	lea    0x4(%eax),%edi
f010411d:	8b 00                	mov    (%eax),%eax
f010411f:	99                   	cltd   
f0104120:	31 d0                	xor    %edx,%eax
f0104122:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104124:	83 f8 06             	cmp    $0x6,%eax
f0104127:	7f 27                	jg     f0104150 <.L32+0x39>
f0104129:	8b 94 83 b0 20 00 00 	mov    0x20b0(%ebx,%eax,4),%edx
f0104130:	85 d2                	test   %edx,%edx
f0104132:	74 1c                	je     f0104150 <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
f0104134:	52                   	push   %edx
f0104135:	8d 83 05 a9 f7 ff    	lea    -0x856fb(%ebx),%eax
f010413b:	50                   	push   %eax
f010413c:	56                   	push   %esi
f010413d:	ff 75 08             	pushl  0x8(%ebp)
f0104140:	e8 a4 fe ff ff       	call   f0103fe9 <printfmt>
f0104145:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0104148:	89 7d 14             	mov    %edi,0x14(%ebp)
f010414b:	e9 95 02 00 00       	jmp    f01043e5 <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
f0104150:	50                   	push   %eax
f0104151:	8d 83 1c b0 f7 ff    	lea    -0x84fe4(%ebx),%eax
f0104157:	50                   	push   %eax
f0104158:	56                   	push   %esi
f0104159:	ff 75 08             	pushl  0x8(%ebp)
f010415c:	e8 88 fe ff ff       	call   f0103fe9 <printfmt>
f0104161:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0104164:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0104167:	e9 79 02 00 00       	jmp    f01043e5 <.L35+0x45>

f010416c <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
f010416c:	8b 45 14             	mov    0x14(%ebp),%eax
f010416f:	83 c0 04             	add    $0x4,%eax
f0104172:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104175:	8b 45 14             	mov    0x14(%ebp),%eax
f0104178:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f010417a:	85 ff                	test   %edi,%edi
f010417c:	8d 83 15 b0 f7 ff    	lea    -0x84feb(%ebx),%eax
f0104182:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0104185:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104189:	0f 8e b5 00 00 00    	jle    f0104244 <.L36+0xd8>
f010418f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0104193:	75 08                	jne    f010419d <.L36+0x31>
f0104195:	89 75 0c             	mov    %esi,0xc(%ebp)
f0104198:	8b 75 cc             	mov    -0x34(%ebp),%esi
f010419b:	eb 6d                	jmp    f010420a <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
f010419d:	83 ec 08             	sub    $0x8,%esp
f01041a0:	ff 75 cc             	pushl  -0x34(%ebp)
f01041a3:	57                   	push   %edi
f01041a4:	e8 7e 04 00 00       	call   f0104627 <strnlen>
f01041a9:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01041ac:	29 c2                	sub    %eax,%edx
f01041ae:	89 55 c8             	mov    %edx,-0x38(%ebp)
f01041b1:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f01041b4:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f01041b8:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01041bb:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f01041be:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f01041c0:	eb 10                	jmp    f01041d2 <.L36+0x66>
					putch(padc, putdat);
f01041c2:	83 ec 08             	sub    $0x8,%esp
f01041c5:	56                   	push   %esi
f01041c6:	ff 75 e0             	pushl  -0x20(%ebp)
f01041c9:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f01041cc:	83 ef 01             	sub    $0x1,%edi
f01041cf:	83 c4 10             	add    $0x10,%esp
f01041d2:	85 ff                	test   %edi,%edi
f01041d4:	7f ec                	jg     f01041c2 <.L36+0x56>
f01041d6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01041d9:	8b 55 c8             	mov    -0x38(%ebp),%edx
f01041dc:	85 d2                	test   %edx,%edx
f01041de:	b8 00 00 00 00       	mov    $0x0,%eax
f01041e3:	0f 49 c2             	cmovns %edx,%eax
f01041e6:	29 c2                	sub    %eax,%edx
f01041e8:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01041eb:	89 75 0c             	mov    %esi,0xc(%ebp)
f01041ee:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01041f1:	eb 17                	jmp    f010420a <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
f01041f3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01041f7:	75 30                	jne    f0104229 <.L36+0xbd>
					putch(ch, putdat);
f01041f9:	83 ec 08             	sub    $0x8,%esp
f01041fc:	ff 75 0c             	pushl  0xc(%ebp)
f01041ff:	50                   	push   %eax
f0104200:	ff 55 08             	call   *0x8(%ebp)
f0104203:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104206:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
f010420a:	83 c7 01             	add    $0x1,%edi
f010420d:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f0104211:	0f be c2             	movsbl %dl,%eax
f0104214:	85 c0                	test   %eax,%eax
f0104216:	74 52                	je     f010426a <.L36+0xfe>
f0104218:	85 f6                	test   %esi,%esi
f010421a:	78 d7                	js     f01041f3 <.L36+0x87>
f010421c:	83 ee 01             	sub    $0x1,%esi
f010421f:	79 d2                	jns    f01041f3 <.L36+0x87>
f0104221:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104224:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104227:	eb 32                	jmp    f010425b <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
f0104229:	0f be d2             	movsbl %dl,%edx
f010422c:	83 ea 20             	sub    $0x20,%edx
f010422f:	83 fa 5e             	cmp    $0x5e,%edx
f0104232:	76 c5                	jbe    f01041f9 <.L36+0x8d>
					putch('?', putdat);
f0104234:	83 ec 08             	sub    $0x8,%esp
f0104237:	ff 75 0c             	pushl  0xc(%ebp)
f010423a:	6a 3f                	push   $0x3f
f010423c:	ff 55 08             	call   *0x8(%ebp)
f010423f:	83 c4 10             	add    $0x10,%esp
f0104242:	eb c2                	jmp    f0104206 <.L36+0x9a>
f0104244:	89 75 0c             	mov    %esi,0xc(%ebp)
f0104247:	8b 75 cc             	mov    -0x34(%ebp),%esi
f010424a:	eb be                	jmp    f010420a <.L36+0x9e>
				putch(' ', putdat);
f010424c:	83 ec 08             	sub    $0x8,%esp
f010424f:	56                   	push   %esi
f0104250:	6a 20                	push   $0x20
f0104252:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
f0104255:	83 ef 01             	sub    $0x1,%edi
f0104258:	83 c4 10             	add    $0x10,%esp
f010425b:	85 ff                	test   %edi,%edi
f010425d:	7f ed                	jg     f010424c <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
f010425f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104262:	89 45 14             	mov    %eax,0x14(%ebp)
f0104265:	e9 7b 01 00 00       	jmp    f01043e5 <.L35+0x45>
f010426a:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010426d:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104270:	eb e9                	jmp    f010425b <.L36+0xef>

f0104272 <.L31>:
f0104272:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f0104275:	83 f9 01             	cmp    $0x1,%ecx
f0104278:	7e 40                	jle    f01042ba <.L31+0x48>
		return va_arg(*ap, long long);
f010427a:	8b 45 14             	mov    0x14(%ebp),%eax
f010427d:	8b 50 04             	mov    0x4(%eax),%edx
f0104280:	8b 00                	mov    (%eax),%eax
f0104282:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104285:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104288:	8b 45 14             	mov    0x14(%ebp),%eax
f010428b:	8d 40 08             	lea    0x8(%eax),%eax
f010428e:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0104291:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0104295:	79 55                	jns    f01042ec <.L31+0x7a>
				putch('-', putdat);
f0104297:	83 ec 08             	sub    $0x8,%esp
f010429a:	56                   	push   %esi
f010429b:	6a 2d                	push   $0x2d
f010429d:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f01042a0:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01042a3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01042a6:	f7 da                	neg    %edx
f01042a8:	83 d1 00             	adc    $0x0,%ecx
f01042ab:	f7 d9                	neg    %ecx
f01042ad:	83 c4 10             	add    $0x10,%esp
			base = 10;
f01042b0:	b8 0a 00 00 00       	mov    $0xa,%eax
f01042b5:	e9 10 01 00 00       	jmp    f01043ca <.L35+0x2a>
	else if (lflag)
f01042ba:	85 c9                	test   %ecx,%ecx
f01042bc:	75 17                	jne    f01042d5 <.L31+0x63>
		return va_arg(*ap, int);
f01042be:	8b 45 14             	mov    0x14(%ebp),%eax
f01042c1:	8b 00                	mov    (%eax),%eax
f01042c3:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01042c6:	99                   	cltd   
f01042c7:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01042ca:	8b 45 14             	mov    0x14(%ebp),%eax
f01042cd:	8d 40 04             	lea    0x4(%eax),%eax
f01042d0:	89 45 14             	mov    %eax,0x14(%ebp)
f01042d3:	eb bc                	jmp    f0104291 <.L31+0x1f>
		return va_arg(*ap, long);
f01042d5:	8b 45 14             	mov    0x14(%ebp),%eax
f01042d8:	8b 00                	mov    (%eax),%eax
f01042da:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01042dd:	99                   	cltd   
f01042de:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01042e1:	8b 45 14             	mov    0x14(%ebp),%eax
f01042e4:	8d 40 04             	lea    0x4(%eax),%eax
f01042e7:	89 45 14             	mov    %eax,0x14(%ebp)
f01042ea:	eb a5                	jmp    f0104291 <.L31+0x1f>
			num = getint(&ap, lflag);
f01042ec:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01042ef:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f01042f2:	b8 0a 00 00 00       	mov    $0xa,%eax
f01042f7:	e9 ce 00 00 00       	jmp    f01043ca <.L35+0x2a>

f01042fc <.L37>:
f01042fc:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f01042ff:	83 f9 01             	cmp    $0x1,%ecx
f0104302:	7e 18                	jle    f010431c <.L37+0x20>
		return va_arg(*ap, unsigned long long);
f0104304:	8b 45 14             	mov    0x14(%ebp),%eax
f0104307:	8b 10                	mov    (%eax),%edx
f0104309:	8b 48 04             	mov    0x4(%eax),%ecx
f010430c:	8d 40 08             	lea    0x8(%eax),%eax
f010430f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104312:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104317:	e9 ae 00 00 00       	jmp    f01043ca <.L35+0x2a>
	else if (lflag)
f010431c:	85 c9                	test   %ecx,%ecx
f010431e:	75 1a                	jne    f010433a <.L37+0x3e>
		return va_arg(*ap, unsigned int);
f0104320:	8b 45 14             	mov    0x14(%ebp),%eax
f0104323:	8b 10                	mov    (%eax),%edx
f0104325:	b9 00 00 00 00       	mov    $0x0,%ecx
f010432a:	8d 40 04             	lea    0x4(%eax),%eax
f010432d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104330:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104335:	e9 90 00 00 00       	jmp    f01043ca <.L35+0x2a>
		return va_arg(*ap, unsigned long);
f010433a:	8b 45 14             	mov    0x14(%ebp),%eax
f010433d:	8b 10                	mov    (%eax),%edx
f010433f:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104344:	8d 40 04             	lea    0x4(%eax),%eax
f0104347:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010434a:	b8 0a 00 00 00       	mov    $0xa,%eax
f010434f:	eb 79                	jmp    f01043ca <.L35+0x2a>

f0104351 <.L34>:
f0104351:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f0104354:	83 f9 01             	cmp    $0x1,%ecx
f0104357:	7e 15                	jle    f010436e <.L34+0x1d>
		return va_arg(*ap, unsigned long long);
f0104359:	8b 45 14             	mov    0x14(%ebp),%eax
f010435c:	8b 10                	mov    (%eax),%edx
f010435e:	8b 48 04             	mov    0x4(%eax),%ecx
f0104361:	8d 40 08             	lea    0x8(%eax),%eax
f0104364:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0104367:	b8 08 00 00 00       	mov    $0x8,%eax
f010436c:	eb 5c                	jmp    f01043ca <.L35+0x2a>
	else if (lflag)
f010436e:	85 c9                	test   %ecx,%ecx
f0104370:	75 17                	jne    f0104389 <.L34+0x38>
		return va_arg(*ap, unsigned int);
f0104372:	8b 45 14             	mov    0x14(%ebp),%eax
f0104375:	8b 10                	mov    (%eax),%edx
f0104377:	b9 00 00 00 00       	mov    $0x0,%ecx
f010437c:	8d 40 04             	lea    0x4(%eax),%eax
f010437f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0104382:	b8 08 00 00 00       	mov    $0x8,%eax
f0104387:	eb 41                	jmp    f01043ca <.L35+0x2a>
		return va_arg(*ap, unsigned long);
f0104389:	8b 45 14             	mov    0x14(%ebp),%eax
f010438c:	8b 10                	mov    (%eax),%edx
f010438e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104393:	8d 40 04             	lea    0x4(%eax),%eax
f0104396:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0104399:	b8 08 00 00 00       	mov    $0x8,%eax
f010439e:	eb 2a                	jmp    f01043ca <.L35+0x2a>

f01043a0 <.L35>:
			putch('0', putdat);
f01043a0:	83 ec 08             	sub    $0x8,%esp
f01043a3:	56                   	push   %esi
f01043a4:	6a 30                	push   $0x30
f01043a6:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f01043a9:	83 c4 08             	add    $0x8,%esp
f01043ac:	56                   	push   %esi
f01043ad:	6a 78                	push   $0x78
f01043af:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
f01043b2:	8b 45 14             	mov    0x14(%ebp),%eax
f01043b5:	8b 10                	mov    (%eax),%edx
f01043b7:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f01043bc:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f01043bf:	8d 40 04             	lea    0x4(%eax),%eax
f01043c2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01043c5:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f01043ca:	83 ec 0c             	sub    $0xc,%esp
f01043cd:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f01043d1:	57                   	push   %edi
f01043d2:	ff 75 e0             	pushl  -0x20(%ebp)
f01043d5:	50                   	push   %eax
f01043d6:	51                   	push   %ecx
f01043d7:	52                   	push   %edx
f01043d8:	89 f2                	mov    %esi,%edx
f01043da:	8b 45 08             	mov    0x8(%ebp),%eax
f01043dd:	e8 20 fb ff ff       	call   f0103f02 <printnum>
			break;
f01043e2:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f01043e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01043e8:	83 c7 01             	add    $0x1,%edi
f01043eb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01043ef:	83 f8 25             	cmp    $0x25,%eax
f01043f2:	0f 84 2d fc ff ff    	je     f0104025 <vprintfmt+0x1f>
			if (ch == '\0')
f01043f8:	85 c0                	test   %eax,%eax
f01043fa:	0f 84 91 00 00 00    	je     f0104491 <.L22+0x21>
			putch(ch, putdat);
f0104400:	83 ec 08             	sub    $0x8,%esp
f0104403:	56                   	push   %esi
f0104404:	50                   	push   %eax
f0104405:	ff 55 08             	call   *0x8(%ebp)
f0104408:	83 c4 10             	add    $0x10,%esp
f010440b:	eb db                	jmp    f01043e8 <.L35+0x48>

f010440d <.L38>:
f010440d:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f0104410:	83 f9 01             	cmp    $0x1,%ecx
f0104413:	7e 15                	jle    f010442a <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
f0104415:	8b 45 14             	mov    0x14(%ebp),%eax
f0104418:	8b 10                	mov    (%eax),%edx
f010441a:	8b 48 04             	mov    0x4(%eax),%ecx
f010441d:	8d 40 08             	lea    0x8(%eax),%eax
f0104420:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104423:	b8 10 00 00 00       	mov    $0x10,%eax
f0104428:	eb a0                	jmp    f01043ca <.L35+0x2a>
	else if (lflag)
f010442a:	85 c9                	test   %ecx,%ecx
f010442c:	75 17                	jne    f0104445 <.L38+0x38>
		return va_arg(*ap, unsigned int);
f010442e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104431:	8b 10                	mov    (%eax),%edx
f0104433:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104438:	8d 40 04             	lea    0x4(%eax),%eax
f010443b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010443e:	b8 10 00 00 00       	mov    $0x10,%eax
f0104443:	eb 85                	jmp    f01043ca <.L35+0x2a>
		return va_arg(*ap, unsigned long);
f0104445:	8b 45 14             	mov    0x14(%ebp),%eax
f0104448:	8b 10                	mov    (%eax),%edx
f010444a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010444f:	8d 40 04             	lea    0x4(%eax),%eax
f0104452:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104455:	b8 10 00 00 00       	mov    $0x10,%eax
f010445a:	e9 6b ff ff ff       	jmp    f01043ca <.L35+0x2a>

f010445f <.L25>:
			putch(ch, putdat);
f010445f:	83 ec 08             	sub    $0x8,%esp
f0104462:	56                   	push   %esi
f0104463:	6a 25                	push   $0x25
f0104465:	ff 55 08             	call   *0x8(%ebp)
			break;
f0104468:	83 c4 10             	add    $0x10,%esp
f010446b:	e9 75 ff ff ff       	jmp    f01043e5 <.L35+0x45>

f0104470 <.L22>:
			putch('%', putdat);
f0104470:	83 ec 08             	sub    $0x8,%esp
f0104473:	56                   	push   %esi
f0104474:	6a 25                	push   $0x25
f0104476:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104479:	83 c4 10             	add    $0x10,%esp
f010447c:	89 f8                	mov    %edi,%eax
f010447e:	eb 03                	jmp    f0104483 <.L22+0x13>
f0104480:	83 e8 01             	sub    $0x1,%eax
f0104483:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0104487:	75 f7                	jne    f0104480 <.L22+0x10>
f0104489:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010448c:	e9 54 ff ff ff       	jmp    f01043e5 <.L35+0x45>
}
f0104491:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104494:	5b                   	pop    %ebx
f0104495:	5e                   	pop    %esi
f0104496:	5f                   	pop    %edi
f0104497:	5d                   	pop    %ebp
f0104498:	c3                   	ret    

f0104499 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0104499:	55                   	push   %ebp
f010449a:	89 e5                	mov    %esp,%ebp
f010449c:	53                   	push   %ebx
f010449d:	83 ec 14             	sub    $0x14,%esp
f01044a0:	e8 01 bd ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f01044a5:	81 c3 7b 6b 08 00    	add    $0x86b7b,%ebx
f01044ab:	8b 45 08             	mov    0x8(%ebp),%eax
f01044ae:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01044b1:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01044b4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01044b8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01044bb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01044c2:	85 c0                	test   %eax,%eax
f01044c4:	74 2b                	je     f01044f1 <vsnprintf+0x58>
f01044c6:	85 d2                	test   %edx,%edx
f01044c8:	7e 27                	jle    f01044f1 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01044ca:	ff 75 14             	pushl  0x14(%ebp)
f01044cd:	ff 75 10             	pushl  0x10(%ebp)
f01044d0:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01044d3:	50                   	push   %eax
f01044d4:	8d 83 ac 8f f7 ff    	lea    -0x87054(%ebx),%eax
f01044da:	50                   	push   %eax
f01044db:	e8 26 fb ff ff       	call   f0104006 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01044e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01044e3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01044e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01044e9:	83 c4 10             	add    $0x10,%esp
}
f01044ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01044ef:	c9                   	leave  
f01044f0:	c3                   	ret    
		return -E_INVAL;
f01044f1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01044f6:	eb f4                	jmp    f01044ec <vsnprintf+0x53>

f01044f8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01044f8:	55                   	push   %ebp
f01044f9:	89 e5                	mov    %esp,%ebp
f01044fb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01044fe:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0104501:	50                   	push   %eax
f0104502:	ff 75 10             	pushl  0x10(%ebp)
f0104505:	ff 75 0c             	pushl  0xc(%ebp)
f0104508:	ff 75 08             	pushl  0x8(%ebp)
f010450b:	e8 89 ff ff ff       	call   f0104499 <vsnprintf>
	va_end(ap);

	return rc;
}
f0104510:	c9                   	leave  
f0104511:	c3                   	ret    

f0104512 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104512:	55                   	push   %ebp
f0104513:	89 e5                	mov    %esp,%ebp
f0104515:	57                   	push   %edi
f0104516:	56                   	push   %esi
f0104517:	53                   	push   %ebx
f0104518:	83 ec 1c             	sub    $0x1c,%esp
f010451b:	e8 86 bc ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f0104520:	81 c3 00 6b 08 00    	add    $0x86b00,%ebx
f0104526:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0104529:	85 c0                	test   %eax,%eax
f010452b:	74 13                	je     f0104540 <readline+0x2e>
		cprintf("%s", prompt);
f010452d:	83 ec 08             	sub    $0x8,%esp
f0104530:	50                   	push   %eax
f0104531:	8d 83 05 a9 f7 ff    	lea    -0x856fb(%ebx),%eax
f0104537:	50                   	push   %eax
f0104538:	e8 99 f1 ff ff       	call   f01036d6 <cprintf>
f010453d:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0104540:	83 ec 0c             	sub    $0xc,%esp
f0104543:	6a 00                	push   $0x0
f0104545:	e8 f4 c1 ff ff       	call   f010073e <iscons>
f010454a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010454d:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0104550:	bf 00 00 00 00       	mov    $0x0,%edi
f0104555:	eb 46                	jmp    f010459d <readline+0x8b>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f0104557:	83 ec 08             	sub    $0x8,%esp
f010455a:	50                   	push   %eax
f010455b:	8d 83 e8 b1 f7 ff    	lea    -0x84e18(%ebx),%eax
f0104561:	50                   	push   %eax
f0104562:	e8 6f f1 ff ff       	call   f01036d6 <cprintf>
			return NULL;
f0104567:	83 c4 10             	add    $0x10,%esp
f010456a:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f010456f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104572:	5b                   	pop    %ebx
f0104573:	5e                   	pop    %esi
f0104574:	5f                   	pop    %edi
f0104575:	5d                   	pop    %ebp
f0104576:	c3                   	ret    
			if (echoing)
f0104577:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010457b:	75 05                	jne    f0104582 <readline+0x70>
			i--;
f010457d:	83 ef 01             	sub    $0x1,%edi
f0104580:	eb 1b                	jmp    f010459d <readline+0x8b>
				cputchar('\b');
f0104582:	83 ec 0c             	sub    $0xc,%esp
f0104585:	6a 08                	push   $0x8
f0104587:	e8 91 c1 ff ff       	call   f010071d <cputchar>
f010458c:	83 c4 10             	add    $0x10,%esp
f010458f:	eb ec                	jmp    f010457d <readline+0x6b>
			buf[i++] = c;
f0104591:	89 f0                	mov    %esi,%eax
f0104593:	88 84 3b e0 2b 00 00 	mov    %al,0x2be0(%ebx,%edi,1)
f010459a:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f010459d:	e8 8b c1 ff ff       	call   f010072d <getchar>
f01045a2:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f01045a4:	85 c0                	test   %eax,%eax
f01045a6:	78 af                	js     f0104557 <readline+0x45>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01045a8:	83 f8 08             	cmp    $0x8,%eax
f01045ab:	0f 94 c2             	sete   %dl
f01045ae:	83 f8 7f             	cmp    $0x7f,%eax
f01045b1:	0f 94 c0             	sete   %al
f01045b4:	08 c2                	or     %al,%dl
f01045b6:	74 04                	je     f01045bc <readline+0xaa>
f01045b8:	85 ff                	test   %edi,%edi
f01045ba:	7f bb                	jg     f0104577 <readline+0x65>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01045bc:	83 fe 1f             	cmp    $0x1f,%esi
f01045bf:	7e 1c                	jle    f01045dd <readline+0xcb>
f01045c1:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f01045c7:	7f 14                	jg     f01045dd <readline+0xcb>
			if (echoing)
f01045c9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01045cd:	74 c2                	je     f0104591 <readline+0x7f>
				cputchar(c);
f01045cf:	83 ec 0c             	sub    $0xc,%esp
f01045d2:	56                   	push   %esi
f01045d3:	e8 45 c1 ff ff       	call   f010071d <cputchar>
f01045d8:	83 c4 10             	add    $0x10,%esp
f01045db:	eb b4                	jmp    f0104591 <readline+0x7f>
		} else if (c == '\n' || c == '\r') {
f01045dd:	83 fe 0a             	cmp    $0xa,%esi
f01045e0:	74 05                	je     f01045e7 <readline+0xd5>
f01045e2:	83 fe 0d             	cmp    $0xd,%esi
f01045e5:	75 b6                	jne    f010459d <readline+0x8b>
			if (echoing)
f01045e7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01045eb:	75 13                	jne    f0104600 <readline+0xee>
			buf[i] = 0;
f01045ed:	c6 84 3b e0 2b 00 00 	movb   $0x0,0x2be0(%ebx,%edi,1)
f01045f4:	00 
			return buf;
f01045f5:	8d 83 e0 2b 00 00    	lea    0x2be0(%ebx),%eax
f01045fb:	e9 6f ff ff ff       	jmp    f010456f <readline+0x5d>
				cputchar('\n');
f0104600:	83 ec 0c             	sub    $0xc,%esp
f0104603:	6a 0a                	push   $0xa
f0104605:	e8 13 c1 ff ff       	call   f010071d <cputchar>
f010460a:	83 c4 10             	add    $0x10,%esp
f010460d:	eb de                	jmp    f01045ed <readline+0xdb>

f010460f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010460f:	55                   	push   %ebp
f0104610:	89 e5                	mov    %esp,%ebp
f0104612:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104615:	b8 00 00 00 00       	mov    $0x0,%eax
f010461a:	eb 03                	jmp    f010461f <strlen+0x10>
		n++;
f010461c:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f010461f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0104623:	75 f7                	jne    f010461c <strlen+0xd>
	return n;
}
f0104625:	5d                   	pop    %ebp
f0104626:	c3                   	ret    

f0104627 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0104627:	55                   	push   %ebp
f0104628:	89 e5                	mov    %esp,%ebp
f010462a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010462d:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104630:	b8 00 00 00 00       	mov    $0x0,%eax
f0104635:	eb 03                	jmp    f010463a <strnlen+0x13>
		n++;
f0104637:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010463a:	39 d0                	cmp    %edx,%eax
f010463c:	74 06                	je     f0104644 <strnlen+0x1d>
f010463e:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0104642:	75 f3                	jne    f0104637 <strnlen+0x10>
	return n;
}
f0104644:	5d                   	pop    %ebp
f0104645:	c3                   	ret    

f0104646 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0104646:	55                   	push   %ebp
f0104647:	89 e5                	mov    %esp,%ebp
f0104649:	53                   	push   %ebx
f010464a:	8b 45 08             	mov    0x8(%ebp),%eax
f010464d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0104650:	89 c2                	mov    %eax,%edx
f0104652:	83 c1 01             	add    $0x1,%ecx
f0104655:	83 c2 01             	add    $0x1,%edx
f0104658:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f010465c:	88 5a ff             	mov    %bl,-0x1(%edx)
f010465f:	84 db                	test   %bl,%bl
f0104661:	75 ef                	jne    f0104652 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0104663:	5b                   	pop    %ebx
f0104664:	5d                   	pop    %ebp
f0104665:	c3                   	ret    

f0104666 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0104666:	55                   	push   %ebp
f0104667:	89 e5                	mov    %esp,%ebp
f0104669:	53                   	push   %ebx
f010466a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f010466d:	53                   	push   %ebx
f010466e:	e8 9c ff ff ff       	call   f010460f <strlen>
f0104673:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0104676:	ff 75 0c             	pushl  0xc(%ebp)
f0104679:	01 d8                	add    %ebx,%eax
f010467b:	50                   	push   %eax
f010467c:	e8 c5 ff ff ff       	call   f0104646 <strcpy>
	return dst;
}
f0104681:	89 d8                	mov    %ebx,%eax
f0104683:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104686:	c9                   	leave  
f0104687:	c3                   	ret    

f0104688 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0104688:	55                   	push   %ebp
f0104689:	89 e5                	mov    %esp,%ebp
f010468b:	56                   	push   %esi
f010468c:	53                   	push   %ebx
f010468d:	8b 75 08             	mov    0x8(%ebp),%esi
f0104690:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104693:	89 f3                	mov    %esi,%ebx
f0104695:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104698:	89 f2                	mov    %esi,%edx
f010469a:	eb 0f                	jmp    f01046ab <strncpy+0x23>
		*dst++ = *src;
f010469c:	83 c2 01             	add    $0x1,%edx
f010469f:	0f b6 01             	movzbl (%ecx),%eax
f01046a2:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01046a5:	80 39 01             	cmpb   $0x1,(%ecx)
f01046a8:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
f01046ab:	39 da                	cmp    %ebx,%edx
f01046ad:	75 ed                	jne    f010469c <strncpy+0x14>
	}
	return ret;
}
f01046af:	89 f0                	mov    %esi,%eax
f01046b1:	5b                   	pop    %ebx
f01046b2:	5e                   	pop    %esi
f01046b3:	5d                   	pop    %ebp
f01046b4:	c3                   	ret    

f01046b5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01046b5:	55                   	push   %ebp
f01046b6:	89 e5                	mov    %esp,%ebp
f01046b8:	56                   	push   %esi
f01046b9:	53                   	push   %ebx
f01046ba:	8b 75 08             	mov    0x8(%ebp),%esi
f01046bd:	8b 55 0c             	mov    0xc(%ebp),%edx
f01046c0:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01046c3:	89 f0                	mov    %esi,%eax
f01046c5:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01046c9:	85 c9                	test   %ecx,%ecx
f01046cb:	75 0b                	jne    f01046d8 <strlcpy+0x23>
f01046cd:	eb 17                	jmp    f01046e6 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01046cf:	83 c2 01             	add    $0x1,%edx
f01046d2:	83 c0 01             	add    $0x1,%eax
f01046d5:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f01046d8:	39 d8                	cmp    %ebx,%eax
f01046da:	74 07                	je     f01046e3 <strlcpy+0x2e>
f01046dc:	0f b6 0a             	movzbl (%edx),%ecx
f01046df:	84 c9                	test   %cl,%cl
f01046e1:	75 ec                	jne    f01046cf <strlcpy+0x1a>
		*dst = '\0';
f01046e3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01046e6:	29 f0                	sub    %esi,%eax
}
f01046e8:	5b                   	pop    %ebx
f01046e9:	5e                   	pop    %esi
f01046ea:	5d                   	pop    %ebp
f01046eb:	c3                   	ret    

f01046ec <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01046ec:	55                   	push   %ebp
f01046ed:	89 e5                	mov    %esp,%ebp
f01046ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01046f2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01046f5:	eb 06                	jmp    f01046fd <strcmp+0x11>
		p++, q++;
f01046f7:	83 c1 01             	add    $0x1,%ecx
f01046fa:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f01046fd:	0f b6 01             	movzbl (%ecx),%eax
f0104700:	84 c0                	test   %al,%al
f0104702:	74 04                	je     f0104708 <strcmp+0x1c>
f0104704:	3a 02                	cmp    (%edx),%al
f0104706:	74 ef                	je     f01046f7 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0104708:	0f b6 c0             	movzbl %al,%eax
f010470b:	0f b6 12             	movzbl (%edx),%edx
f010470e:	29 d0                	sub    %edx,%eax
}
f0104710:	5d                   	pop    %ebp
f0104711:	c3                   	ret    

f0104712 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0104712:	55                   	push   %ebp
f0104713:	89 e5                	mov    %esp,%ebp
f0104715:	53                   	push   %ebx
f0104716:	8b 45 08             	mov    0x8(%ebp),%eax
f0104719:	8b 55 0c             	mov    0xc(%ebp),%edx
f010471c:	89 c3                	mov    %eax,%ebx
f010471e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0104721:	eb 06                	jmp    f0104729 <strncmp+0x17>
		n--, p++, q++;
f0104723:	83 c0 01             	add    $0x1,%eax
f0104726:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0104729:	39 d8                	cmp    %ebx,%eax
f010472b:	74 16                	je     f0104743 <strncmp+0x31>
f010472d:	0f b6 08             	movzbl (%eax),%ecx
f0104730:	84 c9                	test   %cl,%cl
f0104732:	74 04                	je     f0104738 <strncmp+0x26>
f0104734:	3a 0a                	cmp    (%edx),%cl
f0104736:	74 eb                	je     f0104723 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0104738:	0f b6 00             	movzbl (%eax),%eax
f010473b:	0f b6 12             	movzbl (%edx),%edx
f010473e:	29 d0                	sub    %edx,%eax
}
f0104740:	5b                   	pop    %ebx
f0104741:	5d                   	pop    %ebp
f0104742:	c3                   	ret    
		return 0;
f0104743:	b8 00 00 00 00       	mov    $0x0,%eax
f0104748:	eb f6                	jmp    f0104740 <strncmp+0x2e>

f010474a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010474a:	55                   	push   %ebp
f010474b:	89 e5                	mov    %esp,%ebp
f010474d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104750:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104754:	0f b6 10             	movzbl (%eax),%edx
f0104757:	84 d2                	test   %dl,%dl
f0104759:	74 09                	je     f0104764 <strchr+0x1a>
		if (*s == c)
f010475b:	38 ca                	cmp    %cl,%dl
f010475d:	74 0a                	je     f0104769 <strchr+0x1f>
	for (; *s; s++)
f010475f:	83 c0 01             	add    $0x1,%eax
f0104762:	eb f0                	jmp    f0104754 <strchr+0xa>
			return (char *) s;
	return 0;
f0104764:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104769:	5d                   	pop    %ebp
f010476a:	c3                   	ret    

f010476b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010476b:	55                   	push   %ebp
f010476c:	89 e5                	mov    %esp,%ebp
f010476e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104771:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104775:	eb 03                	jmp    f010477a <strfind+0xf>
f0104777:	83 c0 01             	add    $0x1,%eax
f010477a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010477d:	38 ca                	cmp    %cl,%dl
f010477f:	74 04                	je     f0104785 <strfind+0x1a>
f0104781:	84 d2                	test   %dl,%dl
f0104783:	75 f2                	jne    f0104777 <strfind+0xc>
			break;
	return (char *) s;
}
f0104785:	5d                   	pop    %ebp
f0104786:	c3                   	ret    

f0104787 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0104787:	55                   	push   %ebp
f0104788:	89 e5                	mov    %esp,%ebp
f010478a:	57                   	push   %edi
f010478b:	56                   	push   %esi
f010478c:	53                   	push   %ebx
f010478d:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104790:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0104793:	85 c9                	test   %ecx,%ecx
f0104795:	74 13                	je     f01047aa <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0104797:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010479d:	75 05                	jne    f01047a4 <memset+0x1d>
f010479f:	f6 c1 03             	test   $0x3,%cl
f01047a2:	74 0d                	je     f01047b1 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01047a4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01047a7:	fc                   	cld    
f01047a8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01047aa:	89 f8                	mov    %edi,%eax
f01047ac:	5b                   	pop    %ebx
f01047ad:	5e                   	pop    %esi
f01047ae:	5f                   	pop    %edi
f01047af:	5d                   	pop    %ebp
f01047b0:	c3                   	ret    
		c &= 0xFF;
f01047b1:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01047b5:	89 d3                	mov    %edx,%ebx
f01047b7:	c1 e3 08             	shl    $0x8,%ebx
f01047ba:	89 d0                	mov    %edx,%eax
f01047bc:	c1 e0 18             	shl    $0x18,%eax
f01047bf:	89 d6                	mov    %edx,%esi
f01047c1:	c1 e6 10             	shl    $0x10,%esi
f01047c4:	09 f0                	or     %esi,%eax
f01047c6:	09 c2                	or     %eax,%edx
f01047c8:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f01047ca:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f01047cd:	89 d0                	mov    %edx,%eax
f01047cf:	fc                   	cld    
f01047d0:	f3 ab                	rep stos %eax,%es:(%edi)
f01047d2:	eb d6                	jmp    f01047aa <memset+0x23>

f01047d4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01047d4:	55                   	push   %ebp
f01047d5:	89 e5                	mov    %esp,%ebp
f01047d7:	57                   	push   %edi
f01047d8:	56                   	push   %esi
f01047d9:	8b 45 08             	mov    0x8(%ebp),%eax
f01047dc:	8b 75 0c             	mov    0xc(%ebp),%esi
f01047df:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01047e2:	39 c6                	cmp    %eax,%esi
f01047e4:	73 35                	jae    f010481b <memmove+0x47>
f01047e6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01047e9:	39 c2                	cmp    %eax,%edx
f01047eb:	76 2e                	jbe    f010481b <memmove+0x47>
		s += n;
		d += n;
f01047ed:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01047f0:	89 d6                	mov    %edx,%esi
f01047f2:	09 fe                	or     %edi,%esi
f01047f4:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01047fa:	74 0c                	je     f0104808 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01047fc:	83 ef 01             	sub    $0x1,%edi
f01047ff:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0104802:	fd                   	std    
f0104803:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0104805:	fc                   	cld    
f0104806:	eb 21                	jmp    f0104829 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104808:	f6 c1 03             	test   $0x3,%cl
f010480b:	75 ef                	jne    f01047fc <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f010480d:	83 ef 04             	sub    $0x4,%edi
f0104810:	8d 72 fc             	lea    -0x4(%edx),%esi
f0104813:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0104816:	fd                   	std    
f0104817:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104819:	eb ea                	jmp    f0104805 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010481b:	89 f2                	mov    %esi,%edx
f010481d:	09 c2                	or     %eax,%edx
f010481f:	f6 c2 03             	test   $0x3,%dl
f0104822:	74 09                	je     f010482d <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0104824:	89 c7                	mov    %eax,%edi
f0104826:	fc                   	cld    
f0104827:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0104829:	5e                   	pop    %esi
f010482a:	5f                   	pop    %edi
f010482b:	5d                   	pop    %ebp
f010482c:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010482d:	f6 c1 03             	test   $0x3,%cl
f0104830:	75 f2                	jne    f0104824 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0104832:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0104835:	89 c7                	mov    %eax,%edi
f0104837:	fc                   	cld    
f0104838:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010483a:	eb ed                	jmp    f0104829 <memmove+0x55>

f010483c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010483c:	55                   	push   %ebp
f010483d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010483f:	ff 75 10             	pushl  0x10(%ebp)
f0104842:	ff 75 0c             	pushl  0xc(%ebp)
f0104845:	ff 75 08             	pushl  0x8(%ebp)
f0104848:	e8 87 ff ff ff       	call   f01047d4 <memmove>
}
f010484d:	c9                   	leave  
f010484e:	c3                   	ret    

f010484f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010484f:	55                   	push   %ebp
f0104850:	89 e5                	mov    %esp,%ebp
f0104852:	56                   	push   %esi
f0104853:	53                   	push   %ebx
f0104854:	8b 45 08             	mov    0x8(%ebp),%eax
f0104857:	8b 55 0c             	mov    0xc(%ebp),%edx
f010485a:	89 c6                	mov    %eax,%esi
f010485c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010485f:	39 f0                	cmp    %esi,%eax
f0104861:	74 1c                	je     f010487f <memcmp+0x30>
		if (*s1 != *s2)
f0104863:	0f b6 08             	movzbl (%eax),%ecx
f0104866:	0f b6 1a             	movzbl (%edx),%ebx
f0104869:	38 d9                	cmp    %bl,%cl
f010486b:	75 08                	jne    f0104875 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f010486d:	83 c0 01             	add    $0x1,%eax
f0104870:	83 c2 01             	add    $0x1,%edx
f0104873:	eb ea                	jmp    f010485f <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f0104875:	0f b6 c1             	movzbl %cl,%eax
f0104878:	0f b6 db             	movzbl %bl,%ebx
f010487b:	29 d8                	sub    %ebx,%eax
f010487d:	eb 05                	jmp    f0104884 <memcmp+0x35>
	}

	return 0;
f010487f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104884:	5b                   	pop    %ebx
f0104885:	5e                   	pop    %esi
f0104886:	5d                   	pop    %ebp
f0104887:	c3                   	ret    

f0104888 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0104888:	55                   	push   %ebp
f0104889:	89 e5                	mov    %esp,%ebp
f010488b:	8b 45 08             	mov    0x8(%ebp),%eax
f010488e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0104891:	89 c2                	mov    %eax,%edx
f0104893:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0104896:	39 d0                	cmp    %edx,%eax
f0104898:	73 09                	jae    f01048a3 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f010489a:	38 08                	cmp    %cl,(%eax)
f010489c:	74 05                	je     f01048a3 <memfind+0x1b>
	for (; s < ends; s++)
f010489e:	83 c0 01             	add    $0x1,%eax
f01048a1:	eb f3                	jmp    f0104896 <memfind+0xe>
			break;
	return (void *) s;
}
f01048a3:	5d                   	pop    %ebp
f01048a4:	c3                   	ret    

f01048a5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01048a5:	55                   	push   %ebp
f01048a6:	89 e5                	mov    %esp,%ebp
f01048a8:	57                   	push   %edi
f01048a9:	56                   	push   %esi
f01048aa:	53                   	push   %ebx
f01048ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01048ae:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01048b1:	eb 03                	jmp    f01048b6 <strtol+0x11>
		s++;
f01048b3:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f01048b6:	0f b6 01             	movzbl (%ecx),%eax
f01048b9:	3c 20                	cmp    $0x20,%al
f01048bb:	74 f6                	je     f01048b3 <strtol+0xe>
f01048bd:	3c 09                	cmp    $0x9,%al
f01048bf:	74 f2                	je     f01048b3 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f01048c1:	3c 2b                	cmp    $0x2b,%al
f01048c3:	74 2e                	je     f01048f3 <strtol+0x4e>
	int neg = 0;
f01048c5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f01048ca:	3c 2d                	cmp    $0x2d,%al
f01048cc:	74 2f                	je     f01048fd <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01048ce:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01048d4:	75 05                	jne    f01048db <strtol+0x36>
f01048d6:	80 39 30             	cmpb   $0x30,(%ecx)
f01048d9:	74 2c                	je     f0104907 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01048db:	85 db                	test   %ebx,%ebx
f01048dd:	75 0a                	jne    f01048e9 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01048df:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
f01048e4:	80 39 30             	cmpb   $0x30,(%ecx)
f01048e7:	74 28                	je     f0104911 <strtol+0x6c>
		base = 10;
f01048e9:	b8 00 00 00 00       	mov    $0x0,%eax
f01048ee:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01048f1:	eb 50                	jmp    f0104943 <strtol+0x9e>
		s++;
f01048f3:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f01048f6:	bf 00 00 00 00       	mov    $0x0,%edi
f01048fb:	eb d1                	jmp    f01048ce <strtol+0x29>
		s++, neg = 1;
f01048fd:	83 c1 01             	add    $0x1,%ecx
f0104900:	bf 01 00 00 00       	mov    $0x1,%edi
f0104905:	eb c7                	jmp    f01048ce <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104907:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f010490b:	74 0e                	je     f010491b <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f010490d:	85 db                	test   %ebx,%ebx
f010490f:	75 d8                	jne    f01048e9 <strtol+0x44>
		s++, base = 8;
f0104911:	83 c1 01             	add    $0x1,%ecx
f0104914:	bb 08 00 00 00       	mov    $0x8,%ebx
f0104919:	eb ce                	jmp    f01048e9 <strtol+0x44>
		s += 2, base = 16;
f010491b:	83 c1 02             	add    $0x2,%ecx
f010491e:	bb 10 00 00 00       	mov    $0x10,%ebx
f0104923:	eb c4                	jmp    f01048e9 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f0104925:	8d 72 9f             	lea    -0x61(%edx),%esi
f0104928:	89 f3                	mov    %esi,%ebx
f010492a:	80 fb 19             	cmp    $0x19,%bl
f010492d:	77 29                	ja     f0104958 <strtol+0xb3>
			dig = *s - 'a' + 10;
f010492f:	0f be d2             	movsbl %dl,%edx
f0104932:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0104935:	3b 55 10             	cmp    0x10(%ebp),%edx
f0104938:	7d 30                	jge    f010496a <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f010493a:	83 c1 01             	add    $0x1,%ecx
f010493d:	0f af 45 10          	imul   0x10(%ebp),%eax
f0104941:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0104943:	0f b6 11             	movzbl (%ecx),%edx
f0104946:	8d 72 d0             	lea    -0x30(%edx),%esi
f0104949:	89 f3                	mov    %esi,%ebx
f010494b:	80 fb 09             	cmp    $0x9,%bl
f010494e:	77 d5                	ja     f0104925 <strtol+0x80>
			dig = *s - '0';
f0104950:	0f be d2             	movsbl %dl,%edx
f0104953:	83 ea 30             	sub    $0x30,%edx
f0104956:	eb dd                	jmp    f0104935 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
f0104958:	8d 72 bf             	lea    -0x41(%edx),%esi
f010495b:	89 f3                	mov    %esi,%ebx
f010495d:	80 fb 19             	cmp    $0x19,%bl
f0104960:	77 08                	ja     f010496a <strtol+0xc5>
			dig = *s - 'A' + 10;
f0104962:	0f be d2             	movsbl %dl,%edx
f0104965:	83 ea 37             	sub    $0x37,%edx
f0104968:	eb cb                	jmp    f0104935 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
f010496a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010496e:	74 05                	je     f0104975 <strtol+0xd0>
		*endptr = (char *) s;
f0104970:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104973:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0104975:	89 c2                	mov    %eax,%edx
f0104977:	f7 da                	neg    %edx
f0104979:	85 ff                	test   %edi,%edi
f010497b:	0f 45 c2             	cmovne %edx,%eax
}
f010497e:	5b                   	pop    %ebx
f010497f:	5e                   	pop    %esi
f0104980:	5f                   	pop    %edi
f0104981:	5d                   	pop    %ebp
f0104982:	c3                   	ret    
f0104983:	66 90                	xchg   %ax,%ax
f0104985:	66 90                	xchg   %ax,%ax
f0104987:	66 90                	xchg   %ax,%ax
f0104989:	66 90                	xchg   %ax,%ax
f010498b:	66 90                	xchg   %ax,%ax
f010498d:	66 90                	xchg   %ax,%ax
f010498f:	90                   	nop

f0104990 <__udivdi3>:
f0104990:	55                   	push   %ebp
f0104991:	57                   	push   %edi
f0104992:	56                   	push   %esi
f0104993:	53                   	push   %ebx
f0104994:	83 ec 1c             	sub    $0x1c,%esp
f0104997:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010499b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f010499f:	8b 74 24 34          	mov    0x34(%esp),%esi
f01049a3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f01049a7:	85 d2                	test   %edx,%edx
f01049a9:	75 35                	jne    f01049e0 <__udivdi3+0x50>
f01049ab:	39 f3                	cmp    %esi,%ebx
f01049ad:	0f 87 bd 00 00 00    	ja     f0104a70 <__udivdi3+0xe0>
f01049b3:	85 db                	test   %ebx,%ebx
f01049b5:	89 d9                	mov    %ebx,%ecx
f01049b7:	75 0b                	jne    f01049c4 <__udivdi3+0x34>
f01049b9:	b8 01 00 00 00       	mov    $0x1,%eax
f01049be:	31 d2                	xor    %edx,%edx
f01049c0:	f7 f3                	div    %ebx
f01049c2:	89 c1                	mov    %eax,%ecx
f01049c4:	31 d2                	xor    %edx,%edx
f01049c6:	89 f0                	mov    %esi,%eax
f01049c8:	f7 f1                	div    %ecx
f01049ca:	89 c6                	mov    %eax,%esi
f01049cc:	89 e8                	mov    %ebp,%eax
f01049ce:	89 f7                	mov    %esi,%edi
f01049d0:	f7 f1                	div    %ecx
f01049d2:	89 fa                	mov    %edi,%edx
f01049d4:	83 c4 1c             	add    $0x1c,%esp
f01049d7:	5b                   	pop    %ebx
f01049d8:	5e                   	pop    %esi
f01049d9:	5f                   	pop    %edi
f01049da:	5d                   	pop    %ebp
f01049db:	c3                   	ret    
f01049dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01049e0:	39 f2                	cmp    %esi,%edx
f01049e2:	77 7c                	ja     f0104a60 <__udivdi3+0xd0>
f01049e4:	0f bd fa             	bsr    %edx,%edi
f01049e7:	83 f7 1f             	xor    $0x1f,%edi
f01049ea:	0f 84 98 00 00 00    	je     f0104a88 <__udivdi3+0xf8>
f01049f0:	89 f9                	mov    %edi,%ecx
f01049f2:	b8 20 00 00 00       	mov    $0x20,%eax
f01049f7:	29 f8                	sub    %edi,%eax
f01049f9:	d3 e2                	shl    %cl,%edx
f01049fb:	89 54 24 08          	mov    %edx,0x8(%esp)
f01049ff:	89 c1                	mov    %eax,%ecx
f0104a01:	89 da                	mov    %ebx,%edx
f0104a03:	d3 ea                	shr    %cl,%edx
f0104a05:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0104a09:	09 d1                	or     %edx,%ecx
f0104a0b:	89 f2                	mov    %esi,%edx
f0104a0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104a11:	89 f9                	mov    %edi,%ecx
f0104a13:	d3 e3                	shl    %cl,%ebx
f0104a15:	89 c1                	mov    %eax,%ecx
f0104a17:	d3 ea                	shr    %cl,%edx
f0104a19:	89 f9                	mov    %edi,%ecx
f0104a1b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0104a1f:	d3 e6                	shl    %cl,%esi
f0104a21:	89 eb                	mov    %ebp,%ebx
f0104a23:	89 c1                	mov    %eax,%ecx
f0104a25:	d3 eb                	shr    %cl,%ebx
f0104a27:	09 de                	or     %ebx,%esi
f0104a29:	89 f0                	mov    %esi,%eax
f0104a2b:	f7 74 24 08          	divl   0x8(%esp)
f0104a2f:	89 d6                	mov    %edx,%esi
f0104a31:	89 c3                	mov    %eax,%ebx
f0104a33:	f7 64 24 0c          	mull   0xc(%esp)
f0104a37:	39 d6                	cmp    %edx,%esi
f0104a39:	72 0c                	jb     f0104a47 <__udivdi3+0xb7>
f0104a3b:	89 f9                	mov    %edi,%ecx
f0104a3d:	d3 e5                	shl    %cl,%ebp
f0104a3f:	39 c5                	cmp    %eax,%ebp
f0104a41:	73 5d                	jae    f0104aa0 <__udivdi3+0x110>
f0104a43:	39 d6                	cmp    %edx,%esi
f0104a45:	75 59                	jne    f0104aa0 <__udivdi3+0x110>
f0104a47:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0104a4a:	31 ff                	xor    %edi,%edi
f0104a4c:	89 fa                	mov    %edi,%edx
f0104a4e:	83 c4 1c             	add    $0x1c,%esp
f0104a51:	5b                   	pop    %ebx
f0104a52:	5e                   	pop    %esi
f0104a53:	5f                   	pop    %edi
f0104a54:	5d                   	pop    %ebp
f0104a55:	c3                   	ret    
f0104a56:	8d 76 00             	lea    0x0(%esi),%esi
f0104a59:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f0104a60:	31 ff                	xor    %edi,%edi
f0104a62:	31 c0                	xor    %eax,%eax
f0104a64:	89 fa                	mov    %edi,%edx
f0104a66:	83 c4 1c             	add    $0x1c,%esp
f0104a69:	5b                   	pop    %ebx
f0104a6a:	5e                   	pop    %esi
f0104a6b:	5f                   	pop    %edi
f0104a6c:	5d                   	pop    %ebp
f0104a6d:	c3                   	ret    
f0104a6e:	66 90                	xchg   %ax,%ax
f0104a70:	31 ff                	xor    %edi,%edi
f0104a72:	89 e8                	mov    %ebp,%eax
f0104a74:	89 f2                	mov    %esi,%edx
f0104a76:	f7 f3                	div    %ebx
f0104a78:	89 fa                	mov    %edi,%edx
f0104a7a:	83 c4 1c             	add    $0x1c,%esp
f0104a7d:	5b                   	pop    %ebx
f0104a7e:	5e                   	pop    %esi
f0104a7f:	5f                   	pop    %edi
f0104a80:	5d                   	pop    %ebp
f0104a81:	c3                   	ret    
f0104a82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104a88:	39 f2                	cmp    %esi,%edx
f0104a8a:	72 06                	jb     f0104a92 <__udivdi3+0x102>
f0104a8c:	31 c0                	xor    %eax,%eax
f0104a8e:	39 eb                	cmp    %ebp,%ebx
f0104a90:	77 d2                	ja     f0104a64 <__udivdi3+0xd4>
f0104a92:	b8 01 00 00 00       	mov    $0x1,%eax
f0104a97:	eb cb                	jmp    f0104a64 <__udivdi3+0xd4>
f0104a99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104aa0:	89 d8                	mov    %ebx,%eax
f0104aa2:	31 ff                	xor    %edi,%edi
f0104aa4:	eb be                	jmp    f0104a64 <__udivdi3+0xd4>
f0104aa6:	66 90                	xchg   %ax,%ax
f0104aa8:	66 90                	xchg   %ax,%ax
f0104aaa:	66 90                	xchg   %ax,%ax
f0104aac:	66 90                	xchg   %ax,%ax
f0104aae:	66 90                	xchg   %ax,%ax

f0104ab0 <__umoddi3>:
f0104ab0:	55                   	push   %ebp
f0104ab1:	57                   	push   %edi
f0104ab2:	56                   	push   %esi
f0104ab3:	53                   	push   %ebx
f0104ab4:	83 ec 1c             	sub    $0x1c,%esp
f0104ab7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f0104abb:	8b 74 24 30          	mov    0x30(%esp),%esi
f0104abf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0104ac3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0104ac7:	85 ed                	test   %ebp,%ebp
f0104ac9:	89 f0                	mov    %esi,%eax
f0104acb:	89 da                	mov    %ebx,%edx
f0104acd:	75 19                	jne    f0104ae8 <__umoddi3+0x38>
f0104acf:	39 df                	cmp    %ebx,%edi
f0104ad1:	0f 86 b1 00 00 00    	jbe    f0104b88 <__umoddi3+0xd8>
f0104ad7:	f7 f7                	div    %edi
f0104ad9:	89 d0                	mov    %edx,%eax
f0104adb:	31 d2                	xor    %edx,%edx
f0104add:	83 c4 1c             	add    $0x1c,%esp
f0104ae0:	5b                   	pop    %ebx
f0104ae1:	5e                   	pop    %esi
f0104ae2:	5f                   	pop    %edi
f0104ae3:	5d                   	pop    %ebp
f0104ae4:	c3                   	ret    
f0104ae5:	8d 76 00             	lea    0x0(%esi),%esi
f0104ae8:	39 dd                	cmp    %ebx,%ebp
f0104aea:	77 f1                	ja     f0104add <__umoddi3+0x2d>
f0104aec:	0f bd cd             	bsr    %ebp,%ecx
f0104aef:	83 f1 1f             	xor    $0x1f,%ecx
f0104af2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104af6:	0f 84 b4 00 00 00    	je     f0104bb0 <__umoddi3+0x100>
f0104afc:	b8 20 00 00 00       	mov    $0x20,%eax
f0104b01:	89 c2                	mov    %eax,%edx
f0104b03:	8b 44 24 04          	mov    0x4(%esp),%eax
f0104b07:	29 c2                	sub    %eax,%edx
f0104b09:	89 c1                	mov    %eax,%ecx
f0104b0b:	89 f8                	mov    %edi,%eax
f0104b0d:	d3 e5                	shl    %cl,%ebp
f0104b0f:	89 d1                	mov    %edx,%ecx
f0104b11:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104b15:	d3 e8                	shr    %cl,%eax
f0104b17:	09 c5                	or     %eax,%ebp
f0104b19:	8b 44 24 04          	mov    0x4(%esp),%eax
f0104b1d:	89 c1                	mov    %eax,%ecx
f0104b1f:	d3 e7                	shl    %cl,%edi
f0104b21:	89 d1                	mov    %edx,%ecx
f0104b23:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0104b27:	89 df                	mov    %ebx,%edi
f0104b29:	d3 ef                	shr    %cl,%edi
f0104b2b:	89 c1                	mov    %eax,%ecx
f0104b2d:	89 f0                	mov    %esi,%eax
f0104b2f:	d3 e3                	shl    %cl,%ebx
f0104b31:	89 d1                	mov    %edx,%ecx
f0104b33:	89 fa                	mov    %edi,%edx
f0104b35:	d3 e8                	shr    %cl,%eax
f0104b37:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0104b3c:	09 d8                	or     %ebx,%eax
f0104b3e:	f7 f5                	div    %ebp
f0104b40:	d3 e6                	shl    %cl,%esi
f0104b42:	89 d1                	mov    %edx,%ecx
f0104b44:	f7 64 24 08          	mull   0x8(%esp)
f0104b48:	39 d1                	cmp    %edx,%ecx
f0104b4a:	89 c3                	mov    %eax,%ebx
f0104b4c:	89 d7                	mov    %edx,%edi
f0104b4e:	72 06                	jb     f0104b56 <__umoddi3+0xa6>
f0104b50:	75 0e                	jne    f0104b60 <__umoddi3+0xb0>
f0104b52:	39 c6                	cmp    %eax,%esi
f0104b54:	73 0a                	jae    f0104b60 <__umoddi3+0xb0>
f0104b56:	2b 44 24 08          	sub    0x8(%esp),%eax
f0104b5a:	19 ea                	sbb    %ebp,%edx
f0104b5c:	89 d7                	mov    %edx,%edi
f0104b5e:	89 c3                	mov    %eax,%ebx
f0104b60:	89 ca                	mov    %ecx,%edx
f0104b62:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f0104b67:	29 de                	sub    %ebx,%esi
f0104b69:	19 fa                	sbb    %edi,%edx
f0104b6b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f0104b6f:	89 d0                	mov    %edx,%eax
f0104b71:	d3 e0                	shl    %cl,%eax
f0104b73:	89 d9                	mov    %ebx,%ecx
f0104b75:	d3 ee                	shr    %cl,%esi
f0104b77:	d3 ea                	shr    %cl,%edx
f0104b79:	09 f0                	or     %esi,%eax
f0104b7b:	83 c4 1c             	add    $0x1c,%esp
f0104b7e:	5b                   	pop    %ebx
f0104b7f:	5e                   	pop    %esi
f0104b80:	5f                   	pop    %edi
f0104b81:	5d                   	pop    %ebp
f0104b82:	c3                   	ret    
f0104b83:	90                   	nop
f0104b84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104b88:	85 ff                	test   %edi,%edi
f0104b8a:	89 f9                	mov    %edi,%ecx
f0104b8c:	75 0b                	jne    f0104b99 <__umoddi3+0xe9>
f0104b8e:	b8 01 00 00 00       	mov    $0x1,%eax
f0104b93:	31 d2                	xor    %edx,%edx
f0104b95:	f7 f7                	div    %edi
f0104b97:	89 c1                	mov    %eax,%ecx
f0104b99:	89 d8                	mov    %ebx,%eax
f0104b9b:	31 d2                	xor    %edx,%edx
f0104b9d:	f7 f1                	div    %ecx
f0104b9f:	89 f0                	mov    %esi,%eax
f0104ba1:	f7 f1                	div    %ecx
f0104ba3:	e9 31 ff ff ff       	jmp    f0104ad9 <__umoddi3+0x29>
f0104ba8:	90                   	nop
f0104ba9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104bb0:	39 dd                	cmp    %ebx,%ebp
f0104bb2:	72 08                	jb     f0104bbc <__umoddi3+0x10c>
f0104bb4:	39 f7                	cmp    %esi,%edi
f0104bb6:	0f 87 21 ff ff ff    	ja     f0104add <__umoddi3+0x2d>
f0104bbc:	89 da                	mov    %ebx,%edx
f0104bbe:	89 f0                	mov    %esi,%eax
f0104bc0:	29 f8                	sub    %edi,%eax
f0104bc2:	19 ea                	sbb    %ebp,%edx
f0104bc4:	e9 14 ff ff ff       	jmp    f0104add <__umoddi3+0x2d>
