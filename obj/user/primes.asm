
obj/user/primes.debug:     file format elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003c:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80003f:	83 ec 04             	sub    $0x4,%esp
  800042:	6a 00                	push   $0x0
  800044:	6a 00                	push   $0x0
  800046:	56                   	push   %esi
  800047:	e8 f1 10 00 00       	call   80113d <ipc_recv>
  80004c:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004e:	a1 04 40 80 00       	mov    0x804004,%eax
  800053:	8b 40 5c             	mov    0x5c(%eax),%eax
  800056:	83 c4 0c             	add    $0xc,%esp
  800059:	53                   	push   %ebx
  80005a:	50                   	push   %eax
  80005b:	68 20 22 80 00       	push   $0x802220
  800060:	e8 ce 01 00 00       	call   800233 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800065:	e8 c6 0e 00 00       	call   800f30 <fork>
  80006a:	89 c7                	mov    %eax,%edi
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	85 c0                	test   %eax,%eax
  800071:	78 30                	js     8000a3 <primeproc+0x70>
		panic("fork: %e", id);
	if (id == 0)
  800073:	85 c0                	test   %eax,%eax
  800075:	74 c8                	je     80003f <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  800077:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80007a:	83 ec 04             	sub    $0x4,%esp
  80007d:	6a 00                	push   $0x0
  80007f:	6a 00                	push   $0x0
  800081:	56                   	push   %esi
  800082:	e8 b6 10 00 00       	call   80113d <ipc_recv>
  800087:	89 c1                	mov    %eax,%ecx
		if (i % p)
  800089:	99                   	cltd   
  80008a:	f7 fb                	idiv   %ebx
  80008c:	83 c4 10             	add    $0x10,%esp
  80008f:	85 d2                	test   %edx,%edx
  800091:	74 e7                	je     80007a <primeproc+0x47>
			ipc_send(id, i, 0, 0);
  800093:	6a 00                	push   $0x0
  800095:	6a 00                	push   $0x0
  800097:	51                   	push   %ecx
  800098:	57                   	push   %edi
  800099:	e8 14 11 00 00       	call   8011b2 <ipc_send>
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	eb d7                	jmp    80007a <primeproc+0x47>
		panic("fork: %e", id);
  8000a3:	50                   	push   %eax
  8000a4:	68 2c 22 80 00       	push   $0x80222c
  8000a9:	6a 1a                	push   $0x1a
  8000ab:	68 35 22 80 00       	push   $0x802235
  8000b0:	e8 a3 00 00 00       	call   800158 <_panic>

008000b5 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000ba:	e8 71 0e 00 00       	call   800f30 <fork>
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	78 1c                	js     8000e1 <umain+0x2c>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  8000c5:	bb 02 00 00 00       	mov    $0x2,%ebx
	if (id == 0)
  8000ca:	85 c0                	test   %eax,%eax
  8000cc:	74 25                	je     8000f3 <umain+0x3e>
		ipc_send(id, i, 0, 0);
  8000ce:	6a 00                	push   $0x0
  8000d0:	6a 00                	push   $0x0
  8000d2:	53                   	push   %ebx
  8000d3:	56                   	push   %esi
  8000d4:	e8 d9 10 00 00       	call   8011b2 <ipc_send>
	for (i = 2; ; i++)
  8000d9:	83 c3 01             	add    $0x1,%ebx
  8000dc:	83 c4 10             	add    $0x10,%esp
  8000df:	eb ed                	jmp    8000ce <umain+0x19>
		panic("fork: %e", id);
  8000e1:	50                   	push   %eax
  8000e2:	68 2c 22 80 00       	push   $0x80222c
  8000e7:	6a 2d                	push   $0x2d
  8000e9:	68 35 22 80 00       	push   $0x802235
  8000ee:	e8 65 00 00 00       	call   800158 <_panic>
		primeproc();
  8000f3:	e8 3b ff ff ff       	call   800033 <primeproc>

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800100:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800103:	e8 05 0b 00 00       	call   800c0d <sys_getenvid>
  800108:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800110:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800115:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80011a:	85 db                	test   %ebx,%ebx
  80011c:	7e 07                	jle    800125 <libmain+0x2d>
		binaryname = argv[0];
  80011e:	8b 06                	mov    (%esi),%eax
  800120:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800125:	83 ec 08             	sub    $0x8,%esp
  800128:	56                   	push   %esi
  800129:	53                   	push   %ebx
  80012a:	e8 86 ff ff ff       	call   8000b5 <umain>

	// exit gracefully
	exit();
  80012f:	e8 0a 00 00 00       	call   80013e <exit>
}
  800134:	83 c4 10             	add    $0x10,%esp
  800137:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5d                   	pop    %ebp
  80013d:	c3                   	ret    

0080013e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80013e:	55                   	push   %ebp
  80013f:	89 e5                	mov    %esp,%ebp
  800141:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800144:	e8 ce 12 00 00       	call   801417 <close_all>
	sys_env_destroy(0);
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	6a 00                	push   $0x0
  80014e:	e8 79 0a 00 00       	call   800bcc <sys_env_destroy>
}
  800153:	83 c4 10             	add    $0x10,%esp
  800156:	c9                   	leave  
  800157:	c3                   	ret    

00800158 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	56                   	push   %esi
  80015c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80015d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800160:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800166:	e8 a2 0a 00 00       	call   800c0d <sys_getenvid>
  80016b:	83 ec 0c             	sub    $0xc,%esp
  80016e:	ff 75 0c             	pushl  0xc(%ebp)
  800171:	ff 75 08             	pushl  0x8(%ebp)
  800174:	56                   	push   %esi
  800175:	50                   	push   %eax
  800176:	68 50 22 80 00       	push   $0x802250
  80017b:	e8 b3 00 00 00       	call   800233 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800180:	83 c4 18             	add    $0x18,%esp
  800183:	53                   	push   %ebx
  800184:	ff 75 10             	pushl  0x10(%ebp)
  800187:	e8 56 00 00 00       	call   8001e2 <vcprintf>
	cprintf("\n");
  80018c:	c7 04 24 bf 25 80 00 	movl   $0x8025bf,(%esp)
  800193:	e8 9b 00 00 00       	call   800233 <cprintf>
  800198:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80019b:	cc                   	int3   
  80019c:	eb fd                	jmp    80019b <_panic+0x43>

0080019e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	53                   	push   %ebx
  8001a2:	83 ec 04             	sub    $0x4,%esp
  8001a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a8:	8b 13                	mov    (%ebx),%edx
  8001aa:	8d 42 01             	lea    0x1(%edx),%eax
  8001ad:	89 03                	mov    %eax,(%ebx)
  8001af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001b6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001bb:	74 09                	je     8001c6 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001bd:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c4:	c9                   	leave  
  8001c5:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001c6:	83 ec 08             	sub    $0x8,%esp
  8001c9:	68 ff 00 00 00       	push   $0xff
  8001ce:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d1:	50                   	push   %eax
  8001d2:	e8 b8 09 00 00       	call   800b8f <sys_cputs>
		b->idx = 0;
  8001d7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001dd:	83 c4 10             	add    $0x10,%esp
  8001e0:	eb db                	jmp    8001bd <putch+0x1f>

008001e2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e2:	55                   	push   %ebp
  8001e3:	89 e5                	mov    %esp,%ebp
  8001e5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001eb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f2:	00 00 00 
	b.cnt = 0;
  8001f5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001fc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ff:	ff 75 0c             	pushl  0xc(%ebp)
  800202:	ff 75 08             	pushl  0x8(%ebp)
  800205:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80020b:	50                   	push   %eax
  80020c:	68 9e 01 80 00       	push   $0x80019e
  800211:	e8 1a 01 00 00       	call   800330 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800216:	83 c4 08             	add    $0x8,%esp
  800219:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80021f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800225:	50                   	push   %eax
  800226:	e8 64 09 00 00       	call   800b8f <sys_cputs>

	return b.cnt;
}
  80022b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800231:	c9                   	leave  
  800232:	c3                   	ret    

00800233 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800233:	55                   	push   %ebp
  800234:	89 e5                	mov    %esp,%ebp
  800236:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800239:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80023c:	50                   	push   %eax
  80023d:	ff 75 08             	pushl  0x8(%ebp)
  800240:	e8 9d ff ff ff       	call   8001e2 <vcprintf>
	va_end(ap);

	return cnt;
}
  800245:	c9                   	leave  
  800246:	c3                   	ret    

00800247 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800247:	55                   	push   %ebp
  800248:	89 e5                	mov    %esp,%ebp
  80024a:	57                   	push   %edi
  80024b:	56                   	push   %esi
  80024c:	53                   	push   %ebx
  80024d:	83 ec 1c             	sub    $0x1c,%esp
  800250:	89 c7                	mov    %eax,%edi
  800252:	89 d6                	mov    %edx,%esi
  800254:	8b 45 08             	mov    0x8(%ebp),%eax
  800257:	8b 55 0c             	mov    0xc(%ebp),%edx
  80025a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80025d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800260:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800263:	bb 00 00 00 00       	mov    $0x0,%ebx
  800268:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80026b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80026e:	39 d3                	cmp    %edx,%ebx
  800270:	72 05                	jb     800277 <printnum+0x30>
  800272:	39 45 10             	cmp    %eax,0x10(%ebp)
  800275:	77 7a                	ja     8002f1 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800277:	83 ec 0c             	sub    $0xc,%esp
  80027a:	ff 75 18             	pushl  0x18(%ebp)
  80027d:	8b 45 14             	mov    0x14(%ebp),%eax
  800280:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800283:	53                   	push   %ebx
  800284:	ff 75 10             	pushl  0x10(%ebp)
  800287:	83 ec 08             	sub    $0x8,%esp
  80028a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028d:	ff 75 e0             	pushl  -0x20(%ebp)
  800290:	ff 75 dc             	pushl  -0x24(%ebp)
  800293:	ff 75 d8             	pushl  -0x28(%ebp)
  800296:	e8 35 1d 00 00       	call   801fd0 <__udivdi3>
  80029b:	83 c4 18             	add    $0x18,%esp
  80029e:	52                   	push   %edx
  80029f:	50                   	push   %eax
  8002a0:	89 f2                	mov    %esi,%edx
  8002a2:	89 f8                	mov    %edi,%eax
  8002a4:	e8 9e ff ff ff       	call   800247 <printnum>
  8002a9:	83 c4 20             	add    $0x20,%esp
  8002ac:	eb 13                	jmp    8002c1 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ae:	83 ec 08             	sub    $0x8,%esp
  8002b1:	56                   	push   %esi
  8002b2:	ff 75 18             	pushl  0x18(%ebp)
  8002b5:	ff d7                	call   *%edi
  8002b7:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002ba:	83 eb 01             	sub    $0x1,%ebx
  8002bd:	85 db                	test   %ebx,%ebx
  8002bf:	7f ed                	jg     8002ae <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002c1:	83 ec 08             	sub    $0x8,%esp
  8002c4:	56                   	push   %esi
  8002c5:	83 ec 04             	sub    $0x4,%esp
  8002c8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002cb:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ce:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d1:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d4:	e8 17 1e 00 00       	call   8020f0 <__umoddi3>
  8002d9:	83 c4 14             	add    $0x14,%esp
  8002dc:	0f be 80 73 22 80 00 	movsbl 0x802273(%eax),%eax
  8002e3:	50                   	push   %eax
  8002e4:	ff d7                	call   *%edi
}
  8002e6:	83 c4 10             	add    $0x10,%esp
  8002e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ec:	5b                   	pop    %ebx
  8002ed:	5e                   	pop    %esi
  8002ee:	5f                   	pop    %edi
  8002ef:	5d                   	pop    %ebp
  8002f0:	c3                   	ret    
  8002f1:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002f4:	eb c4                	jmp    8002ba <printnum+0x73>

008002f6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f6:	55                   	push   %ebp
  8002f7:	89 e5                	mov    %esp,%ebp
  8002f9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002fc:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800300:	8b 10                	mov    (%eax),%edx
  800302:	3b 50 04             	cmp    0x4(%eax),%edx
  800305:	73 0a                	jae    800311 <sprintputch+0x1b>
		*b->buf++ = ch;
  800307:	8d 4a 01             	lea    0x1(%edx),%ecx
  80030a:	89 08                	mov    %ecx,(%eax)
  80030c:	8b 45 08             	mov    0x8(%ebp),%eax
  80030f:	88 02                	mov    %al,(%edx)
}
  800311:	5d                   	pop    %ebp
  800312:	c3                   	ret    

00800313 <printfmt>:
{
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
  800316:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800319:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80031c:	50                   	push   %eax
  80031d:	ff 75 10             	pushl  0x10(%ebp)
  800320:	ff 75 0c             	pushl  0xc(%ebp)
  800323:	ff 75 08             	pushl  0x8(%ebp)
  800326:	e8 05 00 00 00       	call   800330 <vprintfmt>
}
  80032b:	83 c4 10             	add    $0x10,%esp
  80032e:	c9                   	leave  
  80032f:	c3                   	ret    

00800330 <vprintfmt>:
{
  800330:	55                   	push   %ebp
  800331:	89 e5                	mov    %esp,%ebp
  800333:	57                   	push   %edi
  800334:	56                   	push   %esi
  800335:	53                   	push   %ebx
  800336:	83 ec 2c             	sub    $0x2c,%esp
  800339:	8b 75 08             	mov    0x8(%ebp),%esi
  80033c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80033f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800342:	e9 c1 03 00 00       	jmp    800708 <vprintfmt+0x3d8>
		padc = ' ';
  800347:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  80034b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800352:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800359:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800360:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800365:	8d 47 01             	lea    0x1(%edi),%eax
  800368:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80036b:	0f b6 17             	movzbl (%edi),%edx
  80036e:	8d 42 dd             	lea    -0x23(%edx),%eax
  800371:	3c 55                	cmp    $0x55,%al
  800373:	0f 87 12 04 00 00    	ja     80078b <vprintfmt+0x45b>
  800379:	0f b6 c0             	movzbl %al,%eax
  80037c:	ff 24 85 c0 23 80 00 	jmp    *0x8023c0(,%eax,4)
  800383:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800386:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80038a:	eb d9                	jmp    800365 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80038c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80038f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800393:	eb d0                	jmp    800365 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800395:	0f b6 d2             	movzbl %dl,%edx
  800398:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80039b:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003a3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003a6:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003aa:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003ad:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003b0:	83 f9 09             	cmp    $0x9,%ecx
  8003b3:	77 55                	ja     80040a <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  8003b5:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003b8:	eb e9                	jmp    8003a3 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  8003ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bd:	8b 00                	mov    (%eax),%eax
  8003bf:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c5:	8d 40 04             	lea    0x4(%eax),%eax
  8003c8:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003ce:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003d2:	79 91                	jns    800365 <vprintfmt+0x35>
				width = precision, precision = -1;
  8003d4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003da:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003e1:	eb 82                	jmp    800365 <vprintfmt+0x35>
  8003e3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e6:	85 c0                	test   %eax,%eax
  8003e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ed:	0f 49 d0             	cmovns %eax,%edx
  8003f0:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f6:	e9 6a ff ff ff       	jmp    800365 <vprintfmt+0x35>
  8003fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003fe:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800405:	e9 5b ff ff ff       	jmp    800365 <vprintfmt+0x35>
  80040a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80040d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800410:	eb bc                	jmp    8003ce <vprintfmt+0x9e>
			lflag++;
  800412:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800415:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800418:	e9 48 ff ff ff       	jmp    800365 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  80041d:	8b 45 14             	mov    0x14(%ebp),%eax
  800420:	8d 78 04             	lea    0x4(%eax),%edi
  800423:	83 ec 08             	sub    $0x8,%esp
  800426:	53                   	push   %ebx
  800427:	ff 30                	pushl  (%eax)
  800429:	ff d6                	call   *%esi
			break;
  80042b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80042e:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800431:	e9 cf 02 00 00       	jmp    800705 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  800436:	8b 45 14             	mov    0x14(%ebp),%eax
  800439:	8d 78 04             	lea    0x4(%eax),%edi
  80043c:	8b 00                	mov    (%eax),%eax
  80043e:	99                   	cltd   
  80043f:	31 d0                	xor    %edx,%eax
  800441:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800443:	83 f8 0f             	cmp    $0xf,%eax
  800446:	7f 23                	jg     80046b <vprintfmt+0x13b>
  800448:	8b 14 85 20 25 80 00 	mov    0x802520(,%eax,4),%edx
  80044f:	85 d2                	test   %edx,%edx
  800451:	74 18                	je     80046b <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800453:	52                   	push   %edx
  800454:	68 bd 27 80 00       	push   $0x8027bd
  800459:	53                   	push   %ebx
  80045a:	56                   	push   %esi
  80045b:	e8 b3 fe ff ff       	call   800313 <printfmt>
  800460:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800463:	89 7d 14             	mov    %edi,0x14(%ebp)
  800466:	e9 9a 02 00 00       	jmp    800705 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  80046b:	50                   	push   %eax
  80046c:	68 8b 22 80 00       	push   $0x80228b
  800471:	53                   	push   %ebx
  800472:	56                   	push   %esi
  800473:	e8 9b fe ff ff       	call   800313 <printfmt>
  800478:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80047b:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80047e:	e9 82 02 00 00       	jmp    800705 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  800483:	8b 45 14             	mov    0x14(%ebp),%eax
  800486:	83 c0 04             	add    $0x4,%eax
  800489:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80048c:	8b 45 14             	mov    0x14(%ebp),%eax
  80048f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800491:	85 ff                	test   %edi,%edi
  800493:	b8 84 22 80 00       	mov    $0x802284,%eax
  800498:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80049b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80049f:	0f 8e bd 00 00 00    	jle    800562 <vprintfmt+0x232>
  8004a5:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004a9:	75 0e                	jne    8004b9 <vprintfmt+0x189>
  8004ab:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ae:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004b1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004b7:	eb 6d                	jmp    800526 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b9:	83 ec 08             	sub    $0x8,%esp
  8004bc:	ff 75 d0             	pushl  -0x30(%ebp)
  8004bf:	57                   	push   %edi
  8004c0:	e8 6e 03 00 00       	call   800833 <strnlen>
  8004c5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004c8:	29 c1                	sub    %eax,%ecx
  8004ca:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004cd:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004d0:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004da:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004dc:	eb 0f                	jmp    8004ed <vprintfmt+0x1bd>
					putch(padc, putdat);
  8004de:	83 ec 08             	sub    $0x8,%esp
  8004e1:	53                   	push   %ebx
  8004e2:	ff 75 e0             	pushl  -0x20(%ebp)
  8004e5:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e7:	83 ef 01             	sub    $0x1,%edi
  8004ea:	83 c4 10             	add    $0x10,%esp
  8004ed:	85 ff                	test   %edi,%edi
  8004ef:	7f ed                	jg     8004de <vprintfmt+0x1ae>
  8004f1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004f4:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004f7:	85 c9                	test   %ecx,%ecx
  8004f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8004fe:	0f 49 c1             	cmovns %ecx,%eax
  800501:	29 c1                	sub    %eax,%ecx
  800503:	89 75 08             	mov    %esi,0x8(%ebp)
  800506:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800509:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80050c:	89 cb                	mov    %ecx,%ebx
  80050e:	eb 16                	jmp    800526 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  800510:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800514:	75 31                	jne    800547 <vprintfmt+0x217>
					putch(ch, putdat);
  800516:	83 ec 08             	sub    $0x8,%esp
  800519:	ff 75 0c             	pushl  0xc(%ebp)
  80051c:	50                   	push   %eax
  80051d:	ff 55 08             	call   *0x8(%ebp)
  800520:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800523:	83 eb 01             	sub    $0x1,%ebx
  800526:	83 c7 01             	add    $0x1,%edi
  800529:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  80052d:	0f be c2             	movsbl %dl,%eax
  800530:	85 c0                	test   %eax,%eax
  800532:	74 59                	je     80058d <vprintfmt+0x25d>
  800534:	85 f6                	test   %esi,%esi
  800536:	78 d8                	js     800510 <vprintfmt+0x1e0>
  800538:	83 ee 01             	sub    $0x1,%esi
  80053b:	79 d3                	jns    800510 <vprintfmt+0x1e0>
  80053d:	89 df                	mov    %ebx,%edi
  80053f:	8b 75 08             	mov    0x8(%ebp),%esi
  800542:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800545:	eb 37                	jmp    80057e <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  800547:	0f be d2             	movsbl %dl,%edx
  80054a:	83 ea 20             	sub    $0x20,%edx
  80054d:	83 fa 5e             	cmp    $0x5e,%edx
  800550:	76 c4                	jbe    800516 <vprintfmt+0x1e6>
					putch('?', putdat);
  800552:	83 ec 08             	sub    $0x8,%esp
  800555:	ff 75 0c             	pushl  0xc(%ebp)
  800558:	6a 3f                	push   $0x3f
  80055a:	ff 55 08             	call   *0x8(%ebp)
  80055d:	83 c4 10             	add    $0x10,%esp
  800560:	eb c1                	jmp    800523 <vprintfmt+0x1f3>
  800562:	89 75 08             	mov    %esi,0x8(%ebp)
  800565:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800568:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80056b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80056e:	eb b6                	jmp    800526 <vprintfmt+0x1f6>
				putch(' ', putdat);
  800570:	83 ec 08             	sub    $0x8,%esp
  800573:	53                   	push   %ebx
  800574:	6a 20                	push   $0x20
  800576:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800578:	83 ef 01             	sub    $0x1,%edi
  80057b:	83 c4 10             	add    $0x10,%esp
  80057e:	85 ff                	test   %edi,%edi
  800580:	7f ee                	jg     800570 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800582:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800585:	89 45 14             	mov    %eax,0x14(%ebp)
  800588:	e9 78 01 00 00       	jmp    800705 <vprintfmt+0x3d5>
  80058d:	89 df                	mov    %ebx,%edi
  80058f:	8b 75 08             	mov    0x8(%ebp),%esi
  800592:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800595:	eb e7                	jmp    80057e <vprintfmt+0x24e>
	if (lflag >= 2)
  800597:	83 f9 01             	cmp    $0x1,%ecx
  80059a:	7e 3f                	jle    8005db <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  80059c:	8b 45 14             	mov    0x14(%ebp),%eax
  80059f:	8b 50 04             	mov    0x4(%eax),%edx
  8005a2:	8b 00                	mov    (%eax),%eax
  8005a4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ad:	8d 40 08             	lea    0x8(%eax),%eax
  8005b0:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005b3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005b7:	79 5c                	jns    800615 <vprintfmt+0x2e5>
				putch('-', putdat);
  8005b9:	83 ec 08             	sub    $0x8,%esp
  8005bc:	53                   	push   %ebx
  8005bd:	6a 2d                	push   $0x2d
  8005bf:	ff d6                	call   *%esi
				num = -(long long) num;
  8005c1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005c4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005c7:	f7 da                	neg    %edx
  8005c9:	83 d1 00             	adc    $0x0,%ecx
  8005cc:	f7 d9                	neg    %ecx
  8005ce:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005d1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d6:	e9 10 01 00 00       	jmp    8006eb <vprintfmt+0x3bb>
	else if (lflag)
  8005db:	85 c9                	test   %ecx,%ecx
  8005dd:	75 1b                	jne    8005fa <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8005df:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e2:	8b 00                	mov    (%eax),%eax
  8005e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e7:	89 c1                	mov    %eax,%ecx
  8005e9:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ec:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f2:	8d 40 04             	lea    0x4(%eax),%eax
  8005f5:	89 45 14             	mov    %eax,0x14(%ebp)
  8005f8:	eb b9                	jmp    8005b3 <vprintfmt+0x283>
		return va_arg(*ap, long);
  8005fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fd:	8b 00                	mov    (%eax),%eax
  8005ff:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800602:	89 c1                	mov    %eax,%ecx
  800604:	c1 f9 1f             	sar    $0x1f,%ecx
  800607:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80060a:	8b 45 14             	mov    0x14(%ebp),%eax
  80060d:	8d 40 04             	lea    0x4(%eax),%eax
  800610:	89 45 14             	mov    %eax,0x14(%ebp)
  800613:	eb 9e                	jmp    8005b3 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  800615:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800618:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80061b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800620:	e9 c6 00 00 00       	jmp    8006eb <vprintfmt+0x3bb>
	if (lflag >= 2)
  800625:	83 f9 01             	cmp    $0x1,%ecx
  800628:	7e 18                	jle    800642 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  80062a:	8b 45 14             	mov    0x14(%ebp),%eax
  80062d:	8b 10                	mov    (%eax),%edx
  80062f:	8b 48 04             	mov    0x4(%eax),%ecx
  800632:	8d 40 08             	lea    0x8(%eax),%eax
  800635:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800638:	b8 0a 00 00 00       	mov    $0xa,%eax
  80063d:	e9 a9 00 00 00       	jmp    8006eb <vprintfmt+0x3bb>
	else if (lflag)
  800642:	85 c9                	test   %ecx,%ecx
  800644:	75 1a                	jne    800660 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  800646:	8b 45 14             	mov    0x14(%ebp),%eax
  800649:	8b 10                	mov    (%eax),%edx
  80064b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800650:	8d 40 04             	lea    0x4(%eax),%eax
  800653:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800656:	b8 0a 00 00 00       	mov    $0xa,%eax
  80065b:	e9 8b 00 00 00       	jmp    8006eb <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800660:	8b 45 14             	mov    0x14(%ebp),%eax
  800663:	8b 10                	mov    (%eax),%edx
  800665:	b9 00 00 00 00       	mov    $0x0,%ecx
  80066a:	8d 40 04             	lea    0x4(%eax),%eax
  80066d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800670:	b8 0a 00 00 00       	mov    $0xa,%eax
  800675:	eb 74                	jmp    8006eb <vprintfmt+0x3bb>
	if (lflag >= 2)
  800677:	83 f9 01             	cmp    $0x1,%ecx
  80067a:	7e 15                	jle    800691 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  80067c:	8b 45 14             	mov    0x14(%ebp),%eax
  80067f:	8b 10                	mov    (%eax),%edx
  800681:	8b 48 04             	mov    0x4(%eax),%ecx
  800684:	8d 40 08             	lea    0x8(%eax),%eax
  800687:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80068a:	b8 08 00 00 00       	mov    $0x8,%eax
  80068f:	eb 5a                	jmp    8006eb <vprintfmt+0x3bb>
	else if (lflag)
  800691:	85 c9                	test   %ecx,%ecx
  800693:	75 17                	jne    8006ac <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  800695:	8b 45 14             	mov    0x14(%ebp),%eax
  800698:	8b 10                	mov    (%eax),%edx
  80069a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80069f:	8d 40 04             	lea    0x4(%eax),%eax
  8006a2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006a5:	b8 08 00 00 00       	mov    $0x8,%eax
  8006aa:	eb 3f                	jmp    8006eb <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8006ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8006af:	8b 10                	mov    (%eax),%edx
  8006b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b6:	8d 40 04             	lea    0x4(%eax),%eax
  8006b9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006bc:	b8 08 00 00 00       	mov    $0x8,%eax
  8006c1:	eb 28                	jmp    8006eb <vprintfmt+0x3bb>
			putch('0', putdat);
  8006c3:	83 ec 08             	sub    $0x8,%esp
  8006c6:	53                   	push   %ebx
  8006c7:	6a 30                	push   $0x30
  8006c9:	ff d6                	call   *%esi
			putch('x', putdat);
  8006cb:	83 c4 08             	add    $0x8,%esp
  8006ce:	53                   	push   %ebx
  8006cf:	6a 78                	push   $0x78
  8006d1:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d6:	8b 10                	mov    (%eax),%edx
  8006d8:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006dd:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006e0:	8d 40 04             	lea    0x4(%eax),%eax
  8006e3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006e6:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006eb:	83 ec 0c             	sub    $0xc,%esp
  8006ee:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006f2:	57                   	push   %edi
  8006f3:	ff 75 e0             	pushl  -0x20(%ebp)
  8006f6:	50                   	push   %eax
  8006f7:	51                   	push   %ecx
  8006f8:	52                   	push   %edx
  8006f9:	89 da                	mov    %ebx,%edx
  8006fb:	89 f0                	mov    %esi,%eax
  8006fd:	e8 45 fb ff ff       	call   800247 <printnum>
			break;
  800702:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800705:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800708:	83 c7 01             	add    $0x1,%edi
  80070b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80070f:	83 f8 25             	cmp    $0x25,%eax
  800712:	0f 84 2f fc ff ff    	je     800347 <vprintfmt+0x17>
			if (ch == '\0')
  800718:	85 c0                	test   %eax,%eax
  80071a:	0f 84 8b 00 00 00    	je     8007ab <vprintfmt+0x47b>
			putch(ch, putdat);
  800720:	83 ec 08             	sub    $0x8,%esp
  800723:	53                   	push   %ebx
  800724:	50                   	push   %eax
  800725:	ff d6                	call   *%esi
  800727:	83 c4 10             	add    $0x10,%esp
  80072a:	eb dc                	jmp    800708 <vprintfmt+0x3d8>
	if (lflag >= 2)
  80072c:	83 f9 01             	cmp    $0x1,%ecx
  80072f:	7e 15                	jle    800746 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  800731:	8b 45 14             	mov    0x14(%ebp),%eax
  800734:	8b 10                	mov    (%eax),%edx
  800736:	8b 48 04             	mov    0x4(%eax),%ecx
  800739:	8d 40 08             	lea    0x8(%eax),%eax
  80073c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80073f:	b8 10 00 00 00       	mov    $0x10,%eax
  800744:	eb a5                	jmp    8006eb <vprintfmt+0x3bb>
	else if (lflag)
  800746:	85 c9                	test   %ecx,%ecx
  800748:	75 17                	jne    800761 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  80074a:	8b 45 14             	mov    0x14(%ebp),%eax
  80074d:	8b 10                	mov    (%eax),%edx
  80074f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800754:	8d 40 04             	lea    0x4(%eax),%eax
  800757:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80075a:	b8 10 00 00 00       	mov    $0x10,%eax
  80075f:	eb 8a                	jmp    8006eb <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800761:	8b 45 14             	mov    0x14(%ebp),%eax
  800764:	8b 10                	mov    (%eax),%edx
  800766:	b9 00 00 00 00       	mov    $0x0,%ecx
  80076b:	8d 40 04             	lea    0x4(%eax),%eax
  80076e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800771:	b8 10 00 00 00       	mov    $0x10,%eax
  800776:	e9 70 ff ff ff       	jmp    8006eb <vprintfmt+0x3bb>
			putch(ch, putdat);
  80077b:	83 ec 08             	sub    $0x8,%esp
  80077e:	53                   	push   %ebx
  80077f:	6a 25                	push   $0x25
  800781:	ff d6                	call   *%esi
			break;
  800783:	83 c4 10             	add    $0x10,%esp
  800786:	e9 7a ff ff ff       	jmp    800705 <vprintfmt+0x3d5>
			putch('%', putdat);
  80078b:	83 ec 08             	sub    $0x8,%esp
  80078e:	53                   	push   %ebx
  80078f:	6a 25                	push   $0x25
  800791:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800793:	83 c4 10             	add    $0x10,%esp
  800796:	89 f8                	mov    %edi,%eax
  800798:	eb 03                	jmp    80079d <vprintfmt+0x46d>
  80079a:	83 e8 01             	sub    $0x1,%eax
  80079d:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007a1:	75 f7                	jne    80079a <vprintfmt+0x46a>
  8007a3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007a6:	e9 5a ff ff ff       	jmp    800705 <vprintfmt+0x3d5>
}
  8007ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007ae:	5b                   	pop    %ebx
  8007af:	5e                   	pop    %esi
  8007b0:	5f                   	pop    %edi
  8007b1:	5d                   	pop    %ebp
  8007b2:	c3                   	ret    

008007b3 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007b3:	55                   	push   %ebp
  8007b4:	89 e5                	mov    %esp,%ebp
  8007b6:	83 ec 18             	sub    $0x18,%esp
  8007b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007bf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007c2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007c6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007c9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007d0:	85 c0                	test   %eax,%eax
  8007d2:	74 26                	je     8007fa <vsnprintf+0x47>
  8007d4:	85 d2                	test   %edx,%edx
  8007d6:	7e 22                	jle    8007fa <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007d8:	ff 75 14             	pushl  0x14(%ebp)
  8007db:	ff 75 10             	pushl  0x10(%ebp)
  8007de:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007e1:	50                   	push   %eax
  8007e2:	68 f6 02 80 00       	push   $0x8002f6
  8007e7:	e8 44 fb ff ff       	call   800330 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007ef:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007f5:	83 c4 10             	add    $0x10,%esp
}
  8007f8:	c9                   	leave  
  8007f9:	c3                   	ret    
		return -E_INVAL;
  8007fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007ff:	eb f7                	jmp    8007f8 <vsnprintf+0x45>

00800801 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800801:	55                   	push   %ebp
  800802:	89 e5                	mov    %esp,%ebp
  800804:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800807:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80080a:	50                   	push   %eax
  80080b:	ff 75 10             	pushl  0x10(%ebp)
  80080e:	ff 75 0c             	pushl  0xc(%ebp)
  800811:	ff 75 08             	pushl  0x8(%ebp)
  800814:	e8 9a ff ff ff       	call   8007b3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800819:	c9                   	leave  
  80081a:	c3                   	ret    

0080081b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800821:	b8 00 00 00 00       	mov    $0x0,%eax
  800826:	eb 03                	jmp    80082b <strlen+0x10>
		n++;
  800828:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80082b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80082f:	75 f7                	jne    800828 <strlen+0xd>
	return n;
}
  800831:	5d                   	pop    %ebp
  800832:	c3                   	ret    

00800833 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800833:	55                   	push   %ebp
  800834:	89 e5                	mov    %esp,%ebp
  800836:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800839:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80083c:	b8 00 00 00 00       	mov    $0x0,%eax
  800841:	eb 03                	jmp    800846 <strnlen+0x13>
		n++;
  800843:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800846:	39 d0                	cmp    %edx,%eax
  800848:	74 06                	je     800850 <strnlen+0x1d>
  80084a:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80084e:	75 f3                	jne    800843 <strnlen+0x10>
	return n;
}
  800850:	5d                   	pop    %ebp
  800851:	c3                   	ret    

00800852 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	53                   	push   %ebx
  800856:	8b 45 08             	mov    0x8(%ebp),%eax
  800859:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80085c:	89 c2                	mov    %eax,%edx
  80085e:	83 c1 01             	add    $0x1,%ecx
  800861:	83 c2 01             	add    $0x1,%edx
  800864:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800868:	88 5a ff             	mov    %bl,-0x1(%edx)
  80086b:	84 db                	test   %bl,%bl
  80086d:	75 ef                	jne    80085e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80086f:	5b                   	pop    %ebx
  800870:	5d                   	pop    %ebp
  800871:	c3                   	ret    

00800872 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	53                   	push   %ebx
  800876:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800879:	53                   	push   %ebx
  80087a:	e8 9c ff ff ff       	call   80081b <strlen>
  80087f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800882:	ff 75 0c             	pushl  0xc(%ebp)
  800885:	01 d8                	add    %ebx,%eax
  800887:	50                   	push   %eax
  800888:	e8 c5 ff ff ff       	call   800852 <strcpy>
	return dst;
}
  80088d:	89 d8                	mov    %ebx,%eax
  80088f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800892:	c9                   	leave  
  800893:	c3                   	ret    

00800894 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	56                   	push   %esi
  800898:	53                   	push   %ebx
  800899:	8b 75 08             	mov    0x8(%ebp),%esi
  80089c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80089f:	89 f3                	mov    %esi,%ebx
  8008a1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a4:	89 f2                	mov    %esi,%edx
  8008a6:	eb 0f                	jmp    8008b7 <strncpy+0x23>
		*dst++ = *src;
  8008a8:	83 c2 01             	add    $0x1,%edx
  8008ab:	0f b6 01             	movzbl (%ecx),%eax
  8008ae:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008b1:	80 39 01             	cmpb   $0x1,(%ecx)
  8008b4:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8008b7:	39 da                	cmp    %ebx,%edx
  8008b9:	75 ed                	jne    8008a8 <strncpy+0x14>
	}
	return ret;
}
  8008bb:	89 f0                	mov    %esi,%eax
  8008bd:	5b                   	pop    %ebx
  8008be:	5e                   	pop    %esi
  8008bf:	5d                   	pop    %ebp
  8008c0:	c3                   	ret    

008008c1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	56                   	push   %esi
  8008c5:	53                   	push   %ebx
  8008c6:	8b 75 08             	mov    0x8(%ebp),%esi
  8008c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008cc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008cf:	89 f0                	mov    %esi,%eax
  8008d1:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008d5:	85 c9                	test   %ecx,%ecx
  8008d7:	75 0b                	jne    8008e4 <strlcpy+0x23>
  8008d9:	eb 17                	jmp    8008f2 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008db:	83 c2 01             	add    $0x1,%edx
  8008de:	83 c0 01             	add    $0x1,%eax
  8008e1:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8008e4:	39 d8                	cmp    %ebx,%eax
  8008e6:	74 07                	je     8008ef <strlcpy+0x2e>
  8008e8:	0f b6 0a             	movzbl (%edx),%ecx
  8008eb:	84 c9                	test   %cl,%cl
  8008ed:	75 ec                	jne    8008db <strlcpy+0x1a>
		*dst = '\0';
  8008ef:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008f2:	29 f0                	sub    %esi,%eax
}
  8008f4:	5b                   	pop    %ebx
  8008f5:	5e                   	pop    %esi
  8008f6:	5d                   	pop    %ebp
  8008f7:	c3                   	ret    

008008f8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008f8:	55                   	push   %ebp
  8008f9:	89 e5                	mov    %esp,%ebp
  8008fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008fe:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800901:	eb 06                	jmp    800909 <strcmp+0x11>
		p++, q++;
  800903:	83 c1 01             	add    $0x1,%ecx
  800906:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800909:	0f b6 01             	movzbl (%ecx),%eax
  80090c:	84 c0                	test   %al,%al
  80090e:	74 04                	je     800914 <strcmp+0x1c>
  800910:	3a 02                	cmp    (%edx),%al
  800912:	74 ef                	je     800903 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800914:	0f b6 c0             	movzbl %al,%eax
  800917:	0f b6 12             	movzbl (%edx),%edx
  80091a:	29 d0                	sub    %edx,%eax
}
  80091c:	5d                   	pop    %ebp
  80091d:	c3                   	ret    

0080091e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	53                   	push   %ebx
  800922:	8b 45 08             	mov    0x8(%ebp),%eax
  800925:	8b 55 0c             	mov    0xc(%ebp),%edx
  800928:	89 c3                	mov    %eax,%ebx
  80092a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80092d:	eb 06                	jmp    800935 <strncmp+0x17>
		n--, p++, q++;
  80092f:	83 c0 01             	add    $0x1,%eax
  800932:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800935:	39 d8                	cmp    %ebx,%eax
  800937:	74 16                	je     80094f <strncmp+0x31>
  800939:	0f b6 08             	movzbl (%eax),%ecx
  80093c:	84 c9                	test   %cl,%cl
  80093e:	74 04                	je     800944 <strncmp+0x26>
  800940:	3a 0a                	cmp    (%edx),%cl
  800942:	74 eb                	je     80092f <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800944:	0f b6 00             	movzbl (%eax),%eax
  800947:	0f b6 12             	movzbl (%edx),%edx
  80094a:	29 d0                	sub    %edx,%eax
}
  80094c:	5b                   	pop    %ebx
  80094d:	5d                   	pop    %ebp
  80094e:	c3                   	ret    
		return 0;
  80094f:	b8 00 00 00 00       	mov    $0x0,%eax
  800954:	eb f6                	jmp    80094c <strncmp+0x2e>

00800956 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800956:	55                   	push   %ebp
  800957:	89 e5                	mov    %esp,%ebp
  800959:	8b 45 08             	mov    0x8(%ebp),%eax
  80095c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800960:	0f b6 10             	movzbl (%eax),%edx
  800963:	84 d2                	test   %dl,%dl
  800965:	74 09                	je     800970 <strchr+0x1a>
		if (*s == c)
  800967:	38 ca                	cmp    %cl,%dl
  800969:	74 0a                	je     800975 <strchr+0x1f>
	for (; *s; s++)
  80096b:	83 c0 01             	add    $0x1,%eax
  80096e:	eb f0                	jmp    800960 <strchr+0xa>
			return (char *) s;
	return 0;
  800970:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800975:	5d                   	pop    %ebp
  800976:	c3                   	ret    

00800977 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
  80097a:	8b 45 08             	mov    0x8(%ebp),%eax
  80097d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800981:	eb 03                	jmp    800986 <strfind+0xf>
  800983:	83 c0 01             	add    $0x1,%eax
  800986:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800989:	38 ca                	cmp    %cl,%dl
  80098b:	74 04                	je     800991 <strfind+0x1a>
  80098d:	84 d2                	test   %dl,%dl
  80098f:	75 f2                	jne    800983 <strfind+0xc>
			break;
	return (char *) s;
}
  800991:	5d                   	pop    %ebp
  800992:	c3                   	ret    

00800993 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800993:	55                   	push   %ebp
  800994:	89 e5                	mov    %esp,%ebp
  800996:	57                   	push   %edi
  800997:	56                   	push   %esi
  800998:	53                   	push   %ebx
  800999:	8b 7d 08             	mov    0x8(%ebp),%edi
  80099c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80099f:	85 c9                	test   %ecx,%ecx
  8009a1:	74 13                	je     8009b6 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009a3:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009a9:	75 05                	jne    8009b0 <memset+0x1d>
  8009ab:	f6 c1 03             	test   $0x3,%cl
  8009ae:	74 0d                	je     8009bd <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b3:	fc                   	cld    
  8009b4:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009b6:	89 f8                	mov    %edi,%eax
  8009b8:	5b                   	pop    %ebx
  8009b9:	5e                   	pop    %esi
  8009ba:	5f                   	pop    %edi
  8009bb:	5d                   	pop    %ebp
  8009bc:	c3                   	ret    
		c &= 0xFF;
  8009bd:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009c1:	89 d3                	mov    %edx,%ebx
  8009c3:	c1 e3 08             	shl    $0x8,%ebx
  8009c6:	89 d0                	mov    %edx,%eax
  8009c8:	c1 e0 18             	shl    $0x18,%eax
  8009cb:	89 d6                	mov    %edx,%esi
  8009cd:	c1 e6 10             	shl    $0x10,%esi
  8009d0:	09 f0                	or     %esi,%eax
  8009d2:	09 c2                	or     %eax,%edx
  8009d4:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  8009d6:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009d9:	89 d0                	mov    %edx,%eax
  8009db:	fc                   	cld    
  8009dc:	f3 ab                	rep stos %eax,%es:(%edi)
  8009de:	eb d6                	jmp    8009b6 <memset+0x23>

008009e0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	57                   	push   %edi
  8009e4:	56                   	push   %esi
  8009e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009eb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009ee:	39 c6                	cmp    %eax,%esi
  8009f0:	73 35                	jae    800a27 <memmove+0x47>
  8009f2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009f5:	39 c2                	cmp    %eax,%edx
  8009f7:	76 2e                	jbe    800a27 <memmove+0x47>
		s += n;
		d += n;
  8009f9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009fc:	89 d6                	mov    %edx,%esi
  8009fe:	09 fe                	or     %edi,%esi
  800a00:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a06:	74 0c                	je     800a14 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a08:	83 ef 01             	sub    $0x1,%edi
  800a0b:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a0e:	fd                   	std    
  800a0f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a11:	fc                   	cld    
  800a12:	eb 21                	jmp    800a35 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a14:	f6 c1 03             	test   $0x3,%cl
  800a17:	75 ef                	jne    800a08 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a19:	83 ef 04             	sub    $0x4,%edi
  800a1c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a1f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a22:	fd                   	std    
  800a23:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a25:	eb ea                	jmp    800a11 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a27:	89 f2                	mov    %esi,%edx
  800a29:	09 c2                	or     %eax,%edx
  800a2b:	f6 c2 03             	test   $0x3,%dl
  800a2e:	74 09                	je     800a39 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a30:	89 c7                	mov    %eax,%edi
  800a32:	fc                   	cld    
  800a33:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a35:	5e                   	pop    %esi
  800a36:	5f                   	pop    %edi
  800a37:	5d                   	pop    %ebp
  800a38:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a39:	f6 c1 03             	test   $0x3,%cl
  800a3c:	75 f2                	jne    800a30 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a3e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a41:	89 c7                	mov    %eax,%edi
  800a43:	fc                   	cld    
  800a44:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a46:	eb ed                	jmp    800a35 <memmove+0x55>

00800a48 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a48:	55                   	push   %ebp
  800a49:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a4b:	ff 75 10             	pushl  0x10(%ebp)
  800a4e:	ff 75 0c             	pushl  0xc(%ebp)
  800a51:	ff 75 08             	pushl  0x8(%ebp)
  800a54:	e8 87 ff ff ff       	call   8009e0 <memmove>
}
  800a59:	c9                   	leave  
  800a5a:	c3                   	ret    

00800a5b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	56                   	push   %esi
  800a5f:	53                   	push   %ebx
  800a60:	8b 45 08             	mov    0x8(%ebp),%eax
  800a63:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a66:	89 c6                	mov    %eax,%esi
  800a68:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a6b:	39 f0                	cmp    %esi,%eax
  800a6d:	74 1c                	je     800a8b <memcmp+0x30>
		if (*s1 != *s2)
  800a6f:	0f b6 08             	movzbl (%eax),%ecx
  800a72:	0f b6 1a             	movzbl (%edx),%ebx
  800a75:	38 d9                	cmp    %bl,%cl
  800a77:	75 08                	jne    800a81 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a79:	83 c0 01             	add    $0x1,%eax
  800a7c:	83 c2 01             	add    $0x1,%edx
  800a7f:	eb ea                	jmp    800a6b <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a81:	0f b6 c1             	movzbl %cl,%eax
  800a84:	0f b6 db             	movzbl %bl,%ebx
  800a87:	29 d8                	sub    %ebx,%eax
  800a89:	eb 05                	jmp    800a90 <memcmp+0x35>
	}

	return 0;
  800a8b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a90:	5b                   	pop    %ebx
  800a91:	5e                   	pop    %esi
  800a92:	5d                   	pop    %ebp
  800a93:	c3                   	ret    

00800a94 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a94:	55                   	push   %ebp
  800a95:	89 e5                	mov    %esp,%ebp
  800a97:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a9d:	89 c2                	mov    %eax,%edx
  800a9f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800aa2:	39 d0                	cmp    %edx,%eax
  800aa4:	73 09                	jae    800aaf <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aa6:	38 08                	cmp    %cl,(%eax)
  800aa8:	74 05                	je     800aaf <memfind+0x1b>
	for (; s < ends; s++)
  800aaa:	83 c0 01             	add    $0x1,%eax
  800aad:	eb f3                	jmp    800aa2 <memfind+0xe>
			break;
	return (void *) s;
}
  800aaf:	5d                   	pop    %ebp
  800ab0:	c3                   	ret    

00800ab1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
  800ab4:	57                   	push   %edi
  800ab5:	56                   	push   %esi
  800ab6:	53                   	push   %ebx
  800ab7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aba:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800abd:	eb 03                	jmp    800ac2 <strtol+0x11>
		s++;
  800abf:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800ac2:	0f b6 01             	movzbl (%ecx),%eax
  800ac5:	3c 20                	cmp    $0x20,%al
  800ac7:	74 f6                	je     800abf <strtol+0xe>
  800ac9:	3c 09                	cmp    $0x9,%al
  800acb:	74 f2                	je     800abf <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800acd:	3c 2b                	cmp    $0x2b,%al
  800acf:	74 2e                	je     800aff <strtol+0x4e>
	int neg = 0;
  800ad1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800ad6:	3c 2d                	cmp    $0x2d,%al
  800ad8:	74 2f                	je     800b09 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ada:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ae0:	75 05                	jne    800ae7 <strtol+0x36>
  800ae2:	80 39 30             	cmpb   $0x30,(%ecx)
  800ae5:	74 2c                	je     800b13 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ae7:	85 db                	test   %ebx,%ebx
  800ae9:	75 0a                	jne    800af5 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aeb:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800af0:	80 39 30             	cmpb   $0x30,(%ecx)
  800af3:	74 28                	je     800b1d <strtol+0x6c>
		base = 10;
  800af5:	b8 00 00 00 00       	mov    $0x0,%eax
  800afa:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800afd:	eb 50                	jmp    800b4f <strtol+0x9e>
		s++;
  800aff:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b02:	bf 00 00 00 00       	mov    $0x0,%edi
  800b07:	eb d1                	jmp    800ada <strtol+0x29>
		s++, neg = 1;
  800b09:	83 c1 01             	add    $0x1,%ecx
  800b0c:	bf 01 00 00 00       	mov    $0x1,%edi
  800b11:	eb c7                	jmp    800ada <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b13:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b17:	74 0e                	je     800b27 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b19:	85 db                	test   %ebx,%ebx
  800b1b:	75 d8                	jne    800af5 <strtol+0x44>
		s++, base = 8;
  800b1d:	83 c1 01             	add    $0x1,%ecx
  800b20:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b25:	eb ce                	jmp    800af5 <strtol+0x44>
		s += 2, base = 16;
  800b27:	83 c1 02             	add    $0x2,%ecx
  800b2a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b2f:	eb c4                	jmp    800af5 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800b31:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b34:	89 f3                	mov    %esi,%ebx
  800b36:	80 fb 19             	cmp    $0x19,%bl
  800b39:	77 29                	ja     800b64 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b3b:	0f be d2             	movsbl %dl,%edx
  800b3e:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b41:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b44:	7d 30                	jge    800b76 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b46:	83 c1 01             	add    $0x1,%ecx
  800b49:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b4d:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b4f:	0f b6 11             	movzbl (%ecx),%edx
  800b52:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b55:	89 f3                	mov    %esi,%ebx
  800b57:	80 fb 09             	cmp    $0x9,%bl
  800b5a:	77 d5                	ja     800b31 <strtol+0x80>
			dig = *s - '0';
  800b5c:	0f be d2             	movsbl %dl,%edx
  800b5f:	83 ea 30             	sub    $0x30,%edx
  800b62:	eb dd                	jmp    800b41 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800b64:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b67:	89 f3                	mov    %esi,%ebx
  800b69:	80 fb 19             	cmp    $0x19,%bl
  800b6c:	77 08                	ja     800b76 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b6e:	0f be d2             	movsbl %dl,%edx
  800b71:	83 ea 37             	sub    $0x37,%edx
  800b74:	eb cb                	jmp    800b41 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b76:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b7a:	74 05                	je     800b81 <strtol+0xd0>
		*endptr = (char *) s;
  800b7c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b7f:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b81:	89 c2                	mov    %eax,%edx
  800b83:	f7 da                	neg    %edx
  800b85:	85 ff                	test   %edi,%edi
  800b87:	0f 45 c2             	cmovne %edx,%eax
}
  800b8a:	5b                   	pop    %ebx
  800b8b:	5e                   	pop    %esi
  800b8c:	5f                   	pop    %edi
  800b8d:	5d                   	pop    %ebp
  800b8e:	c3                   	ret    

00800b8f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	57                   	push   %edi
  800b93:	56                   	push   %esi
  800b94:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b95:	b8 00 00 00 00       	mov    $0x0,%eax
  800b9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba0:	89 c3                	mov    %eax,%ebx
  800ba2:	89 c7                	mov    %eax,%edi
  800ba4:	89 c6                	mov    %eax,%esi
  800ba6:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ba8:	5b                   	pop    %ebx
  800ba9:	5e                   	pop    %esi
  800baa:	5f                   	pop    %edi
  800bab:	5d                   	pop    %ebp
  800bac:	c3                   	ret    

00800bad <sys_cgetc>:

int
sys_cgetc(void)
{
  800bad:	55                   	push   %ebp
  800bae:	89 e5                	mov    %esp,%ebp
  800bb0:	57                   	push   %edi
  800bb1:	56                   	push   %esi
  800bb2:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bb3:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb8:	b8 01 00 00 00       	mov    $0x1,%eax
  800bbd:	89 d1                	mov    %edx,%ecx
  800bbf:	89 d3                	mov    %edx,%ebx
  800bc1:	89 d7                	mov    %edx,%edi
  800bc3:	89 d6                	mov    %edx,%esi
  800bc5:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bc7:	5b                   	pop    %ebx
  800bc8:	5e                   	pop    %esi
  800bc9:	5f                   	pop    %edi
  800bca:	5d                   	pop    %ebp
  800bcb:	c3                   	ret    

00800bcc <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bcc:	55                   	push   %ebp
  800bcd:	89 e5                	mov    %esp,%ebp
  800bcf:	57                   	push   %edi
  800bd0:	56                   	push   %esi
  800bd1:	53                   	push   %ebx
  800bd2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bd5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bda:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdd:	b8 03 00 00 00       	mov    $0x3,%eax
  800be2:	89 cb                	mov    %ecx,%ebx
  800be4:	89 cf                	mov    %ecx,%edi
  800be6:	89 ce                	mov    %ecx,%esi
  800be8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bea:	85 c0                	test   %eax,%eax
  800bec:	7f 08                	jg     800bf6 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf1:	5b                   	pop    %ebx
  800bf2:	5e                   	pop    %esi
  800bf3:	5f                   	pop    %edi
  800bf4:	5d                   	pop    %ebp
  800bf5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf6:	83 ec 0c             	sub    $0xc,%esp
  800bf9:	50                   	push   %eax
  800bfa:	6a 03                	push   $0x3
  800bfc:	68 7f 25 80 00       	push   $0x80257f
  800c01:	6a 23                	push   $0x23
  800c03:	68 9c 25 80 00       	push   $0x80259c
  800c08:	e8 4b f5 ff ff       	call   800158 <_panic>

00800c0d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c0d:	55                   	push   %ebp
  800c0e:	89 e5                	mov    %esp,%ebp
  800c10:	57                   	push   %edi
  800c11:	56                   	push   %esi
  800c12:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c13:	ba 00 00 00 00       	mov    $0x0,%edx
  800c18:	b8 02 00 00 00       	mov    $0x2,%eax
  800c1d:	89 d1                	mov    %edx,%ecx
  800c1f:	89 d3                	mov    %edx,%ebx
  800c21:	89 d7                	mov    %edx,%edi
  800c23:	89 d6                	mov    %edx,%esi
  800c25:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c27:	5b                   	pop    %ebx
  800c28:	5e                   	pop    %esi
  800c29:	5f                   	pop    %edi
  800c2a:	5d                   	pop    %ebp
  800c2b:	c3                   	ret    

00800c2c <sys_yield>:

void
sys_yield(void)
{
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
  800c2f:	57                   	push   %edi
  800c30:	56                   	push   %esi
  800c31:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c32:	ba 00 00 00 00       	mov    $0x0,%edx
  800c37:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c3c:	89 d1                	mov    %edx,%ecx
  800c3e:	89 d3                	mov    %edx,%ebx
  800c40:	89 d7                	mov    %edx,%edi
  800c42:	89 d6                	mov    %edx,%esi
  800c44:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c46:	5b                   	pop    %ebx
  800c47:	5e                   	pop    %esi
  800c48:	5f                   	pop    %edi
  800c49:	5d                   	pop    %ebp
  800c4a:	c3                   	ret    

00800c4b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	57                   	push   %edi
  800c4f:	56                   	push   %esi
  800c50:	53                   	push   %ebx
  800c51:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c54:	be 00 00 00 00       	mov    $0x0,%esi
  800c59:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5f:	b8 04 00 00 00       	mov    $0x4,%eax
  800c64:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c67:	89 f7                	mov    %esi,%edi
  800c69:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c6b:	85 c0                	test   %eax,%eax
  800c6d:	7f 08                	jg     800c77 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c72:	5b                   	pop    %ebx
  800c73:	5e                   	pop    %esi
  800c74:	5f                   	pop    %edi
  800c75:	5d                   	pop    %ebp
  800c76:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c77:	83 ec 0c             	sub    $0xc,%esp
  800c7a:	50                   	push   %eax
  800c7b:	6a 04                	push   $0x4
  800c7d:	68 7f 25 80 00       	push   $0x80257f
  800c82:	6a 23                	push   $0x23
  800c84:	68 9c 25 80 00       	push   $0x80259c
  800c89:	e8 ca f4 ff ff       	call   800158 <_panic>

00800c8e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c8e:	55                   	push   %ebp
  800c8f:	89 e5                	mov    %esp,%ebp
  800c91:	57                   	push   %edi
  800c92:	56                   	push   %esi
  800c93:	53                   	push   %ebx
  800c94:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c97:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9d:	b8 05 00 00 00       	mov    $0x5,%eax
  800ca2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ca8:	8b 75 18             	mov    0x18(%ebp),%esi
  800cab:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cad:	85 c0                	test   %eax,%eax
  800caf:	7f 08                	jg     800cb9 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb4:	5b                   	pop    %ebx
  800cb5:	5e                   	pop    %esi
  800cb6:	5f                   	pop    %edi
  800cb7:	5d                   	pop    %ebp
  800cb8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb9:	83 ec 0c             	sub    $0xc,%esp
  800cbc:	50                   	push   %eax
  800cbd:	6a 05                	push   $0x5
  800cbf:	68 7f 25 80 00       	push   $0x80257f
  800cc4:	6a 23                	push   $0x23
  800cc6:	68 9c 25 80 00       	push   $0x80259c
  800ccb:	e8 88 f4 ff ff       	call   800158 <_panic>

00800cd0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cd0:	55                   	push   %ebp
  800cd1:	89 e5                	mov    %esp,%ebp
  800cd3:	57                   	push   %edi
  800cd4:	56                   	push   %esi
  800cd5:	53                   	push   %ebx
  800cd6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cd9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cde:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce4:	b8 06 00 00 00       	mov    $0x6,%eax
  800ce9:	89 df                	mov    %ebx,%edi
  800ceb:	89 de                	mov    %ebx,%esi
  800ced:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cef:	85 c0                	test   %eax,%eax
  800cf1:	7f 08                	jg     800cfb <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cf3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf6:	5b                   	pop    %ebx
  800cf7:	5e                   	pop    %esi
  800cf8:	5f                   	pop    %edi
  800cf9:	5d                   	pop    %ebp
  800cfa:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfb:	83 ec 0c             	sub    $0xc,%esp
  800cfe:	50                   	push   %eax
  800cff:	6a 06                	push   $0x6
  800d01:	68 7f 25 80 00       	push   $0x80257f
  800d06:	6a 23                	push   $0x23
  800d08:	68 9c 25 80 00       	push   $0x80259c
  800d0d:	e8 46 f4 ff ff       	call   800158 <_panic>

00800d12 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d12:	55                   	push   %ebp
  800d13:	89 e5                	mov    %esp,%ebp
  800d15:	57                   	push   %edi
  800d16:	56                   	push   %esi
  800d17:	53                   	push   %ebx
  800d18:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d1b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d20:	8b 55 08             	mov    0x8(%ebp),%edx
  800d23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d26:	b8 08 00 00 00       	mov    $0x8,%eax
  800d2b:	89 df                	mov    %ebx,%edi
  800d2d:	89 de                	mov    %ebx,%esi
  800d2f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d31:	85 c0                	test   %eax,%eax
  800d33:	7f 08                	jg     800d3d <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d38:	5b                   	pop    %ebx
  800d39:	5e                   	pop    %esi
  800d3a:	5f                   	pop    %edi
  800d3b:	5d                   	pop    %ebp
  800d3c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3d:	83 ec 0c             	sub    $0xc,%esp
  800d40:	50                   	push   %eax
  800d41:	6a 08                	push   $0x8
  800d43:	68 7f 25 80 00       	push   $0x80257f
  800d48:	6a 23                	push   $0x23
  800d4a:	68 9c 25 80 00       	push   $0x80259c
  800d4f:	e8 04 f4 ff ff       	call   800158 <_panic>

00800d54 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
  800d57:	57                   	push   %edi
  800d58:	56                   	push   %esi
  800d59:	53                   	push   %ebx
  800d5a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d5d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d62:	8b 55 08             	mov    0x8(%ebp),%edx
  800d65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d68:	b8 09 00 00 00       	mov    $0x9,%eax
  800d6d:	89 df                	mov    %ebx,%edi
  800d6f:	89 de                	mov    %ebx,%esi
  800d71:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d73:	85 c0                	test   %eax,%eax
  800d75:	7f 08                	jg     800d7f <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7a:	5b                   	pop    %ebx
  800d7b:	5e                   	pop    %esi
  800d7c:	5f                   	pop    %edi
  800d7d:	5d                   	pop    %ebp
  800d7e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7f:	83 ec 0c             	sub    $0xc,%esp
  800d82:	50                   	push   %eax
  800d83:	6a 09                	push   $0x9
  800d85:	68 7f 25 80 00       	push   $0x80257f
  800d8a:	6a 23                	push   $0x23
  800d8c:	68 9c 25 80 00       	push   $0x80259c
  800d91:	e8 c2 f3 ff ff       	call   800158 <_panic>

00800d96 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d96:	55                   	push   %ebp
  800d97:	89 e5                	mov    %esp,%ebp
  800d99:	57                   	push   %edi
  800d9a:	56                   	push   %esi
  800d9b:	53                   	push   %ebx
  800d9c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d9f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da4:	8b 55 08             	mov    0x8(%ebp),%edx
  800da7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800daa:	b8 0a 00 00 00       	mov    $0xa,%eax
  800daf:	89 df                	mov    %ebx,%edi
  800db1:	89 de                	mov    %ebx,%esi
  800db3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800db5:	85 c0                	test   %eax,%eax
  800db7:	7f 08                	jg     800dc1 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800db9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dbc:	5b                   	pop    %ebx
  800dbd:	5e                   	pop    %esi
  800dbe:	5f                   	pop    %edi
  800dbf:	5d                   	pop    %ebp
  800dc0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc1:	83 ec 0c             	sub    $0xc,%esp
  800dc4:	50                   	push   %eax
  800dc5:	6a 0a                	push   $0xa
  800dc7:	68 7f 25 80 00       	push   $0x80257f
  800dcc:	6a 23                	push   $0x23
  800dce:	68 9c 25 80 00       	push   $0x80259c
  800dd3:	e8 80 f3 ff ff       	call   800158 <_panic>

00800dd8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dd8:	55                   	push   %ebp
  800dd9:	89 e5                	mov    %esp,%ebp
  800ddb:	57                   	push   %edi
  800ddc:	56                   	push   %esi
  800ddd:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dde:	8b 55 08             	mov    0x8(%ebp),%edx
  800de1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800de9:	be 00 00 00 00       	mov    $0x0,%esi
  800dee:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800df1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800df4:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800df6:	5b                   	pop    %ebx
  800df7:	5e                   	pop    %esi
  800df8:	5f                   	pop    %edi
  800df9:	5d                   	pop    %ebp
  800dfa:	c3                   	ret    

00800dfb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dfb:	55                   	push   %ebp
  800dfc:	89 e5                	mov    %esp,%ebp
  800dfe:	57                   	push   %edi
  800dff:	56                   	push   %esi
  800e00:	53                   	push   %ebx
  800e01:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e04:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e09:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e11:	89 cb                	mov    %ecx,%ebx
  800e13:	89 cf                	mov    %ecx,%edi
  800e15:	89 ce                	mov    %ecx,%esi
  800e17:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e19:	85 c0                	test   %eax,%eax
  800e1b:	7f 08                	jg     800e25 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e20:	5b                   	pop    %ebx
  800e21:	5e                   	pop    %esi
  800e22:	5f                   	pop    %edi
  800e23:	5d                   	pop    %ebp
  800e24:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e25:	83 ec 0c             	sub    $0xc,%esp
  800e28:	50                   	push   %eax
  800e29:	6a 0d                	push   $0xd
  800e2b:	68 7f 25 80 00       	push   $0x80257f
  800e30:	6a 23                	push   $0x23
  800e32:	68 9c 25 80 00       	push   $0x80259c
  800e37:	e8 1c f3 ff ff       	call   800158 <_panic>

00800e3c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e3c:	55                   	push   %ebp
  800e3d:	89 e5                	mov    %esp,%ebp
  800e3f:	56                   	push   %esi
  800e40:	53                   	push   %ebx
  800e41:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e44:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if((err&FEC_WR)==0 || (uvpt[PGNUM(addr)]&(PTE_W|PTE_COW))==0){
  800e46:	8b 40 04             	mov    0x4(%eax),%eax
  800e49:	83 e0 02             	and    $0x2,%eax
  800e4c:	0f 84 82 00 00 00    	je     800ed4 <pgfault+0x98>
  800e52:	89 da                	mov    %ebx,%edx
  800e54:	c1 ea 0c             	shr    $0xc,%edx
  800e57:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e5e:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800e64:	74 6e                	je     800ed4 <pgfault+0x98>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        envid_t envid = sys_getenvid();
  800e66:	e8 a2 fd ff ff       	call   800c0d <sys_getenvid>
  800e6b:	89 c6                	mov    %eax,%esi
	r = sys_page_alloc(envid,(void *)PFTEMP,PTE_P|PTE_W|PTE_U);
  800e6d:	83 ec 04             	sub    $0x4,%esp
  800e70:	6a 07                	push   $0x7
  800e72:	68 00 f0 7f 00       	push   $0x7ff000
  800e77:	50                   	push   %eax
  800e78:	e8 ce fd ff ff       	call   800c4b <sys_page_alloc>
	if(r<0) panic("pgfault:page allocation failed %e",r);
  800e7d:	83 c4 10             	add    $0x10,%esp
  800e80:	85 c0                	test   %eax,%eax
  800e82:	78 72                	js     800ef6 <pgfault+0xba>

	addr = ROUNDDOWN(addr,PGSIZE);
  800e84:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy((void *)PFTEMP,(const void *)addr,PGSIZE);
  800e8a:	83 ec 04             	sub    $0x4,%esp
  800e8d:	68 00 10 00 00       	push   $0x1000
  800e92:	53                   	push   %ebx
  800e93:	68 00 f0 7f 00       	push   $0x7ff000
  800e98:	e8 ab fb ff ff       	call   800a48 <memcpy>

	if(sys_page_map(envid,(void *)PFTEMP, envid,addr,PTE_P|PTE_W|PTE_U)<0)
  800e9d:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ea4:	53                   	push   %ebx
  800ea5:	56                   	push   %esi
  800ea6:	68 00 f0 7f 00       	push   $0x7ff000
  800eab:	56                   	push   %esi
  800eac:	e8 dd fd ff ff       	call   800c8e <sys_page_map>
  800eb1:	83 c4 20             	add    $0x20,%esp
  800eb4:	85 c0                	test   %eax,%eax
  800eb6:	78 50                	js     800f08 <pgfault+0xcc>
		panic("pgfault:page map failed\n");
	if(sys_page_unmap(envid,(void *)PFTEMP)<0)
  800eb8:	83 ec 08             	sub    $0x8,%esp
  800ebb:	68 00 f0 7f 00       	push   $0x7ff000
  800ec0:	56                   	push   %esi
  800ec1:	e8 0a fe ff ff       	call   800cd0 <sys_page_unmap>
  800ec6:	83 c4 10             	add    $0x10,%esp
  800ec9:	85 c0                	test   %eax,%eax
  800ecb:	78 4f                	js     800f1c <pgfault+0xe0>
		panic("pgfault: page upmap failed\n");
       //	panic("pgfault not implemented");
}
  800ecd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ed0:	5b                   	pop    %ebx
  800ed1:	5e                   	pop    %esi
  800ed2:	5d                   	pop    %ebp
  800ed3:	c3                   	ret    
		cprintf("Where is the error %d\n",err&FEC_WR);
  800ed4:	83 ec 08             	sub    $0x8,%esp
  800ed7:	50                   	push   %eax
  800ed8:	68 aa 25 80 00       	push   $0x8025aa
  800edd:	e8 51 f3 ff ff       	call   800233 <cprintf>
		panic("pgfault:invalid user trap");
  800ee2:	83 c4 0c             	add    $0xc,%esp
  800ee5:	68 c1 25 80 00       	push   $0x8025c1
  800eea:	6a 1e                	push   $0x1e
  800eec:	68 db 25 80 00       	push   $0x8025db
  800ef1:	e8 62 f2 ff ff       	call   800158 <_panic>
	if(r<0) panic("pgfault:page allocation failed %e",r);
  800ef6:	50                   	push   %eax
  800ef7:	68 c8 26 80 00       	push   $0x8026c8
  800efc:	6a 29                	push   $0x29
  800efe:	68 db 25 80 00       	push   $0x8025db
  800f03:	e8 50 f2 ff ff       	call   800158 <_panic>
		panic("pgfault:page map failed\n");
  800f08:	83 ec 04             	sub    $0x4,%esp
  800f0b:	68 e6 25 80 00       	push   $0x8025e6
  800f10:	6a 2f                	push   $0x2f
  800f12:	68 db 25 80 00       	push   $0x8025db
  800f17:	e8 3c f2 ff ff       	call   800158 <_panic>
		panic("pgfault: page upmap failed\n");
  800f1c:	83 ec 04             	sub    $0x4,%esp
  800f1f:	68 ff 25 80 00       	push   $0x8025ff
  800f24:	6a 31                	push   $0x31
  800f26:	68 db 25 80 00       	push   $0x8025db
  800f2b:	e8 28 f2 ff ff       	call   800158 <_panic>

00800f30 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f30:	55                   	push   %ebp
  800f31:	89 e5                	mov    %esp,%ebp
  800f33:	57                   	push   %edi
  800f34:	56                   	push   %esi
  800f35:	53                   	push   %ebx
  800f36:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	set_pgfault_handler(pgfault);
  800f39:	68 3c 0e 80 00       	push   $0x800e3c
  800f3e:	e8 b9 0f 00 00       	call   801efc <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f43:	b8 07 00 00 00       	mov    $0x7,%eax
  800f48:	cd 30                	int    $0x30
  800f4a:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800f4d:	89 45 e0             	mov    %eax,-0x20(%ebp)
       
	envid_t envid = sys_exofork();
	uintptr_t addr;
  
	if(envid<0) panic("sys_exofork failed\n");
  800f50:	83 c4 10             	add    $0x10,%esp
  800f53:	85 c0                	test   %eax,%eax
  800f55:	78 27                	js     800f7e <fork+0x4e>
	if(envid==0){
	  thisenv = &envs[ENVX(sys_getenvid())];
	  return 0;
	}

	for(addr=(uintptr_t)UTEXT; addr<USTACKTOP;addr+=PGSIZE){
  800f57:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if(envid==0){
  800f5c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800f60:	75 5e                	jne    800fc0 <fork+0x90>
	  thisenv = &envs[ENVX(sys_getenvid())];
  800f62:	e8 a6 fc ff ff       	call   800c0d <sys_getenvid>
  800f67:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f6c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f6f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f74:	a3 04 40 80 00       	mov    %eax,0x804004
	  return 0;
  800f79:	e9 fc 00 00 00       	jmp    80107a <fork+0x14a>
	if(envid<0) panic("sys_exofork failed\n");
  800f7e:	83 ec 04             	sub    $0x4,%esp
  800f81:	68 1b 26 80 00       	push   $0x80261b
  800f86:	6a 77                	push   $0x77
  800f88:	68 db 25 80 00       	push   $0x8025db
  800f8d:	e8 c6 f1 ff ff       	call   800158 <_panic>
          if((r=sys_page_map(parent_envid,va,envid,va,uvpt[pn]&PTE_SYSCALL))<0)
  800f92:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f99:	83 ec 0c             	sub    $0xc,%esp
  800f9c:	25 07 0e 00 00       	and    $0xe07,%eax
  800fa1:	50                   	push   %eax
  800fa2:	57                   	push   %edi
  800fa3:	ff 75 e0             	pushl  -0x20(%ebp)
  800fa6:	57                   	push   %edi
  800fa7:	ff 75 e4             	pushl  -0x1c(%ebp)
  800faa:	e8 df fc ff ff       	call   800c8e <sys_page_map>
  800faf:	83 c4 20             	add    $0x20,%esp
	for(addr=(uintptr_t)UTEXT; addr<USTACKTOP;addr+=PGSIZE){
  800fb2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fb8:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800fbe:	74 76                	je     801036 <fork+0x106>
	   if((uvpd[PDX(addr)]&PTE_P) && uvpt[PGNUM(addr)] & PTE_P)
  800fc0:	89 d8                	mov    %ebx,%eax
  800fc2:	c1 e8 16             	shr    $0x16,%eax
  800fc5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fcc:	a8 01                	test   $0x1,%al
  800fce:	74 e2                	je     800fb2 <fork+0x82>
  800fd0:	89 de                	mov    %ebx,%esi
  800fd2:	c1 ee 0c             	shr    $0xc,%esi
  800fd5:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fdc:	a8 01                	test   $0x1,%al
  800fde:	74 d2                	je     800fb2 <fork+0x82>
        envid_t parent_envid = sys_getenvid();
  800fe0:	e8 28 fc ff ff       	call   800c0d <sys_getenvid>
  800fe5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	void *va = (void *)(pn*PGSIZE);
  800fe8:	89 f7                	mov    %esi,%edi
  800fea:	c1 e7 0c             	shl    $0xc,%edi
        if(uvpt[pn] & PTE_SHARE){
  800fed:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800ff4:	f6 c4 04             	test   $0x4,%ah
  800ff7:	75 99                	jne    800f92 <fork+0x62>
	if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)){
  800ff9:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801000:	a8 02                	test   $0x2,%al
  801002:	0f 85 ed 00 00 00    	jne    8010f5 <fork+0x1c5>
  801008:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80100f:	f6 c4 08             	test   $0x8,%ah
  801012:	0f 85 dd 00 00 00    	jne    8010f5 <fork+0x1c5>
	 if((r=sys_page_map(parent_envid,va,envid,va,perm))<0)
  801018:	83 ec 0c             	sub    $0xc,%esp
  80101b:	6a 05                	push   $0x5
  80101d:	57                   	push   %edi
  80101e:	ff 75 e0             	pushl  -0x20(%ebp)
  801021:	57                   	push   %edi
  801022:	ff 75 e4             	pushl  -0x1c(%ebp)
  801025:	e8 64 fc ff ff       	call   800c8e <sys_page_map>
  80102a:	83 c4 20             	add    $0x20,%esp
  80102d:	85 c0                	test   %eax,%eax
  80102f:	79 81                	jns    800fb2 <fork+0x82>
  801031:	e9 db 00 00 00       	jmp    801111 <fork+0x1e1>
		   duppage(envid,PGNUM(addr));
	}
        
	int r;
	if((r=sys_page_alloc(envid,(void *)UXSTACKTOP-PGSIZE,PTE_U|PTE_P|PTE_W))<0)
  801036:	83 ec 04             	sub    $0x4,%esp
  801039:	6a 07                	push   $0x7
  80103b:	68 00 f0 bf ee       	push   $0xeebff000
  801040:	ff 75 dc             	pushl  -0x24(%ebp)
  801043:	e8 03 fc ff ff       	call   800c4b <sys_page_alloc>
  801048:	83 c4 10             	add    $0x10,%esp
  80104b:	85 c0                	test   %eax,%eax
  80104d:	78 36                	js     801085 <fork+0x155>
		panic("fork:page alloc failed %e\n",r);

	extern void _pgfault_upcall();
	if((r = sys_env_set_pgfault_upcall(envid,_pgfault_upcall)))
  80104f:	83 ec 08             	sub    $0x8,%esp
  801052:	68 61 1f 80 00       	push   $0x801f61
  801057:	ff 75 dc             	pushl  -0x24(%ebp)
  80105a:	e8 37 fd ff ff       	call   800d96 <sys_env_set_pgfault_upcall>
  80105f:	83 c4 10             	add    $0x10,%esp
  801062:	85 c0                	test   %eax,%eax
  801064:	75 34                	jne    80109a <fork+0x16a>
		panic("fork:set upcall failed %e\n",r);
	if((r = sys_env_set_status(envid,ENV_RUNNABLE))<0)
  801066:	83 ec 08             	sub    $0x8,%esp
  801069:	6a 02                	push   $0x2
  80106b:	ff 75 dc             	pushl  -0x24(%ebp)
  80106e:	e8 9f fc ff ff       	call   800d12 <sys_env_set_status>
  801073:	83 c4 10             	add    $0x10,%esp
  801076:	85 c0                	test   %eax,%eax
  801078:	78 35                	js     8010af <fork+0x17f>
		panic("fork:set status failed %e\n",r);
	//cprintf("forkid= %d\n", envid);
	return envid;
       	
}
  80107a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80107d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801080:	5b                   	pop    %ebx
  801081:	5e                   	pop    %esi
  801082:	5f                   	pop    %edi
  801083:	5d                   	pop    %ebp
  801084:	c3                   	ret    
		panic("fork:page alloc failed %e\n",r);
  801085:	50                   	push   %eax
  801086:	68 5f 26 80 00       	push   $0x80265f
  80108b:	68 84 00 00 00       	push   $0x84
  801090:	68 db 25 80 00       	push   $0x8025db
  801095:	e8 be f0 ff ff       	call   800158 <_panic>
		panic("fork:set upcall failed %e\n",r);
  80109a:	50                   	push   %eax
  80109b:	68 7a 26 80 00       	push   $0x80267a
  8010a0:	68 88 00 00 00       	push   $0x88
  8010a5:	68 db 25 80 00       	push   $0x8025db
  8010aa:	e8 a9 f0 ff ff       	call   800158 <_panic>
		panic("fork:set status failed %e\n",r);
  8010af:	50                   	push   %eax
  8010b0:	68 95 26 80 00       	push   $0x802695
  8010b5:	68 8a 00 00 00       	push   $0x8a
  8010ba:	68 db 25 80 00       	push   $0x8025db
  8010bf:	e8 94 f0 ff ff       	call   800158 <_panic>
		if( (r=sys_page_map(parent_envid,va,parent_envid,va,perm))<0){
  8010c4:	83 ec 0c             	sub    $0xc,%esp
  8010c7:	68 05 08 00 00       	push   $0x805
  8010cc:	57                   	push   %edi
  8010cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010d0:	50                   	push   %eax
  8010d1:	57                   	push   %edi
  8010d2:	50                   	push   %eax
  8010d3:	e8 b6 fb ff ff       	call   800c8e <sys_page_map>
  8010d8:	83 c4 20             	add    $0x20,%esp
  8010db:	85 c0                	test   %eax,%eax
  8010dd:	0f 89 cf fe ff ff    	jns    800fb2 <fork+0x82>
		 panic("duppage:map02 failed %e",r);
  8010e3:	50                   	push   %eax
  8010e4:	68 47 26 80 00       	push   $0x802647
  8010e9:	6a 56                	push   $0x56
  8010eb:	68 db 25 80 00       	push   $0x8025db
  8010f0:	e8 63 f0 ff ff       	call   800158 <_panic>
	 if((r=sys_page_map(parent_envid,va,envid,va,perm))<0)
  8010f5:	83 ec 0c             	sub    $0xc,%esp
  8010f8:	68 05 08 00 00       	push   $0x805
  8010fd:	57                   	push   %edi
  8010fe:	ff 75 e0             	pushl  -0x20(%ebp)
  801101:	57                   	push   %edi
  801102:	ff 75 e4             	pushl  -0x1c(%ebp)
  801105:	e8 84 fb ff ff       	call   800c8e <sys_page_map>
  80110a:	83 c4 20             	add    $0x20,%esp
  80110d:	85 c0                	test   %eax,%eax
  80110f:	79 b3                	jns    8010c4 <fork+0x194>
		 panic("duppage:map01 failed %e",r);
  801111:	50                   	push   %eax
  801112:	68 2f 26 80 00       	push   $0x80262f
  801117:	6a 53                	push   $0x53
  801119:	68 db 25 80 00       	push   $0x8025db
  80111e:	e8 35 f0 ff ff       	call   800158 <_panic>

00801123 <sfork>:

// Challenge!
int
sfork(void)
{
  801123:	55                   	push   %ebp
  801124:	89 e5                	mov    %esp,%ebp
  801126:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801129:	68 b0 26 80 00       	push   $0x8026b0
  80112e:	68 94 00 00 00       	push   $0x94
  801133:	68 db 25 80 00       	push   $0x8025db
  801138:	e8 1b f0 ff ff       	call   800158 <_panic>

0080113d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80113d:	55                   	push   %ebp
  80113e:	89 e5                	mov    %esp,%ebp
  801140:	56                   	push   %esi
  801141:	53                   	push   %ebx
  801142:	8b 75 08             	mov    0x8(%ebp),%esi
  801145:	8b 45 0c             	mov    0xc(%ebp),%eax
  801148:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        //	panic("ipc_recv not implemented");
        int r;
       	if(pg!=NULL){
  80114b:	85 c0                	test   %eax,%eax
  80114d:	74 3b                	je     80118a <ipc_recv+0x4d>
	  r = sys_ipc_recv(pg);
  80114f:	83 ec 0c             	sub    $0xc,%esp
  801152:	50                   	push   %eax
  801153:	e8 a3 fc ff ff       	call   800dfb <sys_ipc_recv>
  801158:	83 c4 10             	add    $0x10,%esp
	}else
	  r = sys_ipc_recv((void *)UTOP);
	if(r<0){
  80115b:	85 c0                	test   %eax,%eax
  80115d:	78 3d                	js     80119c <ipc_recv+0x5f>
	if(perm_store!=NULL){
		*perm_store = 0;
            }
        	return r;
           }else{
	     if(from_env_store!=NULL)
  80115f:	85 f6                	test   %esi,%esi
  801161:	74 0a                	je     80116d <ipc_recv+0x30>
		     *from_env_store = thisenv->env_ipc_from;
  801163:	a1 04 40 80 00       	mov    0x804004,%eax
  801168:	8b 40 74             	mov    0x74(%eax),%eax
  80116b:	89 06                	mov    %eax,(%esi)
	     if(perm_store != NULL)
  80116d:	85 db                	test   %ebx,%ebx
  80116f:	74 0a                	je     80117b <ipc_recv+0x3e>
		     *perm_store = thisenv->env_ipc_perm;
  801171:	a1 04 40 80 00       	mov    0x804004,%eax
  801176:	8b 40 78             	mov    0x78(%eax),%eax
  801179:	89 03                	mov    %eax,(%ebx)
	     return thisenv->env_ipc_value;
  80117b:	a1 04 40 80 00       	mov    0x804004,%eax
  801180:	8b 40 70             	mov    0x70(%eax),%eax
	   }

}
  801183:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801186:	5b                   	pop    %ebx
  801187:	5e                   	pop    %esi
  801188:	5d                   	pop    %ebp
  801189:	c3                   	ret    
	  r = sys_ipc_recv((void *)UTOP);
  80118a:	83 ec 0c             	sub    $0xc,%esp
  80118d:	68 00 00 c0 ee       	push   $0xeec00000
  801192:	e8 64 fc ff ff       	call   800dfb <sys_ipc_recv>
  801197:	83 c4 10             	add    $0x10,%esp
  80119a:	eb bf                	jmp    80115b <ipc_recv+0x1e>
	if(from_env_store!=NULL){
  80119c:	85 f6                	test   %esi,%esi
  80119e:	74 06                	je     8011a6 <ipc_recv+0x69>
	  *from_env_store = 0;
  8011a0:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if(perm_store!=NULL){
  8011a6:	85 db                	test   %ebx,%ebx
  8011a8:	74 d9                	je     801183 <ipc_recv+0x46>
		*perm_store = 0;
  8011aa:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8011b0:	eb d1                	jmp    801183 <ipc_recv+0x46>

008011b2 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8011b2:	55                   	push   %ebp
  8011b3:	89 e5                	mov    %esp,%ebp
  8011b5:	57                   	push   %edi
  8011b6:	56                   	push   %esi
  8011b7:	53                   	push   %ebx
  8011b8:	83 ec 0c             	sub    $0xc,%esp
  8011bb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011be:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011c1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if(pg==NULL) pg = (void *)UTOP;
  8011c4:	85 db                	test   %ebx,%ebx
  8011c6:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8011cb:	0f 44 d8             	cmove  %eax,%ebx
	while((r=sys_ipc_try_send(to_env,val,pg,perm))<0){
  8011ce:	ff 75 14             	pushl  0x14(%ebp)
  8011d1:	53                   	push   %ebx
  8011d2:	56                   	push   %esi
  8011d3:	57                   	push   %edi
  8011d4:	e8 ff fb ff ff       	call   800dd8 <sys_ipc_try_send>
  8011d9:	83 c4 10             	add    $0x10,%esp
  8011dc:	85 c0                	test   %eax,%eax
  8011de:	79 20                	jns    801200 <ipc_send+0x4e>
	    if(r!=-E_IPC_NOT_RECV){
  8011e0:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8011e3:	75 07                	jne    8011ec <ipc_send+0x3a>
		    panic("ipc_send:send message failed\n");
	    }
	    sys_yield();
  8011e5:	e8 42 fa ff ff       	call   800c2c <sys_yield>
  8011ea:	eb e2                	jmp    8011ce <ipc_send+0x1c>
		    panic("ipc_send:send message failed\n");
  8011ec:	83 ec 04             	sub    $0x4,%esp
  8011ef:	68 ea 26 80 00       	push   $0x8026ea
  8011f4:	6a 43                	push   $0x43
  8011f6:	68 08 27 80 00       	push   $0x802708
  8011fb:	e8 58 ef ff ff       	call   800158 <_panic>
	}

}
  801200:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801203:	5b                   	pop    %ebx
  801204:	5e                   	pop    %esi
  801205:	5f                   	pop    %edi
  801206:	5d                   	pop    %ebp
  801207:	c3                   	ret    

00801208 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801208:	55                   	push   %ebp
  801209:	89 e5                	mov    %esp,%ebp
  80120b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80120e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801213:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801216:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80121c:	8b 52 50             	mov    0x50(%edx),%edx
  80121f:	39 ca                	cmp    %ecx,%edx
  801221:	74 11                	je     801234 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801223:	83 c0 01             	add    $0x1,%eax
  801226:	3d 00 04 00 00       	cmp    $0x400,%eax
  80122b:	75 e6                	jne    801213 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  80122d:	b8 00 00 00 00       	mov    $0x0,%eax
  801232:	eb 0b                	jmp    80123f <ipc_find_env+0x37>
			return envs[i].env_id;
  801234:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801237:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80123c:	8b 40 48             	mov    0x48(%eax),%eax
}
  80123f:	5d                   	pop    %ebp
  801240:	c3                   	ret    

00801241 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801241:	55                   	push   %ebp
  801242:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801244:	8b 45 08             	mov    0x8(%ebp),%eax
  801247:	05 00 00 00 30       	add    $0x30000000,%eax
  80124c:	c1 e8 0c             	shr    $0xc,%eax
}
  80124f:	5d                   	pop    %ebp
  801250:	c3                   	ret    

00801251 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801251:	55                   	push   %ebp
  801252:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801254:	8b 45 08             	mov    0x8(%ebp),%eax
  801257:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80125c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801261:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801266:	5d                   	pop    %ebp
  801267:	c3                   	ret    

00801268 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801268:	55                   	push   %ebp
  801269:	89 e5                	mov    %esp,%ebp
  80126b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80126e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801273:	89 c2                	mov    %eax,%edx
  801275:	c1 ea 16             	shr    $0x16,%edx
  801278:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80127f:	f6 c2 01             	test   $0x1,%dl
  801282:	74 2a                	je     8012ae <fd_alloc+0x46>
  801284:	89 c2                	mov    %eax,%edx
  801286:	c1 ea 0c             	shr    $0xc,%edx
  801289:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801290:	f6 c2 01             	test   $0x1,%dl
  801293:	74 19                	je     8012ae <fd_alloc+0x46>
  801295:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  80129a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80129f:	75 d2                	jne    801273 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012a1:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012a7:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8012ac:	eb 07                	jmp    8012b5 <fd_alloc+0x4d>
			*fd_store = fd;
  8012ae:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012b5:	5d                   	pop    %ebp
  8012b6:	c3                   	ret    

008012b7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012b7:	55                   	push   %ebp
  8012b8:	89 e5                	mov    %esp,%ebp
  8012ba:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012bd:	83 f8 1f             	cmp    $0x1f,%eax
  8012c0:	77 36                	ja     8012f8 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012c2:	c1 e0 0c             	shl    $0xc,%eax
  8012c5:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012ca:	89 c2                	mov    %eax,%edx
  8012cc:	c1 ea 16             	shr    $0x16,%edx
  8012cf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012d6:	f6 c2 01             	test   $0x1,%dl
  8012d9:	74 24                	je     8012ff <fd_lookup+0x48>
  8012db:	89 c2                	mov    %eax,%edx
  8012dd:	c1 ea 0c             	shr    $0xc,%edx
  8012e0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012e7:	f6 c2 01             	test   $0x1,%dl
  8012ea:	74 1a                	je     801306 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012ef:	89 02                	mov    %eax,(%edx)
	return 0;
  8012f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012f6:	5d                   	pop    %ebp
  8012f7:	c3                   	ret    
		return -E_INVAL;
  8012f8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012fd:	eb f7                	jmp    8012f6 <fd_lookup+0x3f>
		return -E_INVAL;
  8012ff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801304:	eb f0                	jmp    8012f6 <fd_lookup+0x3f>
  801306:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80130b:	eb e9                	jmp    8012f6 <fd_lookup+0x3f>

0080130d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80130d:	55                   	push   %ebp
  80130e:	89 e5                	mov    %esp,%ebp
  801310:	83 ec 08             	sub    $0x8,%esp
  801313:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801316:	ba 94 27 80 00       	mov    $0x802794,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80131b:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  801320:	39 08                	cmp    %ecx,(%eax)
  801322:	74 33                	je     801357 <dev_lookup+0x4a>
  801324:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  801327:	8b 02                	mov    (%edx),%eax
  801329:	85 c0                	test   %eax,%eax
  80132b:	75 f3                	jne    801320 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80132d:	a1 04 40 80 00       	mov    0x804004,%eax
  801332:	8b 40 48             	mov    0x48(%eax),%eax
  801335:	83 ec 04             	sub    $0x4,%esp
  801338:	51                   	push   %ecx
  801339:	50                   	push   %eax
  80133a:	68 14 27 80 00       	push   $0x802714
  80133f:	e8 ef ee ff ff       	call   800233 <cprintf>
	*dev = 0;
  801344:	8b 45 0c             	mov    0xc(%ebp),%eax
  801347:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80134d:	83 c4 10             	add    $0x10,%esp
  801350:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801355:	c9                   	leave  
  801356:	c3                   	ret    
			*dev = devtab[i];
  801357:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80135a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80135c:	b8 00 00 00 00       	mov    $0x0,%eax
  801361:	eb f2                	jmp    801355 <dev_lookup+0x48>

00801363 <fd_close>:
{
  801363:	55                   	push   %ebp
  801364:	89 e5                	mov    %esp,%ebp
  801366:	57                   	push   %edi
  801367:	56                   	push   %esi
  801368:	53                   	push   %ebx
  801369:	83 ec 1c             	sub    $0x1c,%esp
  80136c:	8b 75 08             	mov    0x8(%ebp),%esi
  80136f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801372:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801375:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801376:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80137c:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80137f:	50                   	push   %eax
  801380:	e8 32 ff ff ff       	call   8012b7 <fd_lookup>
  801385:	89 c3                	mov    %eax,%ebx
  801387:	83 c4 08             	add    $0x8,%esp
  80138a:	85 c0                	test   %eax,%eax
  80138c:	78 05                	js     801393 <fd_close+0x30>
	    || fd != fd2)
  80138e:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801391:	74 16                	je     8013a9 <fd_close+0x46>
		return (must_exist ? r : 0);
  801393:	89 f8                	mov    %edi,%eax
  801395:	84 c0                	test   %al,%al
  801397:	b8 00 00 00 00       	mov    $0x0,%eax
  80139c:	0f 44 d8             	cmove  %eax,%ebx
}
  80139f:	89 d8                	mov    %ebx,%eax
  8013a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013a4:	5b                   	pop    %ebx
  8013a5:	5e                   	pop    %esi
  8013a6:	5f                   	pop    %edi
  8013a7:	5d                   	pop    %ebp
  8013a8:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013a9:	83 ec 08             	sub    $0x8,%esp
  8013ac:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8013af:	50                   	push   %eax
  8013b0:	ff 36                	pushl  (%esi)
  8013b2:	e8 56 ff ff ff       	call   80130d <dev_lookup>
  8013b7:	89 c3                	mov    %eax,%ebx
  8013b9:	83 c4 10             	add    $0x10,%esp
  8013bc:	85 c0                	test   %eax,%eax
  8013be:	78 15                	js     8013d5 <fd_close+0x72>
		if (dev->dev_close)
  8013c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013c3:	8b 40 10             	mov    0x10(%eax),%eax
  8013c6:	85 c0                	test   %eax,%eax
  8013c8:	74 1b                	je     8013e5 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  8013ca:	83 ec 0c             	sub    $0xc,%esp
  8013cd:	56                   	push   %esi
  8013ce:	ff d0                	call   *%eax
  8013d0:	89 c3                	mov    %eax,%ebx
  8013d2:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8013d5:	83 ec 08             	sub    $0x8,%esp
  8013d8:	56                   	push   %esi
  8013d9:	6a 00                	push   $0x0
  8013db:	e8 f0 f8 ff ff       	call   800cd0 <sys_page_unmap>
	return r;
  8013e0:	83 c4 10             	add    $0x10,%esp
  8013e3:	eb ba                	jmp    80139f <fd_close+0x3c>
			r = 0;
  8013e5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013ea:	eb e9                	jmp    8013d5 <fd_close+0x72>

008013ec <close>:

int
close(int fdnum)
{
  8013ec:	55                   	push   %ebp
  8013ed:	89 e5                	mov    %esp,%ebp
  8013ef:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013f5:	50                   	push   %eax
  8013f6:	ff 75 08             	pushl  0x8(%ebp)
  8013f9:	e8 b9 fe ff ff       	call   8012b7 <fd_lookup>
  8013fe:	83 c4 08             	add    $0x8,%esp
  801401:	85 c0                	test   %eax,%eax
  801403:	78 10                	js     801415 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801405:	83 ec 08             	sub    $0x8,%esp
  801408:	6a 01                	push   $0x1
  80140a:	ff 75 f4             	pushl  -0xc(%ebp)
  80140d:	e8 51 ff ff ff       	call   801363 <fd_close>
  801412:	83 c4 10             	add    $0x10,%esp
}
  801415:	c9                   	leave  
  801416:	c3                   	ret    

00801417 <close_all>:

void
close_all(void)
{
  801417:	55                   	push   %ebp
  801418:	89 e5                	mov    %esp,%ebp
  80141a:	53                   	push   %ebx
  80141b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80141e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801423:	83 ec 0c             	sub    $0xc,%esp
  801426:	53                   	push   %ebx
  801427:	e8 c0 ff ff ff       	call   8013ec <close>
	for (i = 0; i < MAXFD; i++)
  80142c:	83 c3 01             	add    $0x1,%ebx
  80142f:	83 c4 10             	add    $0x10,%esp
  801432:	83 fb 20             	cmp    $0x20,%ebx
  801435:	75 ec                	jne    801423 <close_all+0xc>
}
  801437:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80143a:	c9                   	leave  
  80143b:	c3                   	ret    

0080143c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80143c:	55                   	push   %ebp
  80143d:	89 e5                	mov    %esp,%ebp
  80143f:	57                   	push   %edi
  801440:	56                   	push   %esi
  801441:	53                   	push   %ebx
  801442:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801445:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801448:	50                   	push   %eax
  801449:	ff 75 08             	pushl  0x8(%ebp)
  80144c:	e8 66 fe ff ff       	call   8012b7 <fd_lookup>
  801451:	89 c3                	mov    %eax,%ebx
  801453:	83 c4 08             	add    $0x8,%esp
  801456:	85 c0                	test   %eax,%eax
  801458:	0f 88 81 00 00 00    	js     8014df <dup+0xa3>
		return r;
	close(newfdnum);
  80145e:	83 ec 0c             	sub    $0xc,%esp
  801461:	ff 75 0c             	pushl  0xc(%ebp)
  801464:	e8 83 ff ff ff       	call   8013ec <close>

	newfd = INDEX2FD(newfdnum);
  801469:	8b 75 0c             	mov    0xc(%ebp),%esi
  80146c:	c1 e6 0c             	shl    $0xc,%esi
  80146f:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801475:	83 c4 04             	add    $0x4,%esp
  801478:	ff 75 e4             	pushl  -0x1c(%ebp)
  80147b:	e8 d1 fd ff ff       	call   801251 <fd2data>
  801480:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801482:	89 34 24             	mov    %esi,(%esp)
  801485:	e8 c7 fd ff ff       	call   801251 <fd2data>
  80148a:	83 c4 10             	add    $0x10,%esp
  80148d:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80148f:	89 d8                	mov    %ebx,%eax
  801491:	c1 e8 16             	shr    $0x16,%eax
  801494:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80149b:	a8 01                	test   $0x1,%al
  80149d:	74 11                	je     8014b0 <dup+0x74>
  80149f:	89 d8                	mov    %ebx,%eax
  8014a1:	c1 e8 0c             	shr    $0xc,%eax
  8014a4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014ab:	f6 c2 01             	test   $0x1,%dl
  8014ae:	75 39                	jne    8014e9 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014b0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014b3:	89 d0                	mov    %edx,%eax
  8014b5:	c1 e8 0c             	shr    $0xc,%eax
  8014b8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014bf:	83 ec 0c             	sub    $0xc,%esp
  8014c2:	25 07 0e 00 00       	and    $0xe07,%eax
  8014c7:	50                   	push   %eax
  8014c8:	56                   	push   %esi
  8014c9:	6a 00                	push   $0x0
  8014cb:	52                   	push   %edx
  8014cc:	6a 00                	push   $0x0
  8014ce:	e8 bb f7 ff ff       	call   800c8e <sys_page_map>
  8014d3:	89 c3                	mov    %eax,%ebx
  8014d5:	83 c4 20             	add    $0x20,%esp
  8014d8:	85 c0                	test   %eax,%eax
  8014da:	78 31                	js     80150d <dup+0xd1>
		goto err;

	return newfdnum;
  8014dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8014df:	89 d8                	mov    %ebx,%eax
  8014e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014e4:	5b                   	pop    %ebx
  8014e5:	5e                   	pop    %esi
  8014e6:	5f                   	pop    %edi
  8014e7:	5d                   	pop    %ebp
  8014e8:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014e9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014f0:	83 ec 0c             	sub    $0xc,%esp
  8014f3:	25 07 0e 00 00       	and    $0xe07,%eax
  8014f8:	50                   	push   %eax
  8014f9:	57                   	push   %edi
  8014fa:	6a 00                	push   $0x0
  8014fc:	53                   	push   %ebx
  8014fd:	6a 00                	push   $0x0
  8014ff:	e8 8a f7 ff ff       	call   800c8e <sys_page_map>
  801504:	89 c3                	mov    %eax,%ebx
  801506:	83 c4 20             	add    $0x20,%esp
  801509:	85 c0                	test   %eax,%eax
  80150b:	79 a3                	jns    8014b0 <dup+0x74>
	sys_page_unmap(0, newfd);
  80150d:	83 ec 08             	sub    $0x8,%esp
  801510:	56                   	push   %esi
  801511:	6a 00                	push   $0x0
  801513:	e8 b8 f7 ff ff       	call   800cd0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801518:	83 c4 08             	add    $0x8,%esp
  80151b:	57                   	push   %edi
  80151c:	6a 00                	push   $0x0
  80151e:	e8 ad f7 ff ff       	call   800cd0 <sys_page_unmap>
	return r;
  801523:	83 c4 10             	add    $0x10,%esp
  801526:	eb b7                	jmp    8014df <dup+0xa3>

00801528 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801528:	55                   	push   %ebp
  801529:	89 e5                	mov    %esp,%ebp
  80152b:	53                   	push   %ebx
  80152c:	83 ec 14             	sub    $0x14,%esp
  80152f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801532:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801535:	50                   	push   %eax
  801536:	53                   	push   %ebx
  801537:	e8 7b fd ff ff       	call   8012b7 <fd_lookup>
  80153c:	83 c4 08             	add    $0x8,%esp
  80153f:	85 c0                	test   %eax,%eax
  801541:	78 3f                	js     801582 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801543:	83 ec 08             	sub    $0x8,%esp
  801546:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801549:	50                   	push   %eax
  80154a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80154d:	ff 30                	pushl  (%eax)
  80154f:	e8 b9 fd ff ff       	call   80130d <dev_lookup>
  801554:	83 c4 10             	add    $0x10,%esp
  801557:	85 c0                	test   %eax,%eax
  801559:	78 27                	js     801582 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80155b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80155e:	8b 42 08             	mov    0x8(%edx),%eax
  801561:	83 e0 03             	and    $0x3,%eax
  801564:	83 f8 01             	cmp    $0x1,%eax
  801567:	74 1e                	je     801587 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801569:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80156c:	8b 40 08             	mov    0x8(%eax),%eax
  80156f:	85 c0                	test   %eax,%eax
  801571:	74 35                	je     8015a8 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801573:	83 ec 04             	sub    $0x4,%esp
  801576:	ff 75 10             	pushl  0x10(%ebp)
  801579:	ff 75 0c             	pushl  0xc(%ebp)
  80157c:	52                   	push   %edx
  80157d:	ff d0                	call   *%eax
  80157f:	83 c4 10             	add    $0x10,%esp
}
  801582:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801585:	c9                   	leave  
  801586:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801587:	a1 04 40 80 00       	mov    0x804004,%eax
  80158c:	8b 40 48             	mov    0x48(%eax),%eax
  80158f:	83 ec 04             	sub    $0x4,%esp
  801592:	53                   	push   %ebx
  801593:	50                   	push   %eax
  801594:	68 58 27 80 00       	push   $0x802758
  801599:	e8 95 ec ff ff       	call   800233 <cprintf>
		return -E_INVAL;
  80159e:	83 c4 10             	add    $0x10,%esp
  8015a1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015a6:	eb da                	jmp    801582 <read+0x5a>
		return -E_NOT_SUPP;
  8015a8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015ad:	eb d3                	jmp    801582 <read+0x5a>

008015af <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015af:	55                   	push   %ebp
  8015b0:	89 e5                	mov    %esp,%ebp
  8015b2:	57                   	push   %edi
  8015b3:	56                   	push   %esi
  8015b4:	53                   	push   %ebx
  8015b5:	83 ec 0c             	sub    $0xc,%esp
  8015b8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015bb:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015be:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015c3:	39 f3                	cmp    %esi,%ebx
  8015c5:	73 25                	jae    8015ec <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015c7:	83 ec 04             	sub    $0x4,%esp
  8015ca:	89 f0                	mov    %esi,%eax
  8015cc:	29 d8                	sub    %ebx,%eax
  8015ce:	50                   	push   %eax
  8015cf:	89 d8                	mov    %ebx,%eax
  8015d1:	03 45 0c             	add    0xc(%ebp),%eax
  8015d4:	50                   	push   %eax
  8015d5:	57                   	push   %edi
  8015d6:	e8 4d ff ff ff       	call   801528 <read>
		if (m < 0)
  8015db:	83 c4 10             	add    $0x10,%esp
  8015de:	85 c0                	test   %eax,%eax
  8015e0:	78 08                	js     8015ea <readn+0x3b>
			return m;
		if (m == 0)
  8015e2:	85 c0                	test   %eax,%eax
  8015e4:	74 06                	je     8015ec <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  8015e6:	01 c3                	add    %eax,%ebx
  8015e8:	eb d9                	jmp    8015c3 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015ea:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8015ec:	89 d8                	mov    %ebx,%eax
  8015ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015f1:	5b                   	pop    %ebx
  8015f2:	5e                   	pop    %esi
  8015f3:	5f                   	pop    %edi
  8015f4:	5d                   	pop    %ebp
  8015f5:	c3                   	ret    

008015f6 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015f6:	55                   	push   %ebp
  8015f7:	89 e5                	mov    %esp,%ebp
  8015f9:	53                   	push   %ebx
  8015fa:	83 ec 14             	sub    $0x14,%esp
  8015fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801600:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801603:	50                   	push   %eax
  801604:	53                   	push   %ebx
  801605:	e8 ad fc ff ff       	call   8012b7 <fd_lookup>
  80160a:	83 c4 08             	add    $0x8,%esp
  80160d:	85 c0                	test   %eax,%eax
  80160f:	78 3a                	js     80164b <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801611:	83 ec 08             	sub    $0x8,%esp
  801614:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801617:	50                   	push   %eax
  801618:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80161b:	ff 30                	pushl  (%eax)
  80161d:	e8 eb fc ff ff       	call   80130d <dev_lookup>
  801622:	83 c4 10             	add    $0x10,%esp
  801625:	85 c0                	test   %eax,%eax
  801627:	78 22                	js     80164b <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801629:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80162c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801630:	74 1e                	je     801650 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801632:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801635:	8b 52 0c             	mov    0xc(%edx),%edx
  801638:	85 d2                	test   %edx,%edx
  80163a:	74 35                	je     801671 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80163c:	83 ec 04             	sub    $0x4,%esp
  80163f:	ff 75 10             	pushl  0x10(%ebp)
  801642:	ff 75 0c             	pushl  0xc(%ebp)
  801645:	50                   	push   %eax
  801646:	ff d2                	call   *%edx
  801648:	83 c4 10             	add    $0x10,%esp
}
  80164b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80164e:	c9                   	leave  
  80164f:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801650:	a1 04 40 80 00       	mov    0x804004,%eax
  801655:	8b 40 48             	mov    0x48(%eax),%eax
  801658:	83 ec 04             	sub    $0x4,%esp
  80165b:	53                   	push   %ebx
  80165c:	50                   	push   %eax
  80165d:	68 74 27 80 00       	push   $0x802774
  801662:	e8 cc eb ff ff       	call   800233 <cprintf>
		return -E_INVAL;
  801667:	83 c4 10             	add    $0x10,%esp
  80166a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80166f:	eb da                	jmp    80164b <write+0x55>
		return -E_NOT_SUPP;
  801671:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801676:	eb d3                	jmp    80164b <write+0x55>

00801678 <seek>:

int
seek(int fdnum, off_t offset)
{
  801678:	55                   	push   %ebp
  801679:	89 e5                	mov    %esp,%ebp
  80167b:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80167e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801681:	50                   	push   %eax
  801682:	ff 75 08             	pushl  0x8(%ebp)
  801685:	e8 2d fc ff ff       	call   8012b7 <fd_lookup>
  80168a:	83 c4 08             	add    $0x8,%esp
  80168d:	85 c0                	test   %eax,%eax
  80168f:	78 0e                	js     80169f <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801691:	8b 55 0c             	mov    0xc(%ebp),%edx
  801694:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801697:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80169a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80169f:	c9                   	leave  
  8016a0:	c3                   	ret    

008016a1 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016a1:	55                   	push   %ebp
  8016a2:	89 e5                	mov    %esp,%ebp
  8016a4:	53                   	push   %ebx
  8016a5:	83 ec 14             	sub    $0x14,%esp
  8016a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016ab:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016ae:	50                   	push   %eax
  8016af:	53                   	push   %ebx
  8016b0:	e8 02 fc ff ff       	call   8012b7 <fd_lookup>
  8016b5:	83 c4 08             	add    $0x8,%esp
  8016b8:	85 c0                	test   %eax,%eax
  8016ba:	78 37                	js     8016f3 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016bc:	83 ec 08             	sub    $0x8,%esp
  8016bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016c2:	50                   	push   %eax
  8016c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c6:	ff 30                	pushl  (%eax)
  8016c8:	e8 40 fc ff ff       	call   80130d <dev_lookup>
  8016cd:	83 c4 10             	add    $0x10,%esp
  8016d0:	85 c0                	test   %eax,%eax
  8016d2:	78 1f                	js     8016f3 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016d7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016db:	74 1b                	je     8016f8 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8016dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016e0:	8b 52 18             	mov    0x18(%edx),%edx
  8016e3:	85 d2                	test   %edx,%edx
  8016e5:	74 32                	je     801719 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016e7:	83 ec 08             	sub    $0x8,%esp
  8016ea:	ff 75 0c             	pushl  0xc(%ebp)
  8016ed:	50                   	push   %eax
  8016ee:	ff d2                	call   *%edx
  8016f0:	83 c4 10             	add    $0x10,%esp
}
  8016f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f6:	c9                   	leave  
  8016f7:	c3                   	ret    
			thisenv->env_id, fdnum);
  8016f8:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016fd:	8b 40 48             	mov    0x48(%eax),%eax
  801700:	83 ec 04             	sub    $0x4,%esp
  801703:	53                   	push   %ebx
  801704:	50                   	push   %eax
  801705:	68 34 27 80 00       	push   $0x802734
  80170a:	e8 24 eb ff ff       	call   800233 <cprintf>
		return -E_INVAL;
  80170f:	83 c4 10             	add    $0x10,%esp
  801712:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801717:	eb da                	jmp    8016f3 <ftruncate+0x52>
		return -E_NOT_SUPP;
  801719:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80171e:	eb d3                	jmp    8016f3 <ftruncate+0x52>

00801720 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801720:	55                   	push   %ebp
  801721:	89 e5                	mov    %esp,%ebp
  801723:	53                   	push   %ebx
  801724:	83 ec 14             	sub    $0x14,%esp
  801727:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80172a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80172d:	50                   	push   %eax
  80172e:	ff 75 08             	pushl  0x8(%ebp)
  801731:	e8 81 fb ff ff       	call   8012b7 <fd_lookup>
  801736:	83 c4 08             	add    $0x8,%esp
  801739:	85 c0                	test   %eax,%eax
  80173b:	78 4b                	js     801788 <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80173d:	83 ec 08             	sub    $0x8,%esp
  801740:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801743:	50                   	push   %eax
  801744:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801747:	ff 30                	pushl  (%eax)
  801749:	e8 bf fb ff ff       	call   80130d <dev_lookup>
  80174e:	83 c4 10             	add    $0x10,%esp
  801751:	85 c0                	test   %eax,%eax
  801753:	78 33                	js     801788 <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  801755:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801758:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80175c:	74 2f                	je     80178d <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80175e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801761:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801768:	00 00 00 
	stat->st_isdir = 0;
  80176b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801772:	00 00 00 
	stat->st_dev = dev;
  801775:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80177b:	83 ec 08             	sub    $0x8,%esp
  80177e:	53                   	push   %ebx
  80177f:	ff 75 f0             	pushl  -0x10(%ebp)
  801782:	ff 50 14             	call   *0x14(%eax)
  801785:	83 c4 10             	add    $0x10,%esp
}
  801788:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80178b:	c9                   	leave  
  80178c:	c3                   	ret    
		return -E_NOT_SUPP;
  80178d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801792:	eb f4                	jmp    801788 <fstat+0x68>

00801794 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801794:	55                   	push   %ebp
  801795:	89 e5                	mov    %esp,%ebp
  801797:	56                   	push   %esi
  801798:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801799:	83 ec 08             	sub    $0x8,%esp
  80179c:	6a 00                	push   $0x0
  80179e:	ff 75 08             	pushl  0x8(%ebp)
  8017a1:	e8 e7 01 00 00       	call   80198d <open>
  8017a6:	89 c3                	mov    %eax,%ebx
  8017a8:	83 c4 10             	add    $0x10,%esp
  8017ab:	85 c0                	test   %eax,%eax
  8017ad:	78 1b                	js     8017ca <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017af:	83 ec 08             	sub    $0x8,%esp
  8017b2:	ff 75 0c             	pushl  0xc(%ebp)
  8017b5:	50                   	push   %eax
  8017b6:	e8 65 ff ff ff       	call   801720 <fstat>
  8017bb:	89 c6                	mov    %eax,%esi
	close(fd);
  8017bd:	89 1c 24             	mov    %ebx,(%esp)
  8017c0:	e8 27 fc ff ff       	call   8013ec <close>
	return r;
  8017c5:	83 c4 10             	add    $0x10,%esp
  8017c8:	89 f3                	mov    %esi,%ebx
}
  8017ca:	89 d8                	mov    %ebx,%eax
  8017cc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017cf:	5b                   	pop    %ebx
  8017d0:	5e                   	pop    %esi
  8017d1:	5d                   	pop    %ebp
  8017d2:	c3                   	ret    

008017d3 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017d3:	55                   	push   %ebp
  8017d4:	89 e5                	mov    %esp,%ebp
  8017d6:	56                   	push   %esi
  8017d7:	53                   	push   %ebx
  8017d8:	89 c6                	mov    %eax,%esi
  8017da:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017dc:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017e3:	74 27                	je     80180c <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017e5:	6a 07                	push   $0x7
  8017e7:	68 00 50 80 00       	push   $0x805000
  8017ec:	56                   	push   %esi
  8017ed:	ff 35 00 40 80 00    	pushl  0x804000
  8017f3:	e8 ba f9 ff ff       	call   8011b2 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017f8:	83 c4 0c             	add    $0xc,%esp
  8017fb:	6a 00                	push   $0x0
  8017fd:	53                   	push   %ebx
  8017fe:	6a 00                	push   $0x0
  801800:	e8 38 f9 ff ff       	call   80113d <ipc_recv>
}
  801805:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801808:	5b                   	pop    %ebx
  801809:	5e                   	pop    %esi
  80180a:	5d                   	pop    %ebp
  80180b:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80180c:	83 ec 0c             	sub    $0xc,%esp
  80180f:	6a 01                	push   $0x1
  801811:	e8 f2 f9 ff ff       	call   801208 <ipc_find_env>
  801816:	a3 00 40 80 00       	mov    %eax,0x804000
  80181b:	83 c4 10             	add    $0x10,%esp
  80181e:	eb c5                	jmp    8017e5 <fsipc+0x12>

00801820 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801820:	55                   	push   %ebp
  801821:	89 e5                	mov    %esp,%ebp
  801823:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801826:	8b 45 08             	mov    0x8(%ebp),%eax
  801829:	8b 40 0c             	mov    0xc(%eax),%eax
  80182c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801831:	8b 45 0c             	mov    0xc(%ebp),%eax
  801834:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801839:	ba 00 00 00 00       	mov    $0x0,%edx
  80183e:	b8 02 00 00 00       	mov    $0x2,%eax
  801843:	e8 8b ff ff ff       	call   8017d3 <fsipc>
}
  801848:	c9                   	leave  
  801849:	c3                   	ret    

0080184a <devfile_flush>:
{
  80184a:	55                   	push   %ebp
  80184b:	89 e5                	mov    %esp,%ebp
  80184d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801850:	8b 45 08             	mov    0x8(%ebp),%eax
  801853:	8b 40 0c             	mov    0xc(%eax),%eax
  801856:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80185b:	ba 00 00 00 00       	mov    $0x0,%edx
  801860:	b8 06 00 00 00       	mov    $0x6,%eax
  801865:	e8 69 ff ff ff       	call   8017d3 <fsipc>
}
  80186a:	c9                   	leave  
  80186b:	c3                   	ret    

0080186c <devfile_stat>:
{
  80186c:	55                   	push   %ebp
  80186d:	89 e5                	mov    %esp,%ebp
  80186f:	53                   	push   %ebx
  801870:	83 ec 04             	sub    $0x4,%esp
  801873:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801876:	8b 45 08             	mov    0x8(%ebp),%eax
  801879:	8b 40 0c             	mov    0xc(%eax),%eax
  80187c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801881:	ba 00 00 00 00       	mov    $0x0,%edx
  801886:	b8 05 00 00 00       	mov    $0x5,%eax
  80188b:	e8 43 ff ff ff       	call   8017d3 <fsipc>
  801890:	85 c0                	test   %eax,%eax
  801892:	78 2c                	js     8018c0 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801894:	83 ec 08             	sub    $0x8,%esp
  801897:	68 00 50 80 00       	push   $0x805000
  80189c:	53                   	push   %ebx
  80189d:	e8 b0 ef ff ff       	call   800852 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018a2:	a1 80 50 80 00       	mov    0x805080,%eax
  8018a7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018ad:	a1 84 50 80 00       	mov    0x805084,%eax
  8018b2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018b8:	83 c4 10             	add    $0x10,%esp
  8018bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018c3:	c9                   	leave  
  8018c4:	c3                   	ret    

008018c5 <devfile_write>:
{
  8018c5:	55                   	push   %ebp
  8018c6:	89 e5                	mov    %esp,%ebp
  8018c8:	83 ec 0c             	sub    $0xc,%esp
  8018cb:	8b 45 10             	mov    0x10(%ebp),%eax
  8018ce:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8018d3:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8018d8:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018db:	8b 55 08             	mov    0x8(%ebp),%edx
  8018de:	8b 52 0c             	mov    0xc(%edx),%edx
  8018e1:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8018e7:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf,buf,n);
  8018ec:	50                   	push   %eax
  8018ed:	ff 75 0c             	pushl  0xc(%ebp)
  8018f0:	68 08 50 80 00       	push   $0x805008
  8018f5:	e8 e6 f0 ff ff       	call   8009e0 <memmove>
	if((r = fsipc(FSREQ_WRITE,NULL))<0)
  8018fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ff:	b8 04 00 00 00       	mov    $0x4,%eax
  801904:	e8 ca fe ff ff       	call   8017d3 <fsipc>
}
  801909:	c9                   	leave  
  80190a:	c3                   	ret    

0080190b <devfile_read>:
{
  80190b:	55                   	push   %ebp
  80190c:	89 e5                	mov    %esp,%ebp
  80190e:	56                   	push   %esi
  80190f:	53                   	push   %ebx
  801910:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801913:	8b 45 08             	mov    0x8(%ebp),%eax
  801916:	8b 40 0c             	mov    0xc(%eax),%eax
  801919:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80191e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801924:	ba 00 00 00 00       	mov    $0x0,%edx
  801929:	b8 03 00 00 00       	mov    $0x3,%eax
  80192e:	e8 a0 fe ff ff       	call   8017d3 <fsipc>
  801933:	89 c3                	mov    %eax,%ebx
  801935:	85 c0                	test   %eax,%eax
  801937:	78 1f                	js     801958 <devfile_read+0x4d>
	assert(r <= n);
  801939:	39 f0                	cmp    %esi,%eax
  80193b:	77 24                	ja     801961 <devfile_read+0x56>
	assert(r <= PGSIZE);
  80193d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801942:	7f 33                	jg     801977 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801944:	83 ec 04             	sub    $0x4,%esp
  801947:	50                   	push   %eax
  801948:	68 00 50 80 00       	push   $0x805000
  80194d:	ff 75 0c             	pushl  0xc(%ebp)
  801950:	e8 8b f0 ff ff       	call   8009e0 <memmove>
	return r;
  801955:	83 c4 10             	add    $0x10,%esp
}
  801958:	89 d8                	mov    %ebx,%eax
  80195a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80195d:	5b                   	pop    %ebx
  80195e:	5e                   	pop    %esi
  80195f:	5d                   	pop    %ebp
  801960:	c3                   	ret    
	assert(r <= n);
  801961:	68 a4 27 80 00       	push   $0x8027a4
  801966:	68 ab 27 80 00       	push   $0x8027ab
  80196b:	6a 7c                	push   $0x7c
  80196d:	68 c0 27 80 00       	push   $0x8027c0
  801972:	e8 e1 e7 ff ff       	call   800158 <_panic>
	assert(r <= PGSIZE);
  801977:	68 cb 27 80 00       	push   $0x8027cb
  80197c:	68 ab 27 80 00       	push   $0x8027ab
  801981:	6a 7d                	push   $0x7d
  801983:	68 c0 27 80 00       	push   $0x8027c0
  801988:	e8 cb e7 ff ff       	call   800158 <_panic>

0080198d <open>:
{
  80198d:	55                   	push   %ebp
  80198e:	89 e5                	mov    %esp,%ebp
  801990:	56                   	push   %esi
  801991:	53                   	push   %ebx
  801992:	83 ec 1c             	sub    $0x1c,%esp
  801995:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801998:	56                   	push   %esi
  801999:	e8 7d ee ff ff       	call   80081b <strlen>
  80199e:	83 c4 10             	add    $0x10,%esp
  8019a1:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019a6:	7f 6c                	jg     801a14 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8019a8:	83 ec 0c             	sub    $0xc,%esp
  8019ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019ae:	50                   	push   %eax
  8019af:	e8 b4 f8 ff ff       	call   801268 <fd_alloc>
  8019b4:	89 c3                	mov    %eax,%ebx
  8019b6:	83 c4 10             	add    $0x10,%esp
  8019b9:	85 c0                	test   %eax,%eax
  8019bb:	78 3c                	js     8019f9 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8019bd:	83 ec 08             	sub    $0x8,%esp
  8019c0:	56                   	push   %esi
  8019c1:	68 00 50 80 00       	push   $0x805000
  8019c6:	e8 87 ee ff ff       	call   800852 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ce:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019d3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8019db:	e8 f3 fd ff ff       	call   8017d3 <fsipc>
  8019e0:	89 c3                	mov    %eax,%ebx
  8019e2:	83 c4 10             	add    $0x10,%esp
  8019e5:	85 c0                	test   %eax,%eax
  8019e7:	78 19                	js     801a02 <open+0x75>
	return fd2num(fd);
  8019e9:	83 ec 0c             	sub    $0xc,%esp
  8019ec:	ff 75 f4             	pushl  -0xc(%ebp)
  8019ef:	e8 4d f8 ff ff       	call   801241 <fd2num>
  8019f4:	89 c3                	mov    %eax,%ebx
  8019f6:	83 c4 10             	add    $0x10,%esp
}
  8019f9:	89 d8                	mov    %ebx,%eax
  8019fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019fe:	5b                   	pop    %ebx
  8019ff:	5e                   	pop    %esi
  801a00:	5d                   	pop    %ebp
  801a01:	c3                   	ret    
		fd_close(fd, 0);
  801a02:	83 ec 08             	sub    $0x8,%esp
  801a05:	6a 00                	push   $0x0
  801a07:	ff 75 f4             	pushl  -0xc(%ebp)
  801a0a:	e8 54 f9 ff ff       	call   801363 <fd_close>
		return r;
  801a0f:	83 c4 10             	add    $0x10,%esp
  801a12:	eb e5                	jmp    8019f9 <open+0x6c>
		return -E_BAD_PATH;
  801a14:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801a19:	eb de                	jmp    8019f9 <open+0x6c>

00801a1b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a1b:	55                   	push   %ebp
  801a1c:	89 e5                	mov    %esp,%ebp
  801a1e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a21:	ba 00 00 00 00       	mov    $0x0,%edx
  801a26:	b8 08 00 00 00       	mov    $0x8,%eax
  801a2b:	e8 a3 fd ff ff       	call   8017d3 <fsipc>
}
  801a30:	c9                   	leave  
  801a31:	c3                   	ret    

00801a32 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a32:	55                   	push   %ebp
  801a33:	89 e5                	mov    %esp,%ebp
  801a35:	56                   	push   %esi
  801a36:	53                   	push   %ebx
  801a37:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a3a:	83 ec 0c             	sub    $0xc,%esp
  801a3d:	ff 75 08             	pushl  0x8(%ebp)
  801a40:	e8 0c f8 ff ff       	call   801251 <fd2data>
  801a45:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a47:	83 c4 08             	add    $0x8,%esp
  801a4a:	68 d7 27 80 00       	push   $0x8027d7
  801a4f:	53                   	push   %ebx
  801a50:	e8 fd ed ff ff       	call   800852 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a55:	8b 46 04             	mov    0x4(%esi),%eax
  801a58:	2b 06                	sub    (%esi),%eax
  801a5a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a60:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a67:	00 00 00 
	stat->st_dev = &devpipe;
  801a6a:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a71:	30 80 00 
	return 0;
}
  801a74:	b8 00 00 00 00       	mov    $0x0,%eax
  801a79:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a7c:	5b                   	pop    %ebx
  801a7d:	5e                   	pop    %esi
  801a7e:	5d                   	pop    %ebp
  801a7f:	c3                   	ret    

00801a80 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a80:	55                   	push   %ebp
  801a81:	89 e5                	mov    %esp,%ebp
  801a83:	53                   	push   %ebx
  801a84:	83 ec 0c             	sub    $0xc,%esp
  801a87:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a8a:	53                   	push   %ebx
  801a8b:	6a 00                	push   $0x0
  801a8d:	e8 3e f2 ff ff       	call   800cd0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a92:	89 1c 24             	mov    %ebx,(%esp)
  801a95:	e8 b7 f7 ff ff       	call   801251 <fd2data>
  801a9a:	83 c4 08             	add    $0x8,%esp
  801a9d:	50                   	push   %eax
  801a9e:	6a 00                	push   $0x0
  801aa0:	e8 2b f2 ff ff       	call   800cd0 <sys_page_unmap>
}
  801aa5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aa8:	c9                   	leave  
  801aa9:	c3                   	ret    

00801aaa <_pipeisclosed>:
{
  801aaa:	55                   	push   %ebp
  801aab:	89 e5                	mov    %esp,%ebp
  801aad:	57                   	push   %edi
  801aae:	56                   	push   %esi
  801aaf:	53                   	push   %ebx
  801ab0:	83 ec 1c             	sub    $0x1c,%esp
  801ab3:	89 c7                	mov    %eax,%edi
  801ab5:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801ab7:	a1 04 40 80 00       	mov    0x804004,%eax
  801abc:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801abf:	83 ec 0c             	sub    $0xc,%esp
  801ac2:	57                   	push   %edi
  801ac3:	e8 c0 04 00 00       	call   801f88 <pageref>
  801ac8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801acb:	89 34 24             	mov    %esi,(%esp)
  801ace:	e8 b5 04 00 00       	call   801f88 <pageref>
		nn = thisenv->env_runs;
  801ad3:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801ad9:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801adc:	83 c4 10             	add    $0x10,%esp
  801adf:	39 cb                	cmp    %ecx,%ebx
  801ae1:	74 1b                	je     801afe <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801ae3:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801ae6:	75 cf                	jne    801ab7 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ae8:	8b 42 58             	mov    0x58(%edx),%eax
  801aeb:	6a 01                	push   $0x1
  801aed:	50                   	push   %eax
  801aee:	53                   	push   %ebx
  801aef:	68 de 27 80 00       	push   $0x8027de
  801af4:	e8 3a e7 ff ff       	call   800233 <cprintf>
  801af9:	83 c4 10             	add    $0x10,%esp
  801afc:	eb b9                	jmp    801ab7 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801afe:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b01:	0f 94 c0             	sete   %al
  801b04:	0f b6 c0             	movzbl %al,%eax
}
  801b07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b0a:	5b                   	pop    %ebx
  801b0b:	5e                   	pop    %esi
  801b0c:	5f                   	pop    %edi
  801b0d:	5d                   	pop    %ebp
  801b0e:	c3                   	ret    

00801b0f <devpipe_write>:
{
  801b0f:	55                   	push   %ebp
  801b10:	89 e5                	mov    %esp,%ebp
  801b12:	57                   	push   %edi
  801b13:	56                   	push   %esi
  801b14:	53                   	push   %ebx
  801b15:	83 ec 28             	sub    $0x28,%esp
  801b18:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801b1b:	56                   	push   %esi
  801b1c:	e8 30 f7 ff ff       	call   801251 <fd2data>
  801b21:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b23:	83 c4 10             	add    $0x10,%esp
  801b26:	bf 00 00 00 00       	mov    $0x0,%edi
  801b2b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b2e:	74 4f                	je     801b7f <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b30:	8b 43 04             	mov    0x4(%ebx),%eax
  801b33:	8b 0b                	mov    (%ebx),%ecx
  801b35:	8d 51 20             	lea    0x20(%ecx),%edx
  801b38:	39 d0                	cmp    %edx,%eax
  801b3a:	72 14                	jb     801b50 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801b3c:	89 da                	mov    %ebx,%edx
  801b3e:	89 f0                	mov    %esi,%eax
  801b40:	e8 65 ff ff ff       	call   801aaa <_pipeisclosed>
  801b45:	85 c0                	test   %eax,%eax
  801b47:	75 3a                	jne    801b83 <devpipe_write+0x74>
			sys_yield();
  801b49:	e8 de f0 ff ff       	call   800c2c <sys_yield>
  801b4e:	eb e0                	jmp    801b30 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b53:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b57:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b5a:	89 c2                	mov    %eax,%edx
  801b5c:	c1 fa 1f             	sar    $0x1f,%edx
  801b5f:	89 d1                	mov    %edx,%ecx
  801b61:	c1 e9 1b             	shr    $0x1b,%ecx
  801b64:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b67:	83 e2 1f             	and    $0x1f,%edx
  801b6a:	29 ca                	sub    %ecx,%edx
  801b6c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b70:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b74:	83 c0 01             	add    $0x1,%eax
  801b77:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801b7a:	83 c7 01             	add    $0x1,%edi
  801b7d:	eb ac                	jmp    801b2b <devpipe_write+0x1c>
	return i;
  801b7f:	89 f8                	mov    %edi,%eax
  801b81:	eb 05                	jmp    801b88 <devpipe_write+0x79>
				return 0;
  801b83:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b8b:	5b                   	pop    %ebx
  801b8c:	5e                   	pop    %esi
  801b8d:	5f                   	pop    %edi
  801b8e:	5d                   	pop    %ebp
  801b8f:	c3                   	ret    

00801b90 <devpipe_read>:
{
  801b90:	55                   	push   %ebp
  801b91:	89 e5                	mov    %esp,%ebp
  801b93:	57                   	push   %edi
  801b94:	56                   	push   %esi
  801b95:	53                   	push   %ebx
  801b96:	83 ec 18             	sub    $0x18,%esp
  801b99:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801b9c:	57                   	push   %edi
  801b9d:	e8 af f6 ff ff       	call   801251 <fd2data>
  801ba2:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801ba4:	83 c4 10             	add    $0x10,%esp
  801ba7:	be 00 00 00 00       	mov    $0x0,%esi
  801bac:	3b 75 10             	cmp    0x10(%ebp),%esi
  801baf:	74 47                	je     801bf8 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  801bb1:	8b 03                	mov    (%ebx),%eax
  801bb3:	3b 43 04             	cmp    0x4(%ebx),%eax
  801bb6:	75 22                	jne    801bda <devpipe_read+0x4a>
			if (i > 0)
  801bb8:	85 f6                	test   %esi,%esi
  801bba:	75 14                	jne    801bd0 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801bbc:	89 da                	mov    %ebx,%edx
  801bbe:	89 f8                	mov    %edi,%eax
  801bc0:	e8 e5 fe ff ff       	call   801aaa <_pipeisclosed>
  801bc5:	85 c0                	test   %eax,%eax
  801bc7:	75 33                	jne    801bfc <devpipe_read+0x6c>
			sys_yield();
  801bc9:	e8 5e f0 ff ff       	call   800c2c <sys_yield>
  801bce:	eb e1                	jmp    801bb1 <devpipe_read+0x21>
				return i;
  801bd0:	89 f0                	mov    %esi,%eax
}
  801bd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bd5:	5b                   	pop    %ebx
  801bd6:	5e                   	pop    %esi
  801bd7:	5f                   	pop    %edi
  801bd8:	5d                   	pop    %ebp
  801bd9:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bda:	99                   	cltd   
  801bdb:	c1 ea 1b             	shr    $0x1b,%edx
  801bde:	01 d0                	add    %edx,%eax
  801be0:	83 e0 1f             	and    $0x1f,%eax
  801be3:	29 d0                	sub    %edx,%eax
  801be5:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801bea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bed:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801bf0:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801bf3:	83 c6 01             	add    $0x1,%esi
  801bf6:	eb b4                	jmp    801bac <devpipe_read+0x1c>
	return i;
  801bf8:	89 f0                	mov    %esi,%eax
  801bfa:	eb d6                	jmp    801bd2 <devpipe_read+0x42>
				return 0;
  801bfc:	b8 00 00 00 00       	mov    $0x0,%eax
  801c01:	eb cf                	jmp    801bd2 <devpipe_read+0x42>

00801c03 <pipe>:
{
  801c03:	55                   	push   %ebp
  801c04:	89 e5                	mov    %esp,%ebp
  801c06:	56                   	push   %esi
  801c07:	53                   	push   %ebx
  801c08:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801c0b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c0e:	50                   	push   %eax
  801c0f:	e8 54 f6 ff ff       	call   801268 <fd_alloc>
  801c14:	89 c3                	mov    %eax,%ebx
  801c16:	83 c4 10             	add    $0x10,%esp
  801c19:	85 c0                	test   %eax,%eax
  801c1b:	78 5b                	js     801c78 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c1d:	83 ec 04             	sub    $0x4,%esp
  801c20:	68 07 04 00 00       	push   $0x407
  801c25:	ff 75 f4             	pushl  -0xc(%ebp)
  801c28:	6a 00                	push   $0x0
  801c2a:	e8 1c f0 ff ff       	call   800c4b <sys_page_alloc>
  801c2f:	89 c3                	mov    %eax,%ebx
  801c31:	83 c4 10             	add    $0x10,%esp
  801c34:	85 c0                	test   %eax,%eax
  801c36:	78 40                	js     801c78 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  801c38:	83 ec 0c             	sub    $0xc,%esp
  801c3b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c3e:	50                   	push   %eax
  801c3f:	e8 24 f6 ff ff       	call   801268 <fd_alloc>
  801c44:	89 c3                	mov    %eax,%ebx
  801c46:	83 c4 10             	add    $0x10,%esp
  801c49:	85 c0                	test   %eax,%eax
  801c4b:	78 1b                	js     801c68 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c4d:	83 ec 04             	sub    $0x4,%esp
  801c50:	68 07 04 00 00       	push   $0x407
  801c55:	ff 75 f0             	pushl  -0x10(%ebp)
  801c58:	6a 00                	push   $0x0
  801c5a:	e8 ec ef ff ff       	call   800c4b <sys_page_alloc>
  801c5f:	89 c3                	mov    %eax,%ebx
  801c61:	83 c4 10             	add    $0x10,%esp
  801c64:	85 c0                	test   %eax,%eax
  801c66:	79 19                	jns    801c81 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  801c68:	83 ec 08             	sub    $0x8,%esp
  801c6b:	ff 75 f4             	pushl  -0xc(%ebp)
  801c6e:	6a 00                	push   $0x0
  801c70:	e8 5b f0 ff ff       	call   800cd0 <sys_page_unmap>
  801c75:	83 c4 10             	add    $0x10,%esp
}
  801c78:	89 d8                	mov    %ebx,%eax
  801c7a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c7d:	5b                   	pop    %ebx
  801c7e:	5e                   	pop    %esi
  801c7f:	5d                   	pop    %ebp
  801c80:	c3                   	ret    
	va = fd2data(fd0);
  801c81:	83 ec 0c             	sub    $0xc,%esp
  801c84:	ff 75 f4             	pushl  -0xc(%ebp)
  801c87:	e8 c5 f5 ff ff       	call   801251 <fd2data>
  801c8c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c8e:	83 c4 0c             	add    $0xc,%esp
  801c91:	68 07 04 00 00       	push   $0x407
  801c96:	50                   	push   %eax
  801c97:	6a 00                	push   $0x0
  801c99:	e8 ad ef ff ff       	call   800c4b <sys_page_alloc>
  801c9e:	89 c3                	mov    %eax,%ebx
  801ca0:	83 c4 10             	add    $0x10,%esp
  801ca3:	85 c0                	test   %eax,%eax
  801ca5:	0f 88 8c 00 00 00    	js     801d37 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cab:	83 ec 0c             	sub    $0xc,%esp
  801cae:	ff 75 f0             	pushl  -0x10(%ebp)
  801cb1:	e8 9b f5 ff ff       	call   801251 <fd2data>
  801cb6:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cbd:	50                   	push   %eax
  801cbe:	6a 00                	push   $0x0
  801cc0:	56                   	push   %esi
  801cc1:	6a 00                	push   $0x0
  801cc3:	e8 c6 ef ff ff       	call   800c8e <sys_page_map>
  801cc8:	89 c3                	mov    %eax,%ebx
  801cca:	83 c4 20             	add    $0x20,%esp
  801ccd:	85 c0                	test   %eax,%eax
  801ccf:	78 58                	js     801d29 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801cd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cda:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801cdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cdf:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801ce6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ce9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cef:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cf1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cf4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801cfb:	83 ec 0c             	sub    $0xc,%esp
  801cfe:	ff 75 f4             	pushl  -0xc(%ebp)
  801d01:	e8 3b f5 ff ff       	call   801241 <fd2num>
  801d06:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d09:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d0b:	83 c4 04             	add    $0x4,%esp
  801d0e:	ff 75 f0             	pushl  -0x10(%ebp)
  801d11:	e8 2b f5 ff ff       	call   801241 <fd2num>
  801d16:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d19:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d1c:	83 c4 10             	add    $0x10,%esp
  801d1f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d24:	e9 4f ff ff ff       	jmp    801c78 <pipe+0x75>
	sys_page_unmap(0, va);
  801d29:	83 ec 08             	sub    $0x8,%esp
  801d2c:	56                   	push   %esi
  801d2d:	6a 00                	push   $0x0
  801d2f:	e8 9c ef ff ff       	call   800cd0 <sys_page_unmap>
  801d34:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801d37:	83 ec 08             	sub    $0x8,%esp
  801d3a:	ff 75 f0             	pushl  -0x10(%ebp)
  801d3d:	6a 00                	push   $0x0
  801d3f:	e8 8c ef ff ff       	call   800cd0 <sys_page_unmap>
  801d44:	83 c4 10             	add    $0x10,%esp
  801d47:	e9 1c ff ff ff       	jmp    801c68 <pipe+0x65>

00801d4c <pipeisclosed>:
{
  801d4c:	55                   	push   %ebp
  801d4d:	89 e5                	mov    %esp,%ebp
  801d4f:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d52:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d55:	50                   	push   %eax
  801d56:	ff 75 08             	pushl  0x8(%ebp)
  801d59:	e8 59 f5 ff ff       	call   8012b7 <fd_lookup>
  801d5e:	83 c4 10             	add    $0x10,%esp
  801d61:	85 c0                	test   %eax,%eax
  801d63:	78 18                	js     801d7d <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801d65:	83 ec 0c             	sub    $0xc,%esp
  801d68:	ff 75 f4             	pushl  -0xc(%ebp)
  801d6b:	e8 e1 f4 ff ff       	call   801251 <fd2data>
	return _pipeisclosed(fd, p);
  801d70:	89 c2                	mov    %eax,%edx
  801d72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d75:	e8 30 fd ff ff       	call   801aaa <_pipeisclosed>
  801d7a:	83 c4 10             	add    $0x10,%esp
}
  801d7d:	c9                   	leave  
  801d7e:	c3                   	ret    

00801d7f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d7f:	55                   	push   %ebp
  801d80:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d82:	b8 00 00 00 00       	mov    $0x0,%eax
  801d87:	5d                   	pop    %ebp
  801d88:	c3                   	ret    

00801d89 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d89:	55                   	push   %ebp
  801d8a:	89 e5                	mov    %esp,%ebp
  801d8c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d8f:	68 f6 27 80 00       	push   $0x8027f6
  801d94:	ff 75 0c             	pushl  0xc(%ebp)
  801d97:	e8 b6 ea ff ff       	call   800852 <strcpy>
	return 0;
}
  801d9c:	b8 00 00 00 00       	mov    $0x0,%eax
  801da1:	c9                   	leave  
  801da2:	c3                   	ret    

00801da3 <devcons_write>:
{
  801da3:	55                   	push   %ebp
  801da4:	89 e5                	mov    %esp,%ebp
  801da6:	57                   	push   %edi
  801da7:	56                   	push   %esi
  801da8:	53                   	push   %ebx
  801da9:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801daf:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801db4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801dba:	eb 2f                	jmp    801deb <devcons_write+0x48>
		m = n - tot;
  801dbc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801dbf:	29 f3                	sub    %esi,%ebx
  801dc1:	83 fb 7f             	cmp    $0x7f,%ebx
  801dc4:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801dc9:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801dcc:	83 ec 04             	sub    $0x4,%esp
  801dcf:	53                   	push   %ebx
  801dd0:	89 f0                	mov    %esi,%eax
  801dd2:	03 45 0c             	add    0xc(%ebp),%eax
  801dd5:	50                   	push   %eax
  801dd6:	57                   	push   %edi
  801dd7:	e8 04 ec ff ff       	call   8009e0 <memmove>
		sys_cputs(buf, m);
  801ddc:	83 c4 08             	add    $0x8,%esp
  801ddf:	53                   	push   %ebx
  801de0:	57                   	push   %edi
  801de1:	e8 a9 ed ff ff       	call   800b8f <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801de6:	01 de                	add    %ebx,%esi
  801de8:	83 c4 10             	add    $0x10,%esp
  801deb:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dee:	72 cc                	jb     801dbc <devcons_write+0x19>
}
  801df0:	89 f0                	mov    %esi,%eax
  801df2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801df5:	5b                   	pop    %ebx
  801df6:	5e                   	pop    %esi
  801df7:	5f                   	pop    %edi
  801df8:	5d                   	pop    %ebp
  801df9:	c3                   	ret    

00801dfa <devcons_read>:
{
  801dfa:	55                   	push   %ebp
  801dfb:	89 e5                	mov    %esp,%ebp
  801dfd:	83 ec 08             	sub    $0x8,%esp
  801e00:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801e05:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e09:	75 07                	jne    801e12 <devcons_read+0x18>
}
  801e0b:	c9                   	leave  
  801e0c:	c3                   	ret    
		sys_yield();
  801e0d:	e8 1a ee ff ff       	call   800c2c <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801e12:	e8 96 ed ff ff       	call   800bad <sys_cgetc>
  801e17:	85 c0                	test   %eax,%eax
  801e19:	74 f2                	je     801e0d <devcons_read+0x13>
	if (c < 0)
  801e1b:	85 c0                	test   %eax,%eax
  801e1d:	78 ec                	js     801e0b <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  801e1f:	83 f8 04             	cmp    $0x4,%eax
  801e22:	74 0c                	je     801e30 <devcons_read+0x36>
	*(char*)vbuf = c;
  801e24:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e27:	88 02                	mov    %al,(%edx)
	return 1;
  801e29:	b8 01 00 00 00       	mov    $0x1,%eax
  801e2e:	eb db                	jmp    801e0b <devcons_read+0x11>
		return 0;
  801e30:	b8 00 00 00 00       	mov    $0x0,%eax
  801e35:	eb d4                	jmp    801e0b <devcons_read+0x11>

00801e37 <cputchar>:
{
  801e37:	55                   	push   %ebp
  801e38:	89 e5                	mov    %esp,%ebp
  801e3a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e3d:	8b 45 08             	mov    0x8(%ebp),%eax
  801e40:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801e43:	6a 01                	push   $0x1
  801e45:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e48:	50                   	push   %eax
  801e49:	e8 41 ed ff ff       	call   800b8f <sys_cputs>
}
  801e4e:	83 c4 10             	add    $0x10,%esp
  801e51:	c9                   	leave  
  801e52:	c3                   	ret    

00801e53 <getchar>:
{
  801e53:	55                   	push   %ebp
  801e54:	89 e5                	mov    %esp,%ebp
  801e56:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801e59:	6a 01                	push   $0x1
  801e5b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e5e:	50                   	push   %eax
  801e5f:	6a 00                	push   $0x0
  801e61:	e8 c2 f6 ff ff       	call   801528 <read>
	if (r < 0)
  801e66:	83 c4 10             	add    $0x10,%esp
  801e69:	85 c0                	test   %eax,%eax
  801e6b:	78 08                	js     801e75 <getchar+0x22>
	if (r < 1)
  801e6d:	85 c0                	test   %eax,%eax
  801e6f:	7e 06                	jle    801e77 <getchar+0x24>
	return c;
  801e71:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801e75:	c9                   	leave  
  801e76:	c3                   	ret    
		return -E_EOF;
  801e77:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801e7c:	eb f7                	jmp    801e75 <getchar+0x22>

00801e7e <iscons>:
{
  801e7e:	55                   	push   %ebp
  801e7f:	89 e5                	mov    %esp,%ebp
  801e81:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e84:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e87:	50                   	push   %eax
  801e88:	ff 75 08             	pushl  0x8(%ebp)
  801e8b:	e8 27 f4 ff ff       	call   8012b7 <fd_lookup>
  801e90:	83 c4 10             	add    $0x10,%esp
  801e93:	85 c0                	test   %eax,%eax
  801e95:	78 11                	js     801ea8 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801e97:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e9a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ea0:	39 10                	cmp    %edx,(%eax)
  801ea2:	0f 94 c0             	sete   %al
  801ea5:	0f b6 c0             	movzbl %al,%eax
}
  801ea8:	c9                   	leave  
  801ea9:	c3                   	ret    

00801eaa <opencons>:
{
  801eaa:	55                   	push   %ebp
  801eab:	89 e5                	mov    %esp,%ebp
  801ead:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801eb0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eb3:	50                   	push   %eax
  801eb4:	e8 af f3 ff ff       	call   801268 <fd_alloc>
  801eb9:	83 c4 10             	add    $0x10,%esp
  801ebc:	85 c0                	test   %eax,%eax
  801ebe:	78 3a                	js     801efa <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ec0:	83 ec 04             	sub    $0x4,%esp
  801ec3:	68 07 04 00 00       	push   $0x407
  801ec8:	ff 75 f4             	pushl  -0xc(%ebp)
  801ecb:	6a 00                	push   $0x0
  801ecd:	e8 79 ed ff ff       	call   800c4b <sys_page_alloc>
  801ed2:	83 c4 10             	add    $0x10,%esp
  801ed5:	85 c0                	test   %eax,%eax
  801ed7:	78 21                	js     801efa <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801ed9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801edc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ee2:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ee4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ee7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801eee:	83 ec 0c             	sub    $0xc,%esp
  801ef1:	50                   	push   %eax
  801ef2:	e8 4a f3 ff ff       	call   801241 <fd2num>
  801ef7:	83 c4 10             	add    $0x10,%esp
}
  801efa:	c9                   	leave  
  801efb:	c3                   	ret    

00801efc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801efc:	55                   	push   %ebp
  801efd:	89 e5                	mov    %esp,%ebp
  801eff:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f02:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f09:	74 0a                	je     801f15 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler %e",r);
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
	}
       
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f0b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f0e:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f13:	c9                   	leave  
  801f14:	c3                   	ret    
		if((r=sys_page_alloc(thisenv->env_id,(void *)UXSTACKTOP-PGSIZE,PTE_P|PTE_W|PTE_U))<0)
  801f15:	a1 04 40 80 00       	mov    0x804004,%eax
  801f1a:	8b 40 48             	mov    0x48(%eax),%eax
  801f1d:	83 ec 04             	sub    $0x4,%esp
  801f20:	6a 07                	push   $0x7
  801f22:	68 00 f0 bf ee       	push   $0xeebff000
  801f27:	50                   	push   %eax
  801f28:	e8 1e ed ff ff       	call   800c4b <sys_page_alloc>
  801f2d:	83 c4 10             	add    $0x10,%esp
  801f30:	85 c0                	test   %eax,%eax
  801f32:	78 1b                	js     801f4f <set_pgfault_handler+0x53>
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
  801f34:	a1 04 40 80 00       	mov    0x804004,%eax
  801f39:	8b 40 48             	mov    0x48(%eax),%eax
  801f3c:	83 ec 08             	sub    $0x8,%esp
  801f3f:	68 61 1f 80 00       	push   $0x801f61
  801f44:	50                   	push   %eax
  801f45:	e8 4c ee ff ff       	call   800d96 <sys_env_set_pgfault_upcall>
  801f4a:	83 c4 10             	add    $0x10,%esp
  801f4d:	eb bc                	jmp    801f0b <set_pgfault_handler+0xf>
			panic("set_pgfault_handler %e",r);
  801f4f:	50                   	push   %eax
  801f50:	68 02 28 80 00       	push   $0x802802
  801f55:	6a 22                	push   $0x22
  801f57:	68 19 28 80 00       	push   $0x802819
  801f5c:	e8 f7 e1 ff ff       	call   800158 <_panic>

00801f61 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f61:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f62:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f67:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f69:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 48(%esp), %ebp
  801f6c:	8b 6c 24 30          	mov    0x30(%esp),%ebp
        subl $4, %ebp
  801f70:	83 ed 04             	sub    $0x4,%ebp
        movl %ebp, 48(%esp)
  801f73:	89 6c 24 30          	mov    %ebp,0x30(%esp)
        movl 40(%esp), %eax
  801f77:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl %eax, (%ebp)
  801f7b:	89 45 00             	mov    %eax,0x0(%ebp)
	// Restore the trap-time registers.  After you do this, you
 	// can no longer modify any general-purpose registers.
 	// LAB 4: Your code here.
        addl $8, %esp
  801f7e:	83 c4 08             	add    $0x8,%esp
        popal
  801f81:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $4, %esp
  801f82:	83 c4 04             	add    $0x4,%esp
        popfl
  801f85:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  801f86:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  801f87:	c3                   	ret    

00801f88 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f88:	55                   	push   %ebp
  801f89:	89 e5                	mov    %esp,%ebp
  801f8b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f8e:	89 d0                	mov    %edx,%eax
  801f90:	c1 e8 16             	shr    $0x16,%eax
  801f93:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f9a:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801f9f:	f6 c1 01             	test   $0x1,%cl
  801fa2:	74 1d                	je     801fc1 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801fa4:	c1 ea 0c             	shr    $0xc,%edx
  801fa7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fae:	f6 c2 01             	test   $0x1,%dl
  801fb1:	74 0e                	je     801fc1 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fb3:	c1 ea 0c             	shr    $0xc,%edx
  801fb6:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fbd:	ef 
  801fbe:	0f b7 c0             	movzwl %ax,%eax
}
  801fc1:	5d                   	pop    %ebp
  801fc2:	c3                   	ret    
  801fc3:	66 90                	xchg   %ax,%ax
  801fc5:	66 90                	xchg   %ax,%ax
  801fc7:	66 90                	xchg   %ax,%ax
  801fc9:	66 90                	xchg   %ax,%ax
  801fcb:	66 90                	xchg   %ax,%ax
  801fcd:	66 90                	xchg   %ax,%ax
  801fcf:	90                   	nop

00801fd0 <__udivdi3>:
  801fd0:	55                   	push   %ebp
  801fd1:	57                   	push   %edi
  801fd2:	56                   	push   %esi
  801fd3:	53                   	push   %ebx
  801fd4:	83 ec 1c             	sub    $0x1c,%esp
  801fd7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801fdb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801fdf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801fe3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801fe7:	85 d2                	test   %edx,%edx
  801fe9:	75 35                	jne    802020 <__udivdi3+0x50>
  801feb:	39 f3                	cmp    %esi,%ebx
  801fed:	0f 87 bd 00 00 00    	ja     8020b0 <__udivdi3+0xe0>
  801ff3:	85 db                	test   %ebx,%ebx
  801ff5:	89 d9                	mov    %ebx,%ecx
  801ff7:	75 0b                	jne    802004 <__udivdi3+0x34>
  801ff9:	b8 01 00 00 00       	mov    $0x1,%eax
  801ffe:	31 d2                	xor    %edx,%edx
  802000:	f7 f3                	div    %ebx
  802002:	89 c1                	mov    %eax,%ecx
  802004:	31 d2                	xor    %edx,%edx
  802006:	89 f0                	mov    %esi,%eax
  802008:	f7 f1                	div    %ecx
  80200a:	89 c6                	mov    %eax,%esi
  80200c:	89 e8                	mov    %ebp,%eax
  80200e:	89 f7                	mov    %esi,%edi
  802010:	f7 f1                	div    %ecx
  802012:	89 fa                	mov    %edi,%edx
  802014:	83 c4 1c             	add    $0x1c,%esp
  802017:	5b                   	pop    %ebx
  802018:	5e                   	pop    %esi
  802019:	5f                   	pop    %edi
  80201a:	5d                   	pop    %ebp
  80201b:	c3                   	ret    
  80201c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802020:	39 f2                	cmp    %esi,%edx
  802022:	77 7c                	ja     8020a0 <__udivdi3+0xd0>
  802024:	0f bd fa             	bsr    %edx,%edi
  802027:	83 f7 1f             	xor    $0x1f,%edi
  80202a:	0f 84 98 00 00 00    	je     8020c8 <__udivdi3+0xf8>
  802030:	89 f9                	mov    %edi,%ecx
  802032:	b8 20 00 00 00       	mov    $0x20,%eax
  802037:	29 f8                	sub    %edi,%eax
  802039:	d3 e2                	shl    %cl,%edx
  80203b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80203f:	89 c1                	mov    %eax,%ecx
  802041:	89 da                	mov    %ebx,%edx
  802043:	d3 ea                	shr    %cl,%edx
  802045:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802049:	09 d1                	or     %edx,%ecx
  80204b:	89 f2                	mov    %esi,%edx
  80204d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802051:	89 f9                	mov    %edi,%ecx
  802053:	d3 e3                	shl    %cl,%ebx
  802055:	89 c1                	mov    %eax,%ecx
  802057:	d3 ea                	shr    %cl,%edx
  802059:	89 f9                	mov    %edi,%ecx
  80205b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80205f:	d3 e6                	shl    %cl,%esi
  802061:	89 eb                	mov    %ebp,%ebx
  802063:	89 c1                	mov    %eax,%ecx
  802065:	d3 eb                	shr    %cl,%ebx
  802067:	09 de                	or     %ebx,%esi
  802069:	89 f0                	mov    %esi,%eax
  80206b:	f7 74 24 08          	divl   0x8(%esp)
  80206f:	89 d6                	mov    %edx,%esi
  802071:	89 c3                	mov    %eax,%ebx
  802073:	f7 64 24 0c          	mull   0xc(%esp)
  802077:	39 d6                	cmp    %edx,%esi
  802079:	72 0c                	jb     802087 <__udivdi3+0xb7>
  80207b:	89 f9                	mov    %edi,%ecx
  80207d:	d3 e5                	shl    %cl,%ebp
  80207f:	39 c5                	cmp    %eax,%ebp
  802081:	73 5d                	jae    8020e0 <__udivdi3+0x110>
  802083:	39 d6                	cmp    %edx,%esi
  802085:	75 59                	jne    8020e0 <__udivdi3+0x110>
  802087:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80208a:	31 ff                	xor    %edi,%edi
  80208c:	89 fa                	mov    %edi,%edx
  80208e:	83 c4 1c             	add    $0x1c,%esp
  802091:	5b                   	pop    %ebx
  802092:	5e                   	pop    %esi
  802093:	5f                   	pop    %edi
  802094:	5d                   	pop    %ebp
  802095:	c3                   	ret    
  802096:	8d 76 00             	lea    0x0(%esi),%esi
  802099:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8020a0:	31 ff                	xor    %edi,%edi
  8020a2:	31 c0                	xor    %eax,%eax
  8020a4:	89 fa                	mov    %edi,%edx
  8020a6:	83 c4 1c             	add    $0x1c,%esp
  8020a9:	5b                   	pop    %ebx
  8020aa:	5e                   	pop    %esi
  8020ab:	5f                   	pop    %edi
  8020ac:	5d                   	pop    %ebp
  8020ad:	c3                   	ret    
  8020ae:	66 90                	xchg   %ax,%ax
  8020b0:	31 ff                	xor    %edi,%edi
  8020b2:	89 e8                	mov    %ebp,%eax
  8020b4:	89 f2                	mov    %esi,%edx
  8020b6:	f7 f3                	div    %ebx
  8020b8:	89 fa                	mov    %edi,%edx
  8020ba:	83 c4 1c             	add    $0x1c,%esp
  8020bd:	5b                   	pop    %ebx
  8020be:	5e                   	pop    %esi
  8020bf:	5f                   	pop    %edi
  8020c0:	5d                   	pop    %ebp
  8020c1:	c3                   	ret    
  8020c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020c8:	39 f2                	cmp    %esi,%edx
  8020ca:	72 06                	jb     8020d2 <__udivdi3+0x102>
  8020cc:	31 c0                	xor    %eax,%eax
  8020ce:	39 eb                	cmp    %ebp,%ebx
  8020d0:	77 d2                	ja     8020a4 <__udivdi3+0xd4>
  8020d2:	b8 01 00 00 00       	mov    $0x1,%eax
  8020d7:	eb cb                	jmp    8020a4 <__udivdi3+0xd4>
  8020d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020e0:	89 d8                	mov    %ebx,%eax
  8020e2:	31 ff                	xor    %edi,%edi
  8020e4:	eb be                	jmp    8020a4 <__udivdi3+0xd4>
  8020e6:	66 90                	xchg   %ax,%ax
  8020e8:	66 90                	xchg   %ax,%ax
  8020ea:	66 90                	xchg   %ax,%ax
  8020ec:	66 90                	xchg   %ax,%ax
  8020ee:	66 90                	xchg   %ax,%ax

008020f0 <__umoddi3>:
  8020f0:	55                   	push   %ebp
  8020f1:	57                   	push   %edi
  8020f2:	56                   	push   %esi
  8020f3:	53                   	push   %ebx
  8020f4:	83 ec 1c             	sub    $0x1c,%esp
  8020f7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  8020fb:	8b 74 24 30          	mov    0x30(%esp),%esi
  8020ff:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802103:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802107:	85 ed                	test   %ebp,%ebp
  802109:	89 f0                	mov    %esi,%eax
  80210b:	89 da                	mov    %ebx,%edx
  80210d:	75 19                	jne    802128 <__umoddi3+0x38>
  80210f:	39 df                	cmp    %ebx,%edi
  802111:	0f 86 b1 00 00 00    	jbe    8021c8 <__umoddi3+0xd8>
  802117:	f7 f7                	div    %edi
  802119:	89 d0                	mov    %edx,%eax
  80211b:	31 d2                	xor    %edx,%edx
  80211d:	83 c4 1c             	add    $0x1c,%esp
  802120:	5b                   	pop    %ebx
  802121:	5e                   	pop    %esi
  802122:	5f                   	pop    %edi
  802123:	5d                   	pop    %ebp
  802124:	c3                   	ret    
  802125:	8d 76 00             	lea    0x0(%esi),%esi
  802128:	39 dd                	cmp    %ebx,%ebp
  80212a:	77 f1                	ja     80211d <__umoddi3+0x2d>
  80212c:	0f bd cd             	bsr    %ebp,%ecx
  80212f:	83 f1 1f             	xor    $0x1f,%ecx
  802132:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802136:	0f 84 b4 00 00 00    	je     8021f0 <__umoddi3+0x100>
  80213c:	b8 20 00 00 00       	mov    $0x20,%eax
  802141:	89 c2                	mov    %eax,%edx
  802143:	8b 44 24 04          	mov    0x4(%esp),%eax
  802147:	29 c2                	sub    %eax,%edx
  802149:	89 c1                	mov    %eax,%ecx
  80214b:	89 f8                	mov    %edi,%eax
  80214d:	d3 e5                	shl    %cl,%ebp
  80214f:	89 d1                	mov    %edx,%ecx
  802151:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802155:	d3 e8                	shr    %cl,%eax
  802157:	09 c5                	or     %eax,%ebp
  802159:	8b 44 24 04          	mov    0x4(%esp),%eax
  80215d:	89 c1                	mov    %eax,%ecx
  80215f:	d3 e7                	shl    %cl,%edi
  802161:	89 d1                	mov    %edx,%ecx
  802163:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802167:	89 df                	mov    %ebx,%edi
  802169:	d3 ef                	shr    %cl,%edi
  80216b:	89 c1                	mov    %eax,%ecx
  80216d:	89 f0                	mov    %esi,%eax
  80216f:	d3 e3                	shl    %cl,%ebx
  802171:	89 d1                	mov    %edx,%ecx
  802173:	89 fa                	mov    %edi,%edx
  802175:	d3 e8                	shr    %cl,%eax
  802177:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80217c:	09 d8                	or     %ebx,%eax
  80217e:	f7 f5                	div    %ebp
  802180:	d3 e6                	shl    %cl,%esi
  802182:	89 d1                	mov    %edx,%ecx
  802184:	f7 64 24 08          	mull   0x8(%esp)
  802188:	39 d1                	cmp    %edx,%ecx
  80218a:	89 c3                	mov    %eax,%ebx
  80218c:	89 d7                	mov    %edx,%edi
  80218e:	72 06                	jb     802196 <__umoddi3+0xa6>
  802190:	75 0e                	jne    8021a0 <__umoddi3+0xb0>
  802192:	39 c6                	cmp    %eax,%esi
  802194:	73 0a                	jae    8021a0 <__umoddi3+0xb0>
  802196:	2b 44 24 08          	sub    0x8(%esp),%eax
  80219a:	19 ea                	sbb    %ebp,%edx
  80219c:	89 d7                	mov    %edx,%edi
  80219e:	89 c3                	mov    %eax,%ebx
  8021a0:	89 ca                	mov    %ecx,%edx
  8021a2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8021a7:	29 de                	sub    %ebx,%esi
  8021a9:	19 fa                	sbb    %edi,%edx
  8021ab:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  8021af:	89 d0                	mov    %edx,%eax
  8021b1:	d3 e0                	shl    %cl,%eax
  8021b3:	89 d9                	mov    %ebx,%ecx
  8021b5:	d3 ee                	shr    %cl,%esi
  8021b7:	d3 ea                	shr    %cl,%edx
  8021b9:	09 f0                	or     %esi,%eax
  8021bb:	83 c4 1c             	add    $0x1c,%esp
  8021be:	5b                   	pop    %ebx
  8021bf:	5e                   	pop    %esi
  8021c0:	5f                   	pop    %edi
  8021c1:	5d                   	pop    %ebp
  8021c2:	c3                   	ret    
  8021c3:	90                   	nop
  8021c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021c8:	85 ff                	test   %edi,%edi
  8021ca:	89 f9                	mov    %edi,%ecx
  8021cc:	75 0b                	jne    8021d9 <__umoddi3+0xe9>
  8021ce:	b8 01 00 00 00       	mov    $0x1,%eax
  8021d3:	31 d2                	xor    %edx,%edx
  8021d5:	f7 f7                	div    %edi
  8021d7:	89 c1                	mov    %eax,%ecx
  8021d9:	89 d8                	mov    %ebx,%eax
  8021db:	31 d2                	xor    %edx,%edx
  8021dd:	f7 f1                	div    %ecx
  8021df:	89 f0                	mov    %esi,%eax
  8021e1:	f7 f1                	div    %ecx
  8021e3:	e9 31 ff ff ff       	jmp    802119 <__umoddi3+0x29>
  8021e8:	90                   	nop
  8021e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021f0:	39 dd                	cmp    %ebx,%ebp
  8021f2:	72 08                	jb     8021fc <__umoddi3+0x10c>
  8021f4:	39 f7                	cmp    %esi,%edi
  8021f6:	0f 87 21 ff ff ff    	ja     80211d <__umoddi3+0x2d>
  8021fc:	89 da                	mov    %ebx,%edx
  8021fe:	89 f0                	mov    %esi,%eax
  802200:	29 f8                	sub    %edi,%eax
  802202:	19 ea                	sbb    %ebp,%edx
  802204:	e9 14 ff ff ff       	jmp    80211d <__umoddi3+0x2d>
