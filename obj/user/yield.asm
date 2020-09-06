
obj/user/yield.debug:     file format elf32-i386


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
  80002c:	e8 69 00 00 00       	call   80009a <libmain>
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
  800037:	83 ec 0c             	sub    $0xc,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003a:	a1 04 40 80 00       	mov    0x804004,%eax
  80003f:	8b 40 48             	mov    0x48(%eax),%eax
  800042:	50                   	push   %eax
  800043:	68 20 1e 80 00       	push   $0x801e20
  800048:	e8 42 01 00 00       	call   80018f <cprintf>
  80004d:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 5; i++) {
  800050:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800055:	e8 2e 0b 00 00       	call   800b88 <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005a:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("Back in environment %08x, iteration %d.\n",
  80005f:	8b 40 48             	mov    0x48(%eax),%eax
  800062:	83 ec 04             	sub    $0x4,%esp
  800065:	53                   	push   %ebx
  800066:	50                   	push   %eax
  800067:	68 40 1e 80 00       	push   $0x801e40
  80006c:	e8 1e 01 00 00       	call   80018f <cprintf>
	for (i = 0; i < 5; i++) {
  800071:	83 c3 01             	add    $0x1,%ebx
  800074:	83 c4 10             	add    $0x10,%esp
  800077:	83 fb 05             	cmp    $0x5,%ebx
  80007a:	75 d9                	jne    800055 <umain+0x22>
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  80007c:	a1 04 40 80 00       	mov    0x804004,%eax
  800081:	8b 40 48             	mov    0x48(%eax),%eax
  800084:	83 ec 08             	sub    $0x8,%esp
  800087:	50                   	push   %eax
  800088:	68 6c 1e 80 00       	push   $0x801e6c
  80008d:	e8 fd 00 00 00       	call   80018f <cprintf>
}
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
  80009f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000a5:	e8 bf 0a 00 00       	call   800b69 <sys_getenvid>
  8000aa:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000af:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000b2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b7:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000bc:	85 db                	test   %ebx,%ebx
  8000be:	7e 07                	jle    8000c7 <libmain+0x2d>
		binaryname = argv[0];
  8000c0:	8b 06                	mov    (%esi),%eax
  8000c2:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000c7:	83 ec 08             	sub    $0x8,%esp
  8000ca:	56                   	push   %esi
  8000cb:	53                   	push   %ebx
  8000cc:	e8 62 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000d1:	e8 0a 00 00 00       	call   8000e0 <exit>
}
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000dc:	5b                   	pop    %ebx
  8000dd:	5e                   	pop    %esi
  8000de:	5d                   	pop    %ebp
  8000df:	c3                   	ret    

008000e0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000e6:	e8 83 0e 00 00       	call   800f6e <close_all>
	sys_env_destroy(0);
  8000eb:	83 ec 0c             	sub    $0xc,%esp
  8000ee:	6a 00                	push   $0x0
  8000f0:	e8 33 0a 00 00       	call   800b28 <sys_env_destroy>
}
  8000f5:	83 c4 10             	add    $0x10,%esp
  8000f8:	c9                   	leave  
  8000f9:	c3                   	ret    

008000fa <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000fa:	55                   	push   %ebp
  8000fb:	89 e5                	mov    %esp,%ebp
  8000fd:	53                   	push   %ebx
  8000fe:	83 ec 04             	sub    $0x4,%esp
  800101:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800104:	8b 13                	mov    (%ebx),%edx
  800106:	8d 42 01             	lea    0x1(%edx),%eax
  800109:	89 03                	mov    %eax,(%ebx)
  80010b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80010e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800112:	3d ff 00 00 00       	cmp    $0xff,%eax
  800117:	74 09                	je     800122 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800119:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80011d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800120:	c9                   	leave  
  800121:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800122:	83 ec 08             	sub    $0x8,%esp
  800125:	68 ff 00 00 00       	push   $0xff
  80012a:	8d 43 08             	lea    0x8(%ebx),%eax
  80012d:	50                   	push   %eax
  80012e:	e8 b8 09 00 00       	call   800aeb <sys_cputs>
		b->idx = 0;
  800133:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800139:	83 c4 10             	add    $0x10,%esp
  80013c:	eb db                	jmp    800119 <putch+0x1f>

0080013e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80013e:	55                   	push   %ebp
  80013f:	89 e5                	mov    %esp,%ebp
  800141:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800147:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80014e:	00 00 00 
	b.cnt = 0;
  800151:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800158:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80015b:	ff 75 0c             	pushl  0xc(%ebp)
  80015e:	ff 75 08             	pushl  0x8(%ebp)
  800161:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800167:	50                   	push   %eax
  800168:	68 fa 00 80 00       	push   $0x8000fa
  80016d:	e8 1a 01 00 00       	call   80028c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800172:	83 c4 08             	add    $0x8,%esp
  800175:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80017b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800181:	50                   	push   %eax
  800182:	e8 64 09 00 00       	call   800aeb <sys_cputs>

	return b.cnt;
}
  800187:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018d:	c9                   	leave  
  80018e:	c3                   	ret    

0080018f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80018f:	55                   	push   %ebp
  800190:	89 e5                	mov    %esp,%ebp
  800192:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800195:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800198:	50                   	push   %eax
  800199:	ff 75 08             	pushl  0x8(%ebp)
  80019c:	e8 9d ff ff ff       	call   80013e <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a1:	c9                   	leave  
  8001a2:	c3                   	ret    

008001a3 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a3:	55                   	push   %ebp
  8001a4:	89 e5                	mov    %esp,%ebp
  8001a6:	57                   	push   %edi
  8001a7:	56                   	push   %esi
  8001a8:	53                   	push   %ebx
  8001a9:	83 ec 1c             	sub    $0x1c,%esp
  8001ac:	89 c7                	mov    %eax,%edi
  8001ae:	89 d6                	mov    %edx,%esi
  8001b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001b9:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001bc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001bf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001c4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001c7:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001ca:	39 d3                	cmp    %edx,%ebx
  8001cc:	72 05                	jb     8001d3 <printnum+0x30>
  8001ce:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001d1:	77 7a                	ja     80024d <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d3:	83 ec 0c             	sub    $0xc,%esp
  8001d6:	ff 75 18             	pushl  0x18(%ebp)
  8001d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8001dc:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001df:	53                   	push   %ebx
  8001e0:	ff 75 10             	pushl  0x10(%ebp)
  8001e3:	83 ec 08             	sub    $0x8,%esp
  8001e6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e9:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ec:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ef:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f2:	e8 e9 19 00 00       	call   801be0 <__udivdi3>
  8001f7:	83 c4 18             	add    $0x18,%esp
  8001fa:	52                   	push   %edx
  8001fb:	50                   	push   %eax
  8001fc:	89 f2                	mov    %esi,%edx
  8001fe:	89 f8                	mov    %edi,%eax
  800200:	e8 9e ff ff ff       	call   8001a3 <printnum>
  800205:	83 c4 20             	add    $0x20,%esp
  800208:	eb 13                	jmp    80021d <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80020a:	83 ec 08             	sub    $0x8,%esp
  80020d:	56                   	push   %esi
  80020e:	ff 75 18             	pushl  0x18(%ebp)
  800211:	ff d7                	call   *%edi
  800213:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800216:	83 eb 01             	sub    $0x1,%ebx
  800219:	85 db                	test   %ebx,%ebx
  80021b:	7f ed                	jg     80020a <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80021d:	83 ec 08             	sub    $0x8,%esp
  800220:	56                   	push   %esi
  800221:	83 ec 04             	sub    $0x4,%esp
  800224:	ff 75 e4             	pushl  -0x1c(%ebp)
  800227:	ff 75 e0             	pushl  -0x20(%ebp)
  80022a:	ff 75 dc             	pushl  -0x24(%ebp)
  80022d:	ff 75 d8             	pushl  -0x28(%ebp)
  800230:	e8 cb 1a 00 00       	call   801d00 <__umoddi3>
  800235:	83 c4 14             	add    $0x14,%esp
  800238:	0f be 80 95 1e 80 00 	movsbl 0x801e95(%eax),%eax
  80023f:	50                   	push   %eax
  800240:	ff d7                	call   *%edi
}
  800242:	83 c4 10             	add    $0x10,%esp
  800245:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800248:	5b                   	pop    %ebx
  800249:	5e                   	pop    %esi
  80024a:	5f                   	pop    %edi
  80024b:	5d                   	pop    %ebp
  80024c:	c3                   	ret    
  80024d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800250:	eb c4                	jmp    800216 <printnum+0x73>

00800252 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800252:	55                   	push   %ebp
  800253:	89 e5                	mov    %esp,%ebp
  800255:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800258:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80025c:	8b 10                	mov    (%eax),%edx
  80025e:	3b 50 04             	cmp    0x4(%eax),%edx
  800261:	73 0a                	jae    80026d <sprintputch+0x1b>
		*b->buf++ = ch;
  800263:	8d 4a 01             	lea    0x1(%edx),%ecx
  800266:	89 08                	mov    %ecx,(%eax)
  800268:	8b 45 08             	mov    0x8(%ebp),%eax
  80026b:	88 02                	mov    %al,(%edx)
}
  80026d:	5d                   	pop    %ebp
  80026e:	c3                   	ret    

0080026f <printfmt>:
{
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
  800272:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800275:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800278:	50                   	push   %eax
  800279:	ff 75 10             	pushl  0x10(%ebp)
  80027c:	ff 75 0c             	pushl  0xc(%ebp)
  80027f:	ff 75 08             	pushl  0x8(%ebp)
  800282:	e8 05 00 00 00       	call   80028c <vprintfmt>
}
  800287:	83 c4 10             	add    $0x10,%esp
  80028a:	c9                   	leave  
  80028b:	c3                   	ret    

0080028c <vprintfmt>:
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	57                   	push   %edi
  800290:	56                   	push   %esi
  800291:	53                   	push   %ebx
  800292:	83 ec 2c             	sub    $0x2c,%esp
  800295:	8b 75 08             	mov    0x8(%ebp),%esi
  800298:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80029b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80029e:	e9 c1 03 00 00       	jmp    800664 <vprintfmt+0x3d8>
		padc = ' ';
  8002a3:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8002a7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8002ae:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8002b5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002bc:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002c1:	8d 47 01             	lea    0x1(%edi),%eax
  8002c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002c7:	0f b6 17             	movzbl (%edi),%edx
  8002ca:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002cd:	3c 55                	cmp    $0x55,%al
  8002cf:	0f 87 12 04 00 00    	ja     8006e7 <vprintfmt+0x45b>
  8002d5:	0f b6 c0             	movzbl %al,%eax
  8002d8:	ff 24 85 e0 1f 80 00 	jmp    *0x801fe0(,%eax,4)
  8002df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002e2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8002e6:	eb d9                	jmp    8002c1 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8002e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  8002eb:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002ef:	eb d0                	jmp    8002c1 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8002f1:	0f b6 d2             	movzbl %dl,%edx
  8002f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8002fc:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002ff:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800302:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800306:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800309:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80030c:	83 f9 09             	cmp    $0x9,%ecx
  80030f:	77 55                	ja     800366 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800311:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800314:	eb e9                	jmp    8002ff <vprintfmt+0x73>
			precision = va_arg(ap, int);
  800316:	8b 45 14             	mov    0x14(%ebp),%eax
  800319:	8b 00                	mov    (%eax),%eax
  80031b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80031e:	8b 45 14             	mov    0x14(%ebp),%eax
  800321:	8d 40 04             	lea    0x4(%eax),%eax
  800324:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800327:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80032a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80032e:	79 91                	jns    8002c1 <vprintfmt+0x35>
				width = precision, precision = -1;
  800330:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800333:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800336:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80033d:	eb 82                	jmp    8002c1 <vprintfmt+0x35>
  80033f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800342:	85 c0                	test   %eax,%eax
  800344:	ba 00 00 00 00       	mov    $0x0,%edx
  800349:	0f 49 d0             	cmovns %eax,%edx
  80034c:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80034f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800352:	e9 6a ff ff ff       	jmp    8002c1 <vprintfmt+0x35>
  800357:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80035a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800361:	e9 5b ff ff ff       	jmp    8002c1 <vprintfmt+0x35>
  800366:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800369:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80036c:	eb bc                	jmp    80032a <vprintfmt+0x9e>
			lflag++;
  80036e:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800371:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800374:	e9 48 ff ff ff       	jmp    8002c1 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  800379:	8b 45 14             	mov    0x14(%ebp),%eax
  80037c:	8d 78 04             	lea    0x4(%eax),%edi
  80037f:	83 ec 08             	sub    $0x8,%esp
  800382:	53                   	push   %ebx
  800383:	ff 30                	pushl  (%eax)
  800385:	ff d6                	call   *%esi
			break;
  800387:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80038a:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80038d:	e9 cf 02 00 00       	jmp    800661 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  800392:	8b 45 14             	mov    0x14(%ebp),%eax
  800395:	8d 78 04             	lea    0x4(%eax),%edi
  800398:	8b 00                	mov    (%eax),%eax
  80039a:	99                   	cltd   
  80039b:	31 d0                	xor    %edx,%eax
  80039d:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80039f:	83 f8 0f             	cmp    $0xf,%eax
  8003a2:	7f 23                	jg     8003c7 <vprintfmt+0x13b>
  8003a4:	8b 14 85 40 21 80 00 	mov    0x802140(,%eax,4),%edx
  8003ab:	85 d2                	test   %edx,%edx
  8003ad:	74 18                	je     8003c7 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8003af:	52                   	push   %edx
  8003b0:	68 71 22 80 00       	push   $0x802271
  8003b5:	53                   	push   %ebx
  8003b6:	56                   	push   %esi
  8003b7:	e8 b3 fe ff ff       	call   80026f <printfmt>
  8003bc:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003bf:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003c2:	e9 9a 02 00 00       	jmp    800661 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  8003c7:	50                   	push   %eax
  8003c8:	68 ad 1e 80 00       	push   $0x801ead
  8003cd:	53                   	push   %ebx
  8003ce:	56                   	push   %esi
  8003cf:	e8 9b fe ff ff       	call   80026f <printfmt>
  8003d4:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003d7:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003da:	e9 82 02 00 00       	jmp    800661 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  8003df:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e2:	83 c0 04             	add    $0x4,%eax
  8003e5:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003eb:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003ed:	85 ff                	test   %edi,%edi
  8003ef:	b8 a6 1e 80 00       	mov    $0x801ea6,%eax
  8003f4:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8003f7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003fb:	0f 8e bd 00 00 00    	jle    8004be <vprintfmt+0x232>
  800401:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800405:	75 0e                	jne    800415 <vprintfmt+0x189>
  800407:	89 75 08             	mov    %esi,0x8(%ebp)
  80040a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80040d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800410:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800413:	eb 6d                	jmp    800482 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  800415:	83 ec 08             	sub    $0x8,%esp
  800418:	ff 75 d0             	pushl  -0x30(%ebp)
  80041b:	57                   	push   %edi
  80041c:	e8 6e 03 00 00       	call   80078f <strnlen>
  800421:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800424:	29 c1                	sub    %eax,%ecx
  800426:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800429:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80042c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800430:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800433:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800436:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800438:	eb 0f                	jmp    800449 <vprintfmt+0x1bd>
					putch(padc, putdat);
  80043a:	83 ec 08             	sub    $0x8,%esp
  80043d:	53                   	push   %ebx
  80043e:	ff 75 e0             	pushl  -0x20(%ebp)
  800441:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800443:	83 ef 01             	sub    $0x1,%edi
  800446:	83 c4 10             	add    $0x10,%esp
  800449:	85 ff                	test   %edi,%edi
  80044b:	7f ed                	jg     80043a <vprintfmt+0x1ae>
  80044d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800450:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800453:	85 c9                	test   %ecx,%ecx
  800455:	b8 00 00 00 00       	mov    $0x0,%eax
  80045a:	0f 49 c1             	cmovns %ecx,%eax
  80045d:	29 c1                	sub    %eax,%ecx
  80045f:	89 75 08             	mov    %esi,0x8(%ebp)
  800462:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800465:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800468:	89 cb                	mov    %ecx,%ebx
  80046a:	eb 16                	jmp    800482 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  80046c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800470:	75 31                	jne    8004a3 <vprintfmt+0x217>
					putch(ch, putdat);
  800472:	83 ec 08             	sub    $0x8,%esp
  800475:	ff 75 0c             	pushl  0xc(%ebp)
  800478:	50                   	push   %eax
  800479:	ff 55 08             	call   *0x8(%ebp)
  80047c:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80047f:	83 eb 01             	sub    $0x1,%ebx
  800482:	83 c7 01             	add    $0x1,%edi
  800485:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800489:	0f be c2             	movsbl %dl,%eax
  80048c:	85 c0                	test   %eax,%eax
  80048e:	74 59                	je     8004e9 <vprintfmt+0x25d>
  800490:	85 f6                	test   %esi,%esi
  800492:	78 d8                	js     80046c <vprintfmt+0x1e0>
  800494:	83 ee 01             	sub    $0x1,%esi
  800497:	79 d3                	jns    80046c <vprintfmt+0x1e0>
  800499:	89 df                	mov    %ebx,%edi
  80049b:	8b 75 08             	mov    0x8(%ebp),%esi
  80049e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004a1:	eb 37                	jmp    8004da <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004a3:	0f be d2             	movsbl %dl,%edx
  8004a6:	83 ea 20             	sub    $0x20,%edx
  8004a9:	83 fa 5e             	cmp    $0x5e,%edx
  8004ac:	76 c4                	jbe    800472 <vprintfmt+0x1e6>
					putch('?', putdat);
  8004ae:	83 ec 08             	sub    $0x8,%esp
  8004b1:	ff 75 0c             	pushl  0xc(%ebp)
  8004b4:	6a 3f                	push   $0x3f
  8004b6:	ff 55 08             	call   *0x8(%ebp)
  8004b9:	83 c4 10             	add    $0x10,%esp
  8004bc:	eb c1                	jmp    80047f <vprintfmt+0x1f3>
  8004be:	89 75 08             	mov    %esi,0x8(%ebp)
  8004c1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004c4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004c7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004ca:	eb b6                	jmp    800482 <vprintfmt+0x1f6>
				putch(' ', putdat);
  8004cc:	83 ec 08             	sub    $0x8,%esp
  8004cf:	53                   	push   %ebx
  8004d0:	6a 20                	push   $0x20
  8004d2:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004d4:	83 ef 01             	sub    $0x1,%edi
  8004d7:	83 c4 10             	add    $0x10,%esp
  8004da:	85 ff                	test   %edi,%edi
  8004dc:	7f ee                	jg     8004cc <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  8004de:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004e1:	89 45 14             	mov    %eax,0x14(%ebp)
  8004e4:	e9 78 01 00 00       	jmp    800661 <vprintfmt+0x3d5>
  8004e9:	89 df                	mov    %ebx,%edi
  8004eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f1:	eb e7                	jmp    8004da <vprintfmt+0x24e>
	if (lflag >= 2)
  8004f3:	83 f9 01             	cmp    $0x1,%ecx
  8004f6:	7e 3f                	jle    800537 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  8004f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fb:	8b 50 04             	mov    0x4(%eax),%edx
  8004fe:	8b 00                	mov    (%eax),%eax
  800500:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800503:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800506:	8b 45 14             	mov    0x14(%ebp),%eax
  800509:	8d 40 08             	lea    0x8(%eax),%eax
  80050c:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80050f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800513:	79 5c                	jns    800571 <vprintfmt+0x2e5>
				putch('-', putdat);
  800515:	83 ec 08             	sub    $0x8,%esp
  800518:	53                   	push   %ebx
  800519:	6a 2d                	push   $0x2d
  80051b:	ff d6                	call   *%esi
				num = -(long long) num;
  80051d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800520:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800523:	f7 da                	neg    %edx
  800525:	83 d1 00             	adc    $0x0,%ecx
  800528:	f7 d9                	neg    %ecx
  80052a:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80052d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800532:	e9 10 01 00 00       	jmp    800647 <vprintfmt+0x3bb>
	else if (lflag)
  800537:	85 c9                	test   %ecx,%ecx
  800539:	75 1b                	jne    800556 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  80053b:	8b 45 14             	mov    0x14(%ebp),%eax
  80053e:	8b 00                	mov    (%eax),%eax
  800540:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800543:	89 c1                	mov    %eax,%ecx
  800545:	c1 f9 1f             	sar    $0x1f,%ecx
  800548:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80054b:	8b 45 14             	mov    0x14(%ebp),%eax
  80054e:	8d 40 04             	lea    0x4(%eax),%eax
  800551:	89 45 14             	mov    %eax,0x14(%ebp)
  800554:	eb b9                	jmp    80050f <vprintfmt+0x283>
		return va_arg(*ap, long);
  800556:	8b 45 14             	mov    0x14(%ebp),%eax
  800559:	8b 00                	mov    (%eax),%eax
  80055b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80055e:	89 c1                	mov    %eax,%ecx
  800560:	c1 f9 1f             	sar    $0x1f,%ecx
  800563:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800566:	8b 45 14             	mov    0x14(%ebp),%eax
  800569:	8d 40 04             	lea    0x4(%eax),%eax
  80056c:	89 45 14             	mov    %eax,0x14(%ebp)
  80056f:	eb 9e                	jmp    80050f <vprintfmt+0x283>
			num = getint(&ap, lflag);
  800571:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800574:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800577:	b8 0a 00 00 00       	mov    $0xa,%eax
  80057c:	e9 c6 00 00 00       	jmp    800647 <vprintfmt+0x3bb>
	if (lflag >= 2)
  800581:	83 f9 01             	cmp    $0x1,%ecx
  800584:	7e 18                	jle    80059e <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  800586:	8b 45 14             	mov    0x14(%ebp),%eax
  800589:	8b 10                	mov    (%eax),%edx
  80058b:	8b 48 04             	mov    0x4(%eax),%ecx
  80058e:	8d 40 08             	lea    0x8(%eax),%eax
  800591:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800594:	b8 0a 00 00 00       	mov    $0xa,%eax
  800599:	e9 a9 00 00 00       	jmp    800647 <vprintfmt+0x3bb>
	else if (lflag)
  80059e:	85 c9                	test   %ecx,%ecx
  8005a0:	75 1a                	jne    8005bc <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  8005a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a5:	8b 10                	mov    (%eax),%edx
  8005a7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ac:	8d 40 04             	lea    0x4(%eax),%eax
  8005af:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005b2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b7:	e9 8b 00 00 00       	jmp    800647 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8005bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bf:	8b 10                	mov    (%eax),%edx
  8005c1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005c6:	8d 40 04             	lea    0x4(%eax),%eax
  8005c9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005cc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d1:	eb 74                	jmp    800647 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8005d3:	83 f9 01             	cmp    $0x1,%ecx
  8005d6:	7e 15                	jle    8005ed <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  8005d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005db:	8b 10                	mov    (%eax),%edx
  8005dd:	8b 48 04             	mov    0x4(%eax),%ecx
  8005e0:	8d 40 08             	lea    0x8(%eax),%eax
  8005e3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8005e6:	b8 08 00 00 00       	mov    $0x8,%eax
  8005eb:	eb 5a                	jmp    800647 <vprintfmt+0x3bb>
	else if (lflag)
  8005ed:	85 c9                	test   %ecx,%ecx
  8005ef:	75 17                	jne    800608 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  8005f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f4:	8b 10                	mov    (%eax),%edx
  8005f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005fb:	8d 40 04             	lea    0x4(%eax),%eax
  8005fe:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800601:	b8 08 00 00 00       	mov    $0x8,%eax
  800606:	eb 3f                	jmp    800647 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800608:	8b 45 14             	mov    0x14(%ebp),%eax
  80060b:	8b 10                	mov    (%eax),%edx
  80060d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800612:	8d 40 04             	lea    0x4(%eax),%eax
  800615:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800618:	b8 08 00 00 00       	mov    $0x8,%eax
  80061d:	eb 28                	jmp    800647 <vprintfmt+0x3bb>
			putch('0', putdat);
  80061f:	83 ec 08             	sub    $0x8,%esp
  800622:	53                   	push   %ebx
  800623:	6a 30                	push   $0x30
  800625:	ff d6                	call   *%esi
			putch('x', putdat);
  800627:	83 c4 08             	add    $0x8,%esp
  80062a:	53                   	push   %ebx
  80062b:	6a 78                	push   $0x78
  80062d:	ff d6                	call   *%esi
			num = (unsigned long long)
  80062f:	8b 45 14             	mov    0x14(%ebp),%eax
  800632:	8b 10                	mov    (%eax),%edx
  800634:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800639:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80063c:	8d 40 04             	lea    0x4(%eax),%eax
  80063f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800642:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800647:	83 ec 0c             	sub    $0xc,%esp
  80064a:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80064e:	57                   	push   %edi
  80064f:	ff 75 e0             	pushl  -0x20(%ebp)
  800652:	50                   	push   %eax
  800653:	51                   	push   %ecx
  800654:	52                   	push   %edx
  800655:	89 da                	mov    %ebx,%edx
  800657:	89 f0                	mov    %esi,%eax
  800659:	e8 45 fb ff ff       	call   8001a3 <printnum>
			break;
  80065e:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800661:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800664:	83 c7 01             	add    $0x1,%edi
  800667:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80066b:	83 f8 25             	cmp    $0x25,%eax
  80066e:	0f 84 2f fc ff ff    	je     8002a3 <vprintfmt+0x17>
			if (ch == '\0')
  800674:	85 c0                	test   %eax,%eax
  800676:	0f 84 8b 00 00 00    	je     800707 <vprintfmt+0x47b>
			putch(ch, putdat);
  80067c:	83 ec 08             	sub    $0x8,%esp
  80067f:	53                   	push   %ebx
  800680:	50                   	push   %eax
  800681:	ff d6                	call   *%esi
  800683:	83 c4 10             	add    $0x10,%esp
  800686:	eb dc                	jmp    800664 <vprintfmt+0x3d8>
	if (lflag >= 2)
  800688:	83 f9 01             	cmp    $0x1,%ecx
  80068b:	7e 15                	jle    8006a2 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  80068d:	8b 45 14             	mov    0x14(%ebp),%eax
  800690:	8b 10                	mov    (%eax),%edx
  800692:	8b 48 04             	mov    0x4(%eax),%ecx
  800695:	8d 40 08             	lea    0x8(%eax),%eax
  800698:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80069b:	b8 10 00 00 00       	mov    $0x10,%eax
  8006a0:	eb a5                	jmp    800647 <vprintfmt+0x3bb>
	else if (lflag)
  8006a2:	85 c9                	test   %ecx,%ecx
  8006a4:	75 17                	jne    8006bd <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  8006a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a9:	8b 10                	mov    (%eax),%edx
  8006ab:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b0:	8d 40 04             	lea    0x4(%eax),%eax
  8006b3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b6:	b8 10 00 00 00       	mov    $0x10,%eax
  8006bb:	eb 8a                	jmp    800647 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8006bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c0:	8b 10                	mov    (%eax),%edx
  8006c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006c7:	8d 40 04             	lea    0x4(%eax),%eax
  8006ca:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006cd:	b8 10 00 00 00       	mov    $0x10,%eax
  8006d2:	e9 70 ff ff ff       	jmp    800647 <vprintfmt+0x3bb>
			putch(ch, putdat);
  8006d7:	83 ec 08             	sub    $0x8,%esp
  8006da:	53                   	push   %ebx
  8006db:	6a 25                	push   $0x25
  8006dd:	ff d6                	call   *%esi
			break;
  8006df:	83 c4 10             	add    $0x10,%esp
  8006e2:	e9 7a ff ff ff       	jmp    800661 <vprintfmt+0x3d5>
			putch('%', putdat);
  8006e7:	83 ec 08             	sub    $0x8,%esp
  8006ea:	53                   	push   %ebx
  8006eb:	6a 25                	push   $0x25
  8006ed:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006ef:	83 c4 10             	add    $0x10,%esp
  8006f2:	89 f8                	mov    %edi,%eax
  8006f4:	eb 03                	jmp    8006f9 <vprintfmt+0x46d>
  8006f6:	83 e8 01             	sub    $0x1,%eax
  8006f9:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006fd:	75 f7                	jne    8006f6 <vprintfmt+0x46a>
  8006ff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800702:	e9 5a ff ff ff       	jmp    800661 <vprintfmt+0x3d5>
}
  800707:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80070a:	5b                   	pop    %ebx
  80070b:	5e                   	pop    %esi
  80070c:	5f                   	pop    %edi
  80070d:	5d                   	pop    %ebp
  80070e:	c3                   	ret    

0080070f <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80070f:	55                   	push   %ebp
  800710:	89 e5                	mov    %esp,%ebp
  800712:	83 ec 18             	sub    $0x18,%esp
  800715:	8b 45 08             	mov    0x8(%ebp),%eax
  800718:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80071b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80071e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800722:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800725:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80072c:	85 c0                	test   %eax,%eax
  80072e:	74 26                	je     800756 <vsnprintf+0x47>
  800730:	85 d2                	test   %edx,%edx
  800732:	7e 22                	jle    800756 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800734:	ff 75 14             	pushl  0x14(%ebp)
  800737:	ff 75 10             	pushl  0x10(%ebp)
  80073a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80073d:	50                   	push   %eax
  80073e:	68 52 02 80 00       	push   $0x800252
  800743:	e8 44 fb ff ff       	call   80028c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800748:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80074b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80074e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800751:	83 c4 10             	add    $0x10,%esp
}
  800754:	c9                   	leave  
  800755:	c3                   	ret    
		return -E_INVAL;
  800756:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80075b:	eb f7                	jmp    800754 <vsnprintf+0x45>

0080075d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80075d:	55                   	push   %ebp
  80075e:	89 e5                	mov    %esp,%ebp
  800760:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800763:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800766:	50                   	push   %eax
  800767:	ff 75 10             	pushl  0x10(%ebp)
  80076a:	ff 75 0c             	pushl  0xc(%ebp)
  80076d:	ff 75 08             	pushl  0x8(%ebp)
  800770:	e8 9a ff ff ff       	call   80070f <vsnprintf>
	va_end(ap);

	return rc;
}
  800775:	c9                   	leave  
  800776:	c3                   	ret    

00800777 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800777:	55                   	push   %ebp
  800778:	89 e5                	mov    %esp,%ebp
  80077a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80077d:	b8 00 00 00 00       	mov    $0x0,%eax
  800782:	eb 03                	jmp    800787 <strlen+0x10>
		n++;
  800784:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800787:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80078b:	75 f7                	jne    800784 <strlen+0xd>
	return n;
}
  80078d:	5d                   	pop    %ebp
  80078e:	c3                   	ret    

0080078f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80078f:	55                   	push   %ebp
  800790:	89 e5                	mov    %esp,%ebp
  800792:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800795:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800798:	b8 00 00 00 00       	mov    $0x0,%eax
  80079d:	eb 03                	jmp    8007a2 <strnlen+0x13>
		n++;
  80079f:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a2:	39 d0                	cmp    %edx,%eax
  8007a4:	74 06                	je     8007ac <strnlen+0x1d>
  8007a6:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007aa:	75 f3                	jne    80079f <strnlen+0x10>
	return n;
}
  8007ac:	5d                   	pop    %ebp
  8007ad:	c3                   	ret    

008007ae <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ae:	55                   	push   %ebp
  8007af:	89 e5                	mov    %esp,%ebp
  8007b1:	53                   	push   %ebx
  8007b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b8:	89 c2                	mov    %eax,%edx
  8007ba:	83 c1 01             	add    $0x1,%ecx
  8007bd:	83 c2 01             	add    $0x1,%edx
  8007c0:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007c4:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007c7:	84 db                	test   %bl,%bl
  8007c9:	75 ef                	jne    8007ba <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007cb:	5b                   	pop    %ebx
  8007cc:	5d                   	pop    %ebp
  8007cd:	c3                   	ret    

008007ce <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007ce:	55                   	push   %ebp
  8007cf:	89 e5                	mov    %esp,%ebp
  8007d1:	53                   	push   %ebx
  8007d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007d5:	53                   	push   %ebx
  8007d6:	e8 9c ff ff ff       	call   800777 <strlen>
  8007db:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007de:	ff 75 0c             	pushl  0xc(%ebp)
  8007e1:	01 d8                	add    %ebx,%eax
  8007e3:	50                   	push   %eax
  8007e4:	e8 c5 ff ff ff       	call   8007ae <strcpy>
	return dst;
}
  8007e9:	89 d8                	mov    %ebx,%eax
  8007eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ee:	c9                   	leave  
  8007ef:	c3                   	ret    

008007f0 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	56                   	push   %esi
  8007f4:	53                   	push   %ebx
  8007f5:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007fb:	89 f3                	mov    %esi,%ebx
  8007fd:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800800:	89 f2                	mov    %esi,%edx
  800802:	eb 0f                	jmp    800813 <strncpy+0x23>
		*dst++ = *src;
  800804:	83 c2 01             	add    $0x1,%edx
  800807:	0f b6 01             	movzbl (%ecx),%eax
  80080a:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80080d:	80 39 01             	cmpb   $0x1,(%ecx)
  800810:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800813:	39 da                	cmp    %ebx,%edx
  800815:	75 ed                	jne    800804 <strncpy+0x14>
	}
	return ret;
}
  800817:	89 f0                	mov    %esi,%eax
  800819:	5b                   	pop    %ebx
  80081a:	5e                   	pop    %esi
  80081b:	5d                   	pop    %ebp
  80081c:	c3                   	ret    

0080081d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80081d:	55                   	push   %ebp
  80081e:	89 e5                	mov    %esp,%ebp
  800820:	56                   	push   %esi
  800821:	53                   	push   %ebx
  800822:	8b 75 08             	mov    0x8(%ebp),%esi
  800825:	8b 55 0c             	mov    0xc(%ebp),%edx
  800828:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80082b:	89 f0                	mov    %esi,%eax
  80082d:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800831:	85 c9                	test   %ecx,%ecx
  800833:	75 0b                	jne    800840 <strlcpy+0x23>
  800835:	eb 17                	jmp    80084e <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800837:	83 c2 01             	add    $0x1,%edx
  80083a:	83 c0 01             	add    $0x1,%eax
  80083d:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800840:	39 d8                	cmp    %ebx,%eax
  800842:	74 07                	je     80084b <strlcpy+0x2e>
  800844:	0f b6 0a             	movzbl (%edx),%ecx
  800847:	84 c9                	test   %cl,%cl
  800849:	75 ec                	jne    800837 <strlcpy+0x1a>
		*dst = '\0';
  80084b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80084e:	29 f0                	sub    %esi,%eax
}
  800850:	5b                   	pop    %ebx
  800851:	5e                   	pop    %esi
  800852:	5d                   	pop    %ebp
  800853:	c3                   	ret    

00800854 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800854:	55                   	push   %ebp
  800855:	89 e5                	mov    %esp,%ebp
  800857:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80085a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80085d:	eb 06                	jmp    800865 <strcmp+0x11>
		p++, q++;
  80085f:	83 c1 01             	add    $0x1,%ecx
  800862:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800865:	0f b6 01             	movzbl (%ecx),%eax
  800868:	84 c0                	test   %al,%al
  80086a:	74 04                	je     800870 <strcmp+0x1c>
  80086c:	3a 02                	cmp    (%edx),%al
  80086e:	74 ef                	je     80085f <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800870:	0f b6 c0             	movzbl %al,%eax
  800873:	0f b6 12             	movzbl (%edx),%edx
  800876:	29 d0                	sub    %edx,%eax
}
  800878:	5d                   	pop    %ebp
  800879:	c3                   	ret    

0080087a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80087a:	55                   	push   %ebp
  80087b:	89 e5                	mov    %esp,%ebp
  80087d:	53                   	push   %ebx
  80087e:	8b 45 08             	mov    0x8(%ebp),%eax
  800881:	8b 55 0c             	mov    0xc(%ebp),%edx
  800884:	89 c3                	mov    %eax,%ebx
  800886:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800889:	eb 06                	jmp    800891 <strncmp+0x17>
		n--, p++, q++;
  80088b:	83 c0 01             	add    $0x1,%eax
  80088e:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800891:	39 d8                	cmp    %ebx,%eax
  800893:	74 16                	je     8008ab <strncmp+0x31>
  800895:	0f b6 08             	movzbl (%eax),%ecx
  800898:	84 c9                	test   %cl,%cl
  80089a:	74 04                	je     8008a0 <strncmp+0x26>
  80089c:	3a 0a                	cmp    (%edx),%cl
  80089e:	74 eb                	je     80088b <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a0:	0f b6 00             	movzbl (%eax),%eax
  8008a3:	0f b6 12             	movzbl (%edx),%edx
  8008a6:	29 d0                	sub    %edx,%eax
}
  8008a8:	5b                   	pop    %ebx
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    
		return 0;
  8008ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b0:	eb f6                	jmp    8008a8 <strncmp+0x2e>

008008b2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008bc:	0f b6 10             	movzbl (%eax),%edx
  8008bf:	84 d2                	test   %dl,%dl
  8008c1:	74 09                	je     8008cc <strchr+0x1a>
		if (*s == c)
  8008c3:	38 ca                	cmp    %cl,%dl
  8008c5:	74 0a                	je     8008d1 <strchr+0x1f>
	for (; *s; s++)
  8008c7:	83 c0 01             	add    $0x1,%eax
  8008ca:	eb f0                	jmp    8008bc <strchr+0xa>
			return (char *) s;
	return 0;
  8008cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008d1:	5d                   	pop    %ebp
  8008d2:	c3                   	ret    

008008d3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008d3:	55                   	push   %ebp
  8008d4:	89 e5                	mov    %esp,%ebp
  8008d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008dd:	eb 03                	jmp    8008e2 <strfind+0xf>
  8008df:	83 c0 01             	add    $0x1,%eax
  8008e2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008e5:	38 ca                	cmp    %cl,%dl
  8008e7:	74 04                	je     8008ed <strfind+0x1a>
  8008e9:	84 d2                	test   %dl,%dl
  8008eb:	75 f2                	jne    8008df <strfind+0xc>
			break;
	return (char *) s;
}
  8008ed:	5d                   	pop    %ebp
  8008ee:	c3                   	ret    

008008ef <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008ef:	55                   	push   %ebp
  8008f0:	89 e5                	mov    %esp,%ebp
  8008f2:	57                   	push   %edi
  8008f3:	56                   	push   %esi
  8008f4:	53                   	push   %ebx
  8008f5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008f8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008fb:	85 c9                	test   %ecx,%ecx
  8008fd:	74 13                	je     800912 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008ff:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800905:	75 05                	jne    80090c <memset+0x1d>
  800907:	f6 c1 03             	test   $0x3,%cl
  80090a:	74 0d                	je     800919 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80090c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80090f:	fc                   	cld    
  800910:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800912:	89 f8                	mov    %edi,%eax
  800914:	5b                   	pop    %ebx
  800915:	5e                   	pop    %esi
  800916:	5f                   	pop    %edi
  800917:	5d                   	pop    %ebp
  800918:	c3                   	ret    
		c &= 0xFF;
  800919:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80091d:	89 d3                	mov    %edx,%ebx
  80091f:	c1 e3 08             	shl    $0x8,%ebx
  800922:	89 d0                	mov    %edx,%eax
  800924:	c1 e0 18             	shl    $0x18,%eax
  800927:	89 d6                	mov    %edx,%esi
  800929:	c1 e6 10             	shl    $0x10,%esi
  80092c:	09 f0                	or     %esi,%eax
  80092e:	09 c2                	or     %eax,%edx
  800930:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800932:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800935:	89 d0                	mov    %edx,%eax
  800937:	fc                   	cld    
  800938:	f3 ab                	rep stos %eax,%es:(%edi)
  80093a:	eb d6                	jmp    800912 <memset+0x23>

0080093c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80093c:	55                   	push   %ebp
  80093d:	89 e5                	mov    %esp,%ebp
  80093f:	57                   	push   %edi
  800940:	56                   	push   %esi
  800941:	8b 45 08             	mov    0x8(%ebp),%eax
  800944:	8b 75 0c             	mov    0xc(%ebp),%esi
  800947:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80094a:	39 c6                	cmp    %eax,%esi
  80094c:	73 35                	jae    800983 <memmove+0x47>
  80094e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800951:	39 c2                	cmp    %eax,%edx
  800953:	76 2e                	jbe    800983 <memmove+0x47>
		s += n;
		d += n;
  800955:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800958:	89 d6                	mov    %edx,%esi
  80095a:	09 fe                	or     %edi,%esi
  80095c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800962:	74 0c                	je     800970 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800964:	83 ef 01             	sub    $0x1,%edi
  800967:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80096a:	fd                   	std    
  80096b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80096d:	fc                   	cld    
  80096e:	eb 21                	jmp    800991 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800970:	f6 c1 03             	test   $0x3,%cl
  800973:	75 ef                	jne    800964 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800975:	83 ef 04             	sub    $0x4,%edi
  800978:	8d 72 fc             	lea    -0x4(%edx),%esi
  80097b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80097e:	fd                   	std    
  80097f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800981:	eb ea                	jmp    80096d <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800983:	89 f2                	mov    %esi,%edx
  800985:	09 c2                	or     %eax,%edx
  800987:	f6 c2 03             	test   $0x3,%dl
  80098a:	74 09                	je     800995 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80098c:	89 c7                	mov    %eax,%edi
  80098e:	fc                   	cld    
  80098f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800991:	5e                   	pop    %esi
  800992:	5f                   	pop    %edi
  800993:	5d                   	pop    %ebp
  800994:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800995:	f6 c1 03             	test   $0x3,%cl
  800998:	75 f2                	jne    80098c <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80099a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80099d:	89 c7                	mov    %eax,%edi
  80099f:	fc                   	cld    
  8009a0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a2:	eb ed                	jmp    800991 <memmove+0x55>

008009a4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009a4:	55                   	push   %ebp
  8009a5:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009a7:	ff 75 10             	pushl  0x10(%ebp)
  8009aa:	ff 75 0c             	pushl  0xc(%ebp)
  8009ad:	ff 75 08             	pushl  0x8(%ebp)
  8009b0:	e8 87 ff ff ff       	call   80093c <memmove>
}
  8009b5:	c9                   	leave  
  8009b6:	c3                   	ret    

008009b7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	56                   	push   %esi
  8009bb:	53                   	push   %ebx
  8009bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c2:	89 c6                	mov    %eax,%esi
  8009c4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c7:	39 f0                	cmp    %esi,%eax
  8009c9:	74 1c                	je     8009e7 <memcmp+0x30>
		if (*s1 != *s2)
  8009cb:	0f b6 08             	movzbl (%eax),%ecx
  8009ce:	0f b6 1a             	movzbl (%edx),%ebx
  8009d1:	38 d9                	cmp    %bl,%cl
  8009d3:	75 08                	jne    8009dd <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009d5:	83 c0 01             	add    $0x1,%eax
  8009d8:	83 c2 01             	add    $0x1,%edx
  8009db:	eb ea                	jmp    8009c7 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8009dd:	0f b6 c1             	movzbl %cl,%eax
  8009e0:	0f b6 db             	movzbl %bl,%ebx
  8009e3:	29 d8                	sub    %ebx,%eax
  8009e5:	eb 05                	jmp    8009ec <memcmp+0x35>
	}

	return 0;
  8009e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ec:	5b                   	pop    %ebx
  8009ed:	5e                   	pop    %esi
  8009ee:	5d                   	pop    %ebp
  8009ef:	c3                   	ret    

008009f0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009f0:	55                   	push   %ebp
  8009f1:	89 e5                	mov    %esp,%ebp
  8009f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009f9:	89 c2                	mov    %eax,%edx
  8009fb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009fe:	39 d0                	cmp    %edx,%eax
  800a00:	73 09                	jae    800a0b <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a02:	38 08                	cmp    %cl,(%eax)
  800a04:	74 05                	je     800a0b <memfind+0x1b>
	for (; s < ends; s++)
  800a06:	83 c0 01             	add    $0x1,%eax
  800a09:	eb f3                	jmp    8009fe <memfind+0xe>
			break;
	return (void *) s;
}
  800a0b:	5d                   	pop    %ebp
  800a0c:	c3                   	ret    

00800a0d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a0d:	55                   	push   %ebp
  800a0e:	89 e5                	mov    %esp,%ebp
  800a10:	57                   	push   %edi
  800a11:	56                   	push   %esi
  800a12:	53                   	push   %ebx
  800a13:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a16:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a19:	eb 03                	jmp    800a1e <strtol+0x11>
		s++;
  800a1b:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a1e:	0f b6 01             	movzbl (%ecx),%eax
  800a21:	3c 20                	cmp    $0x20,%al
  800a23:	74 f6                	je     800a1b <strtol+0xe>
  800a25:	3c 09                	cmp    $0x9,%al
  800a27:	74 f2                	je     800a1b <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a29:	3c 2b                	cmp    $0x2b,%al
  800a2b:	74 2e                	je     800a5b <strtol+0x4e>
	int neg = 0;
  800a2d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a32:	3c 2d                	cmp    $0x2d,%al
  800a34:	74 2f                	je     800a65 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a36:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a3c:	75 05                	jne    800a43 <strtol+0x36>
  800a3e:	80 39 30             	cmpb   $0x30,(%ecx)
  800a41:	74 2c                	je     800a6f <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a43:	85 db                	test   %ebx,%ebx
  800a45:	75 0a                	jne    800a51 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a47:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a4c:	80 39 30             	cmpb   $0x30,(%ecx)
  800a4f:	74 28                	je     800a79 <strtol+0x6c>
		base = 10;
  800a51:	b8 00 00 00 00       	mov    $0x0,%eax
  800a56:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a59:	eb 50                	jmp    800aab <strtol+0x9e>
		s++;
  800a5b:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a5e:	bf 00 00 00 00       	mov    $0x0,%edi
  800a63:	eb d1                	jmp    800a36 <strtol+0x29>
		s++, neg = 1;
  800a65:	83 c1 01             	add    $0x1,%ecx
  800a68:	bf 01 00 00 00       	mov    $0x1,%edi
  800a6d:	eb c7                	jmp    800a36 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a6f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a73:	74 0e                	je     800a83 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a75:	85 db                	test   %ebx,%ebx
  800a77:	75 d8                	jne    800a51 <strtol+0x44>
		s++, base = 8;
  800a79:	83 c1 01             	add    $0x1,%ecx
  800a7c:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a81:	eb ce                	jmp    800a51 <strtol+0x44>
		s += 2, base = 16;
  800a83:	83 c1 02             	add    $0x2,%ecx
  800a86:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a8b:	eb c4                	jmp    800a51 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800a8d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a90:	89 f3                	mov    %esi,%ebx
  800a92:	80 fb 19             	cmp    $0x19,%bl
  800a95:	77 29                	ja     800ac0 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800a97:	0f be d2             	movsbl %dl,%edx
  800a9a:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a9d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aa0:	7d 30                	jge    800ad2 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800aa2:	83 c1 01             	add    $0x1,%ecx
  800aa5:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aa9:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800aab:	0f b6 11             	movzbl (%ecx),%edx
  800aae:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ab1:	89 f3                	mov    %esi,%ebx
  800ab3:	80 fb 09             	cmp    $0x9,%bl
  800ab6:	77 d5                	ja     800a8d <strtol+0x80>
			dig = *s - '0';
  800ab8:	0f be d2             	movsbl %dl,%edx
  800abb:	83 ea 30             	sub    $0x30,%edx
  800abe:	eb dd                	jmp    800a9d <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800ac0:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ac3:	89 f3                	mov    %esi,%ebx
  800ac5:	80 fb 19             	cmp    $0x19,%bl
  800ac8:	77 08                	ja     800ad2 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800aca:	0f be d2             	movsbl %dl,%edx
  800acd:	83 ea 37             	sub    $0x37,%edx
  800ad0:	eb cb                	jmp    800a9d <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ad2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ad6:	74 05                	je     800add <strtol+0xd0>
		*endptr = (char *) s;
  800ad8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800adb:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800add:	89 c2                	mov    %eax,%edx
  800adf:	f7 da                	neg    %edx
  800ae1:	85 ff                	test   %edi,%edi
  800ae3:	0f 45 c2             	cmovne %edx,%eax
}
  800ae6:	5b                   	pop    %ebx
  800ae7:	5e                   	pop    %esi
  800ae8:	5f                   	pop    %edi
  800ae9:	5d                   	pop    %ebp
  800aea:	c3                   	ret    

00800aeb <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aeb:	55                   	push   %ebp
  800aec:	89 e5                	mov    %esp,%ebp
  800aee:	57                   	push   %edi
  800aef:	56                   	push   %esi
  800af0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800af1:	b8 00 00 00 00       	mov    $0x0,%eax
  800af6:	8b 55 08             	mov    0x8(%ebp),%edx
  800af9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800afc:	89 c3                	mov    %eax,%ebx
  800afe:	89 c7                	mov    %eax,%edi
  800b00:	89 c6                	mov    %eax,%esi
  800b02:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b04:	5b                   	pop    %ebx
  800b05:	5e                   	pop    %esi
  800b06:	5f                   	pop    %edi
  800b07:	5d                   	pop    %ebp
  800b08:	c3                   	ret    

00800b09 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b09:	55                   	push   %ebp
  800b0a:	89 e5                	mov    %esp,%ebp
  800b0c:	57                   	push   %edi
  800b0d:	56                   	push   %esi
  800b0e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b0f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b14:	b8 01 00 00 00       	mov    $0x1,%eax
  800b19:	89 d1                	mov    %edx,%ecx
  800b1b:	89 d3                	mov    %edx,%ebx
  800b1d:	89 d7                	mov    %edx,%edi
  800b1f:	89 d6                	mov    %edx,%esi
  800b21:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b23:	5b                   	pop    %ebx
  800b24:	5e                   	pop    %esi
  800b25:	5f                   	pop    %edi
  800b26:	5d                   	pop    %ebp
  800b27:	c3                   	ret    

00800b28 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b28:	55                   	push   %ebp
  800b29:	89 e5                	mov    %esp,%ebp
  800b2b:	57                   	push   %edi
  800b2c:	56                   	push   %esi
  800b2d:	53                   	push   %ebx
  800b2e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b31:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b36:	8b 55 08             	mov    0x8(%ebp),%edx
  800b39:	b8 03 00 00 00       	mov    $0x3,%eax
  800b3e:	89 cb                	mov    %ecx,%ebx
  800b40:	89 cf                	mov    %ecx,%edi
  800b42:	89 ce                	mov    %ecx,%esi
  800b44:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b46:	85 c0                	test   %eax,%eax
  800b48:	7f 08                	jg     800b52 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b4d:	5b                   	pop    %ebx
  800b4e:	5e                   	pop    %esi
  800b4f:	5f                   	pop    %edi
  800b50:	5d                   	pop    %ebp
  800b51:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b52:	83 ec 0c             	sub    $0xc,%esp
  800b55:	50                   	push   %eax
  800b56:	6a 03                	push   $0x3
  800b58:	68 9f 21 80 00       	push   $0x80219f
  800b5d:	6a 23                	push   $0x23
  800b5f:	68 bc 21 80 00       	push   $0x8021bc
  800b64:	e8 ea 0e 00 00       	call   801a53 <_panic>

00800b69 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b69:	55                   	push   %ebp
  800b6a:	89 e5                	mov    %esp,%ebp
  800b6c:	57                   	push   %edi
  800b6d:	56                   	push   %esi
  800b6e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b6f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b74:	b8 02 00 00 00       	mov    $0x2,%eax
  800b79:	89 d1                	mov    %edx,%ecx
  800b7b:	89 d3                	mov    %edx,%ebx
  800b7d:	89 d7                	mov    %edx,%edi
  800b7f:	89 d6                	mov    %edx,%esi
  800b81:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b83:	5b                   	pop    %ebx
  800b84:	5e                   	pop    %esi
  800b85:	5f                   	pop    %edi
  800b86:	5d                   	pop    %ebp
  800b87:	c3                   	ret    

00800b88 <sys_yield>:

void
sys_yield(void)
{
  800b88:	55                   	push   %ebp
  800b89:	89 e5                	mov    %esp,%ebp
  800b8b:	57                   	push   %edi
  800b8c:	56                   	push   %esi
  800b8d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b8e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b93:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b98:	89 d1                	mov    %edx,%ecx
  800b9a:	89 d3                	mov    %edx,%ebx
  800b9c:	89 d7                	mov    %edx,%edi
  800b9e:	89 d6                	mov    %edx,%esi
  800ba0:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ba2:	5b                   	pop    %ebx
  800ba3:	5e                   	pop    %esi
  800ba4:	5f                   	pop    %edi
  800ba5:	5d                   	pop    %ebp
  800ba6:	c3                   	ret    

00800ba7 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
  800baa:	57                   	push   %edi
  800bab:	56                   	push   %esi
  800bac:	53                   	push   %ebx
  800bad:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bb0:	be 00 00 00 00       	mov    $0x0,%esi
  800bb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbb:	b8 04 00 00 00       	mov    $0x4,%eax
  800bc0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bc3:	89 f7                	mov    %esi,%edi
  800bc5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bc7:	85 c0                	test   %eax,%eax
  800bc9:	7f 08                	jg     800bd3 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bcb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bce:	5b                   	pop    %ebx
  800bcf:	5e                   	pop    %esi
  800bd0:	5f                   	pop    %edi
  800bd1:	5d                   	pop    %ebp
  800bd2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd3:	83 ec 0c             	sub    $0xc,%esp
  800bd6:	50                   	push   %eax
  800bd7:	6a 04                	push   $0x4
  800bd9:	68 9f 21 80 00       	push   $0x80219f
  800bde:	6a 23                	push   $0x23
  800be0:	68 bc 21 80 00       	push   $0x8021bc
  800be5:	e8 69 0e 00 00       	call   801a53 <_panic>

00800bea <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bea:	55                   	push   %ebp
  800beb:	89 e5                	mov    %esp,%ebp
  800bed:	57                   	push   %edi
  800bee:	56                   	push   %esi
  800bef:	53                   	push   %ebx
  800bf0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bf3:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf9:	b8 05 00 00 00       	mov    $0x5,%eax
  800bfe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c01:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c04:	8b 75 18             	mov    0x18(%ebp),%esi
  800c07:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c09:	85 c0                	test   %eax,%eax
  800c0b:	7f 08                	jg     800c15 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c10:	5b                   	pop    %ebx
  800c11:	5e                   	pop    %esi
  800c12:	5f                   	pop    %edi
  800c13:	5d                   	pop    %ebp
  800c14:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c15:	83 ec 0c             	sub    $0xc,%esp
  800c18:	50                   	push   %eax
  800c19:	6a 05                	push   $0x5
  800c1b:	68 9f 21 80 00       	push   $0x80219f
  800c20:	6a 23                	push   $0x23
  800c22:	68 bc 21 80 00       	push   $0x8021bc
  800c27:	e8 27 0e 00 00       	call   801a53 <_panic>

00800c2c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
  800c2f:	57                   	push   %edi
  800c30:	56                   	push   %esi
  800c31:	53                   	push   %ebx
  800c32:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c35:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c40:	b8 06 00 00 00       	mov    $0x6,%eax
  800c45:	89 df                	mov    %ebx,%edi
  800c47:	89 de                	mov    %ebx,%esi
  800c49:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c4b:	85 c0                	test   %eax,%eax
  800c4d:	7f 08                	jg     800c57 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c52:	5b                   	pop    %ebx
  800c53:	5e                   	pop    %esi
  800c54:	5f                   	pop    %edi
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c57:	83 ec 0c             	sub    $0xc,%esp
  800c5a:	50                   	push   %eax
  800c5b:	6a 06                	push   $0x6
  800c5d:	68 9f 21 80 00       	push   $0x80219f
  800c62:	6a 23                	push   $0x23
  800c64:	68 bc 21 80 00       	push   $0x8021bc
  800c69:	e8 e5 0d 00 00       	call   801a53 <_panic>

00800c6e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c6e:	55                   	push   %ebp
  800c6f:	89 e5                	mov    %esp,%ebp
  800c71:	57                   	push   %edi
  800c72:	56                   	push   %esi
  800c73:	53                   	push   %ebx
  800c74:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c77:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c82:	b8 08 00 00 00       	mov    $0x8,%eax
  800c87:	89 df                	mov    %ebx,%edi
  800c89:	89 de                	mov    %ebx,%esi
  800c8b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c8d:	85 c0                	test   %eax,%eax
  800c8f:	7f 08                	jg     800c99 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c94:	5b                   	pop    %ebx
  800c95:	5e                   	pop    %esi
  800c96:	5f                   	pop    %edi
  800c97:	5d                   	pop    %ebp
  800c98:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c99:	83 ec 0c             	sub    $0xc,%esp
  800c9c:	50                   	push   %eax
  800c9d:	6a 08                	push   $0x8
  800c9f:	68 9f 21 80 00       	push   $0x80219f
  800ca4:	6a 23                	push   $0x23
  800ca6:	68 bc 21 80 00       	push   $0x8021bc
  800cab:	e8 a3 0d 00 00       	call   801a53 <_panic>

00800cb0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cb0:	55                   	push   %ebp
  800cb1:	89 e5                	mov    %esp,%ebp
  800cb3:	57                   	push   %edi
  800cb4:	56                   	push   %esi
  800cb5:	53                   	push   %ebx
  800cb6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cb9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc4:	b8 09 00 00 00       	mov    $0x9,%eax
  800cc9:	89 df                	mov    %ebx,%edi
  800ccb:	89 de                	mov    %ebx,%esi
  800ccd:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ccf:	85 c0                	test   %eax,%eax
  800cd1:	7f 08                	jg     800cdb <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cd3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd6:	5b                   	pop    %ebx
  800cd7:	5e                   	pop    %esi
  800cd8:	5f                   	pop    %edi
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdb:	83 ec 0c             	sub    $0xc,%esp
  800cde:	50                   	push   %eax
  800cdf:	6a 09                	push   $0x9
  800ce1:	68 9f 21 80 00       	push   $0x80219f
  800ce6:	6a 23                	push   $0x23
  800ce8:	68 bc 21 80 00       	push   $0x8021bc
  800ced:	e8 61 0d 00 00       	call   801a53 <_panic>

00800cf2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cf2:	55                   	push   %ebp
  800cf3:	89 e5                	mov    %esp,%ebp
  800cf5:	57                   	push   %edi
  800cf6:	56                   	push   %esi
  800cf7:	53                   	push   %ebx
  800cf8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cfb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d00:	8b 55 08             	mov    0x8(%ebp),%edx
  800d03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d06:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d0b:	89 df                	mov    %ebx,%edi
  800d0d:	89 de                	mov    %ebx,%esi
  800d0f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d11:	85 c0                	test   %eax,%eax
  800d13:	7f 08                	jg     800d1d <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d18:	5b                   	pop    %ebx
  800d19:	5e                   	pop    %esi
  800d1a:	5f                   	pop    %edi
  800d1b:	5d                   	pop    %ebp
  800d1c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1d:	83 ec 0c             	sub    $0xc,%esp
  800d20:	50                   	push   %eax
  800d21:	6a 0a                	push   $0xa
  800d23:	68 9f 21 80 00       	push   $0x80219f
  800d28:	6a 23                	push   $0x23
  800d2a:	68 bc 21 80 00       	push   $0x8021bc
  800d2f:	e8 1f 0d 00 00       	call   801a53 <_panic>

00800d34 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d34:	55                   	push   %ebp
  800d35:	89 e5                	mov    %esp,%ebp
  800d37:	57                   	push   %edi
  800d38:	56                   	push   %esi
  800d39:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d40:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d45:	be 00 00 00 00       	mov    $0x0,%esi
  800d4a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d4d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d50:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d52:	5b                   	pop    %ebx
  800d53:	5e                   	pop    %esi
  800d54:	5f                   	pop    %edi
  800d55:	5d                   	pop    %ebp
  800d56:	c3                   	ret    

00800d57 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d57:	55                   	push   %ebp
  800d58:	89 e5                	mov    %esp,%ebp
  800d5a:	57                   	push   %edi
  800d5b:	56                   	push   %esi
  800d5c:	53                   	push   %ebx
  800d5d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d60:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d65:	8b 55 08             	mov    0x8(%ebp),%edx
  800d68:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d6d:	89 cb                	mov    %ecx,%ebx
  800d6f:	89 cf                	mov    %ecx,%edi
  800d71:	89 ce                	mov    %ecx,%esi
  800d73:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d75:	85 c0                	test   %eax,%eax
  800d77:	7f 08                	jg     800d81 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d79:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7c:	5b                   	pop    %ebx
  800d7d:	5e                   	pop    %esi
  800d7e:	5f                   	pop    %edi
  800d7f:	5d                   	pop    %ebp
  800d80:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d81:	83 ec 0c             	sub    $0xc,%esp
  800d84:	50                   	push   %eax
  800d85:	6a 0d                	push   $0xd
  800d87:	68 9f 21 80 00       	push   $0x80219f
  800d8c:	6a 23                	push   $0x23
  800d8e:	68 bc 21 80 00       	push   $0x8021bc
  800d93:	e8 bb 0c 00 00       	call   801a53 <_panic>

00800d98 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d98:	55                   	push   %ebp
  800d99:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9e:	05 00 00 00 30       	add    $0x30000000,%eax
  800da3:	c1 e8 0c             	shr    $0xc,%eax
}
  800da6:	5d                   	pop    %ebp
  800da7:	c3                   	ret    

00800da8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800da8:	55                   	push   %ebp
  800da9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dab:	8b 45 08             	mov    0x8(%ebp),%eax
  800dae:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800db3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800db8:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800dbd:	5d                   	pop    %ebp
  800dbe:	c3                   	ret    

00800dbf <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800dbf:	55                   	push   %ebp
  800dc0:	89 e5                	mov    %esp,%ebp
  800dc2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dc5:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800dca:	89 c2                	mov    %eax,%edx
  800dcc:	c1 ea 16             	shr    $0x16,%edx
  800dcf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dd6:	f6 c2 01             	test   $0x1,%dl
  800dd9:	74 2a                	je     800e05 <fd_alloc+0x46>
  800ddb:	89 c2                	mov    %eax,%edx
  800ddd:	c1 ea 0c             	shr    $0xc,%edx
  800de0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800de7:	f6 c2 01             	test   $0x1,%dl
  800dea:	74 19                	je     800e05 <fd_alloc+0x46>
  800dec:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800df1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800df6:	75 d2                	jne    800dca <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800df8:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800dfe:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800e03:	eb 07                	jmp    800e0c <fd_alloc+0x4d>
			*fd_store = fd;
  800e05:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e07:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e0c:	5d                   	pop    %ebp
  800e0d:	c3                   	ret    

00800e0e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e0e:	55                   	push   %ebp
  800e0f:	89 e5                	mov    %esp,%ebp
  800e11:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e14:	83 f8 1f             	cmp    $0x1f,%eax
  800e17:	77 36                	ja     800e4f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e19:	c1 e0 0c             	shl    $0xc,%eax
  800e1c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e21:	89 c2                	mov    %eax,%edx
  800e23:	c1 ea 16             	shr    $0x16,%edx
  800e26:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e2d:	f6 c2 01             	test   $0x1,%dl
  800e30:	74 24                	je     800e56 <fd_lookup+0x48>
  800e32:	89 c2                	mov    %eax,%edx
  800e34:	c1 ea 0c             	shr    $0xc,%edx
  800e37:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e3e:	f6 c2 01             	test   $0x1,%dl
  800e41:	74 1a                	je     800e5d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e43:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e46:	89 02                	mov    %eax,(%edx)
	return 0;
  800e48:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e4d:	5d                   	pop    %ebp
  800e4e:	c3                   	ret    
		return -E_INVAL;
  800e4f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e54:	eb f7                	jmp    800e4d <fd_lookup+0x3f>
		return -E_INVAL;
  800e56:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e5b:	eb f0                	jmp    800e4d <fd_lookup+0x3f>
  800e5d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e62:	eb e9                	jmp    800e4d <fd_lookup+0x3f>

00800e64 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e64:	55                   	push   %ebp
  800e65:	89 e5                	mov    %esp,%ebp
  800e67:	83 ec 08             	sub    $0x8,%esp
  800e6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e6d:	ba 48 22 80 00       	mov    $0x802248,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e72:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800e77:	39 08                	cmp    %ecx,(%eax)
  800e79:	74 33                	je     800eae <dev_lookup+0x4a>
  800e7b:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800e7e:	8b 02                	mov    (%edx),%eax
  800e80:	85 c0                	test   %eax,%eax
  800e82:	75 f3                	jne    800e77 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e84:	a1 04 40 80 00       	mov    0x804004,%eax
  800e89:	8b 40 48             	mov    0x48(%eax),%eax
  800e8c:	83 ec 04             	sub    $0x4,%esp
  800e8f:	51                   	push   %ecx
  800e90:	50                   	push   %eax
  800e91:	68 cc 21 80 00       	push   $0x8021cc
  800e96:	e8 f4 f2 ff ff       	call   80018f <cprintf>
	*dev = 0;
  800e9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e9e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800ea4:	83 c4 10             	add    $0x10,%esp
  800ea7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800eac:	c9                   	leave  
  800ead:	c3                   	ret    
			*dev = devtab[i];
  800eae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb1:	89 01                	mov    %eax,(%ecx)
			return 0;
  800eb3:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb8:	eb f2                	jmp    800eac <dev_lookup+0x48>

00800eba <fd_close>:
{
  800eba:	55                   	push   %ebp
  800ebb:	89 e5                	mov    %esp,%ebp
  800ebd:	57                   	push   %edi
  800ebe:	56                   	push   %esi
  800ebf:	53                   	push   %ebx
  800ec0:	83 ec 1c             	sub    $0x1c,%esp
  800ec3:	8b 75 08             	mov    0x8(%ebp),%esi
  800ec6:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ec9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ecc:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ecd:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800ed3:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ed6:	50                   	push   %eax
  800ed7:	e8 32 ff ff ff       	call   800e0e <fd_lookup>
  800edc:	89 c3                	mov    %eax,%ebx
  800ede:	83 c4 08             	add    $0x8,%esp
  800ee1:	85 c0                	test   %eax,%eax
  800ee3:	78 05                	js     800eea <fd_close+0x30>
	    || fd != fd2)
  800ee5:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800ee8:	74 16                	je     800f00 <fd_close+0x46>
		return (must_exist ? r : 0);
  800eea:	89 f8                	mov    %edi,%eax
  800eec:	84 c0                	test   %al,%al
  800eee:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef3:	0f 44 d8             	cmove  %eax,%ebx
}
  800ef6:	89 d8                	mov    %ebx,%eax
  800ef8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800efb:	5b                   	pop    %ebx
  800efc:	5e                   	pop    %esi
  800efd:	5f                   	pop    %edi
  800efe:	5d                   	pop    %ebp
  800eff:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f00:	83 ec 08             	sub    $0x8,%esp
  800f03:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800f06:	50                   	push   %eax
  800f07:	ff 36                	pushl  (%esi)
  800f09:	e8 56 ff ff ff       	call   800e64 <dev_lookup>
  800f0e:	89 c3                	mov    %eax,%ebx
  800f10:	83 c4 10             	add    $0x10,%esp
  800f13:	85 c0                	test   %eax,%eax
  800f15:	78 15                	js     800f2c <fd_close+0x72>
		if (dev->dev_close)
  800f17:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f1a:	8b 40 10             	mov    0x10(%eax),%eax
  800f1d:	85 c0                	test   %eax,%eax
  800f1f:	74 1b                	je     800f3c <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  800f21:	83 ec 0c             	sub    $0xc,%esp
  800f24:	56                   	push   %esi
  800f25:	ff d0                	call   *%eax
  800f27:	89 c3                	mov    %eax,%ebx
  800f29:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800f2c:	83 ec 08             	sub    $0x8,%esp
  800f2f:	56                   	push   %esi
  800f30:	6a 00                	push   $0x0
  800f32:	e8 f5 fc ff ff       	call   800c2c <sys_page_unmap>
	return r;
  800f37:	83 c4 10             	add    $0x10,%esp
  800f3a:	eb ba                	jmp    800ef6 <fd_close+0x3c>
			r = 0;
  800f3c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f41:	eb e9                	jmp    800f2c <fd_close+0x72>

00800f43 <close>:

int
close(int fdnum)
{
  800f43:	55                   	push   %ebp
  800f44:	89 e5                	mov    %esp,%ebp
  800f46:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f49:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f4c:	50                   	push   %eax
  800f4d:	ff 75 08             	pushl  0x8(%ebp)
  800f50:	e8 b9 fe ff ff       	call   800e0e <fd_lookup>
  800f55:	83 c4 08             	add    $0x8,%esp
  800f58:	85 c0                	test   %eax,%eax
  800f5a:	78 10                	js     800f6c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f5c:	83 ec 08             	sub    $0x8,%esp
  800f5f:	6a 01                	push   $0x1
  800f61:	ff 75 f4             	pushl  -0xc(%ebp)
  800f64:	e8 51 ff ff ff       	call   800eba <fd_close>
  800f69:	83 c4 10             	add    $0x10,%esp
}
  800f6c:	c9                   	leave  
  800f6d:	c3                   	ret    

00800f6e <close_all>:

void
close_all(void)
{
  800f6e:	55                   	push   %ebp
  800f6f:	89 e5                	mov    %esp,%ebp
  800f71:	53                   	push   %ebx
  800f72:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f75:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f7a:	83 ec 0c             	sub    $0xc,%esp
  800f7d:	53                   	push   %ebx
  800f7e:	e8 c0 ff ff ff       	call   800f43 <close>
	for (i = 0; i < MAXFD; i++)
  800f83:	83 c3 01             	add    $0x1,%ebx
  800f86:	83 c4 10             	add    $0x10,%esp
  800f89:	83 fb 20             	cmp    $0x20,%ebx
  800f8c:	75 ec                	jne    800f7a <close_all+0xc>
}
  800f8e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f91:	c9                   	leave  
  800f92:	c3                   	ret    

00800f93 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f93:	55                   	push   %ebp
  800f94:	89 e5                	mov    %esp,%ebp
  800f96:	57                   	push   %edi
  800f97:	56                   	push   %esi
  800f98:	53                   	push   %ebx
  800f99:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f9c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f9f:	50                   	push   %eax
  800fa0:	ff 75 08             	pushl  0x8(%ebp)
  800fa3:	e8 66 fe ff ff       	call   800e0e <fd_lookup>
  800fa8:	89 c3                	mov    %eax,%ebx
  800faa:	83 c4 08             	add    $0x8,%esp
  800fad:	85 c0                	test   %eax,%eax
  800faf:	0f 88 81 00 00 00    	js     801036 <dup+0xa3>
		return r;
	close(newfdnum);
  800fb5:	83 ec 0c             	sub    $0xc,%esp
  800fb8:	ff 75 0c             	pushl  0xc(%ebp)
  800fbb:	e8 83 ff ff ff       	call   800f43 <close>

	newfd = INDEX2FD(newfdnum);
  800fc0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fc3:	c1 e6 0c             	shl    $0xc,%esi
  800fc6:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800fcc:	83 c4 04             	add    $0x4,%esp
  800fcf:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fd2:	e8 d1 fd ff ff       	call   800da8 <fd2data>
  800fd7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800fd9:	89 34 24             	mov    %esi,(%esp)
  800fdc:	e8 c7 fd ff ff       	call   800da8 <fd2data>
  800fe1:	83 c4 10             	add    $0x10,%esp
  800fe4:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fe6:	89 d8                	mov    %ebx,%eax
  800fe8:	c1 e8 16             	shr    $0x16,%eax
  800feb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ff2:	a8 01                	test   $0x1,%al
  800ff4:	74 11                	je     801007 <dup+0x74>
  800ff6:	89 d8                	mov    %ebx,%eax
  800ff8:	c1 e8 0c             	shr    $0xc,%eax
  800ffb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801002:	f6 c2 01             	test   $0x1,%dl
  801005:	75 39                	jne    801040 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801007:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80100a:	89 d0                	mov    %edx,%eax
  80100c:	c1 e8 0c             	shr    $0xc,%eax
  80100f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801016:	83 ec 0c             	sub    $0xc,%esp
  801019:	25 07 0e 00 00       	and    $0xe07,%eax
  80101e:	50                   	push   %eax
  80101f:	56                   	push   %esi
  801020:	6a 00                	push   $0x0
  801022:	52                   	push   %edx
  801023:	6a 00                	push   $0x0
  801025:	e8 c0 fb ff ff       	call   800bea <sys_page_map>
  80102a:	89 c3                	mov    %eax,%ebx
  80102c:	83 c4 20             	add    $0x20,%esp
  80102f:	85 c0                	test   %eax,%eax
  801031:	78 31                	js     801064 <dup+0xd1>
		goto err;

	return newfdnum;
  801033:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801036:	89 d8                	mov    %ebx,%eax
  801038:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80103b:	5b                   	pop    %ebx
  80103c:	5e                   	pop    %esi
  80103d:	5f                   	pop    %edi
  80103e:	5d                   	pop    %ebp
  80103f:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801040:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801047:	83 ec 0c             	sub    $0xc,%esp
  80104a:	25 07 0e 00 00       	and    $0xe07,%eax
  80104f:	50                   	push   %eax
  801050:	57                   	push   %edi
  801051:	6a 00                	push   $0x0
  801053:	53                   	push   %ebx
  801054:	6a 00                	push   $0x0
  801056:	e8 8f fb ff ff       	call   800bea <sys_page_map>
  80105b:	89 c3                	mov    %eax,%ebx
  80105d:	83 c4 20             	add    $0x20,%esp
  801060:	85 c0                	test   %eax,%eax
  801062:	79 a3                	jns    801007 <dup+0x74>
	sys_page_unmap(0, newfd);
  801064:	83 ec 08             	sub    $0x8,%esp
  801067:	56                   	push   %esi
  801068:	6a 00                	push   $0x0
  80106a:	e8 bd fb ff ff       	call   800c2c <sys_page_unmap>
	sys_page_unmap(0, nva);
  80106f:	83 c4 08             	add    $0x8,%esp
  801072:	57                   	push   %edi
  801073:	6a 00                	push   $0x0
  801075:	e8 b2 fb ff ff       	call   800c2c <sys_page_unmap>
	return r;
  80107a:	83 c4 10             	add    $0x10,%esp
  80107d:	eb b7                	jmp    801036 <dup+0xa3>

0080107f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80107f:	55                   	push   %ebp
  801080:	89 e5                	mov    %esp,%ebp
  801082:	53                   	push   %ebx
  801083:	83 ec 14             	sub    $0x14,%esp
  801086:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801089:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80108c:	50                   	push   %eax
  80108d:	53                   	push   %ebx
  80108e:	e8 7b fd ff ff       	call   800e0e <fd_lookup>
  801093:	83 c4 08             	add    $0x8,%esp
  801096:	85 c0                	test   %eax,%eax
  801098:	78 3f                	js     8010d9 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80109a:	83 ec 08             	sub    $0x8,%esp
  80109d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010a0:	50                   	push   %eax
  8010a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010a4:	ff 30                	pushl  (%eax)
  8010a6:	e8 b9 fd ff ff       	call   800e64 <dev_lookup>
  8010ab:	83 c4 10             	add    $0x10,%esp
  8010ae:	85 c0                	test   %eax,%eax
  8010b0:	78 27                	js     8010d9 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010b2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010b5:	8b 42 08             	mov    0x8(%edx),%eax
  8010b8:	83 e0 03             	and    $0x3,%eax
  8010bb:	83 f8 01             	cmp    $0x1,%eax
  8010be:	74 1e                	je     8010de <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8010c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010c3:	8b 40 08             	mov    0x8(%eax),%eax
  8010c6:	85 c0                	test   %eax,%eax
  8010c8:	74 35                	je     8010ff <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010ca:	83 ec 04             	sub    $0x4,%esp
  8010cd:	ff 75 10             	pushl  0x10(%ebp)
  8010d0:	ff 75 0c             	pushl  0xc(%ebp)
  8010d3:	52                   	push   %edx
  8010d4:	ff d0                	call   *%eax
  8010d6:	83 c4 10             	add    $0x10,%esp
}
  8010d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010dc:	c9                   	leave  
  8010dd:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010de:	a1 04 40 80 00       	mov    0x804004,%eax
  8010e3:	8b 40 48             	mov    0x48(%eax),%eax
  8010e6:	83 ec 04             	sub    $0x4,%esp
  8010e9:	53                   	push   %ebx
  8010ea:	50                   	push   %eax
  8010eb:	68 0d 22 80 00       	push   $0x80220d
  8010f0:	e8 9a f0 ff ff       	call   80018f <cprintf>
		return -E_INVAL;
  8010f5:	83 c4 10             	add    $0x10,%esp
  8010f8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010fd:	eb da                	jmp    8010d9 <read+0x5a>
		return -E_NOT_SUPP;
  8010ff:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801104:	eb d3                	jmp    8010d9 <read+0x5a>

00801106 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801106:	55                   	push   %ebp
  801107:	89 e5                	mov    %esp,%ebp
  801109:	57                   	push   %edi
  80110a:	56                   	push   %esi
  80110b:	53                   	push   %ebx
  80110c:	83 ec 0c             	sub    $0xc,%esp
  80110f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801112:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801115:	bb 00 00 00 00       	mov    $0x0,%ebx
  80111a:	39 f3                	cmp    %esi,%ebx
  80111c:	73 25                	jae    801143 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80111e:	83 ec 04             	sub    $0x4,%esp
  801121:	89 f0                	mov    %esi,%eax
  801123:	29 d8                	sub    %ebx,%eax
  801125:	50                   	push   %eax
  801126:	89 d8                	mov    %ebx,%eax
  801128:	03 45 0c             	add    0xc(%ebp),%eax
  80112b:	50                   	push   %eax
  80112c:	57                   	push   %edi
  80112d:	e8 4d ff ff ff       	call   80107f <read>
		if (m < 0)
  801132:	83 c4 10             	add    $0x10,%esp
  801135:	85 c0                	test   %eax,%eax
  801137:	78 08                	js     801141 <readn+0x3b>
			return m;
		if (m == 0)
  801139:	85 c0                	test   %eax,%eax
  80113b:	74 06                	je     801143 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  80113d:	01 c3                	add    %eax,%ebx
  80113f:	eb d9                	jmp    80111a <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801141:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801143:	89 d8                	mov    %ebx,%eax
  801145:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801148:	5b                   	pop    %ebx
  801149:	5e                   	pop    %esi
  80114a:	5f                   	pop    %edi
  80114b:	5d                   	pop    %ebp
  80114c:	c3                   	ret    

0080114d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80114d:	55                   	push   %ebp
  80114e:	89 e5                	mov    %esp,%ebp
  801150:	53                   	push   %ebx
  801151:	83 ec 14             	sub    $0x14,%esp
  801154:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801157:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80115a:	50                   	push   %eax
  80115b:	53                   	push   %ebx
  80115c:	e8 ad fc ff ff       	call   800e0e <fd_lookup>
  801161:	83 c4 08             	add    $0x8,%esp
  801164:	85 c0                	test   %eax,%eax
  801166:	78 3a                	js     8011a2 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801168:	83 ec 08             	sub    $0x8,%esp
  80116b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80116e:	50                   	push   %eax
  80116f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801172:	ff 30                	pushl  (%eax)
  801174:	e8 eb fc ff ff       	call   800e64 <dev_lookup>
  801179:	83 c4 10             	add    $0x10,%esp
  80117c:	85 c0                	test   %eax,%eax
  80117e:	78 22                	js     8011a2 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801180:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801183:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801187:	74 1e                	je     8011a7 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801189:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80118c:	8b 52 0c             	mov    0xc(%edx),%edx
  80118f:	85 d2                	test   %edx,%edx
  801191:	74 35                	je     8011c8 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801193:	83 ec 04             	sub    $0x4,%esp
  801196:	ff 75 10             	pushl  0x10(%ebp)
  801199:	ff 75 0c             	pushl  0xc(%ebp)
  80119c:	50                   	push   %eax
  80119d:	ff d2                	call   *%edx
  80119f:	83 c4 10             	add    $0x10,%esp
}
  8011a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011a5:	c9                   	leave  
  8011a6:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011a7:	a1 04 40 80 00       	mov    0x804004,%eax
  8011ac:	8b 40 48             	mov    0x48(%eax),%eax
  8011af:	83 ec 04             	sub    $0x4,%esp
  8011b2:	53                   	push   %ebx
  8011b3:	50                   	push   %eax
  8011b4:	68 29 22 80 00       	push   $0x802229
  8011b9:	e8 d1 ef ff ff       	call   80018f <cprintf>
		return -E_INVAL;
  8011be:	83 c4 10             	add    $0x10,%esp
  8011c1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011c6:	eb da                	jmp    8011a2 <write+0x55>
		return -E_NOT_SUPP;
  8011c8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011cd:	eb d3                	jmp    8011a2 <write+0x55>

008011cf <seek>:

int
seek(int fdnum, off_t offset)
{
  8011cf:	55                   	push   %ebp
  8011d0:	89 e5                	mov    %esp,%ebp
  8011d2:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011d5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011d8:	50                   	push   %eax
  8011d9:	ff 75 08             	pushl  0x8(%ebp)
  8011dc:	e8 2d fc ff ff       	call   800e0e <fd_lookup>
  8011e1:	83 c4 08             	add    $0x8,%esp
  8011e4:	85 c0                	test   %eax,%eax
  8011e6:	78 0e                	js     8011f6 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011ee:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011f6:	c9                   	leave  
  8011f7:	c3                   	ret    

008011f8 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011f8:	55                   	push   %ebp
  8011f9:	89 e5                	mov    %esp,%ebp
  8011fb:	53                   	push   %ebx
  8011fc:	83 ec 14             	sub    $0x14,%esp
  8011ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801202:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801205:	50                   	push   %eax
  801206:	53                   	push   %ebx
  801207:	e8 02 fc ff ff       	call   800e0e <fd_lookup>
  80120c:	83 c4 08             	add    $0x8,%esp
  80120f:	85 c0                	test   %eax,%eax
  801211:	78 37                	js     80124a <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801213:	83 ec 08             	sub    $0x8,%esp
  801216:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801219:	50                   	push   %eax
  80121a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80121d:	ff 30                	pushl  (%eax)
  80121f:	e8 40 fc ff ff       	call   800e64 <dev_lookup>
  801224:	83 c4 10             	add    $0x10,%esp
  801227:	85 c0                	test   %eax,%eax
  801229:	78 1f                	js     80124a <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80122b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80122e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801232:	74 1b                	je     80124f <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801234:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801237:	8b 52 18             	mov    0x18(%edx),%edx
  80123a:	85 d2                	test   %edx,%edx
  80123c:	74 32                	je     801270 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80123e:	83 ec 08             	sub    $0x8,%esp
  801241:	ff 75 0c             	pushl  0xc(%ebp)
  801244:	50                   	push   %eax
  801245:	ff d2                	call   *%edx
  801247:	83 c4 10             	add    $0x10,%esp
}
  80124a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80124d:	c9                   	leave  
  80124e:	c3                   	ret    
			thisenv->env_id, fdnum);
  80124f:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801254:	8b 40 48             	mov    0x48(%eax),%eax
  801257:	83 ec 04             	sub    $0x4,%esp
  80125a:	53                   	push   %ebx
  80125b:	50                   	push   %eax
  80125c:	68 ec 21 80 00       	push   $0x8021ec
  801261:	e8 29 ef ff ff       	call   80018f <cprintf>
		return -E_INVAL;
  801266:	83 c4 10             	add    $0x10,%esp
  801269:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80126e:	eb da                	jmp    80124a <ftruncate+0x52>
		return -E_NOT_SUPP;
  801270:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801275:	eb d3                	jmp    80124a <ftruncate+0x52>

00801277 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801277:	55                   	push   %ebp
  801278:	89 e5                	mov    %esp,%ebp
  80127a:	53                   	push   %ebx
  80127b:	83 ec 14             	sub    $0x14,%esp
  80127e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801281:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801284:	50                   	push   %eax
  801285:	ff 75 08             	pushl  0x8(%ebp)
  801288:	e8 81 fb ff ff       	call   800e0e <fd_lookup>
  80128d:	83 c4 08             	add    $0x8,%esp
  801290:	85 c0                	test   %eax,%eax
  801292:	78 4b                	js     8012df <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801294:	83 ec 08             	sub    $0x8,%esp
  801297:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80129a:	50                   	push   %eax
  80129b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80129e:	ff 30                	pushl  (%eax)
  8012a0:	e8 bf fb ff ff       	call   800e64 <dev_lookup>
  8012a5:	83 c4 10             	add    $0x10,%esp
  8012a8:	85 c0                	test   %eax,%eax
  8012aa:	78 33                	js     8012df <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  8012ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012af:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012b3:	74 2f                	je     8012e4 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012b5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012b8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012bf:	00 00 00 
	stat->st_isdir = 0;
  8012c2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012c9:	00 00 00 
	stat->st_dev = dev;
  8012cc:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012d2:	83 ec 08             	sub    $0x8,%esp
  8012d5:	53                   	push   %ebx
  8012d6:	ff 75 f0             	pushl  -0x10(%ebp)
  8012d9:	ff 50 14             	call   *0x14(%eax)
  8012dc:	83 c4 10             	add    $0x10,%esp
}
  8012df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012e2:	c9                   	leave  
  8012e3:	c3                   	ret    
		return -E_NOT_SUPP;
  8012e4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012e9:	eb f4                	jmp    8012df <fstat+0x68>

008012eb <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012eb:	55                   	push   %ebp
  8012ec:	89 e5                	mov    %esp,%ebp
  8012ee:	56                   	push   %esi
  8012ef:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012f0:	83 ec 08             	sub    $0x8,%esp
  8012f3:	6a 00                	push   $0x0
  8012f5:	ff 75 08             	pushl  0x8(%ebp)
  8012f8:	e8 e7 01 00 00       	call   8014e4 <open>
  8012fd:	89 c3                	mov    %eax,%ebx
  8012ff:	83 c4 10             	add    $0x10,%esp
  801302:	85 c0                	test   %eax,%eax
  801304:	78 1b                	js     801321 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801306:	83 ec 08             	sub    $0x8,%esp
  801309:	ff 75 0c             	pushl  0xc(%ebp)
  80130c:	50                   	push   %eax
  80130d:	e8 65 ff ff ff       	call   801277 <fstat>
  801312:	89 c6                	mov    %eax,%esi
	close(fd);
  801314:	89 1c 24             	mov    %ebx,(%esp)
  801317:	e8 27 fc ff ff       	call   800f43 <close>
	return r;
  80131c:	83 c4 10             	add    $0x10,%esp
  80131f:	89 f3                	mov    %esi,%ebx
}
  801321:	89 d8                	mov    %ebx,%eax
  801323:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801326:	5b                   	pop    %ebx
  801327:	5e                   	pop    %esi
  801328:	5d                   	pop    %ebp
  801329:	c3                   	ret    

0080132a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80132a:	55                   	push   %ebp
  80132b:	89 e5                	mov    %esp,%ebp
  80132d:	56                   	push   %esi
  80132e:	53                   	push   %ebx
  80132f:	89 c6                	mov    %eax,%esi
  801331:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801333:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80133a:	74 27                	je     801363 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80133c:	6a 07                	push   $0x7
  80133e:	68 00 50 80 00       	push   $0x805000
  801343:	56                   	push   %esi
  801344:	ff 35 00 40 80 00    	pushl  0x804000
  80134a:	e8 bf 07 00 00       	call   801b0e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80134f:	83 c4 0c             	add    $0xc,%esp
  801352:	6a 00                	push   $0x0
  801354:	53                   	push   %ebx
  801355:	6a 00                	push   $0x0
  801357:	e8 3d 07 00 00       	call   801a99 <ipc_recv>
}
  80135c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80135f:	5b                   	pop    %ebx
  801360:	5e                   	pop    %esi
  801361:	5d                   	pop    %ebp
  801362:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801363:	83 ec 0c             	sub    $0xc,%esp
  801366:	6a 01                	push   $0x1
  801368:	e8 f7 07 00 00       	call   801b64 <ipc_find_env>
  80136d:	a3 00 40 80 00       	mov    %eax,0x804000
  801372:	83 c4 10             	add    $0x10,%esp
  801375:	eb c5                	jmp    80133c <fsipc+0x12>

00801377 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801377:	55                   	push   %ebp
  801378:	89 e5                	mov    %esp,%ebp
  80137a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80137d:	8b 45 08             	mov    0x8(%ebp),%eax
  801380:	8b 40 0c             	mov    0xc(%eax),%eax
  801383:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801388:	8b 45 0c             	mov    0xc(%ebp),%eax
  80138b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801390:	ba 00 00 00 00       	mov    $0x0,%edx
  801395:	b8 02 00 00 00       	mov    $0x2,%eax
  80139a:	e8 8b ff ff ff       	call   80132a <fsipc>
}
  80139f:	c9                   	leave  
  8013a0:	c3                   	ret    

008013a1 <devfile_flush>:
{
  8013a1:	55                   	push   %ebp
  8013a2:	89 e5                	mov    %esp,%ebp
  8013a4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8013ad:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8013b7:	b8 06 00 00 00       	mov    $0x6,%eax
  8013bc:	e8 69 ff ff ff       	call   80132a <fsipc>
}
  8013c1:	c9                   	leave  
  8013c2:	c3                   	ret    

008013c3 <devfile_stat>:
{
  8013c3:	55                   	push   %ebp
  8013c4:	89 e5                	mov    %esp,%ebp
  8013c6:	53                   	push   %ebx
  8013c7:	83 ec 04             	sub    $0x4,%esp
  8013ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d0:	8b 40 0c             	mov    0xc(%eax),%eax
  8013d3:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8013dd:	b8 05 00 00 00       	mov    $0x5,%eax
  8013e2:	e8 43 ff ff ff       	call   80132a <fsipc>
  8013e7:	85 c0                	test   %eax,%eax
  8013e9:	78 2c                	js     801417 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013eb:	83 ec 08             	sub    $0x8,%esp
  8013ee:	68 00 50 80 00       	push   $0x805000
  8013f3:	53                   	push   %ebx
  8013f4:	e8 b5 f3 ff ff       	call   8007ae <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013f9:	a1 80 50 80 00       	mov    0x805080,%eax
  8013fe:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801404:	a1 84 50 80 00       	mov    0x805084,%eax
  801409:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80140f:	83 c4 10             	add    $0x10,%esp
  801412:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801417:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80141a:	c9                   	leave  
  80141b:	c3                   	ret    

0080141c <devfile_write>:
{
  80141c:	55                   	push   %ebp
  80141d:	89 e5                	mov    %esp,%ebp
  80141f:	83 ec 0c             	sub    $0xc,%esp
  801422:	8b 45 10             	mov    0x10(%ebp),%eax
  801425:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80142a:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80142f:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801432:	8b 55 08             	mov    0x8(%ebp),%edx
  801435:	8b 52 0c             	mov    0xc(%edx),%edx
  801438:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80143e:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf,buf,n);
  801443:	50                   	push   %eax
  801444:	ff 75 0c             	pushl  0xc(%ebp)
  801447:	68 08 50 80 00       	push   $0x805008
  80144c:	e8 eb f4 ff ff       	call   80093c <memmove>
	if((r = fsipc(FSREQ_WRITE,NULL))<0)
  801451:	ba 00 00 00 00       	mov    $0x0,%edx
  801456:	b8 04 00 00 00       	mov    $0x4,%eax
  80145b:	e8 ca fe ff ff       	call   80132a <fsipc>
}
  801460:	c9                   	leave  
  801461:	c3                   	ret    

00801462 <devfile_read>:
{
  801462:	55                   	push   %ebp
  801463:	89 e5                	mov    %esp,%ebp
  801465:	56                   	push   %esi
  801466:	53                   	push   %ebx
  801467:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80146a:	8b 45 08             	mov    0x8(%ebp),%eax
  80146d:	8b 40 0c             	mov    0xc(%eax),%eax
  801470:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801475:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80147b:	ba 00 00 00 00       	mov    $0x0,%edx
  801480:	b8 03 00 00 00       	mov    $0x3,%eax
  801485:	e8 a0 fe ff ff       	call   80132a <fsipc>
  80148a:	89 c3                	mov    %eax,%ebx
  80148c:	85 c0                	test   %eax,%eax
  80148e:	78 1f                	js     8014af <devfile_read+0x4d>
	assert(r <= n);
  801490:	39 f0                	cmp    %esi,%eax
  801492:	77 24                	ja     8014b8 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801494:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801499:	7f 33                	jg     8014ce <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80149b:	83 ec 04             	sub    $0x4,%esp
  80149e:	50                   	push   %eax
  80149f:	68 00 50 80 00       	push   $0x805000
  8014a4:	ff 75 0c             	pushl  0xc(%ebp)
  8014a7:	e8 90 f4 ff ff       	call   80093c <memmove>
	return r;
  8014ac:	83 c4 10             	add    $0x10,%esp
}
  8014af:	89 d8                	mov    %ebx,%eax
  8014b1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014b4:	5b                   	pop    %ebx
  8014b5:	5e                   	pop    %esi
  8014b6:	5d                   	pop    %ebp
  8014b7:	c3                   	ret    
	assert(r <= n);
  8014b8:	68 58 22 80 00       	push   $0x802258
  8014bd:	68 5f 22 80 00       	push   $0x80225f
  8014c2:	6a 7c                	push   $0x7c
  8014c4:	68 74 22 80 00       	push   $0x802274
  8014c9:	e8 85 05 00 00       	call   801a53 <_panic>
	assert(r <= PGSIZE);
  8014ce:	68 7f 22 80 00       	push   $0x80227f
  8014d3:	68 5f 22 80 00       	push   $0x80225f
  8014d8:	6a 7d                	push   $0x7d
  8014da:	68 74 22 80 00       	push   $0x802274
  8014df:	e8 6f 05 00 00       	call   801a53 <_panic>

008014e4 <open>:
{
  8014e4:	55                   	push   %ebp
  8014e5:	89 e5                	mov    %esp,%ebp
  8014e7:	56                   	push   %esi
  8014e8:	53                   	push   %ebx
  8014e9:	83 ec 1c             	sub    $0x1c,%esp
  8014ec:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8014ef:	56                   	push   %esi
  8014f0:	e8 82 f2 ff ff       	call   800777 <strlen>
  8014f5:	83 c4 10             	add    $0x10,%esp
  8014f8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014fd:	7f 6c                	jg     80156b <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8014ff:	83 ec 0c             	sub    $0xc,%esp
  801502:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801505:	50                   	push   %eax
  801506:	e8 b4 f8 ff ff       	call   800dbf <fd_alloc>
  80150b:	89 c3                	mov    %eax,%ebx
  80150d:	83 c4 10             	add    $0x10,%esp
  801510:	85 c0                	test   %eax,%eax
  801512:	78 3c                	js     801550 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801514:	83 ec 08             	sub    $0x8,%esp
  801517:	56                   	push   %esi
  801518:	68 00 50 80 00       	push   $0x805000
  80151d:	e8 8c f2 ff ff       	call   8007ae <strcpy>
	fsipcbuf.open.req_omode = mode;
  801522:	8b 45 0c             	mov    0xc(%ebp),%eax
  801525:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80152a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80152d:	b8 01 00 00 00       	mov    $0x1,%eax
  801532:	e8 f3 fd ff ff       	call   80132a <fsipc>
  801537:	89 c3                	mov    %eax,%ebx
  801539:	83 c4 10             	add    $0x10,%esp
  80153c:	85 c0                	test   %eax,%eax
  80153e:	78 19                	js     801559 <open+0x75>
	return fd2num(fd);
  801540:	83 ec 0c             	sub    $0xc,%esp
  801543:	ff 75 f4             	pushl  -0xc(%ebp)
  801546:	e8 4d f8 ff ff       	call   800d98 <fd2num>
  80154b:	89 c3                	mov    %eax,%ebx
  80154d:	83 c4 10             	add    $0x10,%esp
}
  801550:	89 d8                	mov    %ebx,%eax
  801552:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801555:	5b                   	pop    %ebx
  801556:	5e                   	pop    %esi
  801557:	5d                   	pop    %ebp
  801558:	c3                   	ret    
		fd_close(fd, 0);
  801559:	83 ec 08             	sub    $0x8,%esp
  80155c:	6a 00                	push   $0x0
  80155e:	ff 75 f4             	pushl  -0xc(%ebp)
  801561:	e8 54 f9 ff ff       	call   800eba <fd_close>
		return r;
  801566:	83 c4 10             	add    $0x10,%esp
  801569:	eb e5                	jmp    801550 <open+0x6c>
		return -E_BAD_PATH;
  80156b:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801570:	eb de                	jmp    801550 <open+0x6c>

00801572 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801572:	55                   	push   %ebp
  801573:	89 e5                	mov    %esp,%ebp
  801575:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801578:	ba 00 00 00 00       	mov    $0x0,%edx
  80157d:	b8 08 00 00 00       	mov    $0x8,%eax
  801582:	e8 a3 fd ff ff       	call   80132a <fsipc>
}
  801587:	c9                   	leave  
  801588:	c3                   	ret    

00801589 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801589:	55                   	push   %ebp
  80158a:	89 e5                	mov    %esp,%ebp
  80158c:	56                   	push   %esi
  80158d:	53                   	push   %ebx
  80158e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801591:	83 ec 0c             	sub    $0xc,%esp
  801594:	ff 75 08             	pushl  0x8(%ebp)
  801597:	e8 0c f8 ff ff       	call   800da8 <fd2data>
  80159c:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80159e:	83 c4 08             	add    $0x8,%esp
  8015a1:	68 8b 22 80 00       	push   $0x80228b
  8015a6:	53                   	push   %ebx
  8015a7:	e8 02 f2 ff ff       	call   8007ae <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8015ac:	8b 46 04             	mov    0x4(%esi),%eax
  8015af:	2b 06                	sub    (%esi),%eax
  8015b1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8015b7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015be:	00 00 00 
	stat->st_dev = &devpipe;
  8015c1:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8015c8:	30 80 00 
	return 0;
}
  8015cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8015d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015d3:	5b                   	pop    %ebx
  8015d4:	5e                   	pop    %esi
  8015d5:	5d                   	pop    %ebp
  8015d6:	c3                   	ret    

008015d7 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8015d7:	55                   	push   %ebp
  8015d8:	89 e5                	mov    %esp,%ebp
  8015da:	53                   	push   %ebx
  8015db:	83 ec 0c             	sub    $0xc,%esp
  8015de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8015e1:	53                   	push   %ebx
  8015e2:	6a 00                	push   $0x0
  8015e4:	e8 43 f6 ff ff       	call   800c2c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8015e9:	89 1c 24             	mov    %ebx,(%esp)
  8015ec:	e8 b7 f7 ff ff       	call   800da8 <fd2data>
  8015f1:	83 c4 08             	add    $0x8,%esp
  8015f4:	50                   	push   %eax
  8015f5:	6a 00                	push   $0x0
  8015f7:	e8 30 f6 ff ff       	call   800c2c <sys_page_unmap>
}
  8015fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ff:	c9                   	leave  
  801600:	c3                   	ret    

00801601 <_pipeisclosed>:
{
  801601:	55                   	push   %ebp
  801602:	89 e5                	mov    %esp,%ebp
  801604:	57                   	push   %edi
  801605:	56                   	push   %esi
  801606:	53                   	push   %ebx
  801607:	83 ec 1c             	sub    $0x1c,%esp
  80160a:	89 c7                	mov    %eax,%edi
  80160c:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  80160e:	a1 04 40 80 00       	mov    0x804004,%eax
  801613:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801616:	83 ec 0c             	sub    $0xc,%esp
  801619:	57                   	push   %edi
  80161a:	e8 7e 05 00 00       	call   801b9d <pageref>
  80161f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801622:	89 34 24             	mov    %esi,(%esp)
  801625:	e8 73 05 00 00       	call   801b9d <pageref>
		nn = thisenv->env_runs;
  80162a:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801630:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801633:	83 c4 10             	add    $0x10,%esp
  801636:	39 cb                	cmp    %ecx,%ebx
  801638:	74 1b                	je     801655 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  80163a:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80163d:	75 cf                	jne    80160e <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80163f:	8b 42 58             	mov    0x58(%edx),%eax
  801642:	6a 01                	push   $0x1
  801644:	50                   	push   %eax
  801645:	53                   	push   %ebx
  801646:	68 92 22 80 00       	push   $0x802292
  80164b:	e8 3f eb ff ff       	call   80018f <cprintf>
  801650:	83 c4 10             	add    $0x10,%esp
  801653:	eb b9                	jmp    80160e <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801655:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801658:	0f 94 c0             	sete   %al
  80165b:	0f b6 c0             	movzbl %al,%eax
}
  80165e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801661:	5b                   	pop    %ebx
  801662:	5e                   	pop    %esi
  801663:	5f                   	pop    %edi
  801664:	5d                   	pop    %ebp
  801665:	c3                   	ret    

00801666 <devpipe_write>:
{
  801666:	55                   	push   %ebp
  801667:	89 e5                	mov    %esp,%ebp
  801669:	57                   	push   %edi
  80166a:	56                   	push   %esi
  80166b:	53                   	push   %ebx
  80166c:	83 ec 28             	sub    $0x28,%esp
  80166f:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801672:	56                   	push   %esi
  801673:	e8 30 f7 ff ff       	call   800da8 <fd2data>
  801678:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80167a:	83 c4 10             	add    $0x10,%esp
  80167d:	bf 00 00 00 00       	mov    $0x0,%edi
  801682:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801685:	74 4f                	je     8016d6 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801687:	8b 43 04             	mov    0x4(%ebx),%eax
  80168a:	8b 0b                	mov    (%ebx),%ecx
  80168c:	8d 51 20             	lea    0x20(%ecx),%edx
  80168f:	39 d0                	cmp    %edx,%eax
  801691:	72 14                	jb     8016a7 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801693:	89 da                	mov    %ebx,%edx
  801695:	89 f0                	mov    %esi,%eax
  801697:	e8 65 ff ff ff       	call   801601 <_pipeisclosed>
  80169c:	85 c0                	test   %eax,%eax
  80169e:	75 3a                	jne    8016da <devpipe_write+0x74>
			sys_yield();
  8016a0:	e8 e3 f4 ff ff       	call   800b88 <sys_yield>
  8016a5:	eb e0                	jmp    801687 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8016a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016aa:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8016ae:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8016b1:	89 c2                	mov    %eax,%edx
  8016b3:	c1 fa 1f             	sar    $0x1f,%edx
  8016b6:	89 d1                	mov    %edx,%ecx
  8016b8:	c1 e9 1b             	shr    $0x1b,%ecx
  8016bb:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8016be:	83 e2 1f             	and    $0x1f,%edx
  8016c1:	29 ca                	sub    %ecx,%edx
  8016c3:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8016c7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8016cb:	83 c0 01             	add    $0x1,%eax
  8016ce:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  8016d1:	83 c7 01             	add    $0x1,%edi
  8016d4:	eb ac                	jmp    801682 <devpipe_write+0x1c>
	return i;
  8016d6:	89 f8                	mov    %edi,%eax
  8016d8:	eb 05                	jmp    8016df <devpipe_write+0x79>
				return 0;
  8016da:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016e2:	5b                   	pop    %ebx
  8016e3:	5e                   	pop    %esi
  8016e4:	5f                   	pop    %edi
  8016e5:	5d                   	pop    %ebp
  8016e6:	c3                   	ret    

008016e7 <devpipe_read>:
{
  8016e7:	55                   	push   %ebp
  8016e8:	89 e5                	mov    %esp,%ebp
  8016ea:	57                   	push   %edi
  8016eb:	56                   	push   %esi
  8016ec:	53                   	push   %ebx
  8016ed:	83 ec 18             	sub    $0x18,%esp
  8016f0:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8016f3:	57                   	push   %edi
  8016f4:	e8 af f6 ff ff       	call   800da8 <fd2data>
  8016f9:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8016fb:	83 c4 10             	add    $0x10,%esp
  8016fe:	be 00 00 00 00       	mov    $0x0,%esi
  801703:	3b 75 10             	cmp    0x10(%ebp),%esi
  801706:	74 47                	je     80174f <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  801708:	8b 03                	mov    (%ebx),%eax
  80170a:	3b 43 04             	cmp    0x4(%ebx),%eax
  80170d:	75 22                	jne    801731 <devpipe_read+0x4a>
			if (i > 0)
  80170f:	85 f6                	test   %esi,%esi
  801711:	75 14                	jne    801727 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801713:	89 da                	mov    %ebx,%edx
  801715:	89 f8                	mov    %edi,%eax
  801717:	e8 e5 fe ff ff       	call   801601 <_pipeisclosed>
  80171c:	85 c0                	test   %eax,%eax
  80171e:	75 33                	jne    801753 <devpipe_read+0x6c>
			sys_yield();
  801720:	e8 63 f4 ff ff       	call   800b88 <sys_yield>
  801725:	eb e1                	jmp    801708 <devpipe_read+0x21>
				return i;
  801727:	89 f0                	mov    %esi,%eax
}
  801729:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80172c:	5b                   	pop    %ebx
  80172d:	5e                   	pop    %esi
  80172e:	5f                   	pop    %edi
  80172f:	5d                   	pop    %ebp
  801730:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801731:	99                   	cltd   
  801732:	c1 ea 1b             	shr    $0x1b,%edx
  801735:	01 d0                	add    %edx,%eax
  801737:	83 e0 1f             	and    $0x1f,%eax
  80173a:	29 d0                	sub    %edx,%eax
  80173c:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801741:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801744:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801747:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  80174a:	83 c6 01             	add    $0x1,%esi
  80174d:	eb b4                	jmp    801703 <devpipe_read+0x1c>
	return i;
  80174f:	89 f0                	mov    %esi,%eax
  801751:	eb d6                	jmp    801729 <devpipe_read+0x42>
				return 0;
  801753:	b8 00 00 00 00       	mov    $0x0,%eax
  801758:	eb cf                	jmp    801729 <devpipe_read+0x42>

0080175a <pipe>:
{
  80175a:	55                   	push   %ebp
  80175b:	89 e5                	mov    %esp,%ebp
  80175d:	56                   	push   %esi
  80175e:	53                   	push   %ebx
  80175f:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801762:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801765:	50                   	push   %eax
  801766:	e8 54 f6 ff ff       	call   800dbf <fd_alloc>
  80176b:	89 c3                	mov    %eax,%ebx
  80176d:	83 c4 10             	add    $0x10,%esp
  801770:	85 c0                	test   %eax,%eax
  801772:	78 5b                	js     8017cf <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801774:	83 ec 04             	sub    $0x4,%esp
  801777:	68 07 04 00 00       	push   $0x407
  80177c:	ff 75 f4             	pushl  -0xc(%ebp)
  80177f:	6a 00                	push   $0x0
  801781:	e8 21 f4 ff ff       	call   800ba7 <sys_page_alloc>
  801786:	89 c3                	mov    %eax,%ebx
  801788:	83 c4 10             	add    $0x10,%esp
  80178b:	85 c0                	test   %eax,%eax
  80178d:	78 40                	js     8017cf <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  80178f:	83 ec 0c             	sub    $0xc,%esp
  801792:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801795:	50                   	push   %eax
  801796:	e8 24 f6 ff ff       	call   800dbf <fd_alloc>
  80179b:	89 c3                	mov    %eax,%ebx
  80179d:	83 c4 10             	add    $0x10,%esp
  8017a0:	85 c0                	test   %eax,%eax
  8017a2:	78 1b                	js     8017bf <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017a4:	83 ec 04             	sub    $0x4,%esp
  8017a7:	68 07 04 00 00       	push   $0x407
  8017ac:	ff 75 f0             	pushl  -0x10(%ebp)
  8017af:	6a 00                	push   $0x0
  8017b1:	e8 f1 f3 ff ff       	call   800ba7 <sys_page_alloc>
  8017b6:	89 c3                	mov    %eax,%ebx
  8017b8:	83 c4 10             	add    $0x10,%esp
  8017bb:	85 c0                	test   %eax,%eax
  8017bd:	79 19                	jns    8017d8 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  8017bf:	83 ec 08             	sub    $0x8,%esp
  8017c2:	ff 75 f4             	pushl  -0xc(%ebp)
  8017c5:	6a 00                	push   $0x0
  8017c7:	e8 60 f4 ff ff       	call   800c2c <sys_page_unmap>
  8017cc:	83 c4 10             	add    $0x10,%esp
}
  8017cf:	89 d8                	mov    %ebx,%eax
  8017d1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017d4:	5b                   	pop    %ebx
  8017d5:	5e                   	pop    %esi
  8017d6:	5d                   	pop    %ebp
  8017d7:	c3                   	ret    
	va = fd2data(fd0);
  8017d8:	83 ec 0c             	sub    $0xc,%esp
  8017db:	ff 75 f4             	pushl  -0xc(%ebp)
  8017de:	e8 c5 f5 ff ff       	call   800da8 <fd2data>
  8017e3:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017e5:	83 c4 0c             	add    $0xc,%esp
  8017e8:	68 07 04 00 00       	push   $0x407
  8017ed:	50                   	push   %eax
  8017ee:	6a 00                	push   $0x0
  8017f0:	e8 b2 f3 ff ff       	call   800ba7 <sys_page_alloc>
  8017f5:	89 c3                	mov    %eax,%ebx
  8017f7:	83 c4 10             	add    $0x10,%esp
  8017fa:	85 c0                	test   %eax,%eax
  8017fc:	0f 88 8c 00 00 00    	js     80188e <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801802:	83 ec 0c             	sub    $0xc,%esp
  801805:	ff 75 f0             	pushl  -0x10(%ebp)
  801808:	e8 9b f5 ff ff       	call   800da8 <fd2data>
  80180d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801814:	50                   	push   %eax
  801815:	6a 00                	push   $0x0
  801817:	56                   	push   %esi
  801818:	6a 00                	push   $0x0
  80181a:	e8 cb f3 ff ff       	call   800bea <sys_page_map>
  80181f:	89 c3                	mov    %eax,%ebx
  801821:	83 c4 20             	add    $0x20,%esp
  801824:	85 c0                	test   %eax,%eax
  801826:	78 58                	js     801880 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801828:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80182b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801831:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801833:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801836:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  80183d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801840:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801846:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801848:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80184b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801852:	83 ec 0c             	sub    $0xc,%esp
  801855:	ff 75 f4             	pushl  -0xc(%ebp)
  801858:	e8 3b f5 ff ff       	call   800d98 <fd2num>
  80185d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801860:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801862:	83 c4 04             	add    $0x4,%esp
  801865:	ff 75 f0             	pushl  -0x10(%ebp)
  801868:	e8 2b f5 ff ff       	call   800d98 <fd2num>
  80186d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801870:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801873:	83 c4 10             	add    $0x10,%esp
  801876:	bb 00 00 00 00       	mov    $0x0,%ebx
  80187b:	e9 4f ff ff ff       	jmp    8017cf <pipe+0x75>
	sys_page_unmap(0, va);
  801880:	83 ec 08             	sub    $0x8,%esp
  801883:	56                   	push   %esi
  801884:	6a 00                	push   $0x0
  801886:	e8 a1 f3 ff ff       	call   800c2c <sys_page_unmap>
  80188b:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  80188e:	83 ec 08             	sub    $0x8,%esp
  801891:	ff 75 f0             	pushl  -0x10(%ebp)
  801894:	6a 00                	push   $0x0
  801896:	e8 91 f3 ff ff       	call   800c2c <sys_page_unmap>
  80189b:	83 c4 10             	add    $0x10,%esp
  80189e:	e9 1c ff ff ff       	jmp    8017bf <pipe+0x65>

008018a3 <pipeisclosed>:
{
  8018a3:	55                   	push   %ebp
  8018a4:	89 e5                	mov    %esp,%ebp
  8018a6:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018ac:	50                   	push   %eax
  8018ad:	ff 75 08             	pushl  0x8(%ebp)
  8018b0:	e8 59 f5 ff ff       	call   800e0e <fd_lookup>
  8018b5:	83 c4 10             	add    $0x10,%esp
  8018b8:	85 c0                	test   %eax,%eax
  8018ba:	78 18                	js     8018d4 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  8018bc:	83 ec 0c             	sub    $0xc,%esp
  8018bf:	ff 75 f4             	pushl  -0xc(%ebp)
  8018c2:	e8 e1 f4 ff ff       	call   800da8 <fd2data>
	return _pipeisclosed(fd, p);
  8018c7:	89 c2                	mov    %eax,%edx
  8018c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018cc:	e8 30 fd ff ff       	call   801601 <_pipeisclosed>
  8018d1:	83 c4 10             	add    $0x10,%esp
}
  8018d4:	c9                   	leave  
  8018d5:	c3                   	ret    

008018d6 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8018d6:	55                   	push   %ebp
  8018d7:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8018d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8018de:	5d                   	pop    %ebp
  8018df:	c3                   	ret    

008018e0 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8018e0:	55                   	push   %ebp
  8018e1:	89 e5                	mov    %esp,%ebp
  8018e3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8018e6:	68 aa 22 80 00       	push   $0x8022aa
  8018eb:	ff 75 0c             	pushl  0xc(%ebp)
  8018ee:	e8 bb ee ff ff       	call   8007ae <strcpy>
	return 0;
}
  8018f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8018f8:	c9                   	leave  
  8018f9:	c3                   	ret    

008018fa <devcons_write>:
{
  8018fa:	55                   	push   %ebp
  8018fb:	89 e5                	mov    %esp,%ebp
  8018fd:	57                   	push   %edi
  8018fe:	56                   	push   %esi
  8018ff:	53                   	push   %ebx
  801900:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801906:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80190b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801911:	eb 2f                	jmp    801942 <devcons_write+0x48>
		m = n - tot;
  801913:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801916:	29 f3                	sub    %esi,%ebx
  801918:	83 fb 7f             	cmp    $0x7f,%ebx
  80191b:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801920:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801923:	83 ec 04             	sub    $0x4,%esp
  801926:	53                   	push   %ebx
  801927:	89 f0                	mov    %esi,%eax
  801929:	03 45 0c             	add    0xc(%ebp),%eax
  80192c:	50                   	push   %eax
  80192d:	57                   	push   %edi
  80192e:	e8 09 f0 ff ff       	call   80093c <memmove>
		sys_cputs(buf, m);
  801933:	83 c4 08             	add    $0x8,%esp
  801936:	53                   	push   %ebx
  801937:	57                   	push   %edi
  801938:	e8 ae f1 ff ff       	call   800aeb <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  80193d:	01 de                	add    %ebx,%esi
  80193f:	83 c4 10             	add    $0x10,%esp
  801942:	3b 75 10             	cmp    0x10(%ebp),%esi
  801945:	72 cc                	jb     801913 <devcons_write+0x19>
}
  801947:	89 f0                	mov    %esi,%eax
  801949:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80194c:	5b                   	pop    %ebx
  80194d:	5e                   	pop    %esi
  80194e:	5f                   	pop    %edi
  80194f:	5d                   	pop    %ebp
  801950:	c3                   	ret    

00801951 <devcons_read>:
{
  801951:	55                   	push   %ebp
  801952:	89 e5                	mov    %esp,%ebp
  801954:	83 ec 08             	sub    $0x8,%esp
  801957:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  80195c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801960:	75 07                	jne    801969 <devcons_read+0x18>
}
  801962:	c9                   	leave  
  801963:	c3                   	ret    
		sys_yield();
  801964:	e8 1f f2 ff ff       	call   800b88 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801969:	e8 9b f1 ff ff       	call   800b09 <sys_cgetc>
  80196e:	85 c0                	test   %eax,%eax
  801970:	74 f2                	je     801964 <devcons_read+0x13>
	if (c < 0)
  801972:	85 c0                	test   %eax,%eax
  801974:	78 ec                	js     801962 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  801976:	83 f8 04             	cmp    $0x4,%eax
  801979:	74 0c                	je     801987 <devcons_read+0x36>
	*(char*)vbuf = c;
  80197b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80197e:	88 02                	mov    %al,(%edx)
	return 1;
  801980:	b8 01 00 00 00       	mov    $0x1,%eax
  801985:	eb db                	jmp    801962 <devcons_read+0x11>
		return 0;
  801987:	b8 00 00 00 00       	mov    $0x0,%eax
  80198c:	eb d4                	jmp    801962 <devcons_read+0x11>

0080198e <cputchar>:
{
  80198e:	55                   	push   %ebp
  80198f:	89 e5                	mov    %esp,%ebp
  801991:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801994:	8b 45 08             	mov    0x8(%ebp),%eax
  801997:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  80199a:	6a 01                	push   $0x1
  80199c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80199f:	50                   	push   %eax
  8019a0:	e8 46 f1 ff ff       	call   800aeb <sys_cputs>
}
  8019a5:	83 c4 10             	add    $0x10,%esp
  8019a8:	c9                   	leave  
  8019a9:	c3                   	ret    

008019aa <getchar>:
{
  8019aa:	55                   	push   %ebp
  8019ab:	89 e5                	mov    %esp,%ebp
  8019ad:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  8019b0:	6a 01                	push   $0x1
  8019b2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8019b5:	50                   	push   %eax
  8019b6:	6a 00                	push   $0x0
  8019b8:	e8 c2 f6 ff ff       	call   80107f <read>
	if (r < 0)
  8019bd:	83 c4 10             	add    $0x10,%esp
  8019c0:	85 c0                	test   %eax,%eax
  8019c2:	78 08                	js     8019cc <getchar+0x22>
	if (r < 1)
  8019c4:	85 c0                	test   %eax,%eax
  8019c6:	7e 06                	jle    8019ce <getchar+0x24>
	return c;
  8019c8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  8019cc:	c9                   	leave  
  8019cd:	c3                   	ret    
		return -E_EOF;
  8019ce:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  8019d3:	eb f7                	jmp    8019cc <getchar+0x22>

008019d5 <iscons>:
{
  8019d5:	55                   	push   %ebp
  8019d6:	89 e5                	mov    %esp,%ebp
  8019d8:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019de:	50                   	push   %eax
  8019df:	ff 75 08             	pushl  0x8(%ebp)
  8019e2:	e8 27 f4 ff ff       	call   800e0e <fd_lookup>
  8019e7:	83 c4 10             	add    $0x10,%esp
  8019ea:	85 c0                	test   %eax,%eax
  8019ec:	78 11                	js     8019ff <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  8019ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019f1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019f7:	39 10                	cmp    %edx,(%eax)
  8019f9:	0f 94 c0             	sete   %al
  8019fc:	0f b6 c0             	movzbl %al,%eax
}
  8019ff:	c9                   	leave  
  801a00:	c3                   	ret    

00801a01 <opencons>:
{
  801a01:	55                   	push   %ebp
  801a02:	89 e5                	mov    %esp,%ebp
  801a04:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801a07:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a0a:	50                   	push   %eax
  801a0b:	e8 af f3 ff ff       	call   800dbf <fd_alloc>
  801a10:	83 c4 10             	add    $0x10,%esp
  801a13:	85 c0                	test   %eax,%eax
  801a15:	78 3a                	js     801a51 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a17:	83 ec 04             	sub    $0x4,%esp
  801a1a:	68 07 04 00 00       	push   $0x407
  801a1f:	ff 75 f4             	pushl  -0xc(%ebp)
  801a22:	6a 00                	push   $0x0
  801a24:	e8 7e f1 ff ff       	call   800ba7 <sys_page_alloc>
  801a29:	83 c4 10             	add    $0x10,%esp
  801a2c:	85 c0                	test   %eax,%eax
  801a2e:	78 21                	js     801a51 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801a30:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a33:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a39:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a3e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a45:	83 ec 0c             	sub    $0xc,%esp
  801a48:	50                   	push   %eax
  801a49:	e8 4a f3 ff ff       	call   800d98 <fd2num>
  801a4e:	83 c4 10             	add    $0x10,%esp
}
  801a51:	c9                   	leave  
  801a52:	c3                   	ret    

00801a53 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a53:	55                   	push   %ebp
  801a54:	89 e5                	mov    %esp,%ebp
  801a56:	56                   	push   %esi
  801a57:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a58:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a5b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a61:	e8 03 f1 ff ff       	call   800b69 <sys_getenvid>
  801a66:	83 ec 0c             	sub    $0xc,%esp
  801a69:	ff 75 0c             	pushl  0xc(%ebp)
  801a6c:	ff 75 08             	pushl  0x8(%ebp)
  801a6f:	56                   	push   %esi
  801a70:	50                   	push   %eax
  801a71:	68 b8 22 80 00       	push   $0x8022b8
  801a76:	e8 14 e7 ff ff       	call   80018f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a7b:	83 c4 18             	add    $0x18,%esp
  801a7e:	53                   	push   %ebx
  801a7f:	ff 75 10             	pushl  0x10(%ebp)
  801a82:	e8 b7 e6 ff ff       	call   80013e <vcprintf>
	cprintf("\n");
  801a87:	c7 04 24 a3 22 80 00 	movl   $0x8022a3,(%esp)
  801a8e:	e8 fc e6 ff ff       	call   80018f <cprintf>
  801a93:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a96:	cc                   	int3   
  801a97:	eb fd                	jmp    801a96 <_panic+0x43>

00801a99 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a99:	55                   	push   %ebp
  801a9a:	89 e5                	mov    %esp,%ebp
  801a9c:	56                   	push   %esi
  801a9d:	53                   	push   %ebx
  801a9e:	8b 75 08             	mov    0x8(%ebp),%esi
  801aa1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aa4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        //	panic("ipc_recv not implemented");
        int r;
       	if(pg!=NULL){
  801aa7:	85 c0                	test   %eax,%eax
  801aa9:	74 3b                	je     801ae6 <ipc_recv+0x4d>
	  r = sys_ipc_recv(pg);
  801aab:	83 ec 0c             	sub    $0xc,%esp
  801aae:	50                   	push   %eax
  801aaf:	e8 a3 f2 ff ff       	call   800d57 <sys_ipc_recv>
  801ab4:	83 c4 10             	add    $0x10,%esp
	}else
	  r = sys_ipc_recv((void *)UTOP);
	if(r<0){
  801ab7:	85 c0                	test   %eax,%eax
  801ab9:	78 3d                	js     801af8 <ipc_recv+0x5f>
	if(perm_store!=NULL){
		*perm_store = 0;
            }
        	return r;
           }else{
	     if(from_env_store!=NULL)
  801abb:	85 f6                	test   %esi,%esi
  801abd:	74 0a                	je     801ac9 <ipc_recv+0x30>
		     *from_env_store = thisenv->env_ipc_from;
  801abf:	a1 04 40 80 00       	mov    0x804004,%eax
  801ac4:	8b 40 74             	mov    0x74(%eax),%eax
  801ac7:	89 06                	mov    %eax,(%esi)
	     if(perm_store != NULL)
  801ac9:	85 db                	test   %ebx,%ebx
  801acb:	74 0a                	je     801ad7 <ipc_recv+0x3e>
		     *perm_store = thisenv->env_ipc_perm;
  801acd:	a1 04 40 80 00       	mov    0x804004,%eax
  801ad2:	8b 40 78             	mov    0x78(%eax),%eax
  801ad5:	89 03                	mov    %eax,(%ebx)
	     return thisenv->env_ipc_value;
  801ad7:	a1 04 40 80 00       	mov    0x804004,%eax
  801adc:	8b 40 70             	mov    0x70(%eax),%eax
	   }

}
  801adf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ae2:	5b                   	pop    %ebx
  801ae3:	5e                   	pop    %esi
  801ae4:	5d                   	pop    %ebp
  801ae5:	c3                   	ret    
	  r = sys_ipc_recv((void *)UTOP);
  801ae6:	83 ec 0c             	sub    $0xc,%esp
  801ae9:	68 00 00 c0 ee       	push   $0xeec00000
  801aee:	e8 64 f2 ff ff       	call   800d57 <sys_ipc_recv>
  801af3:	83 c4 10             	add    $0x10,%esp
  801af6:	eb bf                	jmp    801ab7 <ipc_recv+0x1e>
	if(from_env_store!=NULL){
  801af8:	85 f6                	test   %esi,%esi
  801afa:	74 06                	je     801b02 <ipc_recv+0x69>
	  *from_env_store = 0;
  801afc:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if(perm_store!=NULL){
  801b02:	85 db                	test   %ebx,%ebx
  801b04:	74 d9                	je     801adf <ipc_recv+0x46>
		*perm_store = 0;
  801b06:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b0c:	eb d1                	jmp    801adf <ipc_recv+0x46>

00801b0e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b0e:	55                   	push   %ebp
  801b0f:	89 e5                	mov    %esp,%ebp
  801b11:	57                   	push   %edi
  801b12:	56                   	push   %esi
  801b13:	53                   	push   %ebx
  801b14:	83 ec 0c             	sub    $0xc,%esp
  801b17:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b1a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b1d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if(pg==NULL) pg = (void *)UTOP;
  801b20:	85 db                	test   %ebx,%ebx
  801b22:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801b27:	0f 44 d8             	cmove  %eax,%ebx
	while((r=sys_ipc_try_send(to_env,val,pg,perm))<0){
  801b2a:	ff 75 14             	pushl  0x14(%ebp)
  801b2d:	53                   	push   %ebx
  801b2e:	56                   	push   %esi
  801b2f:	57                   	push   %edi
  801b30:	e8 ff f1 ff ff       	call   800d34 <sys_ipc_try_send>
  801b35:	83 c4 10             	add    $0x10,%esp
  801b38:	85 c0                	test   %eax,%eax
  801b3a:	79 20                	jns    801b5c <ipc_send+0x4e>
	    if(r!=-E_IPC_NOT_RECV){
  801b3c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b3f:	75 07                	jne    801b48 <ipc_send+0x3a>
		    panic("ipc_send:send message failed\n");
	    }
	    sys_yield();
  801b41:	e8 42 f0 ff ff       	call   800b88 <sys_yield>
  801b46:	eb e2                	jmp    801b2a <ipc_send+0x1c>
		    panic("ipc_send:send message failed\n");
  801b48:	83 ec 04             	sub    $0x4,%esp
  801b4b:	68 dc 22 80 00       	push   $0x8022dc
  801b50:	6a 43                	push   $0x43
  801b52:	68 fa 22 80 00       	push   $0x8022fa
  801b57:	e8 f7 fe ff ff       	call   801a53 <_panic>
	}

}
  801b5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b5f:	5b                   	pop    %ebx
  801b60:	5e                   	pop    %esi
  801b61:	5f                   	pop    %edi
  801b62:	5d                   	pop    %ebp
  801b63:	c3                   	ret    

00801b64 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b64:	55                   	push   %ebp
  801b65:	89 e5                	mov    %esp,%ebp
  801b67:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b6a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b6f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b72:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b78:	8b 52 50             	mov    0x50(%edx),%edx
  801b7b:	39 ca                	cmp    %ecx,%edx
  801b7d:	74 11                	je     801b90 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801b7f:	83 c0 01             	add    $0x1,%eax
  801b82:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b87:	75 e6                	jne    801b6f <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801b89:	b8 00 00 00 00       	mov    $0x0,%eax
  801b8e:	eb 0b                	jmp    801b9b <ipc_find_env+0x37>
			return envs[i].env_id;
  801b90:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b93:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b98:	8b 40 48             	mov    0x48(%eax),%eax
}
  801b9b:	5d                   	pop    %ebp
  801b9c:	c3                   	ret    

00801b9d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b9d:	55                   	push   %ebp
  801b9e:	89 e5                	mov    %esp,%ebp
  801ba0:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ba3:	89 d0                	mov    %edx,%eax
  801ba5:	c1 e8 16             	shr    $0x16,%eax
  801ba8:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801baf:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801bb4:	f6 c1 01             	test   $0x1,%cl
  801bb7:	74 1d                	je     801bd6 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801bb9:	c1 ea 0c             	shr    $0xc,%edx
  801bbc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801bc3:	f6 c2 01             	test   $0x1,%dl
  801bc6:	74 0e                	je     801bd6 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bc8:	c1 ea 0c             	shr    $0xc,%edx
  801bcb:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801bd2:	ef 
  801bd3:	0f b7 c0             	movzwl %ax,%eax
}
  801bd6:	5d                   	pop    %ebp
  801bd7:	c3                   	ret    
  801bd8:	66 90                	xchg   %ax,%ax
  801bda:	66 90                	xchg   %ax,%ax
  801bdc:	66 90                	xchg   %ax,%ax
  801bde:	66 90                	xchg   %ax,%ax

00801be0 <__udivdi3>:
  801be0:	55                   	push   %ebp
  801be1:	57                   	push   %edi
  801be2:	56                   	push   %esi
  801be3:	53                   	push   %ebx
  801be4:	83 ec 1c             	sub    $0x1c,%esp
  801be7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801beb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801bef:	8b 74 24 34          	mov    0x34(%esp),%esi
  801bf3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801bf7:	85 d2                	test   %edx,%edx
  801bf9:	75 35                	jne    801c30 <__udivdi3+0x50>
  801bfb:	39 f3                	cmp    %esi,%ebx
  801bfd:	0f 87 bd 00 00 00    	ja     801cc0 <__udivdi3+0xe0>
  801c03:	85 db                	test   %ebx,%ebx
  801c05:	89 d9                	mov    %ebx,%ecx
  801c07:	75 0b                	jne    801c14 <__udivdi3+0x34>
  801c09:	b8 01 00 00 00       	mov    $0x1,%eax
  801c0e:	31 d2                	xor    %edx,%edx
  801c10:	f7 f3                	div    %ebx
  801c12:	89 c1                	mov    %eax,%ecx
  801c14:	31 d2                	xor    %edx,%edx
  801c16:	89 f0                	mov    %esi,%eax
  801c18:	f7 f1                	div    %ecx
  801c1a:	89 c6                	mov    %eax,%esi
  801c1c:	89 e8                	mov    %ebp,%eax
  801c1e:	89 f7                	mov    %esi,%edi
  801c20:	f7 f1                	div    %ecx
  801c22:	89 fa                	mov    %edi,%edx
  801c24:	83 c4 1c             	add    $0x1c,%esp
  801c27:	5b                   	pop    %ebx
  801c28:	5e                   	pop    %esi
  801c29:	5f                   	pop    %edi
  801c2a:	5d                   	pop    %ebp
  801c2b:	c3                   	ret    
  801c2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c30:	39 f2                	cmp    %esi,%edx
  801c32:	77 7c                	ja     801cb0 <__udivdi3+0xd0>
  801c34:	0f bd fa             	bsr    %edx,%edi
  801c37:	83 f7 1f             	xor    $0x1f,%edi
  801c3a:	0f 84 98 00 00 00    	je     801cd8 <__udivdi3+0xf8>
  801c40:	89 f9                	mov    %edi,%ecx
  801c42:	b8 20 00 00 00       	mov    $0x20,%eax
  801c47:	29 f8                	sub    %edi,%eax
  801c49:	d3 e2                	shl    %cl,%edx
  801c4b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c4f:	89 c1                	mov    %eax,%ecx
  801c51:	89 da                	mov    %ebx,%edx
  801c53:	d3 ea                	shr    %cl,%edx
  801c55:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801c59:	09 d1                	or     %edx,%ecx
  801c5b:	89 f2                	mov    %esi,%edx
  801c5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c61:	89 f9                	mov    %edi,%ecx
  801c63:	d3 e3                	shl    %cl,%ebx
  801c65:	89 c1                	mov    %eax,%ecx
  801c67:	d3 ea                	shr    %cl,%edx
  801c69:	89 f9                	mov    %edi,%ecx
  801c6b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c6f:	d3 e6                	shl    %cl,%esi
  801c71:	89 eb                	mov    %ebp,%ebx
  801c73:	89 c1                	mov    %eax,%ecx
  801c75:	d3 eb                	shr    %cl,%ebx
  801c77:	09 de                	or     %ebx,%esi
  801c79:	89 f0                	mov    %esi,%eax
  801c7b:	f7 74 24 08          	divl   0x8(%esp)
  801c7f:	89 d6                	mov    %edx,%esi
  801c81:	89 c3                	mov    %eax,%ebx
  801c83:	f7 64 24 0c          	mull   0xc(%esp)
  801c87:	39 d6                	cmp    %edx,%esi
  801c89:	72 0c                	jb     801c97 <__udivdi3+0xb7>
  801c8b:	89 f9                	mov    %edi,%ecx
  801c8d:	d3 e5                	shl    %cl,%ebp
  801c8f:	39 c5                	cmp    %eax,%ebp
  801c91:	73 5d                	jae    801cf0 <__udivdi3+0x110>
  801c93:	39 d6                	cmp    %edx,%esi
  801c95:	75 59                	jne    801cf0 <__udivdi3+0x110>
  801c97:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801c9a:	31 ff                	xor    %edi,%edi
  801c9c:	89 fa                	mov    %edi,%edx
  801c9e:	83 c4 1c             	add    $0x1c,%esp
  801ca1:	5b                   	pop    %ebx
  801ca2:	5e                   	pop    %esi
  801ca3:	5f                   	pop    %edi
  801ca4:	5d                   	pop    %ebp
  801ca5:	c3                   	ret    
  801ca6:	8d 76 00             	lea    0x0(%esi),%esi
  801ca9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801cb0:	31 ff                	xor    %edi,%edi
  801cb2:	31 c0                	xor    %eax,%eax
  801cb4:	89 fa                	mov    %edi,%edx
  801cb6:	83 c4 1c             	add    $0x1c,%esp
  801cb9:	5b                   	pop    %ebx
  801cba:	5e                   	pop    %esi
  801cbb:	5f                   	pop    %edi
  801cbc:	5d                   	pop    %ebp
  801cbd:	c3                   	ret    
  801cbe:	66 90                	xchg   %ax,%ax
  801cc0:	31 ff                	xor    %edi,%edi
  801cc2:	89 e8                	mov    %ebp,%eax
  801cc4:	89 f2                	mov    %esi,%edx
  801cc6:	f7 f3                	div    %ebx
  801cc8:	89 fa                	mov    %edi,%edx
  801cca:	83 c4 1c             	add    $0x1c,%esp
  801ccd:	5b                   	pop    %ebx
  801cce:	5e                   	pop    %esi
  801ccf:	5f                   	pop    %edi
  801cd0:	5d                   	pop    %ebp
  801cd1:	c3                   	ret    
  801cd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cd8:	39 f2                	cmp    %esi,%edx
  801cda:	72 06                	jb     801ce2 <__udivdi3+0x102>
  801cdc:	31 c0                	xor    %eax,%eax
  801cde:	39 eb                	cmp    %ebp,%ebx
  801ce0:	77 d2                	ja     801cb4 <__udivdi3+0xd4>
  801ce2:	b8 01 00 00 00       	mov    $0x1,%eax
  801ce7:	eb cb                	jmp    801cb4 <__udivdi3+0xd4>
  801ce9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cf0:	89 d8                	mov    %ebx,%eax
  801cf2:	31 ff                	xor    %edi,%edi
  801cf4:	eb be                	jmp    801cb4 <__udivdi3+0xd4>
  801cf6:	66 90                	xchg   %ax,%ax
  801cf8:	66 90                	xchg   %ax,%ax
  801cfa:	66 90                	xchg   %ax,%ax
  801cfc:	66 90                	xchg   %ax,%ax
  801cfe:	66 90                	xchg   %ax,%ax

00801d00 <__umoddi3>:
  801d00:	55                   	push   %ebp
  801d01:	57                   	push   %edi
  801d02:	56                   	push   %esi
  801d03:	53                   	push   %ebx
  801d04:	83 ec 1c             	sub    $0x1c,%esp
  801d07:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801d0b:	8b 74 24 30          	mov    0x30(%esp),%esi
  801d0f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801d13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d17:	85 ed                	test   %ebp,%ebp
  801d19:	89 f0                	mov    %esi,%eax
  801d1b:	89 da                	mov    %ebx,%edx
  801d1d:	75 19                	jne    801d38 <__umoddi3+0x38>
  801d1f:	39 df                	cmp    %ebx,%edi
  801d21:	0f 86 b1 00 00 00    	jbe    801dd8 <__umoddi3+0xd8>
  801d27:	f7 f7                	div    %edi
  801d29:	89 d0                	mov    %edx,%eax
  801d2b:	31 d2                	xor    %edx,%edx
  801d2d:	83 c4 1c             	add    $0x1c,%esp
  801d30:	5b                   	pop    %ebx
  801d31:	5e                   	pop    %esi
  801d32:	5f                   	pop    %edi
  801d33:	5d                   	pop    %ebp
  801d34:	c3                   	ret    
  801d35:	8d 76 00             	lea    0x0(%esi),%esi
  801d38:	39 dd                	cmp    %ebx,%ebp
  801d3a:	77 f1                	ja     801d2d <__umoddi3+0x2d>
  801d3c:	0f bd cd             	bsr    %ebp,%ecx
  801d3f:	83 f1 1f             	xor    $0x1f,%ecx
  801d42:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801d46:	0f 84 b4 00 00 00    	je     801e00 <__umoddi3+0x100>
  801d4c:	b8 20 00 00 00       	mov    $0x20,%eax
  801d51:	89 c2                	mov    %eax,%edx
  801d53:	8b 44 24 04          	mov    0x4(%esp),%eax
  801d57:	29 c2                	sub    %eax,%edx
  801d59:	89 c1                	mov    %eax,%ecx
  801d5b:	89 f8                	mov    %edi,%eax
  801d5d:	d3 e5                	shl    %cl,%ebp
  801d5f:	89 d1                	mov    %edx,%ecx
  801d61:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801d65:	d3 e8                	shr    %cl,%eax
  801d67:	09 c5                	or     %eax,%ebp
  801d69:	8b 44 24 04          	mov    0x4(%esp),%eax
  801d6d:	89 c1                	mov    %eax,%ecx
  801d6f:	d3 e7                	shl    %cl,%edi
  801d71:	89 d1                	mov    %edx,%ecx
  801d73:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801d77:	89 df                	mov    %ebx,%edi
  801d79:	d3 ef                	shr    %cl,%edi
  801d7b:	89 c1                	mov    %eax,%ecx
  801d7d:	89 f0                	mov    %esi,%eax
  801d7f:	d3 e3                	shl    %cl,%ebx
  801d81:	89 d1                	mov    %edx,%ecx
  801d83:	89 fa                	mov    %edi,%edx
  801d85:	d3 e8                	shr    %cl,%eax
  801d87:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801d8c:	09 d8                	or     %ebx,%eax
  801d8e:	f7 f5                	div    %ebp
  801d90:	d3 e6                	shl    %cl,%esi
  801d92:	89 d1                	mov    %edx,%ecx
  801d94:	f7 64 24 08          	mull   0x8(%esp)
  801d98:	39 d1                	cmp    %edx,%ecx
  801d9a:	89 c3                	mov    %eax,%ebx
  801d9c:	89 d7                	mov    %edx,%edi
  801d9e:	72 06                	jb     801da6 <__umoddi3+0xa6>
  801da0:	75 0e                	jne    801db0 <__umoddi3+0xb0>
  801da2:	39 c6                	cmp    %eax,%esi
  801da4:	73 0a                	jae    801db0 <__umoddi3+0xb0>
  801da6:	2b 44 24 08          	sub    0x8(%esp),%eax
  801daa:	19 ea                	sbb    %ebp,%edx
  801dac:	89 d7                	mov    %edx,%edi
  801dae:	89 c3                	mov    %eax,%ebx
  801db0:	89 ca                	mov    %ecx,%edx
  801db2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801db7:	29 de                	sub    %ebx,%esi
  801db9:	19 fa                	sbb    %edi,%edx
  801dbb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  801dbf:	89 d0                	mov    %edx,%eax
  801dc1:	d3 e0                	shl    %cl,%eax
  801dc3:	89 d9                	mov    %ebx,%ecx
  801dc5:	d3 ee                	shr    %cl,%esi
  801dc7:	d3 ea                	shr    %cl,%edx
  801dc9:	09 f0                	or     %esi,%eax
  801dcb:	83 c4 1c             	add    $0x1c,%esp
  801dce:	5b                   	pop    %ebx
  801dcf:	5e                   	pop    %esi
  801dd0:	5f                   	pop    %edi
  801dd1:	5d                   	pop    %ebp
  801dd2:	c3                   	ret    
  801dd3:	90                   	nop
  801dd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801dd8:	85 ff                	test   %edi,%edi
  801dda:	89 f9                	mov    %edi,%ecx
  801ddc:	75 0b                	jne    801de9 <__umoddi3+0xe9>
  801dde:	b8 01 00 00 00       	mov    $0x1,%eax
  801de3:	31 d2                	xor    %edx,%edx
  801de5:	f7 f7                	div    %edi
  801de7:	89 c1                	mov    %eax,%ecx
  801de9:	89 d8                	mov    %ebx,%eax
  801deb:	31 d2                	xor    %edx,%edx
  801ded:	f7 f1                	div    %ecx
  801def:	89 f0                	mov    %esi,%eax
  801df1:	f7 f1                	div    %ecx
  801df3:	e9 31 ff ff ff       	jmp    801d29 <__umoddi3+0x29>
  801df8:	90                   	nop
  801df9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e00:	39 dd                	cmp    %ebx,%ebp
  801e02:	72 08                	jb     801e0c <__umoddi3+0x10c>
  801e04:	39 f7                	cmp    %esi,%edi
  801e06:	0f 87 21 ff ff ff    	ja     801d2d <__umoddi3+0x2d>
  801e0c:	89 da                	mov    %ebx,%edx
  801e0e:	89 f0                	mov    %esi,%eax
  801e10:	29 f8                	sub    %edi,%eax
  801e12:	19 ea                	sbb    %ebp,%edx
  801e14:	e9 14 ff ff ff       	jmp    801d2d <__umoddi3+0x2d>
