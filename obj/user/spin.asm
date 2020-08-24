
obj/user/spin:     file format elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 10             	sub    $0x10,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003a:	68 40 13 80 00       	push   $0x801340
  80003f:	e8 5e 01 00 00       	call   8001a2 <cprintf>
	if ((env = fork()) == 0) {
  800044:	e8 fd 0d 00 00       	call   800e46 <fork>
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	85 c0                	test   %eax,%eax
  80004e:	75 12                	jne    800062 <umain+0x2f>
		cprintf("I am the child.  Spinning...\n");
  800050:	83 ec 0c             	sub    $0xc,%esp
  800053:	68 b8 13 80 00       	push   $0x8013b8
  800058:	e8 45 01 00 00       	call   8001a2 <cprintf>
  80005d:	83 c4 10             	add    $0x10,%esp
  800060:	eb fe                	jmp    800060 <umain+0x2d>
  800062:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800064:	83 ec 0c             	sub    $0xc,%esp
  800067:	68 68 13 80 00       	push   $0x801368
  80006c:	e8 31 01 00 00       	call   8001a2 <cprintf>
	sys_yield();
  800071:	e8 25 0b 00 00       	call   800b9b <sys_yield>
	sys_yield();
  800076:	e8 20 0b 00 00       	call   800b9b <sys_yield>
	sys_yield();
  80007b:	e8 1b 0b 00 00       	call   800b9b <sys_yield>
	sys_yield();
  800080:	e8 16 0b 00 00       	call   800b9b <sys_yield>
	sys_yield();
  800085:	e8 11 0b 00 00       	call   800b9b <sys_yield>
	sys_yield();
  80008a:	e8 0c 0b 00 00       	call   800b9b <sys_yield>
	sys_yield();
  80008f:	e8 07 0b 00 00       	call   800b9b <sys_yield>
	sys_yield();
  800094:	e8 02 0b 00 00       	call   800b9b <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  800099:	c7 04 24 90 13 80 00 	movl   $0x801390,(%esp)
  8000a0:	e8 fd 00 00 00       	call   8001a2 <cprintf>
	sys_env_destroy(env);
  8000a5:	89 1c 24             	mov    %ebx,(%esp)
  8000a8:	e8 8e 0a 00 00       	call   800b3b <sys_env_destroy>
}
  8000ad:	83 c4 10             	add    $0x10,%esp
  8000b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000c0:	e8 b7 0a 00 00       	call   800b7c <sys_getenvid>
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d2:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d7:	85 db                	test   %ebx,%ebx
  8000d9:	7e 07                	jle    8000e2 <libmain+0x2d>
		binaryname = argv[0];
  8000db:	8b 06                	mov    (%esi),%eax
  8000dd:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000e2:	83 ec 08             	sub    $0x8,%esp
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	e8 47 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000ec:	e8 0a 00 00 00       	call   8000fb <exit>
}
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5e                   	pop    %esi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800101:	6a 00                	push   $0x0
  800103:	e8 33 0a 00 00       	call   800b3b <sys_env_destroy>
}
  800108:	83 c4 10             	add    $0x10,%esp
  80010b:	c9                   	leave  
  80010c:	c3                   	ret    

0080010d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	53                   	push   %ebx
  800111:	83 ec 04             	sub    $0x4,%esp
  800114:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800117:	8b 13                	mov    (%ebx),%edx
  800119:	8d 42 01             	lea    0x1(%edx),%eax
  80011c:	89 03                	mov    %eax,(%ebx)
  80011e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800121:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800125:	3d ff 00 00 00       	cmp    $0xff,%eax
  80012a:	74 09                	je     800135 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80012c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800130:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800133:	c9                   	leave  
  800134:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800135:	83 ec 08             	sub    $0x8,%esp
  800138:	68 ff 00 00 00       	push   $0xff
  80013d:	8d 43 08             	lea    0x8(%ebx),%eax
  800140:	50                   	push   %eax
  800141:	e8 b8 09 00 00       	call   800afe <sys_cputs>
		b->idx = 0;
  800146:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80014c:	83 c4 10             	add    $0x10,%esp
  80014f:	eb db                	jmp    80012c <putch+0x1f>

00800151 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800151:	55                   	push   %ebp
  800152:	89 e5                	mov    %esp,%ebp
  800154:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80015a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800161:	00 00 00 
	b.cnt = 0;
  800164:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80016b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80016e:	ff 75 0c             	pushl  0xc(%ebp)
  800171:	ff 75 08             	pushl  0x8(%ebp)
  800174:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80017a:	50                   	push   %eax
  80017b:	68 0d 01 80 00       	push   $0x80010d
  800180:	e8 1a 01 00 00       	call   80029f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800185:	83 c4 08             	add    $0x8,%esp
  800188:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80018e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800194:	50                   	push   %eax
  800195:	e8 64 09 00 00       	call   800afe <sys_cputs>

	return b.cnt;
}
  80019a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a0:	c9                   	leave  
  8001a1:	c3                   	ret    

008001a2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a2:	55                   	push   %ebp
  8001a3:	89 e5                	mov    %esp,%ebp
  8001a5:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001a8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001ab:	50                   	push   %eax
  8001ac:	ff 75 08             	pushl  0x8(%ebp)
  8001af:	e8 9d ff ff ff       	call   800151 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001b4:	c9                   	leave  
  8001b5:	c3                   	ret    

008001b6 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001b6:	55                   	push   %ebp
  8001b7:	89 e5                	mov    %esp,%ebp
  8001b9:	57                   	push   %edi
  8001ba:	56                   	push   %esi
  8001bb:	53                   	push   %ebx
  8001bc:	83 ec 1c             	sub    $0x1c,%esp
  8001bf:	89 c7                	mov    %eax,%edi
  8001c1:	89 d6                	mov    %edx,%esi
  8001c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001cc:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001cf:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001d2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001d7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001da:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001dd:	39 d3                	cmp    %edx,%ebx
  8001df:	72 05                	jb     8001e6 <printnum+0x30>
  8001e1:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001e4:	77 7a                	ja     800260 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001e6:	83 ec 0c             	sub    $0xc,%esp
  8001e9:	ff 75 18             	pushl  0x18(%ebp)
  8001ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8001ef:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001f2:	53                   	push   %ebx
  8001f3:	ff 75 10             	pushl  0x10(%ebp)
  8001f6:	83 ec 08             	sub    $0x8,%esp
  8001f9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001fc:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ff:	ff 75 dc             	pushl  -0x24(%ebp)
  800202:	ff 75 d8             	pushl  -0x28(%ebp)
  800205:	e8 f6 0e 00 00       	call   801100 <__udivdi3>
  80020a:	83 c4 18             	add    $0x18,%esp
  80020d:	52                   	push   %edx
  80020e:	50                   	push   %eax
  80020f:	89 f2                	mov    %esi,%edx
  800211:	89 f8                	mov    %edi,%eax
  800213:	e8 9e ff ff ff       	call   8001b6 <printnum>
  800218:	83 c4 20             	add    $0x20,%esp
  80021b:	eb 13                	jmp    800230 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80021d:	83 ec 08             	sub    $0x8,%esp
  800220:	56                   	push   %esi
  800221:	ff 75 18             	pushl  0x18(%ebp)
  800224:	ff d7                	call   *%edi
  800226:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800229:	83 eb 01             	sub    $0x1,%ebx
  80022c:	85 db                	test   %ebx,%ebx
  80022e:	7f ed                	jg     80021d <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800230:	83 ec 08             	sub    $0x8,%esp
  800233:	56                   	push   %esi
  800234:	83 ec 04             	sub    $0x4,%esp
  800237:	ff 75 e4             	pushl  -0x1c(%ebp)
  80023a:	ff 75 e0             	pushl  -0x20(%ebp)
  80023d:	ff 75 dc             	pushl  -0x24(%ebp)
  800240:	ff 75 d8             	pushl  -0x28(%ebp)
  800243:	e8 d8 0f 00 00       	call   801220 <__umoddi3>
  800248:	83 c4 14             	add    $0x14,%esp
  80024b:	0f be 80 e0 13 80 00 	movsbl 0x8013e0(%eax),%eax
  800252:	50                   	push   %eax
  800253:	ff d7                	call   *%edi
}
  800255:	83 c4 10             	add    $0x10,%esp
  800258:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025b:	5b                   	pop    %ebx
  80025c:	5e                   	pop    %esi
  80025d:	5f                   	pop    %edi
  80025e:	5d                   	pop    %ebp
  80025f:	c3                   	ret    
  800260:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800263:	eb c4                	jmp    800229 <printnum+0x73>

00800265 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800265:	55                   	push   %ebp
  800266:	89 e5                	mov    %esp,%ebp
  800268:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80026b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80026f:	8b 10                	mov    (%eax),%edx
  800271:	3b 50 04             	cmp    0x4(%eax),%edx
  800274:	73 0a                	jae    800280 <sprintputch+0x1b>
		*b->buf++ = ch;
  800276:	8d 4a 01             	lea    0x1(%edx),%ecx
  800279:	89 08                	mov    %ecx,(%eax)
  80027b:	8b 45 08             	mov    0x8(%ebp),%eax
  80027e:	88 02                	mov    %al,(%edx)
}
  800280:	5d                   	pop    %ebp
  800281:	c3                   	ret    

00800282 <printfmt>:
{
  800282:	55                   	push   %ebp
  800283:	89 e5                	mov    %esp,%ebp
  800285:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800288:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80028b:	50                   	push   %eax
  80028c:	ff 75 10             	pushl  0x10(%ebp)
  80028f:	ff 75 0c             	pushl  0xc(%ebp)
  800292:	ff 75 08             	pushl  0x8(%ebp)
  800295:	e8 05 00 00 00       	call   80029f <vprintfmt>
}
  80029a:	83 c4 10             	add    $0x10,%esp
  80029d:	c9                   	leave  
  80029e:	c3                   	ret    

0080029f <vprintfmt>:
{
  80029f:	55                   	push   %ebp
  8002a0:	89 e5                	mov    %esp,%ebp
  8002a2:	57                   	push   %edi
  8002a3:	56                   	push   %esi
  8002a4:	53                   	push   %ebx
  8002a5:	83 ec 2c             	sub    $0x2c,%esp
  8002a8:	8b 75 08             	mov    0x8(%ebp),%esi
  8002ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002ae:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002b1:	e9 c1 03 00 00       	jmp    800677 <vprintfmt+0x3d8>
		padc = ' ';
  8002b6:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8002ba:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8002c1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8002c8:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002cf:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002d4:	8d 47 01             	lea    0x1(%edi),%eax
  8002d7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002da:	0f b6 17             	movzbl (%edi),%edx
  8002dd:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002e0:	3c 55                	cmp    $0x55,%al
  8002e2:	0f 87 12 04 00 00    	ja     8006fa <vprintfmt+0x45b>
  8002e8:	0f b6 c0             	movzbl %al,%eax
  8002eb:	ff 24 85 a0 14 80 00 	jmp    *0x8014a0(,%eax,4)
  8002f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002f5:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8002f9:	eb d9                	jmp    8002d4 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8002fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  8002fe:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800302:	eb d0                	jmp    8002d4 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800304:	0f b6 d2             	movzbl %dl,%edx
  800307:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80030a:	b8 00 00 00 00       	mov    $0x0,%eax
  80030f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800312:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800315:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800319:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80031c:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80031f:	83 f9 09             	cmp    $0x9,%ecx
  800322:	77 55                	ja     800379 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800324:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800327:	eb e9                	jmp    800312 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  800329:	8b 45 14             	mov    0x14(%ebp),%eax
  80032c:	8b 00                	mov    (%eax),%eax
  80032e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800331:	8b 45 14             	mov    0x14(%ebp),%eax
  800334:	8d 40 04             	lea    0x4(%eax),%eax
  800337:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80033a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80033d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800341:	79 91                	jns    8002d4 <vprintfmt+0x35>
				width = precision, precision = -1;
  800343:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800346:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800349:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800350:	eb 82                	jmp    8002d4 <vprintfmt+0x35>
  800352:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800355:	85 c0                	test   %eax,%eax
  800357:	ba 00 00 00 00       	mov    $0x0,%edx
  80035c:	0f 49 d0             	cmovns %eax,%edx
  80035f:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800362:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800365:	e9 6a ff ff ff       	jmp    8002d4 <vprintfmt+0x35>
  80036a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80036d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800374:	e9 5b ff ff ff       	jmp    8002d4 <vprintfmt+0x35>
  800379:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80037c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80037f:	eb bc                	jmp    80033d <vprintfmt+0x9e>
			lflag++;
  800381:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800384:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800387:	e9 48 ff ff ff       	jmp    8002d4 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  80038c:	8b 45 14             	mov    0x14(%ebp),%eax
  80038f:	8d 78 04             	lea    0x4(%eax),%edi
  800392:	83 ec 08             	sub    $0x8,%esp
  800395:	53                   	push   %ebx
  800396:	ff 30                	pushl  (%eax)
  800398:	ff d6                	call   *%esi
			break;
  80039a:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80039d:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003a0:	e9 cf 02 00 00       	jmp    800674 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  8003a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a8:	8d 78 04             	lea    0x4(%eax),%edi
  8003ab:	8b 00                	mov    (%eax),%eax
  8003ad:	99                   	cltd   
  8003ae:	31 d0                	xor    %edx,%eax
  8003b0:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003b2:	83 f8 08             	cmp    $0x8,%eax
  8003b5:	7f 23                	jg     8003da <vprintfmt+0x13b>
  8003b7:	8b 14 85 00 16 80 00 	mov    0x801600(,%eax,4),%edx
  8003be:	85 d2                	test   %edx,%edx
  8003c0:	74 18                	je     8003da <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8003c2:	52                   	push   %edx
  8003c3:	68 01 14 80 00       	push   $0x801401
  8003c8:	53                   	push   %ebx
  8003c9:	56                   	push   %esi
  8003ca:	e8 b3 fe ff ff       	call   800282 <printfmt>
  8003cf:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003d2:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003d5:	e9 9a 02 00 00       	jmp    800674 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  8003da:	50                   	push   %eax
  8003db:	68 f8 13 80 00       	push   $0x8013f8
  8003e0:	53                   	push   %ebx
  8003e1:	56                   	push   %esi
  8003e2:	e8 9b fe ff ff       	call   800282 <printfmt>
  8003e7:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003ea:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003ed:	e9 82 02 00 00       	jmp    800674 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  8003f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f5:	83 c0 04             	add    $0x4,%eax
  8003f8:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fe:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800400:	85 ff                	test   %edi,%edi
  800402:	b8 f1 13 80 00       	mov    $0x8013f1,%eax
  800407:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80040a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80040e:	0f 8e bd 00 00 00    	jle    8004d1 <vprintfmt+0x232>
  800414:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800418:	75 0e                	jne    800428 <vprintfmt+0x189>
  80041a:	89 75 08             	mov    %esi,0x8(%ebp)
  80041d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800420:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800423:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800426:	eb 6d                	jmp    800495 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  800428:	83 ec 08             	sub    $0x8,%esp
  80042b:	ff 75 d0             	pushl  -0x30(%ebp)
  80042e:	57                   	push   %edi
  80042f:	e8 6e 03 00 00       	call   8007a2 <strnlen>
  800434:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800437:	29 c1                	sub    %eax,%ecx
  800439:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80043c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80043f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800443:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800446:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800449:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  80044b:	eb 0f                	jmp    80045c <vprintfmt+0x1bd>
					putch(padc, putdat);
  80044d:	83 ec 08             	sub    $0x8,%esp
  800450:	53                   	push   %ebx
  800451:	ff 75 e0             	pushl  -0x20(%ebp)
  800454:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800456:	83 ef 01             	sub    $0x1,%edi
  800459:	83 c4 10             	add    $0x10,%esp
  80045c:	85 ff                	test   %edi,%edi
  80045e:	7f ed                	jg     80044d <vprintfmt+0x1ae>
  800460:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800463:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800466:	85 c9                	test   %ecx,%ecx
  800468:	b8 00 00 00 00       	mov    $0x0,%eax
  80046d:	0f 49 c1             	cmovns %ecx,%eax
  800470:	29 c1                	sub    %eax,%ecx
  800472:	89 75 08             	mov    %esi,0x8(%ebp)
  800475:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800478:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80047b:	89 cb                	mov    %ecx,%ebx
  80047d:	eb 16                	jmp    800495 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  80047f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800483:	75 31                	jne    8004b6 <vprintfmt+0x217>
					putch(ch, putdat);
  800485:	83 ec 08             	sub    $0x8,%esp
  800488:	ff 75 0c             	pushl  0xc(%ebp)
  80048b:	50                   	push   %eax
  80048c:	ff 55 08             	call   *0x8(%ebp)
  80048f:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800492:	83 eb 01             	sub    $0x1,%ebx
  800495:	83 c7 01             	add    $0x1,%edi
  800498:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  80049c:	0f be c2             	movsbl %dl,%eax
  80049f:	85 c0                	test   %eax,%eax
  8004a1:	74 59                	je     8004fc <vprintfmt+0x25d>
  8004a3:	85 f6                	test   %esi,%esi
  8004a5:	78 d8                	js     80047f <vprintfmt+0x1e0>
  8004a7:	83 ee 01             	sub    $0x1,%esi
  8004aa:	79 d3                	jns    80047f <vprintfmt+0x1e0>
  8004ac:	89 df                	mov    %ebx,%edi
  8004ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8004b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004b4:	eb 37                	jmp    8004ed <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004b6:	0f be d2             	movsbl %dl,%edx
  8004b9:	83 ea 20             	sub    $0x20,%edx
  8004bc:	83 fa 5e             	cmp    $0x5e,%edx
  8004bf:	76 c4                	jbe    800485 <vprintfmt+0x1e6>
					putch('?', putdat);
  8004c1:	83 ec 08             	sub    $0x8,%esp
  8004c4:	ff 75 0c             	pushl  0xc(%ebp)
  8004c7:	6a 3f                	push   $0x3f
  8004c9:	ff 55 08             	call   *0x8(%ebp)
  8004cc:	83 c4 10             	add    $0x10,%esp
  8004cf:	eb c1                	jmp    800492 <vprintfmt+0x1f3>
  8004d1:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004da:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004dd:	eb b6                	jmp    800495 <vprintfmt+0x1f6>
				putch(' ', putdat);
  8004df:	83 ec 08             	sub    $0x8,%esp
  8004e2:	53                   	push   %ebx
  8004e3:	6a 20                	push   $0x20
  8004e5:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004e7:	83 ef 01             	sub    $0x1,%edi
  8004ea:	83 c4 10             	add    $0x10,%esp
  8004ed:	85 ff                	test   %edi,%edi
  8004ef:	7f ee                	jg     8004df <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  8004f1:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004f4:	89 45 14             	mov    %eax,0x14(%ebp)
  8004f7:	e9 78 01 00 00       	jmp    800674 <vprintfmt+0x3d5>
  8004fc:	89 df                	mov    %ebx,%edi
  8004fe:	8b 75 08             	mov    0x8(%ebp),%esi
  800501:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800504:	eb e7                	jmp    8004ed <vprintfmt+0x24e>
	if (lflag >= 2)
  800506:	83 f9 01             	cmp    $0x1,%ecx
  800509:	7e 3f                	jle    80054a <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  80050b:	8b 45 14             	mov    0x14(%ebp),%eax
  80050e:	8b 50 04             	mov    0x4(%eax),%edx
  800511:	8b 00                	mov    (%eax),%eax
  800513:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800516:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800519:	8b 45 14             	mov    0x14(%ebp),%eax
  80051c:	8d 40 08             	lea    0x8(%eax),%eax
  80051f:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800522:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800526:	79 5c                	jns    800584 <vprintfmt+0x2e5>
				putch('-', putdat);
  800528:	83 ec 08             	sub    $0x8,%esp
  80052b:	53                   	push   %ebx
  80052c:	6a 2d                	push   $0x2d
  80052e:	ff d6                	call   *%esi
				num = -(long long) num;
  800530:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800533:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800536:	f7 da                	neg    %edx
  800538:	83 d1 00             	adc    $0x0,%ecx
  80053b:	f7 d9                	neg    %ecx
  80053d:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800540:	b8 0a 00 00 00       	mov    $0xa,%eax
  800545:	e9 10 01 00 00       	jmp    80065a <vprintfmt+0x3bb>
	else if (lflag)
  80054a:	85 c9                	test   %ecx,%ecx
  80054c:	75 1b                	jne    800569 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  80054e:	8b 45 14             	mov    0x14(%ebp),%eax
  800551:	8b 00                	mov    (%eax),%eax
  800553:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800556:	89 c1                	mov    %eax,%ecx
  800558:	c1 f9 1f             	sar    $0x1f,%ecx
  80055b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80055e:	8b 45 14             	mov    0x14(%ebp),%eax
  800561:	8d 40 04             	lea    0x4(%eax),%eax
  800564:	89 45 14             	mov    %eax,0x14(%ebp)
  800567:	eb b9                	jmp    800522 <vprintfmt+0x283>
		return va_arg(*ap, long);
  800569:	8b 45 14             	mov    0x14(%ebp),%eax
  80056c:	8b 00                	mov    (%eax),%eax
  80056e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800571:	89 c1                	mov    %eax,%ecx
  800573:	c1 f9 1f             	sar    $0x1f,%ecx
  800576:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800579:	8b 45 14             	mov    0x14(%ebp),%eax
  80057c:	8d 40 04             	lea    0x4(%eax),%eax
  80057f:	89 45 14             	mov    %eax,0x14(%ebp)
  800582:	eb 9e                	jmp    800522 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  800584:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800587:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80058a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80058f:	e9 c6 00 00 00       	jmp    80065a <vprintfmt+0x3bb>
	if (lflag >= 2)
  800594:	83 f9 01             	cmp    $0x1,%ecx
  800597:	7e 18                	jle    8005b1 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  800599:	8b 45 14             	mov    0x14(%ebp),%eax
  80059c:	8b 10                	mov    (%eax),%edx
  80059e:	8b 48 04             	mov    0x4(%eax),%ecx
  8005a1:	8d 40 08             	lea    0x8(%eax),%eax
  8005a4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005a7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ac:	e9 a9 00 00 00       	jmp    80065a <vprintfmt+0x3bb>
	else if (lflag)
  8005b1:	85 c9                	test   %ecx,%ecx
  8005b3:	75 1a                	jne    8005cf <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  8005b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b8:	8b 10                	mov    (%eax),%edx
  8005ba:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005bf:	8d 40 04             	lea    0x4(%eax),%eax
  8005c2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005c5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ca:	e9 8b 00 00 00       	jmp    80065a <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8005cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d2:	8b 10                	mov    (%eax),%edx
  8005d4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d9:	8d 40 04             	lea    0x4(%eax),%eax
  8005dc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005df:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e4:	eb 74                	jmp    80065a <vprintfmt+0x3bb>
	if (lflag >= 2)
  8005e6:	83 f9 01             	cmp    $0x1,%ecx
  8005e9:	7e 15                	jle    800600 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  8005eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ee:	8b 10                	mov    (%eax),%edx
  8005f0:	8b 48 04             	mov    0x4(%eax),%ecx
  8005f3:	8d 40 08             	lea    0x8(%eax),%eax
  8005f6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8005f9:	b8 08 00 00 00       	mov    $0x8,%eax
  8005fe:	eb 5a                	jmp    80065a <vprintfmt+0x3bb>
	else if (lflag)
  800600:	85 c9                	test   %ecx,%ecx
  800602:	75 17                	jne    80061b <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  800604:	8b 45 14             	mov    0x14(%ebp),%eax
  800607:	8b 10                	mov    (%eax),%edx
  800609:	b9 00 00 00 00       	mov    $0x0,%ecx
  80060e:	8d 40 04             	lea    0x4(%eax),%eax
  800611:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800614:	b8 08 00 00 00       	mov    $0x8,%eax
  800619:	eb 3f                	jmp    80065a <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80061b:	8b 45 14             	mov    0x14(%ebp),%eax
  80061e:	8b 10                	mov    (%eax),%edx
  800620:	b9 00 00 00 00       	mov    $0x0,%ecx
  800625:	8d 40 04             	lea    0x4(%eax),%eax
  800628:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80062b:	b8 08 00 00 00       	mov    $0x8,%eax
  800630:	eb 28                	jmp    80065a <vprintfmt+0x3bb>
			putch('0', putdat);
  800632:	83 ec 08             	sub    $0x8,%esp
  800635:	53                   	push   %ebx
  800636:	6a 30                	push   $0x30
  800638:	ff d6                	call   *%esi
			putch('x', putdat);
  80063a:	83 c4 08             	add    $0x8,%esp
  80063d:	53                   	push   %ebx
  80063e:	6a 78                	push   $0x78
  800640:	ff d6                	call   *%esi
			num = (unsigned long long)
  800642:	8b 45 14             	mov    0x14(%ebp),%eax
  800645:	8b 10                	mov    (%eax),%edx
  800647:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80064c:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80064f:	8d 40 04             	lea    0x4(%eax),%eax
  800652:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800655:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80065a:	83 ec 0c             	sub    $0xc,%esp
  80065d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800661:	57                   	push   %edi
  800662:	ff 75 e0             	pushl  -0x20(%ebp)
  800665:	50                   	push   %eax
  800666:	51                   	push   %ecx
  800667:	52                   	push   %edx
  800668:	89 da                	mov    %ebx,%edx
  80066a:	89 f0                	mov    %esi,%eax
  80066c:	e8 45 fb ff ff       	call   8001b6 <printnum>
			break;
  800671:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800674:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800677:	83 c7 01             	add    $0x1,%edi
  80067a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80067e:	83 f8 25             	cmp    $0x25,%eax
  800681:	0f 84 2f fc ff ff    	je     8002b6 <vprintfmt+0x17>
			if (ch == '\0')
  800687:	85 c0                	test   %eax,%eax
  800689:	0f 84 8b 00 00 00    	je     80071a <vprintfmt+0x47b>
			putch(ch, putdat);
  80068f:	83 ec 08             	sub    $0x8,%esp
  800692:	53                   	push   %ebx
  800693:	50                   	push   %eax
  800694:	ff d6                	call   *%esi
  800696:	83 c4 10             	add    $0x10,%esp
  800699:	eb dc                	jmp    800677 <vprintfmt+0x3d8>
	if (lflag >= 2)
  80069b:	83 f9 01             	cmp    $0x1,%ecx
  80069e:	7e 15                	jle    8006b5 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  8006a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a3:	8b 10                	mov    (%eax),%edx
  8006a5:	8b 48 04             	mov    0x4(%eax),%ecx
  8006a8:	8d 40 08             	lea    0x8(%eax),%eax
  8006ab:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ae:	b8 10 00 00 00       	mov    $0x10,%eax
  8006b3:	eb a5                	jmp    80065a <vprintfmt+0x3bb>
	else if (lflag)
  8006b5:	85 c9                	test   %ecx,%ecx
  8006b7:	75 17                	jne    8006d0 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  8006b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bc:	8b 10                	mov    (%eax),%edx
  8006be:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006c3:	8d 40 04             	lea    0x4(%eax),%eax
  8006c6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006c9:	b8 10 00 00 00       	mov    $0x10,%eax
  8006ce:	eb 8a                	jmp    80065a <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8006d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d3:	8b 10                	mov    (%eax),%edx
  8006d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006da:	8d 40 04             	lea    0x4(%eax),%eax
  8006dd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006e0:	b8 10 00 00 00       	mov    $0x10,%eax
  8006e5:	e9 70 ff ff ff       	jmp    80065a <vprintfmt+0x3bb>
			putch(ch, putdat);
  8006ea:	83 ec 08             	sub    $0x8,%esp
  8006ed:	53                   	push   %ebx
  8006ee:	6a 25                	push   $0x25
  8006f0:	ff d6                	call   *%esi
			break;
  8006f2:	83 c4 10             	add    $0x10,%esp
  8006f5:	e9 7a ff ff ff       	jmp    800674 <vprintfmt+0x3d5>
			putch('%', putdat);
  8006fa:	83 ec 08             	sub    $0x8,%esp
  8006fd:	53                   	push   %ebx
  8006fe:	6a 25                	push   $0x25
  800700:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800702:	83 c4 10             	add    $0x10,%esp
  800705:	89 f8                	mov    %edi,%eax
  800707:	eb 03                	jmp    80070c <vprintfmt+0x46d>
  800709:	83 e8 01             	sub    $0x1,%eax
  80070c:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800710:	75 f7                	jne    800709 <vprintfmt+0x46a>
  800712:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800715:	e9 5a ff ff ff       	jmp    800674 <vprintfmt+0x3d5>
}
  80071a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80071d:	5b                   	pop    %ebx
  80071e:	5e                   	pop    %esi
  80071f:	5f                   	pop    %edi
  800720:	5d                   	pop    %ebp
  800721:	c3                   	ret    

00800722 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800722:	55                   	push   %ebp
  800723:	89 e5                	mov    %esp,%ebp
  800725:	83 ec 18             	sub    $0x18,%esp
  800728:	8b 45 08             	mov    0x8(%ebp),%eax
  80072b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80072e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800731:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800735:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800738:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80073f:	85 c0                	test   %eax,%eax
  800741:	74 26                	je     800769 <vsnprintf+0x47>
  800743:	85 d2                	test   %edx,%edx
  800745:	7e 22                	jle    800769 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800747:	ff 75 14             	pushl  0x14(%ebp)
  80074a:	ff 75 10             	pushl  0x10(%ebp)
  80074d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800750:	50                   	push   %eax
  800751:	68 65 02 80 00       	push   $0x800265
  800756:	e8 44 fb ff ff       	call   80029f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80075b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80075e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800761:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800764:	83 c4 10             	add    $0x10,%esp
}
  800767:	c9                   	leave  
  800768:	c3                   	ret    
		return -E_INVAL;
  800769:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80076e:	eb f7                	jmp    800767 <vsnprintf+0x45>

00800770 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800776:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800779:	50                   	push   %eax
  80077a:	ff 75 10             	pushl  0x10(%ebp)
  80077d:	ff 75 0c             	pushl  0xc(%ebp)
  800780:	ff 75 08             	pushl  0x8(%ebp)
  800783:	e8 9a ff ff ff       	call   800722 <vsnprintf>
	va_end(ap);

	return rc;
}
  800788:	c9                   	leave  
  800789:	c3                   	ret    

0080078a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80078a:	55                   	push   %ebp
  80078b:	89 e5                	mov    %esp,%ebp
  80078d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800790:	b8 00 00 00 00       	mov    $0x0,%eax
  800795:	eb 03                	jmp    80079a <strlen+0x10>
		n++;
  800797:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80079a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80079e:	75 f7                	jne    800797 <strlen+0xd>
	return n;
}
  8007a0:	5d                   	pop    %ebp
  8007a1:	c3                   	ret    

008007a2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007a2:	55                   	push   %ebp
  8007a3:	89 e5                	mov    %esp,%ebp
  8007a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a8:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b0:	eb 03                	jmp    8007b5 <strnlen+0x13>
		n++;
  8007b2:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b5:	39 d0                	cmp    %edx,%eax
  8007b7:	74 06                	je     8007bf <strnlen+0x1d>
  8007b9:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007bd:	75 f3                	jne    8007b2 <strnlen+0x10>
	return n;
}
  8007bf:	5d                   	pop    %ebp
  8007c0:	c3                   	ret    

008007c1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007c1:	55                   	push   %ebp
  8007c2:	89 e5                	mov    %esp,%ebp
  8007c4:	53                   	push   %ebx
  8007c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007cb:	89 c2                	mov    %eax,%edx
  8007cd:	83 c1 01             	add    $0x1,%ecx
  8007d0:	83 c2 01             	add    $0x1,%edx
  8007d3:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007d7:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007da:	84 db                	test   %bl,%bl
  8007dc:	75 ef                	jne    8007cd <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007de:	5b                   	pop    %ebx
  8007df:	5d                   	pop    %ebp
  8007e0:	c3                   	ret    

008007e1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007e1:	55                   	push   %ebp
  8007e2:	89 e5                	mov    %esp,%ebp
  8007e4:	53                   	push   %ebx
  8007e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007e8:	53                   	push   %ebx
  8007e9:	e8 9c ff ff ff       	call   80078a <strlen>
  8007ee:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007f1:	ff 75 0c             	pushl  0xc(%ebp)
  8007f4:	01 d8                	add    %ebx,%eax
  8007f6:	50                   	push   %eax
  8007f7:	e8 c5 ff ff ff       	call   8007c1 <strcpy>
	return dst;
}
  8007fc:	89 d8                	mov    %ebx,%eax
  8007fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800801:	c9                   	leave  
  800802:	c3                   	ret    

00800803 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800803:	55                   	push   %ebp
  800804:	89 e5                	mov    %esp,%ebp
  800806:	56                   	push   %esi
  800807:	53                   	push   %ebx
  800808:	8b 75 08             	mov    0x8(%ebp),%esi
  80080b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80080e:	89 f3                	mov    %esi,%ebx
  800810:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800813:	89 f2                	mov    %esi,%edx
  800815:	eb 0f                	jmp    800826 <strncpy+0x23>
		*dst++ = *src;
  800817:	83 c2 01             	add    $0x1,%edx
  80081a:	0f b6 01             	movzbl (%ecx),%eax
  80081d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800820:	80 39 01             	cmpb   $0x1,(%ecx)
  800823:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800826:	39 da                	cmp    %ebx,%edx
  800828:	75 ed                	jne    800817 <strncpy+0x14>
	}
	return ret;
}
  80082a:	89 f0                	mov    %esi,%eax
  80082c:	5b                   	pop    %ebx
  80082d:	5e                   	pop    %esi
  80082e:	5d                   	pop    %ebp
  80082f:	c3                   	ret    

00800830 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	56                   	push   %esi
  800834:	53                   	push   %ebx
  800835:	8b 75 08             	mov    0x8(%ebp),%esi
  800838:	8b 55 0c             	mov    0xc(%ebp),%edx
  80083b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80083e:	89 f0                	mov    %esi,%eax
  800840:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800844:	85 c9                	test   %ecx,%ecx
  800846:	75 0b                	jne    800853 <strlcpy+0x23>
  800848:	eb 17                	jmp    800861 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80084a:	83 c2 01             	add    $0x1,%edx
  80084d:	83 c0 01             	add    $0x1,%eax
  800850:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800853:	39 d8                	cmp    %ebx,%eax
  800855:	74 07                	je     80085e <strlcpy+0x2e>
  800857:	0f b6 0a             	movzbl (%edx),%ecx
  80085a:	84 c9                	test   %cl,%cl
  80085c:	75 ec                	jne    80084a <strlcpy+0x1a>
		*dst = '\0';
  80085e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800861:	29 f0                	sub    %esi,%eax
}
  800863:	5b                   	pop    %ebx
  800864:	5e                   	pop    %esi
  800865:	5d                   	pop    %ebp
  800866:	c3                   	ret    

00800867 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80086d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800870:	eb 06                	jmp    800878 <strcmp+0x11>
		p++, q++;
  800872:	83 c1 01             	add    $0x1,%ecx
  800875:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800878:	0f b6 01             	movzbl (%ecx),%eax
  80087b:	84 c0                	test   %al,%al
  80087d:	74 04                	je     800883 <strcmp+0x1c>
  80087f:	3a 02                	cmp    (%edx),%al
  800881:	74 ef                	je     800872 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800883:	0f b6 c0             	movzbl %al,%eax
  800886:	0f b6 12             	movzbl (%edx),%edx
  800889:	29 d0                	sub    %edx,%eax
}
  80088b:	5d                   	pop    %ebp
  80088c:	c3                   	ret    

0080088d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80088d:	55                   	push   %ebp
  80088e:	89 e5                	mov    %esp,%ebp
  800890:	53                   	push   %ebx
  800891:	8b 45 08             	mov    0x8(%ebp),%eax
  800894:	8b 55 0c             	mov    0xc(%ebp),%edx
  800897:	89 c3                	mov    %eax,%ebx
  800899:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80089c:	eb 06                	jmp    8008a4 <strncmp+0x17>
		n--, p++, q++;
  80089e:	83 c0 01             	add    $0x1,%eax
  8008a1:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008a4:	39 d8                	cmp    %ebx,%eax
  8008a6:	74 16                	je     8008be <strncmp+0x31>
  8008a8:	0f b6 08             	movzbl (%eax),%ecx
  8008ab:	84 c9                	test   %cl,%cl
  8008ad:	74 04                	je     8008b3 <strncmp+0x26>
  8008af:	3a 0a                	cmp    (%edx),%cl
  8008b1:	74 eb                	je     80089e <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b3:	0f b6 00             	movzbl (%eax),%eax
  8008b6:	0f b6 12             	movzbl (%edx),%edx
  8008b9:	29 d0                	sub    %edx,%eax
}
  8008bb:	5b                   	pop    %ebx
  8008bc:	5d                   	pop    %ebp
  8008bd:	c3                   	ret    
		return 0;
  8008be:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c3:	eb f6                	jmp    8008bb <strncmp+0x2e>

008008c5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008c5:	55                   	push   %ebp
  8008c6:	89 e5                	mov    %esp,%ebp
  8008c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008cf:	0f b6 10             	movzbl (%eax),%edx
  8008d2:	84 d2                	test   %dl,%dl
  8008d4:	74 09                	je     8008df <strchr+0x1a>
		if (*s == c)
  8008d6:	38 ca                	cmp    %cl,%dl
  8008d8:	74 0a                	je     8008e4 <strchr+0x1f>
	for (; *s; s++)
  8008da:	83 c0 01             	add    $0x1,%eax
  8008dd:	eb f0                	jmp    8008cf <strchr+0xa>
			return (char *) s;
	return 0;
  8008df:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008e4:	5d                   	pop    %ebp
  8008e5:	c3                   	ret    

008008e6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008e6:	55                   	push   %ebp
  8008e7:	89 e5                	mov    %esp,%ebp
  8008e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ec:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008f0:	eb 03                	jmp    8008f5 <strfind+0xf>
  8008f2:	83 c0 01             	add    $0x1,%eax
  8008f5:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008f8:	38 ca                	cmp    %cl,%dl
  8008fa:	74 04                	je     800900 <strfind+0x1a>
  8008fc:	84 d2                	test   %dl,%dl
  8008fe:	75 f2                	jne    8008f2 <strfind+0xc>
			break;
	return (char *) s;
}
  800900:	5d                   	pop    %ebp
  800901:	c3                   	ret    

00800902 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	57                   	push   %edi
  800906:	56                   	push   %esi
  800907:	53                   	push   %ebx
  800908:	8b 7d 08             	mov    0x8(%ebp),%edi
  80090b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80090e:	85 c9                	test   %ecx,%ecx
  800910:	74 13                	je     800925 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800912:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800918:	75 05                	jne    80091f <memset+0x1d>
  80091a:	f6 c1 03             	test   $0x3,%cl
  80091d:	74 0d                	je     80092c <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80091f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800922:	fc                   	cld    
  800923:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800925:	89 f8                	mov    %edi,%eax
  800927:	5b                   	pop    %ebx
  800928:	5e                   	pop    %esi
  800929:	5f                   	pop    %edi
  80092a:	5d                   	pop    %ebp
  80092b:	c3                   	ret    
		c &= 0xFF;
  80092c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800930:	89 d3                	mov    %edx,%ebx
  800932:	c1 e3 08             	shl    $0x8,%ebx
  800935:	89 d0                	mov    %edx,%eax
  800937:	c1 e0 18             	shl    $0x18,%eax
  80093a:	89 d6                	mov    %edx,%esi
  80093c:	c1 e6 10             	shl    $0x10,%esi
  80093f:	09 f0                	or     %esi,%eax
  800941:	09 c2                	or     %eax,%edx
  800943:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800945:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800948:	89 d0                	mov    %edx,%eax
  80094a:	fc                   	cld    
  80094b:	f3 ab                	rep stos %eax,%es:(%edi)
  80094d:	eb d6                	jmp    800925 <memset+0x23>

0080094f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80094f:	55                   	push   %ebp
  800950:	89 e5                	mov    %esp,%ebp
  800952:	57                   	push   %edi
  800953:	56                   	push   %esi
  800954:	8b 45 08             	mov    0x8(%ebp),%eax
  800957:	8b 75 0c             	mov    0xc(%ebp),%esi
  80095a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80095d:	39 c6                	cmp    %eax,%esi
  80095f:	73 35                	jae    800996 <memmove+0x47>
  800961:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800964:	39 c2                	cmp    %eax,%edx
  800966:	76 2e                	jbe    800996 <memmove+0x47>
		s += n;
		d += n;
  800968:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096b:	89 d6                	mov    %edx,%esi
  80096d:	09 fe                	or     %edi,%esi
  80096f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800975:	74 0c                	je     800983 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800977:	83 ef 01             	sub    $0x1,%edi
  80097a:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80097d:	fd                   	std    
  80097e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800980:	fc                   	cld    
  800981:	eb 21                	jmp    8009a4 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800983:	f6 c1 03             	test   $0x3,%cl
  800986:	75 ef                	jne    800977 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800988:	83 ef 04             	sub    $0x4,%edi
  80098b:	8d 72 fc             	lea    -0x4(%edx),%esi
  80098e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800991:	fd                   	std    
  800992:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800994:	eb ea                	jmp    800980 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800996:	89 f2                	mov    %esi,%edx
  800998:	09 c2                	or     %eax,%edx
  80099a:	f6 c2 03             	test   $0x3,%dl
  80099d:	74 09                	je     8009a8 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80099f:	89 c7                	mov    %eax,%edi
  8009a1:	fc                   	cld    
  8009a2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009a4:	5e                   	pop    %esi
  8009a5:	5f                   	pop    %edi
  8009a6:	5d                   	pop    %ebp
  8009a7:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a8:	f6 c1 03             	test   $0x3,%cl
  8009ab:	75 f2                	jne    80099f <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009ad:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009b0:	89 c7                	mov    %eax,%edi
  8009b2:	fc                   	cld    
  8009b3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b5:	eb ed                	jmp    8009a4 <memmove+0x55>

008009b7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009ba:	ff 75 10             	pushl  0x10(%ebp)
  8009bd:	ff 75 0c             	pushl  0xc(%ebp)
  8009c0:	ff 75 08             	pushl  0x8(%ebp)
  8009c3:	e8 87 ff ff ff       	call   80094f <memmove>
}
  8009c8:	c9                   	leave  
  8009c9:	c3                   	ret    

008009ca <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ca:	55                   	push   %ebp
  8009cb:	89 e5                	mov    %esp,%ebp
  8009cd:	56                   	push   %esi
  8009ce:	53                   	push   %ebx
  8009cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d5:	89 c6                	mov    %eax,%esi
  8009d7:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009da:	39 f0                	cmp    %esi,%eax
  8009dc:	74 1c                	je     8009fa <memcmp+0x30>
		if (*s1 != *s2)
  8009de:	0f b6 08             	movzbl (%eax),%ecx
  8009e1:	0f b6 1a             	movzbl (%edx),%ebx
  8009e4:	38 d9                	cmp    %bl,%cl
  8009e6:	75 08                	jne    8009f0 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009e8:	83 c0 01             	add    $0x1,%eax
  8009eb:	83 c2 01             	add    $0x1,%edx
  8009ee:	eb ea                	jmp    8009da <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8009f0:	0f b6 c1             	movzbl %cl,%eax
  8009f3:	0f b6 db             	movzbl %bl,%ebx
  8009f6:	29 d8                	sub    %ebx,%eax
  8009f8:	eb 05                	jmp    8009ff <memcmp+0x35>
	}

	return 0;
  8009fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ff:	5b                   	pop    %ebx
  800a00:	5e                   	pop    %esi
  800a01:	5d                   	pop    %ebp
  800a02:	c3                   	ret    

00800a03 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a03:	55                   	push   %ebp
  800a04:	89 e5                	mov    %esp,%ebp
  800a06:	8b 45 08             	mov    0x8(%ebp),%eax
  800a09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a0c:	89 c2                	mov    %eax,%edx
  800a0e:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a11:	39 d0                	cmp    %edx,%eax
  800a13:	73 09                	jae    800a1e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a15:	38 08                	cmp    %cl,(%eax)
  800a17:	74 05                	je     800a1e <memfind+0x1b>
	for (; s < ends; s++)
  800a19:	83 c0 01             	add    $0x1,%eax
  800a1c:	eb f3                	jmp    800a11 <memfind+0xe>
			break;
	return (void *) s;
}
  800a1e:	5d                   	pop    %ebp
  800a1f:	c3                   	ret    

00800a20 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a20:	55                   	push   %ebp
  800a21:	89 e5                	mov    %esp,%ebp
  800a23:	57                   	push   %edi
  800a24:	56                   	push   %esi
  800a25:	53                   	push   %ebx
  800a26:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a29:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a2c:	eb 03                	jmp    800a31 <strtol+0x11>
		s++;
  800a2e:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a31:	0f b6 01             	movzbl (%ecx),%eax
  800a34:	3c 20                	cmp    $0x20,%al
  800a36:	74 f6                	je     800a2e <strtol+0xe>
  800a38:	3c 09                	cmp    $0x9,%al
  800a3a:	74 f2                	je     800a2e <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a3c:	3c 2b                	cmp    $0x2b,%al
  800a3e:	74 2e                	je     800a6e <strtol+0x4e>
	int neg = 0;
  800a40:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a45:	3c 2d                	cmp    $0x2d,%al
  800a47:	74 2f                	je     800a78 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a49:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a4f:	75 05                	jne    800a56 <strtol+0x36>
  800a51:	80 39 30             	cmpb   $0x30,(%ecx)
  800a54:	74 2c                	je     800a82 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a56:	85 db                	test   %ebx,%ebx
  800a58:	75 0a                	jne    800a64 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a5a:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a5f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a62:	74 28                	je     800a8c <strtol+0x6c>
		base = 10;
  800a64:	b8 00 00 00 00       	mov    $0x0,%eax
  800a69:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a6c:	eb 50                	jmp    800abe <strtol+0x9e>
		s++;
  800a6e:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a71:	bf 00 00 00 00       	mov    $0x0,%edi
  800a76:	eb d1                	jmp    800a49 <strtol+0x29>
		s++, neg = 1;
  800a78:	83 c1 01             	add    $0x1,%ecx
  800a7b:	bf 01 00 00 00       	mov    $0x1,%edi
  800a80:	eb c7                	jmp    800a49 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a82:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a86:	74 0e                	je     800a96 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a88:	85 db                	test   %ebx,%ebx
  800a8a:	75 d8                	jne    800a64 <strtol+0x44>
		s++, base = 8;
  800a8c:	83 c1 01             	add    $0x1,%ecx
  800a8f:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a94:	eb ce                	jmp    800a64 <strtol+0x44>
		s += 2, base = 16;
  800a96:	83 c1 02             	add    $0x2,%ecx
  800a99:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a9e:	eb c4                	jmp    800a64 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800aa0:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aa3:	89 f3                	mov    %esi,%ebx
  800aa5:	80 fb 19             	cmp    $0x19,%bl
  800aa8:	77 29                	ja     800ad3 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800aaa:	0f be d2             	movsbl %dl,%edx
  800aad:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ab0:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ab3:	7d 30                	jge    800ae5 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800ab5:	83 c1 01             	add    $0x1,%ecx
  800ab8:	0f af 45 10          	imul   0x10(%ebp),%eax
  800abc:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800abe:	0f b6 11             	movzbl (%ecx),%edx
  800ac1:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ac4:	89 f3                	mov    %esi,%ebx
  800ac6:	80 fb 09             	cmp    $0x9,%bl
  800ac9:	77 d5                	ja     800aa0 <strtol+0x80>
			dig = *s - '0';
  800acb:	0f be d2             	movsbl %dl,%edx
  800ace:	83 ea 30             	sub    $0x30,%edx
  800ad1:	eb dd                	jmp    800ab0 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800ad3:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ad6:	89 f3                	mov    %esi,%ebx
  800ad8:	80 fb 19             	cmp    $0x19,%bl
  800adb:	77 08                	ja     800ae5 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800add:	0f be d2             	movsbl %dl,%edx
  800ae0:	83 ea 37             	sub    $0x37,%edx
  800ae3:	eb cb                	jmp    800ab0 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ae5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ae9:	74 05                	je     800af0 <strtol+0xd0>
		*endptr = (char *) s;
  800aeb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aee:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800af0:	89 c2                	mov    %eax,%edx
  800af2:	f7 da                	neg    %edx
  800af4:	85 ff                	test   %edi,%edi
  800af6:	0f 45 c2             	cmovne %edx,%eax
}
  800af9:	5b                   	pop    %ebx
  800afa:	5e                   	pop    %esi
  800afb:	5f                   	pop    %edi
  800afc:	5d                   	pop    %ebp
  800afd:	c3                   	ret    

00800afe <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800afe:	55                   	push   %ebp
  800aff:	89 e5                	mov    %esp,%ebp
  800b01:	57                   	push   %edi
  800b02:	56                   	push   %esi
  800b03:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b04:	b8 00 00 00 00       	mov    $0x0,%eax
  800b09:	8b 55 08             	mov    0x8(%ebp),%edx
  800b0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b0f:	89 c3                	mov    %eax,%ebx
  800b11:	89 c7                	mov    %eax,%edi
  800b13:	89 c6                	mov    %eax,%esi
  800b15:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b17:	5b                   	pop    %ebx
  800b18:	5e                   	pop    %esi
  800b19:	5f                   	pop    %edi
  800b1a:	5d                   	pop    %ebp
  800b1b:	c3                   	ret    

00800b1c <sys_cgetc>:

int
sys_cgetc(void)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
  800b1f:	57                   	push   %edi
  800b20:	56                   	push   %esi
  800b21:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b22:	ba 00 00 00 00       	mov    $0x0,%edx
  800b27:	b8 01 00 00 00       	mov    $0x1,%eax
  800b2c:	89 d1                	mov    %edx,%ecx
  800b2e:	89 d3                	mov    %edx,%ebx
  800b30:	89 d7                	mov    %edx,%edi
  800b32:	89 d6                	mov    %edx,%esi
  800b34:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b36:	5b                   	pop    %ebx
  800b37:	5e                   	pop    %esi
  800b38:	5f                   	pop    %edi
  800b39:	5d                   	pop    %ebp
  800b3a:	c3                   	ret    

00800b3b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	57                   	push   %edi
  800b3f:	56                   	push   %esi
  800b40:	53                   	push   %ebx
  800b41:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b44:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b49:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4c:	b8 03 00 00 00       	mov    $0x3,%eax
  800b51:	89 cb                	mov    %ecx,%ebx
  800b53:	89 cf                	mov    %ecx,%edi
  800b55:	89 ce                	mov    %ecx,%esi
  800b57:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b59:	85 c0                	test   %eax,%eax
  800b5b:	7f 08                	jg     800b65 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b60:	5b                   	pop    %ebx
  800b61:	5e                   	pop    %esi
  800b62:	5f                   	pop    %edi
  800b63:	5d                   	pop    %ebp
  800b64:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b65:	83 ec 0c             	sub    $0xc,%esp
  800b68:	50                   	push   %eax
  800b69:	6a 03                	push   $0x3
  800b6b:	68 24 16 80 00       	push   $0x801624
  800b70:	6a 23                	push   $0x23
  800b72:	68 41 16 80 00       	push   $0x801641
  800b77:	e8 a6 04 00 00       	call   801022 <_panic>

00800b7c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	57                   	push   %edi
  800b80:	56                   	push   %esi
  800b81:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b82:	ba 00 00 00 00       	mov    $0x0,%edx
  800b87:	b8 02 00 00 00       	mov    $0x2,%eax
  800b8c:	89 d1                	mov    %edx,%ecx
  800b8e:	89 d3                	mov    %edx,%ebx
  800b90:	89 d7                	mov    %edx,%edi
  800b92:	89 d6                	mov    %edx,%esi
  800b94:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b96:	5b                   	pop    %ebx
  800b97:	5e                   	pop    %esi
  800b98:	5f                   	pop    %edi
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    

00800b9b <sys_yield>:

void
sys_yield(void)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	57                   	push   %edi
  800b9f:	56                   	push   %esi
  800ba0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ba1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba6:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bab:	89 d1                	mov    %edx,%ecx
  800bad:	89 d3                	mov    %edx,%ebx
  800baf:	89 d7                	mov    %edx,%edi
  800bb1:	89 d6                	mov    %edx,%esi
  800bb3:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bb5:	5b                   	pop    %ebx
  800bb6:	5e                   	pop    %esi
  800bb7:	5f                   	pop    %edi
  800bb8:	5d                   	pop    %ebp
  800bb9:	c3                   	ret    

00800bba <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	57                   	push   %edi
  800bbe:	56                   	push   %esi
  800bbf:	53                   	push   %ebx
  800bc0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bc3:	be 00 00 00 00       	mov    $0x0,%esi
  800bc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bce:	b8 04 00 00 00       	mov    $0x4,%eax
  800bd3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd6:	89 f7                	mov    %esi,%edi
  800bd8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bda:	85 c0                	test   %eax,%eax
  800bdc:	7f 08                	jg     800be6 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bde:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be1:	5b                   	pop    %ebx
  800be2:	5e                   	pop    %esi
  800be3:	5f                   	pop    %edi
  800be4:	5d                   	pop    %ebp
  800be5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800be6:	83 ec 0c             	sub    $0xc,%esp
  800be9:	50                   	push   %eax
  800bea:	6a 04                	push   $0x4
  800bec:	68 24 16 80 00       	push   $0x801624
  800bf1:	6a 23                	push   $0x23
  800bf3:	68 41 16 80 00       	push   $0x801641
  800bf8:	e8 25 04 00 00       	call   801022 <_panic>

00800bfd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bfd:	55                   	push   %ebp
  800bfe:	89 e5                	mov    %esp,%ebp
  800c00:	57                   	push   %edi
  800c01:	56                   	push   %esi
  800c02:	53                   	push   %ebx
  800c03:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c06:	8b 55 08             	mov    0x8(%ebp),%edx
  800c09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0c:	b8 05 00 00 00       	mov    $0x5,%eax
  800c11:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c14:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c17:	8b 75 18             	mov    0x18(%ebp),%esi
  800c1a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c1c:	85 c0                	test   %eax,%eax
  800c1e:	7f 08                	jg     800c28 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c20:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c23:	5b                   	pop    %ebx
  800c24:	5e                   	pop    %esi
  800c25:	5f                   	pop    %edi
  800c26:	5d                   	pop    %ebp
  800c27:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c28:	83 ec 0c             	sub    $0xc,%esp
  800c2b:	50                   	push   %eax
  800c2c:	6a 05                	push   $0x5
  800c2e:	68 24 16 80 00       	push   $0x801624
  800c33:	6a 23                	push   $0x23
  800c35:	68 41 16 80 00       	push   $0x801641
  800c3a:	e8 e3 03 00 00       	call   801022 <_panic>

00800c3f <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c3f:	55                   	push   %ebp
  800c40:	89 e5                	mov    %esp,%ebp
  800c42:	57                   	push   %edi
  800c43:	56                   	push   %esi
  800c44:	53                   	push   %ebx
  800c45:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c48:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c53:	b8 06 00 00 00       	mov    $0x6,%eax
  800c58:	89 df                	mov    %ebx,%edi
  800c5a:	89 de                	mov    %ebx,%esi
  800c5c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c5e:	85 c0                	test   %eax,%eax
  800c60:	7f 08                	jg     800c6a <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c65:	5b                   	pop    %ebx
  800c66:	5e                   	pop    %esi
  800c67:	5f                   	pop    %edi
  800c68:	5d                   	pop    %ebp
  800c69:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6a:	83 ec 0c             	sub    $0xc,%esp
  800c6d:	50                   	push   %eax
  800c6e:	6a 06                	push   $0x6
  800c70:	68 24 16 80 00       	push   $0x801624
  800c75:	6a 23                	push   $0x23
  800c77:	68 41 16 80 00       	push   $0x801641
  800c7c:	e8 a1 03 00 00       	call   801022 <_panic>

00800c81 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c81:	55                   	push   %ebp
  800c82:	89 e5                	mov    %esp,%ebp
  800c84:	57                   	push   %edi
  800c85:	56                   	push   %esi
  800c86:	53                   	push   %ebx
  800c87:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c8a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c95:	b8 08 00 00 00       	mov    $0x8,%eax
  800c9a:	89 df                	mov    %ebx,%edi
  800c9c:	89 de                	mov    %ebx,%esi
  800c9e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ca0:	85 c0                	test   %eax,%eax
  800ca2:	7f 08                	jg     800cac <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ca4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca7:	5b                   	pop    %ebx
  800ca8:	5e                   	pop    %esi
  800ca9:	5f                   	pop    %edi
  800caa:	5d                   	pop    %ebp
  800cab:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cac:	83 ec 0c             	sub    $0xc,%esp
  800caf:	50                   	push   %eax
  800cb0:	6a 08                	push   $0x8
  800cb2:	68 24 16 80 00       	push   $0x801624
  800cb7:	6a 23                	push   $0x23
  800cb9:	68 41 16 80 00       	push   $0x801641
  800cbe:	e8 5f 03 00 00       	call   801022 <_panic>

00800cc3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	57                   	push   %edi
  800cc7:	56                   	push   %esi
  800cc8:	53                   	push   %ebx
  800cc9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ccc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd7:	b8 09 00 00 00       	mov    $0x9,%eax
  800cdc:	89 df                	mov    %ebx,%edi
  800cde:	89 de                	mov    %ebx,%esi
  800ce0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ce2:	85 c0                	test   %eax,%eax
  800ce4:	7f 08                	jg     800cee <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ce6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce9:	5b                   	pop    %ebx
  800cea:	5e                   	pop    %esi
  800ceb:	5f                   	pop    %edi
  800cec:	5d                   	pop    %ebp
  800ced:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cee:	83 ec 0c             	sub    $0xc,%esp
  800cf1:	50                   	push   %eax
  800cf2:	6a 09                	push   $0x9
  800cf4:	68 24 16 80 00       	push   $0x801624
  800cf9:	6a 23                	push   $0x23
  800cfb:	68 41 16 80 00       	push   $0x801641
  800d00:	e8 1d 03 00 00       	call   801022 <_panic>

00800d05 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d05:	55                   	push   %ebp
  800d06:	89 e5                	mov    %esp,%ebp
  800d08:	57                   	push   %edi
  800d09:	56                   	push   %esi
  800d0a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d11:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d16:	be 00 00 00 00       	mov    $0x0,%esi
  800d1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d1e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d21:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d23:	5b                   	pop    %ebx
  800d24:	5e                   	pop    %esi
  800d25:	5f                   	pop    %edi
  800d26:	5d                   	pop    %ebp
  800d27:	c3                   	ret    

00800d28 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	57                   	push   %edi
  800d2c:	56                   	push   %esi
  800d2d:	53                   	push   %ebx
  800d2e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d31:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d36:	8b 55 08             	mov    0x8(%ebp),%edx
  800d39:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d3e:	89 cb                	mov    %ecx,%ebx
  800d40:	89 cf                	mov    %ecx,%edi
  800d42:	89 ce                	mov    %ecx,%esi
  800d44:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d46:	85 c0                	test   %eax,%eax
  800d48:	7f 08                	jg     800d52 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4d:	5b                   	pop    %ebx
  800d4e:	5e                   	pop    %esi
  800d4f:	5f                   	pop    %edi
  800d50:	5d                   	pop    %ebp
  800d51:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d52:	83 ec 0c             	sub    $0xc,%esp
  800d55:	50                   	push   %eax
  800d56:	6a 0c                	push   $0xc
  800d58:	68 24 16 80 00       	push   $0x801624
  800d5d:	6a 23                	push   $0x23
  800d5f:	68 41 16 80 00       	push   $0x801641
  800d64:	e8 b9 02 00 00       	call   801022 <_panic>

00800d69 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d69:	55                   	push   %ebp
  800d6a:	89 e5                	mov    %esp,%ebp
  800d6c:	56                   	push   %esi
  800d6d:	53                   	push   %ebx
  800d6e:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d71:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if((err&FEC_WR)==0 || (uvpt[PGNUM(addr)]&PTE_COW)==0){
  800d73:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d77:	74 7f                	je     800df8 <pgfault+0x8f>
  800d79:	89 d8                	mov    %ebx,%eax
  800d7b:	c1 e8 0c             	shr    $0xc,%eax
  800d7e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d85:	f6 c4 08             	test   $0x8,%ah
  800d88:	74 6e                	je     800df8 <pgfault+0x8f>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        envid_t envid = sys_getenvid();
  800d8a:	e8 ed fd ff ff       	call   800b7c <sys_getenvid>
  800d8f:	89 c6                	mov    %eax,%esi
	r = sys_page_alloc(envid,(void *)PFTEMP,PTE_P|PTE_W|PTE_U);
  800d91:	83 ec 04             	sub    $0x4,%esp
  800d94:	6a 07                	push   $0x7
  800d96:	68 00 f0 7f 00       	push   $0x7ff000
  800d9b:	50                   	push   %eax
  800d9c:	e8 19 fe ff ff       	call   800bba <sys_page_alloc>
	if(r<0) panic("pgfault:page allocation failed %e",r);
  800da1:	83 c4 10             	add    $0x10,%esp
  800da4:	85 c0                	test   %eax,%eax
  800da6:	78 64                	js     800e0c <pgfault+0xa3>
	addr = ROUNDDOWN(addr,PGSIZE);
  800da8:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy((void *)PFTEMP,(const void *)addr,PGSIZE);
  800dae:	83 ec 04             	sub    $0x4,%esp
  800db1:	68 00 10 00 00       	push   $0x1000
  800db6:	53                   	push   %ebx
  800db7:	68 00 f0 7f 00       	push   $0x7ff000
  800dbc:	e8 f6 fb ff ff       	call   8009b7 <memcpy>
	if(sys_page_map(envid,(void *)PFTEMP, envid,addr,PTE_P|PTE_W|PTE_U)<0)
  800dc1:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800dc8:	53                   	push   %ebx
  800dc9:	56                   	push   %esi
  800dca:	68 00 f0 7f 00       	push   $0x7ff000
  800dcf:	56                   	push   %esi
  800dd0:	e8 28 fe ff ff       	call   800bfd <sys_page_map>
  800dd5:	83 c4 20             	add    $0x20,%esp
  800dd8:	85 c0                	test   %eax,%eax
  800dda:	78 42                	js     800e1e <pgfault+0xb5>
		panic("pgfault:page map failed\n");
	if(sys_page_unmap(envid,(void *)PFTEMP)<0)
  800ddc:	83 ec 08             	sub    $0x8,%esp
  800ddf:	68 00 f0 7f 00       	push   $0x7ff000
  800de4:	56                   	push   %esi
  800de5:	e8 55 fe ff ff       	call   800c3f <sys_page_unmap>
  800dea:	83 c4 10             	add    $0x10,%esp
  800ded:	85 c0                	test   %eax,%eax
  800def:	78 41                	js     800e32 <pgfault+0xc9>
		panic("pgfault: page upmap failed\n");
       //	panic("pgfault not implemented");
}
  800df1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800df4:	5b                   	pop    %ebx
  800df5:	5e                   	pop    %esi
  800df6:	5d                   	pop    %ebp
  800df7:	c3                   	ret    
		panic("pgfault:invalid user trap");
  800df8:	83 ec 04             	sub    $0x4,%esp
  800dfb:	68 4f 16 80 00       	push   $0x80164f
  800e00:	6a 1e                	push   $0x1e
  800e02:	68 69 16 80 00       	push   $0x801669
  800e07:	e8 16 02 00 00       	call   801022 <_panic>
	if(r<0) panic("pgfault:page allocation failed %e",r);
  800e0c:	50                   	push   %eax
  800e0d:	68 54 17 80 00       	push   $0x801754
  800e12:	6a 29                	push   $0x29
  800e14:	68 69 16 80 00       	push   $0x801669
  800e19:	e8 04 02 00 00       	call   801022 <_panic>
		panic("pgfault:page map failed\n");
  800e1e:	83 ec 04             	sub    $0x4,%esp
  800e21:	68 74 16 80 00       	push   $0x801674
  800e26:	6a 2d                	push   $0x2d
  800e28:	68 69 16 80 00       	push   $0x801669
  800e2d:	e8 f0 01 00 00       	call   801022 <_panic>
		panic("pgfault: page upmap failed\n");
  800e32:	83 ec 04             	sub    $0x4,%esp
  800e35:	68 8d 16 80 00       	push   $0x80168d
  800e3a:	6a 2f                	push   $0x2f
  800e3c:	68 69 16 80 00       	push   $0x801669
  800e41:	e8 dc 01 00 00       	call   801022 <_panic>

00800e46 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e46:	55                   	push   %ebp
  800e47:	89 e5                	mov    %esp,%ebp
  800e49:	57                   	push   %edi
  800e4a:	56                   	push   %esi
  800e4b:	53                   	push   %ebx
  800e4c:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	set_pgfault_handler(pgfault);
  800e4f:	68 69 0d 80 00       	push   $0x800d69
  800e54:	e8 0f 02 00 00       	call   801068 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e59:	b8 07 00 00 00       	mov    $0x7,%eax
  800e5e:	cd 30                	int    $0x30
  800e60:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800e63:	89 45 e0             	mov    %eax,-0x20(%ebp)
       
	envid_t envid = sys_exofork();
	uintptr_t addr;
  
	if(envid<0) panic("sys_exofork failed\n");
  800e66:	83 c4 10             	add    $0x10,%esp
  800e69:	85 c0                	test   %eax,%eax
  800e6b:	78 28                	js     800e95 <fork+0x4f>
	if(envid==0){
	  thisenv = &envs[ENVX(sys_getenvid())];
	  return 0;
	}

	for(addr=(uintptr_t)UTEXT; addr<USTACKTOP;addr+=PGSIZE){
  800e6d:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if(envid==0){
  800e72:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800e76:	0f 85 fb 00 00 00    	jne    800f77 <fork+0x131>
	  thisenv = &envs[ENVX(sys_getenvid())];
  800e7c:	e8 fb fc ff ff       	call   800b7c <sys_getenvid>
  800e81:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e86:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e89:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e8e:	a3 04 20 80 00       	mov    %eax,0x802004
	  return 0;
  800e93:	eb 6a                	jmp    800eff <fork+0xb9>
	if(envid<0) panic("sys_exofork failed\n");
  800e95:	83 ec 04             	sub    $0x4,%esp
  800e98:	68 a9 16 80 00       	push   $0x8016a9
  800e9d:	6a 70                	push   $0x70
  800e9f:	68 69 16 80 00       	push   $0x801669
  800ea4:	e8 79 01 00 00       	call   801022 <_panic>
		 panic("duppage:map02 failed %e",r);
  800ea9:	50                   	push   %eax
  800eaa:	68 d5 16 80 00       	push   $0x8016d5
  800eaf:	6a 50                	push   $0x50
  800eb1:	68 69 16 80 00       	push   $0x801669
  800eb6:	e8 67 01 00 00       	call   801022 <_panic>
	   if((uvpd[PDX(addr)]&PTE_P) && uvpt[PGNUM(addr)] & PTE_P)
		   duppage(envid,PGNUM(addr));
	}
        
	int r;
	if((r=sys_page_alloc(envid,(void *)UXSTACKTOP-PGSIZE,PTE_U|PTE_P|PTE_W))<0)
  800ebb:	83 ec 04             	sub    $0x4,%esp
  800ebe:	6a 07                	push   $0x7
  800ec0:	68 00 f0 bf ee       	push   $0xeebff000
  800ec5:	ff 75 dc             	pushl  -0x24(%ebp)
  800ec8:	e8 ed fc ff ff       	call   800bba <sys_page_alloc>
  800ecd:	83 c4 10             	add    $0x10,%esp
  800ed0:	85 c0                	test   %eax,%eax
  800ed2:	78 36                	js     800f0a <fork+0xc4>
		panic("fork:page alloc failed %e\n",r);

	extern void _pgfault_upcall();
	if((r = sys_env_set_pgfault_upcall(envid,_pgfault_upcall)))
  800ed4:	83 ec 08             	sub    $0x8,%esp
  800ed7:	68 cd 10 80 00       	push   $0x8010cd
  800edc:	ff 75 dc             	pushl  -0x24(%ebp)
  800edf:	e8 df fd ff ff       	call   800cc3 <sys_env_set_pgfault_upcall>
  800ee4:	83 c4 10             	add    $0x10,%esp
  800ee7:	85 c0                	test   %eax,%eax
  800ee9:	75 31                	jne    800f1c <fork+0xd6>
		panic("fork:set upcall failed %e\n",r);
	if((r = sys_env_set_status(envid,ENV_RUNNABLE))<0)
  800eeb:	83 ec 08             	sub    $0x8,%esp
  800eee:	6a 02                	push   $0x2
  800ef0:	ff 75 dc             	pushl  -0x24(%ebp)
  800ef3:	e8 89 fd ff ff       	call   800c81 <sys_env_set_status>
  800ef8:	83 c4 10             	add    $0x10,%esp
  800efb:	85 c0                	test   %eax,%eax
  800efd:	78 32                	js     800f31 <fork+0xeb>
		panic("fork:set status failed %e\n",r);
	return envid;
       	
}
  800eff:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800f02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f05:	5b                   	pop    %ebx
  800f06:	5e                   	pop    %esi
  800f07:	5f                   	pop    %edi
  800f08:	5d                   	pop    %ebp
  800f09:	c3                   	ret    
		panic("fork:page alloc failed %e\n",r);
  800f0a:	50                   	push   %eax
  800f0b:	68 ed 16 80 00       	push   $0x8016ed
  800f10:	6a 7d                	push   $0x7d
  800f12:	68 69 16 80 00       	push   $0x801669
  800f17:	e8 06 01 00 00       	call   801022 <_panic>
		panic("fork:set upcall failed %e\n",r);
  800f1c:	50                   	push   %eax
  800f1d:	68 08 17 80 00       	push   $0x801708
  800f22:	68 81 00 00 00       	push   $0x81
  800f27:	68 69 16 80 00       	push   $0x801669
  800f2c:	e8 f1 00 00 00       	call   801022 <_panic>
		panic("fork:set status failed %e\n",r);
  800f31:	50                   	push   %eax
  800f32:	68 23 17 80 00       	push   $0x801723
  800f37:	68 83 00 00 00       	push   $0x83
  800f3c:	68 69 16 80 00       	push   $0x801669
  800f41:	e8 dc 00 00 00       	call   801022 <_panic>
	 if((perm&PTE_COW) && (r=sys_page_map(parent_envid,va,parent_envid,va,perm))<0){
  800f46:	83 ec 0c             	sub    $0xc,%esp
  800f49:	68 05 08 00 00       	push   $0x805
  800f4e:	57                   	push   %edi
  800f4f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f52:	50                   	push   %eax
  800f53:	57                   	push   %edi
  800f54:	50                   	push   %eax
  800f55:	e8 a3 fc ff ff       	call   800bfd <sys_page_map>
  800f5a:	83 c4 20             	add    $0x20,%esp
  800f5d:	85 c0                	test   %eax,%eax
  800f5f:	0f 88 44 ff ff ff    	js     800ea9 <fork+0x63>
	for(addr=(uintptr_t)UTEXT; addr<USTACKTOP;addr+=PGSIZE){
  800f65:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f6b:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800f71:	0f 84 44 ff ff ff    	je     800ebb <fork+0x75>
	   if((uvpd[PDX(addr)]&PTE_P) && uvpt[PGNUM(addr)] & PTE_P)
  800f77:	89 d8                	mov    %ebx,%eax
  800f79:	c1 e8 16             	shr    $0x16,%eax
  800f7c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f83:	a8 01                	test   $0x1,%al
  800f85:	74 de                	je     800f65 <fork+0x11f>
  800f87:	89 de                	mov    %ebx,%esi
  800f89:	c1 ee 0c             	shr    $0xc,%esi
  800f8c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f93:	a8 01                	test   $0x1,%al
  800f95:	74 ce                	je     800f65 <fork+0x11f>
        envid_t parent_envid = sys_getenvid();
  800f97:	e8 e0 fb ff ff       	call   800b7c <sys_getenvid>
  800f9c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	void *va = (void *)(pn*PGSIZE);
  800f9f:	89 f7                	mov    %esi,%edi
  800fa1:	c1 e7 0c             	shl    $0xc,%edi
	if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)){
  800fa4:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fab:	a8 02                	test   $0x2,%al
  800fad:	75 27                	jne    800fd6 <fork+0x190>
  800faf:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fb6:	f6 c4 08             	test   $0x8,%ah
  800fb9:	75 1b                	jne    800fd6 <fork+0x190>
	 if((r=sys_page_map(parent_envid,va,envid,va,perm))<0)
  800fbb:	83 ec 0c             	sub    $0xc,%esp
  800fbe:	6a 05                	push   $0x5
  800fc0:	57                   	push   %edi
  800fc1:	ff 75 e0             	pushl  -0x20(%ebp)
  800fc4:	57                   	push   %edi
  800fc5:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fc8:	e8 30 fc ff ff       	call   800bfd <sys_page_map>
  800fcd:	83 c4 20             	add    $0x20,%esp
  800fd0:	85 c0                	test   %eax,%eax
  800fd2:	79 91                	jns    800f65 <fork+0x11f>
  800fd4:	eb 20                	jmp    800ff6 <fork+0x1b0>
  800fd6:	83 ec 0c             	sub    $0xc,%esp
  800fd9:	68 05 08 00 00       	push   $0x805
  800fde:	57                   	push   %edi
  800fdf:	ff 75 e0             	pushl  -0x20(%ebp)
  800fe2:	57                   	push   %edi
  800fe3:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fe6:	e8 12 fc ff ff       	call   800bfd <sys_page_map>
  800feb:	83 c4 20             	add    $0x20,%esp
  800fee:	85 c0                	test   %eax,%eax
  800ff0:	0f 89 50 ff ff ff    	jns    800f46 <fork+0x100>
		 panic("duppage:map01 failed %e",r);
  800ff6:	50                   	push   %eax
  800ff7:	68 bd 16 80 00       	push   $0x8016bd
  800ffc:	6a 4e                	push   $0x4e
  800ffe:	68 69 16 80 00       	push   $0x801669
  801003:	e8 1a 00 00 00       	call   801022 <_panic>

00801008 <sfork>:

// Challenge!
int
sfork(void)
{
  801008:	55                   	push   %ebp
  801009:	89 e5                	mov    %esp,%ebp
  80100b:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80100e:	68 3e 17 80 00       	push   $0x80173e
  801013:	68 8c 00 00 00       	push   $0x8c
  801018:	68 69 16 80 00       	push   $0x801669
  80101d:	e8 00 00 00 00       	call   801022 <_panic>

00801022 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801022:	55                   	push   %ebp
  801023:	89 e5                	mov    %esp,%ebp
  801025:	56                   	push   %esi
  801026:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801027:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80102a:	8b 35 00 20 80 00    	mov    0x802000,%esi
  801030:	e8 47 fb ff ff       	call   800b7c <sys_getenvid>
  801035:	83 ec 0c             	sub    $0xc,%esp
  801038:	ff 75 0c             	pushl  0xc(%ebp)
  80103b:	ff 75 08             	pushl  0x8(%ebp)
  80103e:	56                   	push   %esi
  80103f:	50                   	push   %eax
  801040:	68 78 17 80 00       	push   $0x801778
  801045:	e8 58 f1 ff ff       	call   8001a2 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80104a:	83 c4 18             	add    $0x18,%esp
  80104d:	53                   	push   %ebx
  80104e:	ff 75 10             	pushl  0x10(%ebp)
  801051:	e8 fb f0 ff ff       	call   800151 <vcprintf>
	cprintf("\n");
  801056:	c7 04 24 d4 13 80 00 	movl   $0x8013d4,(%esp)
  80105d:	e8 40 f1 ff ff       	call   8001a2 <cprintf>
  801062:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801065:	cc                   	int3   
  801066:	eb fd                	jmp    801065 <_panic+0x43>

00801068 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801068:	55                   	push   %ebp
  801069:	89 e5                	mov    %esp,%ebp
  80106b:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80106e:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  801075:	74 0a                	je     801081 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler %e",r);
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
	}
       
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801077:	8b 45 08             	mov    0x8(%ebp),%eax
  80107a:	a3 08 20 80 00       	mov    %eax,0x802008
}
  80107f:	c9                   	leave  
  801080:	c3                   	ret    
		if((r=sys_page_alloc(thisenv->env_id,(void *)UXSTACKTOP-PGSIZE,PTE_P|PTE_W|PTE_U))<0)
  801081:	a1 04 20 80 00       	mov    0x802004,%eax
  801086:	8b 40 48             	mov    0x48(%eax),%eax
  801089:	83 ec 04             	sub    $0x4,%esp
  80108c:	6a 07                	push   $0x7
  80108e:	68 00 f0 bf ee       	push   $0xeebff000
  801093:	50                   	push   %eax
  801094:	e8 21 fb ff ff       	call   800bba <sys_page_alloc>
  801099:	83 c4 10             	add    $0x10,%esp
  80109c:	85 c0                	test   %eax,%eax
  80109e:	78 1b                	js     8010bb <set_pgfault_handler+0x53>
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
  8010a0:	a1 04 20 80 00       	mov    0x802004,%eax
  8010a5:	8b 40 48             	mov    0x48(%eax),%eax
  8010a8:	83 ec 08             	sub    $0x8,%esp
  8010ab:	68 cd 10 80 00       	push   $0x8010cd
  8010b0:	50                   	push   %eax
  8010b1:	e8 0d fc ff ff       	call   800cc3 <sys_env_set_pgfault_upcall>
  8010b6:	83 c4 10             	add    $0x10,%esp
  8010b9:	eb bc                	jmp    801077 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler %e",r);
  8010bb:	50                   	push   %eax
  8010bc:	68 9c 17 80 00       	push   $0x80179c
  8010c1:	6a 22                	push   $0x22
  8010c3:	68 b3 17 80 00       	push   $0x8017b3
  8010c8:	e8 55 ff ff ff       	call   801022 <_panic>

008010cd <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8010cd:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8010ce:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  8010d3:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8010d5:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 48(%esp), %ebp
  8010d8:	8b 6c 24 30          	mov    0x30(%esp),%ebp
        subl $4, %ebp
  8010dc:	83 ed 04             	sub    $0x4,%ebp
        movl %ebp, 48(%esp)
  8010df:	89 6c 24 30          	mov    %ebp,0x30(%esp)
        movl 40(%esp), %eax
  8010e3:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl %eax, (%ebp)
  8010e7:	89 45 00             	mov    %eax,0x0(%ebp)
	// Restore the trap-time registers.  After you do this, you
 	// can no longer modify any general-purpose registers.
 	// LAB 4: Your code here.
        addl $8, %esp
  8010ea:	83 c4 08             	add    $0x8,%esp
        popal
  8010ed:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $4, %esp
  8010ee:	83 c4 04             	add    $0x4,%esp
        popfl
  8010f1:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  8010f2:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  8010f3:	c3                   	ret    
  8010f4:	66 90                	xchg   %ax,%ax
  8010f6:	66 90                	xchg   %ax,%ax
  8010f8:	66 90                	xchg   %ax,%ax
  8010fa:	66 90                	xchg   %ax,%ax
  8010fc:	66 90                	xchg   %ax,%ax
  8010fe:	66 90                	xchg   %ax,%ax

00801100 <__udivdi3>:
  801100:	55                   	push   %ebp
  801101:	57                   	push   %edi
  801102:	56                   	push   %esi
  801103:	53                   	push   %ebx
  801104:	83 ec 1c             	sub    $0x1c,%esp
  801107:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80110b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  80110f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801113:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801117:	85 d2                	test   %edx,%edx
  801119:	75 35                	jne    801150 <__udivdi3+0x50>
  80111b:	39 f3                	cmp    %esi,%ebx
  80111d:	0f 87 bd 00 00 00    	ja     8011e0 <__udivdi3+0xe0>
  801123:	85 db                	test   %ebx,%ebx
  801125:	89 d9                	mov    %ebx,%ecx
  801127:	75 0b                	jne    801134 <__udivdi3+0x34>
  801129:	b8 01 00 00 00       	mov    $0x1,%eax
  80112e:	31 d2                	xor    %edx,%edx
  801130:	f7 f3                	div    %ebx
  801132:	89 c1                	mov    %eax,%ecx
  801134:	31 d2                	xor    %edx,%edx
  801136:	89 f0                	mov    %esi,%eax
  801138:	f7 f1                	div    %ecx
  80113a:	89 c6                	mov    %eax,%esi
  80113c:	89 e8                	mov    %ebp,%eax
  80113e:	89 f7                	mov    %esi,%edi
  801140:	f7 f1                	div    %ecx
  801142:	89 fa                	mov    %edi,%edx
  801144:	83 c4 1c             	add    $0x1c,%esp
  801147:	5b                   	pop    %ebx
  801148:	5e                   	pop    %esi
  801149:	5f                   	pop    %edi
  80114a:	5d                   	pop    %ebp
  80114b:	c3                   	ret    
  80114c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801150:	39 f2                	cmp    %esi,%edx
  801152:	77 7c                	ja     8011d0 <__udivdi3+0xd0>
  801154:	0f bd fa             	bsr    %edx,%edi
  801157:	83 f7 1f             	xor    $0x1f,%edi
  80115a:	0f 84 98 00 00 00    	je     8011f8 <__udivdi3+0xf8>
  801160:	89 f9                	mov    %edi,%ecx
  801162:	b8 20 00 00 00       	mov    $0x20,%eax
  801167:	29 f8                	sub    %edi,%eax
  801169:	d3 e2                	shl    %cl,%edx
  80116b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80116f:	89 c1                	mov    %eax,%ecx
  801171:	89 da                	mov    %ebx,%edx
  801173:	d3 ea                	shr    %cl,%edx
  801175:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801179:	09 d1                	or     %edx,%ecx
  80117b:	89 f2                	mov    %esi,%edx
  80117d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801181:	89 f9                	mov    %edi,%ecx
  801183:	d3 e3                	shl    %cl,%ebx
  801185:	89 c1                	mov    %eax,%ecx
  801187:	d3 ea                	shr    %cl,%edx
  801189:	89 f9                	mov    %edi,%ecx
  80118b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80118f:	d3 e6                	shl    %cl,%esi
  801191:	89 eb                	mov    %ebp,%ebx
  801193:	89 c1                	mov    %eax,%ecx
  801195:	d3 eb                	shr    %cl,%ebx
  801197:	09 de                	or     %ebx,%esi
  801199:	89 f0                	mov    %esi,%eax
  80119b:	f7 74 24 08          	divl   0x8(%esp)
  80119f:	89 d6                	mov    %edx,%esi
  8011a1:	89 c3                	mov    %eax,%ebx
  8011a3:	f7 64 24 0c          	mull   0xc(%esp)
  8011a7:	39 d6                	cmp    %edx,%esi
  8011a9:	72 0c                	jb     8011b7 <__udivdi3+0xb7>
  8011ab:	89 f9                	mov    %edi,%ecx
  8011ad:	d3 e5                	shl    %cl,%ebp
  8011af:	39 c5                	cmp    %eax,%ebp
  8011b1:	73 5d                	jae    801210 <__udivdi3+0x110>
  8011b3:	39 d6                	cmp    %edx,%esi
  8011b5:	75 59                	jne    801210 <__udivdi3+0x110>
  8011b7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8011ba:	31 ff                	xor    %edi,%edi
  8011bc:	89 fa                	mov    %edi,%edx
  8011be:	83 c4 1c             	add    $0x1c,%esp
  8011c1:	5b                   	pop    %ebx
  8011c2:	5e                   	pop    %esi
  8011c3:	5f                   	pop    %edi
  8011c4:	5d                   	pop    %ebp
  8011c5:	c3                   	ret    
  8011c6:	8d 76 00             	lea    0x0(%esi),%esi
  8011c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8011d0:	31 ff                	xor    %edi,%edi
  8011d2:	31 c0                	xor    %eax,%eax
  8011d4:	89 fa                	mov    %edi,%edx
  8011d6:	83 c4 1c             	add    $0x1c,%esp
  8011d9:	5b                   	pop    %ebx
  8011da:	5e                   	pop    %esi
  8011db:	5f                   	pop    %edi
  8011dc:	5d                   	pop    %ebp
  8011dd:	c3                   	ret    
  8011de:	66 90                	xchg   %ax,%ax
  8011e0:	31 ff                	xor    %edi,%edi
  8011e2:	89 e8                	mov    %ebp,%eax
  8011e4:	89 f2                	mov    %esi,%edx
  8011e6:	f7 f3                	div    %ebx
  8011e8:	89 fa                	mov    %edi,%edx
  8011ea:	83 c4 1c             	add    $0x1c,%esp
  8011ed:	5b                   	pop    %ebx
  8011ee:	5e                   	pop    %esi
  8011ef:	5f                   	pop    %edi
  8011f0:	5d                   	pop    %ebp
  8011f1:	c3                   	ret    
  8011f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8011f8:	39 f2                	cmp    %esi,%edx
  8011fa:	72 06                	jb     801202 <__udivdi3+0x102>
  8011fc:	31 c0                	xor    %eax,%eax
  8011fe:	39 eb                	cmp    %ebp,%ebx
  801200:	77 d2                	ja     8011d4 <__udivdi3+0xd4>
  801202:	b8 01 00 00 00       	mov    $0x1,%eax
  801207:	eb cb                	jmp    8011d4 <__udivdi3+0xd4>
  801209:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801210:	89 d8                	mov    %ebx,%eax
  801212:	31 ff                	xor    %edi,%edi
  801214:	eb be                	jmp    8011d4 <__udivdi3+0xd4>
  801216:	66 90                	xchg   %ax,%ax
  801218:	66 90                	xchg   %ax,%ax
  80121a:	66 90                	xchg   %ax,%ax
  80121c:	66 90                	xchg   %ax,%ax
  80121e:	66 90                	xchg   %ax,%ax

00801220 <__umoddi3>:
  801220:	55                   	push   %ebp
  801221:	57                   	push   %edi
  801222:	56                   	push   %esi
  801223:	53                   	push   %ebx
  801224:	83 ec 1c             	sub    $0x1c,%esp
  801227:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80122b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80122f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801233:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801237:	85 ed                	test   %ebp,%ebp
  801239:	89 f0                	mov    %esi,%eax
  80123b:	89 da                	mov    %ebx,%edx
  80123d:	75 19                	jne    801258 <__umoddi3+0x38>
  80123f:	39 df                	cmp    %ebx,%edi
  801241:	0f 86 b1 00 00 00    	jbe    8012f8 <__umoddi3+0xd8>
  801247:	f7 f7                	div    %edi
  801249:	89 d0                	mov    %edx,%eax
  80124b:	31 d2                	xor    %edx,%edx
  80124d:	83 c4 1c             	add    $0x1c,%esp
  801250:	5b                   	pop    %ebx
  801251:	5e                   	pop    %esi
  801252:	5f                   	pop    %edi
  801253:	5d                   	pop    %ebp
  801254:	c3                   	ret    
  801255:	8d 76 00             	lea    0x0(%esi),%esi
  801258:	39 dd                	cmp    %ebx,%ebp
  80125a:	77 f1                	ja     80124d <__umoddi3+0x2d>
  80125c:	0f bd cd             	bsr    %ebp,%ecx
  80125f:	83 f1 1f             	xor    $0x1f,%ecx
  801262:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801266:	0f 84 b4 00 00 00    	je     801320 <__umoddi3+0x100>
  80126c:	b8 20 00 00 00       	mov    $0x20,%eax
  801271:	89 c2                	mov    %eax,%edx
  801273:	8b 44 24 04          	mov    0x4(%esp),%eax
  801277:	29 c2                	sub    %eax,%edx
  801279:	89 c1                	mov    %eax,%ecx
  80127b:	89 f8                	mov    %edi,%eax
  80127d:	d3 e5                	shl    %cl,%ebp
  80127f:	89 d1                	mov    %edx,%ecx
  801281:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801285:	d3 e8                	shr    %cl,%eax
  801287:	09 c5                	or     %eax,%ebp
  801289:	8b 44 24 04          	mov    0x4(%esp),%eax
  80128d:	89 c1                	mov    %eax,%ecx
  80128f:	d3 e7                	shl    %cl,%edi
  801291:	89 d1                	mov    %edx,%ecx
  801293:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801297:	89 df                	mov    %ebx,%edi
  801299:	d3 ef                	shr    %cl,%edi
  80129b:	89 c1                	mov    %eax,%ecx
  80129d:	89 f0                	mov    %esi,%eax
  80129f:	d3 e3                	shl    %cl,%ebx
  8012a1:	89 d1                	mov    %edx,%ecx
  8012a3:	89 fa                	mov    %edi,%edx
  8012a5:	d3 e8                	shr    %cl,%eax
  8012a7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012ac:	09 d8                	or     %ebx,%eax
  8012ae:	f7 f5                	div    %ebp
  8012b0:	d3 e6                	shl    %cl,%esi
  8012b2:	89 d1                	mov    %edx,%ecx
  8012b4:	f7 64 24 08          	mull   0x8(%esp)
  8012b8:	39 d1                	cmp    %edx,%ecx
  8012ba:	89 c3                	mov    %eax,%ebx
  8012bc:	89 d7                	mov    %edx,%edi
  8012be:	72 06                	jb     8012c6 <__umoddi3+0xa6>
  8012c0:	75 0e                	jne    8012d0 <__umoddi3+0xb0>
  8012c2:	39 c6                	cmp    %eax,%esi
  8012c4:	73 0a                	jae    8012d0 <__umoddi3+0xb0>
  8012c6:	2b 44 24 08          	sub    0x8(%esp),%eax
  8012ca:	19 ea                	sbb    %ebp,%edx
  8012cc:	89 d7                	mov    %edx,%edi
  8012ce:	89 c3                	mov    %eax,%ebx
  8012d0:	89 ca                	mov    %ecx,%edx
  8012d2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8012d7:	29 de                	sub    %ebx,%esi
  8012d9:	19 fa                	sbb    %edi,%edx
  8012db:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  8012df:	89 d0                	mov    %edx,%eax
  8012e1:	d3 e0                	shl    %cl,%eax
  8012e3:	89 d9                	mov    %ebx,%ecx
  8012e5:	d3 ee                	shr    %cl,%esi
  8012e7:	d3 ea                	shr    %cl,%edx
  8012e9:	09 f0                	or     %esi,%eax
  8012eb:	83 c4 1c             	add    $0x1c,%esp
  8012ee:	5b                   	pop    %ebx
  8012ef:	5e                   	pop    %esi
  8012f0:	5f                   	pop    %edi
  8012f1:	5d                   	pop    %ebp
  8012f2:	c3                   	ret    
  8012f3:	90                   	nop
  8012f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012f8:	85 ff                	test   %edi,%edi
  8012fa:	89 f9                	mov    %edi,%ecx
  8012fc:	75 0b                	jne    801309 <__umoddi3+0xe9>
  8012fe:	b8 01 00 00 00       	mov    $0x1,%eax
  801303:	31 d2                	xor    %edx,%edx
  801305:	f7 f7                	div    %edi
  801307:	89 c1                	mov    %eax,%ecx
  801309:	89 d8                	mov    %ebx,%eax
  80130b:	31 d2                	xor    %edx,%edx
  80130d:	f7 f1                	div    %ecx
  80130f:	89 f0                	mov    %esi,%eax
  801311:	f7 f1                	div    %ecx
  801313:	e9 31 ff ff ff       	jmp    801249 <__umoddi3+0x29>
  801318:	90                   	nop
  801319:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801320:	39 dd                	cmp    %ebx,%ebp
  801322:	72 08                	jb     80132c <__umoddi3+0x10c>
  801324:	39 f7                	cmp    %esi,%edi
  801326:	0f 87 21 ff ff ff    	ja     80124d <__umoddi3+0x2d>
  80132c:	89 da                	mov    %ebx,%edx
  80132e:	89 f0                	mov    %esi,%eax
  801330:	29 f8                	sub    %edi,%eax
  801332:	19 ea                	sbb    %ebp,%edx
  801334:	e9 14 ff ff ff       	jmp    80124d <__umoddi3+0x2d>
