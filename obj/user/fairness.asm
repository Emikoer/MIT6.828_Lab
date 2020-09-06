
obj/user/fairness.debug:     file format elf32-i386


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
  80002c:	e8 70 00 00 00       	call   8000a1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 10             	sub    $0x10,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003b:	e8 30 0b 00 00       	call   800b70 <sys_getenvid>
  800040:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800042:	81 3d 04 40 80 00 7c 	cmpl   $0xeec0007c,0x804004
  800049:	00 c0 ee 
  80004c:	75 26                	jne    800074 <umain+0x41>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004e:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800051:	83 ec 04             	sub    $0x4,%esp
  800054:	6a 00                	push   $0x0
  800056:	6a 00                	push   $0x0
  800058:	56                   	push   %esi
  800059:	e8 41 0d 00 00       	call   800d9f <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80005e:	83 c4 0c             	add    $0xc,%esp
  800061:	ff 75 f4             	pushl  -0xc(%ebp)
  800064:	53                   	push   %ebx
  800065:	68 20 1e 80 00       	push   $0x801e20
  80006a:	e8 27 01 00 00       	call   800196 <cprintf>
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	eb dd                	jmp    800051 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800074:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800079:	83 ec 04             	sub    $0x4,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	68 31 1e 80 00       	push   $0x801e31
  800083:	e8 0e 01 00 00       	call   800196 <cprintf>
  800088:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80008b:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800090:	6a 00                	push   $0x0
  800092:	6a 00                	push   $0x0
  800094:	6a 00                	push   $0x0
  800096:	50                   	push   %eax
  800097:	e8 78 0d 00 00       	call   800e14 <ipc_send>
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	eb ea                	jmp    80008b <umain+0x58>

008000a1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
  8000a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000ac:	e8 bf 0a 00 00       	call   800b70 <sys_getenvid>
  8000b1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000b9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000be:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c3:	85 db                	test   %ebx,%ebx
  8000c5:	7e 07                	jle    8000ce <libmain+0x2d>
		binaryname = argv[0];
  8000c7:	8b 06                	mov    (%esi),%eax
  8000c9:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ce:	83 ec 08             	sub    $0x8,%esp
  8000d1:	56                   	push   %esi
  8000d2:	53                   	push   %ebx
  8000d3:	e8 5b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000d8:	e8 0a 00 00 00       	call   8000e7 <exit>
}
  8000dd:	83 c4 10             	add    $0x10,%esp
  8000e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e3:	5b                   	pop    %ebx
  8000e4:	5e                   	pop    %esi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000ed:	e8 87 0f 00 00       	call   801079 <close_all>
	sys_env_destroy(0);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	6a 00                	push   $0x0
  8000f7:	e8 33 0a 00 00       	call   800b2f <sys_env_destroy>
}
  8000fc:	83 c4 10             	add    $0x10,%esp
  8000ff:	c9                   	leave  
  800100:	c3                   	ret    

00800101 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800101:	55                   	push   %ebp
  800102:	89 e5                	mov    %esp,%ebp
  800104:	53                   	push   %ebx
  800105:	83 ec 04             	sub    $0x4,%esp
  800108:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80010b:	8b 13                	mov    (%ebx),%edx
  80010d:	8d 42 01             	lea    0x1(%edx),%eax
  800110:	89 03                	mov    %eax,(%ebx)
  800112:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800115:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800119:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011e:	74 09                	je     800129 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800120:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800124:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800127:	c9                   	leave  
  800128:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800129:	83 ec 08             	sub    $0x8,%esp
  80012c:	68 ff 00 00 00       	push   $0xff
  800131:	8d 43 08             	lea    0x8(%ebx),%eax
  800134:	50                   	push   %eax
  800135:	e8 b8 09 00 00       	call   800af2 <sys_cputs>
		b->idx = 0;
  80013a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800140:	83 c4 10             	add    $0x10,%esp
  800143:	eb db                	jmp    800120 <putch+0x1f>

00800145 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800145:	55                   	push   %ebp
  800146:	89 e5                	mov    %esp,%ebp
  800148:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80014e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800155:	00 00 00 
	b.cnt = 0;
  800158:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80015f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800162:	ff 75 0c             	pushl  0xc(%ebp)
  800165:	ff 75 08             	pushl  0x8(%ebp)
  800168:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80016e:	50                   	push   %eax
  80016f:	68 01 01 80 00       	push   $0x800101
  800174:	e8 1a 01 00 00       	call   800293 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800179:	83 c4 08             	add    $0x8,%esp
  80017c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800182:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800188:	50                   	push   %eax
  800189:	e8 64 09 00 00       	call   800af2 <sys_cputs>

	return b.cnt;
}
  80018e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800194:	c9                   	leave  
  800195:	c3                   	ret    

00800196 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800196:	55                   	push   %ebp
  800197:	89 e5                	mov    %esp,%ebp
  800199:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80019c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80019f:	50                   	push   %eax
  8001a0:	ff 75 08             	pushl  0x8(%ebp)
  8001a3:	e8 9d ff ff ff       	call   800145 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a8:	c9                   	leave  
  8001a9:	c3                   	ret    

008001aa <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001aa:	55                   	push   %ebp
  8001ab:	89 e5                	mov    %esp,%ebp
  8001ad:	57                   	push   %edi
  8001ae:	56                   	push   %esi
  8001af:	53                   	push   %ebx
  8001b0:	83 ec 1c             	sub    $0x1c,%esp
  8001b3:	89 c7                	mov    %eax,%edi
  8001b5:	89 d6                	mov    %edx,%esi
  8001b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001c0:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c3:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001c6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001cb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001ce:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001d1:	39 d3                	cmp    %edx,%ebx
  8001d3:	72 05                	jb     8001da <printnum+0x30>
  8001d5:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001d8:	77 7a                	ja     800254 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001da:	83 ec 0c             	sub    $0xc,%esp
  8001dd:	ff 75 18             	pushl  0x18(%ebp)
  8001e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8001e3:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001e6:	53                   	push   %ebx
  8001e7:	ff 75 10             	pushl  0x10(%ebp)
  8001ea:	83 ec 08             	sub    $0x8,%esp
  8001ed:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001f0:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f3:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f6:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f9:	e8 e2 19 00 00       	call   801be0 <__udivdi3>
  8001fe:	83 c4 18             	add    $0x18,%esp
  800201:	52                   	push   %edx
  800202:	50                   	push   %eax
  800203:	89 f2                	mov    %esi,%edx
  800205:	89 f8                	mov    %edi,%eax
  800207:	e8 9e ff ff ff       	call   8001aa <printnum>
  80020c:	83 c4 20             	add    $0x20,%esp
  80020f:	eb 13                	jmp    800224 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800211:	83 ec 08             	sub    $0x8,%esp
  800214:	56                   	push   %esi
  800215:	ff 75 18             	pushl  0x18(%ebp)
  800218:	ff d7                	call   *%edi
  80021a:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80021d:	83 eb 01             	sub    $0x1,%ebx
  800220:	85 db                	test   %ebx,%ebx
  800222:	7f ed                	jg     800211 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800224:	83 ec 08             	sub    $0x8,%esp
  800227:	56                   	push   %esi
  800228:	83 ec 04             	sub    $0x4,%esp
  80022b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80022e:	ff 75 e0             	pushl  -0x20(%ebp)
  800231:	ff 75 dc             	pushl  -0x24(%ebp)
  800234:	ff 75 d8             	pushl  -0x28(%ebp)
  800237:	e8 c4 1a 00 00       	call   801d00 <__umoddi3>
  80023c:	83 c4 14             	add    $0x14,%esp
  80023f:	0f be 80 52 1e 80 00 	movsbl 0x801e52(%eax),%eax
  800246:	50                   	push   %eax
  800247:	ff d7                	call   *%edi
}
  800249:	83 c4 10             	add    $0x10,%esp
  80024c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024f:	5b                   	pop    %ebx
  800250:	5e                   	pop    %esi
  800251:	5f                   	pop    %edi
  800252:	5d                   	pop    %ebp
  800253:	c3                   	ret    
  800254:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800257:	eb c4                	jmp    80021d <printnum+0x73>

00800259 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800259:	55                   	push   %ebp
  80025a:	89 e5                	mov    %esp,%ebp
  80025c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80025f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800263:	8b 10                	mov    (%eax),%edx
  800265:	3b 50 04             	cmp    0x4(%eax),%edx
  800268:	73 0a                	jae    800274 <sprintputch+0x1b>
		*b->buf++ = ch;
  80026a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80026d:	89 08                	mov    %ecx,(%eax)
  80026f:	8b 45 08             	mov    0x8(%ebp),%eax
  800272:	88 02                	mov    %al,(%edx)
}
  800274:	5d                   	pop    %ebp
  800275:	c3                   	ret    

00800276 <printfmt>:
{
  800276:	55                   	push   %ebp
  800277:	89 e5                	mov    %esp,%ebp
  800279:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80027c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80027f:	50                   	push   %eax
  800280:	ff 75 10             	pushl  0x10(%ebp)
  800283:	ff 75 0c             	pushl  0xc(%ebp)
  800286:	ff 75 08             	pushl  0x8(%ebp)
  800289:	e8 05 00 00 00       	call   800293 <vprintfmt>
}
  80028e:	83 c4 10             	add    $0x10,%esp
  800291:	c9                   	leave  
  800292:	c3                   	ret    

00800293 <vprintfmt>:
{
  800293:	55                   	push   %ebp
  800294:	89 e5                	mov    %esp,%ebp
  800296:	57                   	push   %edi
  800297:	56                   	push   %esi
  800298:	53                   	push   %ebx
  800299:	83 ec 2c             	sub    $0x2c,%esp
  80029c:	8b 75 08             	mov    0x8(%ebp),%esi
  80029f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002a2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002a5:	e9 c1 03 00 00       	jmp    80066b <vprintfmt+0x3d8>
		padc = ' ';
  8002aa:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8002ae:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8002b5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8002bc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002c3:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002c8:	8d 47 01             	lea    0x1(%edi),%eax
  8002cb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ce:	0f b6 17             	movzbl (%edi),%edx
  8002d1:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002d4:	3c 55                	cmp    $0x55,%al
  8002d6:	0f 87 12 04 00 00    	ja     8006ee <vprintfmt+0x45b>
  8002dc:	0f b6 c0             	movzbl %al,%eax
  8002df:	ff 24 85 a0 1f 80 00 	jmp    *0x801fa0(,%eax,4)
  8002e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002e9:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8002ed:	eb d9                	jmp    8002c8 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8002ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  8002f2:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002f6:	eb d0                	jmp    8002c8 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8002f8:	0f b6 d2             	movzbl %dl,%edx
  8002fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002fe:	b8 00 00 00 00       	mov    $0x0,%eax
  800303:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800306:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800309:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80030d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800310:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800313:	83 f9 09             	cmp    $0x9,%ecx
  800316:	77 55                	ja     80036d <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800318:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80031b:	eb e9                	jmp    800306 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  80031d:	8b 45 14             	mov    0x14(%ebp),%eax
  800320:	8b 00                	mov    (%eax),%eax
  800322:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800325:	8b 45 14             	mov    0x14(%ebp),%eax
  800328:	8d 40 04             	lea    0x4(%eax),%eax
  80032b:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80032e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800331:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800335:	79 91                	jns    8002c8 <vprintfmt+0x35>
				width = precision, precision = -1;
  800337:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80033a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80033d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800344:	eb 82                	jmp    8002c8 <vprintfmt+0x35>
  800346:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800349:	85 c0                	test   %eax,%eax
  80034b:	ba 00 00 00 00       	mov    $0x0,%edx
  800350:	0f 49 d0             	cmovns %eax,%edx
  800353:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800356:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800359:	e9 6a ff ff ff       	jmp    8002c8 <vprintfmt+0x35>
  80035e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800361:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800368:	e9 5b ff ff ff       	jmp    8002c8 <vprintfmt+0x35>
  80036d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800370:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800373:	eb bc                	jmp    800331 <vprintfmt+0x9e>
			lflag++;
  800375:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800378:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80037b:	e9 48 ff ff ff       	jmp    8002c8 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  800380:	8b 45 14             	mov    0x14(%ebp),%eax
  800383:	8d 78 04             	lea    0x4(%eax),%edi
  800386:	83 ec 08             	sub    $0x8,%esp
  800389:	53                   	push   %ebx
  80038a:	ff 30                	pushl  (%eax)
  80038c:	ff d6                	call   *%esi
			break;
  80038e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800391:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800394:	e9 cf 02 00 00       	jmp    800668 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  800399:	8b 45 14             	mov    0x14(%ebp),%eax
  80039c:	8d 78 04             	lea    0x4(%eax),%edi
  80039f:	8b 00                	mov    (%eax),%eax
  8003a1:	99                   	cltd   
  8003a2:	31 d0                	xor    %edx,%eax
  8003a4:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003a6:	83 f8 0f             	cmp    $0xf,%eax
  8003a9:	7f 23                	jg     8003ce <vprintfmt+0x13b>
  8003ab:	8b 14 85 00 21 80 00 	mov    0x802100(,%eax,4),%edx
  8003b2:	85 d2                	test   %edx,%edx
  8003b4:	74 18                	je     8003ce <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8003b6:	52                   	push   %edx
  8003b7:	68 59 22 80 00       	push   $0x802259
  8003bc:	53                   	push   %ebx
  8003bd:	56                   	push   %esi
  8003be:	e8 b3 fe ff ff       	call   800276 <printfmt>
  8003c3:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003c6:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003c9:	e9 9a 02 00 00       	jmp    800668 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  8003ce:	50                   	push   %eax
  8003cf:	68 6a 1e 80 00       	push   $0x801e6a
  8003d4:	53                   	push   %ebx
  8003d5:	56                   	push   %esi
  8003d6:	e8 9b fe ff ff       	call   800276 <printfmt>
  8003db:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003de:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003e1:	e9 82 02 00 00       	jmp    800668 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  8003e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e9:	83 c0 04             	add    $0x4,%eax
  8003ec:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f2:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003f4:	85 ff                	test   %edi,%edi
  8003f6:	b8 63 1e 80 00       	mov    $0x801e63,%eax
  8003fb:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8003fe:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800402:	0f 8e bd 00 00 00    	jle    8004c5 <vprintfmt+0x232>
  800408:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80040c:	75 0e                	jne    80041c <vprintfmt+0x189>
  80040e:	89 75 08             	mov    %esi,0x8(%ebp)
  800411:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800414:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800417:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80041a:	eb 6d                	jmp    800489 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  80041c:	83 ec 08             	sub    $0x8,%esp
  80041f:	ff 75 d0             	pushl  -0x30(%ebp)
  800422:	57                   	push   %edi
  800423:	e8 6e 03 00 00       	call   800796 <strnlen>
  800428:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80042b:	29 c1                	sub    %eax,%ecx
  80042d:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800430:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800433:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800437:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80043a:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80043d:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  80043f:	eb 0f                	jmp    800450 <vprintfmt+0x1bd>
					putch(padc, putdat);
  800441:	83 ec 08             	sub    $0x8,%esp
  800444:	53                   	push   %ebx
  800445:	ff 75 e0             	pushl  -0x20(%ebp)
  800448:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80044a:	83 ef 01             	sub    $0x1,%edi
  80044d:	83 c4 10             	add    $0x10,%esp
  800450:	85 ff                	test   %edi,%edi
  800452:	7f ed                	jg     800441 <vprintfmt+0x1ae>
  800454:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800457:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80045a:	85 c9                	test   %ecx,%ecx
  80045c:	b8 00 00 00 00       	mov    $0x0,%eax
  800461:	0f 49 c1             	cmovns %ecx,%eax
  800464:	29 c1                	sub    %eax,%ecx
  800466:	89 75 08             	mov    %esi,0x8(%ebp)
  800469:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80046c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80046f:	89 cb                	mov    %ecx,%ebx
  800471:	eb 16                	jmp    800489 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  800473:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800477:	75 31                	jne    8004aa <vprintfmt+0x217>
					putch(ch, putdat);
  800479:	83 ec 08             	sub    $0x8,%esp
  80047c:	ff 75 0c             	pushl  0xc(%ebp)
  80047f:	50                   	push   %eax
  800480:	ff 55 08             	call   *0x8(%ebp)
  800483:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800486:	83 eb 01             	sub    $0x1,%ebx
  800489:	83 c7 01             	add    $0x1,%edi
  80048c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800490:	0f be c2             	movsbl %dl,%eax
  800493:	85 c0                	test   %eax,%eax
  800495:	74 59                	je     8004f0 <vprintfmt+0x25d>
  800497:	85 f6                	test   %esi,%esi
  800499:	78 d8                	js     800473 <vprintfmt+0x1e0>
  80049b:	83 ee 01             	sub    $0x1,%esi
  80049e:	79 d3                	jns    800473 <vprintfmt+0x1e0>
  8004a0:	89 df                	mov    %ebx,%edi
  8004a2:	8b 75 08             	mov    0x8(%ebp),%esi
  8004a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004a8:	eb 37                	jmp    8004e1 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004aa:	0f be d2             	movsbl %dl,%edx
  8004ad:	83 ea 20             	sub    $0x20,%edx
  8004b0:	83 fa 5e             	cmp    $0x5e,%edx
  8004b3:	76 c4                	jbe    800479 <vprintfmt+0x1e6>
					putch('?', putdat);
  8004b5:	83 ec 08             	sub    $0x8,%esp
  8004b8:	ff 75 0c             	pushl  0xc(%ebp)
  8004bb:	6a 3f                	push   $0x3f
  8004bd:	ff 55 08             	call   *0x8(%ebp)
  8004c0:	83 c4 10             	add    $0x10,%esp
  8004c3:	eb c1                	jmp    800486 <vprintfmt+0x1f3>
  8004c5:	89 75 08             	mov    %esi,0x8(%ebp)
  8004c8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004cb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ce:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004d1:	eb b6                	jmp    800489 <vprintfmt+0x1f6>
				putch(' ', putdat);
  8004d3:	83 ec 08             	sub    $0x8,%esp
  8004d6:	53                   	push   %ebx
  8004d7:	6a 20                	push   $0x20
  8004d9:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004db:	83 ef 01             	sub    $0x1,%edi
  8004de:	83 c4 10             	add    $0x10,%esp
  8004e1:	85 ff                	test   %edi,%edi
  8004e3:	7f ee                	jg     8004d3 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  8004e5:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004e8:	89 45 14             	mov    %eax,0x14(%ebp)
  8004eb:	e9 78 01 00 00       	jmp    800668 <vprintfmt+0x3d5>
  8004f0:	89 df                	mov    %ebx,%edi
  8004f2:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f8:	eb e7                	jmp    8004e1 <vprintfmt+0x24e>
	if (lflag >= 2)
  8004fa:	83 f9 01             	cmp    $0x1,%ecx
  8004fd:	7e 3f                	jle    80053e <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  8004ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800502:	8b 50 04             	mov    0x4(%eax),%edx
  800505:	8b 00                	mov    (%eax),%eax
  800507:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80050a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80050d:	8b 45 14             	mov    0x14(%ebp),%eax
  800510:	8d 40 08             	lea    0x8(%eax),%eax
  800513:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800516:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80051a:	79 5c                	jns    800578 <vprintfmt+0x2e5>
				putch('-', putdat);
  80051c:	83 ec 08             	sub    $0x8,%esp
  80051f:	53                   	push   %ebx
  800520:	6a 2d                	push   $0x2d
  800522:	ff d6                	call   *%esi
				num = -(long long) num;
  800524:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800527:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80052a:	f7 da                	neg    %edx
  80052c:	83 d1 00             	adc    $0x0,%ecx
  80052f:	f7 d9                	neg    %ecx
  800531:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800534:	b8 0a 00 00 00       	mov    $0xa,%eax
  800539:	e9 10 01 00 00       	jmp    80064e <vprintfmt+0x3bb>
	else if (lflag)
  80053e:	85 c9                	test   %ecx,%ecx
  800540:	75 1b                	jne    80055d <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800542:	8b 45 14             	mov    0x14(%ebp),%eax
  800545:	8b 00                	mov    (%eax),%eax
  800547:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80054a:	89 c1                	mov    %eax,%ecx
  80054c:	c1 f9 1f             	sar    $0x1f,%ecx
  80054f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800552:	8b 45 14             	mov    0x14(%ebp),%eax
  800555:	8d 40 04             	lea    0x4(%eax),%eax
  800558:	89 45 14             	mov    %eax,0x14(%ebp)
  80055b:	eb b9                	jmp    800516 <vprintfmt+0x283>
		return va_arg(*ap, long);
  80055d:	8b 45 14             	mov    0x14(%ebp),%eax
  800560:	8b 00                	mov    (%eax),%eax
  800562:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800565:	89 c1                	mov    %eax,%ecx
  800567:	c1 f9 1f             	sar    $0x1f,%ecx
  80056a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80056d:	8b 45 14             	mov    0x14(%ebp),%eax
  800570:	8d 40 04             	lea    0x4(%eax),%eax
  800573:	89 45 14             	mov    %eax,0x14(%ebp)
  800576:	eb 9e                	jmp    800516 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  800578:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80057b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80057e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800583:	e9 c6 00 00 00       	jmp    80064e <vprintfmt+0x3bb>
	if (lflag >= 2)
  800588:	83 f9 01             	cmp    $0x1,%ecx
  80058b:	7e 18                	jle    8005a5 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  80058d:	8b 45 14             	mov    0x14(%ebp),%eax
  800590:	8b 10                	mov    (%eax),%edx
  800592:	8b 48 04             	mov    0x4(%eax),%ecx
  800595:	8d 40 08             	lea    0x8(%eax),%eax
  800598:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80059b:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005a0:	e9 a9 00 00 00       	jmp    80064e <vprintfmt+0x3bb>
	else if (lflag)
  8005a5:	85 c9                	test   %ecx,%ecx
  8005a7:	75 1a                	jne    8005c3 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  8005a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ac:	8b 10                	mov    (%eax),%edx
  8005ae:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005b3:	8d 40 04             	lea    0x4(%eax),%eax
  8005b6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005b9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005be:	e9 8b 00 00 00       	jmp    80064e <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8005c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c6:	8b 10                	mov    (%eax),%edx
  8005c8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005cd:	8d 40 04             	lea    0x4(%eax),%eax
  8005d0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005d3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d8:	eb 74                	jmp    80064e <vprintfmt+0x3bb>
	if (lflag >= 2)
  8005da:	83 f9 01             	cmp    $0x1,%ecx
  8005dd:	7e 15                	jle    8005f4 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  8005df:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e2:	8b 10                	mov    (%eax),%edx
  8005e4:	8b 48 04             	mov    0x4(%eax),%ecx
  8005e7:	8d 40 08             	lea    0x8(%eax),%eax
  8005ea:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8005ed:	b8 08 00 00 00       	mov    $0x8,%eax
  8005f2:	eb 5a                	jmp    80064e <vprintfmt+0x3bb>
	else if (lflag)
  8005f4:	85 c9                	test   %ecx,%ecx
  8005f6:	75 17                	jne    80060f <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  8005f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fb:	8b 10                	mov    (%eax),%edx
  8005fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800602:	8d 40 04             	lea    0x4(%eax),%eax
  800605:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800608:	b8 08 00 00 00       	mov    $0x8,%eax
  80060d:	eb 3f                	jmp    80064e <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80060f:	8b 45 14             	mov    0x14(%ebp),%eax
  800612:	8b 10                	mov    (%eax),%edx
  800614:	b9 00 00 00 00       	mov    $0x0,%ecx
  800619:	8d 40 04             	lea    0x4(%eax),%eax
  80061c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80061f:	b8 08 00 00 00       	mov    $0x8,%eax
  800624:	eb 28                	jmp    80064e <vprintfmt+0x3bb>
			putch('0', putdat);
  800626:	83 ec 08             	sub    $0x8,%esp
  800629:	53                   	push   %ebx
  80062a:	6a 30                	push   $0x30
  80062c:	ff d6                	call   *%esi
			putch('x', putdat);
  80062e:	83 c4 08             	add    $0x8,%esp
  800631:	53                   	push   %ebx
  800632:	6a 78                	push   $0x78
  800634:	ff d6                	call   *%esi
			num = (unsigned long long)
  800636:	8b 45 14             	mov    0x14(%ebp),%eax
  800639:	8b 10                	mov    (%eax),%edx
  80063b:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800640:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800643:	8d 40 04             	lea    0x4(%eax),%eax
  800646:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800649:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80064e:	83 ec 0c             	sub    $0xc,%esp
  800651:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800655:	57                   	push   %edi
  800656:	ff 75 e0             	pushl  -0x20(%ebp)
  800659:	50                   	push   %eax
  80065a:	51                   	push   %ecx
  80065b:	52                   	push   %edx
  80065c:	89 da                	mov    %ebx,%edx
  80065e:	89 f0                	mov    %esi,%eax
  800660:	e8 45 fb ff ff       	call   8001aa <printnum>
			break;
  800665:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800668:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80066b:	83 c7 01             	add    $0x1,%edi
  80066e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800672:	83 f8 25             	cmp    $0x25,%eax
  800675:	0f 84 2f fc ff ff    	je     8002aa <vprintfmt+0x17>
			if (ch == '\0')
  80067b:	85 c0                	test   %eax,%eax
  80067d:	0f 84 8b 00 00 00    	je     80070e <vprintfmt+0x47b>
			putch(ch, putdat);
  800683:	83 ec 08             	sub    $0x8,%esp
  800686:	53                   	push   %ebx
  800687:	50                   	push   %eax
  800688:	ff d6                	call   *%esi
  80068a:	83 c4 10             	add    $0x10,%esp
  80068d:	eb dc                	jmp    80066b <vprintfmt+0x3d8>
	if (lflag >= 2)
  80068f:	83 f9 01             	cmp    $0x1,%ecx
  800692:	7e 15                	jle    8006a9 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  800694:	8b 45 14             	mov    0x14(%ebp),%eax
  800697:	8b 10                	mov    (%eax),%edx
  800699:	8b 48 04             	mov    0x4(%eax),%ecx
  80069c:	8d 40 08             	lea    0x8(%eax),%eax
  80069f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006a2:	b8 10 00 00 00       	mov    $0x10,%eax
  8006a7:	eb a5                	jmp    80064e <vprintfmt+0x3bb>
	else if (lflag)
  8006a9:	85 c9                	test   %ecx,%ecx
  8006ab:	75 17                	jne    8006c4 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  8006ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b0:	8b 10                	mov    (%eax),%edx
  8006b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b7:	8d 40 04             	lea    0x4(%eax),%eax
  8006ba:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006bd:	b8 10 00 00 00       	mov    $0x10,%eax
  8006c2:	eb 8a                	jmp    80064e <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8006c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c7:	8b 10                	mov    (%eax),%edx
  8006c9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ce:	8d 40 04             	lea    0x4(%eax),%eax
  8006d1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d4:	b8 10 00 00 00       	mov    $0x10,%eax
  8006d9:	e9 70 ff ff ff       	jmp    80064e <vprintfmt+0x3bb>
			putch(ch, putdat);
  8006de:	83 ec 08             	sub    $0x8,%esp
  8006e1:	53                   	push   %ebx
  8006e2:	6a 25                	push   $0x25
  8006e4:	ff d6                	call   *%esi
			break;
  8006e6:	83 c4 10             	add    $0x10,%esp
  8006e9:	e9 7a ff ff ff       	jmp    800668 <vprintfmt+0x3d5>
			putch('%', putdat);
  8006ee:	83 ec 08             	sub    $0x8,%esp
  8006f1:	53                   	push   %ebx
  8006f2:	6a 25                	push   $0x25
  8006f4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006f6:	83 c4 10             	add    $0x10,%esp
  8006f9:	89 f8                	mov    %edi,%eax
  8006fb:	eb 03                	jmp    800700 <vprintfmt+0x46d>
  8006fd:	83 e8 01             	sub    $0x1,%eax
  800700:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800704:	75 f7                	jne    8006fd <vprintfmt+0x46a>
  800706:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800709:	e9 5a ff ff ff       	jmp    800668 <vprintfmt+0x3d5>
}
  80070e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800711:	5b                   	pop    %ebx
  800712:	5e                   	pop    %esi
  800713:	5f                   	pop    %edi
  800714:	5d                   	pop    %ebp
  800715:	c3                   	ret    

00800716 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800716:	55                   	push   %ebp
  800717:	89 e5                	mov    %esp,%ebp
  800719:	83 ec 18             	sub    $0x18,%esp
  80071c:	8b 45 08             	mov    0x8(%ebp),%eax
  80071f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800722:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800725:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800729:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80072c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800733:	85 c0                	test   %eax,%eax
  800735:	74 26                	je     80075d <vsnprintf+0x47>
  800737:	85 d2                	test   %edx,%edx
  800739:	7e 22                	jle    80075d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80073b:	ff 75 14             	pushl  0x14(%ebp)
  80073e:	ff 75 10             	pushl  0x10(%ebp)
  800741:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800744:	50                   	push   %eax
  800745:	68 59 02 80 00       	push   $0x800259
  80074a:	e8 44 fb ff ff       	call   800293 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80074f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800752:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800755:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800758:	83 c4 10             	add    $0x10,%esp
}
  80075b:	c9                   	leave  
  80075c:	c3                   	ret    
		return -E_INVAL;
  80075d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800762:	eb f7                	jmp    80075b <vsnprintf+0x45>

00800764 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800764:	55                   	push   %ebp
  800765:	89 e5                	mov    %esp,%ebp
  800767:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80076a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80076d:	50                   	push   %eax
  80076e:	ff 75 10             	pushl  0x10(%ebp)
  800771:	ff 75 0c             	pushl  0xc(%ebp)
  800774:	ff 75 08             	pushl  0x8(%ebp)
  800777:	e8 9a ff ff ff       	call   800716 <vsnprintf>
	va_end(ap);

	return rc;
}
  80077c:	c9                   	leave  
  80077d:	c3                   	ret    

0080077e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80077e:	55                   	push   %ebp
  80077f:	89 e5                	mov    %esp,%ebp
  800781:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800784:	b8 00 00 00 00       	mov    $0x0,%eax
  800789:	eb 03                	jmp    80078e <strlen+0x10>
		n++;
  80078b:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80078e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800792:	75 f7                	jne    80078b <strlen+0xd>
	return n;
}
  800794:	5d                   	pop    %ebp
  800795:	c3                   	ret    

00800796 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079f:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a4:	eb 03                	jmp    8007a9 <strnlen+0x13>
		n++;
  8007a6:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a9:	39 d0                	cmp    %edx,%eax
  8007ab:	74 06                	je     8007b3 <strnlen+0x1d>
  8007ad:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007b1:	75 f3                	jne    8007a6 <strnlen+0x10>
	return n;
}
  8007b3:	5d                   	pop    %ebp
  8007b4:	c3                   	ret    

008007b5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007b5:	55                   	push   %ebp
  8007b6:	89 e5                	mov    %esp,%ebp
  8007b8:	53                   	push   %ebx
  8007b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007bf:	89 c2                	mov    %eax,%edx
  8007c1:	83 c1 01             	add    $0x1,%ecx
  8007c4:	83 c2 01             	add    $0x1,%edx
  8007c7:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007cb:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007ce:	84 db                	test   %bl,%bl
  8007d0:	75 ef                	jne    8007c1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007d2:	5b                   	pop    %ebx
  8007d3:	5d                   	pop    %ebp
  8007d4:	c3                   	ret    

008007d5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d5:	55                   	push   %ebp
  8007d6:	89 e5                	mov    %esp,%ebp
  8007d8:	53                   	push   %ebx
  8007d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007dc:	53                   	push   %ebx
  8007dd:	e8 9c ff ff ff       	call   80077e <strlen>
  8007e2:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007e5:	ff 75 0c             	pushl  0xc(%ebp)
  8007e8:	01 d8                	add    %ebx,%eax
  8007ea:	50                   	push   %eax
  8007eb:	e8 c5 ff ff ff       	call   8007b5 <strcpy>
	return dst;
}
  8007f0:	89 d8                	mov    %ebx,%eax
  8007f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f5:	c9                   	leave  
  8007f6:	c3                   	ret    

008007f7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007f7:	55                   	push   %ebp
  8007f8:	89 e5                	mov    %esp,%ebp
  8007fa:	56                   	push   %esi
  8007fb:	53                   	push   %ebx
  8007fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800802:	89 f3                	mov    %esi,%ebx
  800804:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800807:	89 f2                	mov    %esi,%edx
  800809:	eb 0f                	jmp    80081a <strncpy+0x23>
		*dst++ = *src;
  80080b:	83 c2 01             	add    $0x1,%edx
  80080e:	0f b6 01             	movzbl (%ecx),%eax
  800811:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800814:	80 39 01             	cmpb   $0x1,(%ecx)
  800817:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80081a:	39 da                	cmp    %ebx,%edx
  80081c:	75 ed                	jne    80080b <strncpy+0x14>
	}
	return ret;
}
  80081e:	89 f0                	mov    %esi,%eax
  800820:	5b                   	pop    %ebx
  800821:	5e                   	pop    %esi
  800822:	5d                   	pop    %ebp
  800823:	c3                   	ret    

00800824 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	56                   	push   %esi
  800828:	53                   	push   %ebx
  800829:	8b 75 08             	mov    0x8(%ebp),%esi
  80082c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80082f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800832:	89 f0                	mov    %esi,%eax
  800834:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800838:	85 c9                	test   %ecx,%ecx
  80083a:	75 0b                	jne    800847 <strlcpy+0x23>
  80083c:	eb 17                	jmp    800855 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80083e:	83 c2 01             	add    $0x1,%edx
  800841:	83 c0 01             	add    $0x1,%eax
  800844:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800847:	39 d8                	cmp    %ebx,%eax
  800849:	74 07                	je     800852 <strlcpy+0x2e>
  80084b:	0f b6 0a             	movzbl (%edx),%ecx
  80084e:	84 c9                	test   %cl,%cl
  800850:	75 ec                	jne    80083e <strlcpy+0x1a>
		*dst = '\0';
  800852:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800855:	29 f0                	sub    %esi,%eax
}
  800857:	5b                   	pop    %ebx
  800858:	5e                   	pop    %esi
  800859:	5d                   	pop    %ebp
  80085a:	c3                   	ret    

0080085b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800861:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800864:	eb 06                	jmp    80086c <strcmp+0x11>
		p++, q++;
  800866:	83 c1 01             	add    $0x1,%ecx
  800869:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80086c:	0f b6 01             	movzbl (%ecx),%eax
  80086f:	84 c0                	test   %al,%al
  800871:	74 04                	je     800877 <strcmp+0x1c>
  800873:	3a 02                	cmp    (%edx),%al
  800875:	74 ef                	je     800866 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800877:	0f b6 c0             	movzbl %al,%eax
  80087a:	0f b6 12             	movzbl (%edx),%edx
  80087d:	29 d0                	sub    %edx,%eax
}
  80087f:	5d                   	pop    %ebp
  800880:	c3                   	ret    

00800881 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800881:	55                   	push   %ebp
  800882:	89 e5                	mov    %esp,%ebp
  800884:	53                   	push   %ebx
  800885:	8b 45 08             	mov    0x8(%ebp),%eax
  800888:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088b:	89 c3                	mov    %eax,%ebx
  80088d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800890:	eb 06                	jmp    800898 <strncmp+0x17>
		n--, p++, q++;
  800892:	83 c0 01             	add    $0x1,%eax
  800895:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800898:	39 d8                	cmp    %ebx,%eax
  80089a:	74 16                	je     8008b2 <strncmp+0x31>
  80089c:	0f b6 08             	movzbl (%eax),%ecx
  80089f:	84 c9                	test   %cl,%cl
  8008a1:	74 04                	je     8008a7 <strncmp+0x26>
  8008a3:	3a 0a                	cmp    (%edx),%cl
  8008a5:	74 eb                	je     800892 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a7:	0f b6 00             	movzbl (%eax),%eax
  8008aa:	0f b6 12             	movzbl (%edx),%edx
  8008ad:	29 d0                	sub    %edx,%eax
}
  8008af:	5b                   	pop    %ebx
  8008b0:	5d                   	pop    %ebp
  8008b1:	c3                   	ret    
		return 0;
  8008b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b7:	eb f6                	jmp    8008af <strncmp+0x2e>

008008b9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c3:	0f b6 10             	movzbl (%eax),%edx
  8008c6:	84 d2                	test   %dl,%dl
  8008c8:	74 09                	je     8008d3 <strchr+0x1a>
		if (*s == c)
  8008ca:	38 ca                	cmp    %cl,%dl
  8008cc:	74 0a                	je     8008d8 <strchr+0x1f>
	for (; *s; s++)
  8008ce:	83 c0 01             	add    $0x1,%eax
  8008d1:	eb f0                	jmp    8008c3 <strchr+0xa>
			return (char *) s;
	return 0;
  8008d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008d8:	5d                   	pop    %ebp
  8008d9:	c3                   	ret    

008008da <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008da:	55                   	push   %ebp
  8008db:	89 e5                	mov    %esp,%ebp
  8008dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e4:	eb 03                	jmp    8008e9 <strfind+0xf>
  8008e6:	83 c0 01             	add    $0x1,%eax
  8008e9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008ec:	38 ca                	cmp    %cl,%dl
  8008ee:	74 04                	je     8008f4 <strfind+0x1a>
  8008f0:	84 d2                	test   %dl,%dl
  8008f2:	75 f2                	jne    8008e6 <strfind+0xc>
			break;
	return (char *) s;
}
  8008f4:	5d                   	pop    %ebp
  8008f5:	c3                   	ret    

008008f6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	57                   	push   %edi
  8008fa:	56                   	push   %esi
  8008fb:	53                   	push   %ebx
  8008fc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ff:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800902:	85 c9                	test   %ecx,%ecx
  800904:	74 13                	je     800919 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800906:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80090c:	75 05                	jne    800913 <memset+0x1d>
  80090e:	f6 c1 03             	test   $0x3,%cl
  800911:	74 0d                	je     800920 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800913:	8b 45 0c             	mov    0xc(%ebp),%eax
  800916:	fc                   	cld    
  800917:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800919:	89 f8                	mov    %edi,%eax
  80091b:	5b                   	pop    %ebx
  80091c:	5e                   	pop    %esi
  80091d:	5f                   	pop    %edi
  80091e:	5d                   	pop    %ebp
  80091f:	c3                   	ret    
		c &= 0xFF;
  800920:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800924:	89 d3                	mov    %edx,%ebx
  800926:	c1 e3 08             	shl    $0x8,%ebx
  800929:	89 d0                	mov    %edx,%eax
  80092b:	c1 e0 18             	shl    $0x18,%eax
  80092e:	89 d6                	mov    %edx,%esi
  800930:	c1 e6 10             	shl    $0x10,%esi
  800933:	09 f0                	or     %esi,%eax
  800935:	09 c2                	or     %eax,%edx
  800937:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800939:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80093c:	89 d0                	mov    %edx,%eax
  80093e:	fc                   	cld    
  80093f:	f3 ab                	rep stos %eax,%es:(%edi)
  800941:	eb d6                	jmp    800919 <memset+0x23>

00800943 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800943:	55                   	push   %ebp
  800944:	89 e5                	mov    %esp,%ebp
  800946:	57                   	push   %edi
  800947:	56                   	push   %esi
  800948:	8b 45 08             	mov    0x8(%ebp),%eax
  80094b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80094e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800951:	39 c6                	cmp    %eax,%esi
  800953:	73 35                	jae    80098a <memmove+0x47>
  800955:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800958:	39 c2                	cmp    %eax,%edx
  80095a:	76 2e                	jbe    80098a <memmove+0x47>
		s += n;
		d += n;
  80095c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80095f:	89 d6                	mov    %edx,%esi
  800961:	09 fe                	or     %edi,%esi
  800963:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800969:	74 0c                	je     800977 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80096b:	83 ef 01             	sub    $0x1,%edi
  80096e:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800971:	fd                   	std    
  800972:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800974:	fc                   	cld    
  800975:	eb 21                	jmp    800998 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800977:	f6 c1 03             	test   $0x3,%cl
  80097a:	75 ef                	jne    80096b <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80097c:	83 ef 04             	sub    $0x4,%edi
  80097f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800982:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800985:	fd                   	std    
  800986:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800988:	eb ea                	jmp    800974 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098a:	89 f2                	mov    %esi,%edx
  80098c:	09 c2                	or     %eax,%edx
  80098e:	f6 c2 03             	test   $0x3,%dl
  800991:	74 09                	je     80099c <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800993:	89 c7                	mov    %eax,%edi
  800995:	fc                   	cld    
  800996:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800998:	5e                   	pop    %esi
  800999:	5f                   	pop    %edi
  80099a:	5d                   	pop    %ebp
  80099b:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099c:	f6 c1 03             	test   $0x3,%cl
  80099f:	75 f2                	jne    800993 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009a1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009a4:	89 c7                	mov    %eax,%edi
  8009a6:	fc                   	cld    
  8009a7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a9:	eb ed                	jmp    800998 <memmove+0x55>

008009ab <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009ae:	ff 75 10             	pushl  0x10(%ebp)
  8009b1:	ff 75 0c             	pushl  0xc(%ebp)
  8009b4:	ff 75 08             	pushl  0x8(%ebp)
  8009b7:	e8 87 ff ff ff       	call   800943 <memmove>
}
  8009bc:	c9                   	leave  
  8009bd:	c3                   	ret    

008009be <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009be:	55                   	push   %ebp
  8009bf:	89 e5                	mov    %esp,%ebp
  8009c1:	56                   	push   %esi
  8009c2:	53                   	push   %ebx
  8009c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c9:	89 c6                	mov    %eax,%esi
  8009cb:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ce:	39 f0                	cmp    %esi,%eax
  8009d0:	74 1c                	je     8009ee <memcmp+0x30>
		if (*s1 != *s2)
  8009d2:	0f b6 08             	movzbl (%eax),%ecx
  8009d5:	0f b6 1a             	movzbl (%edx),%ebx
  8009d8:	38 d9                	cmp    %bl,%cl
  8009da:	75 08                	jne    8009e4 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009dc:	83 c0 01             	add    $0x1,%eax
  8009df:	83 c2 01             	add    $0x1,%edx
  8009e2:	eb ea                	jmp    8009ce <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8009e4:	0f b6 c1             	movzbl %cl,%eax
  8009e7:	0f b6 db             	movzbl %bl,%ebx
  8009ea:	29 d8                	sub    %ebx,%eax
  8009ec:	eb 05                	jmp    8009f3 <memcmp+0x35>
	}

	return 0;
  8009ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f3:	5b                   	pop    %ebx
  8009f4:	5e                   	pop    %esi
  8009f5:	5d                   	pop    %ebp
  8009f6:	c3                   	ret    

008009f7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a00:	89 c2                	mov    %eax,%edx
  800a02:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a05:	39 d0                	cmp    %edx,%eax
  800a07:	73 09                	jae    800a12 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a09:	38 08                	cmp    %cl,(%eax)
  800a0b:	74 05                	je     800a12 <memfind+0x1b>
	for (; s < ends; s++)
  800a0d:	83 c0 01             	add    $0x1,%eax
  800a10:	eb f3                	jmp    800a05 <memfind+0xe>
			break;
	return (void *) s;
}
  800a12:	5d                   	pop    %ebp
  800a13:	c3                   	ret    

00800a14 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	57                   	push   %edi
  800a18:	56                   	push   %esi
  800a19:	53                   	push   %ebx
  800a1a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a1d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a20:	eb 03                	jmp    800a25 <strtol+0x11>
		s++;
  800a22:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a25:	0f b6 01             	movzbl (%ecx),%eax
  800a28:	3c 20                	cmp    $0x20,%al
  800a2a:	74 f6                	je     800a22 <strtol+0xe>
  800a2c:	3c 09                	cmp    $0x9,%al
  800a2e:	74 f2                	je     800a22 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a30:	3c 2b                	cmp    $0x2b,%al
  800a32:	74 2e                	je     800a62 <strtol+0x4e>
	int neg = 0;
  800a34:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a39:	3c 2d                	cmp    $0x2d,%al
  800a3b:	74 2f                	je     800a6c <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a3d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a43:	75 05                	jne    800a4a <strtol+0x36>
  800a45:	80 39 30             	cmpb   $0x30,(%ecx)
  800a48:	74 2c                	je     800a76 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a4a:	85 db                	test   %ebx,%ebx
  800a4c:	75 0a                	jne    800a58 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a4e:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a53:	80 39 30             	cmpb   $0x30,(%ecx)
  800a56:	74 28                	je     800a80 <strtol+0x6c>
		base = 10;
  800a58:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5d:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a60:	eb 50                	jmp    800ab2 <strtol+0x9e>
		s++;
  800a62:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a65:	bf 00 00 00 00       	mov    $0x0,%edi
  800a6a:	eb d1                	jmp    800a3d <strtol+0x29>
		s++, neg = 1;
  800a6c:	83 c1 01             	add    $0x1,%ecx
  800a6f:	bf 01 00 00 00       	mov    $0x1,%edi
  800a74:	eb c7                	jmp    800a3d <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a76:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a7a:	74 0e                	je     800a8a <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a7c:	85 db                	test   %ebx,%ebx
  800a7e:	75 d8                	jne    800a58 <strtol+0x44>
		s++, base = 8;
  800a80:	83 c1 01             	add    $0x1,%ecx
  800a83:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a88:	eb ce                	jmp    800a58 <strtol+0x44>
		s += 2, base = 16;
  800a8a:	83 c1 02             	add    $0x2,%ecx
  800a8d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a92:	eb c4                	jmp    800a58 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800a94:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a97:	89 f3                	mov    %esi,%ebx
  800a99:	80 fb 19             	cmp    $0x19,%bl
  800a9c:	77 29                	ja     800ac7 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800a9e:	0f be d2             	movsbl %dl,%edx
  800aa1:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800aa4:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aa7:	7d 30                	jge    800ad9 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800aa9:	83 c1 01             	add    $0x1,%ecx
  800aac:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ab0:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ab2:	0f b6 11             	movzbl (%ecx),%edx
  800ab5:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ab8:	89 f3                	mov    %esi,%ebx
  800aba:	80 fb 09             	cmp    $0x9,%bl
  800abd:	77 d5                	ja     800a94 <strtol+0x80>
			dig = *s - '0';
  800abf:	0f be d2             	movsbl %dl,%edx
  800ac2:	83 ea 30             	sub    $0x30,%edx
  800ac5:	eb dd                	jmp    800aa4 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800ac7:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aca:	89 f3                	mov    %esi,%ebx
  800acc:	80 fb 19             	cmp    $0x19,%bl
  800acf:	77 08                	ja     800ad9 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800ad1:	0f be d2             	movsbl %dl,%edx
  800ad4:	83 ea 37             	sub    $0x37,%edx
  800ad7:	eb cb                	jmp    800aa4 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ad9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800add:	74 05                	je     800ae4 <strtol+0xd0>
		*endptr = (char *) s;
  800adf:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae2:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ae4:	89 c2                	mov    %eax,%edx
  800ae6:	f7 da                	neg    %edx
  800ae8:	85 ff                	test   %edi,%edi
  800aea:	0f 45 c2             	cmovne %edx,%eax
}
  800aed:	5b                   	pop    %ebx
  800aee:	5e                   	pop    %esi
  800aef:	5f                   	pop    %edi
  800af0:	5d                   	pop    %ebp
  800af1:	c3                   	ret    

00800af2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	57                   	push   %edi
  800af6:	56                   	push   %esi
  800af7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800af8:	b8 00 00 00 00       	mov    $0x0,%eax
  800afd:	8b 55 08             	mov    0x8(%ebp),%edx
  800b00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b03:	89 c3                	mov    %eax,%ebx
  800b05:	89 c7                	mov    %eax,%edi
  800b07:	89 c6                	mov    %eax,%esi
  800b09:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b0b:	5b                   	pop    %ebx
  800b0c:	5e                   	pop    %esi
  800b0d:	5f                   	pop    %edi
  800b0e:	5d                   	pop    %ebp
  800b0f:	c3                   	ret    

00800b10 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b10:	55                   	push   %ebp
  800b11:	89 e5                	mov    %esp,%ebp
  800b13:	57                   	push   %edi
  800b14:	56                   	push   %esi
  800b15:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b16:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b20:	89 d1                	mov    %edx,%ecx
  800b22:	89 d3                	mov    %edx,%ebx
  800b24:	89 d7                	mov    %edx,%edi
  800b26:	89 d6                	mov    %edx,%esi
  800b28:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b2a:	5b                   	pop    %ebx
  800b2b:	5e                   	pop    %esi
  800b2c:	5f                   	pop    %edi
  800b2d:	5d                   	pop    %ebp
  800b2e:	c3                   	ret    

00800b2f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	57                   	push   %edi
  800b33:	56                   	push   %esi
  800b34:	53                   	push   %ebx
  800b35:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b38:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b40:	b8 03 00 00 00       	mov    $0x3,%eax
  800b45:	89 cb                	mov    %ecx,%ebx
  800b47:	89 cf                	mov    %ecx,%edi
  800b49:	89 ce                	mov    %ecx,%esi
  800b4b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b4d:	85 c0                	test   %eax,%eax
  800b4f:	7f 08                	jg     800b59 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b54:	5b                   	pop    %ebx
  800b55:	5e                   	pop    %esi
  800b56:	5f                   	pop    %edi
  800b57:	5d                   	pop    %ebp
  800b58:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b59:	83 ec 0c             	sub    $0xc,%esp
  800b5c:	50                   	push   %eax
  800b5d:	6a 03                	push   $0x3
  800b5f:	68 5f 21 80 00       	push   $0x80215f
  800b64:	6a 23                	push   $0x23
  800b66:	68 7c 21 80 00       	push   $0x80217c
  800b6b:	e8 ee 0f 00 00       	call   801b5e <_panic>

00800b70 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b70:	55                   	push   %ebp
  800b71:	89 e5                	mov    %esp,%ebp
  800b73:	57                   	push   %edi
  800b74:	56                   	push   %esi
  800b75:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b76:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7b:	b8 02 00 00 00       	mov    $0x2,%eax
  800b80:	89 d1                	mov    %edx,%ecx
  800b82:	89 d3                	mov    %edx,%ebx
  800b84:	89 d7                	mov    %edx,%edi
  800b86:	89 d6                	mov    %edx,%esi
  800b88:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b8a:	5b                   	pop    %ebx
  800b8b:	5e                   	pop    %esi
  800b8c:	5f                   	pop    %edi
  800b8d:	5d                   	pop    %ebp
  800b8e:	c3                   	ret    

00800b8f <sys_yield>:

void
sys_yield(void)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	57                   	push   %edi
  800b93:	56                   	push   %esi
  800b94:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b95:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b9f:	89 d1                	mov    %edx,%ecx
  800ba1:	89 d3                	mov    %edx,%ebx
  800ba3:	89 d7                	mov    %edx,%edi
  800ba5:	89 d6                	mov    %edx,%esi
  800ba7:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ba9:	5b                   	pop    %ebx
  800baa:	5e                   	pop    %esi
  800bab:	5f                   	pop    %edi
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	57                   	push   %edi
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
  800bb4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bb7:	be 00 00 00 00       	mov    $0x0,%esi
  800bbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc2:	b8 04 00 00 00       	mov    $0x4,%eax
  800bc7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bca:	89 f7                	mov    %esi,%edi
  800bcc:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bce:	85 c0                	test   %eax,%eax
  800bd0:	7f 08                	jg     800bda <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd5:	5b                   	pop    %ebx
  800bd6:	5e                   	pop    %esi
  800bd7:	5f                   	pop    %edi
  800bd8:	5d                   	pop    %ebp
  800bd9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bda:	83 ec 0c             	sub    $0xc,%esp
  800bdd:	50                   	push   %eax
  800bde:	6a 04                	push   $0x4
  800be0:	68 5f 21 80 00       	push   $0x80215f
  800be5:	6a 23                	push   $0x23
  800be7:	68 7c 21 80 00       	push   $0x80217c
  800bec:	e8 6d 0f 00 00       	call   801b5e <_panic>

00800bf1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	57                   	push   %edi
  800bf5:	56                   	push   %esi
  800bf6:	53                   	push   %ebx
  800bf7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c00:	b8 05 00 00 00       	mov    $0x5,%eax
  800c05:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c08:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c0b:	8b 75 18             	mov    0x18(%ebp),%esi
  800c0e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c10:	85 c0                	test   %eax,%eax
  800c12:	7f 08                	jg     800c1c <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c17:	5b                   	pop    %ebx
  800c18:	5e                   	pop    %esi
  800c19:	5f                   	pop    %edi
  800c1a:	5d                   	pop    %ebp
  800c1b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1c:	83 ec 0c             	sub    $0xc,%esp
  800c1f:	50                   	push   %eax
  800c20:	6a 05                	push   $0x5
  800c22:	68 5f 21 80 00       	push   $0x80215f
  800c27:	6a 23                	push   $0x23
  800c29:	68 7c 21 80 00       	push   $0x80217c
  800c2e:	e8 2b 0f 00 00       	call   801b5e <_panic>

00800c33 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	57                   	push   %edi
  800c37:	56                   	push   %esi
  800c38:	53                   	push   %ebx
  800c39:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c3c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c41:	8b 55 08             	mov    0x8(%ebp),%edx
  800c44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c47:	b8 06 00 00 00       	mov    $0x6,%eax
  800c4c:	89 df                	mov    %ebx,%edi
  800c4e:	89 de                	mov    %ebx,%esi
  800c50:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c52:	85 c0                	test   %eax,%eax
  800c54:	7f 08                	jg     800c5e <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c59:	5b                   	pop    %ebx
  800c5a:	5e                   	pop    %esi
  800c5b:	5f                   	pop    %edi
  800c5c:	5d                   	pop    %ebp
  800c5d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5e:	83 ec 0c             	sub    $0xc,%esp
  800c61:	50                   	push   %eax
  800c62:	6a 06                	push   $0x6
  800c64:	68 5f 21 80 00       	push   $0x80215f
  800c69:	6a 23                	push   $0x23
  800c6b:	68 7c 21 80 00       	push   $0x80217c
  800c70:	e8 e9 0e 00 00       	call   801b5e <_panic>

00800c75 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	57                   	push   %edi
  800c79:	56                   	push   %esi
  800c7a:	53                   	push   %ebx
  800c7b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c7e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c83:	8b 55 08             	mov    0x8(%ebp),%edx
  800c86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c89:	b8 08 00 00 00       	mov    $0x8,%eax
  800c8e:	89 df                	mov    %ebx,%edi
  800c90:	89 de                	mov    %ebx,%esi
  800c92:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c94:	85 c0                	test   %eax,%eax
  800c96:	7f 08                	jg     800ca0 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9b:	5b                   	pop    %ebx
  800c9c:	5e                   	pop    %esi
  800c9d:	5f                   	pop    %edi
  800c9e:	5d                   	pop    %ebp
  800c9f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca0:	83 ec 0c             	sub    $0xc,%esp
  800ca3:	50                   	push   %eax
  800ca4:	6a 08                	push   $0x8
  800ca6:	68 5f 21 80 00       	push   $0x80215f
  800cab:	6a 23                	push   $0x23
  800cad:	68 7c 21 80 00       	push   $0x80217c
  800cb2:	e8 a7 0e 00 00       	call   801b5e <_panic>

00800cb7 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
  800cba:	57                   	push   %edi
  800cbb:	56                   	push   %esi
  800cbc:	53                   	push   %ebx
  800cbd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cc0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccb:	b8 09 00 00 00       	mov    $0x9,%eax
  800cd0:	89 df                	mov    %ebx,%edi
  800cd2:	89 de                	mov    %ebx,%esi
  800cd4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cd6:	85 c0                	test   %eax,%eax
  800cd8:	7f 08                	jg     800ce2 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdd:	5b                   	pop    %ebx
  800cde:	5e                   	pop    %esi
  800cdf:	5f                   	pop    %edi
  800ce0:	5d                   	pop    %ebp
  800ce1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce2:	83 ec 0c             	sub    $0xc,%esp
  800ce5:	50                   	push   %eax
  800ce6:	6a 09                	push   $0x9
  800ce8:	68 5f 21 80 00       	push   $0x80215f
  800ced:	6a 23                	push   $0x23
  800cef:	68 7c 21 80 00       	push   $0x80217c
  800cf4:	e8 65 0e 00 00       	call   801b5e <_panic>

00800cf9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
  800cfc:	57                   	push   %edi
  800cfd:	56                   	push   %esi
  800cfe:	53                   	push   %ebx
  800cff:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d02:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d07:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d12:	89 df                	mov    %ebx,%edi
  800d14:	89 de                	mov    %ebx,%esi
  800d16:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d18:	85 c0                	test   %eax,%eax
  800d1a:	7f 08                	jg     800d24 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1f:	5b                   	pop    %ebx
  800d20:	5e                   	pop    %esi
  800d21:	5f                   	pop    %edi
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d24:	83 ec 0c             	sub    $0xc,%esp
  800d27:	50                   	push   %eax
  800d28:	6a 0a                	push   $0xa
  800d2a:	68 5f 21 80 00       	push   $0x80215f
  800d2f:	6a 23                	push   $0x23
  800d31:	68 7c 21 80 00       	push   $0x80217c
  800d36:	e8 23 0e 00 00       	call   801b5e <_panic>

00800d3b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	57                   	push   %edi
  800d3f:	56                   	push   %esi
  800d40:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d41:	8b 55 08             	mov    0x8(%ebp),%edx
  800d44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d47:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d4c:	be 00 00 00 00       	mov    $0x0,%esi
  800d51:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d54:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d57:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d59:	5b                   	pop    %ebx
  800d5a:	5e                   	pop    %esi
  800d5b:	5f                   	pop    %edi
  800d5c:	5d                   	pop    %ebp
  800d5d:	c3                   	ret    

00800d5e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
  800d61:	57                   	push   %edi
  800d62:	56                   	push   %esi
  800d63:	53                   	push   %ebx
  800d64:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d67:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d74:	89 cb                	mov    %ecx,%ebx
  800d76:	89 cf                	mov    %ecx,%edi
  800d78:	89 ce                	mov    %ecx,%esi
  800d7a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d7c:	85 c0                	test   %eax,%eax
  800d7e:	7f 08                	jg     800d88 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d83:	5b                   	pop    %ebx
  800d84:	5e                   	pop    %esi
  800d85:	5f                   	pop    %edi
  800d86:	5d                   	pop    %ebp
  800d87:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d88:	83 ec 0c             	sub    $0xc,%esp
  800d8b:	50                   	push   %eax
  800d8c:	6a 0d                	push   $0xd
  800d8e:	68 5f 21 80 00       	push   $0x80215f
  800d93:	6a 23                	push   $0x23
  800d95:	68 7c 21 80 00       	push   $0x80217c
  800d9a:	e8 bf 0d 00 00       	call   801b5e <_panic>

00800d9f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800d9f:	55                   	push   %ebp
  800da0:	89 e5                	mov    %esp,%ebp
  800da2:	56                   	push   %esi
  800da3:	53                   	push   %ebx
  800da4:	8b 75 08             	mov    0x8(%ebp),%esi
  800da7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800daa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        //	panic("ipc_recv not implemented");
        int r;
       	if(pg!=NULL){
  800dad:	85 c0                	test   %eax,%eax
  800daf:	74 3b                	je     800dec <ipc_recv+0x4d>
	  r = sys_ipc_recv(pg);
  800db1:	83 ec 0c             	sub    $0xc,%esp
  800db4:	50                   	push   %eax
  800db5:	e8 a4 ff ff ff       	call   800d5e <sys_ipc_recv>
  800dba:	83 c4 10             	add    $0x10,%esp
	}else
	  r = sys_ipc_recv((void *)UTOP);
	if(r<0){
  800dbd:	85 c0                	test   %eax,%eax
  800dbf:	78 3d                	js     800dfe <ipc_recv+0x5f>
	if(perm_store!=NULL){
		*perm_store = 0;
            }
        	return r;
           }else{
	     if(from_env_store!=NULL)
  800dc1:	85 f6                	test   %esi,%esi
  800dc3:	74 0a                	je     800dcf <ipc_recv+0x30>
		     *from_env_store = thisenv->env_ipc_from;
  800dc5:	a1 04 40 80 00       	mov    0x804004,%eax
  800dca:	8b 40 74             	mov    0x74(%eax),%eax
  800dcd:	89 06                	mov    %eax,(%esi)
	     if(perm_store != NULL)
  800dcf:	85 db                	test   %ebx,%ebx
  800dd1:	74 0a                	je     800ddd <ipc_recv+0x3e>
		     *perm_store = thisenv->env_ipc_perm;
  800dd3:	a1 04 40 80 00       	mov    0x804004,%eax
  800dd8:	8b 40 78             	mov    0x78(%eax),%eax
  800ddb:	89 03                	mov    %eax,(%ebx)
	     return thisenv->env_ipc_value;
  800ddd:	a1 04 40 80 00       	mov    0x804004,%eax
  800de2:	8b 40 70             	mov    0x70(%eax),%eax
	   }

}
  800de5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800de8:	5b                   	pop    %ebx
  800de9:	5e                   	pop    %esi
  800dea:	5d                   	pop    %ebp
  800deb:	c3                   	ret    
	  r = sys_ipc_recv((void *)UTOP);
  800dec:	83 ec 0c             	sub    $0xc,%esp
  800def:	68 00 00 c0 ee       	push   $0xeec00000
  800df4:	e8 65 ff ff ff       	call   800d5e <sys_ipc_recv>
  800df9:	83 c4 10             	add    $0x10,%esp
  800dfc:	eb bf                	jmp    800dbd <ipc_recv+0x1e>
	if(from_env_store!=NULL){
  800dfe:	85 f6                	test   %esi,%esi
  800e00:	74 06                	je     800e08 <ipc_recv+0x69>
	  *from_env_store = 0;
  800e02:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if(perm_store!=NULL){
  800e08:	85 db                	test   %ebx,%ebx
  800e0a:	74 d9                	je     800de5 <ipc_recv+0x46>
		*perm_store = 0;
  800e0c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800e12:	eb d1                	jmp    800de5 <ipc_recv+0x46>

00800e14 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800e14:	55                   	push   %ebp
  800e15:	89 e5                	mov    %esp,%ebp
  800e17:	57                   	push   %edi
  800e18:	56                   	push   %esi
  800e19:	53                   	push   %ebx
  800e1a:	83 ec 0c             	sub    $0xc,%esp
  800e1d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e20:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e23:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if(pg==NULL) pg = (void *)UTOP;
  800e26:	85 db                	test   %ebx,%ebx
  800e28:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  800e2d:	0f 44 d8             	cmove  %eax,%ebx
	while((r=sys_ipc_try_send(to_env,val,pg,perm))<0){
  800e30:	ff 75 14             	pushl  0x14(%ebp)
  800e33:	53                   	push   %ebx
  800e34:	56                   	push   %esi
  800e35:	57                   	push   %edi
  800e36:	e8 00 ff ff ff       	call   800d3b <sys_ipc_try_send>
  800e3b:	83 c4 10             	add    $0x10,%esp
  800e3e:	85 c0                	test   %eax,%eax
  800e40:	79 20                	jns    800e62 <ipc_send+0x4e>
	    if(r!=-E_IPC_NOT_RECV){
  800e42:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800e45:	75 07                	jne    800e4e <ipc_send+0x3a>
		    panic("ipc_send:send message failed\n");
	    }
	    sys_yield();
  800e47:	e8 43 fd ff ff       	call   800b8f <sys_yield>
  800e4c:	eb e2                	jmp    800e30 <ipc_send+0x1c>
		    panic("ipc_send:send message failed\n");
  800e4e:	83 ec 04             	sub    $0x4,%esp
  800e51:	68 8a 21 80 00       	push   $0x80218a
  800e56:	6a 43                	push   $0x43
  800e58:	68 a8 21 80 00       	push   $0x8021a8
  800e5d:	e8 fc 0c 00 00       	call   801b5e <_panic>
	}

}
  800e62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e65:	5b                   	pop    %ebx
  800e66:	5e                   	pop    %esi
  800e67:	5f                   	pop    %edi
  800e68:	5d                   	pop    %ebp
  800e69:	c3                   	ret    

00800e6a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800e6a:	55                   	push   %ebp
  800e6b:	89 e5                	mov    %esp,%ebp
  800e6d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800e70:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800e75:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800e78:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800e7e:	8b 52 50             	mov    0x50(%edx),%edx
  800e81:	39 ca                	cmp    %ecx,%edx
  800e83:	74 11                	je     800e96 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  800e85:	83 c0 01             	add    $0x1,%eax
  800e88:	3d 00 04 00 00       	cmp    $0x400,%eax
  800e8d:	75 e6                	jne    800e75 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  800e8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e94:	eb 0b                	jmp    800ea1 <ipc_find_env+0x37>
			return envs[i].env_id;
  800e96:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e99:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e9e:	8b 40 48             	mov    0x48(%eax),%eax
}
  800ea1:	5d                   	pop    %ebp
  800ea2:	c3                   	ret    

00800ea3 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ea3:	55                   	push   %ebp
  800ea4:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ea6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea9:	05 00 00 00 30       	add    $0x30000000,%eax
  800eae:	c1 e8 0c             	shr    $0xc,%eax
}
  800eb1:	5d                   	pop    %ebp
  800eb2:	c3                   	ret    

00800eb3 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800eb3:	55                   	push   %ebp
  800eb4:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800eb6:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb9:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800ebe:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ec3:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ec8:	5d                   	pop    %ebp
  800ec9:	c3                   	ret    

00800eca <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800eca:	55                   	push   %ebp
  800ecb:	89 e5                	mov    %esp,%ebp
  800ecd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ed0:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ed5:	89 c2                	mov    %eax,%edx
  800ed7:	c1 ea 16             	shr    $0x16,%edx
  800eda:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ee1:	f6 c2 01             	test   $0x1,%dl
  800ee4:	74 2a                	je     800f10 <fd_alloc+0x46>
  800ee6:	89 c2                	mov    %eax,%edx
  800ee8:	c1 ea 0c             	shr    $0xc,%edx
  800eeb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ef2:	f6 c2 01             	test   $0x1,%dl
  800ef5:	74 19                	je     800f10 <fd_alloc+0x46>
  800ef7:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800efc:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f01:	75 d2                	jne    800ed5 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f03:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f09:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800f0e:	eb 07                	jmp    800f17 <fd_alloc+0x4d>
			*fd_store = fd;
  800f10:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f12:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f17:	5d                   	pop    %ebp
  800f18:	c3                   	ret    

00800f19 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f19:	55                   	push   %ebp
  800f1a:	89 e5                	mov    %esp,%ebp
  800f1c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f1f:	83 f8 1f             	cmp    $0x1f,%eax
  800f22:	77 36                	ja     800f5a <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f24:	c1 e0 0c             	shl    $0xc,%eax
  800f27:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f2c:	89 c2                	mov    %eax,%edx
  800f2e:	c1 ea 16             	shr    $0x16,%edx
  800f31:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f38:	f6 c2 01             	test   $0x1,%dl
  800f3b:	74 24                	je     800f61 <fd_lookup+0x48>
  800f3d:	89 c2                	mov    %eax,%edx
  800f3f:	c1 ea 0c             	shr    $0xc,%edx
  800f42:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f49:	f6 c2 01             	test   $0x1,%dl
  800f4c:	74 1a                	je     800f68 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f4e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f51:	89 02                	mov    %eax,(%edx)
	return 0;
  800f53:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f58:	5d                   	pop    %ebp
  800f59:	c3                   	ret    
		return -E_INVAL;
  800f5a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f5f:	eb f7                	jmp    800f58 <fd_lookup+0x3f>
		return -E_INVAL;
  800f61:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f66:	eb f0                	jmp    800f58 <fd_lookup+0x3f>
  800f68:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f6d:	eb e9                	jmp    800f58 <fd_lookup+0x3f>

00800f6f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f6f:	55                   	push   %ebp
  800f70:	89 e5                	mov    %esp,%ebp
  800f72:	83 ec 08             	sub    $0x8,%esp
  800f75:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f78:	ba 30 22 80 00       	mov    $0x802230,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f7d:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800f82:	39 08                	cmp    %ecx,(%eax)
  800f84:	74 33                	je     800fb9 <dev_lookup+0x4a>
  800f86:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800f89:	8b 02                	mov    (%edx),%eax
  800f8b:	85 c0                	test   %eax,%eax
  800f8d:	75 f3                	jne    800f82 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f8f:	a1 04 40 80 00       	mov    0x804004,%eax
  800f94:	8b 40 48             	mov    0x48(%eax),%eax
  800f97:	83 ec 04             	sub    $0x4,%esp
  800f9a:	51                   	push   %ecx
  800f9b:	50                   	push   %eax
  800f9c:	68 b4 21 80 00       	push   $0x8021b4
  800fa1:	e8 f0 f1 ff ff       	call   800196 <cprintf>
	*dev = 0;
  800fa6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fa9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800faf:	83 c4 10             	add    $0x10,%esp
  800fb2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fb7:	c9                   	leave  
  800fb8:	c3                   	ret    
			*dev = devtab[i];
  800fb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fbc:	89 01                	mov    %eax,(%ecx)
			return 0;
  800fbe:	b8 00 00 00 00       	mov    $0x0,%eax
  800fc3:	eb f2                	jmp    800fb7 <dev_lookup+0x48>

00800fc5 <fd_close>:
{
  800fc5:	55                   	push   %ebp
  800fc6:	89 e5                	mov    %esp,%ebp
  800fc8:	57                   	push   %edi
  800fc9:	56                   	push   %esi
  800fca:	53                   	push   %ebx
  800fcb:	83 ec 1c             	sub    $0x1c,%esp
  800fce:	8b 75 08             	mov    0x8(%ebp),%esi
  800fd1:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fd4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fd7:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fd8:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fde:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fe1:	50                   	push   %eax
  800fe2:	e8 32 ff ff ff       	call   800f19 <fd_lookup>
  800fe7:	89 c3                	mov    %eax,%ebx
  800fe9:	83 c4 08             	add    $0x8,%esp
  800fec:	85 c0                	test   %eax,%eax
  800fee:	78 05                	js     800ff5 <fd_close+0x30>
	    || fd != fd2)
  800ff0:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800ff3:	74 16                	je     80100b <fd_close+0x46>
		return (must_exist ? r : 0);
  800ff5:	89 f8                	mov    %edi,%eax
  800ff7:	84 c0                	test   %al,%al
  800ff9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ffe:	0f 44 d8             	cmove  %eax,%ebx
}
  801001:	89 d8                	mov    %ebx,%eax
  801003:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801006:	5b                   	pop    %ebx
  801007:	5e                   	pop    %esi
  801008:	5f                   	pop    %edi
  801009:	5d                   	pop    %ebp
  80100a:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80100b:	83 ec 08             	sub    $0x8,%esp
  80100e:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801011:	50                   	push   %eax
  801012:	ff 36                	pushl  (%esi)
  801014:	e8 56 ff ff ff       	call   800f6f <dev_lookup>
  801019:	89 c3                	mov    %eax,%ebx
  80101b:	83 c4 10             	add    $0x10,%esp
  80101e:	85 c0                	test   %eax,%eax
  801020:	78 15                	js     801037 <fd_close+0x72>
		if (dev->dev_close)
  801022:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801025:	8b 40 10             	mov    0x10(%eax),%eax
  801028:	85 c0                	test   %eax,%eax
  80102a:	74 1b                	je     801047 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  80102c:	83 ec 0c             	sub    $0xc,%esp
  80102f:	56                   	push   %esi
  801030:	ff d0                	call   *%eax
  801032:	89 c3                	mov    %eax,%ebx
  801034:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801037:	83 ec 08             	sub    $0x8,%esp
  80103a:	56                   	push   %esi
  80103b:	6a 00                	push   $0x0
  80103d:	e8 f1 fb ff ff       	call   800c33 <sys_page_unmap>
	return r;
  801042:	83 c4 10             	add    $0x10,%esp
  801045:	eb ba                	jmp    801001 <fd_close+0x3c>
			r = 0;
  801047:	bb 00 00 00 00       	mov    $0x0,%ebx
  80104c:	eb e9                	jmp    801037 <fd_close+0x72>

0080104e <close>:

int
close(int fdnum)
{
  80104e:	55                   	push   %ebp
  80104f:	89 e5                	mov    %esp,%ebp
  801051:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801054:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801057:	50                   	push   %eax
  801058:	ff 75 08             	pushl  0x8(%ebp)
  80105b:	e8 b9 fe ff ff       	call   800f19 <fd_lookup>
  801060:	83 c4 08             	add    $0x8,%esp
  801063:	85 c0                	test   %eax,%eax
  801065:	78 10                	js     801077 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801067:	83 ec 08             	sub    $0x8,%esp
  80106a:	6a 01                	push   $0x1
  80106c:	ff 75 f4             	pushl  -0xc(%ebp)
  80106f:	e8 51 ff ff ff       	call   800fc5 <fd_close>
  801074:	83 c4 10             	add    $0x10,%esp
}
  801077:	c9                   	leave  
  801078:	c3                   	ret    

00801079 <close_all>:

void
close_all(void)
{
  801079:	55                   	push   %ebp
  80107a:	89 e5                	mov    %esp,%ebp
  80107c:	53                   	push   %ebx
  80107d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801080:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801085:	83 ec 0c             	sub    $0xc,%esp
  801088:	53                   	push   %ebx
  801089:	e8 c0 ff ff ff       	call   80104e <close>
	for (i = 0; i < MAXFD; i++)
  80108e:	83 c3 01             	add    $0x1,%ebx
  801091:	83 c4 10             	add    $0x10,%esp
  801094:	83 fb 20             	cmp    $0x20,%ebx
  801097:	75 ec                	jne    801085 <close_all+0xc>
}
  801099:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80109c:	c9                   	leave  
  80109d:	c3                   	ret    

0080109e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80109e:	55                   	push   %ebp
  80109f:	89 e5                	mov    %esp,%ebp
  8010a1:	57                   	push   %edi
  8010a2:	56                   	push   %esi
  8010a3:	53                   	push   %ebx
  8010a4:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010a7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010aa:	50                   	push   %eax
  8010ab:	ff 75 08             	pushl  0x8(%ebp)
  8010ae:	e8 66 fe ff ff       	call   800f19 <fd_lookup>
  8010b3:	89 c3                	mov    %eax,%ebx
  8010b5:	83 c4 08             	add    $0x8,%esp
  8010b8:	85 c0                	test   %eax,%eax
  8010ba:	0f 88 81 00 00 00    	js     801141 <dup+0xa3>
		return r;
	close(newfdnum);
  8010c0:	83 ec 0c             	sub    $0xc,%esp
  8010c3:	ff 75 0c             	pushl  0xc(%ebp)
  8010c6:	e8 83 ff ff ff       	call   80104e <close>

	newfd = INDEX2FD(newfdnum);
  8010cb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010ce:	c1 e6 0c             	shl    $0xc,%esi
  8010d1:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8010d7:	83 c4 04             	add    $0x4,%esp
  8010da:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010dd:	e8 d1 fd ff ff       	call   800eb3 <fd2data>
  8010e2:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8010e4:	89 34 24             	mov    %esi,(%esp)
  8010e7:	e8 c7 fd ff ff       	call   800eb3 <fd2data>
  8010ec:	83 c4 10             	add    $0x10,%esp
  8010ef:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010f1:	89 d8                	mov    %ebx,%eax
  8010f3:	c1 e8 16             	shr    $0x16,%eax
  8010f6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010fd:	a8 01                	test   $0x1,%al
  8010ff:	74 11                	je     801112 <dup+0x74>
  801101:	89 d8                	mov    %ebx,%eax
  801103:	c1 e8 0c             	shr    $0xc,%eax
  801106:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80110d:	f6 c2 01             	test   $0x1,%dl
  801110:	75 39                	jne    80114b <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801112:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801115:	89 d0                	mov    %edx,%eax
  801117:	c1 e8 0c             	shr    $0xc,%eax
  80111a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801121:	83 ec 0c             	sub    $0xc,%esp
  801124:	25 07 0e 00 00       	and    $0xe07,%eax
  801129:	50                   	push   %eax
  80112a:	56                   	push   %esi
  80112b:	6a 00                	push   $0x0
  80112d:	52                   	push   %edx
  80112e:	6a 00                	push   $0x0
  801130:	e8 bc fa ff ff       	call   800bf1 <sys_page_map>
  801135:	89 c3                	mov    %eax,%ebx
  801137:	83 c4 20             	add    $0x20,%esp
  80113a:	85 c0                	test   %eax,%eax
  80113c:	78 31                	js     80116f <dup+0xd1>
		goto err;

	return newfdnum;
  80113e:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801141:	89 d8                	mov    %ebx,%eax
  801143:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801146:	5b                   	pop    %ebx
  801147:	5e                   	pop    %esi
  801148:	5f                   	pop    %edi
  801149:	5d                   	pop    %ebp
  80114a:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80114b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801152:	83 ec 0c             	sub    $0xc,%esp
  801155:	25 07 0e 00 00       	and    $0xe07,%eax
  80115a:	50                   	push   %eax
  80115b:	57                   	push   %edi
  80115c:	6a 00                	push   $0x0
  80115e:	53                   	push   %ebx
  80115f:	6a 00                	push   $0x0
  801161:	e8 8b fa ff ff       	call   800bf1 <sys_page_map>
  801166:	89 c3                	mov    %eax,%ebx
  801168:	83 c4 20             	add    $0x20,%esp
  80116b:	85 c0                	test   %eax,%eax
  80116d:	79 a3                	jns    801112 <dup+0x74>
	sys_page_unmap(0, newfd);
  80116f:	83 ec 08             	sub    $0x8,%esp
  801172:	56                   	push   %esi
  801173:	6a 00                	push   $0x0
  801175:	e8 b9 fa ff ff       	call   800c33 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80117a:	83 c4 08             	add    $0x8,%esp
  80117d:	57                   	push   %edi
  80117e:	6a 00                	push   $0x0
  801180:	e8 ae fa ff ff       	call   800c33 <sys_page_unmap>
	return r;
  801185:	83 c4 10             	add    $0x10,%esp
  801188:	eb b7                	jmp    801141 <dup+0xa3>

0080118a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80118a:	55                   	push   %ebp
  80118b:	89 e5                	mov    %esp,%ebp
  80118d:	53                   	push   %ebx
  80118e:	83 ec 14             	sub    $0x14,%esp
  801191:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801194:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801197:	50                   	push   %eax
  801198:	53                   	push   %ebx
  801199:	e8 7b fd ff ff       	call   800f19 <fd_lookup>
  80119e:	83 c4 08             	add    $0x8,%esp
  8011a1:	85 c0                	test   %eax,%eax
  8011a3:	78 3f                	js     8011e4 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011a5:	83 ec 08             	sub    $0x8,%esp
  8011a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ab:	50                   	push   %eax
  8011ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011af:	ff 30                	pushl  (%eax)
  8011b1:	e8 b9 fd ff ff       	call   800f6f <dev_lookup>
  8011b6:	83 c4 10             	add    $0x10,%esp
  8011b9:	85 c0                	test   %eax,%eax
  8011bb:	78 27                	js     8011e4 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011bd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011c0:	8b 42 08             	mov    0x8(%edx),%eax
  8011c3:	83 e0 03             	and    $0x3,%eax
  8011c6:	83 f8 01             	cmp    $0x1,%eax
  8011c9:	74 1e                	je     8011e9 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8011cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011ce:	8b 40 08             	mov    0x8(%eax),%eax
  8011d1:	85 c0                	test   %eax,%eax
  8011d3:	74 35                	je     80120a <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011d5:	83 ec 04             	sub    $0x4,%esp
  8011d8:	ff 75 10             	pushl  0x10(%ebp)
  8011db:	ff 75 0c             	pushl  0xc(%ebp)
  8011de:	52                   	push   %edx
  8011df:	ff d0                	call   *%eax
  8011e1:	83 c4 10             	add    $0x10,%esp
}
  8011e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011e7:	c9                   	leave  
  8011e8:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011e9:	a1 04 40 80 00       	mov    0x804004,%eax
  8011ee:	8b 40 48             	mov    0x48(%eax),%eax
  8011f1:	83 ec 04             	sub    $0x4,%esp
  8011f4:	53                   	push   %ebx
  8011f5:	50                   	push   %eax
  8011f6:	68 f5 21 80 00       	push   $0x8021f5
  8011fb:	e8 96 ef ff ff       	call   800196 <cprintf>
		return -E_INVAL;
  801200:	83 c4 10             	add    $0x10,%esp
  801203:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801208:	eb da                	jmp    8011e4 <read+0x5a>
		return -E_NOT_SUPP;
  80120a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80120f:	eb d3                	jmp    8011e4 <read+0x5a>

00801211 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801211:	55                   	push   %ebp
  801212:	89 e5                	mov    %esp,%ebp
  801214:	57                   	push   %edi
  801215:	56                   	push   %esi
  801216:	53                   	push   %ebx
  801217:	83 ec 0c             	sub    $0xc,%esp
  80121a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80121d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801220:	bb 00 00 00 00       	mov    $0x0,%ebx
  801225:	39 f3                	cmp    %esi,%ebx
  801227:	73 25                	jae    80124e <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801229:	83 ec 04             	sub    $0x4,%esp
  80122c:	89 f0                	mov    %esi,%eax
  80122e:	29 d8                	sub    %ebx,%eax
  801230:	50                   	push   %eax
  801231:	89 d8                	mov    %ebx,%eax
  801233:	03 45 0c             	add    0xc(%ebp),%eax
  801236:	50                   	push   %eax
  801237:	57                   	push   %edi
  801238:	e8 4d ff ff ff       	call   80118a <read>
		if (m < 0)
  80123d:	83 c4 10             	add    $0x10,%esp
  801240:	85 c0                	test   %eax,%eax
  801242:	78 08                	js     80124c <readn+0x3b>
			return m;
		if (m == 0)
  801244:	85 c0                	test   %eax,%eax
  801246:	74 06                	je     80124e <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  801248:	01 c3                	add    %eax,%ebx
  80124a:	eb d9                	jmp    801225 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80124c:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80124e:	89 d8                	mov    %ebx,%eax
  801250:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801253:	5b                   	pop    %ebx
  801254:	5e                   	pop    %esi
  801255:	5f                   	pop    %edi
  801256:	5d                   	pop    %ebp
  801257:	c3                   	ret    

00801258 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801258:	55                   	push   %ebp
  801259:	89 e5                	mov    %esp,%ebp
  80125b:	53                   	push   %ebx
  80125c:	83 ec 14             	sub    $0x14,%esp
  80125f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801262:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801265:	50                   	push   %eax
  801266:	53                   	push   %ebx
  801267:	e8 ad fc ff ff       	call   800f19 <fd_lookup>
  80126c:	83 c4 08             	add    $0x8,%esp
  80126f:	85 c0                	test   %eax,%eax
  801271:	78 3a                	js     8012ad <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801273:	83 ec 08             	sub    $0x8,%esp
  801276:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801279:	50                   	push   %eax
  80127a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80127d:	ff 30                	pushl  (%eax)
  80127f:	e8 eb fc ff ff       	call   800f6f <dev_lookup>
  801284:	83 c4 10             	add    $0x10,%esp
  801287:	85 c0                	test   %eax,%eax
  801289:	78 22                	js     8012ad <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80128b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80128e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801292:	74 1e                	je     8012b2 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801294:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801297:	8b 52 0c             	mov    0xc(%edx),%edx
  80129a:	85 d2                	test   %edx,%edx
  80129c:	74 35                	je     8012d3 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80129e:	83 ec 04             	sub    $0x4,%esp
  8012a1:	ff 75 10             	pushl  0x10(%ebp)
  8012a4:	ff 75 0c             	pushl  0xc(%ebp)
  8012a7:	50                   	push   %eax
  8012a8:	ff d2                	call   *%edx
  8012aa:	83 c4 10             	add    $0x10,%esp
}
  8012ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012b0:	c9                   	leave  
  8012b1:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012b2:	a1 04 40 80 00       	mov    0x804004,%eax
  8012b7:	8b 40 48             	mov    0x48(%eax),%eax
  8012ba:	83 ec 04             	sub    $0x4,%esp
  8012bd:	53                   	push   %ebx
  8012be:	50                   	push   %eax
  8012bf:	68 11 22 80 00       	push   $0x802211
  8012c4:	e8 cd ee ff ff       	call   800196 <cprintf>
		return -E_INVAL;
  8012c9:	83 c4 10             	add    $0x10,%esp
  8012cc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012d1:	eb da                	jmp    8012ad <write+0x55>
		return -E_NOT_SUPP;
  8012d3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012d8:	eb d3                	jmp    8012ad <write+0x55>

008012da <seek>:

int
seek(int fdnum, off_t offset)
{
  8012da:	55                   	push   %ebp
  8012db:	89 e5                	mov    %esp,%ebp
  8012dd:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012e0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012e3:	50                   	push   %eax
  8012e4:	ff 75 08             	pushl  0x8(%ebp)
  8012e7:	e8 2d fc ff ff       	call   800f19 <fd_lookup>
  8012ec:	83 c4 08             	add    $0x8,%esp
  8012ef:	85 c0                	test   %eax,%eax
  8012f1:	78 0e                	js     801301 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012f9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801301:	c9                   	leave  
  801302:	c3                   	ret    

00801303 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801303:	55                   	push   %ebp
  801304:	89 e5                	mov    %esp,%ebp
  801306:	53                   	push   %ebx
  801307:	83 ec 14             	sub    $0x14,%esp
  80130a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80130d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801310:	50                   	push   %eax
  801311:	53                   	push   %ebx
  801312:	e8 02 fc ff ff       	call   800f19 <fd_lookup>
  801317:	83 c4 08             	add    $0x8,%esp
  80131a:	85 c0                	test   %eax,%eax
  80131c:	78 37                	js     801355 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80131e:	83 ec 08             	sub    $0x8,%esp
  801321:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801324:	50                   	push   %eax
  801325:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801328:	ff 30                	pushl  (%eax)
  80132a:	e8 40 fc ff ff       	call   800f6f <dev_lookup>
  80132f:	83 c4 10             	add    $0x10,%esp
  801332:	85 c0                	test   %eax,%eax
  801334:	78 1f                	js     801355 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801336:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801339:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80133d:	74 1b                	je     80135a <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80133f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801342:	8b 52 18             	mov    0x18(%edx),%edx
  801345:	85 d2                	test   %edx,%edx
  801347:	74 32                	je     80137b <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801349:	83 ec 08             	sub    $0x8,%esp
  80134c:	ff 75 0c             	pushl  0xc(%ebp)
  80134f:	50                   	push   %eax
  801350:	ff d2                	call   *%edx
  801352:	83 c4 10             	add    $0x10,%esp
}
  801355:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801358:	c9                   	leave  
  801359:	c3                   	ret    
			thisenv->env_id, fdnum);
  80135a:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80135f:	8b 40 48             	mov    0x48(%eax),%eax
  801362:	83 ec 04             	sub    $0x4,%esp
  801365:	53                   	push   %ebx
  801366:	50                   	push   %eax
  801367:	68 d4 21 80 00       	push   $0x8021d4
  80136c:	e8 25 ee ff ff       	call   800196 <cprintf>
		return -E_INVAL;
  801371:	83 c4 10             	add    $0x10,%esp
  801374:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801379:	eb da                	jmp    801355 <ftruncate+0x52>
		return -E_NOT_SUPP;
  80137b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801380:	eb d3                	jmp    801355 <ftruncate+0x52>

00801382 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801382:	55                   	push   %ebp
  801383:	89 e5                	mov    %esp,%ebp
  801385:	53                   	push   %ebx
  801386:	83 ec 14             	sub    $0x14,%esp
  801389:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80138c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80138f:	50                   	push   %eax
  801390:	ff 75 08             	pushl  0x8(%ebp)
  801393:	e8 81 fb ff ff       	call   800f19 <fd_lookup>
  801398:	83 c4 08             	add    $0x8,%esp
  80139b:	85 c0                	test   %eax,%eax
  80139d:	78 4b                	js     8013ea <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80139f:	83 ec 08             	sub    $0x8,%esp
  8013a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a5:	50                   	push   %eax
  8013a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a9:	ff 30                	pushl  (%eax)
  8013ab:	e8 bf fb ff ff       	call   800f6f <dev_lookup>
  8013b0:	83 c4 10             	add    $0x10,%esp
  8013b3:	85 c0                	test   %eax,%eax
  8013b5:	78 33                	js     8013ea <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  8013b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013ba:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013be:	74 2f                	je     8013ef <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013c0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013c3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013ca:	00 00 00 
	stat->st_isdir = 0;
  8013cd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013d4:	00 00 00 
	stat->st_dev = dev;
  8013d7:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013dd:	83 ec 08             	sub    $0x8,%esp
  8013e0:	53                   	push   %ebx
  8013e1:	ff 75 f0             	pushl  -0x10(%ebp)
  8013e4:	ff 50 14             	call   *0x14(%eax)
  8013e7:	83 c4 10             	add    $0x10,%esp
}
  8013ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ed:	c9                   	leave  
  8013ee:	c3                   	ret    
		return -E_NOT_SUPP;
  8013ef:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013f4:	eb f4                	jmp    8013ea <fstat+0x68>

008013f6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013f6:	55                   	push   %ebp
  8013f7:	89 e5                	mov    %esp,%ebp
  8013f9:	56                   	push   %esi
  8013fa:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013fb:	83 ec 08             	sub    $0x8,%esp
  8013fe:	6a 00                	push   $0x0
  801400:	ff 75 08             	pushl  0x8(%ebp)
  801403:	e8 e7 01 00 00       	call   8015ef <open>
  801408:	89 c3                	mov    %eax,%ebx
  80140a:	83 c4 10             	add    $0x10,%esp
  80140d:	85 c0                	test   %eax,%eax
  80140f:	78 1b                	js     80142c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801411:	83 ec 08             	sub    $0x8,%esp
  801414:	ff 75 0c             	pushl  0xc(%ebp)
  801417:	50                   	push   %eax
  801418:	e8 65 ff ff ff       	call   801382 <fstat>
  80141d:	89 c6                	mov    %eax,%esi
	close(fd);
  80141f:	89 1c 24             	mov    %ebx,(%esp)
  801422:	e8 27 fc ff ff       	call   80104e <close>
	return r;
  801427:	83 c4 10             	add    $0x10,%esp
  80142a:	89 f3                	mov    %esi,%ebx
}
  80142c:	89 d8                	mov    %ebx,%eax
  80142e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801431:	5b                   	pop    %ebx
  801432:	5e                   	pop    %esi
  801433:	5d                   	pop    %ebp
  801434:	c3                   	ret    

00801435 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801435:	55                   	push   %ebp
  801436:	89 e5                	mov    %esp,%ebp
  801438:	56                   	push   %esi
  801439:	53                   	push   %ebx
  80143a:	89 c6                	mov    %eax,%esi
  80143c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80143e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801445:	74 27                	je     80146e <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801447:	6a 07                	push   $0x7
  801449:	68 00 50 80 00       	push   $0x805000
  80144e:	56                   	push   %esi
  80144f:	ff 35 00 40 80 00    	pushl  0x804000
  801455:	e8 ba f9 ff ff       	call   800e14 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80145a:	83 c4 0c             	add    $0xc,%esp
  80145d:	6a 00                	push   $0x0
  80145f:	53                   	push   %ebx
  801460:	6a 00                	push   $0x0
  801462:	e8 38 f9 ff ff       	call   800d9f <ipc_recv>
}
  801467:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80146a:	5b                   	pop    %ebx
  80146b:	5e                   	pop    %esi
  80146c:	5d                   	pop    %ebp
  80146d:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80146e:	83 ec 0c             	sub    $0xc,%esp
  801471:	6a 01                	push   $0x1
  801473:	e8 f2 f9 ff ff       	call   800e6a <ipc_find_env>
  801478:	a3 00 40 80 00       	mov    %eax,0x804000
  80147d:	83 c4 10             	add    $0x10,%esp
  801480:	eb c5                	jmp    801447 <fsipc+0x12>

00801482 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801482:	55                   	push   %ebp
  801483:	89 e5                	mov    %esp,%ebp
  801485:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801488:	8b 45 08             	mov    0x8(%ebp),%eax
  80148b:	8b 40 0c             	mov    0xc(%eax),%eax
  80148e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801493:	8b 45 0c             	mov    0xc(%ebp),%eax
  801496:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80149b:	ba 00 00 00 00       	mov    $0x0,%edx
  8014a0:	b8 02 00 00 00       	mov    $0x2,%eax
  8014a5:	e8 8b ff ff ff       	call   801435 <fsipc>
}
  8014aa:	c9                   	leave  
  8014ab:	c3                   	ret    

008014ac <devfile_flush>:
{
  8014ac:	55                   	push   %ebp
  8014ad:	89 e5                	mov    %esp,%ebp
  8014af:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b5:	8b 40 0c             	mov    0xc(%eax),%eax
  8014b8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c2:	b8 06 00 00 00       	mov    $0x6,%eax
  8014c7:	e8 69 ff ff ff       	call   801435 <fsipc>
}
  8014cc:	c9                   	leave  
  8014cd:	c3                   	ret    

008014ce <devfile_stat>:
{
  8014ce:	55                   	push   %ebp
  8014cf:	89 e5                	mov    %esp,%ebp
  8014d1:	53                   	push   %ebx
  8014d2:	83 ec 04             	sub    $0x4,%esp
  8014d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8014db:	8b 40 0c             	mov    0xc(%eax),%eax
  8014de:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e8:	b8 05 00 00 00       	mov    $0x5,%eax
  8014ed:	e8 43 ff ff ff       	call   801435 <fsipc>
  8014f2:	85 c0                	test   %eax,%eax
  8014f4:	78 2c                	js     801522 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014f6:	83 ec 08             	sub    $0x8,%esp
  8014f9:	68 00 50 80 00       	push   $0x805000
  8014fe:	53                   	push   %ebx
  8014ff:	e8 b1 f2 ff ff       	call   8007b5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801504:	a1 80 50 80 00       	mov    0x805080,%eax
  801509:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80150f:	a1 84 50 80 00       	mov    0x805084,%eax
  801514:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80151a:	83 c4 10             	add    $0x10,%esp
  80151d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801522:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801525:	c9                   	leave  
  801526:	c3                   	ret    

00801527 <devfile_write>:
{
  801527:	55                   	push   %ebp
  801528:	89 e5                	mov    %esp,%ebp
  80152a:	83 ec 0c             	sub    $0xc,%esp
  80152d:	8b 45 10             	mov    0x10(%ebp),%eax
  801530:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801535:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80153a:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80153d:	8b 55 08             	mov    0x8(%ebp),%edx
  801540:	8b 52 0c             	mov    0xc(%edx),%edx
  801543:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801549:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf,buf,n);
  80154e:	50                   	push   %eax
  80154f:	ff 75 0c             	pushl  0xc(%ebp)
  801552:	68 08 50 80 00       	push   $0x805008
  801557:	e8 e7 f3 ff ff       	call   800943 <memmove>
	if((r = fsipc(FSREQ_WRITE,NULL))<0)
  80155c:	ba 00 00 00 00       	mov    $0x0,%edx
  801561:	b8 04 00 00 00       	mov    $0x4,%eax
  801566:	e8 ca fe ff ff       	call   801435 <fsipc>
}
  80156b:	c9                   	leave  
  80156c:	c3                   	ret    

0080156d <devfile_read>:
{
  80156d:	55                   	push   %ebp
  80156e:	89 e5                	mov    %esp,%ebp
  801570:	56                   	push   %esi
  801571:	53                   	push   %ebx
  801572:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801575:	8b 45 08             	mov    0x8(%ebp),%eax
  801578:	8b 40 0c             	mov    0xc(%eax),%eax
  80157b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801580:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801586:	ba 00 00 00 00       	mov    $0x0,%edx
  80158b:	b8 03 00 00 00       	mov    $0x3,%eax
  801590:	e8 a0 fe ff ff       	call   801435 <fsipc>
  801595:	89 c3                	mov    %eax,%ebx
  801597:	85 c0                	test   %eax,%eax
  801599:	78 1f                	js     8015ba <devfile_read+0x4d>
	assert(r <= n);
  80159b:	39 f0                	cmp    %esi,%eax
  80159d:	77 24                	ja     8015c3 <devfile_read+0x56>
	assert(r <= PGSIZE);
  80159f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015a4:	7f 33                	jg     8015d9 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015a6:	83 ec 04             	sub    $0x4,%esp
  8015a9:	50                   	push   %eax
  8015aa:	68 00 50 80 00       	push   $0x805000
  8015af:	ff 75 0c             	pushl  0xc(%ebp)
  8015b2:	e8 8c f3 ff ff       	call   800943 <memmove>
	return r;
  8015b7:	83 c4 10             	add    $0x10,%esp
}
  8015ba:	89 d8                	mov    %ebx,%eax
  8015bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015bf:	5b                   	pop    %ebx
  8015c0:	5e                   	pop    %esi
  8015c1:	5d                   	pop    %ebp
  8015c2:	c3                   	ret    
	assert(r <= n);
  8015c3:	68 40 22 80 00       	push   $0x802240
  8015c8:	68 47 22 80 00       	push   $0x802247
  8015cd:	6a 7c                	push   $0x7c
  8015cf:	68 5c 22 80 00       	push   $0x80225c
  8015d4:	e8 85 05 00 00       	call   801b5e <_panic>
	assert(r <= PGSIZE);
  8015d9:	68 67 22 80 00       	push   $0x802267
  8015de:	68 47 22 80 00       	push   $0x802247
  8015e3:	6a 7d                	push   $0x7d
  8015e5:	68 5c 22 80 00       	push   $0x80225c
  8015ea:	e8 6f 05 00 00       	call   801b5e <_panic>

008015ef <open>:
{
  8015ef:	55                   	push   %ebp
  8015f0:	89 e5                	mov    %esp,%ebp
  8015f2:	56                   	push   %esi
  8015f3:	53                   	push   %ebx
  8015f4:	83 ec 1c             	sub    $0x1c,%esp
  8015f7:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8015fa:	56                   	push   %esi
  8015fb:	e8 7e f1 ff ff       	call   80077e <strlen>
  801600:	83 c4 10             	add    $0x10,%esp
  801603:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801608:	7f 6c                	jg     801676 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  80160a:	83 ec 0c             	sub    $0xc,%esp
  80160d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801610:	50                   	push   %eax
  801611:	e8 b4 f8 ff ff       	call   800eca <fd_alloc>
  801616:	89 c3                	mov    %eax,%ebx
  801618:	83 c4 10             	add    $0x10,%esp
  80161b:	85 c0                	test   %eax,%eax
  80161d:	78 3c                	js     80165b <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  80161f:	83 ec 08             	sub    $0x8,%esp
  801622:	56                   	push   %esi
  801623:	68 00 50 80 00       	push   $0x805000
  801628:	e8 88 f1 ff ff       	call   8007b5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80162d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801630:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801635:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801638:	b8 01 00 00 00       	mov    $0x1,%eax
  80163d:	e8 f3 fd ff ff       	call   801435 <fsipc>
  801642:	89 c3                	mov    %eax,%ebx
  801644:	83 c4 10             	add    $0x10,%esp
  801647:	85 c0                	test   %eax,%eax
  801649:	78 19                	js     801664 <open+0x75>
	return fd2num(fd);
  80164b:	83 ec 0c             	sub    $0xc,%esp
  80164e:	ff 75 f4             	pushl  -0xc(%ebp)
  801651:	e8 4d f8 ff ff       	call   800ea3 <fd2num>
  801656:	89 c3                	mov    %eax,%ebx
  801658:	83 c4 10             	add    $0x10,%esp
}
  80165b:	89 d8                	mov    %ebx,%eax
  80165d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801660:	5b                   	pop    %ebx
  801661:	5e                   	pop    %esi
  801662:	5d                   	pop    %ebp
  801663:	c3                   	ret    
		fd_close(fd, 0);
  801664:	83 ec 08             	sub    $0x8,%esp
  801667:	6a 00                	push   $0x0
  801669:	ff 75 f4             	pushl  -0xc(%ebp)
  80166c:	e8 54 f9 ff ff       	call   800fc5 <fd_close>
		return r;
  801671:	83 c4 10             	add    $0x10,%esp
  801674:	eb e5                	jmp    80165b <open+0x6c>
		return -E_BAD_PATH;
  801676:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80167b:	eb de                	jmp    80165b <open+0x6c>

0080167d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80167d:	55                   	push   %ebp
  80167e:	89 e5                	mov    %esp,%ebp
  801680:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801683:	ba 00 00 00 00       	mov    $0x0,%edx
  801688:	b8 08 00 00 00       	mov    $0x8,%eax
  80168d:	e8 a3 fd ff ff       	call   801435 <fsipc>
}
  801692:	c9                   	leave  
  801693:	c3                   	ret    

00801694 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801694:	55                   	push   %ebp
  801695:	89 e5                	mov    %esp,%ebp
  801697:	56                   	push   %esi
  801698:	53                   	push   %ebx
  801699:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80169c:	83 ec 0c             	sub    $0xc,%esp
  80169f:	ff 75 08             	pushl  0x8(%ebp)
  8016a2:	e8 0c f8 ff ff       	call   800eb3 <fd2data>
  8016a7:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8016a9:	83 c4 08             	add    $0x8,%esp
  8016ac:	68 73 22 80 00       	push   $0x802273
  8016b1:	53                   	push   %ebx
  8016b2:	e8 fe f0 ff ff       	call   8007b5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8016b7:	8b 46 04             	mov    0x4(%esi),%eax
  8016ba:	2b 06                	sub    (%esi),%eax
  8016bc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8016c2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016c9:	00 00 00 
	stat->st_dev = &devpipe;
  8016cc:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8016d3:	30 80 00 
	return 0;
}
  8016d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8016db:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016de:	5b                   	pop    %ebx
  8016df:	5e                   	pop    %esi
  8016e0:	5d                   	pop    %ebp
  8016e1:	c3                   	ret    

008016e2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8016e2:	55                   	push   %ebp
  8016e3:	89 e5                	mov    %esp,%ebp
  8016e5:	53                   	push   %ebx
  8016e6:	83 ec 0c             	sub    $0xc,%esp
  8016e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8016ec:	53                   	push   %ebx
  8016ed:	6a 00                	push   $0x0
  8016ef:	e8 3f f5 ff ff       	call   800c33 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8016f4:	89 1c 24             	mov    %ebx,(%esp)
  8016f7:	e8 b7 f7 ff ff       	call   800eb3 <fd2data>
  8016fc:	83 c4 08             	add    $0x8,%esp
  8016ff:	50                   	push   %eax
  801700:	6a 00                	push   $0x0
  801702:	e8 2c f5 ff ff       	call   800c33 <sys_page_unmap>
}
  801707:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80170a:	c9                   	leave  
  80170b:	c3                   	ret    

0080170c <_pipeisclosed>:
{
  80170c:	55                   	push   %ebp
  80170d:	89 e5                	mov    %esp,%ebp
  80170f:	57                   	push   %edi
  801710:	56                   	push   %esi
  801711:	53                   	push   %ebx
  801712:	83 ec 1c             	sub    $0x1c,%esp
  801715:	89 c7                	mov    %eax,%edi
  801717:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801719:	a1 04 40 80 00       	mov    0x804004,%eax
  80171e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801721:	83 ec 0c             	sub    $0xc,%esp
  801724:	57                   	push   %edi
  801725:	e8 7a 04 00 00       	call   801ba4 <pageref>
  80172a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80172d:	89 34 24             	mov    %esi,(%esp)
  801730:	e8 6f 04 00 00       	call   801ba4 <pageref>
		nn = thisenv->env_runs;
  801735:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80173b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80173e:	83 c4 10             	add    $0x10,%esp
  801741:	39 cb                	cmp    %ecx,%ebx
  801743:	74 1b                	je     801760 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801745:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801748:	75 cf                	jne    801719 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80174a:	8b 42 58             	mov    0x58(%edx),%eax
  80174d:	6a 01                	push   $0x1
  80174f:	50                   	push   %eax
  801750:	53                   	push   %ebx
  801751:	68 7a 22 80 00       	push   $0x80227a
  801756:	e8 3b ea ff ff       	call   800196 <cprintf>
  80175b:	83 c4 10             	add    $0x10,%esp
  80175e:	eb b9                	jmp    801719 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801760:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801763:	0f 94 c0             	sete   %al
  801766:	0f b6 c0             	movzbl %al,%eax
}
  801769:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80176c:	5b                   	pop    %ebx
  80176d:	5e                   	pop    %esi
  80176e:	5f                   	pop    %edi
  80176f:	5d                   	pop    %ebp
  801770:	c3                   	ret    

00801771 <devpipe_write>:
{
  801771:	55                   	push   %ebp
  801772:	89 e5                	mov    %esp,%ebp
  801774:	57                   	push   %edi
  801775:	56                   	push   %esi
  801776:	53                   	push   %ebx
  801777:	83 ec 28             	sub    $0x28,%esp
  80177a:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  80177d:	56                   	push   %esi
  80177e:	e8 30 f7 ff ff       	call   800eb3 <fd2data>
  801783:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801785:	83 c4 10             	add    $0x10,%esp
  801788:	bf 00 00 00 00       	mov    $0x0,%edi
  80178d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801790:	74 4f                	je     8017e1 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801792:	8b 43 04             	mov    0x4(%ebx),%eax
  801795:	8b 0b                	mov    (%ebx),%ecx
  801797:	8d 51 20             	lea    0x20(%ecx),%edx
  80179a:	39 d0                	cmp    %edx,%eax
  80179c:	72 14                	jb     8017b2 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  80179e:	89 da                	mov    %ebx,%edx
  8017a0:	89 f0                	mov    %esi,%eax
  8017a2:	e8 65 ff ff ff       	call   80170c <_pipeisclosed>
  8017a7:	85 c0                	test   %eax,%eax
  8017a9:	75 3a                	jne    8017e5 <devpipe_write+0x74>
			sys_yield();
  8017ab:	e8 df f3 ff ff       	call   800b8f <sys_yield>
  8017b0:	eb e0                	jmp    801792 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8017b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017b5:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8017b9:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8017bc:	89 c2                	mov    %eax,%edx
  8017be:	c1 fa 1f             	sar    $0x1f,%edx
  8017c1:	89 d1                	mov    %edx,%ecx
  8017c3:	c1 e9 1b             	shr    $0x1b,%ecx
  8017c6:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8017c9:	83 e2 1f             	and    $0x1f,%edx
  8017cc:	29 ca                	sub    %ecx,%edx
  8017ce:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8017d2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8017d6:	83 c0 01             	add    $0x1,%eax
  8017d9:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  8017dc:	83 c7 01             	add    $0x1,%edi
  8017df:	eb ac                	jmp    80178d <devpipe_write+0x1c>
	return i;
  8017e1:	89 f8                	mov    %edi,%eax
  8017e3:	eb 05                	jmp    8017ea <devpipe_write+0x79>
				return 0;
  8017e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017ed:	5b                   	pop    %ebx
  8017ee:	5e                   	pop    %esi
  8017ef:	5f                   	pop    %edi
  8017f0:	5d                   	pop    %ebp
  8017f1:	c3                   	ret    

008017f2 <devpipe_read>:
{
  8017f2:	55                   	push   %ebp
  8017f3:	89 e5                	mov    %esp,%ebp
  8017f5:	57                   	push   %edi
  8017f6:	56                   	push   %esi
  8017f7:	53                   	push   %ebx
  8017f8:	83 ec 18             	sub    $0x18,%esp
  8017fb:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8017fe:	57                   	push   %edi
  8017ff:	e8 af f6 ff ff       	call   800eb3 <fd2data>
  801804:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801806:	83 c4 10             	add    $0x10,%esp
  801809:	be 00 00 00 00       	mov    $0x0,%esi
  80180e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801811:	74 47                	je     80185a <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  801813:	8b 03                	mov    (%ebx),%eax
  801815:	3b 43 04             	cmp    0x4(%ebx),%eax
  801818:	75 22                	jne    80183c <devpipe_read+0x4a>
			if (i > 0)
  80181a:	85 f6                	test   %esi,%esi
  80181c:	75 14                	jne    801832 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  80181e:	89 da                	mov    %ebx,%edx
  801820:	89 f8                	mov    %edi,%eax
  801822:	e8 e5 fe ff ff       	call   80170c <_pipeisclosed>
  801827:	85 c0                	test   %eax,%eax
  801829:	75 33                	jne    80185e <devpipe_read+0x6c>
			sys_yield();
  80182b:	e8 5f f3 ff ff       	call   800b8f <sys_yield>
  801830:	eb e1                	jmp    801813 <devpipe_read+0x21>
				return i;
  801832:	89 f0                	mov    %esi,%eax
}
  801834:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801837:	5b                   	pop    %ebx
  801838:	5e                   	pop    %esi
  801839:	5f                   	pop    %edi
  80183a:	5d                   	pop    %ebp
  80183b:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80183c:	99                   	cltd   
  80183d:	c1 ea 1b             	shr    $0x1b,%edx
  801840:	01 d0                	add    %edx,%eax
  801842:	83 e0 1f             	and    $0x1f,%eax
  801845:	29 d0                	sub    %edx,%eax
  801847:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  80184c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80184f:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801852:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801855:	83 c6 01             	add    $0x1,%esi
  801858:	eb b4                	jmp    80180e <devpipe_read+0x1c>
	return i;
  80185a:	89 f0                	mov    %esi,%eax
  80185c:	eb d6                	jmp    801834 <devpipe_read+0x42>
				return 0;
  80185e:	b8 00 00 00 00       	mov    $0x0,%eax
  801863:	eb cf                	jmp    801834 <devpipe_read+0x42>

00801865 <pipe>:
{
  801865:	55                   	push   %ebp
  801866:	89 e5                	mov    %esp,%ebp
  801868:	56                   	push   %esi
  801869:	53                   	push   %ebx
  80186a:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  80186d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801870:	50                   	push   %eax
  801871:	e8 54 f6 ff ff       	call   800eca <fd_alloc>
  801876:	89 c3                	mov    %eax,%ebx
  801878:	83 c4 10             	add    $0x10,%esp
  80187b:	85 c0                	test   %eax,%eax
  80187d:	78 5b                	js     8018da <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80187f:	83 ec 04             	sub    $0x4,%esp
  801882:	68 07 04 00 00       	push   $0x407
  801887:	ff 75 f4             	pushl  -0xc(%ebp)
  80188a:	6a 00                	push   $0x0
  80188c:	e8 1d f3 ff ff       	call   800bae <sys_page_alloc>
  801891:	89 c3                	mov    %eax,%ebx
  801893:	83 c4 10             	add    $0x10,%esp
  801896:	85 c0                	test   %eax,%eax
  801898:	78 40                	js     8018da <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  80189a:	83 ec 0c             	sub    $0xc,%esp
  80189d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018a0:	50                   	push   %eax
  8018a1:	e8 24 f6 ff ff       	call   800eca <fd_alloc>
  8018a6:	89 c3                	mov    %eax,%ebx
  8018a8:	83 c4 10             	add    $0x10,%esp
  8018ab:	85 c0                	test   %eax,%eax
  8018ad:	78 1b                	js     8018ca <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018af:	83 ec 04             	sub    $0x4,%esp
  8018b2:	68 07 04 00 00       	push   $0x407
  8018b7:	ff 75 f0             	pushl  -0x10(%ebp)
  8018ba:	6a 00                	push   $0x0
  8018bc:	e8 ed f2 ff ff       	call   800bae <sys_page_alloc>
  8018c1:	89 c3                	mov    %eax,%ebx
  8018c3:	83 c4 10             	add    $0x10,%esp
  8018c6:	85 c0                	test   %eax,%eax
  8018c8:	79 19                	jns    8018e3 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  8018ca:	83 ec 08             	sub    $0x8,%esp
  8018cd:	ff 75 f4             	pushl  -0xc(%ebp)
  8018d0:	6a 00                	push   $0x0
  8018d2:	e8 5c f3 ff ff       	call   800c33 <sys_page_unmap>
  8018d7:	83 c4 10             	add    $0x10,%esp
}
  8018da:	89 d8                	mov    %ebx,%eax
  8018dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018df:	5b                   	pop    %ebx
  8018e0:	5e                   	pop    %esi
  8018e1:	5d                   	pop    %ebp
  8018e2:	c3                   	ret    
	va = fd2data(fd0);
  8018e3:	83 ec 0c             	sub    $0xc,%esp
  8018e6:	ff 75 f4             	pushl  -0xc(%ebp)
  8018e9:	e8 c5 f5 ff ff       	call   800eb3 <fd2data>
  8018ee:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018f0:	83 c4 0c             	add    $0xc,%esp
  8018f3:	68 07 04 00 00       	push   $0x407
  8018f8:	50                   	push   %eax
  8018f9:	6a 00                	push   $0x0
  8018fb:	e8 ae f2 ff ff       	call   800bae <sys_page_alloc>
  801900:	89 c3                	mov    %eax,%ebx
  801902:	83 c4 10             	add    $0x10,%esp
  801905:	85 c0                	test   %eax,%eax
  801907:	0f 88 8c 00 00 00    	js     801999 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80190d:	83 ec 0c             	sub    $0xc,%esp
  801910:	ff 75 f0             	pushl  -0x10(%ebp)
  801913:	e8 9b f5 ff ff       	call   800eb3 <fd2data>
  801918:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80191f:	50                   	push   %eax
  801920:	6a 00                	push   $0x0
  801922:	56                   	push   %esi
  801923:	6a 00                	push   $0x0
  801925:	e8 c7 f2 ff ff       	call   800bf1 <sys_page_map>
  80192a:	89 c3                	mov    %eax,%ebx
  80192c:	83 c4 20             	add    $0x20,%esp
  80192f:	85 c0                	test   %eax,%eax
  801931:	78 58                	js     80198b <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801933:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801936:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80193c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80193e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801941:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801948:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80194b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801951:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801953:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801956:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  80195d:	83 ec 0c             	sub    $0xc,%esp
  801960:	ff 75 f4             	pushl  -0xc(%ebp)
  801963:	e8 3b f5 ff ff       	call   800ea3 <fd2num>
  801968:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80196b:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80196d:	83 c4 04             	add    $0x4,%esp
  801970:	ff 75 f0             	pushl  -0x10(%ebp)
  801973:	e8 2b f5 ff ff       	call   800ea3 <fd2num>
  801978:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80197b:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80197e:	83 c4 10             	add    $0x10,%esp
  801981:	bb 00 00 00 00       	mov    $0x0,%ebx
  801986:	e9 4f ff ff ff       	jmp    8018da <pipe+0x75>
	sys_page_unmap(0, va);
  80198b:	83 ec 08             	sub    $0x8,%esp
  80198e:	56                   	push   %esi
  80198f:	6a 00                	push   $0x0
  801991:	e8 9d f2 ff ff       	call   800c33 <sys_page_unmap>
  801996:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801999:	83 ec 08             	sub    $0x8,%esp
  80199c:	ff 75 f0             	pushl  -0x10(%ebp)
  80199f:	6a 00                	push   $0x0
  8019a1:	e8 8d f2 ff ff       	call   800c33 <sys_page_unmap>
  8019a6:	83 c4 10             	add    $0x10,%esp
  8019a9:	e9 1c ff ff ff       	jmp    8018ca <pipe+0x65>

008019ae <pipeisclosed>:
{
  8019ae:	55                   	push   %ebp
  8019af:	89 e5                	mov    %esp,%ebp
  8019b1:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019b7:	50                   	push   %eax
  8019b8:	ff 75 08             	pushl  0x8(%ebp)
  8019bb:	e8 59 f5 ff ff       	call   800f19 <fd_lookup>
  8019c0:	83 c4 10             	add    $0x10,%esp
  8019c3:	85 c0                	test   %eax,%eax
  8019c5:	78 18                	js     8019df <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  8019c7:	83 ec 0c             	sub    $0xc,%esp
  8019ca:	ff 75 f4             	pushl  -0xc(%ebp)
  8019cd:	e8 e1 f4 ff ff       	call   800eb3 <fd2data>
	return _pipeisclosed(fd, p);
  8019d2:	89 c2                	mov    %eax,%edx
  8019d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019d7:	e8 30 fd ff ff       	call   80170c <_pipeisclosed>
  8019dc:	83 c4 10             	add    $0x10,%esp
}
  8019df:	c9                   	leave  
  8019e0:	c3                   	ret    

008019e1 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8019e1:	55                   	push   %ebp
  8019e2:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8019e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8019e9:	5d                   	pop    %ebp
  8019ea:	c3                   	ret    

008019eb <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8019eb:	55                   	push   %ebp
  8019ec:	89 e5                	mov    %esp,%ebp
  8019ee:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8019f1:	68 92 22 80 00       	push   $0x802292
  8019f6:	ff 75 0c             	pushl  0xc(%ebp)
  8019f9:	e8 b7 ed ff ff       	call   8007b5 <strcpy>
	return 0;
}
  8019fe:	b8 00 00 00 00       	mov    $0x0,%eax
  801a03:	c9                   	leave  
  801a04:	c3                   	ret    

00801a05 <devcons_write>:
{
  801a05:	55                   	push   %ebp
  801a06:	89 e5                	mov    %esp,%ebp
  801a08:	57                   	push   %edi
  801a09:	56                   	push   %esi
  801a0a:	53                   	push   %ebx
  801a0b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801a11:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801a16:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801a1c:	eb 2f                	jmp    801a4d <devcons_write+0x48>
		m = n - tot;
  801a1e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a21:	29 f3                	sub    %esi,%ebx
  801a23:	83 fb 7f             	cmp    $0x7f,%ebx
  801a26:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801a2b:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801a2e:	83 ec 04             	sub    $0x4,%esp
  801a31:	53                   	push   %ebx
  801a32:	89 f0                	mov    %esi,%eax
  801a34:	03 45 0c             	add    0xc(%ebp),%eax
  801a37:	50                   	push   %eax
  801a38:	57                   	push   %edi
  801a39:	e8 05 ef ff ff       	call   800943 <memmove>
		sys_cputs(buf, m);
  801a3e:	83 c4 08             	add    $0x8,%esp
  801a41:	53                   	push   %ebx
  801a42:	57                   	push   %edi
  801a43:	e8 aa f0 ff ff       	call   800af2 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801a48:	01 de                	add    %ebx,%esi
  801a4a:	83 c4 10             	add    $0x10,%esp
  801a4d:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a50:	72 cc                	jb     801a1e <devcons_write+0x19>
}
  801a52:	89 f0                	mov    %esi,%eax
  801a54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a57:	5b                   	pop    %ebx
  801a58:	5e                   	pop    %esi
  801a59:	5f                   	pop    %edi
  801a5a:	5d                   	pop    %ebp
  801a5b:	c3                   	ret    

00801a5c <devcons_read>:
{
  801a5c:	55                   	push   %ebp
  801a5d:	89 e5                	mov    %esp,%ebp
  801a5f:	83 ec 08             	sub    $0x8,%esp
  801a62:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801a67:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a6b:	75 07                	jne    801a74 <devcons_read+0x18>
}
  801a6d:	c9                   	leave  
  801a6e:	c3                   	ret    
		sys_yield();
  801a6f:	e8 1b f1 ff ff       	call   800b8f <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801a74:	e8 97 f0 ff ff       	call   800b10 <sys_cgetc>
  801a79:	85 c0                	test   %eax,%eax
  801a7b:	74 f2                	je     801a6f <devcons_read+0x13>
	if (c < 0)
  801a7d:	85 c0                	test   %eax,%eax
  801a7f:	78 ec                	js     801a6d <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  801a81:	83 f8 04             	cmp    $0x4,%eax
  801a84:	74 0c                	je     801a92 <devcons_read+0x36>
	*(char*)vbuf = c;
  801a86:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a89:	88 02                	mov    %al,(%edx)
	return 1;
  801a8b:	b8 01 00 00 00       	mov    $0x1,%eax
  801a90:	eb db                	jmp    801a6d <devcons_read+0x11>
		return 0;
  801a92:	b8 00 00 00 00       	mov    $0x0,%eax
  801a97:	eb d4                	jmp    801a6d <devcons_read+0x11>

00801a99 <cputchar>:
{
  801a99:	55                   	push   %ebp
  801a9a:	89 e5                	mov    %esp,%ebp
  801a9c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a9f:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa2:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801aa5:	6a 01                	push   $0x1
  801aa7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801aaa:	50                   	push   %eax
  801aab:	e8 42 f0 ff ff       	call   800af2 <sys_cputs>
}
  801ab0:	83 c4 10             	add    $0x10,%esp
  801ab3:	c9                   	leave  
  801ab4:	c3                   	ret    

00801ab5 <getchar>:
{
  801ab5:	55                   	push   %ebp
  801ab6:	89 e5                	mov    %esp,%ebp
  801ab8:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801abb:	6a 01                	push   $0x1
  801abd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ac0:	50                   	push   %eax
  801ac1:	6a 00                	push   $0x0
  801ac3:	e8 c2 f6 ff ff       	call   80118a <read>
	if (r < 0)
  801ac8:	83 c4 10             	add    $0x10,%esp
  801acb:	85 c0                	test   %eax,%eax
  801acd:	78 08                	js     801ad7 <getchar+0x22>
	if (r < 1)
  801acf:	85 c0                	test   %eax,%eax
  801ad1:	7e 06                	jle    801ad9 <getchar+0x24>
	return c;
  801ad3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801ad7:	c9                   	leave  
  801ad8:	c3                   	ret    
		return -E_EOF;
  801ad9:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801ade:	eb f7                	jmp    801ad7 <getchar+0x22>

00801ae0 <iscons>:
{
  801ae0:	55                   	push   %ebp
  801ae1:	89 e5                	mov    %esp,%ebp
  801ae3:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ae6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ae9:	50                   	push   %eax
  801aea:	ff 75 08             	pushl  0x8(%ebp)
  801aed:	e8 27 f4 ff ff       	call   800f19 <fd_lookup>
  801af2:	83 c4 10             	add    $0x10,%esp
  801af5:	85 c0                	test   %eax,%eax
  801af7:	78 11                	js     801b0a <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801af9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801afc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b02:	39 10                	cmp    %edx,(%eax)
  801b04:	0f 94 c0             	sete   %al
  801b07:	0f b6 c0             	movzbl %al,%eax
}
  801b0a:	c9                   	leave  
  801b0b:	c3                   	ret    

00801b0c <opencons>:
{
  801b0c:	55                   	push   %ebp
  801b0d:	89 e5                	mov    %esp,%ebp
  801b0f:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801b12:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b15:	50                   	push   %eax
  801b16:	e8 af f3 ff ff       	call   800eca <fd_alloc>
  801b1b:	83 c4 10             	add    $0x10,%esp
  801b1e:	85 c0                	test   %eax,%eax
  801b20:	78 3a                	js     801b5c <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b22:	83 ec 04             	sub    $0x4,%esp
  801b25:	68 07 04 00 00       	push   $0x407
  801b2a:	ff 75 f4             	pushl  -0xc(%ebp)
  801b2d:	6a 00                	push   $0x0
  801b2f:	e8 7a f0 ff ff       	call   800bae <sys_page_alloc>
  801b34:	83 c4 10             	add    $0x10,%esp
  801b37:	85 c0                	test   %eax,%eax
  801b39:	78 21                	js     801b5c <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801b3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b3e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b44:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b46:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b49:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b50:	83 ec 0c             	sub    $0xc,%esp
  801b53:	50                   	push   %eax
  801b54:	e8 4a f3 ff ff       	call   800ea3 <fd2num>
  801b59:	83 c4 10             	add    $0x10,%esp
}
  801b5c:	c9                   	leave  
  801b5d:	c3                   	ret    

00801b5e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801b5e:	55                   	push   %ebp
  801b5f:	89 e5                	mov    %esp,%ebp
  801b61:	56                   	push   %esi
  801b62:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801b63:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801b66:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801b6c:	e8 ff ef ff ff       	call   800b70 <sys_getenvid>
  801b71:	83 ec 0c             	sub    $0xc,%esp
  801b74:	ff 75 0c             	pushl  0xc(%ebp)
  801b77:	ff 75 08             	pushl  0x8(%ebp)
  801b7a:	56                   	push   %esi
  801b7b:	50                   	push   %eax
  801b7c:	68 a0 22 80 00       	push   $0x8022a0
  801b81:	e8 10 e6 ff ff       	call   800196 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b86:	83 c4 18             	add    $0x18,%esp
  801b89:	53                   	push   %ebx
  801b8a:	ff 75 10             	pushl  0x10(%ebp)
  801b8d:	e8 b3 e5 ff ff       	call   800145 <vcprintf>
	cprintf("\n");
  801b92:	c7 04 24 8b 22 80 00 	movl   $0x80228b,(%esp)
  801b99:	e8 f8 e5 ff ff       	call   800196 <cprintf>
  801b9e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ba1:	cc                   	int3   
  801ba2:	eb fd                	jmp    801ba1 <_panic+0x43>

00801ba4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ba4:	55                   	push   %ebp
  801ba5:	89 e5                	mov    %esp,%ebp
  801ba7:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801baa:	89 d0                	mov    %edx,%eax
  801bac:	c1 e8 16             	shr    $0x16,%eax
  801baf:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801bb6:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801bbb:	f6 c1 01             	test   $0x1,%cl
  801bbe:	74 1d                	je     801bdd <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801bc0:	c1 ea 0c             	shr    $0xc,%edx
  801bc3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801bca:	f6 c2 01             	test   $0x1,%dl
  801bcd:	74 0e                	je     801bdd <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bcf:	c1 ea 0c             	shr    $0xc,%edx
  801bd2:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801bd9:	ef 
  801bda:	0f b7 c0             	movzwl %ax,%eax
}
  801bdd:	5d                   	pop    %ebp
  801bde:	c3                   	ret    
  801bdf:	90                   	nop

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
