
obj/user/faultread.debug:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
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
	cprintf("I read %08x from location 0!\n", *(unsigned*)0);
  800039:	ff 35 00 00 00 00    	pushl  0x0
  80003f:	68 e0 1d 80 00       	push   $0x801de0
  800044:	e8 fa 00 00 00       	call   800143 <cprintf>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800059:	e8 bf 0a 00 00       	call   800b1d <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x2d>
		binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	e8 ae ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800085:	e8 0a 00 00 00       	call   800094 <exit>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800090:	5b                   	pop    %ebx
  800091:	5e                   	pop    %esi
  800092:	5d                   	pop    %ebp
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80009a:	e8 83 0e 00 00       	call   800f22 <close_all>
	sys_env_destroy(0);
  80009f:	83 ec 0c             	sub    $0xc,%esp
  8000a2:	6a 00                	push   $0x0
  8000a4:	e8 33 0a 00 00       	call   800adc <sys_env_destroy>
}
  8000a9:	83 c4 10             	add    $0x10,%esp
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    

008000ae <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000ae:	55                   	push   %ebp
  8000af:	89 e5                	mov    %esp,%ebp
  8000b1:	53                   	push   %ebx
  8000b2:	83 ec 04             	sub    $0x4,%esp
  8000b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000b8:	8b 13                	mov    (%ebx),%edx
  8000ba:	8d 42 01             	lea    0x1(%edx),%eax
  8000bd:	89 03                	mov    %eax,(%ebx)
  8000bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000c2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000c6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000cb:	74 09                	je     8000d6 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000cd:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000d4:	c9                   	leave  
  8000d5:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000d6:	83 ec 08             	sub    $0x8,%esp
  8000d9:	68 ff 00 00 00       	push   $0xff
  8000de:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e1:	50                   	push   %eax
  8000e2:	e8 b8 09 00 00       	call   800a9f <sys_cputs>
		b->idx = 0;
  8000e7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000ed:	83 c4 10             	add    $0x10,%esp
  8000f0:	eb db                	jmp    8000cd <putch+0x1f>

008000f2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000f2:	55                   	push   %ebp
  8000f3:	89 e5                	mov    %esp,%ebp
  8000f5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000fb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800102:	00 00 00 
	b.cnt = 0;
  800105:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80010c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80010f:	ff 75 0c             	pushl  0xc(%ebp)
  800112:	ff 75 08             	pushl  0x8(%ebp)
  800115:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80011b:	50                   	push   %eax
  80011c:	68 ae 00 80 00       	push   $0x8000ae
  800121:	e8 1a 01 00 00       	call   800240 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800126:	83 c4 08             	add    $0x8,%esp
  800129:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80012f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800135:	50                   	push   %eax
  800136:	e8 64 09 00 00       	call   800a9f <sys_cputs>

	return b.cnt;
}
  80013b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800141:	c9                   	leave  
  800142:	c3                   	ret    

00800143 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800149:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80014c:	50                   	push   %eax
  80014d:	ff 75 08             	pushl  0x8(%ebp)
  800150:	e8 9d ff ff ff       	call   8000f2 <vcprintf>
	va_end(ap);

	return cnt;
}
  800155:	c9                   	leave  
  800156:	c3                   	ret    

00800157 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	57                   	push   %edi
  80015b:	56                   	push   %esi
  80015c:	53                   	push   %ebx
  80015d:	83 ec 1c             	sub    $0x1c,%esp
  800160:	89 c7                	mov    %eax,%edi
  800162:	89 d6                	mov    %edx,%esi
  800164:	8b 45 08             	mov    0x8(%ebp),%eax
  800167:	8b 55 0c             	mov    0xc(%ebp),%edx
  80016a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80016d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800170:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800173:	bb 00 00 00 00       	mov    $0x0,%ebx
  800178:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80017b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80017e:	39 d3                	cmp    %edx,%ebx
  800180:	72 05                	jb     800187 <printnum+0x30>
  800182:	39 45 10             	cmp    %eax,0x10(%ebp)
  800185:	77 7a                	ja     800201 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	ff 75 18             	pushl  0x18(%ebp)
  80018d:	8b 45 14             	mov    0x14(%ebp),%eax
  800190:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800193:	53                   	push   %ebx
  800194:	ff 75 10             	pushl  0x10(%ebp)
  800197:	83 ec 08             	sub    $0x8,%esp
  80019a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80019d:	ff 75 e0             	pushl  -0x20(%ebp)
  8001a0:	ff 75 dc             	pushl  -0x24(%ebp)
  8001a3:	ff 75 d8             	pushl  -0x28(%ebp)
  8001a6:	e8 e5 19 00 00       	call   801b90 <__udivdi3>
  8001ab:	83 c4 18             	add    $0x18,%esp
  8001ae:	52                   	push   %edx
  8001af:	50                   	push   %eax
  8001b0:	89 f2                	mov    %esi,%edx
  8001b2:	89 f8                	mov    %edi,%eax
  8001b4:	e8 9e ff ff ff       	call   800157 <printnum>
  8001b9:	83 c4 20             	add    $0x20,%esp
  8001bc:	eb 13                	jmp    8001d1 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001be:	83 ec 08             	sub    $0x8,%esp
  8001c1:	56                   	push   %esi
  8001c2:	ff 75 18             	pushl  0x18(%ebp)
  8001c5:	ff d7                	call   *%edi
  8001c7:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001ca:	83 eb 01             	sub    $0x1,%ebx
  8001cd:	85 db                	test   %ebx,%ebx
  8001cf:	7f ed                	jg     8001be <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001d1:	83 ec 08             	sub    $0x8,%esp
  8001d4:	56                   	push   %esi
  8001d5:	83 ec 04             	sub    $0x4,%esp
  8001d8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001db:	ff 75 e0             	pushl  -0x20(%ebp)
  8001de:	ff 75 dc             	pushl  -0x24(%ebp)
  8001e1:	ff 75 d8             	pushl  -0x28(%ebp)
  8001e4:	e8 c7 1a 00 00       	call   801cb0 <__umoddi3>
  8001e9:	83 c4 14             	add    $0x14,%esp
  8001ec:	0f be 80 08 1e 80 00 	movsbl 0x801e08(%eax),%eax
  8001f3:	50                   	push   %eax
  8001f4:	ff d7                	call   *%edi
}
  8001f6:	83 c4 10             	add    $0x10,%esp
  8001f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001fc:	5b                   	pop    %ebx
  8001fd:	5e                   	pop    %esi
  8001fe:	5f                   	pop    %edi
  8001ff:	5d                   	pop    %ebp
  800200:	c3                   	ret    
  800201:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800204:	eb c4                	jmp    8001ca <printnum+0x73>

00800206 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800206:	55                   	push   %ebp
  800207:	89 e5                	mov    %esp,%ebp
  800209:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80020c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800210:	8b 10                	mov    (%eax),%edx
  800212:	3b 50 04             	cmp    0x4(%eax),%edx
  800215:	73 0a                	jae    800221 <sprintputch+0x1b>
		*b->buf++ = ch;
  800217:	8d 4a 01             	lea    0x1(%edx),%ecx
  80021a:	89 08                	mov    %ecx,(%eax)
  80021c:	8b 45 08             	mov    0x8(%ebp),%eax
  80021f:	88 02                	mov    %al,(%edx)
}
  800221:	5d                   	pop    %ebp
  800222:	c3                   	ret    

00800223 <printfmt>:
{
  800223:	55                   	push   %ebp
  800224:	89 e5                	mov    %esp,%ebp
  800226:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800229:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80022c:	50                   	push   %eax
  80022d:	ff 75 10             	pushl  0x10(%ebp)
  800230:	ff 75 0c             	pushl  0xc(%ebp)
  800233:	ff 75 08             	pushl  0x8(%ebp)
  800236:	e8 05 00 00 00       	call   800240 <vprintfmt>
}
  80023b:	83 c4 10             	add    $0x10,%esp
  80023e:	c9                   	leave  
  80023f:	c3                   	ret    

00800240 <vprintfmt>:
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	57                   	push   %edi
  800244:	56                   	push   %esi
  800245:	53                   	push   %ebx
  800246:	83 ec 2c             	sub    $0x2c,%esp
  800249:	8b 75 08             	mov    0x8(%ebp),%esi
  80024c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80024f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800252:	e9 c1 03 00 00       	jmp    800618 <vprintfmt+0x3d8>
		padc = ' ';
  800257:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  80025b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800262:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800269:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800270:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800275:	8d 47 01             	lea    0x1(%edi),%eax
  800278:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80027b:	0f b6 17             	movzbl (%edi),%edx
  80027e:	8d 42 dd             	lea    -0x23(%edx),%eax
  800281:	3c 55                	cmp    $0x55,%al
  800283:	0f 87 12 04 00 00    	ja     80069b <vprintfmt+0x45b>
  800289:	0f b6 c0             	movzbl %al,%eax
  80028c:	ff 24 85 40 1f 80 00 	jmp    *0x801f40(,%eax,4)
  800293:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800296:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80029a:	eb d9                	jmp    800275 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80029c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80029f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002a3:	eb d0                	jmp    800275 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8002a5:	0f b6 d2             	movzbl %dl,%edx
  8002a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8002b0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002b3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002b6:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002ba:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002bd:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002c0:	83 f9 09             	cmp    $0x9,%ecx
  8002c3:	77 55                	ja     80031a <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  8002c5:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8002c8:	eb e9                	jmp    8002b3 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  8002ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8002cd:	8b 00                	mov    (%eax),%eax
  8002cf:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8002d5:	8d 40 04             	lea    0x4(%eax),%eax
  8002d8:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8002db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8002de:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8002e2:	79 91                	jns    800275 <vprintfmt+0x35>
				width = precision, precision = -1;
  8002e4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8002e7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002ea:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002f1:	eb 82                	jmp    800275 <vprintfmt+0x35>
  8002f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002f6:	85 c0                	test   %eax,%eax
  8002f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8002fd:	0f 49 d0             	cmovns %eax,%edx
  800300:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800303:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800306:	e9 6a ff ff ff       	jmp    800275 <vprintfmt+0x35>
  80030b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80030e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800315:	e9 5b ff ff ff       	jmp    800275 <vprintfmt+0x35>
  80031a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80031d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800320:	eb bc                	jmp    8002de <vprintfmt+0x9e>
			lflag++;
  800322:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800325:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800328:	e9 48 ff ff ff       	jmp    800275 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  80032d:	8b 45 14             	mov    0x14(%ebp),%eax
  800330:	8d 78 04             	lea    0x4(%eax),%edi
  800333:	83 ec 08             	sub    $0x8,%esp
  800336:	53                   	push   %ebx
  800337:	ff 30                	pushl  (%eax)
  800339:	ff d6                	call   *%esi
			break;
  80033b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80033e:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800341:	e9 cf 02 00 00       	jmp    800615 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  800346:	8b 45 14             	mov    0x14(%ebp),%eax
  800349:	8d 78 04             	lea    0x4(%eax),%edi
  80034c:	8b 00                	mov    (%eax),%eax
  80034e:	99                   	cltd   
  80034f:	31 d0                	xor    %edx,%eax
  800351:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800353:	83 f8 0f             	cmp    $0xf,%eax
  800356:	7f 23                	jg     80037b <vprintfmt+0x13b>
  800358:	8b 14 85 a0 20 80 00 	mov    0x8020a0(,%eax,4),%edx
  80035f:	85 d2                	test   %edx,%edx
  800361:	74 18                	je     80037b <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800363:	52                   	push   %edx
  800364:	68 d1 21 80 00       	push   $0x8021d1
  800369:	53                   	push   %ebx
  80036a:	56                   	push   %esi
  80036b:	e8 b3 fe ff ff       	call   800223 <printfmt>
  800370:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800373:	89 7d 14             	mov    %edi,0x14(%ebp)
  800376:	e9 9a 02 00 00       	jmp    800615 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  80037b:	50                   	push   %eax
  80037c:	68 20 1e 80 00       	push   $0x801e20
  800381:	53                   	push   %ebx
  800382:	56                   	push   %esi
  800383:	e8 9b fe ff ff       	call   800223 <printfmt>
  800388:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80038b:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80038e:	e9 82 02 00 00       	jmp    800615 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  800393:	8b 45 14             	mov    0x14(%ebp),%eax
  800396:	83 c0 04             	add    $0x4,%eax
  800399:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80039c:	8b 45 14             	mov    0x14(%ebp),%eax
  80039f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003a1:	85 ff                	test   %edi,%edi
  8003a3:	b8 19 1e 80 00       	mov    $0x801e19,%eax
  8003a8:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8003ab:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003af:	0f 8e bd 00 00 00    	jle    800472 <vprintfmt+0x232>
  8003b5:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8003b9:	75 0e                	jne    8003c9 <vprintfmt+0x189>
  8003bb:	89 75 08             	mov    %esi,0x8(%ebp)
  8003be:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8003c1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8003c4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8003c7:	eb 6d                	jmp    800436 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003c9:	83 ec 08             	sub    $0x8,%esp
  8003cc:	ff 75 d0             	pushl  -0x30(%ebp)
  8003cf:	57                   	push   %edi
  8003d0:	e8 6e 03 00 00       	call   800743 <strnlen>
  8003d5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003d8:	29 c1                	sub    %eax,%ecx
  8003da:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8003dd:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8003e0:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8003e4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003e7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8003ea:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8003ec:	eb 0f                	jmp    8003fd <vprintfmt+0x1bd>
					putch(padc, putdat);
  8003ee:	83 ec 08             	sub    $0x8,%esp
  8003f1:	53                   	push   %ebx
  8003f2:	ff 75 e0             	pushl  -0x20(%ebp)
  8003f5:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8003f7:	83 ef 01             	sub    $0x1,%edi
  8003fa:	83 c4 10             	add    $0x10,%esp
  8003fd:	85 ff                	test   %edi,%edi
  8003ff:	7f ed                	jg     8003ee <vprintfmt+0x1ae>
  800401:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800404:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800407:	85 c9                	test   %ecx,%ecx
  800409:	b8 00 00 00 00       	mov    $0x0,%eax
  80040e:	0f 49 c1             	cmovns %ecx,%eax
  800411:	29 c1                	sub    %eax,%ecx
  800413:	89 75 08             	mov    %esi,0x8(%ebp)
  800416:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800419:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80041c:	89 cb                	mov    %ecx,%ebx
  80041e:	eb 16                	jmp    800436 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  800420:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800424:	75 31                	jne    800457 <vprintfmt+0x217>
					putch(ch, putdat);
  800426:	83 ec 08             	sub    $0x8,%esp
  800429:	ff 75 0c             	pushl  0xc(%ebp)
  80042c:	50                   	push   %eax
  80042d:	ff 55 08             	call   *0x8(%ebp)
  800430:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800433:	83 eb 01             	sub    $0x1,%ebx
  800436:	83 c7 01             	add    $0x1,%edi
  800439:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  80043d:	0f be c2             	movsbl %dl,%eax
  800440:	85 c0                	test   %eax,%eax
  800442:	74 59                	je     80049d <vprintfmt+0x25d>
  800444:	85 f6                	test   %esi,%esi
  800446:	78 d8                	js     800420 <vprintfmt+0x1e0>
  800448:	83 ee 01             	sub    $0x1,%esi
  80044b:	79 d3                	jns    800420 <vprintfmt+0x1e0>
  80044d:	89 df                	mov    %ebx,%edi
  80044f:	8b 75 08             	mov    0x8(%ebp),%esi
  800452:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800455:	eb 37                	jmp    80048e <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  800457:	0f be d2             	movsbl %dl,%edx
  80045a:	83 ea 20             	sub    $0x20,%edx
  80045d:	83 fa 5e             	cmp    $0x5e,%edx
  800460:	76 c4                	jbe    800426 <vprintfmt+0x1e6>
					putch('?', putdat);
  800462:	83 ec 08             	sub    $0x8,%esp
  800465:	ff 75 0c             	pushl  0xc(%ebp)
  800468:	6a 3f                	push   $0x3f
  80046a:	ff 55 08             	call   *0x8(%ebp)
  80046d:	83 c4 10             	add    $0x10,%esp
  800470:	eb c1                	jmp    800433 <vprintfmt+0x1f3>
  800472:	89 75 08             	mov    %esi,0x8(%ebp)
  800475:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800478:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80047b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80047e:	eb b6                	jmp    800436 <vprintfmt+0x1f6>
				putch(' ', putdat);
  800480:	83 ec 08             	sub    $0x8,%esp
  800483:	53                   	push   %ebx
  800484:	6a 20                	push   $0x20
  800486:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800488:	83 ef 01             	sub    $0x1,%edi
  80048b:	83 c4 10             	add    $0x10,%esp
  80048e:	85 ff                	test   %edi,%edi
  800490:	7f ee                	jg     800480 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800492:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800495:	89 45 14             	mov    %eax,0x14(%ebp)
  800498:	e9 78 01 00 00       	jmp    800615 <vprintfmt+0x3d5>
  80049d:	89 df                	mov    %ebx,%edi
  80049f:	8b 75 08             	mov    0x8(%ebp),%esi
  8004a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004a5:	eb e7                	jmp    80048e <vprintfmt+0x24e>
	if (lflag >= 2)
  8004a7:	83 f9 01             	cmp    $0x1,%ecx
  8004aa:	7e 3f                	jle    8004eb <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  8004ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8004af:	8b 50 04             	mov    0x4(%eax),%edx
  8004b2:	8b 00                	mov    (%eax),%eax
  8004b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004b7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bd:	8d 40 08             	lea    0x8(%eax),%eax
  8004c0:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8004c3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004c7:	79 5c                	jns    800525 <vprintfmt+0x2e5>
				putch('-', putdat);
  8004c9:	83 ec 08             	sub    $0x8,%esp
  8004cc:	53                   	push   %ebx
  8004cd:	6a 2d                	push   $0x2d
  8004cf:	ff d6                	call   *%esi
				num = -(long long) num;
  8004d1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004d4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004d7:	f7 da                	neg    %edx
  8004d9:	83 d1 00             	adc    $0x0,%ecx
  8004dc:	f7 d9                	neg    %ecx
  8004de:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8004e1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8004e6:	e9 10 01 00 00       	jmp    8005fb <vprintfmt+0x3bb>
	else if (lflag)
  8004eb:	85 c9                	test   %ecx,%ecx
  8004ed:	75 1b                	jne    80050a <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8004ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f2:	8b 00                	mov    (%eax),%eax
  8004f4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004f7:	89 c1                	mov    %eax,%ecx
  8004f9:	c1 f9 1f             	sar    $0x1f,%ecx
  8004fc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800502:	8d 40 04             	lea    0x4(%eax),%eax
  800505:	89 45 14             	mov    %eax,0x14(%ebp)
  800508:	eb b9                	jmp    8004c3 <vprintfmt+0x283>
		return va_arg(*ap, long);
  80050a:	8b 45 14             	mov    0x14(%ebp),%eax
  80050d:	8b 00                	mov    (%eax),%eax
  80050f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800512:	89 c1                	mov    %eax,%ecx
  800514:	c1 f9 1f             	sar    $0x1f,%ecx
  800517:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80051a:	8b 45 14             	mov    0x14(%ebp),%eax
  80051d:	8d 40 04             	lea    0x4(%eax),%eax
  800520:	89 45 14             	mov    %eax,0x14(%ebp)
  800523:	eb 9e                	jmp    8004c3 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  800525:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800528:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80052b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800530:	e9 c6 00 00 00       	jmp    8005fb <vprintfmt+0x3bb>
	if (lflag >= 2)
  800535:	83 f9 01             	cmp    $0x1,%ecx
  800538:	7e 18                	jle    800552 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  80053a:	8b 45 14             	mov    0x14(%ebp),%eax
  80053d:	8b 10                	mov    (%eax),%edx
  80053f:	8b 48 04             	mov    0x4(%eax),%ecx
  800542:	8d 40 08             	lea    0x8(%eax),%eax
  800545:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800548:	b8 0a 00 00 00       	mov    $0xa,%eax
  80054d:	e9 a9 00 00 00       	jmp    8005fb <vprintfmt+0x3bb>
	else if (lflag)
  800552:	85 c9                	test   %ecx,%ecx
  800554:	75 1a                	jne    800570 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  800556:	8b 45 14             	mov    0x14(%ebp),%eax
  800559:	8b 10                	mov    (%eax),%edx
  80055b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800560:	8d 40 04             	lea    0x4(%eax),%eax
  800563:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800566:	b8 0a 00 00 00       	mov    $0xa,%eax
  80056b:	e9 8b 00 00 00       	jmp    8005fb <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800570:	8b 45 14             	mov    0x14(%ebp),%eax
  800573:	8b 10                	mov    (%eax),%edx
  800575:	b9 00 00 00 00       	mov    $0x0,%ecx
  80057a:	8d 40 04             	lea    0x4(%eax),%eax
  80057d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800580:	b8 0a 00 00 00       	mov    $0xa,%eax
  800585:	eb 74                	jmp    8005fb <vprintfmt+0x3bb>
	if (lflag >= 2)
  800587:	83 f9 01             	cmp    $0x1,%ecx
  80058a:	7e 15                	jle    8005a1 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  80058c:	8b 45 14             	mov    0x14(%ebp),%eax
  80058f:	8b 10                	mov    (%eax),%edx
  800591:	8b 48 04             	mov    0x4(%eax),%ecx
  800594:	8d 40 08             	lea    0x8(%eax),%eax
  800597:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80059a:	b8 08 00 00 00       	mov    $0x8,%eax
  80059f:	eb 5a                	jmp    8005fb <vprintfmt+0x3bb>
	else if (lflag)
  8005a1:	85 c9                	test   %ecx,%ecx
  8005a3:	75 17                	jne    8005bc <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  8005a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a8:	8b 10                	mov    (%eax),%edx
  8005aa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005af:	8d 40 04             	lea    0x4(%eax),%eax
  8005b2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8005b5:	b8 08 00 00 00       	mov    $0x8,%eax
  8005ba:	eb 3f                	jmp    8005fb <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8005bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bf:	8b 10                	mov    (%eax),%edx
  8005c1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005c6:	8d 40 04             	lea    0x4(%eax),%eax
  8005c9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8005cc:	b8 08 00 00 00       	mov    $0x8,%eax
  8005d1:	eb 28                	jmp    8005fb <vprintfmt+0x3bb>
			putch('0', putdat);
  8005d3:	83 ec 08             	sub    $0x8,%esp
  8005d6:	53                   	push   %ebx
  8005d7:	6a 30                	push   $0x30
  8005d9:	ff d6                	call   *%esi
			putch('x', putdat);
  8005db:	83 c4 08             	add    $0x8,%esp
  8005de:	53                   	push   %ebx
  8005df:	6a 78                	push   $0x78
  8005e1:	ff d6                	call   *%esi
			num = (unsigned long long)
  8005e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e6:	8b 10                	mov    (%eax),%edx
  8005e8:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8005ed:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8005f0:	8d 40 04             	lea    0x4(%eax),%eax
  8005f3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8005f6:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8005fb:	83 ec 0c             	sub    $0xc,%esp
  8005fe:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800602:	57                   	push   %edi
  800603:	ff 75 e0             	pushl  -0x20(%ebp)
  800606:	50                   	push   %eax
  800607:	51                   	push   %ecx
  800608:	52                   	push   %edx
  800609:	89 da                	mov    %ebx,%edx
  80060b:	89 f0                	mov    %esi,%eax
  80060d:	e8 45 fb ff ff       	call   800157 <printnum>
			break;
  800612:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800615:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800618:	83 c7 01             	add    $0x1,%edi
  80061b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80061f:	83 f8 25             	cmp    $0x25,%eax
  800622:	0f 84 2f fc ff ff    	je     800257 <vprintfmt+0x17>
			if (ch == '\0')
  800628:	85 c0                	test   %eax,%eax
  80062a:	0f 84 8b 00 00 00    	je     8006bb <vprintfmt+0x47b>
			putch(ch, putdat);
  800630:	83 ec 08             	sub    $0x8,%esp
  800633:	53                   	push   %ebx
  800634:	50                   	push   %eax
  800635:	ff d6                	call   *%esi
  800637:	83 c4 10             	add    $0x10,%esp
  80063a:	eb dc                	jmp    800618 <vprintfmt+0x3d8>
	if (lflag >= 2)
  80063c:	83 f9 01             	cmp    $0x1,%ecx
  80063f:	7e 15                	jle    800656 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  800641:	8b 45 14             	mov    0x14(%ebp),%eax
  800644:	8b 10                	mov    (%eax),%edx
  800646:	8b 48 04             	mov    0x4(%eax),%ecx
  800649:	8d 40 08             	lea    0x8(%eax),%eax
  80064c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80064f:	b8 10 00 00 00       	mov    $0x10,%eax
  800654:	eb a5                	jmp    8005fb <vprintfmt+0x3bb>
	else if (lflag)
  800656:	85 c9                	test   %ecx,%ecx
  800658:	75 17                	jne    800671 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  80065a:	8b 45 14             	mov    0x14(%ebp),%eax
  80065d:	8b 10                	mov    (%eax),%edx
  80065f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800664:	8d 40 04             	lea    0x4(%eax),%eax
  800667:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80066a:	b8 10 00 00 00       	mov    $0x10,%eax
  80066f:	eb 8a                	jmp    8005fb <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800671:	8b 45 14             	mov    0x14(%ebp),%eax
  800674:	8b 10                	mov    (%eax),%edx
  800676:	b9 00 00 00 00       	mov    $0x0,%ecx
  80067b:	8d 40 04             	lea    0x4(%eax),%eax
  80067e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800681:	b8 10 00 00 00       	mov    $0x10,%eax
  800686:	e9 70 ff ff ff       	jmp    8005fb <vprintfmt+0x3bb>
			putch(ch, putdat);
  80068b:	83 ec 08             	sub    $0x8,%esp
  80068e:	53                   	push   %ebx
  80068f:	6a 25                	push   $0x25
  800691:	ff d6                	call   *%esi
			break;
  800693:	83 c4 10             	add    $0x10,%esp
  800696:	e9 7a ff ff ff       	jmp    800615 <vprintfmt+0x3d5>
			putch('%', putdat);
  80069b:	83 ec 08             	sub    $0x8,%esp
  80069e:	53                   	push   %ebx
  80069f:	6a 25                	push   $0x25
  8006a1:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006a3:	83 c4 10             	add    $0x10,%esp
  8006a6:	89 f8                	mov    %edi,%eax
  8006a8:	eb 03                	jmp    8006ad <vprintfmt+0x46d>
  8006aa:	83 e8 01             	sub    $0x1,%eax
  8006ad:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006b1:	75 f7                	jne    8006aa <vprintfmt+0x46a>
  8006b3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006b6:	e9 5a ff ff ff       	jmp    800615 <vprintfmt+0x3d5>
}
  8006bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006be:	5b                   	pop    %ebx
  8006bf:	5e                   	pop    %esi
  8006c0:	5f                   	pop    %edi
  8006c1:	5d                   	pop    %ebp
  8006c2:	c3                   	ret    

008006c3 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006c3:	55                   	push   %ebp
  8006c4:	89 e5                	mov    %esp,%ebp
  8006c6:	83 ec 18             	sub    $0x18,%esp
  8006c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006cf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006d2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006d6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006e0:	85 c0                	test   %eax,%eax
  8006e2:	74 26                	je     80070a <vsnprintf+0x47>
  8006e4:	85 d2                	test   %edx,%edx
  8006e6:	7e 22                	jle    80070a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006e8:	ff 75 14             	pushl  0x14(%ebp)
  8006eb:	ff 75 10             	pushl  0x10(%ebp)
  8006ee:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006f1:	50                   	push   %eax
  8006f2:	68 06 02 80 00       	push   $0x800206
  8006f7:	e8 44 fb ff ff       	call   800240 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006ff:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800702:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800705:	83 c4 10             	add    $0x10,%esp
}
  800708:	c9                   	leave  
  800709:	c3                   	ret    
		return -E_INVAL;
  80070a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80070f:	eb f7                	jmp    800708 <vsnprintf+0x45>

00800711 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800711:	55                   	push   %ebp
  800712:	89 e5                	mov    %esp,%ebp
  800714:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800717:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80071a:	50                   	push   %eax
  80071b:	ff 75 10             	pushl  0x10(%ebp)
  80071e:	ff 75 0c             	pushl  0xc(%ebp)
  800721:	ff 75 08             	pushl  0x8(%ebp)
  800724:	e8 9a ff ff ff       	call   8006c3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800729:	c9                   	leave  
  80072a:	c3                   	ret    

0080072b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80072b:	55                   	push   %ebp
  80072c:	89 e5                	mov    %esp,%ebp
  80072e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800731:	b8 00 00 00 00       	mov    $0x0,%eax
  800736:	eb 03                	jmp    80073b <strlen+0x10>
		n++;
  800738:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80073b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80073f:	75 f7                	jne    800738 <strlen+0xd>
	return n;
}
  800741:	5d                   	pop    %ebp
  800742:	c3                   	ret    

00800743 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800743:	55                   	push   %ebp
  800744:	89 e5                	mov    %esp,%ebp
  800746:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800749:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80074c:	b8 00 00 00 00       	mov    $0x0,%eax
  800751:	eb 03                	jmp    800756 <strnlen+0x13>
		n++;
  800753:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800756:	39 d0                	cmp    %edx,%eax
  800758:	74 06                	je     800760 <strnlen+0x1d>
  80075a:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80075e:	75 f3                	jne    800753 <strnlen+0x10>
	return n;
}
  800760:	5d                   	pop    %ebp
  800761:	c3                   	ret    

00800762 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800762:	55                   	push   %ebp
  800763:	89 e5                	mov    %esp,%ebp
  800765:	53                   	push   %ebx
  800766:	8b 45 08             	mov    0x8(%ebp),%eax
  800769:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80076c:	89 c2                	mov    %eax,%edx
  80076e:	83 c1 01             	add    $0x1,%ecx
  800771:	83 c2 01             	add    $0x1,%edx
  800774:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800778:	88 5a ff             	mov    %bl,-0x1(%edx)
  80077b:	84 db                	test   %bl,%bl
  80077d:	75 ef                	jne    80076e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80077f:	5b                   	pop    %ebx
  800780:	5d                   	pop    %ebp
  800781:	c3                   	ret    

00800782 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800782:	55                   	push   %ebp
  800783:	89 e5                	mov    %esp,%ebp
  800785:	53                   	push   %ebx
  800786:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800789:	53                   	push   %ebx
  80078a:	e8 9c ff ff ff       	call   80072b <strlen>
  80078f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800792:	ff 75 0c             	pushl  0xc(%ebp)
  800795:	01 d8                	add    %ebx,%eax
  800797:	50                   	push   %eax
  800798:	e8 c5 ff ff ff       	call   800762 <strcpy>
	return dst;
}
  80079d:	89 d8                	mov    %ebx,%eax
  80079f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007a2:	c9                   	leave  
  8007a3:	c3                   	ret    

008007a4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007a4:	55                   	push   %ebp
  8007a5:	89 e5                	mov    %esp,%ebp
  8007a7:	56                   	push   %esi
  8007a8:	53                   	push   %ebx
  8007a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007af:	89 f3                	mov    %esi,%ebx
  8007b1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007b4:	89 f2                	mov    %esi,%edx
  8007b6:	eb 0f                	jmp    8007c7 <strncpy+0x23>
		*dst++ = *src;
  8007b8:	83 c2 01             	add    $0x1,%edx
  8007bb:	0f b6 01             	movzbl (%ecx),%eax
  8007be:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007c1:	80 39 01             	cmpb   $0x1,(%ecx)
  8007c4:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8007c7:	39 da                	cmp    %ebx,%edx
  8007c9:	75 ed                	jne    8007b8 <strncpy+0x14>
	}
	return ret;
}
  8007cb:	89 f0                	mov    %esi,%eax
  8007cd:	5b                   	pop    %ebx
  8007ce:	5e                   	pop    %esi
  8007cf:	5d                   	pop    %ebp
  8007d0:	c3                   	ret    

008007d1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007d1:	55                   	push   %ebp
  8007d2:	89 e5                	mov    %esp,%ebp
  8007d4:	56                   	push   %esi
  8007d5:	53                   	push   %ebx
  8007d6:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007dc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8007df:	89 f0                	mov    %esi,%eax
  8007e1:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007e5:	85 c9                	test   %ecx,%ecx
  8007e7:	75 0b                	jne    8007f4 <strlcpy+0x23>
  8007e9:	eb 17                	jmp    800802 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007eb:	83 c2 01             	add    $0x1,%edx
  8007ee:	83 c0 01             	add    $0x1,%eax
  8007f1:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8007f4:	39 d8                	cmp    %ebx,%eax
  8007f6:	74 07                	je     8007ff <strlcpy+0x2e>
  8007f8:	0f b6 0a             	movzbl (%edx),%ecx
  8007fb:	84 c9                	test   %cl,%cl
  8007fd:	75 ec                	jne    8007eb <strlcpy+0x1a>
		*dst = '\0';
  8007ff:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800802:	29 f0                	sub    %esi,%eax
}
  800804:	5b                   	pop    %ebx
  800805:	5e                   	pop    %esi
  800806:	5d                   	pop    %ebp
  800807:	c3                   	ret    

00800808 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800808:	55                   	push   %ebp
  800809:	89 e5                	mov    %esp,%ebp
  80080b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80080e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800811:	eb 06                	jmp    800819 <strcmp+0x11>
		p++, q++;
  800813:	83 c1 01             	add    $0x1,%ecx
  800816:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800819:	0f b6 01             	movzbl (%ecx),%eax
  80081c:	84 c0                	test   %al,%al
  80081e:	74 04                	je     800824 <strcmp+0x1c>
  800820:	3a 02                	cmp    (%edx),%al
  800822:	74 ef                	je     800813 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800824:	0f b6 c0             	movzbl %al,%eax
  800827:	0f b6 12             	movzbl (%edx),%edx
  80082a:	29 d0                	sub    %edx,%eax
}
  80082c:	5d                   	pop    %ebp
  80082d:	c3                   	ret    

0080082e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80082e:	55                   	push   %ebp
  80082f:	89 e5                	mov    %esp,%ebp
  800831:	53                   	push   %ebx
  800832:	8b 45 08             	mov    0x8(%ebp),%eax
  800835:	8b 55 0c             	mov    0xc(%ebp),%edx
  800838:	89 c3                	mov    %eax,%ebx
  80083a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80083d:	eb 06                	jmp    800845 <strncmp+0x17>
		n--, p++, q++;
  80083f:	83 c0 01             	add    $0x1,%eax
  800842:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800845:	39 d8                	cmp    %ebx,%eax
  800847:	74 16                	je     80085f <strncmp+0x31>
  800849:	0f b6 08             	movzbl (%eax),%ecx
  80084c:	84 c9                	test   %cl,%cl
  80084e:	74 04                	je     800854 <strncmp+0x26>
  800850:	3a 0a                	cmp    (%edx),%cl
  800852:	74 eb                	je     80083f <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800854:	0f b6 00             	movzbl (%eax),%eax
  800857:	0f b6 12             	movzbl (%edx),%edx
  80085a:	29 d0                	sub    %edx,%eax
}
  80085c:	5b                   	pop    %ebx
  80085d:	5d                   	pop    %ebp
  80085e:	c3                   	ret    
		return 0;
  80085f:	b8 00 00 00 00       	mov    $0x0,%eax
  800864:	eb f6                	jmp    80085c <strncmp+0x2e>

00800866 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800866:	55                   	push   %ebp
  800867:	89 e5                	mov    %esp,%ebp
  800869:	8b 45 08             	mov    0x8(%ebp),%eax
  80086c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800870:	0f b6 10             	movzbl (%eax),%edx
  800873:	84 d2                	test   %dl,%dl
  800875:	74 09                	je     800880 <strchr+0x1a>
		if (*s == c)
  800877:	38 ca                	cmp    %cl,%dl
  800879:	74 0a                	je     800885 <strchr+0x1f>
	for (; *s; s++)
  80087b:	83 c0 01             	add    $0x1,%eax
  80087e:	eb f0                	jmp    800870 <strchr+0xa>
			return (char *) s;
	return 0;
  800880:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800885:	5d                   	pop    %ebp
  800886:	c3                   	ret    

00800887 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	8b 45 08             	mov    0x8(%ebp),%eax
  80088d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800891:	eb 03                	jmp    800896 <strfind+0xf>
  800893:	83 c0 01             	add    $0x1,%eax
  800896:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800899:	38 ca                	cmp    %cl,%dl
  80089b:	74 04                	je     8008a1 <strfind+0x1a>
  80089d:	84 d2                	test   %dl,%dl
  80089f:	75 f2                	jne    800893 <strfind+0xc>
			break;
	return (char *) s;
}
  8008a1:	5d                   	pop    %ebp
  8008a2:	c3                   	ret    

008008a3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	57                   	push   %edi
  8008a7:	56                   	push   %esi
  8008a8:	53                   	push   %ebx
  8008a9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ac:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008af:	85 c9                	test   %ecx,%ecx
  8008b1:	74 13                	je     8008c6 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008b3:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008b9:	75 05                	jne    8008c0 <memset+0x1d>
  8008bb:	f6 c1 03             	test   $0x3,%cl
  8008be:	74 0d                	je     8008cd <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c3:	fc                   	cld    
  8008c4:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008c6:	89 f8                	mov    %edi,%eax
  8008c8:	5b                   	pop    %ebx
  8008c9:	5e                   	pop    %esi
  8008ca:	5f                   	pop    %edi
  8008cb:	5d                   	pop    %ebp
  8008cc:	c3                   	ret    
		c &= 0xFF;
  8008cd:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008d1:	89 d3                	mov    %edx,%ebx
  8008d3:	c1 e3 08             	shl    $0x8,%ebx
  8008d6:	89 d0                	mov    %edx,%eax
  8008d8:	c1 e0 18             	shl    $0x18,%eax
  8008db:	89 d6                	mov    %edx,%esi
  8008dd:	c1 e6 10             	shl    $0x10,%esi
  8008e0:	09 f0                	or     %esi,%eax
  8008e2:	09 c2                	or     %eax,%edx
  8008e4:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  8008e6:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8008e9:	89 d0                	mov    %edx,%eax
  8008eb:	fc                   	cld    
  8008ec:	f3 ab                	rep stos %eax,%es:(%edi)
  8008ee:	eb d6                	jmp    8008c6 <memset+0x23>

008008f0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
  8008f3:	57                   	push   %edi
  8008f4:	56                   	push   %esi
  8008f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008fb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008fe:	39 c6                	cmp    %eax,%esi
  800900:	73 35                	jae    800937 <memmove+0x47>
  800902:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800905:	39 c2                	cmp    %eax,%edx
  800907:	76 2e                	jbe    800937 <memmove+0x47>
		s += n;
		d += n;
  800909:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80090c:	89 d6                	mov    %edx,%esi
  80090e:	09 fe                	or     %edi,%esi
  800910:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800916:	74 0c                	je     800924 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800918:	83 ef 01             	sub    $0x1,%edi
  80091b:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80091e:	fd                   	std    
  80091f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800921:	fc                   	cld    
  800922:	eb 21                	jmp    800945 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800924:	f6 c1 03             	test   $0x3,%cl
  800927:	75 ef                	jne    800918 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800929:	83 ef 04             	sub    $0x4,%edi
  80092c:	8d 72 fc             	lea    -0x4(%edx),%esi
  80092f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800932:	fd                   	std    
  800933:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800935:	eb ea                	jmp    800921 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800937:	89 f2                	mov    %esi,%edx
  800939:	09 c2                	or     %eax,%edx
  80093b:	f6 c2 03             	test   $0x3,%dl
  80093e:	74 09                	je     800949 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800940:	89 c7                	mov    %eax,%edi
  800942:	fc                   	cld    
  800943:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800945:	5e                   	pop    %esi
  800946:	5f                   	pop    %edi
  800947:	5d                   	pop    %ebp
  800948:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800949:	f6 c1 03             	test   $0x3,%cl
  80094c:	75 f2                	jne    800940 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80094e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800951:	89 c7                	mov    %eax,%edi
  800953:	fc                   	cld    
  800954:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800956:	eb ed                	jmp    800945 <memmove+0x55>

00800958 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80095b:	ff 75 10             	pushl  0x10(%ebp)
  80095e:	ff 75 0c             	pushl  0xc(%ebp)
  800961:	ff 75 08             	pushl  0x8(%ebp)
  800964:	e8 87 ff ff ff       	call   8008f0 <memmove>
}
  800969:	c9                   	leave  
  80096a:	c3                   	ret    

0080096b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	56                   	push   %esi
  80096f:	53                   	push   %ebx
  800970:	8b 45 08             	mov    0x8(%ebp),%eax
  800973:	8b 55 0c             	mov    0xc(%ebp),%edx
  800976:	89 c6                	mov    %eax,%esi
  800978:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80097b:	39 f0                	cmp    %esi,%eax
  80097d:	74 1c                	je     80099b <memcmp+0x30>
		if (*s1 != *s2)
  80097f:	0f b6 08             	movzbl (%eax),%ecx
  800982:	0f b6 1a             	movzbl (%edx),%ebx
  800985:	38 d9                	cmp    %bl,%cl
  800987:	75 08                	jne    800991 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800989:	83 c0 01             	add    $0x1,%eax
  80098c:	83 c2 01             	add    $0x1,%edx
  80098f:	eb ea                	jmp    80097b <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800991:	0f b6 c1             	movzbl %cl,%eax
  800994:	0f b6 db             	movzbl %bl,%ebx
  800997:	29 d8                	sub    %ebx,%eax
  800999:	eb 05                	jmp    8009a0 <memcmp+0x35>
	}

	return 0;
  80099b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009a0:	5b                   	pop    %ebx
  8009a1:	5e                   	pop    %esi
  8009a2:	5d                   	pop    %ebp
  8009a3:	c3                   	ret    

008009a4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009a4:	55                   	push   %ebp
  8009a5:	89 e5                	mov    %esp,%ebp
  8009a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009ad:	89 c2                	mov    %eax,%edx
  8009af:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009b2:	39 d0                	cmp    %edx,%eax
  8009b4:	73 09                	jae    8009bf <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009b6:	38 08                	cmp    %cl,(%eax)
  8009b8:	74 05                	je     8009bf <memfind+0x1b>
	for (; s < ends; s++)
  8009ba:	83 c0 01             	add    $0x1,%eax
  8009bd:	eb f3                	jmp    8009b2 <memfind+0xe>
			break;
	return (void *) s;
}
  8009bf:	5d                   	pop    %ebp
  8009c0:	c3                   	ret    

008009c1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009c1:	55                   	push   %ebp
  8009c2:	89 e5                	mov    %esp,%ebp
  8009c4:	57                   	push   %edi
  8009c5:	56                   	push   %esi
  8009c6:	53                   	push   %ebx
  8009c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ca:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009cd:	eb 03                	jmp    8009d2 <strtol+0x11>
		s++;
  8009cf:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  8009d2:	0f b6 01             	movzbl (%ecx),%eax
  8009d5:	3c 20                	cmp    $0x20,%al
  8009d7:	74 f6                	je     8009cf <strtol+0xe>
  8009d9:	3c 09                	cmp    $0x9,%al
  8009db:	74 f2                	je     8009cf <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8009dd:	3c 2b                	cmp    $0x2b,%al
  8009df:	74 2e                	je     800a0f <strtol+0x4e>
	int neg = 0;
  8009e1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8009e6:	3c 2d                	cmp    $0x2d,%al
  8009e8:	74 2f                	je     800a19 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009ea:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009f0:	75 05                	jne    8009f7 <strtol+0x36>
  8009f2:	80 39 30             	cmpb   $0x30,(%ecx)
  8009f5:	74 2c                	je     800a23 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009f7:	85 db                	test   %ebx,%ebx
  8009f9:	75 0a                	jne    800a05 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009fb:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a00:	80 39 30             	cmpb   $0x30,(%ecx)
  800a03:	74 28                	je     800a2d <strtol+0x6c>
		base = 10;
  800a05:	b8 00 00 00 00       	mov    $0x0,%eax
  800a0a:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a0d:	eb 50                	jmp    800a5f <strtol+0x9e>
		s++;
  800a0f:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a12:	bf 00 00 00 00       	mov    $0x0,%edi
  800a17:	eb d1                	jmp    8009ea <strtol+0x29>
		s++, neg = 1;
  800a19:	83 c1 01             	add    $0x1,%ecx
  800a1c:	bf 01 00 00 00       	mov    $0x1,%edi
  800a21:	eb c7                	jmp    8009ea <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a23:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a27:	74 0e                	je     800a37 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a29:	85 db                	test   %ebx,%ebx
  800a2b:	75 d8                	jne    800a05 <strtol+0x44>
		s++, base = 8;
  800a2d:	83 c1 01             	add    $0x1,%ecx
  800a30:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a35:	eb ce                	jmp    800a05 <strtol+0x44>
		s += 2, base = 16;
  800a37:	83 c1 02             	add    $0x2,%ecx
  800a3a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a3f:	eb c4                	jmp    800a05 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800a41:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a44:	89 f3                	mov    %esi,%ebx
  800a46:	80 fb 19             	cmp    $0x19,%bl
  800a49:	77 29                	ja     800a74 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800a4b:	0f be d2             	movsbl %dl,%edx
  800a4e:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a51:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a54:	7d 30                	jge    800a86 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800a56:	83 c1 01             	add    $0x1,%ecx
  800a59:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a5d:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a5f:	0f b6 11             	movzbl (%ecx),%edx
  800a62:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a65:	89 f3                	mov    %esi,%ebx
  800a67:	80 fb 09             	cmp    $0x9,%bl
  800a6a:	77 d5                	ja     800a41 <strtol+0x80>
			dig = *s - '0';
  800a6c:	0f be d2             	movsbl %dl,%edx
  800a6f:	83 ea 30             	sub    $0x30,%edx
  800a72:	eb dd                	jmp    800a51 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800a74:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a77:	89 f3                	mov    %esi,%ebx
  800a79:	80 fb 19             	cmp    $0x19,%bl
  800a7c:	77 08                	ja     800a86 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a7e:	0f be d2             	movsbl %dl,%edx
  800a81:	83 ea 37             	sub    $0x37,%edx
  800a84:	eb cb                	jmp    800a51 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a86:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a8a:	74 05                	je     800a91 <strtol+0xd0>
		*endptr = (char *) s;
  800a8c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a8f:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800a91:	89 c2                	mov    %eax,%edx
  800a93:	f7 da                	neg    %edx
  800a95:	85 ff                	test   %edi,%edi
  800a97:	0f 45 c2             	cmovne %edx,%eax
}
  800a9a:	5b                   	pop    %ebx
  800a9b:	5e                   	pop    %esi
  800a9c:	5f                   	pop    %edi
  800a9d:	5d                   	pop    %ebp
  800a9e:	c3                   	ret    

00800a9f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a9f:	55                   	push   %ebp
  800aa0:	89 e5                	mov    %esp,%ebp
  800aa2:	57                   	push   %edi
  800aa3:	56                   	push   %esi
  800aa4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800aa5:	b8 00 00 00 00       	mov    $0x0,%eax
  800aaa:	8b 55 08             	mov    0x8(%ebp),%edx
  800aad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ab0:	89 c3                	mov    %eax,%ebx
  800ab2:	89 c7                	mov    %eax,%edi
  800ab4:	89 c6                	mov    %eax,%esi
  800ab6:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ab8:	5b                   	pop    %ebx
  800ab9:	5e                   	pop    %esi
  800aba:	5f                   	pop    %edi
  800abb:	5d                   	pop    %ebp
  800abc:	c3                   	ret    

00800abd <sys_cgetc>:

int
sys_cgetc(void)
{
  800abd:	55                   	push   %ebp
  800abe:	89 e5                	mov    %esp,%ebp
  800ac0:	57                   	push   %edi
  800ac1:	56                   	push   %esi
  800ac2:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ac3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac8:	b8 01 00 00 00       	mov    $0x1,%eax
  800acd:	89 d1                	mov    %edx,%ecx
  800acf:	89 d3                	mov    %edx,%ebx
  800ad1:	89 d7                	mov    %edx,%edi
  800ad3:	89 d6                	mov    %edx,%esi
  800ad5:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ad7:	5b                   	pop    %ebx
  800ad8:	5e                   	pop    %esi
  800ad9:	5f                   	pop    %edi
  800ada:	5d                   	pop    %ebp
  800adb:	c3                   	ret    

00800adc <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800adc:	55                   	push   %ebp
  800add:	89 e5                	mov    %esp,%ebp
  800adf:	57                   	push   %edi
  800ae0:	56                   	push   %esi
  800ae1:	53                   	push   %ebx
  800ae2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ae5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aea:	8b 55 08             	mov    0x8(%ebp),%edx
  800aed:	b8 03 00 00 00       	mov    $0x3,%eax
  800af2:	89 cb                	mov    %ecx,%ebx
  800af4:	89 cf                	mov    %ecx,%edi
  800af6:	89 ce                	mov    %ecx,%esi
  800af8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800afa:	85 c0                	test   %eax,%eax
  800afc:	7f 08                	jg     800b06 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800afe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b01:	5b                   	pop    %ebx
  800b02:	5e                   	pop    %esi
  800b03:	5f                   	pop    %edi
  800b04:	5d                   	pop    %ebp
  800b05:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b06:	83 ec 0c             	sub    $0xc,%esp
  800b09:	50                   	push   %eax
  800b0a:	6a 03                	push   $0x3
  800b0c:	68 ff 20 80 00       	push   $0x8020ff
  800b11:	6a 23                	push   $0x23
  800b13:	68 1c 21 80 00       	push   $0x80211c
  800b18:	e8 ea 0e 00 00       	call   801a07 <_panic>

00800b1d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b1d:	55                   	push   %ebp
  800b1e:	89 e5                	mov    %esp,%ebp
  800b20:	57                   	push   %edi
  800b21:	56                   	push   %esi
  800b22:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b23:	ba 00 00 00 00       	mov    $0x0,%edx
  800b28:	b8 02 00 00 00       	mov    $0x2,%eax
  800b2d:	89 d1                	mov    %edx,%ecx
  800b2f:	89 d3                	mov    %edx,%ebx
  800b31:	89 d7                	mov    %edx,%edi
  800b33:	89 d6                	mov    %edx,%esi
  800b35:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b37:	5b                   	pop    %ebx
  800b38:	5e                   	pop    %esi
  800b39:	5f                   	pop    %edi
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <sys_yield>:

void
sys_yield(void)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	57                   	push   %edi
  800b40:	56                   	push   %esi
  800b41:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b42:	ba 00 00 00 00       	mov    $0x0,%edx
  800b47:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b4c:	89 d1                	mov    %edx,%ecx
  800b4e:	89 d3                	mov    %edx,%ebx
  800b50:	89 d7                	mov    %edx,%edi
  800b52:	89 d6                	mov    %edx,%esi
  800b54:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b56:	5b                   	pop    %ebx
  800b57:	5e                   	pop    %esi
  800b58:	5f                   	pop    %edi
  800b59:	5d                   	pop    %ebp
  800b5a:	c3                   	ret    

00800b5b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b5b:	55                   	push   %ebp
  800b5c:	89 e5                	mov    %esp,%ebp
  800b5e:	57                   	push   %edi
  800b5f:	56                   	push   %esi
  800b60:	53                   	push   %ebx
  800b61:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b64:	be 00 00 00 00       	mov    $0x0,%esi
  800b69:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b6f:	b8 04 00 00 00       	mov    $0x4,%eax
  800b74:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b77:	89 f7                	mov    %esi,%edi
  800b79:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b7b:	85 c0                	test   %eax,%eax
  800b7d:	7f 08                	jg     800b87 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b82:	5b                   	pop    %ebx
  800b83:	5e                   	pop    %esi
  800b84:	5f                   	pop    %edi
  800b85:	5d                   	pop    %ebp
  800b86:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b87:	83 ec 0c             	sub    $0xc,%esp
  800b8a:	50                   	push   %eax
  800b8b:	6a 04                	push   $0x4
  800b8d:	68 ff 20 80 00       	push   $0x8020ff
  800b92:	6a 23                	push   $0x23
  800b94:	68 1c 21 80 00       	push   $0x80211c
  800b99:	e8 69 0e 00 00       	call   801a07 <_panic>

00800b9e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b9e:	55                   	push   %ebp
  800b9f:	89 e5                	mov    %esp,%ebp
  800ba1:	57                   	push   %edi
  800ba2:	56                   	push   %esi
  800ba3:	53                   	push   %ebx
  800ba4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ba7:	8b 55 08             	mov    0x8(%ebp),%edx
  800baa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bad:	b8 05 00 00 00       	mov    $0x5,%eax
  800bb2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bb8:	8b 75 18             	mov    0x18(%ebp),%esi
  800bbb:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bbd:	85 c0                	test   %eax,%eax
  800bbf:	7f 08                	jg     800bc9 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc4:	5b                   	pop    %ebx
  800bc5:	5e                   	pop    %esi
  800bc6:	5f                   	pop    %edi
  800bc7:	5d                   	pop    %ebp
  800bc8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc9:	83 ec 0c             	sub    $0xc,%esp
  800bcc:	50                   	push   %eax
  800bcd:	6a 05                	push   $0x5
  800bcf:	68 ff 20 80 00       	push   $0x8020ff
  800bd4:	6a 23                	push   $0x23
  800bd6:	68 1c 21 80 00       	push   $0x80211c
  800bdb:	e8 27 0e 00 00       	call   801a07 <_panic>

00800be0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800be0:	55                   	push   %ebp
  800be1:	89 e5                	mov    %esp,%ebp
  800be3:	57                   	push   %edi
  800be4:	56                   	push   %esi
  800be5:	53                   	push   %ebx
  800be6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800be9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bee:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf4:	b8 06 00 00 00       	mov    $0x6,%eax
  800bf9:	89 df                	mov    %ebx,%edi
  800bfb:	89 de                	mov    %ebx,%esi
  800bfd:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bff:	85 c0                	test   %eax,%eax
  800c01:	7f 08                	jg     800c0b <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c03:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c06:	5b                   	pop    %ebx
  800c07:	5e                   	pop    %esi
  800c08:	5f                   	pop    %edi
  800c09:	5d                   	pop    %ebp
  800c0a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0b:	83 ec 0c             	sub    $0xc,%esp
  800c0e:	50                   	push   %eax
  800c0f:	6a 06                	push   $0x6
  800c11:	68 ff 20 80 00       	push   $0x8020ff
  800c16:	6a 23                	push   $0x23
  800c18:	68 1c 21 80 00       	push   $0x80211c
  800c1d:	e8 e5 0d 00 00       	call   801a07 <_panic>

00800c22 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	57                   	push   %edi
  800c26:	56                   	push   %esi
  800c27:	53                   	push   %ebx
  800c28:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c2b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c30:	8b 55 08             	mov    0x8(%ebp),%edx
  800c33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c36:	b8 08 00 00 00       	mov    $0x8,%eax
  800c3b:	89 df                	mov    %ebx,%edi
  800c3d:	89 de                	mov    %ebx,%esi
  800c3f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c41:	85 c0                	test   %eax,%eax
  800c43:	7f 08                	jg     800c4d <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c48:	5b                   	pop    %ebx
  800c49:	5e                   	pop    %esi
  800c4a:	5f                   	pop    %edi
  800c4b:	5d                   	pop    %ebp
  800c4c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4d:	83 ec 0c             	sub    $0xc,%esp
  800c50:	50                   	push   %eax
  800c51:	6a 08                	push   $0x8
  800c53:	68 ff 20 80 00       	push   $0x8020ff
  800c58:	6a 23                	push   $0x23
  800c5a:	68 1c 21 80 00       	push   $0x80211c
  800c5f:	e8 a3 0d 00 00       	call   801a07 <_panic>

00800c64 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	57                   	push   %edi
  800c68:	56                   	push   %esi
  800c69:	53                   	push   %ebx
  800c6a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c6d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c72:	8b 55 08             	mov    0x8(%ebp),%edx
  800c75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c78:	b8 09 00 00 00       	mov    $0x9,%eax
  800c7d:	89 df                	mov    %ebx,%edi
  800c7f:	89 de                	mov    %ebx,%esi
  800c81:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c83:	85 c0                	test   %eax,%eax
  800c85:	7f 08                	jg     800c8f <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8a:	5b                   	pop    %ebx
  800c8b:	5e                   	pop    %esi
  800c8c:	5f                   	pop    %edi
  800c8d:	5d                   	pop    %ebp
  800c8e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8f:	83 ec 0c             	sub    $0xc,%esp
  800c92:	50                   	push   %eax
  800c93:	6a 09                	push   $0x9
  800c95:	68 ff 20 80 00       	push   $0x8020ff
  800c9a:	6a 23                	push   $0x23
  800c9c:	68 1c 21 80 00       	push   $0x80211c
  800ca1:	e8 61 0d 00 00       	call   801a07 <_panic>

00800ca6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ca6:	55                   	push   %ebp
  800ca7:	89 e5                	mov    %esp,%ebp
  800ca9:	57                   	push   %edi
  800caa:	56                   	push   %esi
  800cab:	53                   	push   %ebx
  800cac:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800caf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cba:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cbf:	89 df                	mov    %ebx,%edi
  800cc1:	89 de                	mov    %ebx,%esi
  800cc3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cc5:	85 c0                	test   %eax,%eax
  800cc7:	7f 08                	jg     800cd1 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cc9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ccc:	5b                   	pop    %ebx
  800ccd:	5e                   	pop    %esi
  800cce:	5f                   	pop    %edi
  800ccf:	5d                   	pop    %ebp
  800cd0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd1:	83 ec 0c             	sub    $0xc,%esp
  800cd4:	50                   	push   %eax
  800cd5:	6a 0a                	push   $0xa
  800cd7:	68 ff 20 80 00       	push   $0x8020ff
  800cdc:	6a 23                	push   $0x23
  800cde:	68 1c 21 80 00       	push   $0x80211c
  800ce3:	e8 1f 0d 00 00       	call   801a07 <_panic>

00800ce8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ce8:	55                   	push   %ebp
  800ce9:	89 e5                	mov    %esp,%ebp
  800ceb:	57                   	push   %edi
  800cec:	56                   	push   %esi
  800ced:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cee:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cf9:	be 00 00 00 00       	mov    $0x0,%esi
  800cfe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d01:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d04:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d06:	5b                   	pop    %ebx
  800d07:	5e                   	pop    %esi
  800d08:	5f                   	pop    %edi
  800d09:	5d                   	pop    %ebp
  800d0a:	c3                   	ret    

00800d0b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d0b:	55                   	push   %ebp
  800d0c:	89 e5                	mov    %esp,%ebp
  800d0e:	57                   	push   %edi
  800d0f:	56                   	push   %esi
  800d10:	53                   	push   %ebx
  800d11:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d14:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d19:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d21:	89 cb                	mov    %ecx,%ebx
  800d23:	89 cf                	mov    %ecx,%edi
  800d25:	89 ce                	mov    %ecx,%esi
  800d27:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d29:	85 c0                	test   %eax,%eax
  800d2b:	7f 08                	jg     800d35 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d30:	5b                   	pop    %ebx
  800d31:	5e                   	pop    %esi
  800d32:	5f                   	pop    %edi
  800d33:	5d                   	pop    %ebp
  800d34:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d35:	83 ec 0c             	sub    $0xc,%esp
  800d38:	50                   	push   %eax
  800d39:	6a 0d                	push   $0xd
  800d3b:	68 ff 20 80 00       	push   $0x8020ff
  800d40:	6a 23                	push   $0x23
  800d42:	68 1c 21 80 00       	push   $0x80211c
  800d47:	e8 bb 0c 00 00       	call   801a07 <_panic>

00800d4c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d52:	05 00 00 00 30       	add    $0x30000000,%eax
  800d57:	c1 e8 0c             	shr    $0xc,%eax
}
  800d5a:	5d                   	pop    %ebp
  800d5b:	c3                   	ret    

00800d5c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d5c:	55                   	push   %ebp
  800d5d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d62:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800d67:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d6c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d71:	5d                   	pop    %ebp
  800d72:	c3                   	ret    

00800d73 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
  800d76:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d79:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d7e:	89 c2                	mov    %eax,%edx
  800d80:	c1 ea 16             	shr    $0x16,%edx
  800d83:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d8a:	f6 c2 01             	test   $0x1,%dl
  800d8d:	74 2a                	je     800db9 <fd_alloc+0x46>
  800d8f:	89 c2                	mov    %eax,%edx
  800d91:	c1 ea 0c             	shr    $0xc,%edx
  800d94:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d9b:	f6 c2 01             	test   $0x1,%dl
  800d9e:	74 19                	je     800db9 <fd_alloc+0x46>
  800da0:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800da5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800daa:	75 d2                	jne    800d7e <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800dac:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800db2:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800db7:	eb 07                	jmp    800dc0 <fd_alloc+0x4d>
			*fd_store = fd;
  800db9:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dbb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dc0:	5d                   	pop    %ebp
  800dc1:	c3                   	ret    

00800dc2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800dc2:	55                   	push   %ebp
  800dc3:	89 e5                	mov    %esp,%ebp
  800dc5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800dc8:	83 f8 1f             	cmp    $0x1f,%eax
  800dcb:	77 36                	ja     800e03 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800dcd:	c1 e0 0c             	shl    $0xc,%eax
  800dd0:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800dd5:	89 c2                	mov    %eax,%edx
  800dd7:	c1 ea 16             	shr    $0x16,%edx
  800dda:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800de1:	f6 c2 01             	test   $0x1,%dl
  800de4:	74 24                	je     800e0a <fd_lookup+0x48>
  800de6:	89 c2                	mov    %eax,%edx
  800de8:	c1 ea 0c             	shr    $0xc,%edx
  800deb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800df2:	f6 c2 01             	test   $0x1,%dl
  800df5:	74 1a                	je     800e11 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800df7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dfa:	89 02                	mov    %eax,(%edx)
	return 0;
  800dfc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e01:	5d                   	pop    %ebp
  800e02:	c3                   	ret    
		return -E_INVAL;
  800e03:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e08:	eb f7                	jmp    800e01 <fd_lookup+0x3f>
		return -E_INVAL;
  800e0a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e0f:	eb f0                	jmp    800e01 <fd_lookup+0x3f>
  800e11:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e16:	eb e9                	jmp    800e01 <fd_lookup+0x3f>

00800e18 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e18:	55                   	push   %ebp
  800e19:	89 e5                	mov    %esp,%ebp
  800e1b:	83 ec 08             	sub    $0x8,%esp
  800e1e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e21:	ba a8 21 80 00       	mov    $0x8021a8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e26:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800e2b:	39 08                	cmp    %ecx,(%eax)
  800e2d:	74 33                	je     800e62 <dev_lookup+0x4a>
  800e2f:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800e32:	8b 02                	mov    (%edx),%eax
  800e34:	85 c0                	test   %eax,%eax
  800e36:	75 f3                	jne    800e2b <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e38:	a1 04 40 80 00       	mov    0x804004,%eax
  800e3d:	8b 40 48             	mov    0x48(%eax),%eax
  800e40:	83 ec 04             	sub    $0x4,%esp
  800e43:	51                   	push   %ecx
  800e44:	50                   	push   %eax
  800e45:	68 2c 21 80 00       	push   $0x80212c
  800e4a:	e8 f4 f2 ff ff       	call   800143 <cprintf>
	*dev = 0;
  800e4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e52:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e58:	83 c4 10             	add    $0x10,%esp
  800e5b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e60:	c9                   	leave  
  800e61:	c3                   	ret    
			*dev = devtab[i];
  800e62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e65:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e67:	b8 00 00 00 00       	mov    $0x0,%eax
  800e6c:	eb f2                	jmp    800e60 <dev_lookup+0x48>

00800e6e <fd_close>:
{
  800e6e:	55                   	push   %ebp
  800e6f:	89 e5                	mov    %esp,%ebp
  800e71:	57                   	push   %edi
  800e72:	56                   	push   %esi
  800e73:	53                   	push   %ebx
  800e74:	83 ec 1c             	sub    $0x1c,%esp
  800e77:	8b 75 08             	mov    0x8(%ebp),%esi
  800e7a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e7d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800e80:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e81:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e87:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e8a:	50                   	push   %eax
  800e8b:	e8 32 ff ff ff       	call   800dc2 <fd_lookup>
  800e90:	89 c3                	mov    %eax,%ebx
  800e92:	83 c4 08             	add    $0x8,%esp
  800e95:	85 c0                	test   %eax,%eax
  800e97:	78 05                	js     800e9e <fd_close+0x30>
	    || fd != fd2)
  800e99:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800e9c:	74 16                	je     800eb4 <fd_close+0x46>
		return (must_exist ? r : 0);
  800e9e:	89 f8                	mov    %edi,%eax
  800ea0:	84 c0                	test   %al,%al
  800ea2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea7:	0f 44 d8             	cmove  %eax,%ebx
}
  800eaa:	89 d8                	mov    %ebx,%eax
  800eac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eaf:	5b                   	pop    %ebx
  800eb0:	5e                   	pop    %esi
  800eb1:	5f                   	pop    %edi
  800eb2:	5d                   	pop    %ebp
  800eb3:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800eb4:	83 ec 08             	sub    $0x8,%esp
  800eb7:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800eba:	50                   	push   %eax
  800ebb:	ff 36                	pushl  (%esi)
  800ebd:	e8 56 ff ff ff       	call   800e18 <dev_lookup>
  800ec2:	89 c3                	mov    %eax,%ebx
  800ec4:	83 c4 10             	add    $0x10,%esp
  800ec7:	85 c0                	test   %eax,%eax
  800ec9:	78 15                	js     800ee0 <fd_close+0x72>
		if (dev->dev_close)
  800ecb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ece:	8b 40 10             	mov    0x10(%eax),%eax
  800ed1:	85 c0                	test   %eax,%eax
  800ed3:	74 1b                	je     800ef0 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  800ed5:	83 ec 0c             	sub    $0xc,%esp
  800ed8:	56                   	push   %esi
  800ed9:	ff d0                	call   *%eax
  800edb:	89 c3                	mov    %eax,%ebx
  800edd:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800ee0:	83 ec 08             	sub    $0x8,%esp
  800ee3:	56                   	push   %esi
  800ee4:	6a 00                	push   $0x0
  800ee6:	e8 f5 fc ff ff       	call   800be0 <sys_page_unmap>
	return r;
  800eeb:	83 c4 10             	add    $0x10,%esp
  800eee:	eb ba                	jmp    800eaa <fd_close+0x3c>
			r = 0;
  800ef0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ef5:	eb e9                	jmp    800ee0 <fd_close+0x72>

00800ef7 <close>:

int
close(int fdnum)
{
  800ef7:	55                   	push   %ebp
  800ef8:	89 e5                	mov    %esp,%ebp
  800efa:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800efd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f00:	50                   	push   %eax
  800f01:	ff 75 08             	pushl  0x8(%ebp)
  800f04:	e8 b9 fe ff ff       	call   800dc2 <fd_lookup>
  800f09:	83 c4 08             	add    $0x8,%esp
  800f0c:	85 c0                	test   %eax,%eax
  800f0e:	78 10                	js     800f20 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f10:	83 ec 08             	sub    $0x8,%esp
  800f13:	6a 01                	push   $0x1
  800f15:	ff 75 f4             	pushl  -0xc(%ebp)
  800f18:	e8 51 ff ff ff       	call   800e6e <fd_close>
  800f1d:	83 c4 10             	add    $0x10,%esp
}
  800f20:	c9                   	leave  
  800f21:	c3                   	ret    

00800f22 <close_all>:

void
close_all(void)
{
  800f22:	55                   	push   %ebp
  800f23:	89 e5                	mov    %esp,%ebp
  800f25:	53                   	push   %ebx
  800f26:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f29:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f2e:	83 ec 0c             	sub    $0xc,%esp
  800f31:	53                   	push   %ebx
  800f32:	e8 c0 ff ff ff       	call   800ef7 <close>
	for (i = 0; i < MAXFD; i++)
  800f37:	83 c3 01             	add    $0x1,%ebx
  800f3a:	83 c4 10             	add    $0x10,%esp
  800f3d:	83 fb 20             	cmp    $0x20,%ebx
  800f40:	75 ec                	jne    800f2e <close_all+0xc>
}
  800f42:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f45:	c9                   	leave  
  800f46:	c3                   	ret    

00800f47 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f47:	55                   	push   %ebp
  800f48:	89 e5                	mov    %esp,%ebp
  800f4a:	57                   	push   %edi
  800f4b:	56                   	push   %esi
  800f4c:	53                   	push   %ebx
  800f4d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f50:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f53:	50                   	push   %eax
  800f54:	ff 75 08             	pushl  0x8(%ebp)
  800f57:	e8 66 fe ff ff       	call   800dc2 <fd_lookup>
  800f5c:	89 c3                	mov    %eax,%ebx
  800f5e:	83 c4 08             	add    $0x8,%esp
  800f61:	85 c0                	test   %eax,%eax
  800f63:	0f 88 81 00 00 00    	js     800fea <dup+0xa3>
		return r;
	close(newfdnum);
  800f69:	83 ec 0c             	sub    $0xc,%esp
  800f6c:	ff 75 0c             	pushl  0xc(%ebp)
  800f6f:	e8 83 ff ff ff       	call   800ef7 <close>

	newfd = INDEX2FD(newfdnum);
  800f74:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f77:	c1 e6 0c             	shl    $0xc,%esi
  800f7a:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800f80:	83 c4 04             	add    $0x4,%esp
  800f83:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f86:	e8 d1 fd ff ff       	call   800d5c <fd2data>
  800f8b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800f8d:	89 34 24             	mov    %esi,(%esp)
  800f90:	e8 c7 fd ff ff       	call   800d5c <fd2data>
  800f95:	83 c4 10             	add    $0x10,%esp
  800f98:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f9a:	89 d8                	mov    %ebx,%eax
  800f9c:	c1 e8 16             	shr    $0x16,%eax
  800f9f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fa6:	a8 01                	test   $0x1,%al
  800fa8:	74 11                	je     800fbb <dup+0x74>
  800faa:	89 d8                	mov    %ebx,%eax
  800fac:	c1 e8 0c             	shr    $0xc,%eax
  800faf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fb6:	f6 c2 01             	test   $0x1,%dl
  800fb9:	75 39                	jne    800ff4 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fbb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fbe:	89 d0                	mov    %edx,%eax
  800fc0:	c1 e8 0c             	shr    $0xc,%eax
  800fc3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fca:	83 ec 0c             	sub    $0xc,%esp
  800fcd:	25 07 0e 00 00       	and    $0xe07,%eax
  800fd2:	50                   	push   %eax
  800fd3:	56                   	push   %esi
  800fd4:	6a 00                	push   $0x0
  800fd6:	52                   	push   %edx
  800fd7:	6a 00                	push   $0x0
  800fd9:	e8 c0 fb ff ff       	call   800b9e <sys_page_map>
  800fde:	89 c3                	mov    %eax,%ebx
  800fe0:	83 c4 20             	add    $0x20,%esp
  800fe3:	85 c0                	test   %eax,%eax
  800fe5:	78 31                	js     801018 <dup+0xd1>
		goto err;

	return newfdnum;
  800fe7:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800fea:	89 d8                	mov    %ebx,%eax
  800fec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fef:	5b                   	pop    %ebx
  800ff0:	5e                   	pop    %esi
  800ff1:	5f                   	pop    %edi
  800ff2:	5d                   	pop    %ebp
  800ff3:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800ff4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ffb:	83 ec 0c             	sub    $0xc,%esp
  800ffe:	25 07 0e 00 00       	and    $0xe07,%eax
  801003:	50                   	push   %eax
  801004:	57                   	push   %edi
  801005:	6a 00                	push   $0x0
  801007:	53                   	push   %ebx
  801008:	6a 00                	push   $0x0
  80100a:	e8 8f fb ff ff       	call   800b9e <sys_page_map>
  80100f:	89 c3                	mov    %eax,%ebx
  801011:	83 c4 20             	add    $0x20,%esp
  801014:	85 c0                	test   %eax,%eax
  801016:	79 a3                	jns    800fbb <dup+0x74>
	sys_page_unmap(0, newfd);
  801018:	83 ec 08             	sub    $0x8,%esp
  80101b:	56                   	push   %esi
  80101c:	6a 00                	push   $0x0
  80101e:	e8 bd fb ff ff       	call   800be0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801023:	83 c4 08             	add    $0x8,%esp
  801026:	57                   	push   %edi
  801027:	6a 00                	push   $0x0
  801029:	e8 b2 fb ff ff       	call   800be0 <sys_page_unmap>
	return r;
  80102e:	83 c4 10             	add    $0x10,%esp
  801031:	eb b7                	jmp    800fea <dup+0xa3>

00801033 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801033:	55                   	push   %ebp
  801034:	89 e5                	mov    %esp,%ebp
  801036:	53                   	push   %ebx
  801037:	83 ec 14             	sub    $0x14,%esp
  80103a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80103d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801040:	50                   	push   %eax
  801041:	53                   	push   %ebx
  801042:	e8 7b fd ff ff       	call   800dc2 <fd_lookup>
  801047:	83 c4 08             	add    $0x8,%esp
  80104a:	85 c0                	test   %eax,%eax
  80104c:	78 3f                	js     80108d <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80104e:	83 ec 08             	sub    $0x8,%esp
  801051:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801054:	50                   	push   %eax
  801055:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801058:	ff 30                	pushl  (%eax)
  80105a:	e8 b9 fd ff ff       	call   800e18 <dev_lookup>
  80105f:	83 c4 10             	add    $0x10,%esp
  801062:	85 c0                	test   %eax,%eax
  801064:	78 27                	js     80108d <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801066:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801069:	8b 42 08             	mov    0x8(%edx),%eax
  80106c:	83 e0 03             	and    $0x3,%eax
  80106f:	83 f8 01             	cmp    $0x1,%eax
  801072:	74 1e                	je     801092 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801074:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801077:	8b 40 08             	mov    0x8(%eax),%eax
  80107a:	85 c0                	test   %eax,%eax
  80107c:	74 35                	je     8010b3 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80107e:	83 ec 04             	sub    $0x4,%esp
  801081:	ff 75 10             	pushl  0x10(%ebp)
  801084:	ff 75 0c             	pushl  0xc(%ebp)
  801087:	52                   	push   %edx
  801088:	ff d0                	call   *%eax
  80108a:	83 c4 10             	add    $0x10,%esp
}
  80108d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801090:	c9                   	leave  
  801091:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801092:	a1 04 40 80 00       	mov    0x804004,%eax
  801097:	8b 40 48             	mov    0x48(%eax),%eax
  80109a:	83 ec 04             	sub    $0x4,%esp
  80109d:	53                   	push   %ebx
  80109e:	50                   	push   %eax
  80109f:	68 6d 21 80 00       	push   $0x80216d
  8010a4:	e8 9a f0 ff ff       	call   800143 <cprintf>
		return -E_INVAL;
  8010a9:	83 c4 10             	add    $0x10,%esp
  8010ac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010b1:	eb da                	jmp    80108d <read+0x5a>
		return -E_NOT_SUPP;
  8010b3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8010b8:	eb d3                	jmp    80108d <read+0x5a>

008010ba <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010ba:	55                   	push   %ebp
  8010bb:	89 e5                	mov    %esp,%ebp
  8010bd:	57                   	push   %edi
  8010be:	56                   	push   %esi
  8010bf:	53                   	push   %ebx
  8010c0:	83 ec 0c             	sub    $0xc,%esp
  8010c3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010c6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010c9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010ce:	39 f3                	cmp    %esi,%ebx
  8010d0:	73 25                	jae    8010f7 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010d2:	83 ec 04             	sub    $0x4,%esp
  8010d5:	89 f0                	mov    %esi,%eax
  8010d7:	29 d8                	sub    %ebx,%eax
  8010d9:	50                   	push   %eax
  8010da:	89 d8                	mov    %ebx,%eax
  8010dc:	03 45 0c             	add    0xc(%ebp),%eax
  8010df:	50                   	push   %eax
  8010e0:	57                   	push   %edi
  8010e1:	e8 4d ff ff ff       	call   801033 <read>
		if (m < 0)
  8010e6:	83 c4 10             	add    $0x10,%esp
  8010e9:	85 c0                	test   %eax,%eax
  8010eb:	78 08                	js     8010f5 <readn+0x3b>
			return m;
		if (m == 0)
  8010ed:	85 c0                	test   %eax,%eax
  8010ef:	74 06                	je     8010f7 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  8010f1:	01 c3                	add    %eax,%ebx
  8010f3:	eb d9                	jmp    8010ce <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010f5:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8010f7:	89 d8                	mov    %ebx,%eax
  8010f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010fc:	5b                   	pop    %ebx
  8010fd:	5e                   	pop    %esi
  8010fe:	5f                   	pop    %edi
  8010ff:	5d                   	pop    %ebp
  801100:	c3                   	ret    

00801101 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801101:	55                   	push   %ebp
  801102:	89 e5                	mov    %esp,%ebp
  801104:	53                   	push   %ebx
  801105:	83 ec 14             	sub    $0x14,%esp
  801108:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80110b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80110e:	50                   	push   %eax
  80110f:	53                   	push   %ebx
  801110:	e8 ad fc ff ff       	call   800dc2 <fd_lookup>
  801115:	83 c4 08             	add    $0x8,%esp
  801118:	85 c0                	test   %eax,%eax
  80111a:	78 3a                	js     801156 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80111c:	83 ec 08             	sub    $0x8,%esp
  80111f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801122:	50                   	push   %eax
  801123:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801126:	ff 30                	pushl  (%eax)
  801128:	e8 eb fc ff ff       	call   800e18 <dev_lookup>
  80112d:	83 c4 10             	add    $0x10,%esp
  801130:	85 c0                	test   %eax,%eax
  801132:	78 22                	js     801156 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801134:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801137:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80113b:	74 1e                	je     80115b <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80113d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801140:	8b 52 0c             	mov    0xc(%edx),%edx
  801143:	85 d2                	test   %edx,%edx
  801145:	74 35                	je     80117c <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801147:	83 ec 04             	sub    $0x4,%esp
  80114a:	ff 75 10             	pushl  0x10(%ebp)
  80114d:	ff 75 0c             	pushl  0xc(%ebp)
  801150:	50                   	push   %eax
  801151:	ff d2                	call   *%edx
  801153:	83 c4 10             	add    $0x10,%esp
}
  801156:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801159:	c9                   	leave  
  80115a:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80115b:	a1 04 40 80 00       	mov    0x804004,%eax
  801160:	8b 40 48             	mov    0x48(%eax),%eax
  801163:	83 ec 04             	sub    $0x4,%esp
  801166:	53                   	push   %ebx
  801167:	50                   	push   %eax
  801168:	68 89 21 80 00       	push   $0x802189
  80116d:	e8 d1 ef ff ff       	call   800143 <cprintf>
		return -E_INVAL;
  801172:	83 c4 10             	add    $0x10,%esp
  801175:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80117a:	eb da                	jmp    801156 <write+0x55>
		return -E_NOT_SUPP;
  80117c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801181:	eb d3                	jmp    801156 <write+0x55>

00801183 <seek>:

int
seek(int fdnum, off_t offset)
{
  801183:	55                   	push   %ebp
  801184:	89 e5                	mov    %esp,%ebp
  801186:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801189:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80118c:	50                   	push   %eax
  80118d:	ff 75 08             	pushl  0x8(%ebp)
  801190:	e8 2d fc ff ff       	call   800dc2 <fd_lookup>
  801195:	83 c4 08             	add    $0x8,%esp
  801198:	85 c0                	test   %eax,%eax
  80119a:	78 0e                	js     8011aa <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80119c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80119f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011a2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011a5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011aa:	c9                   	leave  
  8011ab:	c3                   	ret    

008011ac <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011ac:	55                   	push   %ebp
  8011ad:	89 e5                	mov    %esp,%ebp
  8011af:	53                   	push   %ebx
  8011b0:	83 ec 14             	sub    $0x14,%esp
  8011b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011b9:	50                   	push   %eax
  8011ba:	53                   	push   %ebx
  8011bb:	e8 02 fc ff ff       	call   800dc2 <fd_lookup>
  8011c0:	83 c4 08             	add    $0x8,%esp
  8011c3:	85 c0                	test   %eax,%eax
  8011c5:	78 37                	js     8011fe <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011c7:	83 ec 08             	sub    $0x8,%esp
  8011ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011cd:	50                   	push   %eax
  8011ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011d1:	ff 30                	pushl  (%eax)
  8011d3:	e8 40 fc ff ff       	call   800e18 <dev_lookup>
  8011d8:	83 c4 10             	add    $0x10,%esp
  8011db:	85 c0                	test   %eax,%eax
  8011dd:	78 1f                	js     8011fe <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011e6:	74 1b                	je     801203 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8011e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011eb:	8b 52 18             	mov    0x18(%edx),%edx
  8011ee:	85 d2                	test   %edx,%edx
  8011f0:	74 32                	je     801224 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8011f2:	83 ec 08             	sub    $0x8,%esp
  8011f5:	ff 75 0c             	pushl  0xc(%ebp)
  8011f8:	50                   	push   %eax
  8011f9:	ff d2                	call   *%edx
  8011fb:	83 c4 10             	add    $0x10,%esp
}
  8011fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801201:	c9                   	leave  
  801202:	c3                   	ret    
			thisenv->env_id, fdnum);
  801203:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801208:	8b 40 48             	mov    0x48(%eax),%eax
  80120b:	83 ec 04             	sub    $0x4,%esp
  80120e:	53                   	push   %ebx
  80120f:	50                   	push   %eax
  801210:	68 4c 21 80 00       	push   $0x80214c
  801215:	e8 29 ef ff ff       	call   800143 <cprintf>
		return -E_INVAL;
  80121a:	83 c4 10             	add    $0x10,%esp
  80121d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801222:	eb da                	jmp    8011fe <ftruncate+0x52>
		return -E_NOT_SUPP;
  801224:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801229:	eb d3                	jmp    8011fe <ftruncate+0x52>

0080122b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80122b:	55                   	push   %ebp
  80122c:	89 e5                	mov    %esp,%ebp
  80122e:	53                   	push   %ebx
  80122f:	83 ec 14             	sub    $0x14,%esp
  801232:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801235:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801238:	50                   	push   %eax
  801239:	ff 75 08             	pushl  0x8(%ebp)
  80123c:	e8 81 fb ff ff       	call   800dc2 <fd_lookup>
  801241:	83 c4 08             	add    $0x8,%esp
  801244:	85 c0                	test   %eax,%eax
  801246:	78 4b                	js     801293 <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801248:	83 ec 08             	sub    $0x8,%esp
  80124b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80124e:	50                   	push   %eax
  80124f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801252:	ff 30                	pushl  (%eax)
  801254:	e8 bf fb ff ff       	call   800e18 <dev_lookup>
  801259:	83 c4 10             	add    $0x10,%esp
  80125c:	85 c0                	test   %eax,%eax
  80125e:	78 33                	js     801293 <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  801260:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801263:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801267:	74 2f                	je     801298 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801269:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80126c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801273:	00 00 00 
	stat->st_isdir = 0;
  801276:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80127d:	00 00 00 
	stat->st_dev = dev;
  801280:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801286:	83 ec 08             	sub    $0x8,%esp
  801289:	53                   	push   %ebx
  80128a:	ff 75 f0             	pushl  -0x10(%ebp)
  80128d:	ff 50 14             	call   *0x14(%eax)
  801290:	83 c4 10             	add    $0x10,%esp
}
  801293:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801296:	c9                   	leave  
  801297:	c3                   	ret    
		return -E_NOT_SUPP;
  801298:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80129d:	eb f4                	jmp    801293 <fstat+0x68>

0080129f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80129f:	55                   	push   %ebp
  8012a0:	89 e5                	mov    %esp,%ebp
  8012a2:	56                   	push   %esi
  8012a3:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012a4:	83 ec 08             	sub    $0x8,%esp
  8012a7:	6a 00                	push   $0x0
  8012a9:	ff 75 08             	pushl  0x8(%ebp)
  8012ac:	e8 e7 01 00 00       	call   801498 <open>
  8012b1:	89 c3                	mov    %eax,%ebx
  8012b3:	83 c4 10             	add    $0x10,%esp
  8012b6:	85 c0                	test   %eax,%eax
  8012b8:	78 1b                	js     8012d5 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012ba:	83 ec 08             	sub    $0x8,%esp
  8012bd:	ff 75 0c             	pushl  0xc(%ebp)
  8012c0:	50                   	push   %eax
  8012c1:	e8 65 ff ff ff       	call   80122b <fstat>
  8012c6:	89 c6                	mov    %eax,%esi
	close(fd);
  8012c8:	89 1c 24             	mov    %ebx,(%esp)
  8012cb:	e8 27 fc ff ff       	call   800ef7 <close>
	return r;
  8012d0:	83 c4 10             	add    $0x10,%esp
  8012d3:	89 f3                	mov    %esi,%ebx
}
  8012d5:	89 d8                	mov    %ebx,%eax
  8012d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012da:	5b                   	pop    %ebx
  8012db:	5e                   	pop    %esi
  8012dc:	5d                   	pop    %ebp
  8012dd:	c3                   	ret    

008012de <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012de:	55                   	push   %ebp
  8012df:	89 e5                	mov    %esp,%ebp
  8012e1:	56                   	push   %esi
  8012e2:	53                   	push   %ebx
  8012e3:	89 c6                	mov    %eax,%esi
  8012e5:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8012e7:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8012ee:	74 27                	je     801317 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8012f0:	6a 07                	push   $0x7
  8012f2:	68 00 50 80 00       	push   $0x805000
  8012f7:	56                   	push   %esi
  8012f8:	ff 35 00 40 80 00    	pushl  0x804000
  8012fe:	e8 bf 07 00 00       	call   801ac2 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801303:	83 c4 0c             	add    $0xc,%esp
  801306:	6a 00                	push   $0x0
  801308:	53                   	push   %ebx
  801309:	6a 00                	push   $0x0
  80130b:	e8 3d 07 00 00       	call   801a4d <ipc_recv>
}
  801310:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801313:	5b                   	pop    %ebx
  801314:	5e                   	pop    %esi
  801315:	5d                   	pop    %ebp
  801316:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801317:	83 ec 0c             	sub    $0xc,%esp
  80131a:	6a 01                	push   $0x1
  80131c:	e8 f7 07 00 00       	call   801b18 <ipc_find_env>
  801321:	a3 00 40 80 00       	mov    %eax,0x804000
  801326:	83 c4 10             	add    $0x10,%esp
  801329:	eb c5                	jmp    8012f0 <fsipc+0x12>

0080132b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80132b:	55                   	push   %ebp
  80132c:	89 e5                	mov    %esp,%ebp
  80132e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801331:	8b 45 08             	mov    0x8(%ebp),%eax
  801334:	8b 40 0c             	mov    0xc(%eax),%eax
  801337:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80133c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80133f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801344:	ba 00 00 00 00       	mov    $0x0,%edx
  801349:	b8 02 00 00 00       	mov    $0x2,%eax
  80134e:	e8 8b ff ff ff       	call   8012de <fsipc>
}
  801353:	c9                   	leave  
  801354:	c3                   	ret    

00801355 <devfile_flush>:
{
  801355:	55                   	push   %ebp
  801356:	89 e5                	mov    %esp,%ebp
  801358:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80135b:	8b 45 08             	mov    0x8(%ebp),%eax
  80135e:	8b 40 0c             	mov    0xc(%eax),%eax
  801361:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801366:	ba 00 00 00 00       	mov    $0x0,%edx
  80136b:	b8 06 00 00 00       	mov    $0x6,%eax
  801370:	e8 69 ff ff ff       	call   8012de <fsipc>
}
  801375:	c9                   	leave  
  801376:	c3                   	ret    

00801377 <devfile_stat>:
{
  801377:	55                   	push   %ebp
  801378:	89 e5                	mov    %esp,%ebp
  80137a:	53                   	push   %ebx
  80137b:	83 ec 04             	sub    $0x4,%esp
  80137e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801381:	8b 45 08             	mov    0x8(%ebp),%eax
  801384:	8b 40 0c             	mov    0xc(%eax),%eax
  801387:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80138c:	ba 00 00 00 00       	mov    $0x0,%edx
  801391:	b8 05 00 00 00       	mov    $0x5,%eax
  801396:	e8 43 ff ff ff       	call   8012de <fsipc>
  80139b:	85 c0                	test   %eax,%eax
  80139d:	78 2c                	js     8013cb <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80139f:	83 ec 08             	sub    $0x8,%esp
  8013a2:	68 00 50 80 00       	push   $0x805000
  8013a7:	53                   	push   %ebx
  8013a8:	e8 b5 f3 ff ff       	call   800762 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013ad:	a1 80 50 80 00       	mov    0x805080,%eax
  8013b2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013b8:	a1 84 50 80 00       	mov    0x805084,%eax
  8013bd:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013c3:	83 c4 10             	add    $0x10,%esp
  8013c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ce:	c9                   	leave  
  8013cf:	c3                   	ret    

008013d0 <devfile_write>:
{
  8013d0:	55                   	push   %ebp
  8013d1:	89 e5                	mov    %esp,%ebp
  8013d3:	83 ec 0c             	sub    $0xc,%esp
  8013d6:	8b 45 10             	mov    0x10(%ebp),%eax
  8013d9:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8013de:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8013e3:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8013e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8013e9:	8b 52 0c             	mov    0xc(%edx),%edx
  8013ec:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8013f2:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf,buf,n);
  8013f7:	50                   	push   %eax
  8013f8:	ff 75 0c             	pushl  0xc(%ebp)
  8013fb:	68 08 50 80 00       	push   $0x805008
  801400:	e8 eb f4 ff ff       	call   8008f0 <memmove>
	if((r = fsipc(FSREQ_WRITE,NULL))<0)
  801405:	ba 00 00 00 00       	mov    $0x0,%edx
  80140a:	b8 04 00 00 00       	mov    $0x4,%eax
  80140f:	e8 ca fe ff ff       	call   8012de <fsipc>
}
  801414:	c9                   	leave  
  801415:	c3                   	ret    

00801416 <devfile_read>:
{
  801416:	55                   	push   %ebp
  801417:	89 e5                	mov    %esp,%ebp
  801419:	56                   	push   %esi
  80141a:	53                   	push   %ebx
  80141b:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80141e:	8b 45 08             	mov    0x8(%ebp),%eax
  801421:	8b 40 0c             	mov    0xc(%eax),%eax
  801424:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801429:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80142f:	ba 00 00 00 00       	mov    $0x0,%edx
  801434:	b8 03 00 00 00       	mov    $0x3,%eax
  801439:	e8 a0 fe ff ff       	call   8012de <fsipc>
  80143e:	89 c3                	mov    %eax,%ebx
  801440:	85 c0                	test   %eax,%eax
  801442:	78 1f                	js     801463 <devfile_read+0x4d>
	assert(r <= n);
  801444:	39 f0                	cmp    %esi,%eax
  801446:	77 24                	ja     80146c <devfile_read+0x56>
	assert(r <= PGSIZE);
  801448:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80144d:	7f 33                	jg     801482 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80144f:	83 ec 04             	sub    $0x4,%esp
  801452:	50                   	push   %eax
  801453:	68 00 50 80 00       	push   $0x805000
  801458:	ff 75 0c             	pushl  0xc(%ebp)
  80145b:	e8 90 f4 ff ff       	call   8008f0 <memmove>
	return r;
  801460:	83 c4 10             	add    $0x10,%esp
}
  801463:	89 d8                	mov    %ebx,%eax
  801465:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801468:	5b                   	pop    %ebx
  801469:	5e                   	pop    %esi
  80146a:	5d                   	pop    %ebp
  80146b:	c3                   	ret    
	assert(r <= n);
  80146c:	68 b8 21 80 00       	push   $0x8021b8
  801471:	68 bf 21 80 00       	push   $0x8021bf
  801476:	6a 7c                	push   $0x7c
  801478:	68 d4 21 80 00       	push   $0x8021d4
  80147d:	e8 85 05 00 00       	call   801a07 <_panic>
	assert(r <= PGSIZE);
  801482:	68 df 21 80 00       	push   $0x8021df
  801487:	68 bf 21 80 00       	push   $0x8021bf
  80148c:	6a 7d                	push   $0x7d
  80148e:	68 d4 21 80 00       	push   $0x8021d4
  801493:	e8 6f 05 00 00       	call   801a07 <_panic>

00801498 <open>:
{
  801498:	55                   	push   %ebp
  801499:	89 e5                	mov    %esp,%ebp
  80149b:	56                   	push   %esi
  80149c:	53                   	push   %ebx
  80149d:	83 ec 1c             	sub    $0x1c,%esp
  8014a0:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8014a3:	56                   	push   %esi
  8014a4:	e8 82 f2 ff ff       	call   80072b <strlen>
  8014a9:	83 c4 10             	add    $0x10,%esp
  8014ac:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014b1:	7f 6c                	jg     80151f <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8014b3:	83 ec 0c             	sub    $0xc,%esp
  8014b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b9:	50                   	push   %eax
  8014ba:	e8 b4 f8 ff ff       	call   800d73 <fd_alloc>
  8014bf:	89 c3                	mov    %eax,%ebx
  8014c1:	83 c4 10             	add    $0x10,%esp
  8014c4:	85 c0                	test   %eax,%eax
  8014c6:	78 3c                	js     801504 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8014c8:	83 ec 08             	sub    $0x8,%esp
  8014cb:	56                   	push   %esi
  8014cc:	68 00 50 80 00       	push   $0x805000
  8014d1:	e8 8c f2 ff ff       	call   800762 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014d9:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014de:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8014e6:	e8 f3 fd ff ff       	call   8012de <fsipc>
  8014eb:	89 c3                	mov    %eax,%ebx
  8014ed:	83 c4 10             	add    $0x10,%esp
  8014f0:	85 c0                	test   %eax,%eax
  8014f2:	78 19                	js     80150d <open+0x75>
	return fd2num(fd);
  8014f4:	83 ec 0c             	sub    $0xc,%esp
  8014f7:	ff 75 f4             	pushl  -0xc(%ebp)
  8014fa:	e8 4d f8 ff ff       	call   800d4c <fd2num>
  8014ff:	89 c3                	mov    %eax,%ebx
  801501:	83 c4 10             	add    $0x10,%esp
}
  801504:	89 d8                	mov    %ebx,%eax
  801506:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801509:	5b                   	pop    %ebx
  80150a:	5e                   	pop    %esi
  80150b:	5d                   	pop    %ebp
  80150c:	c3                   	ret    
		fd_close(fd, 0);
  80150d:	83 ec 08             	sub    $0x8,%esp
  801510:	6a 00                	push   $0x0
  801512:	ff 75 f4             	pushl  -0xc(%ebp)
  801515:	e8 54 f9 ff ff       	call   800e6e <fd_close>
		return r;
  80151a:	83 c4 10             	add    $0x10,%esp
  80151d:	eb e5                	jmp    801504 <open+0x6c>
		return -E_BAD_PATH;
  80151f:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801524:	eb de                	jmp    801504 <open+0x6c>

00801526 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801526:	55                   	push   %ebp
  801527:	89 e5                	mov    %esp,%ebp
  801529:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80152c:	ba 00 00 00 00       	mov    $0x0,%edx
  801531:	b8 08 00 00 00       	mov    $0x8,%eax
  801536:	e8 a3 fd ff ff       	call   8012de <fsipc>
}
  80153b:	c9                   	leave  
  80153c:	c3                   	ret    

0080153d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80153d:	55                   	push   %ebp
  80153e:	89 e5                	mov    %esp,%ebp
  801540:	56                   	push   %esi
  801541:	53                   	push   %ebx
  801542:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801545:	83 ec 0c             	sub    $0xc,%esp
  801548:	ff 75 08             	pushl  0x8(%ebp)
  80154b:	e8 0c f8 ff ff       	call   800d5c <fd2data>
  801550:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801552:	83 c4 08             	add    $0x8,%esp
  801555:	68 eb 21 80 00       	push   $0x8021eb
  80155a:	53                   	push   %ebx
  80155b:	e8 02 f2 ff ff       	call   800762 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801560:	8b 46 04             	mov    0x4(%esi),%eax
  801563:	2b 06                	sub    (%esi),%eax
  801565:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80156b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801572:	00 00 00 
	stat->st_dev = &devpipe;
  801575:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80157c:	30 80 00 
	return 0;
}
  80157f:	b8 00 00 00 00       	mov    $0x0,%eax
  801584:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801587:	5b                   	pop    %ebx
  801588:	5e                   	pop    %esi
  801589:	5d                   	pop    %ebp
  80158a:	c3                   	ret    

0080158b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80158b:	55                   	push   %ebp
  80158c:	89 e5                	mov    %esp,%ebp
  80158e:	53                   	push   %ebx
  80158f:	83 ec 0c             	sub    $0xc,%esp
  801592:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801595:	53                   	push   %ebx
  801596:	6a 00                	push   $0x0
  801598:	e8 43 f6 ff ff       	call   800be0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80159d:	89 1c 24             	mov    %ebx,(%esp)
  8015a0:	e8 b7 f7 ff ff       	call   800d5c <fd2data>
  8015a5:	83 c4 08             	add    $0x8,%esp
  8015a8:	50                   	push   %eax
  8015a9:	6a 00                	push   $0x0
  8015ab:	e8 30 f6 ff ff       	call   800be0 <sys_page_unmap>
}
  8015b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b3:	c9                   	leave  
  8015b4:	c3                   	ret    

008015b5 <_pipeisclosed>:
{
  8015b5:	55                   	push   %ebp
  8015b6:	89 e5                	mov    %esp,%ebp
  8015b8:	57                   	push   %edi
  8015b9:	56                   	push   %esi
  8015ba:	53                   	push   %ebx
  8015bb:	83 ec 1c             	sub    $0x1c,%esp
  8015be:	89 c7                	mov    %eax,%edi
  8015c0:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8015c2:	a1 04 40 80 00       	mov    0x804004,%eax
  8015c7:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8015ca:	83 ec 0c             	sub    $0xc,%esp
  8015cd:	57                   	push   %edi
  8015ce:	e8 7e 05 00 00       	call   801b51 <pageref>
  8015d3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8015d6:	89 34 24             	mov    %esi,(%esp)
  8015d9:	e8 73 05 00 00       	call   801b51 <pageref>
		nn = thisenv->env_runs;
  8015de:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8015e4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8015e7:	83 c4 10             	add    $0x10,%esp
  8015ea:	39 cb                	cmp    %ecx,%ebx
  8015ec:	74 1b                	je     801609 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8015ee:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8015f1:	75 cf                	jne    8015c2 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8015f3:	8b 42 58             	mov    0x58(%edx),%eax
  8015f6:	6a 01                	push   $0x1
  8015f8:	50                   	push   %eax
  8015f9:	53                   	push   %ebx
  8015fa:	68 f2 21 80 00       	push   $0x8021f2
  8015ff:	e8 3f eb ff ff       	call   800143 <cprintf>
  801604:	83 c4 10             	add    $0x10,%esp
  801607:	eb b9                	jmp    8015c2 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801609:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80160c:	0f 94 c0             	sete   %al
  80160f:	0f b6 c0             	movzbl %al,%eax
}
  801612:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801615:	5b                   	pop    %ebx
  801616:	5e                   	pop    %esi
  801617:	5f                   	pop    %edi
  801618:	5d                   	pop    %ebp
  801619:	c3                   	ret    

0080161a <devpipe_write>:
{
  80161a:	55                   	push   %ebp
  80161b:	89 e5                	mov    %esp,%ebp
  80161d:	57                   	push   %edi
  80161e:	56                   	push   %esi
  80161f:	53                   	push   %ebx
  801620:	83 ec 28             	sub    $0x28,%esp
  801623:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801626:	56                   	push   %esi
  801627:	e8 30 f7 ff ff       	call   800d5c <fd2data>
  80162c:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80162e:	83 c4 10             	add    $0x10,%esp
  801631:	bf 00 00 00 00       	mov    $0x0,%edi
  801636:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801639:	74 4f                	je     80168a <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80163b:	8b 43 04             	mov    0x4(%ebx),%eax
  80163e:	8b 0b                	mov    (%ebx),%ecx
  801640:	8d 51 20             	lea    0x20(%ecx),%edx
  801643:	39 d0                	cmp    %edx,%eax
  801645:	72 14                	jb     80165b <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801647:	89 da                	mov    %ebx,%edx
  801649:	89 f0                	mov    %esi,%eax
  80164b:	e8 65 ff ff ff       	call   8015b5 <_pipeisclosed>
  801650:	85 c0                	test   %eax,%eax
  801652:	75 3a                	jne    80168e <devpipe_write+0x74>
			sys_yield();
  801654:	e8 e3 f4 ff ff       	call   800b3c <sys_yield>
  801659:	eb e0                	jmp    80163b <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80165b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80165e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801662:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801665:	89 c2                	mov    %eax,%edx
  801667:	c1 fa 1f             	sar    $0x1f,%edx
  80166a:	89 d1                	mov    %edx,%ecx
  80166c:	c1 e9 1b             	shr    $0x1b,%ecx
  80166f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801672:	83 e2 1f             	and    $0x1f,%edx
  801675:	29 ca                	sub    %ecx,%edx
  801677:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80167b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80167f:	83 c0 01             	add    $0x1,%eax
  801682:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801685:	83 c7 01             	add    $0x1,%edi
  801688:	eb ac                	jmp    801636 <devpipe_write+0x1c>
	return i;
  80168a:	89 f8                	mov    %edi,%eax
  80168c:	eb 05                	jmp    801693 <devpipe_write+0x79>
				return 0;
  80168e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801693:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801696:	5b                   	pop    %ebx
  801697:	5e                   	pop    %esi
  801698:	5f                   	pop    %edi
  801699:	5d                   	pop    %ebp
  80169a:	c3                   	ret    

0080169b <devpipe_read>:
{
  80169b:	55                   	push   %ebp
  80169c:	89 e5                	mov    %esp,%ebp
  80169e:	57                   	push   %edi
  80169f:	56                   	push   %esi
  8016a0:	53                   	push   %ebx
  8016a1:	83 ec 18             	sub    $0x18,%esp
  8016a4:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8016a7:	57                   	push   %edi
  8016a8:	e8 af f6 ff ff       	call   800d5c <fd2data>
  8016ad:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8016af:	83 c4 10             	add    $0x10,%esp
  8016b2:	be 00 00 00 00       	mov    $0x0,%esi
  8016b7:	3b 75 10             	cmp    0x10(%ebp),%esi
  8016ba:	74 47                	je     801703 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  8016bc:	8b 03                	mov    (%ebx),%eax
  8016be:	3b 43 04             	cmp    0x4(%ebx),%eax
  8016c1:	75 22                	jne    8016e5 <devpipe_read+0x4a>
			if (i > 0)
  8016c3:	85 f6                	test   %esi,%esi
  8016c5:	75 14                	jne    8016db <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  8016c7:	89 da                	mov    %ebx,%edx
  8016c9:	89 f8                	mov    %edi,%eax
  8016cb:	e8 e5 fe ff ff       	call   8015b5 <_pipeisclosed>
  8016d0:	85 c0                	test   %eax,%eax
  8016d2:	75 33                	jne    801707 <devpipe_read+0x6c>
			sys_yield();
  8016d4:	e8 63 f4 ff ff       	call   800b3c <sys_yield>
  8016d9:	eb e1                	jmp    8016bc <devpipe_read+0x21>
				return i;
  8016db:	89 f0                	mov    %esi,%eax
}
  8016dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016e0:	5b                   	pop    %ebx
  8016e1:	5e                   	pop    %esi
  8016e2:	5f                   	pop    %edi
  8016e3:	5d                   	pop    %ebp
  8016e4:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016e5:	99                   	cltd   
  8016e6:	c1 ea 1b             	shr    $0x1b,%edx
  8016e9:	01 d0                	add    %edx,%eax
  8016eb:	83 e0 1f             	and    $0x1f,%eax
  8016ee:	29 d0                	sub    %edx,%eax
  8016f0:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8016f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016f8:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8016fb:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8016fe:	83 c6 01             	add    $0x1,%esi
  801701:	eb b4                	jmp    8016b7 <devpipe_read+0x1c>
	return i;
  801703:	89 f0                	mov    %esi,%eax
  801705:	eb d6                	jmp    8016dd <devpipe_read+0x42>
				return 0;
  801707:	b8 00 00 00 00       	mov    $0x0,%eax
  80170c:	eb cf                	jmp    8016dd <devpipe_read+0x42>

0080170e <pipe>:
{
  80170e:	55                   	push   %ebp
  80170f:	89 e5                	mov    %esp,%ebp
  801711:	56                   	push   %esi
  801712:	53                   	push   %ebx
  801713:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801716:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801719:	50                   	push   %eax
  80171a:	e8 54 f6 ff ff       	call   800d73 <fd_alloc>
  80171f:	89 c3                	mov    %eax,%ebx
  801721:	83 c4 10             	add    $0x10,%esp
  801724:	85 c0                	test   %eax,%eax
  801726:	78 5b                	js     801783 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801728:	83 ec 04             	sub    $0x4,%esp
  80172b:	68 07 04 00 00       	push   $0x407
  801730:	ff 75 f4             	pushl  -0xc(%ebp)
  801733:	6a 00                	push   $0x0
  801735:	e8 21 f4 ff ff       	call   800b5b <sys_page_alloc>
  80173a:	89 c3                	mov    %eax,%ebx
  80173c:	83 c4 10             	add    $0x10,%esp
  80173f:	85 c0                	test   %eax,%eax
  801741:	78 40                	js     801783 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  801743:	83 ec 0c             	sub    $0xc,%esp
  801746:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801749:	50                   	push   %eax
  80174a:	e8 24 f6 ff ff       	call   800d73 <fd_alloc>
  80174f:	89 c3                	mov    %eax,%ebx
  801751:	83 c4 10             	add    $0x10,%esp
  801754:	85 c0                	test   %eax,%eax
  801756:	78 1b                	js     801773 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801758:	83 ec 04             	sub    $0x4,%esp
  80175b:	68 07 04 00 00       	push   $0x407
  801760:	ff 75 f0             	pushl  -0x10(%ebp)
  801763:	6a 00                	push   $0x0
  801765:	e8 f1 f3 ff ff       	call   800b5b <sys_page_alloc>
  80176a:	89 c3                	mov    %eax,%ebx
  80176c:	83 c4 10             	add    $0x10,%esp
  80176f:	85 c0                	test   %eax,%eax
  801771:	79 19                	jns    80178c <pipe+0x7e>
	sys_page_unmap(0, fd0);
  801773:	83 ec 08             	sub    $0x8,%esp
  801776:	ff 75 f4             	pushl  -0xc(%ebp)
  801779:	6a 00                	push   $0x0
  80177b:	e8 60 f4 ff ff       	call   800be0 <sys_page_unmap>
  801780:	83 c4 10             	add    $0x10,%esp
}
  801783:	89 d8                	mov    %ebx,%eax
  801785:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801788:	5b                   	pop    %ebx
  801789:	5e                   	pop    %esi
  80178a:	5d                   	pop    %ebp
  80178b:	c3                   	ret    
	va = fd2data(fd0);
  80178c:	83 ec 0c             	sub    $0xc,%esp
  80178f:	ff 75 f4             	pushl  -0xc(%ebp)
  801792:	e8 c5 f5 ff ff       	call   800d5c <fd2data>
  801797:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801799:	83 c4 0c             	add    $0xc,%esp
  80179c:	68 07 04 00 00       	push   $0x407
  8017a1:	50                   	push   %eax
  8017a2:	6a 00                	push   $0x0
  8017a4:	e8 b2 f3 ff ff       	call   800b5b <sys_page_alloc>
  8017a9:	89 c3                	mov    %eax,%ebx
  8017ab:	83 c4 10             	add    $0x10,%esp
  8017ae:	85 c0                	test   %eax,%eax
  8017b0:	0f 88 8c 00 00 00    	js     801842 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017b6:	83 ec 0c             	sub    $0xc,%esp
  8017b9:	ff 75 f0             	pushl  -0x10(%ebp)
  8017bc:	e8 9b f5 ff ff       	call   800d5c <fd2data>
  8017c1:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8017c8:	50                   	push   %eax
  8017c9:	6a 00                	push   $0x0
  8017cb:	56                   	push   %esi
  8017cc:	6a 00                	push   $0x0
  8017ce:	e8 cb f3 ff ff       	call   800b9e <sys_page_map>
  8017d3:	89 c3                	mov    %eax,%ebx
  8017d5:	83 c4 20             	add    $0x20,%esp
  8017d8:	85 c0                	test   %eax,%eax
  8017da:	78 58                	js     801834 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  8017dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017df:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017e5:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8017e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017ea:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  8017f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017f4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017fa:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8017fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ff:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801806:	83 ec 0c             	sub    $0xc,%esp
  801809:	ff 75 f4             	pushl  -0xc(%ebp)
  80180c:	e8 3b f5 ff ff       	call   800d4c <fd2num>
  801811:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801814:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801816:	83 c4 04             	add    $0x4,%esp
  801819:	ff 75 f0             	pushl  -0x10(%ebp)
  80181c:	e8 2b f5 ff ff       	call   800d4c <fd2num>
  801821:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801824:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801827:	83 c4 10             	add    $0x10,%esp
  80182a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80182f:	e9 4f ff ff ff       	jmp    801783 <pipe+0x75>
	sys_page_unmap(0, va);
  801834:	83 ec 08             	sub    $0x8,%esp
  801837:	56                   	push   %esi
  801838:	6a 00                	push   $0x0
  80183a:	e8 a1 f3 ff ff       	call   800be0 <sys_page_unmap>
  80183f:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801842:	83 ec 08             	sub    $0x8,%esp
  801845:	ff 75 f0             	pushl  -0x10(%ebp)
  801848:	6a 00                	push   $0x0
  80184a:	e8 91 f3 ff ff       	call   800be0 <sys_page_unmap>
  80184f:	83 c4 10             	add    $0x10,%esp
  801852:	e9 1c ff ff ff       	jmp    801773 <pipe+0x65>

00801857 <pipeisclosed>:
{
  801857:	55                   	push   %ebp
  801858:	89 e5                	mov    %esp,%ebp
  80185a:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80185d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801860:	50                   	push   %eax
  801861:	ff 75 08             	pushl  0x8(%ebp)
  801864:	e8 59 f5 ff ff       	call   800dc2 <fd_lookup>
  801869:	83 c4 10             	add    $0x10,%esp
  80186c:	85 c0                	test   %eax,%eax
  80186e:	78 18                	js     801888 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801870:	83 ec 0c             	sub    $0xc,%esp
  801873:	ff 75 f4             	pushl  -0xc(%ebp)
  801876:	e8 e1 f4 ff ff       	call   800d5c <fd2data>
	return _pipeisclosed(fd, p);
  80187b:	89 c2                	mov    %eax,%edx
  80187d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801880:	e8 30 fd ff ff       	call   8015b5 <_pipeisclosed>
  801885:	83 c4 10             	add    $0x10,%esp
}
  801888:	c9                   	leave  
  801889:	c3                   	ret    

0080188a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80188a:	55                   	push   %ebp
  80188b:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80188d:	b8 00 00 00 00       	mov    $0x0,%eax
  801892:	5d                   	pop    %ebp
  801893:	c3                   	ret    

00801894 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801894:	55                   	push   %ebp
  801895:	89 e5                	mov    %esp,%ebp
  801897:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80189a:	68 0a 22 80 00       	push   $0x80220a
  80189f:	ff 75 0c             	pushl  0xc(%ebp)
  8018a2:	e8 bb ee ff ff       	call   800762 <strcpy>
	return 0;
}
  8018a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8018ac:	c9                   	leave  
  8018ad:	c3                   	ret    

008018ae <devcons_write>:
{
  8018ae:	55                   	push   %ebp
  8018af:	89 e5                	mov    %esp,%ebp
  8018b1:	57                   	push   %edi
  8018b2:	56                   	push   %esi
  8018b3:	53                   	push   %ebx
  8018b4:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8018ba:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8018bf:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8018c5:	eb 2f                	jmp    8018f6 <devcons_write+0x48>
		m = n - tot;
  8018c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8018ca:	29 f3                	sub    %esi,%ebx
  8018cc:	83 fb 7f             	cmp    $0x7f,%ebx
  8018cf:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8018d4:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8018d7:	83 ec 04             	sub    $0x4,%esp
  8018da:	53                   	push   %ebx
  8018db:	89 f0                	mov    %esi,%eax
  8018dd:	03 45 0c             	add    0xc(%ebp),%eax
  8018e0:	50                   	push   %eax
  8018e1:	57                   	push   %edi
  8018e2:	e8 09 f0 ff ff       	call   8008f0 <memmove>
		sys_cputs(buf, m);
  8018e7:	83 c4 08             	add    $0x8,%esp
  8018ea:	53                   	push   %ebx
  8018eb:	57                   	push   %edi
  8018ec:	e8 ae f1 ff ff       	call   800a9f <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8018f1:	01 de                	add    %ebx,%esi
  8018f3:	83 c4 10             	add    $0x10,%esp
  8018f6:	3b 75 10             	cmp    0x10(%ebp),%esi
  8018f9:	72 cc                	jb     8018c7 <devcons_write+0x19>
}
  8018fb:	89 f0                	mov    %esi,%eax
  8018fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801900:	5b                   	pop    %ebx
  801901:	5e                   	pop    %esi
  801902:	5f                   	pop    %edi
  801903:	5d                   	pop    %ebp
  801904:	c3                   	ret    

00801905 <devcons_read>:
{
  801905:	55                   	push   %ebp
  801906:	89 e5                	mov    %esp,%ebp
  801908:	83 ec 08             	sub    $0x8,%esp
  80190b:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801910:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801914:	75 07                	jne    80191d <devcons_read+0x18>
}
  801916:	c9                   	leave  
  801917:	c3                   	ret    
		sys_yield();
  801918:	e8 1f f2 ff ff       	call   800b3c <sys_yield>
	while ((c = sys_cgetc()) == 0)
  80191d:	e8 9b f1 ff ff       	call   800abd <sys_cgetc>
  801922:	85 c0                	test   %eax,%eax
  801924:	74 f2                	je     801918 <devcons_read+0x13>
	if (c < 0)
  801926:	85 c0                	test   %eax,%eax
  801928:	78 ec                	js     801916 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  80192a:	83 f8 04             	cmp    $0x4,%eax
  80192d:	74 0c                	je     80193b <devcons_read+0x36>
	*(char*)vbuf = c;
  80192f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801932:	88 02                	mov    %al,(%edx)
	return 1;
  801934:	b8 01 00 00 00       	mov    $0x1,%eax
  801939:	eb db                	jmp    801916 <devcons_read+0x11>
		return 0;
  80193b:	b8 00 00 00 00       	mov    $0x0,%eax
  801940:	eb d4                	jmp    801916 <devcons_read+0x11>

00801942 <cputchar>:
{
  801942:	55                   	push   %ebp
  801943:	89 e5                	mov    %esp,%ebp
  801945:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801948:	8b 45 08             	mov    0x8(%ebp),%eax
  80194b:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  80194e:	6a 01                	push   $0x1
  801950:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801953:	50                   	push   %eax
  801954:	e8 46 f1 ff ff       	call   800a9f <sys_cputs>
}
  801959:	83 c4 10             	add    $0x10,%esp
  80195c:	c9                   	leave  
  80195d:	c3                   	ret    

0080195e <getchar>:
{
  80195e:	55                   	push   %ebp
  80195f:	89 e5                	mov    %esp,%ebp
  801961:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801964:	6a 01                	push   $0x1
  801966:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801969:	50                   	push   %eax
  80196a:	6a 00                	push   $0x0
  80196c:	e8 c2 f6 ff ff       	call   801033 <read>
	if (r < 0)
  801971:	83 c4 10             	add    $0x10,%esp
  801974:	85 c0                	test   %eax,%eax
  801976:	78 08                	js     801980 <getchar+0x22>
	if (r < 1)
  801978:	85 c0                	test   %eax,%eax
  80197a:	7e 06                	jle    801982 <getchar+0x24>
	return c;
  80197c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801980:	c9                   	leave  
  801981:	c3                   	ret    
		return -E_EOF;
  801982:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801987:	eb f7                	jmp    801980 <getchar+0x22>

00801989 <iscons>:
{
  801989:	55                   	push   %ebp
  80198a:	89 e5                	mov    %esp,%ebp
  80198c:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80198f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801992:	50                   	push   %eax
  801993:	ff 75 08             	pushl  0x8(%ebp)
  801996:	e8 27 f4 ff ff       	call   800dc2 <fd_lookup>
  80199b:	83 c4 10             	add    $0x10,%esp
  80199e:	85 c0                	test   %eax,%eax
  8019a0:	78 11                	js     8019b3 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  8019a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019a5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019ab:	39 10                	cmp    %edx,(%eax)
  8019ad:	0f 94 c0             	sete   %al
  8019b0:	0f b6 c0             	movzbl %al,%eax
}
  8019b3:	c9                   	leave  
  8019b4:	c3                   	ret    

008019b5 <opencons>:
{
  8019b5:	55                   	push   %ebp
  8019b6:	89 e5                	mov    %esp,%ebp
  8019b8:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8019bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019be:	50                   	push   %eax
  8019bf:	e8 af f3 ff ff       	call   800d73 <fd_alloc>
  8019c4:	83 c4 10             	add    $0x10,%esp
  8019c7:	85 c0                	test   %eax,%eax
  8019c9:	78 3a                	js     801a05 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019cb:	83 ec 04             	sub    $0x4,%esp
  8019ce:	68 07 04 00 00       	push   $0x407
  8019d3:	ff 75 f4             	pushl  -0xc(%ebp)
  8019d6:	6a 00                	push   $0x0
  8019d8:	e8 7e f1 ff ff       	call   800b5b <sys_page_alloc>
  8019dd:	83 c4 10             	add    $0x10,%esp
  8019e0:	85 c0                	test   %eax,%eax
  8019e2:	78 21                	js     801a05 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8019e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019e7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019ed:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8019ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019f2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8019f9:	83 ec 0c             	sub    $0xc,%esp
  8019fc:	50                   	push   %eax
  8019fd:	e8 4a f3 ff ff       	call   800d4c <fd2num>
  801a02:	83 c4 10             	add    $0x10,%esp
}
  801a05:	c9                   	leave  
  801a06:	c3                   	ret    

00801a07 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a07:	55                   	push   %ebp
  801a08:	89 e5                	mov    %esp,%ebp
  801a0a:	56                   	push   %esi
  801a0b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a0c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a0f:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a15:	e8 03 f1 ff ff       	call   800b1d <sys_getenvid>
  801a1a:	83 ec 0c             	sub    $0xc,%esp
  801a1d:	ff 75 0c             	pushl  0xc(%ebp)
  801a20:	ff 75 08             	pushl  0x8(%ebp)
  801a23:	56                   	push   %esi
  801a24:	50                   	push   %eax
  801a25:	68 18 22 80 00       	push   $0x802218
  801a2a:	e8 14 e7 ff ff       	call   800143 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a2f:	83 c4 18             	add    $0x18,%esp
  801a32:	53                   	push   %ebx
  801a33:	ff 75 10             	pushl  0x10(%ebp)
  801a36:	e8 b7 e6 ff ff       	call   8000f2 <vcprintf>
	cprintf("\n");
  801a3b:	c7 04 24 fc 1d 80 00 	movl   $0x801dfc,(%esp)
  801a42:	e8 fc e6 ff ff       	call   800143 <cprintf>
  801a47:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a4a:	cc                   	int3   
  801a4b:	eb fd                	jmp    801a4a <_panic+0x43>

00801a4d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a4d:	55                   	push   %ebp
  801a4e:	89 e5                	mov    %esp,%ebp
  801a50:	56                   	push   %esi
  801a51:	53                   	push   %ebx
  801a52:	8b 75 08             	mov    0x8(%ebp),%esi
  801a55:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a58:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        //	panic("ipc_recv not implemented");
        int r;
       	if(pg!=NULL){
  801a5b:	85 c0                	test   %eax,%eax
  801a5d:	74 3b                	je     801a9a <ipc_recv+0x4d>
	  r = sys_ipc_recv(pg);
  801a5f:	83 ec 0c             	sub    $0xc,%esp
  801a62:	50                   	push   %eax
  801a63:	e8 a3 f2 ff ff       	call   800d0b <sys_ipc_recv>
  801a68:	83 c4 10             	add    $0x10,%esp
	}else
	  r = sys_ipc_recv((void *)UTOP);
	if(r<0){
  801a6b:	85 c0                	test   %eax,%eax
  801a6d:	78 3d                	js     801aac <ipc_recv+0x5f>
	if(perm_store!=NULL){
		*perm_store = 0;
            }
        	return r;
           }else{
	     if(from_env_store!=NULL)
  801a6f:	85 f6                	test   %esi,%esi
  801a71:	74 0a                	je     801a7d <ipc_recv+0x30>
		     *from_env_store = thisenv->env_ipc_from;
  801a73:	a1 04 40 80 00       	mov    0x804004,%eax
  801a78:	8b 40 74             	mov    0x74(%eax),%eax
  801a7b:	89 06                	mov    %eax,(%esi)
	     if(perm_store != NULL)
  801a7d:	85 db                	test   %ebx,%ebx
  801a7f:	74 0a                	je     801a8b <ipc_recv+0x3e>
		     *perm_store = thisenv->env_ipc_perm;
  801a81:	a1 04 40 80 00       	mov    0x804004,%eax
  801a86:	8b 40 78             	mov    0x78(%eax),%eax
  801a89:	89 03                	mov    %eax,(%ebx)
	     return thisenv->env_ipc_value;
  801a8b:	a1 04 40 80 00       	mov    0x804004,%eax
  801a90:	8b 40 70             	mov    0x70(%eax),%eax
	   }

}
  801a93:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a96:	5b                   	pop    %ebx
  801a97:	5e                   	pop    %esi
  801a98:	5d                   	pop    %ebp
  801a99:	c3                   	ret    
	  r = sys_ipc_recv((void *)UTOP);
  801a9a:	83 ec 0c             	sub    $0xc,%esp
  801a9d:	68 00 00 c0 ee       	push   $0xeec00000
  801aa2:	e8 64 f2 ff ff       	call   800d0b <sys_ipc_recv>
  801aa7:	83 c4 10             	add    $0x10,%esp
  801aaa:	eb bf                	jmp    801a6b <ipc_recv+0x1e>
	if(from_env_store!=NULL){
  801aac:	85 f6                	test   %esi,%esi
  801aae:	74 06                	je     801ab6 <ipc_recv+0x69>
	  *from_env_store = 0;
  801ab0:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if(perm_store!=NULL){
  801ab6:	85 db                	test   %ebx,%ebx
  801ab8:	74 d9                	je     801a93 <ipc_recv+0x46>
		*perm_store = 0;
  801aba:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ac0:	eb d1                	jmp    801a93 <ipc_recv+0x46>

00801ac2 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ac2:	55                   	push   %ebp
  801ac3:	89 e5                	mov    %esp,%ebp
  801ac5:	57                   	push   %edi
  801ac6:	56                   	push   %esi
  801ac7:	53                   	push   %ebx
  801ac8:	83 ec 0c             	sub    $0xc,%esp
  801acb:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ace:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ad1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if(pg==NULL) pg = (void *)UTOP;
  801ad4:	85 db                	test   %ebx,%ebx
  801ad6:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801adb:	0f 44 d8             	cmove  %eax,%ebx
	while((r=sys_ipc_try_send(to_env,val,pg,perm))<0){
  801ade:	ff 75 14             	pushl  0x14(%ebp)
  801ae1:	53                   	push   %ebx
  801ae2:	56                   	push   %esi
  801ae3:	57                   	push   %edi
  801ae4:	e8 ff f1 ff ff       	call   800ce8 <sys_ipc_try_send>
  801ae9:	83 c4 10             	add    $0x10,%esp
  801aec:	85 c0                	test   %eax,%eax
  801aee:	79 20                	jns    801b10 <ipc_send+0x4e>
	    if(r!=-E_IPC_NOT_RECV){
  801af0:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801af3:	75 07                	jne    801afc <ipc_send+0x3a>
		    panic("ipc_send:send message failed\n");
	    }
	    sys_yield();
  801af5:	e8 42 f0 ff ff       	call   800b3c <sys_yield>
  801afa:	eb e2                	jmp    801ade <ipc_send+0x1c>
		    panic("ipc_send:send message failed\n");
  801afc:	83 ec 04             	sub    $0x4,%esp
  801aff:	68 3c 22 80 00       	push   $0x80223c
  801b04:	6a 43                	push   $0x43
  801b06:	68 5a 22 80 00       	push   $0x80225a
  801b0b:	e8 f7 fe ff ff       	call   801a07 <_panic>
	}

}
  801b10:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b13:	5b                   	pop    %ebx
  801b14:	5e                   	pop    %esi
  801b15:	5f                   	pop    %edi
  801b16:	5d                   	pop    %ebp
  801b17:	c3                   	ret    

00801b18 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b18:	55                   	push   %ebp
  801b19:	89 e5                	mov    %esp,%ebp
  801b1b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b1e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b23:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b26:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b2c:	8b 52 50             	mov    0x50(%edx),%edx
  801b2f:	39 ca                	cmp    %ecx,%edx
  801b31:	74 11                	je     801b44 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801b33:	83 c0 01             	add    $0x1,%eax
  801b36:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b3b:	75 e6                	jne    801b23 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801b3d:	b8 00 00 00 00       	mov    $0x0,%eax
  801b42:	eb 0b                	jmp    801b4f <ipc_find_env+0x37>
			return envs[i].env_id;
  801b44:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b47:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b4c:	8b 40 48             	mov    0x48(%eax),%eax
}
  801b4f:	5d                   	pop    %ebp
  801b50:	c3                   	ret    

00801b51 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b51:	55                   	push   %ebp
  801b52:	89 e5                	mov    %esp,%ebp
  801b54:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b57:	89 d0                	mov    %edx,%eax
  801b59:	c1 e8 16             	shr    $0x16,%eax
  801b5c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b63:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801b68:	f6 c1 01             	test   $0x1,%cl
  801b6b:	74 1d                	je     801b8a <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801b6d:	c1 ea 0c             	shr    $0xc,%edx
  801b70:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b77:	f6 c2 01             	test   $0x1,%dl
  801b7a:	74 0e                	je     801b8a <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b7c:	c1 ea 0c             	shr    $0xc,%edx
  801b7f:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b86:	ef 
  801b87:	0f b7 c0             	movzwl %ax,%eax
}
  801b8a:	5d                   	pop    %ebp
  801b8b:	c3                   	ret    
  801b8c:	66 90                	xchg   %ax,%ax
  801b8e:	66 90                	xchg   %ax,%ax

00801b90 <__udivdi3>:
  801b90:	55                   	push   %ebp
  801b91:	57                   	push   %edi
  801b92:	56                   	push   %esi
  801b93:	53                   	push   %ebx
  801b94:	83 ec 1c             	sub    $0x1c,%esp
  801b97:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801b9b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801b9f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801ba3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801ba7:	85 d2                	test   %edx,%edx
  801ba9:	75 35                	jne    801be0 <__udivdi3+0x50>
  801bab:	39 f3                	cmp    %esi,%ebx
  801bad:	0f 87 bd 00 00 00    	ja     801c70 <__udivdi3+0xe0>
  801bb3:	85 db                	test   %ebx,%ebx
  801bb5:	89 d9                	mov    %ebx,%ecx
  801bb7:	75 0b                	jne    801bc4 <__udivdi3+0x34>
  801bb9:	b8 01 00 00 00       	mov    $0x1,%eax
  801bbe:	31 d2                	xor    %edx,%edx
  801bc0:	f7 f3                	div    %ebx
  801bc2:	89 c1                	mov    %eax,%ecx
  801bc4:	31 d2                	xor    %edx,%edx
  801bc6:	89 f0                	mov    %esi,%eax
  801bc8:	f7 f1                	div    %ecx
  801bca:	89 c6                	mov    %eax,%esi
  801bcc:	89 e8                	mov    %ebp,%eax
  801bce:	89 f7                	mov    %esi,%edi
  801bd0:	f7 f1                	div    %ecx
  801bd2:	89 fa                	mov    %edi,%edx
  801bd4:	83 c4 1c             	add    $0x1c,%esp
  801bd7:	5b                   	pop    %ebx
  801bd8:	5e                   	pop    %esi
  801bd9:	5f                   	pop    %edi
  801bda:	5d                   	pop    %ebp
  801bdb:	c3                   	ret    
  801bdc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801be0:	39 f2                	cmp    %esi,%edx
  801be2:	77 7c                	ja     801c60 <__udivdi3+0xd0>
  801be4:	0f bd fa             	bsr    %edx,%edi
  801be7:	83 f7 1f             	xor    $0x1f,%edi
  801bea:	0f 84 98 00 00 00    	je     801c88 <__udivdi3+0xf8>
  801bf0:	89 f9                	mov    %edi,%ecx
  801bf2:	b8 20 00 00 00       	mov    $0x20,%eax
  801bf7:	29 f8                	sub    %edi,%eax
  801bf9:	d3 e2                	shl    %cl,%edx
  801bfb:	89 54 24 08          	mov    %edx,0x8(%esp)
  801bff:	89 c1                	mov    %eax,%ecx
  801c01:	89 da                	mov    %ebx,%edx
  801c03:	d3 ea                	shr    %cl,%edx
  801c05:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801c09:	09 d1                	or     %edx,%ecx
  801c0b:	89 f2                	mov    %esi,%edx
  801c0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c11:	89 f9                	mov    %edi,%ecx
  801c13:	d3 e3                	shl    %cl,%ebx
  801c15:	89 c1                	mov    %eax,%ecx
  801c17:	d3 ea                	shr    %cl,%edx
  801c19:	89 f9                	mov    %edi,%ecx
  801c1b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c1f:	d3 e6                	shl    %cl,%esi
  801c21:	89 eb                	mov    %ebp,%ebx
  801c23:	89 c1                	mov    %eax,%ecx
  801c25:	d3 eb                	shr    %cl,%ebx
  801c27:	09 de                	or     %ebx,%esi
  801c29:	89 f0                	mov    %esi,%eax
  801c2b:	f7 74 24 08          	divl   0x8(%esp)
  801c2f:	89 d6                	mov    %edx,%esi
  801c31:	89 c3                	mov    %eax,%ebx
  801c33:	f7 64 24 0c          	mull   0xc(%esp)
  801c37:	39 d6                	cmp    %edx,%esi
  801c39:	72 0c                	jb     801c47 <__udivdi3+0xb7>
  801c3b:	89 f9                	mov    %edi,%ecx
  801c3d:	d3 e5                	shl    %cl,%ebp
  801c3f:	39 c5                	cmp    %eax,%ebp
  801c41:	73 5d                	jae    801ca0 <__udivdi3+0x110>
  801c43:	39 d6                	cmp    %edx,%esi
  801c45:	75 59                	jne    801ca0 <__udivdi3+0x110>
  801c47:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801c4a:	31 ff                	xor    %edi,%edi
  801c4c:	89 fa                	mov    %edi,%edx
  801c4e:	83 c4 1c             	add    $0x1c,%esp
  801c51:	5b                   	pop    %ebx
  801c52:	5e                   	pop    %esi
  801c53:	5f                   	pop    %edi
  801c54:	5d                   	pop    %ebp
  801c55:	c3                   	ret    
  801c56:	8d 76 00             	lea    0x0(%esi),%esi
  801c59:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801c60:	31 ff                	xor    %edi,%edi
  801c62:	31 c0                	xor    %eax,%eax
  801c64:	89 fa                	mov    %edi,%edx
  801c66:	83 c4 1c             	add    $0x1c,%esp
  801c69:	5b                   	pop    %ebx
  801c6a:	5e                   	pop    %esi
  801c6b:	5f                   	pop    %edi
  801c6c:	5d                   	pop    %ebp
  801c6d:	c3                   	ret    
  801c6e:	66 90                	xchg   %ax,%ax
  801c70:	31 ff                	xor    %edi,%edi
  801c72:	89 e8                	mov    %ebp,%eax
  801c74:	89 f2                	mov    %esi,%edx
  801c76:	f7 f3                	div    %ebx
  801c78:	89 fa                	mov    %edi,%edx
  801c7a:	83 c4 1c             	add    $0x1c,%esp
  801c7d:	5b                   	pop    %ebx
  801c7e:	5e                   	pop    %esi
  801c7f:	5f                   	pop    %edi
  801c80:	5d                   	pop    %ebp
  801c81:	c3                   	ret    
  801c82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c88:	39 f2                	cmp    %esi,%edx
  801c8a:	72 06                	jb     801c92 <__udivdi3+0x102>
  801c8c:	31 c0                	xor    %eax,%eax
  801c8e:	39 eb                	cmp    %ebp,%ebx
  801c90:	77 d2                	ja     801c64 <__udivdi3+0xd4>
  801c92:	b8 01 00 00 00       	mov    $0x1,%eax
  801c97:	eb cb                	jmp    801c64 <__udivdi3+0xd4>
  801c99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ca0:	89 d8                	mov    %ebx,%eax
  801ca2:	31 ff                	xor    %edi,%edi
  801ca4:	eb be                	jmp    801c64 <__udivdi3+0xd4>
  801ca6:	66 90                	xchg   %ax,%ax
  801ca8:	66 90                	xchg   %ax,%ax
  801caa:	66 90                	xchg   %ax,%ax
  801cac:	66 90                	xchg   %ax,%ax
  801cae:	66 90                	xchg   %ax,%ax

00801cb0 <__umoddi3>:
  801cb0:	55                   	push   %ebp
  801cb1:	57                   	push   %edi
  801cb2:	56                   	push   %esi
  801cb3:	53                   	push   %ebx
  801cb4:	83 ec 1c             	sub    $0x1c,%esp
  801cb7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801cbb:	8b 74 24 30          	mov    0x30(%esp),%esi
  801cbf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801cc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801cc7:	85 ed                	test   %ebp,%ebp
  801cc9:	89 f0                	mov    %esi,%eax
  801ccb:	89 da                	mov    %ebx,%edx
  801ccd:	75 19                	jne    801ce8 <__umoddi3+0x38>
  801ccf:	39 df                	cmp    %ebx,%edi
  801cd1:	0f 86 b1 00 00 00    	jbe    801d88 <__umoddi3+0xd8>
  801cd7:	f7 f7                	div    %edi
  801cd9:	89 d0                	mov    %edx,%eax
  801cdb:	31 d2                	xor    %edx,%edx
  801cdd:	83 c4 1c             	add    $0x1c,%esp
  801ce0:	5b                   	pop    %ebx
  801ce1:	5e                   	pop    %esi
  801ce2:	5f                   	pop    %edi
  801ce3:	5d                   	pop    %ebp
  801ce4:	c3                   	ret    
  801ce5:	8d 76 00             	lea    0x0(%esi),%esi
  801ce8:	39 dd                	cmp    %ebx,%ebp
  801cea:	77 f1                	ja     801cdd <__umoddi3+0x2d>
  801cec:	0f bd cd             	bsr    %ebp,%ecx
  801cef:	83 f1 1f             	xor    $0x1f,%ecx
  801cf2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801cf6:	0f 84 b4 00 00 00    	je     801db0 <__umoddi3+0x100>
  801cfc:	b8 20 00 00 00       	mov    $0x20,%eax
  801d01:	89 c2                	mov    %eax,%edx
  801d03:	8b 44 24 04          	mov    0x4(%esp),%eax
  801d07:	29 c2                	sub    %eax,%edx
  801d09:	89 c1                	mov    %eax,%ecx
  801d0b:	89 f8                	mov    %edi,%eax
  801d0d:	d3 e5                	shl    %cl,%ebp
  801d0f:	89 d1                	mov    %edx,%ecx
  801d11:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801d15:	d3 e8                	shr    %cl,%eax
  801d17:	09 c5                	or     %eax,%ebp
  801d19:	8b 44 24 04          	mov    0x4(%esp),%eax
  801d1d:	89 c1                	mov    %eax,%ecx
  801d1f:	d3 e7                	shl    %cl,%edi
  801d21:	89 d1                	mov    %edx,%ecx
  801d23:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801d27:	89 df                	mov    %ebx,%edi
  801d29:	d3 ef                	shr    %cl,%edi
  801d2b:	89 c1                	mov    %eax,%ecx
  801d2d:	89 f0                	mov    %esi,%eax
  801d2f:	d3 e3                	shl    %cl,%ebx
  801d31:	89 d1                	mov    %edx,%ecx
  801d33:	89 fa                	mov    %edi,%edx
  801d35:	d3 e8                	shr    %cl,%eax
  801d37:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801d3c:	09 d8                	or     %ebx,%eax
  801d3e:	f7 f5                	div    %ebp
  801d40:	d3 e6                	shl    %cl,%esi
  801d42:	89 d1                	mov    %edx,%ecx
  801d44:	f7 64 24 08          	mull   0x8(%esp)
  801d48:	39 d1                	cmp    %edx,%ecx
  801d4a:	89 c3                	mov    %eax,%ebx
  801d4c:	89 d7                	mov    %edx,%edi
  801d4e:	72 06                	jb     801d56 <__umoddi3+0xa6>
  801d50:	75 0e                	jne    801d60 <__umoddi3+0xb0>
  801d52:	39 c6                	cmp    %eax,%esi
  801d54:	73 0a                	jae    801d60 <__umoddi3+0xb0>
  801d56:	2b 44 24 08          	sub    0x8(%esp),%eax
  801d5a:	19 ea                	sbb    %ebp,%edx
  801d5c:	89 d7                	mov    %edx,%edi
  801d5e:	89 c3                	mov    %eax,%ebx
  801d60:	89 ca                	mov    %ecx,%edx
  801d62:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801d67:	29 de                	sub    %ebx,%esi
  801d69:	19 fa                	sbb    %edi,%edx
  801d6b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  801d6f:	89 d0                	mov    %edx,%eax
  801d71:	d3 e0                	shl    %cl,%eax
  801d73:	89 d9                	mov    %ebx,%ecx
  801d75:	d3 ee                	shr    %cl,%esi
  801d77:	d3 ea                	shr    %cl,%edx
  801d79:	09 f0                	or     %esi,%eax
  801d7b:	83 c4 1c             	add    $0x1c,%esp
  801d7e:	5b                   	pop    %ebx
  801d7f:	5e                   	pop    %esi
  801d80:	5f                   	pop    %edi
  801d81:	5d                   	pop    %ebp
  801d82:	c3                   	ret    
  801d83:	90                   	nop
  801d84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d88:	85 ff                	test   %edi,%edi
  801d8a:	89 f9                	mov    %edi,%ecx
  801d8c:	75 0b                	jne    801d99 <__umoddi3+0xe9>
  801d8e:	b8 01 00 00 00       	mov    $0x1,%eax
  801d93:	31 d2                	xor    %edx,%edx
  801d95:	f7 f7                	div    %edi
  801d97:	89 c1                	mov    %eax,%ecx
  801d99:	89 d8                	mov    %ebx,%eax
  801d9b:	31 d2                	xor    %edx,%edx
  801d9d:	f7 f1                	div    %ecx
  801d9f:	89 f0                	mov    %esi,%eax
  801da1:	f7 f1                	div    %ecx
  801da3:	e9 31 ff ff ff       	jmp    801cd9 <__umoddi3+0x29>
  801da8:	90                   	nop
  801da9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801db0:	39 dd                	cmp    %ebx,%ebp
  801db2:	72 08                	jb     801dbc <__umoddi3+0x10c>
  801db4:	39 f7                	cmp    %esi,%edi
  801db6:	0f 87 21 ff ff ff    	ja     801cdd <__umoddi3+0x2d>
  801dbc:	89 da                	mov    %ebx,%edx
  801dbe:	89 f0                	mov    %esi,%eax
  801dc0:	29 f8                	sub    %edi,%eax
  801dc2:	19 ea                	sbb    %ebp,%edx
  801dc4:	e9 14 ff ff ff       	jmp    801cdd <__umoddi3+0x2d>
