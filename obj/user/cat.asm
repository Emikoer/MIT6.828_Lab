
obj/user/cat.debug:     file format elf32-i386


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
  80002c:	e8 fe 00 00 00       	call   80012f <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <cat>:

char buf[8192];

void
cat(int f, char *s)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  80003b:	83 ec 04             	sub    $0x4,%esp
  80003e:	68 00 20 00 00       	push   $0x2000
  800043:	68 20 40 80 00       	push   $0x804020
  800048:	56                   	push   %esi
  800049:	e8 0c 11 00 00       	call   80115a <read>
  80004e:	89 c3                	mov    %eax,%ebx
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	7e 2f                	jle    800086 <cat+0x53>
		if ((r = write(1, buf, n)) != n)
  800057:	83 ec 04             	sub    $0x4,%esp
  80005a:	53                   	push   %ebx
  80005b:	68 20 40 80 00       	push   $0x804020
  800060:	6a 01                	push   $0x1
  800062:	e8 c1 11 00 00       	call   801228 <write>
  800067:	83 c4 10             	add    $0x10,%esp
  80006a:	39 c3                	cmp    %eax,%ebx
  80006c:	74 cd                	je     80003b <cat+0x8>
			panic("write error copying %s: %e", s, r);
  80006e:	83 ec 0c             	sub    $0xc,%esp
  800071:	50                   	push   %eax
  800072:	ff 75 0c             	pushl  0xc(%ebp)
  800075:	68 e0 1f 80 00       	push   $0x801fe0
  80007a:	6a 0d                	push   $0xd
  80007c:	68 fb 1f 80 00       	push   $0x801ffb
  800081:	e8 09 01 00 00       	call   80018f <_panic>
	if (n < 0)
  800086:	85 c0                	test   %eax,%eax
  800088:	78 07                	js     800091 <cat+0x5e>
		panic("error reading %s: %e", s, n);
}
  80008a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008d:	5b                   	pop    %ebx
  80008e:	5e                   	pop    %esi
  80008f:	5d                   	pop    %ebp
  800090:	c3                   	ret    
		panic("error reading %s: %e", s, n);
  800091:	83 ec 0c             	sub    $0xc,%esp
  800094:	50                   	push   %eax
  800095:	ff 75 0c             	pushl  0xc(%ebp)
  800098:	68 06 20 80 00       	push   $0x802006
  80009d:	6a 0f                	push   $0xf
  80009f:	68 fb 1f 80 00       	push   $0x801ffb
  8000a4:	e8 e6 00 00 00       	call   80018f <_panic>

008000a9 <umain>:

void
umain(int argc, char **argv)
{
  8000a9:	55                   	push   %ebp
  8000aa:	89 e5                	mov    %esp,%ebp
  8000ac:	57                   	push   %edi
  8000ad:	56                   	push   %esi
  8000ae:	53                   	push   %ebx
  8000af:	83 ec 0c             	sub    $0xc,%esp
  8000b2:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int f, i;

	binaryname = "cat";
  8000b5:	c7 05 00 30 80 00 1b 	movl   $0x80201b,0x803000
  8000bc:	20 80 00 
	if (argc == 1)
		cat(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  8000bf:	bb 01 00 00 00       	mov    $0x1,%ebx
	if (argc == 1)
  8000c4:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8000c8:	75 31                	jne    8000fb <umain+0x52>
		cat(0, "<stdin>");
  8000ca:	83 ec 08             	sub    $0x8,%esp
  8000cd:	68 1f 20 80 00       	push   $0x80201f
  8000d2:	6a 00                	push   $0x0
  8000d4:	e8 5a ff ff ff       	call   800033 <cat>
  8000d9:	83 c4 10             	add    $0x10,%esp
			else {
				cat(f, argv[i]);
				close(f);
			}
		}
}
  8000dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000df:	5b                   	pop    %ebx
  8000e0:	5e                   	pop    %esi
  8000e1:	5f                   	pop    %edi
  8000e2:	5d                   	pop    %ebp
  8000e3:	c3                   	ret    
				printf("can't open %s: %e\n", argv[i], f);
  8000e4:	83 ec 04             	sub    $0x4,%esp
  8000e7:	50                   	push   %eax
  8000e8:	ff 34 9f             	pushl  (%edi,%ebx,4)
  8000eb:	68 27 20 80 00       	push   $0x802027
  8000f0:	e8 6e 16 00 00       	call   801763 <printf>
  8000f5:	83 c4 10             	add    $0x10,%esp
		for (i = 1; i < argc; i++) {
  8000f8:	83 c3 01             	add    $0x1,%ebx
  8000fb:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  8000fe:	7d dc                	jge    8000dc <umain+0x33>
			f = open(argv[i], O_RDONLY);
  800100:	83 ec 08             	sub    $0x8,%esp
  800103:	6a 00                	push   $0x0
  800105:	ff 34 9f             	pushl  (%edi,%ebx,4)
  800108:	e8 b2 14 00 00       	call   8015bf <open>
  80010d:	89 c6                	mov    %eax,%esi
			if (f < 0)
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	85 c0                	test   %eax,%eax
  800114:	78 ce                	js     8000e4 <umain+0x3b>
				cat(f, argv[i]);
  800116:	83 ec 08             	sub    $0x8,%esp
  800119:	ff 34 9f             	pushl  (%edi,%ebx,4)
  80011c:	50                   	push   %eax
  80011d:	e8 11 ff ff ff       	call   800033 <cat>
				close(f);
  800122:	89 34 24             	mov    %esi,(%esp)
  800125:	e8 f4 0e 00 00       	call   80101e <close>
  80012a:	83 c4 10             	add    $0x10,%esp
  80012d:	eb c9                	jmp    8000f8 <umain+0x4f>

0080012f <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80012f:	55                   	push   %ebp
  800130:	89 e5                	mov    %esp,%ebp
  800132:	56                   	push   %esi
  800133:	53                   	push   %ebx
  800134:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800137:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80013a:	e8 05 0b 00 00       	call   800c44 <sys_getenvid>
  80013f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800144:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800147:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80014c:	a3 20 60 80 00       	mov    %eax,0x806020
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800151:	85 db                	test   %ebx,%ebx
  800153:	7e 07                	jle    80015c <libmain+0x2d>
		binaryname = argv[0];
  800155:	8b 06                	mov    (%esi),%eax
  800157:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80015c:	83 ec 08             	sub    $0x8,%esp
  80015f:	56                   	push   %esi
  800160:	53                   	push   %ebx
  800161:	e8 43 ff ff ff       	call   8000a9 <umain>

	// exit gracefully
	exit();
  800166:	e8 0a 00 00 00       	call   800175 <exit>
}
  80016b:	83 c4 10             	add    $0x10,%esp
  80016e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800171:	5b                   	pop    %ebx
  800172:	5e                   	pop    %esi
  800173:	5d                   	pop    %ebp
  800174:	c3                   	ret    

00800175 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800175:	55                   	push   %ebp
  800176:	89 e5                	mov    %esp,%ebp
  800178:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80017b:	e8 c9 0e 00 00       	call   801049 <close_all>
	sys_env_destroy(0);
  800180:	83 ec 0c             	sub    $0xc,%esp
  800183:	6a 00                	push   $0x0
  800185:	e8 79 0a 00 00       	call   800c03 <sys_env_destroy>
}
  80018a:	83 c4 10             	add    $0x10,%esp
  80018d:	c9                   	leave  
  80018e:	c3                   	ret    

0080018f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80018f:	55                   	push   %ebp
  800190:	89 e5                	mov    %esp,%ebp
  800192:	56                   	push   %esi
  800193:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800194:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800197:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80019d:	e8 a2 0a 00 00       	call   800c44 <sys_getenvid>
  8001a2:	83 ec 0c             	sub    $0xc,%esp
  8001a5:	ff 75 0c             	pushl  0xc(%ebp)
  8001a8:	ff 75 08             	pushl  0x8(%ebp)
  8001ab:	56                   	push   %esi
  8001ac:	50                   	push   %eax
  8001ad:	68 44 20 80 00       	push   $0x802044
  8001b2:	e8 b3 00 00 00       	call   80026a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001b7:	83 c4 18             	add    $0x18,%esp
  8001ba:	53                   	push   %ebx
  8001bb:	ff 75 10             	pushl  0x10(%ebp)
  8001be:	e8 56 00 00 00       	call   800219 <vcprintf>
	cprintf("\n");
  8001c3:	c7 04 24 67 24 80 00 	movl   $0x802467,(%esp)
  8001ca:	e8 9b 00 00 00       	call   80026a <cprintf>
  8001cf:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d2:	cc                   	int3   
  8001d3:	eb fd                	jmp    8001d2 <_panic+0x43>

008001d5 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d5:	55                   	push   %ebp
  8001d6:	89 e5                	mov    %esp,%ebp
  8001d8:	53                   	push   %ebx
  8001d9:	83 ec 04             	sub    $0x4,%esp
  8001dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001df:	8b 13                	mov    (%ebx),%edx
  8001e1:	8d 42 01             	lea    0x1(%edx),%eax
  8001e4:	89 03                	mov    %eax,(%ebx)
  8001e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001e9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001ed:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f2:	74 09                	je     8001fd <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001f4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001fb:	c9                   	leave  
  8001fc:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001fd:	83 ec 08             	sub    $0x8,%esp
  800200:	68 ff 00 00 00       	push   $0xff
  800205:	8d 43 08             	lea    0x8(%ebx),%eax
  800208:	50                   	push   %eax
  800209:	e8 b8 09 00 00       	call   800bc6 <sys_cputs>
		b->idx = 0;
  80020e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800214:	83 c4 10             	add    $0x10,%esp
  800217:	eb db                	jmp    8001f4 <putch+0x1f>

00800219 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800219:	55                   	push   %ebp
  80021a:	89 e5                	mov    %esp,%ebp
  80021c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800222:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800229:	00 00 00 
	b.cnt = 0;
  80022c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800233:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800236:	ff 75 0c             	pushl  0xc(%ebp)
  800239:	ff 75 08             	pushl  0x8(%ebp)
  80023c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800242:	50                   	push   %eax
  800243:	68 d5 01 80 00       	push   $0x8001d5
  800248:	e8 1a 01 00 00       	call   800367 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80024d:	83 c4 08             	add    $0x8,%esp
  800250:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800256:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80025c:	50                   	push   %eax
  80025d:	e8 64 09 00 00       	call   800bc6 <sys_cputs>

	return b.cnt;
}
  800262:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800268:	c9                   	leave  
  800269:	c3                   	ret    

0080026a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80026a:	55                   	push   %ebp
  80026b:	89 e5                	mov    %esp,%ebp
  80026d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800270:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800273:	50                   	push   %eax
  800274:	ff 75 08             	pushl  0x8(%ebp)
  800277:	e8 9d ff ff ff       	call   800219 <vcprintf>
	va_end(ap);

	return cnt;
}
  80027c:	c9                   	leave  
  80027d:	c3                   	ret    

0080027e <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80027e:	55                   	push   %ebp
  80027f:	89 e5                	mov    %esp,%ebp
  800281:	57                   	push   %edi
  800282:	56                   	push   %esi
  800283:	53                   	push   %ebx
  800284:	83 ec 1c             	sub    $0x1c,%esp
  800287:	89 c7                	mov    %eax,%edi
  800289:	89 d6                	mov    %edx,%esi
  80028b:	8b 45 08             	mov    0x8(%ebp),%eax
  80028e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800291:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800294:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800297:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80029a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80029f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002a2:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002a5:	39 d3                	cmp    %edx,%ebx
  8002a7:	72 05                	jb     8002ae <printnum+0x30>
  8002a9:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002ac:	77 7a                	ja     800328 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002ae:	83 ec 0c             	sub    $0xc,%esp
  8002b1:	ff 75 18             	pushl  0x18(%ebp)
  8002b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8002b7:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002ba:	53                   	push   %ebx
  8002bb:	ff 75 10             	pushl  0x10(%ebp)
  8002be:	83 ec 08             	sub    $0x8,%esp
  8002c1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c4:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c7:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ca:	ff 75 d8             	pushl  -0x28(%ebp)
  8002cd:	e8 be 1a 00 00       	call   801d90 <__udivdi3>
  8002d2:	83 c4 18             	add    $0x18,%esp
  8002d5:	52                   	push   %edx
  8002d6:	50                   	push   %eax
  8002d7:	89 f2                	mov    %esi,%edx
  8002d9:	89 f8                	mov    %edi,%eax
  8002db:	e8 9e ff ff ff       	call   80027e <printnum>
  8002e0:	83 c4 20             	add    $0x20,%esp
  8002e3:	eb 13                	jmp    8002f8 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e5:	83 ec 08             	sub    $0x8,%esp
  8002e8:	56                   	push   %esi
  8002e9:	ff 75 18             	pushl  0x18(%ebp)
  8002ec:	ff d7                	call   *%edi
  8002ee:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002f1:	83 eb 01             	sub    $0x1,%ebx
  8002f4:	85 db                	test   %ebx,%ebx
  8002f6:	7f ed                	jg     8002e5 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002f8:	83 ec 08             	sub    $0x8,%esp
  8002fb:	56                   	push   %esi
  8002fc:	83 ec 04             	sub    $0x4,%esp
  8002ff:	ff 75 e4             	pushl  -0x1c(%ebp)
  800302:	ff 75 e0             	pushl  -0x20(%ebp)
  800305:	ff 75 dc             	pushl  -0x24(%ebp)
  800308:	ff 75 d8             	pushl  -0x28(%ebp)
  80030b:	e8 a0 1b 00 00       	call   801eb0 <__umoddi3>
  800310:	83 c4 14             	add    $0x14,%esp
  800313:	0f be 80 67 20 80 00 	movsbl 0x802067(%eax),%eax
  80031a:	50                   	push   %eax
  80031b:	ff d7                	call   *%edi
}
  80031d:	83 c4 10             	add    $0x10,%esp
  800320:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800323:	5b                   	pop    %ebx
  800324:	5e                   	pop    %esi
  800325:	5f                   	pop    %edi
  800326:	5d                   	pop    %ebp
  800327:	c3                   	ret    
  800328:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80032b:	eb c4                	jmp    8002f1 <printnum+0x73>

0080032d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80032d:	55                   	push   %ebp
  80032e:	89 e5                	mov    %esp,%ebp
  800330:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800333:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800337:	8b 10                	mov    (%eax),%edx
  800339:	3b 50 04             	cmp    0x4(%eax),%edx
  80033c:	73 0a                	jae    800348 <sprintputch+0x1b>
		*b->buf++ = ch;
  80033e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800341:	89 08                	mov    %ecx,(%eax)
  800343:	8b 45 08             	mov    0x8(%ebp),%eax
  800346:	88 02                	mov    %al,(%edx)
}
  800348:	5d                   	pop    %ebp
  800349:	c3                   	ret    

0080034a <printfmt>:
{
  80034a:	55                   	push   %ebp
  80034b:	89 e5                	mov    %esp,%ebp
  80034d:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800350:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800353:	50                   	push   %eax
  800354:	ff 75 10             	pushl  0x10(%ebp)
  800357:	ff 75 0c             	pushl  0xc(%ebp)
  80035a:	ff 75 08             	pushl  0x8(%ebp)
  80035d:	e8 05 00 00 00       	call   800367 <vprintfmt>
}
  800362:	83 c4 10             	add    $0x10,%esp
  800365:	c9                   	leave  
  800366:	c3                   	ret    

00800367 <vprintfmt>:
{
  800367:	55                   	push   %ebp
  800368:	89 e5                	mov    %esp,%ebp
  80036a:	57                   	push   %edi
  80036b:	56                   	push   %esi
  80036c:	53                   	push   %ebx
  80036d:	83 ec 2c             	sub    $0x2c,%esp
  800370:	8b 75 08             	mov    0x8(%ebp),%esi
  800373:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800376:	8b 7d 10             	mov    0x10(%ebp),%edi
  800379:	e9 c1 03 00 00       	jmp    80073f <vprintfmt+0x3d8>
		padc = ' ';
  80037e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800382:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800389:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800390:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800397:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80039c:	8d 47 01             	lea    0x1(%edi),%eax
  80039f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003a2:	0f b6 17             	movzbl (%edi),%edx
  8003a5:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003a8:	3c 55                	cmp    $0x55,%al
  8003aa:	0f 87 12 04 00 00    	ja     8007c2 <vprintfmt+0x45b>
  8003b0:	0f b6 c0             	movzbl %al,%eax
  8003b3:	ff 24 85 a0 21 80 00 	jmp    *0x8021a0(,%eax,4)
  8003ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8003bd:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8003c1:	eb d9                	jmp    80039c <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8003c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  8003c6:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003ca:	eb d0                	jmp    80039c <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8003cc:	0f b6 d2             	movzbl %dl,%edx
  8003cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8003d7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003da:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003dd:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003e1:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003e4:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003e7:	83 f9 09             	cmp    $0x9,%ecx
  8003ea:	77 55                	ja     800441 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  8003ec:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003ef:	eb e9                	jmp    8003da <vprintfmt+0x73>
			precision = va_arg(ap, int);
  8003f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f4:	8b 00                	mov    (%eax),%eax
  8003f6:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fc:	8d 40 04             	lea    0x4(%eax),%eax
  8003ff:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800402:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800405:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800409:	79 91                	jns    80039c <vprintfmt+0x35>
				width = precision, precision = -1;
  80040b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80040e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800411:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800418:	eb 82                	jmp    80039c <vprintfmt+0x35>
  80041a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80041d:	85 c0                	test   %eax,%eax
  80041f:	ba 00 00 00 00       	mov    $0x0,%edx
  800424:	0f 49 d0             	cmovns %eax,%edx
  800427:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80042a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80042d:	e9 6a ff ff ff       	jmp    80039c <vprintfmt+0x35>
  800432:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800435:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80043c:	e9 5b ff ff ff       	jmp    80039c <vprintfmt+0x35>
  800441:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800444:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800447:	eb bc                	jmp    800405 <vprintfmt+0x9e>
			lflag++;
  800449:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80044c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80044f:	e9 48 ff ff ff       	jmp    80039c <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  800454:	8b 45 14             	mov    0x14(%ebp),%eax
  800457:	8d 78 04             	lea    0x4(%eax),%edi
  80045a:	83 ec 08             	sub    $0x8,%esp
  80045d:	53                   	push   %ebx
  80045e:	ff 30                	pushl  (%eax)
  800460:	ff d6                	call   *%esi
			break;
  800462:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800465:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800468:	e9 cf 02 00 00       	jmp    80073c <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  80046d:	8b 45 14             	mov    0x14(%ebp),%eax
  800470:	8d 78 04             	lea    0x4(%eax),%edi
  800473:	8b 00                	mov    (%eax),%eax
  800475:	99                   	cltd   
  800476:	31 d0                	xor    %edx,%eax
  800478:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80047a:	83 f8 0f             	cmp    $0xf,%eax
  80047d:	7f 23                	jg     8004a2 <vprintfmt+0x13b>
  80047f:	8b 14 85 00 23 80 00 	mov    0x802300(,%eax,4),%edx
  800486:	85 d2                	test   %edx,%edx
  800488:	74 18                	je     8004a2 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  80048a:	52                   	push   %edx
  80048b:	68 35 24 80 00       	push   $0x802435
  800490:	53                   	push   %ebx
  800491:	56                   	push   %esi
  800492:	e8 b3 fe ff ff       	call   80034a <printfmt>
  800497:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80049a:	89 7d 14             	mov    %edi,0x14(%ebp)
  80049d:	e9 9a 02 00 00       	jmp    80073c <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  8004a2:	50                   	push   %eax
  8004a3:	68 7f 20 80 00       	push   $0x80207f
  8004a8:	53                   	push   %ebx
  8004a9:	56                   	push   %esi
  8004aa:	e8 9b fe ff ff       	call   80034a <printfmt>
  8004af:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004b2:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8004b5:	e9 82 02 00 00       	jmp    80073c <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  8004ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bd:	83 c0 04             	add    $0x4,%eax
  8004c0:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8004c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004c8:	85 ff                	test   %edi,%edi
  8004ca:	b8 78 20 80 00       	mov    $0x802078,%eax
  8004cf:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004d2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004d6:	0f 8e bd 00 00 00    	jle    800599 <vprintfmt+0x232>
  8004dc:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004e0:	75 0e                	jne    8004f0 <vprintfmt+0x189>
  8004e2:	89 75 08             	mov    %esi,0x8(%ebp)
  8004e5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004e8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004eb:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004ee:	eb 6d                	jmp    80055d <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f0:	83 ec 08             	sub    $0x8,%esp
  8004f3:	ff 75 d0             	pushl  -0x30(%ebp)
  8004f6:	57                   	push   %edi
  8004f7:	e8 6e 03 00 00       	call   80086a <strnlen>
  8004fc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004ff:	29 c1                	sub    %eax,%ecx
  800501:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800504:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800507:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80050b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80050e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800511:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800513:	eb 0f                	jmp    800524 <vprintfmt+0x1bd>
					putch(padc, putdat);
  800515:	83 ec 08             	sub    $0x8,%esp
  800518:	53                   	push   %ebx
  800519:	ff 75 e0             	pushl  -0x20(%ebp)
  80051c:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80051e:	83 ef 01             	sub    $0x1,%edi
  800521:	83 c4 10             	add    $0x10,%esp
  800524:	85 ff                	test   %edi,%edi
  800526:	7f ed                	jg     800515 <vprintfmt+0x1ae>
  800528:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80052b:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80052e:	85 c9                	test   %ecx,%ecx
  800530:	b8 00 00 00 00       	mov    $0x0,%eax
  800535:	0f 49 c1             	cmovns %ecx,%eax
  800538:	29 c1                	sub    %eax,%ecx
  80053a:	89 75 08             	mov    %esi,0x8(%ebp)
  80053d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800540:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800543:	89 cb                	mov    %ecx,%ebx
  800545:	eb 16                	jmp    80055d <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  800547:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80054b:	75 31                	jne    80057e <vprintfmt+0x217>
					putch(ch, putdat);
  80054d:	83 ec 08             	sub    $0x8,%esp
  800550:	ff 75 0c             	pushl  0xc(%ebp)
  800553:	50                   	push   %eax
  800554:	ff 55 08             	call   *0x8(%ebp)
  800557:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80055a:	83 eb 01             	sub    $0x1,%ebx
  80055d:	83 c7 01             	add    $0x1,%edi
  800560:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800564:	0f be c2             	movsbl %dl,%eax
  800567:	85 c0                	test   %eax,%eax
  800569:	74 59                	je     8005c4 <vprintfmt+0x25d>
  80056b:	85 f6                	test   %esi,%esi
  80056d:	78 d8                	js     800547 <vprintfmt+0x1e0>
  80056f:	83 ee 01             	sub    $0x1,%esi
  800572:	79 d3                	jns    800547 <vprintfmt+0x1e0>
  800574:	89 df                	mov    %ebx,%edi
  800576:	8b 75 08             	mov    0x8(%ebp),%esi
  800579:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80057c:	eb 37                	jmp    8005b5 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  80057e:	0f be d2             	movsbl %dl,%edx
  800581:	83 ea 20             	sub    $0x20,%edx
  800584:	83 fa 5e             	cmp    $0x5e,%edx
  800587:	76 c4                	jbe    80054d <vprintfmt+0x1e6>
					putch('?', putdat);
  800589:	83 ec 08             	sub    $0x8,%esp
  80058c:	ff 75 0c             	pushl  0xc(%ebp)
  80058f:	6a 3f                	push   $0x3f
  800591:	ff 55 08             	call   *0x8(%ebp)
  800594:	83 c4 10             	add    $0x10,%esp
  800597:	eb c1                	jmp    80055a <vprintfmt+0x1f3>
  800599:	89 75 08             	mov    %esi,0x8(%ebp)
  80059c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80059f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005a2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005a5:	eb b6                	jmp    80055d <vprintfmt+0x1f6>
				putch(' ', putdat);
  8005a7:	83 ec 08             	sub    $0x8,%esp
  8005aa:	53                   	push   %ebx
  8005ab:	6a 20                	push   $0x20
  8005ad:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8005af:	83 ef 01             	sub    $0x1,%edi
  8005b2:	83 c4 10             	add    $0x10,%esp
  8005b5:	85 ff                	test   %edi,%edi
  8005b7:	7f ee                	jg     8005a7 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  8005b9:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005bc:	89 45 14             	mov    %eax,0x14(%ebp)
  8005bf:	e9 78 01 00 00       	jmp    80073c <vprintfmt+0x3d5>
  8005c4:	89 df                	mov    %ebx,%edi
  8005c6:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005cc:	eb e7                	jmp    8005b5 <vprintfmt+0x24e>
	if (lflag >= 2)
  8005ce:	83 f9 01             	cmp    $0x1,%ecx
  8005d1:	7e 3f                	jle    800612 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  8005d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d6:	8b 50 04             	mov    0x4(%eax),%edx
  8005d9:	8b 00                	mov    (%eax),%eax
  8005db:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005de:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e4:	8d 40 08             	lea    0x8(%eax),%eax
  8005e7:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005ea:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005ee:	79 5c                	jns    80064c <vprintfmt+0x2e5>
				putch('-', putdat);
  8005f0:	83 ec 08             	sub    $0x8,%esp
  8005f3:	53                   	push   %ebx
  8005f4:	6a 2d                	push   $0x2d
  8005f6:	ff d6                	call   *%esi
				num = -(long long) num;
  8005f8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005fb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005fe:	f7 da                	neg    %edx
  800600:	83 d1 00             	adc    $0x0,%ecx
  800603:	f7 d9                	neg    %ecx
  800605:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800608:	b8 0a 00 00 00       	mov    $0xa,%eax
  80060d:	e9 10 01 00 00       	jmp    800722 <vprintfmt+0x3bb>
	else if (lflag)
  800612:	85 c9                	test   %ecx,%ecx
  800614:	75 1b                	jne    800631 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800616:	8b 45 14             	mov    0x14(%ebp),%eax
  800619:	8b 00                	mov    (%eax),%eax
  80061b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80061e:	89 c1                	mov    %eax,%ecx
  800620:	c1 f9 1f             	sar    $0x1f,%ecx
  800623:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800626:	8b 45 14             	mov    0x14(%ebp),%eax
  800629:	8d 40 04             	lea    0x4(%eax),%eax
  80062c:	89 45 14             	mov    %eax,0x14(%ebp)
  80062f:	eb b9                	jmp    8005ea <vprintfmt+0x283>
		return va_arg(*ap, long);
  800631:	8b 45 14             	mov    0x14(%ebp),%eax
  800634:	8b 00                	mov    (%eax),%eax
  800636:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800639:	89 c1                	mov    %eax,%ecx
  80063b:	c1 f9 1f             	sar    $0x1f,%ecx
  80063e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800641:	8b 45 14             	mov    0x14(%ebp),%eax
  800644:	8d 40 04             	lea    0x4(%eax),%eax
  800647:	89 45 14             	mov    %eax,0x14(%ebp)
  80064a:	eb 9e                	jmp    8005ea <vprintfmt+0x283>
			num = getint(&ap, lflag);
  80064c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80064f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800652:	b8 0a 00 00 00       	mov    $0xa,%eax
  800657:	e9 c6 00 00 00       	jmp    800722 <vprintfmt+0x3bb>
	if (lflag >= 2)
  80065c:	83 f9 01             	cmp    $0x1,%ecx
  80065f:	7e 18                	jle    800679 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  800661:	8b 45 14             	mov    0x14(%ebp),%eax
  800664:	8b 10                	mov    (%eax),%edx
  800666:	8b 48 04             	mov    0x4(%eax),%ecx
  800669:	8d 40 08             	lea    0x8(%eax),%eax
  80066c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80066f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800674:	e9 a9 00 00 00       	jmp    800722 <vprintfmt+0x3bb>
	else if (lflag)
  800679:	85 c9                	test   %ecx,%ecx
  80067b:	75 1a                	jne    800697 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  80067d:	8b 45 14             	mov    0x14(%ebp),%eax
  800680:	8b 10                	mov    (%eax),%edx
  800682:	b9 00 00 00 00       	mov    $0x0,%ecx
  800687:	8d 40 04             	lea    0x4(%eax),%eax
  80068a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80068d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800692:	e9 8b 00 00 00       	jmp    800722 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800697:	8b 45 14             	mov    0x14(%ebp),%eax
  80069a:	8b 10                	mov    (%eax),%edx
  80069c:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006a1:	8d 40 04             	lea    0x4(%eax),%eax
  8006a4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006a7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ac:	eb 74                	jmp    800722 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8006ae:	83 f9 01             	cmp    $0x1,%ecx
  8006b1:	7e 15                	jle    8006c8 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  8006b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b6:	8b 10                	mov    (%eax),%edx
  8006b8:	8b 48 04             	mov    0x4(%eax),%ecx
  8006bb:	8d 40 08             	lea    0x8(%eax),%eax
  8006be:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006c1:	b8 08 00 00 00       	mov    $0x8,%eax
  8006c6:	eb 5a                	jmp    800722 <vprintfmt+0x3bb>
	else if (lflag)
  8006c8:	85 c9                	test   %ecx,%ecx
  8006ca:	75 17                	jne    8006e3 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  8006cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cf:	8b 10                	mov    (%eax),%edx
  8006d1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d6:	8d 40 04             	lea    0x4(%eax),%eax
  8006d9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006dc:	b8 08 00 00 00       	mov    $0x8,%eax
  8006e1:	eb 3f                	jmp    800722 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8006e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e6:	8b 10                	mov    (%eax),%edx
  8006e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ed:	8d 40 04             	lea    0x4(%eax),%eax
  8006f0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006f3:	b8 08 00 00 00       	mov    $0x8,%eax
  8006f8:	eb 28                	jmp    800722 <vprintfmt+0x3bb>
			putch('0', putdat);
  8006fa:	83 ec 08             	sub    $0x8,%esp
  8006fd:	53                   	push   %ebx
  8006fe:	6a 30                	push   $0x30
  800700:	ff d6                	call   *%esi
			putch('x', putdat);
  800702:	83 c4 08             	add    $0x8,%esp
  800705:	53                   	push   %ebx
  800706:	6a 78                	push   $0x78
  800708:	ff d6                	call   *%esi
			num = (unsigned long long)
  80070a:	8b 45 14             	mov    0x14(%ebp),%eax
  80070d:	8b 10                	mov    (%eax),%edx
  80070f:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800714:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800717:	8d 40 04             	lea    0x4(%eax),%eax
  80071a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80071d:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800722:	83 ec 0c             	sub    $0xc,%esp
  800725:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800729:	57                   	push   %edi
  80072a:	ff 75 e0             	pushl  -0x20(%ebp)
  80072d:	50                   	push   %eax
  80072e:	51                   	push   %ecx
  80072f:	52                   	push   %edx
  800730:	89 da                	mov    %ebx,%edx
  800732:	89 f0                	mov    %esi,%eax
  800734:	e8 45 fb ff ff       	call   80027e <printnum>
			break;
  800739:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80073c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80073f:	83 c7 01             	add    $0x1,%edi
  800742:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800746:	83 f8 25             	cmp    $0x25,%eax
  800749:	0f 84 2f fc ff ff    	je     80037e <vprintfmt+0x17>
			if (ch == '\0')
  80074f:	85 c0                	test   %eax,%eax
  800751:	0f 84 8b 00 00 00    	je     8007e2 <vprintfmt+0x47b>
			putch(ch, putdat);
  800757:	83 ec 08             	sub    $0x8,%esp
  80075a:	53                   	push   %ebx
  80075b:	50                   	push   %eax
  80075c:	ff d6                	call   *%esi
  80075e:	83 c4 10             	add    $0x10,%esp
  800761:	eb dc                	jmp    80073f <vprintfmt+0x3d8>
	if (lflag >= 2)
  800763:	83 f9 01             	cmp    $0x1,%ecx
  800766:	7e 15                	jle    80077d <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  800768:	8b 45 14             	mov    0x14(%ebp),%eax
  80076b:	8b 10                	mov    (%eax),%edx
  80076d:	8b 48 04             	mov    0x4(%eax),%ecx
  800770:	8d 40 08             	lea    0x8(%eax),%eax
  800773:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800776:	b8 10 00 00 00       	mov    $0x10,%eax
  80077b:	eb a5                	jmp    800722 <vprintfmt+0x3bb>
	else if (lflag)
  80077d:	85 c9                	test   %ecx,%ecx
  80077f:	75 17                	jne    800798 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  800781:	8b 45 14             	mov    0x14(%ebp),%eax
  800784:	8b 10                	mov    (%eax),%edx
  800786:	b9 00 00 00 00       	mov    $0x0,%ecx
  80078b:	8d 40 04             	lea    0x4(%eax),%eax
  80078e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800791:	b8 10 00 00 00       	mov    $0x10,%eax
  800796:	eb 8a                	jmp    800722 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800798:	8b 45 14             	mov    0x14(%ebp),%eax
  80079b:	8b 10                	mov    (%eax),%edx
  80079d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007a2:	8d 40 04             	lea    0x4(%eax),%eax
  8007a5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007a8:	b8 10 00 00 00       	mov    $0x10,%eax
  8007ad:	e9 70 ff ff ff       	jmp    800722 <vprintfmt+0x3bb>
			putch(ch, putdat);
  8007b2:	83 ec 08             	sub    $0x8,%esp
  8007b5:	53                   	push   %ebx
  8007b6:	6a 25                	push   $0x25
  8007b8:	ff d6                	call   *%esi
			break;
  8007ba:	83 c4 10             	add    $0x10,%esp
  8007bd:	e9 7a ff ff ff       	jmp    80073c <vprintfmt+0x3d5>
			putch('%', putdat);
  8007c2:	83 ec 08             	sub    $0x8,%esp
  8007c5:	53                   	push   %ebx
  8007c6:	6a 25                	push   $0x25
  8007c8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007ca:	83 c4 10             	add    $0x10,%esp
  8007cd:	89 f8                	mov    %edi,%eax
  8007cf:	eb 03                	jmp    8007d4 <vprintfmt+0x46d>
  8007d1:	83 e8 01             	sub    $0x1,%eax
  8007d4:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007d8:	75 f7                	jne    8007d1 <vprintfmt+0x46a>
  8007da:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007dd:	e9 5a ff ff ff       	jmp    80073c <vprintfmt+0x3d5>
}
  8007e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007e5:	5b                   	pop    %ebx
  8007e6:	5e                   	pop    %esi
  8007e7:	5f                   	pop    %edi
  8007e8:	5d                   	pop    %ebp
  8007e9:	c3                   	ret    

008007ea <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007ea:	55                   	push   %ebp
  8007eb:	89 e5                	mov    %esp,%ebp
  8007ed:	83 ec 18             	sub    $0x18,%esp
  8007f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007f6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007f9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007fd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800800:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800807:	85 c0                	test   %eax,%eax
  800809:	74 26                	je     800831 <vsnprintf+0x47>
  80080b:	85 d2                	test   %edx,%edx
  80080d:	7e 22                	jle    800831 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80080f:	ff 75 14             	pushl  0x14(%ebp)
  800812:	ff 75 10             	pushl  0x10(%ebp)
  800815:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800818:	50                   	push   %eax
  800819:	68 2d 03 80 00       	push   $0x80032d
  80081e:	e8 44 fb ff ff       	call   800367 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800823:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800826:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800829:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80082c:	83 c4 10             	add    $0x10,%esp
}
  80082f:	c9                   	leave  
  800830:	c3                   	ret    
		return -E_INVAL;
  800831:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800836:	eb f7                	jmp    80082f <vsnprintf+0x45>

00800838 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80083e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800841:	50                   	push   %eax
  800842:	ff 75 10             	pushl  0x10(%ebp)
  800845:	ff 75 0c             	pushl  0xc(%ebp)
  800848:	ff 75 08             	pushl  0x8(%ebp)
  80084b:	e8 9a ff ff ff       	call   8007ea <vsnprintf>
	va_end(ap);

	return rc;
}
  800850:	c9                   	leave  
  800851:	c3                   	ret    

00800852 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800858:	b8 00 00 00 00       	mov    $0x0,%eax
  80085d:	eb 03                	jmp    800862 <strlen+0x10>
		n++;
  80085f:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800862:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800866:	75 f7                	jne    80085f <strlen+0xd>
	return n;
}
  800868:	5d                   	pop    %ebp
  800869:	c3                   	ret    

0080086a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800870:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800873:	b8 00 00 00 00       	mov    $0x0,%eax
  800878:	eb 03                	jmp    80087d <strnlen+0x13>
		n++;
  80087a:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80087d:	39 d0                	cmp    %edx,%eax
  80087f:	74 06                	je     800887 <strnlen+0x1d>
  800881:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800885:	75 f3                	jne    80087a <strnlen+0x10>
	return n;
}
  800887:	5d                   	pop    %ebp
  800888:	c3                   	ret    

00800889 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800889:	55                   	push   %ebp
  80088a:	89 e5                	mov    %esp,%ebp
  80088c:	53                   	push   %ebx
  80088d:	8b 45 08             	mov    0x8(%ebp),%eax
  800890:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800893:	89 c2                	mov    %eax,%edx
  800895:	83 c1 01             	add    $0x1,%ecx
  800898:	83 c2 01             	add    $0x1,%edx
  80089b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80089f:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008a2:	84 db                	test   %bl,%bl
  8008a4:	75 ef                	jne    800895 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008a6:	5b                   	pop    %ebx
  8008a7:	5d                   	pop    %ebp
  8008a8:	c3                   	ret    

008008a9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008a9:	55                   	push   %ebp
  8008aa:	89 e5                	mov    %esp,%ebp
  8008ac:	53                   	push   %ebx
  8008ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008b0:	53                   	push   %ebx
  8008b1:	e8 9c ff ff ff       	call   800852 <strlen>
  8008b6:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008b9:	ff 75 0c             	pushl  0xc(%ebp)
  8008bc:	01 d8                	add    %ebx,%eax
  8008be:	50                   	push   %eax
  8008bf:	e8 c5 ff ff ff       	call   800889 <strcpy>
	return dst;
}
  8008c4:	89 d8                	mov    %ebx,%eax
  8008c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008c9:	c9                   	leave  
  8008ca:	c3                   	ret    

008008cb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008cb:	55                   	push   %ebp
  8008cc:	89 e5                	mov    %esp,%ebp
  8008ce:	56                   	push   %esi
  8008cf:	53                   	push   %ebx
  8008d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8008d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008d6:	89 f3                	mov    %esi,%ebx
  8008d8:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008db:	89 f2                	mov    %esi,%edx
  8008dd:	eb 0f                	jmp    8008ee <strncpy+0x23>
		*dst++ = *src;
  8008df:	83 c2 01             	add    $0x1,%edx
  8008e2:	0f b6 01             	movzbl (%ecx),%eax
  8008e5:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008e8:	80 39 01             	cmpb   $0x1,(%ecx)
  8008eb:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8008ee:	39 da                	cmp    %ebx,%edx
  8008f0:	75 ed                	jne    8008df <strncpy+0x14>
	}
	return ret;
}
  8008f2:	89 f0                	mov    %esi,%eax
  8008f4:	5b                   	pop    %ebx
  8008f5:	5e                   	pop    %esi
  8008f6:	5d                   	pop    %ebp
  8008f7:	c3                   	ret    

008008f8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008f8:	55                   	push   %ebp
  8008f9:	89 e5                	mov    %esp,%ebp
  8008fb:	56                   	push   %esi
  8008fc:	53                   	push   %ebx
  8008fd:	8b 75 08             	mov    0x8(%ebp),%esi
  800900:	8b 55 0c             	mov    0xc(%ebp),%edx
  800903:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800906:	89 f0                	mov    %esi,%eax
  800908:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80090c:	85 c9                	test   %ecx,%ecx
  80090e:	75 0b                	jne    80091b <strlcpy+0x23>
  800910:	eb 17                	jmp    800929 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800912:	83 c2 01             	add    $0x1,%edx
  800915:	83 c0 01             	add    $0x1,%eax
  800918:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  80091b:	39 d8                	cmp    %ebx,%eax
  80091d:	74 07                	je     800926 <strlcpy+0x2e>
  80091f:	0f b6 0a             	movzbl (%edx),%ecx
  800922:	84 c9                	test   %cl,%cl
  800924:	75 ec                	jne    800912 <strlcpy+0x1a>
		*dst = '\0';
  800926:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800929:	29 f0                	sub    %esi,%eax
}
  80092b:	5b                   	pop    %ebx
  80092c:	5e                   	pop    %esi
  80092d:	5d                   	pop    %ebp
  80092e:	c3                   	ret    

0080092f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800935:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800938:	eb 06                	jmp    800940 <strcmp+0x11>
		p++, q++;
  80093a:	83 c1 01             	add    $0x1,%ecx
  80093d:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800940:	0f b6 01             	movzbl (%ecx),%eax
  800943:	84 c0                	test   %al,%al
  800945:	74 04                	je     80094b <strcmp+0x1c>
  800947:	3a 02                	cmp    (%edx),%al
  800949:	74 ef                	je     80093a <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80094b:	0f b6 c0             	movzbl %al,%eax
  80094e:	0f b6 12             	movzbl (%edx),%edx
  800951:	29 d0                	sub    %edx,%eax
}
  800953:	5d                   	pop    %ebp
  800954:	c3                   	ret    

00800955 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
  800958:	53                   	push   %ebx
  800959:	8b 45 08             	mov    0x8(%ebp),%eax
  80095c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80095f:	89 c3                	mov    %eax,%ebx
  800961:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800964:	eb 06                	jmp    80096c <strncmp+0x17>
		n--, p++, q++;
  800966:	83 c0 01             	add    $0x1,%eax
  800969:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80096c:	39 d8                	cmp    %ebx,%eax
  80096e:	74 16                	je     800986 <strncmp+0x31>
  800970:	0f b6 08             	movzbl (%eax),%ecx
  800973:	84 c9                	test   %cl,%cl
  800975:	74 04                	je     80097b <strncmp+0x26>
  800977:	3a 0a                	cmp    (%edx),%cl
  800979:	74 eb                	je     800966 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80097b:	0f b6 00             	movzbl (%eax),%eax
  80097e:	0f b6 12             	movzbl (%edx),%edx
  800981:	29 d0                	sub    %edx,%eax
}
  800983:	5b                   	pop    %ebx
  800984:	5d                   	pop    %ebp
  800985:	c3                   	ret    
		return 0;
  800986:	b8 00 00 00 00       	mov    $0x0,%eax
  80098b:	eb f6                	jmp    800983 <strncmp+0x2e>

0080098d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80098d:	55                   	push   %ebp
  80098e:	89 e5                	mov    %esp,%ebp
  800990:	8b 45 08             	mov    0x8(%ebp),%eax
  800993:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800997:	0f b6 10             	movzbl (%eax),%edx
  80099a:	84 d2                	test   %dl,%dl
  80099c:	74 09                	je     8009a7 <strchr+0x1a>
		if (*s == c)
  80099e:	38 ca                	cmp    %cl,%dl
  8009a0:	74 0a                	je     8009ac <strchr+0x1f>
	for (; *s; s++)
  8009a2:	83 c0 01             	add    $0x1,%eax
  8009a5:	eb f0                	jmp    800997 <strchr+0xa>
			return (char *) s;
	return 0;
  8009a7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ac:	5d                   	pop    %ebp
  8009ad:	c3                   	ret    

008009ae <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009ae:	55                   	push   %ebp
  8009af:	89 e5                	mov    %esp,%ebp
  8009b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b8:	eb 03                	jmp    8009bd <strfind+0xf>
  8009ba:	83 c0 01             	add    $0x1,%eax
  8009bd:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009c0:	38 ca                	cmp    %cl,%dl
  8009c2:	74 04                	je     8009c8 <strfind+0x1a>
  8009c4:	84 d2                	test   %dl,%dl
  8009c6:	75 f2                	jne    8009ba <strfind+0xc>
			break;
	return (char *) s;
}
  8009c8:	5d                   	pop    %ebp
  8009c9:	c3                   	ret    

008009ca <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009ca:	55                   	push   %ebp
  8009cb:	89 e5                	mov    %esp,%ebp
  8009cd:	57                   	push   %edi
  8009ce:	56                   	push   %esi
  8009cf:	53                   	push   %ebx
  8009d0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009d3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009d6:	85 c9                	test   %ecx,%ecx
  8009d8:	74 13                	je     8009ed <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009da:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009e0:	75 05                	jne    8009e7 <memset+0x1d>
  8009e2:	f6 c1 03             	test   $0x3,%cl
  8009e5:	74 0d                	je     8009f4 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ea:	fc                   	cld    
  8009eb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009ed:	89 f8                	mov    %edi,%eax
  8009ef:	5b                   	pop    %ebx
  8009f0:	5e                   	pop    %esi
  8009f1:	5f                   	pop    %edi
  8009f2:	5d                   	pop    %ebp
  8009f3:	c3                   	ret    
		c &= 0xFF;
  8009f4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009f8:	89 d3                	mov    %edx,%ebx
  8009fa:	c1 e3 08             	shl    $0x8,%ebx
  8009fd:	89 d0                	mov    %edx,%eax
  8009ff:	c1 e0 18             	shl    $0x18,%eax
  800a02:	89 d6                	mov    %edx,%esi
  800a04:	c1 e6 10             	shl    $0x10,%esi
  800a07:	09 f0                	or     %esi,%eax
  800a09:	09 c2                	or     %eax,%edx
  800a0b:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800a0d:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a10:	89 d0                	mov    %edx,%eax
  800a12:	fc                   	cld    
  800a13:	f3 ab                	rep stos %eax,%es:(%edi)
  800a15:	eb d6                	jmp    8009ed <memset+0x23>

00800a17 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	57                   	push   %edi
  800a1b:	56                   	push   %esi
  800a1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a22:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a25:	39 c6                	cmp    %eax,%esi
  800a27:	73 35                	jae    800a5e <memmove+0x47>
  800a29:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a2c:	39 c2                	cmp    %eax,%edx
  800a2e:	76 2e                	jbe    800a5e <memmove+0x47>
		s += n;
		d += n;
  800a30:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a33:	89 d6                	mov    %edx,%esi
  800a35:	09 fe                	or     %edi,%esi
  800a37:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a3d:	74 0c                	je     800a4b <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a3f:	83 ef 01             	sub    $0x1,%edi
  800a42:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a45:	fd                   	std    
  800a46:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a48:	fc                   	cld    
  800a49:	eb 21                	jmp    800a6c <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a4b:	f6 c1 03             	test   $0x3,%cl
  800a4e:	75 ef                	jne    800a3f <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a50:	83 ef 04             	sub    $0x4,%edi
  800a53:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a56:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a59:	fd                   	std    
  800a5a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a5c:	eb ea                	jmp    800a48 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a5e:	89 f2                	mov    %esi,%edx
  800a60:	09 c2                	or     %eax,%edx
  800a62:	f6 c2 03             	test   $0x3,%dl
  800a65:	74 09                	je     800a70 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a67:	89 c7                	mov    %eax,%edi
  800a69:	fc                   	cld    
  800a6a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a6c:	5e                   	pop    %esi
  800a6d:	5f                   	pop    %edi
  800a6e:	5d                   	pop    %ebp
  800a6f:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a70:	f6 c1 03             	test   $0x3,%cl
  800a73:	75 f2                	jne    800a67 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a75:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a78:	89 c7                	mov    %eax,%edi
  800a7a:	fc                   	cld    
  800a7b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a7d:	eb ed                	jmp    800a6c <memmove+0x55>

00800a7f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a7f:	55                   	push   %ebp
  800a80:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a82:	ff 75 10             	pushl  0x10(%ebp)
  800a85:	ff 75 0c             	pushl  0xc(%ebp)
  800a88:	ff 75 08             	pushl  0x8(%ebp)
  800a8b:	e8 87 ff ff ff       	call   800a17 <memmove>
}
  800a90:	c9                   	leave  
  800a91:	c3                   	ret    

00800a92 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a92:	55                   	push   %ebp
  800a93:	89 e5                	mov    %esp,%ebp
  800a95:	56                   	push   %esi
  800a96:	53                   	push   %ebx
  800a97:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a9d:	89 c6                	mov    %eax,%esi
  800a9f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aa2:	39 f0                	cmp    %esi,%eax
  800aa4:	74 1c                	je     800ac2 <memcmp+0x30>
		if (*s1 != *s2)
  800aa6:	0f b6 08             	movzbl (%eax),%ecx
  800aa9:	0f b6 1a             	movzbl (%edx),%ebx
  800aac:	38 d9                	cmp    %bl,%cl
  800aae:	75 08                	jne    800ab8 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ab0:	83 c0 01             	add    $0x1,%eax
  800ab3:	83 c2 01             	add    $0x1,%edx
  800ab6:	eb ea                	jmp    800aa2 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800ab8:	0f b6 c1             	movzbl %cl,%eax
  800abb:	0f b6 db             	movzbl %bl,%ebx
  800abe:	29 d8                	sub    %ebx,%eax
  800ac0:	eb 05                	jmp    800ac7 <memcmp+0x35>
	}

	return 0;
  800ac2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ac7:	5b                   	pop    %ebx
  800ac8:	5e                   	pop    %esi
  800ac9:	5d                   	pop    %ebp
  800aca:	c3                   	ret    

00800acb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800acb:	55                   	push   %ebp
  800acc:	89 e5                	mov    %esp,%ebp
  800ace:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ad4:	89 c2                	mov    %eax,%edx
  800ad6:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ad9:	39 d0                	cmp    %edx,%eax
  800adb:	73 09                	jae    800ae6 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800add:	38 08                	cmp    %cl,(%eax)
  800adf:	74 05                	je     800ae6 <memfind+0x1b>
	for (; s < ends; s++)
  800ae1:	83 c0 01             	add    $0x1,%eax
  800ae4:	eb f3                	jmp    800ad9 <memfind+0xe>
			break;
	return (void *) s;
}
  800ae6:	5d                   	pop    %ebp
  800ae7:	c3                   	ret    

00800ae8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ae8:	55                   	push   %ebp
  800ae9:	89 e5                	mov    %esp,%ebp
  800aeb:	57                   	push   %edi
  800aec:	56                   	push   %esi
  800aed:	53                   	push   %ebx
  800aee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800af1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800af4:	eb 03                	jmp    800af9 <strtol+0x11>
		s++;
  800af6:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800af9:	0f b6 01             	movzbl (%ecx),%eax
  800afc:	3c 20                	cmp    $0x20,%al
  800afe:	74 f6                	je     800af6 <strtol+0xe>
  800b00:	3c 09                	cmp    $0x9,%al
  800b02:	74 f2                	je     800af6 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b04:	3c 2b                	cmp    $0x2b,%al
  800b06:	74 2e                	je     800b36 <strtol+0x4e>
	int neg = 0;
  800b08:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b0d:	3c 2d                	cmp    $0x2d,%al
  800b0f:	74 2f                	je     800b40 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b11:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b17:	75 05                	jne    800b1e <strtol+0x36>
  800b19:	80 39 30             	cmpb   $0x30,(%ecx)
  800b1c:	74 2c                	je     800b4a <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b1e:	85 db                	test   %ebx,%ebx
  800b20:	75 0a                	jne    800b2c <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b22:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800b27:	80 39 30             	cmpb   $0x30,(%ecx)
  800b2a:	74 28                	je     800b54 <strtol+0x6c>
		base = 10;
  800b2c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b31:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b34:	eb 50                	jmp    800b86 <strtol+0x9e>
		s++;
  800b36:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b39:	bf 00 00 00 00       	mov    $0x0,%edi
  800b3e:	eb d1                	jmp    800b11 <strtol+0x29>
		s++, neg = 1;
  800b40:	83 c1 01             	add    $0x1,%ecx
  800b43:	bf 01 00 00 00       	mov    $0x1,%edi
  800b48:	eb c7                	jmp    800b11 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b4a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b4e:	74 0e                	je     800b5e <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b50:	85 db                	test   %ebx,%ebx
  800b52:	75 d8                	jne    800b2c <strtol+0x44>
		s++, base = 8;
  800b54:	83 c1 01             	add    $0x1,%ecx
  800b57:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b5c:	eb ce                	jmp    800b2c <strtol+0x44>
		s += 2, base = 16;
  800b5e:	83 c1 02             	add    $0x2,%ecx
  800b61:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b66:	eb c4                	jmp    800b2c <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800b68:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b6b:	89 f3                	mov    %esi,%ebx
  800b6d:	80 fb 19             	cmp    $0x19,%bl
  800b70:	77 29                	ja     800b9b <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b72:	0f be d2             	movsbl %dl,%edx
  800b75:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b78:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b7b:	7d 30                	jge    800bad <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b7d:	83 c1 01             	add    $0x1,%ecx
  800b80:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b84:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b86:	0f b6 11             	movzbl (%ecx),%edx
  800b89:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b8c:	89 f3                	mov    %esi,%ebx
  800b8e:	80 fb 09             	cmp    $0x9,%bl
  800b91:	77 d5                	ja     800b68 <strtol+0x80>
			dig = *s - '0';
  800b93:	0f be d2             	movsbl %dl,%edx
  800b96:	83 ea 30             	sub    $0x30,%edx
  800b99:	eb dd                	jmp    800b78 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800b9b:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b9e:	89 f3                	mov    %esi,%ebx
  800ba0:	80 fb 19             	cmp    $0x19,%bl
  800ba3:	77 08                	ja     800bad <strtol+0xc5>
			dig = *s - 'A' + 10;
  800ba5:	0f be d2             	movsbl %dl,%edx
  800ba8:	83 ea 37             	sub    $0x37,%edx
  800bab:	eb cb                	jmp    800b78 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bad:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bb1:	74 05                	je     800bb8 <strtol+0xd0>
		*endptr = (char *) s;
  800bb3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bb6:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800bb8:	89 c2                	mov    %eax,%edx
  800bba:	f7 da                	neg    %edx
  800bbc:	85 ff                	test   %edi,%edi
  800bbe:	0f 45 c2             	cmovne %edx,%eax
}
  800bc1:	5b                   	pop    %ebx
  800bc2:	5e                   	pop    %esi
  800bc3:	5f                   	pop    %edi
  800bc4:	5d                   	pop    %ebp
  800bc5:	c3                   	ret    

00800bc6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	57                   	push   %edi
  800bca:	56                   	push   %esi
  800bcb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bcc:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd7:	89 c3                	mov    %eax,%ebx
  800bd9:	89 c7                	mov    %eax,%edi
  800bdb:	89 c6                	mov    %eax,%esi
  800bdd:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bdf:	5b                   	pop    %ebx
  800be0:	5e                   	pop    %esi
  800be1:	5f                   	pop    %edi
  800be2:	5d                   	pop    %ebp
  800be3:	c3                   	ret    

00800be4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	57                   	push   %edi
  800be8:	56                   	push   %esi
  800be9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bea:	ba 00 00 00 00       	mov    $0x0,%edx
  800bef:	b8 01 00 00 00       	mov    $0x1,%eax
  800bf4:	89 d1                	mov    %edx,%ecx
  800bf6:	89 d3                	mov    %edx,%ebx
  800bf8:	89 d7                	mov    %edx,%edi
  800bfa:	89 d6                	mov    %edx,%esi
  800bfc:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bfe:	5b                   	pop    %ebx
  800bff:	5e                   	pop    %esi
  800c00:	5f                   	pop    %edi
  800c01:	5d                   	pop    %ebp
  800c02:	c3                   	ret    

00800c03 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c03:	55                   	push   %ebp
  800c04:	89 e5                	mov    %esp,%ebp
  800c06:	57                   	push   %edi
  800c07:	56                   	push   %esi
  800c08:	53                   	push   %ebx
  800c09:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c0c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c11:	8b 55 08             	mov    0x8(%ebp),%edx
  800c14:	b8 03 00 00 00       	mov    $0x3,%eax
  800c19:	89 cb                	mov    %ecx,%ebx
  800c1b:	89 cf                	mov    %ecx,%edi
  800c1d:	89 ce                	mov    %ecx,%esi
  800c1f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c21:	85 c0                	test   %eax,%eax
  800c23:	7f 08                	jg     800c2d <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c28:	5b                   	pop    %ebx
  800c29:	5e                   	pop    %esi
  800c2a:	5f                   	pop    %edi
  800c2b:	5d                   	pop    %ebp
  800c2c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2d:	83 ec 0c             	sub    $0xc,%esp
  800c30:	50                   	push   %eax
  800c31:	6a 03                	push   $0x3
  800c33:	68 5f 23 80 00       	push   $0x80235f
  800c38:	6a 23                	push   $0x23
  800c3a:	68 7c 23 80 00       	push   $0x80237c
  800c3f:	e8 4b f5 ff ff       	call   80018f <_panic>

00800c44 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	57                   	push   %edi
  800c48:	56                   	push   %esi
  800c49:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c4a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c4f:	b8 02 00 00 00       	mov    $0x2,%eax
  800c54:	89 d1                	mov    %edx,%ecx
  800c56:	89 d3                	mov    %edx,%ebx
  800c58:	89 d7                	mov    %edx,%edi
  800c5a:	89 d6                	mov    %edx,%esi
  800c5c:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c5e:	5b                   	pop    %ebx
  800c5f:	5e                   	pop    %esi
  800c60:	5f                   	pop    %edi
  800c61:	5d                   	pop    %ebp
  800c62:	c3                   	ret    

00800c63 <sys_yield>:

void
sys_yield(void)
{
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	57                   	push   %edi
  800c67:	56                   	push   %esi
  800c68:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c69:	ba 00 00 00 00       	mov    $0x0,%edx
  800c6e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c73:	89 d1                	mov    %edx,%ecx
  800c75:	89 d3                	mov    %edx,%ebx
  800c77:	89 d7                	mov    %edx,%edi
  800c79:	89 d6                	mov    %edx,%esi
  800c7b:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c7d:	5b                   	pop    %ebx
  800c7e:	5e                   	pop    %esi
  800c7f:	5f                   	pop    %edi
  800c80:	5d                   	pop    %ebp
  800c81:	c3                   	ret    

00800c82 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	57                   	push   %edi
  800c86:	56                   	push   %esi
  800c87:	53                   	push   %ebx
  800c88:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c8b:	be 00 00 00 00       	mov    $0x0,%esi
  800c90:	8b 55 08             	mov    0x8(%ebp),%edx
  800c93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c96:	b8 04 00 00 00       	mov    $0x4,%eax
  800c9b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c9e:	89 f7                	mov    %esi,%edi
  800ca0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ca2:	85 c0                	test   %eax,%eax
  800ca4:	7f 08                	jg     800cae <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ca6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca9:	5b                   	pop    %ebx
  800caa:	5e                   	pop    %esi
  800cab:	5f                   	pop    %edi
  800cac:	5d                   	pop    %ebp
  800cad:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cae:	83 ec 0c             	sub    $0xc,%esp
  800cb1:	50                   	push   %eax
  800cb2:	6a 04                	push   $0x4
  800cb4:	68 5f 23 80 00       	push   $0x80235f
  800cb9:	6a 23                	push   $0x23
  800cbb:	68 7c 23 80 00       	push   $0x80237c
  800cc0:	e8 ca f4 ff ff       	call   80018f <_panic>

00800cc5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cc5:	55                   	push   %ebp
  800cc6:	89 e5                	mov    %esp,%ebp
  800cc8:	57                   	push   %edi
  800cc9:	56                   	push   %esi
  800cca:	53                   	push   %ebx
  800ccb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cce:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd4:	b8 05 00 00 00       	mov    $0x5,%eax
  800cd9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cdc:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cdf:	8b 75 18             	mov    0x18(%ebp),%esi
  800ce2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ce4:	85 c0                	test   %eax,%eax
  800ce6:	7f 08                	jg     800cf0 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ce8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ceb:	5b                   	pop    %ebx
  800cec:	5e                   	pop    %esi
  800ced:	5f                   	pop    %edi
  800cee:	5d                   	pop    %ebp
  800cef:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf0:	83 ec 0c             	sub    $0xc,%esp
  800cf3:	50                   	push   %eax
  800cf4:	6a 05                	push   $0x5
  800cf6:	68 5f 23 80 00       	push   $0x80235f
  800cfb:	6a 23                	push   $0x23
  800cfd:	68 7c 23 80 00       	push   $0x80237c
  800d02:	e8 88 f4 ff ff       	call   80018f <_panic>

00800d07 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d07:	55                   	push   %ebp
  800d08:	89 e5                	mov    %esp,%ebp
  800d0a:	57                   	push   %edi
  800d0b:	56                   	push   %esi
  800d0c:	53                   	push   %ebx
  800d0d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d10:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d15:	8b 55 08             	mov    0x8(%ebp),%edx
  800d18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1b:	b8 06 00 00 00       	mov    $0x6,%eax
  800d20:	89 df                	mov    %ebx,%edi
  800d22:	89 de                	mov    %ebx,%esi
  800d24:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d26:	85 c0                	test   %eax,%eax
  800d28:	7f 08                	jg     800d32 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2d:	5b                   	pop    %ebx
  800d2e:	5e                   	pop    %esi
  800d2f:	5f                   	pop    %edi
  800d30:	5d                   	pop    %ebp
  800d31:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d32:	83 ec 0c             	sub    $0xc,%esp
  800d35:	50                   	push   %eax
  800d36:	6a 06                	push   $0x6
  800d38:	68 5f 23 80 00       	push   $0x80235f
  800d3d:	6a 23                	push   $0x23
  800d3f:	68 7c 23 80 00       	push   $0x80237c
  800d44:	e8 46 f4 ff ff       	call   80018f <_panic>

00800d49 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d49:	55                   	push   %ebp
  800d4a:	89 e5                	mov    %esp,%ebp
  800d4c:	57                   	push   %edi
  800d4d:	56                   	push   %esi
  800d4e:	53                   	push   %ebx
  800d4f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d52:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d57:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5d:	b8 08 00 00 00       	mov    $0x8,%eax
  800d62:	89 df                	mov    %ebx,%edi
  800d64:	89 de                	mov    %ebx,%esi
  800d66:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d68:	85 c0                	test   %eax,%eax
  800d6a:	7f 08                	jg     800d74 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6f:	5b                   	pop    %ebx
  800d70:	5e                   	pop    %esi
  800d71:	5f                   	pop    %edi
  800d72:	5d                   	pop    %ebp
  800d73:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d74:	83 ec 0c             	sub    $0xc,%esp
  800d77:	50                   	push   %eax
  800d78:	6a 08                	push   $0x8
  800d7a:	68 5f 23 80 00       	push   $0x80235f
  800d7f:	6a 23                	push   $0x23
  800d81:	68 7c 23 80 00       	push   $0x80237c
  800d86:	e8 04 f4 ff ff       	call   80018f <_panic>

00800d8b <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d8b:	55                   	push   %ebp
  800d8c:	89 e5                	mov    %esp,%ebp
  800d8e:	57                   	push   %edi
  800d8f:	56                   	push   %esi
  800d90:	53                   	push   %ebx
  800d91:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d94:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d99:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9f:	b8 09 00 00 00       	mov    $0x9,%eax
  800da4:	89 df                	mov    %ebx,%edi
  800da6:	89 de                	mov    %ebx,%esi
  800da8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800daa:	85 c0                	test   %eax,%eax
  800dac:	7f 08                	jg     800db6 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db1:	5b                   	pop    %ebx
  800db2:	5e                   	pop    %esi
  800db3:	5f                   	pop    %edi
  800db4:	5d                   	pop    %ebp
  800db5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800db6:	83 ec 0c             	sub    $0xc,%esp
  800db9:	50                   	push   %eax
  800dba:	6a 09                	push   $0x9
  800dbc:	68 5f 23 80 00       	push   $0x80235f
  800dc1:	6a 23                	push   $0x23
  800dc3:	68 7c 23 80 00       	push   $0x80237c
  800dc8:	e8 c2 f3 ff ff       	call   80018f <_panic>

00800dcd <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dcd:	55                   	push   %ebp
  800dce:	89 e5                	mov    %esp,%ebp
  800dd0:	57                   	push   %edi
  800dd1:	56                   	push   %esi
  800dd2:	53                   	push   %ebx
  800dd3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dd6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ddb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800de6:	89 df                	mov    %ebx,%edi
  800de8:	89 de                	mov    %ebx,%esi
  800dea:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dec:	85 c0                	test   %eax,%eax
  800dee:	7f 08                	jg     800df8 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800df0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df3:	5b                   	pop    %ebx
  800df4:	5e                   	pop    %esi
  800df5:	5f                   	pop    %edi
  800df6:	5d                   	pop    %ebp
  800df7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800df8:	83 ec 0c             	sub    $0xc,%esp
  800dfb:	50                   	push   %eax
  800dfc:	6a 0a                	push   $0xa
  800dfe:	68 5f 23 80 00       	push   $0x80235f
  800e03:	6a 23                	push   $0x23
  800e05:	68 7c 23 80 00       	push   $0x80237c
  800e0a:	e8 80 f3 ff ff       	call   80018f <_panic>

00800e0f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e0f:	55                   	push   %ebp
  800e10:	89 e5                	mov    %esp,%ebp
  800e12:	57                   	push   %edi
  800e13:	56                   	push   %esi
  800e14:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e15:	8b 55 08             	mov    0x8(%ebp),%edx
  800e18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e20:	be 00 00 00 00       	mov    $0x0,%esi
  800e25:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e28:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e2b:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e2d:	5b                   	pop    %ebx
  800e2e:	5e                   	pop    %esi
  800e2f:	5f                   	pop    %edi
  800e30:	5d                   	pop    %ebp
  800e31:	c3                   	ret    

00800e32 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e32:	55                   	push   %ebp
  800e33:	89 e5                	mov    %esp,%ebp
  800e35:	57                   	push   %edi
  800e36:	56                   	push   %esi
  800e37:	53                   	push   %ebx
  800e38:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e3b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e40:	8b 55 08             	mov    0x8(%ebp),%edx
  800e43:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e48:	89 cb                	mov    %ecx,%ebx
  800e4a:	89 cf                	mov    %ecx,%edi
  800e4c:	89 ce                	mov    %ecx,%esi
  800e4e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e50:	85 c0                	test   %eax,%eax
  800e52:	7f 08                	jg     800e5c <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e57:	5b                   	pop    %ebx
  800e58:	5e                   	pop    %esi
  800e59:	5f                   	pop    %edi
  800e5a:	5d                   	pop    %ebp
  800e5b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e5c:	83 ec 0c             	sub    $0xc,%esp
  800e5f:	50                   	push   %eax
  800e60:	6a 0d                	push   $0xd
  800e62:	68 5f 23 80 00       	push   $0x80235f
  800e67:	6a 23                	push   $0x23
  800e69:	68 7c 23 80 00       	push   $0x80237c
  800e6e:	e8 1c f3 ff ff       	call   80018f <_panic>

00800e73 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e73:	55                   	push   %ebp
  800e74:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e76:	8b 45 08             	mov    0x8(%ebp),%eax
  800e79:	05 00 00 00 30       	add    $0x30000000,%eax
  800e7e:	c1 e8 0c             	shr    $0xc,%eax
}
  800e81:	5d                   	pop    %ebp
  800e82:	c3                   	ret    

00800e83 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e83:	55                   	push   %ebp
  800e84:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e86:	8b 45 08             	mov    0x8(%ebp),%eax
  800e89:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800e8e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e93:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e98:	5d                   	pop    %ebp
  800e99:	c3                   	ret    

00800e9a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e9a:	55                   	push   %ebp
  800e9b:	89 e5                	mov    %esp,%ebp
  800e9d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ea0:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ea5:	89 c2                	mov    %eax,%edx
  800ea7:	c1 ea 16             	shr    $0x16,%edx
  800eaa:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800eb1:	f6 c2 01             	test   $0x1,%dl
  800eb4:	74 2a                	je     800ee0 <fd_alloc+0x46>
  800eb6:	89 c2                	mov    %eax,%edx
  800eb8:	c1 ea 0c             	shr    $0xc,%edx
  800ebb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ec2:	f6 c2 01             	test   $0x1,%dl
  800ec5:	74 19                	je     800ee0 <fd_alloc+0x46>
  800ec7:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800ecc:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ed1:	75 d2                	jne    800ea5 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ed3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800ed9:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800ede:	eb 07                	jmp    800ee7 <fd_alloc+0x4d>
			*fd_store = fd;
  800ee0:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ee2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ee7:	5d                   	pop    %ebp
  800ee8:	c3                   	ret    

00800ee9 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ee9:	55                   	push   %ebp
  800eea:	89 e5                	mov    %esp,%ebp
  800eec:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800eef:	83 f8 1f             	cmp    $0x1f,%eax
  800ef2:	77 36                	ja     800f2a <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ef4:	c1 e0 0c             	shl    $0xc,%eax
  800ef7:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800efc:	89 c2                	mov    %eax,%edx
  800efe:	c1 ea 16             	shr    $0x16,%edx
  800f01:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f08:	f6 c2 01             	test   $0x1,%dl
  800f0b:	74 24                	je     800f31 <fd_lookup+0x48>
  800f0d:	89 c2                	mov    %eax,%edx
  800f0f:	c1 ea 0c             	shr    $0xc,%edx
  800f12:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f19:	f6 c2 01             	test   $0x1,%dl
  800f1c:	74 1a                	je     800f38 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f1e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f21:	89 02                	mov    %eax,(%edx)
	return 0;
  800f23:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f28:	5d                   	pop    %ebp
  800f29:	c3                   	ret    
		return -E_INVAL;
  800f2a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f2f:	eb f7                	jmp    800f28 <fd_lookup+0x3f>
		return -E_INVAL;
  800f31:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f36:	eb f0                	jmp    800f28 <fd_lookup+0x3f>
  800f38:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f3d:	eb e9                	jmp    800f28 <fd_lookup+0x3f>

00800f3f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f3f:	55                   	push   %ebp
  800f40:	89 e5                	mov    %esp,%ebp
  800f42:	83 ec 08             	sub    $0x8,%esp
  800f45:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f48:	ba 0c 24 80 00       	mov    $0x80240c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f4d:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800f52:	39 08                	cmp    %ecx,(%eax)
  800f54:	74 33                	je     800f89 <dev_lookup+0x4a>
  800f56:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800f59:	8b 02                	mov    (%edx),%eax
  800f5b:	85 c0                	test   %eax,%eax
  800f5d:	75 f3                	jne    800f52 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f5f:	a1 20 60 80 00       	mov    0x806020,%eax
  800f64:	8b 40 48             	mov    0x48(%eax),%eax
  800f67:	83 ec 04             	sub    $0x4,%esp
  800f6a:	51                   	push   %ecx
  800f6b:	50                   	push   %eax
  800f6c:	68 8c 23 80 00       	push   $0x80238c
  800f71:	e8 f4 f2 ff ff       	call   80026a <cprintf>
	*dev = 0;
  800f76:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f79:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f7f:	83 c4 10             	add    $0x10,%esp
  800f82:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f87:	c9                   	leave  
  800f88:	c3                   	ret    
			*dev = devtab[i];
  800f89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f8c:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f8e:	b8 00 00 00 00       	mov    $0x0,%eax
  800f93:	eb f2                	jmp    800f87 <dev_lookup+0x48>

00800f95 <fd_close>:
{
  800f95:	55                   	push   %ebp
  800f96:	89 e5                	mov    %esp,%ebp
  800f98:	57                   	push   %edi
  800f99:	56                   	push   %esi
  800f9a:	53                   	push   %ebx
  800f9b:	83 ec 1c             	sub    $0x1c,%esp
  800f9e:	8b 75 08             	mov    0x8(%ebp),%esi
  800fa1:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fa4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fa7:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fa8:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fae:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fb1:	50                   	push   %eax
  800fb2:	e8 32 ff ff ff       	call   800ee9 <fd_lookup>
  800fb7:	89 c3                	mov    %eax,%ebx
  800fb9:	83 c4 08             	add    $0x8,%esp
  800fbc:	85 c0                	test   %eax,%eax
  800fbe:	78 05                	js     800fc5 <fd_close+0x30>
	    || fd != fd2)
  800fc0:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800fc3:	74 16                	je     800fdb <fd_close+0x46>
		return (must_exist ? r : 0);
  800fc5:	89 f8                	mov    %edi,%eax
  800fc7:	84 c0                	test   %al,%al
  800fc9:	b8 00 00 00 00       	mov    $0x0,%eax
  800fce:	0f 44 d8             	cmove  %eax,%ebx
}
  800fd1:	89 d8                	mov    %ebx,%eax
  800fd3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fd6:	5b                   	pop    %ebx
  800fd7:	5e                   	pop    %esi
  800fd8:	5f                   	pop    %edi
  800fd9:	5d                   	pop    %ebp
  800fda:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fdb:	83 ec 08             	sub    $0x8,%esp
  800fde:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800fe1:	50                   	push   %eax
  800fe2:	ff 36                	pushl  (%esi)
  800fe4:	e8 56 ff ff ff       	call   800f3f <dev_lookup>
  800fe9:	89 c3                	mov    %eax,%ebx
  800feb:	83 c4 10             	add    $0x10,%esp
  800fee:	85 c0                	test   %eax,%eax
  800ff0:	78 15                	js     801007 <fd_close+0x72>
		if (dev->dev_close)
  800ff2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ff5:	8b 40 10             	mov    0x10(%eax),%eax
  800ff8:	85 c0                	test   %eax,%eax
  800ffa:	74 1b                	je     801017 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  800ffc:	83 ec 0c             	sub    $0xc,%esp
  800fff:	56                   	push   %esi
  801000:	ff d0                	call   *%eax
  801002:	89 c3                	mov    %eax,%ebx
  801004:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801007:	83 ec 08             	sub    $0x8,%esp
  80100a:	56                   	push   %esi
  80100b:	6a 00                	push   $0x0
  80100d:	e8 f5 fc ff ff       	call   800d07 <sys_page_unmap>
	return r;
  801012:	83 c4 10             	add    $0x10,%esp
  801015:	eb ba                	jmp    800fd1 <fd_close+0x3c>
			r = 0;
  801017:	bb 00 00 00 00       	mov    $0x0,%ebx
  80101c:	eb e9                	jmp    801007 <fd_close+0x72>

0080101e <close>:

int
close(int fdnum)
{
  80101e:	55                   	push   %ebp
  80101f:	89 e5                	mov    %esp,%ebp
  801021:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801024:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801027:	50                   	push   %eax
  801028:	ff 75 08             	pushl  0x8(%ebp)
  80102b:	e8 b9 fe ff ff       	call   800ee9 <fd_lookup>
  801030:	83 c4 08             	add    $0x8,%esp
  801033:	85 c0                	test   %eax,%eax
  801035:	78 10                	js     801047 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801037:	83 ec 08             	sub    $0x8,%esp
  80103a:	6a 01                	push   $0x1
  80103c:	ff 75 f4             	pushl  -0xc(%ebp)
  80103f:	e8 51 ff ff ff       	call   800f95 <fd_close>
  801044:	83 c4 10             	add    $0x10,%esp
}
  801047:	c9                   	leave  
  801048:	c3                   	ret    

00801049 <close_all>:

void
close_all(void)
{
  801049:	55                   	push   %ebp
  80104a:	89 e5                	mov    %esp,%ebp
  80104c:	53                   	push   %ebx
  80104d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801050:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801055:	83 ec 0c             	sub    $0xc,%esp
  801058:	53                   	push   %ebx
  801059:	e8 c0 ff ff ff       	call   80101e <close>
	for (i = 0; i < MAXFD; i++)
  80105e:	83 c3 01             	add    $0x1,%ebx
  801061:	83 c4 10             	add    $0x10,%esp
  801064:	83 fb 20             	cmp    $0x20,%ebx
  801067:	75 ec                	jne    801055 <close_all+0xc>
}
  801069:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80106c:	c9                   	leave  
  80106d:	c3                   	ret    

0080106e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80106e:	55                   	push   %ebp
  80106f:	89 e5                	mov    %esp,%ebp
  801071:	57                   	push   %edi
  801072:	56                   	push   %esi
  801073:	53                   	push   %ebx
  801074:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801077:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80107a:	50                   	push   %eax
  80107b:	ff 75 08             	pushl  0x8(%ebp)
  80107e:	e8 66 fe ff ff       	call   800ee9 <fd_lookup>
  801083:	89 c3                	mov    %eax,%ebx
  801085:	83 c4 08             	add    $0x8,%esp
  801088:	85 c0                	test   %eax,%eax
  80108a:	0f 88 81 00 00 00    	js     801111 <dup+0xa3>
		return r;
	close(newfdnum);
  801090:	83 ec 0c             	sub    $0xc,%esp
  801093:	ff 75 0c             	pushl  0xc(%ebp)
  801096:	e8 83 ff ff ff       	call   80101e <close>

	newfd = INDEX2FD(newfdnum);
  80109b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80109e:	c1 e6 0c             	shl    $0xc,%esi
  8010a1:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8010a7:	83 c4 04             	add    $0x4,%esp
  8010aa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010ad:	e8 d1 fd ff ff       	call   800e83 <fd2data>
  8010b2:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8010b4:	89 34 24             	mov    %esi,(%esp)
  8010b7:	e8 c7 fd ff ff       	call   800e83 <fd2data>
  8010bc:	83 c4 10             	add    $0x10,%esp
  8010bf:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010c1:	89 d8                	mov    %ebx,%eax
  8010c3:	c1 e8 16             	shr    $0x16,%eax
  8010c6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010cd:	a8 01                	test   $0x1,%al
  8010cf:	74 11                	je     8010e2 <dup+0x74>
  8010d1:	89 d8                	mov    %ebx,%eax
  8010d3:	c1 e8 0c             	shr    $0xc,%eax
  8010d6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010dd:	f6 c2 01             	test   $0x1,%dl
  8010e0:	75 39                	jne    80111b <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010e2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010e5:	89 d0                	mov    %edx,%eax
  8010e7:	c1 e8 0c             	shr    $0xc,%eax
  8010ea:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010f1:	83 ec 0c             	sub    $0xc,%esp
  8010f4:	25 07 0e 00 00       	and    $0xe07,%eax
  8010f9:	50                   	push   %eax
  8010fa:	56                   	push   %esi
  8010fb:	6a 00                	push   $0x0
  8010fd:	52                   	push   %edx
  8010fe:	6a 00                	push   $0x0
  801100:	e8 c0 fb ff ff       	call   800cc5 <sys_page_map>
  801105:	89 c3                	mov    %eax,%ebx
  801107:	83 c4 20             	add    $0x20,%esp
  80110a:	85 c0                	test   %eax,%eax
  80110c:	78 31                	js     80113f <dup+0xd1>
		goto err;

	return newfdnum;
  80110e:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801111:	89 d8                	mov    %ebx,%eax
  801113:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801116:	5b                   	pop    %ebx
  801117:	5e                   	pop    %esi
  801118:	5f                   	pop    %edi
  801119:	5d                   	pop    %ebp
  80111a:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80111b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801122:	83 ec 0c             	sub    $0xc,%esp
  801125:	25 07 0e 00 00       	and    $0xe07,%eax
  80112a:	50                   	push   %eax
  80112b:	57                   	push   %edi
  80112c:	6a 00                	push   $0x0
  80112e:	53                   	push   %ebx
  80112f:	6a 00                	push   $0x0
  801131:	e8 8f fb ff ff       	call   800cc5 <sys_page_map>
  801136:	89 c3                	mov    %eax,%ebx
  801138:	83 c4 20             	add    $0x20,%esp
  80113b:	85 c0                	test   %eax,%eax
  80113d:	79 a3                	jns    8010e2 <dup+0x74>
	sys_page_unmap(0, newfd);
  80113f:	83 ec 08             	sub    $0x8,%esp
  801142:	56                   	push   %esi
  801143:	6a 00                	push   $0x0
  801145:	e8 bd fb ff ff       	call   800d07 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80114a:	83 c4 08             	add    $0x8,%esp
  80114d:	57                   	push   %edi
  80114e:	6a 00                	push   $0x0
  801150:	e8 b2 fb ff ff       	call   800d07 <sys_page_unmap>
	return r;
  801155:	83 c4 10             	add    $0x10,%esp
  801158:	eb b7                	jmp    801111 <dup+0xa3>

0080115a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80115a:	55                   	push   %ebp
  80115b:	89 e5                	mov    %esp,%ebp
  80115d:	53                   	push   %ebx
  80115e:	83 ec 14             	sub    $0x14,%esp
  801161:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801164:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801167:	50                   	push   %eax
  801168:	53                   	push   %ebx
  801169:	e8 7b fd ff ff       	call   800ee9 <fd_lookup>
  80116e:	83 c4 08             	add    $0x8,%esp
  801171:	85 c0                	test   %eax,%eax
  801173:	78 3f                	js     8011b4 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801175:	83 ec 08             	sub    $0x8,%esp
  801178:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80117b:	50                   	push   %eax
  80117c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80117f:	ff 30                	pushl  (%eax)
  801181:	e8 b9 fd ff ff       	call   800f3f <dev_lookup>
  801186:	83 c4 10             	add    $0x10,%esp
  801189:	85 c0                	test   %eax,%eax
  80118b:	78 27                	js     8011b4 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80118d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801190:	8b 42 08             	mov    0x8(%edx),%eax
  801193:	83 e0 03             	and    $0x3,%eax
  801196:	83 f8 01             	cmp    $0x1,%eax
  801199:	74 1e                	je     8011b9 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80119b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80119e:	8b 40 08             	mov    0x8(%eax),%eax
  8011a1:	85 c0                	test   %eax,%eax
  8011a3:	74 35                	je     8011da <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011a5:	83 ec 04             	sub    $0x4,%esp
  8011a8:	ff 75 10             	pushl  0x10(%ebp)
  8011ab:	ff 75 0c             	pushl  0xc(%ebp)
  8011ae:	52                   	push   %edx
  8011af:	ff d0                	call   *%eax
  8011b1:	83 c4 10             	add    $0x10,%esp
}
  8011b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011b7:	c9                   	leave  
  8011b8:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011b9:	a1 20 60 80 00       	mov    0x806020,%eax
  8011be:	8b 40 48             	mov    0x48(%eax),%eax
  8011c1:	83 ec 04             	sub    $0x4,%esp
  8011c4:	53                   	push   %ebx
  8011c5:	50                   	push   %eax
  8011c6:	68 d0 23 80 00       	push   $0x8023d0
  8011cb:	e8 9a f0 ff ff       	call   80026a <cprintf>
		return -E_INVAL;
  8011d0:	83 c4 10             	add    $0x10,%esp
  8011d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011d8:	eb da                	jmp    8011b4 <read+0x5a>
		return -E_NOT_SUPP;
  8011da:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011df:	eb d3                	jmp    8011b4 <read+0x5a>

008011e1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011e1:	55                   	push   %ebp
  8011e2:	89 e5                	mov    %esp,%ebp
  8011e4:	57                   	push   %edi
  8011e5:	56                   	push   %esi
  8011e6:	53                   	push   %ebx
  8011e7:	83 ec 0c             	sub    $0xc,%esp
  8011ea:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011ed:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011f0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011f5:	39 f3                	cmp    %esi,%ebx
  8011f7:	73 25                	jae    80121e <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011f9:	83 ec 04             	sub    $0x4,%esp
  8011fc:	89 f0                	mov    %esi,%eax
  8011fe:	29 d8                	sub    %ebx,%eax
  801200:	50                   	push   %eax
  801201:	89 d8                	mov    %ebx,%eax
  801203:	03 45 0c             	add    0xc(%ebp),%eax
  801206:	50                   	push   %eax
  801207:	57                   	push   %edi
  801208:	e8 4d ff ff ff       	call   80115a <read>
		if (m < 0)
  80120d:	83 c4 10             	add    $0x10,%esp
  801210:	85 c0                	test   %eax,%eax
  801212:	78 08                	js     80121c <readn+0x3b>
			return m;
		if (m == 0)
  801214:	85 c0                	test   %eax,%eax
  801216:	74 06                	je     80121e <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  801218:	01 c3                	add    %eax,%ebx
  80121a:	eb d9                	jmp    8011f5 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80121c:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80121e:	89 d8                	mov    %ebx,%eax
  801220:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801223:	5b                   	pop    %ebx
  801224:	5e                   	pop    %esi
  801225:	5f                   	pop    %edi
  801226:	5d                   	pop    %ebp
  801227:	c3                   	ret    

00801228 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801228:	55                   	push   %ebp
  801229:	89 e5                	mov    %esp,%ebp
  80122b:	53                   	push   %ebx
  80122c:	83 ec 14             	sub    $0x14,%esp
  80122f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801232:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801235:	50                   	push   %eax
  801236:	53                   	push   %ebx
  801237:	e8 ad fc ff ff       	call   800ee9 <fd_lookup>
  80123c:	83 c4 08             	add    $0x8,%esp
  80123f:	85 c0                	test   %eax,%eax
  801241:	78 3a                	js     80127d <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801243:	83 ec 08             	sub    $0x8,%esp
  801246:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801249:	50                   	push   %eax
  80124a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80124d:	ff 30                	pushl  (%eax)
  80124f:	e8 eb fc ff ff       	call   800f3f <dev_lookup>
  801254:	83 c4 10             	add    $0x10,%esp
  801257:	85 c0                	test   %eax,%eax
  801259:	78 22                	js     80127d <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80125b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80125e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801262:	74 1e                	je     801282 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801264:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801267:	8b 52 0c             	mov    0xc(%edx),%edx
  80126a:	85 d2                	test   %edx,%edx
  80126c:	74 35                	je     8012a3 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80126e:	83 ec 04             	sub    $0x4,%esp
  801271:	ff 75 10             	pushl  0x10(%ebp)
  801274:	ff 75 0c             	pushl  0xc(%ebp)
  801277:	50                   	push   %eax
  801278:	ff d2                	call   *%edx
  80127a:	83 c4 10             	add    $0x10,%esp
}
  80127d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801280:	c9                   	leave  
  801281:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801282:	a1 20 60 80 00       	mov    0x806020,%eax
  801287:	8b 40 48             	mov    0x48(%eax),%eax
  80128a:	83 ec 04             	sub    $0x4,%esp
  80128d:	53                   	push   %ebx
  80128e:	50                   	push   %eax
  80128f:	68 ec 23 80 00       	push   $0x8023ec
  801294:	e8 d1 ef ff ff       	call   80026a <cprintf>
		return -E_INVAL;
  801299:	83 c4 10             	add    $0x10,%esp
  80129c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012a1:	eb da                	jmp    80127d <write+0x55>
		return -E_NOT_SUPP;
  8012a3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012a8:	eb d3                	jmp    80127d <write+0x55>

008012aa <seek>:

int
seek(int fdnum, off_t offset)
{
  8012aa:	55                   	push   %ebp
  8012ab:	89 e5                	mov    %esp,%ebp
  8012ad:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012b0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012b3:	50                   	push   %eax
  8012b4:	ff 75 08             	pushl  0x8(%ebp)
  8012b7:	e8 2d fc ff ff       	call   800ee9 <fd_lookup>
  8012bc:	83 c4 08             	add    $0x8,%esp
  8012bf:	85 c0                	test   %eax,%eax
  8012c1:	78 0e                	js     8012d1 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012c9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012d1:	c9                   	leave  
  8012d2:	c3                   	ret    

008012d3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012d3:	55                   	push   %ebp
  8012d4:	89 e5                	mov    %esp,%ebp
  8012d6:	53                   	push   %ebx
  8012d7:	83 ec 14             	sub    $0x14,%esp
  8012da:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012e0:	50                   	push   %eax
  8012e1:	53                   	push   %ebx
  8012e2:	e8 02 fc ff ff       	call   800ee9 <fd_lookup>
  8012e7:	83 c4 08             	add    $0x8,%esp
  8012ea:	85 c0                	test   %eax,%eax
  8012ec:	78 37                	js     801325 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ee:	83 ec 08             	sub    $0x8,%esp
  8012f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f4:	50                   	push   %eax
  8012f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f8:	ff 30                	pushl  (%eax)
  8012fa:	e8 40 fc ff ff       	call   800f3f <dev_lookup>
  8012ff:	83 c4 10             	add    $0x10,%esp
  801302:	85 c0                	test   %eax,%eax
  801304:	78 1f                	js     801325 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801306:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801309:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80130d:	74 1b                	je     80132a <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80130f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801312:	8b 52 18             	mov    0x18(%edx),%edx
  801315:	85 d2                	test   %edx,%edx
  801317:	74 32                	je     80134b <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801319:	83 ec 08             	sub    $0x8,%esp
  80131c:	ff 75 0c             	pushl  0xc(%ebp)
  80131f:	50                   	push   %eax
  801320:	ff d2                	call   *%edx
  801322:	83 c4 10             	add    $0x10,%esp
}
  801325:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801328:	c9                   	leave  
  801329:	c3                   	ret    
			thisenv->env_id, fdnum);
  80132a:	a1 20 60 80 00       	mov    0x806020,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80132f:	8b 40 48             	mov    0x48(%eax),%eax
  801332:	83 ec 04             	sub    $0x4,%esp
  801335:	53                   	push   %ebx
  801336:	50                   	push   %eax
  801337:	68 ac 23 80 00       	push   $0x8023ac
  80133c:	e8 29 ef ff ff       	call   80026a <cprintf>
		return -E_INVAL;
  801341:	83 c4 10             	add    $0x10,%esp
  801344:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801349:	eb da                	jmp    801325 <ftruncate+0x52>
		return -E_NOT_SUPP;
  80134b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801350:	eb d3                	jmp    801325 <ftruncate+0x52>

00801352 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801352:	55                   	push   %ebp
  801353:	89 e5                	mov    %esp,%ebp
  801355:	53                   	push   %ebx
  801356:	83 ec 14             	sub    $0x14,%esp
  801359:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80135c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80135f:	50                   	push   %eax
  801360:	ff 75 08             	pushl  0x8(%ebp)
  801363:	e8 81 fb ff ff       	call   800ee9 <fd_lookup>
  801368:	83 c4 08             	add    $0x8,%esp
  80136b:	85 c0                	test   %eax,%eax
  80136d:	78 4b                	js     8013ba <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80136f:	83 ec 08             	sub    $0x8,%esp
  801372:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801375:	50                   	push   %eax
  801376:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801379:	ff 30                	pushl  (%eax)
  80137b:	e8 bf fb ff ff       	call   800f3f <dev_lookup>
  801380:	83 c4 10             	add    $0x10,%esp
  801383:	85 c0                	test   %eax,%eax
  801385:	78 33                	js     8013ba <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  801387:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80138a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80138e:	74 2f                	je     8013bf <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801390:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801393:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80139a:	00 00 00 
	stat->st_isdir = 0;
  80139d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013a4:	00 00 00 
	stat->st_dev = dev;
  8013a7:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013ad:	83 ec 08             	sub    $0x8,%esp
  8013b0:	53                   	push   %ebx
  8013b1:	ff 75 f0             	pushl  -0x10(%ebp)
  8013b4:	ff 50 14             	call   *0x14(%eax)
  8013b7:	83 c4 10             	add    $0x10,%esp
}
  8013ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013bd:	c9                   	leave  
  8013be:	c3                   	ret    
		return -E_NOT_SUPP;
  8013bf:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013c4:	eb f4                	jmp    8013ba <fstat+0x68>

008013c6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013c6:	55                   	push   %ebp
  8013c7:	89 e5                	mov    %esp,%ebp
  8013c9:	56                   	push   %esi
  8013ca:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013cb:	83 ec 08             	sub    $0x8,%esp
  8013ce:	6a 00                	push   $0x0
  8013d0:	ff 75 08             	pushl  0x8(%ebp)
  8013d3:	e8 e7 01 00 00       	call   8015bf <open>
  8013d8:	89 c3                	mov    %eax,%ebx
  8013da:	83 c4 10             	add    $0x10,%esp
  8013dd:	85 c0                	test   %eax,%eax
  8013df:	78 1b                	js     8013fc <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013e1:	83 ec 08             	sub    $0x8,%esp
  8013e4:	ff 75 0c             	pushl  0xc(%ebp)
  8013e7:	50                   	push   %eax
  8013e8:	e8 65 ff ff ff       	call   801352 <fstat>
  8013ed:	89 c6                	mov    %eax,%esi
	close(fd);
  8013ef:	89 1c 24             	mov    %ebx,(%esp)
  8013f2:	e8 27 fc ff ff       	call   80101e <close>
	return r;
  8013f7:	83 c4 10             	add    $0x10,%esp
  8013fa:	89 f3                	mov    %esi,%ebx
}
  8013fc:	89 d8                	mov    %ebx,%eax
  8013fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801401:	5b                   	pop    %ebx
  801402:	5e                   	pop    %esi
  801403:	5d                   	pop    %ebp
  801404:	c3                   	ret    

00801405 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801405:	55                   	push   %ebp
  801406:	89 e5                	mov    %esp,%ebp
  801408:	56                   	push   %esi
  801409:	53                   	push   %ebx
  80140a:	89 c6                	mov    %eax,%esi
  80140c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80140e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801415:	74 27                	je     80143e <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801417:	6a 07                	push   $0x7
  801419:	68 00 70 80 00       	push   $0x807000
  80141e:	56                   	push   %esi
  80141f:	ff 35 00 40 80 00    	pushl  0x804000
  801425:	e8 8e 08 00 00       	call   801cb8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80142a:	83 c4 0c             	add    $0xc,%esp
  80142d:	6a 00                	push   $0x0
  80142f:	53                   	push   %ebx
  801430:	6a 00                	push   $0x0
  801432:	e8 0c 08 00 00       	call   801c43 <ipc_recv>
}
  801437:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80143a:	5b                   	pop    %ebx
  80143b:	5e                   	pop    %esi
  80143c:	5d                   	pop    %ebp
  80143d:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80143e:	83 ec 0c             	sub    $0xc,%esp
  801441:	6a 01                	push   $0x1
  801443:	e8 c6 08 00 00       	call   801d0e <ipc_find_env>
  801448:	a3 00 40 80 00       	mov    %eax,0x804000
  80144d:	83 c4 10             	add    $0x10,%esp
  801450:	eb c5                	jmp    801417 <fsipc+0x12>

00801452 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801452:	55                   	push   %ebp
  801453:	89 e5                	mov    %esp,%ebp
  801455:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801458:	8b 45 08             	mov    0x8(%ebp),%eax
  80145b:	8b 40 0c             	mov    0xc(%eax),%eax
  80145e:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  801463:	8b 45 0c             	mov    0xc(%ebp),%eax
  801466:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80146b:	ba 00 00 00 00       	mov    $0x0,%edx
  801470:	b8 02 00 00 00       	mov    $0x2,%eax
  801475:	e8 8b ff ff ff       	call   801405 <fsipc>
}
  80147a:	c9                   	leave  
  80147b:	c3                   	ret    

0080147c <devfile_flush>:
{
  80147c:	55                   	push   %ebp
  80147d:	89 e5                	mov    %esp,%ebp
  80147f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801482:	8b 45 08             	mov    0x8(%ebp),%eax
  801485:	8b 40 0c             	mov    0xc(%eax),%eax
  801488:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  80148d:	ba 00 00 00 00       	mov    $0x0,%edx
  801492:	b8 06 00 00 00       	mov    $0x6,%eax
  801497:	e8 69 ff ff ff       	call   801405 <fsipc>
}
  80149c:	c9                   	leave  
  80149d:	c3                   	ret    

0080149e <devfile_stat>:
{
  80149e:	55                   	push   %ebp
  80149f:	89 e5                	mov    %esp,%ebp
  8014a1:	53                   	push   %ebx
  8014a2:	83 ec 04             	sub    $0x4,%esp
  8014a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ab:	8b 40 0c             	mov    0xc(%eax),%eax
  8014ae:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b8:	b8 05 00 00 00       	mov    $0x5,%eax
  8014bd:	e8 43 ff ff ff       	call   801405 <fsipc>
  8014c2:	85 c0                	test   %eax,%eax
  8014c4:	78 2c                	js     8014f2 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014c6:	83 ec 08             	sub    $0x8,%esp
  8014c9:	68 00 70 80 00       	push   $0x807000
  8014ce:	53                   	push   %ebx
  8014cf:	e8 b5 f3 ff ff       	call   800889 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014d4:	a1 80 70 80 00       	mov    0x807080,%eax
  8014d9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014df:	a1 84 70 80 00       	mov    0x807084,%eax
  8014e4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014ea:	83 c4 10             	add    $0x10,%esp
  8014ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014f5:	c9                   	leave  
  8014f6:	c3                   	ret    

008014f7 <devfile_write>:
{
  8014f7:	55                   	push   %ebp
  8014f8:	89 e5                	mov    %esp,%ebp
  8014fa:	83 ec 0c             	sub    $0xc,%esp
  8014fd:	8b 45 10             	mov    0x10(%ebp),%eax
  801500:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801505:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80150a:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80150d:	8b 55 08             	mov    0x8(%ebp),%edx
  801510:	8b 52 0c             	mov    0xc(%edx),%edx
  801513:	89 15 00 70 80 00    	mov    %edx,0x807000
	fsipcbuf.write.req_n = n;
  801519:	a3 04 70 80 00       	mov    %eax,0x807004
	memmove(fsipcbuf.write.req_buf,buf,n);
  80151e:	50                   	push   %eax
  80151f:	ff 75 0c             	pushl  0xc(%ebp)
  801522:	68 08 70 80 00       	push   $0x807008
  801527:	e8 eb f4 ff ff       	call   800a17 <memmove>
	if((r = fsipc(FSREQ_WRITE,NULL))<0)
  80152c:	ba 00 00 00 00       	mov    $0x0,%edx
  801531:	b8 04 00 00 00       	mov    $0x4,%eax
  801536:	e8 ca fe ff ff       	call   801405 <fsipc>
}
  80153b:	c9                   	leave  
  80153c:	c3                   	ret    

0080153d <devfile_read>:
{
  80153d:	55                   	push   %ebp
  80153e:	89 e5                	mov    %esp,%ebp
  801540:	56                   	push   %esi
  801541:	53                   	push   %ebx
  801542:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801545:	8b 45 08             	mov    0x8(%ebp),%eax
  801548:	8b 40 0c             	mov    0xc(%eax),%eax
  80154b:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  801550:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801556:	ba 00 00 00 00       	mov    $0x0,%edx
  80155b:	b8 03 00 00 00       	mov    $0x3,%eax
  801560:	e8 a0 fe ff ff       	call   801405 <fsipc>
  801565:	89 c3                	mov    %eax,%ebx
  801567:	85 c0                	test   %eax,%eax
  801569:	78 1f                	js     80158a <devfile_read+0x4d>
	assert(r <= n);
  80156b:	39 f0                	cmp    %esi,%eax
  80156d:	77 24                	ja     801593 <devfile_read+0x56>
	assert(r <= PGSIZE);
  80156f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801574:	7f 33                	jg     8015a9 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801576:	83 ec 04             	sub    $0x4,%esp
  801579:	50                   	push   %eax
  80157a:	68 00 70 80 00       	push   $0x807000
  80157f:	ff 75 0c             	pushl  0xc(%ebp)
  801582:	e8 90 f4 ff ff       	call   800a17 <memmove>
	return r;
  801587:	83 c4 10             	add    $0x10,%esp
}
  80158a:	89 d8                	mov    %ebx,%eax
  80158c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80158f:	5b                   	pop    %ebx
  801590:	5e                   	pop    %esi
  801591:	5d                   	pop    %ebp
  801592:	c3                   	ret    
	assert(r <= n);
  801593:	68 1c 24 80 00       	push   $0x80241c
  801598:	68 23 24 80 00       	push   $0x802423
  80159d:	6a 7c                	push   $0x7c
  80159f:	68 38 24 80 00       	push   $0x802438
  8015a4:	e8 e6 eb ff ff       	call   80018f <_panic>
	assert(r <= PGSIZE);
  8015a9:	68 43 24 80 00       	push   $0x802443
  8015ae:	68 23 24 80 00       	push   $0x802423
  8015b3:	6a 7d                	push   $0x7d
  8015b5:	68 38 24 80 00       	push   $0x802438
  8015ba:	e8 d0 eb ff ff       	call   80018f <_panic>

008015bf <open>:
{
  8015bf:	55                   	push   %ebp
  8015c0:	89 e5                	mov    %esp,%ebp
  8015c2:	56                   	push   %esi
  8015c3:	53                   	push   %ebx
  8015c4:	83 ec 1c             	sub    $0x1c,%esp
  8015c7:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8015ca:	56                   	push   %esi
  8015cb:	e8 82 f2 ff ff       	call   800852 <strlen>
  8015d0:	83 c4 10             	add    $0x10,%esp
  8015d3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015d8:	7f 6c                	jg     801646 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8015da:	83 ec 0c             	sub    $0xc,%esp
  8015dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e0:	50                   	push   %eax
  8015e1:	e8 b4 f8 ff ff       	call   800e9a <fd_alloc>
  8015e6:	89 c3                	mov    %eax,%ebx
  8015e8:	83 c4 10             	add    $0x10,%esp
  8015eb:	85 c0                	test   %eax,%eax
  8015ed:	78 3c                	js     80162b <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8015ef:	83 ec 08             	sub    $0x8,%esp
  8015f2:	56                   	push   %esi
  8015f3:	68 00 70 80 00       	push   $0x807000
  8015f8:	e8 8c f2 ff ff       	call   800889 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801600:	a3 00 74 80 00       	mov    %eax,0x807400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801605:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801608:	b8 01 00 00 00       	mov    $0x1,%eax
  80160d:	e8 f3 fd ff ff       	call   801405 <fsipc>
  801612:	89 c3                	mov    %eax,%ebx
  801614:	83 c4 10             	add    $0x10,%esp
  801617:	85 c0                	test   %eax,%eax
  801619:	78 19                	js     801634 <open+0x75>
	return fd2num(fd);
  80161b:	83 ec 0c             	sub    $0xc,%esp
  80161e:	ff 75 f4             	pushl  -0xc(%ebp)
  801621:	e8 4d f8 ff ff       	call   800e73 <fd2num>
  801626:	89 c3                	mov    %eax,%ebx
  801628:	83 c4 10             	add    $0x10,%esp
}
  80162b:	89 d8                	mov    %ebx,%eax
  80162d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801630:	5b                   	pop    %ebx
  801631:	5e                   	pop    %esi
  801632:	5d                   	pop    %ebp
  801633:	c3                   	ret    
		fd_close(fd, 0);
  801634:	83 ec 08             	sub    $0x8,%esp
  801637:	6a 00                	push   $0x0
  801639:	ff 75 f4             	pushl  -0xc(%ebp)
  80163c:	e8 54 f9 ff ff       	call   800f95 <fd_close>
		return r;
  801641:	83 c4 10             	add    $0x10,%esp
  801644:	eb e5                	jmp    80162b <open+0x6c>
		return -E_BAD_PATH;
  801646:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80164b:	eb de                	jmp    80162b <open+0x6c>

0080164d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80164d:	55                   	push   %ebp
  80164e:	89 e5                	mov    %esp,%ebp
  801650:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801653:	ba 00 00 00 00       	mov    $0x0,%edx
  801658:	b8 08 00 00 00       	mov    $0x8,%eax
  80165d:	e8 a3 fd ff ff       	call   801405 <fsipc>
}
  801662:	c9                   	leave  
  801663:	c3                   	ret    

00801664 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801664:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801668:	7e 38                	jle    8016a2 <writebuf+0x3e>
{
  80166a:	55                   	push   %ebp
  80166b:	89 e5                	mov    %esp,%ebp
  80166d:	53                   	push   %ebx
  80166e:	83 ec 08             	sub    $0x8,%esp
  801671:	89 c3                	mov    %eax,%ebx
		ssize_t result = write(b->fd, b->buf, b->idx);
  801673:	ff 70 04             	pushl  0x4(%eax)
  801676:	8d 40 10             	lea    0x10(%eax),%eax
  801679:	50                   	push   %eax
  80167a:	ff 33                	pushl  (%ebx)
  80167c:	e8 a7 fb ff ff       	call   801228 <write>
		if (result > 0)
  801681:	83 c4 10             	add    $0x10,%esp
  801684:	85 c0                	test   %eax,%eax
  801686:	7e 03                	jle    80168b <writebuf+0x27>
			b->result += result;
  801688:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80168b:	39 43 04             	cmp    %eax,0x4(%ebx)
  80168e:	74 0d                	je     80169d <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801690:	85 c0                	test   %eax,%eax
  801692:	ba 00 00 00 00       	mov    $0x0,%edx
  801697:	0f 4f c2             	cmovg  %edx,%eax
  80169a:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  80169d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a0:	c9                   	leave  
  8016a1:	c3                   	ret    
  8016a2:	f3 c3                	repz ret 

008016a4 <putch>:

static void
putch(int ch, void *thunk)
{
  8016a4:	55                   	push   %ebp
  8016a5:	89 e5                	mov    %esp,%ebp
  8016a7:	53                   	push   %ebx
  8016a8:	83 ec 04             	sub    $0x4,%esp
  8016ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8016ae:	8b 53 04             	mov    0x4(%ebx),%edx
  8016b1:	8d 42 01             	lea    0x1(%edx),%eax
  8016b4:	89 43 04             	mov    %eax,0x4(%ebx)
  8016b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016ba:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8016be:	3d 00 01 00 00       	cmp    $0x100,%eax
  8016c3:	74 06                	je     8016cb <putch+0x27>
		writebuf(b);
		b->idx = 0;
	}
}
  8016c5:	83 c4 04             	add    $0x4,%esp
  8016c8:	5b                   	pop    %ebx
  8016c9:	5d                   	pop    %ebp
  8016ca:	c3                   	ret    
		writebuf(b);
  8016cb:	89 d8                	mov    %ebx,%eax
  8016cd:	e8 92 ff ff ff       	call   801664 <writebuf>
		b->idx = 0;
  8016d2:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
}
  8016d9:	eb ea                	jmp    8016c5 <putch+0x21>

008016db <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8016db:	55                   	push   %ebp
  8016dc:	89 e5                	mov    %esp,%ebp
  8016de:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8016e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e7:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8016ed:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8016f4:	00 00 00 
	b.result = 0;
  8016f7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8016fe:	00 00 00 
	b.error = 1;
  801701:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801708:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  80170b:	ff 75 10             	pushl  0x10(%ebp)
  80170e:	ff 75 0c             	pushl  0xc(%ebp)
  801711:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801717:	50                   	push   %eax
  801718:	68 a4 16 80 00       	push   $0x8016a4
  80171d:	e8 45 ec ff ff       	call   800367 <vprintfmt>
	if (b.idx > 0)
  801722:	83 c4 10             	add    $0x10,%esp
  801725:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  80172c:	7f 11                	jg     80173f <vfprintf+0x64>
		writebuf(&b);

	return (b.result ? b.result : b.error);
  80172e:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801734:	85 c0                	test   %eax,%eax
  801736:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  80173d:	c9                   	leave  
  80173e:	c3                   	ret    
		writebuf(&b);
  80173f:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801745:	e8 1a ff ff ff       	call   801664 <writebuf>
  80174a:	eb e2                	jmp    80172e <vfprintf+0x53>

0080174c <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  80174c:	55                   	push   %ebp
  80174d:	89 e5                	mov    %esp,%ebp
  80174f:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801752:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801755:	50                   	push   %eax
  801756:	ff 75 0c             	pushl  0xc(%ebp)
  801759:	ff 75 08             	pushl  0x8(%ebp)
  80175c:	e8 7a ff ff ff       	call   8016db <vfprintf>
	va_end(ap);

	return cnt;
}
  801761:	c9                   	leave  
  801762:	c3                   	ret    

00801763 <printf>:

int
printf(const char *fmt, ...)
{
  801763:	55                   	push   %ebp
  801764:	89 e5                	mov    %esp,%ebp
  801766:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801769:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  80176c:	50                   	push   %eax
  80176d:	ff 75 08             	pushl  0x8(%ebp)
  801770:	6a 01                	push   $0x1
  801772:	e8 64 ff ff ff       	call   8016db <vfprintf>
	va_end(ap);

	return cnt;
}
  801777:	c9                   	leave  
  801778:	c3                   	ret    

00801779 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801779:	55                   	push   %ebp
  80177a:	89 e5                	mov    %esp,%ebp
  80177c:	56                   	push   %esi
  80177d:	53                   	push   %ebx
  80177e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801781:	83 ec 0c             	sub    $0xc,%esp
  801784:	ff 75 08             	pushl  0x8(%ebp)
  801787:	e8 f7 f6 ff ff       	call   800e83 <fd2data>
  80178c:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80178e:	83 c4 08             	add    $0x8,%esp
  801791:	68 4f 24 80 00       	push   $0x80244f
  801796:	53                   	push   %ebx
  801797:	e8 ed f0 ff ff       	call   800889 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80179c:	8b 46 04             	mov    0x4(%esi),%eax
  80179f:	2b 06                	sub    (%esi),%eax
  8017a1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8017a7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017ae:	00 00 00 
	stat->st_dev = &devpipe;
  8017b1:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8017b8:	30 80 00 
	return 0;
}
  8017bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8017c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017c3:	5b                   	pop    %ebx
  8017c4:	5e                   	pop    %esi
  8017c5:	5d                   	pop    %ebp
  8017c6:	c3                   	ret    

008017c7 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8017c7:	55                   	push   %ebp
  8017c8:	89 e5                	mov    %esp,%ebp
  8017ca:	53                   	push   %ebx
  8017cb:	83 ec 0c             	sub    $0xc,%esp
  8017ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8017d1:	53                   	push   %ebx
  8017d2:	6a 00                	push   $0x0
  8017d4:	e8 2e f5 ff ff       	call   800d07 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8017d9:	89 1c 24             	mov    %ebx,(%esp)
  8017dc:	e8 a2 f6 ff ff       	call   800e83 <fd2data>
  8017e1:	83 c4 08             	add    $0x8,%esp
  8017e4:	50                   	push   %eax
  8017e5:	6a 00                	push   $0x0
  8017e7:	e8 1b f5 ff ff       	call   800d07 <sys_page_unmap>
}
  8017ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017ef:	c9                   	leave  
  8017f0:	c3                   	ret    

008017f1 <_pipeisclosed>:
{
  8017f1:	55                   	push   %ebp
  8017f2:	89 e5                	mov    %esp,%ebp
  8017f4:	57                   	push   %edi
  8017f5:	56                   	push   %esi
  8017f6:	53                   	push   %ebx
  8017f7:	83 ec 1c             	sub    $0x1c,%esp
  8017fa:	89 c7                	mov    %eax,%edi
  8017fc:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8017fe:	a1 20 60 80 00       	mov    0x806020,%eax
  801803:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801806:	83 ec 0c             	sub    $0xc,%esp
  801809:	57                   	push   %edi
  80180a:	e8 38 05 00 00       	call   801d47 <pageref>
  80180f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801812:	89 34 24             	mov    %esi,(%esp)
  801815:	e8 2d 05 00 00       	call   801d47 <pageref>
		nn = thisenv->env_runs;
  80181a:	8b 15 20 60 80 00    	mov    0x806020,%edx
  801820:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801823:	83 c4 10             	add    $0x10,%esp
  801826:	39 cb                	cmp    %ecx,%ebx
  801828:	74 1b                	je     801845 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  80182a:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80182d:	75 cf                	jne    8017fe <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80182f:	8b 42 58             	mov    0x58(%edx),%eax
  801832:	6a 01                	push   $0x1
  801834:	50                   	push   %eax
  801835:	53                   	push   %ebx
  801836:	68 56 24 80 00       	push   $0x802456
  80183b:	e8 2a ea ff ff       	call   80026a <cprintf>
  801840:	83 c4 10             	add    $0x10,%esp
  801843:	eb b9                	jmp    8017fe <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801845:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801848:	0f 94 c0             	sete   %al
  80184b:	0f b6 c0             	movzbl %al,%eax
}
  80184e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801851:	5b                   	pop    %ebx
  801852:	5e                   	pop    %esi
  801853:	5f                   	pop    %edi
  801854:	5d                   	pop    %ebp
  801855:	c3                   	ret    

00801856 <devpipe_write>:
{
  801856:	55                   	push   %ebp
  801857:	89 e5                	mov    %esp,%ebp
  801859:	57                   	push   %edi
  80185a:	56                   	push   %esi
  80185b:	53                   	push   %ebx
  80185c:	83 ec 28             	sub    $0x28,%esp
  80185f:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801862:	56                   	push   %esi
  801863:	e8 1b f6 ff ff       	call   800e83 <fd2data>
  801868:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80186a:	83 c4 10             	add    $0x10,%esp
  80186d:	bf 00 00 00 00       	mov    $0x0,%edi
  801872:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801875:	74 4f                	je     8018c6 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801877:	8b 43 04             	mov    0x4(%ebx),%eax
  80187a:	8b 0b                	mov    (%ebx),%ecx
  80187c:	8d 51 20             	lea    0x20(%ecx),%edx
  80187f:	39 d0                	cmp    %edx,%eax
  801881:	72 14                	jb     801897 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801883:	89 da                	mov    %ebx,%edx
  801885:	89 f0                	mov    %esi,%eax
  801887:	e8 65 ff ff ff       	call   8017f1 <_pipeisclosed>
  80188c:	85 c0                	test   %eax,%eax
  80188e:	75 3a                	jne    8018ca <devpipe_write+0x74>
			sys_yield();
  801890:	e8 ce f3 ff ff       	call   800c63 <sys_yield>
  801895:	eb e0                	jmp    801877 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801897:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80189a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80189e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8018a1:	89 c2                	mov    %eax,%edx
  8018a3:	c1 fa 1f             	sar    $0x1f,%edx
  8018a6:	89 d1                	mov    %edx,%ecx
  8018a8:	c1 e9 1b             	shr    $0x1b,%ecx
  8018ab:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8018ae:	83 e2 1f             	and    $0x1f,%edx
  8018b1:	29 ca                	sub    %ecx,%edx
  8018b3:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8018b7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8018bb:	83 c0 01             	add    $0x1,%eax
  8018be:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  8018c1:	83 c7 01             	add    $0x1,%edi
  8018c4:	eb ac                	jmp    801872 <devpipe_write+0x1c>
	return i;
  8018c6:	89 f8                	mov    %edi,%eax
  8018c8:	eb 05                	jmp    8018cf <devpipe_write+0x79>
				return 0;
  8018ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018d2:	5b                   	pop    %ebx
  8018d3:	5e                   	pop    %esi
  8018d4:	5f                   	pop    %edi
  8018d5:	5d                   	pop    %ebp
  8018d6:	c3                   	ret    

008018d7 <devpipe_read>:
{
  8018d7:	55                   	push   %ebp
  8018d8:	89 e5                	mov    %esp,%ebp
  8018da:	57                   	push   %edi
  8018db:	56                   	push   %esi
  8018dc:	53                   	push   %ebx
  8018dd:	83 ec 18             	sub    $0x18,%esp
  8018e0:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8018e3:	57                   	push   %edi
  8018e4:	e8 9a f5 ff ff       	call   800e83 <fd2data>
  8018e9:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8018eb:	83 c4 10             	add    $0x10,%esp
  8018ee:	be 00 00 00 00       	mov    $0x0,%esi
  8018f3:	3b 75 10             	cmp    0x10(%ebp),%esi
  8018f6:	74 47                	je     80193f <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  8018f8:	8b 03                	mov    (%ebx),%eax
  8018fa:	3b 43 04             	cmp    0x4(%ebx),%eax
  8018fd:	75 22                	jne    801921 <devpipe_read+0x4a>
			if (i > 0)
  8018ff:	85 f6                	test   %esi,%esi
  801901:	75 14                	jne    801917 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801903:	89 da                	mov    %ebx,%edx
  801905:	89 f8                	mov    %edi,%eax
  801907:	e8 e5 fe ff ff       	call   8017f1 <_pipeisclosed>
  80190c:	85 c0                	test   %eax,%eax
  80190e:	75 33                	jne    801943 <devpipe_read+0x6c>
			sys_yield();
  801910:	e8 4e f3 ff ff       	call   800c63 <sys_yield>
  801915:	eb e1                	jmp    8018f8 <devpipe_read+0x21>
				return i;
  801917:	89 f0                	mov    %esi,%eax
}
  801919:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80191c:	5b                   	pop    %ebx
  80191d:	5e                   	pop    %esi
  80191e:	5f                   	pop    %edi
  80191f:	5d                   	pop    %ebp
  801920:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801921:	99                   	cltd   
  801922:	c1 ea 1b             	shr    $0x1b,%edx
  801925:	01 d0                	add    %edx,%eax
  801927:	83 e0 1f             	and    $0x1f,%eax
  80192a:	29 d0                	sub    %edx,%eax
  80192c:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801931:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801934:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801937:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  80193a:	83 c6 01             	add    $0x1,%esi
  80193d:	eb b4                	jmp    8018f3 <devpipe_read+0x1c>
	return i;
  80193f:	89 f0                	mov    %esi,%eax
  801941:	eb d6                	jmp    801919 <devpipe_read+0x42>
				return 0;
  801943:	b8 00 00 00 00       	mov    $0x0,%eax
  801948:	eb cf                	jmp    801919 <devpipe_read+0x42>

0080194a <pipe>:
{
  80194a:	55                   	push   %ebp
  80194b:	89 e5                	mov    %esp,%ebp
  80194d:	56                   	push   %esi
  80194e:	53                   	push   %ebx
  80194f:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801952:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801955:	50                   	push   %eax
  801956:	e8 3f f5 ff ff       	call   800e9a <fd_alloc>
  80195b:	89 c3                	mov    %eax,%ebx
  80195d:	83 c4 10             	add    $0x10,%esp
  801960:	85 c0                	test   %eax,%eax
  801962:	78 5b                	js     8019bf <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801964:	83 ec 04             	sub    $0x4,%esp
  801967:	68 07 04 00 00       	push   $0x407
  80196c:	ff 75 f4             	pushl  -0xc(%ebp)
  80196f:	6a 00                	push   $0x0
  801971:	e8 0c f3 ff ff       	call   800c82 <sys_page_alloc>
  801976:	89 c3                	mov    %eax,%ebx
  801978:	83 c4 10             	add    $0x10,%esp
  80197b:	85 c0                	test   %eax,%eax
  80197d:	78 40                	js     8019bf <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  80197f:	83 ec 0c             	sub    $0xc,%esp
  801982:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801985:	50                   	push   %eax
  801986:	e8 0f f5 ff ff       	call   800e9a <fd_alloc>
  80198b:	89 c3                	mov    %eax,%ebx
  80198d:	83 c4 10             	add    $0x10,%esp
  801990:	85 c0                	test   %eax,%eax
  801992:	78 1b                	js     8019af <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801994:	83 ec 04             	sub    $0x4,%esp
  801997:	68 07 04 00 00       	push   $0x407
  80199c:	ff 75 f0             	pushl  -0x10(%ebp)
  80199f:	6a 00                	push   $0x0
  8019a1:	e8 dc f2 ff ff       	call   800c82 <sys_page_alloc>
  8019a6:	89 c3                	mov    %eax,%ebx
  8019a8:	83 c4 10             	add    $0x10,%esp
  8019ab:	85 c0                	test   %eax,%eax
  8019ad:	79 19                	jns    8019c8 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  8019af:	83 ec 08             	sub    $0x8,%esp
  8019b2:	ff 75 f4             	pushl  -0xc(%ebp)
  8019b5:	6a 00                	push   $0x0
  8019b7:	e8 4b f3 ff ff       	call   800d07 <sys_page_unmap>
  8019bc:	83 c4 10             	add    $0x10,%esp
}
  8019bf:	89 d8                	mov    %ebx,%eax
  8019c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019c4:	5b                   	pop    %ebx
  8019c5:	5e                   	pop    %esi
  8019c6:	5d                   	pop    %ebp
  8019c7:	c3                   	ret    
	va = fd2data(fd0);
  8019c8:	83 ec 0c             	sub    $0xc,%esp
  8019cb:	ff 75 f4             	pushl  -0xc(%ebp)
  8019ce:	e8 b0 f4 ff ff       	call   800e83 <fd2data>
  8019d3:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019d5:	83 c4 0c             	add    $0xc,%esp
  8019d8:	68 07 04 00 00       	push   $0x407
  8019dd:	50                   	push   %eax
  8019de:	6a 00                	push   $0x0
  8019e0:	e8 9d f2 ff ff       	call   800c82 <sys_page_alloc>
  8019e5:	89 c3                	mov    %eax,%ebx
  8019e7:	83 c4 10             	add    $0x10,%esp
  8019ea:	85 c0                	test   %eax,%eax
  8019ec:	0f 88 8c 00 00 00    	js     801a7e <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019f2:	83 ec 0c             	sub    $0xc,%esp
  8019f5:	ff 75 f0             	pushl  -0x10(%ebp)
  8019f8:	e8 86 f4 ff ff       	call   800e83 <fd2data>
  8019fd:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801a04:	50                   	push   %eax
  801a05:	6a 00                	push   $0x0
  801a07:	56                   	push   %esi
  801a08:	6a 00                	push   $0x0
  801a0a:	e8 b6 f2 ff ff       	call   800cc5 <sys_page_map>
  801a0f:	89 c3                	mov    %eax,%ebx
  801a11:	83 c4 20             	add    $0x20,%esp
  801a14:	85 c0                	test   %eax,%eax
  801a16:	78 58                	js     801a70 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801a18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a1b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a21:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801a23:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a26:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801a2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a30:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a36:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801a38:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a3b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801a42:	83 ec 0c             	sub    $0xc,%esp
  801a45:	ff 75 f4             	pushl  -0xc(%ebp)
  801a48:	e8 26 f4 ff ff       	call   800e73 <fd2num>
  801a4d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a50:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801a52:	83 c4 04             	add    $0x4,%esp
  801a55:	ff 75 f0             	pushl  -0x10(%ebp)
  801a58:	e8 16 f4 ff ff       	call   800e73 <fd2num>
  801a5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a60:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801a63:	83 c4 10             	add    $0x10,%esp
  801a66:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a6b:	e9 4f ff ff ff       	jmp    8019bf <pipe+0x75>
	sys_page_unmap(0, va);
  801a70:	83 ec 08             	sub    $0x8,%esp
  801a73:	56                   	push   %esi
  801a74:	6a 00                	push   $0x0
  801a76:	e8 8c f2 ff ff       	call   800d07 <sys_page_unmap>
  801a7b:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801a7e:	83 ec 08             	sub    $0x8,%esp
  801a81:	ff 75 f0             	pushl  -0x10(%ebp)
  801a84:	6a 00                	push   $0x0
  801a86:	e8 7c f2 ff ff       	call   800d07 <sys_page_unmap>
  801a8b:	83 c4 10             	add    $0x10,%esp
  801a8e:	e9 1c ff ff ff       	jmp    8019af <pipe+0x65>

00801a93 <pipeisclosed>:
{
  801a93:	55                   	push   %ebp
  801a94:	89 e5                	mov    %esp,%ebp
  801a96:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a99:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a9c:	50                   	push   %eax
  801a9d:	ff 75 08             	pushl  0x8(%ebp)
  801aa0:	e8 44 f4 ff ff       	call   800ee9 <fd_lookup>
  801aa5:	83 c4 10             	add    $0x10,%esp
  801aa8:	85 c0                	test   %eax,%eax
  801aaa:	78 18                	js     801ac4 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801aac:	83 ec 0c             	sub    $0xc,%esp
  801aaf:	ff 75 f4             	pushl  -0xc(%ebp)
  801ab2:	e8 cc f3 ff ff       	call   800e83 <fd2data>
	return _pipeisclosed(fd, p);
  801ab7:	89 c2                	mov    %eax,%edx
  801ab9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801abc:	e8 30 fd ff ff       	call   8017f1 <_pipeisclosed>
  801ac1:	83 c4 10             	add    $0x10,%esp
}
  801ac4:	c9                   	leave  
  801ac5:	c3                   	ret    

00801ac6 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ac6:	55                   	push   %ebp
  801ac7:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ac9:	b8 00 00 00 00       	mov    $0x0,%eax
  801ace:	5d                   	pop    %ebp
  801acf:	c3                   	ret    

00801ad0 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ad0:	55                   	push   %ebp
  801ad1:	89 e5                	mov    %esp,%ebp
  801ad3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ad6:	68 6e 24 80 00       	push   $0x80246e
  801adb:	ff 75 0c             	pushl  0xc(%ebp)
  801ade:	e8 a6 ed ff ff       	call   800889 <strcpy>
	return 0;
}
  801ae3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ae8:	c9                   	leave  
  801ae9:	c3                   	ret    

00801aea <devcons_write>:
{
  801aea:	55                   	push   %ebp
  801aeb:	89 e5                	mov    %esp,%ebp
  801aed:	57                   	push   %edi
  801aee:	56                   	push   %esi
  801aef:	53                   	push   %ebx
  801af0:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801af6:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801afb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801b01:	eb 2f                	jmp    801b32 <devcons_write+0x48>
		m = n - tot;
  801b03:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801b06:	29 f3                	sub    %esi,%ebx
  801b08:	83 fb 7f             	cmp    $0x7f,%ebx
  801b0b:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801b10:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801b13:	83 ec 04             	sub    $0x4,%esp
  801b16:	53                   	push   %ebx
  801b17:	89 f0                	mov    %esi,%eax
  801b19:	03 45 0c             	add    0xc(%ebp),%eax
  801b1c:	50                   	push   %eax
  801b1d:	57                   	push   %edi
  801b1e:	e8 f4 ee ff ff       	call   800a17 <memmove>
		sys_cputs(buf, m);
  801b23:	83 c4 08             	add    $0x8,%esp
  801b26:	53                   	push   %ebx
  801b27:	57                   	push   %edi
  801b28:	e8 99 f0 ff ff       	call   800bc6 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801b2d:	01 de                	add    %ebx,%esi
  801b2f:	83 c4 10             	add    $0x10,%esp
  801b32:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b35:	72 cc                	jb     801b03 <devcons_write+0x19>
}
  801b37:	89 f0                	mov    %esi,%eax
  801b39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b3c:	5b                   	pop    %ebx
  801b3d:	5e                   	pop    %esi
  801b3e:	5f                   	pop    %edi
  801b3f:	5d                   	pop    %ebp
  801b40:	c3                   	ret    

00801b41 <devcons_read>:
{
  801b41:	55                   	push   %ebp
  801b42:	89 e5                	mov    %esp,%ebp
  801b44:	83 ec 08             	sub    $0x8,%esp
  801b47:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801b4c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b50:	75 07                	jne    801b59 <devcons_read+0x18>
}
  801b52:	c9                   	leave  
  801b53:	c3                   	ret    
		sys_yield();
  801b54:	e8 0a f1 ff ff       	call   800c63 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801b59:	e8 86 f0 ff ff       	call   800be4 <sys_cgetc>
  801b5e:	85 c0                	test   %eax,%eax
  801b60:	74 f2                	je     801b54 <devcons_read+0x13>
	if (c < 0)
  801b62:	85 c0                	test   %eax,%eax
  801b64:	78 ec                	js     801b52 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  801b66:	83 f8 04             	cmp    $0x4,%eax
  801b69:	74 0c                	je     801b77 <devcons_read+0x36>
	*(char*)vbuf = c;
  801b6b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b6e:	88 02                	mov    %al,(%edx)
	return 1;
  801b70:	b8 01 00 00 00       	mov    $0x1,%eax
  801b75:	eb db                	jmp    801b52 <devcons_read+0x11>
		return 0;
  801b77:	b8 00 00 00 00       	mov    $0x0,%eax
  801b7c:	eb d4                	jmp    801b52 <devcons_read+0x11>

00801b7e <cputchar>:
{
  801b7e:	55                   	push   %ebp
  801b7f:	89 e5                	mov    %esp,%ebp
  801b81:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801b84:	8b 45 08             	mov    0x8(%ebp),%eax
  801b87:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801b8a:	6a 01                	push   $0x1
  801b8c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b8f:	50                   	push   %eax
  801b90:	e8 31 f0 ff ff       	call   800bc6 <sys_cputs>
}
  801b95:	83 c4 10             	add    $0x10,%esp
  801b98:	c9                   	leave  
  801b99:	c3                   	ret    

00801b9a <getchar>:
{
  801b9a:	55                   	push   %ebp
  801b9b:	89 e5                	mov    %esp,%ebp
  801b9d:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801ba0:	6a 01                	push   $0x1
  801ba2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ba5:	50                   	push   %eax
  801ba6:	6a 00                	push   $0x0
  801ba8:	e8 ad f5 ff ff       	call   80115a <read>
	if (r < 0)
  801bad:	83 c4 10             	add    $0x10,%esp
  801bb0:	85 c0                	test   %eax,%eax
  801bb2:	78 08                	js     801bbc <getchar+0x22>
	if (r < 1)
  801bb4:	85 c0                	test   %eax,%eax
  801bb6:	7e 06                	jle    801bbe <getchar+0x24>
	return c;
  801bb8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801bbc:	c9                   	leave  
  801bbd:	c3                   	ret    
		return -E_EOF;
  801bbe:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801bc3:	eb f7                	jmp    801bbc <getchar+0x22>

00801bc5 <iscons>:
{
  801bc5:	55                   	push   %ebp
  801bc6:	89 e5                	mov    %esp,%ebp
  801bc8:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bcb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bce:	50                   	push   %eax
  801bcf:	ff 75 08             	pushl  0x8(%ebp)
  801bd2:	e8 12 f3 ff ff       	call   800ee9 <fd_lookup>
  801bd7:	83 c4 10             	add    $0x10,%esp
  801bda:	85 c0                	test   %eax,%eax
  801bdc:	78 11                	js     801bef <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801bde:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801be1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801be7:	39 10                	cmp    %edx,(%eax)
  801be9:	0f 94 c0             	sete   %al
  801bec:	0f b6 c0             	movzbl %al,%eax
}
  801bef:	c9                   	leave  
  801bf0:	c3                   	ret    

00801bf1 <opencons>:
{
  801bf1:	55                   	push   %ebp
  801bf2:	89 e5                	mov    %esp,%ebp
  801bf4:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801bf7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bfa:	50                   	push   %eax
  801bfb:	e8 9a f2 ff ff       	call   800e9a <fd_alloc>
  801c00:	83 c4 10             	add    $0x10,%esp
  801c03:	85 c0                	test   %eax,%eax
  801c05:	78 3a                	js     801c41 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c07:	83 ec 04             	sub    $0x4,%esp
  801c0a:	68 07 04 00 00       	push   $0x407
  801c0f:	ff 75 f4             	pushl  -0xc(%ebp)
  801c12:	6a 00                	push   $0x0
  801c14:	e8 69 f0 ff ff       	call   800c82 <sys_page_alloc>
  801c19:	83 c4 10             	add    $0x10,%esp
  801c1c:	85 c0                	test   %eax,%eax
  801c1e:	78 21                	js     801c41 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801c20:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c23:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c29:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801c2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c2e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801c35:	83 ec 0c             	sub    $0xc,%esp
  801c38:	50                   	push   %eax
  801c39:	e8 35 f2 ff ff       	call   800e73 <fd2num>
  801c3e:	83 c4 10             	add    $0x10,%esp
}
  801c41:	c9                   	leave  
  801c42:	c3                   	ret    

00801c43 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c43:	55                   	push   %ebp
  801c44:	89 e5                	mov    %esp,%ebp
  801c46:	56                   	push   %esi
  801c47:	53                   	push   %ebx
  801c48:	8b 75 08             	mov    0x8(%ebp),%esi
  801c4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c4e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        //	panic("ipc_recv not implemented");
        int r;
       	if(pg!=NULL){
  801c51:	85 c0                	test   %eax,%eax
  801c53:	74 3b                	je     801c90 <ipc_recv+0x4d>
	  r = sys_ipc_recv(pg);
  801c55:	83 ec 0c             	sub    $0xc,%esp
  801c58:	50                   	push   %eax
  801c59:	e8 d4 f1 ff ff       	call   800e32 <sys_ipc_recv>
  801c5e:	83 c4 10             	add    $0x10,%esp
	}else
	  r = sys_ipc_recv((void *)UTOP);
	if(r<0){
  801c61:	85 c0                	test   %eax,%eax
  801c63:	78 3d                	js     801ca2 <ipc_recv+0x5f>
	if(perm_store!=NULL){
		*perm_store = 0;
            }
        	return r;
           }else{
	     if(from_env_store!=NULL)
  801c65:	85 f6                	test   %esi,%esi
  801c67:	74 0a                	je     801c73 <ipc_recv+0x30>
		     *from_env_store = thisenv->env_ipc_from;
  801c69:	a1 20 60 80 00       	mov    0x806020,%eax
  801c6e:	8b 40 74             	mov    0x74(%eax),%eax
  801c71:	89 06                	mov    %eax,(%esi)
	     if(perm_store != NULL)
  801c73:	85 db                	test   %ebx,%ebx
  801c75:	74 0a                	je     801c81 <ipc_recv+0x3e>
		     *perm_store = thisenv->env_ipc_perm;
  801c77:	a1 20 60 80 00       	mov    0x806020,%eax
  801c7c:	8b 40 78             	mov    0x78(%eax),%eax
  801c7f:	89 03                	mov    %eax,(%ebx)
	     return thisenv->env_ipc_value;
  801c81:	a1 20 60 80 00       	mov    0x806020,%eax
  801c86:	8b 40 70             	mov    0x70(%eax),%eax
	   }

}
  801c89:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c8c:	5b                   	pop    %ebx
  801c8d:	5e                   	pop    %esi
  801c8e:	5d                   	pop    %ebp
  801c8f:	c3                   	ret    
	  r = sys_ipc_recv((void *)UTOP);
  801c90:	83 ec 0c             	sub    $0xc,%esp
  801c93:	68 00 00 c0 ee       	push   $0xeec00000
  801c98:	e8 95 f1 ff ff       	call   800e32 <sys_ipc_recv>
  801c9d:	83 c4 10             	add    $0x10,%esp
  801ca0:	eb bf                	jmp    801c61 <ipc_recv+0x1e>
	if(from_env_store!=NULL){
  801ca2:	85 f6                	test   %esi,%esi
  801ca4:	74 06                	je     801cac <ipc_recv+0x69>
	  *from_env_store = 0;
  801ca6:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if(perm_store!=NULL){
  801cac:	85 db                	test   %ebx,%ebx
  801cae:	74 d9                	je     801c89 <ipc_recv+0x46>
		*perm_store = 0;
  801cb0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801cb6:	eb d1                	jmp    801c89 <ipc_recv+0x46>

00801cb8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801cb8:	55                   	push   %ebp
  801cb9:	89 e5                	mov    %esp,%ebp
  801cbb:	57                   	push   %edi
  801cbc:	56                   	push   %esi
  801cbd:	53                   	push   %ebx
  801cbe:	83 ec 0c             	sub    $0xc,%esp
  801cc1:	8b 7d 08             	mov    0x8(%ebp),%edi
  801cc4:	8b 75 0c             	mov    0xc(%ebp),%esi
  801cc7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if(pg==NULL) pg = (void *)UTOP;
  801cca:	85 db                	test   %ebx,%ebx
  801ccc:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801cd1:	0f 44 d8             	cmove  %eax,%ebx
	while((r=sys_ipc_try_send(to_env,val,pg,perm))<0){
  801cd4:	ff 75 14             	pushl  0x14(%ebp)
  801cd7:	53                   	push   %ebx
  801cd8:	56                   	push   %esi
  801cd9:	57                   	push   %edi
  801cda:	e8 30 f1 ff ff       	call   800e0f <sys_ipc_try_send>
  801cdf:	83 c4 10             	add    $0x10,%esp
  801ce2:	85 c0                	test   %eax,%eax
  801ce4:	79 20                	jns    801d06 <ipc_send+0x4e>
	    if(r!=-E_IPC_NOT_RECV){
  801ce6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ce9:	75 07                	jne    801cf2 <ipc_send+0x3a>
		    panic("ipc_send:send message failed\n");
	    }
	    sys_yield();
  801ceb:	e8 73 ef ff ff       	call   800c63 <sys_yield>
  801cf0:	eb e2                	jmp    801cd4 <ipc_send+0x1c>
		    panic("ipc_send:send message failed\n");
  801cf2:	83 ec 04             	sub    $0x4,%esp
  801cf5:	68 7a 24 80 00       	push   $0x80247a
  801cfa:	6a 43                	push   $0x43
  801cfc:	68 98 24 80 00       	push   $0x802498
  801d01:	e8 89 e4 ff ff       	call   80018f <_panic>
	}

}
  801d06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d09:	5b                   	pop    %ebx
  801d0a:	5e                   	pop    %esi
  801d0b:	5f                   	pop    %edi
  801d0c:	5d                   	pop    %ebp
  801d0d:	c3                   	ret    

00801d0e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d0e:	55                   	push   %ebp
  801d0f:	89 e5                	mov    %esp,%ebp
  801d11:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801d14:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801d19:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801d1c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801d22:	8b 52 50             	mov    0x50(%edx),%edx
  801d25:	39 ca                	cmp    %ecx,%edx
  801d27:	74 11                	je     801d3a <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801d29:	83 c0 01             	add    $0x1,%eax
  801d2c:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d31:	75 e6                	jne    801d19 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801d33:	b8 00 00 00 00       	mov    $0x0,%eax
  801d38:	eb 0b                	jmp    801d45 <ipc_find_env+0x37>
			return envs[i].env_id;
  801d3a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801d3d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801d42:	8b 40 48             	mov    0x48(%eax),%eax
}
  801d45:	5d                   	pop    %ebp
  801d46:	c3                   	ret    

00801d47 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d47:	55                   	push   %ebp
  801d48:	89 e5                	mov    %esp,%ebp
  801d4a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d4d:	89 d0                	mov    %edx,%eax
  801d4f:	c1 e8 16             	shr    $0x16,%eax
  801d52:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801d59:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801d5e:	f6 c1 01             	test   $0x1,%cl
  801d61:	74 1d                	je     801d80 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801d63:	c1 ea 0c             	shr    $0xc,%edx
  801d66:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801d6d:	f6 c2 01             	test   $0x1,%dl
  801d70:	74 0e                	je     801d80 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d72:	c1 ea 0c             	shr    $0xc,%edx
  801d75:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801d7c:	ef 
  801d7d:	0f b7 c0             	movzwl %ax,%eax
}
  801d80:	5d                   	pop    %ebp
  801d81:	c3                   	ret    
  801d82:	66 90                	xchg   %ax,%ax
  801d84:	66 90                	xchg   %ax,%ax
  801d86:	66 90                	xchg   %ax,%ax
  801d88:	66 90                	xchg   %ax,%ax
  801d8a:	66 90                	xchg   %ax,%ax
  801d8c:	66 90                	xchg   %ax,%ax
  801d8e:	66 90                	xchg   %ax,%ax

00801d90 <__udivdi3>:
  801d90:	55                   	push   %ebp
  801d91:	57                   	push   %edi
  801d92:	56                   	push   %esi
  801d93:	53                   	push   %ebx
  801d94:	83 ec 1c             	sub    $0x1c,%esp
  801d97:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d9b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801d9f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801da3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801da7:	85 d2                	test   %edx,%edx
  801da9:	75 35                	jne    801de0 <__udivdi3+0x50>
  801dab:	39 f3                	cmp    %esi,%ebx
  801dad:	0f 87 bd 00 00 00    	ja     801e70 <__udivdi3+0xe0>
  801db3:	85 db                	test   %ebx,%ebx
  801db5:	89 d9                	mov    %ebx,%ecx
  801db7:	75 0b                	jne    801dc4 <__udivdi3+0x34>
  801db9:	b8 01 00 00 00       	mov    $0x1,%eax
  801dbe:	31 d2                	xor    %edx,%edx
  801dc0:	f7 f3                	div    %ebx
  801dc2:	89 c1                	mov    %eax,%ecx
  801dc4:	31 d2                	xor    %edx,%edx
  801dc6:	89 f0                	mov    %esi,%eax
  801dc8:	f7 f1                	div    %ecx
  801dca:	89 c6                	mov    %eax,%esi
  801dcc:	89 e8                	mov    %ebp,%eax
  801dce:	89 f7                	mov    %esi,%edi
  801dd0:	f7 f1                	div    %ecx
  801dd2:	89 fa                	mov    %edi,%edx
  801dd4:	83 c4 1c             	add    $0x1c,%esp
  801dd7:	5b                   	pop    %ebx
  801dd8:	5e                   	pop    %esi
  801dd9:	5f                   	pop    %edi
  801dda:	5d                   	pop    %ebp
  801ddb:	c3                   	ret    
  801ddc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801de0:	39 f2                	cmp    %esi,%edx
  801de2:	77 7c                	ja     801e60 <__udivdi3+0xd0>
  801de4:	0f bd fa             	bsr    %edx,%edi
  801de7:	83 f7 1f             	xor    $0x1f,%edi
  801dea:	0f 84 98 00 00 00    	je     801e88 <__udivdi3+0xf8>
  801df0:	89 f9                	mov    %edi,%ecx
  801df2:	b8 20 00 00 00       	mov    $0x20,%eax
  801df7:	29 f8                	sub    %edi,%eax
  801df9:	d3 e2                	shl    %cl,%edx
  801dfb:	89 54 24 08          	mov    %edx,0x8(%esp)
  801dff:	89 c1                	mov    %eax,%ecx
  801e01:	89 da                	mov    %ebx,%edx
  801e03:	d3 ea                	shr    %cl,%edx
  801e05:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801e09:	09 d1                	or     %edx,%ecx
  801e0b:	89 f2                	mov    %esi,%edx
  801e0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e11:	89 f9                	mov    %edi,%ecx
  801e13:	d3 e3                	shl    %cl,%ebx
  801e15:	89 c1                	mov    %eax,%ecx
  801e17:	d3 ea                	shr    %cl,%edx
  801e19:	89 f9                	mov    %edi,%ecx
  801e1b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801e1f:	d3 e6                	shl    %cl,%esi
  801e21:	89 eb                	mov    %ebp,%ebx
  801e23:	89 c1                	mov    %eax,%ecx
  801e25:	d3 eb                	shr    %cl,%ebx
  801e27:	09 de                	or     %ebx,%esi
  801e29:	89 f0                	mov    %esi,%eax
  801e2b:	f7 74 24 08          	divl   0x8(%esp)
  801e2f:	89 d6                	mov    %edx,%esi
  801e31:	89 c3                	mov    %eax,%ebx
  801e33:	f7 64 24 0c          	mull   0xc(%esp)
  801e37:	39 d6                	cmp    %edx,%esi
  801e39:	72 0c                	jb     801e47 <__udivdi3+0xb7>
  801e3b:	89 f9                	mov    %edi,%ecx
  801e3d:	d3 e5                	shl    %cl,%ebp
  801e3f:	39 c5                	cmp    %eax,%ebp
  801e41:	73 5d                	jae    801ea0 <__udivdi3+0x110>
  801e43:	39 d6                	cmp    %edx,%esi
  801e45:	75 59                	jne    801ea0 <__udivdi3+0x110>
  801e47:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801e4a:	31 ff                	xor    %edi,%edi
  801e4c:	89 fa                	mov    %edi,%edx
  801e4e:	83 c4 1c             	add    $0x1c,%esp
  801e51:	5b                   	pop    %ebx
  801e52:	5e                   	pop    %esi
  801e53:	5f                   	pop    %edi
  801e54:	5d                   	pop    %ebp
  801e55:	c3                   	ret    
  801e56:	8d 76 00             	lea    0x0(%esi),%esi
  801e59:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801e60:	31 ff                	xor    %edi,%edi
  801e62:	31 c0                	xor    %eax,%eax
  801e64:	89 fa                	mov    %edi,%edx
  801e66:	83 c4 1c             	add    $0x1c,%esp
  801e69:	5b                   	pop    %ebx
  801e6a:	5e                   	pop    %esi
  801e6b:	5f                   	pop    %edi
  801e6c:	5d                   	pop    %ebp
  801e6d:	c3                   	ret    
  801e6e:	66 90                	xchg   %ax,%ax
  801e70:	31 ff                	xor    %edi,%edi
  801e72:	89 e8                	mov    %ebp,%eax
  801e74:	89 f2                	mov    %esi,%edx
  801e76:	f7 f3                	div    %ebx
  801e78:	89 fa                	mov    %edi,%edx
  801e7a:	83 c4 1c             	add    $0x1c,%esp
  801e7d:	5b                   	pop    %ebx
  801e7e:	5e                   	pop    %esi
  801e7f:	5f                   	pop    %edi
  801e80:	5d                   	pop    %ebp
  801e81:	c3                   	ret    
  801e82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e88:	39 f2                	cmp    %esi,%edx
  801e8a:	72 06                	jb     801e92 <__udivdi3+0x102>
  801e8c:	31 c0                	xor    %eax,%eax
  801e8e:	39 eb                	cmp    %ebp,%ebx
  801e90:	77 d2                	ja     801e64 <__udivdi3+0xd4>
  801e92:	b8 01 00 00 00       	mov    $0x1,%eax
  801e97:	eb cb                	jmp    801e64 <__udivdi3+0xd4>
  801e99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ea0:	89 d8                	mov    %ebx,%eax
  801ea2:	31 ff                	xor    %edi,%edi
  801ea4:	eb be                	jmp    801e64 <__udivdi3+0xd4>
  801ea6:	66 90                	xchg   %ax,%ax
  801ea8:	66 90                	xchg   %ax,%ax
  801eaa:	66 90                	xchg   %ax,%ax
  801eac:	66 90                	xchg   %ax,%ax
  801eae:	66 90                	xchg   %ax,%ax

00801eb0 <__umoddi3>:
  801eb0:	55                   	push   %ebp
  801eb1:	57                   	push   %edi
  801eb2:	56                   	push   %esi
  801eb3:	53                   	push   %ebx
  801eb4:	83 ec 1c             	sub    $0x1c,%esp
  801eb7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801ebb:	8b 74 24 30          	mov    0x30(%esp),%esi
  801ebf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801ec3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ec7:	85 ed                	test   %ebp,%ebp
  801ec9:	89 f0                	mov    %esi,%eax
  801ecb:	89 da                	mov    %ebx,%edx
  801ecd:	75 19                	jne    801ee8 <__umoddi3+0x38>
  801ecf:	39 df                	cmp    %ebx,%edi
  801ed1:	0f 86 b1 00 00 00    	jbe    801f88 <__umoddi3+0xd8>
  801ed7:	f7 f7                	div    %edi
  801ed9:	89 d0                	mov    %edx,%eax
  801edb:	31 d2                	xor    %edx,%edx
  801edd:	83 c4 1c             	add    $0x1c,%esp
  801ee0:	5b                   	pop    %ebx
  801ee1:	5e                   	pop    %esi
  801ee2:	5f                   	pop    %edi
  801ee3:	5d                   	pop    %ebp
  801ee4:	c3                   	ret    
  801ee5:	8d 76 00             	lea    0x0(%esi),%esi
  801ee8:	39 dd                	cmp    %ebx,%ebp
  801eea:	77 f1                	ja     801edd <__umoddi3+0x2d>
  801eec:	0f bd cd             	bsr    %ebp,%ecx
  801eef:	83 f1 1f             	xor    $0x1f,%ecx
  801ef2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801ef6:	0f 84 b4 00 00 00    	je     801fb0 <__umoddi3+0x100>
  801efc:	b8 20 00 00 00       	mov    $0x20,%eax
  801f01:	89 c2                	mov    %eax,%edx
  801f03:	8b 44 24 04          	mov    0x4(%esp),%eax
  801f07:	29 c2                	sub    %eax,%edx
  801f09:	89 c1                	mov    %eax,%ecx
  801f0b:	89 f8                	mov    %edi,%eax
  801f0d:	d3 e5                	shl    %cl,%ebp
  801f0f:	89 d1                	mov    %edx,%ecx
  801f11:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801f15:	d3 e8                	shr    %cl,%eax
  801f17:	09 c5                	or     %eax,%ebp
  801f19:	8b 44 24 04          	mov    0x4(%esp),%eax
  801f1d:	89 c1                	mov    %eax,%ecx
  801f1f:	d3 e7                	shl    %cl,%edi
  801f21:	89 d1                	mov    %edx,%ecx
  801f23:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801f27:	89 df                	mov    %ebx,%edi
  801f29:	d3 ef                	shr    %cl,%edi
  801f2b:	89 c1                	mov    %eax,%ecx
  801f2d:	89 f0                	mov    %esi,%eax
  801f2f:	d3 e3                	shl    %cl,%ebx
  801f31:	89 d1                	mov    %edx,%ecx
  801f33:	89 fa                	mov    %edi,%edx
  801f35:	d3 e8                	shr    %cl,%eax
  801f37:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801f3c:	09 d8                	or     %ebx,%eax
  801f3e:	f7 f5                	div    %ebp
  801f40:	d3 e6                	shl    %cl,%esi
  801f42:	89 d1                	mov    %edx,%ecx
  801f44:	f7 64 24 08          	mull   0x8(%esp)
  801f48:	39 d1                	cmp    %edx,%ecx
  801f4a:	89 c3                	mov    %eax,%ebx
  801f4c:	89 d7                	mov    %edx,%edi
  801f4e:	72 06                	jb     801f56 <__umoddi3+0xa6>
  801f50:	75 0e                	jne    801f60 <__umoddi3+0xb0>
  801f52:	39 c6                	cmp    %eax,%esi
  801f54:	73 0a                	jae    801f60 <__umoddi3+0xb0>
  801f56:	2b 44 24 08          	sub    0x8(%esp),%eax
  801f5a:	19 ea                	sbb    %ebp,%edx
  801f5c:	89 d7                	mov    %edx,%edi
  801f5e:	89 c3                	mov    %eax,%ebx
  801f60:	89 ca                	mov    %ecx,%edx
  801f62:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801f67:	29 de                	sub    %ebx,%esi
  801f69:	19 fa                	sbb    %edi,%edx
  801f6b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  801f6f:	89 d0                	mov    %edx,%eax
  801f71:	d3 e0                	shl    %cl,%eax
  801f73:	89 d9                	mov    %ebx,%ecx
  801f75:	d3 ee                	shr    %cl,%esi
  801f77:	d3 ea                	shr    %cl,%edx
  801f79:	09 f0                	or     %esi,%eax
  801f7b:	83 c4 1c             	add    $0x1c,%esp
  801f7e:	5b                   	pop    %ebx
  801f7f:	5e                   	pop    %esi
  801f80:	5f                   	pop    %edi
  801f81:	5d                   	pop    %ebp
  801f82:	c3                   	ret    
  801f83:	90                   	nop
  801f84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f88:	85 ff                	test   %edi,%edi
  801f8a:	89 f9                	mov    %edi,%ecx
  801f8c:	75 0b                	jne    801f99 <__umoddi3+0xe9>
  801f8e:	b8 01 00 00 00       	mov    $0x1,%eax
  801f93:	31 d2                	xor    %edx,%edx
  801f95:	f7 f7                	div    %edi
  801f97:	89 c1                	mov    %eax,%ecx
  801f99:	89 d8                	mov    %ebx,%eax
  801f9b:	31 d2                	xor    %edx,%edx
  801f9d:	f7 f1                	div    %ecx
  801f9f:	89 f0                	mov    %esi,%eax
  801fa1:	f7 f1                	div    %ecx
  801fa3:	e9 31 ff ff ff       	jmp    801ed9 <__umoddi3+0x29>
  801fa8:	90                   	nop
  801fa9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fb0:	39 dd                	cmp    %ebx,%ebp
  801fb2:	72 08                	jb     801fbc <__umoddi3+0x10c>
  801fb4:	39 f7                	cmp    %esi,%edi
  801fb6:	0f 87 21 ff ff ff    	ja     801edd <__umoddi3+0x2d>
  801fbc:	89 da                	mov    %ebx,%edx
  801fbe:	89 f0                	mov    %esi,%eax
  801fc0:	29 f8                	sub    %edi,%eax
  801fc2:	19 ea                	sbb    %ebp,%edx
  801fc4:	e9 14 ff ff ff       	jmp    801edd <__umoddi3+0x2d>
