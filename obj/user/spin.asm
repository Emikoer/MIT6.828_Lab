
obj/user/spin.debug:     file format elf32-i386


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
  80003a:	68 c0 21 80 00       	push   $0x8021c0
  80003f:	e8 66 01 00 00       	call   8001aa <cprintf>
	if ((env = fork()) == 0) {
  800044:	e8 5e 0e 00 00       	call   800ea7 <fork>
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	85 c0                	test   %eax,%eax
  80004e:	75 12                	jne    800062 <umain+0x2f>
		cprintf("I am the child.  Spinning...\n");
  800050:	83 ec 0c             	sub    $0xc,%esp
  800053:	68 38 22 80 00       	push   $0x802238
  800058:	e8 4d 01 00 00       	call   8001aa <cprintf>
  80005d:	83 c4 10             	add    $0x10,%esp
  800060:	eb fe                	jmp    800060 <umain+0x2d>
  800062:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800064:	83 ec 0c             	sub    $0xc,%esp
  800067:	68 e8 21 80 00       	push   $0x8021e8
  80006c:	e8 39 01 00 00       	call   8001aa <cprintf>
	sys_yield();
  800071:	e8 2d 0b 00 00       	call   800ba3 <sys_yield>
	sys_yield();
  800076:	e8 28 0b 00 00       	call   800ba3 <sys_yield>
	sys_yield();
  80007b:	e8 23 0b 00 00       	call   800ba3 <sys_yield>
	sys_yield();
  800080:	e8 1e 0b 00 00       	call   800ba3 <sys_yield>
	sys_yield();
  800085:	e8 19 0b 00 00       	call   800ba3 <sys_yield>
	sys_yield();
  80008a:	e8 14 0b 00 00       	call   800ba3 <sys_yield>
	sys_yield();
  80008f:	e8 0f 0b 00 00       	call   800ba3 <sys_yield>
	sys_yield();
  800094:	e8 0a 0b 00 00       	call   800ba3 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  800099:	c7 04 24 10 22 80 00 	movl   $0x802210,(%esp)
  8000a0:	e8 05 01 00 00       	call   8001aa <cprintf>
	sys_env_destroy(env);
  8000a5:	89 1c 24             	mov    %ebx,(%esp)
  8000a8:	e8 96 0a 00 00       	call   800b43 <sys_env_destroy>
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
  8000c0:	e8 bf 0a 00 00       	call   800b84 <sys_getenvid>
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d2:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d7:	85 db                	test   %ebx,%ebx
  8000d9:	7e 07                	jle    8000e2 <libmain+0x2d>
		binaryname = argv[0];
  8000db:	8b 06                	mov    (%esi),%eax
  8000dd:	a3 00 30 80 00       	mov    %eax,0x803000

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
  8000fe:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800101:	e8 84 11 00 00       	call   80128a <close_all>
	sys_env_destroy(0);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	6a 00                	push   $0x0
  80010b:	e8 33 0a 00 00       	call   800b43 <sys_env_destroy>
}
  800110:	83 c4 10             	add    $0x10,%esp
  800113:	c9                   	leave  
  800114:	c3                   	ret    

00800115 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800115:	55                   	push   %ebp
  800116:	89 e5                	mov    %esp,%ebp
  800118:	53                   	push   %ebx
  800119:	83 ec 04             	sub    $0x4,%esp
  80011c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80011f:	8b 13                	mov    (%ebx),%edx
  800121:	8d 42 01             	lea    0x1(%edx),%eax
  800124:	89 03                	mov    %eax,(%ebx)
  800126:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800129:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80012d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800132:	74 09                	je     80013d <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800134:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800138:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80013b:	c9                   	leave  
  80013c:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80013d:	83 ec 08             	sub    $0x8,%esp
  800140:	68 ff 00 00 00       	push   $0xff
  800145:	8d 43 08             	lea    0x8(%ebx),%eax
  800148:	50                   	push   %eax
  800149:	e8 b8 09 00 00       	call   800b06 <sys_cputs>
		b->idx = 0;
  80014e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800154:	83 c4 10             	add    $0x10,%esp
  800157:	eb db                	jmp    800134 <putch+0x1f>

00800159 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800159:	55                   	push   %ebp
  80015a:	89 e5                	mov    %esp,%ebp
  80015c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800162:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800169:	00 00 00 
	b.cnt = 0;
  80016c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800173:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800176:	ff 75 0c             	pushl  0xc(%ebp)
  800179:	ff 75 08             	pushl  0x8(%ebp)
  80017c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800182:	50                   	push   %eax
  800183:	68 15 01 80 00       	push   $0x800115
  800188:	e8 1a 01 00 00       	call   8002a7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80018d:	83 c4 08             	add    $0x8,%esp
  800190:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800196:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80019c:	50                   	push   %eax
  80019d:	e8 64 09 00 00       	call   800b06 <sys_cputs>

	return b.cnt;
}
  8001a2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a8:	c9                   	leave  
  8001a9:	c3                   	ret    

008001aa <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001aa:	55                   	push   %ebp
  8001ab:	89 e5                	mov    %esp,%ebp
  8001ad:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001b0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b3:	50                   	push   %eax
  8001b4:	ff 75 08             	pushl  0x8(%ebp)
  8001b7:	e8 9d ff ff ff       	call   800159 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001bc:	c9                   	leave  
  8001bd:	c3                   	ret    

008001be <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001be:	55                   	push   %ebp
  8001bf:	89 e5                	mov    %esp,%ebp
  8001c1:	57                   	push   %edi
  8001c2:	56                   	push   %esi
  8001c3:	53                   	push   %ebx
  8001c4:	83 ec 1c             	sub    $0x1c,%esp
  8001c7:	89 c7                	mov    %eax,%edi
  8001c9:	89 d6                	mov    %edx,%esi
  8001cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001d4:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001da:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001df:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001e2:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001e5:	39 d3                	cmp    %edx,%ebx
  8001e7:	72 05                	jb     8001ee <printnum+0x30>
  8001e9:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001ec:	77 7a                	ja     800268 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ee:	83 ec 0c             	sub    $0xc,%esp
  8001f1:	ff 75 18             	pushl  0x18(%ebp)
  8001f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8001f7:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001fa:	53                   	push   %ebx
  8001fb:	ff 75 10             	pushl  0x10(%ebp)
  8001fe:	83 ec 08             	sub    $0x8,%esp
  800201:	ff 75 e4             	pushl  -0x1c(%ebp)
  800204:	ff 75 e0             	pushl  -0x20(%ebp)
  800207:	ff 75 dc             	pushl  -0x24(%ebp)
  80020a:	ff 75 d8             	pushl  -0x28(%ebp)
  80020d:	e8 6e 1d 00 00       	call   801f80 <__udivdi3>
  800212:	83 c4 18             	add    $0x18,%esp
  800215:	52                   	push   %edx
  800216:	50                   	push   %eax
  800217:	89 f2                	mov    %esi,%edx
  800219:	89 f8                	mov    %edi,%eax
  80021b:	e8 9e ff ff ff       	call   8001be <printnum>
  800220:	83 c4 20             	add    $0x20,%esp
  800223:	eb 13                	jmp    800238 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800225:	83 ec 08             	sub    $0x8,%esp
  800228:	56                   	push   %esi
  800229:	ff 75 18             	pushl  0x18(%ebp)
  80022c:	ff d7                	call   *%edi
  80022e:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800231:	83 eb 01             	sub    $0x1,%ebx
  800234:	85 db                	test   %ebx,%ebx
  800236:	7f ed                	jg     800225 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800238:	83 ec 08             	sub    $0x8,%esp
  80023b:	56                   	push   %esi
  80023c:	83 ec 04             	sub    $0x4,%esp
  80023f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800242:	ff 75 e0             	pushl  -0x20(%ebp)
  800245:	ff 75 dc             	pushl  -0x24(%ebp)
  800248:	ff 75 d8             	pushl  -0x28(%ebp)
  80024b:	e8 50 1e 00 00       	call   8020a0 <__umoddi3>
  800250:	83 c4 14             	add    $0x14,%esp
  800253:	0f be 80 60 22 80 00 	movsbl 0x802260(%eax),%eax
  80025a:	50                   	push   %eax
  80025b:	ff d7                	call   *%edi
}
  80025d:	83 c4 10             	add    $0x10,%esp
  800260:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800263:	5b                   	pop    %ebx
  800264:	5e                   	pop    %esi
  800265:	5f                   	pop    %edi
  800266:	5d                   	pop    %ebp
  800267:	c3                   	ret    
  800268:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80026b:	eb c4                	jmp    800231 <printnum+0x73>

0080026d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80026d:	55                   	push   %ebp
  80026e:	89 e5                	mov    %esp,%ebp
  800270:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800273:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800277:	8b 10                	mov    (%eax),%edx
  800279:	3b 50 04             	cmp    0x4(%eax),%edx
  80027c:	73 0a                	jae    800288 <sprintputch+0x1b>
		*b->buf++ = ch;
  80027e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800281:	89 08                	mov    %ecx,(%eax)
  800283:	8b 45 08             	mov    0x8(%ebp),%eax
  800286:	88 02                	mov    %al,(%edx)
}
  800288:	5d                   	pop    %ebp
  800289:	c3                   	ret    

0080028a <printfmt>:
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800290:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800293:	50                   	push   %eax
  800294:	ff 75 10             	pushl  0x10(%ebp)
  800297:	ff 75 0c             	pushl  0xc(%ebp)
  80029a:	ff 75 08             	pushl  0x8(%ebp)
  80029d:	e8 05 00 00 00       	call   8002a7 <vprintfmt>
}
  8002a2:	83 c4 10             	add    $0x10,%esp
  8002a5:	c9                   	leave  
  8002a6:	c3                   	ret    

008002a7 <vprintfmt>:
{
  8002a7:	55                   	push   %ebp
  8002a8:	89 e5                	mov    %esp,%ebp
  8002aa:	57                   	push   %edi
  8002ab:	56                   	push   %esi
  8002ac:	53                   	push   %ebx
  8002ad:	83 ec 2c             	sub    $0x2c,%esp
  8002b0:	8b 75 08             	mov    0x8(%ebp),%esi
  8002b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002b6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002b9:	e9 c1 03 00 00       	jmp    80067f <vprintfmt+0x3d8>
		padc = ' ';
  8002be:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8002c2:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8002c9:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8002d0:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002d7:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002dc:	8d 47 01             	lea    0x1(%edi),%eax
  8002df:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002e2:	0f b6 17             	movzbl (%edi),%edx
  8002e5:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002e8:	3c 55                	cmp    $0x55,%al
  8002ea:	0f 87 12 04 00 00    	ja     800702 <vprintfmt+0x45b>
  8002f0:	0f b6 c0             	movzbl %al,%eax
  8002f3:	ff 24 85 a0 23 80 00 	jmp    *0x8023a0(,%eax,4)
  8002fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002fd:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800301:	eb d9                	jmp    8002dc <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800303:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800306:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80030a:	eb d0                	jmp    8002dc <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80030c:	0f b6 d2             	movzbl %dl,%edx
  80030f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800312:	b8 00 00 00 00       	mov    $0x0,%eax
  800317:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80031a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80031d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800321:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800324:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800327:	83 f9 09             	cmp    $0x9,%ecx
  80032a:	77 55                	ja     800381 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  80032c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80032f:	eb e9                	jmp    80031a <vprintfmt+0x73>
			precision = va_arg(ap, int);
  800331:	8b 45 14             	mov    0x14(%ebp),%eax
  800334:	8b 00                	mov    (%eax),%eax
  800336:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800339:	8b 45 14             	mov    0x14(%ebp),%eax
  80033c:	8d 40 04             	lea    0x4(%eax),%eax
  80033f:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800342:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800345:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800349:	79 91                	jns    8002dc <vprintfmt+0x35>
				width = precision, precision = -1;
  80034b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80034e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800351:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800358:	eb 82                	jmp    8002dc <vprintfmt+0x35>
  80035a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80035d:	85 c0                	test   %eax,%eax
  80035f:	ba 00 00 00 00       	mov    $0x0,%edx
  800364:	0f 49 d0             	cmovns %eax,%edx
  800367:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80036a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80036d:	e9 6a ff ff ff       	jmp    8002dc <vprintfmt+0x35>
  800372:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800375:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80037c:	e9 5b ff ff ff       	jmp    8002dc <vprintfmt+0x35>
  800381:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800384:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800387:	eb bc                	jmp    800345 <vprintfmt+0x9e>
			lflag++;
  800389:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80038c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80038f:	e9 48 ff ff ff       	jmp    8002dc <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  800394:	8b 45 14             	mov    0x14(%ebp),%eax
  800397:	8d 78 04             	lea    0x4(%eax),%edi
  80039a:	83 ec 08             	sub    $0x8,%esp
  80039d:	53                   	push   %ebx
  80039e:	ff 30                	pushl  (%eax)
  8003a0:	ff d6                	call   *%esi
			break;
  8003a2:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003a5:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003a8:	e9 cf 02 00 00       	jmp    80067c <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  8003ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b0:	8d 78 04             	lea    0x4(%eax),%edi
  8003b3:	8b 00                	mov    (%eax),%eax
  8003b5:	99                   	cltd   
  8003b6:	31 d0                	xor    %edx,%eax
  8003b8:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003ba:	83 f8 0f             	cmp    $0xf,%eax
  8003bd:	7f 23                	jg     8003e2 <vprintfmt+0x13b>
  8003bf:	8b 14 85 00 25 80 00 	mov    0x802500(,%eax,4),%edx
  8003c6:	85 d2                	test   %edx,%edx
  8003c8:	74 18                	je     8003e2 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8003ca:	52                   	push   %edx
  8003cb:	68 71 27 80 00       	push   $0x802771
  8003d0:	53                   	push   %ebx
  8003d1:	56                   	push   %esi
  8003d2:	e8 b3 fe ff ff       	call   80028a <printfmt>
  8003d7:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003da:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003dd:	e9 9a 02 00 00       	jmp    80067c <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  8003e2:	50                   	push   %eax
  8003e3:	68 78 22 80 00       	push   $0x802278
  8003e8:	53                   	push   %ebx
  8003e9:	56                   	push   %esi
  8003ea:	e8 9b fe ff ff       	call   80028a <printfmt>
  8003ef:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003f2:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003f5:	e9 82 02 00 00       	jmp    80067c <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  8003fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fd:	83 c0 04             	add    $0x4,%eax
  800400:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800403:	8b 45 14             	mov    0x14(%ebp),%eax
  800406:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800408:	85 ff                	test   %edi,%edi
  80040a:	b8 71 22 80 00       	mov    $0x802271,%eax
  80040f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800412:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800416:	0f 8e bd 00 00 00    	jle    8004d9 <vprintfmt+0x232>
  80041c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800420:	75 0e                	jne    800430 <vprintfmt+0x189>
  800422:	89 75 08             	mov    %esi,0x8(%ebp)
  800425:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800428:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80042b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80042e:	eb 6d                	jmp    80049d <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  800430:	83 ec 08             	sub    $0x8,%esp
  800433:	ff 75 d0             	pushl  -0x30(%ebp)
  800436:	57                   	push   %edi
  800437:	e8 6e 03 00 00       	call   8007aa <strnlen>
  80043c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80043f:	29 c1                	sub    %eax,%ecx
  800441:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800444:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800447:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80044b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80044e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800451:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800453:	eb 0f                	jmp    800464 <vprintfmt+0x1bd>
					putch(padc, putdat);
  800455:	83 ec 08             	sub    $0x8,%esp
  800458:	53                   	push   %ebx
  800459:	ff 75 e0             	pushl  -0x20(%ebp)
  80045c:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80045e:	83 ef 01             	sub    $0x1,%edi
  800461:	83 c4 10             	add    $0x10,%esp
  800464:	85 ff                	test   %edi,%edi
  800466:	7f ed                	jg     800455 <vprintfmt+0x1ae>
  800468:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80046b:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80046e:	85 c9                	test   %ecx,%ecx
  800470:	b8 00 00 00 00       	mov    $0x0,%eax
  800475:	0f 49 c1             	cmovns %ecx,%eax
  800478:	29 c1                	sub    %eax,%ecx
  80047a:	89 75 08             	mov    %esi,0x8(%ebp)
  80047d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800480:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800483:	89 cb                	mov    %ecx,%ebx
  800485:	eb 16                	jmp    80049d <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  800487:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80048b:	75 31                	jne    8004be <vprintfmt+0x217>
					putch(ch, putdat);
  80048d:	83 ec 08             	sub    $0x8,%esp
  800490:	ff 75 0c             	pushl  0xc(%ebp)
  800493:	50                   	push   %eax
  800494:	ff 55 08             	call   *0x8(%ebp)
  800497:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80049a:	83 eb 01             	sub    $0x1,%ebx
  80049d:	83 c7 01             	add    $0x1,%edi
  8004a0:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8004a4:	0f be c2             	movsbl %dl,%eax
  8004a7:	85 c0                	test   %eax,%eax
  8004a9:	74 59                	je     800504 <vprintfmt+0x25d>
  8004ab:	85 f6                	test   %esi,%esi
  8004ad:	78 d8                	js     800487 <vprintfmt+0x1e0>
  8004af:	83 ee 01             	sub    $0x1,%esi
  8004b2:	79 d3                	jns    800487 <vprintfmt+0x1e0>
  8004b4:	89 df                	mov    %ebx,%edi
  8004b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8004b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004bc:	eb 37                	jmp    8004f5 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004be:	0f be d2             	movsbl %dl,%edx
  8004c1:	83 ea 20             	sub    $0x20,%edx
  8004c4:	83 fa 5e             	cmp    $0x5e,%edx
  8004c7:	76 c4                	jbe    80048d <vprintfmt+0x1e6>
					putch('?', putdat);
  8004c9:	83 ec 08             	sub    $0x8,%esp
  8004cc:	ff 75 0c             	pushl  0xc(%ebp)
  8004cf:	6a 3f                	push   $0x3f
  8004d1:	ff 55 08             	call   *0x8(%ebp)
  8004d4:	83 c4 10             	add    $0x10,%esp
  8004d7:	eb c1                	jmp    80049a <vprintfmt+0x1f3>
  8004d9:	89 75 08             	mov    %esi,0x8(%ebp)
  8004dc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004df:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004e2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004e5:	eb b6                	jmp    80049d <vprintfmt+0x1f6>
				putch(' ', putdat);
  8004e7:	83 ec 08             	sub    $0x8,%esp
  8004ea:	53                   	push   %ebx
  8004eb:	6a 20                	push   $0x20
  8004ed:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004ef:	83 ef 01             	sub    $0x1,%edi
  8004f2:	83 c4 10             	add    $0x10,%esp
  8004f5:	85 ff                	test   %edi,%edi
  8004f7:	7f ee                	jg     8004e7 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  8004f9:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004fc:	89 45 14             	mov    %eax,0x14(%ebp)
  8004ff:	e9 78 01 00 00       	jmp    80067c <vprintfmt+0x3d5>
  800504:	89 df                	mov    %ebx,%edi
  800506:	8b 75 08             	mov    0x8(%ebp),%esi
  800509:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80050c:	eb e7                	jmp    8004f5 <vprintfmt+0x24e>
	if (lflag >= 2)
  80050e:	83 f9 01             	cmp    $0x1,%ecx
  800511:	7e 3f                	jle    800552 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800513:	8b 45 14             	mov    0x14(%ebp),%eax
  800516:	8b 50 04             	mov    0x4(%eax),%edx
  800519:	8b 00                	mov    (%eax),%eax
  80051b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80051e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800521:	8b 45 14             	mov    0x14(%ebp),%eax
  800524:	8d 40 08             	lea    0x8(%eax),%eax
  800527:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80052a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80052e:	79 5c                	jns    80058c <vprintfmt+0x2e5>
				putch('-', putdat);
  800530:	83 ec 08             	sub    $0x8,%esp
  800533:	53                   	push   %ebx
  800534:	6a 2d                	push   $0x2d
  800536:	ff d6                	call   *%esi
				num = -(long long) num;
  800538:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80053b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80053e:	f7 da                	neg    %edx
  800540:	83 d1 00             	adc    $0x0,%ecx
  800543:	f7 d9                	neg    %ecx
  800545:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800548:	b8 0a 00 00 00       	mov    $0xa,%eax
  80054d:	e9 10 01 00 00       	jmp    800662 <vprintfmt+0x3bb>
	else if (lflag)
  800552:	85 c9                	test   %ecx,%ecx
  800554:	75 1b                	jne    800571 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800556:	8b 45 14             	mov    0x14(%ebp),%eax
  800559:	8b 00                	mov    (%eax),%eax
  80055b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80055e:	89 c1                	mov    %eax,%ecx
  800560:	c1 f9 1f             	sar    $0x1f,%ecx
  800563:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800566:	8b 45 14             	mov    0x14(%ebp),%eax
  800569:	8d 40 04             	lea    0x4(%eax),%eax
  80056c:	89 45 14             	mov    %eax,0x14(%ebp)
  80056f:	eb b9                	jmp    80052a <vprintfmt+0x283>
		return va_arg(*ap, long);
  800571:	8b 45 14             	mov    0x14(%ebp),%eax
  800574:	8b 00                	mov    (%eax),%eax
  800576:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800579:	89 c1                	mov    %eax,%ecx
  80057b:	c1 f9 1f             	sar    $0x1f,%ecx
  80057e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800581:	8b 45 14             	mov    0x14(%ebp),%eax
  800584:	8d 40 04             	lea    0x4(%eax),%eax
  800587:	89 45 14             	mov    %eax,0x14(%ebp)
  80058a:	eb 9e                	jmp    80052a <vprintfmt+0x283>
			num = getint(&ap, lflag);
  80058c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80058f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800592:	b8 0a 00 00 00       	mov    $0xa,%eax
  800597:	e9 c6 00 00 00       	jmp    800662 <vprintfmt+0x3bb>
	if (lflag >= 2)
  80059c:	83 f9 01             	cmp    $0x1,%ecx
  80059f:	7e 18                	jle    8005b9 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8005a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a4:	8b 10                	mov    (%eax),%edx
  8005a6:	8b 48 04             	mov    0x4(%eax),%ecx
  8005a9:	8d 40 08             	lea    0x8(%eax),%eax
  8005ac:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005af:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b4:	e9 a9 00 00 00       	jmp    800662 <vprintfmt+0x3bb>
	else if (lflag)
  8005b9:	85 c9                	test   %ecx,%ecx
  8005bb:	75 1a                	jne    8005d7 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  8005bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c0:	8b 10                	mov    (%eax),%edx
  8005c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005c7:	8d 40 04             	lea    0x4(%eax),%eax
  8005ca:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005cd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d2:	e9 8b 00 00 00       	jmp    800662 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8005d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005da:	8b 10                	mov    (%eax),%edx
  8005dc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e1:	8d 40 04             	lea    0x4(%eax),%eax
  8005e4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005e7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ec:	eb 74                	jmp    800662 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8005ee:	83 f9 01             	cmp    $0x1,%ecx
  8005f1:	7e 15                	jle    800608 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  8005f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f6:	8b 10                	mov    (%eax),%edx
  8005f8:	8b 48 04             	mov    0x4(%eax),%ecx
  8005fb:	8d 40 08             	lea    0x8(%eax),%eax
  8005fe:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800601:	b8 08 00 00 00       	mov    $0x8,%eax
  800606:	eb 5a                	jmp    800662 <vprintfmt+0x3bb>
	else if (lflag)
  800608:	85 c9                	test   %ecx,%ecx
  80060a:	75 17                	jne    800623 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  80060c:	8b 45 14             	mov    0x14(%ebp),%eax
  80060f:	8b 10                	mov    (%eax),%edx
  800611:	b9 00 00 00 00       	mov    $0x0,%ecx
  800616:	8d 40 04             	lea    0x4(%eax),%eax
  800619:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80061c:	b8 08 00 00 00       	mov    $0x8,%eax
  800621:	eb 3f                	jmp    800662 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800623:	8b 45 14             	mov    0x14(%ebp),%eax
  800626:	8b 10                	mov    (%eax),%edx
  800628:	b9 00 00 00 00       	mov    $0x0,%ecx
  80062d:	8d 40 04             	lea    0x4(%eax),%eax
  800630:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800633:	b8 08 00 00 00       	mov    $0x8,%eax
  800638:	eb 28                	jmp    800662 <vprintfmt+0x3bb>
			putch('0', putdat);
  80063a:	83 ec 08             	sub    $0x8,%esp
  80063d:	53                   	push   %ebx
  80063e:	6a 30                	push   $0x30
  800640:	ff d6                	call   *%esi
			putch('x', putdat);
  800642:	83 c4 08             	add    $0x8,%esp
  800645:	53                   	push   %ebx
  800646:	6a 78                	push   $0x78
  800648:	ff d6                	call   *%esi
			num = (unsigned long long)
  80064a:	8b 45 14             	mov    0x14(%ebp),%eax
  80064d:	8b 10                	mov    (%eax),%edx
  80064f:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800654:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800657:	8d 40 04             	lea    0x4(%eax),%eax
  80065a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80065d:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800662:	83 ec 0c             	sub    $0xc,%esp
  800665:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800669:	57                   	push   %edi
  80066a:	ff 75 e0             	pushl  -0x20(%ebp)
  80066d:	50                   	push   %eax
  80066e:	51                   	push   %ecx
  80066f:	52                   	push   %edx
  800670:	89 da                	mov    %ebx,%edx
  800672:	89 f0                	mov    %esi,%eax
  800674:	e8 45 fb ff ff       	call   8001be <printnum>
			break;
  800679:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80067c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80067f:	83 c7 01             	add    $0x1,%edi
  800682:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800686:	83 f8 25             	cmp    $0x25,%eax
  800689:	0f 84 2f fc ff ff    	je     8002be <vprintfmt+0x17>
			if (ch == '\0')
  80068f:	85 c0                	test   %eax,%eax
  800691:	0f 84 8b 00 00 00    	je     800722 <vprintfmt+0x47b>
			putch(ch, putdat);
  800697:	83 ec 08             	sub    $0x8,%esp
  80069a:	53                   	push   %ebx
  80069b:	50                   	push   %eax
  80069c:	ff d6                	call   *%esi
  80069e:	83 c4 10             	add    $0x10,%esp
  8006a1:	eb dc                	jmp    80067f <vprintfmt+0x3d8>
	if (lflag >= 2)
  8006a3:	83 f9 01             	cmp    $0x1,%ecx
  8006a6:	7e 15                	jle    8006bd <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  8006a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ab:	8b 10                	mov    (%eax),%edx
  8006ad:	8b 48 04             	mov    0x4(%eax),%ecx
  8006b0:	8d 40 08             	lea    0x8(%eax),%eax
  8006b3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b6:	b8 10 00 00 00       	mov    $0x10,%eax
  8006bb:	eb a5                	jmp    800662 <vprintfmt+0x3bb>
	else if (lflag)
  8006bd:	85 c9                	test   %ecx,%ecx
  8006bf:	75 17                	jne    8006d8 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  8006c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c4:	8b 10                	mov    (%eax),%edx
  8006c6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006cb:	8d 40 04             	lea    0x4(%eax),%eax
  8006ce:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d1:	b8 10 00 00 00       	mov    $0x10,%eax
  8006d6:	eb 8a                	jmp    800662 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8006d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006db:	8b 10                	mov    (%eax),%edx
  8006dd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006e2:	8d 40 04             	lea    0x4(%eax),%eax
  8006e5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006e8:	b8 10 00 00 00       	mov    $0x10,%eax
  8006ed:	e9 70 ff ff ff       	jmp    800662 <vprintfmt+0x3bb>
			putch(ch, putdat);
  8006f2:	83 ec 08             	sub    $0x8,%esp
  8006f5:	53                   	push   %ebx
  8006f6:	6a 25                	push   $0x25
  8006f8:	ff d6                	call   *%esi
			break;
  8006fa:	83 c4 10             	add    $0x10,%esp
  8006fd:	e9 7a ff ff ff       	jmp    80067c <vprintfmt+0x3d5>
			putch('%', putdat);
  800702:	83 ec 08             	sub    $0x8,%esp
  800705:	53                   	push   %ebx
  800706:	6a 25                	push   $0x25
  800708:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80070a:	83 c4 10             	add    $0x10,%esp
  80070d:	89 f8                	mov    %edi,%eax
  80070f:	eb 03                	jmp    800714 <vprintfmt+0x46d>
  800711:	83 e8 01             	sub    $0x1,%eax
  800714:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800718:	75 f7                	jne    800711 <vprintfmt+0x46a>
  80071a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80071d:	e9 5a ff ff ff       	jmp    80067c <vprintfmt+0x3d5>
}
  800722:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800725:	5b                   	pop    %ebx
  800726:	5e                   	pop    %esi
  800727:	5f                   	pop    %edi
  800728:	5d                   	pop    %ebp
  800729:	c3                   	ret    

0080072a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80072a:	55                   	push   %ebp
  80072b:	89 e5                	mov    %esp,%ebp
  80072d:	83 ec 18             	sub    $0x18,%esp
  800730:	8b 45 08             	mov    0x8(%ebp),%eax
  800733:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800736:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800739:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80073d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800740:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800747:	85 c0                	test   %eax,%eax
  800749:	74 26                	je     800771 <vsnprintf+0x47>
  80074b:	85 d2                	test   %edx,%edx
  80074d:	7e 22                	jle    800771 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80074f:	ff 75 14             	pushl  0x14(%ebp)
  800752:	ff 75 10             	pushl  0x10(%ebp)
  800755:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800758:	50                   	push   %eax
  800759:	68 6d 02 80 00       	push   $0x80026d
  80075e:	e8 44 fb ff ff       	call   8002a7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800763:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800766:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800769:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80076c:	83 c4 10             	add    $0x10,%esp
}
  80076f:	c9                   	leave  
  800770:	c3                   	ret    
		return -E_INVAL;
  800771:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800776:	eb f7                	jmp    80076f <vsnprintf+0x45>

00800778 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80077e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800781:	50                   	push   %eax
  800782:	ff 75 10             	pushl  0x10(%ebp)
  800785:	ff 75 0c             	pushl  0xc(%ebp)
  800788:	ff 75 08             	pushl  0x8(%ebp)
  80078b:	e8 9a ff ff ff       	call   80072a <vsnprintf>
	va_end(ap);

	return rc;
}
  800790:	c9                   	leave  
  800791:	c3                   	ret    

00800792 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800792:	55                   	push   %ebp
  800793:	89 e5                	mov    %esp,%ebp
  800795:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800798:	b8 00 00 00 00       	mov    $0x0,%eax
  80079d:	eb 03                	jmp    8007a2 <strlen+0x10>
		n++;
  80079f:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007a2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007a6:	75 f7                	jne    80079f <strlen+0xd>
	return n;
}
  8007a8:	5d                   	pop    %ebp
  8007a9:	c3                   	ret    

008007aa <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007aa:	55                   	push   %ebp
  8007ab:	89 e5                	mov    %esp,%ebp
  8007ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b0:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b8:	eb 03                	jmp    8007bd <strnlen+0x13>
		n++;
  8007ba:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007bd:	39 d0                	cmp    %edx,%eax
  8007bf:	74 06                	je     8007c7 <strnlen+0x1d>
  8007c1:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007c5:	75 f3                	jne    8007ba <strnlen+0x10>
	return n;
}
  8007c7:	5d                   	pop    %ebp
  8007c8:	c3                   	ret    

008007c9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007c9:	55                   	push   %ebp
  8007ca:	89 e5                	mov    %esp,%ebp
  8007cc:	53                   	push   %ebx
  8007cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007d3:	89 c2                	mov    %eax,%edx
  8007d5:	83 c1 01             	add    $0x1,%ecx
  8007d8:	83 c2 01             	add    $0x1,%edx
  8007db:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007df:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007e2:	84 db                	test   %bl,%bl
  8007e4:	75 ef                	jne    8007d5 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007e6:	5b                   	pop    %ebx
  8007e7:	5d                   	pop    %ebp
  8007e8:	c3                   	ret    

008007e9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007e9:	55                   	push   %ebp
  8007ea:	89 e5                	mov    %esp,%ebp
  8007ec:	53                   	push   %ebx
  8007ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007f0:	53                   	push   %ebx
  8007f1:	e8 9c ff ff ff       	call   800792 <strlen>
  8007f6:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007f9:	ff 75 0c             	pushl  0xc(%ebp)
  8007fc:	01 d8                	add    %ebx,%eax
  8007fe:	50                   	push   %eax
  8007ff:	e8 c5 ff ff ff       	call   8007c9 <strcpy>
	return dst;
}
  800804:	89 d8                	mov    %ebx,%eax
  800806:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800809:	c9                   	leave  
  80080a:	c3                   	ret    

0080080b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80080b:	55                   	push   %ebp
  80080c:	89 e5                	mov    %esp,%ebp
  80080e:	56                   	push   %esi
  80080f:	53                   	push   %ebx
  800810:	8b 75 08             	mov    0x8(%ebp),%esi
  800813:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800816:	89 f3                	mov    %esi,%ebx
  800818:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081b:	89 f2                	mov    %esi,%edx
  80081d:	eb 0f                	jmp    80082e <strncpy+0x23>
		*dst++ = *src;
  80081f:	83 c2 01             	add    $0x1,%edx
  800822:	0f b6 01             	movzbl (%ecx),%eax
  800825:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800828:	80 39 01             	cmpb   $0x1,(%ecx)
  80082b:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80082e:	39 da                	cmp    %ebx,%edx
  800830:	75 ed                	jne    80081f <strncpy+0x14>
	}
	return ret;
}
  800832:	89 f0                	mov    %esi,%eax
  800834:	5b                   	pop    %ebx
  800835:	5e                   	pop    %esi
  800836:	5d                   	pop    %ebp
  800837:	c3                   	ret    

00800838 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	56                   	push   %esi
  80083c:	53                   	push   %ebx
  80083d:	8b 75 08             	mov    0x8(%ebp),%esi
  800840:	8b 55 0c             	mov    0xc(%ebp),%edx
  800843:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800846:	89 f0                	mov    %esi,%eax
  800848:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80084c:	85 c9                	test   %ecx,%ecx
  80084e:	75 0b                	jne    80085b <strlcpy+0x23>
  800850:	eb 17                	jmp    800869 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800852:	83 c2 01             	add    $0x1,%edx
  800855:	83 c0 01             	add    $0x1,%eax
  800858:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  80085b:	39 d8                	cmp    %ebx,%eax
  80085d:	74 07                	je     800866 <strlcpy+0x2e>
  80085f:	0f b6 0a             	movzbl (%edx),%ecx
  800862:	84 c9                	test   %cl,%cl
  800864:	75 ec                	jne    800852 <strlcpy+0x1a>
		*dst = '\0';
  800866:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800869:	29 f0                	sub    %esi,%eax
}
  80086b:	5b                   	pop    %ebx
  80086c:	5e                   	pop    %esi
  80086d:	5d                   	pop    %ebp
  80086e:	c3                   	ret    

0080086f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80086f:	55                   	push   %ebp
  800870:	89 e5                	mov    %esp,%ebp
  800872:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800875:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800878:	eb 06                	jmp    800880 <strcmp+0x11>
		p++, q++;
  80087a:	83 c1 01             	add    $0x1,%ecx
  80087d:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800880:	0f b6 01             	movzbl (%ecx),%eax
  800883:	84 c0                	test   %al,%al
  800885:	74 04                	je     80088b <strcmp+0x1c>
  800887:	3a 02                	cmp    (%edx),%al
  800889:	74 ef                	je     80087a <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80088b:	0f b6 c0             	movzbl %al,%eax
  80088e:	0f b6 12             	movzbl (%edx),%edx
  800891:	29 d0                	sub    %edx,%eax
}
  800893:	5d                   	pop    %ebp
  800894:	c3                   	ret    

00800895 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800895:	55                   	push   %ebp
  800896:	89 e5                	mov    %esp,%ebp
  800898:	53                   	push   %ebx
  800899:	8b 45 08             	mov    0x8(%ebp),%eax
  80089c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089f:	89 c3                	mov    %eax,%ebx
  8008a1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008a4:	eb 06                	jmp    8008ac <strncmp+0x17>
		n--, p++, q++;
  8008a6:	83 c0 01             	add    $0x1,%eax
  8008a9:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008ac:	39 d8                	cmp    %ebx,%eax
  8008ae:	74 16                	je     8008c6 <strncmp+0x31>
  8008b0:	0f b6 08             	movzbl (%eax),%ecx
  8008b3:	84 c9                	test   %cl,%cl
  8008b5:	74 04                	je     8008bb <strncmp+0x26>
  8008b7:	3a 0a                	cmp    (%edx),%cl
  8008b9:	74 eb                	je     8008a6 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008bb:	0f b6 00             	movzbl (%eax),%eax
  8008be:	0f b6 12             	movzbl (%edx),%edx
  8008c1:	29 d0                	sub    %edx,%eax
}
  8008c3:	5b                   	pop    %ebx
  8008c4:	5d                   	pop    %ebp
  8008c5:	c3                   	ret    
		return 0;
  8008c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008cb:	eb f6                	jmp    8008c3 <strncmp+0x2e>

008008cd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008cd:	55                   	push   %ebp
  8008ce:	89 e5                	mov    %esp,%ebp
  8008d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d7:	0f b6 10             	movzbl (%eax),%edx
  8008da:	84 d2                	test   %dl,%dl
  8008dc:	74 09                	je     8008e7 <strchr+0x1a>
		if (*s == c)
  8008de:	38 ca                	cmp    %cl,%dl
  8008e0:	74 0a                	je     8008ec <strchr+0x1f>
	for (; *s; s++)
  8008e2:	83 c0 01             	add    $0x1,%eax
  8008e5:	eb f0                	jmp    8008d7 <strchr+0xa>
			return (char *) s;
	return 0;
  8008e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008ec:	5d                   	pop    %ebp
  8008ed:	c3                   	ret    

008008ee <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ee:	55                   	push   %ebp
  8008ef:	89 e5                	mov    %esp,%ebp
  8008f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008f8:	eb 03                	jmp    8008fd <strfind+0xf>
  8008fa:	83 c0 01             	add    $0x1,%eax
  8008fd:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800900:	38 ca                	cmp    %cl,%dl
  800902:	74 04                	je     800908 <strfind+0x1a>
  800904:	84 d2                	test   %dl,%dl
  800906:	75 f2                	jne    8008fa <strfind+0xc>
			break;
	return (char *) s;
}
  800908:	5d                   	pop    %ebp
  800909:	c3                   	ret    

0080090a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	57                   	push   %edi
  80090e:	56                   	push   %esi
  80090f:	53                   	push   %ebx
  800910:	8b 7d 08             	mov    0x8(%ebp),%edi
  800913:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800916:	85 c9                	test   %ecx,%ecx
  800918:	74 13                	je     80092d <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80091a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800920:	75 05                	jne    800927 <memset+0x1d>
  800922:	f6 c1 03             	test   $0x3,%cl
  800925:	74 0d                	je     800934 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800927:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092a:	fc                   	cld    
  80092b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80092d:	89 f8                	mov    %edi,%eax
  80092f:	5b                   	pop    %ebx
  800930:	5e                   	pop    %esi
  800931:	5f                   	pop    %edi
  800932:	5d                   	pop    %ebp
  800933:	c3                   	ret    
		c &= 0xFF;
  800934:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800938:	89 d3                	mov    %edx,%ebx
  80093a:	c1 e3 08             	shl    $0x8,%ebx
  80093d:	89 d0                	mov    %edx,%eax
  80093f:	c1 e0 18             	shl    $0x18,%eax
  800942:	89 d6                	mov    %edx,%esi
  800944:	c1 e6 10             	shl    $0x10,%esi
  800947:	09 f0                	or     %esi,%eax
  800949:	09 c2                	or     %eax,%edx
  80094b:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  80094d:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800950:	89 d0                	mov    %edx,%eax
  800952:	fc                   	cld    
  800953:	f3 ab                	rep stos %eax,%es:(%edi)
  800955:	eb d6                	jmp    80092d <memset+0x23>

00800957 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800957:	55                   	push   %ebp
  800958:	89 e5                	mov    %esp,%ebp
  80095a:	57                   	push   %edi
  80095b:	56                   	push   %esi
  80095c:	8b 45 08             	mov    0x8(%ebp),%eax
  80095f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800962:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800965:	39 c6                	cmp    %eax,%esi
  800967:	73 35                	jae    80099e <memmove+0x47>
  800969:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80096c:	39 c2                	cmp    %eax,%edx
  80096e:	76 2e                	jbe    80099e <memmove+0x47>
		s += n;
		d += n;
  800970:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800973:	89 d6                	mov    %edx,%esi
  800975:	09 fe                	or     %edi,%esi
  800977:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80097d:	74 0c                	je     80098b <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80097f:	83 ef 01             	sub    $0x1,%edi
  800982:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800985:	fd                   	std    
  800986:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800988:	fc                   	cld    
  800989:	eb 21                	jmp    8009ac <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098b:	f6 c1 03             	test   $0x3,%cl
  80098e:	75 ef                	jne    80097f <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800990:	83 ef 04             	sub    $0x4,%edi
  800993:	8d 72 fc             	lea    -0x4(%edx),%esi
  800996:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800999:	fd                   	std    
  80099a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80099c:	eb ea                	jmp    800988 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099e:	89 f2                	mov    %esi,%edx
  8009a0:	09 c2                	or     %eax,%edx
  8009a2:	f6 c2 03             	test   $0x3,%dl
  8009a5:	74 09                	je     8009b0 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009a7:	89 c7                	mov    %eax,%edi
  8009a9:	fc                   	cld    
  8009aa:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ac:	5e                   	pop    %esi
  8009ad:	5f                   	pop    %edi
  8009ae:	5d                   	pop    %ebp
  8009af:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b0:	f6 c1 03             	test   $0x3,%cl
  8009b3:	75 f2                	jne    8009a7 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009b5:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009b8:	89 c7                	mov    %eax,%edi
  8009ba:	fc                   	cld    
  8009bb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009bd:	eb ed                	jmp    8009ac <memmove+0x55>

008009bf <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009bf:	55                   	push   %ebp
  8009c0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009c2:	ff 75 10             	pushl  0x10(%ebp)
  8009c5:	ff 75 0c             	pushl  0xc(%ebp)
  8009c8:	ff 75 08             	pushl  0x8(%ebp)
  8009cb:	e8 87 ff ff ff       	call   800957 <memmove>
}
  8009d0:	c9                   	leave  
  8009d1:	c3                   	ret    

008009d2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009d2:	55                   	push   %ebp
  8009d3:	89 e5                	mov    %esp,%ebp
  8009d5:	56                   	push   %esi
  8009d6:	53                   	push   %ebx
  8009d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009dd:	89 c6                	mov    %eax,%esi
  8009df:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e2:	39 f0                	cmp    %esi,%eax
  8009e4:	74 1c                	je     800a02 <memcmp+0x30>
		if (*s1 != *s2)
  8009e6:	0f b6 08             	movzbl (%eax),%ecx
  8009e9:	0f b6 1a             	movzbl (%edx),%ebx
  8009ec:	38 d9                	cmp    %bl,%cl
  8009ee:	75 08                	jne    8009f8 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009f0:	83 c0 01             	add    $0x1,%eax
  8009f3:	83 c2 01             	add    $0x1,%edx
  8009f6:	eb ea                	jmp    8009e2 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8009f8:	0f b6 c1             	movzbl %cl,%eax
  8009fb:	0f b6 db             	movzbl %bl,%ebx
  8009fe:	29 d8                	sub    %ebx,%eax
  800a00:	eb 05                	jmp    800a07 <memcmp+0x35>
	}

	return 0;
  800a02:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a07:	5b                   	pop    %ebx
  800a08:	5e                   	pop    %esi
  800a09:	5d                   	pop    %ebp
  800a0a:	c3                   	ret    

00800a0b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a14:	89 c2                	mov    %eax,%edx
  800a16:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a19:	39 d0                	cmp    %edx,%eax
  800a1b:	73 09                	jae    800a26 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a1d:	38 08                	cmp    %cl,(%eax)
  800a1f:	74 05                	je     800a26 <memfind+0x1b>
	for (; s < ends; s++)
  800a21:	83 c0 01             	add    $0x1,%eax
  800a24:	eb f3                	jmp    800a19 <memfind+0xe>
			break;
	return (void *) s;
}
  800a26:	5d                   	pop    %ebp
  800a27:	c3                   	ret    

00800a28 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a28:	55                   	push   %ebp
  800a29:	89 e5                	mov    %esp,%ebp
  800a2b:	57                   	push   %edi
  800a2c:	56                   	push   %esi
  800a2d:	53                   	push   %ebx
  800a2e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a31:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a34:	eb 03                	jmp    800a39 <strtol+0x11>
		s++;
  800a36:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a39:	0f b6 01             	movzbl (%ecx),%eax
  800a3c:	3c 20                	cmp    $0x20,%al
  800a3e:	74 f6                	je     800a36 <strtol+0xe>
  800a40:	3c 09                	cmp    $0x9,%al
  800a42:	74 f2                	je     800a36 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a44:	3c 2b                	cmp    $0x2b,%al
  800a46:	74 2e                	je     800a76 <strtol+0x4e>
	int neg = 0;
  800a48:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a4d:	3c 2d                	cmp    $0x2d,%al
  800a4f:	74 2f                	je     800a80 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a51:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a57:	75 05                	jne    800a5e <strtol+0x36>
  800a59:	80 39 30             	cmpb   $0x30,(%ecx)
  800a5c:	74 2c                	je     800a8a <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a5e:	85 db                	test   %ebx,%ebx
  800a60:	75 0a                	jne    800a6c <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a62:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a67:	80 39 30             	cmpb   $0x30,(%ecx)
  800a6a:	74 28                	je     800a94 <strtol+0x6c>
		base = 10;
  800a6c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a71:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a74:	eb 50                	jmp    800ac6 <strtol+0x9e>
		s++;
  800a76:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a79:	bf 00 00 00 00       	mov    $0x0,%edi
  800a7e:	eb d1                	jmp    800a51 <strtol+0x29>
		s++, neg = 1;
  800a80:	83 c1 01             	add    $0x1,%ecx
  800a83:	bf 01 00 00 00       	mov    $0x1,%edi
  800a88:	eb c7                	jmp    800a51 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a8a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a8e:	74 0e                	je     800a9e <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a90:	85 db                	test   %ebx,%ebx
  800a92:	75 d8                	jne    800a6c <strtol+0x44>
		s++, base = 8;
  800a94:	83 c1 01             	add    $0x1,%ecx
  800a97:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a9c:	eb ce                	jmp    800a6c <strtol+0x44>
		s += 2, base = 16;
  800a9e:	83 c1 02             	add    $0x2,%ecx
  800aa1:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aa6:	eb c4                	jmp    800a6c <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800aa8:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aab:	89 f3                	mov    %esi,%ebx
  800aad:	80 fb 19             	cmp    $0x19,%bl
  800ab0:	77 29                	ja     800adb <strtol+0xb3>
			dig = *s - 'a' + 10;
  800ab2:	0f be d2             	movsbl %dl,%edx
  800ab5:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ab8:	3b 55 10             	cmp    0x10(%ebp),%edx
  800abb:	7d 30                	jge    800aed <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800abd:	83 c1 01             	add    $0x1,%ecx
  800ac0:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ac4:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ac6:	0f b6 11             	movzbl (%ecx),%edx
  800ac9:	8d 72 d0             	lea    -0x30(%edx),%esi
  800acc:	89 f3                	mov    %esi,%ebx
  800ace:	80 fb 09             	cmp    $0x9,%bl
  800ad1:	77 d5                	ja     800aa8 <strtol+0x80>
			dig = *s - '0';
  800ad3:	0f be d2             	movsbl %dl,%edx
  800ad6:	83 ea 30             	sub    $0x30,%edx
  800ad9:	eb dd                	jmp    800ab8 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800adb:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ade:	89 f3                	mov    %esi,%ebx
  800ae0:	80 fb 19             	cmp    $0x19,%bl
  800ae3:	77 08                	ja     800aed <strtol+0xc5>
			dig = *s - 'A' + 10;
  800ae5:	0f be d2             	movsbl %dl,%edx
  800ae8:	83 ea 37             	sub    $0x37,%edx
  800aeb:	eb cb                	jmp    800ab8 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800aed:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800af1:	74 05                	je     800af8 <strtol+0xd0>
		*endptr = (char *) s;
  800af3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800af6:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800af8:	89 c2                	mov    %eax,%edx
  800afa:	f7 da                	neg    %edx
  800afc:	85 ff                	test   %edi,%edi
  800afe:	0f 45 c2             	cmovne %edx,%eax
}
  800b01:	5b                   	pop    %ebx
  800b02:	5e                   	pop    %esi
  800b03:	5f                   	pop    %edi
  800b04:	5d                   	pop    %ebp
  800b05:	c3                   	ret    

00800b06 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b06:	55                   	push   %ebp
  800b07:	89 e5                	mov    %esp,%ebp
  800b09:	57                   	push   %edi
  800b0a:	56                   	push   %esi
  800b0b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b0c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b11:	8b 55 08             	mov    0x8(%ebp),%edx
  800b14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b17:	89 c3                	mov    %eax,%ebx
  800b19:	89 c7                	mov    %eax,%edi
  800b1b:	89 c6                	mov    %eax,%esi
  800b1d:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b1f:	5b                   	pop    %ebx
  800b20:	5e                   	pop    %esi
  800b21:	5f                   	pop    %edi
  800b22:	5d                   	pop    %ebp
  800b23:	c3                   	ret    

00800b24 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	57                   	push   %edi
  800b28:	56                   	push   %esi
  800b29:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b34:	89 d1                	mov    %edx,%ecx
  800b36:	89 d3                	mov    %edx,%ebx
  800b38:	89 d7                	mov    %edx,%edi
  800b3a:	89 d6                	mov    %edx,%esi
  800b3c:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b3e:	5b                   	pop    %ebx
  800b3f:	5e                   	pop    %esi
  800b40:	5f                   	pop    %edi
  800b41:	5d                   	pop    %ebp
  800b42:	c3                   	ret    

00800b43 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	57                   	push   %edi
  800b47:	56                   	push   %esi
  800b48:	53                   	push   %ebx
  800b49:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b4c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b51:	8b 55 08             	mov    0x8(%ebp),%edx
  800b54:	b8 03 00 00 00       	mov    $0x3,%eax
  800b59:	89 cb                	mov    %ecx,%ebx
  800b5b:	89 cf                	mov    %ecx,%edi
  800b5d:	89 ce                	mov    %ecx,%esi
  800b5f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b61:	85 c0                	test   %eax,%eax
  800b63:	7f 08                	jg     800b6d <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b68:	5b                   	pop    %ebx
  800b69:	5e                   	pop    %esi
  800b6a:	5f                   	pop    %edi
  800b6b:	5d                   	pop    %ebp
  800b6c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b6d:	83 ec 0c             	sub    $0xc,%esp
  800b70:	50                   	push   %eax
  800b71:	6a 03                	push   $0x3
  800b73:	68 5f 25 80 00       	push   $0x80255f
  800b78:	6a 23                	push   $0x23
  800b7a:	68 7c 25 80 00       	push   $0x80257c
  800b7f:	e8 eb 11 00 00       	call   801d6f <_panic>

00800b84 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	57                   	push   %edi
  800b88:	56                   	push   %esi
  800b89:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b8a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8f:	b8 02 00 00 00       	mov    $0x2,%eax
  800b94:	89 d1                	mov    %edx,%ecx
  800b96:	89 d3                	mov    %edx,%ebx
  800b98:	89 d7                	mov    %edx,%edi
  800b9a:	89 d6                	mov    %edx,%esi
  800b9c:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b9e:	5b                   	pop    %ebx
  800b9f:	5e                   	pop    %esi
  800ba0:	5f                   	pop    %edi
  800ba1:	5d                   	pop    %ebp
  800ba2:	c3                   	ret    

00800ba3 <sys_yield>:

void
sys_yield(void)
{
  800ba3:	55                   	push   %ebp
  800ba4:	89 e5                	mov    %esp,%ebp
  800ba6:	57                   	push   %edi
  800ba7:	56                   	push   %esi
  800ba8:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ba9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bae:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bb3:	89 d1                	mov    %edx,%ecx
  800bb5:	89 d3                	mov    %edx,%ebx
  800bb7:	89 d7                	mov    %edx,%edi
  800bb9:	89 d6                	mov    %edx,%esi
  800bbb:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bbd:	5b                   	pop    %ebx
  800bbe:	5e                   	pop    %esi
  800bbf:	5f                   	pop    %edi
  800bc0:	5d                   	pop    %ebp
  800bc1:	c3                   	ret    

00800bc2 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	57                   	push   %edi
  800bc6:	56                   	push   %esi
  800bc7:	53                   	push   %ebx
  800bc8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bcb:	be 00 00 00 00       	mov    $0x0,%esi
  800bd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd6:	b8 04 00 00 00       	mov    $0x4,%eax
  800bdb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bde:	89 f7                	mov    %esi,%edi
  800be0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800be2:	85 c0                	test   %eax,%eax
  800be4:	7f 08                	jg     800bee <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800be6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be9:	5b                   	pop    %ebx
  800bea:	5e                   	pop    %esi
  800beb:	5f                   	pop    %edi
  800bec:	5d                   	pop    %ebp
  800bed:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bee:	83 ec 0c             	sub    $0xc,%esp
  800bf1:	50                   	push   %eax
  800bf2:	6a 04                	push   $0x4
  800bf4:	68 5f 25 80 00       	push   $0x80255f
  800bf9:	6a 23                	push   $0x23
  800bfb:	68 7c 25 80 00       	push   $0x80257c
  800c00:	e8 6a 11 00 00       	call   801d6f <_panic>

00800c05 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	57                   	push   %edi
  800c09:	56                   	push   %esi
  800c0a:	53                   	push   %ebx
  800c0b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c14:	b8 05 00 00 00       	mov    $0x5,%eax
  800c19:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c1c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c1f:	8b 75 18             	mov    0x18(%ebp),%esi
  800c22:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c24:	85 c0                	test   %eax,%eax
  800c26:	7f 08                	jg     800c30 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2b:	5b                   	pop    %ebx
  800c2c:	5e                   	pop    %esi
  800c2d:	5f                   	pop    %edi
  800c2e:	5d                   	pop    %ebp
  800c2f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c30:	83 ec 0c             	sub    $0xc,%esp
  800c33:	50                   	push   %eax
  800c34:	6a 05                	push   $0x5
  800c36:	68 5f 25 80 00       	push   $0x80255f
  800c3b:	6a 23                	push   $0x23
  800c3d:	68 7c 25 80 00       	push   $0x80257c
  800c42:	e8 28 11 00 00       	call   801d6f <_panic>

00800c47 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	57                   	push   %edi
  800c4b:	56                   	push   %esi
  800c4c:	53                   	push   %ebx
  800c4d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c50:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c55:	8b 55 08             	mov    0x8(%ebp),%edx
  800c58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5b:	b8 06 00 00 00       	mov    $0x6,%eax
  800c60:	89 df                	mov    %ebx,%edi
  800c62:	89 de                	mov    %ebx,%esi
  800c64:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c66:	85 c0                	test   %eax,%eax
  800c68:	7f 08                	jg     800c72 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6d:	5b                   	pop    %ebx
  800c6e:	5e                   	pop    %esi
  800c6f:	5f                   	pop    %edi
  800c70:	5d                   	pop    %ebp
  800c71:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c72:	83 ec 0c             	sub    $0xc,%esp
  800c75:	50                   	push   %eax
  800c76:	6a 06                	push   $0x6
  800c78:	68 5f 25 80 00       	push   $0x80255f
  800c7d:	6a 23                	push   $0x23
  800c7f:	68 7c 25 80 00       	push   $0x80257c
  800c84:	e8 e6 10 00 00       	call   801d6f <_panic>

00800c89 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c89:	55                   	push   %ebp
  800c8a:	89 e5                	mov    %esp,%ebp
  800c8c:	57                   	push   %edi
  800c8d:	56                   	push   %esi
  800c8e:	53                   	push   %ebx
  800c8f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c92:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c97:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9d:	b8 08 00 00 00       	mov    $0x8,%eax
  800ca2:	89 df                	mov    %ebx,%edi
  800ca4:	89 de                	mov    %ebx,%esi
  800ca6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ca8:	85 c0                	test   %eax,%eax
  800caa:	7f 08                	jg     800cb4 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800caf:	5b                   	pop    %ebx
  800cb0:	5e                   	pop    %esi
  800cb1:	5f                   	pop    %edi
  800cb2:	5d                   	pop    %ebp
  800cb3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb4:	83 ec 0c             	sub    $0xc,%esp
  800cb7:	50                   	push   %eax
  800cb8:	6a 08                	push   $0x8
  800cba:	68 5f 25 80 00       	push   $0x80255f
  800cbf:	6a 23                	push   $0x23
  800cc1:	68 7c 25 80 00       	push   $0x80257c
  800cc6:	e8 a4 10 00 00       	call   801d6f <_panic>

00800ccb <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	57                   	push   %edi
  800ccf:	56                   	push   %esi
  800cd0:	53                   	push   %ebx
  800cd1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cd4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdf:	b8 09 00 00 00       	mov    $0x9,%eax
  800ce4:	89 df                	mov    %ebx,%edi
  800ce6:	89 de                	mov    %ebx,%esi
  800ce8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cea:	85 c0                	test   %eax,%eax
  800cec:	7f 08                	jg     800cf6 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf1:	5b                   	pop    %ebx
  800cf2:	5e                   	pop    %esi
  800cf3:	5f                   	pop    %edi
  800cf4:	5d                   	pop    %ebp
  800cf5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf6:	83 ec 0c             	sub    $0xc,%esp
  800cf9:	50                   	push   %eax
  800cfa:	6a 09                	push   $0x9
  800cfc:	68 5f 25 80 00       	push   $0x80255f
  800d01:	6a 23                	push   $0x23
  800d03:	68 7c 25 80 00       	push   $0x80257c
  800d08:	e8 62 10 00 00       	call   801d6f <_panic>

00800d0d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	57                   	push   %edi
  800d11:	56                   	push   %esi
  800d12:	53                   	push   %ebx
  800d13:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d16:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d21:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d26:	89 df                	mov    %ebx,%edi
  800d28:	89 de                	mov    %ebx,%esi
  800d2a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d2c:	85 c0                	test   %eax,%eax
  800d2e:	7f 08                	jg     800d38 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d33:	5b                   	pop    %ebx
  800d34:	5e                   	pop    %esi
  800d35:	5f                   	pop    %edi
  800d36:	5d                   	pop    %ebp
  800d37:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d38:	83 ec 0c             	sub    $0xc,%esp
  800d3b:	50                   	push   %eax
  800d3c:	6a 0a                	push   $0xa
  800d3e:	68 5f 25 80 00       	push   $0x80255f
  800d43:	6a 23                	push   $0x23
  800d45:	68 7c 25 80 00       	push   $0x80257c
  800d4a:	e8 20 10 00 00       	call   801d6f <_panic>

00800d4f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d4f:	55                   	push   %ebp
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	57                   	push   %edi
  800d53:	56                   	push   %esi
  800d54:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d55:	8b 55 08             	mov    0x8(%ebp),%edx
  800d58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d60:	be 00 00 00 00       	mov    $0x0,%esi
  800d65:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d68:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d6b:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d6d:	5b                   	pop    %ebx
  800d6e:	5e                   	pop    %esi
  800d6f:	5f                   	pop    %edi
  800d70:	5d                   	pop    %ebp
  800d71:	c3                   	ret    

00800d72 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d72:	55                   	push   %ebp
  800d73:	89 e5                	mov    %esp,%ebp
  800d75:	57                   	push   %edi
  800d76:	56                   	push   %esi
  800d77:	53                   	push   %ebx
  800d78:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d7b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d80:	8b 55 08             	mov    0x8(%ebp),%edx
  800d83:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d88:	89 cb                	mov    %ecx,%ebx
  800d8a:	89 cf                	mov    %ecx,%edi
  800d8c:	89 ce                	mov    %ecx,%esi
  800d8e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d90:	85 c0                	test   %eax,%eax
  800d92:	7f 08                	jg     800d9c <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d97:	5b                   	pop    %ebx
  800d98:	5e                   	pop    %esi
  800d99:	5f                   	pop    %edi
  800d9a:	5d                   	pop    %ebp
  800d9b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9c:	83 ec 0c             	sub    $0xc,%esp
  800d9f:	50                   	push   %eax
  800da0:	6a 0d                	push   $0xd
  800da2:	68 5f 25 80 00       	push   $0x80255f
  800da7:	6a 23                	push   $0x23
  800da9:	68 7c 25 80 00       	push   $0x80257c
  800dae:	e8 bc 0f 00 00       	call   801d6f <_panic>

00800db3 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800db3:	55                   	push   %ebp
  800db4:	89 e5                	mov    %esp,%ebp
  800db6:	56                   	push   %esi
  800db7:	53                   	push   %ebx
  800db8:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800dbb:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if((err&FEC_WR)==0 || (uvpt[PGNUM(addr)]&(PTE_W|PTE_COW))==0){
  800dbd:	8b 40 04             	mov    0x4(%eax),%eax
  800dc0:	83 e0 02             	and    $0x2,%eax
  800dc3:	0f 84 82 00 00 00    	je     800e4b <pgfault+0x98>
  800dc9:	89 da                	mov    %ebx,%edx
  800dcb:	c1 ea 0c             	shr    $0xc,%edx
  800dce:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dd5:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800ddb:	74 6e                	je     800e4b <pgfault+0x98>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        envid_t envid = sys_getenvid();
  800ddd:	e8 a2 fd ff ff       	call   800b84 <sys_getenvid>
  800de2:	89 c6                	mov    %eax,%esi
	r = sys_page_alloc(envid,(void *)PFTEMP,PTE_P|PTE_W|PTE_U);
  800de4:	83 ec 04             	sub    $0x4,%esp
  800de7:	6a 07                	push   $0x7
  800de9:	68 00 f0 7f 00       	push   $0x7ff000
  800dee:	50                   	push   %eax
  800def:	e8 ce fd ff ff       	call   800bc2 <sys_page_alloc>
	if(r<0) panic("pgfault:page allocation failed %e",r);
  800df4:	83 c4 10             	add    $0x10,%esp
  800df7:	85 c0                	test   %eax,%eax
  800df9:	78 72                	js     800e6d <pgfault+0xba>

	addr = ROUNDDOWN(addr,PGSIZE);
  800dfb:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy((void *)PFTEMP,(const void *)addr,PGSIZE);
  800e01:	83 ec 04             	sub    $0x4,%esp
  800e04:	68 00 10 00 00       	push   $0x1000
  800e09:	53                   	push   %ebx
  800e0a:	68 00 f0 7f 00       	push   $0x7ff000
  800e0f:	e8 ab fb ff ff       	call   8009bf <memcpy>

	if(sys_page_map(envid,(void *)PFTEMP, envid,addr,PTE_P|PTE_W|PTE_U)<0)
  800e14:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e1b:	53                   	push   %ebx
  800e1c:	56                   	push   %esi
  800e1d:	68 00 f0 7f 00       	push   $0x7ff000
  800e22:	56                   	push   %esi
  800e23:	e8 dd fd ff ff       	call   800c05 <sys_page_map>
  800e28:	83 c4 20             	add    $0x20,%esp
  800e2b:	85 c0                	test   %eax,%eax
  800e2d:	78 50                	js     800e7f <pgfault+0xcc>
		panic("pgfault:page map failed\n");
	if(sys_page_unmap(envid,(void *)PFTEMP)<0)
  800e2f:	83 ec 08             	sub    $0x8,%esp
  800e32:	68 00 f0 7f 00       	push   $0x7ff000
  800e37:	56                   	push   %esi
  800e38:	e8 0a fe ff ff       	call   800c47 <sys_page_unmap>
  800e3d:	83 c4 10             	add    $0x10,%esp
  800e40:	85 c0                	test   %eax,%eax
  800e42:	78 4f                	js     800e93 <pgfault+0xe0>
		panic("pgfault: page upmap failed\n");
       //	panic("pgfault not implemented");
}
  800e44:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e47:	5b                   	pop    %ebx
  800e48:	5e                   	pop    %esi
  800e49:	5d                   	pop    %ebp
  800e4a:	c3                   	ret    
		cprintf("Where is the error %d\n",err&FEC_WR);
  800e4b:	83 ec 08             	sub    $0x8,%esp
  800e4e:	50                   	push   %eax
  800e4f:	68 8a 25 80 00       	push   $0x80258a
  800e54:	e8 51 f3 ff ff       	call   8001aa <cprintf>
		panic("pgfault:invalid user trap");
  800e59:	83 c4 0c             	add    $0xc,%esp
  800e5c:	68 a1 25 80 00       	push   $0x8025a1
  800e61:	6a 1e                	push   $0x1e
  800e63:	68 bb 25 80 00       	push   $0x8025bb
  800e68:	e8 02 0f 00 00       	call   801d6f <_panic>
	if(r<0) panic("pgfault:page allocation failed %e",r);
  800e6d:	50                   	push   %eax
  800e6e:	68 a8 26 80 00       	push   $0x8026a8
  800e73:	6a 29                	push   $0x29
  800e75:	68 bb 25 80 00       	push   $0x8025bb
  800e7a:	e8 f0 0e 00 00       	call   801d6f <_panic>
		panic("pgfault:page map failed\n");
  800e7f:	83 ec 04             	sub    $0x4,%esp
  800e82:	68 c6 25 80 00       	push   $0x8025c6
  800e87:	6a 2f                	push   $0x2f
  800e89:	68 bb 25 80 00       	push   $0x8025bb
  800e8e:	e8 dc 0e 00 00       	call   801d6f <_panic>
		panic("pgfault: page upmap failed\n");
  800e93:	83 ec 04             	sub    $0x4,%esp
  800e96:	68 df 25 80 00       	push   $0x8025df
  800e9b:	6a 31                	push   $0x31
  800e9d:	68 bb 25 80 00       	push   $0x8025bb
  800ea2:	e8 c8 0e 00 00       	call   801d6f <_panic>

00800ea7 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ea7:	55                   	push   %ebp
  800ea8:	89 e5                	mov    %esp,%ebp
  800eaa:	57                   	push   %edi
  800eab:	56                   	push   %esi
  800eac:	53                   	push   %ebx
  800ead:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	set_pgfault_handler(pgfault);
  800eb0:	68 b3 0d 80 00       	push   $0x800db3
  800eb5:	e8 fb 0e 00 00       	call   801db5 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800eba:	b8 07 00 00 00       	mov    $0x7,%eax
  800ebf:	cd 30                	int    $0x30
  800ec1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800ec4:	89 45 e0             	mov    %eax,-0x20(%ebp)
       
	envid_t envid = sys_exofork();
	uintptr_t addr;
  
	if(envid<0) panic("sys_exofork failed\n");
  800ec7:	83 c4 10             	add    $0x10,%esp
  800eca:	85 c0                	test   %eax,%eax
  800ecc:	78 27                	js     800ef5 <fork+0x4e>
	if(envid==0){
	  thisenv = &envs[ENVX(sys_getenvid())];
	  return 0;
	}

	for(addr=(uintptr_t)UTEXT; addr<USTACKTOP;addr+=PGSIZE){
  800ece:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if(envid==0){
  800ed3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800ed7:	75 5e                	jne    800f37 <fork+0x90>
	  thisenv = &envs[ENVX(sys_getenvid())];
  800ed9:	e8 a6 fc ff ff       	call   800b84 <sys_getenvid>
  800ede:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ee3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800ee6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800eeb:	a3 04 40 80 00       	mov    %eax,0x804004
	  return 0;
  800ef0:	e9 fc 00 00 00       	jmp    800ff1 <fork+0x14a>
	if(envid<0) panic("sys_exofork failed\n");
  800ef5:	83 ec 04             	sub    $0x4,%esp
  800ef8:	68 fb 25 80 00       	push   $0x8025fb
  800efd:	6a 77                	push   $0x77
  800eff:	68 bb 25 80 00       	push   $0x8025bb
  800f04:	e8 66 0e 00 00       	call   801d6f <_panic>
          if((r=sys_page_map(parent_envid,va,envid,va,uvpt[pn]&PTE_SYSCALL))<0)
  800f09:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f10:	83 ec 0c             	sub    $0xc,%esp
  800f13:	25 07 0e 00 00       	and    $0xe07,%eax
  800f18:	50                   	push   %eax
  800f19:	57                   	push   %edi
  800f1a:	ff 75 e0             	pushl  -0x20(%ebp)
  800f1d:	57                   	push   %edi
  800f1e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f21:	e8 df fc ff ff       	call   800c05 <sys_page_map>
  800f26:	83 c4 20             	add    $0x20,%esp
	for(addr=(uintptr_t)UTEXT; addr<USTACKTOP;addr+=PGSIZE){
  800f29:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f2f:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800f35:	74 76                	je     800fad <fork+0x106>
	   if((uvpd[PDX(addr)]&PTE_P) && uvpt[PGNUM(addr)] & PTE_P)
  800f37:	89 d8                	mov    %ebx,%eax
  800f39:	c1 e8 16             	shr    $0x16,%eax
  800f3c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f43:	a8 01                	test   $0x1,%al
  800f45:	74 e2                	je     800f29 <fork+0x82>
  800f47:	89 de                	mov    %ebx,%esi
  800f49:	c1 ee 0c             	shr    $0xc,%esi
  800f4c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f53:	a8 01                	test   $0x1,%al
  800f55:	74 d2                	je     800f29 <fork+0x82>
        envid_t parent_envid = sys_getenvid();
  800f57:	e8 28 fc ff ff       	call   800b84 <sys_getenvid>
  800f5c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	void *va = (void *)(pn*PGSIZE);
  800f5f:	89 f7                	mov    %esi,%edi
  800f61:	c1 e7 0c             	shl    $0xc,%edi
        if(uvpt[pn] & PTE_SHARE){
  800f64:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f6b:	f6 c4 04             	test   $0x4,%ah
  800f6e:	75 99                	jne    800f09 <fork+0x62>
	if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)){
  800f70:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f77:	a8 02                	test   $0x2,%al
  800f79:	0f 85 ed 00 00 00    	jne    80106c <fork+0x1c5>
  800f7f:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f86:	f6 c4 08             	test   $0x8,%ah
  800f89:	0f 85 dd 00 00 00    	jne    80106c <fork+0x1c5>
	 if((r=sys_page_map(parent_envid,va,envid,va,perm))<0)
  800f8f:	83 ec 0c             	sub    $0xc,%esp
  800f92:	6a 05                	push   $0x5
  800f94:	57                   	push   %edi
  800f95:	ff 75 e0             	pushl  -0x20(%ebp)
  800f98:	57                   	push   %edi
  800f99:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f9c:	e8 64 fc ff ff       	call   800c05 <sys_page_map>
  800fa1:	83 c4 20             	add    $0x20,%esp
  800fa4:	85 c0                	test   %eax,%eax
  800fa6:	79 81                	jns    800f29 <fork+0x82>
  800fa8:	e9 db 00 00 00       	jmp    801088 <fork+0x1e1>
		   duppage(envid,PGNUM(addr));
	}
        
	int r;
	if((r=sys_page_alloc(envid,(void *)UXSTACKTOP-PGSIZE,PTE_U|PTE_P|PTE_W))<0)
  800fad:	83 ec 04             	sub    $0x4,%esp
  800fb0:	6a 07                	push   $0x7
  800fb2:	68 00 f0 bf ee       	push   $0xeebff000
  800fb7:	ff 75 dc             	pushl  -0x24(%ebp)
  800fba:	e8 03 fc ff ff       	call   800bc2 <sys_page_alloc>
  800fbf:	83 c4 10             	add    $0x10,%esp
  800fc2:	85 c0                	test   %eax,%eax
  800fc4:	78 36                	js     800ffc <fork+0x155>
		panic("fork:page alloc failed %e\n",r);

	extern void _pgfault_upcall();
	if((r = sys_env_set_pgfault_upcall(envid,_pgfault_upcall)))
  800fc6:	83 ec 08             	sub    $0x8,%esp
  800fc9:	68 1a 1e 80 00       	push   $0x801e1a
  800fce:	ff 75 dc             	pushl  -0x24(%ebp)
  800fd1:	e8 37 fd ff ff       	call   800d0d <sys_env_set_pgfault_upcall>
  800fd6:	83 c4 10             	add    $0x10,%esp
  800fd9:	85 c0                	test   %eax,%eax
  800fdb:	75 34                	jne    801011 <fork+0x16a>
		panic("fork:set upcall failed %e\n",r);
	if((r = sys_env_set_status(envid,ENV_RUNNABLE))<0)
  800fdd:	83 ec 08             	sub    $0x8,%esp
  800fe0:	6a 02                	push   $0x2
  800fe2:	ff 75 dc             	pushl  -0x24(%ebp)
  800fe5:	e8 9f fc ff ff       	call   800c89 <sys_env_set_status>
  800fea:	83 c4 10             	add    $0x10,%esp
  800fed:	85 c0                	test   %eax,%eax
  800fef:	78 35                	js     801026 <fork+0x17f>
		panic("fork:set status failed %e\n",r);
	//cprintf("forkid= %d\n", envid);
	return envid;
       	
}
  800ff1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800ff4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ff7:	5b                   	pop    %ebx
  800ff8:	5e                   	pop    %esi
  800ff9:	5f                   	pop    %edi
  800ffa:	5d                   	pop    %ebp
  800ffb:	c3                   	ret    
		panic("fork:page alloc failed %e\n",r);
  800ffc:	50                   	push   %eax
  800ffd:	68 3f 26 80 00       	push   $0x80263f
  801002:	68 84 00 00 00       	push   $0x84
  801007:	68 bb 25 80 00       	push   $0x8025bb
  80100c:	e8 5e 0d 00 00       	call   801d6f <_panic>
		panic("fork:set upcall failed %e\n",r);
  801011:	50                   	push   %eax
  801012:	68 5a 26 80 00       	push   $0x80265a
  801017:	68 88 00 00 00       	push   $0x88
  80101c:	68 bb 25 80 00       	push   $0x8025bb
  801021:	e8 49 0d 00 00       	call   801d6f <_panic>
		panic("fork:set status failed %e\n",r);
  801026:	50                   	push   %eax
  801027:	68 75 26 80 00       	push   $0x802675
  80102c:	68 8a 00 00 00       	push   $0x8a
  801031:	68 bb 25 80 00       	push   $0x8025bb
  801036:	e8 34 0d 00 00       	call   801d6f <_panic>
		if( (r=sys_page_map(parent_envid,va,parent_envid,va,perm))<0){
  80103b:	83 ec 0c             	sub    $0xc,%esp
  80103e:	68 05 08 00 00       	push   $0x805
  801043:	57                   	push   %edi
  801044:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801047:	50                   	push   %eax
  801048:	57                   	push   %edi
  801049:	50                   	push   %eax
  80104a:	e8 b6 fb ff ff       	call   800c05 <sys_page_map>
  80104f:	83 c4 20             	add    $0x20,%esp
  801052:	85 c0                	test   %eax,%eax
  801054:	0f 89 cf fe ff ff    	jns    800f29 <fork+0x82>
		 panic("duppage:map02 failed %e",r);
  80105a:	50                   	push   %eax
  80105b:	68 27 26 80 00       	push   $0x802627
  801060:	6a 56                	push   $0x56
  801062:	68 bb 25 80 00       	push   $0x8025bb
  801067:	e8 03 0d 00 00       	call   801d6f <_panic>
	 if((r=sys_page_map(parent_envid,va,envid,va,perm))<0)
  80106c:	83 ec 0c             	sub    $0xc,%esp
  80106f:	68 05 08 00 00       	push   $0x805
  801074:	57                   	push   %edi
  801075:	ff 75 e0             	pushl  -0x20(%ebp)
  801078:	57                   	push   %edi
  801079:	ff 75 e4             	pushl  -0x1c(%ebp)
  80107c:	e8 84 fb ff ff       	call   800c05 <sys_page_map>
  801081:	83 c4 20             	add    $0x20,%esp
  801084:	85 c0                	test   %eax,%eax
  801086:	79 b3                	jns    80103b <fork+0x194>
		 panic("duppage:map01 failed %e",r);
  801088:	50                   	push   %eax
  801089:	68 0f 26 80 00       	push   $0x80260f
  80108e:	6a 53                	push   $0x53
  801090:	68 bb 25 80 00       	push   $0x8025bb
  801095:	e8 d5 0c 00 00       	call   801d6f <_panic>

0080109a <sfork>:

// Challenge!
int
sfork(void)
{
  80109a:	55                   	push   %ebp
  80109b:	89 e5                	mov    %esp,%ebp
  80109d:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010a0:	68 90 26 80 00       	push   $0x802690
  8010a5:	68 94 00 00 00       	push   $0x94
  8010aa:	68 bb 25 80 00       	push   $0x8025bb
  8010af:	e8 bb 0c 00 00       	call   801d6f <_panic>

008010b4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010b4:	55                   	push   %ebp
  8010b5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ba:	05 00 00 00 30       	add    $0x30000000,%eax
  8010bf:	c1 e8 0c             	shr    $0xc,%eax
}
  8010c2:	5d                   	pop    %ebp
  8010c3:	c3                   	ret    

008010c4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010c4:	55                   	push   %ebp
  8010c5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ca:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8010cf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010d4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010d9:	5d                   	pop    %ebp
  8010da:	c3                   	ret    

008010db <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010db:	55                   	push   %ebp
  8010dc:	89 e5                	mov    %esp,%ebp
  8010de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010e1:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010e6:	89 c2                	mov    %eax,%edx
  8010e8:	c1 ea 16             	shr    $0x16,%edx
  8010eb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010f2:	f6 c2 01             	test   $0x1,%dl
  8010f5:	74 2a                	je     801121 <fd_alloc+0x46>
  8010f7:	89 c2                	mov    %eax,%edx
  8010f9:	c1 ea 0c             	shr    $0xc,%edx
  8010fc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801103:	f6 c2 01             	test   $0x1,%dl
  801106:	74 19                	je     801121 <fd_alloc+0x46>
  801108:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  80110d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801112:	75 d2                	jne    8010e6 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801114:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80111a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  80111f:	eb 07                	jmp    801128 <fd_alloc+0x4d>
			*fd_store = fd;
  801121:	89 01                	mov    %eax,(%ecx)
			return 0;
  801123:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801128:	5d                   	pop    %ebp
  801129:	c3                   	ret    

0080112a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80112a:	55                   	push   %ebp
  80112b:	89 e5                	mov    %esp,%ebp
  80112d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801130:	83 f8 1f             	cmp    $0x1f,%eax
  801133:	77 36                	ja     80116b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801135:	c1 e0 0c             	shl    $0xc,%eax
  801138:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80113d:	89 c2                	mov    %eax,%edx
  80113f:	c1 ea 16             	shr    $0x16,%edx
  801142:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801149:	f6 c2 01             	test   $0x1,%dl
  80114c:	74 24                	je     801172 <fd_lookup+0x48>
  80114e:	89 c2                	mov    %eax,%edx
  801150:	c1 ea 0c             	shr    $0xc,%edx
  801153:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80115a:	f6 c2 01             	test   $0x1,%dl
  80115d:	74 1a                	je     801179 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80115f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801162:	89 02                	mov    %eax,(%edx)
	return 0;
  801164:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801169:	5d                   	pop    %ebp
  80116a:	c3                   	ret    
		return -E_INVAL;
  80116b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801170:	eb f7                	jmp    801169 <fd_lookup+0x3f>
		return -E_INVAL;
  801172:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801177:	eb f0                	jmp    801169 <fd_lookup+0x3f>
  801179:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80117e:	eb e9                	jmp    801169 <fd_lookup+0x3f>

00801180 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801180:	55                   	push   %ebp
  801181:	89 e5                	mov    %esp,%ebp
  801183:	83 ec 08             	sub    $0x8,%esp
  801186:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801189:	ba 48 27 80 00       	mov    $0x802748,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80118e:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  801193:	39 08                	cmp    %ecx,(%eax)
  801195:	74 33                	je     8011ca <dev_lookup+0x4a>
  801197:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  80119a:	8b 02                	mov    (%edx),%eax
  80119c:	85 c0                	test   %eax,%eax
  80119e:	75 f3                	jne    801193 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011a0:	a1 04 40 80 00       	mov    0x804004,%eax
  8011a5:	8b 40 48             	mov    0x48(%eax),%eax
  8011a8:	83 ec 04             	sub    $0x4,%esp
  8011ab:	51                   	push   %ecx
  8011ac:	50                   	push   %eax
  8011ad:	68 cc 26 80 00       	push   $0x8026cc
  8011b2:	e8 f3 ef ff ff       	call   8001aa <cprintf>
	*dev = 0;
  8011b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011ba:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011c0:	83 c4 10             	add    $0x10,%esp
  8011c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011c8:	c9                   	leave  
  8011c9:	c3                   	ret    
			*dev = devtab[i];
  8011ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011cd:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8011d4:	eb f2                	jmp    8011c8 <dev_lookup+0x48>

008011d6 <fd_close>:
{
  8011d6:	55                   	push   %ebp
  8011d7:	89 e5                	mov    %esp,%ebp
  8011d9:	57                   	push   %edi
  8011da:	56                   	push   %esi
  8011db:	53                   	push   %ebx
  8011dc:	83 ec 1c             	sub    $0x1c,%esp
  8011df:	8b 75 08             	mov    0x8(%ebp),%esi
  8011e2:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011e5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8011e8:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011e9:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011ef:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011f2:	50                   	push   %eax
  8011f3:	e8 32 ff ff ff       	call   80112a <fd_lookup>
  8011f8:	89 c3                	mov    %eax,%ebx
  8011fa:	83 c4 08             	add    $0x8,%esp
  8011fd:	85 c0                	test   %eax,%eax
  8011ff:	78 05                	js     801206 <fd_close+0x30>
	    || fd != fd2)
  801201:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801204:	74 16                	je     80121c <fd_close+0x46>
		return (must_exist ? r : 0);
  801206:	89 f8                	mov    %edi,%eax
  801208:	84 c0                	test   %al,%al
  80120a:	b8 00 00 00 00       	mov    $0x0,%eax
  80120f:	0f 44 d8             	cmove  %eax,%ebx
}
  801212:	89 d8                	mov    %ebx,%eax
  801214:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801217:	5b                   	pop    %ebx
  801218:	5e                   	pop    %esi
  801219:	5f                   	pop    %edi
  80121a:	5d                   	pop    %ebp
  80121b:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80121c:	83 ec 08             	sub    $0x8,%esp
  80121f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801222:	50                   	push   %eax
  801223:	ff 36                	pushl  (%esi)
  801225:	e8 56 ff ff ff       	call   801180 <dev_lookup>
  80122a:	89 c3                	mov    %eax,%ebx
  80122c:	83 c4 10             	add    $0x10,%esp
  80122f:	85 c0                	test   %eax,%eax
  801231:	78 15                	js     801248 <fd_close+0x72>
		if (dev->dev_close)
  801233:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801236:	8b 40 10             	mov    0x10(%eax),%eax
  801239:	85 c0                	test   %eax,%eax
  80123b:	74 1b                	je     801258 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  80123d:	83 ec 0c             	sub    $0xc,%esp
  801240:	56                   	push   %esi
  801241:	ff d0                	call   *%eax
  801243:	89 c3                	mov    %eax,%ebx
  801245:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801248:	83 ec 08             	sub    $0x8,%esp
  80124b:	56                   	push   %esi
  80124c:	6a 00                	push   $0x0
  80124e:	e8 f4 f9 ff ff       	call   800c47 <sys_page_unmap>
	return r;
  801253:	83 c4 10             	add    $0x10,%esp
  801256:	eb ba                	jmp    801212 <fd_close+0x3c>
			r = 0;
  801258:	bb 00 00 00 00       	mov    $0x0,%ebx
  80125d:	eb e9                	jmp    801248 <fd_close+0x72>

0080125f <close>:

int
close(int fdnum)
{
  80125f:	55                   	push   %ebp
  801260:	89 e5                	mov    %esp,%ebp
  801262:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801265:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801268:	50                   	push   %eax
  801269:	ff 75 08             	pushl  0x8(%ebp)
  80126c:	e8 b9 fe ff ff       	call   80112a <fd_lookup>
  801271:	83 c4 08             	add    $0x8,%esp
  801274:	85 c0                	test   %eax,%eax
  801276:	78 10                	js     801288 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801278:	83 ec 08             	sub    $0x8,%esp
  80127b:	6a 01                	push   $0x1
  80127d:	ff 75 f4             	pushl  -0xc(%ebp)
  801280:	e8 51 ff ff ff       	call   8011d6 <fd_close>
  801285:	83 c4 10             	add    $0x10,%esp
}
  801288:	c9                   	leave  
  801289:	c3                   	ret    

0080128a <close_all>:

void
close_all(void)
{
  80128a:	55                   	push   %ebp
  80128b:	89 e5                	mov    %esp,%ebp
  80128d:	53                   	push   %ebx
  80128e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801291:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801296:	83 ec 0c             	sub    $0xc,%esp
  801299:	53                   	push   %ebx
  80129a:	e8 c0 ff ff ff       	call   80125f <close>
	for (i = 0; i < MAXFD; i++)
  80129f:	83 c3 01             	add    $0x1,%ebx
  8012a2:	83 c4 10             	add    $0x10,%esp
  8012a5:	83 fb 20             	cmp    $0x20,%ebx
  8012a8:	75 ec                	jne    801296 <close_all+0xc>
}
  8012aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012ad:	c9                   	leave  
  8012ae:	c3                   	ret    

008012af <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012af:	55                   	push   %ebp
  8012b0:	89 e5                	mov    %esp,%ebp
  8012b2:	57                   	push   %edi
  8012b3:	56                   	push   %esi
  8012b4:	53                   	push   %ebx
  8012b5:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012b8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012bb:	50                   	push   %eax
  8012bc:	ff 75 08             	pushl  0x8(%ebp)
  8012bf:	e8 66 fe ff ff       	call   80112a <fd_lookup>
  8012c4:	89 c3                	mov    %eax,%ebx
  8012c6:	83 c4 08             	add    $0x8,%esp
  8012c9:	85 c0                	test   %eax,%eax
  8012cb:	0f 88 81 00 00 00    	js     801352 <dup+0xa3>
		return r;
	close(newfdnum);
  8012d1:	83 ec 0c             	sub    $0xc,%esp
  8012d4:	ff 75 0c             	pushl  0xc(%ebp)
  8012d7:	e8 83 ff ff ff       	call   80125f <close>

	newfd = INDEX2FD(newfdnum);
  8012dc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012df:	c1 e6 0c             	shl    $0xc,%esi
  8012e2:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8012e8:	83 c4 04             	add    $0x4,%esp
  8012eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012ee:	e8 d1 fd ff ff       	call   8010c4 <fd2data>
  8012f3:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8012f5:	89 34 24             	mov    %esi,(%esp)
  8012f8:	e8 c7 fd ff ff       	call   8010c4 <fd2data>
  8012fd:	83 c4 10             	add    $0x10,%esp
  801300:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801302:	89 d8                	mov    %ebx,%eax
  801304:	c1 e8 16             	shr    $0x16,%eax
  801307:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80130e:	a8 01                	test   $0x1,%al
  801310:	74 11                	je     801323 <dup+0x74>
  801312:	89 d8                	mov    %ebx,%eax
  801314:	c1 e8 0c             	shr    $0xc,%eax
  801317:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80131e:	f6 c2 01             	test   $0x1,%dl
  801321:	75 39                	jne    80135c <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801323:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801326:	89 d0                	mov    %edx,%eax
  801328:	c1 e8 0c             	shr    $0xc,%eax
  80132b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801332:	83 ec 0c             	sub    $0xc,%esp
  801335:	25 07 0e 00 00       	and    $0xe07,%eax
  80133a:	50                   	push   %eax
  80133b:	56                   	push   %esi
  80133c:	6a 00                	push   $0x0
  80133e:	52                   	push   %edx
  80133f:	6a 00                	push   $0x0
  801341:	e8 bf f8 ff ff       	call   800c05 <sys_page_map>
  801346:	89 c3                	mov    %eax,%ebx
  801348:	83 c4 20             	add    $0x20,%esp
  80134b:	85 c0                	test   %eax,%eax
  80134d:	78 31                	js     801380 <dup+0xd1>
		goto err;

	return newfdnum;
  80134f:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801352:	89 d8                	mov    %ebx,%eax
  801354:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801357:	5b                   	pop    %ebx
  801358:	5e                   	pop    %esi
  801359:	5f                   	pop    %edi
  80135a:	5d                   	pop    %ebp
  80135b:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80135c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801363:	83 ec 0c             	sub    $0xc,%esp
  801366:	25 07 0e 00 00       	and    $0xe07,%eax
  80136b:	50                   	push   %eax
  80136c:	57                   	push   %edi
  80136d:	6a 00                	push   $0x0
  80136f:	53                   	push   %ebx
  801370:	6a 00                	push   $0x0
  801372:	e8 8e f8 ff ff       	call   800c05 <sys_page_map>
  801377:	89 c3                	mov    %eax,%ebx
  801379:	83 c4 20             	add    $0x20,%esp
  80137c:	85 c0                	test   %eax,%eax
  80137e:	79 a3                	jns    801323 <dup+0x74>
	sys_page_unmap(0, newfd);
  801380:	83 ec 08             	sub    $0x8,%esp
  801383:	56                   	push   %esi
  801384:	6a 00                	push   $0x0
  801386:	e8 bc f8 ff ff       	call   800c47 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80138b:	83 c4 08             	add    $0x8,%esp
  80138e:	57                   	push   %edi
  80138f:	6a 00                	push   $0x0
  801391:	e8 b1 f8 ff ff       	call   800c47 <sys_page_unmap>
	return r;
  801396:	83 c4 10             	add    $0x10,%esp
  801399:	eb b7                	jmp    801352 <dup+0xa3>

0080139b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80139b:	55                   	push   %ebp
  80139c:	89 e5                	mov    %esp,%ebp
  80139e:	53                   	push   %ebx
  80139f:	83 ec 14             	sub    $0x14,%esp
  8013a2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013a5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013a8:	50                   	push   %eax
  8013a9:	53                   	push   %ebx
  8013aa:	e8 7b fd ff ff       	call   80112a <fd_lookup>
  8013af:	83 c4 08             	add    $0x8,%esp
  8013b2:	85 c0                	test   %eax,%eax
  8013b4:	78 3f                	js     8013f5 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013b6:	83 ec 08             	sub    $0x8,%esp
  8013b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013bc:	50                   	push   %eax
  8013bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c0:	ff 30                	pushl  (%eax)
  8013c2:	e8 b9 fd ff ff       	call   801180 <dev_lookup>
  8013c7:	83 c4 10             	add    $0x10,%esp
  8013ca:	85 c0                	test   %eax,%eax
  8013cc:	78 27                	js     8013f5 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013ce:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013d1:	8b 42 08             	mov    0x8(%edx),%eax
  8013d4:	83 e0 03             	and    $0x3,%eax
  8013d7:	83 f8 01             	cmp    $0x1,%eax
  8013da:	74 1e                	je     8013fa <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8013dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013df:	8b 40 08             	mov    0x8(%eax),%eax
  8013e2:	85 c0                	test   %eax,%eax
  8013e4:	74 35                	je     80141b <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013e6:	83 ec 04             	sub    $0x4,%esp
  8013e9:	ff 75 10             	pushl  0x10(%ebp)
  8013ec:	ff 75 0c             	pushl  0xc(%ebp)
  8013ef:	52                   	push   %edx
  8013f0:	ff d0                	call   *%eax
  8013f2:	83 c4 10             	add    $0x10,%esp
}
  8013f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013f8:	c9                   	leave  
  8013f9:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013fa:	a1 04 40 80 00       	mov    0x804004,%eax
  8013ff:	8b 40 48             	mov    0x48(%eax),%eax
  801402:	83 ec 04             	sub    $0x4,%esp
  801405:	53                   	push   %ebx
  801406:	50                   	push   %eax
  801407:	68 0d 27 80 00       	push   $0x80270d
  80140c:	e8 99 ed ff ff       	call   8001aa <cprintf>
		return -E_INVAL;
  801411:	83 c4 10             	add    $0x10,%esp
  801414:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801419:	eb da                	jmp    8013f5 <read+0x5a>
		return -E_NOT_SUPP;
  80141b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801420:	eb d3                	jmp    8013f5 <read+0x5a>

00801422 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801422:	55                   	push   %ebp
  801423:	89 e5                	mov    %esp,%ebp
  801425:	57                   	push   %edi
  801426:	56                   	push   %esi
  801427:	53                   	push   %ebx
  801428:	83 ec 0c             	sub    $0xc,%esp
  80142b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80142e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801431:	bb 00 00 00 00       	mov    $0x0,%ebx
  801436:	39 f3                	cmp    %esi,%ebx
  801438:	73 25                	jae    80145f <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80143a:	83 ec 04             	sub    $0x4,%esp
  80143d:	89 f0                	mov    %esi,%eax
  80143f:	29 d8                	sub    %ebx,%eax
  801441:	50                   	push   %eax
  801442:	89 d8                	mov    %ebx,%eax
  801444:	03 45 0c             	add    0xc(%ebp),%eax
  801447:	50                   	push   %eax
  801448:	57                   	push   %edi
  801449:	e8 4d ff ff ff       	call   80139b <read>
		if (m < 0)
  80144e:	83 c4 10             	add    $0x10,%esp
  801451:	85 c0                	test   %eax,%eax
  801453:	78 08                	js     80145d <readn+0x3b>
			return m;
		if (m == 0)
  801455:	85 c0                	test   %eax,%eax
  801457:	74 06                	je     80145f <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  801459:	01 c3                	add    %eax,%ebx
  80145b:	eb d9                	jmp    801436 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80145d:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80145f:	89 d8                	mov    %ebx,%eax
  801461:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801464:	5b                   	pop    %ebx
  801465:	5e                   	pop    %esi
  801466:	5f                   	pop    %edi
  801467:	5d                   	pop    %ebp
  801468:	c3                   	ret    

00801469 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801469:	55                   	push   %ebp
  80146a:	89 e5                	mov    %esp,%ebp
  80146c:	53                   	push   %ebx
  80146d:	83 ec 14             	sub    $0x14,%esp
  801470:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801473:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801476:	50                   	push   %eax
  801477:	53                   	push   %ebx
  801478:	e8 ad fc ff ff       	call   80112a <fd_lookup>
  80147d:	83 c4 08             	add    $0x8,%esp
  801480:	85 c0                	test   %eax,%eax
  801482:	78 3a                	js     8014be <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801484:	83 ec 08             	sub    $0x8,%esp
  801487:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80148a:	50                   	push   %eax
  80148b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80148e:	ff 30                	pushl  (%eax)
  801490:	e8 eb fc ff ff       	call   801180 <dev_lookup>
  801495:	83 c4 10             	add    $0x10,%esp
  801498:	85 c0                	test   %eax,%eax
  80149a:	78 22                	js     8014be <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80149c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80149f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014a3:	74 1e                	je     8014c3 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014a8:	8b 52 0c             	mov    0xc(%edx),%edx
  8014ab:	85 d2                	test   %edx,%edx
  8014ad:	74 35                	je     8014e4 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014af:	83 ec 04             	sub    $0x4,%esp
  8014b2:	ff 75 10             	pushl  0x10(%ebp)
  8014b5:	ff 75 0c             	pushl  0xc(%ebp)
  8014b8:	50                   	push   %eax
  8014b9:	ff d2                	call   *%edx
  8014bb:	83 c4 10             	add    $0x10,%esp
}
  8014be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014c1:	c9                   	leave  
  8014c2:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014c3:	a1 04 40 80 00       	mov    0x804004,%eax
  8014c8:	8b 40 48             	mov    0x48(%eax),%eax
  8014cb:	83 ec 04             	sub    $0x4,%esp
  8014ce:	53                   	push   %ebx
  8014cf:	50                   	push   %eax
  8014d0:	68 29 27 80 00       	push   $0x802729
  8014d5:	e8 d0 ec ff ff       	call   8001aa <cprintf>
		return -E_INVAL;
  8014da:	83 c4 10             	add    $0x10,%esp
  8014dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014e2:	eb da                	jmp    8014be <write+0x55>
		return -E_NOT_SUPP;
  8014e4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014e9:	eb d3                	jmp    8014be <write+0x55>

008014eb <seek>:

int
seek(int fdnum, off_t offset)
{
  8014eb:	55                   	push   %ebp
  8014ec:	89 e5                	mov    %esp,%ebp
  8014ee:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014f1:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014f4:	50                   	push   %eax
  8014f5:	ff 75 08             	pushl  0x8(%ebp)
  8014f8:	e8 2d fc ff ff       	call   80112a <fd_lookup>
  8014fd:	83 c4 08             	add    $0x8,%esp
  801500:	85 c0                	test   %eax,%eax
  801502:	78 0e                	js     801512 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801504:	8b 55 0c             	mov    0xc(%ebp),%edx
  801507:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80150a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80150d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801512:	c9                   	leave  
  801513:	c3                   	ret    

00801514 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801514:	55                   	push   %ebp
  801515:	89 e5                	mov    %esp,%ebp
  801517:	53                   	push   %ebx
  801518:	83 ec 14             	sub    $0x14,%esp
  80151b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80151e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801521:	50                   	push   %eax
  801522:	53                   	push   %ebx
  801523:	e8 02 fc ff ff       	call   80112a <fd_lookup>
  801528:	83 c4 08             	add    $0x8,%esp
  80152b:	85 c0                	test   %eax,%eax
  80152d:	78 37                	js     801566 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80152f:	83 ec 08             	sub    $0x8,%esp
  801532:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801535:	50                   	push   %eax
  801536:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801539:	ff 30                	pushl  (%eax)
  80153b:	e8 40 fc ff ff       	call   801180 <dev_lookup>
  801540:	83 c4 10             	add    $0x10,%esp
  801543:	85 c0                	test   %eax,%eax
  801545:	78 1f                	js     801566 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801547:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80154a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80154e:	74 1b                	je     80156b <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801550:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801553:	8b 52 18             	mov    0x18(%edx),%edx
  801556:	85 d2                	test   %edx,%edx
  801558:	74 32                	je     80158c <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80155a:	83 ec 08             	sub    $0x8,%esp
  80155d:	ff 75 0c             	pushl  0xc(%ebp)
  801560:	50                   	push   %eax
  801561:	ff d2                	call   *%edx
  801563:	83 c4 10             	add    $0x10,%esp
}
  801566:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801569:	c9                   	leave  
  80156a:	c3                   	ret    
			thisenv->env_id, fdnum);
  80156b:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801570:	8b 40 48             	mov    0x48(%eax),%eax
  801573:	83 ec 04             	sub    $0x4,%esp
  801576:	53                   	push   %ebx
  801577:	50                   	push   %eax
  801578:	68 ec 26 80 00       	push   $0x8026ec
  80157d:	e8 28 ec ff ff       	call   8001aa <cprintf>
		return -E_INVAL;
  801582:	83 c4 10             	add    $0x10,%esp
  801585:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80158a:	eb da                	jmp    801566 <ftruncate+0x52>
		return -E_NOT_SUPP;
  80158c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801591:	eb d3                	jmp    801566 <ftruncate+0x52>

00801593 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801593:	55                   	push   %ebp
  801594:	89 e5                	mov    %esp,%ebp
  801596:	53                   	push   %ebx
  801597:	83 ec 14             	sub    $0x14,%esp
  80159a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80159d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a0:	50                   	push   %eax
  8015a1:	ff 75 08             	pushl  0x8(%ebp)
  8015a4:	e8 81 fb ff ff       	call   80112a <fd_lookup>
  8015a9:	83 c4 08             	add    $0x8,%esp
  8015ac:	85 c0                	test   %eax,%eax
  8015ae:	78 4b                	js     8015fb <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b0:	83 ec 08             	sub    $0x8,%esp
  8015b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b6:	50                   	push   %eax
  8015b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ba:	ff 30                	pushl  (%eax)
  8015bc:	e8 bf fb ff ff       	call   801180 <dev_lookup>
  8015c1:	83 c4 10             	add    $0x10,%esp
  8015c4:	85 c0                	test   %eax,%eax
  8015c6:	78 33                	js     8015fb <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  8015c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015cb:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015cf:	74 2f                	je     801600 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015d1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015d4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015db:	00 00 00 
	stat->st_isdir = 0;
  8015de:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015e5:	00 00 00 
	stat->st_dev = dev;
  8015e8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015ee:	83 ec 08             	sub    $0x8,%esp
  8015f1:	53                   	push   %ebx
  8015f2:	ff 75 f0             	pushl  -0x10(%ebp)
  8015f5:	ff 50 14             	call   *0x14(%eax)
  8015f8:	83 c4 10             	add    $0x10,%esp
}
  8015fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015fe:	c9                   	leave  
  8015ff:	c3                   	ret    
		return -E_NOT_SUPP;
  801600:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801605:	eb f4                	jmp    8015fb <fstat+0x68>

00801607 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801607:	55                   	push   %ebp
  801608:	89 e5                	mov    %esp,%ebp
  80160a:	56                   	push   %esi
  80160b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80160c:	83 ec 08             	sub    $0x8,%esp
  80160f:	6a 00                	push   $0x0
  801611:	ff 75 08             	pushl  0x8(%ebp)
  801614:	e8 e7 01 00 00       	call   801800 <open>
  801619:	89 c3                	mov    %eax,%ebx
  80161b:	83 c4 10             	add    $0x10,%esp
  80161e:	85 c0                	test   %eax,%eax
  801620:	78 1b                	js     80163d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801622:	83 ec 08             	sub    $0x8,%esp
  801625:	ff 75 0c             	pushl  0xc(%ebp)
  801628:	50                   	push   %eax
  801629:	e8 65 ff ff ff       	call   801593 <fstat>
  80162e:	89 c6                	mov    %eax,%esi
	close(fd);
  801630:	89 1c 24             	mov    %ebx,(%esp)
  801633:	e8 27 fc ff ff       	call   80125f <close>
	return r;
  801638:	83 c4 10             	add    $0x10,%esp
  80163b:	89 f3                	mov    %esi,%ebx
}
  80163d:	89 d8                	mov    %ebx,%eax
  80163f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801642:	5b                   	pop    %ebx
  801643:	5e                   	pop    %esi
  801644:	5d                   	pop    %ebp
  801645:	c3                   	ret    

00801646 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801646:	55                   	push   %ebp
  801647:	89 e5                	mov    %esp,%ebp
  801649:	56                   	push   %esi
  80164a:	53                   	push   %ebx
  80164b:	89 c6                	mov    %eax,%esi
  80164d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80164f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801656:	74 27                	je     80167f <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801658:	6a 07                	push   $0x7
  80165a:	68 00 50 80 00       	push   $0x805000
  80165f:	56                   	push   %esi
  801660:	ff 35 00 40 80 00    	pushl  0x804000
  801666:	e8 4b 08 00 00       	call   801eb6 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80166b:	83 c4 0c             	add    $0xc,%esp
  80166e:	6a 00                	push   $0x0
  801670:	53                   	push   %ebx
  801671:	6a 00                	push   $0x0
  801673:	e8 c9 07 00 00       	call   801e41 <ipc_recv>
}
  801678:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80167b:	5b                   	pop    %ebx
  80167c:	5e                   	pop    %esi
  80167d:	5d                   	pop    %ebp
  80167e:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80167f:	83 ec 0c             	sub    $0xc,%esp
  801682:	6a 01                	push   $0x1
  801684:	e8 83 08 00 00       	call   801f0c <ipc_find_env>
  801689:	a3 00 40 80 00       	mov    %eax,0x804000
  80168e:	83 c4 10             	add    $0x10,%esp
  801691:	eb c5                	jmp    801658 <fsipc+0x12>

00801693 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801693:	55                   	push   %ebp
  801694:	89 e5                	mov    %esp,%ebp
  801696:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801699:	8b 45 08             	mov    0x8(%ebp),%eax
  80169c:	8b 40 0c             	mov    0xc(%eax),%eax
  80169f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016a7:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b1:	b8 02 00 00 00       	mov    $0x2,%eax
  8016b6:	e8 8b ff ff ff       	call   801646 <fsipc>
}
  8016bb:	c9                   	leave  
  8016bc:	c3                   	ret    

008016bd <devfile_flush>:
{
  8016bd:	55                   	push   %ebp
  8016be:	89 e5                	mov    %esp,%ebp
  8016c0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c6:	8b 40 0c             	mov    0xc(%eax),%eax
  8016c9:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d3:	b8 06 00 00 00       	mov    $0x6,%eax
  8016d8:	e8 69 ff ff ff       	call   801646 <fsipc>
}
  8016dd:	c9                   	leave  
  8016de:	c3                   	ret    

008016df <devfile_stat>:
{
  8016df:	55                   	push   %ebp
  8016e0:	89 e5                	mov    %esp,%ebp
  8016e2:	53                   	push   %ebx
  8016e3:	83 ec 04             	sub    $0x4,%esp
  8016e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ec:	8b 40 0c             	mov    0xc(%eax),%eax
  8016ef:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8016f9:	b8 05 00 00 00       	mov    $0x5,%eax
  8016fe:	e8 43 ff ff ff       	call   801646 <fsipc>
  801703:	85 c0                	test   %eax,%eax
  801705:	78 2c                	js     801733 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801707:	83 ec 08             	sub    $0x8,%esp
  80170a:	68 00 50 80 00       	push   $0x805000
  80170f:	53                   	push   %ebx
  801710:	e8 b4 f0 ff ff       	call   8007c9 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801715:	a1 80 50 80 00       	mov    0x805080,%eax
  80171a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801720:	a1 84 50 80 00       	mov    0x805084,%eax
  801725:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80172b:	83 c4 10             	add    $0x10,%esp
  80172e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801733:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801736:	c9                   	leave  
  801737:	c3                   	ret    

00801738 <devfile_write>:
{
  801738:	55                   	push   %ebp
  801739:	89 e5                	mov    %esp,%ebp
  80173b:	83 ec 0c             	sub    $0xc,%esp
  80173e:	8b 45 10             	mov    0x10(%ebp),%eax
  801741:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801746:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80174b:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80174e:	8b 55 08             	mov    0x8(%ebp),%edx
  801751:	8b 52 0c             	mov    0xc(%edx),%edx
  801754:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80175a:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf,buf,n);
  80175f:	50                   	push   %eax
  801760:	ff 75 0c             	pushl  0xc(%ebp)
  801763:	68 08 50 80 00       	push   $0x805008
  801768:	e8 ea f1 ff ff       	call   800957 <memmove>
	if((r = fsipc(FSREQ_WRITE,NULL))<0)
  80176d:	ba 00 00 00 00       	mov    $0x0,%edx
  801772:	b8 04 00 00 00       	mov    $0x4,%eax
  801777:	e8 ca fe ff ff       	call   801646 <fsipc>
}
  80177c:	c9                   	leave  
  80177d:	c3                   	ret    

0080177e <devfile_read>:
{
  80177e:	55                   	push   %ebp
  80177f:	89 e5                	mov    %esp,%ebp
  801781:	56                   	push   %esi
  801782:	53                   	push   %ebx
  801783:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801786:	8b 45 08             	mov    0x8(%ebp),%eax
  801789:	8b 40 0c             	mov    0xc(%eax),%eax
  80178c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801791:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801797:	ba 00 00 00 00       	mov    $0x0,%edx
  80179c:	b8 03 00 00 00       	mov    $0x3,%eax
  8017a1:	e8 a0 fe ff ff       	call   801646 <fsipc>
  8017a6:	89 c3                	mov    %eax,%ebx
  8017a8:	85 c0                	test   %eax,%eax
  8017aa:	78 1f                	js     8017cb <devfile_read+0x4d>
	assert(r <= n);
  8017ac:	39 f0                	cmp    %esi,%eax
  8017ae:	77 24                	ja     8017d4 <devfile_read+0x56>
	assert(r <= PGSIZE);
  8017b0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017b5:	7f 33                	jg     8017ea <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017b7:	83 ec 04             	sub    $0x4,%esp
  8017ba:	50                   	push   %eax
  8017bb:	68 00 50 80 00       	push   $0x805000
  8017c0:	ff 75 0c             	pushl  0xc(%ebp)
  8017c3:	e8 8f f1 ff ff       	call   800957 <memmove>
	return r;
  8017c8:	83 c4 10             	add    $0x10,%esp
}
  8017cb:	89 d8                	mov    %ebx,%eax
  8017cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017d0:	5b                   	pop    %ebx
  8017d1:	5e                   	pop    %esi
  8017d2:	5d                   	pop    %ebp
  8017d3:	c3                   	ret    
	assert(r <= n);
  8017d4:	68 58 27 80 00       	push   $0x802758
  8017d9:	68 5f 27 80 00       	push   $0x80275f
  8017de:	6a 7c                	push   $0x7c
  8017e0:	68 74 27 80 00       	push   $0x802774
  8017e5:	e8 85 05 00 00       	call   801d6f <_panic>
	assert(r <= PGSIZE);
  8017ea:	68 7f 27 80 00       	push   $0x80277f
  8017ef:	68 5f 27 80 00       	push   $0x80275f
  8017f4:	6a 7d                	push   $0x7d
  8017f6:	68 74 27 80 00       	push   $0x802774
  8017fb:	e8 6f 05 00 00       	call   801d6f <_panic>

00801800 <open>:
{
  801800:	55                   	push   %ebp
  801801:	89 e5                	mov    %esp,%ebp
  801803:	56                   	push   %esi
  801804:	53                   	push   %ebx
  801805:	83 ec 1c             	sub    $0x1c,%esp
  801808:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80180b:	56                   	push   %esi
  80180c:	e8 81 ef ff ff       	call   800792 <strlen>
  801811:	83 c4 10             	add    $0x10,%esp
  801814:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801819:	7f 6c                	jg     801887 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  80181b:	83 ec 0c             	sub    $0xc,%esp
  80181e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801821:	50                   	push   %eax
  801822:	e8 b4 f8 ff ff       	call   8010db <fd_alloc>
  801827:	89 c3                	mov    %eax,%ebx
  801829:	83 c4 10             	add    $0x10,%esp
  80182c:	85 c0                	test   %eax,%eax
  80182e:	78 3c                	js     80186c <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801830:	83 ec 08             	sub    $0x8,%esp
  801833:	56                   	push   %esi
  801834:	68 00 50 80 00       	push   $0x805000
  801839:	e8 8b ef ff ff       	call   8007c9 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80183e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801841:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801846:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801849:	b8 01 00 00 00       	mov    $0x1,%eax
  80184e:	e8 f3 fd ff ff       	call   801646 <fsipc>
  801853:	89 c3                	mov    %eax,%ebx
  801855:	83 c4 10             	add    $0x10,%esp
  801858:	85 c0                	test   %eax,%eax
  80185a:	78 19                	js     801875 <open+0x75>
	return fd2num(fd);
  80185c:	83 ec 0c             	sub    $0xc,%esp
  80185f:	ff 75 f4             	pushl  -0xc(%ebp)
  801862:	e8 4d f8 ff ff       	call   8010b4 <fd2num>
  801867:	89 c3                	mov    %eax,%ebx
  801869:	83 c4 10             	add    $0x10,%esp
}
  80186c:	89 d8                	mov    %ebx,%eax
  80186e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801871:	5b                   	pop    %ebx
  801872:	5e                   	pop    %esi
  801873:	5d                   	pop    %ebp
  801874:	c3                   	ret    
		fd_close(fd, 0);
  801875:	83 ec 08             	sub    $0x8,%esp
  801878:	6a 00                	push   $0x0
  80187a:	ff 75 f4             	pushl  -0xc(%ebp)
  80187d:	e8 54 f9 ff ff       	call   8011d6 <fd_close>
		return r;
  801882:	83 c4 10             	add    $0x10,%esp
  801885:	eb e5                	jmp    80186c <open+0x6c>
		return -E_BAD_PATH;
  801887:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80188c:	eb de                	jmp    80186c <open+0x6c>

0080188e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80188e:	55                   	push   %ebp
  80188f:	89 e5                	mov    %esp,%ebp
  801891:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801894:	ba 00 00 00 00       	mov    $0x0,%edx
  801899:	b8 08 00 00 00       	mov    $0x8,%eax
  80189e:	e8 a3 fd ff ff       	call   801646 <fsipc>
}
  8018a3:	c9                   	leave  
  8018a4:	c3                   	ret    

008018a5 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018a5:	55                   	push   %ebp
  8018a6:	89 e5                	mov    %esp,%ebp
  8018a8:	56                   	push   %esi
  8018a9:	53                   	push   %ebx
  8018aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018ad:	83 ec 0c             	sub    $0xc,%esp
  8018b0:	ff 75 08             	pushl  0x8(%ebp)
  8018b3:	e8 0c f8 ff ff       	call   8010c4 <fd2data>
  8018b8:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8018ba:	83 c4 08             	add    $0x8,%esp
  8018bd:	68 8b 27 80 00       	push   $0x80278b
  8018c2:	53                   	push   %ebx
  8018c3:	e8 01 ef ff ff       	call   8007c9 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018c8:	8b 46 04             	mov    0x4(%esi),%eax
  8018cb:	2b 06                	sub    (%esi),%eax
  8018cd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8018d3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018da:	00 00 00 
	stat->st_dev = &devpipe;
  8018dd:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8018e4:	30 80 00 
	return 0;
}
  8018e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8018ec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018ef:	5b                   	pop    %ebx
  8018f0:	5e                   	pop    %esi
  8018f1:	5d                   	pop    %ebp
  8018f2:	c3                   	ret    

008018f3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018f3:	55                   	push   %ebp
  8018f4:	89 e5                	mov    %esp,%ebp
  8018f6:	53                   	push   %ebx
  8018f7:	83 ec 0c             	sub    $0xc,%esp
  8018fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8018fd:	53                   	push   %ebx
  8018fe:	6a 00                	push   $0x0
  801900:	e8 42 f3 ff ff       	call   800c47 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801905:	89 1c 24             	mov    %ebx,(%esp)
  801908:	e8 b7 f7 ff ff       	call   8010c4 <fd2data>
  80190d:	83 c4 08             	add    $0x8,%esp
  801910:	50                   	push   %eax
  801911:	6a 00                	push   $0x0
  801913:	e8 2f f3 ff ff       	call   800c47 <sys_page_unmap>
}
  801918:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80191b:	c9                   	leave  
  80191c:	c3                   	ret    

0080191d <_pipeisclosed>:
{
  80191d:	55                   	push   %ebp
  80191e:	89 e5                	mov    %esp,%ebp
  801920:	57                   	push   %edi
  801921:	56                   	push   %esi
  801922:	53                   	push   %ebx
  801923:	83 ec 1c             	sub    $0x1c,%esp
  801926:	89 c7                	mov    %eax,%edi
  801928:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  80192a:	a1 04 40 80 00       	mov    0x804004,%eax
  80192f:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801932:	83 ec 0c             	sub    $0xc,%esp
  801935:	57                   	push   %edi
  801936:	e8 0a 06 00 00       	call   801f45 <pageref>
  80193b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80193e:	89 34 24             	mov    %esi,(%esp)
  801941:	e8 ff 05 00 00       	call   801f45 <pageref>
		nn = thisenv->env_runs;
  801946:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80194c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80194f:	83 c4 10             	add    $0x10,%esp
  801952:	39 cb                	cmp    %ecx,%ebx
  801954:	74 1b                	je     801971 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801956:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801959:	75 cf                	jne    80192a <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80195b:	8b 42 58             	mov    0x58(%edx),%eax
  80195e:	6a 01                	push   $0x1
  801960:	50                   	push   %eax
  801961:	53                   	push   %ebx
  801962:	68 92 27 80 00       	push   $0x802792
  801967:	e8 3e e8 ff ff       	call   8001aa <cprintf>
  80196c:	83 c4 10             	add    $0x10,%esp
  80196f:	eb b9                	jmp    80192a <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801971:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801974:	0f 94 c0             	sete   %al
  801977:	0f b6 c0             	movzbl %al,%eax
}
  80197a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80197d:	5b                   	pop    %ebx
  80197e:	5e                   	pop    %esi
  80197f:	5f                   	pop    %edi
  801980:	5d                   	pop    %ebp
  801981:	c3                   	ret    

00801982 <devpipe_write>:
{
  801982:	55                   	push   %ebp
  801983:	89 e5                	mov    %esp,%ebp
  801985:	57                   	push   %edi
  801986:	56                   	push   %esi
  801987:	53                   	push   %ebx
  801988:	83 ec 28             	sub    $0x28,%esp
  80198b:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  80198e:	56                   	push   %esi
  80198f:	e8 30 f7 ff ff       	call   8010c4 <fd2data>
  801994:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801996:	83 c4 10             	add    $0x10,%esp
  801999:	bf 00 00 00 00       	mov    $0x0,%edi
  80199e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8019a1:	74 4f                	je     8019f2 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019a3:	8b 43 04             	mov    0x4(%ebx),%eax
  8019a6:	8b 0b                	mov    (%ebx),%ecx
  8019a8:	8d 51 20             	lea    0x20(%ecx),%edx
  8019ab:	39 d0                	cmp    %edx,%eax
  8019ad:	72 14                	jb     8019c3 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  8019af:	89 da                	mov    %ebx,%edx
  8019b1:	89 f0                	mov    %esi,%eax
  8019b3:	e8 65 ff ff ff       	call   80191d <_pipeisclosed>
  8019b8:	85 c0                	test   %eax,%eax
  8019ba:	75 3a                	jne    8019f6 <devpipe_write+0x74>
			sys_yield();
  8019bc:	e8 e2 f1 ff ff       	call   800ba3 <sys_yield>
  8019c1:	eb e0                	jmp    8019a3 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019c6:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8019ca:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8019cd:	89 c2                	mov    %eax,%edx
  8019cf:	c1 fa 1f             	sar    $0x1f,%edx
  8019d2:	89 d1                	mov    %edx,%ecx
  8019d4:	c1 e9 1b             	shr    $0x1b,%ecx
  8019d7:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8019da:	83 e2 1f             	and    $0x1f,%edx
  8019dd:	29 ca                	sub    %ecx,%edx
  8019df:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8019e3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8019e7:	83 c0 01             	add    $0x1,%eax
  8019ea:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  8019ed:	83 c7 01             	add    $0x1,%edi
  8019f0:	eb ac                	jmp    80199e <devpipe_write+0x1c>
	return i;
  8019f2:	89 f8                	mov    %edi,%eax
  8019f4:	eb 05                	jmp    8019fb <devpipe_write+0x79>
				return 0;
  8019f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019fe:	5b                   	pop    %ebx
  8019ff:	5e                   	pop    %esi
  801a00:	5f                   	pop    %edi
  801a01:	5d                   	pop    %ebp
  801a02:	c3                   	ret    

00801a03 <devpipe_read>:
{
  801a03:	55                   	push   %ebp
  801a04:	89 e5                	mov    %esp,%ebp
  801a06:	57                   	push   %edi
  801a07:	56                   	push   %esi
  801a08:	53                   	push   %ebx
  801a09:	83 ec 18             	sub    $0x18,%esp
  801a0c:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801a0f:	57                   	push   %edi
  801a10:	e8 af f6 ff ff       	call   8010c4 <fd2data>
  801a15:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801a17:	83 c4 10             	add    $0x10,%esp
  801a1a:	be 00 00 00 00       	mov    $0x0,%esi
  801a1f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a22:	74 47                	je     801a6b <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  801a24:	8b 03                	mov    (%ebx),%eax
  801a26:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a29:	75 22                	jne    801a4d <devpipe_read+0x4a>
			if (i > 0)
  801a2b:	85 f6                	test   %esi,%esi
  801a2d:	75 14                	jne    801a43 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801a2f:	89 da                	mov    %ebx,%edx
  801a31:	89 f8                	mov    %edi,%eax
  801a33:	e8 e5 fe ff ff       	call   80191d <_pipeisclosed>
  801a38:	85 c0                	test   %eax,%eax
  801a3a:	75 33                	jne    801a6f <devpipe_read+0x6c>
			sys_yield();
  801a3c:	e8 62 f1 ff ff       	call   800ba3 <sys_yield>
  801a41:	eb e1                	jmp    801a24 <devpipe_read+0x21>
				return i;
  801a43:	89 f0                	mov    %esi,%eax
}
  801a45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a48:	5b                   	pop    %ebx
  801a49:	5e                   	pop    %esi
  801a4a:	5f                   	pop    %edi
  801a4b:	5d                   	pop    %ebp
  801a4c:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a4d:	99                   	cltd   
  801a4e:	c1 ea 1b             	shr    $0x1b,%edx
  801a51:	01 d0                	add    %edx,%eax
  801a53:	83 e0 1f             	and    $0x1f,%eax
  801a56:	29 d0                	sub    %edx,%eax
  801a58:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801a5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a60:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801a63:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801a66:	83 c6 01             	add    $0x1,%esi
  801a69:	eb b4                	jmp    801a1f <devpipe_read+0x1c>
	return i;
  801a6b:	89 f0                	mov    %esi,%eax
  801a6d:	eb d6                	jmp    801a45 <devpipe_read+0x42>
				return 0;
  801a6f:	b8 00 00 00 00       	mov    $0x0,%eax
  801a74:	eb cf                	jmp    801a45 <devpipe_read+0x42>

00801a76 <pipe>:
{
  801a76:	55                   	push   %ebp
  801a77:	89 e5                	mov    %esp,%ebp
  801a79:	56                   	push   %esi
  801a7a:	53                   	push   %ebx
  801a7b:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801a7e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a81:	50                   	push   %eax
  801a82:	e8 54 f6 ff ff       	call   8010db <fd_alloc>
  801a87:	89 c3                	mov    %eax,%ebx
  801a89:	83 c4 10             	add    $0x10,%esp
  801a8c:	85 c0                	test   %eax,%eax
  801a8e:	78 5b                	js     801aeb <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a90:	83 ec 04             	sub    $0x4,%esp
  801a93:	68 07 04 00 00       	push   $0x407
  801a98:	ff 75 f4             	pushl  -0xc(%ebp)
  801a9b:	6a 00                	push   $0x0
  801a9d:	e8 20 f1 ff ff       	call   800bc2 <sys_page_alloc>
  801aa2:	89 c3                	mov    %eax,%ebx
  801aa4:	83 c4 10             	add    $0x10,%esp
  801aa7:	85 c0                	test   %eax,%eax
  801aa9:	78 40                	js     801aeb <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  801aab:	83 ec 0c             	sub    $0xc,%esp
  801aae:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ab1:	50                   	push   %eax
  801ab2:	e8 24 f6 ff ff       	call   8010db <fd_alloc>
  801ab7:	89 c3                	mov    %eax,%ebx
  801ab9:	83 c4 10             	add    $0x10,%esp
  801abc:	85 c0                	test   %eax,%eax
  801abe:	78 1b                	js     801adb <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ac0:	83 ec 04             	sub    $0x4,%esp
  801ac3:	68 07 04 00 00       	push   $0x407
  801ac8:	ff 75 f0             	pushl  -0x10(%ebp)
  801acb:	6a 00                	push   $0x0
  801acd:	e8 f0 f0 ff ff       	call   800bc2 <sys_page_alloc>
  801ad2:	89 c3                	mov    %eax,%ebx
  801ad4:	83 c4 10             	add    $0x10,%esp
  801ad7:	85 c0                	test   %eax,%eax
  801ad9:	79 19                	jns    801af4 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  801adb:	83 ec 08             	sub    $0x8,%esp
  801ade:	ff 75 f4             	pushl  -0xc(%ebp)
  801ae1:	6a 00                	push   $0x0
  801ae3:	e8 5f f1 ff ff       	call   800c47 <sys_page_unmap>
  801ae8:	83 c4 10             	add    $0x10,%esp
}
  801aeb:	89 d8                	mov    %ebx,%eax
  801aed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801af0:	5b                   	pop    %ebx
  801af1:	5e                   	pop    %esi
  801af2:	5d                   	pop    %ebp
  801af3:	c3                   	ret    
	va = fd2data(fd0);
  801af4:	83 ec 0c             	sub    $0xc,%esp
  801af7:	ff 75 f4             	pushl  -0xc(%ebp)
  801afa:	e8 c5 f5 ff ff       	call   8010c4 <fd2data>
  801aff:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b01:	83 c4 0c             	add    $0xc,%esp
  801b04:	68 07 04 00 00       	push   $0x407
  801b09:	50                   	push   %eax
  801b0a:	6a 00                	push   $0x0
  801b0c:	e8 b1 f0 ff ff       	call   800bc2 <sys_page_alloc>
  801b11:	89 c3                	mov    %eax,%ebx
  801b13:	83 c4 10             	add    $0x10,%esp
  801b16:	85 c0                	test   %eax,%eax
  801b18:	0f 88 8c 00 00 00    	js     801baa <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b1e:	83 ec 0c             	sub    $0xc,%esp
  801b21:	ff 75 f0             	pushl  -0x10(%ebp)
  801b24:	e8 9b f5 ff ff       	call   8010c4 <fd2data>
  801b29:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b30:	50                   	push   %eax
  801b31:	6a 00                	push   $0x0
  801b33:	56                   	push   %esi
  801b34:	6a 00                	push   $0x0
  801b36:	e8 ca f0 ff ff       	call   800c05 <sys_page_map>
  801b3b:	89 c3                	mov    %eax,%ebx
  801b3d:	83 c4 20             	add    $0x20,%esp
  801b40:	85 c0                	test   %eax,%eax
  801b42:	78 58                	js     801b9c <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801b44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b47:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b4d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b52:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801b59:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b5c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b62:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b64:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b67:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801b6e:	83 ec 0c             	sub    $0xc,%esp
  801b71:	ff 75 f4             	pushl  -0xc(%ebp)
  801b74:	e8 3b f5 ff ff       	call   8010b4 <fd2num>
  801b79:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b7c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b7e:	83 c4 04             	add    $0x4,%esp
  801b81:	ff 75 f0             	pushl  -0x10(%ebp)
  801b84:	e8 2b f5 ff ff       	call   8010b4 <fd2num>
  801b89:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b8c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801b8f:	83 c4 10             	add    $0x10,%esp
  801b92:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b97:	e9 4f ff ff ff       	jmp    801aeb <pipe+0x75>
	sys_page_unmap(0, va);
  801b9c:	83 ec 08             	sub    $0x8,%esp
  801b9f:	56                   	push   %esi
  801ba0:	6a 00                	push   $0x0
  801ba2:	e8 a0 f0 ff ff       	call   800c47 <sys_page_unmap>
  801ba7:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801baa:	83 ec 08             	sub    $0x8,%esp
  801bad:	ff 75 f0             	pushl  -0x10(%ebp)
  801bb0:	6a 00                	push   $0x0
  801bb2:	e8 90 f0 ff ff       	call   800c47 <sys_page_unmap>
  801bb7:	83 c4 10             	add    $0x10,%esp
  801bba:	e9 1c ff ff ff       	jmp    801adb <pipe+0x65>

00801bbf <pipeisclosed>:
{
  801bbf:	55                   	push   %ebp
  801bc0:	89 e5                	mov    %esp,%ebp
  801bc2:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bc5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bc8:	50                   	push   %eax
  801bc9:	ff 75 08             	pushl  0x8(%ebp)
  801bcc:	e8 59 f5 ff ff       	call   80112a <fd_lookup>
  801bd1:	83 c4 10             	add    $0x10,%esp
  801bd4:	85 c0                	test   %eax,%eax
  801bd6:	78 18                	js     801bf0 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801bd8:	83 ec 0c             	sub    $0xc,%esp
  801bdb:	ff 75 f4             	pushl  -0xc(%ebp)
  801bde:	e8 e1 f4 ff ff       	call   8010c4 <fd2data>
	return _pipeisclosed(fd, p);
  801be3:	89 c2                	mov    %eax,%edx
  801be5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801be8:	e8 30 fd ff ff       	call   80191d <_pipeisclosed>
  801bed:	83 c4 10             	add    $0x10,%esp
}
  801bf0:	c9                   	leave  
  801bf1:	c3                   	ret    

00801bf2 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801bf2:	55                   	push   %ebp
  801bf3:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801bf5:	b8 00 00 00 00       	mov    $0x0,%eax
  801bfa:	5d                   	pop    %ebp
  801bfb:	c3                   	ret    

00801bfc <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801bfc:	55                   	push   %ebp
  801bfd:	89 e5                	mov    %esp,%ebp
  801bff:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c02:	68 aa 27 80 00       	push   $0x8027aa
  801c07:	ff 75 0c             	pushl  0xc(%ebp)
  801c0a:	e8 ba eb ff ff       	call   8007c9 <strcpy>
	return 0;
}
  801c0f:	b8 00 00 00 00       	mov    $0x0,%eax
  801c14:	c9                   	leave  
  801c15:	c3                   	ret    

00801c16 <devcons_write>:
{
  801c16:	55                   	push   %ebp
  801c17:	89 e5                	mov    %esp,%ebp
  801c19:	57                   	push   %edi
  801c1a:	56                   	push   %esi
  801c1b:	53                   	push   %ebx
  801c1c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801c22:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801c27:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801c2d:	eb 2f                	jmp    801c5e <devcons_write+0x48>
		m = n - tot;
  801c2f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c32:	29 f3                	sub    %esi,%ebx
  801c34:	83 fb 7f             	cmp    $0x7f,%ebx
  801c37:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801c3c:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801c3f:	83 ec 04             	sub    $0x4,%esp
  801c42:	53                   	push   %ebx
  801c43:	89 f0                	mov    %esi,%eax
  801c45:	03 45 0c             	add    0xc(%ebp),%eax
  801c48:	50                   	push   %eax
  801c49:	57                   	push   %edi
  801c4a:	e8 08 ed ff ff       	call   800957 <memmove>
		sys_cputs(buf, m);
  801c4f:	83 c4 08             	add    $0x8,%esp
  801c52:	53                   	push   %ebx
  801c53:	57                   	push   %edi
  801c54:	e8 ad ee ff ff       	call   800b06 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801c59:	01 de                	add    %ebx,%esi
  801c5b:	83 c4 10             	add    $0x10,%esp
  801c5e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c61:	72 cc                	jb     801c2f <devcons_write+0x19>
}
  801c63:	89 f0                	mov    %esi,%eax
  801c65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c68:	5b                   	pop    %ebx
  801c69:	5e                   	pop    %esi
  801c6a:	5f                   	pop    %edi
  801c6b:	5d                   	pop    %ebp
  801c6c:	c3                   	ret    

00801c6d <devcons_read>:
{
  801c6d:	55                   	push   %ebp
  801c6e:	89 e5                	mov    %esp,%ebp
  801c70:	83 ec 08             	sub    $0x8,%esp
  801c73:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801c78:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c7c:	75 07                	jne    801c85 <devcons_read+0x18>
}
  801c7e:	c9                   	leave  
  801c7f:	c3                   	ret    
		sys_yield();
  801c80:	e8 1e ef ff ff       	call   800ba3 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801c85:	e8 9a ee ff ff       	call   800b24 <sys_cgetc>
  801c8a:	85 c0                	test   %eax,%eax
  801c8c:	74 f2                	je     801c80 <devcons_read+0x13>
	if (c < 0)
  801c8e:	85 c0                	test   %eax,%eax
  801c90:	78 ec                	js     801c7e <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  801c92:	83 f8 04             	cmp    $0x4,%eax
  801c95:	74 0c                	je     801ca3 <devcons_read+0x36>
	*(char*)vbuf = c;
  801c97:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c9a:	88 02                	mov    %al,(%edx)
	return 1;
  801c9c:	b8 01 00 00 00       	mov    $0x1,%eax
  801ca1:	eb db                	jmp    801c7e <devcons_read+0x11>
		return 0;
  801ca3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ca8:	eb d4                	jmp    801c7e <devcons_read+0x11>

00801caa <cputchar>:
{
  801caa:	55                   	push   %ebp
  801cab:	89 e5                	mov    %esp,%ebp
  801cad:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801cb0:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb3:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801cb6:	6a 01                	push   $0x1
  801cb8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cbb:	50                   	push   %eax
  801cbc:	e8 45 ee ff ff       	call   800b06 <sys_cputs>
}
  801cc1:	83 c4 10             	add    $0x10,%esp
  801cc4:	c9                   	leave  
  801cc5:	c3                   	ret    

00801cc6 <getchar>:
{
  801cc6:	55                   	push   %ebp
  801cc7:	89 e5                	mov    %esp,%ebp
  801cc9:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801ccc:	6a 01                	push   $0x1
  801cce:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cd1:	50                   	push   %eax
  801cd2:	6a 00                	push   $0x0
  801cd4:	e8 c2 f6 ff ff       	call   80139b <read>
	if (r < 0)
  801cd9:	83 c4 10             	add    $0x10,%esp
  801cdc:	85 c0                	test   %eax,%eax
  801cde:	78 08                	js     801ce8 <getchar+0x22>
	if (r < 1)
  801ce0:	85 c0                	test   %eax,%eax
  801ce2:	7e 06                	jle    801cea <getchar+0x24>
	return c;
  801ce4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801ce8:	c9                   	leave  
  801ce9:	c3                   	ret    
		return -E_EOF;
  801cea:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801cef:	eb f7                	jmp    801ce8 <getchar+0x22>

00801cf1 <iscons>:
{
  801cf1:	55                   	push   %ebp
  801cf2:	89 e5                	mov    %esp,%ebp
  801cf4:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cf7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cfa:	50                   	push   %eax
  801cfb:	ff 75 08             	pushl  0x8(%ebp)
  801cfe:	e8 27 f4 ff ff       	call   80112a <fd_lookup>
  801d03:	83 c4 10             	add    $0x10,%esp
  801d06:	85 c0                	test   %eax,%eax
  801d08:	78 11                	js     801d1b <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801d0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d0d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d13:	39 10                	cmp    %edx,(%eax)
  801d15:	0f 94 c0             	sete   %al
  801d18:	0f b6 c0             	movzbl %al,%eax
}
  801d1b:	c9                   	leave  
  801d1c:	c3                   	ret    

00801d1d <opencons>:
{
  801d1d:	55                   	push   %ebp
  801d1e:	89 e5                	mov    %esp,%ebp
  801d20:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801d23:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d26:	50                   	push   %eax
  801d27:	e8 af f3 ff ff       	call   8010db <fd_alloc>
  801d2c:	83 c4 10             	add    $0x10,%esp
  801d2f:	85 c0                	test   %eax,%eax
  801d31:	78 3a                	js     801d6d <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d33:	83 ec 04             	sub    $0x4,%esp
  801d36:	68 07 04 00 00       	push   $0x407
  801d3b:	ff 75 f4             	pushl  -0xc(%ebp)
  801d3e:	6a 00                	push   $0x0
  801d40:	e8 7d ee ff ff       	call   800bc2 <sys_page_alloc>
  801d45:	83 c4 10             	add    $0x10,%esp
  801d48:	85 c0                	test   %eax,%eax
  801d4a:	78 21                	js     801d6d <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801d4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d4f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d55:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d57:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d5a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d61:	83 ec 0c             	sub    $0xc,%esp
  801d64:	50                   	push   %eax
  801d65:	e8 4a f3 ff ff       	call   8010b4 <fd2num>
  801d6a:	83 c4 10             	add    $0x10,%esp
}
  801d6d:	c9                   	leave  
  801d6e:	c3                   	ret    

00801d6f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d6f:	55                   	push   %ebp
  801d70:	89 e5                	mov    %esp,%ebp
  801d72:	56                   	push   %esi
  801d73:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d74:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d77:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d7d:	e8 02 ee ff ff       	call   800b84 <sys_getenvid>
  801d82:	83 ec 0c             	sub    $0xc,%esp
  801d85:	ff 75 0c             	pushl  0xc(%ebp)
  801d88:	ff 75 08             	pushl  0x8(%ebp)
  801d8b:	56                   	push   %esi
  801d8c:	50                   	push   %eax
  801d8d:	68 b8 27 80 00       	push   $0x8027b8
  801d92:	e8 13 e4 ff ff       	call   8001aa <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d97:	83 c4 18             	add    $0x18,%esp
  801d9a:	53                   	push   %ebx
  801d9b:	ff 75 10             	pushl  0x10(%ebp)
  801d9e:	e8 b6 e3 ff ff       	call   800159 <vcprintf>
	cprintf("\n");
  801da3:	c7 04 24 54 22 80 00 	movl   $0x802254,(%esp)
  801daa:	e8 fb e3 ff ff       	call   8001aa <cprintf>
  801daf:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801db2:	cc                   	int3   
  801db3:	eb fd                	jmp    801db2 <_panic+0x43>

00801db5 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801db5:	55                   	push   %ebp
  801db6:	89 e5                	mov    %esp,%ebp
  801db8:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801dbb:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801dc2:	74 0a                	je     801dce <set_pgfault_handler+0x19>
			panic("set_pgfault_handler %e",r);
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
	}
       
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801dc4:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc7:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801dcc:	c9                   	leave  
  801dcd:	c3                   	ret    
		if((r=sys_page_alloc(thisenv->env_id,(void *)UXSTACKTOP-PGSIZE,PTE_P|PTE_W|PTE_U))<0)
  801dce:	a1 04 40 80 00       	mov    0x804004,%eax
  801dd3:	8b 40 48             	mov    0x48(%eax),%eax
  801dd6:	83 ec 04             	sub    $0x4,%esp
  801dd9:	6a 07                	push   $0x7
  801ddb:	68 00 f0 bf ee       	push   $0xeebff000
  801de0:	50                   	push   %eax
  801de1:	e8 dc ed ff ff       	call   800bc2 <sys_page_alloc>
  801de6:	83 c4 10             	add    $0x10,%esp
  801de9:	85 c0                	test   %eax,%eax
  801deb:	78 1b                	js     801e08 <set_pgfault_handler+0x53>
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
  801ded:	a1 04 40 80 00       	mov    0x804004,%eax
  801df2:	8b 40 48             	mov    0x48(%eax),%eax
  801df5:	83 ec 08             	sub    $0x8,%esp
  801df8:	68 1a 1e 80 00       	push   $0x801e1a
  801dfd:	50                   	push   %eax
  801dfe:	e8 0a ef ff ff       	call   800d0d <sys_env_set_pgfault_upcall>
  801e03:	83 c4 10             	add    $0x10,%esp
  801e06:	eb bc                	jmp    801dc4 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler %e",r);
  801e08:	50                   	push   %eax
  801e09:	68 dc 27 80 00       	push   $0x8027dc
  801e0e:	6a 22                	push   $0x22
  801e10:	68 f3 27 80 00       	push   $0x8027f3
  801e15:	e8 55 ff ff ff       	call   801d6f <_panic>

00801e1a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e1a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e1b:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e20:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e22:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 48(%esp), %ebp
  801e25:	8b 6c 24 30          	mov    0x30(%esp),%ebp
        subl $4, %ebp
  801e29:	83 ed 04             	sub    $0x4,%ebp
        movl %ebp, 48(%esp)
  801e2c:	89 6c 24 30          	mov    %ebp,0x30(%esp)
        movl 40(%esp), %eax
  801e30:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl %eax, (%ebp)
  801e34:	89 45 00             	mov    %eax,0x0(%ebp)
	// Restore the trap-time registers.  After you do this, you
 	// can no longer modify any general-purpose registers.
 	// LAB 4: Your code here.
        addl $8, %esp
  801e37:	83 c4 08             	add    $0x8,%esp
        popal
  801e3a:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $4, %esp
  801e3b:	83 c4 04             	add    $0x4,%esp
        popfl
  801e3e:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  801e3f:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  801e40:	c3                   	ret    

00801e41 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e41:	55                   	push   %ebp
  801e42:	89 e5                	mov    %esp,%ebp
  801e44:	56                   	push   %esi
  801e45:	53                   	push   %ebx
  801e46:	8b 75 08             	mov    0x8(%ebp),%esi
  801e49:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        //	panic("ipc_recv not implemented");
        int r;
       	if(pg!=NULL){
  801e4f:	85 c0                	test   %eax,%eax
  801e51:	74 3b                	je     801e8e <ipc_recv+0x4d>
	  r = sys_ipc_recv(pg);
  801e53:	83 ec 0c             	sub    $0xc,%esp
  801e56:	50                   	push   %eax
  801e57:	e8 16 ef ff ff       	call   800d72 <sys_ipc_recv>
  801e5c:	83 c4 10             	add    $0x10,%esp
	}else
	  r = sys_ipc_recv((void *)UTOP);
	if(r<0){
  801e5f:	85 c0                	test   %eax,%eax
  801e61:	78 3d                	js     801ea0 <ipc_recv+0x5f>
	if(perm_store!=NULL){
		*perm_store = 0;
            }
        	return r;
           }else{
	     if(from_env_store!=NULL)
  801e63:	85 f6                	test   %esi,%esi
  801e65:	74 0a                	je     801e71 <ipc_recv+0x30>
		     *from_env_store = thisenv->env_ipc_from;
  801e67:	a1 04 40 80 00       	mov    0x804004,%eax
  801e6c:	8b 40 74             	mov    0x74(%eax),%eax
  801e6f:	89 06                	mov    %eax,(%esi)
	     if(perm_store != NULL)
  801e71:	85 db                	test   %ebx,%ebx
  801e73:	74 0a                	je     801e7f <ipc_recv+0x3e>
		     *perm_store = thisenv->env_ipc_perm;
  801e75:	a1 04 40 80 00       	mov    0x804004,%eax
  801e7a:	8b 40 78             	mov    0x78(%eax),%eax
  801e7d:	89 03                	mov    %eax,(%ebx)
	     return thisenv->env_ipc_value;
  801e7f:	a1 04 40 80 00       	mov    0x804004,%eax
  801e84:	8b 40 70             	mov    0x70(%eax),%eax
	   }

}
  801e87:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e8a:	5b                   	pop    %ebx
  801e8b:	5e                   	pop    %esi
  801e8c:	5d                   	pop    %ebp
  801e8d:	c3                   	ret    
	  r = sys_ipc_recv((void *)UTOP);
  801e8e:	83 ec 0c             	sub    $0xc,%esp
  801e91:	68 00 00 c0 ee       	push   $0xeec00000
  801e96:	e8 d7 ee ff ff       	call   800d72 <sys_ipc_recv>
  801e9b:	83 c4 10             	add    $0x10,%esp
  801e9e:	eb bf                	jmp    801e5f <ipc_recv+0x1e>
	if(from_env_store!=NULL){
  801ea0:	85 f6                	test   %esi,%esi
  801ea2:	74 06                	je     801eaa <ipc_recv+0x69>
	  *from_env_store = 0;
  801ea4:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if(perm_store!=NULL){
  801eaa:	85 db                	test   %ebx,%ebx
  801eac:	74 d9                	je     801e87 <ipc_recv+0x46>
		*perm_store = 0;
  801eae:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801eb4:	eb d1                	jmp    801e87 <ipc_recv+0x46>

00801eb6 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801eb6:	55                   	push   %ebp
  801eb7:	89 e5                	mov    %esp,%ebp
  801eb9:	57                   	push   %edi
  801eba:	56                   	push   %esi
  801ebb:	53                   	push   %ebx
  801ebc:	83 ec 0c             	sub    $0xc,%esp
  801ebf:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ec2:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ec5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if(pg==NULL) pg = (void *)UTOP;
  801ec8:	85 db                	test   %ebx,%ebx
  801eca:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ecf:	0f 44 d8             	cmove  %eax,%ebx
	while((r=sys_ipc_try_send(to_env,val,pg,perm))<0){
  801ed2:	ff 75 14             	pushl  0x14(%ebp)
  801ed5:	53                   	push   %ebx
  801ed6:	56                   	push   %esi
  801ed7:	57                   	push   %edi
  801ed8:	e8 72 ee ff ff       	call   800d4f <sys_ipc_try_send>
  801edd:	83 c4 10             	add    $0x10,%esp
  801ee0:	85 c0                	test   %eax,%eax
  801ee2:	79 20                	jns    801f04 <ipc_send+0x4e>
	    if(r!=-E_IPC_NOT_RECV){
  801ee4:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ee7:	75 07                	jne    801ef0 <ipc_send+0x3a>
		    panic("ipc_send:send message failed\n");
	    }
	    sys_yield();
  801ee9:	e8 b5 ec ff ff       	call   800ba3 <sys_yield>
  801eee:	eb e2                	jmp    801ed2 <ipc_send+0x1c>
		    panic("ipc_send:send message failed\n");
  801ef0:	83 ec 04             	sub    $0x4,%esp
  801ef3:	68 01 28 80 00       	push   $0x802801
  801ef8:	6a 43                	push   $0x43
  801efa:	68 1f 28 80 00       	push   $0x80281f
  801eff:	e8 6b fe ff ff       	call   801d6f <_panic>
	}

}
  801f04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f07:	5b                   	pop    %ebx
  801f08:	5e                   	pop    %esi
  801f09:	5f                   	pop    %edi
  801f0a:	5d                   	pop    %ebp
  801f0b:	c3                   	ret    

00801f0c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f0c:	55                   	push   %ebp
  801f0d:	89 e5                	mov    %esp,%ebp
  801f0f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f12:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f17:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f1a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f20:	8b 52 50             	mov    0x50(%edx),%edx
  801f23:	39 ca                	cmp    %ecx,%edx
  801f25:	74 11                	je     801f38 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801f27:	83 c0 01             	add    $0x1,%eax
  801f2a:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f2f:	75 e6                	jne    801f17 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801f31:	b8 00 00 00 00       	mov    $0x0,%eax
  801f36:	eb 0b                	jmp    801f43 <ipc_find_env+0x37>
			return envs[i].env_id;
  801f38:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f3b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f40:	8b 40 48             	mov    0x48(%eax),%eax
}
  801f43:	5d                   	pop    %ebp
  801f44:	c3                   	ret    

00801f45 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f45:	55                   	push   %ebp
  801f46:	89 e5                	mov    %esp,%ebp
  801f48:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f4b:	89 d0                	mov    %edx,%eax
  801f4d:	c1 e8 16             	shr    $0x16,%eax
  801f50:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f57:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801f5c:	f6 c1 01             	test   $0x1,%cl
  801f5f:	74 1d                	je     801f7e <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801f61:	c1 ea 0c             	shr    $0xc,%edx
  801f64:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f6b:	f6 c2 01             	test   $0x1,%dl
  801f6e:	74 0e                	je     801f7e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f70:	c1 ea 0c             	shr    $0xc,%edx
  801f73:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f7a:	ef 
  801f7b:	0f b7 c0             	movzwl %ax,%eax
}
  801f7e:	5d                   	pop    %ebp
  801f7f:	c3                   	ret    

00801f80 <__udivdi3>:
  801f80:	55                   	push   %ebp
  801f81:	57                   	push   %edi
  801f82:	56                   	push   %esi
  801f83:	53                   	push   %ebx
  801f84:	83 ec 1c             	sub    $0x1c,%esp
  801f87:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801f8b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801f8f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801f93:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801f97:	85 d2                	test   %edx,%edx
  801f99:	75 35                	jne    801fd0 <__udivdi3+0x50>
  801f9b:	39 f3                	cmp    %esi,%ebx
  801f9d:	0f 87 bd 00 00 00    	ja     802060 <__udivdi3+0xe0>
  801fa3:	85 db                	test   %ebx,%ebx
  801fa5:	89 d9                	mov    %ebx,%ecx
  801fa7:	75 0b                	jne    801fb4 <__udivdi3+0x34>
  801fa9:	b8 01 00 00 00       	mov    $0x1,%eax
  801fae:	31 d2                	xor    %edx,%edx
  801fb0:	f7 f3                	div    %ebx
  801fb2:	89 c1                	mov    %eax,%ecx
  801fb4:	31 d2                	xor    %edx,%edx
  801fb6:	89 f0                	mov    %esi,%eax
  801fb8:	f7 f1                	div    %ecx
  801fba:	89 c6                	mov    %eax,%esi
  801fbc:	89 e8                	mov    %ebp,%eax
  801fbe:	89 f7                	mov    %esi,%edi
  801fc0:	f7 f1                	div    %ecx
  801fc2:	89 fa                	mov    %edi,%edx
  801fc4:	83 c4 1c             	add    $0x1c,%esp
  801fc7:	5b                   	pop    %ebx
  801fc8:	5e                   	pop    %esi
  801fc9:	5f                   	pop    %edi
  801fca:	5d                   	pop    %ebp
  801fcb:	c3                   	ret    
  801fcc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fd0:	39 f2                	cmp    %esi,%edx
  801fd2:	77 7c                	ja     802050 <__udivdi3+0xd0>
  801fd4:	0f bd fa             	bsr    %edx,%edi
  801fd7:	83 f7 1f             	xor    $0x1f,%edi
  801fda:	0f 84 98 00 00 00    	je     802078 <__udivdi3+0xf8>
  801fe0:	89 f9                	mov    %edi,%ecx
  801fe2:	b8 20 00 00 00       	mov    $0x20,%eax
  801fe7:	29 f8                	sub    %edi,%eax
  801fe9:	d3 e2                	shl    %cl,%edx
  801feb:	89 54 24 08          	mov    %edx,0x8(%esp)
  801fef:	89 c1                	mov    %eax,%ecx
  801ff1:	89 da                	mov    %ebx,%edx
  801ff3:	d3 ea                	shr    %cl,%edx
  801ff5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801ff9:	09 d1                	or     %edx,%ecx
  801ffb:	89 f2                	mov    %esi,%edx
  801ffd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802001:	89 f9                	mov    %edi,%ecx
  802003:	d3 e3                	shl    %cl,%ebx
  802005:	89 c1                	mov    %eax,%ecx
  802007:	d3 ea                	shr    %cl,%edx
  802009:	89 f9                	mov    %edi,%ecx
  80200b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80200f:	d3 e6                	shl    %cl,%esi
  802011:	89 eb                	mov    %ebp,%ebx
  802013:	89 c1                	mov    %eax,%ecx
  802015:	d3 eb                	shr    %cl,%ebx
  802017:	09 de                	or     %ebx,%esi
  802019:	89 f0                	mov    %esi,%eax
  80201b:	f7 74 24 08          	divl   0x8(%esp)
  80201f:	89 d6                	mov    %edx,%esi
  802021:	89 c3                	mov    %eax,%ebx
  802023:	f7 64 24 0c          	mull   0xc(%esp)
  802027:	39 d6                	cmp    %edx,%esi
  802029:	72 0c                	jb     802037 <__udivdi3+0xb7>
  80202b:	89 f9                	mov    %edi,%ecx
  80202d:	d3 e5                	shl    %cl,%ebp
  80202f:	39 c5                	cmp    %eax,%ebp
  802031:	73 5d                	jae    802090 <__udivdi3+0x110>
  802033:	39 d6                	cmp    %edx,%esi
  802035:	75 59                	jne    802090 <__udivdi3+0x110>
  802037:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80203a:	31 ff                	xor    %edi,%edi
  80203c:	89 fa                	mov    %edi,%edx
  80203e:	83 c4 1c             	add    $0x1c,%esp
  802041:	5b                   	pop    %ebx
  802042:	5e                   	pop    %esi
  802043:	5f                   	pop    %edi
  802044:	5d                   	pop    %ebp
  802045:	c3                   	ret    
  802046:	8d 76 00             	lea    0x0(%esi),%esi
  802049:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802050:	31 ff                	xor    %edi,%edi
  802052:	31 c0                	xor    %eax,%eax
  802054:	89 fa                	mov    %edi,%edx
  802056:	83 c4 1c             	add    $0x1c,%esp
  802059:	5b                   	pop    %ebx
  80205a:	5e                   	pop    %esi
  80205b:	5f                   	pop    %edi
  80205c:	5d                   	pop    %ebp
  80205d:	c3                   	ret    
  80205e:	66 90                	xchg   %ax,%ax
  802060:	31 ff                	xor    %edi,%edi
  802062:	89 e8                	mov    %ebp,%eax
  802064:	89 f2                	mov    %esi,%edx
  802066:	f7 f3                	div    %ebx
  802068:	89 fa                	mov    %edi,%edx
  80206a:	83 c4 1c             	add    $0x1c,%esp
  80206d:	5b                   	pop    %ebx
  80206e:	5e                   	pop    %esi
  80206f:	5f                   	pop    %edi
  802070:	5d                   	pop    %ebp
  802071:	c3                   	ret    
  802072:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802078:	39 f2                	cmp    %esi,%edx
  80207a:	72 06                	jb     802082 <__udivdi3+0x102>
  80207c:	31 c0                	xor    %eax,%eax
  80207e:	39 eb                	cmp    %ebp,%ebx
  802080:	77 d2                	ja     802054 <__udivdi3+0xd4>
  802082:	b8 01 00 00 00       	mov    $0x1,%eax
  802087:	eb cb                	jmp    802054 <__udivdi3+0xd4>
  802089:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802090:	89 d8                	mov    %ebx,%eax
  802092:	31 ff                	xor    %edi,%edi
  802094:	eb be                	jmp    802054 <__udivdi3+0xd4>
  802096:	66 90                	xchg   %ax,%ax
  802098:	66 90                	xchg   %ax,%ax
  80209a:	66 90                	xchg   %ax,%ax
  80209c:	66 90                	xchg   %ax,%ax
  80209e:	66 90                	xchg   %ax,%ax

008020a0 <__umoddi3>:
  8020a0:	55                   	push   %ebp
  8020a1:	57                   	push   %edi
  8020a2:	56                   	push   %esi
  8020a3:	53                   	push   %ebx
  8020a4:	83 ec 1c             	sub    $0x1c,%esp
  8020a7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  8020ab:	8b 74 24 30          	mov    0x30(%esp),%esi
  8020af:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8020b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020b7:	85 ed                	test   %ebp,%ebp
  8020b9:	89 f0                	mov    %esi,%eax
  8020bb:	89 da                	mov    %ebx,%edx
  8020bd:	75 19                	jne    8020d8 <__umoddi3+0x38>
  8020bf:	39 df                	cmp    %ebx,%edi
  8020c1:	0f 86 b1 00 00 00    	jbe    802178 <__umoddi3+0xd8>
  8020c7:	f7 f7                	div    %edi
  8020c9:	89 d0                	mov    %edx,%eax
  8020cb:	31 d2                	xor    %edx,%edx
  8020cd:	83 c4 1c             	add    $0x1c,%esp
  8020d0:	5b                   	pop    %ebx
  8020d1:	5e                   	pop    %esi
  8020d2:	5f                   	pop    %edi
  8020d3:	5d                   	pop    %ebp
  8020d4:	c3                   	ret    
  8020d5:	8d 76 00             	lea    0x0(%esi),%esi
  8020d8:	39 dd                	cmp    %ebx,%ebp
  8020da:	77 f1                	ja     8020cd <__umoddi3+0x2d>
  8020dc:	0f bd cd             	bsr    %ebp,%ecx
  8020df:	83 f1 1f             	xor    $0x1f,%ecx
  8020e2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8020e6:	0f 84 b4 00 00 00    	je     8021a0 <__umoddi3+0x100>
  8020ec:	b8 20 00 00 00       	mov    $0x20,%eax
  8020f1:	89 c2                	mov    %eax,%edx
  8020f3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8020f7:	29 c2                	sub    %eax,%edx
  8020f9:	89 c1                	mov    %eax,%ecx
  8020fb:	89 f8                	mov    %edi,%eax
  8020fd:	d3 e5                	shl    %cl,%ebp
  8020ff:	89 d1                	mov    %edx,%ecx
  802101:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802105:	d3 e8                	shr    %cl,%eax
  802107:	09 c5                	or     %eax,%ebp
  802109:	8b 44 24 04          	mov    0x4(%esp),%eax
  80210d:	89 c1                	mov    %eax,%ecx
  80210f:	d3 e7                	shl    %cl,%edi
  802111:	89 d1                	mov    %edx,%ecx
  802113:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802117:	89 df                	mov    %ebx,%edi
  802119:	d3 ef                	shr    %cl,%edi
  80211b:	89 c1                	mov    %eax,%ecx
  80211d:	89 f0                	mov    %esi,%eax
  80211f:	d3 e3                	shl    %cl,%ebx
  802121:	89 d1                	mov    %edx,%ecx
  802123:	89 fa                	mov    %edi,%edx
  802125:	d3 e8                	shr    %cl,%eax
  802127:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80212c:	09 d8                	or     %ebx,%eax
  80212e:	f7 f5                	div    %ebp
  802130:	d3 e6                	shl    %cl,%esi
  802132:	89 d1                	mov    %edx,%ecx
  802134:	f7 64 24 08          	mull   0x8(%esp)
  802138:	39 d1                	cmp    %edx,%ecx
  80213a:	89 c3                	mov    %eax,%ebx
  80213c:	89 d7                	mov    %edx,%edi
  80213e:	72 06                	jb     802146 <__umoddi3+0xa6>
  802140:	75 0e                	jne    802150 <__umoddi3+0xb0>
  802142:	39 c6                	cmp    %eax,%esi
  802144:	73 0a                	jae    802150 <__umoddi3+0xb0>
  802146:	2b 44 24 08          	sub    0x8(%esp),%eax
  80214a:	19 ea                	sbb    %ebp,%edx
  80214c:	89 d7                	mov    %edx,%edi
  80214e:	89 c3                	mov    %eax,%ebx
  802150:	89 ca                	mov    %ecx,%edx
  802152:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  802157:	29 de                	sub    %ebx,%esi
  802159:	19 fa                	sbb    %edi,%edx
  80215b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80215f:	89 d0                	mov    %edx,%eax
  802161:	d3 e0                	shl    %cl,%eax
  802163:	89 d9                	mov    %ebx,%ecx
  802165:	d3 ee                	shr    %cl,%esi
  802167:	d3 ea                	shr    %cl,%edx
  802169:	09 f0                	or     %esi,%eax
  80216b:	83 c4 1c             	add    $0x1c,%esp
  80216e:	5b                   	pop    %ebx
  80216f:	5e                   	pop    %esi
  802170:	5f                   	pop    %edi
  802171:	5d                   	pop    %ebp
  802172:	c3                   	ret    
  802173:	90                   	nop
  802174:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802178:	85 ff                	test   %edi,%edi
  80217a:	89 f9                	mov    %edi,%ecx
  80217c:	75 0b                	jne    802189 <__umoddi3+0xe9>
  80217e:	b8 01 00 00 00       	mov    $0x1,%eax
  802183:	31 d2                	xor    %edx,%edx
  802185:	f7 f7                	div    %edi
  802187:	89 c1                	mov    %eax,%ecx
  802189:	89 d8                	mov    %ebx,%eax
  80218b:	31 d2                	xor    %edx,%edx
  80218d:	f7 f1                	div    %ecx
  80218f:	89 f0                	mov    %esi,%eax
  802191:	f7 f1                	div    %ecx
  802193:	e9 31 ff ff ff       	jmp    8020c9 <__umoddi3+0x29>
  802198:	90                   	nop
  802199:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021a0:	39 dd                	cmp    %ebx,%ebp
  8021a2:	72 08                	jb     8021ac <__umoddi3+0x10c>
  8021a4:	39 f7                	cmp    %esi,%edi
  8021a6:	0f 87 21 ff ff ff    	ja     8020cd <__umoddi3+0x2d>
  8021ac:	89 da                	mov    %ebx,%edx
  8021ae:	89 f0                	mov    %esi,%eax
  8021b0:	29 f8                	sub    %edi,%eax
  8021b2:	19 ea                	sbb    %ebp,%edx
  8021b4:	e9 14 ff ff ff       	jmp    8020cd <__umoddi3+0x2d>
