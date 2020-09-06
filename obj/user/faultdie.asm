
obj/user/faultdie.debug:     file format elf32-i386


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
  80002c:	e8 4f 00 00 00       	call   800080 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
  800039:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  80003c:	8b 42 04             	mov    0x4(%edx),%eax
  80003f:	83 e0 07             	and    $0x7,%eax
  800042:	50                   	push   %eax
  800043:	ff 32                	pushl  (%edx)
  800045:	68 a0 1e 80 00       	push   $0x801ea0
  80004a:	e8 26 01 00 00       	call   800175 <cprintf>
	sys_env_destroy(sys_getenvid());
  80004f:	e8 fb 0a 00 00       	call   800b4f <sys_getenvid>
  800054:	89 04 24             	mov    %eax,(%esp)
  800057:	e8 b2 0a 00 00       	call   800b0e <sys_env_destroy>
}
  80005c:	83 c4 10             	add    $0x10,%esp
  80005f:	c9                   	leave  
  800060:	c3                   	ret    

00800061 <umain>:

void
umain(int argc, char **argv)
{
  800061:	55                   	push   %ebp
  800062:	89 e5                	mov    %esp,%ebp
  800064:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800067:	68 33 00 80 00       	push   $0x800033
  80006c:	e8 0d 0d 00 00       	call   800d7e <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800071:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800078:	00 00 00 
}
  80007b:	83 c4 10             	add    $0x10,%esp
  80007e:	c9                   	leave  
  80007f:	c3                   	ret    

00800080 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	56                   	push   %esi
  800084:	53                   	push   %ebx
  800085:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800088:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80008b:	e8 bf 0a 00 00       	call   800b4f <sys_getenvid>
  800090:	25 ff 03 00 00       	and    $0x3ff,%eax
  800095:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800098:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80009d:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a2:	85 db                	test   %ebx,%ebx
  8000a4:	7e 07                	jle    8000ad <libmain+0x2d>
		binaryname = argv[0];
  8000a6:	8b 06                	mov    (%esi),%eax
  8000a8:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ad:	83 ec 08             	sub    $0x8,%esp
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
  8000b2:	e8 aa ff ff ff       	call   800061 <umain>

	// exit gracefully
	exit();
  8000b7:	e8 0a 00 00 00       	call   8000c6 <exit>
}
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c2:	5b                   	pop    %ebx
  8000c3:	5e                   	pop    %esi
  8000c4:	5d                   	pop    %ebp
  8000c5:	c3                   	ret    

008000c6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c6:	55                   	push   %ebp
  8000c7:	89 e5                	mov    %esp,%ebp
  8000c9:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000cc:	e8 0f 0f 00 00       	call   800fe0 <close_all>
	sys_env_destroy(0);
  8000d1:	83 ec 0c             	sub    $0xc,%esp
  8000d4:	6a 00                	push   $0x0
  8000d6:	e8 33 0a 00 00       	call   800b0e <sys_env_destroy>
}
  8000db:	83 c4 10             	add    $0x10,%esp
  8000de:	c9                   	leave  
  8000df:	c3                   	ret    

008000e0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	53                   	push   %ebx
  8000e4:	83 ec 04             	sub    $0x4,%esp
  8000e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ea:	8b 13                	mov    (%ebx),%edx
  8000ec:	8d 42 01             	lea    0x1(%edx),%eax
  8000ef:	89 03                	mov    %eax,(%ebx)
  8000f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000f4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000f8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000fd:	74 09                	je     800108 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000ff:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800103:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800106:	c9                   	leave  
  800107:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800108:	83 ec 08             	sub    $0x8,%esp
  80010b:	68 ff 00 00 00       	push   $0xff
  800110:	8d 43 08             	lea    0x8(%ebx),%eax
  800113:	50                   	push   %eax
  800114:	e8 b8 09 00 00       	call   800ad1 <sys_cputs>
		b->idx = 0;
  800119:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80011f:	83 c4 10             	add    $0x10,%esp
  800122:	eb db                	jmp    8000ff <putch+0x1f>

00800124 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80012d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800134:	00 00 00 
	b.cnt = 0;
  800137:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80013e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800141:	ff 75 0c             	pushl  0xc(%ebp)
  800144:	ff 75 08             	pushl  0x8(%ebp)
  800147:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80014d:	50                   	push   %eax
  80014e:	68 e0 00 80 00       	push   $0x8000e0
  800153:	e8 1a 01 00 00       	call   800272 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800158:	83 c4 08             	add    $0x8,%esp
  80015b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800161:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800167:	50                   	push   %eax
  800168:	e8 64 09 00 00       	call   800ad1 <sys_cputs>

	return b.cnt;
}
  80016d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800173:	c9                   	leave  
  800174:	c3                   	ret    

00800175 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800175:	55                   	push   %ebp
  800176:	89 e5                	mov    %esp,%ebp
  800178:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80017b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80017e:	50                   	push   %eax
  80017f:	ff 75 08             	pushl  0x8(%ebp)
  800182:	e8 9d ff ff ff       	call   800124 <vcprintf>
	va_end(ap);

	return cnt;
}
  800187:	c9                   	leave  
  800188:	c3                   	ret    

00800189 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800189:	55                   	push   %ebp
  80018a:	89 e5                	mov    %esp,%ebp
  80018c:	57                   	push   %edi
  80018d:	56                   	push   %esi
  80018e:	53                   	push   %ebx
  80018f:	83 ec 1c             	sub    $0x1c,%esp
  800192:	89 c7                	mov    %eax,%edi
  800194:	89 d6                	mov    %edx,%esi
  800196:	8b 45 08             	mov    0x8(%ebp),%eax
  800199:	8b 55 0c             	mov    0xc(%ebp),%edx
  80019c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80019f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001a5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001aa:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001ad:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001b0:	39 d3                	cmp    %edx,%ebx
  8001b2:	72 05                	jb     8001b9 <printnum+0x30>
  8001b4:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001b7:	77 7a                	ja     800233 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b9:	83 ec 0c             	sub    $0xc,%esp
  8001bc:	ff 75 18             	pushl  0x18(%ebp)
  8001bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8001c2:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001c5:	53                   	push   %ebx
  8001c6:	ff 75 10             	pushl  0x10(%ebp)
  8001c9:	83 ec 08             	sub    $0x8,%esp
  8001cc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001cf:	ff 75 e0             	pushl  -0x20(%ebp)
  8001d2:	ff 75 dc             	pushl  -0x24(%ebp)
  8001d5:	ff 75 d8             	pushl  -0x28(%ebp)
  8001d8:	e8 73 1a 00 00       	call   801c50 <__udivdi3>
  8001dd:	83 c4 18             	add    $0x18,%esp
  8001e0:	52                   	push   %edx
  8001e1:	50                   	push   %eax
  8001e2:	89 f2                	mov    %esi,%edx
  8001e4:	89 f8                	mov    %edi,%eax
  8001e6:	e8 9e ff ff ff       	call   800189 <printnum>
  8001eb:	83 c4 20             	add    $0x20,%esp
  8001ee:	eb 13                	jmp    800203 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001f0:	83 ec 08             	sub    $0x8,%esp
  8001f3:	56                   	push   %esi
  8001f4:	ff 75 18             	pushl  0x18(%ebp)
  8001f7:	ff d7                	call   *%edi
  8001f9:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001fc:	83 eb 01             	sub    $0x1,%ebx
  8001ff:	85 db                	test   %ebx,%ebx
  800201:	7f ed                	jg     8001f0 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800203:	83 ec 08             	sub    $0x8,%esp
  800206:	56                   	push   %esi
  800207:	83 ec 04             	sub    $0x4,%esp
  80020a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80020d:	ff 75 e0             	pushl  -0x20(%ebp)
  800210:	ff 75 dc             	pushl  -0x24(%ebp)
  800213:	ff 75 d8             	pushl  -0x28(%ebp)
  800216:	e8 55 1b 00 00       	call   801d70 <__umoddi3>
  80021b:	83 c4 14             	add    $0x14,%esp
  80021e:	0f be 80 c6 1e 80 00 	movsbl 0x801ec6(%eax),%eax
  800225:	50                   	push   %eax
  800226:	ff d7                	call   *%edi
}
  800228:	83 c4 10             	add    $0x10,%esp
  80022b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022e:	5b                   	pop    %ebx
  80022f:	5e                   	pop    %esi
  800230:	5f                   	pop    %edi
  800231:	5d                   	pop    %ebp
  800232:	c3                   	ret    
  800233:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800236:	eb c4                	jmp    8001fc <printnum+0x73>

00800238 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80023e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800242:	8b 10                	mov    (%eax),%edx
  800244:	3b 50 04             	cmp    0x4(%eax),%edx
  800247:	73 0a                	jae    800253 <sprintputch+0x1b>
		*b->buf++ = ch;
  800249:	8d 4a 01             	lea    0x1(%edx),%ecx
  80024c:	89 08                	mov    %ecx,(%eax)
  80024e:	8b 45 08             	mov    0x8(%ebp),%eax
  800251:	88 02                	mov    %al,(%edx)
}
  800253:	5d                   	pop    %ebp
  800254:	c3                   	ret    

00800255 <printfmt>:
{
  800255:	55                   	push   %ebp
  800256:	89 e5                	mov    %esp,%ebp
  800258:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80025b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80025e:	50                   	push   %eax
  80025f:	ff 75 10             	pushl  0x10(%ebp)
  800262:	ff 75 0c             	pushl  0xc(%ebp)
  800265:	ff 75 08             	pushl  0x8(%ebp)
  800268:	e8 05 00 00 00       	call   800272 <vprintfmt>
}
  80026d:	83 c4 10             	add    $0x10,%esp
  800270:	c9                   	leave  
  800271:	c3                   	ret    

00800272 <vprintfmt>:
{
  800272:	55                   	push   %ebp
  800273:	89 e5                	mov    %esp,%ebp
  800275:	57                   	push   %edi
  800276:	56                   	push   %esi
  800277:	53                   	push   %ebx
  800278:	83 ec 2c             	sub    $0x2c,%esp
  80027b:	8b 75 08             	mov    0x8(%ebp),%esi
  80027e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800281:	8b 7d 10             	mov    0x10(%ebp),%edi
  800284:	e9 c1 03 00 00       	jmp    80064a <vprintfmt+0x3d8>
		padc = ' ';
  800289:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  80028d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800294:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  80029b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002a2:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002a7:	8d 47 01             	lea    0x1(%edi),%eax
  8002aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ad:	0f b6 17             	movzbl (%edi),%edx
  8002b0:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002b3:	3c 55                	cmp    $0x55,%al
  8002b5:	0f 87 12 04 00 00    	ja     8006cd <vprintfmt+0x45b>
  8002bb:	0f b6 c0             	movzbl %al,%eax
  8002be:	ff 24 85 00 20 80 00 	jmp    *0x802000(,%eax,4)
  8002c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002c8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8002cc:	eb d9                	jmp    8002a7 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8002ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  8002d1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002d5:	eb d0                	jmp    8002a7 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8002d7:	0f b6 d2             	movzbl %dl,%edx
  8002da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8002e2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002e5:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002e8:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002ec:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002ef:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002f2:	83 f9 09             	cmp    $0x9,%ecx
  8002f5:	77 55                	ja     80034c <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  8002f7:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8002fa:	eb e9                	jmp    8002e5 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  8002fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8002ff:	8b 00                	mov    (%eax),%eax
  800301:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800304:	8b 45 14             	mov    0x14(%ebp),%eax
  800307:	8d 40 04             	lea    0x4(%eax),%eax
  80030a:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80030d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800310:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800314:	79 91                	jns    8002a7 <vprintfmt+0x35>
				width = precision, precision = -1;
  800316:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800319:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80031c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800323:	eb 82                	jmp    8002a7 <vprintfmt+0x35>
  800325:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800328:	85 c0                	test   %eax,%eax
  80032a:	ba 00 00 00 00       	mov    $0x0,%edx
  80032f:	0f 49 d0             	cmovns %eax,%edx
  800332:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800335:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800338:	e9 6a ff ff ff       	jmp    8002a7 <vprintfmt+0x35>
  80033d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800340:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800347:	e9 5b ff ff ff       	jmp    8002a7 <vprintfmt+0x35>
  80034c:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80034f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800352:	eb bc                	jmp    800310 <vprintfmt+0x9e>
			lflag++;
  800354:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800357:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80035a:	e9 48 ff ff ff       	jmp    8002a7 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  80035f:	8b 45 14             	mov    0x14(%ebp),%eax
  800362:	8d 78 04             	lea    0x4(%eax),%edi
  800365:	83 ec 08             	sub    $0x8,%esp
  800368:	53                   	push   %ebx
  800369:	ff 30                	pushl  (%eax)
  80036b:	ff d6                	call   *%esi
			break;
  80036d:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800370:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800373:	e9 cf 02 00 00       	jmp    800647 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  800378:	8b 45 14             	mov    0x14(%ebp),%eax
  80037b:	8d 78 04             	lea    0x4(%eax),%edi
  80037e:	8b 00                	mov    (%eax),%eax
  800380:	99                   	cltd   
  800381:	31 d0                	xor    %edx,%eax
  800383:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800385:	83 f8 0f             	cmp    $0xf,%eax
  800388:	7f 23                	jg     8003ad <vprintfmt+0x13b>
  80038a:	8b 14 85 60 21 80 00 	mov    0x802160(,%eax,4),%edx
  800391:	85 d2                	test   %edx,%edx
  800393:	74 18                	je     8003ad <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800395:	52                   	push   %edx
  800396:	68 b5 22 80 00       	push   $0x8022b5
  80039b:	53                   	push   %ebx
  80039c:	56                   	push   %esi
  80039d:	e8 b3 fe ff ff       	call   800255 <printfmt>
  8003a2:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003a5:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003a8:	e9 9a 02 00 00       	jmp    800647 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  8003ad:	50                   	push   %eax
  8003ae:	68 de 1e 80 00       	push   $0x801ede
  8003b3:	53                   	push   %ebx
  8003b4:	56                   	push   %esi
  8003b5:	e8 9b fe ff ff       	call   800255 <printfmt>
  8003ba:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003bd:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003c0:	e9 82 02 00 00       	jmp    800647 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  8003c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c8:	83 c0 04             	add    $0x4,%eax
  8003cb:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d1:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003d3:	85 ff                	test   %edi,%edi
  8003d5:	b8 d7 1e 80 00       	mov    $0x801ed7,%eax
  8003da:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8003dd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003e1:	0f 8e bd 00 00 00    	jle    8004a4 <vprintfmt+0x232>
  8003e7:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8003eb:	75 0e                	jne    8003fb <vprintfmt+0x189>
  8003ed:	89 75 08             	mov    %esi,0x8(%ebp)
  8003f0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8003f3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8003f6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8003f9:	eb 6d                	jmp    800468 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003fb:	83 ec 08             	sub    $0x8,%esp
  8003fe:	ff 75 d0             	pushl  -0x30(%ebp)
  800401:	57                   	push   %edi
  800402:	e8 6e 03 00 00       	call   800775 <strnlen>
  800407:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80040a:	29 c1                	sub    %eax,%ecx
  80040c:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80040f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800412:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800416:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800419:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80041c:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  80041e:	eb 0f                	jmp    80042f <vprintfmt+0x1bd>
					putch(padc, putdat);
  800420:	83 ec 08             	sub    $0x8,%esp
  800423:	53                   	push   %ebx
  800424:	ff 75 e0             	pushl  -0x20(%ebp)
  800427:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800429:	83 ef 01             	sub    $0x1,%edi
  80042c:	83 c4 10             	add    $0x10,%esp
  80042f:	85 ff                	test   %edi,%edi
  800431:	7f ed                	jg     800420 <vprintfmt+0x1ae>
  800433:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800436:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800439:	85 c9                	test   %ecx,%ecx
  80043b:	b8 00 00 00 00       	mov    $0x0,%eax
  800440:	0f 49 c1             	cmovns %ecx,%eax
  800443:	29 c1                	sub    %eax,%ecx
  800445:	89 75 08             	mov    %esi,0x8(%ebp)
  800448:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80044b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80044e:	89 cb                	mov    %ecx,%ebx
  800450:	eb 16                	jmp    800468 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  800452:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800456:	75 31                	jne    800489 <vprintfmt+0x217>
					putch(ch, putdat);
  800458:	83 ec 08             	sub    $0x8,%esp
  80045b:	ff 75 0c             	pushl  0xc(%ebp)
  80045e:	50                   	push   %eax
  80045f:	ff 55 08             	call   *0x8(%ebp)
  800462:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800465:	83 eb 01             	sub    $0x1,%ebx
  800468:	83 c7 01             	add    $0x1,%edi
  80046b:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  80046f:	0f be c2             	movsbl %dl,%eax
  800472:	85 c0                	test   %eax,%eax
  800474:	74 59                	je     8004cf <vprintfmt+0x25d>
  800476:	85 f6                	test   %esi,%esi
  800478:	78 d8                	js     800452 <vprintfmt+0x1e0>
  80047a:	83 ee 01             	sub    $0x1,%esi
  80047d:	79 d3                	jns    800452 <vprintfmt+0x1e0>
  80047f:	89 df                	mov    %ebx,%edi
  800481:	8b 75 08             	mov    0x8(%ebp),%esi
  800484:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800487:	eb 37                	jmp    8004c0 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  800489:	0f be d2             	movsbl %dl,%edx
  80048c:	83 ea 20             	sub    $0x20,%edx
  80048f:	83 fa 5e             	cmp    $0x5e,%edx
  800492:	76 c4                	jbe    800458 <vprintfmt+0x1e6>
					putch('?', putdat);
  800494:	83 ec 08             	sub    $0x8,%esp
  800497:	ff 75 0c             	pushl  0xc(%ebp)
  80049a:	6a 3f                	push   $0x3f
  80049c:	ff 55 08             	call   *0x8(%ebp)
  80049f:	83 c4 10             	add    $0x10,%esp
  8004a2:	eb c1                	jmp    800465 <vprintfmt+0x1f3>
  8004a4:	89 75 08             	mov    %esi,0x8(%ebp)
  8004a7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004aa:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ad:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004b0:	eb b6                	jmp    800468 <vprintfmt+0x1f6>
				putch(' ', putdat);
  8004b2:	83 ec 08             	sub    $0x8,%esp
  8004b5:	53                   	push   %ebx
  8004b6:	6a 20                	push   $0x20
  8004b8:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004ba:	83 ef 01             	sub    $0x1,%edi
  8004bd:	83 c4 10             	add    $0x10,%esp
  8004c0:	85 ff                	test   %edi,%edi
  8004c2:	7f ee                	jg     8004b2 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  8004c4:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004c7:	89 45 14             	mov    %eax,0x14(%ebp)
  8004ca:	e9 78 01 00 00       	jmp    800647 <vprintfmt+0x3d5>
  8004cf:	89 df                	mov    %ebx,%edi
  8004d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8004d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004d7:	eb e7                	jmp    8004c0 <vprintfmt+0x24e>
	if (lflag >= 2)
  8004d9:	83 f9 01             	cmp    $0x1,%ecx
  8004dc:	7e 3f                	jle    80051d <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  8004de:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e1:	8b 50 04             	mov    0x4(%eax),%edx
  8004e4:	8b 00                	mov    (%eax),%eax
  8004e6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004e9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ef:	8d 40 08             	lea    0x8(%eax),%eax
  8004f2:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8004f5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004f9:	79 5c                	jns    800557 <vprintfmt+0x2e5>
				putch('-', putdat);
  8004fb:	83 ec 08             	sub    $0x8,%esp
  8004fe:	53                   	push   %ebx
  8004ff:	6a 2d                	push   $0x2d
  800501:	ff d6                	call   *%esi
				num = -(long long) num;
  800503:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800506:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800509:	f7 da                	neg    %edx
  80050b:	83 d1 00             	adc    $0x0,%ecx
  80050e:	f7 d9                	neg    %ecx
  800510:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800513:	b8 0a 00 00 00       	mov    $0xa,%eax
  800518:	e9 10 01 00 00       	jmp    80062d <vprintfmt+0x3bb>
	else if (lflag)
  80051d:	85 c9                	test   %ecx,%ecx
  80051f:	75 1b                	jne    80053c <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800521:	8b 45 14             	mov    0x14(%ebp),%eax
  800524:	8b 00                	mov    (%eax),%eax
  800526:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800529:	89 c1                	mov    %eax,%ecx
  80052b:	c1 f9 1f             	sar    $0x1f,%ecx
  80052e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800531:	8b 45 14             	mov    0x14(%ebp),%eax
  800534:	8d 40 04             	lea    0x4(%eax),%eax
  800537:	89 45 14             	mov    %eax,0x14(%ebp)
  80053a:	eb b9                	jmp    8004f5 <vprintfmt+0x283>
		return va_arg(*ap, long);
  80053c:	8b 45 14             	mov    0x14(%ebp),%eax
  80053f:	8b 00                	mov    (%eax),%eax
  800541:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800544:	89 c1                	mov    %eax,%ecx
  800546:	c1 f9 1f             	sar    $0x1f,%ecx
  800549:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80054c:	8b 45 14             	mov    0x14(%ebp),%eax
  80054f:	8d 40 04             	lea    0x4(%eax),%eax
  800552:	89 45 14             	mov    %eax,0x14(%ebp)
  800555:	eb 9e                	jmp    8004f5 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  800557:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80055a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80055d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800562:	e9 c6 00 00 00       	jmp    80062d <vprintfmt+0x3bb>
	if (lflag >= 2)
  800567:	83 f9 01             	cmp    $0x1,%ecx
  80056a:	7e 18                	jle    800584 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  80056c:	8b 45 14             	mov    0x14(%ebp),%eax
  80056f:	8b 10                	mov    (%eax),%edx
  800571:	8b 48 04             	mov    0x4(%eax),%ecx
  800574:	8d 40 08             	lea    0x8(%eax),%eax
  800577:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80057a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80057f:	e9 a9 00 00 00       	jmp    80062d <vprintfmt+0x3bb>
	else if (lflag)
  800584:	85 c9                	test   %ecx,%ecx
  800586:	75 1a                	jne    8005a2 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  800588:	8b 45 14             	mov    0x14(%ebp),%eax
  80058b:	8b 10                	mov    (%eax),%edx
  80058d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800592:	8d 40 04             	lea    0x4(%eax),%eax
  800595:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800598:	b8 0a 00 00 00       	mov    $0xa,%eax
  80059d:	e9 8b 00 00 00       	jmp    80062d <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8005a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a5:	8b 10                	mov    (%eax),%edx
  8005a7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ac:	8d 40 04             	lea    0x4(%eax),%eax
  8005af:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005b2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b7:	eb 74                	jmp    80062d <vprintfmt+0x3bb>
	if (lflag >= 2)
  8005b9:	83 f9 01             	cmp    $0x1,%ecx
  8005bc:	7e 15                	jle    8005d3 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  8005be:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c1:	8b 10                	mov    (%eax),%edx
  8005c3:	8b 48 04             	mov    0x4(%eax),%ecx
  8005c6:	8d 40 08             	lea    0x8(%eax),%eax
  8005c9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8005cc:	b8 08 00 00 00       	mov    $0x8,%eax
  8005d1:	eb 5a                	jmp    80062d <vprintfmt+0x3bb>
	else if (lflag)
  8005d3:	85 c9                	test   %ecx,%ecx
  8005d5:	75 17                	jne    8005ee <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  8005d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005da:	8b 10                	mov    (%eax),%edx
  8005dc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e1:	8d 40 04             	lea    0x4(%eax),%eax
  8005e4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8005e7:	b8 08 00 00 00       	mov    $0x8,%eax
  8005ec:	eb 3f                	jmp    80062d <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8005ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f1:	8b 10                	mov    (%eax),%edx
  8005f3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f8:	8d 40 04             	lea    0x4(%eax),%eax
  8005fb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8005fe:	b8 08 00 00 00       	mov    $0x8,%eax
  800603:	eb 28                	jmp    80062d <vprintfmt+0x3bb>
			putch('0', putdat);
  800605:	83 ec 08             	sub    $0x8,%esp
  800608:	53                   	push   %ebx
  800609:	6a 30                	push   $0x30
  80060b:	ff d6                	call   *%esi
			putch('x', putdat);
  80060d:	83 c4 08             	add    $0x8,%esp
  800610:	53                   	push   %ebx
  800611:	6a 78                	push   $0x78
  800613:	ff d6                	call   *%esi
			num = (unsigned long long)
  800615:	8b 45 14             	mov    0x14(%ebp),%eax
  800618:	8b 10                	mov    (%eax),%edx
  80061a:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80061f:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800622:	8d 40 04             	lea    0x4(%eax),%eax
  800625:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800628:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80062d:	83 ec 0c             	sub    $0xc,%esp
  800630:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800634:	57                   	push   %edi
  800635:	ff 75 e0             	pushl  -0x20(%ebp)
  800638:	50                   	push   %eax
  800639:	51                   	push   %ecx
  80063a:	52                   	push   %edx
  80063b:	89 da                	mov    %ebx,%edx
  80063d:	89 f0                	mov    %esi,%eax
  80063f:	e8 45 fb ff ff       	call   800189 <printnum>
			break;
  800644:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800647:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80064a:	83 c7 01             	add    $0x1,%edi
  80064d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800651:	83 f8 25             	cmp    $0x25,%eax
  800654:	0f 84 2f fc ff ff    	je     800289 <vprintfmt+0x17>
			if (ch == '\0')
  80065a:	85 c0                	test   %eax,%eax
  80065c:	0f 84 8b 00 00 00    	je     8006ed <vprintfmt+0x47b>
			putch(ch, putdat);
  800662:	83 ec 08             	sub    $0x8,%esp
  800665:	53                   	push   %ebx
  800666:	50                   	push   %eax
  800667:	ff d6                	call   *%esi
  800669:	83 c4 10             	add    $0x10,%esp
  80066c:	eb dc                	jmp    80064a <vprintfmt+0x3d8>
	if (lflag >= 2)
  80066e:	83 f9 01             	cmp    $0x1,%ecx
  800671:	7e 15                	jle    800688 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  800673:	8b 45 14             	mov    0x14(%ebp),%eax
  800676:	8b 10                	mov    (%eax),%edx
  800678:	8b 48 04             	mov    0x4(%eax),%ecx
  80067b:	8d 40 08             	lea    0x8(%eax),%eax
  80067e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800681:	b8 10 00 00 00       	mov    $0x10,%eax
  800686:	eb a5                	jmp    80062d <vprintfmt+0x3bb>
	else if (lflag)
  800688:	85 c9                	test   %ecx,%ecx
  80068a:	75 17                	jne    8006a3 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  80068c:	8b 45 14             	mov    0x14(%ebp),%eax
  80068f:	8b 10                	mov    (%eax),%edx
  800691:	b9 00 00 00 00       	mov    $0x0,%ecx
  800696:	8d 40 04             	lea    0x4(%eax),%eax
  800699:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80069c:	b8 10 00 00 00       	mov    $0x10,%eax
  8006a1:	eb 8a                	jmp    80062d <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8006a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a6:	8b 10                	mov    (%eax),%edx
  8006a8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ad:	8d 40 04             	lea    0x4(%eax),%eax
  8006b0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b3:	b8 10 00 00 00       	mov    $0x10,%eax
  8006b8:	e9 70 ff ff ff       	jmp    80062d <vprintfmt+0x3bb>
			putch(ch, putdat);
  8006bd:	83 ec 08             	sub    $0x8,%esp
  8006c0:	53                   	push   %ebx
  8006c1:	6a 25                	push   $0x25
  8006c3:	ff d6                	call   *%esi
			break;
  8006c5:	83 c4 10             	add    $0x10,%esp
  8006c8:	e9 7a ff ff ff       	jmp    800647 <vprintfmt+0x3d5>
			putch('%', putdat);
  8006cd:	83 ec 08             	sub    $0x8,%esp
  8006d0:	53                   	push   %ebx
  8006d1:	6a 25                	push   $0x25
  8006d3:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006d5:	83 c4 10             	add    $0x10,%esp
  8006d8:	89 f8                	mov    %edi,%eax
  8006da:	eb 03                	jmp    8006df <vprintfmt+0x46d>
  8006dc:	83 e8 01             	sub    $0x1,%eax
  8006df:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006e3:	75 f7                	jne    8006dc <vprintfmt+0x46a>
  8006e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006e8:	e9 5a ff ff ff       	jmp    800647 <vprintfmt+0x3d5>
}
  8006ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f0:	5b                   	pop    %ebx
  8006f1:	5e                   	pop    %esi
  8006f2:	5f                   	pop    %edi
  8006f3:	5d                   	pop    %ebp
  8006f4:	c3                   	ret    

008006f5 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f5:	55                   	push   %ebp
  8006f6:	89 e5                	mov    %esp,%ebp
  8006f8:	83 ec 18             	sub    $0x18,%esp
  8006fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fe:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800701:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800704:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800708:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80070b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800712:	85 c0                	test   %eax,%eax
  800714:	74 26                	je     80073c <vsnprintf+0x47>
  800716:	85 d2                	test   %edx,%edx
  800718:	7e 22                	jle    80073c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80071a:	ff 75 14             	pushl  0x14(%ebp)
  80071d:	ff 75 10             	pushl  0x10(%ebp)
  800720:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800723:	50                   	push   %eax
  800724:	68 38 02 80 00       	push   $0x800238
  800729:	e8 44 fb ff ff       	call   800272 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80072e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800731:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800734:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800737:	83 c4 10             	add    $0x10,%esp
}
  80073a:	c9                   	leave  
  80073b:	c3                   	ret    
		return -E_INVAL;
  80073c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800741:	eb f7                	jmp    80073a <vsnprintf+0x45>

00800743 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800743:	55                   	push   %ebp
  800744:	89 e5                	mov    %esp,%ebp
  800746:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800749:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80074c:	50                   	push   %eax
  80074d:	ff 75 10             	pushl  0x10(%ebp)
  800750:	ff 75 0c             	pushl  0xc(%ebp)
  800753:	ff 75 08             	pushl  0x8(%ebp)
  800756:	e8 9a ff ff ff       	call   8006f5 <vsnprintf>
	va_end(ap);

	return rc;
}
  80075b:	c9                   	leave  
  80075c:	c3                   	ret    

0080075d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80075d:	55                   	push   %ebp
  80075e:	89 e5                	mov    %esp,%ebp
  800760:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800763:	b8 00 00 00 00       	mov    $0x0,%eax
  800768:	eb 03                	jmp    80076d <strlen+0x10>
		n++;
  80076a:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80076d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800771:	75 f7                	jne    80076a <strlen+0xd>
	return n;
}
  800773:	5d                   	pop    %ebp
  800774:	c3                   	ret    

00800775 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800775:	55                   	push   %ebp
  800776:	89 e5                	mov    %esp,%ebp
  800778:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80077b:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80077e:	b8 00 00 00 00       	mov    $0x0,%eax
  800783:	eb 03                	jmp    800788 <strnlen+0x13>
		n++;
  800785:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800788:	39 d0                	cmp    %edx,%eax
  80078a:	74 06                	je     800792 <strnlen+0x1d>
  80078c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800790:	75 f3                	jne    800785 <strnlen+0x10>
	return n;
}
  800792:	5d                   	pop    %ebp
  800793:	c3                   	ret    

00800794 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800794:	55                   	push   %ebp
  800795:	89 e5                	mov    %esp,%ebp
  800797:	53                   	push   %ebx
  800798:	8b 45 08             	mov    0x8(%ebp),%eax
  80079b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80079e:	89 c2                	mov    %eax,%edx
  8007a0:	83 c1 01             	add    $0x1,%ecx
  8007a3:	83 c2 01             	add    $0x1,%edx
  8007a6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007aa:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007ad:	84 db                	test   %bl,%bl
  8007af:	75 ef                	jne    8007a0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007b1:	5b                   	pop    %ebx
  8007b2:	5d                   	pop    %ebp
  8007b3:	c3                   	ret    

008007b4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	53                   	push   %ebx
  8007b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007bb:	53                   	push   %ebx
  8007bc:	e8 9c ff ff ff       	call   80075d <strlen>
  8007c1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007c4:	ff 75 0c             	pushl  0xc(%ebp)
  8007c7:	01 d8                	add    %ebx,%eax
  8007c9:	50                   	push   %eax
  8007ca:	e8 c5 ff ff ff       	call   800794 <strcpy>
	return dst;
}
  8007cf:	89 d8                	mov    %ebx,%eax
  8007d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d4:	c9                   	leave  
  8007d5:	c3                   	ret    

008007d6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007d6:	55                   	push   %ebp
  8007d7:	89 e5                	mov    %esp,%ebp
  8007d9:	56                   	push   %esi
  8007da:	53                   	push   %ebx
  8007db:	8b 75 08             	mov    0x8(%ebp),%esi
  8007de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e1:	89 f3                	mov    %esi,%ebx
  8007e3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e6:	89 f2                	mov    %esi,%edx
  8007e8:	eb 0f                	jmp    8007f9 <strncpy+0x23>
		*dst++ = *src;
  8007ea:	83 c2 01             	add    $0x1,%edx
  8007ed:	0f b6 01             	movzbl (%ecx),%eax
  8007f0:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007f3:	80 39 01             	cmpb   $0x1,(%ecx)
  8007f6:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8007f9:	39 da                	cmp    %ebx,%edx
  8007fb:	75 ed                	jne    8007ea <strncpy+0x14>
	}
	return ret;
}
  8007fd:	89 f0                	mov    %esi,%eax
  8007ff:	5b                   	pop    %ebx
  800800:	5e                   	pop    %esi
  800801:	5d                   	pop    %ebp
  800802:	c3                   	ret    

00800803 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800803:	55                   	push   %ebp
  800804:	89 e5                	mov    %esp,%ebp
  800806:	56                   	push   %esi
  800807:	53                   	push   %ebx
  800808:	8b 75 08             	mov    0x8(%ebp),%esi
  80080b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80080e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800811:	89 f0                	mov    %esi,%eax
  800813:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800817:	85 c9                	test   %ecx,%ecx
  800819:	75 0b                	jne    800826 <strlcpy+0x23>
  80081b:	eb 17                	jmp    800834 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80081d:	83 c2 01             	add    $0x1,%edx
  800820:	83 c0 01             	add    $0x1,%eax
  800823:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800826:	39 d8                	cmp    %ebx,%eax
  800828:	74 07                	je     800831 <strlcpy+0x2e>
  80082a:	0f b6 0a             	movzbl (%edx),%ecx
  80082d:	84 c9                	test   %cl,%cl
  80082f:	75 ec                	jne    80081d <strlcpy+0x1a>
		*dst = '\0';
  800831:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800834:	29 f0                	sub    %esi,%eax
}
  800836:	5b                   	pop    %ebx
  800837:	5e                   	pop    %esi
  800838:	5d                   	pop    %ebp
  800839:	c3                   	ret    

0080083a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800840:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800843:	eb 06                	jmp    80084b <strcmp+0x11>
		p++, q++;
  800845:	83 c1 01             	add    $0x1,%ecx
  800848:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80084b:	0f b6 01             	movzbl (%ecx),%eax
  80084e:	84 c0                	test   %al,%al
  800850:	74 04                	je     800856 <strcmp+0x1c>
  800852:	3a 02                	cmp    (%edx),%al
  800854:	74 ef                	je     800845 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800856:	0f b6 c0             	movzbl %al,%eax
  800859:	0f b6 12             	movzbl (%edx),%edx
  80085c:	29 d0                	sub    %edx,%eax
}
  80085e:	5d                   	pop    %ebp
  80085f:	c3                   	ret    

00800860 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	53                   	push   %ebx
  800864:	8b 45 08             	mov    0x8(%ebp),%eax
  800867:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086a:	89 c3                	mov    %eax,%ebx
  80086c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80086f:	eb 06                	jmp    800877 <strncmp+0x17>
		n--, p++, q++;
  800871:	83 c0 01             	add    $0x1,%eax
  800874:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800877:	39 d8                	cmp    %ebx,%eax
  800879:	74 16                	je     800891 <strncmp+0x31>
  80087b:	0f b6 08             	movzbl (%eax),%ecx
  80087e:	84 c9                	test   %cl,%cl
  800880:	74 04                	je     800886 <strncmp+0x26>
  800882:	3a 0a                	cmp    (%edx),%cl
  800884:	74 eb                	je     800871 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800886:	0f b6 00             	movzbl (%eax),%eax
  800889:	0f b6 12             	movzbl (%edx),%edx
  80088c:	29 d0                	sub    %edx,%eax
}
  80088e:	5b                   	pop    %ebx
  80088f:	5d                   	pop    %ebp
  800890:	c3                   	ret    
		return 0;
  800891:	b8 00 00 00 00       	mov    $0x0,%eax
  800896:	eb f6                	jmp    80088e <strncmp+0x2e>

00800898 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800898:	55                   	push   %ebp
  800899:	89 e5                	mov    %esp,%ebp
  80089b:	8b 45 08             	mov    0x8(%ebp),%eax
  80089e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a2:	0f b6 10             	movzbl (%eax),%edx
  8008a5:	84 d2                	test   %dl,%dl
  8008a7:	74 09                	je     8008b2 <strchr+0x1a>
		if (*s == c)
  8008a9:	38 ca                	cmp    %cl,%dl
  8008ab:	74 0a                	je     8008b7 <strchr+0x1f>
	for (; *s; s++)
  8008ad:	83 c0 01             	add    $0x1,%eax
  8008b0:	eb f0                	jmp    8008a2 <strchr+0xa>
			return (char *) s;
	return 0;
  8008b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008b7:	5d                   	pop    %ebp
  8008b8:	c3                   	ret    

008008b9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c3:	eb 03                	jmp    8008c8 <strfind+0xf>
  8008c5:	83 c0 01             	add    $0x1,%eax
  8008c8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008cb:	38 ca                	cmp    %cl,%dl
  8008cd:	74 04                	je     8008d3 <strfind+0x1a>
  8008cf:	84 d2                	test   %dl,%dl
  8008d1:	75 f2                	jne    8008c5 <strfind+0xc>
			break;
	return (char *) s;
}
  8008d3:	5d                   	pop    %ebp
  8008d4:	c3                   	ret    

008008d5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008d5:	55                   	push   %ebp
  8008d6:	89 e5                	mov    %esp,%ebp
  8008d8:	57                   	push   %edi
  8008d9:	56                   	push   %esi
  8008da:	53                   	push   %ebx
  8008db:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008de:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008e1:	85 c9                	test   %ecx,%ecx
  8008e3:	74 13                	je     8008f8 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008e5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008eb:	75 05                	jne    8008f2 <memset+0x1d>
  8008ed:	f6 c1 03             	test   $0x3,%cl
  8008f0:	74 0d                	je     8008ff <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f5:	fc                   	cld    
  8008f6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008f8:	89 f8                	mov    %edi,%eax
  8008fa:	5b                   	pop    %ebx
  8008fb:	5e                   	pop    %esi
  8008fc:	5f                   	pop    %edi
  8008fd:	5d                   	pop    %ebp
  8008fe:	c3                   	ret    
		c &= 0xFF;
  8008ff:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800903:	89 d3                	mov    %edx,%ebx
  800905:	c1 e3 08             	shl    $0x8,%ebx
  800908:	89 d0                	mov    %edx,%eax
  80090a:	c1 e0 18             	shl    $0x18,%eax
  80090d:	89 d6                	mov    %edx,%esi
  80090f:	c1 e6 10             	shl    $0x10,%esi
  800912:	09 f0                	or     %esi,%eax
  800914:	09 c2                	or     %eax,%edx
  800916:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800918:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80091b:	89 d0                	mov    %edx,%eax
  80091d:	fc                   	cld    
  80091e:	f3 ab                	rep stos %eax,%es:(%edi)
  800920:	eb d6                	jmp    8008f8 <memset+0x23>

00800922 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	57                   	push   %edi
  800926:	56                   	push   %esi
  800927:	8b 45 08             	mov    0x8(%ebp),%eax
  80092a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80092d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800930:	39 c6                	cmp    %eax,%esi
  800932:	73 35                	jae    800969 <memmove+0x47>
  800934:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800937:	39 c2                	cmp    %eax,%edx
  800939:	76 2e                	jbe    800969 <memmove+0x47>
		s += n;
		d += n;
  80093b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80093e:	89 d6                	mov    %edx,%esi
  800940:	09 fe                	or     %edi,%esi
  800942:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800948:	74 0c                	je     800956 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80094a:	83 ef 01             	sub    $0x1,%edi
  80094d:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800950:	fd                   	std    
  800951:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800953:	fc                   	cld    
  800954:	eb 21                	jmp    800977 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800956:	f6 c1 03             	test   $0x3,%cl
  800959:	75 ef                	jne    80094a <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80095b:	83 ef 04             	sub    $0x4,%edi
  80095e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800961:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800964:	fd                   	std    
  800965:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800967:	eb ea                	jmp    800953 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800969:	89 f2                	mov    %esi,%edx
  80096b:	09 c2                	or     %eax,%edx
  80096d:	f6 c2 03             	test   $0x3,%dl
  800970:	74 09                	je     80097b <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800972:	89 c7                	mov    %eax,%edi
  800974:	fc                   	cld    
  800975:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800977:	5e                   	pop    %esi
  800978:	5f                   	pop    %edi
  800979:	5d                   	pop    %ebp
  80097a:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80097b:	f6 c1 03             	test   $0x3,%cl
  80097e:	75 f2                	jne    800972 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800980:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800983:	89 c7                	mov    %eax,%edi
  800985:	fc                   	cld    
  800986:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800988:	eb ed                	jmp    800977 <memmove+0x55>

0080098a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80098d:	ff 75 10             	pushl  0x10(%ebp)
  800990:	ff 75 0c             	pushl  0xc(%ebp)
  800993:	ff 75 08             	pushl  0x8(%ebp)
  800996:	e8 87 ff ff ff       	call   800922 <memmove>
}
  80099b:	c9                   	leave  
  80099c:	c3                   	ret    

0080099d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80099d:	55                   	push   %ebp
  80099e:	89 e5                	mov    %esp,%ebp
  8009a0:	56                   	push   %esi
  8009a1:	53                   	push   %ebx
  8009a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a8:	89 c6                	mov    %eax,%esi
  8009aa:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ad:	39 f0                	cmp    %esi,%eax
  8009af:	74 1c                	je     8009cd <memcmp+0x30>
		if (*s1 != *s2)
  8009b1:	0f b6 08             	movzbl (%eax),%ecx
  8009b4:	0f b6 1a             	movzbl (%edx),%ebx
  8009b7:	38 d9                	cmp    %bl,%cl
  8009b9:	75 08                	jne    8009c3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009bb:	83 c0 01             	add    $0x1,%eax
  8009be:	83 c2 01             	add    $0x1,%edx
  8009c1:	eb ea                	jmp    8009ad <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8009c3:	0f b6 c1             	movzbl %cl,%eax
  8009c6:	0f b6 db             	movzbl %bl,%ebx
  8009c9:	29 d8                	sub    %ebx,%eax
  8009cb:	eb 05                	jmp    8009d2 <memcmp+0x35>
	}

	return 0;
  8009cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d2:	5b                   	pop    %ebx
  8009d3:	5e                   	pop    %esi
  8009d4:	5d                   	pop    %ebp
  8009d5:	c3                   	ret    

008009d6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
  8009d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009df:	89 c2                	mov    %eax,%edx
  8009e1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009e4:	39 d0                	cmp    %edx,%eax
  8009e6:	73 09                	jae    8009f1 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e8:	38 08                	cmp    %cl,(%eax)
  8009ea:	74 05                	je     8009f1 <memfind+0x1b>
	for (; s < ends; s++)
  8009ec:	83 c0 01             	add    $0x1,%eax
  8009ef:	eb f3                	jmp    8009e4 <memfind+0xe>
			break;
	return (void *) s;
}
  8009f1:	5d                   	pop    %ebp
  8009f2:	c3                   	ret    

008009f3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	57                   	push   %edi
  8009f7:	56                   	push   %esi
  8009f8:	53                   	push   %ebx
  8009f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009fc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ff:	eb 03                	jmp    800a04 <strtol+0x11>
		s++;
  800a01:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a04:	0f b6 01             	movzbl (%ecx),%eax
  800a07:	3c 20                	cmp    $0x20,%al
  800a09:	74 f6                	je     800a01 <strtol+0xe>
  800a0b:	3c 09                	cmp    $0x9,%al
  800a0d:	74 f2                	je     800a01 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a0f:	3c 2b                	cmp    $0x2b,%al
  800a11:	74 2e                	je     800a41 <strtol+0x4e>
	int neg = 0;
  800a13:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a18:	3c 2d                	cmp    $0x2d,%al
  800a1a:	74 2f                	je     800a4b <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a1c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a22:	75 05                	jne    800a29 <strtol+0x36>
  800a24:	80 39 30             	cmpb   $0x30,(%ecx)
  800a27:	74 2c                	je     800a55 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a29:	85 db                	test   %ebx,%ebx
  800a2b:	75 0a                	jne    800a37 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a2d:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a32:	80 39 30             	cmpb   $0x30,(%ecx)
  800a35:	74 28                	je     800a5f <strtol+0x6c>
		base = 10;
  800a37:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3c:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a3f:	eb 50                	jmp    800a91 <strtol+0x9e>
		s++;
  800a41:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a44:	bf 00 00 00 00       	mov    $0x0,%edi
  800a49:	eb d1                	jmp    800a1c <strtol+0x29>
		s++, neg = 1;
  800a4b:	83 c1 01             	add    $0x1,%ecx
  800a4e:	bf 01 00 00 00       	mov    $0x1,%edi
  800a53:	eb c7                	jmp    800a1c <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a55:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a59:	74 0e                	je     800a69 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a5b:	85 db                	test   %ebx,%ebx
  800a5d:	75 d8                	jne    800a37 <strtol+0x44>
		s++, base = 8;
  800a5f:	83 c1 01             	add    $0x1,%ecx
  800a62:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a67:	eb ce                	jmp    800a37 <strtol+0x44>
		s += 2, base = 16;
  800a69:	83 c1 02             	add    $0x2,%ecx
  800a6c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a71:	eb c4                	jmp    800a37 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800a73:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a76:	89 f3                	mov    %esi,%ebx
  800a78:	80 fb 19             	cmp    $0x19,%bl
  800a7b:	77 29                	ja     800aa6 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800a7d:	0f be d2             	movsbl %dl,%edx
  800a80:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a83:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a86:	7d 30                	jge    800ab8 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800a88:	83 c1 01             	add    $0x1,%ecx
  800a8b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a8f:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a91:	0f b6 11             	movzbl (%ecx),%edx
  800a94:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a97:	89 f3                	mov    %esi,%ebx
  800a99:	80 fb 09             	cmp    $0x9,%bl
  800a9c:	77 d5                	ja     800a73 <strtol+0x80>
			dig = *s - '0';
  800a9e:	0f be d2             	movsbl %dl,%edx
  800aa1:	83 ea 30             	sub    $0x30,%edx
  800aa4:	eb dd                	jmp    800a83 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800aa6:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aa9:	89 f3                	mov    %esi,%ebx
  800aab:	80 fb 19             	cmp    $0x19,%bl
  800aae:	77 08                	ja     800ab8 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800ab0:	0f be d2             	movsbl %dl,%edx
  800ab3:	83 ea 37             	sub    $0x37,%edx
  800ab6:	eb cb                	jmp    800a83 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ab8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800abc:	74 05                	je     800ac3 <strtol+0xd0>
		*endptr = (char *) s;
  800abe:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac1:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ac3:	89 c2                	mov    %eax,%edx
  800ac5:	f7 da                	neg    %edx
  800ac7:	85 ff                	test   %edi,%edi
  800ac9:	0f 45 c2             	cmovne %edx,%eax
}
  800acc:	5b                   	pop    %ebx
  800acd:	5e                   	pop    %esi
  800ace:	5f                   	pop    %edi
  800acf:	5d                   	pop    %ebp
  800ad0:	c3                   	ret    

00800ad1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ad1:	55                   	push   %ebp
  800ad2:	89 e5                	mov    %esp,%ebp
  800ad4:	57                   	push   %edi
  800ad5:	56                   	push   %esi
  800ad6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ad7:	b8 00 00 00 00       	mov    $0x0,%eax
  800adc:	8b 55 08             	mov    0x8(%ebp),%edx
  800adf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae2:	89 c3                	mov    %eax,%ebx
  800ae4:	89 c7                	mov    %eax,%edi
  800ae6:	89 c6                	mov    %eax,%esi
  800ae8:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aea:	5b                   	pop    %ebx
  800aeb:	5e                   	pop    %esi
  800aec:	5f                   	pop    %edi
  800aed:	5d                   	pop    %ebp
  800aee:	c3                   	ret    

00800aef <sys_cgetc>:

int
sys_cgetc(void)
{
  800aef:	55                   	push   %ebp
  800af0:	89 e5                	mov    %esp,%ebp
  800af2:	57                   	push   %edi
  800af3:	56                   	push   %esi
  800af4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800af5:	ba 00 00 00 00       	mov    $0x0,%edx
  800afa:	b8 01 00 00 00       	mov    $0x1,%eax
  800aff:	89 d1                	mov    %edx,%ecx
  800b01:	89 d3                	mov    %edx,%ebx
  800b03:	89 d7                	mov    %edx,%edi
  800b05:	89 d6                	mov    %edx,%esi
  800b07:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b09:	5b                   	pop    %ebx
  800b0a:	5e                   	pop    %esi
  800b0b:	5f                   	pop    %edi
  800b0c:	5d                   	pop    %ebp
  800b0d:	c3                   	ret    

00800b0e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b0e:	55                   	push   %ebp
  800b0f:	89 e5                	mov    %esp,%ebp
  800b11:	57                   	push   %edi
  800b12:	56                   	push   %esi
  800b13:	53                   	push   %ebx
  800b14:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b17:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b1f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b24:	89 cb                	mov    %ecx,%ebx
  800b26:	89 cf                	mov    %ecx,%edi
  800b28:	89 ce                	mov    %ecx,%esi
  800b2a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b2c:	85 c0                	test   %eax,%eax
  800b2e:	7f 08                	jg     800b38 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b33:	5b                   	pop    %ebx
  800b34:	5e                   	pop    %esi
  800b35:	5f                   	pop    %edi
  800b36:	5d                   	pop    %ebp
  800b37:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b38:	83 ec 0c             	sub    $0xc,%esp
  800b3b:	50                   	push   %eax
  800b3c:	6a 03                	push   $0x3
  800b3e:	68 bf 21 80 00       	push   $0x8021bf
  800b43:	6a 23                	push   $0x23
  800b45:	68 dc 21 80 00       	push   $0x8021dc
  800b4a:	e8 76 0f 00 00       	call   801ac5 <_panic>

00800b4f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b4f:	55                   	push   %ebp
  800b50:	89 e5                	mov    %esp,%ebp
  800b52:	57                   	push   %edi
  800b53:	56                   	push   %esi
  800b54:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b55:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5a:	b8 02 00 00 00       	mov    $0x2,%eax
  800b5f:	89 d1                	mov    %edx,%ecx
  800b61:	89 d3                	mov    %edx,%ebx
  800b63:	89 d7                	mov    %edx,%edi
  800b65:	89 d6                	mov    %edx,%esi
  800b67:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b69:	5b                   	pop    %ebx
  800b6a:	5e                   	pop    %esi
  800b6b:	5f                   	pop    %edi
  800b6c:	5d                   	pop    %ebp
  800b6d:	c3                   	ret    

00800b6e <sys_yield>:

void
sys_yield(void)
{
  800b6e:	55                   	push   %ebp
  800b6f:	89 e5                	mov    %esp,%ebp
  800b71:	57                   	push   %edi
  800b72:	56                   	push   %esi
  800b73:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b74:	ba 00 00 00 00       	mov    $0x0,%edx
  800b79:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b7e:	89 d1                	mov    %edx,%ecx
  800b80:	89 d3                	mov    %edx,%ebx
  800b82:	89 d7                	mov    %edx,%edi
  800b84:	89 d6                	mov    %edx,%esi
  800b86:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b88:	5b                   	pop    %ebx
  800b89:	5e                   	pop    %esi
  800b8a:	5f                   	pop    %edi
  800b8b:	5d                   	pop    %ebp
  800b8c:	c3                   	ret    

00800b8d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b8d:	55                   	push   %ebp
  800b8e:	89 e5                	mov    %esp,%ebp
  800b90:	57                   	push   %edi
  800b91:	56                   	push   %esi
  800b92:	53                   	push   %ebx
  800b93:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b96:	be 00 00 00 00       	mov    $0x0,%esi
  800b9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba1:	b8 04 00 00 00       	mov    $0x4,%eax
  800ba6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ba9:	89 f7                	mov    %esi,%edi
  800bab:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bad:	85 c0                	test   %eax,%eax
  800baf:	7f 08                	jg     800bb9 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb4:	5b                   	pop    %ebx
  800bb5:	5e                   	pop    %esi
  800bb6:	5f                   	pop    %edi
  800bb7:	5d                   	pop    %ebp
  800bb8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb9:	83 ec 0c             	sub    $0xc,%esp
  800bbc:	50                   	push   %eax
  800bbd:	6a 04                	push   $0x4
  800bbf:	68 bf 21 80 00       	push   $0x8021bf
  800bc4:	6a 23                	push   $0x23
  800bc6:	68 dc 21 80 00       	push   $0x8021dc
  800bcb:	e8 f5 0e 00 00       	call   801ac5 <_panic>

00800bd0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bd0:	55                   	push   %ebp
  800bd1:	89 e5                	mov    %esp,%ebp
  800bd3:	57                   	push   %edi
  800bd4:	56                   	push   %esi
  800bd5:	53                   	push   %ebx
  800bd6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bdf:	b8 05 00 00 00       	mov    $0x5,%eax
  800be4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800be7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bea:	8b 75 18             	mov    0x18(%ebp),%esi
  800bed:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bef:	85 c0                	test   %eax,%eax
  800bf1:	7f 08                	jg     800bfb <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bf3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf6:	5b                   	pop    %ebx
  800bf7:	5e                   	pop    %esi
  800bf8:	5f                   	pop    %edi
  800bf9:	5d                   	pop    %ebp
  800bfa:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfb:	83 ec 0c             	sub    $0xc,%esp
  800bfe:	50                   	push   %eax
  800bff:	6a 05                	push   $0x5
  800c01:	68 bf 21 80 00       	push   $0x8021bf
  800c06:	6a 23                	push   $0x23
  800c08:	68 dc 21 80 00       	push   $0x8021dc
  800c0d:	e8 b3 0e 00 00       	call   801ac5 <_panic>

00800c12 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	57                   	push   %edi
  800c16:	56                   	push   %esi
  800c17:	53                   	push   %ebx
  800c18:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c1b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c20:	8b 55 08             	mov    0x8(%ebp),%edx
  800c23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c26:	b8 06 00 00 00       	mov    $0x6,%eax
  800c2b:	89 df                	mov    %ebx,%edi
  800c2d:	89 de                	mov    %ebx,%esi
  800c2f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c31:	85 c0                	test   %eax,%eax
  800c33:	7f 08                	jg     800c3d <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c38:	5b                   	pop    %ebx
  800c39:	5e                   	pop    %esi
  800c3a:	5f                   	pop    %edi
  800c3b:	5d                   	pop    %ebp
  800c3c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3d:	83 ec 0c             	sub    $0xc,%esp
  800c40:	50                   	push   %eax
  800c41:	6a 06                	push   $0x6
  800c43:	68 bf 21 80 00       	push   $0x8021bf
  800c48:	6a 23                	push   $0x23
  800c4a:	68 dc 21 80 00       	push   $0x8021dc
  800c4f:	e8 71 0e 00 00       	call   801ac5 <_panic>

00800c54 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c54:	55                   	push   %ebp
  800c55:	89 e5                	mov    %esp,%ebp
  800c57:	57                   	push   %edi
  800c58:	56                   	push   %esi
  800c59:	53                   	push   %ebx
  800c5a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c5d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c62:	8b 55 08             	mov    0x8(%ebp),%edx
  800c65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c68:	b8 08 00 00 00       	mov    $0x8,%eax
  800c6d:	89 df                	mov    %ebx,%edi
  800c6f:	89 de                	mov    %ebx,%esi
  800c71:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c73:	85 c0                	test   %eax,%eax
  800c75:	7f 08                	jg     800c7f <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7a:	5b                   	pop    %ebx
  800c7b:	5e                   	pop    %esi
  800c7c:	5f                   	pop    %edi
  800c7d:	5d                   	pop    %ebp
  800c7e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7f:	83 ec 0c             	sub    $0xc,%esp
  800c82:	50                   	push   %eax
  800c83:	6a 08                	push   $0x8
  800c85:	68 bf 21 80 00       	push   $0x8021bf
  800c8a:	6a 23                	push   $0x23
  800c8c:	68 dc 21 80 00       	push   $0x8021dc
  800c91:	e8 2f 0e 00 00       	call   801ac5 <_panic>

00800c96 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c96:	55                   	push   %ebp
  800c97:	89 e5                	mov    %esp,%ebp
  800c99:	57                   	push   %edi
  800c9a:	56                   	push   %esi
  800c9b:	53                   	push   %ebx
  800c9c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c9f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800caa:	b8 09 00 00 00       	mov    $0x9,%eax
  800caf:	89 df                	mov    %ebx,%edi
  800cb1:	89 de                	mov    %ebx,%esi
  800cb3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cb5:	85 c0                	test   %eax,%eax
  800cb7:	7f 08                	jg     800cc1 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbc:	5b                   	pop    %ebx
  800cbd:	5e                   	pop    %esi
  800cbe:	5f                   	pop    %edi
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc1:	83 ec 0c             	sub    $0xc,%esp
  800cc4:	50                   	push   %eax
  800cc5:	6a 09                	push   $0x9
  800cc7:	68 bf 21 80 00       	push   $0x8021bf
  800ccc:	6a 23                	push   $0x23
  800cce:	68 dc 21 80 00       	push   $0x8021dc
  800cd3:	e8 ed 0d 00 00       	call   801ac5 <_panic>

00800cd8 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cd8:	55                   	push   %ebp
  800cd9:	89 e5                	mov    %esp,%ebp
  800cdb:	57                   	push   %edi
  800cdc:	56                   	push   %esi
  800cdd:	53                   	push   %ebx
  800cde:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ce1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cec:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cf1:	89 df                	mov    %ebx,%edi
  800cf3:	89 de                	mov    %ebx,%esi
  800cf5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cf7:	85 c0                	test   %eax,%eax
  800cf9:	7f 08                	jg     800d03 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfe:	5b                   	pop    %ebx
  800cff:	5e                   	pop    %esi
  800d00:	5f                   	pop    %edi
  800d01:	5d                   	pop    %ebp
  800d02:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d03:	83 ec 0c             	sub    $0xc,%esp
  800d06:	50                   	push   %eax
  800d07:	6a 0a                	push   $0xa
  800d09:	68 bf 21 80 00       	push   $0x8021bf
  800d0e:	6a 23                	push   $0x23
  800d10:	68 dc 21 80 00       	push   $0x8021dc
  800d15:	e8 ab 0d 00 00       	call   801ac5 <_panic>

00800d1a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d1a:	55                   	push   %ebp
  800d1b:	89 e5                	mov    %esp,%ebp
  800d1d:	57                   	push   %edi
  800d1e:	56                   	push   %esi
  800d1f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d20:	8b 55 08             	mov    0x8(%ebp),%edx
  800d23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d26:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d2b:	be 00 00 00 00       	mov    $0x0,%esi
  800d30:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d33:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d36:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d38:	5b                   	pop    %ebx
  800d39:	5e                   	pop    %esi
  800d3a:	5f                   	pop    %edi
  800d3b:	5d                   	pop    %ebp
  800d3c:	c3                   	ret    

00800d3d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d3d:	55                   	push   %ebp
  800d3e:	89 e5                	mov    %esp,%ebp
  800d40:	57                   	push   %edi
  800d41:	56                   	push   %esi
  800d42:	53                   	push   %ebx
  800d43:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d46:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d53:	89 cb                	mov    %ecx,%ebx
  800d55:	89 cf                	mov    %ecx,%edi
  800d57:	89 ce                	mov    %ecx,%esi
  800d59:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d5b:	85 c0                	test   %eax,%eax
  800d5d:	7f 08                	jg     800d67 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d62:	5b                   	pop    %ebx
  800d63:	5e                   	pop    %esi
  800d64:	5f                   	pop    %edi
  800d65:	5d                   	pop    %ebp
  800d66:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d67:	83 ec 0c             	sub    $0xc,%esp
  800d6a:	50                   	push   %eax
  800d6b:	6a 0d                	push   $0xd
  800d6d:	68 bf 21 80 00       	push   $0x8021bf
  800d72:	6a 23                	push   $0x23
  800d74:	68 dc 21 80 00       	push   $0x8021dc
  800d79:	e8 47 0d 00 00       	call   801ac5 <_panic>

00800d7e <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d7e:	55                   	push   %ebp
  800d7f:	89 e5                	mov    %esp,%ebp
  800d81:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d84:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800d8b:	74 0a                	je     800d97 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler %e",r);
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
	}
       
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d90:	a3 08 40 80 00       	mov    %eax,0x804008
}
  800d95:	c9                   	leave  
  800d96:	c3                   	ret    
		if((r=sys_page_alloc(thisenv->env_id,(void *)UXSTACKTOP-PGSIZE,PTE_P|PTE_W|PTE_U))<0)
  800d97:	a1 04 40 80 00       	mov    0x804004,%eax
  800d9c:	8b 40 48             	mov    0x48(%eax),%eax
  800d9f:	83 ec 04             	sub    $0x4,%esp
  800da2:	6a 07                	push   $0x7
  800da4:	68 00 f0 bf ee       	push   $0xeebff000
  800da9:	50                   	push   %eax
  800daa:	e8 de fd ff ff       	call   800b8d <sys_page_alloc>
  800daf:	83 c4 10             	add    $0x10,%esp
  800db2:	85 c0                	test   %eax,%eax
  800db4:	78 1b                	js     800dd1 <set_pgfault_handler+0x53>
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
  800db6:	a1 04 40 80 00       	mov    0x804004,%eax
  800dbb:	8b 40 48             	mov    0x48(%eax),%eax
  800dbe:	83 ec 08             	sub    $0x8,%esp
  800dc1:	68 e3 0d 80 00       	push   $0x800de3
  800dc6:	50                   	push   %eax
  800dc7:	e8 0c ff ff ff       	call   800cd8 <sys_env_set_pgfault_upcall>
  800dcc:	83 c4 10             	add    $0x10,%esp
  800dcf:	eb bc                	jmp    800d8d <set_pgfault_handler+0xf>
			panic("set_pgfault_handler %e",r);
  800dd1:	50                   	push   %eax
  800dd2:	68 ea 21 80 00       	push   $0x8021ea
  800dd7:	6a 22                	push   $0x22
  800dd9:	68 01 22 80 00       	push   $0x802201
  800dde:	e8 e2 0c 00 00       	call   801ac5 <_panic>

00800de3 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800de3:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800de4:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800de9:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800deb:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 48(%esp), %ebp
  800dee:	8b 6c 24 30          	mov    0x30(%esp),%ebp
        subl $4, %ebp
  800df2:	83 ed 04             	sub    $0x4,%ebp
        movl %ebp, 48(%esp)
  800df5:	89 6c 24 30          	mov    %ebp,0x30(%esp)
        movl 40(%esp), %eax
  800df9:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl %eax, (%ebp)
  800dfd:	89 45 00             	mov    %eax,0x0(%ebp)
	// Restore the trap-time registers.  After you do this, you
 	// can no longer modify any general-purpose registers.
 	// LAB 4: Your code here.
        addl $8, %esp
  800e00:	83 c4 08             	add    $0x8,%esp
        popal
  800e03:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $4, %esp
  800e04:	83 c4 04             	add    $0x4,%esp
        popfl
  800e07:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  800e08:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  800e09:	c3                   	ret    

00800e0a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e10:	05 00 00 00 30       	add    $0x30000000,%eax
  800e15:	c1 e8 0c             	shr    $0xc,%eax
}
  800e18:	5d                   	pop    %ebp
  800e19:	c3                   	ret    

00800e1a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e1a:	55                   	push   %ebp
  800e1b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e20:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800e25:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e2a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e2f:	5d                   	pop    %ebp
  800e30:	c3                   	ret    

00800e31 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e31:	55                   	push   %ebp
  800e32:	89 e5                	mov    %esp,%ebp
  800e34:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e37:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e3c:	89 c2                	mov    %eax,%edx
  800e3e:	c1 ea 16             	shr    $0x16,%edx
  800e41:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e48:	f6 c2 01             	test   $0x1,%dl
  800e4b:	74 2a                	je     800e77 <fd_alloc+0x46>
  800e4d:	89 c2                	mov    %eax,%edx
  800e4f:	c1 ea 0c             	shr    $0xc,%edx
  800e52:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e59:	f6 c2 01             	test   $0x1,%dl
  800e5c:	74 19                	je     800e77 <fd_alloc+0x46>
  800e5e:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800e63:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e68:	75 d2                	jne    800e3c <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e6a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e70:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800e75:	eb 07                	jmp    800e7e <fd_alloc+0x4d>
			*fd_store = fd;
  800e77:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e79:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e7e:	5d                   	pop    %ebp
  800e7f:	c3                   	ret    

00800e80 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e80:	55                   	push   %ebp
  800e81:	89 e5                	mov    %esp,%ebp
  800e83:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e86:	83 f8 1f             	cmp    $0x1f,%eax
  800e89:	77 36                	ja     800ec1 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e8b:	c1 e0 0c             	shl    $0xc,%eax
  800e8e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e93:	89 c2                	mov    %eax,%edx
  800e95:	c1 ea 16             	shr    $0x16,%edx
  800e98:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e9f:	f6 c2 01             	test   $0x1,%dl
  800ea2:	74 24                	je     800ec8 <fd_lookup+0x48>
  800ea4:	89 c2                	mov    %eax,%edx
  800ea6:	c1 ea 0c             	shr    $0xc,%edx
  800ea9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800eb0:	f6 c2 01             	test   $0x1,%dl
  800eb3:	74 1a                	je     800ecf <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800eb5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eb8:	89 02                	mov    %eax,(%edx)
	return 0;
  800eba:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ebf:	5d                   	pop    %ebp
  800ec0:	c3                   	ret    
		return -E_INVAL;
  800ec1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ec6:	eb f7                	jmp    800ebf <fd_lookup+0x3f>
		return -E_INVAL;
  800ec8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ecd:	eb f0                	jmp    800ebf <fd_lookup+0x3f>
  800ecf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ed4:	eb e9                	jmp    800ebf <fd_lookup+0x3f>

00800ed6 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ed6:	55                   	push   %ebp
  800ed7:	89 e5                	mov    %esp,%ebp
  800ed9:	83 ec 08             	sub    $0x8,%esp
  800edc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800edf:	ba 8c 22 80 00       	mov    $0x80228c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800ee4:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800ee9:	39 08                	cmp    %ecx,(%eax)
  800eeb:	74 33                	je     800f20 <dev_lookup+0x4a>
  800eed:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800ef0:	8b 02                	mov    (%edx),%eax
  800ef2:	85 c0                	test   %eax,%eax
  800ef4:	75 f3                	jne    800ee9 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ef6:	a1 04 40 80 00       	mov    0x804004,%eax
  800efb:	8b 40 48             	mov    0x48(%eax),%eax
  800efe:	83 ec 04             	sub    $0x4,%esp
  800f01:	51                   	push   %ecx
  800f02:	50                   	push   %eax
  800f03:	68 10 22 80 00       	push   $0x802210
  800f08:	e8 68 f2 ff ff       	call   800175 <cprintf>
	*dev = 0;
  800f0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f10:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f16:	83 c4 10             	add    $0x10,%esp
  800f19:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f1e:	c9                   	leave  
  800f1f:	c3                   	ret    
			*dev = devtab[i];
  800f20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f23:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f25:	b8 00 00 00 00       	mov    $0x0,%eax
  800f2a:	eb f2                	jmp    800f1e <dev_lookup+0x48>

00800f2c <fd_close>:
{
  800f2c:	55                   	push   %ebp
  800f2d:	89 e5                	mov    %esp,%ebp
  800f2f:	57                   	push   %edi
  800f30:	56                   	push   %esi
  800f31:	53                   	push   %ebx
  800f32:	83 ec 1c             	sub    $0x1c,%esp
  800f35:	8b 75 08             	mov    0x8(%ebp),%esi
  800f38:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f3b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f3e:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f3f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f45:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f48:	50                   	push   %eax
  800f49:	e8 32 ff ff ff       	call   800e80 <fd_lookup>
  800f4e:	89 c3                	mov    %eax,%ebx
  800f50:	83 c4 08             	add    $0x8,%esp
  800f53:	85 c0                	test   %eax,%eax
  800f55:	78 05                	js     800f5c <fd_close+0x30>
	    || fd != fd2)
  800f57:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800f5a:	74 16                	je     800f72 <fd_close+0x46>
		return (must_exist ? r : 0);
  800f5c:	89 f8                	mov    %edi,%eax
  800f5e:	84 c0                	test   %al,%al
  800f60:	b8 00 00 00 00       	mov    $0x0,%eax
  800f65:	0f 44 d8             	cmove  %eax,%ebx
}
  800f68:	89 d8                	mov    %ebx,%eax
  800f6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f6d:	5b                   	pop    %ebx
  800f6e:	5e                   	pop    %esi
  800f6f:	5f                   	pop    %edi
  800f70:	5d                   	pop    %ebp
  800f71:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f72:	83 ec 08             	sub    $0x8,%esp
  800f75:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800f78:	50                   	push   %eax
  800f79:	ff 36                	pushl  (%esi)
  800f7b:	e8 56 ff ff ff       	call   800ed6 <dev_lookup>
  800f80:	89 c3                	mov    %eax,%ebx
  800f82:	83 c4 10             	add    $0x10,%esp
  800f85:	85 c0                	test   %eax,%eax
  800f87:	78 15                	js     800f9e <fd_close+0x72>
		if (dev->dev_close)
  800f89:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f8c:	8b 40 10             	mov    0x10(%eax),%eax
  800f8f:	85 c0                	test   %eax,%eax
  800f91:	74 1b                	je     800fae <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  800f93:	83 ec 0c             	sub    $0xc,%esp
  800f96:	56                   	push   %esi
  800f97:	ff d0                	call   *%eax
  800f99:	89 c3                	mov    %eax,%ebx
  800f9b:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800f9e:	83 ec 08             	sub    $0x8,%esp
  800fa1:	56                   	push   %esi
  800fa2:	6a 00                	push   $0x0
  800fa4:	e8 69 fc ff ff       	call   800c12 <sys_page_unmap>
	return r;
  800fa9:	83 c4 10             	add    $0x10,%esp
  800fac:	eb ba                	jmp    800f68 <fd_close+0x3c>
			r = 0;
  800fae:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fb3:	eb e9                	jmp    800f9e <fd_close+0x72>

00800fb5 <close>:

int
close(int fdnum)
{
  800fb5:	55                   	push   %ebp
  800fb6:	89 e5                	mov    %esp,%ebp
  800fb8:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fbb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fbe:	50                   	push   %eax
  800fbf:	ff 75 08             	pushl  0x8(%ebp)
  800fc2:	e8 b9 fe ff ff       	call   800e80 <fd_lookup>
  800fc7:	83 c4 08             	add    $0x8,%esp
  800fca:	85 c0                	test   %eax,%eax
  800fcc:	78 10                	js     800fde <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fce:	83 ec 08             	sub    $0x8,%esp
  800fd1:	6a 01                	push   $0x1
  800fd3:	ff 75 f4             	pushl  -0xc(%ebp)
  800fd6:	e8 51 ff ff ff       	call   800f2c <fd_close>
  800fdb:	83 c4 10             	add    $0x10,%esp
}
  800fde:	c9                   	leave  
  800fdf:	c3                   	ret    

00800fe0 <close_all>:

void
close_all(void)
{
  800fe0:	55                   	push   %ebp
  800fe1:	89 e5                	mov    %esp,%ebp
  800fe3:	53                   	push   %ebx
  800fe4:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fe7:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fec:	83 ec 0c             	sub    $0xc,%esp
  800fef:	53                   	push   %ebx
  800ff0:	e8 c0 ff ff ff       	call   800fb5 <close>
	for (i = 0; i < MAXFD; i++)
  800ff5:	83 c3 01             	add    $0x1,%ebx
  800ff8:	83 c4 10             	add    $0x10,%esp
  800ffb:	83 fb 20             	cmp    $0x20,%ebx
  800ffe:	75 ec                	jne    800fec <close_all+0xc>
}
  801000:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801003:	c9                   	leave  
  801004:	c3                   	ret    

00801005 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801005:	55                   	push   %ebp
  801006:	89 e5                	mov    %esp,%ebp
  801008:	57                   	push   %edi
  801009:	56                   	push   %esi
  80100a:	53                   	push   %ebx
  80100b:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80100e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801011:	50                   	push   %eax
  801012:	ff 75 08             	pushl  0x8(%ebp)
  801015:	e8 66 fe ff ff       	call   800e80 <fd_lookup>
  80101a:	89 c3                	mov    %eax,%ebx
  80101c:	83 c4 08             	add    $0x8,%esp
  80101f:	85 c0                	test   %eax,%eax
  801021:	0f 88 81 00 00 00    	js     8010a8 <dup+0xa3>
		return r;
	close(newfdnum);
  801027:	83 ec 0c             	sub    $0xc,%esp
  80102a:	ff 75 0c             	pushl  0xc(%ebp)
  80102d:	e8 83 ff ff ff       	call   800fb5 <close>

	newfd = INDEX2FD(newfdnum);
  801032:	8b 75 0c             	mov    0xc(%ebp),%esi
  801035:	c1 e6 0c             	shl    $0xc,%esi
  801038:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80103e:	83 c4 04             	add    $0x4,%esp
  801041:	ff 75 e4             	pushl  -0x1c(%ebp)
  801044:	e8 d1 fd ff ff       	call   800e1a <fd2data>
  801049:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80104b:	89 34 24             	mov    %esi,(%esp)
  80104e:	e8 c7 fd ff ff       	call   800e1a <fd2data>
  801053:	83 c4 10             	add    $0x10,%esp
  801056:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801058:	89 d8                	mov    %ebx,%eax
  80105a:	c1 e8 16             	shr    $0x16,%eax
  80105d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801064:	a8 01                	test   $0x1,%al
  801066:	74 11                	je     801079 <dup+0x74>
  801068:	89 d8                	mov    %ebx,%eax
  80106a:	c1 e8 0c             	shr    $0xc,%eax
  80106d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801074:	f6 c2 01             	test   $0x1,%dl
  801077:	75 39                	jne    8010b2 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801079:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80107c:	89 d0                	mov    %edx,%eax
  80107e:	c1 e8 0c             	shr    $0xc,%eax
  801081:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801088:	83 ec 0c             	sub    $0xc,%esp
  80108b:	25 07 0e 00 00       	and    $0xe07,%eax
  801090:	50                   	push   %eax
  801091:	56                   	push   %esi
  801092:	6a 00                	push   $0x0
  801094:	52                   	push   %edx
  801095:	6a 00                	push   $0x0
  801097:	e8 34 fb ff ff       	call   800bd0 <sys_page_map>
  80109c:	89 c3                	mov    %eax,%ebx
  80109e:	83 c4 20             	add    $0x20,%esp
  8010a1:	85 c0                	test   %eax,%eax
  8010a3:	78 31                	js     8010d6 <dup+0xd1>
		goto err;

	return newfdnum;
  8010a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8010a8:	89 d8                	mov    %ebx,%eax
  8010aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ad:	5b                   	pop    %ebx
  8010ae:	5e                   	pop    %esi
  8010af:	5f                   	pop    %edi
  8010b0:	5d                   	pop    %ebp
  8010b1:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010b2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010b9:	83 ec 0c             	sub    $0xc,%esp
  8010bc:	25 07 0e 00 00       	and    $0xe07,%eax
  8010c1:	50                   	push   %eax
  8010c2:	57                   	push   %edi
  8010c3:	6a 00                	push   $0x0
  8010c5:	53                   	push   %ebx
  8010c6:	6a 00                	push   $0x0
  8010c8:	e8 03 fb ff ff       	call   800bd0 <sys_page_map>
  8010cd:	89 c3                	mov    %eax,%ebx
  8010cf:	83 c4 20             	add    $0x20,%esp
  8010d2:	85 c0                	test   %eax,%eax
  8010d4:	79 a3                	jns    801079 <dup+0x74>
	sys_page_unmap(0, newfd);
  8010d6:	83 ec 08             	sub    $0x8,%esp
  8010d9:	56                   	push   %esi
  8010da:	6a 00                	push   $0x0
  8010dc:	e8 31 fb ff ff       	call   800c12 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010e1:	83 c4 08             	add    $0x8,%esp
  8010e4:	57                   	push   %edi
  8010e5:	6a 00                	push   $0x0
  8010e7:	e8 26 fb ff ff       	call   800c12 <sys_page_unmap>
	return r;
  8010ec:	83 c4 10             	add    $0x10,%esp
  8010ef:	eb b7                	jmp    8010a8 <dup+0xa3>

008010f1 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010f1:	55                   	push   %ebp
  8010f2:	89 e5                	mov    %esp,%ebp
  8010f4:	53                   	push   %ebx
  8010f5:	83 ec 14             	sub    $0x14,%esp
  8010f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010fe:	50                   	push   %eax
  8010ff:	53                   	push   %ebx
  801100:	e8 7b fd ff ff       	call   800e80 <fd_lookup>
  801105:	83 c4 08             	add    $0x8,%esp
  801108:	85 c0                	test   %eax,%eax
  80110a:	78 3f                	js     80114b <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80110c:	83 ec 08             	sub    $0x8,%esp
  80110f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801112:	50                   	push   %eax
  801113:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801116:	ff 30                	pushl  (%eax)
  801118:	e8 b9 fd ff ff       	call   800ed6 <dev_lookup>
  80111d:	83 c4 10             	add    $0x10,%esp
  801120:	85 c0                	test   %eax,%eax
  801122:	78 27                	js     80114b <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801124:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801127:	8b 42 08             	mov    0x8(%edx),%eax
  80112a:	83 e0 03             	and    $0x3,%eax
  80112d:	83 f8 01             	cmp    $0x1,%eax
  801130:	74 1e                	je     801150 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801132:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801135:	8b 40 08             	mov    0x8(%eax),%eax
  801138:	85 c0                	test   %eax,%eax
  80113a:	74 35                	je     801171 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80113c:	83 ec 04             	sub    $0x4,%esp
  80113f:	ff 75 10             	pushl  0x10(%ebp)
  801142:	ff 75 0c             	pushl  0xc(%ebp)
  801145:	52                   	push   %edx
  801146:	ff d0                	call   *%eax
  801148:	83 c4 10             	add    $0x10,%esp
}
  80114b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80114e:	c9                   	leave  
  80114f:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801150:	a1 04 40 80 00       	mov    0x804004,%eax
  801155:	8b 40 48             	mov    0x48(%eax),%eax
  801158:	83 ec 04             	sub    $0x4,%esp
  80115b:	53                   	push   %ebx
  80115c:	50                   	push   %eax
  80115d:	68 51 22 80 00       	push   $0x802251
  801162:	e8 0e f0 ff ff       	call   800175 <cprintf>
		return -E_INVAL;
  801167:	83 c4 10             	add    $0x10,%esp
  80116a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80116f:	eb da                	jmp    80114b <read+0x5a>
		return -E_NOT_SUPP;
  801171:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801176:	eb d3                	jmp    80114b <read+0x5a>

00801178 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801178:	55                   	push   %ebp
  801179:	89 e5                	mov    %esp,%ebp
  80117b:	57                   	push   %edi
  80117c:	56                   	push   %esi
  80117d:	53                   	push   %ebx
  80117e:	83 ec 0c             	sub    $0xc,%esp
  801181:	8b 7d 08             	mov    0x8(%ebp),%edi
  801184:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801187:	bb 00 00 00 00       	mov    $0x0,%ebx
  80118c:	39 f3                	cmp    %esi,%ebx
  80118e:	73 25                	jae    8011b5 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801190:	83 ec 04             	sub    $0x4,%esp
  801193:	89 f0                	mov    %esi,%eax
  801195:	29 d8                	sub    %ebx,%eax
  801197:	50                   	push   %eax
  801198:	89 d8                	mov    %ebx,%eax
  80119a:	03 45 0c             	add    0xc(%ebp),%eax
  80119d:	50                   	push   %eax
  80119e:	57                   	push   %edi
  80119f:	e8 4d ff ff ff       	call   8010f1 <read>
		if (m < 0)
  8011a4:	83 c4 10             	add    $0x10,%esp
  8011a7:	85 c0                	test   %eax,%eax
  8011a9:	78 08                	js     8011b3 <readn+0x3b>
			return m;
		if (m == 0)
  8011ab:	85 c0                	test   %eax,%eax
  8011ad:	74 06                	je     8011b5 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  8011af:	01 c3                	add    %eax,%ebx
  8011b1:	eb d9                	jmp    80118c <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011b3:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8011b5:	89 d8                	mov    %ebx,%eax
  8011b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ba:	5b                   	pop    %ebx
  8011bb:	5e                   	pop    %esi
  8011bc:	5f                   	pop    %edi
  8011bd:	5d                   	pop    %ebp
  8011be:	c3                   	ret    

008011bf <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011bf:	55                   	push   %ebp
  8011c0:	89 e5                	mov    %esp,%ebp
  8011c2:	53                   	push   %ebx
  8011c3:	83 ec 14             	sub    $0x14,%esp
  8011c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011cc:	50                   	push   %eax
  8011cd:	53                   	push   %ebx
  8011ce:	e8 ad fc ff ff       	call   800e80 <fd_lookup>
  8011d3:	83 c4 08             	add    $0x8,%esp
  8011d6:	85 c0                	test   %eax,%eax
  8011d8:	78 3a                	js     801214 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011da:	83 ec 08             	sub    $0x8,%esp
  8011dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e0:	50                   	push   %eax
  8011e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e4:	ff 30                	pushl  (%eax)
  8011e6:	e8 eb fc ff ff       	call   800ed6 <dev_lookup>
  8011eb:	83 c4 10             	add    $0x10,%esp
  8011ee:	85 c0                	test   %eax,%eax
  8011f0:	78 22                	js     801214 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011f5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011f9:	74 1e                	je     801219 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011fe:	8b 52 0c             	mov    0xc(%edx),%edx
  801201:	85 d2                	test   %edx,%edx
  801203:	74 35                	je     80123a <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801205:	83 ec 04             	sub    $0x4,%esp
  801208:	ff 75 10             	pushl  0x10(%ebp)
  80120b:	ff 75 0c             	pushl  0xc(%ebp)
  80120e:	50                   	push   %eax
  80120f:	ff d2                	call   *%edx
  801211:	83 c4 10             	add    $0x10,%esp
}
  801214:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801217:	c9                   	leave  
  801218:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801219:	a1 04 40 80 00       	mov    0x804004,%eax
  80121e:	8b 40 48             	mov    0x48(%eax),%eax
  801221:	83 ec 04             	sub    $0x4,%esp
  801224:	53                   	push   %ebx
  801225:	50                   	push   %eax
  801226:	68 6d 22 80 00       	push   $0x80226d
  80122b:	e8 45 ef ff ff       	call   800175 <cprintf>
		return -E_INVAL;
  801230:	83 c4 10             	add    $0x10,%esp
  801233:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801238:	eb da                	jmp    801214 <write+0x55>
		return -E_NOT_SUPP;
  80123a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80123f:	eb d3                	jmp    801214 <write+0x55>

00801241 <seek>:

int
seek(int fdnum, off_t offset)
{
  801241:	55                   	push   %ebp
  801242:	89 e5                	mov    %esp,%ebp
  801244:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801247:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80124a:	50                   	push   %eax
  80124b:	ff 75 08             	pushl  0x8(%ebp)
  80124e:	e8 2d fc ff ff       	call   800e80 <fd_lookup>
  801253:	83 c4 08             	add    $0x8,%esp
  801256:	85 c0                	test   %eax,%eax
  801258:	78 0e                	js     801268 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80125a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80125d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801260:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801263:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801268:	c9                   	leave  
  801269:	c3                   	ret    

0080126a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80126a:	55                   	push   %ebp
  80126b:	89 e5                	mov    %esp,%ebp
  80126d:	53                   	push   %ebx
  80126e:	83 ec 14             	sub    $0x14,%esp
  801271:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801274:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801277:	50                   	push   %eax
  801278:	53                   	push   %ebx
  801279:	e8 02 fc ff ff       	call   800e80 <fd_lookup>
  80127e:	83 c4 08             	add    $0x8,%esp
  801281:	85 c0                	test   %eax,%eax
  801283:	78 37                	js     8012bc <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801285:	83 ec 08             	sub    $0x8,%esp
  801288:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80128b:	50                   	push   %eax
  80128c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80128f:	ff 30                	pushl  (%eax)
  801291:	e8 40 fc ff ff       	call   800ed6 <dev_lookup>
  801296:	83 c4 10             	add    $0x10,%esp
  801299:	85 c0                	test   %eax,%eax
  80129b:	78 1f                	js     8012bc <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80129d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012a4:	74 1b                	je     8012c1 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8012a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012a9:	8b 52 18             	mov    0x18(%edx),%edx
  8012ac:	85 d2                	test   %edx,%edx
  8012ae:	74 32                	je     8012e2 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012b0:	83 ec 08             	sub    $0x8,%esp
  8012b3:	ff 75 0c             	pushl  0xc(%ebp)
  8012b6:	50                   	push   %eax
  8012b7:	ff d2                	call   *%edx
  8012b9:	83 c4 10             	add    $0x10,%esp
}
  8012bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012bf:	c9                   	leave  
  8012c0:	c3                   	ret    
			thisenv->env_id, fdnum);
  8012c1:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012c6:	8b 40 48             	mov    0x48(%eax),%eax
  8012c9:	83 ec 04             	sub    $0x4,%esp
  8012cc:	53                   	push   %ebx
  8012cd:	50                   	push   %eax
  8012ce:	68 30 22 80 00       	push   $0x802230
  8012d3:	e8 9d ee ff ff       	call   800175 <cprintf>
		return -E_INVAL;
  8012d8:	83 c4 10             	add    $0x10,%esp
  8012db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012e0:	eb da                	jmp    8012bc <ftruncate+0x52>
		return -E_NOT_SUPP;
  8012e2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012e7:	eb d3                	jmp    8012bc <ftruncate+0x52>

008012e9 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012e9:	55                   	push   %ebp
  8012ea:	89 e5                	mov    %esp,%ebp
  8012ec:	53                   	push   %ebx
  8012ed:	83 ec 14             	sub    $0x14,%esp
  8012f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012f6:	50                   	push   %eax
  8012f7:	ff 75 08             	pushl  0x8(%ebp)
  8012fa:	e8 81 fb ff ff       	call   800e80 <fd_lookup>
  8012ff:	83 c4 08             	add    $0x8,%esp
  801302:	85 c0                	test   %eax,%eax
  801304:	78 4b                	js     801351 <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801306:	83 ec 08             	sub    $0x8,%esp
  801309:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80130c:	50                   	push   %eax
  80130d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801310:	ff 30                	pushl  (%eax)
  801312:	e8 bf fb ff ff       	call   800ed6 <dev_lookup>
  801317:	83 c4 10             	add    $0x10,%esp
  80131a:	85 c0                	test   %eax,%eax
  80131c:	78 33                	js     801351 <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  80131e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801321:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801325:	74 2f                	je     801356 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801327:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80132a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801331:	00 00 00 
	stat->st_isdir = 0;
  801334:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80133b:	00 00 00 
	stat->st_dev = dev;
  80133e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801344:	83 ec 08             	sub    $0x8,%esp
  801347:	53                   	push   %ebx
  801348:	ff 75 f0             	pushl  -0x10(%ebp)
  80134b:	ff 50 14             	call   *0x14(%eax)
  80134e:	83 c4 10             	add    $0x10,%esp
}
  801351:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801354:	c9                   	leave  
  801355:	c3                   	ret    
		return -E_NOT_SUPP;
  801356:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80135b:	eb f4                	jmp    801351 <fstat+0x68>

0080135d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80135d:	55                   	push   %ebp
  80135e:	89 e5                	mov    %esp,%ebp
  801360:	56                   	push   %esi
  801361:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801362:	83 ec 08             	sub    $0x8,%esp
  801365:	6a 00                	push   $0x0
  801367:	ff 75 08             	pushl  0x8(%ebp)
  80136a:	e8 e7 01 00 00       	call   801556 <open>
  80136f:	89 c3                	mov    %eax,%ebx
  801371:	83 c4 10             	add    $0x10,%esp
  801374:	85 c0                	test   %eax,%eax
  801376:	78 1b                	js     801393 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801378:	83 ec 08             	sub    $0x8,%esp
  80137b:	ff 75 0c             	pushl  0xc(%ebp)
  80137e:	50                   	push   %eax
  80137f:	e8 65 ff ff ff       	call   8012e9 <fstat>
  801384:	89 c6                	mov    %eax,%esi
	close(fd);
  801386:	89 1c 24             	mov    %ebx,(%esp)
  801389:	e8 27 fc ff ff       	call   800fb5 <close>
	return r;
  80138e:	83 c4 10             	add    $0x10,%esp
  801391:	89 f3                	mov    %esi,%ebx
}
  801393:	89 d8                	mov    %ebx,%eax
  801395:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801398:	5b                   	pop    %ebx
  801399:	5e                   	pop    %esi
  80139a:	5d                   	pop    %ebp
  80139b:	c3                   	ret    

0080139c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80139c:	55                   	push   %ebp
  80139d:	89 e5                	mov    %esp,%ebp
  80139f:	56                   	push   %esi
  8013a0:	53                   	push   %ebx
  8013a1:	89 c6                	mov    %eax,%esi
  8013a3:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013a5:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013ac:	74 27                	je     8013d5 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013ae:	6a 07                	push   $0x7
  8013b0:	68 00 50 80 00       	push   $0x805000
  8013b5:	56                   	push   %esi
  8013b6:	ff 35 00 40 80 00    	pushl  0x804000
  8013bc:	e8 bf 07 00 00       	call   801b80 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013c1:	83 c4 0c             	add    $0xc,%esp
  8013c4:	6a 00                	push   $0x0
  8013c6:	53                   	push   %ebx
  8013c7:	6a 00                	push   $0x0
  8013c9:	e8 3d 07 00 00       	call   801b0b <ipc_recv>
}
  8013ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013d1:	5b                   	pop    %ebx
  8013d2:	5e                   	pop    %esi
  8013d3:	5d                   	pop    %ebp
  8013d4:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013d5:	83 ec 0c             	sub    $0xc,%esp
  8013d8:	6a 01                	push   $0x1
  8013da:	e8 f7 07 00 00       	call   801bd6 <ipc_find_env>
  8013df:	a3 00 40 80 00       	mov    %eax,0x804000
  8013e4:	83 c4 10             	add    $0x10,%esp
  8013e7:	eb c5                	jmp    8013ae <fsipc+0x12>

008013e9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013e9:	55                   	push   %ebp
  8013ea:	89 e5                	mov    %esp,%ebp
  8013ec:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f2:	8b 40 0c             	mov    0xc(%eax),%eax
  8013f5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013fd:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801402:	ba 00 00 00 00       	mov    $0x0,%edx
  801407:	b8 02 00 00 00       	mov    $0x2,%eax
  80140c:	e8 8b ff ff ff       	call   80139c <fsipc>
}
  801411:	c9                   	leave  
  801412:	c3                   	ret    

00801413 <devfile_flush>:
{
  801413:	55                   	push   %ebp
  801414:	89 e5                	mov    %esp,%ebp
  801416:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801419:	8b 45 08             	mov    0x8(%ebp),%eax
  80141c:	8b 40 0c             	mov    0xc(%eax),%eax
  80141f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801424:	ba 00 00 00 00       	mov    $0x0,%edx
  801429:	b8 06 00 00 00       	mov    $0x6,%eax
  80142e:	e8 69 ff ff ff       	call   80139c <fsipc>
}
  801433:	c9                   	leave  
  801434:	c3                   	ret    

00801435 <devfile_stat>:
{
  801435:	55                   	push   %ebp
  801436:	89 e5                	mov    %esp,%ebp
  801438:	53                   	push   %ebx
  801439:	83 ec 04             	sub    $0x4,%esp
  80143c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80143f:	8b 45 08             	mov    0x8(%ebp),%eax
  801442:	8b 40 0c             	mov    0xc(%eax),%eax
  801445:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80144a:	ba 00 00 00 00       	mov    $0x0,%edx
  80144f:	b8 05 00 00 00       	mov    $0x5,%eax
  801454:	e8 43 ff ff ff       	call   80139c <fsipc>
  801459:	85 c0                	test   %eax,%eax
  80145b:	78 2c                	js     801489 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80145d:	83 ec 08             	sub    $0x8,%esp
  801460:	68 00 50 80 00       	push   $0x805000
  801465:	53                   	push   %ebx
  801466:	e8 29 f3 ff ff       	call   800794 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80146b:	a1 80 50 80 00       	mov    0x805080,%eax
  801470:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801476:	a1 84 50 80 00       	mov    0x805084,%eax
  80147b:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801481:	83 c4 10             	add    $0x10,%esp
  801484:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801489:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80148c:	c9                   	leave  
  80148d:	c3                   	ret    

0080148e <devfile_write>:
{
  80148e:	55                   	push   %ebp
  80148f:	89 e5                	mov    %esp,%ebp
  801491:	83 ec 0c             	sub    $0xc,%esp
  801494:	8b 45 10             	mov    0x10(%ebp),%eax
  801497:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80149c:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8014a1:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8014a7:	8b 52 0c             	mov    0xc(%edx),%edx
  8014aa:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8014b0:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf,buf,n);
  8014b5:	50                   	push   %eax
  8014b6:	ff 75 0c             	pushl  0xc(%ebp)
  8014b9:	68 08 50 80 00       	push   $0x805008
  8014be:	e8 5f f4 ff ff       	call   800922 <memmove>
	if((r = fsipc(FSREQ_WRITE,NULL))<0)
  8014c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c8:	b8 04 00 00 00       	mov    $0x4,%eax
  8014cd:	e8 ca fe ff ff       	call   80139c <fsipc>
}
  8014d2:	c9                   	leave  
  8014d3:	c3                   	ret    

008014d4 <devfile_read>:
{
  8014d4:	55                   	push   %ebp
  8014d5:	89 e5                	mov    %esp,%ebp
  8014d7:	56                   	push   %esi
  8014d8:	53                   	push   %ebx
  8014d9:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8014df:	8b 40 0c             	mov    0xc(%eax),%eax
  8014e2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014e7:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f2:	b8 03 00 00 00       	mov    $0x3,%eax
  8014f7:	e8 a0 fe ff ff       	call   80139c <fsipc>
  8014fc:	89 c3                	mov    %eax,%ebx
  8014fe:	85 c0                	test   %eax,%eax
  801500:	78 1f                	js     801521 <devfile_read+0x4d>
	assert(r <= n);
  801502:	39 f0                	cmp    %esi,%eax
  801504:	77 24                	ja     80152a <devfile_read+0x56>
	assert(r <= PGSIZE);
  801506:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80150b:	7f 33                	jg     801540 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80150d:	83 ec 04             	sub    $0x4,%esp
  801510:	50                   	push   %eax
  801511:	68 00 50 80 00       	push   $0x805000
  801516:	ff 75 0c             	pushl  0xc(%ebp)
  801519:	e8 04 f4 ff ff       	call   800922 <memmove>
	return r;
  80151e:	83 c4 10             	add    $0x10,%esp
}
  801521:	89 d8                	mov    %ebx,%eax
  801523:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801526:	5b                   	pop    %ebx
  801527:	5e                   	pop    %esi
  801528:	5d                   	pop    %ebp
  801529:	c3                   	ret    
	assert(r <= n);
  80152a:	68 9c 22 80 00       	push   $0x80229c
  80152f:	68 a3 22 80 00       	push   $0x8022a3
  801534:	6a 7c                	push   $0x7c
  801536:	68 b8 22 80 00       	push   $0x8022b8
  80153b:	e8 85 05 00 00       	call   801ac5 <_panic>
	assert(r <= PGSIZE);
  801540:	68 c3 22 80 00       	push   $0x8022c3
  801545:	68 a3 22 80 00       	push   $0x8022a3
  80154a:	6a 7d                	push   $0x7d
  80154c:	68 b8 22 80 00       	push   $0x8022b8
  801551:	e8 6f 05 00 00       	call   801ac5 <_panic>

00801556 <open>:
{
  801556:	55                   	push   %ebp
  801557:	89 e5                	mov    %esp,%ebp
  801559:	56                   	push   %esi
  80155a:	53                   	push   %ebx
  80155b:	83 ec 1c             	sub    $0x1c,%esp
  80155e:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801561:	56                   	push   %esi
  801562:	e8 f6 f1 ff ff       	call   80075d <strlen>
  801567:	83 c4 10             	add    $0x10,%esp
  80156a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80156f:	7f 6c                	jg     8015dd <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801571:	83 ec 0c             	sub    $0xc,%esp
  801574:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801577:	50                   	push   %eax
  801578:	e8 b4 f8 ff ff       	call   800e31 <fd_alloc>
  80157d:	89 c3                	mov    %eax,%ebx
  80157f:	83 c4 10             	add    $0x10,%esp
  801582:	85 c0                	test   %eax,%eax
  801584:	78 3c                	js     8015c2 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801586:	83 ec 08             	sub    $0x8,%esp
  801589:	56                   	push   %esi
  80158a:	68 00 50 80 00       	push   $0x805000
  80158f:	e8 00 f2 ff ff       	call   800794 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801594:	8b 45 0c             	mov    0xc(%ebp),%eax
  801597:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80159c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80159f:	b8 01 00 00 00       	mov    $0x1,%eax
  8015a4:	e8 f3 fd ff ff       	call   80139c <fsipc>
  8015a9:	89 c3                	mov    %eax,%ebx
  8015ab:	83 c4 10             	add    $0x10,%esp
  8015ae:	85 c0                	test   %eax,%eax
  8015b0:	78 19                	js     8015cb <open+0x75>
	return fd2num(fd);
  8015b2:	83 ec 0c             	sub    $0xc,%esp
  8015b5:	ff 75 f4             	pushl  -0xc(%ebp)
  8015b8:	e8 4d f8 ff ff       	call   800e0a <fd2num>
  8015bd:	89 c3                	mov    %eax,%ebx
  8015bf:	83 c4 10             	add    $0x10,%esp
}
  8015c2:	89 d8                	mov    %ebx,%eax
  8015c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015c7:	5b                   	pop    %ebx
  8015c8:	5e                   	pop    %esi
  8015c9:	5d                   	pop    %ebp
  8015ca:	c3                   	ret    
		fd_close(fd, 0);
  8015cb:	83 ec 08             	sub    $0x8,%esp
  8015ce:	6a 00                	push   $0x0
  8015d0:	ff 75 f4             	pushl  -0xc(%ebp)
  8015d3:	e8 54 f9 ff ff       	call   800f2c <fd_close>
		return r;
  8015d8:	83 c4 10             	add    $0x10,%esp
  8015db:	eb e5                	jmp    8015c2 <open+0x6c>
		return -E_BAD_PATH;
  8015dd:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8015e2:	eb de                	jmp    8015c2 <open+0x6c>

008015e4 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015e4:	55                   	push   %ebp
  8015e5:	89 e5                	mov    %esp,%ebp
  8015e7:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ef:	b8 08 00 00 00       	mov    $0x8,%eax
  8015f4:	e8 a3 fd ff ff       	call   80139c <fsipc>
}
  8015f9:	c9                   	leave  
  8015fa:	c3                   	ret    

008015fb <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8015fb:	55                   	push   %ebp
  8015fc:	89 e5                	mov    %esp,%ebp
  8015fe:	56                   	push   %esi
  8015ff:	53                   	push   %ebx
  801600:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801603:	83 ec 0c             	sub    $0xc,%esp
  801606:	ff 75 08             	pushl  0x8(%ebp)
  801609:	e8 0c f8 ff ff       	call   800e1a <fd2data>
  80160e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801610:	83 c4 08             	add    $0x8,%esp
  801613:	68 cf 22 80 00       	push   $0x8022cf
  801618:	53                   	push   %ebx
  801619:	e8 76 f1 ff ff       	call   800794 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80161e:	8b 46 04             	mov    0x4(%esi),%eax
  801621:	2b 06                	sub    (%esi),%eax
  801623:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801629:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801630:	00 00 00 
	stat->st_dev = &devpipe;
  801633:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80163a:	30 80 00 
	return 0;
}
  80163d:	b8 00 00 00 00       	mov    $0x0,%eax
  801642:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801645:	5b                   	pop    %ebx
  801646:	5e                   	pop    %esi
  801647:	5d                   	pop    %ebp
  801648:	c3                   	ret    

00801649 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801649:	55                   	push   %ebp
  80164a:	89 e5                	mov    %esp,%ebp
  80164c:	53                   	push   %ebx
  80164d:	83 ec 0c             	sub    $0xc,%esp
  801650:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801653:	53                   	push   %ebx
  801654:	6a 00                	push   $0x0
  801656:	e8 b7 f5 ff ff       	call   800c12 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80165b:	89 1c 24             	mov    %ebx,(%esp)
  80165e:	e8 b7 f7 ff ff       	call   800e1a <fd2data>
  801663:	83 c4 08             	add    $0x8,%esp
  801666:	50                   	push   %eax
  801667:	6a 00                	push   $0x0
  801669:	e8 a4 f5 ff ff       	call   800c12 <sys_page_unmap>
}
  80166e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801671:	c9                   	leave  
  801672:	c3                   	ret    

00801673 <_pipeisclosed>:
{
  801673:	55                   	push   %ebp
  801674:	89 e5                	mov    %esp,%ebp
  801676:	57                   	push   %edi
  801677:	56                   	push   %esi
  801678:	53                   	push   %ebx
  801679:	83 ec 1c             	sub    $0x1c,%esp
  80167c:	89 c7                	mov    %eax,%edi
  80167e:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801680:	a1 04 40 80 00       	mov    0x804004,%eax
  801685:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801688:	83 ec 0c             	sub    $0xc,%esp
  80168b:	57                   	push   %edi
  80168c:	e8 7e 05 00 00       	call   801c0f <pageref>
  801691:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801694:	89 34 24             	mov    %esi,(%esp)
  801697:	e8 73 05 00 00       	call   801c0f <pageref>
		nn = thisenv->env_runs;
  80169c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8016a2:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8016a5:	83 c4 10             	add    $0x10,%esp
  8016a8:	39 cb                	cmp    %ecx,%ebx
  8016aa:	74 1b                	je     8016c7 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8016ac:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8016af:	75 cf                	jne    801680 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8016b1:	8b 42 58             	mov    0x58(%edx),%eax
  8016b4:	6a 01                	push   $0x1
  8016b6:	50                   	push   %eax
  8016b7:	53                   	push   %ebx
  8016b8:	68 d6 22 80 00       	push   $0x8022d6
  8016bd:	e8 b3 ea ff ff       	call   800175 <cprintf>
  8016c2:	83 c4 10             	add    $0x10,%esp
  8016c5:	eb b9                	jmp    801680 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8016c7:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8016ca:	0f 94 c0             	sete   %al
  8016cd:	0f b6 c0             	movzbl %al,%eax
}
  8016d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016d3:	5b                   	pop    %ebx
  8016d4:	5e                   	pop    %esi
  8016d5:	5f                   	pop    %edi
  8016d6:	5d                   	pop    %ebp
  8016d7:	c3                   	ret    

008016d8 <devpipe_write>:
{
  8016d8:	55                   	push   %ebp
  8016d9:	89 e5                	mov    %esp,%ebp
  8016db:	57                   	push   %edi
  8016dc:	56                   	push   %esi
  8016dd:	53                   	push   %ebx
  8016de:	83 ec 28             	sub    $0x28,%esp
  8016e1:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8016e4:	56                   	push   %esi
  8016e5:	e8 30 f7 ff ff       	call   800e1a <fd2data>
  8016ea:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8016ec:	83 c4 10             	add    $0x10,%esp
  8016ef:	bf 00 00 00 00       	mov    $0x0,%edi
  8016f4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8016f7:	74 4f                	je     801748 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8016f9:	8b 43 04             	mov    0x4(%ebx),%eax
  8016fc:	8b 0b                	mov    (%ebx),%ecx
  8016fe:	8d 51 20             	lea    0x20(%ecx),%edx
  801701:	39 d0                	cmp    %edx,%eax
  801703:	72 14                	jb     801719 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801705:	89 da                	mov    %ebx,%edx
  801707:	89 f0                	mov    %esi,%eax
  801709:	e8 65 ff ff ff       	call   801673 <_pipeisclosed>
  80170e:	85 c0                	test   %eax,%eax
  801710:	75 3a                	jne    80174c <devpipe_write+0x74>
			sys_yield();
  801712:	e8 57 f4 ff ff       	call   800b6e <sys_yield>
  801717:	eb e0                	jmp    8016f9 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801719:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80171c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801720:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801723:	89 c2                	mov    %eax,%edx
  801725:	c1 fa 1f             	sar    $0x1f,%edx
  801728:	89 d1                	mov    %edx,%ecx
  80172a:	c1 e9 1b             	shr    $0x1b,%ecx
  80172d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801730:	83 e2 1f             	and    $0x1f,%edx
  801733:	29 ca                	sub    %ecx,%edx
  801735:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801739:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80173d:	83 c0 01             	add    $0x1,%eax
  801740:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801743:	83 c7 01             	add    $0x1,%edi
  801746:	eb ac                	jmp    8016f4 <devpipe_write+0x1c>
	return i;
  801748:	89 f8                	mov    %edi,%eax
  80174a:	eb 05                	jmp    801751 <devpipe_write+0x79>
				return 0;
  80174c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801751:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801754:	5b                   	pop    %ebx
  801755:	5e                   	pop    %esi
  801756:	5f                   	pop    %edi
  801757:	5d                   	pop    %ebp
  801758:	c3                   	ret    

00801759 <devpipe_read>:
{
  801759:	55                   	push   %ebp
  80175a:	89 e5                	mov    %esp,%ebp
  80175c:	57                   	push   %edi
  80175d:	56                   	push   %esi
  80175e:	53                   	push   %ebx
  80175f:	83 ec 18             	sub    $0x18,%esp
  801762:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801765:	57                   	push   %edi
  801766:	e8 af f6 ff ff       	call   800e1a <fd2data>
  80176b:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80176d:	83 c4 10             	add    $0x10,%esp
  801770:	be 00 00 00 00       	mov    $0x0,%esi
  801775:	3b 75 10             	cmp    0x10(%ebp),%esi
  801778:	74 47                	je     8017c1 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  80177a:	8b 03                	mov    (%ebx),%eax
  80177c:	3b 43 04             	cmp    0x4(%ebx),%eax
  80177f:	75 22                	jne    8017a3 <devpipe_read+0x4a>
			if (i > 0)
  801781:	85 f6                	test   %esi,%esi
  801783:	75 14                	jne    801799 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801785:	89 da                	mov    %ebx,%edx
  801787:	89 f8                	mov    %edi,%eax
  801789:	e8 e5 fe ff ff       	call   801673 <_pipeisclosed>
  80178e:	85 c0                	test   %eax,%eax
  801790:	75 33                	jne    8017c5 <devpipe_read+0x6c>
			sys_yield();
  801792:	e8 d7 f3 ff ff       	call   800b6e <sys_yield>
  801797:	eb e1                	jmp    80177a <devpipe_read+0x21>
				return i;
  801799:	89 f0                	mov    %esi,%eax
}
  80179b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80179e:	5b                   	pop    %ebx
  80179f:	5e                   	pop    %esi
  8017a0:	5f                   	pop    %edi
  8017a1:	5d                   	pop    %ebp
  8017a2:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017a3:	99                   	cltd   
  8017a4:	c1 ea 1b             	shr    $0x1b,%edx
  8017a7:	01 d0                	add    %edx,%eax
  8017a9:	83 e0 1f             	and    $0x1f,%eax
  8017ac:	29 d0                	sub    %edx,%eax
  8017ae:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8017b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017b6:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8017b9:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8017bc:	83 c6 01             	add    $0x1,%esi
  8017bf:	eb b4                	jmp    801775 <devpipe_read+0x1c>
	return i;
  8017c1:	89 f0                	mov    %esi,%eax
  8017c3:	eb d6                	jmp    80179b <devpipe_read+0x42>
				return 0;
  8017c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8017ca:	eb cf                	jmp    80179b <devpipe_read+0x42>

008017cc <pipe>:
{
  8017cc:	55                   	push   %ebp
  8017cd:	89 e5                	mov    %esp,%ebp
  8017cf:	56                   	push   %esi
  8017d0:	53                   	push   %ebx
  8017d1:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8017d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017d7:	50                   	push   %eax
  8017d8:	e8 54 f6 ff ff       	call   800e31 <fd_alloc>
  8017dd:	89 c3                	mov    %eax,%ebx
  8017df:	83 c4 10             	add    $0x10,%esp
  8017e2:	85 c0                	test   %eax,%eax
  8017e4:	78 5b                	js     801841 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017e6:	83 ec 04             	sub    $0x4,%esp
  8017e9:	68 07 04 00 00       	push   $0x407
  8017ee:	ff 75 f4             	pushl  -0xc(%ebp)
  8017f1:	6a 00                	push   $0x0
  8017f3:	e8 95 f3 ff ff       	call   800b8d <sys_page_alloc>
  8017f8:	89 c3                	mov    %eax,%ebx
  8017fa:	83 c4 10             	add    $0x10,%esp
  8017fd:	85 c0                	test   %eax,%eax
  8017ff:	78 40                	js     801841 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  801801:	83 ec 0c             	sub    $0xc,%esp
  801804:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801807:	50                   	push   %eax
  801808:	e8 24 f6 ff ff       	call   800e31 <fd_alloc>
  80180d:	89 c3                	mov    %eax,%ebx
  80180f:	83 c4 10             	add    $0x10,%esp
  801812:	85 c0                	test   %eax,%eax
  801814:	78 1b                	js     801831 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801816:	83 ec 04             	sub    $0x4,%esp
  801819:	68 07 04 00 00       	push   $0x407
  80181e:	ff 75 f0             	pushl  -0x10(%ebp)
  801821:	6a 00                	push   $0x0
  801823:	e8 65 f3 ff ff       	call   800b8d <sys_page_alloc>
  801828:	89 c3                	mov    %eax,%ebx
  80182a:	83 c4 10             	add    $0x10,%esp
  80182d:	85 c0                	test   %eax,%eax
  80182f:	79 19                	jns    80184a <pipe+0x7e>
	sys_page_unmap(0, fd0);
  801831:	83 ec 08             	sub    $0x8,%esp
  801834:	ff 75 f4             	pushl  -0xc(%ebp)
  801837:	6a 00                	push   $0x0
  801839:	e8 d4 f3 ff ff       	call   800c12 <sys_page_unmap>
  80183e:	83 c4 10             	add    $0x10,%esp
}
  801841:	89 d8                	mov    %ebx,%eax
  801843:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801846:	5b                   	pop    %ebx
  801847:	5e                   	pop    %esi
  801848:	5d                   	pop    %ebp
  801849:	c3                   	ret    
	va = fd2data(fd0);
  80184a:	83 ec 0c             	sub    $0xc,%esp
  80184d:	ff 75 f4             	pushl  -0xc(%ebp)
  801850:	e8 c5 f5 ff ff       	call   800e1a <fd2data>
  801855:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801857:	83 c4 0c             	add    $0xc,%esp
  80185a:	68 07 04 00 00       	push   $0x407
  80185f:	50                   	push   %eax
  801860:	6a 00                	push   $0x0
  801862:	e8 26 f3 ff ff       	call   800b8d <sys_page_alloc>
  801867:	89 c3                	mov    %eax,%ebx
  801869:	83 c4 10             	add    $0x10,%esp
  80186c:	85 c0                	test   %eax,%eax
  80186e:	0f 88 8c 00 00 00    	js     801900 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801874:	83 ec 0c             	sub    $0xc,%esp
  801877:	ff 75 f0             	pushl  -0x10(%ebp)
  80187a:	e8 9b f5 ff ff       	call   800e1a <fd2data>
  80187f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801886:	50                   	push   %eax
  801887:	6a 00                	push   $0x0
  801889:	56                   	push   %esi
  80188a:	6a 00                	push   $0x0
  80188c:	e8 3f f3 ff ff       	call   800bd0 <sys_page_map>
  801891:	89 c3                	mov    %eax,%ebx
  801893:	83 c4 20             	add    $0x20,%esp
  801896:	85 c0                	test   %eax,%eax
  801898:	78 58                	js     8018f2 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  80189a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80189d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018a3:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8018a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018a8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  8018af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018b2:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018b8:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8018ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018bd:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8018c4:	83 ec 0c             	sub    $0xc,%esp
  8018c7:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ca:	e8 3b f5 ff ff       	call   800e0a <fd2num>
  8018cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018d2:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8018d4:	83 c4 04             	add    $0x4,%esp
  8018d7:	ff 75 f0             	pushl  -0x10(%ebp)
  8018da:	e8 2b f5 ff ff       	call   800e0a <fd2num>
  8018df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018e2:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8018e5:	83 c4 10             	add    $0x10,%esp
  8018e8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018ed:	e9 4f ff ff ff       	jmp    801841 <pipe+0x75>
	sys_page_unmap(0, va);
  8018f2:	83 ec 08             	sub    $0x8,%esp
  8018f5:	56                   	push   %esi
  8018f6:	6a 00                	push   $0x0
  8018f8:	e8 15 f3 ff ff       	call   800c12 <sys_page_unmap>
  8018fd:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801900:	83 ec 08             	sub    $0x8,%esp
  801903:	ff 75 f0             	pushl  -0x10(%ebp)
  801906:	6a 00                	push   $0x0
  801908:	e8 05 f3 ff ff       	call   800c12 <sys_page_unmap>
  80190d:	83 c4 10             	add    $0x10,%esp
  801910:	e9 1c ff ff ff       	jmp    801831 <pipe+0x65>

00801915 <pipeisclosed>:
{
  801915:	55                   	push   %ebp
  801916:	89 e5                	mov    %esp,%ebp
  801918:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80191b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80191e:	50                   	push   %eax
  80191f:	ff 75 08             	pushl  0x8(%ebp)
  801922:	e8 59 f5 ff ff       	call   800e80 <fd_lookup>
  801927:	83 c4 10             	add    $0x10,%esp
  80192a:	85 c0                	test   %eax,%eax
  80192c:	78 18                	js     801946 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  80192e:	83 ec 0c             	sub    $0xc,%esp
  801931:	ff 75 f4             	pushl  -0xc(%ebp)
  801934:	e8 e1 f4 ff ff       	call   800e1a <fd2data>
	return _pipeisclosed(fd, p);
  801939:	89 c2                	mov    %eax,%edx
  80193b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80193e:	e8 30 fd ff ff       	call   801673 <_pipeisclosed>
  801943:	83 c4 10             	add    $0x10,%esp
}
  801946:	c9                   	leave  
  801947:	c3                   	ret    

00801948 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801948:	55                   	push   %ebp
  801949:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80194b:	b8 00 00 00 00       	mov    $0x0,%eax
  801950:	5d                   	pop    %ebp
  801951:	c3                   	ret    

00801952 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801952:	55                   	push   %ebp
  801953:	89 e5                	mov    %esp,%ebp
  801955:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801958:	68 ee 22 80 00       	push   $0x8022ee
  80195d:	ff 75 0c             	pushl  0xc(%ebp)
  801960:	e8 2f ee ff ff       	call   800794 <strcpy>
	return 0;
}
  801965:	b8 00 00 00 00       	mov    $0x0,%eax
  80196a:	c9                   	leave  
  80196b:	c3                   	ret    

0080196c <devcons_write>:
{
  80196c:	55                   	push   %ebp
  80196d:	89 e5                	mov    %esp,%ebp
  80196f:	57                   	push   %edi
  801970:	56                   	push   %esi
  801971:	53                   	push   %ebx
  801972:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801978:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80197d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801983:	eb 2f                	jmp    8019b4 <devcons_write+0x48>
		m = n - tot;
  801985:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801988:	29 f3                	sub    %esi,%ebx
  80198a:	83 fb 7f             	cmp    $0x7f,%ebx
  80198d:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801992:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801995:	83 ec 04             	sub    $0x4,%esp
  801998:	53                   	push   %ebx
  801999:	89 f0                	mov    %esi,%eax
  80199b:	03 45 0c             	add    0xc(%ebp),%eax
  80199e:	50                   	push   %eax
  80199f:	57                   	push   %edi
  8019a0:	e8 7d ef ff ff       	call   800922 <memmove>
		sys_cputs(buf, m);
  8019a5:	83 c4 08             	add    $0x8,%esp
  8019a8:	53                   	push   %ebx
  8019a9:	57                   	push   %edi
  8019aa:	e8 22 f1 ff ff       	call   800ad1 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8019af:	01 de                	add    %ebx,%esi
  8019b1:	83 c4 10             	add    $0x10,%esp
  8019b4:	3b 75 10             	cmp    0x10(%ebp),%esi
  8019b7:	72 cc                	jb     801985 <devcons_write+0x19>
}
  8019b9:	89 f0                	mov    %esi,%eax
  8019bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019be:	5b                   	pop    %ebx
  8019bf:	5e                   	pop    %esi
  8019c0:	5f                   	pop    %edi
  8019c1:	5d                   	pop    %ebp
  8019c2:	c3                   	ret    

008019c3 <devcons_read>:
{
  8019c3:	55                   	push   %ebp
  8019c4:	89 e5                	mov    %esp,%ebp
  8019c6:	83 ec 08             	sub    $0x8,%esp
  8019c9:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8019ce:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019d2:	75 07                	jne    8019db <devcons_read+0x18>
}
  8019d4:	c9                   	leave  
  8019d5:	c3                   	ret    
		sys_yield();
  8019d6:	e8 93 f1 ff ff       	call   800b6e <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8019db:	e8 0f f1 ff ff       	call   800aef <sys_cgetc>
  8019e0:	85 c0                	test   %eax,%eax
  8019e2:	74 f2                	je     8019d6 <devcons_read+0x13>
	if (c < 0)
  8019e4:	85 c0                	test   %eax,%eax
  8019e6:	78 ec                	js     8019d4 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  8019e8:	83 f8 04             	cmp    $0x4,%eax
  8019eb:	74 0c                	je     8019f9 <devcons_read+0x36>
	*(char*)vbuf = c;
  8019ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019f0:	88 02                	mov    %al,(%edx)
	return 1;
  8019f2:	b8 01 00 00 00       	mov    $0x1,%eax
  8019f7:	eb db                	jmp    8019d4 <devcons_read+0x11>
		return 0;
  8019f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8019fe:	eb d4                	jmp    8019d4 <devcons_read+0x11>

00801a00 <cputchar>:
{
  801a00:	55                   	push   %ebp
  801a01:	89 e5                	mov    %esp,%ebp
  801a03:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a06:	8b 45 08             	mov    0x8(%ebp),%eax
  801a09:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801a0c:	6a 01                	push   $0x1
  801a0e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a11:	50                   	push   %eax
  801a12:	e8 ba f0 ff ff       	call   800ad1 <sys_cputs>
}
  801a17:	83 c4 10             	add    $0x10,%esp
  801a1a:	c9                   	leave  
  801a1b:	c3                   	ret    

00801a1c <getchar>:
{
  801a1c:	55                   	push   %ebp
  801a1d:	89 e5                	mov    %esp,%ebp
  801a1f:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801a22:	6a 01                	push   $0x1
  801a24:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a27:	50                   	push   %eax
  801a28:	6a 00                	push   $0x0
  801a2a:	e8 c2 f6 ff ff       	call   8010f1 <read>
	if (r < 0)
  801a2f:	83 c4 10             	add    $0x10,%esp
  801a32:	85 c0                	test   %eax,%eax
  801a34:	78 08                	js     801a3e <getchar+0x22>
	if (r < 1)
  801a36:	85 c0                	test   %eax,%eax
  801a38:	7e 06                	jle    801a40 <getchar+0x24>
	return c;
  801a3a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801a3e:	c9                   	leave  
  801a3f:	c3                   	ret    
		return -E_EOF;
  801a40:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801a45:	eb f7                	jmp    801a3e <getchar+0x22>

00801a47 <iscons>:
{
  801a47:	55                   	push   %ebp
  801a48:	89 e5                	mov    %esp,%ebp
  801a4a:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a4d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a50:	50                   	push   %eax
  801a51:	ff 75 08             	pushl  0x8(%ebp)
  801a54:	e8 27 f4 ff ff       	call   800e80 <fd_lookup>
  801a59:	83 c4 10             	add    $0x10,%esp
  801a5c:	85 c0                	test   %eax,%eax
  801a5e:	78 11                	js     801a71 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801a60:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a63:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a69:	39 10                	cmp    %edx,(%eax)
  801a6b:	0f 94 c0             	sete   %al
  801a6e:	0f b6 c0             	movzbl %al,%eax
}
  801a71:	c9                   	leave  
  801a72:	c3                   	ret    

00801a73 <opencons>:
{
  801a73:	55                   	push   %ebp
  801a74:	89 e5                	mov    %esp,%ebp
  801a76:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801a79:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a7c:	50                   	push   %eax
  801a7d:	e8 af f3 ff ff       	call   800e31 <fd_alloc>
  801a82:	83 c4 10             	add    $0x10,%esp
  801a85:	85 c0                	test   %eax,%eax
  801a87:	78 3a                	js     801ac3 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a89:	83 ec 04             	sub    $0x4,%esp
  801a8c:	68 07 04 00 00       	push   $0x407
  801a91:	ff 75 f4             	pushl  -0xc(%ebp)
  801a94:	6a 00                	push   $0x0
  801a96:	e8 f2 f0 ff ff       	call   800b8d <sys_page_alloc>
  801a9b:	83 c4 10             	add    $0x10,%esp
  801a9e:	85 c0                	test   %eax,%eax
  801aa0:	78 21                	js     801ac3 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801aa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aa5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801aab:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801aad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ab0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ab7:	83 ec 0c             	sub    $0xc,%esp
  801aba:	50                   	push   %eax
  801abb:	e8 4a f3 ff ff       	call   800e0a <fd2num>
  801ac0:	83 c4 10             	add    $0x10,%esp
}
  801ac3:	c9                   	leave  
  801ac4:	c3                   	ret    

00801ac5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801ac5:	55                   	push   %ebp
  801ac6:	89 e5                	mov    %esp,%ebp
  801ac8:	56                   	push   %esi
  801ac9:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801aca:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801acd:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801ad3:	e8 77 f0 ff ff       	call   800b4f <sys_getenvid>
  801ad8:	83 ec 0c             	sub    $0xc,%esp
  801adb:	ff 75 0c             	pushl  0xc(%ebp)
  801ade:	ff 75 08             	pushl  0x8(%ebp)
  801ae1:	56                   	push   %esi
  801ae2:	50                   	push   %eax
  801ae3:	68 fc 22 80 00       	push   $0x8022fc
  801ae8:	e8 88 e6 ff ff       	call   800175 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801aed:	83 c4 18             	add    $0x18,%esp
  801af0:	53                   	push   %ebx
  801af1:	ff 75 10             	pushl  0x10(%ebp)
  801af4:	e8 2b e6 ff ff       	call   800124 <vcprintf>
	cprintf("\n");
  801af9:	c7 04 24 e7 22 80 00 	movl   $0x8022e7,(%esp)
  801b00:	e8 70 e6 ff ff       	call   800175 <cprintf>
  801b05:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801b08:	cc                   	int3   
  801b09:	eb fd                	jmp    801b08 <_panic+0x43>

00801b0b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b0b:	55                   	push   %ebp
  801b0c:	89 e5                	mov    %esp,%ebp
  801b0e:	56                   	push   %esi
  801b0f:	53                   	push   %ebx
  801b10:	8b 75 08             	mov    0x8(%ebp),%esi
  801b13:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b16:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        //	panic("ipc_recv not implemented");
        int r;
       	if(pg!=NULL){
  801b19:	85 c0                	test   %eax,%eax
  801b1b:	74 3b                	je     801b58 <ipc_recv+0x4d>
	  r = sys_ipc_recv(pg);
  801b1d:	83 ec 0c             	sub    $0xc,%esp
  801b20:	50                   	push   %eax
  801b21:	e8 17 f2 ff ff       	call   800d3d <sys_ipc_recv>
  801b26:	83 c4 10             	add    $0x10,%esp
	}else
	  r = sys_ipc_recv((void *)UTOP);
	if(r<0){
  801b29:	85 c0                	test   %eax,%eax
  801b2b:	78 3d                	js     801b6a <ipc_recv+0x5f>
	if(perm_store!=NULL){
		*perm_store = 0;
            }
        	return r;
           }else{
	     if(from_env_store!=NULL)
  801b2d:	85 f6                	test   %esi,%esi
  801b2f:	74 0a                	je     801b3b <ipc_recv+0x30>
		     *from_env_store = thisenv->env_ipc_from;
  801b31:	a1 04 40 80 00       	mov    0x804004,%eax
  801b36:	8b 40 74             	mov    0x74(%eax),%eax
  801b39:	89 06                	mov    %eax,(%esi)
	     if(perm_store != NULL)
  801b3b:	85 db                	test   %ebx,%ebx
  801b3d:	74 0a                	je     801b49 <ipc_recv+0x3e>
		     *perm_store = thisenv->env_ipc_perm;
  801b3f:	a1 04 40 80 00       	mov    0x804004,%eax
  801b44:	8b 40 78             	mov    0x78(%eax),%eax
  801b47:	89 03                	mov    %eax,(%ebx)
	     return thisenv->env_ipc_value;
  801b49:	a1 04 40 80 00       	mov    0x804004,%eax
  801b4e:	8b 40 70             	mov    0x70(%eax),%eax
	   }

}
  801b51:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b54:	5b                   	pop    %ebx
  801b55:	5e                   	pop    %esi
  801b56:	5d                   	pop    %ebp
  801b57:	c3                   	ret    
	  r = sys_ipc_recv((void *)UTOP);
  801b58:	83 ec 0c             	sub    $0xc,%esp
  801b5b:	68 00 00 c0 ee       	push   $0xeec00000
  801b60:	e8 d8 f1 ff ff       	call   800d3d <sys_ipc_recv>
  801b65:	83 c4 10             	add    $0x10,%esp
  801b68:	eb bf                	jmp    801b29 <ipc_recv+0x1e>
	if(from_env_store!=NULL){
  801b6a:	85 f6                	test   %esi,%esi
  801b6c:	74 06                	je     801b74 <ipc_recv+0x69>
	  *from_env_store = 0;
  801b6e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if(perm_store!=NULL){
  801b74:	85 db                	test   %ebx,%ebx
  801b76:	74 d9                	je     801b51 <ipc_recv+0x46>
		*perm_store = 0;
  801b78:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b7e:	eb d1                	jmp    801b51 <ipc_recv+0x46>

00801b80 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b80:	55                   	push   %ebp
  801b81:	89 e5                	mov    %esp,%ebp
  801b83:	57                   	push   %edi
  801b84:	56                   	push   %esi
  801b85:	53                   	push   %ebx
  801b86:	83 ec 0c             	sub    $0xc,%esp
  801b89:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b8c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if(pg==NULL) pg = (void *)UTOP;
  801b92:	85 db                	test   %ebx,%ebx
  801b94:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801b99:	0f 44 d8             	cmove  %eax,%ebx
	while((r=sys_ipc_try_send(to_env,val,pg,perm))<0){
  801b9c:	ff 75 14             	pushl  0x14(%ebp)
  801b9f:	53                   	push   %ebx
  801ba0:	56                   	push   %esi
  801ba1:	57                   	push   %edi
  801ba2:	e8 73 f1 ff ff       	call   800d1a <sys_ipc_try_send>
  801ba7:	83 c4 10             	add    $0x10,%esp
  801baa:	85 c0                	test   %eax,%eax
  801bac:	79 20                	jns    801bce <ipc_send+0x4e>
	    if(r!=-E_IPC_NOT_RECV){
  801bae:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801bb1:	75 07                	jne    801bba <ipc_send+0x3a>
		    panic("ipc_send:send message failed\n");
	    }
	    sys_yield();
  801bb3:	e8 b6 ef ff ff       	call   800b6e <sys_yield>
  801bb8:	eb e2                	jmp    801b9c <ipc_send+0x1c>
		    panic("ipc_send:send message failed\n");
  801bba:	83 ec 04             	sub    $0x4,%esp
  801bbd:	68 20 23 80 00       	push   $0x802320
  801bc2:	6a 43                	push   $0x43
  801bc4:	68 3e 23 80 00       	push   $0x80233e
  801bc9:	e8 f7 fe ff ff       	call   801ac5 <_panic>
	}

}
  801bce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bd1:	5b                   	pop    %ebx
  801bd2:	5e                   	pop    %esi
  801bd3:	5f                   	pop    %edi
  801bd4:	5d                   	pop    %ebp
  801bd5:	c3                   	ret    

00801bd6 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801bd6:	55                   	push   %ebp
  801bd7:	89 e5                	mov    %esp,%ebp
  801bd9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801bdc:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801be1:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801be4:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801bea:	8b 52 50             	mov    0x50(%edx),%edx
  801bed:	39 ca                	cmp    %ecx,%edx
  801bef:	74 11                	je     801c02 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801bf1:	83 c0 01             	add    $0x1,%eax
  801bf4:	3d 00 04 00 00       	cmp    $0x400,%eax
  801bf9:	75 e6                	jne    801be1 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801bfb:	b8 00 00 00 00       	mov    $0x0,%eax
  801c00:	eb 0b                	jmp    801c0d <ipc_find_env+0x37>
			return envs[i].env_id;
  801c02:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c05:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c0a:	8b 40 48             	mov    0x48(%eax),%eax
}
  801c0d:	5d                   	pop    %ebp
  801c0e:	c3                   	ret    

00801c0f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c0f:	55                   	push   %ebp
  801c10:	89 e5                	mov    %esp,%ebp
  801c12:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c15:	89 d0                	mov    %edx,%eax
  801c17:	c1 e8 16             	shr    $0x16,%eax
  801c1a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c21:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801c26:	f6 c1 01             	test   $0x1,%cl
  801c29:	74 1d                	je     801c48 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801c2b:	c1 ea 0c             	shr    $0xc,%edx
  801c2e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c35:	f6 c2 01             	test   $0x1,%dl
  801c38:	74 0e                	je     801c48 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c3a:	c1 ea 0c             	shr    $0xc,%edx
  801c3d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c44:	ef 
  801c45:	0f b7 c0             	movzwl %ax,%eax
}
  801c48:	5d                   	pop    %ebp
  801c49:	c3                   	ret    
  801c4a:	66 90                	xchg   %ax,%ax
  801c4c:	66 90                	xchg   %ax,%ax
  801c4e:	66 90                	xchg   %ax,%ax

00801c50 <__udivdi3>:
  801c50:	55                   	push   %ebp
  801c51:	57                   	push   %edi
  801c52:	56                   	push   %esi
  801c53:	53                   	push   %ebx
  801c54:	83 ec 1c             	sub    $0x1c,%esp
  801c57:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c5b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801c5f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c63:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801c67:	85 d2                	test   %edx,%edx
  801c69:	75 35                	jne    801ca0 <__udivdi3+0x50>
  801c6b:	39 f3                	cmp    %esi,%ebx
  801c6d:	0f 87 bd 00 00 00    	ja     801d30 <__udivdi3+0xe0>
  801c73:	85 db                	test   %ebx,%ebx
  801c75:	89 d9                	mov    %ebx,%ecx
  801c77:	75 0b                	jne    801c84 <__udivdi3+0x34>
  801c79:	b8 01 00 00 00       	mov    $0x1,%eax
  801c7e:	31 d2                	xor    %edx,%edx
  801c80:	f7 f3                	div    %ebx
  801c82:	89 c1                	mov    %eax,%ecx
  801c84:	31 d2                	xor    %edx,%edx
  801c86:	89 f0                	mov    %esi,%eax
  801c88:	f7 f1                	div    %ecx
  801c8a:	89 c6                	mov    %eax,%esi
  801c8c:	89 e8                	mov    %ebp,%eax
  801c8e:	89 f7                	mov    %esi,%edi
  801c90:	f7 f1                	div    %ecx
  801c92:	89 fa                	mov    %edi,%edx
  801c94:	83 c4 1c             	add    $0x1c,%esp
  801c97:	5b                   	pop    %ebx
  801c98:	5e                   	pop    %esi
  801c99:	5f                   	pop    %edi
  801c9a:	5d                   	pop    %ebp
  801c9b:	c3                   	ret    
  801c9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ca0:	39 f2                	cmp    %esi,%edx
  801ca2:	77 7c                	ja     801d20 <__udivdi3+0xd0>
  801ca4:	0f bd fa             	bsr    %edx,%edi
  801ca7:	83 f7 1f             	xor    $0x1f,%edi
  801caa:	0f 84 98 00 00 00    	je     801d48 <__udivdi3+0xf8>
  801cb0:	89 f9                	mov    %edi,%ecx
  801cb2:	b8 20 00 00 00       	mov    $0x20,%eax
  801cb7:	29 f8                	sub    %edi,%eax
  801cb9:	d3 e2                	shl    %cl,%edx
  801cbb:	89 54 24 08          	mov    %edx,0x8(%esp)
  801cbf:	89 c1                	mov    %eax,%ecx
  801cc1:	89 da                	mov    %ebx,%edx
  801cc3:	d3 ea                	shr    %cl,%edx
  801cc5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801cc9:	09 d1                	or     %edx,%ecx
  801ccb:	89 f2                	mov    %esi,%edx
  801ccd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801cd1:	89 f9                	mov    %edi,%ecx
  801cd3:	d3 e3                	shl    %cl,%ebx
  801cd5:	89 c1                	mov    %eax,%ecx
  801cd7:	d3 ea                	shr    %cl,%edx
  801cd9:	89 f9                	mov    %edi,%ecx
  801cdb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801cdf:	d3 e6                	shl    %cl,%esi
  801ce1:	89 eb                	mov    %ebp,%ebx
  801ce3:	89 c1                	mov    %eax,%ecx
  801ce5:	d3 eb                	shr    %cl,%ebx
  801ce7:	09 de                	or     %ebx,%esi
  801ce9:	89 f0                	mov    %esi,%eax
  801ceb:	f7 74 24 08          	divl   0x8(%esp)
  801cef:	89 d6                	mov    %edx,%esi
  801cf1:	89 c3                	mov    %eax,%ebx
  801cf3:	f7 64 24 0c          	mull   0xc(%esp)
  801cf7:	39 d6                	cmp    %edx,%esi
  801cf9:	72 0c                	jb     801d07 <__udivdi3+0xb7>
  801cfb:	89 f9                	mov    %edi,%ecx
  801cfd:	d3 e5                	shl    %cl,%ebp
  801cff:	39 c5                	cmp    %eax,%ebp
  801d01:	73 5d                	jae    801d60 <__udivdi3+0x110>
  801d03:	39 d6                	cmp    %edx,%esi
  801d05:	75 59                	jne    801d60 <__udivdi3+0x110>
  801d07:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801d0a:	31 ff                	xor    %edi,%edi
  801d0c:	89 fa                	mov    %edi,%edx
  801d0e:	83 c4 1c             	add    $0x1c,%esp
  801d11:	5b                   	pop    %ebx
  801d12:	5e                   	pop    %esi
  801d13:	5f                   	pop    %edi
  801d14:	5d                   	pop    %ebp
  801d15:	c3                   	ret    
  801d16:	8d 76 00             	lea    0x0(%esi),%esi
  801d19:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801d20:	31 ff                	xor    %edi,%edi
  801d22:	31 c0                	xor    %eax,%eax
  801d24:	89 fa                	mov    %edi,%edx
  801d26:	83 c4 1c             	add    $0x1c,%esp
  801d29:	5b                   	pop    %ebx
  801d2a:	5e                   	pop    %esi
  801d2b:	5f                   	pop    %edi
  801d2c:	5d                   	pop    %ebp
  801d2d:	c3                   	ret    
  801d2e:	66 90                	xchg   %ax,%ax
  801d30:	31 ff                	xor    %edi,%edi
  801d32:	89 e8                	mov    %ebp,%eax
  801d34:	89 f2                	mov    %esi,%edx
  801d36:	f7 f3                	div    %ebx
  801d38:	89 fa                	mov    %edi,%edx
  801d3a:	83 c4 1c             	add    $0x1c,%esp
  801d3d:	5b                   	pop    %ebx
  801d3e:	5e                   	pop    %esi
  801d3f:	5f                   	pop    %edi
  801d40:	5d                   	pop    %ebp
  801d41:	c3                   	ret    
  801d42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d48:	39 f2                	cmp    %esi,%edx
  801d4a:	72 06                	jb     801d52 <__udivdi3+0x102>
  801d4c:	31 c0                	xor    %eax,%eax
  801d4e:	39 eb                	cmp    %ebp,%ebx
  801d50:	77 d2                	ja     801d24 <__udivdi3+0xd4>
  801d52:	b8 01 00 00 00       	mov    $0x1,%eax
  801d57:	eb cb                	jmp    801d24 <__udivdi3+0xd4>
  801d59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d60:	89 d8                	mov    %ebx,%eax
  801d62:	31 ff                	xor    %edi,%edi
  801d64:	eb be                	jmp    801d24 <__udivdi3+0xd4>
  801d66:	66 90                	xchg   %ax,%ax
  801d68:	66 90                	xchg   %ax,%ax
  801d6a:	66 90                	xchg   %ax,%ax
  801d6c:	66 90                	xchg   %ax,%ax
  801d6e:	66 90                	xchg   %ax,%ax

00801d70 <__umoddi3>:
  801d70:	55                   	push   %ebp
  801d71:	57                   	push   %edi
  801d72:	56                   	push   %esi
  801d73:	53                   	push   %ebx
  801d74:	83 ec 1c             	sub    $0x1c,%esp
  801d77:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801d7b:	8b 74 24 30          	mov    0x30(%esp),%esi
  801d7f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801d83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d87:	85 ed                	test   %ebp,%ebp
  801d89:	89 f0                	mov    %esi,%eax
  801d8b:	89 da                	mov    %ebx,%edx
  801d8d:	75 19                	jne    801da8 <__umoddi3+0x38>
  801d8f:	39 df                	cmp    %ebx,%edi
  801d91:	0f 86 b1 00 00 00    	jbe    801e48 <__umoddi3+0xd8>
  801d97:	f7 f7                	div    %edi
  801d99:	89 d0                	mov    %edx,%eax
  801d9b:	31 d2                	xor    %edx,%edx
  801d9d:	83 c4 1c             	add    $0x1c,%esp
  801da0:	5b                   	pop    %ebx
  801da1:	5e                   	pop    %esi
  801da2:	5f                   	pop    %edi
  801da3:	5d                   	pop    %ebp
  801da4:	c3                   	ret    
  801da5:	8d 76 00             	lea    0x0(%esi),%esi
  801da8:	39 dd                	cmp    %ebx,%ebp
  801daa:	77 f1                	ja     801d9d <__umoddi3+0x2d>
  801dac:	0f bd cd             	bsr    %ebp,%ecx
  801daf:	83 f1 1f             	xor    $0x1f,%ecx
  801db2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801db6:	0f 84 b4 00 00 00    	je     801e70 <__umoddi3+0x100>
  801dbc:	b8 20 00 00 00       	mov    $0x20,%eax
  801dc1:	89 c2                	mov    %eax,%edx
  801dc3:	8b 44 24 04          	mov    0x4(%esp),%eax
  801dc7:	29 c2                	sub    %eax,%edx
  801dc9:	89 c1                	mov    %eax,%ecx
  801dcb:	89 f8                	mov    %edi,%eax
  801dcd:	d3 e5                	shl    %cl,%ebp
  801dcf:	89 d1                	mov    %edx,%ecx
  801dd1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801dd5:	d3 e8                	shr    %cl,%eax
  801dd7:	09 c5                	or     %eax,%ebp
  801dd9:	8b 44 24 04          	mov    0x4(%esp),%eax
  801ddd:	89 c1                	mov    %eax,%ecx
  801ddf:	d3 e7                	shl    %cl,%edi
  801de1:	89 d1                	mov    %edx,%ecx
  801de3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801de7:	89 df                	mov    %ebx,%edi
  801de9:	d3 ef                	shr    %cl,%edi
  801deb:	89 c1                	mov    %eax,%ecx
  801ded:	89 f0                	mov    %esi,%eax
  801def:	d3 e3                	shl    %cl,%ebx
  801df1:	89 d1                	mov    %edx,%ecx
  801df3:	89 fa                	mov    %edi,%edx
  801df5:	d3 e8                	shr    %cl,%eax
  801df7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801dfc:	09 d8                	or     %ebx,%eax
  801dfe:	f7 f5                	div    %ebp
  801e00:	d3 e6                	shl    %cl,%esi
  801e02:	89 d1                	mov    %edx,%ecx
  801e04:	f7 64 24 08          	mull   0x8(%esp)
  801e08:	39 d1                	cmp    %edx,%ecx
  801e0a:	89 c3                	mov    %eax,%ebx
  801e0c:	89 d7                	mov    %edx,%edi
  801e0e:	72 06                	jb     801e16 <__umoddi3+0xa6>
  801e10:	75 0e                	jne    801e20 <__umoddi3+0xb0>
  801e12:	39 c6                	cmp    %eax,%esi
  801e14:	73 0a                	jae    801e20 <__umoddi3+0xb0>
  801e16:	2b 44 24 08          	sub    0x8(%esp),%eax
  801e1a:	19 ea                	sbb    %ebp,%edx
  801e1c:	89 d7                	mov    %edx,%edi
  801e1e:	89 c3                	mov    %eax,%ebx
  801e20:	89 ca                	mov    %ecx,%edx
  801e22:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801e27:	29 de                	sub    %ebx,%esi
  801e29:	19 fa                	sbb    %edi,%edx
  801e2b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  801e2f:	89 d0                	mov    %edx,%eax
  801e31:	d3 e0                	shl    %cl,%eax
  801e33:	89 d9                	mov    %ebx,%ecx
  801e35:	d3 ee                	shr    %cl,%esi
  801e37:	d3 ea                	shr    %cl,%edx
  801e39:	09 f0                	or     %esi,%eax
  801e3b:	83 c4 1c             	add    $0x1c,%esp
  801e3e:	5b                   	pop    %ebx
  801e3f:	5e                   	pop    %esi
  801e40:	5f                   	pop    %edi
  801e41:	5d                   	pop    %ebp
  801e42:	c3                   	ret    
  801e43:	90                   	nop
  801e44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e48:	85 ff                	test   %edi,%edi
  801e4a:	89 f9                	mov    %edi,%ecx
  801e4c:	75 0b                	jne    801e59 <__umoddi3+0xe9>
  801e4e:	b8 01 00 00 00       	mov    $0x1,%eax
  801e53:	31 d2                	xor    %edx,%edx
  801e55:	f7 f7                	div    %edi
  801e57:	89 c1                	mov    %eax,%ecx
  801e59:	89 d8                	mov    %ebx,%eax
  801e5b:	31 d2                	xor    %edx,%edx
  801e5d:	f7 f1                	div    %ecx
  801e5f:	89 f0                	mov    %esi,%eax
  801e61:	f7 f1                	div    %ecx
  801e63:	e9 31 ff ff ff       	jmp    801d99 <__umoddi3+0x29>
  801e68:	90                   	nop
  801e69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e70:	39 dd                	cmp    %ebx,%ebp
  801e72:	72 08                	jb     801e7c <__umoddi3+0x10c>
  801e74:	39 f7                	cmp    %esi,%edi
  801e76:	0f 87 21 ff ff ff    	ja     801d9d <__umoddi3+0x2d>
  801e7c:	89 da                	mov    %ebx,%edx
  801e7e:	89 f0                	mov    %esi,%eax
  801e80:	29 f8                	sub    %edi,%eax
  801e82:	19 ea                	sbb    %ebp,%edx
  801e84:	e9 14 ff ff ff       	jmp    801d9d <__umoddi3+0x2d>
