
obj/user/sendpage.debug:     file format elf32-i386


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
  80002c:	e8 6e 01 00 00       	call   80019f <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#define TEMP_ADDR	((char*)0xa00000)
#define TEMP_ADDR_CHILD	((char*)0xb00000)

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	envid_t who;

	if ((who = fork()) == 0) {
  800039:	e8 53 0f 00 00       	call   800f91 <fork>
  80003e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800041:	85 c0                	test   %eax,%eax
  800043:	0f 85 9e 00 00 00    	jne    8000e7 <umain+0xb4>
		// Child
		ipc_recv(&who, TEMP_ADDR_CHILD, 0);
  800049:	83 ec 04             	sub    $0x4,%esp
  80004c:	6a 00                	push   $0x0
  80004e:	68 00 00 b0 00       	push   $0xb00000
  800053:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800056:	50                   	push   %eax
  800057:	e8 42 11 00 00       	call   80119e <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  80005c:	83 c4 0c             	add    $0xc,%esp
  80005f:	68 00 00 b0 00       	push   $0xb00000
  800064:	ff 75 f4             	pushl  -0xc(%ebp)
  800067:	68 c0 22 80 00       	push   $0x8022c0
  80006c:	e8 23 02 00 00       	call   800294 <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800071:	83 c4 04             	add    $0x4,%esp
  800074:	ff 35 04 30 80 00    	pushl  0x803004
  80007a:	e8 fd 07 00 00       	call   80087c <strlen>
  80007f:	83 c4 0c             	add    $0xc,%esp
  800082:	50                   	push   %eax
  800083:	ff 35 04 30 80 00    	pushl  0x803004
  800089:	68 00 00 b0 00       	push   $0xb00000
  80008e:	e8 ec 08 00 00       	call   80097f <strncmp>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	74 3b                	je     8000d5 <umain+0xa2>
			cprintf("child received correct message\n");

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  80009a:	83 ec 0c             	sub    $0xc,%esp
  80009d:	ff 35 00 30 80 00    	pushl  0x803000
  8000a3:	e8 d4 07 00 00       	call   80087c <strlen>
  8000a8:	83 c4 0c             	add    $0xc,%esp
  8000ab:	83 c0 01             	add    $0x1,%eax
  8000ae:	50                   	push   %eax
  8000af:	ff 35 00 30 80 00    	pushl  0x803000
  8000b5:	68 00 00 b0 00       	push   $0xb00000
  8000ba:	e8 ea 09 00 00       	call   800aa9 <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000bf:	6a 07                	push   $0x7
  8000c1:	68 00 00 b0 00       	push   $0xb00000
  8000c6:	6a 00                	push   $0x0
  8000c8:	ff 75 f4             	pushl  -0xc(%ebp)
  8000cb:	e8 43 11 00 00       	call   801213 <ipc_send>
		return;
  8000d0:	83 c4 20             	add    $0x20,%esp
	ipc_recv(&who, TEMP_ADDR, 0);
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
		cprintf("parent received correct message\n");
	return;
}
  8000d3:	c9                   	leave  
  8000d4:	c3                   	ret    
			cprintf("child received correct message\n");
  8000d5:	83 ec 0c             	sub    $0xc,%esp
  8000d8:	68 d4 22 80 00       	push   $0x8022d4
  8000dd:	e8 b2 01 00 00       	call   800294 <cprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
  8000e5:	eb b3                	jmp    80009a <umain+0x67>
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  8000e7:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ec:	8b 40 48             	mov    0x48(%eax),%eax
  8000ef:	83 ec 04             	sub    $0x4,%esp
  8000f2:	6a 07                	push   $0x7
  8000f4:	68 00 00 a0 00       	push   $0xa00000
  8000f9:	50                   	push   %eax
  8000fa:	e8 ad 0b 00 00       	call   800cac <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  8000ff:	83 c4 04             	add    $0x4,%esp
  800102:	ff 35 04 30 80 00    	pushl  0x803004
  800108:	e8 6f 07 00 00       	call   80087c <strlen>
  80010d:	83 c4 0c             	add    $0xc,%esp
  800110:	83 c0 01             	add    $0x1,%eax
  800113:	50                   	push   %eax
  800114:	ff 35 04 30 80 00    	pushl  0x803004
  80011a:	68 00 00 a0 00       	push   $0xa00000
  80011f:	e8 85 09 00 00       	call   800aa9 <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800124:	6a 07                	push   $0x7
  800126:	68 00 00 a0 00       	push   $0xa00000
  80012b:	6a 00                	push   $0x0
  80012d:	ff 75 f4             	pushl  -0xc(%ebp)
  800130:	e8 de 10 00 00       	call   801213 <ipc_send>
	ipc_recv(&who, TEMP_ADDR, 0);
  800135:	83 c4 1c             	add    $0x1c,%esp
  800138:	6a 00                	push   $0x0
  80013a:	68 00 00 a0 00       	push   $0xa00000
  80013f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800142:	50                   	push   %eax
  800143:	e8 56 10 00 00       	call   80119e <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  800148:	83 c4 0c             	add    $0xc,%esp
  80014b:	68 00 00 a0 00       	push   $0xa00000
  800150:	ff 75 f4             	pushl  -0xc(%ebp)
  800153:	68 c0 22 80 00       	push   $0x8022c0
  800158:	e8 37 01 00 00       	call   800294 <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  80015d:	83 c4 04             	add    $0x4,%esp
  800160:	ff 35 00 30 80 00    	pushl  0x803000
  800166:	e8 11 07 00 00       	call   80087c <strlen>
  80016b:	83 c4 0c             	add    $0xc,%esp
  80016e:	50                   	push   %eax
  80016f:	ff 35 00 30 80 00    	pushl  0x803000
  800175:	68 00 00 a0 00       	push   $0xa00000
  80017a:	e8 00 08 00 00       	call   80097f <strncmp>
  80017f:	83 c4 10             	add    $0x10,%esp
  800182:	85 c0                	test   %eax,%eax
  800184:	0f 85 49 ff ff ff    	jne    8000d3 <umain+0xa0>
		cprintf("parent received correct message\n");
  80018a:	83 ec 0c             	sub    $0xc,%esp
  80018d:	68 f4 22 80 00       	push   $0x8022f4
  800192:	e8 fd 00 00 00       	call   800294 <cprintf>
  800197:	83 c4 10             	add    $0x10,%esp
  80019a:	e9 34 ff ff ff       	jmp    8000d3 <umain+0xa0>

0080019f <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80019f:	55                   	push   %ebp
  8001a0:	89 e5                	mov    %esp,%ebp
  8001a2:	56                   	push   %esi
  8001a3:	53                   	push   %ebx
  8001a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001a7:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001aa:	e8 bf 0a 00 00       	call   800c6e <sys_getenvid>
  8001af:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001b4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001b7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001bc:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001c1:	85 db                	test   %ebx,%ebx
  8001c3:	7e 07                	jle    8001cc <libmain+0x2d>
		binaryname = argv[0];
  8001c5:	8b 06                	mov    (%esi),%eax
  8001c7:	a3 08 30 80 00       	mov    %eax,0x803008

	// call user main routine
	umain(argc, argv);
  8001cc:	83 ec 08             	sub    $0x8,%esp
  8001cf:	56                   	push   %esi
  8001d0:	53                   	push   %ebx
  8001d1:	e8 5d fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001d6:	e8 0a 00 00 00       	call   8001e5 <exit>
}
  8001db:	83 c4 10             	add    $0x10,%esp
  8001de:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001e1:	5b                   	pop    %ebx
  8001e2:	5e                   	pop    %esi
  8001e3:	5d                   	pop    %ebp
  8001e4:	c3                   	ret    

008001e5 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001e5:	55                   	push   %ebp
  8001e6:	89 e5                	mov    %esp,%ebp
  8001e8:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001eb:	e8 88 12 00 00       	call   801478 <close_all>
	sys_env_destroy(0);
  8001f0:	83 ec 0c             	sub    $0xc,%esp
  8001f3:	6a 00                	push   $0x0
  8001f5:	e8 33 0a 00 00       	call   800c2d <sys_env_destroy>
}
  8001fa:	83 c4 10             	add    $0x10,%esp
  8001fd:	c9                   	leave  
  8001fe:	c3                   	ret    

008001ff <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001ff:	55                   	push   %ebp
  800200:	89 e5                	mov    %esp,%ebp
  800202:	53                   	push   %ebx
  800203:	83 ec 04             	sub    $0x4,%esp
  800206:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800209:	8b 13                	mov    (%ebx),%edx
  80020b:	8d 42 01             	lea    0x1(%edx),%eax
  80020e:	89 03                	mov    %eax,(%ebx)
  800210:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800213:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800217:	3d ff 00 00 00       	cmp    $0xff,%eax
  80021c:	74 09                	je     800227 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80021e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800222:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800225:	c9                   	leave  
  800226:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800227:	83 ec 08             	sub    $0x8,%esp
  80022a:	68 ff 00 00 00       	push   $0xff
  80022f:	8d 43 08             	lea    0x8(%ebx),%eax
  800232:	50                   	push   %eax
  800233:	e8 b8 09 00 00       	call   800bf0 <sys_cputs>
		b->idx = 0;
  800238:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80023e:	83 c4 10             	add    $0x10,%esp
  800241:	eb db                	jmp    80021e <putch+0x1f>

00800243 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800243:	55                   	push   %ebp
  800244:	89 e5                	mov    %esp,%ebp
  800246:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80024c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800253:	00 00 00 
	b.cnt = 0;
  800256:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80025d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800260:	ff 75 0c             	pushl  0xc(%ebp)
  800263:	ff 75 08             	pushl  0x8(%ebp)
  800266:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80026c:	50                   	push   %eax
  80026d:	68 ff 01 80 00       	push   $0x8001ff
  800272:	e8 1a 01 00 00       	call   800391 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800277:	83 c4 08             	add    $0x8,%esp
  80027a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800280:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800286:	50                   	push   %eax
  800287:	e8 64 09 00 00       	call   800bf0 <sys_cputs>

	return b.cnt;
}
  80028c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800292:	c9                   	leave  
  800293:	c3                   	ret    

00800294 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800294:	55                   	push   %ebp
  800295:	89 e5                	mov    %esp,%ebp
  800297:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80029a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80029d:	50                   	push   %eax
  80029e:	ff 75 08             	pushl  0x8(%ebp)
  8002a1:	e8 9d ff ff ff       	call   800243 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002a6:	c9                   	leave  
  8002a7:	c3                   	ret    

008002a8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a8:	55                   	push   %ebp
  8002a9:	89 e5                	mov    %esp,%ebp
  8002ab:	57                   	push   %edi
  8002ac:	56                   	push   %esi
  8002ad:	53                   	push   %ebx
  8002ae:	83 ec 1c             	sub    $0x1c,%esp
  8002b1:	89 c7                	mov    %eax,%edi
  8002b3:	89 d6                	mov    %edx,%esi
  8002b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002be:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002c1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002cc:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002cf:	39 d3                	cmp    %edx,%ebx
  8002d1:	72 05                	jb     8002d8 <printnum+0x30>
  8002d3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002d6:	77 7a                	ja     800352 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d8:	83 ec 0c             	sub    $0xc,%esp
  8002db:	ff 75 18             	pushl  0x18(%ebp)
  8002de:	8b 45 14             	mov    0x14(%ebp),%eax
  8002e1:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002e4:	53                   	push   %ebx
  8002e5:	ff 75 10             	pushl  0x10(%ebp)
  8002e8:	83 ec 08             	sub    $0x8,%esp
  8002eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8002f1:	ff 75 dc             	pushl  -0x24(%ebp)
  8002f4:	ff 75 d8             	pushl  -0x28(%ebp)
  8002f7:	e8 74 1d 00 00       	call   802070 <__udivdi3>
  8002fc:	83 c4 18             	add    $0x18,%esp
  8002ff:	52                   	push   %edx
  800300:	50                   	push   %eax
  800301:	89 f2                	mov    %esi,%edx
  800303:	89 f8                	mov    %edi,%eax
  800305:	e8 9e ff ff ff       	call   8002a8 <printnum>
  80030a:	83 c4 20             	add    $0x20,%esp
  80030d:	eb 13                	jmp    800322 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80030f:	83 ec 08             	sub    $0x8,%esp
  800312:	56                   	push   %esi
  800313:	ff 75 18             	pushl  0x18(%ebp)
  800316:	ff d7                	call   *%edi
  800318:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80031b:	83 eb 01             	sub    $0x1,%ebx
  80031e:	85 db                	test   %ebx,%ebx
  800320:	7f ed                	jg     80030f <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800322:	83 ec 08             	sub    $0x8,%esp
  800325:	56                   	push   %esi
  800326:	83 ec 04             	sub    $0x4,%esp
  800329:	ff 75 e4             	pushl  -0x1c(%ebp)
  80032c:	ff 75 e0             	pushl  -0x20(%ebp)
  80032f:	ff 75 dc             	pushl  -0x24(%ebp)
  800332:	ff 75 d8             	pushl  -0x28(%ebp)
  800335:	e8 56 1e 00 00       	call   802190 <__umoddi3>
  80033a:	83 c4 14             	add    $0x14,%esp
  80033d:	0f be 80 6c 23 80 00 	movsbl 0x80236c(%eax),%eax
  800344:	50                   	push   %eax
  800345:	ff d7                	call   *%edi
}
  800347:	83 c4 10             	add    $0x10,%esp
  80034a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034d:	5b                   	pop    %ebx
  80034e:	5e                   	pop    %esi
  80034f:	5f                   	pop    %edi
  800350:	5d                   	pop    %ebp
  800351:	c3                   	ret    
  800352:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800355:	eb c4                	jmp    80031b <printnum+0x73>

00800357 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
  80035a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80035d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800361:	8b 10                	mov    (%eax),%edx
  800363:	3b 50 04             	cmp    0x4(%eax),%edx
  800366:	73 0a                	jae    800372 <sprintputch+0x1b>
		*b->buf++ = ch;
  800368:	8d 4a 01             	lea    0x1(%edx),%ecx
  80036b:	89 08                	mov    %ecx,(%eax)
  80036d:	8b 45 08             	mov    0x8(%ebp),%eax
  800370:	88 02                	mov    %al,(%edx)
}
  800372:	5d                   	pop    %ebp
  800373:	c3                   	ret    

00800374 <printfmt>:
{
  800374:	55                   	push   %ebp
  800375:	89 e5                	mov    %esp,%ebp
  800377:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80037a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80037d:	50                   	push   %eax
  80037e:	ff 75 10             	pushl  0x10(%ebp)
  800381:	ff 75 0c             	pushl  0xc(%ebp)
  800384:	ff 75 08             	pushl  0x8(%ebp)
  800387:	e8 05 00 00 00       	call   800391 <vprintfmt>
}
  80038c:	83 c4 10             	add    $0x10,%esp
  80038f:	c9                   	leave  
  800390:	c3                   	ret    

00800391 <vprintfmt>:
{
  800391:	55                   	push   %ebp
  800392:	89 e5                	mov    %esp,%ebp
  800394:	57                   	push   %edi
  800395:	56                   	push   %esi
  800396:	53                   	push   %ebx
  800397:	83 ec 2c             	sub    $0x2c,%esp
  80039a:	8b 75 08             	mov    0x8(%ebp),%esi
  80039d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003a0:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003a3:	e9 c1 03 00 00       	jmp    800769 <vprintfmt+0x3d8>
		padc = ' ';
  8003a8:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8003ac:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8003b3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8003ba:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003c1:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003c6:	8d 47 01             	lea    0x1(%edi),%eax
  8003c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003cc:	0f b6 17             	movzbl (%edi),%edx
  8003cf:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003d2:	3c 55                	cmp    $0x55,%al
  8003d4:	0f 87 12 04 00 00    	ja     8007ec <vprintfmt+0x45b>
  8003da:	0f b6 c0             	movzbl %al,%eax
  8003dd:	ff 24 85 a0 24 80 00 	jmp    *0x8024a0(,%eax,4)
  8003e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8003e7:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8003eb:	eb d9                	jmp    8003c6 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8003ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  8003f0:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003f4:	eb d0                	jmp    8003c6 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8003f6:	0f b6 d2             	movzbl %dl,%edx
  8003f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800401:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800404:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800407:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80040b:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80040e:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800411:	83 f9 09             	cmp    $0x9,%ecx
  800414:	77 55                	ja     80046b <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800416:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800419:	eb e9                	jmp    800404 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  80041b:	8b 45 14             	mov    0x14(%ebp),%eax
  80041e:	8b 00                	mov    (%eax),%eax
  800420:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800423:	8b 45 14             	mov    0x14(%ebp),%eax
  800426:	8d 40 04             	lea    0x4(%eax),%eax
  800429:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80042c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80042f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800433:	79 91                	jns    8003c6 <vprintfmt+0x35>
				width = precision, precision = -1;
  800435:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800438:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80043b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800442:	eb 82                	jmp    8003c6 <vprintfmt+0x35>
  800444:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800447:	85 c0                	test   %eax,%eax
  800449:	ba 00 00 00 00       	mov    $0x0,%edx
  80044e:	0f 49 d0             	cmovns %eax,%edx
  800451:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800454:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800457:	e9 6a ff ff ff       	jmp    8003c6 <vprintfmt+0x35>
  80045c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80045f:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800466:	e9 5b ff ff ff       	jmp    8003c6 <vprintfmt+0x35>
  80046b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80046e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800471:	eb bc                	jmp    80042f <vprintfmt+0x9e>
			lflag++;
  800473:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800476:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800479:	e9 48 ff ff ff       	jmp    8003c6 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  80047e:	8b 45 14             	mov    0x14(%ebp),%eax
  800481:	8d 78 04             	lea    0x4(%eax),%edi
  800484:	83 ec 08             	sub    $0x8,%esp
  800487:	53                   	push   %ebx
  800488:	ff 30                	pushl  (%eax)
  80048a:	ff d6                	call   *%esi
			break;
  80048c:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80048f:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800492:	e9 cf 02 00 00       	jmp    800766 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  800497:	8b 45 14             	mov    0x14(%ebp),%eax
  80049a:	8d 78 04             	lea    0x4(%eax),%edi
  80049d:	8b 00                	mov    (%eax),%eax
  80049f:	99                   	cltd   
  8004a0:	31 d0                	xor    %edx,%eax
  8004a2:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004a4:	83 f8 0f             	cmp    $0xf,%eax
  8004a7:	7f 23                	jg     8004cc <vprintfmt+0x13b>
  8004a9:	8b 14 85 00 26 80 00 	mov    0x802600(,%eax,4),%edx
  8004b0:	85 d2                	test   %edx,%edx
  8004b2:	74 18                	je     8004cc <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8004b4:	52                   	push   %edx
  8004b5:	68 99 28 80 00       	push   $0x802899
  8004ba:	53                   	push   %ebx
  8004bb:	56                   	push   %esi
  8004bc:	e8 b3 fe ff ff       	call   800374 <printfmt>
  8004c1:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004c4:	89 7d 14             	mov    %edi,0x14(%ebp)
  8004c7:	e9 9a 02 00 00       	jmp    800766 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  8004cc:	50                   	push   %eax
  8004cd:	68 84 23 80 00       	push   $0x802384
  8004d2:	53                   	push   %ebx
  8004d3:	56                   	push   %esi
  8004d4:	e8 9b fe ff ff       	call   800374 <printfmt>
  8004d9:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004dc:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8004df:	e9 82 02 00 00       	jmp    800766 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  8004e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e7:	83 c0 04             	add    $0x4,%eax
  8004ea:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8004ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f0:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004f2:	85 ff                	test   %edi,%edi
  8004f4:	b8 7d 23 80 00       	mov    $0x80237d,%eax
  8004f9:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004fc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800500:	0f 8e bd 00 00 00    	jle    8005c3 <vprintfmt+0x232>
  800506:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80050a:	75 0e                	jne    80051a <vprintfmt+0x189>
  80050c:	89 75 08             	mov    %esi,0x8(%ebp)
  80050f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800512:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800515:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800518:	eb 6d                	jmp    800587 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  80051a:	83 ec 08             	sub    $0x8,%esp
  80051d:	ff 75 d0             	pushl  -0x30(%ebp)
  800520:	57                   	push   %edi
  800521:	e8 6e 03 00 00       	call   800894 <strnlen>
  800526:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800529:	29 c1                	sub    %eax,%ecx
  80052b:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80052e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800531:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800535:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800538:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80053b:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  80053d:	eb 0f                	jmp    80054e <vprintfmt+0x1bd>
					putch(padc, putdat);
  80053f:	83 ec 08             	sub    $0x8,%esp
  800542:	53                   	push   %ebx
  800543:	ff 75 e0             	pushl  -0x20(%ebp)
  800546:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800548:	83 ef 01             	sub    $0x1,%edi
  80054b:	83 c4 10             	add    $0x10,%esp
  80054e:	85 ff                	test   %edi,%edi
  800550:	7f ed                	jg     80053f <vprintfmt+0x1ae>
  800552:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800555:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800558:	85 c9                	test   %ecx,%ecx
  80055a:	b8 00 00 00 00       	mov    $0x0,%eax
  80055f:	0f 49 c1             	cmovns %ecx,%eax
  800562:	29 c1                	sub    %eax,%ecx
  800564:	89 75 08             	mov    %esi,0x8(%ebp)
  800567:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80056a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80056d:	89 cb                	mov    %ecx,%ebx
  80056f:	eb 16                	jmp    800587 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  800571:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800575:	75 31                	jne    8005a8 <vprintfmt+0x217>
					putch(ch, putdat);
  800577:	83 ec 08             	sub    $0x8,%esp
  80057a:	ff 75 0c             	pushl  0xc(%ebp)
  80057d:	50                   	push   %eax
  80057e:	ff 55 08             	call   *0x8(%ebp)
  800581:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800584:	83 eb 01             	sub    $0x1,%ebx
  800587:	83 c7 01             	add    $0x1,%edi
  80058a:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  80058e:	0f be c2             	movsbl %dl,%eax
  800591:	85 c0                	test   %eax,%eax
  800593:	74 59                	je     8005ee <vprintfmt+0x25d>
  800595:	85 f6                	test   %esi,%esi
  800597:	78 d8                	js     800571 <vprintfmt+0x1e0>
  800599:	83 ee 01             	sub    $0x1,%esi
  80059c:	79 d3                	jns    800571 <vprintfmt+0x1e0>
  80059e:	89 df                	mov    %ebx,%edi
  8005a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a6:	eb 37                	jmp    8005df <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8005a8:	0f be d2             	movsbl %dl,%edx
  8005ab:	83 ea 20             	sub    $0x20,%edx
  8005ae:	83 fa 5e             	cmp    $0x5e,%edx
  8005b1:	76 c4                	jbe    800577 <vprintfmt+0x1e6>
					putch('?', putdat);
  8005b3:	83 ec 08             	sub    $0x8,%esp
  8005b6:	ff 75 0c             	pushl  0xc(%ebp)
  8005b9:	6a 3f                	push   $0x3f
  8005bb:	ff 55 08             	call   *0x8(%ebp)
  8005be:	83 c4 10             	add    $0x10,%esp
  8005c1:	eb c1                	jmp    800584 <vprintfmt+0x1f3>
  8005c3:	89 75 08             	mov    %esi,0x8(%ebp)
  8005c6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005c9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005cc:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005cf:	eb b6                	jmp    800587 <vprintfmt+0x1f6>
				putch(' ', putdat);
  8005d1:	83 ec 08             	sub    $0x8,%esp
  8005d4:	53                   	push   %ebx
  8005d5:	6a 20                	push   $0x20
  8005d7:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8005d9:	83 ef 01             	sub    $0x1,%edi
  8005dc:	83 c4 10             	add    $0x10,%esp
  8005df:	85 ff                	test   %edi,%edi
  8005e1:	7f ee                	jg     8005d1 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  8005e3:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005e6:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e9:	e9 78 01 00 00       	jmp    800766 <vprintfmt+0x3d5>
  8005ee:	89 df                	mov    %ebx,%edi
  8005f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8005f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005f6:	eb e7                	jmp    8005df <vprintfmt+0x24e>
	if (lflag >= 2)
  8005f8:	83 f9 01             	cmp    $0x1,%ecx
  8005fb:	7e 3f                	jle    80063c <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  8005fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800600:	8b 50 04             	mov    0x4(%eax),%edx
  800603:	8b 00                	mov    (%eax),%eax
  800605:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800608:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80060b:	8b 45 14             	mov    0x14(%ebp),%eax
  80060e:	8d 40 08             	lea    0x8(%eax),%eax
  800611:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800614:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800618:	79 5c                	jns    800676 <vprintfmt+0x2e5>
				putch('-', putdat);
  80061a:	83 ec 08             	sub    $0x8,%esp
  80061d:	53                   	push   %ebx
  80061e:	6a 2d                	push   $0x2d
  800620:	ff d6                	call   *%esi
				num = -(long long) num;
  800622:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800625:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800628:	f7 da                	neg    %edx
  80062a:	83 d1 00             	adc    $0x0,%ecx
  80062d:	f7 d9                	neg    %ecx
  80062f:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800632:	b8 0a 00 00 00       	mov    $0xa,%eax
  800637:	e9 10 01 00 00       	jmp    80074c <vprintfmt+0x3bb>
	else if (lflag)
  80063c:	85 c9                	test   %ecx,%ecx
  80063e:	75 1b                	jne    80065b <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800640:	8b 45 14             	mov    0x14(%ebp),%eax
  800643:	8b 00                	mov    (%eax),%eax
  800645:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800648:	89 c1                	mov    %eax,%ecx
  80064a:	c1 f9 1f             	sar    $0x1f,%ecx
  80064d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800650:	8b 45 14             	mov    0x14(%ebp),%eax
  800653:	8d 40 04             	lea    0x4(%eax),%eax
  800656:	89 45 14             	mov    %eax,0x14(%ebp)
  800659:	eb b9                	jmp    800614 <vprintfmt+0x283>
		return va_arg(*ap, long);
  80065b:	8b 45 14             	mov    0x14(%ebp),%eax
  80065e:	8b 00                	mov    (%eax),%eax
  800660:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800663:	89 c1                	mov    %eax,%ecx
  800665:	c1 f9 1f             	sar    $0x1f,%ecx
  800668:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80066b:	8b 45 14             	mov    0x14(%ebp),%eax
  80066e:	8d 40 04             	lea    0x4(%eax),%eax
  800671:	89 45 14             	mov    %eax,0x14(%ebp)
  800674:	eb 9e                	jmp    800614 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  800676:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800679:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80067c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800681:	e9 c6 00 00 00       	jmp    80074c <vprintfmt+0x3bb>
	if (lflag >= 2)
  800686:	83 f9 01             	cmp    $0x1,%ecx
  800689:	7e 18                	jle    8006a3 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  80068b:	8b 45 14             	mov    0x14(%ebp),%eax
  80068e:	8b 10                	mov    (%eax),%edx
  800690:	8b 48 04             	mov    0x4(%eax),%ecx
  800693:	8d 40 08             	lea    0x8(%eax),%eax
  800696:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800699:	b8 0a 00 00 00       	mov    $0xa,%eax
  80069e:	e9 a9 00 00 00       	jmp    80074c <vprintfmt+0x3bb>
	else if (lflag)
  8006a3:	85 c9                	test   %ecx,%ecx
  8006a5:	75 1a                	jne    8006c1 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  8006a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006aa:	8b 10                	mov    (%eax),%edx
  8006ac:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b1:	8d 40 04             	lea    0x4(%eax),%eax
  8006b4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006b7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006bc:	e9 8b 00 00 00       	jmp    80074c <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8006c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c4:	8b 10                	mov    (%eax),%edx
  8006c6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006cb:	8d 40 04             	lea    0x4(%eax),%eax
  8006ce:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006d1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006d6:	eb 74                	jmp    80074c <vprintfmt+0x3bb>
	if (lflag >= 2)
  8006d8:	83 f9 01             	cmp    $0x1,%ecx
  8006db:	7e 15                	jle    8006f2 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  8006dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e0:	8b 10                	mov    (%eax),%edx
  8006e2:	8b 48 04             	mov    0x4(%eax),%ecx
  8006e5:	8d 40 08             	lea    0x8(%eax),%eax
  8006e8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006eb:	b8 08 00 00 00       	mov    $0x8,%eax
  8006f0:	eb 5a                	jmp    80074c <vprintfmt+0x3bb>
	else if (lflag)
  8006f2:	85 c9                	test   %ecx,%ecx
  8006f4:	75 17                	jne    80070d <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  8006f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f9:	8b 10                	mov    (%eax),%edx
  8006fb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800700:	8d 40 04             	lea    0x4(%eax),%eax
  800703:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800706:	b8 08 00 00 00       	mov    $0x8,%eax
  80070b:	eb 3f                	jmp    80074c <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80070d:	8b 45 14             	mov    0x14(%ebp),%eax
  800710:	8b 10                	mov    (%eax),%edx
  800712:	b9 00 00 00 00       	mov    $0x0,%ecx
  800717:	8d 40 04             	lea    0x4(%eax),%eax
  80071a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80071d:	b8 08 00 00 00       	mov    $0x8,%eax
  800722:	eb 28                	jmp    80074c <vprintfmt+0x3bb>
			putch('0', putdat);
  800724:	83 ec 08             	sub    $0x8,%esp
  800727:	53                   	push   %ebx
  800728:	6a 30                	push   $0x30
  80072a:	ff d6                	call   *%esi
			putch('x', putdat);
  80072c:	83 c4 08             	add    $0x8,%esp
  80072f:	53                   	push   %ebx
  800730:	6a 78                	push   $0x78
  800732:	ff d6                	call   *%esi
			num = (unsigned long long)
  800734:	8b 45 14             	mov    0x14(%ebp),%eax
  800737:	8b 10                	mov    (%eax),%edx
  800739:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80073e:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800741:	8d 40 04             	lea    0x4(%eax),%eax
  800744:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800747:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80074c:	83 ec 0c             	sub    $0xc,%esp
  80074f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800753:	57                   	push   %edi
  800754:	ff 75 e0             	pushl  -0x20(%ebp)
  800757:	50                   	push   %eax
  800758:	51                   	push   %ecx
  800759:	52                   	push   %edx
  80075a:	89 da                	mov    %ebx,%edx
  80075c:	89 f0                	mov    %esi,%eax
  80075e:	e8 45 fb ff ff       	call   8002a8 <printnum>
			break;
  800763:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800766:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800769:	83 c7 01             	add    $0x1,%edi
  80076c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800770:	83 f8 25             	cmp    $0x25,%eax
  800773:	0f 84 2f fc ff ff    	je     8003a8 <vprintfmt+0x17>
			if (ch == '\0')
  800779:	85 c0                	test   %eax,%eax
  80077b:	0f 84 8b 00 00 00    	je     80080c <vprintfmt+0x47b>
			putch(ch, putdat);
  800781:	83 ec 08             	sub    $0x8,%esp
  800784:	53                   	push   %ebx
  800785:	50                   	push   %eax
  800786:	ff d6                	call   *%esi
  800788:	83 c4 10             	add    $0x10,%esp
  80078b:	eb dc                	jmp    800769 <vprintfmt+0x3d8>
	if (lflag >= 2)
  80078d:	83 f9 01             	cmp    $0x1,%ecx
  800790:	7e 15                	jle    8007a7 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  800792:	8b 45 14             	mov    0x14(%ebp),%eax
  800795:	8b 10                	mov    (%eax),%edx
  800797:	8b 48 04             	mov    0x4(%eax),%ecx
  80079a:	8d 40 08             	lea    0x8(%eax),%eax
  80079d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007a0:	b8 10 00 00 00       	mov    $0x10,%eax
  8007a5:	eb a5                	jmp    80074c <vprintfmt+0x3bb>
	else if (lflag)
  8007a7:	85 c9                	test   %ecx,%ecx
  8007a9:	75 17                	jne    8007c2 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  8007ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ae:	8b 10                	mov    (%eax),%edx
  8007b0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007b5:	8d 40 04             	lea    0x4(%eax),%eax
  8007b8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007bb:	b8 10 00 00 00       	mov    $0x10,%eax
  8007c0:	eb 8a                	jmp    80074c <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8007c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c5:	8b 10                	mov    (%eax),%edx
  8007c7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007cc:	8d 40 04             	lea    0x4(%eax),%eax
  8007cf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007d2:	b8 10 00 00 00       	mov    $0x10,%eax
  8007d7:	e9 70 ff ff ff       	jmp    80074c <vprintfmt+0x3bb>
			putch(ch, putdat);
  8007dc:	83 ec 08             	sub    $0x8,%esp
  8007df:	53                   	push   %ebx
  8007e0:	6a 25                	push   $0x25
  8007e2:	ff d6                	call   *%esi
			break;
  8007e4:	83 c4 10             	add    $0x10,%esp
  8007e7:	e9 7a ff ff ff       	jmp    800766 <vprintfmt+0x3d5>
			putch('%', putdat);
  8007ec:	83 ec 08             	sub    $0x8,%esp
  8007ef:	53                   	push   %ebx
  8007f0:	6a 25                	push   $0x25
  8007f2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007f4:	83 c4 10             	add    $0x10,%esp
  8007f7:	89 f8                	mov    %edi,%eax
  8007f9:	eb 03                	jmp    8007fe <vprintfmt+0x46d>
  8007fb:	83 e8 01             	sub    $0x1,%eax
  8007fe:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800802:	75 f7                	jne    8007fb <vprintfmt+0x46a>
  800804:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800807:	e9 5a ff ff ff       	jmp    800766 <vprintfmt+0x3d5>
}
  80080c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80080f:	5b                   	pop    %ebx
  800810:	5e                   	pop    %esi
  800811:	5f                   	pop    %edi
  800812:	5d                   	pop    %ebp
  800813:	c3                   	ret    

00800814 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800814:	55                   	push   %ebp
  800815:	89 e5                	mov    %esp,%ebp
  800817:	83 ec 18             	sub    $0x18,%esp
  80081a:	8b 45 08             	mov    0x8(%ebp),%eax
  80081d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800820:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800823:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800827:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80082a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800831:	85 c0                	test   %eax,%eax
  800833:	74 26                	je     80085b <vsnprintf+0x47>
  800835:	85 d2                	test   %edx,%edx
  800837:	7e 22                	jle    80085b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800839:	ff 75 14             	pushl  0x14(%ebp)
  80083c:	ff 75 10             	pushl  0x10(%ebp)
  80083f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800842:	50                   	push   %eax
  800843:	68 57 03 80 00       	push   $0x800357
  800848:	e8 44 fb ff ff       	call   800391 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80084d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800850:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800853:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800856:	83 c4 10             	add    $0x10,%esp
}
  800859:	c9                   	leave  
  80085a:	c3                   	ret    
		return -E_INVAL;
  80085b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800860:	eb f7                	jmp    800859 <vsnprintf+0x45>

00800862 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800868:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80086b:	50                   	push   %eax
  80086c:	ff 75 10             	pushl  0x10(%ebp)
  80086f:	ff 75 0c             	pushl  0xc(%ebp)
  800872:	ff 75 08             	pushl  0x8(%ebp)
  800875:	e8 9a ff ff ff       	call   800814 <vsnprintf>
	va_end(ap);

	return rc;
}
  80087a:	c9                   	leave  
  80087b:	c3                   	ret    

0080087c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800882:	b8 00 00 00 00       	mov    $0x0,%eax
  800887:	eb 03                	jmp    80088c <strlen+0x10>
		n++;
  800889:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80088c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800890:	75 f7                	jne    800889 <strlen+0xd>
	return n;
}
  800892:	5d                   	pop    %ebp
  800893:	c3                   	ret    

00800894 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80089a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80089d:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a2:	eb 03                	jmp    8008a7 <strnlen+0x13>
		n++;
  8008a4:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008a7:	39 d0                	cmp    %edx,%eax
  8008a9:	74 06                	je     8008b1 <strnlen+0x1d>
  8008ab:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008af:	75 f3                	jne    8008a4 <strnlen+0x10>
	return n;
}
  8008b1:	5d                   	pop    %ebp
  8008b2:	c3                   	ret    

008008b3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008b3:	55                   	push   %ebp
  8008b4:	89 e5                	mov    %esp,%ebp
  8008b6:	53                   	push   %ebx
  8008b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008bd:	89 c2                	mov    %eax,%edx
  8008bf:	83 c1 01             	add    $0x1,%ecx
  8008c2:	83 c2 01             	add    $0x1,%edx
  8008c5:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008c9:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008cc:	84 db                	test   %bl,%bl
  8008ce:	75 ef                	jne    8008bf <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008d0:	5b                   	pop    %ebx
  8008d1:	5d                   	pop    %ebp
  8008d2:	c3                   	ret    

008008d3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008d3:	55                   	push   %ebp
  8008d4:	89 e5                	mov    %esp,%ebp
  8008d6:	53                   	push   %ebx
  8008d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008da:	53                   	push   %ebx
  8008db:	e8 9c ff ff ff       	call   80087c <strlen>
  8008e0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008e3:	ff 75 0c             	pushl  0xc(%ebp)
  8008e6:	01 d8                	add    %ebx,%eax
  8008e8:	50                   	push   %eax
  8008e9:	e8 c5 ff ff ff       	call   8008b3 <strcpy>
	return dst;
}
  8008ee:	89 d8                	mov    %ebx,%eax
  8008f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008f3:	c9                   	leave  
  8008f4:	c3                   	ret    

008008f5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	56                   	push   %esi
  8008f9:	53                   	push   %ebx
  8008fa:	8b 75 08             	mov    0x8(%ebp),%esi
  8008fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800900:	89 f3                	mov    %esi,%ebx
  800902:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800905:	89 f2                	mov    %esi,%edx
  800907:	eb 0f                	jmp    800918 <strncpy+0x23>
		*dst++ = *src;
  800909:	83 c2 01             	add    $0x1,%edx
  80090c:	0f b6 01             	movzbl (%ecx),%eax
  80090f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800912:	80 39 01             	cmpb   $0x1,(%ecx)
  800915:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800918:	39 da                	cmp    %ebx,%edx
  80091a:	75 ed                	jne    800909 <strncpy+0x14>
	}
	return ret;
}
  80091c:	89 f0                	mov    %esi,%eax
  80091e:	5b                   	pop    %ebx
  80091f:	5e                   	pop    %esi
  800920:	5d                   	pop    %ebp
  800921:	c3                   	ret    

00800922 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	56                   	push   %esi
  800926:	53                   	push   %ebx
  800927:	8b 75 08             	mov    0x8(%ebp),%esi
  80092a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800930:	89 f0                	mov    %esi,%eax
  800932:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800936:	85 c9                	test   %ecx,%ecx
  800938:	75 0b                	jne    800945 <strlcpy+0x23>
  80093a:	eb 17                	jmp    800953 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80093c:	83 c2 01             	add    $0x1,%edx
  80093f:	83 c0 01             	add    $0x1,%eax
  800942:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800945:	39 d8                	cmp    %ebx,%eax
  800947:	74 07                	je     800950 <strlcpy+0x2e>
  800949:	0f b6 0a             	movzbl (%edx),%ecx
  80094c:	84 c9                	test   %cl,%cl
  80094e:	75 ec                	jne    80093c <strlcpy+0x1a>
		*dst = '\0';
  800950:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800953:	29 f0                	sub    %esi,%eax
}
  800955:	5b                   	pop    %ebx
  800956:	5e                   	pop    %esi
  800957:	5d                   	pop    %ebp
  800958:	c3                   	ret    

00800959 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800959:	55                   	push   %ebp
  80095a:	89 e5                	mov    %esp,%ebp
  80095c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80095f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800962:	eb 06                	jmp    80096a <strcmp+0x11>
		p++, q++;
  800964:	83 c1 01             	add    $0x1,%ecx
  800967:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80096a:	0f b6 01             	movzbl (%ecx),%eax
  80096d:	84 c0                	test   %al,%al
  80096f:	74 04                	je     800975 <strcmp+0x1c>
  800971:	3a 02                	cmp    (%edx),%al
  800973:	74 ef                	je     800964 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800975:	0f b6 c0             	movzbl %al,%eax
  800978:	0f b6 12             	movzbl (%edx),%edx
  80097b:	29 d0                	sub    %edx,%eax
}
  80097d:	5d                   	pop    %ebp
  80097e:	c3                   	ret    

0080097f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	53                   	push   %ebx
  800983:	8b 45 08             	mov    0x8(%ebp),%eax
  800986:	8b 55 0c             	mov    0xc(%ebp),%edx
  800989:	89 c3                	mov    %eax,%ebx
  80098b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80098e:	eb 06                	jmp    800996 <strncmp+0x17>
		n--, p++, q++;
  800990:	83 c0 01             	add    $0x1,%eax
  800993:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800996:	39 d8                	cmp    %ebx,%eax
  800998:	74 16                	je     8009b0 <strncmp+0x31>
  80099a:	0f b6 08             	movzbl (%eax),%ecx
  80099d:	84 c9                	test   %cl,%cl
  80099f:	74 04                	je     8009a5 <strncmp+0x26>
  8009a1:	3a 0a                	cmp    (%edx),%cl
  8009a3:	74 eb                	je     800990 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a5:	0f b6 00             	movzbl (%eax),%eax
  8009a8:	0f b6 12             	movzbl (%edx),%edx
  8009ab:	29 d0                	sub    %edx,%eax
}
  8009ad:	5b                   	pop    %ebx
  8009ae:	5d                   	pop    %ebp
  8009af:	c3                   	ret    
		return 0;
  8009b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b5:	eb f6                	jmp    8009ad <strncmp+0x2e>

008009b7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c1:	0f b6 10             	movzbl (%eax),%edx
  8009c4:	84 d2                	test   %dl,%dl
  8009c6:	74 09                	je     8009d1 <strchr+0x1a>
		if (*s == c)
  8009c8:	38 ca                	cmp    %cl,%dl
  8009ca:	74 0a                	je     8009d6 <strchr+0x1f>
	for (; *s; s++)
  8009cc:	83 c0 01             	add    $0x1,%eax
  8009cf:	eb f0                	jmp    8009c1 <strchr+0xa>
			return (char *) s;
	return 0;
  8009d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d6:	5d                   	pop    %ebp
  8009d7:	c3                   	ret    

008009d8 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009d8:	55                   	push   %ebp
  8009d9:	89 e5                	mov    %esp,%ebp
  8009db:	8b 45 08             	mov    0x8(%ebp),%eax
  8009de:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009e2:	eb 03                	jmp    8009e7 <strfind+0xf>
  8009e4:	83 c0 01             	add    $0x1,%eax
  8009e7:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009ea:	38 ca                	cmp    %cl,%dl
  8009ec:	74 04                	je     8009f2 <strfind+0x1a>
  8009ee:	84 d2                	test   %dl,%dl
  8009f0:	75 f2                	jne    8009e4 <strfind+0xc>
			break;
	return (char *) s;
}
  8009f2:	5d                   	pop    %ebp
  8009f3:	c3                   	ret    

008009f4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009f4:	55                   	push   %ebp
  8009f5:	89 e5                	mov    %esp,%ebp
  8009f7:	57                   	push   %edi
  8009f8:	56                   	push   %esi
  8009f9:	53                   	push   %ebx
  8009fa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009fd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a00:	85 c9                	test   %ecx,%ecx
  800a02:	74 13                	je     800a17 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a04:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a0a:	75 05                	jne    800a11 <memset+0x1d>
  800a0c:	f6 c1 03             	test   $0x3,%cl
  800a0f:	74 0d                	je     800a1e <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a11:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a14:	fc                   	cld    
  800a15:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a17:	89 f8                	mov    %edi,%eax
  800a19:	5b                   	pop    %ebx
  800a1a:	5e                   	pop    %esi
  800a1b:	5f                   	pop    %edi
  800a1c:	5d                   	pop    %ebp
  800a1d:	c3                   	ret    
		c &= 0xFF;
  800a1e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a22:	89 d3                	mov    %edx,%ebx
  800a24:	c1 e3 08             	shl    $0x8,%ebx
  800a27:	89 d0                	mov    %edx,%eax
  800a29:	c1 e0 18             	shl    $0x18,%eax
  800a2c:	89 d6                	mov    %edx,%esi
  800a2e:	c1 e6 10             	shl    $0x10,%esi
  800a31:	09 f0                	or     %esi,%eax
  800a33:	09 c2                	or     %eax,%edx
  800a35:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800a37:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a3a:	89 d0                	mov    %edx,%eax
  800a3c:	fc                   	cld    
  800a3d:	f3 ab                	rep stos %eax,%es:(%edi)
  800a3f:	eb d6                	jmp    800a17 <memset+0x23>

00800a41 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
  800a44:	57                   	push   %edi
  800a45:	56                   	push   %esi
  800a46:	8b 45 08             	mov    0x8(%ebp),%eax
  800a49:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a4c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a4f:	39 c6                	cmp    %eax,%esi
  800a51:	73 35                	jae    800a88 <memmove+0x47>
  800a53:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a56:	39 c2                	cmp    %eax,%edx
  800a58:	76 2e                	jbe    800a88 <memmove+0x47>
		s += n;
		d += n;
  800a5a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a5d:	89 d6                	mov    %edx,%esi
  800a5f:	09 fe                	or     %edi,%esi
  800a61:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a67:	74 0c                	je     800a75 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a69:	83 ef 01             	sub    $0x1,%edi
  800a6c:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a6f:	fd                   	std    
  800a70:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a72:	fc                   	cld    
  800a73:	eb 21                	jmp    800a96 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a75:	f6 c1 03             	test   $0x3,%cl
  800a78:	75 ef                	jne    800a69 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a7a:	83 ef 04             	sub    $0x4,%edi
  800a7d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a80:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a83:	fd                   	std    
  800a84:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a86:	eb ea                	jmp    800a72 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a88:	89 f2                	mov    %esi,%edx
  800a8a:	09 c2                	or     %eax,%edx
  800a8c:	f6 c2 03             	test   $0x3,%dl
  800a8f:	74 09                	je     800a9a <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a91:	89 c7                	mov    %eax,%edi
  800a93:	fc                   	cld    
  800a94:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a96:	5e                   	pop    %esi
  800a97:	5f                   	pop    %edi
  800a98:	5d                   	pop    %ebp
  800a99:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a9a:	f6 c1 03             	test   $0x3,%cl
  800a9d:	75 f2                	jne    800a91 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a9f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800aa2:	89 c7                	mov    %eax,%edi
  800aa4:	fc                   	cld    
  800aa5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa7:	eb ed                	jmp    800a96 <memmove+0x55>

00800aa9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aa9:	55                   	push   %ebp
  800aaa:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800aac:	ff 75 10             	pushl  0x10(%ebp)
  800aaf:	ff 75 0c             	pushl  0xc(%ebp)
  800ab2:	ff 75 08             	pushl  0x8(%ebp)
  800ab5:	e8 87 ff ff ff       	call   800a41 <memmove>
}
  800aba:	c9                   	leave  
  800abb:	c3                   	ret    

00800abc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	56                   	push   %esi
  800ac0:	53                   	push   %ebx
  800ac1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ac7:	89 c6                	mov    %eax,%esi
  800ac9:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800acc:	39 f0                	cmp    %esi,%eax
  800ace:	74 1c                	je     800aec <memcmp+0x30>
		if (*s1 != *s2)
  800ad0:	0f b6 08             	movzbl (%eax),%ecx
  800ad3:	0f b6 1a             	movzbl (%edx),%ebx
  800ad6:	38 d9                	cmp    %bl,%cl
  800ad8:	75 08                	jne    800ae2 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ada:	83 c0 01             	add    $0x1,%eax
  800add:	83 c2 01             	add    $0x1,%edx
  800ae0:	eb ea                	jmp    800acc <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800ae2:	0f b6 c1             	movzbl %cl,%eax
  800ae5:	0f b6 db             	movzbl %bl,%ebx
  800ae8:	29 d8                	sub    %ebx,%eax
  800aea:	eb 05                	jmp    800af1 <memcmp+0x35>
	}

	return 0;
  800aec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af1:	5b                   	pop    %ebx
  800af2:	5e                   	pop    %esi
  800af3:	5d                   	pop    %ebp
  800af4:	c3                   	ret    

00800af5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800af5:	55                   	push   %ebp
  800af6:	89 e5                	mov    %esp,%ebp
  800af8:	8b 45 08             	mov    0x8(%ebp),%eax
  800afb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800afe:	89 c2                	mov    %eax,%edx
  800b00:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b03:	39 d0                	cmp    %edx,%eax
  800b05:	73 09                	jae    800b10 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b07:	38 08                	cmp    %cl,(%eax)
  800b09:	74 05                	je     800b10 <memfind+0x1b>
	for (; s < ends; s++)
  800b0b:	83 c0 01             	add    $0x1,%eax
  800b0e:	eb f3                	jmp    800b03 <memfind+0xe>
			break;
	return (void *) s;
}
  800b10:	5d                   	pop    %ebp
  800b11:	c3                   	ret    

00800b12 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b12:	55                   	push   %ebp
  800b13:	89 e5                	mov    %esp,%ebp
  800b15:	57                   	push   %edi
  800b16:	56                   	push   %esi
  800b17:	53                   	push   %ebx
  800b18:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b1e:	eb 03                	jmp    800b23 <strtol+0x11>
		s++;
  800b20:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b23:	0f b6 01             	movzbl (%ecx),%eax
  800b26:	3c 20                	cmp    $0x20,%al
  800b28:	74 f6                	je     800b20 <strtol+0xe>
  800b2a:	3c 09                	cmp    $0x9,%al
  800b2c:	74 f2                	je     800b20 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b2e:	3c 2b                	cmp    $0x2b,%al
  800b30:	74 2e                	je     800b60 <strtol+0x4e>
	int neg = 0;
  800b32:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b37:	3c 2d                	cmp    $0x2d,%al
  800b39:	74 2f                	je     800b6a <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b3b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b41:	75 05                	jne    800b48 <strtol+0x36>
  800b43:	80 39 30             	cmpb   $0x30,(%ecx)
  800b46:	74 2c                	je     800b74 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b48:	85 db                	test   %ebx,%ebx
  800b4a:	75 0a                	jne    800b56 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b4c:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800b51:	80 39 30             	cmpb   $0x30,(%ecx)
  800b54:	74 28                	je     800b7e <strtol+0x6c>
		base = 10;
  800b56:	b8 00 00 00 00       	mov    $0x0,%eax
  800b5b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b5e:	eb 50                	jmp    800bb0 <strtol+0x9e>
		s++;
  800b60:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b63:	bf 00 00 00 00       	mov    $0x0,%edi
  800b68:	eb d1                	jmp    800b3b <strtol+0x29>
		s++, neg = 1;
  800b6a:	83 c1 01             	add    $0x1,%ecx
  800b6d:	bf 01 00 00 00       	mov    $0x1,%edi
  800b72:	eb c7                	jmp    800b3b <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b74:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b78:	74 0e                	je     800b88 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b7a:	85 db                	test   %ebx,%ebx
  800b7c:	75 d8                	jne    800b56 <strtol+0x44>
		s++, base = 8;
  800b7e:	83 c1 01             	add    $0x1,%ecx
  800b81:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b86:	eb ce                	jmp    800b56 <strtol+0x44>
		s += 2, base = 16;
  800b88:	83 c1 02             	add    $0x2,%ecx
  800b8b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b90:	eb c4                	jmp    800b56 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800b92:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b95:	89 f3                	mov    %esi,%ebx
  800b97:	80 fb 19             	cmp    $0x19,%bl
  800b9a:	77 29                	ja     800bc5 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b9c:	0f be d2             	movsbl %dl,%edx
  800b9f:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ba2:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ba5:	7d 30                	jge    800bd7 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800ba7:	83 c1 01             	add    $0x1,%ecx
  800baa:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bae:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800bb0:	0f b6 11             	movzbl (%ecx),%edx
  800bb3:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bb6:	89 f3                	mov    %esi,%ebx
  800bb8:	80 fb 09             	cmp    $0x9,%bl
  800bbb:	77 d5                	ja     800b92 <strtol+0x80>
			dig = *s - '0';
  800bbd:	0f be d2             	movsbl %dl,%edx
  800bc0:	83 ea 30             	sub    $0x30,%edx
  800bc3:	eb dd                	jmp    800ba2 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800bc5:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bc8:	89 f3                	mov    %esi,%ebx
  800bca:	80 fb 19             	cmp    $0x19,%bl
  800bcd:	77 08                	ja     800bd7 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800bcf:	0f be d2             	movsbl %dl,%edx
  800bd2:	83 ea 37             	sub    $0x37,%edx
  800bd5:	eb cb                	jmp    800ba2 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bd7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bdb:	74 05                	je     800be2 <strtol+0xd0>
		*endptr = (char *) s;
  800bdd:	8b 75 0c             	mov    0xc(%ebp),%esi
  800be0:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800be2:	89 c2                	mov    %eax,%edx
  800be4:	f7 da                	neg    %edx
  800be6:	85 ff                	test   %edi,%edi
  800be8:	0f 45 c2             	cmovne %edx,%eax
}
  800beb:	5b                   	pop    %ebx
  800bec:	5e                   	pop    %esi
  800bed:	5f                   	pop    %edi
  800bee:	5d                   	pop    %ebp
  800bef:	c3                   	ret    

00800bf0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bf0:	55                   	push   %ebp
  800bf1:	89 e5                	mov    %esp,%ebp
  800bf3:	57                   	push   %edi
  800bf4:	56                   	push   %esi
  800bf5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bf6:	b8 00 00 00 00       	mov    $0x0,%eax
  800bfb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c01:	89 c3                	mov    %eax,%ebx
  800c03:	89 c7                	mov    %eax,%edi
  800c05:	89 c6                	mov    %eax,%esi
  800c07:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c09:	5b                   	pop    %ebx
  800c0a:	5e                   	pop    %esi
  800c0b:	5f                   	pop    %edi
  800c0c:	5d                   	pop    %ebp
  800c0d:	c3                   	ret    

00800c0e <sys_cgetc>:

int
sys_cgetc(void)
{
  800c0e:	55                   	push   %ebp
  800c0f:	89 e5                	mov    %esp,%ebp
  800c11:	57                   	push   %edi
  800c12:	56                   	push   %esi
  800c13:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c14:	ba 00 00 00 00       	mov    $0x0,%edx
  800c19:	b8 01 00 00 00       	mov    $0x1,%eax
  800c1e:	89 d1                	mov    %edx,%ecx
  800c20:	89 d3                	mov    %edx,%ebx
  800c22:	89 d7                	mov    %edx,%edi
  800c24:	89 d6                	mov    %edx,%esi
  800c26:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c28:	5b                   	pop    %ebx
  800c29:	5e                   	pop    %esi
  800c2a:	5f                   	pop    %edi
  800c2b:	5d                   	pop    %ebp
  800c2c:	c3                   	ret    

00800c2d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c2d:	55                   	push   %ebp
  800c2e:	89 e5                	mov    %esp,%ebp
  800c30:	57                   	push   %edi
  800c31:	56                   	push   %esi
  800c32:	53                   	push   %ebx
  800c33:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c36:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3e:	b8 03 00 00 00       	mov    $0x3,%eax
  800c43:	89 cb                	mov    %ecx,%ebx
  800c45:	89 cf                	mov    %ecx,%edi
  800c47:	89 ce                	mov    %ecx,%esi
  800c49:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c4b:	85 c0                	test   %eax,%eax
  800c4d:	7f 08                	jg     800c57 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c52:	5b                   	pop    %ebx
  800c53:	5e                   	pop    %esi
  800c54:	5f                   	pop    %edi
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c57:	83 ec 0c             	sub    $0xc,%esp
  800c5a:	50                   	push   %eax
  800c5b:	6a 03                	push   $0x3
  800c5d:	68 5f 26 80 00       	push   $0x80265f
  800c62:	6a 23                	push   $0x23
  800c64:	68 7c 26 80 00       	push   $0x80267c
  800c69:	e8 ef 12 00 00       	call   801f5d <_panic>

00800c6e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c6e:	55                   	push   %ebp
  800c6f:	89 e5                	mov    %esp,%ebp
  800c71:	57                   	push   %edi
  800c72:	56                   	push   %esi
  800c73:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c74:	ba 00 00 00 00       	mov    $0x0,%edx
  800c79:	b8 02 00 00 00       	mov    $0x2,%eax
  800c7e:	89 d1                	mov    %edx,%ecx
  800c80:	89 d3                	mov    %edx,%ebx
  800c82:	89 d7                	mov    %edx,%edi
  800c84:	89 d6                	mov    %edx,%esi
  800c86:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c88:	5b                   	pop    %ebx
  800c89:	5e                   	pop    %esi
  800c8a:	5f                   	pop    %edi
  800c8b:	5d                   	pop    %ebp
  800c8c:	c3                   	ret    

00800c8d <sys_yield>:

void
sys_yield(void)
{
  800c8d:	55                   	push   %ebp
  800c8e:	89 e5                	mov    %esp,%ebp
  800c90:	57                   	push   %edi
  800c91:	56                   	push   %esi
  800c92:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c93:	ba 00 00 00 00       	mov    $0x0,%edx
  800c98:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c9d:	89 d1                	mov    %edx,%ecx
  800c9f:	89 d3                	mov    %edx,%ebx
  800ca1:	89 d7                	mov    %edx,%edi
  800ca3:	89 d6                	mov    %edx,%esi
  800ca5:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ca7:	5b                   	pop    %ebx
  800ca8:	5e                   	pop    %esi
  800ca9:	5f                   	pop    %edi
  800caa:	5d                   	pop    %ebp
  800cab:	c3                   	ret    

00800cac <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cac:	55                   	push   %ebp
  800cad:	89 e5                	mov    %esp,%ebp
  800caf:	57                   	push   %edi
  800cb0:	56                   	push   %esi
  800cb1:	53                   	push   %ebx
  800cb2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cb5:	be 00 00 00 00       	mov    $0x0,%esi
  800cba:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc0:	b8 04 00 00 00       	mov    $0x4,%eax
  800cc5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc8:	89 f7                	mov    %esi,%edi
  800cca:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ccc:	85 c0                	test   %eax,%eax
  800cce:	7f 08                	jg     800cd8 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd3:	5b                   	pop    %ebx
  800cd4:	5e                   	pop    %esi
  800cd5:	5f                   	pop    %edi
  800cd6:	5d                   	pop    %ebp
  800cd7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd8:	83 ec 0c             	sub    $0xc,%esp
  800cdb:	50                   	push   %eax
  800cdc:	6a 04                	push   $0x4
  800cde:	68 5f 26 80 00       	push   $0x80265f
  800ce3:	6a 23                	push   $0x23
  800ce5:	68 7c 26 80 00       	push   $0x80267c
  800cea:	e8 6e 12 00 00       	call   801f5d <_panic>

00800cef <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cef:	55                   	push   %ebp
  800cf0:	89 e5                	mov    %esp,%ebp
  800cf2:	57                   	push   %edi
  800cf3:	56                   	push   %esi
  800cf4:	53                   	push   %ebx
  800cf5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfe:	b8 05 00 00 00       	mov    $0x5,%eax
  800d03:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d06:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d09:	8b 75 18             	mov    0x18(%ebp),%esi
  800d0c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d0e:	85 c0                	test   %eax,%eax
  800d10:	7f 08                	jg     800d1a <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d15:	5b                   	pop    %ebx
  800d16:	5e                   	pop    %esi
  800d17:	5f                   	pop    %edi
  800d18:	5d                   	pop    %ebp
  800d19:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1a:	83 ec 0c             	sub    $0xc,%esp
  800d1d:	50                   	push   %eax
  800d1e:	6a 05                	push   $0x5
  800d20:	68 5f 26 80 00       	push   $0x80265f
  800d25:	6a 23                	push   $0x23
  800d27:	68 7c 26 80 00       	push   $0x80267c
  800d2c:	e8 2c 12 00 00       	call   801f5d <_panic>

00800d31 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d31:	55                   	push   %ebp
  800d32:	89 e5                	mov    %esp,%ebp
  800d34:	57                   	push   %edi
  800d35:	56                   	push   %esi
  800d36:	53                   	push   %ebx
  800d37:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d3a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d45:	b8 06 00 00 00       	mov    $0x6,%eax
  800d4a:	89 df                	mov    %ebx,%edi
  800d4c:	89 de                	mov    %ebx,%esi
  800d4e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d50:	85 c0                	test   %eax,%eax
  800d52:	7f 08                	jg     800d5c <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d57:	5b                   	pop    %ebx
  800d58:	5e                   	pop    %esi
  800d59:	5f                   	pop    %edi
  800d5a:	5d                   	pop    %ebp
  800d5b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5c:	83 ec 0c             	sub    $0xc,%esp
  800d5f:	50                   	push   %eax
  800d60:	6a 06                	push   $0x6
  800d62:	68 5f 26 80 00       	push   $0x80265f
  800d67:	6a 23                	push   $0x23
  800d69:	68 7c 26 80 00       	push   $0x80267c
  800d6e:	e8 ea 11 00 00       	call   801f5d <_panic>

00800d73 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
  800d76:	57                   	push   %edi
  800d77:	56                   	push   %esi
  800d78:	53                   	push   %ebx
  800d79:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d7c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d81:	8b 55 08             	mov    0x8(%ebp),%edx
  800d84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d87:	b8 08 00 00 00       	mov    $0x8,%eax
  800d8c:	89 df                	mov    %ebx,%edi
  800d8e:	89 de                	mov    %ebx,%esi
  800d90:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d92:	85 c0                	test   %eax,%eax
  800d94:	7f 08                	jg     800d9e <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d99:	5b                   	pop    %ebx
  800d9a:	5e                   	pop    %esi
  800d9b:	5f                   	pop    %edi
  800d9c:	5d                   	pop    %ebp
  800d9d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9e:	83 ec 0c             	sub    $0xc,%esp
  800da1:	50                   	push   %eax
  800da2:	6a 08                	push   $0x8
  800da4:	68 5f 26 80 00       	push   $0x80265f
  800da9:	6a 23                	push   $0x23
  800dab:	68 7c 26 80 00       	push   $0x80267c
  800db0:	e8 a8 11 00 00       	call   801f5d <_panic>

00800db5 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800db5:	55                   	push   %ebp
  800db6:	89 e5                	mov    %esp,%ebp
  800db8:	57                   	push   %edi
  800db9:	56                   	push   %esi
  800dba:	53                   	push   %ebx
  800dbb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dbe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc9:	b8 09 00 00 00       	mov    $0x9,%eax
  800dce:	89 df                	mov    %ebx,%edi
  800dd0:	89 de                	mov    %ebx,%esi
  800dd2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dd4:	85 c0                	test   %eax,%eax
  800dd6:	7f 08                	jg     800de0 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ddb:	5b                   	pop    %ebx
  800ddc:	5e                   	pop    %esi
  800ddd:	5f                   	pop    %edi
  800dde:	5d                   	pop    %ebp
  800ddf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800de0:	83 ec 0c             	sub    $0xc,%esp
  800de3:	50                   	push   %eax
  800de4:	6a 09                	push   $0x9
  800de6:	68 5f 26 80 00       	push   $0x80265f
  800deb:	6a 23                	push   $0x23
  800ded:	68 7c 26 80 00       	push   $0x80267c
  800df2:	e8 66 11 00 00       	call   801f5d <_panic>

00800df7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800df7:	55                   	push   %ebp
  800df8:	89 e5                	mov    %esp,%ebp
  800dfa:	57                   	push   %edi
  800dfb:	56                   	push   %esi
  800dfc:	53                   	push   %ebx
  800dfd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e00:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e05:	8b 55 08             	mov    0x8(%ebp),%edx
  800e08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e10:	89 df                	mov    %ebx,%edi
  800e12:	89 de                	mov    %ebx,%esi
  800e14:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e16:	85 c0                	test   %eax,%eax
  800e18:	7f 08                	jg     800e22 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1d:	5b                   	pop    %ebx
  800e1e:	5e                   	pop    %esi
  800e1f:	5f                   	pop    %edi
  800e20:	5d                   	pop    %ebp
  800e21:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e22:	83 ec 0c             	sub    $0xc,%esp
  800e25:	50                   	push   %eax
  800e26:	6a 0a                	push   $0xa
  800e28:	68 5f 26 80 00       	push   $0x80265f
  800e2d:	6a 23                	push   $0x23
  800e2f:	68 7c 26 80 00       	push   $0x80267c
  800e34:	e8 24 11 00 00       	call   801f5d <_panic>

00800e39 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e39:	55                   	push   %ebp
  800e3a:	89 e5                	mov    %esp,%ebp
  800e3c:	57                   	push   %edi
  800e3d:	56                   	push   %esi
  800e3e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e45:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e4a:	be 00 00 00 00       	mov    $0x0,%esi
  800e4f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e52:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e55:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e57:	5b                   	pop    %ebx
  800e58:	5e                   	pop    %esi
  800e59:	5f                   	pop    %edi
  800e5a:	5d                   	pop    %ebp
  800e5b:	c3                   	ret    

00800e5c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e5c:	55                   	push   %ebp
  800e5d:	89 e5                	mov    %esp,%ebp
  800e5f:	57                   	push   %edi
  800e60:	56                   	push   %esi
  800e61:	53                   	push   %ebx
  800e62:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e65:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e72:	89 cb                	mov    %ecx,%ebx
  800e74:	89 cf                	mov    %ecx,%edi
  800e76:	89 ce                	mov    %ecx,%esi
  800e78:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e7a:	85 c0                	test   %eax,%eax
  800e7c:	7f 08                	jg     800e86 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e81:	5b                   	pop    %ebx
  800e82:	5e                   	pop    %esi
  800e83:	5f                   	pop    %edi
  800e84:	5d                   	pop    %ebp
  800e85:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e86:	83 ec 0c             	sub    $0xc,%esp
  800e89:	50                   	push   %eax
  800e8a:	6a 0d                	push   $0xd
  800e8c:	68 5f 26 80 00       	push   $0x80265f
  800e91:	6a 23                	push   $0x23
  800e93:	68 7c 26 80 00       	push   $0x80267c
  800e98:	e8 c0 10 00 00       	call   801f5d <_panic>

00800e9d <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e9d:	55                   	push   %ebp
  800e9e:	89 e5                	mov    %esp,%ebp
  800ea0:	56                   	push   %esi
  800ea1:	53                   	push   %ebx
  800ea2:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ea5:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if((err&FEC_WR)==0 || (uvpt[PGNUM(addr)]&(PTE_W|PTE_COW))==0){
  800ea7:	8b 40 04             	mov    0x4(%eax),%eax
  800eaa:	83 e0 02             	and    $0x2,%eax
  800ead:	0f 84 82 00 00 00    	je     800f35 <pgfault+0x98>
  800eb3:	89 da                	mov    %ebx,%edx
  800eb5:	c1 ea 0c             	shr    $0xc,%edx
  800eb8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ebf:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800ec5:	74 6e                	je     800f35 <pgfault+0x98>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        envid_t envid = sys_getenvid();
  800ec7:	e8 a2 fd ff ff       	call   800c6e <sys_getenvid>
  800ecc:	89 c6                	mov    %eax,%esi
	r = sys_page_alloc(envid,(void *)PFTEMP,PTE_P|PTE_W|PTE_U);
  800ece:	83 ec 04             	sub    $0x4,%esp
  800ed1:	6a 07                	push   $0x7
  800ed3:	68 00 f0 7f 00       	push   $0x7ff000
  800ed8:	50                   	push   %eax
  800ed9:	e8 ce fd ff ff       	call   800cac <sys_page_alloc>
	if(r<0) panic("pgfault:page allocation failed %e",r);
  800ede:	83 c4 10             	add    $0x10,%esp
  800ee1:	85 c0                	test   %eax,%eax
  800ee3:	78 72                	js     800f57 <pgfault+0xba>

	addr = ROUNDDOWN(addr,PGSIZE);
  800ee5:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy((void *)PFTEMP,(const void *)addr,PGSIZE);
  800eeb:	83 ec 04             	sub    $0x4,%esp
  800eee:	68 00 10 00 00       	push   $0x1000
  800ef3:	53                   	push   %ebx
  800ef4:	68 00 f0 7f 00       	push   $0x7ff000
  800ef9:	e8 ab fb ff ff       	call   800aa9 <memcpy>

	if(sys_page_map(envid,(void *)PFTEMP, envid,addr,PTE_P|PTE_W|PTE_U)<0)
  800efe:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f05:	53                   	push   %ebx
  800f06:	56                   	push   %esi
  800f07:	68 00 f0 7f 00       	push   $0x7ff000
  800f0c:	56                   	push   %esi
  800f0d:	e8 dd fd ff ff       	call   800cef <sys_page_map>
  800f12:	83 c4 20             	add    $0x20,%esp
  800f15:	85 c0                	test   %eax,%eax
  800f17:	78 50                	js     800f69 <pgfault+0xcc>
		panic("pgfault:page map failed\n");
	if(sys_page_unmap(envid,(void *)PFTEMP)<0)
  800f19:	83 ec 08             	sub    $0x8,%esp
  800f1c:	68 00 f0 7f 00       	push   $0x7ff000
  800f21:	56                   	push   %esi
  800f22:	e8 0a fe ff ff       	call   800d31 <sys_page_unmap>
  800f27:	83 c4 10             	add    $0x10,%esp
  800f2a:	85 c0                	test   %eax,%eax
  800f2c:	78 4f                	js     800f7d <pgfault+0xe0>
		panic("pgfault: page upmap failed\n");
       //	panic("pgfault not implemented");
}
  800f2e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f31:	5b                   	pop    %ebx
  800f32:	5e                   	pop    %esi
  800f33:	5d                   	pop    %ebp
  800f34:	c3                   	ret    
		cprintf("Where is the error %d\n",err&FEC_WR);
  800f35:	83 ec 08             	sub    $0x8,%esp
  800f38:	50                   	push   %eax
  800f39:	68 8a 26 80 00       	push   $0x80268a
  800f3e:	e8 51 f3 ff ff       	call   800294 <cprintf>
		panic("pgfault:invalid user trap");
  800f43:	83 c4 0c             	add    $0xc,%esp
  800f46:	68 a1 26 80 00       	push   $0x8026a1
  800f4b:	6a 1e                	push   $0x1e
  800f4d:	68 bb 26 80 00       	push   $0x8026bb
  800f52:	e8 06 10 00 00       	call   801f5d <_panic>
	if(r<0) panic("pgfault:page allocation failed %e",r);
  800f57:	50                   	push   %eax
  800f58:	68 a8 27 80 00       	push   $0x8027a8
  800f5d:	6a 29                	push   $0x29
  800f5f:	68 bb 26 80 00       	push   $0x8026bb
  800f64:	e8 f4 0f 00 00       	call   801f5d <_panic>
		panic("pgfault:page map failed\n");
  800f69:	83 ec 04             	sub    $0x4,%esp
  800f6c:	68 c6 26 80 00       	push   $0x8026c6
  800f71:	6a 2f                	push   $0x2f
  800f73:	68 bb 26 80 00       	push   $0x8026bb
  800f78:	e8 e0 0f 00 00       	call   801f5d <_panic>
		panic("pgfault: page upmap failed\n");
  800f7d:	83 ec 04             	sub    $0x4,%esp
  800f80:	68 df 26 80 00       	push   $0x8026df
  800f85:	6a 31                	push   $0x31
  800f87:	68 bb 26 80 00       	push   $0x8026bb
  800f8c:	e8 cc 0f 00 00       	call   801f5d <_panic>

00800f91 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f91:	55                   	push   %ebp
  800f92:	89 e5                	mov    %esp,%ebp
  800f94:	57                   	push   %edi
  800f95:	56                   	push   %esi
  800f96:	53                   	push   %ebx
  800f97:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	set_pgfault_handler(pgfault);
  800f9a:	68 9d 0e 80 00       	push   $0x800e9d
  800f9f:	e8 ff 0f 00 00       	call   801fa3 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fa4:	b8 07 00 00 00       	mov    $0x7,%eax
  800fa9:	cd 30                	int    $0x30
  800fab:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800fae:	89 45 e0             	mov    %eax,-0x20(%ebp)
       
	envid_t envid = sys_exofork();
	uintptr_t addr;
  
	if(envid<0) panic("sys_exofork failed\n");
  800fb1:	83 c4 10             	add    $0x10,%esp
  800fb4:	85 c0                	test   %eax,%eax
  800fb6:	78 27                	js     800fdf <fork+0x4e>
	if(envid==0){
	  thisenv = &envs[ENVX(sys_getenvid())];
	  return 0;
	}

	for(addr=(uintptr_t)UTEXT; addr<USTACKTOP;addr+=PGSIZE){
  800fb8:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if(envid==0){
  800fbd:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800fc1:	75 5e                	jne    801021 <fork+0x90>
	  thisenv = &envs[ENVX(sys_getenvid())];
  800fc3:	e8 a6 fc ff ff       	call   800c6e <sys_getenvid>
  800fc8:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fcd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fd0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fd5:	a3 04 40 80 00       	mov    %eax,0x804004
	  return 0;
  800fda:	e9 fc 00 00 00       	jmp    8010db <fork+0x14a>
	if(envid<0) panic("sys_exofork failed\n");
  800fdf:	83 ec 04             	sub    $0x4,%esp
  800fe2:	68 fb 26 80 00       	push   $0x8026fb
  800fe7:	6a 77                	push   $0x77
  800fe9:	68 bb 26 80 00       	push   $0x8026bb
  800fee:	e8 6a 0f 00 00       	call   801f5d <_panic>
          if((r=sys_page_map(parent_envid,va,envid,va,uvpt[pn]&PTE_SYSCALL))<0)
  800ff3:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800ffa:	83 ec 0c             	sub    $0xc,%esp
  800ffd:	25 07 0e 00 00       	and    $0xe07,%eax
  801002:	50                   	push   %eax
  801003:	57                   	push   %edi
  801004:	ff 75 e0             	pushl  -0x20(%ebp)
  801007:	57                   	push   %edi
  801008:	ff 75 e4             	pushl  -0x1c(%ebp)
  80100b:	e8 df fc ff ff       	call   800cef <sys_page_map>
  801010:	83 c4 20             	add    $0x20,%esp
	for(addr=(uintptr_t)UTEXT; addr<USTACKTOP;addr+=PGSIZE){
  801013:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801019:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80101f:	74 76                	je     801097 <fork+0x106>
	   if((uvpd[PDX(addr)]&PTE_P) && uvpt[PGNUM(addr)] & PTE_P)
  801021:	89 d8                	mov    %ebx,%eax
  801023:	c1 e8 16             	shr    $0x16,%eax
  801026:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80102d:	a8 01                	test   $0x1,%al
  80102f:	74 e2                	je     801013 <fork+0x82>
  801031:	89 de                	mov    %ebx,%esi
  801033:	c1 ee 0c             	shr    $0xc,%esi
  801036:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80103d:	a8 01                	test   $0x1,%al
  80103f:	74 d2                	je     801013 <fork+0x82>
        envid_t parent_envid = sys_getenvid();
  801041:	e8 28 fc ff ff       	call   800c6e <sys_getenvid>
  801046:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	void *va = (void *)(pn*PGSIZE);
  801049:	89 f7                	mov    %esi,%edi
  80104b:	c1 e7 0c             	shl    $0xc,%edi
        if(uvpt[pn] & PTE_SHARE){
  80104e:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801055:	f6 c4 04             	test   $0x4,%ah
  801058:	75 99                	jne    800ff3 <fork+0x62>
	if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)){
  80105a:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801061:	a8 02                	test   $0x2,%al
  801063:	0f 85 ed 00 00 00    	jne    801156 <fork+0x1c5>
  801069:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801070:	f6 c4 08             	test   $0x8,%ah
  801073:	0f 85 dd 00 00 00    	jne    801156 <fork+0x1c5>
	 if((r=sys_page_map(parent_envid,va,envid,va,perm))<0)
  801079:	83 ec 0c             	sub    $0xc,%esp
  80107c:	6a 05                	push   $0x5
  80107e:	57                   	push   %edi
  80107f:	ff 75 e0             	pushl  -0x20(%ebp)
  801082:	57                   	push   %edi
  801083:	ff 75 e4             	pushl  -0x1c(%ebp)
  801086:	e8 64 fc ff ff       	call   800cef <sys_page_map>
  80108b:	83 c4 20             	add    $0x20,%esp
  80108e:	85 c0                	test   %eax,%eax
  801090:	79 81                	jns    801013 <fork+0x82>
  801092:	e9 db 00 00 00       	jmp    801172 <fork+0x1e1>
		   duppage(envid,PGNUM(addr));
	}
        
	int r;
	if((r=sys_page_alloc(envid,(void *)UXSTACKTOP-PGSIZE,PTE_U|PTE_P|PTE_W))<0)
  801097:	83 ec 04             	sub    $0x4,%esp
  80109a:	6a 07                	push   $0x7
  80109c:	68 00 f0 bf ee       	push   $0xeebff000
  8010a1:	ff 75 dc             	pushl  -0x24(%ebp)
  8010a4:	e8 03 fc ff ff       	call   800cac <sys_page_alloc>
  8010a9:	83 c4 10             	add    $0x10,%esp
  8010ac:	85 c0                	test   %eax,%eax
  8010ae:	78 36                	js     8010e6 <fork+0x155>
		panic("fork:page alloc failed %e\n",r);

	extern void _pgfault_upcall();
	if((r = sys_env_set_pgfault_upcall(envid,_pgfault_upcall)))
  8010b0:	83 ec 08             	sub    $0x8,%esp
  8010b3:	68 08 20 80 00       	push   $0x802008
  8010b8:	ff 75 dc             	pushl  -0x24(%ebp)
  8010bb:	e8 37 fd ff ff       	call   800df7 <sys_env_set_pgfault_upcall>
  8010c0:	83 c4 10             	add    $0x10,%esp
  8010c3:	85 c0                	test   %eax,%eax
  8010c5:	75 34                	jne    8010fb <fork+0x16a>
		panic("fork:set upcall failed %e\n",r);
	if((r = sys_env_set_status(envid,ENV_RUNNABLE))<0)
  8010c7:	83 ec 08             	sub    $0x8,%esp
  8010ca:	6a 02                	push   $0x2
  8010cc:	ff 75 dc             	pushl  -0x24(%ebp)
  8010cf:	e8 9f fc ff ff       	call   800d73 <sys_env_set_status>
  8010d4:	83 c4 10             	add    $0x10,%esp
  8010d7:	85 c0                	test   %eax,%eax
  8010d9:	78 35                	js     801110 <fork+0x17f>
		panic("fork:set status failed %e\n",r);
	//cprintf("forkid= %d\n", envid);
	return envid;
       	
}
  8010db:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8010de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e1:	5b                   	pop    %ebx
  8010e2:	5e                   	pop    %esi
  8010e3:	5f                   	pop    %edi
  8010e4:	5d                   	pop    %ebp
  8010e5:	c3                   	ret    
		panic("fork:page alloc failed %e\n",r);
  8010e6:	50                   	push   %eax
  8010e7:	68 3f 27 80 00       	push   $0x80273f
  8010ec:	68 84 00 00 00       	push   $0x84
  8010f1:	68 bb 26 80 00       	push   $0x8026bb
  8010f6:	e8 62 0e 00 00       	call   801f5d <_panic>
		panic("fork:set upcall failed %e\n",r);
  8010fb:	50                   	push   %eax
  8010fc:	68 5a 27 80 00       	push   $0x80275a
  801101:	68 88 00 00 00       	push   $0x88
  801106:	68 bb 26 80 00       	push   $0x8026bb
  80110b:	e8 4d 0e 00 00       	call   801f5d <_panic>
		panic("fork:set status failed %e\n",r);
  801110:	50                   	push   %eax
  801111:	68 75 27 80 00       	push   $0x802775
  801116:	68 8a 00 00 00       	push   $0x8a
  80111b:	68 bb 26 80 00       	push   $0x8026bb
  801120:	e8 38 0e 00 00       	call   801f5d <_panic>
		if( (r=sys_page_map(parent_envid,va,parent_envid,va,perm))<0){
  801125:	83 ec 0c             	sub    $0xc,%esp
  801128:	68 05 08 00 00       	push   $0x805
  80112d:	57                   	push   %edi
  80112e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801131:	50                   	push   %eax
  801132:	57                   	push   %edi
  801133:	50                   	push   %eax
  801134:	e8 b6 fb ff ff       	call   800cef <sys_page_map>
  801139:	83 c4 20             	add    $0x20,%esp
  80113c:	85 c0                	test   %eax,%eax
  80113e:	0f 89 cf fe ff ff    	jns    801013 <fork+0x82>
		 panic("duppage:map02 failed %e",r);
  801144:	50                   	push   %eax
  801145:	68 27 27 80 00       	push   $0x802727
  80114a:	6a 56                	push   $0x56
  80114c:	68 bb 26 80 00       	push   $0x8026bb
  801151:	e8 07 0e 00 00       	call   801f5d <_panic>
	 if((r=sys_page_map(parent_envid,va,envid,va,perm))<0)
  801156:	83 ec 0c             	sub    $0xc,%esp
  801159:	68 05 08 00 00       	push   $0x805
  80115e:	57                   	push   %edi
  80115f:	ff 75 e0             	pushl  -0x20(%ebp)
  801162:	57                   	push   %edi
  801163:	ff 75 e4             	pushl  -0x1c(%ebp)
  801166:	e8 84 fb ff ff       	call   800cef <sys_page_map>
  80116b:	83 c4 20             	add    $0x20,%esp
  80116e:	85 c0                	test   %eax,%eax
  801170:	79 b3                	jns    801125 <fork+0x194>
		 panic("duppage:map01 failed %e",r);
  801172:	50                   	push   %eax
  801173:	68 0f 27 80 00       	push   $0x80270f
  801178:	6a 53                	push   $0x53
  80117a:	68 bb 26 80 00       	push   $0x8026bb
  80117f:	e8 d9 0d 00 00       	call   801f5d <_panic>

00801184 <sfork>:

// Challenge!
int
sfork(void)
{
  801184:	55                   	push   %ebp
  801185:	89 e5                	mov    %esp,%ebp
  801187:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80118a:	68 90 27 80 00       	push   $0x802790
  80118f:	68 94 00 00 00       	push   $0x94
  801194:	68 bb 26 80 00       	push   $0x8026bb
  801199:	e8 bf 0d 00 00       	call   801f5d <_panic>

0080119e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80119e:	55                   	push   %ebp
  80119f:	89 e5                	mov    %esp,%ebp
  8011a1:	56                   	push   %esi
  8011a2:	53                   	push   %ebx
  8011a3:	8b 75 08             	mov    0x8(%ebp),%esi
  8011a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011a9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        //	panic("ipc_recv not implemented");
        int r;
       	if(pg!=NULL){
  8011ac:	85 c0                	test   %eax,%eax
  8011ae:	74 3b                	je     8011eb <ipc_recv+0x4d>
	  r = sys_ipc_recv(pg);
  8011b0:	83 ec 0c             	sub    $0xc,%esp
  8011b3:	50                   	push   %eax
  8011b4:	e8 a3 fc ff ff       	call   800e5c <sys_ipc_recv>
  8011b9:	83 c4 10             	add    $0x10,%esp
	}else
	  r = sys_ipc_recv((void *)UTOP);
	if(r<0){
  8011bc:	85 c0                	test   %eax,%eax
  8011be:	78 3d                	js     8011fd <ipc_recv+0x5f>
	if(perm_store!=NULL){
		*perm_store = 0;
            }
        	return r;
           }else{
	     if(from_env_store!=NULL)
  8011c0:	85 f6                	test   %esi,%esi
  8011c2:	74 0a                	je     8011ce <ipc_recv+0x30>
		     *from_env_store = thisenv->env_ipc_from;
  8011c4:	a1 04 40 80 00       	mov    0x804004,%eax
  8011c9:	8b 40 74             	mov    0x74(%eax),%eax
  8011cc:	89 06                	mov    %eax,(%esi)
	     if(perm_store != NULL)
  8011ce:	85 db                	test   %ebx,%ebx
  8011d0:	74 0a                	je     8011dc <ipc_recv+0x3e>
		     *perm_store = thisenv->env_ipc_perm;
  8011d2:	a1 04 40 80 00       	mov    0x804004,%eax
  8011d7:	8b 40 78             	mov    0x78(%eax),%eax
  8011da:	89 03                	mov    %eax,(%ebx)
	     return thisenv->env_ipc_value;
  8011dc:	a1 04 40 80 00       	mov    0x804004,%eax
  8011e1:	8b 40 70             	mov    0x70(%eax),%eax
	   }

}
  8011e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011e7:	5b                   	pop    %ebx
  8011e8:	5e                   	pop    %esi
  8011e9:	5d                   	pop    %ebp
  8011ea:	c3                   	ret    
	  r = sys_ipc_recv((void *)UTOP);
  8011eb:	83 ec 0c             	sub    $0xc,%esp
  8011ee:	68 00 00 c0 ee       	push   $0xeec00000
  8011f3:	e8 64 fc ff ff       	call   800e5c <sys_ipc_recv>
  8011f8:	83 c4 10             	add    $0x10,%esp
  8011fb:	eb bf                	jmp    8011bc <ipc_recv+0x1e>
	if(from_env_store!=NULL){
  8011fd:	85 f6                	test   %esi,%esi
  8011ff:	74 06                	je     801207 <ipc_recv+0x69>
	  *from_env_store = 0;
  801201:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if(perm_store!=NULL){
  801207:	85 db                	test   %ebx,%ebx
  801209:	74 d9                	je     8011e4 <ipc_recv+0x46>
		*perm_store = 0;
  80120b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801211:	eb d1                	jmp    8011e4 <ipc_recv+0x46>

00801213 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801213:	55                   	push   %ebp
  801214:	89 e5                	mov    %esp,%ebp
  801216:	57                   	push   %edi
  801217:	56                   	push   %esi
  801218:	53                   	push   %ebx
  801219:	83 ec 0c             	sub    $0xc,%esp
  80121c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80121f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801222:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if(pg==NULL) pg = (void *)UTOP;
  801225:	85 db                	test   %ebx,%ebx
  801227:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80122c:	0f 44 d8             	cmove  %eax,%ebx
	while((r=sys_ipc_try_send(to_env,val,pg,perm))<0){
  80122f:	ff 75 14             	pushl  0x14(%ebp)
  801232:	53                   	push   %ebx
  801233:	56                   	push   %esi
  801234:	57                   	push   %edi
  801235:	e8 ff fb ff ff       	call   800e39 <sys_ipc_try_send>
  80123a:	83 c4 10             	add    $0x10,%esp
  80123d:	85 c0                	test   %eax,%eax
  80123f:	79 20                	jns    801261 <ipc_send+0x4e>
	    if(r!=-E_IPC_NOT_RECV){
  801241:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801244:	75 07                	jne    80124d <ipc_send+0x3a>
		    panic("ipc_send:send message failed\n");
	    }
	    sys_yield();
  801246:	e8 42 fa ff ff       	call   800c8d <sys_yield>
  80124b:	eb e2                	jmp    80122f <ipc_send+0x1c>
		    panic("ipc_send:send message failed\n");
  80124d:	83 ec 04             	sub    $0x4,%esp
  801250:	68 ca 27 80 00       	push   $0x8027ca
  801255:	6a 43                	push   $0x43
  801257:	68 e8 27 80 00       	push   $0x8027e8
  80125c:	e8 fc 0c 00 00       	call   801f5d <_panic>
	}

}
  801261:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801264:	5b                   	pop    %ebx
  801265:	5e                   	pop    %esi
  801266:	5f                   	pop    %edi
  801267:	5d                   	pop    %ebp
  801268:	c3                   	ret    

00801269 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801269:	55                   	push   %ebp
  80126a:	89 e5                	mov    %esp,%ebp
  80126c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80126f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801274:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801277:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80127d:	8b 52 50             	mov    0x50(%edx),%edx
  801280:	39 ca                	cmp    %ecx,%edx
  801282:	74 11                	je     801295 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801284:	83 c0 01             	add    $0x1,%eax
  801287:	3d 00 04 00 00       	cmp    $0x400,%eax
  80128c:	75 e6                	jne    801274 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  80128e:	b8 00 00 00 00       	mov    $0x0,%eax
  801293:	eb 0b                	jmp    8012a0 <ipc_find_env+0x37>
			return envs[i].env_id;
  801295:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801298:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80129d:	8b 40 48             	mov    0x48(%eax),%eax
}
  8012a0:	5d                   	pop    %ebp
  8012a1:	c3                   	ret    

008012a2 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012a2:	55                   	push   %ebp
  8012a3:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a8:	05 00 00 00 30       	add    $0x30000000,%eax
  8012ad:	c1 e8 0c             	shr    $0xc,%eax
}
  8012b0:	5d                   	pop    %ebp
  8012b1:	c3                   	ret    

008012b2 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012b2:	55                   	push   %ebp
  8012b3:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8012b8:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8012bd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012c2:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012c7:	5d                   	pop    %ebp
  8012c8:	c3                   	ret    

008012c9 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012c9:	55                   	push   %ebp
  8012ca:	89 e5                	mov    %esp,%ebp
  8012cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012cf:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012d4:	89 c2                	mov    %eax,%edx
  8012d6:	c1 ea 16             	shr    $0x16,%edx
  8012d9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012e0:	f6 c2 01             	test   $0x1,%dl
  8012e3:	74 2a                	je     80130f <fd_alloc+0x46>
  8012e5:	89 c2                	mov    %eax,%edx
  8012e7:	c1 ea 0c             	shr    $0xc,%edx
  8012ea:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012f1:	f6 c2 01             	test   $0x1,%dl
  8012f4:	74 19                	je     80130f <fd_alloc+0x46>
  8012f6:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8012fb:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801300:	75 d2                	jne    8012d4 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801302:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801308:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  80130d:	eb 07                	jmp    801316 <fd_alloc+0x4d>
			*fd_store = fd;
  80130f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801311:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801316:	5d                   	pop    %ebp
  801317:	c3                   	ret    

00801318 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801318:	55                   	push   %ebp
  801319:	89 e5                	mov    %esp,%ebp
  80131b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80131e:	83 f8 1f             	cmp    $0x1f,%eax
  801321:	77 36                	ja     801359 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801323:	c1 e0 0c             	shl    $0xc,%eax
  801326:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80132b:	89 c2                	mov    %eax,%edx
  80132d:	c1 ea 16             	shr    $0x16,%edx
  801330:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801337:	f6 c2 01             	test   $0x1,%dl
  80133a:	74 24                	je     801360 <fd_lookup+0x48>
  80133c:	89 c2                	mov    %eax,%edx
  80133e:	c1 ea 0c             	shr    $0xc,%edx
  801341:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801348:	f6 c2 01             	test   $0x1,%dl
  80134b:	74 1a                	je     801367 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80134d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801350:	89 02                	mov    %eax,(%edx)
	return 0;
  801352:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801357:	5d                   	pop    %ebp
  801358:	c3                   	ret    
		return -E_INVAL;
  801359:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80135e:	eb f7                	jmp    801357 <fd_lookup+0x3f>
		return -E_INVAL;
  801360:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801365:	eb f0                	jmp    801357 <fd_lookup+0x3f>
  801367:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80136c:	eb e9                	jmp    801357 <fd_lookup+0x3f>

0080136e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80136e:	55                   	push   %ebp
  80136f:	89 e5                	mov    %esp,%ebp
  801371:	83 ec 08             	sub    $0x8,%esp
  801374:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801377:	ba 70 28 80 00       	mov    $0x802870,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80137c:	b8 0c 30 80 00       	mov    $0x80300c,%eax
		if (devtab[i]->dev_id == dev_id) {
  801381:	39 08                	cmp    %ecx,(%eax)
  801383:	74 33                	je     8013b8 <dev_lookup+0x4a>
  801385:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  801388:	8b 02                	mov    (%edx),%eax
  80138a:	85 c0                	test   %eax,%eax
  80138c:	75 f3                	jne    801381 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80138e:	a1 04 40 80 00       	mov    0x804004,%eax
  801393:	8b 40 48             	mov    0x48(%eax),%eax
  801396:	83 ec 04             	sub    $0x4,%esp
  801399:	51                   	push   %ecx
  80139a:	50                   	push   %eax
  80139b:	68 f4 27 80 00       	push   $0x8027f4
  8013a0:	e8 ef ee ff ff       	call   800294 <cprintf>
	*dev = 0;
  8013a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013a8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013ae:	83 c4 10             	add    $0x10,%esp
  8013b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013b6:	c9                   	leave  
  8013b7:	c3                   	ret    
			*dev = devtab[i];
  8013b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013bb:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8013c2:	eb f2                	jmp    8013b6 <dev_lookup+0x48>

008013c4 <fd_close>:
{
  8013c4:	55                   	push   %ebp
  8013c5:	89 e5                	mov    %esp,%ebp
  8013c7:	57                   	push   %edi
  8013c8:	56                   	push   %esi
  8013c9:	53                   	push   %ebx
  8013ca:	83 ec 1c             	sub    $0x1c,%esp
  8013cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8013d0:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013d3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013d6:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013d7:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013dd:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013e0:	50                   	push   %eax
  8013e1:	e8 32 ff ff ff       	call   801318 <fd_lookup>
  8013e6:	89 c3                	mov    %eax,%ebx
  8013e8:	83 c4 08             	add    $0x8,%esp
  8013eb:	85 c0                	test   %eax,%eax
  8013ed:	78 05                	js     8013f4 <fd_close+0x30>
	    || fd != fd2)
  8013ef:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8013f2:	74 16                	je     80140a <fd_close+0x46>
		return (must_exist ? r : 0);
  8013f4:	89 f8                	mov    %edi,%eax
  8013f6:	84 c0                	test   %al,%al
  8013f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8013fd:	0f 44 d8             	cmove  %eax,%ebx
}
  801400:	89 d8                	mov    %ebx,%eax
  801402:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801405:	5b                   	pop    %ebx
  801406:	5e                   	pop    %esi
  801407:	5f                   	pop    %edi
  801408:	5d                   	pop    %ebp
  801409:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80140a:	83 ec 08             	sub    $0x8,%esp
  80140d:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801410:	50                   	push   %eax
  801411:	ff 36                	pushl  (%esi)
  801413:	e8 56 ff ff ff       	call   80136e <dev_lookup>
  801418:	89 c3                	mov    %eax,%ebx
  80141a:	83 c4 10             	add    $0x10,%esp
  80141d:	85 c0                	test   %eax,%eax
  80141f:	78 15                	js     801436 <fd_close+0x72>
		if (dev->dev_close)
  801421:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801424:	8b 40 10             	mov    0x10(%eax),%eax
  801427:	85 c0                	test   %eax,%eax
  801429:	74 1b                	je     801446 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  80142b:	83 ec 0c             	sub    $0xc,%esp
  80142e:	56                   	push   %esi
  80142f:	ff d0                	call   *%eax
  801431:	89 c3                	mov    %eax,%ebx
  801433:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801436:	83 ec 08             	sub    $0x8,%esp
  801439:	56                   	push   %esi
  80143a:	6a 00                	push   $0x0
  80143c:	e8 f0 f8 ff ff       	call   800d31 <sys_page_unmap>
	return r;
  801441:	83 c4 10             	add    $0x10,%esp
  801444:	eb ba                	jmp    801400 <fd_close+0x3c>
			r = 0;
  801446:	bb 00 00 00 00       	mov    $0x0,%ebx
  80144b:	eb e9                	jmp    801436 <fd_close+0x72>

0080144d <close>:

int
close(int fdnum)
{
  80144d:	55                   	push   %ebp
  80144e:	89 e5                	mov    %esp,%ebp
  801450:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801453:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801456:	50                   	push   %eax
  801457:	ff 75 08             	pushl  0x8(%ebp)
  80145a:	e8 b9 fe ff ff       	call   801318 <fd_lookup>
  80145f:	83 c4 08             	add    $0x8,%esp
  801462:	85 c0                	test   %eax,%eax
  801464:	78 10                	js     801476 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801466:	83 ec 08             	sub    $0x8,%esp
  801469:	6a 01                	push   $0x1
  80146b:	ff 75 f4             	pushl  -0xc(%ebp)
  80146e:	e8 51 ff ff ff       	call   8013c4 <fd_close>
  801473:	83 c4 10             	add    $0x10,%esp
}
  801476:	c9                   	leave  
  801477:	c3                   	ret    

00801478 <close_all>:

void
close_all(void)
{
  801478:	55                   	push   %ebp
  801479:	89 e5                	mov    %esp,%ebp
  80147b:	53                   	push   %ebx
  80147c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80147f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801484:	83 ec 0c             	sub    $0xc,%esp
  801487:	53                   	push   %ebx
  801488:	e8 c0 ff ff ff       	call   80144d <close>
	for (i = 0; i < MAXFD; i++)
  80148d:	83 c3 01             	add    $0x1,%ebx
  801490:	83 c4 10             	add    $0x10,%esp
  801493:	83 fb 20             	cmp    $0x20,%ebx
  801496:	75 ec                	jne    801484 <close_all+0xc>
}
  801498:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80149b:	c9                   	leave  
  80149c:	c3                   	ret    

0080149d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80149d:	55                   	push   %ebp
  80149e:	89 e5                	mov    %esp,%ebp
  8014a0:	57                   	push   %edi
  8014a1:	56                   	push   %esi
  8014a2:	53                   	push   %ebx
  8014a3:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014a6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014a9:	50                   	push   %eax
  8014aa:	ff 75 08             	pushl  0x8(%ebp)
  8014ad:	e8 66 fe ff ff       	call   801318 <fd_lookup>
  8014b2:	89 c3                	mov    %eax,%ebx
  8014b4:	83 c4 08             	add    $0x8,%esp
  8014b7:	85 c0                	test   %eax,%eax
  8014b9:	0f 88 81 00 00 00    	js     801540 <dup+0xa3>
		return r;
	close(newfdnum);
  8014bf:	83 ec 0c             	sub    $0xc,%esp
  8014c2:	ff 75 0c             	pushl  0xc(%ebp)
  8014c5:	e8 83 ff ff ff       	call   80144d <close>

	newfd = INDEX2FD(newfdnum);
  8014ca:	8b 75 0c             	mov    0xc(%ebp),%esi
  8014cd:	c1 e6 0c             	shl    $0xc,%esi
  8014d0:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8014d6:	83 c4 04             	add    $0x4,%esp
  8014d9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014dc:	e8 d1 fd ff ff       	call   8012b2 <fd2data>
  8014e1:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8014e3:	89 34 24             	mov    %esi,(%esp)
  8014e6:	e8 c7 fd ff ff       	call   8012b2 <fd2data>
  8014eb:	83 c4 10             	add    $0x10,%esp
  8014ee:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014f0:	89 d8                	mov    %ebx,%eax
  8014f2:	c1 e8 16             	shr    $0x16,%eax
  8014f5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014fc:	a8 01                	test   $0x1,%al
  8014fe:	74 11                	je     801511 <dup+0x74>
  801500:	89 d8                	mov    %ebx,%eax
  801502:	c1 e8 0c             	shr    $0xc,%eax
  801505:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80150c:	f6 c2 01             	test   $0x1,%dl
  80150f:	75 39                	jne    80154a <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801511:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801514:	89 d0                	mov    %edx,%eax
  801516:	c1 e8 0c             	shr    $0xc,%eax
  801519:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801520:	83 ec 0c             	sub    $0xc,%esp
  801523:	25 07 0e 00 00       	and    $0xe07,%eax
  801528:	50                   	push   %eax
  801529:	56                   	push   %esi
  80152a:	6a 00                	push   $0x0
  80152c:	52                   	push   %edx
  80152d:	6a 00                	push   $0x0
  80152f:	e8 bb f7 ff ff       	call   800cef <sys_page_map>
  801534:	89 c3                	mov    %eax,%ebx
  801536:	83 c4 20             	add    $0x20,%esp
  801539:	85 c0                	test   %eax,%eax
  80153b:	78 31                	js     80156e <dup+0xd1>
		goto err;

	return newfdnum;
  80153d:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801540:	89 d8                	mov    %ebx,%eax
  801542:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801545:	5b                   	pop    %ebx
  801546:	5e                   	pop    %esi
  801547:	5f                   	pop    %edi
  801548:	5d                   	pop    %ebp
  801549:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80154a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801551:	83 ec 0c             	sub    $0xc,%esp
  801554:	25 07 0e 00 00       	and    $0xe07,%eax
  801559:	50                   	push   %eax
  80155a:	57                   	push   %edi
  80155b:	6a 00                	push   $0x0
  80155d:	53                   	push   %ebx
  80155e:	6a 00                	push   $0x0
  801560:	e8 8a f7 ff ff       	call   800cef <sys_page_map>
  801565:	89 c3                	mov    %eax,%ebx
  801567:	83 c4 20             	add    $0x20,%esp
  80156a:	85 c0                	test   %eax,%eax
  80156c:	79 a3                	jns    801511 <dup+0x74>
	sys_page_unmap(0, newfd);
  80156e:	83 ec 08             	sub    $0x8,%esp
  801571:	56                   	push   %esi
  801572:	6a 00                	push   $0x0
  801574:	e8 b8 f7 ff ff       	call   800d31 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801579:	83 c4 08             	add    $0x8,%esp
  80157c:	57                   	push   %edi
  80157d:	6a 00                	push   $0x0
  80157f:	e8 ad f7 ff ff       	call   800d31 <sys_page_unmap>
	return r;
  801584:	83 c4 10             	add    $0x10,%esp
  801587:	eb b7                	jmp    801540 <dup+0xa3>

00801589 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801589:	55                   	push   %ebp
  80158a:	89 e5                	mov    %esp,%ebp
  80158c:	53                   	push   %ebx
  80158d:	83 ec 14             	sub    $0x14,%esp
  801590:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801593:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801596:	50                   	push   %eax
  801597:	53                   	push   %ebx
  801598:	e8 7b fd ff ff       	call   801318 <fd_lookup>
  80159d:	83 c4 08             	add    $0x8,%esp
  8015a0:	85 c0                	test   %eax,%eax
  8015a2:	78 3f                	js     8015e3 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a4:	83 ec 08             	sub    $0x8,%esp
  8015a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015aa:	50                   	push   %eax
  8015ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ae:	ff 30                	pushl  (%eax)
  8015b0:	e8 b9 fd ff ff       	call   80136e <dev_lookup>
  8015b5:	83 c4 10             	add    $0x10,%esp
  8015b8:	85 c0                	test   %eax,%eax
  8015ba:	78 27                	js     8015e3 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015bc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015bf:	8b 42 08             	mov    0x8(%edx),%eax
  8015c2:	83 e0 03             	and    $0x3,%eax
  8015c5:	83 f8 01             	cmp    $0x1,%eax
  8015c8:	74 1e                	je     8015e8 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8015ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015cd:	8b 40 08             	mov    0x8(%eax),%eax
  8015d0:	85 c0                	test   %eax,%eax
  8015d2:	74 35                	je     801609 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015d4:	83 ec 04             	sub    $0x4,%esp
  8015d7:	ff 75 10             	pushl  0x10(%ebp)
  8015da:	ff 75 0c             	pushl  0xc(%ebp)
  8015dd:	52                   	push   %edx
  8015de:	ff d0                	call   *%eax
  8015e0:	83 c4 10             	add    $0x10,%esp
}
  8015e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015e6:	c9                   	leave  
  8015e7:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015e8:	a1 04 40 80 00       	mov    0x804004,%eax
  8015ed:	8b 40 48             	mov    0x48(%eax),%eax
  8015f0:	83 ec 04             	sub    $0x4,%esp
  8015f3:	53                   	push   %ebx
  8015f4:	50                   	push   %eax
  8015f5:	68 35 28 80 00       	push   $0x802835
  8015fa:	e8 95 ec ff ff       	call   800294 <cprintf>
		return -E_INVAL;
  8015ff:	83 c4 10             	add    $0x10,%esp
  801602:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801607:	eb da                	jmp    8015e3 <read+0x5a>
		return -E_NOT_SUPP;
  801609:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80160e:	eb d3                	jmp    8015e3 <read+0x5a>

00801610 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801610:	55                   	push   %ebp
  801611:	89 e5                	mov    %esp,%ebp
  801613:	57                   	push   %edi
  801614:	56                   	push   %esi
  801615:	53                   	push   %ebx
  801616:	83 ec 0c             	sub    $0xc,%esp
  801619:	8b 7d 08             	mov    0x8(%ebp),%edi
  80161c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80161f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801624:	39 f3                	cmp    %esi,%ebx
  801626:	73 25                	jae    80164d <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801628:	83 ec 04             	sub    $0x4,%esp
  80162b:	89 f0                	mov    %esi,%eax
  80162d:	29 d8                	sub    %ebx,%eax
  80162f:	50                   	push   %eax
  801630:	89 d8                	mov    %ebx,%eax
  801632:	03 45 0c             	add    0xc(%ebp),%eax
  801635:	50                   	push   %eax
  801636:	57                   	push   %edi
  801637:	e8 4d ff ff ff       	call   801589 <read>
		if (m < 0)
  80163c:	83 c4 10             	add    $0x10,%esp
  80163f:	85 c0                	test   %eax,%eax
  801641:	78 08                	js     80164b <readn+0x3b>
			return m;
		if (m == 0)
  801643:	85 c0                	test   %eax,%eax
  801645:	74 06                	je     80164d <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  801647:	01 c3                	add    %eax,%ebx
  801649:	eb d9                	jmp    801624 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80164b:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80164d:	89 d8                	mov    %ebx,%eax
  80164f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801652:	5b                   	pop    %ebx
  801653:	5e                   	pop    %esi
  801654:	5f                   	pop    %edi
  801655:	5d                   	pop    %ebp
  801656:	c3                   	ret    

00801657 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801657:	55                   	push   %ebp
  801658:	89 e5                	mov    %esp,%ebp
  80165a:	53                   	push   %ebx
  80165b:	83 ec 14             	sub    $0x14,%esp
  80165e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801661:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801664:	50                   	push   %eax
  801665:	53                   	push   %ebx
  801666:	e8 ad fc ff ff       	call   801318 <fd_lookup>
  80166b:	83 c4 08             	add    $0x8,%esp
  80166e:	85 c0                	test   %eax,%eax
  801670:	78 3a                	js     8016ac <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801672:	83 ec 08             	sub    $0x8,%esp
  801675:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801678:	50                   	push   %eax
  801679:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80167c:	ff 30                	pushl  (%eax)
  80167e:	e8 eb fc ff ff       	call   80136e <dev_lookup>
  801683:	83 c4 10             	add    $0x10,%esp
  801686:	85 c0                	test   %eax,%eax
  801688:	78 22                	js     8016ac <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80168a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80168d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801691:	74 1e                	je     8016b1 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801693:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801696:	8b 52 0c             	mov    0xc(%edx),%edx
  801699:	85 d2                	test   %edx,%edx
  80169b:	74 35                	je     8016d2 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80169d:	83 ec 04             	sub    $0x4,%esp
  8016a0:	ff 75 10             	pushl  0x10(%ebp)
  8016a3:	ff 75 0c             	pushl  0xc(%ebp)
  8016a6:	50                   	push   %eax
  8016a7:	ff d2                	call   *%edx
  8016a9:	83 c4 10             	add    $0x10,%esp
}
  8016ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016af:	c9                   	leave  
  8016b0:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016b1:	a1 04 40 80 00       	mov    0x804004,%eax
  8016b6:	8b 40 48             	mov    0x48(%eax),%eax
  8016b9:	83 ec 04             	sub    $0x4,%esp
  8016bc:	53                   	push   %ebx
  8016bd:	50                   	push   %eax
  8016be:	68 51 28 80 00       	push   $0x802851
  8016c3:	e8 cc eb ff ff       	call   800294 <cprintf>
		return -E_INVAL;
  8016c8:	83 c4 10             	add    $0x10,%esp
  8016cb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016d0:	eb da                	jmp    8016ac <write+0x55>
		return -E_NOT_SUPP;
  8016d2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016d7:	eb d3                	jmp    8016ac <write+0x55>

008016d9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8016d9:	55                   	push   %ebp
  8016da:	89 e5                	mov    %esp,%ebp
  8016dc:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016df:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016e2:	50                   	push   %eax
  8016e3:	ff 75 08             	pushl  0x8(%ebp)
  8016e6:	e8 2d fc ff ff       	call   801318 <fd_lookup>
  8016eb:	83 c4 08             	add    $0x8,%esp
  8016ee:	85 c0                	test   %eax,%eax
  8016f0:	78 0e                	js     801700 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016f8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801700:	c9                   	leave  
  801701:	c3                   	ret    

00801702 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801702:	55                   	push   %ebp
  801703:	89 e5                	mov    %esp,%ebp
  801705:	53                   	push   %ebx
  801706:	83 ec 14             	sub    $0x14,%esp
  801709:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80170c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80170f:	50                   	push   %eax
  801710:	53                   	push   %ebx
  801711:	e8 02 fc ff ff       	call   801318 <fd_lookup>
  801716:	83 c4 08             	add    $0x8,%esp
  801719:	85 c0                	test   %eax,%eax
  80171b:	78 37                	js     801754 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80171d:	83 ec 08             	sub    $0x8,%esp
  801720:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801723:	50                   	push   %eax
  801724:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801727:	ff 30                	pushl  (%eax)
  801729:	e8 40 fc ff ff       	call   80136e <dev_lookup>
  80172e:	83 c4 10             	add    $0x10,%esp
  801731:	85 c0                	test   %eax,%eax
  801733:	78 1f                	js     801754 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801735:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801738:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80173c:	74 1b                	je     801759 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80173e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801741:	8b 52 18             	mov    0x18(%edx),%edx
  801744:	85 d2                	test   %edx,%edx
  801746:	74 32                	je     80177a <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801748:	83 ec 08             	sub    $0x8,%esp
  80174b:	ff 75 0c             	pushl  0xc(%ebp)
  80174e:	50                   	push   %eax
  80174f:	ff d2                	call   *%edx
  801751:	83 c4 10             	add    $0x10,%esp
}
  801754:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801757:	c9                   	leave  
  801758:	c3                   	ret    
			thisenv->env_id, fdnum);
  801759:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80175e:	8b 40 48             	mov    0x48(%eax),%eax
  801761:	83 ec 04             	sub    $0x4,%esp
  801764:	53                   	push   %ebx
  801765:	50                   	push   %eax
  801766:	68 14 28 80 00       	push   $0x802814
  80176b:	e8 24 eb ff ff       	call   800294 <cprintf>
		return -E_INVAL;
  801770:	83 c4 10             	add    $0x10,%esp
  801773:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801778:	eb da                	jmp    801754 <ftruncate+0x52>
		return -E_NOT_SUPP;
  80177a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80177f:	eb d3                	jmp    801754 <ftruncate+0x52>

00801781 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801781:	55                   	push   %ebp
  801782:	89 e5                	mov    %esp,%ebp
  801784:	53                   	push   %ebx
  801785:	83 ec 14             	sub    $0x14,%esp
  801788:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80178b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80178e:	50                   	push   %eax
  80178f:	ff 75 08             	pushl  0x8(%ebp)
  801792:	e8 81 fb ff ff       	call   801318 <fd_lookup>
  801797:	83 c4 08             	add    $0x8,%esp
  80179a:	85 c0                	test   %eax,%eax
  80179c:	78 4b                	js     8017e9 <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80179e:	83 ec 08             	sub    $0x8,%esp
  8017a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017a4:	50                   	push   %eax
  8017a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a8:	ff 30                	pushl  (%eax)
  8017aa:	e8 bf fb ff ff       	call   80136e <dev_lookup>
  8017af:	83 c4 10             	add    $0x10,%esp
  8017b2:	85 c0                	test   %eax,%eax
  8017b4:	78 33                	js     8017e9 <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  8017b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017b9:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017bd:	74 2f                	je     8017ee <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017bf:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017c2:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017c9:	00 00 00 
	stat->st_isdir = 0;
  8017cc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017d3:	00 00 00 
	stat->st_dev = dev;
  8017d6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017dc:	83 ec 08             	sub    $0x8,%esp
  8017df:	53                   	push   %ebx
  8017e0:	ff 75 f0             	pushl  -0x10(%ebp)
  8017e3:	ff 50 14             	call   *0x14(%eax)
  8017e6:	83 c4 10             	add    $0x10,%esp
}
  8017e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017ec:	c9                   	leave  
  8017ed:	c3                   	ret    
		return -E_NOT_SUPP;
  8017ee:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017f3:	eb f4                	jmp    8017e9 <fstat+0x68>

008017f5 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017f5:	55                   	push   %ebp
  8017f6:	89 e5                	mov    %esp,%ebp
  8017f8:	56                   	push   %esi
  8017f9:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017fa:	83 ec 08             	sub    $0x8,%esp
  8017fd:	6a 00                	push   $0x0
  8017ff:	ff 75 08             	pushl  0x8(%ebp)
  801802:	e8 e7 01 00 00       	call   8019ee <open>
  801807:	89 c3                	mov    %eax,%ebx
  801809:	83 c4 10             	add    $0x10,%esp
  80180c:	85 c0                	test   %eax,%eax
  80180e:	78 1b                	js     80182b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801810:	83 ec 08             	sub    $0x8,%esp
  801813:	ff 75 0c             	pushl  0xc(%ebp)
  801816:	50                   	push   %eax
  801817:	e8 65 ff ff ff       	call   801781 <fstat>
  80181c:	89 c6                	mov    %eax,%esi
	close(fd);
  80181e:	89 1c 24             	mov    %ebx,(%esp)
  801821:	e8 27 fc ff ff       	call   80144d <close>
	return r;
  801826:	83 c4 10             	add    $0x10,%esp
  801829:	89 f3                	mov    %esi,%ebx
}
  80182b:	89 d8                	mov    %ebx,%eax
  80182d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801830:	5b                   	pop    %ebx
  801831:	5e                   	pop    %esi
  801832:	5d                   	pop    %ebp
  801833:	c3                   	ret    

00801834 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801834:	55                   	push   %ebp
  801835:	89 e5                	mov    %esp,%ebp
  801837:	56                   	push   %esi
  801838:	53                   	push   %ebx
  801839:	89 c6                	mov    %eax,%esi
  80183b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80183d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801844:	74 27                	je     80186d <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801846:	6a 07                	push   $0x7
  801848:	68 00 50 80 00       	push   $0x805000
  80184d:	56                   	push   %esi
  80184e:	ff 35 00 40 80 00    	pushl  0x804000
  801854:	e8 ba f9 ff ff       	call   801213 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801859:	83 c4 0c             	add    $0xc,%esp
  80185c:	6a 00                	push   $0x0
  80185e:	53                   	push   %ebx
  80185f:	6a 00                	push   $0x0
  801861:	e8 38 f9 ff ff       	call   80119e <ipc_recv>
}
  801866:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801869:	5b                   	pop    %ebx
  80186a:	5e                   	pop    %esi
  80186b:	5d                   	pop    %ebp
  80186c:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80186d:	83 ec 0c             	sub    $0xc,%esp
  801870:	6a 01                	push   $0x1
  801872:	e8 f2 f9 ff ff       	call   801269 <ipc_find_env>
  801877:	a3 00 40 80 00       	mov    %eax,0x804000
  80187c:	83 c4 10             	add    $0x10,%esp
  80187f:	eb c5                	jmp    801846 <fsipc+0x12>

00801881 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801881:	55                   	push   %ebp
  801882:	89 e5                	mov    %esp,%ebp
  801884:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801887:	8b 45 08             	mov    0x8(%ebp),%eax
  80188a:	8b 40 0c             	mov    0xc(%eax),%eax
  80188d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801892:	8b 45 0c             	mov    0xc(%ebp),%eax
  801895:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80189a:	ba 00 00 00 00       	mov    $0x0,%edx
  80189f:	b8 02 00 00 00       	mov    $0x2,%eax
  8018a4:	e8 8b ff ff ff       	call   801834 <fsipc>
}
  8018a9:	c9                   	leave  
  8018aa:	c3                   	ret    

008018ab <devfile_flush>:
{
  8018ab:	55                   	push   %ebp
  8018ac:	89 e5                	mov    %esp,%ebp
  8018ae:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b4:	8b 40 0c             	mov    0xc(%eax),%eax
  8018b7:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c1:	b8 06 00 00 00       	mov    $0x6,%eax
  8018c6:	e8 69 ff ff ff       	call   801834 <fsipc>
}
  8018cb:	c9                   	leave  
  8018cc:	c3                   	ret    

008018cd <devfile_stat>:
{
  8018cd:	55                   	push   %ebp
  8018ce:	89 e5                	mov    %esp,%ebp
  8018d0:	53                   	push   %ebx
  8018d1:	83 ec 04             	sub    $0x4,%esp
  8018d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018da:	8b 40 0c             	mov    0xc(%eax),%eax
  8018dd:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e7:	b8 05 00 00 00       	mov    $0x5,%eax
  8018ec:	e8 43 ff ff ff       	call   801834 <fsipc>
  8018f1:	85 c0                	test   %eax,%eax
  8018f3:	78 2c                	js     801921 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018f5:	83 ec 08             	sub    $0x8,%esp
  8018f8:	68 00 50 80 00       	push   $0x805000
  8018fd:	53                   	push   %ebx
  8018fe:	e8 b0 ef ff ff       	call   8008b3 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801903:	a1 80 50 80 00       	mov    0x805080,%eax
  801908:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80190e:	a1 84 50 80 00       	mov    0x805084,%eax
  801913:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801919:	83 c4 10             	add    $0x10,%esp
  80191c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801921:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801924:	c9                   	leave  
  801925:	c3                   	ret    

00801926 <devfile_write>:
{
  801926:	55                   	push   %ebp
  801927:	89 e5                	mov    %esp,%ebp
  801929:	83 ec 0c             	sub    $0xc,%esp
  80192c:	8b 45 10             	mov    0x10(%ebp),%eax
  80192f:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801934:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801939:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80193c:	8b 55 08             	mov    0x8(%ebp),%edx
  80193f:	8b 52 0c             	mov    0xc(%edx),%edx
  801942:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801948:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf,buf,n);
  80194d:	50                   	push   %eax
  80194e:	ff 75 0c             	pushl  0xc(%ebp)
  801951:	68 08 50 80 00       	push   $0x805008
  801956:	e8 e6 f0 ff ff       	call   800a41 <memmove>
	if((r = fsipc(FSREQ_WRITE,NULL))<0)
  80195b:	ba 00 00 00 00       	mov    $0x0,%edx
  801960:	b8 04 00 00 00       	mov    $0x4,%eax
  801965:	e8 ca fe ff ff       	call   801834 <fsipc>
}
  80196a:	c9                   	leave  
  80196b:	c3                   	ret    

0080196c <devfile_read>:
{
  80196c:	55                   	push   %ebp
  80196d:	89 e5                	mov    %esp,%ebp
  80196f:	56                   	push   %esi
  801970:	53                   	push   %ebx
  801971:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801974:	8b 45 08             	mov    0x8(%ebp),%eax
  801977:	8b 40 0c             	mov    0xc(%eax),%eax
  80197a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80197f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801985:	ba 00 00 00 00       	mov    $0x0,%edx
  80198a:	b8 03 00 00 00       	mov    $0x3,%eax
  80198f:	e8 a0 fe ff ff       	call   801834 <fsipc>
  801994:	89 c3                	mov    %eax,%ebx
  801996:	85 c0                	test   %eax,%eax
  801998:	78 1f                	js     8019b9 <devfile_read+0x4d>
	assert(r <= n);
  80199a:	39 f0                	cmp    %esi,%eax
  80199c:	77 24                	ja     8019c2 <devfile_read+0x56>
	assert(r <= PGSIZE);
  80199e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019a3:	7f 33                	jg     8019d8 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019a5:	83 ec 04             	sub    $0x4,%esp
  8019a8:	50                   	push   %eax
  8019a9:	68 00 50 80 00       	push   $0x805000
  8019ae:	ff 75 0c             	pushl  0xc(%ebp)
  8019b1:	e8 8b f0 ff ff       	call   800a41 <memmove>
	return r;
  8019b6:	83 c4 10             	add    $0x10,%esp
}
  8019b9:	89 d8                	mov    %ebx,%eax
  8019bb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019be:	5b                   	pop    %ebx
  8019bf:	5e                   	pop    %esi
  8019c0:	5d                   	pop    %ebp
  8019c1:	c3                   	ret    
	assert(r <= n);
  8019c2:	68 80 28 80 00       	push   $0x802880
  8019c7:	68 87 28 80 00       	push   $0x802887
  8019cc:	6a 7c                	push   $0x7c
  8019ce:	68 9c 28 80 00       	push   $0x80289c
  8019d3:	e8 85 05 00 00       	call   801f5d <_panic>
	assert(r <= PGSIZE);
  8019d8:	68 a7 28 80 00       	push   $0x8028a7
  8019dd:	68 87 28 80 00       	push   $0x802887
  8019e2:	6a 7d                	push   $0x7d
  8019e4:	68 9c 28 80 00       	push   $0x80289c
  8019e9:	e8 6f 05 00 00       	call   801f5d <_panic>

008019ee <open>:
{
  8019ee:	55                   	push   %ebp
  8019ef:	89 e5                	mov    %esp,%ebp
  8019f1:	56                   	push   %esi
  8019f2:	53                   	push   %ebx
  8019f3:	83 ec 1c             	sub    $0x1c,%esp
  8019f6:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8019f9:	56                   	push   %esi
  8019fa:	e8 7d ee ff ff       	call   80087c <strlen>
  8019ff:	83 c4 10             	add    $0x10,%esp
  801a02:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a07:	7f 6c                	jg     801a75 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801a09:	83 ec 0c             	sub    $0xc,%esp
  801a0c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a0f:	50                   	push   %eax
  801a10:	e8 b4 f8 ff ff       	call   8012c9 <fd_alloc>
  801a15:	89 c3                	mov    %eax,%ebx
  801a17:	83 c4 10             	add    $0x10,%esp
  801a1a:	85 c0                	test   %eax,%eax
  801a1c:	78 3c                	js     801a5a <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801a1e:	83 ec 08             	sub    $0x8,%esp
  801a21:	56                   	push   %esi
  801a22:	68 00 50 80 00       	push   $0x805000
  801a27:	e8 87 ee ff ff       	call   8008b3 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a2f:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a34:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a37:	b8 01 00 00 00       	mov    $0x1,%eax
  801a3c:	e8 f3 fd ff ff       	call   801834 <fsipc>
  801a41:	89 c3                	mov    %eax,%ebx
  801a43:	83 c4 10             	add    $0x10,%esp
  801a46:	85 c0                	test   %eax,%eax
  801a48:	78 19                	js     801a63 <open+0x75>
	return fd2num(fd);
  801a4a:	83 ec 0c             	sub    $0xc,%esp
  801a4d:	ff 75 f4             	pushl  -0xc(%ebp)
  801a50:	e8 4d f8 ff ff       	call   8012a2 <fd2num>
  801a55:	89 c3                	mov    %eax,%ebx
  801a57:	83 c4 10             	add    $0x10,%esp
}
  801a5a:	89 d8                	mov    %ebx,%eax
  801a5c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a5f:	5b                   	pop    %ebx
  801a60:	5e                   	pop    %esi
  801a61:	5d                   	pop    %ebp
  801a62:	c3                   	ret    
		fd_close(fd, 0);
  801a63:	83 ec 08             	sub    $0x8,%esp
  801a66:	6a 00                	push   $0x0
  801a68:	ff 75 f4             	pushl  -0xc(%ebp)
  801a6b:	e8 54 f9 ff ff       	call   8013c4 <fd_close>
		return r;
  801a70:	83 c4 10             	add    $0x10,%esp
  801a73:	eb e5                	jmp    801a5a <open+0x6c>
		return -E_BAD_PATH;
  801a75:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801a7a:	eb de                	jmp    801a5a <open+0x6c>

00801a7c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a7c:	55                   	push   %ebp
  801a7d:	89 e5                	mov    %esp,%ebp
  801a7f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a82:	ba 00 00 00 00       	mov    $0x0,%edx
  801a87:	b8 08 00 00 00       	mov    $0x8,%eax
  801a8c:	e8 a3 fd ff ff       	call   801834 <fsipc>
}
  801a91:	c9                   	leave  
  801a92:	c3                   	ret    

00801a93 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a93:	55                   	push   %ebp
  801a94:	89 e5                	mov    %esp,%ebp
  801a96:	56                   	push   %esi
  801a97:	53                   	push   %ebx
  801a98:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a9b:	83 ec 0c             	sub    $0xc,%esp
  801a9e:	ff 75 08             	pushl  0x8(%ebp)
  801aa1:	e8 0c f8 ff ff       	call   8012b2 <fd2data>
  801aa6:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801aa8:	83 c4 08             	add    $0x8,%esp
  801aab:	68 b3 28 80 00       	push   $0x8028b3
  801ab0:	53                   	push   %ebx
  801ab1:	e8 fd ed ff ff       	call   8008b3 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ab6:	8b 46 04             	mov    0x4(%esi),%eax
  801ab9:	2b 06                	sub    (%esi),%eax
  801abb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ac1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ac8:	00 00 00 
	stat->st_dev = &devpipe;
  801acb:	c7 83 88 00 00 00 28 	movl   $0x803028,0x88(%ebx)
  801ad2:	30 80 00 
	return 0;
}
  801ad5:	b8 00 00 00 00       	mov    $0x0,%eax
  801ada:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801add:	5b                   	pop    %ebx
  801ade:	5e                   	pop    %esi
  801adf:	5d                   	pop    %ebp
  801ae0:	c3                   	ret    

00801ae1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ae1:	55                   	push   %ebp
  801ae2:	89 e5                	mov    %esp,%ebp
  801ae4:	53                   	push   %ebx
  801ae5:	83 ec 0c             	sub    $0xc,%esp
  801ae8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801aeb:	53                   	push   %ebx
  801aec:	6a 00                	push   $0x0
  801aee:	e8 3e f2 ff ff       	call   800d31 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801af3:	89 1c 24             	mov    %ebx,(%esp)
  801af6:	e8 b7 f7 ff ff       	call   8012b2 <fd2data>
  801afb:	83 c4 08             	add    $0x8,%esp
  801afe:	50                   	push   %eax
  801aff:	6a 00                	push   $0x0
  801b01:	e8 2b f2 ff ff       	call   800d31 <sys_page_unmap>
}
  801b06:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b09:	c9                   	leave  
  801b0a:	c3                   	ret    

00801b0b <_pipeisclosed>:
{
  801b0b:	55                   	push   %ebp
  801b0c:	89 e5                	mov    %esp,%ebp
  801b0e:	57                   	push   %edi
  801b0f:	56                   	push   %esi
  801b10:	53                   	push   %ebx
  801b11:	83 ec 1c             	sub    $0x1c,%esp
  801b14:	89 c7                	mov    %eax,%edi
  801b16:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801b18:	a1 04 40 80 00       	mov    0x804004,%eax
  801b1d:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801b20:	83 ec 0c             	sub    $0xc,%esp
  801b23:	57                   	push   %edi
  801b24:	e8 06 05 00 00       	call   80202f <pageref>
  801b29:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801b2c:	89 34 24             	mov    %esi,(%esp)
  801b2f:	e8 fb 04 00 00       	call   80202f <pageref>
		nn = thisenv->env_runs;
  801b34:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b3a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b3d:	83 c4 10             	add    $0x10,%esp
  801b40:	39 cb                	cmp    %ecx,%ebx
  801b42:	74 1b                	je     801b5f <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801b44:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b47:	75 cf                	jne    801b18 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b49:	8b 42 58             	mov    0x58(%edx),%eax
  801b4c:	6a 01                	push   $0x1
  801b4e:	50                   	push   %eax
  801b4f:	53                   	push   %ebx
  801b50:	68 ba 28 80 00       	push   $0x8028ba
  801b55:	e8 3a e7 ff ff       	call   800294 <cprintf>
  801b5a:	83 c4 10             	add    $0x10,%esp
  801b5d:	eb b9                	jmp    801b18 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801b5f:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b62:	0f 94 c0             	sete   %al
  801b65:	0f b6 c0             	movzbl %al,%eax
}
  801b68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b6b:	5b                   	pop    %ebx
  801b6c:	5e                   	pop    %esi
  801b6d:	5f                   	pop    %edi
  801b6e:	5d                   	pop    %ebp
  801b6f:	c3                   	ret    

00801b70 <devpipe_write>:
{
  801b70:	55                   	push   %ebp
  801b71:	89 e5                	mov    %esp,%ebp
  801b73:	57                   	push   %edi
  801b74:	56                   	push   %esi
  801b75:	53                   	push   %ebx
  801b76:	83 ec 28             	sub    $0x28,%esp
  801b79:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801b7c:	56                   	push   %esi
  801b7d:	e8 30 f7 ff ff       	call   8012b2 <fd2data>
  801b82:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b84:	83 c4 10             	add    $0x10,%esp
  801b87:	bf 00 00 00 00       	mov    $0x0,%edi
  801b8c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b8f:	74 4f                	je     801be0 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b91:	8b 43 04             	mov    0x4(%ebx),%eax
  801b94:	8b 0b                	mov    (%ebx),%ecx
  801b96:	8d 51 20             	lea    0x20(%ecx),%edx
  801b99:	39 d0                	cmp    %edx,%eax
  801b9b:	72 14                	jb     801bb1 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801b9d:	89 da                	mov    %ebx,%edx
  801b9f:	89 f0                	mov    %esi,%eax
  801ba1:	e8 65 ff ff ff       	call   801b0b <_pipeisclosed>
  801ba6:	85 c0                	test   %eax,%eax
  801ba8:	75 3a                	jne    801be4 <devpipe_write+0x74>
			sys_yield();
  801baa:	e8 de f0 ff ff       	call   800c8d <sys_yield>
  801baf:	eb e0                	jmp    801b91 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bb4:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801bb8:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801bbb:	89 c2                	mov    %eax,%edx
  801bbd:	c1 fa 1f             	sar    $0x1f,%edx
  801bc0:	89 d1                	mov    %edx,%ecx
  801bc2:	c1 e9 1b             	shr    $0x1b,%ecx
  801bc5:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801bc8:	83 e2 1f             	and    $0x1f,%edx
  801bcb:	29 ca                	sub    %ecx,%edx
  801bcd:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bd1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bd5:	83 c0 01             	add    $0x1,%eax
  801bd8:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801bdb:	83 c7 01             	add    $0x1,%edi
  801bde:	eb ac                	jmp    801b8c <devpipe_write+0x1c>
	return i;
  801be0:	89 f8                	mov    %edi,%eax
  801be2:	eb 05                	jmp    801be9 <devpipe_write+0x79>
				return 0;
  801be4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801be9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bec:	5b                   	pop    %ebx
  801bed:	5e                   	pop    %esi
  801bee:	5f                   	pop    %edi
  801bef:	5d                   	pop    %ebp
  801bf0:	c3                   	ret    

00801bf1 <devpipe_read>:
{
  801bf1:	55                   	push   %ebp
  801bf2:	89 e5                	mov    %esp,%ebp
  801bf4:	57                   	push   %edi
  801bf5:	56                   	push   %esi
  801bf6:	53                   	push   %ebx
  801bf7:	83 ec 18             	sub    $0x18,%esp
  801bfa:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801bfd:	57                   	push   %edi
  801bfe:	e8 af f6 ff ff       	call   8012b2 <fd2data>
  801c03:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c05:	83 c4 10             	add    $0x10,%esp
  801c08:	be 00 00 00 00       	mov    $0x0,%esi
  801c0d:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c10:	74 47                	je     801c59 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  801c12:	8b 03                	mov    (%ebx),%eax
  801c14:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c17:	75 22                	jne    801c3b <devpipe_read+0x4a>
			if (i > 0)
  801c19:	85 f6                	test   %esi,%esi
  801c1b:	75 14                	jne    801c31 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801c1d:	89 da                	mov    %ebx,%edx
  801c1f:	89 f8                	mov    %edi,%eax
  801c21:	e8 e5 fe ff ff       	call   801b0b <_pipeisclosed>
  801c26:	85 c0                	test   %eax,%eax
  801c28:	75 33                	jne    801c5d <devpipe_read+0x6c>
			sys_yield();
  801c2a:	e8 5e f0 ff ff       	call   800c8d <sys_yield>
  801c2f:	eb e1                	jmp    801c12 <devpipe_read+0x21>
				return i;
  801c31:	89 f0                	mov    %esi,%eax
}
  801c33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c36:	5b                   	pop    %ebx
  801c37:	5e                   	pop    %esi
  801c38:	5f                   	pop    %edi
  801c39:	5d                   	pop    %ebp
  801c3a:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c3b:	99                   	cltd   
  801c3c:	c1 ea 1b             	shr    $0x1b,%edx
  801c3f:	01 d0                	add    %edx,%eax
  801c41:	83 e0 1f             	and    $0x1f,%eax
  801c44:	29 d0                	sub    %edx,%eax
  801c46:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801c4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c4e:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801c51:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801c54:	83 c6 01             	add    $0x1,%esi
  801c57:	eb b4                	jmp    801c0d <devpipe_read+0x1c>
	return i;
  801c59:	89 f0                	mov    %esi,%eax
  801c5b:	eb d6                	jmp    801c33 <devpipe_read+0x42>
				return 0;
  801c5d:	b8 00 00 00 00       	mov    $0x0,%eax
  801c62:	eb cf                	jmp    801c33 <devpipe_read+0x42>

00801c64 <pipe>:
{
  801c64:	55                   	push   %ebp
  801c65:	89 e5                	mov    %esp,%ebp
  801c67:	56                   	push   %esi
  801c68:	53                   	push   %ebx
  801c69:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801c6c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c6f:	50                   	push   %eax
  801c70:	e8 54 f6 ff ff       	call   8012c9 <fd_alloc>
  801c75:	89 c3                	mov    %eax,%ebx
  801c77:	83 c4 10             	add    $0x10,%esp
  801c7a:	85 c0                	test   %eax,%eax
  801c7c:	78 5b                	js     801cd9 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c7e:	83 ec 04             	sub    $0x4,%esp
  801c81:	68 07 04 00 00       	push   $0x407
  801c86:	ff 75 f4             	pushl  -0xc(%ebp)
  801c89:	6a 00                	push   $0x0
  801c8b:	e8 1c f0 ff ff       	call   800cac <sys_page_alloc>
  801c90:	89 c3                	mov    %eax,%ebx
  801c92:	83 c4 10             	add    $0x10,%esp
  801c95:	85 c0                	test   %eax,%eax
  801c97:	78 40                	js     801cd9 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  801c99:	83 ec 0c             	sub    $0xc,%esp
  801c9c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c9f:	50                   	push   %eax
  801ca0:	e8 24 f6 ff ff       	call   8012c9 <fd_alloc>
  801ca5:	89 c3                	mov    %eax,%ebx
  801ca7:	83 c4 10             	add    $0x10,%esp
  801caa:	85 c0                	test   %eax,%eax
  801cac:	78 1b                	js     801cc9 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cae:	83 ec 04             	sub    $0x4,%esp
  801cb1:	68 07 04 00 00       	push   $0x407
  801cb6:	ff 75 f0             	pushl  -0x10(%ebp)
  801cb9:	6a 00                	push   $0x0
  801cbb:	e8 ec ef ff ff       	call   800cac <sys_page_alloc>
  801cc0:	89 c3                	mov    %eax,%ebx
  801cc2:	83 c4 10             	add    $0x10,%esp
  801cc5:	85 c0                	test   %eax,%eax
  801cc7:	79 19                	jns    801ce2 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  801cc9:	83 ec 08             	sub    $0x8,%esp
  801ccc:	ff 75 f4             	pushl  -0xc(%ebp)
  801ccf:	6a 00                	push   $0x0
  801cd1:	e8 5b f0 ff ff       	call   800d31 <sys_page_unmap>
  801cd6:	83 c4 10             	add    $0x10,%esp
}
  801cd9:	89 d8                	mov    %ebx,%eax
  801cdb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cde:	5b                   	pop    %ebx
  801cdf:	5e                   	pop    %esi
  801ce0:	5d                   	pop    %ebp
  801ce1:	c3                   	ret    
	va = fd2data(fd0);
  801ce2:	83 ec 0c             	sub    $0xc,%esp
  801ce5:	ff 75 f4             	pushl  -0xc(%ebp)
  801ce8:	e8 c5 f5 ff ff       	call   8012b2 <fd2data>
  801ced:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cef:	83 c4 0c             	add    $0xc,%esp
  801cf2:	68 07 04 00 00       	push   $0x407
  801cf7:	50                   	push   %eax
  801cf8:	6a 00                	push   $0x0
  801cfa:	e8 ad ef ff ff       	call   800cac <sys_page_alloc>
  801cff:	89 c3                	mov    %eax,%ebx
  801d01:	83 c4 10             	add    $0x10,%esp
  801d04:	85 c0                	test   %eax,%eax
  801d06:	0f 88 8c 00 00 00    	js     801d98 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d0c:	83 ec 0c             	sub    $0xc,%esp
  801d0f:	ff 75 f0             	pushl  -0x10(%ebp)
  801d12:	e8 9b f5 ff ff       	call   8012b2 <fd2data>
  801d17:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d1e:	50                   	push   %eax
  801d1f:	6a 00                	push   $0x0
  801d21:	56                   	push   %esi
  801d22:	6a 00                	push   $0x0
  801d24:	e8 c6 ef ff ff       	call   800cef <sys_page_map>
  801d29:	89 c3                	mov    %eax,%ebx
  801d2b:	83 c4 20             	add    $0x20,%esp
  801d2e:	85 c0                	test   %eax,%eax
  801d30:	78 58                	js     801d8a <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801d32:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d35:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801d3b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d40:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801d47:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d4a:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801d50:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d52:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d55:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801d5c:	83 ec 0c             	sub    $0xc,%esp
  801d5f:	ff 75 f4             	pushl  -0xc(%ebp)
  801d62:	e8 3b f5 ff ff       	call   8012a2 <fd2num>
  801d67:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d6a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d6c:	83 c4 04             	add    $0x4,%esp
  801d6f:	ff 75 f0             	pushl  -0x10(%ebp)
  801d72:	e8 2b f5 ff ff       	call   8012a2 <fd2num>
  801d77:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d7a:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d7d:	83 c4 10             	add    $0x10,%esp
  801d80:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d85:	e9 4f ff ff ff       	jmp    801cd9 <pipe+0x75>
	sys_page_unmap(0, va);
  801d8a:	83 ec 08             	sub    $0x8,%esp
  801d8d:	56                   	push   %esi
  801d8e:	6a 00                	push   $0x0
  801d90:	e8 9c ef ff ff       	call   800d31 <sys_page_unmap>
  801d95:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801d98:	83 ec 08             	sub    $0x8,%esp
  801d9b:	ff 75 f0             	pushl  -0x10(%ebp)
  801d9e:	6a 00                	push   $0x0
  801da0:	e8 8c ef ff ff       	call   800d31 <sys_page_unmap>
  801da5:	83 c4 10             	add    $0x10,%esp
  801da8:	e9 1c ff ff ff       	jmp    801cc9 <pipe+0x65>

00801dad <pipeisclosed>:
{
  801dad:	55                   	push   %ebp
  801dae:	89 e5                	mov    %esp,%ebp
  801db0:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801db3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801db6:	50                   	push   %eax
  801db7:	ff 75 08             	pushl  0x8(%ebp)
  801dba:	e8 59 f5 ff ff       	call   801318 <fd_lookup>
  801dbf:	83 c4 10             	add    $0x10,%esp
  801dc2:	85 c0                	test   %eax,%eax
  801dc4:	78 18                	js     801dde <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801dc6:	83 ec 0c             	sub    $0xc,%esp
  801dc9:	ff 75 f4             	pushl  -0xc(%ebp)
  801dcc:	e8 e1 f4 ff ff       	call   8012b2 <fd2data>
	return _pipeisclosed(fd, p);
  801dd1:	89 c2                	mov    %eax,%edx
  801dd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dd6:	e8 30 fd ff ff       	call   801b0b <_pipeisclosed>
  801ddb:	83 c4 10             	add    $0x10,%esp
}
  801dde:	c9                   	leave  
  801ddf:	c3                   	ret    

00801de0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801de0:	55                   	push   %ebp
  801de1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801de3:	b8 00 00 00 00       	mov    $0x0,%eax
  801de8:	5d                   	pop    %ebp
  801de9:	c3                   	ret    

00801dea <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801dea:	55                   	push   %ebp
  801deb:	89 e5                	mov    %esp,%ebp
  801ded:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801df0:	68 d2 28 80 00       	push   $0x8028d2
  801df5:	ff 75 0c             	pushl  0xc(%ebp)
  801df8:	e8 b6 ea ff ff       	call   8008b3 <strcpy>
	return 0;
}
  801dfd:	b8 00 00 00 00       	mov    $0x0,%eax
  801e02:	c9                   	leave  
  801e03:	c3                   	ret    

00801e04 <devcons_write>:
{
  801e04:	55                   	push   %ebp
  801e05:	89 e5                	mov    %esp,%ebp
  801e07:	57                   	push   %edi
  801e08:	56                   	push   %esi
  801e09:	53                   	push   %ebx
  801e0a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801e10:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801e15:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801e1b:	eb 2f                	jmp    801e4c <devcons_write+0x48>
		m = n - tot;
  801e1d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e20:	29 f3                	sub    %esi,%ebx
  801e22:	83 fb 7f             	cmp    $0x7f,%ebx
  801e25:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801e2a:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801e2d:	83 ec 04             	sub    $0x4,%esp
  801e30:	53                   	push   %ebx
  801e31:	89 f0                	mov    %esi,%eax
  801e33:	03 45 0c             	add    0xc(%ebp),%eax
  801e36:	50                   	push   %eax
  801e37:	57                   	push   %edi
  801e38:	e8 04 ec ff ff       	call   800a41 <memmove>
		sys_cputs(buf, m);
  801e3d:	83 c4 08             	add    $0x8,%esp
  801e40:	53                   	push   %ebx
  801e41:	57                   	push   %edi
  801e42:	e8 a9 ed ff ff       	call   800bf0 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801e47:	01 de                	add    %ebx,%esi
  801e49:	83 c4 10             	add    $0x10,%esp
  801e4c:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e4f:	72 cc                	jb     801e1d <devcons_write+0x19>
}
  801e51:	89 f0                	mov    %esi,%eax
  801e53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e56:	5b                   	pop    %ebx
  801e57:	5e                   	pop    %esi
  801e58:	5f                   	pop    %edi
  801e59:	5d                   	pop    %ebp
  801e5a:	c3                   	ret    

00801e5b <devcons_read>:
{
  801e5b:	55                   	push   %ebp
  801e5c:	89 e5                	mov    %esp,%ebp
  801e5e:	83 ec 08             	sub    $0x8,%esp
  801e61:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801e66:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e6a:	75 07                	jne    801e73 <devcons_read+0x18>
}
  801e6c:	c9                   	leave  
  801e6d:	c3                   	ret    
		sys_yield();
  801e6e:	e8 1a ee ff ff       	call   800c8d <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801e73:	e8 96 ed ff ff       	call   800c0e <sys_cgetc>
  801e78:	85 c0                	test   %eax,%eax
  801e7a:	74 f2                	je     801e6e <devcons_read+0x13>
	if (c < 0)
  801e7c:	85 c0                	test   %eax,%eax
  801e7e:	78 ec                	js     801e6c <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  801e80:	83 f8 04             	cmp    $0x4,%eax
  801e83:	74 0c                	je     801e91 <devcons_read+0x36>
	*(char*)vbuf = c;
  801e85:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e88:	88 02                	mov    %al,(%edx)
	return 1;
  801e8a:	b8 01 00 00 00       	mov    $0x1,%eax
  801e8f:	eb db                	jmp    801e6c <devcons_read+0x11>
		return 0;
  801e91:	b8 00 00 00 00       	mov    $0x0,%eax
  801e96:	eb d4                	jmp    801e6c <devcons_read+0x11>

00801e98 <cputchar>:
{
  801e98:	55                   	push   %ebp
  801e99:	89 e5                	mov    %esp,%ebp
  801e9b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e9e:	8b 45 08             	mov    0x8(%ebp),%eax
  801ea1:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801ea4:	6a 01                	push   $0x1
  801ea6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ea9:	50                   	push   %eax
  801eaa:	e8 41 ed ff ff       	call   800bf0 <sys_cputs>
}
  801eaf:	83 c4 10             	add    $0x10,%esp
  801eb2:	c9                   	leave  
  801eb3:	c3                   	ret    

00801eb4 <getchar>:
{
  801eb4:	55                   	push   %ebp
  801eb5:	89 e5                	mov    %esp,%ebp
  801eb7:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801eba:	6a 01                	push   $0x1
  801ebc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ebf:	50                   	push   %eax
  801ec0:	6a 00                	push   $0x0
  801ec2:	e8 c2 f6 ff ff       	call   801589 <read>
	if (r < 0)
  801ec7:	83 c4 10             	add    $0x10,%esp
  801eca:	85 c0                	test   %eax,%eax
  801ecc:	78 08                	js     801ed6 <getchar+0x22>
	if (r < 1)
  801ece:	85 c0                	test   %eax,%eax
  801ed0:	7e 06                	jle    801ed8 <getchar+0x24>
	return c;
  801ed2:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801ed6:	c9                   	leave  
  801ed7:	c3                   	ret    
		return -E_EOF;
  801ed8:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801edd:	eb f7                	jmp    801ed6 <getchar+0x22>

00801edf <iscons>:
{
  801edf:	55                   	push   %ebp
  801ee0:	89 e5                	mov    %esp,%ebp
  801ee2:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ee5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ee8:	50                   	push   %eax
  801ee9:	ff 75 08             	pushl  0x8(%ebp)
  801eec:	e8 27 f4 ff ff       	call   801318 <fd_lookup>
  801ef1:	83 c4 10             	add    $0x10,%esp
  801ef4:	85 c0                	test   %eax,%eax
  801ef6:	78 11                	js     801f09 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801ef8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801efb:	8b 15 44 30 80 00    	mov    0x803044,%edx
  801f01:	39 10                	cmp    %edx,(%eax)
  801f03:	0f 94 c0             	sete   %al
  801f06:	0f b6 c0             	movzbl %al,%eax
}
  801f09:	c9                   	leave  
  801f0a:	c3                   	ret    

00801f0b <opencons>:
{
  801f0b:	55                   	push   %ebp
  801f0c:	89 e5                	mov    %esp,%ebp
  801f0e:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801f11:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f14:	50                   	push   %eax
  801f15:	e8 af f3 ff ff       	call   8012c9 <fd_alloc>
  801f1a:	83 c4 10             	add    $0x10,%esp
  801f1d:	85 c0                	test   %eax,%eax
  801f1f:	78 3a                	js     801f5b <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f21:	83 ec 04             	sub    $0x4,%esp
  801f24:	68 07 04 00 00       	push   $0x407
  801f29:	ff 75 f4             	pushl  -0xc(%ebp)
  801f2c:	6a 00                	push   $0x0
  801f2e:	e8 79 ed ff ff       	call   800cac <sys_page_alloc>
  801f33:	83 c4 10             	add    $0x10,%esp
  801f36:	85 c0                	test   %eax,%eax
  801f38:	78 21                	js     801f5b <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801f3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f3d:	8b 15 44 30 80 00    	mov    0x803044,%edx
  801f43:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f45:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f48:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f4f:	83 ec 0c             	sub    $0xc,%esp
  801f52:	50                   	push   %eax
  801f53:	e8 4a f3 ff ff       	call   8012a2 <fd2num>
  801f58:	83 c4 10             	add    $0x10,%esp
}
  801f5b:	c9                   	leave  
  801f5c:	c3                   	ret    

00801f5d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801f5d:	55                   	push   %ebp
  801f5e:	89 e5                	mov    %esp,%ebp
  801f60:	56                   	push   %esi
  801f61:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801f62:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801f65:	8b 35 08 30 80 00    	mov    0x803008,%esi
  801f6b:	e8 fe ec ff ff       	call   800c6e <sys_getenvid>
  801f70:	83 ec 0c             	sub    $0xc,%esp
  801f73:	ff 75 0c             	pushl  0xc(%ebp)
  801f76:	ff 75 08             	pushl  0x8(%ebp)
  801f79:	56                   	push   %esi
  801f7a:	50                   	push   %eax
  801f7b:	68 e0 28 80 00       	push   $0x8028e0
  801f80:	e8 0f e3 ff ff       	call   800294 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801f85:	83 c4 18             	add    $0x18,%esp
  801f88:	53                   	push   %ebx
  801f89:	ff 75 10             	pushl  0x10(%ebp)
  801f8c:	e8 b2 e2 ff ff       	call   800243 <vcprintf>
	cprintf("\n");
  801f91:	c7 04 24 9f 26 80 00 	movl   $0x80269f,(%esp)
  801f98:	e8 f7 e2 ff ff       	call   800294 <cprintf>
  801f9d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801fa0:	cc                   	int3   
  801fa1:	eb fd                	jmp    801fa0 <_panic+0x43>

00801fa3 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801fa3:	55                   	push   %ebp
  801fa4:	89 e5                	mov    %esp,%ebp
  801fa6:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801fa9:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801fb0:	74 0a                	je     801fbc <set_pgfault_handler+0x19>
			panic("set_pgfault_handler %e",r);
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
	}
       
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801fb2:	8b 45 08             	mov    0x8(%ebp),%eax
  801fb5:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801fba:	c9                   	leave  
  801fbb:	c3                   	ret    
		if((r=sys_page_alloc(thisenv->env_id,(void *)UXSTACKTOP-PGSIZE,PTE_P|PTE_W|PTE_U))<0)
  801fbc:	a1 04 40 80 00       	mov    0x804004,%eax
  801fc1:	8b 40 48             	mov    0x48(%eax),%eax
  801fc4:	83 ec 04             	sub    $0x4,%esp
  801fc7:	6a 07                	push   $0x7
  801fc9:	68 00 f0 bf ee       	push   $0xeebff000
  801fce:	50                   	push   %eax
  801fcf:	e8 d8 ec ff ff       	call   800cac <sys_page_alloc>
  801fd4:	83 c4 10             	add    $0x10,%esp
  801fd7:	85 c0                	test   %eax,%eax
  801fd9:	78 1b                	js     801ff6 <set_pgfault_handler+0x53>
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
  801fdb:	a1 04 40 80 00       	mov    0x804004,%eax
  801fe0:	8b 40 48             	mov    0x48(%eax),%eax
  801fe3:	83 ec 08             	sub    $0x8,%esp
  801fe6:	68 08 20 80 00       	push   $0x802008
  801feb:	50                   	push   %eax
  801fec:	e8 06 ee ff ff       	call   800df7 <sys_env_set_pgfault_upcall>
  801ff1:	83 c4 10             	add    $0x10,%esp
  801ff4:	eb bc                	jmp    801fb2 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler %e",r);
  801ff6:	50                   	push   %eax
  801ff7:	68 04 29 80 00       	push   $0x802904
  801ffc:	6a 22                	push   $0x22
  801ffe:	68 1b 29 80 00       	push   $0x80291b
  802003:	e8 55 ff ff ff       	call   801f5d <_panic>

00802008 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802008:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802009:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80200e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802010:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 48(%esp), %ebp
  802013:	8b 6c 24 30          	mov    0x30(%esp),%ebp
        subl $4, %ebp
  802017:	83 ed 04             	sub    $0x4,%ebp
        movl %ebp, 48(%esp)
  80201a:	89 6c 24 30          	mov    %ebp,0x30(%esp)
        movl 40(%esp), %eax
  80201e:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl %eax, (%ebp)
  802022:	89 45 00             	mov    %eax,0x0(%ebp)
	// Restore the trap-time registers.  After you do this, you
 	// can no longer modify any general-purpose registers.
 	// LAB 4: Your code here.
        addl $8, %esp
  802025:	83 c4 08             	add    $0x8,%esp
        popal
  802028:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $4, %esp
  802029:	83 c4 04             	add    $0x4,%esp
        popfl
  80202c:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  80202d:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  80202e:	c3                   	ret    

0080202f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80202f:	55                   	push   %ebp
  802030:	89 e5                	mov    %esp,%ebp
  802032:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802035:	89 d0                	mov    %edx,%eax
  802037:	c1 e8 16             	shr    $0x16,%eax
  80203a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802041:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  802046:	f6 c1 01             	test   $0x1,%cl
  802049:	74 1d                	je     802068 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  80204b:	c1 ea 0c             	shr    $0xc,%edx
  80204e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802055:	f6 c2 01             	test   $0x1,%dl
  802058:	74 0e                	je     802068 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80205a:	c1 ea 0c             	shr    $0xc,%edx
  80205d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802064:	ef 
  802065:	0f b7 c0             	movzwl %ax,%eax
}
  802068:	5d                   	pop    %ebp
  802069:	c3                   	ret    
  80206a:	66 90                	xchg   %ax,%ax
  80206c:	66 90                	xchg   %ax,%ax
  80206e:	66 90                	xchg   %ax,%ax

00802070 <__udivdi3>:
  802070:	55                   	push   %ebp
  802071:	57                   	push   %edi
  802072:	56                   	push   %esi
  802073:	53                   	push   %ebx
  802074:	83 ec 1c             	sub    $0x1c,%esp
  802077:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80207b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  80207f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802083:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  802087:	85 d2                	test   %edx,%edx
  802089:	75 35                	jne    8020c0 <__udivdi3+0x50>
  80208b:	39 f3                	cmp    %esi,%ebx
  80208d:	0f 87 bd 00 00 00    	ja     802150 <__udivdi3+0xe0>
  802093:	85 db                	test   %ebx,%ebx
  802095:	89 d9                	mov    %ebx,%ecx
  802097:	75 0b                	jne    8020a4 <__udivdi3+0x34>
  802099:	b8 01 00 00 00       	mov    $0x1,%eax
  80209e:	31 d2                	xor    %edx,%edx
  8020a0:	f7 f3                	div    %ebx
  8020a2:	89 c1                	mov    %eax,%ecx
  8020a4:	31 d2                	xor    %edx,%edx
  8020a6:	89 f0                	mov    %esi,%eax
  8020a8:	f7 f1                	div    %ecx
  8020aa:	89 c6                	mov    %eax,%esi
  8020ac:	89 e8                	mov    %ebp,%eax
  8020ae:	89 f7                	mov    %esi,%edi
  8020b0:	f7 f1                	div    %ecx
  8020b2:	89 fa                	mov    %edi,%edx
  8020b4:	83 c4 1c             	add    $0x1c,%esp
  8020b7:	5b                   	pop    %ebx
  8020b8:	5e                   	pop    %esi
  8020b9:	5f                   	pop    %edi
  8020ba:	5d                   	pop    %ebp
  8020bb:	c3                   	ret    
  8020bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020c0:	39 f2                	cmp    %esi,%edx
  8020c2:	77 7c                	ja     802140 <__udivdi3+0xd0>
  8020c4:	0f bd fa             	bsr    %edx,%edi
  8020c7:	83 f7 1f             	xor    $0x1f,%edi
  8020ca:	0f 84 98 00 00 00    	je     802168 <__udivdi3+0xf8>
  8020d0:	89 f9                	mov    %edi,%ecx
  8020d2:	b8 20 00 00 00       	mov    $0x20,%eax
  8020d7:	29 f8                	sub    %edi,%eax
  8020d9:	d3 e2                	shl    %cl,%edx
  8020db:	89 54 24 08          	mov    %edx,0x8(%esp)
  8020df:	89 c1                	mov    %eax,%ecx
  8020e1:	89 da                	mov    %ebx,%edx
  8020e3:	d3 ea                	shr    %cl,%edx
  8020e5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8020e9:	09 d1                	or     %edx,%ecx
  8020eb:	89 f2                	mov    %esi,%edx
  8020ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020f1:	89 f9                	mov    %edi,%ecx
  8020f3:	d3 e3                	shl    %cl,%ebx
  8020f5:	89 c1                	mov    %eax,%ecx
  8020f7:	d3 ea                	shr    %cl,%edx
  8020f9:	89 f9                	mov    %edi,%ecx
  8020fb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8020ff:	d3 e6                	shl    %cl,%esi
  802101:	89 eb                	mov    %ebp,%ebx
  802103:	89 c1                	mov    %eax,%ecx
  802105:	d3 eb                	shr    %cl,%ebx
  802107:	09 de                	or     %ebx,%esi
  802109:	89 f0                	mov    %esi,%eax
  80210b:	f7 74 24 08          	divl   0x8(%esp)
  80210f:	89 d6                	mov    %edx,%esi
  802111:	89 c3                	mov    %eax,%ebx
  802113:	f7 64 24 0c          	mull   0xc(%esp)
  802117:	39 d6                	cmp    %edx,%esi
  802119:	72 0c                	jb     802127 <__udivdi3+0xb7>
  80211b:	89 f9                	mov    %edi,%ecx
  80211d:	d3 e5                	shl    %cl,%ebp
  80211f:	39 c5                	cmp    %eax,%ebp
  802121:	73 5d                	jae    802180 <__udivdi3+0x110>
  802123:	39 d6                	cmp    %edx,%esi
  802125:	75 59                	jne    802180 <__udivdi3+0x110>
  802127:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80212a:	31 ff                	xor    %edi,%edi
  80212c:	89 fa                	mov    %edi,%edx
  80212e:	83 c4 1c             	add    $0x1c,%esp
  802131:	5b                   	pop    %ebx
  802132:	5e                   	pop    %esi
  802133:	5f                   	pop    %edi
  802134:	5d                   	pop    %ebp
  802135:	c3                   	ret    
  802136:	8d 76 00             	lea    0x0(%esi),%esi
  802139:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802140:	31 ff                	xor    %edi,%edi
  802142:	31 c0                	xor    %eax,%eax
  802144:	89 fa                	mov    %edi,%edx
  802146:	83 c4 1c             	add    $0x1c,%esp
  802149:	5b                   	pop    %ebx
  80214a:	5e                   	pop    %esi
  80214b:	5f                   	pop    %edi
  80214c:	5d                   	pop    %ebp
  80214d:	c3                   	ret    
  80214e:	66 90                	xchg   %ax,%ax
  802150:	31 ff                	xor    %edi,%edi
  802152:	89 e8                	mov    %ebp,%eax
  802154:	89 f2                	mov    %esi,%edx
  802156:	f7 f3                	div    %ebx
  802158:	89 fa                	mov    %edi,%edx
  80215a:	83 c4 1c             	add    $0x1c,%esp
  80215d:	5b                   	pop    %ebx
  80215e:	5e                   	pop    %esi
  80215f:	5f                   	pop    %edi
  802160:	5d                   	pop    %ebp
  802161:	c3                   	ret    
  802162:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802168:	39 f2                	cmp    %esi,%edx
  80216a:	72 06                	jb     802172 <__udivdi3+0x102>
  80216c:	31 c0                	xor    %eax,%eax
  80216e:	39 eb                	cmp    %ebp,%ebx
  802170:	77 d2                	ja     802144 <__udivdi3+0xd4>
  802172:	b8 01 00 00 00       	mov    $0x1,%eax
  802177:	eb cb                	jmp    802144 <__udivdi3+0xd4>
  802179:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802180:	89 d8                	mov    %ebx,%eax
  802182:	31 ff                	xor    %edi,%edi
  802184:	eb be                	jmp    802144 <__udivdi3+0xd4>
  802186:	66 90                	xchg   %ax,%ax
  802188:	66 90                	xchg   %ax,%ax
  80218a:	66 90                	xchg   %ax,%ax
  80218c:	66 90                	xchg   %ax,%ax
  80218e:	66 90                	xchg   %ax,%ax

00802190 <__umoddi3>:
  802190:	55                   	push   %ebp
  802191:	57                   	push   %edi
  802192:	56                   	push   %esi
  802193:	53                   	push   %ebx
  802194:	83 ec 1c             	sub    $0x1c,%esp
  802197:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80219b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80219f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8021a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021a7:	85 ed                	test   %ebp,%ebp
  8021a9:	89 f0                	mov    %esi,%eax
  8021ab:	89 da                	mov    %ebx,%edx
  8021ad:	75 19                	jne    8021c8 <__umoddi3+0x38>
  8021af:	39 df                	cmp    %ebx,%edi
  8021b1:	0f 86 b1 00 00 00    	jbe    802268 <__umoddi3+0xd8>
  8021b7:	f7 f7                	div    %edi
  8021b9:	89 d0                	mov    %edx,%eax
  8021bb:	31 d2                	xor    %edx,%edx
  8021bd:	83 c4 1c             	add    $0x1c,%esp
  8021c0:	5b                   	pop    %ebx
  8021c1:	5e                   	pop    %esi
  8021c2:	5f                   	pop    %edi
  8021c3:	5d                   	pop    %ebp
  8021c4:	c3                   	ret    
  8021c5:	8d 76 00             	lea    0x0(%esi),%esi
  8021c8:	39 dd                	cmp    %ebx,%ebp
  8021ca:	77 f1                	ja     8021bd <__umoddi3+0x2d>
  8021cc:	0f bd cd             	bsr    %ebp,%ecx
  8021cf:	83 f1 1f             	xor    $0x1f,%ecx
  8021d2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8021d6:	0f 84 b4 00 00 00    	je     802290 <__umoddi3+0x100>
  8021dc:	b8 20 00 00 00       	mov    $0x20,%eax
  8021e1:	89 c2                	mov    %eax,%edx
  8021e3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8021e7:	29 c2                	sub    %eax,%edx
  8021e9:	89 c1                	mov    %eax,%ecx
  8021eb:	89 f8                	mov    %edi,%eax
  8021ed:	d3 e5                	shl    %cl,%ebp
  8021ef:	89 d1                	mov    %edx,%ecx
  8021f1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8021f5:	d3 e8                	shr    %cl,%eax
  8021f7:	09 c5                	or     %eax,%ebp
  8021f9:	8b 44 24 04          	mov    0x4(%esp),%eax
  8021fd:	89 c1                	mov    %eax,%ecx
  8021ff:	d3 e7                	shl    %cl,%edi
  802201:	89 d1                	mov    %edx,%ecx
  802203:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802207:	89 df                	mov    %ebx,%edi
  802209:	d3 ef                	shr    %cl,%edi
  80220b:	89 c1                	mov    %eax,%ecx
  80220d:	89 f0                	mov    %esi,%eax
  80220f:	d3 e3                	shl    %cl,%ebx
  802211:	89 d1                	mov    %edx,%ecx
  802213:	89 fa                	mov    %edi,%edx
  802215:	d3 e8                	shr    %cl,%eax
  802217:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80221c:	09 d8                	or     %ebx,%eax
  80221e:	f7 f5                	div    %ebp
  802220:	d3 e6                	shl    %cl,%esi
  802222:	89 d1                	mov    %edx,%ecx
  802224:	f7 64 24 08          	mull   0x8(%esp)
  802228:	39 d1                	cmp    %edx,%ecx
  80222a:	89 c3                	mov    %eax,%ebx
  80222c:	89 d7                	mov    %edx,%edi
  80222e:	72 06                	jb     802236 <__umoddi3+0xa6>
  802230:	75 0e                	jne    802240 <__umoddi3+0xb0>
  802232:	39 c6                	cmp    %eax,%esi
  802234:	73 0a                	jae    802240 <__umoddi3+0xb0>
  802236:	2b 44 24 08          	sub    0x8(%esp),%eax
  80223a:	19 ea                	sbb    %ebp,%edx
  80223c:	89 d7                	mov    %edx,%edi
  80223e:	89 c3                	mov    %eax,%ebx
  802240:	89 ca                	mov    %ecx,%edx
  802242:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  802247:	29 de                	sub    %ebx,%esi
  802249:	19 fa                	sbb    %edi,%edx
  80224b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80224f:	89 d0                	mov    %edx,%eax
  802251:	d3 e0                	shl    %cl,%eax
  802253:	89 d9                	mov    %ebx,%ecx
  802255:	d3 ee                	shr    %cl,%esi
  802257:	d3 ea                	shr    %cl,%edx
  802259:	09 f0                	or     %esi,%eax
  80225b:	83 c4 1c             	add    $0x1c,%esp
  80225e:	5b                   	pop    %ebx
  80225f:	5e                   	pop    %esi
  802260:	5f                   	pop    %edi
  802261:	5d                   	pop    %ebp
  802262:	c3                   	ret    
  802263:	90                   	nop
  802264:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802268:	85 ff                	test   %edi,%edi
  80226a:	89 f9                	mov    %edi,%ecx
  80226c:	75 0b                	jne    802279 <__umoddi3+0xe9>
  80226e:	b8 01 00 00 00       	mov    $0x1,%eax
  802273:	31 d2                	xor    %edx,%edx
  802275:	f7 f7                	div    %edi
  802277:	89 c1                	mov    %eax,%ecx
  802279:	89 d8                	mov    %ebx,%eax
  80227b:	31 d2                	xor    %edx,%edx
  80227d:	f7 f1                	div    %ecx
  80227f:	89 f0                	mov    %esi,%eax
  802281:	f7 f1                	div    %ecx
  802283:	e9 31 ff ff ff       	jmp    8021b9 <__umoddi3+0x29>
  802288:	90                   	nop
  802289:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802290:	39 dd                	cmp    %ebx,%ebp
  802292:	72 08                	jb     80229c <__umoddi3+0x10c>
  802294:	39 f7                	cmp    %esi,%edi
  802296:	0f 87 21 ff ff ff    	ja     8021bd <__umoddi3+0x2d>
  80229c:	89 da                	mov    %ebx,%edx
  80229e:	89 f0                	mov    %esi,%eax
  8022a0:	29 f8                	sub    %edi,%eax
  8022a2:	19 ea                	sbb    %ebp,%edx
  8022a4:	e9 14 ff ff ff       	jmp    8021bd <__umoddi3+0x2d>
