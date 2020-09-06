
obj/user/faultalloc.debug:     file format elf32-i386


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
  80002c:	e8 99 00 00 00       	call   8000ca <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
  80003d:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  80003f:	53                   	push   %ebx
  800040:	68 e0 1e 80 00       	push   $0x801ee0
  800045:	e8 bb 01 00 00       	call   800205 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 bf 0b 00 00       	call   800c1d <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	78 16                	js     80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800065:	53                   	push   %ebx
  800066:	68 2c 1f 80 00       	push   $0x801f2c
  80006b:	6a 64                	push   $0x64
  80006d:	53                   	push   %ebx
  80006e:	e8 60 07 00 00       	call   8007d3 <snprintf>
}
  800073:	83 c4 10             	add    $0x10,%esp
  800076:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800079:	c9                   	leave  
  80007a:	c3                   	ret    
		panic("allocating at %x in page fault handler: %e", addr, r);
  80007b:	83 ec 0c             	sub    $0xc,%esp
  80007e:	50                   	push   %eax
  80007f:	53                   	push   %ebx
  800080:	68 00 1f 80 00       	push   $0x801f00
  800085:	6a 0e                	push   $0xe
  800087:	68 ea 1e 80 00       	push   $0x801eea
  80008c:	e8 99 00 00 00       	call   80012a <_panic>

00800091 <umain>:

void
umain(int argc, char **argv)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800097:	68 33 00 80 00       	push   $0x800033
  80009c:	e8 6d 0d 00 00       	call   800e0e <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	68 ef be ad de       	push   $0xdeadbeef
  8000a9:	68 fc 1e 80 00       	push   $0x801efc
  8000ae:	e8 52 01 00 00       	call   800205 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	68 fe bf fe ca       	push   $0xcafebffe
  8000bb:	68 fc 1e 80 00       	push   $0x801efc
  8000c0:	e8 40 01 00 00       	call   800205 <cprintf>
}
  8000c5:	83 c4 10             	add    $0x10,%esp
  8000c8:	c9                   	leave  
  8000c9:	c3                   	ret    

008000ca <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	56                   	push   %esi
  8000ce:	53                   	push   %ebx
  8000cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000d2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000d5:	e8 05 0b 00 00       	call   800bdf <sys_getenvid>
  8000da:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000df:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000e2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e7:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ec:	85 db                	test   %ebx,%ebx
  8000ee:	7e 07                	jle    8000f7 <libmain+0x2d>
		binaryname = argv[0];
  8000f0:	8b 06                	mov    (%esi),%eax
  8000f2:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	56                   	push   %esi
  8000fb:	53                   	push   %ebx
  8000fc:	e8 90 ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  800101:	e8 0a 00 00 00       	call   800110 <exit>
}
  800106:	83 c4 10             	add    $0x10,%esp
  800109:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80010c:	5b                   	pop    %ebx
  80010d:	5e                   	pop    %esi
  80010e:	5d                   	pop    %ebp
  80010f:	c3                   	ret    

00800110 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800116:	e8 55 0f 00 00       	call   801070 <close_all>
	sys_env_destroy(0);
  80011b:	83 ec 0c             	sub    $0xc,%esp
  80011e:	6a 00                	push   $0x0
  800120:	e8 79 0a 00 00       	call   800b9e <sys_env_destroy>
}
  800125:	83 c4 10             	add    $0x10,%esp
  800128:	c9                   	leave  
  800129:	c3                   	ret    

0080012a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	56                   	push   %esi
  80012e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80012f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800132:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800138:	e8 a2 0a 00 00       	call   800bdf <sys_getenvid>
  80013d:	83 ec 0c             	sub    $0xc,%esp
  800140:	ff 75 0c             	pushl  0xc(%ebp)
  800143:	ff 75 08             	pushl  0x8(%ebp)
  800146:	56                   	push   %esi
  800147:	50                   	push   %eax
  800148:	68 58 1f 80 00       	push   $0x801f58
  80014d:	e8 b3 00 00 00       	call   800205 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800152:	83 c4 18             	add    $0x18,%esp
  800155:	53                   	push   %ebx
  800156:	ff 75 10             	pushl  0x10(%ebp)
  800159:	e8 56 00 00 00       	call   8001b4 <vcprintf>
	cprintf("\n");
  80015e:	c7 04 24 ab 23 80 00 	movl   $0x8023ab,(%esp)
  800165:	e8 9b 00 00 00       	call   800205 <cprintf>
  80016a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80016d:	cc                   	int3   
  80016e:	eb fd                	jmp    80016d <_panic+0x43>

00800170 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	53                   	push   %ebx
  800174:	83 ec 04             	sub    $0x4,%esp
  800177:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80017a:	8b 13                	mov    (%ebx),%edx
  80017c:	8d 42 01             	lea    0x1(%edx),%eax
  80017f:	89 03                	mov    %eax,(%ebx)
  800181:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800184:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800188:	3d ff 00 00 00       	cmp    $0xff,%eax
  80018d:	74 09                	je     800198 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80018f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800193:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800196:	c9                   	leave  
  800197:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800198:	83 ec 08             	sub    $0x8,%esp
  80019b:	68 ff 00 00 00       	push   $0xff
  8001a0:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a3:	50                   	push   %eax
  8001a4:	e8 b8 09 00 00       	call   800b61 <sys_cputs>
		b->idx = 0;
  8001a9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001af:	83 c4 10             	add    $0x10,%esp
  8001b2:	eb db                	jmp    80018f <putch+0x1f>

008001b4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001bd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c4:	00 00 00 
	b.cnt = 0;
  8001c7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ce:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d1:	ff 75 0c             	pushl  0xc(%ebp)
  8001d4:	ff 75 08             	pushl  0x8(%ebp)
  8001d7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001dd:	50                   	push   %eax
  8001de:	68 70 01 80 00       	push   $0x800170
  8001e3:	e8 1a 01 00 00       	call   800302 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e8:	83 c4 08             	add    $0x8,%esp
  8001eb:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001f1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f7:	50                   	push   %eax
  8001f8:	e8 64 09 00 00       	call   800b61 <sys_cputs>

	return b.cnt;
}
  8001fd:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800203:	c9                   	leave  
  800204:	c3                   	ret    

00800205 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800205:	55                   	push   %ebp
  800206:	89 e5                	mov    %esp,%ebp
  800208:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80020b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80020e:	50                   	push   %eax
  80020f:	ff 75 08             	pushl  0x8(%ebp)
  800212:	e8 9d ff ff ff       	call   8001b4 <vcprintf>
	va_end(ap);

	return cnt;
}
  800217:	c9                   	leave  
  800218:	c3                   	ret    

00800219 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800219:	55                   	push   %ebp
  80021a:	89 e5                	mov    %esp,%ebp
  80021c:	57                   	push   %edi
  80021d:	56                   	push   %esi
  80021e:	53                   	push   %ebx
  80021f:	83 ec 1c             	sub    $0x1c,%esp
  800222:	89 c7                	mov    %eax,%edi
  800224:	89 d6                	mov    %edx,%esi
  800226:	8b 45 08             	mov    0x8(%ebp),%eax
  800229:	8b 55 0c             	mov    0xc(%ebp),%edx
  80022c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80022f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800232:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800235:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80023d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800240:	39 d3                	cmp    %edx,%ebx
  800242:	72 05                	jb     800249 <printnum+0x30>
  800244:	39 45 10             	cmp    %eax,0x10(%ebp)
  800247:	77 7a                	ja     8002c3 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800249:	83 ec 0c             	sub    $0xc,%esp
  80024c:	ff 75 18             	pushl  0x18(%ebp)
  80024f:	8b 45 14             	mov    0x14(%ebp),%eax
  800252:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800255:	53                   	push   %ebx
  800256:	ff 75 10             	pushl  0x10(%ebp)
  800259:	83 ec 08             	sub    $0x8,%esp
  80025c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80025f:	ff 75 e0             	pushl  -0x20(%ebp)
  800262:	ff 75 dc             	pushl  -0x24(%ebp)
  800265:	ff 75 d8             	pushl  -0x28(%ebp)
  800268:	e8 33 1a 00 00       	call   801ca0 <__udivdi3>
  80026d:	83 c4 18             	add    $0x18,%esp
  800270:	52                   	push   %edx
  800271:	50                   	push   %eax
  800272:	89 f2                	mov    %esi,%edx
  800274:	89 f8                	mov    %edi,%eax
  800276:	e8 9e ff ff ff       	call   800219 <printnum>
  80027b:	83 c4 20             	add    $0x20,%esp
  80027e:	eb 13                	jmp    800293 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800280:	83 ec 08             	sub    $0x8,%esp
  800283:	56                   	push   %esi
  800284:	ff 75 18             	pushl  0x18(%ebp)
  800287:	ff d7                	call   *%edi
  800289:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80028c:	83 eb 01             	sub    $0x1,%ebx
  80028f:	85 db                	test   %ebx,%ebx
  800291:	7f ed                	jg     800280 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800293:	83 ec 08             	sub    $0x8,%esp
  800296:	56                   	push   %esi
  800297:	83 ec 04             	sub    $0x4,%esp
  80029a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80029d:	ff 75 e0             	pushl  -0x20(%ebp)
  8002a0:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a3:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a6:	e8 15 1b 00 00       	call   801dc0 <__umoddi3>
  8002ab:	83 c4 14             	add    $0x14,%esp
  8002ae:	0f be 80 7b 1f 80 00 	movsbl 0x801f7b(%eax),%eax
  8002b5:	50                   	push   %eax
  8002b6:	ff d7                	call   *%edi
}
  8002b8:	83 c4 10             	add    $0x10,%esp
  8002bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002be:	5b                   	pop    %ebx
  8002bf:	5e                   	pop    %esi
  8002c0:	5f                   	pop    %edi
  8002c1:	5d                   	pop    %ebp
  8002c2:	c3                   	ret    
  8002c3:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002c6:	eb c4                	jmp    80028c <printnum+0x73>

008002c8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002c8:	55                   	push   %ebp
  8002c9:	89 e5                	mov    %esp,%ebp
  8002cb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ce:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002d2:	8b 10                	mov    (%eax),%edx
  8002d4:	3b 50 04             	cmp    0x4(%eax),%edx
  8002d7:	73 0a                	jae    8002e3 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002d9:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002dc:	89 08                	mov    %ecx,(%eax)
  8002de:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e1:	88 02                	mov    %al,(%edx)
}
  8002e3:	5d                   	pop    %ebp
  8002e4:	c3                   	ret    

008002e5 <printfmt>:
{
  8002e5:	55                   	push   %ebp
  8002e6:	89 e5                	mov    %esp,%ebp
  8002e8:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002eb:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002ee:	50                   	push   %eax
  8002ef:	ff 75 10             	pushl  0x10(%ebp)
  8002f2:	ff 75 0c             	pushl  0xc(%ebp)
  8002f5:	ff 75 08             	pushl  0x8(%ebp)
  8002f8:	e8 05 00 00 00       	call   800302 <vprintfmt>
}
  8002fd:	83 c4 10             	add    $0x10,%esp
  800300:	c9                   	leave  
  800301:	c3                   	ret    

00800302 <vprintfmt>:
{
  800302:	55                   	push   %ebp
  800303:	89 e5                	mov    %esp,%ebp
  800305:	57                   	push   %edi
  800306:	56                   	push   %esi
  800307:	53                   	push   %ebx
  800308:	83 ec 2c             	sub    $0x2c,%esp
  80030b:	8b 75 08             	mov    0x8(%ebp),%esi
  80030e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800311:	8b 7d 10             	mov    0x10(%ebp),%edi
  800314:	e9 c1 03 00 00       	jmp    8006da <vprintfmt+0x3d8>
		padc = ' ';
  800319:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  80031d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800324:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  80032b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800332:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800337:	8d 47 01             	lea    0x1(%edi),%eax
  80033a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80033d:	0f b6 17             	movzbl (%edi),%edx
  800340:	8d 42 dd             	lea    -0x23(%edx),%eax
  800343:	3c 55                	cmp    $0x55,%al
  800345:	0f 87 12 04 00 00    	ja     80075d <vprintfmt+0x45b>
  80034b:	0f b6 c0             	movzbl %al,%eax
  80034e:	ff 24 85 c0 20 80 00 	jmp    *0x8020c0(,%eax,4)
  800355:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800358:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80035c:	eb d9                	jmp    800337 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80035e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800361:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800365:	eb d0                	jmp    800337 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800367:	0f b6 d2             	movzbl %dl,%edx
  80036a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80036d:	b8 00 00 00 00       	mov    $0x0,%eax
  800372:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800375:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800378:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80037c:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80037f:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800382:	83 f9 09             	cmp    $0x9,%ecx
  800385:	77 55                	ja     8003dc <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800387:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80038a:	eb e9                	jmp    800375 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  80038c:	8b 45 14             	mov    0x14(%ebp),%eax
  80038f:	8b 00                	mov    (%eax),%eax
  800391:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800394:	8b 45 14             	mov    0x14(%ebp),%eax
  800397:	8d 40 04             	lea    0x4(%eax),%eax
  80039a:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80039d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003a0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003a4:	79 91                	jns    800337 <vprintfmt+0x35>
				width = precision, precision = -1;
  8003a6:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003a9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ac:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003b3:	eb 82                	jmp    800337 <vprintfmt+0x35>
  8003b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003b8:	85 c0                	test   %eax,%eax
  8003ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8003bf:	0f 49 d0             	cmovns %eax,%edx
  8003c2:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003c8:	e9 6a ff ff ff       	jmp    800337 <vprintfmt+0x35>
  8003cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003d0:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003d7:	e9 5b ff ff ff       	jmp    800337 <vprintfmt+0x35>
  8003dc:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003df:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003e2:	eb bc                	jmp    8003a0 <vprintfmt+0x9e>
			lflag++;
  8003e4:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003ea:	e9 48 ff ff ff       	jmp    800337 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8003ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f2:	8d 78 04             	lea    0x4(%eax),%edi
  8003f5:	83 ec 08             	sub    $0x8,%esp
  8003f8:	53                   	push   %ebx
  8003f9:	ff 30                	pushl  (%eax)
  8003fb:	ff d6                	call   *%esi
			break;
  8003fd:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800400:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800403:	e9 cf 02 00 00       	jmp    8006d7 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  800408:	8b 45 14             	mov    0x14(%ebp),%eax
  80040b:	8d 78 04             	lea    0x4(%eax),%edi
  80040e:	8b 00                	mov    (%eax),%eax
  800410:	99                   	cltd   
  800411:	31 d0                	xor    %edx,%eax
  800413:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800415:	83 f8 0f             	cmp    $0xf,%eax
  800418:	7f 23                	jg     80043d <vprintfmt+0x13b>
  80041a:	8b 14 85 20 22 80 00 	mov    0x802220(,%eax,4),%edx
  800421:	85 d2                	test   %edx,%edx
  800423:	74 18                	je     80043d <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800425:	52                   	push   %edx
  800426:	68 79 23 80 00       	push   $0x802379
  80042b:	53                   	push   %ebx
  80042c:	56                   	push   %esi
  80042d:	e8 b3 fe ff ff       	call   8002e5 <printfmt>
  800432:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800435:	89 7d 14             	mov    %edi,0x14(%ebp)
  800438:	e9 9a 02 00 00       	jmp    8006d7 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  80043d:	50                   	push   %eax
  80043e:	68 93 1f 80 00       	push   $0x801f93
  800443:	53                   	push   %ebx
  800444:	56                   	push   %esi
  800445:	e8 9b fe ff ff       	call   8002e5 <printfmt>
  80044a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80044d:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800450:	e9 82 02 00 00       	jmp    8006d7 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  800455:	8b 45 14             	mov    0x14(%ebp),%eax
  800458:	83 c0 04             	add    $0x4,%eax
  80045b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80045e:	8b 45 14             	mov    0x14(%ebp),%eax
  800461:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800463:	85 ff                	test   %edi,%edi
  800465:	b8 8c 1f 80 00       	mov    $0x801f8c,%eax
  80046a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80046d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800471:	0f 8e bd 00 00 00    	jle    800534 <vprintfmt+0x232>
  800477:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80047b:	75 0e                	jne    80048b <vprintfmt+0x189>
  80047d:	89 75 08             	mov    %esi,0x8(%ebp)
  800480:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800483:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800486:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800489:	eb 6d                	jmp    8004f8 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  80048b:	83 ec 08             	sub    $0x8,%esp
  80048e:	ff 75 d0             	pushl  -0x30(%ebp)
  800491:	57                   	push   %edi
  800492:	e8 6e 03 00 00       	call   800805 <strnlen>
  800497:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80049a:	29 c1                	sub    %eax,%ecx
  80049c:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80049f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004a2:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004a6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004ac:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ae:	eb 0f                	jmp    8004bf <vprintfmt+0x1bd>
					putch(padc, putdat);
  8004b0:	83 ec 08             	sub    $0x8,%esp
  8004b3:	53                   	push   %ebx
  8004b4:	ff 75 e0             	pushl  -0x20(%ebp)
  8004b7:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b9:	83 ef 01             	sub    $0x1,%edi
  8004bc:	83 c4 10             	add    $0x10,%esp
  8004bf:	85 ff                	test   %edi,%edi
  8004c1:	7f ed                	jg     8004b0 <vprintfmt+0x1ae>
  8004c3:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004c6:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004c9:	85 c9                	test   %ecx,%ecx
  8004cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d0:	0f 49 c1             	cmovns %ecx,%eax
  8004d3:	29 c1                	sub    %eax,%ecx
  8004d5:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004db:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004de:	89 cb                	mov    %ecx,%ebx
  8004e0:	eb 16                	jmp    8004f8 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8004e2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004e6:	75 31                	jne    800519 <vprintfmt+0x217>
					putch(ch, putdat);
  8004e8:	83 ec 08             	sub    $0x8,%esp
  8004eb:	ff 75 0c             	pushl  0xc(%ebp)
  8004ee:	50                   	push   %eax
  8004ef:	ff 55 08             	call   *0x8(%ebp)
  8004f2:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004f5:	83 eb 01             	sub    $0x1,%ebx
  8004f8:	83 c7 01             	add    $0x1,%edi
  8004fb:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8004ff:	0f be c2             	movsbl %dl,%eax
  800502:	85 c0                	test   %eax,%eax
  800504:	74 59                	je     80055f <vprintfmt+0x25d>
  800506:	85 f6                	test   %esi,%esi
  800508:	78 d8                	js     8004e2 <vprintfmt+0x1e0>
  80050a:	83 ee 01             	sub    $0x1,%esi
  80050d:	79 d3                	jns    8004e2 <vprintfmt+0x1e0>
  80050f:	89 df                	mov    %ebx,%edi
  800511:	8b 75 08             	mov    0x8(%ebp),%esi
  800514:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800517:	eb 37                	jmp    800550 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  800519:	0f be d2             	movsbl %dl,%edx
  80051c:	83 ea 20             	sub    $0x20,%edx
  80051f:	83 fa 5e             	cmp    $0x5e,%edx
  800522:	76 c4                	jbe    8004e8 <vprintfmt+0x1e6>
					putch('?', putdat);
  800524:	83 ec 08             	sub    $0x8,%esp
  800527:	ff 75 0c             	pushl  0xc(%ebp)
  80052a:	6a 3f                	push   $0x3f
  80052c:	ff 55 08             	call   *0x8(%ebp)
  80052f:	83 c4 10             	add    $0x10,%esp
  800532:	eb c1                	jmp    8004f5 <vprintfmt+0x1f3>
  800534:	89 75 08             	mov    %esi,0x8(%ebp)
  800537:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80053a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80053d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800540:	eb b6                	jmp    8004f8 <vprintfmt+0x1f6>
				putch(' ', putdat);
  800542:	83 ec 08             	sub    $0x8,%esp
  800545:	53                   	push   %ebx
  800546:	6a 20                	push   $0x20
  800548:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80054a:	83 ef 01             	sub    $0x1,%edi
  80054d:	83 c4 10             	add    $0x10,%esp
  800550:	85 ff                	test   %edi,%edi
  800552:	7f ee                	jg     800542 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800554:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800557:	89 45 14             	mov    %eax,0x14(%ebp)
  80055a:	e9 78 01 00 00       	jmp    8006d7 <vprintfmt+0x3d5>
  80055f:	89 df                	mov    %ebx,%edi
  800561:	8b 75 08             	mov    0x8(%ebp),%esi
  800564:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800567:	eb e7                	jmp    800550 <vprintfmt+0x24e>
	if (lflag >= 2)
  800569:	83 f9 01             	cmp    $0x1,%ecx
  80056c:	7e 3f                	jle    8005ad <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  80056e:	8b 45 14             	mov    0x14(%ebp),%eax
  800571:	8b 50 04             	mov    0x4(%eax),%edx
  800574:	8b 00                	mov    (%eax),%eax
  800576:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800579:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80057c:	8b 45 14             	mov    0x14(%ebp),%eax
  80057f:	8d 40 08             	lea    0x8(%eax),%eax
  800582:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800585:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800589:	79 5c                	jns    8005e7 <vprintfmt+0x2e5>
				putch('-', putdat);
  80058b:	83 ec 08             	sub    $0x8,%esp
  80058e:	53                   	push   %ebx
  80058f:	6a 2d                	push   $0x2d
  800591:	ff d6                	call   *%esi
				num = -(long long) num;
  800593:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800596:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800599:	f7 da                	neg    %edx
  80059b:	83 d1 00             	adc    $0x0,%ecx
  80059e:	f7 d9                	neg    %ecx
  8005a0:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005a3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005a8:	e9 10 01 00 00       	jmp    8006bd <vprintfmt+0x3bb>
	else if (lflag)
  8005ad:	85 c9                	test   %ecx,%ecx
  8005af:	75 1b                	jne    8005cc <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8005b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b4:	8b 00                	mov    (%eax),%eax
  8005b6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b9:	89 c1                	mov    %eax,%ecx
  8005bb:	c1 f9 1f             	sar    $0x1f,%ecx
  8005be:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c4:	8d 40 04             	lea    0x4(%eax),%eax
  8005c7:	89 45 14             	mov    %eax,0x14(%ebp)
  8005ca:	eb b9                	jmp    800585 <vprintfmt+0x283>
		return va_arg(*ap, long);
  8005cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cf:	8b 00                	mov    (%eax),%eax
  8005d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d4:	89 c1                	mov    %eax,%ecx
  8005d6:	c1 f9 1f             	sar    $0x1f,%ecx
  8005d9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005df:	8d 40 04             	lea    0x4(%eax),%eax
  8005e2:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e5:	eb 9e                	jmp    800585 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8005e7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005ea:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005ed:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f2:	e9 c6 00 00 00       	jmp    8006bd <vprintfmt+0x3bb>
	if (lflag >= 2)
  8005f7:	83 f9 01             	cmp    $0x1,%ecx
  8005fa:	7e 18                	jle    800614 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8005fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ff:	8b 10                	mov    (%eax),%edx
  800601:	8b 48 04             	mov    0x4(%eax),%ecx
  800604:	8d 40 08             	lea    0x8(%eax),%eax
  800607:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80060a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80060f:	e9 a9 00 00 00       	jmp    8006bd <vprintfmt+0x3bb>
	else if (lflag)
  800614:	85 c9                	test   %ecx,%ecx
  800616:	75 1a                	jne    800632 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  800618:	8b 45 14             	mov    0x14(%ebp),%eax
  80061b:	8b 10                	mov    (%eax),%edx
  80061d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800622:	8d 40 04             	lea    0x4(%eax),%eax
  800625:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800628:	b8 0a 00 00 00       	mov    $0xa,%eax
  80062d:	e9 8b 00 00 00       	jmp    8006bd <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800632:	8b 45 14             	mov    0x14(%ebp),%eax
  800635:	8b 10                	mov    (%eax),%edx
  800637:	b9 00 00 00 00       	mov    $0x0,%ecx
  80063c:	8d 40 04             	lea    0x4(%eax),%eax
  80063f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800642:	b8 0a 00 00 00       	mov    $0xa,%eax
  800647:	eb 74                	jmp    8006bd <vprintfmt+0x3bb>
	if (lflag >= 2)
  800649:	83 f9 01             	cmp    $0x1,%ecx
  80064c:	7e 15                	jle    800663 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  80064e:	8b 45 14             	mov    0x14(%ebp),%eax
  800651:	8b 10                	mov    (%eax),%edx
  800653:	8b 48 04             	mov    0x4(%eax),%ecx
  800656:	8d 40 08             	lea    0x8(%eax),%eax
  800659:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80065c:	b8 08 00 00 00       	mov    $0x8,%eax
  800661:	eb 5a                	jmp    8006bd <vprintfmt+0x3bb>
	else if (lflag)
  800663:	85 c9                	test   %ecx,%ecx
  800665:	75 17                	jne    80067e <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  800667:	8b 45 14             	mov    0x14(%ebp),%eax
  80066a:	8b 10                	mov    (%eax),%edx
  80066c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800671:	8d 40 04             	lea    0x4(%eax),%eax
  800674:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800677:	b8 08 00 00 00       	mov    $0x8,%eax
  80067c:	eb 3f                	jmp    8006bd <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80067e:	8b 45 14             	mov    0x14(%ebp),%eax
  800681:	8b 10                	mov    (%eax),%edx
  800683:	b9 00 00 00 00       	mov    $0x0,%ecx
  800688:	8d 40 04             	lea    0x4(%eax),%eax
  80068b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80068e:	b8 08 00 00 00       	mov    $0x8,%eax
  800693:	eb 28                	jmp    8006bd <vprintfmt+0x3bb>
			putch('0', putdat);
  800695:	83 ec 08             	sub    $0x8,%esp
  800698:	53                   	push   %ebx
  800699:	6a 30                	push   $0x30
  80069b:	ff d6                	call   *%esi
			putch('x', putdat);
  80069d:	83 c4 08             	add    $0x8,%esp
  8006a0:	53                   	push   %ebx
  8006a1:	6a 78                	push   $0x78
  8006a3:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a8:	8b 10                	mov    (%eax),%edx
  8006aa:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006af:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006b2:	8d 40 04             	lea    0x4(%eax),%eax
  8006b5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b8:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006bd:	83 ec 0c             	sub    $0xc,%esp
  8006c0:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006c4:	57                   	push   %edi
  8006c5:	ff 75 e0             	pushl  -0x20(%ebp)
  8006c8:	50                   	push   %eax
  8006c9:	51                   	push   %ecx
  8006ca:	52                   	push   %edx
  8006cb:	89 da                	mov    %ebx,%edx
  8006cd:	89 f0                	mov    %esi,%eax
  8006cf:	e8 45 fb ff ff       	call   800219 <printnum>
			break;
  8006d4:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8006d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006da:	83 c7 01             	add    $0x1,%edi
  8006dd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006e1:	83 f8 25             	cmp    $0x25,%eax
  8006e4:	0f 84 2f fc ff ff    	je     800319 <vprintfmt+0x17>
			if (ch == '\0')
  8006ea:	85 c0                	test   %eax,%eax
  8006ec:	0f 84 8b 00 00 00    	je     80077d <vprintfmt+0x47b>
			putch(ch, putdat);
  8006f2:	83 ec 08             	sub    $0x8,%esp
  8006f5:	53                   	push   %ebx
  8006f6:	50                   	push   %eax
  8006f7:	ff d6                	call   *%esi
  8006f9:	83 c4 10             	add    $0x10,%esp
  8006fc:	eb dc                	jmp    8006da <vprintfmt+0x3d8>
	if (lflag >= 2)
  8006fe:	83 f9 01             	cmp    $0x1,%ecx
  800701:	7e 15                	jle    800718 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  800703:	8b 45 14             	mov    0x14(%ebp),%eax
  800706:	8b 10                	mov    (%eax),%edx
  800708:	8b 48 04             	mov    0x4(%eax),%ecx
  80070b:	8d 40 08             	lea    0x8(%eax),%eax
  80070e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800711:	b8 10 00 00 00       	mov    $0x10,%eax
  800716:	eb a5                	jmp    8006bd <vprintfmt+0x3bb>
	else if (lflag)
  800718:	85 c9                	test   %ecx,%ecx
  80071a:	75 17                	jne    800733 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  80071c:	8b 45 14             	mov    0x14(%ebp),%eax
  80071f:	8b 10                	mov    (%eax),%edx
  800721:	b9 00 00 00 00       	mov    $0x0,%ecx
  800726:	8d 40 04             	lea    0x4(%eax),%eax
  800729:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80072c:	b8 10 00 00 00       	mov    $0x10,%eax
  800731:	eb 8a                	jmp    8006bd <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800733:	8b 45 14             	mov    0x14(%ebp),%eax
  800736:	8b 10                	mov    (%eax),%edx
  800738:	b9 00 00 00 00       	mov    $0x0,%ecx
  80073d:	8d 40 04             	lea    0x4(%eax),%eax
  800740:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800743:	b8 10 00 00 00       	mov    $0x10,%eax
  800748:	e9 70 ff ff ff       	jmp    8006bd <vprintfmt+0x3bb>
			putch(ch, putdat);
  80074d:	83 ec 08             	sub    $0x8,%esp
  800750:	53                   	push   %ebx
  800751:	6a 25                	push   $0x25
  800753:	ff d6                	call   *%esi
			break;
  800755:	83 c4 10             	add    $0x10,%esp
  800758:	e9 7a ff ff ff       	jmp    8006d7 <vprintfmt+0x3d5>
			putch('%', putdat);
  80075d:	83 ec 08             	sub    $0x8,%esp
  800760:	53                   	push   %ebx
  800761:	6a 25                	push   $0x25
  800763:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800765:	83 c4 10             	add    $0x10,%esp
  800768:	89 f8                	mov    %edi,%eax
  80076a:	eb 03                	jmp    80076f <vprintfmt+0x46d>
  80076c:	83 e8 01             	sub    $0x1,%eax
  80076f:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800773:	75 f7                	jne    80076c <vprintfmt+0x46a>
  800775:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800778:	e9 5a ff ff ff       	jmp    8006d7 <vprintfmt+0x3d5>
}
  80077d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800780:	5b                   	pop    %ebx
  800781:	5e                   	pop    %esi
  800782:	5f                   	pop    %edi
  800783:	5d                   	pop    %ebp
  800784:	c3                   	ret    

00800785 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800785:	55                   	push   %ebp
  800786:	89 e5                	mov    %esp,%ebp
  800788:	83 ec 18             	sub    $0x18,%esp
  80078b:	8b 45 08             	mov    0x8(%ebp),%eax
  80078e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800791:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800794:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800798:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80079b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007a2:	85 c0                	test   %eax,%eax
  8007a4:	74 26                	je     8007cc <vsnprintf+0x47>
  8007a6:	85 d2                	test   %edx,%edx
  8007a8:	7e 22                	jle    8007cc <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007aa:	ff 75 14             	pushl  0x14(%ebp)
  8007ad:	ff 75 10             	pushl  0x10(%ebp)
  8007b0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007b3:	50                   	push   %eax
  8007b4:	68 c8 02 80 00       	push   $0x8002c8
  8007b9:	e8 44 fb ff ff       	call   800302 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007be:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007c1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007c7:	83 c4 10             	add    $0x10,%esp
}
  8007ca:	c9                   	leave  
  8007cb:	c3                   	ret    
		return -E_INVAL;
  8007cc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007d1:	eb f7                	jmp    8007ca <vsnprintf+0x45>

008007d3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007d3:	55                   	push   %ebp
  8007d4:	89 e5                	mov    %esp,%ebp
  8007d6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007d9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007dc:	50                   	push   %eax
  8007dd:	ff 75 10             	pushl  0x10(%ebp)
  8007e0:	ff 75 0c             	pushl  0xc(%ebp)
  8007e3:	ff 75 08             	pushl  0x8(%ebp)
  8007e6:	e8 9a ff ff ff       	call   800785 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007eb:	c9                   	leave  
  8007ec:	c3                   	ret    

008007ed <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007ed:	55                   	push   %ebp
  8007ee:	89 e5                	mov    %esp,%ebp
  8007f0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f8:	eb 03                	jmp    8007fd <strlen+0x10>
		n++;
  8007fa:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007fd:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800801:	75 f7                	jne    8007fa <strlen+0xd>
	return n;
}
  800803:	5d                   	pop    %ebp
  800804:	c3                   	ret    

00800805 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800805:	55                   	push   %ebp
  800806:	89 e5                	mov    %esp,%ebp
  800808:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80080b:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80080e:	b8 00 00 00 00       	mov    $0x0,%eax
  800813:	eb 03                	jmp    800818 <strnlen+0x13>
		n++;
  800815:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800818:	39 d0                	cmp    %edx,%eax
  80081a:	74 06                	je     800822 <strnlen+0x1d>
  80081c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800820:	75 f3                	jne    800815 <strnlen+0x10>
	return n;
}
  800822:	5d                   	pop    %ebp
  800823:	c3                   	ret    

00800824 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	53                   	push   %ebx
  800828:	8b 45 08             	mov    0x8(%ebp),%eax
  80082b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80082e:	89 c2                	mov    %eax,%edx
  800830:	83 c1 01             	add    $0x1,%ecx
  800833:	83 c2 01             	add    $0x1,%edx
  800836:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80083a:	88 5a ff             	mov    %bl,-0x1(%edx)
  80083d:	84 db                	test   %bl,%bl
  80083f:	75 ef                	jne    800830 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800841:	5b                   	pop    %ebx
  800842:	5d                   	pop    %ebp
  800843:	c3                   	ret    

00800844 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800844:	55                   	push   %ebp
  800845:	89 e5                	mov    %esp,%ebp
  800847:	53                   	push   %ebx
  800848:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80084b:	53                   	push   %ebx
  80084c:	e8 9c ff ff ff       	call   8007ed <strlen>
  800851:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800854:	ff 75 0c             	pushl  0xc(%ebp)
  800857:	01 d8                	add    %ebx,%eax
  800859:	50                   	push   %eax
  80085a:	e8 c5 ff ff ff       	call   800824 <strcpy>
	return dst;
}
  80085f:	89 d8                	mov    %ebx,%eax
  800861:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800864:	c9                   	leave  
  800865:	c3                   	ret    

00800866 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800866:	55                   	push   %ebp
  800867:	89 e5                	mov    %esp,%ebp
  800869:	56                   	push   %esi
  80086a:	53                   	push   %ebx
  80086b:	8b 75 08             	mov    0x8(%ebp),%esi
  80086e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800871:	89 f3                	mov    %esi,%ebx
  800873:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800876:	89 f2                	mov    %esi,%edx
  800878:	eb 0f                	jmp    800889 <strncpy+0x23>
		*dst++ = *src;
  80087a:	83 c2 01             	add    $0x1,%edx
  80087d:	0f b6 01             	movzbl (%ecx),%eax
  800880:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800883:	80 39 01             	cmpb   $0x1,(%ecx)
  800886:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800889:	39 da                	cmp    %ebx,%edx
  80088b:	75 ed                	jne    80087a <strncpy+0x14>
	}
	return ret;
}
  80088d:	89 f0                	mov    %esi,%eax
  80088f:	5b                   	pop    %ebx
  800890:	5e                   	pop    %esi
  800891:	5d                   	pop    %ebp
  800892:	c3                   	ret    

00800893 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800893:	55                   	push   %ebp
  800894:	89 e5                	mov    %esp,%ebp
  800896:	56                   	push   %esi
  800897:	53                   	push   %ebx
  800898:	8b 75 08             	mov    0x8(%ebp),%esi
  80089b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008a1:	89 f0                	mov    %esi,%eax
  8008a3:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008a7:	85 c9                	test   %ecx,%ecx
  8008a9:	75 0b                	jne    8008b6 <strlcpy+0x23>
  8008ab:	eb 17                	jmp    8008c4 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008ad:	83 c2 01             	add    $0x1,%edx
  8008b0:	83 c0 01             	add    $0x1,%eax
  8008b3:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8008b6:	39 d8                	cmp    %ebx,%eax
  8008b8:	74 07                	je     8008c1 <strlcpy+0x2e>
  8008ba:	0f b6 0a             	movzbl (%edx),%ecx
  8008bd:	84 c9                	test   %cl,%cl
  8008bf:	75 ec                	jne    8008ad <strlcpy+0x1a>
		*dst = '\0';
  8008c1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008c4:	29 f0                	sub    %esi,%eax
}
  8008c6:	5b                   	pop    %ebx
  8008c7:	5e                   	pop    %esi
  8008c8:	5d                   	pop    %ebp
  8008c9:	c3                   	ret    

008008ca <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008d3:	eb 06                	jmp    8008db <strcmp+0x11>
		p++, q++;
  8008d5:	83 c1 01             	add    $0x1,%ecx
  8008d8:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008db:	0f b6 01             	movzbl (%ecx),%eax
  8008de:	84 c0                	test   %al,%al
  8008e0:	74 04                	je     8008e6 <strcmp+0x1c>
  8008e2:	3a 02                	cmp    (%edx),%al
  8008e4:	74 ef                	je     8008d5 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e6:	0f b6 c0             	movzbl %al,%eax
  8008e9:	0f b6 12             	movzbl (%edx),%edx
  8008ec:	29 d0                	sub    %edx,%eax
}
  8008ee:	5d                   	pop    %ebp
  8008ef:	c3                   	ret    

008008f0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
  8008f3:	53                   	push   %ebx
  8008f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008fa:	89 c3                	mov    %eax,%ebx
  8008fc:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008ff:	eb 06                	jmp    800907 <strncmp+0x17>
		n--, p++, q++;
  800901:	83 c0 01             	add    $0x1,%eax
  800904:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800907:	39 d8                	cmp    %ebx,%eax
  800909:	74 16                	je     800921 <strncmp+0x31>
  80090b:	0f b6 08             	movzbl (%eax),%ecx
  80090e:	84 c9                	test   %cl,%cl
  800910:	74 04                	je     800916 <strncmp+0x26>
  800912:	3a 0a                	cmp    (%edx),%cl
  800914:	74 eb                	je     800901 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800916:	0f b6 00             	movzbl (%eax),%eax
  800919:	0f b6 12             	movzbl (%edx),%edx
  80091c:	29 d0                	sub    %edx,%eax
}
  80091e:	5b                   	pop    %ebx
  80091f:	5d                   	pop    %ebp
  800920:	c3                   	ret    
		return 0;
  800921:	b8 00 00 00 00       	mov    $0x0,%eax
  800926:	eb f6                	jmp    80091e <strncmp+0x2e>

00800928 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
  80092b:	8b 45 08             	mov    0x8(%ebp),%eax
  80092e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800932:	0f b6 10             	movzbl (%eax),%edx
  800935:	84 d2                	test   %dl,%dl
  800937:	74 09                	je     800942 <strchr+0x1a>
		if (*s == c)
  800939:	38 ca                	cmp    %cl,%dl
  80093b:	74 0a                	je     800947 <strchr+0x1f>
	for (; *s; s++)
  80093d:	83 c0 01             	add    $0x1,%eax
  800940:	eb f0                	jmp    800932 <strchr+0xa>
			return (char *) s;
	return 0;
  800942:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800947:	5d                   	pop    %ebp
  800948:	c3                   	ret    

00800949 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800949:	55                   	push   %ebp
  80094a:	89 e5                	mov    %esp,%ebp
  80094c:	8b 45 08             	mov    0x8(%ebp),%eax
  80094f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800953:	eb 03                	jmp    800958 <strfind+0xf>
  800955:	83 c0 01             	add    $0x1,%eax
  800958:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80095b:	38 ca                	cmp    %cl,%dl
  80095d:	74 04                	je     800963 <strfind+0x1a>
  80095f:	84 d2                	test   %dl,%dl
  800961:	75 f2                	jne    800955 <strfind+0xc>
			break;
	return (char *) s;
}
  800963:	5d                   	pop    %ebp
  800964:	c3                   	ret    

00800965 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800965:	55                   	push   %ebp
  800966:	89 e5                	mov    %esp,%ebp
  800968:	57                   	push   %edi
  800969:	56                   	push   %esi
  80096a:	53                   	push   %ebx
  80096b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80096e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800971:	85 c9                	test   %ecx,%ecx
  800973:	74 13                	je     800988 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800975:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80097b:	75 05                	jne    800982 <memset+0x1d>
  80097d:	f6 c1 03             	test   $0x3,%cl
  800980:	74 0d                	je     80098f <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800982:	8b 45 0c             	mov    0xc(%ebp),%eax
  800985:	fc                   	cld    
  800986:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800988:	89 f8                	mov    %edi,%eax
  80098a:	5b                   	pop    %ebx
  80098b:	5e                   	pop    %esi
  80098c:	5f                   	pop    %edi
  80098d:	5d                   	pop    %ebp
  80098e:	c3                   	ret    
		c &= 0xFF;
  80098f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800993:	89 d3                	mov    %edx,%ebx
  800995:	c1 e3 08             	shl    $0x8,%ebx
  800998:	89 d0                	mov    %edx,%eax
  80099a:	c1 e0 18             	shl    $0x18,%eax
  80099d:	89 d6                	mov    %edx,%esi
  80099f:	c1 e6 10             	shl    $0x10,%esi
  8009a2:	09 f0                	or     %esi,%eax
  8009a4:	09 c2                	or     %eax,%edx
  8009a6:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  8009a8:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009ab:	89 d0                	mov    %edx,%eax
  8009ad:	fc                   	cld    
  8009ae:	f3 ab                	rep stos %eax,%es:(%edi)
  8009b0:	eb d6                	jmp    800988 <memset+0x23>

008009b2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
  8009b5:	57                   	push   %edi
  8009b6:	56                   	push   %esi
  8009b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ba:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009bd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009c0:	39 c6                	cmp    %eax,%esi
  8009c2:	73 35                	jae    8009f9 <memmove+0x47>
  8009c4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009c7:	39 c2                	cmp    %eax,%edx
  8009c9:	76 2e                	jbe    8009f9 <memmove+0x47>
		s += n;
		d += n;
  8009cb:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ce:	89 d6                	mov    %edx,%esi
  8009d0:	09 fe                	or     %edi,%esi
  8009d2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009d8:	74 0c                	je     8009e6 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009da:	83 ef 01             	sub    $0x1,%edi
  8009dd:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009e0:	fd                   	std    
  8009e1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009e3:	fc                   	cld    
  8009e4:	eb 21                	jmp    800a07 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e6:	f6 c1 03             	test   $0x3,%cl
  8009e9:	75 ef                	jne    8009da <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009eb:	83 ef 04             	sub    $0x4,%edi
  8009ee:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009f1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009f4:	fd                   	std    
  8009f5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009f7:	eb ea                	jmp    8009e3 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f9:	89 f2                	mov    %esi,%edx
  8009fb:	09 c2                	or     %eax,%edx
  8009fd:	f6 c2 03             	test   $0x3,%dl
  800a00:	74 09                	je     800a0b <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a02:	89 c7                	mov    %eax,%edi
  800a04:	fc                   	cld    
  800a05:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a07:	5e                   	pop    %esi
  800a08:	5f                   	pop    %edi
  800a09:	5d                   	pop    %ebp
  800a0a:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a0b:	f6 c1 03             	test   $0x3,%cl
  800a0e:	75 f2                	jne    800a02 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a10:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a13:	89 c7                	mov    %eax,%edi
  800a15:	fc                   	cld    
  800a16:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a18:	eb ed                	jmp    800a07 <memmove+0x55>

00800a1a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a1a:	55                   	push   %ebp
  800a1b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a1d:	ff 75 10             	pushl  0x10(%ebp)
  800a20:	ff 75 0c             	pushl  0xc(%ebp)
  800a23:	ff 75 08             	pushl  0x8(%ebp)
  800a26:	e8 87 ff ff ff       	call   8009b2 <memmove>
}
  800a2b:	c9                   	leave  
  800a2c:	c3                   	ret    

00800a2d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a2d:	55                   	push   %ebp
  800a2e:	89 e5                	mov    %esp,%ebp
  800a30:	56                   	push   %esi
  800a31:	53                   	push   %ebx
  800a32:	8b 45 08             	mov    0x8(%ebp),%eax
  800a35:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a38:	89 c6                	mov    %eax,%esi
  800a3a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a3d:	39 f0                	cmp    %esi,%eax
  800a3f:	74 1c                	je     800a5d <memcmp+0x30>
		if (*s1 != *s2)
  800a41:	0f b6 08             	movzbl (%eax),%ecx
  800a44:	0f b6 1a             	movzbl (%edx),%ebx
  800a47:	38 d9                	cmp    %bl,%cl
  800a49:	75 08                	jne    800a53 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a4b:	83 c0 01             	add    $0x1,%eax
  800a4e:	83 c2 01             	add    $0x1,%edx
  800a51:	eb ea                	jmp    800a3d <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a53:	0f b6 c1             	movzbl %cl,%eax
  800a56:	0f b6 db             	movzbl %bl,%ebx
  800a59:	29 d8                	sub    %ebx,%eax
  800a5b:	eb 05                	jmp    800a62 <memcmp+0x35>
	}

	return 0;
  800a5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a62:	5b                   	pop    %ebx
  800a63:	5e                   	pop    %esi
  800a64:	5d                   	pop    %ebp
  800a65:	c3                   	ret    

00800a66 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a66:	55                   	push   %ebp
  800a67:	89 e5                	mov    %esp,%ebp
  800a69:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a6f:	89 c2                	mov    %eax,%edx
  800a71:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a74:	39 d0                	cmp    %edx,%eax
  800a76:	73 09                	jae    800a81 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a78:	38 08                	cmp    %cl,(%eax)
  800a7a:	74 05                	je     800a81 <memfind+0x1b>
	for (; s < ends; s++)
  800a7c:	83 c0 01             	add    $0x1,%eax
  800a7f:	eb f3                	jmp    800a74 <memfind+0xe>
			break;
	return (void *) s;
}
  800a81:	5d                   	pop    %ebp
  800a82:	c3                   	ret    

00800a83 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a83:	55                   	push   %ebp
  800a84:	89 e5                	mov    %esp,%ebp
  800a86:	57                   	push   %edi
  800a87:	56                   	push   %esi
  800a88:	53                   	push   %ebx
  800a89:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a8f:	eb 03                	jmp    800a94 <strtol+0x11>
		s++;
  800a91:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a94:	0f b6 01             	movzbl (%ecx),%eax
  800a97:	3c 20                	cmp    $0x20,%al
  800a99:	74 f6                	je     800a91 <strtol+0xe>
  800a9b:	3c 09                	cmp    $0x9,%al
  800a9d:	74 f2                	je     800a91 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a9f:	3c 2b                	cmp    $0x2b,%al
  800aa1:	74 2e                	je     800ad1 <strtol+0x4e>
	int neg = 0;
  800aa3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800aa8:	3c 2d                	cmp    $0x2d,%al
  800aaa:	74 2f                	je     800adb <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aac:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ab2:	75 05                	jne    800ab9 <strtol+0x36>
  800ab4:	80 39 30             	cmpb   $0x30,(%ecx)
  800ab7:	74 2c                	je     800ae5 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ab9:	85 db                	test   %ebx,%ebx
  800abb:	75 0a                	jne    800ac7 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800abd:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800ac2:	80 39 30             	cmpb   $0x30,(%ecx)
  800ac5:	74 28                	je     800aef <strtol+0x6c>
		base = 10;
  800ac7:	b8 00 00 00 00       	mov    $0x0,%eax
  800acc:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800acf:	eb 50                	jmp    800b21 <strtol+0x9e>
		s++;
  800ad1:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800ad4:	bf 00 00 00 00       	mov    $0x0,%edi
  800ad9:	eb d1                	jmp    800aac <strtol+0x29>
		s++, neg = 1;
  800adb:	83 c1 01             	add    $0x1,%ecx
  800ade:	bf 01 00 00 00       	mov    $0x1,%edi
  800ae3:	eb c7                	jmp    800aac <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ae5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ae9:	74 0e                	je     800af9 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800aeb:	85 db                	test   %ebx,%ebx
  800aed:	75 d8                	jne    800ac7 <strtol+0x44>
		s++, base = 8;
  800aef:	83 c1 01             	add    $0x1,%ecx
  800af2:	bb 08 00 00 00       	mov    $0x8,%ebx
  800af7:	eb ce                	jmp    800ac7 <strtol+0x44>
		s += 2, base = 16;
  800af9:	83 c1 02             	add    $0x2,%ecx
  800afc:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b01:	eb c4                	jmp    800ac7 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800b03:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b06:	89 f3                	mov    %esi,%ebx
  800b08:	80 fb 19             	cmp    $0x19,%bl
  800b0b:	77 29                	ja     800b36 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b0d:	0f be d2             	movsbl %dl,%edx
  800b10:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b13:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b16:	7d 30                	jge    800b48 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b18:	83 c1 01             	add    $0x1,%ecx
  800b1b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b1f:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b21:	0f b6 11             	movzbl (%ecx),%edx
  800b24:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b27:	89 f3                	mov    %esi,%ebx
  800b29:	80 fb 09             	cmp    $0x9,%bl
  800b2c:	77 d5                	ja     800b03 <strtol+0x80>
			dig = *s - '0';
  800b2e:	0f be d2             	movsbl %dl,%edx
  800b31:	83 ea 30             	sub    $0x30,%edx
  800b34:	eb dd                	jmp    800b13 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800b36:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b39:	89 f3                	mov    %esi,%ebx
  800b3b:	80 fb 19             	cmp    $0x19,%bl
  800b3e:	77 08                	ja     800b48 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b40:	0f be d2             	movsbl %dl,%edx
  800b43:	83 ea 37             	sub    $0x37,%edx
  800b46:	eb cb                	jmp    800b13 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b48:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b4c:	74 05                	je     800b53 <strtol+0xd0>
		*endptr = (char *) s;
  800b4e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b51:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b53:	89 c2                	mov    %eax,%edx
  800b55:	f7 da                	neg    %edx
  800b57:	85 ff                	test   %edi,%edi
  800b59:	0f 45 c2             	cmovne %edx,%eax
}
  800b5c:	5b                   	pop    %ebx
  800b5d:	5e                   	pop    %esi
  800b5e:	5f                   	pop    %edi
  800b5f:	5d                   	pop    %ebp
  800b60:	c3                   	ret    

00800b61 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b61:	55                   	push   %ebp
  800b62:	89 e5                	mov    %esp,%ebp
  800b64:	57                   	push   %edi
  800b65:	56                   	push   %esi
  800b66:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b67:	b8 00 00 00 00       	mov    $0x0,%eax
  800b6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b72:	89 c3                	mov    %eax,%ebx
  800b74:	89 c7                	mov    %eax,%edi
  800b76:	89 c6                	mov    %eax,%esi
  800b78:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b7a:	5b                   	pop    %ebx
  800b7b:	5e                   	pop    %esi
  800b7c:	5f                   	pop    %edi
  800b7d:	5d                   	pop    %ebp
  800b7e:	c3                   	ret    

00800b7f <sys_cgetc>:

int
sys_cgetc(void)
{
  800b7f:	55                   	push   %ebp
  800b80:	89 e5                	mov    %esp,%ebp
  800b82:	57                   	push   %edi
  800b83:	56                   	push   %esi
  800b84:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b85:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b8f:	89 d1                	mov    %edx,%ecx
  800b91:	89 d3                	mov    %edx,%ebx
  800b93:	89 d7                	mov    %edx,%edi
  800b95:	89 d6                	mov    %edx,%esi
  800b97:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b99:	5b                   	pop    %ebx
  800b9a:	5e                   	pop    %esi
  800b9b:	5f                   	pop    %edi
  800b9c:	5d                   	pop    %ebp
  800b9d:	c3                   	ret    

00800b9e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b9e:	55                   	push   %ebp
  800b9f:	89 e5                	mov    %esp,%ebp
  800ba1:	57                   	push   %edi
  800ba2:	56                   	push   %esi
  800ba3:	53                   	push   %ebx
  800ba4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ba7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bac:	8b 55 08             	mov    0x8(%ebp),%edx
  800baf:	b8 03 00 00 00       	mov    $0x3,%eax
  800bb4:	89 cb                	mov    %ecx,%ebx
  800bb6:	89 cf                	mov    %ecx,%edi
  800bb8:	89 ce                	mov    %ecx,%esi
  800bba:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bbc:	85 c0                	test   %eax,%eax
  800bbe:	7f 08                	jg     800bc8 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc3:	5b                   	pop    %ebx
  800bc4:	5e                   	pop    %esi
  800bc5:	5f                   	pop    %edi
  800bc6:	5d                   	pop    %ebp
  800bc7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc8:	83 ec 0c             	sub    $0xc,%esp
  800bcb:	50                   	push   %eax
  800bcc:	6a 03                	push   $0x3
  800bce:	68 7f 22 80 00       	push   $0x80227f
  800bd3:	6a 23                	push   $0x23
  800bd5:	68 9c 22 80 00       	push   $0x80229c
  800bda:	e8 4b f5 ff ff       	call   80012a <_panic>

00800bdf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bdf:	55                   	push   %ebp
  800be0:	89 e5                	mov    %esp,%ebp
  800be2:	57                   	push   %edi
  800be3:	56                   	push   %esi
  800be4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800be5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bea:	b8 02 00 00 00       	mov    $0x2,%eax
  800bef:	89 d1                	mov    %edx,%ecx
  800bf1:	89 d3                	mov    %edx,%ebx
  800bf3:	89 d7                	mov    %edx,%edi
  800bf5:	89 d6                	mov    %edx,%esi
  800bf7:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bf9:	5b                   	pop    %ebx
  800bfa:	5e                   	pop    %esi
  800bfb:	5f                   	pop    %edi
  800bfc:	5d                   	pop    %ebp
  800bfd:	c3                   	ret    

00800bfe <sys_yield>:

void
sys_yield(void)
{
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	57                   	push   %edi
  800c02:	56                   	push   %esi
  800c03:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c04:	ba 00 00 00 00       	mov    $0x0,%edx
  800c09:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c0e:	89 d1                	mov    %edx,%ecx
  800c10:	89 d3                	mov    %edx,%ebx
  800c12:	89 d7                	mov    %edx,%edi
  800c14:	89 d6                	mov    %edx,%esi
  800c16:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c18:	5b                   	pop    %ebx
  800c19:	5e                   	pop    %esi
  800c1a:	5f                   	pop    %edi
  800c1b:	5d                   	pop    %ebp
  800c1c:	c3                   	ret    

00800c1d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c1d:	55                   	push   %ebp
  800c1e:	89 e5                	mov    %esp,%ebp
  800c20:	57                   	push   %edi
  800c21:	56                   	push   %esi
  800c22:	53                   	push   %ebx
  800c23:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c26:	be 00 00 00 00       	mov    $0x0,%esi
  800c2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c31:	b8 04 00 00 00       	mov    $0x4,%eax
  800c36:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c39:	89 f7                	mov    %esi,%edi
  800c3b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c3d:	85 c0                	test   %eax,%eax
  800c3f:	7f 08                	jg     800c49 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c44:	5b                   	pop    %ebx
  800c45:	5e                   	pop    %esi
  800c46:	5f                   	pop    %edi
  800c47:	5d                   	pop    %ebp
  800c48:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c49:	83 ec 0c             	sub    $0xc,%esp
  800c4c:	50                   	push   %eax
  800c4d:	6a 04                	push   $0x4
  800c4f:	68 7f 22 80 00       	push   $0x80227f
  800c54:	6a 23                	push   $0x23
  800c56:	68 9c 22 80 00       	push   $0x80229c
  800c5b:	e8 ca f4 ff ff       	call   80012a <_panic>

00800c60 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	57                   	push   %edi
  800c64:	56                   	push   %esi
  800c65:	53                   	push   %ebx
  800c66:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c69:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6f:	b8 05 00 00 00       	mov    $0x5,%eax
  800c74:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c77:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c7a:	8b 75 18             	mov    0x18(%ebp),%esi
  800c7d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c7f:	85 c0                	test   %eax,%eax
  800c81:	7f 08                	jg     800c8b <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c86:	5b                   	pop    %ebx
  800c87:	5e                   	pop    %esi
  800c88:	5f                   	pop    %edi
  800c89:	5d                   	pop    %ebp
  800c8a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8b:	83 ec 0c             	sub    $0xc,%esp
  800c8e:	50                   	push   %eax
  800c8f:	6a 05                	push   $0x5
  800c91:	68 7f 22 80 00       	push   $0x80227f
  800c96:	6a 23                	push   $0x23
  800c98:	68 9c 22 80 00       	push   $0x80229c
  800c9d:	e8 88 f4 ff ff       	call   80012a <_panic>

00800ca2 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ca2:	55                   	push   %ebp
  800ca3:	89 e5                	mov    %esp,%ebp
  800ca5:	57                   	push   %edi
  800ca6:	56                   	push   %esi
  800ca7:	53                   	push   %ebx
  800ca8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cab:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb6:	b8 06 00 00 00       	mov    $0x6,%eax
  800cbb:	89 df                	mov    %ebx,%edi
  800cbd:	89 de                	mov    %ebx,%esi
  800cbf:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cc1:	85 c0                	test   %eax,%eax
  800cc3:	7f 08                	jg     800ccd <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cc5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc8:	5b                   	pop    %ebx
  800cc9:	5e                   	pop    %esi
  800cca:	5f                   	pop    %edi
  800ccb:	5d                   	pop    %ebp
  800ccc:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccd:	83 ec 0c             	sub    $0xc,%esp
  800cd0:	50                   	push   %eax
  800cd1:	6a 06                	push   $0x6
  800cd3:	68 7f 22 80 00       	push   $0x80227f
  800cd8:	6a 23                	push   $0x23
  800cda:	68 9c 22 80 00       	push   $0x80229c
  800cdf:	e8 46 f4 ff ff       	call   80012a <_panic>

00800ce4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	57                   	push   %edi
  800ce8:	56                   	push   %esi
  800ce9:	53                   	push   %ebx
  800cea:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ced:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf8:	b8 08 00 00 00       	mov    $0x8,%eax
  800cfd:	89 df                	mov    %ebx,%edi
  800cff:	89 de                	mov    %ebx,%esi
  800d01:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d03:	85 c0                	test   %eax,%eax
  800d05:	7f 08                	jg     800d0f <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0a:	5b                   	pop    %ebx
  800d0b:	5e                   	pop    %esi
  800d0c:	5f                   	pop    %edi
  800d0d:	5d                   	pop    %ebp
  800d0e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0f:	83 ec 0c             	sub    $0xc,%esp
  800d12:	50                   	push   %eax
  800d13:	6a 08                	push   $0x8
  800d15:	68 7f 22 80 00       	push   $0x80227f
  800d1a:	6a 23                	push   $0x23
  800d1c:	68 9c 22 80 00       	push   $0x80229c
  800d21:	e8 04 f4 ff ff       	call   80012a <_panic>

00800d26 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d26:	55                   	push   %ebp
  800d27:	89 e5                	mov    %esp,%ebp
  800d29:	57                   	push   %edi
  800d2a:	56                   	push   %esi
  800d2b:	53                   	push   %ebx
  800d2c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d2f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d34:	8b 55 08             	mov    0x8(%ebp),%edx
  800d37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3a:	b8 09 00 00 00       	mov    $0x9,%eax
  800d3f:	89 df                	mov    %ebx,%edi
  800d41:	89 de                	mov    %ebx,%esi
  800d43:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d45:	85 c0                	test   %eax,%eax
  800d47:	7f 08                	jg     800d51 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4c:	5b                   	pop    %ebx
  800d4d:	5e                   	pop    %esi
  800d4e:	5f                   	pop    %edi
  800d4f:	5d                   	pop    %ebp
  800d50:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d51:	83 ec 0c             	sub    $0xc,%esp
  800d54:	50                   	push   %eax
  800d55:	6a 09                	push   $0x9
  800d57:	68 7f 22 80 00       	push   $0x80227f
  800d5c:	6a 23                	push   $0x23
  800d5e:	68 9c 22 80 00       	push   $0x80229c
  800d63:	e8 c2 f3 ff ff       	call   80012a <_panic>

00800d68 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d68:	55                   	push   %ebp
  800d69:	89 e5                	mov    %esp,%ebp
  800d6b:	57                   	push   %edi
  800d6c:	56                   	push   %esi
  800d6d:	53                   	push   %ebx
  800d6e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d71:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d76:	8b 55 08             	mov    0x8(%ebp),%edx
  800d79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d81:	89 df                	mov    %ebx,%edi
  800d83:	89 de                	mov    %ebx,%esi
  800d85:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d87:	85 c0                	test   %eax,%eax
  800d89:	7f 08                	jg     800d93 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d8e:	5b                   	pop    %ebx
  800d8f:	5e                   	pop    %esi
  800d90:	5f                   	pop    %edi
  800d91:	5d                   	pop    %ebp
  800d92:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d93:	83 ec 0c             	sub    $0xc,%esp
  800d96:	50                   	push   %eax
  800d97:	6a 0a                	push   $0xa
  800d99:	68 7f 22 80 00       	push   $0x80227f
  800d9e:	6a 23                	push   $0x23
  800da0:	68 9c 22 80 00       	push   $0x80229c
  800da5:	e8 80 f3 ff ff       	call   80012a <_panic>

00800daa <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800daa:	55                   	push   %ebp
  800dab:	89 e5                	mov    %esp,%ebp
  800dad:	57                   	push   %edi
  800dae:	56                   	push   %esi
  800daf:	53                   	push   %ebx
	asm volatile("int %1\n"
  800db0:	8b 55 08             	mov    0x8(%ebp),%edx
  800db3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db6:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dbb:	be 00 00 00 00       	mov    $0x0,%esi
  800dc0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dc3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dc6:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dc8:	5b                   	pop    %ebx
  800dc9:	5e                   	pop    %esi
  800dca:	5f                   	pop    %edi
  800dcb:	5d                   	pop    %ebp
  800dcc:	c3                   	ret    

00800dcd <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dcd:	55                   	push   %ebp
  800dce:	89 e5                	mov    %esp,%ebp
  800dd0:	57                   	push   %edi
  800dd1:	56                   	push   %esi
  800dd2:	53                   	push   %ebx
  800dd3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dd6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ddb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dde:	b8 0d 00 00 00       	mov    $0xd,%eax
  800de3:	89 cb                	mov    %ecx,%ebx
  800de5:	89 cf                	mov    %ecx,%edi
  800de7:	89 ce                	mov    %ecx,%esi
  800de9:	cd 30                	int    $0x30
	if(check && ret > 0)
  800deb:	85 c0                	test   %eax,%eax
  800ded:	7f 08                	jg     800df7 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800def:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df2:	5b                   	pop    %ebx
  800df3:	5e                   	pop    %esi
  800df4:	5f                   	pop    %edi
  800df5:	5d                   	pop    %ebp
  800df6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800df7:	83 ec 0c             	sub    $0xc,%esp
  800dfa:	50                   	push   %eax
  800dfb:	6a 0d                	push   $0xd
  800dfd:	68 7f 22 80 00       	push   $0x80227f
  800e02:	6a 23                	push   $0x23
  800e04:	68 9c 22 80 00       	push   $0x80229c
  800e09:	e8 1c f3 ff ff       	call   80012a <_panic>

00800e0e <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e0e:	55                   	push   %ebp
  800e0f:	89 e5                	mov    %esp,%ebp
  800e11:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800e14:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800e1b:	74 0a                	je     800e27 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler %e",r);
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
	}
       
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e20:	a3 08 40 80 00       	mov    %eax,0x804008
}
  800e25:	c9                   	leave  
  800e26:	c3                   	ret    
		if((r=sys_page_alloc(thisenv->env_id,(void *)UXSTACKTOP-PGSIZE,PTE_P|PTE_W|PTE_U))<0)
  800e27:	a1 04 40 80 00       	mov    0x804004,%eax
  800e2c:	8b 40 48             	mov    0x48(%eax),%eax
  800e2f:	83 ec 04             	sub    $0x4,%esp
  800e32:	6a 07                	push   $0x7
  800e34:	68 00 f0 bf ee       	push   $0xeebff000
  800e39:	50                   	push   %eax
  800e3a:	e8 de fd ff ff       	call   800c1d <sys_page_alloc>
  800e3f:	83 c4 10             	add    $0x10,%esp
  800e42:	85 c0                	test   %eax,%eax
  800e44:	78 1b                	js     800e61 <set_pgfault_handler+0x53>
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
  800e46:	a1 04 40 80 00       	mov    0x804004,%eax
  800e4b:	8b 40 48             	mov    0x48(%eax),%eax
  800e4e:	83 ec 08             	sub    $0x8,%esp
  800e51:	68 73 0e 80 00       	push   $0x800e73
  800e56:	50                   	push   %eax
  800e57:	e8 0c ff ff ff       	call   800d68 <sys_env_set_pgfault_upcall>
  800e5c:	83 c4 10             	add    $0x10,%esp
  800e5f:	eb bc                	jmp    800e1d <set_pgfault_handler+0xf>
			panic("set_pgfault_handler %e",r);
  800e61:	50                   	push   %eax
  800e62:	68 aa 22 80 00       	push   $0x8022aa
  800e67:	6a 22                	push   $0x22
  800e69:	68 c1 22 80 00       	push   $0x8022c1
  800e6e:	e8 b7 f2 ff ff       	call   80012a <_panic>

00800e73 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e73:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e74:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800e79:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e7b:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 48(%esp), %ebp
  800e7e:	8b 6c 24 30          	mov    0x30(%esp),%ebp
        subl $4, %ebp
  800e82:	83 ed 04             	sub    $0x4,%ebp
        movl %ebp, 48(%esp)
  800e85:	89 6c 24 30          	mov    %ebp,0x30(%esp)
        movl 40(%esp), %eax
  800e89:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl %eax, (%ebp)
  800e8d:	89 45 00             	mov    %eax,0x0(%ebp)
	// Restore the trap-time registers.  After you do this, you
 	// can no longer modify any general-purpose registers.
 	// LAB 4: Your code here.
        addl $8, %esp
  800e90:	83 c4 08             	add    $0x8,%esp
        popal
  800e93:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $4, %esp
  800e94:	83 c4 04             	add    $0x4,%esp
        popfl
  800e97:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  800e98:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  800e99:	c3                   	ret    

00800e9a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e9a:	55                   	push   %ebp
  800e9b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea0:	05 00 00 00 30       	add    $0x30000000,%eax
  800ea5:	c1 e8 0c             	shr    $0xc,%eax
}
  800ea8:	5d                   	pop    %ebp
  800ea9:	c3                   	ret    

00800eaa <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800eaa:	55                   	push   %ebp
  800eab:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ead:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb0:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800eb5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800eba:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ebf:	5d                   	pop    %ebp
  800ec0:	c3                   	ret    

00800ec1 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ec1:	55                   	push   %ebp
  800ec2:	89 e5                	mov    %esp,%ebp
  800ec4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ec7:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ecc:	89 c2                	mov    %eax,%edx
  800ece:	c1 ea 16             	shr    $0x16,%edx
  800ed1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ed8:	f6 c2 01             	test   $0x1,%dl
  800edb:	74 2a                	je     800f07 <fd_alloc+0x46>
  800edd:	89 c2                	mov    %eax,%edx
  800edf:	c1 ea 0c             	shr    $0xc,%edx
  800ee2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ee9:	f6 c2 01             	test   $0x1,%dl
  800eec:	74 19                	je     800f07 <fd_alloc+0x46>
  800eee:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800ef3:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ef8:	75 d2                	jne    800ecc <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800efa:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f00:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800f05:	eb 07                	jmp    800f0e <fd_alloc+0x4d>
			*fd_store = fd;
  800f07:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f09:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f0e:	5d                   	pop    %ebp
  800f0f:	c3                   	ret    

00800f10 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f10:	55                   	push   %ebp
  800f11:	89 e5                	mov    %esp,%ebp
  800f13:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f16:	83 f8 1f             	cmp    $0x1f,%eax
  800f19:	77 36                	ja     800f51 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f1b:	c1 e0 0c             	shl    $0xc,%eax
  800f1e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f23:	89 c2                	mov    %eax,%edx
  800f25:	c1 ea 16             	shr    $0x16,%edx
  800f28:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f2f:	f6 c2 01             	test   $0x1,%dl
  800f32:	74 24                	je     800f58 <fd_lookup+0x48>
  800f34:	89 c2                	mov    %eax,%edx
  800f36:	c1 ea 0c             	shr    $0xc,%edx
  800f39:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f40:	f6 c2 01             	test   $0x1,%dl
  800f43:	74 1a                	je     800f5f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f45:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f48:	89 02                	mov    %eax,(%edx)
	return 0;
  800f4a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f4f:	5d                   	pop    %ebp
  800f50:	c3                   	ret    
		return -E_INVAL;
  800f51:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f56:	eb f7                	jmp    800f4f <fd_lookup+0x3f>
		return -E_INVAL;
  800f58:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f5d:	eb f0                	jmp    800f4f <fd_lookup+0x3f>
  800f5f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f64:	eb e9                	jmp    800f4f <fd_lookup+0x3f>

00800f66 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f66:	55                   	push   %ebp
  800f67:	89 e5                	mov    %esp,%ebp
  800f69:	83 ec 08             	sub    $0x8,%esp
  800f6c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f6f:	ba 50 23 80 00       	mov    $0x802350,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f74:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800f79:	39 08                	cmp    %ecx,(%eax)
  800f7b:	74 33                	je     800fb0 <dev_lookup+0x4a>
  800f7d:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800f80:	8b 02                	mov    (%edx),%eax
  800f82:	85 c0                	test   %eax,%eax
  800f84:	75 f3                	jne    800f79 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f86:	a1 04 40 80 00       	mov    0x804004,%eax
  800f8b:	8b 40 48             	mov    0x48(%eax),%eax
  800f8e:	83 ec 04             	sub    $0x4,%esp
  800f91:	51                   	push   %ecx
  800f92:	50                   	push   %eax
  800f93:	68 d0 22 80 00       	push   $0x8022d0
  800f98:	e8 68 f2 ff ff       	call   800205 <cprintf>
	*dev = 0;
  800f9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fa0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800fa6:	83 c4 10             	add    $0x10,%esp
  800fa9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fae:	c9                   	leave  
  800faf:	c3                   	ret    
			*dev = devtab[i];
  800fb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb3:	89 01                	mov    %eax,(%ecx)
			return 0;
  800fb5:	b8 00 00 00 00       	mov    $0x0,%eax
  800fba:	eb f2                	jmp    800fae <dev_lookup+0x48>

00800fbc <fd_close>:
{
  800fbc:	55                   	push   %ebp
  800fbd:	89 e5                	mov    %esp,%ebp
  800fbf:	57                   	push   %edi
  800fc0:	56                   	push   %esi
  800fc1:	53                   	push   %ebx
  800fc2:	83 ec 1c             	sub    $0x1c,%esp
  800fc5:	8b 75 08             	mov    0x8(%ebp),%esi
  800fc8:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fcb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fce:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fcf:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fd5:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fd8:	50                   	push   %eax
  800fd9:	e8 32 ff ff ff       	call   800f10 <fd_lookup>
  800fde:	89 c3                	mov    %eax,%ebx
  800fe0:	83 c4 08             	add    $0x8,%esp
  800fe3:	85 c0                	test   %eax,%eax
  800fe5:	78 05                	js     800fec <fd_close+0x30>
	    || fd != fd2)
  800fe7:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800fea:	74 16                	je     801002 <fd_close+0x46>
		return (must_exist ? r : 0);
  800fec:	89 f8                	mov    %edi,%eax
  800fee:	84 c0                	test   %al,%al
  800ff0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ff5:	0f 44 d8             	cmove  %eax,%ebx
}
  800ff8:	89 d8                	mov    %ebx,%eax
  800ffa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ffd:	5b                   	pop    %ebx
  800ffe:	5e                   	pop    %esi
  800fff:	5f                   	pop    %edi
  801000:	5d                   	pop    %ebp
  801001:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801002:	83 ec 08             	sub    $0x8,%esp
  801005:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801008:	50                   	push   %eax
  801009:	ff 36                	pushl  (%esi)
  80100b:	e8 56 ff ff ff       	call   800f66 <dev_lookup>
  801010:	89 c3                	mov    %eax,%ebx
  801012:	83 c4 10             	add    $0x10,%esp
  801015:	85 c0                	test   %eax,%eax
  801017:	78 15                	js     80102e <fd_close+0x72>
		if (dev->dev_close)
  801019:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80101c:	8b 40 10             	mov    0x10(%eax),%eax
  80101f:	85 c0                	test   %eax,%eax
  801021:	74 1b                	je     80103e <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  801023:	83 ec 0c             	sub    $0xc,%esp
  801026:	56                   	push   %esi
  801027:	ff d0                	call   *%eax
  801029:	89 c3                	mov    %eax,%ebx
  80102b:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80102e:	83 ec 08             	sub    $0x8,%esp
  801031:	56                   	push   %esi
  801032:	6a 00                	push   $0x0
  801034:	e8 69 fc ff ff       	call   800ca2 <sys_page_unmap>
	return r;
  801039:	83 c4 10             	add    $0x10,%esp
  80103c:	eb ba                	jmp    800ff8 <fd_close+0x3c>
			r = 0;
  80103e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801043:	eb e9                	jmp    80102e <fd_close+0x72>

00801045 <close>:

int
close(int fdnum)
{
  801045:	55                   	push   %ebp
  801046:	89 e5                	mov    %esp,%ebp
  801048:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80104b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80104e:	50                   	push   %eax
  80104f:	ff 75 08             	pushl  0x8(%ebp)
  801052:	e8 b9 fe ff ff       	call   800f10 <fd_lookup>
  801057:	83 c4 08             	add    $0x8,%esp
  80105a:	85 c0                	test   %eax,%eax
  80105c:	78 10                	js     80106e <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80105e:	83 ec 08             	sub    $0x8,%esp
  801061:	6a 01                	push   $0x1
  801063:	ff 75 f4             	pushl  -0xc(%ebp)
  801066:	e8 51 ff ff ff       	call   800fbc <fd_close>
  80106b:	83 c4 10             	add    $0x10,%esp
}
  80106e:	c9                   	leave  
  80106f:	c3                   	ret    

00801070 <close_all>:

void
close_all(void)
{
  801070:	55                   	push   %ebp
  801071:	89 e5                	mov    %esp,%ebp
  801073:	53                   	push   %ebx
  801074:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801077:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80107c:	83 ec 0c             	sub    $0xc,%esp
  80107f:	53                   	push   %ebx
  801080:	e8 c0 ff ff ff       	call   801045 <close>
	for (i = 0; i < MAXFD; i++)
  801085:	83 c3 01             	add    $0x1,%ebx
  801088:	83 c4 10             	add    $0x10,%esp
  80108b:	83 fb 20             	cmp    $0x20,%ebx
  80108e:	75 ec                	jne    80107c <close_all+0xc>
}
  801090:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801093:	c9                   	leave  
  801094:	c3                   	ret    

00801095 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801095:	55                   	push   %ebp
  801096:	89 e5                	mov    %esp,%ebp
  801098:	57                   	push   %edi
  801099:	56                   	push   %esi
  80109a:	53                   	push   %ebx
  80109b:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80109e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010a1:	50                   	push   %eax
  8010a2:	ff 75 08             	pushl  0x8(%ebp)
  8010a5:	e8 66 fe ff ff       	call   800f10 <fd_lookup>
  8010aa:	89 c3                	mov    %eax,%ebx
  8010ac:	83 c4 08             	add    $0x8,%esp
  8010af:	85 c0                	test   %eax,%eax
  8010b1:	0f 88 81 00 00 00    	js     801138 <dup+0xa3>
		return r;
	close(newfdnum);
  8010b7:	83 ec 0c             	sub    $0xc,%esp
  8010ba:	ff 75 0c             	pushl  0xc(%ebp)
  8010bd:	e8 83 ff ff ff       	call   801045 <close>

	newfd = INDEX2FD(newfdnum);
  8010c2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010c5:	c1 e6 0c             	shl    $0xc,%esi
  8010c8:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8010ce:	83 c4 04             	add    $0x4,%esp
  8010d1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010d4:	e8 d1 fd ff ff       	call   800eaa <fd2data>
  8010d9:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8010db:	89 34 24             	mov    %esi,(%esp)
  8010de:	e8 c7 fd ff ff       	call   800eaa <fd2data>
  8010e3:	83 c4 10             	add    $0x10,%esp
  8010e6:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010e8:	89 d8                	mov    %ebx,%eax
  8010ea:	c1 e8 16             	shr    $0x16,%eax
  8010ed:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010f4:	a8 01                	test   $0x1,%al
  8010f6:	74 11                	je     801109 <dup+0x74>
  8010f8:	89 d8                	mov    %ebx,%eax
  8010fa:	c1 e8 0c             	shr    $0xc,%eax
  8010fd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801104:	f6 c2 01             	test   $0x1,%dl
  801107:	75 39                	jne    801142 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801109:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80110c:	89 d0                	mov    %edx,%eax
  80110e:	c1 e8 0c             	shr    $0xc,%eax
  801111:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801118:	83 ec 0c             	sub    $0xc,%esp
  80111b:	25 07 0e 00 00       	and    $0xe07,%eax
  801120:	50                   	push   %eax
  801121:	56                   	push   %esi
  801122:	6a 00                	push   $0x0
  801124:	52                   	push   %edx
  801125:	6a 00                	push   $0x0
  801127:	e8 34 fb ff ff       	call   800c60 <sys_page_map>
  80112c:	89 c3                	mov    %eax,%ebx
  80112e:	83 c4 20             	add    $0x20,%esp
  801131:	85 c0                	test   %eax,%eax
  801133:	78 31                	js     801166 <dup+0xd1>
		goto err;

	return newfdnum;
  801135:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801138:	89 d8                	mov    %ebx,%eax
  80113a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80113d:	5b                   	pop    %ebx
  80113e:	5e                   	pop    %esi
  80113f:	5f                   	pop    %edi
  801140:	5d                   	pop    %ebp
  801141:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801142:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801149:	83 ec 0c             	sub    $0xc,%esp
  80114c:	25 07 0e 00 00       	and    $0xe07,%eax
  801151:	50                   	push   %eax
  801152:	57                   	push   %edi
  801153:	6a 00                	push   $0x0
  801155:	53                   	push   %ebx
  801156:	6a 00                	push   $0x0
  801158:	e8 03 fb ff ff       	call   800c60 <sys_page_map>
  80115d:	89 c3                	mov    %eax,%ebx
  80115f:	83 c4 20             	add    $0x20,%esp
  801162:	85 c0                	test   %eax,%eax
  801164:	79 a3                	jns    801109 <dup+0x74>
	sys_page_unmap(0, newfd);
  801166:	83 ec 08             	sub    $0x8,%esp
  801169:	56                   	push   %esi
  80116a:	6a 00                	push   $0x0
  80116c:	e8 31 fb ff ff       	call   800ca2 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801171:	83 c4 08             	add    $0x8,%esp
  801174:	57                   	push   %edi
  801175:	6a 00                	push   $0x0
  801177:	e8 26 fb ff ff       	call   800ca2 <sys_page_unmap>
	return r;
  80117c:	83 c4 10             	add    $0x10,%esp
  80117f:	eb b7                	jmp    801138 <dup+0xa3>

00801181 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801181:	55                   	push   %ebp
  801182:	89 e5                	mov    %esp,%ebp
  801184:	53                   	push   %ebx
  801185:	83 ec 14             	sub    $0x14,%esp
  801188:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80118b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80118e:	50                   	push   %eax
  80118f:	53                   	push   %ebx
  801190:	e8 7b fd ff ff       	call   800f10 <fd_lookup>
  801195:	83 c4 08             	add    $0x8,%esp
  801198:	85 c0                	test   %eax,%eax
  80119a:	78 3f                	js     8011db <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80119c:	83 ec 08             	sub    $0x8,%esp
  80119f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011a2:	50                   	push   %eax
  8011a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011a6:	ff 30                	pushl  (%eax)
  8011a8:	e8 b9 fd ff ff       	call   800f66 <dev_lookup>
  8011ad:	83 c4 10             	add    $0x10,%esp
  8011b0:	85 c0                	test   %eax,%eax
  8011b2:	78 27                	js     8011db <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011b4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011b7:	8b 42 08             	mov    0x8(%edx),%eax
  8011ba:	83 e0 03             	and    $0x3,%eax
  8011bd:	83 f8 01             	cmp    $0x1,%eax
  8011c0:	74 1e                	je     8011e0 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8011c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011c5:	8b 40 08             	mov    0x8(%eax),%eax
  8011c8:	85 c0                	test   %eax,%eax
  8011ca:	74 35                	je     801201 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011cc:	83 ec 04             	sub    $0x4,%esp
  8011cf:	ff 75 10             	pushl  0x10(%ebp)
  8011d2:	ff 75 0c             	pushl  0xc(%ebp)
  8011d5:	52                   	push   %edx
  8011d6:	ff d0                	call   *%eax
  8011d8:	83 c4 10             	add    $0x10,%esp
}
  8011db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011de:	c9                   	leave  
  8011df:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011e0:	a1 04 40 80 00       	mov    0x804004,%eax
  8011e5:	8b 40 48             	mov    0x48(%eax),%eax
  8011e8:	83 ec 04             	sub    $0x4,%esp
  8011eb:	53                   	push   %ebx
  8011ec:	50                   	push   %eax
  8011ed:	68 14 23 80 00       	push   $0x802314
  8011f2:	e8 0e f0 ff ff       	call   800205 <cprintf>
		return -E_INVAL;
  8011f7:	83 c4 10             	add    $0x10,%esp
  8011fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011ff:	eb da                	jmp    8011db <read+0x5a>
		return -E_NOT_SUPP;
  801201:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801206:	eb d3                	jmp    8011db <read+0x5a>

00801208 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801208:	55                   	push   %ebp
  801209:	89 e5                	mov    %esp,%ebp
  80120b:	57                   	push   %edi
  80120c:	56                   	push   %esi
  80120d:	53                   	push   %ebx
  80120e:	83 ec 0c             	sub    $0xc,%esp
  801211:	8b 7d 08             	mov    0x8(%ebp),%edi
  801214:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801217:	bb 00 00 00 00       	mov    $0x0,%ebx
  80121c:	39 f3                	cmp    %esi,%ebx
  80121e:	73 25                	jae    801245 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801220:	83 ec 04             	sub    $0x4,%esp
  801223:	89 f0                	mov    %esi,%eax
  801225:	29 d8                	sub    %ebx,%eax
  801227:	50                   	push   %eax
  801228:	89 d8                	mov    %ebx,%eax
  80122a:	03 45 0c             	add    0xc(%ebp),%eax
  80122d:	50                   	push   %eax
  80122e:	57                   	push   %edi
  80122f:	e8 4d ff ff ff       	call   801181 <read>
		if (m < 0)
  801234:	83 c4 10             	add    $0x10,%esp
  801237:	85 c0                	test   %eax,%eax
  801239:	78 08                	js     801243 <readn+0x3b>
			return m;
		if (m == 0)
  80123b:	85 c0                	test   %eax,%eax
  80123d:	74 06                	je     801245 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  80123f:	01 c3                	add    %eax,%ebx
  801241:	eb d9                	jmp    80121c <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801243:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801245:	89 d8                	mov    %ebx,%eax
  801247:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80124a:	5b                   	pop    %ebx
  80124b:	5e                   	pop    %esi
  80124c:	5f                   	pop    %edi
  80124d:	5d                   	pop    %ebp
  80124e:	c3                   	ret    

0080124f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80124f:	55                   	push   %ebp
  801250:	89 e5                	mov    %esp,%ebp
  801252:	53                   	push   %ebx
  801253:	83 ec 14             	sub    $0x14,%esp
  801256:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801259:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80125c:	50                   	push   %eax
  80125d:	53                   	push   %ebx
  80125e:	e8 ad fc ff ff       	call   800f10 <fd_lookup>
  801263:	83 c4 08             	add    $0x8,%esp
  801266:	85 c0                	test   %eax,%eax
  801268:	78 3a                	js     8012a4 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80126a:	83 ec 08             	sub    $0x8,%esp
  80126d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801270:	50                   	push   %eax
  801271:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801274:	ff 30                	pushl  (%eax)
  801276:	e8 eb fc ff ff       	call   800f66 <dev_lookup>
  80127b:	83 c4 10             	add    $0x10,%esp
  80127e:	85 c0                	test   %eax,%eax
  801280:	78 22                	js     8012a4 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801282:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801285:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801289:	74 1e                	je     8012a9 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80128b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80128e:	8b 52 0c             	mov    0xc(%edx),%edx
  801291:	85 d2                	test   %edx,%edx
  801293:	74 35                	je     8012ca <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801295:	83 ec 04             	sub    $0x4,%esp
  801298:	ff 75 10             	pushl  0x10(%ebp)
  80129b:	ff 75 0c             	pushl  0xc(%ebp)
  80129e:	50                   	push   %eax
  80129f:	ff d2                	call   *%edx
  8012a1:	83 c4 10             	add    $0x10,%esp
}
  8012a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012a7:	c9                   	leave  
  8012a8:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012a9:	a1 04 40 80 00       	mov    0x804004,%eax
  8012ae:	8b 40 48             	mov    0x48(%eax),%eax
  8012b1:	83 ec 04             	sub    $0x4,%esp
  8012b4:	53                   	push   %ebx
  8012b5:	50                   	push   %eax
  8012b6:	68 30 23 80 00       	push   $0x802330
  8012bb:	e8 45 ef ff ff       	call   800205 <cprintf>
		return -E_INVAL;
  8012c0:	83 c4 10             	add    $0x10,%esp
  8012c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012c8:	eb da                	jmp    8012a4 <write+0x55>
		return -E_NOT_SUPP;
  8012ca:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012cf:	eb d3                	jmp    8012a4 <write+0x55>

008012d1 <seek>:

int
seek(int fdnum, off_t offset)
{
  8012d1:	55                   	push   %ebp
  8012d2:	89 e5                	mov    %esp,%ebp
  8012d4:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012d7:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012da:	50                   	push   %eax
  8012db:	ff 75 08             	pushl  0x8(%ebp)
  8012de:	e8 2d fc ff ff       	call   800f10 <fd_lookup>
  8012e3:	83 c4 08             	add    $0x8,%esp
  8012e6:	85 c0                	test   %eax,%eax
  8012e8:	78 0e                	js     8012f8 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012f0:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012f8:	c9                   	leave  
  8012f9:	c3                   	ret    

008012fa <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012fa:	55                   	push   %ebp
  8012fb:	89 e5                	mov    %esp,%ebp
  8012fd:	53                   	push   %ebx
  8012fe:	83 ec 14             	sub    $0x14,%esp
  801301:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801304:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801307:	50                   	push   %eax
  801308:	53                   	push   %ebx
  801309:	e8 02 fc ff ff       	call   800f10 <fd_lookup>
  80130e:	83 c4 08             	add    $0x8,%esp
  801311:	85 c0                	test   %eax,%eax
  801313:	78 37                	js     80134c <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801315:	83 ec 08             	sub    $0x8,%esp
  801318:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80131b:	50                   	push   %eax
  80131c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80131f:	ff 30                	pushl  (%eax)
  801321:	e8 40 fc ff ff       	call   800f66 <dev_lookup>
  801326:	83 c4 10             	add    $0x10,%esp
  801329:	85 c0                	test   %eax,%eax
  80132b:	78 1f                	js     80134c <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80132d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801330:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801334:	74 1b                	je     801351 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801336:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801339:	8b 52 18             	mov    0x18(%edx),%edx
  80133c:	85 d2                	test   %edx,%edx
  80133e:	74 32                	je     801372 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801340:	83 ec 08             	sub    $0x8,%esp
  801343:	ff 75 0c             	pushl  0xc(%ebp)
  801346:	50                   	push   %eax
  801347:	ff d2                	call   *%edx
  801349:	83 c4 10             	add    $0x10,%esp
}
  80134c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80134f:	c9                   	leave  
  801350:	c3                   	ret    
			thisenv->env_id, fdnum);
  801351:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801356:	8b 40 48             	mov    0x48(%eax),%eax
  801359:	83 ec 04             	sub    $0x4,%esp
  80135c:	53                   	push   %ebx
  80135d:	50                   	push   %eax
  80135e:	68 f0 22 80 00       	push   $0x8022f0
  801363:	e8 9d ee ff ff       	call   800205 <cprintf>
		return -E_INVAL;
  801368:	83 c4 10             	add    $0x10,%esp
  80136b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801370:	eb da                	jmp    80134c <ftruncate+0x52>
		return -E_NOT_SUPP;
  801372:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801377:	eb d3                	jmp    80134c <ftruncate+0x52>

00801379 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801379:	55                   	push   %ebp
  80137a:	89 e5                	mov    %esp,%ebp
  80137c:	53                   	push   %ebx
  80137d:	83 ec 14             	sub    $0x14,%esp
  801380:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801383:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801386:	50                   	push   %eax
  801387:	ff 75 08             	pushl  0x8(%ebp)
  80138a:	e8 81 fb ff ff       	call   800f10 <fd_lookup>
  80138f:	83 c4 08             	add    $0x8,%esp
  801392:	85 c0                	test   %eax,%eax
  801394:	78 4b                	js     8013e1 <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801396:	83 ec 08             	sub    $0x8,%esp
  801399:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80139c:	50                   	push   %eax
  80139d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a0:	ff 30                	pushl  (%eax)
  8013a2:	e8 bf fb ff ff       	call   800f66 <dev_lookup>
  8013a7:	83 c4 10             	add    $0x10,%esp
  8013aa:	85 c0                	test   %eax,%eax
  8013ac:	78 33                	js     8013e1 <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  8013ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013b1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013b5:	74 2f                	je     8013e6 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013b7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013ba:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013c1:	00 00 00 
	stat->st_isdir = 0;
  8013c4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013cb:	00 00 00 
	stat->st_dev = dev;
  8013ce:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013d4:	83 ec 08             	sub    $0x8,%esp
  8013d7:	53                   	push   %ebx
  8013d8:	ff 75 f0             	pushl  -0x10(%ebp)
  8013db:	ff 50 14             	call   *0x14(%eax)
  8013de:	83 c4 10             	add    $0x10,%esp
}
  8013e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013e4:	c9                   	leave  
  8013e5:	c3                   	ret    
		return -E_NOT_SUPP;
  8013e6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013eb:	eb f4                	jmp    8013e1 <fstat+0x68>

008013ed <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013ed:	55                   	push   %ebp
  8013ee:	89 e5                	mov    %esp,%ebp
  8013f0:	56                   	push   %esi
  8013f1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013f2:	83 ec 08             	sub    $0x8,%esp
  8013f5:	6a 00                	push   $0x0
  8013f7:	ff 75 08             	pushl  0x8(%ebp)
  8013fa:	e8 e7 01 00 00       	call   8015e6 <open>
  8013ff:	89 c3                	mov    %eax,%ebx
  801401:	83 c4 10             	add    $0x10,%esp
  801404:	85 c0                	test   %eax,%eax
  801406:	78 1b                	js     801423 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801408:	83 ec 08             	sub    $0x8,%esp
  80140b:	ff 75 0c             	pushl  0xc(%ebp)
  80140e:	50                   	push   %eax
  80140f:	e8 65 ff ff ff       	call   801379 <fstat>
  801414:	89 c6                	mov    %eax,%esi
	close(fd);
  801416:	89 1c 24             	mov    %ebx,(%esp)
  801419:	e8 27 fc ff ff       	call   801045 <close>
	return r;
  80141e:	83 c4 10             	add    $0x10,%esp
  801421:	89 f3                	mov    %esi,%ebx
}
  801423:	89 d8                	mov    %ebx,%eax
  801425:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801428:	5b                   	pop    %ebx
  801429:	5e                   	pop    %esi
  80142a:	5d                   	pop    %ebp
  80142b:	c3                   	ret    

0080142c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80142c:	55                   	push   %ebp
  80142d:	89 e5                	mov    %esp,%ebp
  80142f:	56                   	push   %esi
  801430:	53                   	push   %ebx
  801431:	89 c6                	mov    %eax,%esi
  801433:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801435:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80143c:	74 27                	je     801465 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80143e:	6a 07                	push   $0x7
  801440:	68 00 50 80 00       	push   $0x805000
  801445:	56                   	push   %esi
  801446:	ff 35 00 40 80 00    	pushl  0x804000
  80144c:	e8 79 07 00 00       	call   801bca <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801451:	83 c4 0c             	add    $0xc,%esp
  801454:	6a 00                	push   $0x0
  801456:	53                   	push   %ebx
  801457:	6a 00                	push   $0x0
  801459:	e8 f7 06 00 00       	call   801b55 <ipc_recv>
}
  80145e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801461:	5b                   	pop    %ebx
  801462:	5e                   	pop    %esi
  801463:	5d                   	pop    %ebp
  801464:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801465:	83 ec 0c             	sub    $0xc,%esp
  801468:	6a 01                	push   $0x1
  80146a:	e8 b1 07 00 00       	call   801c20 <ipc_find_env>
  80146f:	a3 00 40 80 00       	mov    %eax,0x804000
  801474:	83 c4 10             	add    $0x10,%esp
  801477:	eb c5                	jmp    80143e <fsipc+0x12>

00801479 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801479:	55                   	push   %ebp
  80147a:	89 e5                	mov    %esp,%ebp
  80147c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80147f:	8b 45 08             	mov    0x8(%ebp),%eax
  801482:	8b 40 0c             	mov    0xc(%eax),%eax
  801485:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80148a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80148d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801492:	ba 00 00 00 00       	mov    $0x0,%edx
  801497:	b8 02 00 00 00       	mov    $0x2,%eax
  80149c:	e8 8b ff ff ff       	call   80142c <fsipc>
}
  8014a1:	c9                   	leave  
  8014a2:	c3                   	ret    

008014a3 <devfile_flush>:
{
  8014a3:	55                   	push   %ebp
  8014a4:	89 e5                	mov    %esp,%ebp
  8014a6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ac:	8b 40 0c             	mov    0xc(%eax),%eax
  8014af:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b9:	b8 06 00 00 00       	mov    $0x6,%eax
  8014be:	e8 69 ff ff ff       	call   80142c <fsipc>
}
  8014c3:	c9                   	leave  
  8014c4:	c3                   	ret    

008014c5 <devfile_stat>:
{
  8014c5:	55                   	push   %ebp
  8014c6:	89 e5                	mov    %esp,%ebp
  8014c8:	53                   	push   %ebx
  8014c9:	83 ec 04             	sub    $0x4,%esp
  8014cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d2:	8b 40 0c             	mov    0xc(%eax),%eax
  8014d5:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014da:	ba 00 00 00 00       	mov    $0x0,%edx
  8014df:	b8 05 00 00 00       	mov    $0x5,%eax
  8014e4:	e8 43 ff ff ff       	call   80142c <fsipc>
  8014e9:	85 c0                	test   %eax,%eax
  8014eb:	78 2c                	js     801519 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014ed:	83 ec 08             	sub    $0x8,%esp
  8014f0:	68 00 50 80 00       	push   $0x805000
  8014f5:	53                   	push   %ebx
  8014f6:	e8 29 f3 ff ff       	call   800824 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014fb:	a1 80 50 80 00       	mov    0x805080,%eax
  801500:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801506:	a1 84 50 80 00       	mov    0x805084,%eax
  80150b:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801511:	83 c4 10             	add    $0x10,%esp
  801514:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801519:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80151c:	c9                   	leave  
  80151d:	c3                   	ret    

0080151e <devfile_write>:
{
  80151e:	55                   	push   %ebp
  80151f:	89 e5                	mov    %esp,%ebp
  801521:	83 ec 0c             	sub    $0xc,%esp
  801524:	8b 45 10             	mov    0x10(%ebp),%eax
  801527:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80152c:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801531:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801534:	8b 55 08             	mov    0x8(%ebp),%edx
  801537:	8b 52 0c             	mov    0xc(%edx),%edx
  80153a:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801540:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf,buf,n);
  801545:	50                   	push   %eax
  801546:	ff 75 0c             	pushl  0xc(%ebp)
  801549:	68 08 50 80 00       	push   $0x805008
  80154e:	e8 5f f4 ff ff       	call   8009b2 <memmove>
	if((r = fsipc(FSREQ_WRITE,NULL))<0)
  801553:	ba 00 00 00 00       	mov    $0x0,%edx
  801558:	b8 04 00 00 00       	mov    $0x4,%eax
  80155d:	e8 ca fe ff ff       	call   80142c <fsipc>
}
  801562:	c9                   	leave  
  801563:	c3                   	ret    

00801564 <devfile_read>:
{
  801564:	55                   	push   %ebp
  801565:	89 e5                	mov    %esp,%ebp
  801567:	56                   	push   %esi
  801568:	53                   	push   %ebx
  801569:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80156c:	8b 45 08             	mov    0x8(%ebp),%eax
  80156f:	8b 40 0c             	mov    0xc(%eax),%eax
  801572:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801577:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80157d:	ba 00 00 00 00       	mov    $0x0,%edx
  801582:	b8 03 00 00 00       	mov    $0x3,%eax
  801587:	e8 a0 fe ff ff       	call   80142c <fsipc>
  80158c:	89 c3                	mov    %eax,%ebx
  80158e:	85 c0                	test   %eax,%eax
  801590:	78 1f                	js     8015b1 <devfile_read+0x4d>
	assert(r <= n);
  801592:	39 f0                	cmp    %esi,%eax
  801594:	77 24                	ja     8015ba <devfile_read+0x56>
	assert(r <= PGSIZE);
  801596:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80159b:	7f 33                	jg     8015d0 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80159d:	83 ec 04             	sub    $0x4,%esp
  8015a0:	50                   	push   %eax
  8015a1:	68 00 50 80 00       	push   $0x805000
  8015a6:	ff 75 0c             	pushl  0xc(%ebp)
  8015a9:	e8 04 f4 ff ff       	call   8009b2 <memmove>
	return r;
  8015ae:	83 c4 10             	add    $0x10,%esp
}
  8015b1:	89 d8                	mov    %ebx,%eax
  8015b3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015b6:	5b                   	pop    %ebx
  8015b7:	5e                   	pop    %esi
  8015b8:	5d                   	pop    %ebp
  8015b9:	c3                   	ret    
	assert(r <= n);
  8015ba:	68 60 23 80 00       	push   $0x802360
  8015bf:	68 67 23 80 00       	push   $0x802367
  8015c4:	6a 7c                	push   $0x7c
  8015c6:	68 7c 23 80 00       	push   $0x80237c
  8015cb:	e8 5a eb ff ff       	call   80012a <_panic>
	assert(r <= PGSIZE);
  8015d0:	68 87 23 80 00       	push   $0x802387
  8015d5:	68 67 23 80 00       	push   $0x802367
  8015da:	6a 7d                	push   $0x7d
  8015dc:	68 7c 23 80 00       	push   $0x80237c
  8015e1:	e8 44 eb ff ff       	call   80012a <_panic>

008015e6 <open>:
{
  8015e6:	55                   	push   %ebp
  8015e7:	89 e5                	mov    %esp,%ebp
  8015e9:	56                   	push   %esi
  8015ea:	53                   	push   %ebx
  8015eb:	83 ec 1c             	sub    $0x1c,%esp
  8015ee:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8015f1:	56                   	push   %esi
  8015f2:	e8 f6 f1 ff ff       	call   8007ed <strlen>
  8015f7:	83 c4 10             	add    $0x10,%esp
  8015fa:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015ff:	7f 6c                	jg     80166d <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801601:	83 ec 0c             	sub    $0xc,%esp
  801604:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801607:	50                   	push   %eax
  801608:	e8 b4 f8 ff ff       	call   800ec1 <fd_alloc>
  80160d:	89 c3                	mov    %eax,%ebx
  80160f:	83 c4 10             	add    $0x10,%esp
  801612:	85 c0                	test   %eax,%eax
  801614:	78 3c                	js     801652 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801616:	83 ec 08             	sub    $0x8,%esp
  801619:	56                   	push   %esi
  80161a:	68 00 50 80 00       	push   $0x805000
  80161f:	e8 00 f2 ff ff       	call   800824 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801624:	8b 45 0c             	mov    0xc(%ebp),%eax
  801627:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80162c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80162f:	b8 01 00 00 00       	mov    $0x1,%eax
  801634:	e8 f3 fd ff ff       	call   80142c <fsipc>
  801639:	89 c3                	mov    %eax,%ebx
  80163b:	83 c4 10             	add    $0x10,%esp
  80163e:	85 c0                	test   %eax,%eax
  801640:	78 19                	js     80165b <open+0x75>
	return fd2num(fd);
  801642:	83 ec 0c             	sub    $0xc,%esp
  801645:	ff 75 f4             	pushl  -0xc(%ebp)
  801648:	e8 4d f8 ff ff       	call   800e9a <fd2num>
  80164d:	89 c3                	mov    %eax,%ebx
  80164f:	83 c4 10             	add    $0x10,%esp
}
  801652:	89 d8                	mov    %ebx,%eax
  801654:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801657:	5b                   	pop    %ebx
  801658:	5e                   	pop    %esi
  801659:	5d                   	pop    %ebp
  80165a:	c3                   	ret    
		fd_close(fd, 0);
  80165b:	83 ec 08             	sub    $0x8,%esp
  80165e:	6a 00                	push   $0x0
  801660:	ff 75 f4             	pushl  -0xc(%ebp)
  801663:	e8 54 f9 ff ff       	call   800fbc <fd_close>
		return r;
  801668:	83 c4 10             	add    $0x10,%esp
  80166b:	eb e5                	jmp    801652 <open+0x6c>
		return -E_BAD_PATH;
  80166d:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801672:	eb de                	jmp    801652 <open+0x6c>

00801674 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801674:	55                   	push   %ebp
  801675:	89 e5                	mov    %esp,%ebp
  801677:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80167a:	ba 00 00 00 00       	mov    $0x0,%edx
  80167f:	b8 08 00 00 00       	mov    $0x8,%eax
  801684:	e8 a3 fd ff ff       	call   80142c <fsipc>
}
  801689:	c9                   	leave  
  80168a:	c3                   	ret    

0080168b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80168b:	55                   	push   %ebp
  80168c:	89 e5                	mov    %esp,%ebp
  80168e:	56                   	push   %esi
  80168f:	53                   	push   %ebx
  801690:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801693:	83 ec 0c             	sub    $0xc,%esp
  801696:	ff 75 08             	pushl  0x8(%ebp)
  801699:	e8 0c f8 ff ff       	call   800eaa <fd2data>
  80169e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8016a0:	83 c4 08             	add    $0x8,%esp
  8016a3:	68 93 23 80 00       	push   $0x802393
  8016a8:	53                   	push   %ebx
  8016a9:	e8 76 f1 ff ff       	call   800824 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8016ae:	8b 46 04             	mov    0x4(%esi),%eax
  8016b1:	2b 06                	sub    (%esi),%eax
  8016b3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8016b9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016c0:	00 00 00 
	stat->st_dev = &devpipe;
  8016c3:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8016ca:	30 80 00 
	return 0;
}
  8016cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8016d2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016d5:	5b                   	pop    %ebx
  8016d6:	5e                   	pop    %esi
  8016d7:	5d                   	pop    %ebp
  8016d8:	c3                   	ret    

008016d9 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8016d9:	55                   	push   %ebp
  8016da:	89 e5                	mov    %esp,%ebp
  8016dc:	53                   	push   %ebx
  8016dd:	83 ec 0c             	sub    $0xc,%esp
  8016e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8016e3:	53                   	push   %ebx
  8016e4:	6a 00                	push   $0x0
  8016e6:	e8 b7 f5 ff ff       	call   800ca2 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8016eb:	89 1c 24             	mov    %ebx,(%esp)
  8016ee:	e8 b7 f7 ff ff       	call   800eaa <fd2data>
  8016f3:	83 c4 08             	add    $0x8,%esp
  8016f6:	50                   	push   %eax
  8016f7:	6a 00                	push   $0x0
  8016f9:	e8 a4 f5 ff ff       	call   800ca2 <sys_page_unmap>
}
  8016fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801701:	c9                   	leave  
  801702:	c3                   	ret    

00801703 <_pipeisclosed>:
{
  801703:	55                   	push   %ebp
  801704:	89 e5                	mov    %esp,%ebp
  801706:	57                   	push   %edi
  801707:	56                   	push   %esi
  801708:	53                   	push   %ebx
  801709:	83 ec 1c             	sub    $0x1c,%esp
  80170c:	89 c7                	mov    %eax,%edi
  80170e:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801710:	a1 04 40 80 00       	mov    0x804004,%eax
  801715:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801718:	83 ec 0c             	sub    $0xc,%esp
  80171b:	57                   	push   %edi
  80171c:	e8 38 05 00 00       	call   801c59 <pageref>
  801721:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801724:	89 34 24             	mov    %esi,(%esp)
  801727:	e8 2d 05 00 00       	call   801c59 <pageref>
		nn = thisenv->env_runs;
  80172c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801732:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801735:	83 c4 10             	add    $0x10,%esp
  801738:	39 cb                	cmp    %ecx,%ebx
  80173a:	74 1b                	je     801757 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  80173c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80173f:	75 cf                	jne    801710 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801741:	8b 42 58             	mov    0x58(%edx),%eax
  801744:	6a 01                	push   $0x1
  801746:	50                   	push   %eax
  801747:	53                   	push   %ebx
  801748:	68 9a 23 80 00       	push   $0x80239a
  80174d:	e8 b3 ea ff ff       	call   800205 <cprintf>
  801752:	83 c4 10             	add    $0x10,%esp
  801755:	eb b9                	jmp    801710 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801757:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80175a:	0f 94 c0             	sete   %al
  80175d:	0f b6 c0             	movzbl %al,%eax
}
  801760:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801763:	5b                   	pop    %ebx
  801764:	5e                   	pop    %esi
  801765:	5f                   	pop    %edi
  801766:	5d                   	pop    %ebp
  801767:	c3                   	ret    

00801768 <devpipe_write>:
{
  801768:	55                   	push   %ebp
  801769:	89 e5                	mov    %esp,%ebp
  80176b:	57                   	push   %edi
  80176c:	56                   	push   %esi
  80176d:	53                   	push   %ebx
  80176e:	83 ec 28             	sub    $0x28,%esp
  801771:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801774:	56                   	push   %esi
  801775:	e8 30 f7 ff ff       	call   800eaa <fd2data>
  80177a:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80177c:	83 c4 10             	add    $0x10,%esp
  80177f:	bf 00 00 00 00       	mov    $0x0,%edi
  801784:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801787:	74 4f                	je     8017d8 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801789:	8b 43 04             	mov    0x4(%ebx),%eax
  80178c:	8b 0b                	mov    (%ebx),%ecx
  80178e:	8d 51 20             	lea    0x20(%ecx),%edx
  801791:	39 d0                	cmp    %edx,%eax
  801793:	72 14                	jb     8017a9 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801795:	89 da                	mov    %ebx,%edx
  801797:	89 f0                	mov    %esi,%eax
  801799:	e8 65 ff ff ff       	call   801703 <_pipeisclosed>
  80179e:	85 c0                	test   %eax,%eax
  8017a0:	75 3a                	jne    8017dc <devpipe_write+0x74>
			sys_yield();
  8017a2:	e8 57 f4 ff ff       	call   800bfe <sys_yield>
  8017a7:	eb e0                	jmp    801789 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8017a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017ac:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8017b0:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8017b3:	89 c2                	mov    %eax,%edx
  8017b5:	c1 fa 1f             	sar    $0x1f,%edx
  8017b8:	89 d1                	mov    %edx,%ecx
  8017ba:	c1 e9 1b             	shr    $0x1b,%ecx
  8017bd:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8017c0:	83 e2 1f             	and    $0x1f,%edx
  8017c3:	29 ca                	sub    %ecx,%edx
  8017c5:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8017c9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8017cd:	83 c0 01             	add    $0x1,%eax
  8017d0:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  8017d3:	83 c7 01             	add    $0x1,%edi
  8017d6:	eb ac                	jmp    801784 <devpipe_write+0x1c>
	return i;
  8017d8:	89 f8                	mov    %edi,%eax
  8017da:	eb 05                	jmp    8017e1 <devpipe_write+0x79>
				return 0;
  8017dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017e4:	5b                   	pop    %ebx
  8017e5:	5e                   	pop    %esi
  8017e6:	5f                   	pop    %edi
  8017e7:	5d                   	pop    %ebp
  8017e8:	c3                   	ret    

008017e9 <devpipe_read>:
{
  8017e9:	55                   	push   %ebp
  8017ea:	89 e5                	mov    %esp,%ebp
  8017ec:	57                   	push   %edi
  8017ed:	56                   	push   %esi
  8017ee:	53                   	push   %ebx
  8017ef:	83 ec 18             	sub    $0x18,%esp
  8017f2:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8017f5:	57                   	push   %edi
  8017f6:	e8 af f6 ff ff       	call   800eaa <fd2data>
  8017fb:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8017fd:	83 c4 10             	add    $0x10,%esp
  801800:	be 00 00 00 00       	mov    $0x0,%esi
  801805:	3b 75 10             	cmp    0x10(%ebp),%esi
  801808:	74 47                	je     801851 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  80180a:	8b 03                	mov    (%ebx),%eax
  80180c:	3b 43 04             	cmp    0x4(%ebx),%eax
  80180f:	75 22                	jne    801833 <devpipe_read+0x4a>
			if (i > 0)
  801811:	85 f6                	test   %esi,%esi
  801813:	75 14                	jne    801829 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801815:	89 da                	mov    %ebx,%edx
  801817:	89 f8                	mov    %edi,%eax
  801819:	e8 e5 fe ff ff       	call   801703 <_pipeisclosed>
  80181e:	85 c0                	test   %eax,%eax
  801820:	75 33                	jne    801855 <devpipe_read+0x6c>
			sys_yield();
  801822:	e8 d7 f3 ff ff       	call   800bfe <sys_yield>
  801827:	eb e1                	jmp    80180a <devpipe_read+0x21>
				return i;
  801829:	89 f0                	mov    %esi,%eax
}
  80182b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80182e:	5b                   	pop    %ebx
  80182f:	5e                   	pop    %esi
  801830:	5f                   	pop    %edi
  801831:	5d                   	pop    %ebp
  801832:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801833:	99                   	cltd   
  801834:	c1 ea 1b             	shr    $0x1b,%edx
  801837:	01 d0                	add    %edx,%eax
  801839:	83 e0 1f             	and    $0x1f,%eax
  80183c:	29 d0                	sub    %edx,%eax
  80183e:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801843:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801846:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801849:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  80184c:	83 c6 01             	add    $0x1,%esi
  80184f:	eb b4                	jmp    801805 <devpipe_read+0x1c>
	return i;
  801851:	89 f0                	mov    %esi,%eax
  801853:	eb d6                	jmp    80182b <devpipe_read+0x42>
				return 0;
  801855:	b8 00 00 00 00       	mov    $0x0,%eax
  80185a:	eb cf                	jmp    80182b <devpipe_read+0x42>

0080185c <pipe>:
{
  80185c:	55                   	push   %ebp
  80185d:	89 e5                	mov    %esp,%ebp
  80185f:	56                   	push   %esi
  801860:	53                   	push   %ebx
  801861:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801864:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801867:	50                   	push   %eax
  801868:	e8 54 f6 ff ff       	call   800ec1 <fd_alloc>
  80186d:	89 c3                	mov    %eax,%ebx
  80186f:	83 c4 10             	add    $0x10,%esp
  801872:	85 c0                	test   %eax,%eax
  801874:	78 5b                	js     8018d1 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801876:	83 ec 04             	sub    $0x4,%esp
  801879:	68 07 04 00 00       	push   $0x407
  80187e:	ff 75 f4             	pushl  -0xc(%ebp)
  801881:	6a 00                	push   $0x0
  801883:	e8 95 f3 ff ff       	call   800c1d <sys_page_alloc>
  801888:	89 c3                	mov    %eax,%ebx
  80188a:	83 c4 10             	add    $0x10,%esp
  80188d:	85 c0                	test   %eax,%eax
  80188f:	78 40                	js     8018d1 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  801891:	83 ec 0c             	sub    $0xc,%esp
  801894:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801897:	50                   	push   %eax
  801898:	e8 24 f6 ff ff       	call   800ec1 <fd_alloc>
  80189d:	89 c3                	mov    %eax,%ebx
  80189f:	83 c4 10             	add    $0x10,%esp
  8018a2:	85 c0                	test   %eax,%eax
  8018a4:	78 1b                	js     8018c1 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018a6:	83 ec 04             	sub    $0x4,%esp
  8018a9:	68 07 04 00 00       	push   $0x407
  8018ae:	ff 75 f0             	pushl  -0x10(%ebp)
  8018b1:	6a 00                	push   $0x0
  8018b3:	e8 65 f3 ff ff       	call   800c1d <sys_page_alloc>
  8018b8:	89 c3                	mov    %eax,%ebx
  8018ba:	83 c4 10             	add    $0x10,%esp
  8018bd:	85 c0                	test   %eax,%eax
  8018bf:	79 19                	jns    8018da <pipe+0x7e>
	sys_page_unmap(0, fd0);
  8018c1:	83 ec 08             	sub    $0x8,%esp
  8018c4:	ff 75 f4             	pushl  -0xc(%ebp)
  8018c7:	6a 00                	push   $0x0
  8018c9:	e8 d4 f3 ff ff       	call   800ca2 <sys_page_unmap>
  8018ce:	83 c4 10             	add    $0x10,%esp
}
  8018d1:	89 d8                	mov    %ebx,%eax
  8018d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018d6:	5b                   	pop    %ebx
  8018d7:	5e                   	pop    %esi
  8018d8:	5d                   	pop    %ebp
  8018d9:	c3                   	ret    
	va = fd2data(fd0);
  8018da:	83 ec 0c             	sub    $0xc,%esp
  8018dd:	ff 75 f4             	pushl  -0xc(%ebp)
  8018e0:	e8 c5 f5 ff ff       	call   800eaa <fd2data>
  8018e5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018e7:	83 c4 0c             	add    $0xc,%esp
  8018ea:	68 07 04 00 00       	push   $0x407
  8018ef:	50                   	push   %eax
  8018f0:	6a 00                	push   $0x0
  8018f2:	e8 26 f3 ff ff       	call   800c1d <sys_page_alloc>
  8018f7:	89 c3                	mov    %eax,%ebx
  8018f9:	83 c4 10             	add    $0x10,%esp
  8018fc:	85 c0                	test   %eax,%eax
  8018fe:	0f 88 8c 00 00 00    	js     801990 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801904:	83 ec 0c             	sub    $0xc,%esp
  801907:	ff 75 f0             	pushl  -0x10(%ebp)
  80190a:	e8 9b f5 ff ff       	call   800eaa <fd2data>
  80190f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801916:	50                   	push   %eax
  801917:	6a 00                	push   $0x0
  801919:	56                   	push   %esi
  80191a:	6a 00                	push   $0x0
  80191c:	e8 3f f3 ff ff       	call   800c60 <sys_page_map>
  801921:	89 c3                	mov    %eax,%ebx
  801923:	83 c4 20             	add    $0x20,%esp
  801926:	85 c0                	test   %eax,%eax
  801928:	78 58                	js     801982 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  80192a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80192d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801933:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801935:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801938:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  80193f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801942:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801948:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80194a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80194d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801954:	83 ec 0c             	sub    $0xc,%esp
  801957:	ff 75 f4             	pushl  -0xc(%ebp)
  80195a:	e8 3b f5 ff ff       	call   800e9a <fd2num>
  80195f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801962:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801964:	83 c4 04             	add    $0x4,%esp
  801967:	ff 75 f0             	pushl  -0x10(%ebp)
  80196a:	e8 2b f5 ff ff       	call   800e9a <fd2num>
  80196f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801972:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801975:	83 c4 10             	add    $0x10,%esp
  801978:	bb 00 00 00 00       	mov    $0x0,%ebx
  80197d:	e9 4f ff ff ff       	jmp    8018d1 <pipe+0x75>
	sys_page_unmap(0, va);
  801982:	83 ec 08             	sub    $0x8,%esp
  801985:	56                   	push   %esi
  801986:	6a 00                	push   $0x0
  801988:	e8 15 f3 ff ff       	call   800ca2 <sys_page_unmap>
  80198d:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801990:	83 ec 08             	sub    $0x8,%esp
  801993:	ff 75 f0             	pushl  -0x10(%ebp)
  801996:	6a 00                	push   $0x0
  801998:	e8 05 f3 ff ff       	call   800ca2 <sys_page_unmap>
  80199d:	83 c4 10             	add    $0x10,%esp
  8019a0:	e9 1c ff ff ff       	jmp    8018c1 <pipe+0x65>

008019a5 <pipeisclosed>:
{
  8019a5:	55                   	push   %ebp
  8019a6:	89 e5                	mov    %esp,%ebp
  8019a8:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019ae:	50                   	push   %eax
  8019af:	ff 75 08             	pushl  0x8(%ebp)
  8019b2:	e8 59 f5 ff ff       	call   800f10 <fd_lookup>
  8019b7:	83 c4 10             	add    $0x10,%esp
  8019ba:	85 c0                	test   %eax,%eax
  8019bc:	78 18                	js     8019d6 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  8019be:	83 ec 0c             	sub    $0xc,%esp
  8019c1:	ff 75 f4             	pushl  -0xc(%ebp)
  8019c4:	e8 e1 f4 ff ff       	call   800eaa <fd2data>
	return _pipeisclosed(fd, p);
  8019c9:	89 c2                	mov    %eax,%edx
  8019cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ce:	e8 30 fd ff ff       	call   801703 <_pipeisclosed>
  8019d3:	83 c4 10             	add    $0x10,%esp
}
  8019d6:	c9                   	leave  
  8019d7:	c3                   	ret    

008019d8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8019d8:	55                   	push   %ebp
  8019d9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8019db:	b8 00 00 00 00       	mov    $0x0,%eax
  8019e0:	5d                   	pop    %ebp
  8019e1:	c3                   	ret    

008019e2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8019e2:	55                   	push   %ebp
  8019e3:	89 e5                	mov    %esp,%ebp
  8019e5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8019e8:	68 b2 23 80 00       	push   $0x8023b2
  8019ed:	ff 75 0c             	pushl  0xc(%ebp)
  8019f0:	e8 2f ee ff ff       	call   800824 <strcpy>
	return 0;
}
  8019f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8019fa:	c9                   	leave  
  8019fb:	c3                   	ret    

008019fc <devcons_write>:
{
  8019fc:	55                   	push   %ebp
  8019fd:	89 e5                	mov    %esp,%ebp
  8019ff:	57                   	push   %edi
  801a00:	56                   	push   %esi
  801a01:	53                   	push   %ebx
  801a02:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801a08:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801a0d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801a13:	eb 2f                	jmp    801a44 <devcons_write+0x48>
		m = n - tot;
  801a15:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a18:	29 f3                	sub    %esi,%ebx
  801a1a:	83 fb 7f             	cmp    $0x7f,%ebx
  801a1d:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801a22:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801a25:	83 ec 04             	sub    $0x4,%esp
  801a28:	53                   	push   %ebx
  801a29:	89 f0                	mov    %esi,%eax
  801a2b:	03 45 0c             	add    0xc(%ebp),%eax
  801a2e:	50                   	push   %eax
  801a2f:	57                   	push   %edi
  801a30:	e8 7d ef ff ff       	call   8009b2 <memmove>
		sys_cputs(buf, m);
  801a35:	83 c4 08             	add    $0x8,%esp
  801a38:	53                   	push   %ebx
  801a39:	57                   	push   %edi
  801a3a:	e8 22 f1 ff ff       	call   800b61 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801a3f:	01 de                	add    %ebx,%esi
  801a41:	83 c4 10             	add    $0x10,%esp
  801a44:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a47:	72 cc                	jb     801a15 <devcons_write+0x19>
}
  801a49:	89 f0                	mov    %esi,%eax
  801a4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a4e:	5b                   	pop    %ebx
  801a4f:	5e                   	pop    %esi
  801a50:	5f                   	pop    %edi
  801a51:	5d                   	pop    %ebp
  801a52:	c3                   	ret    

00801a53 <devcons_read>:
{
  801a53:	55                   	push   %ebp
  801a54:	89 e5                	mov    %esp,%ebp
  801a56:	83 ec 08             	sub    $0x8,%esp
  801a59:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801a5e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a62:	75 07                	jne    801a6b <devcons_read+0x18>
}
  801a64:	c9                   	leave  
  801a65:	c3                   	ret    
		sys_yield();
  801a66:	e8 93 f1 ff ff       	call   800bfe <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801a6b:	e8 0f f1 ff ff       	call   800b7f <sys_cgetc>
  801a70:	85 c0                	test   %eax,%eax
  801a72:	74 f2                	je     801a66 <devcons_read+0x13>
	if (c < 0)
  801a74:	85 c0                	test   %eax,%eax
  801a76:	78 ec                	js     801a64 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  801a78:	83 f8 04             	cmp    $0x4,%eax
  801a7b:	74 0c                	je     801a89 <devcons_read+0x36>
	*(char*)vbuf = c;
  801a7d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a80:	88 02                	mov    %al,(%edx)
	return 1;
  801a82:	b8 01 00 00 00       	mov    $0x1,%eax
  801a87:	eb db                	jmp    801a64 <devcons_read+0x11>
		return 0;
  801a89:	b8 00 00 00 00       	mov    $0x0,%eax
  801a8e:	eb d4                	jmp    801a64 <devcons_read+0x11>

00801a90 <cputchar>:
{
  801a90:	55                   	push   %ebp
  801a91:	89 e5                	mov    %esp,%ebp
  801a93:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a96:	8b 45 08             	mov    0x8(%ebp),%eax
  801a99:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801a9c:	6a 01                	push   $0x1
  801a9e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801aa1:	50                   	push   %eax
  801aa2:	e8 ba f0 ff ff       	call   800b61 <sys_cputs>
}
  801aa7:	83 c4 10             	add    $0x10,%esp
  801aaa:	c9                   	leave  
  801aab:	c3                   	ret    

00801aac <getchar>:
{
  801aac:	55                   	push   %ebp
  801aad:	89 e5                	mov    %esp,%ebp
  801aaf:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801ab2:	6a 01                	push   $0x1
  801ab4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ab7:	50                   	push   %eax
  801ab8:	6a 00                	push   $0x0
  801aba:	e8 c2 f6 ff ff       	call   801181 <read>
	if (r < 0)
  801abf:	83 c4 10             	add    $0x10,%esp
  801ac2:	85 c0                	test   %eax,%eax
  801ac4:	78 08                	js     801ace <getchar+0x22>
	if (r < 1)
  801ac6:	85 c0                	test   %eax,%eax
  801ac8:	7e 06                	jle    801ad0 <getchar+0x24>
	return c;
  801aca:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801ace:	c9                   	leave  
  801acf:	c3                   	ret    
		return -E_EOF;
  801ad0:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801ad5:	eb f7                	jmp    801ace <getchar+0x22>

00801ad7 <iscons>:
{
  801ad7:	55                   	push   %ebp
  801ad8:	89 e5                	mov    %esp,%ebp
  801ada:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801add:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ae0:	50                   	push   %eax
  801ae1:	ff 75 08             	pushl  0x8(%ebp)
  801ae4:	e8 27 f4 ff ff       	call   800f10 <fd_lookup>
  801ae9:	83 c4 10             	add    $0x10,%esp
  801aec:	85 c0                	test   %eax,%eax
  801aee:	78 11                	js     801b01 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801af0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801af9:	39 10                	cmp    %edx,(%eax)
  801afb:	0f 94 c0             	sete   %al
  801afe:	0f b6 c0             	movzbl %al,%eax
}
  801b01:	c9                   	leave  
  801b02:	c3                   	ret    

00801b03 <opencons>:
{
  801b03:	55                   	push   %ebp
  801b04:	89 e5                	mov    %esp,%ebp
  801b06:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801b09:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b0c:	50                   	push   %eax
  801b0d:	e8 af f3 ff ff       	call   800ec1 <fd_alloc>
  801b12:	83 c4 10             	add    $0x10,%esp
  801b15:	85 c0                	test   %eax,%eax
  801b17:	78 3a                	js     801b53 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b19:	83 ec 04             	sub    $0x4,%esp
  801b1c:	68 07 04 00 00       	push   $0x407
  801b21:	ff 75 f4             	pushl  -0xc(%ebp)
  801b24:	6a 00                	push   $0x0
  801b26:	e8 f2 f0 ff ff       	call   800c1d <sys_page_alloc>
  801b2b:	83 c4 10             	add    $0x10,%esp
  801b2e:	85 c0                	test   %eax,%eax
  801b30:	78 21                	js     801b53 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801b32:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b35:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b3b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b40:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b47:	83 ec 0c             	sub    $0xc,%esp
  801b4a:	50                   	push   %eax
  801b4b:	e8 4a f3 ff ff       	call   800e9a <fd2num>
  801b50:	83 c4 10             	add    $0x10,%esp
}
  801b53:	c9                   	leave  
  801b54:	c3                   	ret    

00801b55 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b55:	55                   	push   %ebp
  801b56:	89 e5                	mov    %esp,%ebp
  801b58:	56                   	push   %esi
  801b59:	53                   	push   %ebx
  801b5a:	8b 75 08             	mov    0x8(%ebp),%esi
  801b5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b60:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        //	panic("ipc_recv not implemented");
        int r;
       	if(pg!=NULL){
  801b63:	85 c0                	test   %eax,%eax
  801b65:	74 3b                	je     801ba2 <ipc_recv+0x4d>
	  r = sys_ipc_recv(pg);
  801b67:	83 ec 0c             	sub    $0xc,%esp
  801b6a:	50                   	push   %eax
  801b6b:	e8 5d f2 ff ff       	call   800dcd <sys_ipc_recv>
  801b70:	83 c4 10             	add    $0x10,%esp
	}else
	  r = sys_ipc_recv((void *)UTOP);
	if(r<0){
  801b73:	85 c0                	test   %eax,%eax
  801b75:	78 3d                	js     801bb4 <ipc_recv+0x5f>
	if(perm_store!=NULL){
		*perm_store = 0;
            }
        	return r;
           }else{
	     if(from_env_store!=NULL)
  801b77:	85 f6                	test   %esi,%esi
  801b79:	74 0a                	je     801b85 <ipc_recv+0x30>
		     *from_env_store = thisenv->env_ipc_from;
  801b7b:	a1 04 40 80 00       	mov    0x804004,%eax
  801b80:	8b 40 74             	mov    0x74(%eax),%eax
  801b83:	89 06                	mov    %eax,(%esi)
	     if(perm_store != NULL)
  801b85:	85 db                	test   %ebx,%ebx
  801b87:	74 0a                	je     801b93 <ipc_recv+0x3e>
		     *perm_store = thisenv->env_ipc_perm;
  801b89:	a1 04 40 80 00       	mov    0x804004,%eax
  801b8e:	8b 40 78             	mov    0x78(%eax),%eax
  801b91:	89 03                	mov    %eax,(%ebx)
	     return thisenv->env_ipc_value;
  801b93:	a1 04 40 80 00       	mov    0x804004,%eax
  801b98:	8b 40 70             	mov    0x70(%eax),%eax
	   }

}
  801b9b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b9e:	5b                   	pop    %ebx
  801b9f:	5e                   	pop    %esi
  801ba0:	5d                   	pop    %ebp
  801ba1:	c3                   	ret    
	  r = sys_ipc_recv((void *)UTOP);
  801ba2:	83 ec 0c             	sub    $0xc,%esp
  801ba5:	68 00 00 c0 ee       	push   $0xeec00000
  801baa:	e8 1e f2 ff ff       	call   800dcd <sys_ipc_recv>
  801baf:	83 c4 10             	add    $0x10,%esp
  801bb2:	eb bf                	jmp    801b73 <ipc_recv+0x1e>
	if(from_env_store!=NULL){
  801bb4:	85 f6                	test   %esi,%esi
  801bb6:	74 06                	je     801bbe <ipc_recv+0x69>
	  *from_env_store = 0;
  801bb8:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if(perm_store!=NULL){
  801bbe:	85 db                	test   %ebx,%ebx
  801bc0:	74 d9                	je     801b9b <ipc_recv+0x46>
		*perm_store = 0;
  801bc2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801bc8:	eb d1                	jmp    801b9b <ipc_recv+0x46>

00801bca <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bca:	55                   	push   %ebp
  801bcb:	89 e5                	mov    %esp,%ebp
  801bcd:	57                   	push   %edi
  801bce:	56                   	push   %esi
  801bcf:	53                   	push   %ebx
  801bd0:	83 ec 0c             	sub    $0xc,%esp
  801bd3:	8b 7d 08             	mov    0x8(%ebp),%edi
  801bd6:	8b 75 0c             	mov    0xc(%ebp),%esi
  801bd9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if(pg==NULL) pg = (void *)UTOP;
  801bdc:	85 db                	test   %ebx,%ebx
  801bde:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801be3:	0f 44 d8             	cmove  %eax,%ebx
	while((r=sys_ipc_try_send(to_env,val,pg,perm))<0){
  801be6:	ff 75 14             	pushl  0x14(%ebp)
  801be9:	53                   	push   %ebx
  801bea:	56                   	push   %esi
  801beb:	57                   	push   %edi
  801bec:	e8 b9 f1 ff ff       	call   800daa <sys_ipc_try_send>
  801bf1:	83 c4 10             	add    $0x10,%esp
  801bf4:	85 c0                	test   %eax,%eax
  801bf6:	79 20                	jns    801c18 <ipc_send+0x4e>
	    if(r!=-E_IPC_NOT_RECV){
  801bf8:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801bfb:	75 07                	jne    801c04 <ipc_send+0x3a>
		    panic("ipc_send:send message failed\n");
	    }
	    sys_yield();
  801bfd:	e8 fc ef ff ff       	call   800bfe <sys_yield>
  801c02:	eb e2                	jmp    801be6 <ipc_send+0x1c>
		    panic("ipc_send:send message failed\n");
  801c04:	83 ec 04             	sub    $0x4,%esp
  801c07:	68 be 23 80 00       	push   $0x8023be
  801c0c:	6a 43                	push   $0x43
  801c0e:	68 dc 23 80 00       	push   $0x8023dc
  801c13:	e8 12 e5 ff ff       	call   80012a <_panic>
	}

}
  801c18:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c1b:	5b                   	pop    %ebx
  801c1c:	5e                   	pop    %esi
  801c1d:	5f                   	pop    %edi
  801c1e:	5d                   	pop    %ebp
  801c1f:	c3                   	ret    

00801c20 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c20:	55                   	push   %ebp
  801c21:	89 e5                	mov    %esp,%ebp
  801c23:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c26:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c2b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c2e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c34:	8b 52 50             	mov    0x50(%edx),%edx
  801c37:	39 ca                	cmp    %ecx,%edx
  801c39:	74 11                	je     801c4c <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801c3b:	83 c0 01             	add    $0x1,%eax
  801c3e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c43:	75 e6                	jne    801c2b <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801c45:	b8 00 00 00 00       	mov    $0x0,%eax
  801c4a:	eb 0b                	jmp    801c57 <ipc_find_env+0x37>
			return envs[i].env_id;
  801c4c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c4f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c54:	8b 40 48             	mov    0x48(%eax),%eax
}
  801c57:	5d                   	pop    %ebp
  801c58:	c3                   	ret    

00801c59 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c59:	55                   	push   %ebp
  801c5a:	89 e5                	mov    %esp,%ebp
  801c5c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c5f:	89 d0                	mov    %edx,%eax
  801c61:	c1 e8 16             	shr    $0x16,%eax
  801c64:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c6b:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801c70:	f6 c1 01             	test   $0x1,%cl
  801c73:	74 1d                	je     801c92 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801c75:	c1 ea 0c             	shr    $0xc,%edx
  801c78:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c7f:	f6 c2 01             	test   $0x1,%dl
  801c82:	74 0e                	je     801c92 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c84:	c1 ea 0c             	shr    $0xc,%edx
  801c87:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c8e:	ef 
  801c8f:	0f b7 c0             	movzwl %ax,%eax
}
  801c92:	5d                   	pop    %ebp
  801c93:	c3                   	ret    
  801c94:	66 90                	xchg   %ax,%ax
  801c96:	66 90                	xchg   %ax,%ax
  801c98:	66 90                	xchg   %ax,%ax
  801c9a:	66 90                	xchg   %ax,%ax
  801c9c:	66 90                	xchg   %ax,%ax
  801c9e:	66 90                	xchg   %ax,%ax

00801ca0 <__udivdi3>:
  801ca0:	55                   	push   %ebp
  801ca1:	57                   	push   %edi
  801ca2:	56                   	push   %esi
  801ca3:	53                   	push   %ebx
  801ca4:	83 ec 1c             	sub    $0x1c,%esp
  801ca7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801cab:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801caf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801cb3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801cb7:	85 d2                	test   %edx,%edx
  801cb9:	75 35                	jne    801cf0 <__udivdi3+0x50>
  801cbb:	39 f3                	cmp    %esi,%ebx
  801cbd:	0f 87 bd 00 00 00    	ja     801d80 <__udivdi3+0xe0>
  801cc3:	85 db                	test   %ebx,%ebx
  801cc5:	89 d9                	mov    %ebx,%ecx
  801cc7:	75 0b                	jne    801cd4 <__udivdi3+0x34>
  801cc9:	b8 01 00 00 00       	mov    $0x1,%eax
  801cce:	31 d2                	xor    %edx,%edx
  801cd0:	f7 f3                	div    %ebx
  801cd2:	89 c1                	mov    %eax,%ecx
  801cd4:	31 d2                	xor    %edx,%edx
  801cd6:	89 f0                	mov    %esi,%eax
  801cd8:	f7 f1                	div    %ecx
  801cda:	89 c6                	mov    %eax,%esi
  801cdc:	89 e8                	mov    %ebp,%eax
  801cde:	89 f7                	mov    %esi,%edi
  801ce0:	f7 f1                	div    %ecx
  801ce2:	89 fa                	mov    %edi,%edx
  801ce4:	83 c4 1c             	add    $0x1c,%esp
  801ce7:	5b                   	pop    %ebx
  801ce8:	5e                   	pop    %esi
  801ce9:	5f                   	pop    %edi
  801cea:	5d                   	pop    %ebp
  801ceb:	c3                   	ret    
  801cec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cf0:	39 f2                	cmp    %esi,%edx
  801cf2:	77 7c                	ja     801d70 <__udivdi3+0xd0>
  801cf4:	0f bd fa             	bsr    %edx,%edi
  801cf7:	83 f7 1f             	xor    $0x1f,%edi
  801cfa:	0f 84 98 00 00 00    	je     801d98 <__udivdi3+0xf8>
  801d00:	89 f9                	mov    %edi,%ecx
  801d02:	b8 20 00 00 00       	mov    $0x20,%eax
  801d07:	29 f8                	sub    %edi,%eax
  801d09:	d3 e2                	shl    %cl,%edx
  801d0b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d0f:	89 c1                	mov    %eax,%ecx
  801d11:	89 da                	mov    %ebx,%edx
  801d13:	d3 ea                	shr    %cl,%edx
  801d15:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801d19:	09 d1                	or     %edx,%ecx
  801d1b:	89 f2                	mov    %esi,%edx
  801d1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d21:	89 f9                	mov    %edi,%ecx
  801d23:	d3 e3                	shl    %cl,%ebx
  801d25:	89 c1                	mov    %eax,%ecx
  801d27:	d3 ea                	shr    %cl,%edx
  801d29:	89 f9                	mov    %edi,%ecx
  801d2b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801d2f:	d3 e6                	shl    %cl,%esi
  801d31:	89 eb                	mov    %ebp,%ebx
  801d33:	89 c1                	mov    %eax,%ecx
  801d35:	d3 eb                	shr    %cl,%ebx
  801d37:	09 de                	or     %ebx,%esi
  801d39:	89 f0                	mov    %esi,%eax
  801d3b:	f7 74 24 08          	divl   0x8(%esp)
  801d3f:	89 d6                	mov    %edx,%esi
  801d41:	89 c3                	mov    %eax,%ebx
  801d43:	f7 64 24 0c          	mull   0xc(%esp)
  801d47:	39 d6                	cmp    %edx,%esi
  801d49:	72 0c                	jb     801d57 <__udivdi3+0xb7>
  801d4b:	89 f9                	mov    %edi,%ecx
  801d4d:	d3 e5                	shl    %cl,%ebp
  801d4f:	39 c5                	cmp    %eax,%ebp
  801d51:	73 5d                	jae    801db0 <__udivdi3+0x110>
  801d53:	39 d6                	cmp    %edx,%esi
  801d55:	75 59                	jne    801db0 <__udivdi3+0x110>
  801d57:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801d5a:	31 ff                	xor    %edi,%edi
  801d5c:	89 fa                	mov    %edi,%edx
  801d5e:	83 c4 1c             	add    $0x1c,%esp
  801d61:	5b                   	pop    %ebx
  801d62:	5e                   	pop    %esi
  801d63:	5f                   	pop    %edi
  801d64:	5d                   	pop    %ebp
  801d65:	c3                   	ret    
  801d66:	8d 76 00             	lea    0x0(%esi),%esi
  801d69:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801d70:	31 ff                	xor    %edi,%edi
  801d72:	31 c0                	xor    %eax,%eax
  801d74:	89 fa                	mov    %edi,%edx
  801d76:	83 c4 1c             	add    $0x1c,%esp
  801d79:	5b                   	pop    %ebx
  801d7a:	5e                   	pop    %esi
  801d7b:	5f                   	pop    %edi
  801d7c:	5d                   	pop    %ebp
  801d7d:	c3                   	ret    
  801d7e:	66 90                	xchg   %ax,%ax
  801d80:	31 ff                	xor    %edi,%edi
  801d82:	89 e8                	mov    %ebp,%eax
  801d84:	89 f2                	mov    %esi,%edx
  801d86:	f7 f3                	div    %ebx
  801d88:	89 fa                	mov    %edi,%edx
  801d8a:	83 c4 1c             	add    $0x1c,%esp
  801d8d:	5b                   	pop    %ebx
  801d8e:	5e                   	pop    %esi
  801d8f:	5f                   	pop    %edi
  801d90:	5d                   	pop    %ebp
  801d91:	c3                   	ret    
  801d92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d98:	39 f2                	cmp    %esi,%edx
  801d9a:	72 06                	jb     801da2 <__udivdi3+0x102>
  801d9c:	31 c0                	xor    %eax,%eax
  801d9e:	39 eb                	cmp    %ebp,%ebx
  801da0:	77 d2                	ja     801d74 <__udivdi3+0xd4>
  801da2:	b8 01 00 00 00       	mov    $0x1,%eax
  801da7:	eb cb                	jmp    801d74 <__udivdi3+0xd4>
  801da9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801db0:	89 d8                	mov    %ebx,%eax
  801db2:	31 ff                	xor    %edi,%edi
  801db4:	eb be                	jmp    801d74 <__udivdi3+0xd4>
  801db6:	66 90                	xchg   %ax,%ax
  801db8:	66 90                	xchg   %ax,%ax
  801dba:	66 90                	xchg   %ax,%ax
  801dbc:	66 90                	xchg   %ax,%ax
  801dbe:	66 90                	xchg   %ax,%ax

00801dc0 <__umoddi3>:
  801dc0:	55                   	push   %ebp
  801dc1:	57                   	push   %edi
  801dc2:	56                   	push   %esi
  801dc3:	53                   	push   %ebx
  801dc4:	83 ec 1c             	sub    $0x1c,%esp
  801dc7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801dcb:	8b 74 24 30          	mov    0x30(%esp),%esi
  801dcf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801dd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801dd7:	85 ed                	test   %ebp,%ebp
  801dd9:	89 f0                	mov    %esi,%eax
  801ddb:	89 da                	mov    %ebx,%edx
  801ddd:	75 19                	jne    801df8 <__umoddi3+0x38>
  801ddf:	39 df                	cmp    %ebx,%edi
  801de1:	0f 86 b1 00 00 00    	jbe    801e98 <__umoddi3+0xd8>
  801de7:	f7 f7                	div    %edi
  801de9:	89 d0                	mov    %edx,%eax
  801deb:	31 d2                	xor    %edx,%edx
  801ded:	83 c4 1c             	add    $0x1c,%esp
  801df0:	5b                   	pop    %ebx
  801df1:	5e                   	pop    %esi
  801df2:	5f                   	pop    %edi
  801df3:	5d                   	pop    %ebp
  801df4:	c3                   	ret    
  801df5:	8d 76 00             	lea    0x0(%esi),%esi
  801df8:	39 dd                	cmp    %ebx,%ebp
  801dfa:	77 f1                	ja     801ded <__umoddi3+0x2d>
  801dfc:	0f bd cd             	bsr    %ebp,%ecx
  801dff:	83 f1 1f             	xor    $0x1f,%ecx
  801e02:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801e06:	0f 84 b4 00 00 00    	je     801ec0 <__umoddi3+0x100>
  801e0c:	b8 20 00 00 00       	mov    $0x20,%eax
  801e11:	89 c2                	mov    %eax,%edx
  801e13:	8b 44 24 04          	mov    0x4(%esp),%eax
  801e17:	29 c2                	sub    %eax,%edx
  801e19:	89 c1                	mov    %eax,%ecx
  801e1b:	89 f8                	mov    %edi,%eax
  801e1d:	d3 e5                	shl    %cl,%ebp
  801e1f:	89 d1                	mov    %edx,%ecx
  801e21:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801e25:	d3 e8                	shr    %cl,%eax
  801e27:	09 c5                	or     %eax,%ebp
  801e29:	8b 44 24 04          	mov    0x4(%esp),%eax
  801e2d:	89 c1                	mov    %eax,%ecx
  801e2f:	d3 e7                	shl    %cl,%edi
  801e31:	89 d1                	mov    %edx,%ecx
  801e33:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801e37:	89 df                	mov    %ebx,%edi
  801e39:	d3 ef                	shr    %cl,%edi
  801e3b:	89 c1                	mov    %eax,%ecx
  801e3d:	89 f0                	mov    %esi,%eax
  801e3f:	d3 e3                	shl    %cl,%ebx
  801e41:	89 d1                	mov    %edx,%ecx
  801e43:	89 fa                	mov    %edi,%edx
  801e45:	d3 e8                	shr    %cl,%eax
  801e47:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801e4c:	09 d8                	or     %ebx,%eax
  801e4e:	f7 f5                	div    %ebp
  801e50:	d3 e6                	shl    %cl,%esi
  801e52:	89 d1                	mov    %edx,%ecx
  801e54:	f7 64 24 08          	mull   0x8(%esp)
  801e58:	39 d1                	cmp    %edx,%ecx
  801e5a:	89 c3                	mov    %eax,%ebx
  801e5c:	89 d7                	mov    %edx,%edi
  801e5e:	72 06                	jb     801e66 <__umoddi3+0xa6>
  801e60:	75 0e                	jne    801e70 <__umoddi3+0xb0>
  801e62:	39 c6                	cmp    %eax,%esi
  801e64:	73 0a                	jae    801e70 <__umoddi3+0xb0>
  801e66:	2b 44 24 08          	sub    0x8(%esp),%eax
  801e6a:	19 ea                	sbb    %ebp,%edx
  801e6c:	89 d7                	mov    %edx,%edi
  801e6e:	89 c3                	mov    %eax,%ebx
  801e70:	89 ca                	mov    %ecx,%edx
  801e72:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801e77:	29 de                	sub    %ebx,%esi
  801e79:	19 fa                	sbb    %edi,%edx
  801e7b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  801e7f:	89 d0                	mov    %edx,%eax
  801e81:	d3 e0                	shl    %cl,%eax
  801e83:	89 d9                	mov    %ebx,%ecx
  801e85:	d3 ee                	shr    %cl,%esi
  801e87:	d3 ea                	shr    %cl,%edx
  801e89:	09 f0                	or     %esi,%eax
  801e8b:	83 c4 1c             	add    $0x1c,%esp
  801e8e:	5b                   	pop    %ebx
  801e8f:	5e                   	pop    %esi
  801e90:	5f                   	pop    %edi
  801e91:	5d                   	pop    %ebp
  801e92:	c3                   	ret    
  801e93:	90                   	nop
  801e94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e98:	85 ff                	test   %edi,%edi
  801e9a:	89 f9                	mov    %edi,%ecx
  801e9c:	75 0b                	jne    801ea9 <__umoddi3+0xe9>
  801e9e:	b8 01 00 00 00       	mov    $0x1,%eax
  801ea3:	31 d2                	xor    %edx,%edx
  801ea5:	f7 f7                	div    %edi
  801ea7:	89 c1                	mov    %eax,%ecx
  801ea9:	89 d8                	mov    %ebx,%eax
  801eab:	31 d2                	xor    %edx,%edx
  801ead:	f7 f1                	div    %ecx
  801eaf:	89 f0                	mov    %esi,%eax
  801eb1:	f7 f1                	div    %ecx
  801eb3:	e9 31 ff ff ff       	jmp    801de9 <__umoddi3+0x29>
  801eb8:	90                   	nop
  801eb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ec0:	39 dd                	cmp    %ebx,%ebp
  801ec2:	72 08                	jb     801ecc <__umoddi3+0x10c>
  801ec4:	39 f7                	cmp    %esi,%edi
  801ec6:	0f 87 21 ff ff ff    	ja     801ded <__umoddi3+0x2d>
  801ecc:	89 da                	mov    %ebx,%edx
  801ece:	89 f0                	mov    %esi,%eax
  801ed0:	29 f8                	sub    %edi,%eax
  801ed2:	19 ea                	sbb    %ebp,%edx
  801ed4:	e9 14 ff ff ff       	jmp    801ded <__umoddi3+0x2d>
