
obj/user/forktree.debug:     file format elf32-i386


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
  80002c:	e8 b2 00 00 00       	call   8000e3 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
  80003a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80003d:	e8 70 0b 00 00       	call   800bb2 <sys_getenvid>
  800042:	83 ec 04             	sub    $0x4,%esp
  800045:	53                   	push   %ebx
  800046:	50                   	push   %eax
  800047:	68 00 22 80 00       	push   $0x802200
  80004c:	e8 87 01 00 00       	call   8001d8 <cprintf>

	forkchild(cur, '0');
  800051:	83 c4 08             	add    $0x8,%esp
  800054:	6a 30                	push   $0x30
  800056:	53                   	push   %ebx
  800057:	e8 13 00 00 00       	call   80006f <forkchild>
	forkchild(cur, '1');
  80005c:	83 c4 08             	add    $0x8,%esp
  80005f:	6a 31                	push   $0x31
  800061:	53                   	push   %ebx
  800062:	e8 08 00 00 00       	call   80006f <forkchild>
}
  800067:	83 c4 10             	add    $0x10,%esp
  80006a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80006d:	c9                   	leave  
  80006e:	c3                   	ret    

0080006f <forkchild>:
{
  80006f:	55                   	push   %ebp
  800070:	89 e5                	mov    %esp,%ebp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	83 ec 1c             	sub    $0x1c,%esp
  800077:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80007a:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (strlen(cur) >= DEPTH)
  80007d:	53                   	push   %ebx
  80007e:	e8 3d 07 00 00       	call   8007c0 <strlen>
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	83 f8 02             	cmp    $0x2,%eax
  800089:	7e 07                	jle    800092 <forkchild+0x23>
}
  80008b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008e:	5b                   	pop    %ebx
  80008f:	5e                   	pop    %esi
  800090:	5d                   	pop    %ebp
  800091:	c3                   	ret    
	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  800092:	83 ec 0c             	sub    $0xc,%esp
  800095:	89 f0                	mov    %esi,%eax
  800097:	0f be f0             	movsbl %al,%esi
  80009a:	56                   	push   %esi
  80009b:	53                   	push   %ebx
  80009c:	68 11 22 80 00       	push   $0x802211
  8000a1:	6a 04                	push   $0x4
  8000a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000a6:	50                   	push   %eax
  8000a7:	e8 fa 06 00 00       	call   8007a6 <snprintf>
	if (fork() == 0) {
  8000ac:	83 c4 20             	add    $0x20,%esp
  8000af:	e8 21 0e 00 00       	call   800ed5 <fork>
  8000b4:	85 c0                	test   %eax,%eax
  8000b6:	75 d3                	jne    80008b <forkchild+0x1c>
		forktree(nxt);
  8000b8:	83 ec 0c             	sub    $0xc,%esp
  8000bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000be:	50                   	push   %eax
  8000bf:	e8 6f ff ff ff       	call   800033 <forktree>
		exit();
  8000c4:	e8 60 00 00 00       	call   800129 <exit>
  8000c9:	83 c4 10             	add    $0x10,%esp
  8000cc:	eb bd                	jmp    80008b <forkchild+0x1c>

008000ce <umain>:

void
umain(int argc, char **argv)
{
  8000ce:	55                   	push   %ebp
  8000cf:	89 e5                	mov    %esp,%ebp
  8000d1:	83 ec 14             	sub    $0x14,%esp
	forktree("");
  8000d4:	68 10 22 80 00       	push   $0x802210
  8000d9:	e8 55 ff ff ff       	call   800033 <forktree>
}
  8000de:	83 c4 10             	add    $0x10,%esp
  8000e1:	c9                   	leave  
  8000e2:	c3                   	ret    

008000e3 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	56                   	push   %esi
  8000e7:	53                   	push   %ebx
  8000e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000eb:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000ee:	e8 bf 0a 00 00       	call   800bb2 <sys_getenvid>
  8000f3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000fb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800100:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800105:	85 db                	test   %ebx,%ebx
  800107:	7e 07                	jle    800110 <libmain+0x2d>
		binaryname = argv[0];
  800109:	8b 06                	mov    (%esi),%eax
  80010b:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800110:	83 ec 08             	sub    $0x8,%esp
  800113:	56                   	push   %esi
  800114:	53                   	push   %ebx
  800115:	e8 b4 ff ff ff       	call   8000ce <umain>

	// exit gracefully
	exit();
  80011a:	e8 0a 00 00 00       	call   800129 <exit>
}
  80011f:	83 c4 10             	add    $0x10,%esp
  800122:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800125:	5b                   	pop    %ebx
  800126:	5e                   	pop    %esi
  800127:	5d                   	pop    %ebp
  800128:	c3                   	ret    

00800129 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800129:	55                   	push   %ebp
  80012a:	89 e5                	mov    %esp,%ebp
  80012c:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80012f:	e8 84 11 00 00       	call   8012b8 <close_all>
	sys_env_destroy(0);
  800134:	83 ec 0c             	sub    $0xc,%esp
  800137:	6a 00                	push   $0x0
  800139:	e8 33 0a 00 00       	call   800b71 <sys_env_destroy>
}
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	c9                   	leave  
  800142:	c3                   	ret    

00800143 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	53                   	push   %ebx
  800147:	83 ec 04             	sub    $0x4,%esp
  80014a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80014d:	8b 13                	mov    (%ebx),%edx
  80014f:	8d 42 01             	lea    0x1(%edx),%eax
  800152:	89 03                	mov    %eax,(%ebx)
  800154:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800157:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80015b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800160:	74 09                	je     80016b <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800162:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800166:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800169:	c9                   	leave  
  80016a:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80016b:	83 ec 08             	sub    $0x8,%esp
  80016e:	68 ff 00 00 00       	push   $0xff
  800173:	8d 43 08             	lea    0x8(%ebx),%eax
  800176:	50                   	push   %eax
  800177:	e8 b8 09 00 00       	call   800b34 <sys_cputs>
		b->idx = 0;
  80017c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800182:	83 c4 10             	add    $0x10,%esp
  800185:	eb db                	jmp    800162 <putch+0x1f>

00800187 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800187:	55                   	push   %ebp
  800188:	89 e5                	mov    %esp,%ebp
  80018a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800190:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800197:	00 00 00 
	b.cnt = 0;
  80019a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001a1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001a4:	ff 75 0c             	pushl  0xc(%ebp)
  8001a7:	ff 75 08             	pushl  0x8(%ebp)
  8001aa:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001b0:	50                   	push   %eax
  8001b1:	68 43 01 80 00       	push   $0x800143
  8001b6:	e8 1a 01 00 00       	call   8002d5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001bb:	83 c4 08             	add    $0x8,%esp
  8001be:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001c4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ca:	50                   	push   %eax
  8001cb:	e8 64 09 00 00       	call   800b34 <sys_cputs>

	return b.cnt;
}
  8001d0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001d6:	c9                   	leave  
  8001d7:	c3                   	ret    

008001d8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001de:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001e1:	50                   	push   %eax
  8001e2:	ff 75 08             	pushl  0x8(%ebp)
  8001e5:	e8 9d ff ff ff       	call   800187 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ea:	c9                   	leave  
  8001eb:	c3                   	ret    

008001ec <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001ec:	55                   	push   %ebp
  8001ed:	89 e5                	mov    %esp,%ebp
  8001ef:	57                   	push   %edi
  8001f0:	56                   	push   %esi
  8001f1:	53                   	push   %ebx
  8001f2:	83 ec 1c             	sub    $0x1c,%esp
  8001f5:	89 c7                	mov    %eax,%edi
  8001f7:	89 d6                	mov    %edx,%esi
  8001f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8001fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001ff:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800202:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800205:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800208:	bb 00 00 00 00       	mov    $0x0,%ebx
  80020d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800210:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800213:	39 d3                	cmp    %edx,%ebx
  800215:	72 05                	jb     80021c <printnum+0x30>
  800217:	39 45 10             	cmp    %eax,0x10(%ebp)
  80021a:	77 7a                	ja     800296 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80021c:	83 ec 0c             	sub    $0xc,%esp
  80021f:	ff 75 18             	pushl  0x18(%ebp)
  800222:	8b 45 14             	mov    0x14(%ebp),%eax
  800225:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800228:	53                   	push   %ebx
  800229:	ff 75 10             	pushl  0x10(%ebp)
  80022c:	83 ec 08             	sub    $0x8,%esp
  80022f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800232:	ff 75 e0             	pushl  -0x20(%ebp)
  800235:	ff 75 dc             	pushl  -0x24(%ebp)
  800238:	ff 75 d8             	pushl  -0x28(%ebp)
  80023b:	e8 70 1d 00 00       	call   801fb0 <__udivdi3>
  800240:	83 c4 18             	add    $0x18,%esp
  800243:	52                   	push   %edx
  800244:	50                   	push   %eax
  800245:	89 f2                	mov    %esi,%edx
  800247:	89 f8                	mov    %edi,%eax
  800249:	e8 9e ff ff ff       	call   8001ec <printnum>
  80024e:	83 c4 20             	add    $0x20,%esp
  800251:	eb 13                	jmp    800266 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800253:	83 ec 08             	sub    $0x8,%esp
  800256:	56                   	push   %esi
  800257:	ff 75 18             	pushl  0x18(%ebp)
  80025a:	ff d7                	call   *%edi
  80025c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80025f:	83 eb 01             	sub    $0x1,%ebx
  800262:	85 db                	test   %ebx,%ebx
  800264:	7f ed                	jg     800253 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800266:	83 ec 08             	sub    $0x8,%esp
  800269:	56                   	push   %esi
  80026a:	83 ec 04             	sub    $0x4,%esp
  80026d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800270:	ff 75 e0             	pushl  -0x20(%ebp)
  800273:	ff 75 dc             	pushl  -0x24(%ebp)
  800276:	ff 75 d8             	pushl  -0x28(%ebp)
  800279:	e8 52 1e 00 00       	call   8020d0 <__umoddi3>
  80027e:	83 c4 14             	add    $0x14,%esp
  800281:	0f be 80 20 22 80 00 	movsbl 0x802220(%eax),%eax
  800288:	50                   	push   %eax
  800289:	ff d7                	call   *%edi
}
  80028b:	83 c4 10             	add    $0x10,%esp
  80028e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800291:	5b                   	pop    %ebx
  800292:	5e                   	pop    %esi
  800293:	5f                   	pop    %edi
  800294:	5d                   	pop    %ebp
  800295:	c3                   	ret    
  800296:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800299:	eb c4                	jmp    80025f <printnum+0x73>

0080029b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80029b:	55                   	push   %ebp
  80029c:	89 e5                	mov    %esp,%ebp
  80029e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002a1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002a5:	8b 10                	mov    (%eax),%edx
  8002a7:	3b 50 04             	cmp    0x4(%eax),%edx
  8002aa:	73 0a                	jae    8002b6 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002ac:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002af:	89 08                	mov    %ecx,(%eax)
  8002b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b4:	88 02                	mov    %al,(%edx)
}
  8002b6:	5d                   	pop    %ebp
  8002b7:	c3                   	ret    

008002b8 <printfmt>:
{
  8002b8:	55                   	push   %ebp
  8002b9:	89 e5                	mov    %esp,%ebp
  8002bb:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002be:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002c1:	50                   	push   %eax
  8002c2:	ff 75 10             	pushl  0x10(%ebp)
  8002c5:	ff 75 0c             	pushl  0xc(%ebp)
  8002c8:	ff 75 08             	pushl  0x8(%ebp)
  8002cb:	e8 05 00 00 00       	call   8002d5 <vprintfmt>
}
  8002d0:	83 c4 10             	add    $0x10,%esp
  8002d3:	c9                   	leave  
  8002d4:	c3                   	ret    

008002d5 <vprintfmt>:
{
  8002d5:	55                   	push   %ebp
  8002d6:	89 e5                	mov    %esp,%ebp
  8002d8:	57                   	push   %edi
  8002d9:	56                   	push   %esi
  8002da:	53                   	push   %ebx
  8002db:	83 ec 2c             	sub    $0x2c,%esp
  8002de:	8b 75 08             	mov    0x8(%ebp),%esi
  8002e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002e4:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002e7:	e9 c1 03 00 00       	jmp    8006ad <vprintfmt+0x3d8>
		padc = ' ';
  8002ec:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8002f0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8002f7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8002fe:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800305:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80030a:	8d 47 01             	lea    0x1(%edi),%eax
  80030d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800310:	0f b6 17             	movzbl (%edi),%edx
  800313:	8d 42 dd             	lea    -0x23(%edx),%eax
  800316:	3c 55                	cmp    $0x55,%al
  800318:	0f 87 12 04 00 00    	ja     800730 <vprintfmt+0x45b>
  80031e:	0f b6 c0             	movzbl %al,%eax
  800321:	ff 24 85 60 23 80 00 	jmp    *0x802360(,%eax,4)
  800328:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80032b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80032f:	eb d9                	jmp    80030a <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800331:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800334:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800338:	eb d0                	jmp    80030a <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80033a:	0f b6 d2             	movzbl %dl,%edx
  80033d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800340:	b8 00 00 00 00       	mov    $0x0,%eax
  800345:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800348:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80034b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80034f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800352:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800355:	83 f9 09             	cmp    $0x9,%ecx
  800358:	77 55                	ja     8003af <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  80035a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80035d:	eb e9                	jmp    800348 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  80035f:	8b 45 14             	mov    0x14(%ebp),%eax
  800362:	8b 00                	mov    (%eax),%eax
  800364:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800367:	8b 45 14             	mov    0x14(%ebp),%eax
  80036a:	8d 40 04             	lea    0x4(%eax),%eax
  80036d:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800370:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800373:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800377:	79 91                	jns    80030a <vprintfmt+0x35>
				width = precision, precision = -1;
  800379:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80037c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80037f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800386:	eb 82                	jmp    80030a <vprintfmt+0x35>
  800388:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80038b:	85 c0                	test   %eax,%eax
  80038d:	ba 00 00 00 00       	mov    $0x0,%edx
  800392:	0f 49 d0             	cmovns %eax,%edx
  800395:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800398:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80039b:	e9 6a ff ff ff       	jmp    80030a <vprintfmt+0x35>
  8003a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003a3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003aa:	e9 5b ff ff ff       	jmp    80030a <vprintfmt+0x35>
  8003af:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003b2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003b5:	eb bc                	jmp    800373 <vprintfmt+0x9e>
			lflag++;
  8003b7:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003bd:	e9 48 ff ff ff       	jmp    80030a <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8003c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c5:	8d 78 04             	lea    0x4(%eax),%edi
  8003c8:	83 ec 08             	sub    $0x8,%esp
  8003cb:	53                   	push   %ebx
  8003cc:	ff 30                	pushl  (%eax)
  8003ce:	ff d6                	call   *%esi
			break;
  8003d0:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003d3:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003d6:	e9 cf 02 00 00       	jmp    8006aa <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  8003db:	8b 45 14             	mov    0x14(%ebp),%eax
  8003de:	8d 78 04             	lea    0x4(%eax),%edi
  8003e1:	8b 00                	mov    (%eax),%eax
  8003e3:	99                   	cltd   
  8003e4:	31 d0                	xor    %edx,%eax
  8003e6:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003e8:	83 f8 0f             	cmp    $0xf,%eax
  8003eb:	7f 23                	jg     800410 <vprintfmt+0x13b>
  8003ed:	8b 14 85 c0 24 80 00 	mov    0x8024c0(,%eax,4),%edx
  8003f4:	85 d2                	test   %edx,%edx
  8003f6:	74 18                	je     800410 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8003f8:	52                   	push   %edx
  8003f9:	68 31 27 80 00       	push   $0x802731
  8003fe:	53                   	push   %ebx
  8003ff:	56                   	push   %esi
  800400:	e8 b3 fe ff ff       	call   8002b8 <printfmt>
  800405:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800408:	89 7d 14             	mov    %edi,0x14(%ebp)
  80040b:	e9 9a 02 00 00       	jmp    8006aa <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  800410:	50                   	push   %eax
  800411:	68 38 22 80 00       	push   $0x802238
  800416:	53                   	push   %ebx
  800417:	56                   	push   %esi
  800418:	e8 9b fe ff ff       	call   8002b8 <printfmt>
  80041d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800420:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800423:	e9 82 02 00 00       	jmp    8006aa <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  800428:	8b 45 14             	mov    0x14(%ebp),%eax
  80042b:	83 c0 04             	add    $0x4,%eax
  80042e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800431:	8b 45 14             	mov    0x14(%ebp),%eax
  800434:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800436:	85 ff                	test   %edi,%edi
  800438:	b8 31 22 80 00       	mov    $0x802231,%eax
  80043d:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800440:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800444:	0f 8e bd 00 00 00    	jle    800507 <vprintfmt+0x232>
  80044a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80044e:	75 0e                	jne    80045e <vprintfmt+0x189>
  800450:	89 75 08             	mov    %esi,0x8(%ebp)
  800453:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800456:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800459:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80045c:	eb 6d                	jmp    8004cb <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  80045e:	83 ec 08             	sub    $0x8,%esp
  800461:	ff 75 d0             	pushl  -0x30(%ebp)
  800464:	57                   	push   %edi
  800465:	e8 6e 03 00 00       	call   8007d8 <strnlen>
  80046a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80046d:	29 c1                	sub    %eax,%ecx
  80046f:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800472:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800475:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800479:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80047c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80047f:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800481:	eb 0f                	jmp    800492 <vprintfmt+0x1bd>
					putch(padc, putdat);
  800483:	83 ec 08             	sub    $0x8,%esp
  800486:	53                   	push   %ebx
  800487:	ff 75 e0             	pushl  -0x20(%ebp)
  80048a:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80048c:	83 ef 01             	sub    $0x1,%edi
  80048f:	83 c4 10             	add    $0x10,%esp
  800492:	85 ff                	test   %edi,%edi
  800494:	7f ed                	jg     800483 <vprintfmt+0x1ae>
  800496:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800499:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80049c:	85 c9                	test   %ecx,%ecx
  80049e:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a3:	0f 49 c1             	cmovns %ecx,%eax
  8004a6:	29 c1                	sub    %eax,%ecx
  8004a8:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ab:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ae:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b1:	89 cb                	mov    %ecx,%ebx
  8004b3:	eb 16                	jmp    8004cb <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8004b5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004b9:	75 31                	jne    8004ec <vprintfmt+0x217>
					putch(ch, putdat);
  8004bb:	83 ec 08             	sub    $0x8,%esp
  8004be:	ff 75 0c             	pushl  0xc(%ebp)
  8004c1:	50                   	push   %eax
  8004c2:	ff 55 08             	call   *0x8(%ebp)
  8004c5:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004c8:	83 eb 01             	sub    $0x1,%ebx
  8004cb:	83 c7 01             	add    $0x1,%edi
  8004ce:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8004d2:	0f be c2             	movsbl %dl,%eax
  8004d5:	85 c0                	test   %eax,%eax
  8004d7:	74 59                	je     800532 <vprintfmt+0x25d>
  8004d9:	85 f6                	test   %esi,%esi
  8004db:	78 d8                	js     8004b5 <vprintfmt+0x1e0>
  8004dd:	83 ee 01             	sub    $0x1,%esi
  8004e0:	79 d3                	jns    8004b5 <vprintfmt+0x1e0>
  8004e2:	89 df                	mov    %ebx,%edi
  8004e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004ea:	eb 37                	jmp    800523 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004ec:	0f be d2             	movsbl %dl,%edx
  8004ef:	83 ea 20             	sub    $0x20,%edx
  8004f2:	83 fa 5e             	cmp    $0x5e,%edx
  8004f5:	76 c4                	jbe    8004bb <vprintfmt+0x1e6>
					putch('?', putdat);
  8004f7:	83 ec 08             	sub    $0x8,%esp
  8004fa:	ff 75 0c             	pushl  0xc(%ebp)
  8004fd:	6a 3f                	push   $0x3f
  8004ff:	ff 55 08             	call   *0x8(%ebp)
  800502:	83 c4 10             	add    $0x10,%esp
  800505:	eb c1                	jmp    8004c8 <vprintfmt+0x1f3>
  800507:	89 75 08             	mov    %esi,0x8(%ebp)
  80050a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80050d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800510:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800513:	eb b6                	jmp    8004cb <vprintfmt+0x1f6>
				putch(' ', putdat);
  800515:	83 ec 08             	sub    $0x8,%esp
  800518:	53                   	push   %ebx
  800519:	6a 20                	push   $0x20
  80051b:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80051d:	83 ef 01             	sub    $0x1,%edi
  800520:	83 c4 10             	add    $0x10,%esp
  800523:	85 ff                	test   %edi,%edi
  800525:	7f ee                	jg     800515 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800527:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80052a:	89 45 14             	mov    %eax,0x14(%ebp)
  80052d:	e9 78 01 00 00       	jmp    8006aa <vprintfmt+0x3d5>
  800532:	89 df                	mov    %ebx,%edi
  800534:	8b 75 08             	mov    0x8(%ebp),%esi
  800537:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80053a:	eb e7                	jmp    800523 <vprintfmt+0x24e>
	if (lflag >= 2)
  80053c:	83 f9 01             	cmp    $0x1,%ecx
  80053f:	7e 3f                	jle    800580 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800541:	8b 45 14             	mov    0x14(%ebp),%eax
  800544:	8b 50 04             	mov    0x4(%eax),%edx
  800547:	8b 00                	mov    (%eax),%eax
  800549:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80054c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80054f:	8b 45 14             	mov    0x14(%ebp),%eax
  800552:	8d 40 08             	lea    0x8(%eax),%eax
  800555:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800558:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80055c:	79 5c                	jns    8005ba <vprintfmt+0x2e5>
				putch('-', putdat);
  80055e:	83 ec 08             	sub    $0x8,%esp
  800561:	53                   	push   %ebx
  800562:	6a 2d                	push   $0x2d
  800564:	ff d6                	call   *%esi
				num = -(long long) num;
  800566:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800569:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80056c:	f7 da                	neg    %edx
  80056e:	83 d1 00             	adc    $0x0,%ecx
  800571:	f7 d9                	neg    %ecx
  800573:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800576:	b8 0a 00 00 00       	mov    $0xa,%eax
  80057b:	e9 10 01 00 00       	jmp    800690 <vprintfmt+0x3bb>
	else if (lflag)
  800580:	85 c9                	test   %ecx,%ecx
  800582:	75 1b                	jne    80059f <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800584:	8b 45 14             	mov    0x14(%ebp),%eax
  800587:	8b 00                	mov    (%eax),%eax
  800589:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058c:	89 c1                	mov    %eax,%ecx
  80058e:	c1 f9 1f             	sar    $0x1f,%ecx
  800591:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800594:	8b 45 14             	mov    0x14(%ebp),%eax
  800597:	8d 40 04             	lea    0x4(%eax),%eax
  80059a:	89 45 14             	mov    %eax,0x14(%ebp)
  80059d:	eb b9                	jmp    800558 <vprintfmt+0x283>
		return va_arg(*ap, long);
  80059f:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a2:	8b 00                	mov    (%eax),%eax
  8005a4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a7:	89 c1                	mov    %eax,%ecx
  8005a9:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ac:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005af:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b2:	8d 40 04             	lea    0x4(%eax),%eax
  8005b5:	89 45 14             	mov    %eax,0x14(%ebp)
  8005b8:	eb 9e                	jmp    800558 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8005ba:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005bd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005c0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005c5:	e9 c6 00 00 00       	jmp    800690 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8005ca:	83 f9 01             	cmp    $0x1,%ecx
  8005cd:	7e 18                	jle    8005e7 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8005cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d2:	8b 10                	mov    (%eax),%edx
  8005d4:	8b 48 04             	mov    0x4(%eax),%ecx
  8005d7:	8d 40 08             	lea    0x8(%eax),%eax
  8005da:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005dd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e2:	e9 a9 00 00 00       	jmp    800690 <vprintfmt+0x3bb>
	else if (lflag)
  8005e7:	85 c9                	test   %ecx,%ecx
  8005e9:	75 1a                	jne    800605 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  8005eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ee:	8b 10                	mov    (%eax),%edx
  8005f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f5:	8d 40 04             	lea    0x4(%eax),%eax
  8005f8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005fb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800600:	e9 8b 00 00 00       	jmp    800690 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800605:	8b 45 14             	mov    0x14(%ebp),%eax
  800608:	8b 10                	mov    (%eax),%edx
  80060a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80060f:	8d 40 04             	lea    0x4(%eax),%eax
  800612:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800615:	b8 0a 00 00 00       	mov    $0xa,%eax
  80061a:	eb 74                	jmp    800690 <vprintfmt+0x3bb>
	if (lflag >= 2)
  80061c:	83 f9 01             	cmp    $0x1,%ecx
  80061f:	7e 15                	jle    800636 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  800621:	8b 45 14             	mov    0x14(%ebp),%eax
  800624:	8b 10                	mov    (%eax),%edx
  800626:	8b 48 04             	mov    0x4(%eax),%ecx
  800629:	8d 40 08             	lea    0x8(%eax),%eax
  80062c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80062f:	b8 08 00 00 00       	mov    $0x8,%eax
  800634:	eb 5a                	jmp    800690 <vprintfmt+0x3bb>
	else if (lflag)
  800636:	85 c9                	test   %ecx,%ecx
  800638:	75 17                	jne    800651 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  80063a:	8b 45 14             	mov    0x14(%ebp),%eax
  80063d:	8b 10                	mov    (%eax),%edx
  80063f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800644:	8d 40 04             	lea    0x4(%eax),%eax
  800647:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80064a:	b8 08 00 00 00       	mov    $0x8,%eax
  80064f:	eb 3f                	jmp    800690 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800651:	8b 45 14             	mov    0x14(%ebp),%eax
  800654:	8b 10                	mov    (%eax),%edx
  800656:	b9 00 00 00 00       	mov    $0x0,%ecx
  80065b:	8d 40 04             	lea    0x4(%eax),%eax
  80065e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800661:	b8 08 00 00 00       	mov    $0x8,%eax
  800666:	eb 28                	jmp    800690 <vprintfmt+0x3bb>
			putch('0', putdat);
  800668:	83 ec 08             	sub    $0x8,%esp
  80066b:	53                   	push   %ebx
  80066c:	6a 30                	push   $0x30
  80066e:	ff d6                	call   *%esi
			putch('x', putdat);
  800670:	83 c4 08             	add    $0x8,%esp
  800673:	53                   	push   %ebx
  800674:	6a 78                	push   $0x78
  800676:	ff d6                	call   *%esi
			num = (unsigned long long)
  800678:	8b 45 14             	mov    0x14(%ebp),%eax
  80067b:	8b 10                	mov    (%eax),%edx
  80067d:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800682:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800685:	8d 40 04             	lea    0x4(%eax),%eax
  800688:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80068b:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800690:	83 ec 0c             	sub    $0xc,%esp
  800693:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800697:	57                   	push   %edi
  800698:	ff 75 e0             	pushl  -0x20(%ebp)
  80069b:	50                   	push   %eax
  80069c:	51                   	push   %ecx
  80069d:	52                   	push   %edx
  80069e:	89 da                	mov    %ebx,%edx
  8006a0:	89 f0                	mov    %esi,%eax
  8006a2:	e8 45 fb ff ff       	call   8001ec <printnum>
			break;
  8006a7:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8006aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006ad:	83 c7 01             	add    $0x1,%edi
  8006b0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006b4:	83 f8 25             	cmp    $0x25,%eax
  8006b7:	0f 84 2f fc ff ff    	je     8002ec <vprintfmt+0x17>
			if (ch == '\0')
  8006bd:	85 c0                	test   %eax,%eax
  8006bf:	0f 84 8b 00 00 00    	je     800750 <vprintfmt+0x47b>
			putch(ch, putdat);
  8006c5:	83 ec 08             	sub    $0x8,%esp
  8006c8:	53                   	push   %ebx
  8006c9:	50                   	push   %eax
  8006ca:	ff d6                	call   *%esi
  8006cc:	83 c4 10             	add    $0x10,%esp
  8006cf:	eb dc                	jmp    8006ad <vprintfmt+0x3d8>
	if (lflag >= 2)
  8006d1:	83 f9 01             	cmp    $0x1,%ecx
  8006d4:	7e 15                	jle    8006eb <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  8006d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d9:	8b 10                	mov    (%eax),%edx
  8006db:	8b 48 04             	mov    0x4(%eax),%ecx
  8006de:	8d 40 08             	lea    0x8(%eax),%eax
  8006e1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006e4:	b8 10 00 00 00       	mov    $0x10,%eax
  8006e9:	eb a5                	jmp    800690 <vprintfmt+0x3bb>
	else if (lflag)
  8006eb:	85 c9                	test   %ecx,%ecx
  8006ed:	75 17                	jne    800706 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  8006ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f2:	8b 10                	mov    (%eax),%edx
  8006f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f9:	8d 40 04             	lea    0x4(%eax),%eax
  8006fc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ff:	b8 10 00 00 00       	mov    $0x10,%eax
  800704:	eb 8a                	jmp    800690 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800706:	8b 45 14             	mov    0x14(%ebp),%eax
  800709:	8b 10                	mov    (%eax),%edx
  80070b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800710:	8d 40 04             	lea    0x4(%eax),%eax
  800713:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800716:	b8 10 00 00 00       	mov    $0x10,%eax
  80071b:	e9 70 ff ff ff       	jmp    800690 <vprintfmt+0x3bb>
			putch(ch, putdat);
  800720:	83 ec 08             	sub    $0x8,%esp
  800723:	53                   	push   %ebx
  800724:	6a 25                	push   $0x25
  800726:	ff d6                	call   *%esi
			break;
  800728:	83 c4 10             	add    $0x10,%esp
  80072b:	e9 7a ff ff ff       	jmp    8006aa <vprintfmt+0x3d5>
			putch('%', putdat);
  800730:	83 ec 08             	sub    $0x8,%esp
  800733:	53                   	push   %ebx
  800734:	6a 25                	push   $0x25
  800736:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800738:	83 c4 10             	add    $0x10,%esp
  80073b:	89 f8                	mov    %edi,%eax
  80073d:	eb 03                	jmp    800742 <vprintfmt+0x46d>
  80073f:	83 e8 01             	sub    $0x1,%eax
  800742:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800746:	75 f7                	jne    80073f <vprintfmt+0x46a>
  800748:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80074b:	e9 5a ff ff ff       	jmp    8006aa <vprintfmt+0x3d5>
}
  800750:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800753:	5b                   	pop    %ebx
  800754:	5e                   	pop    %esi
  800755:	5f                   	pop    %edi
  800756:	5d                   	pop    %ebp
  800757:	c3                   	ret    

00800758 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	83 ec 18             	sub    $0x18,%esp
  80075e:	8b 45 08             	mov    0x8(%ebp),%eax
  800761:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800764:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800767:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80076b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80076e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800775:	85 c0                	test   %eax,%eax
  800777:	74 26                	je     80079f <vsnprintf+0x47>
  800779:	85 d2                	test   %edx,%edx
  80077b:	7e 22                	jle    80079f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80077d:	ff 75 14             	pushl  0x14(%ebp)
  800780:	ff 75 10             	pushl  0x10(%ebp)
  800783:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800786:	50                   	push   %eax
  800787:	68 9b 02 80 00       	push   $0x80029b
  80078c:	e8 44 fb ff ff       	call   8002d5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800791:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800794:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800797:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80079a:	83 c4 10             	add    $0x10,%esp
}
  80079d:	c9                   	leave  
  80079e:	c3                   	ret    
		return -E_INVAL;
  80079f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007a4:	eb f7                	jmp    80079d <vsnprintf+0x45>

008007a6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007a6:	55                   	push   %ebp
  8007a7:	89 e5                	mov    %esp,%ebp
  8007a9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ac:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007af:	50                   	push   %eax
  8007b0:	ff 75 10             	pushl  0x10(%ebp)
  8007b3:	ff 75 0c             	pushl  0xc(%ebp)
  8007b6:	ff 75 08             	pushl  0x8(%ebp)
  8007b9:	e8 9a ff ff ff       	call   800758 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007be:	c9                   	leave  
  8007bf:	c3                   	ret    

008007c0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007cb:	eb 03                	jmp    8007d0 <strlen+0x10>
		n++;
  8007cd:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007d0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007d4:	75 f7                	jne    8007cd <strlen+0xd>
	return n;
}
  8007d6:	5d                   	pop    %ebp
  8007d7:	c3                   	ret    

008007d8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007de:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e6:	eb 03                	jmp    8007eb <strnlen+0x13>
		n++;
  8007e8:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007eb:	39 d0                	cmp    %edx,%eax
  8007ed:	74 06                	je     8007f5 <strnlen+0x1d>
  8007ef:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007f3:	75 f3                	jne    8007e8 <strnlen+0x10>
	return n;
}
  8007f5:	5d                   	pop    %ebp
  8007f6:	c3                   	ret    

008007f7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007f7:	55                   	push   %ebp
  8007f8:	89 e5                	mov    %esp,%ebp
  8007fa:	53                   	push   %ebx
  8007fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800801:	89 c2                	mov    %eax,%edx
  800803:	83 c1 01             	add    $0x1,%ecx
  800806:	83 c2 01             	add    $0x1,%edx
  800809:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80080d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800810:	84 db                	test   %bl,%bl
  800812:	75 ef                	jne    800803 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800814:	5b                   	pop    %ebx
  800815:	5d                   	pop    %ebp
  800816:	c3                   	ret    

00800817 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800817:	55                   	push   %ebp
  800818:	89 e5                	mov    %esp,%ebp
  80081a:	53                   	push   %ebx
  80081b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80081e:	53                   	push   %ebx
  80081f:	e8 9c ff ff ff       	call   8007c0 <strlen>
  800824:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800827:	ff 75 0c             	pushl  0xc(%ebp)
  80082a:	01 d8                	add    %ebx,%eax
  80082c:	50                   	push   %eax
  80082d:	e8 c5 ff ff ff       	call   8007f7 <strcpy>
	return dst;
}
  800832:	89 d8                	mov    %ebx,%eax
  800834:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800837:	c9                   	leave  
  800838:	c3                   	ret    

00800839 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800839:	55                   	push   %ebp
  80083a:	89 e5                	mov    %esp,%ebp
  80083c:	56                   	push   %esi
  80083d:	53                   	push   %ebx
  80083e:	8b 75 08             	mov    0x8(%ebp),%esi
  800841:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800844:	89 f3                	mov    %esi,%ebx
  800846:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800849:	89 f2                	mov    %esi,%edx
  80084b:	eb 0f                	jmp    80085c <strncpy+0x23>
		*dst++ = *src;
  80084d:	83 c2 01             	add    $0x1,%edx
  800850:	0f b6 01             	movzbl (%ecx),%eax
  800853:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800856:	80 39 01             	cmpb   $0x1,(%ecx)
  800859:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80085c:	39 da                	cmp    %ebx,%edx
  80085e:	75 ed                	jne    80084d <strncpy+0x14>
	}
	return ret;
}
  800860:	89 f0                	mov    %esi,%eax
  800862:	5b                   	pop    %ebx
  800863:	5e                   	pop    %esi
  800864:	5d                   	pop    %ebp
  800865:	c3                   	ret    

00800866 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800866:	55                   	push   %ebp
  800867:	89 e5                	mov    %esp,%ebp
  800869:	56                   	push   %esi
  80086a:	53                   	push   %ebx
  80086b:	8b 75 08             	mov    0x8(%ebp),%esi
  80086e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800871:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800874:	89 f0                	mov    %esi,%eax
  800876:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80087a:	85 c9                	test   %ecx,%ecx
  80087c:	75 0b                	jne    800889 <strlcpy+0x23>
  80087e:	eb 17                	jmp    800897 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800880:	83 c2 01             	add    $0x1,%edx
  800883:	83 c0 01             	add    $0x1,%eax
  800886:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800889:	39 d8                	cmp    %ebx,%eax
  80088b:	74 07                	je     800894 <strlcpy+0x2e>
  80088d:	0f b6 0a             	movzbl (%edx),%ecx
  800890:	84 c9                	test   %cl,%cl
  800892:	75 ec                	jne    800880 <strlcpy+0x1a>
		*dst = '\0';
  800894:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800897:	29 f0                	sub    %esi,%eax
}
  800899:	5b                   	pop    %ebx
  80089a:	5e                   	pop    %esi
  80089b:	5d                   	pop    %ebp
  80089c:	c3                   	ret    

0080089d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80089d:	55                   	push   %ebp
  80089e:	89 e5                	mov    %esp,%ebp
  8008a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008a6:	eb 06                	jmp    8008ae <strcmp+0x11>
		p++, q++;
  8008a8:	83 c1 01             	add    $0x1,%ecx
  8008ab:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008ae:	0f b6 01             	movzbl (%ecx),%eax
  8008b1:	84 c0                	test   %al,%al
  8008b3:	74 04                	je     8008b9 <strcmp+0x1c>
  8008b5:	3a 02                	cmp    (%edx),%al
  8008b7:	74 ef                	je     8008a8 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b9:	0f b6 c0             	movzbl %al,%eax
  8008bc:	0f b6 12             	movzbl (%edx),%edx
  8008bf:	29 d0                	sub    %edx,%eax
}
  8008c1:	5d                   	pop    %ebp
  8008c2:	c3                   	ret    

008008c3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	53                   	push   %ebx
  8008c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008cd:	89 c3                	mov    %eax,%ebx
  8008cf:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008d2:	eb 06                	jmp    8008da <strncmp+0x17>
		n--, p++, q++;
  8008d4:	83 c0 01             	add    $0x1,%eax
  8008d7:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008da:	39 d8                	cmp    %ebx,%eax
  8008dc:	74 16                	je     8008f4 <strncmp+0x31>
  8008de:	0f b6 08             	movzbl (%eax),%ecx
  8008e1:	84 c9                	test   %cl,%cl
  8008e3:	74 04                	je     8008e9 <strncmp+0x26>
  8008e5:	3a 0a                	cmp    (%edx),%cl
  8008e7:	74 eb                	je     8008d4 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e9:	0f b6 00             	movzbl (%eax),%eax
  8008ec:	0f b6 12             	movzbl (%edx),%edx
  8008ef:	29 d0                	sub    %edx,%eax
}
  8008f1:	5b                   	pop    %ebx
  8008f2:	5d                   	pop    %ebp
  8008f3:	c3                   	ret    
		return 0;
  8008f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f9:	eb f6                	jmp    8008f1 <strncmp+0x2e>

008008fb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008fb:	55                   	push   %ebp
  8008fc:	89 e5                	mov    %esp,%ebp
  8008fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800901:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800905:	0f b6 10             	movzbl (%eax),%edx
  800908:	84 d2                	test   %dl,%dl
  80090a:	74 09                	je     800915 <strchr+0x1a>
		if (*s == c)
  80090c:	38 ca                	cmp    %cl,%dl
  80090e:	74 0a                	je     80091a <strchr+0x1f>
	for (; *s; s++)
  800910:	83 c0 01             	add    $0x1,%eax
  800913:	eb f0                	jmp    800905 <strchr+0xa>
			return (char *) s;
	return 0;
  800915:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80091a:	5d                   	pop    %ebp
  80091b:	c3                   	ret    

0080091c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	8b 45 08             	mov    0x8(%ebp),%eax
  800922:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800926:	eb 03                	jmp    80092b <strfind+0xf>
  800928:	83 c0 01             	add    $0x1,%eax
  80092b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80092e:	38 ca                	cmp    %cl,%dl
  800930:	74 04                	je     800936 <strfind+0x1a>
  800932:	84 d2                	test   %dl,%dl
  800934:	75 f2                	jne    800928 <strfind+0xc>
			break;
	return (char *) s;
}
  800936:	5d                   	pop    %ebp
  800937:	c3                   	ret    

00800938 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
  80093b:	57                   	push   %edi
  80093c:	56                   	push   %esi
  80093d:	53                   	push   %ebx
  80093e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800941:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800944:	85 c9                	test   %ecx,%ecx
  800946:	74 13                	je     80095b <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800948:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80094e:	75 05                	jne    800955 <memset+0x1d>
  800950:	f6 c1 03             	test   $0x3,%cl
  800953:	74 0d                	je     800962 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800955:	8b 45 0c             	mov    0xc(%ebp),%eax
  800958:	fc                   	cld    
  800959:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80095b:	89 f8                	mov    %edi,%eax
  80095d:	5b                   	pop    %ebx
  80095e:	5e                   	pop    %esi
  80095f:	5f                   	pop    %edi
  800960:	5d                   	pop    %ebp
  800961:	c3                   	ret    
		c &= 0xFF;
  800962:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800966:	89 d3                	mov    %edx,%ebx
  800968:	c1 e3 08             	shl    $0x8,%ebx
  80096b:	89 d0                	mov    %edx,%eax
  80096d:	c1 e0 18             	shl    $0x18,%eax
  800970:	89 d6                	mov    %edx,%esi
  800972:	c1 e6 10             	shl    $0x10,%esi
  800975:	09 f0                	or     %esi,%eax
  800977:	09 c2                	or     %eax,%edx
  800979:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  80097b:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80097e:	89 d0                	mov    %edx,%eax
  800980:	fc                   	cld    
  800981:	f3 ab                	rep stos %eax,%es:(%edi)
  800983:	eb d6                	jmp    80095b <memset+0x23>

00800985 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800985:	55                   	push   %ebp
  800986:	89 e5                	mov    %esp,%ebp
  800988:	57                   	push   %edi
  800989:	56                   	push   %esi
  80098a:	8b 45 08             	mov    0x8(%ebp),%eax
  80098d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800990:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800993:	39 c6                	cmp    %eax,%esi
  800995:	73 35                	jae    8009cc <memmove+0x47>
  800997:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80099a:	39 c2                	cmp    %eax,%edx
  80099c:	76 2e                	jbe    8009cc <memmove+0x47>
		s += n;
		d += n;
  80099e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a1:	89 d6                	mov    %edx,%esi
  8009a3:	09 fe                	or     %edi,%esi
  8009a5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ab:	74 0c                	je     8009b9 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009ad:	83 ef 01             	sub    $0x1,%edi
  8009b0:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009b3:	fd                   	std    
  8009b4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009b6:	fc                   	cld    
  8009b7:	eb 21                	jmp    8009da <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b9:	f6 c1 03             	test   $0x3,%cl
  8009bc:	75 ef                	jne    8009ad <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009be:	83 ef 04             	sub    $0x4,%edi
  8009c1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009c4:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009c7:	fd                   	std    
  8009c8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ca:	eb ea                	jmp    8009b6 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009cc:	89 f2                	mov    %esi,%edx
  8009ce:	09 c2                	or     %eax,%edx
  8009d0:	f6 c2 03             	test   $0x3,%dl
  8009d3:	74 09                	je     8009de <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009d5:	89 c7                	mov    %eax,%edi
  8009d7:	fc                   	cld    
  8009d8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009da:	5e                   	pop    %esi
  8009db:	5f                   	pop    %edi
  8009dc:	5d                   	pop    %ebp
  8009dd:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009de:	f6 c1 03             	test   $0x3,%cl
  8009e1:	75 f2                	jne    8009d5 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009e3:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009e6:	89 c7                	mov    %eax,%edi
  8009e8:	fc                   	cld    
  8009e9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009eb:	eb ed                	jmp    8009da <memmove+0x55>

008009ed <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ed:	55                   	push   %ebp
  8009ee:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009f0:	ff 75 10             	pushl  0x10(%ebp)
  8009f3:	ff 75 0c             	pushl  0xc(%ebp)
  8009f6:	ff 75 08             	pushl  0x8(%ebp)
  8009f9:	e8 87 ff ff ff       	call   800985 <memmove>
}
  8009fe:	c9                   	leave  
  8009ff:	c3                   	ret    

00800a00 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	56                   	push   %esi
  800a04:	53                   	push   %ebx
  800a05:	8b 45 08             	mov    0x8(%ebp),%eax
  800a08:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a0b:	89 c6                	mov    %eax,%esi
  800a0d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a10:	39 f0                	cmp    %esi,%eax
  800a12:	74 1c                	je     800a30 <memcmp+0x30>
		if (*s1 != *s2)
  800a14:	0f b6 08             	movzbl (%eax),%ecx
  800a17:	0f b6 1a             	movzbl (%edx),%ebx
  800a1a:	38 d9                	cmp    %bl,%cl
  800a1c:	75 08                	jne    800a26 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a1e:	83 c0 01             	add    $0x1,%eax
  800a21:	83 c2 01             	add    $0x1,%edx
  800a24:	eb ea                	jmp    800a10 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a26:	0f b6 c1             	movzbl %cl,%eax
  800a29:	0f b6 db             	movzbl %bl,%ebx
  800a2c:	29 d8                	sub    %ebx,%eax
  800a2e:	eb 05                	jmp    800a35 <memcmp+0x35>
	}

	return 0;
  800a30:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a35:	5b                   	pop    %ebx
  800a36:	5e                   	pop    %esi
  800a37:	5d                   	pop    %ebp
  800a38:	c3                   	ret    

00800a39 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a39:	55                   	push   %ebp
  800a3a:	89 e5                	mov    %esp,%ebp
  800a3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a42:	89 c2                	mov    %eax,%edx
  800a44:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a47:	39 d0                	cmp    %edx,%eax
  800a49:	73 09                	jae    800a54 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a4b:	38 08                	cmp    %cl,(%eax)
  800a4d:	74 05                	je     800a54 <memfind+0x1b>
	for (; s < ends; s++)
  800a4f:	83 c0 01             	add    $0x1,%eax
  800a52:	eb f3                	jmp    800a47 <memfind+0xe>
			break;
	return (void *) s;
}
  800a54:	5d                   	pop    %ebp
  800a55:	c3                   	ret    

00800a56 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a56:	55                   	push   %ebp
  800a57:	89 e5                	mov    %esp,%ebp
  800a59:	57                   	push   %edi
  800a5a:	56                   	push   %esi
  800a5b:	53                   	push   %ebx
  800a5c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a62:	eb 03                	jmp    800a67 <strtol+0x11>
		s++;
  800a64:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a67:	0f b6 01             	movzbl (%ecx),%eax
  800a6a:	3c 20                	cmp    $0x20,%al
  800a6c:	74 f6                	je     800a64 <strtol+0xe>
  800a6e:	3c 09                	cmp    $0x9,%al
  800a70:	74 f2                	je     800a64 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a72:	3c 2b                	cmp    $0x2b,%al
  800a74:	74 2e                	je     800aa4 <strtol+0x4e>
	int neg = 0;
  800a76:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a7b:	3c 2d                	cmp    $0x2d,%al
  800a7d:	74 2f                	je     800aae <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a7f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a85:	75 05                	jne    800a8c <strtol+0x36>
  800a87:	80 39 30             	cmpb   $0x30,(%ecx)
  800a8a:	74 2c                	je     800ab8 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a8c:	85 db                	test   %ebx,%ebx
  800a8e:	75 0a                	jne    800a9a <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a90:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a95:	80 39 30             	cmpb   $0x30,(%ecx)
  800a98:	74 28                	je     800ac2 <strtol+0x6c>
		base = 10;
  800a9a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800aa2:	eb 50                	jmp    800af4 <strtol+0x9e>
		s++;
  800aa4:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800aa7:	bf 00 00 00 00       	mov    $0x0,%edi
  800aac:	eb d1                	jmp    800a7f <strtol+0x29>
		s++, neg = 1;
  800aae:	83 c1 01             	add    $0x1,%ecx
  800ab1:	bf 01 00 00 00       	mov    $0x1,%edi
  800ab6:	eb c7                	jmp    800a7f <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800abc:	74 0e                	je     800acc <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800abe:	85 db                	test   %ebx,%ebx
  800ac0:	75 d8                	jne    800a9a <strtol+0x44>
		s++, base = 8;
  800ac2:	83 c1 01             	add    $0x1,%ecx
  800ac5:	bb 08 00 00 00       	mov    $0x8,%ebx
  800aca:	eb ce                	jmp    800a9a <strtol+0x44>
		s += 2, base = 16;
  800acc:	83 c1 02             	add    $0x2,%ecx
  800acf:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ad4:	eb c4                	jmp    800a9a <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800ad6:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ad9:	89 f3                	mov    %esi,%ebx
  800adb:	80 fb 19             	cmp    $0x19,%bl
  800ade:	77 29                	ja     800b09 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800ae0:	0f be d2             	movsbl %dl,%edx
  800ae3:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ae6:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ae9:	7d 30                	jge    800b1b <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800aeb:	83 c1 01             	add    $0x1,%ecx
  800aee:	0f af 45 10          	imul   0x10(%ebp),%eax
  800af2:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800af4:	0f b6 11             	movzbl (%ecx),%edx
  800af7:	8d 72 d0             	lea    -0x30(%edx),%esi
  800afa:	89 f3                	mov    %esi,%ebx
  800afc:	80 fb 09             	cmp    $0x9,%bl
  800aff:	77 d5                	ja     800ad6 <strtol+0x80>
			dig = *s - '0';
  800b01:	0f be d2             	movsbl %dl,%edx
  800b04:	83 ea 30             	sub    $0x30,%edx
  800b07:	eb dd                	jmp    800ae6 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800b09:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b0c:	89 f3                	mov    %esi,%ebx
  800b0e:	80 fb 19             	cmp    $0x19,%bl
  800b11:	77 08                	ja     800b1b <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b13:	0f be d2             	movsbl %dl,%edx
  800b16:	83 ea 37             	sub    $0x37,%edx
  800b19:	eb cb                	jmp    800ae6 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b1b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b1f:	74 05                	je     800b26 <strtol+0xd0>
		*endptr = (char *) s;
  800b21:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b24:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b26:	89 c2                	mov    %eax,%edx
  800b28:	f7 da                	neg    %edx
  800b2a:	85 ff                	test   %edi,%edi
  800b2c:	0f 45 c2             	cmovne %edx,%eax
}
  800b2f:	5b                   	pop    %ebx
  800b30:	5e                   	pop    %esi
  800b31:	5f                   	pop    %edi
  800b32:	5d                   	pop    %ebp
  800b33:	c3                   	ret    

00800b34 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	57                   	push   %edi
  800b38:	56                   	push   %esi
  800b39:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b45:	89 c3                	mov    %eax,%ebx
  800b47:	89 c7                	mov    %eax,%edi
  800b49:	89 c6                	mov    %eax,%esi
  800b4b:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b4d:	5b                   	pop    %ebx
  800b4e:	5e                   	pop    %esi
  800b4f:	5f                   	pop    %edi
  800b50:	5d                   	pop    %ebp
  800b51:	c3                   	ret    

00800b52 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b52:	55                   	push   %ebp
  800b53:	89 e5                	mov    %esp,%ebp
  800b55:	57                   	push   %edi
  800b56:	56                   	push   %esi
  800b57:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b58:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b62:	89 d1                	mov    %edx,%ecx
  800b64:	89 d3                	mov    %edx,%ebx
  800b66:	89 d7                	mov    %edx,%edi
  800b68:	89 d6                	mov    %edx,%esi
  800b6a:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b6c:	5b                   	pop    %ebx
  800b6d:	5e                   	pop    %esi
  800b6e:	5f                   	pop    %edi
  800b6f:	5d                   	pop    %ebp
  800b70:	c3                   	ret    

00800b71 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	57                   	push   %edi
  800b75:	56                   	push   %esi
  800b76:	53                   	push   %ebx
  800b77:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b7a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b82:	b8 03 00 00 00       	mov    $0x3,%eax
  800b87:	89 cb                	mov    %ecx,%ebx
  800b89:	89 cf                	mov    %ecx,%edi
  800b8b:	89 ce                	mov    %ecx,%esi
  800b8d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b8f:	85 c0                	test   %eax,%eax
  800b91:	7f 08                	jg     800b9b <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b96:	5b                   	pop    %ebx
  800b97:	5e                   	pop    %esi
  800b98:	5f                   	pop    %edi
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9b:	83 ec 0c             	sub    $0xc,%esp
  800b9e:	50                   	push   %eax
  800b9f:	6a 03                	push   $0x3
  800ba1:	68 1f 25 80 00       	push   $0x80251f
  800ba6:	6a 23                	push   $0x23
  800ba8:	68 3c 25 80 00       	push   $0x80253c
  800bad:	e8 eb 11 00 00       	call   801d9d <_panic>

00800bb2 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bb2:	55                   	push   %ebp
  800bb3:	89 e5                	mov    %esp,%ebp
  800bb5:	57                   	push   %edi
  800bb6:	56                   	push   %esi
  800bb7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bb8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bbd:	b8 02 00 00 00       	mov    $0x2,%eax
  800bc2:	89 d1                	mov    %edx,%ecx
  800bc4:	89 d3                	mov    %edx,%ebx
  800bc6:	89 d7                	mov    %edx,%edi
  800bc8:	89 d6                	mov    %edx,%esi
  800bca:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bcc:	5b                   	pop    %ebx
  800bcd:	5e                   	pop    %esi
  800bce:	5f                   	pop    %edi
  800bcf:	5d                   	pop    %ebp
  800bd0:	c3                   	ret    

00800bd1 <sys_yield>:

void
sys_yield(void)
{
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	57                   	push   %edi
  800bd5:	56                   	push   %esi
  800bd6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bd7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bdc:	b8 0b 00 00 00       	mov    $0xb,%eax
  800be1:	89 d1                	mov    %edx,%ecx
  800be3:	89 d3                	mov    %edx,%ebx
  800be5:	89 d7                	mov    %edx,%edi
  800be7:	89 d6                	mov    %edx,%esi
  800be9:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800beb:	5b                   	pop    %ebx
  800bec:	5e                   	pop    %esi
  800bed:	5f                   	pop    %edi
  800bee:	5d                   	pop    %ebp
  800bef:	c3                   	ret    

00800bf0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bf0:	55                   	push   %ebp
  800bf1:	89 e5                	mov    %esp,%ebp
  800bf3:	57                   	push   %edi
  800bf4:	56                   	push   %esi
  800bf5:	53                   	push   %ebx
  800bf6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bf9:	be 00 00 00 00       	mov    $0x0,%esi
  800bfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800c01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c04:	b8 04 00 00 00       	mov    $0x4,%eax
  800c09:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c0c:	89 f7                	mov    %esi,%edi
  800c0e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c10:	85 c0                	test   %eax,%eax
  800c12:	7f 08                	jg     800c1c <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
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
  800c20:	6a 04                	push   $0x4
  800c22:	68 1f 25 80 00       	push   $0x80251f
  800c27:	6a 23                	push   $0x23
  800c29:	68 3c 25 80 00       	push   $0x80253c
  800c2e:	e8 6a 11 00 00       	call   801d9d <_panic>

00800c33 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	57                   	push   %edi
  800c37:	56                   	push   %esi
  800c38:	53                   	push   %ebx
  800c39:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c42:	b8 05 00 00 00       	mov    $0x5,%eax
  800c47:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c4a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c4d:	8b 75 18             	mov    0x18(%ebp),%esi
  800c50:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c52:	85 c0                	test   %eax,%eax
  800c54:	7f 08                	jg     800c5e <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
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
  800c62:	6a 05                	push   $0x5
  800c64:	68 1f 25 80 00       	push   $0x80251f
  800c69:	6a 23                	push   $0x23
  800c6b:	68 3c 25 80 00       	push   $0x80253c
  800c70:	e8 28 11 00 00       	call   801d9d <_panic>

00800c75 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800c89:	b8 06 00 00 00       	mov    $0x6,%eax
  800c8e:	89 df                	mov    %ebx,%edi
  800c90:	89 de                	mov    %ebx,%esi
  800c92:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c94:	85 c0                	test   %eax,%eax
  800c96:	7f 08                	jg     800ca0 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
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
  800ca4:	6a 06                	push   $0x6
  800ca6:	68 1f 25 80 00       	push   $0x80251f
  800cab:	6a 23                	push   $0x23
  800cad:	68 3c 25 80 00       	push   $0x80253c
  800cb2:	e8 e6 10 00 00       	call   801d9d <_panic>

00800cb7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800ccb:	b8 08 00 00 00       	mov    $0x8,%eax
  800cd0:	89 df                	mov    %ebx,%edi
  800cd2:	89 de                	mov    %ebx,%esi
  800cd4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cd6:	85 c0                	test   %eax,%eax
  800cd8:	7f 08                	jg     800ce2 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
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
  800ce6:	6a 08                	push   $0x8
  800ce8:	68 1f 25 80 00       	push   $0x80251f
  800ced:	6a 23                	push   $0x23
  800cef:	68 3c 25 80 00       	push   $0x80253c
  800cf4:	e8 a4 10 00 00       	call   801d9d <_panic>

00800cf9 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800d0d:	b8 09 00 00 00       	mov    $0x9,%eax
  800d12:	89 df                	mov    %ebx,%edi
  800d14:	89 de                	mov    %ebx,%esi
  800d16:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d18:	85 c0                	test   %eax,%eax
  800d1a:	7f 08                	jg     800d24 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
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
  800d28:	6a 09                	push   $0x9
  800d2a:	68 1f 25 80 00       	push   $0x80251f
  800d2f:	6a 23                	push   $0x23
  800d31:	68 3c 25 80 00       	push   $0x80253c
  800d36:	e8 62 10 00 00       	call   801d9d <_panic>

00800d3b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	57                   	push   %edi
  800d3f:	56                   	push   %esi
  800d40:	53                   	push   %ebx
  800d41:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d44:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d49:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d54:	89 df                	mov    %ebx,%edi
  800d56:	89 de                	mov    %ebx,%esi
  800d58:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d5a:	85 c0                	test   %eax,%eax
  800d5c:	7f 08                	jg     800d66 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d61:	5b                   	pop    %ebx
  800d62:	5e                   	pop    %esi
  800d63:	5f                   	pop    %edi
  800d64:	5d                   	pop    %ebp
  800d65:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d66:	83 ec 0c             	sub    $0xc,%esp
  800d69:	50                   	push   %eax
  800d6a:	6a 0a                	push   $0xa
  800d6c:	68 1f 25 80 00       	push   $0x80251f
  800d71:	6a 23                	push   $0x23
  800d73:	68 3c 25 80 00       	push   $0x80253c
  800d78:	e8 20 10 00 00       	call   801d9d <_panic>

00800d7d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d7d:	55                   	push   %ebp
  800d7e:	89 e5                	mov    %esp,%ebp
  800d80:	57                   	push   %edi
  800d81:	56                   	push   %esi
  800d82:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d83:	8b 55 08             	mov    0x8(%ebp),%edx
  800d86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d89:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d8e:	be 00 00 00 00       	mov    $0x0,%esi
  800d93:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d96:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d99:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d9b:	5b                   	pop    %ebx
  800d9c:	5e                   	pop    %esi
  800d9d:	5f                   	pop    %edi
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    

00800da0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	57                   	push   %edi
  800da4:	56                   	push   %esi
  800da5:	53                   	push   %ebx
  800da6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800da9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dae:	8b 55 08             	mov    0x8(%ebp),%edx
  800db1:	b8 0d 00 00 00       	mov    $0xd,%eax
  800db6:	89 cb                	mov    %ecx,%ebx
  800db8:	89 cf                	mov    %ecx,%edi
  800dba:	89 ce                	mov    %ecx,%esi
  800dbc:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dbe:	85 c0                	test   %eax,%eax
  800dc0:	7f 08                	jg     800dca <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc5:	5b                   	pop    %ebx
  800dc6:	5e                   	pop    %esi
  800dc7:	5f                   	pop    %edi
  800dc8:	5d                   	pop    %ebp
  800dc9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dca:	83 ec 0c             	sub    $0xc,%esp
  800dcd:	50                   	push   %eax
  800dce:	6a 0d                	push   $0xd
  800dd0:	68 1f 25 80 00       	push   $0x80251f
  800dd5:	6a 23                	push   $0x23
  800dd7:	68 3c 25 80 00       	push   $0x80253c
  800ddc:	e8 bc 0f 00 00       	call   801d9d <_panic>

00800de1 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800de1:	55                   	push   %ebp
  800de2:	89 e5                	mov    %esp,%ebp
  800de4:	56                   	push   %esi
  800de5:	53                   	push   %ebx
  800de6:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800de9:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if((err&FEC_WR)==0 || (uvpt[PGNUM(addr)]&(PTE_W|PTE_COW))==0){
  800deb:	8b 40 04             	mov    0x4(%eax),%eax
  800dee:	83 e0 02             	and    $0x2,%eax
  800df1:	0f 84 82 00 00 00    	je     800e79 <pgfault+0x98>
  800df7:	89 da                	mov    %ebx,%edx
  800df9:	c1 ea 0c             	shr    $0xc,%edx
  800dfc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e03:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800e09:	74 6e                	je     800e79 <pgfault+0x98>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        envid_t envid = sys_getenvid();
  800e0b:	e8 a2 fd ff ff       	call   800bb2 <sys_getenvid>
  800e10:	89 c6                	mov    %eax,%esi
	r = sys_page_alloc(envid,(void *)PFTEMP,PTE_P|PTE_W|PTE_U);
  800e12:	83 ec 04             	sub    $0x4,%esp
  800e15:	6a 07                	push   $0x7
  800e17:	68 00 f0 7f 00       	push   $0x7ff000
  800e1c:	50                   	push   %eax
  800e1d:	e8 ce fd ff ff       	call   800bf0 <sys_page_alloc>
	if(r<0) panic("pgfault:page allocation failed %e",r);
  800e22:	83 c4 10             	add    $0x10,%esp
  800e25:	85 c0                	test   %eax,%eax
  800e27:	78 72                	js     800e9b <pgfault+0xba>

	addr = ROUNDDOWN(addr,PGSIZE);
  800e29:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy((void *)PFTEMP,(const void *)addr,PGSIZE);
  800e2f:	83 ec 04             	sub    $0x4,%esp
  800e32:	68 00 10 00 00       	push   $0x1000
  800e37:	53                   	push   %ebx
  800e38:	68 00 f0 7f 00       	push   $0x7ff000
  800e3d:	e8 ab fb ff ff       	call   8009ed <memcpy>

	if(sys_page_map(envid,(void *)PFTEMP, envid,addr,PTE_P|PTE_W|PTE_U)<0)
  800e42:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e49:	53                   	push   %ebx
  800e4a:	56                   	push   %esi
  800e4b:	68 00 f0 7f 00       	push   $0x7ff000
  800e50:	56                   	push   %esi
  800e51:	e8 dd fd ff ff       	call   800c33 <sys_page_map>
  800e56:	83 c4 20             	add    $0x20,%esp
  800e59:	85 c0                	test   %eax,%eax
  800e5b:	78 50                	js     800ead <pgfault+0xcc>
		panic("pgfault:page map failed\n");
	if(sys_page_unmap(envid,(void *)PFTEMP)<0)
  800e5d:	83 ec 08             	sub    $0x8,%esp
  800e60:	68 00 f0 7f 00       	push   $0x7ff000
  800e65:	56                   	push   %esi
  800e66:	e8 0a fe ff ff       	call   800c75 <sys_page_unmap>
  800e6b:	83 c4 10             	add    $0x10,%esp
  800e6e:	85 c0                	test   %eax,%eax
  800e70:	78 4f                	js     800ec1 <pgfault+0xe0>
		panic("pgfault: page upmap failed\n");
       //	panic("pgfault not implemented");
}
  800e72:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e75:	5b                   	pop    %ebx
  800e76:	5e                   	pop    %esi
  800e77:	5d                   	pop    %ebp
  800e78:	c3                   	ret    
		cprintf("Where is the error %d\n",err&FEC_WR);
  800e79:	83 ec 08             	sub    $0x8,%esp
  800e7c:	50                   	push   %eax
  800e7d:	68 4a 25 80 00       	push   $0x80254a
  800e82:	e8 51 f3 ff ff       	call   8001d8 <cprintf>
		panic("pgfault:invalid user trap");
  800e87:	83 c4 0c             	add    $0xc,%esp
  800e8a:	68 61 25 80 00       	push   $0x802561
  800e8f:	6a 1e                	push   $0x1e
  800e91:	68 7b 25 80 00       	push   $0x80257b
  800e96:	e8 02 0f 00 00       	call   801d9d <_panic>
	if(r<0) panic("pgfault:page allocation failed %e",r);
  800e9b:	50                   	push   %eax
  800e9c:	68 68 26 80 00       	push   $0x802668
  800ea1:	6a 29                	push   $0x29
  800ea3:	68 7b 25 80 00       	push   $0x80257b
  800ea8:	e8 f0 0e 00 00       	call   801d9d <_panic>
		panic("pgfault:page map failed\n");
  800ead:	83 ec 04             	sub    $0x4,%esp
  800eb0:	68 86 25 80 00       	push   $0x802586
  800eb5:	6a 2f                	push   $0x2f
  800eb7:	68 7b 25 80 00       	push   $0x80257b
  800ebc:	e8 dc 0e 00 00       	call   801d9d <_panic>
		panic("pgfault: page upmap failed\n");
  800ec1:	83 ec 04             	sub    $0x4,%esp
  800ec4:	68 9f 25 80 00       	push   $0x80259f
  800ec9:	6a 31                	push   $0x31
  800ecb:	68 7b 25 80 00       	push   $0x80257b
  800ed0:	e8 c8 0e 00 00       	call   801d9d <_panic>

00800ed5 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ed5:	55                   	push   %ebp
  800ed6:	89 e5                	mov    %esp,%ebp
  800ed8:	57                   	push   %edi
  800ed9:	56                   	push   %esi
  800eda:	53                   	push   %ebx
  800edb:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	set_pgfault_handler(pgfault);
  800ede:	68 e1 0d 80 00       	push   $0x800de1
  800ee3:	e8 fb 0e 00 00       	call   801de3 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ee8:	b8 07 00 00 00       	mov    $0x7,%eax
  800eed:	cd 30                	int    $0x30
  800eef:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800ef2:	89 45 e0             	mov    %eax,-0x20(%ebp)
       
	envid_t envid = sys_exofork();
	uintptr_t addr;
  
	if(envid<0) panic("sys_exofork failed\n");
  800ef5:	83 c4 10             	add    $0x10,%esp
  800ef8:	85 c0                	test   %eax,%eax
  800efa:	78 27                	js     800f23 <fork+0x4e>
	if(envid==0){
	  thisenv = &envs[ENVX(sys_getenvid())];
	  return 0;
	}

	for(addr=(uintptr_t)UTEXT; addr<USTACKTOP;addr+=PGSIZE){
  800efc:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if(envid==0){
  800f01:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800f05:	75 5e                	jne    800f65 <fork+0x90>
	  thisenv = &envs[ENVX(sys_getenvid())];
  800f07:	e8 a6 fc ff ff       	call   800bb2 <sys_getenvid>
  800f0c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f11:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f14:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f19:	a3 04 40 80 00       	mov    %eax,0x804004
	  return 0;
  800f1e:	e9 fc 00 00 00       	jmp    80101f <fork+0x14a>
	if(envid<0) panic("sys_exofork failed\n");
  800f23:	83 ec 04             	sub    $0x4,%esp
  800f26:	68 bb 25 80 00       	push   $0x8025bb
  800f2b:	6a 77                	push   $0x77
  800f2d:	68 7b 25 80 00       	push   $0x80257b
  800f32:	e8 66 0e 00 00       	call   801d9d <_panic>
          if((r=sys_page_map(parent_envid,va,envid,va,uvpt[pn]&PTE_SYSCALL))<0)
  800f37:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f3e:	83 ec 0c             	sub    $0xc,%esp
  800f41:	25 07 0e 00 00       	and    $0xe07,%eax
  800f46:	50                   	push   %eax
  800f47:	57                   	push   %edi
  800f48:	ff 75 e0             	pushl  -0x20(%ebp)
  800f4b:	57                   	push   %edi
  800f4c:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f4f:	e8 df fc ff ff       	call   800c33 <sys_page_map>
  800f54:	83 c4 20             	add    $0x20,%esp
	for(addr=(uintptr_t)UTEXT; addr<USTACKTOP;addr+=PGSIZE){
  800f57:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f5d:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800f63:	74 76                	je     800fdb <fork+0x106>
	   if((uvpd[PDX(addr)]&PTE_P) && uvpt[PGNUM(addr)] & PTE_P)
  800f65:	89 d8                	mov    %ebx,%eax
  800f67:	c1 e8 16             	shr    $0x16,%eax
  800f6a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f71:	a8 01                	test   $0x1,%al
  800f73:	74 e2                	je     800f57 <fork+0x82>
  800f75:	89 de                	mov    %ebx,%esi
  800f77:	c1 ee 0c             	shr    $0xc,%esi
  800f7a:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f81:	a8 01                	test   $0x1,%al
  800f83:	74 d2                	je     800f57 <fork+0x82>
        envid_t parent_envid = sys_getenvid();
  800f85:	e8 28 fc ff ff       	call   800bb2 <sys_getenvid>
  800f8a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	void *va = (void *)(pn*PGSIZE);
  800f8d:	89 f7                	mov    %esi,%edi
  800f8f:	c1 e7 0c             	shl    $0xc,%edi
        if(uvpt[pn] & PTE_SHARE){
  800f92:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f99:	f6 c4 04             	test   $0x4,%ah
  800f9c:	75 99                	jne    800f37 <fork+0x62>
	if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)){
  800f9e:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fa5:	a8 02                	test   $0x2,%al
  800fa7:	0f 85 ed 00 00 00    	jne    80109a <fork+0x1c5>
  800fad:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fb4:	f6 c4 08             	test   $0x8,%ah
  800fb7:	0f 85 dd 00 00 00    	jne    80109a <fork+0x1c5>
	 if((r=sys_page_map(parent_envid,va,envid,va,perm))<0)
  800fbd:	83 ec 0c             	sub    $0xc,%esp
  800fc0:	6a 05                	push   $0x5
  800fc2:	57                   	push   %edi
  800fc3:	ff 75 e0             	pushl  -0x20(%ebp)
  800fc6:	57                   	push   %edi
  800fc7:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fca:	e8 64 fc ff ff       	call   800c33 <sys_page_map>
  800fcf:	83 c4 20             	add    $0x20,%esp
  800fd2:	85 c0                	test   %eax,%eax
  800fd4:	79 81                	jns    800f57 <fork+0x82>
  800fd6:	e9 db 00 00 00       	jmp    8010b6 <fork+0x1e1>
		   duppage(envid,PGNUM(addr));
	}
        
	int r;
	if((r=sys_page_alloc(envid,(void *)UXSTACKTOP-PGSIZE,PTE_U|PTE_P|PTE_W))<0)
  800fdb:	83 ec 04             	sub    $0x4,%esp
  800fde:	6a 07                	push   $0x7
  800fe0:	68 00 f0 bf ee       	push   $0xeebff000
  800fe5:	ff 75 dc             	pushl  -0x24(%ebp)
  800fe8:	e8 03 fc ff ff       	call   800bf0 <sys_page_alloc>
  800fed:	83 c4 10             	add    $0x10,%esp
  800ff0:	85 c0                	test   %eax,%eax
  800ff2:	78 36                	js     80102a <fork+0x155>
		panic("fork:page alloc failed %e\n",r);

	extern void _pgfault_upcall();
	if((r = sys_env_set_pgfault_upcall(envid,_pgfault_upcall)))
  800ff4:	83 ec 08             	sub    $0x8,%esp
  800ff7:	68 48 1e 80 00       	push   $0x801e48
  800ffc:	ff 75 dc             	pushl  -0x24(%ebp)
  800fff:	e8 37 fd ff ff       	call   800d3b <sys_env_set_pgfault_upcall>
  801004:	83 c4 10             	add    $0x10,%esp
  801007:	85 c0                	test   %eax,%eax
  801009:	75 34                	jne    80103f <fork+0x16a>
		panic("fork:set upcall failed %e\n",r);
	if((r = sys_env_set_status(envid,ENV_RUNNABLE))<0)
  80100b:	83 ec 08             	sub    $0x8,%esp
  80100e:	6a 02                	push   $0x2
  801010:	ff 75 dc             	pushl  -0x24(%ebp)
  801013:	e8 9f fc ff ff       	call   800cb7 <sys_env_set_status>
  801018:	83 c4 10             	add    $0x10,%esp
  80101b:	85 c0                	test   %eax,%eax
  80101d:	78 35                	js     801054 <fork+0x17f>
		panic("fork:set status failed %e\n",r);
	//cprintf("forkid= %d\n", envid);
	return envid;
       	
}
  80101f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801022:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801025:	5b                   	pop    %ebx
  801026:	5e                   	pop    %esi
  801027:	5f                   	pop    %edi
  801028:	5d                   	pop    %ebp
  801029:	c3                   	ret    
		panic("fork:page alloc failed %e\n",r);
  80102a:	50                   	push   %eax
  80102b:	68 ff 25 80 00       	push   $0x8025ff
  801030:	68 84 00 00 00       	push   $0x84
  801035:	68 7b 25 80 00       	push   $0x80257b
  80103a:	e8 5e 0d 00 00       	call   801d9d <_panic>
		panic("fork:set upcall failed %e\n",r);
  80103f:	50                   	push   %eax
  801040:	68 1a 26 80 00       	push   $0x80261a
  801045:	68 88 00 00 00       	push   $0x88
  80104a:	68 7b 25 80 00       	push   $0x80257b
  80104f:	e8 49 0d 00 00       	call   801d9d <_panic>
		panic("fork:set status failed %e\n",r);
  801054:	50                   	push   %eax
  801055:	68 35 26 80 00       	push   $0x802635
  80105a:	68 8a 00 00 00       	push   $0x8a
  80105f:	68 7b 25 80 00       	push   $0x80257b
  801064:	e8 34 0d 00 00       	call   801d9d <_panic>
		if( (r=sys_page_map(parent_envid,va,parent_envid,va,perm))<0){
  801069:	83 ec 0c             	sub    $0xc,%esp
  80106c:	68 05 08 00 00       	push   $0x805
  801071:	57                   	push   %edi
  801072:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801075:	50                   	push   %eax
  801076:	57                   	push   %edi
  801077:	50                   	push   %eax
  801078:	e8 b6 fb ff ff       	call   800c33 <sys_page_map>
  80107d:	83 c4 20             	add    $0x20,%esp
  801080:	85 c0                	test   %eax,%eax
  801082:	0f 89 cf fe ff ff    	jns    800f57 <fork+0x82>
		 panic("duppage:map02 failed %e",r);
  801088:	50                   	push   %eax
  801089:	68 e7 25 80 00       	push   $0x8025e7
  80108e:	6a 56                	push   $0x56
  801090:	68 7b 25 80 00       	push   $0x80257b
  801095:	e8 03 0d 00 00       	call   801d9d <_panic>
	 if((r=sys_page_map(parent_envid,va,envid,va,perm))<0)
  80109a:	83 ec 0c             	sub    $0xc,%esp
  80109d:	68 05 08 00 00       	push   $0x805
  8010a2:	57                   	push   %edi
  8010a3:	ff 75 e0             	pushl  -0x20(%ebp)
  8010a6:	57                   	push   %edi
  8010a7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010aa:	e8 84 fb ff ff       	call   800c33 <sys_page_map>
  8010af:	83 c4 20             	add    $0x20,%esp
  8010b2:	85 c0                	test   %eax,%eax
  8010b4:	79 b3                	jns    801069 <fork+0x194>
		 panic("duppage:map01 failed %e",r);
  8010b6:	50                   	push   %eax
  8010b7:	68 cf 25 80 00       	push   $0x8025cf
  8010bc:	6a 53                	push   $0x53
  8010be:	68 7b 25 80 00       	push   $0x80257b
  8010c3:	e8 d5 0c 00 00       	call   801d9d <_panic>

008010c8 <sfork>:

// Challenge!
int
sfork(void)
{
  8010c8:	55                   	push   %ebp
  8010c9:	89 e5                	mov    %esp,%ebp
  8010cb:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010ce:	68 50 26 80 00       	push   $0x802650
  8010d3:	68 94 00 00 00       	push   $0x94
  8010d8:	68 7b 25 80 00       	push   $0x80257b
  8010dd:	e8 bb 0c 00 00       	call   801d9d <_panic>

008010e2 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010e2:	55                   	push   %ebp
  8010e3:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e8:	05 00 00 00 30       	add    $0x30000000,%eax
  8010ed:	c1 e8 0c             	shr    $0xc,%eax
}
  8010f0:	5d                   	pop    %ebp
  8010f1:	c3                   	ret    

008010f2 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010f2:	55                   	push   %ebp
  8010f3:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f8:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8010fd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801102:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801107:	5d                   	pop    %ebp
  801108:	c3                   	ret    

00801109 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801109:	55                   	push   %ebp
  80110a:	89 e5                	mov    %esp,%ebp
  80110c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80110f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801114:	89 c2                	mov    %eax,%edx
  801116:	c1 ea 16             	shr    $0x16,%edx
  801119:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801120:	f6 c2 01             	test   $0x1,%dl
  801123:	74 2a                	je     80114f <fd_alloc+0x46>
  801125:	89 c2                	mov    %eax,%edx
  801127:	c1 ea 0c             	shr    $0xc,%edx
  80112a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801131:	f6 c2 01             	test   $0x1,%dl
  801134:	74 19                	je     80114f <fd_alloc+0x46>
  801136:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  80113b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801140:	75 d2                	jne    801114 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801142:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801148:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  80114d:	eb 07                	jmp    801156 <fd_alloc+0x4d>
			*fd_store = fd;
  80114f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801151:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801156:	5d                   	pop    %ebp
  801157:	c3                   	ret    

00801158 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801158:	55                   	push   %ebp
  801159:	89 e5                	mov    %esp,%ebp
  80115b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80115e:	83 f8 1f             	cmp    $0x1f,%eax
  801161:	77 36                	ja     801199 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801163:	c1 e0 0c             	shl    $0xc,%eax
  801166:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80116b:	89 c2                	mov    %eax,%edx
  80116d:	c1 ea 16             	shr    $0x16,%edx
  801170:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801177:	f6 c2 01             	test   $0x1,%dl
  80117a:	74 24                	je     8011a0 <fd_lookup+0x48>
  80117c:	89 c2                	mov    %eax,%edx
  80117e:	c1 ea 0c             	shr    $0xc,%edx
  801181:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801188:	f6 c2 01             	test   $0x1,%dl
  80118b:	74 1a                	je     8011a7 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80118d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801190:	89 02                	mov    %eax,(%edx)
	return 0;
  801192:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801197:	5d                   	pop    %ebp
  801198:	c3                   	ret    
		return -E_INVAL;
  801199:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80119e:	eb f7                	jmp    801197 <fd_lookup+0x3f>
		return -E_INVAL;
  8011a0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011a5:	eb f0                	jmp    801197 <fd_lookup+0x3f>
  8011a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011ac:	eb e9                	jmp    801197 <fd_lookup+0x3f>

008011ae <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011ae:	55                   	push   %ebp
  8011af:	89 e5                	mov    %esp,%ebp
  8011b1:	83 ec 08             	sub    $0x8,%esp
  8011b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011b7:	ba 08 27 80 00       	mov    $0x802708,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011bc:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  8011c1:	39 08                	cmp    %ecx,(%eax)
  8011c3:	74 33                	je     8011f8 <dev_lookup+0x4a>
  8011c5:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  8011c8:	8b 02                	mov    (%edx),%eax
  8011ca:	85 c0                	test   %eax,%eax
  8011cc:	75 f3                	jne    8011c1 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011ce:	a1 04 40 80 00       	mov    0x804004,%eax
  8011d3:	8b 40 48             	mov    0x48(%eax),%eax
  8011d6:	83 ec 04             	sub    $0x4,%esp
  8011d9:	51                   	push   %ecx
  8011da:	50                   	push   %eax
  8011db:	68 8c 26 80 00       	push   $0x80268c
  8011e0:	e8 f3 ef ff ff       	call   8001d8 <cprintf>
	*dev = 0;
  8011e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011e8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011ee:	83 c4 10             	add    $0x10,%esp
  8011f1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011f6:	c9                   	leave  
  8011f7:	c3                   	ret    
			*dev = devtab[i];
  8011f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011fb:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011fd:	b8 00 00 00 00       	mov    $0x0,%eax
  801202:	eb f2                	jmp    8011f6 <dev_lookup+0x48>

00801204 <fd_close>:
{
  801204:	55                   	push   %ebp
  801205:	89 e5                	mov    %esp,%ebp
  801207:	57                   	push   %edi
  801208:	56                   	push   %esi
  801209:	53                   	push   %ebx
  80120a:	83 ec 1c             	sub    $0x1c,%esp
  80120d:	8b 75 08             	mov    0x8(%ebp),%esi
  801210:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801213:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801216:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801217:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80121d:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801220:	50                   	push   %eax
  801221:	e8 32 ff ff ff       	call   801158 <fd_lookup>
  801226:	89 c3                	mov    %eax,%ebx
  801228:	83 c4 08             	add    $0x8,%esp
  80122b:	85 c0                	test   %eax,%eax
  80122d:	78 05                	js     801234 <fd_close+0x30>
	    || fd != fd2)
  80122f:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801232:	74 16                	je     80124a <fd_close+0x46>
		return (must_exist ? r : 0);
  801234:	89 f8                	mov    %edi,%eax
  801236:	84 c0                	test   %al,%al
  801238:	b8 00 00 00 00       	mov    $0x0,%eax
  80123d:	0f 44 d8             	cmove  %eax,%ebx
}
  801240:	89 d8                	mov    %ebx,%eax
  801242:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801245:	5b                   	pop    %ebx
  801246:	5e                   	pop    %esi
  801247:	5f                   	pop    %edi
  801248:	5d                   	pop    %ebp
  801249:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80124a:	83 ec 08             	sub    $0x8,%esp
  80124d:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801250:	50                   	push   %eax
  801251:	ff 36                	pushl  (%esi)
  801253:	e8 56 ff ff ff       	call   8011ae <dev_lookup>
  801258:	89 c3                	mov    %eax,%ebx
  80125a:	83 c4 10             	add    $0x10,%esp
  80125d:	85 c0                	test   %eax,%eax
  80125f:	78 15                	js     801276 <fd_close+0x72>
		if (dev->dev_close)
  801261:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801264:	8b 40 10             	mov    0x10(%eax),%eax
  801267:	85 c0                	test   %eax,%eax
  801269:	74 1b                	je     801286 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  80126b:	83 ec 0c             	sub    $0xc,%esp
  80126e:	56                   	push   %esi
  80126f:	ff d0                	call   *%eax
  801271:	89 c3                	mov    %eax,%ebx
  801273:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801276:	83 ec 08             	sub    $0x8,%esp
  801279:	56                   	push   %esi
  80127a:	6a 00                	push   $0x0
  80127c:	e8 f4 f9 ff ff       	call   800c75 <sys_page_unmap>
	return r;
  801281:	83 c4 10             	add    $0x10,%esp
  801284:	eb ba                	jmp    801240 <fd_close+0x3c>
			r = 0;
  801286:	bb 00 00 00 00       	mov    $0x0,%ebx
  80128b:	eb e9                	jmp    801276 <fd_close+0x72>

0080128d <close>:

int
close(int fdnum)
{
  80128d:	55                   	push   %ebp
  80128e:	89 e5                	mov    %esp,%ebp
  801290:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801293:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801296:	50                   	push   %eax
  801297:	ff 75 08             	pushl  0x8(%ebp)
  80129a:	e8 b9 fe ff ff       	call   801158 <fd_lookup>
  80129f:	83 c4 08             	add    $0x8,%esp
  8012a2:	85 c0                	test   %eax,%eax
  8012a4:	78 10                	js     8012b6 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012a6:	83 ec 08             	sub    $0x8,%esp
  8012a9:	6a 01                	push   $0x1
  8012ab:	ff 75 f4             	pushl  -0xc(%ebp)
  8012ae:	e8 51 ff ff ff       	call   801204 <fd_close>
  8012b3:	83 c4 10             	add    $0x10,%esp
}
  8012b6:	c9                   	leave  
  8012b7:	c3                   	ret    

008012b8 <close_all>:

void
close_all(void)
{
  8012b8:	55                   	push   %ebp
  8012b9:	89 e5                	mov    %esp,%ebp
  8012bb:	53                   	push   %ebx
  8012bc:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012bf:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012c4:	83 ec 0c             	sub    $0xc,%esp
  8012c7:	53                   	push   %ebx
  8012c8:	e8 c0 ff ff ff       	call   80128d <close>
	for (i = 0; i < MAXFD; i++)
  8012cd:	83 c3 01             	add    $0x1,%ebx
  8012d0:	83 c4 10             	add    $0x10,%esp
  8012d3:	83 fb 20             	cmp    $0x20,%ebx
  8012d6:	75 ec                	jne    8012c4 <close_all+0xc>
}
  8012d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012db:	c9                   	leave  
  8012dc:	c3                   	ret    

008012dd <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012dd:	55                   	push   %ebp
  8012de:	89 e5                	mov    %esp,%ebp
  8012e0:	57                   	push   %edi
  8012e1:	56                   	push   %esi
  8012e2:	53                   	push   %ebx
  8012e3:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012e6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012e9:	50                   	push   %eax
  8012ea:	ff 75 08             	pushl  0x8(%ebp)
  8012ed:	e8 66 fe ff ff       	call   801158 <fd_lookup>
  8012f2:	89 c3                	mov    %eax,%ebx
  8012f4:	83 c4 08             	add    $0x8,%esp
  8012f7:	85 c0                	test   %eax,%eax
  8012f9:	0f 88 81 00 00 00    	js     801380 <dup+0xa3>
		return r;
	close(newfdnum);
  8012ff:	83 ec 0c             	sub    $0xc,%esp
  801302:	ff 75 0c             	pushl  0xc(%ebp)
  801305:	e8 83 ff ff ff       	call   80128d <close>

	newfd = INDEX2FD(newfdnum);
  80130a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80130d:	c1 e6 0c             	shl    $0xc,%esi
  801310:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801316:	83 c4 04             	add    $0x4,%esp
  801319:	ff 75 e4             	pushl  -0x1c(%ebp)
  80131c:	e8 d1 fd ff ff       	call   8010f2 <fd2data>
  801321:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801323:	89 34 24             	mov    %esi,(%esp)
  801326:	e8 c7 fd ff ff       	call   8010f2 <fd2data>
  80132b:	83 c4 10             	add    $0x10,%esp
  80132e:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801330:	89 d8                	mov    %ebx,%eax
  801332:	c1 e8 16             	shr    $0x16,%eax
  801335:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80133c:	a8 01                	test   $0x1,%al
  80133e:	74 11                	je     801351 <dup+0x74>
  801340:	89 d8                	mov    %ebx,%eax
  801342:	c1 e8 0c             	shr    $0xc,%eax
  801345:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80134c:	f6 c2 01             	test   $0x1,%dl
  80134f:	75 39                	jne    80138a <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801351:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801354:	89 d0                	mov    %edx,%eax
  801356:	c1 e8 0c             	shr    $0xc,%eax
  801359:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801360:	83 ec 0c             	sub    $0xc,%esp
  801363:	25 07 0e 00 00       	and    $0xe07,%eax
  801368:	50                   	push   %eax
  801369:	56                   	push   %esi
  80136a:	6a 00                	push   $0x0
  80136c:	52                   	push   %edx
  80136d:	6a 00                	push   $0x0
  80136f:	e8 bf f8 ff ff       	call   800c33 <sys_page_map>
  801374:	89 c3                	mov    %eax,%ebx
  801376:	83 c4 20             	add    $0x20,%esp
  801379:	85 c0                	test   %eax,%eax
  80137b:	78 31                	js     8013ae <dup+0xd1>
		goto err;

	return newfdnum;
  80137d:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801380:	89 d8                	mov    %ebx,%eax
  801382:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801385:	5b                   	pop    %ebx
  801386:	5e                   	pop    %esi
  801387:	5f                   	pop    %edi
  801388:	5d                   	pop    %ebp
  801389:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80138a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801391:	83 ec 0c             	sub    $0xc,%esp
  801394:	25 07 0e 00 00       	and    $0xe07,%eax
  801399:	50                   	push   %eax
  80139a:	57                   	push   %edi
  80139b:	6a 00                	push   $0x0
  80139d:	53                   	push   %ebx
  80139e:	6a 00                	push   $0x0
  8013a0:	e8 8e f8 ff ff       	call   800c33 <sys_page_map>
  8013a5:	89 c3                	mov    %eax,%ebx
  8013a7:	83 c4 20             	add    $0x20,%esp
  8013aa:	85 c0                	test   %eax,%eax
  8013ac:	79 a3                	jns    801351 <dup+0x74>
	sys_page_unmap(0, newfd);
  8013ae:	83 ec 08             	sub    $0x8,%esp
  8013b1:	56                   	push   %esi
  8013b2:	6a 00                	push   $0x0
  8013b4:	e8 bc f8 ff ff       	call   800c75 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013b9:	83 c4 08             	add    $0x8,%esp
  8013bc:	57                   	push   %edi
  8013bd:	6a 00                	push   $0x0
  8013bf:	e8 b1 f8 ff ff       	call   800c75 <sys_page_unmap>
	return r;
  8013c4:	83 c4 10             	add    $0x10,%esp
  8013c7:	eb b7                	jmp    801380 <dup+0xa3>

008013c9 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013c9:	55                   	push   %ebp
  8013ca:	89 e5                	mov    %esp,%ebp
  8013cc:	53                   	push   %ebx
  8013cd:	83 ec 14             	sub    $0x14,%esp
  8013d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013d3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013d6:	50                   	push   %eax
  8013d7:	53                   	push   %ebx
  8013d8:	e8 7b fd ff ff       	call   801158 <fd_lookup>
  8013dd:	83 c4 08             	add    $0x8,%esp
  8013e0:	85 c0                	test   %eax,%eax
  8013e2:	78 3f                	js     801423 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013e4:	83 ec 08             	sub    $0x8,%esp
  8013e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ea:	50                   	push   %eax
  8013eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ee:	ff 30                	pushl  (%eax)
  8013f0:	e8 b9 fd ff ff       	call   8011ae <dev_lookup>
  8013f5:	83 c4 10             	add    $0x10,%esp
  8013f8:	85 c0                	test   %eax,%eax
  8013fa:	78 27                	js     801423 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013fc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013ff:	8b 42 08             	mov    0x8(%edx),%eax
  801402:	83 e0 03             	and    $0x3,%eax
  801405:	83 f8 01             	cmp    $0x1,%eax
  801408:	74 1e                	je     801428 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80140a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80140d:	8b 40 08             	mov    0x8(%eax),%eax
  801410:	85 c0                	test   %eax,%eax
  801412:	74 35                	je     801449 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801414:	83 ec 04             	sub    $0x4,%esp
  801417:	ff 75 10             	pushl  0x10(%ebp)
  80141a:	ff 75 0c             	pushl  0xc(%ebp)
  80141d:	52                   	push   %edx
  80141e:	ff d0                	call   *%eax
  801420:	83 c4 10             	add    $0x10,%esp
}
  801423:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801426:	c9                   	leave  
  801427:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801428:	a1 04 40 80 00       	mov    0x804004,%eax
  80142d:	8b 40 48             	mov    0x48(%eax),%eax
  801430:	83 ec 04             	sub    $0x4,%esp
  801433:	53                   	push   %ebx
  801434:	50                   	push   %eax
  801435:	68 cd 26 80 00       	push   $0x8026cd
  80143a:	e8 99 ed ff ff       	call   8001d8 <cprintf>
		return -E_INVAL;
  80143f:	83 c4 10             	add    $0x10,%esp
  801442:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801447:	eb da                	jmp    801423 <read+0x5a>
		return -E_NOT_SUPP;
  801449:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80144e:	eb d3                	jmp    801423 <read+0x5a>

00801450 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801450:	55                   	push   %ebp
  801451:	89 e5                	mov    %esp,%ebp
  801453:	57                   	push   %edi
  801454:	56                   	push   %esi
  801455:	53                   	push   %ebx
  801456:	83 ec 0c             	sub    $0xc,%esp
  801459:	8b 7d 08             	mov    0x8(%ebp),%edi
  80145c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80145f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801464:	39 f3                	cmp    %esi,%ebx
  801466:	73 25                	jae    80148d <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801468:	83 ec 04             	sub    $0x4,%esp
  80146b:	89 f0                	mov    %esi,%eax
  80146d:	29 d8                	sub    %ebx,%eax
  80146f:	50                   	push   %eax
  801470:	89 d8                	mov    %ebx,%eax
  801472:	03 45 0c             	add    0xc(%ebp),%eax
  801475:	50                   	push   %eax
  801476:	57                   	push   %edi
  801477:	e8 4d ff ff ff       	call   8013c9 <read>
		if (m < 0)
  80147c:	83 c4 10             	add    $0x10,%esp
  80147f:	85 c0                	test   %eax,%eax
  801481:	78 08                	js     80148b <readn+0x3b>
			return m;
		if (m == 0)
  801483:	85 c0                	test   %eax,%eax
  801485:	74 06                	je     80148d <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  801487:	01 c3                	add    %eax,%ebx
  801489:	eb d9                	jmp    801464 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80148b:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80148d:	89 d8                	mov    %ebx,%eax
  80148f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801492:	5b                   	pop    %ebx
  801493:	5e                   	pop    %esi
  801494:	5f                   	pop    %edi
  801495:	5d                   	pop    %ebp
  801496:	c3                   	ret    

00801497 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801497:	55                   	push   %ebp
  801498:	89 e5                	mov    %esp,%ebp
  80149a:	53                   	push   %ebx
  80149b:	83 ec 14             	sub    $0x14,%esp
  80149e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014a1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014a4:	50                   	push   %eax
  8014a5:	53                   	push   %ebx
  8014a6:	e8 ad fc ff ff       	call   801158 <fd_lookup>
  8014ab:	83 c4 08             	add    $0x8,%esp
  8014ae:	85 c0                	test   %eax,%eax
  8014b0:	78 3a                	js     8014ec <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014b2:	83 ec 08             	sub    $0x8,%esp
  8014b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b8:	50                   	push   %eax
  8014b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014bc:	ff 30                	pushl  (%eax)
  8014be:	e8 eb fc ff ff       	call   8011ae <dev_lookup>
  8014c3:	83 c4 10             	add    $0x10,%esp
  8014c6:	85 c0                	test   %eax,%eax
  8014c8:	78 22                	js     8014ec <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014cd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014d1:	74 1e                	je     8014f1 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014d3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014d6:	8b 52 0c             	mov    0xc(%edx),%edx
  8014d9:	85 d2                	test   %edx,%edx
  8014db:	74 35                	je     801512 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014dd:	83 ec 04             	sub    $0x4,%esp
  8014e0:	ff 75 10             	pushl  0x10(%ebp)
  8014e3:	ff 75 0c             	pushl  0xc(%ebp)
  8014e6:	50                   	push   %eax
  8014e7:	ff d2                	call   *%edx
  8014e9:	83 c4 10             	add    $0x10,%esp
}
  8014ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014ef:	c9                   	leave  
  8014f0:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014f1:	a1 04 40 80 00       	mov    0x804004,%eax
  8014f6:	8b 40 48             	mov    0x48(%eax),%eax
  8014f9:	83 ec 04             	sub    $0x4,%esp
  8014fc:	53                   	push   %ebx
  8014fd:	50                   	push   %eax
  8014fe:	68 e9 26 80 00       	push   $0x8026e9
  801503:	e8 d0 ec ff ff       	call   8001d8 <cprintf>
		return -E_INVAL;
  801508:	83 c4 10             	add    $0x10,%esp
  80150b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801510:	eb da                	jmp    8014ec <write+0x55>
		return -E_NOT_SUPP;
  801512:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801517:	eb d3                	jmp    8014ec <write+0x55>

00801519 <seek>:

int
seek(int fdnum, off_t offset)
{
  801519:	55                   	push   %ebp
  80151a:	89 e5                	mov    %esp,%ebp
  80151c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80151f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801522:	50                   	push   %eax
  801523:	ff 75 08             	pushl  0x8(%ebp)
  801526:	e8 2d fc ff ff       	call   801158 <fd_lookup>
  80152b:	83 c4 08             	add    $0x8,%esp
  80152e:	85 c0                	test   %eax,%eax
  801530:	78 0e                	js     801540 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801532:	8b 55 0c             	mov    0xc(%ebp),%edx
  801535:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801538:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80153b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801540:	c9                   	leave  
  801541:	c3                   	ret    

00801542 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801542:	55                   	push   %ebp
  801543:	89 e5                	mov    %esp,%ebp
  801545:	53                   	push   %ebx
  801546:	83 ec 14             	sub    $0x14,%esp
  801549:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80154c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80154f:	50                   	push   %eax
  801550:	53                   	push   %ebx
  801551:	e8 02 fc ff ff       	call   801158 <fd_lookup>
  801556:	83 c4 08             	add    $0x8,%esp
  801559:	85 c0                	test   %eax,%eax
  80155b:	78 37                	js     801594 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80155d:	83 ec 08             	sub    $0x8,%esp
  801560:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801563:	50                   	push   %eax
  801564:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801567:	ff 30                	pushl  (%eax)
  801569:	e8 40 fc ff ff       	call   8011ae <dev_lookup>
  80156e:	83 c4 10             	add    $0x10,%esp
  801571:	85 c0                	test   %eax,%eax
  801573:	78 1f                	js     801594 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801575:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801578:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80157c:	74 1b                	je     801599 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80157e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801581:	8b 52 18             	mov    0x18(%edx),%edx
  801584:	85 d2                	test   %edx,%edx
  801586:	74 32                	je     8015ba <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801588:	83 ec 08             	sub    $0x8,%esp
  80158b:	ff 75 0c             	pushl  0xc(%ebp)
  80158e:	50                   	push   %eax
  80158f:	ff d2                	call   *%edx
  801591:	83 c4 10             	add    $0x10,%esp
}
  801594:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801597:	c9                   	leave  
  801598:	c3                   	ret    
			thisenv->env_id, fdnum);
  801599:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80159e:	8b 40 48             	mov    0x48(%eax),%eax
  8015a1:	83 ec 04             	sub    $0x4,%esp
  8015a4:	53                   	push   %ebx
  8015a5:	50                   	push   %eax
  8015a6:	68 ac 26 80 00       	push   $0x8026ac
  8015ab:	e8 28 ec ff ff       	call   8001d8 <cprintf>
		return -E_INVAL;
  8015b0:	83 c4 10             	add    $0x10,%esp
  8015b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015b8:	eb da                	jmp    801594 <ftruncate+0x52>
		return -E_NOT_SUPP;
  8015ba:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015bf:	eb d3                	jmp    801594 <ftruncate+0x52>

008015c1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015c1:	55                   	push   %ebp
  8015c2:	89 e5                	mov    %esp,%ebp
  8015c4:	53                   	push   %ebx
  8015c5:	83 ec 14             	sub    $0x14,%esp
  8015c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015cb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ce:	50                   	push   %eax
  8015cf:	ff 75 08             	pushl  0x8(%ebp)
  8015d2:	e8 81 fb ff ff       	call   801158 <fd_lookup>
  8015d7:	83 c4 08             	add    $0x8,%esp
  8015da:	85 c0                	test   %eax,%eax
  8015dc:	78 4b                	js     801629 <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015de:	83 ec 08             	sub    $0x8,%esp
  8015e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e4:	50                   	push   %eax
  8015e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e8:	ff 30                	pushl  (%eax)
  8015ea:	e8 bf fb ff ff       	call   8011ae <dev_lookup>
  8015ef:	83 c4 10             	add    $0x10,%esp
  8015f2:	85 c0                	test   %eax,%eax
  8015f4:	78 33                	js     801629 <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  8015f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015f9:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015fd:	74 2f                	je     80162e <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015ff:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801602:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801609:	00 00 00 
	stat->st_isdir = 0;
  80160c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801613:	00 00 00 
	stat->st_dev = dev;
  801616:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80161c:	83 ec 08             	sub    $0x8,%esp
  80161f:	53                   	push   %ebx
  801620:	ff 75 f0             	pushl  -0x10(%ebp)
  801623:	ff 50 14             	call   *0x14(%eax)
  801626:	83 c4 10             	add    $0x10,%esp
}
  801629:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80162c:	c9                   	leave  
  80162d:	c3                   	ret    
		return -E_NOT_SUPP;
  80162e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801633:	eb f4                	jmp    801629 <fstat+0x68>

00801635 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801635:	55                   	push   %ebp
  801636:	89 e5                	mov    %esp,%ebp
  801638:	56                   	push   %esi
  801639:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80163a:	83 ec 08             	sub    $0x8,%esp
  80163d:	6a 00                	push   $0x0
  80163f:	ff 75 08             	pushl  0x8(%ebp)
  801642:	e8 e7 01 00 00       	call   80182e <open>
  801647:	89 c3                	mov    %eax,%ebx
  801649:	83 c4 10             	add    $0x10,%esp
  80164c:	85 c0                	test   %eax,%eax
  80164e:	78 1b                	js     80166b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801650:	83 ec 08             	sub    $0x8,%esp
  801653:	ff 75 0c             	pushl  0xc(%ebp)
  801656:	50                   	push   %eax
  801657:	e8 65 ff ff ff       	call   8015c1 <fstat>
  80165c:	89 c6                	mov    %eax,%esi
	close(fd);
  80165e:	89 1c 24             	mov    %ebx,(%esp)
  801661:	e8 27 fc ff ff       	call   80128d <close>
	return r;
  801666:	83 c4 10             	add    $0x10,%esp
  801669:	89 f3                	mov    %esi,%ebx
}
  80166b:	89 d8                	mov    %ebx,%eax
  80166d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801670:	5b                   	pop    %ebx
  801671:	5e                   	pop    %esi
  801672:	5d                   	pop    %ebp
  801673:	c3                   	ret    

00801674 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801674:	55                   	push   %ebp
  801675:	89 e5                	mov    %esp,%ebp
  801677:	56                   	push   %esi
  801678:	53                   	push   %ebx
  801679:	89 c6                	mov    %eax,%esi
  80167b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80167d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801684:	74 27                	je     8016ad <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801686:	6a 07                	push   $0x7
  801688:	68 00 50 80 00       	push   $0x805000
  80168d:	56                   	push   %esi
  80168e:	ff 35 00 40 80 00    	pushl  0x804000
  801694:	e8 4b 08 00 00       	call   801ee4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801699:	83 c4 0c             	add    $0xc,%esp
  80169c:	6a 00                	push   $0x0
  80169e:	53                   	push   %ebx
  80169f:	6a 00                	push   $0x0
  8016a1:	e8 c9 07 00 00       	call   801e6f <ipc_recv>
}
  8016a6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016a9:	5b                   	pop    %ebx
  8016aa:	5e                   	pop    %esi
  8016ab:	5d                   	pop    %ebp
  8016ac:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016ad:	83 ec 0c             	sub    $0xc,%esp
  8016b0:	6a 01                	push   $0x1
  8016b2:	e8 83 08 00 00       	call   801f3a <ipc_find_env>
  8016b7:	a3 00 40 80 00       	mov    %eax,0x804000
  8016bc:	83 c4 10             	add    $0x10,%esp
  8016bf:	eb c5                	jmp    801686 <fsipc+0x12>

008016c1 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016c1:	55                   	push   %ebp
  8016c2:	89 e5                	mov    %esp,%ebp
  8016c4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ca:	8b 40 0c             	mov    0xc(%eax),%eax
  8016cd:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016d5:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016da:	ba 00 00 00 00       	mov    $0x0,%edx
  8016df:	b8 02 00 00 00       	mov    $0x2,%eax
  8016e4:	e8 8b ff ff ff       	call   801674 <fsipc>
}
  8016e9:	c9                   	leave  
  8016ea:	c3                   	ret    

008016eb <devfile_flush>:
{
  8016eb:	55                   	push   %ebp
  8016ec:	89 e5                	mov    %esp,%ebp
  8016ee:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f4:	8b 40 0c             	mov    0xc(%eax),%eax
  8016f7:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016fc:	ba 00 00 00 00       	mov    $0x0,%edx
  801701:	b8 06 00 00 00       	mov    $0x6,%eax
  801706:	e8 69 ff ff ff       	call   801674 <fsipc>
}
  80170b:	c9                   	leave  
  80170c:	c3                   	ret    

0080170d <devfile_stat>:
{
  80170d:	55                   	push   %ebp
  80170e:	89 e5                	mov    %esp,%ebp
  801710:	53                   	push   %ebx
  801711:	83 ec 04             	sub    $0x4,%esp
  801714:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801717:	8b 45 08             	mov    0x8(%ebp),%eax
  80171a:	8b 40 0c             	mov    0xc(%eax),%eax
  80171d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801722:	ba 00 00 00 00       	mov    $0x0,%edx
  801727:	b8 05 00 00 00       	mov    $0x5,%eax
  80172c:	e8 43 ff ff ff       	call   801674 <fsipc>
  801731:	85 c0                	test   %eax,%eax
  801733:	78 2c                	js     801761 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801735:	83 ec 08             	sub    $0x8,%esp
  801738:	68 00 50 80 00       	push   $0x805000
  80173d:	53                   	push   %ebx
  80173e:	e8 b4 f0 ff ff       	call   8007f7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801743:	a1 80 50 80 00       	mov    0x805080,%eax
  801748:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80174e:	a1 84 50 80 00       	mov    0x805084,%eax
  801753:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801759:	83 c4 10             	add    $0x10,%esp
  80175c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801761:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801764:	c9                   	leave  
  801765:	c3                   	ret    

00801766 <devfile_write>:
{
  801766:	55                   	push   %ebp
  801767:	89 e5                	mov    %esp,%ebp
  801769:	83 ec 0c             	sub    $0xc,%esp
  80176c:	8b 45 10             	mov    0x10(%ebp),%eax
  80176f:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801774:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801779:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80177c:	8b 55 08             	mov    0x8(%ebp),%edx
  80177f:	8b 52 0c             	mov    0xc(%edx),%edx
  801782:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801788:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf,buf,n);
  80178d:	50                   	push   %eax
  80178e:	ff 75 0c             	pushl  0xc(%ebp)
  801791:	68 08 50 80 00       	push   $0x805008
  801796:	e8 ea f1 ff ff       	call   800985 <memmove>
	if((r = fsipc(FSREQ_WRITE,NULL))<0)
  80179b:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a0:	b8 04 00 00 00       	mov    $0x4,%eax
  8017a5:	e8 ca fe ff ff       	call   801674 <fsipc>
}
  8017aa:	c9                   	leave  
  8017ab:	c3                   	ret    

008017ac <devfile_read>:
{
  8017ac:	55                   	push   %ebp
  8017ad:	89 e5                	mov    %esp,%ebp
  8017af:	56                   	push   %esi
  8017b0:	53                   	push   %ebx
  8017b1:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b7:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ba:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017bf:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ca:	b8 03 00 00 00       	mov    $0x3,%eax
  8017cf:	e8 a0 fe ff ff       	call   801674 <fsipc>
  8017d4:	89 c3                	mov    %eax,%ebx
  8017d6:	85 c0                	test   %eax,%eax
  8017d8:	78 1f                	js     8017f9 <devfile_read+0x4d>
	assert(r <= n);
  8017da:	39 f0                	cmp    %esi,%eax
  8017dc:	77 24                	ja     801802 <devfile_read+0x56>
	assert(r <= PGSIZE);
  8017de:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017e3:	7f 33                	jg     801818 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017e5:	83 ec 04             	sub    $0x4,%esp
  8017e8:	50                   	push   %eax
  8017e9:	68 00 50 80 00       	push   $0x805000
  8017ee:	ff 75 0c             	pushl  0xc(%ebp)
  8017f1:	e8 8f f1 ff ff       	call   800985 <memmove>
	return r;
  8017f6:	83 c4 10             	add    $0x10,%esp
}
  8017f9:	89 d8                	mov    %ebx,%eax
  8017fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017fe:	5b                   	pop    %ebx
  8017ff:	5e                   	pop    %esi
  801800:	5d                   	pop    %ebp
  801801:	c3                   	ret    
	assert(r <= n);
  801802:	68 18 27 80 00       	push   $0x802718
  801807:	68 1f 27 80 00       	push   $0x80271f
  80180c:	6a 7c                	push   $0x7c
  80180e:	68 34 27 80 00       	push   $0x802734
  801813:	e8 85 05 00 00       	call   801d9d <_panic>
	assert(r <= PGSIZE);
  801818:	68 3f 27 80 00       	push   $0x80273f
  80181d:	68 1f 27 80 00       	push   $0x80271f
  801822:	6a 7d                	push   $0x7d
  801824:	68 34 27 80 00       	push   $0x802734
  801829:	e8 6f 05 00 00       	call   801d9d <_panic>

0080182e <open>:
{
  80182e:	55                   	push   %ebp
  80182f:	89 e5                	mov    %esp,%ebp
  801831:	56                   	push   %esi
  801832:	53                   	push   %ebx
  801833:	83 ec 1c             	sub    $0x1c,%esp
  801836:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801839:	56                   	push   %esi
  80183a:	e8 81 ef ff ff       	call   8007c0 <strlen>
  80183f:	83 c4 10             	add    $0x10,%esp
  801842:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801847:	7f 6c                	jg     8018b5 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801849:	83 ec 0c             	sub    $0xc,%esp
  80184c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80184f:	50                   	push   %eax
  801850:	e8 b4 f8 ff ff       	call   801109 <fd_alloc>
  801855:	89 c3                	mov    %eax,%ebx
  801857:	83 c4 10             	add    $0x10,%esp
  80185a:	85 c0                	test   %eax,%eax
  80185c:	78 3c                	js     80189a <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  80185e:	83 ec 08             	sub    $0x8,%esp
  801861:	56                   	push   %esi
  801862:	68 00 50 80 00       	push   $0x805000
  801867:	e8 8b ef ff ff       	call   8007f7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80186c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80186f:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801874:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801877:	b8 01 00 00 00       	mov    $0x1,%eax
  80187c:	e8 f3 fd ff ff       	call   801674 <fsipc>
  801881:	89 c3                	mov    %eax,%ebx
  801883:	83 c4 10             	add    $0x10,%esp
  801886:	85 c0                	test   %eax,%eax
  801888:	78 19                	js     8018a3 <open+0x75>
	return fd2num(fd);
  80188a:	83 ec 0c             	sub    $0xc,%esp
  80188d:	ff 75 f4             	pushl  -0xc(%ebp)
  801890:	e8 4d f8 ff ff       	call   8010e2 <fd2num>
  801895:	89 c3                	mov    %eax,%ebx
  801897:	83 c4 10             	add    $0x10,%esp
}
  80189a:	89 d8                	mov    %ebx,%eax
  80189c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80189f:	5b                   	pop    %ebx
  8018a0:	5e                   	pop    %esi
  8018a1:	5d                   	pop    %ebp
  8018a2:	c3                   	ret    
		fd_close(fd, 0);
  8018a3:	83 ec 08             	sub    $0x8,%esp
  8018a6:	6a 00                	push   $0x0
  8018a8:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ab:	e8 54 f9 ff ff       	call   801204 <fd_close>
		return r;
  8018b0:	83 c4 10             	add    $0x10,%esp
  8018b3:	eb e5                	jmp    80189a <open+0x6c>
		return -E_BAD_PATH;
  8018b5:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8018ba:	eb de                	jmp    80189a <open+0x6c>

008018bc <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018bc:	55                   	push   %ebp
  8018bd:	89 e5                	mov    %esp,%ebp
  8018bf:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c7:	b8 08 00 00 00       	mov    $0x8,%eax
  8018cc:	e8 a3 fd ff ff       	call   801674 <fsipc>
}
  8018d1:	c9                   	leave  
  8018d2:	c3                   	ret    

008018d3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018d3:	55                   	push   %ebp
  8018d4:	89 e5                	mov    %esp,%ebp
  8018d6:	56                   	push   %esi
  8018d7:	53                   	push   %ebx
  8018d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018db:	83 ec 0c             	sub    $0xc,%esp
  8018de:	ff 75 08             	pushl  0x8(%ebp)
  8018e1:	e8 0c f8 ff ff       	call   8010f2 <fd2data>
  8018e6:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8018e8:	83 c4 08             	add    $0x8,%esp
  8018eb:	68 4b 27 80 00       	push   $0x80274b
  8018f0:	53                   	push   %ebx
  8018f1:	e8 01 ef ff ff       	call   8007f7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018f6:	8b 46 04             	mov    0x4(%esi),%eax
  8018f9:	2b 06                	sub    (%esi),%eax
  8018fb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801901:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801908:	00 00 00 
	stat->st_dev = &devpipe;
  80190b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801912:	30 80 00 
	return 0;
}
  801915:	b8 00 00 00 00       	mov    $0x0,%eax
  80191a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80191d:	5b                   	pop    %ebx
  80191e:	5e                   	pop    %esi
  80191f:	5d                   	pop    %ebp
  801920:	c3                   	ret    

00801921 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801921:	55                   	push   %ebp
  801922:	89 e5                	mov    %esp,%ebp
  801924:	53                   	push   %ebx
  801925:	83 ec 0c             	sub    $0xc,%esp
  801928:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80192b:	53                   	push   %ebx
  80192c:	6a 00                	push   $0x0
  80192e:	e8 42 f3 ff ff       	call   800c75 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801933:	89 1c 24             	mov    %ebx,(%esp)
  801936:	e8 b7 f7 ff ff       	call   8010f2 <fd2data>
  80193b:	83 c4 08             	add    $0x8,%esp
  80193e:	50                   	push   %eax
  80193f:	6a 00                	push   $0x0
  801941:	e8 2f f3 ff ff       	call   800c75 <sys_page_unmap>
}
  801946:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801949:	c9                   	leave  
  80194a:	c3                   	ret    

0080194b <_pipeisclosed>:
{
  80194b:	55                   	push   %ebp
  80194c:	89 e5                	mov    %esp,%ebp
  80194e:	57                   	push   %edi
  80194f:	56                   	push   %esi
  801950:	53                   	push   %ebx
  801951:	83 ec 1c             	sub    $0x1c,%esp
  801954:	89 c7                	mov    %eax,%edi
  801956:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801958:	a1 04 40 80 00       	mov    0x804004,%eax
  80195d:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801960:	83 ec 0c             	sub    $0xc,%esp
  801963:	57                   	push   %edi
  801964:	e8 0a 06 00 00       	call   801f73 <pageref>
  801969:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80196c:	89 34 24             	mov    %esi,(%esp)
  80196f:	e8 ff 05 00 00       	call   801f73 <pageref>
		nn = thisenv->env_runs;
  801974:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80197a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80197d:	83 c4 10             	add    $0x10,%esp
  801980:	39 cb                	cmp    %ecx,%ebx
  801982:	74 1b                	je     80199f <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801984:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801987:	75 cf                	jne    801958 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801989:	8b 42 58             	mov    0x58(%edx),%eax
  80198c:	6a 01                	push   $0x1
  80198e:	50                   	push   %eax
  80198f:	53                   	push   %ebx
  801990:	68 52 27 80 00       	push   $0x802752
  801995:	e8 3e e8 ff ff       	call   8001d8 <cprintf>
  80199a:	83 c4 10             	add    $0x10,%esp
  80199d:	eb b9                	jmp    801958 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  80199f:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8019a2:	0f 94 c0             	sete   %al
  8019a5:	0f b6 c0             	movzbl %al,%eax
}
  8019a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019ab:	5b                   	pop    %ebx
  8019ac:	5e                   	pop    %esi
  8019ad:	5f                   	pop    %edi
  8019ae:	5d                   	pop    %ebp
  8019af:	c3                   	ret    

008019b0 <devpipe_write>:
{
  8019b0:	55                   	push   %ebp
  8019b1:	89 e5                	mov    %esp,%ebp
  8019b3:	57                   	push   %edi
  8019b4:	56                   	push   %esi
  8019b5:	53                   	push   %ebx
  8019b6:	83 ec 28             	sub    $0x28,%esp
  8019b9:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8019bc:	56                   	push   %esi
  8019bd:	e8 30 f7 ff ff       	call   8010f2 <fd2data>
  8019c2:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8019c4:	83 c4 10             	add    $0x10,%esp
  8019c7:	bf 00 00 00 00       	mov    $0x0,%edi
  8019cc:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8019cf:	74 4f                	je     801a20 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019d1:	8b 43 04             	mov    0x4(%ebx),%eax
  8019d4:	8b 0b                	mov    (%ebx),%ecx
  8019d6:	8d 51 20             	lea    0x20(%ecx),%edx
  8019d9:	39 d0                	cmp    %edx,%eax
  8019db:	72 14                	jb     8019f1 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  8019dd:	89 da                	mov    %ebx,%edx
  8019df:	89 f0                	mov    %esi,%eax
  8019e1:	e8 65 ff ff ff       	call   80194b <_pipeisclosed>
  8019e6:	85 c0                	test   %eax,%eax
  8019e8:	75 3a                	jne    801a24 <devpipe_write+0x74>
			sys_yield();
  8019ea:	e8 e2 f1 ff ff       	call   800bd1 <sys_yield>
  8019ef:	eb e0                	jmp    8019d1 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019f4:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8019f8:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8019fb:	89 c2                	mov    %eax,%edx
  8019fd:	c1 fa 1f             	sar    $0x1f,%edx
  801a00:	89 d1                	mov    %edx,%ecx
  801a02:	c1 e9 1b             	shr    $0x1b,%ecx
  801a05:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a08:	83 e2 1f             	and    $0x1f,%edx
  801a0b:	29 ca                	sub    %ecx,%edx
  801a0d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a11:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a15:	83 c0 01             	add    $0x1,%eax
  801a18:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801a1b:	83 c7 01             	add    $0x1,%edi
  801a1e:	eb ac                	jmp    8019cc <devpipe_write+0x1c>
	return i;
  801a20:	89 f8                	mov    %edi,%eax
  801a22:	eb 05                	jmp    801a29 <devpipe_write+0x79>
				return 0;
  801a24:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a29:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a2c:	5b                   	pop    %ebx
  801a2d:	5e                   	pop    %esi
  801a2e:	5f                   	pop    %edi
  801a2f:	5d                   	pop    %ebp
  801a30:	c3                   	ret    

00801a31 <devpipe_read>:
{
  801a31:	55                   	push   %ebp
  801a32:	89 e5                	mov    %esp,%ebp
  801a34:	57                   	push   %edi
  801a35:	56                   	push   %esi
  801a36:	53                   	push   %ebx
  801a37:	83 ec 18             	sub    $0x18,%esp
  801a3a:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801a3d:	57                   	push   %edi
  801a3e:	e8 af f6 ff ff       	call   8010f2 <fd2data>
  801a43:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801a45:	83 c4 10             	add    $0x10,%esp
  801a48:	be 00 00 00 00       	mov    $0x0,%esi
  801a4d:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a50:	74 47                	je     801a99 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  801a52:	8b 03                	mov    (%ebx),%eax
  801a54:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a57:	75 22                	jne    801a7b <devpipe_read+0x4a>
			if (i > 0)
  801a59:	85 f6                	test   %esi,%esi
  801a5b:	75 14                	jne    801a71 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801a5d:	89 da                	mov    %ebx,%edx
  801a5f:	89 f8                	mov    %edi,%eax
  801a61:	e8 e5 fe ff ff       	call   80194b <_pipeisclosed>
  801a66:	85 c0                	test   %eax,%eax
  801a68:	75 33                	jne    801a9d <devpipe_read+0x6c>
			sys_yield();
  801a6a:	e8 62 f1 ff ff       	call   800bd1 <sys_yield>
  801a6f:	eb e1                	jmp    801a52 <devpipe_read+0x21>
				return i;
  801a71:	89 f0                	mov    %esi,%eax
}
  801a73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a76:	5b                   	pop    %ebx
  801a77:	5e                   	pop    %esi
  801a78:	5f                   	pop    %edi
  801a79:	5d                   	pop    %ebp
  801a7a:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a7b:	99                   	cltd   
  801a7c:	c1 ea 1b             	shr    $0x1b,%edx
  801a7f:	01 d0                	add    %edx,%eax
  801a81:	83 e0 1f             	and    $0x1f,%eax
  801a84:	29 d0                	sub    %edx,%eax
  801a86:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801a8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a8e:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801a91:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801a94:	83 c6 01             	add    $0x1,%esi
  801a97:	eb b4                	jmp    801a4d <devpipe_read+0x1c>
	return i;
  801a99:	89 f0                	mov    %esi,%eax
  801a9b:	eb d6                	jmp    801a73 <devpipe_read+0x42>
				return 0;
  801a9d:	b8 00 00 00 00       	mov    $0x0,%eax
  801aa2:	eb cf                	jmp    801a73 <devpipe_read+0x42>

00801aa4 <pipe>:
{
  801aa4:	55                   	push   %ebp
  801aa5:	89 e5                	mov    %esp,%ebp
  801aa7:	56                   	push   %esi
  801aa8:	53                   	push   %ebx
  801aa9:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801aac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aaf:	50                   	push   %eax
  801ab0:	e8 54 f6 ff ff       	call   801109 <fd_alloc>
  801ab5:	89 c3                	mov    %eax,%ebx
  801ab7:	83 c4 10             	add    $0x10,%esp
  801aba:	85 c0                	test   %eax,%eax
  801abc:	78 5b                	js     801b19 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801abe:	83 ec 04             	sub    $0x4,%esp
  801ac1:	68 07 04 00 00       	push   $0x407
  801ac6:	ff 75 f4             	pushl  -0xc(%ebp)
  801ac9:	6a 00                	push   $0x0
  801acb:	e8 20 f1 ff ff       	call   800bf0 <sys_page_alloc>
  801ad0:	89 c3                	mov    %eax,%ebx
  801ad2:	83 c4 10             	add    $0x10,%esp
  801ad5:	85 c0                	test   %eax,%eax
  801ad7:	78 40                	js     801b19 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  801ad9:	83 ec 0c             	sub    $0xc,%esp
  801adc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801adf:	50                   	push   %eax
  801ae0:	e8 24 f6 ff ff       	call   801109 <fd_alloc>
  801ae5:	89 c3                	mov    %eax,%ebx
  801ae7:	83 c4 10             	add    $0x10,%esp
  801aea:	85 c0                	test   %eax,%eax
  801aec:	78 1b                	js     801b09 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aee:	83 ec 04             	sub    $0x4,%esp
  801af1:	68 07 04 00 00       	push   $0x407
  801af6:	ff 75 f0             	pushl  -0x10(%ebp)
  801af9:	6a 00                	push   $0x0
  801afb:	e8 f0 f0 ff ff       	call   800bf0 <sys_page_alloc>
  801b00:	89 c3                	mov    %eax,%ebx
  801b02:	83 c4 10             	add    $0x10,%esp
  801b05:	85 c0                	test   %eax,%eax
  801b07:	79 19                	jns    801b22 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  801b09:	83 ec 08             	sub    $0x8,%esp
  801b0c:	ff 75 f4             	pushl  -0xc(%ebp)
  801b0f:	6a 00                	push   $0x0
  801b11:	e8 5f f1 ff ff       	call   800c75 <sys_page_unmap>
  801b16:	83 c4 10             	add    $0x10,%esp
}
  801b19:	89 d8                	mov    %ebx,%eax
  801b1b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b1e:	5b                   	pop    %ebx
  801b1f:	5e                   	pop    %esi
  801b20:	5d                   	pop    %ebp
  801b21:	c3                   	ret    
	va = fd2data(fd0);
  801b22:	83 ec 0c             	sub    $0xc,%esp
  801b25:	ff 75 f4             	pushl  -0xc(%ebp)
  801b28:	e8 c5 f5 ff ff       	call   8010f2 <fd2data>
  801b2d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b2f:	83 c4 0c             	add    $0xc,%esp
  801b32:	68 07 04 00 00       	push   $0x407
  801b37:	50                   	push   %eax
  801b38:	6a 00                	push   $0x0
  801b3a:	e8 b1 f0 ff ff       	call   800bf0 <sys_page_alloc>
  801b3f:	89 c3                	mov    %eax,%ebx
  801b41:	83 c4 10             	add    $0x10,%esp
  801b44:	85 c0                	test   %eax,%eax
  801b46:	0f 88 8c 00 00 00    	js     801bd8 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b4c:	83 ec 0c             	sub    $0xc,%esp
  801b4f:	ff 75 f0             	pushl  -0x10(%ebp)
  801b52:	e8 9b f5 ff ff       	call   8010f2 <fd2data>
  801b57:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b5e:	50                   	push   %eax
  801b5f:	6a 00                	push   $0x0
  801b61:	56                   	push   %esi
  801b62:	6a 00                	push   $0x0
  801b64:	e8 ca f0 ff ff       	call   800c33 <sys_page_map>
  801b69:	89 c3                	mov    %eax,%ebx
  801b6b:	83 c4 20             	add    $0x20,%esp
  801b6e:	85 c0                	test   %eax,%eax
  801b70:	78 58                	js     801bca <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801b72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b75:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b7b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b80:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801b87:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b8a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b90:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b92:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b95:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801b9c:	83 ec 0c             	sub    $0xc,%esp
  801b9f:	ff 75 f4             	pushl  -0xc(%ebp)
  801ba2:	e8 3b f5 ff ff       	call   8010e2 <fd2num>
  801ba7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801baa:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801bac:	83 c4 04             	add    $0x4,%esp
  801baf:	ff 75 f0             	pushl  -0x10(%ebp)
  801bb2:	e8 2b f5 ff ff       	call   8010e2 <fd2num>
  801bb7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bba:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801bbd:	83 c4 10             	add    $0x10,%esp
  801bc0:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bc5:	e9 4f ff ff ff       	jmp    801b19 <pipe+0x75>
	sys_page_unmap(0, va);
  801bca:	83 ec 08             	sub    $0x8,%esp
  801bcd:	56                   	push   %esi
  801bce:	6a 00                	push   $0x0
  801bd0:	e8 a0 f0 ff ff       	call   800c75 <sys_page_unmap>
  801bd5:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801bd8:	83 ec 08             	sub    $0x8,%esp
  801bdb:	ff 75 f0             	pushl  -0x10(%ebp)
  801bde:	6a 00                	push   $0x0
  801be0:	e8 90 f0 ff ff       	call   800c75 <sys_page_unmap>
  801be5:	83 c4 10             	add    $0x10,%esp
  801be8:	e9 1c ff ff ff       	jmp    801b09 <pipe+0x65>

00801bed <pipeisclosed>:
{
  801bed:	55                   	push   %ebp
  801bee:	89 e5                	mov    %esp,%ebp
  801bf0:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bf3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bf6:	50                   	push   %eax
  801bf7:	ff 75 08             	pushl  0x8(%ebp)
  801bfa:	e8 59 f5 ff ff       	call   801158 <fd_lookup>
  801bff:	83 c4 10             	add    $0x10,%esp
  801c02:	85 c0                	test   %eax,%eax
  801c04:	78 18                	js     801c1e <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801c06:	83 ec 0c             	sub    $0xc,%esp
  801c09:	ff 75 f4             	pushl  -0xc(%ebp)
  801c0c:	e8 e1 f4 ff ff       	call   8010f2 <fd2data>
	return _pipeisclosed(fd, p);
  801c11:	89 c2                	mov    %eax,%edx
  801c13:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c16:	e8 30 fd ff ff       	call   80194b <_pipeisclosed>
  801c1b:	83 c4 10             	add    $0x10,%esp
}
  801c1e:	c9                   	leave  
  801c1f:	c3                   	ret    

00801c20 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c20:	55                   	push   %ebp
  801c21:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c23:	b8 00 00 00 00       	mov    $0x0,%eax
  801c28:	5d                   	pop    %ebp
  801c29:	c3                   	ret    

00801c2a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c2a:	55                   	push   %ebp
  801c2b:	89 e5                	mov    %esp,%ebp
  801c2d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c30:	68 6a 27 80 00       	push   $0x80276a
  801c35:	ff 75 0c             	pushl  0xc(%ebp)
  801c38:	e8 ba eb ff ff       	call   8007f7 <strcpy>
	return 0;
}
  801c3d:	b8 00 00 00 00       	mov    $0x0,%eax
  801c42:	c9                   	leave  
  801c43:	c3                   	ret    

00801c44 <devcons_write>:
{
  801c44:	55                   	push   %ebp
  801c45:	89 e5                	mov    %esp,%ebp
  801c47:	57                   	push   %edi
  801c48:	56                   	push   %esi
  801c49:	53                   	push   %ebx
  801c4a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801c50:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801c55:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801c5b:	eb 2f                	jmp    801c8c <devcons_write+0x48>
		m = n - tot;
  801c5d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c60:	29 f3                	sub    %esi,%ebx
  801c62:	83 fb 7f             	cmp    $0x7f,%ebx
  801c65:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801c6a:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801c6d:	83 ec 04             	sub    $0x4,%esp
  801c70:	53                   	push   %ebx
  801c71:	89 f0                	mov    %esi,%eax
  801c73:	03 45 0c             	add    0xc(%ebp),%eax
  801c76:	50                   	push   %eax
  801c77:	57                   	push   %edi
  801c78:	e8 08 ed ff ff       	call   800985 <memmove>
		sys_cputs(buf, m);
  801c7d:	83 c4 08             	add    $0x8,%esp
  801c80:	53                   	push   %ebx
  801c81:	57                   	push   %edi
  801c82:	e8 ad ee ff ff       	call   800b34 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801c87:	01 de                	add    %ebx,%esi
  801c89:	83 c4 10             	add    $0x10,%esp
  801c8c:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c8f:	72 cc                	jb     801c5d <devcons_write+0x19>
}
  801c91:	89 f0                	mov    %esi,%eax
  801c93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c96:	5b                   	pop    %ebx
  801c97:	5e                   	pop    %esi
  801c98:	5f                   	pop    %edi
  801c99:	5d                   	pop    %ebp
  801c9a:	c3                   	ret    

00801c9b <devcons_read>:
{
  801c9b:	55                   	push   %ebp
  801c9c:	89 e5                	mov    %esp,%ebp
  801c9e:	83 ec 08             	sub    $0x8,%esp
  801ca1:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801ca6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801caa:	75 07                	jne    801cb3 <devcons_read+0x18>
}
  801cac:	c9                   	leave  
  801cad:	c3                   	ret    
		sys_yield();
  801cae:	e8 1e ef ff ff       	call   800bd1 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801cb3:	e8 9a ee ff ff       	call   800b52 <sys_cgetc>
  801cb8:	85 c0                	test   %eax,%eax
  801cba:	74 f2                	je     801cae <devcons_read+0x13>
	if (c < 0)
  801cbc:	85 c0                	test   %eax,%eax
  801cbe:	78 ec                	js     801cac <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  801cc0:	83 f8 04             	cmp    $0x4,%eax
  801cc3:	74 0c                	je     801cd1 <devcons_read+0x36>
	*(char*)vbuf = c;
  801cc5:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cc8:	88 02                	mov    %al,(%edx)
	return 1;
  801cca:	b8 01 00 00 00       	mov    $0x1,%eax
  801ccf:	eb db                	jmp    801cac <devcons_read+0x11>
		return 0;
  801cd1:	b8 00 00 00 00       	mov    $0x0,%eax
  801cd6:	eb d4                	jmp    801cac <devcons_read+0x11>

00801cd8 <cputchar>:
{
  801cd8:	55                   	push   %ebp
  801cd9:	89 e5                	mov    %esp,%ebp
  801cdb:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801cde:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce1:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801ce4:	6a 01                	push   $0x1
  801ce6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ce9:	50                   	push   %eax
  801cea:	e8 45 ee ff ff       	call   800b34 <sys_cputs>
}
  801cef:	83 c4 10             	add    $0x10,%esp
  801cf2:	c9                   	leave  
  801cf3:	c3                   	ret    

00801cf4 <getchar>:
{
  801cf4:	55                   	push   %ebp
  801cf5:	89 e5                	mov    %esp,%ebp
  801cf7:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801cfa:	6a 01                	push   $0x1
  801cfc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cff:	50                   	push   %eax
  801d00:	6a 00                	push   $0x0
  801d02:	e8 c2 f6 ff ff       	call   8013c9 <read>
	if (r < 0)
  801d07:	83 c4 10             	add    $0x10,%esp
  801d0a:	85 c0                	test   %eax,%eax
  801d0c:	78 08                	js     801d16 <getchar+0x22>
	if (r < 1)
  801d0e:	85 c0                	test   %eax,%eax
  801d10:	7e 06                	jle    801d18 <getchar+0x24>
	return c;
  801d12:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801d16:	c9                   	leave  
  801d17:	c3                   	ret    
		return -E_EOF;
  801d18:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801d1d:	eb f7                	jmp    801d16 <getchar+0x22>

00801d1f <iscons>:
{
  801d1f:	55                   	push   %ebp
  801d20:	89 e5                	mov    %esp,%ebp
  801d22:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d25:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d28:	50                   	push   %eax
  801d29:	ff 75 08             	pushl  0x8(%ebp)
  801d2c:	e8 27 f4 ff ff       	call   801158 <fd_lookup>
  801d31:	83 c4 10             	add    $0x10,%esp
  801d34:	85 c0                	test   %eax,%eax
  801d36:	78 11                	js     801d49 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801d38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d3b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d41:	39 10                	cmp    %edx,(%eax)
  801d43:	0f 94 c0             	sete   %al
  801d46:	0f b6 c0             	movzbl %al,%eax
}
  801d49:	c9                   	leave  
  801d4a:	c3                   	ret    

00801d4b <opencons>:
{
  801d4b:	55                   	push   %ebp
  801d4c:	89 e5                	mov    %esp,%ebp
  801d4e:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801d51:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d54:	50                   	push   %eax
  801d55:	e8 af f3 ff ff       	call   801109 <fd_alloc>
  801d5a:	83 c4 10             	add    $0x10,%esp
  801d5d:	85 c0                	test   %eax,%eax
  801d5f:	78 3a                	js     801d9b <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d61:	83 ec 04             	sub    $0x4,%esp
  801d64:	68 07 04 00 00       	push   $0x407
  801d69:	ff 75 f4             	pushl  -0xc(%ebp)
  801d6c:	6a 00                	push   $0x0
  801d6e:	e8 7d ee ff ff       	call   800bf0 <sys_page_alloc>
  801d73:	83 c4 10             	add    $0x10,%esp
  801d76:	85 c0                	test   %eax,%eax
  801d78:	78 21                	js     801d9b <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801d7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d7d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d83:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d85:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d88:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d8f:	83 ec 0c             	sub    $0xc,%esp
  801d92:	50                   	push   %eax
  801d93:	e8 4a f3 ff ff       	call   8010e2 <fd2num>
  801d98:	83 c4 10             	add    $0x10,%esp
}
  801d9b:	c9                   	leave  
  801d9c:	c3                   	ret    

00801d9d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d9d:	55                   	push   %ebp
  801d9e:	89 e5                	mov    %esp,%ebp
  801da0:	56                   	push   %esi
  801da1:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801da2:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801da5:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801dab:	e8 02 ee ff ff       	call   800bb2 <sys_getenvid>
  801db0:	83 ec 0c             	sub    $0xc,%esp
  801db3:	ff 75 0c             	pushl  0xc(%ebp)
  801db6:	ff 75 08             	pushl  0x8(%ebp)
  801db9:	56                   	push   %esi
  801dba:	50                   	push   %eax
  801dbb:	68 78 27 80 00       	push   $0x802778
  801dc0:	e8 13 e4 ff ff       	call   8001d8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801dc5:	83 c4 18             	add    $0x18,%esp
  801dc8:	53                   	push   %ebx
  801dc9:	ff 75 10             	pushl  0x10(%ebp)
  801dcc:	e8 b6 e3 ff ff       	call   800187 <vcprintf>
	cprintf("\n");
  801dd1:	c7 04 24 0f 22 80 00 	movl   $0x80220f,(%esp)
  801dd8:	e8 fb e3 ff ff       	call   8001d8 <cprintf>
  801ddd:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801de0:	cc                   	int3   
  801de1:	eb fd                	jmp    801de0 <_panic+0x43>

00801de3 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801de3:	55                   	push   %ebp
  801de4:	89 e5                	mov    %esp,%ebp
  801de6:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801de9:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801df0:	74 0a                	je     801dfc <set_pgfault_handler+0x19>
			panic("set_pgfault_handler %e",r);
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
	}
       
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801df2:	8b 45 08             	mov    0x8(%ebp),%eax
  801df5:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801dfa:	c9                   	leave  
  801dfb:	c3                   	ret    
		if((r=sys_page_alloc(thisenv->env_id,(void *)UXSTACKTOP-PGSIZE,PTE_P|PTE_W|PTE_U))<0)
  801dfc:	a1 04 40 80 00       	mov    0x804004,%eax
  801e01:	8b 40 48             	mov    0x48(%eax),%eax
  801e04:	83 ec 04             	sub    $0x4,%esp
  801e07:	6a 07                	push   $0x7
  801e09:	68 00 f0 bf ee       	push   $0xeebff000
  801e0e:	50                   	push   %eax
  801e0f:	e8 dc ed ff ff       	call   800bf0 <sys_page_alloc>
  801e14:	83 c4 10             	add    $0x10,%esp
  801e17:	85 c0                	test   %eax,%eax
  801e19:	78 1b                	js     801e36 <set_pgfault_handler+0x53>
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
  801e1b:	a1 04 40 80 00       	mov    0x804004,%eax
  801e20:	8b 40 48             	mov    0x48(%eax),%eax
  801e23:	83 ec 08             	sub    $0x8,%esp
  801e26:	68 48 1e 80 00       	push   $0x801e48
  801e2b:	50                   	push   %eax
  801e2c:	e8 0a ef ff ff       	call   800d3b <sys_env_set_pgfault_upcall>
  801e31:	83 c4 10             	add    $0x10,%esp
  801e34:	eb bc                	jmp    801df2 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler %e",r);
  801e36:	50                   	push   %eax
  801e37:	68 9c 27 80 00       	push   $0x80279c
  801e3c:	6a 22                	push   $0x22
  801e3e:	68 b3 27 80 00       	push   $0x8027b3
  801e43:	e8 55 ff ff ff       	call   801d9d <_panic>

00801e48 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e48:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e49:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e4e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e50:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 48(%esp), %ebp
  801e53:	8b 6c 24 30          	mov    0x30(%esp),%ebp
        subl $4, %ebp
  801e57:	83 ed 04             	sub    $0x4,%ebp
        movl %ebp, 48(%esp)
  801e5a:	89 6c 24 30          	mov    %ebp,0x30(%esp)
        movl 40(%esp), %eax
  801e5e:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl %eax, (%ebp)
  801e62:	89 45 00             	mov    %eax,0x0(%ebp)
	// Restore the trap-time registers.  After you do this, you
 	// can no longer modify any general-purpose registers.
 	// LAB 4: Your code here.
        addl $8, %esp
  801e65:	83 c4 08             	add    $0x8,%esp
        popal
  801e68:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $4, %esp
  801e69:	83 c4 04             	add    $0x4,%esp
        popfl
  801e6c:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  801e6d:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  801e6e:	c3                   	ret    

00801e6f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e6f:	55                   	push   %ebp
  801e70:	89 e5                	mov    %esp,%ebp
  801e72:	56                   	push   %esi
  801e73:	53                   	push   %ebx
  801e74:	8b 75 08             	mov    0x8(%ebp),%esi
  801e77:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e7a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        //	panic("ipc_recv not implemented");
        int r;
       	if(pg!=NULL){
  801e7d:	85 c0                	test   %eax,%eax
  801e7f:	74 3b                	je     801ebc <ipc_recv+0x4d>
	  r = sys_ipc_recv(pg);
  801e81:	83 ec 0c             	sub    $0xc,%esp
  801e84:	50                   	push   %eax
  801e85:	e8 16 ef ff ff       	call   800da0 <sys_ipc_recv>
  801e8a:	83 c4 10             	add    $0x10,%esp
	}else
	  r = sys_ipc_recv((void *)UTOP);
	if(r<0){
  801e8d:	85 c0                	test   %eax,%eax
  801e8f:	78 3d                	js     801ece <ipc_recv+0x5f>
	if(perm_store!=NULL){
		*perm_store = 0;
            }
        	return r;
           }else{
	     if(from_env_store!=NULL)
  801e91:	85 f6                	test   %esi,%esi
  801e93:	74 0a                	je     801e9f <ipc_recv+0x30>
		     *from_env_store = thisenv->env_ipc_from;
  801e95:	a1 04 40 80 00       	mov    0x804004,%eax
  801e9a:	8b 40 74             	mov    0x74(%eax),%eax
  801e9d:	89 06                	mov    %eax,(%esi)
	     if(perm_store != NULL)
  801e9f:	85 db                	test   %ebx,%ebx
  801ea1:	74 0a                	je     801ead <ipc_recv+0x3e>
		     *perm_store = thisenv->env_ipc_perm;
  801ea3:	a1 04 40 80 00       	mov    0x804004,%eax
  801ea8:	8b 40 78             	mov    0x78(%eax),%eax
  801eab:	89 03                	mov    %eax,(%ebx)
	     return thisenv->env_ipc_value;
  801ead:	a1 04 40 80 00       	mov    0x804004,%eax
  801eb2:	8b 40 70             	mov    0x70(%eax),%eax
	   }

}
  801eb5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eb8:	5b                   	pop    %ebx
  801eb9:	5e                   	pop    %esi
  801eba:	5d                   	pop    %ebp
  801ebb:	c3                   	ret    
	  r = sys_ipc_recv((void *)UTOP);
  801ebc:	83 ec 0c             	sub    $0xc,%esp
  801ebf:	68 00 00 c0 ee       	push   $0xeec00000
  801ec4:	e8 d7 ee ff ff       	call   800da0 <sys_ipc_recv>
  801ec9:	83 c4 10             	add    $0x10,%esp
  801ecc:	eb bf                	jmp    801e8d <ipc_recv+0x1e>
	if(from_env_store!=NULL){
  801ece:	85 f6                	test   %esi,%esi
  801ed0:	74 06                	je     801ed8 <ipc_recv+0x69>
	  *from_env_store = 0;
  801ed2:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if(perm_store!=NULL){
  801ed8:	85 db                	test   %ebx,%ebx
  801eda:	74 d9                	je     801eb5 <ipc_recv+0x46>
		*perm_store = 0;
  801edc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ee2:	eb d1                	jmp    801eb5 <ipc_recv+0x46>

00801ee4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ee4:	55                   	push   %ebp
  801ee5:	89 e5                	mov    %esp,%ebp
  801ee7:	57                   	push   %edi
  801ee8:	56                   	push   %esi
  801ee9:	53                   	push   %ebx
  801eea:	83 ec 0c             	sub    $0xc,%esp
  801eed:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ef0:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ef3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if(pg==NULL) pg = (void *)UTOP;
  801ef6:	85 db                	test   %ebx,%ebx
  801ef8:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801efd:	0f 44 d8             	cmove  %eax,%ebx
	while((r=sys_ipc_try_send(to_env,val,pg,perm))<0){
  801f00:	ff 75 14             	pushl  0x14(%ebp)
  801f03:	53                   	push   %ebx
  801f04:	56                   	push   %esi
  801f05:	57                   	push   %edi
  801f06:	e8 72 ee ff ff       	call   800d7d <sys_ipc_try_send>
  801f0b:	83 c4 10             	add    $0x10,%esp
  801f0e:	85 c0                	test   %eax,%eax
  801f10:	79 20                	jns    801f32 <ipc_send+0x4e>
	    if(r!=-E_IPC_NOT_RECV){
  801f12:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f15:	75 07                	jne    801f1e <ipc_send+0x3a>
		    panic("ipc_send:send message failed\n");
	    }
	    sys_yield();
  801f17:	e8 b5 ec ff ff       	call   800bd1 <sys_yield>
  801f1c:	eb e2                	jmp    801f00 <ipc_send+0x1c>
		    panic("ipc_send:send message failed\n");
  801f1e:	83 ec 04             	sub    $0x4,%esp
  801f21:	68 c1 27 80 00       	push   $0x8027c1
  801f26:	6a 43                	push   $0x43
  801f28:	68 df 27 80 00       	push   $0x8027df
  801f2d:	e8 6b fe ff ff       	call   801d9d <_panic>
	}

}
  801f32:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f35:	5b                   	pop    %ebx
  801f36:	5e                   	pop    %esi
  801f37:	5f                   	pop    %edi
  801f38:	5d                   	pop    %ebp
  801f39:	c3                   	ret    

00801f3a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f3a:	55                   	push   %ebp
  801f3b:	89 e5                	mov    %esp,%ebp
  801f3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f40:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f45:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f48:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f4e:	8b 52 50             	mov    0x50(%edx),%edx
  801f51:	39 ca                	cmp    %ecx,%edx
  801f53:	74 11                	je     801f66 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801f55:	83 c0 01             	add    $0x1,%eax
  801f58:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f5d:	75 e6                	jne    801f45 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801f5f:	b8 00 00 00 00       	mov    $0x0,%eax
  801f64:	eb 0b                	jmp    801f71 <ipc_find_env+0x37>
			return envs[i].env_id;
  801f66:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f69:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f6e:	8b 40 48             	mov    0x48(%eax),%eax
}
  801f71:	5d                   	pop    %ebp
  801f72:	c3                   	ret    

00801f73 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f73:	55                   	push   %ebp
  801f74:	89 e5                	mov    %esp,%ebp
  801f76:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f79:	89 d0                	mov    %edx,%eax
  801f7b:	c1 e8 16             	shr    $0x16,%eax
  801f7e:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f85:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801f8a:	f6 c1 01             	test   $0x1,%cl
  801f8d:	74 1d                	je     801fac <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801f8f:	c1 ea 0c             	shr    $0xc,%edx
  801f92:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f99:	f6 c2 01             	test   $0x1,%dl
  801f9c:	74 0e                	je     801fac <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f9e:	c1 ea 0c             	shr    $0xc,%edx
  801fa1:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fa8:	ef 
  801fa9:	0f b7 c0             	movzwl %ax,%eax
}
  801fac:	5d                   	pop    %ebp
  801fad:	c3                   	ret    
  801fae:	66 90                	xchg   %ax,%ax

00801fb0 <__udivdi3>:
  801fb0:	55                   	push   %ebp
  801fb1:	57                   	push   %edi
  801fb2:	56                   	push   %esi
  801fb3:	53                   	push   %ebx
  801fb4:	83 ec 1c             	sub    $0x1c,%esp
  801fb7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801fbb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801fbf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801fc3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801fc7:	85 d2                	test   %edx,%edx
  801fc9:	75 35                	jne    802000 <__udivdi3+0x50>
  801fcb:	39 f3                	cmp    %esi,%ebx
  801fcd:	0f 87 bd 00 00 00    	ja     802090 <__udivdi3+0xe0>
  801fd3:	85 db                	test   %ebx,%ebx
  801fd5:	89 d9                	mov    %ebx,%ecx
  801fd7:	75 0b                	jne    801fe4 <__udivdi3+0x34>
  801fd9:	b8 01 00 00 00       	mov    $0x1,%eax
  801fde:	31 d2                	xor    %edx,%edx
  801fe0:	f7 f3                	div    %ebx
  801fe2:	89 c1                	mov    %eax,%ecx
  801fe4:	31 d2                	xor    %edx,%edx
  801fe6:	89 f0                	mov    %esi,%eax
  801fe8:	f7 f1                	div    %ecx
  801fea:	89 c6                	mov    %eax,%esi
  801fec:	89 e8                	mov    %ebp,%eax
  801fee:	89 f7                	mov    %esi,%edi
  801ff0:	f7 f1                	div    %ecx
  801ff2:	89 fa                	mov    %edi,%edx
  801ff4:	83 c4 1c             	add    $0x1c,%esp
  801ff7:	5b                   	pop    %ebx
  801ff8:	5e                   	pop    %esi
  801ff9:	5f                   	pop    %edi
  801ffa:	5d                   	pop    %ebp
  801ffb:	c3                   	ret    
  801ffc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802000:	39 f2                	cmp    %esi,%edx
  802002:	77 7c                	ja     802080 <__udivdi3+0xd0>
  802004:	0f bd fa             	bsr    %edx,%edi
  802007:	83 f7 1f             	xor    $0x1f,%edi
  80200a:	0f 84 98 00 00 00    	je     8020a8 <__udivdi3+0xf8>
  802010:	89 f9                	mov    %edi,%ecx
  802012:	b8 20 00 00 00       	mov    $0x20,%eax
  802017:	29 f8                	sub    %edi,%eax
  802019:	d3 e2                	shl    %cl,%edx
  80201b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80201f:	89 c1                	mov    %eax,%ecx
  802021:	89 da                	mov    %ebx,%edx
  802023:	d3 ea                	shr    %cl,%edx
  802025:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802029:	09 d1                	or     %edx,%ecx
  80202b:	89 f2                	mov    %esi,%edx
  80202d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802031:	89 f9                	mov    %edi,%ecx
  802033:	d3 e3                	shl    %cl,%ebx
  802035:	89 c1                	mov    %eax,%ecx
  802037:	d3 ea                	shr    %cl,%edx
  802039:	89 f9                	mov    %edi,%ecx
  80203b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80203f:	d3 e6                	shl    %cl,%esi
  802041:	89 eb                	mov    %ebp,%ebx
  802043:	89 c1                	mov    %eax,%ecx
  802045:	d3 eb                	shr    %cl,%ebx
  802047:	09 de                	or     %ebx,%esi
  802049:	89 f0                	mov    %esi,%eax
  80204b:	f7 74 24 08          	divl   0x8(%esp)
  80204f:	89 d6                	mov    %edx,%esi
  802051:	89 c3                	mov    %eax,%ebx
  802053:	f7 64 24 0c          	mull   0xc(%esp)
  802057:	39 d6                	cmp    %edx,%esi
  802059:	72 0c                	jb     802067 <__udivdi3+0xb7>
  80205b:	89 f9                	mov    %edi,%ecx
  80205d:	d3 e5                	shl    %cl,%ebp
  80205f:	39 c5                	cmp    %eax,%ebp
  802061:	73 5d                	jae    8020c0 <__udivdi3+0x110>
  802063:	39 d6                	cmp    %edx,%esi
  802065:	75 59                	jne    8020c0 <__udivdi3+0x110>
  802067:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80206a:	31 ff                	xor    %edi,%edi
  80206c:	89 fa                	mov    %edi,%edx
  80206e:	83 c4 1c             	add    $0x1c,%esp
  802071:	5b                   	pop    %ebx
  802072:	5e                   	pop    %esi
  802073:	5f                   	pop    %edi
  802074:	5d                   	pop    %ebp
  802075:	c3                   	ret    
  802076:	8d 76 00             	lea    0x0(%esi),%esi
  802079:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802080:	31 ff                	xor    %edi,%edi
  802082:	31 c0                	xor    %eax,%eax
  802084:	89 fa                	mov    %edi,%edx
  802086:	83 c4 1c             	add    $0x1c,%esp
  802089:	5b                   	pop    %ebx
  80208a:	5e                   	pop    %esi
  80208b:	5f                   	pop    %edi
  80208c:	5d                   	pop    %ebp
  80208d:	c3                   	ret    
  80208e:	66 90                	xchg   %ax,%ax
  802090:	31 ff                	xor    %edi,%edi
  802092:	89 e8                	mov    %ebp,%eax
  802094:	89 f2                	mov    %esi,%edx
  802096:	f7 f3                	div    %ebx
  802098:	89 fa                	mov    %edi,%edx
  80209a:	83 c4 1c             	add    $0x1c,%esp
  80209d:	5b                   	pop    %ebx
  80209e:	5e                   	pop    %esi
  80209f:	5f                   	pop    %edi
  8020a0:	5d                   	pop    %ebp
  8020a1:	c3                   	ret    
  8020a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020a8:	39 f2                	cmp    %esi,%edx
  8020aa:	72 06                	jb     8020b2 <__udivdi3+0x102>
  8020ac:	31 c0                	xor    %eax,%eax
  8020ae:	39 eb                	cmp    %ebp,%ebx
  8020b0:	77 d2                	ja     802084 <__udivdi3+0xd4>
  8020b2:	b8 01 00 00 00       	mov    $0x1,%eax
  8020b7:	eb cb                	jmp    802084 <__udivdi3+0xd4>
  8020b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020c0:	89 d8                	mov    %ebx,%eax
  8020c2:	31 ff                	xor    %edi,%edi
  8020c4:	eb be                	jmp    802084 <__udivdi3+0xd4>
  8020c6:	66 90                	xchg   %ax,%ax
  8020c8:	66 90                	xchg   %ax,%ax
  8020ca:	66 90                	xchg   %ax,%ax
  8020cc:	66 90                	xchg   %ax,%ax
  8020ce:	66 90                	xchg   %ax,%ax

008020d0 <__umoddi3>:
  8020d0:	55                   	push   %ebp
  8020d1:	57                   	push   %edi
  8020d2:	56                   	push   %esi
  8020d3:	53                   	push   %ebx
  8020d4:	83 ec 1c             	sub    $0x1c,%esp
  8020d7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  8020db:	8b 74 24 30          	mov    0x30(%esp),%esi
  8020df:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8020e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020e7:	85 ed                	test   %ebp,%ebp
  8020e9:	89 f0                	mov    %esi,%eax
  8020eb:	89 da                	mov    %ebx,%edx
  8020ed:	75 19                	jne    802108 <__umoddi3+0x38>
  8020ef:	39 df                	cmp    %ebx,%edi
  8020f1:	0f 86 b1 00 00 00    	jbe    8021a8 <__umoddi3+0xd8>
  8020f7:	f7 f7                	div    %edi
  8020f9:	89 d0                	mov    %edx,%eax
  8020fb:	31 d2                	xor    %edx,%edx
  8020fd:	83 c4 1c             	add    $0x1c,%esp
  802100:	5b                   	pop    %ebx
  802101:	5e                   	pop    %esi
  802102:	5f                   	pop    %edi
  802103:	5d                   	pop    %ebp
  802104:	c3                   	ret    
  802105:	8d 76 00             	lea    0x0(%esi),%esi
  802108:	39 dd                	cmp    %ebx,%ebp
  80210a:	77 f1                	ja     8020fd <__umoddi3+0x2d>
  80210c:	0f bd cd             	bsr    %ebp,%ecx
  80210f:	83 f1 1f             	xor    $0x1f,%ecx
  802112:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802116:	0f 84 b4 00 00 00    	je     8021d0 <__umoddi3+0x100>
  80211c:	b8 20 00 00 00       	mov    $0x20,%eax
  802121:	89 c2                	mov    %eax,%edx
  802123:	8b 44 24 04          	mov    0x4(%esp),%eax
  802127:	29 c2                	sub    %eax,%edx
  802129:	89 c1                	mov    %eax,%ecx
  80212b:	89 f8                	mov    %edi,%eax
  80212d:	d3 e5                	shl    %cl,%ebp
  80212f:	89 d1                	mov    %edx,%ecx
  802131:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802135:	d3 e8                	shr    %cl,%eax
  802137:	09 c5                	or     %eax,%ebp
  802139:	8b 44 24 04          	mov    0x4(%esp),%eax
  80213d:	89 c1                	mov    %eax,%ecx
  80213f:	d3 e7                	shl    %cl,%edi
  802141:	89 d1                	mov    %edx,%ecx
  802143:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802147:	89 df                	mov    %ebx,%edi
  802149:	d3 ef                	shr    %cl,%edi
  80214b:	89 c1                	mov    %eax,%ecx
  80214d:	89 f0                	mov    %esi,%eax
  80214f:	d3 e3                	shl    %cl,%ebx
  802151:	89 d1                	mov    %edx,%ecx
  802153:	89 fa                	mov    %edi,%edx
  802155:	d3 e8                	shr    %cl,%eax
  802157:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80215c:	09 d8                	or     %ebx,%eax
  80215e:	f7 f5                	div    %ebp
  802160:	d3 e6                	shl    %cl,%esi
  802162:	89 d1                	mov    %edx,%ecx
  802164:	f7 64 24 08          	mull   0x8(%esp)
  802168:	39 d1                	cmp    %edx,%ecx
  80216a:	89 c3                	mov    %eax,%ebx
  80216c:	89 d7                	mov    %edx,%edi
  80216e:	72 06                	jb     802176 <__umoddi3+0xa6>
  802170:	75 0e                	jne    802180 <__umoddi3+0xb0>
  802172:	39 c6                	cmp    %eax,%esi
  802174:	73 0a                	jae    802180 <__umoddi3+0xb0>
  802176:	2b 44 24 08          	sub    0x8(%esp),%eax
  80217a:	19 ea                	sbb    %ebp,%edx
  80217c:	89 d7                	mov    %edx,%edi
  80217e:	89 c3                	mov    %eax,%ebx
  802180:	89 ca                	mov    %ecx,%edx
  802182:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  802187:	29 de                	sub    %ebx,%esi
  802189:	19 fa                	sbb    %edi,%edx
  80218b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80218f:	89 d0                	mov    %edx,%eax
  802191:	d3 e0                	shl    %cl,%eax
  802193:	89 d9                	mov    %ebx,%ecx
  802195:	d3 ee                	shr    %cl,%esi
  802197:	d3 ea                	shr    %cl,%edx
  802199:	09 f0                	or     %esi,%eax
  80219b:	83 c4 1c             	add    $0x1c,%esp
  80219e:	5b                   	pop    %ebx
  80219f:	5e                   	pop    %esi
  8021a0:	5f                   	pop    %edi
  8021a1:	5d                   	pop    %ebp
  8021a2:	c3                   	ret    
  8021a3:	90                   	nop
  8021a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021a8:	85 ff                	test   %edi,%edi
  8021aa:	89 f9                	mov    %edi,%ecx
  8021ac:	75 0b                	jne    8021b9 <__umoddi3+0xe9>
  8021ae:	b8 01 00 00 00       	mov    $0x1,%eax
  8021b3:	31 d2                	xor    %edx,%edx
  8021b5:	f7 f7                	div    %edi
  8021b7:	89 c1                	mov    %eax,%ecx
  8021b9:	89 d8                	mov    %ebx,%eax
  8021bb:	31 d2                	xor    %edx,%edx
  8021bd:	f7 f1                	div    %ecx
  8021bf:	89 f0                	mov    %esi,%eax
  8021c1:	f7 f1                	div    %ecx
  8021c3:	e9 31 ff ff ff       	jmp    8020f9 <__umoddi3+0x29>
  8021c8:	90                   	nop
  8021c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021d0:	39 dd                	cmp    %ebx,%ebp
  8021d2:	72 08                	jb     8021dc <__umoddi3+0x10c>
  8021d4:	39 f7                	cmp    %esi,%edi
  8021d6:	0f 87 21 ff ff ff    	ja     8020fd <__umoddi3+0x2d>
  8021dc:	89 da                	mov    %ebx,%edx
  8021de:	89 f0                	mov    %esi,%eax
  8021e0:	29 f8                	sub    %edi,%eax
  8021e2:	19 ea                	sbb    %ebp,%edx
  8021e4:	e9 14 ff ff ff       	jmp    8020fd <__umoddi3+0x2d>
