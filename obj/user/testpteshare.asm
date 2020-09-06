
obj/user/testpteshare.debug:     file format elf32-i386


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
  80002c:	e8 65 01 00 00       	call   800196 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <childofspawn>:
	breakpoint();
}

void
childofspawn(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	strcpy(VA, msg2);
  800039:	ff 35 00 40 80 00    	pushl  0x804000
  80003f:	68 00 00 00 a0       	push   $0xa0000000
  800044:	e8 a7 08 00 00       	call   8008f0 <strcpy>
	exit();
  800049:	e8 8e 01 00 00       	call   8001dc <exit>
}
  80004e:	83 c4 10             	add    $0x10,%esp
  800051:	c9                   	leave  
  800052:	c3                   	ret    

00800053 <umain>:
{
  800053:	55                   	push   %ebp
  800054:	89 e5                	mov    %esp,%ebp
  800056:	53                   	push   %ebx
  800057:	83 ec 04             	sub    $0x4,%esp
	if (argc != 0)
  80005a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80005e:	0f 85 d2 00 00 00    	jne    800136 <umain+0xe3>
	if ((r = sys_page_alloc(0, VA, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800064:	83 ec 04             	sub    $0x4,%esp
  800067:	68 07 04 00 00       	push   $0x407
  80006c:	68 00 00 00 a0       	push   $0xa0000000
  800071:	6a 00                	push   $0x0
  800073:	e8 71 0c 00 00       	call   800ce9 <sys_page_alloc>
  800078:	83 c4 10             	add    $0x10,%esp
  80007b:	85 c0                	test   %eax,%eax
  80007d:	0f 88 bd 00 00 00    	js     800140 <umain+0xed>
	if ((r = fork()) < 0)
  800083:	e8 46 0f 00 00       	call   800fce <fork>
  800088:	89 c3                	mov    %eax,%ebx
  80008a:	85 c0                	test   %eax,%eax
  80008c:	0f 88 c0 00 00 00    	js     800152 <umain+0xff>
	if (r == 0) {
  800092:	85 c0                	test   %eax,%eax
  800094:	0f 84 ca 00 00 00    	je     800164 <umain+0x111>
	wait(r);
  80009a:	83 ec 0c             	sub    $0xc,%esp
  80009d:	53                   	push   %ebx
  80009e:	e8 79 22 00 00       	call   80231c <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000a3:	83 c4 08             	add    $0x8,%esp
  8000a6:	ff 35 04 40 80 00    	pushl  0x804004
  8000ac:	68 00 00 00 a0       	push   $0xa0000000
  8000b1:	e8 e0 08 00 00       	call   800996 <strcmp>
  8000b6:	83 c4 08             	add    $0x8,%esp
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	b8 00 29 80 00       	mov    $0x802900,%eax
  8000c0:	ba 06 29 80 00       	mov    $0x802906,%edx
  8000c5:	0f 45 c2             	cmovne %edx,%eax
  8000c8:	50                   	push   %eax
  8000c9:	68 3c 29 80 00       	push   $0x80293c
  8000ce:	e8 fe 01 00 00       	call   8002d1 <cprintf>
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  8000d3:	6a 00                	push   $0x0
  8000d5:	68 57 29 80 00       	push   $0x802957
  8000da:	68 5c 29 80 00       	push   $0x80295c
  8000df:	68 5b 29 80 00       	push   $0x80295b
  8000e4:	e8 69 1e 00 00       	call   801f52 <spawnl>
  8000e9:	83 c4 20             	add    $0x20,%esp
  8000ec:	85 c0                	test   %eax,%eax
  8000ee:	0f 88 90 00 00 00    	js     800184 <umain+0x131>
	wait(r);
  8000f4:	83 ec 0c             	sub    $0xc,%esp
  8000f7:	50                   	push   %eax
  8000f8:	e8 1f 22 00 00       	call   80231c <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  8000fd:	83 c4 08             	add    $0x8,%esp
  800100:	ff 35 00 40 80 00    	pushl  0x804000
  800106:	68 00 00 00 a0       	push   $0xa0000000
  80010b:	e8 86 08 00 00       	call   800996 <strcmp>
  800110:	83 c4 08             	add    $0x8,%esp
  800113:	85 c0                	test   %eax,%eax
  800115:	b8 00 29 80 00       	mov    $0x802900,%eax
  80011a:	ba 06 29 80 00       	mov    $0x802906,%edx
  80011f:	0f 45 c2             	cmovne %edx,%eax
  800122:	50                   	push   %eax
  800123:	68 73 29 80 00       	push   $0x802973
  800128:	e8 a4 01 00 00       	call   8002d1 <cprintf>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  80012d:	cc                   	int3   
}
  80012e:	83 c4 10             	add    $0x10,%esp
  800131:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800134:	c9                   	leave  
  800135:	c3                   	ret    
		childofspawn();
  800136:	e8 f8 fe ff ff       	call   800033 <childofspawn>
  80013b:	e9 24 ff ff ff       	jmp    800064 <umain+0x11>
		panic("sys_page_alloc: %e", r);
  800140:	50                   	push   %eax
  800141:	68 0c 29 80 00       	push   $0x80290c
  800146:	6a 13                	push   $0x13
  800148:	68 1f 29 80 00       	push   $0x80291f
  80014d:	e8 a4 00 00 00       	call   8001f6 <_panic>
		panic("fork: %e", r);
  800152:	50                   	push   %eax
  800153:	68 33 29 80 00       	push   $0x802933
  800158:	6a 17                	push   $0x17
  80015a:	68 1f 29 80 00       	push   $0x80291f
  80015f:	e8 92 00 00 00       	call   8001f6 <_panic>
		strcpy(VA, msg);
  800164:	83 ec 08             	sub    $0x8,%esp
  800167:	ff 35 04 40 80 00    	pushl  0x804004
  80016d:	68 00 00 00 a0       	push   $0xa0000000
  800172:	e8 79 07 00 00       	call   8008f0 <strcpy>
		exit();
  800177:	e8 60 00 00 00       	call   8001dc <exit>
  80017c:	83 c4 10             	add    $0x10,%esp
  80017f:	e9 16 ff ff ff       	jmp    80009a <umain+0x47>
		panic("spawn: %e", r);
  800184:	50                   	push   %eax
  800185:	68 69 29 80 00       	push   $0x802969
  80018a:	6a 21                	push   $0x21
  80018c:	68 1f 29 80 00       	push   $0x80291f
  800191:	e8 60 00 00 00       	call   8001f6 <_panic>

00800196 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800196:	55                   	push   %ebp
  800197:	89 e5                	mov    %esp,%ebp
  800199:	56                   	push   %esi
  80019a:	53                   	push   %ebx
  80019b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80019e:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001a1:	e8 05 0b 00 00       	call   800cab <sys_getenvid>
  8001a6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001ab:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001ae:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001b3:	a3 04 50 80 00       	mov    %eax,0x805004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001b8:	85 db                	test   %ebx,%ebx
  8001ba:	7e 07                	jle    8001c3 <libmain+0x2d>
		binaryname = argv[0];
  8001bc:	8b 06                	mov    (%esi),%eax
  8001be:	a3 08 40 80 00       	mov    %eax,0x804008

	// call user main routine
	umain(argc, argv);
  8001c3:	83 ec 08             	sub    $0x8,%esp
  8001c6:	56                   	push   %esi
  8001c7:	53                   	push   %ebx
  8001c8:	e8 86 fe ff ff       	call   800053 <umain>

	// exit gracefully
	exit();
  8001cd:	e8 0a 00 00 00       	call   8001dc <exit>
}
  8001d2:	83 c4 10             	add    $0x10,%esp
  8001d5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001d8:	5b                   	pop    %ebx
  8001d9:	5e                   	pop    %esi
  8001da:	5d                   	pop    %ebp
  8001db:	c3                   	ret    

008001dc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001dc:	55                   	push   %ebp
  8001dd:	89 e5                	mov    %esp,%ebp
  8001df:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001e2:	e8 ca 11 00 00       	call   8013b1 <close_all>
	sys_env_destroy(0);
  8001e7:	83 ec 0c             	sub    $0xc,%esp
  8001ea:	6a 00                	push   $0x0
  8001ec:	e8 79 0a 00 00       	call   800c6a <sys_env_destroy>
}
  8001f1:	83 c4 10             	add    $0x10,%esp
  8001f4:	c9                   	leave  
  8001f5:	c3                   	ret    

008001f6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001f6:	55                   	push   %ebp
  8001f7:	89 e5                	mov    %esp,%ebp
  8001f9:	56                   	push   %esi
  8001fa:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001fb:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001fe:	8b 35 08 40 80 00    	mov    0x804008,%esi
  800204:	e8 a2 0a 00 00       	call   800cab <sys_getenvid>
  800209:	83 ec 0c             	sub    $0xc,%esp
  80020c:	ff 75 0c             	pushl  0xc(%ebp)
  80020f:	ff 75 08             	pushl  0x8(%ebp)
  800212:	56                   	push   %esi
  800213:	50                   	push   %eax
  800214:	68 b8 29 80 00       	push   $0x8029b8
  800219:	e8 b3 00 00 00       	call   8002d1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80021e:	83 c4 18             	add    $0x18,%esp
  800221:	53                   	push   %ebx
  800222:	ff 75 10             	pushl  0x10(%ebp)
  800225:	e8 56 00 00 00       	call   800280 <vcprintf>
	cprintf("\n");
  80022a:	c7 04 24 1f 2d 80 00 	movl   $0x802d1f,(%esp)
  800231:	e8 9b 00 00 00       	call   8002d1 <cprintf>
  800236:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800239:	cc                   	int3   
  80023a:	eb fd                	jmp    800239 <_panic+0x43>

0080023c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80023c:	55                   	push   %ebp
  80023d:	89 e5                	mov    %esp,%ebp
  80023f:	53                   	push   %ebx
  800240:	83 ec 04             	sub    $0x4,%esp
  800243:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800246:	8b 13                	mov    (%ebx),%edx
  800248:	8d 42 01             	lea    0x1(%edx),%eax
  80024b:	89 03                	mov    %eax,(%ebx)
  80024d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800250:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800254:	3d ff 00 00 00       	cmp    $0xff,%eax
  800259:	74 09                	je     800264 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80025b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80025f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800262:	c9                   	leave  
  800263:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800264:	83 ec 08             	sub    $0x8,%esp
  800267:	68 ff 00 00 00       	push   $0xff
  80026c:	8d 43 08             	lea    0x8(%ebx),%eax
  80026f:	50                   	push   %eax
  800270:	e8 b8 09 00 00       	call   800c2d <sys_cputs>
		b->idx = 0;
  800275:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80027b:	83 c4 10             	add    $0x10,%esp
  80027e:	eb db                	jmp    80025b <putch+0x1f>

00800280 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800289:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800290:	00 00 00 
	b.cnt = 0;
  800293:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80029a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80029d:	ff 75 0c             	pushl  0xc(%ebp)
  8002a0:	ff 75 08             	pushl  0x8(%ebp)
  8002a3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002a9:	50                   	push   %eax
  8002aa:	68 3c 02 80 00       	push   $0x80023c
  8002af:	e8 1a 01 00 00       	call   8003ce <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002b4:	83 c4 08             	add    $0x8,%esp
  8002b7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002bd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002c3:	50                   	push   %eax
  8002c4:	e8 64 09 00 00       	call   800c2d <sys_cputs>

	return b.cnt;
}
  8002c9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002cf:	c9                   	leave  
  8002d0:	c3                   	ret    

008002d1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002d1:	55                   	push   %ebp
  8002d2:	89 e5                	mov    %esp,%ebp
  8002d4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002d7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002da:	50                   	push   %eax
  8002db:	ff 75 08             	pushl  0x8(%ebp)
  8002de:	e8 9d ff ff ff       	call   800280 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002e3:	c9                   	leave  
  8002e4:	c3                   	ret    

008002e5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002e5:	55                   	push   %ebp
  8002e6:	89 e5                	mov    %esp,%ebp
  8002e8:	57                   	push   %edi
  8002e9:	56                   	push   %esi
  8002ea:	53                   	push   %ebx
  8002eb:	83 ec 1c             	sub    $0x1c,%esp
  8002ee:	89 c7                	mov    %eax,%edi
  8002f0:	89 d6                	mov    %edx,%esi
  8002f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002f8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002fb:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002fe:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800301:	bb 00 00 00 00       	mov    $0x0,%ebx
  800306:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800309:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80030c:	39 d3                	cmp    %edx,%ebx
  80030e:	72 05                	jb     800315 <printnum+0x30>
  800310:	39 45 10             	cmp    %eax,0x10(%ebp)
  800313:	77 7a                	ja     80038f <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800315:	83 ec 0c             	sub    $0xc,%esp
  800318:	ff 75 18             	pushl  0x18(%ebp)
  80031b:	8b 45 14             	mov    0x14(%ebp),%eax
  80031e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800321:	53                   	push   %ebx
  800322:	ff 75 10             	pushl  0x10(%ebp)
  800325:	83 ec 08             	sub    $0x8,%esp
  800328:	ff 75 e4             	pushl  -0x1c(%ebp)
  80032b:	ff 75 e0             	pushl  -0x20(%ebp)
  80032e:	ff 75 dc             	pushl  -0x24(%ebp)
  800331:	ff 75 d8             	pushl  -0x28(%ebp)
  800334:	e8 87 23 00 00       	call   8026c0 <__udivdi3>
  800339:	83 c4 18             	add    $0x18,%esp
  80033c:	52                   	push   %edx
  80033d:	50                   	push   %eax
  80033e:	89 f2                	mov    %esi,%edx
  800340:	89 f8                	mov    %edi,%eax
  800342:	e8 9e ff ff ff       	call   8002e5 <printnum>
  800347:	83 c4 20             	add    $0x20,%esp
  80034a:	eb 13                	jmp    80035f <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80034c:	83 ec 08             	sub    $0x8,%esp
  80034f:	56                   	push   %esi
  800350:	ff 75 18             	pushl  0x18(%ebp)
  800353:	ff d7                	call   *%edi
  800355:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800358:	83 eb 01             	sub    $0x1,%ebx
  80035b:	85 db                	test   %ebx,%ebx
  80035d:	7f ed                	jg     80034c <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80035f:	83 ec 08             	sub    $0x8,%esp
  800362:	56                   	push   %esi
  800363:	83 ec 04             	sub    $0x4,%esp
  800366:	ff 75 e4             	pushl  -0x1c(%ebp)
  800369:	ff 75 e0             	pushl  -0x20(%ebp)
  80036c:	ff 75 dc             	pushl  -0x24(%ebp)
  80036f:	ff 75 d8             	pushl  -0x28(%ebp)
  800372:	e8 69 24 00 00       	call   8027e0 <__umoddi3>
  800377:	83 c4 14             	add    $0x14,%esp
  80037a:	0f be 80 db 29 80 00 	movsbl 0x8029db(%eax),%eax
  800381:	50                   	push   %eax
  800382:	ff d7                	call   *%edi
}
  800384:	83 c4 10             	add    $0x10,%esp
  800387:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80038a:	5b                   	pop    %ebx
  80038b:	5e                   	pop    %esi
  80038c:	5f                   	pop    %edi
  80038d:	5d                   	pop    %ebp
  80038e:	c3                   	ret    
  80038f:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800392:	eb c4                	jmp    800358 <printnum+0x73>

00800394 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800394:	55                   	push   %ebp
  800395:	89 e5                	mov    %esp,%ebp
  800397:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80039a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80039e:	8b 10                	mov    (%eax),%edx
  8003a0:	3b 50 04             	cmp    0x4(%eax),%edx
  8003a3:	73 0a                	jae    8003af <sprintputch+0x1b>
		*b->buf++ = ch;
  8003a5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003a8:	89 08                	mov    %ecx,(%eax)
  8003aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ad:	88 02                	mov    %al,(%edx)
}
  8003af:	5d                   	pop    %ebp
  8003b0:	c3                   	ret    

008003b1 <printfmt>:
{
  8003b1:	55                   	push   %ebp
  8003b2:	89 e5                	mov    %esp,%ebp
  8003b4:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8003b7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003ba:	50                   	push   %eax
  8003bb:	ff 75 10             	pushl  0x10(%ebp)
  8003be:	ff 75 0c             	pushl  0xc(%ebp)
  8003c1:	ff 75 08             	pushl  0x8(%ebp)
  8003c4:	e8 05 00 00 00       	call   8003ce <vprintfmt>
}
  8003c9:	83 c4 10             	add    $0x10,%esp
  8003cc:	c9                   	leave  
  8003cd:	c3                   	ret    

008003ce <vprintfmt>:
{
  8003ce:	55                   	push   %ebp
  8003cf:	89 e5                	mov    %esp,%ebp
  8003d1:	57                   	push   %edi
  8003d2:	56                   	push   %esi
  8003d3:	53                   	push   %ebx
  8003d4:	83 ec 2c             	sub    $0x2c,%esp
  8003d7:	8b 75 08             	mov    0x8(%ebp),%esi
  8003da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003dd:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003e0:	e9 c1 03 00 00       	jmp    8007a6 <vprintfmt+0x3d8>
		padc = ' ';
  8003e5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8003e9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8003f0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8003f7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003fe:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800403:	8d 47 01             	lea    0x1(%edi),%eax
  800406:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800409:	0f b6 17             	movzbl (%edi),%edx
  80040c:	8d 42 dd             	lea    -0x23(%edx),%eax
  80040f:	3c 55                	cmp    $0x55,%al
  800411:	0f 87 12 04 00 00    	ja     800829 <vprintfmt+0x45b>
  800417:	0f b6 c0             	movzbl %al,%eax
  80041a:	ff 24 85 20 2b 80 00 	jmp    *0x802b20(,%eax,4)
  800421:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800424:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800428:	eb d9                	jmp    800403 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80042a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80042d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800431:	eb d0                	jmp    800403 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800433:	0f b6 d2             	movzbl %dl,%edx
  800436:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800439:	b8 00 00 00 00       	mov    $0x0,%eax
  80043e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800441:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800444:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800448:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80044b:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80044e:	83 f9 09             	cmp    $0x9,%ecx
  800451:	77 55                	ja     8004a8 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800453:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800456:	eb e9                	jmp    800441 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  800458:	8b 45 14             	mov    0x14(%ebp),%eax
  80045b:	8b 00                	mov    (%eax),%eax
  80045d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800460:	8b 45 14             	mov    0x14(%ebp),%eax
  800463:	8d 40 04             	lea    0x4(%eax),%eax
  800466:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800469:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80046c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800470:	79 91                	jns    800403 <vprintfmt+0x35>
				width = precision, precision = -1;
  800472:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800475:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800478:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80047f:	eb 82                	jmp    800403 <vprintfmt+0x35>
  800481:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800484:	85 c0                	test   %eax,%eax
  800486:	ba 00 00 00 00       	mov    $0x0,%edx
  80048b:	0f 49 d0             	cmovns %eax,%edx
  80048e:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800491:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800494:	e9 6a ff ff ff       	jmp    800403 <vprintfmt+0x35>
  800499:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80049c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004a3:	e9 5b ff ff ff       	jmp    800403 <vprintfmt+0x35>
  8004a8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004ab:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004ae:	eb bc                	jmp    80046c <vprintfmt+0x9e>
			lflag++;
  8004b0:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8004b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004b6:	e9 48 ff ff ff       	jmp    800403 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8004bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004be:	8d 78 04             	lea    0x4(%eax),%edi
  8004c1:	83 ec 08             	sub    $0x8,%esp
  8004c4:	53                   	push   %ebx
  8004c5:	ff 30                	pushl  (%eax)
  8004c7:	ff d6                	call   *%esi
			break;
  8004c9:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004cc:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8004cf:	e9 cf 02 00 00       	jmp    8007a3 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  8004d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d7:	8d 78 04             	lea    0x4(%eax),%edi
  8004da:	8b 00                	mov    (%eax),%eax
  8004dc:	99                   	cltd   
  8004dd:	31 d0                	xor    %edx,%eax
  8004df:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004e1:	83 f8 0f             	cmp    $0xf,%eax
  8004e4:	7f 23                	jg     800509 <vprintfmt+0x13b>
  8004e6:	8b 14 85 80 2c 80 00 	mov    0x802c80(,%eax,4),%edx
  8004ed:	85 d2                	test   %edx,%edx
  8004ef:	74 18                	je     800509 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8004f1:	52                   	push   %edx
  8004f2:	68 f1 2e 80 00       	push   $0x802ef1
  8004f7:	53                   	push   %ebx
  8004f8:	56                   	push   %esi
  8004f9:	e8 b3 fe ff ff       	call   8003b1 <printfmt>
  8004fe:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800501:	89 7d 14             	mov    %edi,0x14(%ebp)
  800504:	e9 9a 02 00 00       	jmp    8007a3 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  800509:	50                   	push   %eax
  80050a:	68 f3 29 80 00       	push   $0x8029f3
  80050f:	53                   	push   %ebx
  800510:	56                   	push   %esi
  800511:	e8 9b fe ff ff       	call   8003b1 <printfmt>
  800516:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800519:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80051c:	e9 82 02 00 00       	jmp    8007a3 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  800521:	8b 45 14             	mov    0x14(%ebp),%eax
  800524:	83 c0 04             	add    $0x4,%eax
  800527:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80052a:	8b 45 14             	mov    0x14(%ebp),%eax
  80052d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80052f:	85 ff                	test   %edi,%edi
  800531:	b8 ec 29 80 00       	mov    $0x8029ec,%eax
  800536:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800539:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80053d:	0f 8e bd 00 00 00    	jle    800600 <vprintfmt+0x232>
  800543:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800547:	75 0e                	jne    800557 <vprintfmt+0x189>
  800549:	89 75 08             	mov    %esi,0x8(%ebp)
  80054c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80054f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800552:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800555:	eb 6d                	jmp    8005c4 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  800557:	83 ec 08             	sub    $0x8,%esp
  80055a:	ff 75 d0             	pushl  -0x30(%ebp)
  80055d:	57                   	push   %edi
  80055e:	e8 6e 03 00 00       	call   8008d1 <strnlen>
  800563:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800566:	29 c1                	sub    %eax,%ecx
  800568:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80056b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80056e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800572:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800575:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800578:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  80057a:	eb 0f                	jmp    80058b <vprintfmt+0x1bd>
					putch(padc, putdat);
  80057c:	83 ec 08             	sub    $0x8,%esp
  80057f:	53                   	push   %ebx
  800580:	ff 75 e0             	pushl  -0x20(%ebp)
  800583:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800585:	83 ef 01             	sub    $0x1,%edi
  800588:	83 c4 10             	add    $0x10,%esp
  80058b:	85 ff                	test   %edi,%edi
  80058d:	7f ed                	jg     80057c <vprintfmt+0x1ae>
  80058f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800592:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800595:	85 c9                	test   %ecx,%ecx
  800597:	b8 00 00 00 00       	mov    $0x0,%eax
  80059c:	0f 49 c1             	cmovns %ecx,%eax
  80059f:	29 c1                	sub    %eax,%ecx
  8005a1:	89 75 08             	mov    %esi,0x8(%ebp)
  8005a4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005a7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005aa:	89 cb                	mov    %ecx,%ebx
  8005ac:	eb 16                	jmp    8005c4 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8005ae:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005b2:	75 31                	jne    8005e5 <vprintfmt+0x217>
					putch(ch, putdat);
  8005b4:	83 ec 08             	sub    $0x8,%esp
  8005b7:	ff 75 0c             	pushl  0xc(%ebp)
  8005ba:	50                   	push   %eax
  8005bb:	ff 55 08             	call   *0x8(%ebp)
  8005be:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c1:	83 eb 01             	sub    $0x1,%ebx
  8005c4:	83 c7 01             	add    $0x1,%edi
  8005c7:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8005cb:	0f be c2             	movsbl %dl,%eax
  8005ce:	85 c0                	test   %eax,%eax
  8005d0:	74 59                	je     80062b <vprintfmt+0x25d>
  8005d2:	85 f6                	test   %esi,%esi
  8005d4:	78 d8                	js     8005ae <vprintfmt+0x1e0>
  8005d6:	83 ee 01             	sub    $0x1,%esi
  8005d9:	79 d3                	jns    8005ae <vprintfmt+0x1e0>
  8005db:	89 df                	mov    %ebx,%edi
  8005dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8005e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005e3:	eb 37                	jmp    80061c <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8005e5:	0f be d2             	movsbl %dl,%edx
  8005e8:	83 ea 20             	sub    $0x20,%edx
  8005eb:	83 fa 5e             	cmp    $0x5e,%edx
  8005ee:	76 c4                	jbe    8005b4 <vprintfmt+0x1e6>
					putch('?', putdat);
  8005f0:	83 ec 08             	sub    $0x8,%esp
  8005f3:	ff 75 0c             	pushl  0xc(%ebp)
  8005f6:	6a 3f                	push   $0x3f
  8005f8:	ff 55 08             	call   *0x8(%ebp)
  8005fb:	83 c4 10             	add    $0x10,%esp
  8005fe:	eb c1                	jmp    8005c1 <vprintfmt+0x1f3>
  800600:	89 75 08             	mov    %esi,0x8(%ebp)
  800603:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800606:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800609:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80060c:	eb b6                	jmp    8005c4 <vprintfmt+0x1f6>
				putch(' ', putdat);
  80060e:	83 ec 08             	sub    $0x8,%esp
  800611:	53                   	push   %ebx
  800612:	6a 20                	push   $0x20
  800614:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800616:	83 ef 01             	sub    $0x1,%edi
  800619:	83 c4 10             	add    $0x10,%esp
  80061c:	85 ff                	test   %edi,%edi
  80061e:	7f ee                	jg     80060e <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800620:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800623:	89 45 14             	mov    %eax,0x14(%ebp)
  800626:	e9 78 01 00 00       	jmp    8007a3 <vprintfmt+0x3d5>
  80062b:	89 df                	mov    %ebx,%edi
  80062d:	8b 75 08             	mov    0x8(%ebp),%esi
  800630:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800633:	eb e7                	jmp    80061c <vprintfmt+0x24e>
	if (lflag >= 2)
  800635:	83 f9 01             	cmp    $0x1,%ecx
  800638:	7e 3f                	jle    800679 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  80063a:	8b 45 14             	mov    0x14(%ebp),%eax
  80063d:	8b 50 04             	mov    0x4(%eax),%edx
  800640:	8b 00                	mov    (%eax),%eax
  800642:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800645:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800648:	8b 45 14             	mov    0x14(%ebp),%eax
  80064b:	8d 40 08             	lea    0x8(%eax),%eax
  80064e:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800651:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800655:	79 5c                	jns    8006b3 <vprintfmt+0x2e5>
				putch('-', putdat);
  800657:	83 ec 08             	sub    $0x8,%esp
  80065a:	53                   	push   %ebx
  80065b:	6a 2d                	push   $0x2d
  80065d:	ff d6                	call   *%esi
				num = -(long long) num;
  80065f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800662:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800665:	f7 da                	neg    %edx
  800667:	83 d1 00             	adc    $0x0,%ecx
  80066a:	f7 d9                	neg    %ecx
  80066c:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80066f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800674:	e9 10 01 00 00       	jmp    800789 <vprintfmt+0x3bb>
	else if (lflag)
  800679:	85 c9                	test   %ecx,%ecx
  80067b:	75 1b                	jne    800698 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  80067d:	8b 45 14             	mov    0x14(%ebp),%eax
  800680:	8b 00                	mov    (%eax),%eax
  800682:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800685:	89 c1                	mov    %eax,%ecx
  800687:	c1 f9 1f             	sar    $0x1f,%ecx
  80068a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80068d:	8b 45 14             	mov    0x14(%ebp),%eax
  800690:	8d 40 04             	lea    0x4(%eax),%eax
  800693:	89 45 14             	mov    %eax,0x14(%ebp)
  800696:	eb b9                	jmp    800651 <vprintfmt+0x283>
		return va_arg(*ap, long);
  800698:	8b 45 14             	mov    0x14(%ebp),%eax
  80069b:	8b 00                	mov    (%eax),%eax
  80069d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006a0:	89 c1                	mov    %eax,%ecx
  8006a2:	c1 f9 1f             	sar    $0x1f,%ecx
  8006a5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ab:	8d 40 04             	lea    0x4(%eax),%eax
  8006ae:	89 45 14             	mov    %eax,0x14(%ebp)
  8006b1:	eb 9e                	jmp    800651 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8006b3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006b6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8006b9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006be:	e9 c6 00 00 00       	jmp    800789 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8006c3:	83 f9 01             	cmp    $0x1,%ecx
  8006c6:	7e 18                	jle    8006e0 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8006c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cb:	8b 10                	mov    (%eax),%edx
  8006cd:	8b 48 04             	mov    0x4(%eax),%ecx
  8006d0:	8d 40 08             	lea    0x8(%eax),%eax
  8006d3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006d6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006db:	e9 a9 00 00 00       	jmp    800789 <vprintfmt+0x3bb>
	else if (lflag)
  8006e0:	85 c9                	test   %ecx,%ecx
  8006e2:	75 1a                	jne    8006fe <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  8006e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e7:	8b 10                	mov    (%eax),%edx
  8006e9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ee:	8d 40 04             	lea    0x4(%eax),%eax
  8006f1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006f4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006f9:	e9 8b 00 00 00       	jmp    800789 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8006fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800701:	8b 10                	mov    (%eax),%edx
  800703:	b9 00 00 00 00       	mov    $0x0,%ecx
  800708:	8d 40 04             	lea    0x4(%eax),%eax
  80070b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80070e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800713:	eb 74                	jmp    800789 <vprintfmt+0x3bb>
	if (lflag >= 2)
  800715:	83 f9 01             	cmp    $0x1,%ecx
  800718:	7e 15                	jle    80072f <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  80071a:	8b 45 14             	mov    0x14(%ebp),%eax
  80071d:	8b 10                	mov    (%eax),%edx
  80071f:	8b 48 04             	mov    0x4(%eax),%ecx
  800722:	8d 40 08             	lea    0x8(%eax),%eax
  800725:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800728:	b8 08 00 00 00       	mov    $0x8,%eax
  80072d:	eb 5a                	jmp    800789 <vprintfmt+0x3bb>
	else if (lflag)
  80072f:	85 c9                	test   %ecx,%ecx
  800731:	75 17                	jne    80074a <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  800733:	8b 45 14             	mov    0x14(%ebp),%eax
  800736:	8b 10                	mov    (%eax),%edx
  800738:	b9 00 00 00 00       	mov    $0x0,%ecx
  80073d:	8d 40 04             	lea    0x4(%eax),%eax
  800740:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800743:	b8 08 00 00 00       	mov    $0x8,%eax
  800748:	eb 3f                	jmp    800789 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80074a:	8b 45 14             	mov    0x14(%ebp),%eax
  80074d:	8b 10                	mov    (%eax),%edx
  80074f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800754:	8d 40 04             	lea    0x4(%eax),%eax
  800757:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80075a:	b8 08 00 00 00       	mov    $0x8,%eax
  80075f:	eb 28                	jmp    800789 <vprintfmt+0x3bb>
			putch('0', putdat);
  800761:	83 ec 08             	sub    $0x8,%esp
  800764:	53                   	push   %ebx
  800765:	6a 30                	push   $0x30
  800767:	ff d6                	call   *%esi
			putch('x', putdat);
  800769:	83 c4 08             	add    $0x8,%esp
  80076c:	53                   	push   %ebx
  80076d:	6a 78                	push   $0x78
  80076f:	ff d6                	call   *%esi
			num = (unsigned long long)
  800771:	8b 45 14             	mov    0x14(%ebp),%eax
  800774:	8b 10                	mov    (%eax),%edx
  800776:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80077b:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80077e:	8d 40 04             	lea    0x4(%eax),%eax
  800781:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800784:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800789:	83 ec 0c             	sub    $0xc,%esp
  80078c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800790:	57                   	push   %edi
  800791:	ff 75 e0             	pushl  -0x20(%ebp)
  800794:	50                   	push   %eax
  800795:	51                   	push   %ecx
  800796:	52                   	push   %edx
  800797:	89 da                	mov    %ebx,%edx
  800799:	89 f0                	mov    %esi,%eax
  80079b:	e8 45 fb ff ff       	call   8002e5 <printnum>
			break;
  8007a0:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8007a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007a6:	83 c7 01             	add    $0x1,%edi
  8007a9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8007ad:	83 f8 25             	cmp    $0x25,%eax
  8007b0:	0f 84 2f fc ff ff    	je     8003e5 <vprintfmt+0x17>
			if (ch == '\0')
  8007b6:	85 c0                	test   %eax,%eax
  8007b8:	0f 84 8b 00 00 00    	je     800849 <vprintfmt+0x47b>
			putch(ch, putdat);
  8007be:	83 ec 08             	sub    $0x8,%esp
  8007c1:	53                   	push   %ebx
  8007c2:	50                   	push   %eax
  8007c3:	ff d6                	call   *%esi
  8007c5:	83 c4 10             	add    $0x10,%esp
  8007c8:	eb dc                	jmp    8007a6 <vprintfmt+0x3d8>
	if (lflag >= 2)
  8007ca:	83 f9 01             	cmp    $0x1,%ecx
  8007cd:	7e 15                	jle    8007e4 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  8007cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d2:	8b 10                	mov    (%eax),%edx
  8007d4:	8b 48 04             	mov    0x4(%eax),%ecx
  8007d7:	8d 40 08             	lea    0x8(%eax),%eax
  8007da:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007dd:	b8 10 00 00 00       	mov    $0x10,%eax
  8007e2:	eb a5                	jmp    800789 <vprintfmt+0x3bb>
	else if (lflag)
  8007e4:	85 c9                	test   %ecx,%ecx
  8007e6:	75 17                	jne    8007ff <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  8007e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007eb:	8b 10                	mov    (%eax),%edx
  8007ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007f2:	8d 40 04             	lea    0x4(%eax),%eax
  8007f5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007f8:	b8 10 00 00 00       	mov    $0x10,%eax
  8007fd:	eb 8a                	jmp    800789 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8007ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800802:	8b 10                	mov    (%eax),%edx
  800804:	b9 00 00 00 00       	mov    $0x0,%ecx
  800809:	8d 40 04             	lea    0x4(%eax),%eax
  80080c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80080f:	b8 10 00 00 00       	mov    $0x10,%eax
  800814:	e9 70 ff ff ff       	jmp    800789 <vprintfmt+0x3bb>
			putch(ch, putdat);
  800819:	83 ec 08             	sub    $0x8,%esp
  80081c:	53                   	push   %ebx
  80081d:	6a 25                	push   $0x25
  80081f:	ff d6                	call   *%esi
			break;
  800821:	83 c4 10             	add    $0x10,%esp
  800824:	e9 7a ff ff ff       	jmp    8007a3 <vprintfmt+0x3d5>
			putch('%', putdat);
  800829:	83 ec 08             	sub    $0x8,%esp
  80082c:	53                   	push   %ebx
  80082d:	6a 25                	push   $0x25
  80082f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800831:	83 c4 10             	add    $0x10,%esp
  800834:	89 f8                	mov    %edi,%eax
  800836:	eb 03                	jmp    80083b <vprintfmt+0x46d>
  800838:	83 e8 01             	sub    $0x1,%eax
  80083b:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80083f:	75 f7                	jne    800838 <vprintfmt+0x46a>
  800841:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800844:	e9 5a ff ff ff       	jmp    8007a3 <vprintfmt+0x3d5>
}
  800849:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80084c:	5b                   	pop    %ebx
  80084d:	5e                   	pop    %esi
  80084e:	5f                   	pop    %edi
  80084f:	5d                   	pop    %ebp
  800850:	c3                   	ret    

00800851 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	83 ec 18             	sub    $0x18,%esp
  800857:	8b 45 08             	mov    0x8(%ebp),%eax
  80085a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80085d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800860:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800864:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800867:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80086e:	85 c0                	test   %eax,%eax
  800870:	74 26                	je     800898 <vsnprintf+0x47>
  800872:	85 d2                	test   %edx,%edx
  800874:	7e 22                	jle    800898 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800876:	ff 75 14             	pushl  0x14(%ebp)
  800879:	ff 75 10             	pushl  0x10(%ebp)
  80087c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80087f:	50                   	push   %eax
  800880:	68 94 03 80 00       	push   $0x800394
  800885:	e8 44 fb ff ff       	call   8003ce <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80088a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80088d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800890:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800893:	83 c4 10             	add    $0x10,%esp
}
  800896:	c9                   	leave  
  800897:	c3                   	ret    
		return -E_INVAL;
  800898:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80089d:	eb f7                	jmp    800896 <vsnprintf+0x45>

0080089f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008a5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008a8:	50                   	push   %eax
  8008a9:	ff 75 10             	pushl  0x10(%ebp)
  8008ac:	ff 75 0c             	pushl  0xc(%ebp)
  8008af:	ff 75 08             	pushl  0x8(%ebp)
  8008b2:	e8 9a ff ff ff       	call   800851 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008b7:	c9                   	leave  
  8008b8:	c3                   	ret    

008008b9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c4:	eb 03                	jmp    8008c9 <strlen+0x10>
		n++;
  8008c6:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008c9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008cd:	75 f7                	jne    8008c6 <strlen+0xd>
	return n;
}
  8008cf:	5d                   	pop    %ebp
  8008d0:	c3                   	ret    

008008d1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008d1:	55                   	push   %ebp
  8008d2:	89 e5                	mov    %esp,%ebp
  8008d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d7:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008da:	b8 00 00 00 00       	mov    $0x0,%eax
  8008df:	eb 03                	jmp    8008e4 <strnlen+0x13>
		n++;
  8008e1:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008e4:	39 d0                	cmp    %edx,%eax
  8008e6:	74 06                	je     8008ee <strnlen+0x1d>
  8008e8:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008ec:	75 f3                	jne    8008e1 <strnlen+0x10>
	return n;
}
  8008ee:	5d                   	pop    %ebp
  8008ef:	c3                   	ret    

008008f0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
  8008f3:	53                   	push   %ebx
  8008f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008fa:	89 c2                	mov    %eax,%edx
  8008fc:	83 c1 01             	add    $0x1,%ecx
  8008ff:	83 c2 01             	add    $0x1,%edx
  800902:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800906:	88 5a ff             	mov    %bl,-0x1(%edx)
  800909:	84 db                	test   %bl,%bl
  80090b:	75 ef                	jne    8008fc <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80090d:	5b                   	pop    %ebx
  80090e:	5d                   	pop    %ebp
  80090f:	c3                   	ret    

00800910 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	53                   	push   %ebx
  800914:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800917:	53                   	push   %ebx
  800918:	e8 9c ff ff ff       	call   8008b9 <strlen>
  80091d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800920:	ff 75 0c             	pushl  0xc(%ebp)
  800923:	01 d8                	add    %ebx,%eax
  800925:	50                   	push   %eax
  800926:	e8 c5 ff ff ff       	call   8008f0 <strcpy>
	return dst;
}
  80092b:	89 d8                	mov    %ebx,%eax
  80092d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800930:	c9                   	leave  
  800931:	c3                   	ret    

00800932 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
  800935:	56                   	push   %esi
  800936:	53                   	push   %ebx
  800937:	8b 75 08             	mov    0x8(%ebp),%esi
  80093a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80093d:	89 f3                	mov    %esi,%ebx
  80093f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800942:	89 f2                	mov    %esi,%edx
  800944:	eb 0f                	jmp    800955 <strncpy+0x23>
		*dst++ = *src;
  800946:	83 c2 01             	add    $0x1,%edx
  800949:	0f b6 01             	movzbl (%ecx),%eax
  80094c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80094f:	80 39 01             	cmpb   $0x1,(%ecx)
  800952:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800955:	39 da                	cmp    %ebx,%edx
  800957:	75 ed                	jne    800946 <strncpy+0x14>
	}
	return ret;
}
  800959:	89 f0                	mov    %esi,%eax
  80095b:	5b                   	pop    %ebx
  80095c:	5e                   	pop    %esi
  80095d:	5d                   	pop    %ebp
  80095e:	c3                   	ret    

0080095f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	56                   	push   %esi
  800963:	53                   	push   %ebx
  800964:	8b 75 08             	mov    0x8(%ebp),%esi
  800967:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80096d:	89 f0                	mov    %esi,%eax
  80096f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800973:	85 c9                	test   %ecx,%ecx
  800975:	75 0b                	jne    800982 <strlcpy+0x23>
  800977:	eb 17                	jmp    800990 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800979:	83 c2 01             	add    $0x1,%edx
  80097c:	83 c0 01             	add    $0x1,%eax
  80097f:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800982:	39 d8                	cmp    %ebx,%eax
  800984:	74 07                	je     80098d <strlcpy+0x2e>
  800986:	0f b6 0a             	movzbl (%edx),%ecx
  800989:	84 c9                	test   %cl,%cl
  80098b:	75 ec                	jne    800979 <strlcpy+0x1a>
		*dst = '\0';
  80098d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800990:	29 f0                	sub    %esi,%eax
}
  800992:	5b                   	pop    %ebx
  800993:	5e                   	pop    %esi
  800994:	5d                   	pop    %ebp
  800995:	c3                   	ret    

00800996 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80099c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80099f:	eb 06                	jmp    8009a7 <strcmp+0x11>
		p++, q++;
  8009a1:	83 c1 01             	add    $0x1,%ecx
  8009a4:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009a7:	0f b6 01             	movzbl (%ecx),%eax
  8009aa:	84 c0                	test   %al,%al
  8009ac:	74 04                	je     8009b2 <strcmp+0x1c>
  8009ae:	3a 02                	cmp    (%edx),%al
  8009b0:	74 ef                	je     8009a1 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b2:	0f b6 c0             	movzbl %al,%eax
  8009b5:	0f b6 12             	movzbl (%edx),%edx
  8009b8:	29 d0                	sub    %edx,%eax
}
  8009ba:	5d                   	pop    %ebp
  8009bb:	c3                   	ret    

008009bc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	53                   	push   %ebx
  8009c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c6:	89 c3                	mov    %eax,%ebx
  8009c8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009cb:	eb 06                	jmp    8009d3 <strncmp+0x17>
		n--, p++, q++;
  8009cd:	83 c0 01             	add    $0x1,%eax
  8009d0:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009d3:	39 d8                	cmp    %ebx,%eax
  8009d5:	74 16                	je     8009ed <strncmp+0x31>
  8009d7:	0f b6 08             	movzbl (%eax),%ecx
  8009da:	84 c9                	test   %cl,%cl
  8009dc:	74 04                	je     8009e2 <strncmp+0x26>
  8009de:	3a 0a                	cmp    (%edx),%cl
  8009e0:	74 eb                	je     8009cd <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009e2:	0f b6 00             	movzbl (%eax),%eax
  8009e5:	0f b6 12             	movzbl (%edx),%edx
  8009e8:	29 d0                	sub    %edx,%eax
}
  8009ea:	5b                   	pop    %ebx
  8009eb:	5d                   	pop    %ebp
  8009ec:	c3                   	ret    
		return 0;
  8009ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f2:	eb f6                	jmp    8009ea <strncmp+0x2e>

008009f4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009f4:	55                   	push   %ebp
  8009f5:	89 e5                	mov    %esp,%ebp
  8009f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fa:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009fe:	0f b6 10             	movzbl (%eax),%edx
  800a01:	84 d2                	test   %dl,%dl
  800a03:	74 09                	je     800a0e <strchr+0x1a>
		if (*s == c)
  800a05:	38 ca                	cmp    %cl,%dl
  800a07:	74 0a                	je     800a13 <strchr+0x1f>
	for (; *s; s++)
  800a09:	83 c0 01             	add    $0x1,%eax
  800a0c:	eb f0                	jmp    8009fe <strchr+0xa>
			return (char *) s;
	return 0;
  800a0e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a13:	5d                   	pop    %ebp
  800a14:	c3                   	ret    

00800a15 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a1f:	eb 03                	jmp    800a24 <strfind+0xf>
  800a21:	83 c0 01             	add    $0x1,%eax
  800a24:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a27:	38 ca                	cmp    %cl,%dl
  800a29:	74 04                	je     800a2f <strfind+0x1a>
  800a2b:	84 d2                	test   %dl,%dl
  800a2d:	75 f2                	jne    800a21 <strfind+0xc>
			break;
	return (char *) s;
}
  800a2f:	5d                   	pop    %ebp
  800a30:	c3                   	ret    

00800a31 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a31:	55                   	push   %ebp
  800a32:	89 e5                	mov    %esp,%ebp
  800a34:	57                   	push   %edi
  800a35:	56                   	push   %esi
  800a36:	53                   	push   %ebx
  800a37:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a3a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a3d:	85 c9                	test   %ecx,%ecx
  800a3f:	74 13                	je     800a54 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a41:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a47:	75 05                	jne    800a4e <memset+0x1d>
  800a49:	f6 c1 03             	test   $0x3,%cl
  800a4c:	74 0d                	je     800a5b <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a51:	fc                   	cld    
  800a52:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a54:	89 f8                	mov    %edi,%eax
  800a56:	5b                   	pop    %ebx
  800a57:	5e                   	pop    %esi
  800a58:	5f                   	pop    %edi
  800a59:	5d                   	pop    %ebp
  800a5a:	c3                   	ret    
		c &= 0xFF;
  800a5b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a5f:	89 d3                	mov    %edx,%ebx
  800a61:	c1 e3 08             	shl    $0x8,%ebx
  800a64:	89 d0                	mov    %edx,%eax
  800a66:	c1 e0 18             	shl    $0x18,%eax
  800a69:	89 d6                	mov    %edx,%esi
  800a6b:	c1 e6 10             	shl    $0x10,%esi
  800a6e:	09 f0                	or     %esi,%eax
  800a70:	09 c2                	or     %eax,%edx
  800a72:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800a74:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a77:	89 d0                	mov    %edx,%eax
  800a79:	fc                   	cld    
  800a7a:	f3 ab                	rep stos %eax,%es:(%edi)
  800a7c:	eb d6                	jmp    800a54 <memset+0x23>

00800a7e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	57                   	push   %edi
  800a82:	56                   	push   %esi
  800a83:	8b 45 08             	mov    0x8(%ebp),%eax
  800a86:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a89:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a8c:	39 c6                	cmp    %eax,%esi
  800a8e:	73 35                	jae    800ac5 <memmove+0x47>
  800a90:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a93:	39 c2                	cmp    %eax,%edx
  800a95:	76 2e                	jbe    800ac5 <memmove+0x47>
		s += n;
		d += n;
  800a97:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a9a:	89 d6                	mov    %edx,%esi
  800a9c:	09 fe                	or     %edi,%esi
  800a9e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aa4:	74 0c                	je     800ab2 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800aa6:	83 ef 01             	sub    $0x1,%edi
  800aa9:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800aac:	fd                   	std    
  800aad:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aaf:	fc                   	cld    
  800ab0:	eb 21                	jmp    800ad3 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab2:	f6 c1 03             	test   $0x3,%cl
  800ab5:	75 ef                	jne    800aa6 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ab7:	83 ef 04             	sub    $0x4,%edi
  800aba:	8d 72 fc             	lea    -0x4(%edx),%esi
  800abd:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800ac0:	fd                   	std    
  800ac1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ac3:	eb ea                	jmp    800aaf <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac5:	89 f2                	mov    %esi,%edx
  800ac7:	09 c2                	or     %eax,%edx
  800ac9:	f6 c2 03             	test   $0x3,%dl
  800acc:	74 09                	je     800ad7 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ace:	89 c7                	mov    %eax,%edi
  800ad0:	fc                   	cld    
  800ad1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ad3:	5e                   	pop    %esi
  800ad4:	5f                   	pop    %edi
  800ad5:	5d                   	pop    %ebp
  800ad6:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad7:	f6 c1 03             	test   $0x3,%cl
  800ada:	75 f2                	jne    800ace <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800adc:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800adf:	89 c7                	mov    %eax,%edi
  800ae1:	fc                   	cld    
  800ae2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ae4:	eb ed                	jmp    800ad3 <memmove+0x55>

00800ae6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ae9:	ff 75 10             	pushl  0x10(%ebp)
  800aec:	ff 75 0c             	pushl  0xc(%ebp)
  800aef:	ff 75 08             	pushl  0x8(%ebp)
  800af2:	e8 87 ff ff ff       	call   800a7e <memmove>
}
  800af7:	c9                   	leave  
  800af8:	c3                   	ret    

00800af9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800af9:	55                   	push   %ebp
  800afa:	89 e5                	mov    %esp,%ebp
  800afc:	56                   	push   %esi
  800afd:	53                   	push   %ebx
  800afe:	8b 45 08             	mov    0x8(%ebp),%eax
  800b01:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b04:	89 c6                	mov    %eax,%esi
  800b06:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b09:	39 f0                	cmp    %esi,%eax
  800b0b:	74 1c                	je     800b29 <memcmp+0x30>
		if (*s1 != *s2)
  800b0d:	0f b6 08             	movzbl (%eax),%ecx
  800b10:	0f b6 1a             	movzbl (%edx),%ebx
  800b13:	38 d9                	cmp    %bl,%cl
  800b15:	75 08                	jne    800b1f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b17:	83 c0 01             	add    $0x1,%eax
  800b1a:	83 c2 01             	add    $0x1,%edx
  800b1d:	eb ea                	jmp    800b09 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b1f:	0f b6 c1             	movzbl %cl,%eax
  800b22:	0f b6 db             	movzbl %bl,%ebx
  800b25:	29 d8                	sub    %ebx,%eax
  800b27:	eb 05                	jmp    800b2e <memcmp+0x35>
	}

	return 0;
  800b29:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b2e:	5b                   	pop    %ebx
  800b2f:	5e                   	pop    %esi
  800b30:	5d                   	pop    %ebp
  800b31:	c3                   	ret    

00800b32 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b32:	55                   	push   %ebp
  800b33:	89 e5                	mov    %esp,%ebp
  800b35:	8b 45 08             	mov    0x8(%ebp),%eax
  800b38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b3b:	89 c2                	mov    %eax,%edx
  800b3d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b40:	39 d0                	cmp    %edx,%eax
  800b42:	73 09                	jae    800b4d <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b44:	38 08                	cmp    %cl,(%eax)
  800b46:	74 05                	je     800b4d <memfind+0x1b>
	for (; s < ends; s++)
  800b48:	83 c0 01             	add    $0x1,%eax
  800b4b:	eb f3                	jmp    800b40 <memfind+0xe>
			break;
	return (void *) s;
}
  800b4d:	5d                   	pop    %ebp
  800b4e:	c3                   	ret    

00800b4f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b4f:	55                   	push   %ebp
  800b50:	89 e5                	mov    %esp,%ebp
  800b52:	57                   	push   %edi
  800b53:	56                   	push   %esi
  800b54:	53                   	push   %ebx
  800b55:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b58:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b5b:	eb 03                	jmp    800b60 <strtol+0x11>
		s++;
  800b5d:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b60:	0f b6 01             	movzbl (%ecx),%eax
  800b63:	3c 20                	cmp    $0x20,%al
  800b65:	74 f6                	je     800b5d <strtol+0xe>
  800b67:	3c 09                	cmp    $0x9,%al
  800b69:	74 f2                	je     800b5d <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b6b:	3c 2b                	cmp    $0x2b,%al
  800b6d:	74 2e                	je     800b9d <strtol+0x4e>
	int neg = 0;
  800b6f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b74:	3c 2d                	cmp    $0x2d,%al
  800b76:	74 2f                	je     800ba7 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b78:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b7e:	75 05                	jne    800b85 <strtol+0x36>
  800b80:	80 39 30             	cmpb   $0x30,(%ecx)
  800b83:	74 2c                	je     800bb1 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b85:	85 db                	test   %ebx,%ebx
  800b87:	75 0a                	jne    800b93 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b89:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800b8e:	80 39 30             	cmpb   $0x30,(%ecx)
  800b91:	74 28                	je     800bbb <strtol+0x6c>
		base = 10;
  800b93:	b8 00 00 00 00       	mov    $0x0,%eax
  800b98:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b9b:	eb 50                	jmp    800bed <strtol+0x9e>
		s++;
  800b9d:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800ba0:	bf 00 00 00 00       	mov    $0x0,%edi
  800ba5:	eb d1                	jmp    800b78 <strtol+0x29>
		s++, neg = 1;
  800ba7:	83 c1 01             	add    $0x1,%ecx
  800baa:	bf 01 00 00 00       	mov    $0x1,%edi
  800baf:	eb c7                	jmp    800b78 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bb1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bb5:	74 0e                	je     800bc5 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800bb7:	85 db                	test   %ebx,%ebx
  800bb9:	75 d8                	jne    800b93 <strtol+0x44>
		s++, base = 8;
  800bbb:	83 c1 01             	add    $0x1,%ecx
  800bbe:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bc3:	eb ce                	jmp    800b93 <strtol+0x44>
		s += 2, base = 16;
  800bc5:	83 c1 02             	add    $0x2,%ecx
  800bc8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bcd:	eb c4                	jmp    800b93 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800bcf:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bd2:	89 f3                	mov    %esi,%ebx
  800bd4:	80 fb 19             	cmp    $0x19,%bl
  800bd7:	77 29                	ja     800c02 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800bd9:	0f be d2             	movsbl %dl,%edx
  800bdc:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bdf:	3b 55 10             	cmp    0x10(%ebp),%edx
  800be2:	7d 30                	jge    800c14 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800be4:	83 c1 01             	add    $0x1,%ecx
  800be7:	0f af 45 10          	imul   0x10(%ebp),%eax
  800beb:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800bed:	0f b6 11             	movzbl (%ecx),%edx
  800bf0:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bf3:	89 f3                	mov    %esi,%ebx
  800bf5:	80 fb 09             	cmp    $0x9,%bl
  800bf8:	77 d5                	ja     800bcf <strtol+0x80>
			dig = *s - '0';
  800bfa:	0f be d2             	movsbl %dl,%edx
  800bfd:	83 ea 30             	sub    $0x30,%edx
  800c00:	eb dd                	jmp    800bdf <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800c02:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c05:	89 f3                	mov    %esi,%ebx
  800c07:	80 fb 19             	cmp    $0x19,%bl
  800c0a:	77 08                	ja     800c14 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c0c:	0f be d2             	movsbl %dl,%edx
  800c0f:	83 ea 37             	sub    $0x37,%edx
  800c12:	eb cb                	jmp    800bdf <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c14:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c18:	74 05                	je     800c1f <strtol+0xd0>
		*endptr = (char *) s;
  800c1a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c1d:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c1f:	89 c2                	mov    %eax,%edx
  800c21:	f7 da                	neg    %edx
  800c23:	85 ff                	test   %edi,%edi
  800c25:	0f 45 c2             	cmovne %edx,%eax
}
  800c28:	5b                   	pop    %ebx
  800c29:	5e                   	pop    %esi
  800c2a:	5f                   	pop    %edi
  800c2b:	5d                   	pop    %ebp
  800c2c:	c3                   	ret    

00800c2d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c2d:	55                   	push   %ebp
  800c2e:	89 e5                	mov    %esp,%ebp
  800c30:	57                   	push   %edi
  800c31:	56                   	push   %esi
  800c32:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c33:	b8 00 00 00 00       	mov    $0x0,%eax
  800c38:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3e:	89 c3                	mov    %eax,%ebx
  800c40:	89 c7                	mov    %eax,%edi
  800c42:	89 c6                	mov    %eax,%esi
  800c44:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c46:	5b                   	pop    %ebx
  800c47:	5e                   	pop    %esi
  800c48:	5f                   	pop    %edi
  800c49:	5d                   	pop    %ebp
  800c4a:	c3                   	ret    

00800c4b <sys_cgetc>:

int
sys_cgetc(void)
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	57                   	push   %edi
  800c4f:	56                   	push   %esi
  800c50:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c51:	ba 00 00 00 00       	mov    $0x0,%edx
  800c56:	b8 01 00 00 00       	mov    $0x1,%eax
  800c5b:	89 d1                	mov    %edx,%ecx
  800c5d:	89 d3                	mov    %edx,%ebx
  800c5f:	89 d7                	mov    %edx,%edi
  800c61:	89 d6                	mov    %edx,%esi
  800c63:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c65:	5b                   	pop    %ebx
  800c66:	5e                   	pop    %esi
  800c67:	5f                   	pop    %edi
  800c68:	5d                   	pop    %ebp
  800c69:	c3                   	ret    

00800c6a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c6a:	55                   	push   %ebp
  800c6b:	89 e5                	mov    %esp,%ebp
  800c6d:	57                   	push   %edi
  800c6e:	56                   	push   %esi
  800c6f:	53                   	push   %ebx
  800c70:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c73:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c78:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7b:	b8 03 00 00 00       	mov    $0x3,%eax
  800c80:	89 cb                	mov    %ecx,%ebx
  800c82:	89 cf                	mov    %ecx,%edi
  800c84:	89 ce                	mov    %ecx,%esi
  800c86:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c88:	85 c0                	test   %eax,%eax
  800c8a:	7f 08                	jg     800c94 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8f:	5b                   	pop    %ebx
  800c90:	5e                   	pop    %esi
  800c91:	5f                   	pop    %edi
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c94:	83 ec 0c             	sub    $0xc,%esp
  800c97:	50                   	push   %eax
  800c98:	6a 03                	push   $0x3
  800c9a:	68 df 2c 80 00       	push   $0x802cdf
  800c9f:	6a 23                	push   $0x23
  800ca1:	68 fc 2c 80 00       	push   $0x802cfc
  800ca6:	e8 4b f5 ff ff       	call   8001f6 <_panic>

00800cab <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cab:	55                   	push   %ebp
  800cac:	89 e5                	mov    %esp,%ebp
  800cae:	57                   	push   %edi
  800caf:	56                   	push   %esi
  800cb0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cb1:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb6:	b8 02 00 00 00       	mov    $0x2,%eax
  800cbb:	89 d1                	mov    %edx,%ecx
  800cbd:	89 d3                	mov    %edx,%ebx
  800cbf:	89 d7                	mov    %edx,%edi
  800cc1:	89 d6                	mov    %edx,%esi
  800cc3:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cc5:	5b                   	pop    %ebx
  800cc6:	5e                   	pop    %esi
  800cc7:	5f                   	pop    %edi
  800cc8:	5d                   	pop    %ebp
  800cc9:	c3                   	ret    

00800cca <sys_yield>:

void
sys_yield(void)
{
  800cca:	55                   	push   %ebp
  800ccb:	89 e5                	mov    %esp,%ebp
  800ccd:	57                   	push   %edi
  800cce:	56                   	push   %esi
  800ccf:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cd0:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cda:	89 d1                	mov    %edx,%ecx
  800cdc:	89 d3                	mov    %edx,%ebx
  800cde:	89 d7                	mov    %edx,%edi
  800ce0:	89 d6                	mov    %edx,%esi
  800ce2:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ce4:	5b                   	pop    %ebx
  800ce5:	5e                   	pop    %esi
  800ce6:	5f                   	pop    %edi
  800ce7:	5d                   	pop    %ebp
  800ce8:	c3                   	ret    

00800ce9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ce9:	55                   	push   %ebp
  800cea:	89 e5                	mov    %esp,%ebp
  800cec:	57                   	push   %edi
  800ced:	56                   	push   %esi
  800cee:	53                   	push   %ebx
  800cef:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cf2:	be 00 00 00 00       	mov    $0x0,%esi
  800cf7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfd:	b8 04 00 00 00       	mov    $0x4,%eax
  800d02:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d05:	89 f7                	mov    %esi,%edi
  800d07:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d09:	85 c0                	test   %eax,%eax
  800d0b:	7f 08                	jg     800d15 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d10:	5b                   	pop    %ebx
  800d11:	5e                   	pop    %esi
  800d12:	5f                   	pop    %edi
  800d13:	5d                   	pop    %ebp
  800d14:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d15:	83 ec 0c             	sub    $0xc,%esp
  800d18:	50                   	push   %eax
  800d19:	6a 04                	push   $0x4
  800d1b:	68 df 2c 80 00       	push   $0x802cdf
  800d20:	6a 23                	push   $0x23
  800d22:	68 fc 2c 80 00       	push   $0x802cfc
  800d27:	e8 ca f4 ff ff       	call   8001f6 <_panic>

00800d2c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d2c:	55                   	push   %ebp
  800d2d:	89 e5                	mov    %esp,%ebp
  800d2f:	57                   	push   %edi
  800d30:	56                   	push   %esi
  800d31:	53                   	push   %ebx
  800d32:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d35:	8b 55 08             	mov    0x8(%ebp),%edx
  800d38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3b:	b8 05 00 00 00       	mov    $0x5,%eax
  800d40:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d43:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d46:	8b 75 18             	mov    0x18(%ebp),%esi
  800d49:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d4b:	85 c0                	test   %eax,%eax
  800d4d:	7f 08                	jg     800d57 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d52:	5b                   	pop    %ebx
  800d53:	5e                   	pop    %esi
  800d54:	5f                   	pop    %edi
  800d55:	5d                   	pop    %ebp
  800d56:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d57:	83 ec 0c             	sub    $0xc,%esp
  800d5a:	50                   	push   %eax
  800d5b:	6a 05                	push   $0x5
  800d5d:	68 df 2c 80 00       	push   $0x802cdf
  800d62:	6a 23                	push   $0x23
  800d64:	68 fc 2c 80 00       	push   $0x802cfc
  800d69:	e8 88 f4 ff ff       	call   8001f6 <_panic>

00800d6e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d6e:	55                   	push   %ebp
  800d6f:	89 e5                	mov    %esp,%ebp
  800d71:	57                   	push   %edi
  800d72:	56                   	push   %esi
  800d73:	53                   	push   %ebx
  800d74:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d77:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d82:	b8 06 00 00 00       	mov    $0x6,%eax
  800d87:	89 df                	mov    %ebx,%edi
  800d89:	89 de                	mov    %ebx,%esi
  800d8b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d8d:	85 c0                	test   %eax,%eax
  800d8f:	7f 08                	jg     800d99 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d94:	5b                   	pop    %ebx
  800d95:	5e                   	pop    %esi
  800d96:	5f                   	pop    %edi
  800d97:	5d                   	pop    %ebp
  800d98:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d99:	83 ec 0c             	sub    $0xc,%esp
  800d9c:	50                   	push   %eax
  800d9d:	6a 06                	push   $0x6
  800d9f:	68 df 2c 80 00       	push   $0x802cdf
  800da4:	6a 23                	push   $0x23
  800da6:	68 fc 2c 80 00       	push   $0x802cfc
  800dab:	e8 46 f4 ff ff       	call   8001f6 <_panic>

00800db0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800db0:	55                   	push   %ebp
  800db1:	89 e5                	mov    %esp,%ebp
  800db3:	57                   	push   %edi
  800db4:	56                   	push   %esi
  800db5:	53                   	push   %ebx
  800db6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800db9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc4:	b8 08 00 00 00       	mov    $0x8,%eax
  800dc9:	89 df                	mov    %ebx,%edi
  800dcb:	89 de                	mov    %ebx,%esi
  800dcd:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dcf:	85 c0                	test   %eax,%eax
  800dd1:	7f 08                	jg     800ddb <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dd3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd6:	5b                   	pop    %ebx
  800dd7:	5e                   	pop    %esi
  800dd8:	5f                   	pop    %edi
  800dd9:	5d                   	pop    %ebp
  800dda:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ddb:	83 ec 0c             	sub    $0xc,%esp
  800dde:	50                   	push   %eax
  800ddf:	6a 08                	push   $0x8
  800de1:	68 df 2c 80 00       	push   $0x802cdf
  800de6:	6a 23                	push   $0x23
  800de8:	68 fc 2c 80 00       	push   $0x802cfc
  800ded:	e8 04 f4 ff ff       	call   8001f6 <_panic>

00800df2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800df2:	55                   	push   %ebp
  800df3:	89 e5                	mov    %esp,%ebp
  800df5:	57                   	push   %edi
  800df6:	56                   	push   %esi
  800df7:	53                   	push   %ebx
  800df8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dfb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e00:	8b 55 08             	mov    0x8(%ebp),%edx
  800e03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e06:	b8 09 00 00 00       	mov    $0x9,%eax
  800e0b:	89 df                	mov    %ebx,%edi
  800e0d:	89 de                	mov    %ebx,%esi
  800e0f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e11:	85 c0                	test   %eax,%eax
  800e13:	7f 08                	jg     800e1d <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e18:	5b                   	pop    %ebx
  800e19:	5e                   	pop    %esi
  800e1a:	5f                   	pop    %edi
  800e1b:	5d                   	pop    %ebp
  800e1c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e1d:	83 ec 0c             	sub    $0xc,%esp
  800e20:	50                   	push   %eax
  800e21:	6a 09                	push   $0x9
  800e23:	68 df 2c 80 00       	push   $0x802cdf
  800e28:	6a 23                	push   $0x23
  800e2a:	68 fc 2c 80 00       	push   $0x802cfc
  800e2f:	e8 c2 f3 ff ff       	call   8001f6 <_panic>

00800e34 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e34:	55                   	push   %ebp
  800e35:	89 e5                	mov    %esp,%ebp
  800e37:	57                   	push   %edi
  800e38:	56                   	push   %esi
  800e39:	53                   	push   %ebx
  800e3a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e3d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e42:	8b 55 08             	mov    0x8(%ebp),%edx
  800e45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e48:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e4d:	89 df                	mov    %ebx,%edi
  800e4f:	89 de                	mov    %ebx,%esi
  800e51:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e53:	85 c0                	test   %eax,%eax
  800e55:	7f 08                	jg     800e5f <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e5a:	5b                   	pop    %ebx
  800e5b:	5e                   	pop    %esi
  800e5c:	5f                   	pop    %edi
  800e5d:	5d                   	pop    %ebp
  800e5e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e5f:	83 ec 0c             	sub    $0xc,%esp
  800e62:	50                   	push   %eax
  800e63:	6a 0a                	push   $0xa
  800e65:	68 df 2c 80 00       	push   $0x802cdf
  800e6a:	6a 23                	push   $0x23
  800e6c:	68 fc 2c 80 00       	push   $0x802cfc
  800e71:	e8 80 f3 ff ff       	call   8001f6 <_panic>

00800e76 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e76:	55                   	push   %ebp
  800e77:	89 e5                	mov    %esp,%ebp
  800e79:	57                   	push   %edi
  800e7a:	56                   	push   %esi
  800e7b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e82:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e87:	be 00 00 00 00       	mov    $0x0,%esi
  800e8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e8f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e92:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e94:	5b                   	pop    %ebx
  800e95:	5e                   	pop    %esi
  800e96:	5f                   	pop    %edi
  800e97:	5d                   	pop    %ebp
  800e98:	c3                   	ret    

00800e99 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e99:	55                   	push   %ebp
  800e9a:	89 e5                	mov    %esp,%ebp
  800e9c:	57                   	push   %edi
  800e9d:	56                   	push   %esi
  800e9e:	53                   	push   %ebx
  800e9f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ea2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ea7:	8b 55 08             	mov    0x8(%ebp),%edx
  800eaa:	b8 0d 00 00 00       	mov    $0xd,%eax
  800eaf:	89 cb                	mov    %ecx,%ebx
  800eb1:	89 cf                	mov    %ecx,%edi
  800eb3:	89 ce                	mov    %ecx,%esi
  800eb5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800eb7:	85 c0                	test   %eax,%eax
  800eb9:	7f 08                	jg     800ec3 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ebb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ebe:	5b                   	pop    %ebx
  800ebf:	5e                   	pop    %esi
  800ec0:	5f                   	pop    %edi
  800ec1:	5d                   	pop    %ebp
  800ec2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec3:	83 ec 0c             	sub    $0xc,%esp
  800ec6:	50                   	push   %eax
  800ec7:	6a 0d                	push   $0xd
  800ec9:	68 df 2c 80 00       	push   $0x802cdf
  800ece:	6a 23                	push   $0x23
  800ed0:	68 fc 2c 80 00       	push   $0x802cfc
  800ed5:	e8 1c f3 ff ff       	call   8001f6 <_panic>

00800eda <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800eda:	55                   	push   %ebp
  800edb:	89 e5                	mov    %esp,%ebp
  800edd:	56                   	push   %esi
  800ede:	53                   	push   %ebx
  800edf:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ee2:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if((err&FEC_WR)==0 || (uvpt[PGNUM(addr)]&(PTE_W|PTE_COW))==0){
  800ee4:	8b 40 04             	mov    0x4(%eax),%eax
  800ee7:	83 e0 02             	and    $0x2,%eax
  800eea:	0f 84 82 00 00 00    	je     800f72 <pgfault+0x98>
  800ef0:	89 da                	mov    %ebx,%edx
  800ef2:	c1 ea 0c             	shr    $0xc,%edx
  800ef5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800efc:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800f02:	74 6e                	je     800f72 <pgfault+0x98>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        envid_t envid = sys_getenvid();
  800f04:	e8 a2 fd ff ff       	call   800cab <sys_getenvid>
  800f09:	89 c6                	mov    %eax,%esi
	r = sys_page_alloc(envid,(void *)PFTEMP,PTE_P|PTE_W|PTE_U);
  800f0b:	83 ec 04             	sub    $0x4,%esp
  800f0e:	6a 07                	push   $0x7
  800f10:	68 00 f0 7f 00       	push   $0x7ff000
  800f15:	50                   	push   %eax
  800f16:	e8 ce fd ff ff       	call   800ce9 <sys_page_alloc>
	if(r<0) panic("pgfault:page allocation failed %e",r);
  800f1b:	83 c4 10             	add    $0x10,%esp
  800f1e:	85 c0                	test   %eax,%eax
  800f20:	78 72                	js     800f94 <pgfault+0xba>

	addr = ROUNDDOWN(addr,PGSIZE);
  800f22:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy((void *)PFTEMP,(const void *)addr,PGSIZE);
  800f28:	83 ec 04             	sub    $0x4,%esp
  800f2b:	68 00 10 00 00       	push   $0x1000
  800f30:	53                   	push   %ebx
  800f31:	68 00 f0 7f 00       	push   $0x7ff000
  800f36:	e8 ab fb ff ff       	call   800ae6 <memcpy>

	if(sys_page_map(envid,(void *)PFTEMP, envid,addr,PTE_P|PTE_W|PTE_U)<0)
  800f3b:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f42:	53                   	push   %ebx
  800f43:	56                   	push   %esi
  800f44:	68 00 f0 7f 00       	push   $0x7ff000
  800f49:	56                   	push   %esi
  800f4a:	e8 dd fd ff ff       	call   800d2c <sys_page_map>
  800f4f:	83 c4 20             	add    $0x20,%esp
  800f52:	85 c0                	test   %eax,%eax
  800f54:	78 50                	js     800fa6 <pgfault+0xcc>
		panic("pgfault:page map failed\n");
	if(sys_page_unmap(envid,(void *)PFTEMP)<0)
  800f56:	83 ec 08             	sub    $0x8,%esp
  800f59:	68 00 f0 7f 00       	push   $0x7ff000
  800f5e:	56                   	push   %esi
  800f5f:	e8 0a fe ff ff       	call   800d6e <sys_page_unmap>
  800f64:	83 c4 10             	add    $0x10,%esp
  800f67:	85 c0                	test   %eax,%eax
  800f69:	78 4f                	js     800fba <pgfault+0xe0>
		panic("pgfault: page upmap failed\n");
       //	panic("pgfault not implemented");
}
  800f6b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f6e:	5b                   	pop    %ebx
  800f6f:	5e                   	pop    %esi
  800f70:	5d                   	pop    %ebp
  800f71:	c3                   	ret    
		cprintf("Where is the error %d\n",err&FEC_WR);
  800f72:	83 ec 08             	sub    $0x8,%esp
  800f75:	50                   	push   %eax
  800f76:	68 0a 2d 80 00       	push   $0x802d0a
  800f7b:	e8 51 f3 ff ff       	call   8002d1 <cprintf>
		panic("pgfault:invalid user trap");
  800f80:	83 c4 0c             	add    $0xc,%esp
  800f83:	68 21 2d 80 00       	push   $0x802d21
  800f88:	6a 1e                	push   $0x1e
  800f8a:	68 3b 2d 80 00       	push   $0x802d3b
  800f8f:	e8 62 f2 ff ff       	call   8001f6 <_panic>
	if(r<0) panic("pgfault:page allocation failed %e",r);
  800f94:	50                   	push   %eax
  800f95:	68 28 2e 80 00       	push   $0x802e28
  800f9a:	6a 29                	push   $0x29
  800f9c:	68 3b 2d 80 00       	push   $0x802d3b
  800fa1:	e8 50 f2 ff ff       	call   8001f6 <_panic>
		panic("pgfault:page map failed\n");
  800fa6:	83 ec 04             	sub    $0x4,%esp
  800fa9:	68 46 2d 80 00       	push   $0x802d46
  800fae:	6a 2f                	push   $0x2f
  800fb0:	68 3b 2d 80 00       	push   $0x802d3b
  800fb5:	e8 3c f2 ff ff       	call   8001f6 <_panic>
		panic("pgfault: page upmap failed\n");
  800fba:	83 ec 04             	sub    $0x4,%esp
  800fbd:	68 5f 2d 80 00       	push   $0x802d5f
  800fc2:	6a 31                	push   $0x31
  800fc4:	68 3b 2d 80 00       	push   $0x802d3b
  800fc9:	e8 28 f2 ff ff       	call   8001f6 <_panic>

00800fce <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fce:	55                   	push   %ebp
  800fcf:	89 e5                	mov    %esp,%ebp
  800fd1:	57                   	push   %edi
  800fd2:	56                   	push   %esi
  800fd3:	53                   	push   %ebx
  800fd4:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	set_pgfault_handler(pgfault);
  800fd7:	68 da 0e 80 00       	push   $0x800eda
  800fdc:	e8 07 15 00 00       	call   8024e8 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fe1:	b8 07 00 00 00       	mov    $0x7,%eax
  800fe6:	cd 30                	int    $0x30
  800fe8:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800feb:	89 45 e0             	mov    %eax,-0x20(%ebp)
       
	envid_t envid = sys_exofork();
	uintptr_t addr;
  
	if(envid<0) panic("sys_exofork failed\n");
  800fee:	83 c4 10             	add    $0x10,%esp
  800ff1:	85 c0                	test   %eax,%eax
  800ff3:	78 27                	js     80101c <fork+0x4e>
	if(envid==0){
	  thisenv = &envs[ENVX(sys_getenvid())];
	  return 0;
	}

	for(addr=(uintptr_t)UTEXT; addr<USTACKTOP;addr+=PGSIZE){
  800ff5:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if(envid==0){
  800ffa:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800ffe:	75 5e                	jne    80105e <fork+0x90>
	  thisenv = &envs[ENVX(sys_getenvid())];
  801000:	e8 a6 fc ff ff       	call   800cab <sys_getenvid>
  801005:	25 ff 03 00 00       	and    $0x3ff,%eax
  80100a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80100d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801012:	a3 04 50 80 00       	mov    %eax,0x805004
	  return 0;
  801017:	e9 fc 00 00 00       	jmp    801118 <fork+0x14a>
	if(envid<0) panic("sys_exofork failed\n");
  80101c:	83 ec 04             	sub    $0x4,%esp
  80101f:	68 7b 2d 80 00       	push   $0x802d7b
  801024:	6a 77                	push   $0x77
  801026:	68 3b 2d 80 00       	push   $0x802d3b
  80102b:	e8 c6 f1 ff ff       	call   8001f6 <_panic>
          if((r=sys_page_map(parent_envid,va,envid,va,uvpt[pn]&PTE_SYSCALL))<0)
  801030:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801037:	83 ec 0c             	sub    $0xc,%esp
  80103a:	25 07 0e 00 00       	and    $0xe07,%eax
  80103f:	50                   	push   %eax
  801040:	57                   	push   %edi
  801041:	ff 75 e0             	pushl  -0x20(%ebp)
  801044:	57                   	push   %edi
  801045:	ff 75 e4             	pushl  -0x1c(%ebp)
  801048:	e8 df fc ff ff       	call   800d2c <sys_page_map>
  80104d:	83 c4 20             	add    $0x20,%esp
	for(addr=(uintptr_t)UTEXT; addr<USTACKTOP;addr+=PGSIZE){
  801050:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801056:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80105c:	74 76                	je     8010d4 <fork+0x106>
	   if((uvpd[PDX(addr)]&PTE_P) && uvpt[PGNUM(addr)] & PTE_P)
  80105e:	89 d8                	mov    %ebx,%eax
  801060:	c1 e8 16             	shr    $0x16,%eax
  801063:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80106a:	a8 01                	test   $0x1,%al
  80106c:	74 e2                	je     801050 <fork+0x82>
  80106e:	89 de                	mov    %ebx,%esi
  801070:	c1 ee 0c             	shr    $0xc,%esi
  801073:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80107a:	a8 01                	test   $0x1,%al
  80107c:	74 d2                	je     801050 <fork+0x82>
        envid_t parent_envid = sys_getenvid();
  80107e:	e8 28 fc ff ff       	call   800cab <sys_getenvid>
  801083:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	void *va = (void *)(pn*PGSIZE);
  801086:	89 f7                	mov    %esi,%edi
  801088:	c1 e7 0c             	shl    $0xc,%edi
        if(uvpt[pn] & PTE_SHARE){
  80108b:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801092:	f6 c4 04             	test   $0x4,%ah
  801095:	75 99                	jne    801030 <fork+0x62>
	if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)){
  801097:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80109e:	a8 02                	test   $0x2,%al
  8010a0:	0f 85 ed 00 00 00    	jne    801193 <fork+0x1c5>
  8010a6:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010ad:	f6 c4 08             	test   $0x8,%ah
  8010b0:	0f 85 dd 00 00 00    	jne    801193 <fork+0x1c5>
	 if((r=sys_page_map(parent_envid,va,envid,va,perm))<0)
  8010b6:	83 ec 0c             	sub    $0xc,%esp
  8010b9:	6a 05                	push   $0x5
  8010bb:	57                   	push   %edi
  8010bc:	ff 75 e0             	pushl  -0x20(%ebp)
  8010bf:	57                   	push   %edi
  8010c0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010c3:	e8 64 fc ff ff       	call   800d2c <sys_page_map>
  8010c8:	83 c4 20             	add    $0x20,%esp
  8010cb:	85 c0                	test   %eax,%eax
  8010cd:	79 81                	jns    801050 <fork+0x82>
  8010cf:	e9 db 00 00 00       	jmp    8011af <fork+0x1e1>
		   duppage(envid,PGNUM(addr));
	}
        
	int r;
	if((r=sys_page_alloc(envid,(void *)UXSTACKTOP-PGSIZE,PTE_U|PTE_P|PTE_W))<0)
  8010d4:	83 ec 04             	sub    $0x4,%esp
  8010d7:	6a 07                	push   $0x7
  8010d9:	68 00 f0 bf ee       	push   $0xeebff000
  8010de:	ff 75 dc             	pushl  -0x24(%ebp)
  8010e1:	e8 03 fc ff ff       	call   800ce9 <sys_page_alloc>
  8010e6:	83 c4 10             	add    $0x10,%esp
  8010e9:	85 c0                	test   %eax,%eax
  8010eb:	78 36                	js     801123 <fork+0x155>
		panic("fork:page alloc failed %e\n",r);

	extern void _pgfault_upcall();
	if((r = sys_env_set_pgfault_upcall(envid,_pgfault_upcall)))
  8010ed:	83 ec 08             	sub    $0x8,%esp
  8010f0:	68 4d 25 80 00       	push   $0x80254d
  8010f5:	ff 75 dc             	pushl  -0x24(%ebp)
  8010f8:	e8 37 fd ff ff       	call   800e34 <sys_env_set_pgfault_upcall>
  8010fd:	83 c4 10             	add    $0x10,%esp
  801100:	85 c0                	test   %eax,%eax
  801102:	75 34                	jne    801138 <fork+0x16a>
		panic("fork:set upcall failed %e\n",r);
	if((r = sys_env_set_status(envid,ENV_RUNNABLE))<0)
  801104:	83 ec 08             	sub    $0x8,%esp
  801107:	6a 02                	push   $0x2
  801109:	ff 75 dc             	pushl  -0x24(%ebp)
  80110c:	e8 9f fc ff ff       	call   800db0 <sys_env_set_status>
  801111:	83 c4 10             	add    $0x10,%esp
  801114:	85 c0                	test   %eax,%eax
  801116:	78 35                	js     80114d <fork+0x17f>
		panic("fork:set status failed %e\n",r);
	//cprintf("forkid= %d\n", envid);
	return envid;
       	
}
  801118:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80111b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80111e:	5b                   	pop    %ebx
  80111f:	5e                   	pop    %esi
  801120:	5f                   	pop    %edi
  801121:	5d                   	pop    %ebp
  801122:	c3                   	ret    
		panic("fork:page alloc failed %e\n",r);
  801123:	50                   	push   %eax
  801124:	68 bf 2d 80 00       	push   $0x802dbf
  801129:	68 84 00 00 00       	push   $0x84
  80112e:	68 3b 2d 80 00       	push   $0x802d3b
  801133:	e8 be f0 ff ff       	call   8001f6 <_panic>
		panic("fork:set upcall failed %e\n",r);
  801138:	50                   	push   %eax
  801139:	68 da 2d 80 00       	push   $0x802dda
  80113e:	68 88 00 00 00       	push   $0x88
  801143:	68 3b 2d 80 00       	push   $0x802d3b
  801148:	e8 a9 f0 ff ff       	call   8001f6 <_panic>
		panic("fork:set status failed %e\n",r);
  80114d:	50                   	push   %eax
  80114e:	68 f5 2d 80 00       	push   $0x802df5
  801153:	68 8a 00 00 00       	push   $0x8a
  801158:	68 3b 2d 80 00       	push   $0x802d3b
  80115d:	e8 94 f0 ff ff       	call   8001f6 <_panic>
		if( (r=sys_page_map(parent_envid,va,parent_envid,va,perm))<0){
  801162:	83 ec 0c             	sub    $0xc,%esp
  801165:	68 05 08 00 00       	push   $0x805
  80116a:	57                   	push   %edi
  80116b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80116e:	50                   	push   %eax
  80116f:	57                   	push   %edi
  801170:	50                   	push   %eax
  801171:	e8 b6 fb ff ff       	call   800d2c <sys_page_map>
  801176:	83 c4 20             	add    $0x20,%esp
  801179:	85 c0                	test   %eax,%eax
  80117b:	0f 89 cf fe ff ff    	jns    801050 <fork+0x82>
		 panic("duppage:map02 failed %e",r);
  801181:	50                   	push   %eax
  801182:	68 a7 2d 80 00       	push   $0x802da7
  801187:	6a 56                	push   $0x56
  801189:	68 3b 2d 80 00       	push   $0x802d3b
  80118e:	e8 63 f0 ff ff       	call   8001f6 <_panic>
	 if((r=sys_page_map(parent_envid,va,envid,va,perm))<0)
  801193:	83 ec 0c             	sub    $0xc,%esp
  801196:	68 05 08 00 00       	push   $0x805
  80119b:	57                   	push   %edi
  80119c:	ff 75 e0             	pushl  -0x20(%ebp)
  80119f:	57                   	push   %edi
  8011a0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011a3:	e8 84 fb ff ff       	call   800d2c <sys_page_map>
  8011a8:	83 c4 20             	add    $0x20,%esp
  8011ab:	85 c0                	test   %eax,%eax
  8011ad:	79 b3                	jns    801162 <fork+0x194>
		 panic("duppage:map01 failed %e",r);
  8011af:	50                   	push   %eax
  8011b0:	68 8f 2d 80 00       	push   $0x802d8f
  8011b5:	6a 53                	push   $0x53
  8011b7:	68 3b 2d 80 00       	push   $0x802d3b
  8011bc:	e8 35 f0 ff ff       	call   8001f6 <_panic>

008011c1 <sfork>:

// Challenge!
int
sfork(void)
{
  8011c1:	55                   	push   %ebp
  8011c2:	89 e5                	mov    %esp,%ebp
  8011c4:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011c7:	68 10 2e 80 00       	push   $0x802e10
  8011cc:	68 94 00 00 00       	push   $0x94
  8011d1:	68 3b 2d 80 00       	push   $0x802d3b
  8011d6:	e8 1b f0 ff ff       	call   8001f6 <_panic>

008011db <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011db:	55                   	push   %ebp
  8011dc:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011de:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e1:	05 00 00 00 30       	add    $0x30000000,%eax
  8011e6:	c1 e8 0c             	shr    $0xc,%eax
}
  8011e9:	5d                   	pop    %ebp
  8011ea:	c3                   	ret    

008011eb <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011eb:	55                   	push   %ebp
  8011ec:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f1:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8011f6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011fb:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801200:	5d                   	pop    %ebp
  801201:	c3                   	ret    

00801202 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801202:	55                   	push   %ebp
  801203:	89 e5                	mov    %esp,%ebp
  801205:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801208:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80120d:	89 c2                	mov    %eax,%edx
  80120f:	c1 ea 16             	shr    $0x16,%edx
  801212:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801219:	f6 c2 01             	test   $0x1,%dl
  80121c:	74 2a                	je     801248 <fd_alloc+0x46>
  80121e:	89 c2                	mov    %eax,%edx
  801220:	c1 ea 0c             	shr    $0xc,%edx
  801223:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80122a:	f6 c2 01             	test   $0x1,%dl
  80122d:	74 19                	je     801248 <fd_alloc+0x46>
  80122f:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801234:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801239:	75 d2                	jne    80120d <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80123b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801241:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801246:	eb 07                	jmp    80124f <fd_alloc+0x4d>
			*fd_store = fd;
  801248:	89 01                	mov    %eax,(%ecx)
			return 0;
  80124a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80124f:	5d                   	pop    %ebp
  801250:	c3                   	ret    

00801251 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801251:	55                   	push   %ebp
  801252:	89 e5                	mov    %esp,%ebp
  801254:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801257:	83 f8 1f             	cmp    $0x1f,%eax
  80125a:	77 36                	ja     801292 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80125c:	c1 e0 0c             	shl    $0xc,%eax
  80125f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801264:	89 c2                	mov    %eax,%edx
  801266:	c1 ea 16             	shr    $0x16,%edx
  801269:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801270:	f6 c2 01             	test   $0x1,%dl
  801273:	74 24                	je     801299 <fd_lookup+0x48>
  801275:	89 c2                	mov    %eax,%edx
  801277:	c1 ea 0c             	shr    $0xc,%edx
  80127a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801281:	f6 c2 01             	test   $0x1,%dl
  801284:	74 1a                	je     8012a0 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801286:	8b 55 0c             	mov    0xc(%ebp),%edx
  801289:	89 02                	mov    %eax,(%edx)
	return 0;
  80128b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801290:	5d                   	pop    %ebp
  801291:	c3                   	ret    
		return -E_INVAL;
  801292:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801297:	eb f7                	jmp    801290 <fd_lookup+0x3f>
		return -E_INVAL;
  801299:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80129e:	eb f0                	jmp    801290 <fd_lookup+0x3f>
  8012a0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012a5:	eb e9                	jmp    801290 <fd_lookup+0x3f>

008012a7 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012a7:	55                   	push   %ebp
  8012a8:	89 e5                	mov    %esp,%ebp
  8012aa:	83 ec 08             	sub    $0x8,%esp
  8012ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012b0:	ba c8 2e 80 00       	mov    $0x802ec8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012b5:	b8 0c 40 80 00       	mov    $0x80400c,%eax
		if (devtab[i]->dev_id == dev_id) {
  8012ba:	39 08                	cmp    %ecx,(%eax)
  8012bc:	74 33                	je     8012f1 <dev_lookup+0x4a>
  8012be:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  8012c1:	8b 02                	mov    (%edx),%eax
  8012c3:	85 c0                	test   %eax,%eax
  8012c5:	75 f3                	jne    8012ba <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012c7:	a1 04 50 80 00       	mov    0x805004,%eax
  8012cc:	8b 40 48             	mov    0x48(%eax),%eax
  8012cf:	83 ec 04             	sub    $0x4,%esp
  8012d2:	51                   	push   %ecx
  8012d3:	50                   	push   %eax
  8012d4:	68 4c 2e 80 00       	push   $0x802e4c
  8012d9:	e8 f3 ef ff ff       	call   8002d1 <cprintf>
	*dev = 0;
  8012de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012e1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012e7:	83 c4 10             	add    $0x10,%esp
  8012ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012ef:	c9                   	leave  
  8012f0:	c3                   	ret    
			*dev = devtab[i];
  8012f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012f4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8012fb:	eb f2                	jmp    8012ef <dev_lookup+0x48>

008012fd <fd_close>:
{
  8012fd:	55                   	push   %ebp
  8012fe:	89 e5                	mov    %esp,%ebp
  801300:	57                   	push   %edi
  801301:	56                   	push   %esi
  801302:	53                   	push   %ebx
  801303:	83 ec 1c             	sub    $0x1c,%esp
  801306:	8b 75 08             	mov    0x8(%ebp),%esi
  801309:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80130c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80130f:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801310:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801316:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801319:	50                   	push   %eax
  80131a:	e8 32 ff ff ff       	call   801251 <fd_lookup>
  80131f:	89 c3                	mov    %eax,%ebx
  801321:	83 c4 08             	add    $0x8,%esp
  801324:	85 c0                	test   %eax,%eax
  801326:	78 05                	js     80132d <fd_close+0x30>
	    || fd != fd2)
  801328:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80132b:	74 16                	je     801343 <fd_close+0x46>
		return (must_exist ? r : 0);
  80132d:	89 f8                	mov    %edi,%eax
  80132f:	84 c0                	test   %al,%al
  801331:	b8 00 00 00 00       	mov    $0x0,%eax
  801336:	0f 44 d8             	cmove  %eax,%ebx
}
  801339:	89 d8                	mov    %ebx,%eax
  80133b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80133e:	5b                   	pop    %ebx
  80133f:	5e                   	pop    %esi
  801340:	5f                   	pop    %edi
  801341:	5d                   	pop    %ebp
  801342:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801343:	83 ec 08             	sub    $0x8,%esp
  801346:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801349:	50                   	push   %eax
  80134a:	ff 36                	pushl  (%esi)
  80134c:	e8 56 ff ff ff       	call   8012a7 <dev_lookup>
  801351:	89 c3                	mov    %eax,%ebx
  801353:	83 c4 10             	add    $0x10,%esp
  801356:	85 c0                	test   %eax,%eax
  801358:	78 15                	js     80136f <fd_close+0x72>
		if (dev->dev_close)
  80135a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80135d:	8b 40 10             	mov    0x10(%eax),%eax
  801360:	85 c0                	test   %eax,%eax
  801362:	74 1b                	je     80137f <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  801364:	83 ec 0c             	sub    $0xc,%esp
  801367:	56                   	push   %esi
  801368:	ff d0                	call   *%eax
  80136a:	89 c3                	mov    %eax,%ebx
  80136c:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80136f:	83 ec 08             	sub    $0x8,%esp
  801372:	56                   	push   %esi
  801373:	6a 00                	push   $0x0
  801375:	e8 f4 f9 ff ff       	call   800d6e <sys_page_unmap>
	return r;
  80137a:	83 c4 10             	add    $0x10,%esp
  80137d:	eb ba                	jmp    801339 <fd_close+0x3c>
			r = 0;
  80137f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801384:	eb e9                	jmp    80136f <fd_close+0x72>

00801386 <close>:

int
close(int fdnum)
{
  801386:	55                   	push   %ebp
  801387:	89 e5                	mov    %esp,%ebp
  801389:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80138c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80138f:	50                   	push   %eax
  801390:	ff 75 08             	pushl  0x8(%ebp)
  801393:	e8 b9 fe ff ff       	call   801251 <fd_lookup>
  801398:	83 c4 08             	add    $0x8,%esp
  80139b:	85 c0                	test   %eax,%eax
  80139d:	78 10                	js     8013af <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80139f:	83 ec 08             	sub    $0x8,%esp
  8013a2:	6a 01                	push   $0x1
  8013a4:	ff 75 f4             	pushl  -0xc(%ebp)
  8013a7:	e8 51 ff ff ff       	call   8012fd <fd_close>
  8013ac:	83 c4 10             	add    $0x10,%esp
}
  8013af:	c9                   	leave  
  8013b0:	c3                   	ret    

008013b1 <close_all>:

void
close_all(void)
{
  8013b1:	55                   	push   %ebp
  8013b2:	89 e5                	mov    %esp,%ebp
  8013b4:	53                   	push   %ebx
  8013b5:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013b8:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013bd:	83 ec 0c             	sub    $0xc,%esp
  8013c0:	53                   	push   %ebx
  8013c1:	e8 c0 ff ff ff       	call   801386 <close>
	for (i = 0; i < MAXFD; i++)
  8013c6:	83 c3 01             	add    $0x1,%ebx
  8013c9:	83 c4 10             	add    $0x10,%esp
  8013cc:	83 fb 20             	cmp    $0x20,%ebx
  8013cf:	75 ec                	jne    8013bd <close_all+0xc>
}
  8013d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013d4:	c9                   	leave  
  8013d5:	c3                   	ret    

008013d6 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013d6:	55                   	push   %ebp
  8013d7:	89 e5                	mov    %esp,%ebp
  8013d9:	57                   	push   %edi
  8013da:	56                   	push   %esi
  8013db:	53                   	push   %ebx
  8013dc:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013df:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013e2:	50                   	push   %eax
  8013e3:	ff 75 08             	pushl  0x8(%ebp)
  8013e6:	e8 66 fe ff ff       	call   801251 <fd_lookup>
  8013eb:	89 c3                	mov    %eax,%ebx
  8013ed:	83 c4 08             	add    $0x8,%esp
  8013f0:	85 c0                	test   %eax,%eax
  8013f2:	0f 88 81 00 00 00    	js     801479 <dup+0xa3>
		return r;
	close(newfdnum);
  8013f8:	83 ec 0c             	sub    $0xc,%esp
  8013fb:	ff 75 0c             	pushl  0xc(%ebp)
  8013fe:	e8 83 ff ff ff       	call   801386 <close>

	newfd = INDEX2FD(newfdnum);
  801403:	8b 75 0c             	mov    0xc(%ebp),%esi
  801406:	c1 e6 0c             	shl    $0xc,%esi
  801409:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80140f:	83 c4 04             	add    $0x4,%esp
  801412:	ff 75 e4             	pushl  -0x1c(%ebp)
  801415:	e8 d1 fd ff ff       	call   8011eb <fd2data>
  80141a:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80141c:	89 34 24             	mov    %esi,(%esp)
  80141f:	e8 c7 fd ff ff       	call   8011eb <fd2data>
  801424:	83 c4 10             	add    $0x10,%esp
  801427:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801429:	89 d8                	mov    %ebx,%eax
  80142b:	c1 e8 16             	shr    $0x16,%eax
  80142e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801435:	a8 01                	test   $0x1,%al
  801437:	74 11                	je     80144a <dup+0x74>
  801439:	89 d8                	mov    %ebx,%eax
  80143b:	c1 e8 0c             	shr    $0xc,%eax
  80143e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801445:	f6 c2 01             	test   $0x1,%dl
  801448:	75 39                	jne    801483 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80144a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80144d:	89 d0                	mov    %edx,%eax
  80144f:	c1 e8 0c             	shr    $0xc,%eax
  801452:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801459:	83 ec 0c             	sub    $0xc,%esp
  80145c:	25 07 0e 00 00       	and    $0xe07,%eax
  801461:	50                   	push   %eax
  801462:	56                   	push   %esi
  801463:	6a 00                	push   $0x0
  801465:	52                   	push   %edx
  801466:	6a 00                	push   $0x0
  801468:	e8 bf f8 ff ff       	call   800d2c <sys_page_map>
  80146d:	89 c3                	mov    %eax,%ebx
  80146f:	83 c4 20             	add    $0x20,%esp
  801472:	85 c0                	test   %eax,%eax
  801474:	78 31                	js     8014a7 <dup+0xd1>
		goto err;

	return newfdnum;
  801476:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801479:	89 d8                	mov    %ebx,%eax
  80147b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80147e:	5b                   	pop    %ebx
  80147f:	5e                   	pop    %esi
  801480:	5f                   	pop    %edi
  801481:	5d                   	pop    %ebp
  801482:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801483:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80148a:	83 ec 0c             	sub    $0xc,%esp
  80148d:	25 07 0e 00 00       	and    $0xe07,%eax
  801492:	50                   	push   %eax
  801493:	57                   	push   %edi
  801494:	6a 00                	push   $0x0
  801496:	53                   	push   %ebx
  801497:	6a 00                	push   $0x0
  801499:	e8 8e f8 ff ff       	call   800d2c <sys_page_map>
  80149e:	89 c3                	mov    %eax,%ebx
  8014a0:	83 c4 20             	add    $0x20,%esp
  8014a3:	85 c0                	test   %eax,%eax
  8014a5:	79 a3                	jns    80144a <dup+0x74>
	sys_page_unmap(0, newfd);
  8014a7:	83 ec 08             	sub    $0x8,%esp
  8014aa:	56                   	push   %esi
  8014ab:	6a 00                	push   $0x0
  8014ad:	e8 bc f8 ff ff       	call   800d6e <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014b2:	83 c4 08             	add    $0x8,%esp
  8014b5:	57                   	push   %edi
  8014b6:	6a 00                	push   $0x0
  8014b8:	e8 b1 f8 ff ff       	call   800d6e <sys_page_unmap>
	return r;
  8014bd:	83 c4 10             	add    $0x10,%esp
  8014c0:	eb b7                	jmp    801479 <dup+0xa3>

008014c2 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014c2:	55                   	push   %ebp
  8014c3:	89 e5                	mov    %esp,%ebp
  8014c5:	53                   	push   %ebx
  8014c6:	83 ec 14             	sub    $0x14,%esp
  8014c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014cf:	50                   	push   %eax
  8014d0:	53                   	push   %ebx
  8014d1:	e8 7b fd ff ff       	call   801251 <fd_lookup>
  8014d6:	83 c4 08             	add    $0x8,%esp
  8014d9:	85 c0                	test   %eax,%eax
  8014db:	78 3f                	js     80151c <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014dd:	83 ec 08             	sub    $0x8,%esp
  8014e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e3:	50                   	push   %eax
  8014e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014e7:	ff 30                	pushl  (%eax)
  8014e9:	e8 b9 fd ff ff       	call   8012a7 <dev_lookup>
  8014ee:	83 c4 10             	add    $0x10,%esp
  8014f1:	85 c0                	test   %eax,%eax
  8014f3:	78 27                	js     80151c <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014f5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014f8:	8b 42 08             	mov    0x8(%edx),%eax
  8014fb:	83 e0 03             	and    $0x3,%eax
  8014fe:	83 f8 01             	cmp    $0x1,%eax
  801501:	74 1e                	je     801521 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801503:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801506:	8b 40 08             	mov    0x8(%eax),%eax
  801509:	85 c0                	test   %eax,%eax
  80150b:	74 35                	je     801542 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80150d:	83 ec 04             	sub    $0x4,%esp
  801510:	ff 75 10             	pushl  0x10(%ebp)
  801513:	ff 75 0c             	pushl  0xc(%ebp)
  801516:	52                   	push   %edx
  801517:	ff d0                	call   *%eax
  801519:	83 c4 10             	add    $0x10,%esp
}
  80151c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80151f:	c9                   	leave  
  801520:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801521:	a1 04 50 80 00       	mov    0x805004,%eax
  801526:	8b 40 48             	mov    0x48(%eax),%eax
  801529:	83 ec 04             	sub    $0x4,%esp
  80152c:	53                   	push   %ebx
  80152d:	50                   	push   %eax
  80152e:	68 8d 2e 80 00       	push   $0x802e8d
  801533:	e8 99 ed ff ff       	call   8002d1 <cprintf>
		return -E_INVAL;
  801538:	83 c4 10             	add    $0x10,%esp
  80153b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801540:	eb da                	jmp    80151c <read+0x5a>
		return -E_NOT_SUPP;
  801542:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801547:	eb d3                	jmp    80151c <read+0x5a>

00801549 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801549:	55                   	push   %ebp
  80154a:	89 e5                	mov    %esp,%ebp
  80154c:	57                   	push   %edi
  80154d:	56                   	push   %esi
  80154e:	53                   	push   %ebx
  80154f:	83 ec 0c             	sub    $0xc,%esp
  801552:	8b 7d 08             	mov    0x8(%ebp),%edi
  801555:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801558:	bb 00 00 00 00       	mov    $0x0,%ebx
  80155d:	39 f3                	cmp    %esi,%ebx
  80155f:	73 25                	jae    801586 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801561:	83 ec 04             	sub    $0x4,%esp
  801564:	89 f0                	mov    %esi,%eax
  801566:	29 d8                	sub    %ebx,%eax
  801568:	50                   	push   %eax
  801569:	89 d8                	mov    %ebx,%eax
  80156b:	03 45 0c             	add    0xc(%ebp),%eax
  80156e:	50                   	push   %eax
  80156f:	57                   	push   %edi
  801570:	e8 4d ff ff ff       	call   8014c2 <read>
		if (m < 0)
  801575:	83 c4 10             	add    $0x10,%esp
  801578:	85 c0                	test   %eax,%eax
  80157a:	78 08                	js     801584 <readn+0x3b>
			return m;
		if (m == 0)
  80157c:	85 c0                	test   %eax,%eax
  80157e:	74 06                	je     801586 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  801580:	01 c3                	add    %eax,%ebx
  801582:	eb d9                	jmp    80155d <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801584:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801586:	89 d8                	mov    %ebx,%eax
  801588:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80158b:	5b                   	pop    %ebx
  80158c:	5e                   	pop    %esi
  80158d:	5f                   	pop    %edi
  80158e:	5d                   	pop    %ebp
  80158f:	c3                   	ret    

00801590 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801590:	55                   	push   %ebp
  801591:	89 e5                	mov    %esp,%ebp
  801593:	53                   	push   %ebx
  801594:	83 ec 14             	sub    $0x14,%esp
  801597:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80159a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80159d:	50                   	push   %eax
  80159e:	53                   	push   %ebx
  80159f:	e8 ad fc ff ff       	call   801251 <fd_lookup>
  8015a4:	83 c4 08             	add    $0x8,%esp
  8015a7:	85 c0                	test   %eax,%eax
  8015a9:	78 3a                	js     8015e5 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ab:	83 ec 08             	sub    $0x8,%esp
  8015ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b1:	50                   	push   %eax
  8015b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b5:	ff 30                	pushl  (%eax)
  8015b7:	e8 eb fc ff ff       	call   8012a7 <dev_lookup>
  8015bc:	83 c4 10             	add    $0x10,%esp
  8015bf:	85 c0                	test   %eax,%eax
  8015c1:	78 22                	js     8015e5 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015ca:	74 1e                	je     8015ea <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015cf:	8b 52 0c             	mov    0xc(%edx),%edx
  8015d2:	85 d2                	test   %edx,%edx
  8015d4:	74 35                	je     80160b <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015d6:	83 ec 04             	sub    $0x4,%esp
  8015d9:	ff 75 10             	pushl  0x10(%ebp)
  8015dc:	ff 75 0c             	pushl  0xc(%ebp)
  8015df:	50                   	push   %eax
  8015e0:	ff d2                	call   *%edx
  8015e2:	83 c4 10             	add    $0x10,%esp
}
  8015e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015e8:	c9                   	leave  
  8015e9:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015ea:	a1 04 50 80 00       	mov    0x805004,%eax
  8015ef:	8b 40 48             	mov    0x48(%eax),%eax
  8015f2:	83 ec 04             	sub    $0x4,%esp
  8015f5:	53                   	push   %ebx
  8015f6:	50                   	push   %eax
  8015f7:	68 a9 2e 80 00       	push   $0x802ea9
  8015fc:	e8 d0 ec ff ff       	call   8002d1 <cprintf>
		return -E_INVAL;
  801601:	83 c4 10             	add    $0x10,%esp
  801604:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801609:	eb da                	jmp    8015e5 <write+0x55>
		return -E_NOT_SUPP;
  80160b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801610:	eb d3                	jmp    8015e5 <write+0x55>

00801612 <seek>:

int
seek(int fdnum, off_t offset)
{
  801612:	55                   	push   %ebp
  801613:	89 e5                	mov    %esp,%ebp
  801615:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801618:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80161b:	50                   	push   %eax
  80161c:	ff 75 08             	pushl  0x8(%ebp)
  80161f:	e8 2d fc ff ff       	call   801251 <fd_lookup>
  801624:	83 c4 08             	add    $0x8,%esp
  801627:	85 c0                	test   %eax,%eax
  801629:	78 0e                	js     801639 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80162b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80162e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801631:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801634:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801639:	c9                   	leave  
  80163a:	c3                   	ret    

0080163b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80163b:	55                   	push   %ebp
  80163c:	89 e5                	mov    %esp,%ebp
  80163e:	53                   	push   %ebx
  80163f:	83 ec 14             	sub    $0x14,%esp
  801642:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801645:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801648:	50                   	push   %eax
  801649:	53                   	push   %ebx
  80164a:	e8 02 fc ff ff       	call   801251 <fd_lookup>
  80164f:	83 c4 08             	add    $0x8,%esp
  801652:	85 c0                	test   %eax,%eax
  801654:	78 37                	js     80168d <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801656:	83 ec 08             	sub    $0x8,%esp
  801659:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80165c:	50                   	push   %eax
  80165d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801660:	ff 30                	pushl  (%eax)
  801662:	e8 40 fc ff ff       	call   8012a7 <dev_lookup>
  801667:	83 c4 10             	add    $0x10,%esp
  80166a:	85 c0                	test   %eax,%eax
  80166c:	78 1f                	js     80168d <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80166e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801671:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801675:	74 1b                	je     801692 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801677:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80167a:	8b 52 18             	mov    0x18(%edx),%edx
  80167d:	85 d2                	test   %edx,%edx
  80167f:	74 32                	je     8016b3 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801681:	83 ec 08             	sub    $0x8,%esp
  801684:	ff 75 0c             	pushl  0xc(%ebp)
  801687:	50                   	push   %eax
  801688:	ff d2                	call   *%edx
  80168a:	83 c4 10             	add    $0x10,%esp
}
  80168d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801690:	c9                   	leave  
  801691:	c3                   	ret    
			thisenv->env_id, fdnum);
  801692:	a1 04 50 80 00       	mov    0x805004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801697:	8b 40 48             	mov    0x48(%eax),%eax
  80169a:	83 ec 04             	sub    $0x4,%esp
  80169d:	53                   	push   %ebx
  80169e:	50                   	push   %eax
  80169f:	68 6c 2e 80 00       	push   $0x802e6c
  8016a4:	e8 28 ec ff ff       	call   8002d1 <cprintf>
		return -E_INVAL;
  8016a9:	83 c4 10             	add    $0x10,%esp
  8016ac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016b1:	eb da                	jmp    80168d <ftruncate+0x52>
		return -E_NOT_SUPP;
  8016b3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016b8:	eb d3                	jmp    80168d <ftruncate+0x52>

008016ba <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016ba:	55                   	push   %ebp
  8016bb:	89 e5                	mov    %esp,%ebp
  8016bd:	53                   	push   %ebx
  8016be:	83 ec 14             	sub    $0x14,%esp
  8016c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016c7:	50                   	push   %eax
  8016c8:	ff 75 08             	pushl  0x8(%ebp)
  8016cb:	e8 81 fb ff ff       	call   801251 <fd_lookup>
  8016d0:	83 c4 08             	add    $0x8,%esp
  8016d3:	85 c0                	test   %eax,%eax
  8016d5:	78 4b                	js     801722 <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d7:	83 ec 08             	sub    $0x8,%esp
  8016da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016dd:	50                   	push   %eax
  8016de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016e1:	ff 30                	pushl  (%eax)
  8016e3:	e8 bf fb ff ff       	call   8012a7 <dev_lookup>
  8016e8:	83 c4 10             	add    $0x10,%esp
  8016eb:	85 c0                	test   %eax,%eax
  8016ed:	78 33                	js     801722 <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  8016ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016f2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016f6:	74 2f                	je     801727 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016f8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016fb:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801702:	00 00 00 
	stat->st_isdir = 0;
  801705:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80170c:	00 00 00 
	stat->st_dev = dev;
  80170f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801715:	83 ec 08             	sub    $0x8,%esp
  801718:	53                   	push   %ebx
  801719:	ff 75 f0             	pushl  -0x10(%ebp)
  80171c:	ff 50 14             	call   *0x14(%eax)
  80171f:	83 c4 10             	add    $0x10,%esp
}
  801722:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801725:	c9                   	leave  
  801726:	c3                   	ret    
		return -E_NOT_SUPP;
  801727:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80172c:	eb f4                	jmp    801722 <fstat+0x68>

0080172e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80172e:	55                   	push   %ebp
  80172f:	89 e5                	mov    %esp,%ebp
  801731:	56                   	push   %esi
  801732:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801733:	83 ec 08             	sub    $0x8,%esp
  801736:	6a 00                	push   $0x0
  801738:	ff 75 08             	pushl  0x8(%ebp)
  80173b:	e8 e7 01 00 00       	call   801927 <open>
  801740:	89 c3                	mov    %eax,%ebx
  801742:	83 c4 10             	add    $0x10,%esp
  801745:	85 c0                	test   %eax,%eax
  801747:	78 1b                	js     801764 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801749:	83 ec 08             	sub    $0x8,%esp
  80174c:	ff 75 0c             	pushl  0xc(%ebp)
  80174f:	50                   	push   %eax
  801750:	e8 65 ff ff ff       	call   8016ba <fstat>
  801755:	89 c6                	mov    %eax,%esi
	close(fd);
  801757:	89 1c 24             	mov    %ebx,(%esp)
  80175a:	e8 27 fc ff ff       	call   801386 <close>
	return r;
  80175f:	83 c4 10             	add    $0x10,%esp
  801762:	89 f3                	mov    %esi,%ebx
}
  801764:	89 d8                	mov    %ebx,%eax
  801766:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801769:	5b                   	pop    %ebx
  80176a:	5e                   	pop    %esi
  80176b:	5d                   	pop    %ebp
  80176c:	c3                   	ret    

0080176d <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80176d:	55                   	push   %ebp
  80176e:	89 e5                	mov    %esp,%ebp
  801770:	56                   	push   %esi
  801771:	53                   	push   %ebx
  801772:	89 c6                	mov    %eax,%esi
  801774:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801776:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80177d:	74 27                	je     8017a6 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80177f:	6a 07                	push   $0x7
  801781:	68 00 60 80 00       	push   $0x806000
  801786:	56                   	push   %esi
  801787:	ff 35 00 50 80 00    	pushl  0x805000
  80178d:	e8 57 0e 00 00       	call   8025e9 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801792:	83 c4 0c             	add    $0xc,%esp
  801795:	6a 00                	push   $0x0
  801797:	53                   	push   %ebx
  801798:	6a 00                	push   $0x0
  80179a:	e8 d5 0d 00 00       	call   802574 <ipc_recv>
}
  80179f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017a2:	5b                   	pop    %ebx
  8017a3:	5e                   	pop    %esi
  8017a4:	5d                   	pop    %ebp
  8017a5:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017a6:	83 ec 0c             	sub    $0xc,%esp
  8017a9:	6a 01                	push   $0x1
  8017ab:	e8 8f 0e 00 00       	call   80263f <ipc_find_env>
  8017b0:	a3 00 50 80 00       	mov    %eax,0x805000
  8017b5:	83 c4 10             	add    $0x10,%esp
  8017b8:	eb c5                	jmp    80177f <fsipc+0x12>

008017ba <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017ba:	55                   	push   %ebp
  8017bb:	89 e5                	mov    %esp,%ebp
  8017bd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c3:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c6:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  8017cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017ce:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d8:	b8 02 00 00 00       	mov    $0x2,%eax
  8017dd:	e8 8b ff ff ff       	call   80176d <fsipc>
}
  8017e2:	c9                   	leave  
  8017e3:	c3                   	ret    

008017e4 <devfile_flush>:
{
  8017e4:	55                   	push   %ebp
  8017e5:	89 e5                	mov    %esp,%ebp
  8017e7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ed:	8b 40 0c             	mov    0xc(%eax),%eax
  8017f0:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  8017f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8017fa:	b8 06 00 00 00       	mov    $0x6,%eax
  8017ff:	e8 69 ff ff ff       	call   80176d <fsipc>
}
  801804:	c9                   	leave  
  801805:	c3                   	ret    

00801806 <devfile_stat>:
{
  801806:	55                   	push   %ebp
  801807:	89 e5                	mov    %esp,%ebp
  801809:	53                   	push   %ebx
  80180a:	83 ec 04             	sub    $0x4,%esp
  80180d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801810:	8b 45 08             	mov    0x8(%ebp),%eax
  801813:	8b 40 0c             	mov    0xc(%eax),%eax
  801816:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80181b:	ba 00 00 00 00       	mov    $0x0,%edx
  801820:	b8 05 00 00 00       	mov    $0x5,%eax
  801825:	e8 43 ff ff ff       	call   80176d <fsipc>
  80182a:	85 c0                	test   %eax,%eax
  80182c:	78 2c                	js     80185a <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80182e:	83 ec 08             	sub    $0x8,%esp
  801831:	68 00 60 80 00       	push   $0x806000
  801836:	53                   	push   %ebx
  801837:	e8 b4 f0 ff ff       	call   8008f0 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80183c:	a1 80 60 80 00       	mov    0x806080,%eax
  801841:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801847:	a1 84 60 80 00       	mov    0x806084,%eax
  80184c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801852:	83 c4 10             	add    $0x10,%esp
  801855:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80185a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80185d:	c9                   	leave  
  80185e:	c3                   	ret    

0080185f <devfile_write>:
{
  80185f:	55                   	push   %ebp
  801860:	89 e5                	mov    %esp,%ebp
  801862:	83 ec 0c             	sub    $0xc,%esp
  801865:	8b 45 10             	mov    0x10(%ebp),%eax
  801868:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80186d:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801872:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801875:	8b 55 08             	mov    0x8(%ebp),%edx
  801878:	8b 52 0c             	mov    0xc(%edx),%edx
  80187b:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801881:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf,buf,n);
  801886:	50                   	push   %eax
  801887:	ff 75 0c             	pushl  0xc(%ebp)
  80188a:	68 08 60 80 00       	push   $0x806008
  80188f:	e8 ea f1 ff ff       	call   800a7e <memmove>
	if((r = fsipc(FSREQ_WRITE,NULL))<0)
  801894:	ba 00 00 00 00       	mov    $0x0,%edx
  801899:	b8 04 00 00 00       	mov    $0x4,%eax
  80189e:	e8 ca fe ff ff       	call   80176d <fsipc>
}
  8018a3:	c9                   	leave  
  8018a4:	c3                   	ret    

008018a5 <devfile_read>:
{
  8018a5:	55                   	push   %ebp
  8018a6:	89 e5                	mov    %esp,%ebp
  8018a8:	56                   	push   %esi
  8018a9:	53                   	push   %ebx
  8018aa:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b0:	8b 40 0c             	mov    0xc(%eax),%eax
  8018b3:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  8018b8:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018be:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c3:	b8 03 00 00 00       	mov    $0x3,%eax
  8018c8:	e8 a0 fe ff ff       	call   80176d <fsipc>
  8018cd:	89 c3                	mov    %eax,%ebx
  8018cf:	85 c0                	test   %eax,%eax
  8018d1:	78 1f                	js     8018f2 <devfile_read+0x4d>
	assert(r <= n);
  8018d3:	39 f0                	cmp    %esi,%eax
  8018d5:	77 24                	ja     8018fb <devfile_read+0x56>
	assert(r <= PGSIZE);
  8018d7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018dc:	7f 33                	jg     801911 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018de:	83 ec 04             	sub    $0x4,%esp
  8018e1:	50                   	push   %eax
  8018e2:	68 00 60 80 00       	push   $0x806000
  8018e7:	ff 75 0c             	pushl  0xc(%ebp)
  8018ea:	e8 8f f1 ff ff       	call   800a7e <memmove>
	return r;
  8018ef:	83 c4 10             	add    $0x10,%esp
}
  8018f2:	89 d8                	mov    %ebx,%eax
  8018f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018f7:	5b                   	pop    %ebx
  8018f8:	5e                   	pop    %esi
  8018f9:	5d                   	pop    %ebp
  8018fa:	c3                   	ret    
	assert(r <= n);
  8018fb:	68 d8 2e 80 00       	push   $0x802ed8
  801900:	68 df 2e 80 00       	push   $0x802edf
  801905:	6a 7c                	push   $0x7c
  801907:	68 f4 2e 80 00       	push   $0x802ef4
  80190c:	e8 e5 e8 ff ff       	call   8001f6 <_panic>
	assert(r <= PGSIZE);
  801911:	68 ff 2e 80 00       	push   $0x802eff
  801916:	68 df 2e 80 00       	push   $0x802edf
  80191b:	6a 7d                	push   $0x7d
  80191d:	68 f4 2e 80 00       	push   $0x802ef4
  801922:	e8 cf e8 ff ff       	call   8001f6 <_panic>

00801927 <open>:
{
  801927:	55                   	push   %ebp
  801928:	89 e5                	mov    %esp,%ebp
  80192a:	56                   	push   %esi
  80192b:	53                   	push   %ebx
  80192c:	83 ec 1c             	sub    $0x1c,%esp
  80192f:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801932:	56                   	push   %esi
  801933:	e8 81 ef ff ff       	call   8008b9 <strlen>
  801938:	83 c4 10             	add    $0x10,%esp
  80193b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801940:	7f 6c                	jg     8019ae <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801942:	83 ec 0c             	sub    $0xc,%esp
  801945:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801948:	50                   	push   %eax
  801949:	e8 b4 f8 ff ff       	call   801202 <fd_alloc>
  80194e:	89 c3                	mov    %eax,%ebx
  801950:	83 c4 10             	add    $0x10,%esp
  801953:	85 c0                	test   %eax,%eax
  801955:	78 3c                	js     801993 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801957:	83 ec 08             	sub    $0x8,%esp
  80195a:	56                   	push   %esi
  80195b:	68 00 60 80 00       	push   $0x806000
  801960:	e8 8b ef ff ff       	call   8008f0 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801965:	8b 45 0c             	mov    0xc(%ebp),%eax
  801968:	a3 00 64 80 00       	mov    %eax,0x806400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80196d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801970:	b8 01 00 00 00       	mov    $0x1,%eax
  801975:	e8 f3 fd ff ff       	call   80176d <fsipc>
  80197a:	89 c3                	mov    %eax,%ebx
  80197c:	83 c4 10             	add    $0x10,%esp
  80197f:	85 c0                	test   %eax,%eax
  801981:	78 19                	js     80199c <open+0x75>
	return fd2num(fd);
  801983:	83 ec 0c             	sub    $0xc,%esp
  801986:	ff 75 f4             	pushl  -0xc(%ebp)
  801989:	e8 4d f8 ff ff       	call   8011db <fd2num>
  80198e:	89 c3                	mov    %eax,%ebx
  801990:	83 c4 10             	add    $0x10,%esp
}
  801993:	89 d8                	mov    %ebx,%eax
  801995:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801998:	5b                   	pop    %ebx
  801999:	5e                   	pop    %esi
  80199a:	5d                   	pop    %ebp
  80199b:	c3                   	ret    
		fd_close(fd, 0);
  80199c:	83 ec 08             	sub    $0x8,%esp
  80199f:	6a 00                	push   $0x0
  8019a1:	ff 75 f4             	pushl  -0xc(%ebp)
  8019a4:	e8 54 f9 ff ff       	call   8012fd <fd_close>
		return r;
  8019a9:	83 c4 10             	add    $0x10,%esp
  8019ac:	eb e5                	jmp    801993 <open+0x6c>
		return -E_BAD_PATH;
  8019ae:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8019b3:	eb de                	jmp    801993 <open+0x6c>

008019b5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019b5:	55                   	push   %ebp
  8019b6:	89 e5                	mov    %esp,%ebp
  8019b8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8019c0:	b8 08 00 00 00       	mov    $0x8,%eax
  8019c5:	e8 a3 fd ff ff       	call   80176d <fsipc>
}
  8019ca:	c9                   	leave  
  8019cb:	c3                   	ret    

008019cc <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8019cc:	55                   	push   %ebp
  8019cd:	89 e5                	mov    %esp,%ebp
  8019cf:	57                   	push   %edi
  8019d0:	56                   	push   %esi
  8019d1:	53                   	push   %ebx
  8019d2:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8019d8:	6a 00                	push   $0x0
  8019da:	ff 75 08             	pushl  0x8(%ebp)
  8019dd:	e8 45 ff ff ff       	call   801927 <open>
  8019e2:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  8019e8:	83 c4 10             	add    $0x10,%esp
  8019eb:	85 c0                	test   %eax,%eax
  8019ed:	0f 88 40 03 00 00    	js     801d33 <spawn+0x367>
  8019f3:	89 c2                	mov    %eax,%edx
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8019f5:	83 ec 04             	sub    $0x4,%esp
  8019f8:	68 00 02 00 00       	push   $0x200
  8019fd:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801a03:	50                   	push   %eax
  801a04:	52                   	push   %edx
  801a05:	e8 3f fb ff ff       	call   801549 <readn>
  801a0a:	83 c4 10             	add    $0x10,%esp
  801a0d:	3d 00 02 00 00       	cmp    $0x200,%eax
  801a12:	75 5d                	jne    801a71 <spawn+0xa5>
	    || elf->e_magic != ELF_MAGIC) {
  801a14:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801a1b:	45 4c 46 
  801a1e:	75 51                	jne    801a71 <spawn+0xa5>
  801a20:	b8 07 00 00 00       	mov    $0x7,%eax
  801a25:	cd 30                	int    $0x30
  801a27:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801a2d:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801a33:	85 c0                	test   %eax,%eax
  801a35:	0f 88 6e 04 00 00    	js     801ea9 <spawn+0x4dd>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801a3b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801a40:	6b f0 7c             	imul   $0x7c,%eax,%esi
  801a43:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801a49:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801a4f:	b9 11 00 00 00       	mov    $0x11,%ecx
  801a54:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801a56:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801a5c:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801a62:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  801a67:	be 00 00 00 00       	mov    $0x0,%esi
  801a6c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a6f:	eb 4b                	jmp    801abc <spawn+0xf0>
		close(fd);
  801a71:	83 ec 0c             	sub    $0xc,%esp
  801a74:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801a7a:	e8 07 f9 ff ff       	call   801386 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801a7f:	83 c4 0c             	add    $0xc,%esp
  801a82:	68 7f 45 4c 46       	push   $0x464c457f
  801a87:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801a8d:	68 0b 2f 80 00       	push   $0x802f0b
  801a92:	e8 3a e8 ff ff       	call   8002d1 <cprintf>
		return -E_NOT_EXEC;
  801a97:	83 c4 10             	add    $0x10,%esp
  801a9a:	c7 85 90 fd ff ff f2 	movl   $0xfffffff2,-0x270(%ebp)
  801aa1:	ff ff ff 
  801aa4:	e9 8a 02 00 00       	jmp    801d33 <spawn+0x367>
		string_size += strlen(argv[argc]) + 1;
  801aa9:	83 ec 0c             	sub    $0xc,%esp
  801aac:	50                   	push   %eax
  801aad:	e8 07 ee ff ff       	call   8008b9 <strlen>
  801ab2:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  801ab6:	83 c3 01             	add    $0x1,%ebx
  801ab9:	83 c4 10             	add    $0x10,%esp
  801abc:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801ac3:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801ac6:	85 c0                	test   %eax,%eax
  801ac8:	75 df                	jne    801aa9 <spawn+0xdd>
  801aca:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801ad0:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801ad6:	bf 00 10 40 00       	mov    $0x401000,%edi
  801adb:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801add:	89 fa                	mov    %edi,%edx
  801adf:	83 e2 fc             	and    $0xfffffffc,%edx
  801ae2:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801ae9:	29 c2                	sub    %eax,%edx
  801aeb:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801af1:	8d 42 f8             	lea    -0x8(%edx),%eax
  801af4:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801af9:	0f 86 bb 03 00 00    	jbe    801eba <spawn+0x4ee>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801aff:	83 ec 04             	sub    $0x4,%esp
  801b02:	6a 07                	push   $0x7
  801b04:	68 00 00 40 00       	push   $0x400000
  801b09:	6a 00                	push   $0x0
  801b0b:	e8 d9 f1 ff ff       	call   800ce9 <sys_page_alloc>
  801b10:	83 c4 10             	add    $0x10,%esp
  801b13:	85 c0                	test   %eax,%eax
  801b15:	0f 88 a4 03 00 00    	js     801ebf <spawn+0x4f3>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801b1b:	be 00 00 00 00       	mov    $0x0,%esi
  801b20:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  801b26:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801b29:	eb 30                	jmp    801b5b <spawn+0x18f>
		argv_store[i] = UTEMP2USTACK(string_store);
  801b2b:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801b31:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801b37:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  801b3a:	83 ec 08             	sub    $0x8,%esp
  801b3d:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801b40:	57                   	push   %edi
  801b41:	e8 aa ed ff ff       	call   8008f0 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801b46:	83 c4 04             	add    $0x4,%esp
  801b49:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801b4c:	e8 68 ed ff ff       	call   8008b9 <strlen>
  801b51:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  801b55:	83 c6 01             	add    $0x1,%esi
  801b58:	83 c4 10             	add    $0x10,%esp
  801b5b:	39 b5 8c fd ff ff    	cmp    %esi,-0x274(%ebp)
  801b61:	7f c8                	jg     801b2b <spawn+0x15f>
	}
	argv_store[argc] = 0;
  801b63:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801b69:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801b6f:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801b76:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801b7c:	0f 85 8c 00 00 00    	jne    801c0e <spawn+0x242>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801b82:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801b88:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801b8e:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801b91:	89 f8                	mov    %edi,%eax
  801b93:	8b bd 88 fd ff ff    	mov    -0x278(%ebp),%edi
  801b99:	89 78 f8             	mov    %edi,-0x8(%eax)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801b9c:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801ba1:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801ba7:	83 ec 0c             	sub    $0xc,%esp
  801baa:	6a 07                	push   $0x7
  801bac:	68 00 d0 bf ee       	push   $0xeebfd000
  801bb1:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801bb7:	68 00 00 40 00       	push   $0x400000
  801bbc:	6a 00                	push   $0x0
  801bbe:	e8 69 f1 ff ff       	call   800d2c <sys_page_map>
  801bc3:	89 c3                	mov    %eax,%ebx
  801bc5:	83 c4 20             	add    $0x20,%esp
  801bc8:	85 c0                	test   %eax,%eax
  801bca:	0f 88 65 03 00 00    	js     801f35 <spawn+0x569>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801bd0:	83 ec 08             	sub    $0x8,%esp
  801bd3:	68 00 00 40 00       	push   $0x400000
  801bd8:	6a 00                	push   $0x0
  801bda:	e8 8f f1 ff ff       	call   800d6e <sys_page_unmap>
  801bdf:	89 c3                	mov    %eax,%ebx
  801be1:	83 c4 10             	add    $0x10,%esp
  801be4:	85 c0                	test   %eax,%eax
  801be6:	0f 88 49 03 00 00    	js     801f35 <spawn+0x569>
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801bec:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801bf2:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801bf9:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801bff:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801c06:	00 00 00 
  801c09:	e9 56 01 00 00       	jmp    801d64 <spawn+0x398>
	assert(string_store == (char*)UTEMP + PGSIZE);
  801c0e:	68 98 2f 80 00       	push   $0x802f98
  801c13:	68 df 2e 80 00       	push   $0x802edf
  801c18:	68 f2 00 00 00       	push   $0xf2
  801c1d:	68 25 2f 80 00       	push   $0x802f25
  801c22:	e8 cf e5 ff ff       	call   8001f6 <_panic>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801c27:	83 ec 04             	sub    $0x4,%esp
  801c2a:	6a 07                	push   $0x7
  801c2c:	68 00 00 40 00       	push   $0x400000
  801c31:	6a 00                	push   $0x0
  801c33:	e8 b1 f0 ff ff       	call   800ce9 <sys_page_alloc>
  801c38:	83 c4 10             	add    $0x10,%esp
  801c3b:	85 c0                	test   %eax,%eax
  801c3d:	0f 88 87 02 00 00    	js     801eca <spawn+0x4fe>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801c43:	83 ec 08             	sub    $0x8,%esp
  801c46:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801c4c:	01 f0                	add    %esi,%eax
  801c4e:	50                   	push   %eax
  801c4f:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801c55:	e8 b8 f9 ff ff       	call   801612 <seek>
  801c5a:	83 c4 10             	add    $0x10,%esp
  801c5d:	85 c0                	test   %eax,%eax
  801c5f:	0f 88 6c 02 00 00    	js     801ed1 <spawn+0x505>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801c65:	83 ec 04             	sub    $0x4,%esp
  801c68:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801c6e:	29 f0                	sub    %esi,%eax
  801c70:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c75:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801c7a:	0f 47 c1             	cmova  %ecx,%eax
  801c7d:	50                   	push   %eax
  801c7e:	68 00 00 40 00       	push   $0x400000
  801c83:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801c89:	e8 bb f8 ff ff       	call   801549 <readn>
  801c8e:	83 c4 10             	add    $0x10,%esp
  801c91:	85 c0                	test   %eax,%eax
  801c93:	0f 88 3f 02 00 00    	js     801ed8 <spawn+0x50c>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801c99:	83 ec 0c             	sub    $0xc,%esp
  801c9c:	57                   	push   %edi
  801c9d:	03 b5 88 fd ff ff    	add    -0x278(%ebp),%esi
  801ca3:	56                   	push   %esi
  801ca4:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801caa:	68 00 00 40 00       	push   $0x400000
  801caf:	6a 00                	push   $0x0
  801cb1:	e8 76 f0 ff ff       	call   800d2c <sys_page_map>
  801cb6:	83 c4 20             	add    $0x20,%esp
  801cb9:	85 c0                	test   %eax,%eax
  801cbb:	0f 88 80 00 00 00    	js     801d41 <spawn+0x375>
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
  801cc1:	83 ec 08             	sub    $0x8,%esp
  801cc4:	68 00 00 40 00       	push   $0x400000
  801cc9:	6a 00                	push   $0x0
  801ccb:	e8 9e f0 ff ff       	call   800d6e <sys_page_unmap>
  801cd0:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < memsz; i += PGSIZE) {
  801cd3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801cd9:	89 de                	mov    %ebx,%esi
  801cdb:	39 9d 8c fd ff ff    	cmp    %ebx,-0x274(%ebp)
  801ce1:	76 73                	jbe    801d56 <spawn+0x38a>
		if (i >= filesz) {
  801ce3:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  801ce9:	0f 87 38 ff ff ff    	ja     801c27 <spawn+0x25b>
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801cef:	83 ec 04             	sub    $0x4,%esp
  801cf2:	57                   	push   %edi
  801cf3:	03 b5 88 fd ff ff    	add    -0x278(%ebp),%esi
  801cf9:	56                   	push   %esi
  801cfa:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801d00:	e8 e4 ef ff ff       	call   800ce9 <sys_page_alloc>
  801d05:	83 c4 10             	add    $0x10,%esp
  801d08:	85 c0                	test   %eax,%eax
  801d0a:	79 c7                	jns    801cd3 <spawn+0x307>
  801d0c:	89 c7                	mov    %eax,%edi
	sys_env_destroy(child);
  801d0e:	83 ec 0c             	sub    $0xc,%esp
  801d11:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801d17:	e8 4e ef ff ff       	call   800c6a <sys_env_destroy>
	close(fd);
  801d1c:	83 c4 04             	add    $0x4,%esp
  801d1f:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801d25:	e8 5c f6 ff ff       	call   801386 <close>
	return r;
  801d2a:	83 c4 10             	add    $0x10,%esp
  801d2d:	89 bd 90 fd ff ff    	mov    %edi,-0x270(%ebp)
}
  801d33:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801d39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d3c:	5b                   	pop    %ebx
  801d3d:	5e                   	pop    %esi
  801d3e:	5f                   	pop    %edi
  801d3f:	5d                   	pop    %ebp
  801d40:	c3                   	ret    
				panic("spawn: sys_page_map data: %e", r);
  801d41:	50                   	push   %eax
  801d42:	68 31 2f 80 00       	push   $0x802f31
  801d47:	68 25 01 00 00       	push   $0x125
  801d4c:	68 25 2f 80 00       	push   $0x802f25
  801d51:	e8 a0 e4 ff ff       	call   8001f6 <_panic>
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801d56:	83 85 7c fd ff ff 01 	addl   $0x1,-0x284(%ebp)
  801d5d:	83 85 78 fd ff ff 20 	addl   $0x20,-0x288(%ebp)
  801d64:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801d6b:	3b 85 7c fd ff ff    	cmp    -0x284(%ebp),%eax
  801d71:	7e 71                	jle    801de4 <spawn+0x418>
		if (ph->p_type != ELF_PROG_LOAD)
  801d73:	8b 8d 78 fd ff ff    	mov    -0x288(%ebp),%ecx
  801d79:	83 39 01             	cmpl   $0x1,(%ecx)
  801d7c:	75 d8                	jne    801d56 <spawn+0x38a>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801d7e:	8b 41 18             	mov    0x18(%ecx),%eax
  801d81:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801d84:	83 f8 01             	cmp    $0x1,%eax
  801d87:	19 ff                	sbb    %edi,%edi
  801d89:	83 e7 fe             	and    $0xfffffffe,%edi
  801d8c:	83 c7 07             	add    $0x7,%edi
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801d8f:	8b 71 04             	mov    0x4(%ecx),%esi
  801d92:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  801d98:	8b 59 10             	mov    0x10(%ecx),%ebx
  801d9b:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801da1:	8b 41 14             	mov    0x14(%ecx),%eax
  801da4:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801daa:	8b 51 08             	mov    0x8(%ecx),%edx
  801dad:	89 95 88 fd ff ff    	mov    %edx,-0x278(%ebp)
	if ((i = PGOFF(va))) {
  801db3:	89 d0                	mov    %edx,%eax
  801db5:	25 ff 0f 00 00       	and    $0xfff,%eax
  801dba:	74 1e                	je     801dda <spawn+0x40e>
		va -= i;
  801dbc:	29 c2                	sub    %eax,%edx
  801dbe:	89 95 88 fd ff ff    	mov    %edx,-0x278(%ebp)
		memsz += i;
  801dc4:	01 85 8c fd ff ff    	add    %eax,-0x274(%ebp)
		filesz += i;
  801dca:	01 c3                	add    %eax,%ebx
  801dcc:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
		fileoffset -= i;
  801dd2:	29 c6                	sub    %eax,%esi
  801dd4:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
	for (i = 0; i < memsz; i += PGSIZE) {
  801dda:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ddf:	e9 f5 fe ff ff       	jmp    801cd9 <spawn+0x30d>
	close(fd);
  801de4:	83 ec 0c             	sub    $0xc,%esp
  801de7:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801ded:	e8 94 f5 ff ff       	call   801386 <close>
  801df2:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	uintptr_t addr;
	int r;

	for(addr=(uintptr_t)UTEXT; addr<USTACKTOP;addr+=PGSIZE){
  801df5:	bb 00 00 80 00       	mov    $0x800000,%ebx
  801dfa:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
  801e00:	eb 12                	jmp    801e14 <spawn+0x448>
  801e02:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801e08:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801e0e:	0f 84 cb 00 00 00    	je     801edf <spawn+0x513>
	   if((uvpd[PDX(addr)]&PTE_P) && (uvpt[PGNUM(addr)]&PTE_P)){
  801e14:	89 d8                	mov    %ebx,%eax
  801e16:	c1 e8 16             	shr    $0x16,%eax
  801e19:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801e20:	a8 01                	test   $0x1,%al
  801e22:	74 de                	je     801e02 <spawn+0x436>
  801e24:	89 d8                	mov    %ebx,%eax
  801e26:	c1 e8 0c             	shr    $0xc,%eax
  801e29:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801e30:	f6 c2 01             	test   $0x1,%dl
  801e33:	74 cd                	je     801e02 <spawn+0x436>
	      if(uvpt[PGNUM(addr)] & PTE_SHARE){
  801e35:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801e3c:	f6 c6 04             	test   $0x4,%dh
  801e3f:	74 c1                	je     801e02 <spawn+0x436>
	        if((r=sys_page_map(thisenv->env_id,(void *)addr,child,(void *)addr, uvpt[PGNUM(addr)]&PTE_SYSCALL))<0)
  801e41:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801e48:	8b 15 04 50 80 00    	mov    0x805004,%edx
  801e4e:	8b 52 48             	mov    0x48(%edx),%edx
  801e51:	83 ec 0c             	sub    $0xc,%esp
  801e54:	25 07 0e 00 00       	and    $0xe07,%eax
  801e59:	50                   	push   %eax
  801e5a:	53                   	push   %ebx
  801e5b:	56                   	push   %esi
  801e5c:	53                   	push   %ebx
  801e5d:	52                   	push   %edx
  801e5e:	e8 c9 ee ff ff       	call   800d2c <sys_page_map>
  801e63:	83 c4 20             	add    $0x20,%esp
  801e66:	85 c0                	test   %eax,%eax
  801e68:	79 98                	jns    801e02 <spawn+0x436>
		panic("copy_shared_pages: %e", r);
  801e6a:	50                   	push   %eax
  801e6b:	68 7f 2f 80 00       	push   $0x802f7f
  801e70:	68 82 00 00 00       	push   $0x82
  801e75:	68 25 2f 80 00       	push   $0x802f25
  801e7a:	e8 77 e3 ff ff       	call   8001f6 <_panic>
		panic("sys_env_set_trapframe: %e", r);
  801e7f:	50                   	push   %eax
  801e80:	68 4e 2f 80 00       	push   $0x802f4e
  801e85:	68 86 00 00 00       	push   $0x86
  801e8a:	68 25 2f 80 00       	push   $0x802f25
  801e8f:	e8 62 e3 ff ff       	call   8001f6 <_panic>
		panic("sys_env_set_status: %e", r);
  801e94:	50                   	push   %eax
  801e95:	68 68 2f 80 00       	push   $0x802f68
  801e9a:	68 89 00 00 00       	push   $0x89
  801e9f:	68 25 2f 80 00       	push   $0x802f25
  801ea4:	e8 4d e3 ff ff       	call   8001f6 <_panic>
		return r;
  801ea9:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801eaf:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  801eb5:	e9 79 fe ff ff       	jmp    801d33 <spawn+0x367>
		return -E_NO_MEM;
  801eba:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return r;
  801ebf:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  801ec5:	e9 69 fe ff ff       	jmp    801d33 <spawn+0x367>
  801eca:	89 c7                	mov    %eax,%edi
  801ecc:	e9 3d fe ff ff       	jmp    801d0e <spawn+0x342>
  801ed1:	89 c7                	mov    %eax,%edi
  801ed3:	e9 36 fe ff ff       	jmp    801d0e <spawn+0x342>
  801ed8:	89 c7                	mov    %eax,%edi
  801eda:	e9 2f fe ff ff       	jmp    801d0e <spawn+0x342>
	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801edf:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801ee6:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801ee9:	83 ec 08             	sub    $0x8,%esp
  801eec:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801ef2:	50                   	push   %eax
  801ef3:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801ef9:	e8 f4 ee ff ff       	call   800df2 <sys_env_set_trapframe>
  801efe:	83 c4 10             	add    $0x10,%esp
  801f01:	85 c0                	test   %eax,%eax
  801f03:	0f 88 76 ff ff ff    	js     801e7f <spawn+0x4b3>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801f09:	83 ec 08             	sub    $0x8,%esp
  801f0c:	6a 02                	push   $0x2
  801f0e:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801f14:	e8 97 ee ff ff       	call   800db0 <sys_env_set_status>
  801f19:	83 c4 10             	add    $0x10,%esp
  801f1c:	85 c0                	test   %eax,%eax
  801f1e:	0f 88 70 ff ff ff    	js     801e94 <spawn+0x4c8>
	return child;
  801f24:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801f2a:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  801f30:	e9 fe fd ff ff       	jmp    801d33 <spawn+0x367>
	sys_page_unmap(0, UTEMP);
  801f35:	83 ec 08             	sub    $0x8,%esp
  801f38:	68 00 00 40 00       	push   $0x400000
  801f3d:	6a 00                	push   $0x0
  801f3f:	e8 2a ee ff ff       	call   800d6e <sys_page_unmap>
  801f44:	83 c4 10             	add    $0x10,%esp
  801f47:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801f4d:	e9 e1 fd ff ff       	jmp    801d33 <spawn+0x367>

00801f52 <spawnl>:
{
  801f52:	55                   	push   %ebp
  801f53:	89 e5                	mov    %esp,%ebp
  801f55:	57                   	push   %edi
  801f56:	56                   	push   %esi
  801f57:	53                   	push   %ebx
  801f58:	83 ec 0c             	sub    $0xc,%esp
	va_start(vl, arg0);
  801f5b:	8d 55 10             	lea    0x10(%ebp),%edx
	int argc=0;
  801f5e:	b8 00 00 00 00       	mov    $0x0,%eax
	while(va_arg(vl, void *) != NULL)
  801f63:	eb 05                	jmp    801f6a <spawnl+0x18>
		argc++;
  801f65:	83 c0 01             	add    $0x1,%eax
	while(va_arg(vl, void *) != NULL)
  801f68:	89 ca                	mov    %ecx,%edx
  801f6a:	8d 4a 04             	lea    0x4(%edx),%ecx
  801f6d:	83 3a 00             	cmpl   $0x0,(%edx)
  801f70:	75 f3                	jne    801f65 <spawnl+0x13>
	const char *argv[argc+2];
  801f72:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801f79:	83 e2 f0             	and    $0xfffffff0,%edx
  801f7c:	29 d4                	sub    %edx,%esp
  801f7e:	8d 54 24 03          	lea    0x3(%esp),%edx
  801f82:	c1 ea 02             	shr    $0x2,%edx
  801f85:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801f8c:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801f8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f91:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801f98:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801f9f:	00 
	va_start(vl, arg0);
  801fa0:	8d 4d 10             	lea    0x10(%ebp),%ecx
  801fa3:	89 c2                	mov    %eax,%edx
	for(i=0;i<argc;i++)
  801fa5:	b8 00 00 00 00       	mov    $0x0,%eax
  801faa:	eb 0b                	jmp    801fb7 <spawnl+0x65>
		argv[i+1] = va_arg(vl, const char *);
  801fac:	83 c0 01             	add    $0x1,%eax
  801faf:	8b 39                	mov    (%ecx),%edi
  801fb1:	89 3c 83             	mov    %edi,(%ebx,%eax,4)
  801fb4:	8d 49 04             	lea    0x4(%ecx),%ecx
	for(i=0;i<argc;i++)
  801fb7:	39 d0                	cmp    %edx,%eax
  801fb9:	75 f1                	jne    801fac <spawnl+0x5a>
	return spawn(prog, argv);
  801fbb:	83 ec 08             	sub    $0x8,%esp
  801fbe:	56                   	push   %esi
  801fbf:	ff 75 08             	pushl  0x8(%ebp)
  801fc2:	e8 05 fa ff ff       	call   8019cc <spawn>
}
  801fc7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fca:	5b                   	pop    %ebx
  801fcb:	5e                   	pop    %esi
  801fcc:	5f                   	pop    %edi
  801fcd:	5d                   	pop    %ebp
  801fce:	c3                   	ret    

00801fcf <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801fcf:	55                   	push   %ebp
  801fd0:	89 e5                	mov    %esp,%ebp
  801fd2:	56                   	push   %esi
  801fd3:	53                   	push   %ebx
  801fd4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801fd7:	83 ec 0c             	sub    $0xc,%esp
  801fda:	ff 75 08             	pushl  0x8(%ebp)
  801fdd:	e8 09 f2 ff ff       	call   8011eb <fd2data>
  801fe2:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801fe4:	83 c4 08             	add    $0x8,%esp
  801fe7:	68 c0 2f 80 00       	push   $0x802fc0
  801fec:	53                   	push   %ebx
  801fed:	e8 fe e8 ff ff       	call   8008f0 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ff2:	8b 46 04             	mov    0x4(%esi),%eax
  801ff5:	2b 06                	sub    (%esi),%eax
  801ff7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ffd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802004:	00 00 00 
	stat->st_dev = &devpipe;
  802007:	c7 83 88 00 00 00 28 	movl   $0x804028,0x88(%ebx)
  80200e:	40 80 00 
	return 0;
}
  802011:	b8 00 00 00 00       	mov    $0x0,%eax
  802016:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802019:	5b                   	pop    %ebx
  80201a:	5e                   	pop    %esi
  80201b:	5d                   	pop    %ebp
  80201c:	c3                   	ret    

0080201d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80201d:	55                   	push   %ebp
  80201e:	89 e5                	mov    %esp,%ebp
  802020:	53                   	push   %ebx
  802021:	83 ec 0c             	sub    $0xc,%esp
  802024:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802027:	53                   	push   %ebx
  802028:	6a 00                	push   $0x0
  80202a:	e8 3f ed ff ff       	call   800d6e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80202f:	89 1c 24             	mov    %ebx,(%esp)
  802032:	e8 b4 f1 ff ff       	call   8011eb <fd2data>
  802037:	83 c4 08             	add    $0x8,%esp
  80203a:	50                   	push   %eax
  80203b:	6a 00                	push   $0x0
  80203d:	e8 2c ed ff ff       	call   800d6e <sys_page_unmap>
}
  802042:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802045:	c9                   	leave  
  802046:	c3                   	ret    

00802047 <_pipeisclosed>:
{
  802047:	55                   	push   %ebp
  802048:	89 e5                	mov    %esp,%ebp
  80204a:	57                   	push   %edi
  80204b:	56                   	push   %esi
  80204c:	53                   	push   %ebx
  80204d:	83 ec 1c             	sub    $0x1c,%esp
  802050:	89 c7                	mov    %eax,%edi
  802052:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  802054:	a1 04 50 80 00       	mov    0x805004,%eax
  802059:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80205c:	83 ec 0c             	sub    $0xc,%esp
  80205f:	57                   	push   %edi
  802060:	e8 13 06 00 00       	call   802678 <pageref>
  802065:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  802068:	89 34 24             	mov    %esi,(%esp)
  80206b:	e8 08 06 00 00       	call   802678 <pageref>
		nn = thisenv->env_runs;
  802070:	8b 15 04 50 80 00    	mov    0x805004,%edx
  802076:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802079:	83 c4 10             	add    $0x10,%esp
  80207c:	39 cb                	cmp    %ecx,%ebx
  80207e:	74 1b                	je     80209b <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  802080:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802083:	75 cf                	jne    802054 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802085:	8b 42 58             	mov    0x58(%edx),%eax
  802088:	6a 01                	push   $0x1
  80208a:	50                   	push   %eax
  80208b:	53                   	push   %ebx
  80208c:	68 c7 2f 80 00       	push   $0x802fc7
  802091:	e8 3b e2 ff ff       	call   8002d1 <cprintf>
  802096:	83 c4 10             	add    $0x10,%esp
  802099:	eb b9                	jmp    802054 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  80209b:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80209e:	0f 94 c0             	sete   %al
  8020a1:	0f b6 c0             	movzbl %al,%eax
}
  8020a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020a7:	5b                   	pop    %ebx
  8020a8:	5e                   	pop    %esi
  8020a9:	5f                   	pop    %edi
  8020aa:	5d                   	pop    %ebp
  8020ab:	c3                   	ret    

008020ac <devpipe_write>:
{
  8020ac:	55                   	push   %ebp
  8020ad:	89 e5                	mov    %esp,%ebp
  8020af:	57                   	push   %edi
  8020b0:	56                   	push   %esi
  8020b1:	53                   	push   %ebx
  8020b2:	83 ec 28             	sub    $0x28,%esp
  8020b5:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8020b8:	56                   	push   %esi
  8020b9:	e8 2d f1 ff ff       	call   8011eb <fd2data>
  8020be:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8020c0:	83 c4 10             	add    $0x10,%esp
  8020c3:	bf 00 00 00 00       	mov    $0x0,%edi
  8020c8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8020cb:	74 4f                	je     80211c <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8020cd:	8b 43 04             	mov    0x4(%ebx),%eax
  8020d0:	8b 0b                	mov    (%ebx),%ecx
  8020d2:	8d 51 20             	lea    0x20(%ecx),%edx
  8020d5:	39 d0                	cmp    %edx,%eax
  8020d7:	72 14                	jb     8020ed <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  8020d9:	89 da                	mov    %ebx,%edx
  8020db:	89 f0                	mov    %esi,%eax
  8020dd:	e8 65 ff ff ff       	call   802047 <_pipeisclosed>
  8020e2:	85 c0                	test   %eax,%eax
  8020e4:	75 3a                	jne    802120 <devpipe_write+0x74>
			sys_yield();
  8020e6:	e8 df eb ff ff       	call   800cca <sys_yield>
  8020eb:	eb e0                	jmp    8020cd <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8020ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020f0:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8020f4:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8020f7:	89 c2                	mov    %eax,%edx
  8020f9:	c1 fa 1f             	sar    $0x1f,%edx
  8020fc:	89 d1                	mov    %edx,%ecx
  8020fe:	c1 e9 1b             	shr    $0x1b,%ecx
  802101:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802104:	83 e2 1f             	and    $0x1f,%edx
  802107:	29 ca                	sub    %ecx,%edx
  802109:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80210d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802111:	83 c0 01             	add    $0x1,%eax
  802114:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  802117:	83 c7 01             	add    $0x1,%edi
  80211a:	eb ac                	jmp    8020c8 <devpipe_write+0x1c>
	return i;
  80211c:	89 f8                	mov    %edi,%eax
  80211e:	eb 05                	jmp    802125 <devpipe_write+0x79>
				return 0;
  802120:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802125:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802128:	5b                   	pop    %ebx
  802129:	5e                   	pop    %esi
  80212a:	5f                   	pop    %edi
  80212b:	5d                   	pop    %ebp
  80212c:	c3                   	ret    

0080212d <devpipe_read>:
{
  80212d:	55                   	push   %ebp
  80212e:	89 e5                	mov    %esp,%ebp
  802130:	57                   	push   %edi
  802131:	56                   	push   %esi
  802132:	53                   	push   %ebx
  802133:	83 ec 18             	sub    $0x18,%esp
  802136:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  802139:	57                   	push   %edi
  80213a:	e8 ac f0 ff ff       	call   8011eb <fd2data>
  80213f:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802141:	83 c4 10             	add    $0x10,%esp
  802144:	be 00 00 00 00       	mov    $0x0,%esi
  802149:	3b 75 10             	cmp    0x10(%ebp),%esi
  80214c:	74 47                	je     802195 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  80214e:	8b 03                	mov    (%ebx),%eax
  802150:	3b 43 04             	cmp    0x4(%ebx),%eax
  802153:	75 22                	jne    802177 <devpipe_read+0x4a>
			if (i > 0)
  802155:	85 f6                	test   %esi,%esi
  802157:	75 14                	jne    80216d <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  802159:	89 da                	mov    %ebx,%edx
  80215b:	89 f8                	mov    %edi,%eax
  80215d:	e8 e5 fe ff ff       	call   802047 <_pipeisclosed>
  802162:	85 c0                	test   %eax,%eax
  802164:	75 33                	jne    802199 <devpipe_read+0x6c>
			sys_yield();
  802166:	e8 5f eb ff ff       	call   800cca <sys_yield>
  80216b:	eb e1                	jmp    80214e <devpipe_read+0x21>
				return i;
  80216d:	89 f0                	mov    %esi,%eax
}
  80216f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802172:	5b                   	pop    %ebx
  802173:	5e                   	pop    %esi
  802174:	5f                   	pop    %edi
  802175:	5d                   	pop    %ebp
  802176:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802177:	99                   	cltd   
  802178:	c1 ea 1b             	shr    $0x1b,%edx
  80217b:	01 d0                	add    %edx,%eax
  80217d:	83 e0 1f             	and    $0x1f,%eax
  802180:	29 d0                	sub    %edx,%eax
  802182:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802187:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80218a:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  80218d:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  802190:	83 c6 01             	add    $0x1,%esi
  802193:	eb b4                	jmp    802149 <devpipe_read+0x1c>
	return i;
  802195:	89 f0                	mov    %esi,%eax
  802197:	eb d6                	jmp    80216f <devpipe_read+0x42>
				return 0;
  802199:	b8 00 00 00 00       	mov    $0x0,%eax
  80219e:	eb cf                	jmp    80216f <devpipe_read+0x42>

008021a0 <pipe>:
{
  8021a0:	55                   	push   %ebp
  8021a1:	89 e5                	mov    %esp,%ebp
  8021a3:	56                   	push   %esi
  8021a4:	53                   	push   %ebx
  8021a5:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8021a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021ab:	50                   	push   %eax
  8021ac:	e8 51 f0 ff ff       	call   801202 <fd_alloc>
  8021b1:	89 c3                	mov    %eax,%ebx
  8021b3:	83 c4 10             	add    $0x10,%esp
  8021b6:	85 c0                	test   %eax,%eax
  8021b8:	78 5b                	js     802215 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021ba:	83 ec 04             	sub    $0x4,%esp
  8021bd:	68 07 04 00 00       	push   $0x407
  8021c2:	ff 75 f4             	pushl  -0xc(%ebp)
  8021c5:	6a 00                	push   $0x0
  8021c7:	e8 1d eb ff ff       	call   800ce9 <sys_page_alloc>
  8021cc:	89 c3                	mov    %eax,%ebx
  8021ce:	83 c4 10             	add    $0x10,%esp
  8021d1:	85 c0                	test   %eax,%eax
  8021d3:	78 40                	js     802215 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  8021d5:	83 ec 0c             	sub    $0xc,%esp
  8021d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8021db:	50                   	push   %eax
  8021dc:	e8 21 f0 ff ff       	call   801202 <fd_alloc>
  8021e1:	89 c3                	mov    %eax,%ebx
  8021e3:	83 c4 10             	add    $0x10,%esp
  8021e6:	85 c0                	test   %eax,%eax
  8021e8:	78 1b                	js     802205 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021ea:	83 ec 04             	sub    $0x4,%esp
  8021ed:	68 07 04 00 00       	push   $0x407
  8021f2:	ff 75 f0             	pushl  -0x10(%ebp)
  8021f5:	6a 00                	push   $0x0
  8021f7:	e8 ed ea ff ff       	call   800ce9 <sys_page_alloc>
  8021fc:	89 c3                	mov    %eax,%ebx
  8021fe:	83 c4 10             	add    $0x10,%esp
  802201:	85 c0                	test   %eax,%eax
  802203:	79 19                	jns    80221e <pipe+0x7e>
	sys_page_unmap(0, fd0);
  802205:	83 ec 08             	sub    $0x8,%esp
  802208:	ff 75 f4             	pushl  -0xc(%ebp)
  80220b:	6a 00                	push   $0x0
  80220d:	e8 5c eb ff ff       	call   800d6e <sys_page_unmap>
  802212:	83 c4 10             	add    $0x10,%esp
}
  802215:	89 d8                	mov    %ebx,%eax
  802217:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80221a:	5b                   	pop    %ebx
  80221b:	5e                   	pop    %esi
  80221c:	5d                   	pop    %ebp
  80221d:	c3                   	ret    
	va = fd2data(fd0);
  80221e:	83 ec 0c             	sub    $0xc,%esp
  802221:	ff 75 f4             	pushl  -0xc(%ebp)
  802224:	e8 c2 ef ff ff       	call   8011eb <fd2data>
  802229:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80222b:	83 c4 0c             	add    $0xc,%esp
  80222e:	68 07 04 00 00       	push   $0x407
  802233:	50                   	push   %eax
  802234:	6a 00                	push   $0x0
  802236:	e8 ae ea ff ff       	call   800ce9 <sys_page_alloc>
  80223b:	89 c3                	mov    %eax,%ebx
  80223d:	83 c4 10             	add    $0x10,%esp
  802240:	85 c0                	test   %eax,%eax
  802242:	0f 88 8c 00 00 00    	js     8022d4 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802248:	83 ec 0c             	sub    $0xc,%esp
  80224b:	ff 75 f0             	pushl  -0x10(%ebp)
  80224e:	e8 98 ef ff ff       	call   8011eb <fd2data>
  802253:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80225a:	50                   	push   %eax
  80225b:	6a 00                	push   $0x0
  80225d:	56                   	push   %esi
  80225e:	6a 00                	push   $0x0
  802260:	e8 c7 ea ff ff       	call   800d2c <sys_page_map>
  802265:	89 c3                	mov    %eax,%ebx
  802267:	83 c4 20             	add    $0x20,%esp
  80226a:	85 c0                	test   %eax,%eax
  80226c:	78 58                	js     8022c6 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  80226e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802271:	8b 15 28 40 80 00    	mov    0x804028,%edx
  802277:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802279:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80227c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  802283:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802286:	8b 15 28 40 80 00    	mov    0x804028,%edx
  80228c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80228e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802291:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  802298:	83 ec 0c             	sub    $0xc,%esp
  80229b:	ff 75 f4             	pushl  -0xc(%ebp)
  80229e:	e8 38 ef ff ff       	call   8011db <fd2num>
  8022a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8022a6:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8022a8:	83 c4 04             	add    $0x4,%esp
  8022ab:	ff 75 f0             	pushl  -0x10(%ebp)
  8022ae:	e8 28 ef ff ff       	call   8011db <fd2num>
  8022b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8022b6:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8022b9:	83 c4 10             	add    $0x10,%esp
  8022bc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8022c1:	e9 4f ff ff ff       	jmp    802215 <pipe+0x75>
	sys_page_unmap(0, va);
  8022c6:	83 ec 08             	sub    $0x8,%esp
  8022c9:	56                   	push   %esi
  8022ca:	6a 00                	push   $0x0
  8022cc:	e8 9d ea ff ff       	call   800d6e <sys_page_unmap>
  8022d1:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8022d4:	83 ec 08             	sub    $0x8,%esp
  8022d7:	ff 75 f0             	pushl  -0x10(%ebp)
  8022da:	6a 00                	push   $0x0
  8022dc:	e8 8d ea ff ff       	call   800d6e <sys_page_unmap>
  8022e1:	83 c4 10             	add    $0x10,%esp
  8022e4:	e9 1c ff ff ff       	jmp    802205 <pipe+0x65>

008022e9 <pipeisclosed>:
{
  8022e9:	55                   	push   %ebp
  8022ea:	89 e5                	mov    %esp,%ebp
  8022ec:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022f2:	50                   	push   %eax
  8022f3:	ff 75 08             	pushl  0x8(%ebp)
  8022f6:	e8 56 ef ff ff       	call   801251 <fd_lookup>
  8022fb:	83 c4 10             	add    $0x10,%esp
  8022fe:	85 c0                	test   %eax,%eax
  802300:	78 18                	js     80231a <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  802302:	83 ec 0c             	sub    $0xc,%esp
  802305:	ff 75 f4             	pushl  -0xc(%ebp)
  802308:	e8 de ee ff ff       	call   8011eb <fd2data>
	return _pipeisclosed(fd, p);
  80230d:	89 c2                	mov    %eax,%edx
  80230f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802312:	e8 30 fd ff ff       	call   802047 <_pipeisclosed>
  802317:	83 c4 10             	add    $0x10,%esp
}
  80231a:	c9                   	leave  
  80231b:	c3                   	ret    

0080231c <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  80231c:	55                   	push   %ebp
  80231d:	89 e5                	mov    %esp,%ebp
  80231f:	56                   	push   %esi
  802320:	53                   	push   %ebx
  802321:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802324:	85 f6                	test   %esi,%esi
  802326:	74 13                	je     80233b <wait+0x1f>
	e = &envs[ENVX(envid)];
  802328:	89 f3                	mov    %esi,%ebx
  80232a:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802330:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802333:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802339:	eb 1b                	jmp    802356 <wait+0x3a>
	assert(envid != 0);
  80233b:	68 df 2f 80 00       	push   $0x802fdf
  802340:	68 df 2e 80 00       	push   $0x802edf
  802345:	6a 09                	push   $0x9
  802347:	68 ea 2f 80 00       	push   $0x802fea
  80234c:	e8 a5 de ff ff       	call   8001f6 <_panic>
		sys_yield();
  802351:	e8 74 e9 ff ff       	call   800cca <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802356:	8b 43 48             	mov    0x48(%ebx),%eax
  802359:	39 f0                	cmp    %esi,%eax
  80235b:	75 07                	jne    802364 <wait+0x48>
  80235d:	8b 43 54             	mov    0x54(%ebx),%eax
  802360:	85 c0                	test   %eax,%eax
  802362:	75 ed                	jne    802351 <wait+0x35>
}
  802364:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802367:	5b                   	pop    %ebx
  802368:	5e                   	pop    %esi
  802369:	5d                   	pop    %ebp
  80236a:	c3                   	ret    

0080236b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80236b:	55                   	push   %ebp
  80236c:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80236e:	b8 00 00 00 00       	mov    $0x0,%eax
  802373:	5d                   	pop    %ebp
  802374:	c3                   	ret    

00802375 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802375:	55                   	push   %ebp
  802376:	89 e5                	mov    %esp,%ebp
  802378:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80237b:	68 f5 2f 80 00       	push   $0x802ff5
  802380:	ff 75 0c             	pushl  0xc(%ebp)
  802383:	e8 68 e5 ff ff       	call   8008f0 <strcpy>
	return 0;
}
  802388:	b8 00 00 00 00       	mov    $0x0,%eax
  80238d:	c9                   	leave  
  80238e:	c3                   	ret    

0080238f <devcons_write>:
{
  80238f:	55                   	push   %ebp
  802390:	89 e5                	mov    %esp,%ebp
  802392:	57                   	push   %edi
  802393:	56                   	push   %esi
  802394:	53                   	push   %ebx
  802395:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  80239b:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8023a0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8023a6:	eb 2f                	jmp    8023d7 <devcons_write+0x48>
		m = n - tot;
  8023a8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8023ab:	29 f3                	sub    %esi,%ebx
  8023ad:	83 fb 7f             	cmp    $0x7f,%ebx
  8023b0:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8023b5:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8023b8:	83 ec 04             	sub    $0x4,%esp
  8023bb:	53                   	push   %ebx
  8023bc:	89 f0                	mov    %esi,%eax
  8023be:	03 45 0c             	add    0xc(%ebp),%eax
  8023c1:	50                   	push   %eax
  8023c2:	57                   	push   %edi
  8023c3:	e8 b6 e6 ff ff       	call   800a7e <memmove>
		sys_cputs(buf, m);
  8023c8:	83 c4 08             	add    $0x8,%esp
  8023cb:	53                   	push   %ebx
  8023cc:	57                   	push   %edi
  8023cd:	e8 5b e8 ff ff       	call   800c2d <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8023d2:	01 de                	add    %ebx,%esi
  8023d4:	83 c4 10             	add    $0x10,%esp
  8023d7:	3b 75 10             	cmp    0x10(%ebp),%esi
  8023da:	72 cc                	jb     8023a8 <devcons_write+0x19>
}
  8023dc:	89 f0                	mov    %esi,%eax
  8023de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023e1:	5b                   	pop    %ebx
  8023e2:	5e                   	pop    %esi
  8023e3:	5f                   	pop    %edi
  8023e4:	5d                   	pop    %ebp
  8023e5:	c3                   	ret    

008023e6 <devcons_read>:
{
  8023e6:	55                   	push   %ebp
  8023e7:	89 e5                	mov    %esp,%ebp
  8023e9:	83 ec 08             	sub    $0x8,%esp
  8023ec:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8023f1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8023f5:	75 07                	jne    8023fe <devcons_read+0x18>
}
  8023f7:	c9                   	leave  
  8023f8:	c3                   	ret    
		sys_yield();
  8023f9:	e8 cc e8 ff ff       	call   800cca <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8023fe:	e8 48 e8 ff ff       	call   800c4b <sys_cgetc>
  802403:	85 c0                	test   %eax,%eax
  802405:	74 f2                	je     8023f9 <devcons_read+0x13>
	if (c < 0)
  802407:	85 c0                	test   %eax,%eax
  802409:	78 ec                	js     8023f7 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  80240b:	83 f8 04             	cmp    $0x4,%eax
  80240e:	74 0c                	je     80241c <devcons_read+0x36>
	*(char*)vbuf = c;
  802410:	8b 55 0c             	mov    0xc(%ebp),%edx
  802413:	88 02                	mov    %al,(%edx)
	return 1;
  802415:	b8 01 00 00 00       	mov    $0x1,%eax
  80241a:	eb db                	jmp    8023f7 <devcons_read+0x11>
		return 0;
  80241c:	b8 00 00 00 00       	mov    $0x0,%eax
  802421:	eb d4                	jmp    8023f7 <devcons_read+0x11>

00802423 <cputchar>:
{
  802423:	55                   	push   %ebp
  802424:	89 e5                	mov    %esp,%ebp
  802426:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802429:	8b 45 08             	mov    0x8(%ebp),%eax
  80242c:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  80242f:	6a 01                	push   $0x1
  802431:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802434:	50                   	push   %eax
  802435:	e8 f3 e7 ff ff       	call   800c2d <sys_cputs>
}
  80243a:	83 c4 10             	add    $0x10,%esp
  80243d:	c9                   	leave  
  80243e:	c3                   	ret    

0080243f <getchar>:
{
  80243f:	55                   	push   %ebp
  802440:	89 e5                	mov    %esp,%ebp
  802442:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802445:	6a 01                	push   $0x1
  802447:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80244a:	50                   	push   %eax
  80244b:	6a 00                	push   $0x0
  80244d:	e8 70 f0 ff ff       	call   8014c2 <read>
	if (r < 0)
  802452:	83 c4 10             	add    $0x10,%esp
  802455:	85 c0                	test   %eax,%eax
  802457:	78 08                	js     802461 <getchar+0x22>
	if (r < 1)
  802459:	85 c0                	test   %eax,%eax
  80245b:	7e 06                	jle    802463 <getchar+0x24>
	return c;
  80245d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802461:	c9                   	leave  
  802462:	c3                   	ret    
		return -E_EOF;
  802463:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802468:	eb f7                	jmp    802461 <getchar+0x22>

0080246a <iscons>:
{
  80246a:	55                   	push   %ebp
  80246b:	89 e5                	mov    %esp,%ebp
  80246d:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802470:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802473:	50                   	push   %eax
  802474:	ff 75 08             	pushl  0x8(%ebp)
  802477:	e8 d5 ed ff ff       	call   801251 <fd_lookup>
  80247c:	83 c4 10             	add    $0x10,%esp
  80247f:	85 c0                	test   %eax,%eax
  802481:	78 11                	js     802494 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  802483:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802486:	8b 15 44 40 80 00    	mov    0x804044,%edx
  80248c:	39 10                	cmp    %edx,(%eax)
  80248e:	0f 94 c0             	sete   %al
  802491:	0f b6 c0             	movzbl %al,%eax
}
  802494:	c9                   	leave  
  802495:	c3                   	ret    

00802496 <opencons>:
{
  802496:	55                   	push   %ebp
  802497:	89 e5                	mov    %esp,%ebp
  802499:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80249c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80249f:	50                   	push   %eax
  8024a0:	e8 5d ed ff ff       	call   801202 <fd_alloc>
  8024a5:	83 c4 10             	add    $0x10,%esp
  8024a8:	85 c0                	test   %eax,%eax
  8024aa:	78 3a                	js     8024e6 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8024ac:	83 ec 04             	sub    $0x4,%esp
  8024af:	68 07 04 00 00       	push   $0x407
  8024b4:	ff 75 f4             	pushl  -0xc(%ebp)
  8024b7:	6a 00                	push   $0x0
  8024b9:	e8 2b e8 ff ff       	call   800ce9 <sys_page_alloc>
  8024be:	83 c4 10             	add    $0x10,%esp
  8024c1:	85 c0                	test   %eax,%eax
  8024c3:	78 21                	js     8024e6 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8024c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024c8:	8b 15 44 40 80 00    	mov    0x804044,%edx
  8024ce:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8024d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024d3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8024da:	83 ec 0c             	sub    $0xc,%esp
  8024dd:	50                   	push   %eax
  8024de:	e8 f8 ec ff ff       	call   8011db <fd2num>
  8024e3:	83 c4 10             	add    $0x10,%esp
}
  8024e6:	c9                   	leave  
  8024e7:	c3                   	ret    

008024e8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8024e8:	55                   	push   %ebp
  8024e9:	89 e5                	mov    %esp,%ebp
  8024eb:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8024ee:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8024f5:	74 0a                	je     802501 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler %e",r);
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
	}
       
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8024f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8024fa:	a3 00 70 80 00       	mov    %eax,0x807000
}
  8024ff:	c9                   	leave  
  802500:	c3                   	ret    
		if((r=sys_page_alloc(thisenv->env_id,(void *)UXSTACKTOP-PGSIZE,PTE_P|PTE_W|PTE_U))<0)
  802501:	a1 04 50 80 00       	mov    0x805004,%eax
  802506:	8b 40 48             	mov    0x48(%eax),%eax
  802509:	83 ec 04             	sub    $0x4,%esp
  80250c:	6a 07                	push   $0x7
  80250e:	68 00 f0 bf ee       	push   $0xeebff000
  802513:	50                   	push   %eax
  802514:	e8 d0 e7 ff ff       	call   800ce9 <sys_page_alloc>
  802519:	83 c4 10             	add    $0x10,%esp
  80251c:	85 c0                	test   %eax,%eax
  80251e:	78 1b                	js     80253b <set_pgfault_handler+0x53>
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
  802520:	a1 04 50 80 00       	mov    0x805004,%eax
  802525:	8b 40 48             	mov    0x48(%eax),%eax
  802528:	83 ec 08             	sub    $0x8,%esp
  80252b:	68 4d 25 80 00       	push   $0x80254d
  802530:	50                   	push   %eax
  802531:	e8 fe e8 ff ff       	call   800e34 <sys_env_set_pgfault_upcall>
  802536:	83 c4 10             	add    $0x10,%esp
  802539:	eb bc                	jmp    8024f7 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler %e",r);
  80253b:	50                   	push   %eax
  80253c:	68 01 30 80 00       	push   $0x803001
  802541:	6a 22                	push   $0x22
  802543:	68 18 30 80 00       	push   $0x803018
  802548:	e8 a9 dc ff ff       	call   8001f6 <_panic>

0080254d <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80254d:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80254e:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802553:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802555:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 48(%esp), %ebp
  802558:	8b 6c 24 30          	mov    0x30(%esp),%ebp
        subl $4, %ebp
  80255c:	83 ed 04             	sub    $0x4,%ebp
        movl %ebp, 48(%esp)
  80255f:	89 6c 24 30          	mov    %ebp,0x30(%esp)
        movl 40(%esp), %eax
  802563:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl %eax, (%ebp)
  802567:	89 45 00             	mov    %eax,0x0(%ebp)
	// Restore the trap-time registers.  After you do this, you
 	// can no longer modify any general-purpose registers.
 	// LAB 4: Your code here.
        addl $8, %esp
  80256a:	83 c4 08             	add    $0x8,%esp
        popal
  80256d:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $4, %esp
  80256e:	83 c4 04             	add    $0x4,%esp
        popfl
  802571:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  802572:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  802573:	c3                   	ret    

00802574 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802574:	55                   	push   %ebp
  802575:	89 e5                	mov    %esp,%ebp
  802577:	56                   	push   %esi
  802578:	53                   	push   %ebx
  802579:	8b 75 08             	mov    0x8(%ebp),%esi
  80257c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80257f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        //	panic("ipc_recv not implemented");
        int r;
       	if(pg!=NULL){
  802582:	85 c0                	test   %eax,%eax
  802584:	74 3b                	je     8025c1 <ipc_recv+0x4d>
	  r = sys_ipc_recv(pg);
  802586:	83 ec 0c             	sub    $0xc,%esp
  802589:	50                   	push   %eax
  80258a:	e8 0a e9 ff ff       	call   800e99 <sys_ipc_recv>
  80258f:	83 c4 10             	add    $0x10,%esp
	}else
	  r = sys_ipc_recv((void *)UTOP);
	if(r<0){
  802592:	85 c0                	test   %eax,%eax
  802594:	78 3d                	js     8025d3 <ipc_recv+0x5f>
	if(perm_store!=NULL){
		*perm_store = 0;
            }
        	return r;
           }else{
	     if(from_env_store!=NULL)
  802596:	85 f6                	test   %esi,%esi
  802598:	74 0a                	je     8025a4 <ipc_recv+0x30>
		     *from_env_store = thisenv->env_ipc_from;
  80259a:	a1 04 50 80 00       	mov    0x805004,%eax
  80259f:	8b 40 74             	mov    0x74(%eax),%eax
  8025a2:	89 06                	mov    %eax,(%esi)
	     if(perm_store != NULL)
  8025a4:	85 db                	test   %ebx,%ebx
  8025a6:	74 0a                	je     8025b2 <ipc_recv+0x3e>
		     *perm_store = thisenv->env_ipc_perm;
  8025a8:	a1 04 50 80 00       	mov    0x805004,%eax
  8025ad:	8b 40 78             	mov    0x78(%eax),%eax
  8025b0:	89 03                	mov    %eax,(%ebx)
	     return thisenv->env_ipc_value;
  8025b2:	a1 04 50 80 00       	mov    0x805004,%eax
  8025b7:	8b 40 70             	mov    0x70(%eax),%eax
	   }

}
  8025ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8025bd:	5b                   	pop    %ebx
  8025be:	5e                   	pop    %esi
  8025bf:	5d                   	pop    %ebp
  8025c0:	c3                   	ret    
	  r = sys_ipc_recv((void *)UTOP);
  8025c1:	83 ec 0c             	sub    $0xc,%esp
  8025c4:	68 00 00 c0 ee       	push   $0xeec00000
  8025c9:	e8 cb e8 ff ff       	call   800e99 <sys_ipc_recv>
  8025ce:	83 c4 10             	add    $0x10,%esp
  8025d1:	eb bf                	jmp    802592 <ipc_recv+0x1e>
	if(from_env_store!=NULL){
  8025d3:	85 f6                	test   %esi,%esi
  8025d5:	74 06                	je     8025dd <ipc_recv+0x69>
	  *from_env_store = 0;
  8025d7:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if(perm_store!=NULL){
  8025dd:	85 db                	test   %ebx,%ebx
  8025df:	74 d9                	je     8025ba <ipc_recv+0x46>
		*perm_store = 0;
  8025e1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8025e7:	eb d1                	jmp    8025ba <ipc_recv+0x46>

008025e9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8025e9:	55                   	push   %ebp
  8025ea:	89 e5                	mov    %esp,%ebp
  8025ec:	57                   	push   %edi
  8025ed:	56                   	push   %esi
  8025ee:	53                   	push   %ebx
  8025ef:	83 ec 0c             	sub    $0xc,%esp
  8025f2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8025f5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8025f8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if(pg==NULL) pg = (void *)UTOP;
  8025fb:	85 db                	test   %ebx,%ebx
  8025fd:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802602:	0f 44 d8             	cmove  %eax,%ebx
	while((r=sys_ipc_try_send(to_env,val,pg,perm))<0){
  802605:	ff 75 14             	pushl  0x14(%ebp)
  802608:	53                   	push   %ebx
  802609:	56                   	push   %esi
  80260a:	57                   	push   %edi
  80260b:	e8 66 e8 ff ff       	call   800e76 <sys_ipc_try_send>
  802610:	83 c4 10             	add    $0x10,%esp
  802613:	85 c0                	test   %eax,%eax
  802615:	79 20                	jns    802637 <ipc_send+0x4e>
	    if(r!=-E_IPC_NOT_RECV){
  802617:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80261a:	75 07                	jne    802623 <ipc_send+0x3a>
		    panic("ipc_send:send message failed\n");
	    }
	    sys_yield();
  80261c:	e8 a9 e6 ff ff       	call   800cca <sys_yield>
  802621:	eb e2                	jmp    802605 <ipc_send+0x1c>
		    panic("ipc_send:send message failed\n");
  802623:	83 ec 04             	sub    $0x4,%esp
  802626:	68 26 30 80 00       	push   $0x803026
  80262b:	6a 43                	push   $0x43
  80262d:	68 44 30 80 00       	push   $0x803044
  802632:	e8 bf db ff ff       	call   8001f6 <_panic>
	}

}
  802637:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80263a:	5b                   	pop    %ebx
  80263b:	5e                   	pop    %esi
  80263c:	5f                   	pop    %edi
  80263d:	5d                   	pop    %ebp
  80263e:	c3                   	ret    

0080263f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80263f:	55                   	push   %ebp
  802640:	89 e5                	mov    %esp,%ebp
  802642:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802645:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80264a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80264d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802653:	8b 52 50             	mov    0x50(%edx),%edx
  802656:	39 ca                	cmp    %ecx,%edx
  802658:	74 11                	je     80266b <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  80265a:	83 c0 01             	add    $0x1,%eax
  80265d:	3d 00 04 00 00       	cmp    $0x400,%eax
  802662:	75 e6                	jne    80264a <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  802664:	b8 00 00 00 00       	mov    $0x0,%eax
  802669:	eb 0b                	jmp    802676 <ipc_find_env+0x37>
			return envs[i].env_id;
  80266b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80266e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802673:	8b 40 48             	mov    0x48(%eax),%eax
}
  802676:	5d                   	pop    %ebp
  802677:	c3                   	ret    

00802678 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802678:	55                   	push   %ebp
  802679:	89 e5                	mov    %esp,%ebp
  80267b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80267e:	89 d0                	mov    %edx,%eax
  802680:	c1 e8 16             	shr    $0x16,%eax
  802683:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80268a:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  80268f:	f6 c1 01             	test   $0x1,%cl
  802692:	74 1d                	je     8026b1 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  802694:	c1 ea 0c             	shr    $0xc,%edx
  802697:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80269e:	f6 c2 01             	test   $0x1,%dl
  8026a1:	74 0e                	je     8026b1 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8026a3:	c1 ea 0c             	shr    $0xc,%edx
  8026a6:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8026ad:	ef 
  8026ae:	0f b7 c0             	movzwl %ax,%eax
}
  8026b1:	5d                   	pop    %ebp
  8026b2:	c3                   	ret    
  8026b3:	66 90                	xchg   %ax,%ax
  8026b5:	66 90                	xchg   %ax,%ax
  8026b7:	66 90                	xchg   %ax,%ax
  8026b9:	66 90                	xchg   %ax,%ax
  8026bb:	66 90                	xchg   %ax,%ax
  8026bd:	66 90                	xchg   %ax,%ax
  8026bf:	90                   	nop

008026c0 <__udivdi3>:
  8026c0:	55                   	push   %ebp
  8026c1:	57                   	push   %edi
  8026c2:	56                   	push   %esi
  8026c3:	53                   	push   %ebx
  8026c4:	83 ec 1c             	sub    $0x1c,%esp
  8026c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8026cb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8026cf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8026d3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8026d7:	85 d2                	test   %edx,%edx
  8026d9:	75 35                	jne    802710 <__udivdi3+0x50>
  8026db:	39 f3                	cmp    %esi,%ebx
  8026dd:	0f 87 bd 00 00 00    	ja     8027a0 <__udivdi3+0xe0>
  8026e3:	85 db                	test   %ebx,%ebx
  8026e5:	89 d9                	mov    %ebx,%ecx
  8026e7:	75 0b                	jne    8026f4 <__udivdi3+0x34>
  8026e9:	b8 01 00 00 00       	mov    $0x1,%eax
  8026ee:	31 d2                	xor    %edx,%edx
  8026f0:	f7 f3                	div    %ebx
  8026f2:	89 c1                	mov    %eax,%ecx
  8026f4:	31 d2                	xor    %edx,%edx
  8026f6:	89 f0                	mov    %esi,%eax
  8026f8:	f7 f1                	div    %ecx
  8026fa:	89 c6                	mov    %eax,%esi
  8026fc:	89 e8                	mov    %ebp,%eax
  8026fe:	89 f7                	mov    %esi,%edi
  802700:	f7 f1                	div    %ecx
  802702:	89 fa                	mov    %edi,%edx
  802704:	83 c4 1c             	add    $0x1c,%esp
  802707:	5b                   	pop    %ebx
  802708:	5e                   	pop    %esi
  802709:	5f                   	pop    %edi
  80270a:	5d                   	pop    %ebp
  80270b:	c3                   	ret    
  80270c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802710:	39 f2                	cmp    %esi,%edx
  802712:	77 7c                	ja     802790 <__udivdi3+0xd0>
  802714:	0f bd fa             	bsr    %edx,%edi
  802717:	83 f7 1f             	xor    $0x1f,%edi
  80271a:	0f 84 98 00 00 00    	je     8027b8 <__udivdi3+0xf8>
  802720:	89 f9                	mov    %edi,%ecx
  802722:	b8 20 00 00 00       	mov    $0x20,%eax
  802727:	29 f8                	sub    %edi,%eax
  802729:	d3 e2                	shl    %cl,%edx
  80272b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80272f:	89 c1                	mov    %eax,%ecx
  802731:	89 da                	mov    %ebx,%edx
  802733:	d3 ea                	shr    %cl,%edx
  802735:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802739:	09 d1                	or     %edx,%ecx
  80273b:	89 f2                	mov    %esi,%edx
  80273d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802741:	89 f9                	mov    %edi,%ecx
  802743:	d3 e3                	shl    %cl,%ebx
  802745:	89 c1                	mov    %eax,%ecx
  802747:	d3 ea                	shr    %cl,%edx
  802749:	89 f9                	mov    %edi,%ecx
  80274b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80274f:	d3 e6                	shl    %cl,%esi
  802751:	89 eb                	mov    %ebp,%ebx
  802753:	89 c1                	mov    %eax,%ecx
  802755:	d3 eb                	shr    %cl,%ebx
  802757:	09 de                	or     %ebx,%esi
  802759:	89 f0                	mov    %esi,%eax
  80275b:	f7 74 24 08          	divl   0x8(%esp)
  80275f:	89 d6                	mov    %edx,%esi
  802761:	89 c3                	mov    %eax,%ebx
  802763:	f7 64 24 0c          	mull   0xc(%esp)
  802767:	39 d6                	cmp    %edx,%esi
  802769:	72 0c                	jb     802777 <__udivdi3+0xb7>
  80276b:	89 f9                	mov    %edi,%ecx
  80276d:	d3 e5                	shl    %cl,%ebp
  80276f:	39 c5                	cmp    %eax,%ebp
  802771:	73 5d                	jae    8027d0 <__udivdi3+0x110>
  802773:	39 d6                	cmp    %edx,%esi
  802775:	75 59                	jne    8027d0 <__udivdi3+0x110>
  802777:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80277a:	31 ff                	xor    %edi,%edi
  80277c:	89 fa                	mov    %edi,%edx
  80277e:	83 c4 1c             	add    $0x1c,%esp
  802781:	5b                   	pop    %ebx
  802782:	5e                   	pop    %esi
  802783:	5f                   	pop    %edi
  802784:	5d                   	pop    %ebp
  802785:	c3                   	ret    
  802786:	8d 76 00             	lea    0x0(%esi),%esi
  802789:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802790:	31 ff                	xor    %edi,%edi
  802792:	31 c0                	xor    %eax,%eax
  802794:	89 fa                	mov    %edi,%edx
  802796:	83 c4 1c             	add    $0x1c,%esp
  802799:	5b                   	pop    %ebx
  80279a:	5e                   	pop    %esi
  80279b:	5f                   	pop    %edi
  80279c:	5d                   	pop    %ebp
  80279d:	c3                   	ret    
  80279e:	66 90                	xchg   %ax,%ax
  8027a0:	31 ff                	xor    %edi,%edi
  8027a2:	89 e8                	mov    %ebp,%eax
  8027a4:	89 f2                	mov    %esi,%edx
  8027a6:	f7 f3                	div    %ebx
  8027a8:	89 fa                	mov    %edi,%edx
  8027aa:	83 c4 1c             	add    $0x1c,%esp
  8027ad:	5b                   	pop    %ebx
  8027ae:	5e                   	pop    %esi
  8027af:	5f                   	pop    %edi
  8027b0:	5d                   	pop    %ebp
  8027b1:	c3                   	ret    
  8027b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8027b8:	39 f2                	cmp    %esi,%edx
  8027ba:	72 06                	jb     8027c2 <__udivdi3+0x102>
  8027bc:	31 c0                	xor    %eax,%eax
  8027be:	39 eb                	cmp    %ebp,%ebx
  8027c0:	77 d2                	ja     802794 <__udivdi3+0xd4>
  8027c2:	b8 01 00 00 00       	mov    $0x1,%eax
  8027c7:	eb cb                	jmp    802794 <__udivdi3+0xd4>
  8027c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8027d0:	89 d8                	mov    %ebx,%eax
  8027d2:	31 ff                	xor    %edi,%edi
  8027d4:	eb be                	jmp    802794 <__udivdi3+0xd4>
  8027d6:	66 90                	xchg   %ax,%ax
  8027d8:	66 90                	xchg   %ax,%ax
  8027da:	66 90                	xchg   %ax,%ax
  8027dc:	66 90                	xchg   %ax,%ax
  8027de:	66 90                	xchg   %ax,%ax

008027e0 <__umoddi3>:
  8027e0:	55                   	push   %ebp
  8027e1:	57                   	push   %edi
  8027e2:	56                   	push   %esi
  8027e3:	53                   	push   %ebx
  8027e4:	83 ec 1c             	sub    $0x1c,%esp
  8027e7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  8027eb:	8b 74 24 30          	mov    0x30(%esp),%esi
  8027ef:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8027f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8027f7:	85 ed                	test   %ebp,%ebp
  8027f9:	89 f0                	mov    %esi,%eax
  8027fb:	89 da                	mov    %ebx,%edx
  8027fd:	75 19                	jne    802818 <__umoddi3+0x38>
  8027ff:	39 df                	cmp    %ebx,%edi
  802801:	0f 86 b1 00 00 00    	jbe    8028b8 <__umoddi3+0xd8>
  802807:	f7 f7                	div    %edi
  802809:	89 d0                	mov    %edx,%eax
  80280b:	31 d2                	xor    %edx,%edx
  80280d:	83 c4 1c             	add    $0x1c,%esp
  802810:	5b                   	pop    %ebx
  802811:	5e                   	pop    %esi
  802812:	5f                   	pop    %edi
  802813:	5d                   	pop    %ebp
  802814:	c3                   	ret    
  802815:	8d 76 00             	lea    0x0(%esi),%esi
  802818:	39 dd                	cmp    %ebx,%ebp
  80281a:	77 f1                	ja     80280d <__umoddi3+0x2d>
  80281c:	0f bd cd             	bsr    %ebp,%ecx
  80281f:	83 f1 1f             	xor    $0x1f,%ecx
  802822:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802826:	0f 84 b4 00 00 00    	je     8028e0 <__umoddi3+0x100>
  80282c:	b8 20 00 00 00       	mov    $0x20,%eax
  802831:	89 c2                	mov    %eax,%edx
  802833:	8b 44 24 04          	mov    0x4(%esp),%eax
  802837:	29 c2                	sub    %eax,%edx
  802839:	89 c1                	mov    %eax,%ecx
  80283b:	89 f8                	mov    %edi,%eax
  80283d:	d3 e5                	shl    %cl,%ebp
  80283f:	89 d1                	mov    %edx,%ecx
  802841:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802845:	d3 e8                	shr    %cl,%eax
  802847:	09 c5                	or     %eax,%ebp
  802849:	8b 44 24 04          	mov    0x4(%esp),%eax
  80284d:	89 c1                	mov    %eax,%ecx
  80284f:	d3 e7                	shl    %cl,%edi
  802851:	89 d1                	mov    %edx,%ecx
  802853:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802857:	89 df                	mov    %ebx,%edi
  802859:	d3 ef                	shr    %cl,%edi
  80285b:	89 c1                	mov    %eax,%ecx
  80285d:	89 f0                	mov    %esi,%eax
  80285f:	d3 e3                	shl    %cl,%ebx
  802861:	89 d1                	mov    %edx,%ecx
  802863:	89 fa                	mov    %edi,%edx
  802865:	d3 e8                	shr    %cl,%eax
  802867:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80286c:	09 d8                	or     %ebx,%eax
  80286e:	f7 f5                	div    %ebp
  802870:	d3 e6                	shl    %cl,%esi
  802872:	89 d1                	mov    %edx,%ecx
  802874:	f7 64 24 08          	mull   0x8(%esp)
  802878:	39 d1                	cmp    %edx,%ecx
  80287a:	89 c3                	mov    %eax,%ebx
  80287c:	89 d7                	mov    %edx,%edi
  80287e:	72 06                	jb     802886 <__umoddi3+0xa6>
  802880:	75 0e                	jne    802890 <__umoddi3+0xb0>
  802882:	39 c6                	cmp    %eax,%esi
  802884:	73 0a                	jae    802890 <__umoddi3+0xb0>
  802886:	2b 44 24 08          	sub    0x8(%esp),%eax
  80288a:	19 ea                	sbb    %ebp,%edx
  80288c:	89 d7                	mov    %edx,%edi
  80288e:	89 c3                	mov    %eax,%ebx
  802890:	89 ca                	mov    %ecx,%edx
  802892:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  802897:	29 de                	sub    %ebx,%esi
  802899:	19 fa                	sbb    %edi,%edx
  80289b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80289f:	89 d0                	mov    %edx,%eax
  8028a1:	d3 e0                	shl    %cl,%eax
  8028a3:	89 d9                	mov    %ebx,%ecx
  8028a5:	d3 ee                	shr    %cl,%esi
  8028a7:	d3 ea                	shr    %cl,%edx
  8028a9:	09 f0                	or     %esi,%eax
  8028ab:	83 c4 1c             	add    $0x1c,%esp
  8028ae:	5b                   	pop    %ebx
  8028af:	5e                   	pop    %esi
  8028b0:	5f                   	pop    %edi
  8028b1:	5d                   	pop    %ebp
  8028b2:	c3                   	ret    
  8028b3:	90                   	nop
  8028b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8028b8:	85 ff                	test   %edi,%edi
  8028ba:	89 f9                	mov    %edi,%ecx
  8028bc:	75 0b                	jne    8028c9 <__umoddi3+0xe9>
  8028be:	b8 01 00 00 00       	mov    $0x1,%eax
  8028c3:	31 d2                	xor    %edx,%edx
  8028c5:	f7 f7                	div    %edi
  8028c7:	89 c1                	mov    %eax,%ecx
  8028c9:	89 d8                	mov    %ebx,%eax
  8028cb:	31 d2                	xor    %edx,%edx
  8028cd:	f7 f1                	div    %ecx
  8028cf:	89 f0                	mov    %esi,%eax
  8028d1:	f7 f1                	div    %ecx
  8028d3:	e9 31 ff ff ff       	jmp    802809 <__umoddi3+0x29>
  8028d8:	90                   	nop
  8028d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8028e0:	39 dd                	cmp    %ebx,%ebp
  8028e2:	72 08                	jb     8028ec <__umoddi3+0x10c>
  8028e4:	39 f7                	cmp    %esi,%edi
  8028e6:	0f 87 21 ff ff ff    	ja     80280d <__umoddi3+0x2d>
  8028ec:	89 da                	mov    %ebx,%edx
  8028ee:	89 f0                	mov    %esi,%eax
  8028f0:	29 f8                	sub    %edi,%eax
  8028f2:	19 ea                	sbb    %ebp,%edx
  8028f4:	e9 14 ff ff ff       	jmp    80280d <__umoddi3+0x2d>
