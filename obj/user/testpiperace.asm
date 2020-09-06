
obj/user/testpiperace.debug:     file format elf32-i386


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
  80002c:	e8 bf 01 00 00       	call   8001f0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 1c             	sub    $0x1c,%esp
	int p[2], r, pid, i, max;
	void *va;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for dup race...\n");
  80003b:	68 00 23 80 00       	push   $0x802300
  800040:	e8 e6 02 00 00       	call   80032b <cprintf>
	if ((r = pipe(p)) < 0)
  800045:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800048:	89 04 24             	mov    %eax,(%esp)
  80004b:	e8 e6 1c 00 00       	call   801d36 <pipe>
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	78 5b                	js     8000b2 <umain+0x7f>
		panic("pipe: %e", r);
	max = 200;
	if ((r = fork()) < 0)
  800057:	e8 cc 0f 00 00       	call   801028 <fork>
  80005c:	89 c6                	mov    %eax,%esi
  80005e:	85 c0                	test   %eax,%eax
  800060:	78 62                	js     8000c4 <umain+0x91>
		panic("fork: %e", r);
	if (r == 0) {
  800062:	85 c0                	test   %eax,%eax
  800064:	74 70                	je     8000d6 <umain+0xa3>
		}
		// do something to be not runnable besides exiting
		ipc_recv(0,0,0);
	}
	pid = r;
	cprintf("pid is %d\n", pid);
  800066:	83 ec 08             	sub    $0x8,%esp
  800069:	56                   	push   %esi
  80006a:	68 5a 23 80 00       	push   $0x80235a
  80006f:	e8 b7 02 00 00       	call   80032b <cprintf>
	va = 0;
	kid = &envs[ENVX(pid)];
  800074:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	cprintf("kid is %d\n", kid-envs);
  80007a:	83 c4 08             	add    $0x8,%esp
  80007d:	6b c6 7c             	imul   $0x7c,%esi,%eax
  800080:	c1 f8 02             	sar    $0x2,%eax
  800083:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
  800089:	50                   	push   %eax
  80008a:	68 65 23 80 00       	push   $0x802365
  80008f:	e8 97 02 00 00       	call   80032b <cprintf>
	dup(p[0], 10);
  800094:	83 c4 08             	add    $0x8,%esp
  800097:	6a 0a                	push   $0xa
  800099:	ff 75 f0             	pushl  -0x10(%ebp)
  80009c:	e8 93 14 00 00       	call   801534 <dup>
	while (kid->env_status == ENV_RUNNABLE)
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	6b de 7c             	imul   $0x7c,%esi,%ebx
  8000a7:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  8000ad:	e9 92 00 00 00       	jmp    800144 <umain+0x111>
		panic("pipe: %e", r);
  8000b2:	50                   	push   %eax
  8000b3:	68 19 23 80 00       	push   $0x802319
  8000b8:	6a 0d                	push   $0xd
  8000ba:	68 22 23 80 00       	push   $0x802322
  8000bf:	e8 8c 01 00 00       	call   800250 <_panic>
		panic("fork: %e", r);
  8000c4:	50                   	push   %eax
  8000c5:	68 36 23 80 00       	push   $0x802336
  8000ca:	6a 10                	push   $0x10
  8000cc:	68 22 23 80 00       	push   $0x802322
  8000d1:	e8 7a 01 00 00       	call   800250 <_panic>
		close(p[1]);
  8000d6:	83 ec 0c             	sub    $0xc,%esp
  8000d9:	ff 75 f4             	pushl  -0xc(%ebp)
  8000dc:	e8 03 14 00 00       	call   8014e4 <close>
  8000e1:	83 c4 10             	add    $0x10,%esp
  8000e4:	bb c8 00 00 00       	mov    $0xc8,%ebx
  8000e9:	eb 0a                	jmp    8000f5 <umain+0xc2>
			sys_yield();
  8000eb:	e8 34 0c 00 00       	call   800d24 <sys_yield>
		for (i=0; i<max; i++) {
  8000f0:	83 eb 01             	sub    $0x1,%ebx
  8000f3:	74 29                	je     80011e <umain+0xeb>
			if(pipeisclosed(p[0])){
  8000f5:	83 ec 0c             	sub    $0xc,%esp
  8000f8:	ff 75 f0             	pushl  -0x10(%ebp)
  8000fb:	e8 7f 1d 00 00       	call   801e7f <pipeisclosed>
  800100:	83 c4 10             	add    $0x10,%esp
  800103:	85 c0                	test   %eax,%eax
  800105:	74 e4                	je     8000eb <umain+0xb8>
				cprintf("RACE: pipe appears closed\n");
  800107:	83 ec 0c             	sub    $0xc,%esp
  80010a:	68 3f 23 80 00       	push   $0x80233f
  80010f:	e8 17 02 00 00       	call   80032b <cprintf>
				exit();
  800114:	e8 1d 01 00 00       	call   800236 <exit>
  800119:	83 c4 10             	add    $0x10,%esp
  80011c:	eb cd                	jmp    8000eb <umain+0xb8>
		ipc_recv(0,0,0);
  80011e:	83 ec 04             	sub    $0x4,%esp
  800121:	6a 00                	push   $0x0
  800123:	6a 00                	push   $0x0
  800125:	6a 00                	push   $0x0
  800127:	e8 09 11 00 00       	call   801235 <ipc_recv>
  80012c:	83 c4 10             	add    $0x10,%esp
  80012f:	e9 32 ff ff ff       	jmp    800066 <umain+0x33>
		dup(p[0], 10);
  800134:	83 ec 08             	sub    $0x8,%esp
  800137:	6a 0a                	push   $0xa
  800139:	ff 75 f0             	pushl  -0x10(%ebp)
  80013c:	e8 f3 13 00 00       	call   801534 <dup>
  800141:	83 c4 10             	add    $0x10,%esp
	while (kid->env_status == ENV_RUNNABLE)
  800144:	8b 53 54             	mov    0x54(%ebx),%edx
  800147:	83 fa 02             	cmp    $0x2,%edx
  80014a:	74 e8                	je     800134 <umain+0x101>

	cprintf("child done with loop\n");
  80014c:	83 ec 0c             	sub    $0xc,%esp
  80014f:	68 70 23 80 00       	push   $0x802370
  800154:	e8 d2 01 00 00       	call   80032b <cprintf>
	if (pipeisclosed(p[0]))
  800159:	83 c4 04             	add    $0x4,%esp
  80015c:	ff 75 f0             	pushl  -0x10(%ebp)
  80015f:	e8 1b 1d 00 00       	call   801e7f <pipeisclosed>
  800164:	83 c4 10             	add    $0x10,%esp
  800167:	85 c0                	test   %eax,%eax
  800169:	75 48                	jne    8001b3 <umain+0x180>
		panic("somehow the other end of p[0] got closed!");
	if ((r = fd_lookup(p[0], &fd)) < 0)
  80016b:	83 ec 08             	sub    $0x8,%esp
  80016e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800171:	50                   	push   %eax
  800172:	ff 75 f0             	pushl  -0x10(%ebp)
  800175:	e8 35 12 00 00       	call   8013af <fd_lookup>
  80017a:	83 c4 10             	add    $0x10,%esp
  80017d:	85 c0                	test   %eax,%eax
  80017f:	78 46                	js     8001c7 <umain+0x194>
		panic("cannot look up p[0]: %e", r);
	va = fd2data(fd);
  800181:	83 ec 0c             	sub    $0xc,%esp
  800184:	ff 75 ec             	pushl  -0x14(%ebp)
  800187:	e8 bd 11 00 00       	call   801349 <fd2data>
	if (pageref(va) != 3+1)
  80018c:	89 04 24             	mov    %eax,(%esp)
  80018f:	e8 96 19 00 00       	call   801b2a <pageref>
  800194:	83 c4 10             	add    $0x10,%esp
  800197:	83 f8 04             	cmp    $0x4,%eax
  80019a:	74 3d                	je     8001d9 <umain+0x1a6>
		cprintf("\nchild detected race\n");
  80019c:	83 ec 0c             	sub    $0xc,%esp
  80019f:	68 9e 23 80 00       	push   $0x80239e
  8001a4:	e8 82 01 00 00       	call   80032b <cprintf>
  8001a9:	83 c4 10             	add    $0x10,%esp
	else
		cprintf("\nrace didn't happen\n", max);
}
  8001ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001af:	5b                   	pop    %ebx
  8001b0:	5e                   	pop    %esi
  8001b1:	5d                   	pop    %ebp
  8001b2:	c3                   	ret    
		panic("somehow the other end of p[0] got closed!");
  8001b3:	83 ec 04             	sub    $0x4,%esp
  8001b6:	68 cc 23 80 00       	push   $0x8023cc
  8001bb:	6a 3a                	push   $0x3a
  8001bd:	68 22 23 80 00       	push   $0x802322
  8001c2:	e8 89 00 00 00       	call   800250 <_panic>
		panic("cannot look up p[0]: %e", r);
  8001c7:	50                   	push   %eax
  8001c8:	68 86 23 80 00       	push   $0x802386
  8001cd:	6a 3c                	push   $0x3c
  8001cf:	68 22 23 80 00       	push   $0x802322
  8001d4:	e8 77 00 00 00       	call   800250 <_panic>
		cprintf("\nrace didn't happen\n", max);
  8001d9:	83 ec 08             	sub    $0x8,%esp
  8001dc:	68 c8 00 00 00       	push   $0xc8
  8001e1:	68 b4 23 80 00       	push   $0x8023b4
  8001e6:	e8 40 01 00 00       	call   80032b <cprintf>
  8001eb:	83 c4 10             	add    $0x10,%esp
}
  8001ee:	eb bc                	jmp    8001ac <umain+0x179>

008001f0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	56                   	push   %esi
  8001f4:	53                   	push   %ebx
  8001f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001f8:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001fb:	e8 05 0b 00 00       	call   800d05 <sys_getenvid>
  800200:	25 ff 03 00 00       	and    $0x3ff,%eax
  800205:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800208:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80020d:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800212:	85 db                	test   %ebx,%ebx
  800214:	7e 07                	jle    80021d <libmain+0x2d>
		binaryname = argv[0];
  800216:	8b 06                	mov    (%esi),%eax
  800218:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80021d:	83 ec 08             	sub    $0x8,%esp
  800220:	56                   	push   %esi
  800221:	53                   	push   %ebx
  800222:	e8 0c fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800227:	e8 0a 00 00 00       	call   800236 <exit>
}
  80022c:	83 c4 10             	add    $0x10,%esp
  80022f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800232:	5b                   	pop    %ebx
  800233:	5e                   	pop    %esi
  800234:	5d                   	pop    %ebp
  800235:	c3                   	ret    

00800236 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
  800239:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80023c:	e8 ce 12 00 00       	call   80150f <close_all>
	sys_env_destroy(0);
  800241:	83 ec 0c             	sub    $0xc,%esp
  800244:	6a 00                	push   $0x0
  800246:	e8 79 0a 00 00       	call   800cc4 <sys_env_destroy>
}
  80024b:	83 c4 10             	add    $0x10,%esp
  80024e:	c9                   	leave  
  80024f:	c3                   	ret    

00800250 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	56                   	push   %esi
  800254:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800255:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800258:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80025e:	e8 a2 0a 00 00       	call   800d05 <sys_getenvid>
  800263:	83 ec 0c             	sub    $0xc,%esp
  800266:	ff 75 0c             	pushl  0xc(%ebp)
  800269:	ff 75 08             	pushl  0x8(%ebp)
  80026c:	56                   	push   %esi
  80026d:	50                   	push   %eax
  80026e:	68 00 24 80 00       	push   $0x802400
  800273:	e8 b3 00 00 00       	call   80032b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800278:	83 c4 18             	add    $0x18,%esp
  80027b:	53                   	push   %ebx
  80027c:	ff 75 10             	pushl  0x10(%ebp)
  80027f:	e8 56 00 00 00       	call   8002da <vcprintf>
	cprintf("\n");
  800284:	c7 04 24 17 23 80 00 	movl   $0x802317,(%esp)
  80028b:	e8 9b 00 00 00       	call   80032b <cprintf>
  800290:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800293:	cc                   	int3   
  800294:	eb fd                	jmp    800293 <_panic+0x43>

00800296 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800296:	55                   	push   %ebp
  800297:	89 e5                	mov    %esp,%ebp
  800299:	53                   	push   %ebx
  80029a:	83 ec 04             	sub    $0x4,%esp
  80029d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002a0:	8b 13                	mov    (%ebx),%edx
  8002a2:	8d 42 01             	lea    0x1(%edx),%eax
  8002a5:	89 03                	mov    %eax,(%ebx)
  8002a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002aa:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002ae:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002b3:	74 09                	je     8002be <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8002b5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002bc:	c9                   	leave  
  8002bd:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8002be:	83 ec 08             	sub    $0x8,%esp
  8002c1:	68 ff 00 00 00       	push   $0xff
  8002c6:	8d 43 08             	lea    0x8(%ebx),%eax
  8002c9:	50                   	push   %eax
  8002ca:	e8 b8 09 00 00       	call   800c87 <sys_cputs>
		b->idx = 0;
  8002cf:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002d5:	83 c4 10             	add    $0x10,%esp
  8002d8:	eb db                	jmp    8002b5 <putch+0x1f>

008002da <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002da:	55                   	push   %ebp
  8002db:	89 e5                	mov    %esp,%ebp
  8002dd:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002e3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002ea:	00 00 00 
	b.cnt = 0;
  8002ed:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002f4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002f7:	ff 75 0c             	pushl  0xc(%ebp)
  8002fa:	ff 75 08             	pushl  0x8(%ebp)
  8002fd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800303:	50                   	push   %eax
  800304:	68 96 02 80 00       	push   $0x800296
  800309:	e8 1a 01 00 00       	call   800428 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80030e:	83 c4 08             	add    $0x8,%esp
  800311:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800317:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80031d:	50                   	push   %eax
  80031e:	e8 64 09 00 00       	call   800c87 <sys_cputs>

	return b.cnt;
}
  800323:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800329:	c9                   	leave  
  80032a:	c3                   	ret    

0080032b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80032b:	55                   	push   %ebp
  80032c:	89 e5                	mov    %esp,%ebp
  80032e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800331:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800334:	50                   	push   %eax
  800335:	ff 75 08             	pushl  0x8(%ebp)
  800338:	e8 9d ff ff ff       	call   8002da <vcprintf>
	va_end(ap);

	return cnt;
}
  80033d:	c9                   	leave  
  80033e:	c3                   	ret    

0080033f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80033f:	55                   	push   %ebp
  800340:	89 e5                	mov    %esp,%ebp
  800342:	57                   	push   %edi
  800343:	56                   	push   %esi
  800344:	53                   	push   %ebx
  800345:	83 ec 1c             	sub    $0x1c,%esp
  800348:	89 c7                	mov    %eax,%edi
  80034a:	89 d6                	mov    %edx,%esi
  80034c:	8b 45 08             	mov    0x8(%ebp),%eax
  80034f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800352:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800355:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800358:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80035b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800360:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800363:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800366:	39 d3                	cmp    %edx,%ebx
  800368:	72 05                	jb     80036f <printnum+0x30>
  80036a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80036d:	77 7a                	ja     8003e9 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80036f:	83 ec 0c             	sub    $0xc,%esp
  800372:	ff 75 18             	pushl  0x18(%ebp)
  800375:	8b 45 14             	mov    0x14(%ebp),%eax
  800378:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80037b:	53                   	push   %ebx
  80037c:	ff 75 10             	pushl  0x10(%ebp)
  80037f:	83 ec 08             	sub    $0x8,%esp
  800382:	ff 75 e4             	pushl  -0x1c(%ebp)
  800385:	ff 75 e0             	pushl  -0x20(%ebp)
  800388:	ff 75 dc             	pushl  -0x24(%ebp)
  80038b:	ff 75 d8             	pushl  -0x28(%ebp)
  80038e:	e8 2d 1d 00 00       	call   8020c0 <__udivdi3>
  800393:	83 c4 18             	add    $0x18,%esp
  800396:	52                   	push   %edx
  800397:	50                   	push   %eax
  800398:	89 f2                	mov    %esi,%edx
  80039a:	89 f8                	mov    %edi,%eax
  80039c:	e8 9e ff ff ff       	call   80033f <printnum>
  8003a1:	83 c4 20             	add    $0x20,%esp
  8003a4:	eb 13                	jmp    8003b9 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003a6:	83 ec 08             	sub    $0x8,%esp
  8003a9:	56                   	push   %esi
  8003aa:	ff 75 18             	pushl  0x18(%ebp)
  8003ad:	ff d7                	call   *%edi
  8003af:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8003b2:	83 eb 01             	sub    $0x1,%ebx
  8003b5:	85 db                	test   %ebx,%ebx
  8003b7:	7f ed                	jg     8003a6 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003b9:	83 ec 08             	sub    $0x8,%esp
  8003bc:	56                   	push   %esi
  8003bd:	83 ec 04             	sub    $0x4,%esp
  8003c0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003c3:	ff 75 e0             	pushl  -0x20(%ebp)
  8003c6:	ff 75 dc             	pushl  -0x24(%ebp)
  8003c9:	ff 75 d8             	pushl  -0x28(%ebp)
  8003cc:	e8 0f 1e 00 00       	call   8021e0 <__umoddi3>
  8003d1:	83 c4 14             	add    $0x14,%esp
  8003d4:	0f be 80 23 24 80 00 	movsbl 0x802423(%eax),%eax
  8003db:	50                   	push   %eax
  8003dc:	ff d7                	call   *%edi
}
  8003de:	83 c4 10             	add    $0x10,%esp
  8003e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003e4:	5b                   	pop    %ebx
  8003e5:	5e                   	pop    %esi
  8003e6:	5f                   	pop    %edi
  8003e7:	5d                   	pop    %ebp
  8003e8:	c3                   	ret    
  8003e9:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003ec:	eb c4                	jmp    8003b2 <printnum+0x73>

008003ee <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ee:	55                   	push   %ebp
  8003ef:	89 e5                	mov    %esp,%ebp
  8003f1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003f4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003f8:	8b 10                	mov    (%eax),%edx
  8003fa:	3b 50 04             	cmp    0x4(%eax),%edx
  8003fd:	73 0a                	jae    800409 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003ff:	8d 4a 01             	lea    0x1(%edx),%ecx
  800402:	89 08                	mov    %ecx,(%eax)
  800404:	8b 45 08             	mov    0x8(%ebp),%eax
  800407:	88 02                	mov    %al,(%edx)
}
  800409:	5d                   	pop    %ebp
  80040a:	c3                   	ret    

0080040b <printfmt>:
{
  80040b:	55                   	push   %ebp
  80040c:	89 e5                	mov    %esp,%ebp
  80040e:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800411:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800414:	50                   	push   %eax
  800415:	ff 75 10             	pushl  0x10(%ebp)
  800418:	ff 75 0c             	pushl  0xc(%ebp)
  80041b:	ff 75 08             	pushl  0x8(%ebp)
  80041e:	e8 05 00 00 00       	call   800428 <vprintfmt>
}
  800423:	83 c4 10             	add    $0x10,%esp
  800426:	c9                   	leave  
  800427:	c3                   	ret    

00800428 <vprintfmt>:
{
  800428:	55                   	push   %ebp
  800429:	89 e5                	mov    %esp,%ebp
  80042b:	57                   	push   %edi
  80042c:	56                   	push   %esi
  80042d:	53                   	push   %ebx
  80042e:	83 ec 2c             	sub    $0x2c,%esp
  800431:	8b 75 08             	mov    0x8(%ebp),%esi
  800434:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800437:	8b 7d 10             	mov    0x10(%ebp),%edi
  80043a:	e9 c1 03 00 00       	jmp    800800 <vprintfmt+0x3d8>
		padc = ' ';
  80043f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800443:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  80044a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800451:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800458:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80045d:	8d 47 01             	lea    0x1(%edi),%eax
  800460:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800463:	0f b6 17             	movzbl (%edi),%edx
  800466:	8d 42 dd             	lea    -0x23(%edx),%eax
  800469:	3c 55                	cmp    $0x55,%al
  80046b:	0f 87 12 04 00 00    	ja     800883 <vprintfmt+0x45b>
  800471:	0f b6 c0             	movzbl %al,%eax
  800474:	ff 24 85 60 25 80 00 	jmp    *0x802560(,%eax,4)
  80047b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80047e:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800482:	eb d9                	jmp    80045d <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800484:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800487:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80048b:	eb d0                	jmp    80045d <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80048d:	0f b6 d2             	movzbl %dl,%edx
  800490:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800493:	b8 00 00 00 00       	mov    $0x0,%eax
  800498:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80049b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80049e:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8004a2:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8004a5:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8004a8:	83 f9 09             	cmp    $0x9,%ecx
  8004ab:	77 55                	ja     800502 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  8004ad:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8004b0:	eb e9                	jmp    80049b <vprintfmt+0x73>
			precision = va_arg(ap, int);
  8004b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b5:	8b 00                	mov    (%eax),%eax
  8004b7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bd:	8d 40 04             	lea    0x4(%eax),%eax
  8004c0:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8004c6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004ca:	79 91                	jns    80045d <vprintfmt+0x35>
				width = precision, precision = -1;
  8004cc:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004cf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004d9:	eb 82                	jmp    80045d <vprintfmt+0x35>
  8004db:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004de:	85 c0                	test   %eax,%eax
  8004e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e5:	0f 49 d0             	cmovns %eax,%edx
  8004e8:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ee:	e9 6a ff ff ff       	jmp    80045d <vprintfmt+0x35>
  8004f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8004f6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004fd:	e9 5b ff ff ff       	jmp    80045d <vprintfmt+0x35>
  800502:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800505:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800508:	eb bc                	jmp    8004c6 <vprintfmt+0x9e>
			lflag++;
  80050a:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80050d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800510:	e9 48 ff ff ff       	jmp    80045d <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  800515:	8b 45 14             	mov    0x14(%ebp),%eax
  800518:	8d 78 04             	lea    0x4(%eax),%edi
  80051b:	83 ec 08             	sub    $0x8,%esp
  80051e:	53                   	push   %ebx
  80051f:	ff 30                	pushl  (%eax)
  800521:	ff d6                	call   *%esi
			break;
  800523:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800526:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800529:	e9 cf 02 00 00       	jmp    8007fd <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  80052e:	8b 45 14             	mov    0x14(%ebp),%eax
  800531:	8d 78 04             	lea    0x4(%eax),%edi
  800534:	8b 00                	mov    (%eax),%eax
  800536:	99                   	cltd   
  800537:	31 d0                	xor    %edx,%eax
  800539:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80053b:	83 f8 0f             	cmp    $0xf,%eax
  80053e:	7f 23                	jg     800563 <vprintfmt+0x13b>
  800540:	8b 14 85 c0 26 80 00 	mov    0x8026c0(,%eax,4),%edx
  800547:	85 d2                	test   %edx,%edx
  800549:	74 18                	je     800563 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  80054b:	52                   	push   %edx
  80054c:	68 5d 29 80 00       	push   $0x80295d
  800551:	53                   	push   %ebx
  800552:	56                   	push   %esi
  800553:	e8 b3 fe ff ff       	call   80040b <printfmt>
  800558:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80055b:	89 7d 14             	mov    %edi,0x14(%ebp)
  80055e:	e9 9a 02 00 00       	jmp    8007fd <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  800563:	50                   	push   %eax
  800564:	68 3b 24 80 00       	push   $0x80243b
  800569:	53                   	push   %ebx
  80056a:	56                   	push   %esi
  80056b:	e8 9b fe ff ff       	call   80040b <printfmt>
  800570:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800573:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800576:	e9 82 02 00 00       	jmp    8007fd <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  80057b:	8b 45 14             	mov    0x14(%ebp),%eax
  80057e:	83 c0 04             	add    $0x4,%eax
  800581:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800584:	8b 45 14             	mov    0x14(%ebp),%eax
  800587:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800589:	85 ff                	test   %edi,%edi
  80058b:	b8 34 24 80 00       	mov    $0x802434,%eax
  800590:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800593:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800597:	0f 8e bd 00 00 00    	jle    80065a <vprintfmt+0x232>
  80059d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005a1:	75 0e                	jne    8005b1 <vprintfmt+0x189>
  8005a3:	89 75 08             	mov    %esi,0x8(%ebp)
  8005a6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005a9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005ac:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005af:	eb 6d                	jmp    80061e <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b1:	83 ec 08             	sub    $0x8,%esp
  8005b4:	ff 75 d0             	pushl  -0x30(%ebp)
  8005b7:	57                   	push   %edi
  8005b8:	e8 6e 03 00 00       	call   80092b <strnlen>
  8005bd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005c0:	29 c1                	sub    %eax,%ecx
  8005c2:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8005c5:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005c8:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005cc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005cf:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005d2:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d4:	eb 0f                	jmp    8005e5 <vprintfmt+0x1bd>
					putch(padc, putdat);
  8005d6:	83 ec 08             	sub    $0x8,%esp
  8005d9:	53                   	push   %ebx
  8005da:	ff 75 e0             	pushl  -0x20(%ebp)
  8005dd:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005df:	83 ef 01             	sub    $0x1,%edi
  8005e2:	83 c4 10             	add    $0x10,%esp
  8005e5:	85 ff                	test   %edi,%edi
  8005e7:	7f ed                	jg     8005d6 <vprintfmt+0x1ae>
  8005e9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005ec:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8005ef:	85 c9                	test   %ecx,%ecx
  8005f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8005f6:	0f 49 c1             	cmovns %ecx,%eax
  8005f9:	29 c1                	sub    %eax,%ecx
  8005fb:	89 75 08             	mov    %esi,0x8(%ebp)
  8005fe:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800601:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800604:	89 cb                	mov    %ecx,%ebx
  800606:	eb 16                	jmp    80061e <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  800608:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80060c:	75 31                	jne    80063f <vprintfmt+0x217>
					putch(ch, putdat);
  80060e:	83 ec 08             	sub    $0x8,%esp
  800611:	ff 75 0c             	pushl  0xc(%ebp)
  800614:	50                   	push   %eax
  800615:	ff 55 08             	call   *0x8(%ebp)
  800618:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80061b:	83 eb 01             	sub    $0x1,%ebx
  80061e:	83 c7 01             	add    $0x1,%edi
  800621:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800625:	0f be c2             	movsbl %dl,%eax
  800628:	85 c0                	test   %eax,%eax
  80062a:	74 59                	je     800685 <vprintfmt+0x25d>
  80062c:	85 f6                	test   %esi,%esi
  80062e:	78 d8                	js     800608 <vprintfmt+0x1e0>
  800630:	83 ee 01             	sub    $0x1,%esi
  800633:	79 d3                	jns    800608 <vprintfmt+0x1e0>
  800635:	89 df                	mov    %ebx,%edi
  800637:	8b 75 08             	mov    0x8(%ebp),%esi
  80063a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80063d:	eb 37                	jmp    800676 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  80063f:	0f be d2             	movsbl %dl,%edx
  800642:	83 ea 20             	sub    $0x20,%edx
  800645:	83 fa 5e             	cmp    $0x5e,%edx
  800648:	76 c4                	jbe    80060e <vprintfmt+0x1e6>
					putch('?', putdat);
  80064a:	83 ec 08             	sub    $0x8,%esp
  80064d:	ff 75 0c             	pushl  0xc(%ebp)
  800650:	6a 3f                	push   $0x3f
  800652:	ff 55 08             	call   *0x8(%ebp)
  800655:	83 c4 10             	add    $0x10,%esp
  800658:	eb c1                	jmp    80061b <vprintfmt+0x1f3>
  80065a:	89 75 08             	mov    %esi,0x8(%ebp)
  80065d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800660:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800663:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800666:	eb b6                	jmp    80061e <vprintfmt+0x1f6>
				putch(' ', putdat);
  800668:	83 ec 08             	sub    $0x8,%esp
  80066b:	53                   	push   %ebx
  80066c:	6a 20                	push   $0x20
  80066e:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800670:	83 ef 01             	sub    $0x1,%edi
  800673:	83 c4 10             	add    $0x10,%esp
  800676:	85 ff                	test   %edi,%edi
  800678:	7f ee                	jg     800668 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  80067a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80067d:	89 45 14             	mov    %eax,0x14(%ebp)
  800680:	e9 78 01 00 00       	jmp    8007fd <vprintfmt+0x3d5>
  800685:	89 df                	mov    %ebx,%edi
  800687:	8b 75 08             	mov    0x8(%ebp),%esi
  80068a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80068d:	eb e7                	jmp    800676 <vprintfmt+0x24e>
	if (lflag >= 2)
  80068f:	83 f9 01             	cmp    $0x1,%ecx
  800692:	7e 3f                	jle    8006d3 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800694:	8b 45 14             	mov    0x14(%ebp),%eax
  800697:	8b 50 04             	mov    0x4(%eax),%edx
  80069a:	8b 00                	mov    (%eax),%eax
  80069c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80069f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a5:	8d 40 08             	lea    0x8(%eax),%eax
  8006a8:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8006ab:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006af:	79 5c                	jns    80070d <vprintfmt+0x2e5>
				putch('-', putdat);
  8006b1:	83 ec 08             	sub    $0x8,%esp
  8006b4:	53                   	push   %ebx
  8006b5:	6a 2d                	push   $0x2d
  8006b7:	ff d6                	call   *%esi
				num = -(long long) num;
  8006b9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006bc:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006bf:	f7 da                	neg    %edx
  8006c1:	83 d1 00             	adc    $0x0,%ecx
  8006c4:	f7 d9                	neg    %ecx
  8006c6:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006c9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ce:	e9 10 01 00 00       	jmp    8007e3 <vprintfmt+0x3bb>
	else if (lflag)
  8006d3:	85 c9                	test   %ecx,%ecx
  8006d5:	75 1b                	jne    8006f2 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8006d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006da:	8b 00                	mov    (%eax),%eax
  8006dc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006df:	89 c1                	mov    %eax,%ecx
  8006e1:	c1 f9 1f             	sar    $0x1f,%ecx
  8006e4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ea:	8d 40 04             	lea    0x4(%eax),%eax
  8006ed:	89 45 14             	mov    %eax,0x14(%ebp)
  8006f0:	eb b9                	jmp    8006ab <vprintfmt+0x283>
		return va_arg(*ap, long);
  8006f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f5:	8b 00                	mov    (%eax),%eax
  8006f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006fa:	89 c1                	mov    %eax,%ecx
  8006fc:	c1 f9 1f             	sar    $0x1f,%ecx
  8006ff:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800702:	8b 45 14             	mov    0x14(%ebp),%eax
  800705:	8d 40 04             	lea    0x4(%eax),%eax
  800708:	89 45 14             	mov    %eax,0x14(%ebp)
  80070b:	eb 9e                	jmp    8006ab <vprintfmt+0x283>
			num = getint(&ap, lflag);
  80070d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800710:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800713:	b8 0a 00 00 00       	mov    $0xa,%eax
  800718:	e9 c6 00 00 00       	jmp    8007e3 <vprintfmt+0x3bb>
	if (lflag >= 2)
  80071d:	83 f9 01             	cmp    $0x1,%ecx
  800720:	7e 18                	jle    80073a <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  800722:	8b 45 14             	mov    0x14(%ebp),%eax
  800725:	8b 10                	mov    (%eax),%edx
  800727:	8b 48 04             	mov    0x4(%eax),%ecx
  80072a:	8d 40 08             	lea    0x8(%eax),%eax
  80072d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800730:	b8 0a 00 00 00       	mov    $0xa,%eax
  800735:	e9 a9 00 00 00       	jmp    8007e3 <vprintfmt+0x3bb>
	else if (lflag)
  80073a:	85 c9                	test   %ecx,%ecx
  80073c:	75 1a                	jne    800758 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  80073e:	8b 45 14             	mov    0x14(%ebp),%eax
  800741:	8b 10                	mov    (%eax),%edx
  800743:	b9 00 00 00 00       	mov    $0x0,%ecx
  800748:	8d 40 04             	lea    0x4(%eax),%eax
  80074b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80074e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800753:	e9 8b 00 00 00       	jmp    8007e3 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800758:	8b 45 14             	mov    0x14(%ebp),%eax
  80075b:	8b 10                	mov    (%eax),%edx
  80075d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800762:	8d 40 04             	lea    0x4(%eax),%eax
  800765:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800768:	b8 0a 00 00 00       	mov    $0xa,%eax
  80076d:	eb 74                	jmp    8007e3 <vprintfmt+0x3bb>
	if (lflag >= 2)
  80076f:	83 f9 01             	cmp    $0x1,%ecx
  800772:	7e 15                	jle    800789 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  800774:	8b 45 14             	mov    0x14(%ebp),%eax
  800777:	8b 10                	mov    (%eax),%edx
  800779:	8b 48 04             	mov    0x4(%eax),%ecx
  80077c:	8d 40 08             	lea    0x8(%eax),%eax
  80077f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800782:	b8 08 00 00 00       	mov    $0x8,%eax
  800787:	eb 5a                	jmp    8007e3 <vprintfmt+0x3bb>
	else if (lflag)
  800789:	85 c9                	test   %ecx,%ecx
  80078b:	75 17                	jne    8007a4 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  80078d:	8b 45 14             	mov    0x14(%ebp),%eax
  800790:	8b 10                	mov    (%eax),%edx
  800792:	b9 00 00 00 00       	mov    $0x0,%ecx
  800797:	8d 40 04             	lea    0x4(%eax),%eax
  80079a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80079d:	b8 08 00 00 00       	mov    $0x8,%eax
  8007a2:	eb 3f                	jmp    8007e3 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8007a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a7:	8b 10                	mov    (%eax),%edx
  8007a9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007ae:	8d 40 04             	lea    0x4(%eax),%eax
  8007b1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8007b4:	b8 08 00 00 00       	mov    $0x8,%eax
  8007b9:	eb 28                	jmp    8007e3 <vprintfmt+0x3bb>
			putch('0', putdat);
  8007bb:	83 ec 08             	sub    $0x8,%esp
  8007be:	53                   	push   %ebx
  8007bf:	6a 30                	push   $0x30
  8007c1:	ff d6                	call   *%esi
			putch('x', putdat);
  8007c3:	83 c4 08             	add    $0x8,%esp
  8007c6:	53                   	push   %ebx
  8007c7:	6a 78                	push   $0x78
  8007c9:	ff d6                	call   *%esi
			num = (unsigned long long)
  8007cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ce:	8b 10                	mov    (%eax),%edx
  8007d0:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8007d5:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8007d8:	8d 40 04             	lea    0x4(%eax),%eax
  8007db:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007de:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8007e3:	83 ec 0c             	sub    $0xc,%esp
  8007e6:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007ea:	57                   	push   %edi
  8007eb:	ff 75 e0             	pushl  -0x20(%ebp)
  8007ee:	50                   	push   %eax
  8007ef:	51                   	push   %ecx
  8007f0:	52                   	push   %edx
  8007f1:	89 da                	mov    %ebx,%edx
  8007f3:	89 f0                	mov    %esi,%eax
  8007f5:	e8 45 fb ff ff       	call   80033f <printnum>
			break;
  8007fa:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8007fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800800:	83 c7 01             	add    $0x1,%edi
  800803:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800807:	83 f8 25             	cmp    $0x25,%eax
  80080a:	0f 84 2f fc ff ff    	je     80043f <vprintfmt+0x17>
			if (ch == '\0')
  800810:	85 c0                	test   %eax,%eax
  800812:	0f 84 8b 00 00 00    	je     8008a3 <vprintfmt+0x47b>
			putch(ch, putdat);
  800818:	83 ec 08             	sub    $0x8,%esp
  80081b:	53                   	push   %ebx
  80081c:	50                   	push   %eax
  80081d:	ff d6                	call   *%esi
  80081f:	83 c4 10             	add    $0x10,%esp
  800822:	eb dc                	jmp    800800 <vprintfmt+0x3d8>
	if (lflag >= 2)
  800824:	83 f9 01             	cmp    $0x1,%ecx
  800827:	7e 15                	jle    80083e <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  800829:	8b 45 14             	mov    0x14(%ebp),%eax
  80082c:	8b 10                	mov    (%eax),%edx
  80082e:	8b 48 04             	mov    0x4(%eax),%ecx
  800831:	8d 40 08             	lea    0x8(%eax),%eax
  800834:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800837:	b8 10 00 00 00       	mov    $0x10,%eax
  80083c:	eb a5                	jmp    8007e3 <vprintfmt+0x3bb>
	else if (lflag)
  80083e:	85 c9                	test   %ecx,%ecx
  800840:	75 17                	jne    800859 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  800842:	8b 45 14             	mov    0x14(%ebp),%eax
  800845:	8b 10                	mov    (%eax),%edx
  800847:	b9 00 00 00 00       	mov    $0x0,%ecx
  80084c:	8d 40 04             	lea    0x4(%eax),%eax
  80084f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800852:	b8 10 00 00 00       	mov    $0x10,%eax
  800857:	eb 8a                	jmp    8007e3 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800859:	8b 45 14             	mov    0x14(%ebp),%eax
  80085c:	8b 10                	mov    (%eax),%edx
  80085e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800863:	8d 40 04             	lea    0x4(%eax),%eax
  800866:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800869:	b8 10 00 00 00       	mov    $0x10,%eax
  80086e:	e9 70 ff ff ff       	jmp    8007e3 <vprintfmt+0x3bb>
			putch(ch, putdat);
  800873:	83 ec 08             	sub    $0x8,%esp
  800876:	53                   	push   %ebx
  800877:	6a 25                	push   $0x25
  800879:	ff d6                	call   *%esi
			break;
  80087b:	83 c4 10             	add    $0x10,%esp
  80087e:	e9 7a ff ff ff       	jmp    8007fd <vprintfmt+0x3d5>
			putch('%', putdat);
  800883:	83 ec 08             	sub    $0x8,%esp
  800886:	53                   	push   %ebx
  800887:	6a 25                	push   $0x25
  800889:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80088b:	83 c4 10             	add    $0x10,%esp
  80088e:	89 f8                	mov    %edi,%eax
  800890:	eb 03                	jmp    800895 <vprintfmt+0x46d>
  800892:	83 e8 01             	sub    $0x1,%eax
  800895:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800899:	75 f7                	jne    800892 <vprintfmt+0x46a>
  80089b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80089e:	e9 5a ff ff ff       	jmp    8007fd <vprintfmt+0x3d5>
}
  8008a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008a6:	5b                   	pop    %ebx
  8008a7:	5e                   	pop    %esi
  8008a8:	5f                   	pop    %edi
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	83 ec 18             	sub    $0x18,%esp
  8008b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008b7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008ba:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008be:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008c1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008c8:	85 c0                	test   %eax,%eax
  8008ca:	74 26                	je     8008f2 <vsnprintf+0x47>
  8008cc:	85 d2                	test   %edx,%edx
  8008ce:	7e 22                	jle    8008f2 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008d0:	ff 75 14             	pushl  0x14(%ebp)
  8008d3:	ff 75 10             	pushl  0x10(%ebp)
  8008d6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008d9:	50                   	push   %eax
  8008da:	68 ee 03 80 00       	push   $0x8003ee
  8008df:	e8 44 fb ff ff       	call   800428 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008e7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008ed:	83 c4 10             	add    $0x10,%esp
}
  8008f0:	c9                   	leave  
  8008f1:	c3                   	ret    
		return -E_INVAL;
  8008f2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008f7:	eb f7                	jmp    8008f0 <vsnprintf+0x45>

008008f9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008f9:	55                   	push   %ebp
  8008fa:	89 e5                	mov    %esp,%ebp
  8008fc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008ff:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800902:	50                   	push   %eax
  800903:	ff 75 10             	pushl  0x10(%ebp)
  800906:	ff 75 0c             	pushl  0xc(%ebp)
  800909:	ff 75 08             	pushl  0x8(%ebp)
  80090c:	e8 9a ff ff ff       	call   8008ab <vsnprintf>
	va_end(ap);

	return rc;
}
  800911:	c9                   	leave  
  800912:	c3                   	ret    

00800913 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800913:	55                   	push   %ebp
  800914:	89 e5                	mov    %esp,%ebp
  800916:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800919:	b8 00 00 00 00       	mov    $0x0,%eax
  80091e:	eb 03                	jmp    800923 <strlen+0x10>
		n++;
  800920:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800923:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800927:	75 f7                	jne    800920 <strlen+0xd>
	return n;
}
  800929:	5d                   	pop    %ebp
  80092a:	c3                   	ret    

0080092b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80092b:	55                   	push   %ebp
  80092c:	89 e5                	mov    %esp,%ebp
  80092e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800931:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800934:	b8 00 00 00 00       	mov    $0x0,%eax
  800939:	eb 03                	jmp    80093e <strnlen+0x13>
		n++;
  80093b:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80093e:	39 d0                	cmp    %edx,%eax
  800940:	74 06                	je     800948 <strnlen+0x1d>
  800942:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800946:	75 f3                	jne    80093b <strnlen+0x10>
	return n;
}
  800948:	5d                   	pop    %ebp
  800949:	c3                   	ret    

0080094a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	53                   	push   %ebx
  80094e:	8b 45 08             	mov    0x8(%ebp),%eax
  800951:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800954:	89 c2                	mov    %eax,%edx
  800956:	83 c1 01             	add    $0x1,%ecx
  800959:	83 c2 01             	add    $0x1,%edx
  80095c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800960:	88 5a ff             	mov    %bl,-0x1(%edx)
  800963:	84 db                	test   %bl,%bl
  800965:	75 ef                	jne    800956 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800967:	5b                   	pop    %ebx
  800968:	5d                   	pop    %ebp
  800969:	c3                   	ret    

0080096a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	53                   	push   %ebx
  80096e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800971:	53                   	push   %ebx
  800972:	e8 9c ff ff ff       	call   800913 <strlen>
  800977:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80097a:	ff 75 0c             	pushl  0xc(%ebp)
  80097d:	01 d8                	add    %ebx,%eax
  80097f:	50                   	push   %eax
  800980:	e8 c5 ff ff ff       	call   80094a <strcpy>
	return dst;
}
  800985:	89 d8                	mov    %ebx,%eax
  800987:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80098a:	c9                   	leave  
  80098b:	c3                   	ret    

0080098c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
  80098f:	56                   	push   %esi
  800990:	53                   	push   %ebx
  800991:	8b 75 08             	mov    0x8(%ebp),%esi
  800994:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800997:	89 f3                	mov    %esi,%ebx
  800999:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80099c:	89 f2                	mov    %esi,%edx
  80099e:	eb 0f                	jmp    8009af <strncpy+0x23>
		*dst++ = *src;
  8009a0:	83 c2 01             	add    $0x1,%edx
  8009a3:	0f b6 01             	movzbl (%ecx),%eax
  8009a6:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009a9:	80 39 01             	cmpb   $0x1,(%ecx)
  8009ac:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8009af:	39 da                	cmp    %ebx,%edx
  8009b1:	75 ed                	jne    8009a0 <strncpy+0x14>
	}
	return ret;
}
  8009b3:	89 f0                	mov    %esi,%eax
  8009b5:	5b                   	pop    %ebx
  8009b6:	5e                   	pop    %esi
  8009b7:	5d                   	pop    %ebp
  8009b8:	c3                   	ret    

008009b9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	56                   	push   %esi
  8009bd:	53                   	push   %ebx
  8009be:	8b 75 08             	mov    0x8(%ebp),%esi
  8009c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8009c7:	89 f0                	mov    %esi,%eax
  8009c9:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009cd:	85 c9                	test   %ecx,%ecx
  8009cf:	75 0b                	jne    8009dc <strlcpy+0x23>
  8009d1:	eb 17                	jmp    8009ea <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009d3:	83 c2 01             	add    $0x1,%edx
  8009d6:	83 c0 01             	add    $0x1,%eax
  8009d9:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8009dc:	39 d8                	cmp    %ebx,%eax
  8009de:	74 07                	je     8009e7 <strlcpy+0x2e>
  8009e0:	0f b6 0a             	movzbl (%edx),%ecx
  8009e3:	84 c9                	test   %cl,%cl
  8009e5:	75 ec                	jne    8009d3 <strlcpy+0x1a>
		*dst = '\0';
  8009e7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009ea:	29 f0                	sub    %esi,%eax
}
  8009ec:	5b                   	pop    %ebx
  8009ed:	5e                   	pop    %esi
  8009ee:	5d                   	pop    %ebp
  8009ef:	c3                   	ret    

008009f0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009f0:	55                   	push   %ebp
  8009f1:	89 e5                	mov    %esp,%ebp
  8009f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009f9:	eb 06                	jmp    800a01 <strcmp+0x11>
		p++, q++;
  8009fb:	83 c1 01             	add    $0x1,%ecx
  8009fe:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800a01:	0f b6 01             	movzbl (%ecx),%eax
  800a04:	84 c0                	test   %al,%al
  800a06:	74 04                	je     800a0c <strcmp+0x1c>
  800a08:	3a 02                	cmp    (%edx),%al
  800a0a:	74 ef                	je     8009fb <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a0c:	0f b6 c0             	movzbl %al,%eax
  800a0f:	0f b6 12             	movzbl (%edx),%edx
  800a12:	29 d0                	sub    %edx,%eax
}
  800a14:	5d                   	pop    %ebp
  800a15:	c3                   	ret    

00800a16 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a16:	55                   	push   %ebp
  800a17:	89 e5                	mov    %esp,%ebp
  800a19:	53                   	push   %ebx
  800a1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a20:	89 c3                	mov    %eax,%ebx
  800a22:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a25:	eb 06                	jmp    800a2d <strncmp+0x17>
		n--, p++, q++;
  800a27:	83 c0 01             	add    $0x1,%eax
  800a2a:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a2d:	39 d8                	cmp    %ebx,%eax
  800a2f:	74 16                	je     800a47 <strncmp+0x31>
  800a31:	0f b6 08             	movzbl (%eax),%ecx
  800a34:	84 c9                	test   %cl,%cl
  800a36:	74 04                	je     800a3c <strncmp+0x26>
  800a38:	3a 0a                	cmp    (%edx),%cl
  800a3a:	74 eb                	je     800a27 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a3c:	0f b6 00             	movzbl (%eax),%eax
  800a3f:	0f b6 12             	movzbl (%edx),%edx
  800a42:	29 d0                	sub    %edx,%eax
}
  800a44:	5b                   	pop    %ebx
  800a45:	5d                   	pop    %ebp
  800a46:	c3                   	ret    
		return 0;
  800a47:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4c:	eb f6                	jmp    800a44 <strncmp+0x2e>

00800a4e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a4e:	55                   	push   %ebp
  800a4f:	89 e5                	mov    %esp,%ebp
  800a51:	8b 45 08             	mov    0x8(%ebp),%eax
  800a54:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a58:	0f b6 10             	movzbl (%eax),%edx
  800a5b:	84 d2                	test   %dl,%dl
  800a5d:	74 09                	je     800a68 <strchr+0x1a>
		if (*s == c)
  800a5f:	38 ca                	cmp    %cl,%dl
  800a61:	74 0a                	je     800a6d <strchr+0x1f>
	for (; *s; s++)
  800a63:	83 c0 01             	add    $0x1,%eax
  800a66:	eb f0                	jmp    800a58 <strchr+0xa>
			return (char *) s;
	return 0;
  800a68:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a6d:	5d                   	pop    %ebp
  800a6e:	c3                   	ret    

00800a6f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a6f:	55                   	push   %ebp
  800a70:	89 e5                	mov    %esp,%ebp
  800a72:	8b 45 08             	mov    0x8(%ebp),%eax
  800a75:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a79:	eb 03                	jmp    800a7e <strfind+0xf>
  800a7b:	83 c0 01             	add    $0x1,%eax
  800a7e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a81:	38 ca                	cmp    %cl,%dl
  800a83:	74 04                	je     800a89 <strfind+0x1a>
  800a85:	84 d2                	test   %dl,%dl
  800a87:	75 f2                	jne    800a7b <strfind+0xc>
			break;
	return (char *) s;
}
  800a89:	5d                   	pop    %ebp
  800a8a:	c3                   	ret    

00800a8b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	57                   	push   %edi
  800a8f:	56                   	push   %esi
  800a90:	53                   	push   %ebx
  800a91:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a94:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a97:	85 c9                	test   %ecx,%ecx
  800a99:	74 13                	je     800aae <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a9b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aa1:	75 05                	jne    800aa8 <memset+0x1d>
  800aa3:	f6 c1 03             	test   $0x3,%cl
  800aa6:	74 0d                	je     800ab5 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800aa8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aab:	fc                   	cld    
  800aac:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800aae:	89 f8                	mov    %edi,%eax
  800ab0:	5b                   	pop    %ebx
  800ab1:	5e                   	pop    %esi
  800ab2:	5f                   	pop    %edi
  800ab3:	5d                   	pop    %ebp
  800ab4:	c3                   	ret    
		c &= 0xFF;
  800ab5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ab9:	89 d3                	mov    %edx,%ebx
  800abb:	c1 e3 08             	shl    $0x8,%ebx
  800abe:	89 d0                	mov    %edx,%eax
  800ac0:	c1 e0 18             	shl    $0x18,%eax
  800ac3:	89 d6                	mov    %edx,%esi
  800ac5:	c1 e6 10             	shl    $0x10,%esi
  800ac8:	09 f0                	or     %esi,%eax
  800aca:	09 c2                	or     %eax,%edx
  800acc:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800ace:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800ad1:	89 d0                	mov    %edx,%eax
  800ad3:	fc                   	cld    
  800ad4:	f3 ab                	rep stos %eax,%es:(%edi)
  800ad6:	eb d6                	jmp    800aae <memset+0x23>

00800ad8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	57                   	push   %edi
  800adc:	56                   	push   %esi
  800add:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ae6:	39 c6                	cmp    %eax,%esi
  800ae8:	73 35                	jae    800b1f <memmove+0x47>
  800aea:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aed:	39 c2                	cmp    %eax,%edx
  800aef:	76 2e                	jbe    800b1f <memmove+0x47>
		s += n;
		d += n;
  800af1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800af4:	89 d6                	mov    %edx,%esi
  800af6:	09 fe                	or     %edi,%esi
  800af8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800afe:	74 0c                	je     800b0c <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b00:	83 ef 01             	sub    $0x1,%edi
  800b03:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b06:	fd                   	std    
  800b07:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b09:	fc                   	cld    
  800b0a:	eb 21                	jmp    800b2d <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b0c:	f6 c1 03             	test   $0x3,%cl
  800b0f:	75 ef                	jne    800b00 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b11:	83 ef 04             	sub    $0x4,%edi
  800b14:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b17:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b1a:	fd                   	std    
  800b1b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b1d:	eb ea                	jmp    800b09 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b1f:	89 f2                	mov    %esi,%edx
  800b21:	09 c2                	or     %eax,%edx
  800b23:	f6 c2 03             	test   $0x3,%dl
  800b26:	74 09                	je     800b31 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b28:	89 c7                	mov    %eax,%edi
  800b2a:	fc                   	cld    
  800b2b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b2d:	5e                   	pop    %esi
  800b2e:	5f                   	pop    %edi
  800b2f:	5d                   	pop    %ebp
  800b30:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b31:	f6 c1 03             	test   $0x3,%cl
  800b34:	75 f2                	jne    800b28 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b36:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b39:	89 c7                	mov    %eax,%edi
  800b3b:	fc                   	cld    
  800b3c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b3e:	eb ed                	jmp    800b2d <memmove+0x55>

00800b40 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b43:	ff 75 10             	pushl  0x10(%ebp)
  800b46:	ff 75 0c             	pushl  0xc(%ebp)
  800b49:	ff 75 08             	pushl  0x8(%ebp)
  800b4c:	e8 87 ff ff ff       	call   800ad8 <memmove>
}
  800b51:	c9                   	leave  
  800b52:	c3                   	ret    

00800b53 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b53:	55                   	push   %ebp
  800b54:	89 e5                	mov    %esp,%ebp
  800b56:	56                   	push   %esi
  800b57:	53                   	push   %ebx
  800b58:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b5e:	89 c6                	mov    %eax,%esi
  800b60:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b63:	39 f0                	cmp    %esi,%eax
  800b65:	74 1c                	je     800b83 <memcmp+0x30>
		if (*s1 != *s2)
  800b67:	0f b6 08             	movzbl (%eax),%ecx
  800b6a:	0f b6 1a             	movzbl (%edx),%ebx
  800b6d:	38 d9                	cmp    %bl,%cl
  800b6f:	75 08                	jne    800b79 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b71:	83 c0 01             	add    $0x1,%eax
  800b74:	83 c2 01             	add    $0x1,%edx
  800b77:	eb ea                	jmp    800b63 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b79:	0f b6 c1             	movzbl %cl,%eax
  800b7c:	0f b6 db             	movzbl %bl,%ebx
  800b7f:	29 d8                	sub    %ebx,%eax
  800b81:	eb 05                	jmp    800b88 <memcmp+0x35>
	}

	return 0;
  800b83:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b88:	5b                   	pop    %ebx
  800b89:	5e                   	pop    %esi
  800b8a:	5d                   	pop    %ebp
  800b8b:	c3                   	ret    

00800b8c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b8c:	55                   	push   %ebp
  800b8d:	89 e5                	mov    %esp,%ebp
  800b8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b95:	89 c2                	mov    %eax,%edx
  800b97:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b9a:	39 d0                	cmp    %edx,%eax
  800b9c:	73 09                	jae    800ba7 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b9e:	38 08                	cmp    %cl,(%eax)
  800ba0:	74 05                	je     800ba7 <memfind+0x1b>
	for (; s < ends; s++)
  800ba2:	83 c0 01             	add    $0x1,%eax
  800ba5:	eb f3                	jmp    800b9a <memfind+0xe>
			break;
	return (void *) s;
}
  800ba7:	5d                   	pop    %ebp
  800ba8:	c3                   	ret    

00800ba9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ba9:	55                   	push   %ebp
  800baa:	89 e5                	mov    %esp,%ebp
  800bac:	57                   	push   %edi
  800bad:	56                   	push   %esi
  800bae:	53                   	push   %ebx
  800baf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bb2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bb5:	eb 03                	jmp    800bba <strtol+0x11>
		s++;
  800bb7:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800bba:	0f b6 01             	movzbl (%ecx),%eax
  800bbd:	3c 20                	cmp    $0x20,%al
  800bbf:	74 f6                	je     800bb7 <strtol+0xe>
  800bc1:	3c 09                	cmp    $0x9,%al
  800bc3:	74 f2                	je     800bb7 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800bc5:	3c 2b                	cmp    $0x2b,%al
  800bc7:	74 2e                	je     800bf7 <strtol+0x4e>
	int neg = 0;
  800bc9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800bce:	3c 2d                	cmp    $0x2d,%al
  800bd0:	74 2f                	je     800c01 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bd2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bd8:	75 05                	jne    800bdf <strtol+0x36>
  800bda:	80 39 30             	cmpb   $0x30,(%ecx)
  800bdd:	74 2c                	je     800c0b <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bdf:	85 db                	test   %ebx,%ebx
  800be1:	75 0a                	jne    800bed <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800be3:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800be8:	80 39 30             	cmpb   $0x30,(%ecx)
  800beb:	74 28                	je     800c15 <strtol+0x6c>
		base = 10;
  800bed:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf2:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bf5:	eb 50                	jmp    800c47 <strtol+0x9e>
		s++;
  800bf7:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800bfa:	bf 00 00 00 00       	mov    $0x0,%edi
  800bff:	eb d1                	jmp    800bd2 <strtol+0x29>
		s++, neg = 1;
  800c01:	83 c1 01             	add    $0x1,%ecx
  800c04:	bf 01 00 00 00       	mov    $0x1,%edi
  800c09:	eb c7                	jmp    800bd2 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c0b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c0f:	74 0e                	je     800c1f <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800c11:	85 db                	test   %ebx,%ebx
  800c13:	75 d8                	jne    800bed <strtol+0x44>
		s++, base = 8;
  800c15:	83 c1 01             	add    $0x1,%ecx
  800c18:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c1d:	eb ce                	jmp    800bed <strtol+0x44>
		s += 2, base = 16;
  800c1f:	83 c1 02             	add    $0x2,%ecx
  800c22:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c27:	eb c4                	jmp    800bed <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800c29:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c2c:	89 f3                	mov    %esi,%ebx
  800c2e:	80 fb 19             	cmp    $0x19,%bl
  800c31:	77 29                	ja     800c5c <strtol+0xb3>
			dig = *s - 'a' + 10;
  800c33:	0f be d2             	movsbl %dl,%edx
  800c36:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c39:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c3c:	7d 30                	jge    800c6e <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800c3e:	83 c1 01             	add    $0x1,%ecx
  800c41:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c45:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c47:	0f b6 11             	movzbl (%ecx),%edx
  800c4a:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c4d:	89 f3                	mov    %esi,%ebx
  800c4f:	80 fb 09             	cmp    $0x9,%bl
  800c52:	77 d5                	ja     800c29 <strtol+0x80>
			dig = *s - '0';
  800c54:	0f be d2             	movsbl %dl,%edx
  800c57:	83 ea 30             	sub    $0x30,%edx
  800c5a:	eb dd                	jmp    800c39 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800c5c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c5f:	89 f3                	mov    %esi,%ebx
  800c61:	80 fb 19             	cmp    $0x19,%bl
  800c64:	77 08                	ja     800c6e <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c66:	0f be d2             	movsbl %dl,%edx
  800c69:	83 ea 37             	sub    $0x37,%edx
  800c6c:	eb cb                	jmp    800c39 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c6e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c72:	74 05                	je     800c79 <strtol+0xd0>
		*endptr = (char *) s;
  800c74:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c77:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c79:	89 c2                	mov    %eax,%edx
  800c7b:	f7 da                	neg    %edx
  800c7d:	85 ff                	test   %edi,%edi
  800c7f:	0f 45 c2             	cmovne %edx,%eax
}
  800c82:	5b                   	pop    %ebx
  800c83:	5e                   	pop    %esi
  800c84:	5f                   	pop    %edi
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	57                   	push   %edi
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c8d:	b8 00 00 00 00       	mov    $0x0,%eax
  800c92:	8b 55 08             	mov    0x8(%ebp),%edx
  800c95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c98:	89 c3                	mov    %eax,%ebx
  800c9a:	89 c7                	mov    %eax,%edi
  800c9c:	89 c6                	mov    %eax,%esi
  800c9e:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ca0:	5b                   	pop    %ebx
  800ca1:	5e                   	pop    %esi
  800ca2:	5f                   	pop    %edi
  800ca3:	5d                   	pop    %ebp
  800ca4:	c3                   	ret    

00800ca5 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	57                   	push   %edi
  800ca9:	56                   	push   %esi
  800caa:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cab:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb0:	b8 01 00 00 00       	mov    $0x1,%eax
  800cb5:	89 d1                	mov    %edx,%ecx
  800cb7:	89 d3                	mov    %edx,%ebx
  800cb9:	89 d7                	mov    %edx,%edi
  800cbb:	89 d6                	mov    %edx,%esi
  800cbd:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cbf:	5b                   	pop    %ebx
  800cc0:	5e                   	pop    %esi
  800cc1:	5f                   	pop    %edi
  800cc2:	5d                   	pop    %ebp
  800cc3:	c3                   	ret    

00800cc4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	57                   	push   %edi
  800cc8:	56                   	push   %esi
  800cc9:	53                   	push   %ebx
  800cca:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ccd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd5:	b8 03 00 00 00       	mov    $0x3,%eax
  800cda:	89 cb                	mov    %ecx,%ebx
  800cdc:	89 cf                	mov    %ecx,%edi
  800cde:	89 ce                	mov    %ecx,%esi
  800ce0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ce2:	85 c0                	test   %eax,%eax
  800ce4:	7f 08                	jg     800cee <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ce6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce9:	5b                   	pop    %ebx
  800cea:	5e                   	pop    %esi
  800ceb:	5f                   	pop    %edi
  800cec:	5d                   	pop    %ebp
  800ced:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cee:	83 ec 0c             	sub    $0xc,%esp
  800cf1:	50                   	push   %eax
  800cf2:	6a 03                	push   $0x3
  800cf4:	68 1f 27 80 00       	push   $0x80271f
  800cf9:	6a 23                	push   $0x23
  800cfb:	68 3c 27 80 00       	push   $0x80273c
  800d00:	e8 4b f5 ff ff       	call   800250 <_panic>

00800d05 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d05:	55                   	push   %ebp
  800d06:	89 e5                	mov    %esp,%ebp
  800d08:	57                   	push   %edi
  800d09:	56                   	push   %esi
  800d0a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d0b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d10:	b8 02 00 00 00       	mov    $0x2,%eax
  800d15:	89 d1                	mov    %edx,%ecx
  800d17:	89 d3                	mov    %edx,%ebx
  800d19:	89 d7                	mov    %edx,%edi
  800d1b:	89 d6                	mov    %edx,%esi
  800d1d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d1f:	5b                   	pop    %ebx
  800d20:	5e                   	pop    %esi
  800d21:	5f                   	pop    %edi
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    

00800d24 <sys_yield>:

void
sys_yield(void)
{
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	57                   	push   %edi
  800d28:	56                   	push   %esi
  800d29:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d2f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d34:	89 d1                	mov    %edx,%ecx
  800d36:	89 d3                	mov    %edx,%ebx
  800d38:	89 d7                	mov    %edx,%edi
  800d3a:	89 d6                	mov    %edx,%esi
  800d3c:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d3e:	5b                   	pop    %ebx
  800d3f:	5e                   	pop    %esi
  800d40:	5f                   	pop    %edi
  800d41:	5d                   	pop    %ebp
  800d42:	c3                   	ret    

00800d43 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d43:	55                   	push   %ebp
  800d44:	89 e5                	mov    %esp,%ebp
  800d46:	57                   	push   %edi
  800d47:	56                   	push   %esi
  800d48:	53                   	push   %ebx
  800d49:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d4c:	be 00 00 00 00       	mov    $0x0,%esi
  800d51:	8b 55 08             	mov    0x8(%ebp),%edx
  800d54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d57:	b8 04 00 00 00       	mov    $0x4,%eax
  800d5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d5f:	89 f7                	mov    %esi,%edi
  800d61:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d63:	85 c0                	test   %eax,%eax
  800d65:	7f 08                	jg     800d6f <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
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
  800d73:	6a 04                	push   $0x4
  800d75:	68 1f 27 80 00       	push   $0x80271f
  800d7a:	6a 23                	push   $0x23
  800d7c:	68 3c 27 80 00       	push   $0x80273c
  800d81:	e8 ca f4 ff ff       	call   800250 <_panic>

00800d86 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d86:	55                   	push   %ebp
  800d87:	89 e5                	mov    %esp,%ebp
  800d89:	57                   	push   %edi
  800d8a:	56                   	push   %esi
  800d8b:	53                   	push   %ebx
  800d8c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d95:	b8 05 00 00 00       	mov    $0x5,%eax
  800d9a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d9d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800da0:	8b 75 18             	mov    0x18(%ebp),%esi
  800da3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800da5:	85 c0                	test   %eax,%eax
  800da7:	7f 08                	jg     800db1 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
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
  800db5:	6a 05                	push   $0x5
  800db7:	68 1f 27 80 00       	push   $0x80271f
  800dbc:	6a 23                	push   $0x23
  800dbe:	68 3c 27 80 00       	push   $0x80273c
  800dc3:	e8 88 f4 ff ff       	call   800250 <_panic>

00800dc8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	57                   	push   %edi
  800dcc:	56                   	push   %esi
  800dcd:	53                   	push   %ebx
  800dce:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dd1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ddc:	b8 06 00 00 00       	mov    $0x6,%eax
  800de1:	89 df                	mov    %ebx,%edi
  800de3:	89 de                	mov    %ebx,%esi
  800de5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800de7:	85 c0                	test   %eax,%eax
  800de9:	7f 08                	jg     800df3 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800deb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dee:	5b                   	pop    %ebx
  800def:	5e                   	pop    %esi
  800df0:	5f                   	pop    %edi
  800df1:	5d                   	pop    %ebp
  800df2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800df3:	83 ec 0c             	sub    $0xc,%esp
  800df6:	50                   	push   %eax
  800df7:	6a 06                	push   $0x6
  800df9:	68 1f 27 80 00       	push   $0x80271f
  800dfe:	6a 23                	push   $0x23
  800e00:	68 3c 27 80 00       	push   $0x80273c
  800e05:	e8 46 f4 ff ff       	call   800250 <_panic>

00800e0a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	57                   	push   %edi
  800e0e:	56                   	push   %esi
  800e0f:	53                   	push   %ebx
  800e10:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e13:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e18:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1e:	b8 08 00 00 00       	mov    $0x8,%eax
  800e23:	89 df                	mov    %ebx,%edi
  800e25:	89 de                	mov    %ebx,%esi
  800e27:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e29:	85 c0                	test   %eax,%eax
  800e2b:	7f 08                	jg     800e35 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e30:	5b                   	pop    %ebx
  800e31:	5e                   	pop    %esi
  800e32:	5f                   	pop    %edi
  800e33:	5d                   	pop    %ebp
  800e34:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e35:	83 ec 0c             	sub    $0xc,%esp
  800e38:	50                   	push   %eax
  800e39:	6a 08                	push   $0x8
  800e3b:	68 1f 27 80 00       	push   $0x80271f
  800e40:	6a 23                	push   $0x23
  800e42:	68 3c 27 80 00       	push   $0x80273c
  800e47:	e8 04 f4 ff ff       	call   800250 <_panic>

00800e4c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	57                   	push   %edi
  800e50:	56                   	push   %esi
  800e51:	53                   	push   %ebx
  800e52:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e55:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e60:	b8 09 00 00 00       	mov    $0x9,%eax
  800e65:	89 df                	mov    %ebx,%edi
  800e67:	89 de                	mov    %ebx,%esi
  800e69:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e6b:	85 c0                	test   %eax,%eax
  800e6d:	7f 08                	jg     800e77 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e72:	5b                   	pop    %ebx
  800e73:	5e                   	pop    %esi
  800e74:	5f                   	pop    %edi
  800e75:	5d                   	pop    %ebp
  800e76:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e77:	83 ec 0c             	sub    $0xc,%esp
  800e7a:	50                   	push   %eax
  800e7b:	6a 09                	push   $0x9
  800e7d:	68 1f 27 80 00       	push   $0x80271f
  800e82:	6a 23                	push   $0x23
  800e84:	68 3c 27 80 00       	push   $0x80273c
  800e89:	e8 c2 f3 ff ff       	call   800250 <_panic>

00800e8e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e8e:	55                   	push   %ebp
  800e8f:	89 e5                	mov    %esp,%ebp
  800e91:	57                   	push   %edi
  800e92:	56                   	push   %esi
  800e93:	53                   	push   %ebx
  800e94:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e97:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ea7:	89 df                	mov    %ebx,%edi
  800ea9:	89 de                	mov    %ebx,%esi
  800eab:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ead:	85 c0                	test   %eax,%eax
  800eaf:	7f 08                	jg     800eb9 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800eb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eb4:	5b                   	pop    %ebx
  800eb5:	5e                   	pop    %esi
  800eb6:	5f                   	pop    %edi
  800eb7:	5d                   	pop    %ebp
  800eb8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb9:	83 ec 0c             	sub    $0xc,%esp
  800ebc:	50                   	push   %eax
  800ebd:	6a 0a                	push   $0xa
  800ebf:	68 1f 27 80 00       	push   $0x80271f
  800ec4:	6a 23                	push   $0x23
  800ec6:	68 3c 27 80 00       	push   $0x80273c
  800ecb:	e8 80 f3 ff ff       	call   800250 <_panic>

00800ed0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
  800ed3:	57                   	push   %edi
  800ed4:	56                   	push   %esi
  800ed5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ed6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800edc:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ee1:	be 00 00 00 00       	mov    $0x0,%esi
  800ee6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ee9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800eec:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800eee:	5b                   	pop    %ebx
  800eef:	5e                   	pop    %esi
  800ef0:	5f                   	pop    %edi
  800ef1:	5d                   	pop    %ebp
  800ef2:	c3                   	ret    

00800ef3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ef3:	55                   	push   %ebp
  800ef4:	89 e5                	mov    %esp,%ebp
  800ef6:	57                   	push   %edi
  800ef7:	56                   	push   %esi
  800ef8:	53                   	push   %ebx
  800ef9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800efc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f01:	8b 55 08             	mov    0x8(%ebp),%edx
  800f04:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f09:	89 cb                	mov    %ecx,%ebx
  800f0b:	89 cf                	mov    %ecx,%edi
  800f0d:	89 ce                	mov    %ecx,%esi
  800f0f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f11:	85 c0                	test   %eax,%eax
  800f13:	7f 08                	jg     800f1d <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f18:	5b                   	pop    %ebx
  800f19:	5e                   	pop    %esi
  800f1a:	5f                   	pop    %edi
  800f1b:	5d                   	pop    %ebp
  800f1c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f1d:	83 ec 0c             	sub    $0xc,%esp
  800f20:	50                   	push   %eax
  800f21:	6a 0d                	push   $0xd
  800f23:	68 1f 27 80 00       	push   $0x80271f
  800f28:	6a 23                	push   $0x23
  800f2a:	68 3c 27 80 00       	push   $0x80273c
  800f2f:	e8 1c f3 ff ff       	call   800250 <_panic>

00800f34 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f34:	55                   	push   %ebp
  800f35:	89 e5                	mov    %esp,%ebp
  800f37:	56                   	push   %esi
  800f38:	53                   	push   %ebx
  800f39:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f3c:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if((err&FEC_WR)==0 || (uvpt[PGNUM(addr)]&(PTE_W|PTE_COW))==0){
  800f3e:	8b 40 04             	mov    0x4(%eax),%eax
  800f41:	83 e0 02             	and    $0x2,%eax
  800f44:	0f 84 82 00 00 00    	je     800fcc <pgfault+0x98>
  800f4a:	89 da                	mov    %ebx,%edx
  800f4c:	c1 ea 0c             	shr    $0xc,%edx
  800f4f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f56:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800f5c:	74 6e                	je     800fcc <pgfault+0x98>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        envid_t envid = sys_getenvid();
  800f5e:	e8 a2 fd ff ff       	call   800d05 <sys_getenvid>
  800f63:	89 c6                	mov    %eax,%esi
	r = sys_page_alloc(envid,(void *)PFTEMP,PTE_P|PTE_W|PTE_U);
  800f65:	83 ec 04             	sub    $0x4,%esp
  800f68:	6a 07                	push   $0x7
  800f6a:	68 00 f0 7f 00       	push   $0x7ff000
  800f6f:	50                   	push   %eax
  800f70:	e8 ce fd ff ff       	call   800d43 <sys_page_alloc>
	if(r<0) panic("pgfault:page allocation failed %e",r);
  800f75:	83 c4 10             	add    $0x10,%esp
  800f78:	85 c0                	test   %eax,%eax
  800f7a:	78 72                	js     800fee <pgfault+0xba>

	addr = ROUNDDOWN(addr,PGSIZE);
  800f7c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy((void *)PFTEMP,(const void *)addr,PGSIZE);
  800f82:	83 ec 04             	sub    $0x4,%esp
  800f85:	68 00 10 00 00       	push   $0x1000
  800f8a:	53                   	push   %ebx
  800f8b:	68 00 f0 7f 00       	push   $0x7ff000
  800f90:	e8 ab fb ff ff       	call   800b40 <memcpy>

	if(sys_page_map(envid,(void *)PFTEMP, envid,addr,PTE_P|PTE_W|PTE_U)<0)
  800f95:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f9c:	53                   	push   %ebx
  800f9d:	56                   	push   %esi
  800f9e:	68 00 f0 7f 00       	push   $0x7ff000
  800fa3:	56                   	push   %esi
  800fa4:	e8 dd fd ff ff       	call   800d86 <sys_page_map>
  800fa9:	83 c4 20             	add    $0x20,%esp
  800fac:	85 c0                	test   %eax,%eax
  800fae:	78 50                	js     801000 <pgfault+0xcc>
		panic("pgfault:page map failed\n");
	if(sys_page_unmap(envid,(void *)PFTEMP)<0)
  800fb0:	83 ec 08             	sub    $0x8,%esp
  800fb3:	68 00 f0 7f 00       	push   $0x7ff000
  800fb8:	56                   	push   %esi
  800fb9:	e8 0a fe ff ff       	call   800dc8 <sys_page_unmap>
  800fbe:	83 c4 10             	add    $0x10,%esp
  800fc1:	85 c0                	test   %eax,%eax
  800fc3:	78 4f                	js     801014 <pgfault+0xe0>
		panic("pgfault: page upmap failed\n");
       //	panic("pgfault not implemented");
}
  800fc5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fc8:	5b                   	pop    %ebx
  800fc9:	5e                   	pop    %esi
  800fca:	5d                   	pop    %ebp
  800fcb:	c3                   	ret    
		cprintf("Where is the error %d\n",err&FEC_WR);
  800fcc:	83 ec 08             	sub    $0x8,%esp
  800fcf:	50                   	push   %eax
  800fd0:	68 4a 27 80 00       	push   $0x80274a
  800fd5:	e8 51 f3 ff ff       	call   80032b <cprintf>
		panic("pgfault:invalid user trap");
  800fda:	83 c4 0c             	add    $0xc,%esp
  800fdd:	68 61 27 80 00       	push   $0x802761
  800fe2:	6a 1e                	push   $0x1e
  800fe4:	68 7b 27 80 00       	push   $0x80277b
  800fe9:	e8 62 f2 ff ff       	call   800250 <_panic>
	if(r<0) panic("pgfault:page allocation failed %e",r);
  800fee:	50                   	push   %eax
  800fef:	68 68 28 80 00       	push   $0x802868
  800ff4:	6a 29                	push   $0x29
  800ff6:	68 7b 27 80 00       	push   $0x80277b
  800ffb:	e8 50 f2 ff ff       	call   800250 <_panic>
		panic("pgfault:page map failed\n");
  801000:	83 ec 04             	sub    $0x4,%esp
  801003:	68 86 27 80 00       	push   $0x802786
  801008:	6a 2f                	push   $0x2f
  80100a:	68 7b 27 80 00       	push   $0x80277b
  80100f:	e8 3c f2 ff ff       	call   800250 <_panic>
		panic("pgfault: page upmap failed\n");
  801014:	83 ec 04             	sub    $0x4,%esp
  801017:	68 9f 27 80 00       	push   $0x80279f
  80101c:	6a 31                	push   $0x31
  80101e:	68 7b 27 80 00       	push   $0x80277b
  801023:	e8 28 f2 ff ff       	call   800250 <_panic>

00801028 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801028:	55                   	push   %ebp
  801029:	89 e5                	mov    %esp,%ebp
  80102b:	57                   	push   %edi
  80102c:	56                   	push   %esi
  80102d:	53                   	push   %ebx
  80102e:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	set_pgfault_handler(pgfault);
  801031:	68 34 0f 80 00       	push   $0x800f34
  801036:	e8 f4 0f 00 00       	call   80202f <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80103b:	b8 07 00 00 00       	mov    $0x7,%eax
  801040:	cd 30                	int    $0x30
  801042:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801045:	89 45 e0             	mov    %eax,-0x20(%ebp)
       
	envid_t envid = sys_exofork();
	uintptr_t addr;
  
	if(envid<0) panic("sys_exofork failed\n");
  801048:	83 c4 10             	add    $0x10,%esp
  80104b:	85 c0                	test   %eax,%eax
  80104d:	78 27                	js     801076 <fork+0x4e>
	if(envid==0){
	  thisenv = &envs[ENVX(sys_getenvid())];
	  return 0;
	}

	for(addr=(uintptr_t)UTEXT; addr<USTACKTOP;addr+=PGSIZE){
  80104f:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if(envid==0){
  801054:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801058:	75 5e                	jne    8010b8 <fork+0x90>
	  thisenv = &envs[ENVX(sys_getenvid())];
  80105a:	e8 a6 fc ff ff       	call   800d05 <sys_getenvid>
  80105f:	25 ff 03 00 00       	and    $0x3ff,%eax
  801064:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801067:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80106c:	a3 04 40 80 00       	mov    %eax,0x804004
	  return 0;
  801071:	e9 fc 00 00 00       	jmp    801172 <fork+0x14a>
	if(envid<0) panic("sys_exofork failed\n");
  801076:	83 ec 04             	sub    $0x4,%esp
  801079:	68 bb 27 80 00       	push   $0x8027bb
  80107e:	6a 77                	push   $0x77
  801080:	68 7b 27 80 00       	push   $0x80277b
  801085:	e8 c6 f1 ff ff       	call   800250 <_panic>
          if((r=sys_page_map(parent_envid,va,envid,va,uvpt[pn]&PTE_SYSCALL))<0)
  80108a:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801091:	83 ec 0c             	sub    $0xc,%esp
  801094:	25 07 0e 00 00       	and    $0xe07,%eax
  801099:	50                   	push   %eax
  80109a:	57                   	push   %edi
  80109b:	ff 75 e0             	pushl  -0x20(%ebp)
  80109e:	57                   	push   %edi
  80109f:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010a2:	e8 df fc ff ff       	call   800d86 <sys_page_map>
  8010a7:	83 c4 20             	add    $0x20,%esp
	for(addr=(uintptr_t)UTEXT; addr<USTACKTOP;addr+=PGSIZE){
  8010aa:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010b0:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8010b6:	74 76                	je     80112e <fork+0x106>
	   if((uvpd[PDX(addr)]&PTE_P) && uvpt[PGNUM(addr)] & PTE_P)
  8010b8:	89 d8                	mov    %ebx,%eax
  8010ba:	c1 e8 16             	shr    $0x16,%eax
  8010bd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010c4:	a8 01                	test   $0x1,%al
  8010c6:	74 e2                	je     8010aa <fork+0x82>
  8010c8:	89 de                	mov    %ebx,%esi
  8010ca:	c1 ee 0c             	shr    $0xc,%esi
  8010cd:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010d4:	a8 01                	test   $0x1,%al
  8010d6:	74 d2                	je     8010aa <fork+0x82>
        envid_t parent_envid = sys_getenvid();
  8010d8:	e8 28 fc ff ff       	call   800d05 <sys_getenvid>
  8010dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	void *va = (void *)(pn*PGSIZE);
  8010e0:	89 f7                	mov    %esi,%edi
  8010e2:	c1 e7 0c             	shl    $0xc,%edi
        if(uvpt[pn] & PTE_SHARE){
  8010e5:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010ec:	f6 c4 04             	test   $0x4,%ah
  8010ef:	75 99                	jne    80108a <fork+0x62>
	if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)){
  8010f1:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010f8:	a8 02                	test   $0x2,%al
  8010fa:	0f 85 ed 00 00 00    	jne    8011ed <fork+0x1c5>
  801100:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801107:	f6 c4 08             	test   $0x8,%ah
  80110a:	0f 85 dd 00 00 00    	jne    8011ed <fork+0x1c5>
	 if((r=sys_page_map(parent_envid,va,envid,va,perm))<0)
  801110:	83 ec 0c             	sub    $0xc,%esp
  801113:	6a 05                	push   $0x5
  801115:	57                   	push   %edi
  801116:	ff 75 e0             	pushl  -0x20(%ebp)
  801119:	57                   	push   %edi
  80111a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80111d:	e8 64 fc ff ff       	call   800d86 <sys_page_map>
  801122:	83 c4 20             	add    $0x20,%esp
  801125:	85 c0                	test   %eax,%eax
  801127:	79 81                	jns    8010aa <fork+0x82>
  801129:	e9 db 00 00 00       	jmp    801209 <fork+0x1e1>
		   duppage(envid,PGNUM(addr));
	}
        
	int r;
	if((r=sys_page_alloc(envid,(void *)UXSTACKTOP-PGSIZE,PTE_U|PTE_P|PTE_W))<0)
  80112e:	83 ec 04             	sub    $0x4,%esp
  801131:	6a 07                	push   $0x7
  801133:	68 00 f0 bf ee       	push   $0xeebff000
  801138:	ff 75 dc             	pushl  -0x24(%ebp)
  80113b:	e8 03 fc ff ff       	call   800d43 <sys_page_alloc>
  801140:	83 c4 10             	add    $0x10,%esp
  801143:	85 c0                	test   %eax,%eax
  801145:	78 36                	js     80117d <fork+0x155>
		panic("fork:page alloc failed %e\n",r);

	extern void _pgfault_upcall();
	if((r = sys_env_set_pgfault_upcall(envid,_pgfault_upcall)))
  801147:	83 ec 08             	sub    $0x8,%esp
  80114a:	68 94 20 80 00       	push   $0x802094
  80114f:	ff 75 dc             	pushl  -0x24(%ebp)
  801152:	e8 37 fd ff ff       	call   800e8e <sys_env_set_pgfault_upcall>
  801157:	83 c4 10             	add    $0x10,%esp
  80115a:	85 c0                	test   %eax,%eax
  80115c:	75 34                	jne    801192 <fork+0x16a>
		panic("fork:set upcall failed %e\n",r);
	if((r = sys_env_set_status(envid,ENV_RUNNABLE))<0)
  80115e:	83 ec 08             	sub    $0x8,%esp
  801161:	6a 02                	push   $0x2
  801163:	ff 75 dc             	pushl  -0x24(%ebp)
  801166:	e8 9f fc ff ff       	call   800e0a <sys_env_set_status>
  80116b:	83 c4 10             	add    $0x10,%esp
  80116e:	85 c0                	test   %eax,%eax
  801170:	78 35                	js     8011a7 <fork+0x17f>
		panic("fork:set status failed %e\n",r);
	//cprintf("forkid= %d\n", envid);
	return envid;
       	
}
  801172:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801175:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801178:	5b                   	pop    %ebx
  801179:	5e                   	pop    %esi
  80117a:	5f                   	pop    %edi
  80117b:	5d                   	pop    %ebp
  80117c:	c3                   	ret    
		panic("fork:page alloc failed %e\n",r);
  80117d:	50                   	push   %eax
  80117e:	68 ff 27 80 00       	push   $0x8027ff
  801183:	68 84 00 00 00       	push   $0x84
  801188:	68 7b 27 80 00       	push   $0x80277b
  80118d:	e8 be f0 ff ff       	call   800250 <_panic>
		panic("fork:set upcall failed %e\n",r);
  801192:	50                   	push   %eax
  801193:	68 1a 28 80 00       	push   $0x80281a
  801198:	68 88 00 00 00       	push   $0x88
  80119d:	68 7b 27 80 00       	push   $0x80277b
  8011a2:	e8 a9 f0 ff ff       	call   800250 <_panic>
		panic("fork:set status failed %e\n",r);
  8011a7:	50                   	push   %eax
  8011a8:	68 35 28 80 00       	push   $0x802835
  8011ad:	68 8a 00 00 00       	push   $0x8a
  8011b2:	68 7b 27 80 00       	push   $0x80277b
  8011b7:	e8 94 f0 ff ff       	call   800250 <_panic>
		if( (r=sys_page_map(parent_envid,va,parent_envid,va,perm))<0){
  8011bc:	83 ec 0c             	sub    $0xc,%esp
  8011bf:	68 05 08 00 00       	push   $0x805
  8011c4:	57                   	push   %edi
  8011c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011c8:	50                   	push   %eax
  8011c9:	57                   	push   %edi
  8011ca:	50                   	push   %eax
  8011cb:	e8 b6 fb ff ff       	call   800d86 <sys_page_map>
  8011d0:	83 c4 20             	add    $0x20,%esp
  8011d3:	85 c0                	test   %eax,%eax
  8011d5:	0f 89 cf fe ff ff    	jns    8010aa <fork+0x82>
		 panic("duppage:map02 failed %e",r);
  8011db:	50                   	push   %eax
  8011dc:	68 e7 27 80 00       	push   $0x8027e7
  8011e1:	6a 56                	push   $0x56
  8011e3:	68 7b 27 80 00       	push   $0x80277b
  8011e8:	e8 63 f0 ff ff       	call   800250 <_panic>
	 if((r=sys_page_map(parent_envid,va,envid,va,perm))<0)
  8011ed:	83 ec 0c             	sub    $0xc,%esp
  8011f0:	68 05 08 00 00       	push   $0x805
  8011f5:	57                   	push   %edi
  8011f6:	ff 75 e0             	pushl  -0x20(%ebp)
  8011f9:	57                   	push   %edi
  8011fa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011fd:	e8 84 fb ff ff       	call   800d86 <sys_page_map>
  801202:	83 c4 20             	add    $0x20,%esp
  801205:	85 c0                	test   %eax,%eax
  801207:	79 b3                	jns    8011bc <fork+0x194>
		 panic("duppage:map01 failed %e",r);
  801209:	50                   	push   %eax
  80120a:	68 cf 27 80 00       	push   $0x8027cf
  80120f:	6a 53                	push   $0x53
  801211:	68 7b 27 80 00       	push   $0x80277b
  801216:	e8 35 f0 ff ff       	call   800250 <_panic>

0080121b <sfork>:

// Challenge!
int
sfork(void)
{
  80121b:	55                   	push   %ebp
  80121c:	89 e5                	mov    %esp,%ebp
  80121e:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801221:	68 50 28 80 00       	push   $0x802850
  801226:	68 94 00 00 00       	push   $0x94
  80122b:	68 7b 27 80 00       	push   $0x80277b
  801230:	e8 1b f0 ff ff       	call   800250 <_panic>

00801235 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801235:	55                   	push   %ebp
  801236:	89 e5                	mov    %esp,%ebp
  801238:	56                   	push   %esi
  801239:	53                   	push   %ebx
  80123a:	8b 75 08             	mov    0x8(%ebp),%esi
  80123d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801240:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        //	panic("ipc_recv not implemented");
        int r;
       	if(pg!=NULL){
  801243:	85 c0                	test   %eax,%eax
  801245:	74 3b                	je     801282 <ipc_recv+0x4d>
	  r = sys_ipc_recv(pg);
  801247:	83 ec 0c             	sub    $0xc,%esp
  80124a:	50                   	push   %eax
  80124b:	e8 a3 fc ff ff       	call   800ef3 <sys_ipc_recv>
  801250:	83 c4 10             	add    $0x10,%esp
	}else
	  r = sys_ipc_recv((void *)UTOP);
	if(r<0){
  801253:	85 c0                	test   %eax,%eax
  801255:	78 3d                	js     801294 <ipc_recv+0x5f>
	if(perm_store!=NULL){
		*perm_store = 0;
            }
        	return r;
           }else{
	     if(from_env_store!=NULL)
  801257:	85 f6                	test   %esi,%esi
  801259:	74 0a                	je     801265 <ipc_recv+0x30>
		     *from_env_store = thisenv->env_ipc_from;
  80125b:	a1 04 40 80 00       	mov    0x804004,%eax
  801260:	8b 40 74             	mov    0x74(%eax),%eax
  801263:	89 06                	mov    %eax,(%esi)
	     if(perm_store != NULL)
  801265:	85 db                	test   %ebx,%ebx
  801267:	74 0a                	je     801273 <ipc_recv+0x3e>
		     *perm_store = thisenv->env_ipc_perm;
  801269:	a1 04 40 80 00       	mov    0x804004,%eax
  80126e:	8b 40 78             	mov    0x78(%eax),%eax
  801271:	89 03                	mov    %eax,(%ebx)
	     return thisenv->env_ipc_value;
  801273:	a1 04 40 80 00       	mov    0x804004,%eax
  801278:	8b 40 70             	mov    0x70(%eax),%eax
	   }

}
  80127b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80127e:	5b                   	pop    %ebx
  80127f:	5e                   	pop    %esi
  801280:	5d                   	pop    %ebp
  801281:	c3                   	ret    
	  r = sys_ipc_recv((void *)UTOP);
  801282:	83 ec 0c             	sub    $0xc,%esp
  801285:	68 00 00 c0 ee       	push   $0xeec00000
  80128a:	e8 64 fc ff ff       	call   800ef3 <sys_ipc_recv>
  80128f:	83 c4 10             	add    $0x10,%esp
  801292:	eb bf                	jmp    801253 <ipc_recv+0x1e>
	if(from_env_store!=NULL){
  801294:	85 f6                	test   %esi,%esi
  801296:	74 06                	je     80129e <ipc_recv+0x69>
	  *from_env_store = 0;
  801298:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if(perm_store!=NULL){
  80129e:	85 db                	test   %ebx,%ebx
  8012a0:	74 d9                	je     80127b <ipc_recv+0x46>
		*perm_store = 0;
  8012a2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8012a8:	eb d1                	jmp    80127b <ipc_recv+0x46>

008012aa <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8012aa:	55                   	push   %ebp
  8012ab:	89 e5                	mov    %esp,%ebp
  8012ad:	57                   	push   %edi
  8012ae:	56                   	push   %esi
  8012af:	53                   	push   %ebx
  8012b0:	83 ec 0c             	sub    $0xc,%esp
  8012b3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012b6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012b9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if(pg==NULL) pg = (void *)UTOP;
  8012bc:	85 db                	test   %ebx,%ebx
  8012be:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8012c3:	0f 44 d8             	cmove  %eax,%ebx
	while((r=sys_ipc_try_send(to_env,val,pg,perm))<0){
  8012c6:	ff 75 14             	pushl  0x14(%ebp)
  8012c9:	53                   	push   %ebx
  8012ca:	56                   	push   %esi
  8012cb:	57                   	push   %edi
  8012cc:	e8 ff fb ff ff       	call   800ed0 <sys_ipc_try_send>
  8012d1:	83 c4 10             	add    $0x10,%esp
  8012d4:	85 c0                	test   %eax,%eax
  8012d6:	79 20                	jns    8012f8 <ipc_send+0x4e>
	    if(r!=-E_IPC_NOT_RECV){
  8012d8:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8012db:	75 07                	jne    8012e4 <ipc_send+0x3a>
		    panic("ipc_send:send message failed\n");
	    }
	    sys_yield();
  8012dd:	e8 42 fa ff ff       	call   800d24 <sys_yield>
  8012e2:	eb e2                	jmp    8012c6 <ipc_send+0x1c>
		    panic("ipc_send:send message failed\n");
  8012e4:	83 ec 04             	sub    $0x4,%esp
  8012e7:	68 8a 28 80 00       	push   $0x80288a
  8012ec:	6a 43                	push   $0x43
  8012ee:	68 a8 28 80 00       	push   $0x8028a8
  8012f3:	e8 58 ef ff ff       	call   800250 <_panic>
	}

}
  8012f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012fb:	5b                   	pop    %ebx
  8012fc:	5e                   	pop    %esi
  8012fd:	5f                   	pop    %edi
  8012fe:	5d                   	pop    %ebp
  8012ff:	c3                   	ret    

00801300 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801300:	55                   	push   %ebp
  801301:	89 e5                	mov    %esp,%ebp
  801303:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801306:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80130b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80130e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801314:	8b 52 50             	mov    0x50(%edx),%edx
  801317:	39 ca                	cmp    %ecx,%edx
  801319:	74 11                	je     80132c <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  80131b:	83 c0 01             	add    $0x1,%eax
  80131e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801323:	75 e6                	jne    80130b <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801325:	b8 00 00 00 00       	mov    $0x0,%eax
  80132a:	eb 0b                	jmp    801337 <ipc_find_env+0x37>
			return envs[i].env_id;
  80132c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80132f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801334:	8b 40 48             	mov    0x48(%eax),%eax
}
  801337:	5d                   	pop    %ebp
  801338:	c3                   	ret    

00801339 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801339:	55                   	push   %ebp
  80133a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80133c:	8b 45 08             	mov    0x8(%ebp),%eax
  80133f:	05 00 00 00 30       	add    $0x30000000,%eax
  801344:	c1 e8 0c             	shr    $0xc,%eax
}
  801347:	5d                   	pop    %ebp
  801348:	c3                   	ret    

00801349 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801349:	55                   	push   %ebp
  80134a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80134c:	8b 45 08             	mov    0x8(%ebp),%eax
  80134f:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801354:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801359:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80135e:	5d                   	pop    %ebp
  80135f:	c3                   	ret    

00801360 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801360:	55                   	push   %ebp
  801361:	89 e5                	mov    %esp,%ebp
  801363:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801366:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80136b:	89 c2                	mov    %eax,%edx
  80136d:	c1 ea 16             	shr    $0x16,%edx
  801370:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801377:	f6 c2 01             	test   $0x1,%dl
  80137a:	74 2a                	je     8013a6 <fd_alloc+0x46>
  80137c:	89 c2                	mov    %eax,%edx
  80137e:	c1 ea 0c             	shr    $0xc,%edx
  801381:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801388:	f6 c2 01             	test   $0x1,%dl
  80138b:	74 19                	je     8013a6 <fd_alloc+0x46>
  80138d:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801392:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801397:	75 d2                	jne    80136b <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801399:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80139f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8013a4:	eb 07                	jmp    8013ad <fd_alloc+0x4d>
			*fd_store = fd;
  8013a6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013ad:	5d                   	pop    %ebp
  8013ae:	c3                   	ret    

008013af <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013af:	55                   	push   %ebp
  8013b0:	89 e5                	mov    %esp,%ebp
  8013b2:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013b5:	83 f8 1f             	cmp    $0x1f,%eax
  8013b8:	77 36                	ja     8013f0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013ba:	c1 e0 0c             	shl    $0xc,%eax
  8013bd:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013c2:	89 c2                	mov    %eax,%edx
  8013c4:	c1 ea 16             	shr    $0x16,%edx
  8013c7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013ce:	f6 c2 01             	test   $0x1,%dl
  8013d1:	74 24                	je     8013f7 <fd_lookup+0x48>
  8013d3:	89 c2                	mov    %eax,%edx
  8013d5:	c1 ea 0c             	shr    $0xc,%edx
  8013d8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013df:	f6 c2 01             	test   $0x1,%dl
  8013e2:	74 1a                	je     8013fe <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013e7:	89 02                	mov    %eax,(%edx)
	return 0;
  8013e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013ee:	5d                   	pop    %ebp
  8013ef:	c3                   	ret    
		return -E_INVAL;
  8013f0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013f5:	eb f7                	jmp    8013ee <fd_lookup+0x3f>
		return -E_INVAL;
  8013f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013fc:	eb f0                	jmp    8013ee <fd_lookup+0x3f>
  8013fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801403:	eb e9                	jmp    8013ee <fd_lookup+0x3f>

00801405 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801405:	55                   	push   %ebp
  801406:	89 e5                	mov    %esp,%ebp
  801408:	83 ec 08             	sub    $0x8,%esp
  80140b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80140e:	ba 34 29 80 00       	mov    $0x802934,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801413:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  801418:	39 08                	cmp    %ecx,(%eax)
  80141a:	74 33                	je     80144f <dev_lookup+0x4a>
  80141c:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  80141f:	8b 02                	mov    (%edx),%eax
  801421:	85 c0                	test   %eax,%eax
  801423:	75 f3                	jne    801418 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801425:	a1 04 40 80 00       	mov    0x804004,%eax
  80142a:	8b 40 48             	mov    0x48(%eax),%eax
  80142d:	83 ec 04             	sub    $0x4,%esp
  801430:	51                   	push   %ecx
  801431:	50                   	push   %eax
  801432:	68 b4 28 80 00       	push   $0x8028b4
  801437:	e8 ef ee ff ff       	call   80032b <cprintf>
	*dev = 0;
  80143c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80143f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801445:	83 c4 10             	add    $0x10,%esp
  801448:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80144d:	c9                   	leave  
  80144e:	c3                   	ret    
			*dev = devtab[i];
  80144f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801452:	89 01                	mov    %eax,(%ecx)
			return 0;
  801454:	b8 00 00 00 00       	mov    $0x0,%eax
  801459:	eb f2                	jmp    80144d <dev_lookup+0x48>

0080145b <fd_close>:
{
  80145b:	55                   	push   %ebp
  80145c:	89 e5                	mov    %esp,%ebp
  80145e:	57                   	push   %edi
  80145f:	56                   	push   %esi
  801460:	53                   	push   %ebx
  801461:	83 ec 1c             	sub    $0x1c,%esp
  801464:	8b 75 08             	mov    0x8(%ebp),%esi
  801467:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80146a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80146d:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80146e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801474:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801477:	50                   	push   %eax
  801478:	e8 32 ff ff ff       	call   8013af <fd_lookup>
  80147d:	89 c3                	mov    %eax,%ebx
  80147f:	83 c4 08             	add    $0x8,%esp
  801482:	85 c0                	test   %eax,%eax
  801484:	78 05                	js     80148b <fd_close+0x30>
	    || fd != fd2)
  801486:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801489:	74 16                	je     8014a1 <fd_close+0x46>
		return (must_exist ? r : 0);
  80148b:	89 f8                	mov    %edi,%eax
  80148d:	84 c0                	test   %al,%al
  80148f:	b8 00 00 00 00       	mov    $0x0,%eax
  801494:	0f 44 d8             	cmove  %eax,%ebx
}
  801497:	89 d8                	mov    %ebx,%eax
  801499:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80149c:	5b                   	pop    %ebx
  80149d:	5e                   	pop    %esi
  80149e:	5f                   	pop    %edi
  80149f:	5d                   	pop    %ebp
  8014a0:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014a1:	83 ec 08             	sub    $0x8,%esp
  8014a4:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8014a7:	50                   	push   %eax
  8014a8:	ff 36                	pushl  (%esi)
  8014aa:	e8 56 ff ff ff       	call   801405 <dev_lookup>
  8014af:	89 c3                	mov    %eax,%ebx
  8014b1:	83 c4 10             	add    $0x10,%esp
  8014b4:	85 c0                	test   %eax,%eax
  8014b6:	78 15                	js     8014cd <fd_close+0x72>
		if (dev->dev_close)
  8014b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8014bb:	8b 40 10             	mov    0x10(%eax),%eax
  8014be:	85 c0                	test   %eax,%eax
  8014c0:	74 1b                	je     8014dd <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  8014c2:	83 ec 0c             	sub    $0xc,%esp
  8014c5:	56                   	push   %esi
  8014c6:	ff d0                	call   *%eax
  8014c8:	89 c3                	mov    %eax,%ebx
  8014ca:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8014cd:	83 ec 08             	sub    $0x8,%esp
  8014d0:	56                   	push   %esi
  8014d1:	6a 00                	push   $0x0
  8014d3:	e8 f0 f8 ff ff       	call   800dc8 <sys_page_unmap>
	return r;
  8014d8:	83 c4 10             	add    $0x10,%esp
  8014db:	eb ba                	jmp    801497 <fd_close+0x3c>
			r = 0;
  8014dd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014e2:	eb e9                	jmp    8014cd <fd_close+0x72>

008014e4 <close>:

int
close(int fdnum)
{
  8014e4:	55                   	push   %ebp
  8014e5:	89 e5                	mov    %esp,%ebp
  8014e7:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ed:	50                   	push   %eax
  8014ee:	ff 75 08             	pushl  0x8(%ebp)
  8014f1:	e8 b9 fe ff ff       	call   8013af <fd_lookup>
  8014f6:	83 c4 08             	add    $0x8,%esp
  8014f9:	85 c0                	test   %eax,%eax
  8014fb:	78 10                	js     80150d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8014fd:	83 ec 08             	sub    $0x8,%esp
  801500:	6a 01                	push   $0x1
  801502:	ff 75 f4             	pushl  -0xc(%ebp)
  801505:	e8 51 ff ff ff       	call   80145b <fd_close>
  80150a:	83 c4 10             	add    $0x10,%esp
}
  80150d:	c9                   	leave  
  80150e:	c3                   	ret    

0080150f <close_all>:

void
close_all(void)
{
  80150f:	55                   	push   %ebp
  801510:	89 e5                	mov    %esp,%ebp
  801512:	53                   	push   %ebx
  801513:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801516:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80151b:	83 ec 0c             	sub    $0xc,%esp
  80151e:	53                   	push   %ebx
  80151f:	e8 c0 ff ff ff       	call   8014e4 <close>
	for (i = 0; i < MAXFD; i++)
  801524:	83 c3 01             	add    $0x1,%ebx
  801527:	83 c4 10             	add    $0x10,%esp
  80152a:	83 fb 20             	cmp    $0x20,%ebx
  80152d:	75 ec                	jne    80151b <close_all+0xc>
}
  80152f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801532:	c9                   	leave  
  801533:	c3                   	ret    

00801534 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801534:	55                   	push   %ebp
  801535:	89 e5                	mov    %esp,%ebp
  801537:	57                   	push   %edi
  801538:	56                   	push   %esi
  801539:	53                   	push   %ebx
  80153a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80153d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801540:	50                   	push   %eax
  801541:	ff 75 08             	pushl  0x8(%ebp)
  801544:	e8 66 fe ff ff       	call   8013af <fd_lookup>
  801549:	89 c3                	mov    %eax,%ebx
  80154b:	83 c4 08             	add    $0x8,%esp
  80154e:	85 c0                	test   %eax,%eax
  801550:	0f 88 81 00 00 00    	js     8015d7 <dup+0xa3>
		return r;
	close(newfdnum);
  801556:	83 ec 0c             	sub    $0xc,%esp
  801559:	ff 75 0c             	pushl  0xc(%ebp)
  80155c:	e8 83 ff ff ff       	call   8014e4 <close>

	newfd = INDEX2FD(newfdnum);
  801561:	8b 75 0c             	mov    0xc(%ebp),%esi
  801564:	c1 e6 0c             	shl    $0xc,%esi
  801567:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80156d:	83 c4 04             	add    $0x4,%esp
  801570:	ff 75 e4             	pushl  -0x1c(%ebp)
  801573:	e8 d1 fd ff ff       	call   801349 <fd2data>
  801578:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80157a:	89 34 24             	mov    %esi,(%esp)
  80157d:	e8 c7 fd ff ff       	call   801349 <fd2data>
  801582:	83 c4 10             	add    $0x10,%esp
  801585:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801587:	89 d8                	mov    %ebx,%eax
  801589:	c1 e8 16             	shr    $0x16,%eax
  80158c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801593:	a8 01                	test   $0x1,%al
  801595:	74 11                	je     8015a8 <dup+0x74>
  801597:	89 d8                	mov    %ebx,%eax
  801599:	c1 e8 0c             	shr    $0xc,%eax
  80159c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015a3:	f6 c2 01             	test   $0x1,%dl
  8015a6:	75 39                	jne    8015e1 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015a8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8015ab:	89 d0                	mov    %edx,%eax
  8015ad:	c1 e8 0c             	shr    $0xc,%eax
  8015b0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015b7:	83 ec 0c             	sub    $0xc,%esp
  8015ba:	25 07 0e 00 00       	and    $0xe07,%eax
  8015bf:	50                   	push   %eax
  8015c0:	56                   	push   %esi
  8015c1:	6a 00                	push   $0x0
  8015c3:	52                   	push   %edx
  8015c4:	6a 00                	push   $0x0
  8015c6:	e8 bb f7 ff ff       	call   800d86 <sys_page_map>
  8015cb:	89 c3                	mov    %eax,%ebx
  8015cd:	83 c4 20             	add    $0x20,%esp
  8015d0:	85 c0                	test   %eax,%eax
  8015d2:	78 31                	js     801605 <dup+0xd1>
		goto err;

	return newfdnum;
  8015d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8015d7:	89 d8                	mov    %ebx,%eax
  8015d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015dc:	5b                   	pop    %ebx
  8015dd:	5e                   	pop    %esi
  8015de:	5f                   	pop    %edi
  8015df:	5d                   	pop    %ebp
  8015e0:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015e1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015e8:	83 ec 0c             	sub    $0xc,%esp
  8015eb:	25 07 0e 00 00       	and    $0xe07,%eax
  8015f0:	50                   	push   %eax
  8015f1:	57                   	push   %edi
  8015f2:	6a 00                	push   $0x0
  8015f4:	53                   	push   %ebx
  8015f5:	6a 00                	push   $0x0
  8015f7:	e8 8a f7 ff ff       	call   800d86 <sys_page_map>
  8015fc:	89 c3                	mov    %eax,%ebx
  8015fe:	83 c4 20             	add    $0x20,%esp
  801601:	85 c0                	test   %eax,%eax
  801603:	79 a3                	jns    8015a8 <dup+0x74>
	sys_page_unmap(0, newfd);
  801605:	83 ec 08             	sub    $0x8,%esp
  801608:	56                   	push   %esi
  801609:	6a 00                	push   $0x0
  80160b:	e8 b8 f7 ff ff       	call   800dc8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801610:	83 c4 08             	add    $0x8,%esp
  801613:	57                   	push   %edi
  801614:	6a 00                	push   $0x0
  801616:	e8 ad f7 ff ff       	call   800dc8 <sys_page_unmap>
	return r;
  80161b:	83 c4 10             	add    $0x10,%esp
  80161e:	eb b7                	jmp    8015d7 <dup+0xa3>

00801620 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801620:	55                   	push   %ebp
  801621:	89 e5                	mov    %esp,%ebp
  801623:	53                   	push   %ebx
  801624:	83 ec 14             	sub    $0x14,%esp
  801627:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80162a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80162d:	50                   	push   %eax
  80162e:	53                   	push   %ebx
  80162f:	e8 7b fd ff ff       	call   8013af <fd_lookup>
  801634:	83 c4 08             	add    $0x8,%esp
  801637:	85 c0                	test   %eax,%eax
  801639:	78 3f                	js     80167a <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80163b:	83 ec 08             	sub    $0x8,%esp
  80163e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801641:	50                   	push   %eax
  801642:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801645:	ff 30                	pushl  (%eax)
  801647:	e8 b9 fd ff ff       	call   801405 <dev_lookup>
  80164c:	83 c4 10             	add    $0x10,%esp
  80164f:	85 c0                	test   %eax,%eax
  801651:	78 27                	js     80167a <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801653:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801656:	8b 42 08             	mov    0x8(%edx),%eax
  801659:	83 e0 03             	and    $0x3,%eax
  80165c:	83 f8 01             	cmp    $0x1,%eax
  80165f:	74 1e                	je     80167f <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801661:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801664:	8b 40 08             	mov    0x8(%eax),%eax
  801667:	85 c0                	test   %eax,%eax
  801669:	74 35                	je     8016a0 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80166b:	83 ec 04             	sub    $0x4,%esp
  80166e:	ff 75 10             	pushl  0x10(%ebp)
  801671:	ff 75 0c             	pushl  0xc(%ebp)
  801674:	52                   	push   %edx
  801675:	ff d0                	call   *%eax
  801677:	83 c4 10             	add    $0x10,%esp
}
  80167a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80167d:	c9                   	leave  
  80167e:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80167f:	a1 04 40 80 00       	mov    0x804004,%eax
  801684:	8b 40 48             	mov    0x48(%eax),%eax
  801687:	83 ec 04             	sub    $0x4,%esp
  80168a:	53                   	push   %ebx
  80168b:	50                   	push   %eax
  80168c:	68 f8 28 80 00       	push   $0x8028f8
  801691:	e8 95 ec ff ff       	call   80032b <cprintf>
		return -E_INVAL;
  801696:	83 c4 10             	add    $0x10,%esp
  801699:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80169e:	eb da                	jmp    80167a <read+0x5a>
		return -E_NOT_SUPP;
  8016a0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016a5:	eb d3                	jmp    80167a <read+0x5a>

008016a7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8016a7:	55                   	push   %ebp
  8016a8:	89 e5                	mov    %esp,%ebp
  8016aa:	57                   	push   %edi
  8016ab:	56                   	push   %esi
  8016ac:	53                   	push   %ebx
  8016ad:	83 ec 0c             	sub    $0xc,%esp
  8016b0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016b3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016b6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016bb:	39 f3                	cmp    %esi,%ebx
  8016bd:	73 25                	jae    8016e4 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016bf:	83 ec 04             	sub    $0x4,%esp
  8016c2:	89 f0                	mov    %esi,%eax
  8016c4:	29 d8                	sub    %ebx,%eax
  8016c6:	50                   	push   %eax
  8016c7:	89 d8                	mov    %ebx,%eax
  8016c9:	03 45 0c             	add    0xc(%ebp),%eax
  8016cc:	50                   	push   %eax
  8016cd:	57                   	push   %edi
  8016ce:	e8 4d ff ff ff       	call   801620 <read>
		if (m < 0)
  8016d3:	83 c4 10             	add    $0x10,%esp
  8016d6:	85 c0                	test   %eax,%eax
  8016d8:	78 08                	js     8016e2 <readn+0x3b>
			return m;
		if (m == 0)
  8016da:	85 c0                	test   %eax,%eax
  8016dc:	74 06                	je     8016e4 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  8016de:	01 c3                	add    %eax,%ebx
  8016e0:	eb d9                	jmp    8016bb <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016e2:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8016e4:	89 d8                	mov    %ebx,%eax
  8016e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016e9:	5b                   	pop    %ebx
  8016ea:	5e                   	pop    %esi
  8016eb:	5f                   	pop    %edi
  8016ec:	5d                   	pop    %ebp
  8016ed:	c3                   	ret    

008016ee <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016ee:	55                   	push   %ebp
  8016ef:	89 e5                	mov    %esp,%ebp
  8016f1:	53                   	push   %ebx
  8016f2:	83 ec 14             	sub    $0x14,%esp
  8016f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016fb:	50                   	push   %eax
  8016fc:	53                   	push   %ebx
  8016fd:	e8 ad fc ff ff       	call   8013af <fd_lookup>
  801702:	83 c4 08             	add    $0x8,%esp
  801705:	85 c0                	test   %eax,%eax
  801707:	78 3a                	js     801743 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801709:	83 ec 08             	sub    $0x8,%esp
  80170c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80170f:	50                   	push   %eax
  801710:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801713:	ff 30                	pushl  (%eax)
  801715:	e8 eb fc ff ff       	call   801405 <dev_lookup>
  80171a:	83 c4 10             	add    $0x10,%esp
  80171d:	85 c0                	test   %eax,%eax
  80171f:	78 22                	js     801743 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801721:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801724:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801728:	74 1e                	je     801748 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80172a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80172d:	8b 52 0c             	mov    0xc(%edx),%edx
  801730:	85 d2                	test   %edx,%edx
  801732:	74 35                	je     801769 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801734:	83 ec 04             	sub    $0x4,%esp
  801737:	ff 75 10             	pushl  0x10(%ebp)
  80173a:	ff 75 0c             	pushl  0xc(%ebp)
  80173d:	50                   	push   %eax
  80173e:	ff d2                	call   *%edx
  801740:	83 c4 10             	add    $0x10,%esp
}
  801743:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801746:	c9                   	leave  
  801747:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801748:	a1 04 40 80 00       	mov    0x804004,%eax
  80174d:	8b 40 48             	mov    0x48(%eax),%eax
  801750:	83 ec 04             	sub    $0x4,%esp
  801753:	53                   	push   %ebx
  801754:	50                   	push   %eax
  801755:	68 14 29 80 00       	push   $0x802914
  80175a:	e8 cc eb ff ff       	call   80032b <cprintf>
		return -E_INVAL;
  80175f:	83 c4 10             	add    $0x10,%esp
  801762:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801767:	eb da                	jmp    801743 <write+0x55>
		return -E_NOT_SUPP;
  801769:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80176e:	eb d3                	jmp    801743 <write+0x55>

00801770 <seek>:

int
seek(int fdnum, off_t offset)
{
  801770:	55                   	push   %ebp
  801771:	89 e5                	mov    %esp,%ebp
  801773:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801776:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801779:	50                   	push   %eax
  80177a:	ff 75 08             	pushl  0x8(%ebp)
  80177d:	e8 2d fc ff ff       	call   8013af <fd_lookup>
  801782:	83 c4 08             	add    $0x8,%esp
  801785:	85 c0                	test   %eax,%eax
  801787:	78 0e                	js     801797 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801789:	8b 55 0c             	mov    0xc(%ebp),%edx
  80178c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80178f:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801792:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801797:	c9                   	leave  
  801798:	c3                   	ret    

00801799 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801799:	55                   	push   %ebp
  80179a:	89 e5                	mov    %esp,%ebp
  80179c:	53                   	push   %ebx
  80179d:	83 ec 14             	sub    $0x14,%esp
  8017a0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017a3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017a6:	50                   	push   %eax
  8017a7:	53                   	push   %ebx
  8017a8:	e8 02 fc ff ff       	call   8013af <fd_lookup>
  8017ad:	83 c4 08             	add    $0x8,%esp
  8017b0:	85 c0                	test   %eax,%eax
  8017b2:	78 37                	js     8017eb <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017b4:	83 ec 08             	sub    $0x8,%esp
  8017b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017ba:	50                   	push   %eax
  8017bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017be:	ff 30                	pushl  (%eax)
  8017c0:	e8 40 fc ff ff       	call   801405 <dev_lookup>
  8017c5:	83 c4 10             	add    $0x10,%esp
  8017c8:	85 c0                	test   %eax,%eax
  8017ca:	78 1f                	js     8017eb <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017cf:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017d3:	74 1b                	je     8017f0 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8017d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017d8:	8b 52 18             	mov    0x18(%edx),%edx
  8017db:	85 d2                	test   %edx,%edx
  8017dd:	74 32                	je     801811 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017df:	83 ec 08             	sub    $0x8,%esp
  8017e2:	ff 75 0c             	pushl  0xc(%ebp)
  8017e5:	50                   	push   %eax
  8017e6:	ff d2                	call   *%edx
  8017e8:	83 c4 10             	add    $0x10,%esp
}
  8017eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017ee:	c9                   	leave  
  8017ef:	c3                   	ret    
			thisenv->env_id, fdnum);
  8017f0:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017f5:	8b 40 48             	mov    0x48(%eax),%eax
  8017f8:	83 ec 04             	sub    $0x4,%esp
  8017fb:	53                   	push   %ebx
  8017fc:	50                   	push   %eax
  8017fd:	68 d4 28 80 00       	push   $0x8028d4
  801802:	e8 24 eb ff ff       	call   80032b <cprintf>
		return -E_INVAL;
  801807:	83 c4 10             	add    $0x10,%esp
  80180a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80180f:	eb da                	jmp    8017eb <ftruncate+0x52>
		return -E_NOT_SUPP;
  801811:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801816:	eb d3                	jmp    8017eb <ftruncate+0x52>

00801818 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801818:	55                   	push   %ebp
  801819:	89 e5                	mov    %esp,%ebp
  80181b:	53                   	push   %ebx
  80181c:	83 ec 14             	sub    $0x14,%esp
  80181f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801822:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801825:	50                   	push   %eax
  801826:	ff 75 08             	pushl  0x8(%ebp)
  801829:	e8 81 fb ff ff       	call   8013af <fd_lookup>
  80182e:	83 c4 08             	add    $0x8,%esp
  801831:	85 c0                	test   %eax,%eax
  801833:	78 4b                	js     801880 <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801835:	83 ec 08             	sub    $0x8,%esp
  801838:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80183b:	50                   	push   %eax
  80183c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80183f:	ff 30                	pushl  (%eax)
  801841:	e8 bf fb ff ff       	call   801405 <dev_lookup>
  801846:	83 c4 10             	add    $0x10,%esp
  801849:	85 c0                	test   %eax,%eax
  80184b:	78 33                	js     801880 <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  80184d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801850:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801854:	74 2f                	je     801885 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801856:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801859:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801860:	00 00 00 
	stat->st_isdir = 0;
  801863:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80186a:	00 00 00 
	stat->st_dev = dev;
  80186d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801873:	83 ec 08             	sub    $0x8,%esp
  801876:	53                   	push   %ebx
  801877:	ff 75 f0             	pushl  -0x10(%ebp)
  80187a:	ff 50 14             	call   *0x14(%eax)
  80187d:	83 c4 10             	add    $0x10,%esp
}
  801880:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801883:	c9                   	leave  
  801884:	c3                   	ret    
		return -E_NOT_SUPP;
  801885:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80188a:	eb f4                	jmp    801880 <fstat+0x68>

0080188c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80188c:	55                   	push   %ebp
  80188d:	89 e5                	mov    %esp,%ebp
  80188f:	56                   	push   %esi
  801890:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801891:	83 ec 08             	sub    $0x8,%esp
  801894:	6a 00                	push   $0x0
  801896:	ff 75 08             	pushl  0x8(%ebp)
  801899:	e8 e7 01 00 00       	call   801a85 <open>
  80189e:	89 c3                	mov    %eax,%ebx
  8018a0:	83 c4 10             	add    $0x10,%esp
  8018a3:	85 c0                	test   %eax,%eax
  8018a5:	78 1b                	js     8018c2 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8018a7:	83 ec 08             	sub    $0x8,%esp
  8018aa:	ff 75 0c             	pushl  0xc(%ebp)
  8018ad:	50                   	push   %eax
  8018ae:	e8 65 ff ff ff       	call   801818 <fstat>
  8018b3:	89 c6                	mov    %eax,%esi
	close(fd);
  8018b5:	89 1c 24             	mov    %ebx,(%esp)
  8018b8:	e8 27 fc ff ff       	call   8014e4 <close>
	return r;
  8018bd:	83 c4 10             	add    $0x10,%esp
  8018c0:	89 f3                	mov    %esi,%ebx
}
  8018c2:	89 d8                	mov    %ebx,%eax
  8018c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018c7:	5b                   	pop    %ebx
  8018c8:	5e                   	pop    %esi
  8018c9:	5d                   	pop    %ebp
  8018ca:	c3                   	ret    

008018cb <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018cb:	55                   	push   %ebp
  8018cc:	89 e5                	mov    %esp,%ebp
  8018ce:	56                   	push   %esi
  8018cf:	53                   	push   %ebx
  8018d0:	89 c6                	mov    %eax,%esi
  8018d2:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8018d4:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8018db:	74 27                	je     801904 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018dd:	6a 07                	push   $0x7
  8018df:	68 00 50 80 00       	push   $0x805000
  8018e4:	56                   	push   %esi
  8018e5:	ff 35 00 40 80 00    	pushl  0x804000
  8018eb:	e8 ba f9 ff ff       	call   8012aa <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018f0:	83 c4 0c             	add    $0xc,%esp
  8018f3:	6a 00                	push   $0x0
  8018f5:	53                   	push   %ebx
  8018f6:	6a 00                	push   $0x0
  8018f8:	e8 38 f9 ff ff       	call   801235 <ipc_recv>
}
  8018fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801900:	5b                   	pop    %ebx
  801901:	5e                   	pop    %esi
  801902:	5d                   	pop    %ebp
  801903:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801904:	83 ec 0c             	sub    $0xc,%esp
  801907:	6a 01                	push   $0x1
  801909:	e8 f2 f9 ff ff       	call   801300 <ipc_find_env>
  80190e:	a3 00 40 80 00       	mov    %eax,0x804000
  801913:	83 c4 10             	add    $0x10,%esp
  801916:	eb c5                	jmp    8018dd <fsipc+0x12>

00801918 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801918:	55                   	push   %ebp
  801919:	89 e5                	mov    %esp,%ebp
  80191b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80191e:	8b 45 08             	mov    0x8(%ebp),%eax
  801921:	8b 40 0c             	mov    0xc(%eax),%eax
  801924:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801929:	8b 45 0c             	mov    0xc(%ebp),%eax
  80192c:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801931:	ba 00 00 00 00       	mov    $0x0,%edx
  801936:	b8 02 00 00 00       	mov    $0x2,%eax
  80193b:	e8 8b ff ff ff       	call   8018cb <fsipc>
}
  801940:	c9                   	leave  
  801941:	c3                   	ret    

00801942 <devfile_flush>:
{
  801942:	55                   	push   %ebp
  801943:	89 e5                	mov    %esp,%ebp
  801945:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801948:	8b 45 08             	mov    0x8(%ebp),%eax
  80194b:	8b 40 0c             	mov    0xc(%eax),%eax
  80194e:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801953:	ba 00 00 00 00       	mov    $0x0,%edx
  801958:	b8 06 00 00 00       	mov    $0x6,%eax
  80195d:	e8 69 ff ff ff       	call   8018cb <fsipc>
}
  801962:	c9                   	leave  
  801963:	c3                   	ret    

00801964 <devfile_stat>:
{
  801964:	55                   	push   %ebp
  801965:	89 e5                	mov    %esp,%ebp
  801967:	53                   	push   %ebx
  801968:	83 ec 04             	sub    $0x4,%esp
  80196b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80196e:	8b 45 08             	mov    0x8(%ebp),%eax
  801971:	8b 40 0c             	mov    0xc(%eax),%eax
  801974:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801979:	ba 00 00 00 00       	mov    $0x0,%edx
  80197e:	b8 05 00 00 00       	mov    $0x5,%eax
  801983:	e8 43 ff ff ff       	call   8018cb <fsipc>
  801988:	85 c0                	test   %eax,%eax
  80198a:	78 2c                	js     8019b8 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80198c:	83 ec 08             	sub    $0x8,%esp
  80198f:	68 00 50 80 00       	push   $0x805000
  801994:	53                   	push   %ebx
  801995:	e8 b0 ef ff ff       	call   80094a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80199a:	a1 80 50 80 00       	mov    0x805080,%eax
  80199f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019a5:	a1 84 50 80 00       	mov    0x805084,%eax
  8019aa:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019b0:	83 c4 10             	add    $0x10,%esp
  8019b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019bb:	c9                   	leave  
  8019bc:	c3                   	ret    

008019bd <devfile_write>:
{
  8019bd:	55                   	push   %ebp
  8019be:	89 e5                	mov    %esp,%ebp
  8019c0:	83 ec 0c             	sub    $0xc,%esp
  8019c3:	8b 45 10             	mov    0x10(%ebp),%eax
  8019c6:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8019cb:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8019d0:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8019d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8019d6:	8b 52 0c             	mov    0xc(%edx),%edx
  8019d9:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8019df:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf,buf,n);
  8019e4:	50                   	push   %eax
  8019e5:	ff 75 0c             	pushl  0xc(%ebp)
  8019e8:	68 08 50 80 00       	push   $0x805008
  8019ed:	e8 e6 f0 ff ff       	call   800ad8 <memmove>
	if((r = fsipc(FSREQ_WRITE,NULL))<0)
  8019f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f7:	b8 04 00 00 00       	mov    $0x4,%eax
  8019fc:	e8 ca fe ff ff       	call   8018cb <fsipc>
}
  801a01:	c9                   	leave  
  801a02:	c3                   	ret    

00801a03 <devfile_read>:
{
  801a03:	55                   	push   %ebp
  801a04:	89 e5                	mov    %esp,%ebp
  801a06:	56                   	push   %esi
  801a07:	53                   	push   %ebx
  801a08:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a0b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0e:	8b 40 0c             	mov    0xc(%eax),%eax
  801a11:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a16:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a1c:	ba 00 00 00 00       	mov    $0x0,%edx
  801a21:	b8 03 00 00 00       	mov    $0x3,%eax
  801a26:	e8 a0 fe ff ff       	call   8018cb <fsipc>
  801a2b:	89 c3                	mov    %eax,%ebx
  801a2d:	85 c0                	test   %eax,%eax
  801a2f:	78 1f                	js     801a50 <devfile_read+0x4d>
	assert(r <= n);
  801a31:	39 f0                	cmp    %esi,%eax
  801a33:	77 24                	ja     801a59 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801a35:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a3a:	7f 33                	jg     801a6f <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a3c:	83 ec 04             	sub    $0x4,%esp
  801a3f:	50                   	push   %eax
  801a40:	68 00 50 80 00       	push   $0x805000
  801a45:	ff 75 0c             	pushl  0xc(%ebp)
  801a48:	e8 8b f0 ff ff       	call   800ad8 <memmove>
	return r;
  801a4d:	83 c4 10             	add    $0x10,%esp
}
  801a50:	89 d8                	mov    %ebx,%eax
  801a52:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a55:	5b                   	pop    %ebx
  801a56:	5e                   	pop    %esi
  801a57:	5d                   	pop    %ebp
  801a58:	c3                   	ret    
	assert(r <= n);
  801a59:	68 44 29 80 00       	push   $0x802944
  801a5e:	68 4b 29 80 00       	push   $0x80294b
  801a63:	6a 7c                	push   $0x7c
  801a65:	68 60 29 80 00       	push   $0x802960
  801a6a:	e8 e1 e7 ff ff       	call   800250 <_panic>
	assert(r <= PGSIZE);
  801a6f:	68 6b 29 80 00       	push   $0x80296b
  801a74:	68 4b 29 80 00       	push   $0x80294b
  801a79:	6a 7d                	push   $0x7d
  801a7b:	68 60 29 80 00       	push   $0x802960
  801a80:	e8 cb e7 ff ff       	call   800250 <_panic>

00801a85 <open>:
{
  801a85:	55                   	push   %ebp
  801a86:	89 e5                	mov    %esp,%ebp
  801a88:	56                   	push   %esi
  801a89:	53                   	push   %ebx
  801a8a:	83 ec 1c             	sub    $0x1c,%esp
  801a8d:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801a90:	56                   	push   %esi
  801a91:	e8 7d ee ff ff       	call   800913 <strlen>
  801a96:	83 c4 10             	add    $0x10,%esp
  801a99:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a9e:	7f 6c                	jg     801b0c <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801aa0:	83 ec 0c             	sub    $0xc,%esp
  801aa3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aa6:	50                   	push   %eax
  801aa7:	e8 b4 f8 ff ff       	call   801360 <fd_alloc>
  801aac:	89 c3                	mov    %eax,%ebx
  801aae:	83 c4 10             	add    $0x10,%esp
  801ab1:	85 c0                	test   %eax,%eax
  801ab3:	78 3c                	js     801af1 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801ab5:	83 ec 08             	sub    $0x8,%esp
  801ab8:	56                   	push   %esi
  801ab9:	68 00 50 80 00       	push   $0x805000
  801abe:	e8 87 ee ff ff       	call   80094a <strcpy>
	fsipcbuf.open.req_omode = mode;
  801ac3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ac6:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801acb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ace:	b8 01 00 00 00       	mov    $0x1,%eax
  801ad3:	e8 f3 fd ff ff       	call   8018cb <fsipc>
  801ad8:	89 c3                	mov    %eax,%ebx
  801ada:	83 c4 10             	add    $0x10,%esp
  801add:	85 c0                	test   %eax,%eax
  801adf:	78 19                	js     801afa <open+0x75>
	return fd2num(fd);
  801ae1:	83 ec 0c             	sub    $0xc,%esp
  801ae4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ae7:	e8 4d f8 ff ff       	call   801339 <fd2num>
  801aec:	89 c3                	mov    %eax,%ebx
  801aee:	83 c4 10             	add    $0x10,%esp
}
  801af1:	89 d8                	mov    %ebx,%eax
  801af3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801af6:	5b                   	pop    %ebx
  801af7:	5e                   	pop    %esi
  801af8:	5d                   	pop    %ebp
  801af9:	c3                   	ret    
		fd_close(fd, 0);
  801afa:	83 ec 08             	sub    $0x8,%esp
  801afd:	6a 00                	push   $0x0
  801aff:	ff 75 f4             	pushl  -0xc(%ebp)
  801b02:	e8 54 f9 ff ff       	call   80145b <fd_close>
		return r;
  801b07:	83 c4 10             	add    $0x10,%esp
  801b0a:	eb e5                	jmp    801af1 <open+0x6c>
		return -E_BAD_PATH;
  801b0c:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801b11:	eb de                	jmp    801af1 <open+0x6c>

00801b13 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b13:	55                   	push   %ebp
  801b14:	89 e5                	mov    %esp,%ebp
  801b16:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b19:	ba 00 00 00 00       	mov    $0x0,%edx
  801b1e:	b8 08 00 00 00       	mov    $0x8,%eax
  801b23:	e8 a3 fd ff ff       	call   8018cb <fsipc>
}
  801b28:	c9                   	leave  
  801b29:	c3                   	ret    

00801b2a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b2a:	55                   	push   %ebp
  801b2b:	89 e5                	mov    %esp,%ebp
  801b2d:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b30:	89 d0                	mov    %edx,%eax
  801b32:	c1 e8 16             	shr    $0x16,%eax
  801b35:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b3c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801b41:	f6 c1 01             	test   $0x1,%cl
  801b44:	74 1d                	je     801b63 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801b46:	c1 ea 0c             	shr    $0xc,%edx
  801b49:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b50:	f6 c2 01             	test   $0x1,%dl
  801b53:	74 0e                	je     801b63 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b55:	c1 ea 0c             	shr    $0xc,%edx
  801b58:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b5f:	ef 
  801b60:	0f b7 c0             	movzwl %ax,%eax
}
  801b63:	5d                   	pop    %ebp
  801b64:	c3                   	ret    

00801b65 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b65:	55                   	push   %ebp
  801b66:	89 e5                	mov    %esp,%ebp
  801b68:	56                   	push   %esi
  801b69:	53                   	push   %ebx
  801b6a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b6d:	83 ec 0c             	sub    $0xc,%esp
  801b70:	ff 75 08             	pushl  0x8(%ebp)
  801b73:	e8 d1 f7 ff ff       	call   801349 <fd2data>
  801b78:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b7a:	83 c4 08             	add    $0x8,%esp
  801b7d:	68 77 29 80 00       	push   $0x802977
  801b82:	53                   	push   %ebx
  801b83:	e8 c2 ed ff ff       	call   80094a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b88:	8b 46 04             	mov    0x4(%esi),%eax
  801b8b:	2b 06                	sub    (%esi),%eax
  801b8d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b93:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b9a:	00 00 00 
	stat->st_dev = &devpipe;
  801b9d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801ba4:	30 80 00 
	return 0;
}
  801ba7:	b8 00 00 00 00       	mov    $0x0,%eax
  801bac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801baf:	5b                   	pop    %ebx
  801bb0:	5e                   	pop    %esi
  801bb1:	5d                   	pop    %ebp
  801bb2:	c3                   	ret    

00801bb3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801bb3:	55                   	push   %ebp
  801bb4:	89 e5                	mov    %esp,%ebp
  801bb6:	53                   	push   %ebx
  801bb7:	83 ec 0c             	sub    $0xc,%esp
  801bba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801bbd:	53                   	push   %ebx
  801bbe:	6a 00                	push   $0x0
  801bc0:	e8 03 f2 ff ff       	call   800dc8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bc5:	89 1c 24             	mov    %ebx,(%esp)
  801bc8:	e8 7c f7 ff ff       	call   801349 <fd2data>
  801bcd:	83 c4 08             	add    $0x8,%esp
  801bd0:	50                   	push   %eax
  801bd1:	6a 00                	push   $0x0
  801bd3:	e8 f0 f1 ff ff       	call   800dc8 <sys_page_unmap>
}
  801bd8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bdb:	c9                   	leave  
  801bdc:	c3                   	ret    

00801bdd <_pipeisclosed>:
{
  801bdd:	55                   	push   %ebp
  801bde:	89 e5                	mov    %esp,%ebp
  801be0:	57                   	push   %edi
  801be1:	56                   	push   %esi
  801be2:	53                   	push   %ebx
  801be3:	83 ec 1c             	sub    $0x1c,%esp
  801be6:	89 c7                	mov    %eax,%edi
  801be8:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801bea:	a1 04 40 80 00       	mov    0x804004,%eax
  801bef:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801bf2:	83 ec 0c             	sub    $0xc,%esp
  801bf5:	57                   	push   %edi
  801bf6:	e8 2f ff ff ff       	call   801b2a <pageref>
  801bfb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801bfe:	89 34 24             	mov    %esi,(%esp)
  801c01:	e8 24 ff ff ff       	call   801b2a <pageref>
		nn = thisenv->env_runs;
  801c06:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801c0c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c0f:	83 c4 10             	add    $0x10,%esp
  801c12:	39 cb                	cmp    %ecx,%ebx
  801c14:	74 1b                	je     801c31 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801c16:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801c19:	75 cf                	jne    801bea <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c1b:	8b 42 58             	mov    0x58(%edx),%eax
  801c1e:	6a 01                	push   $0x1
  801c20:	50                   	push   %eax
  801c21:	53                   	push   %ebx
  801c22:	68 7e 29 80 00       	push   $0x80297e
  801c27:	e8 ff e6 ff ff       	call   80032b <cprintf>
  801c2c:	83 c4 10             	add    $0x10,%esp
  801c2f:	eb b9                	jmp    801bea <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801c31:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801c34:	0f 94 c0             	sete   %al
  801c37:	0f b6 c0             	movzbl %al,%eax
}
  801c3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c3d:	5b                   	pop    %ebx
  801c3e:	5e                   	pop    %esi
  801c3f:	5f                   	pop    %edi
  801c40:	5d                   	pop    %ebp
  801c41:	c3                   	ret    

00801c42 <devpipe_write>:
{
  801c42:	55                   	push   %ebp
  801c43:	89 e5                	mov    %esp,%ebp
  801c45:	57                   	push   %edi
  801c46:	56                   	push   %esi
  801c47:	53                   	push   %ebx
  801c48:	83 ec 28             	sub    $0x28,%esp
  801c4b:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801c4e:	56                   	push   %esi
  801c4f:	e8 f5 f6 ff ff       	call   801349 <fd2data>
  801c54:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c56:	83 c4 10             	add    $0x10,%esp
  801c59:	bf 00 00 00 00       	mov    $0x0,%edi
  801c5e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c61:	74 4f                	je     801cb2 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c63:	8b 43 04             	mov    0x4(%ebx),%eax
  801c66:	8b 0b                	mov    (%ebx),%ecx
  801c68:	8d 51 20             	lea    0x20(%ecx),%edx
  801c6b:	39 d0                	cmp    %edx,%eax
  801c6d:	72 14                	jb     801c83 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801c6f:	89 da                	mov    %ebx,%edx
  801c71:	89 f0                	mov    %esi,%eax
  801c73:	e8 65 ff ff ff       	call   801bdd <_pipeisclosed>
  801c78:	85 c0                	test   %eax,%eax
  801c7a:	75 3a                	jne    801cb6 <devpipe_write+0x74>
			sys_yield();
  801c7c:	e8 a3 f0 ff ff       	call   800d24 <sys_yield>
  801c81:	eb e0                	jmp    801c63 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c86:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c8a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c8d:	89 c2                	mov    %eax,%edx
  801c8f:	c1 fa 1f             	sar    $0x1f,%edx
  801c92:	89 d1                	mov    %edx,%ecx
  801c94:	c1 e9 1b             	shr    $0x1b,%ecx
  801c97:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c9a:	83 e2 1f             	and    $0x1f,%edx
  801c9d:	29 ca                	sub    %ecx,%edx
  801c9f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ca3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ca7:	83 c0 01             	add    $0x1,%eax
  801caa:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801cad:	83 c7 01             	add    $0x1,%edi
  801cb0:	eb ac                	jmp    801c5e <devpipe_write+0x1c>
	return i;
  801cb2:	89 f8                	mov    %edi,%eax
  801cb4:	eb 05                	jmp    801cbb <devpipe_write+0x79>
				return 0;
  801cb6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cbb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cbe:	5b                   	pop    %ebx
  801cbf:	5e                   	pop    %esi
  801cc0:	5f                   	pop    %edi
  801cc1:	5d                   	pop    %ebp
  801cc2:	c3                   	ret    

00801cc3 <devpipe_read>:
{
  801cc3:	55                   	push   %ebp
  801cc4:	89 e5                	mov    %esp,%ebp
  801cc6:	57                   	push   %edi
  801cc7:	56                   	push   %esi
  801cc8:	53                   	push   %ebx
  801cc9:	83 ec 18             	sub    $0x18,%esp
  801ccc:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801ccf:	57                   	push   %edi
  801cd0:	e8 74 f6 ff ff       	call   801349 <fd2data>
  801cd5:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801cd7:	83 c4 10             	add    $0x10,%esp
  801cda:	be 00 00 00 00       	mov    $0x0,%esi
  801cdf:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ce2:	74 47                	je     801d2b <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  801ce4:	8b 03                	mov    (%ebx),%eax
  801ce6:	3b 43 04             	cmp    0x4(%ebx),%eax
  801ce9:	75 22                	jne    801d0d <devpipe_read+0x4a>
			if (i > 0)
  801ceb:	85 f6                	test   %esi,%esi
  801ced:	75 14                	jne    801d03 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801cef:	89 da                	mov    %ebx,%edx
  801cf1:	89 f8                	mov    %edi,%eax
  801cf3:	e8 e5 fe ff ff       	call   801bdd <_pipeisclosed>
  801cf8:	85 c0                	test   %eax,%eax
  801cfa:	75 33                	jne    801d2f <devpipe_read+0x6c>
			sys_yield();
  801cfc:	e8 23 f0 ff ff       	call   800d24 <sys_yield>
  801d01:	eb e1                	jmp    801ce4 <devpipe_read+0x21>
				return i;
  801d03:	89 f0                	mov    %esi,%eax
}
  801d05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d08:	5b                   	pop    %ebx
  801d09:	5e                   	pop    %esi
  801d0a:	5f                   	pop    %edi
  801d0b:	5d                   	pop    %ebp
  801d0c:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d0d:	99                   	cltd   
  801d0e:	c1 ea 1b             	shr    $0x1b,%edx
  801d11:	01 d0                	add    %edx,%eax
  801d13:	83 e0 1f             	and    $0x1f,%eax
  801d16:	29 d0                	sub    %edx,%eax
  801d18:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801d1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d20:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801d23:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801d26:	83 c6 01             	add    $0x1,%esi
  801d29:	eb b4                	jmp    801cdf <devpipe_read+0x1c>
	return i;
  801d2b:	89 f0                	mov    %esi,%eax
  801d2d:	eb d6                	jmp    801d05 <devpipe_read+0x42>
				return 0;
  801d2f:	b8 00 00 00 00       	mov    $0x0,%eax
  801d34:	eb cf                	jmp    801d05 <devpipe_read+0x42>

00801d36 <pipe>:
{
  801d36:	55                   	push   %ebp
  801d37:	89 e5                	mov    %esp,%ebp
  801d39:	56                   	push   %esi
  801d3a:	53                   	push   %ebx
  801d3b:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801d3e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d41:	50                   	push   %eax
  801d42:	e8 19 f6 ff ff       	call   801360 <fd_alloc>
  801d47:	89 c3                	mov    %eax,%ebx
  801d49:	83 c4 10             	add    $0x10,%esp
  801d4c:	85 c0                	test   %eax,%eax
  801d4e:	78 5b                	js     801dab <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d50:	83 ec 04             	sub    $0x4,%esp
  801d53:	68 07 04 00 00       	push   $0x407
  801d58:	ff 75 f4             	pushl  -0xc(%ebp)
  801d5b:	6a 00                	push   $0x0
  801d5d:	e8 e1 ef ff ff       	call   800d43 <sys_page_alloc>
  801d62:	89 c3                	mov    %eax,%ebx
  801d64:	83 c4 10             	add    $0x10,%esp
  801d67:	85 c0                	test   %eax,%eax
  801d69:	78 40                	js     801dab <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  801d6b:	83 ec 0c             	sub    $0xc,%esp
  801d6e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d71:	50                   	push   %eax
  801d72:	e8 e9 f5 ff ff       	call   801360 <fd_alloc>
  801d77:	89 c3                	mov    %eax,%ebx
  801d79:	83 c4 10             	add    $0x10,%esp
  801d7c:	85 c0                	test   %eax,%eax
  801d7e:	78 1b                	js     801d9b <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d80:	83 ec 04             	sub    $0x4,%esp
  801d83:	68 07 04 00 00       	push   $0x407
  801d88:	ff 75 f0             	pushl  -0x10(%ebp)
  801d8b:	6a 00                	push   $0x0
  801d8d:	e8 b1 ef ff ff       	call   800d43 <sys_page_alloc>
  801d92:	89 c3                	mov    %eax,%ebx
  801d94:	83 c4 10             	add    $0x10,%esp
  801d97:	85 c0                	test   %eax,%eax
  801d99:	79 19                	jns    801db4 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  801d9b:	83 ec 08             	sub    $0x8,%esp
  801d9e:	ff 75 f4             	pushl  -0xc(%ebp)
  801da1:	6a 00                	push   $0x0
  801da3:	e8 20 f0 ff ff       	call   800dc8 <sys_page_unmap>
  801da8:	83 c4 10             	add    $0x10,%esp
}
  801dab:	89 d8                	mov    %ebx,%eax
  801dad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801db0:	5b                   	pop    %ebx
  801db1:	5e                   	pop    %esi
  801db2:	5d                   	pop    %ebp
  801db3:	c3                   	ret    
	va = fd2data(fd0);
  801db4:	83 ec 0c             	sub    $0xc,%esp
  801db7:	ff 75 f4             	pushl  -0xc(%ebp)
  801dba:	e8 8a f5 ff ff       	call   801349 <fd2data>
  801dbf:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dc1:	83 c4 0c             	add    $0xc,%esp
  801dc4:	68 07 04 00 00       	push   $0x407
  801dc9:	50                   	push   %eax
  801dca:	6a 00                	push   $0x0
  801dcc:	e8 72 ef ff ff       	call   800d43 <sys_page_alloc>
  801dd1:	89 c3                	mov    %eax,%ebx
  801dd3:	83 c4 10             	add    $0x10,%esp
  801dd6:	85 c0                	test   %eax,%eax
  801dd8:	0f 88 8c 00 00 00    	js     801e6a <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dde:	83 ec 0c             	sub    $0xc,%esp
  801de1:	ff 75 f0             	pushl  -0x10(%ebp)
  801de4:	e8 60 f5 ff ff       	call   801349 <fd2data>
  801de9:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801df0:	50                   	push   %eax
  801df1:	6a 00                	push   $0x0
  801df3:	56                   	push   %esi
  801df4:	6a 00                	push   $0x0
  801df6:	e8 8b ef ff ff       	call   800d86 <sys_page_map>
  801dfb:	89 c3                	mov    %eax,%ebx
  801dfd:	83 c4 20             	add    $0x20,%esp
  801e00:	85 c0                	test   %eax,%eax
  801e02:	78 58                	js     801e5c <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801e04:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e07:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e0d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e12:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801e19:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e1c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e22:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e24:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e27:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801e2e:	83 ec 0c             	sub    $0xc,%esp
  801e31:	ff 75 f4             	pushl  -0xc(%ebp)
  801e34:	e8 00 f5 ff ff       	call   801339 <fd2num>
  801e39:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e3c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e3e:	83 c4 04             	add    $0x4,%esp
  801e41:	ff 75 f0             	pushl  -0x10(%ebp)
  801e44:	e8 f0 f4 ff ff       	call   801339 <fd2num>
  801e49:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e4c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e4f:	83 c4 10             	add    $0x10,%esp
  801e52:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e57:	e9 4f ff ff ff       	jmp    801dab <pipe+0x75>
	sys_page_unmap(0, va);
  801e5c:	83 ec 08             	sub    $0x8,%esp
  801e5f:	56                   	push   %esi
  801e60:	6a 00                	push   $0x0
  801e62:	e8 61 ef ff ff       	call   800dc8 <sys_page_unmap>
  801e67:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801e6a:	83 ec 08             	sub    $0x8,%esp
  801e6d:	ff 75 f0             	pushl  -0x10(%ebp)
  801e70:	6a 00                	push   $0x0
  801e72:	e8 51 ef ff ff       	call   800dc8 <sys_page_unmap>
  801e77:	83 c4 10             	add    $0x10,%esp
  801e7a:	e9 1c ff ff ff       	jmp    801d9b <pipe+0x65>

00801e7f <pipeisclosed>:
{
  801e7f:	55                   	push   %ebp
  801e80:	89 e5                	mov    %esp,%ebp
  801e82:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e85:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e88:	50                   	push   %eax
  801e89:	ff 75 08             	pushl  0x8(%ebp)
  801e8c:	e8 1e f5 ff ff       	call   8013af <fd_lookup>
  801e91:	83 c4 10             	add    $0x10,%esp
  801e94:	85 c0                	test   %eax,%eax
  801e96:	78 18                	js     801eb0 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801e98:	83 ec 0c             	sub    $0xc,%esp
  801e9b:	ff 75 f4             	pushl  -0xc(%ebp)
  801e9e:	e8 a6 f4 ff ff       	call   801349 <fd2data>
	return _pipeisclosed(fd, p);
  801ea3:	89 c2                	mov    %eax,%edx
  801ea5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea8:	e8 30 fd ff ff       	call   801bdd <_pipeisclosed>
  801ead:	83 c4 10             	add    $0x10,%esp
}
  801eb0:	c9                   	leave  
  801eb1:	c3                   	ret    

00801eb2 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801eb2:	55                   	push   %ebp
  801eb3:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801eb5:	b8 00 00 00 00       	mov    $0x0,%eax
  801eba:	5d                   	pop    %ebp
  801ebb:	c3                   	ret    

00801ebc <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ebc:	55                   	push   %ebp
  801ebd:	89 e5                	mov    %esp,%ebp
  801ebf:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ec2:	68 96 29 80 00       	push   $0x802996
  801ec7:	ff 75 0c             	pushl  0xc(%ebp)
  801eca:	e8 7b ea ff ff       	call   80094a <strcpy>
	return 0;
}
  801ecf:	b8 00 00 00 00       	mov    $0x0,%eax
  801ed4:	c9                   	leave  
  801ed5:	c3                   	ret    

00801ed6 <devcons_write>:
{
  801ed6:	55                   	push   %ebp
  801ed7:	89 e5                	mov    %esp,%ebp
  801ed9:	57                   	push   %edi
  801eda:	56                   	push   %esi
  801edb:	53                   	push   %ebx
  801edc:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801ee2:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801ee7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801eed:	eb 2f                	jmp    801f1e <devcons_write+0x48>
		m = n - tot;
  801eef:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ef2:	29 f3                	sub    %esi,%ebx
  801ef4:	83 fb 7f             	cmp    $0x7f,%ebx
  801ef7:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801efc:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801eff:	83 ec 04             	sub    $0x4,%esp
  801f02:	53                   	push   %ebx
  801f03:	89 f0                	mov    %esi,%eax
  801f05:	03 45 0c             	add    0xc(%ebp),%eax
  801f08:	50                   	push   %eax
  801f09:	57                   	push   %edi
  801f0a:	e8 c9 eb ff ff       	call   800ad8 <memmove>
		sys_cputs(buf, m);
  801f0f:	83 c4 08             	add    $0x8,%esp
  801f12:	53                   	push   %ebx
  801f13:	57                   	push   %edi
  801f14:	e8 6e ed ff ff       	call   800c87 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801f19:	01 de                	add    %ebx,%esi
  801f1b:	83 c4 10             	add    $0x10,%esp
  801f1e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f21:	72 cc                	jb     801eef <devcons_write+0x19>
}
  801f23:	89 f0                	mov    %esi,%eax
  801f25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f28:	5b                   	pop    %ebx
  801f29:	5e                   	pop    %esi
  801f2a:	5f                   	pop    %edi
  801f2b:	5d                   	pop    %ebp
  801f2c:	c3                   	ret    

00801f2d <devcons_read>:
{
  801f2d:	55                   	push   %ebp
  801f2e:	89 e5                	mov    %esp,%ebp
  801f30:	83 ec 08             	sub    $0x8,%esp
  801f33:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801f38:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f3c:	75 07                	jne    801f45 <devcons_read+0x18>
}
  801f3e:	c9                   	leave  
  801f3f:	c3                   	ret    
		sys_yield();
  801f40:	e8 df ed ff ff       	call   800d24 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801f45:	e8 5b ed ff ff       	call   800ca5 <sys_cgetc>
  801f4a:	85 c0                	test   %eax,%eax
  801f4c:	74 f2                	je     801f40 <devcons_read+0x13>
	if (c < 0)
  801f4e:	85 c0                	test   %eax,%eax
  801f50:	78 ec                	js     801f3e <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  801f52:	83 f8 04             	cmp    $0x4,%eax
  801f55:	74 0c                	je     801f63 <devcons_read+0x36>
	*(char*)vbuf = c;
  801f57:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f5a:	88 02                	mov    %al,(%edx)
	return 1;
  801f5c:	b8 01 00 00 00       	mov    $0x1,%eax
  801f61:	eb db                	jmp    801f3e <devcons_read+0x11>
		return 0;
  801f63:	b8 00 00 00 00       	mov    $0x0,%eax
  801f68:	eb d4                	jmp    801f3e <devcons_read+0x11>

00801f6a <cputchar>:
{
  801f6a:	55                   	push   %ebp
  801f6b:	89 e5                	mov    %esp,%ebp
  801f6d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f70:	8b 45 08             	mov    0x8(%ebp),%eax
  801f73:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801f76:	6a 01                	push   $0x1
  801f78:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f7b:	50                   	push   %eax
  801f7c:	e8 06 ed ff ff       	call   800c87 <sys_cputs>
}
  801f81:	83 c4 10             	add    $0x10,%esp
  801f84:	c9                   	leave  
  801f85:	c3                   	ret    

00801f86 <getchar>:
{
  801f86:	55                   	push   %ebp
  801f87:	89 e5                	mov    %esp,%ebp
  801f89:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801f8c:	6a 01                	push   $0x1
  801f8e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f91:	50                   	push   %eax
  801f92:	6a 00                	push   $0x0
  801f94:	e8 87 f6 ff ff       	call   801620 <read>
	if (r < 0)
  801f99:	83 c4 10             	add    $0x10,%esp
  801f9c:	85 c0                	test   %eax,%eax
  801f9e:	78 08                	js     801fa8 <getchar+0x22>
	if (r < 1)
  801fa0:	85 c0                	test   %eax,%eax
  801fa2:	7e 06                	jle    801faa <getchar+0x24>
	return c;
  801fa4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801fa8:	c9                   	leave  
  801fa9:	c3                   	ret    
		return -E_EOF;
  801faa:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801faf:	eb f7                	jmp    801fa8 <getchar+0x22>

00801fb1 <iscons>:
{
  801fb1:	55                   	push   %ebp
  801fb2:	89 e5                	mov    %esp,%ebp
  801fb4:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fb7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fba:	50                   	push   %eax
  801fbb:	ff 75 08             	pushl  0x8(%ebp)
  801fbe:	e8 ec f3 ff ff       	call   8013af <fd_lookup>
  801fc3:	83 c4 10             	add    $0x10,%esp
  801fc6:	85 c0                	test   %eax,%eax
  801fc8:	78 11                	js     801fdb <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801fca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fcd:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fd3:	39 10                	cmp    %edx,(%eax)
  801fd5:	0f 94 c0             	sete   %al
  801fd8:	0f b6 c0             	movzbl %al,%eax
}
  801fdb:	c9                   	leave  
  801fdc:	c3                   	ret    

00801fdd <opencons>:
{
  801fdd:	55                   	push   %ebp
  801fde:	89 e5                	mov    %esp,%ebp
  801fe0:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801fe3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fe6:	50                   	push   %eax
  801fe7:	e8 74 f3 ff ff       	call   801360 <fd_alloc>
  801fec:	83 c4 10             	add    $0x10,%esp
  801fef:	85 c0                	test   %eax,%eax
  801ff1:	78 3a                	js     80202d <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ff3:	83 ec 04             	sub    $0x4,%esp
  801ff6:	68 07 04 00 00       	push   $0x407
  801ffb:	ff 75 f4             	pushl  -0xc(%ebp)
  801ffe:	6a 00                	push   $0x0
  802000:	e8 3e ed ff ff       	call   800d43 <sys_page_alloc>
  802005:	83 c4 10             	add    $0x10,%esp
  802008:	85 c0                	test   %eax,%eax
  80200a:	78 21                	js     80202d <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  80200c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80200f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802015:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802017:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80201a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802021:	83 ec 0c             	sub    $0xc,%esp
  802024:	50                   	push   %eax
  802025:	e8 0f f3 ff ff       	call   801339 <fd2num>
  80202a:	83 c4 10             	add    $0x10,%esp
}
  80202d:	c9                   	leave  
  80202e:	c3                   	ret    

0080202f <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80202f:	55                   	push   %ebp
  802030:	89 e5                	mov    %esp,%ebp
  802032:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802035:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80203c:	74 0a                	je     802048 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler %e",r);
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
	}
       
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80203e:	8b 45 08             	mov    0x8(%ebp),%eax
  802041:	a3 00 60 80 00       	mov    %eax,0x806000
}
  802046:	c9                   	leave  
  802047:	c3                   	ret    
		if((r=sys_page_alloc(thisenv->env_id,(void *)UXSTACKTOP-PGSIZE,PTE_P|PTE_W|PTE_U))<0)
  802048:	a1 04 40 80 00       	mov    0x804004,%eax
  80204d:	8b 40 48             	mov    0x48(%eax),%eax
  802050:	83 ec 04             	sub    $0x4,%esp
  802053:	6a 07                	push   $0x7
  802055:	68 00 f0 bf ee       	push   $0xeebff000
  80205a:	50                   	push   %eax
  80205b:	e8 e3 ec ff ff       	call   800d43 <sys_page_alloc>
  802060:	83 c4 10             	add    $0x10,%esp
  802063:	85 c0                	test   %eax,%eax
  802065:	78 1b                	js     802082 <set_pgfault_handler+0x53>
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
  802067:	a1 04 40 80 00       	mov    0x804004,%eax
  80206c:	8b 40 48             	mov    0x48(%eax),%eax
  80206f:	83 ec 08             	sub    $0x8,%esp
  802072:	68 94 20 80 00       	push   $0x802094
  802077:	50                   	push   %eax
  802078:	e8 11 ee ff ff       	call   800e8e <sys_env_set_pgfault_upcall>
  80207d:	83 c4 10             	add    $0x10,%esp
  802080:	eb bc                	jmp    80203e <set_pgfault_handler+0xf>
			panic("set_pgfault_handler %e",r);
  802082:	50                   	push   %eax
  802083:	68 a2 29 80 00       	push   $0x8029a2
  802088:	6a 22                	push   $0x22
  80208a:	68 b9 29 80 00       	push   $0x8029b9
  80208f:	e8 bc e1 ff ff       	call   800250 <_panic>

00802094 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802094:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802095:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80209a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80209c:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 48(%esp), %ebp
  80209f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
        subl $4, %ebp
  8020a3:	83 ed 04             	sub    $0x4,%ebp
        movl %ebp, 48(%esp)
  8020a6:	89 6c 24 30          	mov    %ebp,0x30(%esp)
        movl 40(%esp), %eax
  8020aa:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl %eax, (%ebp)
  8020ae:	89 45 00             	mov    %eax,0x0(%ebp)
	// Restore the trap-time registers.  After you do this, you
 	// can no longer modify any general-purpose registers.
 	// LAB 4: Your code here.
        addl $8, %esp
  8020b1:	83 c4 08             	add    $0x8,%esp
        popal
  8020b4:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $4, %esp
  8020b5:	83 c4 04             	add    $0x4,%esp
        popfl
  8020b8:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  8020b9:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  8020ba:	c3                   	ret    
  8020bb:	66 90                	xchg   %ax,%ax
  8020bd:	66 90                	xchg   %ax,%ax
  8020bf:	90                   	nop

008020c0 <__udivdi3>:
  8020c0:	55                   	push   %ebp
  8020c1:	57                   	push   %edi
  8020c2:	56                   	push   %esi
  8020c3:	53                   	push   %ebx
  8020c4:	83 ec 1c             	sub    $0x1c,%esp
  8020c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020cb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8020cf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020d3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8020d7:	85 d2                	test   %edx,%edx
  8020d9:	75 35                	jne    802110 <__udivdi3+0x50>
  8020db:	39 f3                	cmp    %esi,%ebx
  8020dd:	0f 87 bd 00 00 00    	ja     8021a0 <__udivdi3+0xe0>
  8020e3:	85 db                	test   %ebx,%ebx
  8020e5:	89 d9                	mov    %ebx,%ecx
  8020e7:	75 0b                	jne    8020f4 <__udivdi3+0x34>
  8020e9:	b8 01 00 00 00       	mov    $0x1,%eax
  8020ee:	31 d2                	xor    %edx,%edx
  8020f0:	f7 f3                	div    %ebx
  8020f2:	89 c1                	mov    %eax,%ecx
  8020f4:	31 d2                	xor    %edx,%edx
  8020f6:	89 f0                	mov    %esi,%eax
  8020f8:	f7 f1                	div    %ecx
  8020fa:	89 c6                	mov    %eax,%esi
  8020fc:	89 e8                	mov    %ebp,%eax
  8020fe:	89 f7                	mov    %esi,%edi
  802100:	f7 f1                	div    %ecx
  802102:	89 fa                	mov    %edi,%edx
  802104:	83 c4 1c             	add    $0x1c,%esp
  802107:	5b                   	pop    %ebx
  802108:	5e                   	pop    %esi
  802109:	5f                   	pop    %edi
  80210a:	5d                   	pop    %ebp
  80210b:	c3                   	ret    
  80210c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802110:	39 f2                	cmp    %esi,%edx
  802112:	77 7c                	ja     802190 <__udivdi3+0xd0>
  802114:	0f bd fa             	bsr    %edx,%edi
  802117:	83 f7 1f             	xor    $0x1f,%edi
  80211a:	0f 84 98 00 00 00    	je     8021b8 <__udivdi3+0xf8>
  802120:	89 f9                	mov    %edi,%ecx
  802122:	b8 20 00 00 00       	mov    $0x20,%eax
  802127:	29 f8                	sub    %edi,%eax
  802129:	d3 e2                	shl    %cl,%edx
  80212b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80212f:	89 c1                	mov    %eax,%ecx
  802131:	89 da                	mov    %ebx,%edx
  802133:	d3 ea                	shr    %cl,%edx
  802135:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802139:	09 d1                	or     %edx,%ecx
  80213b:	89 f2                	mov    %esi,%edx
  80213d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802141:	89 f9                	mov    %edi,%ecx
  802143:	d3 e3                	shl    %cl,%ebx
  802145:	89 c1                	mov    %eax,%ecx
  802147:	d3 ea                	shr    %cl,%edx
  802149:	89 f9                	mov    %edi,%ecx
  80214b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80214f:	d3 e6                	shl    %cl,%esi
  802151:	89 eb                	mov    %ebp,%ebx
  802153:	89 c1                	mov    %eax,%ecx
  802155:	d3 eb                	shr    %cl,%ebx
  802157:	09 de                	or     %ebx,%esi
  802159:	89 f0                	mov    %esi,%eax
  80215b:	f7 74 24 08          	divl   0x8(%esp)
  80215f:	89 d6                	mov    %edx,%esi
  802161:	89 c3                	mov    %eax,%ebx
  802163:	f7 64 24 0c          	mull   0xc(%esp)
  802167:	39 d6                	cmp    %edx,%esi
  802169:	72 0c                	jb     802177 <__udivdi3+0xb7>
  80216b:	89 f9                	mov    %edi,%ecx
  80216d:	d3 e5                	shl    %cl,%ebp
  80216f:	39 c5                	cmp    %eax,%ebp
  802171:	73 5d                	jae    8021d0 <__udivdi3+0x110>
  802173:	39 d6                	cmp    %edx,%esi
  802175:	75 59                	jne    8021d0 <__udivdi3+0x110>
  802177:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80217a:	31 ff                	xor    %edi,%edi
  80217c:	89 fa                	mov    %edi,%edx
  80217e:	83 c4 1c             	add    $0x1c,%esp
  802181:	5b                   	pop    %ebx
  802182:	5e                   	pop    %esi
  802183:	5f                   	pop    %edi
  802184:	5d                   	pop    %ebp
  802185:	c3                   	ret    
  802186:	8d 76 00             	lea    0x0(%esi),%esi
  802189:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802190:	31 ff                	xor    %edi,%edi
  802192:	31 c0                	xor    %eax,%eax
  802194:	89 fa                	mov    %edi,%edx
  802196:	83 c4 1c             	add    $0x1c,%esp
  802199:	5b                   	pop    %ebx
  80219a:	5e                   	pop    %esi
  80219b:	5f                   	pop    %edi
  80219c:	5d                   	pop    %ebp
  80219d:	c3                   	ret    
  80219e:	66 90                	xchg   %ax,%ax
  8021a0:	31 ff                	xor    %edi,%edi
  8021a2:	89 e8                	mov    %ebp,%eax
  8021a4:	89 f2                	mov    %esi,%edx
  8021a6:	f7 f3                	div    %ebx
  8021a8:	89 fa                	mov    %edi,%edx
  8021aa:	83 c4 1c             	add    $0x1c,%esp
  8021ad:	5b                   	pop    %ebx
  8021ae:	5e                   	pop    %esi
  8021af:	5f                   	pop    %edi
  8021b0:	5d                   	pop    %ebp
  8021b1:	c3                   	ret    
  8021b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021b8:	39 f2                	cmp    %esi,%edx
  8021ba:	72 06                	jb     8021c2 <__udivdi3+0x102>
  8021bc:	31 c0                	xor    %eax,%eax
  8021be:	39 eb                	cmp    %ebp,%ebx
  8021c0:	77 d2                	ja     802194 <__udivdi3+0xd4>
  8021c2:	b8 01 00 00 00       	mov    $0x1,%eax
  8021c7:	eb cb                	jmp    802194 <__udivdi3+0xd4>
  8021c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021d0:	89 d8                	mov    %ebx,%eax
  8021d2:	31 ff                	xor    %edi,%edi
  8021d4:	eb be                	jmp    802194 <__udivdi3+0xd4>
  8021d6:	66 90                	xchg   %ax,%ax
  8021d8:	66 90                	xchg   %ax,%ax
  8021da:	66 90                	xchg   %ax,%ax
  8021dc:	66 90                	xchg   %ax,%ax
  8021de:	66 90                	xchg   %ax,%ax

008021e0 <__umoddi3>:
  8021e0:	55                   	push   %ebp
  8021e1:	57                   	push   %edi
  8021e2:	56                   	push   %esi
  8021e3:	53                   	push   %ebx
  8021e4:	83 ec 1c             	sub    $0x1c,%esp
  8021e7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  8021eb:	8b 74 24 30          	mov    0x30(%esp),%esi
  8021ef:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8021f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021f7:	85 ed                	test   %ebp,%ebp
  8021f9:	89 f0                	mov    %esi,%eax
  8021fb:	89 da                	mov    %ebx,%edx
  8021fd:	75 19                	jne    802218 <__umoddi3+0x38>
  8021ff:	39 df                	cmp    %ebx,%edi
  802201:	0f 86 b1 00 00 00    	jbe    8022b8 <__umoddi3+0xd8>
  802207:	f7 f7                	div    %edi
  802209:	89 d0                	mov    %edx,%eax
  80220b:	31 d2                	xor    %edx,%edx
  80220d:	83 c4 1c             	add    $0x1c,%esp
  802210:	5b                   	pop    %ebx
  802211:	5e                   	pop    %esi
  802212:	5f                   	pop    %edi
  802213:	5d                   	pop    %ebp
  802214:	c3                   	ret    
  802215:	8d 76 00             	lea    0x0(%esi),%esi
  802218:	39 dd                	cmp    %ebx,%ebp
  80221a:	77 f1                	ja     80220d <__umoddi3+0x2d>
  80221c:	0f bd cd             	bsr    %ebp,%ecx
  80221f:	83 f1 1f             	xor    $0x1f,%ecx
  802222:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802226:	0f 84 b4 00 00 00    	je     8022e0 <__umoddi3+0x100>
  80222c:	b8 20 00 00 00       	mov    $0x20,%eax
  802231:	89 c2                	mov    %eax,%edx
  802233:	8b 44 24 04          	mov    0x4(%esp),%eax
  802237:	29 c2                	sub    %eax,%edx
  802239:	89 c1                	mov    %eax,%ecx
  80223b:	89 f8                	mov    %edi,%eax
  80223d:	d3 e5                	shl    %cl,%ebp
  80223f:	89 d1                	mov    %edx,%ecx
  802241:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802245:	d3 e8                	shr    %cl,%eax
  802247:	09 c5                	or     %eax,%ebp
  802249:	8b 44 24 04          	mov    0x4(%esp),%eax
  80224d:	89 c1                	mov    %eax,%ecx
  80224f:	d3 e7                	shl    %cl,%edi
  802251:	89 d1                	mov    %edx,%ecx
  802253:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802257:	89 df                	mov    %ebx,%edi
  802259:	d3 ef                	shr    %cl,%edi
  80225b:	89 c1                	mov    %eax,%ecx
  80225d:	89 f0                	mov    %esi,%eax
  80225f:	d3 e3                	shl    %cl,%ebx
  802261:	89 d1                	mov    %edx,%ecx
  802263:	89 fa                	mov    %edi,%edx
  802265:	d3 e8                	shr    %cl,%eax
  802267:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80226c:	09 d8                	or     %ebx,%eax
  80226e:	f7 f5                	div    %ebp
  802270:	d3 e6                	shl    %cl,%esi
  802272:	89 d1                	mov    %edx,%ecx
  802274:	f7 64 24 08          	mull   0x8(%esp)
  802278:	39 d1                	cmp    %edx,%ecx
  80227a:	89 c3                	mov    %eax,%ebx
  80227c:	89 d7                	mov    %edx,%edi
  80227e:	72 06                	jb     802286 <__umoddi3+0xa6>
  802280:	75 0e                	jne    802290 <__umoddi3+0xb0>
  802282:	39 c6                	cmp    %eax,%esi
  802284:	73 0a                	jae    802290 <__umoddi3+0xb0>
  802286:	2b 44 24 08          	sub    0x8(%esp),%eax
  80228a:	19 ea                	sbb    %ebp,%edx
  80228c:	89 d7                	mov    %edx,%edi
  80228e:	89 c3                	mov    %eax,%ebx
  802290:	89 ca                	mov    %ecx,%edx
  802292:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  802297:	29 de                	sub    %ebx,%esi
  802299:	19 fa                	sbb    %edi,%edx
  80229b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80229f:	89 d0                	mov    %edx,%eax
  8022a1:	d3 e0                	shl    %cl,%eax
  8022a3:	89 d9                	mov    %ebx,%ecx
  8022a5:	d3 ee                	shr    %cl,%esi
  8022a7:	d3 ea                	shr    %cl,%edx
  8022a9:	09 f0                	or     %esi,%eax
  8022ab:	83 c4 1c             	add    $0x1c,%esp
  8022ae:	5b                   	pop    %ebx
  8022af:	5e                   	pop    %esi
  8022b0:	5f                   	pop    %edi
  8022b1:	5d                   	pop    %ebp
  8022b2:	c3                   	ret    
  8022b3:	90                   	nop
  8022b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022b8:	85 ff                	test   %edi,%edi
  8022ba:	89 f9                	mov    %edi,%ecx
  8022bc:	75 0b                	jne    8022c9 <__umoddi3+0xe9>
  8022be:	b8 01 00 00 00       	mov    $0x1,%eax
  8022c3:	31 d2                	xor    %edx,%edx
  8022c5:	f7 f7                	div    %edi
  8022c7:	89 c1                	mov    %eax,%ecx
  8022c9:	89 d8                	mov    %ebx,%eax
  8022cb:	31 d2                	xor    %edx,%edx
  8022cd:	f7 f1                	div    %ecx
  8022cf:	89 f0                	mov    %esi,%eax
  8022d1:	f7 f1                	div    %ecx
  8022d3:	e9 31 ff ff ff       	jmp    802209 <__umoddi3+0x29>
  8022d8:	90                   	nop
  8022d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022e0:	39 dd                	cmp    %ebx,%ebp
  8022e2:	72 08                	jb     8022ec <__umoddi3+0x10c>
  8022e4:	39 f7                	cmp    %esi,%edi
  8022e6:	0f 87 21 ff ff ff    	ja     80220d <__umoddi3+0x2d>
  8022ec:	89 da                	mov    %ebx,%edx
  8022ee:	89 f0                	mov    %esi,%eax
  8022f0:	29 f8                	sub    %edi,%eax
  8022f2:	19 ea                	sbb    %ebp,%edx
  8022f4:	e9 14 ff ff ff       	jmp    80220d <__umoddi3+0x2d>
