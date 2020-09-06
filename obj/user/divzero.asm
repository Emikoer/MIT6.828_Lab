
obj/user/divzero.debug:     file format elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	zero = 0;
  800039:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  800040:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800043:	b8 01 00 00 00       	mov    $0x1,%eax
  800048:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004d:	99                   	cltd   
  80004e:	f7 f9                	idiv   %ecx
  800050:	50                   	push   %eax
  800051:	68 e0 1d 80 00       	push   $0x801de0
  800056:	e8 fa 00 00 00       	call   800155 <cprintf>
}
  80005b:	83 c4 10             	add    $0x10,%esp
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	56                   	push   %esi
  800064:	53                   	push   %ebx
  800065:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800068:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80006b:	e8 bf 0a 00 00       	call   800b2f <sys_getenvid>
  800070:	25 ff 03 00 00       	and    $0x3ff,%eax
  800075:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800078:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007d:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800082:	85 db                	test   %ebx,%ebx
  800084:	7e 07                	jle    80008d <libmain+0x2d>
		binaryname = argv[0];
  800086:	8b 06                	mov    (%esi),%eax
  800088:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80008d:	83 ec 08             	sub    $0x8,%esp
  800090:	56                   	push   %esi
  800091:	53                   	push   %ebx
  800092:	e8 9c ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800097:	e8 0a 00 00 00       	call   8000a6 <exit>
}
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a2:	5b                   	pop    %ebx
  8000a3:	5e                   	pop    %esi
  8000a4:	5d                   	pop    %ebp
  8000a5:	c3                   	ret    

008000a6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000ac:	e8 83 0e 00 00       	call   800f34 <close_all>
	sys_env_destroy(0);
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	6a 00                	push   $0x0
  8000b6:	e8 33 0a 00 00       	call   800aee <sys_env_destroy>
}
  8000bb:	83 c4 10             	add    $0x10,%esp
  8000be:	c9                   	leave  
  8000bf:	c3                   	ret    

008000c0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	53                   	push   %ebx
  8000c4:	83 ec 04             	sub    $0x4,%esp
  8000c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ca:	8b 13                	mov    (%ebx),%edx
  8000cc:	8d 42 01             	lea    0x1(%edx),%eax
  8000cf:	89 03                	mov    %eax,(%ebx)
  8000d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000dd:	74 09                	je     8000e8 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000df:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000e6:	c9                   	leave  
  8000e7:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000e8:	83 ec 08             	sub    $0x8,%esp
  8000eb:	68 ff 00 00 00       	push   $0xff
  8000f0:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f3:	50                   	push   %eax
  8000f4:	e8 b8 09 00 00       	call   800ab1 <sys_cputs>
		b->idx = 0;
  8000f9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000ff:	83 c4 10             	add    $0x10,%esp
  800102:	eb db                	jmp    8000df <putch+0x1f>

00800104 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80010d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800114:	00 00 00 
	b.cnt = 0;
  800117:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800121:	ff 75 0c             	pushl  0xc(%ebp)
  800124:	ff 75 08             	pushl  0x8(%ebp)
  800127:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80012d:	50                   	push   %eax
  80012e:	68 c0 00 80 00       	push   $0x8000c0
  800133:	e8 1a 01 00 00       	call   800252 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800138:	83 c4 08             	add    $0x8,%esp
  80013b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800141:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800147:	50                   	push   %eax
  800148:	e8 64 09 00 00       	call   800ab1 <sys_cputs>

	return b.cnt;
}
  80014d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800153:	c9                   	leave  
  800154:	c3                   	ret    

00800155 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80015b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80015e:	50                   	push   %eax
  80015f:	ff 75 08             	pushl  0x8(%ebp)
  800162:	e8 9d ff ff ff       	call   800104 <vcprintf>
	va_end(ap);

	return cnt;
}
  800167:	c9                   	leave  
  800168:	c3                   	ret    

00800169 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800169:	55                   	push   %ebp
  80016a:	89 e5                	mov    %esp,%ebp
  80016c:	57                   	push   %edi
  80016d:	56                   	push   %esi
  80016e:	53                   	push   %ebx
  80016f:	83 ec 1c             	sub    $0x1c,%esp
  800172:	89 c7                	mov    %eax,%edi
  800174:	89 d6                	mov    %edx,%esi
  800176:	8b 45 08             	mov    0x8(%ebp),%eax
  800179:	8b 55 0c             	mov    0xc(%ebp),%edx
  80017c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80017f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800182:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800185:	bb 00 00 00 00       	mov    $0x0,%ebx
  80018a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80018d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800190:	39 d3                	cmp    %edx,%ebx
  800192:	72 05                	jb     800199 <printnum+0x30>
  800194:	39 45 10             	cmp    %eax,0x10(%ebp)
  800197:	77 7a                	ja     800213 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800199:	83 ec 0c             	sub    $0xc,%esp
  80019c:	ff 75 18             	pushl  0x18(%ebp)
  80019f:	8b 45 14             	mov    0x14(%ebp),%eax
  8001a2:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001a5:	53                   	push   %ebx
  8001a6:	ff 75 10             	pushl  0x10(%ebp)
  8001a9:	83 ec 08             	sub    $0x8,%esp
  8001ac:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001af:	ff 75 e0             	pushl  -0x20(%ebp)
  8001b2:	ff 75 dc             	pushl  -0x24(%ebp)
  8001b5:	ff 75 d8             	pushl  -0x28(%ebp)
  8001b8:	e8 e3 19 00 00       	call   801ba0 <__udivdi3>
  8001bd:	83 c4 18             	add    $0x18,%esp
  8001c0:	52                   	push   %edx
  8001c1:	50                   	push   %eax
  8001c2:	89 f2                	mov    %esi,%edx
  8001c4:	89 f8                	mov    %edi,%eax
  8001c6:	e8 9e ff ff ff       	call   800169 <printnum>
  8001cb:	83 c4 20             	add    $0x20,%esp
  8001ce:	eb 13                	jmp    8001e3 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001d0:	83 ec 08             	sub    $0x8,%esp
  8001d3:	56                   	push   %esi
  8001d4:	ff 75 18             	pushl  0x18(%ebp)
  8001d7:	ff d7                	call   *%edi
  8001d9:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001dc:	83 eb 01             	sub    $0x1,%ebx
  8001df:	85 db                	test   %ebx,%ebx
  8001e1:	7f ed                	jg     8001d0 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001e3:	83 ec 08             	sub    $0x8,%esp
  8001e6:	56                   	push   %esi
  8001e7:	83 ec 04             	sub    $0x4,%esp
  8001ea:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ed:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f0:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f3:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f6:	e8 c5 1a 00 00       	call   801cc0 <__umoddi3>
  8001fb:	83 c4 14             	add    $0x14,%esp
  8001fe:	0f be 80 f8 1d 80 00 	movsbl 0x801df8(%eax),%eax
  800205:	50                   	push   %eax
  800206:	ff d7                	call   *%edi
}
  800208:	83 c4 10             	add    $0x10,%esp
  80020b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020e:	5b                   	pop    %ebx
  80020f:	5e                   	pop    %esi
  800210:	5f                   	pop    %edi
  800211:	5d                   	pop    %ebp
  800212:	c3                   	ret    
  800213:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800216:	eb c4                	jmp    8001dc <printnum+0x73>

00800218 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80021e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800222:	8b 10                	mov    (%eax),%edx
  800224:	3b 50 04             	cmp    0x4(%eax),%edx
  800227:	73 0a                	jae    800233 <sprintputch+0x1b>
		*b->buf++ = ch;
  800229:	8d 4a 01             	lea    0x1(%edx),%ecx
  80022c:	89 08                	mov    %ecx,(%eax)
  80022e:	8b 45 08             	mov    0x8(%ebp),%eax
  800231:	88 02                	mov    %al,(%edx)
}
  800233:	5d                   	pop    %ebp
  800234:	c3                   	ret    

00800235 <printfmt>:
{
  800235:	55                   	push   %ebp
  800236:	89 e5                	mov    %esp,%ebp
  800238:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80023b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80023e:	50                   	push   %eax
  80023f:	ff 75 10             	pushl  0x10(%ebp)
  800242:	ff 75 0c             	pushl  0xc(%ebp)
  800245:	ff 75 08             	pushl  0x8(%ebp)
  800248:	e8 05 00 00 00       	call   800252 <vprintfmt>
}
  80024d:	83 c4 10             	add    $0x10,%esp
  800250:	c9                   	leave  
  800251:	c3                   	ret    

00800252 <vprintfmt>:
{
  800252:	55                   	push   %ebp
  800253:	89 e5                	mov    %esp,%ebp
  800255:	57                   	push   %edi
  800256:	56                   	push   %esi
  800257:	53                   	push   %ebx
  800258:	83 ec 2c             	sub    $0x2c,%esp
  80025b:	8b 75 08             	mov    0x8(%ebp),%esi
  80025e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800261:	8b 7d 10             	mov    0x10(%ebp),%edi
  800264:	e9 c1 03 00 00       	jmp    80062a <vprintfmt+0x3d8>
		padc = ' ';
  800269:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  80026d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800274:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  80027b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800282:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800287:	8d 47 01             	lea    0x1(%edi),%eax
  80028a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80028d:	0f b6 17             	movzbl (%edi),%edx
  800290:	8d 42 dd             	lea    -0x23(%edx),%eax
  800293:	3c 55                	cmp    $0x55,%al
  800295:	0f 87 12 04 00 00    	ja     8006ad <vprintfmt+0x45b>
  80029b:	0f b6 c0             	movzbl %al,%eax
  80029e:	ff 24 85 40 1f 80 00 	jmp    *0x801f40(,%eax,4)
  8002a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002a8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8002ac:	eb d9                	jmp    800287 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8002ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  8002b1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002b5:	eb d0                	jmp    800287 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8002b7:	0f b6 d2             	movzbl %dl,%edx
  8002ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8002c2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002c5:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002c8:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002cc:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002cf:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002d2:	83 f9 09             	cmp    $0x9,%ecx
  8002d5:	77 55                	ja     80032c <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  8002d7:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8002da:	eb e9                	jmp    8002c5 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  8002dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8002df:	8b 00                	mov    (%eax),%eax
  8002e1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8002e7:	8d 40 04             	lea    0x4(%eax),%eax
  8002ea:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8002ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8002f0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8002f4:	79 91                	jns    800287 <vprintfmt+0x35>
				width = precision, precision = -1;
  8002f6:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8002f9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002fc:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800303:	eb 82                	jmp    800287 <vprintfmt+0x35>
  800305:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800308:	85 c0                	test   %eax,%eax
  80030a:	ba 00 00 00 00       	mov    $0x0,%edx
  80030f:	0f 49 d0             	cmovns %eax,%edx
  800312:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800315:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800318:	e9 6a ff ff ff       	jmp    800287 <vprintfmt+0x35>
  80031d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800320:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800327:	e9 5b ff ff ff       	jmp    800287 <vprintfmt+0x35>
  80032c:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80032f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800332:	eb bc                	jmp    8002f0 <vprintfmt+0x9e>
			lflag++;
  800334:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800337:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80033a:	e9 48 ff ff ff       	jmp    800287 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  80033f:	8b 45 14             	mov    0x14(%ebp),%eax
  800342:	8d 78 04             	lea    0x4(%eax),%edi
  800345:	83 ec 08             	sub    $0x8,%esp
  800348:	53                   	push   %ebx
  800349:	ff 30                	pushl  (%eax)
  80034b:	ff d6                	call   *%esi
			break;
  80034d:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800350:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800353:	e9 cf 02 00 00       	jmp    800627 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  800358:	8b 45 14             	mov    0x14(%ebp),%eax
  80035b:	8d 78 04             	lea    0x4(%eax),%edi
  80035e:	8b 00                	mov    (%eax),%eax
  800360:	99                   	cltd   
  800361:	31 d0                	xor    %edx,%eax
  800363:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800365:	83 f8 0f             	cmp    $0xf,%eax
  800368:	7f 23                	jg     80038d <vprintfmt+0x13b>
  80036a:	8b 14 85 a0 20 80 00 	mov    0x8020a0(,%eax,4),%edx
  800371:	85 d2                	test   %edx,%edx
  800373:	74 18                	je     80038d <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800375:	52                   	push   %edx
  800376:	68 d1 21 80 00       	push   $0x8021d1
  80037b:	53                   	push   %ebx
  80037c:	56                   	push   %esi
  80037d:	e8 b3 fe ff ff       	call   800235 <printfmt>
  800382:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800385:	89 7d 14             	mov    %edi,0x14(%ebp)
  800388:	e9 9a 02 00 00       	jmp    800627 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  80038d:	50                   	push   %eax
  80038e:	68 10 1e 80 00       	push   $0x801e10
  800393:	53                   	push   %ebx
  800394:	56                   	push   %esi
  800395:	e8 9b fe ff ff       	call   800235 <printfmt>
  80039a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80039d:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003a0:	e9 82 02 00 00       	jmp    800627 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  8003a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a8:	83 c0 04             	add    $0x4,%eax
  8003ab:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b1:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003b3:	85 ff                	test   %edi,%edi
  8003b5:	b8 09 1e 80 00       	mov    $0x801e09,%eax
  8003ba:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8003bd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003c1:	0f 8e bd 00 00 00    	jle    800484 <vprintfmt+0x232>
  8003c7:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8003cb:	75 0e                	jne    8003db <vprintfmt+0x189>
  8003cd:	89 75 08             	mov    %esi,0x8(%ebp)
  8003d0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8003d3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8003d6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8003d9:	eb 6d                	jmp    800448 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003db:	83 ec 08             	sub    $0x8,%esp
  8003de:	ff 75 d0             	pushl  -0x30(%ebp)
  8003e1:	57                   	push   %edi
  8003e2:	e8 6e 03 00 00       	call   800755 <strnlen>
  8003e7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003ea:	29 c1                	sub    %eax,%ecx
  8003ec:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8003ef:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8003f2:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8003f6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003f9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8003fc:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8003fe:	eb 0f                	jmp    80040f <vprintfmt+0x1bd>
					putch(padc, putdat);
  800400:	83 ec 08             	sub    $0x8,%esp
  800403:	53                   	push   %ebx
  800404:	ff 75 e0             	pushl  -0x20(%ebp)
  800407:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800409:	83 ef 01             	sub    $0x1,%edi
  80040c:	83 c4 10             	add    $0x10,%esp
  80040f:	85 ff                	test   %edi,%edi
  800411:	7f ed                	jg     800400 <vprintfmt+0x1ae>
  800413:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800416:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800419:	85 c9                	test   %ecx,%ecx
  80041b:	b8 00 00 00 00       	mov    $0x0,%eax
  800420:	0f 49 c1             	cmovns %ecx,%eax
  800423:	29 c1                	sub    %eax,%ecx
  800425:	89 75 08             	mov    %esi,0x8(%ebp)
  800428:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80042b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80042e:	89 cb                	mov    %ecx,%ebx
  800430:	eb 16                	jmp    800448 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  800432:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800436:	75 31                	jne    800469 <vprintfmt+0x217>
					putch(ch, putdat);
  800438:	83 ec 08             	sub    $0x8,%esp
  80043b:	ff 75 0c             	pushl  0xc(%ebp)
  80043e:	50                   	push   %eax
  80043f:	ff 55 08             	call   *0x8(%ebp)
  800442:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800445:	83 eb 01             	sub    $0x1,%ebx
  800448:	83 c7 01             	add    $0x1,%edi
  80044b:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  80044f:	0f be c2             	movsbl %dl,%eax
  800452:	85 c0                	test   %eax,%eax
  800454:	74 59                	je     8004af <vprintfmt+0x25d>
  800456:	85 f6                	test   %esi,%esi
  800458:	78 d8                	js     800432 <vprintfmt+0x1e0>
  80045a:	83 ee 01             	sub    $0x1,%esi
  80045d:	79 d3                	jns    800432 <vprintfmt+0x1e0>
  80045f:	89 df                	mov    %ebx,%edi
  800461:	8b 75 08             	mov    0x8(%ebp),%esi
  800464:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800467:	eb 37                	jmp    8004a0 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  800469:	0f be d2             	movsbl %dl,%edx
  80046c:	83 ea 20             	sub    $0x20,%edx
  80046f:	83 fa 5e             	cmp    $0x5e,%edx
  800472:	76 c4                	jbe    800438 <vprintfmt+0x1e6>
					putch('?', putdat);
  800474:	83 ec 08             	sub    $0x8,%esp
  800477:	ff 75 0c             	pushl  0xc(%ebp)
  80047a:	6a 3f                	push   $0x3f
  80047c:	ff 55 08             	call   *0x8(%ebp)
  80047f:	83 c4 10             	add    $0x10,%esp
  800482:	eb c1                	jmp    800445 <vprintfmt+0x1f3>
  800484:	89 75 08             	mov    %esi,0x8(%ebp)
  800487:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80048a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80048d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800490:	eb b6                	jmp    800448 <vprintfmt+0x1f6>
				putch(' ', putdat);
  800492:	83 ec 08             	sub    $0x8,%esp
  800495:	53                   	push   %ebx
  800496:	6a 20                	push   $0x20
  800498:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80049a:	83 ef 01             	sub    $0x1,%edi
  80049d:	83 c4 10             	add    $0x10,%esp
  8004a0:	85 ff                	test   %edi,%edi
  8004a2:	7f ee                	jg     800492 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  8004a4:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004a7:	89 45 14             	mov    %eax,0x14(%ebp)
  8004aa:	e9 78 01 00 00       	jmp    800627 <vprintfmt+0x3d5>
  8004af:	89 df                	mov    %ebx,%edi
  8004b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8004b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004b7:	eb e7                	jmp    8004a0 <vprintfmt+0x24e>
	if (lflag >= 2)
  8004b9:	83 f9 01             	cmp    $0x1,%ecx
  8004bc:	7e 3f                	jle    8004fd <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  8004be:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c1:	8b 50 04             	mov    0x4(%eax),%edx
  8004c4:	8b 00                	mov    (%eax),%eax
  8004c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004c9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cf:	8d 40 08             	lea    0x8(%eax),%eax
  8004d2:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8004d5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004d9:	79 5c                	jns    800537 <vprintfmt+0x2e5>
				putch('-', putdat);
  8004db:	83 ec 08             	sub    $0x8,%esp
  8004de:	53                   	push   %ebx
  8004df:	6a 2d                	push   $0x2d
  8004e1:	ff d6                	call   *%esi
				num = -(long long) num;
  8004e3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004e6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004e9:	f7 da                	neg    %edx
  8004eb:	83 d1 00             	adc    $0x0,%ecx
  8004ee:	f7 d9                	neg    %ecx
  8004f0:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8004f3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8004f8:	e9 10 01 00 00       	jmp    80060d <vprintfmt+0x3bb>
	else if (lflag)
  8004fd:	85 c9                	test   %ecx,%ecx
  8004ff:	75 1b                	jne    80051c <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800501:	8b 45 14             	mov    0x14(%ebp),%eax
  800504:	8b 00                	mov    (%eax),%eax
  800506:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800509:	89 c1                	mov    %eax,%ecx
  80050b:	c1 f9 1f             	sar    $0x1f,%ecx
  80050e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800511:	8b 45 14             	mov    0x14(%ebp),%eax
  800514:	8d 40 04             	lea    0x4(%eax),%eax
  800517:	89 45 14             	mov    %eax,0x14(%ebp)
  80051a:	eb b9                	jmp    8004d5 <vprintfmt+0x283>
		return va_arg(*ap, long);
  80051c:	8b 45 14             	mov    0x14(%ebp),%eax
  80051f:	8b 00                	mov    (%eax),%eax
  800521:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800524:	89 c1                	mov    %eax,%ecx
  800526:	c1 f9 1f             	sar    $0x1f,%ecx
  800529:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80052c:	8b 45 14             	mov    0x14(%ebp),%eax
  80052f:	8d 40 04             	lea    0x4(%eax),%eax
  800532:	89 45 14             	mov    %eax,0x14(%ebp)
  800535:	eb 9e                	jmp    8004d5 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  800537:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80053a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80053d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800542:	e9 c6 00 00 00       	jmp    80060d <vprintfmt+0x3bb>
	if (lflag >= 2)
  800547:	83 f9 01             	cmp    $0x1,%ecx
  80054a:	7e 18                	jle    800564 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  80054c:	8b 45 14             	mov    0x14(%ebp),%eax
  80054f:	8b 10                	mov    (%eax),%edx
  800551:	8b 48 04             	mov    0x4(%eax),%ecx
  800554:	8d 40 08             	lea    0x8(%eax),%eax
  800557:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80055a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80055f:	e9 a9 00 00 00       	jmp    80060d <vprintfmt+0x3bb>
	else if (lflag)
  800564:	85 c9                	test   %ecx,%ecx
  800566:	75 1a                	jne    800582 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  800568:	8b 45 14             	mov    0x14(%ebp),%eax
  80056b:	8b 10                	mov    (%eax),%edx
  80056d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800572:	8d 40 04             	lea    0x4(%eax),%eax
  800575:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800578:	b8 0a 00 00 00       	mov    $0xa,%eax
  80057d:	e9 8b 00 00 00       	jmp    80060d <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800582:	8b 45 14             	mov    0x14(%ebp),%eax
  800585:	8b 10                	mov    (%eax),%edx
  800587:	b9 00 00 00 00       	mov    $0x0,%ecx
  80058c:	8d 40 04             	lea    0x4(%eax),%eax
  80058f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800592:	b8 0a 00 00 00       	mov    $0xa,%eax
  800597:	eb 74                	jmp    80060d <vprintfmt+0x3bb>
	if (lflag >= 2)
  800599:	83 f9 01             	cmp    $0x1,%ecx
  80059c:	7e 15                	jle    8005b3 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  80059e:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a1:	8b 10                	mov    (%eax),%edx
  8005a3:	8b 48 04             	mov    0x4(%eax),%ecx
  8005a6:	8d 40 08             	lea    0x8(%eax),%eax
  8005a9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8005ac:	b8 08 00 00 00       	mov    $0x8,%eax
  8005b1:	eb 5a                	jmp    80060d <vprintfmt+0x3bb>
	else if (lflag)
  8005b3:	85 c9                	test   %ecx,%ecx
  8005b5:	75 17                	jne    8005ce <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  8005b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ba:	8b 10                	mov    (%eax),%edx
  8005bc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005c1:	8d 40 04             	lea    0x4(%eax),%eax
  8005c4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8005c7:	b8 08 00 00 00       	mov    $0x8,%eax
  8005cc:	eb 3f                	jmp    80060d <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8005ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d1:	8b 10                	mov    (%eax),%edx
  8005d3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d8:	8d 40 04             	lea    0x4(%eax),%eax
  8005db:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8005de:	b8 08 00 00 00       	mov    $0x8,%eax
  8005e3:	eb 28                	jmp    80060d <vprintfmt+0x3bb>
			putch('0', putdat);
  8005e5:	83 ec 08             	sub    $0x8,%esp
  8005e8:	53                   	push   %ebx
  8005e9:	6a 30                	push   $0x30
  8005eb:	ff d6                	call   *%esi
			putch('x', putdat);
  8005ed:	83 c4 08             	add    $0x8,%esp
  8005f0:	53                   	push   %ebx
  8005f1:	6a 78                	push   $0x78
  8005f3:	ff d6                	call   *%esi
			num = (unsigned long long)
  8005f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f8:	8b 10                	mov    (%eax),%edx
  8005fa:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8005ff:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800602:	8d 40 04             	lea    0x4(%eax),%eax
  800605:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800608:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80060d:	83 ec 0c             	sub    $0xc,%esp
  800610:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800614:	57                   	push   %edi
  800615:	ff 75 e0             	pushl  -0x20(%ebp)
  800618:	50                   	push   %eax
  800619:	51                   	push   %ecx
  80061a:	52                   	push   %edx
  80061b:	89 da                	mov    %ebx,%edx
  80061d:	89 f0                	mov    %esi,%eax
  80061f:	e8 45 fb ff ff       	call   800169 <printnum>
			break;
  800624:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800627:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80062a:	83 c7 01             	add    $0x1,%edi
  80062d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800631:	83 f8 25             	cmp    $0x25,%eax
  800634:	0f 84 2f fc ff ff    	je     800269 <vprintfmt+0x17>
			if (ch == '\0')
  80063a:	85 c0                	test   %eax,%eax
  80063c:	0f 84 8b 00 00 00    	je     8006cd <vprintfmt+0x47b>
			putch(ch, putdat);
  800642:	83 ec 08             	sub    $0x8,%esp
  800645:	53                   	push   %ebx
  800646:	50                   	push   %eax
  800647:	ff d6                	call   *%esi
  800649:	83 c4 10             	add    $0x10,%esp
  80064c:	eb dc                	jmp    80062a <vprintfmt+0x3d8>
	if (lflag >= 2)
  80064e:	83 f9 01             	cmp    $0x1,%ecx
  800651:	7e 15                	jle    800668 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  800653:	8b 45 14             	mov    0x14(%ebp),%eax
  800656:	8b 10                	mov    (%eax),%edx
  800658:	8b 48 04             	mov    0x4(%eax),%ecx
  80065b:	8d 40 08             	lea    0x8(%eax),%eax
  80065e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800661:	b8 10 00 00 00       	mov    $0x10,%eax
  800666:	eb a5                	jmp    80060d <vprintfmt+0x3bb>
	else if (lflag)
  800668:	85 c9                	test   %ecx,%ecx
  80066a:	75 17                	jne    800683 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  80066c:	8b 45 14             	mov    0x14(%ebp),%eax
  80066f:	8b 10                	mov    (%eax),%edx
  800671:	b9 00 00 00 00       	mov    $0x0,%ecx
  800676:	8d 40 04             	lea    0x4(%eax),%eax
  800679:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80067c:	b8 10 00 00 00       	mov    $0x10,%eax
  800681:	eb 8a                	jmp    80060d <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800683:	8b 45 14             	mov    0x14(%ebp),%eax
  800686:	8b 10                	mov    (%eax),%edx
  800688:	b9 00 00 00 00       	mov    $0x0,%ecx
  80068d:	8d 40 04             	lea    0x4(%eax),%eax
  800690:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800693:	b8 10 00 00 00       	mov    $0x10,%eax
  800698:	e9 70 ff ff ff       	jmp    80060d <vprintfmt+0x3bb>
			putch(ch, putdat);
  80069d:	83 ec 08             	sub    $0x8,%esp
  8006a0:	53                   	push   %ebx
  8006a1:	6a 25                	push   $0x25
  8006a3:	ff d6                	call   *%esi
			break;
  8006a5:	83 c4 10             	add    $0x10,%esp
  8006a8:	e9 7a ff ff ff       	jmp    800627 <vprintfmt+0x3d5>
			putch('%', putdat);
  8006ad:	83 ec 08             	sub    $0x8,%esp
  8006b0:	53                   	push   %ebx
  8006b1:	6a 25                	push   $0x25
  8006b3:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006b5:	83 c4 10             	add    $0x10,%esp
  8006b8:	89 f8                	mov    %edi,%eax
  8006ba:	eb 03                	jmp    8006bf <vprintfmt+0x46d>
  8006bc:	83 e8 01             	sub    $0x1,%eax
  8006bf:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006c3:	75 f7                	jne    8006bc <vprintfmt+0x46a>
  8006c5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006c8:	e9 5a ff ff ff       	jmp    800627 <vprintfmt+0x3d5>
}
  8006cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006d0:	5b                   	pop    %ebx
  8006d1:	5e                   	pop    %esi
  8006d2:	5f                   	pop    %edi
  8006d3:	5d                   	pop    %ebp
  8006d4:	c3                   	ret    

008006d5 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006d5:	55                   	push   %ebp
  8006d6:	89 e5                	mov    %esp,%ebp
  8006d8:	83 ec 18             	sub    $0x18,%esp
  8006db:	8b 45 08             	mov    0x8(%ebp),%eax
  8006de:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006e4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006e8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006eb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006f2:	85 c0                	test   %eax,%eax
  8006f4:	74 26                	je     80071c <vsnprintf+0x47>
  8006f6:	85 d2                	test   %edx,%edx
  8006f8:	7e 22                	jle    80071c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006fa:	ff 75 14             	pushl  0x14(%ebp)
  8006fd:	ff 75 10             	pushl  0x10(%ebp)
  800700:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800703:	50                   	push   %eax
  800704:	68 18 02 80 00       	push   $0x800218
  800709:	e8 44 fb ff ff       	call   800252 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80070e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800711:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800714:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800717:	83 c4 10             	add    $0x10,%esp
}
  80071a:	c9                   	leave  
  80071b:	c3                   	ret    
		return -E_INVAL;
  80071c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800721:	eb f7                	jmp    80071a <vsnprintf+0x45>

00800723 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800723:	55                   	push   %ebp
  800724:	89 e5                	mov    %esp,%ebp
  800726:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800729:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80072c:	50                   	push   %eax
  80072d:	ff 75 10             	pushl  0x10(%ebp)
  800730:	ff 75 0c             	pushl  0xc(%ebp)
  800733:	ff 75 08             	pushl  0x8(%ebp)
  800736:	e8 9a ff ff ff       	call   8006d5 <vsnprintf>
	va_end(ap);

	return rc;
}
  80073b:	c9                   	leave  
  80073c:	c3                   	ret    

0080073d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80073d:	55                   	push   %ebp
  80073e:	89 e5                	mov    %esp,%ebp
  800740:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800743:	b8 00 00 00 00       	mov    $0x0,%eax
  800748:	eb 03                	jmp    80074d <strlen+0x10>
		n++;
  80074a:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80074d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800751:	75 f7                	jne    80074a <strlen+0xd>
	return n;
}
  800753:	5d                   	pop    %ebp
  800754:	c3                   	ret    

00800755 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800755:	55                   	push   %ebp
  800756:	89 e5                	mov    %esp,%ebp
  800758:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80075b:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075e:	b8 00 00 00 00       	mov    $0x0,%eax
  800763:	eb 03                	jmp    800768 <strnlen+0x13>
		n++;
  800765:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800768:	39 d0                	cmp    %edx,%eax
  80076a:	74 06                	je     800772 <strnlen+0x1d>
  80076c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800770:	75 f3                	jne    800765 <strnlen+0x10>
	return n;
}
  800772:	5d                   	pop    %ebp
  800773:	c3                   	ret    

00800774 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800774:	55                   	push   %ebp
  800775:	89 e5                	mov    %esp,%ebp
  800777:	53                   	push   %ebx
  800778:	8b 45 08             	mov    0x8(%ebp),%eax
  80077b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80077e:	89 c2                	mov    %eax,%edx
  800780:	83 c1 01             	add    $0x1,%ecx
  800783:	83 c2 01             	add    $0x1,%edx
  800786:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80078a:	88 5a ff             	mov    %bl,-0x1(%edx)
  80078d:	84 db                	test   %bl,%bl
  80078f:	75 ef                	jne    800780 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800791:	5b                   	pop    %ebx
  800792:	5d                   	pop    %ebp
  800793:	c3                   	ret    

00800794 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800794:	55                   	push   %ebp
  800795:	89 e5                	mov    %esp,%ebp
  800797:	53                   	push   %ebx
  800798:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80079b:	53                   	push   %ebx
  80079c:	e8 9c ff ff ff       	call   80073d <strlen>
  8007a1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007a4:	ff 75 0c             	pushl  0xc(%ebp)
  8007a7:	01 d8                	add    %ebx,%eax
  8007a9:	50                   	push   %eax
  8007aa:	e8 c5 ff ff ff       	call   800774 <strcpy>
	return dst;
}
  8007af:	89 d8                	mov    %ebx,%eax
  8007b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b4:	c9                   	leave  
  8007b5:	c3                   	ret    

008007b6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
  8007b9:	56                   	push   %esi
  8007ba:	53                   	push   %ebx
  8007bb:	8b 75 08             	mov    0x8(%ebp),%esi
  8007be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c1:	89 f3                	mov    %esi,%ebx
  8007c3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c6:	89 f2                	mov    %esi,%edx
  8007c8:	eb 0f                	jmp    8007d9 <strncpy+0x23>
		*dst++ = *src;
  8007ca:	83 c2 01             	add    $0x1,%edx
  8007cd:	0f b6 01             	movzbl (%ecx),%eax
  8007d0:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007d3:	80 39 01             	cmpb   $0x1,(%ecx)
  8007d6:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8007d9:	39 da                	cmp    %ebx,%edx
  8007db:	75 ed                	jne    8007ca <strncpy+0x14>
	}
	return ret;
}
  8007dd:	89 f0                	mov    %esi,%eax
  8007df:	5b                   	pop    %ebx
  8007e0:	5e                   	pop    %esi
  8007e1:	5d                   	pop    %ebp
  8007e2:	c3                   	ret    

008007e3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007e3:	55                   	push   %ebp
  8007e4:	89 e5                	mov    %esp,%ebp
  8007e6:	56                   	push   %esi
  8007e7:	53                   	push   %ebx
  8007e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8007eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ee:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8007f1:	89 f0                	mov    %esi,%eax
  8007f3:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f7:	85 c9                	test   %ecx,%ecx
  8007f9:	75 0b                	jne    800806 <strlcpy+0x23>
  8007fb:	eb 17                	jmp    800814 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007fd:	83 c2 01             	add    $0x1,%edx
  800800:	83 c0 01             	add    $0x1,%eax
  800803:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800806:	39 d8                	cmp    %ebx,%eax
  800808:	74 07                	je     800811 <strlcpy+0x2e>
  80080a:	0f b6 0a             	movzbl (%edx),%ecx
  80080d:	84 c9                	test   %cl,%cl
  80080f:	75 ec                	jne    8007fd <strlcpy+0x1a>
		*dst = '\0';
  800811:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800814:	29 f0                	sub    %esi,%eax
}
  800816:	5b                   	pop    %ebx
  800817:	5e                   	pop    %esi
  800818:	5d                   	pop    %ebp
  800819:	c3                   	ret    

0080081a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800820:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800823:	eb 06                	jmp    80082b <strcmp+0x11>
		p++, q++;
  800825:	83 c1 01             	add    $0x1,%ecx
  800828:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80082b:	0f b6 01             	movzbl (%ecx),%eax
  80082e:	84 c0                	test   %al,%al
  800830:	74 04                	je     800836 <strcmp+0x1c>
  800832:	3a 02                	cmp    (%edx),%al
  800834:	74 ef                	je     800825 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800836:	0f b6 c0             	movzbl %al,%eax
  800839:	0f b6 12             	movzbl (%edx),%edx
  80083c:	29 d0                	sub    %edx,%eax
}
  80083e:	5d                   	pop    %ebp
  80083f:	c3                   	ret    

00800840 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	53                   	push   %ebx
  800844:	8b 45 08             	mov    0x8(%ebp),%eax
  800847:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084a:	89 c3                	mov    %eax,%ebx
  80084c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80084f:	eb 06                	jmp    800857 <strncmp+0x17>
		n--, p++, q++;
  800851:	83 c0 01             	add    $0x1,%eax
  800854:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800857:	39 d8                	cmp    %ebx,%eax
  800859:	74 16                	je     800871 <strncmp+0x31>
  80085b:	0f b6 08             	movzbl (%eax),%ecx
  80085e:	84 c9                	test   %cl,%cl
  800860:	74 04                	je     800866 <strncmp+0x26>
  800862:	3a 0a                	cmp    (%edx),%cl
  800864:	74 eb                	je     800851 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800866:	0f b6 00             	movzbl (%eax),%eax
  800869:	0f b6 12             	movzbl (%edx),%edx
  80086c:	29 d0                	sub    %edx,%eax
}
  80086e:	5b                   	pop    %ebx
  80086f:	5d                   	pop    %ebp
  800870:	c3                   	ret    
		return 0;
  800871:	b8 00 00 00 00       	mov    $0x0,%eax
  800876:	eb f6                	jmp    80086e <strncmp+0x2e>

00800878 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	8b 45 08             	mov    0x8(%ebp),%eax
  80087e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800882:	0f b6 10             	movzbl (%eax),%edx
  800885:	84 d2                	test   %dl,%dl
  800887:	74 09                	je     800892 <strchr+0x1a>
		if (*s == c)
  800889:	38 ca                	cmp    %cl,%dl
  80088b:	74 0a                	je     800897 <strchr+0x1f>
	for (; *s; s++)
  80088d:	83 c0 01             	add    $0x1,%eax
  800890:	eb f0                	jmp    800882 <strchr+0xa>
			return (char *) s;
	return 0;
  800892:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800897:	5d                   	pop    %ebp
  800898:	c3                   	ret    

00800899 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800899:	55                   	push   %ebp
  80089a:	89 e5                	mov    %esp,%ebp
  80089c:	8b 45 08             	mov    0x8(%ebp),%eax
  80089f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a3:	eb 03                	jmp    8008a8 <strfind+0xf>
  8008a5:	83 c0 01             	add    $0x1,%eax
  8008a8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008ab:	38 ca                	cmp    %cl,%dl
  8008ad:	74 04                	je     8008b3 <strfind+0x1a>
  8008af:	84 d2                	test   %dl,%dl
  8008b1:	75 f2                	jne    8008a5 <strfind+0xc>
			break;
	return (char *) s;
}
  8008b3:	5d                   	pop    %ebp
  8008b4:	c3                   	ret    

008008b5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008b5:	55                   	push   %ebp
  8008b6:	89 e5                	mov    %esp,%ebp
  8008b8:	57                   	push   %edi
  8008b9:	56                   	push   %esi
  8008ba:	53                   	push   %ebx
  8008bb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008be:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008c1:	85 c9                	test   %ecx,%ecx
  8008c3:	74 13                	je     8008d8 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008c5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008cb:	75 05                	jne    8008d2 <memset+0x1d>
  8008cd:	f6 c1 03             	test   $0x3,%cl
  8008d0:	74 0d                	je     8008df <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008d5:	fc                   	cld    
  8008d6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008d8:	89 f8                	mov    %edi,%eax
  8008da:	5b                   	pop    %ebx
  8008db:	5e                   	pop    %esi
  8008dc:	5f                   	pop    %edi
  8008dd:	5d                   	pop    %ebp
  8008de:	c3                   	ret    
		c &= 0xFF;
  8008df:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008e3:	89 d3                	mov    %edx,%ebx
  8008e5:	c1 e3 08             	shl    $0x8,%ebx
  8008e8:	89 d0                	mov    %edx,%eax
  8008ea:	c1 e0 18             	shl    $0x18,%eax
  8008ed:	89 d6                	mov    %edx,%esi
  8008ef:	c1 e6 10             	shl    $0x10,%esi
  8008f2:	09 f0                	or     %esi,%eax
  8008f4:	09 c2                	or     %eax,%edx
  8008f6:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  8008f8:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8008fb:	89 d0                	mov    %edx,%eax
  8008fd:	fc                   	cld    
  8008fe:	f3 ab                	rep stos %eax,%es:(%edi)
  800900:	eb d6                	jmp    8008d8 <memset+0x23>

00800902 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	57                   	push   %edi
  800906:	56                   	push   %esi
  800907:	8b 45 08             	mov    0x8(%ebp),%eax
  80090a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80090d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800910:	39 c6                	cmp    %eax,%esi
  800912:	73 35                	jae    800949 <memmove+0x47>
  800914:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800917:	39 c2                	cmp    %eax,%edx
  800919:	76 2e                	jbe    800949 <memmove+0x47>
		s += n;
		d += n;
  80091b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80091e:	89 d6                	mov    %edx,%esi
  800920:	09 fe                	or     %edi,%esi
  800922:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800928:	74 0c                	je     800936 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80092a:	83 ef 01             	sub    $0x1,%edi
  80092d:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800930:	fd                   	std    
  800931:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800933:	fc                   	cld    
  800934:	eb 21                	jmp    800957 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800936:	f6 c1 03             	test   $0x3,%cl
  800939:	75 ef                	jne    80092a <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80093b:	83 ef 04             	sub    $0x4,%edi
  80093e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800941:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800944:	fd                   	std    
  800945:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800947:	eb ea                	jmp    800933 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800949:	89 f2                	mov    %esi,%edx
  80094b:	09 c2                	or     %eax,%edx
  80094d:	f6 c2 03             	test   $0x3,%dl
  800950:	74 09                	je     80095b <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800952:	89 c7                	mov    %eax,%edi
  800954:	fc                   	cld    
  800955:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800957:	5e                   	pop    %esi
  800958:	5f                   	pop    %edi
  800959:	5d                   	pop    %ebp
  80095a:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80095b:	f6 c1 03             	test   $0x3,%cl
  80095e:	75 f2                	jne    800952 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800960:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800963:	89 c7                	mov    %eax,%edi
  800965:	fc                   	cld    
  800966:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800968:	eb ed                	jmp    800957 <memmove+0x55>

0080096a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80096d:	ff 75 10             	pushl  0x10(%ebp)
  800970:	ff 75 0c             	pushl  0xc(%ebp)
  800973:	ff 75 08             	pushl  0x8(%ebp)
  800976:	e8 87 ff ff ff       	call   800902 <memmove>
}
  80097b:	c9                   	leave  
  80097c:	c3                   	ret    

0080097d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80097d:	55                   	push   %ebp
  80097e:	89 e5                	mov    %esp,%ebp
  800980:	56                   	push   %esi
  800981:	53                   	push   %ebx
  800982:	8b 45 08             	mov    0x8(%ebp),%eax
  800985:	8b 55 0c             	mov    0xc(%ebp),%edx
  800988:	89 c6                	mov    %eax,%esi
  80098a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80098d:	39 f0                	cmp    %esi,%eax
  80098f:	74 1c                	je     8009ad <memcmp+0x30>
		if (*s1 != *s2)
  800991:	0f b6 08             	movzbl (%eax),%ecx
  800994:	0f b6 1a             	movzbl (%edx),%ebx
  800997:	38 d9                	cmp    %bl,%cl
  800999:	75 08                	jne    8009a3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  80099b:	83 c0 01             	add    $0x1,%eax
  80099e:	83 c2 01             	add    $0x1,%edx
  8009a1:	eb ea                	jmp    80098d <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8009a3:	0f b6 c1             	movzbl %cl,%eax
  8009a6:	0f b6 db             	movzbl %bl,%ebx
  8009a9:	29 d8                	sub    %ebx,%eax
  8009ab:	eb 05                	jmp    8009b2 <memcmp+0x35>
	}

	return 0;
  8009ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b2:	5b                   	pop    %ebx
  8009b3:	5e                   	pop    %esi
  8009b4:	5d                   	pop    %ebp
  8009b5:	c3                   	ret    

008009b6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009b6:	55                   	push   %ebp
  8009b7:	89 e5                	mov    %esp,%ebp
  8009b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009bf:	89 c2                	mov    %eax,%edx
  8009c1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009c4:	39 d0                	cmp    %edx,%eax
  8009c6:	73 09                	jae    8009d1 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009c8:	38 08                	cmp    %cl,(%eax)
  8009ca:	74 05                	je     8009d1 <memfind+0x1b>
	for (; s < ends; s++)
  8009cc:	83 c0 01             	add    $0x1,%eax
  8009cf:	eb f3                	jmp    8009c4 <memfind+0xe>
			break;
	return (void *) s;
}
  8009d1:	5d                   	pop    %ebp
  8009d2:	c3                   	ret    

008009d3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009d3:	55                   	push   %ebp
  8009d4:	89 e5                	mov    %esp,%ebp
  8009d6:	57                   	push   %edi
  8009d7:	56                   	push   %esi
  8009d8:	53                   	push   %ebx
  8009d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009dc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009df:	eb 03                	jmp    8009e4 <strtol+0x11>
		s++;
  8009e1:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  8009e4:	0f b6 01             	movzbl (%ecx),%eax
  8009e7:	3c 20                	cmp    $0x20,%al
  8009e9:	74 f6                	je     8009e1 <strtol+0xe>
  8009eb:	3c 09                	cmp    $0x9,%al
  8009ed:	74 f2                	je     8009e1 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8009ef:	3c 2b                	cmp    $0x2b,%al
  8009f1:	74 2e                	je     800a21 <strtol+0x4e>
	int neg = 0;
  8009f3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8009f8:	3c 2d                	cmp    $0x2d,%al
  8009fa:	74 2f                	je     800a2b <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009fc:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a02:	75 05                	jne    800a09 <strtol+0x36>
  800a04:	80 39 30             	cmpb   $0x30,(%ecx)
  800a07:	74 2c                	je     800a35 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a09:	85 db                	test   %ebx,%ebx
  800a0b:	75 0a                	jne    800a17 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a0d:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a12:	80 39 30             	cmpb   $0x30,(%ecx)
  800a15:	74 28                	je     800a3f <strtol+0x6c>
		base = 10;
  800a17:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1c:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a1f:	eb 50                	jmp    800a71 <strtol+0x9e>
		s++;
  800a21:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a24:	bf 00 00 00 00       	mov    $0x0,%edi
  800a29:	eb d1                	jmp    8009fc <strtol+0x29>
		s++, neg = 1;
  800a2b:	83 c1 01             	add    $0x1,%ecx
  800a2e:	bf 01 00 00 00       	mov    $0x1,%edi
  800a33:	eb c7                	jmp    8009fc <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a35:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a39:	74 0e                	je     800a49 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a3b:	85 db                	test   %ebx,%ebx
  800a3d:	75 d8                	jne    800a17 <strtol+0x44>
		s++, base = 8;
  800a3f:	83 c1 01             	add    $0x1,%ecx
  800a42:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a47:	eb ce                	jmp    800a17 <strtol+0x44>
		s += 2, base = 16;
  800a49:	83 c1 02             	add    $0x2,%ecx
  800a4c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a51:	eb c4                	jmp    800a17 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800a53:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a56:	89 f3                	mov    %esi,%ebx
  800a58:	80 fb 19             	cmp    $0x19,%bl
  800a5b:	77 29                	ja     800a86 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800a5d:	0f be d2             	movsbl %dl,%edx
  800a60:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a63:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a66:	7d 30                	jge    800a98 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800a68:	83 c1 01             	add    $0x1,%ecx
  800a6b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a6f:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a71:	0f b6 11             	movzbl (%ecx),%edx
  800a74:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a77:	89 f3                	mov    %esi,%ebx
  800a79:	80 fb 09             	cmp    $0x9,%bl
  800a7c:	77 d5                	ja     800a53 <strtol+0x80>
			dig = *s - '0';
  800a7e:	0f be d2             	movsbl %dl,%edx
  800a81:	83 ea 30             	sub    $0x30,%edx
  800a84:	eb dd                	jmp    800a63 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800a86:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a89:	89 f3                	mov    %esi,%ebx
  800a8b:	80 fb 19             	cmp    $0x19,%bl
  800a8e:	77 08                	ja     800a98 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a90:	0f be d2             	movsbl %dl,%edx
  800a93:	83 ea 37             	sub    $0x37,%edx
  800a96:	eb cb                	jmp    800a63 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a98:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a9c:	74 05                	je     800aa3 <strtol+0xd0>
		*endptr = (char *) s;
  800a9e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa1:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800aa3:	89 c2                	mov    %eax,%edx
  800aa5:	f7 da                	neg    %edx
  800aa7:	85 ff                	test   %edi,%edi
  800aa9:	0f 45 c2             	cmovne %edx,%eax
}
  800aac:	5b                   	pop    %ebx
  800aad:	5e                   	pop    %esi
  800aae:	5f                   	pop    %edi
  800aaf:	5d                   	pop    %ebp
  800ab0:	c3                   	ret    

00800ab1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
  800ab4:	57                   	push   %edi
  800ab5:	56                   	push   %esi
  800ab6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ab7:	b8 00 00 00 00       	mov    $0x0,%eax
  800abc:	8b 55 08             	mov    0x8(%ebp),%edx
  800abf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ac2:	89 c3                	mov    %eax,%ebx
  800ac4:	89 c7                	mov    %eax,%edi
  800ac6:	89 c6                	mov    %eax,%esi
  800ac8:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aca:	5b                   	pop    %ebx
  800acb:	5e                   	pop    %esi
  800acc:	5f                   	pop    %edi
  800acd:	5d                   	pop    %ebp
  800ace:	c3                   	ret    

00800acf <sys_cgetc>:

int
sys_cgetc(void)
{
  800acf:	55                   	push   %ebp
  800ad0:	89 e5                	mov    %esp,%ebp
  800ad2:	57                   	push   %edi
  800ad3:	56                   	push   %esi
  800ad4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ad5:	ba 00 00 00 00       	mov    $0x0,%edx
  800ada:	b8 01 00 00 00       	mov    $0x1,%eax
  800adf:	89 d1                	mov    %edx,%ecx
  800ae1:	89 d3                	mov    %edx,%ebx
  800ae3:	89 d7                	mov    %edx,%edi
  800ae5:	89 d6                	mov    %edx,%esi
  800ae7:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ae9:	5b                   	pop    %ebx
  800aea:	5e                   	pop    %esi
  800aeb:	5f                   	pop    %edi
  800aec:	5d                   	pop    %ebp
  800aed:	c3                   	ret    

00800aee <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	57                   	push   %edi
  800af2:	56                   	push   %esi
  800af3:	53                   	push   %ebx
  800af4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800af7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800afc:	8b 55 08             	mov    0x8(%ebp),%edx
  800aff:	b8 03 00 00 00       	mov    $0x3,%eax
  800b04:	89 cb                	mov    %ecx,%ebx
  800b06:	89 cf                	mov    %ecx,%edi
  800b08:	89 ce                	mov    %ecx,%esi
  800b0a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b0c:	85 c0                	test   %eax,%eax
  800b0e:	7f 08                	jg     800b18 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b10:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b13:	5b                   	pop    %ebx
  800b14:	5e                   	pop    %esi
  800b15:	5f                   	pop    %edi
  800b16:	5d                   	pop    %ebp
  800b17:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b18:	83 ec 0c             	sub    $0xc,%esp
  800b1b:	50                   	push   %eax
  800b1c:	6a 03                	push   $0x3
  800b1e:	68 ff 20 80 00       	push   $0x8020ff
  800b23:	6a 23                	push   $0x23
  800b25:	68 1c 21 80 00       	push   $0x80211c
  800b2a:	e8 ea 0e 00 00       	call   801a19 <_panic>

00800b2f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	57                   	push   %edi
  800b33:	56                   	push   %esi
  800b34:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b35:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3a:	b8 02 00 00 00       	mov    $0x2,%eax
  800b3f:	89 d1                	mov    %edx,%ecx
  800b41:	89 d3                	mov    %edx,%ebx
  800b43:	89 d7                	mov    %edx,%edi
  800b45:	89 d6                	mov    %edx,%esi
  800b47:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b49:	5b                   	pop    %ebx
  800b4a:	5e                   	pop    %esi
  800b4b:	5f                   	pop    %edi
  800b4c:	5d                   	pop    %ebp
  800b4d:	c3                   	ret    

00800b4e <sys_yield>:

void
sys_yield(void)
{
  800b4e:	55                   	push   %ebp
  800b4f:	89 e5                	mov    %esp,%ebp
  800b51:	57                   	push   %edi
  800b52:	56                   	push   %esi
  800b53:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b54:	ba 00 00 00 00       	mov    $0x0,%edx
  800b59:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b5e:	89 d1                	mov    %edx,%ecx
  800b60:	89 d3                	mov    %edx,%ebx
  800b62:	89 d7                	mov    %edx,%edi
  800b64:	89 d6                	mov    %edx,%esi
  800b66:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b68:	5b                   	pop    %ebx
  800b69:	5e                   	pop    %esi
  800b6a:	5f                   	pop    %edi
  800b6b:	5d                   	pop    %ebp
  800b6c:	c3                   	ret    

00800b6d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b6d:	55                   	push   %ebp
  800b6e:	89 e5                	mov    %esp,%ebp
  800b70:	57                   	push   %edi
  800b71:	56                   	push   %esi
  800b72:	53                   	push   %ebx
  800b73:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b76:	be 00 00 00 00       	mov    $0x0,%esi
  800b7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b81:	b8 04 00 00 00       	mov    $0x4,%eax
  800b86:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b89:	89 f7                	mov    %esi,%edi
  800b8b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b8d:	85 c0                	test   %eax,%eax
  800b8f:	7f 08                	jg     800b99 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b94:	5b                   	pop    %ebx
  800b95:	5e                   	pop    %esi
  800b96:	5f                   	pop    %edi
  800b97:	5d                   	pop    %ebp
  800b98:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b99:	83 ec 0c             	sub    $0xc,%esp
  800b9c:	50                   	push   %eax
  800b9d:	6a 04                	push   $0x4
  800b9f:	68 ff 20 80 00       	push   $0x8020ff
  800ba4:	6a 23                	push   $0x23
  800ba6:	68 1c 21 80 00       	push   $0x80211c
  800bab:	e8 69 0e 00 00       	call   801a19 <_panic>

00800bb0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bb0:	55                   	push   %ebp
  800bb1:	89 e5                	mov    %esp,%ebp
  800bb3:	57                   	push   %edi
  800bb4:	56                   	push   %esi
  800bb5:	53                   	push   %ebx
  800bb6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbf:	b8 05 00 00 00       	mov    $0x5,%eax
  800bc4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bc7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bca:	8b 75 18             	mov    0x18(%ebp),%esi
  800bcd:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bcf:	85 c0                	test   %eax,%eax
  800bd1:	7f 08                	jg     800bdb <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bd3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd6:	5b                   	pop    %ebx
  800bd7:	5e                   	pop    %esi
  800bd8:	5f                   	pop    %edi
  800bd9:	5d                   	pop    %ebp
  800bda:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdb:	83 ec 0c             	sub    $0xc,%esp
  800bde:	50                   	push   %eax
  800bdf:	6a 05                	push   $0x5
  800be1:	68 ff 20 80 00       	push   $0x8020ff
  800be6:	6a 23                	push   $0x23
  800be8:	68 1c 21 80 00       	push   $0x80211c
  800bed:	e8 27 0e 00 00       	call   801a19 <_panic>

00800bf2 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bf2:	55                   	push   %ebp
  800bf3:	89 e5                	mov    %esp,%ebp
  800bf5:	57                   	push   %edi
  800bf6:	56                   	push   %esi
  800bf7:	53                   	push   %ebx
  800bf8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bfb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c00:	8b 55 08             	mov    0x8(%ebp),%edx
  800c03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c06:	b8 06 00 00 00       	mov    $0x6,%eax
  800c0b:	89 df                	mov    %ebx,%edi
  800c0d:	89 de                	mov    %ebx,%esi
  800c0f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c11:	85 c0                	test   %eax,%eax
  800c13:	7f 08                	jg     800c1d <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c18:	5b                   	pop    %ebx
  800c19:	5e                   	pop    %esi
  800c1a:	5f                   	pop    %edi
  800c1b:	5d                   	pop    %ebp
  800c1c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1d:	83 ec 0c             	sub    $0xc,%esp
  800c20:	50                   	push   %eax
  800c21:	6a 06                	push   $0x6
  800c23:	68 ff 20 80 00       	push   $0x8020ff
  800c28:	6a 23                	push   $0x23
  800c2a:	68 1c 21 80 00       	push   $0x80211c
  800c2f:	e8 e5 0d 00 00       	call   801a19 <_panic>

00800c34 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	57                   	push   %edi
  800c38:	56                   	push   %esi
  800c39:	53                   	push   %ebx
  800c3a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c3d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c42:	8b 55 08             	mov    0x8(%ebp),%edx
  800c45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c48:	b8 08 00 00 00       	mov    $0x8,%eax
  800c4d:	89 df                	mov    %ebx,%edi
  800c4f:	89 de                	mov    %ebx,%esi
  800c51:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c53:	85 c0                	test   %eax,%eax
  800c55:	7f 08                	jg     800c5f <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5a:	5b                   	pop    %ebx
  800c5b:	5e                   	pop    %esi
  800c5c:	5f                   	pop    %edi
  800c5d:	5d                   	pop    %ebp
  800c5e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5f:	83 ec 0c             	sub    $0xc,%esp
  800c62:	50                   	push   %eax
  800c63:	6a 08                	push   $0x8
  800c65:	68 ff 20 80 00       	push   $0x8020ff
  800c6a:	6a 23                	push   $0x23
  800c6c:	68 1c 21 80 00       	push   $0x80211c
  800c71:	e8 a3 0d 00 00       	call   801a19 <_panic>

00800c76 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c76:	55                   	push   %ebp
  800c77:	89 e5                	mov    %esp,%ebp
  800c79:	57                   	push   %edi
  800c7a:	56                   	push   %esi
  800c7b:	53                   	push   %ebx
  800c7c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c7f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c84:	8b 55 08             	mov    0x8(%ebp),%edx
  800c87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8a:	b8 09 00 00 00       	mov    $0x9,%eax
  800c8f:	89 df                	mov    %ebx,%edi
  800c91:	89 de                	mov    %ebx,%esi
  800c93:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c95:	85 c0                	test   %eax,%eax
  800c97:	7f 08                	jg     800ca1 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9c:	5b                   	pop    %ebx
  800c9d:	5e                   	pop    %esi
  800c9e:	5f                   	pop    %edi
  800c9f:	5d                   	pop    %ebp
  800ca0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca1:	83 ec 0c             	sub    $0xc,%esp
  800ca4:	50                   	push   %eax
  800ca5:	6a 09                	push   $0x9
  800ca7:	68 ff 20 80 00       	push   $0x8020ff
  800cac:	6a 23                	push   $0x23
  800cae:	68 1c 21 80 00       	push   $0x80211c
  800cb3:	e8 61 0d 00 00       	call   801a19 <_panic>

00800cb8 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cb8:	55                   	push   %ebp
  800cb9:	89 e5                	mov    %esp,%ebp
  800cbb:	57                   	push   %edi
  800cbc:	56                   	push   %esi
  800cbd:	53                   	push   %ebx
  800cbe:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cc1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccc:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cd1:	89 df                	mov    %ebx,%edi
  800cd3:	89 de                	mov    %ebx,%esi
  800cd5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cd7:	85 c0                	test   %eax,%eax
  800cd9:	7f 08                	jg     800ce3 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cdb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cde:	5b                   	pop    %ebx
  800cdf:	5e                   	pop    %esi
  800ce0:	5f                   	pop    %edi
  800ce1:	5d                   	pop    %ebp
  800ce2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce3:	83 ec 0c             	sub    $0xc,%esp
  800ce6:	50                   	push   %eax
  800ce7:	6a 0a                	push   $0xa
  800ce9:	68 ff 20 80 00       	push   $0x8020ff
  800cee:	6a 23                	push   $0x23
  800cf0:	68 1c 21 80 00       	push   $0x80211c
  800cf5:	e8 1f 0d 00 00       	call   801a19 <_panic>

00800cfa <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cfa:	55                   	push   %ebp
  800cfb:	89 e5                	mov    %esp,%ebp
  800cfd:	57                   	push   %edi
  800cfe:	56                   	push   %esi
  800cff:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d00:	8b 55 08             	mov    0x8(%ebp),%edx
  800d03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d06:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d0b:	be 00 00 00 00       	mov    $0x0,%esi
  800d10:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d13:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d16:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d18:	5b                   	pop    %ebx
  800d19:	5e                   	pop    %esi
  800d1a:	5f                   	pop    %edi
  800d1b:	5d                   	pop    %ebp
  800d1c:	c3                   	ret    

00800d1d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d1d:	55                   	push   %ebp
  800d1e:	89 e5                	mov    %esp,%ebp
  800d20:	57                   	push   %edi
  800d21:	56                   	push   %esi
  800d22:	53                   	push   %ebx
  800d23:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d26:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d33:	89 cb                	mov    %ecx,%ebx
  800d35:	89 cf                	mov    %ecx,%edi
  800d37:	89 ce                	mov    %ecx,%esi
  800d39:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d3b:	85 c0                	test   %eax,%eax
  800d3d:	7f 08                	jg     800d47 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d42:	5b                   	pop    %ebx
  800d43:	5e                   	pop    %esi
  800d44:	5f                   	pop    %edi
  800d45:	5d                   	pop    %ebp
  800d46:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d47:	83 ec 0c             	sub    $0xc,%esp
  800d4a:	50                   	push   %eax
  800d4b:	6a 0d                	push   $0xd
  800d4d:	68 ff 20 80 00       	push   $0x8020ff
  800d52:	6a 23                	push   $0x23
  800d54:	68 1c 21 80 00       	push   $0x80211c
  800d59:	e8 bb 0c 00 00       	call   801a19 <_panic>

00800d5e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d61:	8b 45 08             	mov    0x8(%ebp),%eax
  800d64:	05 00 00 00 30       	add    $0x30000000,%eax
  800d69:	c1 e8 0c             	shr    $0xc,%eax
}
  800d6c:	5d                   	pop    %ebp
  800d6d:	c3                   	ret    

00800d6e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d6e:	55                   	push   %ebp
  800d6f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d71:	8b 45 08             	mov    0x8(%ebp),%eax
  800d74:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800d79:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d7e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    

00800d85 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d85:	55                   	push   %ebp
  800d86:	89 e5                	mov    %esp,%ebp
  800d88:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d8b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d90:	89 c2                	mov    %eax,%edx
  800d92:	c1 ea 16             	shr    $0x16,%edx
  800d95:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d9c:	f6 c2 01             	test   $0x1,%dl
  800d9f:	74 2a                	je     800dcb <fd_alloc+0x46>
  800da1:	89 c2                	mov    %eax,%edx
  800da3:	c1 ea 0c             	shr    $0xc,%edx
  800da6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dad:	f6 c2 01             	test   $0x1,%dl
  800db0:	74 19                	je     800dcb <fd_alloc+0x46>
  800db2:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800db7:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800dbc:	75 d2                	jne    800d90 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800dbe:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800dc4:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800dc9:	eb 07                	jmp    800dd2 <fd_alloc+0x4d>
			*fd_store = fd;
  800dcb:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dcd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dd2:	5d                   	pop    %ebp
  800dd3:	c3                   	ret    

00800dd4 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800dd4:	55                   	push   %ebp
  800dd5:	89 e5                	mov    %esp,%ebp
  800dd7:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800dda:	83 f8 1f             	cmp    $0x1f,%eax
  800ddd:	77 36                	ja     800e15 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ddf:	c1 e0 0c             	shl    $0xc,%eax
  800de2:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800de7:	89 c2                	mov    %eax,%edx
  800de9:	c1 ea 16             	shr    $0x16,%edx
  800dec:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800df3:	f6 c2 01             	test   $0x1,%dl
  800df6:	74 24                	je     800e1c <fd_lookup+0x48>
  800df8:	89 c2                	mov    %eax,%edx
  800dfa:	c1 ea 0c             	shr    $0xc,%edx
  800dfd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e04:	f6 c2 01             	test   $0x1,%dl
  800e07:	74 1a                	je     800e23 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e09:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e0c:	89 02                	mov    %eax,(%edx)
	return 0;
  800e0e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e13:	5d                   	pop    %ebp
  800e14:	c3                   	ret    
		return -E_INVAL;
  800e15:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e1a:	eb f7                	jmp    800e13 <fd_lookup+0x3f>
		return -E_INVAL;
  800e1c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e21:	eb f0                	jmp    800e13 <fd_lookup+0x3f>
  800e23:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e28:	eb e9                	jmp    800e13 <fd_lookup+0x3f>

00800e2a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	83 ec 08             	sub    $0x8,%esp
  800e30:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e33:	ba a8 21 80 00       	mov    $0x8021a8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e38:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800e3d:	39 08                	cmp    %ecx,(%eax)
  800e3f:	74 33                	je     800e74 <dev_lookup+0x4a>
  800e41:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800e44:	8b 02                	mov    (%edx),%eax
  800e46:	85 c0                	test   %eax,%eax
  800e48:	75 f3                	jne    800e3d <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e4a:	a1 08 40 80 00       	mov    0x804008,%eax
  800e4f:	8b 40 48             	mov    0x48(%eax),%eax
  800e52:	83 ec 04             	sub    $0x4,%esp
  800e55:	51                   	push   %ecx
  800e56:	50                   	push   %eax
  800e57:	68 2c 21 80 00       	push   $0x80212c
  800e5c:	e8 f4 f2 ff ff       	call   800155 <cprintf>
	*dev = 0;
  800e61:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e64:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e6a:	83 c4 10             	add    $0x10,%esp
  800e6d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e72:	c9                   	leave  
  800e73:	c3                   	ret    
			*dev = devtab[i];
  800e74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e77:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e79:	b8 00 00 00 00       	mov    $0x0,%eax
  800e7e:	eb f2                	jmp    800e72 <dev_lookup+0x48>

00800e80 <fd_close>:
{
  800e80:	55                   	push   %ebp
  800e81:	89 e5                	mov    %esp,%ebp
  800e83:	57                   	push   %edi
  800e84:	56                   	push   %esi
  800e85:	53                   	push   %ebx
  800e86:	83 ec 1c             	sub    $0x1c,%esp
  800e89:	8b 75 08             	mov    0x8(%ebp),%esi
  800e8c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e8f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800e92:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e93:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e99:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e9c:	50                   	push   %eax
  800e9d:	e8 32 ff ff ff       	call   800dd4 <fd_lookup>
  800ea2:	89 c3                	mov    %eax,%ebx
  800ea4:	83 c4 08             	add    $0x8,%esp
  800ea7:	85 c0                	test   %eax,%eax
  800ea9:	78 05                	js     800eb0 <fd_close+0x30>
	    || fd != fd2)
  800eab:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800eae:	74 16                	je     800ec6 <fd_close+0x46>
		return (must_exist ? r : 0);
  800eb0:	89 f8                	mov    %edi,%eax
  800eb2:	84 c0                	test   %al,%al
  800eb4:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb9:	0f 44 d8             	cmove  %eax,%ebx
}
  800ebc:	89 d8                	mov    %ebx,%eax
  800ebe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ec1:	5b                   	pop    %ebx
  800ec2:	5e                   	pop    %esi
  800ec3:	5f                   	pop    %edi
  800ec4:	5d                   	pop    %ebp
  800ec5:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ec6:	83 ec 08             	sub    $0x8,%esp
  800ec9:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800ecc:	50                   	push   %eax
  800ecd:	ff 36                	pushl  (%esi)
  800ecf:	e8 56 ff ff ff       	call   800e2a <dev_lookup>
  800ed4:	89 c3                	mov    %eax,%ebx
  800ed6:	83 c4 10             	add    $0x10,%esp
  800ed9:	85 c0                	test   %eax,%eax
  800edb:	78 15                	js     800ef2 <fd_close+0x72>
		if (dev->dev_close)
  800edd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ee0:	8b 40 10             	mov    0x10(%eax),%eax
  800ee3:	85 c0                	test   %eax,%eax
  800ee5:	74 1b                	je     800f02 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  800ee7:	83 ec 0c             	sub    $0xc,%esp
  800eea:	56                   	push   %esi
  800eeb:	ff d0                	call   *%eax
  800eed:	89 c3                	mov    %eax,%ebx
  800eef:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800ef2:	83 ec 08             	sub    $0x8,%esp
  800ef5:	56                   	push   %esi
  800ef6:	6a 00                	push   $0x0
  800ef8:	e8 f5 fc ff ff       	call   800bf2 <sys_page_unmap>
	return r;
  800efd:	83 c4 10             	add    $0x10,%esp
  800f00:	eb ba                	jmp    800ebc <fd_close+0x3c>
			r = 0;
  800f02:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f07:	eb e9                	jmp    800ef2 <fd_close+0x72>

00800f09 <close>:

int
close(int fdnum)
{
  800f09:	55                   	push   %ebp
  800f0a:	89 e5                	mov    %esp,%ebp
  800f0c:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f0f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f12:	50                   	push   %eax
  800f13:	ff 75 08             	pushl  0x8(%ebp)
  800f16:	e8 b9 fe ff ff       	call   800dd4 <fd_lookup>
  800f1b:	83 c4 08             	add    $0x8,%esp
  800f1e:	85 c0                	test   %eax,%eax
  800f20:	78 10                	js     800f32 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f22:	83 ec 08             	sub    $0x8,%esp
  800f25:	6a 01                	push   $0x1
  800f27:	ff 75 f4             	pushl  -0xc(%ebp)
  800f2a:	e8 51 ff ff ff       	call   800e80 <fd_close>
  800f2f:	83 c4 10             	add    $0x10,%esp
}
  800f32:	c9                   	leave  
  800f33:	c3                   	ret    

00800f34 <close_all>:

void
close_all(void)
{
  800f34:	55                   	push   %ebp
  800f35:	89 e5                	mov    %esp,%ebp
  800f37:	53                   	push   %ebx
  800f38:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f3b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f40:	83 ec 0c             	sub    $0xc,%esp
  800f43:	53                   	push   %ebx
  800f44:	e8 c0 ff ff ff       	call   800f09 <close>
	for (i = 0; i < MAXFD; i++)
  800f49:	83 c3 01             	add    $0x1,%ebx
  800f4c:	83 c4 10             	add    $0x10,%esp
  800f4f:	83 fb 20             	cmp    $0x20,%ebx
  800f52:	75 ec                	jne    800f40 <close_all+0xc>
}
  800f54:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f57:	c9                   	leave  
  800f58:	c3                   	ret    

00800f59 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f59:	55                   	push   %ebp
  800f5a:	89 e5                	mov    %esp,%ebp
  800f5c:	57                   	push   %edi
  800f5d:	56                   	push   %esi
  800f5e:	53                   	push   %ebx
  800f5f:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f62:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f65:	50                   	push   %eax
  800f66:	ff 75 08             	pushl  0x8(%ebp)
  800f69:	e8 66 fe ff ff       	call   800dd4 <fd_lookup>
  800f6e:	89 c3                	mov    %eax,%ebx
  800f70:	83 c4 08             	add    $0x8,%esp
  800f73:	85 c0                	test   %eax,%eax
  800f75:	0f 88 81 00 00 00    	js     800ffc <dup+0xa3>
		return r;
	close(newfdnum);
  800f7b:	83 ec 0c             	sub    $0xc,%esp
  800f7e:	ff 75 0c             	pushl  0xc(%ebp)
  800f81:	e8 83 ff ff ff       	call   800f09 <close>

	newfd = INDEX2FD(newfdnum);
  800f86:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f89:	c1 e6 0c             	shl    $0xc,%esi
  800f8c:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800f92:	83 c4 04             	add    $0x4,%esp
  800f95:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f98:	e8 d1 fd ff ff       	call   800d6e <fd2data>
  800f9d:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800f9f:	89 34 24             	mov    %esi,(%esp)
  800fa2:	e8 c7 fd ff ff       	call   800d6e <fd2data>
  800fa7:	83 c4 10             	add    $0x10,%esp
  800faa:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fac:	89 d8                	mov    %ebx,%eax
  800fae:	c1 e8 16             	shr    $0x16,%eax
  800fb1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fb8:	a8 01                	test   $0x1,%al
  800fba:	74 11                	je     800fcd <dup+0x74>
  800fbc:	89 d8                	mov    %ebx,%eax
  800fbe:	c1 e8 0c             	shr    $0xc,%eax
  800fc1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fc8:	f6 c2 01             	test   $0x1,%dl
  800fcb:	75 39                	jne    801006 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fcd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fd0:	89 d0                	mov    %edx,%eax
  800fd2:	c1 e8 0c             	shr    $0xc,%eax
  800fd5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fdc:	83 ec 0c             	sub    $0xc,%esp
  800fdf:	25 07 0e 00 00       	and    $0xe07,%eax
  800fe4:	50                   	push   %eax
  800fe5:	56                   	push   %esi
  800fe6:	6a 00                	push   $0x0
  800fe8:	52                   	push   %edx
  800fe9:	6a 00                	push   $0x0
  800feb:	e8 c0 fb ff ff       	call   800bb0 <sys_page_map>
  800ff0:	89 c3                	mov    %eax,%ebx
  800ff2:	83 c4 20             	add    $0x20,%esp
  800ff5:	85 c0                	test   %eax,%eax
  800ff7:	78 31                	js     80102a <dup+0xd1>
		goto err;

	return newfdnum;
  800ff9:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800ffc:	89 d8                	mov    %ebx,%eax
  800ffe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801001:	5b                   	pop    %ebx
  801002:	5e                   	pop    %esi
  801003:	5f                   	pop    %edi
  801004:	5d                   	pop    %ebp
  801005:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801006:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80100d:	83 ec 0c             	sub    $0xc,%esp
  801010:	25 07 0e 00 00       	and    $0xe07,%eax
  801015:	50                   	push   %eax
  801016:	57                   	push   %edi
  801017:	6a 00                	push   $0x0
  801019:	53                   	push   %ebx
  80101a:	6a 00                	push   $0x0
  80101c:	e8 8f fb ff ff       	call   800bb0 <sys_page_map>
  801021:	89 c3                	mov    %eax,%ebx
  801023:	83 c4 20             	add    $0x20,%esp
  801026:	85 c0                	test   %eax,%eax
  801028:	79 a3                	jns    800fcd <dup+0x74>
	sys_page_unmap(0, newfd);
  80102a:	83 ec 08             	sub    $0x8,%esp
  80102d:	56                   	push   %esi
  80102e:	6a 00                	push   $0x0
  801030:	e8 bd fb ff ff       	call   800bf2 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801035:	83 c4 08             	add    $0x8,%esp
  801038:	57                   	push   %edi
  801039:	6a 00                	push   $0x0
  80103b:	e8 b2 fb ff ff       	call   800bf2 <sys_page_unmap>
	return r;
  801040:	83 c4 10             	add    $0x10,%esp
  801043:	eb b7                	jmp    800ffc <dup+0xa3>

00801045 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801045:	55                   	push   %ebp
  801046:	89 e5                	mov    %esp,%ebp
  801048:	53                   	push   %ebx
  801049:	83 ec 14             	sub    $0x14,%esp
  80104c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80104f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801052:	50                   	push   %eax
  801053:	53                   	push   %ebx
  801054:	e8 7b fd ff ff       	call   800dd4 <fd_lookup>
  801059:	83 c4 08             	add    $0x8,%esp
  80105c:	85 c0                	test   %eax,%eax
  80105e:	78 3f                	js     80109f <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801060:	83 ec 08             	sub    $0x8,%esp
  801063:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801066:	50                   	push   %eax
  801067:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80106a:	ff 30                	pushl  (%eax)
  80106c:	e8 b9 fd ff ff       	call   800e2a <dev_lookup>
  801071:	83 c4 10             	add    $0x10,%esp
  801074:	85 c0                	test   %eax,%eax
  801076:	78 27                	js     80109f <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801078:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80107b:	8b 42 08             	mov    0x8(%edx),%eax
  80107e:	83 e0 03             	and    $0x3,%eax
  801081:	83 f8 01             	cmp    $0x1,%eax
  801084:	74 1e                	je     8010a4 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801086:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801089:	8b 40 08             	mov    0x8(%eax),%eax
  80108c:	85 c0                	test   %eax,%eax
  80108e:	74 35                	je     8010c5 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801090:	83 ec 04             	sub    $0x4,%esp
  801093:	ff 75 10             	pushl  0x10(%ebp)
  801096:	ff 75 0c             	pushl  0xc(%ebp)
  801099:	52                   	push   %edx
  80109a:	ff d0                	call   *%eax
  80109c:	83 c4 10             	add    $0x10,%esp
}
  80109f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010a2:	c9                   	leave  
  8010a3:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010a4:	a1 08 40 80 00       	mov    0x804008,%eax
  8010a9:	8b 40 48             	mov    0x48(%eax),%eax
  8010ac:	83 ec 04             	sub    $0x4,%esp
  8010af:	53                   	push   %ebx
  8010b0:	50                   	push   %eax
  8010b1:	68 6d 21 80 00       	push   $0x80216d
  8010b6:	e8 9a f0 ff ff       	call   800155 <cprintf>
		return -E_INVAL;
  8010bb:	83 c4 10             	add    $0x10,%esp
  8010be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010c3:	eb da                	jmp    80109f <read+0x5a>
		return -E_NOT_SUPP;
  8010c5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8010ca:	eb d3                	jmp    80109f <read+0x5a>

008010cc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010cc:	55                   	push   %ebp
  8010cd:	89 e5                	mov    %esp,%ebp
  8010cf:	57                   	push   %edi
  8010d0:	56                   	push   %esi
  8010d1:	53                   	push   %ebx
  8010d2:	83 ec 0c             	sub    $0xc,%esp
  8010d5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010d8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010db:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010e0:	39 f3                	cmp    %esi,%ebx
  8010e2:	73 25                	jae    801109 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010e4:	83 ec 04             	sub    $0x4,%esp
  8010e7:	89 f0                	mov    %esi,%eax
  8010e9:	29 d8                	sub    %ebx,%eax
  8010eb:	50                   	push   %eax
  8010ec:	89 d8                	mov    %ebx,%eax
  8010ee:	03 45 0c             	add    0xc(%ebp),%eax
  8010f1:	50                   	push   %eax
  8010f2:	57                   	push   %edi
  8010f3:	e8 4d ff ff ff       	call   801045 <read>
		if (m < 0)
  8010f8:	83 c4 10             	add    $0x10,%esp
  8010fb:	85 c0                	test   %eax,%eax
  8010fd:	78 08                	js     801107 <readn+0x3b>
			return m;
		if (m == 0)
  8010ff:	85 c0                	test   %eax,%eax
  801101:	74 06                	je     801109 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  801103:	01 c3                	add    %eax,%ebx
  801105:	eb d9                	jmp    8010e0 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801107:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801109:	89 d8                	mov    %ebx,%eax
  80110b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80110e:	5b                   	pop    %ebx
  80110f:	5e                   	pop    %esi
  801110:	5f                   	pop    %edi
  801111:	5d                   	pop    %ebp
  801112:	c3                   	ret    

00801113 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801113:	55                   	push   %ebp
  801114:	89 e5                	mov    %esp,%ebp
  801116:	53                   	push   %ebx
  801117:	83 ec 14             	sub    $0x14,%esp
  80111a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80111d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801120:	50                   	push   %eax
  801121:	53                   	push   %ebx
  801122:	e8 ad fc ff ff       	call   800dd4 <fd_lookup>
  801127:	83 c4 08             	add    $0x8,%esp
  80112a:	85 c0                	test   %eax,%eax
  80112c:	78 3a                	js     801168 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80112e:	83 ec 08             	sub    $0x8,%esp
  801131:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801134:	50                   	push   %eax
  801135:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801138:	ff 30                	pushl  (%eax)
  80113a:	e8 eb fc ff ff       	call   800e2a <dev_lookup>
  80113f:	83 c4 10             	add    $0x10,%esp
  801142:	85 c0                	test   %eax,%eax
  801144:	78 22                	js     801168 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801146:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801149:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80114d:	74 1e                	je     80116d <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80114f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801152:	8b 52 0c             	mov    0xc(%edx),%edx
  801155:	85 d2                	test   %edx,%edx
  801157:	74 35                	je     80118e <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801159:	83 ec 04             	sub    $0x4,%esp
  80115c:	ff 75 10             	pushl  0x10(%ebp)
  80115f:	ff 75 0c             	pushl  0xc(%ebp)
  801162:	50                   	push   %eax
  801163:	ff d2                	call   *%edx
  801165:	83 c4 10             	add    $0x10,%esp
}
  801168:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80116b:	c9                   	leave  
  80116c:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80116d:	a1 08 40 80 00       	mov    0x804008,%eax
  801172:	8b 40 48             	mov    0x48(%eax),%eax
  801175:	83 ec 04             	sub    $0x4,%esp
  801178:	53                   	push   %ebx
  801179:	50                   	push   %eax
  80117a:	68 89 21 80 00       	push   $0x802189
  80117f:	e8 d1 ef ff ff       	call   800155 <cprintf>
		return -E_INVAL;
  801184:	83 c4 10             	add    $0x10,%esp
  801187:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80118c:	eb da                	jmp    801168 <write+0x55>
		return -E_NOT_SUPP;
  80118e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801193:	eb d3                	jmp    801168 <write+0x55>

00801195 <seek>:

int
seek(int fdnum, off_t offset)
{
  801195:	55                   	push   %ebp
  801196:	89 e5                	mov    %esp,%ebp
  801198:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80119b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80119e:	50                   	push   %eax
  80119f:	ff 75 08             	pushl  0x8(%ebp)
  8011a2:	e8 2d fc ff ff       	call   800dd4 <fd_lookup>
  8011a7:	83 c4 08             	add    $0x8,%esp
  8011aa:	85 c0                	test   %eax,%eax
  8011ac:	78 0e                	js     8011bc <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011b4:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011bc:	c9                   	leave  
  8011bd:	c3                   	ret    

008011be <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011be:	55                   	push   %ebp
  8011bf:	89 e5                	mov    %esp,%ebp
  8011c1:	53                   	push   %ebx
  8011c2:	83 ec 14             	sub    $0x14,%esp
  8011c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011cb:	50                   	push   %eax
  8011cc:	53                   	push   %ebx
  8011cd:	e8 02 fc ff ff       	call   800dd4 <fd_lookup>
  8011d2:	83 c4 08             	add    $0x8,%esp
  8011d5:	85 c0                	test   %eax,%eax
  8011d7:	78 37                	js     801210 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011d9:	83 ec 08             	sub    $0x8,%esp
  8011dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011df:	50                   	push   %eax
  8011e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e3:	ff 30                	pushl  (%eax)
  8011e5:	e8 40 fc ff ff       	call   800e2a <dev_lookup>
  8011ea:	83 c4 10             	add    $0x10,%esp
  8011ed:	85 c0                	test   %eax,%eax
  8011ef:	78 1f                	js     801210 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011f4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011f8:	74 1b                	je     801215 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8011fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011fd:	8b 52 18             	mov    0x18(%edx),%edx
  801200:	85 d2                	test   %edx,%edx
  801202:	74 32                	je     801236 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801204:	83 ec 08             	sub    $0x8,%esp
  801207:	ff 75 0c             	pushl  0xc(%ebp)
  80120a:	50                   	push   %eax
  80120b:	ff d2                	call   *%edx
  80120d:	83 c4 10             	add    $0x10,%esp
}
  801210:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801213:	c9                   	leave  
  801214:	c3                   	ret    
			thisenv->env_id, fdnum);
  801215:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80121a:	8b 40 48             	mov    0x48(%eax),%eax
  80121d:	83 ec 04             	sub    $0x4,%esp
  801220:	53                   	push   %ebx
  801221:	50                   	push   %eax
  801222:	68 4c 21 80 00       	push   $0x80214c
  801227:	e8 29 ef ff ff       	call   800155 <cprintf>
		return -E_INVAL;
  80122c:	83 c4 10             	add    $0x10,%esp
  80122f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801234:	eb da                	jmp    801210 <ftruncate+0x52>
		return -E_NOT_SUPP;
  801236:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80123b:	eb d3                	jmp    801210 <ftruncate+0x52>

0080123d <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80123d:	55                   	push   %ebp
  80123e:	89 e5                	mov    %esp,%ebp
  801240:	53                   	push   %ebx
  801241:	83 ec 14             	sub    $0x14,%esp
  801244:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801247:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80124a:	50                   	push   %eax
  80124b:	ff 75 08             	pushl  0x8(%ebp)
  80124e:	e8 81 fb ff ff       	call   800dd4 <fd_lookup>
  801253:	83 c4 08             	add    $0x8,%esp
  801256:	85 c0                	test   %eax,%eax
  801258:	78 4b                	js     8012a5 <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80125a:	83 ec 08             	sub    $0x8,%esp
  80125d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801260:	50                   	push   %eax
  801261:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801264:	ff 30                	pushl  (%eax)
  801266:	e8 bf fb ff ff       	call   800e2a <dev_lookup>
  80126b:	83 c4 10             	add    $0x10,%esp
  80126e:	85 c0                	test   %eax,%eax
  801270:	78 33                	js     8012a5 <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  801272:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801275:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801279:	74 2f                	je     8012aa <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80127b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80127e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801285:	00 00 00 
	stat->st_isdir = 0;
  801288:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80128f:	00 00 00 
	stat->st_dev = dev;
  801292:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801298:	83 ec 08             	sub    $0x8,%esp
  80129b:	53                   	push   %ebx
  80129c:	ff 75 f0             	pushl  -0x10(%ebp)
  80129f:	ff 50 14             	call   *0x14(%eax)
  8012a2:	83 c4 10             	add    $0x10,%esp
}
  8012a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012a8:	c9                   	leave  
  8012a9:	c3                   	ret    
		return -E_NOT_SUPP;
  8012aa:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012af:	eb f4                	jmp    8012a5 <fstat+0x68>

008012b1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012b1:	55                   	push   %ebp
  8012b2:	89 e5                	mov    %esp,%ebp
  8012b4:	56                   	push   %esi
  8012b5:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012b6:	83 ec 08             	sub    $0x8,%esp
  8012b9:	6a 00                	push   $0x0
  8012bb:	ff 75 08             	pushl  0x8(%ebp)
  8012be:	e8 e7 01 00 00       	call   8014aa <open>
  8012c3:	89 c3                	mov    %eax,%ebx
  8012c5:	83 c4 10             	add    $0x10,%esp
  8012c8:	85 c0                	test   %eax,%eax
  8012ca:	78 1b                	js     8012e7 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012cc:	83 ec 08             	sub    $0x8,%esp
  8012cf:	ff 75 0c             	pushl  0xc(%ebp)
  8012d2:	50                   	push   %eax
  8012d3:	e8 65 ff ff ff       	call   80123d <fstat>
  8012d8:	89 c6                	mov    %eax,%esi
	close(fd);
  8012da:	89 1c 24             	mov    %ebx,(%esp)
  8012dd:	e8 27 fc ff ff       	call   800f09 <close>
	return r;
  8012e2:	83 c4 10             	add    $0x10,%esp
  8012e5:	89 f3                	mov    %esi,%ebx
}
  8012e7:	89 d8                	mov    %ebx,%eax
  8012e9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012ec:	5b                   	pop    %ebx
  8012ed:	5e                   	pop    %esi
  8012ee:	5d                   	pop    %ebp
  8012ef:	c3                   	ret    

008012f0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012f0:	55                   	push   %ebp
  8012f1:	89 e5                	mov    %esp,%ebp
  8012f3:	56                   	push   %esi
  8012f4:	53                   	push   %ebx
  8012f5:	89 c6                	mov    %eax,%esi
  8012f7:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8012f9:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801300:	74 27                	je     801329 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801302:	6a 07                	push   $0x7
  801304:	68 00 50 80 00       	push   $0x805000
  801309:	56                   	push   %esi
  80130a:	ff 35 00 40 80 00    	pushl  0x804000
  801310:	e8 bf 07 00 00       	call   801ad4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801315:	83 c4 0c             	add    $0xc,%esp
  801318:	6a 00                	push   $0x0
  80131a:	53                   	push   %ebx
  80131b:	6a 00                	push   $0x0
  80131d:	e8 3d 07 00 00       	call   801a5f <ipc_recv>
}
  801322:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801325:	5b                   	pop    %ebx
  801326:	5e                   	pop    %esi
  801327:	5d                   	pop    %ebp
  801328:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801329:	83 ec 0c             	sub    $0xc,%esp
  80132c:	6a 01                	push   $0x1
  80132e:	e8 f7 07 00 00       	call   801b2a <ipc_find_env>
  801333:	a3 00 40 80 00       	mov    %eax,0x804000
  801338:	83 c4 10             	add    $0x10,%esp
  80133b:	eb c5                	jmp    801302 <fsipc+0x12>

0080133d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80133d:	55                   	push   %ebp
  80133e:	89 e5                	mov    %esp,%ebp
  801340:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801343:	8b 45 08             	mov    0x8(%ebp),%eax
  801346:	8b 40 0c             	mov    0xc(%eax),%eax
  801349:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80134e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801351:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801356:	ba 00 00 00 00       	mov    $0x0,%edx
  80135b:	b8 02 00 00 00       	mov    $0x2,%eax
  801360:	e8 8b ff ff ff       	call   8012f0 <fsipc>
}
  801365:	c9                   	leave  
  801366:	c3                   	ret    

00801367 <devfile_flush>:
{
  801367:	55                   	push   %ebp
  801368:	89 e5                	mov    %esp,%ebp
  80136a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80136d:	8b 45 08             	mov    0x8(%ebp),%eax
  801370:	8b 40 0c             	mov    0xc(%eax),%eax
  801373:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801378:	ba 00 00 00 00       	mov    $0x0,%edx
  80137d:	b8 06 00 00 00       	mov    $0x6,%eax
  801382:	e8 69 ff ff ff       	call   8012f0 <fsipc>
}
  801387:	c9                   	leave  
  801388:	c3                   	ret    

00801389 <devfile_stat>:
{
  801389:	55                   	push   %ebp
  80138a:	89 e5                	mov    %esp,%ebp
  80138c:	53                   	push   %ebx
  80138d:	83 ec 04             	sub    $0x4,%esp
  801390:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801393:	8b 45 08             	mov    0x8(%ebp),%eax
  801396:	8b 40 0c             	mov    0xc(%eax),%eax
  801399:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80139e:	ba 00 00 00 00       	mov    $0x0,%edx
  8013a3:	b8 05 00 00 00       	mov    $0x5,%eax
  8013a8:	e8 43 ff ff ff       	call   8012f0 <fsipc>
  8013ad:	85 c0                	test   %eax,%eax
  8013af:	78 2c                	js     8013dd <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013b1:	83 ec 08             	sub    $0x8,%esp
  8013b4:	68 00 50 80 00       	push   $0x805000
  8013b9:	53                   	push   %ebx
  8013ba:	e8 b5 f3 ff ff       	call   800774 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013bf:	a1 80 50 80 00       	mov    0x805080,%eax
  8013c4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013ca:	a1 84 50 80 00       	mov    0x805084,%eax
  8013cf:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013d5:	83 c4 10             	add    $0x10,%esp
  8013d8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013e0:	c9                   	leave  
  8013e1:	c3                   	ret    

008013e2 <devfile_write>:
{
  8013e2:	55                   	push   %ebp
  8013e3:	89 e5                	mov    %esp,%ebp
  8013e5:	83 ec 0c             	sub    $0xc,%esp
  8013e8:	8b 45 10             	mov    0x10(%ebp),%eax
  8013eb:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8013f0:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8013f5:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8013f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8013fb:	8b 52 0c             	mov    0xc(%edx),%edx
  8013fe:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801404:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf,buf,n);
  801409:	50                   	push   %eax
  80140a:	ff 75 0c             	pushl  0xc(%ebp)
  80140d:	68 08 50 80 00       	push   $0x805008
  801412:	e8 eb f4 ff ff       	call   800902 <memmove>
	if((r = fsipc(FSREQ_WRITE,NULL))<0)
  801417:	ba 00 00 00 00       	mov    $0x0,%edx
  80141c:	b8 04 00 00 00       	mov    $0x4,%eax
  801421:	e8 ca fe ff ff       	call   8012f0 <fsipc>
}
  801426:	c9                   	leave  
  801427:	c3                   	ret    

00801428 <devfile_read>:
{
  801428:	55                   	push   %ebp
  801429:	89 e5                	mov    %esp,%ebp
  80142b:	56                   	push   %esi
  80142c:	53                   	push   %ebx
  80142d:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801430:	8b 45 08             	mov    0x8(%ebp),%eax
  801433:	8b 40 0c             	mov    0xc(%eax),%eax
  801436:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80143b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801441:	ba 00 00 00 00       	mov    $0x0,%edx
  801446:	b8 03 00 00 00       	mov    $0x3,%eax
  80144b:	e8 a0 fe ff ff       	call   8012f0 <fsipc>
  801450:	89 c3                	mov    %eax,%ebx
  801452:	85 c0                	test   %eax,%eax
  801454:	78 1f                	js     801475 <devfile_read+0x4d>
	assert(r <= n);
  801456:	39 f0                	cmp    %esi,%eax
  801458:	77 24                	ja     80147e <devfile_read+0x56>
	assert(r <= PGSIZE);
  80145a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80145f:	7f 33                	jg     801494 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801461:	83 ec 04             	sub    $0x4,%esp
  801464:	50                   	push   %eax
  801465:	68 00 50 80 00       	push   $0x805000
  80146a:	ff 75 0c             	pushl  0xc(%ebp)
  80146d:	e8 90 f4 ff ff       	call   800902 <memmove>
	return r;
  801472:	83 c4 10             	add    $0x10,%esp
}
  801475:	89 d8                	mov    %ebx,%eax
  801477:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80147a:	5b                   	pop    %ebx
  80147b:	5e                   	pop    %esi
  80147c:	5d                   	pop    %ebp
  80147d:	c3                   	ret    
	assert(r <= n);
  80147e:	68 b8 21 80 00       	push   $0x8021b8
  801483:	68 bf 21 80 00       	push   $0x8021bf
  801488:	6a 7c                	push   $0x7c
  80148a:	68 d4 21 80 00       	push   $0x8021d4
  80148f:	e8 85 05 00 00       	call   801a19 <_panic>
	assert(r <= PGSIZE);
  801494:	68 df 21 80 00       	push   $0x8021df
  801499:	68 bf 21 80 00       	push   $0x8021bf
  80149e:	6a 7d                	push   $0x7d
  8014a0:	68 d4 21 80 00       	push   $0x8021d4
  8014a5:	e8 6f 05 00 00       	call   801a19 <_panic>

008014aa <open>:
{
  8014aa:	55                   	push   %ebp
  8014ab:	89 e5                	mov    %esp,%ebp
  8014ad:	56                   	push   %esi
  8014ae:	53                   	push   %ebx
  8014af:	83 ec 1c             	sub    $0x1c,%esp
  8014b2:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8014b5:	56                   	push   %esi
  8014b6:	e8 82 f2 ff ff       	call   80073d <strlen>
  8014bb:	83 c4 10             	add    $0x10,%esp
  8014be:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014c3:	7f 6c                	jg     801531 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8014c5:	83 ec 0c             	sub    $0xc,%esp
  8014c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014cb:	50                   	push   %eax
  8014cc:	e8 b4 f8 ff ff       	call   800d85 <fd_alloc>
  8014d1:	89 c3                	mov    %eax,%ebx
  8014d3:	83 c4 10             	add    $0x10,%esp
  8014d6:	85 c0                	test   %eax,%eax
  8014d8:	78 3c                	js     801516 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8014da:	83 ec 08             	sub    $0x8,%esp
  8014dd:	56                   	push   %esi
  8014de:	68 00 50 80 00       	push   $0x805000
  8014e3:	e8 8c f2 ff ff       	call   800774 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014eb:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014f3:	b8 01 00 00 00       	mov    $0x1,%eax
  8014f8:	e8 f3 fd ff ff       	call   8012f0 <fsipc>
  8014fd:	89 c3                	mov    %eax,%ebx
  8014ff:	83 c4 10             	add    $0x10,%esp
  801502:	85 c0                	test   %eax,%eax
  801504:	78 19                	js     80151f <open+0x75>
	return fd2num(fd);
  801506:	83 ec 0c             	sub    $0xc,%esp
  801509:	ff 75 f4             	pushl  -0xc(%ebp)
  80150c:	e8 4d f8 ff ff       	call   800d5e <fd2num>
  801511:	89 c3                	mov    %eax,%ebx
  801513:	83 c4 10             	add    $0x10,%esp
}
  801516:	89 d8                	mov    %ebx,%eax
  801518:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80151b:	5b                   	pop    %ebx
  80151c:	5e                   	pop    %esi
  80151d:	5d                   	pop    %ebp
  80151e:	c3                   	ret    
		fd_close(fd, 0);
  80151f:	83 ec 08             	sub    $0x8,%esp
  801522:	6a 00                	push   $0x0
  801524:	ff 75 f4             	pushl  -0xc(%ebp)
  801527:	e8 54 f9 ff ff       	call   800e80 <fd_close>
		return r;
  80152c:	83 c4 10             	add    $0x10,%esp
  80152f:	eb e5                	jmp    801516 <open+0x6c>
		return -E_BAD_PATH;
  801531:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801536:	eb de                	jmp    801516 <open+0x6c>

00801538 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801538:	55                   	push   %ebp
  801539:	89 e5                	mov    %esp,%ebp
  80153b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80153e:	ba 00 00 00 00       	mov    $0x0,%edx
  801543:	b8 08 00 00 00       	mov    $0x8,%eax
  801548:	e8 a3 fd ff ff       	call   8012f0 <fsipc>
}
  80154d:	c9                   	leave  
  80154e:	c3                   	ret    

0080154f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80154f:	55                   	push   %ebp
  801550:	89 e5                	mov    %esp,%ebp
  801552:	56                   	push   %esi
  801553:	53                   	push   %ebx
  801554:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801557:	83 ec 0c             	sub    $0xc,%esp
  80155a:	ff 75 08             	pushl  0x8(%ebp)
  80155d:	e8 0c f8 ff ff       	call   800d6e <fd2data>
  801562:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801564:	83 c4 08             	add    $0x8,%esp
  801567:	68 eb 21 80 00       	push   $0x8021eb
  80156c:	53                   	push   %ebx
  80156d:	e8 02 f2 ff ff       	call   800774 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801572:	8b 46 04             	mov    0x4(%esi),%eax
  801575:	2b 06                	sub    (%esi),%eax
  801577:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80157d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801584:	00 00 00 
	stat->st_dev = &devpipe;
  801587:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80158e:	30 80 00 
	return 0;
}
  801591:	b8 00 00 00 00       	mov    $0x0,%eax
  801596:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801599:	5b                   	pop    %ebx
  80159a:	5e                   	pop    %esi
  80159b:	5d                   	pop    %ebp
  80159c:	c3                   	ret    

0080159d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80159d:	55                   	push   %ebp
  80159e:	89 e5                	mov    %esp,%ebp
  8015a0:	53                   	push   %ebx
  8015a1:	83 ec 0c             	sub    $0xc,%esp
  8015a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8015a7:	53                   	push   %ebx
  8015a8:	6a 00                	push   $0x0
  8015aa:	e8 43 f6 ff ff       	call   800bf2 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8015af:	89 1c 24             	mov    %ebx,(%esp)
  8015b2:	e8 b7 f7 ff ff       	call   800d6e <fd2data>
  8015b7:	83 c4 08             	add    $0x8,%esp
  8015ba:	50                   	push   %eax
  8015bb:	6a 00                	push   $0x0
  8015bd:	e8 30 f6 ff ff       	call   800bf2 <sys_page_unmap>
}
  8015c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c5:	c9                   	leave  
  8015c6:	c3                   	ret    

008015c7 <_pipeisclosed>:
{
  8015c7:	55                   	push   %ebp
  8015c8:	89 e5                	mov    %esp,%ebp
  8015ca:	57                   	push   %edi
  8015cb:	56                   	push   %esi
  8015cc:	53                   	push   %ebx
  8015cd:	83 ec 1c             	sub    $0x1c,%esp
  8015d0:	89 c7                	mov    %eax,%edi
  8015d2:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8015d4:	a1 08 40 80 00       	mov    0x804008,%eax
  8015d9:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8015dc:	83 ec 0c             	sub    $0xc,%esp
  8015df:	57                   	push   %edi
  8015e0:	e8 7e 05 00 00       	call   801b63 <pageref>
  8015e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8015e8:	89 34 24             	mov    %esi,(%esp)
  8015eb:	e8 73 05 00 00       	call   801b63 <pageref>
		nn = thisenv->env_runs;
  8015f0:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8015f6:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8015f9:	83 c4 10             	add    $0x10,%esp
  8015fc:	39 cb                	cmp    %ecx,%ebx
  8015fe:	74 1b                	je     80161b <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801600:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801603:	75 cf                	jne    8015d4 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801605:	8b 42 58             	mov    0x58(%edx),%eax
  801608:	6a 01                	push   $0x1
  80160a:	50                   	push   %eax
  80160b:	53                   	push   %ebx
  80160c:	68 f2 21 80 00       	push   $0x8021f2
  801611:	e8 3f eb ff ff       	call   800155 <cprintf>
  801616:	83 c4 10             	add    $0x10,%esp
  801619:	eb b9                	jmp    8015d4 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  80161b:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80161e:	0f 94 c0             	sete   %al
  801621:	0f b6 c0             	movzbl %al,%eax
}
  801624:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801627:	5b                   	pop    %ebx
  801628:	5e                   	pop    %esi
  801629:	5f                   	pop    %edi
  80162a:	5d                   	pop    %ebp
  80162b:	c3                   	ret    

0080162c <devpipe_write>:
{
  80162c:	55                   	push   %ebp
  80162d:	89 e5                	mov    %esp,%ebp
  80162f:	57                   	push   %edi
  801630:	56                   	push   %esi
  801631:	53                   	push   %ebx
  801632:	83 ec 28             	sub    $0x28,%esp
  801635:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801638:	56                   	push   %esi
  801639:	e8 30 f7 ff ff       	call   800d6e <fd2data>
  80163e:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801640:	83 c4 10             	add    $0x10,%esp
  801643:	bf 00 00 00 00       	mov    $0x0,%edi
  801648:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80164b:	74 4f                	je     80169c <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80164d:	8b 43 04             	mov    0x4(%ebx),%eax
  801650:	8b 0b                	mov    (%ebx),%ecx
  801652:	8d 51 20             	lea    0x20(%ecx),%edx
  801655:	39 d0                	cmp    %edx,%eax
  801657:	72 14                	jb     80166d <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801659:	89 da                	mov    %ebx,%edx
  80165b:	89 f0                	mov    %esi,%eax
  80165d:	e8 65 ff ff ff       	call   8015c7 <_pipeisclosed>
  801662:	85 c0                	test   %eax,%eax
  801664:	75 3a                	jne    8016a0 <devpipe_write+0x74>
			sys_yield();
  801666:	e8 e3 f4 ff ff       	call   800b4e <sys_yield>
  80166b:	eb e0                	jmp    80164d <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80166d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801670:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801674:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801677:	89 c2                	mov    %eax,%edx
  801679:	c1 fa 1f             	sar    $0x1f,%edx
  80167c:	89 d1                	mov    %edx,%ecx
  80167e:	c1 e9 1b             	shr    $0x1b,%ecx
  801681:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801684:	83 e2 1f             	and    $0x1f,%edx
  801687:	29 ca                	sub    %ecx,%edx
  801689:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80168d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801691:	83 c0 01             	add    $0x1,%eax
  801694:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801697:	83 c7 01             	add    $0x1,%edi
  80169a:	eb ac                	jmp    801648 <devpipe_write+0x1c>
	return i;
  80169c:	89 f8                	mov    %edi,%eax
  80169e:	eb 05                	jmp    8016a5 <devpipe_write+0x79>
				return 0;
  8016a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016a8:	5b                   	pop    %ebx
  8016a9:	5e                   	pop    %esi
  8016aa:	5f                   	pop    %edi
  8016ab:	5d                   	pop    %ebp
  8016ac:	c3                   	ret    

008016ad <devpipe_read>:
{
  8016ad:	55                   	push   %ebp
  8016ae:	89 e5                	mov    %esp,%ebp
  8016b0:	57                   	push   %edi
  8016b1:	56                   	push   %esi
  8016b2:	53                   	push   %ebx
  8016b3:	83 ec 18             	sub    $0x18,%esp
  8016b6:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8016b9:	57                   	push   %edi
  8016ba:	e8 af f6 ff ff       	call   800d6e <fd2data>
  8016bf:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8016c1:	83 c4 10             	add    $0x10,%esp
  8016c4:	be 00 00 00 00       	mov    $0x0,%esi
  8016c9:	3b 75 10             	cmp    0x10(%ebp),%esi
  8016cc:	74 47                	je     801715 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  8016ce:	8b 03                	mov    (%ebx),%eax
  8016d0:	3b 43 04             	cmp    0x4(%ebx),%eax
  8016d3:	75 22                	jne    8016f7 <devpipe_read+0x4a>
			if (i > 0)
  8016d5:	85 f6                	test   %esi,%esi
  8016d7:	75 14                	jne    8016ed <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  8016d9:	89 da                	mov    %ebx,%edx
  8016db:	89 f8                	mov    %edi,%eax
  8016dd:	e8 e5 fe ff ff       	call   8015c7 <_pipeisclosed>
  8016e2:	85 c0                	test   %eax,%eax
  8016e4:	75 33                	jne    801719 <devpipe_read+0x6c>
			sys_yield();
  8016e6:	e8 63 f4 ff ff       	call   800b4e <sys_yield>
  8016eb:	eb e1                	jmp    8016ce <devpipe_read+0x21>
				return i;
  8016ed:	89 f0                	mov    %esi,%eax
}
  8016ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016f2:	5b                   	pop    %ebx
  8016f3:	5e                   	pop    %esi
  8016f4:	5f                   	pop    %edi
  8016f5:	5d                   	pop    %ebp
  8016f6:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016f7:	99                   	cltd   
  8016f8:	c1 ea 1b             	shr    $0x1b,%edx
  8016fb:	01 d0                	add    %edx,%eax
  8016fd:	83 e0 1f             	and    $0x1f,%eax
  801700:	29 d0                	sub    %edx,%eax
  801702:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801707:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80170a:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  80170d:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801710:	83 c6 01             	add    $0x1,%esi
  801713:	eb b4                	jmp    8016c9 <devpipe_read+0x1c>
	return i;
  801715:	89 f0                	mov    %esi,%eax
  801717:	eb d6                	jmp    8016ef <devpipe_read+0x42>
				return 0;
  801719:	b8 00 00 00 00       	mov    $0x0,%eax
  80171e:	eb cf                	jmp    8016ef <devpipe_read+0x42>

00801720 <pipe>:
{
  801720:	55                   	push   %ebp
  801721:	89 e5                	mov    %esp,%ebp
  801723:	56                   	push   %esi
  801724:	53                   	push   %ebx
  801725:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801728:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80172b:	50                   	push   %eax
  80172c:	e8 54 f6 ff ff       	call   800d85 <fd_alloc>
  801731:	89 c3                	mov    %eax,%ebx
  801733:	83 c4 10             	add    $0x10,%esp
  801736:	85 c0                	test   %eax,%eax
  801738:	78 5b                	js     801795 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80173a:	83 ec 04             	sub    $0x4,%esp
  80173d:	68 07 04 00 00       	push   $0x407
  801742:	ff 75 f4             	pushl  -0xc(%ebp)
  801745:	6a 00                	push   $0x0
  801747:	e8 21 f4 ff ff       	call   800b6d <sys_page_alloc>
  80174c:	89 c3                	mov    %eax,%ebx
  80174e:	83 c4 10             	add    $0x10,%esp
  801751:	85 c0                	test   %eax,%eax
  801753:	78 40                	js     801795 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  801755:	83 ec 0c             	sub    $0xc,%esp
  801758:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80175b:	50                   	push   %eax
  80175c:	e8 24 f6 ff ff       	call   800d85 <fd_alloc>
  801761:	89 c3                	mov    %eax,%ebx
  801763:	83 c4 10             	add    $0x10,%esp
  801766:	85 c0                	test   %eax,%eax
  801768:	78 1b                	js     801785 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80176a:	83 ec 04             	sub    $0x4,%esp
  80176d:	68 07 04 00 00       	push   $0x407
  801772:	ff 75 f0             	pushl  -0x10(%ebp)
  801775:	6a 00                	push   $0x0
  801777:	e8 f1 f3 ff ff       	call   800b6d <sys_page_alloc>
  80177c:	89 c3                	mov    %eax,%ebx
  80177e:	83 c4 10             	add    $0x10,%esp
  801781:	85 c0                	test   %eax,%eax
  801783:	79 19                	jns    80179e <pipe+0x7e>
	sys_page_unmap(0, fd0);
  801785:	83 ec 08             	sub    $0x8,%esp
  801788:	ff 75 f4             	pushl  -0xc(%ebp)
  80178b:	6a 00                	push   $0x0
  80178d:	e8 60 f4 ff ff       	call   800bf2 <sys_page_unmap>
  801792:	83 c4 10             	add    $0x10,%esp
}
  801795:	89 d8                	mov    %ebx,%eax
  801797:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80179a:	5b                   	pop    %ebx
  80179b:	5e                   	pop    %esi
  80179c:	5d                   	pop    %ebp
  80179d:	c3                   	ret    
	va = fd2data(fd0);
  80179e:	83 ec 0c             	sub    $0xc,%esp
  8017a1:	ff 75 f4             	pushl  -0xc(%ebp)
  8017a4:	e8 c5 f5 ff ff       	call   800d6e <fd2data>
  8017a9:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017ab:	83 c4 0c             	add    $0xc,%esp
  8017ae:	68 07 04 00 00       	push   $0x407
  8017b3:	50                   	push   %eax
  8017b4:	6a 00                	push   $0x0
  8017b6:	e8 b2 f3 ff ff       	call   800b6d <sys_page_alloc>
  8017bb:	89 c3                	mov    %eax,%ebx
  8017bd:	83 c4 10             	add    $0x10,%esp
  8017c0:	85 c0                	test   %eax,%eax
  8017c2:	0f 88 8c 00 00 00    	js     801854 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017c8:	83 ec 0c             	sub    $0xc,%esp
  8017cb:	ff 75 f0             	pushl  -0x10(%ebp)
  8017ce:	e8 9b f5 ff ff       	call   800d6e <fd2data>
  8017d3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8017da:	50                   	push   %eax
  8017db:	6a 00                	push   $0x0
  8017dd:	56                   	push   %esi
  8017de:	6a 00                	push   $0x0
  8017e0:	e8 cb f3 ff ff       	call   800bb0 <sys_page_map>
  8017e5:	89 c3                	mov    %eax,%ebx
  8017e7:	83 c4 20             	add    $0x20,%esp
  8017ea:	85 c0                	test   %eax,%eax
  8017ec:	78 58                	js     801846 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  8017ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017f1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017f7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8017f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017fc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801803:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801806:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80180c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80180e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801811:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801818:	83 ec 0c             	sub    $0xc,%esp
  80181b:	ff 75 f4             	pushl  -0xc(%ebp)
  80181e:	e8 3b f5 ff ff       	call   800d5e <fd2num>
  801823:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801826:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801828:	83 c4 04             	add    $0x4,%esp
  80182b:	ff 75 f0             	pushl  -0x10(%ebp)
  80182e:	e8 2b f5 ff ff       	call   800d5e <fd2num>
  801833:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801836:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801839:	83 c4 10             	add    $0x10,%esp
  80183c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801841:	e9 4f ff ff ff       	jmp    801795 <pipe+0x75>
	sys_page_unmap(0, va);
  801846:	83 ec 08             	sub    $0x8,%esp
  801849:	56                   	push   %esi
  80184a:	6a 00                	push   $0x0
  80184c:	e8 a1 f3 ff ff       	call   800bf2 <sys_page_unmap>
  801851:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801854:	83 ec 08             	sub    $0x8,%esp
  801857:	ff 75 f0             	pushl  -0x10(%ebp)
  80185a:	6a 00                	push   $0x0
  80185c:	e8 91 f3 ff ff       	call   800bf2 <sys_page_unmap>
  801861:	83 c4 10             	add    $0x10,%esp
  801864:	e9 1c ff ff ff       	jmp    801785 <pipe+0x65>

00801869 <pipeisclosed>:
{
  801869:	55                   	push   %ebp
  80186a:	89 e5                	mov    %esp,%ebp
  80186c:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80186f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801872:	50                   	push   %eax
  801873:	ff 75 08             	pushl  0x8(%ebp)
  801876:	e8 59 f5 ff ff       	call   800dd4 <fd_lookup>
  80187b:	83 c4 10             	add    $0x10,%esp
  80187e:	85 c0                	test   %eax,%eax
  801880:	78 18                	js     80189a <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801882:	83 ec 0c             	sub    $0xc,%esp
  801885:	ff 75 f4             	pushl  -0xc(%ebp)
  801888:	e8 e1 f4 ff ff       	call   800d6e <fd2data>
	return _pipeisclosed(fd, p);
  80188d:	89 c2                	mov    %eax,%edx
  80188f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801892:	e8 30 fd ff ff       	call   8015c7 <_pipeisclosed>
  801897:	83 c4 10             	add    $0x10,%esp
}
  80189a:	c9                   	leave  
  80189b:	c3                   	ret    

0080189c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80189c:	55                   	push   %ebp
  80189d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80189f:	b8 00 00 00 00       	mov    $0x0,%eax
  8018a4:	5d                   	pop    %ebp
  8018a5:	c3                   	ret    

008018a6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8018a6:	55                   	push   %ebp
  8018a7:	89 e5                	mov    %esp,%ebp
  8018a9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8018ac:	68 0a 22 80 00       	push   $0x80220a
  8018b1:	ff 75 0c             	pushl  0xc(%ebp)
  8018b4:	e8 bb ee ff ff       	call   800774 <strcpy>
	return 0;
}
  8018b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8018be:	c9                   	leave  
  8018bf:	c3                   	ret    

008018c0 <devcons_write>:
{
  8018c0:	55                   	push   %ebp
  8018c1:	89 e5                	mov    %esp,%ebp
  8018c3:	57                   	push   %edi
  8018c4:	56                   	push   %esi
  8018c5:	53                   	push   %ebx
  8018c6:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8018cc:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8018d1:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8018d7:	eb 2f                	jmp    801908 <devcons_write+0x48>
		m = n - tot;
  8018d9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8018dc:	29 f3                	sub    %esi,%ebx
  8018de:	83 fb 7f             	cmp    $0x7f,%ebx
  8018e1:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8018e6:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8018e9:	83 ec 04             	sub    $0x4,%esp
  8018ec:	53                   	push   %ebx
  8018ed:	89 f0                	mov    %esi,%eax
  8018ef:	03 45 0c             	add    0xc(%ebp),%eax
  8018f2:	50                   	push   %eax
  8018f3:	57                   	push   %edi
  8018f4:	e8 09 f0 ff ff       	call   800902 <memmove>
		sys_cputs(buf, m);
  8018f9:	83 c4 08             	add    $0x8,%esp
  8018fc:	53                   	push   %ebx
  8018fd:	57                   	push   %edi
  8018fe:	e8 ae f1 ff ff       	call   800ab1 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801903:	01 de                	add    %ebx,%esi
  801905:	83 c4 10             	add    $0x10,%esp
  801908:	3b 75 10             	cmp    0x10(%ebp),%esi
  80190b:	72 cc                	jb     8018d9 <devcons_write+0x19>
}
  80190d:	89 f0                	mov    %esi,%eax
  80190f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801912:	5b                   	pop    %ebx
  801913:	5e                   	pop    %esi
  801914:	5f                   	pop    %edi
  801915:	5d                   	pop    %ebp
  801916:	c3                   	ret    

00801917 <devcons_read>:
{
  801917:	55                   	push   %ebp
  801918:	89 e5                	mov    %esp,%ebp
  80191a:	83 ec 08             	sub    $0x8,%esp
  80191d:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801922:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801926:	75 07                	jne    80192f <devcons_read+0x18>
}
  801928:	c9                   	leave  
  801929:	c3                   	ret    
		sys_yield();
  80192a:	e8 1f f2 ff ff       	call   800b4e <sys_yield>
	while ((c = sys_cgetc()) == 0)
  80192f:	e8 9b f1 ff ff       	call   800acf <sys_cgetc>
  801934:	85 c0                	test   %eax,%eax
  801936:	74 f2                	je     80192a <devcons_read+0x13>
	if (c < 0)
  801938:	85 c0                	test   %eax,%eax
  80193a:	78 ec                	js     801928 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  80193c:	83 f8 04             	cmp    $0x4,%eax
  80193f:	74 0c                	je     80194d <devcons_read+0x36>
	*(char*)vbuf = c;
  801941:	8b 55 0c             	mov    0xc(%ebp),%edx
  801944:	88 02                	mov    %al,(%edx)
	return 1;
  801946:	b8 01 00 00 00       	mov    $0x1,%eax
  80194b:	eb db                	jmp    801928 <devcons_read+0x11>
		return 0;
  80194d:	b8 00 00 00 00       	mov    $0x0,%eax
  801952:	eb d4                	jmp    801928 <devcons_read+0x11>

00801954 <cputchar>:
{
  801954:	55                   	push   %ebp
  801955:	89 e5                	mov    %esp,%ebp
  801957:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80195a:	8b 45 08             	mov    0x8(%ebp),%eax
  80195d:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801960:	6a 01                	push   $0x1
  801962:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801965:	50                   	push   %eax
  801966:	e8 46 f1 ff ff       	call   800ab1 <sys_cputs>
}
  80196b:	83 c4 10             	add    $0x10,%esp
  80196e:	c9                   	leave  
  80196f:	c3                   	ret    

00801970 <getchar>:
{
  801970:	55                   	push   %ebp
  801971:	89 e5                	mov    %esp,%ebp
  801973:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801976:	6a 01                	push   $0x1
  801978:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80197b:	50                   	push   %eax
  80197c:	6a 00                	push   $0x0
  80197e:	e8 c2 f6 ff ff       	call   801045 <read>
	if (r < 0)
  801983:	83 c4 10             	add    $0x10,%esp
  801986:	85 c0                	test   %eax,%eax
  801988:	78 08                	js     801992 <getchar+0x22>
	if (r < 1)
  80198a:	85 c0                	test   %eax,%eax
  80198c:	7e 06                	jle    801994 <getchar+0x24>
	return c;
  80198e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801992:	c9                   	leave  
  801993:	c3                   	ret    
		return -E_EOF;
  801994:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801999:	eb f7                	jmp    801992 <getchar+0x22>

0080199b <iscons>:
{
  80199b:	55                   	push   %ebp
  80199c:	89 e5                	mov    %esp,%ebp
  80199e:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019a4:	50                   	push   %eax
  8019a5:	ff 75 08             	pushl  0x8(%ebp)
  8019a8:	e8 27 f4 ff ff       	call   800dd4 <fd_lookup>
  8019ad:	83 c4 10             	add    $0x10,%esp
  8019b0:	85 c0                	test   %eax,%eax
  8019b2:	78 11                	js     8019c5 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  8019b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019b7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019bd:	39 10                	cmp    %edx,(%eax)
  8019bf:	0f 94 c0             	sete   %al
  8019c2:	0f b6 c0             	movzbl %al,%eax
}
  8019c5:	c9                   	leave  
  8019c6:	c3                   	ret    

008019c7 <opencons>:
{
  8019c7:	55                   	push   %ebp
  8019c8:	89 e5                	mov    %esp,%ebp
  8019ca:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8019cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019d0:	50                   	push   %eax
  8019d1:	e8 af f3 ff ff       	call   800d85 <fd_alloc>
  8019d6:	83 c4 10             	add    $0x10,%esp
  8019d9:	85 c0                	test   %eax,%eax
  8019db:	78 3a                	js     801a17 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019dd:	83 ec 04             	sub    $0x4,%esp
  8019e0:	68 07 04 00 00       	push   $0x407
  8019e5:	ff 75 f4             	pushl  -0xc(%ebp)
  8019e8:	6a 00                	push   $0x0
  8019ea:	e8 7e f1 ff ff       	call   800b6d <sys_page_alloc>
  8019ef:	83 c4 10             	add    $0x10,%esp
  8019f2:	85 c0                	test   %eax,%eax
  8019f4:	78 21                	js     801a17 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8019f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019f9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019ff:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a01:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a04:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a0b:	83 ec 0c             	sub    $0xc,%esp
  801a0e:	50                   	push   %eax
  801a0f:	e8 4a f3 ff ff       	call   800d5e <fd2num>
  801a14:	83 c4 10             	add    $0x10,%esp
}
  801a17:	c9                   	leave  
  801a18:	c3                   	ret    

00801a19 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a19:	55                   	push   %ebp
  801a1a:	89 e5                	mov    %esp,%ebp
  801a1c:	56                   	push   %esi
  801a1d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a1e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a21:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a27:	e8 03 f1 ff ff       	call   800b2f <sys_getenvid>
  801a2c:	83 ec 0c             	sub    $0xc,%esp
  801a2f:	ff 75 0c             	pushl  0xc(%ebp)
  801a32:	ff 75 08             	pushl  0x8(%ebp)
  801a35:	56                   	push   %esi
  801a36:	50                   	push   %eax
  801a37:	68 18 22 80 00       	push   $0x802218
  801a3c:	e8 14 e7 ff ff       	call   800155 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a41:	83 c4 18             	add    $0x18,%esp
  801a44:	53                   	push   %ebx
  801a45:	ff 75 10             	pushl  0x10(%ebp)
  801a48:	e8 b7 e6 ff ff       	call   800104 <vcprintf>
	cprintf("\n");
  801a4d:	c7 04 24 ec 1d 80 00 	movl   $0x801dec,(%esp)
  801a54:	e8 fc e6 ff ff       	call   800155 <cprintf>
  801a59:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a5c:	cc                   	int3   
  801a5d:	eb fd                	jmp    801a5c <_panic+0x43>

00801a5f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a5f:	55                   	push   %ebp
  801a60:	89 e5                	mov    %esp,%ebp
  801a62:	56                   	push   %esi
  801a63:	53                   	push   %ebx
  801a64:	8b 75 08             	mov    0x8(%ebp),%esi
  801a67:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a6a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        //	panic("ipc_recv not implemented");
        int r;
       	if(pg!=NULL){
  801a6d:	85 c0                	test   %eax,%eax
  801a6f:	74 3b                	je     801aac <ipc_recv+0x4d>
	  r = sys_ipc_recv(pg);
  801a71:	83 ec 0c             	sub    $0xc,%esp
  801a74:	50                   	push   %eax
  801a75:	e8 a3 f2 ff ff       	call   800d1d <sys_ipc_recv>
  801a7a:	83 c4 10             	add    $0x10,%esp
	}else
	  r = sys_ipc_recv((void *)UTOP);
	if(r<0){
  801a7d:	85 c0                	test   %eax,%eax
  801a7f:	78 3d                	js     801abe <ipc_recv+0x5f>
	if(perm_store!=NULL){
		*perm_store = 0;
            }
        	return r;
           }else{
	     if(from_env_store!=NULL)
  801a81:	85 f6                	test   %esi,%esi
  801a83:	74 0a                	je     801a8f <ipc_recv+0x30>
		     *from_env_store = thisenv->env_ipc_from;
  801a85:	a1 08 40 80 00       	mov    0x804008,%eax
  801a8a:	8b 40 74             	mov    0x74(%eax),%eax
  801a8d:	89 06                	mov    %eax,(%esi)
	     if(perm_store != NULL)
  801a8f:	85 db                	test   %ebx,%ebx
  801a91:	74 0a                	je     801a9d <ipc_recv+0x3e>
		     *perm_store = thisenv->env_ipc_perm;
  801a93:	a1 08 40 80 00       	mov    0x804008,%eax
  801a98:	8b 40 78             	mov    0x78(%eax),%eax
  801a9b:	89 03                	mov    %eax,(%ebx)
	     return thisenv->env_ipc_value;
  801a9d:	a1 08 40 80 00       	mov    0x804008,%eax
  801aa2:	8b 40 70             	mov    0x70(%eax),%eax
	   }

}
  801aa5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aa8:	5b                   	pop    %ebx
  801aa9:	5e                   	pop    %esi
  801aaa:	5d                   	pop    %ebp
  801aab:	c3                   	ret    
	  r = sys_ipc_recv((void *)UTOP);
  801aac:	83 ec 0c             	sub    $0xc,%esp
  801aaf:	68 00 00 c0 ee       	push   $0xeec00000
  801ab4:	e8 64 f2 ff ff       	call   800d1d <sys_ipc_recv>
  801ab9:	83 c4 10             	add    $0x10,%esp
  801abc:	eb bf                	jmp    801a7d <ipc_recv+0x1e>
	if(from_env_store!=NULL){
  801abe:	85 f6                	test   %esi,%esi
  801ac0:	74 06                	je     801ac8 <ipc_recv+0x69>
	  *from_env_store = 0;
  801ac2:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if(perm_store!=NULL){
  801ac8:	85 db                	test   %ebx,%ebx
  801aca:	74 d9                	je     801aa5 <ipc_recv+0x46>
		*perm_store = 0;
  801acc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ad2:	eb d1                	jmp    801aa5 <ipc_recv+0x46>

00801ad4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ad4:	55                   	push   %ebp
  801ad5:	89 e5                	mov    %esp,%ebp
  801ad7:	57                   	push   %edi
  801ad8:	56                   	push   %esi
  801ad9:	53                   	push   %ebx
  801ada:	83 ec 0c             	sub    $0xc,%esp
  801add:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ae0:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ae3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if(pg==NULL) pg = (void *)UTOP;
  801ae6:	85 db                	test   %ebx,%ebx
  801ae8:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801aed:	0f 44 d8             	cmove  %eax,%ebx
	while((r=sys_ipc_try_send(to_env,val,pg,perm))<0){
  801af0:	ff 75 14             	pushl  0x14(%ebp)
  801af3:	53                   	push   %ebx
  801af4:	56                   	push   %esi
  801af5:	57                   	push   %edi
  801af6:	e8 ff f1 ff ff       	call   800cfa <sys_ipc_try_send>
  801afb:	83 c4 10             	add    $0x10,%esp
  801afe:	85 c0                	test   %eax,%eax
  801b00:	79 20                	jns    801b22 <ipc_send+0x4e>
	    if(r!=-E_IPC_NOT_RECV){
  801b02:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b05:	75 07                	jne    801b0e <ipc_send+0x3a>
		    panic("ipc_send:send message failed\n");
	    }
	    sys_yield();
  801b07:	e8 42 f0 ff ff       	call   800b4e <sys_yield>
  801b0c:	eb e2                	jmp    801af0 <ipc_send+0x1c>
		    panic("ipc_send:send message failed\n");
  801b0e:	83 ec 04             	sub    $0x4,%esp
  801b11:	68 3c 22 80 00       	push   $0x80223c
  801b16:	6a 43                	push   $0x43
  801b18:	68 5a 22 80 00       	push   $0x80225a
  801b1d:	e8 f7 fe ff ff       	call   801a19 <_panic>
	}

}
  801b22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b25:	5b                   	pop    %ebx
  801b26:	5e                   	pop    %esi
  801b27:	5f                   	pop    %edi
  801b28:	5d                   	pop    %ebp
  801b29:	c3                   	ret    

00801b2a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b2a:	55                   	push   %ebp
  801b2b:	89 e5                	mov    %esp,%ebp
  801b2d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b30:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b35:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b38:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b3e:	8b 52 50             	mov    0x50(%edx),%edx
  801b41:	39 ca                	cmp    %ecx,%edx
  801b43:	74 11                	je     801b56 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801b45:	83 c0 01             	add    $0x1,%eax
  801b48:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b4d:	75 e6                	jne    801b35 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801b4f:	b8 00 00 00 00       	mov    $0x0,%eax
  801b54:	eb 0b                	jmp    801b61 <ipc_find_env+0x37>
			return envs[i].env_id;
  801b56:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b59:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b5e:	8b 40 48             	mov    0x48(%eax),%eax
}
  801b61:	5d                   	pop    %ebp
  801b62:	c3                   	ret    

00801b63 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b63:	55                   	push   %ebp
  801b64:	89 e5                	mov    %esp,%ebp
  801b66:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b69:	89 d0                	mov    %edx,%eax
  801b6b:	c1 e8 16             	shr    $0x16,%eax
  801b6e:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b75:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801b7a:	f6 c1 01             	test   $0x1,%cl
  801b7d:	74 1d                	je     801b9c <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801b7f:	c1 ea 0c             	shr    $0xc,%edx
  801b82:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b89:	f6 c2 01             	test   $0x1,%dl
  801b8c:	74 0e                	je     801b9c <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b8e:	c1 ea 0c             	shr    $0xc,%edx
  801b91:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b98:	ef 
  801b99:	0f b7 c0             	movzwl %ax,%eax
}
  801b9c:	5d                   	pop    %ebp
  801b9d:	c3                   	ret    
  801b9e:	66 90                	xchg   %ax,%ax

00801ba0 <__udivdi3>:
  801ba0:	55                   	push   %ebp
  801ba1:	57                   	push   %edi
  801ba2:	56                   	push   %esi
  801ba3:	53                   	push   %ebx
  801ba4:	83 ec 1c             	sub    $0x1c,%esp
  801ba7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801bab:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801baf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801bb3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801bb7:	85 d2                	test   %edx,%edx
  801bb9:	75 35                	jne    801bf0 <__udivdi3+0x50>
  801bbb:	39 f3                	cmp    %esi,%ebx
  801bbd:	0f 87 bd 00 00 00    	ja     801c80 <__udivdi3+0xe0>
  801bc3:	85 db                	test   %ebx,%ebx
  801bc5:	89 d9                	mov    %ebx,%ecx
  801bc7:	75 0b                	jne    801bd4 <__udivdi3+0x34>
  801bc9:	b8 01 00 00 00       	mov    $0x1,%eax
  801bce:	31 d2                	xor    %edx,%edx
  801bd0:	f7 f3                	div    %ebx
  801bd2:	89 c1                	mov    %eax,%ecx
  801bd4:	31 d2                	xor    %edx,%edx
  801bd6:	89 f0                	mov    %esi,%eax
  801bd8:	f7 f1                	div    %ecx
  801bda:	89 c6                	mov    %eax,%esi
  801bdc:	89 e8                	mov    %ebp,%eax
  801bde:	89 f7                	mov    %esi,%edi
  801be0:	f7 f1                	div    %ecx
  801be2:	89 fa                	mov    %edi,%edx
  801be4:	83 c4 1c             	add    $0x1c,%esp
  801be7:	5b                   	pop    %ebx
  801be8:	5e                   	pop    %esi
  801be9:	5f                   	pop    %edi
  801bea:	5d                   	pop    %ebp
  801beb:	c3                   	ret    
  801bec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801bf0:	39 f2                	cmp    %esi,%edx
  801bf2:	77 7c                	ja     801c70 <__udivdi3+0xd0>
  801bf4:	0f bd fa             	bsr    %edx,%edi
  801bf7:	83 f7 1f             	xor    $0x1f,%edi
  801bfa:	0f 84 98 00 00 00    	je     801c98 <__udivdi3+0xf8>
  801c00:	89 f9                	mov    %edi,%ecx
  801c02:	b8 20 00 00 00       	mov    $0x20,%eax
  801c07:	29 f8                	sub    %edi,%eax
  801c09:	d3 e2                	shl    %cl,%edx
  801c0b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c0f:	89 c1                	mov    %eax,%ecx
  801c11:	89 da                	mov    %ebx,%edx
  801c13:	d3 ea                	shr    %cl,%edx
  801c15:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801c19:	09 d1                	or     %edx,%ecx
  801c1b:	89 f2                	mov    %esi,%edx
  801c1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c21:	89 f9                	mov    %edi,%ecx
  801c23:	d3 e3                	shl    %cl,%ebx
  801c25:	89 c1                	mov    %eax,%ecx
  801c27:	d3 ea                	shr    %cl,%edx
  801c29:	89 f9                	mov    %edi,%ecx
  801c2b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c2f:	d3 e6                	shl    %cl,%esi
  801c31:	89 eb                	mov    %ebp,%ebx
  801c33:	89 c1                	mov    %eax,%ecx
  801c35:	d3 eb                	shr    %cl,%ebx
  801c37:	09 de                	or     %ebx,%esi
  801c39:	89 f0                	mov    %esi,%eax
  801c3b:	f7 74 24 08          	divl   0x8(%esp)
  801c3f:	89 d6                	mov    %edx,%esi
  801c41:	89 c3                	mov    %eax,%ebx
  801c43:	f7 64 24 0c          	mull   0xc(%esp)
  801c47:	39 d6                	cmp    %edx,%esi
  801c49:	72 0c                	jb     801c57 <__udivdi3+0xb7>
  801c4b:	89 f9                	mov    %edi,%ecx
  801c4d:	d3 e5                	shl    %cl,%ebp
  801c4f:	39 c5                	cmp    %eax,%ebp
  801c51:	73 5d                	jae    801cb0 <__udivdi3+0x110>
  801c53:	39 d6                	cmp    %edx,%esi
  801c55:	75 59                	jne    801cb0 <__udivdi3+0x110>
  801c57:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801c5a:	31 ff                	xor    %edi,%edi
  801c5c:	89 fa                	mov    %edi,%edx
  801c5e:	83 c4 1c             	add    $0x1c,%esp
  801c61:	5b                   	pop    %ebx
  801c62:	5e                   	pop    %esi
  801c63:	5f                   	pop    %edi
  801c64:	5d                   	pop    %ebp
  801c65:	c3                   	ret    
  801c66:	8d 76 00             	lea    0x0(%esi),%esi
  801c69:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801c70:	31 ff                	xor    %edi,%edi
  801c72:	31 c0                	xor    %eax,%eax
  801c74:	89 fa                	mov    %edi,%edx
  801c76:	83 c4 1c             	add    $0x1c,%esp
  801c79:	5b                   	pop    %ebx
  801c7a:	5e                   	pop    %esi
  801c7b:	5f                   	pop    %edi
  801c7c:	5d                   	pop    %ebp
  801c7d:	c3                   	ret    
  801c7e:	66 90                	xchg   %ax,%ax
  801c80:	31 ff                	xor    %edi,%edi
  801c82:	89 e8                	mov    %ebp,%eax
  801c84:	89 f2                	mov    %esi,%edx
  801c86:	f7 f3                	div    %ebx
  801c88:	89 fa                	mov    %edi,%edx
  801c8a:	83 c4 1c             	add    $0x1c,%esp
  801c8d:	5b                   	pop    %ebx
  801c8e:	5e                   	pop    %esi
  801c8f:	5f                   	pop    %edi
  801c90:	5d                   	pop    %ebp
  801c91:	c3                   	ret    
  801c92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c98:	39 f2                	cmp    %esi,%edx
  801c9a:	72 06                	jb     801ca2 <__udivdi3+0x102>
  801c9c:	31 c0                	xor    %eax,%eax
  801c9e:	39 eb                	cmp    %ebp,%ebx
  801ca0:	77 d2                	ja     801c74 <__udivdi3+0xd4>
  801ca2:	b8 01 00 00 00       	mov    $0x1,%eax
  801ca7:	eb cb                	jmp    801c74 <__udivdi3+0xd4>
  801ca9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cb0:	89 d8                	mov    %ebx,%eax
  801cb2:	31 ff                	xor    %edi,%edi
  801cb4:	eb be                	jmp    801c74 <__udivdi3+0xd4>
  801cb6:	66 90                	xchg   %ax,%ax
  801cb8:	66 90                	xchg   %ax,%ax
  801cba:	66 90                	xchg   %ax,%ax
  801cbc:	66 90                	xchg   %ax,%ax
  801cbe:	66 90                	xchg   %ax,%ax

00801cc0 <__umoddi3>:
  801cc0:	55                   	push   %ebp
  801cc1:	57                   	push   %edi
  801cc2:	56                   	push   %esi
  801cc3:	53                   	push   %ebx
  801cc4:	83 ec 1c             	sub    $0x1c,%esp
  801cc7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801ccb:	8b 74 24 30          	mov    0x30(%esp),%esi
  801ccf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801cd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801cd7:	85 ed                	test   %ebp,%ebp
  801cd9:	89 f0                	mov    %esi,%eax
  801cdb:	89 da                	mov    %ebx,%edx
  801cdd:	75 19                	jne    801cf8 <__umoddi3+0x38>
  801cdf:	39 df                	cmp    %ebx,%edi
  801ce1:	0f 86 b1 00 00 00    	jbe    801d98 <__umoddi3+0xd8>
  801ce7:	f7 f7                	div    %edi
  801ce9:	89 d0                	mov    %edx,%eax
  801ceb:	31 d2                	xor    %edx,%edx
  801ced:	83 c4 1c             	add    $0x1c,%esp
  801cf0:	5b                   	pop    %ebx
  801cf1:	5e                   	pop    %esi
  801cf2:	5f                   	pop    %edi
  801cf3:	5d                   	pop    %ebp
  801cf4:	c3                   	ret    
  801cf5:	8d 76 00             	lea    0x0(%esi),%esi
  801cf8:	39 dd                	cmp    %ebx,%ebp
  801cfa:	77 f1                	ja     801ced <__umoddi3+0x2d>
  801cfc:	0f bd cd             	bsr    %ebp,%ecx
  801cff:	83 f1 1f             	xor    $0x1f,%ecx
  801d02:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801d06:	0f 84 b4 00 00 00    	je     801dc0 <__umoddi3+0x100>
  801d0c:	b8 20 00 00 00       	mov    $0x20,%eax
  801d11:	89 c2                	mov    %eax,%edx
  801d13:	8b 44 24 04          	mov    0x4(%esp),%eax
  801d17:	29 c2                	sub    %eax,%edx
  801d19:	89 c1                	mov    %eax,%ecx
  801d1b:	89 f8                	mov    %edi,%eax
  801d1d:	d3 e5                	shl    %cl,%ebp
  801d1f:	89 d1                	mov    %edx,%ecx
  801d21:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801d25:	d3 e8                	shr    %cl,%eax
  801d27:	09 c5                	or     %eax,%ebp
  801d29:	8b 44 24 04          	mov    0x4(%esp),%eax
  801d2d:	89 c1                	mov    %eax,%ecx
  801d2f:	d3 e7                	shl    %cl,%edi
  801d31:	89 d1                	mov    %edx,%ecx
  801d33:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801d37:	89 df                	mov    %ebx,%edi
  801d39:	d3 ef                	shr    %cl,%edi
  801d3b:	89 c1                	mov    %eax,%ecx
  801d3d:	89 f0                	mov    %esi,%eax
  801d3f:	d3 e3                	shl    %cl,%ebx
  801d41:	89 d1                	mov    %edx,%ecx
  801d43:	89 fa                	mov    %edi,%edx
  801d45:	d3 e8                	shr    %cl,%eax
  801d47:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801d4c:	09 d8                	or     %ebx,%eax
  801d4e:	f7 f5                	div    %ebp
  801d50:	d3 e6                	shl    %cl,%esi
  801d52:	89 d1                	mov    %edx,%ecx
  801d54:	f7 64 24 08          	mull   0x8(%esp)
  801d58:	39 d1                	cmp    %edx,%ecx
  801d5a:	89 c3                	mov    %eax,%ebx
  801d5c:	89 d7                	mov    %edx,%edi
  801d5e:	72 06                	jb     801d66 <__umoddi3+0xa6>
  801d60:	75 0e                	jne    801d70 <__umoddi3+0xb0>
  801d62:	39 c6                	cmp    %eax,%esi
  801d64:	73 0a                	jae    801d70 <__umoddi3+0xb0>
  801d66:	2b 44 24 08          	sub    0x8(%esp),%eax
  801d6a:	19 ea                	sbb    %ebp,%edx
  801d6c:	89 d7                	mov    %edx,%edi
  801d6e:	89 c3                	mov    %eax,%ebx
  801d70:	89 ca                	mov    %ecx,%edx
  801d72:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801d77:	29 de                	sub    %ebx,%esi
  801d79:	19 fa                	sbb    %edi,%edx
  801d7b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  801d7f:	89 d0                	mov    %edx,%eax
  801d81:	d3 e0                	shl    %cl,%eax
  801d83:	89 d9                	mov    %ebx,%ecx
  801d85:	d3 ee                	shr    %cl,%esi
  801d87:	d3 ea                	shr    %cl,%edx
  801d89:	09 f0                	or     %esi,%eax
  801d8b:	83 c4 1c             	add    $0x1c,%esp
  801d8e:	5b                   	pop    %ebx
  801d8f:	5e                   	pop    %esi
  801d90:	5f                   	pop    %edi
  801d91:	5d                   	pop    %ebp
  801d92:	c3                   	ret    
  801d93:	90                   	nop
  801d94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d98:	85 ff                	test   %edi,%edi
  801d9a:	89 f9                	mov    %edi,%ecx
  801d9c:	75 0b                	jne    801da9 <__umoddi3+0xe9>
  801d9e:	b8 01 00 00 00       	mov    $0x1,%eax
  801da3:	31 d2                	xor    %edx,%edx
  801da5:	f7 f7                	div    %edi
  801da7:	89 c1                	mov    %eax,%ecx
  801da9:	89 d8                	mov    %ebx,%eax
  801dab:	31 d2                	xor    %edx,%edx
  801dad:	f7 f1                	div    %ecx
  801daf:	89 f0                	mov    %esi,%eax
  801db1:	f7 f1                	div    %ecx
  801db3:	e9 31 ff ff ff       	jmp    801ce9 <__umoddi3+0x29>
  801db8:	90                   	nop
  801db9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801dc0:	39 dd                	cmp    %ebx,%ebp
  801dc2:	72 08                	jb     801dcc <__umoddi3+0x10c>
  801dc4:	39 f7                	cmp    %esi,%edi
  801dc6:	0f 87 21 ff ff ff    	ja     801ced <__umoddi3+0x2d>
  801dcc:	89 da                	mov    %ebx,%edx
  801dce:	89 f0                	mov    %esi,%eax
  801dd0:	29 f8                	sub    %edi,%eax
  801dd2:	19 ea                	sbb    %ebp,%edx
  801dd4:	e9 14 ff ff ff       	jmp    801ced <__umoddi3+0x2d>
