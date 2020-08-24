
obj/user/sendpage:     file format elf32-i386


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
  800039:	e8 f2 0e 00 00       	call   800f30 <fork>
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
  800057:	e8 b0 10 00 00       	call   80110c <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  80005c:	83 c4 0c             	add    $0xc,%esp
  80005f:	68 00 00 b0 00       	push   $0xb00000
  800064:	ff 75 f4             	pushl  -0xc(%ebp)
  800067:	68 40 15 80 00       	push   $0x801540
  80006c:	e8 1b 02 00 00       	call   80028c <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800071:	83 c4 04             	add    $0x4,%esp
  800074:	ff 35 04 20 80 00    	pushl  0x802004
  80007a:	e8 f5 07 00 00       	call   800874 <strlen>
  80007f:	83 c4 0c             	add    $0xc,%esp
  800082:	50                   	push   %eax
  800083:	ff 35 04 20 80 00    	pushl  0x802004
  800089:	68 00 00 b0 00       	push   $0xb00000
  80008e:	e8 e4 08 00 00       	call   800977 <strncmp>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	74 3b                	je     8000d5 <umain+0xa2>
			cprintf("child received correct message\n");

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  80009a:	83 ec 0c             	sub    $0xc,%esp
  80009d:	ff 35 00 20 80 00    	pushl  0x802000
  8000a3:	e8 cc 07 00 00       	call   800874 <strlen>
  8000a8:	83 c4 0c             	add    $0xc,%esp
  8000ab:	83 c0 01             	add    $0x1,%eax
  8000ae:	50                   	push   %eax
  8000af:	ff 35 00 20 80 00    	pushl  0x802000
  8000b5:	68 00 00 b0 00       	push   $0xb00000
  8000ba:	e8 e2 09 00 00       	call   800aa1 <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000bf:	6a 07                	push   $0x7
  8000c1:	68 00 00 b0 00       	push   $0xb00000
  8000c6:	6a 00                	push   $0x0
  8000c8:	ff 75 f4             	pushl  -0xc(%ebp)
  8000cb:	e8 b1 10 00 00       	call   801181 <ipc_send>
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
  8000d8:	68 54 15 80 00       	push   $0x801554
  8000dd:	e8 aa 01 00 00       	call   80028c <cprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
  8000e5:	eb b3                	jmp    80009a <umain+0x67>
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  8000e7:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8000ec:	8b 40 48             	mov    0x48(%eax),%eax
  8000ef:	83 ec 04             	sub    $0x4,%esp
  8000f2:	6a 07                	push   $0x7
  8000f4:	68 00 00 a0 00       	push   $0xa00000
  8000f9:	50                   	push   %eax
  8000fa:	e8 a5 0b 00 00       	call   800ca4 <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  8000ff:	83 c4 04             	add    $0x4,%esp
  800102:	ff 35 04 20 80 00    	pushl  0x802004
  800108:	e8 67 07 00 00       	call   800874 <strlen>
  80010d:	83 c4 0c             	add    $0xc,%esp
  800110:	83 c0 01             	add    $0x1,%eax
  800113:	50                   	push   %eax
  800114:	ff 35 04 20 80 00    	pushl  0x802004
  80011a:	68 00 00 a0 00       	push   $0xa00000
  80011f:	e8 7d 09 00 00       	call   800aa1 <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800124:	6a 07                	push   $0x7
  800126:	68 00 00 a0 00       	push   $0xa00000
  80012b:	6a 00                	push   $0x0
  80012d:	ff 75 f4             	pushl  -0xc(%ebp)
  800130:	e8 4c 10 00 00       	call   801181 <ipc_send>
	ipc_recv(&who, TEMP_ADDR, 0);
  800135:	83 c4 1c             	add    $0x1c,%esp
  800138:	6a 00                	push   $0x0
  80013a:	68 00 00 a0 00       	push   $0xa00000
  80013f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800142:	50                   	push   %eax
  800143:	e8 c4 0f 00 00       	call   80110c <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  800148:	83 c4 0c             	add    $0xc,%esp
  80014b:	68 00 00 a0 00       	push   $0xa00000
  800150:	ff 75 f4             	pushl  -0xc(%ebp)
  800153:	68 40 15 80 00       	push   $0x801540
  800158:	e8 2f 01 00 00       	call   80028c <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  80015d:	83 c4 04             	add    $0x4,%esp
  800160:	ff 35 00 20 80 00    	pushl  0x802000
  800166:	e8 09 07 00 00       	call   800874 <strlen>
  80016b:	83 c4 0c             	add    $0xc,%esp
  80016e:	50                   	push   %eax
  80016f:	ff 35 00 20 80 00    	pushl  0x802000
  800175:	68 00 00 a0 00       	push   $0xa00000
  80017a:	e8 f8 07 00 00       	call   800977 <strncmp>
  80017f:	83 c4 10             	add    $0x10,%esp
  800182:	85 c0                	test   %eax,%eax
  800184:	0f 85 49 ff ff ff    	jne    8000d3 <umain+0xa0>
		cprintf("parent received correct message\n");
  80018a:	83 ec 0c             	sub    $0xc,%esp
  80018d:	68 74 15 80 00       	push   $0x801574
  800192:	e8 f5 00 00 00       	call   80028c <cprintf>
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
  8001aa:	e8 b7 0a 00 00       	call   800c66 <sys_getenvid>
  8001af:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001b4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001b7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001bc:	a3 0c 20 80 00       	mov    %eax,0x80200c
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001c1:	85 db                	test   %ebx,%ebx
  8001c3:	7e 07                	jle    8001cc <libmain+0x2d>
		binaryname = argv[0];
  8001c5:	8b 06                	mov    (%esi),%eax
  8001c7:	a3 08 20 80 00       	mov    %eax,0x802008

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
  8001e8:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8001eb:	6a 00                	push   $0x0
  8001ed:	e8 33 0a 00 00       	call   800c25 <sys_env_destroy>
}
  8001f2:	83 c4 10             	add    $0x10,%esp
  8001f5:	c9                   	leave  
  8001f6:	c3                   	ret    

008001f7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001f7:	55                   	push   %ebp
  8001f8:	89 e5                	mov    %esp,%ebp
  8001fa:	53                   	push   %ebx
  8001fb:	83 ec 04             	sub    $0x4,%esp
  8001fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800201:	8b 13                	mov    (%ebx),%edx
  800203:	8d 42 01             	lea    0x1(%edx),%eax
  800206:	89 03                	mov    %eax,(%ebx)
  800208:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80020b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80020f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800214:	74 09                	je     80021f <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800216:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80021a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80021d:	c9                   	leave  
  80021e:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80021f:	83 ec 08             	sub    $0x8,%esp
  800222:	68 ff 00 00 00       	push   $0xff
  800227:	8d 43 08             	lea    0x8(%ebx),%eax
  80022a:	50                   	push   %eax
  80022b:	e8 b8 09 00 00       	call   800be8 <sys_cputs>
		b->idx = 0;
  800230:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800236:	83 c4 10             	add    $0x10,%esp
  800239:	eb db                	jmp    800216 <putch+0x1f>

0080023b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
  80023e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800244:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80024b:	00 00 00 
	b.cnt = 0;
  80024e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800255:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800258:	ff 75 0c             	pushl  0xc(%ebp)
  80025b:	ff 75 08             	pushl  0x8(%ebp)
  80025e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800264:	50                   	push   %eax
  800265:	68 f7 01 80 00       	push   $0x8001f7
  80026a:	e8 1a 01 00 00       	call   800389 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80026f:	83 c4 08             	add    $0x8,%esp
  800272:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800278:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80027e:	50                   	push   %eax
  80027f:	e8 64 09 00 00       	call   800be8 <sys_cputs>

	return b.cnt;
}
  800284:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80028a:	c9                   	leave  
  80028b:	c3                   	ret    

0080028c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800292:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800295:	50                   	push   %eax
  800296:	ff 75 08             	pushl  0x8(%ebp)
  800299:	e8 9d ff ff ff       	call   80023b <vcprintf>
	va_end(ap);

	return cnt;
}
  80029e:	c9                   	leave  
  80029f:	c3                   	ret    

008002a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	57                   	push   %edi
  8002a4:	56                   	push   %esi
  8002a5:	53                   	push   %ebx
  8002a6:	83 ec 1c             	sub    $0x1c,%esp
  8002a9:	89 c7                	mov    %eax,%edi
  8002ab:	89 d6                	mov    %edx,%esi
  8002ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002b6:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002b9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002bc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002c4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002c7:	39 d3                	cmp    %edx,%ebx
  8002c9:	72 05                	jb     8002d0 <printnum+0x30>
  8002cb:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002ce:	77 7a                	ja     80034a <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d0:	83 ec 0c             	sub    $0xc,%esp
  8002d3:	ff 75 18             	pushl  0x18(%ebp)
  8002d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8002d9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002dc:	53                   	push   %ebx
  8002dd:	ff 75 10             	pushl  0x10(%ebp)
  8002e0:	83 ec 08             	sub    $0x8,%esp
  8002e3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8002e9:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ec:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ef:	e8 fc 0f 00 00       	call   8012f0 <__udivdi3>
  8002f4:	83 c4 18             	add    $0x18,%esp
  8002f7:	52                   	push   %edx
  8002f8:	50                   	push   %eax
  8002f9:	89 f2                	mov    %esi,%edx
  8002fb:	89 f8                	mov    %edi,%eax
  8002fd:	e8 9e ff ff ff       	call   8002a0 <printnum>
  800302:	83 c4 20             	add    $0x20,%esp
  800305:	eb 13                	jmp    80031a <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800307:	83 ec 08             	sub    $0x8,%esp
  80030a:	56                   	push   %esi
  80030b:	ff 75 18             	pushl  0x18(%ebp)
  80030e:	ff d7                	call   *%edi
  800310:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800313:	83 eb 01             	sub    $0x1,%ebx
  800316:	85 db                	test   %ebx,%ebx
  800318:	7f ed                	jg     800307 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80031a:	83 ec 08             	sub    $0x8,%esp
  80031d:	56                   	push   %esi
  80031e:	83 ec 04             	sub    $0x4,%esp
  800321:	ff 75 e4             	pushl  -0x1c(%ebp)
  800324:	ff 75 e0             	pushl  -0x20(%ebp)
  800327:	ff 75 dc             	pushl  -0x24(%ebp)
  80032a:	ff 75 d8             	pushl  -0x28(%ebp)
  80032d:	e8 de 10 00 00       	call   801410 <__umoddi3>
  800332:	83 c4 14             	add    $0x14,%esp
  800335:	0f be 80 ec 15 80 00 	movsbl 0x8015ec(%eax),%eax
  80033c:	50                   	push   %eax
  80033d:	ff d7                	call   *%edi
}
  80033f:	83 c4 10             	add    $0x10,%esp
  800342:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800345:	5b                   	pop    %ebx
  800346:	5e                   	pop    %esi
  800347:	5f                   	pop    %edi
  800348:	5d                   	pop    %ebp
  800349:	c3                   	ret    
  80034a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80034d:	eb c4                	jmp    800313 <printnum+0x73>

0080034f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
  800352:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800355:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800359:	8b 10                	mov    (%eax),%edx
  80035b:	3b 50 04             	cmp    0x4(%eax),%edx
  80035e:	73 0a                	jae    80036a <sprintputch+0x1b>
		*b->buf++ = ch;
  800360:	8d 4a 01             	lea    0x1(%edx),%ecx
  800363:	89 08                	mov    %ecx,(%eax)
  800365:	8b 45 08             	mov    0x8(%ebp),%eax
  800368:	88 02                	mov    %al,(%edx)
}
  80036a:	5d                   	pop    %ebp
  80036b:	c3                   	ret    

0080036c <printfmt>:
{
  80036c:	55                   	push   %ebp
  80036d:	89 e5                	mov    %esp,%ebp
  80036f:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800372:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800375:	50                   	push   %eax
  800376:	ff 75 10             	pushl  0x10(%ebp)
  800379:	ff 75 0c             	pushl  0xc(%ebp)
  80037c:	ff 75 08             	pushl  0x8(%ebp)
  80037f:	e8 05 00 00 00       	call   800389 <vprintfmt>
}
  800384:	83 c4 10             	add    $0x10,%esp
  800387:	c9                   	leave  
  800388:	c3                   	ret    

00800389 <vprintfmt>:
{
  800389:	55                   	push   %ebp
  80038a:	89 e5                	mov    %esp,%ebp
  80038c:	57                   	push   %edi
  80038d:	56                   	push   %esi
  80038e:	53                   	push   %ebx
  80038f:	83 ec 2c             	sub    $0x2c,%esp
  800392:	8b 75 08             	mov    0x8(%ebp),%esi
  800395:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800398:	8b 7d 10             	mov    0x10(%ebp),%edi
  80039b:	e9 c1 03 00 00       	jmp    800761 <vprintfmt+0x3d8>
		padc = ' ';
  8003a0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8003a4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8003ab:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8003b2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003b9:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003be:	8d 47 01             	lea    0x1(%edi),%eax
  8003c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003c4:	0f b6 17             	movzbl (%edi),%edx
  8003c7:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003ca:	3c 55                	cmp    $0x55,%al
  8003cc:	0f 87 12 04 00 00    	ja     8007e4 <vprintfmt+0x45b>
  8003d2:	0f b6 c0             	movzbl %al,%eax
  8003d5:	ff 24 85 c0 16 80 00 	jmp    *0x8016c0(,%eax,4)
  8003dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8003df:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8003e3:	eb d9                	jmp    8003be <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8003e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  8003e8:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003ec:	eb d0                	jmp    8003be <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8003ee:	0f b6 d2             	movzbl %dl,%edx
  8003f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8003f9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003fc:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003ff:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800403:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800406:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800409:	83 f9 09             	cmp    $0x9,%ecx
  80040c:	77 55                	ja     800463 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  80040e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800411:	eb e9                	jmp    8003fc <vprintfmt+0x73>
			precision = va_arg(ap, int);
  800413:	8b 45 14             	mov    0x14(%ebp),%eax
  800416:	8b 00                	mov    (%eax),%eax
  800418:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80041b:	8b 45 14             	mov    0x14(%ebp),%eax
  80041e:	8d 40 04             	lea    0x4(%eax),%eax
  800421:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800424:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800427:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80042b:	79 91                	jns    8003be <vprintfmt+0x35>
				width = precision, precision = -1;
  80042d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800430:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800433:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80043a:	eb 82                	jmp    8003be <vprintfmt+0x35>
  80043c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80043f:	85 c0                	test   %eax,%eax
  800441:	ba 00 00 00 00       	mov    $0x0,%edx
  800446:	0f 49 d0             	cmovns %eax,%edx
  800449:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80044c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80044f:	e9 6a ff ff ff       	jmp    8003be <vprintfmt+0x35>
  800454:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800457:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80045e:	e9 5b ff ff ff       	jmp    8003be <vprintfmt+0x35>
  800463:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800466:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800469:	eb bc                	jmp    800427 <vprintfmt+0x9e>
			lflag++;
  80046b:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80046e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800471:	e9 48 ff ff ff       	jmp    8003be <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  800476:	8b 45 14             	mov    0x14(%ebp),%eax
  800479:	8d 78 04             	lea    0x4(%eax),%edi
  80047c:	83 ec 08             	sub    $0x8,%esp
  80047f:	53                   	push   %ebx
  800480:	ff 30                	pushl  (%eax)
  800482:	ff d6                	call   *%esi
			break;
  800484:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800487:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80048a:	e9 cf 02 00 00       	jmp    80075e <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  80048f:	8b 45 14             	mov    0x14(%ebp),%eax
  800492:	8d 78 04             	lea    0x4(%eax),%edi
  800495:	8b 00                	mov    (%eax),%eax
  800497:	99                   	cltd   
  800498:	31 d0                	xor    %edx,%eax
  80049a:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80049c:	83 f8 08             	cmp    $0x8,%eax
  80049f:	7f 23                	jg     8004c4 <vprintfmt+0x13b>
  8004a1:	8b 14 85 20 18 80 00 	mov    0x801820(,%eax,4),%edx
  8004a8:	85 d2                	test   %edx,%edx
  8004aa:	74 18                	je     8004c4 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8004ac:	52                   	push   %edx
  8004ad:	68 0d 16 80 00       	push   $0x80160d
  8004b2:	53                   	push   %ebx
  8004b3:	56                   	push   %esi
  8004b4:	e8 b3 fe ff ff       	call   80036c <printfmt>
  8004b9:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004bc:	89 7d 14             	mov    %edi,0x14(%ebp)
  8004bf:	e9 9a 02 00 00       	jmp    80075e <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  8004c4:	50                   	push   %eax
  8004c5:	68 04 16 80 00       	push   $0x801604
  8004ca:	53                   	push   %ebx
  8004cb:	56                   	push   %esi
  8004cc:	e8 9b fe ff ff       	call   80036c <printfmt>
  8004d1:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004d4:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8004d7:	e9 82 02 00 00       	jmp    80075e <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  8004dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004df:	83 c0 04             	add    $0x4,%eax
  8004e2:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8004e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e8:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004ea:	85 ff                	test   %edi,%edi
  8004ec:	b8 fd 15 80 00       	mov    $0x8015fd,%eax
  8004f1:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004f4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004f8:	0f 8e bd 00 00 00    	jle    8005bb <vprintfmt+0x232>
  8004fe:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800502:	75 0e                	jne    800512 <vprintfmt+0x189>
  800504:	89 75 08             	mov    %esi,0x8(%ebp)
  800507:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80050a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80050d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800510:	eb 6d                	jmp    80057f <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  800512:	83 ec 08             	sub    $0x8,%esp
  800515:	ff 75 d0             	pushl  -0x30(%ebp)
  800518:	57                   	push   %edi
  800519:	e8 6e 03 00 00       	call   80088c <strnlen>
  80051e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800521:	29 c1                	sub    %eax,%ecx
  800523:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800526:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800529:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80052d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800530:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800533:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800535:	eb 0f                	jmp    800546 <vprintfmt+0x1bd>
					putch(padc, putdat);
  800537:	83 ec 08             	sub    $0x8,%esp
  80053a:	53                   	push   %ebx
  80053b:	ff 75 e0             	pushl  -0x20(%ebp)
  80053e:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800540:	83 ef 01             	sub    $0x1,%edi
  800543:	83 c4 10             	add    $0x10,%esp
  800546:	85 ff                	test   %edi,%edi
  800548:	7f ed                	jg     800537 <vprintfmt+0x1ae>
  80054a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80054d:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800550:	85 c9                	test   %ecx,%ecx
  800552:	b8 00 00 00 00       	mov    $0x0,%eax
  800557:	0f 49 c1             	cmovns %ecx,%eax
  80055a:	29 c1                	sub    %eax,%ecx
  80055c:	89 75 08             	mov    %esi,0x8(%ebp)
  80055f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800562:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800565:	89 cb                	mov    %ecx,%ebx
  800567:	eb 16                	jmp    80057f <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  800569:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80056d:	75 31                	jne    8005a0 <vprintfmt+0x217>
					putch(ch, putdat);
  80056f:	83 ec 08             	sub    $0x8,%esp
  800572:	ff 75 0c             	pushl  0xc(%ebp)
  800575:	50                   	push   %eax
  800576:	ff 55 08             	call   *0x8(%ebp)
  800579:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80057c:	83 eb 01             	sub    $0x1,%ebx
  80057f:	83 c7 01             	add    $0x1,%edi
  800582:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800586:	0f be c2             	movsbl %dl,%eax
  800589:	85 c0                	test   %eax,%eax
  80058b:	74 59                	je     8005e6 <vprintfmt+0x25d>
  80058d:	85 f6                	test   %esi,%esi
  80058f:	78 d8                	js     800569 <vprintfmt+0x1e0>
  800591:	83 ee 01             	sub    $0x1,%esi
  800594:	79 d3                	jns    800569 <vprintfmt+0x1e0>
  800596:	89 df                	mov    %ebx,%edi
  800598:	8b 75 08             	mov    0x8(%ebp),%esi
  80059b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80059e:	eb 37                	jmp    8005d7 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8005a0:	0f be d2             	movsbl %dl,%edx
  8005a3:	83 ea 20             	sub    $0x20,%edx
  8005a6:	83 fa 5e             	cmp    $0x5e,%edx
  8005a9:	76 c4                	jbe    80056f <vprintfmt+0x1e6>
					putch('?', putdat);
  8005ab:	83 ec 08             	sub    $0x8,%esp
  8005ae:	ff 75 0c             	pushl  0xc(%ebp)
  8005b1:	6a 3f                	push   $0x3f
  8005b3:	ff 55 08             	call   *0x8(%ebp)
  8005b6:	83 c4 10             	add    $0x10,%esp
  8005b9:	eb c1                	jmp    80057c <vprintfmt+0x1f3>
  8005bb:	89 75 08             	mov    %esi,0x8(%ebp)
  8005be:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005c1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005c4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005c7:	eb b6                	jmp    80057f <vprintfmt+0x1f6>
				putch(' ', putdat);
  8005c9:	83 ec 08             	sub    $0x8,%esp
  8005cc:	53                   	push   %ebx
  8005cd:	6a 20                	push   $0x20
  8005cf:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8005d1:	83 ef 01             	sub    $0x1,%edi
  8005d4:	83 c4 10             	add    $0x10,%esp
  8005d7:	85 ff                	test   %edi,%edi
  8005d9:	7f ee                	jg     8005c9 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  8005db:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005de:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e1:	e9 78 01 00 00       	jmp    80075e <vprintfmt+0x3d5>
  8005e6:	89 df                	mov    %ebx,%edi
  8005e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8005eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005ee:	eb e7                	jmp    8005d7 <vprintfmt+0x24e>
	if (lflag >= 2)
  8005f0:	83 f9 01             	cmp    $0x1,%ecx
  8005f3:	7e 3f                	jle    800634 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  8005f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f8:	8b 50 04             	mov    0x4(%eax),%edx
  8005fb:	8b 00                	mov    (%eax),%eax
  8005fd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800600:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800603:	8b 45 14             	mov    0x14(%ebp),%eax
  800606:	8d 40 08             	lea    0x8(%eax),%eax
  800609:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80060c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800610:	79 5c                	jns    80066e <vprintfmt+0x2e5>
				putch('-', putdat);
  800612:	83 ec 08             	sub    $0x8,%esp
  800615:	53                   	push   %ebx
  800616:	6a 2d                	push   $0x2d
  800618:	ff d6                	call   *%esi
				num = -(long long) num;
  80061a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80061d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800620:	f7 da                	neg    %edx
  800622:	83 d1 00             	adc    $0x0,%ecx
  800625:	f7 d9                	neg    %ecx
  800627:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80062a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80062f:	e9 10 01 00 00       	jmp    800744 <vprintfmt+0x3bb>
	else if (lflag)
  800634:	85 c9                	test   %ecx,%ecx
  800636:	75 1b                	jne    800653 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800638:	8b 45 14             	mov    0x14(%ebp),%eax
  80063b:	8b 00                	mov    (%eax),%eax
  80063d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800640:	89 c1                	mov    %eax,%ecx
  800642:	c1 f9 1f             	sar    $0x1f,%ecx
  800645:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800648:	8b 45 14             	mov    0x14(%ebp),%eax
  80064b:	8d 40 04             	lea    0x4(%eax),%eax
  80064e:	89 45 14             	mov    %eax,0x14(%ebp)
  800651:	eb b9                	jmp    80060c <vprintfmt+0x283>
		return va_arg(*ap, long);
  800653:	8b 45 14             	mov    0x14(%ebp),%eax
  800656:	8b 00                	mov    (%eax),%eax
  800658:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80065b:	89 c1                	mov    %eax,%ecx
  80065d:	c1 f9 1f             	sar    $0x1f,%ecx
  800660:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800663:	8b 45 14             	mov    0x14(%ebp),%eax
  800666:	8d 40 04             	lea    0x4(%eax),%eax
  800669:	89 45 14             	mov    %eax,0x14(%ebp)
  80066c:	eb 9e                	jmp    80060c <vprintfmt+0x283>
			num = getint(&ap, lflag);
  80066e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800671:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800674:	b8 0a 00 00 00       	mov    $0xa,%eax
  800679:	e9 c6 00 00 00       	jmp    800744 <vprintfmt+0x3bb>
	if (lflag >= 2)
  80067e:	83 f9 01             	cmp    $0x1,%ecx
  800681:	7e 18                	jle    80069b <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  800683:	8b 45 14             	mov    0x14(%ebp),%eax
  800686:	8b 10                	mov    (%eax),%edx
  800688:	8b 48 04             	mov    0x4(%eax),%ecx
  80068b:	8d 40 08             	lea    0x8(%eax),%eax
  80068e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800691:	b8 0a 00 00 00       	mov    $0xa,%eax
  800696:	e9 a9 00 00 00       	jmp    800744 <vprintfmt+0x3bb>
	else if (lflag)
  80069b:	85 c9                	test   %ecx,%ecx
  80069d:	75 1a                	jne    8006b9 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  80069f:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a2:	8b 10                	mov    (%eax),%edx
  8006a4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006a9:	8d 40 04             	lea    0x4(%eax),%eax
  8006ac:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006af:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006b4:	e9 8b 00 00 00       	jmp    800744 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8006b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bc:	8b 10                	mov    (%eax),%edx
  8006be:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006c3:	8d 40 04             	lea    0x4(%eax),%eax
  8006c6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006c9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ce:	eb 74                	jmp    800744 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8006d0:	83 f9 01             	cmp    $0x1,%ecx
  8006d3:	7e 15                	jle    8006ea <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  8006d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d8:	8b 10                	mov    (%eax),%edx
  8006da:	8b 48 04             	mov    0x4(%eax),%ecx
  8006dd:	8d 40 08             	lea    0x8(%eax),%eax
  8006e0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006e3:	b8 08 00 00 00       	mov    $0x8,%eax
  8006e8:	eb 5a                	jmp    800744 <vprintfmt+0x3bb>
	else if (lflag)
  8006ea:	85 c9                	test   %ecx,%ecx
  8006ec:	75 17                	jne    800705 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  8006ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f1:	8b 10                	mov    (%eax),%edx
  8006f3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f8:	8d 40 04             	lea    0x4(%eax),%eax
  8006fb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006fe:	b8 08 00 00 00       	mov    $0x8,%eax
  800703:	eb 3f                	jmp    800744 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800705:	8b 45 14             	mov    0x14(%ebp),%eax
  800708:	8b 10                	mov    (%eax),%edx
  80070a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80070f:	8d 40 04             	lea    0x4(%eax),%eax
  800712:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800715:	b8 08 00 00 00       	mov    $0x8,%eax
  80071a:	eb 28                	jmp    800744 <vprintfmt+0x3bb>
			putch('0', putdat);
  80071c:	83 ec 08             	sub    $0x8,%esp
  80071f:	53                   	push   %ebx
  800720:	6a 30                	push   $0x30
  800722:	ff d6                	call   *%esi
			putch('x', putdat);
  800724:	83 c4 08             	add    $0x8,%esp
  800727:	53                   	push   %ebx
  800728:	6a 78                	push   $0x78
  80072a:	ff d6                	call   *%esi
			num = (unsigned long long)
  80072c:	8b 45 14             	mov    0x14(%ebp),%eax
  80072f:	8b 10                	mov    (%eax),%edx
  800731:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800736:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800739:	8d 40 04             	lea    0x4(%eax),%eax
  80073c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80073f:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800744:	83 ec 0c             	sub    $0xc,%esp
  800747:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80074b:	57                   	push   %edi
  80074c:	ff 75 e0             	pushl  -0x20(%ebp)
  80074f:	50                   	push   %eax
  800750:	51                   	push   %ecx
  800751:	52                   	push   %edx
  800752:	89 da                	mov    %ebx,%edx
  800754:	89 f0                	mov    %esi,%eax
  800756:	e8 45 fb ff ff       	call   8002a0 <printnum>
			break;
  80075b:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80075e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800761:	83 c7 01             	add    $0x1,%edi
  800764:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800768:	83 f8 25             	cmp    $0x25,%eax
  80076b:	0f 84 2f fc ff ff    	je     8003a0 <vprintfmt+0x17>
			if (ch == '\0')
  800771:	85 c0                	test   %eax,%eax
  800773:	0f 84 8b 00 00 00    	je     800804 <vprintfmt+0x47b>
			putch(ch, putdat);
  800779:	83 ec 08             	sub    $0x8,%esp
  80077c:	53                   	push   %ebx
  80077d:	50                   	push   %eax
  80077e:	ff d6                	call   *%esi
  800780:	83 c4 10             	add    $0x10,%esp
  800783:	eb dc                	jmp    800761 <vprintfmt+0x3d8>
	if (lflag >= 2)
  800785:	83 f9 01             	cmp    $0x1,%ecx
  800788:	7e 15                	jle    80079f <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  80078a:	8b 45 14             	mov    0x14(%ebp),%eax
  80078d:	8b 10                	mov    (%eax),%edx
  80078f:	8b 48 04             	mov    0x4(%eax),%ecx
  800792:	8d 40 08             	lea    0x8(%eax),%eax
  800795:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800798:	b8 10 00 00 00       	mov    $0x10,%eax
  80079d:	eb a5                	jmp    800744 <vprintfmt+0x3bb>
	else if (lflag)
  80079f:	85 c9                	test   %ecx,%ecx
  8007a1:	75 17                	jne    8007ba <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  8007a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a6:	8b 10                	mov    (%eax),%edx
  8007a8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007ad:	8d 40 04             	lea    0x4(%eax),%eax
  8007b0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007b3:	b8 10 00 00 00       	mov    $0x10,%eax
  8007b8:	eb 8a                	jmp    800744 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8007ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bd:	8b 10                	mov    (%eax),%edx
  8007bf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007c4:	8d 40 04             	lea    0x4(%eax),%eax
  8007c7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007ca:	b8 10 00 00 00       	mov    $0x10,%eax
  8007cf:	e9 70 ff ff ff       	jmp    800744 <vprintfmt+0x3bb>
			putch(ch, putdat);
  8007d4:	83 ec 08             	sub    $0x8,%esp
  8007d7:	53                   	push   %ebx
  8007d8:	6a 25                	push   $0x25
  8007da:	ff d6                	call   *%esi
			break;
  8007dc:	83 c4 10             	add    $0x10,%esp
  8007df:	e9 7a ff ff ff       	jmp    80075e <vprintfmt+0x3d5>
			putch('%', putdat);
  8007e4:	83 ec 08             	sub    $0x8,%esp
  8007e7:	53                   	push   %ebx
  8007e8:	6a 25                	push   $0x25
  8007ea:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007ec:	83 c4 10             	add    $0x10,%esp
  8007ef:	89 f8                	mov    %edi,%eax
  8007f1:	eb 03                	jmp    8007f6 <vprintfmt+0x46d>
  8007f3:	83 e8 01             	sub    $0x1,%eax
  8007f6:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007fa:	75 f7                	jne    8007f3 <vprintfmt+0x46a>
  8007fc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007ff:	e9 5a ff ff ff       	jmp    80075e <vprintfmt+0x3d5>
}
  800804:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800807:	5b                   	pop    %ebx
  800808:	5e                   	pop    %esi
  800809:	5f                   	pop    %edi
  80080a:	5d                   	pop    %ebp
  80080b:	c3                   	ret    

0080080c <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80080c:	55                   	push   %ebp
  80080d:	89 e5                	mov    %esp,%ebp
  80080f:	83 ec 18             	sub    $0x18,%esp
  800812:	8b 45 08             	mov    0x8(%ebp),%eax
  800815:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800818:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80081b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80081f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800822:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800829:	85 c0                	test   %eax,%eax
  80082b:	74 26                	je     800853 <vsnprintf+0x47>
  80082d:	85 d2                	test   %edx,%edx
  80082f:	7e 22                	jle    800853 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800831:	ff 75 14             	pushl  0x14(%ebp)
  800834:	ff 75 10             	pushl  0x10(%ebp)
  800837:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80083a:	50                   	push   %eax
  80083b:	68 4f 03 80 00       	push   $0x80034f
  800840:	e8 44 fb ff ff       	call   800389 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800845:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800848:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80084b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80084e:	83 c4 10             	add    $0x10,%esp
}
  800851:	c9                   	leave  
  800852:	c3                   	ret    
		return -E_INVAL;
  800853:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800858:	eb f7                	jmp    800851 <vsnprintf+0x45>

0080085a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800860:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800863:	50                   	push   %eax
  800864:	ff 75 10             	pushl  0x10(%ebp)
  800867:	ff 75 0c             	pushl  0xc(%ebp)
  80086a:	ff 75 08             	pushl  0x8(%ebp)
  80086d:	e8 9a ff ff ff       	call   80080c <vsnprintf>
	va_end(ap);

	return rc;
}
  800872:	c9                   	leave  
  800873:	c3                   	ret    

00800874 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800874:	55                   	push   %ebp
  800875:	89 e5                	mov    %esp,%ebp
  800877:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80087a:	b8 00 00 00 00       	mov    $0x0,%eax
  80087f:	eb 03                	jmp    800884 <strlen+0x10>
		n++;
  800881:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800884:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800888:	75 f7                	jne    800881 <strlen+0xd>
	return n;
}
  80088a:	5d                   	pop    %ebp
  80088b:	c3                   	ret    

0080088c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80088c:	55                   	push   %ebp
  80088d:	89 e5                	mov    %esp,%ebp
  80088f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800892:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800895:	b8 00 00 00 00       	mov    $0x0,%eax
  80089a:	eb 03                	jmp    80089f <strnlen+0x13>
		n++;
  80089c:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80089f:	39 d0                	cmp    %edx,%eax
  8008a1:	74 06                	je     8008a9 <strnlen+0x1d>
  8008a3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008a7:	75 f3                	jne    80089c <strnlen+0x10>
	return n;
}
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	53                   	push   %ebx
  8008af:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008b5:	89 c2                	mov    %eax,%edx
  8008b7:	83 c1 01             	add    $0x1,%ecx
  8008ba:	83 c2 01             	add    $0x1,%edx
  8008bd:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008c1:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008c4:	84 db                	test   %bl,%bl
  8008c6:	75 ef                	jne    8008b7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008c8:	5b                   	pop    %ebx
  8008c9:	5d                   	pop    %ebp
  8008ca:	c3                   	ret    

008008cb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008cb:	55                   	push   %ebp
  8008cc:	89 e5                	mov    %esp,%ebp
  8008ce:	53                   	push   %ebx
  8008cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008d2:	53                   	push   %ebx
  8008d3:	e8 9c ff ff ff       	call   800874 <strlen>
  8008d8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008db:	ff 75 0c             	pushl  0xc(%ebp)
  8008de:	01 d8                	add    %ebx,%eax
  8008e0:	50                   	push   %eax
  8008e1:	e8 c5 ff ff ff       	call   8008ab <strcpy>
	return dst;
}
  8008e6:	89 d8                	mov    %ebx,%eax
  8008e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008eb:	c9                   	leave  
  8008ec:	c3                   	ret    

008008ed <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008ed:	55                   	push   %ebp
  8008ee:	89 e5                	mov    %esp,%ebp
  8008f0:	56                   	push   %esi
  8008f1:	53                   	push   %ebx
  8008f2:	8b 75 08             	mov    0x8(%ebp),%esi
  8008f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008f8:	89 f3                	mov    %esi,%ebx
  8008fa:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008fd:	89 f2                	mov    %esi,%edx
  8008ff:	eb 0f                	jmp    800910 <strncpy+0x23>
		*dst++ = *src;
  800901:	83 c2 01             	add    $0x1,%edx
  800904:	0f b6 01             	movzbl (%ecx),%eax
  800907:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80090a:	80 39 01             	cmpb   $0x1,(%ecx)
  80090d:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800910:	39 da                	cmp    %ebx,%edx
  800912:	75 ed                	jne    800901 <strncpy+0x14>
	}
	return ret;
}
  800914:	89 f0                	mov    %esi,%eax
  800916:	5b                   	pop    %ebx
  800917:	5e                   	pop    %esi
  800918:	5d                   	pop    %ebp
  800919:	c3                   	ret    

0080091a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	56                   	push   %esi
  80091e:	53                   	push   %ebx
  80091f:	8b 75 08             	mov    0x8(%ebp),%esi
  800922:	8b 55 0c             	mov    0xc(%ebp),%edx
  800925:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800928:	89 f0                	mov    %esi,%eax
  80092a:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80092e:	85 c9                	test   %ecx,%ecx
  800930:	75 0b                	jne    80093d <strlcpy+0x23>
  800932:	eb 17                	jmp    80094b <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800934:	83 c2 01             	add    $0x1,%edx
  800937:	83 c0 01             	add    $0x1,%eax
  80093a:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  80093d:	39 d8                	cmp    %ebx,%eax
  80093f:	74 07                	je     800948 <strlcpy+0x2e>
  800941:	0f b6 0a             	movzbl (%edx),%ecx
  800944:	84 c9                	test   %cl,%cl
  800946:	75 ec                	jne    800934 <strlcpy+0x1a>
		*dst = '\0';
  800948:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80094b:	29 f0                	sub    %esi,%eax
}
  80094d:	5b                   	pop    %ebx
  80094e:	5e                   	pop    %esi
  80094f:	5d                   	pop    %ebp
  800950:	c3                   	ret    

00800951 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
  800954:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800957:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80095a:	eb 06                	jmp    800962 <strcmp+0x11>
		p++, q++;
  80095c:	83 c1 01             	add    $0x1,%ecx
  80095f:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800962:	0f b6 01             	movzbl (%ecx),%eax
  800965:	84 c0                	test   %al,%al
  800967:	74 04                	je     80096d <strcmp+0x1c>
  800969:	3a 02                	cmp    (%edx),%al
  80096b:	74 ef                	je     80095c <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80096d:	0f b6 c0             	movzbl %al,%eax
  800970:	0f b6 12             	movzbl (%edx),%edx
  800973:	29 d0                	sub    %edx,%eax
}
  800975:	5d                   	pop    %ebp
  800976:	c3                   	ret    

00800977 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
  80097a:	53                   	push   %ebx
  80097b:	8b 45 08             	mov    0x8(%ebp),%eax
  80097e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800981:	89 c3                	mov    %eax,%ebx
  800983:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800986:	eb 06                	jmp    80098e <strncmp+0x17>
		n--, p++, q++;
  800988:	83 c0 01             	add    $0x1,%eax
  80098b:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80098e:	39 d8                	cmp    %ebx,%eax
  800990:	74 16                	je     8009a8 <strncmp+0x31>
  800992:	0f b6 08             	movzbl (%eax),%ecx
  800995:	84 c9                	test   %cl,%cl
  800997:	74 04                	je     80099d <strncmp+0x26>
  800999:	3a 0a                	cmp    (%edx),%cl
  80099b:	74 eb                	je     800988 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80099d:	0f b6 00             	movzbl (%eax),%eax
  8009a0:	0f b6 12             	movzbl (%edx),%edx
  8009a3:	29 d0                	sub    %edx,%eax
}
  8009a5:	5b                   	pop    %ebx
  8009a6:	5d                   	pop    %ebp
  8009a7:	c3                   	ret    
		return 0;
  8009a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ad:	eb f6                	jmp    8009a5 <strncmp+0x2e>

008009af <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009af:	55                   	push   %ebp
  8009b0:	89 e5                	mov    %esp,%ebp
  8009b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b9:	0f b6 10             	movzbl (%eax),%edx
  8009bc:	84 d2                	test   %dl,%dl
  8009be:	74 09                	je     8009c9 <strchr+0x1a>
		if (*s == c)
  8009c0:	38 ca                	cmp    %cl,%dl
  8009c2:	74 0a                	je     8009ce <strchr+0x1f>
	for (; *s; s++)
  8009c4:	83 c0 01             	add    $0x1,%eax
  8009c7:	eb f0                	jmp    8009b9 <strchr+0xa>
			return (char *) s;
	return 0;
  8009c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ce:	5d                   	pop    %ebp
  8009cf:	c3                   	ret    

008009d0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
  8009d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009da:	eb 03                	jmp    8009df <strfind+0xf>
  8009dc:	83 c0 01             	add    $0x1,%eax
  8009df:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009e2:	38 ca                	cmp    %cl,%dl
  8009e4:	74 04                	je     8009ea <strfind+0x1a>
  8009e6:	84 d2                	test   %dl,%dl
  8009e8:	75 f2                	jne    8009dc <strfind+0xc>
			break;
	return (char *) s;
}
  8009ea:	5d                   	pop    %ebp
  8009eb:	c3                   	ret    

008009ec <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009ec:	55                   	push   %ebp
  8009ed:	89 e5                	mov    %esp,%ebp
  8009ef:	57                   	push   %edi
  8009f0:	56                   	push   %esi
  8009f1:	53                   	push   %ebx
  8009f2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009f5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009f8:	85 c9                	test   %ecx,%ecx
  8009fa:	74 13                	je     800a0f <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009fc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a02:	75 05                	jne    800a09 <memset+0x1d>
  800a04:	f6 c1 03             	test   $0x3,%cl
  800a07:	74 0d                	je     800a16 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a09:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0c:	fc                   	cld    
  800a0d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a0f:	89 f8                	mov    %edi,%eax
  800a11:	5b                   	pop    %ebx
  800a12:	5e                   	pop    %esi
  800a13:	5f                   	pop    %edi
  800a14:	5d                   	pop    %ebp
  800a15:	c3                   	ret    
		c &= 0xFF;
  800a16:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a1a:	89 d3                	mov    %edx,%ebx
  800a1c:	c1 e3 08             	shl    $0x8,%ebx
  800a1f:	89 d0                	mov    %edx,%eax
  800a21:	c1 e0 18             	shl    $0x18,%eax
  800a24:	89 d6                	mov    %edx,%esi
  800a26:	c1 e6 10             	shl    $0x10,%esi
  800a29:	09 f0                	or     %esi,%eax
  800a2b:	09 c2                	or     %eax,%edx
  800a2d:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800a2f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a32:	89 d0                	mov    %edx,%eax
  800a34:	fc                   	cld    
  800a35:	f3 ab                	rep stos %eax,%es:(%edi)
  800a37:	eb d6                	jmp    800a0f <memset+0x23>

00800a39 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a39:	55                   	push   %ebp
  800a3a:	89 e5                	mov    %esp,%ebp
  800a3c:	57                   	push   %edi
  800a3d:	56                   	push   %esi
  800a3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a41:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a44:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a47:	39 c6                	cmp    %eax,%esi
  800a49:	73 35                	jae    800a80 <memmove+0x47>
  800a4b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a4e:	39 c2                	cmp    %eax,%edx
  800a50:	76 2e                	jbe    800a80 <memmove+0x47>
		s += n;
		d += n;
  800a52:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a55:	89 d6                	mov    %edx,%esi
  800a57:	09 fe                	or     %edi,%esi
  800a59:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a5f:	74 0c                	je     800a6d <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a61:	83 ef 01             	sub    $0x1,%edi
  800a64:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a67:	fd                   	std    
  800a68:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a6a:	fc                   	cld    
  800a6b:	eb 21                	jmp    800a8e <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a6d:	f6 c1 03             	test   $0x3,%cl
  800a70:	75 ef                	jne    800a61 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a72:	83 ef 04             	sub    $0x4,%edi
  800a75:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a78:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a7b:	fd                   	std    
  800a7c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a7e:	eb ea                	jmp    800a6a <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a80:	89 f2                	mov    %esi,%edx
  800a82:	09 c2                	or     %eax,%edx
  800a84:	f6 c2 03             	test   $0x3,%dl
  800a87:	74 09                	je     800a92 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a89:	89 c7                	mov    %eax,%edi
  800a8b:	fc                   	cld    
  800a8c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a8e:	5e                   	pop    %esi
  800a8f:	5f                   	pop    %edi
  800a90:	5d                   	pop    %ebp
  800a91:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a92:	f6 c1 03             	test   $0x3,%cl
  800a95:	75 f2                	jne    800a89 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a97:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a9a:	89 c7                	mov    %eax,%edi
  800a9c:	fc                   	cld    
  800a9d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a9f:	eb ed                	jmp    800a8e <memmove+0x55>

00800aa1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800aa4:	ff 75 10             	pushl  0x10(%ebp)
  800aa7:	ff 75 0c             	pushl  0xc(%ebp)
  800aaa:	ff 75 08             	pushl  0x8(%ebp)
  800aad:	e8 87 ff ff ff       	call   800a39 <memmove>
}
  800ab2:	c9                   	leave  
  800ab3:	c3                   	ret    

00800ab4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ab4:	55                   	push   %ebp
  800ab5:	89 e5                	mov    %esp,%ebp
  800ab7:	56                   	push   %esi
  800ab8:	53                   	push   %ebx
  800ab9:	8b 45 08             	mov    0x8(%ebp),%eax
  800abc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800abf:	89 c6                	mov    %eax,%esi
  800ac1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ac4:	39 f0                	cmp    %esi,%eax
  800ac6:	74 1c                	je     800ae4 <memcmp+0x30>
		if (*s1 != *s2)
  800ac8:	0f b6 08             	movzbl (%eax),%ecx
  800acb:	0f b6 1a             	movzbl (%edx),%ebx
  800ace:	38 d9                	cmp    %bl,%cl
  800ad0:	75 08                	jne    800ada <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ad2:	83 c0 01             	add    $0x1,%eax
  800ad5:	83 c2 01             	add    $0x1,%edx
  800ad8:	eb ea                	jmp    800ac4 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800ada:	0f b6 c1             	movzbl %cl,%eax
  800add:	0f b6 db             	movzbl %bl,%ebx
  800ae0:	29 d8                	sub    %ebx,%eax
  800ae2:	eb 05                	jmp    800ae9 <memcmp+0x35>
	}

	return 0;
  800ae4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ae9:	5b                   	pop    %ebx
  800aea:	5e                   	pop    %esi
  800aeb:	5d                   	pop    %ebp
  800aec:	c3                   	ret    

00800aed <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800aed:	55                   	push   %ebp
  800aee:	89 e5                	mov    %esp,%ebp
  800af0:	8b 45 08             	mov    0x8(%ebp),%eax
  800af3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800af6:	89 c2                	mov    %eax,%edx
  800af8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800afb:	39 d0                	cmp    %edx,%eax
  800afd:	73 09                	jae    800b08 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aff:	38 08                	cmp    %cl,(%eax)
  800b01:	74 05                	je     800b08 <memfind+0x1b>
	for (; s < ends; s++)
  800b03:	83 c0 01             	add    $0x1,%eax
  800b06:	eb f3                	jmp    800afb <memfind+0xe>
			break;
	return (void *) s;
}
  800b08:	5d                   	pop    %ebp
  800b09:	c3                   	ret    

00800b0a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	57                   	push   %edi
  800b0e:	56                   	push   %esi
  800b0f:	53                   	push   %ebx
  800b10:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b13:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b16:	eb 03                	jmp    800b1b <strtol+0x11>
		s++;
  800b18:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b1b:	0f b6 01             	movzbl (%ecx),%eax
  800b1e:	3c 20                	cmp    $0x20,%al
  800b20:	74 f6                	je     800b18 <strtol+0xe>
  800b22:	3c 09                	cmp    $0x9,%al
  800b24:	74 f2                	je     800b18 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b26:	3c 2b                	cmp    $0x2b,%al
  800b28:	74 2e                	je     800b58 <strtol+0x4e>
	int neg = 0;
  800b2a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b2f:	3c 2d                	cmp    $0x2d,%al
  800b31:	74 2f                	je     800b62 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b33:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b39:	75 05                	jne    800b40 <strtol+0x36>
  800b3b:	80 39 30             	cmpb   $0x30,(%ecx)
  800b3e:	74 2c                	je     800b6c <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b40:	85 db                	test   %ebx,%ebx
  800b42:	75 0a                	jne    800b4e <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b44:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800b49:	80 39 30             	cmpb   $0x30,(%ecx)
  800b4c:	74 28                	je     800b76 <strtol+0x6c>
		base = 10;
  800b4e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b53:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b56:	eb 50                	jmp    800ba8 <strtol+0x9e>
		s++;
  800b58:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b5b:	bf 00 00 00 00       	mov    $0x0,%edi
  800b60:	eb d1                	jmp    800b33 <strtol+0x29>
		s++, neg = 1;
  800b62:	83 c1 01             	add    $0x1,%ecx
  800b65:	bf 01 00 00 00       	mov    $0x1,%edi
  800b6a:	eb c7                	jmp    800b33 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b6c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b70:	74 0e                	je     800b80 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b72:	85 db                	test   %ebx,%ebx
  800b74:	75 d8                	jne    800b4e <strtol+0x44>
		s++, base = 8;
  800b76:	83 c1 01             	add    $0x1,%ecx
  800b79:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b7e:	eb ce                	jmp    800b4e <strtol+0x44>
		s += 2, base = 16;
  800b80:	83 c1 02             	add    $0x2,%ecx
  800b83:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b88:	eb c4                	jmp    800b4e <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800b8a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b8d:	89 f3                	mov    %esi,%ebx
  800b8f:	80 fb 19             	cmp    $0x19,%bl
  800b92:	77 29                	ja     800bbd <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b94:	0f be d2             	movsbl %dl,%edx
  800b97:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b9a:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b9d:	7d 30                	jge    800bcf <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b9f:	83 c1 01             	add    $0x1,%ecx
  800ba2:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ba6:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ba8:	0f b6 11             	movzbl (%ecx),%edx
  800bab:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bae:	89 f3                	mov    %esi,%ebx
  800bb0:	80 fb 09             	cmp    $0x9,%bl
  800bb3:	77 d5                	ja     800b8a <strtol+0x80>
			dig = *s - '0';
  800bb5:	0f be d2             	movsbl %dl,%edx
  800bb8:	83 ea 30             	sub    $0x30,%edx
  800bbb:	eb dd                	jmp    800b9a <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800bbd:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bc0:	89 f3                	mov    %esi,%ebx
  800bc2:	80 fb 19             	cmp    $0x19,%bl
  800bc5:	77 08                	ja     800bcf <strtol+0xc5>
			dig = *s - 'A' + 10;
  800bc7:	0f be d2             	movsbl %dl,%edx
  800bca:	83 ea 37             	sub    $0x37,%edx
  800bcd:	eb cb                	jmp    800b9a <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bcf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bd3:	74 05                	je     800bda <strtol+0xd0>
		*endptr = (char *) s;
  800bd5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bd8:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800bda:	89 c2                	mov    %eax,%edx
  800bdc:	f7 da                	neg    %edx
  800bde:	85 ff                	test   %edi,%edi
  800be0:	0f 45 c2             	cmovne %edx,%eax
}
  800be3:	5b                   	pop    %ebx
  800be4:	5e                   	pop    %esi
  800be5:	5f                   	pop    %edi
  800be6:	5d                   	pop    %ebp
  800be7:	c3                   	ret    

00800be8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800be8:	55                   	push   %ebp
  800be9:	89 e5                	mov    %esp,%ebp
  800beb:	57                   	push   %edi
  800bec:	56                   	push   %esi
  800bed:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bee:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf3:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf9:	89 c3                	mov    %eax,%ebx
  800bfb:	89 c7                	mov    %eax,%edi
  800bfd:	89 c6                	mov    %eax,%esi
  800bff:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c01:	5b                   	pop    %ebx
  800c02:	5e                   	pop    %esi
  800c03:	5f                   	pop    %edi
  800c04:	5d                   	pop    %ebp
  800c05:	c3                   	ret    

00800c06 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	57                   	push   %edi
  800c0a:	56                   	push   %esi
  800c0b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c0c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c11:	b8 01 00 00 00       	mov    $0x1,%eax
  800c16:	89 d1                	mov    %edx,%ecx
  800c18:	89 d3                	mov    %edx,%ebx
  800c1a:	89 d7                	mov    %edx,%edi
  800c1c:	89 d6                	mov    %edx,%esi
  800c1e:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c20:	5b                   	pop    %ebx
  800c21:	5e                   	pop    %esi
  800c22:	5f                   	pop    %edi
  800c23:	5d                   	pop    %ebp
  800c24:	c3                   	ret    

00800c25 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	57                   	push   %edi
  800c29:	56                   	push   %esi
  800c2a:	53                   	push   %ebx
  800c2b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c2e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c33:	8b 55 08             	mov    0x8(%ebp),%edx
  800c36:	b8 03 00 00 00       	mov    $0x3,%eax
  800c3b:	89 cb                	mov    %ecx,%ebx
  800c3d:	89 cf                	mov    %ecx,%edi
  800c3f:	89 ce                	mov    %ecx,%esi
  800c41:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c43:	85 c0                	test   %eax,%eax
  800c45:	7f 08                	jg     800c4f <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4a:	5b                   	pop    %ebx
  800c4b:	5e                   	pop    %esi
  800c4c:	5f                   	pop    %edi
  800c4d:	5d                   	pop    %ebp
  800c4e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4f:	83 ec 0c             	sub    $0xc,%esp
  800c52:	50                   	push   %eax
  800c53:	6a 03                	push   $0x3
  800c55:	68 44 18 80 00       	push   $0x801844
  800c5a:	6a 23                	push   $0x23
  800c5c:	68 61 18 80 00       	push   $0x801861
  800c61:	e8 aa 05 00 00       	call   801210 <_panic>

00800c66 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c66:	55                   	push   %ebp
  800c67:	89 e5                	mov    %esp,%ebp
  800c69:	57                   	push   %edi
  800c6a:	56                   	push   %esi
  800c6b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c6c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c71:	b8 02 00 00 00       	mov    $0x2,%eax
  800c76:	89 d1                	mov    %edx,%ecx
  800c78:	89 d3                	mov    %edx,%ebx
  800c7a:	89 d7                	mov    %edx,%edi
  800c7c:	89 d6                	mov    %edx,%esi
  800c7e:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c80:	5b                   	pop    %ebx
  800c81:	5e                   	pop    %esi
  800c82:	5f                   	pop    %edi
  800c83:	5d                   	pop    %ebp
  800c84:	c3                   	ret    

00800c85 <sys_yield>:

void
sys_yield(void)
{
  800c85:	55                   	push   %ebp
  800c86:	89 e5                	mov    %esp,%ebp
  800c88:	57                   	push   %edi
  800c89:	56                   	push   %esi
  800c8a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c90:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c95:	89 d1                	mov    %edx,%ecx
  800c97:	89 d3                	mov    %edx,%ebx
  800c99:	89 d7                	mov    %edx,%edi
  800c9b:	89 d6                	mov    %edx,%esi
  800c9d:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c9f:	5b                   	pop    %ebx
  800ca0:	5e                   	pop    %esi
  800ca1:	5f                   	pop    %edi
  800ca2:	5d                   	pop    %ebp
  800ca3:	c3                   	ret    

00800ca4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	57                   	push   %edi
  800ca8:	56                   	push   %esi
  800ca9:	53                   	push   %ebx
  800caa:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cad:	be 00 00 00 00       	mov    $0x0,%esi
  800cb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb8:	b8 04 00 00 00       	mov    $0x4,%eax
  800cbd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc0:	89 f7                	mov    %esi,%edi
  800cc2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cc4:	85 c0                	test   %eax,%eax
  800cc6:	7f 08                	jg     800cd0 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cc8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ccb:	5b                   	pop    %ebx
  800ccc:	5e                   	pop    %esi
  800ccd:	5f                   	pop    %edi
  800cce:	5d                   	pop    %ebp
  800ccf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd0:	83 ec 0c             	sub    $0xc,%esp
  800cd3:	50                   	push   %eax
  800cd4:	6a 04                	push   $0x4
  800cd6:	68 44 18 80 00       	push   $0x801844
  800cdb:	6a 23                	push   $0x23
  800cdd:	68 61 18 80 00       	push   $0x801861
  800ce2:	e8 29 05 00 00       	call   801210 <_panic>

00800ce7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	57                   	push   %edi
  800ceb:	56                   	push   %esi
  800cec:	53                   	push   %ebx
  800ced:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf6:	b8 05 00 00 00       	mov    $0x5,%eax
  800cfb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cfe:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d01:	8b 75 18             	mov    0x18(%ebp),%esi
  800d04:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d06:	85 c0                	test   %eax,%eax
  800d08:	7f 08                	jg     800d12 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0d:	5b                   	pop    %ebx
  800d0e:	5e                   	pop    %esi
  800d0f:	5f                   	pop    %edi
  800d10:	5d                   	pop    %ebp
  800d11:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d12:	83 ec 0c             	sub    $0xc,%esp
  800d15:	50                   	push   %eax
  800d16:	6a 05                	push   $0x5
  800d18:	68 44 18 80 00       	push   $0x801844
  800d1d:	6a 23                	push   $0x23
  800d1f:	68 61 18 80 00       	push   $0x801861
  800d24:	e8 e7 04 00 00       	call   801210 <_panic>

00800d29 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d29:	55                   	push   %ebp
  800d2a:	89 e5                	mov    %esp,%ebp
  800d2c:	57                   	push   %edi
  800d2d:	56                   	push   %esi
  800d2e:	53                   	push   %ebx
  800d2f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d32:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d37:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3d:	b8 06 00 00 00       	mov    $0x6,%eax
  800d42:	89 df                	mov    %ebx,%edi
  800d44:	89 de                	mov    %ebx,%esi
  800d46:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d48:	85 c0                	test   %eax,%eax
  800d4a:	7f 08                	jg     800d54 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4f:	5b                   	pop    %ebx
  800d50:	5e                   	pop    %esi
  800d51:	5f                   	pop    %edi
  800d52:	5d                   	pop    %ebp
  800d53:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d54:	83 ec 0c             	sub    $0xc,%esp
  800d57:	50                   	push   %eax
  800d58:	6a 06                	push   $0x6
  800d5a:	68 44 18 80 00       	push   $0x801844
  800d5f:	6a 23                	push   $0x23
  800d61:	68 61 18 80 00       	push   $0x801861
  800d66:	e8 a5 04 00 00       	call   801210 <_panic>

00800d6b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	57                   	push   %edi
  800d6f:	56                   	push   %esi
  800d70:	53                   	push   %ebx
  800d71:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d74:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d79:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7f:	b8 08 00 00 00       	mov    $0x8,%eax
  800d84:	89 df                	mov    %ebx,%edi
  800d86:	89 de                	mov    %ebx,%esi
  800d88:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d8a:	85 c0                	test   %eax,%eax
  800d8c:	7f 08                	jg     800d96 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d91:	5b                   	pop    %ebx
  800d92:	5e                   	pop    %esi
  800d93:	5f                   	pop    %edi
  800d94:	5d                   	pop    %ebp
  800d95:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d96:	83 ec 0c             	sub    $0xc,%esp
  800d99:	50                   	push   %eax
  800d9a:	6a 08                	push   $0x8
  800d9c:	68 44 18 80 00       	push   $0x801844
  800da1:	6a 23                	push   $0x23
  800da3:	68 61 18 80 00       	push   $0x801861
  800da8:	e8 63 04 00 00       	call   801210 <_panic>

00800dad <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dad:	55                   	push   %ebp
  800dae:	89 e5                	mov    %esp,%ebp
  800db0:	57                   	push   %edi
  800db1:	56                   	push   %esi
  800db2:	53                   	push   %ebx
  800db3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800db6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc1:	b8 09 00 00 00       	mov    $0x9,%eax
  800dc6:	89 df                	mov    %ebx,%edi
  800dc8:	89 de                	mov    %ebx,%esi
  800dca:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dcc:	85 c0                	test   %eax,%eax
  800dce:	7f 08                	jg     800dd8 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd3:	5b                   	pop    %ebx
  800dd4:	5e                   	pop    %esi
  800dd5:	5f                   	pop    %edi
  800dd6:	5d                   	pop    %ebp
  800dd7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd8:	83 ec 0c             	sub    $0xc,%esp
  800ddb:	50                   	push   %eax
  800ddc:	6a 09                	push   $0x9
  800dde:	68 44 18 80 00       	push   $0x801844
  800de3:	6a 23                	push   $0x23
  800de5:	68 61 18 80 00       	push   $0x801861
  800dea:	e8 21 04 00 00       	call   801210 <_panic>

00800def <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800def:	55                   	push   %ebp
  800df0:	89 e5                	mov    %esp,%ebp
  800df2:	57                   	push   %edi
  800df3:	56                   	push   %esi
  800df4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800df5:	8b 55 08             	mov    0x8(%ebp),%edx
  800df8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfb:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e00:	be 00 00 00 00       	mov    $0x0,%esi
  800e05:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e08:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e0b:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e0d:	5b                   	pop    %ebx
  800e0e:	5e                   	pop    %esi
  800e0f:	5f                   	pop    %edi
  800e10:	5d                   	pop    %ebp
  800e11:	c3                   	ret    

00800e12 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e12:	55                   	push   %ebp
  800e13:	89 e5                	mov    %esp,%ebp
  800e15:	57                   	push   %edi
  800e16:	56                   	push   %esi
  800e17:	53                   	push   %ebx
  800e18:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e1b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e20:	8b 55 08             	mov    0x8(%ebp),%edx
  800e23:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e28:	89 cb                	mov    %ecx,%ebx
  800e2a:	89 cf                	mov    %ecx,%edi
  800e2c:	89 ce                	mov    %ecx,%esi
  800e2e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e30:	85 c0                	test   %eax,%eax
  800e32:	7f 08                	jg     800e3c <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e37:	5b                   	pop    %ebx
  800e38:	5e                   	pop    %esi
  800e39:	5f                   	pop    %edi
  800e3a:	5d                   	pop    %ebp
  800e3b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e3c:	83 ec 0c             	sub    $0xc,%esp
  800e3f:	50                   	push   %eax
  800e40:	6a 0c                	push   $0xc
  800e42:	68 44 18 80 00       	push   $0x801844
  800e47:	6a 23                	push   $0x23
  800e49:	68 61 18 80 00       	push   $0x801861
  800e4e:	e8 bd 03 00 00       	call   801210 <_panic>

00800e53 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e53:	55                   	push   %ebp
  800e54:	89 e5                	mov    %esp,%ebp
  800e56:	56                   	push   %esi
  800e57:	53                   	push   %ebx
  800e58:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e5b:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if((err&FEC_WR)==0 || (uvpt[PGNUM(addr)]&PTE_COW)==0){
  800e5d:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e61:	74 7f                	je     800ee2 <pgfault+0x8f>
  800e63:	89 d8                	mov    %ebx,%eax
  800e65:	c1 e8 0c             	shr    $0xc,%eax
  800e68:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e6f:	f6 c4 08             	test   $0x8,%ah
  800e72:	74 6e                	je     800ee2 <pgfault+0x8f>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        envid_t envid = sys_getenvid();
  800e74:	e8 ed fd ff ff       	call   800c66 <sys_getenvid>
  800e79:	89 c6                	mov    %eax,%esi
	r = sys_page_alloc(envid,(void *)PFTEMP,PTE_P|PTE_W|PTE_U);
  800e7b:	83 ec 04             	sub    $0x4,%esp
  800e7e:	6a 07                	push   $0x7
  800e80:	68 00 f0 7f 00       	push   $0x7ff000
  800e85:	50                   	push   %eax
  800e86:	e8 19 fe ff ff       	call   800ca4 <sys_page_alloc>
	if(r<0) panic("pgfault:page allocation failed %e",r);
  800e8b:	83 c4 10             	add    $0x10,%esp
  800e8e:	85 c0                	test   %eax,%eax
  800e90:	78 64                	js     800ef6 <pgfault+0xa3>
	addr = ROUNDDOWN(addr,PGSIZE);
  800e92:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy((void *)PFTEMP,(const void *)addr,PGSIZE);
  800e98:	83 ec 04             	sub    $0x4,%esp
  800e9b:	68 00 10 00 00       	push   $0x1000
  800ea0:	53                   	push   %ebx
  800ea1:	68 00 f0 7f 00       	push   $0x7ff000
  800ea6:	e8 f6 fb ff ff       	call   800aa1 <memcpy>
	if(sys_page_map(envid,(void *)PFTEMP, envid,addr,PTE_P|PTE_W|PTE_U)<0)
  800eab:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800eb2:	53                   	push   %ebx
  800eb3:	56                   	push   %esi
  800eb4:	68 00 f0 7f 00       	push   $0x7ff000
  800eb9:	56                   	push   %esi
  800eba:	e8 28 fe ff ff       	call   800ce7 <sys_page_map>
  800ebf:	83 c4 20             	add    $0x20,%esp
  800ec2:	85 c0                	test   %eax,%eax
  800ec4:	78 42                	js     800f08 <pgfault+0xb5>
		panic("pgfault:page map failed\n");
	if(sys_page_unmap(envid,(void *)PFTEMP)<0)
  800ec6:	83 ec 08             	sub    $0x8,%esp
  800ec9:	68 00 f0 7f 00       	push   $0x7ff000
  800ece:	56                   	push   %esi
  800ecf:	e8 55 fe ff ff       	call   800d29 <sys_page_unmap>
  800ed4:	83 c4 10             	add    $0x10,%esp
  800ed7:	85 c0                	test   %eax,%eax
  800ed9:	78 41                	js     800f1c <pgfault+0xc9>
		panic("pgfault: page upmap failed\n");
       //	panic("pgfault not implemented");
}
  800edb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ede:	5b                   	pop    %ebx
  800edf:	5e                   	pop    %esi
  800ee0:	5d                   	pop    %ebp
  800ee1:	c3                   	ret    
		panic("pgfault:invalid user trap");
  800ee2:	83 ec 04             	sub    $0x4,%esp
  800ee5:	68 6f 18 80 00       	push   $0x80186f
  800eea:	6a 1e                	push   $0x1e
  800eec:	68 89 18 80 00       	push   $0x801889
  800ef1:	e8 1a 03 00 00       	call   801210 <_panic>
	if(r<0) panic("pgfault:page allocation failed %e",r);
  800ef6:	50                   	push   %eax
  800ef7:	68 74 19 80 00       	push   $0x801974
  800efc:	6a 29                	push   $0x29
  800efe:	68 89 18 80 00       	push   $0x801889
  800f03:	e8 08 03 00 00       	call   801210 <_panic>
		panic("pgfault:page map failed\n");
  800f08:	83 ec 04             	sub    $0x4,%esp
  800f0b:	68 94 18 80 00       	push   $0x801894
  800f10:	6a 2d                	push   $0x2d
  800f12:	68 89 18 80 00       	push   $0x801889
  800f17:	e8 f4 02 00 00       	call   801210 <_panic>
		panic("pgfault: page upmap failed\n");
  800f1c:	83 ec 04             	sub    $0x4,%esp
  800f1f:	68 ad 18 80 00       	push   $0x8018ad
  800f24:	6a 2f                	push   $0x2f
  800f26:	68 89 18 80 00       	push   $0x801889
  800f2b:	e8 e0 02 00 00       	call   801210 <_panic>

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
  800f39:	68 53 0e 80 00       	push   $0x800e53
  800f3e:	e8 13 03 00 00       	call   801256 <set_pgfault_handler>
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
  800f55:	78 28                	js     800f7f <fork+0x4f>
	if(envid==0){
	  thisenv = &envs[ENVX(sys_getenvid())];
	  return 0;
	}

	for(addr=(uintptr_t)UTEXT; addr<USTACKTOP;addr+=PGSIZE){
  800f57:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if(envid==0){
  800f5c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800f60:	0f 85 fb 00 00 00    	jne    801061 <fork+0x131>
	  thisenv = &envs[ENVX(sys_getenvid())];
  800f66:	e8 fb fc ff ff       	call   800c66 <sys_getenvid>
  800f6b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f70:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f73:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f78:	a3 0c 20 80 00       	mov    %eax,0x80200c
	  return 0;
  800f7d:	eb 6a                	jmp    800fe9 <fork+0xb9>
	if(envid<0) panic("sys_exofork failed\n");
  800f7f:	83 ec 04             	sub    $0x4,%esp
  800f82:	68 c9 18 80 00       	push   $0x8018c9
  800f87:	6a 70                	push   $0x70
  800f89:	68 89 18 80 00       	push   $0x801889
  800f8e:	e8 7d 02 00 00       	call   801210 <_panic>
		 panic("duppage:map02 failed %e",r);
  800f93:	50                   	push   %eax
  800f94:	68 f5 18 80 00       	push   $0x8018f5
  800f99:	6a 50                	push   $0x50
  800f9b:	68 89 18 80 00       	push   $0x801889
  800fa0:	e8 6b 02 00 00       	call   801210 <_panic>
	   if((uvpd[PDX(addr)]&PTE_P) && uvpt[PGNUM(addr)] & PTE_P)
		   duppage(envid,PGNUM(addr));
	}
        
	int r;
	if((r=sys_page_alloc(envid,(void *)UXSTACKTOP-PGSIZE,PTE_U|PTE_P|PTE_W))<0)
  800fa5:	83 ec 04             	sub    $0x4,%esp
  800fa8:	6a 07                	push   $0x7
  800faa:	68 00 f0 bf ee       	push   $0xeebff000
  800faf:	ff 75 dc             	pushl  -0x24(%ebp)
  800fb2:	e8 ed fc ff ff       	call   800ca4 <sys_page_alloc>
  800fb7:	83 c4 10             	add    $0x10,%esp
  800fba:	85 c0                	test   %eax,%eax
  800fbc:	78 36                	js     800ff4 <fork+0xc4>
		panic("fork:page alloc failed %e\n",r);

	extern void _pgfault_upcall();
	if((r = sys_env_set_pgfault_upcall(envid,_pgfault_upcall)))
  800fbe:	83 ec 08             	sub    $0x8,%esp
  800fc1:	68 bb 12 80 00       	push   $0x8012bb
  800fc6:	ff 75 dc             	pushl  -0x24(%ebp)
  800fc9:	e8 df fd ff ff       	call   800dad <sys_env_set_pgfault_upcall>
  800fce:	83 c4 10             	add    $0x10,%esp
  800fd1:	85 c0                	test   %eax,%eax
  800fd3:	75 31                	jne    801006 <fork+0xd6>
		panic("fork:set upcall failed %e\n",r);
	if((r = sys_env_set_status(envid,ENV_RUNNABLE))<0)
  800fd5:	83 ec 08             	sub    $0x8,%esp
  800fd8:	6a 02                	push   $0x2
  800fda:	ff 75 dc             	pushl  -0x24(%ebp)
  800fdd:	e8 89 fd ff ff       	call   800d6b <sys_env_set_status>
  800fe2:	83 c4 10             	add    $0x10,%esp
  800fe5:	85 c0                	test   %eax,%eax
  800fe7:	78 32                	js     80101b <fork+0xeb>
		panic("fork:set status failed %e\n",r);
	return envid;
       	
}
  800fe9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800fec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fef:	5b                   	pop    %ebx
  800ff0:	5e                   	pop    %esi
  800ff1:	5f                   	pop    %edi
  800ff2:	5d                   	pop    %ebp
  800ff3:	c3                   	ret    
		panic("fork:page alloc failed %e\n",r);
  800ff4:	50                   	push   %eax
  800ff5:	68 0d 19 80 00       	push   $0x80190d
  800ffa:	6a 7d                	push   $0x7d
  800ffc:	68 89 18 80 00       	push   $0x801889
  801001:	e8 0a 02 00 00       	call   801210 <_panic>
		panic("fork:set upcall failed %e\n",r);
  801006:	50                   	push   %eax
  801007:	68 28 19 80 00       	push   $0x801928
  80100c:	68 81 00 00 00       	push   $0x81
  801011:	68 89 18 80 00       	push   $0x801889
  801016:	e8 f5 01 00 00       	call   801210 <_panic>
		panic("fork:set status failed %e\n",r);
  80101b:	50                   	push   %eax
  80101c:	68 43 19 80 00       	push   $0x801943
  801021:	68 83 00 00 00       	push   $0x83
  801026:	68 89 18 80 00       	push   $0x801889
  80102b:	e8 e0 01 00 00       	call   801210 <_panic>
	 if((perm&PTE_COW) && (r=sys_page_map(parent_envid,va,parent_envid,va,perm))<0){
  801030:	83 ec 0c             	sub    $0xc,%esp
  801033:	68 05 08 00 00       	push   $0x805
  801038:	57                   	push   %edi
  801039:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80103c:	50                   	push   %eax
  80103d:	57                   	push   %edi
  80103e:	50                   	push   %eax
  80103f:	e8 a3 fc ff ff       	call   800ce7 <sys_page_map>
  801044:	83 c4 20             	add    $0x20,%esp
  801047:	85 c0                	test   %eax,%eax
  801049:	0f 88 44 ff ff ff    	js     800f93 <fork+0x63>
	for(addr=(uintptr_t)UTEXT; addr<USTACKTOP;addr+=PGSIZE){
  80104f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801055:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80105b:	0f 84 44 ff ff ff    	je     800fa5 <fork+0x75>
	   if((uvpd[PDX(addr)]&PTE_P) && uvpt[PGNUM(addr)] & PTE_P)
  801061:	89 d8                	mov    %ebx,%eax
  801063:	c1 e8 16             	shr    $0x16,%eax
  801066:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80106d:	a8 01                	test   $0x1,%al
  80106f:	74 de                	je     80104f <fork+0x11f>
  801071:	89 de                	mov    %ebx,%esi
  801073:	c1 ee 0c             	shr    $0xc,%esi
  801076:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80107d:	a8 01                	test   $0x1,%al
  80107f:	74 ce                	je     80104f <fork+0x11f>
        envid_t parent_envid = sys_getenvid();
  801081:	e8 e0 fb ff ff       	call   800c66 <sys_getenvid>
  801086:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	void *va = (void *)(pn*PGSIZE);
  801089:	89 f7                	mov    %esi,%edi
  80108b:	c1 e7 0c             	shl    $0xc,%edi
	if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)){
  80108e:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801095:	a8 02                	test   $0x2,%al
  801097:	75 27                	jne    8010c0 <fork+0x190>
  801099:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010a0:	f6 c4 08             	test   $0x8,%ah
  8010a3:	75 1b                	jne    8010c0 <fork+0x190>
	 if((r=sys_page_map(parent_envid,va,envid,va,perm))<0)
  8010a5:	83 ec 0c             	sub    $0xc,%esp
  8010a8:	6a 05                	push   $0x5
  8010aa:	57                   	push   %edi
  8010ab:	ff 75 e0             	pushl  -0x20(%ebp)
  8010ae:	57                   	push   %edi
  8010af:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010b2:	e8 30 fc ff ff       	call   800ce7 <sys_page_map>
  8010b7:	83 c4 20             	add    $0x20,%esp
  8010ba:	85 c0                	test   %eax,%eax
  8010bc:	79 91                	jns    80104f <fork+0x11f>
  8010be:	eb 20                	jmp    8010e0 <fork+0x1b0>
  8010c0:	83 ec 0c             	sub    $0xc,%esp
  8010c3:	68 05 08 00 00       	push   $0x805
  8010c8:	57                   	push   %edi
  8010c9:	ff 75 e0             	pushl  -0x20(%ebp)
  8010cc:	57                   	push   %edi
  8010cd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010d0:	e8 12 fc ff ff       	call   800ce7 <sys_page_map>
  8010d5:	83 c4 20             	add    $0x20,%esp
  8010d8:	85 c0                	test   %eax,%eax
  8010da:	0f 89 50 ff ff ff    	jns    801030 <fork+0x100>
		 panic("duppage:map01 failed %e",r);
  8010e0:	50                   	push   %eax
  8010e1:	68 dd 18 80 00       	push   $0x8018dd
  8010e6:	6a 4e                	push   $0x4e
  8010e8:	68 89 18 80 00       	push   $0x801889
  8010ed:	e8 1e 01 00 00       	call   801210 <_panic>

008010f2 <sfork>:

// Challenge!
int
sfork(void)
{
  8010f2:	55                   	push   %ebp
  8010f3:	89 e5                	mov    %esp,%ebp
  8010f5:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010f8:	68 5e 19 80 00       	push   $0x80195e
  8010fd:	68 8c 00 00 00       	push   $0x8c
  801102:	68 89 18 80 00       	push   $0x801889
  801107:	e8 04 01 00 00       	call   801210 <_panic>

0080110c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80110c:	55                   	push   %ebp
  80110d:	89 e5                	mov    %esp,%ebp
  80110f:	56                   	push   %esi
  801110:	53                   	push   %ebx
  801111:	8b 75 08             	mov    0x8(%ebp),%esi
  801114:	8b 45 0c             	mov    0xc(%ebp),%eax
  801117:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        //	panic("ipc_recv not implemented");
        int r;
       	if(pg!=NULL){
  80111a:	85 c0                	test   %eax,%eax
  80111c:	74 3b                	je     801159 <ipc_recv+0x4d>
	  r = sys_ipc_recv(pg);
  80111e:	83 ec 0c             	sub    $0xc,%esp
  801121:	50                   	push   %eax
  801122:	e8 eb fc ff ff       	call   800e12 <sys_ipc_recv>
  801127:	83 c4 10             	add    $0x10,%esp
	}else
	  r = sys_ipc_recv((void *)UTOP);
	if(r<0){
  80112a:	85 c0                	test   %eax,%eax
  80112c:	78 3d                	js     80116b <ipc_recv+0x5f>
	if(perm_store!=NULL){
		*perm_store = 0;
            }
        	return r;
           }else{
	     if(from_env_store!=NULL)
  80112e:	85 f6                	test   %esi,%esi
  801130:	74 0a                	je     80113c <ipc_recv+0x30>
		     *from_env_store = thisenv->env_ipc_from;
  801132:	a1 0c 20 80 00       	mov    0x80200c,%eax
  801137:	8b 40 74             	mov    0x74(%eax),%eax
  80113a:	89 06                	mov    %eax,(%esi)
	     if(perm_store != NULL)
  80113c:	85 db                	test   %ebx,%ebx
  80113e:	74 0a                	je     80114a <ipc_recv+0x3e>
		     *perm_store = thisenv->env_ipc_perm;
  801140:	a1 0c 20 80 00       	mov    0x80200c,%eax
  801145:	8b 40 78             	mov    0x78(%eax),%eax
  801148:	89 03                	mov    %eax,(%ebx)
	     return thisenv->env_ipc_value;
  80114a:	a1 0c 20 80 00       	mov    0x80200c,%eax
  80114f:	8b 40 70             	mov    0x70(%eax),%eax
	   }

}
  801152:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801155:	5b                   	pop    %ebx
  801156:	5e                   	pop    %esi
  801157:	5d                   	pop    %ebp
  801158:	c3                   	ret    
	  r = sys_ipc_recv((void *)UTOP);
  801159:	83 ec 0c             	sub    $0xc,%esp
  80115c:	68 00 00 c0 ee       	push   $0xeec00000
  801161:	e8 ac fc ff ff       	call   800e12 <sys_ipc_recv>
  801166:	83 c4 10             	add    $0x10,%esp
  801169:	eb bf                	jmp    80112a <ipc_recv+0x1e>
	if(from_env_store!=NULL){
  80116b:	85 f6                	test   %esi,%esi
  80116d:	74 06                	je     801175 <ipc_recv+0x69>
	  *from_env_store = 0;
  80116f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if(perm_store!=NULL){
  801175:	85 db                	test   %ebx,%ebx
  801177:	74 d9                	je     801152 <ipc_recv+0x46>
		*perm_store = 0;
  801179:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80117f:	eb d1                	jmp    801152 <ipc_recv+0x46>

00801181 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801181:	55                   	push   %ebp
  801182:	89 e5                	mov    %esp,%ebp
  801184:	57                   	push   %edi
  801185:	56                   	push   %esi
  801186:	53                   	push   %ebx
  801187:	83 ec 0c             	sub    $0xc,%esp
  80118a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80118d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801190:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if(pg==NULL) pg = (void *)UTOP;
  801193:	85 db                	test   %ebx,%ebx
  801195:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80119a:	0f 44 d8             	cmove  %eax,%ebx
	while((r=sys_ipc_try_send(to_env,val,pg,perm))<0){
  80119d:	ff 75 14             	pushl  0x14(%ebp)
  8011a0:	53                   	push   %ebx
  8011a1:	56                   	push   %esi
  8011a2:	57                   	push   %edi
  8011a3:	e8 47 fc ff ff       	call   800def <sys_ipc_try_send>
  8011a8:	83 c4 10             	add    $0x10,%esp
  8011ab:	85 c0                	test   %eax,%eax
  8011ad:	79 20                	jns    8011cf <ipc_send+0x4e>
	    if(r!=-E_IPC_NOT_RECV){
  8011af:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8011b2:	75 07                	jne    8011bb <ipc_send+0x3a>
		    panic("ipc_send:send message failed\n");
	    }
	    sys_yield();
  8011b4:	e8 cc fa ff ff       	call   800c85 <sys_yield>
  8011b9:	eb e2                	jmp    80119d <ipc_send+0x1c>
		    panic("ipc_send:send message failed\n");
  8011bb:	83 ec 04             	sub    $0x4,%esp
  8011be:	68 96 19 80 00       	push   $0x801996
  8011c3:	6a 43                	push   $0x43
  8011c5:	68 b4 19 80 00       	push   $0x8019b4
  8011ca:	e8 41 00 00 00       	call   801210 <_panic>
	}

}
  8011cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d2:	5b                   	pop    %ebx
  8011d3:	5e                   	pop    %esi
  8011d4:	5f                   	pop    %edi
  8011d5:	5d                   	pop    %ebp
  8011d6:	c3                   	ret    

008011d7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8011d7:	55                   	push   %ebp
  8011d8:	89 e5                	mov    %esp,%ebp
  8011da:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8011dd:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8011e2:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8011e5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8011eb:	8b 52 50             	mov    0x50(%edx),%edx
  8011ee:	39 ca                	cmp    %ecx,%edx
  8011f0:	74 11                	je     801203 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  8011f2:	83 c0 01             	add    $0x1,%eax
  8011f5:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011fa:	75 e6                	jne    8011e2 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8011fc:	b8 00 00 00 00       	mov    $0x0,%eax
  801201:	eb 0b                	jmp    80120e <ipc_find_env+0x37>
			return envs[i].env_id;
  801203:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801206:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80120b:	8b 40 48             	mov    0x48(%eax),%eax
}
  80120e:	5d                   	pop    %ebp
  80120f:	c3                   	ret    

00801210 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801210:	55                   	push   %ebp
  801211:	89 e5                	mov    %esp,%ebp
  801213:	56                   	push   %esi
  801214:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801215:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801218:	8b 35 08 20 80 00    	mov    0x802008,%esi
  80121e:	e8 43 fa ff ff       	call   800c66 <sys_getenvid>
  801223:	83 ec 0c             	sub    $0xc,%esp
  801226:	ff 75 0c             	pushl  0xc(%ebp)
  801229:	ff 75 08             	pushl  0x8(%ebp)
  80122c:	56                   	push   %esi
  80122d:	50                   	push   %eax
  80122e:	68 c0 19 80 00       	push   $0x8019c0
  801233:	e8 54 f0 ff ff       	call   80028c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801238:	83 c4 18             	add    $0x18,%esp
  80123b:	53                   	push   %ebx
  80123c:	ff 75 10             	pushl  0x10(%ebp)
  80123f:	e8 f7 ef ff ff       	call   80023b <vcprintf>
	cprintf("\n");
  801244:	c7 04 24 b2 19 80 00 	movl   $0x8019b2,(%esp)
  80124b:	e8 3c f0 ff ff       	call   80028c <cprintf>
  801250:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801253:	cc                   	int3   
  801254:	eb fd                	jmp    801253 <_panic+0x43>

00801256 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801256:	55                   	push   %ebp
  801257:	89 e5                	mov    %esp,%ebp
  801259:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80125c:	83 3d 10 20 80 00 00 	cmpl   $0x0,0x802010
  801263:	74 0a                	je     80126f <set_pgfault_handler+0x19>
			panic("set_pgfault_handler %e",r);
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
	}
       
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801265:	8b 45 08             	mov    0x8(%ebp),%eax
  801268:	a3 10 20 80 00       	mov    %eax,0x802010
}
  80126d:	c9                   	leave  
  80126e:	c3                   	ret    
		if((r=sys_page_alloc(thisenv->env_id,(void *)UXSTACKTOP-PGSIZE,PTE_P|PTE_W|PTE_U))<0)
  80126f:	a1 0c 20 80 00       	mov    0x80200c,%eax
  801274:	8b 40 48             	mov    0x48(%eax),%eax
  801277:	83 ec 04             	sub    $0x4,%esp
  80127a:	6a 07                	push   $0x7
  80127c:	68 00 f0 bf ee       	push   $0xeebff000
  801281:	50                   	push   %eax
  801282:	e8 1d fa ff ff       	call   800ca4 <sys_page_alloc>
  801287:	83 c4 10             	add    $0x10,%esp
  80128a:	85 c0                	test   %eax,%eax
  80128c:	78 1b                	js     8012a9 <set_pgfault_handler+0x53>
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
  80128e:	a1 0c 20 80 00       	mov    0x80200c,%eax
  801293:	8b 40 48             	mov    0x48(%eax),%eax
  801296:	83 ec 08             	sub    $0x8,%esp
  801299:	68 bb 12 80 00       	push   $0x8012bb
  80129e:	50                   	push   %eax
  80129f:	e8 09 fb ff ff       	call   800dad <sys_env_set_pgfault_upcall>
  8012a4:	83 c4 10             	add    $0x10,%esp
  8012a7:	eb bc                	jmp    801265 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler %e",r);
  8012a9:	50                   	push   %eax
  8012aa:	68 e4 19 80 00       	push   $0x8019e4
  8012af:	6a 22                	push   $0x22
  8012b1:	68 fb 19 80 00       	push   $0x8019fb
  8012b6:	e8 55 ff ff ff       	call   801210 <_panic>

008012bb <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8012bb:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8012bc:	a1 10 20 80 00       	mov    0x802010,%eax
	call *%eax
  8012c1:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8012c3:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 48(%esp), %ebp
  8012c6:	8b 6c 24 30          	mov    0x30(%esp),%ebp
        subl $4, %ebp
  8012ca:	83 ed 04             	sub    $0x4,%ebp
        movl %ebp, 48(%esp)
  8012cd:	89 6c 24 30          	mov    %ebp,0x30(%esp)
        movl 40(%esp), %eax
  8012d1:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl %eax, (%ebp)
  8012d5:	89 45 00             	mov    %eax,0x0(%ebp)
	// Restore the trap-time registers.  After you do this, you
 	// can no longer modify any general-purpose registers.
 	// LAB 4: Your code here.
        addl $8, %esp
  8012d8:	83 c4 08             	add    $0x8,%esp
        popal
  8012db:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $4, %esp
  8012dc:	83 c4 04             	add    $0x4,%esp
        popfl
  8012df:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  8012e0:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  8012e1:	c3                   	ret    
  8012e2:	66 90                	xchg   %ax,%ax
  8012e4:	66 90                	xchg   %ax,%ax
  8012e6:	66 90                	xchg   %ax,%ax
  8012e8:	66 90                	xchg   %ax,%ax
  8012ea:	66 90                	xchg   %ax,%ax
  8012ec:	66 90                	xchg   %ax,%ax
  8012ee:	66 90                	xchg   %ax,%ax

008012f0 <__udivdi3>:
  8012f0:	55                   	push   %ebp
  8012f1:	57                   	push   %edi
  8012f2:	56                   	push   %esi
  8012f3:	53                   	push   %ebx
  8012f4:	83 ec 1c             	sub    $0x1c,%esp
  8012f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8012fb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8012ff:	8b 74 24 34          	mov    0x34(%esp),%esi
  801303:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801307:	85 d2                	test   %edx,%edx
  801309:	75 35                	jne    801340 <__udivdi3+0x50>
  80130b:	39 f3                	cmp    %esi,%ebx
  80130d:	0f 87 bd 00 00 00    	ja     8013d0 <__udivdi3+0xe0>
  801313:	85 db                	test   %ebx,%ebx
  801315:	89 d9                	mov    %ebx,%ecx
  801317:	75 0b                	jne    801324 <__udivdi3+0x34>
  801319:	b8 01 00 00 00       	mov    $0x1,%eax
  80131e:	31 d2                	xor    %edx,%edx
  801320:	f7 f3                	div    %ebx
  801322:	89 c1                	mov    %eax,%ecx
  801324:	31 d2                	xor    %edx,%edx
  801326:	89 f0                	mov    %esi,%eax
  801328:	f7 f1                	div    %ecx
  80132a:	89 c6                	mov    %eax,%esi
  80132c:	89 e8                	mov    %ebp,%eax
  80132e:	89 f7                	mov    %esi,%edi
  801330:	f7 f1                	div    %ecx
  801332:	89 fa                	mov    %edi,%edx
  801334:	83 c4 1c             	add    $0x1c,%esp
  801337:	5b                   	pop    %ebx
  801338:	5e                   	pop    %esi
  801339:	5f                   	pop    %edi
  80133a:	5d                   	pop    %ebp
  80133b:	c3                   	ret    
  80133c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801340:	39 f2                	cmp    %esi,%edx
  801342:	77 7c                	ja     8013c0 <__udivdi3+0xd0>
  801344:	0f bd fa             	bsr    %edx,%edi
  801347:	83 f7 1f             	xor    $0x1f,%edi
  80134a:	0f 84 98 00 00 00    	je     8013e8 <__udivdi3+0xf8>
  801350:	89 f9                	mov    %edi,%ecx
  801352:	b8 20 00 00 00       	mov    $0x20,%eax
  801357:	29 f8                	sub    %edi,%eax
  801359:	d3 e2                	shl    %cl,%edx
  80135b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80135f:	89 c1                	mov    %eax,%ecx
  801361:	89 da                	mov    %ebx,%edx
  801363:	d3 ea                	shr    %cl,%edx
  801365:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801369:	09 d1                	or     %edx,%ecx
  80136b:	89 f2                	mov    %esi,%edx
  80136d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801371:	89 f9                	mov    %edi,%ecx
  801373:	d3 e3                	shl    %cl,%ebx
  801375:	89 c1                	mov    %eax,%ecx
  801377:	d3 ea                	shr    %cl,%edx
  801379:	89 f9                	mov    %edi,%ecx
  80137b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80137f:	d3 e6                	shl    %cl,%esi
  801381:	89 eb                	mov    %ebp,%ebx
  801383:	89 c1                	mov    %eax,%ecx
  801385:	d3 eb                	shr    %cl,%ebx
  801387:	09 de                	or     %ebx,%esi
  801389:	89 f0                	mov    %esi,%eax
  80138b:	f7 74 24 08          	divl   0x8(%esp)
  80138f:	89 d6                	mov    %edx,%esi
  801391:	89 c3                	mov    %eax,%ebx
  801393:	f7 64 24 0c          	mull   0xc(%esp)
  801397:	39 d6                	cmp    %edx,%esi
  801399:	72 0c                	jb     8013a7 <__udivdi3+0xb7>
  80139b:	89 f9                	mov    %edi,%ecx
  80139d:	d3 e5                	shl    %cl,%ebp
  80139f:	39 c5                	cmp    %eax,%ebp
  8013a1:	73 5d                	jae    801400 <__udivdi3+0x110>
  8013a3:	39 d6                	cmp    %edx,%esi
  8013a5:	75 59                	jne    801400 <__udivdi3+0x110>
  8013a7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8013aa:	31 ff                	xor    %edi,%edi
  8013ac:	89 fa                	mov    %edi,%edx
  8013ae:	83 c4 1c             	add    $0x1c,%esp
  8013b1:	5b                   	pop    %ebx
  8013b2:	5e                   	pop    %esi
  8013b3:	5f                   	pop    %edi
  8013b4:	5d                   	pop    %ebp
  8013b5:	c3                   	ret    
  8013b6:	8d 76 00             	lea    0x0(%esi),%esi
  8013b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8013c0:	31 ff                	xor    %edi,%edi
  8013c2:	31 c0                	xor    %eax,%eax
  8013c4:	89 fa                	mov    %edi,%edx
  8013c6:	83 c4 1c             	add    $0x1c,%esp
  8013c9:	5b                   	pop    %ebx
  8013ca:	5e                   	pop    %esi
  8013cb:	5f                   	pop    %edi
  8013cc:	5d                   	pop    %ebp
  8013cd:	c3                   	ret    
  8013ce:	66 90                	xchg   %ax,%ax
  8013d0:	31 ff                	xor    %edi,%edi
  8013d2:	89 e8                	mov    %ebp,%eax
  8013d4:	89 f2                	mov    %esi,%edx
  8013d6:	f7 f3                	div    %ebx
  8013d8:	89 fa                	mov    %edi,%edx
  8013da:	83 c4 1c             	add    $0x1c,%esp
  8013dd:	5b                   	pop    %ebx
  8013de:	5e                   	pop    %esi
  8013df:	5f                   	pop    %edi
  8013e0:	5d                   	pop    %ebp
  8013e1:	c3                   	ret    
  8013e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8013e8:	39 f2                	cmp    %esi,%edx
  8013ea:	72 06                	jb     8013f2 <__udivdi3+0x102>
  8013ec:	31 c0                	xor    %eax,%eax
  8013ee:	39 eb                	cmp    %ebp,%ebx
  8013f0:	77 d2                	ja     8013c4 <__udivdi3+0xd4>
  8013f2:	b8 01 00 00 00       	mov    $0x1,%eax
  8013f7:	eb cb                	jmp    8013c4 <__udivdi3+0xd4>
  8013f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801400:	89 d8                	mov    %ebx,%eax
  801402:	31 ff                	xor    %edi,%edi
  801404:	eb be                	jmp    8013c4 <__udivdi3+0xd4>
  801406:	66 90                	xchg   %ax,%ax
  801408:	66 90                	xchg   %ax,%ax
  80140a:	66 90                	xchg   %ax,%ax
  80140c:	66 90                	xchg   %ax,%ax
  80140e:	66 90                	xchg   %ax,%ax

00801410 <__umoddi3>:
  801410:	55                   	push   %ebp
  801411:	57                   	push   %edi
  801412:	56                   	push   %esi
  801413:	53                   	push   %ebx
  801414:	83 ec 1c             	sub    $0x1c,%esp
  801417:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80141b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80141f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801423:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801427:	85 ed                	test   %ebp,%ebp
  801429:	89 f0                	mov    %esi,%eax
  80142b:	89 da                	mov    %ebx,%edx
  80142d:	75 19                	jne    801448 <__umoddi3+0x38>
  80142f:	39 df                	cmp    %ebx,%edi
  801431:	0f 86 b1 00 00 00    	jbe    8014e8 <__umoddi3+0xd8>
  801437:	f7 f7                	div    %edi
  801439:	89 d0                	mov    %edx,%eax
  80143b:	31 d2                	xor    %edx,%edx
  80143d:	83 c4 1c             	add    $0x1c,%esp
  801440:	5b                   	pop    %ebx
  801441:	5e                   	pop    %esi
  801442:	5f                   	pop    %edi
  801443:	5d                   	pop    %ebp
  801444:	c3                   	ret    
  801445:	8d 76 00             	lea    0x0(%esi),%esi
  801448:	39 dd                	cmp    %ebx,%ebp
  80144a:	77 f1                	ja     80143d <__umoddi3+0x2d>
  80144c:	0f bd cd             	bsr    %ebp,%ecx
  80144f:	83 f1 1f             	xor    $0x1f,%ecx
  801452:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801456:	0f 84 b4 00 00 00    	je     801510 <__umoddi3+0x100>
  80145c:	b8 20 00 00 00       	mov    $0x20,%eax
  801461:	89 c2                	mov    %eax,%edx
  801463:	8b 44 24 04          	mov    0x4(%esp),%eax
  801467:	29 c2                	sub    %eax,%edx
  801469:	89 c1                	mov    %eax,%ecx
  80146b:	89 f8                	mov    %edi,%eax
  80146d:	d3 e5                	shl    %cl,%ebp
  80146f:	89 d1                	mov    %edx,%ecx
  801471:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801475:	d3 e8                	shr    %cl,%eax
  801477:	09 c5                	or     %eax,%ebp
  801479:	8b 44 24 04          	mov    0x4(%esp),%eax
  80147d:	89 c1                	mov    %eax,%ecx
  80147f:	d3 e7                	shl    %cl,%edi
  801481:	89 d1                	mov    %edx,%ecx
  801483:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801487:	89 df                	mov    %ebx,%edi
  801489:	d3 ef                	shr    %cl,%edi
  80148b:	89 c1                	mov    %eax,%ecx
  80148d:	89 f0                	mov    %esi,%eax
  80148f:	d3 e3                	shl    %cl,%ebx
  801491:	89 d1                	mov    %edx,%ecx
  801493:	89 fa                	mov    %edi,%edx
  801495:	d3 e8                	shr    %cl,%eax
  801497:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80149c:	09 d8                	or     %ebx,%eax
  80149e:	f7 f5                	div    %ebp
  8014a0:	d3 e6                	shl    %cl,%esi
  8014a2:	89 d1                	mov    %edx,%ecx
  8014a4:	f7 64 24 08          	mull   0x8(%esp)
  8014a8:	39 d1                	cmp    %edx,%ecx
  8014aa:	89 c3                	mov    %eax,%ebx
  8014ac:	89 d7                	mov    %edx,%edi
  8014ae:	72 06                	jb     8014b6 <__umoddi3+0xa6>
  8014b0:	75 0e                	jne    8014c0 <__umoddi3+0xb0>
  8014b2:	39 c6                	cmp    %eax,%esi
  8014b4:	73 0a                	jae    8014c0 <__umoddi3+0xb0>
  8014b6:	2b 44 24 08          	sub    0x8(%esp),%eax
  8014ba:	19 ea                	sbb    %ebp,%edx
  8014bc:	89 d7                	mov    %edx,%edi
  8014be:	89 c3                	mov    %eax,%ebx
  8014c0:	89 ca                	mov    %ecx,%edx
  8014c2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8014c7:	29 de                	sub    %ebx,%esi
  8014c9:	19 fa                	sbb    %edi,%edx
  8014cb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  8014cf:	89 d0                	mov    %edx,%eax
  8014d1:	d3 e0                	shl    %cl,%eax
  8014d3:	89 d9                	mov    %ebx,%ecx
  8014d5:	d3 ee                	shr    %cl,%esi
  8014d7:	d3 ea                	shr    %cl,%edx
  8014d9:	09 f0                	or     %esi,%eax
  8014db:	83 c4 1c             	add    $0x1c,%esp
  8014de:	5b                   	pop    %ebx
  8014df:	5e                   	pop    %esi
  8014e0:	5f                   	pop    %edi
  8014e1:	5d                   	pop    %ebp
  8014e2:	c3                   	ret    
  8014e3:	90                   	nop
  8014e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014e8:	85 ff                	test   %edi,%edi
  8014ea:	89 f9                	mov    %edi,%ecx
  8014ec:	75 0b                	jne    8014f9 <__umoddi3+0xe9>
  8014ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8014f3:	31 d2                	xor    %edx,%edx
  8014f5:	f7 f7                	div    %edi
  8014f7:	89 c1                	mov    %eax,%ecx
  8014f9:	89 d8                	mov    %ebx,%eax
  8014fb:	31 d2                	xor    %edx,%edx
  8014fd:	f7 f1                	div    %ecx
  8014ff:	89 f0                	mov    %esi,%eax
  801501:	f7 f1                	div    %ecx
  801503:	e9 31 ff ff ff       	jmp    801439 <__umoddi3+0x29>
  801508:	90                   	nop
  801509:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801510:	39 dd                	cmp    %ebx,%ebp
  801512:	72 08                	jb     80151c <__umoddi3+0x10c>
  801514:	39 f7                	cmp    %esi,%edi
  801516:	0f 87 21 ff ff ff    	ja     80143d <__umoddi3+0x2d>
  80151c:	89 da                	mov    %ebx,%edx
  80151e:	89 f0                	mov    %esi,%eax
  801520:	29 f8                	sub    %edi,%eax
  801522:	19 ea                	sbb    %ebp,%edx
  801524:	e9 14 ff ff ff       	jmp    80143d <__umoddi3+0x2d>
