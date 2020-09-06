
obj/user/testfdsharing.debug:     file format elf32-i386


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
  80002c:	e8 9b 01 00 00       	call   8001cc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char buf[512], buf2[512];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 14             	sub    $0x14,%esp
	int fd, r, n, n2;

	if ((fd = open("motd", O_RDONLY)) < 0)
  80003c:	6a 00                	push   $0x0
  80003e:	68 40 23 80 00       	push   $0x802340
  800043:	e8 15 19 00 00       	call   80195d <open>
  800048:	89 c3                	mov    %eax,%ebx
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	0f 88 01 01 00 00    	js     800156 <umain+0x123>
		panic("open motd: %e", fd);
	seek(fd, 0);
  800055:	83 ec 08             	sub    $0x8,%esp
  800058:	6a 00                	push   $0x0
  80005a:	50                   	push   %eax
  80005b:	e8 e8 15 00 00       	call   801648 <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0)
  800060:	83 c4 0c             	add    $0xc,%esp
  800063:	68 00 02 00 00       	push   $0x200
  800068:	68 20 42 80 00       	push   $0x804220
  80006d:	53                   	push   %ebx
  80006e:	e8 0c 15 00 00       	call   80157f <readn>
  800073:	89 c6                	mov    %eax,%esi
  800075:	83 c4 10             	add    $0x10,%esp
  800078:	85 c0                	test   %eax,%eax
  80007a:	0f 8e e8 00 00 00    	jle    800168 <umain+0x135>
		panic("readn: %e", n);

	if ((r = fork()) < 0)
  800080:	e8 7f 0f 00 00       	call   801004 <fork>
  800085:	89 c7                	mov    %eax,%edi
  800087:	85 c0                	test   %eax,%eax
  800089:	0f 88 eb 00 00 00    	js     80017a <umain+0x147>
		panic("fork: %e", r);
	if (r == 0) {
  80008f:	85 c0                	test   %eax,%eax
  800091:	75 7b                	jne    80010e <umain+0xdb>
		seek(fd, 0);
  800093:	83 ec 08             	sub    $0x8,%esp
  800096:	6a 00                	push   $0x0
  800098:	53                   	push   %ebx
  800099:	e8 aa 15 00 00       	call   801648 <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  80009e:	c7 04 24 b0 23 80 00 	movl   $0x8023b0,(%esp)
  8000a5:	e8 5d 02 00 00       	call   800307 <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8000aa:	83 c4 0c             	add    $0xc,%esp
  8000ad:	68 00 02 00 00       	push   $0x200
  8000b2:	68 20 40 80 00       	push   $0x804020
  8000b7:	53                   	push   %ebx
  8000b8:	e8 c2 14 00 00       	call   80157f <readn>
  8000bd:	83 c4 10             	add    $0x10,%esp
  8000c0:	39 c6                	cmp    %eax,%esi
  8000c2:	0f 85 c4 00 00 00    	jne    80018c <umain+0x159>
			panic("read in parent got %d, read in child got %d", n, n2);
		if (memcmp(buf, buf2, n) != 0)
  8000c8:	83 ec 04             	sub    $0x4,%esp
  8000cb:	56                   	push   %esi
  8000cc:	68 20 40 80 00       	push   $0x804020
  8000d1:	68 20 42 80 00       	push   $0x804220
  8000d6:	e8 54 0a 00 00       	call   800b2f <memcmp>
  8000db:	83 c4 10             	add    $0x10,%esp
  8000de:	85 c0                	test   %eax,%eax
  8000e0:	0f 85 bc 00 00 00    	jne    8001a2 <umain+0x16f>
			panic("read in parent got different bytes from read in child");
		cprintf("read in child succeeded\n");
  8000e6:	83 ec 0c             	sub    $0xc,%esp
  8000e9:	68 7b 23 80 00       	push   $0x80237b
  8000ee:	e8 14 02 00 00       	call   800307 <cprintf>
		seek(fd, 0);
  8000f3:	83 c4 08             	add    $0x8,%esp
  8000f6:	6a 00                	push   $0x0
  8000f8:	53                   	push   %ebx
  8000f9:	e8 4a 15 00 00       	call   801648 <seek>
		close(fd);
  8000fe:	89 1c 24             	mov    %ebx,(%esp)
  800101:	e8 b6 12 00 00       	call   8013bc <close>
		exit();
  800106:	e8 07 01 00 00       	call   800212 <exit>
  80010b:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  80010e:	83 ec 0c             	sub    $0xc,%esp
  800111:	57                   	push   %edi
  800112:	e8 38 1c 00 00       	call   801d4f <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  800117:	83 c4 0c             	add    $0xc,%esp
  80011a:	68 00 02 00 00       	push   $0x200
  80011f:	68 20 40 80 00       	push   $0x804020
  800124:	53                   	push   %ebx
  800125:	e8 55 14 00 00       	call   80157f <readn>
  80012a:	83 c4 10             	add    $0x10,%esp
  80012d:	39 c6                	cmp    %eax,%esi
  80012f:	0f 85 81 00 00 00    	jne    8001b6 <umain+0x183>
		panic("read in parent got %d, then got %d", n, n2);
	cprintf("read in parent succeeded\n");
  800135:	83 ec 0c             	sub    $0xc,%esp
  800138:	68 94 23 80 00       	push   $0x802394
  80013d:	e8 c5 01 00 00       	call   800307 <cprintf>
	close(fd);
  800142:	89 1c 24             	mov    %ebx,(%esp)
  800145:	e8 72 12 00 00       	call   8013bc <close>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  80014a:	cc                   	int3   

	breakpoint();
}
  80014b:	83 c4 10             	add    $0x10,%esp
  80014e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800151:	5b                   	pop    %ebx
  800152:	5e                   	pop    %esi
  800153:	5f                   	pop    %edi
  800154:	5d                   	pop    %ebp
  800155:	c3                   	ret    
		panic("open motd: %e", fd);
  800156:	50                   	push   %eax
  800157:	68 45 23 80 00       	push   $0x802345
  80015c:	6a 0c                	push   $0xc
  80015e:	68 53 23 80 00       	push   $0x802353
  800163:	e8 c4 00 00 00       	call   80022c <_panic>
		panic("readn: %e", n);
  800168:	50                   	push   %eax
  800169:	68 68 23 80 00       	push   $0x802368
  80016e:	6a 0f                	push   $0xf
  800170:	68 53 23 80 00       	push   $0x802353
  800175:	e8 b2 00 00 00       	call   80022c <_panic>
		panic("fork: %e", r);
  80017a:	50                   	push   %eax
  80017b:	68 72 23 80 00       	push   $0x802372
  800180:	6a 12                	push   $0x12
  800182:	68 53 23 80 00       	push   $0x802353
  800187:	e8 a0 00 00 00       	call   80022c <_panic>
			panic("read in parent got %d, read in child got %d", n, n2);
  80018c:	83 ec 0c             	sub    $0xc,%esp
  80018f:	50                   	push   %eax
  800190:	56                   	push   %esi
  800191:	68 f4 23 80 00       	push   $0x8023f4
  800196:	6a 17                	push   $0x17
  800198:	68 53 23 80 00       	push   $0x802353
  80019d:	e8 8a 00 00 00       	call   80022c <_panic>
			panic("read in parent got different bytes from read in child");
  8001a2:	83 ec 04             	sub    $0x4,%esp
  8001a5:	68 20 24 80 00       	push   $0x802420
  8001aa:	6a 19                	push   $0x19
  8001ac:	68 53 23 80 00       	push   $0x802353
  8001b1:	e8 76 00 00 00       	call   80022c <_panic>
		panic("read in parent got %d, then got %d", n, n2);
  8001b6:	83 ec 0c             	sub    $0xc,%esp
  8001b9:	50                   	push   %eax
  8001ba:	56                   	push   %esi
  8001bb:	68 58 24 80 00       	push   $0x802458
  8001c0:	6a 21                	push   $0x21
  8001c2:	68 53 23 80 00       	push   $0x802353
  8001c7:	e8 60 00 00 00       	call   80022c <_panic>

008001cc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	56                   	push   %esi
  8001d0:	53                   	push   %ebx
  8001d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001d4:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001d7:	e8 05 0b 00 00       	call   800ce1 <sys_getenvid>
  8001dc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001e1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001e4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001e9:	a3 20 44 80 00       	mov    %eax,0x804420
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001ee:	85 db                	test   %ebx,%ebx
  8001f0:	7e 07                	jle    8001f9 <libmain+0x2d>
		binaryname = argv[0];
  8001f2:	8b 06                	mov    (%esi),%eax
  8001f4:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8001f9:	83 ec 08             	sub    $0x8,%esp
  8001fc:	56                   	push   %esi
  8001fd:	53                   	push   %ebx
  8001fe:	e8 30 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800203:	e8 0a 00 00 00       	call   800212 <exit>
}
  800208:	83 c4 10             	add    $0x10,%esp
  80020b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80020e:	5b                   	pop    %ebx
  80020f:	5e                   	pop    %esi
  800210:	5d                   	pop    %ebp
  800211:	c3                   	ret    

00800212 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800212:	55                   	push   %ebp
  800213:	89 e5                	mov    %esp,%ebp
  800215:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800218:	e8 ca 11 00 00       	call   8013e7 <close_all>
	sys_env_destroy(0);
  80021d:	83 ec 0c             	sub    $0xc,%esp
  800220:	6a 00                	push   $0x0
  800222:	e8 79 0a 00 00       	call   800ca0 <sys_env_destroy>
}
  800227:	83 c4 10             	add    $0x10,%esp
  80022a:	c9                   	leave  
  80022b:	c3                   	ret    

0080022c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80022c:	55                   	push   %ebp
  80022d:	89 e5                	mov    %esp,%ebp
  80022f:	56                   	push   %esi
  800230:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800231:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800234:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80023a:	e8 a2 0a 00 00       	call   800ce1 <sys_getenvid>
  80023f:	83 ec 0c             	sub    $0xc,%esp
  800242:	ff 75 0c             	pushl  0xc(%ebp)
  800245:	ff 75 08             	pushl  0x8(%ebp)
  800248:	56                   	push   %esi
  800249:	50                   	push   %eax
  80024a:	68 88 24 80 00       	push   $0x802488
  80024f:	e8 b3 00 00 00       	call   800307 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800254:	83 c4 18             	add    $0x18,%esp
  800257:	53                   	push   %ebx
  800258:	ff 75 10             	pushl  0x10(%ebp)
  80025b:	e8 56 00 00 00       	call   8002b6 <vcprintf>
	cprintf("\n");
  800260:	c7 04 24 df 27 80 00 	movl   $0x8027df,(%esp)
  800267:	e8 9b 00 00 00       	call   800307 <cprintf>
  80026c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80026f:	cc                   	int3   
  800270:	eb fd                	jmp    80026f <_panic+0x43>

00800272 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800272:	55                   	push   %ebp
  800273:	89 e5                	mov    %esp,%ebp
  800275:	53                   	push   %ebx
  800276:	83 ec 04             	sub    $0x4,%esp
  800279:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80027c:	8b 13                	mov    (%ebx),%edx
  80027e:	8d 42 01             	lea    0x1(%edx),%eax
  800281:	89 03                	mov    %eax,(%ebx)
  800283:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800286:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80028a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80028f:	74 09                	je     80029a <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800291:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800295:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800298:	c9                   	leave  
  800299:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80029a:	83 ec 08             	sub    $0x8,%esp
  80029d:	68 ff 00 00 00       	push   $0xff
  8002a2:	8d 43 08             	lea    0x8(%ebx),%eax
  8002a5:	50                   	push   %eax
  8002a6:	e8 b8 09 00 00       	call   800c63 <sys_cputs>
		b->idx = 0;
  8002ab:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002b1:	83 c4 10             	add    $0x10,%esp
  8002b4:	eb db                	jmp    800291 <putch+0x1f>

008002b6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002b6:	55                   	push   %ebp
  8002b7:	89 e5                	mov    %esp,%ebp
  8002b9:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002bf:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002c6:	00 00 00 
	b.cnt = 0;
  8002c9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002d0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002d3:	ff 75 0c             	pushl  0xc(%ebp)
  8002d6:	ff 75 08             	pushl  0x8(%ebp)
  8002d9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002df:	50                   	push   %eax
  8002e0:	68 72 02 80 00       	push   $0x800272
  8002e5:	e8 1a 01 00 00       	call   800404 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002ea:	83 c4 08             	add    $0x8,%esp
  8002ed:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002f3:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002f9:	50                   	push   %eax
  8002fa:	e8 64 09 00 00       	call   800c63 <sys_cputs>

	return b.cnt;
}
  8002ff:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800305:	c9                   	leave  
  800306:	c3                   	ret    

00800307 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800307:	55                   	push   %ebp
  800308:	89 e5                	mov    %esp,%ebp
  80030a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80030d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800310:	50                   	push   %eax
  800311:	ff 75 08             	pushl  0x8(%ebp)
  800314:	e8 9d ff ff ff       	call   8002b6 <vcprintf>
	va_end(ap);

	return cnt;
}
  800319:	c9                   	leave  
  80031a:	c3                   	ret    

0080031b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80031b:	55                   	push   %ebp
  80031c:	89 e5                	mov    %esp,%ebp
  80031e:	57                   	push   %edi
  80031f:	56                   	push   %esi
  800320:	53                   	push   %ebx
  800321:	83 ec 1c             	sub    $0x1c,%esp
  800324:	89 c7                	mov    %eax,%edi
  800326:	89 d6                	mov    %edx,%esi
  800328:	8b 45 08             	mov    0x8(%ebp),%eax
  80032b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80032e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800331:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800334:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800337:	bb 00 00 00 00       	mov    $0x0,%ebx
  80033c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80033f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800342:	39 d3                	cmp    %edx,%ebx
  800344:	72 05                	jb     80034b <printnum+0x30>
  800346:	39 45 10             	cmp    %eax,0x10(%ebp)
  800349:	77 7a                	ja     8003c5 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80034b:	83 ec 0c             	sub    $0xc,%esp
  80034e:	ff 75 18             	pushl  0x18(%ebp)
  800351:	8b 45 14             	mov    0x14(%ebp),%eax
  800354:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800357:	53                   	push   %ebx
  800358:	ff 75 10             	pushl  0x10(%ebp)
  80035b:	83 ec 08             	sub    $0x8,%esp
  80035e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800361:	ff 75 e0             	pushl  -0x20(%ebp)
  800364:	ff 75 dc             	pushl  -0x24(%ebp)
  800367:	ff 75 d8             	pushl  -0x28(%ebp)
  80036a:	e8 81 1d 00 00       	call   8020f0 <__udivdi3>
  80036f:	83 c4 18             	add    $0x18,%esp
  800372:	52                   	push   %edx
  800373:	50                   	push   %eax
  800374:	89 f2                	mov    %esi,%edx
  800376:	89 f8                	mov    %edi,%eax
  800378:	e8 9e ff ff ff       	call   80031b <printnum>
  80037d:	83 c4 20             	add    $0x20,%esp
  800380:	eb 13                	jmp    800395 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800382:	83 ec 08             	sub    $0x8,%esp
  800385:	56                   	push   %esi
  800386:	ff 75 18             	pushl  0x18(%ebp)
  800389:	ff d7                	call   *%edi
  80038b:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80038e:	83 eb 01             	sub    $0x1,%ebx
  800391:	85 db                	test   %ebx,%ebx
  800393:	7f ed                	jg     800382 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800395:	83 ec 08             	sub    $0x8,%esp
  800398:	56                   	push   %esi
  800399:	83 ec 04             	sub    $0x4,%esp
  80039c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80039f:	ff 75 e0             	pushl  -0x20(%ebp)
  8003a2:	ff 75 dc             	pushl  -0x24(%ebp)
  8003a5:	ff 75 d8             	pushl  -0x28(%ebp)
  8003a8:	e8 63 1e 00 00       	call   802210 <__umoddi3>
  8003ad:	83 c4 14             	add    $0x14,%esp
  8003b0:	0f be 80 ab 24 80 00 	movsbl 0x8024ab(%eax),%eax
  8003b7:	50                   	push   %eax
  8003b8:	ff d7                	call   *%edi
}
  8003ba:	83 c4 10             	add    $0x10,%esp
  8003bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003c0:	5b                   	pop    %ebx
  8003c1:	5e                   	pop    %esi
  8003c2:	5f                   	pop    %edi
  8003c3:	5d                   	pop    %ebp
  8003c4:	c3                   	ret    
  8003c5:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003c8:	eb c4                	jmp    80038e <printnum+0x73>

008003ca <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
  8003cd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003d0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003d4:	8b 10                	mov    (%eax),%edx
  8003d6:	3b 50 04             	cmp    0x4(%eax),%edx
  8003d9:	73 0a                	jae    8003e5 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003db:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003de:	89 08                	mov    %ecx,(%eax)
  8003e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e3:	88 02                	mov    %al,(%edx)
}
  8003e5:	5d                   	pop    %ebp
  8003e6:	c3                   	ret    

008003e7 <printfmt>:
{
  8003e7:	55                   	push   %ebp
  8003e8:	89 e5                	mov    %esp,%ebp
  8003ea:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8003ed:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003f0:	50                   	push   %eax
  8003f1:	ff 75 10             	pushl  0x10(%ebp)
  8003f4:	ff 75 0c             	pushl  0xc(%ebp)
  8003f7:	ff 75 08             	pushl  0x8(%ebp)
  8003fa:	e8 05 00 00 00       	call   800404 <vprintfmt>
}
  8003ff:	83 c4 10             	add    $0x10,%esp
  800402:	c9                   	leave  
  800403:	c3                   	ret    

00800404 <vprintfmt>:
{
  800404:	55                   	push   %ebp
  800405:	89 e5                	mov    %esp,%ebp
  800407:	57                   	push   %edi
  800408:	56                   	push   %esi
  800409:	53                   	push   %ebx
  80040a:	83 ec 2c             	sub    $0x2c,%esp
  80040d:	8b 75 08             	mov    0x8(%ebp),%esi
  800410:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800413:	8b 7d 10             	mov    0x10(%ebp),%edi
  800416:	e9 c1 03 00 00       	jmp    8007dc <vprintfmt+0x3d8>
		padc = ' ';
  80041b:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  80041f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800426:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  80042d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800434:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800439:	8d 47 01             	lea    0x1(%edi),%eax
  80043c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80043f:	0f b6 17             	movzbl (%edi),%edx
  800442:	8d 42 dd             	lea    -0x23(%edx),%eax
  800445:	3c 55                	cmp    $0x55,%al
  800447:	0f 87 12 04 00 00    	ja     80085f <vprintfmt+0x45b>
  80044d:	0f b6 c0             	movzbl %al,%eax
  800450:	ff 24 85 e0 25 80 00 	jmp    *0x8025e0(,%eax,4)
  800457:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80045a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80045e:	eb d9                	jmp    800439 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800460:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800463:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800467:	eb d0                	jmp    800439 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800469:	0f b6 d2             	movzbl %dl,%edx
  80046c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80046f:	b8 00 00 00 00       	mov    $0x0,%eax
  800474:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800477:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80047a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80047e:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800481:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800484:	83 f9 09             	cmp    $0x9,%ecx
  800487:	77 55                	ja     8004de <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800489:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80048c:	eb e9                	jmp    800477 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  80048e:	8b 45 14             	mov    0x14(%ebp),%eax
  800491:	8b 00                	mov    (%eax),%eax
  800493:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800496:	8b 45 14             	mov    0x14(%ebp),%eax
  800499:	8d 40 04             	lea    0x4(%eax),%eax
  80049c:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80049f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8004a2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004a6:	79 91                	jns    800439 <vprintfmt+0x35>
				width = precision, precision = -1;
  8004a8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004ae:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004b5:	eb 82                	jmp    800439 <vprintfmt+0x35>
  8004b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004ba:	85 c0                	test   %eax,%eax
  8004bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c1:	0f 49 d0             	cmovns %eax,%edx
  8004c4:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ca:	e9 6a ff ff ff       	jmp    800439 <vprintfmt+0x35>
  8004cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8004d2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004d9:	e9 5b ff ff ff       	jmp    800439 <vprintfmt+0x35>
  8004de:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004e1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004e4:	eb bc                	jmp    8004a2 <vprintfmt+0x9e>
			lflag++;
  8004e6:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8004e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004ec:	e9 48 ff ff ff       	jmp    800439 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8004f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f4:	8d 78 04             	lea    0x4(%eax),%edi
  8004f7:	83 ec 08             	sub    $0x8,%esp
  8004fa:	53                   	push   %ebx
  8004fb:	ff 30                	pushl  (%eax)
  8004fd:	ff d6                	call   *%esi
			break;
  8004ff:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800502:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800505:	e9 cf 02 00 00       	jmp    8007d9 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  80050a:	8b 45 14             	mov    0x14(%ebp),%eax
  80050d:	8d 78 04             	lea    0x4(%eax),%edi
  800510:	8b 00                	mov    (%eax),%eax
  800512:	99                   	cltd   
  800513:	31 d0                	xor    %edx,%eax
  800515:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800517:	83 f8 0f             	cmp    $0xf,%eax
  80051a:	7f 23                	jg     80053f <vprintfmt+0x13b>
  80051c:	8b 14 85 40 27 80 00 	mov    0x802740(,%eax,4),%edx
  800523:	85 d2                	test   %edx,%edx
  800525:	74 18                	je     80053f <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800527:	52                   	push   %edx
  800528:	68 b5 29 80 00       	push   $0x8029b5
  80052d:	53                   	push   %ebx
  80052e:	56                   	push   %esi
  80052f:	e8 b3 fe ff ff       	call   8003e7 <printfmt>
  800534:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800537:	89 7d 14             	mov    %edi,0x14(%ebp)
  80053a:	e9 9a 02 00 00       	jmp    8007d9 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  80053f:	50                   	push   %eax
  800540:	68 c3 24 80 00       	push   $0x8024c3
  800545:	53                   	push   %ebx
  800546:	56                   	push   %esi
  800547:	e8 9b fe ff ff       	call   8003e7 <printfmt>
  80054c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80054f:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800552:	e9 82 02 00 00       	jmp    8007d9 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  800557:	8b 45 14             	mov    0x14(%ebp),%eax
  80055a:	83 c0 04             	add    $0x4,%eax
  80055d:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800560:	8b 45 14             	mov    0x14(%ebp),%eax
  800563:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800565:	85 ff                	test   %edi,%edi
  800567:	b8 bc 24 80 00       	mov    $0x8024bc,%eax
  80056c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80056f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800573:	0f 8e bd 00 00 00    	jle    800636 <vprintfmt+0x232>
  800579:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80057d:	75 0e                	jne    80058d <vprintfmt+0x189>
  80057f:	89 75 08             	mov    %esi,0x8(%ebp)
  800582:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800585:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800588:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80058b:	eb 6d                	jmp    8005fa <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  80058d:	83 ec 08             	sub    $0x8,%esp
  800590:	ff 75 d0             	pushl  -0x30(%ebp)
  800593:	57                   	push   %edi
  800594:	e8 6e 03 00 00       	call   800907 <strnlen>
  800599:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80059c:	29 c1                	sub    %eax,%ecx
  80059e:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8005a1:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005a4:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005a8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005ab:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005ae:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b0:	eb 0f                	jmp    8005c1 <vprintfmt+0x1bd>
					putch(padc, putdat);
  8005b2:	83 ec 08             	sub    $0x8,%esp
  8005b5:	53                   	push   %ebx
  8005b6:	ff 75 e0             	pushl  -0x20(%ebp)
  8005b9:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005bb:	83 ef 01             	sub    $0x1,%edi
  8005be:	83 c4 10             	add    $0x10,%esp
  8005c1:	85 ff                	test   %edi,%edi
  8005c3:	7f ed                	jg     8005b2 <vprintfmt+0x1ae>
  8005c5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005c8:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8005cb:	85 c9                	test   %ecx,%ecx
  8005cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8005d2:	0f 49 c1             	cmovns %ecx,%eax
  8005d5:	29 c1                	sub    %eax,%ecx
  8005d7:	89 75 08             	mov    %esi,0x8(%ebp)
  8005da:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005dd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005e0:	89 cb                	mov    %ecx,%ebx
  8005e2:	eb 16                	jmp    8005fa <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8005e4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005e8:	75 31                	jne    80061b <vprintfmt+0x217>
					putch(ch, putdat);
  8005ea:	83 ec 08             	sub    $0x8,%esp
  8005ed:	ff 75 0c             	pushl  0xc(%ebp)
  8005f0:	50                   	push   %eax
  8005f1:	ff 55 08             	call   *0x8(%ebp)
  8005f4:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005f7:	83 eb 01             	sub    $0x1,%ebx
  8005fa:	83 c7 01             	add    $0x1,%edi
  8005fd:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800601:	0f be c2             	movsbl %dl,%eax
  800604:	85 c0                	test   %eax,%eax
  800606:	74 59                	je     800661 <vprintfmt+0x25d>
  800608:	85 f6                	test   %esi,%esi
  80060a:	78 d8                	js     8005e4 <vprintfmt+0x1e0>
  80060c:	83 ee 01             	sub    $0x1,%esi
  80060f:	79 d3                	jns    8005e4 <vprintfmt+0x1e0>
  800611:	89 df                	mov    %ebx,%edi
  800613:	8b 75 08             	mov    0x8(%ebp),%esi
  800616:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800619:	eb 37                	jmp    800652 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  80061b:	0f be d2             	movsbl %dl,%edx
  80061e:	83 ea 20             	sub    $0x20,%edx
  800621:	83 fa 5e             	cmp    $0x5e,%edx
  800624:	76 c4                	jbe    8005ea <vprintfmt+0x1e6>
					putch('?', putdat);
  800626:	83 ec 08             	sub    $0x8,%esp
  800629:	ff 75 0c             	pushl  0xc(%ebp)
  80062c:	6a 3f                	push   $0x3f
  80062e:	ff 55 08             	call   *0x8(%ebp)
  800631:	83 c4 10             	add    $0x10,%esp
  800634:	eb c1                	jmp    8005f7 <vprintfmt+0x1f3>
  800636:	89 75 08             	mov    %esi,0x8(%ebp)
  800639:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80063c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80063f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800642:	eb b6                	jmp    8005fa <vprintfmt+0x1f6>
				putch(' ', putdat);
  800644:	83 ec 08             	sub    $0x8,%esp
  800647:	53                   	push   %ebx
  800648:	6a 20                	push   $0x20
  80064a:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80064c:	83 ef 01             	sub    $0x1,%edi
  80064f:	83 c4 10             	add    $0x10,%esp
  800652:	85 ff                	test   %edi,%edi
  800654:	7f ee                	jg     800644 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800656:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800659:	89 45 14             	mov    %eax,0x14(%ebp)
  80065c:	e9 78 01 00 00       	jmp    8007d9 <vprintfmt+0x3d5>
  800661:	89 df                	mov    %ebx,%edi
  800663:	8b 75 08             	mov    0x8(%ebp),%esi
  800666:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800669:	eb e7                	jmp    800652 <vprintfmt+0x24e>
	if (lflag >= 2)
  80066b:	83 f9 01             	cmp    $0x1,%ecx
  80066e:	7e 3f                	jle    8006af <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800670:	8b 45 14             	mov    0x14(%ebp),%eax
  800673:	8b 50 04             	mov    0x4(%eax),%edx
  800676:	8b 00                	mov    (%eax),%eax
  800678:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80067b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80067e:	8b 45 14             	mov    0x14(%ebp),%eax
  800681:	8d 40 08             	lea    0x8(%eax),%eax
  800684:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800687:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80068b:	79 5c                	jns    8006e9 <vprintfmt+0x2e5>
				putch('-', putdat);
  80068d:	83 ec 08             	sub    $0x8,%esp
  800690:	53                   	push   %ebx
  800691:	6a 2d                	push   $0x2d
  800693:	ff d6                	call   *%esi
				num = -(long long) num;
  800695:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800698:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80069b:	f7 da                	neg    %edx
  80069d:	83 d1 00             	adc    $0x0,%ecx
  8006a0:	f7 d9                	neg    %ecx
  8006a2:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006a5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006aa:	e9 10 01 00 00       	jmp    8007bf <vprintfmt+0x3bb>
	else if (lflag)
  8006af:	85 c9                	test   %ecx,%ecx
  8006b1:	75 1b                	jne    8006ce <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8006b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b6:	8b 00                	mov    (%eax),%eax
  8006b8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006bb:	89 c1                	mov    %eax,%ecx
  8006bd:	c1 f9 1f             	sar    $0x1f,%ecx
  8006c0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c6:	8d 40 04             	lea    0x4(%eax),%eax
  8006c9:	89 45 14             	mov    %eax,0x14(%ebp)
  8006cc:	eb b9                	jmp    800687 <vprintfmt+0x283>
		return va_arg(*ap, long);
  8006ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d1:	8b 00                	mov    (%eax),%eax
  8006d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d6:	89 c1                	mov    %eax,%ecx
  8006d8:	c1 f9 1f             	sar    $0x1f,%ecx
  8006db:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006de:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e1:	8d 40 04             	lea    0x4(%eax),%eax
  8006e4:	89 45 14             	mov    %eax,0x14(%ebp)
  8006e7:	eb 9e                	jmp    800687 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8006e9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006ec:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8006ef:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006f4:	e9 c6 00 00 00       	jmp    8007bf <vprintfmt+0x3bb>
	if (lflag >= 2)
  8006f9:	83 f9 01             	cmp    $0x1,%ecx
  8006fc:	7e 18                	jle    800716 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8006fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800701:	8b 10                	mov    (%eax),%edx
  800703:	8b 48 04             	mov    0x4(%eax),%ecx
  800706:	8d 40 08             	lea    0x8(%eax),%eax
  800709:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80070c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800711:	e9 a9 00 00 00       	jmp    8007bf <vprintfmt+0x3bb>
	else if (lflag)
  800716:	85 c9                	test   %ecx,%ecx
  800718:	75 1a                	jne    800734 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  80071a:	8b 45 14             	mov    0x14(%ebp),%eax
  80071d:	8b 10                	mov    (%eax),%edx
  80071f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800724:	8d 40 04             	lea    0x4(%eax),%eax
  800727:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80072a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80072f:	e9 8b 00 00 00       	jmp    8007bf <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800734:	8b 45 14             	mov    0x14(%ebp),%eax
  800737:	8b 10                	mov    (%eax),%edx
  800739:	b9 00 00 00 00       	mov    $0x0,%ecx
  80073e:	8d 40 04             	lea    0x4(%eax),%eax
  800741:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800744:	b8 0a 00 00 00       	mov    $0xa,%eax
  800749:	eb 74                	jmp    8007bf <vprintfmt+0x3bb>
	if (lflag >= 2)
  80074b:	83 f9 01             	cmp    $0x1,%ecx
  80074e:	7e 15                	jle    800765 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  800750:	8b 45 14             	mov    0x14(%ebp),%eax
  800753:	8b 10                	mov    (%eax),%edx
  800755:	8b 48 04             	mov    0x4(%eax),%ecx
  800758:	8d 40 08             	lea    0x8(%eax),%eax
  80075b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80075e:	b8 08 00 00 00       	mov    $0x8,%eax
  800763:	eb 5a                	jmp    8007bf <vprintfmt+0x3bb>
	else if (lflag)
  800765:	85 c9                	test   %ecx,%ecx
  800767:	75 17                	jne    800780 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  800769:	8b 45 14             	mov    0x14(%ebp),%eax
  80076c:	8b 10                	mov    (%eax),%edx
  80076e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800773:	8d 40 04             	lea    0x4(%eax),%eax
  800776:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800779:	b8 08 00 00 00       	mov    $0x8,%eax
  80077e:	eb 3f                	jmp    8007bf <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800780:	8b 45 14             	mov    0x14(%ebp),%eax
  800783:	8b 10                	mov    (%eax),%edx
  800785:	b9 00 00 00 00       	mov    $0x0,%ecx
  80078a:	8d 40 04             	lea    0x4(%eax),%eax
  80078d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800790:	b8 08 00 00 00       	mov    $0x8,%eax
  800795:	eb 28                	jmp    8007bf <vprintfmt+0x3bb>
			putch('0', putdat);
  800797:	83 ec 08             	sub    $0x8,%esp
  80079a:	53                   	push   %ebx
  80079b:	6a 30                	push   $0x30
  80079d:	ff d6                	call   *%esi
			putch('x', putdat);
  80079f:	83 c4 08             	add    $0x8,%esp
  8007a2:	53                   	push   %ebx
  8007a3:	6a 78                	push   $0x78
  8007a5:	ff d6                	call   *%esi
			num = (unsigned long long)
  8007a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007aa:	8b 10                	mov    (%eax),%edx
  8007ac:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8007b1:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8007b4:	8d 40 04             	lea    0x4(%eax),%eax
  8007b7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007ba:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8007bf:	83 ec 0c             	sub    $0xc,%esp
  8007c2:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007c6:	57                   	push   %edi
  8007c7:	ff 75 e0             	pushl  -0x20(%ebp)
  8007ca:	50                   	push   %eax
  8007cb:	51                   	push   %ecx
  8007cc:	52                   	push   %edx
  8007cd:	89 da                	mov    %ebx,%edx
  8007cf:	89 f0                	mov    %esi,%eax
  8007d1:	e8 45 fb ff ff       	call   80031b <printnum>
			break;
  8007d6:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8007d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007dc:	83 c7 01             	add    $0x1,%edi
  8007df:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8007e3:	83 f8 25             	cmp    $0x25,%eax
  8007e6:	0f 84 2f fc ff ff    	je     80041b <vprintfmt+0x17>
			if (ch == '\0')
  8007ec:	85 c0                	test   %eax,%eax
  8007ee:	0f 84 8b 00 00 00    	je     80087f <vprintfmt+0x47b>
			putch(ch, putdat);
  8007f4:	83 ec 08             	sub    $0x8,%esp
  8007f7:	53                   	push   %ebx
  8007f8:	50                   	push   %eax
  8007f9:	ff d6                	call   *%esi
  8007fb:	83 c4 10             	add    $0x10,%esp
  8007fe:	eb dc                	jmp    8007dc <vprintfmt+0x3d8>
	if (lflag >= 2)
  800800:	83 f9 01             	cmp    $0x1,%ecx
  800803:	7e 15                	jle    80081a <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  800805:	8b 45 14             	mov    0x14(%ebp),%eax
  800808:	8b 10                	mov    (%eax),%edx
  80080a:	8b 48 04             	mov    0x4(%eax),%ecx
  80080d:	8d 40 08             	lea    0x8(%eax),%eax
  800810:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800813:	b8 10 00 00 00       	mov    $0x10,%eax
  800818:	eb a5                	jmp    8007bf <vprintfmt+0x3bb>
	else if (lflag)
  80081a:	85 c9                	test   %ecx,%ecx
  80081c:	75 17                	jne    800835 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  80081e:	8b 45 14             	mov    0x14(%ebp),%eax
  800821:	8b 10                	mov    (%eax),%edx
  800823:	b9 00 00 00 00       	mov    $0x0,%ecx
  800828:	8d 40 04             	lea    0x4(%eax),%eax
  80082b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80082e:	b8 10 00 00 00       	mov    $0x10,%eax
  800833:	eb 8a                	jmp    8007bf <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800835:	8b 45 14             	mov    0x14(%ebp),%eax
  800838:	8b 10                	mov    (%eax),%edx
  80083a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80083f:	8d 40 04             	lea    0x4(%eax),%eax
  800842:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800845:	b8 10 00 00 00       	mov    $0x10,%eax
  80084a:	e9 70 ff ff ff       	jmp    8007bf <vprintfmt+0x3bb>
			putch(ch, putdat);
  80084f:	83 ec 08             	sub    $0x8,%esp
  800852:	53                   	push   %ebx
  800853:	6a 25                	push   $0x25
  800855:	ff d6                	call   *%esi
			break;
  800857:	83 c4 10             	add    $0x10,%esp
  80085a:	e9 7a ff ff ff       	jmp    8007d9 <vprintfmt+0x3d5>
			putch('%', putdat);
  80085f:	83 ec 08             	sub    $0x8,%esp
  800862:	53                   	push   %ebx
  800863:	6a 25                	push   $0x25
  800865:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800867:	83 c4 10             	add    $0x10,%esp
  80086a:	89 f8                	mov    %edi,%eax
  80086c:	eb 03                	jmp    800871 <vprintfmt+0x46d>
  80086e:	83 e8 01             	sub    $0x1,%eax
  800871:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800875:	75 f7                	jne    80086e <vprintfmt+0x46a>
  800877:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80087a:	e9 5a ff ff ff       	jmp    8007d9 <vprintfmt+0x3d5>
}
  80087f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800882:	5b                   	pop    %ebx
  800883:	5e                   	pop    %esi
  800884:	5f                   	pop    %edi
  800885:	5d                   	pop    %ebp
  800886:	c3                   	ret    

00800887 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	83 ec 18             	sub    $0x18,%esp
  80088d:	8b 45 08             	mov    0x8(%ebp),%eax
  800890:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800893:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800896:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80089a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80089d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008a4:	85 c0                	test   %eax,%eax
  8008a6:	74 26                	je     8008ce <vsnprintf+0x47>
  8008a8:	85 d2                	test   %edx,%edx
  8008aa:	7e 22                	jle    8008ce <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008ac:	ff 75 14             	pushl  0x14(%ebp)
  8008af:	ff 75 10             	pushl  0x10(%ebp)
  8008b2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008b5:	50                   	push   %eax
  8008b6:	68 ca 03 80 00       	push   $0x8003ca
  8008bb:	e8 44 fb ff ff       	call   800404 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008c3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008c9:	83 c4 10             	add    $0x10,%esp
}
  8008cc:	c9                   	leave  
  8008cd:	c3                   	ret    
		return -E_INVAL;
  8008ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008d3:	eb f7                	jmp    8008cc <vsnprintf+0x45>

008008d5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008d5:	55                   	push   %ebp
  8008d6:	89 e5                	mov    %esp,%ebp
  8008d8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008db:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008de:	50                   	push   %eax
  8008df:	ff 75 10             	pushl  0x10(%ebp)
  8008e2:	ff 75 0c             	pushl  0xc(%ebp)
  8008e5:	ff 75 08             	pushl  0x8(%ebp)
  8008e8:	e8 9a ff ff ff       	call   800887 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008ed:	c9                   	leave  
  8008ee:	c3                   	ret    

008008ef <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008ef:	55                   	push   %ebp
  8008f0:	89 e5                	mov    %esp,%ebp
  8008f2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8008fa:	eb 03                	jmp    8008ff <strlen+0x10>
		n++;
  8008fc:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008ff:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800903:	75 f7                	jne    8008fc <strlen+0xd>
	return n;
}
  800905:	5d                   	pop    %ebp
  800906:	c3                   	ret    

00800907 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80090d:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800910:	b8 00 00 00 00       	mov    $0x0,%eax
  800915:	eb 03                	jmp    80091a <strnlen+0x13>
		n++;
  800917:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80091a:	39 d0                	cmp    %edx,%eax
  80091c:	74 06                	je     800924 <strnlen+0x1d>
  80091e:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800922:	75 f3                	jne    800917 <strnlen+0x10>
	return n;
}
  800924:	5d                   	pop    %ebp
  800925:	c3                   	ret    

00800926 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	53                   	push   %ebx
  80092a:	8b 45 08             	mov    0x8(%ebp),%eax
  80092d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800930:	89 c2                	mov    %eax,%edx
  800932:	83 c1 01             	add    $0x1,%ecx
  800935:	83 c2 01             	add    $0x1,%edx
  800938:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80093c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80093f:	84 db                	test   %bl,%bl
  800941:	75 ef                	jne    800932 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800943:	5b                   	pop    %ebx
  800944:	5d                   	pop    %ebp
  800945:	c3                   	ret    

00800946 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	53                   	push   %ebx
  80094a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80094d:	53                   	push   %ebx
  80094e:	e8 9c ff ff ff       	call   8008ef <strlen>
  800953:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800956:	ff 75 0c             	pushl  0xc(%ebp)
  800959:	01 d8                	add    %ebx,%eax
  80095b:	50                   	push   %eax
  80095c:	e8 c5 ff ff ff       	call   800926 <strcpy>
	return dst;
}
  800961:	89 d8                	mov    %ebx,%eax
  800963:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800966:	c9                   	leave  
  800967:	c3                   	ret    

00800968 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800968:	55                   	push   %ebp
  800969:	89 e5                	mov    %esp,%ebp
  80096b:	56                   	push   %esi
  80096c:	53                   	push   %ebx
  80096d:	8b 75 08             	mov    0x8(%ebp),%esi
  800970:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800973:	89 f3                	mov    %esi,%ebx
  800975:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800978:	89 f2                	mov    %esi,%edx
  80097a:	eb 0f                	jmp    80098b <strncpy+0x23>
		*dst++ = *src;
  80097c:	83 c2 01             	add    $0x1,%edx
  80097f:	0f b6 01             	movzbl (%ecx),%eax
  800982:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800985:	80 39 01             	cmpb   $0x1,(%ecx)
  800988:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80098b:	39 da                	cmp    %ebx,%edx
  80098d:	75 ed                	jne    80097c <strncpy+0x14>
	}
	return ret;
}
  80098f:	89 f0                	mov    %esi,%eax
  800991:	5b                   	pop    %ebx
  800992:	5e                   	pop    %esi
  800993:	5d                   	pop    %ebp
  800994:	c3                   	ret    

00800995 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	56                   	push   %esi
  800999:	53                   	push   %ebx
  80099a:	8b 75 08             	mov    0x8(%ebp),%esi
  80099d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8009a3:	89 f0                	mov    %esi,%eax
  8009a5:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009a9:	85 c9                	test   %ecx,%ecx
  8009ab:	75 0b                	jne    8009b8 <strlcpy+0x23>
  8009ad:	eb 17                	jmp    8009c6 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009af:	83 c2 01             	add    $0x1,%edx
  8009b2:	83 c0 01             	add    $0x1,%eax
  8009b5:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8009b8:	39 d8                	cmp    %ebx,%eax
  8009ba:	74 07                	je     8009c3 <strlcpy+0x2e>
  8009bc:	0f b6 0a             	movzbl (%edx),%ecx
  8009bf:	84 c9                	test   %cl,%cl
  8009c1:	75 ec                	jne    8009af <strlcpy+0x1a>
		*dst = '\0';
  8009c3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009c6:	29 f0                	sub    %esi,%eax
}
  8009c8:	5b                   	pop    %ebx
  8009c9:	5e                   	pop    %esi
  8009ca:	5d                   	pop    %ebp
  8009cb:	c3                   	ret    

008009cc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009cc:	55                   	push   %ebp
  8009cd:	89 e5                	mov    %esp,%ebp
  8009cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009d2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009d5:	eb 06                	jmp    8009dd <strcmp+0x11>
		p++, q++;
  8009d7:	83 c1 01             	add    $0x1,%ecx
  8009da:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009dd:	0f b6 01             	movzbl (%ecx),%eax
  8009e0:	84 c0                	test   %al,%al
  8009e2:	74 04                	je     8009e8 <strcmp+0x1c>
  8009e4:	3a 02                	cmp    (%edx),%al
  8009e6:	74 ef                	je     8009d7 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009e8:	0f b6 c0             	movzbl %al,%eax
  8009eb:	0f b6 12             	movzbl (%edx),%edx
  8009ee:	29 d0                	sub    %edx,%eax
}
  8009f0:	5d                   	pop    %ebp
  8009f1:	c3                   	ret    

008009f2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009f2:	55                   	push   %ebp
  8009f3:	89 e5                	mov    %esp,%ebp
  8009f5:	53                   	push   %ebx
  8009f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009fc:	89 c3                	mov    %eax,%ebx
  8009fe:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a01:	eb 06                	jmp    800a09 <strncmp+0x17>
		n--, p++, q++;
  800a03:	83 c0 01             	add    $0x1,%eax
  800a06:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a09:	39 d8                	cmp    %ebx,%eax
  800a0b:	74 16                	je     800a23 <strncmp+0x31>
  800a0d:	0f b6 08             	movzbl (%eax),%ecx
  800a10:	84 c9                	test   %cl,%cl
  800a12:	74 04                	je     800a18 <strncmp+0x26>
  800a14:	3a 0a                	cmp    (%edx),%cl
  800a16:	74 eb                	je     800a03 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a18:	0f b6 00             	movzbl (%eax),%eax
  800a1b:	0f b6 12             	movzbl (%edx),%edx
  800a1e:	29 d0                	sub    %edx,%eax
}
  800a20:	5b                   	pop    %ebx
  800a21:	5d                   	pop    %ebp
  800a22:	c3                   	ret    
		return 0;
  800a23:	b8 00 00 00 00       	mov    $0x0,%eax
  800a28:	eb f6                	jmp    800a20 <strncmp+0x2e>

00800a2a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a2a:	55                   	push   %ebp
  800a2b:	89 e5                	mov    %esp,%ebp
  800a2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a30:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a34:	0f b6 10             	movzbl (%eax),%edx
  800a37:	84 d2                	test   %dl,%dl
  800a39:	74 09                	je     800a44 <strchr+0x1a>
		if (*s == c)
  800a3b:	38 ca                	cmp    %cl,%dl
  800a3d:	74 0a                	je     800a49 <strchr+0x1f>
	for (; *s; s++)
  800a3f:	83 c0 01             	add    $0x1,%eax
  800a42:	eb f0                	jmp    800a34 <strchr+0xa>
			return (char *) s;
	return 0;
  800a44:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a49:	5d                   	pop    %ebp
  800a4a:	c3                   	ret    

00800a4b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a4b:	55                   	push   %ebp
  800a4c:	89 e5                	mov    %esp,%ebp
  800a4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a51:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a55:	eb 03                	jmp    800a5a <strfind+0xf>
  800a57:	83 c0 01             	add    $0x1,%eax
  800a5a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a5d:	38 ca                	cmp    %cl,%dl
  800a5f:	74 04                	je     800a65 <strfind+0x1a>
  800a61:	84 d2                	test   %dl,%dl
  800a63:	75 f2                	jne    800a57 <strfind+0xc>
			break;
	return (char *) s;
}
  800a65:	5d                   	pop    %ebp
  800a66:	c3                   	ret    

00800a67 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a67:	55                   	push   %ebp
  800a68:	89 e5                	mov    %esp,%ebp
  800a6a:	57                   	push   %edi
  800a6b:	56                   	push   %esi
  800a6c:	53                   	push   %ebx
  800a6d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a70:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a73:	85 c9                	test   %ecx,%ecx
  800a75:	74 13                	je     800a8a <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a77:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a7d:	75 05                	jne    800a84 <memset+0x1d>
  800a7f:	f6 c1 03             	test   $0x3,%cl
  800a82:	74 0d                	je     800a91 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a84:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a87:	fc                   	cld    
  800a88:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a8a:	89 f8                	mov    %edi,%eax
  800a8c:	5b                   	pop    %ebx
  800a8d:	5e                   	pop    %esi
  800a8e:	5f                   	pop    %edi
  800a8f:	5d                   	pop    %ebp
  800a90:	c3                   	ret    
		c &= 0xFF;
  800a91:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a95:	89 d3                	mov    %edx,%ebx
  800a97:	c1 e3 08             	shl    $0x8,%ebx
  800a9a:	89 d0                	mov    %edx,%eax
  800a9c:	c1 e0 18             	shl    $0x18,%eax
  800a9f:	89 d6                	mov    %edx,%esi
  800aa1:	c1 e6 10             	shl    $0x10,%esi
  800aa4:	09 f0                	or     %esi,%eax
  800aa6:	09 c2                	or     %eax,%edx
  800aa8:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800aaa:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800aad:	89 d0                	mov    %edx,%eax
  800aaf:	fc                   	cld    
  800ab0:	f3 ab                	rep stos %eax,%es:(%edi)
  800ab2:	eb d6                	jmp    800a8a <memset+0x23>

00800ab4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ab4:	55                   	push   %ebp
  800ab5:	89 e5                	mov    %esp,%ebp
  800ab7:	57                   	push   %edi
  800ab8:	56                   	push   %esi
  800ab9:	8b 45 08             	mov    0x8(%ebp),%eax
  800abc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800abf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ac2:	39 c6                	cmp    %eax,%esi
  800ac4:	73 35                	jae    800afb <memmove+0x47>
  800ac6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ac9:	39 c2                	cmp    %eax,%edx
  800acb:	76 2e                	jbe    800afb <memmove+0x47>
		s += n;
		d += n;
  800acd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad0:	89 d6                	mov    %edx,%esi
  800ad2:	09 fe                	or     %edi,%esi
  800ad4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ada:	74 0c                	je     800ae8 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800adc:	83 ef 01             	sub    $0x1,%edi
  800adf:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800ae2:	fd                   	std    
  800ae3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ae5:	fc                   	cld    
  800ae6:	eb 21                	jmp    800b09 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ae8:	f6 c1 03             	test   $0x3,%cl
  800aeb:	75 ef                	jne    800adc <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800aed:	83 ef 04             	sub    $0x4,%edi
  800af0:	8d 72 fc             	lea    -0x4(%edx),%esi
  800af3:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800af6:	fd                   	std    
  800af7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800af9:	eb ea                	jmp    800ae5 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800afb:	89 f2                	mov    %esi,%edx
  800afd:	09 c2                	or     %eax,%edx
  800aff:	f6 c2 03             	test   $0x3,%dl
  800b02:	74 09                	je     800b0d <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b04:	89 c7                	mov    %eax,%edi
  800b06:	fc                   	cld    
  800b07:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b09:	5e                   	pop    %esi
  800b0a:	5f                   	pop    %edi
  800b0b:	5d                   	pop    %ebp
  800b0c:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b0d:	f6 c1 03             	test   $0x3,%cl
  800b10:	75 f2                	jne    800b04 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b12:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b15:	89 c7                	mov    %eax,%edi
  800b17:	fc                   	cld    
  800b18:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b1a:	eb ed                	jmp    800b09 <memmove+0x55>

00800b1c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b1f:	ff 75 10             	pushl  0x10(%ebp)
  800b22:	ff 75 0c             	pushl  0xc(%ebp)
  800b25:	ff 75 08             	pushl  0x8(%ebp)
  800b28:	e8 87 ff ff ff       	call   800ab4 <memmove>
}
  800b2d:	c9                   	leave  
  800b2e:	c3                   	ret    

00800b2f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	56                   	push   %esi
  800b33:	53                   	push   %ebx
  800b34:	8b 45 08             	mov    0x8(%ebp),%eax
  800b37:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b3a:	89 c6                	mov    %eax,%esi
  800b3c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b3f:	39 f0                	cmp    %esi,%eax
  800b41:	74 1c                	je     800b5f <memcmp+0x30>
		if (*s1 != *s2)
  800b43:	0f b6 08             	movzbl (%eax),%ecx
  800b46:	0f b6 1a             	movzbl (%edx),%ebx
  800b49:	38 d9                	cmp    %bl,%cl
  800b4b:	75 08                	jne    800b55 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b4d:	83 c0 01             	add    $0x1,%eax
  800b50:	83 c2 01             	add    $0x1,%edx
  800b53:	eb ea                	jmp    800b3f <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b55:	0f b6 c1             	movzbl %cl,%eax
  800b58:	0f b6 db             	movzbl %bl,%ebx
  800b5b:	29 d8                	sub    %ebx,%eax
  800b5d:	eb 05                	jmp    800b64 <memcmp+0x35>
	}

	return 0;
  800b5f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b64:	5b                   	pop    %ebx
  800b65:	5e                   	pop    %esi
  800b66:	5d                   	pop    %ebp
  800b67:	c3                   	ret    

00800b68 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b68:	55                   	push   %ebp
  800b69:	89 e5                	mov    %esp,%ebp
  800b6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b71:	89 c2                	mov    %eax,%edx
  800b73:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b76:	39 d0                	cmp    %edx,%eax
  800b78:	73 09                	jae    800b83 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b7a:	38 08                	cmp    %cl,(%eax)
  800b7c:	74 05                	je     800b83 <memfind+0x1b>
	for (; s < ends; s++)
  800b7e:	83 c0 01             	add    $0x1,%eax
  800b81:	eb f3                	jmp    800b76 <memfind+0xe>
			break;
	return (void *) s;
}
  800b83:	5d                   	pop    %ebp
  800b84:	c3                   	ret    

00800b85 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	57                   	push   %edi
  800b89:	56                   	push   %esi
  800b8a:	53                   	push   %ebx
  800b8b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b8e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b91:	eb 03                	jmp    800b96 <strtol+0x11>
		s++;
  800b93:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b96:	0f b6 01             	movzbl (%ecx),%eax
  800b99:	3c 20                	cmp    $0x20,%al
  800b9b:	74 f6                	je     800b93 <strtol+0xe>
  800b9d:	3c 09                	cmp    $0x9,%al
  800b9f:	74 f2                	je     800b93 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800ba1:	3c 2b                	cmp    $0x2b,%al
  800ba3:	74 2e                	je     800bd3 <strtol+0x4e>
	int neg = 0;
  800ba5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800baa:	3c 2d                	cmp    $0x2d,%al
  800bac:	74 2f                	je     800bdd <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bae:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bb4:	75 05                	jne    800bbb <strtol+0x36>
  800bb6:	80 39 30             	cmpb   $0x30,(%ecx)
  800bb9:	74 2c                	je     800be7 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bbb:	85 db                	test   %ebx,%ebx
  800bbd:	75 0a                	jne    800bc9 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bbf:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800bc4:	80 39 30             	cmpb   $0x30,(%ecx)
  800bc7:	74 28                	je     800bf1 <strtol+0x6c>
		base = 10;
  800bc9:	b8 00 00 00 00       	mov    $0x0,%eax
  800bce:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bd1:	eb 50                	jmp    800c23 <strtol+0x9e>
		s++;
  800bd3:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800bd6:	bf 00 00 00 00       	mov    $0x0,%edi
  800bdb:	eb d1                	jmp    800bae <strtol+0x29>
		s++, neg = 1;
  800bdd:	83 c1 01             	add    $0x1,%ecx
  800be0:	bf 01 00 00 00       	mov    $0x1,%edi
  800be5:	eb c7                	jmp    800bae <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800be7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800beb:	74 0e                	je     800bfb <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800bed:	85 db                	test   %ebx,%ebx
  800bef:	75 d8                	jne    800bc9 <strtol+0x44>
		s++, base = 8;
  800bf1:	83 c1 01             	add    $0x1,%ecx
  800bf4:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bf9:	eb ce                	jmp    800bc9 <strtol+0x44>
		s += 2, base = 16;
  800bfb:	83 c1 02             	add    $0x2,%ecx
  800bfe:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c03:	eb c4                	jmp    800bc9 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800c05:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c08:	89 f3                	mov    %esi,%ebx
  800c0a:	80 fb 19             	cmp    $0x19,%bl
  800c0d:	77 29                	ja     800c38 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800c0f:	0f be d2             	movsbl %dl,%edx
  800c12:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c15:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c18:	7d 30                	jge    800c4a <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800c1a:	83 c1 01             	add    $0x1,%ecx
  800c1d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c21:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c23:	0f b6 11             	movzbl (%ecx),%edx
  800c26:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c29:	89 f3                	mov    %esi,%ebx
  800c2b:	80 fb 09             	cmp    $0x9,%bl
  800c2e:	77 d5                	ja     800c05 <strtol+0x80>
			dig = *s - '0';
  800c30:	0f be d2             	movsbl %dl,%edx
  800c33:	83 ea 30             	sub    $0x30,%edx
  800c36:	eb dd                	jmp    800c15 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800c38:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c3b:	89 f3                	mov    %esi,%ebx
  800c3d:	80 fb 19             	cmp    $0x19,%bl
  800c40:	77 08                	ja     800c4a <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c42:	0f be d2             	movsbl %dl,%edx
  800c45:	83 ea 37             	sub    $0x37,%edx
  800c48:	eb cb                	jmp    800c15 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c4a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c4e:	74 05                	je     800c55 <strtol+0xd0>
		*endptr = (char *) s;
  800c50:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c53:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c55:	89 c2                	mov    %eax,%edx
  800c57:	f7 da                	neg    %edx
  800c59:	85 ff                	test   %edi,%edi
  800c5b:	0f 45 c2             	cmovne %edx,%eax
}
  800c5e:	5b                   	pop    %ebx
  800c5f:	5e                   	pop    %esi
  800c60:	5f                   	pop    %edi
  800c61:	5d                   	pop    %ebp
  800c62:	c3                   	ret    

00800c63 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	57                   	push   %edi
  800c67:	56                   	push   %esi
  800c68:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c69:	b8 00 00 00 00       	mov    $0x0,%eax
  800c6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c74:	89 c3                	mov    %eax,%ebx
  800c76:	89 c7                	mov    %eax,%edi
  800c78:	89 c6                	mov    %eax,%esi
  800c7a:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c7c:	5b                   	pop    %ebx
  800c7d:	5e                   	pop    %esi
  800c7e:	5f                   	pop    %edi
  800c7f:	5d                   	pop    %ebp
  800c80:	c3                   	ret    

00800c81 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c81:	55                   	push   %ebp
  800c82:	89 e5                	mov    %esp,%ebp
  800c84:	57                   	push   %edi
  800c85:	56                   	push   %esi
  800c86:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c87:	ba 00 00 00 00       	mov    $0x0,%edx
  800c8c:	b8 01 00 00 00       	mov    $0x1,%eax
  800c91:	89 d1                	mov    %edx,%ecx
  800c93:	89 d3                	mov    %edx,%ebx
  800c95:	89 d7                	mov    %edx,%edi
  800c97:	89 d6                	mov    %edx,%esi
  800c99:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c9b:	5b                   	pop    %ebx
  800c9c:	5e                   	pop    %esi
  800c9d:	5f                   	pop    %edi
  800c9e:	5d                   	pop    %ebp
  800c9f:	c3                   	ret    

00800ca0 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ca0:	55                   	push   %ebp
  800ca1:	89 e5                	mov    %esp,%ebp
  800ca3:	57                   	push   %edi
  800ca4:	56                   	push   %esi
  800ca5:	53                   	push   %ebx
  800ca6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ca9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cae:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb1:	b8 03 00 00 00       	mov    $0x3,%eax
  800cb6:	89 cb                	mov    %ecx,%ebx
  800cb8:	89 cf                	mov    %ecx,%edi
  800cba:	89 ce                	mov    %ecx,%esi
  800cbc:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cbe:	85 c0                	test   %eax,%eax
  800cc0:	7f 08                	jg     800cca <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc5:	5b                   	pop    %ebx
  800cc6:	5e                   	pop    %esi
  800cc7:	5f                   	pop    %edi
  800cc8:	5d                   	pop    %ebp
  800cc9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cca:	83 ec 0c             	sub    $0xc,%esp
  800ccd:	50                   	push   %eax
  800cce:	6a 03                	push   $0x3
  800cd0:	68 9f 27 80 00       	push   $0x80279f
  800cd5:	6a 23                	push   $0x23
  800cd7:	68 bc 27 80 00       	push   $0x8027bc
  800cdc:	e8 4b f5 ff ff       	call   80022c <_panic>

00800ce1 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ce1:	55                   	push   %ebp
  800ce2:	89 e5                	mov    %esp,%ebp
  800ce4:	57                   	push   %edi
  800ce5:	56                   	push   %esi
  800ce6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ce7:	ba 00 00 00 00       	mov    $0x0,%edx
  800cec:	b8 02 00 00 00       	mov    $0x2,%eax
  800cf1:	89 d1                	mov    %edx,%ecx
  800cf3:	89 d3                	mov    %edx,%ebx
  800cf5:	89 d7                	mov    %edx,%edi
  800cf7:	89 d6                	mov    %edx,%esi
  800cf9:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cfb:	5b                   	pop    %ebx
  800cfc:	5e                   	pop    %esi
  800cfd:	5f                   	pop    %edi
  800cfe:	5d                   	pop    %ebp
  800cff:	c3                   	ret    

00800d00 <sys_yield>:

void
sys_yield(void)
{
  800d00:	55                   	push   %ebp
  800d01:	89 e5                	mov    %esp,%ebp
  800d03:	57                   	push   %edi
  800d04:	56                   	push   %esi
  800d05:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d06:	ba 00 00 00 00       	mov    $0x0,%edx
  800d0b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d10:	89 d1                	mov    %edx,%ecx
  800d12:	89 d3                	mov    %edx,%ebx
  800d14:	89 d7                	mov    %edx,%edi
  800d16:	89 d6                	mov    %edx,%esi
  800d18:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d1a:	5b                   	pop    %ebx
  800d1b:	5e                   	pop    %esi
  800d1c:	5f                   	pop    %edi
  800d1d:	5d                   	pop    %ebp
  800d1e:	c3                   	ret    

00800d1f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d1f:	55                   	push   %ebp
  800d20:	89 e5                	mov    %esp,%ebp
  800d22:	57                   	push   %edi
  800d23:	56                   	push   %esi
  800d24:	53                   	push   %ebx
  800d25:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d28:	be 00 00 00 00       	mov    $0x0,%esi
  800d2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d33:	b8 04 00 00 00       	mov    $0x4,%eax
  800d38:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d3b:	89 f7                	mov    %esi,%edi
  800d3d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d3f:	85 c0                	test   %eax,%eax
  800d41:	7f 08                	jg     800d4b <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d46:	5b                   	pop    %ebx
  800d47:	5e                   	pop    %esi
  800d48:	5f                   	pop    %edi
  800d49:	5d                   	pop    %ebp
  800d4a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4b:	83 ec 0c             	sub    $0xc,%esp
  800d4e:	50                   	push   %eax
  800d4f:	6a 04                	push   $0x4
  800d51:	68 9f 27 80 00       	push   $0x80279f
  800d56:	6a 23                	push   $0x23
  800d58:	68 bc 27 80 00       	push   $0x8027bc
  800d5d:	e8 ca f4 ff ff       	call   80022c <_panic>

00800d62 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d62:	55                   	push   %ebp
  800d63:	89 e5                	mov    %esp,%ebp
  800d65:	57                   	push   %edi
  800d66:	56                   	push   %esi
  800d67:	53                   	push   %ebx
  800d68:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d71:	b8 05 00 00 00       	mov    $0x5,%eax
  800d76:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d79:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d7c:	8b 75 18             	mov    0x18(%ebp),%esi
  800d7f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d81:	85 c0                	test   %eax,%eax
  800d83:	7f 08                	jg     800d8d <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d85:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d88:	5b                   	pop    %ebx
  800d89:	5e                   	pop    %esi
  800d8a:	5f                   	pop    %edi
  800d8b:	5d                   	pop    %ebp
  800d8c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8d:	83 ec 0c             	sub    $0xc,%esp
  800d90:	50                   	push   %eax
  800d91:	6a 05                	push   $0x5
  800d93:	68 9f 27 80 00       	push   $0x80279f
  800d98:	6a 23                	push   $0x23
  800d9a:	68 bc 27 80 00       	push   $0x8027bc
  800d9f:	e8 88 f4 ff ff       	call   80022c <_panic>

00800da4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800da4:	55                   	push   %ebp
  800da5:	89 e5                	mov    %esp,%ebp
  800da7:	57                   	push   %edi
  800da8:	56                   	push   %esi
  800da9:	53                   	push   %ebx
  800daa:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dad:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db2:	8b 55 08             	mov    0x8(%ebp),%edx
  800db5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db8:	b8 06 00 00 00       	mov    $0x6,%eax
  800dbd:	89 df                	mov    %ebx,%edi
  800dbf:	89 de                	mov    %ebx,%esi
  800dc1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dc3:	85 c0                	test   %eax,%eax
  800dc5:	7f 08                	jg     800dcf <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dc7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dca:	5b                   	pop    %ebx
  800dcb:	5e                   	pop    %esi
  800dcc:	5f                   	pop    %edi
  800dcd:	5d                   	pop    %ebp
  800dce:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dcf:	83 ec 0c             	sub    $0xc,%esp
  800dd2:	50                   	push   %eax
  800dd3:	6a 06                	push   $0x6
  800dd5:	68 9f 27 80 00       	push   $0x80279f
  800dda:	6a 23                	push   $0x23
  800ddc:	68 bc 27 80 00       	push   $0x8027bc
  800de1:	e8 46 f4 ff ff       	call   80022c <_panic>

00800de6 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800de6:	55                   	push   %ebp
  800de7:	89 e5                	mov    %esp,%ebp
  800de9:	57                   	push   %edi
  800dea:	56                   	push   %esi
  800deb:	53                   	push   %ebx
  800dec:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800def:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df4:	8b 55 08             	mov    0x8(%ebp),%edx
  800df7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfa:	b8 08 00 00 00       	mov    $0x8,%eax
  800dff:	89 df                	mov    %ebx,%edi
  800e01:	89 de                	mov    %ebx,%esi
  800e03:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e05:	85 c0                	test   %eax,%eax
  800e07:	7f 08                	jg     800e11 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e09:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e0c:	5b                   	pop    %ebx
  800e0d:	5e                   	pop    %esi
  800e0e:	5f                   	pop    %edi
  800e0f:	5d                   	pop    %ebp
  800e10:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e11:	83 ec 0c             	sub    $0xc,%esp
  800e14:	50                   	push   %eax
  800e15:	6a 08                	push   $0x8
  800e17:	68 9f 27 80 00       	push   $0x80279f
  800e1c:	6a 23                	push   $0x23
  800e1e:	68 bc 27 80 00       	push   $0x8027bc
  800e23:	e8 04 f4 ff ff       	call   80022c <_panic>

00800e28 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e28:	55                   	push   %ebp
  800e29:	89 e5                	mov    %esp,%ebp
  800e2b:	57                   	push   %edi
  800e2c:	56                   	push   %esi
  800e2d:	53                   	push   %ebx
  800e2e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e31:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e36:	8b 55 08             	mov    0x8(%ebp),%edx
  800e39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3c:	b8 09 00 00 00       	mov    $0x9,%eax
  800e41:	89 df                	mov    %ebx,%edi
  800e43:	89 de                	mov    %ebx,%esi
  800e45:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e47:	85 c0                	test   %eax,%eax
  800e49:	7f 08                	jg     800e53 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e4e:	5b                   	pop    %ebx
  800e4f:	5e                   	pop    %esi
  800e50:	5f                   	pop    %edi
  800e51:	5d                   	pop    %ebp
  800e52:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e53:	83 ec 0c             	sub    $0xc,%esp
  800e56:	50                   	push   %eax
  800e57:	6a 09                	push   $0x9
  800e59:	68 9f 27 80 00       	push   $0x80279f
  800e5e:	6a 23                	push   $0x23
  800e60:	68 bc 27 80 00       	push   $0x8027bc
  800e65:	e8 c2 f3 ff ff       	call   80022c <_panic>

00800e6a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e6a:	55                   	push   %ebp
  800e6b:	89 e5                	mov    %esp,%ebp
  800e6d:	57                   	push   %edi
  800e6e:	56                   	push   %esi
  800e6f:	53                   	push   %ebx
  800e70:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e73:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e78:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e83:	89 df                	mov    %ebx,%edi
  800e85:	89 de                	mov    %ebx,%esi
  800e87:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e89:	85 c0                	test   %eax,%eax
  800e8b:	7f 08                	jg     800e95 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e90:	5b                   	pop    %ebx
  800e91:	5e                   	pop    %esi
  800e92:	5f                   	pop    %edi
  800e93:	5d                   	pop    %ebp
  800e94:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e95:	83 ec 0c             	sub    $0xc,%esp
  800e98:	50                   	push   %eax
  800e99:	6a 0a                	push   $0xa
  800e9b:	68 9f 27 80 00       	push   $0x80279f
  800ea0:	6a 23                	push   $0x23
  800ea2:	68 bc 27 80 00       	push   $0x8027bc
  800ea7:	e8 80 f3 ff ff       	call   80022c <_panic>

00800eac <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	57                   	push   %edi
  800eb0:	56                   	push   %esi
  800eb1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800eb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb8:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ebd:	be 00 00 00 00       	mov    $0x0,%esi
  800ec2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ec5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ec8:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800eca:	5b                   	pop    %ebx
  800ecb:	5e                   	pop    %esi
  800ecc:	5f                   	pop    %edi
  800ecd:	5d                   	pop    %ebp
  800ece:	c3                   	ret    

00800ecf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ecf:	55                   	push   %ebp
  800ed0:	89 e5                	mov    %esp,%ebp
  800ed2:	57                   	push   %edi
  800ed3:	56                   	push   %esi
  800ed4:	53                   	push   %ebx
  800ed5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ed8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800edd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee0:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ee5:	89 cb                	mov    %ecx,%ebx
  800ee7:	89 cf                	mov    %ecx,%edi
  800ee9:	89 ce                	mov    %ecx,%esi
  800eeb:	cd 30                	int    $0x30
	if(check && ret > 0)
  800eed:	85 c0                	test   %eax,%eax
  800eef:	7f 08                	jg     800ef9 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ef1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ef4:	5b                   	pop    %ebx
  800ef5:	5e                   	pop    %esi
  800ef6:	5f                   	pop    %edi
  800ef7:	5d                   	pop    %ebp
  800ef8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef9:	83 ec 0c             	sub    $0xc,%esp
  800efc:	50                   	push   %eax
  800efd:	6a 0d                	push   $0xd
  800eff:	68 9f 27 80 00       	push   $0x80279f
  800f04:	6a 23                	push   $0x23
  800f06:	68 bc 27 80 00       	push   $0x8027bc
  800f0b:	e8 1c f3 ff ff       	call   80022c <_panic>

00800f10 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f10:	55                   	push   %ebp
  800f11:	89 e5                	mov    %esp,%ebp
  800f13:	56                   	push   %esi
  800f14:	53                   	push   %ebx
  800f15:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f18:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if((err&FEC_WR)==0 || (uvpt[PGNUM(addr)]&(PTE_W|PTE_COW))==0){
  800f1a:	8b 40 04             	mov    0x4(%eax),%eax
  800f1d:	83 e0 02             	and    $0x2,%eax
  800f20:	0f 84 82 00 00 00    	je     800fa8 <pgfault+0x98>
  800f26:	89 da                	mov    %ebx,%edx
  800f28:	c1 ea 0c             	shr    $0xc,%edx
  800f2b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f32:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800f38:	74 6e                	je     800fa8 <pgfault+0x98>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        envid_t envid = sys_getenvid();
  800f3a:	e8 a2 fd ff ff       	call   800ce1 <sys_getenvid>
  800f3f:	89 c6                	mov    %eax,%esi
	r = sys_page_alloc(envid,(void *)PFTEMP,PTE_P|PTE_W|PTE_U);
  800f41:	83 ec 04             	sub    $0x4,%esp
  800f44:	6a 07                	push   $0x7
  800f46:	68 00 f0 7f 00       	push   $0x7ff000
  800f4b:	50                   	push   %eax
  800f4c:	e8 ce fd ff ff       	call   800d1f <sys_page_alloc>
	if(r<0) panic("pgfault:page allocation failed %e",r);
  800f51:	83 c4 10             	add    $0x10,%esp
  800f54:	85 c0                	test   %eax,%eax
  800f56:	78 72                	js     800fca <pgfault+0xba>

	addr = ROUNDDOWN(addr,PGSIZE);
  800f58:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy((void *)PFTEMP,(const void *)addr,PGSIZE);
  800f5e:	83 ec 04             	sub    $0x4,%esp
  800f61:	68 00 10 00 00       	push   $0x1000
  800f66:	53                   	push   %ebx
  800f67:	68 00 f0 7f 00       	push   $0x7ff000
  800f6c:	e8 ab fb ff ff       	call   800b1c <memcpy>

	if(sys_page_map(envid,(void *)PFTEMP, envid,addr,PTE_P|PTE_W|PTE_U)<0)
  800f71:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f78:	53                   	push   %ebx
  800f79:	56                   	push   %esi
  800f7a:	68 00 f0 7f 00       	push   $0x7ff000
  800f7f:	56                   	push   %esi
  800f80:	e8 dd fd ff ff       	call   800d62 <sys_page_map>
  800f85:	83 c4 20             	add    $0x20,%esp
  800f88:	85 c0                	test   %eax,%eax
  800f8a:	78 50                	js     800fdc <pgfault+0xcc>
		panic("pgfault:page map failed\n");
	if(sys_page_unmap(envid,(void *)PFTEMP)<0)
  800f8c:	83 ec 08             	sub    $0x8,%esp
  800f8f:	68 00 f0 7f 00       	push   $0x7ff000
  800f94:	56                   	push   %esi
  800f95:	e8 0a fe ff ff       	call   800da4 <sys_page_unmap>
  800f9a:	83 c4 10             	add    $0x10,%esp
  800f9d:	85 c0                	test   %eax,%eax
  800f9f:	78 4f                	js     800ff0 <pgfault+0xe0>
		panic("pgfault: page upmap failed\n");
       //	panic("pgfault not implemented");
}
  800fa1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fa4:	5b                   	pop    %ebx
  800fa5:	5e                   	pop    %esi
  800fa6:	5d                   	pop    %ebp
  800fa7:	c3                   	ret    
		cprintf("Where is the error %d\n",err&FEC_WR);
  800fa8:	83 ec 08             	sub    $0x8,%esp
  800fab:	50                   	push   %eax
  800fac:	68 ca 27 80 00       	push   $0x8027ca
  800fb1:	e8 51 f3 ff ff       	call   800307 <cprintf>
		panic("pgfault:invalid user trap");
  800fb6:	83 c4 0c             	add    $0xc,%esp
  800fb9:	68 e1 27 80 00       	push   $0x8027e1
  800fbe:	6a 1e                	push   $0x1e
  800fc0:	68 fb 27 80 00       	push   $0x8027fb
  800fc5:	e8 62 f2 ff ff       	call   80022c <_panic>
	if(r<0) panic("pgfault:page allocation failed %e",r);
  800fca:	50                   	push   %eax
  800fcb:	68 e8 28 80 00       	push   $0x8028e8
  800fd0:	6a 29                	push   $0x29
  800fd2:	68 fb 27 80 00       	push   $0x8027fb
  800fd7:	e8 50 f2 ff ff       	call   80022c <_panic>
		panic("pgfault:page map failed\n");
  800fdc:	83 ec 04             	sub    $0x4,%esp
  800fdf:	68 06 28 80 00       	push   $0x802806
  800fe4:	6a 2f                	push   $0x2f
  800fe6:	68 fb 27 80 00       	push   $0x8027fb
  800feb:	e8 3c f2 ff ff       	call   80022c <_panic>
		panic("pgfault: page upmap failed\n");
  800ff0:	83 ec 04             	sub    $0x4,%esp
  800ff3:	68 1f 28 80 00       	push   $0x80281f
  800ff8:	6a 31                	push   $0x31
  800ffa:	68 fb 27 80 00       	push   $0x8027fb
  800fff:	e8 28 f2 ff ff       	call   80022c <_panic>

00801004 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801004:	55                   	push   %ebp
  801005:	89 e5                	mov    %esp,%ebp
  801007:	57                   	push   %edi
  801008:	56                   	push   %esi
  801009:	53                   	push   %ebx
  80100a:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	set_pgfault_handler(pgfault);
  80100d:	68 10 0f 80 00       	push   $0x800f10
  801012:	e8 04 0f 00 00       	call   801f1b <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801017:	b8 07 00 00 00       	mov    $0x7,%eax
  80101c:	cd 30                	int    $0x30
  80101e:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801021:	89 45 e0             	mov    %eax,-0x20(%ebp)
       
	envid_t envid = sys_exofork();
	uintptr_t addr;
  
	if(envid<0) panic("sys_exofork failed\n");
  801024:	83 c4 10             	add    $0x10,%esp
  801027:	85 c0                	test   %eax,%eax
  801029:	78 27                	js     801052 <fork+0x4e>
	if(envid==0){
	  thisenv = &envs[ENVX(sys_getenvid())];
	  return 0;
	}

	for(addr=(uintptr_t)UTEXT; addr<USTACKTOP;addr+=PGSIZE){
  80102b:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if(envid==0){
  801030:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801034:	75 5e                	jne    801094 <fork+0x90>
	  thisenv = &envs[ENVX(sys_getenvid())];
  801036:	e8 a6 fc ff ff       	call   800ce1 <sys_getenvid>
  80103b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801040:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801043:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801048:	a3 20 44 80 00       	mov    %eax,0x804420
	  return 0;
  80104d:	e9 fc 00 00 00       	jmp    80114e <fork+0x14a>
	if(envid<0) panic("sys_exofork failed\n");
  801052:	83 ec 04             	sub    $0x4,%esp
  801055:	68 3b 28 80 00       	push   $0x80283b
  80105a:	6a 77                	push   $0x77
  80105c:	68 fb 27 80 00       	push   $0x8027fb
  801061:	e8 c6 f1 ff ff       	call   80022c <_panic>
          if((r=sys_page_map(parent_envid,va,envid,va,uvpt[pn]&PTE_SYSCALL))<0)
  801066:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80106d:	83 ec 0c             	sub    $0xc,%esp
  801070:	25 07 0e 00 00       	and    $0xe07,%eax
  801075:	50                   	push   %eax
  801076:	57                   	push   %edi
  801077:	ff 75 e0             	pushl  -0x20(%ebp)
  80107a:	57                   	push   %edi
  80107b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80107e:	e8 df fc ff ff       	call   800d62 <sys_page_map>
  801083:	83 c4 20             	add    $0x20,%esp
	for(addr=(uintptr_t)UTEXT; addr<USTACKTOP;addr+=PGSIZE){
  801086:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80108c:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801092:	74 76                	je     80110a <fork+0x106>
	   if((uvpd[PDX(addr)]&PTE_P) && uvpt[PGNUM(addr)] & PTE_P)
  801094:	89 d8                	mov    %ebx,%eax
  801096:	c1 e8 16             	shr    $0x16,%eax
  801099:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010a0:	a8 01                	test   $0x1,%al
  8010a2:	74 e2                	je     801086 <fork+0x82>
  8010a4:	89 de                	mov    %ebx,%esi
  8010a6:	c1 ee 0c             	shr    $0xc,%esi
  8010a9:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010b0:	a8 01                	test   $0x1,%al
  8010b2:	74 d2                	je     801086 <fork+0x82>
        envid_t parent_envid = sys_getenvid();
  8010b4:	e8 28 fc ff ff       	call   800ce1 <sys_getenvid>
  8010b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	void *va = (void *)(pn*PGSIZE);
  8010bc:	89 f7                	mov    %esi,%edi
  8010be:	c1 e7 0c             	shl    $0xc,%edi
        if(uvpt[pn] & PTE_SHARE){
  8010c1:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010c8:	f6 c4 04             	test   $0x4,%ah
  8010cb:	75 99                	jne    801066 <fork+0x62>
	if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)){
  8010cd:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010d4:	a8 02                	test   $0x2,%al
  8010d6:	0f 85 ed 00 00 00    	jne    8011c9 <fork+0x1c5>
  8010dc:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010e3:	f6 c4 08             	test   $0x8,%ah
  8010e6:	0f 85 dd 00 00 00    	jne    8011c9 <fork+0x1c5>
	 if((r=sys_page_map(parent_envid,va,envid,va,perm))<0)
  8010ec:	83 ec 0c             	sub    $0xc,%esp
  8010ef:	6a 05                	push   $0x5
  8010f1:	57                   	push   %edi
  8010f2:	ff 75 e0             	pushl  -0x20(%ebp)
  8010f5:	57                   	push   %edi
  8010f6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010f9:	e8 64 fc ff ff       	call   800d62 <sys_page_map>
  8010fe:	83 c4 20             	add    $0x20,%esp
  801101:	85 c0                	test   %eax,%eax
  801103:	79 81                	jns    801086 <fork+0x82>
  801105:	e9 db 00 00 00       	jmp    8011e5 <fork+0x1e1>
		   duppage(envid,PGNUM(addr));
	}
        
	int r;
	if((r=sys_page_alloc(envid,(void *)UXSTACKTOP-PGSIZE,PTE_U|PTE_P|PTE_W))<0)
  80110a:	83 ec 04             	sub    $0x4,%esp
  80110d:	6a 07                	push   $0x7
  80110f:	68 00 f0 bf ee       	push   $0xeebff000
  801114:	ff 75 dc             	pushl  -0x24(%ebp)
  801117:	e8 03 fc ff ff       	call   800d1f <sys_page_alloc>
  80111c:	83 c4 10             	add    $0x10,%esp
  80111f:	85 c0                	test   %eax,%eax
  801121:	78 36                	js     801159 <fork+0x155>
		panic("fork:page alloc failed %e\n",r);

	extern void _pgfault_upcall();
	if((r = sys_env_set_pgfault_upcall(envid,_pgfault_upcall)))
  801123:	83 ec 08             	sub    $0x8,%esp
  801126:	68 80 1f 80 00       	push   $0x801f80
  80112b:	ff 75 dc             	pushl  -0x24(%ebp)
  80112e:	e8 37 fd ff ff       	call   800e6a <sys_env_set_pgfault_upcall>
  801133:	83 c4 10             	add    $0x10,%esp
  801136:	85 c0                	test   %eax,%eax
  801138:	75 34                	jne    80116e <fork+0x16a>
		panic("fork:set upcall failed %e\n",r);
	if((r = sys_env_set_status(envid,ENV_RUNNABLE))<0)
  80113a:	83 ec 08             	sub    $0x8,%esp
  80113d:	6a 02                	push   $0x2
  80113f:	ff 75 dc             	pushl  -0x24(%ebp)
  801142:	e8 9f fc ff ff       	call   800de6 <sys_env_set_status>
  801147:	83 c4 10             	add    $0x10,%esp
  80114a:	85 c0                	test   %eax,%eax
  80114c:	78 35                	js     801183 <fork+0x17f>
		panic("fork:set status failed %e\n",r);
	//cprintf("forkid= %d\n", envid);
	return envid;
       	
}
  80114e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801151:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801154:	5b                   	pop    %ebx
  801155:	5e                   	pop    %esi
  801156:	5f                   	pop    %edi
  801157:	5d                   	pop    %ebp
  801158:	c3                   	ret    
		panic("fork:page alloc failed %e\n",r);
  801159:	50                   	push   %eax
  80115a:	68 7f 28 80 00       	push   $0x80287f
  80115f:	68 84 00 00 00       	push   $0x84
  801164:	68 fb 27 80 00       	push   $0x8027fb
  801169:	e8 be f0 ff ff       	call   80022c <_panic>
		panic("fork:set upcall failed %e\n",r);
  80116e:	50                   	push   %eax
  80116f:	68 9a 28 80 00       	push   $0x80289a
  801174:	68 88 00 00 00       	push   $0x88
  801179:	68 fb 27 80 00       	push   $0x8027fb
  80117e:	e8 a9 f0 ff ff       	call   80022c <_panic>
		panic("fork:set status failed %e\n",r);
  801183:	50                   	push   %eax
  801184:	68 b5 28 80 00       	push   $0x8028b5
  801189:	68 8a 00 00 00       	push   $0x8a
  80118e:	68 fb 27 80 00       	push   $0x8027fb
  801193:	e8 94 f0 ff ff       	call   80022c <_panic>
		if( (r=sys_page_map(parent_envid,va,parent_envid,va,perm))<0){
  801198:	83 ec 0c             	sub    $0xc,%esp
  80119b:	68 05 08 00 00       	push   $0x805
  8011a0:	57                   	push   %edi
  8011a1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011a4:	50                   	push   %eax
  8011a5:	57                   	push   %edi
  8011a6:	50                   	push   %eax
  8011a7:	e8 b6 fb ff ff       	call   800d62 <sys_page_map>
  8011ac:	83 c4 20             	add    $0x20,%esp
  8011af:	85 c0                	test   %eax,%eax
  8011b1:	0f 89 cf fe ff ff    	jns    801086 <fork+0x82>
		 panic("duppage:map02 failed %e",r);
  8011b7:	50                   	push   %eax
  8011b8:	68 67 28 80 00       	push   $0x802867
  8011bd:	6a 56                	push   $0x56
  8011bf:	68 fb 27 80 00       	push   $0x8027fb
  8011c4:	e8 63 f0 ff ff       	call   80022c <_panic>
	 if((r=sys_page_map(parent_envid,va,envid,va,perm))<0)
  8011c9:	83 ec 0c             	sub    $0xc,%esp
  8011cc:	68 05 08 00 00       	push   $0x805
  8011d1:	57                   	push   %edi
  8011d2:	ff 75 e0             	pushl  -0x20(%ebp)
  8011d5:	57                   	push   %edi
  8011d6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011d9:	e8 84 fb ff ff       	call   800d62 <sys_page_map>
  8011de:	83 c4 20             	add    $0x20,%esp
  8011e1:	85 c0                	test   %eax,%eax
  8011e3:	79 b3                	jns    801198 <fork+0x194>
		 panic("duppage:map01 failed %e",r);
  8011e5:	50                   	push   %eax
  8011e6:	68 4f 28 80 00       	push   $0x80284f
  8011eb:	6a 53                	push   $0x53
  8011ed:	68 fb 27 80 00       	push   $0x8027fb
  8011f2:	e8 35 f0 ff ff       	call   80022c <_panic>

008011f7 <sfork>:

// Challenge!
int
sfork(void)
{
  8011f7:	55                   	push   %ebp
  8011f8:	89 e5                	mov    %esp,%ebp
  8011fa:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011fd:	68 d0 28 80 00       	push   $0x8028d0
  801202:	68 94 00 00 00       	push   $0x94
  801207:	68 fb 27 80 00       	push   $0x8027fb
  80120c:	e8 1b f0 ff ff       	call   80022c <_panic>

00801211 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801211:	55                   	push   %ebp
  801212:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801214:	8b 45 08             	mov    0x8(%ebp),%eax
  801217:	05 00 00 00 30       	add    $0x30000000,%eax
  80121c:	c1 e8 0c             	shr    $0xc,%eax
}
  80121f:	5d                   	pop    %ebp
  801220:	c3                   	ret    

00801221 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801221:	55                   	push   %ebp
  801222:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801224:	8b 45 08             	mov    0x8(%ebp),%eax
  801227:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80122c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801231:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801236:	5d                   	pop    %ebp
  801237:	c3                   	ret    

00801238 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801238:	55                   	push   %ebp
  801239:	89 e5                	mov    %esp,%ebp
  80123b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80123e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801243:	89 c2                	mov    %eax,%edx
  801245:	c1 ea 16             	shr    $0x16,%edx
  801248:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80124f:	f6 c2 01             	test   $0x1,%dl
  801252:	74 2a                	je     80127e <fd_alloc+0x46>
  801254:	89 c2                	mov    %eax,%edx
  801256:	c1 ea 0c             	shr    $0xc,%edx
  801259:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801260:	f6 c2 01             	test   $0x1,%dl
  801263:	74 19                	je     80127e <fd_alloc+0x46>
  801265:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  80126a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80126f:	75 d2                	jne    801243 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801271:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801277:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  80127c:	eb 07                	jmp    801285 <fd_alloc+0x4d>
			*fd_store = fd;
  80127e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801280:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801285:	5d                   	pop    %ebp
  801286:	c3                   	ret    

00801287 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801287:	55                   	push   %ebp
  801288:	89 e5                	mov    %esp,%ebp
  80128a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80128d:	83 f8 1f             	cmp    $0x1f,%eax
  801290:	77 36                	ja     8012c8 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801292:	c1 e0 0c             	shl    $0xc,%eax
  801295:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80129a:	89 c2                	mov    %eax,%edx
  80129c:	c1 ea 16             	shr    $0x16,%edx
  80129f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012a6:	f6 c2 01             	test   $0x1,%dl
  8012a9:	74 24                	je     8012cf <fd_lookup+0x48>
  8012ab:	89 c2                	mov    %eax,%edx
  8012ad:	c1 ea 0c             	shr    $0xc,%edx
  8012b0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012b7:	f6 c2 01             	test   $0x1,%dl
  8012ba:	74 1a                	je     8012d6 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012bf:	89 02                	mov    %eax,(%edx)
	return 0;
  8012c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012c6:	5d                   	pop    %ebp
  8012c7:	c3                   	ret    
		return -E_INVAL;
  8012c8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012cd:	eb f7                	jmp    8012c6 <fd_lookup+0x3f>
		return -E_INVAL;
  8012cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012d4:	eb f0                	jmp    8012c6 <fd_lookup+0x3f>
  8012d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012db:	eb e9                	jmp    8012c6 <fd_lookup+0x3f>

008012dd <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012dd:	55                   	push   %ebp
  8012de:	89 e5                	mov    %esp,%ebp
  8012e0:	83 ec 08             	sub    $0x8,%esp
  8012e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012e6:	ba 8c 29 80 00       	mov    $0x80298c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012eb:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  8012f0:	39 08                	cmp    %ecx,(%eax)
  8012f2:	74 33                	je     801327 <dev_lookup+0x4a>
  8012f4:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  8012f7:	8b 02                	mov    (%edx),%eax
  8012f9:	85 c0                	test   %eax,%eax
  8012fb:	75 f3                	jne    8012f0 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012fd:	a1 20 44 80 00       	mov    0x804420,%eax
  801302:	8b 40 48             	mov    0x48(%eax),%eax
  801305:	83 ec 04             	sub    $0x4,%esp
  801308:	51                   	push   %ecx
  801309:	50                   	push   %eax
  80130a:	68 0c 29 80 00       	push   $0x80290c
  80130f:	e8 f3 ef ff ff       	call   800307 <cprintf>
	*dev = 0;
  801314:	8b 45 0c             	mov    0xc(%ebp),%eax
  801317:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80131d:	83 c4 10             	add    $0x10,%esp
  801320:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801325:	c9                   	leave  
  801326:	c3                   	ret    
			*dev = devtab[i];
  801327:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80132a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80132c:	b8 00 00 00 00       	mov    $0x0,%eax
  801331:	eb f2                	jmp    801325 <dev_lookup+0x48>

00801333 <fd_close>:
{
  801333:	55                   	push   %ebp
  801334:	89 e5                	mov    %esp,%ebp
  801336:	57                   	push   %edi
  801337:	56                   	push   %esi
  801338:	53                   	push   %ebx
  801339:	83 ec 1c             	sub    $0x1c,%esp
  80133c:	8b 75 08             	mov    0x8(%ebp),%esi
  80133f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801342:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801345:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801346:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80134c:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80134f:	50                   	push   %eax
  801350:	e8 32 ff ff ff       	call   801287 <fd_lookup>
  801355:	89 c3                	mov    %eax,%ebx
  801357:	83 c4 08             	add    $0x8,%esp
  80135a:	85 c0                	test   %eax,%eax
  80135c:	78 05                	js     801363 <fd_close+0x30>
	    || fd != fd2)
  80135e:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801361:	74 16                	je     801379 <fd_close+0x46>
		return (must_exist ? r : 0);
  801363:	89 f8                	mov    %edi,%eax
  801365:	84 c0                	test   %al,%al
  801367:	b8 00 00 00 00       	mov    $0x0,%eax
  80136c:	0f 44 d8             	cmove  %eax,%ebx
}
  80136f:	89 d8                	mov    %ebx,%eax
  801371:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801374:	5b                   	pop    %ebx
  801375:	5e                   	pop    %esi
  801376:	5f                   	pop    %edi
  801377:	5d                   	pop    %ebp
  801378:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801379:	83 ec 08             	sub    $0x8,%esp
  80137c:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80137f:	50                   	push   %eax
  801380:	ff 36                	pushl  (%esi)
  801382:	e8 56 ff ff ff       	call   8012dd <dev_lookup>
  801387:	89 c3                	mov    %eax,%ebx
  801389:	83 c4 10             	add    $0x10,%esp
  80138c:	85 c0                	test   %eax,%eax
  80138e:	78 15                	js     8013a5 <fd_close+0x72>
		if (dev->dev_close)
  801390:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801393:	8b 40 10             	mov    0x10(%eax),%eax
  801396:	85 c0                	test   %eax,%eax
  801398:	74 1b                	je     8013b5 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  80139a:	83 ec 0c             	sub    $0xc,%esp
  80139d:	56                   	push   %esi
  80139e:	ff d0                	call   *%eax
  8013a0:	89 c3                	mov    %eax,%ebx
  8013a2:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8013a5:	83 ec 08             	sub    $0x8,%esp
  8013a8:	56                   	push   %esi
  8013a9:	6a 00                	push   $0x0
  8013ab:	e8 f4 f9 ff ff       	call   800da4 <sys_page_unmap>
	return r;
  8013b0:	83 c4 10             	add    $0x10,%esp
  8013b3:	eb ba                	jmp    80136f <fd_close+0x3c>
			r = 0;
  8013b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013ba:	eb e9                	jmp    8013a5 <fd_close+0x72>

008013bc <close>:

int
close(int fdnum)
{
  8013bc:	55                   	push   %ebp
  8013bd:	89 e5                	mov    %esp,%ebp
  8013bf:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c5:	50                   	push   %eax
  8013c6:	ff 75 08             	pushl  0x8(%ebp)
  8013c9:	e8 b9 fe ff ff       	call   801287 <fd_lookup>
  8013ce:	83 c4 08             	add    $0x8,%esp
  8013d1:	85 c0                	test   %eax,%eax
  8013d3:	78 10                	js     8013e5 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013d5:	83 ec 08             	sub    $0x8,%esp
  8013d8:	6a 01                	push   $0x1
  8013da:	ff 75 f4             	pushl  -0xc(%ebp)
  8013dd:	e8 51 ff ff ff       	call   801333 <fd_close>
  8013e2:	83 c4 10             	add    $0x10,%esp
}
  8013e5:	c9                   	leave  
  8013e6:	c3                   	ret    

008013e7 <close_all>:

void
close_all(void)
{
  8013e7:	55                   	push   %ebp
  8013e8:	89 e5                	mov    %esp,%ebp
  8013ea:	53                   	push   %ebx
  8013eb:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013ee:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013f3:	83 ec 0c             	sub    $0xc,%esp
  8013f6:	53                   	push   %ebx
  8013f7:	e8 c0 ff ff ff       	call   8013bc <close>
	for (i = 0; i < MAXFD; i++)
  8013fc:	83 c3 01             	add    $0x1,%ebx
  8013ff:	83 c4 10             	add    $0x10,%esp
  801402:	83 fb 20             	cmp    $0x20,%ebx
  801405:	75 ec                	jne    8013f3 <close_all+0xc>
}
  801407:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80140a:	c9                   	leave  
  80140b:	c3                   	ret    

0080140c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80140c:	55                   	push   %ebp
  80140d:	89 e5                	mov    %esp,%ebp
  80140f:	57                   	push   %edi
  801410:	56                   	push   %esi
  801411:	53                   	push   %ebx
  801412:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801415:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801418:	50                   	push   %eax
  801419:	ff 75 08             	pushl  0x8(%ebp)
  80141c:	e8 66 fe ff ff       	call   801287 <fd_lookup>
  801421:	89 c3                	mov    %eax,%ebx
  801423:	83 c4 08             	add    $0x8,%esp
  801426:	85 c0                	test   %eax,%eax
  801428:	0f 88 81 00 00 00    	js     8014af <dup+0xa3>
		return r;
	close(newfdnum);
  80142e:	83 ec 0c             	sub    $0xc,%esp
  801431:	ff 75 0c             	pushl  0xc(%ebp)
  801434:	e8 83 ff ff ff       	call   8013bc <close>

	newfd = INDEX2FD(newfdnum);
  801439:	8b 75 0c             	mov    0xc(%ebp),%esi
  80143c:	c1 e6 0c             	shl    $0xc,%esi
  80143f:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801445:	83 c4 04             	add    $0x4,%esp
  801448:	ff 75 e4             	pushl  -0x1c(%ebp)
  80144b:	e8 d1 fd ff ff       	call   801221 <fd2data>
  801450:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801452:	89 34 24             	mov    %esi,(%esp)
  801455:	e8 c7 fd ff ff       	call   801221 <fd2data>
  80145a:	83 c4 10             	add    $0x10,%esp
  80145d:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80145f:	89 d8                	mov    %ebx,%eax
  801461:	c1 e8 16             	shr    $0x16,%eax
  801464:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80146b:	a8 01                	test   $0x1,%al
  80146d:	74 11                	je     801480 <dup+0x74>
  80146f:	89 d8                	mov    %ebx,%eax
  801471:	c1 e8 0c             	shr    $0xc,%eax
  801474:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80147b:	f6 c2 01             	test   $0x1,%dl
  80147e:	75 39                	jne    8014b9 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801480:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801483:	89 d0                	mov    %edx,%eax
  801485:	c1 e8 0c             	shr    $0xc,%eax
  801488:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80148f:	83 ec 0c             	sub    $0xc,%esp
  801492:	25 07 0e 00 00       	and    $0xe07,%eax
  801497:	50                   	push   %eax
  801498:	56                   	push   %esi
  801499:	6a 00                	push   $0x0
  80149b:	52                   	push   %edx
  80149c:	6a 00                	push   $0x0
  80149e:	e8 bf f8 ff ff       	call   800d62 <sys_page_map>
  8014a3:	89 c3                	mov    %eax,%ebx
  8014a5:	83 c4 20             	add    $0x20,%esp
  8014a8:	85 c0                	test   %eax,%eax
  8014aa:	78 31                	js     8014dd <dup+0xd1>
		goto err;

	return newfdnum;
  8014ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8014af:	89 d8                	mov    %ebx,%eax
  8014b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014b4:	5b                   	pop    %ebx
  8014b5:	5e                   	pop    %esi
  8014b6:	5f                   	pop    %edi
  8014b7:	5d                   	pop    %ebp
  8014b8:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014b9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014c0:	83 ec 0c             	sub    $0xc,%esp
  8014c3:	25 07 0e 00 00       	and    $0xe07,%eax
  8014c8:	50                   	push   %eax
  8014c9:	57                   	push   %edi
  8014ca:	6a 00                	push   $0x0
  8014cc:	53                   	push   %ebx
  8014cd:	6a 00                	push   $0x0
  8014cf:	e8 8e f8 ff ff       	call   800d62 <sys_page_map>
  8014d4:	89 c3                	mov    %eax,%ebx
  8014d6:	83 c4 20             	add    $0x20,%esp
  8014d9:	85 c0                	test   %eax,%eax
  8014db:	79 a3                	jns    801480 <dup+0x74>
	sys_page_unmap(0, newfd);
  8014dd:	83 ec 08             	sub    $0x8,%esp
  8014e0:	56                   	push   %esi
  8014e1:	6a 00                	push   $0x0
  8014e3:	e8 bc f8 ff ff       	call   800da4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014e8:	83 c4 08             	add    $0x8,%esp
  8014eb:	57                   	push   %edi
  8014ec:	6a 00                	push   $0x0
  8014ee:	e8 b1 f8 ff ff       	call   800da4 <sys_page_unmap>
	return r;
  8014f3:	83 c4 10             	add    $0x10,%esp
  8014f6:	eb b7                	jmp    8014af <dup+0xa3>

008014f8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014f8:	55                   	push   %ebp
  8014f9:	89 e5                	mov    %esp,%ebp
  8014fb:	53                   	push   %ebx
  8014fc:	83 ec 14             	sub    $0x14,%esp
  8014ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801502:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801505:	50                   	push   %eax
  801506:	53                   	push   %ebx
  801507:	e8 7b fd ff ff       	call   801287 <fd_lookup>
  80150c:	83 c4 08             	add    $0x8,%esp
  80150f:	85 c0                	test   %eax,%eax
  801511:	78 3f                	js     801552 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801513:	83 ec 08             	sub    $0x8,%esp
  801516:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801519:	50                   	push   %eax
  80151a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80151d:	ff 30                	pushl  (%eax)
  80151f:	e8 b9 fd ff ff       	call   8012dd <dev_lookup>
  801524:	83 c4 10             	add    $0x10,%esp
  801527:	85 c0                	test   %eax,%eax
  801529:	78 27                	js     801552 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80152b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80152e:	8b 42 08             	mov    0x8(%edx),%eax
  801531:	83 e0 03             	and    $0x3,%eax
  801534:	83 f8 01             	cmp    $0x1,%eax
  801537:	74 1e                	je     801557 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801539:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80153c:	8b 40 08             	mov    0x8(%eax),%eax
  80153f:	85 c0                	test   %eax,%eax
  801541:	74 35                	je     801578 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801543:	83 ec 04             	sub    $0x4,%esp
  801546:	ff 75 10             	pushl  0x10(%ebp)
  801549:	ff 75 0c             	pushl  0xc(%ebp)
  80154c:	52                   	push   %edx
  80154d:	ff d0                	call   *%eax
  80154f:	83 c4 10             	add    $0x10,%esp
}
  801552:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801555:	c9                   	leave  
  801556:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801557:	a1 20 44 80 00       	mov    0x804420,%eax
  80155c:	8b 40 48             	mov    0x48(%eax),%eax
  80155f:	83 ec 04             	sub    $0x4,%esp
  801562:	53                   	push   %ebx
  801563:	50                   	push   %eax
  801564:	68 50 29 80 00       	push   $0x802950
  801569:	e8 99 ed ff ff       	call   800307 <cprintf>
		return -E_INVAL;
  80156e:	83 c4 10             	add    $0x10,%esp
  801571:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801576:	eb da                	jmp    801552 <read+0x5a>
		return -E_NOT_SUPP;
  801578:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80157d:	eb d3                	jmp    801552 <read+0x5a>

0080157f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80157f:	55                   	push   %ebp
  801580:	89 e5                	mov    %esp,%ebp
  801582:	57                   	push   %edi
  801583:	56                   	push   %esi
  801584:	53                   	push   %ebx
  801585:	83 ec 0c             	sub    $0xc,%esp
  801588:	8b 7d 08             	mov    0x8(%ebp),%edi
  80158b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80158e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801593:	39 f3                	cmp    %esi,%ebx
  801595:	73 25                	jae    8015bc <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801597:	83 ec 04             	sub    $0x4,%esp
  80159a:	89 f0                	mov    %esi,%eax
  80159c:	29 d8                	sub    %ebx,%eax
  80159e:	50                   	push   %eax
  80159f:	89 d8                	mov    %ebx,%eax
  8015a1:	03 45 0c             	add    0xc(%ebp),%eax
  8015a4:	50                   	push   %eax
  8015a5:	57                   	push   %edi
  8015a6:	e8 4d ff ff ff       	call   8014f8 <read>
		if (m < 0)
  8015ab:	83 c4 10             	add    $0x10,%esp
  8015ae:	85 c0                	test   %eax,%eax
  8015b0:	78 08                	js     8015ba <readn+0x3b>
			return m;
		if (m == 0)
  8015b2:	85 c0                	test   %eax,%eax
  8015b4:	74 06                	je     8015bc <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  8015b6:	01 c3                	add    %eax,%ebx
  8015b8:	eb d9                	jmp    801593 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015ba:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8015bc:	89 d8                	mov    %ebx,%eax
  8015be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015c1:	5b                   	pop    %ebx
  8015c2:	5e                   	pop    %esi
  8015c3:	5f                   	pop    %edi
  8015c4:	5d                   	pop    %ebp
  8015c5:	c3                   	ret    

008015c6 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015c6:	55                   	push   %ebp
  8015c7:	89 e5                	mov    %esp,%ebp
  8015c9:	53                   	push   %ebx
  8015ca:	83 ec 14             	sub    $0x14,%esp
  8015cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015d3:	50                   	push   %eax
  8015d4:	53                   	push   %ebx
  8015d5:	e8 ad fc ff ff       	call   801287 <fd_lookup>
  8015da:	83 c4 08             	add    $0x8,%esp
  8015dd:	85 c0                	test   %eax,%eax
  8015df:	78 3a                	js     80161b <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e1:	83 ec 08             	sub    $0x8,%esp
  8015e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e7:	50                   	push   %eax
  8015e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015eb:	ff 30                	pushl  (%eax)
  8015ed:	e8 eb fc ff ff       	call   8012dd <dev_lookup>
  8015f2:	83 c4 10             	add    $0x10,%esp
  8015f5:	85 c0                	test   %eax,%eax
  8015f7:	78 22                	js     80161b <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015fc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801600:	74 1e                	je     801620 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801602:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801605:	8b 52 0c             	mov    0xc(%edx),%edx
  801608:	85 d2                	test   %edx,%edx
  80160a:	74 35                	je     801641 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80160c:	83 ec 04             	sub    $0x4,%esp
  80160f:	ff 75 10             	pushl  0x10(%ebp)
  801612:	ff 75 0c             	pushl  0xc(%ebp)
  801615:	50                   	push   %eax
  801616:	ff d2                	call   *%edx
  801618:	83 c4 10             	add    $0x10,%esp
}
  80161b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80161e:	c9                   	leave  
  80161f:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801620:	a1 20 44 80 00       	mov    0x804420,%eax
  801625:	8b 40 48             	mov    0x48(%eax),%eax
  801628:	83 ec 04             	sub    $0x4,%esp
  80162b:	53                   	push   %ebx
  80162c:	50                   	push   %eax
  80162d:	68 6c 29 80 00       	push   $0x80296c
  801632:	e8 d0 ec ff ff       	call   800307 <cprintf>
		return -E_INVAL;
  801637:	83 c4 10             	add    $0x10,%esp
  80163a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80163f:	eb da                	jmp    80161b <write+0x55>
		return -E_NOT_SUPP;
  801641:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801646:	eb d3                	jmp    80161b <write+0x55>

00801648 <seek>:

int
seek(int fdnum, off_t offset)
{
  801648:	55                   	push   %ebp
  801649:	89 e5                	mov    %esp,%ebp
  80164b:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80164e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801651:	50                   	push   %eax
  801652:	ff 75 08             	pushl  0x8(%ebp)
  801655:	e8 2d fc ff ff       	call   801287 <fd_lookup>
  80165a:	83 c4 08             	add    $0x8,%esp
  80165d:	85 c0                	test   %eax,%eax
  80165f:	78 0e                	js     80166f <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801661:	8b 55 0c             	mov    0xc(%ebp),%edx
  801664:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801667:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80166a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80166f:	c9                   	leave  
  801670:	c3                   	ret    

00801671 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801671:	55                   	push   %ebp
  801672:	89 e5                	mov    %esp,%ebp
  801674:	53                   	push   %ebx
  801675:	83 ec 14             	sub    $0x14,%esp
  801678:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80167b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80167e:	50                   	push   %eax
  80167f:	53                   	push   %ebx
  801680:	e8 02 fc ff ff       	call   801287 <fd_lookup>
  801685:	83 c4 08             	add    $0x8,%esp
  801688:	85 c0                	test   %eax,%eax
  80168a:	78 37                	js     8016c3 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80168c:	83 ec 08             	sub    $0x8,%esp
  80168f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801692:	50                   	push   %eax
  801693:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801696:	ff 30                	pushl  (%eax)
  801698:	e8 40 fc ff ff       	call   8012dd <dev_lookup>
  80169d:	83 c4 10             	add    $0x10,%esp
  8016a0:	85 c0                	test   %eax,%eax
  8016a2:	78 1f                	js     8016c3 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016a7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016ab:	74 1b                	je     8016c8 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8016ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016b0:	8b 52 18             	mov    0x18(%edx),%edx
  8016b3:	85 d2                	test   %edx,%edx
  8016b5:	74 32                	je     8016e9 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016b7:	83 ec 08             	sub    $0x8,%esp
  8016ba:	ff 75 0c             	pushl  0xc(%ebp)
  8016bd:	50                   	push   %eax
  8016be:	ff d2                	call   *%edx
  8016c0:	83 c4 10             	add    $0x10,%esp
}
  8016c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c6:	c9                   	leave  
  8016c7:	c3                   	ret    
			thisenv->env_id, fdnum);
  8016c8:	a1 20 44 80 00       	mov    0x804420,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016cd:	8b 40 48             	mov    0x48(%eax),%eax
  8016d0:	83 ec 04             	sub    $0x4,%esp
  8016d3:	53                   	push   %ebx
  8016d4:	50                   	push   %eax
  8016d5:	68 2c 29 80 00       	push   $0x80292c
  8016da:	e8 28 ec ff ff       	call   800307 <cprintf>
		return -E_INVAL;
  8016df:	83 c4 10             	add    $0x10,%esp
  8016e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016e7:	eb da                	jmp    8016c3 <ftruncate+0x52>
		return -E_NOT_SUPP;
  8016e9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016ee:	eb d3                	jmp    8016c3 <ftruncate+0x52>

008016f0 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016f0:	55                   	push   %ebp
  8016f1:	89 e5                	mov    %esp,%ebp
  8016f3:	53                   	push   %ebx
  8016f4:	83 ec 14             	sub    $0x14,%esp
  8016f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016fa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016fd:	50                   	push   %eax
  8016fe:	ff 75 08             	pushl  0x8(%ebp)
  801701:	e8 81 fb ff ff       	call   801287 <fd_lookup>
  801706:	83 c4 08             	add    $0x8,%esp
  801709:	85 c0                	test   %eax,%eax
  80170b:	78 4b                	js     801758 <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80170d:	83 ec 08             	sub    $0x8,%esp
  801710:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801713:	50                   	push   %eax
  801714:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801717:	ff 30                	pushl  (%eax)
  801719:	e8 bf fb ff ff       	call   8012dd <dev_lookup>
  80171e:	83 c4 10             	add    $0x10,%esp
  801721:	85 c0                	test   %eax,%eax
  801723:	78 33                	js     801758 <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  801725:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801728:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80172c:	74 2f                	je     80175d <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80172e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801731:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801738:	00 00 00 
	stat->st_isdir = 0;
  80173b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801742:	00 00 00 
	stat->st_dev = dev;
  801745:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80174b:	83 ec 08             	sub    $0x8,%esp
  80174e:	53                   	push   %ebx
  80174f:	ff 75 f0             	pushl  -0x10(%ebp)
  801752:	ff 50 14             	call   *0x14(%eax)
  801755:	83 c4 10             	add    $0x10,%esp
}
  801758:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80175b:	c9                   	leave  
  80175c:	c3                   	ret    
		return -E_NOT_SUPP;
  80175d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801762:	eb f4                	jmp    801758 <fstat+0x68>

00801764 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801764:	55                   	push   %ebp
  801765:	89 e5                	mov    %esp,%ebp
  801767:	56                   	push   %esi
  801768:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801769:	83 ec 08             	sub    $0x8,%esp
  80176c:	6a 00                	push   $0x0
  80176e:	ff 75 08             	pushl  0x8(%ebp)
  801771:	e8 e7 01 00 00       	call   80195d <open>
  801776:	89 c3                	mov    %eax,%ebx
  801778:	83 c4 10             	add    $0x10,%esp
  80177b:	85 c0                	test   %eax,%eax
  80177d:	78 1b                	js     80179a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80177f:	83 ec 08             	sub    $0x8,%esp
  801782:	ff 75 0c             	pushl  0xc(%ebp)
  801785:	50                   	push   %eax
  801786:	e8 65 ff ff ff       	call   8016f0 <fstat>
  80178b:	89 c6                	mov    %eax,%esi
	close(fd);
  80178d:	89 1c 24             	mov    %ebx,(%esp)
  801790:	e8 27 fc ff ff       	call   8013bc <close>
	return r;
  801795:	83 c4 10             	add    $0x10,%esp
  801798:	89 f3                	mov    %esi,%ebx
}
  80179a:	89 d8                	mov    %ebx,%eax
  80179c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80179f:	5b                   	pop    %ebx
  8017a0:	5e                   	pop    %esi
  8017a1:	5d                   	pop    %ebp
  8017a2:	c3                   	ret    

008017a3 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017a3:	55                   	push   %ebp
  8017a4:	89 e5                	mov    %esp,%ebp
  8017a6:	56                   	push   %esi
  8017a7:	53                   	push   %ebx
  8017a8:	89 c6                	mov    %eax,%esi
  8017aa:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017ac:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017b3:	74 27                	je     8017dc <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017b5:	6a 07                	push   $0x7
  8017b7:	68 00 50 80 00       	push   $0x805000
  8017bc:	56                   	push   %esi
  8017bd:	ff 35 00 40 80 00    	pushl  0x804000
  8017c3:	e8 54 08 00 00       	call   80201c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017c8:	83 c4 0c             	add    $0xc,%esp
  8017cb:	6a 00                	push   $0x0
  8017cd:	53                   	push   %ebx
  8017ce:	6a 00                	push   $0x0
  8017d0:	e8 d2 07 00 00       	call   801fa7 <ipc_recv>
}
  8017d5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017d8:	5b                   	pop    %ebx
  8017d9:	5e                   	pop    %esi
  8017da:	5d                   	pop    %ebp
  8017db:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017dc:	83 ec 0c             	sub    $0xc,%esp
  8017df:	6a 01                	push   $0x1
  8017e1:	e8 8c 08 00 00       	call   802072 <ipc_find_env>
  8017e6:	a3 00 40 80 00       	mov    %eax,0x804000
  8017eb:	83 c4 10             	add    $0x10,%esp
  8017ee:	eb c5                	jmp    8017b5 <fsipc+0x12>

008017f0 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017f0:	55                   	push   %ebp
  8017f1:	89 e5                	mov    %esp,%ebp
  8017f3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f9:	8b 40 0c             	mov    0xc(%eax),%eax
  8017fc:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801801:	8b 45 0c             	mov    0xc(%ebp),%eax
  801804:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801809:	ba 00 00 00 00       	mov    $0x0,%edx
  80180e:	b8 02 00 00 00       	mov    $0x2,%eax
  801813:	e8 8b ff ff ff       	call   8017a3 <fsipc>
}
  801818:	c9                   	leave  
  801819:	c3                   	ret    

0080181a <devfile_flush>:
{
  80181a:	55                   	push   %ebp
  80181b:	89 e5                	mov    %esp,%ebp
  80181d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801820:	8b 45 08             	mov    0x8(%ebp),%eax
  801823:	8b 40 0c             	mov    0xc(%eax),%eax
  801826:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80182b:	ba 00 00 00 00       	mov    $0x0,%edx
  801830:	b8 06 00 00 00       	mov    $0x6,%eax
  801835:	e8 69 ff ff ff       	call   8017a3 <fsipc>
}
  80183a:	c9                   	leave  
  80183b:	c3                   	ret    

0080183c <devfile_stat>:
{
  80183c:	55                   	push   %ebp
  80183d:	89 e5                	mov    %esp,%ebp
  80183f:	53                   	push   %ebx
  801840:	83 ec 04             	sub    $0x4,%esp
  801843:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801846:	8b 45 08             	mov    0x8(%ebp),%eax
  801849:	8b 40 0c             	mov    0xc(%eax),%eax
  80184c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801851:	ba 00 00 00 00       	mov    $0x0,%edx
  801856:	b8 05 00 00 00       	mov    $0x5,%eax
  80185b:	e8 43 ff ff ff       	call   8017a3 <fsipc>
  801860:	85 c0                	test   %eax,%eax
  801862:	78 2c                	js     801890 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801864:	83 ec 08             	sub    $0x8,%esp
  801867:	68 00 50 80 00       	push   $0x805000
  80186c:	53                   	push   %ebx
  80186d:	e8 b4 f0 ff ff       	call   800926 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801872:	a1 80 50 80 00       	mov    0x805080,%eax
  801877:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80187d:	a1 84 50 80 00       	mov    0x805084,%eax
  801882:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801888:	83 c4 10             	add    $0x10,%esp
  80188b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801890:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801893:	c9                   	leave  
  801894:	c3                   	ret    

00801895 <devfile_write>:
{
  801895:	55                   	push   %ebp
  801896:	89 e5                	mov    %esp,%ebp
  801898:	83 ec 0c             	sub    $0xc,%esp
  80189b:	8b 45 10             	mov    0x10(%ebp),%eax
  80189e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8018a3:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8018a8:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8018ae:	8b 52 0c             	mov    0xc(%edx),%edx
  8018b1:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8018b7:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf,buf,n);
  8018bc:	50                   	push   %eax
  8018bd:	ff 75 0c             	pushl  0xc(%ebp)
  8018c0:	68 08 50 80 00       	push   $0x805008
  8018c5:	e8 ea f1 ff ff       	call   800ab4 <memmove>
	if((r = fsipc(FSREQ_WRITE,NULL))<0)
  8018ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8018cf:	b8 04 00 00 00       	mov    $0x4,%eax
  8018d4:	e8 ca fe ff ff       	call   8017a3 <fsipc>
}
  8018d9:	c9                   	leave  
  8018da:	c3                   	ret    

008018db <devfile_read>:
{
  8018db:	55                   	push   %ebp
  8018dc:	89 e5                	mov    %esp,%ebp
  8018de:	56                   	push   %esi
  8018df:	53                   	push   %ebx
  8018e0:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e6:	8b 40 0c             	mov    0xc(%eax),%eax
  8018e9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018ee:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f9:	b8 03 00 00 00       	mov    $0x3,%eax
  8018fe:	e8 a0 fe ff ff       	call   8017a3 <fsipc>
  801903:	89 c3                	mov    %eax,%ebx
  801905:	85 c0                	test   %eax,%eax
  801907:	78 1f                	js     801928 <devfile_read+0x4d>
	assert(r <= n);
  801909:	39 f0                	cmp    %esi,%eax
  80190b:	77 24                	ja     801931 <devfile_read+0x56>
	assert(r <= PGSIZE);
  80190d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801912:	7f 33                	jg     801947 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801914:	83 ec 04             	sub    $0x4,%esp
  801917:	50                   	push   %eax
  801918:	68 00 50 80 00       	push   $0x805000
  80191d:	ff 75 0c             	pushl  0xc(%ebp)
  801920:	e8 8f f1 ff ff       	call   800ab4 <memmove>
	return r;
  801925:	83 c4 10             	add    $0x10,%esp
}
  801928:	89 d8                	mov    %ebx,%eax
  80192a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80192d:	5b                   	pop    %ebx
  80192e:	5e                   	pop    %esi
  80192f:	5d                   	pop    %ebp
  801930:	c3                   	ret    
	assert(r <= n);
  801931:	68 9c 29 80 00       	push   $0x80299c
  801936:	68 a3 29 80 00       	push   $0x8029a3
  80193b:	6a 7c                	push   $0x7c
  80193d:	68 b8 29 80 00       	push   $0x8029b8
  801942:	e8 e5 e8 ff ff       	call   80022c <_panic>
	assert(r <= PGSIZE);
  801947:	68 c3 29 80 00       	push   $0x8029c3
  80194c:	68 a3 29 80 00       	push   $0x8029a3
  801951:	6a 7d                	push   $0x7d
  801953:	68 b8 29 80 00       	push   $0x8029b8
  801958:	e8 cf e8 ff ff       	call   80022c <_panic>

0080195d <open>:
{
  80195d:	55                   	push   %ebp
  80195e:	89 e5                	mov    %esp,%ebp
  801960:	56                   	push   %esi
  801961:	53                   	push   %ebx
  801962:	83 ec 1c             	sub    $0x1c,%esp
  801965:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801968:	56                   	push   %esi
  801969:	e8 81 ef ff ff       	call   8008ef <strlen>
  80196e:	83 c4 10             	add    $0x10,%esp
  801971:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801976:	7f 6c                	jg     8019e4 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801978:	83 ec 0c             	sub    $0xc,%esp
  80197b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80197e:	50                   	push   %eax
  80197f:	e8 b4 f8 ff ff       	call   801238 <fd_alloc>
  801984:	89 c3                	mov    %eax,%ebx
  801986:	83 c4 10             	add    $0x10,%esp
  801989:	85 c0                	test   %eax,%eax
  80198b:	78 3c                	js     8019c9 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  80198d:	83 ec 08             	sub    $0x8,%esp
  801990:	56                   	push   %esi
  801991:	68 00 50 80 00       	push   $0x805000
  801996:	e8 8b ef ff ff       	call   800926 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80199b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80199e:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8019ab:	e8 f3 fd ff ff       	call   8017a3 <fsipc>
  8019b0:	89 c3                	mov    %eax,%ebx
  8019b2:	83 c4 10             	add    $0x10,%esp
  8019b5:	85 c0                	test   %eax,%eax
  8019b7:	78 19                	js     8019d2 <open+0x75>
	return fd2num(fd);
  8019b9:	83 ec 0c             	sub    $0xc,%esp
  8019bc:	ff 75 f4             	pushl  -0xc(%ebp)
  8019bf:	e8 4d f8 ff ff       	call   801211 <fd2num>
  8019c4:	89 c3                	mov    %eax,%ebx
  8019c6:	83 c4 10             	add    $0x10,%esp
}
  8019c9:	89 d8                	mov    %ebx,%eax
  8019cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019ce:	5b                   	pop    %ebx
  8019cf:	5e                   	pop    %esi
  8019d0:	5d                   	pop    %ebp
  8019d1:	c3                   	ret    
		fd_close(fd, 0);
  8019d2:	83 ec 08             	sub    $0x8,%esp
  8019d5:	6a 00                	push   $0x0
  8019d7:	ff 75 f4             	pushl  -0xc(%ebp)
  8019da:	e8 54 f9 ff ff       	call   801333 <fd_close>
		return r;
  8019df:	83 c4 10             	add    $0x10,%esp
  8019e2:	eb e5                	jmp    8019c9 <open+0x6c>
		return -E_BAD_PATH;
  8019e4:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8019e9:	eb de                	jmp    8019c9 <open+0x6c>

008019eb <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019eb:	55                   	push   %ebp
  8019ec:	89 e5                	mov    %esp,%ebp
  8019ee:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f6:	b8 08 00 00 00       	mov    $0x8,%eax
  8019fb:	e8 a3 fd ff ff       	call   8017a3 <fsipc>
}
  801a00:	c9                   	leave  
  801a01:	c3                   	ret    

00801a02 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a02:	55                   	push   %ebp
  801a03:	89 e5                	mov    %esp,%ebp
  801a05:	56                   	push   %esi
  801a06:	53                   	push   %ebx
  801a07:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a0a:	83 ec 0c             	sub    $0xc,%esp
  801a0d:	ff 75 08             	pushl  0x8(%ebp)
  801a10:	e8 0c f8 ff ff       	call   801221 <fd2data>
  801a15:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a17:	83 c4 08             	add    $0x8,%esp
  801a1a:	68 cf 29 80 00       	push   $0x8029cf
  801a1f:	53                   	push   %ebx
  801a20:	e8 01 ef ff ff       	call   800926 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a25:	8b 46 04             	mov    0x4(%esi),%eax
  801a28:	2b 06                	sub    (%esi),%eax
  801a2a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a30:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a37:	00 00 00 
	stat->st_dev = &devpipe;
  801a3a:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a41:	30 80 00 
	return 0;
}
  801a44:	b8 00 00 00 00       	mov    $0x0,%eax
  801a49:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a4c:	5b                   	pop    %ebx
  801a4d:	5e                   	pop    %esi
  801a4e:	5d                   	pop    %ebp
  801a4f:	c3                   	ret    

00801a50 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a50:	55                   	push   %ebp
  801a51:	89 e5                	mov    %esp,%ebp
  801a53:	53                   	push   %ebx
  801a54:	83 ec 0c             	sub    $0xc,%esp
  801a57:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a5a:	53                   	push   %ebx
  801a5b:	6a 00                	push   $0x0
  801a5d:	e8 42 f3 ff ff       	call   800da4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a62:	89 1c 24             	mov    %ebx,(%esp)
  801a65:	e8 b7 f7 ff ff       	call   801221 <fd2data>
  801a6a:	83 c4 08             	add    $0x8,%esp
  801a6d:	50                   	push   %eax
  801a6e:	6a 00                	push   $0x0
  801a70:	e8 2f f3 ff ff       	call   800da4 <sys_page_unmap>
}
  801a75:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a78:	c9                   	leave  
  801a79:	c3                   	ret    

00801a7a <_pipeisclosed>:
{
  801a7a:	55                   	push   %ebp
  801a7b:	89 e5                	mov    %esp,%ebp
  801a7d:	57                   	push   %edi
  801a7e:	56                   	push   %esi
  801a7f:	53                   	push   %ebx
  801a80:	83 ec 1c             	sub    $0x1c,%esp
  801a83:	89 c7                	mov    %eax,%edi
  801a85:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801a87:	a1 20 44 80 00       	mov    0x804420,%eax
  801a8c:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a8f:	83 ec 0c             	sub    $0xc,%esp
  801a92:	57                   	push   %edi
  801a93:	e8 13 06 00 00       	call   8020ab <pageref>
  801a98:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801a9b:	89 34 24             	mov    %esi,(%esp)
  801a9e:	e8 08 06 00 00       	call   8020ab <pageref>
		nn = thisenv->env_runs;
  801aa3:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801aa9:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801aac:	83 c4 10             	add    $0x10,%esp
  801aaf:	39 cb                	cmp    %ecx,%ebx
  801ab1:	74 1b                	je     801ace <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801ab3:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801ab6:	75 cf                	jne    801a87 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ab8:	8b 42 58             	mov    0x58(%edx),%eax
  801abb:	6a 01                	push   $0x1
  801abd:	50                   	push   %eax
  801abe:	53                   	push   %ebx
  801abf:	68 d6 29 80 00       	push   $0x8029d6
  801ac4:	e8 3e e8 ff ff       	call   800307 <cprintf>
  801ac9:	83 c4 10             	add    $0x10,%esp
  801acc:	eb b9                	jmp    801a87 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801ace:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801ad1:	0f 94 c0             	sete   %al
  801ad4:	0f b6 c0             	movzbl %al,%eax
}
  801ad7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ada:	5b                   	pop    %ebx
  801adb:	5e                   	pop    %esi
  801adc:	5f                   	pop    %edi
  801add:	5d                   	pop    %ebp
  801ade:	c3                   	ret    

00801adf <devpipe_write>:
{
  801adf:	55                   	push   %ebp
  801ae0:	89 e5                	mov    %esp,%ebp
  801ae2:	57                   	push   %edi
  801ae3:	56                   	push   %esi
  801ae4:	53                   	push   %ebx
  801ae5:	83 ec 28             	sub    $0x28,%esp
  801ae8:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801aeb:	56                   	push   %esi
  801aec:	e8 30 f7 ff ff       	call   801221 <fd2data>
  801af1:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801af3:	83 c4 10             	add    $0x10,%esp
  801af6:	bf 00 00 00 00       	mov    $0x0,%edi
  801afb:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801afe:	74 4f                	je     801b4f <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b00:	8b 43 04             	mov    0x4(%ebx),%eax
  801b03:	8b 0b                	mov    (%ebx),%ecx
  801b05:	8d 51 20             	lea    0x20(%ecx),%edx
  801b08:	39 d0                	cmp    %edx,%eax
  801b0a:	72 14                	jb     801b20 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801b0c:	89 da                	mov    %ebx,%edx
  801b0e:	89 f0                	mov    %esi,%eax
  801b10:	e8 65 ff ff ff       	call   801a7a <_pipeisclosed>
  801b15:	85 c0                	test   %eax,%eax
  801b17:	75 3a                	jne    801b53 <devpipe_write+0x74>
			sys_yield();
  801b19:	e8 e2 f1 ff ff       	call   800d00 <sys_yield>
  801b1e:	eb e0                	jmp    801b00 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b23:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b27:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b2a:	89 c2                	mov    %eax,%edx
  801b2c:	c1 fa 1f             	sar    $0x1f,%edx
  801b2f:	89 d1                	mov    %edx,%ecx
  801b31:	c1 e9 1b             	shr    $0x1b,%ecx
  801b34:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b37:	83 e2 1f             	and    $0x1f,%edx
  801b3a:	29 ca                	sub    %ecx,%edx
  801b3c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b40:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b44:	83 c0 01             	add    $0x1,%eax
  801b47:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801b4a:	83 c7 01             	add    $0x1,%edi
  801b4d:	eb ac                	jmp    801afb <devpipe_write+0x1c>
	return i;
  801b4f:	89 f8                	mov    %edi,%eax
  801b51:	eb 05                	jmp    801b58 <devpipe_write+0x79>
				return 0;
  801b53:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b5b:	5b                   	pop    %ebx
  801b5c:	5e                   	pop    %esi
  801b5d:	5f                   	pop    %edi
  801b5e:	5d                   	pop    %ebp
  801b5f:	c3                   	ret    

00801b60 <devpipe_read>:
{
  801b60:	55                   	push   %ebp
  801b61:	89 e5                	mov    %esp,%ebp
  801b63:	57                   	push   %edi
  801b64:	56                   	push   %esi
  801b65:	53                   	push   %ebx
  801b66:	83 ec 18             	sub    $0x18,%esp
  801b69:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801b6c:	57                   	push   %edi
  801b6d:	e8 af f6 ff ff       	call   801221 <fd2data>
  801b72:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b74:	83 c4 10             	add    $0x10,%esp
  801b77:	be 00 00 00 00       	mov    $0x0,%esi
  801b7c:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b7f:	74 47                	je     801bc8 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  801b81:	8b 03                	mov    (%ebx),%eax
  801b83:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b86:	75 22                	jne    801baa <devpipe_read+0x4a>
			if (i > 0)
  801b88:	85 f6                	test   %esi,%esi
  801b8a:	75 14                	jne    801ba0 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801b8c:	89 da                	mov    %ebx,%edx
  801b8e:	89 f8                	mov    %edi,%eax
  801b90:	e8 e5 fe ff ff       	call   801a7a <_pipeisclosed>
  801b95:	85 c0                	test   %eax,%eax
  801b97:	75 33                	jne    801bcc <devpipe_read+0x6c>
			sys_yield();
  801b99:	e8 62 f1 ff ff       	call   800d00 <sys_yield>
  801b9e:	eb e1                	jmp    801b81 <devpipe_read+0x21>
				return i;
  801ba0:	89 f0                	mov    %esi,%eax
}
  801ba2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ba5:	5b                   	pop    %ebx
  801ba6:	5e                   	pop    %esi
  801ba7:	5f                   	pop    %edi
  801ba8:	5d                   	pop    %ebp
  801ba9:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801baa:	99                   	cltd   
  801bab:	c1 ea 1b             	shr    $0x1b,%edx
  801bae:	01 d0                	add    %edx,%eax
  801bb0:	83 e0 1f             	and    $0x1f,%eax
  801bb3:	29 d0                	sub    %edx,%eax
  801bb5:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801bba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bbd:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801bc0:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801bc3:	83 c6 01             	add    $0x1,%esi
  801bc6:	eb b4                	jmp    801b7c <devpipe_read+0x1c>
	return i;
  801bc8:	89 f0                	mov    %esi,%eax
  801bca:	eb d6                	jmp    801ba2 <devpipe_read+0x42>
				return 0;
  801bcc:	b8 00 00 00 00       	mov    $0x0,%eax
  801bd1:	eb cf                	jmp    801ba2 <devpipe_read+0x42>

00801bd3 <pipe>:
{
  801bd3:	55                   	push   %ebp
  801bd4:	89 e5                	mov    %esp,%ebp
  801bd6:	56                   	push   %esi
  801bd7:	53                   	push   %ebx
  801bd8:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801bdb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bde:	50                   	push   %eax
  801bdf:	e8 54 f6 ff ff       	call   801238 <fd_alloc>
  801be4:	89 c3                	mov    %eax,%ebx
  801be6:	83 c4 10             	add    $0x10,%esp
  801be9:	85 c0                	test   %eax,%eax
  801beb:	78 5b                	js     801c48 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bed:	83 ec 04             	sub    $0x4,%esp
  801bf0:	68 07 04 00 00       	push   $0x407
  801bf5:	ff 75 f4             	pushl  -0xc(%ebp)
  801bf8:	6a 00                	push   $0x0
  801bfa:	e8 20 f1 ff ff       	call   800d1f <sys_page_alloc>
  801bff:	89 c3                	mov    %eax,%ebx
  801c01:	83 c4 10             	add    $0x10,%esp
  801c04:	85 c0                	test   %eax,%eax
  801c06:	78 40                	js     801c48 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  801c08:	83 ec 0c             	sub    $0xc,%esp
  801c0b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c0e:	50                   	push   %eax
  801c0f:	e8 24 f6 ff ff       	call   801238 <fd_alloc>
  801c14:	89 c3                	mov    %eax,%ebx
  801c16:	83 c4 10             	add    $0x10,%esp
  801c19:	85 c0                	test   %eax,%eax
  801c1b:	78 1b                	js     801c38 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c1d:	83 ec 04             	sub    $0x4,%esp
  801c20:	68 07 04 00 00       	push   $0x407
  801c25:	ff 75 f0             	pushl  -0x10(%ebp)
  801c28:	6a 00                	push   $0x0
  801c2a:	e8 f0 f0 ff ff       	call   800d1f <sys_page_alloc>
  801c2f:	89 c3                	mov    %eax,%ebx
  801c31:	83 c4 10             	add    $0x10,%esp
  801c34:	85 c0                	test   %eax,%eax
  801c36:	79 19                	jns    801c51 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  801c38:	83 ec 08             	sub    $0x8,%esp
  801c3b:	ff 75 f4             	pushl  -0xc(%ebp)
  801c3e:	6a 00                	push   $0x0
  801c40:	e8 5f f1 ff ff       	call   800da4 <sys_page_unmap>
  801c45:	83 c4 10             	add    $0x10,%esp
}
  801c48:	89 d8                	mov    %ebx,%eax
  801c4a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c4d:	5b                   	pop    %ebx
  801c4e:	5e                   	pop    %esi
  801c4f:	5d                   	pop    %ebp
  801c50:	c3                   	ret    
	va = fd2data(fd0);
  801c51:	83 ec 0c             	sub    $0xc,%esp
  801c54:	ff 75 f4             	pushl  -0xc(%ebp)
  801c57:	e8 c5 f5 ff ff       	call   801221 <fd2data>
  801c5c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c5e:	83 c4 0c             	add    $0xc,%esp
  801c61:	68 07 04 00 00       	push   $0x407
  801c66:	50                   	push   %eax
  801c67:	6a 00                	push   $0x0
  801c69:	e8 b1 f0 ff ff       	call   800d1f <sys_page_alloc>
  801c6e:	89 c3                	mov    %eax,%ebx
  801c70:	83 c4 10             	add    $0x10,%esp
  801c73:	85 c0                	test   %eax,%eax
  801c75:	0f 88 8c 00 00 00    	js     801d07 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c7b:	83 ec 0c             	sub    $0xc,%esp
  801c7e:	ff 75 f0             	pushl  -0x10(%ebp)
  801c81:	e8 9b f5 ff ff       	call   801221 <fd2data>
  801c86:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c8d:	50                   	push   %eax
  801c8e:	6a 00                	push   $0x0
  801c90:	56                   	push   %esi
  801c91:	6a 00                	push   $0x0
  801c93:	e8 ca f0 ff ff       	call   800d62 <sys_page_map>
  801c98:	89 c3                	mov    %eax,%ebx
  801c9a:	83 c4 20             	add    $0x20,%esp
  801c9d:	85 c0                	test   %eax,%eax
  801c9f:	78 58                	js     801cf9 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801ca1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ca4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801caa:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801cac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801caf:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801cb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cb9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cbf:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cc4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801ccb:	83 ec 0c             	sub    $0xc,%esp
  801cce:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd1:	e8 3b f5 ff ff       	call   801211 <fd2num>
  801cd6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cd9:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cdb:	83 c4 04             	add    $0x4,%esp
  801cde:	ff 75 f0             	pushl  -0x10(%ebp)
  801ce1:	e8 2b f5 ff ff       	call   801211 <fd2num>
  801ce6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ce9:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801cec:	83 c4 10             	add    $0x10,%esp
  801cef:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cf4:	e9 4f ff ff ff       	jmp    801c48 <pipe+0x75>
	sys_page_unmap(0, va);
  801cf9:	83 ec 08             	sub    $0x8,%esp
  801cfc:	56                   	push   %esi
  801cfd:	6a 00                	push   $0x0
  801cff:	e8 a0 f0 ff ff       	call   800da4 <sys_page_unmap>
  801d04:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801d07:	83 ec 08             	sub    $0x8,%esp
  801d0a:	ff 75 f0             	pushl  -0x10(%ebp)
  801d0d:	6a 00                	push   $0x0
  801d0f:	e8 90 f0 ff ff       	call   800da4 <sys_page_unmap>
  801d14:	83 c4 10             	add    $0x10,%esp
  801d17:	e9 1c ff ff ff       	jmp    801c38 <pipe+0x65>

00801d1c <pipeisclosed>:
{
  801d1c:	55                   	push   %ebp
  801d1d:	89 e5                	mov    %esp,%ebp
  801d1f:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d22:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d25:	50                   	push   %eax
  801d26:	ff 75 08             	pushl  0x8(%ebp)
  801d29:	e8 59 f5 ff ff       	call   801287 <fd_lookup>
  801d2e:	83 c4 10             	add    $0x10,%esp
  801d31:	85 c0                	test   %eax,%eax
  801d33:	78 18                	js     801d4d <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801d35:	83 ec 0c             	sub    $0xc,%esp
  801d38:	ff 75 f4             	pushl  -0xc(%ebp)
  801d3b:	e8 e1 f4 ff ff       	call   801221 <fd2data>
	return _pipeisclosed(fd, p);
  801d40:	89 c2                	mov    %eax,%edx
  801d42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d45:	e8 30 fd ff ff       	call   801a7a <_pipeisclosed>
  801d4a:	83 c4 10             	add    $0x10,%esp
}
  801d4d:	c9                   	leave  
  801d4e:	c3                   	ret    

00801d4f <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801d4f:	55                   	push   %ebp
  801d50:	89 e5                	mov    %esp,%ebp
  801d52:	56                   	push   %esi
  801d53:	53                   	push   %ebx
  801d54:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801d57:	85 f6                	test   %esi,%esi
  801d59:	74 13                	je     801d6e <wait+0x1f>
	e = &envs[ENVX(envid)];
  801d5b:	89 f3                	mov    %esi,%ebx
  801d5d:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801d63:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  801d66:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  801d6c:	eb 1b                	jmp    801d89 <wait+0x3a>
	assert(envid != 0);
  801d6e:	68 ee 29 80 00       	push   $0x8029ee
  801d73:	68 a3 29 80 00       	push   $0x8029a3
  801d78:	6a 09                	push   $0x9
  801d7a:	68 f9 29 80 00       	push   $0x8029f9
  801d7f:	e8 a8 e4 ff ff       	call   80022c <_panic>
		sys_yield();
  801d84:	e8 77 ef ff ff       	call   800d00 <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801d89:	8b 43 48             	mov    0x48(%ebx),%eax
  801d8c:	39 f0                	cmp    %esi,%eax
  801d8e:	75 07                	jne    801d97 <wait+0x48>
  801d90:	8b 43 54             	mov    0x54(%ebx),%eax
  801d93:	85 c0                	test   %eax,%eax
  801d95:	75 ed                	jne    801d84 <wait+0x35>
}
  801d97:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d9a:	5b                   	pop    %ebx
  801d9b:	5e                   	pop    %esi
  801d9c:	5d                   	pop    %ebp
  801d9d:	c3                   	ret    

00801d9e <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d9e:	55                   	push   %ebp
  801d9f:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801da1:	b8 00 00 00 00       	mov    $0x0,%eax
  801da6:	5d                   	pop    %ebp
  801da7:	c3                   	ret    

00801da8 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801da8:	55                   	push   %ebp
  801da9:	89 e5                	mov    %esp,%ebp
  801dab:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801dae:	68 04 2a 80 00       	push   $0x802a04
  801db3:	ff 75 0c             	pushl  0xc(%ebp)
  801db6:	e8 6b eb ff ff       	call   800926 <strcpy>
	return 0;
}
  801dbb:	b8 00 00 00 00       	mov    $0x0,%eax
  801dc0:	c9                   	leave  
  801dc1:	c3                   	ret    

00801dc2 <devcons_write>:
{
  801dc2:	55                   	push   %ebp
  801dc3:	89 e5                	mov    %esp,%ebp
  801dc5:	57                   	push   %edi
  801dc6:	56                   	push   %esi
  801dc7:	53                   	push   %ebx
  801dc8:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801dce:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801dd3:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801dd9:	eb 2f                	jmp    801e0a <devcons_write+0x48>
		m = n - tot;
  801ddb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801dde:	29 f3                	sub    %esi,%ebx
  801de0:	83 fb 7f             	cmp    $0x7f,%ebx
  801de3:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801de8:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801deb:	83 ec 04             	sub    $0x4,%esp
  801dee:	53                   	push   %ebx
  801def:	89 f0                	mov    %esi,%eax
  801df1:	03 45 0c             	add    0xc(%ebp),%eax
  801df4:	50                   	push   %eax
  801df5:	57                   	push   %edi
  801df6:	e8 b9 ec ff ff       	call   800ab4 <memmove>
		sys_cputs(buf, m);
  801dfb:	83 c4 08             	add    $0x8,%esp
  801dfe:	53                   	push   %ebx
  801dff:	57                   	push   %edi
  801e00:	e8 5e ee ff ff       	call   800c63 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801e05:	01 de                	add    %ebx,%esi
  801e07:	83 c4 10             	add    $0x10,%esp
  801e0a:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e0d:	72 cc                	jb     801ddb <devcons_write+0x19>
}
  801e0f:	89 f0                	mov    %esi,%eax
  801e11:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e14:	5b                   	pop    %ebx
  801e15:	5e                   	pop    %esi
  801e16:	5f                   	pop    %edi
  801e17:	5d                   	pop    %ebp
  801e18:	c3                   	ret    

00801e19 <devcons_read>:
{
  801e19:	55                   	push   %ebp
  801e1a:	89 e5                	mov    %esp,%ebp
  801e1c:	83 ec 08             	sub    $0x8,%esp
  801e1f:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801e24:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e28:	75 07                	jne    801e31 <devcons_read+0x18>
}
  801e2a:	c9                   	leave  
  801e2b:	c3                   	ret    
		sys_yield();
  801e2c:	e8 cf ee ff ff       	call   800d00 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801e31:	e8 4b ee ff ff       	call   800c81 <sys_cgetc>
  801e36:	85 c0                	test   %eax,%eax
  801e38:	74 f2                	je     801e2c <devcons_read+0x13>
	if (c < 0)
  801e3a:	85 c0                	test   %eax,%eax
  801e3c:	78 ec                	js     801e2a <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  801e3e:	83 f8 04             	cmp    $0x4,%eax
  801e41:	74 0c                	je     801e4f <devcons_read+0x36>
	*(char*)vbuf = c;
  801e43:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e46:	88 02                	mov    %al,(%edx)
	return 1;
  801e48:	b8 01 00 00 00       	mov    $0x1,%eax
  801e4d:	eb db                	jmp    801e2a <devcons_read+0x11>
		return 0;
  801e4f:	b8 00 00 00 00       	mov    $0x0,%eax
  801e54:	eb d4                	jmp    801e2a <devcons_read+0x11>

00801e56 <cputchar>:
{
  801e56:	55                   	push   %ebp
  801e57:	89 e5                	mov    %esp,%ebp
  801e59:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e5c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e5f:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801e62:	6a 01                	push   $0x1
  801e64:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e67:	50                   	push   %eax
  801e68:	e8 f6 ed ff ff       	call   800c63 <sys_cputs>
}
  801e6d:	83 c4 10             	add    $0x10,%esp
  801e70:	c9                   	leave  
  801e71:	c3                   	ret    

00801e72 <getchar>:
{
  801e72:	55                   	push   %ebp
  801e73:	89 e5                	mov    %esp,%ebp
  801e75:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801e78:	6a 01                	push   $0x1
  801e7a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e7d:	50                   	push   %eax
  801e7e:	6a 00                	push   $0x0
  801e80:	e8 73 f6 ff ff       	call   8014f8 <read>
	if (r < 0)
  801e85:	83 c4 10             	add    $0x10,%esp
  801e88:	85 c0                	test   %eax,%eax
  801e8a:	78 08                	js     801e94 <getchar+0x22>
	if (r < 1)
  801e8c:	85 c0                	test   %eax,%eax
  801e8e:	7e 06                	jle    801e96 <getchar+0x24>
	return c;
  801e90:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801e94:	c9                   	leave  
  801e95:	c3                   	ret    
		return -E_EOF;
  801e96:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801e9b:	eb f7                	jmp    801e94 <getchar+0x22>

00801e9d <iscons>:
{
  801e9d:	55                   	push   %ebp
  801e9e:	89 e5                	mov    %esp,%ebp
  801ea0:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ea3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ea6:	50                   	push   %eax
  801ea7:	ff 75 08             	pushl  0x8(%ebp)
  801eaa:	e8 d8 f3 ff ff       	call   801287 <fd_lookup>
  801eaf:	83 c4 10             	add    $0x10,%esp
  801eb2:	85 c0                	test   %eax,%eax
  801eb4:	78 11                	js     801ec7 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801eb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ebf:	39 10                	cmp    %edx,(%eax)
  801ec1:	0f 94 c0             	sete   %al
  801ec4:	0f b6 c0             	movzbl %al,%eax
}
  801ec7:	c9                   	leave  
  801ec8:	c3                   	ret    

00801ec9 <opencons>:
{
  801ec9:	55                   	push   %ebp
  801eca:	89 e5                	mov    %esp,%ebp
  801ecc:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801ecf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ed2:	50                   	push   %eax
  801ed3:	e8 60 f3 ff ff       	call   801238 <fd_alloc>
  801ed8:	83 c4 10             	add    $0x10,%esp
  801edb:	85 c0                	test   %eax,%eax
  801edd:	78 3a                	js     801f19 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801edf:	83 ec 04             	sub    $0x4,%esp
  801ee2:	68 07 04 00 00       	push   $0x407
  801ee7:	ff 75 f4             	pushl  -0xc(%ebp)
  801eea:	6a 00                	push   $0x0
  801eec:	e8 2e ee ff ff       	call   800d1f <sys_page_alloc>
  801ef1:	83 c4 10             	add    $0x10,%esp
  801ef4:	85 c0                	test   %eax,%eax
  801ef6:	78 21                	js     801f19 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801ef8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801efb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f01:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f06:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f0d:	83 ec 0c             	sub    $0xc,%esp
  801f10:	50                   	push   %eax
  801f11:	e8 fb f2 ff ff       	call   801211 <fd2num>
  801f16:	83 c4 10             	add    $0x10,%esp
}
  801f19:	c9                   	leave  
  801f1a:	c3                   	ret    

00801f1b <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f1b:	55                   	push   %ebp
  801f1c:	89 e5                	mov    %esp,%ebp
  801f1e:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f21:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f28:	74 0a                	je     801f34 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler %e",r);
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
	}
       
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f2a:	8b 45 08             	mov    0x8(%ebp),%eax
  801f2d:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f32:	c9                   	leave  
  801f33:	c3                   	ret    
		if((r=sys_page_alloc(thisenv->env_id,(void *)UXSTACKTOP-PGSIZE,PTE_P|PTE_W|PTE_U))<0)
  801f34:	a1 20 44 80 00       	mov    0x804420,%eax
  801f39:	8b 40 48             	mov    0x48(%eax),%eax
  801f3c:	83 ec 04             	sub    $0x4,%esp
  801f3f:	6a 07                	push   $0x7
  801f41:	68 00 f0 bf ee       	push   $0xeebff000
  801f46:	50                   	push   %eax
  801f47:	e8 d3 ed ff ff       	call   800d1f <sys_page_alloc>
  801f4c:	83 c4 10             	add    $0x10,%esp
  801f4f:	85 c0                	test   %eax,%eax
  801f51:	78 1b                	js     801f6e <set_pgfault_handler+0x53>
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
  801f53:	a1 20 44 80 00       	mov    0x804420,%eax
  801f58:	8b 40 48             	mov    0x48(%eax),%eax
  801f5b:	83 ec 08             	sub    $0x8,%esp
  801f5e:	68 80 1f 80 00       	push   $0x801f80
  801f63:	50                   	push   %eax
  801f64:	e8 01 ef ff ff       	call   800e6a <sys_env_set_pgfault_upcall>
  801f69:	83 c4 10             	add    $0x10,%esp
  801f6c:	eb bc                	jmp    801f2a <set_pgfault_handler+0xf>
			panic("set_pgfault_handler %e",r);
  801f6e:	50                   	push   %eax
  801f6f:	68 10 2a 80 00       	push   $0x802a10
  801f74:	6a 22                	push   $0x22
  801f76:	68 27 2a 80 00       	push   $0x802a27
  801f7b:	e8 ac e2 ff ff       	call   80022c <_panic>

00801f80 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f80:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f81:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f86:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f88:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 48(%esp), %ebp
  801f8b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
        subl $4, %ebp
  801f8f:	83 ed 04             	sub    $0x4,%ebp
        movl %ebp, 48(%esp)
  801f92:	89 6c 24 30          	mov    %ebp,0x30(%esp)
        movl 40(%esp), %eax
  801f96:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl %eax, (%ebp)
  801f9a:	89 45 00             	mov    %eax,0x0(%ebp)
	// Restore the trap-time registers.  After you do this, you
 	// can no longer modify any general-purpose registers.
 	// LAB 4: Your code here.
        addl $8, %esp
  801f9d:	83 c4 08             	add    $0x8,%esp
        popal
  801fa0:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $4, %esp
  801fa1:	83 c4 04             	add    $0x4,%esp
        popfl
  801fa4:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  801fa5:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  801fa6:	c3                   	ret    

00801fa7 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fa7:	55                   	push   %ebp
  801fa8:	89 e5                	mov    %esp,%ebp
  801faa:	56                   	push   %esi
  801fab:	53                   	push   %ebx
  801fac:	8b 75 08             	mov    0x8(%ebp),%esi
  801faf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fb2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        //	panic("ipc_recv not implemented");
        int r;
       	if(pg!=NULL){
  801fb5:	85 c0                	test   %eax,%eax
  801fb7:	74 3b                	je     801ff4 <ipc_recv+0x4d>
	  r = sys_ipc_recv(pg);
  801fb9:	83 ec 0c             	sub    $0xc,%esp
  801fbc:	50                   	push   %eax
  801fbd:	e8 0d ef ff ff       	call   800ecf <sys_ipc_recv>
  801fc2:	83 c4 10             	add    $0x10,%esp
	}else
	  r = sys_ipc_recv((void *)UTOP);
	if(r<0){
  801fc5:	85 c0                	test   %eax,%eax
  801fc7:	78 3d                	js     802006 <ipc_recv+0x5f>
	if(perm_store!=NULL){
		*perm_store = 0;
            }
        	return r;
           }else{
	     if(from_env_store!=NULL)
  801fc9:	85 f6                	test   %esi,%esi
  801fcb:	74 0a                	je     801fd7 <ipc_recv+0x30>
		     *from_env_store = thisenv->env_ipc_from;
  801fcd:	a1 20 44 80 00       	mov    0x804420,%eax
  801fd2:	8b 40 74             	mov    0x74(%eax),%eax
  801fd5:	89 06                	mov    %eax,(%esi)
	     if(perm_store != NULL)
  801fd7:	85 db                	test   %ebx,%ebx
  801fd9:	74 0a                	je     801fe5 <ipc_recv+0x3e>
		     *perm_store = thisenv->env_ipc_perm;
  801fdb:	a1 20 44 80 00       	mov    0x804420,%eax
  801fe0:	8b 40 78             	mov    0x78(%eax),%eax
  801fe3:	89 03                	mov    %eax,(%ebx)
	     return thisenv->env_ipc_value;
  801fe5:	a1 20 44 80 00       	mov    0x804420,%eax
  801fea:	8b 40 70             	mov    0x70(%eax),%eax
	   }

}
  801fed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ff0:	5b                   	pop    %ebx
  801ff1:	5e                   	pop    %esi
  801ff2:	5d                   	pop    %ebp
  801ff3:	c3                   	ret    
	  r = sys_ipc_recv((void *)UTOP);
  801ff4:	83 ec 0c             	sub    $0xc,%esp
  801ff7:	68 00 00 c0 ee       	push   $0xeec00000
  801ffc:	e8 ce ee ff ff       	call   800ecf <sys_ipc_recv>
  802001:	83 c4 10             	add    $0x10,%esp
  802004:	eb bf                	jmp    801fc5 <ipc_recv+0x1e>
	if(from_env_store!=NULL){
  802006:	85 f6                	test   %esi,%esi
  802008:	74 06                	je     802010 <ipc_recv+0x69>
	  *from_env_store = 0;
  80200a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if(perm_store!=NULL){
  802010:	85 db                	test   %ebx,%ebx
  802012:	74 d9                	je     801fed <ipc_recv+0x46>
		*perm_store = 0;
  802014:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80201a:	eb d1                	jmp    801fed <ipc_recv+0x46>

0080201c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80201c:	55                   	push   %ebp
  80201d:	89 e5                	mov    %esp,%ebp
  80201f:	57                   	push   %edi
  802020:	56                   	push   %esi
  802021:	53                   	push   %ebx
  802022:	83 ec 0c             	sub    $0xc,%esp
  802025:	8b 7d 08             	mov    0x8(%ebp),%edi
  802028:	8b 75 0c             	mov    0xc(%ebp),%esi
  80202b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if(pg==NULL) pg = (void *)UTOP;
  80202e:	85 db                	test   %ebx,%ebx
  802030:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802035:	0f 44 d8             	cmove  %eax,%ebx
	while((r=sys_ipc_try_send(to_env,val,pg,perm))<0){
  802038:	ff 75 14             	pushl  0x14(%ebp)
  80203b:	53                   	push   %ebx
  80203c:	56                   	push   %esi
  80203d:	57                   	push   %edi
  80203e:	e8 69 ee ff ff       	call   800eac <sys_ipc_try_send>
  802043:	83 c4 10             	add    $0x10,%esp
  802046:	85 c0                	test   %eax,%eax
  802048:	79 20                	jns    80206a <ipc_send+0x4e>
	    if(r!=-E_IPC_NOT_RECV){
  80204a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80204d:	75 07                	jne    802056 <ipc_send+0x3a>
		    panic("ipc_send:send message failed\n");
	    }
	    sys_yield();
  80204f:	e8 ac ec ff ff       	call   800d00 <sys_yield>
  802054:	eb e2                	jmp    802038 <ipc_send+0x1c>
		    panic("ipc_send:send message failed\n");
  802056:	83 ec 04             	sub    $0x4,%esp
  802059:	68 35 2a 80 00       	push   $0x802a35
  80205e:	6a 43                	push   $0x43
  802060:	68 53 2a 80 00       	push   $0x802a53
  802065:	e8 c2 e1 ff ff       	call   80022c <_panic>
	}

}
  80206a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80206d:	5b                   	pop    %ebx
  80206e:	5e                   	pop    %esi
  80206f:	5f                   	pop    %edi
  802070:	5d                   	pop    %ebp
  802071:	c3                   	ret    

00802072 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802072:	55                   	push   %ebp
  802073:	89 e5                	mov    %esp,%ebp
  802075:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802078:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80207d:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802080:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802086:	8b 52 50             	mov    0x50(%edx),%edx
  802089:	39 ca                	cmp    %ecx,%edx
  80208b:	74 11                	je     80209e <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  80208d:	83 c0 01             	add    $0x1,%eax
  802090:	3d 00 04 00 00       	cmp    $0x400,%eax
  802095:	75 e6                	jne    80207d <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  802097:	b8 00 00 00 00       	mov    $0x0,%eax
  80209c:	eb 0b                	jmp    8020a9 <ipc_find_env+0x37>
			return envs[i].env_id;
  80209e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020a1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020a6:	8b 40 48             	mov    0x48(%eax),%eax
}
  8020a9:	5d                   	pop    %ebp
  8020aa:	c3                   	ret    

008020ab <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020ab:	55                   	push   %ebp
  8020ac:	89 e5                	mov    %esp,%ebp
  8020ae:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020b1:	89 d0                	mov    %edx,%eax
  8020b3:	c1 e8 16             	shr    $0x16,%eax
  8020b6:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020bd:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  8020c2:	f6 c1 01             	test   $0x1,%cl
  8020c5:	74 1d                	je     8020e4 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  8020c7:	c1 ea 0c             	shr    $0xc,%edx
  8020ca:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020d1:	f6 c2 01             	test   $0x1,%dl
  8020d4:	74 0e                	je     8020e4 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020d6:	c1 ea 0c             	shr    $0xc,%edx
  8020d9:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020e0:	ef 
  8020e1:	0f b7 c0             	movzwl %ax,%eax
}
  8020e4:	5d                   	pop    %ebp
  8020e5:	c3                   	ret    
  8020e6:	66 90                	xchg   %ax,%ax
  8020e8:	66 90                	xchg   %ax,%ax
  8020ea:	66 90                	xchg   %ax,%ax
  8020ec:	66 90                	xchg   %ax,%ax
  8020ee:	66 90                	xchg   %ax,%ax

008020f0 <__udivdi3>:
  8020f0:	55                   	push   %ebp
  8020f1:	57                   	push   %edi
  8020f2:	56                   	push   %esi
  8020f3:	53                   	push   %ebx
  8020f4:	83 ec 1c             	sub    $0x1c,%esp
  8020f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020fb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8020ff:	8b 74 24 34          	mov    0x34(%esp),%esi
  802103:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  802107:	85 d2                	test   %edx,%edx
  802109:	75 35                	jne    802140 <__udivdi3+0x50>
  80210b:	39 f3                	cmp    %esi,%ebx
  80210d:	0f 87 bd 00 00 00    	ja     8021d0 <__udivdi3+0xe0>
  802113:	85 db                	test   %ebx,%ebx
  802115:	89 d9                	mov    %ebx,%ecx
  802117:	75 0b                	jne    802124 <__udivdi3+0x34>
  802119:	b8 01 00 00 00       	mov    $0x1,%eax
  80211e:	31 d2                	xor    %edx,%edx
  802120:	f7 f3                	div    %ebx
  802122:	89 c1                	mov    %eax,%ecx
  802124:	31 d2                	xor    %edx,%edx
  802126:	89 f0                	mov    %esi,%eax
  802128:	f7 f1                	div    %ecx
  80212a:	89 c6                	mov    %eax,%esi
  80212c:	89 e8                	mov    %ebp,%eax
  80212e:	89 f7                	mov    %esi,%edi
  802130:	f7 f1                	div    %ecx
  802132:	89 fa                	mov    %edi,%edx
  802134:	83 c4 1c             	add    $0x1c,%esp
  802137:	5b                   	pop    %ebx
  802138:	5e                   	pop    %esi
  802139:	5f                   	pop    %edi
  80213a:	5d                   	pop    %ebp
  80213b:	c3                   	ret    
  80213c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802140:	39 f2                	cmp    %esi,%edx
  802142:	77 7c                	ja     8021c0 <__udivdi3+0xd0>
  802144:	0f bd fa             	bsr    %edx,%edi
  802147:	83 f7 1f             	xor    $0x1f,%edi
  80214a:	0f 84 98 00 00 00    	je     8021e8 <__udivdi3+0xf8>
  802150:	89 f9                	mov    %edi,%ecx
  802152:	b8 20 00 00 00       	mov    $0x20,%eax
  802157:	29 f8                	sub    %edi,%eax
  802159:	d3 e2                	shl    %cl,%edx
  80215b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80215f:	89 c1                	mov    %eax,%ecx
  802161:	89 da                	mov    %ebx,%edx
  802163:	d3 ea                	shr    %cl,%edx
  802165:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802169:	09 d1                	or     %edx,%ecx
  80216b:	89 f2                	mov    %esi,%edx
  80216d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802171:	89 f9                	mov    %edi,%ecx
  802173:	d3 e3                	shl    %cl,%ebx
  802175:	89 c1                	mov    %eax,%ecx
  802177:	d3 ea                	shr    %cl,%edx
  802179:	89 f9                	mov    %edi,%ecx
  80217b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80217f:	d3 e6                	shl    %cl,%esi
  802181:	89 eb                	mov    %ebp,%ebx
  802183:	89 c1                	mov    %eax,%ecx
  802185:	d3 eb                	shr    %cl,%ebx
  802187:	09 de                	or     %ebx,%esi
  802189:	89 f0                	mov    %esi,%eax
  80218b:	f7 74 24 08          	divl   0x8(%esp)
  80218f:	89 d6                	mov    %edx,%esi
  802191:	89 c3                	mov    %eax,%ebx
  802193:	f7 64 24 0c          	mull   0xc(%esp)
  802197:	39 d6                	cmp    %edx,%esi
  802199:	72 0c                	jb     8021a7 <__udivdi3+0xb7>
  80219b:	89 f9                	mov    %edi,%ecx
  80219d:	d3 e5                	shl    %cl,%ebp
  80219f:	39 c5                	cmp    %eax,%ebp
  8021a1:	73 5d                	jae    802200 <__udivdi3+0x110>
  8021a3:	39 d6                	cmp    %edx,%esi
  8021a5:	75 59                	jne    802200 <__udivdi3+0x110>
  8021a7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8021aa:	31 ff                	xor    %edi,%edi
  8021ac:	89 fa                	mov    %edi,%edx
  8021ae:	83 c4 1c             	add    $0x1c,%esp
  8021b1:	5b                   	pop    %ebx
  8021b2:	5e                   	pop    %esi
  8021b3:	5f                   	pop    %edi
  8021b4:	5d                   	pop    %ebp
  8021b5:	c3                   	ret    
  8021b6:	8d 76 00             	lea    0x0(%esi),%esi
  8021b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8021c0:	31 ff                	xor    %edi,%edi
  8021c2:	31 c0                	xor    %eax,%eax
  8021c4:	89 fa                	mov    %edi,%edx
  8021c6:	83 c4 1c             	add    $0x1c,%esp
  8021c9:	5b                   	pop    %ebx
  8021ca:	5e                   	pop    %esi
  8021cb:	5f                   	pop    %edi
  8021cc:	5d                   	pop    %ebp
  8021cd:	c3                   	ret    
  8021ce:	66 90                	xchg   %ax,%ax
  8021d0:	31 ff                	xor    %edi,%edi
  8021d2:	89 e8                	mov    %ebp,%eax
  8021d4:	89 f2                	mov    %esi,%edx
  8021d6:	f7 f3                	div    %ebx
  8021d8:	89 fa                	mov    %edi,%edx
  8021da:	83 c4 1c             	add    $0x1c,%esp
  8021dd:	5b                   	pop    %ebx
  8021de:	5e                   	pop    %esi
  8021df:	5f                   	pop    %edi
  8021e0:	5d                   	pop    %ebp
  8021e1:	c3                   	ret    
  8021e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021e8:	39 f2                	cmp    %esi,%edx
  8021ea:	72 06                	jb     8021f2 <__udivdi3+0x102>
  8021ec:	31 c0                	xor    %eax,%eax
  8021ee:	39 eb                	cmp    %ebp,%ebx
  8021f0:	77 d2                	ja     8021c4 <__udivdi3+0xd4>
  8021f2:	b8 01 00 00 00       	mov    $0x1,%eax
  8021f7:	eb cb                	jmp    8021c4 <__udivdi3+0xd4>
  8021f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802200:	89 d8                	mov    %ebx,%eax
  802202:	31 ff                	xor    %edi,%edi
  802204:	eb be                	jmp    8021c4 <__udivdi3+0xd4>
  802206:	66 90                	xchg   %ax,%ax
  802208:	66 90                	xchg   %ax,%ax
  80220a:	66 90                	xchg   %ax,%ax
  80220c:	66 90                	xchg   %ax,%ax
  80220e:	66 90                	xchg   %ax,%ax

00802210 <__umoddi3>:
  802210:	55                   	push   %ebp
  802211:	57                   	push   %edi
  802212:	56                   	push   %esi
  802213:	53                   	push   %ebx
  802214:	83 ec 1c             	sub    $0x1c,%esp
  802217:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80221b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80221f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802223:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802227:	85 ed                	test   %ebp,%ebp
  802229:	89 f0                	mov    %esi,%eax
  80222b:	89 da                	mov    %ebx,%edx
  80222d:	75 19                	jne    802248 <__umoddi3+0x38>
  80222f:	39 df                	cmp    %ebx,%edi
  802231:	0f 86 b1 00 00 00    	jbe    8022e8 <__umoddi3+0xd8>
  802237:	f7 f7                	div    %edi
  802239:	89 d0                	mov    %edx,%eax
  80223b:	31 d2                	xor    %edx,%edx
  80223d:	83 c4 1c             	add    $0x1c,%esp
  802240:	5b                   	pop    %ebx
  802241:	5e                   	pop    %esi
  802242:	5f                   	pop    %edi
  802243:	5d                   	pop    %ebp
  802244:	c3                   	ret    
  802245:	8d 76 00             	lea    0x0(%esi),%esi
  802248:	39 dd                	cmp    %ebx,%ebp
  80224a:	77 f1                	ja     80223d <__umoddi3+0x2d>
  80224c:	0f bd cd             	bsr    %ebp,%ecx
  80224f:	83 f1 1f             	xor    $0x1f,%ecx
  802252:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802256:	0f 84 b4 00 00 00    	je     802310 <__umoddi3+0x100>
  80225c:	b8 20 00 00 00       	mov    $0x20,%eax
  802261:	89 c2                	mov    %eax,%edx
  802263:	8b 44 24 04          	mov    0x4(%esp),%eax
  802267:	29 c2                	sub    %eax,%edx
  802269:	89 c1                	mov    %eax,%ecx
  80226b:	89 f8                	mov    %edi,%eax
  80226d:	d3 e5                	shl    %cl,%ebp
  80226f:	89 d1                	mov    %edx,%ecx
  802271:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802275:	d3 e8                	shr    %cl,%eax
  802277:	09 c5                	or     %eax,%ebp
  802279:	8b 44 24 04          	mov    0x4(%esp),%eax
  80227d:	89 c1                	mov    %eax,%ecx
  80227f:	d3 e7                	shl    %cl,%edi
  802281:	89 d1                	mov    %edx,%ecx
  802283:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802287:	89 df                	mov    %ebx,%edi
  802289:	d3 ef                	shr    %cl,%edi
  80228b:	89 c1                	mov    %eax,%ecx
  80228d:	89 f0                	mov    %esi,%eax
  80228f:	d3 e3                	shl    %cl,%ebx
  802291:	89 d1                	mov    %edx,%ecx
  802293:	89 fa                	mov    %edi,%edx
  802295:	d3 e8                	shr    %cl,%eax
  802297:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80229c:	09 d8                	or     %ebx,%eax
  80229e:	f7 f5                	div    %ebp
  8022a0:	d3 e6                	shl    %cl,%esi
  8022a2:	89 d1                	mov    %edx,%ecx
  8022a4:	f7 64 24 08          	mull   0x8(%esp)
  8022a8:	39 d1                	cmp    %edx,%ecx
  8022aa:	89 c3                	mov    %eax,%ebx
  8022ac:	89 d7                	mov    %edx,%edi
  8022ae:	72 06                	jb     8022b6 <__umoddi3+0xa6>
  8022b0:	75 0e                	jne    8022c0 <__umoddi3+0xb0>
  8022b2:	39 c6                	cmp    %eax,%esi
  8022b4:	73 0a                	jae    8022c0 <__umoddi3+0xb0>
  8022b6:	2b 44 24 08          	sub    0x8(%esp),%eax
  8022ba:	19 ea                	sbb    %ebp,%edx
  8022bc:	89 d7                	mov    %edx,%edi
  8022be:	89 c3                	mov    %eax,%ebx
  8022c0:	89 ca                	mov    %ecx,%edx
  8022c2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8022c7:	29 de                	sub    %ebx,%esi
  8022c9:	19 fa                	sbb    %edi,%edx
  8022cb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  8022cf:	89 d0                	mov    %edx,%eax
  8022d1:	d3 e0                	shl    %cl,%eax
  8022d3:	89 d9                	mov    %ebx,%ecx
  8022d5:	d3 ee                	shr    %cl,%esi
  8022d7:	d3 ea                	shr    %cl,%edx
  8022d9:	09 f0                	or     %esi,%eax
  8022db:	83 c4 1c             	add    $0x1c,%esp
  8022de:	5b                   	pop    %ebx
  8022df:	5e                   	pop    %esi
  8022e0:	5f                   	pop    %edi
  8022e1:	5d                   	pop    %ebp
  8022e2:	c3                   	ret    
  8022e3:	90                   	nop
  8022e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022e8:	85 ff                	test   %edi,%edi
  8022ea:	89 f9                	mov    %edi,%ecx
  8022ec:	75 0b                	jne    8022f9 <__umoddi3+0xe9>
  8022ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8022f3:	31 d2                	xor    %edx,%edx
  8022f5:	f7 f7                	div    %edi
  8022f7:	89 c1                	mov    %eax,%ecx
  8022f9:	89 d8                	mov    %ebx,%eax
  8022fb:	31 d2                	xor    %edx,%edx
  8022fd:	f7 f1                	div    %ecx
  8022ff:	89 f0                	mov    %esi,%eax
  802301:	f7 f1                	div    %ecx
  802303:	e9 31 ff ff ff       	jmp    802239 <__umoddi3+0x29>
  802308:	90                   	nop
  802309:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802310:	39 dd                	cmp    %ebx,%ebp
  802312:	72 08                	jb     80231c <__umoddi3+0x10c>
  802314:	39 f7                	cmp    %esi,%edi
  802316:	0f 87 21 ff ff ff    	ja     80223d <__umoddi3+0x2d>
  80231c:	89 da                	mov    %ebx,%edx
  80231e:	89 f0                	mov    %esi,%eax
  802320:	29 f8                	sub    %edi,%eax
  802322:	19 ea                	sbb    %ebp,%edx
  802324:	e9 14 ff ff ff       	jmp    80223d <__umoddi3+0x2d>
