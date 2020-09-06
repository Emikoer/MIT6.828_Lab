
obj/user/spawnhello.debug:     file format elf32-i386


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
  80002c:	e8 4a 00 00 00       	call   80007b <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	int r;
	cprintf("i am parent environment %08x\n", thisenv->env_id);
  800039:	a1 04 40 80 00       	mov    0x804004,%eax
  80003e:	8b 40 48             	mov    0x48(%eax),%eax
  800041:	50                   	push   %eax
  800042:	68 00 24 80 00       	push   $0x802400
  800047:	e8 6a 01 00 00       	call   8001b6 <cprintf>
	if ((r = spawnl("hello", "hello", 0)) < 0)
  80004c:	83 c4 0c             	add    $0xc,%esp
  80004f:	6a 00                	push   $0x0
  800051:	68 1e 24 80 00       	push   $0x80241e
  800056:	68 1e 24 80 00       	push   $0x80241e
  80005b:	e8 d6 1a 00 00       	call   801b36 <spawnl>
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	85 c0                	test   %eax,%eax
  800065:	78 02                	js     800069 <umain+0x36>
		panic("spawn(hello) failed: %e", r);
}
  800067:	c9                   	leave  
  800068:	c3                   	ret    
		panic("spawn(hello) failed: %e", r);
  800069:	50                   	push   %eax
  80006a:	68 24 24 80 00       	push   $0x802424
  80006f:	6a 09                	push   $0x9
  800071:	68 3c 24 80 00       	push   $0x80243c
  800076:	e8 60 00 00 00       	call   8000db <_panic>

0080007b <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80007b:	55                   	push   %ebp
  80007c:	89 e5                	mov    %esp,%ebp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800083:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800086:	e8 05 0b 00 00       	call   800b90 <sys_getenvid>
  80008b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800090:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800093:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800098:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80009d:	85 db                	test   %ebx,%ebx
  80009f:	7e 07                	jle    8000a8 <libmain+0x2d>
		binaryname = argv[0];
  8000a1:	8b 06                	mov    (%esi),%eax
  8000a3:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000a8:	83 ec 08             	sub    $0x8,%esp
  8000ab:	56                   	push   %esi
  8000ac:	53                   	push   %ebx
  8000ad:	e8 81 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000b2:	e8 0a 00 00 00       	call   8000c1 <exit>
}
  8000b7:	83 c4 10             	add    $0x10,%esp
  8000ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000bd:	5b                   	pop    %ebx
  8000be:	5e                   	pop    %esi
  8000bf:	5d                   	pop    %ebp
  8000c0:	c3                   	ret    

008000c1 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c1:	55                   	push   %ebp
  8000c2:	89 e5                	mov    %esp,%ebp
  8000c4:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000c7:	e8 c9 0e 00 00       	call   800f95 <close_all>
	sys_env_destroy(0);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	6a 00                	push   $0x0
  8000d1:	e8 79 0a 00 00       	call   800b4f <sys_env_destroy>
}
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	c9                   	leave  
  8000da:	c3                   	ret    

008000db <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	56                   	push   %esi
  8000df:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8000e0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8000e3:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8000e9:	e8 a2 0a 00 00       	call   800b90 <sys_getenvid>
  8000ee:	83 ec 0c             	sub    $0xc,%esp
  8000f1:	ff 75 0c             	pushl  0xc(%ebp)
  8000f4:	ff 75 08             	pushl  0x8(%ebp)
  8000f7:	56                   	push   %esi
  8000f8:	50                   	push   %eax
  8000f9:	68 58 24 80 00       	push   $0x802458
  8000fe:	e8 b3 00 00 00       	call   8001b6 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800103:	83 c4 18             	add    $0x18,%esp
  800106:	53                   	push   %ebx
  800107:	ff 75 10             	pushl  0x10(%ebp)
  80010a:	e8 56 00 00 00       	call   800165 <vcprintf>
	cprintf("\n");
  80010f:	c7 04 24 38 29 80 00 	movl   $0x802938,(%esp)
  800116:	e8 9b 00 00 00       	call   8001b6 <cprintf>
  80011b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80011e:	cc                   	int3   
  80011f:	eb fd                	jmp    80011e <_panic+0x43>

00800121 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800121:	55                   	push   %ebp
  800122:	89 e5                	mov    %esp,%ebp
  800124:	53                   	push   %ebx
  800125:	83 ec 04             	sub    $0x4,%esp
  800128:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80012b:	8b 13                	mov    (%ebx),%edx
  80012d:	8d 42 01             	lea    0x1(%edx),%eax
  800130:	89 03                	mov    %eax,(%ebx)
  800132:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800135:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800139:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013e:	74 09                	je     800149 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800140:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800144:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800147:	c9                   	leave  
  800148:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800149:	83 ec 08             	sub    $0x8,%esp
  80014c:	68 ff 00 00 00       	push   $0xff
  800151:	8d 43 08             	lea    0x8(%ebx),%eax
  800154:	50                   	push   %eax
  800155:	e8 b8 09 00 00       	call   800b12 <sys_cputs>
		b->idx = 0;
  80015a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800160:	83 c4 10             	add    $0x10,%esp
  800163:	eb db                	jmp    800140 <putch+0x1f>

00800165 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80016e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800175:	00 00 00 
	b.cnt = 0;
  800178:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800182:	ff 75 0c             	pushl  0xc(%ebp)
  800185:	ff 75 08             	pushl  0x8(%ebp)
  800188:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80018e:	50                   	push   %eax
  80018f:	68 21 01 80 00       	push   $0x800121
  800194:	e8 1a 01 00 00       	call   8002b3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800199:	83 c4 08             	add    $0x8,%esp
  80019c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001a2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a8:	50                   	push   %eax
  8001a9:	e8 64 09 00 00       	call   800b12 <sys_cputs>

	return b.cnt;
}
  8001ae:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001b4:	c9                   	leave  
  8001b5:	c3                   	ret    

008001b6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b6:	55                   	push   %ebp
  8001b7:	89 e5                	mov    %esp,%ebp
  8001b9:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001bc:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001bf:	50                   	push   %eax
  8001c0:	ff 75 08             	pushl  0x8(%ebp)
  8001c3:	e8 9d ff ff ff       	call   800165 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c8:	c9                   	leave  
  8001c9:	c3                   	ret    

008001ca <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001ca:	55                   	push   %ebp
  8001cb:	89 e5                	mov    %esp,%ebp
  8001cd:	57                   	push   %edi
  8001ce:	56                   	push   %esi
  8001cf:	53                   	push   %ebx
  8001d0:	83 ec 1c             	sub    $0x1c,%esp
  8001d3:	89 c7                	mov    %eax,%edi
  8001d5:	89 d6                	mov    %edx,%esi
  8001d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8001da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001dd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001e0:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e3:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001e6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001eb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001ee:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001f1:	39 d3                	cmp    %edx,%ebx
  8001f3:	72 05                	jb     8001fa <printnum+0x30>
  8001f5:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f8:	77 7a                	ja     800274 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001fa:	83 ec 0c             	sub    $0xc,%esp
  8001fd:	ff 75 18             	pushl  0x18(%ebp)
  800200:	8b 45 14             	mov    0x14(%ebp),%eax
  800203:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800206:	53                   	push   %ebx
  800207:	ff 75 10             	pushl  0x10(%ebp)
  80020a:	83 ec 08             	sub    $0x8,%esp
  80020d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800210:	ff 75 e0             	pushl  -0x20(%ebp)
  800213:	ff 75 dc             	pushl  -0x24(%ebp)
  800216:	ff 75 d8             	pushl  -0x28(%ebp)
  800219:	e8 a2 1f 00 00       	call   8021c0 <__udivdi3>
  80021e:	83 c4 18             	add    $0x18,%esp
  800221:	52                   	push   %edx
  800222:	50                   	push   %eax
  800223:	89 f2                	mov    %esi,%edx
  800225:	89 f8                	mov    %edi,%eax
  800227:	e8 9e ff ff ff       	call   8001ca <printnum>
  80022c:	83 c4 20             	add    $0x20,%esp
  80022f:	eb 13                	jmp    800244 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800231:	83 ec 08             	sub    $0x8,%esp
  800234:	56                   	push   %esi
  800235:	ff 75 18             	pushl  0x18(%ebp)
  800238:	ff d7                	call   *%edi
  80023a:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80023d:	83 eb 01             	sub    $0x1,%ebx
  800240:	85 db                	test   %ebx,%ebx
  800242:	7f ed                	jg     800231 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800244:	83 ec 08             	sub    $0x8,%esp
  800247:	56                   	push   %esi
  800248:	83 ec 04             	sub    $0x4,%esp
  80024b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024e:	ff 75 e0             	pushl  -0x20(%ebp)
  800251:	ff 75 dc             	pushl  -0x24(%ebp)
  800254:	ff 75 d8             	pushl  -0x28(%ebp)
  800257:	e8 84 20 00 00       	call   8022e0 <__umoddi3>
  80025c:	83 c4 14             	add    $0x14,%esp
  80025f:	0f be 80 7b 24 80 00 	movsbl 0x80247b(%eax),%eax
  800266:	50                   	push   %eax
  800267:	ff d7                	call   *%edi
}
  800269:	83 c4 10             	add    $0x10,%esp
  80026c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026f:	5b                   	pop    %ebx
  800270:	5e                   	pop    %esi
  800271:	5f                   	pop    %edi
  800272:	5d                   	pop    %ebp
  800273:	c3                   	ret    
  800274:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800277:	eb c4                	jmp    80023d <printnum+0x73>

00800279 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800279:	55                   	push   %ebp
  80027a:	89 e5                	mov    %esp,%ebp
  80027c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80027f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800283:	8b 10                	mov    (%eax),%edx
  800285:	3b 50 04             	cmp    0x4(%eax),%edx
  800288:	73 0a                	jae    800294 <sprintputch+0x1b>
		*b->buf++ = ch;
  80028a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80028d:	89 08                	mov    %ecx,(%eax)
  80028f:	8b 45 08             	mov    0x8(%ebp),%eax
  800292:	88 02                	mov    %al,(%edx)
}
  800294:	5d                   	pop    %ebp
  800295:	c3                   	ret    

00800296 <printfmt>:
{
  800296:	55                   	push   %ebp
  800297:	89 e5                	mov    %esp,%ebp
  800299:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80029c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80029f:	50                   	push   %eax
  8002a0:	ff 75 10             	pushl  0x10(%ebp)
  8002a3:	ff 75 0c             	pushl  0xc(%ebp)
  8002a6:	ff 75 08             	pushl  0x8(%ebp)
  8002a9:	e8 05 00 00 00       	call   8002b3 <vprintfmt>
}
  8002ae:	83 c4 10             	add    $0x10,%esp
  8002b1:	c9                   	leave  
  8002b2:	c3                   	ret    

008002b3 <vprintfmt>:
{
  8002b3:	55                   	push   %ebp
  8002b4:	89 e5                	mov    %esp,%ebp
  8002b6:	57                   	push   %edi
  8002b7:	56                   	push   %esi
  8002b8:	53                   	push   %ebx
  8002b9:	83 ec 2c             	sub    $0x2c,%esp
  8002bc:	8b 75 08             	mov    0x8(%ebp),%esi
  8002bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002c2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002c5:	e9 c1 03 00 00       	jmp    80068b <vprintfmt+0x3d8>
		padc = ' ';
  8002ca:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8002ce:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8002d5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8002dc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002e3:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002e8:	8d 47 01             	lea    0x1(%edi),%eax
  8002eb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ee:	0f b6 17             	movzbl (%edi),%edx
  8002f1:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002f4:	3c 55                	cmp    $0x55,%al
  8002f6:	0f 87 12 04 00 00    	ja     80070e <vprintfmt+0x45b>
  8002fc:	0f b6 c0             	movzbl %al,%eax
  8002ff:	ff 24 85 c0 25 80 00 	jmp    *0x8025c0(,%eax,4)
  800306:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800309:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80030d:	eb d9                	jmp    8002e8 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80030f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800312:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800316:	eb d0                	jmp    8002e8 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800318:	0f b6 d2             	movzbl %dl,%edx
  80031b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80031e:	b8 00 00 00 00       	mov    $0x0,%eax
  800323:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800326:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800329:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80032d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800330:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800333:	83 f9 09             	cmp    $0x9,%ecx
  800336:	77 55                	ja     80038d <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800338:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80033b:	eb e9                	jmp    800326 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  80033d:	8b 45 14             	mov    0x14(%ebp),%eax
  800340:	8b 00                	mov    (%eax),%eax
  800342:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800345:	8b 45 14             	mov    0x14(%ebp),%eax
  800348:	8d 40 04             	lea    0x4(%eax),%eax
  80034b:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80034e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800351:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800355:	79 91                	jns    8002e8 <vprintfmt+0x35>
				width = precision, precision = -1;
  800357:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80035a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80035d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800364:	eb 82                	jmp    8002e8 <vprintfmt+0x35>
  800366:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800369:	85 c0                	test   %eax,%eax
  80036b:	ba 00 00 00 00       	mov    $0x0,%edx
  800370:	0f 49 d0             	cmovns %eax,%edx
  800373:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800376:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800379:	e9 6a ff ff ff       	jmp    8002e8 <vprintfmt+0x35>
  80037e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800381:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800388:	e9 5b ff ff ff       	jmp    8002e8 <vprintfmt+0x35>
  80038d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800390:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800393:	eb bc                	jmp    800351 <vprintfmt+0x9e>
			lflag++;
  800395:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800398:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80039b:	e9 48 ff ff ff       	jmp    8002e8 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8003a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a3:	8d 78 04             	lea    0x4(%eax),%edi
  8003a6:	83 ec 08             	sub    $0x8,%esp
  8003a9:	53                   	push   %ebx
  8003aa:	ff 30                	pushl  (%eax)
  8003ac:	ff d6                	call   *%esi
			break;
  8003ae:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003b1:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003b4:	e9 cf 02 00 00       	jmp    800688 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  8003b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bc:	8d 78 04             	lea    0x4(%eax),%edi
  8003bf:	8b 00                	mov    (%eax),%eax
  8003c1:	99                   	cltd   
  8003c2:	31 d0                	xor    %edx,%eax
  8003c4:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003c6:	83 f8 0f             	cmp    $0xf,%eax
  8003c9:	7f 23                	jg     8003ee <vprintfmt+0x13b>
  8003cb:	8b 14 85 20 27 80 00 	mov    0x802720(,%eax,4),%edx
  8003d2:	85 d2                	test   %edx,%edx
  8003d4:	74 18                	je     8003ee <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8003d6:	52                   	push   %edx
  8003d7:	68 51 28 80 00       	push   $0x802851
  8003dc:	53                   	push   %ebx
  8003dd:	56                   	push   %esi
  8003de:	e8 b3 fe ff ff       	call   800296 <printfmt>
  8003e3:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003e6:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003e9:	e9 9a 02 00 00       	jmp    800688 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  8003ee:	50                   	push   %eax
  8003ef:	68 93 24 80 00       	push   $0x802493
  8003f4:	53                   	push   %ebx
  8003f5:	56                   	push   %esi
  8003f6:	e8 9b fe ff ff       	call   800296 <printfmt>
  8003fb:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003fe:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800401:	e9 82 02 00 00       	jmp    800688 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  800406:	8b 45 14             	mov    0x14(%ebp),%eax
  800409:	83 c0 04             	add    $0x4,%eax
  80040c:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80040f:	8b 45 14             	mov    0x14(%ebp),%eax
  800412:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800414:	85 ff                	test   %edi,%edi
  800416:	b8 8c 24 80 00       	mov    $0x80248c,%eax
  80041b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80041e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800422:	0f 8e bd 00 00 00    	jle    8004e5 <vprintfmt+0x232>
  800428:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80042c:	75 0e                	jne    80043c <vprintfmt+0x189>
  80042e:	89 75 08             	mov    %esi,0x8(%ebp)
  800431:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800434:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800437:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80043a:	eb 6d                	jmp    8004a9 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  80043c:	83 ec 08             	sub    $0x8,%esp
  80043f:	ff 75 d0             	pushl  -0x30(%ebp)
  800442:	57                   	push   %edi
  800443:	e8 6e 03 00 00       	call   8007b6 <strnlen>
  800448:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80044b:	29 c1                	sub    %eax,%ecx
  80044d:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800450:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800453:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800457:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80045a:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80045d:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  80045f:	eb 0f                	jmp    800470 <vprintfmt+0x1bd>
					putch(padc, putdat);
  800461:	83 ec 08             	sub    $0x8,%esp
  800464:	53                   	push   %ebx
  800465:	ff 75 e0             	pushl  -0x20(%ebp)
  800468:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80046a:	83 ef 01             	sub    $0x1,%edi
  80046d:	83 c4 10             	add    $0x10,%esp
  800470:	85 ff                	test   %edi,%edi
  800472:	7f ed                	jg     800461 <vprintfmt+0x1ae>
  800474:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800477:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80047a:	85 c9                	test   %ecx,%ecx
  80047c:	b8 00 00 00 00       	mov    $0x0,%eax
  800481:	0f 49 c1             	cmovns %ecx,%eax
  800484:	29 c1                	sub    %eax,%ecx
  800486:	89 75 08             	mov    %esi,0x8(%ebp)
  800489:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80048c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80048f:	89 cb                	mov    %ecx,%ebx
  800491:	eb 16                	jmp    8004a9 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  800493:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800497:	75 31                	jne    8004ca <vprintfmt+0x217>
					putch(ch, putdat);
  800499:	83 ec 08             	sub    $0x8,%esp
  80049c:	ff 75 0c             	pushl  0xc(%ebp)
  80049f:	50                   	push   %eax
  8004a0:	ff 55 08             	call   *0x8(%ebp)
  8004a3:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004a6:	83 eb 01             	sub    $0x1,%ebx
  8004a9:	83 c7 01             	add    $0x1,%edi
  8004ac:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8004b0:	0f be c2             	movsbl %dl,%eax
  8004b3:	85 c0                	test   %eax,%eax
  8004b5:	74 59                	je     800510 <vprintfmt+0x25d>
  8004b7:	85 f6                	test   %esi,%esi
  8004b9:	78 d8                	js     800493 <vprintfmt+0x1e0>
  8004bb:	83 ee 01             	sub    $0x1,%esi
  8004be:	79 d3                	jns    800493 <vprintfmt+0x1e0>
  8004c0:	89 df                	mov    %ebx,%edi
  8004c2:	8b 75 08             	mov    0x8(%ebp),%esi
  8004c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004c8:	eb 37                	jmp    800501 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004ca:	0f be d2             	movsbl %dl,%edx
  8004cd:	83 ea 20             	sub    $0x20,%edx
  8004d0:	83 fa 5e             	cmp    $0x5e,%edx
  8004d3:	76 c4                	jbe    800499 <vprintfmt+0x1e6>
					putch('?', putdat);
  8004d5:	83 ec 08             	sub    $0x8,%esp
  8004d8:	ff 75 0c             	pushl  0xc(%ebp)
  8004db:	6a 3f                	push   $0x3f
  8004dd:	ff 55 08             	call   *0x8(%ebp)
  8004e0:	83 c4 10             	add    $0x10,%esp
  8004e3:	eb c1                	jmp    8004a6 <vprintfmt+0x1f3>
  8004e5:	89 75 08             	mov    %esi,0x8(%ebp)
  8004e8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004eb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ee:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004f1:	eb b6                	jmp    8004a9 <vprintfmt+0x1f6>
				putch(' ', putdat);
  8004f3:	83 ec 08             	sub    $0x8,%esp
  8004f6:	53                   	push   %ebx
  8004f7:	6a 20                	push   $0x20
  8004f9:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004fb:	83 ef 01             	sub    $0x1,%edi
  8004fe:	83 c4 10             	add    $0x10,%esp
  800501:	85 ff                	test   %edi,%edi
  800503:	7f ee                	jg     8004f3 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800505:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800508:	89 45 14             	mov    %eax,0x14(%ebp)
  80050b:	e9 78 01 00 00       	jmp    800688 <vprintfmt+0x3d5>
  800510:	89 df                	mov    %ebx,%edi
  800512:	8b 75 08             	mov    0x8(%ebp),%esi
  800515:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800518:	eb e7                	jmp    800501 <vprintfmt+0x24e>
	if (lflag >= 2)
  80051a:	83 f9 01             	cmp    $0x1,%ecx
  80051d:	7e 3f                	jle    80055e <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  80051f:	8b 45 14             	mov    0x14(%ebp),%eax
  800522:	8b 50 04             	mov    0x4(%eax),%edx
  800525:	8b 00                	mov    (%eax),%eax
  800527:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80052a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80052d:	8b 45 14             	mov    0x14(%ebp),%eax
  800530:	8d 40 08             	lea    0x8(%eax),%eax
  800533:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800536:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80053a:	79 5c                	jns    800598 <vprintfmt+0x2e5>
				putch('-', putdat);
  80053c:	83 ec 08             	sub    $0x8,%esp
  80053f:	53                   	push   %ebx
  800540:	6a 2d                	push   $0x2d
  800542:	ff d6                	call   *%esi
				num = -(long long) num;
  800544:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800547:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80054a:	f7 da                	neg    %edx
  80054c:	83 d1 00             	adc    $0x0,%ecx
  80054f:	f7 d9                	neg    %ecx
  800551:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800554:	b8 0a 00 00 00       	mov    $0xa,%eax
  800559:	e9 10 01 00 00       	jmp    80066e <vprintfmt+0x3bb>
	else if (lflag)
  80055e:	85 c9                	test   %ecx,%ecx
  800560:	75 1b                	jne    80057d <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800562:	8b 45 14             	mov    0x14(%ebp),%eax
  800565:	8b 00                	mov    (%eax),%eax
  800567:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80056a:	89 c1                	mov    %eax,%ecx
  80056c:	c1 f9 1f             	sar    $0x1f,%ecx
  80056f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800572:	8b 45 14             	mov    0x14(%ebp),%eax
  800575:	8d 40 04             	lea    0x4(%eax),%eax
  800578:	89 45 14             	mov    %eax,0x14(%ebp)
  80057b:	eb b9                	jmp    800536 <vprintfmt+0x283>
		return va_arg(*ap, long);
  80057d:	8b 45 14             	mov    0x14(%ebp),%eax
  800580:	8b 00                	mov    (%eax),%eax
  800582:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800585:	89 c1                	mov    %eax,%ecx
  800587:	c1 f9 1f             	sar    $0x1f,%ecx
  80058a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80058d:	8b 45 14             	mov    0x14(%ebp),%eax
  800590:	8d 40 04             	lea    0x4(%eax),%eax
  800593:	89 45 14             	mov    %eax,0x14(%ebp)
  800596:	eb 9e                	jmp    800536 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  800598:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80059b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80059e:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005a3:	e9 c6 00 00 00       	jmp    80066e <vprintfmt+0x3bb>
	if (lflag >= 2)
  8005a8:	83 f9 01             	cmp    $0x1,%ecx
  8005ab:	7e 18                	jle    8005c5 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8005ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b0:	8b 10                	mov    (%eax),%edx
  8005b2:	8b 48 04             	mov    0x4(%eax),%ecx
  8005b5:	8d 40 08             	lea    0x8(%eax),%eax
  8005b8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005bb:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005c0:	e9 a9 00 00 00       	jmp    80066e <vprintfmt+0x3bb>
	else if (lflag)
  8005c5:	85 c9                	test   %ecx,%ecx
  8005c7:	75 1a                	jne    8005e3 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  8005c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cc:	8b 10                	mov    (%eax),%edx
  8005ce:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d3:	8d 40 04             	lea    0x4(%eax),%eax
  8005d6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005d9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005de:	e9 8b 00 00 00       	jmp    80066e <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8005e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e6:	8b 10                	mov    (%eax),%edx
  8005e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ed:	8d 40 04             	lea    0x4(%eax),%eax
  8005f0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005f3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f8:	eb 74                	jmp    80066e <vprintfmt+0x3bb>
	if (lflag >= 2)
  8005fa:	83 f9 01             	cmp    $0x1,%ecx
  8005fd:	7e 15                	jle    800614 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  8005ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800602:	8b 10                	mov    (%eax),%edx
  800604:	8b 48 04             	mov    0x4(%eax),%ecx
  800607:	8d 40 08             	lea    0x8(%eax),%eax
  80060a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80060d:	b8 08 00 00 00       	mov    $0x8,%eax
  800612:	eb 5a                	jmp    80066e <vprintfmt+0x3bb>
	else if (lflag)
  800614:	85 c9                	test   %ecx,%ecx
  800616:	75 17                	jne    80062f <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  800618:	8b 45 14             	mov    0x14(%ebp),%eax
  80061b:	8b 10                	mov    (%eax),%edx
  80061d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800622:	8d 40 04             	lea    0x4(%eax),%eax
  800625:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800628:	b8 08 00 00 00       	mov    $0x8,%eax
  80062d:	eb 3f                	jmp    80066e <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80062f:	8b 45 14             	mov    0x14(%ebp),%eax
  800632:	8b 10                	mov    (%eax),%edx
  800634:	b9 00 00 00 00       	mov    $0x0,%ecx
  800639:	8d 40 04             	lea    0x4(%eax),%eax
  80063c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80063f:	b8 08 00 00 00       	mov    $0x8,%eax
  800644:	eb 28                	jmp    80066e <vprintfmt+0x3bb>
			putch('0', putdat);
  800646:	83 ec 08             	sub    $0x8,%esp
  800649:	53                   	push   %ebx
  80064a:	6a 30                	push   $0x30
  80064c:	ff d6                	call   *%esi
			putch('x', putdat);
  80064e:	83 c4 08             	add    $0x8,%esp
  800651:	53                   	push   %ebx
  800652:	6a 78                	push   $0x78
  800654:	ff d6                	call   *%esi
			num = (unsigned long long)
  800656:	8b 45 14             	mov    0x14(%ebp),%eax
  800659:	8b 10                	mov    (%eax),%edx
  80065b:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800660:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800663:	8d 40 04             	lea    0x4(%eax),%eax
  800666:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800669:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80066e:	83 ec 0c             	sub    $0xc,%esp
  800671:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800675:	57                   	push   %edi
  800676:	ff 75 e0             	pushl  -0x20(%ebp)
  800679:	50                   	push   %eax
  80067a:	51                   	push   %ecx
  80067b:	52                   	push   %edx
  80067c:	89 da                	mov    %ebx,%edx
  80067e:	89 f0                	mov    %esi,%eax
  800680:	e8 45 fb ff ff       	call   8001ca <printnum>
			break;
  800685:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800688:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80068b:	83 c7 01             	add    $0x1,%edi
  80068e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800692:	83 f8 25             	cmp    $0x25,%eax
  800695:	0f 84 2f fc ff ff    	je     8002ca <vprintfmt+0x17>
			if (ch == '\0')
  80069b:	85 c0                	test   %eax,%eax
  80069d:	0f 84 8b 00 00 00    	je     80072e <vprintfmt+0x47b>
			putch(ch, putdat);
  8006a3:	83 ec 08             	sub    $0x8,%esp
  8006a6:	53                   	push   %ebx
  8006a7:	50                   	push   %eax
  8006a8:	ff d6                	call   *%esi
  8006aa:	83 c4 10             	add    $0x10,%esp
  8006ad:	eb dc                	jmp    80068b <vprintfmt+0x3d8>
	if (lflag >= 2)
  8006af:	83 f9 01             	cmp    $0x1,%ecx
  8006b2:	7e 15                	jle    8006c9 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  8006b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b7:	8b 10                	mov    (%eax),%edx
  8006b9:	8b 48 04             	mov    0x4(%eax),%ecx
  8006bc:	8d 40 08             	lea    0x8(%eax),%eax
  8006bf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006c2:	b8 10 00 00 00       	mov    $0x10,%eax
  8006c7:	eb a5                	jmp    80066e <vprintfmt+0x3bb>
	else if (lflag)
  8006c9:	85 c9                	test   %ecx,%ecx
  8006cb:	75 17                	jne    8006e4 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  8006cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d0:	8b 10                	mov    (%eax),%edx
  8006d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d7:	8d 40 04             	lea    0x4(%eax),%eax
  8006da:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006dd:	b8 10 00 00 00       	mov    $0x10,%eax
  8006e2:	eb 8a                	jmp    80066e <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8006e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e7:	8b 10                	mov    (%eax),%edx
  8006e9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ee:	8d 40 04             	lea    0x4(%eax),%eax
  8006f1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006f4:	b8 10 00 00 00       	mov    $0x10,%eax
  8006f9:	e9 70 ff ff ff       	jmp    80066e <vprintfmt+0x3bb>
			putch(ch, putdat);
  8006fe:	83 ec 08             	sub    $0x8,%esp
  800701:	53                   	push   %ebx
  800702:	6a 25                	push   $0x25
  800704:	ff d6                	call   *%esi
			break;
  800706:	83 c4 10             	add    $0x10,%esp
  800709:	e9 7a ff ff ff       	jmp    800688 <vprintfmt+0x3d5>
			putch('%', putdat);
  80070e:	83 ec 08             	sub    $0x8,%esp
  800711:	53                   	push   %ebx
  800712:	6a 25                	push   $0x25
  800714:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800716:	83 c4 10             	add    $0x10,%esp
  800719:	89 f8                	mov    %edi,%eax
  80071b:	eb 03                	jmp    800720 <vprintfmt+0x46d>
  80071d:	83 e8 01             	sub    $0x1,%eax
  800720:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800724:	75 f7                	jne    80071d <vprintfmt+0x46a>
  800726:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800729:	e9 5a ff ff ff       	jmp    800688 <vprintfmt+0x3d5>
}
  80072e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800731:	5b                   	pop    %ebx
  800732:	5e                   	pop    %esi
  800733:	5f                   	pop    %edi
  800734:	5d                   	pop    %ebp
  800735:	c3                   	ret    

00800736 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800736:	55                   	push   %ebp
  800737:	89 e5                	mov    %esp,%ebp
  800739:	83 ec 18             	sub    $0x18,%esp
  80073c:	8b 45 08             	mov    0x8(%ebp),%eax
  80073f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800742:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800745:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800749:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80074c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800753:	85 c0                	test   %eax,%eax
  800755:	74 26                	je     80077d <vsnprintf+0x47>
  800757:	85 d2                	test   %edx,%edx
  800759:	7e 22                	jle    80077d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80075b:	ff 75 14             	pushl  0x14(%ebp)
  80075e:	ff 75 10             	pushl  0x10(%ebp)
  800761:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800764:	50                   	push   %eax
  800765:	68 79 02 80 00       	push   $0x800279
  80076a:	e8 44 fb ff ff       	call   8002b3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80076f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800772:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800775:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800778:	83 c4 10             	add    $0x10,%esp
}
  80077b:	c9                   	leave  
  80077c:	c3                   	ret    
		return -E_INVAL;
  80077d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800782:	eb f7                	jmp    80077b <vsnprintf+0x45>

00800784 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800784:	55                   	push   %ebp
  800785:	89 e5                	mov    %esp,%ebp
  800787:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80078a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80078d:	50                   	push   %eax
  80078e:	ff 75 10             	pushl  0x10(%ebp)
  800791:	ff 75 0c             	pushl  0xc(%ebp)
  800794:	ff 75 08             	pushl  0x8(%ebp)
  800797:	e8 9a ff ff ff       	call   800736 <vsnprintf>
	va_end(ap);

	return rc;
}
  80079c:	c9                   	leave  
  80079d:	c3                   	ret    

0080079e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80079e:	55                   	push   %ebp
  80079f:	89 e5                	mov    %esp,%ebp
  8007a1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a9:	eb 03                	jmp    8007ae <strlen+0x10>
		n++;
  8007ab:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007ae:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007b2:	75 f7                	jne    8007ab <strlen+0xd>
	return n;
}
  8007b4:	5d                   	pop    %ebp
  8007b5:	c3                   	ret    

008007b6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
  8007b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007bc:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c4:	eb 03                	jmp    8007c9 <strnlen+0x13>
		n++;
  8007c6:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c9:	39 d0                	cmp    %edx,%eax
  8007cb:	74 06                	je     8007d3 <strnlen+0x1d>
  8007cd:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007d1:	75 f3                	jne    8007c6 <strnlen+0x10>
	return n;
}
  8007d3:	5d                   	pop    %ebp
  8007d4:	c3                   	ret    

008007d5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007d5:	55                   	push   %ebp
  8007d6:	89 e5                	mov    %esp,%ebp
  8007d8:	53                   	push   %ebx
  8007d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007df:	89 c2                	mov    %eax,%edx
  8007e1:	83 c1 01             	add    $0x1,%ecx
  8007e4:	83 c2 01             	add    $0x1,%edx
  8007e7:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007eb:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007ee:	84 db                	test   %bl,%bl
  8007f0:	75 ef                	jne    8007e1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007f2:	5b                   	pop    %ebx
  8007f3:	5d                   	pop    %ebp
  8007f4:	c3                   	ret    

008007f5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007f5:	55                   	push   %ebp
  8007f6:	89 e5                	mov    %esp,%ebp
  8007f8:	53                   	push   %ebx
  8007f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007fc:	53                   	push   %ebx
  8007fd:	e8 9c ff ff ff       	call   80079e <strlen>
  800802:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800805:	ff 75 0c             	pushl  0xc(%ebp)
  800808:	01 d8                	add    %ebx,%eax
  80080a:	50                   	push   %eax
  80080b:	e8 c5 ff ff ff       	call   8007d5 <strcpy>
	return dst;
}
  800810:	89 d8                	mov    %ebx,%eax
  800812:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800815:	c9                   	leave  
  800816:	c3                   	ret    

00800817 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800817:	55                   	push   %ebp
  800818:	89 e5                	mov    %esp,%ebp
  80081a:	56                   	push   %esi
  80081b:	53                   	push   %ebx
  80081c:	8b 75 08             	mov    0x8(%ebp),%esi
  80081f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800822:	89 f3                	mov    %esi,%ebx
  800824:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800827:	89 f2                	mov    %esi,%edx
  800829:	eb 0f                	jmp    80083a <strncpy+0x23>
		*dst++ = *src;
  80082b:	83 c2 01             	add    $0x1,%edx
  80082e:	0f b6 01             	movzbl (%ecx),%eax
  800831:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800834:	80 39 01             	cmpb   $0x1,(%ecx)
  800837:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80083a:	39 da                	cmp    %ebx,%edx
  80083c:	75 ed                	jne    80082b <strncpy+0x14>
	}
	return ret;
}
  80083e:	89 f0                	mov    %esi,%eax
  800840:	5b                   	pop    %ebx
  800841:	5e                   	pop    %esi
  800842:	5d                   	pop    %ebp
  800843:	c3                   	ret    

00800844 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800844:	55                   	push   %ebp
  800845:	89 e5                	mov    %esp,%ebp
  800847:	56                   	push   %esi
  800848:	53                   	push   %ebx
  800849:	8b 75 08             	mov    0x8(%ebp),%esi
  80084c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800852:	89 f0                	mov    %esi,%eax
  800854:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800858:	85 c9                	test   %ecx,%ecx
  80085a:	75 0b                	jne    800867 <strlcpy+0x23>
  80085c:	eb 17                	jmp    800875 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80085e:	83 c2 01             	add    $0x1,%edx
  800861:	83 c0 01             	add    $0x1,%eax
  800864:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800867:	39 d8                	cmp    %ebx,%eax
  800869:	74 07                	je     800872 <strlcpy+0x2e>
  80086b:	0f b6 0a             	movzbl (%edx),%ecx
  80086e:	84 c9                	test   %cl,%cl
  800870:	75 ec                	jne    80085e <strlcpy+0x1a>
		*dst = '\0';
  800872:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800875:	29 f0                	sub    %esi,%eax
}
  800877:	5b                   	pop    %ebx
  800878:	5e                   	pop    %esi
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800881:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800884:	eb 06                	jmp    80088c <strcmp+0x11>
		p++, q++;
  800886:	83 c1 01             	add    $0x1,%ecx
  800889:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80088c:	0f b6 01             	movzbl (%ecx),%eax
  80088f:	84 c0                	test   %al,%al
  800891:	74 04                	je     800897 <strcmp+0x1c>
  800893:	3a 02                	cmp    (%edx),%al
  800895:	74 ef                	je     800886 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800897:	0f b6 c0             	movzbl %al,%eax
  80089a:	0f b6 12             	movzbl (%edx),%edx
  80089d:	29 d0                	sub    %edx,%eax
}
  80089f:	5d                   	pop    %ebp
  8008a0:	c3                   	ret    

008008a1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008a1:	55                   	push   %ebp
  8008a2:	89 e5                	mov    %esp,%ebp
  8008a4:	53                   	push   %ebx
  8008a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ab:	89 c3                	mov    %eax,%ebx
  8008ad:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008b0:	eb 06                	jmp    8008b8 <strncmp+0x17>
		n--, p++, q++;
  8008b2:	83 c0 01             	add    $0x1,%eax
  8008b5:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008b8:	39 d8                	cmp    %ebx,%eax
  8008ba:	74 16                	je     8008d2 <strncmp+0x31>
  8008bc:	0f b6 08             	movzbl (%eax),%ecx
  8008bf:	84 c9                	test   %cl,%cl
  8008c1:	74 04                	je     8008c7 <strncmp+0x26>
  8008c3:	3a 0a                	cmp    (%edx),%cl
  8008c5:	74 eb                	je     8008b2 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c7:	0f b6 00             	movzbl (%eax),%eax
  8008ca:	0f b6 12             	movzbl (%edx),%edx
  8008cd:	29 d0                	sub    %edx,%eax
}
  8008cf:	5b                   	pop    %ebx
  8008d0:	5d                   	pop    %ebp
  8008d1:	c3                   	ret    
		return 0;
  8008d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d7:	eb f6                	jmp    8008cf <strncmp+0x2e>

008008d9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008d9:	55                   	push   %ebp
  8008da:	89 e5                	mov    %esp,%ebp
  8008dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008df:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e3:	0f b6 10             	movzbl (%eax),%edx
  8008e6:	84 d2                	test   %dl,%dl
  8008e8:	74 09                	je     8008f3 <strchr+0x1a>
		if (*s == c)
  8008ea:	38 ca                	cmp    %cl,%dl
  8008ec:	74 0a                	je     8008f8 <strchr+0x1f>
	for (; *s; s++)
  8008ee:	83 c0 01             	add    $0x1,%eax
  8008f1:	eb f0                	jmp    8008e3 <strchr+0xa>
			return (char *) s;
	return 0;
  8008f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800900:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800904:	eb 03                	jmp    800909 <strfind+0xf>
  800906:	83 c0 01             	add    $0x1,%eax
  800909:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80090c:	38 ca                	cmp    %cl,%dl
  80090e:	74 04                	je     800914 <strfind+0x1a>
  800910:	84 d2                	test   %dl,%dl
  800912:	75 f2                	jne    800906 <strfind+0xc>
			break;
	return (char *) s;
}
  800914:	5d                   	pop    %ebp
  800915:	c3                   	ret    

00800916 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800916:	55                   	push   %ebp
  800917:	89 e5                	mov    %esp,%ebp
  800919:	57                   	push   %edi
  80091a:	56                   	push   %esi
  80091b:	53                   	push   %ebx
  80091c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80091f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800922:	85 c9                	test   %ecx,%ecx
  800924:	74 13                	je     800939 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800926:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80092c:	75 05                	jne    800933 <memset+0x1d>
  80092e:	f6 c1 03             	test   $0x3,%cl
  800931:	74 0d                	je     800940 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800933:	8b 45 0c             	mov    0xc(%ebp),%eax
  800936:	fc                   	cld    
  800937:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800939:	89 f8                	mov    %edi,%eax
  80093b:	5b                   	pop    %ebx
  80093c:	5e                   	pop    %esi
  80093d:	5f                   	pop    %edi
  80093e:	5d                   	pop    %ebp
  80093f:	c3                   	ret    
		c &= 0xFF;
  800940:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800944:	89 d3                	mov    %edx,%ebx
  800946:	c1 e3 08             	shl    $0x8,%ebx
  800949:	89 d0                	mov    %edx,%eax
  80094b:	c1 e0 18             	shl    $0x18,%eax
  80094e:	89 d6                	mov    %edx,%esi
  800950:	c1 e6 10             	shl    $0x10,%esi
  800953:	09 f0                	or     %esi,%eax
  800955:	09 c2                	or     %eax,%edx
  800957:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800959:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80095c:	89 d0                	mov    %edx,%eax
  80095e:	fc                   	cld    
  80095f:	f3 ab                	rep stos %eax,%es:(%edi)
  800961:	eb d6                	jmp    800939 <memset+0x23>

00800963 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800963:	55                   	push   %ebp
  800964:	89 e5                	mov    %esp,%ebp
  800966:	57                   	push   %edi
  800967:	56                   	push   %esi
  800968:	8b 45 08             	mov    0x8(%ebp),%eax
  80096b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80096e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800971:	39 c6                	cmp    %eax,%esi
  800973:	73 35                	jae    8009aa <memmove+0x47>
  800975:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800978:	39 c2                	cmp    %eax,%edx
  80097a:	76 2e                	jbe    8009aa <memmove+0x47>
		s += n;
		d += n;
  80097c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80097f:	89 d6                	mov    %edx,%esi
  800981:	09 fe                	or     %edi,%esi
  800983:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800989:	74 0c                	je     800997 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80098b:	83 ef 01             	sub    $0x1,%edi
  80098e:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800991:	fd                   	std    
  800992:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800994:	fc                   	cld    
  800995:	eb 21                	jmp    8009b8 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800997:	f6 c1 03             	test   $0x3,%cl
  80099a:	75 ef                	jne    80098b <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80099c:	83 ef 04             	sub    $0x4,%edi
  80099f:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009a2:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009a5:	fd                   	std    
  8009a6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a8:	eb ea                	jmp    800994 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009aa:	89 f2                	mov    %esi,%edx
  8009ac:	09 c2                	or     %eax,%edx
  8009ae:	f6 c2 03             	test   $0x3,%dl
  8009b1:	74 09                	je     8009bc <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009b3:	89 c7                	mov    %eax,%edi
  8009b5:	fc                   	cld    
  8009b6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009b8:	5e                   	pop    %esi
  8009b9:	5f                   	pop    %edi
  8009ba:	5d                   	pop    %ebp
  8009bb:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009bc:	f6 c1 03             	test   $0x3,%cl
  8009bf:	75 f2                	jne    8009b3 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009c1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009c4:	89 c7                	mov    %eax,%edi
  8009c6:	fc                   	cld    
  8009c7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c9:	eb ed                	jmp    8009b8 <memmove+0x55>

008009cb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009ce:	ff 75 10             	pushl  0x10(%ebp)
  8009d1:	ff 75 0c             	pushl  0xc(%ebp)
  8009d4:	ff 75 08             	pushl  0x8(%ebp)
  8009d7:	e8 87 ff ff ff       	call   800963 <memmove>
}
  8009dc:	c9                   	leave  
  8009dd:	c3                   	ret    

008009de <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	56                   	push   %esi
  8009e2:	53                   	push   %ebx
  8009e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009e9:	89 c6                	mov    %eax,%esi
  8009eb:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ee:	39 f0                	cmp    %esi,%eax
  8009f0:	74 1c                	je     800a0e <memcmp+0x30>
		if (*s1 != *s2)
  8009f2:	0f b6 08             	movzbl (%eax),%ecx
  8009f5:	0f b6 1a             	movzbl (%edx),%ebx
  8009f8:	38 d9                	cmp    %bl,%cl
  8009fa:	75 08                	jne    800a04 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009fc:	83 c0 01             	add    $0x1,%eax
  8009ff:	83 c2 01             	add    $0x1,%edx
  800a02:	eb ea                	jmp    8009ee <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a04:	0f b6 c1             	movzbl %cl,%eax
  800a07:	0f b6 db             	movzbl %bl,%ebx
  800a0a:	29 d8                	sub    %ebx,%eax
  800a0c:	eb 05                	jmp    800a13 <memcmp+0x35>
	}

	return 0;
  800a0e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a13:	5b                   	pop    %ebx
  800a14:	5e                   	pop    %esi
  800a15:	5d                   	pop    %ebp
  800a16:	c3                   	ret    

00800a17 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a20:	89 c2                	mov    %eax,%edx
  800a22:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a25:	39 d0                	cmp    %edx,%eax
  800a27:	73 09                	jae    800a32 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a29:	38 08                	cmp    %cl,(%eax)
  800a2b:	74 05                	je     800a32 <memfind+0x1b>
	for (; s < ends; s++)
  800a2d:	83 c0 01             	add    $0x1,%eax
  800a30:	eb f3                	jmp    800a25 <memfind+0xe>
			break;
	return (void *) s;
}
  800a32:	5d                   	pop    %ebp
  800a33:	c3                   	ret    

00800a34 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	57                   	push   %edi
  800a38:	56                   	push   %esi
  800a39:	53                   	push   %ebx
  800a3a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a3d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a40:	eb 03                	jmp    800a45 <strtol+0x11>
		s++;
  800a42:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a45:	0f b6 01             	movzbl (%ecx),%eax
  800a48:	3c 20                	cmp    $0x20,%al
  800a4a:	74 f6                	je     800a42 <strtol+0xe>
  800a4c:	3c 09                	cmp    $0x9,%al
  800a4e:	74 f2                	je     800a42 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a50:	3c 2b                	cmp    $0x2b,%al
  800a52:	74 2e                	je     800a82 <strtol+0x4e>
	int neg = 0;
  800a54:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a59:	3c 2d                	cmp    $0x2d,%al
  800a5b:	74 2f                	je     800a8c <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a5d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a63:	75 05                	jne    800a6a <strtol+0x36>
  800a65:	80 39 30             	cmpb   $0x30,(%ecx)
  800a68:	74 2c                	je     800a96 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a6a:	85 db                	test   %ebx,%ebx
  800a6c:	75 0a                	jne    800a78 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a6e:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a73:	80 39 30             	cmpb   $0x30,(%ecx)
  800a76:	74 28                	je     800aa0 <strtol+0x6c>
		base = 10;
  800a78:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7d:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a80:	eb 50                	jmp    800ad2 <strtol+0x9e>
		s++;
  800a82:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a85:	bf 00 00 00 00       	mov    $0x0,%edi
  800a8a:	eb d1                	jmp    800a5d <strtol+0x29>
		s++, neg = 1;
  800a8c:	83 c1 01             	add    $0x1,%ecx
  800a8f:	bf 01 00 00 00       	mov    $0x1,%edi
  800a94:	eb c7                	jmp    800a5d <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a96:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a9a:	74 0e                	je     800aaa <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a9c:	85 db                	test   %ebx,%ebx
  800a9e:	75 d8                	jne    800a78 <strtol+0x44>
		s++, base = 8;
  800aa0:	83 c1 01             	add    $0x1,%ecx
  800aa3:	bb 08 00 00 00       	mov    $0x8,%ebx
  800aa8:	eb ce                	jmp    800a78 <strtol+0x44>
		s += 2, base = 16;
  800aaa:	83 c1 02             	add    $0x2,%ecx
  800aad:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ab2:	eb c4                	jmp    800a78 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800ab4:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ab7:	89 f3                	mov    %esi,%ebx
  800ab9:	80 fb 19             	cmp    $0x19,%bl
  800abc:	77 29                	ja     800ae7 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800abe:	0f be d2             	movsbl %dl,%edx
  800ac1:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ac4:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ac7:	7d 30                	jge    800af9 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800ac9:	83 c1 01             	add    $0x1,%ecx
  800acc:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ad0:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ad2:	0f b6 11             	movzbl (%ecx),%edx
  800ad5:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ad8:	89 f3                	mov    %esi,%ebx
  800ada:	80 fb 09             	cmp    $0x9,%bl
  800add:	77 d5                	ja     800ab4 <strtol+0x80>
			dig = *s - '0';
  800adf:	0f be d2             	movsbl %dl,%edx
  800ae2:	83 ea 30             	sub    $0x30,%edx
  800ae5:	eb dd                	jmp    800ac4 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800ae7:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aea:	89 f3                	mov    %esi,%ebx
  800aec:	80 fb 19             	cmp    $0x19,%bl
  800aef:	77 08                	ja     800af9 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800af1:	0f be d2             	movsbl %dl,%edx
  800af4:	83 ea 37             	sub    $0x37,%edx
  800af7:	eb cb                	jmp    800ac4 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800af9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800afd:	74 05                	je     800b04 <strtol+0xd0>
		*endptr = (char *) s;
  800aff:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b02:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b04:	89 c2                	mov    %eax,%edx
  800b06:	f7 da                	neg    %edx
  800b08:	85 ff                	test   %edi,%edi
  800b0a:	0f 45 c2             	cmovne %edx,%eax
}
  800b0d:	5b                   	pop    %ebx
  800b0e:	5e                   	pop    %esi
  800b0f:	5f                   	pop    %edi
  800b10:	5d                   	pop    %ebp
  800b11:	c3                   	ret    

00800b12 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b12:	55                   	push   %ebp
  800b13:	89 e5                	mov    %esp,%ebp
  800b15:	57                   	push   %edi
  800b16:	56                   	push   %esi
  800b17:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b18:	b8 00 00 00 00       	mov    $0x0,%eax
  800b1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b23:	89 c3                	mov    %eax,%ebx
  800b25:	89 c7                	mov    %eax,%edi
  800b27:	89 c6                	mov    %eax,%esi
  800b29:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b2b:	5b                   	pop    %ebx
  800b2c:	5e                   	pop    %esi
  800b2d:	5f                   	pop    %edi
  800b2e:	5d                   	pop    %ebp
  800b2f:	c3                   	ret    

00800b30 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b30:	55                   	push   %ebp
  800b31:	89 e5                	mov    %esp,%ebp
  800b33:	57                   	push   %edi
  800b34:	56                   	push   %esi
  800b35:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b36:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b40:	89 d1                	mov    %edx,%ecx
  800b42:	89 d3                	mov    %edx,%ebx
  800b44:	89 d7                	mov    %edx,%edi
  800b46:	89 d6                	mov    %edx,%esi
  800b48:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b4a:	5b                   	pop    %ebx
  800b4b:	5e                   	pop    %esi
  800b4c:	5f                   	pop    %edi
  800b4d:	5d                   	pop    %ebp
  800b4e:	c3                   	ret    

00800b4f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b4f:	55                   	push   %ebp
  800b50:	89 e5                	mov    %esp,%ebp
  800b52:	57                   	push   %edi
  800b53:	56                   	push   %esi
  800b54:	53                   	push   %ebx
  800b55:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b58:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b60:	b8 03 00 00 00       	mov    $0x3,%eax
  800b65:	89 cb                	mov    %ecx,%ebx
  800b67:	89 cf                	mov    %ecx,%edi
  800b69:	89 ce                	mov    %ecx,%esi
  800b6b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b6d:	85 c0                	test   %eax,%eax
  800b6f:	7f 08                	jg     800b79 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b74:	5b                   	pop    %ebx
  800b75:	5e                   	pop    %esi
  800b76:	5f                   	pop    %edi
  800b77:	5d                   	pop    %ebp
  800b78:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b79:	83 ec 0c             	sub    $0xc,%esp
  800b7c:	50                   	push   %eax
  800b7d:	6a 03                	push   $0x3
  800b7f:	68 7f 27 80 00       	push   $0x80277f
  800b84:	6a 23                	push   $0x23
  800b86:	68 9c 27 80 00       	push   $0x80279c
  800b8b:	e8 4b f5 ff ff       	call   8000db <_panic>

00800b90 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b90:	55                   	push   %ebp
  800b91:	89 e5                	mov    %esp,%ebp
  800b93:	57                   	push   %edi
  800b94:	56                   	push   %esi
  800b95:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b96:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9b:	b8 02 00 00 00       	mov    $0x2,%eax
  800ba0:	89 d1                	mov    %edx,%ecx
  800ba2:	89 d3                	mov    %edx,%ebx
  800ba4:	89 d7                	mov    %edx,%edi
  800ba6:	89 d6                	mov    %edx,%esi
  800ba8:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800baa:	5b                   	pop    %ebx
  800bab:	5e                   	pop    %esi
  800bac:	5f                   	pop    %edi
  800bad:	5d                   	pop    %ebp
  800bae:	c3                   	ret    

00800baf <sys_yield>:

void
sys_yield(void)
{
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	57                   	push   %edi
  800bb3:	56                   	push   %esi
  800bb4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bb5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bba:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bbf:	89 d1                	mov    %edx,%ecx
  800bc1:	89 d3                	mov    %edx,%ebx
  800bc3:	89 d7                	mov    %edx,%edi
  800bc5:	89 d6                	mov    %edx,%esi
  800bc7:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bc9:	5b                   	pop    %ebx
  800bca:	5e                   	pop    %esi
  800bcb:	5f                   	pop    %edi
  800bcc:	5d                   	pop    %ebp
  800bcd:	c3                   	ret    

00800bce <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bce:	55                   	push   %ebp
  800bcf:	89 e5                	mov    %esp,%ebp
  800bd1:	57                   	push   %edi
  800bd2:	56                   	push   %esi
  800bd3:	53                   	push   %ebx
  800bd4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bd7:	be 00 00 00 00       	mov    $0x0,%esi
  800bdc:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be2:	b8 04 00 00 00       	mov    $0x4,%eax
  800be7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bea:	89 f7                	mov    %esi,%edi
  800bec:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bee:	85 c0                	test   %eax,%eax
  800bf0:	7f 08                	jg     800bfa <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bf2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf5:	5b                   	pop    %ebx
  800bf6:	5e                   	pop    %esi
  800bf7:	5f                   	pop    %edi
  800bf8:	5d                   	pop    %ebp
  800bf9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfa:	83 ec 0c             	sub    $0xc,%esp
  800bfd:	50                   	push   %eax
  800bfe:	6a 04                	push   $0x4
  800c00:	68 7f 27 80 00       	push   $0x80277f
  800c05:	6a 23                	push   $0x23
  800c07:	68 9c 27 80 00       	push   $0x80279c
  800c0c:	e8 ca f4 ff ff       	call   8000db <_panic>

00800c11 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c11:	55                   	push   %ebp
  800c12:	89 e5                	mov    %esp,%ebp
  800c14:	57                   	push   %edi
  800c15:	56                   	push   %esi
  800c16:	53                   	push   %ebx
  800c17:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c20:	b8 05 00 00 00       	mov    $0x5,%eax
  800c25:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c28:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c2b:	8b 75 18             	mov    0x18(%ebp),%esi
  800c2e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c30:	85 c0                	test   %eax,%eax
  800c32:	7f 08                	jg     800c3c <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c37:	5b                   	pop    %ebx
  800c38:	5e                   	pop    %esi
  800c39:	5f                   	pop    %edi
  800c3a:	5d                   	pop    %ebp
  800c3b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3c:	83 ec 0c             	sub    $0xc,%esp
  800c3f:	50                   	push   %eax
  800c40:	6a 05                	push   $0x5
  800c42:	68 7f 27 80 00       	push   $0x80277f
  800c47:	6a 23                	push   $0x23
  800c49:	68 9c 27 80 00       	push   $0x80279c
  800c4e:	e8 88 f4 ff ff       	call   8000db <_panic>

00800c53 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c53:	55                   	push   %ebp
  800c54:	89 e5                	mov    %esp,%ebp
  800c56:	57                   	push   %edi
  800c57:	56                   	push   %esi
  800c58:	53                   	push   %ebx
  800c59:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c5c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c61:	8b 55 08             	mov    0x8(%ebp),%edx
  800c64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c67:	b8 06 00 00 00       	mov    $0x6,%eax
  800c6c:	89 df                	mov    %ebx,%edi
  800c6e:	89 de                	mov    %ebx,%esi
  800c70:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c72:	85 c0                	test   %eax,%eax
  800c74:	7f 08                	jg     800c7e <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c79:	5b                   	pop    %ebx
  800c7a:	5e                   	pop    %esi
  800c7b:	5f                   	pop    %edi
  800c7c:	5d                   	pop    %ebp
  800c7d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7e:	83 ec 0c             	sub    $0xc,%esp
  800c81:	50                   	push   %eax
  800c82:	6a 06                	push   $0x6
  800c84:	68 7f 27 80 00       	push   $0x80277f
  800c89:	6a 23                	push   $0x23
  800c8b:	68 9c 27 80 00       	push   $0x80279c
  800c90:	e8 46 f4 ff ff       	call   8000db <_panic>

00800c95 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c95:	55                   	push   %ebp
  800c96:	89 e5                	mov    %esp,%ebp
  800c98:	57                   	push   %edi
  800c99:	56                   	push   %esi
  800c9a:	53                   	push   %ebx
  800c9b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c9e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca9:	b8 08 00 00 00       	mov    $0x8,%eax
  800cae:	89 df                	mov    %ebx,%edi
  800cb0:	89 de                	mov    %ebx,%esi
  800cb2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cb4:	85 c0                	test   %eax,%eax
  800cb6:	7f 08                	jg     800cc0 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cb8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbb:	5b                   	pop    %ebx
  800cbc:	5e                   	pop    %esi
  800cbd:	5f                   	pop    %edi
  800cbe:	5d                   	pop    %ebp
  800cbf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc0:	83 ec 0c             	sub    $0xc,%esp
  800cc3:	50                   	push   %eax
  800cc4:	6a 08                	push   $0x8
  800cc6:	68 7f 27 80 00       	push   $0x80277f
  800ccb:	6a 23                	push   $0x23
  800ccd:	68 9c 27 80 00       	push   $0x80279c
  800cd2:	e8 04 f4 ff ff       	call   8000db <_panic>

00800cd7 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cd7:	55                   	push   %ebp
  800cd8:	89 e5                	mov    %esp,%ebp
  800cda:	57                   	push   %edi
  800cdb:	56                   	push   %esi
  800cdc:	53                   	push   %ebx
  800cdd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ce0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ceb:	b8 09 00 00 00       	mov    $0x9,%eax
  800cf0:	89 df                	mov    %ebx,%edi
  800cf2:	89 de                	mov    %ebx,%esi
  800cf4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cf6:	85 c0                	test   %eax,%eax
  800cf8:	7f 08                	jg     800d02 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cfa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfd:	5b                   	pop    %ebx
  800cfe:	5e                   	pop    %esi
  800cff:	5f                   	pop    %edi
  800d00:	5d                   	pop    %ebp
  800d01:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d02:	83 ec 0c             	sub    $0xc,%esp
  800d05:	50                   	push   %eax
  800d06:	6a 09                	push   $0x9
  800d08:	68 7f 27 80 00       	push   $0x80277f
  800d0d:	6a 23                	push   $0x23
  800d0f:	68 9c 27 80 00       	push   $0x80279c
  800d14:	e8 c2 f3 ff ff       	call   8000db <_panic>

00800d19 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d19:	55                   	push   %ebp
  800d1a:	89 e5                	mov    %esp,%ebp
  800d1c:	57                   	push   %edi
  800d1d:	56                   	push   %esi
  800d1e:	53                   	push   %ebx
  800d1f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d22:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d27:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d32:	89 df                	mov    %ebx,%edi
  800d34:	89 de                	mov    %ebx,%esi
  800d36:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d38:	85 c0                	test   %eax,%eax
  800d3a:	7f 08                	jg     800d44 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3f:	5b                   	pop    %ebx
  800d40:	5e                   	pop    %esi
  800d41:	5f                   	pop    %edi
  800d42:	5d                   	pop    %ebp
  800d43:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d44:	83 ec 0c             	sub    $0xc,%esp
  800d47:	50                   	push   %eax
  800d48:	6a 0a                	push   $0xa
  800d4a:	68 7f 27 80 00       	push   $0x80277f
  800d4f:	6a 23                	push   $0x23
  800d51:	68 9c 27 80 00       	push   $0x80279c
  800d56:	e8 80 f3 ff ff       	call   8000db <_panic>

00800d5b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d5b:	55                   	push   %ebp
  800d5c:	89 e5                	mov    %esp,%ebp
  800d5e:	57                   	push   %edi
  800d5f:	56                   	push   %esi
  800d60:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d61:	8b 55 08             	mov    0x8(%ebp),%edx
  800d64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d67:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d6c:	be 00 00 00 00       	mov    $0x0,%esi
  800d71:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d74:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d77:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d79:	5b                   	pop    %ebx
  800d7a:	5e                   	pop    %esi
  800d7b:	5f                   	pop    %edi
  800d7c:	5d                   	pop    %ebp
  800d7d:	c3                   	ret    

00800d7e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d7e:	55                   	push   %ebp
  800d7f:	89 e5                	mov    %esp,%ebp
  800d81:	57                   	push   %edi
  800d82:	56                   	push   %esi
  800d83:	53                   	push   %ebx
  800d84:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d87:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d94:	89 cb                	mov    %ecx,%ebx
  800d96:	89 cf                	mov    %ecx,%edi
  800d98:	89 ce                	mov    %ecx,%esi
  800d9a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d9c:	85 c0                	test   %eax,%eax
  800d9e:	7f 08                	jg     800da8 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800da0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da3:	5b                   	pop    %ebx
  800da4:	5e                   	pop    %esi
  800da5:	5f                   	pop    %edi
  800da6:	5d                   	pop    %ebp
  800da7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800da8:	83 ec 0c             	sub    $0xc,%esp
  800dab:	50                   	push   %eax
  800dac:	6a 0d                	push   $0xd
  800dae:	68 7f 27 80 00       	push   $0x80277f
  800db3:	6a 23                	push   $0x23
  800db5:	68 9c 27 80 00       	push   $0x80279c
  800dba:	e8 1c f3 ff ff       	call   8000db <_panic>

00800dbf <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800dbf:	55                   	push   %ebp
  800dc0:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dc2:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc5:	05 00 00 00 30       	add    $0x30000000,%eax
  800dca:	c1 e8 0c             	shr    $0xc,%eax
}
  800dcd:	5d                   	pop    %ebp
  800dce:	c3                   	ret    

00800dcf <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800dcf:	55                   	push   %ebp
  800dd0:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dd2:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd5:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800dda:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ddf:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800de4:	5d                   	pop    %ebp
  800de5:	c3                   	ret    

00800de6 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800de6:	55                   	push   %ebp
  800de7:	89 e5                	mov    %esp,%ebp
  800de9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dec:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800df1:	89 c2                	mov    %eax,%edx
  800df3:	c1 ea 16             	shr    $0x16,%edx
  800df6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dfd:	f6 c2 01             	test   $0x1,%dl
  800e00:	74 2a                	je     800e2c <fd_alloc+0x46>
  800e02:	89 c2                	mov    %eax,%edx
  800e04:	c1 ea 0c             	shr    $0xc,%edx
  800e07:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e0e:	f6 c2 01             	test   $0x1,%dl
  800e11:	74 19                	je     800e2c <fd_alloc+0x46>
  800e13:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800e18:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e1d:	75 d2                	jne    800df1 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e1f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e25:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800e2a:	eb 07                	jmp    800e33 <fd_alloc+0x4d>
			*fd_store = fd;
  800e2c:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e2e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e33:	5d                   	pop    %ebp
  800e34:	c3                   	ret    

00800e35 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e35:	55                   	push   %ebp
  800e36:	89 e5                	mov    %esp,%ebp
  800e38:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e3b:	83 f8 1f             	cmp    $0x1f,%eax
  800e3e:	77 36                	ja     800e76 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e40:	c1 e0 0c             	shl    $0xc,%eax
  800e43:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e48:	89 c2                	mov    %eax,%edx
  800e4a:	c1 ea 16             	shr    $0x16,%edx
  800e4d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e54:	f6 c2 01             	test   $0x1,%dl
  800e57:	74 24                	je     800e7d <fd_lookup+0x48>
  800e59:	89 c2                	mov    %eax,%edx
  800e5b:	c1 ea 0c             	shr    $0xc,%edx
  800e5e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e65:	f6 c2 01             	test   $0x1,%dl
  800e68:	74 1a                	je     800e84 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e6a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e6d:	89 02                	mov    %eax,(%edx)
	return 0;
  800e6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e74:	5d                   	pop    %ebp
  800e75:	c3                   	ret    
		return -E_INVAL;
  800e76:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e7b:	eb f7                	jmp    800e74 <fd_lookup+0x3f>
		return -E_INVAL;
  800e7d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e82:	eb f0                	jmp    800e74 <fd_lookup+0x3f>
  800e84:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e89:	eb e9                	jmp    800e74 <fd_lookup+0x3f>

00800e8b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e8b:	55                   	push   %ebp
  800e8c:	89 e5                	mov    %esp,%ebp
  800e8e:	83 ec 08             	sub    $0x8,%esp
  800e91:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e94:	ba 28 28 80 00       	mov    $0x802828,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e99:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800e9e:	39 08                	cmp    %ecx,(%eax)
  800ea0:	74 33                	je     800ed5 <dev_lookup+0x4a>
  800ea2:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800ea5:	8b 02                	mov    (%edx),%eax
  800ea7:	85 c0                	test   %eax,%eax
  800ea9:	75 f3                	jne    800e9e <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800eab:	a1 04 40 80 00       	mov    0x804004,%eax
  800eb0:	8b 40 48             	mov    0x48(%eax),%eax
  800eb3:	83 ec 04             	sub    $0x4,%esp
  800eb6:	51                   	push   %ecx
  800eb7:	50                   	push   %eax
  800eb8:	68 ac 27 80 00       	push   $0x8027ac
  800ebd:	e8 f4 f2 ff ff       	call   8001b6 <cprintf>
	*dev = 0;
  800ec2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ec5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800ecb:	83 c4 10             	add    $0x10,%esp
  800ece:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ed3:	c9                   	leave  
  800ed4:	c3                   	ret    
			*dev = devtab[i];
  800ed5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed8:	89 01                	mov    %eax,(%ecx)
			return 0;
  800eda:	b8 00 00 00 00       	mov    $0x0,%eax
  800edf:	eb f2                	jmp    800ed3 <dev_lookup+0x48>

00800ee1 <fd_close>:
{
  800ee1:	55                   	push   %ebp
  800ee2:	89 e5                	mov    %esp,%ebp
  800ee4:	57                   	push   %edi
  800ee5:	56                   	push   %esi
  800ee6:	53                   	push   %ebx
  800ee7:	83 ec 1c             	sub    $0x1c,%esp
  800eea:	8b 75 08             	mov    0x8(%ebp),%esi
  800eed:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ef0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ef3:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ef4:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800efa:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800efd:	50                   	push   %eax
  800efe:	e8 32 ff ff ff       	call   800e35 <fd_lookup>
  800f03:	89 c3                	mov    %eax,%ebx
  800f05:	83 c4 08             	add    $0x8,%esp
  800f08:	85 c0                	test   %eax,%eax
  800f0a:	78 05                	js     800f11 <fd_close+0x30>
	    || fd != fd2)
  800f0c:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800f0f:	74 16                	je     800f27 <fd_close+0x46>
		return (must_exist ? r : 0);
  800f11:	89 f8                	mov    %edi,%eax
  800f13:	84 c0                	test   %al,%al
  800f15:	b8 00 00 00 00       	mov    $0x0,%eax
  800f1a:	0f 44 d8             	cmove  %eax,%ebx
}
  800f1d:	89 d8                	mov    %ebx,%eax
  800f1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f22:	5b                   	pop    %ebx
  800f23:	5e                   	pop    %esi
  800f24:	5f                   	pop    %edi
  800f25:	5d                   	pop    %ebp
  800f26:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f27:	83 ec 08             	sub    $0x8,%esp
  800f2a:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800f2d:	50                   	push   %eax
  800f2e:	ff 36                	pushl  (%esi)
  800f30:	e8 56 ff ff ff       	call   800e8b <dev_lookup>
  800f35:	89 c3                	mov    %eax,%ebx
  800f37:	83 c4 10             	add    $0x10,%esp
  800f3a:	85 c0                	test   %eax,%eax
  800f3c:	78 15                	js     800f53 <fd_close+0x72>
		if (dev->dev_close)
  800f3e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f41:	8b 40 10             	mov    0x10(%eax),%eax
  800f44:	85 c0                	test   %eax,%eax
  800f46:	74 1b                	je     800f63 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  800f48:	83 ec 0c             	sub    $0xc,%esp
  800f4b:	56                   	push   %esi
  800f4c:	ff d0                	call   *%eax
  800f4e:	89 c3                	mov    %eax,%ebx
  800f50:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800f53:	83 ec 08             	sub    $0x8,%esp
  800f56:	56                   	push   %esi
  800f57:	6a 00                	push   $0x0
  800f59:	e8 f5 fc ff ff       	call   800c53 <sys_page_unmap>
	return r;
  800f5e:	83 c4 10             	add    $0x10,%esp
  800f61:	eb ba                	jmp    800f1d <fd_close+0x3c>
			r = 0;
  800f63:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f68:	eb e9                	jmp    800f53 <fd_close+0x72>

00800f6a <close>:

int
close(int fdnum)
{
  800f6a:	55                   	push   %ebp
  800f6b:	89 e5                	mov    %esp,%ebp
  800f6d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f70:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f73:	50                   	push   %eax
  800f74:	ff 75 08             	pushl  0x8(%ebp)
  800f77:	e8 b9 fe ff ff       	call   800e35 <fd_lookup>
  800f7c:	83 c4 08             	add    $0x8,%esp
  800f7f:	85 c0                	test   %eax,%eax
  800f81:	78 10                	js     800f93 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f83:	83 ec 08             	sub    $0x8,%esp
  800f86:	6a 01                	push   $0x1
  800f88:	ff 75 f4             	pushl  -0xc(%ebp)
  800f8b:	e8 51 ff ff ff       	call   800ee1 <fd_close>
  800f90:	83 c4 10             	add    $0x10,%esp
}
  800f93:	c9                   	leave  
  800f94:	c3                   	ret    

00800f95 <close_all>:

void
close_all(void)
{
  800f95:	55                   	push   %ebp
  800f96:	89 e5                	mov    %esp,%ebp
  800f98:	53                   	push   %ebx
  800f99:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f9c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fa1:	83 ec 0c             	sub    $0xc,%esp
  800fa4:	53                   	push   %ebx
  800fa5:	e8 c0 ff ff ff       	call   800f6a <close>
	for (i = 0; i < MAXFD; i++)
  800faa:	83 c3 01             	add    $0x1,%ebx
  800fad:	83 c4 10             	add    $0x10,%esp
  800fb0:	83 fb 20             	cmp    $0x20,%ebx
  800fb3:	75 ec                	jne    800fa1 <close_all+0xc>
}
  800fb5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fb8:	c9                   	leave  
  800fb9:	c3                   	ret    

00800fba <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fba:	55                   	push   %ebp
  800fbb:	89 e5                	mov    %esp,%ebp
  800fbd:	57                   	push   %edi
  800fbe:	56                   	push   %esi
  800fbf:	53                   	push   %ebx
  800fc0:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fc3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fc6:	50                   	push   %eax
  800fc7:	ff 75 08             	pushl  0x8(%ebp)
  800fca:	e8 66 fe ff ff       	call   800e35 <fd_lookup>
  800fcf:	89 c3                	mov    %eax,%ebx
  800fd1:	83 c4 08             	add    $0x8,%esp
  800fd4:	85 c0                	test   %eax,%eax
  800fd6:	0f 88 81 00 00 00    	js     80105d <dup+0xa3>
		return r;
	close(newfdnum);
  800fdc:	83 ec 0c             	sub    $0xc,%esp
  800fdf:	ff 75 0c             	pushl  0xc(%ebp)
  800fe2:	e8 83 ff ff ff       	call   800f6a <close>

	newfd = INDEX2FD(newfdnum);
  800fe7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fea:	c1 e6 0c             	shl    $0xc,%esi
  800fed:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800ff3:	83 c4 04             	add    $0x4,%esp
  800ff6:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ff9:	e8 d1 fd ff ff       	call   800dcf <fd2data>
  800ffe:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801000:	89 34 24             	mov    %esi,(%esp)
  801003:	e8 c7 fd ff ff       	call   800dcf <fd2data>
  801008:	83 c4 10             	add    $0x10,%esp
  80100b:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80100d:	89 d8                	mov    %ebx,%eax
  80100f:	c1 e8 16             	shr    $0x16,%eax
  801012:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801019:	a8 01                	test   $0x1,%al
  80101b:	74 11                	je     80102e <dup+0x74>
  80101d:	89 d8                	mov    %ebx,%eax
  80101f:	c1 e8 0c             	shr    $0xc,%eax
  801022:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801029:	f6 c2 01             	test   $0x1,%dl
  80102c:	75 39                	jne    801067 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80102e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801031:	89 d0                	mov    %edx,%eax
  801033:	c1 e8 0c             	shr    $0xc,%eax
  801036:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80103d:	83 ec 0c             	sub    $0xc,%esp
  801040:	25 07 0e 00 00       	and    $0xe07,%eax
  801045:	50                   	push   %eax
  801046:	56                   	push   %esi
  801047:	6a 00                	push   $0x0
  801049:	52                   	push   %edx
  80104a:	6a 00                	push   $0x0
  80104c:	e8 c0 fb ff ff       	call   800c11 <sys_page_map>
  801051:	89 c3                	mov    %eax,%ebx
  801053:	83 c4 20             	add    $0x20,%esp
  801056:	85 c0                	test   %eax,%eax
  801058:	78 31                	js     80108b <dup+0xd1>
		goto err;

	return newfdnum;
  80105a:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80105d:	89 d8                	mov    %ebx,%eax
  80105f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801062:	5b                   	pop    %ebx
  801063:	5e                   	pop    %esi
  801064:	5f                   	pop    %edi
  801065:	5d                   	pop    %ebp
  801066:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801067:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80106e:	83 ec 0c             	sub    $0xc,%esp
  801071:	25 07 0e 00 00       	and    $0xe07,%eax
  801076:	50                   	push   %eax
  801077:	57                   	push   %edi
  801078:	6a 00                	push   $0x0
  80107a:	53                   	push   %ebx
  80107b:	6a 00                	push   $0x0
  80107d:	e8 8f fb ff ff       	call   800c11 <sys_page_map>
  801082:	89 c3                	mov    %eax,%ebx
  801084:	83 c4 20             	add    $0x20,%esp
  801087:	85 c0                	test   %eax,%eax
  801089:	79 a3                	jns    80102e <dup+0x74>
	sys_page_unmap(0, newfd);
  80108b:	83 ec 08             	sub    $0x8,%esp
  80108e:	56                   	push   %esi
  80108f:	6a 00                	push   $0x0
  801091:	e8 bd fb ff ff       	call   800c53 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801096:	83 c4 08             	add    $0x8,%esp
  801099:	57                   	push   %edi
  80109a:	6a 00                	push   $0x0
  80109c:	e8 b2 fb ff ff       	call   800c53 <sys_page_unmap>
	return r;
  8010a1:	83 c4 10             	add    $0x10,%esp
  8010a4:	eb b7                	jmp    80105d <dup+0xa3>

008010a6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010a6:	55                   	push   %ebp
  8010a7:	89 e5                	mov    %esp,%ebp
  8010a9:	53                   	push   %ebx
  8010aa:	83 ec 14             	sub    $0x14,%esp
  8010ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010b3:	50                   	push   %eax
  8010b4:	53                   	push   %ebx
  8010b5:	e8 7b fd ff ff       	call   800e35 <fd_lookup>
  8010ba:	83 c4 08             	add    $0x8,%esp
  8010bd:	85 c0                	test   %eax,%eax
  8010bf:	78 3f                	js     801100 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010c1:	83 ec 08             	sub    $0x8,%esp
  8010c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010c7:	50                   	push   %eax
  8010c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010cb:	ff 30                	pushl  (%eax)
  8010cd:	e8 b9 fd ff ff       	call   800e8b <dev_lookup>
  8010d2:	83 c4 10             	add    $0x10,%esp
  8010d5:	85 c0                	test   %eax,%eax
  8010d7:	78 27                	js     801100 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010d9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010dc:	8b 42 08             	mov    0x8(%edx),%eax
  8010df:	83 e0 03             	and    $0x3,%eax
  8010e2:	83 f8 01             	cmp    $0x1,%eax
  8010e5:	74 1e                	je     801105 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8010e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010ea:	8b 40 08             	mov    0x8(%eax),%eax
  8010ed:	85 c0                	test   %eax,%eax
  8010ef:	74 35                	je     801126 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010f1:	83 ec 04             	sub    $0x4,%esp
  8010f4:	ff 75 10             	pushl  0x10(%ebp)
  8010f7:	ff 75 0c             	pushl  0xc(%ebp)
  8010fa:	52                   	push   %edx
  8010fb:	ff d0                	call   *%eax
  8010fd:	83 c4 10             	add    $0x10,%esp
}
  801100:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801103:	c9                   	leave  
  801104:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801105:	a1 04 40 80 00       	mov    0x804004,%eax
  80110a:	8b 40 48             	mov    0x48(%eax),%eax
  80110d:	83 ec 04             	sub    $0x4,%esp
  801110:	53                   	push   %ebx
  801111:	50                   	push   %eax
  801112:	68 ed 27 80 00       	push   $0x8027ed
  801117:	e8 9a f0 ff ff       	call   8001b6 <cprintf>
		return -E_INVAL;
  80111c:	83 c4 10             	add    $0x10,%esp
  80111f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801124:	eb da                	jmp    801100 <read+0x5a>
		return -E_NOT_SUPP;
  801126:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80112b:	eb d3                	jmp    801100 <read+0x5a>

0080112d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80112d:	55                   	push   %ebp
  80112e:	89 e5                	mov    %esp,%ebp
  801130:	57                   	push   %edi
  801131:	56                   	push   %esi
  801132:	53                   	push   %ebx
  801133:	83 ec 0c             	sub    $0xc,%esp
  801136:	8b 7d 08             	mov    0x8(%ebp),%edi
  801139:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80113c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801141:	39 f3                	cmp    %esi,%ebx
  801143:	73 25                	jae    80116a <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801145:	83 ec 04             	sub    $0x4,%esp
  801148:	89 f0                	mov    %esi,%eax
  80114a:	29 d8                	sub    %ebx,%eax
  80114c:	50                   	push   %eax
  80114d:	89 d8                	mov    %ebx,%eax
  80114f:	03 45 0c             	add    0xc(%ebp),%eax
  801152:	50                   	push   %eax
  801153:	57                   	push   %edi
  801154:	e8 4d ff ff ff       	call   8010a6 <read>
		if (m < 0)
  801159:	83 c4 10             	add    $0x10,%esp
  80115c:	85 c0                	test   %eax,%eax
  80115e:	78 08                	js     801168 <readn+0x3b>
			return m;
		if (m == 0)
  801160:	85 c0                	test   %eax,%eax
  801162:	74 06                	je     80116a <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  801164:	01 c3                	add    %eax,%ebx
  801166:	eb d9                	jmp    801141 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801168:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80116a:	89 d8                	mov    %ebx,%eax
  80116c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80116f:	5b                   	pop    %ebx
  801170:	5e                   	pop    %esi
  801171:	5f                   	pop    %edi
  801172:	5d                   	pop    %ebp
  801173:	c3                   	ret    

00801174 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801174:	55                   	push   %ebp
  801175:	89 e5                	mov    %esp,%ebp
  801177:	53                   	push   %ebx
  801178:	83 ec 14             	sub    $0x14,%esp
  80117b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80117e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801181:	50                   	push   %eax
  801182:	53                   	push   %ebx
  801183:	e8 ad fc ff ff       	call   800e35 <fd_lookup>
  801188:	83 c4 08             	add    $0x8,%esp
  80118b:	85 c0                	test   %eax,%eax
  80118d:	78 3a                	js     8011c9 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80118f:	83 ec 08             	sub    $0x8,%esp
  801192:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801195:	50                   	push   %eax
  801196:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801199:	ff 30                	pushl  (%eax)
  80119b:	e8 eb fc ff ff       	call   800e8b <dev_lookup>
  8011a0:	83 c4 10             	add    $0x10,%esp
  8011a3:	85 c0                	test   %eax,%eax
  8011a5:	78 22                	js     8011c9 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011aa:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011ae:	74 1e                	je     8011ce <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011b3:	8b 52 0c             	mov    0xc(%edx),%edx
  8011b6:	85 d2                	test   %edx,%edx
  8011b8:	74 35                	je     8011ef <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011ba:	83 ec 04             	sub    $0x4,%esp
  8011bd:	ff 75 10             	pushl  0x10(%ebp)
  8011c0:	ff 75 0c             	pushl  0xc(%ebp)
  8011c3:	50                   	push   %eax
  8011c4:	ff d2                	call   *%edx
  8011c6:	83 c4 10             	add    $0x10,%esp
}
  8011c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011cc:	c9                   	leave  
  8011cd:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011ce:	a1 04 40 80 00       	mov    0x804004,%eax
  8011d3:	8b 40 48             	mov    0x48(%eax),%eax
  8011d6:	83 ec 04             	sub    $0x4,%esp
  8011d9:	53                   	push   %ebx
  8011da:	50                   	push   %eax
  8011db:	68 09 28 80 00       	push   $0x802809
  8011e0:	e8 d1 ef ff ff       	call   8001b6 <cprintf>
		return -E_INVAL;
  8011e5:	83 c4 10             	add    $0x10,%esp
  8011e8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011ed:	eb da                	jmp    8011c9 <write+0x55>
		return -E_NOT_SUPP;
  8011ef:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011f4:	eb d3                	jmp    8011c9 <write+0x55>

008011f6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8011f6:	55                   	push   %ebp
  8011f7:	89 e5                	mov    %esp,%ebp
  8011f9:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011fc:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011ff:	50                   	push   %eax
  801200:	ff 75 08             	pushl  0x8(%ebp)
  801203:	e8 2d fc ff ff       	call   800e35 <fd_lookup>
  801208:	83 c4 08             	add    $0x8,%esp
  80120b:	85 c0                	test   %eax,%eax
  80120d:	78 0e                	js     80121d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80120f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801212:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801215:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801218:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80121d:	c9                   	leave  
  80121e:	c3                   	ret    

0080121f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80121f:	55                   	push   %ebp
  801220:	89 e5                	mov    %esp,%ebp
  801222:	53                   	push   %ebx
  801223:	83 ec 14             	sub    $0x14,%esp
  801226:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801229:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80122c:	50                   	push   %eax
  80122d:	53                   	push   %ebx
  80122e:	e8 02 fc ff ff       	call   800e35 <fd_lookup>
  801233:	83 c4 08             	add    $0x8,%esp
  801236:	85 c0                	test   %eax,%eax
  801238:	78 37                	js     801271 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80123a:	83 ec 08             	sub    $0x8,%esp
  80123d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801240:	50                   	push   %eax
  801241:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801244:	ff 30                	pushl  (%eax)
  801246:	e8 40 fc ff ff       	call   800e8b <dev_lookup>
  80124b:	83 c4 10             	add    $0x10,%esp
  80124e:	85 c0                	test   %eax,%eax
  801250:	78 1f                	js     801271 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801252:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801255:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801259:	74 1b                	je     801276 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80125b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80125e:	8b 52 18             	mov    0x18(%edx),%edx
  801261:	85 d2                	test   %edx,%edx
  801263:	74 32                	je     801297 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801265:	83 ec 08             	sub    $0x8,%esp
  801268:	ff 75 0c             	pushl  0xc(%ebp)
  80126b:	50                   	push   %eax
  80126c:	ff d2                	call   *%edx
  80126e:	83 c4 10             	add    $0x10,%esp
}
  801271:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801274:	c9                   	leave  
  801275:	c3                   	ret    
			thisenv->env_id, fdnum);
  801276:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80127b:	8b 40 48             	mov    0x48(%eax),%eax
  80127e:	83 ec 04             	sub    $0x4,%esp
  801281:	53                   	push   %ebx
  801282:	50                   	push   %eax
  801283:	68 cc 27 80 00       	push   $0x8027cc
  801288:	e8 29 ef ff ff       	call   8001b6 <cprintf>
		return -E_INVAL;
  80128d:	83 c4 10             	add    $0x10,%esp
  801290:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801295:	eb da                	jmp    801271 <ftruncate+0x52>
		return -E_NOT_SUPP;
  801297:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80129c:	eb d3                	jmp    801271 <ftruncate+0x52>

0080129e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80129e:	55                   	push   %ebp
  80129f:	89 e5                	mov    %esp,%ebp
  8012a1:	53                   	push   %ebx
  8012a2:	83 ec 14             	sub    $0x14,%esp
  8012a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012a8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ab:	50                   	push   %eax
  8012ac:	ff 75 08             	pushl  0x8(%ebp)
  8012af:	e8 81 fb ff ff       	call   800e35 <fd_lookup>
  8012b4:	83 c4 08             	add    $0x8,%esp
  8012b7:	85 c0                	test   %eax,%eax
  8012b9:	78 4b                	js     801306 <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012bb:	83 ec 08             	sub    $0x8,%esp
  8012be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c1:	50                   	push   %eax
  8012c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c5:	ff 30                	pushl  (%eax)
  8012c7:	e8 bf fb ff ff       	call   800e8b <dev_lookup>
  8012cc:	83 c4 10             	add    $0x10,%esp
  8012cf:	85 c0                	test   %eax,%eax
  8012d1:	78 33                	js     801306 <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  8012d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012d6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012da:	74 2f                	je     80130b <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012dc:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012df:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012e6:	00 00 00 
	stat->st_isdir = 0;
  8012e9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012f0:	00 00 00 
	stat->st_dev = dev;
  8012f3:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012f9:	83 ec 08             	sub    $0x8,%esp
  8012fc:	53                   	push   %ebx
  8012fd:	ff 75 f0             	pushl  -0x10(%ebp)
  801300:	ff 50 14             	call   *0x14(%eax)
  801303:	83 c4 10             	add    $0x10,%esp
}
  801306:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801309:	c9                   	leave  
  80130a:	c3                   	ret    
		return -E_NOT_SUPP;
  80130b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801310:	eb f4                	jmp    801306 <fstat+0x68>

00801312 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801312:	55                   	push   %ebp
  801313:	89 e5                	mov    %esp,%ebp
  801315:	56                   	push   %esi
  801316:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801317:	83 ec 08             	sub    $0x8,%esp
  80131a:	6a 00                	push   $0x0
  80131c:	ff 75 08             	pushl  0x8(%ebp)
  80131f:	e8 e7 01 00 00       	call   80150b <open>
  801324:	89 c3                	mov    %eax,%ebx
  801326:	83 c4 10             	add    $0x10,%esp
  801329:	85 c0                	test   %eax,%eax
  80132b:	78 1b                	js     801348 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80132d:	83 ec 08             	sub    $0x8,%esp
  801330:	ff 75 0c             	pushl  0xc(%ebp)
  801333:	50                   	push   %eax
  801334:	e8 65 ff ff ff       	call   80129e <fstat>
  801339:	89 c6                	mov    %eax,%esi
	close(fd);
  80133b:	89 1c 24             	mov    %ebx,(%esp)
  80133e:	e8 27 fc ff ff       	call   800f6a <close>
	return r;
  801343:	83 c4 10             	add    $0x10,%esp
  801346:	89 f3                	mov    %esi,%ebx
}
  801348:	89 d8                	mov    %ebx,%eax
  80134a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80134d:	5b                   	pop    %ebx
  80134e:	5e                   	pop    %esi
  80134f:	5d                   	pop    %ebp
  801350:	c3                   	ret    

00801351 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801351:	55                   	push   %ebp
  801352:	89 e5                	mov    %esp,%ebp
  801354:	56                   	push   %esi
  801355:	53                   	push   %ebx
  801356:	89 c6                	mov    %eax,%esi
  801358:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80135a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801361:	74 27                	je     80138a <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801363:	6a 07                	push   $0x7
  801365:	68 00 50 80 00       	push   $0x805000
  80136a:	56                   	push   %esi
  80136b:	ff 35 00 40 80 00    	pushl  0x804000
  801371:	e8 7c 0d 00 00       	call   8020f2 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801376:	83 c4 0c             	add    $0xc,%esp
  801379:	6a 00                	push   $0x0
  80137b:	53                   	push   %ebx
  80137c:	6a 00                	push   $0x0
  80137e:	e8 fa 0c 00 00       	call   80207d <ipc_recv>
}
  801383:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801386:	5b                   	pop    %ebx
  801387:	5e                   	pop    %esi
  801388:	5d                   	pop    %ebp
  801389:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80138a:	83 ec 0c             	sub    $0xc,%esp
  80138d:	6a 01                	push   $0x1
  80138f:	e8 b4 0d 00 00       	call   802148 <ipc_find_env>
  801394:	a3 00 40 80 00       	mov    %eax,0x804000
  801399:	83 c4 10             	add    $0x10,%esp
  80139c:	eb c5                	jmp    801363 <fsipc+0x12>

0080139e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80139e:	55                   	push   %ebp
  80139f:	89 e5                	mov    %esp,%ebp
  8013a1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a7:	8b 40 0c             	mov    0xc(%eax),%eax
  8013aa:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013b2:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8013bc:	b8 02 00 00 00       	mov    $0x2,%eax
  8013c1:	e8 8b ff ff ff       	call   801351 <fsipc>
}
  8013c6:	c9                   	leave  
  8013c7:	c3                   	ret    

008013c8 <devfile_flush>:
{
  8013c8:	55                   	push   %ebp
  8013c9:	89 e5                	mov    %esp,%ebp
  8013cb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d1:	8b 40 0c             	mov    0xc(%eax),%eax
  8013d4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8013de:	b8 06 00 00 00       	mov    $0x6,%eax
  8013e3:	e8 69 ff ff ff       	call   801351 <fsipc>
}
  8013e8:	c9                   	leave  
  8013e9:	c3                   	ret    

008013ea <devfile_stat>:
{
  8013ea:	55                   	push   %ebp
  8013eb:	89 e5                	mov    %esp,%ebp
  8013ed:	53                   	push   %ebx
  8013ee:	83 ec 04             	sub    $0x4,%esp
  8013f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f7:	8b 40 0c             	mov    0xc(%eax),%eax
  8013fa:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801404:	b8 05 00 00 00       	mov    $0x5,%eax
  801409:	e8 43 ff ff ff       	call   801351 <fsipc>
  80140e:	85 c0                	test   %eax,%eax
  801410:	78 2c                	js     80143e <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801412:	83 ec 08             	sub    $0x8,%esp
  801415:	68 00 50 80 00       	push   $0x805000
  80141a:	53                   	push   %ebx
  80141b:	e8 b5 f3 ff ff       	call   8007d5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801420:	a1 80 50 80 00       	mov    0x805080,%eax
  801425:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80142b:	a1 84 50 80 00       	mov    0x805084,%eax
  801430:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801436:	83 c4 10             	add    $0x10,%esp
  801439:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80143e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801441:	c9                   	leave  
  801442:	c3                   	ret    

00801443 <devfile_write>:
{
  801443:	55                   	push   %ebp
  801444:	89 e5                	mov    %esp,%ebp
  801446:	83 ec 0c             	sub    $0xc,%esp
  801449:	8b 45 10             	mov    0x10(%ebp),%eax
  80144c:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801451:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801456:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801459:	8b 55 08             	mov    0x8(%ebp),%edx
  80145c:	8b 52 0c             	mov    0xc(%edx),%edx
  80145f:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801465:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf,buf,n);
  80146a:	50                   	push   %eax
  80146b:	ff 75 0c             	pushl  0xc(%ebp)
  80146e:	68 08 50 80 00       	push   $0x805008
  801473:	e8 eb f4 ff ff       	call   800963 <memmove>
	if((r = fsipc(FSREQ_WRITE,NULL))<0)
  801478:	ba 00 00 00 00       	mov    $0x0,%edx
  80147d:	b8 04 00 00 00       	mov    $0x4,%eax
  801482:	e8 ca fe ff ff       	call   801351 <fsipc>
}
  801487:	c9                   	leave  
  801488:	c3                   	ret    

00801489 <devfile_read>:
{
  801489:	55                   	push   %ebp
  80148a:	89 e5                	mov    %esp,%ebp
  80148c:	56                   	push   %esi
  80148d:	53                   	push   %ebx
  80148e:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801491:	8b 45 08             	mov    0x8(%ebp),%eax
  801494:	8b 40 0c             	mov    0xc(%eax),%eax
  801497:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80149c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8014a7:	b8 03 00 00 00       	mov    $0x3,%eax
  8014ac:	e8 a0 fe ff ff       	call   801351 <fsipc>
  8014b1:	89 c3                	mov    %eax,%ebx
  8014b3:	85 c0                	test   %eax,%eax
  8014b5:	78 1f                	js     8014d6 <devfile_read+0x4d>
	assert(r <= n);
  8014b7:	39 f0                	cmp    %esi,%eax
  8014b9:	77 24                	ja     8014df <devfile_read+0x56>
	assert(r <= PGSIZE);
  8014bb:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014c0:	7f 33                	jg     8014f5 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014c2:	83 ec 04             	sub    $0x4,%esp
  8014c5:	50                   	push   %eax
  8014c6:	68 00 50 80 00       	push   $0x805000
  8014cb:	ff 75 0c             	pushl  0xc(%ebp)
  8014ce:	e8 90 f4 ff ff       	call   800963 <memmove>
	return r;
  8014d3:	83 c4 10             	add    $0x10,%esp
}
  8014d6:	89 d8                	mov    %ebx,%eax
  8014d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014db:	5b                   	pop    %ebx
  8014dc:	5e                   	pop    %esi
  8014dd:	5d                   	pop    %ebp
  8014de:	c3                   	ret    
	assert(r <= n);
  8014df:	68 38 28 80 00       	push   $0x802838
  8014e4:	68 3f 28 80 00       	push   $0x80283f
  8014e9:	6a 7c                	push   $0x7c
  8014eb:	68 54 28 80 00       	push   $0x802854
  8014f0:	e8 e6 eb ff ff       	call   8000db <_panic>
	assert(r <= PGSIZE);
  8014f5:	68 5f 28 80 00       	push   $0x80285f
  8014fa:	68 3f 28 80 00       	push   $0x80283f
  8014ff:	6a 7d                	push   $0x7d
  801501:	68 54 28 80 00       	push   $0x802854
  801506:	e8 d0 eb ff ff       	call   8000db <_panic>

0080150b <open>:
{
  80150b:	55                   	push   %ebp
  80150c:	89 e5                	mov    %esp,%ebp
  80150e:	56                   	push   %esi
  80150f:	53                   	push   %ebx
  801510:	83 ec 1c             	sub    $0x1c,%esp
  801513:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801516:	56                   	push   %esi
  801517:	e8 82 f2 ff ff       	call   80079e <strlen>
  80151c:	83 c4 10             	add    $0x10,%esp
  80151f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801524:	7f 6c                	jg     801592 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801526:	83 ec 0c             	sub    $0xc,%esp
  801529:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80152c:	50                   	push   %eax
  80152d:	e8 b4 f8 ff ff       	call   800de6 <fd_alloc>
  801532:	89 c3                	mov    %eax,%ebx
  801534:	83 c4 10             	add    $0x10,%esp
  801537:	85 c0                	test   %eax,%eax
  801539:	78 3c                	js     801577 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  80153b:	83 ec 08             	sub    $0x8,%esp
  80153e:	56                   	push   %esi
  80153f:	68 00 50 80 00       	push   $0x805000
  801544:	e8 8c f2 ff ff       	call   8007d5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801549:	8b 45 0c             	mov    0xc(%ebp),%eax
  80154c:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801551:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801554:	b8 01 00 00 00       	mov    $0x1,%eax
  801559:	e8 f3 fd ff ff       	call   801351 <fsipc>
  80155e:	89 c3                	mov    %eax,%ebx
  801560:	83 c4 10             	add    $0x10,%esp
  801563:	85 c0                	test   %eax,%eax
  801565:	78 19                	js     801580 <open+0x75>
	return fd2num(fd);
  801567:	83 ec 0c             	sub    $0xc,%esp
  80156a:	ff 75 f4             	pushl  -0xc(%ebp)
  80156d:	e8 4d f8 ff ff       	call   800dbf <fd2num>
  801572:	89 c3                	mov    %eax,%ebx
  801574:	83 c4 10             	add    $0x10,%esp
}
  801577:	89 d8                	mov    %ebx,%eax
  801579:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80157c:	5b                   	pop    %ebx
  80157d:	5e                   	pop    %esi
  80157e:	5d                   	pop    %ebp
  80157f:	c3                   	ret    
		fd_close(fd, 0);
  801580:	83 ec 08             	sub    $0x8,%esp
  801583:	6a 00                	push   $0x0
  801585:	ff 75 f4             	pushl  -0xc(%ebp)
  801588:	e8 54 f9 ff ff       	call   800ee1 <fd_close>
		return r;
  80158d:	83 c4 10             	add    $0x10,%esp
  801590:	eb e5                	jmp    801577 <open+0x6c>
		return -E_BAD_PATH;
  801592:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801597:	eb de                	jmp    801577 <open+0x6c>

00801599 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801599:	55                   	push   %ebp
  80159a:	89 e5                	mov    %esp,%ebp
  80159c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80159f:	ba 00 00 00 00       	mov    $0x0,%edx
  8015a4:	b8 08 00 00 00       	mov    $0x8,%eax
  8015a9:	e8 a3 fd ff ff       	call   801351 <fsipc>
}
  8015ae:	c9                   	leave  
  8015af:	c3                   	ret    

008015b0 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8015b0:	55                   	push   %ebp
  8015b1:	89 e5                	mov    %esp,%ebp
  8015b3:	57                   	push   %edi
  8015b4:	56                   	push   %esi
  8015b5:	53                   	push   %ebx
  8015b6:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8015bc:	6a 00                	push   $0x0
  8015be:	ff 75 08             	pushl  0x8(%ebp)
  8015c1:	e8 45 ff ff ff       	call   80150b <open>
  8015c6:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  8015cc:	83 c4 10             	add    $0x10,%esp
  8015cf:	85 c0                	test   %eax,%eax
  8015d1:	0f 88 40 03 00 00    	js     801917 <spawn+0x367>
  8015d7:	89 c2                	mov    %eax,%edx
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8015d9:	83 ec 04             	sub    $0x4,%esp
  8015dc:	68 00 02 00 00       	push   $0x200
  8015e1:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8015e7:	50                   	push   %eax
  8015e8:	52                   	push   %edx
  8015e9:	e8 3f fb ff ff       	call   80112d <readn>
  8015ee:	83 c4 10             	add    $0x10,%esp
  8015f1:	3d 00 02 00 00       	cmp    $0x200,%eax
  8015f6:	75 5d                	jne    801655 <spawn+0xa5>
	    || elf->e_magic != ELF_MAGIC) {
  8015f8:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8015ff:	45 4c 46 
  801602:	75 51                	jne    801655 <spawn+0xa5>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801604:	b8 07 00 00 00       	mov    $0x7,%eax
  801609:	cd 30                	int    $0x30
  80160b:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801611:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801617:	85 c0                	test   %eax,%eax
  801619:	0f 88 6e 04 00 00    	js     801a8d <spawn+0x4dd>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  80161f:	25 ff 03 00 00       	and    $0x3ff,%eax
  801624:	6b f0 7c             	imul   $0x7c,%eax,%esi
  801627:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  80162d:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801633:	b9 11 00 00 00       	mov    $0x11,%ecx
  801638:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  80163a:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801640:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801646:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  80164b:	be 00 00 00 00       	mov    $0x0,%esi
  801650:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801653:	eb 4b                	jmp    8016a0 <spawn+0xf0>
		close(fd);
  801655:	83 ec 0c             	sub    $0xc,%esp
  801658:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  80165e:	e8 07 f9 ff ff       	call   800f6a <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801663:	83 c4 0c             	add    $0xc,%esp
  801666:	68 7f 45 4c 46       	push   $0x464c457f
  80166b:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801671:	68 6b 28 80 00       	push   $0x80286b
  801676:	e8 3b eb ff ff       	call   8001b6 <cprintf>
		return -E_NOT_EXEC;
  80167b:	83 c4 10             	add    $0x10,%esp
  80167e:	c7 85 90 fd ff ff f2 	movl   $0xfffffff2,-0x270(%ebp)
  801685:	ff ff ff 
  801688:	e9 8a 02 00 00       	jmp    801917 <spawn+0x367>
		string_size += strlen(argv[argc]) + 1;
  80168d:	83 ec 0c             	sub    $0xc,%esp
  801690:	50                   	push   %eax
  801691:	e8 08 f1 ff ff       	call   80079e <strlen>
  801696:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  80169a:	83 c3 01             	add    $0x1,%ebx
  80169d:	83 c4 10             	add    $0x10,%esp
  8016a0:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8016a7:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8016aa:	85 c0                	test   %eax,%eax
  8016ac:	75 df                	jne    80168d <spawn+0xdd>
  8016ae:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  8016b4:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8016ba:	bf 00 10 40 00       	mov    $0x401000,%edi
  8016bf:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8016c1:	89 fa                	mov    %edi,%edx
  8016c3:	83 e2 fc             	and    $0xfffffffc,%edx
  8016c6:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8016cd:	29 c2                	sub    %eax,%edx
  8016cf:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8016d5:	8d 42 f8             	lea    -0x8(%edx),%eax
  8016d8:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8016dd:	0f 86 bb 03 00 00    	jbe    801a9e <spawn+0x4ee>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8016e3:	83 ec 04             	sub    $0x4,%esp
  8016e6:	6a 07                	push   $0x7
  8016e8:	68 00 00 40 00       	push   $0x400000
  8016ed:	6a 00                	push   $0x0
  8016ef:	e8 da f4 ff ff       	call   800bce <sys_page_alloc>
  8016f4:	83 c4 10             	add    $0x10,%esp
  8016f7:	85 c0                	test   %eax,%eax
  8016f9:	0f 88 a4 03 00 00    	js     801aa3 <spawn+0x4f3>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8016ff:	be 00 00 00 00       	mov    $0x0,%esi
  801704:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  80170a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80170d:	eb 30                	jmp    80173f <spawn+0x18f>
		argv_store[i] = UTEMP2USTACK(string_store);
  80170f:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801715:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  80171b:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  80171e:	83 ec 08             	sub    $0x8,%esp
  801721:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801724:	57                   	push   %edi
  801725:	e8 ab f0 ff ff       	call   8007d5 <strcpy>
		string_store += strlen(argv[i]) + 1;
  80172a:	83 c4 04             	add    $0x4,%esp
  80172d:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801730:	e8 69 f0 ff ff       	call   80079e <strlen>
  801735:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  801739:	83 c6 01             	add    $0x1,%esi
  80173c:	83 c4 10             	add    $0x10,%esp
  80173f:	39 b5 8c fd ff ff    	cmp    %esi,-0x274(%ebp)
  801745:	7f c8                	jg     80170f <spawn+0x15f>
	}
	argv_store[argc] = 0;
  801747:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  80174d:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801753:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  80175a:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801760:	0f 85 8c 00 00 00    	jne    8017f2 <spawn+0x242>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801766:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  80176c:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801772:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801775:	89 f8                	mov    %edi,%eax
  801777:	8b bd 88 fd ff ff    	mov    -0x278(%ebp),%edi
  80177d:	89 78 f8             	mov    %edi,-0x8(%eax)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801780:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801785:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  80178b:	83 ec 0c             	sub    $0xc,%esp
  80178e:	6a 07                	push   $0x7
  801790:	68 00 d0 bf ee       	push   $0xeebfd000
  801795:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80179b:	68 00 00 40 00       	push   $0x400000
  8017a0:	6a 00                	push   $0x0
  8017a2:	e8 6a f4 ff ff       	call   800c11 <sys_page_map>
  8017a7:	89 c3                	mov    %eax,%ebx
  8017a9:	83 c4 20             	add    $0x20,%esp
  8017ac:	85 c0                	test   %eax,%eax
  8017ae:	0f 88 65 03 00 00    	js     801b19 <spawn+0x569>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8017b4:	83 ec 08             	sub    $0x8,%esp
  8017b7:	68 00 00 40 00       	push   $0x400000
  8017bc:	6a 00                	push   $0x0
  8017be:	e8 90 f4 ff ff       	call   800c53 <sys_page_unmap>
  8017c3:	89 c3                	mov    %eax,%ebx
  8017c5:	83 c4 10             	add    $0x10,%esp
  8017c8:	85 c0                	test   %eax,%eax
  8017ca:	0f 88 49 03 00 00    	js     801b19 <spawn+0x569>
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8017d0:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  8017d6:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  8017dd:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8017e3:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  8017ea:	00 00 00 
  8017ed:	e9 56 01 00 00       	jmp    801948 <spawn+0x398>
	assert(string_store == (char*)UTEMP + PGSIZE);
  8017f2:	68 f8 28 80 00       	push   $0x8028f8
  8017f7:	68 3f 28 80 00       	push   $0x80283f
  8017fc:	68 f2 00 00 00       	push   $0xf2
  801801:	68 85 28 80 00       	push   $0x802885
  801806:	e8 d0 e8 ff ff       	call   8000db <_panic>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80180b:	83 ec 04             	sub    $0x4,%esp
  80180e:	6a 07                	push   $0x7
  801810:	68 00 00 40 00       	push   $0x400000
  801815:	6a 00                	push   $0x0
  801817:	e8 b2 f3 ff ff       	call   800bce <sys_page_alloc>
  80181c:	83 c4 10             	add    $0x10,%esp
  80181f:	85 c0                	test   %eax,%eax
  801821:	0f 88 87 02 00 00    	js     801aae <spawn+0x4fe>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801827:	83 ec 08             	sub    $0x8,%esp
  80182a:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801830:	01 f0                	add    %esi,%eax
  801832:	50                   	push   %eax
  801833:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801839:	e8 b8 f9 ff ff       	call   8011f6 <seek>
  80183e:	83 c4 10             	add    $0x10,%esp
  801841:	85 c0                	test   %eax,%eax
  801843:	0f 88 6c 02 00 00    	js     801ab5 <spawn+0x505>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801849:	83 ec 04             	sub    $0x4,%esp
  80184c:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801852:	29 f0                	sub    %esi,%eax
  801854:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801859:	b9 00 10 00 00       	mov    $0x1000,%ecx
  80185e:	0f 47 c1             	cmova  %ecx,%eax
  801861:	50                   	push   %eax
  801862:	68 00 00 40 00       	push   $0x400000
  801867:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  80186d:	e8 bb f8 ff ff       	call   80112d <readn>
  801872:	83 c4 10             	add    $0x10,%esp
  801875:	85 c0                	test   %eax,%eax
  801877:	0f 88 3f 02 00 00    	js     801abc <spawn+0x50c>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  80187d:	83 ec 0c             	sub    $0xc,%esp
  801880:	57                   	push   %edi
  801881:	03 b5 88 fd ff ff    	add    -0x278(%ebp),%esi
  801887:	56                   	push   %esi
  801888:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  80188e:	68 00 00 40 00       	push   $0x400000
  801893:	6a 00                	push   $0x0
  801895:	e8 77 f3 ff ff       	call   800c11 <sys_page_map>
  80189a:	83 c4 20             	add    $0x20,%esp
  80189d:	85 c0                	test   %eax,%eax
  80189f:	0f 88 80 00 00 00    	js     801925 <spawn+0x375>
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
  8018a5:	83 ec 08             	sub    $0x8,%esp
  8018a8:	68 00 00 40 00       	push   $0x400000
  8018ad:	6a 00                	push   $0x0
  8018af:	e8 9f f3 ff ff       	call   800c53 <sys_page_unmap>
  8018b4:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < memsz; i += PGSIZE) {
  8018b7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8018bd:	89 de                	mov    %ebx,%esi
  8018bf:	39 9d 8c fd ff ff    	cmp    %ebx,-0x274(%ebp)
  8018c5:	76 73                	jbe    80193a <spawn+0x38a>
		if (i >= filesz) {
  8018c7:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  8018cd:	0f 87 38 ff ff ff    	ja     80180b <spawn+0x25b>
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  8018d3:	83 ec 04             	sub    $0x4,%esp
  8018d6:	57                   	push   %edi
  8018d7:	03 b5 88 fd ff ff    	add    -0x278(%ebp),%esi
  8018dd:	56                   	push   %esi
  8018de:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8018e4:	e8 e5 f2 ff ff       	call   800bce <sys_page_alloc>
  8018e9:	83 c4 10             	add    $0x10,%esp
  8018ec:	85 c0                	test   %eax,%eax
  8018ee:	79 c7                	jns    8018b7 <spawn+0x307>
  8018f0:	89 c7                	mov    %eax,%edi
	sys_env_destroy(child);
  8018f2:	83 ec 0c             	sub    $0xc,%esp
  8018f5:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8018fb:	e8 4f f2 ff ff       	call   800b4f <sys_env_destroy>
	close(fd);
  801900:	83 c4 04             	add    $0x4,%esp
  801903:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801909:	e8 5c f6 ff ff       	call   800f6a <close>
	return r;
  80190e:	83 c4 10             	add    $0x10,%esp
  801911:	89 bd 90 fd ff ff    	mov    %edi,-0x270(%ebp)
}
  801917:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  80191d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801920:	5b                   	pop    %ebx
  801921:	5e                   	pop    %esi
  801922:	5f                   	pop    %edi
  801923:	5d                   	pop    %ebp
  801924:	c3                   	ret    
				panic("spawn: sys_page_map data: %e", r);
  801925:	50                   	push   %eax
  801926:	68 91 28 80 00       	push   $0x802891
  80192b:	68 25 01 00 00       	push   $0x125
  801930:	68 85 28 80 00       	push   $0x802885
  801935:	e8 a1 e7 ff ff       	call   8000db <_panic>
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80193a:	83 85 7c fd ff ff 01 	addl   $0x1,-0x284(%ebp)
  801941:	83 85 78 fd ff ff 20 	addl   $0x20,-0x288(%ebp)
  801948:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  80194f:	3b 85 7c fd ff ff    	cmp    -0x284(%ebp),%eax
  801955:	7e 71                	jle    8019c8 <spawn+0x418>
		if (ph->p_type != ELF_PROG_LOAD)
  801957:	8b 8d 78 fd ff ff    	mov    -0x288(%ebp),%ecx
  80195d:	83 39 01             	cmpl   $0x1,(%ecx)
  801960:	75 d8                	jne    80193a <spawn+0x38a>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801962:	8b 41 18             	mov    0x18(%ecx),%eax
  801965:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801968:	83 f8 01             	cmp    $0x1,%eax
  80196b:	19 ff                	sbb    %edi,%edi
  80196d:	83 e7 fe             	and    $0xfffffffe,%edi
  801970:	83 c7 07             	add    $0x7,%edi
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801973:	8b 71 04             	mov    0x4(%ecx),%esi
  801976:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  80197c:	8b 59 10             	mov    0x10(%ecx),%ebx
  80197f:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801985:	8b 41 14             	mov    0x14(%ecx),%eax
  801988:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  80198e:	8b 51 08             	mov    0x8(%ecx),%edx
  801991:	89 95 88 fd ff ff    	mov    %edx,-0x278(%ebp)
	if ((i = PGOFF(va))) {
  801997:	89 d0                	mov    %edx,%eax
  801999:	25 ff 0f 00 00       	and    $0xfff,%eax
  80199e:	74 1e                	je     8019be <spawn+0x40e>
		va -= i;
  8019a0:	29 c2                	sub    %eax,%edx
  8019a2:	89 95 88 fd ff ff    	mov    %edx,-0x278(%ebp)
		memsz += i;
  8019a8:	01 85 8c fd ff ff    	add    %eax,-0x274(%ebp)
		filesz += i;
  8019ae:	01 c3                	add    %eax,%ebx
  8019b0:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
		fileoffset -= i;
  8019b6:	29 c6                	sub    %eax,%esi
  8019b8:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
	for (i = 0; i < memsz; i += PGSIZE) {
  8019be:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019c3:	e9 f5 fe ff ff       	jmp    8018bd <spawn+0x30d>
	close(fd);
  8019c8:	83 ec 0c             	sub    $0xc,%esp
  8019cb:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  8019d1:	e8 94 f5 ff ff       	call   800f6a <close>
  8019d6:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	uintptr_t addr;
	int r;

	for(addr=(uintptr_t)UTEXT; addr<USTACKTOP;addr+=PGSIZE){
  8019d9:	bb 00 00 80 00       	mov    $0x800000,%ebx
  8019de:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
  8019e4:	eb 12                	jmp    8019f8 <spawn+0x448>
  8019e6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8019ec:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8019f2:	0f 84 cb 00 00 00    	je     801ac3 <spawn+0x513>
	   if((uvpd[PDX(addr)]&PTE_P) && (uvpt[PGNUM(addr)]&PTE_P)){
  8019f8:	89 d8                	mov    %ebx,%eax
  8019fa:	c1 e8 16             	shr    $0x16,%eax
  8019fd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801a04:	a8 01                	test   $0x1,%al
  801a06:	74 de                	je     8019e6 <spawn+0x436>
  801a08:	89 d8                	mov    %ebx,%eax
  801a0a:	c1 e8 0c             	shr    $0xc,%eax
  801a0d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801a14:	f6 c2 01             	test   $0x1,%dl
  801a17:	74 cd                	je     8019e6 <spawn+0x436>
	      if(uvpt[PGNUM(addr)] & PTE_SHARE){
  801a19:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801a20:	f6 c6 04             	test   $0x4,%dh
  801a23:	74 c1                	je     8019e6 <spawn+0x436>
	        if((r=sys_page_map(thisenv->env_id,(void *)addr,child,(void *)addr, uvpt[PGNUM(addr)]&PTE_SYSCALL))<0)
  801a25:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a2c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a32:	8b 52 48             	mov    0x48(%edx),%edx
  801a35:	83 ec 0c             	sub    $0xc,%esp
  801a38:	25 07 0e 00 00       	and    $0xe07,%eax
  801a3d:	50                   	push   %eax
  801a3e:	53                   	push   %ebx
  801a3f:	56                   	push   %esi
  801a40:	53                   	push   %ebx
  801a41:	52                   	push   %edx
  801a42:	e8 ca f1 ff ff       	call   800c11 <sys_page_map>
  801a47:	83 c4 20             	add    $0x20,%esp
  801a4a:	85 c0                	test   %eax,%eax
  801a4c:	79 98                	jns    8019e6 <spawn+0x436>
		panic("copy_shared_pages: %e", r);
  801a4e:	50                   	push   %eax
  801a4f:	68 df 28 80 00       	push   $0x8028df
  801a54:	68 82 00 00 00       	push   $0x82
  801a59:	68 85 28 80 00       	push   $0x802885
  801a5e:	e8 78 e6 ff ff       	call   8000db <_panic>
		panic("sys_env_set_trapframe: %e", r);
  801a63:	50                   	push   %eax
  801a64:	68 ae 28 80 00       	push   $0x8028ae
  801a69:	68 86 00 00 00       	push   $0x86
  801a6e:	68 85 28 80 00       	push   $0x802885
  801a73:	e8 63 e6 ff ff       	call   8000db <_panic>
		panic("sys_env_set_status: %e", r);
  801a78:	50                   	push   %eax
  801a79:	68 c8 28 80 00       	push   $0x8028c8
  801a7e:	68 89 00 00 00       	push   $0x89
  801a83:	68 85 28 80 00       	push   $0x802885
  801a88:	e8 4e e6 ff ff       	call   8000db <_panic>
		return r;
  801a8d:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801a93:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  801a99:	e9 79 fe ff ff       	jmp    801917 <spawn+0x367>
		return -E_NO_MEM;
  801a9e:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return r;
  801aa3:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  801aa9:	e9 69 fe ff ff       	jmp    801917 <spawn+0x367>
  801aae:	89 c7                	mov    %eax,%edi
  801ab0:	e9 3d fe ff ff       	jmp    8018f2 <spawn+0x342>
  801ab5:	89 c7                	mov    %eax,%edi
  801ab7:	e9 36 fe ff ff       	jmp    8018f2 <spawn+0x342>
  801abc:	89 c7                	mov    %eax,%edi
  801abe:	e9 2f fe ff ff       	jmp    8018f2 <spawn+0x342>
	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801ac3:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801aca:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801acd:	83 ec 08             	sub    $0x8,%esp
  801ad0:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801ad6:	50                   	push   %eax
  801ad7:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801add:	e8 f5 f1 ff ff       	call   800cd7 <sys_env_set_trapframe>
  801ae2:	83 c4 10             	add    $0x10,%esp
  801ae5:	85 c0                	test   %eax,%eax
  801ae7:	0f 88 76 ff ff ff    	js     801a63 <spawn+0x4b3>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801aed:	83 ec 08             	sub    $0x8,%esp
  801af0:	6a 02                	push   $0x2
  801af2:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801af8:	e8 98 f1 ff ff       	call   800c95 <sys_env_set_status>
  801afd:	83 c4 10             	add    $0x10,%esp
  801b00:	85 c0                	test   %eax,%eax
  801b02:	0f 88 70 ff ff ff    	js     801a78 <spawn+0x4c8>
	return child;
  801b08:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801b0e:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  801b14:	e9 fe fd ff ff       	jmp    801917 <spawn+0x367>
	sys_page_unmap(0, UTEMP);
  801b19:	83 ec 08             	sub    $0x8,%esp
  801b1c:	68 00 00 40 00       	push   $0x400000
  801b21:	6a 00                	push   $0x0
  801b23:	e8 2b f1 ff ff       	call   800c53 <sys_page_unmap>
  801b28:	83 c4 10             	add    $0x10,%esp
  801b2b:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801b31:	e9 e1 fd ff ff       	jmp    801917 <spawn+0x367>

00801b36 <spawnl>:
{
  801b36:	55                   	push   %ebp
  801b37:	89 e5                	mov    %esp,%ebp
  801b39:	57                   	push   %edi
  801b3a:	56                   	push   %esi
  801b3b:	53                   	push   %ebx
  801b3c:	83 ec 0c             	sub    $0xc,%esp
	va_start(vl, arg0);
  801b3f:	8d 55 10             	lea    0x10(%ebp),%edx
	int argc=0;
  801b42:	b8 00 00 00 00       	mov    $0x0,%eax
	while(va_arg(vl, void *) != NULL)
  801b47:	eb 05                	jmp    801b4e <spawnl+0x18>
		argc++;
  801b49:	83 c0 01             	add    $0x1,%eax
	while(va_arg(vl, void *) != NULL)
  801b4c:	89 ca                	mov    %ecx,%edx
  801b4e:	8d 4a 04             	lea    0x4(%edx),%ecx
  801b51:	83 3a 00             	cmpl   $0x0,(%edx)
  801b54:	75 f3                	jne    801b49 <spawnl+0x13>
	const char *argv[argc+2];
  801b56:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801b5d:	83 e2 f0             	and    $0xfffffff0,%edx
  801b60:	29 d4                	sub    %edx,%esp
  801b62:	8d 54 24 03          	lea    0x3(%esp),%edx
  801b66:	c1 ea 02             	shr    $0x2,%edx
  801b69:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801b70:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801b72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b75:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801b7c:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801b83:	00 
	va_start(vl, arg0);
  801b84:	8d 4d 10             	lea    0x10(%ebp),%ecx
  801b87:	89 c2                	mov    %eax,%edx
	for(i=0;i<argc;i++)
  801b89:	b8 00 00 00 00       	mov    $0x0,%eax
  801b8e:	eb 0b                	jmp    801b9b <spawnl+0x65>
		argv[i+1] = va_arg(vl, const char *);
  801b90:	83 c0 01             	add    $0x1,%eax
  801b93:	8b 39                	mov    (%ecx),%edi
  801b95:	89 3c 83             	mov    %edi,(%ebx,%eax,4)
  801b98:	8d 49 04             	lea    0x4(%ecx),%ecx
	for(i=0;i<argc;i++)
  801b9b:	39 d0                	cmp    %edx,%eax
  801b9d:	75 f1                	jne    801b90 <spawnl+0x5a>
	return spawn(prog, argv);
  801b9f:	83 ec 08             	sub    $0x8,%esp
  801ba2:	56                   	push   %esi
  801ba3:	ff 75 08             	pushl  0x8(%ebp)
  801ba6:	e8 05 fa ff ff       	call   8015b0 <spawn>
}
  801bab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bae:	5b                   	pop    %ebx
  801baf:	5e                   	pop    %esi
  801bb0:	5f                   	pop    %edi
  801bb1:	5d                   	pop    %ebp
  801bb2:	c3                   	ret    

00801bb3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801bb3:	55                   	push   %ebp
  801bb4:	89 e5                	mov    %esp,%ebp
  801bb6:	56                   	push   %esi
  801bb7:	53                   	push   %ebx
  801bb8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801bbb:	83 ec 0c             	sub    $0xc,%esp
  801bbe:	ff 75 08             	pushl  0x8(%ebp)
  801bc1:	e8 09 f2 ff ff       	call   800dcf <fd2data>
  801bc6:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801bc8:	83 c4 08             	add    $0x8,%esp
  801bcb:	68 20 29 80 00       	push   $0x802920
  801bd0:	53                   	push   %ebx
  801bd1:	e8 ff eb ff ff       	call   8007d5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801bd6:	8b 46 04             	mov    0x4(%esi),%eax
  801bd9:	2b 06                	sub    (%esi),%eax
  801bdb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801be1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801be8:	00 00 00 
	stat->st_dev = &devpipe;
  801beb:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801bf2:	30 80 00 
	return 0;
}
  801bf5:	b8 00 00 00 00       	mov    $0x0,%eax
  801bfa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bfd:	5b                   	pop    %ebx
  801bfe:	5e                   	pop    %esi
  801bff:	5d                   	pop    %ebp
  801c00:	c3                   	ret    

00801c01 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c01:	55                   	push   %ebp
  801c02:	89 e5                	mov    %esp,%ebp
  801c04:	53                   	push   %ebx
  801c05:	83 ec 0c             	sub    $0xc,%esp
  801c08:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c0b:	53                   	push   %ebx
  801c0c:	6a 00                	push   $0x0
  801c0e:	e8 40 f0 ff ff       	call   800c53 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c13:	89 1c 24             	mov    %ebx,(%esp)
  801c16:	e8 b4 f1 ff ff       	call   800dcf <fd2data>
  801c1b:	83 c4 08             	add    $0x8,%esp
  801c1e:	50                   	push   %eax
  801c1f:	6a 00                	push   $0x0
  801c21:	e8 2d f0 ff ff       	call   800c53 <sys_page_unmap>
}
  801c26:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c29:	c9                   	leave  
  801c2a:	c3                   	ret    

00801c2b <_pipeisclosed>:
{
  801c2b:	55                   	push   %ebp
  801c2c:	89 e5                	mov    %esp,%ebp
  801c2e:	57                   	push   %edi
  801c2f:	56                   	push   %esi
  801c30:	53                   	push   %ebx
  801c31:	83 ec 1c             	sub    $0x1c,%esp
  801c34:	89 c7                	mov    %eax,%edi
  801c36:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801c38:	a1 04 40 80 00       	mov    0x804004,%eax
  801c3d:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801c40:	83 ec 0c             	sub    $0xc,%esp
  801c43:	57                   	push   %edi
  801c44:	e8 38 05 00 00       	call   802181 <pageref>
  801c49:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801c4c:	89 34 24             	mov    %esi,(%esp)
  801c4f:	e8 2d 05 00 00       	call   802181 <pageref>
		nn = thisenv->env_runs;
  801c54:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801c5a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c5d:	83 c4 10             	add    $0x10,%esp
  801c60:	39 cb                	cmp    %ecx,%ebx
  801c62:	74 1b                	je     801c7f <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801c64:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801c67:	75 cf                	jne    801c38 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c69:	8b 42 58             	mov    0x58(%edx),%eax
  801c6c:	6a 01                	push   $0x1
  801c6e:	50                   	push   %eax
  801c6f:	53                   	push   %ebx
  801c70:	68 27 29 80 00       	push   $0x802927
  801c75:	e8 3c e5 ff ff       	call   8001b6 <cprintf>
  801c7a:	83 c4 10             	add    $0x10,%esp
  801c7d:	eb b9                	jmp    801c38 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801c7f:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801c82:	0f 94 c0             	sete   %al
  801c85:	0f b6 c0             	movzbl %al,%eax
}
  801c88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c8b:	5b                   	pop    %ebx
  801c8c:	5e                   	pop    %esi
  801c8d:	5f                   	pop    %edi
  801c8e:	5d                   	pop    %ebp
  801c8f:	c3                   	ret    

00801c90 <devpipe_write>:
{
  801c90:	55                   	push   %ebp
  801c91:	89 e5                	mov    %esp,%ebp
  801c93:	57                   	push   %edi
  801c94:	56                   	push   %esi
  801c95:	53                   	push   %ebx
  801c96:	83 ec 28             	sub    $0x28,%esp
  801c99:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801c9c:	56                   	push   %esi
  801c9d:	e8 2d f1 ff ff       	call   800dcf <fd2data>
  801ca2:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801ca4:	83 c4 10             	add    $0x10,%esp
  801ca7:	bf 00 00 00 00       	mov    $0x0,%edi
  801cac:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801caf:	74 4f                	je     801d00 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801cb1:	8b 43 04             	mov    0x4(%ebx),%eax
  801cb4:	8b 0b                	mov    (%ebx),%ecx
  801cb6:	8d 51 20             	lea    0x20(%ecx),%edx
  801cb9:	39 d0                	cmp    %edx,%eax
  801cbb:	72 14                	jb     801cd1 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801cbd:	89 da                	mov    %ebx,%edx
  801cbf:	89 f0                	mov    %esi,%eax
  801cc1:	e8 65 ff ff ff       	call   801c2b <_pipeisclosed>
  801cc6:	85 c0                	test   %eax,%eax
  801cc8:	75 3a                	jne    801d04 <devpipe_write+0x74>
			sys_yield();
  801cca:	e8 e0 ee ff ff       	call   800baf <sys_yield>
  801ccf:	eb e0                	jmp    801cb1 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801cd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cd4:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801cd8:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801cdb:	89 c2                	mov    %eax,%edx
  801cdd:	c1 fa 1f             	sar    $0x1f,%edx
  801ce0:	89 d1                	mov    %edx,%ecx
  801ce2:	c1 e9 1b             	shr    $0x1b,%ecx
  801ce5:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ce8:	83 e2 1f             	and    $0x1f,%edx
  801ceb:	29 ca                	sub    %ecx,%edx
  801ced:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801cf1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801cf5:	83 c0 01             	add    $0x1,%eax
  801cf8:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801cfb:	83 c7 01             	add    $0x1,%edi
  801cfe:	eb ac                	jmp    801cac <devpipe_write+0x1c>
	return i;
  801d00:	89 f8                	mov    %edi,%eax
  801d02:	eb 05                	jmp    801d09 <devpipe_write+0x79>
				return 0;
  801d04:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d09:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d0c:	5b                   	pop    %ebx
  801d0d:	5e                   	pop    %esi
  801d0e:	5f                   	pop    %edi
  801d0f:	5d                   	pop    %ebp
  801d10:	c3                   	ret    

00801d11 <devpipe_read>:
{
  801d11:	55                   	push   %ebp
  801d12:	89 e5                	mov    %esp,%ebp
  801d14:	57                   	push   %edi
  801d15:	56                   	push   %esi
  801d16:	53                   	push   %ebx
  801d17:	83 ec 18             	sub    $0x18,%esp
  801d1a:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801d1d:	57                   	push   %edi
  801d1e:	e8 ac f0 ff ff       	call   800dcf <fd2data>
  801d23:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801d25:	83 c4 10             	add    $0x10,%esp
  801d28:	be 00 00 00 00       	mov    $0x0,%esi
  801d2d:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d30:	74 47                	je     801d79 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  801d32:	8b 03                	mov    (%ebx),%eax
  801d34:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d37:	75 22                	jne    801d5b <devpipe_read+0x4a>
			if (i > 0)
  801d39:	85 f6                	test   %esi,%esi
  801d3b:	75 14                	jne    801d51 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801d3d:	89 da                	mov    %ebx,%edx
  801d3f:	89 f8                	mov    %edi,%eax
  801d41:	e8 e5 fe ff ff       	call   801c2b <_pipeisclosed>
  801d46:	85 c0                	test   %eax,%eax
  801d48:	75 33                	jne    801d7d <devpipe_read+0x6c>
			sys_yield();
  801d4a:	e8 60 ee ff ff       	call   800baf <sys_yield>
  801d4f:	eb e1                	jmp    801d32 <devpipe_read+0x21>
				return i;
  801d51:	89 f0                	mov    %esi,%eax
}
  801d53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d56:	5b                   	pop    %ebx
  801d57:	5e                   	pop    %esi
  801d58:	5f                   	pop    %edi
  801d59:	5d                   	pop    %ebp
  801d5a:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d5b:	99                   	cltd   
  801d5c:	c1 ea 1b             	shr    $0x1b,%edx
  801d5f:	01 d0                	add    %edx,%eax
  801d61:	83 e0 1f             	and    $0x1f,%eax
  801d64:	29 d0                	sub    %edx,%eax
  801d66:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801d6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d6e:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801d71:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801d74:	83 c6 01             	add    $0x1,%esi
  801d77:	eb b4                	jmp    801d2d <devpipe_read+0x1c>
	return i;
  801d79:	89 f0                	mov    %esi,%eax
  801d7b:	eb d6                	jmp    801d53 <devpipe_read+0x42>
				return 0;
  801d7d:	b8 00 00 00 00       	mov    $0x0,%eax
  801d82:	eb cf                	jmp    801d53 <devpipe_read+0x42>

00801d84 <pipe>:
{
  801d84:	55                   	push   %ebp
  801d85:	89 e5                	mov    %esp,%ebp
  801d87:	56                   	push   %esi
  801d88:	53                   	push   %ebx
  801d89:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801d8c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d8f:	50                   	push   %eax
  801d90:	e8 51 f0 ff ff       	call   800de6 <fd_alloc>
  801d95:	89 c3                	mov    %eax,%ebx
  801d97:	83 c4 10             	add    $0x10,%esp
  801d9a:	85 c0                	test   %eax,%eax
  801d9c:	78 5b                	js     801df9 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d9e:	83 ec 04             	sub    $0x4,%esp
  801da1:	68 07 04 00 00       	push   $0x407
  801da6:	ff 75 f4             	pushl  -0xc(%ebp)
  801da9:	6a 00                	push   $0x0
  801dab:	e8 1e ee ff ff       	call   800bce <sys_page_alloc>
  801db0:	89 c3                	mov    %eax,%ebx
  801db2:	83 c4 10             	add    $0x10,%esp
  801db5:	85 c0                	test   %eax,%eax
  801db7:	78 40                	js     801df9 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  801db9:	83 ec 0c             	sub    $0xc,%esp
  801dbc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801dbf:	50                   	push   %eax
  801dc0:	e8 21 f0 ff ff       	call   800de6 <fd_alloc>
  801dc5:	89 c3                	mov    %eax,%ebx
  801dc7:	83 c4 10             	add    $0x10,%esp
  801dca:	85 c0                	test   %eax,%eax
  801dcc:	78 1b                	js     801de9 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dce:	83 ec 04             	sub    $0x4,%esp
  801dd1:	68 07 04 00 00       	push   $0x407
  801dd6:	ff 75 f0             	pushl  -0x10(%ebp)
  801dd9:	6a 00                	push   $0x0
  801ddb:	e8 ee ed ff ff       	call   800bce <sys_page_alloc>
  801de0:	89 c3                	mov    %eax,%ebx
  801de2:	83 c4 10             	add    $0x10,%esp
  801de5:	85 c0                	test   %eax,%eax
  801de7:	79 19                	jns    801e02 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  801de9:	83 ec 08             	sub    $0x8,%esp
  801dec:	ff 75 f4             	pushl  -0xc(%ebp)
  801def:	6a 00                	push   $0x0
  801df1:	e8 5d ee ff ff       	call   800c53 <sys_page_unmap>
  801df6:	83 c4 10             	add    $0x10,%esp
}
  801df9:	89 d8                	mov    %ebx,%eax
  801dfb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dfe:	5b                   	pop    %ebx
  801dff:	5e                   	pop    %esi
  801e00:	5d                   	pop    %ebp
  801e01:	c3                   	ret    
	va = fd2data(fd0);
  801e02:	83 ec 0c             	sub    $0xc,%esp
  801e05:	ff 75 f4             	pushl  -0xc(%ebp)
  801e08:	e8 c2 ef ff ff       	call   800dcf <fd2data>
  801e0d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e0f:	83 c4 0c             	add    $0xc,%esp
  801e12:	68 07 04 00 00       	push   $0x407
  801e17:	50                   	push   %eax
  801e18:	6a 00                	push   $0x0
  801e1a:	e8 af ed ff ff       	call   800bce <sys_page_alloc>
  801e1f:	89 c3                	mov    %eax,%ebx
  801e21:	83 c4 10             	add    $0x10,%esp
  801e24:	85 c0                	test   %eax,%eax
  801e26:	0f 88 8c 00 00 00    	js     801eb8 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e2c:	83 ec 0c             	sub    $0xc,%esp
  801e2f:	ff 75 f0             	pushl  -0x10(%ebp)
  801e32:	e8 98 ef ff ff       	call   800dcf <fd2data>
  801e37:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e3e:	50                   	push   %eax
  801e3f:	6a 00                	push   $0x0
  801e41:	56                   	push   %esi
  801e42:	6a 00                	push   $0x0
  801e44:	e8 c8 ed ff ff       	call   800c11 <sys_page_map>
  801e49:	89 c3                	mov    %eax,%ebx
  801e4b:	83 c4 20             	add    $0x20,%esp
  801e4e:	85 c0                	test   %eax,%eax
  801e50:	78 58                	js     801eaa <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801e52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e55:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e5b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e60:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801e67:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e6a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e70:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e72:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e75:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801e7c:	83 ec 0c             	sub    $0xc,%esp
  801e7f:	ff 75 f4             	pushl  -0xc(%ebp)
  801e82:	e8 38 ef ff ff       	call   800dbf <fd2num>
  801e87:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e8a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e8c:	83 c4 04             	add    $0x4,%esp
  801e8f:	ff 75 f0             	pushl  -0x10(%ebp)
  801e92:	e8 28 ef ff ff       	call   800dbf <fd2num>
  801e97:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e9a:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e9d:	83 c4 10             	add    $0x10,%esp
  801ea0:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ea5:	e9 4f ff ff ff       	jmp    801df9 <pipe+0x75>
	sys_page_unmap(0, va);
  801eaa:	83 ec 08             	sub    $0x8,%esp
  801ead:	56                   	push   %esi
  801eae:	6a 00                	push   $0x0
  801eb0:	e8 9e ed ff ff       	call   800c53 <sys_page_unmap>
  801eb5:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801eb8:	83 ec 08             	sub    $0x8,%esp
  801ebb:	ff 75 f0             	pushl  -0x10(%ebp)
  801ebe:	6a 00                	push   $0x0
  801ec0:	e8 8e ed ff ff       	call   800c53 <sys_page_unmap>
  801ec5:	83 c4 10             	add    $0x10,%esp
  801ec8:	e9 1c ff ff ff       	jmp    801de9 <pipe+0x65>

00801ecd <pipeisclosed>:
{
  801ecd:	55                   	push   %ebp
  801ece:	89 e5                	mov    %esp,%ebp
  801ed0:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ed3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ed6:	50                   	push   %eax
  801ed7:	ff 75 08             	pushl  0x8(%ebp)
  801eda:	e8 56 ef ff ff       	call   800e35 <fd_lookup>
  801edf:	83 c4 10             	add    $0x10,%esp
  801ee2:	85 c0                	test   %eax,%eax
  801ee4:	78 18                	js     801efe <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801ee6:	83 ec 0c             	sub    $0xc,%esp
  801ee9:	ff 75 f4             	pushl  -0xc(%ebp)
  801eec:	e8 de ee ff ff       	call   800dcf <fd2data>
	return _pipeisclosed(fd, p);
  801ef1:	89 c2                	mov    %eax,%edx
  801ef3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef6:	e8 30 fd ff ff       	call   801c2b <_pipeisclosed>
  801efb:	83 c4 10             	add    $0x10,%esp
}
  801efe:	c9                   	leave  
  801eff:	c3                   	ret    

00801f00 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f00:	55                   	push   %ebp
  801f01:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f03:	b8 00 00 00 00       	mov    $0x0,%eax
  801f08:	5d                   	pop    %ebp
  801f09:	c3                   	ret    

00801f0a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f0a:	55                   	push   %ebp
  801f0b:	89 e5                	mov    %esp,%ebp
  801f0d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f10:	68 3f 29 80 00       	push   $0x80293f
  801f15:	ff 75 0c             	pushl  0xc(%ebp)
  801f18:	e8 b8 e8 ff ff       	call   8007d5 <strcpy>
	return 0;
}
  801f1d:	b8 00 00 00 00       	mov    $0x0,%eax
  801f22:	c9                   	leave  
  801f23:	c3                   	ret    

00801f24 <devcons_write>:
{
  801f24:	55                   	push   %ebp
  801f25:	89 e5                	mov    %esp,%ebp
  801f27:	57                   	push   %edi
  801f28:	56                   	push   %esi
  801f29:	53                   	push   %ebx
  801f2a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801f30:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801f35:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801f3b:	eb 2f                	jmp    801f6c <devcons_write+0x48>
		m = n - tot;
  801f3d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f40:	29 f3                	sub    %esi,%ebx
  801f42:	83 fb 7f             	cmp    $0x7f,%ebx
  801f45:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801f4a:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801f4d:	83 ec 04             	sub    $0x4,%esp
  801f50:	53                   	push   %ebx
  801f51:	89 f0                	mov    %esi,%eax
  801f53:	03 45 0c             	add    0xc(%ebp),%eax
  801f56:	50                   	push   %eax
  801f57:	57                   	push   %edi
  801f58:	e8 06 ea ff ff       	call   800963 <memmove>
		sys_cputs(buf, m);
  801f5d:	83 c4 08             	add    $0x8,%esp
  801f60:	53                   	push   %ebx
  801f61:	57                   	push   %edi
  801f62:	e8 ab eb ff ff       	call   800b12 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801f67:	01 de                	add    %ebx,%esi
  801f69:	83 c4 10             	add    $0x10,%esp
  801f6c:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f6f:	72 cc                	jb     801f3d <devcons_write+0x19>
}
  801f71:	89 f0                	mov    %esi,%eax
  801f73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f76:	5b                   	pop    %ebx
  801f77:	5e                   	pop    %esi
  801f78:	5f                   	pop    %edi
  801f79:	5d                   	pop    %ebp
  801f7a:	c3                   	ret    

00801f7b <devcons_read>:
{
  801f7b:	55                   	push   %ebp
  801f7c:	89 e5                	mov    %esp,%ebp
  801f7e:	83 ec 08             	sub    $0x8,%esp
  801f81:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801f86:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f8a:	75 07                	jne    801f93 <devcons_read+0x18>
}
  801f8c:	c9                   	leave  
  801f8d:	c3                   	ret    
		sys_yield();
  801f8e:	e8 1c ec ff ff       	call   800baf <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801f93:	e8 98 eb ff ff       	call   800b30 <sys_cgetc>
  801f98:	85 c0                	test   %eax,%eax
  801f9a:	74 f2                	je     801f8e <devcons_read+0x13>
	if (c < 0)
  801f9c:	85 c0                	test   %eax,%eax
  801f9e:	78 ec                	js     801f8c <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  801fa0:	83 f8 04             	cmp    $0x4,%eax
  801fa3:	74 0c                	je     801fb1 <devcons_read+0x36>
	*(char*)vbuf = c;
  801fa5:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fa8:	88 02                	mov    %al,(%edx)
	return 1;
  801faa:	b8 01 00 00 00       	mov    $0x1,%eax
  801faf:	eb db                	jmp    801f8c <devcons_read+0x11>
		return 0;
  801fb1:	b8 00 00 00 00       	mov    $0x0,%eax
  801fb6:	eb d4                	jmp    801f8c <devcons_read+0x11>

00801fb8 <cputchar>:
{
  801fb8:	55                   	push   %ebp
  801fb9:	89 e5                	mov    %esp,%ebp
  801fbb:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801fbe:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc1:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801fc4:	6a 01                	push   $0x1
  801fc6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fc9:	50                   	push   %eax
  801fca:	e8 43 eb ff ff       	call   800b12 <sys_cputs>
}
  801fcf:	83 c4 10             	add    $0x10,%esp
  801fd2:	c9                   	leave  
  801fd3:	c3                   	ret    

00801fd4 <getchar>:
{
  801fd4:	55                   	push   %ebp
  801fd5:	89 e5                	mov    %esp,%ebp
  801fd7:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801fda:	6a 01                	push   $0x1
  801fdc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fdf:	50                   	push   %eax
  801fe0:	6a 00                	push   $0x0
  801fe2:	e8 bf f0 ff ff       	call   8010a6 <read>
	if (r < 0)
  801fe7:	83 c4 10             	add    $0x10,%esp
  801fea:	85 c0                	test   %eax,%eax
  801fec:	78 08                	js     801ff6 <getchar+0x22>
	if (r < 1)
  801fee:	85 c0                	test   %eax,%eax
  801ff0:	7e 06                	jle    801ff8 <getchar+0x24>
	return c;
  801ff2:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801ff6:	c9                   	leave  
  801ff7:	c3                   	ret    
		return -E_EOF;
  801ff8:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801ffd:	eb f7                	jmp    801ff6 <getchar+0x22>

00801fff <iscons>:
{
  801fff:	55                   	push   %ebp
  802000:	89 e5                	mov    %esp,%ebp
  802002:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802005:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802008:	50                   	push   %eax
  802009:	ff 75 08             	pushl  0x8(%ebp)
  80200c:	e8 24 ee ff ff       	call   800e35 <fd_lookup>
  802011:	83 c4 10             	add    $0x10,%esp
  802014:	85 c0                	test   %eax,%eax
  802016:	78 11                	js     802029 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  802018:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80201b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802021:	39 10                	cmp    %edx,(%eax)
  802023:	0f 94 c0             	sete   %al
  802026:	0f b6 c0             	movzbl %al,%eax
}
  802029:	c9                   	leave  
  80202a:	c3                   	ret    

0080202b <opencons>:
{
  80202b:	55                   	push   %ebp
  80202c:	89 e5                	mov    %esp,%ebp
  80202e:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802031:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802034:	50                   	push   %eax
  802035:	e8 ac ed ff ff       	call   800de6 <fd_alloc>
  80203a:	83 c4 10             	add    $0x10,%esp
  80203d:	85 c0                	test   %eax,%eax
  80203f:	78 3a                	js     80207b <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802041:	83 ec 04             	sub    $0x4,%esp
  802044:	68 07 04 00 00       	push   $0x407
  802049:	ff 75 f4             	pushl  -0xc(%ebp)
  80204c:	6a 00                	push   $0x0
  80204e:	e8 7b eb ff ff       	call   800bce <sys_page_alloc>
  802053:	83 c4 10             	add    $0x10,%esp
  802056:	85 c0                	test   %eax,%eax
  802058:	78 21                	js     80207b <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  80205a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80205d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802063:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802065:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802068:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80206f:	83 ec 0c             	sub    $0xc,%esp
  802072:	50                   	push   %eax
  802073:	e8 47 ed ff ff       	call   800dbf <fd2num>
  802078:	83 c4 10             	add    $0x10,%esp
}
  80207b:	c9                   	leave  
  80207c:	c3                   	ret    

0080207d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80207d:	55                   	push   %ebp
  80207e:	89 e5                	mov    %esp,%ebp
  802080:	56                   	push   %esi
  802081:	53                   	push   %ebx
  802082:	8b 75 08             	mov    0x8(%ebp),%esi
  802085:	8b 45 0c             	mov    0xc(%ebp),%eax
  802088:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        //	panic("ipc_recv not implemented");
        int r;
       	if(pg!=NULL){
  80208b:	85 c0                	test   %eax,%eax
  80208d:	74 3b                	je     8020ca <ipc_recv+0x4d>
	  r = sys_ipc_recv(pg);
  80208f:	83 ec 0c             	sub    $0xc,%esp
  802092:	50                   	push   %eax
  802093:	e8 e6 ec ff ff       	call   800d7e <sys_ipc_recv>
  802098:	83 c4 10             	add    $0x10,%esp
	}else
	  r = sys_ipc_recv((void *)UTOP);
	if(r<0){
  80209b:	85 c0                	test   %eax,%eax
  80209d:	78 3d                	js     8020dc <ipc_recv+0x5f>
	if(perm_store!=NULL){
		*perm_store = 0;
            }
        	return r;
           }else{
	     if(from_env_store!=NULL)
  80209f:	85 f6                	test   %esi,%esi
  8020a1:	74 0a                	je     8020ad <ipc_recv+0x30>
		     *from_env_store = thisenv->env_ipc_from;
  8020a3:	a1 04 40 80 00       	mov    0x804004,%eax
  8020a8:	8b 40 74             	mov    0x74(%eax),%eax
  8020ab:	89 06                	mov    %eax,(%esi)
	     if(perm_store != NULL)
  8020ad:	85 db                	test   %ebx,%ebx
  8020af:	74 0a                	je     8020bb <ipc_recv+0x3e>
		     *perm_store = thisenv->env_ipc_perm;
  8020b1:	a1 04 40 80 00       	mov    0x804004,%eax
  8020b6:	8b 40 78             	mov    0x78(%eax),%eax
  8020b9:	89 03                	mov    %eax,(%ebx)
	     return thisenv->env_ipc_value;
  8020bb:	a1 04 40 80 00       	mov    0x804004,%eax
  8020c0:	8b 40 70             	mov    0x70(%eax),%eax
	   }

}
  8020c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020c6:	5b                   	pop    %ebx
  8020c7:	5e                   	pop    %esi
  8020c8:	5d                   	pop    %ebp
  8020c9:	c3                   	ret    
	  r = sys_ipc_recv((void *)UTOP);
  8020ca:	83 ec 0c             	sub    $0xc,%esp
  8020cd:	68 00 00 c0 ee       	push   $0xeec00000
  8020d2:	e8 a7 ec ff ff       	call   800d7e <sys_ipc_recv>
  8020d7:	83 c4 10             	add    $0x10,%esp
  8020da:	eb bf                	jmp    80209b <ipc_recv+0x1e>
	if(from_env_store!=NULL){
  8020dc:	85 f6                	test   %esi,%esi
  8020de:	74 06                	je     8020e6 <ipc_recv+0x69>
	  *from_env_store = 0;
  8020e0:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if(perm_store!=NULL){
  8020e6:	85 db                	test   %ebx,%ebx
  8020e8:	74 d9                	je     8020c3 <ipc_recv+0x46>
		*perm_store = 0;
  8020ea:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8020f0:	eb d1                	jmp    8020c3 <ipc_recv+0x46>

008020f2 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020f2:	55                   	push   %ebp
  8020f3:	89 e5                	mov    %esp,%ebp
  8020f5:	57                   	push   %edi
  8020f6:	56                   	push   %esi
  8020f7:	53                   	push   %ebx
  8020f8:	83 ec 0c             	sub    $0xc,%esp
  8020fb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020fe:	8b 75 0c             	mov    0xc(%ebp),%esi
  802101:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if(pg==NULL) pg = (void *)UTOP;
  802104:	85 db                	test   %ebx,%ebx
  802106:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80210b:	0f 44 d8             	cmove  %eax,%ebx
	while((r=sys_ipc_try_send(to_env,val,pg,perm))<0){
  80210e:	ff 75 14             	pushl  0x14(%ebp)
  802111:	53                   	push   %ebx
  802112:	56                   	push   %esi
  802113:	57                   	push   %edi
  802114:	e8 42 ec ff ff       	call   800d5b <sys_ipc_try_send>
  802119:	83 c4 10             	add    $0x10,%esp
  80211c:	85 c0                	test   %eax,%eax
  80211e:	79 20                	jns    802140 <ipc_send+0x4e>
	    if(r!=-E_IPC_NOT_RECV){
  802120:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802123:	75 07                	jne    80212c <ipc_send+0x3a>
		    panic("ipc_send:send message failed\n");
	    }
	    sys_yield();
  802125:	e8 85 ea ff ff       	call   800baf <sys_yield>
  80212a:	eb e2                	jmp    80210e <ipc_send+0x1c>
		    panic("ipc_send:send message failed\n");
  80212c:	83 ec 04             	sub    $0x4,%esp
  80212f:	68 4b 29 80 00       	push   $0x80294b
  802134:	6a 43                	push   $0x43
  802136:	68 69 29 80 00       	push   $0x802969
  80213b:	e8 9b df ff ff       	call   8000db <_panic>
	}

}
  802140:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802143:	5b                   	pop    %ebx
  802144:	5e                   	pop    %esi
  802145:	5f                   	pop    %edi
  802146:	5d                   	pop    %ebp
  802147:	c3                   	ret    

00802148 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802148:	55                   	push   %ebp
  802149:	89 e5                	mov    %esp,%ebp
  80214b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80214e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802153:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802156:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80215c:	8b 52 50             	mov    0x50(%edx),%edx
  80215f:	39 ca                	cmp    %ecx,%edx
  802161:	74 11                	je     802174 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  802163:	83 c0 01             	add    $0x1,%eax
  802166:	3d 00 04 00 00       	cmp    $0x400,%eax
  80216b:	75 e6                	jne    802153 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  80216d:	b8 00 00 00 00       	mov    $0x0,%eax
  802172:	eb 0b                	jmp    80217f <ipc_find_env+0x37>
			return envs[i].env_id;
  802174:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802177:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80217c:	8b 40 48             	mov    0x48(%eax),%eax
}
  80217f:	5d                   	pop    %ebp
  802180:	c3                   	ret    

00802181 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802181:	55                   	push   %ebp
  802182:	89 e5                	mov    %esp,%ebp
  802184:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802187:	89 d0                	mov    %edx,%eax
  802189:	c1 e8 16             	shr    $0x16,%eax
  80218c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802193:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  802198:	f6 c1 01             	test   $0x1,%cl
  80219b:	74 1d                	je     8021ba <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  80219d:	c1 ea 0c             	shr    $0xc,%edx
  8021a0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8021a7:	f6 c2 01             	test   $0x1,%dl
  8021aa:	74 0e                	je     8021ba <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021ac:	c1 ea 0c             	shr    $0xc,%edx
  8021af:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021b6:	ef 
  8021b7:	0f b7 c0             	movzwl %ax,%eax
}
  8021ba:	5d                   	pop    %ebp
  8021bb:	c3                   	ret    
  8021bc:	66 90                	xchg   %ax,%ax
  8021be:	66 90                	xchg   %ax,%ax

008021c0 <__udivdi3>:
  8021c0:	55                   	push   %ebp
  8021c1:	57                   	push   %edi
  8021c2:	56                   	push   %esi
  8021c3:	53                   	push   %ebx
  8021c4:	83 ec 1c             	sub    $0x1c,%esp
  8021c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021cb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8021cf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021d3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8021d7:	85 d2                	test   %edx,%edx
  8021d9:	75 35                	jne    802210 <__udivdi3+0x50>
  8021db:	39 f3                	cmp    %esi,%ebx
  8021dd:	0f 87 bd 00 00 00    	ja     8022a0 <__udivdi3+0xe0>
  8021e3:	85 db                	test   %ebx,%ebx
  8021e5:	89 d9                	mov    %ebx,%ecx
  8021e7:	75 0b                	jne    8021f4 <__udivdi3+0x34>
  8021e9:	b8 01 00 00 00       	mov    $0x1,%eax
  8021ee:	31 d2                	xor    %edx,%edx
  8021f0:	f7 f3                	div    %ebx
  8021f2:	89 c1                	mov    %eax,%ecx
  8021f4:	31 d2                	xor    %edx,%edx
  8021f6:	89 f0                	mov    %esi,%eax
  8021f8:	f7 f1                	div    %ecx
  8021fa:	89 c6                	mov    %eax,%esi
  8021fc:	89 e8                	mov    %ebp,%eax
  8021fe:	89 f7                	mov    %esi,%edi
  802200:	f7 f1                	div    %ecx
  802202:	89 fa                	mov    %edi,%edx
  802204:	83 c4 1c             	add    $0x1c,%esp
  802207:	5b                   	pop    %ebx
  802208:	5e                   	pop    %esi
  802209:	5f                   	pop    %edi
  80220a:	5d                   	pop    %ebp
  80220b:	c3                   	ret    
  80220c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802210:	39 f2                	cmp    %esi,%edx
  802212:	77 7c                	ja     802290 <__udivdi3+0xd0>
  802214:	0f bd fa             	bsr    %edx,%edi
  802217:	83 f7 1f             	xor    $0x1f,%edi
  80221a:	0f 84 98 00 00 00    	je     8022b8 <__udivdi3+0xf8>
  802220:	89 f9                	mov    %edi,%ecx
  802222:	b8 20 00 00 00       	mov    $0x20,%eax
  802227:	29 f8                	sub    %edi,%eax
  802229:	d3 e2                	shl    %cl,%edx
  80222b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80222f:	89 c1                	mov    %eax,%ecx
  802231:	89 da                	mov    %ebx,%edx
  802233:	d3 ea                	shr    %cl,%edx
  802235:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802239:	09 d1                	or     %edx,%ecx
  80223b:	89 f2                	mov    %esi,%edx
  80223d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802241:	89 f9                	mov    %edi,%ecx
  802243:	d3 e3                	shl    %cl,%ebx
  802245:	89 c1                	mov    %eax,%ecx
  802247:	d3 ea                	shr    %cl,%edx
  802249:	89 f9                	mov    %edi,%ecx
  80224b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80224f:	d3 e6                	shl    %cl,%esi
  802251:	89 eb                	mov    %ebp,%ebx
  802253:	89 c1                	mov    %eax,%ecx
  802255:	d3 eb                	shr    %cl,%ebx
  802257:	09 de                	or     %ebx,%esi
  802259:	89 f0                	mov    %esi,%eax
  80225b:	f7 74 24 08          	divl   0x8(%esp)
  80225f:	89 d6                	mov    %edx,%esi
  802261:	89 c3                	mov    %eax,%ebx
  802263:	f7 64 24 0c          	mull   0xc(%esp)
  802267:	39 d6                	cmp    %edx,%esi
  802269:	72 0c                	jb     802277 <__udivdi3+0xb7>
  80226b:	89 f9                	mov    %edi,%ecx
  80226d:	d3 e5                	shl    %cl,%ebp
  80226f:	39 c5                	cmp    %eax,%ebp
  802271:	73 5d                	jae    8022d0 <__udivdi3+0x110>
  802273:	39 d6                	cmp    %edx,%esi
  802275:	75 59                	jne    8022d0 <__udivdi3+0x110>
  802277:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80227a:	31 ff                	xor    %edi,%edi
  80227c:	89 fa                	mov    %edi,%edx
  80227e:	83 c4 1c             	add    $0x1c,%esp
  802281:	5b                   	pop    %ebx
  802282:	5e                   	pop    %esi
  802283:	5f                   	pop    %edi
  802284:	5d                   	pop    %ebp
  802285:	c3                   	ret    
  802286:	8d 76 00             	lea    0x0(%esi),%esi
  802289:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802290:	31 ff                	xor    %edi,%edi
  802292:	31 c0                	xor    %eax,%eax
  802294:	89 fa                	mov    %edi,%edx
  802296:	83 c4 1c             	add    $0x1c,%esp
  802299:	5b                   	pop    %ebx
  80229a:	5e                   	pop    %esi
  80229b:	5f                   	pop    %edi
  80229c:	5d                   	pop    %ebp
  80229d:	c3                   	ret    
  80229e:	66 90                	xchg   %ax,%ax
  8022a0:	31 ff                	xor    %edi,%edi
  8022a2:	89 e8                	mov    %ebp,%eax
  8022a4:	89 f2                	mov    %esi,%edx
  8022a6:	f7 f3                	div    %ebx
  8022a8:	89 fa                	mov    %edi,%edx
  8022aa:	83 c4 1c             	add    $0x1c,%esp
  8022ad:	5b                   	pop    %ebx
  8022ae:	5e                   	pop    %esi
  8022af:	5f                   	pop    %edi
  8022b0:	5d                   	pop    %ebp
  8022b1:	c3                   	ret    
  8022b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022b8:	39 f2                	cmp    %esi,%edx
  8022ba:	72 06                	jb     8022c2 <__udivdi3+0x102>
  8022bc:	31 c0                	xor    %eax,%eax
  8022be:	39 eb                	cmp    %ebp,%ebx
  8022c0:	77 d2                	ja     802294 <__udivdi3+0xd4>
  8022c2:	b8 01 00 00 00       	mov    $0x1,%eax
  8022c7:	eb cb                	jmp    802294 <__udivdi3+0xd4>
  8022c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022d0:	89 d8                	mov    %ebx,%eax
  8022d2:	31 ff                	xor    %edi,%edi
  8022d4:	eb be                	jmp    802294 <__udivdi3+0xd4>
  8022d6:	66 90                	xchg   %ax,%ax
  8022d8:	66 90                	xchg   %ax,%ax
  8022da:	66 90                	xchg   %ax,%ax
  8022dc:	66 90                	xchg   %ax,%ax
  8022de:	66 90                	xchg   %ax,%ax

008022e0 <__umoddi3>:
  8022e0:	55                   	push   %ebp
  8022e1:	57                   	push   %edi
  8022e2:	56                   	push   %esi
  8022e3:	53                   	push   %ebx
  8022e4:	83 ec 1c             	sub    $0x1c,%esp
  8022e7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  8022eb:	8b 74 24 30          	mov    0x30(%esp),%esi
  8022ef:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8022f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022f7:	85 ed                	test   %ebp,%ebp
  8022f9:	89 f0                	mov    %esi,%eax
  8022fb:	89 da                	mov    %ebx,%edx
  8022fd:	75 19                	jne    802318 <__umoddi3+0x38>
  8022ff:	39 df                	cmp    %ebx,%edi
  802301:	0f 86 b1 00 00 00    	jbe    8023b8 <__umoddi3+0xd8>
  802307:	f7 f7                	div    %edi
  802309:	89 d0                	mov    %edx,%eax
  80230b:	31 d2                	xor    %edx,%edx
  80230d:	83 c4 1c             	add    $0x1c,%esp
  802310:	5b                   	pop    %ebx
  802311:	5e                   	pop    %esi
  802312:	5f                   	pop    %edi
  802313:	5d                   	pop    %ebp
  802314:	c3                   	ret    
  802315:	8d 76 00             	lea    0x0(%esi),%esi
  802318:	39 dd                	cmp    %ebx,%ebp
  80231a:	77 f1                	ja     80230d <__umoddi3+0x2d>
  80231c:	0f bd cd             	bsr    %ebp,%ecx
  80231f:	83 f1 1f             	xor    $0x1f,%ecx
  802322:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802326:	0f 84 b4 00 00 00    	je     8023e0 <__umoddi3+0x100>
  80232c:	b8 20 00 00 00       	mov    $0x20,%eax
  802331:	89 c2                	mov    %eax,%edx
  802333:	8b 44 24 04          	mov    0x4(%esp),%eax
  802337:	29 c2                	sub    %eax,%edx
  802339:	89 c1                	mov    %eax,%ecx
  80233b:	89 f8                	mov    %edi,%eax
  80233d:	d3 e5                	shl    %cl,%ebp
  80233f:	89 d1                	mov    %edx,%ecx
  802341:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802345:	d3 e8                	shr    %cl,%eax
  802347:	09 c5                	or     %eax,%ebp
  802349:	8b 44 24 04          	mov    0x4(%esp),%eax
  80234d:	89 c1                	mov    %eax,%ecx
  80234f:	d3 e7                	shl    %cl,%edi
  802351:	89 d1                	mov    %edx,%ecx
  802353:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802357:	89 df                	mov    %ebx,%edi
  802359:	d3 ef                	shr    %cl,%edi
  80235b:	89 c1                	mov    %eax,%ecx
  80235d:	89 f0                	mov    %esi,%eax
  80235f:	d3 e3                	shl    %cl,%ebx
  802361:	89 d1                	mov    %edx,%ecx
  802363:	89 fa                	mov    %edi,%edx
  802365:	d3 e8                	shr    %cl,%eax
  802367:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80236c:	09 d8                	or     %ebx,%eax
  80236e:	f7 f5                	div    %ebp
  802370:	d3 e6                	shl    %cl,%esi
  802372:	89 d1                	mov    %edx,%ecx
  802374:	f7 64 24 08          	mull   0x8(%esp)
  802378:	39 d1                	cmp    %edx,%ecx
  80237a:	89 c3                	mov    %eax,%ebx
  80237c:	89 d7                	mov    %edx,%edi
  80237e:	72 06                	jb     802386 <__umoddi3+0xa6>
  802380:	75 0e                	jne    802390 <__umoddi3+0xb0>
  802382:	39 c6                	cmp    %eax,%esi
  802384:	73 0a                	jae    802390 <__umoddi3+0xb0>
  802386:	2b 44 24 08          	sub    0x8(%esp),%eax
  80238a:	19 ea                	sbb    %ebp,%edx
  80238c:	89 d7                	mov    %edx,%edi
  80238e:	89 c3                	mov    %eax,%ebx
  802390:	89 ca                	mov    %ecx,%edx
  802392:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  802397:	29 de                	sub    %ebx,%esi
  802399:	19 fa                	sbb    %edi,%edx
  80239b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80239f:	89 d0                	mov    %edx,%eax
  8023a1:	d3 e0                	shl    %cl,%eax
  8023a3:	89 d9                	mov    %ebx,%ecx
  8023a5:	d3 ee                	shr    %cl,%esi
  8023a7:	d3 ea                	shr    %cl,%edx
  8023a9:	09 f0                	or     %esi,%eax
  8023ab:	83 c4 1c             	add    $0x1c,%esp
  8023ae:	5b                   	pop    %ebx
  8023af:	5e                   	pop    %esi
  8023b0:	5f                   	pop    %edi
  8023b1:	5d                   	pop    %ebp
  8023b2:	c3                   	ret    
  8023b3:	90                   	nop
  8023b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023b8:	85 ff                	test   %edi,%edi
  8023ba:	89 f9                	mov    %edi,%ecx
  8023bc:	75 0b                	jne    8023c9 <__umoddi3+0xe9>
  8023be:	b8 01 00 00 00       	mov    $0x1,%eax
  8023c3:	31 d2                	xor    %edx,%edx
  8023c5:	f7 f7                	div    %edi
  8023c7:	89 c1                	mov    %eax,%ecx
  8023c9:	89 d8                	mov    %ebx,%eax
  8023cb:	31 d2                	xor    %edx,%edx
  8023cd:	f7 f1                	div    %ecx
  8023cf:	89 f0                	mov    %esi,%eax
  8023d1:	f7 f1                	div    %ecx
  8023d3:	e9 31 ff ff ff       	jmp    802309 <__umoddi3+0x29>
  8023d8:	90                   	nop
  8023d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023e0:	39 dd                	cmp    %ebx,%ebp
  8023e2:	72 08                	jb     8023ec <__umoddi3+0x10c>
  8023e4:	39 f7                	cmp    %esi,%edi
  8023e6:	0f 87 21 ff ff ff    	ja     80230d <__umoddi3+0x2d>
  8023ec:	89 da                	mov    %ebx,%edx
  8023ee:	89 f0                	mov    %esi,%eax
  8023f0:	29 f8                	sub    %edi,%eax
  8023f2:	19 ea                	sbb    %ebp,%edx
  8023f4:	e9 14 ff ff ff       	jmp    80230d <__umoddi3+0x2d>
