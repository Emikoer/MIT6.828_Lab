
obj/user/stresssched.debug:     file format elf32-i386


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
  80002c:	e8 b7 00 00 00       	call   8000e8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800038:	e8 c0 0b 00 00       	call   800bfd <sys_getenvid>
  80003d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80003f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800044:	e8 d7 0e 00 00       	call   800f20 <fork>
  800049:	85 c0                	test   %eax,%eax
  80004b:	74 0f                	je     80005c <umain+0x29>
	for (i = 0; i < 20; i++)
  80004d:	83 c3 01             	add    $0x1,%ebx
  800050:	83 fb 14             	cmp    $0x14,%ebx
  800053:	75 ef                	jne    800044 <umain+0x11>
			break;
	if (i == 20) {
		sys_yield();
  800055:	e8 c2 0b 00 00       	call   800c1c <sys_yield>
		return;
  80005a:	eb 6e                	jmp    8000ca <umain+0x97>
	if (i == 20) {
  80005c:	83 fb 14             	cmp    $0x14,%ebx
  80005f:	74 f4                	je     800055 <umain+0x22>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800061:	89 f0                	mov    %esi,%eax
  800063:	25 ff 03 00 00       	and    $0x3ff,%eax
  800068:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800070:	eb 02                	jmp    800074 <umain+0x41>
		asm volatile("pause");
  800072:	f3 90                	pause  
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800074:	8b 50 54             	mov    0x54(%eax),%edx
  800077:	85 d2                	test   %edx,%edx
  800079:	75 f7                	jne    800072 <umain+0x3f>
  80007b:	bb 0a 00 00 00       	mov    $0xa,%ebx

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  800080:	e8 97 0b 00 00       	call   800c1c <sys_yield>
  800085:	ba 10 27 00 00       	mov    $0x2710,%edx
		for (j = 0; j < 10000; j++)
			counter++;
  80008a:	a1 04 40 80 00       	mov    0x804004,%eax
  80008f:	83 c0 01             	add    $0x1,%eax
  800092:	a3 04 40 80 00       	mov    %eax,0x804004
		for (j = 0; j < 10000; j++)
  800097:	83 ea 01             	sub    $0x1,%edx
  80009a:	75 ee                	jne    80008a <umain+0x57>
	for (i = 0; i < 10; i++) {
  80009c:	83 eb 01             	sub    $0x1,%ebx
  80009f:	75 df                	jne    800080 <umain+0x4d>
	}

	if (counter != 10*10000)
  8000a1:	a1 04 40 80 00       	mov    0x804004,%eax
  8000a6:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000ab:	75 24                	jne    8000d1 <umain+0x9e>
		panic("ran on two CPUs at once (counter is %d)", counter);

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000ad:	a1 08 40 80 00       	mov    0x804008,%eax
  8000b2:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000b5:	8b 40 48             	mov    0x48(%eax),%eax
  8000b8:	83 ec 04             	sub    $0x4,%esp
  8000bb:	52                   	push   %edx
  8000bc:	50                   	push   %eax
  8000bd:	68 3b 22 80 00       	push   $0x80223b
  8000c2:	e8 5c 01 00 00       	call   800223 <cprintf>
  8000c7:	83 c4 10             	add    $0x10,%esp

}
  8000ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5d                   	pop    %ebp
  8000d0:	c3                   	ret    
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000d1:	a1 04 40 80 00       	mov    0x804004,%eax
  8000d6:	50                   	push   %eax
  8000d7:	68 00 22 80 00       	push   $0x802200
  8000dc:	6a 21                	push   $0x21
  8000de:	68 28 22 80 00       	push   $0x802228
  8000e3:	e8 60 00 00 00       	call   800148 <_panic>

008000e8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	56                   	push   %esi
  8000ec:	53                   	push   %ebx
  8000ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000f0:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000f3:	e8 05 0b 00 00       	call   800bfd <sys_getenvid>
  8000f8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000fd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800100:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800105:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010a:	85 db                	test   %ebx,%ebx
  80010c:	7e 07                	jle    800115 <libmain+0x2d>
		binaryname = argv[0];
  80010e:	8b 06                	mov    (%esi),%eax
  800110:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800115:	83 ec 08             	sub    $0x8,%esp
  800118:	56                   	push   %esi
  800119:	53                   	push   %ebx
  80011a:	e8 14 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80011f:	e8 0a 00 00 00       	call   80012e <exit>
}
  800124:	83 c4 10             	add    $0x10,%esp
  800127:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80012a:	5b                   	pop    %ebx
  80012b:	5e                   	pop    %esi
  80012c:	5d                   	pop    %ebp
  80012d:	c3                   	ret    

0080012e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80012e:	55                   	push   %ebp
  80012f:	89 e5                	mov    %esp,%ebp
  800131:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800134:	e8 ca 11 00 00       	call   801303 <close_all>
	sys_env_destroy(0);
  800139:	83 ec 0c             	sub    $0xc,%esp
  80013c:	6a 00                	push   $0x0
  80013e:	e8 79 0a 00 00       	call   800bbc <sys_env_destroy>
}
  800143:	83 c4 10             	add    $0x10,%esp
  800146:	c9                   	leave  
  800147:	c3                   	ret    

00800148 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80014d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800150:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800156:	e8 a2 0a 00 00       	call   800bfd <sys_getenvid>
  80015b:	83 ec 0c             	sub    $0xc,%esp
  80015e:	ff 75 0c             	pushl  0xc(%ebp)
  800161:	ff 75 08             	pushl  0x8(%ebp)
  800164:	56                   	push   %esi
  800165:	50                   	push   %eax
  800166:	68 64 22 80 00       	push   $0x802264
  80016b:	e8 b3 00 00 00       	call   800223 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800170:	83 c4 18             	add    $0x18,%esp
  800173:	53                   	push   %ebx
  800174:	ff 75 10             	pushl  0x10(%ebp)
  800177:	e8 56 00 00 00       	call   8001d2 <vcprintf>
	cprintf("\n");
  80017c:	c7 04 24 57 22 80 00 	movl   $0x802257,(%esp)
  800183:	e8 9b 00 00 00       	call   800223 <cprintf>
  800188:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80018b:	cc                   	int3   
  80018c:	eb fd                	jmp    80018b <_panic+0x43>

0080018e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80018e:	55                   	push   %ebp
  80018f:	89 e5                	mov    %esp,%ebp
  800191:	53                   	push   %ebx
  800192:	83 ec 04             	sub    $0x4,%esp
  800195:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800198:	8b 13                	mov    (%ebx),%edx
  80019a:	8d 42 01             	lea    0x1(%edx),%eax
  80019d:	89 03                	mov    %eax,(%ebx)
  80019f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001a6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001ab:	74 09                	je     8001b6 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001ad:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b4:	c9                   	leave  
  8001b5:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001b6:	83 ec 08             	sub    $0x8,%esp
  8001b9:	68 ff 00 00 00       	push   $0xff
  8001be:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c1:	50                   	push   %eax
  8001c2:	e8 b8 09 00 00       	call   800b7f <sys_cputs>
		b->idx = 0;
  8001c7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001cd:	83 c4 10             	add    $0x10,%esp
  8001d0:	eb db                	jmp    8001ad <putch+0x1f>

008001d2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d2:	55                   	push   %ebp
  8001d3:	89 e5                	mov    %esp,%ebp
  8001d5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001db:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e2:	00 00 00 
	b.cnt = 0;
  8001e5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ec:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ef:	ff 75 0c             	pushl  0xc(%ebp)
  8001f2:	ff 75 08             	pushl  0x8(%ebp)
  8001f5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001fb:	50                   	push   %eax
  8001fc:	68 8e 01 80 00       	push   $0x80018e
  800201:	e8 1a 01 00 00       	call   800320 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800206:	83 c4 08             	add    $0x8,%esp
  800209:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80020f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800215:	50                   	push   %eax
  800216:	e8 64 09 00 00       	call   800b7f <sys_cputs>

	return b.cnt;
}
  80021b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800221:	c9                   	leave  
  800222:	c3                   	ret    

00800223 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800223:	55                   	push   %ebp
  800224:	89 e5                	mov    %esp,%ebp
  800226:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800229:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80022c:	50                   	push   %eax
  80022d:	ff 75 08             	pushl  0x8(%ebp)
  800230:	e8 9d ff ff ff       	call   8001d2 <vcprintf>
	va_end(ap);

	return cnt;
}
  800235:	c9                   	leave  
  800236:	c3                   	ret    

00800237 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800237:	55                   	push   %ebp
  800238:	89 e5                	mov    %esp,%ebp
  80023a:	57                   	push   %edi
  80023b:	56                   	push   %esi
  80023c:	53                   	push   %ebx
  80023d:	83 ec 1c             	sub    $0x1c,%esp
  800240:	89 c7                	mov    %eax,%edi
  800242:	89 d6                	mov    %edx,%esi
  800244:	8b 45 08             	mov    0x8(%ebp),%eax
  800247:	8b 55 0c             	mov    0xc(%ebp),%edx
  80024a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80024d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800250:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800253:	bb 00 00 00 00       	mov    $0x0,%ebx
  800258:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80025b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80025e:	39 d3                	cmp    %edx,%ebx
  800260:	72 05                	jb     800267 <printnum+0x30>
  800262:	39 45 10             	cmp    %eax,0x10(%ebp)
  800265:	77 7a                	ja     8002e1 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800267:	83 ec 0c             	sub    $0xc,%esp
  80026a:	ff 75 18             	pushl  0x18(%ebp)
  80026d:	8b 45 14             	mov    0x14(%ebp),%eax
  800270:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800273:	53                   	push   %ebx
  800274:	ff 75 10             	pushl  0x10(%ebp)
  800277:	83 ec 08             	sub    $0x8,%esp
  80027a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80027d:	ff 75 e0             	pushl  -0x20(%ebp)
  800280:	ff 75 dc             	pushl  -0x24(%ebp)
  800283:	ff 75 d8             	pushl  -0x28(%ebp)
  800286:	e8 35 1d 00 00       	call   801fc0 <__udivdi3>
  80028b:	83 c4 18             	add    $0x18,%esp
  80028e:	52                   	push   %edx
  80028f:	50                   	push   %eax
  800290:	89 f2                	mov    %esi,%edx
  800292:	89 f8                	mov    %edi,%eax
  800294:	e8 9e ff ff ff       	call   800237 <printnum>
  800299:	83 c4 20             	add    $0x20,%esp
  80029c:	eb 13                	jmp    8002b1 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80029e:	83 ec 08             	sub    $0x8,%esp
  8002a1:	56                   	push   %esi
  8002a2:	ff 75 18             	pushl  0x18(%ebp)
  8002a5:	ff d7                	call   *%edi
  8002a7:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002aa:	83 eb 01             	sub    $0x1,%ebx
  8002ad:	85 db                	test   %ebx,%ebx
  8002af:	7f ed                	jg     80029e <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b1:	83 ec 08             	sub    $0x8,%esp
  8002b4:	56                   	push   %esi
  8002b5:	83 ec 04             	sub    $0x4,%esp
  8002b8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002bb:	ff 75 e0             	pushl  -0x20(%ebp)
  8002be:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c1:	ff 75 d8             	pushl  -0x28(%ebp)
  8002c4:	e8 17 1e 00 00       	call   8020e0 <__umoddi3>
  8002c9:	83 c4 14             	add    $0x14,%esp
  8002cc:	0f be 80 87 22 80 00 	movsbl 0x802287(%eax),%eax
  8002d3:	50                   	push   %eax
  8002d4:	ff d7                	call   *%edi
}
  8002d6:	83 c4 10             	add    $0x10,%esp
  8002d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002dc:	5b                   	pop    %ebx
  8002dd:	5e                   	pop    %esi
  8002de:	5f                   	pop    %edi
  8002df:	5d                   	pop    %ebp
  8002e0:	c3                   	ret    
  8002e1:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002e4:	eb c4                	jmp    8002aa <printnum+0x73>

008002e6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e6:	55                   	push   %ebp
  8002e7:	89 e5                	mov    %esp,%ebp
  8002e9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ec:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f0:	8b 10                	mov    (%eax),%edx
  8002f2:	3b 50 04             	cmp    0x4(%eax),%edx
  8002f5:	73 0a                	jae    800301 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002f7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002fa:	89 08                	mov    %ecx,(%eax)
  8002fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ff:	88 02                	mov    %al,(%edx)
}
  800301:	5d                   	pop    %ebp
  800302:	c3                   	ret    

00800303 <printfmt>:
{
  800303:	55                   	push   %ebp
  800304:	89 e5                	mov    %esp,%ebp
  800306:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800309:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80030c:	50                   	push   %eax
  80030d:	ff 75 10             	pushl  0x10(%ebp)
  800310:	ff 75 0c             	pushl  0xc(%ebp)
  800313:	ff 75 08             	pushl  0x8(%ebp)
  800316:	e8 05 00 00 00       	call   800320 <vprintfmt>
}
  80031b:	83 c4 10             	add    $0x10,%esp
  80031e:	c9                   	leave  
  80031f:	c3                   	ret    

00800320 <vprintfmt>:
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	57                   	push   %edi
  800324:	56                   	push   %esi
  800325:	53                   	push   %ebx
  800326:	83 ec 2c             	sub    $0x2c,%esp
  800329:	8b 75 08             	mov    0x8(%ebp),%esi
  80032c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80032f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800332:	e9 c1 03 00 00       	jmp    8006f8 <vprintfmt+0x3d8>
		padc = ' ';
  800337:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  80033b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800342:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800349:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800350:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800355:	8d 47 01             	lea    0x1(%edi),%eax
  800358:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80035b:	0f b6 17             	movzbl (%edi),%edx
  80035e:	8d 42 dd             	lea    -0x23(%edx),%eax
  800361:	3c 55                	cmp    $0x55,%al
  800363:	0f 87 12 04 00 00    	ja     80077b <vprintfmt+0x45b>
  800369:	0f b6 c0             	movzbl %al,%eax
  80036c:	ff 24 85 c0 23 80 00 	jmp    *0x8023c0(,%eax,4)
  800373:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800376:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80037a:	eb d9                	jmp    800355 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80037c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80037f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800383:	eb d0                	jmp    800355 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800385:	0f b6 d2             	movzbl %dl,%edx
  800388:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80038b:	b8 00 00 00 00       	mov    $0x0,%eax
  800390:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800393:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800396:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80039a:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80039d:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003a0:	83 f9 09             	cmp    $0x9,%ecx
  8003a3:	77 55                	ja     8003fa <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  8003a5:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003a8:	eb e9                	jmp    800393 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  8003aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ad:	8b 00                	mov    (%eax),%eax
  8003af:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b5:	8d 40 04             	lea    0x4(%eax),%eax
  8003b8:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003be:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003c2:	79 91                	jns    800355 <vprintfmt+0x35>
				width = precision, precision = -1;
  8003c4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ca:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003d1:	eb 82                	jmp    800355 <vprintfmt+0x35>
  8003d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003d6:	85 c0                	test   %eax,%eax
  8003d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8003dd:	0f 49 d0             	cmovns %eax,%edx
  8003e0:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e6:	e9 6a ff ff ff       	jmp    800355 <vprintfmt+0x35>
  8003eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003ee:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003f5:	e9 5b ff ff ff       	jmp    800355 <vprintfmt+0x35>
  8003fa:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003fd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800400:	eb bc                	jmp    8003be <vprintfmt+0x9e>
			lflag++;
  800402:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800405:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800408:	e9 48 ff ff ff       	jmp    800355 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  80040d:	8b 45 14             	mov    0x14(%ebp),%eax
  800410:	8d 78 04             	lea    0x4(%eax),%edi
  800413:	83 ec 08             	sub    $0x8,%esp
  800416:	53                   	push   %ebx
  800417:	ff 30                	pushl  (%eax)
  800419:	ff d6                	call   *%esi
			break;
  80041b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80041e:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800421:	e9 cf 02 00 00       	jmp    8006f5 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  800426:	8b 45 14             	mov    0x14(%ebp),%eax
  800429:	8d 78 04             	lea    0x4(%eax),%edi
  80042c:	8b 00                	mov    (%eax),%eax
  80042e:	99                   	cltd   
  80042f:	31 d0                	xor    %edx,%eax
  800431:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800433:	83 f8 0f             	cmp    $0xf,%eax
  800436:	7f 23                	jg     80045b <vprintfmt+0x13b>
  800438:	8b 14 85 20 25 80 00 	mov    0x802520(,%eax,4),%edx
  80043f:	85 d2                	test   %edx,%edx
  800441:	74 18                	je     80045b <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800443:	52                   	push   %edx
  800444:	68 95 27 80 00       	push   $0x802795
  800449:	53                   	push   %ebx
  80044a:	56                   	push   %esi
  80044b:	e8 b3 fe ff ff       	call   800303 <printfmt>
  800450:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800453:	89 7d 14             	mov    %edi,0x14(%ebp)
  800456:	e9 9a 02 00 00       	jmp    8006f5 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  80045b:	50                   	push   %eax
  80045c:	68 9f 22 80 00       	push   $0x80229f
  800461:	53                   	push   %ebx
  800462:	56                   	push   %esi
  800463:	e8 9b fe ff ff       	call   800303 <printfmt>
  800468:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80046b:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80046e:	e9 82 02 00 00       	jmp    8006f5 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  800473:	8b 45 14             	mov    0x14(%ebp),%eax
  800476:	83 c0 04             	add    $0x4,%eax
  800479:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80047c:	8b 45 14             	mov    0x14(%ebp),%eax
  80047f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800481:	85 ff                	test   %edi,%edi
  800483:	b8 98 22 80 00       	mov    $0x802298,%eax
  800488:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80048b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80048f:	0f 8e bd 00 00 00    	jle    800552 <vprintfmt+0x232>
  800495:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800499:	75 0e                	jne    8004a9 <vprintfmt+0x189>
  80049b:	89 75 08             	mov    %esi,0x8(%ebp)
  80049e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004a1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004a4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004a7:	eb 6d                	jmp    800516 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a9:	83 ec 08             	sub    $0x8,%esp
  8004ac:	ff 75 d0             	pushl  -0x30(%ebp)
  8004af:	57                   	push   %edi
  8004b0:	e8 6e 03 00 00       	call   800823 <strnlen>
  8004b5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004b8:	29 c1                	sub    %eax,%ecx
  8004ba:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004bd:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004c0:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004c4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004ca:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cc:	eb 0f                	jmp    8004dd <vprintfmt+0x1bd>
					putch(padc, putdat);
  8004ce:	83 ec 08             	sub    $0x8,%esp
  8004d1:	53                   	push   %ebx
  8004d2:	ff 75 e0             	pushl  -0x20(%ebp)
  8004d5:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d7:	83 ef 01             	sub    $0x1,%edi
  8004da:	83 c4 10             	add    $0x10,%esp
  8004dd:	85 ff                	test   %edi,%edi
  8004df:	7f ed                	jg     8004ce <vprintfmt+0x1ae>
  8004e1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004e4:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004e7:	85 c9                	test   %ecx,%ecx
  8004e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ee:	0f 49 c1             	cmovns %ecx,%eax
  8004f1:	29 c1                	sub    %eax,%ecx
  8004f3:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004fc:	89 cb                	mov    %ecx,%ebx
  8004fe:	eb 16                	jmp    800516 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  800500:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800504:	75 31                	jne    800537 <vprintfmt+0x217>
					putch(ch, putdat);
  800506:	83 ec 08             	sub    $0x8,%esp
  800509:	ff 75 0c             	pushl  0xc(%ebp)
  80050c:	50                   	push   %eax
  80050d:	ff 55 08             	call   *0x8(%ebp)
  800510:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800513:	83 eb 01             	sub    $0x1,%ebx
  800516:	83 c7 01             	add    $0x1,%edi
  800519:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  80051d:	0f be c2             	movsbl %dl,%eax
  800520:	85 c0                	test   %eax,%eax
  800522:	74 59                	je     80057d <vprintfmt+0x25d>
  800524:	85 f6                	test   %esi,%esi
  800526:	78 d8                	js     800500 <vprintfmt+0x1e0>
  800528:	83 ee 01             	sub    $0x1,%esi
  80052b:	79 d3                	jns    800500 <vprintfmt+0x1e0>
  80052d:	89 df                	mov    %ebx,%edi
  80052f:	8b 75 08             	mov    0x8(%ebp),%esi
  800532:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800535:	eb 37                	jmp    80056e <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  800537:	0f be d2             	movsbl %dl,%edx
  80053a:	83 ea 20             	sub    $0x20,%edx
  80053d:	83 fa 5e             	cmp    $0x5e,%edx
  800540:	76 c4                	jbe    800506 <vprintfmt+0x1e6>
					putch('?', putdat);
  800542:	83 ec 08             	sub    $0x8,%esp
  800545:	ff 75 0c             	pushl  0xc(%ebp)
  800548:	6a 3f                	push   $0x3f
  80054a:	ff 55 08             	call   *0x8(%ebp)
  80054d:	83 c4 10             	add    $0x10,%esp
  800550:	eb c1                	jmp    800513 <vprintfmt+0x1f3>
  800552:	89 75 08             	mov    %esi,0x8(%ebp)
  800555:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800558:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80055b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80055e:	eb b6                	jmp    800516 <vprintfmt+0x1f6>
				putch(' ', putdat);
  800560:	83 ec 08             	sub    $0x8,%esp
  800563:	53                   	push   %ebx
  800564:	6a 20                	push   $0x20
  800566:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800568:	83 ef 01             	sub    $0x1,%edi
  80056b:	83 c4 10             	add    $0x10,%esp
  80056e:	85 ff                	test   %edi,%edi
  800570:	7f ee                	jg     800560 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800572:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800575:	89 45 14             	mov    %eax,0x14(%ebp)
  800578:	e9 78 01 00 00       	jmp    8006f5 <vprintfmt+0x3d5>
  80057d:	89 df                	mov    %ebx,%edi
  80057f:	8b 75 08             	mov    0x8(%ebp),%esi
  800582:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800585:	eb e7                	jmp    80056e <vprintfmt+0x24e>
	if (lflag >= 2)
  800587:	83 f9 01             	cmp    $0x1,%ecx
  80058a:	7e 3f                	jle    8005cb <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  80058c:	8b 45 14             	mov    0x14(%ebp),%eax
  80058f:	8b 50 04             	mov    0x4(%eax),%edx
  800592:	8b 00                	mov    (%eax),%eax
  800594:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800597:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80059a:	8b 45 14             	mov    0x14(%ebp),%eax
  80059d:	8d 40 08             	lea    0x8(%eax),%eax
  8005a0:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005a3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005a7:	79 5c                	jns    800605 <vprintfmt+0x2e5>
				putch('-', putdat);
  8005a9:	83 ec 08             	sub    $0x8,%esp
  8005ac:	53                   	push   %ebx
  8005ad:	6a 2d                	push   $0x2d
  8005af:	ff d6                	call   *%esi
				num = -(long long) num;
  8005b1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005b4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005b7:	f7 da                	neg    %edx
  8005b9:	83 d1 00             	adc    $0x0,%ecx
  8005bc:	f7 d9                	neg    %ecx
  8005be:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005c1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005c6:	e9 10 01 00 00       	jmp    8006db <vprintfmt+0x3bb>
	else if (lflag)
  8005cb:	85 c9                	test   %ecx,%ecx
  8005cd:	75 1b                	jne    8005ea <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8005cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d2:	8b 00                	mov    (%eax),%eax
  8005d4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d7:	89 c1                	mov    %eax,%ecx
  8005d9:	c1 f9 1f             	sar    $0x1f,%ecx
  8005dc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005df:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e2:	8d 40 04             	lea    0x4(%eax),%eax
  8005e5:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e8:	eb b9                	jmp    8005a3 <vprintfmt+0x283>
		return va_arg(*ap, long);
  8005ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ed:	8b 00                	mov    (%eax),%eax
  8005ef:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f2:	89 c1                	mov    %eax,%ecx
  8005f4:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fd:	8d 40 04             	lea    0x4(%eax),%eax
  800600:	89 45 14             	mov    %eax,0x14(%ebp)
  800603:	eb 9e                	jmp    8005a3 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  800605:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800608:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80060b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800610:	e9 c6 00 00 00       	jmp    8006db <vprintfmt+0x3bb>
	if (lflag >= 2)
  800615:	83 f9 01             	cmp    $0x1,%ecx
  800618:	7e 18                	jle    800632 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  80061a:	8b 45 14             	mov    0x14(%ebp),%eax
  80061d:	8b 10                	mov    (%eax),%edx
  80061f:	8b 48 04             	mov    0x4(%eax),%ecx
  800622:	8d 40 08             	lea    0x8(%eax),%eax
  800625:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800628:	b8 0a 00 00 00       	mov    $0xa,%eax
  80062d:	e9 a9 00 00 00       	jmp    8006db <vprintfmt+0x3bb>
	else if (lflag)
  800632:	85 c9                	test   %ecx,%ecx
  800634:	75 1a                	jne    800650 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  800636:	8b 45 14             	mov    0x14(%ebp),%eax
  800639:	8b 10                	mov    (%eax),%edx
  80063b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800640:	8d 40 04             	lea    0x4(%eax),%eax
  800643:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800646:	b8 0a 00 00 00       	mov    $0xa,%eax
  80064b:	e9 8b 00 00 00       	jmp    8006db <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800650:	8b 45 14             	mov    0x14(%ebp),%eax
  800653:	8b 10                	mov    (%eax),%edx
  800655:	b9 00 00 00 00       	mov    $0x0,%ecx
  80065a:	8d 40 04             	lea    0x4(%eax),%eax
  80065d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800660:	b8 0a 00 00 00       	mov    $0xa,%eax
  800665:	eb 74                	jmp    8006db <vprintfmt+0x3bb>
	if (lflag >= 2)
  800667:	83 f9 01             	cmp    $0x1,%ecx
  80066a:	7e 15                	jle    800681 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  80066c:	8b 45 14             	mov    0x14(%ebp),%eax
  80066f:	8b 10                	mov    (%eax),%edx
  800671:	8b 48 04             	mov    0x4(%eax),%ecx
  800674:	8d 40 08             	lea    0x8(%eax),%eax
  800677:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80067a:	b8 08 00 00 00       	mov    $0x8,%eax
  80067f:	eb 5a                	jmp    8006db <vprintfmt+0x3bb>
	else if (lflag)
  800681:	85 c9                	test   %ecx,%ecx
  800683:	75 17                	jne    80069c <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  800685:	8b 45 14             	mov    0x14(%ebp),%eax
  800688:	8b 10                	mov    (%eax),%edx
  80068a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80068f:	8d 40 04             	lea    0x4(%eax),%eax
  800692:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800695:	b8 08 00 00 00       	mov    $0x8,%eax
  80069a:	eb 3f                	jmp    8006db <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80069c:	8b 45 14             	mov    0x14(%ebp),%eax
  80069f:	8b 10                	mov    (%eax),%edx
  8006a1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006a6:	8d 40 04             	lea    0x4(%eax),%eax
  8006a9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006ac:	b8 08 00 00 00       	mov    $0x8,%eax
  8006b1:	eb 28                	jmp    8006db <vprintfmt+0x3bb>
			putch('0', putdat);
  8006b3:	83 ec 08             	sub    $0x8,%esp
  8006b6:	53                   	push   %ebx
  8006b7:	6a 30                	push   $0x30
  8006b9:	ff d6                	call   *%esi
			putch('x', putdat);
  8006bb:	83 c4 08             	add    $0x8,%esp
  8006be:	53                   	push   %ebx
  8006bf:	6a 78                	push   $0x78
  8006c1:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c6:	8b 10                	mov    (%eax),%edx
  8006c8:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006cd:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006d0:	8d 40 04             	lea    0x4(%eax),%eax
  8006d3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d6:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006db:	83 ec 0c             	sub    $0xc,%esp
  8006de:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006e2:	57                   	push   %edi
  8006e3:	ff 75 e0             	pushl  -0x20(%ebp)
  8006e6:	50                   	push   %eax
  8006e7:	51                   	push   %ecx
  8006e8:	52                   	push   %edx
  8006e9:	89 da                	mov    %ebx,%edx
  8006eb:	89 f0                	mov    %esi,%eax
  8006ed:	e8 45 fb ff ff       	call   800237 <printnum>
			break;
  8006f2:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8006f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006f8:	83 c7 01             	add    $0x1,%edi
  8006fb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006ff:	83 f8 25             	cmp    $0x25,%eax
  800702:	0f 84 2f fc ff ff    	je     800337 <vprintfmt+0x17>
			if (ch == '\0')
  800708:	85 c0                	test   %eax,%eax
  80070a:	0f 84 8b 00 00 00    	je     80079b <vprintfmt+0x47b>
			putch(ch, putdat);
  800710:	83 ec 08             	sub    $0x8,%esp
  800713:	53                   	push   %ebx
  800714:	50                   	push   %eax
  800715:	ff d6                	call   *%esi
  800717:	83 c4 10             	add    $0x10,%esp
  80071a:	eb dc                	jmp    8006f8 <vprintfmt+0x3d8>
	if (lflag >= 2)
  80071c:	83 f9 01             	cmp    $0x1,%ecx
  80071f:	7e 15                	jle    800736 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  800721:	8b 45 14             	mov    0x14(%ebp),%eax
  800724:	8b 10                	mov    (%eax),%edx
  800726:	8b 48 04             	mov    0x4(%eax),%ecx
  800729:	8d 40 08             	lea    0x8(%eax),%eax
  80072c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80072f:	b8 10 00 00 00       	mov    $0x10,%eax
  800734:	eb a5                	jmp    8006db <vprintfmt+0x3bb>
	else if (lflag)
  800736:	85 c9                	test   %ecx,%ecx
  800738:	75 17                	jne    800751 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  80073a:	8b 45 14             	mov    0x14(%ebp),%eax
  80073d:	8b 10                	mov    (%eax),%edx
  80073f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800744:	8d 40 04             	lea    0x4(%eax),%eax
  800747:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80074a:	b8 10 00 00 00       	mov    $0x10,%eax
  80074f:	eb 8a                	jmp    8006db <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800751:	8b 45 14             	mov    0x14(%ebp),%eax
  800754:	8b 10                	mov    (%eax),%edx
  800756:	b9 00 00 00 00       	mov    $0x0,%ecx
  80075b:	8d 40 04             	lea    0x4(%eax),%eax
  80075e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800761:	b8 10 00 00 00       	mov    $0x10,%eax
  800766:	e9 70 ff ff ff       	jmp    8006db <vprintfmt+0x3bb>
			putch(ch, putdat);
  80076b:	83 ec 08             	sub    $0x8,%esp
  80076e:	53                   	push   %ebx
  80076f:	6a 25                	push   $0x25
  800771:	ff d6                	call   *%esi
			break;
  800773:	83 c4 10             	add    $0x10,%esp
  800776:	e9 7a ff ff ff       	jmp    8006f5 <vprintfmt+0x3d5>
			putch('%', putdat);
  80077b:	83 ec 08             	sub    $0x8,%esp
  80077e:	53                   	push   %ebx
  80077f:	6a 25                	push   $0x25
  800781:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800783:	83 c4 10             	add    $0x10,%esp
  800786:	89 f8                	mov    %edi,%eax
  800788:	eb 03                	jmp    80078d <vprintfmt+0x46d>
  80078a:	83 e8 01             	sub    $0x1,%eax
  80078d:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800791:	75 f7                	jne    80078a <vprintfmt+0x46a>
  800793:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800796:	e9 5a ff ff ff       	jmp    8006f5 <vprintfmt+0x3d5>
}
  80079b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80079e:	5b                   	pop    %ebx
  80079f:	5e                   	pop    %esi
  8007a0:	5f                   	pop    %edi
  8007a1:	5d                   	pop    %ebp
  8007a2:	c3                   	ret    

008007a3 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007a3:	55                   	push   %ebp
  8007a4:	89 e5                	mov    %esp,%ebp
  8007a6:	83 ec 18             	sub    $0x18,%esp
  8007a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ac:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007af:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007b2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007b6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007b9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007c0:	85 c0                	test   %eax,%eax
  8007c2:	74 26                	je     8007ea <vsnprintf+0x47>
  8007c4:	85 d2                	test   %edx,%edx
  8007c6:	7e 22                	jle    8007ea <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007c8:	ff 75 14             	pushl  0x14(%ebp)
  8007cb:	ff 75 10             	pushl  0x10(%ebp)
  8007ce:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007d1:	50                   	push   %eax
  8007d2:	68 e6 02 80 00       	push   $0x8002e6
  8007d7:	e8 44 fb ff ff       	call   800320 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007df:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007e5:	83 c4 10             	add    $0x10,%esp
}
  8007e8:	c9                   	leave  
  8007e9:	c3                   	ret    
		return -E_INVAL;
  8007ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007ef:	eb f7                	jmp    8007e8 <vsnprintf+0x45>

008007f1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007f1:	55                   	push   %ebp
  8007f2:	89 e5                	mov    %esp,%ebp
  8007f4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007f7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007fa:	50                   	push   %eax
  8007fb:	ff 75 10             	pushl  0x10(%ebp)
  8007fe:	ff 75 0c             	pushl  0xc(%ebp)
  800801:	ff 75 08             	pushl  0x8(%ebp)
  800804:	e8 9a ff ff ff       	call   8007a3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800809:	c9                   	leave  
  80080a:	c3                   	ret    

0080080b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80080b:	55                   	push   %ebp
  80080c:	89 e5                	mov    %esp,%ebp
  80080e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800811:	b8 00 00 00 00       	mov    $0x0,%eax
  800816:	eb 03                	jmp    80081b <strlen+0x10>
		n++;
  800818:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80081b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80081f:	75 f7                	jne    800818 <strlen+0xd>
	return n;
}
  800821:	5d                   	pop    %ebp
  800822:	c3                   	ret    

00800823 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800829:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80082c:	b8 00 00 00 00       	mov    $0x0,%eax
  800831:	eb 03                	jmp    800836 <strnlen+0x13>
		n++;
  800833:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800836:	39 d0                	cmp    %edx,%eax
  800838:	74 06                	je     800840 <strnlen+0x1d>
  80083a:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80083e:	75 f3                	jne    800833 <strnlen+0x10>
	return n;
}
  800840:	5d                   	pop    %ebp
  800841:	c3                   	ret    

00800842 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	53                   	push   %ebx
  800846:	8b 45 08             	mov    0x8(%ebp),%eax
  800849:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80084c:	89 c2                	mov    %eax,%edx
  80084e:	83 c1 01             	add    $0x1,%ecx
  800851:	83 c2 01             	add    $0x1,%edx
  800854:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800858:	88 5a ff             	mov    %bl,-0x1(%edx)
  80085b:	84 db                	test   %bl,%bl
  80085d:	75 ef                	jne    80084e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80085f:	5b                   	pop    %ebx
  800860:	5d                   	pop    %ebp
  800861:	c3                   	ret    

00800862 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	53                   	push   %ebx
  800866:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800869:	53                   	push   %ebx
  80086a:	e8 9c ff ff ff       	call   80080b <strlen>
  80086f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800872:	ff 75 0c             	pushl  0xc(%ebp)
  800875:	01 d8                	add    %ebx,%eax
  800877:	50                   	push   %eax
  800878:	e8 c5 ff ff ff       	call   800842 <strcpy>
	return dst;
}
  80087d:	89 d8                	mov    %ebx,%eax
  80087f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800882:	c9                   	leave  
  800883:	c3                   	ret    

00800884 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800884:	55                   	push   %ebp
  800885:	89 e5                	mov    %esp,%ebp
  800887:	56                   	push   %esi
  800888:	53                   	push   %ebx
  800889:	8b 75 08             	mov    0x8(%ebp),%esi
  80088c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80088f:	89 f3                	mov    %esi,%ebx
  800891:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800894:	89 f2                	mov    %esi,%edx
  800896:	eb 0f                	jmp    8008a7 <strncpy+0x23>
		*dst++ = *src;
  800898:	83 c2 01             	add    $0x1,%edx
  80089b:	0f b6 01             	movzbl (%ecx),%eax
  80089e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008a1:	80 39 01             	cmpb   $0x1,(%ecx)
  8008a4:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8008a7:	39 da                	cmp    %ebx,%edx
  8008a9:	75 ed                	jne    800898 <strncpy+0x14>
	}
	return ret;
}
  8008ab:	89 f0                	mov    %esi,%eax
  8008ad:	5b                   	pop    %ebx
  8008ae:	5e                   	pop    %esi
  8008af:	5d                   	pop    %ebp
  8008b0:	c3                   	ret    

008008b1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008b1:	55                   	push   %ebp
  8008b2:	89 e5                	mov    %esp,%ebp
  8008b4:	56                   	push   %esi
  8008b5:	53                   	push   %ebx
  8008b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8008b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008bc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008bf:	89 f0                	mov    %esi,%eax
  8008c1:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008c5:	85 c9                	test   %ecx,%ecx
  8008c7:	75 0b                	jne    8008d4 <strlcpy+0x23>
  8008c9:	eb 17                	jmp    8008e2 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008cb:	83 c2 01             	add    $0x1,%edx
  8008ce:	83 c0 01             	add    $0x1,%eax
  8008d1:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8008d4:	39 d8                	cmp    %ebx,%eax
  8008d6:	74 07                	je     8008df <strlcpy+0x2e>
  8008d8:	0f b6 0a             	movzbl (%edx),%ecx
  8008db:	84 c9                	test   %cl,%cl
  8008dd:	75 ec                	jne    8008cb <strlcpy+0x1a>
		*dst = '\0';
  8008df:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008e2:	29 f0                	sub    %esi,%eax
}
  8008e4:	5b                   	pop    %ebx
  8008e5:	5e                   	pop    %esi
  8008e6:	5d                   	pop    %ebp
  8008e7:	c3                   	ret    

008008e8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ee:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008f1:	eb 06                	jmp    8008f9 <strcmp+0x11>
		p++, q++;
  8008f3:	83 c1 01             	add    $0x1,%ecx
  8008f6:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008f9:	0f b6 01             	movzbl (%ecx),%eax
  8008fc:	84 c0                	test   %al,%al
  8008fe:	74 04                	je     800904 <strcmp+0x1c>
  800900:	3a 02                	cmp    (%edx),%al
  800902:	74 ef                	je     8008f3 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800904:	0f b6 c0             	movzbl %al,%eax
  800907:	0f b6 12             	movzbl (%edx),%edx
  80090a:	29 d0                	sub    %edx,%eax
}
  80090c:	5d                   	pop    %ebp
  80090d:	c3                   	ret    

0080090e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80090e:	55                   	push   %ebp
  80090f:	89 e5                	mov    %esp,%ebp
  800911:	53                   	push   %ebx
  800912:	8b 45 08             	mov    0x8(%ebp),%eax
  800915:	8b 55 0c             	mov    0xc(%ebp),%edx
  800918:	89 c3                	mov    %eax,%ebx
  80091a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80091d:	eb 06                	jmp    800925 <strncmp+0x17>
		n--, p++, q++;
  80091f:	83 c0 01             	add    $0x1,%eax
  800922:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800925:	39 d8                	cmp    %ebx,%eax
  800927:	74 16                	je     80093f <strncmp+0x31>
  800929:	0f b6 08             	movzbl (%eax),%ecx
  80092c:	84 c9                	test   %cl,%cl
  80092e:	74 04                	je     800934 <strncmp+0x26>
  800930:	3a 0a                	cmp    (%edx),%cl
  800932:	74 eb                	je     80091f <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800934:	0f b6 00             	movzbl (%eax),%eax
  800937:	0f b6 12             	movzbl (%edx),%edx
  80093a:	29 d0                	sub    %edx,%eax
}
  80093c:	5b                   	pop    %ebx
  80093d:	5d                   	pop    %ebp
  80093e:	c3                   	ret    
		return 0;
  80093f:	b8 00 00 00 00       	mov    $0x0,%eax
  800944:	eb f6                	jmp    80093c <strncmp+0x2e>

00800946 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	8b 45 08             	mov    0x8(%ebp),%eax
  80094c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800950:	0f b6 10             	movzbl (%eax),%edx
  800953:	84 d2                	test   %dl,%dl
  800955:	74 09                	je     800960 <strchr+0x1a>
		if (*s == c)
  800957:	38 ca                	cmp    %cl,%dl
  800959:	74 0a                	je     800965 <strchr+0x1f>
	for (; *s; s++)
  80095b:	83 c0 01             	add    $0x1,%eax
  80095e:	eb f0                	jmp    800950 <strchr+0xa>
			return (char *) s;
	return 0;
  800960:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800965:	5d                   	pop    %ebp
  800966:	c3                   	ret    

00800967 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	8b 45 08             	mov    0x8(%ebp),%eax
  80096d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800971:	eb 03                	jmp    800976 <strfind+0xf>
  800973:	83 c0 01             	add    $0x1,%eax
  800976:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800979:	38 ca                	cmp    %cl,%dl
  80097b:	74 04                	je     800981 <strfind+0x1a>
  80097d:	84 d2                	test   %dl,%dl
  80097f:	75 f2                	jne    800973 <strfind+0xc>
			break;
	return (char *) s;
}
  800981:	5d                   	pop    %ebp
  800982:	c3                   	ret    

00800983 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	57                   	push   %edi
  800987:	56                   	push   %esi
  800988:	53                   	push   %ebx
  800989:	8b 7d 08             	mov    0x8(%ebp),%edi
  80098c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80098f:	85 c9                	test   %ecx,%ecx
  800991:	74 13                	je     8009a6 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800993:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800999:	75 05                	jne    8009a0 <memset+0x1d>
  80099b:	f6 c1 03             	test   $0x3,%cl
  80099e:	74 0d                	je     8009ad <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a3:	fc                   	cld    
  8009a4:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009a6:	89 f8                	mov    %edi,%eax
  8009a8:	5b                   	pop    %ebx
  8009a9:	5e                   	pop    %esi
  8009aa:	5f                   	pop    %edi
  8009ab:	5d                   	pop    %ebp
  8009ac:	c3                   	ret    
		c &= 0xFF;
  8009ad:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009b1:	89 d3                	mov    %edx,%ebx
  8009b3:	c1 e3 08             	shl    $0x8,%ebx
  8009b6:	89 d0                	mov    %edx,%eax
  8009b8:	c1 e0 18             	shl    $0x18,%eax
  8009bb:	89 d6                	mov    %edx,%esi
  8009bd:	c1 e6 10             	shl    $0x10,%esi
  8009c0:	09 f0                	or     %esi,%eax
  8009c2:	09 c2                	or     %eax,%edx
  8009c4:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  8009c6:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009c9:	89 d0                	mov    %edx,%eax
  8009cb:	fc                   	cld    
  8009cc:	f3 ab                	rep stos %eax,%es:(%edi)
  8009ce:	eb d6                	jmp    8009a6 <memset+0x23>

008009d0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
  8009d3:	57                   	push   %edi
  8009d4:	56                   	push   %esi
  8009d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009db:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009de:	39 c6                	cmp    %eax,%esi
  8009e0:	73 35                	jae    800a17 <memmove+0x47>
  8009e2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009e5:	39 c2                	cmp    %eax,%edx
  8009e7:	76 2e                	jbe    800a17 <memmove+0x47>
		s += n;
		d += n;
  8009e9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ec:	89 d6                	mov    %edx,%esi
  8009ee:	09 fe                	or     %edi,%esi
  8009f0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009f6:	74 0c                	je     800a04 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009f8:	83 ef 01             	sub    $0x1,%edi
  8009fb:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009fe:	fd                   	std    
  8009ff:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a01:	fc                   	cld    
  800a02:	eb 21                	jmp    800a25 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a04:	f6 c1 03             	test   $0x3,%cl
  800a07:	75 ef                	jne    8009f8 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a09:	83 ef 04             	sub    $0x4,%edi
  800a0c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a0f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a12:	fd                   	std    
  800a13:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a15:	eb ea                	jmp    800a01 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a17:	89 f2                	mov    %esi,%edx
  800a19:	09 c2                	or     %eax,%edx
  800a1b:	f6 c2 03             	test   $0x3,%dl
  800a1e:	74 09                	je     800a29 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a20:	89 c7                	mov    %eax,%edi
  800a22:	fc                   	cld    
  800a23:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a25:	5e                   	pop    %esi
  800a26:	5f                   	pop    %edi
  800a27:	5d                   	pop    %ebp
  800a28:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a29:	f6 c1 03             	test   $0x3,%cl
  800a2c:	75 f2                	jne    800a20 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a2e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a31:	89 c7                	mov    %eax,%edi
  800a33:	fc                   	cld    
  800a34:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a36:	eb ed                	jmp    800a25 <memmove+0x55>

00800a38 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a38:	55                   	push   %ebp
  800a39:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a3b:	ff 75 10             	pushl  0x10(%ebp)
  800a3e:	ff 75 0c             	pushl  0xc(%ebp)
  800a41:	ff 75 08             	pushl  0x8(%ebp)
  800a44:	e8 87 ff ff ff       	call   8009d0 <memmove>
}
  800a49:	c9                   	leave  
  800a4a:	c3                   	ret    

00800a4b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a4b:	55                   	push   %ebp
  800a4c:	89 e5                	mov    %esp,%ebp
  800a4e:	56                   	push   %esi
  800a4f:	53                   	push   %ebx
  800a50:	8b 45 08             	mov    0x8(%ebp),%eax
  800a53:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a56:	89 c6                	mov    %eax,%esi
  800a58:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a5b:	39 f0                	cmp    %esi,%eax
  800a5d:	74 1c                	je     800a7b <memcmp+0x30>
		if (*s1 != *s2)
  800a5f:	0f b6 08             	movzbl (%eax),%ecx
  800a62:	0f b6 1a             	movzbl (%edx),%ebx
  800a65:	38 d9                	cmp    %bl,%cl
  800a67:	75 08                	jne    800a71 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a69:	83 c0 01             	add    $0x1,%eax
  800a6c:	83 c2 01             	add    $0x1,%edx
  800a6f:	eb ea                	jmp    800a5b <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a71:	0f b6 c1             	movzbl %cl,%eax
  800a74:	0f b6 db             	movzbl %bl,%ebx
  800a77:	29 d8                	sub    %ebx,%eax
  800a79:	eb 05                	jmp    800a80 <memcmp+0x35>
	}

	return 0;
  800a7b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a80:	5b                   	pop    %ebx
  800a81:	5e                   	pop    %esi
  800a82:	5d                   	pop    %ebp
  800a83:	c3                   	ret    

00800a84 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a8d:	89 c2                	mov    %eax,%edx
  800a8f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a92:	39 d0                	cmp    %edx,%eax
  800a94:	73 09                	jae    800a9f <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a96:	38 08                	cmp    %cl,(%eax)
  800a98:	74 05                	je     800a9f <memfind+0x1b>
	for (; s < ends; s++)
  800a9a:	83 c0 01             	add    $0x1,%eax
  800a9d:	eb f3                	jmp    800a92 <memfind+0xe>
			break;
	return (void *) s;
}
  800a9f:	5d                   	pop    %ebp
  800aa0:	c3                   	ret    

00800aa1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	57                   	push   %edi
  800aa5:	56                   	push   %esi
  800aa6:	53                   	push   %ebx
  800aa7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aaa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aad:	eb 03                	jmp    800ab2 <strtol+0x11>
		s++;
  800aaf:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800ab2:	0f b6 01             	movzbl (%ecx),%eax
  800ab5:	3c 20                	cmp    $0x20,%al
  800ab7:	74 f6                	je     800aaf <strtol+0xe>
  800ab9:	3c 09                	cmp    $0x9,%al
  800abb:	74 f2                	je     800aaf <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800abd:	3c 2b                	cmp    $0x2b,%al
  800abf:	74 2e                	je     800aef <strtol+0x4e>
	int neg = 0;
  800ac1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800ac6:	3c 2d                	cmp    $0x2d,%al
  800ac8:	74 2f                	je     800af9 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aca:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ad0:	75 05                	jne    800ad7 <strtol+0x36>
  800ad2:	80 39 30             	cmpb   $0x30,(%ecx)
  800ad5:	74 2c                	je     800b03 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ad7:	85 db                	test   %ebx,%ebx
  800ad9:	75 0a                	jne    800ae5 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800adb:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800ae0:	80 39 30             	cmpb   $0x30,(%ecx)
  800ae3:	74 28                	je     800b0d <strtol+0x6c>
		base = 10;
  800ae5:	b8 00 00 00 00       	mov    $0x0,%eax
  800aea:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800aed:	eb 50                	jmp    800b3f <strtol+0x9e>
		s++;
  800aef:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800af2:	bf 00 00 00 00       	mov    $0x0,%edi
  800af7:	eb d1                	jmp    800aca <strtol+0x29>
		s++, neg = 1;
  800af9:	83 c1 01             	add    $0x1,%ecx
  800afc:	bf 01 00 00 00       	mov    $0x1,%edi
  800b01:	eb c7                	jmp    800aca <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b03:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b07:	74 0e                	je     800b17 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b09:	85 db                	test   %ebx,%ebx
  800b0b:	75 d8                	jne    800ae5 <strtol+0x44>
		s++, base = 8;
  800b0d:	83 c1 01             	add    $0x1,%ecx
  800b10:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b15:	eb ce                	jmp    800ae5 <strtol+0x44>
		s += 2, base = 16;
  800b17:	83 c1 02             	add    $0x2,%ecx
  800b1a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b1f:	eb c4                	jmp    800ae5 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800b21:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b24:	89 f3                	mov    %esi,%ebx
  800b26:	80 fb 19             	cmp    $0x19,%bl
  800b29:	77 29                	ja     800b54 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b2b:	0f be d2             	movsbl %dl,%edx
  800b2e:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b31:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b34:	7d 30                	jge    800b66 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b36:	83 c1 01             	add    $0x1,%ecx
  800b39:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b3d:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b3f:	0f b6 11             	movzbl (%ecx),%edx
  800b42:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b45:	89 f3                	mov    %esi,%ebx
  800b47:	80 fb 09             	cmp    $0x9,%bl
  800b4a:	77 d5                	ja     800b21 <strtol+0x80>
			dig = *s - '0';
  800b4c:	0f be d2             	movsbl %dl,%edx
  800b4f:	83 ea 30             	sub    $0x30,%edx
  800b52:	eb dd                	jmp    800b31 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800b54:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b57:	89 f3                	mov    %esi,%ebx
  800b59:	80 fb 19             	cmp    $0x19,%bl
  800b5c:	77 08                	ja     800b66 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b5e:	0f be d2             	movsbl %dl,%edx
  800b61:	83 ea 37             	sub    $0x37,%edx
  800b64:	eb cb                	jmp    800b31 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b66:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b6a:	74 05                	je     800b71 <strtol+0xd0>
		*endptr = (char *) s;
  800b6c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b6f:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b71:	89 c2                	mov    %eax,%edx
  800b73:	f7 da                	neg    %edx
  800b75:	85 ff                	test   %edi,%edi
  800b77:	0f 45 c2             	cmovne %edx,%eax
}
  800b7a:	5b                   	pop    %ebx
  800b7b:	5e                   	pop    %esi
  800b7c:	5f                   	pop    %edi
  800b7d:	5d                   	pop    %ebp
  800b7e:	c3                   	ret    

00800b7f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b7f:	55                   	push   %ebp
  800b80:	89 e5                	mov    %esp,%ebp
  800b82:	57                   	push   %edi
  800b83:	56                   	push   %esi
  800b84:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b85:	b8 00 00 00 00       	mov    $0x0,%eax
  800b8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b90:	89 c3                	mov    %eax,%ebx
  800b92:	89 c7                	mov    %eax,%edi
  800b94:	89 c6                	mov    %eax,%esi
  800b96:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b98:	5b                   	pop    %ebx
  800b99:	5e                   	pop    %esi
  800b9a:	5f                   	pop    %edi
  800b9b:	5d                   	pop    %ebp
  800b9c:	c3                   	ret    

00800b9d <sys_cgetc>:

int
sys_cgetc(void)
{
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	57                   	push   %edi
  800ba1:	56                   	push   %esi
  800ba2:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ba3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba8:	b8 01 00 00 00       	mov    $0x1,%eax
  800bad:	89 d1                	mov    %edx,%ecx
  800baf:	89 d3                	mov    %edx,%ebx
  800bb1:	89 d7                	mov    %edx,%edi
  800bb3:	89 d6                	mov    %edx,%esi
  800bb5:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bb7:	5b                   	pop    %ebx
  800bb8:	5e                   	pop    %esi
  800bb9:	5f                   	pop    %edi
  800bba:	5d                   	pop    %ebp
  800bbb:	c3                   	ret    

00800bbc <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bbc:	55                   	push   %ebp
  800bbd:	89 e5                	mov    %esp,%ebp
  800bbf:	57                   	push   %edi
  800bc0:	56                   	push   %esi
  800bc1:	53                   	push   %ebx
  800bc2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bc5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bca:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcd:	b8 03 00 00 00       	mov    $0x3,%eax
  800bd2:	89 cb                	mov    %ecx,%ebx
  800bd4:	89 cf                	mov    %ecx,%edi
  800bd6:	89 ce                	mov    %ecx,%esi
  800bd8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bda:	85 c0                	test   %eax,%eax
  800bdc:	7f 08                	jg     800be6 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bde:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be1:	5b                   	pop    %ebx
  800be2:	5e                   	pop    %esi
  800be3:	5f                   	pop    %edi
  800be4:	5d                   	pop    %ebp
  800be5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800be6:	83 ec 0c             	sub    $0xc,%esp
  800be9:	50                   	push   %eax
  800bea:	6a 03                	push   $0x3
  800bec:	68 7f 25 80 00       	push   $0x80257f
  800bf1:	6a 23                	push   $0x23
  800bf3:	68 9c 25 80 00       	push   $0x80259c
  800bf8:	e8 4b f5 ff ff       	call   800148 <_panic>

00800bfd <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bfd:	55                   	push   %ebp
  800bfe:	89 e5                	mov    %esp,%ebp
  800c00:	57                   	push   %edi
  800c01:	56                   	push   %esi
  800c02:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c03:	ba 00 00 00 00       	mov    $0x0,%edx
  800c08:	b8 02 00 00 00       	mov    $0x2,%eax
  800c0d:	89 d1                	mov    %edx,%ecx
  800c0f:	89 d3                	mov    %edx,%ebx
  800c11:	89 d7                	mov    %edx,%edi
  800c13:	89 d6                	mov    %edx,%esi
  800c15:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c17:	5b                   	pop    %ebx
  800c18:	5e                   	pop    %esi
  800c19:	5f                   	pop    %edi
  800c1a:	5d                   	pop    %ebp
  800c1b:	c3                   	ret    

00800c1c <sys_yield>:

void
sys_yield(void)
{
  800c1c:	55                   	push   %ebp
  800c1d:	89 e5                	mov    %esp,%ebp
  800c1f:	57                   	push   %edi
  800c20:	56                   	push   %esi
  800c21:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c22:	ba 00 00 00 00       	mov    $0x0,%edx
  800c27:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c2c:	89 d1                	mov    %edx,%ecx
  800c2e:	89 d3                	mov    %edx,%ebx
  800c30:	89 d7                	mov    %edx,%edi
  800c32:	89 d6                	mov    %edx,%esi
  800c34:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c36:	5b                   	pop    %ebx
  800c37:	5e                   	pop    %esi
  800c38:	5f                   	pop    %edi
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    

00800c3b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	57                   	push   %edi
  800c3f:	56                   	push   %esi
  800c40:	53                   	push   %ebx
  800c41:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c44:	be 00 00 00 00       	mov    $0x0,%esi
  800c49:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4f:	b8 04 00 00 00       	mov    $0x4,%eax
  800c54:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c57:	89 f7                	mov    %esi,%edi
  800c59:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c5b:	85 c0                	test   %eax,%eax
  800c5d:	7f 08                	jg     800c67 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c62:	5b                   	pop    %ebx
  800c63:	5e                   	pop    %esi
  800c64:	5f                   	pop    %edi
  800c65:	5d                   	pop    %ebp
  800c66:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c67:	83 ec 0c             	sub    $0xc,%esp
  800c6a:	50                   	push   %eax
  800c6b:	6a 04                	push   $0x4
  800c6d:	68 7f 25 80 00       	push   $0x80257f
  800c72:	6a 23                	push   $0x23
  800c74:	68 9c 25 80 00       	push   $0x80259c
  800c79:	e8 ca f4 ff ff       	call   800148 <_panic>

00800c7e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c7e:	55                   	push   %ebp
  800c7f:	89 e5                	mov    %esp,%ebp
  800c81:	57                   	push   %edi
  800c82:	56                   	push   %esi
  800c83:	53                   	push   %ebx
  800c84:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c87:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8d:	b8 05 00 00 00       	mov    $0x5,%eax
  800c92:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c95:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c98:	8b 75 18             	mov    0x18(%ebp),%esi
  800c9b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c9d:	85 c0                	test   %eax,%eax
  800c9f:	7f 08                	jg     800ca9 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ca1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca4:	5b                   	pop    %ebx
  800ca5:	5e                   	pop    %esi
  800ca6:	5f                   	pop    %edi
  800ca7:	5d                   	pop    %ebp
  800ca8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca9:	83 ec 0c             	sub    $0xc,%esp
  800cac:	50                   	push   %eax
  800cad:	6a 05                	push   $0x5
  800caf:	68 7f 25 80 00       	push   $0x80257f
  800cb4:	6a 23                	push   $0x23
  800cb6:	68 9c 25 80 00       	push   $0x80259c
  800cbb:	e8 88 f4 ff ff       	call   800148 <_panic>

00800cc0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cc0:	55                   	push   %ebp
  800cc1:	89 e5                	mov    %esp,%ebp
  800cc3:	57                   	push   %edi
  800cc4:	56                   	push   %esi
  800cc5:	53                   	push   %ebx
  800cc6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cc9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cce:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd4:	b8 06 00 00 00       	mov    $0x6,%eax
  800cd9:	89 df                	mov    %ebx,%edi
  800cdb:	89 de                	mov    %ebx,%esi
  800cdd:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cdf:	85 c0                	test   %eax,%eax
  800ce1:	7f 08                	jg     800ceb <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ce3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce6:	5b                   	pop    %ebx
  800ce7:	5e                   	pop    %esi
  800ce8:	5f                   	pop    %edi
  800ce9:	5d                   	pop    %ebp
  800cea:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ceb:	83 ec 0c             	sub    $0xc,%esp
  800cee:	50                   	push   %eax
  800cef:	6a 06                	push   $0x6
  800cf1:	68 7f 25 80 00       	push   $0x80257f
  800cf6:	6a 23                	push   $0x23
  800cf8:	68 9c 25 80 00       	push   $0x80259c
  800cfd:	e8 46 f4 ff ff       	call   800148 <_panic>

00800d02 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d02:	55                   	push   %ebp
  800d03:	89 e5                	mov    %esp,%ebp
  800d05:	57                   	push   %edi
  800d06:	56                   	push   %esi
  800d07:	53                   	push   %ebx
  800d08:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d0b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d10:	8b 55 08             	mov    0x8(%ebp),%edx
  800d13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d16:	b8 08 00 00 00       	mov    $0x8,%eax
  800d1b:	89 df                	mov    %ebx,%edi
  800d1d:	89 de                	mov    %ebx,%esi
  800d1f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d21:	85 c0                	test   %eax,%eax
  800d23:	7f 08                	jg     800d2d <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d28:	5b                   	pop    %ebx
  800d29:	5e                   	pop    %esi
  800d2a:	5f                   	pop    %edi
  800d2b:	5d                   	pop    %ebp
  800d2c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2d:	83 ec 0c             	sub    $0xc,%esp
  800d30:	50                   	push   %eax
  800d31:	6a 08                	push   $0x8
  800d33:	68 7f 25 80 00       	push   $0x80257f
  800d38:	6a 23                	push   $0x23
  800d3a:	68 9c 25 80 00       	push   $0x80259c
  800d3f:	e8 04 f4 ff ff       	call   800148 <_panic>

00800d44 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d44:	55                   	push   %ebp
  800d45:	89 e5                	mov    %esp,%ebp
  800d47:	57                   	push   %edi
  800d48:	56                   	push   %esi
  800d49:	53                   	push   %ebx
  800d4a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d4d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d52:	8b 55 08             	mov    0x8(%ebp),%edx
  800d55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d58:	b8 09 00 00 00       	mov    $0x9,%eax
  800d5d:	89 df                	mov    %ebx,%edi
  800d5f:	89 de                	mov    %ebx,%esi
  800d61:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d63:	85 c0                	test   %eax,%eax
  800d65:	7f 08                	jg     800d6f <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6a:	5b                   	pop    %ebx
  800d6b:	5e                   	pop    %esi
  800d6c:	5f                   	pop    %edi
  800d6d:	5d                   	pop    %ebp
  800d6e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6f:	83 ec 0c             	sub    $0xc,%esp
  800d72:	50                   	push   %eax
  800d73:	6a 09                	push   $0x9
  800d75:	68 7f 25 80 00       	push   $0x80257f
  800d7a:	6a 23                	push   $0x23
  800d7c:	68 9c 25 80 00       	push   $0x80259c
  800d81:	e8 c2 f3 ff ff       	call   800148 <_panic>

00800d86 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d86:	55                   	push   %ebp
  800d87:	89 e5                	mov    %esp,%ebp
  800d89:	57                   	push   %edi
  800d8a:	56                   	push   %esi
  800d8b:	53                   	push   %ebx
  800d8c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d8f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d94:	8b 55 08             	mov    0x8(%ebp),%edx
  800d97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d9f:	89 df                	mov    %ebx,%edi
  800da1:	89 de                	mov    %ebx,%esi
  800da3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800da5:	85 c0                	test   %eax,%eax
  800da7:	7f 08                	jg     800db1 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800da9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dac:	5b                   	pop    %ebx
  800dad:	5e                   	pop    %esi
  800dae:	5f                   	pop    %edi
  800daf:	5d                   	pop    %ebp
  800db0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800db1:	83 ec 0c             	sub    $0xc,%esp
  800db4:	50                   	push   %eax
  800db5:	6a 0a                	push   $0xa
  800db7:	68 7f 25 80 00       	push   $0x80257f
  800dbc:	6a 23                	push   $0x23
  800dbe:	68 9c 25 80 00       	push   $0x80259c
  800dc3:	e8 80 f3 ff ff       	call   800148 <_panic>

00800dc8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	57                   	push   %edi
  800dcc:	56                   	push   %esi
  800dcd:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dce:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dd9:	be 00 00 00 00       	mov    $0x0,%esi
  800dde:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800de1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800de4:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800de6:	5b                   	pop    %ebx
  800de7:	5e                   	pop    %esi
  800de8:	5f                   	pop    %edi
  800de9:	5d                   	pop    %ebp
  800dea:	c3                   	ret    

00800deb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800deb:	55                   	push   %ebp
  800dec:	89 e5                	mov    %esp,%ebp
  800dee:	57                   	push   %edi
  800def:	56                   	push   %esi
  800df0:	53                   	push   %ebx
  800df1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800df4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800df9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfc:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e01:	89 cb                	mov    %ecx,%ebx
  800e03:	89 cf                	mov    %ecx,%edi
  800e05:	89 ce                	mov    %ecx,%esi
  800e07:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e09:	85 c0                	test   %eax,%eax
  800e0b:	7f 08                	jg     800e15 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e10:	5b                   	pop    %ebx
  800e11:	5e                   	pop    %esi
  800e12:	5f                   	pop    %edi
  800e13:	5d                   	pop    %ebp
  800e14:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e15:	83 ec 0c             	sub    $0xc,%esp
  800e18:	50                   	push   %eax
  800e19:	6a 0d                	push   $0xd
  800e1b:	68 7f 25 80 00       	push   $0x80257f
  800e20:	6a 23                	push   $0x23
  800e22:	68 9c 25 80 00       	push   $0x80259c
  800e27:	e8 1c f3 ff ff       	call   800148 <_panic>

00800e2c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e2c:	55                   	push   %ebp
  800e2d:	89 e5                	mov    %esp,%ebp
  800e2f:	56                   	push   %esi
  800e30:	53                   	push   %ebx
  800e31:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e34:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if((err&FEC_WR)==0 || (uvpt[PGNUM(addr)]&(PTE_W|PTE_COW))==0){
  800e36:	8b 40 04             	mov    0x4(%eax),%eax
  800e39:	83 e0 02             	and    $0x2,%eax
  800e3c:	0f 84 82 00 00 00    	je     800ec4 <pgfault+0x98>
  800e42:	89 da                	mov    %ebx,%edx
  800e44:	c1 ea 0c             	shr    $0xc,%edx
  800e47:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e4e:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800e54:	74 6e                	je     800ec4 <pgfault+0x98>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        envid_t envid = sys_getenvid();
  800e56:	e8 a2 fd ff ff       	call   800bfd <sys_getenvid>
  800e5b:	89 c6                	mov    %eax,%esi
	r = sys_page_alloc(envid,(void *)PFTEMP,PTE_P|PTE_W|PTE_U);
  800e5d:	83 ec 04             	sub    $0x4,%esp
  800e60:	6a 07                	push   $0x7
  800e62:	68 00 f0 7f 00       	push   $0x7ff000
  800e67:	50                   	push   %eax
  800e68:	e8 ce fd ff ff       	call   800c3b <sys_page_alloc>
	if(r<0) panic("pgfault:page allocation failed %e",r);
  800e6d:	83 c4 10             	add    $0x10,%esp
  800e70:	85 c0                	test   %eax,%eax
  800e72:	78 72                	js     800ee6 <pgfault+0xba>

	addr = ROUNDDOWN(addr,PGSIZE);
  800e74:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy((void *)PFTEMP,(const void *)addr,PGSIZE);
  800e7a:	83 ec 04             	sub    $0x4,%esp
  800e7d:	68 00 10 00 00       	push   $0x1000
  800e82:	53                   	push   %ebx
  800e83:	68 00 f0 7f 00       	push   $0x7ff000
  800e88:	e8 ab fb ff ff       	call   800a38 <memcpy>

	if(sys_page_map(envid,(void *)PFTEMP, envid,addr,PTE_P|PTE_W|PTE_U)<0)
  800e8d:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e94:	53                   	push   %ebx
  800e95:	56                   	push   %esi
  800e96:	68 00 f0 7f 00       	push   $0x7ff000
  800e9b:	56                   	push   %esi
  800e9c:	e8 dd fd ff ff       	call   800c7e <sys_page_map>
  800ea1:	83 c4 20             	add    $0x20,%esp
  800ea4:	85 c0                	test   %eax,%eax
  800ea6:	78 50                	js     800ef8 <pgfault+0xcc>
		panic("pgfault:page map failed\n");
	if(sys_page_unmap(envid,(void *)PFTEMP)<0)
  800ea8:	83 ec 08             	sub    $0x8,%esp
  800eab:	68 00 f0 7f 00       	push   $0x7ff000
  800eb0:	56                   	push   %esi
  800eb1:	e8 0a fe ff ff       	call   800cc0 <sys_page_unmap>
  800eb6:	83 c4 10             	add    $0x10,%esp
  800eb9:	85 c0                	test   %eax,%eax
  800ebb:	78 4f                	js     800f0c <pgfault+0xe0>
		panic("pgfault: page upmap failed\n");
       //	panic("pgfault not implemented");
}
  800ebd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ec0:	5b                   	pop    %ebx
  800ec1:	5e                   	pop    %esi
  800ec2:	5d                   	pop    %ebp
  800ec3:	c3                   	ret    
		cprintf("Where is the error %d\n",err&FEC_WR);
  800ec4:	83 ec 08             	sub    $0x8,%esp
  800ec7:	50                   	push   %eax
  800ec8:	68 aa 25 80 00       	push   $0x8025aa
  800ecd:	e8 51 f3 ff ff       	call   800223 <cprintf>
		panic("pgfault:invalid user trap");
  800ed2:	83 c4 0c             	add    $0xc,%esp
  800ed5:	68 c1 25 80 00       	push   $0x8025c1
  800eda:	6a 1e                	push   $0x1e
  800edc:	68 db 25 80 00       	push   $0x8025db
  800ee1:	e8 62 f2 ff ff       	call   800148 <_panic>
	if(r<0) panic("pgfault:page allocation failed %e",r);
  800ee6:	50                   	push   %eax
  800ee7:	68 c8 26 80 00       	push   $0x8026c8
  800eec:	6a 29                	push   $0x29
  800eee:	68 db 25 80 00       	push   $0x8025db
  800ef3:	e8 50 f2 ff ff       	call   800148 <_panic>
		panic("pgfault:page map failed\n");
  800ef8:	83 ec 04             	sub    $0x4,%esp
  800efb:	68 e6 25 80 00       	push   $0x8025e6
  800f00:	6a 2f                	push   $0x2f
  800f02:	68 db 25 80 00       	push   $0x8025db
  800f07:	e8 3c f2 ff ff       	call   800148 <_panic>
		panic("pgfault: page upmap failed\n");
  800f0c:	83 ec 04             	sub    $0x4,%esp
  800f0f:	68 ff 25 80 00       	push   $0x8025ff
  800f14:	6a 31                	push   $0x31
  800f16:	68 db 25 80 00       	push   $0x8025db
  800f1b:	e8 28 f2 ff ff       	call   800148 <_panic>

00800f20 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f20:	55                   	push   %ebp
  800f21:	89 e5                	mov    %esp,%ebp
  800f23:	57                   	push   %edi
  800f24:	56                   	push   %esi
  800f25:	53                   	push   %ebx
  800f26:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	set_pgfault_handler(pgfault);
  800f29:	68 2c 0e 80 00       	push   $0x800e2c
  800f2e:	e8 b5 0e 00 00       	call   801de8 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f33:	b8 07 00 00 00       	mov    $0x7,%eax
  800f38:	cd 30                	int    $0x30
  800f3a:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800f3d:	89 45 e0             	mov    %eax,-0x20(%ebp)
       
	envid_t envid = sys_exofork();
	uintptr_t addr;
  
	if(envid<0) panic("sys_exofork failed\n");
  800f40:	83 c4 10             	add    $0x10,%esp
  800f43:	85 c0                	test   %eax,%eax
  800f45:	78 27                	js     800f6e <fork+0x4e>
	if(envid==0){
	  thisenv = &envs[ENVX(sys_getenvid())];
	  return 0;
	}

	for(addr=(uintptr_t)UTEXT; addr<USTACKTOP;addr+=PGSIZE){
  800f47:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if(envid==0){
  800f4c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800f50:	75 5e                	jne    800fb0 <fork+0x90>
	  thisenv = &envs[ENVX(sys_getenvid())];
  800f52:	e8 a6 fc ff ff       	call   800bfd <sys_getenvid>
  800f57:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f5c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f5f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f64:	a3 08 40 80 00       	mov    %eax,0x804008
	  return 0;
  800f69:	e9 fc 00 00 00       	jmp    80106a <fork+0x14a>
	if(envid<0) panic("sys_exofork failed\n");
  800f6e:	83 ec 04             	sub    $0x4,%esp
  800f71:	68 1b 26 80 00       	push   $0x80261b
  800f76:	6a 77                	push   $0x77
  800f78:	68 db 25 80 00       	push   $0x8025db
  800f7d:	e8 c6 f1 ff ff       	call   800148 <_panic>
          if((r=sys_page_map(parent_envid,va,envid,va,uvpt[pn]&PTE_SYSCALL))<0)
  800f82:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f89:	83 ec 0c             	sub    $0xc,%esp
  800f8c:	25 07 0e 00 00       	and    $0xe07,%eax
  800f91:	50                   	push   %eax
  800f92:	57                   	push   %edi
  800f93:	ff 75 e0             	pushl  -0x20(%ebp)
  800f96:	57                   	push   %edi
  800f97:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f9a:	e8 df fc ff ff       	call   800c7e <sys_page_map>
  800f9f:	83 c4 20             	add    $0x20,%esp
	for(addr=(uintptr_t)UTEXT; addr<USTACKTOP;addr+=PGSIZE){
  800fa2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fa8:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800fae:	74 76                	je     801026 <fork+0x106>
	   if((uvpd[PDX(addr)]&PTE_P) && uvpt[PGNUM(addr)] & PTE_P)
  800fb0:	89 d8                	mov    %ebx,%eax
  800fb2:	c1 e8 16             	shr    $0x16,%eax
  800fb5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fbc:	a8 01                	test   $0x1,%al
  800fbe:	74 e2                	je     800fa2 <fork+0x82>
  800fc0:	89 de                	mov    %ebx,%esi
  800fc2:	c1 ee 0c             	shr    $0xc,%esi
  800fc5:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fcc:	a8 01                	test   $0x1,%al
  800fce:	74 d2                	je     800fa2 <fork+0x82>
        envid_t parent_envid = sys_getenvid();
  800fd0:	e8 28 fc ff ff       	call   800bfd <sys_getenvid>
  800fd5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	void *va = (void *)(pn*PGSIZE);
  800fd8:	89 f7                	mov    %esi,%edi
  800fda:	c1 e7 0c             	shl    $0xc,%edi
        if(uvpt[pn] & PTE_SHARE){
  800fdd:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fe4:	f6 c4 04             	test   $0x4,%ah
  800fe7:	75 99                	jne    800f82 <fork+0x62>
	if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)){
  800fe9:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800ff0:	a8 02                	test   $0x2,%al
  800ff2:	0f 85 ed 00 00 00    	jne    8010e5 <fork+0x1c5>
  800ff8:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fff:	f6 c4 08             	test   $0x8,%ah
  801002:	0f 85 dd 00 00 00    	jne    8010e5 <fork+0x1c5>
	 if((r=sys_page_map(parent_envid,va,envid,va,perm))<0)
  801008:	83 ec 0c             	sub    $0xc,%esp
  80100b:	6a 05                	push   $0x5
  80100d:	57                   	push   %edi
  80100e:	ff 75 e0             	pushl  -0x20(%ebp)
  801011:	57                   	push   %edi
  801012:	ff 75 e4             	pushl  -0x1c(%ebp)
  801015:	e8 64 fc ff ff       	call   800c7e <sys_page_map>
  80101a:	83 c4 20             	add    $0x20,%esp
  80101d:	85 c0                	test   %eax,%eax
  80101f:	79 81                	jns    800fa2 <fork+0x82>
  801021:	e9 db 00 00 00       	jmp    801101 <fork+0x1e1>
		   duppage(envid,PGNUM(addr));
	}
        
	int r;
	if((r=sys_page_alloc(envid,(void *)UXSTACKTOP-PGSIZE,PTE_U|PTE_P|PTE_W))<0)
  801026:	83 ec 04             	sub    $0x4,%esp
  801029:	6a 07                	push   $0x7
  80102b:	68 00 f0 bf ee       	push   $0xeebff000
  801030:	ff 75 dc             	pushl  -0x24(%ebp)
  801033:	e8 03 fc ff ff       	call   800c3b <sys_page_alloc>
  801038:	83 c4 10             	add    $0x10,%esp
  80103b:	85 c0                	test   %eax,%eax
  80103d:	78 36                	js     801075 <fork+0x155>
		panic("fork:page alloc failed %e\n",r);

	extern void _pgfault_upcall();
	if((r = sys_env_set_pgfault_upcall(envid,_pgfault_upcall)))
  80103f:	83 ec 08             	sub    $0x8,%esp
  801042:	68 4d 1e 80 00       	push   $0x801e4d
  801047:	ff 75 dc             	pushl  -0x24(%ebp)
  80104a:	e8 37 fd ff ff       	call   800d86 <sys_env_set_pgfault_upcall>
  80104f:	83 c4 10             	add    $0x10,%esp
  801052:	85 c0                	test   %eax,%eax
  801054:	75 34                	jne    80108a <fork+0x16a>
		panic("fork:set upcall failed %e\n",r);
	if((r = sys_env_set_status(envid,ENV_RUNNABLE))<0)
  801056:	83 ec 08             	sub    $0x8,%esp
  801059:	6a 02                	push   $0x2
  80105b:	ff 75 dc             	pushl  -0x24(%ebp)
  80105e:	e8 9f fc ff ff       	call   800d02 <sys_env_set_status>
  801063:	83 c4 10             	add    $0x10,%esp
  801066:	85 c0                	test   %eax,%eax
  801068:	78 35                	js     80109f <fork+0x17f>
		panic("fork:set status failed %e\n",r);
	//cprintf("forkid= %d\n", envid);
	return envid;
       	
}
  80106a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80106d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801070:	5b                   	pop    %ebx
  801071:	5e                   	pop    %esi
  801072:	5f                   	pop    %edi
  801073:	5d                   	pop    %ebp
  801074:	c3                   	ret    
		panic("fork:page alloc failed %e\n",r);
  801075:	50                   	push   %eax
  801076:	68 5f 26 80 00       	push   $0x80265f
  80107b:	68 84 00 00 00       	push   $0x84
  801080:	68 db 25 80 00       	push   $0x8025db
  801085:	e8 be f0 ff ff       	call   800148 <_panic>
		panic("fork:set upcall failed %e\n",r);
  80108a:	50                   	push   %eax
  80108b:	68 7a 26 80 00       	push   $0x80267a
  801090:	68 88 00 00 00       	push   $0x88
  801095:	68 db 25 80 00       	push   $0x8025db
  80109a:	e8 a9 f0 ff ff       	call   800148 <_panic>
		panic("fork:set status failed %e\n",r);
  80109f:	50                   	push   %eax
  8010a0:	68 95 26 80 00       	push   $0x802695
  8010a5:	68 8a 00 00 00       	push   $0x8a
  8010aa:	68 db 25 80 00       	push   $0x8025db
  8010af:	e8 94 f0 ff ff       	call   800148 <_panic>
		if( (r=sys_page_map(parent_envid,va,parent_envid,va,perm))<0){
  8010b4:	83 ec 0c             	sub    $0xc,%esp
  8010b7:	68 05 08 00 00       	push   $0x805
  8010bc:	57                   	push   %edi
  8010bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010c0:	50                   	push   %eax
  8010c1:	57                   	push   %edi
  8010c2:	50                   	push   %eax
  8010c3:	e8 b6 fb ff ff       	call   800c7e <sys_page_map>
  8010c8:	83 c4 20             	add    $0x20,%esp
  8010cb:	85 c0                	test   %eax,%eax
  8010cd:	0f 89 cf fe ff ff    	jns    800fa2 <fork+0x82>
		 panic("duppage:map02 failed %e",r);
  8010d3:	50                   	push   %eax
  8010d4:	68 47 26 80 00       	push   $0x802647
  8010d9:	6a 56                	push   $0x56
  8010db:	68 db 25 80 00       	push   $0x8025db
  8010e0:	e8 63 f0 ff ff       	call   800148 <_panic>
	 if((r=sys_page_map(parent_envid,va,envid,va,perm))<0)
  8010e5:	83 ec 0c             	sub    $0xc,%esp
  8010e8:	68 05 08 00 00       	push   $0x805
  8010ed:	57                   	push   %edi
  8010ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8010f1:	57                   	push   %edi
  8010f2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010f5:	e8 84 fb ff ff       	call   800c7e <sys_page_map>
  8010fa:	83 c4 20             	add    $0x20,%esp
  8010fd:	85 c0                	test   %eax,%eax
  8010ff:	79 b3                	jns    8010b4 <fork+0x194>
		 panic("duppage:map01 failed %e",r);
  801101:	50                   	push   %eax
  801102:	68 2f 26 80 00       	push   $0x80262f
  801107:	6a 53                	push   $0x53
  801109:	68 db 25 80 00       	push   $0x8025db
  80110e:	e8 35 f0 ff ff       	call   800148 <_panic>

00801113 <sfork>:

// Challenge!
int
sfork(void)
{
  801113:	55                   	push   %ebp
  801114:	89 e5                	mov    %esp,%ebp
  801116:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801119:	68 b0 26 80 00       	push   $0x8026b0
  80111e:	68 94 00 00 00       	push   $0x94
  801123:	68 db 25 80 00       	push   $0x8025db
  801128:	e8 1b f0 ff ff       	call   800148 <_panic>

0080112d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80112d:	55                   	push   %ebp
  80112e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801130:	8b 45 08             	mov    0x8(%ebp),%eax
  801133:	05 00 00 00 30       	add    $0x30000000,%eax
  801138:	c1 e8 0c             	shr    $0xc,%eax
}
  80113b:	5d                   	pop    %ebp
  80113c:	c3                   	ret    

0080113d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80113d:	55                   	push   %ebp
  80113e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801140:	8b 45 08             	mov    0x8(%ebp),%eax
  801143:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801148:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80114d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801152:	5d                   	pop    %ebp
  801153:	c3                   	ret    

00801154 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801154:	55                   	push   %ebp
  801155:	89 e5                	mov    %esp,%ebp
  801157:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80115a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80115f:	89 c2                	mov    %eax,%edx
  801161:	c1 ea 16             	shr    $0x16,%edx
  801164:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80116b:	f6 c2 01             	test   $0x1,%dl
  80116e:	74 2a                	je     80119a <fd_alloc+0x46>
  801170:	89 c2                	mov    %eax,%edx
  801172:	c1 ea 0c             	shr    $0xc,%edx
  801175:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80117c:	f6 c2 01             	test   $0x1,%dl
  80117f:	74 19                	je     80119a <fd_alloc+0x46>
  801181:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801186:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80118b:	75 d2                	jne    80115f <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80118d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801193:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801198:	eb 07                	jmp    8011a1 <fd_alloc+0x4d>
			*fd_store = fd;
  80119a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80119c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011a1:	5d                   	pop    %ebp
  8011a2:	c3                   	ret    

008011a3 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011a3:	55                   	push   %ebp
  8011a4:	89 e5                	mov    %esp,%ebp
  8011a6:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011a9:	83 f8 1f             	cmp    $0x1f,%eax
  8011ac:	77 36                	ja     8011e4 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011ae:	c1 e0 0c             	shl    $0xc,%eax
  8011b1:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011b6:	89 c2                	mov    %eax,%edx
  8011b8:	c1 ea 16             	shr    $0x16,%edx
  8011bb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011c2:	f6 c2 01             	test   $0x1,%dl
  8011c5:	74 24                	je     8011eb <fd_lookup+0x48>
  8011c7:	89 c2                	mov    %eax,%edx
  8011c9:	c1 ea 0c             	shr    $0xc,%edx
  8011cc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011d3:	f6 c2 01             	test   $0x1,%dl
  8011d6:	74 1a                	je     8011f2 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011db:	89 02                	mov    %eax,(%edx)
	return 0;
  8011dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011e2:	5d                   	pop    %ebp
  8011e3:	c3                   	ret    
		return -E_INVAL;
  8011e4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011e9:	eb f7                	jmp    8011e2 <fd_lookup+0x3f>
		return -E_INVAL;
  8011eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011f0:	eb f0                	jmp    8011e2 <fd_lookup+0x3f>
  8011f2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011f7:	eb e9                	jmp    8011e2 <fd_lookup+0x3f>

008011f9 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011f9:	55                   	push   %ebp
  8011fa:	89 e5                	mov    %esp,%ebp
  8011fc:	83 ec 08             	sub    $0x8,%esp
  8011ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801202:	ba 6c 27 80 00       	mov    $0x80276c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801207:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  80120c:	39 08                	cmp    %ecx,(%eax)
  80120e:	74 33                	je     801243 <dev_lookup+0x4a>
  801210:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  801213:	8b 02                	mov    (%edx),%eax
  801215:	85 c0                	test   %eax,%eax
  801217:	75 f3                	jne    80120c <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801219:	a1 08 40 80 00       	mov    0x804008,%eax
  80121e:	8b 40 48             	mov    0x48(%eax),%eax
  801221:	83 ec 04             	sub    $0x4,%esp
  801224:	51                   	push   %ecx
  801225:	50                   	push   %eax
  801226:	68 ec 26 80 00       	push   $0x8026ec
  80122b:	e8 f3 ef ff ff       	call   800223 <cprintf>
	*dev = 0;
  801230:	8b 45 0c             	mov    0xc(%ebp),%eax
  801233:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801239:	83 c4 10             	add    $0x10,%esp
  80123c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801241:	c9                   	leave  
  801242:	c3                   	ret    
			*dev = devtab[i];
  801243:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801246:	89 01                	mov    %eax,(%ecx)
			return 0;
  801248:	b8 00 00 00 00       	mov    $0x0,%eax
  80124d:	eb f2                	jmp    801241 <dev_lookup+0x48>

0080124f <fd_close>:
{
  80124f:	55                   	push   %ebp
  801250:	89 e5                	mov    %esp,%ebp
  801252:	57                   	push   %edi
  801253:	56                   	push   %esi
  801254:	53                   	push   %ebx
  801255:	83 ec 1c             	sub    $0x1c,%esp
  801258:	8b 75 08             	mov    0x8(%ebp),%esi
  80125b:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80125e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801261:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801262:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801268:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80126b:	50                   	push   %eax
  80126c:	e8 32 ff ff ff       	call   8011a3 <fd_lookup>
  801271:	89 c3                	mov    %eax,%ebx
  801273:	83 c4 08             	add    $0x8,%esp
  801276:	85 c0                	test   %eax,%eax
  801278:	78 05                	js     80127f <fd_close+0x30>
	    || fd != fd2)
  80127a:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80127d:	74 16                	je     801295 <fd_close+0x46>
		return (must_exist ? r : 0);
  80127f:	89 f8                	mov    %edi,%eax
  801281:	84 c0                	test   %al,%al
  801283:	b8 00 00 00 00       	mov    $0x0,%eax
  801288:	0f 44 d8             	cmove  %eax,%ebx
}
  80128b:	89 d8                	mov    %ebx,%eax
  80128d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801290:	5b                   	pop    %ebx
  801291:	5e                   	pop    %esi
  801292:	5f                   	pop    %edi
  801293:	5d                   	pop    %ebp
  801294:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801295:	83 ec 08             	sub    $0x8,%esp
  801298:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80129b:	50                   	push   %eax
  80129c:	ff 36                	pushl  (%esi)
  80129e:	e8 56 ff ff ff       	call   8011f9 <dev_lookup>
  8012a3:	89 c3                	mov    %eax,%ebx
  8012a5:	83 c4 10             	add    $0x10,%esp
  8012a8:	85 c0                	test   %eax,%eax
  8012aa:	78 15                	js     8012c1 <fd_close+0x72>
		if (dev->dev_close)
  8012ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012af:	8b 40 10             	mov    0x10(%eax),%eax
  8012b2:	85 c0                	test   %eax,%eax
  8012b4:	74 1b                	je     8012d1 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  8012b6:	83 ec 0c             	sub    $0xc,%esp
  8012b9:	56                   	push   %esi
  8012ba:	ff d0                	call   *%eax
  8012bc:	89 c3                	mov    %eax,%ebx
  8012be:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8012c1:	83 ec 08             	sub    $0x8,%esp
  8012c4:	56                   	push   %esi
  8012c5:	6a 00                	push   $0x0
  8012c7:	e8 f4 f9 ff ff       	call   800cc0 <sys_page_unmap>
	return r;
  8012cc:	83 c4 10             	add    $0x10,%esp
  8012cf:	eb ba                	jmp    80128b <fd_close+0x3c>
			r = 0;
  8012d1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012d6:	eb e9                	jmp    8012c1 <fd_close+0x72>

008012d8 <close>:

int
close(int fdnum)
{
  8012d8:	55                   	push   %ebp
  8012d9:	89 e5                	mov    %esp,%ebp
  8012db:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e1:	50                   	push   %eax
  8012e2:	ff 75 08             	pushl  0x8(%ebp)
  8012e5:	e8 b9 fe ff ff       	call   8011a3 <fd_lookup>
  8012ea:	83 c4 08             	add    $0x8,%esp
  8012ed:	85 c0                	test   %eax,%eax
  8012ef:	78 10                	js     801301 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012f1:	83 ec 08             	sub    $0x8,%esp
  8012f4:	6a 01                	push   $0x1
  8012f6:	ff 75 f4             	pushl  -0xc(%ebp)
  8012f9:	e8 51 ff ff ff       	call   80124f <fd_close>
  8012fe:	83 c4 10             	add    $0x10,%esp
}
  801301:	c9                   	leave  
  801302:	c3                   	ret    

00801303 <close_all>:

void
close_all(void)
{
  801303:	55                   	push   %ebp
  801304:	89 e5                	mov    %esp,%ebp
  801306:	53                   	push   %ebx
  801307:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80130a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80130f:	83 ec 0c             	sub    $0xc,%esp
  801312:	53                   	push   %ebx
  801313:	e8 c0 ff ff ff       	call   8012d8 <close>
	for (i = 0; i < MAXFD; i++)
  801318:	83 c3 01             	add    $0x1,%ebx
  80131b:	83 c4 10             	add    $0x10,%esp
  80131e:	83 fb 20             	cmp    $0x20,%ebx
  801321:	75 ec                	jne    80130f <close_all+0xc>
}
  801323:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801326:	c9                   	leave  
  801327:	c3                   	ret    

00801328 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801328:	55                   	push   %ebp
  801329:	89 e5                	mov    %esp,%ebp
  80132b:	57                   	push   %edi
  80132c:	56                   	push   %esi
  80132d:	53                   	push   %ebx
  80132e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801331:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801334:	50                   	push   %eax
  801335:	ff 75 08             	pushl  0x8(%ebp)
  801338:	e8 66 fe ff ff       	call   8011a3 <fd_lookup>
  80133d:	89 c3                	mov    %eax,%ebx
  80133f:	83 c4 08             	add    $0x8,%esp
  801342:	85 c0                	test   %eax,%eax
  801344:	0f 88 81 00 00 00    	js     8013cb <dup+0xa3>
		return r;
	close(newfdnum);
  80134a:	83 ec 0c             	sub    $0xc,%esp
  80134d:	ff 75 0c             	pushl  0xc(%ebp)
  801350:	e8 83 ff ff ff       	call   8012d8 <close>

	newfd = INDEX2FD(newfdnum);
  801355:	8b 75 0c             	mov    0xc(%ebp),%esi
  801358:	c1 e6 0c             	shl    $0xc,%esi
  80135b:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801361:	83 c4 04             	add    $0x4,%esp
  801364:	ff 75 e4             	pushl  -0x1c(%ebp)
  801367:	e8 d1 fd ff ff       	call   80113d <fd2data>
  80136c:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80136e:	89 34 24             	mov    %esi,(%esp)
  801371:	e8 c7 fd ff ff       	call   80113d <fd2data>
  801376:	83 c4 10             	add    $0x10,%esp
  801379:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80137b:	89 d8                	mov    %ebx,%eax
  80137d:	c1 e8 16             	shr    $0x16,%eax
  801380:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801387:	a8 01                	test   $0x1,%al
  801389:	74 11                	je     80139c <dup+0x74>
  80138b:	89 d8                	mov    %ebx,%eax
  80138d:	c1 e8 0c             	shr    $0xc,%eax
  801390:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801397:	f6 c2 01             	test   $0x1,%dl
  80139a:	75 39                	jne    8013d5 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80139c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80139f:	89 d0                	mov    %edx,%eax
  8013a1:	c1 e8 0c             	shr    $0xc,%eax
  8013a4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013ab:	83 ec 0c             	sub    $0xc,%esp
  8013ae:	25 07 0e 00 00       	and    $0xe07,%eax
  8013b3:	50                   	push   %eax
  8013b4:	56                   	push   %esi
  8013b5:	6a 00                	push   $0x0
  8013b7:	52                   	push   %edx
  8013b8:	6a 00                	push   $0x0
  8013ba:	e8 bf f8 ff ff       	call   800c7e <sys_page_map>
  8013bf:	89 c3                	mov    %eax,%ebx
  8013c1:	83 c4 20             	add    $0x20,%esp
  8013c4:	85 c0                	test   %eax,%eax
  8013c6:	78 31                	js     8013f9 <dup+0xd1>
		goto err;

	return newfdnum;
  8013c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8013cb:	89 d8                	mov    %ebx,%eax
  8013cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013d0:	5b                   	pop    %ebx
  8013d1:	5e                   	pop    %esi
  8013d2:	5f                   	pop    %edi
  8013d3:	5d                   	pop    %ebp
  8013d4:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013d5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013dc:	83 ec 0c             	sub    $0xc,%esp
  8013df:	25 07 0e 00 00       	and    $0xe07,%eax
  8013e4:	50                   	push   %eax
  8013e5:	57                   	push   %edi
  8013e6:	6a 00                	push   $0x0
  8013e8:	53                   	push   %ebx
  8013e9:	6a 00                	push   $0x0
  8013eb:	e8 8e f8 ff ff       	call   800c7e <sys_page_map>
  8013f0:	89 c3                	mov    %eax,%ebx
  8013f2:	83 c4 20             	add    $0x20,%esp
  8013f5:	85 c0                	test   %eax,%eax
  8013f7:	79 a3                	jns    80139c <dup+0x74>
	sys_page_unmap(0, newfd);
  8013f9:	83 ec 08             	sub    $0x8,%esp
  8013fc:	56                   	push   %esi
  8013fd:	6a 00                	push   $0x0
  8013ff:	e8 bc f8 ff ff       	call   800cc0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801404:	83 c4 08             	add    $0x8,%esp
  801407:	57                   	push   %edi
  801408:	6a 00                	push   $0x0
  80140a:	e8 b1 f8 ff ff       	call   800cc0 <sys_page_unmap>
	return r;
  80140f:	83 c4 10             	add    $0x10,%esp
  801412:	eb b7                	jmp    8013cb <dup+0xa3>

00801414 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801414:	55                   	push   %ebp
  801415:	89 e5                	mov    %esp,%ebp
  801417:	53                   	push   %ebx
  801418:	83 ec 14             	sub    $0x14,%esp
  80141b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80141e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801421:	50                   	push   %eax
  801422:	53                   	push   %ebx
  801423:	e8 7b fd ff ff       	call   8011a3 <fd_lookup>
  801428:	83 c4 08             	add    $0x8,%esp
  80142b:	85 c0                	test   %eax,%eax
  80142d:	78 3f                	js     80146e <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80142f:	83 ec 08             	sub    $0x8,%esp
  801432:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801435:	50                   	push   %eax
  801436:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801439:	ff 30                	pushl  (%eax)
  80143b:	e8 b9 fd ff ff       	call   8011f9 <dev_lookup>
  801440:	83 c4 10             	add    $0x10,%esp
  801443:	85 c0                	test   %eax,%eax
  801445:	78 27                	js     80146e <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801447:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80144a:	8b 42 08             	mov    0x8(%edx),%eax
  80144d:	83 e0 03             	and    $0x3,%eax
  801450:	83 f8 01             	cmp    $0x1,%eax
  801453:	74 1e                	je     801473 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801455:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801458:	8b 40 08             	mov    0x8(%eax),%eax
  80145b:	85 c0                	test   %eax,%eax
  80145d:	74 35                	je     801494 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80145f:	83 ec 04             	sub    $0x4,%esp
  801462:	ff 75 10             	pushl  0x10(%ebp)
  801465:	ff 75 0c             	pushl  0xc(%ebp)
  801468:	52                   	push   %edx
  801469:	ff d0                	call   *%eax
  80146b:	83 c4 10             	add    $0x10,%esp
}
  80146e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801471:	c9                   	leave  
  801472:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801473:	a1 08 40 80 00       	mov    0x804008,%eax
  801478:	8b 40 48             	mov    0x48(%eax),%eax
  80147b:	83 ec 04             	sub    $0x4,%esp
  80147e:	53                   	push   %ebx
  80147f:	50                   	push   %eax
  801480:	68 30 27 80 00       	push   $0x802730
  801485:	e8 99 ed ff ff       	call   800223 <cprintf>
		return -E_INVAL;
  80148a:	83 c4 10             	add    $0x10,%esp
  80148d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801492:	eb da                	jmp    80146e <read+0x5a>
		return -E_NOT_SUPP;
  801494:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801499:	eb d3                	jmp    80146e <read+0x5a>

0080149b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80149b:	55                   	push   %ebp
  80149c:	89 e5                	mov    %esp,%ebp
  80149e:	57                   	push   %edi
  80149f:	56                   	push   %esi
  8014a0:	53                   	push   %ebx
  8014a1:	83 ec 0c             	sub    $0xc,%esp
  8014a4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014a7:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014aa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014af:	39 f3                	cmp    %esi,%ebx
  8014b1:	73 25                	jae    8014d8 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014b3:	83 ec 04             	sub    $0x4,%esp
  8014b6:	89 f0                	mov    %esi,%eax
  8014b8:	29 d8                	sub    %ebx,%eax
  8014ba:	50                   	push   %eax
  8014bb:	89 d8                	mov    %ebx,%eax
  8014bd:	03 45 0c             	add    0xc(%ebp),%eax
  8014c0:	50                   	push   %eax
  8014c1:	57                   	push   %edi
  8014c2:	e8 4d ff ff ff       	call   801414 <read>
		if (m < 0)
  8014c7:	83 c4 10             	add    $0x10,%esp
  8014ca:	85 c0                	test   %eax,%eax
  8014cc:	78 08                	js     8014d6 <readn+0x3b>
			return m;
		if (m == 0)
  8014ce:	85 c0                	test   %eax,%eax
  8014d0:	74 06                	je     8014d8 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  8014d2:	01 c3                	add    %eax,%ebx
  8014d4:	eb d9                	jmp    8014af <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014d6:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8014d8:	89 d8                	mov    %ebx,%eax
  8014da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014dd:	5b                   	pop    %ebx
  8014de:	5e                   	pop    %esi
  8014df:	5f                   	pop    %edi
  8014e0:	5d                   	pop    %ebp
  8014e1:	c3                   	ret    

008014e2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014e2:	55                   	push   %ebp
  8014e3:	89 e5                	mov    %esp,%ebp
  8014e5:	53                   	push   %ebx
  8014e6:	83 ec 14             	sub    $0x14,%esp
  8014e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014ec:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014ef:	50                   	push   %eax
  8014f0:	53                   	push   %ebx
  8014f1:	e8 ad fc ff ff       	call   8011a3 <fd_lookup>
  8014f6:	83 c4 08             	add    $0x8,%esp
  8014f9:	85 c0                	test   %eax,%eax
  8014fb:	78 3a                	js     801537 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014fd:	83 ec 08             	sub    $0x8,%esp
  801500:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801503:	50                   	push   %eax
  801504:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801507:	ff 30                	pushl  (%eax)
  801509:	e8 eb fc ff ff       	call   8011f9 <dev_lookup>
  80150e:	83 c4 10             	add    $0x10,%esp
  801511:	85 c0                	test   %eax,%eax
  801513:	78 22                	js     801537 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801515:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801518:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80151c:	74 1e                	je     80153c <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80151e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801521:	8b 52 0c             	mov    0xc(%edx),%edx
  801524:	85 d2                	test   %edx,%edx
  801526:	74 35                	je     80155d <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801528:	83 ec 04             	sub    $0x4,%esp
  80152b:	ff 75 10             	pushl  0x10(%ebp)
  80152e:	ff 75 0c             	pushl  0xc(%ebp)
  801531:	50                   	push   %eax
  801532:	ff d2                	call   *%edx
  801534:	83 c4 10             	add    $0x10,%esp
}
  801537:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80153a:	c9                   	leave  
  80153b:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80153c:	a1 08 40 80 00       	mov    0x804008,%eax
  801541:	8b 40 48             	mov    0x48(%eax),%eax
  801544:	83 ec 04             	sub    $0x4,%esp
  801547:	53                   	push   %ebx
  801548:	50                   	push   %eax
  801549:	68 4c 27 80 00       	push   $0x80274c
  80154e:	e8 d0 ec ff ff       	call   800223 <cprintf>
		return -E_INVAL;
  801553:	83 c4 10             	add    $0x10,%esp
  801556:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80155b:	eb da                	jmp    801537 <write+0x55>
		return -E_NOT_SUPP;
  80155d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801562:	eb d3                	jmp    801537 <write+0x55>

00801564 <seek>:

int
seek(int fdnum, off_t offset)
{
  801564:	55                   	push   %ebp
  801565:	89 e5                	mov    %esp,%ebp
  801567:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80156a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80156d:	50                   	push   %eax
  80156e:	ff 75 08             	pushl  0x8(%ebp)
  801571:	e8 2d fc ff ff       	call   8011a3 <fd_lookup>
  801576:	83 c4 08             	add    $0x8,%esp
  801579:	85 c0                	test   %eax,%eax
  80157b:	78 0e                	js     80158b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80157d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801580:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801583:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801586:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80158b:	c9                   	leave  
  80158c:	c3                   	ret    

0080158d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80158d:	55                   	push   %ebp
  80158e:	89 e5                	mov    %esp,%ebp
  801590:	53                   	push   %ebx
  801591:	83 ec 14             	sub    $0x14,%esp
  801594:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801597:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80159a:	50                   	push   %eax
  80159b:	53                   	push   %ebx
  80159c:	e8 02 fc ff ff       	call   8011a3 <fd_lookup>
  8015a1:	83 c4 08             	add    $0x8,%esp
  8015a4:	85 c0                	test   %eax,%eax
  8015a6:	78 37                	js     8015df <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a8:	83 ec 08             	sub    $0x8,%esp
  8015ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ae:	50                   	push   %eax
  8015af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b2:	ff 30                	pushl  (%eax)
  8015b4:	e8 40 fc ff ff       	call   8011f9 <dev_lookup>
  8015b9:	83 c4 10             	add    $0x10,%esp
  8015bc:	85 c0                	test   %eax,%eax
  8015be:	78 1f                	js     8015df <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015c7:	74 1b                	je     8015e4 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8015c9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015cc:	8b 52 18             	mov    0x18(%edx),%edx
  8015cf:	85 d2                	test   %edx,%edx
  8015d1:	74 32                	je     801605 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015d3:	83 ec 08             	sub    $0x8,%esp
  8015d6:	ff 75 0c             	pushl  0xc(%ebp)
  8015d9:	50                   	push   %eax
  8015da:	ff d2                	call   *%edx
  8015dc:	83 c4 10             	add    $0x10,%esp
}
  8015df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015e2:	c9                   	leave  
  8015e3:	c3                   	ret    
			thisenv->env_id, fdnum);
  8015e4:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015e9:	8b 40 48             	mov    0x48(%eax),%eax
  8015ec:	83 ec 04             	sub    $0x4,%esp
  8015ef:	53                   	push   %ebx
  8015f0:	50                   	push   %eax
  8015f1:	68 0c 27 80 00       	push   $0x80270c
  8015f6:	e8 28 ec ff ff       	call   800223 <cprintf>
		return -E_INVAL;
  8015fb:	83 c4 10             	add    $0x10,%esp
  8015fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801603:	eb da                	jmp    8015df <ftruncate+0x52>
		return -E_NOT_SUPP;
  801605:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80160a:	eb d3                	jmp    8015df <ftruncate+0x52>

0080160c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80160c:	55                   	push   %ebp
  80160d:	89 e5                	mov    %esp,%ebp
  80160f:	53                   	push   %ebx
  801610:	83 ec 14             	sub    $0x14,%esp
  801613:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801616:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801619:	50                   	push   %eax
  80161a:	ff 75 08             	pushl  0x8(%ebp)
  80161d:	e8 81 fb ff ff       	call   8011a3 <fd_lookup>
  801622:	83 c4 08             	add    $0x8,%esp
  801625:	85 c0                	test   %eax,%eax
  801627:	78 4b                	js     801674 <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801629:	83 ec 08             	sub    $0x8,%esp
  80162c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80162f:	50                   	push   %eax
  801630:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801633:	ff 30                	pushl  (%eax)
  801635:	e8 bf fb ff ff       	call   8011f9 <dev_lookup>
  80163a:	83 c4 10             	add    $0x10,%esp
  80163d:	85 c0                	test   %eax,%eax
  80163f:	78 33                	js     801674 <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  801641:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801644:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801648:	74 2f                	je     801679 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80164a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80164d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801654:	00 00 00 
	stat->st_isdir = 0;
  801657:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80165e:	00 00 00 
	stat->st_dev = dev;
  801661:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801667:	83 ec 08             	sub    $0x8,%esp
  80166a:	53                   	push   %ebx
  80166b:	ff 75 f0             	pushl  -0x10(%ebp)
  80166e:	ff 50 14             	call   *0x14(%eax)
  801671:	83 c4 10             	add    $0x10,%esp
}
  801674:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801677:	c9                   	leave  
  801678:	c3                   	ret    
		return -E_NOT_SUPP;
  801679:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80167e:	eb f4                	jmp    801674 <fstat+0x68>

00801680 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801680:	55                   	push   %ebp
  801681:	89 e5                	mov    %esp,%ebp
  801683:	56                   	push   %esi
  801684:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801685:	83 ec 08             	sub    $0x8,%esp
  801688:	6a 00                	push   $0x0
  80168a:	ff 75 08             	pushl  0x8(%ebp)
  80168d:	e8 e7 01 00 00       	call   801879 <open>
  801692:	89 c3                	mov    %eax,%ebx
  801694:	83 c4 10             	add    $0x10,%esp
  801697:	85 c0                	test   %eax,%eax
  801699:	78 1b                	js     8016b6 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80169b:	83 ec 08             	sub    $0x8,%esp
  80169e:	ff 75 0c             	pushl  0xc(%ebp)
  8016a1:	50                   	push   %eax
  8016a2:	e8 65 ff ff ff       	call   80160c <fstat>
  8016a7:	89 c6                	mov    %eax,%esi
	close(fd);
  8016a9:	89 1c 24             	mov    %ebx,(%esp)
  8016ac:	e8 27 fc ff ff       	call   8012d8 <close>
	return r;
  8016b1:	83 c4 10             	add    $0x10,%esp
  8016b4:	89 f3                	mov    %esi,%ebx
}
  8016b6:	89 d8                	mov    %ebx,%eax
  8016b8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016bb:	5b                   	pop    %ebx
  8016bc:	5e                   	pop    %esi
  8016bd:	5d                   	pop    %ebp
  8016be:	c3                   	ret    

008016bf <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016bf:	55                   	push   %ebp
  8016c0:	89 e5                	mov    %esp,%ebp
  8016c2:	56                   	push   %esi
  8016c3:	53                   	push   %ebx
  8016c4:	89 c6                	mov    %eax,%esi
  8016c6:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016c8:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016cf:	74 27                	je     8016f8 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016d1:	6a 07                	push   $0x7
  8016d3:	68 00 50 80 00       	push   $0x805000
  8016d8:	56                   	push   %esi
  8016d9:	ff 35 00 40 80 00    	pushl  0x804000
  8016df:	e8 05 08 00 00       	call   801ee9 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016e4:	83 c4 0c             	add    $0xc,%esp
  8016e7:	6a 00                	push   $0x0
  8016e9:	53                   	push   %ebx
  8016ea:	6a 00                	push   $0x0
  8016ec:	e8 83 07 00 00       	call   801e74 <ipc_recv>
}
  8016f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016f4:	5b                   	pop    %ebx
  8016f5:	5e                   	pop    %esi
  8016f6:	5d                   	pop    %ebp
  8016f7:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016f8:	83 ec 0c             	sub    $0xc,%esp
  8016fb:	6a 01                	push   $0x1
  8016fd:	e8 3d 08 00 00       	call   801f3f <ipc_find_env>
  801702:	a3 00 40 80 00       	mov    %eax,0x804000
  801707:	83 c4 10             	add    $0x10,%esp
  80170a:	eb c5                	jmp    8016d1 <fsipc+0x12>

0080170c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80170c:	55                   	push   %ebp
  80170d:	89 e5                	mov    %esp,%ebp
  80170f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801712:	8b 45 08             	mov    0x8(%ebp),%eax
  801715:	8b 40 0c             	mov    0xc(%eax),%eax
  801718:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80171d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801720:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801725:	ba 00 00 00 00       	mov    $0x0,%edx
  80172a:	b8 02 00 00 00       	mov    $0x2,%eax
  80172f:	e8 8b ff ff ff       	call   8016bf <fsipc>
}
  801734:	c9                   	leave  
  801735:	c3                   	ret    

00801736 <devfile_flush>:
{
  801736:	55                   	push   %ebp
  801737:	89 e5                	mov    %esp,%ebp
  801739:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80173c:	8b 45 08             	mov    0x8(%ebp),%eax
  80173f:	8b 40 0c             	mov    0xc(%eax),%eax
  801742:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801747:	ba 00 00 00 00       	mov    $0x0,%edx
  80174c:	b8 06 00 00 00       	mov    $0x6,%eax
  801751:	e8 69 ff ff ff       	call   8016bf <fsipc>
}
  801756:	c9                   	leave  
  801757:	c3                   	ret    

00801758 <devfile_stat>:
{
  801758:	55                   	push   %ebp
  801759:	89 e5                	mov    %esp,%ebp
  80175b:	53                   	push   %ebx
  80175c:	83 ec 04             	sub    $0x4,%esp
  80175f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801762:	8b 45 08             	mov    0x8(%ebp),%eax
  801765:	8b 40 0c             	mov    0xc(%eax),%eax
  801768:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80176d:	ba 00 00 00 00       	mov    $0x0,%edx
  801772:	b8 05 00 00 00       	mov    $0x5,%eax
  801777:	e8 43 ff ff ff       	call   8016bf <fsipc>
  80177c:	85 c0                	test   %eax,%eax
  80177e:	78 2c                	js     8017ac <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801780:	83 ec 08             	sub    $0x8,%esp
  801783:	68 00 50 80 00       	push   $0x805000
  801788:	53                   	push   %ebx
  801789:	e8 b4 f0 ff ff       	call   800842 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80178e:	a1 80 50 80 00       	mov    0x805080,%eax
  801793:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801799:	a1 84 50 80 00       	mov    0x805084,%eax
  80179e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017a4:	83 c4 10             	add    $0x10,%esp
  8017a7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017af:	c9                   	leave  
  8017b0:	c3                   	ret    

008017b1 <devfile_write>:
{
  8017b1:	55                   	push   %ebp
  8017b2:	89 e5                	mov    %esp,%ebp
  8017b4:	83 ec 0c             	sub    $0xc,%esp
  8017b7:	8b 45 10             	mov    0x10(%ebp),%eax
  8017ba:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8017bf:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8017c4:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8017ca:	8b 52 0c             	mov    0xc(%edx),%edx
  8017cd:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8017d3:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf,buf,n);
  8017d8:	50                   	push   %eax
  8017d9:	ff 75 0c             	pushl  0xc(%ebp)
  8017dc:	68 08 50 80 00       	push   $0x805008
  8017e1:	e8 ea f1 ff ff       	call   8009d0 <memmove>
	if((r = fsipc(FSREQ_WRITE,NULL))<0)
  8017e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8017eb:	b8 04 00 00 00       	mov    $0x4,%eax
  8017f0:	e8 ca fe ff ff       	call   8016bf <fsipc>
}
  8017f5:	c9                   	leave  
  8017f6:	c3                   	ret    

008017f7 <devfile_read>:
{
  8017f7:	55                   	push   %ebp
  8017f8:	89 e5                	mov    %esp,%ebp
  8017fa:	56                   	push   %esi
  8017fb:	53                   	push   %ebx
  8017fc:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801802:	8b 40 0c             	mov    0xc(%eax),%eax
  801805:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80180a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801810:	ba 00 00 00 00       	mov    $0x0,%edx
  801815:	b8 03 00 00 00       	mov    $0x3,%eax
  80181a:	e8 a0 fe ff ff       	call   8016bf <fsipc>
  80181f:	89 c3                	mov    %eax,%ebx
  801821:	85 c0                	test   %eax,%eax
  801823:	78 1f                	js     801844 <devfile_read+0x4d>
	assert(r <= n);
  801825:	39 f0                	cmp    %esi,%eax
  801827:	77 24                	ja     80184d <devfile_read+0x56>
	assert(r <= PGSIZE);
  801829:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80182e:	7f 33                	jg     801863 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801830:	83 ec 04             	sub    $0x4,%esp
  801833:	50                   	push   %eax
  801834:	68 00 50 80 00       	push   $0x805000
  801839:	ff 75 0c             	pushl  0xc(%ebp)
  80183c:	e8 8f f1 ff ff       	call   8009d0 <memmove>
	return r;
  801841:	83 c4 10             	add    $0x10,%esp
}
  801844:	89 d8                	mov    %ebx,%eax
  801846:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801849:	5b                   	pop    %ebx
  80184a:	5e                   	pop    %esi
  80184b:	5d                   	pop    %ebp
  80184c:	c3                   	ret    
	assert(r <= n);
  80184d:	68 7c 27 80 00       	push   $0x80277c
  801852:	68 83 27 80 00       	push   $0x802783
  801857:	6a 7c                	push   $0x7c
  801859:	68 98 27 80 00       	push   $0x802798
  80185e:	e8 e5 e8 ff ff       	call   800148 <_panic>
	assert(r <= PGSIZE);
  801863:	68 a3 27 80 00       	push   $0x8027a3
  801868:	68 83 27 80 00       	push   $0x802783
  80186d:	6a 7d                	push   $0x7d
  80186f:	68 98 27 80 00       	push   $0x802798
  801874:	e8 cf e8 ff ff       	call   800148 <_panic>

00801879 <open>:
{
  801879:	55                   	push   %ebp
  80187a:	89 e5                	mov    %esp,%ebp
  80187c:	56                   	push   %esi
  80187d:	53                   	push   %ebx
  80187e:	83 ec 1c             	sub    $0x1c,%esp
  801881:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801884:	56                   	push   %esi
  801885:	e8 81 ef ff ff       	call   80080b <strlen>
  80188a:	83 c4 10             	add    $0x10,%esp
  80188d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801892:	7f 6c                	jg     801900 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801894:	83 ec 0c             	sub    $0xc,%esp
  801897:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80189a:	50                   	push   %eax
  80189b:	e8 b4 f8 ff ff       	call   801154 <fd_alloc>
  8018a0:	89 c3                	mov    %eax,%ebx
  8018a2:	83 c4 10             	add    $0x10,%esp
  8018a5:	85 c0                	test   %eax,%eax
  8018a7:	78 3c                	js     8018e5 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8018a9:	83 ec 08             	sub    $0x8,%esp
  8018ac:	56                   	push   %esi
  8018ad:	68 00 50 80 00       	push   $0x805000
  8018b2:	e8 8b ef ff ff       	call   800842 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018ba:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018c2:	b8 01 00 00 00       	mov    $0x1,%eax
  8018c7:	e8 f3 fd ff ff       	call   8016bf <fsipc>
  8018cc:	89 c3                	mov    %eax,%ebx
  8018ce:	83 c4 10             	add    $0x10,%esp
  8018d1:	85 c0                	test   %eax,%eax
  8018d3:	78 19                	js     8018ee <open+0x75>
	return fd2num(fd);
  8018d5:	83 ec 0c             	sub    $0xc,%esp
  8018d8:	ff 75 f4             	pushl  -0xc(%ebp)
  8018db:	e8 4d f8 ff ff       	call   80112d <fd2num>
  8018e0:	89 c3                	mov    %eax,%ebx
  8018e2:	83 c4 10             	add    $0x10,%esp
}
  8018e5:	89 d8                	mov    %ebx,%eax
  8018e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018ea:	5b                   	pop    %ebx
  8018eb:	5e                   	pop    %esi
  8018ec:	5d                   	pop    %ebp
  8018ed:	c3                   	ret    
		fd_close(fd, 0);
  8018ee:	83 ec 08             	sub    $0x8,%esp
  8018f1:	6a 00                	push   $0x0
  8018f3:	ff 75 f4             	pushl  -0xc(%ebp)
  8018f6:	e8 54 f9 ff ff       	call   80124f <fd_close>
		return r;
  8018fb:	83 c4 10             	add    $0x10,%esp
  8018fe:	eb e5                	jmp    8018e5 <open+0x6c>
		return -E_BAD_PATH;
  801900:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801905:	eb de                	jmp    8018e5 <open+0x6c>

00801907 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801907:	55                   	push   %ebp
  801908:	89 e5                	mov    %esp,%ebp
  80190a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80190d:	ba 00 00 00 00       	mov    $0x0,%edx
  801912:	b8 08 00 00 00       	mov    $0x8,%eax
  801917:	e8 a3 fd ff ff       	call   8016bf <fsipc>
}
  80191c:	c9                   	leave  
  80191d:	c3                   	ret    

0080191e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80191e:	55                   	push   %ebp
  80191f:	89 e5                	mov    %esp,%ebp
  801921:	56                   	push   %esi
  801922:	53                   	push   %ebx
  801923:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801926:	83 ec 0c             	sub    $0xc,%esp
  801929:	ff 75 08             	pushl  0x8(%ebp)
  80192c:	e8 0c f8 ff ff       	call   80113d <fd2data>
  801931:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801933:	83 c4 08             	add    $0x8,%esp
  801936:	68 af 27 80 00       	push   $0x8027af
  80193b:	53                   	push   %ebx
  80193c:	e8 01 ef ff ff       	call   800842 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801941:	8b 46 04             	mov    0x4(%esi),%eax
  801944:	2b 06                	sub    (%esi),%eax
  801946:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80194c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801953:	00 00 00 
	stat->st_dev = &devpipe;
  801956:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80195d:	30 80 00 
	return 0;
}
  801960:	b8 00 00 00 00       	mov    $0x0,%eax
  801965:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801968:	5b                   	pop    %ebx
  801969:	5e                   	pop    %esi
  80196a:	5d                   	pop    %ebp
  80196b:	c3                   	ret    

0080196c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80196c:	55                   	push   %ebp
  80196d:	89 e5                	mov    %esp,%ebp
  80196f:	53                   	push   %ebx
  801970:	83 ec 0c             	sub    $0xc,%esp
  801973:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801976:	53                   	push   %ebx
  801977:	6a 00                	push   $0x0
  801979:	e8 42 f3 ff ff       	call   800cc0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80197e:	89 1c 24             	mov    %ebx,(%esp)
  801981:	e8 b7 f7 ff ff       	call   80113d <fd2data>
  801986:	83 c4 08             	add    $0x8,%esp
  801989:	50                   	push   %eax
  80198a:	6a 00                	push   $0x0
  80198c:	e8 2f f3 ff ff       	call   800cc0 <sys_page_unmap>
}
  801991:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801994:	c9                   	leave  
  801995:	c3                   	ret    

00801996 <_pipeisclosed>:
{
  801996:	55                   	push   %ebp
  801997:	89 e5                	mov    %esp,%ebp
  801999:	57                   	push   %edi
  80199a:	56                   	push   %esi
  80199b:	53                   	push   %ebx
  80199c:	83 ec 1c             	sub    $0x1c,%esp
  80199f:	89 c7                	mov    %eax,%edi
  8019a1:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8019a3:	a1 08 40 80 00       	mov    0x804008,%eax
  8019a8:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8019ab:	83 ec 0c             	sub    $0xc,%esp
  8019ae:	57                   	push   %edi
  8019af:	e8 c4 05 00 00       	call   801f78 <pageref>
  8019b4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8019b7:	89 34 24             	mov    %esi,(%esp)
  8019ba:	e8 b9 05 00 00       	call   801f78 <pageref>
		nn = thisenv->env_runs;
  8019bf:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8019c5:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8019c8:	83 c4 10             	add    $0x10,%esp
  8019cb:	39 cb                	cmp    %ecx,%ebx
  8019cd:	74 1b                	je     8019ea <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8019cf:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8019d2:	75 cf                	jne    8019a3 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8019d4:	8b 42 58             	mov    0x58(%edx),%eax
  8019d7:	6a 01                	push   $0x1
  8019d9:	50                   	push   %eax
  8019da:	53                   	push   %ebx
  8019db:	68 b6 27 80 00       	push   $0x8027b6
  8019e0:	e8 3e e8 ff ff       	call   800223 <cprintf>
  8019e5:	83 c4 10             	add    $0x10,%esp
  8019e8:	eb b9                	jmp    8019a3 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8019ea:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8019ed:	0f 94 c0             	sete   %al
  8019f0:	0f b6 c0             	movzbl %al,%eax
}
  8019f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019f6:	5b                   	pop    %ebx
  8019f7:	5e                   	pop    %esi
  8019f8:	5f                   	pop    %edi
  8019f9:	5d                   	pop    %ebp
  8019fa:	c3                   	ret    

008019fb <devpipe_write>:
{
  8019fb:	55                   	push   %ebp
  8019fc:	89 e5                	mov    %esp,%ebp
  8019fe:	57                   	push   %edi
  8019ff:	56                   	push   %esi
  801a00:	53                   	push   %ebx
  801a01:	83 ec 28             	sub    $0x28,%esp
  801a04:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801a07:	56                   	push   %esi
  801a08:	e8 30 f7 ff ff       	call   80113d <fd2data>
  801a0d:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801a0f:	83 c4 10             	add    $0x10,%esp
  801a12:	bf 00 00 00 00       	mov    $0x0,%edi
  801a17:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a1a:	74 4f                	je     801a6b <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a1c:	8b 43 04             	mov    0x4(%ebx),%eax
  801a1f:	8b 0b                	mov    (%ebx),%ecx
  801a21:	8d 51 20             	lea    0x20(%ecx),%edx
  801a24:	39 d0                	cmp    %edx,%eax
  801a26:	72 14                	jb     801a3c <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801a28:	89 da                	mov    %ebx,%edx
  801a2a:	89 f0                	mov    %esi,%eax
  801a2c:	e8 65 ff ff ff       	call   801996 <_pipeisclosed>
  801a31:	85 c0                	test   %eax,%eax
  801a33:	75 3a                	jne    801a6f <devpipe_write+0x74>
			sys_yield();
  801a35:	e8 e2 f1 ff ff       	call   800c1c <sys_yield>
  801a3a:	eb e0                	jmp    801a1c <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a3f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a43:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a46:	89 c2                	mov    %eax,%edx
  801a48:	c1 fa 1f             	sar    $0x1f,%edx
  801a4b:	89 d1                	mov    %edx,%ecx
  801a4d:	c1 e9 1b             	shr    $0x1b,%ecx
  801a50:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a53:	83 e2 1f             	and    $0x1f,%edx
  801a56:	29 ca                	sub    %ecx,%edx
  801a58:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a5c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a60:	83 c0 01             	add    $0x1,%eax
  801a63:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801a66:	83 c7 01             	add    $0x1,%edi
  801a69:	eb ac                	jmp    801a17 <devpipe_write+0x1c>
	return i;
  801a6b:	89 f8                	mov    %edi,%eax
  801a6d:	eb 05                	jmp    801a74 <devpipe_write+0x79>
				return 0;
  801a6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a77:	5b                   	pop    %ebx
  801a78:	5e                   	pop    %esi
  801a79:	5f                   	pop    %edi
  801a7a:	5d                   	pop    %ebp
  801a7b:	c3                   	ret    

00801a7c <devpipe_read>:
{
  801a7c:	55                   	push   %ebp
  801a7d:	89 e5                	mov    %esp,%ebp
  801a7f:	57                   	push   %edi
  801a80:	56                   	push   %esi
  801a81:	53                   	push   %ebx
  801a82:	83 ec 18             	sub    $0x18,%esp
  801a85:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801a88:	57                   	push   %edi
  801a89:	e8 af f6 ff ff       	call   80113d <fd2data>
  801a8e:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801a90:	83 c4 10             	add    $0x10,%esp
  801a93:	be 00 00 00 00       	mov    $0x0,%esi
  801a98:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a9b:	74 47                	je     801ae4 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  801a9d:	8b 03                	mov    (%ebx),%eax
  801a9f:	3b 43 04             	cmp    0x4(%ebx),%eax
  801aa2:	75 22                	jne    801ac6 <devpipe_read+0x4a>
			if (i > 0)
  801aa4:	85 f6                	test   %esi,%esi
  801aa6:	75 14                	jne    801abc <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801aa8:	89 da                	mov    %ebx,%edx
  801aaa:	89 f8                	mov    %edi,%eax
  801aac:	e8 e5 fe ff ff       	call   801996 <_pipeisclosed>
  801ab1:	85 c0                	test   %eax,%eax
  801ab3:	75 33                	jne    801ae8 <devpipe_read+0x6c>
			sys_yield();
  801ab5:	e8 62 f1 ff ff       	call   800c1c <sys_yield>
  801aba:	eb e1                	jmp    801a9d <devpipe_read+0x21>
				return i;
  801abc:	89 f0                	mov    %esi,%eax
}
  801abe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ac1:	5b                   	pop    %ebx
  801ac2:	5e                   	pop    %esi
  801ac3:	5f                   	pop    %edi
  801ac4:	5d                   	pop    %ebp
  801ac5:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ac6:	99                   	cltd   
  801ac7:	c1 ea 1b             	shr    $0x1b,%edx
  801aca:	01 d0                	add    %edx,%eax
  801acc:	83 e0 1f             	and    $0x1f,%eax
  801acf:	29 d0                	sub    %edx,%eax
  801ad1:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801ad6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ad9:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801adc:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801adf:	83 c6 01             	add    $0x1,%esi
  801ae2:	eb b4                	jmp    801a98 <devpipe_read+0x1c>
	return i;
  801ae4:	89 f0                	mov    %esi,%eax
  801ae6:	eb d6                	jmp    801abe <devpipe_read+0x42>
				return 0;
  801ae8:	b8 00 00 00 00       	mov    $0x0,%eax
  801aed:	eb cf                	jmp    801abe <devpipe_read+0x42>

00801aef <pipe>:
{
  801aef:	55                   	push   %ebp
  801af0:	89 e5                	mov    %esp,%ebp
  801af2:	56                   	push   %esi
  801af3:	53                   	push   %ebx
  801af4:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801af7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801afa:	50                   	push   %eax
  801afb:	e8 54 f6 ff ff       	call   801154 <fd_alloc>
  801b00:	89 c3                	mov    %eax,%ebx
  801b02:	83 c4 10             	add    $0x10,%esp
  801b05:	85 c0                	test   %eax,%eax
  801b07:	78 5b                	js     801b64 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b09:	83 ec 04             	sub    $0x4,%esp
  801b0c:	68 07 04 00 00       	push   $0x407
  801b11:	ff 75 f4             	pushl  -0xc(%ebp)
  801b14:	6a 00                	push   $0x0
  801b16:	e8 20 f1 ff ff       	call   800c3b <sys_page_alloc>
  801b1b:	89 c3                	mov    %eax,%ebx
  801b1d:	83 c4 10             	add    $0x10,%esp
  801b20:	85 c0                	test   %eax,%eax
  801b22:	78 40                	js     801b64 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  801b24:	83 ec 0c             	sub    $0xc,%esp
  801b27:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b2a:	50                   	push   %eax
  801b2b:	e8 24 f6 ff ff       	call   801154 <fd_alloc>
  801b30:	89 c3                	mov    %eax,%ebx
  801b32:	83 c4 10             	add    $0x10,%esp
  801b35:	85 c0                	test   %eax,%eax
  801b37:	78 1b                	js     801b54 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b39:	83 ec 04             	sub    $0x4,%esp
  801b3c:	68 07 04 00 00       	push   $0x407
  801b41:	ff 75 f0             	pushl  -0x10(%ebp)
  801b44:	6a 00                	push   $0x0
  801b46:	e8 f0 f0 ff ff       	call   800c3b <sys_page_alloc>
  801b4b:	89 c3                	mov    %eax,%ebx
  801b4d:	83 c4 10             	add    $0x10,%esp
  801b50:	85 c0                	test   %eax,%eax
  801b52:	79 19                	jns    801b6d <pipe+0x7e>
	sys_page_unmap(0, fd0);
  801b54:	83 ec 08             	sub    $0x8,%esp
  801b57:	ff 75 f4             	pushl  -0xc(%ebp)
  801b5a:	6a 00                	push   $0x0
  801b5c:	e8 5f f1 ff ff       	call   800cc0 <sys_page_unmap>
  801b61:	83 c4 10             	add    $0x10,%esp
}
  801b64:	89 d8                	mov    %ebx,%eax
  801b66:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b69:	5b                   	pop    %ebx
  801b6a:	5e                   	pop    %esi
  801b6b:	5d                   	pop    %ebp
  801b6c:	c3                   	ret    
	va = fd2data(fd0);
  801b6d:	83 ec 0c             	sub    $0xc,%esp
  801b70:	ff 75 f4             	pushl  -0xc(%ebp)
  801b73:	e8 c5 f5 ff ff       	call   80113d <fd2data>
  801b78:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b7a:	83 c4 0c             	add    $0xc,%esp
  801b7d:	68 07 04 00 00       	push   $0x407
  801b82:	50                   	push   %eax
  801b83:	6a 00                	push   $0x0
  801b85:	e8 b1 f0 ff ff       	call   800c3b <sys_page_alloc>
  801b8a:	89 c3                	mov    %eax,%ebx
  801b8c:	83 c4 10             	add    $0x10,%esp
  801b8f:	85 c0                	test   %eax,%eax
  801b91:	0f 88 8c 00 00 00    	js     801c23 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b97:	83 ec 0c             	sub    $0xc,%esp
  801b9a:	ff 75 f0             	pushl  -0x10(%ebp)
  801b9d:	e8 9b f5 ff ff       	call   80113d <fd2data>
  801ba2:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ba9:	50                   	push   %eax
  801baa:	6a 00                	push   $0x0
  801bac:	56                   	push   %esi
  801bad:	6a 00                	push   $0x0
  801baf:	e8 ca f0 ff ff       	call   800c7e <sys_page_map>
  801bb4:	89 c3                	mov    %eax,%ebx
  801bb6:	83 c4 20             	add    $0x20,%esp
  801bb9:	85 c0                	test   %eax,%eax
  801bbb:	78 58                	js     801c15 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801bbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bc0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bc6:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801bc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bcb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801bd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bd5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bdb:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801bdd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801be0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801be7:	83 ec 0c             	sub    $0xc,%esp
  801bea:	ff 75 f4             	pushl  -0xc(%ebp)
  801bed:	e8 3b f5 ff ff       	call   80112d <fd2num>
  801bf2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bf5:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801bf7:	83 c4 04             	add    $0x4,%esp
  801bfa:	ff 75 f0             	pushl  -0x10(%ebp)
  801bfd:	e8 2b f5 ff ff       	call   80112d <fd2num>
  801c02:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c05:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c08:	83 c4 10             	add    $0x10,%esp
  801c0b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c10:	e9 4f ff ff ff       	jmp    801b64 <pipe+0x75>
	sys_page_unmap(0, va);
  801c15:	83 ec 08             	sub    $0x8,%esp
  801c18:	56                   	push   %esi
  801c19:	6a 00                	push   $0x0
  801c1b:	e8 a0 f0 ff ff       	call   800cc0 <sys_page_unmap>
  801c20:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801c23:	83 ec 08             	sub    $0x8,%esp
  801c26:	ff 75 f0             	pushl  -0x10(%ebp)
  801c29:	6a 00                	push   $0x0
  801c2b:	e8 90 f0 ff ff       	call   800cc0 <sys_page_unmap>
  801c30:	83 c4 10             	add    $0x10,%esp
  801c33:	e9 1c ff ff ff       	jmp    801b54 <pipe+0x65>

00801c38 <pipeisclosed>:
{
  801c38:	55                   	push   %ebp
  801c39:	89 e5                	mov    %esp,%ebp
  801c3b:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c3e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c41:	50                   	push   %eax
  801c42:	ff 75 08             	pushl  0x8(%ebp)
  801c45:	e8 59 f5 ff ff       	call   8011a3 <fd_lookup>
  801c4a:	83 c4 10             	add    $0x10,%esp
  801c4d:	85 c0                	test   %eax,%eax
  801c4f:	78 18                	js     801c69 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801c51:	83 ec 0c             	sub    $0xc,%esp
  801c54:	ff 75 f4             	pushl  -0xc(%ebp)
  801c57:	e8 e1 f4 ff ff       	call   80113d <fd2data>
	return _pipeisclosed(fd, p);
  801c5c:	89 c2                	mov    %eax,%edx
  801c5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c61:	e8 30 fd ff ff       	call   801996 <_pipeisclosed>
  801c66:	83 c4 10             	add    $0x10,%esp
}
  801c69:	c9                   	leave  
  801c6a:	c3                   	ret    

00801c6b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c6b:	55                   	push   %ebp
  801c6c:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c6e:	b8 00 00 00 00       	mov    $0x0,%eax
  801c73:	5d                   	pop    %ebp
  801c74:	c3                   	ret    

00801c75 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c75:	55                   	push   %ebp
  801c76:	89 e5                	mov    %esp,%ebp
  801c78:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c7b:	68 ce 27 80 00       	push   $0x8027ce
  801c80:	ff 75 0c             	pushl  0xc(%ebp)
  801c83:	e8 ba eb ff ff       	call   800842 <strcpy>
	return 0;
}
  801c88:	b8 00 00 00 00       	mov    $0x0,%eax
  801c8d:	c9                   	leave  
  801c8e:	c3                   	ret    

00801c8f <devcons_write>:
{
  801c8f:	55                   	push   %ebp
  801c90:	89 e5                	mov    %esp,%ebp
  801c92:	57                   	push   %edi
  801c93:	56                   	push   %esi
  801c94:	53                   	push   %ebx
  801c95:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801c9b:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801ca0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801ca6:	eb 2f                	jmp    801cd7 <devcons_write+0x48>
		m = n - tot;
  801ca8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801cab:	29 f3                	sub    %esi,%ebx
  801cad:	83 fb 7f             	cmp    $0x7f,%ebx
  801cb0:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801cb5:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801cb8:	83 ec 04             	sub    $0x4,%esp
  801cbb:	53                   	push   %ebx
  801cbc:	89 f0                	mov    %esi,%eax
  801cbe:	03 45 0c             	add    0xc(%ebp),%eax
  801cc1:	50                   	push   %eax
  801cc2:	57                   	push   %edi
  801cc3:	e8 08 ed ff ff       	call   8009d0 <memmove>
		sys_cputs(buf, m);
  801cc8:	83 c4 08             	add    $0x8,%esp
  801ccb:	53                   	push   %ebx
  801ccc:	57                   	push   %edi
  801ccd:	e8 ad ee ff ff       	call   800b7f <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801cd2:	01 de                	add    %ebx,%esi
  801cd4:	83 c4 10             	add    $0x10,%esp
  801cd7:	3b 75 10             	cmp    0x10(%ebp),%esi
  801cda:	72 cc                	jb     801ca8 <devcons_write+0x19>
}
  801cdc:	89 f0                	mov    %esi,%eax
  801cde:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ce1:	5b                   	pop    %ebx
  801ce2:	5e                   	pop    %esi
  801ce3:	5f                   	pop    %edi
  801ce4:	5d                   	pop    %ebp
  801ce5:	c3                   	ret    

00801ce6 <devcons_read>:
{
  801ce6:	55                   	push   %ebp
  801ce7:	89 e5                	mov    %esp,%ebp
  801ce9:	83 ec 08             	sub    $0x8,%esp
  801cec:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801cf1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801cf5:	75 07                	jne    801cfe <devcons_read+0x18>
}
  801cf7:	c9                   	leave  
  801cf8:	c3                   	ret    
		sys_yield();
  801cf9:	e8 1e ef ff ff       	call   800c1c <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801cfe:	e8 9a ee ff ff       	call   800b9d <sys_cgetc>
  801d03:	85 c0                	test   %eax,%eax
  801d05:	74 f2                	je     801cf9 <devcons_read+0x13>
	if (c < 0)
  801d07:	85 c0                	test   %eax,%eax
  801d09:	78 ec                	js     801cf7 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  801d0b:	83 f8 04             	cmp    $0x4,%eax
  801d0e:	74 0c                	je     801d1c <devcons_read+0x36>
	*(char*)vbuf = c;
  801d10:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d13:	88 02                	mov    %al,(%edx)
	return 1;
  801d15:	b8 01 00 00 00       	mov    $0x1,%eax
  801d1a:	eb db                	jmp    801cf7 <devcons_read+0x11>
		return 0;
  801d1c:	b8 00 00 00 00       	mov    $0x0,%eax
  801d21:	eb d4                	jmp    801cf7 <devcons_read+0x11>

00801d23 <cputchar>:
{
  801d23:	55                   	push   %ebp
  801d24:	89 e5                	mov    %esp,%ebp
  801d26:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d29:	8b 45 08             	mov    0x8(%ebp),%eax
  801d2c:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801d2f:	6a 01                	push   $0x1
  801d31:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d34:	50                   	push   %eax
  801d35:	e8 45 ee ff ff       	call   800b7f <sys_cputs>
}
  801d3a:	83 c4 10             	add    $0x10,%esp
  801d3d:	c9                   	leave  
  801d3e:	c3                   	ret    

00801d3f <getchar>:
{
  801d3f:	55                   	push   %ebp
  801d40:	89 e5                	mov    %esp,%ebp
  801d42:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801d45:	6a 01                	push   $0x1
  801d47:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d4a:	50                   	push   %eax
  801d4b:	6a 00                	push   $0x0
  801d4d:	e8 c2 f6 ff ff       	call   801414 <read>
	if (r < 0)
  801d52:	83 c4 10             	add    $0x10,%esp
  801d55:	85 c0                	test   %eax,%eax
  801d57:	78 08                	js     801d61 <getchar+0x22>
	if (r < 1)
  801d59:	85 c0                	test   %eax,%eax
  801d5b:	7e 06                	jle    801d63 <getchar+0x24>
	return c;
  801d5d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801d61:	c9                   	leave  
  801d62:	c3                   	ret    
		return -E_EOF;
  801d63:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801d68:	eb f7                	jmp    801d61 <getchar+0x22>

00801d6a <iscons>:
{
  801d6a:	55                   	push   %ebp
  801d6b:	89 e5                	mov    %esp,%ebp
  801d6d:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d70:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d73:	50                   	push   %eax
  801d74:	ff 75 08             	pushl  0x8(%ebp)
  801d77:	e8 27 f4 ff ff       	call   8011a3 <fd_lookup>
  801d7c:	83 c4 10             	add    $0x10,%esp
  801d7f:	85 c0                	test   %eax,%eax
  801d81:	78 11                	js     801d94 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801d83:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d86:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d8c:	39 10                	cmp    %edx,(%eax)
  801d8e:	0f 94 c0             	sete   %al
  801d91:	0f b6 c0             	movzbl %al,%eax
}
  801d94:	c9                   	leave  
  801d95:	c3                   	ret    

00801d96 <opencons>:
{
  801d96:	55                   	push   %ebp
  801d97:	89 e5                	mov    %esp,%ebp
  801d99:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801d9c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d9f:	50                   	push   %eax
  801da0:	e8 af f3 ff ff       	call   801154 <fd_alloc>
  801da5:	83 c4 10             	add    $0x10,%esp
  801da8:	85 c0                	test   %eax,%eax
  801daa:	78 3a                	js     801de6 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801dac:	83 ec 04             	sub    $0x4,%esp
  801daf:	68 07 04 00 00       	push   $0x407
  801db4:	ff 75 f4             	pushl  -0xc(%ebp)
  801db7:	6a 00                	push   $0x0
  801db9:	e8 7d ee ff ff       	call   800c3b <sys_page_alloc>
  801dbe:	83 c4 10             	add    $0x10,%esp
  801dc1:	85 c0                	test   %eax,%eax
  801dc3:	78 21                	js     801de6 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801dc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dc8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801dce:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801dd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dd3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801dda:	83 ec 0c             	sub    $0xc,%esp
  801ddd:	50                   	push   %eax
  801dde:	e8 4a f3 ff ff       	call   80112d <fd2num>
  801de3:	83 c4 10             	add    $0x10,%esp
}
  801de6:	c9                   	leave  
  801de7:	c3                   	ret    

00801de8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801de8:	55                   	push   %ebp
  801de9:	89 e5                	mov    %esp,%ebp
  801deb:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801dee:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801df5:	74 0a                	je     801e01 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler %e",r);
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
	}
       
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801df7:	8b 45 08             	mov    0x8(%ebp),%eax
  801dfa:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801dff:	c9                   	leave  
  801e00:	c3                   	ret    
		if((r=sys_page_alloc(thisenv->env_id,(void *)UXSTACKTOP-PGSIZE,PTE_P|PTE_W|PTE_U))<0)
  801e01:	a1 08 40 80 00       	mov    0x804008,%eax
  801e06:	8b 40 48             	mov    0x48(%eax),%eax
  801e09:	83 ec 04             	sub    $0x4,%esp
  801e0c:	6a 07                	push   $0x7
  801e0e:	68 00 f0 bf ee       	push   $0xeebff000
  801e13:	50                   	push   %eax
  801e14:	e8 22 ee ff ff       	call   800c3b <sys_page_alloc>
  801e19:	83 c4 10             	add    $0x10,%esp
  801e1c:	85 c0                	test   %eax,%eax
  801e1e:	78 1b                	js     801e3b <set_pgfault_handler+0x53>
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
  801e20:	a1 08 40 80 00       	mov    0x804008,%eax
  801e25:	8b 40 48             	mov    0x48(%eax),%eax
  801e28:	83 ec 08             	sub    $0x8,%esp
  801e2b:	68 4d 1e 80 00       	push   $0x801e4d
  801e30:	50                   	push   %eax
  801e31:	e8 50 ef ff ff       	call   800d86 <sys_env_set_pgfault_upcall>
  801e36:	83 c4 10             	add    $0x10,%esp
  801e39:	eb bc                	jmp    801df7 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler %e",r);
  801e3b:	50                   	push   %eax
  801e3c:	68 da 27 80 00       	push   $0x8027da
  801e41:	6a 22                	push   $0x22
  801e43:	68 f1 27 80 00       	push   $0x8027f1
  801e48:	e8 fb e2 ff ff       	call   800148 <_panic>

00801e4d <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e4d:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e4e:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e53:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e55:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 48(%esp), %ebp
  801e58:	8b 6c 24 30          	mov    0x30(%esp),%ebp
        subl $4, %ebp
  801e5c:	83 ed 04             	sub    $0x4,%ebp
        movl %ebp, 48(%esp)
  801e5f:	89 6c 24 30          	mov    %ebp,0x30(%esp)
        movl 40(%esp), %eax
  801e63:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl %eax, (%ebp)
  801e67:	89 45 00             	mov    %eax,0x0(%ebp)
	// Restore the trap-time registers.  After you do this, you
 	// can no longer modify any general-purpose registers.
 	// LAB 4: Your code here.
        addl $8, %esp
  801e6a:	83 c4 08             	add    $0x8,%esp
        popal
  801e6d:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $4, %esp
  801e6e:	83 c4 04             	add    $0x4,%esp
        popfl
  801e71:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  801e72:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  801e73:	c3                   	ret    

00801e74 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e74:	55                   	push   %ebp
  801e75:	89 e5                	mov    %esp,%ebp
  801e77:	56                   	push   %esi
  801e78:	53                   	push   %ebx
  801e79:	8b 75 08             	mov    0x8(%ebp),%esi
  801e7c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e7f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        //	panic("ipc_recv not implemented");
        int r;
       	if(pg!=NULL){
  801e82:	85 c0                	test   %eax,%eax
  801e84:	74 3b                	je     801ec1 <ipc_recv+0x4d>
	  r = sys_ipc_recv(pg);
  801e86:	83 ec 0c             	sub    $0xc,%esp
  801e89:	50                   	push   %eax
  801e8a:	e8 5c ef ff ff       	call   800deb <sys_ipc_recv>
  801e8f:	83 c4 10             	add    $0x10,%esp
	}else
	  r = sys_ipc_recv((void *)UTOP);
	if(r<0){
  801e92:	85 c0                	test   %eax,%eax
  801e94:	78 3d                	js     801ed3 <ipc_recv+0x5f>
	if(perm_store!=NULL){
		*perm_store = 0;
            }
        	return r;
           }else{
	     if(from_env_store!=NULL)
  801e96:	85 f6                	test   %esi,%esi
  801e98:	74 0a                	je     801ea4 <ipc_recv+0x30>
		     *from_env_store = thisenv->env_ipc_from;
  801e9a:	a1 08 40 80 00       	mov    0x804008,%eax
  801e9f:	8b 40 74             	mov    0x74(%eax),%eax
  801ea2:	89 06                	mov    %eax,(%esi)
	     if(perm_store != NULL)
  801ea4:	85 db                	test   %ebx,%ebx
  801ea6:	74 0a                	je     801eb2 <ipc_recv+0x3e>
		     *perm_store = thisenv->env_ipc_perm;
  801ea8:	a1 08 40 80 00       	mov    0x804008,%eax
  801ead:	8b 40 78             	mov    0x78(%eax),%eax
  801eb0:	89 03                	mov    %eax,(%ebx)
	     return thisenv->env_ipc_value;
  801eb2:	a1 08 40 80 00       	mov    0x804008,%eax
  801eb7:	8b 40 70             	mov    0x70(%eax),%eax
	   }

}
  801eba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ebd:	5b                   	pop    %ebx
  801ebe:	5e                   	pop    %esi
  801ebf:	5d                   	pop    %ebp
  801ec0:	c3                   	ret    
	  r = sys_ipc_recv((void *)UTOP);
  801ec1:	83 ec 0c             	sub    $0xc,%esp
  801ec4:	68 00 00 c0 ee       	push   $0xeec00000
  801ec9:	e8 1d ef ff ff       	call   800deb <sys_ipc_recv>
  801ece:	83 c4 10             	add    $0x10,%esp
  801ed1:	eb bf                	jmp    801e92 <ipc_recv+0x1e>
	if(from_env_store!=NULL){
  801ed3:	85 f6                	test   %esi,%esi
  801ed5:	74 06                	je     801edd <ipc_recv+0x69>
	  *from_env_store = 0;
  801ed7:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if(perm_store!=NULL){
  801edd:	85 db                	test   %ebx,%ebx
  801edf:	74 d9                	je     801eba <ipc_recv+0x46>
		*perm_store = 0;
  801ee1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ee7:	eb d1                	jmp    801eba <ipc_recv+0x46>

00801ee9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ee9:	55                   	push   %ebp
  801eea:	89 e5                	mov    %esp,%ebp
  801eec:	57                   	push   %edi
  801eed:	56                   	push   %esi
  801eee:	53                   	push   %ebx
  801eef:	83 ec 0c             	sub    $0xc,%esp
  801ef2:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ef5:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ef8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if(pg==NULL) pg = (void *)UTOP;
  801efb:	85 db                	test   %ebx,%ebx
  801efd:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f02:	0f 44 d8             	cmove  %eax,%ebx
	while((r=sys_ipc_try_send(to_env,val,pg,perm))<0){
  801f05:	ff 75 14             	pushl  0x14(%ebp)
  801f08:	53                   	push   %ebx
  801f09:	56                   	push   %esi
  801f0a:	57                   	push   %edi
  801f0b:	e8 b8 ee ff ff       	call   800dc8 <sys_ipc_try_send>
  801f10:	83 c4 10             	add    $0x10,%esp
  801f13:	85 c0                	test   %eax,%eax
  801f15:	79 20                	jns    801f37 <ipc_send+0x4e>
	    if(r!=-E_IPC_NOT_RECV){
  801f17:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f1a:	75 07                	jne    801f23 <ipc_send+0x3a>
		    panic("ipc_send:send message failed\n");
	    }
	    sys_yield();
  801f1c:	e8 fb ec ff ff       	call   800c1c <sys_yield>
  801f21:	eb e2                	jmp    801f05 <ipc_send+0x1c>
		    panic("ipc_send:send message failed\n");
  801f23:	83 ec 04             	sub    $0x4,%esp
  801f26:	68 ff 27 80 00       	push   $0x8027ff
  801f2b:	6a 43                	push   $0x43
  801f2d:	68 1d 28 80 00       	push   $0x80281d
  801f32:	e8 11 e2 ff ff       	call   800148 <_panic>
	}

}
  801f37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f3a:	5b                   	pop    %ebx
  801f3b:	5e                   	pop    %esi
  801f3c:	5f                   	pop    %edi
  801f3d:	5d                   	pop    %ebp
  801f3e:	c3                   	ret    

00801f3f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f3f:	55                   	push   %ebp
  801f40:	89 e5                	mov    %esp,%ebp
  801f42:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f45:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f4a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f4d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f53:	8b 52 50             	mov    0x50(%edx),%edx
  801f56:	39 ca                	cmp    %ecx,%edx
  801f58:	74 11                	je     801f6b <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801f5a:	83 c0 01             	add    $0x1,%eax
  801f5d:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f62:	75 e6                	jne    801f4a <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801f64:	b8 00 00 00 00       	mov    $0x0,%eax
  801f69:	eb 0b                	jmp    801f76 <ipc_find_env+0x37>
			return envs[i].env_id;
  801f6b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f6e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f73:	8b 40 48             	mov    0x48(%eax),%eax
}
  801f76:	5d                   	pop    %ebp
  801f77:	c3                   	ret    

00801f78 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f78:	55                   	push   %ebp
  801f79:	89 e5                	mov    %esp,%ebp
  801f7b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f7e:	89 d0                	mov    %edx,%eax
  801f80:	c1 e8 16             	shr    $0x16,%eax
  801f83:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f8a:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801f8f:	f6 c1 01             	test   $0x1,%cl
  801f92:	74 1d                	je     801fb1 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801f94:	c1 ea 0c             	shr    $0xc,%edx
  801f97:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f9e:	f6 c2 01             	test   $0x1,%dl
  801fa1:	74 0e                	je     801fb1 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fa3:	c1 ea 0c             	shr    $0xc,%edx
  801fa6:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fad:	ef 
  801fae:	0f b7 c0             	movzwl %ax,%eax
}
  801fb1:	5d                   	pop    %ebp
  801fb2:	c3                   	ret    
  801fb3:	66 90                	xchg   %ax,%ax
  801fb5:	66 90                	xchg   %ax,%ax
  801fb7:	66 90                	xchg   %ax,%ax
  801fb9:	66 90                	xchg   %ax,%ax
  801fbb:	66 90                	xchg   %ax,%ax
  801fbd:	66 90                	xchg   %ax,%ax
  801fbf:	90                   	nop

00801fc0 <__udivdi3>:
  801fc0:	55                   	push   %ebp
  801fc1:	57                   	push   %edi
  801fc2:	56                   	push   %esi
  801fc3:	53                   	push   %ebx
  801fc4:	83 ec 1c             	sub    $0x1c,%esp
  801fc7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801fcb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801fcf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801fd3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801fd7:	85 d2                	test   %edx,%edx
  801fd9:	75 35                	jne    802010 <__udivdi3+0x50>
  801fdb:	39 f3                	cmp    %esi,%ebx
  801fdd:	0f 87 bd 00 00 00    	ja     8020a0 <__udivdi3+0xe0>
  801fe3:	85 db                	test   %ebx,%ebx
  801fe5:	89 d9                	mov    %ebx,%ecx
  801fe7:	75 0b                	jne    801ff4 <__udivdi3+0x34>
  801fe9:	b8 01 00 00 00       	mov    $0x1,%eax
  801fee:	31 d2                	xor    %edx,%edx
  801ff0:	f7 f3                	div    %ebx
  801ff2:	89 c1                	mov    %eax,%ecx
  801ff4:	31 d2                	xor    %edx,%edx
  801ff6:	89 f0                	mov    %esi,%eax
  801ff8:	f7 f1                	div    %ecx
  801ffa:	89 c6                	mov    %eax,%esi
  801ffc:	89 e8                	mov    %ebp,%eax
  801ffe:	89 f7                	mov    %esi,%edi
  802000:	f7 f1                	div    %ecx
  802002:	89 fa                	mov    %edi,%edx
  802004:	83 c4 1c             	add    $0x1c,%esp
  802007:	5b                   	pop    %ebx
  802008:	5e                   	pop    %esi
  802009:	5f                   	pop    %edi
  80200a:	5d                   	pop    %ebp
  80200b:	c3                   	ret    
  80200c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802010:	39 f2                	cmp    %esi,%edx
  802012:	77 7c                	ja     802090 <__udivdi3+0xd0>
  802014:	0f bd fa             	bsr    %edx,%edi
  802017:	83 f7 1f             	xor    $0x1f,%edi
  80201a:	0f 84 98 00 00 00    	je     8020b8 <__udivdi3+0xf8>
  802020:	89 f9                	mov    %edi,%ecx
  802022:	b8 20 00 00 00       	mov    $0x20,%eax
  802027:	29 f8                	sub    %edi,%eax
  802029:	d3 e2                	shl    %cl,%edx
  80202b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80202f:	89 c1                	mov    %eax,%ecx
  802031:	89 da                	mov    %ebx,%edx
  802033:	d3 ea                	shr    %cl,%edx
  802035:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802039:	09 d1                	or     %edx,%ecx
  80203b:	89 f2                	mov    %esi,%edx
  80203d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802041:	89 f9                	mov    %edi,%ecx
  802043:	d3 e3                	shl    %cl,%ebx
  802045:	89 c1                	mov    %eax,%ecx
  802047:	d3 ea                	shr    %cl,%edx
  802049:	89 f9                	mov    %edi,%ecx
  80204b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80204f:	d3 e6                	shl    %cl,%esi
  802051:	89 eb                	mov    %ebp,%ebx
  802053:	89 c1                	mov    %eax,%ecx
  802055:	d3 eb                	shr    %cl,%ebx
  802057:	09 de                	or     %ebx,%esi
  802059:	89 f0                	mov    %esi,%eax
  80205b:	f7 74 24 08          	divl   0x8(%esp)
  80205f:	89 d6                	mov    %edx,%esi
  802061:	89 c3                	mov    %eax,%ebx
  802063:	f7 64 24 0c          	mull   0xc(%esp)
  802067:	39 d6                	cmp    %edx,%esi
  802069:	72 0c                	jb     802077 <__udivdi3+0xb7>
  80206b:	89 f9                	mov    %edi,%ecx
  80206d:	d3 e5                	shl    %cl,%ebp
  80206f:	39 c5                	cmp    %eax,%ebp
  802071:	73 5d                	jae    8020d0 <__udivdi3+0x110>
  802073:	39 d6                	cmp    %edx,%esi
  802075:	75 59                	jne    8020d0 <__udivdi3+0x110>
  802077:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80207a:	31 ff                	xor    %edi,%edi
  80207c:	89 fa                	mov    %edi,%edx
  80207e:	83 c4 1c             	add    $0x1c,%esp
  802081:	5b                   	pop    %ebx
  802082:	5e                   	pop    %esi
  802083:	5f                   	pop    %edi
  802084:	5d                   	pop    %ebp
  802085:	c3                   	ret    
  802086:	8d 76 00             	lea    0x0(%esi),%esi
  802089:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802090:	31 ff                	xor    %edi,%edi
  802092:	31 c0                	xor    %eax,%eax
  802094:	89 fa                	mov    %edi,%edx
  802096:	83 c4 1c             	add    $0x1c,%esp
  802099:	5b                   	pop    %ebx
  80209a:	5e                   	pop    %esi
  80209b:	5f                   	pop    %edi
  80209c:	5d                   	pop    %ebp
  80209d:	c3                   	ret    
  80209e:	66 90                	xchg   %ax,%ax
  8020a0:	31 ff                	xor    %edi,%edi
  8020a2:	89 e8                	mov    %ebp,%eax
  8020a4:	89 f2                	mov    %esi,%edx
  8020a6:	f7 f3                	div    %ebx
  8020a8:	89 fa                	mov    %edi,%edx
  8020aa:	83 c4 1c             	add    $0x1c,%esp
  8020ad:	5b                   	pop    %ebx
  8020ae:	5e                   	pop    %esi
  8020af:	5f                   	pop    %edi
  8020b0:	5d                   	pop    %ebp
  8020b1:	c3                   	ret    
  8020b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020b8:	39 f2                	cmp    %esi,%edx
  8020ba:	72 06                	jb     8020c2 <__udivdi3+0x102>
  8020bc:	31 c0                	xor    %eax,%eax
  8020be:	39 eb                	cmp    %ebp,%ebx
  8020c0:	77 d2                	ja     802094 <__udivdi3+0xd4>
  8020c2:	b8 01 00 00 00       	mov    $0x1,%eax
  8020c7:	eb cb                	jmp    802094 <__udivdi3+0xd4>
  8020c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020d0:	89 d8                	mov    %ebx,%eax
  8020d2:	31 ff                	xor    %edi,%edi
  8020d4:	eb be                	jmp    802094 <__udivdi3+0xd4>
  8020d6:	66 90                	xchg   %ax,%ax
  8020d8:	66 90                	xchg   %ax,%ax
  8020da:	66 90                	xchg   %ax,%ax
  8020dc:	66 90                	xchg   %ax,%ax
  8020de:	66 90                	xchg   %ax,%ax

008020e0 <__umoddi3>:
  8020e0:	55                   	push   %ebp
  8020e1:	57                   	push   %edi
  8020e2:	56                   	push   %esi
  8020e3:	53                   	push   %ebx
  8020e4:	83 ec 1c             	sub    $0x1c,%esp
  8020e7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  8020eb:	8b 74 24 30          	mov    0x30(%esp),%esi
  8020ef:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8020f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020f7:	85 ed                	test   %ebp,%ebp
  8020f9:	89 f0                	mov    %esi,%eax
  8020fb:	89 da                	mov    %ebx,%edx
  8020fd:	75 19                	jne    802118 <__umoddi3+0x38>
  8020ff:	39 df                	cmp    %ebx,%edi
  802101:	0f 86 b1 00 00 00    	jbe    8021b8 <__umoddi3+0xd8>
  802107:	f7 f7                	div    %edi
  802109:	89 d0                	mov    %edx,%eax
  80210b:	31 d2                	xor    %edx,%edx
  80210d:	83 c4 1c             	add    $0x1c,%esp
  802110:	5b                   	pop    %ebx
  802111:	5e                   	pop    %esi
  802112:	5f                   	pop    %edi
  802113:	5d                   	pop    %ebp
  802114:	c3                   	ret    
  802115:	8d 76 00             	lea    0x0(%esi),%esi
  802118:	39 dd                	cmp    %ebx,%ebp
  80211a:	77 f1                	ja     80210d <__umoddi3+0x2d>
  80211c:	0f bd cd             	bsr    %ebp,%ecx
  80211f:	83 f1 1f             	xor    $0x1f,%ecx
  802122:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802126:	0f 84 b4 00 00 00    	je     8021e0 <__umoddi3+0x100>
  80212c:	b8 20 00 00 00       	mov    $0x20,%eax
  802131:	89 c2                	mov    %eax,%edx
  802133:	8b 44 24 04          	mov    0x4(%esp),%eax
  802137:	29 c2                	sub    %eax,%edx
  802139:	89 c1                	mov    %eax,%ecx
  80213b:	89 f8                	mov    %edi,%eax
  80213d:	d3 e5                	shl    %cl,%ebp
  80213f:	89 d1                	mov    %edx,%ecx
  802141:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802145:	d3 e8                	shr    %cl,%eax
  802147:	09 c5                	or     %eax,%ebp
  802149:	8b 44 24 04          	mov    0x4(%esp),%eax
  80214d:	89 c1                	mov    %eax,%ecx
  80214f:	d3 e7                	shl    %cl,%edi
  802151:	89 d1                	mov    %edx,%ecx
  802153:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802157:	89 df                	mov    %ebx,%edi
  802159:	d3 ef                	shr    %cl,%edi
  80215b:	89 c1                	mov    %eax,%ecx
  80215d:	89 f0                	mov    %esi,%eax
  80215f:	d3 e3                	shl    %cl,%ebx
  802161:	89 d1                	mov    %edx,%ecx
  802163:	89 fa                	mov    %edi,%edx
  802165:	d3 e8                	shr    %cl,%eax
  802167:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80216c:	09 d8                	or     %ebx,%eax
  80216e:	f7 f5                	div    %ebp
  802170:	d3 e6                	shl    %cl,%esi
  802172:	89 d1                	mov    %edx,%ecx
  802174:	f7 64 24 08          	mull   0x8(%esp)
  802178:	39 d1                	cmp    %edx,%ecx
  80217a:	89 c3                	mov    %eax,%ebx
  80217c:	89 d7                	mov    %edx,%edi
  80217e:	72 06                	jb     802186 <__umoddi3+0xa6>
  802180:	75 0e                	jne    802190 <__umoddi3+0xb0>
  802182:	39 c6                	cmp    %eax,%esi
  802184:	73 0a                	jae    802190 <__umoddi3+0xb0>
  802186:	2b 44 24 08          	sub    0x8(%esp),%eax
  80218a:	19 ea                	sbb    %ebp,%edx
  80218c:	89 d7                	mov    %edx,%edi
  80218e:	89 c3                	mov    %eax,%ebx
  802190:	89 ca                	mov    %ecx,%edx
  802192:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  802197:	29 de                	sub    %ebx,%esi
  802199:	19 fa                	sbb    %edi,%edx
  80219b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80219f:	89 d0                	mov    %edx,%eax
  8021a1:	d3 e0                	shl    %cl,%eax
  8021a3:	89 d9                	mov    %ebx,%ecx
  8021a5:	d3 ee                	shr    %cl,%esi
  8021a7:	d3 ea                	shr    %cl,%edx
  8021a9:	09 f0                	or     %esi,%eax
  8021ab:	83 c4 1c             	add    $0x1c,%esp
  8021ae:	5b                   	pop    %ebx
  8021af:	5e                   	pop    %esi
  8021b0:	5f                   	pop    %edi
  8021b1:	5d                   	pop    %ebp
  8021b2:	c3                   	ret    
  8021b3:	90                   	nop
  8021b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021b8:	85 ff                	test   %edi,%edi
  8021ba:	89 f9                	mov    %edi,%ecx
  8021bc:	75 0b                	jne    8021c9 <__umoddi3+0xe9>
  8021be:	b8 01 00 00 00       	mov    $0x1,%eax
  8021c3:	31 d2                	xor    %edx,%edx
  8021c5:	f7 f7                	div    %edi
  8021c7:	89 c1                	mov    %eax,%ecx
  8021c9:	89 d8                	mov    %ebx,%eax
  8021cb:	31 d2                	xor    %edx,%edx
  8021cd:	f7 f1                	div    %ecx
  8021cf:	89 f0                	mov    %esi,%eax
  8021d1:	f7 f1                	div    %ecx
  8021d3:	e9 31 ff ff ff       	jmp    802109 <__umoddi3+0x29>
  8021d8:	90                   	nop
  8021d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021e0:	39 dd                	cmp    %ebx,%ebp
  8021e2:	72 08                	jb     8021ec <__umoddi3+0x10c>
  8021e4:	39 f7                	cmp    %esi,%edi
  8021e6:	0f 87 21 ff ff ff    	ja     80210d <__umoddi3+0x2d>
  8021ec:	89 da                	mov    %ebx,%edx
  8021ee:	89 f0                	mov    %esi,%eax
  8021f0:	29 f8                	sub    %edi,%eax
  8021f2:	19 ea                	sbb    %ebp,%edx
  8021f4:	e9 14 ff ff ff       	jmp    80210d <__umoddi3+0x2d>
