
obj/user/testpiperace2.debug:     file format elf32-i386


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
  80002c:	e8 a1 01 00 00       	call   8001d2 <libmain>
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
  800039:	83 ec 28             	sub    $0x28,%esp
	int p[2], r, i;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for pipeisclosed race...\n");
  80003c:	68 e0 22 80 00       	push   $0x8022e0
  800041:	e8 c7 02 00 00       	call   80030d <cprintf>
	if ((r = pipe(p)) < 0)
  800046:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800049:	89 04 24             	mov    %eax,(%esp)
  80004c:	e8 88 1b 00 00       	call   801bd9 <pipe>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	85 c0                	test   %eax,%eax
  800056:	78 5d                	js     8000b5 <umain+0x82>
		panic("pipe: %e", r);
	if ((r = fork()) < 0)
  800058:	e8 ad 0f 00 00       	call   80100a <fork>
  80005d:	89 c7                	mov    %eax,%edi
  80005f:	85 c0                	test   %eax,%eax
  800061:	78 64                	js     8000c7 <umain+0x94>
		panic("fork: %e", r);
	if (r == 0) {
  800063:	85 c0                	test   %eax,%eax
  800065:	74 72                	je     8000d9 <umain+0xa6>
	// pageref(p[0]) and gets 3, then it will return true when
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
  800067:	89 fb                	mov    %edi,%ebx
  800069:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (kid->env_status == ENV_RUNNABLE)
  80006f:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  800072:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  800078:	8b 43 54             	mov    0x54(%ebx),%eax
  80007b:	83 f8 02             	cmp    $0x2,%eax
  80007e:	0f 85 d1 00 00 00    	jne    800155 <umain+0x122>
		if (pipeisclosed(p[0]) != 0) {
  800084:	83 ec 0c             	sub    $0xc,%esp
  800087:	ff 75 e0             	pushl  -0x20(%ebp)
  80008a:	e8 93 1c 00 00       	call   801d22 <pipeisclosed>
  80008f:	83 c4 10             	add    $0x10,%esp
  800092:	85 c0                	test   %eax,%eax
  800094:	74 e2                	je     800078 <umain+0x45>
			cprintf("\nRACE: pipe appears closed\n");
  800096:	83 ec 0c             	sub    $0xc,%esp
  800099:	68 59 23 80 00       	push   $0x802359
  80009e:	e8 6a 02 00 00       	call   80030d <cprintf>
			sys_env_destroy(r);
  8000a3:	89 3c 24             	mov    %edi,(%esp)
  8000a6:	e8 fb 0b 00 00       	call   800ca6 <sys_env_destroy>
			exit();
  8000ab:	e8 68 01 00 00       	call   800218 <exit>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	eb c3                	jmp    800078 <umain+0x45>
		panic("pipe: %e", r);
  8000b5:	50                   	push   %eax
  8000b6:	68 2e 23 80 00       	push   $0x80232e
  8000bb:	6a 0d                	push   $0xd
  8000bd:	68 37 23 80 00       	push   $0x802337
  8000c2:	e8 6b 01 00 00       	call   800232 <_panic>
		panic("fork: %e", r);
  8000c7:	50                   	push   %eax
  8000c8:	68 4c 23 80 00       	push   $0x80234c
  8000cd:	6a 0f                	push   $0xf
  8000cf:	68 37 23 80 00       	push   $0x802337
  8000d4:	e8 59 01 00 00       	call   800232 <_panic>
		close(p[1]);
  8000d9:	83 ec 0c             	sub    $0xc,%esp
  8000dc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000df:	e8 de 12 00 00       	call   8013c2 <close>
  8000e4:	83 c4 10             	add    $0x10,%esp
		for (i = 0; i < 200; i++) {
  8000e7:	89 fb                	mov    %edi,%ebx
			if (i % 10 == 0)
  8000e9:	be 67 66 66 66       	mov    $0x66666667,%esi
  8000ee:	eb 31                	jmp    800121 <umain+0xee>
			dup(p[0], 10);
  8000f0:	83 ec 08             	sub    $0x8,%esp
  8000f3:	6a 0a                	push   $0xa
  8000f5:	ff 75 e0             	pushl  -0x20(%ebp)
  8000f8:	e8 15 13 00 00       	call   801412 <dup>
			sys_yield();
  8000fd:	e8 04 0c 00 00       	call   800d06 <sys_yield>
			close(10);
  800102:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800109:	e8 b4 12 00 00       	call   8013c2 <close>
			sys_yield();
  80010e:	e8 f3 0b 00 00       	call   800d06 <sys_yield>
		for (i = 0; i < 200; i++) {
  800113:	83 c3 01             	add    $0x1,%ebx
  800116:	83 c4 10             	add    $0x10,%esp
  800119:	81 fb c8 00 00 00    	cmp    $0xc8,%ebx
  80011f:	74 2a                	je     80014b <umain+0x118>
			if (i % 10 == 0)
  800121:	89 d8                	mov    %ebx,%eax
  800123:	f7 ee                	imul   %esi
  800125:	c1 fa 02             	sar    $0x2,%edx
  800128:	89 d8                	mov    %ebx,%eax
  80012a:	c1 f8 1f             	sar    $0x1f,%eax
  80012d:	29 c2                	sub    %eax,%edx
  80012f:	8d 04 92             	lea    (%edx,%edx,4),%eax
  800132:	01 c0                	add    %eax,%eax
  800134:	39 c3                	cmp    %eax,%ebx
  800136:	75 b8                	jne    8000f0 <umain+0xbd>
				cprintf("%d.", i);
  800138:	83 ec 08             	sub    $0x8,%esp
  80013b:	53                   	push   %ebx
  80013c:	68 55 23 80 00       	push   $0x802355
  800141:	e8 c7 01 00 00       	call   80030d <cprintf>
  800146:	83 c4 10             	add    $0x10,%esp
  800149:	eb a5                	jmp    8000f0 <umain+0xbd>
		exit();
  80014b:	e8 c8 00 00 00       	call   800218 <exit>
  800150:	e9 12 ff ff ff       	jmp    800067 <umain+0x34>
		}
	cprintf("child done with loop\n");
  800155:	83 ec 0c             	sub    $0xc,%esp
  800158:	68 75 23 80 00       	push   $0x802375
  80015d:	e8 ab 01 00 00       	call   80030d <cprintf>
	if (pipeisclosed(p[0]))
  800162:	83 c4 04             	add    $0x4,%esp
  800165:	ff 75 e0             	pushl  -0x20(%ebp)
  800168:	e8 b5 1b 00 00       	call   801d22 <pipeisclosed>
  80016d:	83 c4 10             	add    $0x10,%esp
  800170:	85 c0                	test   %eax,%eax
  800172:	75 38                	jne    8001ac <umain+0x179>
		panic("somehow the other end of p[0] got closed!");
	if ((r = fd_lookup(p[0], &fd)) < 0)
  800174:	83 ec 08             	sub    $0x8,%esp
  800177:	8d 45 dc             	lea    -0x24(%ebp),%eax
  80017a:	50                   	push   %eax
  80017b:	ff 75 e0             	pushl  -0x20(%ebp)
  80017e:	e8 0a 11 00 00       	call   80128d <fd_lookup>
  800183:	83 c4 10             	add    $0x10,%esp
  800186:	85 c0                	test   %eax,%eax
  800188:	78 36                	js     8001c0 <umain+0x18d>
		panic("cannot look up p[0]: %e", r);
	(void) fd2data(fd);
  80018a:	83 ec 0c             	sub    $0xc,%esp
  80018d:	ff 75 dc             	pushl  -0x24(%ebp)
  800190:	e8 92 10 00 00       	call   801227 <fd2data>
	cprintf("race didn't happen\n");
  800195:	c7 04 24 a3 23 80 00 	movl   $0x8023a3,(%esp)
  80019c:	e8 6c 01 00 00       	call   80030d <cprintf>
}
  8001a1:	83 c4 10             	add    $0x10,%esp
  8001a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a7:	5b                   	pop    %ebx
  8001a8:	5e                   	pop    %esi
  8001a9:	5f                   	pop    %edi
  8001aa:	5d                   	pop    %ebp
  8001ab:	c3                   	ret    
		panic("somehow the other end of p[0] got closed!");
  8001ac:	83 ec 04             	sub    $0x4,%esp
  8001af:	68 04 23 80 00       	push   $0x802304
  8001b4:	6a 40                	push   $0x40
  8001b6:	68 37 23 80 00       	push   $0x802337
  8001bb:	e8 72 00 00 00       	call   800232 <_panic>
		panic("cannot look up p[0]: %e", r);
  8001c0:	50                   	push   %eax
  8001c1:	68 8b 23 80 00       	push   $0x80238b
  8001c6:	6a 42                	push   $0x42
  8001c8:	68 37 23 80 00       	push   $0x802337
  8001cd:	e8 60 00 00 00       	call   800232 <_panic>

008001d2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001d2:	55                   	push   %ebp
  8001d3:	89 e5                	mov    %esp,%ebp
  8001d5:	56                   	push   %esi
  8001d6:	53                   	push   %ebx
  8001d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001da:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001dd:	e8 05 0b 00 00       	call   800ce7 <sys_getenvid>
  8001e2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001e7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001ea:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001ef:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001f4:	85 db                	test   %ebx,%ebx
  8001f6:	7e 07                	jle    8001ff <libmain+0x2d>
		binaryname = argv[0];
  8001f8:	8b 06                	mov    (%esi),%eax
  8001fa:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8001ff:	83 ec 08             	sub    $0x8,%esp
  800202:	56                   	push   %esi
  800203:	53                   	push   %ebx
  800204:	e8 2a fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800209:	e8 0a 00 00 00       	call   800218 <exit>
}
  80020e:	83 c4 10             	add    $0x10,%esp
  800211:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800214:	5b                   	pop    %ebx
  800215:	5e                   	pop    %esi
  800216:	5d                   	pop    %ebp
  800217:	c3                   	ret    

00800218 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80021e:	e8 ca 11 00 00       	call   8013ed <close_all>
	sys_env_destroy(0);
  800223:	83 ec 0c             	sub    $0xc,%esp
  800226:	6a 00                	push   $0x0
  800228:	e8 79 0a 00 00       	call   800ca6 <sys_env_destroy>
}
  80022d:	83 c4 10             	add    $0x10,%esp
  800230:	c9                   	leave  
  800231:	c3                   	ret    

00800232 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800232:	55                   	push   %ebp
  800233:	89 e5                	mov    %esp,%ebp
  800235:	56                   	push   %esi
  800236:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800237:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80023a:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800240:	e8 a2 0a 00 00       	call   800ce7 <sys_getenvid>
  800245:	83 ec 0c             	sub    $0xc,%esp
  800248:	ff 75 0c             	pushl  0xc(%ebp)
  80024b:	ff 75 08             	pushl  0x8(%ebp)
  80024e:	56                   	push   %esi
  80024f:	50                   	push   %eax
  800250:	68 c4 23 80 00       	push   $0x8023c4
  800255:	e8 b3 00 00 00       	call   80030d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80025a:	83 c4 18             	add    $0x18,%esp
  80025d:	53                   	push   %ebx
  80025e:	ff 75 10             	pushl  0x10(%ebp)
  800261:	e8 56 00 00 00       	call   8002bc <vcprintf>
	cprintf("\n");
  800266:	c7 04 24 1f 27 80 00 	movl   $0x80271f,(%esp)
  80026d:	e8 9b 00 00 00       	call   80030d <cprintf>
  800272:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800275:	cc                   	int3   
  800276:	eb fd                	jmp    800275 <_panic+0x43>

00800278 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800278:	55                   	push   %ebp
  800279:	89 e5                	mov    %esp,%ebp
  80027b:	53                   	push   %ebx
  80027c:	83 ec 04             	sub    $0x4,%esp
  80027f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800282:	8b 13                	mov    (%ebx),%edx
  800284:	8d 42 01             	lea    0x1(%edx),%eax
  800287:	89 03                	mov    %eax,(%ebx)
  800289:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80028c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800290:	3d ff 00 00 00       	cmp    $0xff,%eax
  800295:	74 09                	je     8002a0 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800297:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80029b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80029e:	c9                   	leave  
  80029f:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8002a0:	83 ec 08             	sub    $0x8,%esp
  8002a3:	68 ff 00 00 00       	push   $0xff
  8002a8:	8d 43 08             	lea    0x8(%ebx),%eax
  8002ab:	50                   	push   %eax
  8002ac:	e8 b8 09 00 00       	call   800c69 <sys_cputs>
		b->idx = 0;
  8002b1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002b7:	83 c4 10             	add    $0x10,%esp
  8002ba:	eb db                	jmp    800297 <putch+0x1f>

008002bc <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002c5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002cc:	00 00 00 
	b.cnt = 0;
  8002cf:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002d6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002d9:	ff 75 0c             	pushl  0xc(%ebp)
  8002dc:	ff 75 08             	pushl  0x8(%ebp)
  8002df:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002e5:	50                   	push   %eax
  8002e6:	68 78 02 80 00       	push   $0x800278
  8002eb:	e8 1a 01 00 00       	call   80040a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002f0:	83 c4 08             	add    $0x8,%esp
  8002f3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002f9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002ff:	50                   	push   %eax
  800300:	e8 64 09 00 00       	call   800c69 <sys_cputs>

	return b.cnt;
}
  800305:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80030b:	c9                   	leave  
  80030c:	c3                   	ret    

0080030d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80030d:	55                   	push   %ebp
  80030e:	89 e5                	mov    %esp,%ebp
  800310:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800313:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800316:	50                   	push   %eax
  800317:	ff 75 08             	pushl  0x8(%ebp)
  80031a:	e8 9d ff ff ff       	call   8002bc <vcprintf>
	va_end(ap);

	return cnt;
}
  80031f:	c9                   	leave  
  800320:	c3                   	ret    

00800321 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800321:	55                   	push   %ebp
  800322:	89 e5                	mov    %esp,%ebp
  800324:	57                   	push   %edi
  800325:	56                   	push   %esi
  800326:	53                   	push   %ebx
  800327:	83 ec 1c             	sub    $0x1c,%esp
  80032a:	89 c7                	mov    %eax,%edi
  80032c:	89 d6                	mov    %edx,%esi
  80032e:	8b 45 08             	mov    0x8(%ebp),%eax
  800331:	8b 55 0c             	mov    0xc(%ebp),%edx
  800334:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800337:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80033a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80033d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800342:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800345:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800348:	39 d3                	cmp    %edx,%ebx
  80034a:	72 05                	jb     800351 <printnum+0x30>
  80034c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80034f:	77 7a                	ja     8003cb <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800351:	83 ec 0c             	sub    $0xc,%esp
  800354:	ff 75 18             	pushl  0x18(%ebp)
  800357:	8b 45 14             	mov    0x14(%ebp),%eax
  80035a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80035d:	53                   	push   %ebx
  80035e:	ff 75 10             	pushl  0x10(%ebp)
  800361:	83 ec 08             	sub    $0x8,%esp
  800364:	ff 75 e4             	pushl  -0x1c(%ebp)
  800367:	ff 75 e0             	pushl  -0x20(%ebp)
  80036a:	ff 75 dc             	pushl  -0x24(%ebp)
  80036d:	ff 75 d8             	pushl  -0x28(%ebp)
  800370:	e8 2b 1d 00 00       	call   8020a0 <__udivdi3>
  800375:	83 c4 18             	add    $0x18,%esp
  800378:	52                   	push   %edx
  800379:	50                   	push   %eax
  80037a:	89 f2                	mov    %esi,%edx
  80037c:	89 f8                	mov    %edi,%eax
  80037e:	e8 9e ff ff ff       	call   800321 <printnum>
  800383:	83 c4 20             	add    $0x20,%esp
  800386:	eb 13                	jmp    80039b <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800388:	83 ec 08             	sub    $0x8,%esp
  80038b:	56                   	push   %esi
  80038c:	ff 75 18             	pushl  0x18(%ebp)
  80038f:	ff d7                	call   *%edi
  800391:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800394:	83 eb 01             	sub    $0x1,%ebx
  800397:	85 db                	test   %ebx,%ebx
  800399:	7f ed                	jg     800388 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80039b:	83 ec 08             	sub    $0x8,%esp
  80039e:	56                   	push   %esi
  80039f:	83 ec 04             	sub    $0x4,%esp
  8003a2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003a5:	ff 75 e0             	pushl  -0x20(%ebp)
  8003a8:	ff 75 dc             	pushl  -0x24(%ebp)
  8003ab:	ff 75 d8             	pushl  -0x28(%ebp)
  8003ae:	e8 0d 1e 00 00       	call   8021c0 <__umoddi3>
  8003b3:	83 c4 14             	add    $0x14,%esp
  8003b6:	0f be 80 e7 23 80 00 	movsbl 0x8023e7(%eax),%eax
  8003bd:	50                   	push   %eax
  8003be:	ff d7                	call   *%edi
}
  8003c0:	83 c4 10             	add    $0x10,%esp
  8003c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003c6:	5b                   	pop    %ebx
  8003c7:	5e                   	pop    %esi
  8003c8:	5f                   	pop    %edi
  8003c9:	5d                   	pop    %ebp
  8003ca:	c3                   	ret    
  8003cb:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003ce:	eb c4                	jmp    800394 <printnum+0x73>

008003d0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003d0:	55                   	push   %ebp
  8003d1:	89 e5                	mov    %esp,%ebp
  8003d3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003d6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003da:	8b 10                	mov    (%eax),%edx
  8003dc:	3b 50 04             	cmp    0x4(%eax),%edx
  8003df:	73 0a                	jae    8003eb <sprintputch+0x1b>
		*b->buf++ = ch;
  8003e1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003e4:	89 08                	mov    %ecx,(%eax)
  8003e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e9:	88 02                	mov    %al,(%edx)
}
  8003eb:	5d                   	pop    %ebp
  8003ec:	c3                   	ret    

008003ed <printfmt>:
{
  8003ed:	55                   	push   %ebp
  8003ee:	89 e5                	mov    %esp,%ebp
  8003f0:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8003f3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003f6:	50                   	push   %eax
  8003f7:	ff 75 10             	pushl  0x10(%ebp)
  8003fa:	ff 75 0c             	pushl  0xc(%ebp)
  8003fd:	ff 75 08             	pushl  0x8(%ebp)
  800400:	e8 05 00 00 00       	call   80040a <vprintfmt>
}
  800405:	83 c4 10             	add    $0x10,%esp
  800408:	c9                   	leave  
  800409:	c3                   	ret    

0080040a <vprintfmt>:
{
  80040a:	55                   	push   %ebp
  80040b:	89 e5                	mov    %esp,%ebp
  80040d:	57                   	push   %edi
  80040e:	56                   	push   %esi
  80040f:	53                   	push   %ebx
  800410:	83 ec 2c             	sub    $0x2c,%esp
  800413:	8b 75 08             	mov    0x8(%ebp),%esi
  800416:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800419:	8b 7d 10             	mov    0x10(%ebp),%edi
  80041c:	e9 c1 03 00 00       	jmp    8007e2 <vprintfmt+0x3d8>
		padc = ' ';
  800421:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800425:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  80042c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800433:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80043a:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80043f:	8d 47 01             	lea    0x1(%edi),%eax
  800442:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800445:	0f b6 17             	movzbl (%edi),%edx
  800448:	8d 42 dd             	lea    -0x23(%edx),%eax
  80044b:	3c 55                	cmp    $0x55,%al
  80044d:	0f 87 12 04 00 00    	ja     800865 <vprintfmt+0x45b>
  800453:	0f b6 c0             	movzbl %al,%eax
  800456:	ff 24 85 20 25 80 00 	jmp    *0x802520(,%eax,4)
  80045d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800460:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800464:	eb d9                	jmp    80043f <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800466:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800469:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80046d:	eb d0                	jmp    80043f <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80046f:	0f b6 d2             	movzbl %dl,%edx
  800472:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800475:	b8 00 00 00 00       	mov    $0x0,%eax
  80047a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80047d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800480:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800484:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800487:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80048a:	83 f9 09             	cmp    $0x9,%ecx
  80048d:	77 55                	ja     8004e4 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  80048f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800492:	eb e9                	jmp    80047d <vprintfmt+0x73>
			precision = va_arg(ap, int);
  800494:	8b 45 14             	mov    0x14(%ebp),%eax
  800497:	8b 00                	mov    (%eax),%eax
  800499:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80049c:	8b 45 14             	mov    0x14(%ebp),%eax
  80049f:	8d 40 04             	lea    0x4(%eax),%eax
  8004a2:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8004a8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004ac:	79 91                	jns    80043f <vprintfmt+0x35>
				width = precision, precision = -1;
  8004ae:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004bb:	eb 82                	jmp    80043f <vprintfmt+0x35>
  8004bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004c0:	85 c0                	test   %eax,%eax
  8004c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c7:	0f 49 d0             	cmovns %eax,%edx
  8004ca:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004d0:	e9 6a ff ff ff       	jmp    80043f <vprintfmt+0x35>
  8004d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8004d8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004df:	e9 5b ff ff ff       	jmp    80043f <vprintfmt+0x35>
  8004e4:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004e7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004ea:	eb bc                	jmp    8004a8 <vprintfmt+0x9e>
			lflag++;
  8004ec:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8004ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004f2:	e9 48 ff ff ff       	jmp    80043f <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8004f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fa:	8d 78 04             	lea    0x4(%eax),%edi
  8004fd:	83 ec 08             	sub    $0x8,%esp
  800500:	53                   	push   %ebx
  800501:	ff 30                	pushl  (%eax)
  800503:	ff d6                	call   *%esi
			break;
  800505:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800508:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80050b:	e9 cf 02 00 00       	jmp    8007df <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  800510:	8b 45 14             	mov    0x14(%ebp),%eax
  800513:	8d 78 04             	lea    0x4(%eax),%edi
  800516:	8b 00                	mov    (%eax),%eax
  800518:	99                   	cltd   
  800519:	31 d0                	xor    %edx,%eax
  80051b:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80051d:	83 f8 0f             	cmp    $0xf,%eax
  800520:	7f 23                	jg     800545 <vprintfmt+0x13b>
  800522:	8b 14 85 80 26 80 00 	mov    0x802680(,%eax,4),%edx
  800529:	85 d2                	test   %edx,%edx
  80052b:	74 18                	je     800545 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  80052d:	52                   	push   %edx
  80052e:	68 f5 28 80 00       	push   $0x8028f5
  800533:	53                   	push   %ebx
  800534:	56                   	push   %esi
  800535:	e8 b3 fe ff ff       	call   8003ed <printfmt>
  80053a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80053d:	89 7d 14             	mov    %edi,0x14(%ebp)
  800540:	e9 9a 02 00 00       	jmp    8007df <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  800545:	50                   	push   %eax
  800546:	68 ff 23 80 00       	push   $0x8023ff
  80054b:	53                   	push   %ebx
  80054c:	56                   	push   %esi
  80054d:	e8 9b fe ff ff       	call   8003ed <printfmt>
  800552:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800555:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800558:	e9 82 02 00 00       	jmp    8007df <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  80055d:	8b 45 14             	mov    0x14(%ebp),%eax
  800560:	83 c0 04             	add    $0x4,%eax
  800563:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800566:	8b 45 14             	mov    0x14(%ebp),%eax
  800569:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80056b:	85 ff                	test   %edi,%edi
  80056d:	b8 f8 23 80 00       	mov    $0x8023f8,%eax
  800572:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800575:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800579:	0f 8e bd 00 00 00    	jle    80063c <vprintfmt+0x232>
  80057f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800583:	75 0e                	jne    800593 <vprintfmt+0x189>
  800585:	89 75 08             	mov    %esi,0x8(%ebp)
  800588:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80058b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80058e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800591:	eb 6d                	jmp    800600 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  800593:	83 ec 08             	sub    $0x8,%esp
  800596:	ff 75 d0             	pushl  -0x30(%ebp)
  800599:	57                   	push   %edi
  80059a:	e8 6e 03 00 00       	call   80090d <strnlen>
  80059f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005a2:	29 c1                	sub    %eax,%ecx
  8005a4:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8005a7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005aa:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005b1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005b4:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b6:	eb 0f                	jmp    8005c7 <vprintfmt+0x1bd>
					putch(padc, putdat);
  8005b8:	83 ec 08             	sub    $0x8,%esp
  8005bb:	53                   	push   %ebx
  8005bc:	ff 75 e0             	pushl  -0x20(%ebp)
  8005bf:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c1:	83 ef 01             	sub    $0x1,%edi
  8005c4:	83 c4 10             	add    $0x10,%esp
  8005c7:	85 ff                	test   %edi,%edi
  8005c9:	7f ed                	jg     8005b8 <vprintfmt+0x1ae>
  8005cb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005ce:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8005d1:	85 c9                	test   %ecx,%ecx
  8005d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8005d8:	0f 49 c1             	cmovns %ecx,%eax
  8005db:	29 c1                	sub    %eax,%ecx
  8005dd:	89 75 08             	mov    %esi,0x8(%ebp)
  8005e0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005e3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005e6:	89 cb                	mov    %ecx,%ebx
  8005e8:	eb 16                	jmp    800600 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8005ea:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005ee:	75 31                	jne    800621 <vprintfmt+0x217>
					putch(ch, putdat);
  8005f0:	83 ec 08             	sub    $0x8,%esp
  8005f3:	ff 75 0c             	pushl  0xc(%ebp)
  8005f6:	50                   	push   %eax
  8005f7:	ff 55 08             	call   *0x8(%ebp)
  8005fa:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005fd:	83 eb 01             	sub    $0x1,%ebx
  800600:	83 c7 01             	add    $0x1,%edi
  800603:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800607:	0f be c2             	movsbl %dl,%eax
  80060a:	85 c0                	test   %eax,%eax
  80060c:	74 59                	je     800667 <vprintfmt+0x25d>
  80060e:	85 f6                	test   %esi,%esi
  800610:	78 d8                	js     8005ea <vprintfmt+0x1e0>
  800612:	83 ee 01             	sub    $0x1,%esi
  800615:	79 d3                	jns    8005ea <vprintfmt+0x1e0>
  800617:	89 df                	mov    %ebx,%edi
  800619:	8b 75 08             	mov    0x8(%ebp),%esi
  80061c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80061f:	eb 37                	jmp    800658 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  800621:	0f be d2             	movsbl %dl,%edx
  800624:	83 ea 20             	sub    $0x20,%edx
  800627:	83 fa 5e             	cmp    $0x5e,%edx
  80062a:	76 c4                	jbe    8005f0 <vprintfmt+0x1e6>
					putch('?', putdat);
  80062c:	83 ec 08             	sub    $0x8,%esp
  80062f:	ff 75 0c             	pushl  0xc(%ebp)
  800632:	6a 3f                	push   $0x3f
  800634:	ff 55 08             	call   *0x8(%ebp)
  800637:	83 c4 10             	add    $0x10,%esp
  80063a:	eb c1                	jmp    8005fd <vprintfmt+0x1f3>
  80063c:	89 75 08             	mov    %esi,0x8(%ebp)
  80063f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800642:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800645:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800648:	eb b6                	jmp    800600 <vprintfmt+0x1f6>
				putch(' ', putdat);
  80064a:	83 ec 08             	sub    $0x8,%esp
  80064d:	53                   	push   %ebx
  80064e:	6a 20                	push   $0x20
  800650:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800652:	83 ef 01             	sub    $0x1,%edi
  800655:	83 c4 10             	add    $0x10,%esp
  800658:	85 ff                	test   %edi,%edi
  80065a:	7f ee                	jg     80064a <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  80065c:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80065f:	89 45 14             	mov    %eax,0x14(%ebp)
  800662:	e9 78 01 00 00       	jmp    8007df <vprintfmt+0x3d5>
  800667:	89 df                	mov    %ebx,%edi
  800669:	8b 75 08             	mov    0x8(%ebp),%esi
  80066c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80066f:	eb e7                	jmp    800658 <vprintfmt+0x24e>
	if (lflag >= 2)
  800671:	83 f9 01             	cmp    $0x1,%ecx
  800674:	7e 3f                	jle    8006b5 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800676:	8b 45 14             	mov    0x14(%ebp),%eax
  800679:	8b 50 04             	mov    0x4(%eax),%edx
  80067c:	8b 00                	mov    (%eax),%eax
  80067e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800681:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800684:	8b 45 14             	mov    0x14(%ebp),%eax
  800687:	8d 40 08             	lea    0x8(%eax),%eax
  80068a:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80068d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800691:	79 5c                	jns    8006ef <vprintfmt+0x2e5>
				putch('-', putdat);
  800693:	83 ec 08             	sub    $0x8,%esp
  800696:	53                   	push   %ebx
  800697:	6a 2d                	push   $0x2d
  800699:	ff d6                	call   *%esi
				num = -(long long) num;
  80069b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80069e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006a1:	f7 da                	neg    %edx
  8006a3:	83 d1 00             	adc    $0x0,%ecx
  8006a6:	f7 d9                	neg    %ecx
  8006a8:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006ab:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006b0:	e9 10 01 00 00       	jmp    8007c5 <vprintfmt+0x3bb>
	else if (lflag)
  8006b5:	85 c9                	test   %ecx,%ecx
  8006b7:	75 1b                	jne    8006d4 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8006b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bc:	8b 00                	mov    (%eax),%eax
  8006be:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c1:	89 c1                	mov    %eax,%ecx
  8006c3:	c1 f9 1f             	sar    $0x1f,%ecx
  8006c6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cc:	8d 40 04             	lea    0x4(%eax),%eax
  8006cf:	89 45 14             	mov    %eax,0x14(%ebp)
  8006d2:	eb b9                	jmp    80068d <vprintfmt+0x283>
		return va_arg(*ap, long);
  8006d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d7:	8b 00                	mov    (%eax),%eax
  8006d9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006dc:	89 c1                	mov    %eax,%ecx
  8006de:	c1 f9 1f             	sar    $0x1f,%ecx
  8006e1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e7:	8d 40 04             	lea    0x4(%eax),%eax
  8006ea:	89 45 14             	mov    %eax,0x14(%ebp)
  8006ed:	eb 9e                	jmp    80068d <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8006ef:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006f2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8006f5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006fa:	e9 c6 00 00 00       	jmp    8007c5 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8006ff:	83 f9 01             	cmp    $0x1,%ecx
  800702:	7e 18                	jle    80071c <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  800704:	8b 45 14             	mov    0x14(%ebp),%eax
  800707:	8b 10                	mov    (%eax),%edx
  800709:	8b 48 04             	mov    0x4(%eax),%ecx
  80070c:	8d 40 08             	lea    0x8(%eax),%eax
  80070f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800712:	b8 0a 00 00 00       	mov    $0xa,%eax
  800717:	e9 a9 00 00 00       	jmp    8007c5 <vprintfmt+0x3bb>
	else if (lflag)
  80071c:	85 c9                	test   %ecx,%ecx
  80071e:	75 1a                	jne    80073a <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  800720:	8b 45 14             	mov    0x14(%ebp),%eax
  800723:	8b 10                	mov    (%eax),%edx
  800725:	b9 00 00 00 00       	mov    $0x0,%ecx
  80072a:	8d 40 04             	lea    0x4(%eax),%eax
  80072d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800730:	b8 0a 00 00 00       	mov    $0xa,%eax
  800735:	e9 8b 00 00 00       	jmp    8007c5 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80073a:	8b 45 14             	mov    0x14(%ebp),%eax
  80073d:	8b 10                	mov    (%eax),%edx
  80073f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800744:	8d 40 04             	lea    0x4(%eax),%eax
  800747:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80074a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80074f:	eb 74                	jmp    8007c5 <vprintfmt+0x3bb>
	if (lflag >= 2)
  800751:	83 f9 01             	cmp    $0x1,%ecx
  800754:	7e 15                	jle    80076b <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  800756:	8b 45 14             	mov    0x14(%ebp),%eax
  800759:	8b 10                	mov    (%eax),%edx
  80075b:	8b 48 04             	mov    0x4(%eax),%ecx
  80075e:	8d 40 08             	lea    0x8(%eax),%eax
  800761:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800764:	b8 08 00 00 00       	mov    $0x8,%eax
  800769:	eb 5a                	jmp    8007c5 <vprintfmt+0x3bb>
	else if (lflag)
  80076b:	85 c9                	test   %ecx,%ecx
  80076d:	75 17                	jne    800786 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  80076f:	8b 45 14             	mov    0x14(%ebp),%eax
  800772:	8b 10                	mov    (%eax),%edx
  800774:	b9 00 00 00 00       	mov    $0x0,%ecx
  800779:	8d 40 04             	lea    0x4(%eax),%eax
  80077c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80077f:	b8 08 00 00 00       	mov    $0x8,%eax
  800784:	eb 3f                	jmp    8007c5 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800786:	8b 45 14             	mov    0x14(%ebp),%eax
  800789:	8b 10                	mov    (%eax),%edx
  80078b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800790:	8d 40 04             	lea    0x4(%eax),%eax
  800793:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800796:	b8 08 00 00 00       	mov    $0x8,%eax
  80079b:	eb 28                	jmp    8007c5 <vprintfmt+0x3bb>
			putch('0', putdat);
  80079d:	83 ec 08             	sub    $0x8,%esp
  8007a0:	53                   	push   %ebx
  8007a1:	6a 30                	push   $0x30
  8007a3:	ff d6                	call   *%esi
			putch('x', putdat);
  8007a5:	83 c4 08             	add    $0x8,%esp
  8007a8:	53                   	push   %ebx
  8007a9:	6a 78                	push   $0x78
  8007ab:	ff d6                	call   *%esi
			num = (unsigned long long)
  8007ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b0:	8b 10                	mov    (%eax),%edx
  8007b2:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8007b7:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8007ba:	8d 40 04             	lea    0x4(%eax),%eax
  8007bd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007c0:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8007c5:	83 ec 0c             	sub    $0xc,%esp
  8007c8:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007cc:	57                   	push   %edi
  8007cd:	ff 75 e0             	pushl  -0x20(%ebp)
  8007d0:	50                   	push   %eax
  8007d1:	51                   	push   %ecx
  8007d2:	52                   	push   %edx
  8007d3:	89 da                	mov    %ebx,%edx
  8007d5:	89 f0                	mov    %esi,%eax
  8007d7:	e8 45 fb ff ff       	call   800321 <printnum>
			break;
  8007dc:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8007df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007e2:	83 c7 01             	add    $0x1,%edi
  8007e5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8007e9:	83 f8 25             	cmp    $0x25,%eax
  8007ec:	0f 84 2f fc ff ff    	je     800421 <vprintfmt+0x17>
			if (ch == '\0')
  8007f2:	85 c0                	test   %eax,%eax
  8007f4:	0f 84 8b 00 00 00    	je     800885 <vprintfmt+0x47b>
			putch(ch, putdat);
  8007fa:	83 ec 08             	sub    $0x8,%esp
  8007fd:	53                   	push   %ebx
  8007fe:	50                   	push   %eax
  8007ff:	ff d6                	call   *%esi
  800801:	83 c4 10             	add    $0x10,%esp
  800804:	eb dc                	jmp    8007e2 <vprintfmt+0x3d8>
	if (lflag >= 2)
  800806:	83 f9 01             	cmp    $0x1,%ecx
  800809:	7e 15                	jle    800820 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  80080b:	8b 45 14             	mov    0x14(%ebp),%eax
  80080e:	8b 10                	mov    (%eax),%edx
  800810:	8b 48 04             	mov    0x4(%eax),%ecx
  800813:	8d 40 08             	lea    0x8(%eax),%eax
  800816:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800819:	b8 10 00 00 00       	mov    $0x10,%eax
  80081e:	eb a5                	jmp    8007c5 <vprintfmt+0x3bb>
	else if (lflag)
  800820:	85 c9                	test   %ecx,%ecx
  800822:	75 17                	jne    80083b <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  800824:	8b 45 14             	mov    0x14(%ebp),%eax
  800827:	8b 10                	mov    (%eax),%edx
  800829:	b9 00 00 00 00       	mov    $0x0,%ecx
  80082e:	8d 40 04             	lea    0x4(%eax),%eax
  800831:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800834:	b8 10 00 00 00       	mov    $0x10,%eax
  800839:	eb 8a                	jmp    8007c5 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80083b:	8b 45 14             	mov    0x14(%ebp),%eax
  80083e:	8b 10                	mov    (%eax),%edx
  800840:	b9 00 00 00 00       	mov    $0x0,%ecx
  800845:	8d 40 04             	lea    0x4(%eax),%eax
  800848:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80084b:	b8 10 00 00 00       	mov    $0x10,%eax
  800850:	e9 70 ff ff ff       	jmp    8007c5 <vprintfmt+0x3bb>
			putch(ch, putdat);
  800855:	83 ec 08             	sub    $0x8,%esp
  800858:	53                   	push   %ebx
  800859:	6a 25                	push   $0x25
  80085b:	ff d6                	call   *%esi
			break;
  80085d:	83 c4 10             	add    $0x10,%esp
  800860:	e9 7a ff ff ff       	jmp    8007df <vprintfmt+0x3d5>
			putch('%', putdat);
  800865:	83 ec 08             	sub    $0x8,%esp
  800868:	53                   	push   %ebx
  800869:	6a 25                	push   $0x25
  80086b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80086d:	83 c4 10             	add    $0x10,%esp
  800870:	89 f8                	mov    %edi,%eax
  800872:	eb 03                	jmp    800877 <vprintfmt+0x46d>
  800874:	83 e8 01             	sub    $0x1,%eax
  800877:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80087b:	75 f7                	jne    800874 <vprintfmt+0x46a>
  80087d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800880:	e9 5a ff ff ff       	jmp    8007df <vprintfmt+0x3d5>
}
  800885:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800888:	5b                   	pop    %ebx
  800889:	5e                   	pop    %esi
  80088a:	5f                   	pop    %edi
  80088b:	5d                   	pop    %ebp
  80088c:	c3                   	ret    

0080088d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80088d:	55                   	push   %ebp
  80088e:	89 e5                	mov    %esp,%ebp
  800890:	83 ec 18             	sub    $0x18,%esp
  800893:	8b 45 08             	mov    0x8(%ebp),%eax
  800896:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800899:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80089c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008a0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008aa:	85 c0                	test   %eax,%eax
  8008ac:	74 26                	je     8008d4 <vsnprintf+0x47>
  8008ae:	85 d2                	test   %edx,%edx
  8008b0:	7e 22                	jle    8008d4 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008b2:	ff 75 14             	pushl  0x14(%ebp)
  8008b5:	ff 75 10             	pushl  0x10(%ebp)
  8008b8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008bb:	50                   	push   %eax
  8008bc:	68 d0 03 80 00       	push   $0x8003d0
  8008c1:	e8 44 fb ff ff       	call   80040a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008c9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008cf:	83 c4 10             	add    $0x10,%esp
}
  8008d2:	c9                   	leave  
  8008d3:	c3                   	ret    
		return -E_INVAL;
  8008d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008d9:	eb f7                	jmp    8008d2 <vsnprintf+0x45>

008008db <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008e1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008e4:	50                   	push   %eax
  8008e5:	ff 75 10             	pushl  0x10(%ebp)
  8008e8:	ff 75 0c             	pushl  0xc(%ebp)
  8008eb:	ff 75 08             	pushl  0x8(%ebp)
  8008ee:	e8 9a ff ff ff       	call   80088d <vsnprintf>
	va_end(ap);

	return rc;
}
  8008f3:	c9                   	leave  
  8008f4:	c3                   	ret    

008008f5 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800900:	eb 03                	jmp    800905 <strlen+0x10>
		n++;
  800902:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800905:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800909:	75 f7                	jne    800902 <strlen+0xd>
	return n;
}
  80090b:	5d                   	pop    %ebp
  80090c:	c3                   	ret    

0080090d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80090d:	55                   	push   %ebp
  80090e:	89 e5                	mov    %esp,%ebp
  800910:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800913:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800916:	b8 00 00 00 00       	mov    $0x0,%eax
  80091b:	eb 03                	jmp    800920 <strnlen+0x13>
		n++;
  80091d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800920:	39 d0                	cmp    %edx,%eax
  800922:	74 06                	je     80092a <strnlen+0x1d>
  800924:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800928:	75 f3                	jne    80091d <strnlen+0x10>
	return n;
}
  80092a:	5d                   	pop    %ebp
  80092b:	c3                   	ret    

0080092c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	53                   	push   %ebx
  800930:	8b 45 08             	mov    0x8(%ebp),%eax
  800933:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800936:	89 c2                	mov    %eax,%edx
  800938:	83 c1 01             	add    $0x1,%ecx
  80093b:	83 c2 01             	add    $0x1,%edx
  80093e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800942:	88 5a ff             	mov    %bl,-0x1(%edx)
  800945:	84 db                	test   %bl,%bl
  800947:	75 ef                	jne    800938 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800949:	5b                   	pop    %ebx
  80094a:	5d                   	pop    %ebp
  80094b:	c3                   	ret    

0080094c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80094c:	55                   	push   %ebp
  80094d:	89 e5                	mov    %esp,%ebp
  80094f:	53                   	push   %ebx
  800950:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800953:	53                   	push   %ebx
  800954:	e8 9c ff ff ff       	call   8008f5 <strlen>
  800959:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80095c:	ff 75 0c             	pushl  0xc(%ebp)
  80095f:	01 d8                	add    %ebx,%eax
  800961:	50                   	push   %eax
  800962:	e8 c5 ff ff ff       	call   80092c <strcpy>
	return dst;
}
  800967:	89 d8                	mov    %ebx,%eax
  800969:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80096c:	c9                   	leave  
  80096d:	c3                   	ret    

0080096e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80096e:	55                   	push   %ebp
  80096f:	89 e5                	mov    %esp,%ebp
  800971:	56                   	push   %esi
  800972:	53                   	push   %ebx
  800973:	8b 75 08             	mov    0x8(%ebp),%esi
  800976:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800979:	89 f3                	mov    %esi,%ebx
  80097b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80097e:	89 f2                	mov    %esi,%edx
  800980:	eb 0f                	jmp    800991 <strncpy+0x23>
		*dst++ = *src;
  800982:	83 c2 01             	add    $0x1,%edx
  800985:	0f b6 01             	movzbl (%ecx),%eax
  800988:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80098b:	80 39 01             	cmpb   $0x1,(%ecx)
  80098e:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800991:	39 da                	cmp    %ebx,%edx
  800993:	75 ed                	jne    800982 <strncpy+0x14>
	}
	return ret;
}
  800995:	89 f0                	mov    %esi,%eax
  800997:	5b                   	pop    %ebx
  800998:	5e                   	pop    %esi
  800999:	5d                   	pop    %ebp
  80099a:	c3                   	ret    

0080099b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	56                   	push   %esi
  80099f:	53                   	push   %ebx
  8009a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8009a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8009a9:	89 f0                	mov    %esi,%eax
  8009ab:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009af:	85 c9                	test   %ecx,%ecx
  8009b1:	75 0b                	jne    8009be <strlcpy+0x23>
  8009b3:	eb 17                	jmp    8009cc <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009b5:	83 c2 01             	add    $0x1,%edx
  8009b8:	83 c0 01             	add    $0x1,%eax
  8009bb:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8009be:	39 d8                	cmp    %ebx,%eax
  8009c0:	74 07                	je     8009c9 <strlcpy+0x2e>
  8009c2:	0f b6 0a             	movzbl (%edx),%ecx
  8009c5:	84 c9                	test   %cl,%cl
  8009c7:	75 ec                	jne    8009b5 <strlcpy+0x1a>
		*dst = '\0';
  8009c9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009cc:	29 f0                	sub    %esi,%eax
}
  8009ce:	5b                   	pop    %ebx
  8009cf:	5e                   	pop    %esi
  8009d0:	5d                   	pop    %ebp
  8009d1:	c3                   	ret    

008009d2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009d2:	55                   	push   %ebp
  8009d3:	89 e5                	mov    %esp,%ebp
  8009d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009d8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009db:	eb 06                	jmp    8009e3 <strcmp+0x11>
		p++, q++;
  8009dd:	83 c1 01             	add    $0x1,%ecx
  8009e0:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009e3:	0f b6 01             	movzbl (%ecx),%eax
  8009e6:	84 c0                	test   %al,%al
  8009e8:	74 04                	je     8009ee <strcmp+0x1c>
  8009ea:	3a 02                	cmp    (%edx),%al
  8009ec:	74 ef                	je     8009dd <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ee:	0f b6 c0             	movzbl %al,%eax
  8009f1:	0f b6 12             	movzbl (%edx),%edx
  8009f4:	29 d0                	sub    %edx,%eax
}
  8009f6:	5d                   	pop    %ebp
  8009f7:	c3                   	ret    

008009f8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009f8:	55                   	push   %ebp
  8009f9:	89 e5                	mov    %esp,%ebp
  8009fb:	53                   	push   %ebx
  8009fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a02:	89 c3                	mov    %eax,%ebx
  800a04:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a07:	eb 06                	jmp    800a0f <strncmp+0x17>
		n--, p++, q++;
  800a09:	83 c0 01             	add    $0x1,%eax
  800a0c:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a0f:	39 d8                	cmp    %ebx,%eax
  800a11:	74 16                	je     800a29 <strncmp+0x31>
  800a13:	0f b6 08             	movzbl (%eax),%ecx
  800a16:	84 c9                	test   %cl,%cl
  800a18:	74 04                	je     800a1e <strncmp+0x26>
  800a1a:	3a 0a                	cmp    (%edx),%cl
  800a1c:	74 eb                	je     800a09 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a1e:	0f b6 00             	movzbl (%eax),%eax
  800a21:	0f b6 12             	movzbl (%edx),%edx
  800a24:	29 d0                	sub    %edx,%eax
}
  800a26:	5b                   	pop    %ebx
  800a27:	5d                   	pop    %ebp
  800a28:	c3                   	ret    
		return 0;
  800a29:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2e:	eb f6                	jmp    800a26 <strncmp+0x2e>

00800a30 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	8b 45 08             	mov    0x8(%ebp),%eax
  800a36:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a3a:	0f b6 10             	movzbl (%eax),%edx
  800a3d:	84 d2                	test   %dl,%dl
  800a3f:	74 09                	je     800a4a <strchr+0x1a>
		if (*s == c)
  800a41:	38 ca                	cmp    %cl,%dl
  800a43:	74 0a                	je     800a4f <strchr+0x1f>
	for (; *s; s++)
  800a45:	83 c0 01             	add    $0x1,%eax
  800a48:	eb f0                	jmp    800a3a <strchr+0xa>
			return (char *) s;
	return 0;
  800a4a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a4f:	5d                   	pop    %ebp
  800a50:	c3                   	ret    

00800a51 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a51:	55                   	push   %ebp
  800a52:	89 e5                	mov    %esp,%ebp
  800a54:	8b 45 08             	mov    0x8(%ebp),%eax
  800a57:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a5b:	eb 03                	jmp    800a60 <strfind+0xf>
  800a5d:	83 c0 01             	add    $0x1,%eax
  800a60:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a63:	38 ca                	cmp    %cl,%dl
  800a65:	74 04                	je     800a6b <strfind+0x1a>
  800a67:	84 d2                	test   %dl,%dl
  800a69:	75 f2                	jne    800a5d <strfind+0xc>
			break;
	return (char *) s;
}
  800a6b:	5d                   	pop    %ebp
  800a6c:	c3                   	ret    

00800a6d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a6d:	55                   	push   %ebp
  800a6e:	89 e5                	mov    %esp,%ebp
  800a70:	57                   	push   %edi
  800a71:	56                   	push   %esi
  800a72:	53                   	push   %ebx
  800a73:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a76:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a79:	85 c9                	test   %ecx,%ecx
  800a7b:	74 13                	je     800a90 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a7d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a83:	75 05                	jne    800a8a <memset+0x1d>
  800a85:	f6 c1 03             	test   $0x3,%cl
  800a88:	74 0d                	je     800a97 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a8a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8d:	fc                   	cld    
  800a8e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a90:	89 f8                	mov    %edi,%eax
  800a92:	5b                   	pop    %ebx
  800a93:	5e                   	pop    %esi
  800a94:	5f                   	pop    %edi
  800a95:	5d                   	pop    %ebp
  800a96:	c3                   	ret    
		c &= 0xFF;
  800a97:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a9b:	89 d3                	mov    %edx,%ebx
  800a9d:	c1 e3 08             	shl    $0x8,%ebx
  800aa0:	89 d0                	mov    %edx,%eax
  800aa2:	c1 e0 18             	shl    $0x18,%eax
  800aa5:	89 d6                	mov    %edx,%esi
  800aa7:	c1 e6 10             	shl    $0x10,%esi
  800aaa:	09 f0                	or     %esi,%eax
  800aac:	09 c2                	or     %eax,%edx
  800aae:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800ab0:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800ab3:	89 d0                	mov    %edx,%eax
  800ab5:	fc                   	cld    
  800ab6:	f3 ab                	rep stos %eax,%es:(%edi)
  800ab8:	eb d6                	jmp    800a90 <memset+0x23>

00800aba <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
  800abd:	57                   	push   %edi
  800abe:	56                   	push   %esi
  800abf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ac8:	39 c6                	cmp    %eax,%esi
  800aca:	73 35                	jae    800b01 <memmove+0x47>
  800acc:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800acf:	39 c2                	cmp    %eax,%edx
  800ad1:	76 2e                	jbe    800b01 <memmove+0x47>
		s += n;
		d += n;
  800ad3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad6:	89 d6                	mov    %edx,%esi
  800ad8:	09 fe                	or     %edi,%esi
  800ada:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ae0:	74 0c                	je     800aee <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ae2:	83 ef 01             	sub    $0x1,%edi
  800ae5:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800ae8:	fd                   	std    
  800ae9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aeb:	fc                   	cld    
  800aec:	eb 21                	jmp    800b0f <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aee:	f6 c1 03             	test   $0x3,%cl
  800af1:	75 ef                	jne    800ae2 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800af3:	83 ef 04             	sub    $0x4,%edi
  800af6:	8d 72 fc             	lea    -0x4(%edx),%esi
  800af9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800afc:	fd                   	std    
  800afd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aff:	eb ea                	jmp    800aeb <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b01:	89 f2                	mov    %esi,%edx
  800b03:	09 c2                	or     %eax,%edx
  800b05:	f6 c2 03             	test   $0x3,%dl
  800b08:	74 09                	je     800b13 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b0a:	89 c7                	mov    %eax,%edi
  800b0c:	fc                   	cld    
  800b0d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b0f:	5e                   	pop    %esi
  800b10:	5f                   	pop    %edi
  800b11:	5d                   	pop    %ebp
  800b12:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b13:	f6 c1 03             	test   $0x3,%cl
  800b16:	75 f2                	jne    800b0a <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b18:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b1b:	89 c7                	mov    %eax,%edi
  800b1d:	fc                   	cld    
  800b1e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b20:	eb ed                	jmp    800b0f <memmove+0x55>

00800b22 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b22:	55                   	push   %ebp
  800b23:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b25:	ff 75 10             	pushl  0x10(%ebp)
  800b28:	ff 75 0c             	pushl  0xc(%ebp)
  800b2b:	ff 75 08             	pushl  0x8(%ebp)
  800b2e:	e8 87 ff ff ff       	call   800aba <memmove>
}
  800b33:	c9                   	leave  
  800b34:	c3                   	ret    

00800b35 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b35:	55                   	push   %ebp
  800b36:	89 e5                	mov    %esp,%ebp
  800b38:	56                   	push   %esi
  800b39:	53                   	push   %ebx
  800b3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b40:	89 c6                	mov    %eax,%esi
  800b42:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b45:	39 f0                	cmp    %esi,%eax
  800b47:	74 1c                	je     800b65 <memcmp+0x30>
		if (*s1 != *s2)
  800b49:	0f b6 08             	movzbl (%eax),%ecx
  800b4c:	0f b6 1a             	movzbl (%edx),%ebx
  800b4f:	38 d9                	cmp    %bl,%cl
  800b51:	75 08                	jne    800b5b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b53:	83 c0 01             	add    $0x1,%eax
  800b56:	83 c2 01             	add    $0x1,%edx
  800b59:	eb ea                	jmp    800b45 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b5b:	0f b6 c1             	movzbl %cl,%eax
  800b5e:	0f b6 db             	movzbl %bl,%ebx
  800b61:	29 d8                	sub    %ebx,%eax
  800b63:	eb 05                	jmp    800b6a <memcmp+0x35>
	}

	return 0;
  800b65:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b6a:	5b                   	pop    %ebx
  800b6b:	5e                   	pop    %esi
  800b6c:	5d                   	pop    %ebp
  800b6d:	c3                   	ret    

00800b6e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b6e:	55                   	push   %ebp
  800b6f:	89 e5                	mov    %esp,%ebp
  800b71:	8b 45 08             	mov    0x8(%ebp),%eax
  800b74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b77:	89 c2                	mov    %eax,%edx
  800b79:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b7c:	39 d0                	cmp    %edx,%eax
  800b7e:	73 09                	jae    800b89 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b80:	38 08                	cmp    %cl,(%eax)
  800b82:	74 05                	je     800b89 <memfind+0x1b>
	for (; s < ends; s++)
  800b84:	83 c0 01             	add    $0x1,%eax
  800b87:	eb f3                	jmp    800b7c <memfind+0xe>
			break;
	return (void *) s;
}
  800b89:	5d                   	pop    %ebp
  800b8a:	c3                   	ret    

00800b8b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b8b:	55                   	push   %ebp
  800b8c:	89 e5                	mov    %esp,%ebp
  800b8e:	57                   	push   %edi
  800b8f:	56                   	push   %esi
  800b90:	53                   	push   %ebx
  800b91:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b94:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b97:	eb 03                	jmp    800b9c <strtol+0x11>
		s++;
  800b99:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b9c:	0f b6 01             	movzbl (%ecx),%eax
  800b9f:	3c 20                	cmp    $0x20,%al
  800ba1:	74 f6                	je     800b99 <strtol+0xe>
  800ba3:	3c 09                	cmp    $0x9,%al
  800ba5:	74 f2                	je     800b99 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800ba7:	3c 2b                	cmp    $0x2b,%al
  800ba9:	74 2e                	je     800bd9 <strtol+0x4e>
	int neg = 0;
  800bab:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800bb0:	3c 2d                	cmp    $0x2d,%al
  800bb2:	74 2f                	je     800be3 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bb4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bba:	75 05                	jne    800bc1 <strtol+0x36>
  800bbc:	80 39 30             	cmpb   $0x30,(%ecx)
  800bbf:	74 2c                	je     800bed <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bc1:	85 db                	test   %ebx,%ebx
  800bc3:	75 0a                	jne    800bcf <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bc5:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800bca:	80 39 30             	cmpb   $0x30,(%ecx)
  800bcd:	74 28                	je     800bf7 <strtol+0x6c>
		base = 10;
  800bcf:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd4:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bd7:	eb 50                	jmp    800c29 <strtol+0x9e>
		s++;
  800bd9:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800bdc:	bf 00 00 00 00       	mov    $0x0,%edi
  800be1:	eb d1                	jmp    800bb4 <strtol+0x29>
		s++, neg = 1;
  800be3:	83 c1 01             	add    $0x1,%ecx
  800be6:	bf 01 00 00 00       	mov    $0x1,%edi
  800beb:	eb c7                	jmp    800bb4 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bed:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bf1:	74 0e                	je     800c01 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800bf3:	85 db                	test   %ebx,%ebx
  800bf5:	75 d8                	jne    800bcf <strtol+0x44>
		s++, base = 8;
  800bf7:	83 c1 01             	add    $0x1,%ecx
  800bfa:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bff:	eb ce                	jmp    800bcf <strtol+0x44>
		s += 2, base = 16;
  800c01:	83 c1 02             	add    $0x2,%ecx
  800c04:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c09:	eb c4                	jmp    800bcf <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800c0b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c0e:	89 f3                	mov    %esi,%ebx
  800c10:	80 fb 19             	cmp    $0x19,%bl
  800c13:	77 29                	ja     800c3e <strtol+0xb3>
			dig = *s - 'a' + 10;
  800c15:	0f be d2             	movsbl %dl,%edx
  800c18:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c1b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c1e:	7d 30                	jge    800c50 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800c20:	83 c1 01             	add    $0x1,%ecx
  800c23:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c27:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c29:	0f b6 11             	movzbl (%ecx),%edx
  800c2c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c2f:	89 f3                	mov    %esi,%ebx
  800c31:	80 fb 09             	cmp    $0x9,%bl
  800c34:	77 d5                	ja     800c0b <strtol+0x80>
			dig = *s - '0';
  800c36:	0f be d2             	movsbl %dl,%edx
  800c39:	83 ea 30             	sub    $0x30,%edx
  800c3c:	eb dd                	jmp    800c1b <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800c3e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c41:	89 f3                	mov    %esi,%ebx
  800c43:	80 fb 19             	cmp    $0x19,%bl
  800c46:	77 08                	ja     800c50 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c48:	0f be d2             	movsbl %dl,%edx
  800c4b:	83 ea 37             	sub    $0x37,%edx
  800c4e:	eb cb                	jmp    800c1b <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c50:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c54:	74 05                	je     800c5b <strtol+0xd0>
		*endptr = (char *) s;
  800c56:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c59:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c5b:	89 c2                	mov    %eax,%edx
  800c5d:	f7 da                	neg    %edx
  800c5f:	85 ff                	test   %edi,%edi
  800c61:	0f 45 c2             	cmovne %edx,%eax
}
  800c64:	5b                   	pop    %ebx
  800c65:	5e                   	pop    %esi
  800c66:	5f                   	pop    %edi
  800c67:	5d                   	pop    %ebp
  800c68:	c3                   	ret    

00800c69 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c69:	55                   	push   %ebp
  800c6a:	89 e5                	mov    %esp,%ebp
  800c6c:	57                   	push   %edi
  800c6d:	56                   	push   %esi
  800c6e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c6f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c74:	8b 55 08             	mov    0x8(%ebp),%edx
  800c77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7a:	89 c3                	mov    %eax,%ebx
  800c7c:	89 c7                	mov    %eax,%edi
  800c7e:	89 c6                	mov    %eax,%esi
  800c80:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c82:	5b                   	pop    %ebx
  800c83:	5e                   	pop    %esi
  800c84:	5f                   	pop    %edi
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	57                   	push   %edi
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c92:	b8 01 00 00 00       	mov    $0x1,%eax
  800c97:	89 d1                	mov    %edx,%ecx
  800c99:	89 d3                	mov    %edx,%ebx
  800c9b:	89 d7                	mov    %edx,%edi
  800c9d:	89 d6                	mov    %edx,%esi
  800c9f:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ca1:	5b                   	pop    %ebx
  800ca2:	5e                   	pop    %esi
  800ca3:	5f                   	pop    %edi
  800ca4:	5d                   	pop    %ebp
  800ca5:	c3                   	ret    

00800ca6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ca6:	55                   	push   %ebp
  800ca7:	89 e5                	mov    %esp,%ebp
  800ca9:	57                   	push   %edi
  800caa:	56                   	push   %esi
  800cab:	53                   	push   %ebx
  800cac:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800caf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb7:	b8 03 00 00 00       	mov    $0x3,%eax
  800cbc:	89 cb                	mov    %ecx,%ebx
  800cbe:	89 cf                	mov    %ecx,%edi
  800cc0:	89 ce                	mov    %ecx,%esi
  800cc2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cc4:	85 c0                	test   %eax,%eax
  800cc6:	7f 08                	jg     800cd0 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
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
  800cd4:	6a 03                	push   $0x3
  800cd6:	68 df 26 80 00       	push   $0x8026df
  800cdb:	6a 23                	push   $0x23
  800cdd:	68 fc 26 80 00       	push   $0x8026fc
  800ce2:	e8 4b f5 ff ff       	call   800232 <_panic>

00800ce7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	57                   	push   %edi
  800ceb:	56                   	push   %esi
  800cec:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ced:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf2:	b8 02 00 00 00       	mov    $0x2,%eax
  800cf7:	89 d1                	mov    %edx,%ecx
  800cf9:	89 d3                	mov    %edx,%ebx
  800cfb:	89 d7                	mov    %edx,%edi
  800cfd:	89 d6                	mov    %edx,%esi
  800cff:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <sys_yield>:

void
sys_yield(void)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	57                   	push   %edi
  800d0a:	56                   	push   %esi
  800d0b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d0c:	ba 00 00 00 00       	mov    $0x0,%edx
  800d11:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d16:	89 d1                	mov    %edx,%ecx
  800d18:	89 d3                	mov    %edx,%ebx
  800d1a:	89 d7                	mov    %edx,%edi
  800d1c:	89 d6                	mov    %edx,%esi
  800d1e:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d20:	5b                   	pop    %ebx
  800d21:	5e                   	pop    %esi
  800d22:	5f                   	pop    %edi
  800d23:	5d                   	pop    %ebp
  800d24:	c3                   	ret    

00800d25 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d25:	55                   	push   %ebp
  800d26:	89 e5                	mov    %esp,%ebp
  800d28:	57                   	push   %edi
  800d29:	56                   	push   %esi
  800d2a:	53                   	push   %ebx
  800d2b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d2e:	be 00 00 00 00       	mov    $0x0,%esi
  800d33:	8b 55 08             	mov    0x8(%ebp),%edx
  800d36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d39:	b8 04 00 00 00       	mov    $0x4,%eax
  800d3e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d41:	89 f7                	mov    %esi,%edi
  800d43:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d45:	85 c0                	test   %eax,%eax
  800d47:	7f 08                	jg     800d51 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4c:	5b                   	pop    %ebx
  800d4d:	5e                   	pop    %esi
  800d4e:	5f                   	pop    %edi
  800d4f:	5d                   	pop    %ebp
  800d50:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d51:	83 ec 0c             	sub    $0xc,%esp
  800d54:	50                   	push   %eax
  800d55:	6a 04                	push   $0x4
  800d57:	68 df 26 80 00       	push   $0x8026df
  800d5c:	6a 23                	push   $0x23
  800d5e:	68 fc 26 80 00       	push   $0x8026fc
  800d63:	e8 ca f4 ff ff       	call   800232 <_panic>

00800d68 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d68:	55                   	push   %ebp
  800d69:	89 e5                	mov    %esp,%ebp
  800d6b:	57                   	push   %edi
  800d6c:	56                   	push   %esi
  800d6d:	53                   	push   %ebx
  800d6e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d71:	8b 55 08             	mov    0x8(%ebp),%edx
  800d74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d77:	b8 05 00 00 00       	mov    $0x5,%eax
  800d7c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d7f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d82:	8b 75 18             	mov    0x18(%ebp),%esi
  800d85:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d87:	85 c0                	test   %eax,%eax
  800d89:	7f 08                	jg     800d93 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d8e:	5b                   	pop    %ebx
  800d8f:	5e                   	pop    %esi
  800d90:	5f                   	pop    %edi
  800d91:	5d                   	pop    %ebp
  800d92:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d93:	83 ec 0c             	sub    $0xc,%esp
  800d96:	50                   	push   %eax
  800d97:	6a 05                	push   $0x5
  800d99:	68 df 26 80 00       	push   $0x8026df
  800d9e:	6a 23                	push   $0x23
  800da0:	68 fc 26 80 00       	push   $0x8026fc
  800da5:	e8 88 f4 ff ff       	call   800232 <_panic>

00800daa <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800daa:	55                   	push   %ebp
  800dab:	89 e5                	mov    %esp,%ebp
  800dad:	57                   	push   %edi
  800dae:	56                   	push   %esi
  800daf:	53                   	push   %ebx
  800db0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800db3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbe:	b8 06 00 00 00       	mov    $0x6,%eax
  800dc3:	89 df                	mov    %ebx,%edi
  800dc5:	89 de                	mov    %ebx,%esi
  800dc7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dc9:	85 c0                	test   %eax,%eax
  800dcb:	7f 08                	jg     800dd5 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dcd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd0:	5b                   	pop    %ebx
  800dd1:	5e                   	pop    %esi
  800dd2:	5f                   	pop    %edi
  800dd3:	5d                   	pop    %ebp
  800dd4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd5:	83 ec 0c             	sub    $0xc,%esp
  800dd8:	50                   	push   %eax
  800dd9:	6a 06                	push   $0x6
  800ddb:	68 df 26 80 00       	push   $0x8026df
  800de0:	6a 23                	push   $0x23
  800de2:	68 fc 26 80 00       	push   $0x8026fc
  800de7:	e8 46 f4 ff ff       	call   800232 <_panic>

00800dec <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dec:	55                   	push   %ebp
  800ded:	89 e5                	mov    %esp,%ebp
  800def:	57                   	push   %edi
  800df0:	56                   	push   %esi
  800df1:	53                   	push   %ebx
  800df2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800df5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e00:	b8 08 00 00 00       	mov    $0x8,%eax
  800e05:	89 df                	mov    %ebx,%edi
  800e07:	89 de                	mov    %ebx,%esi
  800e09:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e0b:	85 c0                	test   %eax,%eax
  800e0d:	7f 08                	jg     800e17 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e12:	5b                   	pop    %ebx
  800e13:	5e                   	pop    %esi
  800e14:	5f                   	pop    %edi
  800e15:	5d                   	pop    %ebp
  800e16:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e17:	83 ec 0c             	sub    $0xc,%esp
  800e1a:	50                   	push   %eax
  800e1b:	6a 08                	push   $0x8
  800e1d:	68 df 26 80 00       	push   $0x8026df
  800e22:	6a 23                	push   $0x23
  800e24:	68 fc 26 80 00       	push   $0x8026fc
  800e29:	e8 04 f4 ff ff       	call   800232 <_panic>

00800e2e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e2e:	55                   	push   %ebp
  800e2f:	89 e5                	mov    %esp,%ebp
  800e31:	57                   	push   %edi
  800e32:	56                   	push   %esi
  800e33:	53                   	push   %ebx
  800e34:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e37:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e42:	b8 09 00 00 00       	mov    $0x9,%eax
  800e47:	89 df                	mov    %ebx,%edi
  800e49:	89 de                	mov    %ebx,%esi
  800e4b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e4d:	85 c0                	test   %eax,%eax
  800e4f:	7f 08                	jg     800e59 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e54:	5b                   	pop    %ebx
  800e55:	5e                   	pop    %esi
  800e56:	5f                   	pop    %edi
  800e57:	5d                   	pop    %ebp
  800e58:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e59:	83 ec 0c             	sub    $0xc,%esp
  800e5c:	50                   	push   %eax
  800e5d:	6a 09                	push   $0x9
  800e5f:	68 df 26 80 00       	push   $0x8026df
  800e64:	6a 23                	push   $0x23
  800e66:	68 fc 26 80 00       	push   $0x8026fc
  800e6b:	e8 c2 f3 ff ff       	call   800232 <_panic>

00800e70 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e70:	55                   	push   %ebp
  800e71:	89 e5                	mov    %esp,%ebp
  800e73:	57                   	push   %edi
  800e74:	56                   	push   %esi
  800e75:	53                   	push   %ebx
  800e76:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e79:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e84:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e89:	89 df                	mov    %ebx,%edi
  800e8b:	89 de                	mov    %ebx,%esi
  800e8d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e8f:	85 c0                	test   %eax,%eax
  800e91:	7f 08                	jg     800e9b <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e96:	5b                   	pop    %ebx
  800e97:	5e                   	pop    %esi
  800e98:	5f                   	pop    %edi
  800e99:	5d                   	pop    %ebp
  800e9a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e9b:	83 ec 0c             	sub    $0xc,%esp
  800e9e:	50                   	push   %eax
  800e9f:	6a 0a                	push   $0xa
  800ea1:	68 df 26 80 00       	push   $0x8026df
  800ea6:	6a 23                	push   $0x23
  800ea8:	68 fc 26 80 00       	push   $0x8026fc
  800ead:	e8 80 f3 ff ff       	call   800232 <_panic>

00800eb2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800eb2:	55                   	push   %ebp
  800eb3:	89 e5                	mov    %esp,%ebp
  800eb5:	57                   	push   %edi
  800eb6:	56                   	push   %esi
  800eb7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800eb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ebe:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ec3:	be 00 00 00 00       	mov    $0x0,%esi
  800ec8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ecb:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ece:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ed0:	5b                   	pop    %ebx
  800ed1:	5e                   	pop    %esi
  800ed2:	5f                   	pop    %edi
  800ed3:	5d                   	pop    %ebp
  800ed4:	c3                   	ret    

00800ed5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ed5:	55                   	push   %ebp
  800ed6:	89 e5                	mov    %esp,%ebp
  800ed8:	57                   	push   %edi
  800ed9:	56                   	push   %esi
  800eda:	53                   	push   %ebx
  800edb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ede:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ee3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee6:	b8 0d 00 00 00       	mov    $0xd,%eax
  800eeb:	89 cb                	mov    %ecx,%ebx
  800eed:	89 cf                	mov    %ecx,%edi
  800eef:	89 ce                	mov    %ecx,%esi
  800ef1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ef3:	85 c0                	test   %eax,%eax
  800ef5:	7f 08                	jg     800eff <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ef7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800efa:	5b                   	pop    %ebx
  800efb:	5e                   	pop    %esi
  800efc:	5f                   	pop    %edi
  800efd:	5d                   	pop    %ebp
  800efe:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800eff:	83 ec 0c             	sub    $0xc,%esp
  800f02:	50                   	push   %eax
  800f03:	6a 0d                	push   $0xd
  800f05:	68 df 26 80 00       	push   $0x8026df
  800f0a:	6a 23                	push   $0x23
  800f0c:	68 fc 26 80 00       	push   $0x8026fc
  800f11:	e8 1c f3 ff ff       	call   800232 <_panic>

00800f16 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f16:	55                   	push   %ebp
  800f17:	89 e5                	mov    %esp,%ebp
  800f19:	56                   	push   %esi
  800f1a:	53                   	push   %ebx
  800f1b:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f1e:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if((err&FEC_WR)==0 || (uvpt[PGNUM(addr)]&(PTE_W|PTE_COW))==0){
  800f20:	8b 40 04             	mov    0x4(%eax),%eax
  800f23:	83 e0 02             	and    $0x2,%eax
  800f26:	0f 84 82 00 00 00    	je     800fae <pgfault+0x98>
  800f2c:	89 da                	mov    %ebx,%edx
  800f2e:	c1 ea 0c             	shr    $0xc,%edx
  800f31:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f38:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800f3e:	74 6e                	je     800fae <pgfault+0x98>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        envid_t envid = sys_getenvid();
  800f40:	e8 a2 fd ff ff       	call   800ce7 <sys_getenvid>
  800f45:	89 c6                	mov    %eax,%esi
	r = sys_page_alloc(envid,(void *)PFTEMP,PTE_P|PTE_W|PTE_U);
  800f47:	83 ec 04             	sub    $0x4,%esp
  800f4a:	6a 07                	push   $0x7
  800f4c:	68 00 f0 7f 00       	push   $0x7ff000
  800f51:	50                   	push   %eax
  800f52:	e8 ce fd ff ff       	call   800d25 <sys_page_alloc>
	if(r<0) panic("pgfault:page allocation failed %e",r);
  800f57:	83 c4 10             	add    $0x10,%esp
  800f5a:	85 c0                	test   %eax,%eax
  800f5c:	78 72                	js     800fd0 <pgfault+0xba>

	addr = ROUNDDOWN(addr,PGSIZE);
  800f5e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy((void *)PFTEMP,(const void *)addr,PGSIZE);
  800f64:	83 ec 04             	sub    $0x4,%esp
  800f67:	68 00 10 00 00       	push   $0x1000
  800f6c:	53                   	push   %ebx
  800f6d:	68 00 f0 7f 00       	push   $0x7ff000
  800f72:	e8 ab fb ff ff       	call   800b22 <memcpy>

	if(sys_page_map(envid,(void *)PFTEMP, envid,addr,PTE_P|PTE_W|PTE_U)<0)
  800f77:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f7e:	53                   	push   %ebx
  800f7f:	56                   	push   %esi
  800f80:	68 00 f0 7f 00       	push   $0x7ff000
  800f85:	56                   	push   %esi
  800f86:	e8 dd fd ff ff       	call   800d68 <sys_page_map>
  800f8b:	83 c4 20             	add    $0x20,%esp
  800f8e:	85 c0                	test   %eax,%eax
  800f90:	78 50                	js     800fe2 <pgfault+0xcc>
		panic("pgfault:page map failed\n");
	if(sys_page_unmap(envid,(void *)PFTEMP)<0)
  800f92:	83 ec 08             	sub    $0x8,%esp
  800f95:	68 00 f0 7f 00       	push   $0x7ff000
  800f9a:	56                   	push   %esi
  800f9b:	e8 0a fe ff ff       	call   800daa <sys_page_unmap>
  800fa0:	83 c4 10             	add    $0x10,%esp
  800fa3:	85 c0                	test   %eax,%eax
  800fa5:	78 4f                	js     800ff6 <pgfault+0xe0>
		panic("pgfault: page upmap failed\n");
       //	panic("pgfault not implemented");
}
  800fa7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800faa:	5b                   	pop    %ebx
  800fab:	5e                   	pop    %esi
  800fac:	5d                   	pop    %ebp
  800fad:	c3                   	ret    
		cprintf("Where is the error %d\n",err&FEC_WR);
  800fae:	83 ec 08             	sub    $0x8,%esp
  800fb1:	50                   	push   %eax
  800fb2:	68 0a 27 80 00       	push   $0x80270a
  800fb7:	e8 51 f3 ff ff       	call   80030d <cprintf>
		panic("pgfault:invalid user trap");
  800fbc:	83 c4 0c             	add    $0xc,%esp
  800fbf:	68 21 27 80 00       	push   $0x802721
  800fc4:	6a 1e                	push   $0x1e
  800fc6:	68 3b 27 80 00       	push   $0x80273b
  800fcb:	e8 62 f2 ff ff       	call   800232 <_panic>
	if(r<0) panic("pgfault:page allocation failed %e",r);
  800fd0:	50                   	push   %eax
  800fd1:	68 28 28 80 00       	push   $0x802828
  800fd6:	6a 29                	push   $0x29
  800fd8:	68 3b 27 80 00       	push   $0x80273b
  800fdd:	e8 50 f2 ff ff       	call   800232 <_panic>
		panic("pgfault:page map failed\n");
  800fe2:	83 ec 04             	sub    $0x4,%esp
  800fe5:	68 46 27 80 00       	push   $0x802746
  800fea:	6a 2f                	push   $0x2f
  800fec:	68 3b 27 80 00       	push   $0x80273b
  800ff1:	e8 3c f2 ff ff       	call   800232 <_panic>
		panic("pgfault: page upmap failed\n");
  800ff6:	83 ec 04             	sub    $0x4,%esp
  800ff9:	68 5f 27 80 00       	push   $0x80275f
  800ffe:	6a 31                	push   $0x31
  801000:	68 3b 27 80 00       	push   $0x80273b
  801005:	e8 28 f2 ff ff       	call   800232 <_panic>

0080100a <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80100a:	55                   	push   %ebp
  80100b:	89 e5                	mov    %esp,%ebp
  80100d:	57                   	push   %edi
  80100e:	56                   	push   %esi
  80100f:	53                   	push   %ebx
  801010:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	set_pgfault_handler(pgfault);
  801013:	68 16 0f 80 00       	push   $0x800f16
  801018:	e8 b5 0e 00 00       	call   801ed2 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80101d:	b8 07 00 00 00       	mov    $0x7,%eax
  801022:	cd 30                	int    $0x30
  801024:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801027:	89 45 e0             	mov    %eax,-0x20(%ebp)
       
	envid_t envid = sys_exofork();
	uintptr_t addr;
  
	if(envid<0) panic("sys_exofork failed\n");
  80102a:	83 c4 10             	add    $0x10,%esp
  80102d:	85 c0                	test   %eax,%eax
  80102f:	78 27                	js     801058 <fork+0x4e>
	if(envid==0){
	  thisenv = &envs[ENVX(sys_getenvid())];
	  return 0;
	}

	for(addr=(uintptr_t)UTEXT; addr<USTACKTOP;addr+=PGSIZE){
  801031:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if(envid==0){
  801036:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80103a:	75 5e                	jne    80109a <fork+0x90>
	  thisenv = &envs[ENVX(sys_getenvid())];
  80103c:	e8 a6 fc ff ff       	call   800ce7 <sys_getenvid>
  801041:	25 ff 03 00 00       	and    $0x3ff,%eax
  801046:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801049:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80104e:	a3 04 40 80 00       	mov    %eax,0x804004
	  return 0;
  801053:	e9 fc 00 00 00       	jmp    801154 <fork+0x14a>
	if(envid<0) panic("sys_exofork failed\n");
  801058:	83 ec 04             	sub    $0x4,%esp
  80105b:	68 7b 27 80 00       	push   $0x80277b
  801060:	6a 77                	push   $0x77
  801062:	68 3b 27 80 00       	push   $0x80273b
  801067:	e8 c6 f1 ff ff       	call   800232 <_panic>
          if((r=sys_page_map(parent_envid,va,envid,va,uvpt[pn]&PTE_SYSCALL))<0)
  80106c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801073:	83 ec 0c             	sub    $0xc,%esp
  801076:	25 07 0e 00 00       	and    $0xe07,%eax
  80107b:	50                   	push   %eax
  80107c:	57                   	push   %edi
  80107d:	ff 75 e0             	pushl  -0x20(%ebp)
  801080:	57                   	push   %edi
  801081:	ff 75 e4             	pushl  -0x1c(%ebp)
  801084:	e8 df fc ff ff       	call   800d68 <sys_page_map>
  801089:	83 c4 20             	add    $0x20,%esp
	for(addr=(uintptr_t)UTEXT; addr<USTACKTOP;addr+=PGSIZE){
  80108c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801092:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801098:	74 76                	je     801110 <fork+0x106>
	   if((uvpd[PDX(addr)]&PTE_P) && uvpt[PGNUM(addr)] & PTE_P)
  80109a:	89 d8                	mov    %ebx,%eax
  80109c:	c1 e8 16             	shr    $0x16,%eax
  80109f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010a6:	a8 01                	test   $0x1,%al
  8010a8:	74 e2                	je     80108c <fork+0x82>
  8010aa:	89 de                	mov    %ebx,%esi
  8010ac:	c1 ee 0c             	shr    $0xc,%esi
  8010af:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010b6:	a8 01                	test   $0x1,%al
  8010b8:	74 d2                	je     80108c <fork+0x82>
        envid_t parent_envid = sys_getenvid();
  8010ba:	e8 28 fc ff ff       	call   800ce7 <sys_getenvid>
  8010bf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	void *va = (void *)(pn*PGSIZE);
  8010c2:	89 f7                	mov    %esi,%edi
  8010c4:	c1 e7 0c             	shl    $0xc,%edi
        if(uvpt[pn] & PTE_SHARE){
  8010c7:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010ce:	f6 c4 04             	test   $0x4,%ah
  8010d1:	75 99                	jne    80106c <fork+0x62>
	if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)){
  8010d3:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010da:	a8 02                	test   $0x2,%al
  8010dc:	0f 85 ed 00 00 00    	jne    8011cf <fork+0x1c5>
  8010e2:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010e9:	f6 c4 08             	test   $0x8,%ah
  8010ec:	0f 85 dd 00 00 00    	jne    8011cf <fork+0x1c5>
	 if((r=sys_page_map(parent_envid,va,envid,va,perm))<0)
  8010f2:	83 ec 0c             	sub    $0xc,%esp
  8010f5:	6a 05                	push   $0x5
  8010f7:	57                   	push   %edi
  8010f8:	ff 75 e0             	pushl  -0x20(%ebp)
  8010fb:	57                   	push   %edi
  8010fc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010ff:	e8 64 fc ff ff       	call   800d68 <sys_page_map>
  801104:	83 c4 20             	add    $0x20,%esp
  801107:	85 c0                	test   %eax,%eax
  801109:	79 81                	jns    80108c <fork+0x82>
  80110b:	e9 db 00 00 00       	jmp    8011eb <fork+0x1e1>
		   duppage(envid,PGNUM(addr));
	}
        
	int r;
	if((r=sys_page_alloc(envid,(void *)UXSTACKTOP-PGSIZE,PTE_U|PTE_P|PTE_W))<0)
  801110:	83 ec 04             	sub    $0x4,%esp
  801113:	6a 07                	push   $0x7
  801115:	68 00 f0 bf ee       	push   $0xeebff000
  80111a:	ff 75 dc             	pushl  -0x24(%ebp)
  80111d:	e8 03 fc ff ff       	call   800d25 <sys_page_alloc>
  801122:	83 c4 10             	add    $0x10,%esp
  801125:	85 c0                	test   %eax,%eax
  801127:	78 36                	js     80115f <fork+0x155>
		panic("fork:page alloc failed %e\n",r);

	extern void _pgfault_upcall();
	if((r = sys_env_set_pgfault_upcall(envid,_pgfault_upcall)))
  801129:	83 ec 08             	sub    $0x8,%esp
  80112c:	68 37 1f 80 00       	push   $0x801f37
  801131:	ff 75 dc             	pushl  -0x24(%ebp)
  801134:	e8 37 fd ff ff       	call   800e70 <sys_env_set_pgfault_upcall>
  801139:	83 c4 10             	add    $0x10,%esp
  80113c:	85 c0                	test   %eax,%eax
  80113e:	75 34                	jne    801174 <fork+0x16a>
		panic("fork:set upcall failed %e\n",r);
	if((r = sys_env_set_status(envid,ENV_RUNNABLE))<0)
  801140:	83 ec 08             	sub    $0x8,%esp
  801143:	6a 02                	push   $0x2
  801145:	ff 75 dc             	pushl  -0x24(%ebp)
  801148:	e8 9f fc ff ff       	call   800dec <sys_env_set_status>
  80114d:	83 c4 10             	add    $0x10,%esp
  801150:	85 c0                	test   %eax,%eax
  801152:	78 35                	js     801189 <fork+0x17f>
		panic("fork:set status failed %e\n",r);
	//cprintf("forkid= %d\n", envid);
	return envid;
       	
}
  801154:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801157:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80115a:	5b                   	pop    %ebx
  80115b:	5e                   	pop    %esi
  80115c:	5f                   	pop    %edi
  80115d:	5d                   	pop    %ebp
  80115e:	c3                   	ret    
		panic("fork:page alloc failed %e\n",r);
  80115f:	50                   	push   %eax
  801160:	68 bf 27 80 00       	push   $0x8027bf
  801165:	68 84 00 00 00       	push   $0x84
  80116a:	68 3b 27 80 00       	push   $0x80273b
  80116f:	e8 be f0 ff ff       	call   800232 <_panic>
		panic("fork:set upcall failed %e\n",r);
  801174:	50                   	push   %eax
  801175:	68 da 27 80 00       	push   $0x8027da
  80117a:	68 88 00 00 00       	push   $0x88
  80117f:	68 3b 27 80 00       	push   $0x80273b
  801184:	e8 a9 f0 ff ff       	call   800232 <_panic>
		panic("fork:set status failed %e\n",r);
  801189:	50                   	push   %eax
  80118a:	68 f5 27 80 00       	push   $0x8027f5
  80118f:	68 8a 00 00 00       	push   $0x8a
  801194:	68 3b 27 80 00       	push   $0x80273b
  801199:	e8 94 f0 ff ff       	call   800232 <_panic>
		if( (r=sys_page_map(parent_envid,va,parent_envid,va,perm))<0){
  80119e:	83 ec 0c             	sub    $0xc,%esp
  8011a1:	68 05 08 00 00       	push   $0x805
  8011a6:	57                   	push   %edi
  8011a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011aa:	50                   	push   %eax
  8011ab:	57                   	push   %edi
  8011ac:	50                   	push   %eax
  8011ad:	e8 b6 fb ff ff       	call   800d68 <sys_page_map>
  8011b2:	83 c4 20             	add    $0x20,%esp
  8011b5:	85 c0                	test   %eax,%eax
  8011b7:	0f 89 cf fe ff ff    	jns    80108c <fork+0x82>
		 panic("duppage:map02 failed %e",r);
  8011bd:	50                   	push   %eax
  8011be:	68 a7 27 80 00       	push   $0x8027a7
  8011c3:	6a 56                	push   $0x56
  8011c5:	68 3b 27 80 00       	push   $0x80273b
  8011ca:	e8 63 f0 ff ff       	call   800232 <_panic>
	 if((r=sys_page_map(parent_envid,va,envid,va,perm))<0)
  8011cf:	83 ec 0c             	sub    $0xc,%esp
  8011d2:	68 05 08 00 00       	push   $0x805
  8011d7:	57                   	push   %edi
  8011d8:	ff 75 e0             	pushl  -0x20(%ebp)
  8011db:	57                   	push   %edi
  8011dc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011df:	e8 84 fb ff ff       	call   800d68 <sys_page_map>
  8011e4:	83 c4 20             	add    $0x20,%esp
  8011e7:	85 c0                	test   %eax,%eax
  8011e9:	79 b3                	jns    80119e <fork+0x194>
		 panic("duppage:map01 failed %e",r);
  8011eb:	50                   	push   %eax
  8011ec:	68 8f 27 80 00       	push   $0x80278f
  8011f1:	6a 53                	push   $0x53
  8011f3:	68 3b 27 80 00       	push   $0x80273b
  8011f8:	e8 35 f0 ff ff       	call   800232 <_panic>

008011fd <sfork>:

// Challenge!
int
sfork(void)
{
  8011fd:	55                   	push   %ebp
  8011fe:	89 e5                	mov    %esp,%ebp
  801200:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801203:	68 10 28 80 00       	push   $0x802810
  801208:	68 94 00 00 00       	push   $0x94
  80120d:	68 3b 27 80 00       	push   $0x80273b
  801212:	e8 1b f0 ff ff       	call   800232 <_panic>

00801217 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801217:	55                   	push   %ebp
  801218:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80121a:	8b 45 08             	mov    0x8(%ebp),%eax
  80121d:	05 00 00 00 30       	add    $0x30000000,%eax
  801222:	c1 e8 0c             	shr    $0xc,%eax
}
  801225:	5d                   	pop    %ebp
  801226:	c3                   	ret    

00801227 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801227:	55                   	push   %ebp
  801228:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80122a:	8b 45 08             	mov    0x8(%ebp),%eax
  80122d:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801232:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801237:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80123c:	5d                   	pop    %ebp
  80123d:	c3                   	ret    

0080123e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80123e:	55                   	push   %ebp
  80123f:	89 e5                	mov    %esp,%ebp
  801241:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801244:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801249:	89 c2                	mov    %eax,%edx
  80124b:	c1 ea 16             	shr    $0x16,%edx
  80124e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801255:	f6 c2 01             	test   $0x1,%dl
  801258:	74 2a                	je     801284 <fd_alloc+0x46>
  80125a:	89 c2                	mov    %eax,%edx
  80125c:	c1 ea 0c             	shr    $0xc,%edx
  80125f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801266:	f6 c2 01             	test   $0x1,%dl
  801269:	74 19                	je     801284 <fd_alloc+0x46>
  80126b:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801270:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801275:	75 d2                	jne    801249 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801277:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80127d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801282:	eb 07                	jmp    80128b <fd_alloc+0x4d>
			*fd_store = fd;
  801284:	89 01                	mov    %eax,(%ecx)
			return 0;
  801286:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80128b:	5d                   	pop    %ebp
  80128c:	c3                   	ret    

0080128d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80128d:	55                   	push   %ebp
  80128e:	89 e5                	mov    %esp,%ebp
  801290:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801293:	83 f8 1f             	cmp    $0x1f,%eax
  801296:	77 36                	ja     8012ce <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801298:	c1 e0 0c             	shl    $0xc,%eax
  80129b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012a0:	89 c2                	mov    %eax,%edx
  8012a2:	c1 ea 16             	shr    $0x16,%edx
  8012a5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012ac:	f6 c2 01             	test   $0x1,%dl
  8012af:	74 24                	je     8012d5 <fd_lookup+0x48>
  8012b1:	89 c2                	mov    %eax,%edx
  8012b3:	c1 ea 0c             	shr    $0xc,%edx
  8012b6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012bd:	f6 c2 01             	test   $0x1,%dl
  8012c0:	74 1a                	je     8012dc <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012c5:	89 02                	mov    %eax,(%edx)
	return 0;
  8012c7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012cc:	5d                   	pop    %ebp
  8012cd:	c3                   	ret    
		return -E_INVAL;
  8012ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012d3:	eb f7                	jmp    8012cc <fd_lookup+0x3f>
		return -E_INVAL;
  8012d5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012da:	eb f0                	jmp    8012cc <fd_lookup+0x3f>
  8012dc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012e1:	eb e9                	jmp    8012cc <fd_lookup+0x3f>

008012e3 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012e3:	55                   	push   %ebp
  8012e4:	89 e5                	mov    %esp,%ebp
  8012e6:	83 ec 08             	sub    $0x8,%esp
  8012e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012ec:	ba cc 28 80 00       	mov    $0x8028cc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012f1:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  8012f6:	39 08                	cmp    %ecx,(%eax)
  8012f8:	74 33                	je     80132d <dev_lookup+0x4a>
  8012fa:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  8012fd:	8b 02                	mov    (%edx),%eax
  8012ff:	85 c0                	test   %eax,%eax
  801301:	75 f3                	jne    8012f6 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801303:	a1 04 40 80 00       	mov    0x804004,%eax
  801308:	8b 40 48             	mov    0x48(%eax),%eax
  80130b:	83 ec 04             	sub    $0x4,%esp
  80130e:	51                   	push   %ecx
  80130f:	50                   	push   %eax
  801310:	68 4c 28 80 00       	push   $0x80284c
  801315:	e8 f3 ef ff ff       	call   80030d <cprintf>
	*dev = 0;
  80131a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80131d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801323:	83 c4 10             	add    $0x10,%esp
  801326:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80132b:	c9                   	leave  
  80132c:	c3                   	ret    
			*dev = devtab[i];
  80132d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801330:	89 01                	mov    %eax,(%ecx)
			return 0;
  801332:	b8 00 00 00 00       	mov    $0x0,%eax
  801337:	eb f2                	jmp    80132b <dev_lookup+0x48>

00801339 <fd_close>:
{
  801339:	55                   	push   %ebp
  80133a:	89 e5                	mov    %esp,%ebp
  80133c:	57                   	push   %edi
  80133d:	56                   	push   %esi
  80133e:	53                   	push   %ebx
  80133f:	83 ec 1c             	sub    $0x1c,%esp
  801342:	8b 75 08             	mov    0x8(%ebp),%esi
  801345:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801348:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80134b:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80134c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801352:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801355:	50                   	push   %eax
  801356:	e8 32 ff ff ff       	call   80128d <fd_lookup>
  80135b:	89 c3                	mov    %eax,%ebx
  80135d:	83 c4 08             	add    $0x8,%esp
  801360:	85 c0                	test   %eax,%eax
  801362:	78 05                	js     801369 <fd_close+0x30>
	    || fd != fd2)
  801364:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801367:	74 16                	je     80137f <fd_close+0x46>
		return (must_exist ? r : 0);
  801369:	89 f8                	mov    %edi,%eax
  80136b:	84 c0                	test   %al,%al
  80136d:	b8 00 00 00 00       	mov    $0x0,%eax
  801372:	0f 44 d8             	cmove  %eax,%ebx
}
  801375:	89 d8                	mov    %ebx,%eax
  801377:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80137a:	5b                   	pop    %ebx
  80137b:	5e                   	pop    %esi
  80137c:	5f                   	pop    %edi
  80137d:	5d                   	pop    %ebp
  80137e:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80137f:	83 ec 08             	sub    $0x8,%esp
  801382:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801385:	50                   	push   %eax
  801386:	ff 36                	pushl  (%esi)
  801388:	e8 56 ff ff ff       	call   8012e3 <dev_lookup>
  80138d:	89 c3                	mov    %eax,%ebx
  80138f:	83 c4 10             	add    $0x10,%esp
  801392:	85 c0                	test   %eax,%eax
  801394:	78 15                	js     8013ab <fd_close+0x72>
		if (dev->dev_close)
  801396:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801399:	8b 40 10             	mov    0x10(%eax),%eax
  80139c:	85 c0                	test   %eax,%eax
  80139e:	74 1b                	je     8013bb <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  8013a0:	83 ec 0c             	sub    $0xc,%esp
  8013a3:	56                   	push   %esi
  8013a4:	ff d0                	call   *%eax
  8013a6:	89 c3                	mov    %eax,%ebx
  8013a8:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8013ab:	83 ec 08             	sub    $0x8,%esp
  8013ae:	56                   	push   %esi
  8013af:	6a 00                	push   $0x0
  8013b1:	e8 f4 f9 ff ff       	call   800daa <sys_page_unmap>
	return r;
  8013b6:	83 c4 10             	add    $0x10,%esp
  8013b9:	eb ba                	jmp    801375 <fd_close+0x3c>
			r = 0;
  8013bb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013c0:	eb e9                	jmp    8013ab <fd_close+0x72>

008013c2 <close>:

int
close(int fdnum)
{
  8013c2:	55                   	push   %ebp
  8013c3:	89 e5                	mov    %esp,%ebp
  8013c5:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013cb:	50                   	push   %eax
  8013cc:	ff 75 08             	pushl  0x8(%ebp)
  8013cf:	e8 b9 fe ff ff       	call   80128d <fd_lookup>
  8013d4:	83 c4 08             	add    $0x8,%esp
  8013d7:	85 c0                	test   %eax,%eax
  8013d9:	78 10                	js     8013eb <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013db:	83 ec 08             	sub    $0x8,%esp
  8013de:	6a 01                	push   $0x1
  8013e0:	ff 75 f4             	pushl  -0xc(%ebp)
  8013e3:	e8 51 ff ff ff       	call   801339 <fd_close>
  8013e8:	83 c4 10             	add    $0x10,%esp
}
  8013eb:	c9                   	leave  
  8013ec:	c3                   	ret    

008013ed <close_all>:

void
close_all(void)
{
  8013ed:	55                   	push   %ebp
  8013ee:	89 e5                	mov    %esp,%ebp
  8013f0:	53                   	push   %ebx
  8013f1:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013f4:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013f9:	83 ec 0c             	sub    $0xc,%esp
  8013fc:	53                   	push   %ebx
  8013fd:	e8 c0 ff ff ff       	call   8013c2 <close>
	for (i = 0; i < MAXFD; i++)
  801402:	83 c3 01             	add    $0x1,%ebx
  801405:	83 c4 10             	add    $0x10,%esp
  801408:	83 fb 20             	cmp    $0x20,%ebx
  80140b:	75 ec                	jne    8013f9 <close_all+0xc>
}
  80140d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801410:	c9                   	leave  
  801411:	c3                   	ret    

00801412 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801412:	55                   	push   %ebp
  801413:	89 e5                	mov    %esp,%ebp
  801415:	57                   	push   %edi
  801416:	56                   	push   %esi
  801417:	53                   	push   %ebx
  801418:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80141b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80141e:	50                   	push   %eax
  80141f:	ff 75 08             	pushl  0x8(%ebp)
  801422:	e8 66 fe ff ff       	call   80128d <fd_lookup>
  801427:	89 c3                	mov    %eax,%ebx
  801429:	83 c4 08             	add    $0x8,%esp
  80142c:	85 c0                	test   %eax,%eax
  80142e:	0f 88 81 00 00 00    	js     8014b5 <dup+0xa3>
		return r;
	close(newfdnum);
  801434:	83 ec 0c             	sub    $0xc,%esp
  801437:	ff 75 0c             	pushl  0xc(%ebp)
  80143a:	e8 83 ff ff ff       	call   8013c2 <close>

	newfd = INDEX2FD(newfdnum);
  80143f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801442:	c1 e6 0c             	shl    $0xc,%esi
  801445:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80144b:	83 c4 04             	add    $0x4,%esp
  80144e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801451:	e8 d1 fd ff ff       	call   801227 <fd2data>
  801456:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801458:	89 34 24             	mov    %esi,(%esp)
  80145b:	e8 c7 fd ff ff       	call   801227 <fd2data>
  801460:	83 c4 10             	add    $0x10,%esp
  801463:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801465:	89 d8                	mov    %ebx,%eax
  801467:	c1 e8 16             	shr    $0x16,%eax
  80146a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801471:	a8 01                	test   $0x1,%al
  801473:	74 11                	je     801486 <dup+0x74>
  801475:	89 d8                	mov    %ebx,%eax
  801477:	c1 e8 0c             	shr    $0xc,%eax
  80147a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801481:	f6 c2 01             	test   $0x1,%dl
  801484:	75 39                	jne    8014bf <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801486:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801489:	89 d0                	mov    %edx,%eax
  80148b:	c1 e8 0c             	shr    $0xc,%eax
  80148e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801495:	83 ec 0c             	sub    $0xc,%esp
  801498:	25 07 0e 00 00       	and    $0xe07,%eax
  80149d:	50                   	push   %eax
  80149e:	56                   	push   %esi
  80149f:	6a 00                	push   $0x0
  8014a1:	52                   	push   %edx
  8014a2:	6a 00                	push   $0x0
  8014a4:	e8 bf f8 ff ff       	call   800d68 <sys_page_map>
  8014a9:	89 c3                	mov    %eax,%ebx
  8014ab:	83 c4 20             	add    $0x20,%esp
  8014ae:	85 c0                	test   %eax,%eax
  8014b0:	78 31                	js     8014e3 <dup+0xd1>
		goto err;

	return newfdnum;
  8014b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8014b5:	89 d8                	mov    %ebx,%eax
  8014b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014ba:	5b                   	pop    %ebx
  8014bb:	5e                   	pop    %esi
  8014bc:	5f                   	pop    %edi
  8014bd:	5d                   	pop    %ebp
  8014be:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014bf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014c6:	83 ec 0c             	sub    $0xc,%esp
  8014c9:	25 07 0e 00 00       	and    $0xe07,%eax
  8014ce:	50                   	push   %eax
  8014cf:	57                   	push   %edi
  8014d0:	6a 00                	push   $0x0
  8014d2:	53                   	push   %ebx
  8014d3:	6a 00                	push   $0x0
  8014d5:	e8 8e f8 ff ff       	call   800d68 <sys_page_map>
  8014da:	89 c3                	mov    %eax,%ebx
  8014dc:	83 c4 20             	add    $0x20,%esp
  8014df:	85 c0                	test   %eax,%eax
  8014e1:	79 a3                	jns    801486 <dup+0x74>
	sys_page_unmap(0, newfd);
  8014e3:	83 ec 08             	sub    $0x8,%esp
  8014e6:	56                   	push   %esi
  8014e7:	6a 00                	push   $0x0
  8014e9:	e8 bc f8 ff ff       	call   800daa <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014ee:	83 c4 08             	add    $0x8,%esp
  8014f1:	57                   	push   %edi
  8014f2:	6a 00                	push   $0x0
  8014f4:	e8 b1 f8 ff ff       	call   800daa <sys_page_unmap>
	return r;
  8014f9:	83 c4 10             	add    $0x10,%esp
  8014fc:	eb b7                	jmp    8014b5 <dup+0xa3>

008014fe <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014fe:	55                   	push   %ebp
  8014ff:	89 e5                	mov    %esp,%ebp
  801501:	53                   	push   %ebx
  801502:	83 ec 14             	sub    $0x14,%esp
  801505:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801508:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80150b:	50                   	push   %eax
  80150c:	53                   	push   %ebx
  80150d:	e8 7b fd ff ff       	call   80128d <fd_lookup>
  801512:	83 c4 08             	add    $0x8,%esp
  801515:	85 c0                	test   %eax,%eax
  801517:	78 3f                	js     801558 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801519:	83 ec 08             	sub    $0x8,%esp
  80151c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80151f:	50                   	push   %eax
  801520:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801523:	ff 30                	pushl  (%eax)
  801525:	e8 b9 fd ff ff       	call   8012e3 <dev_lookup>
  80152a:	83 c4 10             	add    $0x10,%esp
  80152d:	85 c0                	test   %eax,%eax
  80152f:	78 27                	js     801558 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801531:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801534:	8b 42 08             	mov    0x8(%edx),%eax
  801537:	83 e0 03             	and    $0x3,%eax
  80153a:	83 f8 01             	cmp    $0x1,%eax
  80153d:	74 1e                	je     80155d <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80153f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801542:	8b 40 08             	mov    0x8(%eax),%eax
  801545:	85 c0                	test   %eax,%eax
  801547:	74 35                	je     80157e <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801549:	83 ec 04             	sub    $0x4,%esp
  80154c:	ff 75 10             	pushl  0x10(%ebp)
  80154f:	ff 75 0c             	pushl  0xc(%ebp)
  801552:	52                   	push   %edx
  801553:	ff d0                	call   *%eax
  801555:	83 c4 10             	add    $0x10,%esp
}
  801558:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80155b:	c9                   	leave  
  80155c:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80155d:	a1 04 40 80 00       	mov    0x804004,%eax
  801562:	8b 40 48             	mov    0x48(%eax),%eax
  801565:	83 ec 04             	sub    $0x4,%esp
  801568:	53                   	push   %ebx
  801569:	50                   	push   %eax
  80156a:	68 90 28 80 00       	push   $0x802890
  80156f:	e8 99 ed ff ff       	call   80030d <cprintf>
		return -E_INVAL;
  801574:	83 c4 10             	add    $0x10,%esp
  801577:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80157c:	eb da                	jmp    801558 <read+0x5a>
		return -E_NOT_SUPP;
  80157e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801583:	eb d3                	jmp    801558 <read+0x5a>

00801585 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801585:	55                   	push   %ebp
  801586:	89 e5                	mov    %esp,%ebp
  801588:	57                   	push   %edi
  801589:	56                   	push   %esi
  80158a:	53                   	push   %ebx
  80158b:	83 ec 0c             	sub    $0xc,%esp
  80158e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801591:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801594:	bb 00 00 00 00       	mov    $0x0,%ebx
  801599:	39 f3                	cmp    %esi,%ebx
  80159b:	73 25                	jae    8015c2 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80159d:	83 ec 04             	sub    $0x4,%esp
  8015a0:	89 f0                	mov    %esi,%eax
  8015a2:	29 d8                	sub    %ebx,%eax
  8015a4:	50                   	push   %eax
  8015a5:	89 d8                	mov    %ebx,%eax
  8015a7:	03 45 0c             	add    0xc(%ebp),%eax
  8015aa:	50                   	push   %eax
  8015ab:	57                   	push   %edi
  8015ac:	e8 4d ff ff ff       	call   8014fe <read>
		if (m < 0)
  8015b1:	83 c4 10             	add    $0x10,%esp
  8015b4:	85 c0                	test   %eax,%eax
  8015b6:	78 08                	js     8015c0 <readn+0x3b>
			return m;
		if (m == 0)
  8015b8:	85 c0                	test   %eax,%eax
  8015ba:	74 06                	je     8015c2 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  8015bc:	01 c3                	add    %eax,%ebx
  8015be:	eb d9                	jmp    801599 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015c0:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8015c2:	89 d8                	mov    %ebx,%eax
  8015c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015c7:	5b                   	pop    %ebx
  8015c8:	5e                   	pop    %esi
  8015c9:	5f                   	pop    %edi
  8015ca:	5d                   	pop    %ebp
  8015cb:	c3                   	ret    

008015cc <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015cc:	55                   	push   %ebp
  8015cd:	89 e5                	mov    %esp,%ebp
  8015cf:	53                   	push   %ebx
  8015d0:	83 ec 14             	sub    $0x14,%esp
  8015d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015d9:	50                   	push   %eax
  8015da:	53                   	push   %ebx
  8015db:	e8 ad fc ff ff       	call   80128d <fd_lookup>
  8015e0:	83 c4 08             	add    $0x8,%esp
  8015e3:	85 c0                	test   %eax,%eax
  8015e5:	78 3a                	js     801621 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e7:	83 ec 08             	sub    $0x8,%esp
  8015ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ed:	50                   	push   %eax
  8015ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f1:	ff 30                	pushl  (%eax)
  8015f3:	e8 eb fc ff ff       	call   8012e3 <dev_lookup>
  8015f8:	83 c4 10             	add    $0x10,%esp
  8015fb:	85 c0                	test   %eax,%eax
  8015fd:	78 22                	js     801621 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801602:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801606:	74 1e                	je     801626 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801608:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80160b:	8b 52 0c             	mov    0xc(%edx),%edx
  80160e:	85 d2                	test   %edx,%edx
  801610:	74 35                	je     801647 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801612:	83 ec 04             	sub    $0x4,%esp
  801615:	ff 75 10             	pushl  0x10(%ebp)
  801618:	ff 75 0c             	pushl  0xc(%ebp)
  80161b:	50                   	push   %eax
  80161c:	ff d2                	call   *%edx
  80161e:	83 c4 10             	add    $0x10,%esp
}
  801621:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801624:	c9                   	leave  
  801625:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801626:	a1 04 40 80 00       	mov    0x804004,%eax
  80162b:	8b 40 48             	mov    0x48(%eax),%eax
  80162e:	83 ec 04             	sub    $0x4,%esp
  801631:	53                   	push   %ebx
  801632:	50                   	push   %eax
  801633:	68 ac 28 80 00       	push   $0x8028ac
  801638:	e8 d0 ec ff ff       	call   80030d <cprintf>
		return -E_INVAL;
  80163d:	83 c4 10             	add    $0x10,%esp
  801640:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801645:	eb da                	jmp    801621 <write+0x55>
		return -E_NOT_SUPP;
  801647:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80164c:	eb d3                	jmp    801621 <write+0x55>

0080164e <seek>:

int
seek(int fdnum, off_t offset)
{
  80164e:	55                   	push   %ebp
  80164f:	89 e5                	mov    %esp,%ebp
  801651:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801654:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801657:	50                   	push   %eax
  801658:	ff 75 08             	pushl  0x8(%ebp)
  80165b:	e8 2d fc ff ff       	call   80128d <fd_lookup>
  801660:	83 c4 08             	add    $0x8,%esp
  801663:	85 c0                	test   %eax,%eax
  801665:	78 0e                	js     801675 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801667:	8b 55 0c             	mov    0xc(%ebp),%edx
  80166a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80166d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801670:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801675:	c9                   	leave  
  801676:	c3                   	ret    

00801677 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801677:	55                   	push   %ebp
  801678:	89 e5                	mov    %esp,%ebp
  80167a:	53                   	push   %ebx
  80167b:	83 ec 14             	sub    $0x14,%esp
  80167e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801681:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801684:	50                   	push   %eax
  801685:	53                   	push   %ebx
  801686:	e8 02 fc ff ff       	call   80128d <fd_lookup>
  80168b:	83 c4 08             	add    $0x8,%esp
  80168e:	85 c0                	test   %eax,%eax
  801690:	78 37                	js     8016c9 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801692:	83 ec 08             	sub    $0x8,%esp
  801695:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801698:	50                   	push   %eax
  801699:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80169c:	ff 30                	pushl  (%eax)
  80169e:	e8 40 fc ff ff       	call   8012e3 <dev_lookup>
  8016a3:	83 c4 10             	add    $0x10,%esp
  8016a6:	85 c0                	test   %eax,%eax
  8016a8:	78 1f                	js     8016c9 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ad:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016b1:	74 1b                	je     8016ce <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8016b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016b6:	8b 52 18             	mov    0x18(%edx),%edx
  8016b9:	85 d2                	test   %edx,%edx
  8016bb:	74 32                	je     8016ef <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016bd:	83 ec 08             	sub    $0x8,%esp
  8016c0:	ff 75 0c             	pushl  0xc(%ebp)
  8016c3:	50                   	push   %eax
  8016c4:	ff d2                	call   *%edx
  8016c6:	83 c4 10             	add    $0x10,%esp
}
  8016c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016cc:	c9                   	leave  
  8016cd:	c3                   	ret    
			thisenv->env_id, fdnum);
  8016ce:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016d3:	8b 40 48             	mov    0x48(%eax),%eax
  8016d6:	83 ec 04             	sub    $0x4,%esp
  8016d9:	53                   	push   %ebx
  8016da:	50                   	push   %eax
  8016db:	68 6c 28 80 00       	push   $0x80286c
  8016e0:	e8 28 ec ff ff       	call   80030d <cprintf>
		return -E_INVAL;
  8016e5:	83 c4 10             	add    $0x10,%esp
  8016e8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016ed:	eb da                	jmp    8016c9 <ftruncate+0x52>
		return -E_NOT_SUPP;
  8016ef:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016f4:	eb d3                	jmp    8016c9 <ftruncate+0x52>

008016f6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016f6:	55                   	push   %ebp
  8016f7:	89 e5                	mov    %esp,%ebp
  8016f9:	53                   	push   %ebx
  8016fa:	83 ec 14             	sub    $0x14,%esp
  8016fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801700:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801703:	50                   	push   %eax
  801704:	ff 75 08             	pushl  0x8(%ebp)
  801707:	e8 81 fb ff ff       	call   80128d <fd_lookup>
  80170c:	83 c4 08             	add    $0x8,%esp
  80170f:	85 c0                	test   %eax,%eax
  801711:	78 4b                	js     80175e <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801713:	83 ec 08             	sub    $0x8,%esp
  801716:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801719:	50                   	push   %eax
  80171a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80171d:	ff 30                	pushl  (%eax)
  80171f:	e8 bf fb ff ff       	call   8012e3 <dev_lookup>
  801724:	83 c4 10             	add    $0x10,%esp
  801727:	85 c0                	test   %eax,%eax
  801729:	78 33                	js     80175e <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  80172b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80172e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801732:	74 2f                	je     801763 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801734:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801737:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80173e:	00 00 00 
	stat->st_isdir = 0;
  801741:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801748:	00 00 00 
	stat->st_dev = dev;
  80174b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801751:	83 ec 08             	sub    $0x8,%esp
  801754:	53                   	push   %ebx
  801755:	ff 75 f0             	pushl  -0x10(%ebp)
  801758:	ff 50 14             	call   *0x14(%eax)
  80175b:	83 c4 10             	add    $0x10,%esp
}
  80175e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801761:	c9                   	leave  
  801762:	c3                   	ret    
		return -E_NOT_SUPP;
  801763:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801768:	eb f4                	jmp    80175e <fstat+0x68>

0080176a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80176a:	55                   	push   %ebp
  80176b:	89 e5                	mov    %esp,%ebp
  80176d:	56                   	push   %esi
  80176e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80176f:	83 ec 08             	sub    $0x8,%esp
  801772:	6a 00                	push   $0x0
  801774:	ff 75 08             	pushl  0x8(%ebp)
  801777:	e8 e7 01 00 00       	call   801963 <open>
  80177c:	89 c3                	mov    %eax,%ebx
  80177e:	83 c4 10             	add    $0x10,%esp
  801781:	85 c0                	test   %eax,%eax
  801783:	78 1b                	js     8017a0 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801785:	83 ec 08             	sub    $0x8,%esp
  801788:	ff 75 0c             	pushl  0xc(%ebp)
  80178b:	50                   	push   %eax
  80178c:	e8 65 ff ff ff       	call   8016f6 <fstat>
  801791:	89 c6                	mov    %eax,%esi
	close(fd);
  801793:	89 1c 24             	mov    %ebx,(%esp)
  801796:	e8 27 fc ff ff       	call   8013c2 <close>
	return r;
  80179b:	83 c4 10             	add    $0x10,%esp
  80179e:	89 f3                	mov    %esi,%ebx
}
  8017a0:	89 d8                	mov    %ebx,%eax
  8017a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017a5:	5b                   	pop    %ebx
  8017a6:	5e                   	pop    %esi
  8017a7:	5d                   	pop    %ebp
  8017a8:	c3                   	ret    

008017a9 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017a9:	55                   	push   %ebp
  8017aa:	89 e5                	mov    %esp,%ebp
  8017ac:	56                   	push   %esi
  8017ad:	53                   	push   %ebx
  8017ae:	89 c6                	mov    %eax,%esi
  8017b0:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017b2:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017b9:	74 27                	je     8017e2 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017bb:	6a 07                	push   $0x7
  8017bd:	68 00 50 80 00       	push   $0x805000
  8017c2:	56                   	push   %esi
  8017c3:	ff 35 00 40 80 00    	pushl  0x804000
  8017c9:	e8 05 08 00 00       	call   801fd3 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017ce:	83 c4 0c             	add    $0xc,%esp
  8017d1:	6a 00                	push   $0x0
  8017d3:	53                   	push   %ebx
  8017d4:	6a 00                	push   $0x0
  8017d6:	e8 83 07 00 00       	call   801f5e <ipc_recv>
}
  8017db:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017de:	5b                   	pop    %ebx
  8017df:	5e                   	pop    %esi
  8017e0:	5d                   	pop    %ebp
  8017e1:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017e2:	83 ec 0c             	sub    $0xc,%esp
  8017e5:	6a 01                	push   $0x1
  8017e7:	e8 3d 08 00 00       	call   802029 <ipc_find_env>
  8017ec:	a3 00 40 80 00       	mov    %eax,0x804000
  8017f1:	83 c4 10             	add    $0x10,%esp
  8017f4:	eb c5                	jmp    8017bb <fsipc+0x12>

008017f6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017f6:	55                   	push   %ebp
  8017f7:	89 e5                	mov    %esp,%ebp
  8017f9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ff:	8b 40 0c             	mov    0xc(%eax),%eax
  801802:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801807:	8b 45 0c             	mov    0xc(%ebp),%eax
  80180a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80180f:	ba 00 00 00 00       	mov    $0x0,%edx
  801814:	b8 02 00 00 00       	mov    $0x2,%eax
  801819:	e8 8b ff ff ff       	call   8017a9 <fsipc>
}
  80181e:	c9                   	leave  
  80181f:	c3                   	ret    

00801820 <devfile_flush>:
{
  801820:	55                   	push   %ebp
  801821:	89 e5                	mov    %esp,%ebp
  801823:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801826:	8b 45 08             	mov    0x8(%ebp),%eax
  801829:	8b 40 0c             	mov    0xc(%eax),%eax
  80182c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801831:	ba 00 00 00 00       	mov    $0x0,%edx
  801836:	b8 06 00 00 00       	mov    $0x6,%eax
  80183b:	e8 69 ff ff ff       	call   8017a9 <fsipc>
}
  801840:	c9                   	leave  
  801841:	c3                   	ret    

00801842 <devfile_stat>:
{
  801842:	55                   	push   %ebp
  801843:	89 e5                	mov    %esp,%ebp
  801845:	53                   	push   %ebx
  801846:	83 ec 04             	sub    $0x4,%esp
  801849:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80184c:	8b 45 08             	mov    0x8(%ebp),%eax
  80184f:	8b 40 0c             	mov    0xc(%eax),%eax
  801852:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801857:	ba 00 00 00 00       	mov    $0x0,%edx
  80185c:	b8 05 00 00 00       	mov    $0x5,%eax
  801861:	e8 43 ff ff ff       	call   8017a9 <fsipc>
  801866:	85 c0                	test   %eax,%eax
  801868:	78 2c                	js     801896 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80186a:	83 ec 08             	sub    $0x8,%esp
  80186d:	68 00 50 80 00       	push   $0x805000
  801872:	53                   	push   %ebx
  801873:	e8 b4 f0 ff ff       	call   80092c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801878:	a1 80 50 80 00       	mov    0x805080,%eax
  80187d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801883:	a1 84 50 80 00       	mov    0x805084,%eax
  801888:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80188e:	83 c4 10             	add    $0x10,%esp
  801891:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801896:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801899:	c9                   	leave  
  80189a:	c3                   	ret    

0080189b <devfile_write>:
{
  80189b:	55                   	push   %ebp
  80189c:	89 e5                	mov    %esp,%ebp
  80189e:	83 ec 0c             	sub    $0xc,%esp
  8018a1:	8b 45 10             	mov    0x10(%ebp),%eax
  8018a4:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8018a9:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8018ae:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8018b4:	8b 52 0c             	mov    0xc(%edx),%edx
  8018b7:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8018bd:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf,buf,n);
  8018c2:	50                   	push   %eax
  8018c3:	ff 75 0c             	pushl  0xc(%ebp)
  8018c6:	68 08 50 80 00       	push   $0x805008
  8018cb:	e8 ea f1 ff ff       	call   800aba <memmove>
	if((r = fsipc(FSREQ_WRITE,NULL))<0)
  8018d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d5:	b8 04 00 00 00       	mov    $0x4,%eax
  8018da:	e8 ca fe ff ff       	call   8017a9 <fsipc>
}
  8018df:	c9                   	leave  
  8018e0:	c3                   	ret    

008018e1 <devfile_read>:
{
  8018e1:	55                   	push   %ebp
  8018e2:	89 e5                	mov    %esp,%ebp
  8018e4:	56                   	push   %esi
  8018e5:	53                   	push   %ebx
  8018e6:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ec:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ef:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018f4:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ff:	b8 03 00 00 00       	mov    $0x3,%eax
  801904:	e8 a0 fe ff ff       	call   8017a9 <fsipc>
  801909:	89 c3                	mov    %eax,%ebx
  80190b:	85 c0                	test   %eax,%eax
  80190d:	78 1f                	js     80192e <devfile_read+0x4d>
	assert(r <= n);
  80190f:	39 f0                	cmp    %esi,%eax
  801911:	77 24                	ja     801937 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801913:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801918:	7f 33                	jg     80194d <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80191a:	83 ec 04             	sub    $0x4,%esp
  80191d:	50                   	push   %eax
  80191e:	68 00 50 80 00       	push   $0x805000
  801923:	ff 75 0c             	pushl  0xc(%ebp)
  801926:	e8 8f f1 ff ff       	call   800aba <memmove>
	return r;
  80192b:	83 c4 10             	add    $0x10,%esp
}
  80192e:	89 d8                	mov    %ebx,%eax
  801930:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801933:	5b                   	pop    %ebx
  801934:	5e                   	pop    %esi
  801935:	5d                   	pop    %ebp
  801936:	c3                   	ret    
	assert(r <= n);
  801937:	68 dc 28 80 00       	push   $0x8028dc
  80193c:	68 e3 28 80 00       	push   $0x8028e3
  801941:	6a 7c                	push   $0x7c
  801943:	68 f8 28 80 00       	push   $0x8028f8
  801948:	e8 e5 e8 ff ff       	call   800232 <_panic>
	assert(r <= PGSIZE);
  80194d:	68 03 29 80 00       	push   $0x802903
  801952:	68 e3 28 80 00       	push   $0x8028e3
  801957:	6a 7d                	push   $0x7d
  801959:	68 f8 28 80 00       	push   $0x8028f8
  80195e:	e8 cf e8 ff ff       	call   800232 <_panic>

00801963 <open>:
{
  801963:	55                   	push   %ebp
  801964:	89 e5                	mov    %esp,%ebp
  801966:	56                   	push   %esi
  801967:	53                   	push   %ebx
  801968:	83 ec 1c             	sub    $0x1c,%esp
  80196b:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80196e:	56                   	push   %esi
  80196f:	e8 81 ef ff ff       	call   8008f5 <strlen>
  801974:	83 c4 10             	add    $0x10,%esp
  801977:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80197c:	7f 6c                	jg     8019ea <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  80197e:	83 ec 0c             	sub    $0xc,%esp
  801981:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801984:	50                   	push   %eax
  801985:	e8 b4 f8 ff ff       	call   80123e <fd_alloc>
  80198a:	89 c3                	mov    %eax,%ebx
  80198c:	83 c4 10             	add    $0x10,%esp
  80198f:	85 c0                	test   %eax,%eax
  801991:	78 3c                	js     8019cf <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801993:	83 ec 08             	sub    $0x8,%esp
  801996:	56                   	push   %esi
  801997:	68 00 50 80 00       	push   $0x805000
  80199c:	e8 8b ef ff ff       	call   80092c <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019a4:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019ac:	b8 01 00 00 00       	mov    $0x1,%eax
  8019b1:	e8 f3 fd ff ff       	call   8017a9 <fsipc>
  8019b6:	89 c3                	mov    %eax,%ebx
  8019b8:	83 c4 10             	add    $0x10,%esp
  8019bb:	85 c0                	test   %eax,%eax
  8019bd:	78 19                	js     8019d8 <open+0x75>
	return fd2num(fd);
  8019bf:	83 ec 0c             	sub    $0xc,%esp
  8019c2:	ff 75 f4             	pushl  -0xc(%ebp)
  8019c5:	e8 4d f8 ff ff       	call   801217 <fd2num>
  8019ca:	89 c3                	mov    %eax,%ebx
  8019cc:	83 c4 10             	add    $0x10,%esp
}
  8019cf:	89 d8                	mov    %ebx,%eax
  8019d1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019d4:	5b                   	pop    %ebx
  8019d5:	5e                   	pop    %esi
  8019d6:	5d                   	pop    %ebp
  8019d7:	c3                   	ret    
		fd_close(fd, 0);
  8019d8:	83 ec 08             	sub    $0x8,%esp
  8019db:	6a 00                	push   $0x0
  8019dd:	ff 75 f4             	pushl  -0xc(%ebp)
  8019e0:	e8 54 f9 ff ff       	call   801339 <fd_close>
		return r;
  8019e5:	83 c4 10             	add    $0x10,%esp
  8019e8:	eb e5                	jmp    8019cf <open+0x6c>
		return -E_BAD_PATH;
  8019ea:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8019ef:	eb de                	jmp    8019cf <open+0x6c>

008019f1 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019f1:	55                   	push   %ebp
  8019f2:	89 e5                	mov    %esp,%ebp
  8019f4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8019fc:	b8 08 00 00 00       	mov    $0x8,%eax
  801a01:	e8 a3 fd ff ff       	call   8017a9 <fsipc>
}
  801a06:	c9                   	leave  
  801a07:	c3                   	ret    

00801a08 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a08:	55                   	push   %ebp
  801a09:	89 e5                	mov    %esp,%ebp
  801a0b:	56                   	push   %esi
  801a0c:	53                   	push   %ebx
  801a0d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a10:	83 ec 0c             	sub    $0xc,%esp
  801a13:	ff 75 08             	pushl  0x8(%ebp)
  801a16:	e8 0c f8 ff ff       	call   801227 <fd2data>
  801a1b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a1d:	83 c4 08             	add    $0x8,%esp
  801a20:	68 0f 29 80 00       	push   $0x80290f
  801a25:	53                   	push   %ebx
  801a26:	e8 01 ef ff ff       	call   80092c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a2b:	8b 46 04             	mov    0x4(%esi),%eax
  801a2e:	2b 06                	sub    (%esi),%eax
  801a30:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a36:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a3d:	00 00 00 
	stat->st_dev = &devpipe;
  801a40:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a47:	30 80 00 
	return 0;
}
  801a4a:	b8 00 00 00 00       	mov    $0x0,%eax
  801a4f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a52:	5b                   	pop    %ebx
  801a53:	5e                   	pop    %esi
  801a54:	5d                   	pop    %ebp
  801a55:	c3                   	ret    

00801a56 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a56:	55                   	push   %ebp
  801a57:	89 e5                	mov    %esp,%ebp
  801a59:	53                   	push   %ebx
  801a5a:	83 ec 0c             	sub    $0xc,%esp
  801a5d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a60:	53                   	push   %ebx
  801a61:	6a 00                	push   $0x0
  801a63:	e8 42 f3 ff ff       	call   800daa <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a68:	89 1c 24             	mov    %ebx,(%esp)
  801a6b:	e8 b7 f7 ff ff       	call   801227 <fd2data>
  801a70:	83 c4 08             	add    $0x8,%esp
  801a73:	50                   	push   %eax
  801a74:	6a 00                	push   $0x0
  801a76:	e8 2f f3 ff ff       	call   800daa <sys_page_unmap>
}
  801a7b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a7e:	c9                   	leave  
  801a7f:	c3                   	ret    

00801a80 <_pipeisclosed>:
{
  801a80:	55                   	push   %ebp
  801a81:	89 e5                	mov    %esp,%ebp
  801a83:	57                   	push   %edi
  801a84:	56                   	push   %esi
  801a85:	53                   	push   %ebx
  801a86:	83 ec 1c             	sub    $0x1c,%esp
  801a89:	89 c7                	mov    %eax,%edi
  801a8b:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801a8d:	a1 04 40 80 00       	mov    0x804004,%eax
  801a92:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a95:	83 ec 0c             	sub    $0xc,%esp
  801a98:	57                   	push   %edi
  801a99:	e8 c4 05 00 00       	call   802062 <pageref>
  801a9e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801aa1:	89 34 24             	mov    %esi,(%esp)
  801aa4:	e8 b9 05 00 00       	call   802062 <pageref>
		nn = thisenv->env_runs;
  801aa9:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801aaf:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ab2:	83 c4 10             	add    $0x10,%esp
  801ab5:	39 cb                	cmp    %ecx,%ebx
  801ab7:	74 1b                	je     801ad4 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801ab9:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801abc:	75 cf                	jne    801a8d <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801abe:	8b 42 58             	mov    0x58(%edx),%eax
  801ac1:	6a 01                	push   $0x1
  801ac3:	50                   	push   %eax
  801ac4:	53                   	push   %ebx
  801ac5:	68 16 29 80 00       	push   $0x802916
  801aca:	e8 3e e8 ff ff       	call   80030d <cprintf>
  801acf:	83 c4 10             	add    $0x10,%esp
  801ad2:	eb b9                	jmp    801a8d <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801ad4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801ad7:	0f 94 c0             	sete   %al
  801ada:	0f b6 c0             	movzbl %al,%eax
}
  801add:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae0:	5b                   	pop    %ebx
  801ae1:	5e                   	pop    %esi
  801ae2:	5f                   	pop    %edi
  801ae3:	5d                   	pop    %ebp
  801ae4:	c3                   	ret    

00801ae5 <devpipe_write>:
{
  801ae5:	55                   	push   %ebp
  801ae6:	89 e5                	mov    %esp,%ebp
  801ae8:	57                   	push   %edi
  801ae9:	56                   	push   %esi
  801aea:	53                   	push   %ebx
  801aeb:	83 ec 28             	sub    $0x28,%esp
  801aee:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801af1:	56                   	push   %esi
  801af2:	e8 30 f7 ff ff       	call   801227 <fd2data>
  801af7:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801af9:	83 c4 10             	add    $0x10,%esp
  801afc:	bf 00 00 00 00       	mov    $0x0,%edi
  801b01:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b04:	74 4f                	je     801b55 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b06:	8b 43 04             	mov    0x4(%ebx),%eax
  801b09:	8b 0b                	mov    (%ebx),%ecx
  801b0b:	8d 51 20             	lea    0x20(%ecx),%edx
  801b0e:	39 d0                	cmp    %edx,%eax
  801b10:	72 14                	jb     801b26 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801b12:	89 da                	mov    %ebx,%edx
  801b14:	89 f0                	mov    %esi,%eax
  801b16:	e8 65 ff ff ff       	call   801a80 <_pipeisclosed>
  801b1b:	85 c0                	test   %eax,%eax
  801b1d:	75 3a                	jne    801b59 <devpipe_write+0x74>
			sys_yield();
  801b1f:	e8 e2 f1 ff ff       	call   800d06 <sys_yield>
  801b24:	eb e0                	jmp    801b06 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b29:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b2d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b30:	89 c2                	mov    %eax,%edx
  801b32:	c1 fa 1f             	sar    $0x1f,%edx
  801b35:	89 d1                	mov    %edx,%ecx
  801b37:	c1 e9 1b             	shr    $0x1b,%ecx
  801b3a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b3d:	83 e2 1f             	and    $0x1f,%edx
  801b40:	29 ca                	sub    %ecx,%edx
  801b42:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b46:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b4a:	83 c0 01             	add    $0x1,%eax
  801b4d:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801b50:	83 c7 01             	add    $0x1,%edi
  801b53:	eb ac                	jmp    801b01 <devpipe_write+0x1c>
	return i;
  801b55:	89 f8                	mov    %edi,%eax
  801b57:	eb 05                	jmp    801b5e <devpipe_write+0x79>
				return 0;
  801b59:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b61:	5b                   	pop    %ebx
  801b62:	5e                   	pop    %esi
  801b63:	5f                   	pop    %edi
  801b64:	5d                   	pop    %ebp
  801b65:	c3                   	ret    

00801b66 <devpipe_read>:
{
  801b66:	55                   	push   %ebp
  801b67:	89 e5                	mov    %esp,%ebp
  801b69:	57                   	push   %edi
  801b6a:	56                   	push   %esi
  801b6b:	53                   	push   %ebx
  801b6c:	83 ec 18             	sub    $0x18,%esp
  801b6f:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801b72:	57                   	push   %edi
  801b73:	e8 af f6 ff ff       	call   801227 <fd2data>
  801b78:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b7a:	83 c4 10             	add    $0x10,%esp
  801b7d:	be 00 00 00 00       	mov    $0x0,%esi
  801b82:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b85:	74 47                	je     801bce <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  801b87:	8b 03                	mov    (%ebx),%eax
  801b89:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b8c:	75 22                	jne    801bb0 <devpipe_read+0x4a>
			if (i > 0)
  801b8e:	85 f6                	test   %esi,%esi
  801b90:	75 14                	jne    801ba6 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801b92:	89 da                	mov    %ebx,%edx
  801b94:	89 f8                	mov    %edi,%eax
  801b96:	e8 e5 fe ff ff       	call   801a80 <_pipeisclosed>
  801b9b:	85 c0                	test   %eax,%eax
  801b9d:	75 33                	jne    801bd2 <devpipe_read+0x6c>
			sys_yield();
  801b9f:	e8 62 f1 ff ff       	call   800d06 <sys_yield>
  801ba4:	eb e1                	jmp    801b87 <devpipe_read+0x21>
				return i;
  801ba6:	89 f0                	mov    %esi,%eax
}
  801ba8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bab:	5b                   	pop    %ebx
  801bac:	5e                   	pop    %esi
  801bad:	5f                   	pop    %edi
  801bae:	5d                   	pop    %ebp
  801baf:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bb0:	99                   	cltd   
  801bb1:	c1 ea 1b             	shr    $0x1b,%edx
  801bb4:	01 d0                	add    %edx,%eax
  801bb6:	83 e0 1f             	and    $0x1f,%eax
  801bb9:	29 d0                	sub    %edx,%eax
  801bbb:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801bc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bc3:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801bc6:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801bc9:	83 c6 01             	add    $0x1,%esi
  801bcc:	eb b4                	jmp    801b82 <devpipe_read+0x1c>
	return i;
  801bce:	89 f0                	mov    %esi,%eax
  801bd0:	eb d6                	jmp    801ba8 <devpipe_read+0x42>
				return 0;
  801bd2:	b8 00 00 00 00       	mov    $0x0,%eax
  801bd7:	eb cf                	jmp    801ba8 <devpipe_read+0x42>

00801bd9 <pipe>:
{
  801bd9:	55                   	push   %ebp
  801bda:	89 e5                	mov    %esp,%ebp
  801bdc:	56                   	push   %esi
  801bdd:	53                   	push   %ebx
  801bde:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801be1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801be4:	50                   	push   %eax
  801be5:	e8 54 f6 ff ff       	call   80123e <fd_alloc>
  801bea:	89 c3                	mov    %eax,%ebx
  801bec:	83 c4 10             	add    $0x10,%esp
  801bef:	85 c0                	test   %eax,%eax
  801bf1:	78 5b                	js     801c4e <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bf3:	83 ec 04             	sub    $0x4,%esp
  801bf6:	68 07 04 00 00       	push   $0x407
  801bfb:	ff 75 f4             	pushl  -0xc(%ebp)
  801bfe:	6a 00                	push   $0x0
  801c00:	e8 20 f1 ff ff       	call   800d25 <sys_page_alloc>
  801c05:	89 c3                	mov    %eax,%ebx
  801c07:	83 c4 10             	add    $0x10,%esp
  801c0a:	85 c0                	test   %eax,%eax
  801c0c:	78 40                	js     801c4e <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  801c0e:	83 ec 0c             	sub    $0xc,%esp
  801c11:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c14:	50                   	push   %eax
  801c15:	e8 24 f6 ff ff       	call   80123e <fd_alloc>
  801c1a:	89 c3                	mov    %eax,%ebx
  801c1c:	83 c4 10             	add    $0x10,%esp
  801c1f:	85 c0                	test   %eax,%eax
  801c21:	78 1b                	js     801c3e <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c23:	83 ec 04             	sub    $0x4,%esp
  801c26:	68 07 04 00 00       	push   $0x407
  801c2b:	ff 75 f0             	pushl  -0x10(%ebp)
  801c2e:	6a 00                	push   $0x0
  801c30:	e8 f0 f0 ff ff       	call   800d25 <sys_page_alloc>
  801c35:	89 c3                	mov    %eax,%ebx
  801c37:	83 c4 10             	add    $0x10,%esp
  801c3a:	85 c0                	test   %eax,%eax
  801c3c:	79 19                	jns    801c57 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  801c3e:	83 ec 08             	sub    $0x8,%esp
  801c41:	ff 75 f4             	pushl  -0xc(%ebp)
  801c44:	6a 00                	push   $0x0
  801c46:	e8 5f f1 ff ff       	call   800daa <sys_page_unmap>
  801c4b:	83 c4 10             	add    $0x10,%esp
}
  801c4e:	89 d8                	mov    %ebx,%eax
  801c50:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c53:	5b                   	pop    %ebx
  801c54:	5e                   	pop    %esi
  801c55:	5d                   	pop    %ebp
  801c56:	c3                   	ret    
	va = fd2data(fd0);
  801c57:	83 ec 0c             	sub    $0xc,%esp
  801c5a:	ff 75 f4             	pushl  -0xc(%ebp)
  801c5d:	e8 c5 f5 ff ff       	call   801227 <fd2data>
  801c62:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c64:	83 c4 0c             	add    $0xc,%esp
  801c67:	68 07 04 00 00       	push   $0x407
  801c6c:	50                   	push   %eax
  801c6d:	6a 00                	push   $0x0
  801c6f:	e8 b1 f0 ff ff       	call   800d25 <sys_page_alloc>
  801c74:	89 c3                	mov    %eax,%ebx
  801c76:	83 c4 10             	add    $0x10,%esp
  801c79:	85 c0                	test   %eax,%eax
  801c7b:	0f 88 8c 00 00 00    	js     801d0d <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c81:	83 ec 0c             	sub    $0xc,%esp
  801c84:	ff 75 f0             	pushl  -0x10(%ebp)
  801c87:	e8 9b f5 ff ff       	call   801227 <fd2data>
  801c8c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c93:	50                   	push   %eax
  801c94:	6a 00                	push   $0x0
  801c96:	56                   	push   %esi
  801c97:	6a 00                	push   $0x0
  801c99:	e8 ca f0 ff ff       	call   800d68 <sys_page_map>
  801c9e:	89 c3                	mov    %eax,%ebx
  801ca0:	83 c4 20             	add    $0x20,%esp
  801ca3:	85 c0                	test   %eax,%eax
  801ca5:	78 58                	js     801cff <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801ca7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801caa:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cb0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801cb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cb5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801cbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cbf:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cc5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cca:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801cd1:	83 ec 0c             	sub    $0xc,%esp
  801cd4:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd7:	e8 3b f5 ff ff       	call   801217 <fd2num>
  801cdc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cdf:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ce1:	83 c4 04             	add    $0x4,%esp
  801ce4:	ff 75 f0             	pushl  -0x10(%ebp)
  801ce7:	e8 2b f5 ff ff       	call   801217 <fd2num>
  801cec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cef:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801cf2:	83 c4 10             	add    $0x10,%esp
  801cf5:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cfa:	e9 4f ff ff ff       	jmp    801c4e <pipe+0x75>
	sys_page_unmap(0, va);
  801cff:	83 ec 08             	sub    $0x8,%esp
  801d02:	56                   	push   %esi
  801d03:	6a 00                	push   $0x0
  801d05:	e8 a0 f0 ff ff       	call   800daa <sys_page_unmap>
  801d0a:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801d0d:	83 ec 08             	sub    $0x8,%esp
  801d10:	ff 75 f0             	pushl  -0x10(%ebp)
  801d13:	6a 00                	push   $0x0
  801d15:	e8 90 f0 ff ff       	call   800daa <sys_page_unmap>
  801d1a:	83 c4 10             	add    $0x10,%esp
  801d1d:	e9 1c ff ff ff       	jmp    801c3e <pipe+0x65>

00801d22 <pipeisclosed>:
{
  801d22:	55                   	push   %ebp
  801d23:	89 e5                	mov    %esp,%ebp
  801d25:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d28:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d2b:	50                   	push   %eax
  801d2c:	ff 75 08             	pushl  0x8(%ebp)
  801d2f:	e8 59 f5 ff ff       	call   80128d <fd_lookup>
  801d34:	83 c4 10             	add    $0x10,%esp
  801d37:	85 c0                	test   %eax,%eax
  801d39:	78 18                	js     801d53 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801d3b:	83 ec 0c             	sub    $0xc,%esp
  801d3e:	ff 75 f4             	pushl  -0xc(%ebp)
  801d41:	e8 e1 f4 ff ff       	call   801227 <fd2data>
	return _pipeisclosed(fd, p);
  801d46:	89 c2                	mov    %eax,%edx
  801d48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d4b:	e8 30 fd ff ff       	call   801a80 <_pipeisclosed>
  801d50:	83 c4 10             	add    $0x10,%esp
}
  801d53:	c9                   	leave  
  801d54:	c3                   	ret    

00801d55 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d55:	55                   	push   %ebp
  801d56:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d58:	b8 00 00 00 00       	mov    $0x0,%eax
  801d5d:	5d                   	pop    %ebp
  801d5e:	c3                   	ret    

00801d5f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d5f:	55                   	push   %ebp
  801d60:	89 e5                	mov    %esp,%ebp
  801d62:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d65:	68 2e 29 80 00       	push   $0x80292e
  801d6a:	ff 75 0c             	pushl  0xc(%ebp)
  801d6d:	e8 ba eb ff ff       	call   80092c <strcpy>
	return 0;
}
  801d72:	b8 00 00 00 00       	mov    $0x0,%eax
  801d77:	c9                   	leave  
  801d78:	c3                   	ret    

00801d79 <devcons_write>:
{
  801d79:	55                   	push   %ebp
  801d7a:	89 e5                	mov    %esp,%ebp
  801d7c:	57                   	push   %edi
  801d7d:	56                   	push   %esi
  801d7e:	53                   	push   %ebx
  801d7f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801d85:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801d8a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801d90:	eb 2f                	jmp    801dc1 <devcons_write+0x48>
		m = n - tot;
  801d92:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d95:	29 f3                	sub    %esi,%ebx
  801d97:	83 fb 7f             	cmp    $0x7f,%ebx
  801d9a:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801d9f:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801da2:	83 ec 04             	sub    $0x4,%esp
  801da5:	53                   	push   %ebx
  801da6:	89 f0                	mov    %esi,%eax
  801da8:	03 45 0c             	add    0xc(%ebp),%eax
  801dab:	50                   	push   %eax
  801dac:	57                   	push   %edi
  801dad:	e8 08 ed ff ff       	call   800aba <memmove>
		sys_cputs(buf, m);
  801db2:	83 c4 08             	add    $0x8,%esp
  801db5:	53                   	push   %ebx
  801db6:	57                   	push   %edi
  801db7:	e8 ad ee ff ff       	call   800c69 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801dbc:	01 de                	add    %ebx,%esi
  801dbe:	83 c4 10             	add    $0x10,%esp
  801dc1:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dc4:	72 cc                	jb     801d92 <devcons_write+0x19>
}
  801dc6:	89 f0                	mov    %esi,%eax
  801dc8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dcb:	5b                   	pop    %ebx
  801dcc:	5e                   	pop    %esi
  801dcd:	5f                   	pop    %edi
  801dce:	5d                   	pop    %ebp
  801dcf:	c3                   	ret    

00801dd0 <devcons_read>:
{
  801dd0:	55                   	push   %ebp
  801dd1:	89 e5                	mov    %esp,%ebp
  801dd3:	83 ec 08             	sub    $0x8,%esp
  801dd6:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801ddb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ddf:	75 07                	jne    801de8 <devcons_read+0x18>
}
  801de1:	c9                   	leave  
  801de2:	c3                   	ret    
		sys_yield();
  801de3:	e8 1e ef ff ff       	call   800d06 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801de8:	e8 9a ee ff ff       	call   800c87 <sys_cgetc>
  801ded:	85 c0                	test   %eax,%eax
  801def:	74 f2                	je     801de3 <devcons_read+0x13>
	if (c < 0)
  801df1:	85 c0                	test   %eax,%eax
  801df3:	78 ec                	js     801de1 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  801df5:	83 f8 04             	cmp    $0x4,%eax
  801df8:	74 0c                	je     801e06 <devcons_read+0x36>
	*(char*)vbuf = c;
  801dfa:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dfd:	88 02                	mov    %al,(%edx)
	return 1;
  801dff:	b8 01 00 00 00       	mov    $0x1,%eax
  801e04:	eb db                	jmp    801de1 <devcons_read+0x11>
		return 0;
  801e06:	b8 00 00 00 00       	mov    $0x0,%eax
  801e0b:	eb d4                	jmp    801de1 <devcons_read+0x11>

00801e0d <cputchar>:
{
  801e0d:	55                   	push   %ebp
  801e0e:	89 e5                	mov    %esp,%ebp
  801e10:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e13:	8b 45 08             	mov    0x8(%ebp),%eax
  801e16:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801e19:	6a 01                	push   $0x1
  801e1b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e1e:	50                   	push   %eax
  801e1f:	e8 45 ee ff ff       	call   800c69 <sys_cputs>
}
  801e24:	83 c4 10             	add    $0x10,%esp
  801e27:	c9                   	leave  
  801e28:	c3                   	ret    

00801e29 <getchar>:
{
  801e29:	55                   	push   %ebp
  801e2a:	89 e5                	mov    %esp,%ebp
  801e2c:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801e2f:	6a 01                	push   $0x1
  801e31:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e34:	50                   	push   %eax
  801e35:	6a 00                	push   $0x0
  801e37:	e8 c2 f6 ff ff       	call   8014fe <read>
	if (r < 0)
  801e3c:	83 c4 10             	add    $0x10,%esp
  801e3f:	85 c0                	test   %eax,%eax
  801e41:	78 08                	js     801e4b <getchar+0x22>
	if (r < 1)
  801e43:	85 c0                	test   %eax,%eax
  801e45:	7e 06                	jle    801e4d <getchar+0x24>
	return c;
  801e47:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801e4b:	c9                   	leave  
  801e4c:	c3                   	ret    
		return -E_EOF;
  801e4d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801e52:	eb f7                	jmp    801e4b <getchar+0x22>

00801e54 <iscons>:
{
  801e54:	55                   	push   %ebp
  801e55:	89 e5                	mov    %esp,%ebp
  801e57:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e5a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e5d:	50                   	push   %eax
  801e5e:	ff 75 08             	pushl  0x8(%ebp)
  801e61:	e8 27 f4 ff ff       	call   80128d <fd_lookup>
  801e66:	83 c4 10             	add    $0x10,%esp
  801e69:	85 c0                	test   %eax,%eax
  801e6b:	78 11                	js     801e7e <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801e6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e70:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e76:	39 10                	cmp    %edx,(%eax)
  801e78:	0f 94 c0             	sete   %al
  801e7b:	0f b6 c0             	movzbl %al,%eax
}
  801e7e:	c9                   	leave  
  801e7f:	c3                   	ret    

00801e80 <opencons>:
{
  801e80:	55                   	push   %ebp
  801e81:	89 e5                	mov    %esp,%ebp
  801e83:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801e86:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e89:	50                   	push   %eax
  801e8a:	e8 af f3 ff ff       	call   80123e <fd_alloc>
  801e8f:	83 c4 10             	add    $0x10,%esp
  801e92:	85 c0                	test   %eax,%eax
  801e94:	78 3a                	js     801ed0 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e96:	83 ec 04             	sub    $0x4,%esp
  801e99:	68 07 04 00 00       	push   $0x407
  801e9e:	ff 75 f4             	pushl  -0xc(%ebp)
  801ea1:	6a 00                	push   $0x0
  801ea3:	e8 7d ee ff ff       	call   800d25 <sys_page_alloc>
  801ea8:	83 c4 10             	add    $0x10,%esp
  801eab:	85 c0                	test   %eax,%eax
  801ead:	78 21                	js     801ed0 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801eaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801eb8:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801eba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ebd:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ec4:	83 ec 0c             	sub    $0xc,%esp
  801ec7:	50                   	push   %eax
  801ec8:	e8 4a f3 ff ff       	call   801217 <fd2num>
  801ecd:	83 c4 10             	add    $0x10,%esp
}
  801ed0:	c9                   	leave  
  801ed1:	c3                   	ret    

00801ed2 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ed2:	55                   	push   %ebp
  801ed3:	89 e5                	mov    %esp,%ebp
  801ed5:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801ed8:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801edf:	74 0a                	je     801eeb <set_pgfault_handler+0x19>
			panic("set_pgfault_handler %e",r);
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
	}
       
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801ee1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee4:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801ee9:	c9                   	leave  
  801eea:	c3                   	ret    
		if((r=sys_page_alloc(thisenv->env_id,(void *)UXSTACKTOP-PGSIZE,PTE_P|PTE_W|PTE_U))<0)
  801eeb:	a1 04 40 80 00       	mov    0x804004,%eax
  801ef0:	8b 40 48             	mov    0x48(%eax),%eax
  801ef3:	83 ec 04             	sub    $0x4,%esp
  801ef6:	6a 07                	push   $0x7
  801ef8:	68 00 f0 bf ee       	push   $0xeebff000
  801efd:	50                   	push   %eax
  801efe:	e8 22 ee ff ff       	call   800d25 <sys_page_alloc>
  801f03:	83 c4 10             	add    $0x10,%esp
  801f06:	85 c0                	test   %eax,%eax
  801f08:	78 1b                	js     801f25 <set_pgfault_handler+0x53>
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
  801f0a:	a1 04 40 80 00       	mov    0x804004,%eax
  801f0f:	8b 40 48             	mov    0x48(%eax),%eax
  801f12:	83 ec 08             	sub    $0x8,%esp
  801f15:	68 37 1f 80 00       	push   $0x801f37
  801f1a:	50                   	push   %eax
  801f1b:	e8 50 ef ff ff       	call   800e70 <sys_env_set_pgfault_upcall>
  801f20:	83 c4 10             	add    $0x10,%esp
  801f23:	eb bc                	jmp    801ee1 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler %e",r);
  801f25:	50                   	push   %eax
  801f26:	68 3a 29 80 00       	push   $0x80293a
  801f2b:	6a 22                	push   $0x22
  801f2d:	68 51 29 80 00       	push   $0x802951
  801f32:	e8 fb e2 ff ff       	call   800232 <_panic>

00801f37 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f37:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f38:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f3d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f3f:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 48(%esp), %ebp
  801f42:	8b 6c 24 30          	mov    0x30(%esp),%ebp
        subl $4, %ebp
  801f46:	83 ed 04             	sub    $0x4,%ebp
        movl %ebp, 48(%esp)
  801f49:	89 6c 24 30          	mov    %ebp,0x30(%esp)
        movl 40(%esp), %eax
  801f4d:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl %eax, (%ebp)
  801f51:	89 45 00             	mov    %eax,0x0(%ebp)
	// Restore the trap-time registers.  After you do this, you
 	// can no longer modify any general-purpose registers.
 	// LAB 4: Your code here.
        addl $8, %esp
  801f54:	83 c4 08             	add    $0x8,%esp
        popal
  801f57:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $4, %esp
  801f58:	83 c4 04             	add    $0x4,%esp
        popfl
  801f5b:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  801f5c:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  801f5d:	c3                   	ret    

00801f5e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f5e:	55                   	push   %ebp
  801f5f:	89 e5                	mov    %esp,%ebp
  801f61:	56                   	push   %esi
  801f62:	53                   	push   %ebx
  801f63:	8b 75 08             	mov    0x8(%ebp),%esi
  801f66:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f69:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        //	panic("ipc_recv not implemented");
        int r;
       	if(pg!=NULL){
  801f6c:	85 c0                	test   %eax,%eax
  801f6e:	74 3b                	je     801fab <ipc_recv+0x4d>
	  r = sys_ipc_recv(pg);
  801f70:	83 ec 0c             	sub    $0xc,%esp
  801f73:	50                   	push   %eax
  801f74:	e8 5c ef ff ff       	call   800ed5 <sys_ipc_recv>
  801f79:	83 c4 10             	add    $0x10,%esp
	}else
	  r = sys_ipc_recv((void *)UTOP);
	if(r<0){
  801f7c:	85 c0                	test   %eax,%eax
  801f7e:	78 3d                	js     801fbd <ipc_recv+0x5f>
	if(perm_store!=NULL){
		*perm_store = 0;
            }
        	return r;
           }else{
	     if(from_env_store!=NULL)
  801f80:	85 f6                	test   %esi,%esi
  801f82:	74 0a                	je     801f8e <ipc_recv+0x30>
		     *from_env_store = thisenv->env_ipc_from;
  801f84:	a1 04 40 80 00       	mov    0x804004,%eax
  801f89:	8b 40 74             	mov    0x74(%eax),%eax
  801f8c:	89 06                	mov    %eax,(%esi)
	     if(perm_store != NULL)
  801f8e:	85 db                	test   %ebx,%ebx
  801f90:	74 0a                	je     801f9c <ipc_recv+0x3e>
		     *perm_store = thisenv->env_ipc_perm;
  801f92:	a1 04 40 80 00       	mov    0x804004,%eax
  801f97:	8b 40 78             	mov    0x78(%eax),%eax
  801f9a:	89 03                	mov    %eax,(%ebx)
	     return thisenv->env_ipc_value;
  801f9c:	a1 04 40 80 00       	mov    0x804004,%eax
  801fa1:	8b 40 70             	mov    0x70(%eax),%eax
	   }

}
  801fa4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fa7:	5b                   	pop    %ebx
  801fa8:	5e                   	pop    %esi
  801fa9:	5d                   	pop    %ebp
  801faa:	c3                   	ret    
	  r = sys_ipc_recv((void *)UTOP);
  801fab:	83 ec 0c             	sub    $0xc,%esp
  801fae:	68 00 00 c0 ee       	push   $0xeec00000
  801fb3:	e8 1d ef ff ff       	call   800ed5 <sys_ipc_recv>
  801fb8:	83 c4 10             	add    $0x10,%esp
  801fbb:	eb bf                	jmp    801f7c <ipc_recv+0x1e>
	if(from_env_store!=NULL){
  801fbd:	85 f6                	test   %esi,%esi
  801fbf:	74 06                	je     801fc7 <ipc_recv+0x69>
	  *from_env_store = 0;
  801fc1:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if(perm_store!=NULL){
  801fc7:	85 db                	test   %ebx,%ebx
  801fc9:	74 d9                	je     801fa4 <ipc_recv+0x46>
		*perm_store = 0;
  801fcb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801fd1:	eb d1                	jmp    801fa4 <ipc_recv+0x46>

00801fd3 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fd3:	55                   	push   %ebp
  801fd4:	89 e5                	mov    %esp,%ebp
  801fd6:	57                   	push   %edi
  801fd7:	56                   	push   %esi
  801fd8:	53                   	push   %ebx
  801fd9:	83 ec 0c             	sub    $0xc,%esp
  801fdc:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fdf:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fe2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if(pg==NULL) pg = (void *)UTOP;
  801fe5:	85 db                	test   %ebx,%ebx
  801fe7:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801fec:	0f 44 d8             	cmove  %eax,%ebx
	while((r=sys_ipc_try_send(to_env,val,pg,perm))<0){
  801fef:	ff 75 14             	pushl  0x14(%ebp)
  801ff2:	53                   	push   %ebx
  801ff3:	56                   	push   %esi
  801ff4:	57                   	push   %edi
  801ff5:	e8 b8 ee ff ff       	call   800eb2 <sys_ipc_try_send>
  801ffa:	83 c4 10             	add    $0x10,%esp
  801ffd:	85 c0                	test   %eax,%eax
  801fff:	79 20                	jns    802021 <ipc_send+0x4e>
	    if(r!=-E_IPC_NOT_RECV){
  802001:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802004:	75 07                	jne    80200d <ipc_send+0x3a>
		    panic("ipc_send:send message failed\n");
	    }
	    sys_yield();
  802006:	e8 fb ec ff ff       	call   800d06 <sys_yield>
  80200b:	eb e2                	jmp    801fef <ipc_send+0x1c>
		    panic("ipc_send:send message failed\n");
  80200d:	83 ec 04             	sub    $0x4,%esp
  802010:	68 5f 29 80 00       	push   $0x80295f
  802015:	6a 43                	push   $0x43
  802017:	68 7d 29 80 00       	push   $0x80297d
  80201c:	e8 11 e2 ff ff       	call   800232 <_panic>
	}

}
  802021:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802024:	5b                   	pop    %ebx
  802025:	5e                   	pop    %esi
  802026:	5f                   	pop    %edi
  802027:	5d                   	pop    %ebp
  802028:	c3                   	ret    

00802029 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802029:	55                   	push   %ebp
  80202a:	89 e5                	mov    %esp,%ebp
  80202c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80202f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802034:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802037:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80203d:	8b 52 50             	mov    0x50(%edx),%edx
  802040:	39 ca                	cmp    %ecx,%edx
  802042:	74 11                	je     802055 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  802044:	83 c0 01             	add    $0x1,%eax
  802047:	3d 00 04 00 00       	cmp    $0x400,%eax
  80204c:	75 e6                	jne    802034 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  80204e:	b8 00 00 00 00       	mov    $0x0,%eax
  802053:	eb 0b                	jmp    802060 <ipc_find_env+0x37>
			return envs[i].env_id;
  802055:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802058:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80205d:	8b 40 48             	mov    0x48(%eax),%eax
}
  802060:	5d                   	pop    %ebp
  802061:	c3                   	ret    

00802062 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802062:	55                   	push   %ebp
  802063:	89 e5                	mov    %esp,%ebp
  802065:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802068:	89 d0                	mov    %edx,%eax
  80206a:	c1 e8 16             	shr    $0x16,%eax
  80206d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802074:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  802079:	f6 c1 01             	test   $0x1,%cl
  80207c:	74 1d                	je     80209b <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  80207e:	c1 ea 0c             	shr    $0xc,%edx
  802081:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802088:	f6 c2 01             	test   $0x1,%dl
  80208b:	74 0e                	je     80209b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80208d:	c1 ea 0c             	shr    $0xc,%edx
  802090:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802097:	ef 
  802098:	0f b7 c0             	movzwl %ax,%eax
}
  80209b:	5d                   	pop    %ebp
  80209c:	c3                   	ret    
  80209d:	66 90                	xchg   %ax,%ax
  80209f:	90                   	nop

008020a0 <__udivdi3>:
  8020a0:	55                   	push   %ebp
  8020a1:	57                   	push   %edi
  8020a2:	56                   	push   %esi
  8020a3:	53                   	push   %ebx
  8020a4:	83 ec 1c             	sub    $0x1c,%esp
  8020a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020ab:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8020af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020b3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8020b7:	85 d2                	test   %edx,%edx
  8020b9:	75 35                	jne    8020f0 <__udivdi3+0x50>
  8020bb:	39 f3                	cmp    %esi,%ebx
  8020bd:	0f 87 bd 00 00 00    	ja     802180 <__udivdi3+0xe0>
  8020c3:	85 db                	test   %ebx,%ebx
  8020c5:	89 d9                	mov    %ebx,%ecx
  8020c7:	75 0b                	jne    8020d4 <__udivdi3+0x34>
  8020c9:	b8 01 00 00 00       	mov    $0x1,%eax
  8020ce:	31 d2                	xor    %edx,%edx
  8020d0:	f7 f3                	div    %ebx
  8020d2:	89 c1                	mov    %eax,%ecx
  8020d4:	31 d2                	xor    %edx,%edx
  8020d6:	89 f0                	mov    %esi,%eax
  8020d8:	f7 f1                	div    %ecx
  8020da:	89 c6                	mov    %eax,%esi
  8020dc:	89 e8                	mov    %ebp,%eax
  8020de:	89 f7                	mov    %esi,%edi
  8020e0:	f7 f1                	div    %ecx
  8020e2:	89 fa                	mov    %edi,%edx
  8020e4:	83 c4 1c             	add    $0x1c,%esp
  8020e7:	5b                   	pop    %ebx
  8020e8:	5e                   	pop    %esi
  8020e9:	5f                   	pop    %edi
  8020ea:	5d                   	pop    %ebp
  8020eb:	c3                   	ret    
  8020ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020f0:	39 f2                	cmp    %esi,%edx
  8020f2:	77 7c                	ja     802170 <__udivdi3+0xd0>
  8020f4:	0f bd fa             	bsr    %edx,%edi
  8020f7:	83 f7 1f             	xor    $0x1f,%edi
  8020fa:	0f 84 98 00 00 00    	je     802198 <__udivdi3+0xf8>
  802100:	89 f9                	mov    %edi,%ecx
  802102:	b8 20 00 00 00       	mov    $0x20,%eax
  802107:	29 f8                	sub    %edi,%eax
  802109:	d3 e2                	shl    %cl,%edx
  80210b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80210f:	89 c1                	mov    %eax,%ecx
  802111:	89 da                	mov    %ebx,%edx
  802113:	d3 ea                	shr    %cl,%edx
  802115:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802119:	09 d1                	or     %edx,%ecx
  80211b:	89 f2                	mov    %esi,%edx
  80211d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802121:	89 f9                	mov    %edi,%ecx
  802123:	d3 e3                	shl    %cl,%ebx
  802125:	89 c1                	mov    %eax,%ecx
  802127:	d3 ea                	shr    %cl,%edx
  802129:	89 f9                	mov    %edi,%ecx
  80212b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80212f:	d3 e6                	shl    %cl,%esi
  802131:	89 eb                	mov    %ebp,%ebx
  802133:	89 c1                	mov    %eax,%ecx
  802135:	d3 eb                	shr    %cl,%ebx
  802137:	09 de                	or     %ebx,%esi
  802139:	89 f0                	mov    %esi,%eax
  80213b:	f7 74 24 08          	divl   0x8(%esp)
  80213f:	89 d6                	mov    %edx,%esi
  802141:	89 c3                	mov    %eax,%ebx
  802143:	f7 64 24 0c          	mull   0xc(%esp)
  802147:	39 d6                	cmp    %edx,%esi
  802149:	72 0c                	jb     802157 <__udivdi3+0xb7>
  80214b:	89 f9                	mov    %edi,%ecx
  80214d:	d3 e5                	shl    %cl,%ebp
  80214f:	39 c5                	cmp    %eax,%ebp
  802151:	73 5d                	jae    8021b0 <__udivdi3+0x110>
  802153:	39 d6                	cmp    %edx,%esi
  802155:	75 59                	jne    8021b0 <__udivdi3+0x110>
  802157:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80215a:	31 ff                	xor    %edi,%edi
  80215c:	89 fa                	mov    %edi,%edx
  80215e:	83 c4 1c             	add    $0x1c,%esp
  802161:	5b                   	pop    %ebx
  802162:	5e                   	pop    %esi
  802163:	5f                   	pop    %edi
  802164:	5d                   	pop    %ebp
  802165:	c3                   	ret    
  802166:	8d 76 00             	lea    0x0(%esi),%esi
  802169:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802170:	31 ff                	xor    %edi,%edi
  802172:	31 c0                	xor    %eax,%eax
  802174:	89 fa                	mov    %edi,%edx
  802176:	83 c4 1c             	add    $0x1c,%esp
  802179:	5b                   	pop    %ebx
  80217a:	5e                   	pop    %esi
  80217b:	5f                   	pop    %edi
  80217c:	5d                   	pop    %ebp
  80217d:	c3                   	ret    
  80217e:	66 90                	xchg   %ax,%ax
  802180:	31 ff                	xor    %edi,%edi
  802182:	89 e8                	mov    %ebp,%eax
  802184:	89 f2                	mov    %esi,%edx
  802186:	f7 f3                	div    %ebx
  802188:	89 fa                	mov    %edi,%edx
  80218a:	83 c4 1c             	add    $0x1c,%esp
  80218d:	5b                   	pop    %ebx
  80218e:	5e                   	pop    %esi
  80218f:	5f                   	pop    %edi
  802190:	5d                   	pop    %ebp
  802191:	c3                   	ret    
  802192:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802198:	39 f2                	cmp    %esi,%edx
  80219a:	72 06                	jb     8021a2 <__udivdi3+0x102>
  80219c:	31 c0                	xor    %eax,%eax
  80219e:	39 eb                	cmp    %ebp,%ebx
  8021a0:	77 d2                	ja     802174 <__udivdi3+0xd4>
  8021a2:	b8 01 00 00 00       	mov    $0x1,%eax
  8021a7:	eb cb                	jmp    802174 <__udivdi3+0xd4>
  8021a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021b0:	89 d8                	mov    %ebx,%eax
  8021b2:	31 ff                	xor    %edi,%edi
  8021b4:	eb be                	jmp    802174 <__udivdi3+0xd4>
  8021b6:	66 90                	xchg   %ax,%ax
  8021b8:	66 90                	xchg   %ax,%ax
  8021ba:	66 90                	xchg   %ax,%ax
  8021bc:	66 90                	xchg   %ax,%ax
  8021be:	66 90                	xchg   %ax,%ax

008021c0 <__umoddi3>:
  8021c0:	55                   	push   %ebp
  8021c1:	57                   	push   %edi
  8021c2:	56                   	push   %esi
  8021c3:	53                   	push   %ebx
  8021c4:	83 ec 1c             	sub    $0x1c,%esp
  8021c7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  8021cb:	8b 74 24 30          	mov    0x30(%esp),%esi
  8021cf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8021d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021d7:	85 ed                	test   %ebp,%ebp
  8021d9:	89 f0                	mov    %esi,%eax
  8021db:	89 da                	mov    %ebx,%edx
  8021dd:	75 19                	jne    8021f8 <__umoddi3+0x38>
  8021df:	39 df                	cmp    %ebx,%edi
  8021e1:	0f 86 b1 00 00 00    	jbe    802298 <__umoddi3+0xd8>
  8021e7:	f7 f7                	div    %edi
  8021e9:	89 d0                	mov    %edx,%eax
  8021eb:	31 d2                	xor    %edx,%edx
  8021ed:	83 c4 1c             	add    $0x1c,%esp
  8021f0:	5b                   	pop    %ebx
  8021f1:	5e                   	pop    %esi
  8021f2:	5f                   	pop    %edi
  8021f3:	5d                   	pop    %ebp
  8021f4:	c3                   	ret    
  8021f5:	8d 76 00             	lea    0x0(%esi),%esi
  8021f8:	39 dd                	cmp    %ebx,%ebp
  8021fa:	77 f1                	ja     8021ed <__umoddi3+0x2d>
  8021fc:	0f bd cd             	bsr    %ebp,%ecx
  8021ff:	83 f1 1f             	xor    $0x1f,%ecx
  802202:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802206:	0f 84 b4 00 00 00    	je     8022c0 <__umoddi3+0x100>
  80220c:	b8 20 00 00 00       	mov    $0x20,%eax
  802211:	89 c2                	mov    %eax,%edx
  802213:	8b 44 24 04          	mov    0x4(%esp),%eax
  802217:	29 c2                	sub    %eax,%edx
  802219:	89 c1                	mov    %eax,%ecx
  80221b:	89 f8                	mov    %edi,%eax
  80221d:	d3 e5                	shl    %cl,%ebp
  80221f:	89 d1                	mov    %edx,%ecx
  802221:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802225:	d3 e8                	shr    %cl,%eax
  802227:	09 c5                	or     %eax,%ebp
  802229:	8b 44 24 04          	mov    0x4(%esp),%eax
  80222d:	89 c1                	mov    %eax,%ecx
  80222f:	d3 e7                	shl    %cl,%edi
  802231:	89 d1                	mov    %edx,%ecx
  802233:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802237:	89 df                	mov    %ebx,%edi
  802239:	d3 ef                	shr    %cl,%edi
  80223b:	89 c1                	mov    %eax,%ecx
  80223d:	89 f0                	mov    %esi,%eax
  80223f:	d3 e3                	shl    %cl,%ebx
  802241:	89 d1                	mov    %edx,%ecx
  802243:	89 fa                	mov    %edi,%edx
  802245:	d3 e8                	shr    %cl,%eax
  802247:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80224c:	09 d8                	or     %ebx,%eax
  80224e:	f7 f5                	div    %ebp
  802250:	d3 e6                	shl    %cl,%esi
  802252:	89 d1                	mov    %edx,%ecx
  802254:	f7 64 24 08          	mull   0x8(%esp)
  802258:	39 d1                	cmp    %edx,%ecx
  80225a:	89 c3                	mov    %eax,%ebx
  80225c:	89 d7                	mov    %edx,%edi
  80225e:	72 06                	jb     802266 <__umoddi3+0xa6>
  802260:	75 0e                	jne    802270 <__umoddi3+0xb0>
  802262:	39 c6                	cmp    %eax,%esi
  802264:	73 0a                	jae    802270 <__umoddi3+0xb0>
  802266:	2b 44 24 08          	sub    0x8(%esp),%eax
  80226a:	19 ea                	sbb    %ebp,%edx
  80226c:	89 d7                	mov    %edx,%edi
  80226e:	89 c3                	mov    %eax,%ebx
  802270:	89 ca                	mov    %ecx,%edx
  802272:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  802277:	29 de                	sub    %ebx,%esi
  802279:	19 fa                	sbb    %edi,%edx
  80227b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80227f:	89 d0                	mov    %edx,%eax
  802281:	d3 e0                	shl    %cl,%eax
  802283:	89 d9                	mov    %ebx,%ecx
  802285:	d3 ee                	shr    %cl,%esi
  802287:	d3 ea                	shr    %cl,%edx
  802289:	09 f0                	or     %esi,%eax
  80228b:	83 c4 1c             	add    $0x1c,%esp
  80228e:	5b                   	pop    %ebx
  80228f:	5e                   	pop    %esi
  802290:	5f                   	pop    %edi
  802291:	5d                   	pop    %ebp
  802292:	c3                   	ret    
  802293:	90                   	nop
  802294:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802298:	85 ff                	test   %edi,%edi
  80229a:	89 f9                	mov    %edi,%ecx
  80229c:	75 0b                	jne    8022a9 <__umoddi3+0xe9>
  80229e:	b8 01 00 00 00       	mov    $0x1,%eax
  8022a3:	31 d2                	xor    %edx,%edx
  8022a5:	f7 f7                	div    %edi
  8022a7:	89 c1                	mov    %eax,%ecx
  8022a9:	89 d8                	mov    %ebx,%eax
  8022ab:	31 d2                	xor    %edx,%edx
  8022ad:	f7 f1                	div    %ecx
  8022af:	89 f0                	mov    %esi,%eax
  8022b1:	f7 f1                	div    %ecx
  8022b3:	e9 31 ff ff ff       	jmp    8021e9 <__umoddi3+0x29>
  8022b8:	90                   	nop
  8022b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022c0:	39 dd                	cmp    %ebx,%ebp
  8022c2:	72 08                	jb     8022cc <__umoddi3+0x10c>
  8022c4:	39 f7                	cmp    %esi,%edi
  8022c6:	0f 87 21 ff ff ff    	ja     8021ed <__umoddi3+0x2d>
  8022cc:	89 da                	mov    %ebx,%edx
  8022ce:	89 f0                	mov    %esi,%eax
  8022d0:	29 f8                	sub    %edi,%eax
  8022d2:	19 ea                	sbb    %ebp,%edx
  8022d4:	e9 14 ff ff ff       	jmp    8021ed <__umoddi3+0x2d>
