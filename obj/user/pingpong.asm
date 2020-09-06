
obj/user/pingpong.debug:     file format elf32-i386


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
  80003c:	e8 81 0e 00 00       	call   800ec2 <fork>
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
  80004e:	68 f6 21 80 00       	push   $0x8021f6
  800053:	e8 6d 01 00 00       	call   8001c5 <cprintf>
		uint32_t i = ipc_recv(&who, 0, 0);
  800058:	83 c4 0c             	add    $0xc,%esp
  80005b:	6a 00                	push   $0x0
  80005d:	6a 00                	push   $0x0
  80005f:	56                   	push   %esi
  800060:	e8 6a 10 00 00       	call   8010cf <ipc_recv>
  800065:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  800067:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80006a:	e8 30 0b 00 00       	call   800b9f <sys_getenvid>
  80006f:	57                   	push   %edi
  800070:	53                   	push   %ebx
  800071:	50                   	push   %eax
  800072:	68 04 22 80 00       	push   $0x802204
  800077:	e8 49 01 00 00       	call   8001c5 <cprintf>
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
  80008f:	e8 b0 10 00 00       	call   801144 <ipc_send>
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
  8000a6:	e8 f4 0a 00 00       	call   800b9f <sys_getenvid>
  8000ab:	83 ec 04             	sub    $0x4,%esp
  8000ae:	53                   	push   %ebx
  8000af:	50                   	push   %eax
  8000b0:	68 e0 21 80 00       	push   $0x8021e0
  8000b5:	e8 0b 01 00 00       	call   8001c5 <cprintf>
		ipc_send(who, 0, 0, 0);
  8000ba:	6a 00                	push   $0x0
  8000bc:	6a 00                	push   $0x0
  8000be:	6a 00                	push   $0x0
  8000c0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000c3:	e8 7c 10 00 00       	call   801144 <ipc_send>
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
  8000db:	e8 bf 0a 00 00       	call   800b9f <sys_getenvid>
  8000e0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000e5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000e8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000ed:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000f2:	85 db                	test   %ebx,%ebx
  8000f4:	7e 07                	jle    8000fd <libmain+0x2d>
		binaryname = argv[0];
  8000f6:	8b 06                	mov    (%esi),%eax
  8000f8:	a3 00 30 80 00       	mov    %eax,0x803000

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
  800119:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80011c:	e8 88 12 00 00       	call   8013a9 <close_all>
	sys_env_destroy(0);
  800121:	83 ec 0c             	sub    $0xc,%esp
  800124:	6a 00                	push   $0x0
  800126:	e8 33 0a 00 00       	call   800b5e <sys_env_destroy>
}
  80012b:	83 c4 10             	add    $0x10,%esp
  80012e:	c9                   	leave  
  80012f:	c3                   	ret    

00800130 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800130:	55                   	push   %ebp
  800131:	89 e5                	mov    %esp,%ebp
  800133:	53                   	push   %ebx
  800134:	83 ec 04             	sub    $0x4,%esp
  800137:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80013a:	8b 13                	mov    (%ebx),%edx
  80013c:	8d 42 01             	lea    0x1(%edx),%eax
  80013f:	89 03                	mov    %eax,(%ebx)
  800141:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800144:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800148:	3d ff 00 00 00       	cmp    $0xff,%eax
  80014d:	74 09                	je     800158 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80014f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800153:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800156:	c9                   	leave  
  800157:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800158:	83 ec 08             	sub    $0x8,%esp
  80015b:	68 ff 00 00 00       	push   $0xff
  800160:	8d 43 08             	lea    0x8(%ebx),%eax
  800163:	50                   	push   %eax
  800164:	e8 b8 09 00 00       	call   800b21 <sys_cputs>
		b->idx = 0;
  800169:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80016f:	83 c4 10             	add    $0x10,%esp
  800172:	eb db                	jmp    80014f <putch+0x1f>

00800174 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80017d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800184:	00 00 00 
	b.cnt = 0;
  800187:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80018e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800191:	ff 75 0c             	pushl  0xc(%ebp)
  800194:	ff 75 08             	pushl  0x8(%ebp)
  800197:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80019d:	50                   	push   %eax
  80019e:	68 30 01 80 00       	push   $0x800130
  8001a3:	e8 1a 01 00 00       	call   8002c2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001a8:	83 c4 08             	add    $0x8,%esp
  8001ab:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001b1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001b7:	50                   	push   %eax
  8001b8:	e8 64 09 00 00       	call   800b21 <sys_cputs>

	return b.cnt;
}
  8001bd:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001c3:	c9                   	leave  
  8001c4:	c3                   	ret    

008001c5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001c5:	55                   	push   %ebp
  8001c6:	89 e5                	mov    %esp,%ebp
  8001c8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001cb:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001ce:	50                   	push   %eax
  8001cf:	ff 75 08             	pushl  0x8(%ebp)
  8001d2:	e8 9d ff ff ff       	call   800174 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001d7:	c9                   	leave  
  8001d8:	c3                   	ret    

008001d9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001d9:	55                   	push   %ebp
  8001da:	89 e5                	mov    %esp,%ebp
  8001dc:	57                   	push   %edi
  8001dd:	56                   	push   %esi
  8001de:	53                   	push   %ebx
  8001df:	83 ec 1c             	sub    $0x1c,%esp
  8001e2:	89 c7                	mov    %eax,%edi
  8001e4:	89 d6                	mov    %edx,%esi
  8001e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001ec:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001ef:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001f2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001f5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001fa:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001fd:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800200:	39 d3                	cmp    %edx,%ebx
  800202:	72 05                	jb     800209 <printnum+0x30>
  800204:	39 45 10             	cmp    %eax,0x10(%ebp)
  800207:	77 7a                	ja     800283 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800209:	83 ec 0c             	sub    $0xc,%esp
  80020c:	ff 75 18             	pushl  0x18(%ebp)
  80020f:	8b 45 14             	mov    0x14(%ebp),%eax
  800212:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800215:	53                   	push   %ebx
  800216:	ff 75 10             	pushl  0x10(%ebp)
  800219:	83 ec 08             	sub    $0x8,%esp
  80021c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80021f:	ff 75 e0             	pushl  -0x20(%ebp)
  800222:	ff 75 dc             	pushl  -0x24(%ebp)
  800225:	ff 75 d8             	pushl  -0x28(%ebp)
  800228:	e8 73 1d 00 00       	call   801fa0 <__udivdi3>
  80022d:	83 c4 18             	add    $0x18,%esp
  800230:	52                   	push   %edx
  800231:	50                   	push   %eax
  800232:	89 f2                	mov    %esi,%edx
  800234:	89 f8                	mov    %edi,%eax
  800236:	e8 9e ff ff ff       	call   8001d9 <printnum>
  80023b:	83 c4 20             	add    $0x20,%esp
  80023e:	eb 13                	jmp    800253 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800240:	83 ec 08             	sub    $0x8,%esp
  800243:	56                   	push   %esi
  800244:	ff 75 18             	pushl  0x18(%ebp)
  800247:	ff d7                	call   *%edi
  800249:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80024c:	83 eb 01             	sub    $0x1,%ebx
  80024f:	85 db                	test   %ebx,%ebx
  800251:	7f ed                	jg     800240 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800253:	83 ec 08             	sub    $0x8,%esp
  800256:	56                   	push   %esi
  800257:	83 ec 04             	sub    $0x4,%esp
  80025a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80025d:	ff 75 e0             	pushl  -0x20(%ebp)
  800260:	ff 75 dc             	pushl  -0x24(%ebp)
  800263:	ff 75 d8             	pushl  -0x28(%ebp)
  800266:	e8 55 1e 00 00       	call   8020c0 <__umoddi3>
  80026b:	83 c4 14             	add    $0x14,%esp
  80026e:	0f be 80 21 22 80 00 	movsbl 0x802221(%eax),%eax
  800275:	50                   	push   %eax
  800276:	ff d7                	call   *%edi
}
  800278:	83 c4 10             	add    $0x10,%esp
  80027b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80027e:	5b                   	pop    %ebx
  80027f:	5e                   	pop    %esi
  800280:	5f                   	pop    %edi
  800281:	5d                   	pop    %ebp
  800282:	c3                   	ret    
  800283:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800286:	eb c4                	jmp    80024c <printnum+0x73>

00800288 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800288:	55                   	push   %ebp
  800289:	89 e5                	mov    %esp,%ebp
  80028b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80028e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800292:	8b 10                	mov    (%eax),%edx
  800294:	3b 50 04             	cmp    0x4(%eax),%edx
  800297:	73 0a                	jae    8002a3 <sprintputch+0x1b>
		*b->buf++ = ch;
  800299:	8d 4a 01             	lea    0x1(%edx),%ecx
  80029c:	89 08                	mov    %ecx,(%eax)
  80029e:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a1:	88 02                	mov    %al,(%edx)
}
  8002a3:	5d                   	pop    %ebp
  8002a4:	c3                   	ret    

008002a5 <printfmt>:
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002ab:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002ae:	50                   	push   %eax
  8002af:	ff 75 10             	pushl  0x10(%ebp)
  8002b2:	ff 75 0c             	pushl  0xc(%ebp)
  8002b5:	ff 75 08             	pushl  0x8(%ebp)
  8002b8:	e8 05 00 00 00       	call   8002c2 <vprintfmt>
}
  8002bd:	83 c4 10             	add    $0x10,%esp
  8002c0:	c9                   	leave  
  8002c1:	c3                   	ret    

008002c2 <vprintfmt>:
{
  8002c2:	55                   	push   %ebp
  8002c3:	89 e5                	mov    %esp,%ebp
  8002c5:	57                   	push   %edi
  8002c6:	56                   	push   %esi
  8002c7:	53                   	push   %ebx
  8002c8:	83 ec 2c             	sub    $0x2c,%esp
  8002cb:	8b 75 08             	mov    0x8(%ebp),%esi
  8002ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002d1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002d4:	e9 c1 03 00 00       	jmp    80069a <vprintfmt+0x3d8>
		padc = ' ';
  8002d9:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8002dd:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8002e4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8002eb:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002f2:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002f7:	8d 47 01             	lea    0x1(%edi),%eax
  8002fa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002fd:	0f b6 17             	movzbl (%edi),%edx
  800300:	8d 42 dd             	lea    -0x23(%edx),%eax
  800303:	3c 55                	cmp    $0x55,%al
  800305:	0f 87 12 04 00 00    	ja     80071d <vprintfmt+0x45b>
  80030b:	0f b6 c0             	movzbl %al,%eax
  80030e:	ff 24 85 60 23 80 00 	jmp    *0x802360(,%eax,4)
  800315:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800318:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80031c:	eb d9                	jmp    8002f7 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80031e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800321:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800325:	eb d0                	jmp    8002f7 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800327:	0f b6 d2             	movzbl %dl,%edx
  80032a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80032d:	b8 00 00 00 00       	mov    $0x0,%eax
  800332:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800335:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800338:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80033c:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80033f:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800342:	83 f9 09             	cmp    $0x9,%ecx
  800345:	77 55                	ja     80039c <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800347:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80034a:	eb e9                	jmp    800335 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  80034c:	8b 45 14             	mov    0x14(%ebp),%eax
  80034f:	8b 00                	mov    (%eax),%eax
  800351:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800354:	8b 45 14             	mov    0x14(%ebp),%eax
  800357:	8d 40 04             	lea    0x4(%eax),%eax
  80035a:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80035d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800360:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800364:	79 91                	jns    8002f7 <vprintfmt+0x35>
				width = precision, precision = -1;
  800366:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800369:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80036c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800373:	eb 82                	jmp    8002f7 <vprintfmt+0x35>
  800375:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800378:	85 c0                	test   %eax,%eax
  80037a:	ba 00 00 00 00       	mov    $0x0,%edx
  80037f:	0f 49 d0             	cmovns %eax,%edx
  800382:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800385:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800388:	e9 6a ff ff ff       	jmp    8002f7 <vprintfmt+0x35>
  80038d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800390:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800397:	e9 5b ff ff ff       	jmp    8002f7 <vprintfmt+0x35>
  80039c:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80039f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003a2:	eb bc                	jmp    800360 <vprintfmt+0x9e>
			lflag++;
  8003a4:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003aa:	e9 48 ff ff ff       	jmp    8002f7 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8003af:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b2:	8d 78 04             	lea    0x4(%eax),%edi
  8003b5:	83 ec 08             	sub    $0x8,%esp
  8003b8:	53                   	push   %ebx
  8003b9:	ff 30                	pushl  (%eax)
  8003bb:	ff d6                	call   *%esi
			break;
  8003bd:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003c0:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003c3:	e9 cf 02 00 00       	jmp    800697 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  8003c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cb:	8d 78 04             	lea    0x4(%eax),%edi
  8003ce:	8b 00                	mov    (%eax),%eax
  8003d0:	99                   	cltd   
  8003d1:	31 d0                	xor    %edx,%eax
  8003d3:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003d5:	83 f8 0f             	cmp    $0xf,%eax
  8003d8:	7f 23                	jg     8003fd <vprintfmt+0x13b>
  8003da:	8b 14 85 c0 24 80 00 	mov    0x8024c0(,%eax,4),%edx
  8003e1:	85 d2                	test   %edx,%edx
  8003e3:	74 18                	je     8003fd <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8003e5:	52                   	push   %edx
  8003e6:	68 59 27 80 00       	push   $0x802759
  8003eb:	53                   	push   %ebx
  8003ec:	56                   	push   %esi
  8003ed:	e8 b3 fe ff ff       	call   8002a5 <printfmt>
  8003f2:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003f5:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003f8:	e9 9a 02 00 00       	jmp    800697 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  8003fd:	50                   	push   %eax
  8003fe:	68 39 22 80 00       	push   $0x802239
  800403:	53                   	push   %ebx
  800404:	56                   	push   %esi
  800405:	e8 9b fe ff ff       	call   8002a5 <printfmt>
  80040a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80040d:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800410:	e9 82 02 00 00       	jmp    800697 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  800415:	8b 45 14             	mov    0x14(%ebp),%eax
  800418:	83 c0 04             	add    $0x4,%eax
  80041b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80041e:	8b 45 14             	mov    0x14(%ebp),%eax
  800421:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800423:	85 ff                	test   %edi,%edi
  800425:	b8 32 22 80 00       	mov    $0x802232,%eax
  80042a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80042d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800431:	0f 8e bd 00 00 00    	jle    8004f4 <vprintfmt+0x232>
  800437:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80043b:	75 0e                	jne    80044b <vprintfmt+0x189>
  80043d:	89 75 08             	mov    %esi,0x8(%ebp)
  800440:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800443:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800446:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800449:	eb 6d                	jmp    8004b8 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  80044b:	83 ec 08             	sub    $0x8,%esp
  80044e:	ff 75 d0             	pushl  -0x30(%ebp)
  800451:	57                   	push   %edi
  800452:	e8 6e 03 00 00       	call   8007c5 <strnlen>
  800457:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80045a:	29 c1                	sub    %eax,%ecx
  80045c:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80045f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800462:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800466:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800469:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80046c:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  80046e:	eb 0f                	jmp    80047f <vprintfmt+0x1bd>
					putch(padc, putdat);
  800470:	83 ec 08             	sub    $0x8,%esp
  800473:	53                   	push   %ebx
  800474:	ff 75 e0             	pushl  -0x20(%ebp)
  800477:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800479:	83 ef 01             	sub    $0x1,%edi
  80047c:	83 c4 10             	add    $0x10,%esp
  80047f:	85 ff                	test   %edi,%edi
  800481:	7f ed                	jg     800470 <vprintfmt+0x1ae>
  800483:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800486:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800489:	85 c9                	test   %ecx,%ecx
  80048b:	b8 00 00 00 00       	mov    $0x0,%eax
  800490:	0f 49 c1             	cmovns %ecx,%eax
  800493:	29 c1                	sub    %eax,%ecx
  800495:	89 75 08             	mov    %esi,0x8(%ebp)
  800498:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80049b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80049e:	89 cb                	mov    %ecx,%ebx
  8004a0:	eb 16                	jmp    8004b8 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8004a2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004a6:	75 31                	jne    8004d9 <vprintfmt+0x217>
					putch(ch, putdat);
  8004a8:	83 ec 08             	sub    $0x8,%esp
  8004ab:	ff 75 0c             	pushl  0xc(%ebp)
  8004ae:	50                   	push   %eax
  8004af:	ff 55 08             	call   *0x8(%ebp)
  8004b2:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004b5:	83 eb 01             	sub    $0x1,%ebx
  8004b8:	83 c7 01             	add    $0x1,%edi
  8004bb:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8004bf:	0f be c2             	movsbl %dl,%eax
  8004c2:	85 c0                	test   %eax,%eax
  8004c4:	74 59                	je     80051f <vprintfmt+0x25d>
  8004c6:	85 f6                	test   %esi,%esi
  8004c8:	78 d8                	js     8004a2 <vprintfmt+0x1e0>
  8004ca:	83 ee 01             	sub    $0x1,%esi
  8004cd:	79 d3                	jns    8004a2 <vprintfmt+0x1e0>
  8004cf:	89 df                	mov    %ebx,%edi
  8004d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8004d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004d7:	eb 37                	jmp    800510 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004d9:	0f be d2             	movsbl %dl,%edx
  8004dc:	83 ea 20             	sub    $0x20,%edx
  8004df:	83 fa 5e             	cmp    $0x5e,%edx
  8004e2:	76 c4                	jbe    8004a8 <vprintfmt+0x1e6>
					putch('?', putdat);
  8004e4:	83 ec 08             	sub    $0x8,%esp
  8004e7:	ff 75 0c             	pushl  0xc(%ebp)
  8004ea:	6a 3f                	push   $0x3f
  8004ec:	ff 55 08             	call   *0x8(%ebp)
  8004ef:	83 c4 10             	add    $0x10,%esp
  8004f2:	eb c1                	jmp    8004b5 <vprintfmt+0x1f3>
  8004f4:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004fa:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004fd:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800500:	eb b6                	jmp    8004b8 <vprintfmt+0x1f6>
				putch(' ', putdat);
  800502:	83 ec 08             	sub    $0x8,%esp
  800505:	53                   	push   %ebx
  800506:	6a 20                	push   $0x20
  800508:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80050a:	83 ef 01             	sub    $0x1,%edi
  80050d:	83 c4 10             	add    $0x10,%esp
  800510:	85 ff                	test   %edi,%edi
  800512:	7f ee                	jg     800502 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800514:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800517:	89 45 14             	mov    %eax,0x14(%ebp)
  80051a:	e9 78 01 00 00       	jmp    800697 <vprintfmt+0x3d5>
  80051f:	89 df                	mov    %ebx,%edi
  800521:	8b 75 08             	mov    0x8(%ebp),%esi
  800524:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800527:	eb e7                	jmp    800510 <vprintfmt+0x24e>
	if (lflag >= 2)
  800529:	83 f9 01             	cmp    $0x1,%ecx
  80052c:	7e 3f                	jle    80056d <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  80052e:	8b 45 14             	mov    0x14(%ebp),%eax
  800531:	8b 50 04             	mov    0x4(%eax),%edx
  800534:	8b 00                	mov    (%eax),%eax
  800536:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800539:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80053c:	8b 45 14             	mov    0x14(%ebp),%eax
  80053f:	8d 40 08             	lea    0x8(%eax),%eax
  800542:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800545:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800549:	79 5c                	jns    8005a7 <vprintfmt+0x2e5>
				putch('-', putdat);
  80054b:	83 ec 08             	sub    $0x8,%esp
  80054e:	53                   	push   %ebx
  80054f:	6a 2d                	push   $0x2d
  800551:	ff d6                	call   *%esi
				num = -(long long) num;
  800553:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800556:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800559:	f7 da                	neg    %edx
  80055b:	83 d1 00             	adc    $0x0,%ecx
  80055e:	f7 d9                	neg    %ecx
  800560:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800563:	b8 0a 00 00 00       	mov    $0xa,%eax
  800568:	e9 10 01 00 00       	jmp    80067d <vprintfmt+0x3bb>
	else if (lflag)
  80056d:	85 c9                	test   %ecx,%ecx
  80056f:	75 1b                	jne    80058c <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800571:	8b 45 14             	mov    0x14(%ebp),%eax
  800574:	8b 00                	mov    (%eax),%eax
  800576:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800579:	89 c1                	mov    %eax,%ecx
  80057b:	c1 f9 1f             	sar    $0x1f,%ecx
  80057e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800581:	8b 45 14             	mov    0x14(%ebp),%eax
  800584:	8d 40 04             	lea    0x4(%eax),%eax
  800587:	89 45 14             	mov    %eax,0x14(%ebp)
  80058a:	eb b9                	jmp    800545 <vprintfmt+0x283>
		return va_arg(*ap, long);
  80058c:	8b 45 14             	mov    0x14(%ebp),%eax
  80058f:	8b 00                	mov    (%eax),%eax
  800591:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800594:	89 c1                	mov    %eax,%ecx
  800596:	c1 f9 1f             	sar    $0x1f,%ecx
  800599:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80059c:	8b 45 14             	mov    0x14(%ebp),%eax
  80059f:	8d 40 04             	lea    0x4(%eax),%eax
  8005a2:	89 45 14             	mov    %eax,0x14(%ebp)
  8005a5:	eb 9e                	jmp    800545 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8005a7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005aa:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005ad:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b2:	e9 c6 00 00 00       	jmp    80067d <vprintfmt+0x3bb>
	if (lflag >= 2)
  8005b7:	83 f9 01             	cmp    $0x1,%ecx
  8005ba:	7e 18                	jle    8005d4 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8005bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bf:	8b 10                	mov    (%eax),%edx
  8005c1:	8b 48 04             	mov    0x4(%eax),%ecx
  8005c4:	8d 40 08             	lea    0x8(%eax),%eax
  8005c7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005ca:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005cf:	e9 a9 00 00 00       	jmp    80067d <vprintfmt+0x3bb>
	else if (lflag)
  8005d4:	85 c9                	test   %ecx,%ecx
  8005d6:	75 1a                	jne    8005f2 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  8005d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005db:	8b 10                	mov    (%eax),%edx
  8005dd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e2:	8d 40 04             	lea    0x4(%eax),%eax
  8005e5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005e8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ed:	e9 8b 00 00 00       	jmp    80067d <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8005f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f5:	8b 10                	mov    (%eax),%edx
  8005f7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005fc:	8d 40 04             	lea    0x4(%eax),%eax
  8005ff:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800602:	b8 0a 00 00 00       	mov    $0xa,%eax
  800607:	eb 74                	jmp    80067d <vprintfmt+0x3bb>
	if (lflag >= 2)
  800609:	83 f9 01             	cmp    $0x1,%ecx
  80060c:	7e 15                	jle    800623 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  80060e:	8b 45 14             	mov    0x14(%ebp),%eax
  800611:	8b 10                	mov    (%eax),%edx
  800613:	8b 48 04             	mov    0x4(%eax),%ecx
  800616:	8d 40 08             	lea    0x8(%eax),%eax
  800619:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80061c:	b8 08 00 00 00       	mov    $0x8,%eax
  800621:	eb 5a                	jmp    80067d <vprintfmt+0x3bb>
	else if (lflag)
  800623:	85 c9                	test   %ecx,%ecx
  800625:	75 17                	jne    80063e <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  800627:	8b 45 14             	mov    0x14(%ebp),%eax
  80062a:	8b 10                	mov    (%eax),%edx
  80062c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800631:	8d 40 04             	lea    0x4(%eax),%eax
  800634:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800637:	b8 08 00 00 00       	mov    $0x8,%eax
  80063c:	eb 3f                	jmp    80067d <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80063e:	8b 45 14             	mov    0x14(%ebp),%eax
  800641:	8b 10                	mov    (%eax),%edx
  800643:	b9 00 00 00 00       	mov    $0x0,%ecx
  800648:	8d 40 04             	lea    0x4(%eax),%eax
  80064b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80064e:	b8 08 00 00 00       	mov    $0x8,%eax
  800653:	eb 28                	jmp    80067d <vprintfmt+0x3bb>
			putch('0', putdat);
  800655:	83 ec 08             	sub    $0x8,%esp
  800658:	53                   	push   %ebx
  800659:	6a 30                	push   $0x30
  80065b:	ff d6                	call   *%esi
			putch('x', putdat);
  80065d:	83 c4 08             	add    $0x8,%esp
  800660:	53                   	push   %ebx
  800661:	6a 78                	push   $0x78
  800663:	ff d6                	call   *%esi
			num = (unsigned long long)
  800665:	8b 45 14             	mov    0x14(%ebp),%eax
  800668:	8b 10                	mov    (%eax),%edx
  80066a:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80066f:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800672:	8d 40 04             	lea    0x4(%eax),%eax
  800675:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800678:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80067d:	83 ec 0c             	sub    $0xc,%esp
  800680:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800684:	57                   	push   %edi
  800685:	ff 75 e0             	pushl  -0x20(%ebp)
  800688:	50                   	push   %eax
  800689:	51                   	push   %ecx
  80068a:	52                   	push   %edx
  80068b:	89 da                	mov    %ebx,%edx
  80068d:	89 f0                	mov    %esi,%eax
  80068f:	e8 45 fb ff ff       	call   8001d9 <printnum>
			break;
  800694:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800697:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80069a:	83 c7 01             	add    $0x1,%edi
  80069d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006a1:	83 f8 25             	cmp    $0x25,%eax
  8006a4:	0f 84 2f fc ff ff    	je     8002d9 <vprintfmt+0x17>
			if (ch == '\0')
  8006aa:	85 c0                	test   %eax,%eax
  8006ac:	0f 84 8b 00 00 00    	je     80073d <vprintfmt+0x47b>
			putch(ch, putdat);
  8006b2:	83 ec 08             	sub    $0x8,%esp
  8006b5:	53                   	push   %ebx
  8006b6:	50                   	push   %eax
  8006b7:	ff d6                	call   *%esi
  8006b9:	83 c4 10             	add    $0x10,%esp
  8006bc:	eb dc                	jmp    80069a <vprintfmt+0x3d8>
	if (lflag >= 2)
  8006be:	83 f9 01             	cmp    $0x1,%ecx
  8006c1:	7e 15                	jle    8006d8 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  8006c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c6:	8b 10                	mov    (%eax),%edx
  8006c8:	8b 48 04             	mov    0x4(%eax),%ecx
  8006cb:	8d 40 08             	lea    0x8(%eax),%eax
  8006ce:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d1:	b8 10 00 00 00       	mov    $0x10,%eax
  8006d6:	eb a5                	jmp    80067d <vprintfmt+0x3bb>
	else if (lflag)
  8006d8:	85 c9                	test   %ecx,%ecx
  8006da:	75 17                	jne    8006f3 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  8006dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006df:	8b 10                	mov    (%eax),%edx
  8006e1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006e6:	8d 40 04             	lea    0x4(%eax),%eax
  8006e9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ec:	b8 10 00 00 00       	mov    $0x10,%eax
  8006f1:	eb 8a                	jmp    80067d <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8006f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f6:	8b 10                	mov    (%eax),%edx
  8006f8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006fd:	8d 40 04             	lea    0x4(%eax),%eax
  800700:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800703:	b8 10 00 00 00       	mov    $0x10,%eax
  800708:	e9 70 ff ff ff       	jmp    80067d <vprintfmt+0x3bb>
			putch(ch, putdat);
  80070d:	83 ec 08             	sub    $0x8,%esp
  800710:	53                   	push   %ebx
  800711:	6a 25                	push   $0x25
  800713:	ff d6                	call   *%esi
			break;
  800715:	83 c4 10             	add    $0x10,%esp
  800718:	e9 7a ff ff ff       	jmp    800697 <vprintfmt+0x3d5>
			putch('%', putdat);
  80071d:	83 ec 08             	sub    $0x8,%esp
  800720:	53                   	push   %ebx
  800721:	6a 25                	push   $0x25
  800723:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800725:	83 c4 10             	add    $0x10,%esp
  800728:	89 f8                	mov    %edi,%eax
  80072a:	eb 03                	jmp    80072f <vprintfmt+0x46d>
  80072c:	83 e8 01             	sub    $0x1,%eax
  80072f:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800733:	75 f7                	jne    80072c <vprintfmt+0x46a>
  800735:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800738:	e9 5a ff ff ff       	jmp    800697 <vprintfmt+0x3d5>
}
  80073d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800740:	5b                   	pop    %ebx
  800741:	5e                   	pop    %esi
  800742:	5f                   	pop    %edi
  800743:	5d                   	pop    %ebp
  800744:	c3                   	ret    

00800745 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800745:	55                   	push   %ebp
  800746:	89 e5                	mov    %esp,%ebp
  800748:	83 ec 18             	sub    $0x18,%esp
  80074b:	8b 45 08             	mov    0x8(%ebp),%eax
  80074e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800751:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800754:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800758:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80075b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800762:	85 c0                	test   %eax,%eax
  800764:	74 26                	je     80078c <vsnprintf+0x47>
  800766:	85 d2                	test   %edx,%edx
  800768:	7e 22                	jle    80078c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80076a:	ff 75 14             	pushl  0x14(%ebp)
  80076d:	ff 75 10             	pushl  0x10(%ebp)
  800770:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800773:	50                   	push   %eax
  800774:	68 88 02 80 00       	push   $0x800288
  800779:	e8 44 fb ff ff       	call   8002c2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80077e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800781:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800784:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800787:	83 c4 10             	add    $0x10,%esp
}
  80078a:	c9                   	leave  
  80078b:	c3                   	ret    
		return -E_INVAL;
  80078c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800791:	eb f7                	jmp    80078a <vsnprintf+0x45>

00800793 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800793:	55                   	push   %ebp
  800794:	89 e5                	mov    %esp,%ebp
  800796:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800799:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80079c:	50                   	push   %eax
  80079d:	ff 75 10             	pushl  0x10(%ebp)
  8007a0:	ff 75 0c             	pushl  0xc(%ebp)
  8007a3:	ff 75 08             	pushl  0x8(%ebp)
  8007a6:	e8 9a ff ff ff       	call   800745 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007ab:	c9                   	leave  
  8007ac:	c3                   	ret    

008007ad <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007ad:	55                   	push   %ebp
  8007ae:	89 e5                	mov    %esp,%ebp
  8007b0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b8:	eb 03                	jmp    8007bd <strlen+0x10>
		n++;
  8007ba:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007bd:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007c1:	75 f7                	jne    8007ba <strlen+0xd>
	return n;
}
  8007c3:	5d                   	pop    %ebp
  8007c4:	c3                   	ret    

008007c5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007c5:	55                   	push   %ebp
  8007c6:	89 e5                	mov    %esp,%ebp
  8007c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007cb:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d3:	eb 03                	jmp    8007d8 <strnlen+0x13>
		n++;
  8007d5:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d8:	39 d0                	cmp    %edx,%eax
  8007da:	74 06                	je     8007e2 <strnlen+0x1d>
  8007dc:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007e0:	75 f3                	jne    8007d5 <strnlen+0x10>
	return n;
}
  8007e2:	5d                   	pop    %ebp
  8007e3:	c3                   	ret    

008007e4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007e4:	55                   	push   %ebp
  8007e5:	89 e5                	mov    %esp,%ebp
  8007e7:	53                   	push   %ebx
  8007e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007ee:	89 c2                	mov    %eax,%edx
  8007f0:	83 c1 01             	add    $0x1,%ecx
  8007f3:	83 c2 01             	add    $0x1,%edx
  8007f6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007fa:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007fd:	84 db                	test   %bl,%bl
  8007ff:	75 ef                	jne    8007f0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800801:	5b                   	pop    %ebx
  800802:	5d                   	pop    %ebp
  800803:	c3                   	ret    

00800804 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800804:	55                   	push   %ebp
  800805:	89 e5                	mov    %esp,%ebp
  800807:	53                   	push   %ebx
  800808:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80080b:	53                   	push   %ebx
  80080c:	e8 9c ff ff ff       	call   8007ad <strlen>
  800811:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800814:	ff 75 0c             	pushl  0xc(%ebp)
  800817:	01 d8                	add    %ebx,%eax
  800819:	50                   	push   %eax
  80081a:	e8 c5 ff ff ff       	call   8007e4 <strcpy>
	return dst;
}
  80081f:	89 d8                	mov    %ebx,%eax
  800821:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800824:	c9                   	leave  
  800825:	c3                   	ret    

00800826 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800826:	55                   	push   %ebp
  800827:	89 e5                	mov    %esp,%ebp
  800829:	56                   	push   %esi
  80082a:	53                   	push   %ebx
  80082b:	8b 75 08             	mov    0x8(%ebp),%esi
  80082e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800831:	89 f3                	mov    %esi,%ebx
  800833:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800836:	89 f2                	mov    %esi,%edx
  800838:	eb 0f                	jmp    800849 <strncpy+0x23>
		*dst++ = *src;
  80083a:	83 c2 01             	add    $0x1,%edx
  80083d:	0f b6 01             	movzbl (%ecx),%eax
  800840:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800843:	80 39 01             	cmpb   $0x1,(%ecx)
  800846:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800849:	39 da                	cmp    %ebx,%edx
  80084b:	75 ed                	jne    80083a <strncpy+0x14>
	}
	return ret;
}
  80084d:	89 f0                	mov    %esi,%eax
  80084f:	5b                   	pop    %ebx
  800850:	5e                   	pop    %esi
  800851:	5d                   	pop    %ebp
  800852:	c3                   	ret    

00800853 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800853:	55                   	push   %ebp
  800854:	89 e5                	mov    %esp,%ebp
  800856:	56                   	push   %esi
  800857:	53                   	push   %ebx
  800858:	8b 75 08             	mov    0x8(%ebp),%esi
  80085b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800861:	89 f0                	mov    %esi,%eax
  800863:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800867:	85 c9                	test   %ecx,%ecx
  800869:	75 0b                	jne    800876 <strlcpy+0x23>
  80086b:	eb 17                	jmp    800884 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80086d:	83 c2 01             	add    $0x1,%edx
  800870:	83 c0 01             	add    $0x1,%eax
  800873:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800876:	39 d8                	cmp    %ebx,%eax
  800878:	74 07                	je     800881 <strlcpy+0x2e>
  80087a:	0f b6 0a             	movzbl (%edx),%ecx
  80087d:	84 c9                	test   %cl,%cl
  80087f:	75 ec                	jne    80086d <strlcpy+0x1a>
		*dst = '\0';
  800881:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800884:	29 f0                	sub    %esi,%eax
}
  800886:	5b                   	pop    %ebx
  800887:	5e                   	pop    %esi
  800888:	5d                   	pop    %ebp
  800889:	c3                   	ret    

0080088a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800890:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800893:	eb 06                	jmp    80089b <strcmp+0x11>
		p++, q++;
  800895:	83 c1 01             	add    $0x1,%ecx
  800898:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80089b:	0f b6 01             	movzbl (%ecx),%eax
  80089e:	84 c0                	test   %al,%al
  8008a0:	74 04                	je     8008a6 <strcmp+0x1c>
  8008a2:	3a 02                	cmp    (%edx),%al
  8008a4:	74 ef                	je     800895 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a6:	0f b6 c0             	movzbl %al,%eax
  8008a9:	0f b6 12             	movzbl (%edx),%edx
  8008ac:	29 d0                	sub    %edx,%eax
}
  8008ae:	5d                   	pop    %ebp
  8008af:	c3                   	ret    

008008b0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	53                   	push   %ebx
  8008b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ba:	89 c3                	mov    %eax,%ebx
  8008bc:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008bf:	eb 06                	jmp    8008c7 <strncmp+0x17>
		n--, p++, q++;
  8008c1:	83 c0 01             	add    $0x1,%eax
  8008c4:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008c7:	39 d8                	cmp    %ebx,%eax
  8008c9:	74 16                	je     8008e1 <strncmp+0x31>
  8008cb:	0f b6 08             	movzbl (%eax),%ecx
  8008ce:	84 c9                	test   %cl,%cl
  8008d0:	74 04                	je     8008d6 <strncmp+0x26>
  8008d2:	3a 0a                	cmp    (%edx),%cl
  8008d4:	74 eb                	je     8008c1 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d6:	0f b6 00             	movzbl (%eax),%eax
  8008d9:	0f b6 12             	movzbl (%edx),%edx
  8008dc:	29 d0                	sub    %edx,%eax
}
  8008de:	5b                   	pop    %ebx
  8008df:	5d                   	pop    %ebp
  8008e0:	c3                   	ret    
		return 0;
  8008e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e6:	eb f6                	jmp    8008de <strncmp+0x2e>

008008e8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ee:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008f2:	0f b6 10             	movzbl (%eax),%edx
  8008f5:	84 d2                	test   %dl,%dl
  8008f7:	74 09                	je     800902 <strchr+0x1a>
		if (*s == c)
  8008f9:	38 ca                	cmp    %cl,%dl
  8008fb:	74 0a                	je     800907 <strchr+0x1f>
	for (; *s; s++)
  8008fd:	83 c0 01             	add    $0x1,%eax
  800900:	eb f0                	jmp    8008f2 <strchr+0xa>
			return (char *) s;
	return 0;
  800902:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800907:	5d                   	pop    %ebp
  800908:	c3                   	ret    

00800909 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800909:	55                   	push   %ebp
  80090a:	89 e5                	mov    %esp,%ebp
  80090c:	8b 45 08             	mov    0x8(%ebp),%eax
  80090f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800913:	eb 03                	jmp    800918 <strfind+0xf>
  800915:	83 c0 01             	add    $0x1,%eax
  800918:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80091b:	38 ca                	cmp    %cl,%dl
  80091d:	74 04                	je     800923 <strfind+0x1a>
  80091f:	84 d2                	test   %dl,%dl
  800921:	75 f2                	jne    800915 <strfind+0xc>
			break;
	return (char *) s;
}
  800923:	5d                   	pop    %ebp
  800924:	c3                   	ret    

00800925 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800925:	55                   	push   %ebp
  800926:	89 e5                	mov    %esp,%ebp
  800928:	57                   	push   %edi
  800929:	56                   	push   %esi
  80092a:	53                   	push   %ebx
  80092b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80092e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800931:	85 c9                	test   %ecx,%ecx
  800933:	74 13                	je     800948 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800935:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80093b:	75 05                	jne    800942 <memset+0x1d>
  80093d:	f6 c1 03             	test   $0x3,%cl
  800940:	74 0d                	je     80094f <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800942:	8b 45 0c             	mov    0xc(%ebp),%eax
  800945:	fc                   	cld    
  800946:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800948:	89 f8                	mov    %edi,%eax
  80094a:	5b                   	pop    %ebx
  80094b:	5e                   	pop    %esi
  80094c:	5f                   	pop    %edi
  80094d:	5d                   	pop    %ebp
  80094e:	c3                   	ret    
		c &= 0xFF;
  80094f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800953:	89 d3                	mov    %edx,%ebx
  800955:	c1 e3 08             	shl    $0x8,%ebx
  800958:	89 d0                	mov    %edx,%eax
  80095a:	c1 e0 18             	shl    $0x18,%eax
  80095d:	89 d6                	mov    %edx,%esi
  80095f:	c1 e6 10             	shl    $0x10,%esi
  800962:	09 f0                	or     %esi,%eax
  800964:	09 c2                	or     %eax,%edx
  800966:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800968:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80096b:	89 d0                	mov    %edx,%eax
  80096d:	fc                   	cld    
  80096e:	f3 ab                	rep stos %eax,%es:(%edi)
  800970:	eb d6                	jmp    800948 <memset+0x23>

00800972 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
  800975:	57                   	push   %edi
  800976:	56                   	push   %esi
  800977:	8b 45 08             	mov    0x8(%ebp),%eax
  80097a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80097d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800980:	39 c6                	cmp    %eax,%esi
  800982:	73 35                	jae    8009b9 <memmove+0x47>
  800984:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800987:	39 c2                	cmp    %eax,%edx
  800989:	76 2e                	jbe    8009b9 <memmove+0x47>
		s += n;
		d += n;
  80098b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098e:	89 d6                	mov    %edx,%esi
  800990:	09 fe                	or     %edi,%esi
  800992:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800998:	74 0c                	je     8009a6 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80099a:	83 ef 01             	sub    $0x1,%edi
  80099d:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009a0:	fd                   	std    
  8009a1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009a3:	fc                   	cld    
  8009a4:	eb 21                	jmp    8009c7 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a6:	f6 c1 03             	test   $0x3,%cl
  8009a9:	75 ef                	jne    80099a <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009ab:	83 ef 04             	sub    $0x4,%edi
  8009ae:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009b1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009b4:	fd                   	std    
  8009b5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b7:	eb ea                	jmp    8009a3 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b9:	89 f2                	mov    %esi,%edx
  8009bb:	09 c2                	or     %eax,%edx
  8009bd:	f6 c2 03             	test   $0x3,%dl
  8009c0:	74 09                	je     8009cb <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009c2:	89 c7                	mov    %eax,%edi
  8009c4:	fc                   	cld    
  8009c5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009c7:	5e                   	pop    %esi
  8009c8:	5f                   	pop    %edi
  8009c9:	5d                   	pop    %ebp
  8009ca:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009cb:	f6 c1 03             	test   $0x3,%cl
  8009ce:	75 f2                	jne    8009c2 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009d0:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009d3:	89 c7                	mov    %eax,%edi
  8009d5:	fc                   	cld    
  8009d6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d8:	eb ed                	jmp    8009c7 <memmove+0x55>

008009da <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009dd:	ff 75 10             	pushl  0x10(%ebp)
  8009e0:	ff 75 0c             	pushl  0xc(%ebp)
  8009e3:	ff 75 08             	pushl  0x8(%ebp)
  8009e6:	e8 87 ff ff ff       	call   800972 <memmove>
}
  8009eb:	c9                   	leave  
  8009ec:	c3                   	ret    

008009ed <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ed:	55                   	push   %ebp
  8009ee:	89 e5                	mov    %esp,%ebp
  8009f0:	56                   	push   %esi
  8009f1:	53                   	push   %ebx
  8009f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f8:	89 c6                	mov    %eax,%esi
  8009fa:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009fd:	39 f0                	cmp    %esi,%eax
  8009ff:	74 1c                	je     800a1d <memcmp+0x30>
		if (*s1 != *s2)
  800a01:	0f b6 08             	movzbl (%eax),%ecx
  800a04:	0f b6 1a             	movzbl (%edx),%ebx
  800a07:	38 d9                	cmp    %bl,%cl
  800a09:	75 08                	jne    800a13 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a0b:	83 c0 01             	add    $0x1,%eax
  800a0e:	83 c2 01             	add    $0x1,%edx
  800a11:	eb ea                	jmp    8009fd <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a13:	0f b6 c1             	movzbl %cl,%eax
  800a16:	0f b6 db             	movzbl %bl,%ebx
  800a19:	29 d8                	sub    %ebx,%eax
  800a1b:	eb 05                	jmp    800a22 <memcmp+0x35>
	}

	return 0;
  800a1d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a22:	5b                   	pop    %ebx
  800a23:	5e                   	pop    %esi
  800a24:	5d                   	pop    %ebp
  800a25:	c3                   	ret    

00800a26 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a2f:	89 c2                	mov    %eax,%edx
  800a31:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a34:	39 d0                	cmp    %edx,%eax
  800a36:	73 09                	jae    800a41 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a38:	38 08                	cmp    %cl,(%eax)
  800a3a:	74 05                	je     800a41 <memfind+0x1b>
	for (; s < ends; s++)
  800a3c:	83 c0 01             	add    $0x1,%eax
  800a3f:	eb f3                	jmp    800a34 <memfind+0xe>
			break;
	return (void *) s;
}
  800a41:	5d                   	pop    %ebp
  800a42:	c3                   	ret    

00800a43 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a43:	55                   	push   %ebp
  800a44:	89 e5                	mov    %esp,%ebp
  800a46:	57                   	push   %edi
  800a47:	56                   	push   %esi
  800a48:	53                   	push   %ebx
  800a49:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a4f:	eb 03                	jmp    800a54 <strtol+0x11>
		s++;
  800a51:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a54:	0f b6 01             	movzbl (%ecx),%eax
  800a57:	3c 20                	cmp    $0x20,%al
  800a59:	74 f6                	je     800a51 <strtol+0xe>
  800a5b:	3c 09                	cmp    $0x9,%al
  800a5d:	74 f2                	je     800a51 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a5f:	3c 2b                	cmp    $0x2b,%al
  800a61:	74 2e                	je     800a91 <strtol+0x4e>
	int neg = 0;
  800a63:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a68:	3c 2d                	cmp    $0x2d,%al
  800a6a:	74 2f                	je     800a9b <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a6c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a72:	75 05                	jne    800a79 <strtol+0x36>
  800a74:	80 39 30             	cmpb   $0x30,(%ecx)
  800a77:	74 2c                	je     800aa5 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a79:	85 db                	test   %ebx,%ebx
  800a7b:	75 0a                	jne    800a87 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a7d:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a82:	80 39 30             	cmpb   $0x30,(%ecx)
  800a85:	74 28                	je     800aaf <strtol+0x6c>
		base = 10;
  800a87:	b8 00 00 00 00       	mov    $0x0,%eax
  800a8c:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a8f:	eb 50                	jmp    800ae1 <strtol+0x9e>
		s++;
  800a91:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a94:	bf 00 00 00 00       	mov    $0x0,%edi
  800a99:	eb d1                	jmp    800a6c <strtol+0x29>
		s++, neg = 1;
  800a9b:	83 c1 01             	add    $0x1,%ecx
  800a9e:	bf 01 00 00 00       	mov    $0x1,%edi
  800aa3:	eb c7                	jmp    800a6c <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aa9:	74 0e                	je     800ab9 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800aab:	85 db                	test   %ebx,%ebx
  800aad:	75 d8                	jne    800a87 <strtol+0x44>
		s++, base = 8;
  800aaf:	83 c1 01             	add    $0x1,%ecx
  800ab2:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ab7:	eb ce                	jmp    800a87 <strtol+0x44>
		s += 2, base = 16;
  800ab9:	83 c1 02             	add    $0x2,%ecx
  800abc:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ac1:	eb c4                	jmp    800a87 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800ac3:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ac6:	89 f3                	mov    %esi,%ebx
  800ac8:	80 fb 19             	cmp    $0x19,%bl
  800acb:	77 29                	ja     800af6 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800acd:	0f be d2             	movsbl %dl,%edx
  800ad0:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ad3:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ad6:	7d 30                	jge    800b08 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800ad8:	83 c1 01             	add    $0x1,%ecx
  800adb:	0f af 45 10          	imul   0x10(%ebp),%eax
  800adf:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ae1:	0f b6 11             	movzbl (%ecx),%edx
  800ae4:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ae7:	89 f3                	mov    %esi,%ebx
  800ae9:	80 fb 09             	cmp    $0x9,%bl
  800aec:	77 d5                	ja     800ac3 <strtol+0x80>
			dig = *s - '0';
  800aee:	0f be d2             	movsbl %dl,%edx
  800af1:	83 ea 30             	sub    $0x30,%edx
  800af4:	eb dd                	jmp    800ad3 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800af6:	8d 72 bf             	lea    -0x41(%edx),%esi
  800af9:	89 f3                	mov    %esi,%ebx
  800afb:	80 fb 19             	cmp    $0x19,%bl
  800afe:	77 08                	ja     800b08 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b00:	0f be d2             	movsbl %dl,%edx
  800b03:	83 ea 37             	sub    $0x37,%edx
  800b06:	eb cb                	jmp    800ad3 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b08:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b0c:	74 05                	je     800b13 <strtol+0xd0>
		*endptr = (char *) s;
  800b0e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b11:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b13:	89 c2                	mov    %eax,%edx
  800b15:	f7 da                	neg    %edx
  800b17:	85 ff                	test   %edi,%edi
  800b19:	0f 45 c2             	cmovne %edx,%eax
}
  800b1c:	5b                   	pop    %ebx
  800b1d:	5e                   	pop    %esi
  800b1e:	5f                   	pop    %edi
  800b1f:	5d                   	pop    %ebp
  800b20:	c3                   	ret    

00800b21 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	57                   	push   %edi
  800b25:	56                   	push   %esi
  800b26:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b27:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b32:	89 c3                	mov    %eax,%ebx
  800b34:	89 c7                	mov    %eax,%edi
  800b36:	89 c6                	mov    %eax,%esi
  800b38:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b3a:	5b                   	pop    %ebx
  800b3b:	5e                   	pop    %esi
  800b3c:	5f                   	pop    %edi
  800b3d:	5d                   	pop    %ebp
  800b3e:	c3                   	ret    

00800b3f <sys_cgetc>:

int
sys_cgetc(void)
{
  800b3f:	55                   	push   %ebp
  800b40:	89 e5                	mov    %esp,%ebp
  800b42:	57                   	push   %edi
  800b43:	56                   	push   %esi
  800b44:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b45:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b4f:	89 d1                	mov    %edx,%ecx
  800b51:	89 d3                	mov    %edx,%ebx
  800b53:	89 d7                	mov    %edx,%edi
  800b55:	89 d6                	mov    %edx,%esi
  800b57:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b59:	5b                   	pop    %ebx
  800b5a:	5e                   	pop    %esi
  800b5b:	5f                   	pop    %edi
  800b5c:	5d                   	pop    %ebp
  800b5d:	c3                   	ret    

00800b5e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b5e:	55                   	push   %ebp
  800b5f:	89 e5                	mov    %esp,%ebp
  800b61:	57                   	push   %edi
  800b62:	56                   	push   %esi
  800b63:	53                   	push   %ebx
  800b64:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b67:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b74:	89 cb                	mov    %ecx,%ebx
  800b76:	89 cf                	mov    %ecx,%edi
  800b78:	89 ce                	mov    %ecx,%esi
  800b7a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b7c:	85 c0                	test   %eax,%eax
  800b7e:	7f 08                	jg     800b88 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b83:	5b                   	pop    %ebx
  800b84:	5e                   	pop    %esi
  800b85:	5f                   	pop    %edi
  800b86:	5d                   	pop    %ebp
  800b87:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b88:	83 ec 0c             	sub    $0xc,%esp
  800b8b:	50                   	push   %eax
  800b8c:	6a 03                	push   $0x3
  800b8e:	68 1f 25 80 00       	push   $0x80251f
  800b93:	6a 23                	push   $0x23
  800b95:	68 3c 25 80 00       	push   $0x80253c
  800b9a:	e8 ef 12 00 00       	call   801e8e <_panic>

00800b9f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	57                   	push   %edi
  800ba3:	56                   	push   %esi
  800ba4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ba5:	ba 00 00 00 00       	mov    $0x0,%edx
  800baa:	b8 02 00 00 00       	mov    $0x2,%eax
  800baf:	89 d1                	mov    %edx,%ecx
  800bb1:	89 d3                	mov    %edx,%ebx
  800bb3:	89 d7                	mov    %edx,%edi
  800bb5:	89 d6                	mov    %edx,%esi
  800bb7:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bb9:	5b                   	pop    %ebx
  800bba:	5e                   	pop    %esi
  800bbb:	5f                   	pop    %edi
  800bbc:	5d                   	pop    %ebp
  800bbd:	c3                   	ret    

00800bbe <sys_yield>:

void
sys_yield(void)
{
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	57                   	push   %edi
  800bc2:	56                   	push   %esi
  800bc3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bc4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc9:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bce:	89 d1                	mov    %edx,%ecx
  800bd0:	89 d3                	mov    %edx,%ebx
  800bd2:	89 d7                	mov    %edx,%edi
  800bd4:	89 d6                	mov    %edx,%esi
  800bd6:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bd8:	5b                   	pop    %ebx
  800bd9:	5e                   	pop    %esi
  800bda:	5f                   	pop    %edi
  800bdb:	5d                   	pop    %ebp
  800bdc:	c3                   	ret    

00800bdd <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bdd:	55                   	push   %ebp
  800bde:	89 e5                	mov    %esp,%ebp
  800be0:	57                   	push   %edi
  800be1:	56                   	push   %esi
  800be2:	53                   	push   %ebx
  800be3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800be6:	be 00 00 00 00       	mov    $0x0,%esi
  800beb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf1:	b8 04 00 00 00       	mov    $0x4,%eax
  800bf6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf9:	89 f7                	mov    %esi,%edi
  800bfb:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bfd:	85 c0                	test   %eax,%eax
  800bff:	7f 08                	jg     800c09 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c04:	5b                   	pop    %ebx
  800c05:	5e                   	pop    %esi
  800c06:	5f                   	pop    %edi
  800c07:	5d                   	pop    %ebp
  800c08:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c09:	83 ec 0c             	sub    $0xc,%esp
  800c0c:	50                   	push   %eax
  800c0d:	6a 04                	push   $0x4
  800c0f:	68 1f 25 80 00       	push   $0x80251f
  800c14:	6a 23                	push   $0x23
  800c16:	68 3c 25 80 00       	push   $0x80253c
  800c1b:	e8 6e 12 00 00       	call   801e8e <_panic>

00800c20 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c20:	55                   	push   %ebp
  800c21:	89 e5                	mov    %esp,%ebp
  800c23:	57                   	push   %edi
  800c24:	56                   	push   %esi
  800c25:	53                   	push   %ebx
  800c26:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c29:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2f:	b8 05 00 00 00       	mov    $0x5,%eax
  800c34:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c37:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c3a:	8b 75 18             	mov    0x18(%ebp),%esi
  800c3d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c3f:	85 c0                	test   %eax,%eax
  800c41:	7f 08                	jg     800c4b <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c46:	5b                   	pop    %ebx
  800c47:	5e                   	pop    %esi
  800c48:	5f                   	pop    %edi
  800c49:	5d                   	pop    %ebp
  800c4a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4b:	83 ec 0c             	sub    $0xc,%esp
  800c4e:	50                   	push   %eax
  800c4f:	6a 05                	push   $0x5
  800c51:	68 1f 25 80 00       	push   $0x80251f
  800c56:	6a 23                	push   $0x23
  800c58:	68 3c 25 80 00       	push   $0x80253c
  800c5d:	e8 2c 12 00 00       	call   801e8e <_panic>

00800c62 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c62:	55                   	push   %ebp
  800c63:	89 e5                	mov    %esp,%ebp
  800c65:	57                   	push   %edi
  800c66:	56                   	push   %esi
  800c67:	53                   	push   %ebx
  800c68:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c6b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c70:	8b 55 08             	mov    0x8(%ebp),%edx
  800c73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c76:	b8 06 00 00 00       	mov    $0x6,%eax
  800c7b:	89 df                	mov    %ebx,%edi
  800c7d:	89 de                	mov    %ebx,%esi
  800c7f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c81:	85 c0                	test   %eax,%eax
  800c83:	7f 08                	jg     800c8d <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c85:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c88:	5b                   	pop    %ebx
  800c89:	5e                   	pop    %esi
  800c8a:	5f                   	pop    %edi
  800c8b:	5d                   	pop    %ebp
  800c8c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8d:	83 ec 0c             	sub    $0xc,%esp
  800c90:	50                   	push   %eax
  800c91:	6a 06                	push   $0x6
  800c93:	68 1f 25 80 00       	push   $0x80251f
  800c98:	6a 23                	push   $0x23
  800c9a:	68 3c 25 80 00       	push   $0x80253c
  800c9f:	e8 ea 11 00 00       	call   801e8e <_panic>

00800ca4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	57                   	push   %edi
  800ca8:	56                   	push   %esi
  800ca9:	53                   	push   %ebx
  800caa:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cad:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb8:	b8 08 00 00 00       	mov    $0x8,%eax
  800cbd:	89 df                	mov    %ebx,%edi
  800cbf:	89 de                	mov    %ebx,%esi
  800cc1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cc3:	85 c0                	test   %eax,%eax
  800cc5:	7f 08                	jg     800ccf <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cc7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cca:	5b                   	pop    %ebx
  800ccb:	5e                   	pop    %esi
  800ccc:	5f                   	pop    %edi
  800ccd:	5d                   	pop    %ebp
  800cce:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccf:	83 ec 0c             	sub    $0xc,%esp
  800cd2:	50                   	push   %eax
  800cd3:	6a 08                	push   $0x8
  800cd5:	68 1f 25 80 00       	push   $0x80251f
  800cda:	6a 23                	push   $0x23
  800cdc:	68 3c 25 80 00       	push   $0x80253c
  800ce1:	e8 a8 11 00 00       	call   801e8e <_panic>

00800ce6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ce6:	55                   	push   %ebp
  800ce7:	89 e5                	mov    %esp,%ebp
  800ce9:	57                   	push   %edi
  800cea:	56                   	push   %esi
  800ceb:	53                   	push   %ebx
  800cec:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cef:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfa:	b8 09 00 00 00       	mov    $0x9,%eax
  800cff:	89 df                	mov    %ebx,%edi
  800d01:	89 de                	mov    %ebx,%esi
  800d03:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d05:	85 c0                	test   %eax,%eax
  800d07:	7f 08                	jg     800d11 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d09:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0c:	5b                   	pop    %ebx
  800d0d:	5e                   	pop    %esi
  800d0e:	5f                   	pop    %edi
  800d0f:	5d                   	pop    %ebp
  800d10:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d11:	83 ec 0c             	sub    $0xc,%esp
  800d14:	50                   	push   %eax
  800d15:	6a 09                	push   $0x9
  800d17:	68 1f 25 80 00       	push   $0x80251f
  800d1c:	6a 23                	push   $0x23
  800d1e:	68 3c 25 80 00       	push   $0x80253c
  800d23:	e8 66 11 00 00       	call   801e8e <_panic>

00800d28 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	57                   	push   %edi
  800d2c:	56                   	push   %esi
  800d2d:	53                   	push   %ebx
  800d2e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d31:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d36:	8b 55 08             	mov    0x8(%ebp),%edx
  800d39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d41:	89 df                	mov    %ebx,%edi
  800d43:	89 de                	mov    %ebx,%esi
  800d45:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d47:	85 c0                	test   %eax,%eax
  800d49:	7f 08                	jg     800d53 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4e:	5b                   	pop    %ebx
  800d4f:	5e                   	pop    %esi
  800d50:	5f                   	pop    %edi
  800d51:	5d                   	pop    %ebp
  800d52:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d53:	83 ec 0c             	sub    $0xc,%esp
  800d56:	50                   	push   %eax
  800d57:	6a 0a                	push   $0xa
  800d59:	68 1f 25 80 00       	push   $0x80251f
  800d5e:	6a 23                	push   $0x23
  800d60:	68 3c 25 80 00       	push   $0x80253c
  800d65:	e8 24 11 00 00       	call   801e8e <_panic>

00800d6a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d6a:	55                   	push   %ebp
  800d6b:	89 e5                	mov    %esp,%ebp
  800d6d:	57                   	push   %edi
  800d6e:	56                   	push   %esi
  800d6f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d70:	8b 55 08             	mov    0x8(%ebp),%edx
  800d73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d76:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d7b:	be 00 00 00 00       	mov    $0x0,%esi
  800d80:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d83:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d86:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d88:	5b                   	pop    %ebx
  800d89:	5e                   	pop    %esi
  800d8a:	5f                   	pop    %edi
  800d8b:	5d                   	pop    %ebp
  800d8c:	c3                   	ret    

00800d8d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d8d:	55                   	push   %ebp
  800d8e:	89 e5                	mov    %esp,%ebp
  800d90:	57                   	push   %edi
  800d91:	56                   	push   %esi
  800d92:	53                   	push   %ebx
  800d93:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d96:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800da3:	89 cb                	mov    %ecx,%ebx
  800da5:	89 cf                	mov    %ecx,%edi
  800da7:	89 ce                	mov    %ecx,%esi
  800da9:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dab:	85 c0                	test   %eax,%eax
  800dad:	7f 08                	jg     800db7 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800daf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db2:	5b                   	pop    %ebx
  800db3:	5e                   	pop    %esi
  800db4:	5f                   	pop    %edi
  800db5:	5d                   	pop    %ebp
  800db6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800db7:	83 ec 0c             	sub    $0xc,%esp
  800dba:	50                   	push   %eax
  800dbb:	6a 0d                	push   $0xd
  800dbd:	68 1f 25 80 00       	push   $0x80251f
  800dc2:	6a 23                	push   $0x23
  800dc4:	68 3c 25 80 00       	push   $0x80253c
  800dc9:	e8 c0 10 00 00       	call   801e8e <_panic>

00800dce <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800dce:	55                   	push   %ebp
  800dcf:	89 e5                	mov    %esp,%ebp
  800dd1:	56                   	push   %esi
  800dd2:	53                   	push   %ebx
  800dd3:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800dd6:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if((err&FEC_WR)==0 || (uvpt[PGNUM(addr)]&(PTE_W|PTE_COW))==0){
  800dd8:	8b 40 04             	mov    0x4(%eax),%eax
  800ddb:	83 e0 02             	and    $0x2,%eax
  800dde:	0f 84 82 00 00 00    	je     800e66 <pgfault+0x98>
  800de4:	89 da                	mov    %ebx,%edx
  800de6:	c1 ea 0c             	shr    $0xc,%edx
  800de9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800df0:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800df6:	74 6e                	je     800e66 <pgfault+0x98>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        envid_t envid = sys_getenvid();
  800df8:	e8 a2 fd ff ff       	call   800b9f <sys_getenvid>
  800dfd:	89 c6                	mov    %eax,%esi
	r = sys_page_alloc(envid,(void *)PFTEMP,PTE_P|PTE_W|PTE_U);
  800dff:	83 ec 04             	sub    $0x4,%esp
  800e02:	6a 07                	push   $0x7
  800e04:	68 00 f0 7f 00       	push   $0x7ff000
  800e09:	50                   	push   %eax
  800e0a:	e8 ce fd ff ff       	call   800bdd <sys_page_alloc>
	if(r<0) panic("pgfault:page allocation failed %e",r);
  800e0f:	83 c4 10             	add    $0x10,%esp
  800e12:	85 c0                	test   %eax,%eax
  800e14:	78 72                	js     800e88 <pgfault+0xba>

	addr = ROUNDDOWN(addr,PGSIZE);
  800e16:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy((void *)PFTEMP,(const void *)addr,PGSIZE);
  800e1c:	83 ec 04             	sub    $0x4,%esp
  800e1f:	68 00 10 00 00       	push   $0x1000
  800e24:	53                   	push   %ebx
  800e25:	68 00 f0 7f 00       	push   $0x7ff000
  800e2a:	e8 ab fb ff ff       	call   8009da <memcpy>

	if(sys_page_map(envid,(void *)PFTEMP, envid,addr,PTE_P|PTE_W|PTE_U)<0)
  800e2f:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e36:	53                   	push   %ebx
  800e37:	56                   	push   %esi
  800e38:	68 00 f0 7f 00       	push   $0x7ff000
  800e3d:	56                   	push   %esi
  800e3e:	e8 dd fd ff ff       	call   800c20 <sys_page_map>
  800e43:	83 c4 20             	add    $0x20,%esp
  800e46:	85 c0                	test   %eax,%eax
  800e48:	78 50                	js     800e9a <pgfault+0xcc>
		panic("pgfault:page map failed\n");
	if(sys_page_unmap(envid,(void *)PFTEMP)<0)
  800e4a:	83 ec 08             	sub    $0x8,%esp
  800e4d:	68 00 f0 7f 00       	push   $0x7ff000
  800e52:	56                   	push   %esi
  800e53:	e8 0a fe ff ff       	call   800c62 <sys_page_unmap>
  800e58:	83 c4 10             	add    $0x10,%esp
  800e5b:	85 c0                	test   %eax,%eax
  800e5d:	78 4f                	js     800eae <pgfault+0xe0>
		panic("pgfault: page upmap failed\n");
       //	panic("pgfault not implemented");
}
  800e5f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e62:	5b                   	pop    %ebx
  800e63:	5e                   	pop    %esi
  800e64:	5d                   	pop    %ebp
  800e65:	c3                   	ret    
		cprintf("Where is the error %d\n",err&FEC_WR);
  800e66:	83 ec 08             	sub    $0x8,%esp
  800e69:	50                   	push   %eax
  800e6a:	68 4a 25 80 00       	push   $0x80254a
  800e6f:	e8 51 f3 ff ff       	call   8001c5 <cprintf>
		panic("pgfault:invalid user trap");
  800e74:	83 c4 0c             	add    $0xc,%esp
  800e77:	68 61 25 80 00       	push   $0x802561
  800e7c:	6a 1e                	push   $0x1e
  800e7e:	68 7b 25 80 00       	push   $0x80257b
  800e83:	e8 06 10 00 00       	call   801e8e <_panic>
	if(r<0) panic("pgfault:page allocation failed %e",r);
  800e88:	50                   	push   %eax
  800e89:	68 68 26 80 00       	push   $0x802668
  800e8e:	6a 29                	push   $0x29
  800e90:	68 7b 25 80 00       	push   $0x80257b
  800e95:	e8 f4 0f 00 00       	call   801e8e <_panic>
		panic("pgfault:page map failed\n");
  800e9a:	83 ec 04             	sub    $0x4,%esp
  800e9d:	68 86 25 80 00       	push   $0x802586
  800ea2:	6a 2f                	push   $0x2f
  800ea4:	68 7b 25 80 00       	push   $0x80257b
  800ea9:	e8 e0 0f 00 00       	call   801e8e <_panic>
		panic("pgfault: page upmap failed\n");
  800eae:	83 ec 04             	sub    $0x4,%esp
  800eb1:	68 9f 25 80 00       	push   $0x80259f
  800eb6:	6a 31                	push   $0x31
  800eb8:	68 7b 25 80 00       	push   $0x80257b
  800ebd:	e8 cc 0f 00 00       	call   801e8e <_panic>

00800ec2 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ec2:	55                   	push   %ebp
  800ec3:	89 e5                	mov    %esp,%ebp
  800ec5:	57                   	push   %edi
  800ec6:	56                   	push   %esi
  800ec7:	53                   	push   %ebx
  800ec8:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	set_pgfault_handler(pgfault);
  800ecb:	68 ce 0d 80 00       	push   $0x800dce
  800ed0:	e8 ff 0f 00 00       	call   801ed4 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ed5:	b8 07 00 00 00       	mov    $0x7,%eax
  800eda:	cd 30                	int    $0x30
  800edc:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800edf:	89 45 e0             	mov    %eax,-0x20(%ebp)
       
	envid_t envid = sys_exofork();
	uintptr_t addr;
  
	if(envid<0) panic("sys_exofork failed\n");
  800ee2:	83 c4 10             	add    $0x10,%esp
  800ee5:	85 c0                	test   %eax,%eax
  800ee7:	78 27                	js     800f10 <fork+0x4e>
	if(envid==0){
	  thisenv = &envs[ENVX(sys_getenvid())];
	  return 0;
	}

	for(addr=(uintptr_t)UTEXT; addr<USTACKTOP;addr+=PGSIZE){
  800ee9:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if(envid==0){
  800eee:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800ef2:	75 5e                	jne    800f52 <fork+0x90>
	  thisenv = &envs[ENVX(sys_getenvid())];
  800ef4:	e8 a6 fc ff ff       	call   800b9f <sys_getenvid>
  800ef9:	25 ff 03 00 00       	and    $0x3ff,%eax
  800efe:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f01:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f06:	a3 04 40 80 00       	mov    %eax,0x804004
	  return 0;
  800f0b:	e9 fc 00 00 00       	jmp    80100c <fork+0x14a>
	if(envid<0) panic("sys_exofork failed\n");
  800f10:	83 ec 04             	sub    $0x4,%esp
  800f13:	68 bb 25 80 00       	push   $0x8025bb
  800f18:	6a 77                	push   $0x77
  800f1a:	68 7b 25 80 00       	push   $0x80257b
  800f1f:	e8 6a 0f 00 00       	call   801e8e <_panic>
          if((r=sys_page_map(parent_envid,va,envid,va,uvpt[pn]&PTE_SYSCALL))<0)
  800f24:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f2b:	83 ec 0c             	sub    $0xc,%esp
  800f2e:	25 07 0e 00 00       	and    $0xe07,%eax
  800f33:	50                   	push   %eax
  800f34:	57                   	push   %edi
  800f35:	ff 75 e0             	pushl  -0x20(%ebp)
  800f38:	57                   	push   %edi
  800f39:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f3c:	e8 df fc ff ff       	call   800c20 <sys_page_map>
  800f41:	83 c4 20             	add    $0x20,%esp
	for(addr=(uintptr_t)UTEXT; addr<USTACKTOP;addr+=PGSIZE){
  800f44:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f4a:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800f50:	74 76                	je     800fc8 <fork+0x106>
	   if((uvpd[PDX(addr)]&PTE_P) && uvpt[PGNUM(addr)] & PTE_P)
  800f52:	89 d8                	mov    %ebx,%eax
  800f54:	c1 e8 16             	shr    $0x16,%eax
  800f57:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f5e:	a8 01                	test   $0x1,%al
  800f60:	74 e2                	je     800f44 <fork+0x82>
  800f62:	89 de                	mov    %ebx,%esi
  800f64:	c1 ee 0c             	shr    $0xc,%esi
  800f67:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f6e:	a8 01                	test   $0x1,%al
  800f70:	74 d2                	je     800f44 <fork+0x82>
        envid_t parent_envid = sys_getenvid();
  800f72:	e8 28 fc ff ff       	call   800b9f <sys_getenvid>
  800f77:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	void *va = (void *)(pn*PGSIZE);
  800f7a:	89 f7                	mov    %esi,%edi
  800f7c:	c1 e7 0c             	shl    $0xc,%edi
        if(uvpt[pn] & PTE_SHARE){
  800f7f:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f86:	f6 c4 04             	test   $0x4,%ah
  800f89:	75 99                	jne    800f24 <fork+0x62>
	if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)){
  800f8b:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f92:	a8 02                	test   $0x2,%al
  800f94:	0f 85 ed 00 00 00    	jne    801087 <fork+0x1c5>
  800f9a:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fa1:	f6 c4 08             	test   $0x8,%ah
  800fa4:	0f 85 dd 00 00 00    	jne    801087 <fork+0x1c5>
	 if((r=sys_page_map(parent_envid,va,envid,va,perm))<0)
  800faa:	83 ec 0c             	sub    $0xc,%esp
  800fad:	6a 05                	push   $0x5
  800faf:	57                   	push   %edi
  800fb0:	ff 75 e0             	pushl  -0x20(%ebp)
  800fb3:	57                   	push   %edi
  800fb4:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fb7:	e8 64 fc ff ff       	call   800c20 <sys_page_map>
  800fbc:	83 c4 20             	add    $0x20,%esp
  800fbf:	85 c0                	test   %eax,%eax
  800fc1:	79 81                	jns    800f44 <fork+0x82>
  800fc3:	e9 db 00 00 00       	jmp    8010a3 <fork+0x1e1>
		   duppage(envid,PGNUM(addr));
	}
        
	int r;
	if((r=sys_page_alloc(envid,(void *)UXSTACKTOP-PGSIZE,PTE_U|PTE_P|PTE_W))<0)
  800fc8:	83 ec 04             	sub    $0x4,%esp
  800fcb:	6a 07                	push   $0x7
  800fcd:	68 00 f0 bf ee       	push   $0xeebff000
  800fd2:	ff 75 dc             	pushl  -0x24(%ebp)
  800fd5:	e8 03 fc ff ff       	call   800bdd <sys_page_alloc>
  800fda:	83 c4 10             	add    $0x10,%esp
  800fdd:	85 c0                	test   %eax,%eax
  800fdf:	78 36                	js     801017 <fork+0x155>
		panic("fork:page alloc failed %e\n",r);

	extern void _pgfault_upcall();
	if((r = sys_env_set_pgfault_upcall(envid,_pgfault_upcall)))
  800fe1:	83 ec 08             	sub    $0x8,%esp
  800fe4:	68 39 1f 80 00       	push   $0x801f39
  800fe9:	ff 75 dc             	pushl  -0x24(%ebp)
  800fec:	e8 37 fd ff ff       	call   800d28 <sys_env_set_pgfault_upcall>
  800ff1:	83 c4 10             	add    $0x10,%esp
  800ff4:	85 c0                	test   %eax,%eax
  800ff6:	75 34                	jne    80102c <fork+0x16a>
		panic("fork:set upcall failed %e\n",r);
	if((r = sys_env_set_status(envid,ENV_RUNNABLE))<0)
  800ff8:	83 ec 08             	sub    $0x8,%esp
  800ffb:	6a 02                	push   $0x2
  800ffd:	ff 75 dc             	pushl  -0x24(%ebp)
  801000:	e8 9f fc ff ff       	call   800ca4 <sys_env_set_status>
  801005:	83 c4 10             	add    $0x10,%esp
  801008:	85 c0                	test   %eax,%eax
  80100a:	78 35                	js     801041 <fork+0x17f>
		panic("fork:set status failed %e\n",r);
	//cprintf("forkid= %d\n", envid);
	return envid;
       	
}
  80100c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80100f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801012:	5b                   	pop    %ebx
  801013:	5e                   	pop    %esi
  801014:	5f                   	pop    %edi
  801015:	5d                   	pop    %ebp
  801016:	c3                   	ret    
		panic("fork:page alloc failed %e\n",r);
  801017:	50                   	push   %eax
  801018:	68 ff 25 80 00       	push   $0x8025ff
  80101d:	68 84 00 00 00       	push   $0x84
  801022:	68 7b 25 80 00       	push   $0x80257b
  801027:	e8 62 0e 00 00       	call   801e8e <_panic>
		panic("fork:set upcall failed %e\n",r);
  80102c:	50                   	push   %eax
  80102d:	68 1a 26 80 00       	push   $0x80261a
  801032:	68 88 00 00 00       	push   $0x88
  801037:	68 7b 25 80 00       	push   $0x80257b
  80103c:	e8 4d 0e 00 00       	call   801e8e <_panic>
		panic("fork:set status failed %e\n",r);
  801041:	50                   	push   %eax
  801042:	68 35 26 80 00       	push   $0x802635
  801047:	68 8a 00 00 00       	push   $0x8a
  80104c:	68 7b 25 80 00       	push   $0x80257b
  801051:	e8 38 0e 00 00       	call   801e8e <_panic>
		if( (r=sys_page_map(parent_envid,va,parent_envid,va,perm))<0){
  801056:	83 ec 0c             	sub    $0xc,%esp
  801059:	68 05 08 00 00       	push   $0x805
  80105e:	57                   	push   %edi
  80105f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801062:	50                   	push   %eax
  801063:	57                   	push   %edi
  801064:	50                   	push   %eax
  801065:	e8 b6 fb ff ff       	call   800c20 <sys_page_map>
  80106a:	83 c4 20             	add    $0x20,%esp
  80106d:	85 c0                	test   %eax,%eax
  80106f:	0f 89 cf fe ff ff    	jns    800f44 <fork+0x82>
		 panic("duppage:map02 failed %e",r);
  801075:	50                   	push   %eax
  801076:	68 e7 25 80 00       	push   $0x8025e7
  80107b:	6a 56                	push   $0x56
  80107d:	68 7b 25 80 00       	push   $0x80257b
  801082:	e8 07 0e 00 00       	call   801e8e <_panic>
	 if((r=sys_page_map(parent_envid,va,envid,va,perm))<0)
  801087:	83 ec 0c             	sub    $0xc,%esp
  80108a:	68 05 08 00 00       	push   $0x805
  80108f:	57                   	push   %edi
  801090:	ff 75 e0             	pushl  -0x20(%ebp)
  801093:	57                   	push   %edi
  801094:	ff 75 e4             	pushl  -0x1c(%ebp)
  801097:	e8 84 fb ff ff       	call   800c20 <sys_page_map>
  80109c:	83 c4 20             	add    $0x20,%esp
  80109f:	85 c0                	test   %eax,%eax
  8010a1:	79 b3                	jns    801056 <fork+0x194>
		 panic("duppage:map01 failed %e",r);
  8010a3:	50                   	push   %eax
  8010a4:	68 cf 25 80 00       	push   $0x8025cf
  8010a9:	6a 53                	push   $0x53
  8010ab:	68 7b 25 80 00       	push   $0x80257b
  8010b0:	e8 d9 0d 00 00       	call   801e8e <_panic>

008010b5 <sfork>:

// Challenge!
int
sfork(void)
{
  8010b5:	55                   	push   %ebp
  8010b6:	89 e5                	mov    %esp,%ebp
  8010b8:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010bb:	68 50 26 80 00       	push   $0x802650
  8010c0:	68 94 00 00 00       	push   $0x94
  8010c5:	68 7b 25 80 00       	push   $0x80257b
  8010ca:	e8 bf 0d 00 00       	call   801e8e <_panic>

008010cf <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010cf:	55                   	push   %ebp
  8010d0:	89 e5                	mov    %esp,%ebp
  8010d2:	56                   	push   %esi
  8010d3:	53                   	push   %ebx
  8010d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8010d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010da:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        //	panic("ipc_recv not implemented");
        int r;
       	if(pg!=NULL){
  8010dd:	85 c0                	test   %eax,%eax
  8010df:	74 3b                	je     80111c <ipc_recv+0x4d>
	  r = sys_ipc_recv(pg);
  8010e1:	83 ec 0c             	sub    $0xc,%esp
  8010e4:	50                   	push   %eax
  8010e5:	e8 a3 fc ff ff       	call   800d8d <sys_ipc_recv>
  8010ea:	83 c4 10             	add    $0x10,%esp
	}else
	  r = sys_ipc_recv((void *)UTOP);
	if(r<0){
  8010ed:	85 c0                	test   %eax,%eax
  8010ef:	78 3d                	js     80112e <ipc_recv+0x5f>
	if(perm_store!=NULL){
		*perm_store = 0;
            }
        	return r;
           }else{
	     if(from_env_store!=NULL)
  8010f1:	85 f6                	test   %esi,%esi
  8010f3:	74 0a                	je     8010ff <ipc_recv+0x30>
		     *from_env_store = thisenv->env_ipc_from;
  8010f5:	a1 04 40 80 00       	mov    0x804004,%eax
  8010fa:	8b 40 74             	mov    0x74(%eax),%eax
  8010fd:	89 06                	mov    %eax,(%esi)
	     if(perm_store != NULL)
  8010ff:	85 db                	test   %ebx,%ebx
  801101:	74 0a                	je     80110d <ipc_recv+0x3e>
		     *perm_store = thisenv->env_ipc_perm;
  801103:	a1 04 40 80 00       	mov    0x804004,%eax
  801108:	8b 40 78             	mov    0x78(%eax),%eax
  80110b:	89 03                	mov    %eax,(%ebx)
	     return thisenv->env_ipc_value;
  80110d:	a1 04 40 80 00       	mov    0x804004,%eax
  801112:	8b 40 70             	mov    0x70(%eax),%eax
	   }

}
  801115:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801118:	5b                   	pop    %ebx
  801119:	5e                   	pop    %esi
  80111a:	5d                   	pop    %ebp
  80111b:	c3                   	ret    
	  r = sys_ipc_recv((void *)UTOP);
  80111c:	83 ec 0c             	sub    $0xc,%esp
  80111f:	68 00 00 c0 ee       	push   $0xeec00000
  801124:	e8 64 fc ff ff       	call   800d8d <sys_ipc_recv>
  801129:	83 c4 10             	add    $0x10,%esp
  80112c:	eb bf                	jmp    8010ed <ipc_recv+0x1e>
	if(from_env_store!=NULL){
  80112e:	85 f6                	test   %esi,%esi
  801130:	74 06                	je     801138 <ipc_recv+0x69>
	  *from_env_store = 0;
  801132:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if(perm_store!=NULL){
  801138:	85 db                	test   %ebx,%ebx
  80113a:	74 d9                	je     801115 <ipc_recv+0x46>
		*perm_store = 0;
  80113c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801142:	eb d1                	jmp    801115 <ipc_recv+0x46>

00801144 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801144:	55                   	push   %ebp
  801145:	89 e5                	mov    %esp,%ebp
  801147:	57                   	push   %edi
  801148:	56                   	push   %esi
  801149:	53                   	push   %ebx
  80114a:	83 ec 0c             	sub    $0xc,%esp
  80114d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801150:	8b 75 0c             	mov    0xc(%ebp),%esi
  801153:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if(pg==NULL) pg = (void *)UTOP;
  801156:	85 db                	test   %ebx,%ebx
  801158:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80115d:	0f 44 d8             	cmove  %eax,%ebx
	while((r=sys_ipc_try_send(to_env,val,pg,perm))<0){
  801160:	ff 75 14             	pushl  0x14(%ebp)
  801163:	53                   	push   %ebx
  801164:	56                   	push   %esi
  801165:	57                   	push   %edi
  801166:	e8 ff fb ff ff       	call   800d6a <sys_ipc_try_send>
  80116b:	83 c4 10             	add    $0x10,%esp
  80116e:	85 c0                	test   %eax,%eax
  801170:	79 20                	jns    801192 <ipc_send+0x4e>
	    if(r!=-E_IPC_NOT_RECV){
  801172:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801175:	75 07                	jne    80117e <ipc_send+0x3a>
		    panic("ipc_send:send message failed\n");
	    }
	    sys_yield();
  801177:	e8 42 fa ff ff       	call   800bbe <sys_yield>
  80117c:	eb e2                	jmp    801160 <ipc_send+0x1c>
		    panic("ipc_send:send message failed\n");
  80117e:	83 ec 04             	sub    $0x4,%esp
  801181:	68 8a 26 80 00       	push   $0x80268a
  801186:	6a 43                	push   $0x43
  801188:	68 a8 26 80 00       	push   $0x8026a8
  80118d:	e8 fc 0c 00 00       	call   801e8e <_panic>
	}

}
  801192:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801195:	5b                   	pop    %ebx
  801196:	5e                   	pop    %esi
  801197:	5f                   	pop    %edi
  801198:	5d                   	pop    %ebp
  801199:	c3                   	ret    

0080119a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80119a:	55                   	push   %ebp
  80119b:	89 e5                	mov    %esp,%ebp
  80119d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8011a0:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8011a5:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8011a8:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8011ae:	8b 52 50             	mov    0x50(%edx),%edx
  8011b1:	39 ca                	cmp    %ecx,%edx
  8011b3:	74 11                	je     8011c6 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  8011b5:	83 c0 01             	add    $0x1,%eax
  8011b8:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011bd:	75 e6                	jne    8011a5 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8011bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8011c4:	eb 0b                	jmp    8011d1 <ipc_find_env+0x37>
			return envs[i].env_id;
  8011c6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011c9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011ce:	8b 40 48             	mov    0x48(%eax),%eax
}
  8011d1:	5d                   	pop    %ebp
  8011d2:	c3                   	ret    

008011d3 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011d3:	55                   	push   %ebp
  8011d4:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d9:	05 00 00 00 30       	add    $0x30000000,%eax
  8011de:	c1 e8 0c             	shr    $0xc,%eax
}
  8011e1:	5d                   	pop    %ebp
  8011e2:	c3                   	ret    

008011e3 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011e3:	55                   	push   %ebp
  8011e4:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e9:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8011ee:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011f3:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011f8:	5d                   	pop    %ebp
  8011f9:	c3                   	ret    

008011fa <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011fa:	55                   	push   %ebp
  8011fb:	89 e5                	mov    %esp,%ebp
  8011fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801200:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801205:	89 c2                	mov    %eax,%edx
  801207:	c1 ea 16             	shr    $0x16,%edx
  80120a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801211:	f6 c2 01             	test   $0x1,%dl
  801214:	74 2a                	je     801240 <fd_alloc+0x46>
  801216:	89 c2                	mov    %eax,%edx
  801218:	c1 ea 0c             	shr    $0xc,%edx
  80121b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801222:	f6 c2 01             	test   $0x1,%dl
  801225:	74 19                	je     801240 <fd_alloc+0x46>
  801227:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  80122c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801231:	75 d2                	jne    801205 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801233:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801239:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  80123e:	eb 07                	jmp    801247 <fd_alloc+0x4d>
			*fd_store = fd;
  801240:	89 01                	mov    %eax,(%ecx)
			return 0;
  801242:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801247:	5d                   	pop    %ebp
  801248:	c3                   	ret    

00801249 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801249:	55                   	push   %ebp
  80124a:	89 e5                	mov    %esp,%ebp
  80124c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80124f:	83 f8 1f             	cmp    $0x1f,%eax
  801252:	77 36                	ja     80128a <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801254:	c1 e0 0c             	shl    $0xc,%eax
  801257:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80125c:	89 c2                	mov    %eax,%edx
  80125e:	c1 ea 16             	shr    $0x16,%edx
  801261:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801268:	f6 c2 01             	test   $0x1,%dl
  80126b:	74 24                	je     801291 <fd_lookup+0x48>
  80126d:	89 c2                	mov    %eax,%edx
  80126f:	c1 ea 0c             	shr    $0xc,%edx
  801272:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801279:	f6 c2 01             	test   $0x1,%dl
  80127c:	74 1a                	je     801298 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80127e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801281:	89 02                	mov    %eax,(%edx)
	return 0;
  801283:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801288:	5d                   	pop    %ebp
  801289:	c3                   	ret    
		return -E_INVAL;
  80128a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80128f:	eb f7                	jmp    801288 <fd_lookup+0x3f>
		return -E_INVAL;
  801291:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801296:	eb f0                	jmp    801288 <fd_lookup+0x3f>
  801298:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80129d:	eb e9                	jmp    801288 <fd_lookup+0x3f>

0080129f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80129f:	55                   	push   %ebp
  8012a0:	89 e5                	mov    %esp,%ebp
  8012a2:	83 ec 08             	sub    $0x8,%esp
  8012a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012a8:	ba 30 27 80 00       	mov    $0x802730,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012ad:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  8012b2:	39 08                	cmp    %ecx,(%eax)
  8012b4:	74 33                	je     8012e9 <dev_lookup+0x4a>
  8012b6:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  8012b9:	8b 02                	mov    (%edx),%eax
  8012bb:	85 c0                	test   %eax,%eax
  8012bd:	75 f3                	jne    8012b2 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012bf:	a1 04 40 80 00       	mov    0x804004,%eax
  8012c4:	8b 40 48             	mov    0x48(%eax),%eax
  8012c7:	83 ec 04             	sub    $0x4,%esp
  8012ca:	51                   	push   %ecx
  8012cb:	50                   	push   %eax
  8012cc:	68 b4 26 80 00       	push   $0x8026b4
  8012d1:	e8 ef ee ff ff       	call   8001c5 <cprintf>
	*dev = 0;
  8012d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012d9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012df:	83 c4 10             	add    $0x10,%esp
  8012e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012e7:	c9                   	leave  
  8012e8:	c3                   	ret    
			*dev = devtab[i];
  8012e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012ec:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8012f3:	eb f2                	jmp    8012e7 <dev_lookup+0x48>

008012f5 <fd_close>:
{
  8012f5:	55                   	push   %ebp
  8012f6:	89 e5                	mov    %esp,%ebp
  8012f8:	57                   	push   %edi
  8012f9:	56                   	push   %esi
  8012fa:	53                   	push   %ebx
  8012fb:	83 ec 1c             	sub    $0x1c,%esp
  8012fe:	8b 75 08             	mov    0x8(%ebp),%esi
  801301:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801304:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801307:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801308:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80130e:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801311:	50                   	push   %eax
  801312:	e8 32 ff ff ff       	call   801249 <fd_lookup>
  801317:	89 c3                	mov    %eax,%ebx
  801319:	83 c4 08             	add    $0x8,%esp
  80131c:	85 c0                	test   %eax,%eax
  80131e:	78 05                	js     801325 <fd_close+0x30>
	    || fd != fd2)
  801320:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801323:	74 16                	je     80133b <fd_close+0x46>
		return (must_exist ? r : 0);
  801325:	89 f8                	mov    %edi,%eax
  801327:	84 c0                	test   %al,%al
  801329:	b8 00 00 00 00       	mov    $0x0,%eax
  80132e:	0f 44 d8             	cmove  %eax,%ebx
}
  801331:	89 d8                	mov    %ebx,%eax
  801333:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801336:	5b                   	pop    %ebx
  801337:	5e                   	pop    %esi
  801338:	5f                   	pop    %edi
  801339:	5d                   	pop    %ebp
  80133a:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80133b:	83 ec 08             	sub    $0x8,%esp
  80133e:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801341:	50                   	push   %eax
  801342:	ff 36                	pushl  (%esi)
  801344:	e8 56 ff ff ff       	call   80129f <dev_lookup>
  801349:	89 c3                	mov    %eax,%ebx
  80134b:	83 c4 10             	add    $0x10,%esp
  80134e:	85 c0                	test   %eax,%eax
  801350:	78 15                	js     801367 <fd_close+0x72>
		if (dev->dev_close)
  801352:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801355:	8b 40 10             	mov    0x10(%eax),%eax
  801358:	85 c0                	test   %eax,%eax
  80135a:	74 1b                	je     801377 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  80135c:	83 ec 0c             	sub    $0xc,%esp
  80135f:	56                   	push   %esi
  801360:	ff d0                	call   *%eax
  801362:	89 c3                	mov    %eax,%ebx
  801364:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801367:	83 ec 08             	sub    $0x8,%esp
  80136a:	56                   	push   %esi
  80136b:	6a 00                	push   $0x0
  80136d:	e8 f0 f8 ff ff       	call   800c62 <sys_page_unmap>
	return r;
  801372:	83 c4 10             	add    $0x10,%esp
  801375:	eb ba                	jmp    801331 <fd_close+0x3c>
			r = 0;
  801377:	bb 00 00 00 00       	mov    $0x0,%ebx
  80137c:	eb e9                	jmp    801367 <fd_close+0x72>

0080137e <close>:

int
close(int fdnum)
{
  80137e:	55                   	push   %ebp
  80137f:	89 e5                	mov    %esp,%ebp
  801381:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801384:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801387:	50                   	push   %eax
  801388:	ff 75 08             	pushl  0x8(%ebp)
  80138b:	e8 b9 fe ff ff       	call   801249 <fd_lookup>
  801390:	83 c4 08             	add    $0x8,%esp
  801393:	85 c0                	test   %eax,%eax
  801395:	78 10                	js     8013a7 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801397:	83 ec 08             	sub    $0x8,%esp
  80139a:	6a 01                	push   $0x1
  80139c:	ff 75 f4             	pushl  -0xc(%ebp)
  80139f:	e8 51 ff ff ff       	call   8012f5 <fd_close>
  8013a4:	83 c4 10             	add    $0x10,%esp
}
  8013a7:	c9                   	leave  
  8013a8:	c3                   	ret    

008013a9 <close_all>:

void
close_all(void)
{
  8013a9:	55                   	push   %ebp
  8013aa:	89 e5                	mov    %esp,%ebp
  8013ac:	53                   	push   %ebx
  8013ad:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013b0:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013b5:	83 ec 0c             	sub    $0xc,%esp
  8013b8:	53                   	push   %ebx
  8013b9:	e8 c0 ff ff ff       	call   80137e <close>
	for (i = 0; i < MAXFD; i++)
  8013be:	83 c3 01             	add    $0x1,%ebx
  8013c1:	83 c4 10             	add    $0x10,%esp
  8013c4:	83 fb 20             	cmp    $0x20,%ebx
  8013c7:	75 ec                	jne    8013b5 <close_all+0xc>
}
  8013c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013cc:	c9                   	leave  
  8013cd:	c3                   	ret    

008013ce <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013ce:	55                   	push   %ebp
  8013cf:	89 e5                	mov    %esp,%ebp
  8013d1:	57                   	push   %edi
  8013d2:	56                   	push   %esi
  8013d3:	53                   	push   %ebx
  8013d4:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013d7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013da:	50                   	push   %eax
  8013db:	ff 75 08             	pushl  0x8(%ebp)
  8013de:	e8 66 fe ff ff       	call   801249 <fd_lookup>
  8013e3:	89 c3                	mov    %eax,%ebx
  8013e5:	83 c4 08             	add    $0x8,%esp
  8013e8:	85 c0                	test   %eax,%eax
  8013ea:	0f 88 81 00 00 00    	js     801471 <dup+0xa3>
		return r;
	close(newfdnum);
  8013f0:	83 ec 0c             	sub    $0xc,%esp
  8013f3:	ff 75 0c             	pushl  0xc(%ebp)
  8013f6:	e8 83 ff ff ff       	call   80137e <close>

	newfd = INDEX2FD(newfdnum);
  8013fb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013fe:	c1 e6 0c             	shl    $0xc,%esi
  801401:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801407:	83 c4 04             	add    $0x4,%esp
  80140a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80140d:	e8 d1 fd ff ff       	call   8011e3 <fd2data>
  801412:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801414:	89 34 24             	mov    %esi,(%esp)
  801417:	e8 c7 fd ff ff       	call   8011e3 <fd2data>
  80141c:	83 c4 10             	add    $0x10,%esp
  80141f:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801421:	89 d8                	mov    %ebx,%eax
  801423:	c1 e8 16             	shr    $0x16,%eax
  801426:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80142d:	a8 01                	test   $0x1,%al
  80142f:	74 11                	je     801442 <dup+0x74>
  801431:	89 d8                	mov    %ebx,%eax
  801433:	c1 e8 0c             	shr    $0xc,%eax
  801436:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80143d:	f6 c2 01             	test   $0x1,%dl
  801440:	75 39                	jne    80147b <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801442:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801445:	89 d0                	mov    %edx,%eax
  801447:	c1 e8 0c             	shr    $0xc,%eax
  80144a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801451:	83 ec 0c             	sub    $0xc,%esp
  801454:	25 07 0e 00 00       	and    $0xe07,%eax
  801459:	50                   	push   %eax
  80145a:	56                   	push   %esi
  80145b:	6a 00                	push   $0x0
  80145d:	52                   	push   %edx
  80145e:	6a 00                	push   $0x0
  801460:	e8 bb f7 ff ff       	call   800c20 <sys_page_map>
  801465:	89 c3                	mov    %eax,%ebx
  801467:	83 c4 20             	add    $0x20,%esp
  80146a:	85 c0                	test   %eax,%eax
  80146c:	78 31                	js     80149f <dup+0xd1>
		goto err;

	return newfdnum;
  80146e:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801471:	89 d8                	mov    %ebx,%eax
  801473:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801476:	5b                   	pop    %ebx
  801477:	5e                   	pop    %esi
  801478:	5f                   	pop    %edi
  801479:	5d                   	pop    %ebp
  80147a:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80147b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801482:	83 ec 0c             	sub    $0xc,%esp
  801485:	25 07 0e 00 00       	and    $0xe07,%eax
  80148a:	50                   	push   %eax
  80148b:	57                   	push   %edi
  80148c:	6a 00                	push   $0x0
  80148e:	53                   	push   %ebx
  80148f:	6a 00                	push   $0x0
  801491:	e8 8a f7 ff ff       	call   800c20 <sys_page_map>
  801496:	89 c3                	mov    %eax,%ebx
  801498:	83 c4 20             	add    $0x20,%esp
  80149b:	85 c0                	test   %eax,%eax
  80149d:	79 a3                	jns    801442 <dup+0x74>
	sys_page_unmap(0, newfd);
  80149f:	83 ec 08             	sub    $0x8,%esp
  8014a2:	56                   	push   %esi
  8014a3:	6a 00                	push   $0x0
  8014a5:	e8 b8 f7 ff ff       	call   800c62 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014aa:	83 c4 08             	add    $0x8,%esp
  8014ad:	57                   	push   %edi
  8014ae:	6a 00                	push   $0x0
  8014b0:	e8 ad f7 ff ff       	call   800c62 <sys_page_unmap>
	return r;
  8014b5:	83 c4 10             	add    $0x10,%esp
  8014b8:	eb b7                	jmp    801471 <dup+0xa3>

008014ba <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014ba:	55                   	push   %ebp
  8014bb:	89 e5                	mov    %esp,%ebp
  8014bd:	53                   	push   %ebx
  8014be:	83 ec 14             	sub    $0x14,%esp
  8014c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014c7:	50                   	push   %eax
  8014c8:	53                   	push   %ebx
  8014c9:	e8 7b fd ff ff       	call   801249 <fd_lookup>
  8014ce:	83 c4 08             	add    $0x8,%esp
  8014d1:	85 c0                	test   %eax,%eax
  8014d3:	78 3f                	js     801514 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d5:	83 ec 08             	sub    $0x8,%esp
  8014d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014db:	50                   	push   %eax
  8014dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014df:	ff 30                	pushl  (%eax)
  8014e1:	e8 b9 fd ff ff       	call   80129f <dev_lookup>
  8014e6:	83 c4 10             	add    $0x10,%esp
  8014e9:	85 c0                	test   %eax,%eax
  8014eb:	78 27                	js     801514 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014ed:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014f0:	8b 42 08             	mov    0x8(%edx),%eax
  8014f3:	83 e0 03             	and    $0x3,%eax
  8014f6:	83 f8 01             	cmp    $0x1,%eax
  8014f9:	74 1e                	je     801519 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8014fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014fe:	8b 40 08             	mov    0x8(%eax),%eax
  801501:	85 c0                	test   %eax,%eax
  801503:	74 35                	je     80153a <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801505:	83 ec 04             	sub    $0x4,%esp
  801508:	ff 75 10             	pushl  0x10(%ebp)
  80150b:	ff 75 0c             	pushl  0xc(%ebp)
  80150e:	52                   	push   %edx
  80150f:	ff d0                	call   *%eax
  801511:	83 c4 10             	add    $0x10,%esp
}
  801514:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801517:	c9                   	leave  
  801518:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801519:	a1 04 40 80 00       	mov    0x804004,%eax
  80151e:	8b 40 48             	mov    0x48(%eax),%eax
  801521:	83 ec 04             	sub    $0x4,%esp
  801524:	53                   	push   %ebx
  801525:	50                   	push   %eax
  801526:	68 f5 26 80 00       	push   $0x8026f5
  80152b:	e8 95 ec ff ff       	call   8001c5 <cprintf>
		return -E_INVAL;
  801530:	83 c4 10             	add    $0x10,%esp
  801533:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801538:	eb da                	jmp    801514 <read+0x5a>
		return -E_NOT_SUPP;
  80153a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80153f:	eb d3                	jmp    801514 <read+0x5a>

00801541 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801541:	55                   	push   %ebp
  801542:	89 e5                	mov    %esp,%ebp
  801544:	57                   	push   %edi
  801545:	56                   	push   %esi
  801546:	53                   	push   %ebx
  801547:	83 ec 0c             	sub    $0xc,%esp
  80154a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80154d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801550:	bb 00 00 00 00       	mov    $0x0,%ebx
  801555:	39 f3                	cmp    %esi,%ebx
  801557:	73 25                	jae    80157e <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801559:	83 ec 04             	sub    $0x4,%esp
  80155c:	89 f0                	mov    %esi,%eax
  80155e:	29 d8                	sub    %ebx,%eax
  801560:	50                   	push   %eax
  801561:	89 d8                	mov    %ebx,%eax
  801563:	03 45 0c             	add    0xc(%ebp),%eax
  801566:	50                   	push   %eax
  801567:	57                   	push   %edi
  801568:	e8 4d ff ff ff       	call   8014ba <read>
		if (m < 0)
  80156d:	83 c4 10             	add    $0x10,%esp
  801570:	85 c0                	test   %eax,%eax
  801572:	78 08                	js     80157c <readn+0x3b>
			return m;
		if (m == 0)
  801574:	85 c0                	test   %eax,%eax
  801576:	74 06                	je     80157e <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  801578:	01 c3                	add    %eax,%ebx
  80157a:	eb d9                	jmp    801555 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80157c:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80157e:	89 d8                	mov    %ebx,%eax
  801580:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801583:	5b                   	pop    %ebx
  801584:	5e                   	pop    %esi
  801585:	5f                   	pop    %edi
  801586:	5d                   	pop    %ebp
  801587:	c3                   	ret    

00801588 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801588:	55                   	push   %ebp
  801589:	89 e5                	mov    %esp,%ebp
  80158b:	53                   	push   %ebx
  80158c:	83 ec 14             	sub    $0x14,%esp
  80158f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801592:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801595:	50                   	push   %eax
  801596:	53                   	push   %ebx
  801597:	e8 ad fc ff ff       	call   801249 <fd_lookup>
  80159c:	83 c4 08             	add    $0x8,%esp
  80159f:	85 c0                	test   %eax,%eax
  8015a1:	78 3a                	js     8015dd <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a3:	83 ec 08             	sub    $0x8,%esp
  8015a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a9:	50                   	push   %eax
  8015aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ad:	ff 30                	pushl  (%eax)
  8015af:	e8 eb fc ff ff       	call   80129f <dev_lookup>
  8015b4:	83 c4 10             	add    $0x10,%esp
  8015b7:	85 c0                	test   %eax,%eax
  8015b9:	78 22                	js     8015dd <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015be:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015c2:	74 1e                	je     8015e2 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015c7:	8b 52 0c             	mov    0xc(%edx),%edx
  8015ca:	85 d2                	test   %edx,%edx
  8015cc:	74 35                	je     801603 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015ce:	83 ec 04             	sub    $0x4,%esp
  8015d1:	ff 75 10             	pushl  0x10(%ebp)
  8015d4:	ff 75 0c             	pushl  0xc(%ebp)
  8015d7:	50                   	push   %eax
  8015d8:	ff d2                	call   *%edx
  8015da:	83 c4 10             	add    $0x10,%esp
}
  8015dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015e0:	c9                   	leave  
  8015e1:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015e2:	a1 04 40 80 00       	mov    0x804004,%eax
  8015e7:	8b 40 48             	mov    0x48(%eax),%eax
  8015ea:	83 ec 04             	sub    $0x4,%esp
  8015ed:	53                   	push   %ebx
  8015ee:	50                   	push   %eax
  8015ef:	68 11 27 80 00       	push   $0x802711
  8015f4:	e8 cc eb ff ff       	call   8001c5 <cprintf>
		return -E_INVAL;
  8015f9:	83 c4 10             	add    $0x10,%esp
  8015fc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801601:	eb da                	jmp    8015dd <write+0x55>
		return -E_NOT_SUPP;
  801603:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801608:	eb d3                	jmp    8015dd <write+0x55>

0080160a <seek>:

int
seek(int fdnum, off_t offset)
{
  80160a:	55                   	push   %ebp
  80160b:	89 e5                	mov    %esp,%ebp
  80160d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801610:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801613:	50                   	push   %eax
  801614:	ff 75 08             	pushl  0x8(%ebp)
  801617:	e8 2d fc ff ff       	call   801249 <fd_lookup>
  80161c:	83 c4 08             	add    $0x8,%esp
  80161f:	85 c0                	test   %eax,%eax
  801621:	78 0e                	js     801631 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801623:	8b 55 0c             	mov    0xc(%ebp),%edx
  801626:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801629:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80162c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801631:	c9                   	leave  
  801632:	c3                   	ret    

00801633 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801633:	55                   	push   %ebp
  801634:	89 e5                	mov    %esp,%ebp
  801636:	53                   	push   %ebx
  801637:	83 ec 14             	sub    $0x14,%esp
  80163a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80163d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801640:	50                   	push   %eax
  801641:	53                   	push   %ebx
  801642:	e8 02 fc ff ff       	call   801249 <fd_lookup>
  801647:	83 c4 08             	add    $0x8,%esp
  80164a:	85 c0                	test   %eax,%eax
  80164c:	78 37                	js     801685 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80164e:	83 ec 08             	sub    $0x8,%esp
  801651:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801654:	50                   	push   %eax
  801655:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801658:	ff 30                	pushl  (%eax)
  80165a:	e8 40 fc ff ff       	call   80129f <dev_lookup>
  80165f:	83 c4 10             	add    $0x10,%esp
  801662:	85 c0                	test   %eax,%eax
  801664:	78 1f                	js     801685 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801666:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801669:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80166d:	74 1b                	je     80168a <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80166f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801672:	8b 52 18             	mov    0x18(%edx),%edx
  801675:	85 d2                	test   %edx,%edx
  801677:	74 32                	je     8016ab <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801679:	83 ec 08             	sub    $0x8,%esp
  80167c:	ff 75 0c             	pushl  0xc(%ebp)
  80167f:	50                   	push   %eax
  801680:	ff d2                	call   *%edx
  801682:	83 c4 10             	add    $0x10,%esp
}
  801685:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801688:	c9                   	leave  
  801689:	c3                   	ret    
			thisenv->env_id, fdnum);
  80168a:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80168f:	8b 40 48             	mov    0x48(%eax),%eax
  801692:	83 ec 04             	sub    $0x4,%esp
  801695:	53                   	push   %ebx
  801696:	50                   	push   %eax
  801697:	68 d4 26 80 00       	push   $0x8026d4
  80169c:	e8 24 eb ff ff       	call   8001c5 <cprintf>
		return -E_INVAL;
  8016a1:	83 c4 10             	add    $0x10,%esp
  8016a4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016a9:	eb da                	jmp    801685 <ftruncate+0x52>
		return -E_NOT_SUPP;
  8016ab:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016b0:	eb d3                	jmp    801685 <ftruncate+0x52>

008016b2 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016b2:	55                   	push   %ebp
  8016b3:	89 e5                	mov    %esp,%ebp
  8016b5:	53                   	push   %ebx
  8016b6:	83 ec 14             	sub    $0x14,%esp
  8016b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016bf:	50                   	push   %eax
  8016c0:	ff 75 08             	pushl  0x8(%ebp)
  8016c3:	e8 81 fb ff ff       	call   801249 <fd_lookup>
  8016c8:	83 c4 08             	add    $0x8,%esp
  8016cb:	85 c0                	test   %eax,%eax
  8016cd:	78 4b                	js     80171a <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016cf:	83 ec 08             	sub    $0x8,%esp
  8016d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d5:	50                   	push   %eax
  8016d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016d9:	ff 30                	pushl  (%eax)
  8016db:	e8 bf fb ff ff       	call   80129f <dev_lookup>
  8016e0:	83 c4 10             	add    $0x10,%esp
  8016e3:	85 c0                	test   %eax,%eax
  8016e5:	78 33                	js     80171a <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  8016e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ea:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016ee:	74 2f                	je     80171f <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016f0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016f3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016fa:	00 00 00 
	stat->st_isdir = 0;
  8016fd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801704:	00 00 00 
	stat->st_dev = dev;
  801707:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80170d:	83 ec 08             	sub    $0x8,%esp
  801710:	53                   	push   %ebx
  801711:	ff 75 f0             	pushl  -0x10(%ebp)
  801714:	ff 50 14             	call   *0x14(%eax)
  801717:	83 c4 10             	add    $0x10,%esp
}
  80171a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80171d:	c9                   	leave  
  80171e:	c3                   	ret    
		return -E_NOT_SUPP;
  80171f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801724:	eb f4                	jmp    80171a <fstat+0x68>

00801726 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801726:	55                   	push   %ebp
  801727:	89 e5                	mov    %esp,%ebp
  801729:	56                   	push   %esi
  80172a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80172b:	83 ec 08             	sub    $0x8,%esp
  80172e:	6a 00                	push   $0x0
  801730:	ff 75 08             	pushl  0x8(%ebp)
  801733:	e8 e7 01 00 00       	call   80191f <open>
  801738:	89 c3                	mov    %eax,%ebx
  80173a:	83 c4 10             	add    $0x10,%esp
  80173d:	85 c0                	test   %eax,%eax
  80173f:	78 1b                	js     80175c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801741:	83 ec 08             	sub    $0x8,%esp
  801744:	ff 75 0c             	pushl  0xc(%ebp)
  801747:	50                   	push   %eax
  801748:	e8 65 ff ff ff       	call   8016b2 <fstat>
  80174d:	89 c6                	mov    %eax,%esi
	close(fd);
  80174f:	89 1c 24             	mov    %ebx,(%esp)
  801752:	e8 27 fc ff ff       	call   80137e <close>
	return r;
  801757:	83 c4 10             	add    $0x10,%esp
  80175a:	89 f3                	mov    %esi,%ebx
}
  80175c:	89 d8                	mov    %ebx,%eax
  80175e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801761:	5b                   	pop    %ebx
  801762:	5e                   	pop    %esi
  801763:	5d                   	pop    %ebp
  801764:	c3                   	ret    

00801765 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801765:	55                   	push   %ebp
  801766:	89 e5                	mov    %esp,%ebp
  801768:	56                   	push   %esi
  801769:	53                   	push   %ebx
  80176a:	89 c6                	mov    %eax,%esi
  80176c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80176e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801775:	74 27                	je     80179e <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801777:	6a 07                	push   $0x7
  801779:	68 00 50 80 00       	push   $0x805000
  80177e:	56                   	push   %esi
  80177f:	ff 35 00 40 80 00    	pushl  0x804000
  801785:	e8 ba f9 ff ff       	call   801144 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80178a:	83 c4 0c             	add    $0xc,%esp
  80178d:	6a 00                	push   $0x0
  80178f:	53                   	push   %ebx
  801790:	6a 00                	push   $0x0
  801792:	e8 38 f9 ff ff       	call   8010cf <ipc_recv>
}
  801797:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80179a:	5b                   	pop    %ebx
  80179b:	5e                   	pop    %esi
  80179c:	5d                   	pop    %ebp
  80179d:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80179e:	83 ec 0c             	sub    $0xc,%esp
  8017a1:	6a 01                	push   $0x1
  8017a3:	e8 f2 f9 ff ff       	call   80119a <ipc_find_env>
  8017a8:	a3 00 40 80 00       	mov    %eax,0x804000
  8017ad:	83 c4 10             	add    $0x10,%esp
  8017b0:	eb c5                	jmp    801777 <fsipc+0x12>

008017b2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017b2:	55                   	push   %ebp
  8017b3:	89 e5                	mov    %esp,%ebp
  8017b5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bb:	8b 40 0c             	mov    0xc(%eax),%eax
  8017be:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017c6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d0:	b8 02 00 00 00       	mov    $0x2,%eax
  8017d5:	e8 8b ff ff ff       	call   801765 <fsipc>
}
  8017da:	c9                   	leave  
  8017db:	c3                   	ret    

008017dc <devfile_flush>:
{
  8017dc:	55                   	push   %ebp
  8017dd:	89 e5                	mov    %esp,%ebp
  8017df:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e5:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f2:	b8 06 00 00 00       	mov    $0x6,%eax
  8017f7:	e8 69 ff ff ff       	call   801765 <fsipc>
}
  8017fc:	c9                   	leave  
  8017fd:	c3                   	ret    

008017fe <devfile_stat>:
{
  8017fe:	55                   	push   %ebp
  8017ff:	89 e5                	mov    %esp,%ebp
  801801:	53                   	push   %ebx
  801802:	83 ec 04             	sub    $0x4,%esp
  801805:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801808:	8b 45 08             	mov    0x8(%ebp),%eax
  80180b:	8b 40 0c             	mov    0xc(%eax),%eax
  80180e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801813:	ba 00 00 00 00       	mov    $0x0,%edx
  801818:	b8 05 00 00 00       	mov    $0x5,%eax
  80181d:	e8 43 ff ff ff       	call   801765 <fsipc>
  801822:	85 c0                	test   %eax,%eax
  801824:	78 2c                	js     801852 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801826:	83 ec 08             	sub    $0x8,%esp
  801829:	68 00 50 80 00       	push   $0x805000
  80182e:	53                   	push   %ebx
  80182f:	e8 b0 ef ff ff       	call   8007e4 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801834:	a1 80 50 80 00       	mov    0x805080,%eax
  801839:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80183f:	a1 84 50 80 00       	mov    0x805084,%eax
  801844:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80184a:	83 c4 10             	add    $0x10,%esp
  80184d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801852:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801855:	c9                   	leave  
  801856:	c3                   	ret    

00801857 <devfile_write>:
{
  801857:	55                   	push   %ebp
  801858:	89 e5                	mov    %esp,%ebp
  80185a:	83 ec 0c             	sub    $0xc,%esp
  80185d:	8b 45 10             	mov    0x10(%ebp),%eax
  801860:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801865:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80186a:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80186d:	8b 55 08             	mov    0x8(%ebp),%edx
  801870:	8b 52 0c             	mov    0xc(%edx),%edx
  801873:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801879:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf,buf,n);
  80187e:	50                   	push   %eax
  80187f:	ff 75 0c             	pushl  0xc(%ebp)
  801882:	68 08 50 80 00       	push   $0x805008
  801887:	e8 e6 f0 ff ff       	call   800972 <memmove>
	if((r = fsipc(FSREQ_WRITE,NULL))<0)
  80188c:	ba 00 00 00 00       	mov    $0x0,%edx
  801891:	b8 04 00 00 00       	mov    $0x4,%eax
  801896:	e8 ca fe ff ff       	call   801765 <fsipc>
}
  80189b:	c9                   	leave  
  80189c:	c3                   	ret    

0080189d <devfile_read>:
{
  80189d:	55                   	push   %ebp
  80189e:	89 e5                	mov    %esp,%ebp
  8018a0:	56                   	push   %esi
  8018a1:	53                   	push   %ebx
  8018a2:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a8:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ab:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018b0:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8018bb:	b8 03 00 00 00       	mov    $0x3,%eax
  8018c0:	e8 a0 fe ff ff       	call   801765 <fsipc>
  8018c5:	89 c3                	mov    %eax,%ebx
  8018c7:	85 c0                	test   %eax,%eax
  8018c9:	78 1f                	js     8018ea <devfile_read+0x4d>
	assert(r <= n);
  8018cb:	39 f0                	cmp    %esi,%eax
  8018cd:	77 24                	ja     8018f3 <devfile_read+0x56>
	assert(r <= PGSIZE);
  8018cf:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018d4:	7f 33                	jg     801909 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018d6:	83 ec 04             	sub    $0x4,%esp
  8018d9:	50                   	push   %eax
  8018da:	68 00 50 80 00       	push   $0x805000
  8018df:	ff 75 0c             	pushl  0xc(%ebp)
  8018e2:	e8 8b f0 ff ff       	call   800972 <memmove>
	return r;
  8018e7:	83 c4 10             	add    $0x10,%esp
}
  8018ea:	89 d8                	mov    %ebx,%eax
  8018ec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018ef:	5b                   	pop    %ebx
  8018f0:	5e                   	pop    %esi
  8018f1:	5d                   	pop    %ebp
  8018f2:	c3                   	ret    
	assert(r <= n);
  8018f3:	68 40 27 80 00       	push   $0x802740
  8018f8:	68 47 27 80 00       	push   $0x802747
  8018fd:	6a 7c                	push   $0x7c
  8018ff:	68 5c 27 80 00       	push   $0x80275c
  801904:	e8 85 05 00 00       	call   801e8e <_panic>
	assert(r <= PGSIZE);
  801909:	68 67 27 80 00       	push   $0x802767
  80190e:	68 47 27 80 00       	push   $0x802747
  801913:	6a 7d                	push   $0x7d
  801915:	68 5c 27 80 00       	push   $0x80275c
  80191a:	e8 6f 05 00 00       	call   801e8e <_panic>

0080191f <open>:
{
  80191f:	55                   	push   %ebp
  801920:	89 e5                	mov    %esp,%ebp
  801922:	56                   	push   %esi
  801923:	53                   	push   %ebx
  801924:	83 ec 1c             	sub    $0x1c,%esp
  801927:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80192a:	56                   	push   %esi
  80192b:	e8 7d ee ff ff       	call   8007ad <strlen>
  801930:	83 c4 10             	add    $0x10,%esp
  801933:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801938:	7f 6c                	jg     8019a6 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  80193a:	83 ec 0c             	sub    $0xc,%esp
  80193d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801940:	50                   	push   %eax
  801941:	e8 b4 f8 ff ff       	call   8011fa <fd_alloc>
  801946:	89 c3                	mov    %eax,%ebx
  801948:	83 c4 10             	add    $0x10,%esp
  80194b:	85 c0                	test   %eax,%eax
  80194d:	78 3c                	js     80198b <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  80194f:	83 ec 08             	sub    $0x8,%esp
  801952:	56                   	push   %esi
  801953:	68 00 50 80 00       	push   $0x805000
  801958:	e8 87 ee ff ff       	call   8007e4 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80195d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801960:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801965:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801968:	b8 01 00 00 00       	mov    $0x1,%eax
  80196d:	e8 f3 fd ff ff       	call   801765 <fsipc>
  801972:	89 c3                	mov    %eax,%ebx
  801974:	83 c4 10             	add    $0x10,%esp
  801977:	85 c0                	test   %eax,%eax
  801979:	78 19                	js     801994 <open+0x75>
	return fd2num(fd);
  80197b:	83 ec 0c             	sub    $0xc,%esp
  80197e:	ff 75 f4             	pushl  -0xc(%ebp)
  801981:	e8 4d f8 ff ff       	call   8011d3 <fd2num>
  801986:	89 c3                	mov    %eax,%ebx
  801988:	83 c4 10             	add    $0x10,%esp
}
  80198b:	89 d8                	mov    %ebx,%eax
  80198d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801990:	5b                   	pop    %ebx
  801991:	5e                   	pop    %esi
  801992:	5d                   	pop    %ebp
  801993:	c3                   	ret    
		fd_close(fd, 0);
  801994:	83 ec 08             	sub    $0x8,%esp
  801997:	6a 00                	push   $0x0
  801999:	ff 75 f4             	pushl  -0xc(%ebp)
  80199c:	e8 54 f9 ff ff       	call   8012f5 <fd_close>
		return r;
  8019a1:	83 c4 10             	add    $0x10,%esp
  8019a4:	eb e5                	jmp    80198b <open+0x6c>
		return -E_BAD_PATH;
  8019a6:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8019ab:	eb de                	jmp    80198b <open+0x6c>

008019ad <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019ad:	55                   	push   %ebp
  8019ae:	89 e5                	mov    %esp,%ebp
  8019b0:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8019b8:	b8 08 00 00 00       	mov    $0x8,%eax
  8019bd:	e8 a3 fd ff ff       	call   801765 <fsipc>
}
  8019c2:	c9                   	leave  
  8019c3:	c3                   	ret    

008019c4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019c4:	55                   	push   %ebp
  8019c5:	89 e5                	mov    %esp,%ebp
  8019c7:	56                   	push   %esi
  8019c8:	53                   	push   %ebx
  8019c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019cc:	83 ec 0c             	sub    $0xc,%esp
  8019cf:	ff 75 08             	pushl  0x8(%ebp)
  8019d2:	e8 0c f8 ff ff       	call   8011e3 <fd2data>
  8019d7:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019d9:	83 c4 08             	add    $0x8,%esp
  8019dc:	68 73 27 80 00       	push   $0x802773
  8019e1:	53                   	push   %ebx
  8019e2:	e8 fd ed ff ff       	call   8007e4 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019e7:	8b 46 04             	mov    0x4(%esi),%eax
  8019ea:	2b 06                	sub    (%esi),%eax
  8019ec:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019f2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019f9:	00 00 00 
	stat->st_dev = &devpipe;
  8019fc:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a03:	30 80 00 
	return 0;
}
  801a06:	b8 00 00 00 00       	mov    $0x0,%eax
  801a0b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a0e:	5b                   	pop    %ebx
  801a0f:	5e                   	pop    %esi
  801a10:	5d                   	pop    %ebp
  801a11:	c3                   	ret    

00801a12 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a12:	55                   	push   %ebp
  801a13:	89 e5                	mov    %esp,%ebp
  801a15:	53                   	push   %ebx
  801a16:	83 ec 0c             	sub    $0xc,%esp
  801a19:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a1c:	53                   	push   %ebx
  801a1d:	6a 00                	push   $0x0
  801a1f:	e8 3e f2 ff ff       	call   800c62 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a24:	89 1c 24             	mov    %ebx,(%esp)
  801a27:	e8 b7 f7 ff ff       	call   8011e3 <fd2data>
  801a2c:	83 c4 08             	add    $0x8,%esp
  801a2f:	50                   	push   %eax
  801a30:	6a 00                	push   $0x0
  801a32:	e8 2b f2 ff ff       	call   800c62 <sys_page_unmap>
}
  801a37:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a3a:	c9                   	leave  
  801a3b:	c3                   	ret    

00801a3c <_pipeisclosed>:
{
  801a3c:	55                   	push   %ebp
  801a3d:	89 e5                	mov    %esp,%ebp
  801a3f:	57                   	push   %edi
  801a40:	56                   	push   %esi
  801a41:	53                   	push   %ebx
  801a42:	83 ec 1c             	sub    $0x1c,%esp
  801a45:	89 c7                	mov    %eax,%edi
  801a47:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801a49:	a1 04 40 80 00       	mov    0x804004,%eax
  801a4e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a51:	83 ec 0c             	sub    $0xc,%esp
  801a54:	57                   	push   %edi
  801a55:	e8 06 05 00 00       	call   801f60 <pageref>
  801a5a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801a5d:	89 34 24             	mov    %esi,(%esp)
  801a60:	e8 fb 04 00 00       	call   801f60 <pageref>
		nn = thisenv->env_runs;
  801a65:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a6b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a6e:	83 c4 10             	add    $0x10,%esp
  801a71:	39 cb                	cmp    %ecx,%ebx
  801a73:	74 1b                	je     801a90 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801a75:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801a78:	75 cf                	jne    801a49 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a7a:	8b 42 58             	mov    0x58(%edx),%eax
  801a7d:	6a 01                	push   $0x1
  801a7f:	50                   	push   %eax
  801a80:	53                   	push   %ebx
  801a81:	68 7a 27 80 00       	push   $0x80277a
  801a86:	e8 3a e7 ff ff       	call   8001c5 <cprintf>
  801a8b:	83 c4 10             	add    $0x10,%esp
  801a8e:	eb b9                	jmp    801a49 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801a90:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801a93:	0f 94 c0             	sete   %al
  801a96:	0f b6 c0             	movzbl %al,%eax
}
  801a99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a9c:	5b                   	pop    %ebx
  801a9d:	5e                   	pop    %esi
  801a9e:	5f                   	pop    %edi
  801a9f:	5d                   	pop    %ebp
  801aa0:	c3                   	ret    

00801aa1 <devpipe_write>:
{
  801aa1:	55                   	push   %ebp
  801aa2:	89 e5                	mov    %esp,%ebp
  801aa4:	57                   	push   %edi
  801aa5:	56                   	push   %esi
  801aa6:	53                   	push   %ebx
  801aa7:	83 ec 28             	sub    $0x28,%esp
  801aaa:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801aad:	56                   	push   %esi
  801aae:	e8 30 f7 ff ff       	call   8011e3 <fd2data>
  801ab3:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801ab5:	83 c4 10             	add    $0x10,%esp
  801ab8:	bf 00 00 00 00       	mov    $0x0,%edi
  801abd:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ac0:	74 4f                	je     801b11 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ac2:	8b 43 04             	mov    0x4(%ebx),%eax
  801ac5:	8b 0b                	mov    (%ebx),%ecx
  801ac7:	8d 51 20             	lea    0x20(%ecx),%edx
  801aca:	39 d0                	cmp    %edx,%eax
  801acc:	72 14                	jb     801ae2 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801ace:	89 da                	mov    %ebx,%edx
  801ad0:	89 f0                	mov    %esi,%eax
  801ad2:	e8 65 ff ff ff       	call   801a3c <_pipeisclosed>
  801ad7:	85 c0                	test   %eax,%eax
  801ad9:	75 3a                	jne    801b15 <devpipe_write+0x74>
			sys_yield();
  801adb:	e8 de f0 ff ff       	call   800bbe <sys_yield>
  801ae0:	eb e0                	jmp    801ac2 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ae2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ae5:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ae9:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801aec:	89 c2                	mov    %eax,%edx
  801aee:	c1 fa 1f             	sar    $0x1f,%edx
  801af1:	89 d1                	mov    %edx,%ecx
  801af3:	c1 e9 1b             	shr    $0x1b,%ecx
  801af6:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801af9:	83 e2 1f             	and    $0x1f,%edx
  801afc:	29 ca                	sub    %ecx,%edx
  801afe:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b02:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b06:	83 c0 01             	add    $0x1,%eax
  801b09:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801b0c:	83 c7 01             	add    $0x1,%edi
  801b0f:	eb ac                	jmp    801abd <devpipe_write+0x1c>
	return i;
  801b11:	89 f8                	mov    %edi,%eax
  801b13:	eb 05                	jmp    801b1a <devpipe_write+0x79>
				return 0;
  801b15:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b1d:	5b                   	pop    %ebx
  801b1e:	5e                   	pop    %esi
  801b1f:	5f                   	pop    %edi
  801b20:	5d                   	pop    %ebp
  801b21:	c3                   	ret    

00801b22 <devpipe_read>:
{
  801b22:	55                   	push   %ebp
  801b23:	89 e5                	mov    %esp,%ebp
  801b25:	57                   	push   %edi
  801b26:	56                   	push   %esi
  801b27:	53                   	push   %ebx
  801b28:	83 ec 18             	sub    $0x18,%esp
  801b2b:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801b2e:	57                   	push   %edi
  801b2f:	e8 af f6 ff ff       	call   8011e3 <fd2data>
  801b34:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b36:	83 c4 10             	add    $0x10,%esp
  801b39:	be 00 00 00 00       	mov    $0x0,%esi
  801b3e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b41:	74 47                	je     801b8a <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  801b43:	8b 03                	mov    (%ebx),%eax
  801b45:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b48:	75 22                	jne    801b6c <devpipe_read+0x4a>
			if (i > 0)
  801b4a:	85 f6                	test   %esi,%esi
  801b4c:	75 14                	jne    801b62 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801b4e:	89 da                	mov    %ebx,%edx
  801b50:	89 f8                	mov    %edi,%eax
  801b52:	e8 e5 fe ff ff       	call   801a3c <_pipeisclosed>
  801b57:	85 c0                	test   %eax,%eax
  801b59:	75 33                	jne    801b8e <devpipe_read+0x6c>
			sys_yield();
  801b5b:	e8 5e f0 ff ff       	call   800bbe <sys_yield>
  801b60:	eb e1                	jmp    801b43 <devpipe_read+0x21>
				return i;
  801b62:	89 f0                	mov    %esi,%eax
}
  801b64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b67:	5b                   	pop    %ebx
  801b68:	5e                   	pop    %esi
  801b69:	5f                   	pop    %edi
  801b6a:	5d                   	pop    %ebp
  801b6b:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b6c:	99                   	cltd   
  801b6d:	c1 ea 1b             	shr    $0x1b,%edx
  801b70:	01 d0                	add    %edx,%eax
  801b72:	83 e0 1f             	and    $0x1f,%eax
  801b75:	29 d0                	sub    %edx,%eax
  801b77:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801b7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b7f:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801b82:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801b85:	83 c6 01             	add    $0x1,%esi
  801b88:	eb b4                	jmp    801b3e <devpipe_read+0x1c>
	return i;
  801b8a:	89 f0                	mov    %esi,%eax
  801b8c:	eb d6                	jmp    801b64 <devpipe_read+0x42>
				return 0;
  801b8e:	b8 00 00 00 00       	mov    $0x0,%eax
  801b93:	eb cf                	jmp    801b64 <devpipe_read+0x42>

00801b95 <pipe>:
{
  801b95:	55                   	push   %ebp
  801b96:	89 e5                	mov    %esp,%ebp
  801b98:	56                   	push   %esi
  801b99:	53                   	push   %ebx
  801b9a:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801b9d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ba0:	50                   	push   %eax
  801ba1:	e8 54 f6 ff ff       	call   8011fa <fd_alloc>
  801ba6:	89 c3                	mov    %eax,%ebx
  801ba8:	83 c4 10             	add    $0x10,%esp
  801bab:	85 c0                	test   %eax,%eax
  801bad:	78 5b                	js     801c0a <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801baf:	83 ec 04             	sub    $0x4,%esp
  801bb2:	68 07 04 00 00       	push   $0x407
  801bb7:	ff 75 f4             	pushl  -0xc(%ebp)
  801bba:	6a 00                	push   $0x0
  801bbc:	e8 1c f0 ff ff       	call   800bdd <sys_page_alloc>
  801bc1:	89 c3                	mov    %eax,%ebx
  801bc3:	83 c4 10             	add    $0x10,%esp
  801bc6:	85 c0                	test   %eax,%eax
  801bc8:	78 40                	js     801c0a <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  801bca:	83 ec 0c             	sub    $0xc,%esp
  801bcd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bd0:	50                   	push   %eax
  801bd1:	e8 24 f6 ff ff       	call   8011fa <fd_alloc>
  801bd6:	89 c3                	mov    %eax,%ebx
  801bd8:	83 c4 10             	add    $0x10,%esp
  801bdb:	85 c0                	test   %eax,%eax
  801bdd:	78 1b                	js     801bfa <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bdf:	83 ec 04             	sub    $0x4,%esp
  801be2:	68 07 04 00 00       	push   $0x407
  801be7:	ff 75 f0             	pushl  -0x10(%ebp)
  801bea:	6a 00                	push   $0x0
  801bec:	e8 ec ef ff ff       	call   800bdd <sys_page_alloc>
  801bf1:	89 c3                	mov    %eax,%ebx
  801bf3:	83 c4 10             	add    $0x10,%esp
  801bf6:	85 c0                	test   %eax,%eax
  801bf8:	79 19                	jns    801c13 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  801bfa:	83 ec 08             	sub    $0x8,%esp
  801bfd:	ff 75 f4             	pushl  -0xc(%ebp)
  801c00:	6a 00                	push   $0x0
  801c02:	e8 5b f0 ff ff       	call   800c62 <sys_page_unmap>
  801c07:	83 c4 10             	add    $0x10,%esp
}
  801c0a:	89 d8                	mov    %ebx,%eax
  801c0c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c0f:	5b                   	pop    %ebx
  801c10:	5e                   	pop    %esi
  801c11:	5d                   	pop    %ebp
  801c12:	c3                   	ret    
	va = fd2data(fd0);
  801c13:	83 ec 0c             	sub    $0xc,%esp
  801c16:	ff 75 f4             	pushl  -0xc(%ebp)
  801c19:	e8 c5 f5 ff ff       	call   8011e3 <fd2data>
  801c1e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c20:	83 c4 0c             	add    $0xc,%esp
  801c23:	68 07 04 00 00       	push   $0x407
  801c28:	50                   	push   %eax
  801c29:	6a 00                	push   $0x0
  801c2b:	e8 ad ef ff ff       	call   800bdd <sys_page_alloc>
  801c30:	89 c3                	mov    %eax,%ebx
  801c32:	83 c4 10             	add    $0x10,%esp
  801c35:	85 c0                	test   %eax,%eax
  801c37:	0f 88 8c 00 00 00    	js     801cc9 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c3d:	83 ec 0c             	sub    $0xc,%esp
  801c40:	ff 75 f0             	pushl  -0x10(%ebp)
  801c43:	e8 9b f5 ff ff       	call   8011e3 <fd2data>
  801c48:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c4f:	50                   	push   %eax
  801c50:	6a 00                	push   $0x0
  801c52:	56                   	push   %esi
  801c53:	6a 00                	push   $0x0
  801c55:	e8 c6 ef ff ff       	call   800c20 <sys_page_map>
  801c5a:	89 c3                	mov    %eax,%ebx
  801c5c:	83 c4 20             	add    $0x20,%esp
  801c5f:	85 c0                	test   %eax,%eax
  801c61:	78 58                	js     801cbb <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801c63:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c66:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c6c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c71:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801c78:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c7b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c81:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c83:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c86:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801c8d:	83 ec 0c             	sub    $0xc,%esp
  801c90:	ff 75 f4             	pushl  -0xc(%ebp)
  801c93:	e8 3b f5 ff ff       	call   8011d3 <fd2num>
  801c98:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c9b:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c9d:	83 c4 04             	add    $0x4,%esp
  801ca0:	ff 75 f0             	pushl  -0x10(%ebp)
  801ca3:	e8 2b f5 ff ff       	call   8011d3 <fd2num>
  801ca8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cab:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801cae:	83 c4 10             	add    $0x10,%esp
  801cb1:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cb6:	e9 4f ff ff ff       	jmp    801c0a <pipe+0x75>
	sys_page_unmap(0, va);
  801cbb:	83 ec 08             	sub    $0x8,%esp
  801cbe:	56                   	push   %esi
  801cbf:	6a 00                	push   $0x0
  801cc1:	e8 9c ef ff ff       	call   800c62 <sys_page_unmap>
  801cc6:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801cc9:	83 ec 08             	sub    $0x8,%esp
  801ccc:	ff 75 f0             	pushl  -0x10(%ebp)
  801ccf:	6a 00                	push   $0x0
  801cd1:	e8 8c ef ff ff       	call   800c62 <sys_page_unmap>
  801cd6:	83 c4 10             	add    $0x10,%esp
  801cd9:	e9 1c ff ff ff       	jmp    801bfa <pipe+0x65>

00801cde <pipeisclosed>:
{
  801cde:	55                   	push   %ebp
  801cdf:	89 e5                	mov    %esp,%ebp
  801ce1:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ce4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ce7:	50                   	push   %eax
  801ce8:	ff 75 08             	pushl  0x8(%ebp)
  801ceb:	e8 59 f5 ff ff       	call   801249 <fd_lookup>
  801cf0:	83 c4 10             	add    $0x10,%esp
  801cf3:	85 c0                	test   %eax,%eax
  801cf5:	78 18                	js     801d0f <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801cf7:	83 ec 0c             	sub    $0xc,%esp
  801cfa:	ff 75 f4             	pushl  -0xc(%ebp)
  801cfd:	e8 e1 f4 ff ff       	call   8011e3 <fd2data>
	return _pipeisclosed(fd, p);
  801d02:	89 c2                	mov    %eax,%edx
  801d04:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d07:	e8 30 fd ff ff       	call   801a3c <_pipeisclosed>
  801d0c:	83 c4 10             	add    $0x10,%esp
}
  801d0f:	c9                   	leave  
  801d10:	c3                   	ret    

00801d11 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d11:	55                   	push   %ebp
  801d12:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d14:	b8 00 00 00 00       	mov    $0x0,%eax
  801d19:	5d                   	pop    %ebp
  801d1a:	c3                   	ret    

00801d1b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d1b:	55                   	push   %ebp
  801d1c:	89 e5                	mov    %esp,%ebp
  801d1e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d21:	68 92 27 80 00       	push   $0x802792
  801d26:	ff 75 0c             	pushl  0xc(%ebp)
  801d29:	e8 b6 ea ff ff       	call   8007e4 <strcpy>
	return 0;
}
  801d2e:	b8 00 00 00 00       	mov    $0x0,%eax
  801d33:	c9                   	leave  
  801d34:	c3                   	ret    

00801d35 <devcons_write>:
{
  801d35:	55                   	push   %ebp
  801d36:	89 e5                	mov    %esp,%ebp
  801d38:	57                   	push   %edi
  801d39:	56                   	push   %esi
  801d3a:	53                   	push   %ebx
  801d3b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801d41:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801d46:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801d4c:	eb 2f                	jmp    801d7d <devcons_write+0x48>
		m = n - tot;
  801d4e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d51:	29 f3                	sub    %esi,%ebx
  801d53:	83 fb 7f             	cmp    $0x7f,%ebx
  801d56:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801d5b:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801d5e:	83 ec 04             	sub    $0x4,%esp
  801d61:	53                   	push   %ebx
  801d62:	89 f0                	mov    %esi,%eax
  801d64:	03 45 0c             	add    0xc(%ebp),%eax
  801d67:	50                   	push   %eax
  801d68:	57                   	push   %edi
  801d69:	e8 04 ec ff ff       	call   800972 <memmove>
		sys_cputs(buf, m);
  801d6e:	83 c4 08             	add    $0x8,%esp
  801d71:	53                   	push   %ebx
  801d72:	57                   	push   %edi
  801d73:	e8 a9 ed ff ff       	call   800b21 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801d78:	01 de                	add    %ebx,%esi
  801d7a:	83 c4 10             	add    $0x10,%esp
  801d7d:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d80:	72 cc                	jb     801d4e <devcons_write+0x19>
}
  801d82:	89 f0                	mov    %esi,%eax
  801d84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d87:	5b                   	pop    %ebx
  801d88:	5e                   	pop    %esi
  801d89:	5f                   	pop    %edi
  801d8a:	5d                   	pop    %ebp
  801d8b:	c3                   	ret    

00801d8c <devcons_read>:
{
  801d8c:	55                   	push   %ebp
  801d8d:	89 e5                	mov    %esp,%ebp
  801d8f:	83 ec 08             	sub    $0x8,%esp
  801d92:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801d97:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d9b:	75 07                	jne    801da4 <devcons_read+0x18>
}
  801d9d:	c9                   	leave  
  801d9e:	c3                   	ret    
		sys_yield();
  801d9f:	e8 1a ee ff ff       	call   800bbe <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801da4:	e8 96 ed ff ff       	call   800b3f <sys_cgetc>
  801da9:	85 c0                	test   %eax,%eax
  801dab:	74 f2                	je     801d9f <devcons_read+0x13>
	if (c < 0)
  801dad:	85 c0                	test   %eax,%eax
  801daf:	78 ec                	js     801d9d <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  801db1:	83 f8 04             	cmp    $0x4,%eax
  801db4:	74 0c                	je     801dc2 <devcons_read+0x36>
	*(char*)vbuf = c;
  801db6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801db9:	88 02                	mov    %al,(%edx)
	return 1;
  801dbb:	b8 01 00 00 00       	mov    $0x1,%eax
  801dc0:	eb db                	jmp    801d9d <devcons_read+0x11>
		return 0;
  801dc2:	b8 00 00 00 00       	mov    $0x0,%eax
  801dc7:	eb d4                	jmp    801d9d <devcons_read+0x11>

00801dc9 <cputchar>:
{
  801dc9:	55                   	push   %ebp
  801dca:	89 e5                	mov    %esp,%ebp
  801dcc:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801dcf:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd2:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801dd5:	6a 01                	push   $0x1
  801dd7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dda:	50                   	push   %eax
  801ddb:	e8 41 ed ff ff       	call   800b21 <sys_cputs>
}
  801de0:	83 c4 10             	add    $0x10,%esp
  801de3:	c9                   	leave  
  801de4:	c3                   	ret    

00801de5 <getchar>:
{
  801de5:	55                   	push   %ebp
  801de6:	89 e5                	mov    %esp,%ebp
  801de8:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801deb:	6a 01                	push   $0x1
  801ded:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801df0:	50                   	push   %eax
  801df1:	6a 00                	push   $0x0
  801df3:	e8 c2 f6 ff ff       	call   8014ba <read>
	if (r < 0)
  801df8:	83 c4 10             	add    $0x10,%esp
  801dfb:	85 c0                	test   %eax,%eax
  801dfd:	78 08                	js     801e07 <getchar+0x22>
	if (r < 1)
  801dff:	85 c0                	test   %eax,%eax
  801e01:	7e 06                	jle    801e09 <getchar+0x24>
	return c;
  801e03:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801e07:	c9                   	leave  
  801e08:	c3                   	ret    
		return -E_EOF;
  801e09:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801e0e:	eb f7                	jmp    801e07 <getchar+0x22>

00801e10 <iscons>:
{
  801e10:	55                   	push   %ebp
  801e11:	89 e5                	mov    %esp,%ebp
  801e13:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e16:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e19:	50                   	push   %eax
  801e1a:	ff 75 08             	pushl  0x8(%ebp)
  801e1d:	e8 27 f4 ff ff       	call   801249 <fd_lookup>
  801e22:	83 c4 10             	add    $0x10,%esp
  801e25:	85 c0                	test   %eax,%eax
  801e27:	78 11                	js     801e3a <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801e29:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e2c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e32:	39 10                	cmp    %edx,(%eax)
  801e34:	0f 94 c0             	sete   %al
  801e37:	0f b6 c0             	movzbl %al,%eax
}
  801e3a:	c9                   	leave  
  801e3b:	c3                   	ret    

00801e3c <opencons>:
{
  801e3c:	55                   	push   %ebp
  801e3d:	89 e5                	mov    %esp,%ebp
  801e3f:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801e42:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e45:	50                   	push   %eax
  801e46:	e8 af f3 ff ff       	call   8011fa <fd_alloc>
  801e4b:	83 c4 10             	add    $0x10,%esp
  801e4e:	85 c0                	test   %eax,%eax
  801e50:	78 3a                	js     801e8c <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e52:	83 ec 04             	sub    $0x4,%esp
  801e55:	68 07 04 00 00       	push   $0x407
  801e5a:	ff 75 f4             	pushl  -0xc(%ebp)
  801e5d:	6a 00                	push   $0x0
  801e5f:	e8 79 ed ff ff       	call   800bdd <sys_page_alloc>
  801e64:	83 c4 10             	add    $0x10,%esp
  801e67:	85 c0                	test   %eax,%eax
  801e69:	78 21                	js     801e8c <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801e6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e6e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e74:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e76:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e79:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e80:	83 ec 0c             	sub    $0xc,%esp
  801e83:	50                   	push   %eax
  801e84:	e8 4a f3 ff ff       	call   8011d3 <fd2num>
  801e89:	83 c4 10             	add    $0x10,%esp
}
  801e8c:	c9                   	leave  
  801e8d:	c3                   	ret    

00801e8e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e8e:	55                   	push   %ebp
  801e8f:	89 e5                	mov    %esp,%ebp
  801e91:	56                   	push   %esi
  801e92:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e93:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e96:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801e9c:	e8 fe ec ff ff       	call   800b9f <sys_getenvid>
  801ea1:	83 ec 0c             	sub    $0xc,%esp
  801ea4:	ff 75 0c             	pushl  0xc(%ebp)
  801ea7:	ff 75 08             	pushl  0x8(%ebp)
  801eaa:	56                   	push   %esi
  801eab:	50                   	push   %eax
  801eac:	68 a0 27 80 00       	push   $0x8027a0
  801eb1:	e8 0f e3 ff ff       	call   8001c5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801eb6:	83 c4 18             	add    $0x18,%esp
  801eb9:	53                   	push   %ebx
  801eba:	ff 75 10             	pushl  0x10(%ebp)
  801ebd:	e8 b2 e2 ff ff       	call   800174 <vcprintf>
	cprintf("\n");
  801ec2:	c7 04 24 5f 25 80 00 	movl   $0x80255f,(%esp)
  801ec9:	e8 f7 e2 ff ff       	call   8001c5 <cprintf>
  801ece:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ed1:	cc                   	int3   
  801ed2:	eb fd                	jmp    801ed1 <_panic+0x43>

00801ed4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ed4:	55                   	push   %ebp
  801ed5:	89 e5                	mov    %esp,%ebp
  801ed7:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801eda:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801ee1:	74 0a                	je     801eed <set_pgfault_handler+0x19>
			panic("set_pgfault_handler %e",r);
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
	}
       
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801ee3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee6:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801eeb:	c9                   	leave  
  801eec:	c3                   	ret    
		if((r=sys_page_alloc(thisenv->env_id,(void *)UXSTACKTOP-PGSIZE,PTE_P|PTE_W|PTE_U))<0)
  801eed:	a1 04 40 80 00       	mov    0x804004,%eax
  801ef2:	8b 40 48             	mov    0x48(%eax),%eax
  801ef5:	83 ec 04             	sub    $0x4,%esp
  801ef8:	6a 07                	push   $0x7
  801efa:	68 00 f0 bf ee       	push   $0xeebff000
  801eff:	50                   	push   %eax
  801f00:	e8 d8 ec ff ff       	call   800bdd <sys_page_alloc>
  801f05:	83 c4 10             	add    $0x10,%esp
  801f08:	85 c0                	test   %eax,%eax
  801f0a:	78 1b                	js     801f27 <set_pgfault_handler+0x53>
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
  801f0c:	a1 04 40 80 00       	mov    0x804004,%eax
  801f11:	8b 40 48             	mov    0x48(%eax),%eax
  801f14:	83 ec 08             	sub    $0x8,%esp
  801f17:	68 39 1f 80 00       	push   $0x801f39
  801f1c:	50                   	push   %eax
  801f1d:	e8 06 ee ff ff       	call   800d28 <sys_env_set_pgfault_upcall>
  801f22:	83 c4 10             	add    $0x10,%esp
  801f25:	eb bc                	jmp    801ee3 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler %e",r);
  801f27:	50                   	push   %eax
  801f28:	68 c4 27 80 00       	push   $0x8027c4
  801f2d:	6a 22                	push   $0x22
  801f2f:	68 db 27 80 00       	push   $0x8027db
  801f34:	e8 55 ff ff ff       	call   801e8e <_panic>

00801f39 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f39:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f3a:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f3f:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f41:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 48(%esp), %ebp
  801f44:	8b 6c 24 30          	mov    0x30(%esp),%ebp
        subl $4, %ebp
  801f48:	83 ed 04             	sub    $0x4,%ebp
        movl %ebp, 48(%esp)
  801f4b:	89 6c 24 30          	mov    %ebp,0x30(%esp)
        movl 40(%esp), %eax
  801f4f:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl %eax, (%ebp)
  801f53:	89 45 00             	mov    %eax,0x0(%ebp)
	// Restore the trap-time registers.  After you do this, you
 	// can no longer modify any general-purpose registers.
 	// LAB 4: Your code here.
        addl $8, %esp
  801f56:	83 c4 08             	add    $0x8,%esp
        popal
  801f59:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $4, %esp
  801f5a:	83 c4 04             	add    $0x4,%esp
        popfl
  801f5d:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  801f5e:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  801f5f:	c3                   	ret    

00801f60 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f60:	55                   	push   %ebp
  801f61:	89 e5                	mov    %esp,%ebp
  801f63:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f66:	89 d0                	mov    %edx,%eax
  801f68:	c1 e8 16             	shr    $0x16,%eax
  801f6b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f72:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801f77:	f6 c1 01             	test   $0x1,%cl
  801f7a:	74 1d                	je     801f99 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801f7c:	c1 ea 0c             	shr    $0xc,%edx
  801f7f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f86:	f6 c2 01             	test   $0x1,%dl
  801f89:	74 0e                	je     801f99 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f8b:	c1 ea 0c             	shr    $0xc,%edx
  801f8e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f95:	ef 
  801f96:	0f b7 c0             	movzwl %ax,%eax
}
  801f99:	5d                   	pop    %ebp
  801f9a:	c3                   	ret    
  801f9b:	66 90                	xchg   %ax,%ax
  801f9d:	66 90                	xchg   %ax,%ax
  801f9f:	90                   	nop

00801fa0 <__udivdi3>:
  801fa0:	55                   	push   %ebp
  801fa1:	57                   	push   %edi
  801fa2:	56                   	push   %esi
  801fa3:	53                   	push   %ebx
  801fa4:	83 ec 1c             	sub    $0x1c,%esp
  801fa7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801fab:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801faf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801fb3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801fb7:	85 d2                	test   %edx,%edx
  801fb9:	75 35                	jne    801ff0 <__udivdi3+0x50>
  801fbb:	39 f3                	cmp    %esi,%ebx
  801fbd:	0f 87 bd 00 00 00    	ja     802080 <__udivdi3+0xe0>
  801fc3:	85 db                	test   %ebx,%ebx
  801fc5:	89 d9                	mov    %ebx,%ecx
  801fc7:	75 0b                	jne    801fd4 <__udivdi3+0x34>
  801fc9:	b8 01 00 00 00       	mov    $0x1,%eax
  801fce:	31 d2                	xor    %edx,%edx
  801fd0:	f7 f3                	div    %ebx
  801fd2:	89 c1                	mov    %eax,%ecx
  801fd4:	31 d2                	xor    %edx,%edx
  801fd6:	89 f0                	mov    %esi,%eax
  801fd8:	f7 f1                	div    %ecx
  801fda:	89 c6                	mov    %eax,%esi
  801fdc:	89 e8                	mov    %ebp,%eax
  801fde:	89 f7                	mov    %esi,%edi
  801fe0:	f7 f1                	div    %ecx
  801fe2:	89 fa                	mov    %edi,%edx
  801fe4:	83 c4 1c             	add    $0x1c,%esp
  801fe7:	5b                   	pop    %ebx
  801fe8:	5e                   	pop    %esi
  801fe9:	5f                   	pop    %edi
  801fea:	5d                   	pop    %ebp
  801feb:	c3                   	ret    
  801fec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ff0:	39 f2                	cmp    %esi,%edx
  801ff2:	77 7c                	ja     802070 <__udivdi3+0xd0>
  801ff4:	0f bd fa             	bsr    %edx,%edi
  801ff7:	83 f7 1f             	xor    $0x1f,%edi
  801ffa:	0f 84 98 00 00 00    	je     802098 <__udivdi3+0xf8>
  802000:	89 f9                	mov    %edi,%ecx
  802002:	b8 20 00 00 00       	mov    $0x20,%eax
  802007:	29 f8                	sub    %edi,%eax
  802009:	d3 e2                	shl    %cl,%edx
  80200b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80200f:	89 c1                	mov    %eax,%ecx
  802011:	89 da                	mov    %ebx,%edx
  802013:	d3 ea                	shr    %cl,%edx
  802015:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802019:	09 d1                	or     %edx,%ecx
  80201b:	89 f2                	mov    %esi,%edx
  80201d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802021:	89 f9                	mov    %edi,%ecx
  802023:	d3 e3                	shl    %cl,%ebx
  802025:	89 c1                	mov    %eax,%ecx
  802027:	d3 ea                	shr    %cl,%edx
  802029:	89 f9                	mov    %edi,%ecx
  80202b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80202f:	d3 e6                	shl    %cl,%esi
  802031:	89 eb                	mov    %ebp,%ebx
  802033:	89 c1                	mov    %eax,%ecx
  802035:	d3 eb                	shr    %cl,%ebx
  802037:	09 de                	or     %ebx,%esi
  802039:	89 f0                	mov    %esi,%eax
  80203b:	f7 74 24 08          	divl   0x8(%esp)
  80203f:	89 d6                	mov    %edx,%esi
  802041:	89 c3                	mov    %eax,%ebx
  802043:	f7 64 24 0c          	mull   0xc(%esp)
  802047:	39 d6                	cmp    %edx,%esi
  802049:	72 0c                	jb     802057 <__udivdi3+0xb7>
  80204b:	89 f9                	mov    %edi,%ecx
  80204d:	d3 e5                	shl    %cl,%ebp
  80204f:	39 c5                	cmp    %eax,%ebp
  802051:	73 5d                	jae    8020b0 <__udivdi3+0x110>
  802053:	39 d6                	cmp    %edx,%esi
  802055:	75 59                	jne    8020b0 <__udivdi3+0x110>
  802057:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80205a:	31 ff                	xor    %edi,%edi
  80205c:	89 fa                	mov    %edi,%edx
  80205e:	83 c4 1c             	add    $0x1c,%esp
  802061:	5b                   	pop    %ebx
  802062:	5e                   	pop    %esi
  802063:	5f                   	pop    %edi
  802064:	5d                   	pop    %ebp
  802065:	c3                   	ret    
  802066:	8d 76 00             	lea    0x0(%esi),%esi
  802069:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802070:	31 ff                	xor    %edi,%edi
  802072:	31 c0                	xor    %eax,%eax
  802074:	89 fa                	mov    %edi,%edx
  802076:	83 c4 1c             	add    $0x1c,%esp
  802079:	5b                   	pop    %ebx
  80207a:	5e                   	pop    %esi
  80207b:	5f                   	pop    %edi
  80207c:	5d                   	pop    %ebp
  80207d:	c3                   	ret    
  80207e:	66 90                	xchg   %ax,%ax
  802080:	31 ff                	xor    %edi,%edi
  802082:	89 e8                	mov    %ebp,%eax
  802084:	89 f2                	mov    %esi,%edx
  802086:	f7 f3                	div    %ebx
  802088:	89 fa                	mov    %edi,%edx
  80208a:	83 c4 1c             	add    $0x1c,%esp
  80208d:	5b                   	pop    %ebx
  80208e:	5e                   	pop    %esi
  80208f:	5f                   	pop    %edi
  802090:	5d                   	pop    %ebp
  802091:	c3                   	ret    
  802092:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802098:	39 f2                	cmp    %esi,%edx
  80209a:	72 06                	jb     8020a2 <__udivdi3+0x102>
  80209c:	31 c0                	xor    %eax,%eax
  80209e:	39 eb                	cmp    %ebp,%ebx
  8020a0:	77 d2                	ja     802074 <__udivdi3+0xd4>
  8020a2:	b8 01 00 00 00       	mov    $0x1,%eax
  8020a7:	eb cb                	jmp    802074 <__udivdi3+0xd4>
  8020a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020b0:	89 d8                	mov    %ebx,%eax
  8020b2:	31 ff                	xor    %edi,%edi
  8020b4:	eb be                	jmp    802074 <__udivdi3+0xd4>
  8020b6:	66 90                	xchg   %ax,%ax
  8020b8:	66 90                	xchg   %ax,%ax
  8020ba:	66 90                	xchg   %ax,%ax
  8020bc:	66 90                	xchg   %ax,%ax
  8020be:	66 90                	xchg   %ax,%ax

008020c0 <__umoddi3>:
  8020c0:	55                   	push   %ebp
  8020c1:	57                   	push   %edi
  8020c2:	56                   	push   %esi
  8020c3:	53                   	push   %ebx
  8020c4:	83 ec 1c             	sub    $0x1c,%esp
  8020c7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  8020cb:	8b 74 24 30          	mov    0x30(%esp),%esi
  8020cf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8020d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020d7:	85 ed                	test   %ebp,%ebp
  8020d9:	89 f0                	mov    %esi,%eax
  8020db:	89 da                	mov    %ebx,%edx
  8020dd:	75 19                	jne    8020f8 <__umoddi3+0x38>
  8020df:	39 df                	cmp    %ebx,%edi
  8020e1:	0f 86 b1 00 00 00    	jbe    802198 <__umoddi3+0xd8>
  8020e7:	f7 f7                	div    %edi
  8020e9:	89 d0                	mov    %edx,%eax
  8020eb:	31 d2                	xor    %edx,%edx
  8020ed:	83 c4 1c             	add    $0x1c,%esp
  8020f0:	5b                   	pop    %ebx
  8020f1:	5e                   	pop    %esi
  8020f2:	5f                   	pop    %edi
  8020f3:	5d                   	pop    %ebp
  8020f4:	c3                   	ret    
  8020f5:	8d 76 00             	lea    0x0(%esi),%esi
  8020f8:	39 dd                	cmp    %ebx,%ebp
  8020fa:	77 f1                	ja     8020ed <__umoddi3+0x2d>
  8020fc:	0f bd cd             	bsr    %ebp,%ecx
  8020ff:	83 f1 1f             	xor    $0x1f,%ecx
  802102:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802106:	0f 84 b4 00 00 00    	je     8021c0 <__umoddi3+0x100>
  80210c:	b8 20 00 00 00       	mov    $0x20,%eax
  802111:	89 c2                	mov    %eax,%edx
  802113:	8b 44 24 04          	mov    0x4(%esp),%eax
  802117:	29 c2                	sub    %eax,%edx
  802119:	89 c1                	mov    %eax,%ecx
  80211b:	89 f8                	mov    %edi,%eax
  80211d:	d3 e5                	shl    %cl,%ebp
  80211f:	89 d1                	mov    %edx,%ecx
  802121:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802125:	d3 e8                	shr    %cl,%eax
  802127:	09 c5                	or     %eax,%ebp
  802129:	8b 44 24 04          	mov    0x4(%esp),%eax
  80212d:	89 c1                	mov    %eax,%ecx
  80212f:	d3 e7                	shl    %cl,%edi
  802131:	89 d1                	mov    %edx,%ecx
  802133:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802137:	89 df                	mov    %ebx,%edi
  802139:	d3 ef                	shr    %cl,%edi
  80213b:	89 c1                	mov    %eax,%ecx
  80213d:	89 f0                	mov    %esi,%eax
  80213f:	d3 e3                	shl    %cl,%ebx
  802141:	89 d1                	mov    %edx,%ecx
  802143:	89 fa                	mov    %edi,%edx
  802145:	d3 e8                	shr    %cl,%eax
  802147:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80214c:	09 d8                	or     %ebx,%eax
  80214e:	f7 f5                	div    %ebp
  802150:	d3 e6                	shl    %cl,%esi
  802152:	89 d1                	mov    %edx,%ecx
  802154:	f7 64 24 08          	mull   0x8(%esp)
  802158:	39 d1                	cmp    %edx,%ecx
  80215a:	89 c3                	mov    %eax,%ebx
  80215c:	89 d7                	mov    %edx,%edi
  80215e:	72 06                	jb     802166 <__umoddi3+0xa6>
  802160:	75 0e                	jne    802170 <__umoddi3+0xb0>
  802162:	39 c6                	cmp    %eax,%esi
  802164:	73 0a                	jae    802170 <__umoddi3+0xb0>
  802166:	2b 44 24 08          	sub    0x8(%esp),%eax
  80216a:	19 ea                	sbb    %ebp,%edx
  80216c:	89 d7                	mov    %edx,%edi
  80216e:	89 c3                	mov    %eax,%ebx
  802170:	89 ca                	mov    %ecx,%edx
  802172:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  802177:	29 de                	sub    %ebx,%esi
  802179:	19 fa                	sbb    %edi,%edx
  80217b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80217f:	89 d0                	mov    %edx,%eax
  802181:	d3 e0                	shl    %cl,%eax
  802183:	89 d9                	mov    %ebx,%ecx
  802185:	d3 ee                	shr    %cl,%esi
  802187:	d3 ea                	shr    %cl,%edx
  802189:	09 f0                	or     %esi,%eax
  80218b:	83 c4 1c             	add    $0x1c,%esp
  80218e:	5b                   	pop    %ebx
  80218f:	5e                   	pop    %esi
  802190:	5f                   	pop    %edi
  802191:	5d                   	pop    %ebp
  802192:	c3                   	ret    
  802193:	90                   	nop
  802194:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802198:	85 ff                	test   %edi,%edi
  80219a:	89 f9                	mov    %edi,%ecx
  80219c:	75 0b                	jne    8021a9 <__umoddi3+0xe9>
  80219e:	b8 01 00 00 00       	mov    $0x1,%eax
  8021a3:	31 d2                	xor    %edx,%edx
  8021a5:	f7 f7                	div    %edi
  8021a7:	89 c1                	mov    %eax,%ecx
  8021a9:	89 d8                	mov    %ebx,%eax
  8021ab:	31 d2                	xor    %edx,%edx
  8021ad:	f7 f1                	div    %ecx
  8021af:	89 f0                	mov    %esi,%eax
  8021b1:	f7 f1                	div    %ecx
  8021b3:	e9 31 ff ff ff       	jmp    8020e9 <__umoddi3+0x29>
  8021b8:	90                   	nop
  8021b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021c0:	39 dd                	cmp    %ebx,%ebp
  8021c2:	72 08                	jb     8021cc <__umoddi3+0x10c>
  8021c4:	39 f7                	cmp    %esi,%edi
  8021c6:	0f 87 21 ff ff ff    	ja     8020ed <__umoddi3+0x2d>
  8021cc:	89 da                	mov    %ebx,%edx
  8021ce:	89 f0                	mov    %esi,%eax
  8021d0:	29 f8                	sub    %edi,%eax
  8021d2:	19 ea                	sbb    %ebp,%edx
  8021d4:	e9 14 ff ff ff       	jmp    8020ed <__umoddi3+0x2d>
