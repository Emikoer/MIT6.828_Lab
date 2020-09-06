
obj/user/icode.debug:     file format elf32-i386


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
  80002c:	e8 03 01 00 00       	call   800134 <libmain>
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
  800038:	81 ec 1c 02 00 00    	sub    $0x21c,%esp
	int fd, n, r;
	char buf[512+1];

	binaryname = "icode";
  80003e:	c7 05 00 30 80 00 c0 	movl   $0x8024c0,0x803000
  800045:	24 80 00 

	cprintf("icode startup\n");
  800048:	68 c6 24 80 00       	push   $0x8024c6
  80004d:	e8 1d 02 00 00       	call   80026f <cprintf>

	cprintf("icode: open /motd\n");
  800052:	c7 04 24 d5 24 80 00 	movl   $0x8024d5,(%esp)
  800059:	e8 11 02 00 00       	call   80026f <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  80005e:	83 c4 08             	add    $0x8,%esp
  800061:	6a 00                	push   $0x0
  800063:	68 e8 24 80 00       	push   $0x8024e8
  800068:	e8 57 15 00 00       	call   8015c4 <open>
  80006d:	89 c6                	mov    %eax,%esi
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	85 c0                	test   %eax,%eax
  800074:	78 18                	js     80008e <umain+0x5b>
		panic("icode: open /motd: %e", fd);

	cprintf("icode: read /motd\n");
  800076:	83 ec 0c             	sub    $0xc,%esp
  800079:	68 11 25 80 00       	push   $0x802511
  80007e:	e8 ec 01 00 00       	call   80026f <cprintf>
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	8d 9d f7 fd ff ff    	lea    -0x209(%ebp),%ebx
  80008c:	eb 1f                	jmp    8000ad <umain+0x7a>
		panic("icode: open /motd: %e", fd);
  80008e:	50                   	push   %eax
  80008f:	68 ee 24 80 00       	push   $0x8024ee
  800094:	6a 0f                	push   $0xf
  800096:	68 04 25 80 00       	push   $0x802504
  80009b:	e8 f4 00 00 00       	call   800194 <_panic>
		sys_cputs(buf, n);
  8000a0:	83 ec 08             	sub    $0x8,%esp
  8000a3:	50                   	push   %eax
  8000a4:	53                   	push   %ebx
  8000a5:	e8 21 0b 00 00       	call   800bcb <sys_cputs>
  8000aa:	83 c4 10             	add    $0x10,%esp
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  8000ad:	83 ec 04             	sub    $0x4,%esp
  8000b0:	68 00 02 00 00       	push   $0x200
  8000b5:	53                   	push   %ebx
  8000b6:	56                   	push   %esi
  8000b7:	e8 a3 10 00 00       	call   80115f <read>
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	85 c0                	test   %eax,%eax
  8000c1:	7f dd                	jg     8000a0 <umain+0x6d>

	cprintf("icode: close /motd\n");
  8000c3:	83 ec 0c             	sub    $0xc,%esp
  8000c6:	68 24 25 80 00       	push   $0x802524
  8000cb:	e8 9f 01 00 00       	call   80026f <cprintf>
	close(fd);
  8000d0:	89 34 24             	mov    %esi,(%esp)
  8000d3:	e8 4b 0f 00 00       	call   801023 <close>

	cprintf("icode: spawn /init\n");
  8000d8:	c7 04 24 38 25 80 00 	movl   $0x802538,(%esp)
  8000df:	e8 8b 01 00 00       	call   80026f <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  8000e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000eb:	68 4c 25 80 00       	push   $0x80254c
  8000f0:	68 55 25 80 00       	push   $0x802555
  8000f5:	68 5f 25 80 00       	push   $0x80255f
  8000fa:	68 5e 25 80 00       	push   $0x80255e
  8000ff:	e8 eb 1a 00 00       	call   801bef <spawnl>
  800104:	83 c4 20             	add    $0x20,%esp
  800107:	85 c0                	test   %eax,%eax
  800109:	78 17                	js     800122 <umain+0xef>
		panic("icode: spawn /init: %e", r);

	cprintf("icode: exiting\n");
  80010b:	83 ec 0c             	sub    $0xc,%esp
  80010e:	68 7b 25 80 00       	push   $0x80257b
  800113:	e8 57 01 00 00       	call   80026f <cprintf>
}
  800118:	83 c4 10             	add    $0x10,%esp
  80011b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80011e:	5b                   	pop    %ebx
  80011f:	5e                   	pop    %esi
  800120:	5d                   	pop    %ebp
  800121:	c3                   	ret    
		panic("icode: spawn /init: %e", r);
  800122:	50                   	push   %eax
  800123:	68 64 25 80 00       	push   $0x802564
  800128:	6a 1a                	push   $0x1a
  80012a:	68 04 25 80 00       	push   $0x802504
  80012f:	e8 60 00 00 00       	call   800194 <_panic>

00800134 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	56                   	push   %esi
  800138:	53                   	push   %ebx
  800139:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80013c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80013f:	e8 05 0b 00 00       	call   800c49 <sys_getenvid>
  800144:	25 ff 03 00 00       	and    $0x3ff,%eax
  800149:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80014c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800151:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800156:	85 db                	test   %ebx,%ebx
  800158:	7e 07                	jle    800161 <libmain+0x2d>
		binaryname = argv[0];
  80015a:	8b 06                	mov    (%esi),%eax
  80015c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800161:	83 ec 08             	sub    $0x8,%esp
  800164:	56                   	push   %esi
  800165:	53                   	push   %ebx
  800166:	e8 c8 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80016b:	e8 0a 00 00 00       	call   80017a <exit>
}
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800176:	5b                   	pop    %ebx
  800177:	5e                   	pop    %esi
  800178:	5d                   	pop    %ebp
  800179:	c3                   	ret    

0080017a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80017a:	55                   	push   %ebp
  80017b:	89 e5                	mov    %esp,%ebp
  80017d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800180:	e8 c9 0e 00 00       	call   80104e <close_all>
	sys_env_destroy(0);
  800185:	83 ec 0c             	sub    $0xc,%esp
  800188:	6a 00                	push   $0x0
  80018a:	e8 79 0a 00 00       	call   800c08 <sys_env_destroy>
}
  80018f:	83 c4 10             	add    $0x10,%esp
  800192:	c9                   	leave  
  800193:	c3                   	ret    

00800194 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	56                   	push   %esi
  800198:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800199:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80019c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001a2:	e8 a2 0a 00 00       	call   800c49 <sys_getenvid>
  8001a7:	83 ec 0c             	sub    $0xc,%esp
  8001aa:	ff 75 0c             	pushl  0xc(%ebp)
  8001ad:	ff 75 08             	pushl  0x8(%ebp)
  8001b0:	56                   	push   %esi
  8001b1:	50                   	push   %eax
  8001b2:	68 98 25 80 00       	push   $0x802598
  8001b7:	e8 b3 00 00 00       	call   80026f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001bc:	83 c4 18             	add    $0x18,%esp
  8001bf:	53                   	push   %ebx
  8001c0:	ff 75 10             	pushl  0x10(%ebp)
  8001c3:	e8 56 00 00 00       	call   80021e <vcprintf>
	cprintf("\n");
  8001c8:	c7 04 24 78 2a 80 00 	movl   $0x802a78,(%esp)
  8001cf:	e8 9b 00 00 00       	call   80026f <cprintf>
  8001d4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d7:	cc                   	int3   
  8001d8:	eb fd                	jmp    8001d7 <_panic+0x43>

008001da <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001da:	55                   	push   %ebp
  8001db:	89 e5                	mov    %esp,%ebp
  8001dd:	53                   	push   %ebx
  8001de:	83 ec 04             	sub    $0x4,%esp
  8001e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001e4:	8b 13                	mov    (%ebx),%edx
  8001e6:	8d 42 01             	lea    0x1(%edx),%eax
  8001e9:	89 03                	mov    %eax,(%ebx)
  8001eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ee:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001f2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f7:	74 09                	je     800202 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001f9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800200:	c9                   	leave  
  800201:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800202:	83 ec 08             	sub    $0x8,%esp
  800205:	68 ff 00 00 00       	push   $0xff
  80020a:	8d 43 08             	lea    0x8(%ebx),%eax
  80020d:	50                   	push   %eax
  80020e:	e8 b8 09 00 00       	call   800bcb <sys_cputs>
		b->idx = 0;
  800213:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800219:	83 c4 10             	add    $0x10,%esp
  80021c:	eb db                	jmp    8001f9 <putch+0x1f>

0080021e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80021e:	55                   	push   %ebp
  80021f:	89 e5                	mov    %esp,%ebp
  800221:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800227:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80022e:	00 00 00 
	b.cnt = 0;
  800231:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800238:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80023b:	ff 75 0c             	pushl  0xc(%ebp)
  80023e:	ff 75 08             	pushl  0x8(%ebp)
  800241:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800247:	50                   	push   %eax
  800248:	68 da 01 80 00       	push   $0x8001da
  80024d:	e8 1a 01 00 00       	call   80036c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800252:	83 c4 08             	add    $0x8,%esp
  800255:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80025b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800261:	50                   	push   %eax
  800262:	e8 64 09 00 00       	call   800bcb <sys_cputs>

	return b.cnt;
}
  800267:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80026d:	c9                   	leave  
  80026e:	c3                   	ret    

0080026f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
  800272:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800275:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800278:	50                   	push   %eax
  800279:	ff 75 08             	pushl  0x8(%ebp)
  80027c:	e8 9d ff ff ff       	call   80021e <vcprintf>
	va_end(ap);

	return cnt;
}
  800281:	c9                   	leave  
  800282:	c3                   	ret    

00800283 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800283:	55                   	push   %ebp
  800284:	89 e5                	mov    %esp,%ebp
  800286:	57                   	push   %edi
  800287:	56                   	push   %esi
  800288:	53                   	push   %ebx
  800289:	83 ec 1c             	sub    $0x1c,%esp
  80028c:	89 c7                	mov    %eax,%edi
  80028e:	89 d6                	mov    %edx,%esi
  800290:	8b 45 08             	mov    0x8(%ebp),%eax
  800293:	8b 55 0c             	mov    0xc(%ebp),%edx
  800296:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800299:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80029c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80029f:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002a7:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002aa:	39 d3                	cmp    %edx,%ebx
  8002ac:	72 05                	jb     8002b3 <printnum+0x30>
  8002ae:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002b1:	77 7a                	ja     80032d <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b3:	83 ec 0c             	sub    $0xc,%esp
  8002b6:	ff 75 18             	pushl  0x18(%ebp)
  8002b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8002bc:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002bf:	53                   	push   %ebx
  8002c0:	ff 75 10             	pushl  0x10(%ebp)
  8002c3:	83 ec 08             	sub    $0x8,%esp
  8002c6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c9:	ff 75 e0             	pushl  -0x20(%ebp)
  8002cc:	ff 75 dc             	pushl  -0x24(%ebp)
  8002cf:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d2:	e8 a9 1f 00 00       	call   802280 <__udivdi3>
  8002d7:	83 c4 18             	add    $0x18,%esp
  8002da:	52                   	push   %edx
  8002db:	50                   	push   %eax
  8002dc:	89 f2                	mov    %esi,%edx
  8002de:	89 f8                	mov    %edi,%eax
  8002e0:	e8 9e ff ff ff       	call   800283 <printnum>
  8002e5:	83 c4 20             	add    $0x20,%esp
  8002e8:	eb 13                	jmp    8002fd <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ea:	83 ec 08             	sub    $0x8,%esp
  8002ed:	56                   	push   %esi
  8002ee:	ff 75 18             	pushl  0x18(%ebp)
  8002f1:	ff d7                	call   *%edi
  8002f3:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002f6:	83 eb 01             	sub    $0x1,%ebx
  8002f9:	85 db                	test   %ebx,%ebx
  8002fb:	7f ed                	jg     8002ea <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002fd:	83 ec 08             	sub    $0x8,%esp
  800300:	56                   	push   %esi
  800301:	83 ec 04             	sub    $0x4,%esp
  800304:	ff 75 e4             	pushl  -0x1c(%ebp)
  800307:	ff 75 e0             	pushl  -0x20(%ebp)
  80030a:	ff 75 dc             	pushl  -0x24(%ebp)
  80030d:	ff 75 d8             	pushl  -0x28(%ebp)
  800310:	e8 8b 20 00 00       	call   8023a0 <__umoddi3>
  800315:	83 c4 14             	add    $0x14,%esp
  800318:	0f be 80 bb 25 80 00 	movsbl 0x8025bb(%eax),%eax
  80031f:	50                   	push   %eax
  800320:	ff d7                	call   *%edi
}
  800322:	83 c4 10             	add    $0x10,%esp
  800325:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800328:	5b                   	pop    %ebx
  800329:	5e                   	pop    %esi
  80032a:	5f                   	pop    %edi
  80032b:	5d                   	pop    %ebp
  80032c:	c3                   	ret    
  80032d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800330:	eb c4                	jmp    8002f6 <printnum+0x73>

00800332 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800332:	55                   	push   %ebp
  800333:	89 e5                	mov    %esp,%ebp
  800335:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800338:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80033c:	8b 10                	mov    (%eax),%edx
  80033e:	3b 50 04             	cmp    0x4(%eax),%edx
  800341:	73 0a                	jae    80034d <sprintputch+0x1b>
		*b->buf++ = ch;
  800343:	8d 4a 01             	lea    0x1(%edx),%ecx
  800346:	89 08                	mov    %ecx,(%eax)
  800348:	8b 45 08             	mov    0x8(%ebp),%eax
  80034b:	88 02                	mov    %al,(%edx)
}
  80034d:	5d                   	pop    %ebp
  80034e:	c3                   	ret    

0080034f <printfmt>:
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
  800352:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800355:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800358:	50                   	push   %eax
  800359:	ff 75 10             	pushl  0x10(%ebp)
  80035c:	ff 75 0c             	pushl  0xc(%ebp)
  80035f:	ff 75 08             	pushl  0x8(%ebp)
  800362:	e8 05 00 00 00       	call   80036c <vprintfmt>
}
  800367:	83 c4 10             	add    $0x10,%esp
  80036a:	c9                   	leave  
  80036b:	c3                   	ret    

0080036c <vprintfmt>:
{
  80036c:	55                   	push   %ebp
  80036d:	89 e5                	mov    %esp,%ebp
  80036f:	57                   	push   %edi
  800370:	56                   	push   %esi
  800371:	53                   	push   %ebx
  800372:	83 ec 2c             	sub    $0x2c,%esp
  800375:	8b 75 08             	mov    0x8(%ebp),%esi
  800378:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80037b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80037e:	e9 c1 03 00 00       	jmp    800744 <vprintfmt+0x3d8>
		padc = ' ';
  800383:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800387:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  80038e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800395:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80039c:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003a1:	8d 47 01             	lea    0x1(%edi),%eax
  8003a4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003a7:	0f b6 17             	movzbl (%edi),%edx
  8003aa:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003ad:	3c 55                	cmp    $0x55,%al
  8003af:	0f 87 12 04 00 00    	ja     8007c7 <vprintfmt+0x45b>
  8003b5:	0f b6 c0             	movzbl %al,%eax
  8003b8:	ff 24 85 00 27 80 00 	jmp    *0x802700(,%eax,4)
  8003bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8003c2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8003c6:	eb d9                	jmp    8003a1 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8003c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  8003cb:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003cf:	eb d0                	jmp    8003a1 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8003d1:	0f b6 d2             	movzbl %dl,%edx
  8003d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8003dc:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003df:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003e2:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003e6:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003e9:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003ec:	83 f9 09             	cmp    $0x9,%ecx
  8003ef:	77 55                	ja     800446 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  8003f1:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003f4:	eb e9                	jmp    8003df <vprintfmt+0x73>
			precision = va_arg(ap, int);
  8003f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f9:	8b 00                	mov    (%eax),%eax
  8003fb:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800401:	8d 40 04             	lea    0x4(%eax),%eax
  800404:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800407:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80040a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80040e:	79 91                	jns    8003a1 <vprintfmt+0x35>
				width = precision, precision = -1;
  800410:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800413:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800416:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80041d:	eb 82                	jmp    8003a1 <vprintfmt+0x35>
  80041f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800422:	85 c0                	test   %eax,%eax
  800424:	ba 00 00 00 00       	mov    $0x0,%edx
  800429:	0f 49 d0             	cmovns %eax,%edx
  80042c:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80042f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800432:	e9 6a ff ff ff       	jmp    8003a1 <vprintfmt+0x35>
  800437:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80043a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800441:	e9 5b ff ff ff       	jmp    8003a1 <vprintfmt+0x35>
  800446:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800449:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80044c:	eb bc                	jmp    80040a <vprintfmt+0x9e>
			lflag++;
  80044e:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800451:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800454:	e9 48 ff ff ff       	jmp    8003a1 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  800459:	8b 45 14             	mov    0x14(%ebp),%eax
  80045c:	8d 78 04             	lea    0x4(%eax),%edi
  80045f:	83 ec 08             	sub    $0x8,%esp
  800462:	53                   	push   %ebx
  800463:	ff 30                	pushl  (%eax)
  800465:	ff d6                	call   *%esi
			break;
  800467:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80046a:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80046d:	e9 cf 02 00 00       	jmp    800741 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  800472:	8b 45 14             	mov    0x14(%ebp),%eax
  800475:	8d 78 04             	lea    0x4(%eax),%edi
  800478:	8b 00                	mov    (%eax),%eax
  80047a:	99                   	cltd   
  80047b:	31 d0                	xor    %edx,%eax
  80047d:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80047f:	83 f8 0f             	cmp    $0xf,%eax
  800482:	7f 23                	jg     8004a7 <vprintfmt+0x13b>
  800484:	8b 14 85 60 28 80 00 	mov    0x802860(,%eax,4),%edx
  80048b:	85 d2                	test   %edx,%edx
  80048d:	74 18                	je     8004a7 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  80048f:	52                   	push   %edx
  800490:	68 91 29 80 00       	push   $0x802991
  800495:	53                   	push   %ebx
  800496:	56                   	push   %esi
  800497:	e8 b3 fe ff ff       	call   80034f <printfmt>
  80049c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80049f:	89 7d 14             	mov    %edi,0x14(%ebp)
  8004a2:	e9 9a 02 00 00       	jmp    800741 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  8004a7:	50                   	push   %eax
  8004a8:	68 d3 25 80 00       	push   $0x8025d3
  8004ad:	53                   	push   %ebx
  8004ae:	56                   	push   %esi
  8004af:	e8 9b fe ff ff       	call   80034f <printfmt>
  8004b4:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004b7:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8004ba:	e9 82 02 00 00       	jmp    800741 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  8004bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c2:	83 c0 04             	add    $0x4,%eax
  8004c5:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8004c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cb:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004cd:	85 ff                	test   %edi,%edi
  8004cf:	b8 cc 25 80 00       	mov    $0x8025cc,%eax
  8004d4:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004d7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004db:	0f 8e bd 00 00 00    	jle    80059e <vprintfmt+0x232>
  8004e1:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004e5:	75 0e                	jne    8004f5 <vprintfmt+0x189>
  8004e7:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ea:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ed:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004f3:	eb 6d                	jmp    800562 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f5:	83 ec 08             	sub    $0x8,%esp
  8004f8:	ff 75 d0             	pushl  -0x30(%ebp)
  8004fb:	57                   	push   %edi
  8004fc:	e8 6e 03 00 00       	call   80086f <strnlen>
  800501:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800504:	29 c1                	sub    %eax,%ecx
  800506:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800509:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80050c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800510:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800513:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800516:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800518:	eb 0f                	jmp    800529 <vprintfmt+0x1bd>
					putch(padc, putdat);
  80051a:	83 ec 08             	sub    $0x8,%esp
  80051d:	53                   	push   %ebx
  80051e:	ff 75 e0             	pushl  -0x20(%ebp)
  800521:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800523:	83 ef 01             	sub    $0x1,%edi
  800526:	83 c4 10             	add    $0x10,%esp
  800529:	85 ff                	test   %edi,%edi
  80052b:	7f ed                	jg     80051a <vprintfmt+0x1ae>
  80052d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800530:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800533:	85 c9                	test   %ecx,%ecx
  800535:	b8 00 00 00 00       	mov    $0x0,%eax
  80053a:	0f 49 c1             	cmovns %ecx,%eax
  80053d:	29 c1                	sub    %eax,%ecx
  80053f:	89 75 08             	mov    %esi,0x8(%ebp)
  800542:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800545:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800548:	89 cb                	mov    %ecx,%ebx
  80054a:	eb 16                	jmp    800562 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  80054c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800550:	75 31                	jne    800583 <vprintfmt+0x217>
					putch(ch, putdat);
  800552:	83 ec 08             	sub    $0x8,%esp
  800555:	ff 75 0c             	pushl  0xc(%ebp)
  800558:	50                   	push   %eax
  800559:	ff 55 08             	call   *0x8(%ebp)
  80055c:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80055f:	83 eb 01             	sub    $0x1,%ebx
  800562:	83 c7 01             	add    $0x1,%edi
  800565:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800569:	0f be c2             	movsbl %dl,%eax
  80056c:	85 c0                	test   %eax,%eax
  80056e:	74 59                	je     8005c9 <vprintfmt+0x25d>
  800570:	85 f6                	test   %esi,%esi
  800572:	78 d8                	js     80054c <vprintfmt+0x1e0>
  800574:	83 ee 01             	sub    $0x1,%esi
  800577:	79 d3                	jns    80054c <vprintfmt+0x1e0>
  800579:	89 df                	mov    %ebx,%edi
  80057b:	8b 75 08             	mov    0x8(%ebp),%esi
  80057e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800581:	eb 37                	jmp    8005ba <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  800583:	0f be d2             	movsbl %dl,%edx
  800586:	83 ea 20             	sub    $0x20,%edx
  800589:	83 fa 5e             	cmp    $0x5e,%edx
  80058c:	76 c4                	jbe    800552 <vprintfmt+0x1e6>
					putch('?', putdat);
  80058e:	83 ec 08             	sub    $0x8,%esp
  800591:	ff 75 0c             	pushl  0xc(%ebp)
  800594:	6a 3f                	push   $0x3f
  800596:	ff 55 08             	call   *0x8(%ebp)
  800599:	83 c4 10             	add    $0x10,%esp
  80059c:	eb c1                	jmp    80055f <vprintfmt+0x1f3>
  80059e:	89 75 08             	mov    %esi,0x8(%ebp)
  8005a1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005a4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005a7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005aa:	eb b6                	jmp    800562 <vprintfmt+0x1f6>
				putch(' ', putdat);
  8005ac:	83 ec 08             	sub    $0x8,%esp
  8005af:	53                   	push   %ebx
  8005b0:	6a 20                	push   $0x20
  8005b2:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8005b4:	83 ef 01             	sub    $0x1,%edi
  8005b7:	83 c4 10             	add    $0x10,%esp
  8005ba:	85 ff                	test   %edi,%edi
  8005bc:	7f ee                	jg     8005ac <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  8005be:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005c1:	89 45 14             	mov    %eax,0x14(%ebp)
  8005c4:	e9 78 01 00 00       	jmp    800741 <vprintfmt+0x3d5>
  8005c9:	89 df                	mov    %ebx,%edi
  8005cb:	8b 75 08             	mov    0x8(%ebp),%esi
  8005ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005d1:	eb e7                	jmp    8005ba <vprintfmt+0x24e>
	if (lflag >= 2)
  8005d3:	83 f9 01             	cmp    $0x1,%ecx
  8005d6:	7e 3f                	jle    800617 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  8005d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005db:	8b 50 04             	mov    0x4(%eax),%edx
  8005de:	8b 00                	mov    (%eax),%eax
  8005e0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e9:	8d 40 08             	lea    0x8(%eax),%eax
  8005ec:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005ef:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005f3:	79 5c                	jns    800651 <vprintfmt+0x2e5>
				putch('-', putdat);
  8005f5:	83 ec 08             	sub    $0x8,%esp
  8005f8:	53                   	push   %ebx
  8005f9:	6a 2d                	push   $0x2d
  8005fb:	ff d6                	call   *%esi
				num = -(long long) num;
  8005fd:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800600:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800603:	f7 da                	neg    %edx
  800605:	83 d1 00             	adc    $0x0,%ecx
  800608:	f7 d9                	neg    %ecx
  80060a:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80060d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800612:	e9 10 01 00 00       	jmp    800727 <vprintfmt+0x3bb>
	else if (lflag)
  800617:	85 c9                	test   %ecx,%ecx
  800619:	75 1b                	jne    800636 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  80061b:	8b 45 14             	mov    0x14(%ebp),%eax
  80061e:	8b 00                	mov    (%eax),%eax
  800620:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800623:	89 c1                	mov    %eax,%ecx
  800625:	c1 f9 1f             	sar    $0x1f,%ecx
  800628:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80062b:	8b 45 14             	mov    0x14(%ebp),%eax
  80062e:	8d 40 04             	lea    0x4(%eax),%eax
  800631:	89 45 14             	mov    %eax,0x14(%ebp)
  800634:	eb b9                	jmp    8005ef <vprintfmt+0x283>
		return va_arg(*ap, long);
  800636:	8b 45 14             	mov    0x14(%ebp),%eax
  800639:	8b 00                	mov    (%eax),%eax
  80063b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80063e:	89 c1                	mov    %eax,%ecx
  800640:	c1 f9 1f             	sar    $0x1f,%ecx
  800643:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800646:	8b 45 14             	mov    0x14(%ebp),%eax
  800649:	8d 40 04             	lea    0x4(%eax),%eax
  80064c:	89 45 14             	mov    %eax,0x14(%ebp)
  80064f:	eb 9e                	jmp    8005ef <vprintfmt+0x283>
			num = getint(&ap, lflag);
  800651:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800654:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800657:	b8 0a 00 00 00       	mov    $0xa,%eax
  80065c:	e9 c6 00 00 00       	jmp    800727 <vprintfmt+0x3bb>
	if (lflag >= 2)
  800661:	83 f9 01             	cmp    $0x1,%ecx
  800664:	7e 18                	jle    80067e <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  800666:	8b 45 14             	mov    0x14(%ebp),%eax
  800669:	8b 10                	mov    (%eax),%edx
  80066b:	8b 48 04             	mov    0x4(%eax),%ecx
  80066e:	8d 40 08             	lea    0x8(%eax),%eax
  800671:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800674:	b8 0a 00 00 00       	mov    $0xa,%eax
  800679:	e9 a9 00 00 00       	jmp    800727 <vprintfmt+0x3bb>
	else if (lflag)
  80067e:	85 c9                	test   %ecx,%ecx
  800680:	75 1a                	jne    80069c <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  800682:	8b 45 14             	mov    0x14(%ebp),%eax
  800685:	8b 10                	mov    (%eax),%edx
  800687:	b9 00 00 00 00       	mov    $0x0,%ecx
  80068c:	8d 40 04             	lea    0x4(%eax),%eax
  80068f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800692:	b8 0a 00 00 00       	mov    $0xa,%eax
  800697:	e9 8b 00 00 00       	jmp    800727 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80069c:	8b 45 14             	mov    0x14(%ebp),%eax
  80069f:	8b 10                	mov    (%eax),%edx
  8006a1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006a6:	8d 40 04             	lea    0x4(%eax),%eax
  8006a9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006ac:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006b1:	eb 74                	jmp    800727 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8006b3:	83 f9 01             	cmp    $0x1,%ecx
  8006b6:	7e 15                	jle    8006cd <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  8006b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bb:	8b 10                	mov    (%eax),%edx
  8006bd:	8b 48 04             	mov    0x4(%eax),%ecx
  8006c0:	8d 40 08             	lea    0x8(%eax),%eax
  8006c3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006c6:	b8 08 00 00 00       	mov    $0x8,%eax
  8006cb:	eb 5a                	jmp    800727 <vprintfmt+0x3bb>
	else if (lflag)
  8006cd:	85 c9                	test   %ecx,%ecx
  8006cf:	75 17                	jne    8006e8 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  8006d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d4:	8b 10                	mov    (%eax),%edx
  8006d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006db:	8d 40 04             	lea    0x4(%eax),%eax
  8006de:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006e1:	b8 08 00 00 00       	mov    $0x8,%eax
  8006e6:	eb 3f                	jmp    800727 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8006e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006eb:	8b 10                	mov    (%eax),%edx
  8006ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f2:	8d 40 04             	lea    0x4(%eax),%eax
  8006f5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006f8:	b8 08 00 00 00       	mov    $0x8,%eax
  8006fd:	eb 28                	jmp    800727 <vprintfmt+0x3bb>
			putch('0', putdat);
  8006ff:	83 ec 08             	sub    $0x8,%esp
  800702:	53                   	push   %ebx
  800703:	6a 30                	push   $0x30
  800705:	ff d6                	call   *%esi
			putch('x', putdat);
  800707:	83 c4 08             	add    $0x8,%esp
  80070a:	53                   	push   %ebx
  80070b:	6a 78                	push   $0x78
  80070d:	ff d6                	call   *%esi
			num = (unsigned long long)
  80070f:	8b 45 14             	mov    0x14(%ebp),%eax
  800712:	8b 10                	mov    (%eax),%edx
  800714:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800719:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80071c:	8d 40 04             	lea    0x4(%eax),%eax
  80071f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800722:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800727:	83 ec 0c             	sub    $0xc,%esp
  80072a:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80072e:	57                   	push   %edi
  80072f:	ff 75 e0             	pushl  -0x20(%ebp)
  800732:	50                   	push   %eax
  800733:	51                   	push   %ecx
  800734:	52                   	push   %edx
  800735:	89 da                	mov    %ebx,%edx
  800737:	89 f0                	mov    %esi,%eax
  800739:	e8 45 fb ff ff       	call   800283 <printnum>
			break;
  80073e:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800741:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800744:	83 c7 01             	add    $0x1,%edi
  800747:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80074b:	83 f8 25             	cmp    $0x25,%eax
  80074e:	0f 84 2f fc ff ff    	je     800383 <vprintfmt+0x17>
			if (ch == '\0')
  800754:	85 c0                	test   %eax,%eax
  800756:	0f 84 8b 00 00 00    	je     8007e7 <vprintfmt+0x47b>
			putch(ch, putdat);
  80075c:	83 ec 08             	sub    $0x8,%esp
  80075f:	53                   	push   %ebx
  800760:	50                   	push   %eax
  800761:	ff d6                	call   *%esi
  800763:	83 c4 10             	add    $0x10,%esp
  800766:	eb dc                	jmp    800744 <vprintfmt+0x3d8>
	if (lflag >= 2)
  800768:	83 f9 01             	cmp    $0x1,%ecx
  80076b:	7e 15                	jle    800782 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  80076d:	8b 45 14             	mov    0x14(%ebp),%eax
  800770:	8b 10                	mov    (%eax),%edx
  800772:	8b 48 04             	mov    0x4(%eax),%ecx
  800775:	8d 40 08             	lea    0x8(%eax),%eax
  800778:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80077b:	b8 10 00 00 00       	mov    $0x10,%eax
  800780:	eb a5                	jmp    800727 <vprintfmt+0x3bb>
	else if (lflag)
  800782:	85 c9                	test   %ecx,%ecx
  800784:	75 17                	jne    80079d <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  800786:	8b 45 14             	mov    0x14(%ebp),%eax
  800789:	8b 10                	mov    (%eax),%edx
  80078b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800790:	8d 40 04             	lea    0x4(%eax),%eax
  800793:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800796:	b8 10 00 00 00       	mov    $0x10,%eax
  80079b:	eb 8a                	jmp    800727 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80079d:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a0:	8b 10                	mov    (%eax),%edx
  8007a2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007a7:	8d 40 04             	lea    0x4(%eax),%eax
  8007aa:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007ad:	b8 10 00 00 00       	mov    $0x10,%eax
  8007b2:	e9 70 ff ff ff       	jmp    800727 <vprintfmt+0x3bb>
			putch(ch, putdat);
  8007b7:	83 ec 08             	sub    $0x8,%esp
  8007ba:	53                   	push   %ebx
  8007bb:	6a 25                	push   $0x25
  8007bd:	ff d6                	call   *%esi
			break;
  8007bf:	83 c4 10             	add    $0x10,%esp
  8007c2:	e9 7a ff ff ff       	jmp    800741 <vprintfmt+0x3d5>
			putch('%', putdat);
  8007c7:	83 ec 08             	sub    $0x8,%esp
  8007ca:	53                   	push   %ebx
  8007cb:	6a 25                	push   $0x25
  8007cd:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007cf:	83 c4 10             	add    $0x10,%esp
  8007d2:	89 f8                	mov    %edi,%eax
  8007d4:	eb 03                	jmp    8007d9 <vprintfmt+0x46d>
  8007d6:	83 e8 01             	sub    $0x1,%eax
  8007d9:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007dd:	75 f7                	jne    8007d6 <vprintfmt+0x46a>
  8007df:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007e2:	e9 5a ff ff ff       	jmp    800741 <vprintfmt+0x3d5>
}
  8007e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007ea:	5b                   	pop    %ebx
  8007eb:	5e                   	pop    %esi
  8007ec:	5f                   	pop    %edi
  8007ed:	5d                   	pop    %ebp
  8007ee:	c3                   	ret    

008007ef <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	83 ec 18             	sub    $0x18,%esp
  8007f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007fe:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800802:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800805:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80080c:	85 c0                	test   %eax,%eax
  80080e:	74 26                	je     800836 <vsnprintf+0x47>
  800810:	85 d2                	test   %edx,%edx
  800812:	7e 22                	jle    800836 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800814:	ff 75 14             	pushl  0x14(%ebp)
  800817:	ff 75 10             	pushl  0x10(%ebp)
  80081a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80081d:	50                   	push   %eax
  80081e:	68 32 03 80 00       	push   $0x800332
  800823:	e8 44 fb ff ff       	call   80036c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800828:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80082b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80082e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800831:	83 c4 10             	add    $0x10,%esp
}
  800834:	c9                   	leave  
  800835:	c3                   	ret    
		return -E_INVAL;
  800836:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80083b:	eb f7                	jmp    800834 <vsnprintf+0x45>

0080083d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800843:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800846:	50                   	push   %eax
  800847:	ff 75 10             	pushl  0x10(%ebp)
  80084a:	ff 75 0c             	pushl  0xc(%ebp)
  80084d:	ff 75 08             	pushl  0x8(%ebp)
  800850:	e8 9a ff ff ff       	call   8007ef <vsnprintf>
	va_end(ap);

	return rc;
}
  800855:	c9                   	leave  
  800856:	c3                   	ret    

00800857 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80085d:	b8 00 00 00 00       	mov    $0x0,%eax
  800862:	eb 03                	jmp    800867 <strlen+0x10>
		n++;
  800864:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800867:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80086b:	75 f7                	jne    800864 <strlen+0xd>
	return n;
}
  80086d:	5d                   	pop    %ebp
  80086e:	c3                   	ret    

0080086f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80086f:	55                   	push   %ebp
  800870:	89 e5                	mov    %esp,%ebp
  800872:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800875:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800878:	b8 00 00 00 00       	mov    $0x0,%eax
  80087d:	eb 03                	jmp    800882 <strnlen+0x13>
		n++;
  80087f:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800882:	39 d0                	cmp    %edx,%eax
  800884:	74 06                	je     80088c <strnlen+0x1d>
  800886:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80088a:	75 f3                	jne    80087f <strnlen+0x10>
	return n;
}
  80088c:	5d                   	pop    %ebp
  80088d:	c3                   	ret    

0080088e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80088e:	55                   	push   %ebp
  80088f:	89 e5                	mov    %esp,%ebp
  800891:	53                   	push   %ebx
  800892:	8b 45 08             	mov    0x8(%ebp),%eax
  800895:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800898:	89 c2                	mov    %eax,%edx
  80089a:	83 c1 01             	add    $0x1,%ecx
  80089d:	83 c2 01             	add    $0x1,%edx
  8008a0:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008a4:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008a7:	84 db                	test   %bl,%bl
  8008a9:	75 ef                	jne    80089a <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008ab:	5b                   	pop    %ebx
  8008ac:	5d                   	pop    %ebp
  8008ad:	c3                   	ret    

008008ae <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008ae:	55                   	push   %ebp
  8008af:	89 e5                	mov    %esp,%ebp
  8008b1:	53                   	push   %ebx
  8008b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008b5:	53                   	push   %ebx
  8008b6:	e8 9c ff ff ff       	call   800857 <strlen>
  8008bb:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008be:	ff 75 0c             	pushl  0xc(%ebp)
  8008c1:	01 d8                	add    %ebx,%eax
  8008c3:	50                   	push   %eax
  8008c4:	e8 c5 ff ff ff       	call   80088e <strcpy>
	return dst;
}
  8008c9:	89 d8                	mov    %ebx,%eax
  8008cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008ce:	c9                   	leave  
  8008cf:	c3                   	ret    

008008d0 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	56                   	push   %esi
  8008d4:	53                   	push   %ebx
  8008d5:	8b 75 08             	mov    0x8(%ebp),%esi
  8008d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008db:	89 f3                	mov    %esi,%ebx
  8008dd:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e0:	89 f2                	mov    %esi,%edx
  8008e2:	eb 0f                	jmp    8008f3 <strncpy+0x23>
		*dst++ = *src;
  8008e4:	83 c2 01             	add    $0x1,%edx
  8008e7:	0f b6 01             	movzbl (%ecx),%eax
  8008ea:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008ed:	80 39 01             	cmpb   $0x1,(%ecx)
  8008f0:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8008f3:	39 da                	cmp    %ebx,%edx
  8008f5:	75 ed                	jne    8008e4 <strncpy+0x14>
	}
	return ret;
}
  8008f7:	89 f0                	mov    %esi,%eax
  8008f9:	5b                   	pop    %ebx
  8008fa:	5e                   	pop    %esi
  8008fb:	5d                   	pop    %ebp
  8008fc:	c3                   	ret    

008008fd <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008fd:	55                   	push   %ebp
  8008fe:	89 e5                	mov    %esp,%ebp
  800900:	56                   	push   %esi
  800901:	53                   	push   %ebx
  800902:	8b 75 08             	mov    0x8(%ebp),%esi
  800905:	8b 55 0c             	mov    0xc(%ebp),%edx
  800908:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80090b:	89 f0                	mov    %esi,%eax
  80090d:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800911:	85 c9                	test   %ecx,%ecx
  800913:	75 0b                	jne    800920 <strlcpy+0x23>
  800915:	eb 17                	jmp    80092e <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800917:	83 c2 01             	add    $0x1,%edx
  80091a:	83 c0 01             	add    $0x1,%eax
  80091d:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800920:	39 d8                	cmp    %ebx,%eax
  800922:	74 07                	je     80092b <strlcpy+0x2e>
  800924:	0f b6 0a             	movzbl (%edx),%ecx
  800927:	84 c9                	test   %cl,%cl
  800929:	75 ec                	jne    800917 <strlcpy+0x1a>
		*dst = '\0';
  80092b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80092e:	29 f0                	sub    %esi,%eax
}
  800930:	5b                   	pop    %ebx
  800931:	5e                   	pop    %esi
  800932:	5d                   	pop    %ebp
  800933:	c3                   	ret    

00800934 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80093a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80093d:	eb 06                	jmp    800945 <strcmp+0x11>
		p++, q++;
  80093f:	83 c1 01             	add    $0x1,%ecx
  800942:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800945:	0f b6 01             	movzbl (%ecx),%eax
  800948:	84 c0                	test   %al,%al
  80094a:	74 04                	je     800950 <strcmp+0x1c>
  80094c:	3a 02                	cmp    (%edx),%al
  80094e:	74 ef                	je     80093f <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800950:	0f b6 c0             	movzbl %al,%eax
  800953:	0f b6 12             	movzbl (%edx),%edx
  800956:	29 d0                	sub    %edx,%eax
}
  800958:	5d                   	pop    %ebp
  800959:	c3                   	ret    

0080095a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
  80095d:	53                   	push   %ebx
  80095e:	8b 45 08             	mov    0x8(%ebp),%eax
  800961:	8b 55 0c             	mov    0xc(%ebp),%edx
  800964:	89 c3                	mov    %eax,%ebx
  800966:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800969:	eb 06                	jmp    800971 <strncmp+0x17>
		n--, p++, q++;
  80096b:	83 c0 01             	add    $0x1,%eax
  80096e:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800971:	39 d8                	cmp    %ebx,%eax
  800973:	74 16                	je     80098b <strncmp+0x31>
  800975:	0f b6 08             	movzbl (%eax),%ecx
  800978:	84 c9                	test   %cl,%cl
  80097a:	74 04                	je     800980 <strncmp+0x26>
  80097c:	3a 0a                	cmp    (%edx),%cl
  80097e:	74 eb                	je     80096b <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800980:	0f b6 00             	movzbl (%eax),%eax
  800983:	0f b6 12             	movzbl (%edx),%edx
  800986:	29 d0                	sub    %edx,%eax
}
  800988:	5b                   	pop    %ebx
  800989:	5d                   	pop    %ebp
  80098a:	c3                   	ret    
		return 0;
  80098b:	b8 00 00 00 00       	mov    $0x0,%eax
  800990:	eb f6                	jmp    800988 <strncmp+0x2e>

00800992 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	8b 45 08             	mov    0x8(%ebp),%eax
  800998:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80099c:	0f b6 10             	movzbl (%eax),%edx
  80099f:	84 d2                	test   %dl,%dl
  8009a1:	74 09                	je     8009ac <strchr+0x1a>
		if (*s == c)
  8009a3:	38 ca                	cmp    %cl,%dl
  8009a5:	74 0a                	je     8009b1 <strchr+0x1f>
	for (; *s; s++)
  8009a7:	83 c0 01             	add    $0x1,%eax
  8009aa:	eb f0                	jmp    80099c <strchr+0xa>
			return (char *) s;
	return 0;
  8009ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b1:	5d                   	pop    %ebp
  8009b2:	c3                   	ret    

008009b3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009b3:	55                   	push   %ebp
  8009b4:	89 e5                	mov    %esp,%ebp
  8009b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009bd:	eb 03                	jmp    8009c2 <strfind+0xf>
  8009bf:	83 c0 01             	add    $0x1,%eax
  8009c2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009c5:	38 ca                	cmp    %cl,%dl
  8009c7:	74 04                	je     8009cd <strfind+0x1a>
  8009c9:	84 d2                	test   %dl,%dl
  8009cb:	75 f2                	jne    8009bf <strfind+0xc>
			break;
	return (char *) s;
}
  8009cd:	5d                   	pop    %ebp
  8009ce:	c3                   	ret    

008009cf <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009cf:	55                   	push   %ebp
  8009d0:	89 e5                	mov    %esp,%ebp
  8009d2:	57                   	push   %edi
  8009d3:	56                   	push   %esi
  8009d4:	53                   	push   %ebx
  8009d5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009d8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009db:	85 c9                	test   %ecx,%ecx
  8009dd:	74 13                	je     8009f2 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009df:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009e5:	75 05                	jne    8009ec <memset+0x1d>
  8009e7:	f6 c1 03             	test   $0x3,%cl
  8009ea:	74 0d                	je     8009f9 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ef:	fc                   	cld    
  8009f0:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009f2:	89 f8                	mov    %edi,%eax
  8009f4:	5b                   	pop    %ebx
  8009f5:	5e                   	pop    %esi
  8009f6:	5f                   	pop    %edi
  8009f7:	5d                   	pop    %ebp
  8009f8:	c3                   	ret    
		c &= 0xFF;
  8009f9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009fd:	89 d3                	mov    %edx,%ebx
  8009ff:	c1 e3 08             	shl    $0x8,%ebx
  800a02:	89 d0                	mov    %edx,%eax
  800a04:	c1 e0 18             	shl    $0x18,%eax
  800a07:	89 d6                	mov    %edx,%esi
  800a09:	c1 e6 10             	shl    $0x10,%esi
  800a0c:	09 f0                	or     %esi,%eax
  800a0e:	09 c2                	or     %eax,%edx
  800a10:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800a12:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a15:	89 d0                	mov    %edx,%eax
  800a17:	fc                   	cld    
  800a18:	f3 ab                	rep stos %eax,%es:(%edi)
  800a1a:	eb d6                	jmp    8009f2 <memset+0x23>

00800a1c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	57                   	push   %edi
  800a20:	56                   	push   %esi
  800a21:	8b 45 08             	mov    0x8(%ebp),%eax
  800a24:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a27:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a2a:	39 c6                	cmp    %eax,%esi
  800a2c:	73 35                	jae    800a63 <memmove+0x47>
  800a2e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a31:	39 c2                	cmp    %eax,%edx
  800a33:	76 2e                	jbe    800a63 <memmove+0x47>
		s += n;
		d += n;
  800a35:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a38:	89 d6                	mov    %edx,%esi
  800a3a:	09 fe                	or     %edi,%esi
  800a3c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a42:	74 0c                	je     800a50 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a44:	83 ef 01             	sub    $0x1,%edi
  800a47:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a4a:	fd                   	std    
  800a4b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a4d:	fc                   	cld    
  800a4e:	eb 21                	jmp    800a71 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a50:	f6 c1 03             	test   $0x3,%cl
  800a53:	75 ef                	jne    800a44 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a55:	83 ef 04             	sub    $0x4,%edi
  800a58:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a5b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a5e:	fd                   	std    
  800a5f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a61:	eb ea                	jmp    800a4d <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a63:	89 f2                	mov    %esi,%edx
  800a65:	09 c2                	or     %eax,%edx
  800a67:	f6 c2 03             	test   $0x3,%dl
  800a6a:	74 09                	je     800a75 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a6c:	89 c7                	mov    %eax,%edi
  800a6e:	fc                   	cld    
  800a6f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a71:	5e                   	pop    %esi
  800a72:	5f                   	pop    %edi
  800a73:	5d                   	pop    %ebp
  800a74:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a75:	f6 c1 03             	test   $0x3,%cl
  800a78:	75 f2                	jne    800a6c <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a7a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a7d:	89 c7                	mov    %eax,%edi
  800a7f:	fc                   	cld    
  800a80:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a82:	eb ed                	jmp    800a71 <memmove+0x55>

00800a84 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a87:	ff 75 10             	pushl  0x10(%ebp)
  800a8a:	ff 75 0c             	pushl  0xc(%ebp)
  800a8d:	ff 75 08             	pushl  0x8(%ebp)
  800a90:	e8 87 ff ff ff       	call   800a1c <memmove>
}
  800a95:	c9                   	leave  
  800a96:	c3                   	ret    

00800a97 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a97:	55                   	push   %ebp
  800a98:	89 e5                	mov    %esp,%ebp
  800a9a:	56                   	push   %esi
  800a9b:	53                   	push   %ebx
  800a9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa2:	89 c6                	mov    %eax,%esi
  800aa4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aa7:	39 f0                	cmp    %esi,%eax
  800aa9:	74 1c                	je     800ac7 <memcmp+0x30>
		if (*s1 != *s2)
  800aab:	0f b6 08             	movzbl (%eax),%ecx
  800aae:	0f b6 1a             	movzbl (%edx),%ebx
  800ab1:	38 d9                	cmp    %bl,%cl
  800ab3:	75 08                	jne    800abd <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ab5:	83 c0 01             	add    $0x1,%eax
  800ab8:	83 c2 01             	add    $0x1,%edx
  800abb:	eb ea                	jmp    800aa7 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800abd:	0f b6 c1             	movzbl %cl,%eax
  800ac0:	0f b6 db             	movzbl %bl,%ebx
  800ac3:	29 d8                	sub    %ebx,%eax
  800ac5:	eb 05                	jmp    800acc <memcmp+0x35>
	}

	return 0;
  800ac7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800acc:	5b                   	pop    %ebx
  800acd:	5e                   	pop    %esi
  800ace:	5d                   	pop    %ebp
  800acf:	c3                   	ret    

00800ad0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ad0:	55                   	push   %ebp
  800ad1:	89 e5                	mov    %esp,%ebp
  800ad3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ad9:	89 c2                	mov    %eax,%edx
  800adb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ade:	39 d0                	cmp    %edx,%eax
  800ae0:	73 09                	jae    800aeb <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ae2:	38 08                	cmp    %cl,(%eax)
  800ae4:	74 05                	je     800aeb <memfind+0x1b>
	for (; s < ends; s++)
  800ae6:	83 c0 01             	add    $0x1,%eax
  800ae9:	eb f3                	jmp    800ade <memfind+0xe>
			break;
	return (void *) s;
}
  800aeb:	5d                   	pop    %ebp
  800aec:	c3                   	ret    

00800aed <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aed:	55                   	push   %ebp
  800aee:	89 e5                	mov    %esp,%ebp
  800af0:	57                   	push   %edi
  800af1:	56                   	push   %esi
  800af2:	53                   	push   %ebx
  800af3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800af6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800af9:	eb 03                	jmp    800afe <strtol+0x11>
		s++;
  800afb:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800afe:	0f b6 01             	movzbl (%ecx),%eax
  800b01:	3c 20                	cmp    $0x20,%al
  800b03:	74 f6                	je     800afb <strtol+0xe>
  800b05:	3c 09                	cmp    $0x9,%al
  800b07:	74 f2                	je     800afb <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b09:	3c 2b                	cmp    $0x2b,%al
  800b0b:	74 2e                	je     800b3b <strtol+0x4e>
	int neg = 0;
  800b0d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b12:	3c 2d                	cmp    $0x2d,%al
  800b14:	74 2f                	je     800b45 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b16:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b1c:	75 05                	jne    800b23 <strtol+0x36>
  800b1e:	80 39 30             	cmpb   $0x30,(%ecx)
  800b21:	74 2c                	je     800b4f <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b23:	85 db                	test   %ebx,%ebx
  800b25:	75 0a                	jne    800b31 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b27:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800b2c:	80 39 30             	cmpb   $0x30,(%ecx)
  800b2f:	74 28                	je     800b59 <strtol+0x6c>
		base = 10;
  800b31:	b8 00 00 00 00       	mov    $0x0,%eax
  800b36:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b39:	eb 50                	jmp    800b8b <strtol+0x9e>
		s++;
  800b3b:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b3e:	bf 00 00 00 00       	mov    $0x0,%edi
  800b43:	eb d1                	jmp    800b16 <strtol+0x29>
		s++, neg = 1;
  800b45:	83 c1 01             	add    $0x1,%ecx
  800b48:	bf 01 00 00 00       	mov    $0x1,%edi
  800b4d:	eb c7                	jmp    800b16 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b4f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b53:	74 0e                	je     800b63 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b55:	85 db                	test   %ebx,%ebx
  800b57:	75 d8                	jne    800b31 <strtol+0x44>
		s++, base = 8;
  800b59:	83 c1 01             	add    $0x1,%ecx
  800b5c:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b61:	eb ce                	jmp    800b31 <strtol+0x44>
		s += 2, base = 16;
  800b63:	83 c1 02             	add    $0x2,%ecx
  800b66:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b6b:	eb c4                	jmp    800b31 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800b6d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b70:	89 f3                	mov    %esi,%ebx
  800b72:	80 fb 19             	cmp    $0x19,%bl
  800b75:	77 29                	ja     800ba0 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b77:	0f be d2             	movsbl %dl,%edx
  800b7a:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b7d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b80:	7d 30                	jge    800bb2 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b82:	83 c1 01             	add    $0x1,%ecx
  800b85:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b89:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b8b:	0f b6 11             	movzbl (%ecx),%edx
  800b8e:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b91:	89 f3                	mov    %esi,%ebx
  800b93:	80 fb 09             	cmp    $0x9,%bl
  800b96:	77 d5                	ja     800b6d <strtol+0x80>
			dig = *s - '0';
  800b98:	0f be d2             	movsbl %dl,%edx
  800b9b:	83 ea 30             	sub    $0x30,%edx
  800b9e:	eb dd                	jmp    800b7d <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800ba0:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ba3:	89 f3                	mov    %esi,%ebx
  800ba5:	80 fb 19             	cmp    $0x19,%bl
  800ba8:	77 08                	ja     800bb2 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800baa:	0f be d2             	movsbl %dl,%edx
  800bad:	83 ea 37             	sub    $0x37,%edx
  800bb0:	eb cb                	jmp    800b7d <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bb2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bb6:	74 05                	je     800bbd <strtol+0xd0>
		*endptr = (char *) s;
  800bb8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bbb:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800bbd:	89 c2                	mov    %eax,%edx
  800bbf:	f7 da                	neg    %edx
  800bc1:	85 ff                	test   %edi,%edi
  800bc3:	0f 45 c2             	cmovne %edx,%eax
}
  800bc6:	5b                   	pop    %ebx
  800bc7:	5e                   	pop    %esi
  800bc8:	5f                   	pop    %edi
  800bc9:	5d                   	pop    %ebp
  800bca:	c3                   	ret    

00800bcb <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	57                   	push   %edi
  800bcf:	56                   	push   %esi
  800bd0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bd1:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bdc:	89 c3                	mov    %eax,%ebx
  800bde:	89 c7                	mov    %eax,%edi
  800be0:	89 c6                	mov    %eax,%esi
  800be2:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800be4:	5b                   	pop    %ebx
  800be5:	5e                   	pop    %esi
  800be6:	5f                   	pop    %edi
  800be7:	5d                   	pop    %ebp
  800be8:	c3                   	ret    

00800be9 <sys_cgetc>:

int
sys_cgetc(void)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	57                   	push   %edi
  800bed:	56                   	push   %esi
  800bee:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bef:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf4:	b8 01 00 00 00       	mov    $0x1,%eax
  800bf9:	89 d1                	mov    %edx,%ecx
  800bfb:	89 d3                	mov    %edx,%ebx
  800bfd:	89 d7                	mov    %edx,%edi
  800bff:	89 d6                	mov    %edx,%esi
  800c01:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c03:	5b                   	pop    %ebx
  800c04:	5e                   	pop    %esi
  800c05:	5f                   	pop    %edi
  800c06:	5d                   	pop    %ebp
  800c07:	c3                   	ret    

00800c08 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	57                   	push   %edi
  800c0c:	56                   	push   %esi
  800c0d:	53                   	push   %ebx
  800c0e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c11:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c16:	8b 55 08             	mov    0x8(%ebp),%edx
  800c19:	b8 03 00 00 00       	mov    $0x3,%eax
  800c1e:	89 cb                	mov    %ecx,%ebx
  800c20:	89 cf                	mov    %ecx,%edi
  800c22:	89 ce                	mov    %ecx,%esi
  800c24:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c26:	85 c0                	test   %eax,%eax
  800c28:	7f 08                	jg     800c32 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2d:	5b                   	pop    %ebx
  800c2e:	5e                   	pop    %esi
  800c2f:	5f                   	pop    %edi
  800c30:	5d                   	pop    %ebp
  800c31:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c32:	83 ec 0c             	sub    $0xc,%esp
  800c35:	50                   	push   %eax
  800c36:	6a 03                	push   $0x3
  800c38:	68 bf 28 80 00       	push   $0x8028bf
  800c3d:	6a 23                	push   $0x23
  800c3f:	68 dc 28 80 00       	push   $0x8028dc
  800c44:	e8 4b f5 ff ff       	call   800194 <_panic>

00800c49 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c49:	55                   	push   %ebp
  800c4a:	89 e5                	mov    %esp,%ebp
  800c4c:	57                   	push   %edi
  800c4d:	56                   	push   %esi
  800c4e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c4f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c54:	b8 02 00 00 00       	mov    $0x2,%eax
  800c59:	89 d1                	mov    %edx,%ecx
  800c5b:	89 d3                	mov    %edx,%ebx
  800c5d:	89 d7                	mov    %edx,%edi
  800c5f:	89 d6                	mov    %edx,%esi
  800c61:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c63:	5b                   	pop    %ebx
  800c64:	5e                   	pop    %esi
  800c65:	5f                   	pop    %edi
  800c66:	5d                   	pop    %ebp
  800c67:	c3                   	ret    

00800c68 <sys_yield>:

void
sys_yield(void)
{
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	57                   	push   %edi
  800c6c:	56                   	push   %esi
  800c6d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c6e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c73:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c78:	89 d1                	mov    %edx,%ecx
  800c7a:	89 d3                	mov    %edx,%ebx
  800c7c:	89 d7                	mov    %edx,%edi
  800c7e:	89 d6                	mov    %edx,%esi
  800c80:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c82:	5b                   	pop    %ebx
  800c83:	5e                   	pop    %esi
  800c84:	5f                   	pop    %edi
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	57                   	push   %edi
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
  800c8d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c90:	be 00 00 00 00       	mov    $0x0,%esi
  800c95:	8b 55 08             	mov    0x8(%ebp),%edx
  800c98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9b:	b8 04 00 00 00       	mov    $0x4,%eax
  800ca0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca3:	89 f7                	mov    %esi,%edi
  800ca5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ca7:	85 c0                	test   %eax,%eax
  800ca9:	7f 08                	jg     800cb3 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cae:	5b                   	pop    %ebx
  800caf:	5e                   	pop    %esi
  800cb0:	5f                   	pop    %edi
  800cb1:	5d                   	pop    %ebp
  800cb2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb3:	83 ec 0c             	sub    $0xc,%esp
  800cb6:	50                   	push   %eax
  800cb7:	6a 04                	push   $0x4
  800cb9:	68 bf 28 80 00       	push   $0x8028bf
  800cbe:	6a 23                	push   $0x23
  800cc0:	68 dc 28 80 00       	push   $0x8028dc
  800cc5:	e8 ca f4 ff ff       	call   800194 <_panic>

00800cca <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cca:	55                   	push   %ebp
  800ccb:	89 e5                	mov    %esp,%ebp
  800ccd:	57                   	push   %edi
  800cce:	56                   	push   %esi
  800ccf:	53                   	push   %ebx
  800cd0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd9:	b8 05 00 00 00       	mov    $0x5,%eax
  800cde:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ce4:	8b 75 18             	mov    0x18(%ebp),%esi
  800ce7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ce9:	85 c0                	test   %eax,%eax
  800ceb:	7f 08                	jg     800cf5 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ced:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf0:	5b                   	pop    %ebx
  800cf1:	5e                   	pop    %esi
  800cf2:	5f                   	pop    %edi
  800cf3:	5d                   	pop    %ebp
  800cf4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf5:	83 ec 0c             	sub    $0xc,%esp
  800cf8:	50                   	push   %eax
  800cf9:	6a 05                	push   $0x5
  800cfb:	68 bf 28 80 00       	push   $0x8028bf
  800d00:	6a 23                	push   $0x23
  800d02:	68 dc 28 80 00       	push   $0x8028dc
  800d07:	e8 88 f4 ff ff       	call   800194 <_panic>

00800d0c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d0c:	55                   	push   %ebp
  800d0d:	89 e5                	mov    %esp,%ebp
  800d0f:	57                   	push   %edi
  800d10:	56                   	push   %esi
  800d11:	53                   	push   %ebx
  800d12:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d15:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d20:	b8 06 00 00 00       	mov    $0x6,%eax
  800d25:	89 df                	mov    %ebx,%edi
  800d27:	89 de                	mov    %ebx,%esi
  800d29:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d2b:	85 c0                	test   %eax,%eax
  800d2d:	7f 08                	jg     800d37 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d32:	5b                   	pop    %ebx
  800d33:	5e                   	pop    %esi
  800d34:	5f                   	pop    %edi
  800d35:	5d                   	pop    %ebp
  800d36:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d37:	83 ec 0c             	sub    $0xc,%esp
  800d3a:	50                   	push   %eax
  800d3b:	6a 06                	push   $0x6
  800d3d:	68 bf 28 80 00       	push   $0x8028bf
  800d42:	6a 23                	push   $0x23
  800d44:	68 dc 28 80 00       	push   $0x8028dc
  800d49:	e8 46 f4 ff ff       	call   800194 <_panic>

00800d4e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d4e:	55                   	push   %ebp
  800d4f:	89 e5                	mov    %esp,%ebp
  800d51:	57                   	push   %edi
  800d52:	56                   	push   %esi
  800d53:	53                   	push   %ebx
  800d54:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d57:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d62:	b8 08 00 00 00       	mov    $0x8,%eax
  800d67:	89 df                	mov    %ebx,%edi
  800d69:	89 de                	mov    %ebx,%esi
  800d6b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d6d:	85 c0                	test   %eax,%eax
  800d6f:	7f 08                	jg     800d79 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d74:	5b                   	pop    %ebx
  800d75:	5e                   	pop    %esi
  800d76:	5f                   	pop    %edi
  800d77:	5d                   	pop    %ebp
  800d78:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d79:	83 ec 0c             	sub    $0xc,%esp
  800d7c:	50                   	push   %eax
  800d7d:	6a 08                	push   $0x8
  800d7f:	68 bf 28 80 00       	push   $0x8028bf
  800d84:	6a 23                	push   $0x23
  800d86:	68 dc 28 80 00       	push   $0x8028dc
  800d8b:	e8 04 f4 ff ff       	call   800194 <_panic>

00800d90 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	57                   	push   %edi
  800d94:	56                   	push   %esi
  800d95:	53                   	push   %ebx
  800d96:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d99:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800da1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da4:	b8 09 00 00 00       	mov    $0x9,%eax
  800da9:	89 df                	mov    %ebx,%edi
  800dab:	89 de                	mov    %ebx,%esi
  800dad:	cd 30                	int    $0x30
	if(check && ret > 0)
  800daf:	85 c0                	test   %eax,%eax
  800db1:	7f 08                	jg     800dbb <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800db3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db6:	5b                   	pop    %ebx
  800db7:	5e                   	pop    %esi
  800db8:	5f                   	pop    %edi
  800db9:	5d                   	pop    %ebp
  800dba:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dbb:	83 ec 0c             	sub    $0xc,%esp
  800dbe:	50                   	push   %eax
  800dbf:	6a 09                	push   $0x9
  800dc1:	68 bf 28 80 00       	push   $0x8028bf
  800dc6:	6a 23                	push   $0x23
  800dc8:	68 dc 28 80 00       	push   $0x8028dc
  800dcd:	e8 c2 f3 ff ff       	call   800194 <_panic>

00800dd2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dd2:	55                   	push   %ebp
  800dd3:	89 e5                	mov    %esp,%ebp
  800dd5:	57                   	push   %edi
  800dd6:	56                   	push   %esi
  800dd7:	53                   	push   %ebx
  800dd8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ddb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800de0:	8b 55 08             	mov    0x8(%ebp),%edx
  800de3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de6:	b8 0a 00 00 00       	mov    $0xa,%eax
  800deb:	89 df                	mov    %ebx,%edi
  800ded:	89 de                	mov    %ebx,%esi
  800def:	cd 30                	int    $0x30
	if(check && ret > 0)
  800df1:	85 c0                	test   %eax,%eax
  800df3:	7f 08                	jg     800dfd <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800df5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df8:	5b                   	pop    %ebx
  800df9:	5e                   	pop    %esi
  800dfa:	5f                   	pop    %edi
  800dfb:	5d                   	pop    %ebp
  800dfc:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dfd:	83 ec 0c             	sub    $0xc,%esp
  800e00:	50                   	push   %eax
  800e01:	6a 0a                	push   $0xa
  800e03:	68 bf 28 80 00       	push   $0x8028bf
  800e08:	6a 23                	push   $0x23
  800e0a:	68 dc 28 80 00       	push   $0x8028dc
  800e0f:	e8 80 f3 ff ff       	call   800194 <_panic>

00800e14 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e14:	55                   	push   %ebp
  800e15:	89 e5                	mov    %esp,%ebp
  800e17:	57                   	push   %edi
  800e18:	56                   	push   %esi
  800e19:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e20:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e25:	be 00 00 00 00       	mov    $0x0,%esi
  800e2a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e2d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e30:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e32:	5b                   	pop    %ebx
  800e33:	5e                   	pop    %esi
  800e34:	5f                   	pop    %edi
  800e35:	5d                   	pop    %ebp
  800e36:	c3                   	ret    

00800e37 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e37:	55                   	push   %ebp
  800e38:	89 e5                	mov    %esp,%ebp
  800e3a:	57                   	push   %edi
  800e3b:	56                   	push   %esi
  800e3c:	53                   	push   %ebx
  800e3d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e40:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e45:	8b 55 08             	mov    0x8(%ebp),%edx
  800e48:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e4d:	89 cb                	mov    %ecx,%ebx
  800e4f:	89 cf                	mov    %ecx,%edi
  800e51:	89 ce                	mov    %ecx,%esi
  800e53:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e55:	85 c0                	test   %eax,%eax
  800e57:	7f 08                	jg     800e61 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e59:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e5c:	5b                   	pop    %ebx
  800e5d:	5e                   	pop    %esi
  800e5e:	5f                   	pop    %edi
  800e5f:	5d                   	pop    %ebp
  800e60:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e61:	83 ec 0c             	sub    $0xc,%esp
  800e64:	50                   	push   %eax
  800e65:	6a 0d                	push   $0xd
  800e67:	68 bf 28 80 00       	push   $0x8028bf
  800e6c:	6a 23                	push   $0x23
  800e6e:	68 dc 28 80 00       	push   $0x8028dc
  800e73:	e8 1c f3 ff ff       	call   800194 <_panic>

00800e78 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e78:	55                   	push   %ebp
  800e79:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7e:	05 00 00 00 30       	add    $0x30000000,%eax
  800e83:	c1 e8 0c             	shr    $0xc,%eax
}
  800e86:	5d                   	pop    %ebp
  800e87:	c3                   	ret    

00800e88 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e88:	55                   	push   %ebp
  800e89:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8e:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800e93:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e98:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e9d:	5d                   	pop    %ebp
  800e9e:	c3                   	ret    

00800e9f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e9f:	55                   	push   %ebp
  800ea0:	89 e5                	mov    %esp,%ebp
  800ea2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ea5:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800eaa:	89 c2                	mov    %eax,%edx
  800eac:	c1 ea 16             	shr    $0x16,%edx
  800eaf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800eb6:	f6 c2 01             	test   $0x1,%dl
  800eb9:	74 2a                	je     800ee5 <fd_alloc+0x46>
  800ebb:	89 c2                	mov    %eax,%edx
  800ebd:	c1 ea 0c             	shr    $0xc,%edx
  800ec0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ec7:	f6 c2 01             	test   $0x1,%dl
  800eca:	74 19                	je     800ee5 <fd_alloc+0x46>
  800ecc:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800ed1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ed6:	75 d2                	jne    800eaa <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ed8:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800ede:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800ee3:	eb 07                	jmp    800eec <fd_alloc+0x4d>
			*fd_store = fd;
  800ee5:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ee7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800eec:	5d                   	pop    %ebp
  800eed:	c3                   	ret    

00800eee <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800eee:	55                   	push   %ebp
  800eef:	89 e5                	mov    %esp,%ebp
  800ef1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ef4:	83 f8 1f             	cmp    $0x1f,%eax
  800ef7:	77 36                	ja     800f2f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ef9:	c1 e0 0c             	shl    $0xc,%eax
  800efc:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f01:	89 c2                	mov    %eax,%edx
  800f03:	c1 ea 16             	shr    $0x16,%edx
  800f06:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f0d:	f6 c2 01             	test   $0x1,%dl
  800f10:	74 24                	je     800f36 <fd_lookup+0x48>
  800f12:	89 c2                	mov    %eax,%edx
  800f14:	c1 ea 0c             	shr    $0xc,%edx
  800f17:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f1e:	f6 c2 01             	test   $0x1,%dl
  800f21:	74 1a                	je     800f3d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f23:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f26:	89 02                	mov    %eax,(%edx)
	return 0;
  800f28:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f2d:	5d                   	pop    %ebp
  800f2e:	c3                   	ret    
		return -E_INVAL;
  800f2f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f34:	eb f7                	jmp    800f2d <fd_lookup+0x3f>
		return -E_INVAL;
  800f36:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f3b:	eb f0                	jmp    800f2d <fd_lookup+0x3f>
  800f3d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f42:	eb e9                	jmp    800f2d <fd_lookup+0x3f>

00800f44 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f44:	55                   	push   %ebp
  800f45:	89 e5                	mov    %esp,%ebp
  800f47:	83 ec 08             	sub    $0x8,%esp
  800f4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f4d:	ba 68 29 80 00       	mov    $0x802968,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f52:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800f57:	39 08                	cmp    %ecx,(%eax)
  800f59:	74 33                	je     800f8e <dev_lookup+0x4a>
  800f5b:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800f5e:	8b 02                	mov    (%edx),%eax
  800f60:	85 c0                	test   %eax,%eax
  800f62:	75 f3                	jne    800f57 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f64:	a1 04 40 80 00       	mov    0x804004,%eax
  800f69:	8b 40 48             	mov    0x48(%eax),%eax
  800f6c:	83 ec 04             	sub    $0x4,%esp
  800f6f:	51                   	push   %ecx
  800f70:	50                   	push   %eax
  800f71:	68 ec 28 80 00       	push   $0x8028ec
  800f76:	e8 f4 f2 ff ff       	call   80026f <cprintf>
	*dev = 0;
  800f7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f7e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f84:	83 c4 10             	add    $0x10,%esp
  800f87:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f8c:	c9                   	leave  
  800f8d:	c3                   	ret    
			*dev = devtab[i];
  800f8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f91:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f93:	b8 00 00 00 00       	mov    $0x0,%eax
  800f98:	eb f2                	jmp    800f8c <dev_lookup+0x48>

00800f9a <fd_close>:
{
  800f9a:	55                   	push   %ebp
  800f9b:	89 e5                	mov    %esp,%ebp
  800f9d:	57                   	push   %edi
  800f9e:	56                   	push   %esi
  800f9f:	53                   	push   %ebx
  800fa0:	83 ec 1c             	sub    $0x1c,%esp
  800fa3:	8b 75 08             	mov    0x8(%ebp),%esi
  800fa6:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fa9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fac:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fad:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fb3:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fb6:	50                   	push   %eax
  800fb7:	e8 32 ff ff ff       	call   800eee <fd_lookup>
  800fbc:	89 c3                	mov    %eax,%ebx
  800fbe:	83 c4 08             	add    $0x8,%esp
  800fc1:	85 c0                	test   %eax,%eax
  800fc3:	78 05                	js     800fca <fd_close+0x30>
	    || fd != fd2)
  800fc5:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800fc8:	74 16                	je     800fe0 <fd_close+0x46>
		return (must_exist ? r : 0);
  800fca:	89 f8                	mov    %edi,%eax
  800fcc:	84 c0                	test   %al,%al
  800fce:	b8 00 00 00 00       	mov    $0x0,%eax
  800fd3:	0f 44 d8             	cmove  %eax,%ebx
}
  800fd6:	89 d8                	mov    %ebx,%eax
  800fd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fdb:	5b                   	pop    %ebx
  800fdc:	5e                   	pop    %esi
  800fdd:	5f                   	pop    %edi
  800fde:	5d                   	pop    %ebp
  800fdf:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fe0:	83 ec 08             	sub    $0x8,%esp
  800fe3:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800fe6:	50                   	push   %eax
  800fe7:	ff 36                	pushl  (%esi)
  800fe9:	e8 56 ff ff ff       	call   800f44 <dev_lookup>
  800fee:	89 c3                	mov    %eax,%ebx
  800ff0:	83 c4 10             	add    $0x10,%esp
  800ff3:	85 c0                	test   %eax,%eax
  800ff5:	78 15                	js     80100c <fd_close+0x72>
		if (dev->dev_close)
  800ff7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ffa:	8b 40 10             	mov    0x10(%eax),%eax
  800ffd:	85 c0                	test   %eax,%eax
  800fff:	74 1b                	je     80101c <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  801001:	83 ec 0c             	sub    $0xc,%esp
  801004:	56                   	push   %esi
  801005:	ff d0                	call   *%eax
  801007:	89 c3                	mov    %eax,%ebx
  801009:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80100c:	83 ec 08             	sub    $0x8,%esp
  80100f:	56                   	push   %esi
  801010:	6a 00                	push   $0x0
  801012:	e8 f5 fc ff ff       	call   800d0c <sys_page_unmap>
	return r;
  801017:	83 c4 10             	add    $0x10,%esp
  80101a:	eb ba                	jmp    800fd6 <fd_close+0x3c>
			r = 0;
  80101c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801021:	eb e9                	jmp    80100c <fd_close+0x72>

00801023 <close>:

int
close(int fdnum)
{
  801023:	55                   	push   %ebp
  801024:	89 e5                	mov    %esp,%ebp
  801026:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801029:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80102c:	50                   	push   %eax
  80102d:	ff 75 08             	pushl  0x8(%ebp)
  801030:	e8 b9 fe ff ff       	call   800eee <fd_lookup>
  801035:	83 c4 08             	add    $0x8,%esp
  801038:	85 c0                	test   %eax,%eax
  80103a:	78 10                	js     80104c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80103c:	83 ec 08             	sub    $0x8,%esp
  80103f:	6a 01                	push   $0x1
  801041:	ff 75 f4             	pushl  -0xc(%ebp)
  801044:	e8 51 ff ff ff       	call   800f9a <fd_close>
  801049:	83 c4 10             	add    $0x10,%esp
}
  80104c:	c9                   	leave  
  80104d:	c3                   	ret    

0080104e <close_all>:

void
close_all(void)
{
  80104e:	55                   	push   %ebp
  80104f:	89 e5                	mov    %esp,%ebp
  801051:	53                   	push   %ebx
  801052:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801055:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80105a:	83 ec 0c             	sub    $0xc,%esp
  80105d:	53                   	push   %ebx
  80105e:	e8 c0 ff ff ff       	call   801023 <close>
	for (i = 0; i < MAXFD; i++)
  801063:	83 c3 01             	add    $0x1,%ebx
  801066:	83 c4 10             	add    $0x10,%esp
  801069:	83 fb 20             	cmp    $0x20,%ebx
  80106c:	75 ec                	jne    80105a <close_all+0xc>
}
  80106e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801071:	c9                   	leave  
  801072:	c3                   	ret    

00801073 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801073:	55                   	push   %ebp
  801074:	89 e5                	mov    %esp,%ebp
  801076:	57                   	push   %edi
  801077:	56                   	push   %esi
  801078:	53                   	push   %ebx
  801079:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80107c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80107f:	50                   	push   %eax
  801080:	ff 75 08             	pushl  0x8(%ebp)
  801083:	e8 66 fe ff ff       	call   800eee <fd_lookup>
  801088:	89 c3                	mov    %eax,%ebx
  80108a:	83 c4 08             	add    $0x8,%esp
  80108d:	85 c0                	test   %eax,%eax
  80108f:	0f 88 81 00 00 00    	js     801116 <dup+0xa3>
		return r;
	close(newfdnum);
  801095:	83 ec 0c             	sub    $0xc,%esp
  801098:	ff 75 0c             	pushl  0xc(%ebp)
  80109b:	e8 83 ff ff ff       	call   801023 <close>

	newfd = INDEX2FD(newfdnum);
  8010a0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010a3:	c1 e6 0c             	shl    $0xc,%esi
  8010a6:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8010ac:	83 c4 04             	add    $0x4,%esp
  8010af:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010b2:	e8 d1 fd ff ff       	call   800e88 <fd2data>
  8010b7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8010b9:	89 34 24             	mov    %esi,(%esp)
  8010bc:	e8 c7 fd ff ff       	call   800e88 <fd2data>
  8010c1:	83 c4 10             	add    $0x10,%esp
  8010c4:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010c6:	89 d8                	mov    %ebx,%eax
  8010c8:	c1 e8 16             	shr    $0x16,%eax
  8010cb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010d2:	a8 01                	test   $0x1,%al
  8010d4:	74 11                	je     8010e7 <dup+0x74>
  8010d6:	89 d8                	mov    %ebx,%eax
  8010d8:	c1 e8 0c             	shr    $0xc,%eax
  8010db:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010e2:	f6 c2 01             	test   $0x1,%dl
  8010e5:	75 39                	jne    801120 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010e7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010ea:	89 d0                	mov    %edx,%eax
  8010ec:	c1 e8 0c             	shr    $0xc,%eax
  8010ef:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010f6:	83 ec 0c             	sub    $0xc,%esp
  8010f9:	25 07 0e 00 00       	and    $0xe07,%eax
  8010fe:	50                   	push   %eax
  8010ff:	56                   	push   %esi
  801100:	6a 00                	push   $0x0
  801102:	52                   	push   %edx
  801103:	6a 00                	push   $0x0
  801105:	e8 c0 fb ff ff       	call   800cca <sys_page_map>
  80110a:	89 c3                	mov    %eax,%ebx
  80110c:	83 c4 20             	add    $0x20,%esp
  80110f:	85 c0                	test   %eax,%eax
  801111:	78 31                	js     801144 <dup+0xd1>
		goto err;

	return newfdnum;
  801113:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801116:	89 d8                	mov    %ebx,%eax
  801118:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80111b:	5b                   	pop    %ebx
  80111c:	5e                   	pop    %esi
  80111d:	5f                   	pop    %edi
  80111e:	5d                   	pop    %ebp
  80111f:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801120:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801127:	83 ec 0c             	sub    $0xc,%esp
  80112a:	25 07 0e 00 00       	and    $0xe07,%eax
  80112f:	50                   	push   %eax
  801130:	57                   	push   %edi
  801131:	6a 00                	push   $0x0
  801133:	53                   	push   %ebx
  801134:	6a 00                	push   $0x0
  801136:	e8 8f fb ff ff       	call   800cca <sys_page_map>
  80113b:	89 c3                	mov    %eax,%ebx
  80113d:	83 c4 20             	add    $0x20,%esp
  801140:	85 c0                	test   %eax,%eax
  801142:	79 a3                	jns    8010e7 <dup+0x74>
	sys_page_unmap(0, newfd);
  801144:	83 ec 08             	sub    $0x8,%esp
  801147:	56                   	push   %esi
  801148:	6a 00                	push   $0x0
  80114a:	e8 bd fb ff ff       	call   800d0c <sys_page_unmap>
	sys_page_unmap(0, nva);
  80114f:	83 c4 08             	add    $0x8,%esp
  801152:	57                   	push   %edi
  801153:	6a 00                	push   $0x0
  801155:	e8 b2 fb ff ff       	call   800d0c <sys_page_unmap>
	return r;
  80115a:	83 c4 10             	add    $0x10,%esp
  80115d:	eb b7                	jmp    801116 <dup+0xa3>

0080115f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80115f:	55                   	push   %ebp
  801160:	89 e5                	mov    %esp,%ebp
  801162:	53                   	push   %ebx
  801163:	83 ec 14             	sub    $0x14,%esp
  801166:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801169:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80116c:	50                   	push   %eax
  80116d:	53                   	push   %ebx
  80116e:	e8 7b fd ff ff       	call   800eee <fd_lookup>
  801173:	83 c4 08             	add    $0x8,%esp
  801176:	85 c0                	test   %eax,%eax
  801178:	78 3f                	js     8011b9 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80117a:	83 ec 08             	sub    $0x8,%esp
  80117d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801180:	50                   	push   %eax
  801181:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801184:	ff 30                	pushl  (%eax)
  801186:	e8 b9 fd ff ff       	call   800f44 <dev_lookup>
  80118b:	83 c4 10             	add    $0x10,%esp
  80118e:	85 c0                	test   %eax,%eax
  801190:	78 27                	js     8011b9 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801192:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801195:	8b 42 08             	mov    0x8(%edx),%eax
  801198:	83 e0 03             	and    $0x3,%eax
  80119b:	83 f8 01             	cmp    $0x1,%eax
  80119e:	74 1e                	je     8011be <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8011a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011a3:	8b 40 08             	mov    0x8(%eax),%eax
  8011a6:	85 c0                	test   %eax,%eax
  8011a8:	74 35                	je     8011df <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011aa:	83 ec 04             	sub    $0x4,%esp
  8011ad:	ff 75 10             	pushl  0x10(%ebp)
  8011b0:	ff 75 0c             	pushl  0xc(%ebp)
  8011b3:	52                   	push   %edx
  8011b4:	ff d0                	call   *%eax
  8011b6:	83 c4 10             	add    $0x10,%esp
}
  8011b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011bc:	c9                   	leave  
  8011bd:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011be:	a1 04 40 80 00       	mov    0x804004,%eax
  8011c3:	8b 40 48             	mov    0x48(%eax),%eax
  8011c6:	83 ec 04             	sub    $0x4,%esp
  8011c9:	53                   	push   %ebx
  8011ca:	50                   	push   %eax
  8011cb:	68 2d 29 80 00       	push   $0x80292d
  8011d0:	e8 9a f0 ff ff       	call   80026f <cprintf>
		return -E_INVAL;
  8011d5:	83 c4 10             	add    $0x10,%esp
  8011d8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011dd:	eb da                	jmp    8011b9 <read+0x5a>
		return -E_NOT_SUPP;
  8011df:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011e4:	eb d3                	jmp    8011b9 <read+0x5a>

008011e6 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011e6:	55                   	push   %ebp
  8011e7:	89 e5                	mov    %esp,%ebp
  8011e9:	57                   	push   %edi
  8011ea:	56                   	push   %esi
  8011eb:	53                   	push   %ebx
  8011ec:	83 ec 0c             	sub    $0xc,%esp
  8011ef:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011f2:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011f5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011fa:	39 f3                	cmp    %esi,%ebx
  8011fc:	73 25                	jae    801223 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011fe:	83 ec 04             	sub    $0x4,%esp
  801201:	89 f0                	mov    %esi,%eax
  801203:	29 d8                	sub    %ebx,%eax
  801205:	50                   	push   %eax
  801206:	89 d8                	mov    %ebx,%eax
  801208:	03 45 0c             	add    0xc(%ebp),%eax
  80120b:	50                   	push   %eax
  80120c:	57                   	push   %edi
  80120d:	e8 4d ff ff ff       	call   80115f <read>
		if (m < 0)
  801212:	83 c4 10             	add    $0x10,%esp
  801215:	85 c0                	test   %eax,%eax
  801217:	78 08                	js     801221 <readn+0x3b>
			return m;
		if (m == 0)
  801219:	85 c0                	test   %eax,%eax
  80121b:	74 06                	je     801223 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  80121d:	01 c3                	add    %eax,%ebx
  80121f:	eb d9                	jmp    8011fa <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801221:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801223:	89 d8                	mov    %ebx,%eax
  801225:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801228:	5b                   	pop    %ebx
  801229:	5e                   	pop    %esi
  80122a:	5f                   	pop    %edi
  80122b:	5d                   	pop    %ebp
  80122c:	c3                   	ret    

0080122d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80122d:	55                   	push   %ebp
  80122e:	89 e5                	mov    %esp,%ebp
  801230:	53                   	push   %ebx
  801231:	83 ec 14             	sub    $0x14,%esp
  801234:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801237:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80123a:	50                   	push   %eax
  80123b:	53                   	push   %ebx
  80123c:	e8 ad fc ff ff       	call   800eee <fd_lookup>
  801241:	83 c4 08             	add    $0x8,%esp
  801244:	85 c0                	test   %eax,%eax
  801246:	78 3a                	js     801282 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801248:	83 ec 08             	sub    $0x8,%esp
  80124b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80124e:	50                   	push   %eax
  80124f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801252:	ff 30                	pushl  (%eax)
  801254:	e8 eb fc ff ff       	call   800f44 <dev_lookup>
  801259:	83 c4 10             	add    $0x10,%esp
  80125c:	85 c0                	test   %eax,%eax
  80125e:	78 22                	js     801282 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801260:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801263:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801267:	74 1e                	je     801287 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801269:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80126c:	8b 52 0c             	mov    0xc(%edx),%edx
  80126f:	85 d2                	test   %edx,%edx
  801271:	74 35                	je     8012a8 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801273:	83 ec 04             	sub    $0x4,%esp
  801276:	ff 75 10             	pushl  0x10(%ebp)
  801279:	ff 75 0c             	pushl  0xc(%ebp)
  80127c:	50                   	push   %eax
  80127d:	ff d2                	call   *%edx
  80127f:	83 c4 10             	add    $0x10,%esp
}
  801282:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801285:	c9                   	leave  
  801286:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801287:	a1 04 40 80 00       	mov    0x804004,%eax
  80128c:	8b 40 48             	mov    0x48(%eax),%eax
  80128f:	83 ec 04             	sub    $0x4,%esp
  801292:	53                   	push   %ebx
  801293:	50                   	push   %eax
  801294:	68 49 29 80 00       	push   $0x802949
  801299:	e8 d1 ef ff ff       	call   80026f <cprintf>
		return -E_INVAL;
  80129e:	83 c4 10             	add    $0x10,%esp
  8012a1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012a6:	eb da                	jmp    801282 <write+0x55>
		return -E_NOT_SUPP;
  8012a8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012ad:	eb d3                	jmp    801282 <write+0x55>

008012af <seek>:

int
seek(int fdnum, off_t offset)
{
  8012af:	55                   	push   %ebp
  8012b0:	89 e5                	mov    %esp,%ebp
  8012b2:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012b5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012b8:	50                   	push   %eax
  8012b9:	ff 75 08             	pushl  0x8(%ebp)
  8012bc:	e8 2d fc ff ff       	call   800eee <fd_lookup>
  8012c1:	83 c4 08             	add    $0x8,%esp
  8012c4:	85 c0                	test   %eax,%eax
  8012c6:	78 0e                	js     8012d6 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012c8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012ce:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012d6:	c9                   	leave  
  8012d7:	c3                   	ret    

008012d8 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012d8:	55                   	push   %ebp
  8012d9:	89 e5                	mov    %esp,%ebp
  8012db:	53                   	push   %ebx
  8012dc:	83 ec 14             	sub    $0x14,%esp
  8012df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012e5:	50                   	push   %eax
  8012e6:	53                   	push   %ebx
  8012e7:	e8 02 fc ff ff       	call   800eee <fd_lookup>
  8012ec:	83 c4 08             	add    $0x8,%esp
  8012ef:	85 c0                	test   %eax,%eax
  8012f1:	78 37                	js     80132a <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012f3:	83 ec 08             	sub    $0x8,%esp
  8012f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f9:	50                   	push   %eax
  8012fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012fd:	ff 30                	pushl  (%eax)
  8012ff:	e8 40 fc ff ff       	call   800f44 <dev_lookup>
  801304:	83 c4 10             	add    $0x10,%esp
  801307:	85 c0                	test   %eax,%eax
  801309:	78 1f                	js     80132a <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80130b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80130e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801312:	74 1b                	je     80132f <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801314:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801317:	8b 52 18             	mov    0x18(%edx),%edx
  80131a:	85 d2                	test   %edx,%edx
  80131c:	74 32                	je     801350 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80131e:	83 ec 08             	sub    $0x8,%esp
  801321:	ff 75 0c             	pushl  0xc(%ebp)
  801324:	50                   	push   %eax
  801325:	ff d2                	call   *%edx
  801327:	83 c4 10             	add    $0x10,%esp
}
  80132a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80132d:	c9                   	leave  
  80132e:	c3                   	ret    
			thisenv->env_id, fdnum);
  80132f:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801334:	8b 40 48             	mov    0x48(%eax),%eax
  801337:	83 ec 04             	sub    $0x4,%esp
  80133a:	53                   	push   %ebx
  80133b:	50                   	push   %eax
  80133c:	68 0c 29 80 00       	push   $0x80290c
  801341:	e8 29 ef ff ff       	call   80026f <cprintf>
		return -E_INVAL;
  801346:	83 c4 10             	add    $0x10,%esp
  801349:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80134e:	eb da                	jmp    80132a <ftruncate+0x52>
		return -E_NOT_SUPP;
  801350:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801355:	eb d3                	jmp    80132a <ftruncate+0x52>

00801357 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801357:	55                   	push   %ebp
  801358:	89 e5                	mov    %esp,%ebp
  80135a:	53                   	push   %ebx
  80135b:	83 ec 14             	sub    $0x14,%esp
  80135e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801361:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801364:	50                   	push   %eax
  801365:	ff 75 08             	pushl  0x8(%ebp)
  801368:	e8 81 fb ff ff       	call   800eee <fd_lookup>
  80136d:	83 c4 08             	add    $0x8,%esp
  801370:	85 c0                	test   %eax,%eax
  801372:	78 4b                	js     8013bf <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801374:	83 ec 08             	sub    $0x8,%esp
  801377:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80137a:	50                   	push   %eax
  80137b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80137e:	ff 30                	pushl  (%eax)
  801380:	e8 bf fb ff ff       	call   800f44 <dev_lookup>
  801385:	83 c4 10             	add    $0x10,%esp
  801388:	85 c0                	test   %eax,%eax
  80138a:	78 33                	js     8013bf <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  80138c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80138f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801393:	74 2f                	je     8013c4 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801395:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801398:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80139f:	00 00 00 
	stat->st_isdir = 0;
  8013a2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013a9:	00 00 00 
	stat->st_dev = dev;
  8013ac:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013b2:	83 ec 08             	sub    $0x8,%esp
  8013b5:	53                   	push   %ebx
  8013b6:	ff 75 f0             	pushl  -0x10(%ebp)
  8013b9:	ff 50 14             	call   *0x14(%eax)
  8013bc:	83 c4 10             	add    $0x10,%esp
}
  8013bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c2:	c9                   	leave  
  8013c3:	c3                   	ret    
		return -E_NOT_SUPP;
  8013c4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013c9:	eb f4                	jmp    8013bf <fstat+0x68>

008013cb <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013cb:	55                   	push   %ebp
  8013cc:	89 e5                	mov    %esp,%ebp
  8013ce:	56                   	push   %esi
  8013cf:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013d0:	83 ec 08             	sub    $0x8,%esp
  8013d3:	6a 00                	push   $0x0
  8013d5:	ff 75 08             	pushl  0x8(%ebp)
  8013d8:	e8 e7 01 00 00       	call   8015c4 <open>
  8013dd:	89 c3                	mov    %eax,%ebx
  8013df:	83 c4 10             	add    $0x10,%esp
  8013e2:	85 c0                	test   %eax,%eax
  8013e4:	78 1b                	js     801401 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013e6:	83 ec 08             	sub    $0x8,%esp
  8013e9:	ff 75 0c             	pushl  0xc(%ebp)
  8013ec:	50                   	push   %eax
  8013ed:	e8 65 ff ff ff       	call   801357 <fstat>
  8013f2:	89 c6                	mov    %eax,%esi
	close(fd);
  8013f4:	89 1c 24             	mov    %ebx,(%esp)
  8013f7:	e8 27 fc ff ff       	call   801023 <close>
	return r;
  8013fc:	83 c4 10             	add    $0x10,%esp
  8013ff:	89 f3                	mov    %esi,%ebx
}
  801401:	89 d8                	mov    %ebx,%eax
  801403:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801406:	5b                   	pop    %ebx
  801407:	5e                   	pop    %esi
  801408:	5d                   	pop    %ebp
  801409:	c3                   	ret    

0080140a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80140a:	55                   	push   %ebp
  80140b:	89 e5                	mov    %esp,%ebp
  80140d:	56                   	push   %esi
  80140e:	53                   	push   %ebx
  80140f:	89 c6                	mov    %eax,%esi
  801411:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801413:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80141a:	74 27                	je     801443 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80141c:	6a 07                	push   $0x7
  80141e:	68 00 50 80 00       	push   $0x805000
  801423:	56                   	push   %esi
  801424:	ff 35 00 40 80 00    	pushl  0x804000
  80142a:	e8 7c 0d 00 00       	call   8021ab <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80142f:	83 c4 0c             	add    $0xc,%esp
  801432:	6a 00                	push   $0x0
  801434:	53                   	push   %ebx
  801435:	6a 00                	push   $0x0
  801437:	e8 fa 0c 00 00       	call   802136 <ipc_recv>
}
  80143c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80143f:	5b                   	pop    %ebx
  801440:	5e                   	pop    %esi
  801441:	5d                   	pop    %ebp
  801442:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801443:	83 ec 0c             	sub    $0xc,%esp
  801446:	6a 01                	push   $0x1
  801448:	e8 b4 0d 00 00       	call   802201 <ipc_find_env>
  80144d:	a3 00 40 80 00       	mov    %eax,0x804000
  801452:	83 c4 10             	add    $0x10,%esp
  801455:	eb c5                	jmp    80141c <fsipc+0x12>

00801457 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801457:	55                   	push   %ebp
  801458:	89 e5                	mov    %esp,%ebp
  80145a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80145d:	8b 45 08             	mov    0x8(%ebp),%eax
  801460:	8b 40 0c             	mov    0xc(%eax),%eax
  801463:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801468:	8b 45 0c             	mov    0xc(%ebp),%eax
  80146b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801470:	ba 00 00 00 00       	mov    $0x0,%edx
  801475:	b8 02 00 00 00       	mov    $0x2,%eax
  80147a:	e8 8b ff ff ff       	call   80140a <fsipc>
}
  80147f:	c9                   	leave  
  801480:	c3                   	ret    

00801481 <devfile_flush>:
{
  801481:	55                   	push   %ebp
  801482:	89 e5                	mov    %esp,%ebp
  801484:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801487:	8b 45 08             	mov    0x8(%ebp),%eax
  80148a:	8b 40 0c             	mov    0xc(%eax),%eax
  80148d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801492:	ba 00 00 00 00       	mov    $0x0,%edx
  801497:	b8 06 00 00 00       	mov    $0x6,%eax
  80149c:	e8 69 ff ff ff       	call   80140a <fsipc>
}
  8014a1:	c9                   	leave  
  8014a2:	c3                   	ret    

008014a3 <devfile_stat>:
{
  8014a3:	55                   	push   %ebp
  8014a4:	89 e5                	mov    %esp,%ebp
  8014a6:	53                   	push   %ebx
  8014a7:	83 ec 04             	sub    $0x4,%esp
  8014aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b0:	8b 40 0c             	mov    0xc(%eax),%eax
  8014b3:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8014bd:	b8 05 00 00 00       	mov    $0x5,%eax
  8014c2:	e8 43 ff ff ff       	call   80140a <fsipc>
  8014c7:	85 c0                	test   %eax,%eax
  8014c9:	78 2c                	js     8014f7 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014cb:	83 ec 08             	sub    $0x8,%esp
  8014ce:	68 00 50 80 00       	push   $0x805000
  8014d3:	53                   	push   %ebx
  8014d4:	e8 b5 f3 ff ff       	call   80088e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014d9:	a1 80 50 80 00       	mov    0x805080,%eax
  8014de:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014e4:	a1 84 50 80 00       	mov    0x805084,%eax
  8014e9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014ef:	83 c4 10             	add    $0x10,%esp
  8014f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014fa:	c9                   	leave  
  8014fb:	c3                   	ret    

008014fc <devfile_write>:
{
  8014fc:	55                   	push   %ebp
  8014fd:	89 e5                	mov    %esp,%ebp
  8014ff:	83 ec 0c             	sub    $0xc,%esp
  801502:	8b 45 10             	mov    0x10(%ebp),%eax
  801505:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80150a:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80150f:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801512:	8b 55 08             	mov    0x8(%ebp),%edx
  801515:	8b 52 0c             	mov    0xc(%edx),%edx
  801518:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80151e:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf,buf,n);
  801523:	50                   	push   %eax
  801524:	ff 75 0c             	pushl  0xc(%ebp)
  801527:	68 08 50 80 00       	push   $0x805008
  80152c:	e8 eb f4 ff ff       	call   800a1c <memmove>
	if((r = fsipc(FSREQ_WRITE,NULL))<0)
  801531:	ba 00 00 00 00       	mov    $0x0,%edx
  801536:	b8 04 00 00 00       	mov    $0x4,%eax
  80153b:	e8 ca fe ff ff       	call   80140a <fsipc>
}
  801540:	c9                   	leave  
  801541:	c3                   	ret    

00801542 <devfile_read>:
{
  801542:	55                   	push   %ebp
  801543:	89 e5                	mov    %esp,%ebp
  801545:	56                   	push   %esi
  801546:	53                   	push   %ebx
  801547:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80154a:	8b 45 08             	mov    0x8(%ebp),%eax
  80154d:	8b 40 0c             	mov    0xc(%eax),%eax
  801550:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801555:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80155b:	ba 00 00 00 00       	mov    $0x0,%edx
  801560:	b8 03 00 00 00       	mov    $0x3,%eax
  801565:	e8 a0 fe ff ff       	call   80140a <fsipc>
  80156a:	89 c3                	mov    %eax,%ebx
  80156c:	85 c0                	test   %eax,%eax
  80156e:	78 1f                	js     80158f <devfile_read+0x4d>
	assert(r <= n);
  801570:	39 f0                	cmp    %esi,%eax
  801572:	77 24                	ja     801598 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801574:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801579:	7f 33                	jg     8015ae <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80157b:	83 ec 04             	sub    $0x4,%esp
  80157e:	50                   	push   %eax
  80157f:	68 00 50 80 00       	push   $0x805000
  801584:	ff 75 0c             	pushl  0xc(%ebp)
  801587:	e8 90 f4 ff ff       	call   800a1c <memmove>
	return r;
  80158c:	83 c4 10             	add    $0x10,%esp
}
  80158f:	89 d8                	mov    %ebx,%eax
  801591:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801594:	5b                   	pop    %ebx
  801595:	5e                   	pop    %esi
  801596:	5d                   	pop    %ebp
  801597:	c3                   	ret    
	assert(r <= n);
  801598:	68 78 29 80 00       	push   $0x802978
  80159d:	68 7f 29 80 00       	push   $0x80297f
  8015a2:	6a 7c                	push   $0x7c
  8015a4:	68 94 29 80 00       	push   $0x802994
  8015a9:	e8 e6 eb ff ff       	call   800194 <_panic>
	assert(r <= PGSIZE);
  8015ae:	68 9f 29 80 00       	push   $0x80299f
  8015b3:	68 7f 29 80 00       	push   $0x80297f
  8015b8:	6a 7d                	push   $0x7d
  8015ba:	68 94 29 80 00       	push   $0x802994
  8015bf:	e8 d0 eb ff ff       	call   800194 <_panic>

008015c4 <open>:
{
  8015c4:	55                   	push   %ebp
  8015c5:	89 e5                	mov    %esp,%ebp
  8015c7:	56                   	push   %esi
  8015c8:	53                   	push   %ebx
  8015c9:	83 ec 1c             	sub    $0x1c,%esp
  8015cc:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8015cf:	56                   	push   %esi
  8015d0:	e8 82 f2 ff ff       	call   800857 <strlen>
  8015d5:	83 c4 10             	add    $0x10,%esp
  8015d8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015dd:	7f 6c                	jg     80164b <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8015df:	83 ec 0c             	sub    $0xc,%esp
  8015e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e5:	50                   	push   %eax
  8015e6:	e8 b4 f8 ff ff       	call   800e9f <fd_alloc>
  8015eb:	89 c3                	mov    %eax,%ebx
  8015ed:	83 c4 10             	add    $0x10,%esp
  8015f0:	85 c0                	test   %eax,%eax
  8015f2:	78 3c                	js     801630 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8015f4:	83 ec 08             	sub    $0x8,%esp
  8015f7:	56                   	push   %esi
  8015f8:	68 00 50 80 00       	push   $0x805000
  8015fd:	e8 8c f2 ff ff       	call   80088e <strcpy>
	fsipcbuf.open.req_omode = mode;
  801602:	8b 45 0c             	mov    0xc(%ebp),%eax
  801605:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80160a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80160d:	b8 01 00 00 00       	mov    $0x1,%eax
  801612:	e8 f3 fd ff ff       	call   80140a <fsipc>
  801617:	89 c3                	mov    %eax,%ebx
  801619:	83 c4 10             	add    $0x10,%esp
  80161c:	85 c0                	test   %eax,%eax
  80161e:	78 19                	js     801639 <open+0x75>
	return fd2num(fd);
  801620:	83 ec 0c             	sub    $0xc,%esp
  801623:	ff 75 f4             	pushl  -0xc(%ebp)
  801626:	e8 4d f8 ff ff       	call   800e78 <fd2num>
  80162b:	89 c3                	mov    %eax,%ebx
  80162d:	83 c4 10             	add    $0x10,%esp
}
  801630:	89 d8                	mov    %ebx,%eax
  801632:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801635:	5b                   	pop    %ebx
  801636:	5e                   	pop    %esi
  801637:	5d                   	pop    %ebp
  801638:	c3                   	ret    
		fd_close(fd, 0);
  801639:	83 ec 08             	sub    $0x8,%esp
  80163c:	6a 00                	push   $0x0
  80163e:	ff 75 f4             	pushl  -0xc(%ebp)
  801641:	e8 54 f9 ff ff       	call   800f9a <fd_close>
		return r;
  801646:	83 c4 10             	add    $0x10,%esp
  801649:	eb e5                	jmp    801630 <open+0x6c>
		return -E_BAD_PATH;
  80164b:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801650:	eb de                	jmp    801630 <open+0x6c>

00801652 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801652:	55                   	push   %ebp
  801653:	89 e5                	mov    %esp,%ebp
  801655:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801658:	ba 00 00 00 00       	mov    $0x0,%edx
  80165d:	b8 08 00 00 00       	mov    $0x8,%eax
  801662:	e8 a3 fd ff ff       	call   80140a <fsipc>
}
  801667:	c9                   	leave  
  801668:	c3                   	ret    

00801669 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801669:	55                   	push   %ebp
  80166a:	89 e5                	mov    %esp,%ebp
  80166c:	57                   	push   %edi
  80166d:	56                   	push   %esi
  80166e:	53                   	push   %ebx
  80166f:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801675:	6a 00                	push   $0x0
  801677:	ff 75 08             	pushl  0x8(%ebp)
  80167a:	e8 45 ff ff ff       	call   8015c4 <open>
  80167f:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  801685:	83 c4 10             	add    $0x10,%esp
  801688:	85 c0                	test   %eax,%eax
  80168a:	0f 88 40 03 00 00    	js     8019d0 <spawn+0x367>
  801690:	89 c2                	mov    %eax,%edx
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801692:	83 ec 04             	sub    $0x4,%esp
  801695:	68 00 02 00 00       	push   $0x200
  80169a:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8016a0:	50                   	push   %eax
  8016a1:	52                   	push   %edx
  8016a2:	e8 3f fb ff ff       	call   8011e6 <readn>
  8016a7:	83 c4 10             	add    $0x10,%esp
  8016aa:	3d 00 02 00 00       	cmp    $0x200,%eax
  8016af:	75 5d                	jne    80170e <spawn+0xa5>
	    || elf->e_magic != ELF_MAGIC) {
  8016b1:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8016b8:	45 4c 46 
  8016bb:	75 51                	jne    80170e <spawn+0xa5>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8016bd:	b8 07 00 00 00       	mov    $0x7,%eax
  8016c2:	cd 30                	int    $0x30
  8016c4:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8016ca:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8016d0:	85 c0                	test   %eax,%eax
  8016d2:	0f 88 6e 04 00 00    	js     801b46 <spawn+0x4dd>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8016d8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8016dd:	6b f0 7c             	imul   $0x7c,%eax,%esi
  8016e0:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8016e6:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8016ec:	b9 11 00 00 00       	mov    $0x11,%ecx
  8016f1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8016f3:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8016f9:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8016ff:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  801704:	be 00 00 00 00       	mov    $0x0,%esi
  801709:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80170c:	eb 4b                	jmp    801759 <spawn+0xf0>
		close(fd);
  80170e:	83 ec 0c             	sub    $0xc,%esp
  801711:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801717:	e8 07 f9 ff ff       	call   801023 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80171c:	83 c4 0c             	add    $0xc,%esp
  80171f:	68 7f 45 4c 46       	push   $0x464c457f
  801724:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  80172a:	68 ab 29 80 00       	push   $0x8029ab
  80172f:	e8 3b eb ff ff       	call   80026f <cprintf>
		return -E_NOT_EXEC;
  801734:	83 c4 10             	add    $0x10,%esp
  801737:	c7 85 90 fd ff ff f2 	movl   $0xfffffff2,-0x270(%ebp)
  80173e:	ff ff ff 
  801741:	e9 8a 02 00 00       	jmp    8019d0 <spawn+0x367>
		string_size += strlen(argv[argc]) + 1;
  801746:	83 ec 0c             	sub    $0xc,%esp
  801749:	50                   	push   %eax
  80174a:	e8 08 f1 ff ff       	call   800857 <strlen>
  80174f:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  801753:	83 c3 01             	add    $0x1,%ebx
  801756:	83 c4 10             	add    $0x10,%esp
  801759:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801760:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801763:	85 c0                	test   %eax,%eax
  801765:	75 df                	jne    801746 <spawn+0xdd>
  801767:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  80176d:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801773:	bf 00 10 40 00       	mov    $0x401000,%edi
  801778:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  80177a:	89 fa                	mov    %edi,%edx
  80177c:	83 e2 fc             	and    $0xfffffffc,%edx
  80177f:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801786:	29 c2                	sub    %eax,%edx
  801788:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  80178e:	8d 42 f8             	lea    -0x8(%edx),%eax
  801791:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801796:	0f 86 bb 03 00 00    	jbe    801b57 <spawn+0x4ee>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80179c:	83 ec 04             	sub    $0x4,%esp
  80179f:	6a 07                	push   $0x7
  8017a1:	68 00 00 40 00       	push   $0x400000
  8017a6:	6a 00                	push   $0x0
  8017a8:	e8 da f4 ff ff       	call   800c87 <sys_page_alloc>
  8017ad:	83 c4 10             	add    $0x10,%esp
  8017b0:	85 c0                	test   %eax,%eax
  8017b2:	0f 88 a4 03 00 00    	js     801b5c <spawn+0x4f3>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8017b8:	be 00 00 00 00       	mov    $0x0,%esi
  8017bd:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  8017c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8017c6:	eb 30                	jmp    8017f8 <spawn+0x18f>
		argv_store[i] = UTEMP2USTACK(string_store);
  8017c8:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8017ce:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  8017d4:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  8017d7:	83 ec 08             	sub    $0x8,%esp
  8017da:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8017dd:	57                   	push   %edi
  8017de:	e8 ab f0 ff ff       	call   80088e <strcpy>
		string_store += strlen(argv[i]) + 1;
  8017e3:	83 c4 04             	add    $0x4,%esp
  8017e6:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8017e9:	e8 69 f0 ff ff       	call   800857 <strlen>
  8017ee:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  8017f2:	83 c6 01             	add    $0x1,%esi
  8017f5:	83 c4 10             	add    $0x10,%esp
  8017f8:	39 b5 8c fd ff ff    	cmp    %esi,-0x274(%ebp)
  8017fe:	7f c8                	jg     8017c8 <spawn+0x15f>
	}
	argv_store[argc] = 0;
  801800:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801806:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  80180c:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801813:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801819:	0f 85 8c 00 00 00    	jne    8018ab <spawn+0x242>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  80181f:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801825:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  80182b:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  80182e:	89 f8                	mov    %edi,%eax
  801830:	8b bd 88 fd ff ff    	mov    -0x278(%ebp),%edi
  801836:	89 78 f8             	mov    %edi,-0x8(%eax)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801839:	2d 08 30 80 11       	sub    $0x11803008,%eax
  80183e:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801844:	83 ec 0c             	sub    $0xc,%esp
  801847:	6a 07                	push   $0x7
  801849:	68 00 d0 bf ee       	push   $0xeebfd000
  80184e:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801854:	68 00 00 40 00       	push   $0x400000
  801859:	6a 00                	push   $0x0
  80185b:	e8 6a f4 ff ff       	call   800cca <sys_page_map>
  801860:	89 c3                	mov    %eax,%ebx
  801862:	83 c4 20             	add    $0x20,%esp
  801865:	85 c0                	test   %eax,%eax
  801867:	0f 88 65 03 00 00    	js     801bd2 <spawn+0x569>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  80186d:	83 ec 08             	sub    $0x8,%esp
  801870:	68 00 00 40 00       	push   $0x400000
  801875:	6a 00                	push   $0x0
  801877:	e8 90 f4 ff ff       	call   800d0c <sys_page_unmap>
  80187c:	89 c3                	mov    %eax,%ebx
  80187e:	83 c4 10             	add    $0x10,%esp
  801881:	85 c0                	test   %eax,%eax
  801883:	0f 88 49 03 00 00    	js     801bd2 <spawn+0x569>
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801889:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  80188f:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801896:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80189c:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  8018a3:	00 00 00 
  8018a6:	e9 56 01 00 00       	jmp    801a01 <spawn+0x398>
	assert(string_store == (char*)UTEMP + PGSIZE);
  8018ab:	68 38 2a 80 00       	push   $0x802a38
  8018b0:	68 7f 29 80 00       	push   $0x80297f
  8018b5:	68 f2 00 00 00       	push   $0xf2
  8018ba:	68 c5 29 80 00       	push   $0x8029c5
  8018bf:	e8 d0 e8 ff ff       	call   800194 <_panic>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8018c4:	83 ec 04             	sub    $0x4,%esp
  8018c7:	6a 07                	push   $0x7
  8018c9:	68 00 00 40 00       	push   $0x400000
  8018ce:	6a 00                	push   $0x0
  8018d0:	e8 b2 f3 ff ff       	call   800c87 <sys_page_alloc>
  8018d5:	83 c4 10             	add    $0x10,%esp
  8018d8:	85 c0                	test   %eax,%eax
  8018da:	0f 88 87 02 00 00    	js     801b67 <spawn+0x4fe>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8018e0:	83 ec 08             	sub    $0x8,%esp
  8018e3:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8018e9:	01 f0                	add    %esi,%eax
  8018eb:	50                   	push   %eax
  8018ec:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  8018f2:	e8 b8 f9 ff ff       	call   8012af <seek>
  8018f7:	83 c4 10             	add    $0x10,%esp
  8018fa:	85 c0                	test   %eax,%eax
  8018fc:	0f 88 6c 02 00 00    	js     801b6e <spawn+0x505>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801902:	83 ec 04             	sub    $0x4,%esp
  801905:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  80190b:	29 f0                	sub    %esi,%eax
  80190d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801912:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801917:	0f 47 c1             	cmova  %ecx,%eax
  80191a:	50                   	push   %eax
  80191b:	68 00 00 40 00       	push   $0x400000
  801920:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801926:	e8 bb f8 ff ff       	call   8011e6 <readn>
  80192b:	83 c4 10             	add    $0x10,%esp
  80192e:	85 c0                	test   %eax,%eax
  801930:	0f 88 3f 02 00 00    	js     801b75 <spawn+0x50c>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801936:	83 ec 0c             	sub    $0xc,%esp
  801939:	57                   	push   %edi
  80193a:	03 b5 88 fd ff ff    	add    -0x278(%ebp),%esi
  801940:	56                   	push   %esi
  801941:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801947:	68 00 00 40 00       	push   $0x400000
  80194c:	6a 00                	push   $0x0
  80194e:	e8 77 f3 ff ff       	call   800cca <sys_page_map>
  801953:	83 c4 20             	add    $0x20,%esp
  801956:	85 c0                	test   %eax,%eax
  801958:	0f 88 80 00 00 00    	js     8019de <spawn+0x375>
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
  80195e:	83 ec 08             	sub    $0x8,%esp
  801961:	68 00 00 40 00       	push   $0x400000
  801966:	6a 00                	push   $0x0
  801968:	e8 9f f3 ff ff       	call   800d0c <sys_page_unmap>
  80196d:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < memsz; i += PGSIZE) {
  801970:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801976:	89 de                	mov    %ebx,%esi
  801978:	39 9d 8c fd ff ff    	cmp    %ebx,-0x274(%ebp)
  80197e:	76 73                	jbe    8019f3 <spawn+0x38a>
		if (i >= filesz) {
  801980:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  801986:	0f 87 38 ff ff ff    	ja     8018c4 <spawn+0x25b>
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  80198c:	83 ec 04             	sub    $0x4,%esp
  80198f:	57                   	push   %edi
  801990:	03 b5 88 fd ff ff    	add    -0x278(%ebp),%esi
  801996:	56                   	push   %esi
  801997:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  80199d:	e8 e5 f2 ff ff       	call   800c87 <sys_page_alloc>
  8019a2:	83 c4 10             	add    $0x10,%esp
  8019a5:	85 c0                	test   %eax,%eax
  8019a7:	79 c7                	jns    801970 <spawn+0x307>
  8019a9:	89 c7                	mov    %eax,%edi
	sys_env_destroy(child);
  8019ab:	83 ec 0c             	sub    $0xc,%esp
  8019ae:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8019b4:	e8 4f f2 ff ff       	call   800c08 <sys_env_destroy>
	close(fd);
  8019b9:	83 c4 04             	add    $0x4,%esp
  8019bc:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  8019c2:	e8 5c f6 ff ff       	call   801023 <close>
	return r;
  8019c7:	83 c4 10             	add    $0x10,%esp
  8019ca:	89 bd 90 fd ff ff    	mov    %edi,-0x270(%ebp)
}
  8019d0:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  8019d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019d9:	5b                   	pop    %ebx
  8019da:	5e                   	pop    %esi
  8019db:	5f                   	pop    %edi
  8019dc:	5d                   	pop    %ebp
  8019dd:	c3                   	ret    
				panic("spawn: sys_page_map data: %e", r);
  8019de:	50                   	push   %eax
  8019df:	68 d1 29 80 00       	push   $0x8029d1
  8019e4:	68 25 01 00 00       	push   $0x125
  8019e9:	68 c5 29 80 00       	push   $0x8029c5
  8019ee:	e8 a1 e7 ff ff       	call   800194 <_panic>
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8019f3:	83 85 7c fd ff ff 01 	addl   $0x1,-0x284(%ebp)
  8019fa:	83 85 78 fd ff ff 20 	addl   $0x20,-0x288(%ebp)
  801a01:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801a08:	3b 85 7c fd ff ff    	cmp    -0x284(%ebp),%eax
  801a0e:	7e 71                	jle    801a81 <spawn+0x418>
		if (ph->p_type != ELF_PROG_LOAD)
  801a10:	8b 8d 78 fd ff ff    	mov    -0x288(%ebp),%ecx
  801a16:	83 39 01             	cmpl   $0x1,(%ecx)
  801a19:	75 d8                	jne    8019f3 <spawn+0x38a>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801a1b:	8b 41 18             	mov    0x18(%ecx),%eax
  801a1e:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801a21:	83 f8 01             	cmp    $0x1,%eax
  801a24:	19 ff                	sbb    %edi,%edi
  801a26:	83 e7 fe             	and    $0xfffffffe,%edi
  801a29:	83 c7 07             	add    $0x7,%edi
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801a2c:	8b 71 04             	mov    0x4(%ecx),%esi
  801a2f:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  801a35:	8b 59 10             	mov    0x10(%ecx),%ebx
  801a38:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801a3e:	8b 41 14             	mov    0x14(%ecx),%eax
  801a41:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801a47:	8b 51 08             	mov    0x8(%ecx),%edx
  801a4a:	89 95 88 fd ff ff    	mov    %edx,-0x278(%ebp)
	if ((i = PGOFF(va))) {
  801a50:	89 d0                	mov    %edx,%eax
  801a52:	25 ff 0f 00 00       	and    $0xfff,%eax
  801a57:	74 1e                	je     801a77 <spawn+0x40e>
		va -= i;
  801a59:	29 c2                	sub    %eax,%edx
  801a5b:	89 95 88 fd ff ff    	mov    %edx,-0x278(%ebp)
		memsz += i;
  801a61:	01 85 8c fd ff ff    	add    %eax,-0x274(%ebp)
		filesz += i;
  801a67:	01 c3                	add    %eax,%ebx
  801a69:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
		fileoffset -= i;
  801a6f:	29 c6                	sub    %eax,%esi
  801a71:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
	for (i = 0; i < memsz; i += PGSIZE) {
  801a77:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a7c:	e9 f5 fe ff ff       	jmp    801976 <spawn+0x30d>
	close(fd);
  801a81:	83 ec 0c             	sub    $0xc,%esp
  801a84:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801a8a:	e8 94 f5 ff ff       	call   801023 <close>
  801a8f:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	uintptr_t addr;
	int r;

	for(addr=(uintptr_t)UTEXT; addr<USTACKTOP;addr+=PGSIZE){
  801a92:	bb 00 00 80 00       	mov    $0x800000,%ebx
  801a97:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
  801a9d:	eb 12                	jmp    801ab1 <spawn+0x448>
  801a9f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801aa5:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801aab:	0f 84 cb 00 00 00    	je     801b7c <spawn+0x513>
	   if((uvpd[PDX(addr)]&PTE_P) && (uvpt[PGNUM(addr)]&PTE_P)){
  801ab1:	89 d8                	mov    %ebx,%eax
  801ab3:	c1 e8 16             	shr    $0x16,%eax
  801ab6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801abd:	a8 01                	test   $0x1,%al
  801abf:	74 de                	je     801a9f <spawn+0x436>
  801ac1:	89 d8                	mov    %ebx,%eax
  801ac3:	c1 e8 0c             	shr    $0xc,%eax
  801ac6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801acd:	f6 c2 01             	test   $0x1,%dl
  801ad0:	74 cd                	je     801a9f <spawn+0x436>
	      if(uvpt[PGNUM(addr)] & PTE_SHARE){
  801ad2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801ad9:	f6 c6 04             	test   $0x4,%dh
  801adc:	74 c1                	je     801a9f <spawn+0x436>
	        if((r=sys_page_map(thisenv->env_id,(void *)addr,child,(void *)addr, uvpt[PGNUM(addr)]&PTE_SYSCALL))<0)
  801ade:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801ae5:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801aeb:	8b 52 48             	mov    0x48(%edx),%edx
  801aee:	83 ec 0c             	sub    $0xc,%esp
  801af1:	25 07 0e 00 00       	and    $0xe07,%eax
  801af6:	50                   	push   %eax
  801af7:	53                   	push   %ebx
  801af8:	56                   	push   %esi
  801af9:	53                   	push   %ebx
  801afa:	52                   	push   %edx
  801afb:	e8 ca f1 ff ff       	call   800cca <sys_page_map>
  801b00:	83 c4 20             	add    $0x20,%esp
  801b03:	85 c0                	test   %eax,%eax
  801b05:	79 98                	jns    801a9f <spawn+0x436>
		panic("copy_shared_pages: %e", r);
  801b07:	50                   	push   %eax
  801b08:	68 1f 2a 80 00       	push   $0x802a1f
  801b0d:	68 82 00 00 00       	push   $0x82
  801b12:	68 c5 29 80 00       	push   $0x8029c5
  801b17:	e8 78 e6 ff ff       	call   800194 <_panic>
		panic("sys_env_set_trapframe: %e", r);
  801b1c:	50                   	push   %eax
  801b1d:	68 ee 29 80 00       	push   $0x8029ee
  801b22:	68 86 00 00 00       	push   $0x86
  801b27:	68 c5 29 80 00       	push   $0x8029c5
  801b2c:	e8 63 e6 ff ff       	call   800194 <_panic>
		panic("sys_env_set_status: %e", r);
  801b31:	50                   	push   %eax
  801b32:	68 08 2a 80 00       	push   $0x802a08
  801b37:	68 89 00 00 00       	push   $0x89
  801b3c:	68 c5 29 80 00       	push   $0x8029c5
  801b41:	e8 4e e6 ff ff       	call   800194 <_panic>
		return r;
  801b46:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801b4c:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  801b52:	e9 79 fe ff ff       	jmp    8019d0 <spawn+0x367>
		return -E_NO_MEM;
  801b57:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return r;
  801b5c:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  801b62:	e9 69 fe ff ff       	jmp    8019d0 <spawn+0x367>
  801b67:	89 c7                	mov    %eax,%edi
  801b69:	e9 3d fe ff ff       	jmp    8019ab <spawn+0x342>
  801b6e:	89 c7                	mov    %eax,%edi
  801b70:	e9 36 fe ff ff       	jmp    8019ab <spawn+0x342>
  801b75:	89 c7                	mov    %eax,%edi
  801b77:	e9 2f fe ff ff       	jmp    8019ab <spawn+0x342>
	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801b7c:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801b83:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801b86:	83 ec 08             	sub    $0x8,%esp
  801b89:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801b8f:	50                   	push   %eax
  801b90:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b96:	e8 f5 f1 ff ff       	call   800d90 <sys_env_set_trapframe>
  801b9b:	83 c4 10             	add    $0x10,%esp
  801b9e:	85 c0                	test   %eax,%eax
  801ba0:	0f 88 76 ff ff ff    	js     801b1c <spawn+0x4b3>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801ba6:	83 ec 08             	sub    $0x8,%esp
  801ba9:	6a 02                	push   $0x2
  801bab:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801bb1:	e8 98 f1 ff ff       	call   800d4e <sys_env_set_status>
  801bb6:	83 c4 10             	add    $0x10,%esp
  801bb9:	85 c0                	test   %eax,%eax
  801bbb:	0f 88 70 ff ff ff    	js     801b31 <spawn+0x4c8>
	return child;
  801bc1:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801bc7:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  801bcd:	e9 fe fd ff ff       	jmp    8019d0 <spawn+0x367>
	sys_page_unmap(0, UTEMP);
  801bd2:	83 ec 08             	sub    $0x8,%esp
  801bd5:	68 00 00 40 00       	push   $0x400000
  801bda:	6a 00                	push   $0x0
  801bdc:	e8 2b f1 ff ff       	call   800d0c <sys_page_unmap>
  801be1:	83 c4 10             	add    $0x10,%esp
  801be4:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801bea:	e9 e1 fd ff ff       	jmp    8019d0 <spawn+0x367>

00801bef <spawnl>:
{
  801bef:	55                   	push   %ebp
  801bf0:	89 e5                	mov    %esp,%ebp
  801bf2:	57                   	push   %edi
  801bf3:	56                   	push   %esi
  801bf4:	53                   	push   %ebx
  801bf5:	83 ec 0c             	sub    $0xc,%esp
	va_start(vl, arg0);
  801bf8:	8d 55 10             	lea    0x10(%ebp),%edx
	int argc=0;
  801bfb:	b8 00 00 00 00       	mov    $0x0,%eax
	while(va_arg(vl, void *) != NULL)
  801c00:	eb 05                	jmp    801c07 <spawnl+0x18>
		argc++;
  801c02:	83 c0 01             	add    $0x1,%eax
	while(va_arg(vl, void *) != NULL)
  801c05:	89 ca                	mov    %ecx,%edx
  801c07:	8d 4a 04             	lea    0x4(%edx),%ecx
  801c0a:	83 3a 00             	cmpl   $0x0,(%edx)
  801c0d:	75 f3                	jne    801c02 <spawnl+0x13>
	const char *argv[argc+2];
  801c0f:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801c16:	83 e2 f0             	and    $0xfffffff0,%edx
  801c19:	29 d4                	sub    %edx,%esp
  801c1b:	8d 54 24 03          	lea    0x3(%esp),%edx
  801c1f:	c1 ea 02             	shr    $0x2,%edx
  801c22:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801c29:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801c2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c2e:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801c35:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801c3c:	00 
	va_start(vl, arg0);
  801c3d:	8d 4d 10             	lea    0x10(%ebp),%ecx
  801c40:	89 c2                	mov    %eax,%edx
	for(i=0;i<argc;i++)
  801c42:	b8 00 00 00 00       	mov    $0x0,%eax
  801c47:	eb 0b                	jmp    801c54 <spawnl+0x65>
		argv[i+1] = va_arg(vl, const char *);
  801c49:	83 c0 01             	add    $0x1,%eax
  801c4c:	8b 39                	mov    (%ecx),%edi
  801c4e:	89 3c 83             	mov    %edi,(%ebx,%eax,4)
  801c51:	8d 49 04             	lea    0x4(%ecx),%ecx
	for(i=0;i<argc;i++)
  801c54:	39 d0                	cmp    %edx,%eax
  801c56:	75 f1                	jne    801c49 <spawnl+0x5a>
	return spawn(prog, argv);
  801c58:	83 ec 08             	sub    $0x8,%esp
  801c5b:	56                   	push   %esi
  801c5c:	ff 75 08             	pushl  0x8(%ebp)
  801c5f:	e8 05 fa ff ff       	call   801669 <spawn>
}
  801c64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c67:	5b                   	pop    %ebx
  801c68:	5e                   	pop    %esi
  801c69:	5f                   	pop    %edi
  801c6a:	5d                   	pop    %ebp
  801c6b:	c3                   	ret    

00801c6c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c6c:	55                   	push   %ebp
  801c6d:	89 e5                	mov    %esp,%ebp
  801c6f:	56                   	push   %esi
  801c70:	53                   	push   %ebx
  801c71:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c74:	83 ec 0c             	sub    $0xc,%esp
  801c77:	ff 75 08             	pushl  0x8(%ebp)
  801c7a:	e8 09 f2 ff ff       	call   800e88 <fd2data>
  801c7f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c81:	83 c4 08             	add    $0x8,%esp
  801c84:	68 60 2a 80 00       	push   $0x802a60
  801c89:	53                   	push   %ebx
  801c8a:	e8 ff eb ff ff       	call   80088e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c8f:	8b 46 04             	mov    0x4(%esi),%eax
  801c92:	2b 06                	sub    (%esi),%eax
  801c94:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c9a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ca1:	00 00 00 
	stat->st_dev = &devpipe;
  801ca4:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801cab:	30 80 00 
	return 0;
}
  801cae:	b8 00 00 00 00       	mov    $0x0,%eax
  801cb3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cb6:	5b                   	pop    %ebx
  801cb7:	5e                   	pop    %esi
  801cb8:	5d                   	pop    %ebp
  801cb9:	c3                   	ret    

00801cba <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801cba:	55                   	push   %ebp
  801cbb:	89 e5                	mov    %esp,%ebp
  801cbd:	53                   	push   %ebx
  801cbe:	83 ec 0c             	sub    $0xc,%esp
  801cc1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801cc4:	53                   	push   %ebx
  801cc5:	6a 00                	push   $0x0
  801cc7:	e8 40 f0 ff ff       	call   800d0c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ccc:	89 1c 24             	mov    %ebx,(%esp)
  801ccf:	e8 b4 f1 ff ff       	call   800e88 <fd2data>
  801cd4:	83 c4 08             	add    $0x8,%esp
  801cd7:	50                   	push   %eax
  801cd8:	6a 00                	push   $0x0
  801cda:	e8 2d f0 ff ff       	call   800d0c <sys_page_unmap>
}
  801cdf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ce2:	c9                   	leave  
  801ce3:	c3                   	ret    

00801ce4 <_pipeisclosed>:
{
  801ce4:	55                   	push   %ebp
  801ce5:	89 e5                	mov    %esp,%ebp
  801ce7:	57                   	push   %edi
  801ce8:	56                   	push   %esi
  801ce9:	53                   	push   %ebx
  801cea:	83 ec 1c             	sub    $0x1c,%esp
  801ced:	89 c7                	mov    %eax,%edi
  801cef:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801cf1:	a1 04 40 80 00       	mov    0x804004,%eax
  801cf6:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801cf9:	83 ec 0c             	sub    $0xc,%esp
  801cfc:	57                   	push   %edi
  801cfd:	e8 38 05 00 00       	call   80223a <pageref>
  801d02:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801d05:	89 34 24             	mov    %esi,(%esp)
  801d08:	e8 2d 05 00 00       	call   80223a <pageref>
		nn = thisenv->env_runs;
  801d0d:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801d13:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801d16:	83 c4 10             	add    $0x10,%esp
  801d19:	39 cb                	cmp    %ecx,%ebx
  801d1b:	74 1b                	je     801d38 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801d1d:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801d20:	75 cf                	jne    801cf1 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d22:	8b 42 58             	mov    0x58(%edx),%eax
  801d25:	6a 01                	push   $0x1
  801d27:	50                   	push   %eax
  801d28:	53                   	push   %ebx
  801d29:	68 67 2a 80 00       	push   $0x802a67
  801d2e:	e8 3c e5 ff ff       	call   80026f <cprintf>
  801d33:	83 c4 10             	add    $0x10,%esp
  801d36:	eb b9                	jmp    801cf1 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801d38:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801d3b:	0f 94 c0             	sete   %al
  801d3e:	0f b6 c0             	movzbl %al,%eax
}
  801d41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d44:	5b                   	pop    %ebx
  801d45:	5e                   	pop    %esi
  801d46:	5f                   	pop    %edi
  801d47:	5d                   	pop    %ebp
  801d48:	c3                   	ret    

00801d49 <devpipe_write>:
{
  801d49:	55                   	push   %ebp
  801d4a:	89 e5                	mov    %esp,%ebp
  801d4c:	57                   	push   %edi
  801d4d:	56                   	push   %esi
  801d4e:	53                   	push   %ebx
  801d4f:	83 ec 28             	sub    $0x28,%esp
  801d52:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801d55:	56                   	push   %esi
  801d56:	e8 2d f1 ff ff       	call   800e88 <fd2data>
  801d5b:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801d5d:	83 c4 10             	add    $0x10,%esp
  801d60:	bf 00 00 00 00       	mov    $0x0,%edi
  801d65:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d68:	74 4f                	je     801db9 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d6a:	8b 43 04             	mov    0x4(%ebx),%eax
  801d6d:	8b 0b                	mov    (%ebx),%ecx
  801d6f:	8d 51 20             	lea    0x20(%ecx),%edx
  801d72:	39 d0                	cmp    %edx,%eax
  801d74:	72 14                	jb     801d8a <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801d76:	89 da                	mov    %ebx,%edx
  801d78:	89 f0                	mov    %esi,%eax
  801d7a:	e8 65 ff ff ff       	call   801ce4 <_pipeisclosed>
  801d7f:	85 c0                	test   %eax,%eax
  801d81:	75 3a                	jne    801dbd <devpipe_write+0x74>
			sys_yield();
  801d83:	e8 e0 ee ff ff       	call   800c68 <sys_yield>
  801d88:	eb e0                	jmp    801d6a <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d8d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d91:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d94:	89 c2                	mov    %eax,%edx
  801d96:	c1 fa 1f             	sar    $0x1f,%edx
  801d99:	89 d1                	mov    %edx,%ecx
  801d9b:	c1 e9 1b             	shr    $0x1b,%ecx
  801d9e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801da1:	83 e2 1f             	and    $0x1f,%edx
  801da4:	29 ca                	sub    %ecx,%edx
  801da6:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801daa:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801dae:	83 c0 01             	add    $0x1,%eax
  801db1:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801db4:	83 c7 01             	add    $0x1,%edi
  801db7:	eb ac                	jmp    801d65 <devpipe_write+0x1c>
	return i;
  801db9:	89 f8                	mov    %edi,%eax
  801dbb:	eb 05                	jmp    801dc2 <devpipe_write+0x79>
				return 0;
  801dbd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801dc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dc5:	5b                   	pop    %ebx
  801dc6:	5e                   	pop    %esi
  801dc7:	5f                   	pop    %edi
  801dc8:	5d                   	pop    %ebp
  801dc9:	c3                   	ret    

00801dca <devpipe_read>:
{
  801dca:	55                   	push   %ebp
  801dcb:	89 e5                	mov    %esp,%ebp
  801dcd:	57                   	push   %edi
  801dce:	56                   	push   %esi
  801dcf:	53                   	push   %ebx
  801dd0:	83 ec 18             	sub    $0x18,%esp
  801dd3:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801dd6:	57                   	push   %edi
  801dd7:	e8 ac f0 ff ff       	call   800e88 <fd2data>
  801ddc:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801dde:	83 c4 10             	add    $0x10,%esp
  801de1:	be 00 00 00 00       	mov    $0x0,%esi
  801de6:	3b 75 10             	cmp    0x10(%ebp),%esi
  801de9:	74 47                	je     801e32 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  801deb:	8b 03                	mov    (%ebx),%eax
  801ded:	3b 43 04             	cmp    0x4(%ebx),%eax
  801df0:	75 22                	jne    801e14 <devpipe_read+0x4a>
			if (i > 0)
  801df2:	85 f6                	test   %esi,%esi
  801df4:	75 14                	jne    801e0a <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801df6:	89 da                	mov    %ebx,%edx
  801df8:	89 f8                	mov    %edi,%eax
  801dfa:	e8 e5 fe ff ff       	call   801ce4 <_pipeisclosed>
  801dff:	85 c0                	test   %eax,%eax
  801e01:	75 33                	jne    801e36 <devpipe_read+0x6c>
			sys_yield();
  801e03:	e8 60 ee ff ff       	call   800c68 <sys_yield>
  801e08:	eb e1                	jmp    801deb <devpipe_read+0x21>
				return i;
  801e0a:	89 f0                	mov    %esi,%eax
}
  801e0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e0f:	5b                   	pop    %ebx
  801e10:	5e                   	pop    %esi
  801e11:	5f                   	pop    %edi
  801e12:	5d                   	pop    %ebp
  801e13:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e14:	99                   	cltd   
  801e15:	c1 ea 1b             	shr    $0x1b,%edx
  801e18:	01 d0                	add    %edx,%eax
  801e1a:	83 e0 1f             	and    $0x1f,%eax
  801e1d:	29 d0                	sub    %edx,%eax
  801e1f:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801e24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e27:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801e2a:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801e2d:	83 c6 01             	add    $0x1,%esi
  801e30:	eb b4                	jmp    801de6 <devpipe_read+0x1c>
	return i;
  801e32:	89 f0                	mov    %esi,%eax
  801e34:	eb d6                	jmp    801e0c <devpipe_read+0x42>
				return 0;
  801e36:	b8 00 00 00 00       	mov    $0x0,%eax
  801e3b:	eb cf                	jmp    801e0c <devpipe_read+0x42>

00801e3d <pipe>:
{
  801e3d:	55                   	push   %ebp
  801e3e:	89 e5                	mov    %esp,%ebp
  801e40:	56                   	push   %esi
  801e41:	53                   	push   %ebx
  801e42:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801e45:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e48:	50                   	push   %eax
  801e49:	e8 51 f0 ff ff       	call   800e9f <fd_alloc>
  801e4e:	89 c3                	mov    %eax,%ebx
  801e50:	83 c4 10             	add    $0x10,%esp
  801e53:	85 c0                	test   %eax,%eax
  801e55:	78 5b                	js     801eb2 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e57:	83 ec 04             	sub    $0x4,%esp
  801e5a:	68 07 04 00 00       	push   $0x407
  801e5f:	ff 75 f4             	pushl  -0xc(%ebp)
  801e62:	6a 00                	push   $0x0
  801e64:	e8 1e ee ff ff       	call   800c87 <sys_page_alloc>
  801e69:	89 c3                	mov    %eax,%ebx
  801e6b:	83 c4 10             	add    $0x10,%esp
  801e6e:	85 c0                	test   %eax,%eax
  801e70:	78 40                	js     801eb2 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  801e72:	83 ec 0c             	sub    $0xc,%esp
  801e75:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e78:	50                   	push   %eax
  801e79:	e8 21 f0 ff ff       	call   800e9f <fd_alloc>
  801e7e:	89 c3                	mov    %eax,%ebx
  801e80:	83 c4 10             	add    $0x10,%esp
  801e83:	85 c0                	test   %eax,%eax
  801e85:	78 1b                	js     801ea2 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e87:	83 ec 04             	sub    $0x4,%esp
  801e8a:	68 07 04 00 00       	push   $0x407
  801e8f:	ff 75 f0             	pushl  -0x10(%ebp)
  801e92:	6a 00                	push   $0x0
  801e94:	e8 ee ed ff ff       	call   800c87 <sys_page_alloc>
  801e99:	89 c3                	mov    %eax,%ebx
  801e9b:	83 c4 10             	add    $0x10,%esp
  801e9e:	85 c0                	test   %eax,%eax
  801ea0:	79 19                	jns    801ebb <pipe+0x7e>
	sys_page_unmap(0, fd0);
  801ea2:	83 ec 08             	sub    $0x8,%esp
  801ea5:	ff 75 f4             	pushl  -0xc(%ebp)
  801ea8:	6a 00                	push   $0x0
  801eaa:	e8 5d ee ff ff       	call   800d0c <sys_page_unmap>
  801eaf:	83 c4 10             	add    $0x10,%esp
}
  801eb2:	89 d8                	mov    %ebx,%eax
  801eb4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eb7:	5b                   	pop    %ebx
  801eb8:	5e                   	pop    %esi
  801eb9:	5d                   	pop    %ebp
  801eba:	c3                   	ret    
	va = fd2data(fd0);
  801ebb:	83 ec 0c             	sub    $0xc,%esp
  801ebe:	ff 75 f4             	pushl  -0xc(%ebp)
  801ec1:	e8 c2 ef ff ff       	call   800e88 <fd2data>
  801ec6:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ec8:	83 c4 0c             	add    $0xc,%esp
  801ecb:	68 07 04 00 00       	push   $0x407
  801ed0:	50                   	push   %eax
  801ed1:	6a 00                	push   $0x0
  801ed3:	e8 af ed ff ff       	call   800c87 <sys_page_alloc>
  801ed8:	89 c3                	mov    %eax,%ebx
  801eda:	83 c4 10             	add    $0x10,%esp
  801edd:	85 c0                	test   %eax,%eax
  801edf:	0f 88 8c 00 00 00    	js     801f71 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ee5:	83 ec 0c             	sub    $0xc,%esp
  801ee8:	ff 75 f0             	pushl  -0x10(%ebp)
  801eeb:	e8 98 ef ff ff       	call   800e88 <fd2data>
  801ef0:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ef7:	50                   	push   %eax
  801ef8:	6a 00                	push   $0x0
  801efa:	56                   	push   %esi
  801efb:	6a 00                	push   $0x0
  801efd:	e8 c8 ed ff ff       	call   800cca <sys_page_map>
  801f02:	89 c3                	mov    %eax,%ebx
  801f04:	83 c4 20             	add    $0x20,%esp
  801f07:	85 c0                	test   %eax,%eax
  801f09:	78 58                	js     801f63 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801f0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f0e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f14:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f16:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f19:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801f20:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f23:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f29:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f2e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801f35:	83 ec 0c             	sub    $0xc,%esp
  801f38:	ff 75 f4             	pushl  -0xc(%ebp)
  801f3b:	e8 38 ef ff ff       	call   800e78 <fd2num>
  801f40:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f43:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f45:	83 c4 04             	add    $0x4,%esp
  801f48:	ff 75 f0             	pushl  -0x10(%ebp)
  801f4b:	e8 28 ef ff ff       	call   800e78 <fd2num>
  801f50:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f53:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801f56:	83 c4 10             	add    $0x10,%esp
  801f59:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f5e:	e9 4f ff ff ff       	jmp    801eb2 <pipe+0x75>
	sys_page_unmap(0, va);
  801f63:	83 ec 08             	sub    $0x8,%esp
  801f66:	56                   	push   %esi
  801f67:	6a 00                	push   $0x0
  801f69:	e8 9e ed ff ff       	call   800d0c <sys_page_unmap>
  801f6e:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801f71:	83 ec 08             	sub    $0x8,%esp
  801f74:	ff 75 f0             	pushl  -0x10(%ebp)
  801f77:	6a 00                	push   $0x0
  801f79:	e8 8e ed ff ff       	call   800d0c <sys_page_unmap>
  801f7e:	83 c4 10             	add    $0x10,%esp
  801f81:	e9 1c ff ff ff       	jmp    801ea2 <pipe+0x65>

00801f86 <pipeisclosed>:
{
  801f86:	55                   	push   %ebp
  801f87:	89 e5                	mov    %esp,%ebp
  801f89:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f8c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f8f:	50                   	push   %eax
  801f90:	ff 75 08             	pushl  0x8(%ebp)
  801f93:	e8 56 ef ff ff       	call   800eee <fd_lookup>
  801f98:	83 c4 10             	add    $0x10,%esp
  801f9b:	85 c0                	test   %eax,%eax
  801f9d:	78 18                	js     801fb7 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801f9f:	83 ec 0c             	sub    $0xc,%esp
  801fa2:	ff 75 f4             	pushl  -0xc(%ebp)
  801fa5:	e8 de ee ff ff       	call   800e88 <fd2data>
	return _pipeisclosed(fd, p);
  801faa:	89 c2                	mov    %eax,%edx
  801fac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801faf:	e8 30 fd ff ff       	call   801ce4 <_pipeisclosed>
  801fb4:	83 c4 10             	add    $0x10,%esp
}
  801fb7:	c9                   	leave  
  801fb8:	c3                   	ret    

00801fb9 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801fb9:	55                   	push   %ebp
  801fba:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801fbc:	b8 00 00 00 00       	mov    $0x0,%eax
  801fc1:	5d                   	pop    %ebp
  801fc2:	c3                   	ret    

00801fc3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801fc3:	55                   	push   %ebp
  801fc4:	89 e5                	mov    %esp,%ebp
  801fc6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801fc9:	68 7f 2a 80 00       	push   $0x802a7f
  801fce:	ff 75 0c             	pushl  0xc(%ebp)
  801fd1:	e8 b8 e8 ff ff       	call   80088e <strcpy>
	return 0;
}
  801fd6:	b8 00 00 00 00       	mov    $0x0,%eax
  801fdb:	c9                   	leave  
  801fdc:	c3                   	ret    

00801fdd <devcons_write>:
{
  801fdd:	55                   	push   %ebp
  801fde:	89 e5                	mov    %esp,%ebp
  801fe0:	57                   	push   %edi
  801fe1:	56                   	push   %esi
  801fe2:	53                   	push   %ebx
  801fe3:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801fe9:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801fee:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801ff4:	eb 2f                	jmp    802025 <devcons_write+0x48>
		m = n - tot;
  801ff6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ff9:	29 f3                	sub    %esi,%ebx
  801ffb:	83 fb 7f             	cmp    $0x7f,%ebx
  801ffe:	b8 7f 00 00 00       	mov    $0x7f,%eax
  802003:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  802006:	83 ec 04             	sub    $0x4,%esp
  802009:	53                   	push   %ebx
  80200a:	89 f0                	mov    %esi,%eax
  80200c:	03 45 0c             	add    0xc(%ebp),%eax
  80200f:	50                   	push   %eax
  802010:	57                   	push   %edi
  802011:	e8 06 ea ff ff       	call   800a1c <memmove>
		sys_cputs(buf, m);
  802016:	83 c4 08             	add    $0x8,%esp
  802019:	53                   	push   %ebx
  80201a:	57                   	push   %edi
  80201b:	e8 ab eb ff ff       	call   800bcb <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  802020:	01 de                	add    %ebx,%esi
  802022:	83 c4 10             	add    $0x10,%esp
  802025:	3b 75 10             	cmp    0x10(%ebp),%esi
  802028:	72 cc                	jb     801ff6 <devcons_write+0x19>
}
  80202a:	89 f0                	mov    %esi,%eax
  80202c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80202f:	5b                   	pop    %ebx
  802030:	5e                   	pop    %esi
  802031:	5f                   	pop    %edi
  802032:	5d                   	pop    %ebp
  802033:	c3                   	ret    

00802034 <devcons_read>:
{
  802034:	55                   	push   %ebp
  802035:	89 e5                	mov    %esp,%ebp
  802037:	83 ec 08             	sub    $0x8,%esp
  80203a:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  80203f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802043:	75 07                	jne    80204c <devcons_read+0x18>
}
  802045:	c9                   	leave  
  802046:	c3                   	ret    
		sys_yield();
  802047:	e8 1c ec ff ff       	call   800c68 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  80204c:	e8 98 eb ff ff       	call   800be9 <sys_cgetc>
  802051:	85 c0                	test   %eax,%eax
  802053:	74 f2                	je     802047 <devcons_read+0x13>
	if (c < 0)
  802055:	85 c0                	test   %eax,%eax
  802057:	78 ec                	js     802045 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  802059:	83 f8 04             	cmp    $0x4,%eax
  80205c:	74 0c                	je     80206a <devcons_read+0x36>
	*(char*)vbuf = c;
  80205e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802061:	88 02                	mov    %al,(%edx)
	return 1;
  802063:	b8 01 00 00 00       	mov    $0x1,%eax
  802068:	eb db                	jmp    802045 <devcons_read+0x11>
		return 0;
  80206a:	b8 00 00 00 00       	mov    $0x0,%eax
  80206f:	eb d4                	jmp    802045 <devcons_read+0x11>

00802071 <cputchar>:
{
  802071:	55                   	push   %ebp
  802072:	89 e5                	mov    %esp,%ebp
  802074:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802077:	8b 45 08             	mov    0x8(%ebp),%eax
  80207a:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  80207d:	6a 01                	push   $0x1
  80207f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802082:	50                   	push   %eax
  802083:	e8 43 eb ff ff       	call   800bcb <sys_cputs>
}
  802088:	83 c4 10             	add    $0x10,%esp
  80208b:	c9                   	leave  
  80208c:	c3                   	ret    

0080208d <getchar>:
{
  80208d:	55                   	push   %ebp
  80208e:	89 e5                	mov    %esp,%ebp
  802090:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802093:	6a 01                	push   $0x1
  802095:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802098:	50                   	push   %eax
  802099:	6a 00                	push   $0x0
  80209b:	e8 bf f0 ff ff       	call   80115f <read>
	if (r < 0)
  8020a0:	83 c4 10             	add    $0x10,%esp
  8020a3:	85 c0                	test   %eax,%eax
  8020a5:	78 08                	js     8020af <getchar+0x22>
	if (r < 1)
  8020a7:	85 c0                	test   %eax,%eax
  8020a9:	7e 06                	jle    8020b1 <getchar+0x24>
	return c;
  8020ab:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  8020af:	c9                   	leave  
  8020b0:	c3                   	ret    
		return -E_EOF;
  8020b1:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  8020b6:	eb f7                	jmp    8020af <getchar+0x22>

008020b8 <iscons>:
{
  8020b8:	55                   	push   %ebp
  8020b9:	89 e5                	mov    %esp,%ebp
  8020bb:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020c1:	50                   	push   %eax
  8020c2:	ff 75 08             	pushl  0x8(%ebp)
  8020c5:	e8 24 ee ff ff       	call   800eee <fd_lookup>
  8020ca:	83 c4 10             	add    $0x10,%esp
  8020cd:	85 c0                	test   %eax,%eax
  8020cf:	78 11                	js     8020e2 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  8020d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020d4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020da:	39 10                	cmp    %edx,(%eax)
  8020dc:	0f 94 c0             	sete   %al
  8020df:	0f b6 c0             	movzbl %al,%eax
}
  8020e2:	c9                   	leave  
  8020e3:	c3                   	ret    

008020e4 <opencons>:
{
  8020e4:	55                   	push   %ebp
  8020e5:	89 e5                	mov    %esp,%ebp
  8020e7:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8020ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020ed:	50                   	push   %eax
  8020ee:	e8 ac ed ff ff       	call   800e9f <fd_alloc>
  8020f3:	83 c4 10             	add    $0x10,%esp
  8020f6:	85 c0                	test   %eax,%eax
  8020f8:	78 3a                	js     802134 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020fa:	83 ec 04             	sub    $0x4,%esp
  8020fd:	68 07 04 00 00       	push   $0x407
  802102:	ff 75 f4             	pushl  -0xc(%ebp)
  802105:	6a 00                	push   $0x0
  802107:	e8 7b eb ff ff       	call   800c87 <sys_page_alloc>
  80210c:	83 c4 10             	add    $0x10,%esp
  80210f:	85 c0                	test   %eax,%eax
  802111:	78 21                	js     802134 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  802113:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802116:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80211c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80211e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802121:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802128:	83 ec 0c             	sub    $0xc,%esp
  80212b:	50                   	push   %eax
  80212c:	e8 47 ed ff ff       	call   800e78 <fd2num>
  802131:	83 c4 10             	add    $0x10,%esp
}
  802134:	c9                   	leave  
  802135:	c3                   	ret    

00802136 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802136:	55                   	push   %ebp
  802137:	89 e5                	mov    %esp,%ebp
  802139:	56                   	push   %esi
  80213a:	53                   	push   %ebx
  80213b:	8b 75 08             	mov    0x8(%ebp),%esi
  80213e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802141:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        //	panic("ipc_recv not implemented");
        int r;
       	if(pg!=NULL){
  802144:	85 c0                	test   %eax,%eax
  802146:	74 3b                	je     802183 <ipc_recv+0x4d>
	  r = sys_ipc_recv(pg);
  802148:	83 ec 0c             	sub    $0xc,%esp
  80214b:	50                   	push   %eax
  80214c:	e8 e6 ec ff ff       	call   800e37 <sys_ipc_recv>
  802151:	83 c4 10             	add    $0x10,%esp
	}else
	  r = sys_ipc_recv((void *)UTOP);
	if(r<0){
  802154:	85 c0                	test   %eax,%eax
  802156:	78 3d                	js     802195 <ipc_recv+0x5f>
	if(perm_store!=NULL){
		*perm_store = 0;
            }
        	return r;
           }else{
	     if(from_env_store!=NULL)
  802158:	85 f6                	test   %esi,%esi
  80215a:	74 0a                	je     802166 <ipc_recv+0x30>
		     *from_env_store = thisenv->env_ipc_from;
  80215c:	a1 04 40 80 00       	mov    0x804004,%eax
  802161:	8b 40 74             	mov    0x74(%eax),%eax
  802164:	89 06                	mov    %eax,(%esi)
	     if(perm_store != NULL)
  802166:	85 db                	test   %ebx,%ebx
  802168:	74 0a                	je     802174 <ipc_recv+0x3e>
		     *perm_store = thisenv->env_ipc_perm;
  80216a:	a1 04 40 80 00       	mov    0x804004,%eax
  80216f:	8b 40 78             	mov    0x78(%eax),%eax
  802172:	89 03                	mov    %eax,(%ebx)
	     return thisenv->env_ipc_value;
  802174:	a1 04 40 80 00       	mov    0x804004,%eax
  802179:	8b 40 70             	mov    0x70(%eax),%eax
	   }

}
  80217c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80217f:	5b                   	pop    %ebx
  802180:	5e                   	pop    %esi
  802181:	5d                   	pop    %ebp
  802182:	c3                   	ret    
	  r = sys_ipc_recv((void *)UTOP);
  802183:	83 ec 0c             	sub    $0xc,%esp
  802186:	68 00 00 c0 ee       	push   $0xeec00000
  80218b:	e8 a7 ec ff ff       	call   800e37 <sys_ipc_recv>
  802190:	83 c4 10             	add    $0x10,%esp
  802193:	eb bf                	jmp    802154 <ipc_recv+0x1e>
	if(from_env_store!=NULL){
  802195:	85 f6                	test   %esi,%esi
  802197:	74 06                	je     80219f <ipc_recv+0x69>
	  *from_env_store = 0;
  802199:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if(perm_store!=NULL){
  80219f:	85 db                	test   %ebx,%ebx
  8021a1:	74 d9                	je     80217c <ipc_recv+0x46>
		*perm_store = 0;
  8021a3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8021a9:	eb d1                	jmp    80217c <ipc_recv+0x46>

008021ab <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8021ab:	55                   	push   %ebp
  8021ac:	89 e5                	mov    %esp,%ebp
  8021ae:	57                   	push   %edi
  8021af:	56                   	push   %esi
  8021b0:	53                   	push   %ebx
  8021b1:	83 ec 0c             	sub    $0xc,%esp
  8021b4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8021b7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8021ba:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if(pg==NULL) pg = (void *)UTOP;
  8021bd:	85 db                	test   %ebx,%ebx
  8021bf:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8021c4:	0f 44 d8             	cmove  %eax,%ebx
	while((r=sys_ipc_try_send(to_env,val,pg,perm))<0){
  8021c7:	ff 75 14             	pushl  0x14(%ebp)
  8021ca:	53                   	push   %ebx
  8021cb:	56                   	push   %esi
  8021cc:	57                   	push   %edi
  8021cd:	e8 42 ec ff ff       	call   800e14 <sys_ipc_try_send>
  8021d2:	83 c4 10             	add    $0x10,%esp
  8021d5:	85 c0                	test   %eax,%eax
  8021d7:	79 20                	jns    8021f9 <ipc_send+0x4e>
	    if(r!=-E_IPC_NOT_RECV){
  8021d9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8021dc:	75 07                	jne    8021e5 <ipc_send+0x3a>
		    panic("ipc_send:send message failed\n");
	    }
	    sys_yield();
  8021de:	e8 85 ea ff ff       	call   800c68 <sys_yield>
  8021e3:	eb e2                	jmp    8021c7 <ipc_send+0x1c>
		    panic("ipc_send:send message failed\n");
  8021e5:	83 ec 04             	sub    $0x4,%esp
  8021e8:	68 8b 2a 80 00       	push   $0x802a8b
  8021ed:	6a 43                	push   $0x43
  8021ef:	68 a9 2a 80 00       	push   $0x802aa9
  8021f4:	e8 9b df ff ff       	call   800194 <_panic>
	}

}
  8021f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021fc:	5b                   	pop    %ebx
  8021fd:	5e                   	pop    %esi
  8021fe:	5f                   	pop    %edi
  8021ff:	5d                   	pop    %ebp
  802200:	c3                   	ret    

00802201 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802201:	55                   	push   %ebp
  802202:	89 e5                	mov    %esp,%ebp
  802204:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802207:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80220c:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80220f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802215:	8b 52 50             	mov    0x50(%edx),%edx
  802218:	39 ca                	cmp    %ecx,%edx
  80221a:	74 11                	je     80222d <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  80221c:	83 c0 01             	add    $0x1,%eax
  80221f:	3d 00 04 00 00       	cmp    $0x400,%eax
  802224:	75 e6                	jne    80220c <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  802226:	b8 00 00 00 00       	mov    $0x0,%eax
  80222b:	eb 0b                	jmp    802238 <ipc_find_env+0x37>
			return envs[i].env_id;
  80222d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802230:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802235:	8b 40 48             	mov    0x48(%eax),%eax
}
  802238:	5d                   	pop    %ebp
  802239:	c3                   	ret    

0080223a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80223a:	55                   	push   %ebp
  80223b:	89 e5                	mov    %esp,%ebp
  80223d:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802240:	89 d0                	mov    %edx,%eax
  802242:	c1 e8 16             	shr    $0x16,%eax
  802245:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80224c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  802251:	f6 c1 01             	test   $0x1,%cl
  802254:	74 1d                	je     802273 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  802256:	c1 ea 0c             	shr    $0xc,%edx
  802259:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802260:	f6 c2 01             	test   $0x1,%dl
  802263:	74 0e                	je     802273 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802265:	c1 ea 0c             	shr    $0xc,%edx
  802268:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80226f:	ef 
  802270:	0f b7 c0             	movzwl %ax,%eax
}
  802273:	5d                   	pop    %ebp
  802274:	c3                   	ret    
  802275:	66 90                	xchg   %ax,%ax
  802277:	66 90                	xchg   %ax,%ax
  802279:	66 90                	xchg   %ax,%ax
  80227b:	66 90                	xchg   %ax,%ax
  80227d:	66 90                	xchg   %ax,%ax
  80227f:	90                   	nop

00802280 <__udivdi3>:
  802280:	55                   	push   %ebp
  802281:	57                   	push   %edi
  802282:	56                   	push   %esi
  802283:	53                   	push   %ebx
  802284:	83 ec 1c             	sub    $0x1c,%esp
  802287:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80228b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  80228f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802293:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  802297:	85 d2                	test   %edx,%edx
  802299:	75 35                	jne    8022d0 <__udivdi3+0x50>
  80229b:	39 f3                	cmp    %esi,%ebx
  80229d:	0f 87 bd 00 00 00    	ja     802360 <__udivdi3+0xe0>
  8022a3:	85 db                	test   %ebx,%ebx
  8022a5:	89 d9                	mov    %ebx,%ecx
  8022a7:	75 0b                	jne    8022b4 <__udivdi3+0x34>
  8022a9:	b8 01 00 00 00       	mov    $0x1,%eax
  8022ae:	31 d2                	xor    %edx,%edx
  8022b0:	f7 f3                	div    %ebx
  8022b2:	89 c1                	mov    %eax,%ecx
  8022b4:	31 d2                	xor    %edx,%edx
  8022b6:	89 f0                	mov    %esi,%eax
  8022b8:	f7 f1                	div    %ecx
  8022ba:	89 c6                	mov    %eax,%esi
  8022bc:	89 e8                	mov    %ebp,%eax
  8022be:	89 f7                	mov    %esi,%edi
  8022c0:	f7 f1                	div    %ecx
  8022c2:	89 fa                	mov    %edi,%edx
  8022c4:	83 c4 1c             	add    $0x1c,%esp
  8022c7:	5b                   	pop    %ebx
  8022c8:	5e                   	pop    %esi
  8022c9:	5f                   	pop    %edi
  8022ca:	5d                   	pop    %ebp
  8022cb:	c3                   	ret    
  8022cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022d0:	39 f2                	cmp    %esi,%edx
  8022d2:	77 7c                	ja     802350 <__udivdi3+0xd0>
  8022d4:	0f bd fa             	bsr    %edx,%edi
  8022d7:	83 f7 1f             	xor    $0x1f,%edi
  8022da:	0f 84 98 00 00 00    	je     802378 <__udivdi3+0xf8>
  8022e0:	89 f9                	mov    %edi,%ecx
  8022e2:	b8 20 00 00 00       	mov    $0x20,%eax
  8022e7:	29 f8                	sub    %edi,%eax
  8022e9:	d3 e2                	shl    %cl,%edx
  8022eb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8022ef:	89 c1                	mov    %eax,%ecx
  8022f1:	89 da                	mov    %ebx,%edx
  8022f3:	d3 ea                	shr    %cl,%edx
  8022f5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8022f9:	09 d1                	or     %edx,%ecx
  8022fb:	89 f2                	mov    %esi,%edx
  8022fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802301:	89 f9                	mov    %edi,%ecx
  802303:	d3 e3                	shl    %cl,%ebx
  802305:	89 c1                	mov    %eax,%ecx
  802307:	d3 ea                	shr    %cl,%edx
  802309:	89 f9                	mov    %edi,%ecx
  80230b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80230f:	d3 e6                	shl    %cl,%esi
  802311:	89 eb                	mov    %ebp,%ebx
  802313:	89 c1                	mov    %eax,%ecx
  802315:	d3 eb                	shr    %cl,%ebx
  802317:	09 de                	or     %ebx,%esi
  802319:	89 f0                	mov    %esi,%eax
  80231b:	f7 74 24 08          	divl   0x8(%esp)
  80231f:	89 d6                	mov    %edx,%esi
  802321:	89 c3                	mov    %eax,%ebx
  802323:	f7 64 24 0c          	mull   0xc(%esp)
  802327:	39 d6                	cmp    %edx,%esi
  802329:	72 0c                	jb     802337 <__udivdi3+0xb7>
  80232b:	89 f9                	mov    %edi,%ecx
  80232d:	d3 e5                	shl    %cl,%ebp
  80232f:	39 c5                	cmp    %eax,%ebp
  802331:	73 5d                	jae    802390 <__udivdi3+0x110>
  802333:	39 d6                	cmp    %edx,%esi
  802335:	75 59                	jne    802390 <__udivdi3+0x110>
  802337:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80233a:	31 ff                	xor    %edi,%edi
  80233c:	89 fa                	mov    %edi,%edx
  80233e:	83 c4 1c             	add    $0x1c,%esp
  802341:	5b                   	pop    %ebx
  802342:	5e                   	pop    %esi
  802343:	5f                   	pop    %edi
  802344:	5d                   	pop    %ebp
  802345:	c3                   	ret    
  802346:	8d 76 00             	lea    0x0(%esi),%esi
  802349:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802350:	31 ff                	xor    %edi,%edi
  802352:	31 c0                	xor    %eax,%eax
  802354:	89 fa                	mov    %edi,%edx
  802356:	83 c4 1c             	add    $0x1c,%esp
  802359:	5b                   	pop    %ebx
  80235a:	5e                   	pop    %esi
  80235b:	5f                   	pop    %edi
  80235c:	5d                   	pop    %ebp
  80235d:	c3                   	ret    
  80235e:	66 90                	xchg   %ax,%ax
  802360:	31 ff                	xor    %edi,%edi
  802362:	89 e8                	mov    %ebp,%eax
  802364:	89 f2                	mov    %esi,%edx
  802366:	f7 f3                	div    %ebx
  802368:	89 fa                	mov    %edi,%edx
  80236a:	83 c4 1c             	add    $0x1c,%esp
  80236d:	5b                   	pop    %ebx
  80236e:	5e                   	pop    %esi
  80236f:	5f                   	pop    %edi
  802370:	5d                   	pop    %ebp
  802371:	c3                   	ret    
  802372:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802378:	39 f2                	cmp    %esi,%edx
  80237a:	72 06                	jb     802382 <__udivdi3+0x102>
  80237c:	31 c0                	xor    %eax,%eax
  80237e:	39 eb                	cmp    %ebp,%ebx
  802380:	77 d2                	ja     802354 <__udivdi3+0xd4>
  802382:	b8 01 00 00 00       	mov    $0x1,%eax
  802387:	eb cb                	jmp    802354 <__udivdi3+0xd4>
  802389:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802390:	89 d8                	mov    %ebx,%eax
  802392:	31 ff                	xor    %edi,%edi
  802394:	eb be                	jmp    802354 <__udivdi3+0xd4>
  802396:	66 90                	xchg   %ax,%ax
  802398:	66 90                	xchg   %ax,%ax
  80239a:	66 90                	xchg   %ax,%ax
  80239c:	66 90                	xchg   %ax,%ax
  80239e:	66 90                	xchg   %ax,%ax

008023a0 <__umoddi3>:
  8023a0:	55                   	push   %ebp
  8023a1:	57                   	push   %edi
  8023a2:	56                   	push   %esi
  8023a3:	53                   	push   %ebx
  8023a4:	83 ec 1c             	sub    $0x1c,%esp
  8023a7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  8023ab:	8b 74 24 30          	mov    0x30(%esp),%esi
  8023af:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8023b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8023b7:	85 ed                	test   %ebp,%ebp
  8023b9:	89 f0                	mov    %esi,%eax
  8023bb:	89 da                	mov    %ebx,%edx
  8023bd:	75 19                	jne    8023d8 <__umoddi3+0x38>
  8023bf:	39 df                	cmp    %ebx,%edi
  8023c1:	0f 86 b1 00 00 00    	jbe    802478 <__umoddi3+0xd8>
  8023c7:	f7 f7                	div    %edi
  8023c9:	89 d0                	mov    %edx,%eax
  8023cb:	31 d2                	xor    %edx,%edx
  8023cd:	83 c4 1c             	add    $0x1c,%esp
  8023d0:	5b                   	pop    %ebx
  8023d1:	5e                   	pop    %esi
  8023d2:	5f                   	pop    %edi
  8023d3:	5d                   	pop    %ebp
  8023d4:	c3                   	ret    
  8023d5:	8d 76 00             	lea    0x0(%esi),%esi
  8023d8:	39 dd                	cmp    %ebx,%ebp
  8023da:	77 f1                	ja     8023cd <__umoddi3+0x2d>
  8023dc:	0f bd cd             	bsr    %ebp,%ecx
  8023df:	83 f1 1f             	xor    $0x1f,%ecx
  8023e2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8023e6:	0f 84 b4 00 00 00    	je     8024a0 <__umoddi3+0x100>
  8023ec:	b8 20 00 00 00       	mov    $0x20,%eax
  8023f1:	89 c2                	mov    %eax,%edx
  8023f3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8023f7:	29 c2                	sub    %eax,%edx
  8023f9:	89 c1                	mov    %eax,%ecx
  8023fb:	89 f8                	mov    %edi,%eax
  8023fd:	d3 e5                	shl    %cl,%ebp
  8023ff:	89 d1                	mov    %edx,%ecx
  802401:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802405:	d3 e8                	shr    %cl,%eax
  802407:	09 c5                	or     %eax,%ebp
  802409:	8b 44 24 04          	mov    0x4(%esp),%eax
  80240d:	89 c1                	mov    %eax,%ecx
  80240f:	d3 e7                	shl    %cl,%edi
  802411:	89 d1                	mov    %edx,%ecx
  802413:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802417:	89 df                	mov    %ebx,%edi
  802419:	d3 ef                	shr    %cl,%edi
  80241b:	89 c1                	mov    %eax,%ecx
  80241d:	89 f0                	mov    %esi,%eax
  80241f:	d3 e3                	shl    %cl,%ebx
  802421:	89 d1                	mov    %edx,%ecx
  802423:	89 fa                	mov    %edi,%edx
  802425:	d3 e8                	shr    %cl,%eax
  802427:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80242c:	09 d8                	or     %ebx,%eax
  80242e:	f7 f5                	div    %ebp
  802430:	d3 e6                	shl    %cl,%esi
  802432:	89 d1                	mov    %edx,%ecx
  802434:	f7 64 24 08          	mull   0x8(%esp)
  802438:	39 d1                	cmp    %edx,%ecx
  80243a:	89 c3                	mov    %eax,%ebx
  80243c:	89 d7                	mov    %edx,%edi
  80243e:	72 06                	jb     802446 <__umoddi3+0xa6>
  802440:	75 0e                	jne    802450 <__umoddi3+0xb0>
  802442:	39 c6                	cmp    %eax,%esi
  802444:	73 0a                	jae    802450 <__umoddi3+0xb0>
  802446:	2b 44 24 08          	sub    0x8(%esp),%eax
  80244a:	19 ea                	sbb    %ebp,%edx
  80244c:	89 d7                	mov    %edx,%edi
  80244e:	89 c3                	mov    %eax,%ebx
  802450:	89 ca                	mov    %ecx,%edx
  802452:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  802457:	29 de                	sub    %ebx,%esi
  802459:	19 fa                	sbb    %edi,%edx
  80245b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80245f:	89 d0                	mov    %edx,%eax
  802461:	d3 e0                	shl    %cl,%eax
  802463:	89 d9                	mov    %ebx,%ecx
  802465:	d3 ee                	shr    %cl,%esi
  802467:	d3 ea                	shr    %cl,%edx
  802469:	09 f0                	or     %esi,%eax
  80246b:	83 c4 1c             	add    $0x1c,%esp
  80246e:	5b                   	pop    %ebx
  80246f:	5e                   	pop    %esi
  802470:	5f                   	pop    %edi
  802471:	5d                   	pop    %ebp
  802472:	c3                   	ret    
  802473:	90                   	nop
  802474:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802478:	85 ff                	test   %edi,%edi
  80247a:	89 f9                	mov    %edi,%ecx
  80247c:	75 0b                	jne    802489 <__umoddi3+0xe9>
  80247e:	b8 01 00 00 00       	mov    $0x1,%eax
  802483:	31 d2                	xor    %edx,%edx
  802485:	f7 f7                	div    %edi
  802487:	89 c1                	mov    %eax,%ecx
  802489:	89 d8                	mov    %ebx,%eax
  80248b:	31 d2                	xor    %edx,%edx
  80248d:	f7 f1                	div    %ecx
  80248f:	89 f0                	mov    %esi,%eax
  802491:	f7 f1                	div    %ecx
  802493:	e9 31 ff ff ff       	jmp    8023c9 <__umoddi3+0x29>
  802498:	90                   	nop
  802499:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024a0:	39 dd                	cmp    %ebx,%ebp
  8024a2:	72 08                	jb     8024ac <__umoddi3+0x10c>
  8024a4:	39 f7                	cmp    %esi,%edi
  8024a6:	0f 87 21 ff ff ff    	ja     8023cd <__umoddi3+0x2d>
  8024ac:	89 da                	mov    %ebx,%edx
  8024ae:	89 f0                	mov    %esi,%eax
  8024b0:	29 f8                	sub    %edi,%eax
  8024b2:	19 ea                	sbb    %ebp,%edx
  8024b4:	e9 14 ff ff ff       	jmp    8023cd <__umoddi3+0x2d>
