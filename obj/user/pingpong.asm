
obj/user/pingpong:     file format elf32-i386


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
  80002c:	e8 9f 00 00 00       	call   8000d0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003c:	e8 20 0e 00 00       	call   800e61 <fork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	75 5c                	jne    8000a4 <umain+0x71>
		ipc_send(who, 0, 0, 0);
	}

	while (1) {
		cprintf("is receiving\n");
		uint32_t i = ipc_recv(&who, 0, 0);
  800048:	8d 75 e4             	lea    -0x1c(%ebp),%esi
		cprintf("is receiving\n");
  80004b:	83 ec 0c             	sub    $0xc,%esp
  80004e:	68 76 14 80 00       	push   $0x801476
  800053:	e8 65 01 00 00       	call   8001bd <cprintf>
		uint32_t i = ipc_recv(&who, 0, 0);
  800058:	83 c4 0c             	add    $0xc,%esp
  80005b:	6a 00                	push   $0x0
  80005d:	6a 00                	push   $0x0
  80005f:	56                   	push   %esi
  800060:	e8 d8 0f 00 00       	call   80103d <ipc_recv>
  800065:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  800067:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80006a:	e8 28 0b 00 00       	call   800b97 <sys_getenvid>
  80006f:	57                   	push   %edi
  800070:	53                   	push   %ebx
  800071:	50                   	push   %eax
  800072:	68 84 14 80 00       	push   $0x801484
  800077:	e8 41 01 00 00       	call   8001bd <cprintf>
		if (i == 10)
  80007c:	83 c4 20             	add    $0x20,%esp
  80007f:	83 fb 0a             	cmp    $0xa,%ebx
  800082:	74 18                	je     80009c <umain+0x69>
			return;
		i++;
  800084:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  800087:	6a 00                	push   $0x0
  800089:	6a 00                	push   $0x0
  80008b:	53                   	push   %ebx
  80008c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80008f:	e8 1e 10 00 00       	call   8010b2 <ipc_send>
		if (i == 10)
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	83 fb 0a             	cmp    $0xa,%ebx
  80009a:	75 af                	jne    80004b <umain+0x18>
			return;
	}

}
  80009c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80009f:	5b                   	pop    %ebx
  8000a0:	5e                   	pop    %esi
  8000a1:	5f                   	pop    %edi
  8000a2:	5d                   	pop    %ebp
  8000a3:	c3                   	ret    
  8000a4:	89 c3                	mov    %eax,%ebx
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  8000a6:	e8 ec 0a 00 00       	call   800b97 <sys_getenvid>
  8000ab:	83 ec 04             	sub    $0x4,%esp
  8000ae:	53                   	push   %ebx
  8000af:	50                   	push   %eax
  8000b0:	68 60 14 80 00       	push   $0x801460
  8000b5:	e8 03 01 00 00       	call   8001bd <cprintf>
		ipc_send(who, 0, 0, 0);
  8000ba:	6a 00                	push   $0x0
  8000bc:	6a 00                	push   $0x0
  8000be:	6a 00                	push   $0x0
  8000c0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000c3:	e8 ea 0f 00 00       	call   8010b2 <ipc_send>
  8000c8:	83 c4 20             	add    $0x20,%esp
  8000cb:	e9 78 ff ff ff       	jmp    800048 <umain+0x15>

008000d0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000d0:	55                   	push   %ebp
  8000d1:	89 e5                	mov    %esp,%ebp
  8000d3:	56                   	push   %esi
  8000d4:	53                   	push   %ebx
  8000d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000d8:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000db:	e8 b7 0a 00 00       	call   800b97 <sys_getenvid>
  8000e0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000e5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000e8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000ed:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000f2:	85 db                	test   %ebx,%ebx
  8000f4:	7e 07                	jle    8000fd <libmain+0x2d>
		binaryname = argv[0];
  8000f6:	8b 06                	mov    (%esi),%eax
  8000f8:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000fd:	83 ec 08             	sub    $0x8,%esp
  800100:	56                   	push   %esi
  800101:	53                   	push   %ebx
  800102:	e8 2c ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800107:	e8 0a 00 00 00       	call   800116 <exit>
}
  80010c:	83 c4 10             	add    $0x10,%esp
  80010f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800112:	5b                   	pop    %ebx
  800113:	5e                   	pop    %esi
  800114:	5d                   	pop    %ebp
  800115:	c3                   	ret    

00800116 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800116:	55                   	push   %ebp
  800117:	89 e5                	mov    %esp,%ebp
  800119:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80011c:	6a 00                	push   $0x0
  80011e:	e8 33 0a 00 00       	call   800b56 <sys_env_destroy>
}
  800123:	83 c4 10             	add    $0x10,%esp
  800126:	c9                   	leave  
  800127:	c3                   	ret    

00800128 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	53                   	push   %ebx
  80012c:	83 ec 04             	sub    $0x4,%esp
  80012f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800132:	8b 13                	mov    (%ebx),%edx
  800134:	8d 42 01             	lea    0x1(%edx),%eax
  800137:	89 03                	mov    %eax,(%ebx)
  800139:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80013c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800140:	3d ff 00 00 00       	cmp    $0xff,%eax
  800145:	74 09                	je     800150 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800147:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80014b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80014e:	c9                   	leave  
  80014f:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800150:	83 ec 08             	sub    $0x8,%esp
  800153:	68 ff 00 00 00       	push   $0xff
  800158:	8d 43 08             	lea    0x8(%ebx),%eax
  80015b:	50                   	push   %eax
  80015c:	e8 b8 09 00 00       	call   800b19 <sys_cputs>
		b->idx = 0;
  800161:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800167:	83 c4 10             	add    $0x10,%esp
  80016a:	eb db                	jmp    800147 <putch+0x1f>

0080016c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800175:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80017c:	00 00 00 
	b.cnt = 0;
  80017f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800186:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800189:	ff 75 0c             	pushl  0xc(%ebp)
  80018c:	ff 75 08             	pushl  0x8(%ebp)
  80018f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800195:	50                   	push   %eax
  800196:	68 28 01 80 00       	push   $0x800128
  80019b:	e8 1a 01 00 00       	call   8002ba <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001a0:	83 c4 08             	add    $0x8,%esp
  8001a3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001a9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001af:	50                   	push   %eax
  8001b0:	e8 64 09 00 00       	call   800b19 <sys_cputs>

	return b.cnt;
}
  8001b5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001bb:	c9                   	leave  
  8001bc:	c3                   	ret    

008001bd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001bd:	55                   	push   %ebp
  8001be:	89 e5                	mov    %esp,%ebp
  8001c0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001c3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001c6:	50                   	push   %eax
  8001c7:	ff 75 08             	pushl  0x8(%ebp)
  8001ca:	e8 9d ff ff ff       	call   80016c <vcprintf>
	va_end(ap);

	return cnt;
}
  8001cf:	c9                   	leave  
  8001d0:	c3                   	ret    

008001d1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001d1:	55                   	push   %ebp
  8001d2:	89 e5                	mov    %esp,%ebp
  8001d4:	57                   	push   %edi
  8001d5:	56                   	push   %esi
  8001d6:	53                   	push   %ebx
  8001d7:	83 ec 1c             	sub    $0x1c,%esp
  8001da:	89 c7                	mov    %eax,%edi
  8001dc:	89 d6                	mov    %edx,%esi
  8001de:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001e7:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001ed:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001f5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001f8:	39 d3                	cmp    %edx,%ebx
  8001fa:	72 05                	jb     800201 <printnum+0x30>
  8001fc:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001ff:	77 7a                	ja     80027b <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800201:	83 ec 0c             	sub    $0xc,%esp
  800204:	ff 75 18             	pushl  0x18(%ebp)
  800207:	8b 45 14             	mov    0x14(%ebp),%eax
  80020a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80020d:	53                   	push   %ebx
  80020e:	ff 75 10             	pushl  0x10(%ebp)
  800211:	83 ec 08             	sub    $0x8,%esp
  800214:	ff 75 e4             	pushl  -0x1c(%ebp)
  800217:	ff 75 e0             	pushl  -0x20(%ebp)
  80021a:	ff 75 dc             	pushl  -0x24(%ebp)
  80021d:	ff 75 d8             	pushl  -0x28(%ebp)
  800220:	e8 fb 0f 00 00       	call   801220 <__udivdi3>
  800225:	83 c4 18             	add    $0x18,%esp
  800228:	52                   	push   %edx
  800229:	50                   	push   %eax
  80022a:	89 f2                	mov    %esi,%edx
  80022c:	89 f8                	mov    %edi,%eax
  80022e:	e8 9e ff ff ff       	call   8001d1 <printnum>
  800233:	83 c4 20             	add    $0x20,%esp
  800236:	eb 13                	jmp    80024b <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800238:	83 ec 08             	sub    $0x8,%esp
  80023b:	56                   	push   %esi
  80023c:	ff 75 18             	pushl  0x18(%ebp)
  80023f:	ff d7                	call   *%edi
  800241:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800244:	83 eb 01             	sub    $0x1,%ebx
  800247:	85 db                	test   %ebx,%ebx
  800249:	7f ed                	jg     800238 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80024b:	83 ec 08             	sub    $0x8,%esp
  80024e:	56                   	push   %esi
  80024f:	83 ec 04             	sub    $0x4,%esp
  800252:	ff 75 e4             	pushl  -0x1c(%ebp)
  800255:	ff 75 e0             	pushl  -0x20(%ebp)
  800258:	ff 75 dc             	pushl  -0x24(%ebp)
  80025b:	ff 75 d8             	pushl  -0x28(%ebp)
  80025e:	e8 dd 10 00 00       	call   801340 <__umoddi3>
  800263:	83 c4 14             	add    $0x14,%esp
  800266:	0f be 80 a1 14 80 00 	movsbl 0x8014a1(%eax),%eax
  80026d:	50                   	push   %eax
  80026e:	ff d7                	call   *%edi
}
  800270:	83 c4 10             	add    $0x10,%esp
  800273:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800276:	5b                   	pop    %ebx
  800277:	5e                   	pop    %esi
  800278:	5f                   	pop    %edi
  800279:	5d                   	pop    %ebp
  80027a:	c3                   	ret    
  80027b:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80027e:	eb c4                	jmp    800244 <printnum+0x73>

00800280 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800286:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80028a:	8b 10                	mov    (%eax),%edx
  80028c:	3b 50 04             	cmp    0x4(%eax),%edx
  80028f:	73 0a                	jae    80029b <sprintputch+0x1b>
		*b->buf++ = ch;
  800291:	8d 4a 01             	lea    0x1(%edx),%ecx
  800294:	89 08                	mov    %ecx,(%eax)
  800296:	8b 45 08             	mov    0x8(%ebp),%eax
  800299:	88 02                	mov    %al,(%edx)
}
  80029b:	5d                   	pop    %ebp
  80029c:	c3                   	ret    

0080029d <printfmt>:
{
  80029d:	55                   	push   %ebp
  80029e:	89 e5                	mov    %esp,%ebp
  8002a0:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002a3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002a6:	50                   	push   %eax
  8002a7:	ff 75 10             	pushl  0x10(%ebp)
  8002aa:	ff 75 0c             	pushl  0xc(%ebp)
  8002ad:	ff 75 08             	pushl  0x8(%ebp)
  8002b0:	e8 05 00 00 00       	call   8002ba <vprintfmt>
}
  8002b5:	83 c4 10             	add    $0x10,%esp
  8002b8:	c9                   	leave  
  8002b9:	c3                   	ret    

008002ba <vprintfmt>:
{
  8002ba:	55                   	push   %ebp
  8002bb:	89 e5                	mov    %esp,%ebp
  8002bd:	57                   	push   %edi
  8002be:	56                   	push   %esi
  8002bf:	53                   	push   %ebx
  8002c0:	83 ec 2c             	sub    $0x2c,%esp
  8002c3:	8b 75 08             	mov    0x8(%ebp),%esi
  8002c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002c9:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002cc:	e9 c1 03 00 00       	jmp    800692 <vprintfmt+0x3d8>
		padc = ' ';
  8002d1:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8002d5:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8002dc:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8002e3:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002ea:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002ef:	8d 47 01             	lea    0x1(%edi),%eax
  8002f2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002f5:	0f b6 17             	movzbl (%edi),%edx
  8002f8:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002fb:	3c 55                	cmp    $0x55,%al
  8002fd:	0f 87 12 04 00 00    	ja     800715 <vprintfmt+0x45b>
  800303:	0f b6 c0             	movzbl %al,%eax
  800306:	ff 24 85 60 15 80 00 	jmp    *0x801560(,%eax,4)
  80030d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800310:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800314:	eb d9                	jmp    8002ef <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800316:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800319:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80031d:	eb d0                	jmp    8002ef <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80031f:	0f b6 d2             	movzbl %dl,%edx
  800322:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800325:	b8 00 00 00 00       	mov    $0x0,%eax
  80032a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80032d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800330:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800334:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800337:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80033a:	83 f9 09             	cmp    $0x9,%ecx
  80033d:	77 55                	ja     800394 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  80033f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800342:	eb e9                	jmp    80032d <vprintfmt+0x73>
			precision = va_arg(ap, int);
  800344:	8b 45 14             	mov    0x14(%ebp),%eax
  800347:	8b 00                	mov    (%eax),%eax
  800349:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80034c:	8b 45 14             	mov    0x14(%ebp),%eax
  80034f:	8d 40 04             	lea    0x4(%eax),%eax
  800352:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800355:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800358:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80035c:	79 91                	jns    8002ef <vprintfmt+0x35>
				width = precision, precision = -1;
  80035e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800361:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800364:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80036b:	eb 82                	jmp    8002ef <vprintfmt+0x35>
  80036d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800370:	85 c0                	test   %eax,%eax
  800372:	ba 00 00 00 00       	mov    $0x0,%edx
  800377:	0f 49 d0             	cmovns %eax,%edx
  80037a:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80037d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800380:	e9 6a ff ff ff       	jmp    8002ef <vprintfmt+0x35>
  800385:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800388:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80038f:	e9 5b ff ff ff       	jmp    8002ef <vprintfmt+0x35>
  800394:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800397:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80039a:	eb bc                	jmp    800358 <vprintfmt+0x9e>
			lflag++;
  80039c:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80039f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003a2:	e9 48 ff ff ff       	jmp    8002ef <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8003a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003aa:	8d 78 04             	lea    0x4(%eax),%edi
  8003ad:	83 ec 08             	sub    $0x8,%esp
  8003b0:	53                   	push   %ebx
  8003b1:	ff 30                	pushl  (%eax)
  8003b3:	ff d6                	call   *%esi
			break;
  8003b5:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003b8:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003bb:	e9 cf 02 00 00       	jmp    80068f <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  8003c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c3:	8d 78 04             	lea    0x4(%eax),%edi
  8003c6:	8b 00                	mov    (%eax),%eax
  8003c8:	99                   	cltd   
  8003c9:	31 d0                	xor    %edx,%eax
  8003cb:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003cd:	83 f8 08             	cmp    $0x8,%eax
  8003d0:	7f 23                	jg     8003f5 <vprintfmt+0x13b>
  8003d2:	8b 14 85 c0 16 80 00 	mov    0x8016c0(,%eax,4),%edx
  8003d9:	85 d2                	test   %edx,%edx
  8003db:	74 18                	je     8003f5 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8003dd:	52                   	push   %edx
  8003de:	68 c2 14 80 00       	push   $0x8014c2
  8003e3:	53                   	push   %ebx
  8003e4:	56                   	push   %esi
  8003e5:	e8 b3 fe ff ff       	call   80029d <printfmt>
  8003ea:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003ed:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003f0:	e9 9a 02 00 00       	jmp    80068f <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  8003f5:	50                   	push   %eax
  8003f6:	68 b9 14 80 00       	push   $0x8014b9
  8003fb:	53                   	push   %ebx
  8003fc:	56                   	push   %esi
  8003fd:	e8 9b fe ff ff       	call   80029d <printfmt>
  800402:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800405:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800408:	e9 82 02 00 00       	jmp    80068f <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  80040d:	8b 45 14             	mov    0x14(%ebp),%eax
  800410:	83 c0 04             	add    $0x4,%eax
  800413:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800416:	8b 45 14             	mov    0x14(%ebp),%eax
  800419:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80041b:	85 ff                	test   %edi,%edi
  80041d:	b8 b2 14 80 00       	mov    $0x8014b2,%eax
  800422:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800425:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800429:	0f 8e bd 00 00 00    	jle    8004ec <vprintfmt+0x232>
  80042f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800433:	75 0e                	jne    800443 <vprintfmt+0x189>
  800435:	89 75 08             	mov    %esi,0x8(%ebp)
  800438:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80043b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80043e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800441:	eb 6d                	jmp    8004b0 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  800443:	83 ec 08             	sub    $0x8,%esp
  800446:	ff 75 d0             	pushl  -0x30(%ebp)
  800449:	57                   	push   %edi
  80044a:	e8 6e 03 00 00       	call   8007bd <strnlen>
  80044f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800452:	29 c1                	sub    %eax,%ecx
  800454:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800457:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80045a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80045e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800461:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800464:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800466:	eb 0f                	jmp    800477 <vprintfmt+0x1bd>
					putch(padc, putdat);
  800468:	83 ec 08             	sub    $0x8,%esp
  80046b:	53                   	push   %ebx
  80046c:	ff 75 e0             	pushl  -0x20(%ebp)
  80046f:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800471:	83 ef 01             	sub    $0x1,%edi
  800474:	83 c4 10             	add    $0x10,%esp
  800477:	85 ff                	test   %edi,%edi
  800479:	7f ed                	jg     800468 <vprintfmt+0x1ae>
  80047b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80047e:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800481:	85 c9                	test   %ecx,%ecx
  800483:	b8 00 00 00 00       	mov    $0x0,%eax
  800488:	0f 49 c1             	cmovns %ecx,%eax
  80048b:	29 c1                	sub    %eax,%ecx
  80048d:	89 75 08             	mov    %esi,0x8(%ebp)
  800490:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800493:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800496:	89 cb                	mov    %ecx,%ebx
  800498:	eb 16                	jmp    8004b0 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  80049a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80049e:	75 31                	jne    8004d1 <vprintfmt+0x217>
					putch(ch, putdat);
  8004a0:	83 ec 08             	sub    $0x8,%esp
  8004a3:	ff 75 0c             	pushl  0xc(%ebp)
  8004a6:	50                   	push   %eax
  8004a7:	ff 55 08             	call   *0x8(%ebp)
  8004aa:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ad:	83 eb 01             	sub    $0x1,%ebx
  8004b0:	83 c7 01             	add    $0x1,%edi
  8004b3:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8004b7:	0f be c2             	movsbl %dl,%eax
  8004ba:	85 c0                	test   %eax,%eax
  8004bc:	74 59                	je     800517 <vprintfmt+0x25d>
  8004be:	85 f6                	test   %esi,%esi
  8004c0:	78 d8                	js     80049a <vprintfmt+0x1e0>
  8004c2:	83 ee 01             	sub    $0x1,%esi
  8004c5:	79 d3                	jns    80049a <vprintfmt+0x1e0>
  8004c7:	89 df                	mov    %ebx,%edi
  8004c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8004cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004cf:	eb 37                	jmp    800508 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004d1:	0f be d2             	movsbl %dl,%edx
  8004d4:	83 ea 20             	sub    $0x20,%edx
  8004d7:	83 fa 5e             	cmp    $0x5e,%edx
  8004da:	76 c4                	jbe    8004a0 <vprintfmt+0x1e6>
					putch('?', putdat);
  8004dc:	83 ec 08             	sub    $0x8,%esp
  8004df:	ff 75 0c             	pushl  0xc(%ebp)
  8004e2:	6a 3f                	push   $0x3f
  8004e4:	ff 55 08             	call   *0x8(%ebp)
  8004e7:	83 c4 10             	add    $0x10,%esp
  8004ea:	eb c1                	jmp    8004ad <vprintfmt+0x1f3>
  8004ec:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ef:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004f8:	eb b6                	jmp    8004b0 <vprintfmt+0x1f6>
				putch(' ', putdat);
  8004fa:	83 ec 08             	sub    $0x8,%esp
  8004fd:	53                   	push   %ebx
  8004fe:	6a 20                	push   $0x20
  800500:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800502:	83 ef 01             	sub    $0x1,%edi
  800505:	83 c4 10             	add    $0x10,%esp
  800508:	85 ff                	test   %edi,%edi
  80050a:	7f ee                	jg     8004fa <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  80050c:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80050f:	89 45 14             	mov    %eax,0x14(%ebp)
  800512:	e9 78 01 00 00       	jmp    80068f <vprintfmt+0x3d5>
  800517:	89 df                	mov    %ebx,%edi
  800519:	8b 75 08             	mov    0x8(%ebp),%esi
  80051c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80051f:	eb e7                	jmp    800508 <vprintfmt+0x24e>
	if (lflag >= 2)
  800521:	83 f9 01             	cmp    $0x1,%ecx
  800524:	7e 3f                	jle    800565 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800526:	8b 45 14             	mov    0x14(%ebp),%eax
  800529:	8b 50 04             	mov    0x4(%eax),%edx
  80052c:	8b 00                	mov    (%eax),%eax
  80052e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800531:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800534:	8b 45 14             	mov    0x14(%ebp),%eax
  800537:	8d 40 08             	lea    0x8(%eax),%eax
  80053a:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80053d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800541:	79 5c                	jns    80059f <vprintfmt+0x2e5>
				putch('-', putdat);
  800543:	83 ec 08             	sub    $0x8,%esp
  800546:	53                   	push   %ebx
  800547:	6a 2d                	push   $0x2d
  800549:	ff d6                	call   *%esi
				num = -(long long) num;
  80054b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80054e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800551:	f7 da                	neg    %edx
  800553:	83 d1 00             	adc    $0x0,%ecx
  800556:	f7 d9                	neg    %ecx
  800558:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80055b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800560:	e9 10 01 00 00       	jmp    800675 <vprintfmt+0x3bb>
	else if (lflag)
  800565:	85 c9                	test   %ecx,%ecx
  800567:	75 1b                	jne    800584 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800569:	8b 45 14             	mov    0x14(%ebp),%eax
  80056c:	8b 00                	mov    (%eax),%eax
  80056e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800571:	89 c1                	mov    %eax,%ecx
  800573:	c1 f9 1f             	sar    $0x1f,%ecx
  800576:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800579:	8b 45 14             	mov    0x14(%ebp),%eax
  80057c:	8d 40 04             	lea    0x4(%eax),%eax
  80057f:	89 45 14             	mov    %eax,0x14(%ebp)
  800582:	eb b9                	jmp    80053d <vprintfmt+0x283>
		return va_arg(*ap, long);
  800584:	8b 45 14             	mov    0x14(%ebp),%eax
  800587:	8b 00                	mov    (%eax),%eax
  800589:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058c:	89 c1                	mov    %eax,%ecx
  80058e:	c1 f9 1f             	sar    $0x1f,%ecx
  800591:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800594:	8b 45 14             	mov    0x14(%ebp),%eax
  800597:	8d 40 04             	lea    0x4(%eax),%eax
  80059a:	89 45 14             	mov    %eax,0x14(%ebp)
  80059d:	eb 9e                	jmp    80053d <vprintfmt+0x283>
			num = getint(&ap, lflag);
  80059f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005a2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005a5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005aa:	e9 c6 00 00 00       	jmp    800675 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8005af:	83 f9 01             	cmp    $0x1,%ecx
  8005b2:	7e 18                	jle    8005cc <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8005b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b7:	8b 10                	mov    (%eax),%edx
  8005b9:	8b 48 04             	mov    0x4(%eax),%ecx
  8005bc:	8d 40 08             	lea    0x8(%eax),%eax
  8005bf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005c2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005c7:	e9 a9 00 00 00       	jmp    800675 <vprintfmt+0x3bb>
	else if (lflag)
  8005cc:	85 c9                	test   %ecx,%ecx
  8005ce:	75 1a                	jne    8005ea <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  8005d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d3:	8b 10                	mov    (%eax),%edx
  8005d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005da:	8d 40 04             	lea    0x4(%eax),%eax
  8005dd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005e0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e5:	e9 8b 00 00 00       	jmp    800675 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8005ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ed:	8b 10                	mov    (%eax),%edx
  8005ef:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f4:	8d 40 04             	lea    0x4(%eax),%eax
  8005f7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005fa:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ff:	eb 74                	jmp    800675 <vprintfmt+0x3bb>
	if (lflag >= 2)
  800601:	83 f9 01             	cmp    $0x1,%ecx
  800604:	7e 15                	jle    80061b <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  800606:	8b 45 14             	mov    0x14(%ebp),%eax
  800609:	8b 10                	mov    (%eax),%edx
  80060b:	8b 48 04             	mov    0x4(%eax),%ecx
  80060e:	8d 40 08             	lea    0x8(%eax),%eax
  800611:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800614:	b8 08 00 00 00       	mov    $0x8,%eax
  800619:	eb 5a                	jmp    800675 <vprintfmt+0x3bb>
	else if (lflag)
  80061b:	85 c9                	test   %ecx,%ecx
  80061d:	75 17                	jne    800636 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  80061f:	8b 45 14             	mov    0x14(%ebp),%eax
  800622:	8b 10                	mov    (%eax),%edx
  800624:	b9 00 00 00 00       	mov    $0x0,%ecx
  800629:	8d 40 04             	lea    0x4(%eax),%eax
  80062c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80062f:	b8 08 00 00 00       	mov    $0x8,%eax
  800634:	eb 3f                	jmp    800675 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800636:	8b 45 14             	mov    0x14(%ebp),%eax
  800639:	8b 10                	mov    (%eax),%edx
  80063b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800640:	8d 40 04             	lea    0x4(%eax),%eax
  800643:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800646:	b8 08 00 00 00       	mov    $0x8,%eax
  80064b:	eb 28                	jmp    800675 <vprintfmt+0x3bb>
			putch('0', putdat);
  80064d:	83 ec 08             	sub    $0x8,%esp
  800650:	53                   	push   %ebx
  800651:	6a 30                	push   $0x30
  800653:	ff d6                	call   *%esi
			putch('x', putdat);
  800655:	83 c4 08             	add    $0x8,%esp
  800658:	53                   	push   %ebx
  800659:	6a 78                	push   $0x78
  80065b:	ff d6                	call   *%esi
			num = (unsigned long long)
  80065d:	8b 45 14             	mov    0x14(%ebp),%eax
  800660:	8b 10                	mov    (%eax),%edx
  800662:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800667:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80066a:	8d 40 04             	lea    0x4(%eax),%eax
  80066d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800670:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800675:	83 ec 0c             	sub    $0xc,%esp
  800678:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80067c:	57                   	push   %edi
  80067d:	ff 75 e0             	pushl  -0x20(%ebp)
  800680:	50                   	push   %eax
  800681:	51                   	push   %ecx
  800682:	52                   	push   %edx
  800683:	89 da                	mov    %ebx,%edx
  800685:	89 f0                	mov    %esi,%eax
  800687:	e8 45 fb ff ff       	call   8001d1 <printnum>
			break;
  80068c:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80068f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800692:	83 c7 01             	add    $0x1,%edi
  800695:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800699:	83 f8 25             	cmp    $0x25,%eax
  80069c:	0f 84 2f fc ff ff    	je     8002d1 <vprintfmt+0x17>
			if (ch == '\0')
  8006a2:	85 c0                	test   %eax,%eax
  8006a4:	0f 84 8b 00 00 00    	je     800735 <vprintfmt+0x47b>
			putch(ch, putdat);
  8006aa:	83 ec 08             	sub    $0x8,%esp
  8006ad:	53                   	push   %ebx
  8006ae:	50                   	push   %eax
  8006af:	ff d6                	call   *%esi
  8006b1:	83 c4 10             	add    $0x10,%esp
  8006b4:	eb dc                	jmp    800692 <vprintfmt+0x3d8>
	if (lflag >= 2)
  8006b6:	83 f9 01             	cmp    $0x1,%ecx
  8006b9:	7e 15                	jle    8006d0 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  8006bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006be:	8b 10                	mov    (%eax),%edx
  8006c0:	8b 48 04             	mov    0x4(%eax),%ecx
  8006c3:	8d 40 08             	lea    0x8(%eax),%eax
  8006c6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006c9:	b8 10 00 00 00       	mov    $0x10,%eax
  8006ce:	eb a5                	jmp    800675 <vprintfmt+0x3bb>
	else if (lflag)
  8006d0:	85 c9                	test   %ecx,%ecx
  8006d2:	75 17                	jne    8006eb <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  8006d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d7:	8b 10                	mov    (%eax),%edx
  8006d9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006de:	8d 40 04             	lea    0x4(%eax),%eax
  8006e1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006e4:	b8 10 00 00 00       	mov    $0x10,%eax
  8006e9:	eb 8a                	jmp    800675 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8006eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ee:	8b 10                	mov    (%eax),%edx
  8006f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f5:	8d 40 04             	lea    0x4(%eax),%eax
  8006f8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006fb:	b8 10 00 00 00       	mov    $0x10,%eax
  800700:	e9 70 ff ff ff       	jmp    800675 <vprintfmt+0x3bb>
			putch(ch, putdat);
  800705:	83 ec 08             	sub    $0x8,%esp
  800708:	53                   	push   %ebx
  800709:	6a 25                	push   $0x25
  80070b:	ff d6                	call   *%esi
			break;
  80070d:	83 c4 10             	add    $0x10,%esp
  800710:	e9 7a ff ff ff       	jmp    80068f <vprintfmt+0x3d5>
			putch('%', putdat);
  800715:	83 ec 08             	sub    $0x8,%esp
  800718:	53                   	push   %ebx
  800719:	6a 25                	push   $0x25
  80071b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80071d:	83 c4 10             	add    $0x10,%esp
  800720:	89 f8                	mov    %edi,%eax
  800722:	eb 03                	jmp    800727 <vprintfmt+0x46d>
  800724:	83 e8 01             	sub    $0x1,%eax
  800727:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80072b:	75 f7                	jne    800724 <vprintfmt+0x46a>
  80072d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800730:	e9 5a ff ff ff       	jmp    80068f <vprintfmt+0x3d5>
}
  800735:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800738:	5b                   	pop    %ebx
  800739:	5e                   	pop    %esi
  80073a:	5f                   	pop    %edi
  80073b:	5d                   	pop    %ebp
  80073c:	c3                   	ret    

0080073d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80073d:	55                   	push   %ebp
  80073e:	89 e5                	mov    %esp,%ebp
  800740:	83 ec 18             	sub    $0x18,%esp
  800743:	8b 45 08             	mov    0x8(%ebp),%eax
  800746:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800749:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80074c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800750:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800753:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80075a:	85 c0                	test   %eax,%eax
  80075c:	74 26                	je     800784 <vsnprintf+0x47>
  80075e:	85 d2                	test   %edx,%edx
  800760:	7e 22                	jle    800784 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800762:	ff 75 14             	pushl  0x14(%ebp)
  800765:	ff 75 10             	pushl  0x10(%ebp)
  800768:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80076b:	50                   	push   %eax
  80076c:	68 80 02 80 00       	push   $0x800280
  800771:	e8 44 fb ff ff       	call   8002ba <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800776:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800779:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80077c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80077f:	83 c4 10             	add    $0x10,%esp
}
  800782:	c9                   	leave  
  800783:	c3                   	ret    
		return -E_INVAL;
  800784:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800789:	eb f7                	jmp    800782 <vsnprintf+0x45>

0080078b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80078b:	55                   	push   %ebp
  80078c:	89 e5                	mov    %esp,%ebp
  80078e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800791:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800794:	50                   	push   %eax
  800795:	ff 75 10             	pushl  0x10(%ebp)
  800798:	ff 75 0c             	pushl  0xc(%ebp)
  80079b:	ff 75 08             	pushl  0x8(%ebp)
  80079e:	e8 9a ff ff ff       	call   80073d <vsnprintf>
	va_end(ap);

	return rc;
}
  8007a3:	c9                   	leave  
  8007a4:	c3                   	ret    

008007a5 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007a5:	55                   	push   %ebp
  8007a6:	89 e5                	mov    %esp,%ebp
  8007a8:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b0:	eb 03                	jmp    8007b5 <strlen+0x10>
		n++;
  8007b2:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007b5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007b9:	75 f7                	jne    8007b2 <strlen+0xd>
	return n;
}
  8007bb:	5d                   	pop    %ebp
  8007bc:	c3                   	ret    

008007bd <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007bd:	55                   	push   %ebp
  8007be:	89 e5                	mov    %esp,%ebp
  8007c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c3:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007cb:	eb 03                	jmp    8007d0 <strnlen+0x13>
		n++;
  8007cd:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d0:	39 d0                	cmp    %edx,%eax
  8007d2:	74 06                	je     8007da <strnlen+0x1d>
  8007d4:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007d8:	75 f3                	jne    8007cd <strnlen+0x10>
	return n;
}
  8007da:	5d                   	pop    %ebp
  8007db:	c3                   	ret    

008007dc <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	53                   	push   %ebx
  8007e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007e6:	89 c2                	mov    %eax,%edx
  8007e8:	83 c1 01             	add    $0x1,%ecx
  8007eb:	83 c2 01             	add    $0x1,%edx
  8007ee:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007f2:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007f5:	84 db                	test   %bl,%bl
  8007f7:	75 ef                	jne    8007e8 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007f9:	5b                   	pop    %ebx
  8007fa:	5d                   	pop    %ebp
  8007fb:	c3                   	ret    

008007fc <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
  8007ff:	53                   	push   %ebx
  800800:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800803:	53                   	push   %ebx
  800804:	e8 9c ff ff ff       	call   8007a5 <strlen>
  800809:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80080c:	ff 75 0c             	pushl  0xc(%ebp)
  80080f:	01 d8                	add    %ebx,%eax
  800811:	50                   	push   %eax
  800812:	e8 c5 ff ff ff       	call   8007dc <strcpy>
	return dst;
}
  800817:	89 d8                	mov    %ebx,%eax
  800819:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80081c:	c9                   	leave  
  80081d:	c3                   	ret    

0080081e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80081e:	55                   	push   %ebp
  80081f:	89 e5                	mov    %esp,%ebp
  800821:	56                   	push   %esi
  800822:	53                   	push   %ebx
  800823:	8b 75 08             	mov    0x8(%ebp),%esi
  800826:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800829:	89 f3                	mov    %esi,%ebx
  80082b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80082e:	89 f2                	mov    %esi,%edx
  800830:	eb 0f                	jmp    800841 <strncpy+0x23>
		*dst++ = *src;
  800832:	83 c2 01             	add    $0x1,%edx
  800835:	0f b6 01             	movzbl (%ecx),%eax
  800838:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80083b:	80 39 01             	cmpb   $0x1,(%ecx)
  80083e:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800841:	39 da                	cmp    %ebx,%edx
  800843:	75 ed                	jne    800832 <strncpy+0x14>
	}
	return ret;
}
  800845:	89 f0                	mov    %esi,%eax
  800847:	5b                   	pop    %ebx
  800848:	5e                   	pop    %esi
  800849:	5d                   	pop    %ebp
  80084a:	c3                   	ret    

0080084b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	56                   	push   %esi
  80084f:	53                   	push   %ebx
  800850:	8b 75 08             	mov    0x8(%ebp),%esi
  800853:	8b 55 0c             	mov    0xc(%ebp),%edx
  800856:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800859:	89 f0                	mov    %esi,%eax
  80085b:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80085f:	85 c9                	test   %ecx,%ecx
  800861:	75 0b                	jne    80086e <strlcpy+0x23>
  800863:	eb 17                	jmp    80087c <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800865:	83 c2 01             	add    $0x1,%edx
  800868:	83 c0 01             	add    $0x1,%eax
  80086b:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  80086e:	39 d8                	cmp    %ebx,%eax
  800870:	74 07                	je     800879 <strlcpy+0x2e>
  800872:	0f b6 0a             	movzbl (%edx),%ecx
  800875:	84 c9                	test   %cl,%cl
  800877:	75 ec                	jne    800865 <strlcpy+0x1a>
		*dst = '\0';
  800879:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80087c:	29 f0                	sub    %esi,%eax
}
  80087e:	5b                   	pop    %ebx
  80087f:	5e                   	pop    %esi
  800880:	5d                   	pop    %ebp
  800881:	c3                   	ret    

00800882 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800888:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80088b:	eb 06                	jmp    800893 <strcmp+0x11>
		p++, q++;
  80088d:	83 c1 01             	add    $0x1,%ecx
  800890:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800893:	0f b6 01             	movzbl (%ecx),%eax
  800896:	84 c0                	test   %al,%al
  800898:	74 04                	je     80089e <strcmp+0x1c>
  80089a:	3a 02                	cmp    (%edx),%al
  80089c:	74 ef                	je     80088d <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80089e:	0f b6 c0             	movzbl %al,%eax
  8008a1:	0f b6 12             	movzbl (%edx),%edx
  8008a4:	29 d0                	sub    %edx,%eax
}
  8008a6:	5d                   	pop    %ebp
  8008a7:	c3                   	ret    

008008a8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008a8:	55                   	push   %ebp
  8008a9:	89 e5                	mov    %esp,%ebp
  8008ab:	53                   	push   %ebx
  8008ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8008af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b2:	89 c3                	mov    %eax,%ebx
  8008b4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008b7:	eb 06                	jmp    8008bf <strncmp+0x17>
		n--, p++, q++;
  8008b9:	83 c0 01             	add    $0x1,%eax
  8008bc:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008bf:	39 d8                	cmp    %ebx,%eax
  8008c1:	74 16                	je     8008d9 <strncmp+0x31>
  8008c3:	0f b6 08             	movzbl (%eax),%ecx
  8008c6:	84 c9                	test   %cl,%cl
  8008c8:	74 04                	je     8008ce <strncmp+0x26>
  8008ca:	3a 0a                	cmp    (%edx),%cl
  8008cc:	74 eb                	je     8008b9 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ce:	0f b6 00             	movzbl (%eax),%eax
  8008d1:	0f b6 12             	movzbl (%edx),%edx
  8008d4:	29 d0                	sub    %edx,%eax
}
  8008d6:	5b                   	pop    %ebx
  8008d7:	5d                   	pop    %ebp
  8008d8:	c3                   	ret    
		return 0;
  8008d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8008de:	eb f6                	jmp    8008d6 <strncmp+0x2e>

008008e0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ea:	0f b6 10             	movzbl (%eax),%edx
  8008ed:	84 d2                	test   %dl,%dl
  8008ef:	74 09                	je     8008fa <strchr+0x1a>
		if (*s == c)
  8008f1:	38 ca                	cmp    %cl,%dl
  8008f3:	74 0a                	je     8008ff <strchr+0x1f>
	for (; *s; s++)
  8008f5:	83 c0 01             	add    $0x1,%eax
  8008f8:	eb f0                	jmp    8008ea <strchr+0xa>
			return (char *) s;
	return 0;
  8008fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008ff:	5d                   	pop    %ebp
  800900:	c3                   	ret    

00800901 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800901:	55                   	push   %ebp
  800902:	89 e5                	mov    %esp,%ebp
  800904:	8b 45 08             	mov    0x8(%ebp),%eax
  800907:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80090b:	eb 03                	jmp    800910 <strfind+0xf>
  80090d:	83 c0 01             	add    $0x1,%eax
  800910:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800913:	38 ca                	cmp    %cl,%dl
  800915:	74 04                	je     80091b <strfind+0x1a>
  800917:	84 d2                	test   %dl,%dl
  800919:	75 f2                	jne    80090d <strfind+0xc>
			break;
	return (char *) s;
}
  80091b:	5d                   	pop    %ebp
  80091c:	c3                   	ret    

0080091d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	57                   	push   %edi
  800921:	56                   	push   %esi
  800922:	53                   	push   %ebx
  800923:	8b 7d 08             	mov    0x8(%ebp),%edi
  800926:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800929:	85 c9                	test   %ecx,%ecx
  80092b:	74 13                	je     800940 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80092d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800933:	75 05                	jne    80093a <memset+0x1d>
  800935:	f6 c1 03             	test   $0x3,%cl
  800938:	74 0d                	je     800947 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80093a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093d:	fc                   	cld    
  80093e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800940:	89 f8                	mov    %edi,%eax
  800942:	5b                   	pop    %ebx
  800943:	5e                   	pop    %esi
  800944:	5f                   	pop    %edi
  800945:	5d                   	pop    %ebp
  800946:	c3                   	ret    
		c &= 0xFF;
  800947:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80094b:	89 d3                	mov    %edx,%ebx
  80094d:	c1 e3 08             	shl    $0x8,%ebx
  800950:	89 d0                	mov    %edx,%eax
  800952:	c1 e0 18             	shl    $0x18,%eax
  800955:	89 d6                	mov    %edx,%esi
  800957:	c1 e6 10             	shl    $0x10,%esi
  80095a:	09 f0                	or     %esi,%eax
  80095c:	09 c2                	or     %eax,%edx
  80095e:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800960:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800963:	89 d0                	mov    %edx,%eax
  800965:	fc                   	cld    
  800966:	f3 ab                	rep stos %eax,%es:(%edi)
  800968:	eb d6                	jmp    800940 <memset+0x23>

0080096a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	57                   	push   %edi
  80096e:	56                   	push   %esi
  80096f:	8b 45 08             	mov    0x8(%ebp),%eax
  800972:	8b 75 0c             	mov    0xc(%ebp),%esi
  800975:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800978:	39 c6                	cmp    %eax,%esi
  80097a:	73 35                	jae    8009b1 <memmove+0x47>
  80097c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80097f:	39 c2                	cmp    %eax,%edx
  800981:	76 2e                	jbe    8009b1 <memmove+0x47>
		s += n;
		d += n;
  800983:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800986:	89 d6                	mov    %edx,%esi
  800988:	09 fe                	or     %edi,%esi
  80098a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800990:	74 0c                	je     80099e <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800992:	83 ef 01             	sub    $0x1,%edi
  800995:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800998:	fd                   	std    
  800999:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80099b:	fc                   	cld    
  80099c:	eb 21                	jmp    8009bf <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099e:	f6 c1 03             	test   $0x3,%cl
  8009a1:	75 ef                	jne    800992 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009a3:	83 ef 04             	sub    $0x4,%edi
  8009a6:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009a9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009ac:	fd                   	std    
  8009ad:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009af:	eb ea                	jmp    80099b <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b1:	89 f2                	mov    %esi,%edx
  8009b3:	09 c2                	or     %eax,%edx
  8009b5:	f6 c2 03             	test   $0x3,%dl
  8009b8:	74 09                	je     8009c3 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009ba:	89 c7                	mov    %eax,%edi
  8009bc:	fc                   	cld    
  8009bd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009bf:	5e                   	pop    %esi
  8009c0:	5f                   	pop    %edi
  8009c1:	5d                   	pop    %ebp
  8009c2:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c3:	f6 c1 03             	test   $0x3,%cl
  8009c6:	75 f2                	jne    8009ba <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009c8:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009cb:	89 c7                	mov    %eax,%edi
  8009cd:	fc                   	cld    
  8009ce:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d0:	eb ed                	jmp    8009bf <memmove+0x55>

008009d2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009d2:	55                   	push   %ebp
  8009d3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009d5:	ff 75 10             	pushl  0x10(%ebp)
  8009d8:	ff 75 0c             	pushl  0xc(%ebp)
  8009db:	ff 75 08             	pushl  0x8(%ebp)
  8009de:	e8 87 ff ff ff       	call   80096a <memmove>
}
  8009e3:	c9                   	leave  
  8009e4:	c3                   	ret    

008009e5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	56                   	push   %esi
  8009e9:	53                   	push   %ebx
  8009ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f0:	89 c6                	mov    %eax,%esi
  8009f2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f5:	39 f0                	cmp    %esi,%eax
  8009f7:	74 1c                	je     800a15 <memcmp+0x30>
		if (*s1 != *s2)
  8009f9:	0f b6 08             	movzbl (%eax),%ecx
  8009fc:	0f b6 1a             	movzbl (%edx),%ebx
  8009ff:	38 d9                	cmp    %bl,%cl
  800a01:	75 08                	jne    800a0b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a03:	83 c0 01             	add    $0x1,%eax
  800a06:	83 c2 01             	add    $0x1,%edx
  800a09:	eb ea                	jmp    8009f5 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a0b:	0f b6 c1             	movzbl %cl,%eax
  800a0e:	0f b6 db             	movzbl %bl,%ebx
  800a11:	29 d8                	sub    %ebx,%eax
  800a13:	eb 05                	jmp    800a1a <memcmp+0x35>
	}

	return 0;
  800a15:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1a:	5b                   	pop    %ebx
  800a1b:	5e                   	pop    %esi
  800a1c:	5d                   	pop    %ebp
  800a1d:	c3                   	ret    

00800a1e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	8b 45 08             	mov    0x8(%ebp),%eax
  800a24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a27:	89 c2                	mov    %eax,%edx
  800a29:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a2c:	39 d0                	cmp    %edx,%eax
  800a2e:	73 09                	jae    800a39 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a30:	38 08                	cmp    %cl,(%eax)
  800a32:	74 05                	je     800a39 <memfind+0x1b>
	for (; s < ends; s++)
  800a34:	83 c0 01             	add    $0x1,%eax
  800a37:	eb f3                	jmp    800a2c <memfind+0xe>
			break;
	return (void *) s;
}
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    

00800a3b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	57                   	push   %edi
  800a3f:	56                   	push   %esi
  800a40:	53                   	push   %ebx
  800a41:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a44:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a47:	eb 03                	jmp    800a4c <strtol+0x11>
		s++;
  800a49:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a4c:	0f b6 01             	movzbl (%ecx),%eax
  800a4f:	3c 20                	cmp    $0x20,%al
  800a51:	74 f6                	je     800a49 <strtol+0xe>
  800a53:	3c 09                	cmp    $0x9,%al
  800a55:	74 f2                	je     800a49 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a57:	3c 2b                	cmp    $0x2b,%al
  800a59:	74 2e                	je     800a89 <strtol+0x4e>
	int neg = 0;
  800a5b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a60:	3c 2d                	cmp    $0x2d,%al
  800a62:	74 2f                	je     800a93 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a64:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a6a:	75 05                	jne    800a71 <strtol+0x36>
  800a6c:	80 39 30             	cmpb   $0x30,(%ecx)
  800a6f:	74 2c                	je     800a9d <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a71:	85 db                	test   %ebx,%ebx
  800a73:	75 0a                	jne    800a7f <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a75:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a7a:	80 39 30             	cmpb   $0x30,(%ecx)
  800a7d:	74 28                	je     800aa7 <strtol+0x6c>
		base = 10;
  800a7f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a84:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a87:	eb 50                	jmp    800ad9 <strtol+0x9e>
		s++;
  800a89:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a8c:	bf 00 00 00 00       	mov    $0x0,%edi
  800a91:	eb d1                	jmp    800a64 <strtol+0x29>
		s++, neg = 1;
  800a93:	83 c1 01             	add    $0x1,%ecx
  800a96:	bf 01 00 00 00       	mov    $0x1,%edi
  800a9b:	eb c7                	jmp    800a64 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a9d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aa1:	74 0e                	je     800ab1 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800aa3:	85 db                	test   %ebx,%ebx
  800aa5:	75 d8                	jne    800a7f <strtol+0x44>
		s++, base = 8;
  800aa7:	83 c1 01             	add    $0x1,%ecx
  800aaa:	bb 08 00 00 00       	mov    $0x8,%ebx
  800aaf:	eb ce                	jmp    800a7f <strtol+0x44>
		s += 2, base = 16;
  800ab1:	83 c1 02             	add    $0x2,%ecx
  800ab4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ab9:	eb c4                	jmp    800a7f <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800abb:	8d 72 9f             	lea    -0x61(%edx),%esi
  800abe:	89 f3                	mov    %esi,%ebx
  800ac0:	80 fb 19             	cmp    $0x19,%bl
  800ac3:	77 29                	ja     800aee <strtol+0xb3>
			dig = *s - 'a' + 10;
  800ac5:	0f be d2             	movsbl %dl,%edx
  800ac8:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800acb:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ace:	7d 30                	jge    800b00 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800ad0:	83 c1 01             	add    $0x1,%ecx
  800ad3:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ad7:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ad9:	0f b6 11             	movzbl (%ecx),%edx
  800adc:	8d 72 d0             	lea    -0x30(%edx),%esi
  800adf:	89 f3                	mov    %esi,%ebx
  800ae1:	80 fb 09             	cmp    $0x9,%bl
  800ae4:	77 d5                	ja     800abb <strtol+0x80>
			dig = *s - '0';
  800ae6:	0f be d2             	movsbl %dl,%edx
  800ae9:	83 ea 30             	sub    $0x30,%edx
  800aec:	eb dd                	jmp    800acb <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800aee:	8d 72 bf             	lea    -0x41(%edx),%esi
  800af1:	89 f3                	mov    %esi,%ebx
  800af3:	80 fb 19             	cmp    $0x19,%bl
  800af6:	77 08                	ja     800b00 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800af8:	0f be d2             	movsbl %dl,%edx
  800afb:	83 ea 37             	sub    $0x37,%edx
  800afe:	eb cb                	jmp    800acb <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b00:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b04:	74 05                	je     800b0b <strtol+0xd0>
		*endptr = (char *) s;
  800b06:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b09:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b0b:	89 c2                	mov    %eax,%edx
  800b0d:	f7 da                	neg    %edx
  800b0f:	85 ff                	test   %edi,%edi
  800b11:	0f 45 c2             	cmovne %edx,%eax
}
  800b14:	5b                   	pop    %ebx
  800b15:	5e                   	pop    %esi
  800b16:	5f                   	pop    %edi
  800b17:	5d                   	pop    %ebp
  800b18:	c3                   	ret    

00800b19 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b19:	55                   	push   %ebp
  800b1a:	89 e5                	mov    %esp,%ebp
  800b1c:	57                   	push   %edi
  800b1d:	56                   	push   %esi
  800b1e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b1f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b24:	8b 55 08             	mov    0x8(%ebp),%edx
  800b27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b2a:	89 c3                	mov    %eax,%ebx
  800b2c:	89 c7                	mov    %eax,%edi
  800b2e:	89 c6                	mov    %eax,%esi
  800b30:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b32:	5b                   	pop    %ebx
  800b33:	5e                   	pop    %esi
  800b34:	5f                   	pop    %edi
  800b35:	5d                   	pop    %ebp
  800b36:	c3                   	ret    

00800b37 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	57                   	push   %edi
  800b3b:	56                   	push   %esi
  800b3c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b3d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b42:	b8 01 00 00 00       	mov    $0x1,%eax
  800b47:	89 d1                	mov    %edx,%ecx
  800b49:	89 d3                	mov    %edx,%ebx
  800b4b:	89 d7                	mov    %edx,%edi
  800b4d:	89 d6                	mov    %edx,%esi
  800b4f:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b51:	5b                   	pop    %ebx
  800b52:	5e                   	pop    %esi
  800b53:	5f                   	pop    %edi
  800b54:	5d                   	pop    %ebp
  800b55:	c3                   	ret    

00800b56 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	57                   	push   %edi
  800b5a:	56                   	push   %esi
  800b5b:	53                   	push   %ebx
  800b5c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b5f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b64:	8b 55 08             	mov    0x8(%ebp),%edx
  800b67:	b8 03 00 00 00       	mov    $0x3,%eax
  800b6c:	89 cb                	mov    %ecx,%ebx
  800b6e:	89 cf                	mov    %ecx,%edi
  800b70:	89 ce                	mov    %ecx,%esi
  800b72:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b74:	85 c0                	test   %eax,%eax
  800b76:	7f 08                	jg     800b80 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7b:	5b                   	pop    %ebx
  800b7c:	5e                   	pop    %esi
  800b7d:	5f                   	pop    %edi
  800b7e:	5d                   	pop    %ebp
  800b7f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b80:	83 ec 0c             	sub    $0xc,%esp
  800b83:	50                   	push   %eax
  800b84:	6a 03                	push   $0x3
  800b86:	68 e4 16 80 00       	push   $0x8016e4
  800b8b:	6a 23                	push   $0x23
  800b8d:	68 01 17 80 00       	push   $0x801701
  800b92:	e8 aa 05 00 00       	call   801141 <_panic>

00800b97 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b97:	55                   	push   %ebp
  800b98:	89 e5                	mov    %esp,%ebp
  800b9a:	57                   	push   %edi
  800b9b:	56                   	push   %esi
  800b9c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b9d:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba2:	b8 02 00 00 00       	mov    $0x2,%eax
  800ba7:	89 d1                	mov    %edx,%ecx
  800ba9:	89 d3                	mov    %edx,%ebx
  800bab:	89 d7                	mov    %edx,%edi
  800bad:	89 d6                	mov    %edx,%esi
  800baf:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bb1:	5b                   	pop    %ebx
  800bb2:	5e                   	pop    %esi
  800bb3:	5f                   	pop    %edi
  800bb4:	5d                   	pop    %ebp
  800bb5:	c3                   	ret    

00800bb6 <sys_yield>:

void
sys_yield(void)
{
  800bb6:	55                   	push   %ebp
  800bb7:	89 e5                	mov    %esp,%ebp
  800bb9:	57                   	push   %edi
  800bba:	56                   	push   %esi
  800bbb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bbc:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bc6:	89 d1                	mov    %edx,%ecx
  800bc8:	89 d3                	mov    %edx,%ebx
  800bca:	89 d7                	mov    %edx,%edi
  800bcc:	89 d6                	mov    %edx,%esi
  800bce:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bd0:	5b                   	pop    %ebx
  800bd1:	5e                   	pop    %esi
  800bd2:	5f                   	pop    %edi
  800bd3:	5d                   	pop    %ebp
  800bd4:	c3                   	ret    

00800bd5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bd5:	55                   	push   %ebp
  800bd6:	89 e5                	mov    %esp,%ebp
  800bd8:	57                   	push   %edi
  800bd9:	56                   	push   %esi
  800bda:	53                   	push   %ebx
  800bdb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bde:	be 00 00 00 00       	mov    $0x0,%esi
  800be3:	8b 55 08             	mov    0x8(%ebp),%edx
  800be6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be9:	b8 04 00 00 00       	mov    $0x4,%eax
  800bee:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf1:	89 f7                	mov    %esi,%edi
  800bf3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bf5:	85 c0                	test   %eax,%eax
  800bf7:	7f 08                	jg     800c01 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bf9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfc:	5b                   	pop    %ebx
  800bfd:	5e                   	pop    %esi
  800bfe:	5f                   	pop    %edi
  800bff:	5d                   	pop    %ebp
  800c00:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c01:	83 ec 0c             	sub    $0xc,%esp
  800c04:	50                   	push   %eax
  800c05:	6a 04                	push   $0x4
  800c07:	68 e4 16 80 00       	push   $0x8016e4
  800c0c:	6a 23                	push   $0x23
  800c0e:	68 01 17 80 00       	push   $0x801701
  800c13:	e8 29 05 00 00       	call   801141 <_panic>

00800c18 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c18:	55                   	push   %ebp
  800c19:	89 e5                	mov    %esp,%ebp
  800c1b:	57                   	push   %edi
  800c1c:	56                   	push   %esi
  800c1d:	53                   	push   %ebx
  800c1e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c21:	8b 55 08             	mov    0x8(%ebp),%edx
  800c24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c27:	b8 05 00 00 00       	mov    $0x5,%eax
  800c2c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c2f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c32:	8b 75 18             	mov    0x18(%ebp),%esi
  800c35:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c37:	85 c0                	test   %eax,%eax
  800c39:	7f 08                	jg     800c43 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3e:	5b                   	pop    %ebx
  800c3f:	5e                   	pop    %esi
  800c40:	5f                   	pop    %edi
  800c41:	5d                   	pop    %ebp
  800c42:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c43:	83 ec 0c             	sub    $0xc,%esp
  800c46:	50                   	push   %eax
  800c47:	6a 05                	push   $0x5
  800c49:	68 e4 16 80 00       	push   $0x8016e4
  800c4e:	6a 23                	push   $0x23
  800c50:	68 01 17 80 00       	push   $0x801701
  800c55:	e8 e7 04 00 00       	call   801141 <_panic>

00800c5a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c5a:	55                   	push   %ebp
  800c5b:	89 e5                	mov    %esp,%ebp
  800c5d:	57                   	push   %edi
  800c5e:	56                   	push   %esi
  800c5f:	53                   	push   %ebx
  800c60:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c63:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c68:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6e:	b8 06 00 00 00       	mov    $0x6,%eax
  800c73:	89 df                	mov    %ebx,%edi
  800c75:	89 de                	mov    %ebx,%esi
  800c77:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c79:	85 c0                	test   %eax,%eax
  800c7b:	7f 08                	jg     800c85 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c80:	5b                   	pop    %ebx
  800c81:	5e                   	pop    %esi
  800c82:	5f                   	pop    %edi
  800c83:	5d                   	pop    %ebp
  800c84:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c85:	83 ec 0c             	sub    $0xc,%esp
  800c88:	50                   	push   %eax
  800c89:	6a 06                	push   $0x6
  800c8b:	68 e4 16 80 00       	push   $0x8016e4
  800c90:	6a 23                	push   $0x23
  800c92:	68 01 17 80 00       	push   $0x801701
  800c97:	e8 a5 04 00 00       	call   801141 <_panic>

00800c9c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c9c:	55                   	push   %ebp
  800c9d:	89 e5                	mov    %esp,%ebp
  800c9f:	57                   	push   %edi
  800ca0:	56                   	push   %esi
  800ca1:	53                   	push   %ebx
  800ca2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ca5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800caa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb0:	b8 08 00 00 00       	mov    $0x8,%eax
  800cb5:	89 df                	mov    %ebx,%edi
  800cb7:	89 de                	mov    %ebx,%esi
  800cb9:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cbb:	85 c0                	test   %eax,%eax
  800cbd:	7f 08                	jg     800cc7 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cbf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc2:	5b                   	pop    %ebx
  800cc3:	5e                   	pop    %esi
  800cc4:	5f                   	pop    %edi
  800cc5:	5d                   	pop    %ebp
  800cc6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc7:	83 ec 0c             	sub    $0xc,%esp
  800cca:	50                   	push   %eax
  800ccb:	6a 08                	push   $0x8
  800ccd:	68 e4 16 80 00       	push   $0x8016e4
  800cd2:	6a 23                	push   $0x23
  800cd4:	68 01 17 80 00       	push   $0x801701
  800cd9:	e8 63 04 00 00       	call   801141 <_panic>

00800cde <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cde:	55                   	push   %ebp
  800cdf:	89 e5                	mov    %esp,%ebp
  800ce1:	57                   	push   %edi
  800ce2:	56                   	push   %esi
  800ce3:	53                   	push   %ebx
  800ce4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ce7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cec:	8b 55 08             	mov    0x8(%ebp),%edx
  800cef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf2:	b8 09 00 00 00       	mov    $0x9,%eax
  800cf7:	89 df                	mov    %ebx,%edi
  800cf9:	89 de                	mov    %ebx,%esi
  800cfb:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cfd:	85 c0                	test   %eax,%eax
  800cff:	7f 08                	jg     800d09 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d04:	5b                   	pop    %ebx
  800d05:	5e                   	pop    %esi
  800d06:	5f                   	pop    %edi
  800d07:	5d                   	pop    %ebp
  800d08:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d09:	83 ec 0c             	sub    $0xc,%esp
  800d0c:	50                   	push   %eax
  800d0d:	6a 09                	push   $0x9
  800d0f:	68 e4 16 80 00       	push   $0x8016e4
  800d14:	6a 23                	push   $0x23
  800d16:	68 01 17 80 00       	push   $0x801701
  800d1b:	e8 21 04 00 00       	call   801141 <_panic>

00800d20 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d20:	55                   	push   %ebp
  800d21:	89 e5                	mov    %esp,%ebp
  800d23:	57                   	push   %edi
  800d24:	56                   	push   %esi
  800d25:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d26:	8b 55 08             	mov    0x8(%ebp),%edx
  800d29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d31:	be 00 00 00 00       	mov    $0x0,%esi
  800d36:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d39:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d3c:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d3e:	5b                   	pop    %ebx
  800d3f:	5e                   	pop    %esi
  800d40:	5f                   	pop    %edi
  800d41:	5d                   	pop    %ebp
  800d42:	c3                   	ret    

00800d43 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d43:	55                   	push   %ebp
  800d44:	89 e5                	mov    %esp,%ebp
  800d46:	57                   	push   %edi
  800d47:	56                   	push   %esi
  800d48:	53                   	push   %ebx
  800d49:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d4c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d51:	8b 55 08             	mov    0x8(%ebp),%edx
  800d54:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d59:	89 cb                	mov    %ecx,%ebx
  800d5b:	89 cf                	mov    %ecx,%edi
  800d5d:	89 ce                	mov    %ecx,%esi
  800d5f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d61:	85 c0                	test   %eax,%eax
  800d63:	7f 08                	jg     800d6d <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d68:	5b                   	pop    %ebx
  800d69:	5e                   	pop    %esi
  800d6a:	5f                   	pop    %edi
  800d6b:	5d                   	pop    %ebp
  800d6c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6d:	83 ec 0c             	sub    $0xc,%esp
  800d70:	50                   	push   %eax
  800d71:	6a 0c                	push   $0xc
  800d73:	68 e4 16 80 00       	push   $0x8016e4
  800d78:	6a 23                	push   $0x23
  800d7a:	68 01 17 80 00       	push   $0x801701
  800d7f:	e8 bd 03 00 00       	call   801141 <_panic>

00800d84 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d84:	55                   	push   %ebp
  800d85:	89 e5                	mov    %esp,%ebp
  800d87:	56                   	push   %esi
  800d88:	53                   	push   %ebx
  800d89:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d8c:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if((err&FEC_WR)==0 || (uvpt[PGNUM(addr)]&PTE_COW)==0){
  800d8e:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d92:	74 7f                	je     800e13 <pgfault+0x8f>
  800d94:	89 d8                	mov    %ebx,%eax
  800d96:	c1 e8 0c             	shr    $0xc,%eax
  800d99:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800da0:	f6 c4 08             	test   $0x8,%ah
  800da3:	74 6e                	je     800e13 <pgfault+0x8f>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        envid_t envid = sys_getenvid();
  800da5:	e8 ed fd ff ff       	call   800b97 <sys_getenvid>
  800daa:	89 c6                	mov    %eax,%esi
	r = sys_page_alloc(envid,(void *)PFTEMP,PTE_P|PTE_W|PTE_U);
  800dac:	83 ec 04             	sub    $0x4,%esp
  800daf:	6a 07                	push   $0x7
  800db1:	68 00 f0 7f 00       	push   $0x7ff000
  800db6:	50                   	push   %eax
  800db7:	e8 19 fe ff ff       	call   800bd5 <sys_page_alloc>
	if(r<0) panic("pgfault:page allocation failed %e",r);
  800dbc:	83 c4 10             	add    $0x10,%esp
  800dbf:	85 c0                	test   %eax,%eax
  800dc1:	78 64                	js     800e27 <pgfault+0xa3>
	addr = ROUNDDOWN(addr,PGSIZE);
  800dc3:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy((void *)PFTEMP,(const void *)addr,PGSIZE);
  800dc9:	83 ec 04             	sub    $0x4,%esp
  800dcc:	68 00 10 00 00       	push   $0x1000
  800dd1:	53                   	push   %ebx
  800dd2:	68 00 f0 7f 00       	push   $0x7ff000
  800dd7:	e8 f6 fb ff ff       	call   8009d2 <memcpy>
	if(sys_page_map(envid,(void *)PFTEMP, envid,addr,PTE_P|PTE_W|PTE_U)<0)
  800ddc:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800de3:	53                   	push   %ebx
  800de4:	56                   	push   %esi
  800de5:	68 00 f0 7f 00       	push   $0x7ff000
  800dea:	56                   	push   %esi
  800deb:	e8 28 fe ff ff       	call   800c18 <sys_page_map>
  800df0:	83 c4 20             	add    $0x20,%esp
  800df3:	85 c0                	test   %eax,%eax
  800df5:	78 42                	js     800e39 <pgfault+0xb5>
		panic("pgfault:page map failed\n");
	if(sys_page_unmap(envid,(void *)PFTEMP)<0)
  800df7:	83 ec 08             	sub    $0x8,%esp
  800dfa:	68 00 f0 7f 00       	push   $0x7ff000
  800dff:	56                   	push   %esi
  800e00:	e8 55 fe ff ff       	call   800c5a <sys_page_unmap>
  800e05:	83 c4 10             	add    $0x10,%esp
  800e08:	85 c0                	test   %eax,%eax
  800e0a:	78 41                	js     800e4d <pgfault+0xc9>
		panic("pgfault: page upmap failed\n");
       //	panic("pgfault not implemented");
}
  800e0c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e0f:	5b                   	pop    %ebx
  800e10:	5e                   	pop    %esi
  800e11:	5d                   	pop    %ebp
  800e12:	c3                   	ret    
		panic("pgfault:invalid user trap");
  800e13:	83 ec 04             	sub    $0x4,%esp
  800e16:	68 0f 17 80 00       	push   $0x80170f
  800e1b:	6a 1e                	push   $0x1e
  800e1d:	68 29 17 80 00       	push   $0x801729
  800e22:	e8 1a 03 00 00       	call   801141 <_panic>
	if(r<0) panic("pgfault:page allocation failed %e",r);
  800e27:	50                   	push   %eax
  800e28:	68 14 18 80 00       	push   $0x801814
  800e2d:	6a 29                	push   $0x29
  800e2f:	68 29 17 80 00       	push   $0x801729
  800e34:	e8 08 03 00 00       	call   801141 <_panic>
		panic("pgfault:page map failed\n");
  800e39:	83 ec 04             	sub    $0x4,%esp
  800e3c:	68 34 17 80 00       	push   $0x801734
  800e41:	6a 2d                	push   $0x2d
  800e43:	68 29 17 80 00       	push   $0x801729
  800e48:	e8 f4 02 00 00       	call   801141 <_panic>
		panic("pgfault: page upmap failed\n");
  800e4d:	83 ec 04             	sub    $0x4,%esp
  800e50:	68 4d 17 80 00       	push   $0x80174d
  800e55:	6a 2f                	push   $0x2f
  800e57:	68 29 17 80 00       	push   $0x801729
  800e5c:	e8 e0 02 00 00       	call   801141 <_panic>

00800e61 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e61:	55                   	push   %ebp
  800e62:	89 e5                	mov    %esp,%ebp
  800e64:	57                   	push   %edi
  800e65:	56                   	push   %esi
  800e66:	53                   	push   %ebx
  800e67:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	set_pgfault_handler(pgfault);
  800e6a:	68 84 0d 80 00       	push   $0x800d84
  800e6f:	e8 13 03 00 00       	call   801187 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e74:	b8 07 00 00 00       	mov    $0x7,%eax
  800e79:	cd 30                	int    $0x30
  800e7b:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800e7e:	89 45 e0             	mov    %eax,-0x20(%ebp)
       
	envid_t envid = sys_exofork();
	uintptr_t addr;
  
	if(envid<0) panic("sys_exofork failed\n");
  800e81:	83 c4 10             	add    $0x10,%esp
  800e84:	85 c0                	test   %eax,%eax
  800e86:	78 28                	js     800eb0 <fork+0x4f>
	if(envid==0){
	  thisenv = &envs[ENVX(sys_getenvid())];
	  return 0;
	}

	for(addr=(uintptr_t)UTEXT; addr<USTACKTOP;addr+=PGSIZE){
  800e88:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if(envid==0){
  800e8d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800e91:	0f 85 fb 00 00 00    	jne    800f92 <fork+0x131>
	  thisenv = &envs[ENVX(sys_getenvid())];
  800e97:	e8 fb fc ff ff       	call   800b97 <sys_getenvid>
  800e9c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ea1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800ea4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ea9:	a3 04 20 80 00       	mov    %eax,0x802004
	  return 0;
  800eae:	eb 6a                	jmp    800f1a <fork+0xb9>
	if(envid<0) panic("sys_exofork failed\n");
  800eb0:	83 ec 04             	sub    $0x4,%esp
  800eb3:	68 69 17 80 00       	push   $0x801769
  800eb8:	6a 70                	push   $0x70
  800eba:	68 29 17 80 00       	push   $0x801729
  800ebf:	e8 7d 02 00 00       	call   801141 <_panic>
		 panic("duppage:map02 failed %e",r);
  800ec4:	50                   	push   %eax
  800ec5:	68 95 17 80 00       	push   $0x801795
  800eca:	6a 50                	push   $0x50
  800ecc:	68 29 17 80 00       	push   $0x801729
  800ed1:	e8 6b 02 00 00       	call   801141 <_panic>
	   if((uvpd[PDX(addr)]&PTE_P) && uvpt[PGNUM(addr)] & PTE_P)
		   duppage(envid,PGNUM(addr));
	}
        
	int r;
	if((r=sys_page_alloc(envid,(void *)UXSTACKTOP-PGSIZE,PTE_U|PTE_P|PTE_W))<0)
  800ed6:	83 ec 04             	sub    $0x4,%esp
  800ed9:	6a 07                	push   $0x7
  800edb:	68 00 f0 bf ee       	push   $0xeebff000
  800ee0:	ff 75 dc             	pushl  -0x24(%ebp)
  800ee3:	e8 ed fc ff ff       	call   800bd5 <sys_page_alloc>
  800ee8:	83 c4 10             	add    $0x10,%esp
  800eeb:	85 c0                	test   %eax,%eax
  800eed:	78 36                	js     800f25 <fork+0xc4>
		panic("fork:page alloc failed %e\n",r);

	extern void _pgfault_upcall();
	if((r = sys_env_set_pgfault_upcall(envid,_pgfault_upcall)))
  800eef:	83 ec 08             	sub    $0x8,%esp
  800ef2:	68 ec 11 80 00       	push   $0x8011ec
  800ef7:	ff 75 dc             	pushl  -0x24(%ebp)
  800efa:	e8 df fd ff ff       	call   800cde <sys_env_set_pgfault_upcall>
  800eff:	83 c4 10             	add    $0x10,%esp
  800f02:	85 c0                	test   %eax,%eax
  800f04:	75 31                	jne    800f37 <fork+0xd6>
		panic("fork:set upcall failed %e\n",r);
	if((r = sys_env_set_status(envid,ENV_RUNNABLE))<0)
  800f06:	83 ec 08             	sub    $0x8,%esp
  800f09:	6a 02                	push   $0x2
  800f0b:	ff 75 dc             	pushl  -0x24(%ebp)
  800f0e:	e8 89 fd ff ff       	call   800c9c <sys_env_set_status>
  800f13:	83 c4 10             	add    $0x10,%esp
  800f16:	85 c0                	test   %eax,%eax
  800f18:	78 32                	js     800f4c <fork+0xeb>
		panic("fork:set status failed %e\n",r);
	return envid;
       	
}
  800f1a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800f1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f20:	5b                   	pop    %ebx
  800f21:	5e                   	pop    %esi
  800f22:	5f                   	pop    %edi
  800f23:	5d                   	pop    %ebp
  800f24:	c3                   	ret    
		panic("fork:page alloc failed %e\n",r);
  800f25:	50                   	push   %eax
  800f26:	68 ad 17 80 00       	push   $0x8017ad
  800f2b:	6a 7d                	push   $0x7d
  800f2d:	68 29 17 80 00       	push   $0x801729
  800f32:	e8 0a 02 00 00       	call   801141 <_panic>
		panic("fork:set upcall failed %e\n",r);
  800f37:	50                   	push   %eax
  800f38:	68 c8 17 80 00       	push   $0x8017c8
  800f3d:	68 81 00 00 00       	push   $0x81
  800f42:	68 29 17 80 00       	push   $0x801729
  800f47:	e8 f5 01 00 00       	call   801141 <_panic>
		panic("fork:set status failed %e\n",r);
  800f4c:	50                   	push   %eax
  800f4d:	68 e3 17 80 00       	push   $0x8017e3
  800f52:	68 83 00 00 00       	push   $0x83
  800f57:	68 29 17 80 00       	push   $0x801729
  800f5c:	e8 e0 01 00 00       	call   801141 <_panic>
	 if((perm&PTE_COW) && (r=sys_page_map(parent_envid,va,parent_envid,va,perm))<0){
  800f61:	83 ec 0c             	sub    $0xc,%esp
  800f64:	68 05 08 00 00       	push   $0x805
  800f69:	57                   	push   %edi
  800f6a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f6d:	50                   	push   %eax
  800f6e:	57                   	push   %edi
  800f6f:	50                   	push   %eax
  800f70:	e8 a3 fc ff ff       	call   800c18 <sys_page_map>
  800f75:	83 c4 20             	add    $0x20,%esp
  800f78:	85 c0                	test   %eax,%eax
  800f7a:	0f 88 44 ff ff ff    	js     800ec4 <fork+0x63>
	for(addr=(uintptr_t)UTEXT; addr<USTACKTOP;addr+=PGSIZE){
  800f80:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f86:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800f8c:	0f 84 44 ff ff ff    	je     800ed6 <fork+0x75>
	   if((uvpd[PDX(addr)]&PTE_P) && uvpt[PGNUM(addr)] & PTE_P)
  800f92:	89 d8                	mov    %ebx,%eax
  800f94:	c1 e8 16             	shr    $0x16,%eax
  800f97:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f9e:	a8 01                	test   $0x1,%al
  800fa0:	74 de                	je     800f80 <fork+0x11f>
  800fa2:	89 de                	mov    %ebx,%esi
  800fa4:	c1 ee 0c             	shr    $0xc,%esi
  800fa7:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fae:	a8 01                	test   $0x1,%al
  800fb0:	74 ce                	je     800f80 <fork+0x11f>
        envid_t parent_envid = sys_getenvid();
  800fb2:	e8 e0 fb ff ff       	call   800b97 <sys_getenvid>
  800fb7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	void *va = (void *)(pn*PGSIZE);
  800fba:	89 f7                	mov    %esi,%edi
  800fbc:	c1 e7 0c             	shl    $0xc,%edi
	if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)){
  800fbf:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fc6:	a8 02                	test   $0x2,%al
  800fc8:	75 27                	jne    800ff1 <fork+0x190>
  800fca:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fd1:	f6 c4 08             	test   $0x8,%ah
  800fd4:	75 1b                	jne    800ff1 <fork+0x190>
	 if((r=sys_page_map(parent_envid,va,envid,va,perm))<0)
  800fd6:	83 ec 0c             	sub    $0xc,%esp
  800fd9:	6a 05                	push   $0x5
  800fdb:	57                   	push   %edi
  800fdc:	ff 75 e0             	pushl  -0x20(%ebp)
  800fdf:	57                   	push   %edi
  800fe0:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fe3:	e8 30 fc ff ff       	call   800c18 <sys_page_map>
  800fe8:	83 c4 20             	add    $0x20,%esp
  800feb:	85 c0                	test   %eax,%eax
  800fed:	79 91                	jns    800f80 <fork+0x11f>
  800fef:	eb 20                	jmp    801011 <fork+0x1b0>
  800ff1:	83 ec 0c             	sub    $0xc,%esp
  800ff4:	68 05 08 00 00       	push   $0x805
  800ff9:	57                   	push   %edi
  800ffa:	ff 75 e0             	pushl  -0x20(%ebp)
  800ffd:	57                   	push   %edi
  800ffe:	ff 75 e4             	pushl  -0x1c(%ebp)
  801001:	e8 12 fc ff ff       	call   800c18 <sys_page_map>
  801006:	83 c4 20             	add    $0x20,%esp
  801009:	85 c0                	test   %eax,%eax
  80100b:	0f 89 50 ff ff ff    	jns    800f61 <fork+0x100>
		 panic("duppage:map01 failed %e",r);
  801011:	50                   	push   %eax
  801012:	68 7d 17 80 00       	push   $0x80177d
  801017:	6a 4e                	push   $0x4e
  801019:	68 29 17 80 00       	push   $0x801729
  80101e:	e8 1e 01 00 00       	call   801141 <_panic>

00801023 <sfork>:

// Challenge!
int
sfork(void)
{
  801023:	55                   	push   %ebp
  801024:	89 e5                	mov    %esp,%ebp
  801026:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801029:	68 fe 17 80 00       	push   $0x8017fe
  80102e:	68 8c 00 00 00       	push   $0x8c
  801033:	68 29 17 80 00       	push   $0x801729
  801038:	e8 04 01 00 00       	call   801141 <_panic>

0080103d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80103d:	55                   	push   %ebp
  80103e:	89 e5                	mov    %esp,%ebp
  801040:	56                   	push   %esi
  801041:	53                   	push   %ebx
  801042:	8b 75 08             	mov    0x8(%ebp),%esi
  801045:	8b 45 0c             	mov    0xc(%ebp),%eax
  801048:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        //	panic("ipc_recv not implemented");
        int r;
       	if(pg!=NULL){
  80104b:	85 c0                	test   %eax,%eax
  80104d:	74 3b                	je     80108a <ipc_recv+0x4d>
	  r = sys_ipc_recv(pg);
  80104f:	83 ec 0c             	sub    $0xc,%esp
  801052:	50                   	push   %eax
  801053:	e8 eb fc ff ff       	call   800d43 <sys_ipc_recv>
  801058:	83 c4 10             	add    $0x10,%esp
	}else
	  r = sys_ipc_recv((void *)UTOP);
	if(r<0){
  80105b:	85 c0                	test   %eax,%eax
  80105d:	78 3d                	js     80109c <ipc_recv+0x5f>
	if(perm_store!=NULL){
		*perm_store = 0;
            }
        	return r;
           }else{
	     if(from_env_store!=NULL)
  80105f:	85 f6                	test   %esi,%esi
  801061:	74 0a                	je     80106d <ipc_recv+0x30>
		     *from_env_store = thisenv->env_ipc_from;
  801063:	a1 04 20 80 00       	mov    0x802004,%eax
  801068:	8b 40 74             	mov    0x74(%eax),%eax
  80106b:	89 06                	mov    %eax,(%esi)
	     if(perm_store != NULL)
  80106d:	85 db                	test   %ebx,%ebx
  80106f:	74 0a                	je     80107b <ipc_recv+0x3e>
		     *perm_store = thisenv->env_ipc_perm;
  801071:	a1 04 20 80 00       	mov    0x802004,%eax
  801076:	8b 40 78             	mov    0x78(%eax),%eax
  801079:	89 03                	mov    %eax,(%ebx)
	     return thisenv->env_ipc_value;
  80107b:	a1 04 20 80 00       	mov    0x802004,%eax
  801080:	8b 40 70             	mov    0x70(%eax),%eax
	   }

}
  801083:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801086:	5b                   	pop    %ebx
  801087:	5e                   	pop    %esi
  801088:	5d                   	pop    %ebp
  801089:	c3                   	ret    
	  r = sys_ipc_recv((void *)UTOP);
  80108a:	83 ec 0c             	sub    $0xc,%esp
  80108d:	68 00 00 c0 ee       	push   $0xeec00000
  801092:	e8 ac fc ff ff       	call   800d43 <sys_ipc_recv>
  801097:	83 c4 10             	add    $0x10,%esp
  80109a:	eb bf                	jmp    80105b <ipc_recv+0x1e>
	if(from_env_store!=NULL){
  80109c:	85 f6                	test   %esi,%esi
  80109e:	74 06                	je     8010a6 <ipc_recv+0x69>
	  *from_env_store = 0;
  8010a0:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if(perm_store!=NULL){
  8010a6:	85 db                	test   %ebx,%ebx
  8010a8:	74 d9                	je     801083 <ipc_recv+0x46>
		*perm_store = 0;
  8010aa:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010b0:	eb d1                	jmp    801083 <ipc_recv+0x46>

008010b2 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8010b2:	55                   	push   %ebp
  8010b3:	89 e5                	mov    %esp,%ebp
  8010b5:	57                   	push   %edi
  8010b6:	56                   	push   %esi
  8010b7:	53                   	push   %ebx
  8010b8:	83 ec 0c             	sub    $0xc,%esp
  8010bb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010be:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010c1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if(pg==NULL) pg = (void *)UTOP;
  8010c4:	85 db                	test   %ebx,%ebx
  8010c6:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8010cb:	0f 44 d8             	cmove  %eax,%ebx
	while((r=sys_ipc_try_send(to_env,val,pg,perm))<0){
  8010ce:	ff 75 14             	pushl  0x14(%ebp)
  8010d1:	53                   	push   %ebx
  8010d2:	56                   	push   %esi
  8010d3:	57                   	push   %edi
  8010d4:	e8 47 fc ff ff       	call   800d20 <sys_ipc_try_send>
  8010d9:	83 c4 10             	add    $0x10,%esp
  8010dc:	85 c0                	test   %eax,%eax
  8010de:	79 20                	jns    801100 <ipc_send+0x4e>
	    if(r!=-E_IPC_NOT_RECV){
  8010e0:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8010e3:	75 07                	jne    8010ec <ipc_send+0x3a>
		    panic("ipc_send:send message failed\n");
	    }
	    sys_yield();
  8010e5:	e8 cc fa ff ff       	call   800bb6 <sys_yield>
  8010ea:	eb e2                	jmp    8010ce <ipc_send+0x1c>
		    panic("ipc_send:send message failed\n");
  8010ec:	83 ec 04             	sub    $0x4,%esp
  8010ef:	68 36 18 80 00       	push   $0x801836
  8010f4:	6a 43                	push   $0x43
  8010f6:	68 54 18 80 00       	push   $0x801854
  8010fb:	e8 41 00 00 00       	call   801141 <_panic>
	}

}
  801100:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801103:	5b                   	pop    %ebx
  801104:	5e                   	pop    %esi
  801105:	5f                   	pop    %edi
  801106:	5d                   	pop    %ebp
  801107:	c3                   	ret    

00801108 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801108:	55                   	push   %ebp
  801109:	89 e5                	mov    %esp,%ebp
  80110b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80110e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801113:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801116:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80111c:	8b 52 50             	mov    0x50(%edx),%edx
  80111f:	39 ca                	cmp    %ecx,%edx
  801121:	74 11                	je     801134 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801123:	83 c0 01             	add    $0x1,%eax
  801126:	3d 00 04 00 00       	cmp    $0x400,%eax
  80112b:	75 e6                	jne    801113 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  80112d:	b8 00 00 00 00       	mov    $0x0,%eax
  801132:	eb 0b                	jmp    80113f <ipc_find_env+0x37>
			return envs[i].env_id;
  801134:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801137:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80113c:	8b 40 48             	mov    0x48(%eax),%eax
}
  80113f:	5d                   	pop    %ebp
  801140:	c3                   	ret    

00801141 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801141:	55                   	push   %ebp
  801142:	89 e5                	mov    %esp,%ebp
  801144:	56                   	push   %esi
  801145:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801146:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801149:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80114f:	e8 43 fa ff ff       	call   800b97 <sys_getenvid>
  801154:	83 ec 0c             	sub    $0xc,%esp
  801157:	ff 75 0c             	pushl  0xc(%ebp)
  80115a:	ff 75 08             	pushl  0x8(%ebp)
  80115d:	56                   	push   %esi
  80115e:	50                   	push   %eax
  80115f:	68 60 18 80 00       	push   $0x801860
  801164:	e8 54 f0 ff ff       	call   8001bd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801169:	83 c4 18             	add    $0x18,%esp
  80116c:	53                   	push   %ebx
  80116d:	ff 75 10             	pushl  0x10(%ebp)
  801170:	e8 f7 ef ff ff       	call   80016c <vcprintf>
	cprintf("\n");
  801175:	c7 04 24 52 18 80 00 	movl   $0x801852,(%esp)
  80117c:	e8 3c f0 ff ff       	call   8001bd <cprintf>
  801181:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801184:	cc                   	int3   
  801185:	eb fd                	jmp    801184 <_panic+0x43>

00801187 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801187:	55                   	push   %ebp
  801188:	89 e5                	mov    %esp,%ebp
  80118a:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80118d:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  801194:	74 0a                	je     8011a0 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler %e",r);
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
	}
       
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801196:	8b 45 08             	mov    0x8(%ebp),%eax
  801199:	a3 08 20 80 00       	mov    %eax,0x802008
}
  80119e:	c9                   	leave  
  80119f:	c3                   	ret    
		if((r=sys_page_alloc(thisenv->env_id,(void *)UXSTACKTOP-PGSIZE,PTE_P|PTE_W|PTE_U))<0)
  8011a0:	a1 04 20 80 00       	mov    0x802004,%eax
  8011a5:	8b 40 48             	mov    0x48(%eax),%eax
  8011a8:	83 ec 04             	sub    $0x4,%esp
  8011ab:	6a 07                	push   $0x7
  8011ad:	68 00 f0 bf ee       	push   $0xeebff000
  8011b2:	50                   	push   %eax
  8011b3:	e8 1d fa ff ff       	call   800bd5 <sys_page_alloc>
  8011b8:	83 c4 10             	add    $0x10,%esp
  8011bb:	85 c0                	test   %eax,%eax
  8011bd:	78 1b                	js     8011da <set_pgfault_handler+0x53>
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
  8011bf:	a1 04 20 80 00       	mov    0x802004,%eax
  8011c4:	8b 40 48             	mov    0x48(%eax),%eax
  8011c7:	83 ec 08             	sub    $0x8,%esp
  8011ca:	68 ec 11 80 00       	push   $0x8011ec
  8011cf:	50                   	push   %eax
  8011d0:	e8 09 fb ff ff       	call   800cde <sys_env_set_pgfault_upcall>
  8011d5:	83 c4 10             	add    $0x10,%esp
  8011d8:	eb bc                	jmp    801196 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler %e",r);
  8011da:	50                   	push   %eax
  8011db:	68 84 18 80 00       	push   $0x801884
  8011e0:	6a 22                	push   $0x22
  8011e2:	68 9b 18 80 00       	push   $0x80189b
  8011e7:	e8 55 ff ff ff       	call   801141 <_panic>

008011ec <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8011ec:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8011ed:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  8011f2:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8011f4:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 48(%esp), %ebp
  8011f7:	8b 6c 24 30          	mov    0x30(%esp),%ebp
        subl $4, %ebp
  8011fb:	83 ed 04             	sub    $0x4,%ebp
        movl %ebp, 48(%esp)
  8011fe:	89 6c 24 30          	mov    %ebp,0x30(%esp)
        movl 40(%esp), %eax
  801202:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl %eax, (%ebp)
  801206:	89 45 00             	mov    %eax,0x0(%ebp)
	// Restore the trap-time registers.  After you do this, you
 	// can no longer modify any general-purpose registers.
 	// LAB 4: Your code here.
        addl $8, %esp
  801209:	83 c4 08             	add    $0x8,%esp
        popal
  80120c:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $4, %esp
  80120d:	83 c4 04             	add    $0x4,%esp
        popfl
  801210:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  801211:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  801212:	c3                   	ret    
  801213:	66 90                	xchg   %ax,%ax
  801215:	66 90                	xchg   %ax,%ax
  801217:	66 90                	xchg   %ax,%ax
  801219:	66 90                	xchg   %ax,%ax
  80121b:	66 90                	xchg   %ax,%ax
  80121d:	66 90                	xchg   %ax,%ax
  80121f:	90                   	nop

00801220 <__udivdi3>:
  801220:	55                   	push   %ebp
  801221:	57                   	push   %edi
  801222:	56                   	push   %esi
  801223:	53                   	push   %ebx
  801224:	83 ec 1c             	sub    $0x1c,%esp
  801227:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80122b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  80122f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801233:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801237:	85 d2                	test   %edx,%edx
  801239:	75 35                	jne    801270 <__udivdi3+0x50>
  80123b:	39 f3                	cmp    %esi,%ebx
  80123d:	0f 87 bd 00 00 00    	ja     801300 <__udivdi3+0xe0>
  801243:	85 db                	test   %ebx,%ebx
  801245:	89 d9                	mov    %ebx,%ecx
  801247:	75 0b                	jne    801254 <__udivdi3+0x34>
  801249:	b8 01 00 00 00       	mov    $0x1,%eax
  80124e:	31 d2                	xor    %edx,%edx
  801250:	f7 f3                	div    %ebx
  801252:	89 c1                	mov    %eax,%ecx
  801254:	31 d2                	xor    %edx,%edx
  801256:	89 f0                	mov    %esi,%eax
  801258:	f7 f1                	div    %ecx
  80125a:	89 c6                	mov    %eax,%esi
  80125c:	89 e8                	mov    %ebp,%eax
  80125e:	89 f7                	mov    %esi,%edi
  801260:	f7 f1                	div    %ecx
  801262:	89 fa                	mov    %edi,%edx
  801264:	83 c4 1c             	add    $0x1c,%esp
  801267:	5b                   	pop    %ebx
  801268:	5e                   	pop    %esi
  801269:	5f                   	pop    %edi
  80126a:	5d                   	pop    %ebp
  80126b:	c3                   	ret    
  80126c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801270:	39 f2                	cmp    %esi,%edx
  801272:	77 7c                	ja     8012f0 <__udivdi3+0xd0>
  801274:	0f bd fa             	bsr    %edx,%edi
  801277:	83 f7 1f             	xor    $0x1f,%edi
  80127a:	0f 84 98 00 00 00    	je     801318 <__udivdi3+0xf8>
  801280:	89 f9                	mov    %edi,%ecx
  801282:	b8 20 00 00 00       	mov    $0x20,%eax
  801287:	29 f8                	sub    %edi,%eax
  801289:	d3 e2                	shl    %cl,%edx
  80128b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80128f:	89 c1                	mov    %eax,%ecx
  801291:	89 da                	mov    %ebx,%edx
  801293:	d3 ea                	shr    %cl,%edx
  801295:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801299:	09 d1                	or     %edx,%ecx
  80129b:	89 f2                	mov    %esi,%edx
  80129d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012a1:	89 f9                	mov    %edi,%ecx
  8012a3:	d3 e3                	shl    %cl,%ebx
  8012a5:	89 c1                	mov    %eax,%ecx
  8012a7:	d3 ea                	shr    %cl,%edx
  8012a9:	89 f9                	mov    %edi,%ecx
  8012ab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8012af:	d3 e6                	shl    %cl,%esi
  8012b1:	89 eb                	mov    %ebp,%ebx
  8012b3:	89 c1                	mov    %eax,%ecx
  8012b5:	d3 eb                	shr    %cl,%ebx
  8012b7:	09 de                	or     %ebx,%esi
  8012b9:	89 f0                	mov    %esi,%eax
  8012bb:	f7 74 24 08          	divl   0x8(%esp)
  8012bf:	89 d6                	mov    %edx,%esi
  8012c1:	89 c3                	mov    %eax,%ebx
  8012c3:	f7 64 24 0c          	mull   0xc(%esp)
  8012c7:	39 d6                	cmp    %edx,%esi
  8012c9:	72 0c                	jb     8012d7 <__udivdi3+0xb7>
  8012cb:	89 f9                	mov    %edi,%ecx
  8012cd:	d3 e5                	shl    %cl,%ebp
  8012cf:	39 c5                	cmp    %eax,%ebp
  8012d1:	73 5d                	jae    801330 <__udivdi3+0x110>
  8012d3:	39 d6                	cmp    %edx,%esi
  8012d5:	75 59                	jne    801330 <__udivdi3+0x110>
  8012d7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8012da:	31 ff                	xor    %edi,%edi
  8012dc:	89 fa                	mov    %edi,%edx
  8012de:	83 c4 1c             	add    $0x1c,%esp
  8012e1:	5b                   	pop    %ebx
  8012e2:	5e                   	pop    %esi
  8012e3:	5f                   	pop    %edi
  8012e4:	5d                   	pop    %ebp
  8012e5:	c3                   	ret    
  8012e6:	8d 76 00             	lea    0x0(%esi),%esi
  8012e9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8012f0:	31 ff                	xor    %edi,%edi
  8012f2:	31 c0                	xor    %eax,%eax
  8012f4:	89 fa                	mov    %edi,%edx
  8012f6:	83 c4 1c             	add    $0x1c,%esp
  8012f9:	5b                   	pop    %ebx
  8012fa:	5e                   	pop    %esi
  8012fb:	5f                   	pop    %edi
  8012fc:	5d                   	pop    %ebp
  8012fd:	c3                   	ret    
  8012fe:	66 90                	xchg   %ax,%ax
  801300:	31 ff                	xor    %edi,%edi
  801302:	89 e8                	mov    %ebp,%eax
  801304:	89 f2                	mov    %esi,%edx
  801306:	f7 f3                	div    %ebx
  801308:	89 fa                	mov    %edi,%edx
  80130a:	83 c4 1c             	add    $0x1c,%esp
  80130d:	5b                   	pop    %ebx
  80130e:	5e                   	pop    %esi
  80130f:	5f                   	pop    %edi
  801310:	5d                   	pop    %ebp
  801311:	c3                   	ret    
  801312:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801318:	39 f2                	cmp    %esi,%edx
  80131a:	72 06                	jb     801322 <__udivdi3+0x102>
  80131c:	31 c0                	xor    %eax,%eax
  80131e:	39 eb                	cmp    %ebp,%ebx
  801320:	77 d2                	ja     8012f4 <__udivdi3+0xd4>
  801322:	b8 01 00 00 00       	mov    $0x1,%eax
  801327:	eb cb                	jmp    8012f4 <__udivdi3+0xd4>
  801329:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801330:	89 d8                	mov    %ebx,%eax
  801332:	31 ff                	xor    %edi,%edi
  801334:	eb be                	jmp    8012f4 <__udivdi3+0xd4>
  801336:	66 90                	xchg   %ax,%ax
  801338:	66 90                	xchg   %ax,%ax
  80133a:	66 90                	xchg   %ax,%ax
  80133c:	66 90                	xchg   %ax,%ax
  80133e:	66 90                	xchg   %ax,%ax

00801340 <__umoddi3>:
  801340:	55                   	push   %ebp
  801341:	57                   	push   %edi
  801342:	56                   	push   %esi
  801343:	53                   	push   %ebx
  801344:	83 ec 1c             	sub    $0x1c,%esp
  801347:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80134b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80134f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801353:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801357:	85 ed                	test   %ebp,%ebp
  801359:	89 f0                	mov    %esi,%eax
  80135b:	89 da                	mov    %ebx,%edx
  80135d:	75 19                	jne    801378 <__umoddi3+0x38>
  80135f:	39 df                	cmp    %ebx,%edi
  801361:	0f 86 b1 00 00 00    	jbe    801418 <__umoddi3+0xd8>
  801367:	f7 f7                	div    %edi
  801369:	89 d0                	mov    %edx,%eax
  80136b:	31 d2                	xor    %edx,%edx
  80136d:	83 c4 1c             	add    $0x1c,%esp
  801370:	5b                   	pop    %ebx
  801371:	5e                   	pop    %esi
  801372:	5f                   	pop    %edi
  801373:	5d                   	pop    %ebp
  801374:	c3                   	ret    
  801375:	8d 76 00             	lea    0x0(%esi),%esi
  801378:	39 dd                	cmp    %ebx,%ebp
  80137a:	77 f1                	ja     80136d <__umoddi3+0x2d>
  80137c:	0f bd cd             	bsr    %ebp,%ecx
  80137f:	83 f1 1f             	xor    $0x1f,%ecx
  801382:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801386:	0f 84 b4 00 00 00    	je     801440 <__umoddi3+0x100>
  80138c:	b8 20 00 00 00       	mov    $0x20,%eax
  801391:	89 c2                	mov    %eax,%edx
  801393:	8b 44 24 04          	mov    0x4(%esp),%eax
  801397:	29 c2                	sub    %eax,%edx
  801399:	89 c1                	mov    %eax,%ecx
  80139b:	89 f8                	mov    %edi,%eax
  80139d:	d3 e5                	shl    %cl,%ebp
  80139f:	89 d1                	mov    %edx,%ecx
  8013a1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8013a5:	d3 e8                	shr    %cl,%eax
  8013a7:	09 c5                	or     %eax,%ebp
  8013a9:	8b 44 24 04          	mov    0x4(%esp),%eax
  8013ad:	89 c1                	mov    %eax,%ecx
  8013af:	d3 e7                	shl    %cl,%edi
  8013b1:	89 d1                	mov    %edx,%ecx
  8013b3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8013b7:	89 df                	mov    %ebx,%edi
  8013b9:	d3 ef                	shr    %cl,%edi
  8013bb:	89 c1                	mov    %eax,%ecx
  8013bd:	89 f0                	mov    %esi,%eax
  8013bf:	d3 e3                	shl    %cl,%ebx
  8013c1:	89 d1                	mov    %edx,%ecx
  8013c3:	89 fa                	mov    %edi,%edx
  8013c5:	d3 e8                	shr    %cl,%eax
  8013c7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8013cc:	09 d8                	or     %ebx,%eax
  8013ce:	f7 f5                	div    %ebp
  8013d0:	d3 e6                	shl    %cl,%esi
  8013d2:	89 d1                	mov    %edx,%ecx
  8013d4:	f7 64 24 08          	mull   0x8(%esp)
  8013d8:	39 d1                	cmp    %edx,%ecx
  8013da:	89 c3                	mov    %eax,%ebx
  8013dc:	89 d7                	mov    %edx,%edi
  8013de:	72 06                	jb     8013e6 <__umoddi3+0xa6>
  8013e0:	75 0e                	jne    8013f0 <__umoddi3+0xb0>
  8013e2:	39 c6                	cmp    %eax,%esi
  8013e4:	73 0a                	jae    8013f0 <__umoddi3+0xb0>
  8013e6:	2b 44 24 08          	sub    0x8(%esp),%eax
  8013ea:	19 ea                	sbb    %ebp,%edx
  8013ec:	89 d7                	mov    %edx,%edi
  8013ee:	89 c3                	mov    %eax,%ebx
  8013f0:	89 ca                	mov    %ecx,%edx
  8013f2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8013f7:	29 de                	sub    %ebx,%esi
  8013f9:	19 fa                	sbb    %edi,%edx
  8013fb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  8013ff:	89 d0                	mov    %edx,%eax
  801401:	d3 e0                	shl    %cl,%eax
  801403:	89 d9                	mov    %ebx,%ecx
  801405:	d3 ee                	shr    %cl,%esi
  801407:	d3 ea                	shr    %cl,%edx
  801409:	09 f0                	or     %esi,%eax
  80140b:	83 c4 1c             	add    $0x1c,%esp
  80140e:	5b                   	pop    %ebx
  80140f:	5e                   	pop    %esi
  801410:	5f                   	pop    %edi
  801411:	5d                   	pop    %ebp
  801412:	c3                   	ret    
  801413:	90                   	nop
  801414:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801418:	85 ff                	test   %edi,%edi
  80141a:	89 f9                	mov    %edi,%ecx
  80141c:	75 0b                	jne    801429 <__umoddi3+0xe9>
  80141e:	b8 01 00 00 00       	mov    $0x1,%eax
  801423:	31 d2                	xor    %edx,%edx
  801425:	f7 f7                	div    %edi
  801427:	89 c1                	mov    %eax,%ecx
  801429:	89 d8                	mov    %ebx,%eax
  80142b:	31 d2                	xor    %edx,%edx
  80142d:	f7 f1                	div    %ecx
  80142f:	89 f0                	mov    %esi,%eax
  801431:	f7 f1                	div    %ecx
  801433:	e9 31 ff ff ff       	jmp    801369 <__umoddi3+0x29>
  801438:	90                   	nop
  801439:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801440:	39 dd                	cmp    %ebx,%ebp
  801442:	72 08                	jb     80144c <__umoddi3+0x10c>
  801444:	39 f7                	cmp    %esi,%edi
  801446:	0f 87 21 ff ff ff    	ja     80136d <__umoddi3+0x2d>
  80144c:	89 da                	mov    %ebx,%edx
  80144e:	89 f0                	mov    %esi,%eax
  801450:	29 f8                	sub    %edi,%eax
  801452:	19 ea                	sbb    %ebp,%edx
  801454:	e9 14 ff ff ff       	jmp    80136d <__umoddi3+0x2d>
