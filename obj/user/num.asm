
obj/user/num.debug:     file format elf32-i386


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
  80002c:	e8 52 01 00 00       	call   800183 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <num>:
int bol = 1;
int line = 0;

void
num(int f, const char *s)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 10             	sub    $0x10,%esp
  80003b:	8b 75 08             	mov    0x8(%ebp),%esi
	long n;
	int r;
	char c;

	while ((n = read(f, &c, 1)) > 0) {
  80003e:	8d 5d f7             	lea    -0x9(%ebp),%ebx
  800041:	eb 1b                	jmp    80005e <num+0x2b>
		if (bol) {
			printf("%5d ", ++line);
			bol = 0;
		}
		if ((r = write(1, &c, 1)) != 1)
  800043:	83 ec 04             	sub    $0x4,%esp
  800046:	6a 01                	push   $0x1
  800048:	53                   	push   %ebx
  800049:	6a 01                	push   $0x1
  80004b:	e8 2c 12 00 00       	call   80127c <write>
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	83 f8 01             	cmp    $0x1,%eax
  800056:	75 4c                	jne    8000a4 <num+0x71>
			panic("write error copying %s: %e", s, r);
		if (c == '\n')
  800058:	80 7d f7 0a          	cmpb   $0xa,-0x9(%ebp)
  80005c:	74 5e                	je     8000bc <num+0x89>
	while ((n = read(f, &c, 1)) > 0) {
  80005e:	83 ec 04             	sub    $0x4,%esp
  800061:	6a 01                	push   $0x1
  800063:	53                   	push   %ebx
  800064:	56                   	push   %esi
  800065:	e8 44 11 00 00       	call   8011ae <read>
  80006a:	83 c4 10             	add    $0x10,%esp
  80006d:	85 c0                	test   %eax,%eax
  80006f:	7e 57                	jle    8000c8 <num+0x95>
		if (bol) {
  800071:	83 3d 00 30 80 00 00 	cmpl   $0x0,0x803000
  800078:	74 c9                	je     800043 <num+0x10>
			printf("%5d ", ++line);
  80007a:	a1 00 40 80 00       	mov    0x804000,%eax
  80007f:	83 c0 01             	add    $0x1,%eax
  800082:	a3 00 40 80 00       	mov    %eax,0x804000
  800087:	83 ec 08             	sub    $0x8,%esp
  80008a:	50                   	push   %eax
  80008b:	68 20 20 80 00       	push   $0x802020
  800090:	e8 22 17 00 00       	call   8017b7 <printf>
			bol = 0;
  800095:	c7 05 00 30 80 00 00 	movl   $0x0,0x803000
  80009c:	00 00 00 
  80009f:	83 c4 10             	add    $0x10,%esp
  8000a2:	eb 9f                	jmp    800043 <num+0x10>
			panic("write error copying %s: %e", s, r);
  8000a4:	83 ec 0c             	sub    $0xc,%esp
  8000a7:	50                   	push   %eax
  8000a8:	ff 75 0c             	pushl  0xc(%ebp)
  8000ab:	68 25 20 80 00       	push   $0x802025
  8000b0:	6a 13                	push   $0x13
  8000b2:	68 40 20 80 00       	push   $0x802040
  8000b7:	e8 27 01 00 00       	call   8001e3 <_panic>
			bol = 1;
  8000bc:	c7 05 00 30 80 00 01 	movl   $0x1,0x803000
  8000c3:	00 00 00 
  8000c6:	eb 96                	jmp    80005e <num+0x2b>
	}
	if (n < 0)
  8000c8:	85 c0                	test   %eax,%eax
  8000ca:	78 07                	js     8000d3 <num+0xa0>
		panic("error reading %s: %e", s, n);
}
  8000cc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000cf:	5b                   	pop    %ebx
  8000d0:	5e                   	pop    %esi
  8000d1:	5d                   	pop    %ebp
  8000d2:	c3                   	ret    
		panic("error reading %s: %e", s, n);
  8000d3:	83 ec 0c             	sub    $0xc,%esp
  8000d6:	50                   	push   %eax
  8000d7:	ff 75 0c             	pushl  0xc(%ebp)
  8000da:	68 4b 20 80 00       	push   $0x80204b
  8000df:	6a 18                	push   $0x18
  8000e1:	68 40 20 80 00       	push   $0x802040
  8000e6:	e8 f8 00 00 00       	call   8001e3 <_panic>

008000eb <umain>:

void
umain(int argc, char **argv)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 1c             	sub    $0x1c,%esp
	int f, i;

	binaryname = "num";
  8000f4:	c7 05 04 30 80 00 60 	movl   $0x802060,0x803004
  8000fb:	20 80 00 
	if (argc == 1)
  8000fe:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  800102:	74 46                	je     80014a <umain+0x5f>
  800104:	8b 45 0c             	mov    0xc(%ebp),%eax
  800107:	8d 58 04             	lea    0x4(%eax),%ebx
		num(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  80010a:	bf 01 00 00 00       	mov    $0x1,%edi
  80010f:	3b 7d 08             	cmp    0x8(%ebp),%edi
  800112:	7d 48                	jge    80015c <umain+0x71>
			f = open(argv[i], O_RDONLY);
  800114:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800117:	83 ec 08             	sub    $0x8,%esp
  80011a:	6a 00                	push   $0x0
  80011c:	ff 33                	pushl  (%ebx)
  80011e:	e8 f0 14 00 00       	call   801613 <open>
  800123:	89 c6                	mov    %eax,%esi
			if (f < 0)
  800125:	83 c4 10             	add    $0x10,%esp
  800128:	85 c0                	test   %eax,%eax
  80012a:	78 3d                	js     800169 <umain+0x7e>
				panic("can't open %s: %e", argv[i], f);
			else {
				num(f, argv[i]);
  80012c:	83 ec 08             	sub    $0x8,%esp
  80012f:	ff 33                	pushl  (%ebx)
  800131:	50                   	push   %eax
  800132:	e8 fc fe ff ff       	call   800033 <num>
				close(f);
  800137:	89 34 24             	mov    %esi,(%esp)
  80013a:	e8 33 0f 00 00       	call   801072 <close>
		for (i = 1; i < argc; i++) {
  80013f:	83 c7 01             	add    $0x1,%edi
  800142:	83 c3 04             	add    $0x4,%ebx
  800145:	83 c4 10             	add    $0x10,%esp
  800148:	eb c5                	jmp    80010f <umain+0x24>
		num(0, "<stdin>");
  80014a:	83 ec 08             	sub    $0x8,%esp
  80014d:	68 64 20 80 00       	push   $0x802064
  800152:	6a 00                	push   $0x0
  800154:	e8 da fe ff ff       	call   800033 <num>
  800159:	83 c4 10             	add    $0x10,%esp
			}
		}
	exit();
  80015c:	e8 68 00 00 00       	call   8001c9 <exit>
}
  800161:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800164:	5b                   	pop    %ebx
  800165:	5e                   	pop    %esi
  800166:	5f                   	pop    %edi
  800167:	5d                   	pop    %ebp
  800168:	c3                   	ret    
				panic("can't open %s: %e", argv[i], f);
  800169:	83 ec 0c             	sub    $0xc,%esp
  80016c:	50                   	push   %eax
  80016d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800170:	ff 30                	pushl  (%eax)
  800172:	68 6c 20 80 00       	push   $0x80206c
  800177:	6a 27                	push   $0x27
  800179:	68 40 20 80 00       	push   $0x802040
  80017e:	e8 60 00 00 00       	call   8001e3 <_panic>

00800183 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800183:	55                   	push   %ebp
  800184:	89 e5                	mov    %esp,%ebp
  800186:	56                   	push   %esi
  800187:	53                   	push   %ebx
  800188:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80018b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80018e:	e8 05 0b 00 00       	call   800c98 <sys_getenvid>
  800193:	25 ff 03 00 00       	and    $0x3ff,%eax
  800198:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80019b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001a0:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001a5:	85 db                	test   %ebx,%ebx
  8001a7:	7e 07                	jle    8001b0 <libmain+0x2d>
		binaryname = argv[0];
  8001a9:	8b 06                	mov    (%esi),%eax
  8001ab:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8001b0:	83 ec 08             	sub    $0x8,%esp
  8001b3:	56                   	push   %esi
  8001b4:	53                   	push   %ebx
  8001b5:	e8 31 ff ff ff       	call   8000eb <umain>

	// exit gracefully
	exit();
  8001ba:	e8 0a 00 00 00       	call   8001c9 <exit>
}
  8001bf:	83 c4 10             	add    $0x10,%esp
  8001c2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001c5:	5b                   	pop    %ebx
  8001c6:	5e                   	pop    %esi
  8001c7:	5d                   	pop    %ebp
  8001c8:	c3                   	ret    

008001c9 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001c9:	55                   	push   %ebp
  8001ca:	89 e5                	mov    %esp,%ebp
  8001cc:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001cf:	e8 c9 0e 00 00       	call   80109d <close_all>
	sys_env_destroy(0);
  8001d4:	83 ec 0c             	sub    $0xc,%esp
  8001d7:	6a 00                	push   $0x0
  8001d9:	e8 79 0a 00 00       	call   800c57 <sys_env_destroy>
}
  8001de:	83 c4 10             	add    $0x10,%esp
  8001e1:	c9                   	leave  
  8001e2:	c3                   	ret    

008001e3 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	56                   	push   %esi
  8001e7:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001e8:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001eb:	8b 35 04 30 80 00    	mov    0x803004,%esi
  8001f1:	e8 a2 0a 00 00       	call   800c98 <sys_getenvid>
  8001f6:	83 ec 0c             	sub    $0xc,%esp
  8001f9:	ff 75 0c             	pushl  0xc(%ebp)
  8001fc:	ff 75 08             	pushl  0x8(%ebp)
  8001ff:	56                   	push   %esi
  800200:	50                   	push   %eax
  800201:	68 88 20 80 00       	push   $0x802088
  800206:	e8 b3 00 00 00       	call   8002be <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80020b:	83 c4 18             	add    $0x18,%esp
  80020e:	53                   	push   %ebx
  80020f:	ff 75 10             	pushl  0x10(%ebp)
  800212:	e8 56 00 00 00       	call   80026d <vcprintf>
	cprintf("\n");
  800217:	c7 04 24 a7 24 80 00 	movl   $0x8024a7,(%esp)
  80021e:	e8 9b 00 00 00       	call   8002be <cprintf>
  800223:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800226:	cc                   	int3   
  800227:	eb fd                	jmp    800226 <_panic+0x43>

00800229 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800229:	55                   	push   %ebp
  80022a:	89 e5                	mov    %esp,%ebp
  80022c:	53                   	push   %ebx
  80022d:	83 ec 04             	sub    $0x4,%esp
  800230:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800233:	8b 13                	mov    (%ebx),%edx
  800235:	8d 42 01             	lea    0x1(%edx),%eax
  800238:	89 03                	mov    %eax,(%ebx)
  80023a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80023d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800241:	3d ff 00 00 00       	cmp    $0xff,%eax
  800246:	74 09                	je     800251 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800248:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80024c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80024f:	c9                   	leave  
  800250:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800251:	83 ec 08             	sub    $0x8,%esp
  800254:	68 ff 00 00 00       	push   $0xff
  800259:	8d 43 08             	lea    0x8(%ebx),%eax
  80025c:	50                   	push   %eax
  80025d:	e8 b8 09 00 00       	call   800c1a <sys_cputs>
		b->idx = 0;
  800262:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800268:	83 c4 10             	add    $0x10,%esp
  80026b:	eb db                	jmp    800248 <putch+0x1f>

0080026d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80026d:	55                   	push   %ebp
  80026e:	89 e5                	mov    %esp,%ebp
  800270:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800276:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80027d:	00 00 00 
	b.cnt = 0;
  800280:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800287:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80028a:	ff 75 0c             	pushl  0xc(%ebp)
  80028d:	ff 75 08             	pushl  0x8(%ebp)
  800290:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800296:	50                   	push   %eax
  800297:	68 29 02 80 00       	push   $0x800229
  80029c:	e8 1a 01 00 00       	call   8003bb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002a1:	83 c4 08             	add    $0x8,%esp
  8002a4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002aa:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002b0:	50                   	push   %eax
  8002b1:	e8 64 09 00 00       	call   800c1a <sys_cputs>

	return b.cnt;
}
  8002b6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002bc:	c9                   	leave  
  8002bd:	c3                   	ret    

008002be <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
  8002c1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002c4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002c7:	50                   	push   %eax
  8002c8:	ff 75 08             	pushl  0x8(%ebp)
  8002cb:	e8 9d ff ff ff       	call   80026d <vcprintf>
	va_end(ap);

	return cnt;
}
  8002d0:	c9                   	leave  
  8002d1:	c3                   	ret    

008002d2 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	57                   	push   %edi
  8002d6:	56                   	push   %esi
  8002d7:	53                   	push   %ebx
  8002d8:	83 ec 1c             	sub    $0x1c,%esp
  8002db:	89 c7                	mov    %eax,%edi
  8002dd:	89 d6                	mov    %edx,%esi
  8002df:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002e8:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002eb:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002ee:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002f3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002f6:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002f9:	39 d3                	cmp    %edx,%ebx
  8002fb:	72 05                	jb     800302 <printnum+0x30>
  8002fd:	39 45 10             	cmp    %eax,0x10(%ebp)
  800300:	77 7a                	ja     80037c <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800302:	83 ec 0c             	sub    $0xc,%esp
  800305:	ff 75 18             	pushl  0x18(%ebp)
  800308:	8b 45 14             	mov    0x14(%ebp),%eax
  80030b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80030e:	53                   	push   %ebx
  80030f:	ff 75 10             	pushl  0x10(%ebp)
  800312:	83 ec 08             	sub    $0x8,%esp
  800315:	ff 75 e4             	pushl  -0x1c(%ebp)
  800318:	ff 75 e0             	pushl  -0x20(%ebp)
  80031b:	ff 75 dc             	pushl  -0x24(%ebp)
  80031e:	ff 75 d8             	pushl  -0x28(%ebp)
  800321:	e8 ba 1a 00 00       	call   801de0 <__udivdi3>
  800326:	83 c4 18             	add    $0x18,%esp
  800329:	52                   	push   %edx
  80032a:	50                   	push   %eax
  80032b:	89 f2                	mov    %esi,%edx
  80032d:	89 f8                	mov    %edi,%eax
  80032f:	e8 9e ff ff ff       	call   8002d2 <printnum>
  800334:	83 c4 20             	add    $0x20,%esp
  800337:	eb 13                	jmp    80034c <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800339:	83 ec 08             	sub    $0x8,%esp
  80033c:	56                   	push   %esi
  80033d:	ff 75 18             	pushl  0x18(%ebp)
  800340:	ff d7                	call   *%edi
  800342:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800345:	83 eb 01             	sub    $0x1,%ebx
  800348:	85 db                	test   %ebx,%ebx
  80034a:	7f ed                	jg     800339 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80034c:	83 ec 08             	sub    $0x8,%esp
  80034f:	56                   	push   %esi
  800350:	83 ec 04             	sub    $0x4,%esp
  800353:	ff 75 e4             	pushl  -0x1c(%ebp)
  800356:	ff 75 e0             	pushl  -0x20(%ebp)
  800359:	ff 75 dc             	pushl  -0x24(%ebp)
  80035c:	ff 75 d8             	pushl  -0x28(%ebp)
  80035f:	e8 9c 1b 00 00       	call   801f00 <__umoddi3>
  800364:	83 c4 14             	add    $0x14,%esp
  800367:	0f be 80 ab 20 80 00 	movsbl 0x8020ab(%eax),%eax
  80036e:	50                   	push   %eax
  80036f:	ff d7                	call   *%edi
}
  800371:	83 c4 10             	add    $0x10,%esp
  800374:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800377:	5b                   	pop    %ebx
  800378:	5e                   	pop    %esi
  800379:	5f                   	pop    %edi
  80037a:	5d                   	pop    %ebp
  80037b:	c3                   	ret    
  80037c:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80037f:	eb c4                	jmp    800345 <printnum+0x73>

00800381 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800381:	55                   	push   %ebp
  800382:	89 e5                	mov    %esp,%ebp
  800384:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800387:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80038b:	8b 10                	mov    (%eax),%edx
  80038d:	3b 50 04             	cmp    0x4(%eax),%edx
  800390:	73 0a                	jae    80039c <sprintputch+0x1b>
		*b->buf++ = ch;
  800392:	8d 4a 01             	lea    0x1(%edx),%ecx
  800395:	89 08                	mov    %ecx,(%eax)
  800397:	8b 45 08             	mov    0x8(%ebp),%eax
  80039a:	88 02                	mov    %al,(%edx)
}
  80039c:	5d                   	pop    %ebp
  80039d:	c3                   	ret    

0080039e <printfmt>:
{
  80039e:	55                   	push   %ebp
  80039f:	89 e5                	mov    %esp,%ebp
  8003a1:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8003a4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003a7:	50                   	push   %eax
  8003a8:	ff 75 10             	pushl  0x10(%ebp)
  8003ab:	ff 75 0c             	pushl  0xc(%ebp)
  8003ae:	ff 75 08             	pushl  0x8(%ebp)
  8003b1:	e8 05 00 00 00       	call   8003bb <vprintfmt>
}
  8003b6:	83 c4 10             	add    $0x10,%esp
  8003b9:	c9                   	leave  
  8003ba:	c3                   	ret    

008003bb <vprintfmt>:
{
  8003bb:	55                   	push   %ebp
  8003bc:	89 e5                	mov    %esp,%ebp
  8003be:	57                   	push   %edi
  8003bf:	56                   	push   %esi
  8003c0:	53                   	push   %ebx
  8003c1:	83 ec 2c             	sub    $0x2c,%esp
  8003c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8003c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003ca:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003cd:	e9 c1 03 00 00       	jmp    800793 <vprintfmt+0x3d8>
		padc = ' ';
  8003d2:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8003d6:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8003dd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8003e4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003eb:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003f0:	8d 47 01             	lea    0x1(%edi),%eax
  8003f3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003f6:	0f b6 17             	movzbl (%edi),%edx
  8003f9:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003fc:	3c 55                	cmp    $0x55,%al
  8003fe:	0f 87 12 04 00 00    	ja     800816 <vprintfmt+0x45b>
  800404:	0f b6 c0             	movzbl %al,%eax
  800407:	ff 24 85 e0 21 80 00 	jmp    *0x8021e0(,%eax,4)
  80040e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800411:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800415:	eb d9                	jmp    8003f0 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800417:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80041a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80041e:	eb d0                	jmp    8003f0 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800420:	0f b6 d2             	movzbl %dl,%edx
  800423:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800426:	b8 00 00 00 00       	mov    $0x0,%eax
  80042b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80042e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800431:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800435:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800438:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80043b:	83 f9 09             	cmp    $0x9,%ecx
  80043e:	77 55                	ja     800495 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800440:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800443:	eb e9                	jmp    80042e <vprintfmt+0x73>
			precision = va_arg(ap, int);
  800445:	8b 45 14             	mov    0x14(%ebp),%eax
  800448:	8b 00                	mov    (%eax),%eax
  80044a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80044d:	8b 45 14             	mov    0x14(%ebp),%eax
  800450:	8d 40 04             	lea    0x4(%eax),%eax
  800453:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800456:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800459:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80045d:	79 91                	jns    8003f0 <vprintfmt+0x35>
				width = precision, precision = -1;
  80045f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800462:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800465:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80046c:	eb 82                	jmp    8003f0 <vprintfmt+0x35>
  80046e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800471:	85 c0                	test   %eax,%eax
  800473:	ba 00 00 00 00       	mov    $0x0,%edx
  800478:	0f 49 d0             	cmovns %eax,%edx
  80047b:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80047e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800481:	e9 6a ff ff ff       	jmp    8003f0 <vprintfmt+0x35>
  800486:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800489:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800490:	e9 5b ff ff ff       	jmp    8003f0 <vprintfmt+0x35>
  800495:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800498:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80049b:	eb bc                	jmp    800459 <vprintfmt+0x9e>
			lflag++;
  80049d:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8004a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004a3:	e9 48 ff ff ff       	jmp    8003f0 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8004a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ab:	8d 78 04             	lea    0x4(%eax),%edi
  8004ae:	83 ec 08             	sub    $0x8,%esp
  8004b1:	53                   	push   %ebx
  8004b2:	ff 30                	pushl  (%eax)
  8004b4:	ff d6                	call   *%esi
			break;
  8004b6:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004b9:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8004bc:	e9 cf 02 00 00       	jmp    800790 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  8004c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c4:	8d 78 04             	lea    0x4(%eax),%edi
  8004c7:	8b 00                	mov    (%eax),%eax
  8004c9:	99                   	cltd   
  8004ca:	31 d0                	xor    %edx,%eax
  8004cc:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004ce:	83 f8 0f             	cmp    $0xf,%eax
  8004d1:	7f 23                	jg     8004f6 <vprintfmt+0x13b>
  8004d3:	8b 14 85 40 23 80 00 	mov    0x802340(,%eax,4),%edx
  8004da:	85 d2                	test   %edx,%edx
  8004dc:	74 18                	je     8004f6 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8004de:	52                   	push   %edx
  8004df:	68 75 24 80 00       	push   $0x802475
  8004e4:	53                   	push   %ebx
  8004e5:	56                   	push   %esi
  8004e6:	e8 b3 fe ff ff       	call   80039e <printfmt>
  8004eb:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004ee:	89 7d 14             	mov    %edi,0x14(%ebp)
  8004f1:	e9 9a 02 00 00       	jmp    800790 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  8004f6:	50                   	push   %eax
  8004f7:	68 c3 20 80 00       	push   $0x8020c3
  8004fc:	53                   	push   %ebx
  8004fd:	56                   	push   %esi
  8004fe:	e8 9b fe ff ff       	call   80039e <printfmt>
  800503:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800506:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800509:	e9 82 02 00 00       	jmp    800790 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  80050e:	8b 45 14             	mov    0x14(%ebp),%eax
  800511:	83 c0 04             	add    $0x4,%eax
  800514:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800517:	8b 45 14             	mov    0x14(%ebp),%eax
  80051a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80051c:	85 ff                	test   %edi,%edi
  80051e:	b8 bc 20 80 00       	mov    $0x8020bc,%eax
  800523:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800526:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80052a:	0f 8e bd 00 00 00    	jle    8005ed <vprintfmt+0x232>
  800530:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800534:	75 0e                	jne    800544 <vprintfmt+0x189>
  800536:	89 75 08             	mov    %esi,0x8(%ebp)
  800539:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80053c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80053f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800542:	eb 6d                	jmp    8005b1 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  800544:	83 ec 08             	sub    $0x8,%esp
  800547:	ff 75 d0             	pushl  -0x30(%ebp)
  80054a:	57                   	push   %edi
  80054b:	e8 6e 03 00 00       	call   8008be <strnlen>
  800550:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800553:	29 c1                	sub    %eax,%ecx
  800555:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800558:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80055b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80055f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800562:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800565:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800567:	eb 0f                	jmp    800578 <vprintfmt+0x1bd>
					putch(padc, putdat);
  800569:	83 ec 08             	sub    $0x8,%esp
  80056c:	53                   	push   %ebx
  80056d:	ff 75 e0             	pushl  -0x20(%ebp)
  800570:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800572:	83 ef 01             	sub    $0x1,%edi
  800575:	83 c4 10             	add    $0x10,%esp
  800578:	85 ff                	test   %edi,%edi
  80057a:	7f ed                	jg     800569 <vprintfmt+0x1ae>
  80057c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80057f:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800582:	85 c9                	test   %ecx,%ecx
  800584:	b8 00 00 00 00       	mov    $0x0,%eax
  800589:	0f 49 c1             	cmovns %ecx,%eax
  80058c:	29 c1                	sub    %eax,%ecx
  80058e:	89 75 08             	mov    %esi,0x8(%ebp)
  800591:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800594:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800597:	89 cb                	mov    %ecx,%ebx
  800599:	eb 16                	jmp    8005b1 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  80059b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80059f:	75 31                	jne    8005d2 <vprintfmt+0x217>
					putch(ch, putdat);
  8005a1:	83 ec 08             	sub    $0x8,%esp
  8005a4:	ff 75 0c             	pushl  0xc(%ebp)
  8005a7:	50                   	push   %eax
  8005a8:	ff 55 08             	call   *0x8(%ebp)
  8005ab:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ae:	83 eb 01             	sub    $0x1,%ebx
  8005b1:	83 c7 01             	add    $0x1,%edi
  8005b4:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8005b8:	0f be c2             	movsbl %dl,%eax
  8005bb:	85 c0                	test   %eax,%eax
  8005bd:	74 59                	je     800618 <vprintfmt+0x25d>
  8005bf:	85 f6                	test   %esi,%esi
  8005c1:	78 d8                	js     80059b <vprintfmt+0x1e0>
  8005c3:	83 ee 01             	sub    $0x1,%esi
  8005c6:	79 d3                	jns    80059b <vprintfmt+0x1e0>
  8005c8:	89 df                	mov    %ebx,%edi
  8005ca:	8b 75 08             	mov    0x8(%ebp),%esi
  8005cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005d0:	eb 37                	jmp    800609 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8005d2:	0f be d2             	movsbl %dl,%edx
  8005d5:	83 ea 20             	sub    $0x20,%edx
  8005d8:	83 fa 5e             	cmp    $0x5e,%edx
  8005db:	76 c4                	jbe    8005a1 <vprintfmt+0x1e6>
					putch('?', putdat);
  8005dd:	83 ec 08             	sub    $0x8,%esp
  8005e0:	ff 75 0c             	pushl  0xc(%ebp)
  8005e3:	6a 3f                	push   $0x3f
  8005e5:	ff 55 08             	call   *0x8(%ebp)
  8005e8:	83 c4 10             	add    $0x10,%esp
  8005eb:	eb c1                	jmp    8005ae <vprintfmt+0x1f3>
  8005ed:	89 75 08             	mov    %esi,0x8(%ebp)
  8005f0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005f3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005f6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005f9:	eb b6                	jmp    8005b1 <vprintfmt+0x1f6>
				putch(' ', putdat);
  8005fb:	83 ec 08             	sub    $0x8,%esp
  8005fe:	53                   	push   %ebx
  8005ff:	6a 20                	push   $0x20
  800601:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800603:	83 ef 01             	sub    $0x1,%edi
  800606:	83 c4 10             	add    $0x10,%esp
  800609:	85 ff                	test   %edi,%edi
  80060b:	7f ee                	jg     8005fb <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  80060d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800610:	89 45 14             	mov    %eax,0x14(%ebp)
  800613:	e9 78 01 00 00       	jmp    800790 <vprintfmt+0x3d5>
  800618:	89 df                	mov    %ebx,%edi
  80061a:	8b 75 08             	mov    0x8(%ebp),%esi
  80061d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800620:	eb e7                	jmp    800609 <vprintfmt+0x24e>
	if (lflag >= 2)
  800622:	83 f9 01             	cmp    $0x1,%ecx
  800625:	7e 3f                	jle    800666 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800627:	8b 45 14             	mov    0x14(%ebp),%eax
  80062a:	8b 50 04             	mov    0x4(%eax),%edx
  80062d:	8b 00                	mov    (%eax),%eax
  80062f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800632:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800635:	8b 45 14             	mov    0x14(%ebp),%eax
  800638:	8d 40 08             	lea    0x8(%eax),%eax
  80063b:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80063e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800642:	79 5c                	jns    8006a0 <vprintfmt+0x2e5>
				putch('-', putdat);
  800644:	83 ec 08             	sub    $0x8,%esp
  800647:	53                   	push   %ebx
  800648:	6a 2d                	push   $0x2d
  80064a:	ff d6                	call   *%esi
				num = -(long long) num;
  80064c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80064f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800652:	f7 da                	neg    %edx
  800654:	83 d1 00             	adc    $0x0,%ecx
  800657:	f7 d9                	neg    %ecx
  800659:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80065c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800661:	e9 10 01 00 00       	jmp    800776 <vprintfmt+0x3bb>
	else if (lflag)
  800666:	85 c9                	test   %ecx,%ecx
  800668:	75 1b                	jne    800685 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  80066a:	8b 45 14             	mov    0x14(%ebp),%eax
  80066d:	8b 00                	mov    (%eax),%eax
  80066f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800672:	89 c1                	mov    %eax,%ecx
  800674:	c1 f9 1f             	sar    $0x1f,%ecx
  800677:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80067a:	8b 45 14             	mov    0x14(%ebp),%eax
  80067d:	8d 40 04             	lea    0x4(%eax),%eax
  800680:	89 45 14             	mov    %eax,0x14(%ebp)
  800683:	eb b9                	jmp    80063e <vprintfmt+0x283>
		return va_arg(*ap, long);
  800685:	8b 45 14             	mov    0x14(%ebp),%eax
  800688:	8b 00                	mov    (%eax),%eax
  80068a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80068d:	89 c1                	mov    %eax,%ecx
  80068f:	c1 f9 1f             	sar    $0x1f,%ecx
  800692:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800695:	8b 45 14             	mov    0x14(%ebp),%eax
  800698:	8d 40 04             	lea    0x4(%eax),%eax
  80069b:	89 45 14             	mov    %eax,0x14(%ebp)
  80069e:	eb 9e                	jmp    80063e <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8006a0:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006a3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8006a6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ab:	e9 c6 00 00 00       	jmp    800776 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8006b0:	83 f9 01             	cmp    $0x1,%ecx
  8006b3:	7e 18                	jle    8006cd <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8006b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b8:	8b 10                	mov    (%eax),%edx
  8006ba:	8b 48 04             	mov    0x4(%eax),%ecx
  8006bd:	8d 40 08             	lea    0x8(%eax),%eax
  8006c0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006c3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006c8:	e9 a9 00 00 00       	jmp    800776 <vprintfmt+0x3bb>
	else if (lflag)
  8006cd:	85 c9                	test   %ecx,%ecx
  8006cf:	75 1a                	jne    8006eb <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  8006d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d4:	8b 10                	mov    (%eax),%edx
  8006d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006db:	8d 40 04             	lea    0x4(%eax),%eax
  8006de:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006e1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006e6:	e9 8b 00 00 00       	jmp    800776 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8006eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ee:	8b 10                	mov    (%eax),%edx
  8006f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f5:	8d 40 04             	lea    0x4(%eax),%eax
  8006f8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006fb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800700:	eb 74                	jmp    800776 <vprintfmt+0x3bb>
	if (lflag >= 2)
  800702:	83 f9 01             	cmp    $0x1,%ecx
  800705:	7e 15                	jle    80071c <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  800707:	8b 45 14             	mov    0x14(%ebp),%eax
  80070a:	8b 10                	mov    (%eax),%edx
  80070c:	8b 48 04             	mov    0x4(%eax),%ecx
  80070f:	8d 40 08             	lea    0x8(%eax),%eax
  800712:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800715:	b8 08 00 00 00       	mov    $0x8,%eax
  80071a:	eb 5a                	jmp    800776 <vprintfmt+0x3bb>
	else if (lflag)
  80071c:	85 c9                	test   %ecx,%ecx
  80071e:	75 17                	jne    800737 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  800720:	8b 45 14             	mov    0x14(%ebp),%eax
  800723:	8b 10                	mov    (%eax),%edx
  800725:	b9 00 00 00 00       	mov    $0x0,%ecx
  80072a:	8d 40 04             	lea    0x4(%eax),%eax
  80072d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800730:	b8 08 00 00 00       	mov    $0x8,%eax
  800735:	eb 3f                	jmp    800776 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800737:	8b 45 14             	mov    0x14(%ebp),%eax
  80073a:	8b 10                	mov    (%eax),%edx
  80073c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800741:	8d 40 04             	lea    0x4(%eax),%eax
  800744:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800747:	b8 08 00 00 00       	mov    $0x8,%eax
  80074c:	eb 28                	jmp    800776 <vprintfmt+0x3bb>
			putch('0', putdat);
  80074e:	83 ec 08             	sub    $0x8,%esp
  800751:	53                   	push   %ebx
  800752:	6a 30                	push   $0x30
  800754:	ff d6                	call   *%esi
			putch('x', putdat);
  800756:	83 c4 08             	add    $0x8,%esp
  800759:	53                   	push   %ebx
  80075a:	6a 78                	push   $0x78
  80075c:	ff d6                	call   *%esi
			num = (unsigned long long)
  80075e:	8b 45 14             	mov    0x14(%ebp),%eax
  800761:	8b 10                	mov    (%eax),%edx
  800763:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800768:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80076b:	8d 40 04             	lea    0x4(%eax),%eax
  80076e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800771:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800776:	83 ec 0c             	sub    $0xc,%esp
  800779:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80077d:	57                   	push   %edi
  80077e:	ff 75 e0             	pushl  -0x20(%ebp)
  800781:	50                   	push   %eax
  800782:	51                   	push   %ecx
  800783:	52                   	push   %edx
  800784:	89 da                	mov    %ebx,%edx
  800786:	89 f0                	mov    %esi,%eax
  800788:	e8 45 fb ff ff       	call   8002d2 <printnum>
			break;
  80078d:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800790:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800793:	83 c7 01             	add    $0x1,%edi
  800796:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80079a:	83 f8 25             	cmp    $0x25,%eax
  80079d:	0f 84 2f fc ff ff    	je     8003d2 <vprintfmt+0x17>
			if (ch == '\0')
  8007a3:	85 c0                	test   %eax,%eax
  8007a5:	0f 84 8b 00 00 00    	je     800836 <vprintfmt+0x47b>
			putch(ch, putdat);
  8007ab:	83 ec 08             	sub    $0x8,%esp
  8007ae:	53                   	push   %ebx
  8007af:	50                   	push   %eax
  8007b0:	ff d6                	call   *%esi
  8007b2:	83 c4 10             	add    $0x10,%esp
  8007b5:	eb dc                	jmp    800793 <vprintfmt+0x3d8>
	if (lflag >= 2)
  8007b7:	83 f9 01             	cmp    $0x1,%ecx
  8007ba:	7e 15                	jle    8007d1 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  8007bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bf:	8b 10                	mov    (%eax),%edx
  8007c1:	8b 48 04             	mov    0x4(%eax),%ecx
  8007c4:	8d 40 08             	lea    0x8(%eax),%eax
  8007c7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007ca:	b8 10 00 00 00       	mov    $0x10,%eax
  8007cf:	eb a5                	jmp    800776 <vprintfmt+0x3bb>
	else if (lflag)
  8007d1:	85 c9                	test   %ecx,%ecx
  8007d3:	75 17                	jne    8007ec <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  8007d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d8:	8b 10                	mov    (%eax),%edx
  8007da:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007df:	8d 40 04             	lea    0x4(%eax),%eax
  8007e2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007e5:	b8 10 00 00 00       	mov    $0x10,%eax
  8007ea:	eb 8a                	jmp    800776 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8007ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ef:	8b 10                	mov    (%eax),%edx
  8007f1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007f6:	8d 40 04             	lea    0x4(%eax),%eax
  8007f9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007fc:	b8 10 00 00 00       	mov    $0x10,%eax
  800801:	e9 70 ff ff ff       	jmp    800776 <vprintfmt+0x3bb>
			putch(ch, putdat);
  800806:	83 ec 08             	sub    $0x8,%esp
  800809:	53                   	push   %ebx
  80080a:	6a 25                	push   $0x25
  80080c:	ff d6                	call   *%esi
			break;
  80080e:	83 c4 10             	add    $0x10,%esp
  800811:	e9 7a ff ff ff       	jmp    800790 <vprintfmt+0x3d5>
			putch('%', putdat);
  800816:	83 ec 08             	sub    $0x8,%esp
  800819:	53                   	push   %ebx
  80081a:	6a 25                	push   $0x25
  80081c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80081e:	83 c4 10             	add    $0x10,%esp
  800821:	89 f8                	mov    %edi,%eax
  800823:	eb 03                	jmp    800828 <vprintfmt+0x46d>
  800825:	83 e8 01             	sub    $0x1,%eax
  800828:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80082c:	75 f7                	jne    800825 <vprintfmt+0x46a>
  80082e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800831:	e9 5a ff ff ff       	jmp    800790 <vprintfmt+0x3d5>
}
  800836:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800839:	5b                   	pop    %ebx
  80083a:	5e                   	pop    %esi
  80083b:	5f                   	pop    %edi
  80083c:	5d                   	pop    %ebp
  80083d:	c3                   	ret    

0080083e <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80083e:	55                   	push   %ebp
  80083f:	89 e5                	mov    %esp,%ebp
  800841:	83 ec 18             	sub    $0x18,%esp
  800844:	8b 45 08             	mov    0x8(%ebp),%eax
  800847:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80084a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80084d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800851:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800854:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80085b:	85 c0                	test   %eax,%eax
  80085d:	74 26                	je     800885 <vsnprintf+0x47>
  80085f:	85 d2                	test   %edx,%edx
  800861:	7e 22                	jle    800885 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800863:	ff 75 14             	pushl  0x14(%ebp)
  800866:	ff 75 10             	pushl  0x10(%ebp)
  800869:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80086c:	50                   	push   %eax
  80086d:	68 81 03 80 00       	push   $0x800381
  800872:	e8 44 fb ff ff       	call   8003bb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800877:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80087a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80087d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800880:	83 c4 10             	add    $0x10,%esp
}
  800883:	c9                   	leave  
  800884:	c3                   	ret    
		return -E_INVAL;
  800885:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80088a:	eb f7                	jmp    800883 <vsnprintf+0x45>

0080088c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80088c:	55                   	push   %ebp
  80088d:	89 e5                	mov    %esp,%ebp
  80088f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800892:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800895:	50                   	push   %eax
  800896:	ff 75 10             	pushl  0x10(%ebp)
  800899:	ff 75 0c             	pushl  0xc(%ebp)
  80089c:	ff 75 08             	pushl  0x8(%ebp)
  80089f:	e8 9a ff ff ff       	call   80083e <vsnprintf>
	va_end(ap);

	return rc;
}
  8008a4:	c9                   	leave  
  8008a5:	c3                   	ret    

008008a6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008a6:	55                   	push   %ebp
  8008a7:	89 e5                	mov    %esp,%ebp
  8008a9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b1:	eb 03                	jmp    8008b6 <strlen+0x10>
		n++;
  8008b3:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008b6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008ba:	75 f7                	jne    8008b3 <strlen+0xd>
	return n;
}
  8008bc:	5d                   	pop    %ebp
  8008bd:	c3                   	ret    

008008be <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008be:	55                   	push   %ebp
  8008bf:	89 e5                	mov    %esp,%ebp
  8008c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c4:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8008cc:	eb 03                	jmp    8008d1 <strnlen+0x13>
		n++;
  8008ce:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008d1:	39 d0                	cmp    %edx,%eax
  8008d3:	74 06                	je     8008db <strnlen+0x1d>
  8008d5:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008d9:	75 f3                	jne    8008ce <strnlen+0x10>
	return n;
}
  8008db:	5d                   	pop    %ebp
  8008dc:	c3                   	ret    

008008dd <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008dd:	55                   	push   %ebp
  8008de:	89 e5                	mov    %esp,%ebp
  8008e0:	53                   	push   %ebx
  8008e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008e7:	89 c2                	mov    %eax,%edx
  8008e9:	83 c1 01             	add    $0x1,%ecx
  8008ec:	83 c2 01             	add    $0x1,%edx
  8008ef:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008f3:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008f6:	84 db                	test   %bl,%bl
  8008f8:	75 ef                	jne    8008e9 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008fa:	5b                   	pop    %ebx
  8008fb:	5d                   	pop    %ebp
  8008fc:	c3                   	ret    

008008fd <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008fd:	55                   	push   %ebp
  8008fe:	89 e5                	mov    %esp,%ebp
  800900:	53                   	push   %ebx
  800901:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800904:	53                   	push   %ebx
  800905:	e8 9c ff ff ff       	call   8008a6 <strlen>
  80090a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80090d:	ff 75 0c             	pushl  0xc(%ebp)
  800910:	01 d8                	add    %ebx,%eax
  800912:	50                   	push   %eax
  800913:	e8 c5 ff ff ff       	call   8008dd <strcpy>
	return dst;
}
  800918:	89 d8                	mov    %ebx,%eax
  80091a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80091d:	c9                   	leave  
  80091e:	c3                   	ret    

0080091f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	56                   	push   %esi
  800923:	53                   	push   %ebx
  800924:	8b 75 08             	mov    0x8(%ebp),%esi
  800927:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80092a:	89 f3                	mov    %esi,%ebx
  80092c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80092f:	89 f2                	mov    %esi,%edx
  800931:	eb 0f                	jmp    800942 <strncpy+0x23>
		*dst++ = *src;
  800933:	83 c2 01             	add    $0x1,%edx
  800936:	0f b6 01             	movzbl (%ecx),%eax
  800939:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80093c:	80 39 01             	cmpb   $0x1,(%ecx)
  80093f:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800942:	39 da                	cmp    %ebx,%edx
  800944:	75 ed                	jne    800933 <strncpy+0x14>
	}
	return ret;
}
  800946:	89 f0                	mov    %esi,%eax
  800948:	5b                   	pop    %ebx
  800949:	5e                   	pop    %esi
  80094a:	5d                   	pop    %ebp
  80094b:	c3                   	ret    

0080094c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80094c:	55                   	push   %ebp
  80094d:	89 e5                	mov    %esp,%ebp
  80094f:	56                   	push   %esi
  800950:	53                   	push   %ebx
  800951:	8b 75 08             	mov    0x8(%ebp),%esi
  800954:	8b 55 0c             	mov    0xc(%ebp),%edx
  800957:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80095a:	89 f0                	mov    %esi,%eax
  80095c:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800960:	85 c9                	test   %ecx,%ecx
  800962:	75 0b                	jne    80096f <strlcpy+0x23>
  800964:	eb 17                	jmp    80097d <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800966:	83 c2 01             	add    $0x1,%edx
  800969:	83 c0 01             	add    $0x1,%eax
  80096c:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  80096f:	39 d8                	cmp    %ebx,%eax
  800971:	74 07                	je     80097a <strlcpy+0x2e>
  800973:	0f b6 0a             	movzbl (%edx),%ecx
  800976:	84 c9                	test   %cl,%cl
  800978:	75 ec                	jne    800966 <strlcpy+0x1a>
		*dst = '\0';
  80097a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80097d:	29 f0                	sub    %esi,%eax
}
  80097f:	5b                   	pop    %ebx
  800980:	5e                   	pop    %esi
  800981:	5d                   	pop    %ebp
  800982:	c3                   	ret    

00800983 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800989:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80098c:	eb 06                	jmp    800994 <strcmp+0x11>
		p++, q++;
  80098e:	83 c1 01             	add    $0x1,%ecx
  800991:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800994:	0f b6 01             	movzbl (%ecx),%eax
  800997:	84 c0                	test   %al,%al
  800999:	74 04                	je     80099f <strcmp+0x1c>
  80099b:	3a 02                	cmp    (%edx),%al
  80099d:	74 ef                	je     80098e <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80099f:	0f b6 c0             	movzbl %al,%eax
  8009a2:	0f b6 12             	movzbl (%edx),%edx
  8009a5:	29 d0                	sub    %edx,%eax
}
  8009a7:	5d                   	pop    %ebp
  8009a8:	c3                   	ret    

008009a9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009a9:	55                   	push   %ebp
  8009aa:	89 e5                	mov    %esp,%ebp
  8009ac:	53                   	push   %ebx
  8009ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b3:	89 c3                	mov    %eax,%ebx
  8009b5:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009b8:	eb 06                	jmp    8009c0 <strncmp+0x17>
		n--, p++, q++;
  8009ba:	83 c0 01             	add    $0x1,%eax
  8009bd:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009c0:	39 d8                	cmp    %ebx,%eax
  8009c2:	74 16                	je     8009da <strncmp+0x31>
  8009c4:	0f b6 08             	movzbl (%eax),%ecx
  8009c7:	84 c9                	test   %cl,%cl
  8009c9:	74 04                	je     8009cf <strncmp+0x26>
  8009cb:	3a 0a                	cmp    (%edx),%cl
  8009cd:	74 eb                	je     8009ba <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009cf:	0f b6 00             	movzbl (%eax),%eax
  8009d2:	0f b6 12             	movzbl (%edx),%edx
  8009d5:	29 d0                	sub    %edx,%eax
}
  8009d7:	5b                   	pop    %ebx
  8009d8:	5d                   	pop    %ebp
  8009d9:	c3                   	ret    
		return 0;
  8009da:	b8 00 00 00 00       	mov    $0x0,%eax
  8009df:	eb f6                	jmp    8009d7 <strncmp+0x2e>

008009e1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009e1:	55                   	push   %ebp
  8009e2:	89 e5                	mov    %esp,%ebp
  8009e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009eb:	0f b6 10             	movzbl (%eax),%edx
  8009ee:	84 d2                	test   %dl,%dl
  8009f0:	74 09                	je     8009fb <strchr+0x1a>
		if (*s == c)
  8009f2:	38 ca                	cmp    %cl,%dl
  8009f4:	74 0a                	je     800a00 <strchr+0x1f>
	for (; *s; s++)
  8009f6:	83 c0 01             	add    $0x1,%eax
  8009f9:	eb f0                	jmp    8009eb <strchr+0xa>
			return (char *) s;
	return 0;
  8009fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a00:	5d                   	pop    %ebp
  800a01:	c3                   	ret    

00800a02 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a02:	55                   	push   %ebp
  800a03:	89 e5                	mov    %esp,%ebp
  800a05:	8b 45 08             	mov    0x8(%ebp),%eax
  800a08:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a0c:	eb 03                	jmp    800a11 <strfind+0xf>
  800a0e:	83 c0 01             	add    $0x1,%eax
  800a11:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a14:	38 ca                	cmp    %cl,%dl
  800a16:	74 04                	je     800a1c <strfind+0x1a>
  800a18:	84 d2                	test   %dl,%dl
  800a1a:	75 f2                	jne    800a0e <strfind+0xc>
			break;
	return (char *) s;
}
  800a1c:	5d                   	pop    %ebp
  800a1d:	c3                   	ret    

00800a1e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	57                   	push   %edi
  800a22:	56                   	push   %esi
  800a23:	53                   	push   %ebx
  800a24:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a27:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a2a:	85 c9                	test   %ecx,%ecx
  800a2c:	74 13                	je     800a41 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a2e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a34:	75 05                	jne    800a3b <memset+0x1d>
  800a36:	f6 c1 03             	test   $0x3,%cl
  800a39:	74 0d                	je     800a48 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a3e:	fc                   	cld    
  800a3f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a41:	89 f8                	mov    %edi,%eax
  800a43:	5b                   	pop    %ebx
  800a44:	5e                   	pop    %esi
  800a45:	5f                   	pop    %edi
  800a46:	5d                   	pop    %ebp
  800a47:	c3                   	ret    
		c &= 0xFF;
  800a48:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a4c:	89 d3                	mov    %edx,%ebx
  800a4e:	c1 e3 08             	shl    $0x8,%ebx
  800a51:	89 d0                	mov    %edx,%eax
  800a53:	c1 e0 18             	shl    $0x18,%eax
  800a56:	89 d6                	mov    %edx,%esi
  800a58:	c1 e6 10             	shl    $0x10,%esi
  800a5b:	09 f0                	or     %esi,%eax
  800a5d:	09 c2                	or     %eax,%edx
  800a5f:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800a61:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a64:	89 d0                	mov    %edx,%eax
  800a66:	fc                   	cld    
  800a67:	f3 ab                	rep stos %eax,%es:(%edi)
  800a69:	eb d6                	jmp    800a41 <memset+0x23>

00800a6b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a6b:	55                   	push   %ebp
  800a6c:	89 e5                	mov    %esp,%ebp
  800a6e:	57                   	push   %edi
  800a6f:	56                   	push   %esi
  800a70:	8b 45 08             	mov    0x8(%ebp),%eax
  800a73:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a76:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a79:	39 c6                	cmp    %eax,%esi
  800a7b:	73 35                	jae    800ab2 <memmove+0x47>
  800a7d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a80:	39 c2                	cmp    %eax,%edx
  800a82:	76 2e                	jbe    800ab2 <memmove+0x47>
		s += n;
		d += n;
  800a84:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a87:	89 d6                	mov    %edx,%esi
  800a89:	09 fe                	or     %edi,%esi
  800a8b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a91:	74 0c                	je     800a9f <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a93:	83 ef 01             	sub    $0x1,%edi
  800a96:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a99:	fd                   	std    
  800a9a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a9c:	fc                   	cld    
  800a9d:	eb 21                	jmp    800ac0 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a9f:	f6 c1 03             	test   $0x3,%cl
  800aa2:	75 ef                	jne    800a93 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800aa4:	83 ef 04             	sub    $0x4,%edi
  800aa7:	8d 72 fc             	lea    -0x4(%edx),%esi
  800aaa:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800aad:	fd                   	std    
  800aae:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ab0:	eb ea                	jmp    800a9c <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab2:	89 f2                	mov    %esi,%edx
  800ab4:	09 c2                	or     %eax,%edx
  800ab6:	f6 c2 03             	test   $0x3,%dl
  800ab9:	74 09                	je     800ac4 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800abb:	89 c7                	mov    %eax,%edi
  800abd:	fc                   	cld    
  800abe:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ac0:	5e                   	pop    %esi
  800ac1:	5f                   	pop    %edi
  800ac2:	5d                   	pop    %ebp
  800ac3:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac4:	f6 c1 03             	test   $0x3,%cl
  800ac7:	75 f2                	jne    800abb <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ac9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800acc:	89 c7                	mov    %eax,%edi
  800ace:	fc                   	cld    
  800acf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ad1:	eb ed                	jmp    800ac0 <memmove+0x55>

00800ad3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ad3:	55                   	push   %ebp
  800ad4:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ad6:	ff 75 10             	pushl  0x10(%ebp)
  800ad9:	ff 75 0c             	pushl  0xc(%ebp)
  800adc:	ff 75 08             	pushl  0x8(%ebp)
  800adf:	e8 87 ff ff ff       	call   800a6b <memmove>
}
  800ae4:	c9                   	leave  
  800ae5:	c3                   	ret    

00800ae6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
  800ae9:	56                   	push   %esi
  800aea:	53                   	push   %ebx
  800aeb:	8b 45 08             	mov    0x8(%ebp),%eax
  800aee:	8b 55 0c             	mov    0xc(%ebp),%edx
  800af1:	89 c6                	mov    %eax,%esi
  800af3:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800af6:	39 f0                	cmp    %esi,%eax
  800af8:	74 1c                	je     800b16 <memcmp+0x30>
		if (*s1 != *s2)
  800afa:	0f b6 08             	movzbl (%eax),%ecx
  800afd:	0f b6 1a             	movzbl (%edx),%ebx
  800b00:	38 d9                	cmp    %bl,%cl
  800b02:	75 08                	jne    800b0c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b04:	83 c0 01             	add    $0x1,%eax
  800b07:	83 c2 01             	add    $0x1,%edx
  800b0a:	eb ea                	jmp    800af6 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b0c:	0f b6 c1             	movzbl %cl,%eax
  800b0f:	0f b6 db             	movzbl %bl,%ebx
  800b12:	29 d8                	sub    %ebx,%eax
  800b14:	eb 05                	jmp    800b1b <memcmp+0x35>
	}

	return 0;
  800b16:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b1b:	5b                   	pop    %ebx
  800b1c:	5e                   	pop    %esi
  800b1d:	5d                   	pop    %ebp
  800b1e:	c3                   	ret    

00800b1f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
  800b22:	8b 45 08             	mov    0x8(%ebp),%eax
  800b25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b28:	89 c2                	mov    %eax,%edx
  800b2a:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b2d:	39 d0                	cmp    %edx,%eax
  800b2f:	73 09                	jae    800b3a <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b31:	38 08                	cmp    %cl,(%eax)
  800b33:	74 05                	je     800b3a <memfind+0x1b>
	for (; s < ends; s++)
  800b35:	83 c0 01             	add    $0x1,%eax
  800b38:	eb f3                	jmp    800b2d <memfind+0xe>
			break;
	return (void *) s;
}
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	57                   	push   %edi
  800b40:	56                   	push   %esi
  800b41:	53                   	push   %ebx
  800b42:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b45:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b48:	eb 03                	jmp    800b4d <strtol+0x11>
		s++;
  800b4a:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b4d:	0f b6 01             	movzbl (%ecx),%eax
  800b50:	3c 20                	cmp    $0x20,%al
  800b52:	74 f6                	je     800b4a <strtol+0xe>
  800b54:	3c 09                	cmp    $0x9,%al
  800b56:	74 f2                	je     800b4a <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b58:	3c 2b                	cmp    $0x2b,%al
  800b5a:	74 2e                	je     800b8a <strtol+0x4e>
	int neg = 0;
  800b5c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b61:	3c 2d                	cmp    $0x2d,%al
  800b63:	74 2f                	je     800b94 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b65:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b6b:	75 05                	jne    800b72 <strtol+0x36>
  800b6d:	80 39 30             	cmpb   $0x30,(%ecx)
  800b70:	74 2c                	je     800b9e <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b72:	85 db                	test   %ebx,%ebx
  800b74:	75 0a                	jne    800b80 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b76:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800b7b:	80 39 30             	cmpb   $0x30,(%ecx)
  800b7e:	74 28                	je     800ba8 <strtol+0x6c>
		base = 10;
  800b80:	b8 00 00 00 00       	mov    $0x0,%eax
  800b85:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b88:	eb 50                	jmp    800bda <strtol+0x9e>
		s++;
  800b8a:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b8d:	bf 00 00 00 00       	mov    $0x0,%edi
  800b92:	eb d1                	jmp    800b65 <strtol+0x29>
		s++, neg = 1;
  800b94:	83 c1 01             	add    $0x1,%ecx
  800b97:	bf 01 00 00 00       	mov    $0x1,%edi
  800b9c:	eb c7                	jmp    800b65 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b9e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ba2:	74 0e                	je     800bb2 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800ba4:	85 db                	test   %ebx,%ebx
  800ba6:	75 d8                	jne    800b80 <strtol+0x44>
		s++, base = 8;
  800ba8:	83 c1 01             	add    $0x1,%ecx
  800bab:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bb0:	eb ce                	jmp    800b80 <strtol+0x44>
		s += 2, base = 16;
  800bb2:	83 c1 02             	add    $0x2,%ecx
  800bb5:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bba:	eb c4                	jmp    800b80 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800bbc:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bbf:	89 f3                	mov    %esi,%ebx
  800bc1:	80 fb 19             	cmp    $0x19,%bl
  800bc4:	77 29                	ja     800bef <strtol+0xb3>
			dig = *s - 'a' + 10;
  800bc6:	0f be d2             	movsbl %dl,%edx
  800bc9:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bcc:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bcf:	7d 30                	jge    800c01 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800bd1:	83 c1 01             	add    $0x1,%ecx
  800bd4:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bd8:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800bda:	0f b6 11             	movzbl (%ecx),%edx
  800bdd:	8d 72 d0             	lea    -0x30(%edx),%esi
  800be0:	89 f3                	mov    %esi,%ebx
  800be2:	80 fb 09             	cmp    $0x9,%bl
  800be5:	77 d5                	ja     800bbc <strtol+0x80>
			dig = *s - '0';
  800be7:	0f be d2             	movsbl %dl,%edx
  800bea:	83 ea 30             	sub    $0x30,%edx
  800bed:	eb dd                	jmp    800bcc <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800bef:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bf2:	89 f3                	mov    %esi,%ebx
  800bf4:	80 fb 19             	cmp    $0x19,%bl
  800bf7:	77 08                	ja     800c01 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800bf9:	0f be d2             	movsbl %dl,%edx
  800bfc:	83 ea 37             	sub    $0x37,%edx
  800bff:	eb cb                	jmp    800bcc <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c01:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c05:	74 05                	je     800c0c <strtol+0xd0>
		*endptr = (char *) s;
  800c07:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c0a:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c0c:	89 c2                	mov    %eax,%edx
  800c0e:	f7 da                	neg    %edx
  800c10:	85 ff                	test   %edi,%edi
  800c12:	0f 45 c2             	cmovne %edx,%eax
}
  800c15:	5b                   	pop    %ebx
  800c16:	5e                   	pop    %esi
  800c17:	5f                   	pop    %edi
  800c18:	5d                   	pop    %ebp
  800c19:	c3                   	ret    

00800c1a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c1a:	55                   	push   %ebp
  800c1b:	89 e5                	mov    %esp,%ebp
  800c1d:	57                   	push   %edi
  800c1e:	56                   	push   %esi
  800c1f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c20:	b8 00 00 00 00       	mov    $0x0,%eax
  800c25:	8b 55 08             	mov    0x8(%ebp),%edx
  800c28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2b:	89 c3                	mov    %eax,%ebx
  800c2d:	89 c7                	mov    %eax,%edi
  800c2f:	89 c6                	mov    %eax,%esi
  800c31:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c33:	5b                   	pop    %ebx
  800c34:	5e                   	pop    %esi
  800c35:	5f                   	pop    %edi
  800c36:	5d                   	pop    %ebp
  800c37:	c3                   	ret    

00800c38 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c38:	55                   	push   %ebp
  800c39:	89 e5                	mov    %esp,%ebp
  800c3b:	57                   	push   %edi
  800c3c:	56                   	push   %esi
  800c3d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c3e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c43:	b8 01 00 00 00       	mov    $0x1,%eax
  800c48:	89 d1                	mov    %edx,%ecx
  800c4a:	89 d3                	mov    %edx,%ebx
  800c4c:	89 d7                	mov    %edx,%edi
  800c4e:	89 d6                	mov    %edx,%esi
  800c50:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c52:	5b                   	pop    %ebx
  800c53:	5e                   	pop    %esi
  800c54:	5f                   	pop    %edi
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    

00800c57 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
  800c5a:	57                   	push   %edi
  800c5b:	56                   	push   %esi
  800c5c:	53                   	push   %ebx
  800c5d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c60:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c65:	8b 55 08             	mov    0x8(%ebp),%edx
  800c68:	b8 03 00 00 00       	mov    $0x3,%eax
  800c6d:	89 cb                	mov    %ecx,%ebx
  800c6f:	89 cf                	mov    %ecx,%edi
  800c71:	89 ce                	mov    %ecx,%esi
  800c73:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c75:	85 c0                	test   %eax,%eax
  800c77:	7f 08                	jg     800c81 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c79:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7c:	5b                   	pop    %ebx
  800c7d:	5e                   	pop    %esi
  800c7e:	5f                   	pop    %edi
  800c7f:	5d                   	pop    %ebp
  800c80:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c81:	83 ec 0c             	sub    $0xc,%esp
  800c84:	50                   	push   %eax
  800c85:	6a 03                	push   $0x3
  800c87:	68 9f 23 80 00       	push   $0x80239f
  800c8c:	6a 23                	push   $0x23
  800c8e:	68 bc 23 80 00       	push   $0x8023bc
  800c93:	e8 4b f5 ff ff       	call   8001e3 <_panic>

00800c98 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c98:	55                   	push   %ebp
  800c99:	89 e5                	mov    %esp,%ebp
  800c9b:	57                   	push   %edi
  800c9c:	56                   	push   %esi
  800c9d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c9e:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca3:	b8 02 00 00 00       	mov    $0x2,%eax
  800ca8:	89 d1                	mov    %edx,%ecx
  800caa:	89 d3                	mov    %edx,%ebx
  800cac:	89 d7                	mov    %edx,%edi
  800cae:	89 d6                	mov    %edx,%esi
  800cb0:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cb2:	5b                   	pop    %ebx
  800cb3:	5e                   	pop    %esi
  800cb4:	5f                   	pop    %edi
  800cb5:	5d                   	pop    %ebp
  800cb6:	c3                   	ret    

00800cb7 <sys_yield>:

void
sys_yield(void)
{
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
  800cba:	57                   	push   %edi
  800cbb:	56                   	push   %esi
  800cbc:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cbd:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc2:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cc7:	89 d1                	mov    %edx,%ecx
  800cc9:	89 d3                	mov    %edx,%ebx
  800ccb:	89 d7                	mov    %edx,%edi
  800ccd:	89 d6                	mov    %edx,%esi
  800ccf:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cd1:	5b                   	pop    %ebx
  800cd2:	5e                   	pop    %esi
  800cd3:	5f                   	pop    %edi
  800cd4:	5d                   	pop    %ebp
  800cd5:	c3                   	ret    

00800cd6 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cd6:	55                   	push   %ebp
  800cd7:	89 e5                	mov    %esp,%ebp
  800cd9:	57                   	push   %edi
  800cda:	56                   	push   %esi
  800cdb:	53                   	push   %ebx
  800cdc:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cdf:	be 00 00 00 00       	mov    $0x0,%esi
  800ce4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cea:	b8 04 00 00 00       	mov    $0x4,%eax
  800cef:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf2:	89 f7                	mov    %esi,%edi
  800cf4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cf6:	85 c0                	test   %eax,%eax
  800cf8:	7f 08                	jg     800d02 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cfa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfd:	5b                   	pop    %ebx
  800cfe:	5e                   	pop    %esi
  800cff:	5f                   	pop    %edi
  800d00:	5d                   	pop    %ebp
  800d01:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d02:	83 ec 0c             	sub    $0xc,%esp
  800d05:	50                   	push   %eax
  800d06:	6a 04                	push   $0x4
  800d08:	68 9f 23 80 00       	push   $0x80239f
  800d0d:	6a 23                	push   $0x23
  800d0f:	68 bc 23 80 00       	push   $0x8023bc
  800d14:	e8 ca f4 ff ff       	call   8001e3 <_panic>

00800d19 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d19:	55                   	push   %ebp
  800d1a:	89 e5                	mov    %esp,%ebp
  800d1c:	57                   	push   %edi
  800d1d:	56                   	push   %esi
  800d1e:	53                   	push   %ebx
  800d1f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d22:	8b 55 08             	mov    0x8(%ebp),%edx
  800d25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d28:	b8 05 00 00 00       	mov    $0x5,%eax
  800d2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d30:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d33:	8b 75 18             	mov    0x18(%ebp),%esi
  800d36:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d38:	85 c0                	test   %eax,%eax
  800d3a:	7f 08                	jg     800d44 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3f:	5b                   	pop    %ebx
  800d40:	5e                   	pop    %esi
  800d41:	5f                   	pop    %edi
  800d42:	5d                   	pop    %ebp
  800d43:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d44:	83 ec 0c             	sub    $0xc,%esp
  800d47:	50                   	push   %eax
  800d48:	6a 05                	push   $0x5
  800d4a:	68 9f 23 80 00       	push   $0x80239f
  800d4f:	6a 23                	push   $0x23
  800d51:	68 bc 23 80 00       	push   $0x8023bc
  800d56:	e8 88 f4 ff ff       	call   8001e3 <_panic>

00800d5b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d5b:	55                   	push   %ebp
  800d5c:	89 e5                	mov    %esp,%ebp
  800d5e:	57                   	push   %edi
  800d5f:	56                   	push   %esi
  800d60:	53                   	push   %ebx
  800d61:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d64:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d69:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6f:	b8 06 00 00 00       	mov    $0x6,%eax
  800d74:	89 df                	mov    %ebx,%edi
  800d76:	89 de                	mov    %ebx,%esi
  800d78:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d7a:	85 c0                	test   %eax,%eax
  800d7c:	7f 08                	jg     800d86 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d81:	5b                   	pop    %ebx
  800d82:	5e                   	pop    %esi
  800d83:	5f                   	pop    %edi
  800d84:	5d                   	pop    %ebp
  800d85:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d86:	83 ec 0c             	sub    $0xc,%esp
  800d89:	50                   	push   %eax
  800d8a:	6a 06                	push   $0x6
  800d8c:	68 9f 23 80 00       	push   $0x80239f
  800d91:	6a 23                	push   $0x23
  800d93:	68 bc 23 80 00       	push   $0x8023bc
  800d98:	e8 46 f4 ff ff       	call   8001e3 <_panic>

00800d9d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d9d:	55                   	push   %ebp
  800d9e:	89 e5                	mov    %esp,%ebp
  800da0:	57                   	push   %edi
  800da1:	56                   	push   %esi
  800da2:	53                   	push   %ebx
  800da3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800da6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dab:	8b 55 08             	mov    0x8(%ebp),%edx
  800dae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db1:	b8 08 00 00 00       	mov    $0x8,%eax
  800db6:	89 df                	mov    %ebx,%edi
  800db8:	89 de                	mov    %ebx,%esi
  800dba:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dbc:	85 c0                	test   %eax,%eax
  800dbe:	7f 08                	jg     800dc8 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc3:	5b                   	pop    %ebx
  800dc4:	5e                   	pop    %esi
  800dc5:	5f                   	pop    %edi
  800dc6:	5d                   	pop    %ebp
  800dc7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc8:	83 ec 0c             	sub    $0xc,%esp
  800dcb:	50                   	push   %eax
  800dcc:	6a 08                	push   $0x8
  800dce:	68 9f 23 80 00       	push   $0x80239f
  800dd3:	6a 23                	push   $0x23
  800dd5:	68 bc 23 80 00       	push   $0x8023bc
  800dda:	e8 04 f4 ff ff       	call   8001e3 <_panic>

00800ddf <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ddf:	55                   	push   %ebp
  800de0:	89 e5                	mov    %esp,%ebp
  800de2:	57                   	push   %edi
  800de3:	56                   	push   %esi
  800de4:	53                   	push   %ebx
  800de5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800de8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ded:	8b 55 08             	mov    0x8(%ebp),%edx
  800df0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df3:	b8 09 00 00 00       	mov    $0x9,%eax
  800df8:	89 df                	mov    %ebx,%edi
  800dfa:	89 de                	mov    %ebx,%esi
  800dfc:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dfe:	85 c0                	test   %eax,%eax
  800e00:	7f 08                	jg     800e0a <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e05:	5b                   	pop    %ebx
  800e06:	5e                   	pop    %esi
  800e07:	5f                   	pop    %edi
  800e08:	5d                   	pop    %ebp
  800e09:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0a:	83 ec 0c             	sub    $0xc,%esp
  800e0d:	50                   	push   %eax
  800e0e:	6a 09                	push   $0x9
  800e10:	68 9f 23 80 00       	push   $0x80239f
  800e15:	6a 23                	push   $0x23
  800e17:	68 bc 23 80 00       	push   $0x8023bc
  800e1c:	e8 c2 f3 ff ff       	call   8001e3 <_panic>

00800e21 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e21:	55                   	push   %ebp
  800e22:	89 e5                	mov    %esp,%ebp
  800e24:	57                   	push   %edi
  800e25:	56                   	push   %esi
  800e26:	53                   	push   %ebx
  800e27:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e2a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e35:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e3a:	89 df                	mov    %ebx,%edi
  800e3c:	89 de                	mov    %ebx,%esi
  800e3e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e40:	85 c0                	test   %eax,%eax
  800e42:	7f 08                	jg     800e4c <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e47:	5b                   	pop    %ebx
  800e48:	5e                   	pop    %esi
  800e49:	5f                   	pop    %edi
  800e4a:	5d                   	pop    %ebp
  800e4b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e4c:	83 ec 0c             	sub    $0xc,%esp
  800e4f:	50                   	push   %eax
  800e50:	6a 0a                	push   $0xa
  800e52:	68 9f 23 80 00       	push   $0x80239f
  800e57:	6a 23                	push   $0x23
  800e59:	68 bc 23 80 00       	push   $0x8023bc
  800e5e:	e8 80 f3 ff ff       	call   8001e3 <_panic>

00800e63 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e63:	55                   	push   %ebp
  800e64:	89 e5                	mov    %esp,%ebp
  800e66:	57                   	push   %edi
  800e67:	56                   	push   %esi
  800e68:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e69:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e6f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e74:	be 00 00 00 00       	mov    $0x0,%esi
  800e79:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e7c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e7f:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e81:	5b                   	pop    %ebx
  800e82:	5e                   	pop    %esi
  800e83:	5f                   	pop    %edi
  800e84:	5d                   	pop    %ebp
  800e85:	c3                   	ret    

00800e86 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e86:	55                   	push   %ebp
  800e87:	89 e5                	mov    %esp,%ebp
  800e89:	57                   	push   %edi
  800e8a:	56                   	push   %esi
  800e8b:	53                   	push   %ebx
  800e8c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e8f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e94:	8b 55 08             	mov    0x8(%ebp),%edx
  800e97:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e9c:	89 cb                	mov    %ecx,%ebx
  800e9e:	89 cf                	mov    %ecx,%edi
  800ea0:	89 ce                	mov    %ecx,%esi
  800ea2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ea4:	85 c0                	test   %eax,%eax
  800ea6:	7f 08                	jg     800eb0 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ea8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eab:	5b                   	pop    %ebx
  800eac:	5e                   	pop    %esi
  800ead:	5f                   	pop    %edi
  800eae:	5d                   	pop    %ebp
  800eaf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb0:	83 ec 0c             	sub    $0xc,%esp
  800eb3:	50                   	push   %eax
  800eb4:	6a 0d                	push   $0xd
  800eb6:	68 9f 23 80 00       	push   $0x80239f
  800ebb:	6a 23                	push   $0x23
  800ebd:	68 bc 23 80 00       	push   $0x8023bc
  800ec2:	e8 1c f3 ff ff       	call   8001e3 <_panic>

00800ec7 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ec7:	55                   	push   %ebp
  800ec8:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800eca:	8b 45 08             	mov    0x8(%ebp),%eax
  800ecd:	05 00 00 00 30       	add    $0x30000000,%eax
  800ed2:	c1 e8 0c             	shr    $0xc,%eax
}
  800ed5:	5d                   	pop    %ebp
  800ed6:	c3                   	ret    

00800ed7 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ed7:	55                   	push   %ebp
  800ed8:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800eda:	8b 45 08             	mov    0x8(%ebp),%eax
  800edd:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800ee2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ee7:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800eec:	5d                   	pop    %ebp
  800eed:	c3                   	ret    

00800eee <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800eee:	55                   	push   %ebp
  800eef:	89 e5                	mov    %esp,%ebp
  800ef1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ef4:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ef9:	89 c2                	mov    %eax,%edx
  800efb:	c1 ea 16             	shr    $0x16,%edx
  800efe:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f05:	f6 c2 01             	test   $0x1,%dl
  800f08:	74 2a                	je     800f34 <fd_alloc+0x46>
  800f0a:	89 c2                	mov    %eax,%edx
  800f0c:	c1 ea 0c             	shr    $0xc,%edx
  800f0f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f16:	f6 c2 01             	test   $0x1,%dl
  800f19:	74 19                	je     800f34 <fd_alloc+0x46>
  800f1b:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800f20:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f25:	75 d2                	jne    800ef9 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f27:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f2d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800f32:	eb 07                	jmp    800f3b <fd_alloc+0x4d>
			*fd_store = fd;
  800f34:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f36:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f3b:	5d                   	pop    %ebp
  800f3c:	c3                   	ret    

00800f3d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f3d:	55                   	push   %ebp
  800f3e:	89 e5                	mov    %esp,%ebp
  800f40:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f43:	83 f8 1f             	cmp    $0x1f,%eax
  800f46:	77 36                	ja     800f7e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f48:	c1 e0 0c             	shl    $0xc,%eax
  800f4b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f50:	89 c2                	mov    %eax,%edx
  800f52:	c1 ea 16             	shr    $0x16,%edx
  800f55:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f5c:	f6 c2 01             	test   $0x1,%dl
  800f5f:	74 24                	je     800f85 <fd_lookup+0x48>
  800f61:	89 c2                	mov    %eax,%edx
  800f63:	c1 ea 0c             	shr    $0xc,%edx
  800f66:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f6d:	f6 c2 01             	test   $0x1,%dl
  800f70:	74 1a                	je     800f8c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f72:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f75:	89 02                	mov    %eax,(%edx)
	return 0;
  800f77:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f7c:	5d                   	pop    %ebp
  800f7d:	c3                   	ret    
		return -E_INVAL;
  800f7e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f83:	eb f7                	jmp    800f7c <fd_lookup+0x3f>
		return -E_INVAL;
  800f85:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f8a:	eb f0                	jmp    800f7c <fd_lookup+0x3f>
  800f8c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f91:	eb e9                	jmp    800f7c <fd_lookup+0x3f>

00800f93 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f93:	55                   	push   %ebp
  800f94:	89 e5                	mov    %esp,%ebp
  800f96:	83 ec 08             	sub    $0x8,%esp
  800f99:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f9c:	ba 4c 24 80 00       	mov    $0x80244c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800fa1:	b8 08 30 80 00       	mov    $0x803008,%eax
		if (devtab[i]->dev_id == dev_id) {
  800fa6:	39 08                	cmp    %ecx,(%eax)
  800fa8:	74 33                	je     800fdd <dev_lookup+0x4a>
  800faa:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800fad:	8b 02                	mov    (%edx),%eax
  800faf:	85 c0                	test   %eax,%eax
  800fb1:	75 f3                	jne    800fa6 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fb3:	a1 08 40 80 00       	mov    0x804008,%eax
  800fb8:	8b 40 48             	mov    0x48(%eax),%eax
  800fbb:	83 ec 04             	sub    $0x4,%esp
  800fbe:	51                   	push   %ecx
  800fbf:	50                   	push   %eax
  800fc0:	68 cc 23 80 00       	push   $0x8023cc
  800fc5:	e8 f4 f2 ff ff       	call   8002be <cprintf>
	*dev = 0;
  800fca:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fcd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800fd3:	83 c4 10             	add    $0x10,%esp
  800fd6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fdb:	c9                   	leave  
  800fdc:	c3                   	ret    
			*dev = devtab[i];
  800fdd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe0:	89 01                	mov    %eax,(%ecx)
			return 0;
  800fe2:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe7:	eb f2                	jmp    800fdb <dev_lookup+0x48>

00800fe9 <fd_close>:
{
  800fe9:	55                   	push   %ebp
  800fea:	89 e5                	mov    %esp,%ebp
  800fec:	57                   	push   %edi
  800fed:	56                   	push   %esi
  800fee:	53                   	push   %ebx
  800fef:	83 ec 1c             	sub    $0x1c,%esp
  800ff2:	8b 75 08             	mov    0x8(%ebp),%esi
  800ff5:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ff8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ffb:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ffc:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801002:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801005:	50                   	push   %eax
  801006:	e8 32 ff ff ff       	call   800f3d <fd_lookup>
  80100b:	89 c3                	mov    %eax,%ebx
  80100d:	83 c4 08             	add    $0x8,%esp
  801010:	85 c0                	test   %eax,%eax
  801012:	78 05                	js     801019 <fd_close+0x30>
	    || fd != fd2)
  801014:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801017:	74 16                	je     80102f <fd_close+0x46>
		return (must_exist ? r : 0);
  801019:	89 f8                	mov    %edi,%eax
  80101b:	84 c0                	test   %al,%al
  80101d:	b8 00 00 00 00       	mov    $0x0,%eax
  801022:	0f 44 d8             	cmove  %eax,%ebx
}
  801025:	89 d8                	mov    %ebx,%eax
  801027:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80102a:	5b                   	pop    %ebx
  80102b:	5e                   	pop    %esi
  80102c:	5f                   	pop    %edi
  80102d:	5d                   	pop    %ebp
  80102e:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80102f:	83 ec 08             	sub    $0x8,%esp
  801032:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801035:	50                   	push   %eax
  801036:	ff 36                	pushl  (%esi)
  801038:	e8 56 ff ff ff       	call   800f93 <dev_lookup>
  80103d:	89 c3                	mov    %eax,%ebx
  80103f:	83 c4 10             	add    $0x10,%esp
  801042:	85 c0                	test   %eax,%eax
  801044:	78 15                	js     80105b <fd_close+0x72>
		if (dev->dev_close)
  801046:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801049:	8b 40 10             	mov    0x10(%eax),%eax
  80104c:	85 c0                	test   %eax,%eax
  80104e:	74 1b                	je     80106b <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  801050:	83 ec 0c             	sub    $0xc,%esp
  801053:	56                   	push   %esi
  801054:	ff d0                	call   *%eax
  801056:	89 c3                	mov    %eax,%ebx
  801058:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80105b:	83 ec 08             	sub    $0x8,%esp
  80105e:	56                   	push   %esi
  80105f:	6a 00                	push   $0x0
  801061:	e8 f5 fc ff ff       	call   800d5b <sys_page_unmap>
	return r;
  801066:	83 c4 10             	add    $0x10,%esp
  801069:	eb ba                	jmp    801025 <fd_close+0x3c>
			r = 0;
  80106b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801070:	eb e9                	jmp    80105b <fd_close+0x72>

00801072 <close>:

int
close(int fdnum)
{
  801072:	55                   	push   %ebp
  801073:	89 e5                	mov    %esp,%ebp
  801075:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801078:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80107b:	50                   	push   %eax
  80107c:	ff 75 08             	pushl  0x8(%ebp)
  80107f:	e8 b9 fe ff ff       	call   800f3d <fd_lookup>
  801084:	83 c4 08             	add    $0x8,%esp
  801087:	85 c0                	test   %eax,%eax
  801089:	78 10                	js     80109b <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80108b:	83 ec 08             	sub    $0x8,%esp
  80108e:	6a 01                	push   $0x1
  801090:	ff 75 f4             	pushl  -0xc(%ebp)
  801093:	e8 51 ff ff ff       	call   800fe9 <fd_close>
  801098:	83 c4 10             	add    $0x10,%esp
}
  80109b:	c9                   	leave  
  80109c:	c3                   	ret    

0080109d <close_all>:

void
close_all(void)
{
  80109d:	55                   	push   %ebp
  80109e:	89 e5                	mov    %esp,%ebp
  8010a0:	53                   	push   %ebx
  8010a1:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010a4:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010a9:	83 ec 0c             	sub    $0xc,%esp
  8010ac:	53                   	push   %ebx
  8010ad:	e8 c0 ff ff ff       	call   801072 <close>
	for (i = 0; i < MAXFD; i++)
  8010b2:	83 c3 01             	add    $0x1,%ebx
  8010b5:	83 c4 10             	add    $0x10,%esp
  8010b8:	83 fb 20             	cmp    $0x20,%ebx
  8010bb:	75 ec                	jne    8010a9 <close_all+0xc>
}
  8010bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010c0:	c9                   	leave  
  8010c1:	c3                   	ret    

008010c2 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010c2:	55                   	push   %ebp
  8010c3:	89 e5                	mov    %esp,%ebp
  8010c5:	57                   	push   %edi
  8010c6:	56                   	push   %esi
  8010c7:	53                   	push   %ebx
  8010c8:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010cb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010ce:	50                   	push   %eax
  8010cf:	ff 75 08             	pushl  0x8(%ebp)
  8010d2:	e8 66 fe ff ff       	call   800f3d <fd_lookup>
  8010d7:	89 c3                	mov    %eax,%ebx
  8010d9:	83 c4 08             	add    $0x8,%esp
  8010dc:	85 c0                	test   %eax,%eax
  8010de:	0f 88 81 00 00 00    	js     801165 <dup+0xa3>
		return r;
	close(newfdnum);
  8010e4:	83 ec 0c             	sub    $0xc,%esp
  8010e7:	ff 75 0c             	pushl  0xc(%ebp)
  8010ea:	e8 83 ff ff ff       	call   801072 <close>

	newfd = INDEX2FD(newfdnum);
  8010ef:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010f2:	c1 e6 0c             	shl    $0xc,%esi
  8010f5:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8010fb:	83 c4 04             	add    $0x4,%esp
  8010fe:	ff 75 e4             	pushl  -0x1c(%ebp)
  801101:	e8 d1 fd ff ff       	call   800ed7 <fd2data>
  801106:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801108:	89 34 24             	mov    %esi,(%esp)
  80110b:	e8 c7 fd ff ff       	call   800ed7 <fd2data>
  801110:	83 c4 10             	add    $0x10,%esp
  801113:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801115:	89 d8                	mov    %ebx,%eax
  801117:	c1 e8 16             	shr    $0x16,%eax
  80111a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801121:	a8 01                	test   $0x1,%al
  801123:	74 11                	je     801136 <dup+0x74>
  801125:	89 d8                	mov    %ebx,%eax
  801127:	c1 e8 0c             	shr    $0xc,%eax
  80112a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801131:	f6 c2 01             	test   $0x1,%dl
  801134:	75 39                	jne    80116f <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801136:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801139:	89 d0                	mov    %edx,%eax
  80113b:	c1 e8 0c             	shr    $0xc,%eax
  80113e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801145:	83 ec 0c             	sub    $0xc,%esp
  801148:	25 07 0e 00 00       	and    $0xe07,%eax
  80114d:	50                   	push   %eax
  80114e:	56                   	push   %esi
  80114f:	6a 00                	push   $0x0
  801151:	52                   	push   %edx
  801152:	6a 00                	push   $0x0
  801154:	e8 c0 fb ff ff       	call   800d19 <sys_page_map>
  801159:	89 c3                	mov    %eax,%ebx
  80115b:	83 c4 20             	add    $0x20,%esp
  80115e:	85 c0                	test   %eax,%eax
  801160:	78 31                	js     801193 <dup+0xd1>
		goto err;

	return newfdnum;
  801162:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801165:	89 d8                	mov    %ebx,%eax
  801167:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80116a:	5b                   	pop    %ebx
  80116b:	5e                   	pop    %esi
  80116c:	5f                   	pop    %edi
  80116d:	5d                   	pop    %ebp
  80116e:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80116f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801176:	83 ec 0c             	sub    $0xc,%esp
  801179:	25 07 0e 00 00       	and    $0xe07,%eax
  80117e:	50                   	push   %eax
  80117f:	57                   	push   %edi
  801180:	6a 00                	push   $0x0
  801182:	53                   	push   %ebx
  801183:	6a 00                	push   $0x0
  801185:	e8 8f fb ff ff       	call   800d19 <sys_page_map>
  80118a:	89 c3                	mov    %eax,%ebx
  80118c:	83 c4 20             	add    $0x20,%esp
  80118f:	85 c0                	test   %eax,%eax
  801191:	79 a3                	jns    801136 <dup+0x74>
	sys_page_unmap(0, newfd);
  801193:	83 ec 08             	sub    $0x8,%esp
  801196:	56                   	push   %esi
  801197:	6a 00                	push   $0x0
  801199:	e8 bd fb ff ff       	call   800d5b <sys_page_unmap>
	sys_page_unmap(0, nva);
  80119e:	83 c4 08             	add    $0x8,%esp
  8011a1:	57                   	push   %edi
  8011a2:	6a 00                	push   $0x0
  8011a4:	e8 b2 fb ff ff       	call   800d5b <sys_page_unmap>
	return r;
  8011a9:	83 c4 10             	add    $0x10,%esp
  8011ac:	eb b7                	jmp    801165 <dup+0xa3>

008011ae <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011ae:	55                   	push   %ebp
  8011af:	89 e5                	mov    %esp,%ebp
  8011b1:	53                   	push   %ebx
  8011b2:	83 ec 14             	sub    $0x14,%esp
  8011b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011b8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011bb:	50                   	push   %eax
  8011bc:	53                   	push   %ebx
  8011bd:	e8 7b fd ff ff       	call   800f3d <fd_lookup>
  8011c2:	83 c4 08             	add    $0x8,%esp
  8011c5:	85 c0                	test   %eax,%eax
  8011c7:	78 3f                	js     801208 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011c9:	83 ec 08             	sub    $0x8,%esp
  8011cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011cf:	50                   	push   %eax
  8011d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011d3:	ff 30                	pushl  (%eax)
  8011d5:	e8 b9 fd ff ff       	call   800f93 <dev_lookup>
  8011da:	83 c4 10             	add    $0x10,%esp
  8011dd:	85 c0                	test   %eax,%eax
  8011df:	78 27                	js     801208 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011e1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011e4:	8b 42 08             	mov    0x8(%edx),%eax
  8011e7:	83 e0 03             	and    $0x3,%eax
  8011ea:	83 f8 01             	cmp    $0x1,%eax
  8011ed:	74 1e                	je     80120d <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8011ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011f2:	8b 40 08             	mov    0x8(%eax),%eax
  8011f5:	85 c0                	test   %eax,%eax
  8011f7:	74 35                	je     80122e <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011f9:	83 ec 04             	sub    $0x4,%esp
  8011fc:	ff 75 10             	pushl  0x10(%ebp)
  8011ff:	ff 75 0c             	pushl  0xc(%ebp)
  801202:	52                   	push   %edx
  801203:	ff d0                	call   *%eax
  801205:	83 c4 10             	add    $0x10,%esp
}
  801208:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80120b:	c9                   	leave  
  80120c:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80120d:	a1 08 40 80 00       	mov    0x804008,%eax
  801212:	8b 40 48             	mov    0x48(%eax),%eax
  801215:	83 ec 04             	sub    $0x4,%esp
  801218:	53                   	push   %ebx
  801219:	50                   	push   %eax
  80121a:	68 10 24 80 00       	push   $0x802410
  80121f:	e8 9a f0 ff ff       	call   8002be <cprintf>
		return -E_INVAL;
  801224:	83 c4 10             	add    $0x10,%esp
  801227:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80122c:	eb da                	jmp    801208 <read+0x5a>
		return -E_NOT_SUPP;
  80122e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801233:	eb d3                	jmp    801208 <read+0x5a>

00801235 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801235:	55                   	push   %ebp
  801236:	89 e5                	mov    %esp,%ebp
  801238:	57                   	push   %edi
  801239:	56                   	push   %esi
  80123a:	53                   	push   %ebx
  80123b:	83 ec 0c             	sub    $0xc,%esp
  80123e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801241:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801244:	bb 00 00 00 00       	mov    $0x0,%ebx
  801249:	39 f3                	cmp    %esi,%ebx
  80124b:	73 25                	jae    801272 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80124d:	83 ec 04             	sub    $0x4,%esp
  801250:	89 f0                	mov    %esi,%eax
  801252:	29 d8                	sub    %ebx,%eax
  801254:	50                   	push   %eax
  801255:	89 d8                	mov    %ebx,%eax
  801257:	03 45 0c             	add    0xc(%ebp),%eax
  80125a:	50                   	push   %eax
  80125b:	57                   	push   %edi
  80125c:	e8 4d ff ff ff       	call   8011ae <read>
		if (m < 0)
  801261:	83 c4 10             	add    $0x10,%esp
  801264:	85 c0                	test   %eax,%eax
  801266:	78 08                	js     801270 <readn+0x3b>
			return m;
		if (m == 0)
  801268:	85 c0                	test   %eax,%eax
  80126a:	74 06                	je     801272 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  80126c:	01 c3                	add    %eax,%ebx
  80126e:	eb d9                	jmp    801249 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801270:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801272:	89 d8                	mov    %ebx,%eax
  801274:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801277:	5b                   	pop    %ebx
  801278:	5e                   	pop    %esi
  801279:	5f                   	pop    %edi
  80127a:	5d                   	pop    %ebp
  80127b:	c3                   	ret    

0080127c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80127c:	55                   	push   %ebp
  80127d:	89 e5                	mov    %esp,%ebp
  80127f:	53                   	push   %ebx
  801280:	83 ec 14             	sub    $0x14,%esp
  801283:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801286:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801289:	50                   	push   %eax
  80128a:	53                   	push   %ebx
  80128b:	e8 ad fc ff ff       	call   800f3d <fd_lookup>
  801290:	83 c4 08             	add    $0x8,%esp
  801293:	85 c0                	test   %eax,%eax
  801295:	78 3a                	js     8012d1 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801297:	83 ec 08             	sub    $0x8,%esp
  80129a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80129d:	50                   	push   %eax
  80129e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a1:	ff 30                	pushl  (%eax)
  8012a3:	e8 eb fc ff ff       	call   800f93 <dev_lookup>
  8012a8:	83 c4 10             	add    $0x10,%esp
  8012ab:	85 c0                	test   %eax,%eax
  8012ad:	78 22                	js     8012d1 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012b6:	74 1e                	je     8012d6 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012bb:	8b 52 0c             	mov    0xc(%edx),%edx
  8012be:	85 d2                	test   %edx,%edx
  8012c0:	74 35                	je     8012f7 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012c2:	83 ec 04             	sub    $0x4,%esp
  8012c5:	ff 75 10             	pushl  0x10(%ebp)
  8012c8:	ff 75 0c             	pushl  0xc(%ebp)
  8012cb:	50                   	push   %eax
  8012cc:	ff d2                	call   *%edx
  8012ce:	83 c4 10             	add    $0x10,%esp
}
  8012d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012d4:	c9                   	leave  
  8012d5:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012d6:	a1 08 40 80 00       	mov    0x804008,%eax
  8012db:	8b 40 48             	mov    0x48(%eax),%eax
  8012de:	83 ec 04             	sub    $0x4,%esp
  8012e1:	53                   	push   %ebx
  8012e2:	50                   	push   %eax
  8012e3:	68 2c 24 80 00       	push   $0x80242c
  8012e8:	e8 d1 ef ff ff       	call   8002be <cprintf>
		return -E_INVAL;
  8012ed:	83 c4 10             	add    $0x10,%esp
  8012f0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012f5:	eb da                	jmp    8012d1 <write+0x55>
		return -E_NOT_SUPP;
  8012f7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012fc:	eb d3                	jmp    8012d1 <write+0x55>

008012fe <seek>:

int
seek(int fdnum, off_t offset)
{
  8012fe:	55                   	push   %ebp
  8012ff:	89 e5                	mov    %esp,%ebp
  801301:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801304:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801307:	50                   	push   %eax
  801308:	ff 75 08             	pushl  0x8(%ebp)
  80130b:	e8 2d fc ff ff       	call   800f3d <fd_lookup>
  801310:	83 c4 08             	add    $0x8,%esp
  801313:	85 c0                	test   %eax,%eax
  801315:	78 0e                	js     801325 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801317:	8b 55 0c             	mov    0xc(%ebp),%edx
  80131a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80131d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801320:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801325:	c9                   	leave  
  801326:	c3                   	ret    

00801327 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801327:	55                   	push   %ebp
  801328:	89 e5                	mov    %esp,%ebp
  80132a:	53                   	push   %ebx
  80132b:	83 ec 14             	sub    $0x14,%esp
  80132e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801331:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801334:	50                   	push   %eax
  801335:	53                   	push   %ebx
  801336:	e8 02 fc ff ff       	call   800f3d <fd_lookup>
  80133b:	83 c4 08             	add    $0x8,%esp
  80133e:	85 c0                	test   %eax,%eax
  801340:	78 37                	js     801379 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801342:	83 ec 08             	sub    $0x8,%esp
  801345:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801348:	50                   	push   %eax
  801349:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80134c:	ff 30                	pushl  (%eax)
  80134e:	e8 40 fc ff ff       	call   800f93 <dev_lookup>
  801353:	83 c4 10             	add    $0x10,%esp
  801356:	85 c0                	test   %eax,%eax
  801358:	78 1f                	js     801379 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80135a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80135d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801361:	74 1b                	je     80137e <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801363:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801366:	8b 52 18             	mov    0x18(%edx),%edx
  801369:	85 d2                	test   %edx,%edx
  80136b:	74 32                	je     80139f <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80136d:	83 ec 08             	sub    $0x8,%esp
  801370:	ff 75 0c             	pushl  0xc(%ebp)
  801373:	50                   	push   %eax
  801374:	ff d2                	call   *%edx
  801376:	83 c4 10             	add    $0x10,%esp
}
  801379:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80137c:	c9                   	leave  
  80137d:	c3                   	ret    
			thisenv->env_id, fdnum);
  80137e:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801383:	8b 40 48             	mov    0x48(%eax),%eax
  801386:	83 ec 04             	sub    $0x4,%esp
  801389:	53                   	push   %ebx
  80138a:	50                   	push   %eax
  80138b:	68 ec 23 80 00       	push   $0x8023ec
  801390:	e8 29 ef ff ff       	call   8002be <cprintf>
		return -E_INVAL;
  801395:	83 c4 10             	add    $0x10,%esp
  801398:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80139d:	eb da                	jmp    801379 <ftruncate+0x52>
		return -E_NOT_SUPP;
  80139f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013a4:	eb d3                	jmp    801379 <ftruncate+0x52>

008013a6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013a6:	55                   	push   %ebp
  8013a7:	89 e5                	mov    %esp,%ebp
  8013a9:	53                   	push   %ebx
  8013aa:	83 ec 14             	sub    $0x14,%esp
  8013ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013b3:	50                   	push   %eax
  8013b4:	ff 75 08             	pushl  0x8(%ebp)
  8013b7:	e8 81 fb ff ff       	call   800f3d <fd_lookup>
  8013bc:	83 c4 08             	add    $0x8,%esp
  8013bf:	85 c0                	test   %eax,%eax
  8013c1:	78 4b                	js     80140e <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013c3:	83 ec 08             	sub    $0x8,%esp
  8013c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c9:	50                   	push   %eax
  8013ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013cd:	ff 30                	pushl  (%eax)
  8013cf:	e8 bf fb ff ff       	call   800f93 <dev_lookup>
  8013d4:	83 c4 10             	add    $0x10,%esp
  8013d7:	85 c0                	test   %eax,%eax
  8013d9:	78 33                	js     80140e <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  8013db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013de:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013e2:	74 2f                	je     801413 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013e4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013e7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013ee:	00 00 00 
	stat->st_isdir = 0;
  8013f1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013f8:	00 00 00 
	stat->st_dev = dev;
  8013fb:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801401:	83 ec 08             	sub    $0x8,%esp
  801404:	53                   	push   %ebx
  801405:	ff 75 f0             	pushl  -0x10(%ebp)
  801408:	ff 50 14             	call   *0x14(%eax)
  80140b:	83 c4 10             	add    $0x10,%esp
}
  80140e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801411:	c9                   	leave  
  801412:	c3                   	ret    
		return -E_NOT_SUPP;
  801413:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801418:	eb f4                	jmp    80140e <fstat+0x68>

0080141a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80141a:	55                   	push   %ebp
  80141b:	89 e5                	mov    %esp,%ebp
  80141d:	56                   	push   %esi
  80141e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80141f:	83 ec 08             	sub    $0x8,%esp
  801422:	6a 00                	push   $0x0
  801424:	ff 75 08             	pushl  0x8(%ebp)
  801427:	e8 e7 01 00 00       	call   801613 <open>
  80142c:	89 c3                	mov    %eax,%ebx
  80142e:	83 c4 10             	add    $0x10,%esp
  801431:	85 c0                	test   %eax,%eax
  801433:	78 1b                	js     801450 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801435:	83 ec 08             	sub    $0x8,%esp
  801438:	ff 75 0c             	pushl  0xc(%ebp)
  80143b:	50                   	push   %eax
  80143c:	e8 65 ff ff ff       	call   8013a6 <fstat>
  801441:	89 c6                	mov    %eax,%esi
	close(fd);
  801443:	89 1c 24             	mov    %ebx,(%esp)
  801446:	e8 27 fc ff ff       	call   801072 <close>
	return r;
  80144b:	83 c4 10             	add    $0x10,%esp
  80144e:	89 f3                	mov    %esi,%ebx
}
  801450:	89 d8                	mov    %ebx,%eax
  801452:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801455:	5b                   	pop    %ebx
  801456:	5e                   	pop    %esi
  801457:	5d                   	pop    %ebp
  801458:	c3                   	ret    

00801459 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801459:	55                   	push   %ebp
  80145a:	89 e5                	mov    %esp,%ebp
  80145c:	56                   	push   %esi
  80145d:	53                   	push   %ebx
  80145e:	89 c6                	mov    %eax,%esi
  801460:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801462:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801469:	74 27                	je     801492 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80146b:	6a 07                	push   $0x7
  80146d:	68 00 50 80 00       	push   $0x805000
  801472:	56                   	push   %esi
  801473:	ff 35 04 40 80 00    	pushl  0x804004
  801479:	e8 8e 08 00 00       	call   801d0c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80147e:	83 c4 0c             	add    $0xc,%esp
  801481:	6a 00                	push   $0x0
  801483:	53                   	push   %ebx
  801484:	6a 00                	push   $0x0
  801486:	e8 0c 08 00 00       	call   801c97 <ipc_recv>
}
  80148b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80148e:	5b                   	pop    %ebx
  80148f:	5e                   	pop    %esi
  801490:	5d                   	pop    %ebp
  801491:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801492:	83 ec 0c             	sub    $0xc,%esp
  801495:	6a 01                	push   $0x1
  801497:	e8 c6 08 00 00       	call   801d62 <ipc_find_env>
  80149c:	a3 04 40 80 00       	mov    %eax,0x804004
  8014a1:	83 c4 10             	add    $0x10,%esp
  8014a4:	eb c5                	jmp    80146b <fsipc+0x12>

008014a6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8014a6:	55                   	push   %ebp
  8014a7:	89 e5                	mov    %esp,%ebp
  8014a9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8014af:	8b 40 0c             	mov    0xc(%eax),%eax
  8014b2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8014b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014ba:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c4:	b8 02 00 00 00       	mov    $0x2,%eax
  8014c9:	e8 8b ff ff ff       	call   801459 <fsipc>
}
  8014ce:	c9                   	leave  
  8014cf:	c3                   	ret    

008014d0 <devfile_flush>:
{
  8014d0:	55                   	push   %ebp
  8014d1:	89 e5                	mov    %esp,%ebp
  8014d3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d9:	8b 40 0c             	mov    0xc(%eax),%eax
  8014dc:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e6:	b8 06 00 00 00       	mov    $0x6,%eax
  8014eb:	e8 69 ff ff ff       	call   801459 <fsipc>
}
  8014f0:	c9                   	leave  
  8014f1:	c3                   	ret    

008014f2 <devfile_stat>:
{
  8014f2:	55                   	push   %ebp
  8014f3:	89 e5                	mov    %esp,%ebp
  8014f5:	53                   	push   %ebx
  8014f6:	83 ec 04             	sub    $0x4,%esp
  8014f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ff:	8b 40 0c             	mov    0xc(%eax),%eax
  801502:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801507:	ba 00 00 00 00       	mov    $0x0,%edx
  80150c:	b8 05 00 00 00       	mov    $0x5,%eax
  801511:	e8 43 ff ff ff       	call   801459 <fsipc>
  801516:	85 c0                	test   %eax,%eax
  801518:	78 2c                	js     801546 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80151a:	83 ec 08             	sub    $0x8,%esp
  80151d:	68 00 50 80 00       	push   $0x805000
  801522:	53                   	push   %ebx
  801523:	e8 b5 f3 ff ff       	call   8008dd <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801528:	a1 80 50 80 00       	mov    0x805080,%eax
  80152d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801533:	a1 84 50 80 00       	mov    0x805084,%eax
  801538:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80153e:	83 c4 10             	add    $0x10,%esp
  801541:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801546:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801549:	c9                   	leave  
  80154a:	c3                   	ret    

0080154b <devfile_write>:
{
  80154b:	55                   	push   %ebp
  80154c:	89 e5                	mov    %esp,%ebp
  80154e:	83 ec 0c             	sub    $0xc,%esp
  801551:	8b 45 10             	mov    0x10(%ebp),%eax
  801554:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801559:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80155e:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801561:	8b 55 08             	mov    0x8(%ebp),%edx
  801564:	8b 52 0c             	mov    0xc(%edx),%edx
  801567:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80156d:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf,buf,n);
  801572:	50                   	push   %eax
  801573:	ff 75 0c             	pushl  0xc(%ebp)
  801576:	68 08 50 80 00       	push   $0x805008
  80157b:	e8 eb f4 ff ff       	call   800a6b <memmove>
	if((r = fsipc(FSREQ_WRITE,NULL))<0)
  801580:	ba 00 00 00 00       	mov    $0x0,%edx
  801585:	b8 04 00 00 00       	mov    $0x4,%eax
  80158a:	e8 ca fe ff ff       	call   801459 <fsipc>
}
  80158f:	c9                   	leave  
  801590:	c3                   	ret    

00801591 <devfile_read>:
{
  801591:	55                   	push   %ebp
  801592:	89 e5                	mov    %esp,%ebp
  801594:	56                   	push   %esi
  801595:	53                   	push   %ebx
  801596:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801599:	8b 45 08             	mov    0x8(%ebp),%eax
  80159c:	8b 40 0c             	mov    0xc(%eax),%eax
  80159f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8015a4:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8015af:	b8 03 00 00 00       	mov    $0x3,%eax
  8015b4:	e8 a0 fe ff ff       	call   801459 <fsipc>
  8015b9:	89 c3                	mov    %eax,%ebx
  8015bb:	85 c0                	test   %eax,%eax
  8015bd:	78 1f                	js     8015de <devfile_read+0x4d>
	assert(r <= n);
  8015bf:	39 f0                	cmp    %esi,%eax
  8015c1:	77 24                	ja     8015e7 <devfile_read+0x56>
	assert(r <= PGSIZE);
  8015c3:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015c8:	7f 33                	jg     8015fd <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015ca:	83 ec 04             	sub    $0x4,%esp
  8015cd:	50                   	push   %eax
  8015ce:	68 00 50 80 00       	push   $0x805000
  8015d3:	ff 75 0c             	pushl  0xc(%ebp)
  8015d6:	e8 90 f4 ff ff       	call   800a6b <memmove>
	return r;
  8015db:	83 c4 10             	add    $0x10,%esp
}
  8015de:	89 d8                	mov    %ebx,%eax
  8015e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015e3:	5b                   	pop    %ebx
  8015e4:	5e                   	pop    %esi
  8015e5:	5d                   	pop    %ebp
  8015e6:	c3                   	ret    
	assert(r <= n);
  8015e7:	68 5c 24 80 00       	push   $0x80245c
  8015ec:	68 63 24 80 00       	push   $0x802463
  8015f1:	6a 7c                	push   $0x7c
  8015f3:	68 78 24 80 00       	push   $0x802478
  8015f8:	e8 e6 eb ff ff       	call   8001e3 <_panic>
	assert(r <= PGSIZE);
  8015fd:	68 83 24 80 00       	push   $0x802483
  801602:	68 63 24 80 00       	push   $0x802463
  801607:	6a 7d                	push   $0x7d
  801609:	68 78 24 80 00       	push   $0x802478
  80160e:	e8 d0 eb ff ff       	call   8001e3 <_panic>

00801613 <open>:
{
  801613:	55                   	push   %ebp
  801614:	89 e5                	mov    %esp,%ebp
  801616:	56                   	push   %esi
  801617:	53                   	push   %ebx
  801618:	83 ec 1c             	sub    $0x1c,%esp
  80161b:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80161e:	56                   	push   %esi
  80161f:	e8 82 f2 ff ff       	call   8008a6 <strlen>
  801624:	83 c4 10             	add    $0x10,%esp
  801627:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80162c:	7f 6c                	jg     80169a <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  80162e:	83 ec 0c             	sub    $0xc,%esp
  801631:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801634:	50                   	push   %eax
  801635:	e8 b4 f8 ff ff       	call   800eee <fd_alloc>
  80163a:	89 c3                	mov    %eax,%ebx
  80163c:	83 c4 10             	add    $0x10,%esp
  80163f:	85 c0                	test   %eax,%eax
  801641:	78 3c                	js     80167f <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801643:	83 ec 08             	sub    $0x8,%esp
  801646:	56                   	push   %esi
  801647:	68 00 50 80 00       	push   $0x805000
  80164c:	e8 8c f2 ff ff       	call   8008dd <strcpy>
	fsipcbuf.open.req_omode = mode;
  801651:	8b 45 0c             	mov    0xc(%ebp),%eax
  801654:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801659:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80165c:	b8 01 00 00 00       	mov    $0x1,%eax
  801661:	e8 f3 fd ff ff       	call   801459 <fsipc>
  801666:	89 c3                	mov    %eax,%ebx
  801668:	83 c4 10             	add    $0x10,%esp
  80166b:	85 c0                	test   %eax,%eax
  80166d:	78 19                	js     801688 <open+0x75>
	return fd2num(fd);
  80166f:	83 ec 0c             	sub    $0xc,%esp
  801672:	ff 75 f4             	pushl  -0xc(%ebp)
  801675:	e8 4d f8 ff ff       	call   800ec7 <fd2num>
  80167a:	89 c3                	mov    %eax,%ebx
  80167c:	83 c4 10             	add    $0x10,%esp
}
  80167f:	89 d8                	mov    %ebx,%eax
  801681:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801684:	5b                   	pop    %ebx
  801685:	5e                   	pop    %esi
  801686:	5d                   	pop    %ebp
  801687:	c3                   	ret    
		fd_close(fd, 0);
  801688:	83 ec 08             	sub    $0x8,%esp
  80168b:	6a 00                	push   $0x0
  80168d:	ff 75 f4             	pushl  -0xc(%ebp)
  801690:	e8 54 f9 ff ff       	call   800fe9 <fd_close>
		return r;
  801695:	83 c4 10             	add    $0x10,%esp
  801698:	eb e5                	jmp    80167f <open+0x6c>
		return -E_BAD_PATH;
  80169a:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80169f:	eb de                	jmp    80167f <open+0x6c>

008016a1 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8016a1:	55                   	push   %ebp
  8016a2:	89 e5                	mov    %esp,%ebp
  8016a4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ac:	b8 08 00 00 00       	mov    $0x8,%eax
  8016b1:	e8 a3 fd ff ff       	call   801459 <fsipc>
}
  8016b6:	c9                   	leave  
  8016b7:	c3                   	ret    

008016b8 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  8016b8:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8016bc:	7e 38                	jle    8016f6 <writebuf+0x3e>
{
  8016be:	55                   	push   %ebp
  8016bf:	89 e5                	mov    %esp,%ebp
  8016c1:	53                   	push   %ebx
  8016c2:	83 ec 08             	sub    $0x8,%esp
  8016c5:	89 c3                	mov    %eax,%ebx
		ssize_t result = write(b->fd, b->buf, b->idx);
  8016c7:	ff 70 04             	pushl  0x4(%eax)
  8016ca:	8d 40 10             	lea    0x10(%eax),%eax
  8016cd:	50                   	push   %eax
  8016ce:	ff 33                	pushl  (%ebx)
  8016d0:	e8 a7 fb ff ff       	call   80127c <write>
		if (result > 0)
  8016d5:	83 c4 10             	add    $0x10,%esp
  8016d8:	85 c0                	test   %eax,%eax
  8016da:	7e 03                	jle    8016df <writebuf+0x27>
			b->result += result;
  8016dc:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8016df:	39 43 04             	cmp    %eax,0x4(%ebx)
  8016e2:	74 0d                	je     8016f1 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  8016e4:	85 c0                	test   %eax,%eax
  8016e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8016eb:	0f 4f c2             	cmovg  %edx,%eax
  8016ee:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8016f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f4:	c9                   	leave  
  8016f5:	c3                   	ret    
  8016f6:	f3 c3                	repz ret 

008016f8 <putch>:

static void
putch(int ch, void *thunk)
{
  8016f8:	55                   	push   %ebp
  8016f9:	89 e5                	mov    %esp,%ebp
  8016fb:	53                   	push   %ebx
  8016fc:	83 ec 04             	sub    $0x4,%esp
  8016ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801702:	8b 53 04             	mov    0x4(%ebx),%edx
  801705:	8d 42 01             	lea    0x1(%edx),%eax
  801708:	89 43 04             	mov    %eax,0x4(%ebx)
  80170b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80170e:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801712:	3d 00 01 00 00       	cmp    $0x100,%eax
  801717:	74 06                	je     80171f <putch+0x27>
		writebuf(b);
		b->idx = 0;
	}
}
  801719:	83 c4 04             	add    $0x4,%esp
  80171c:	5b                   	pop    %ebx
  80171d:	5d                   	pop    %ebp
  80171e:	c3                   	ret    
		writebuf(b);
  80171f:	89 d8                	mov    %ebx,%eax
  801721:	e8 92 ff ff ff       	call   8016b8 <writebuf>
		b->idx = 0;
  801726:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
}
  80172d:	eb ea                	jmp    801719 <putch+0x21>

0080172f <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  80172f:	55                   	push   %ebp
  801730:	89 e5                	mov    %esp,%ebp
  801732:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801738:	8b 45 08             	mov    0x8(%ebp),%eax
  80173b:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801741:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801748:	00 00 00 
	b.result = 0;
  80174b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801752:	00 00 00 
	b.error = 1;
  801755:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  80175c:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  80175f:	ff 75 10             	pushl  0x10(%ebp)
  801762:	ff 75 0c             	pushl  0xc(%ebp)
  801765:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80176b:	50                   	push   %eax
  80176c:	68 f8 16 80 00       	push   $0x8016f8
  801771:	e8 45 ec ff ff       	call   8003bb <vprintfmt>
	if (b.idx > 0)
  801776:	83 c4 10             	add    $0x10,%esp
  801779:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801780:	7f 11                	jg     801793 <vfprintf+0x64>
		writebuf(&b);

	return (b.result ? b.result : b.error);
  801782:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801788:	85 c0                	test   %eax,%eax
  80178a:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801791:	c9                   	leave  
  801792:	c3                   	ret    
		writebuf(&b);
  801793:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801799:	e8 1a ff ff ff       	call   8016b8 <writebuf>
  80179e:	eb e2                	jmp    801782 <vfprintf+0x53>

008017a0 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8017a0:	55                   	push   %ebp
  8017a1:	89 e5                	mov    %esp,%ebp
  8017a3:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8017a6:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8017a9:	50                   	push   %eax
  8017aa:	ff 75 0c             	pushl  0xc(%ebp)
  8017ad:	ff 75 08             	pushl  0x8(%ebp)
  8017b0:	e8 7a ff ff ff       	call   80172f <vfprintf>
	va_end(ap);

	return cnt;
}
  8017b5:	c9                   	leave  
  8017b6:	c3                   	ret    

008017b7 <printf>:

int
printf(const char *fmt, ...)
{
  8017b7:	55                   	push   %ebp
  8017b8:	89 e5                	mov    %esp,%ebp
  8017ba:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8017bd:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8017c0:	50                   	push   %eax
  8017c1:	ff 75 08             	pushl  0x8(%ebp)
  8017c4:	6a 01                	push   $0x1
  8017c6:	e8 64 ff ff ff       	call   80172f <vfprintf>
	va_end(ap);

	return cnt;
}
  8017cb:	c9                   	leave  
  8017cc:	c3                   	ret    

008017cd <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8017cd:	55                   	push   %ebp
  8017ce:	89 e5                	mov    %esp,%ebp
  8017d0:	56                   	push   %esi
  8017d1:	53                   	push   %ebx
  8017d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8017d5:	83 ec 0c             	sub    $0xc,%esp
  8017d8:	ff 75 08             	pushl  0x8(%ebp)
  8017db:	e8 f7 f6 ff ff       	call   800ed7 <fd2data>
  8017e0:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8017e2:	83 c4 08             	add    $0x8,%esp
  8017e5:	68 8f 24 80 00       	push   $0x80248f
  8017ea:	53                   	push   %ebx
  8017eb:	e8 ed f0 ff ff       	call   8008dd <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8017f0:	8b 46 04             	mov    0x4(%esi),%eax
  8017f3:	2b 06                	sub    (%esi),%eax
  8017f5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8017fb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801802:	00 00 00 
	stat->st_dev = &devpipe;
  801805:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  80180c:	30 80 00 
	return 0;
}
  80180f:	b8 00 00 00 00       	mov    $0x0,%eax
  801814:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801817:	5b                   	pop    %ebx
  801818:	5e                   	pop    %esi
  801819:	5d                   	pop    %ebp
  80181a:	c3                   	ret    

0080181b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80181b:	55                   	push   %ebp
  80181c:	89 e5                	mov    %esp,%ebp
  80181e:	53                   	push   %ebx
  80181f:	83 ec 0c             	sub    $0xc,%esp
  801822:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801825:	53                   	push   %ebx
  801826:	6a 00                	push   $0x0
  801828:	e8 2e f5 ff ff       	call   800d5b <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80182d:	89 1c 24             	mov    %ebx,(%esp)
  801830:	e8 a2 f6 ff ff       	call   800ed7 <fd2data>
  801835:	83 c4 08             	add    $0x8,%esp
  801838:	50                   	push   %eax
  801839:	6a 00                	push   $0x0
  80183b:	e8 1b f5 ff ff       	call   800d5b <sys_page_unmap>
}
  801840:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801843:	c9                   	leave  
  801844:	c3                   	ret    

00801845 <_pipeisclosed>:
{
  801845:	55                   	push   %ebp
  801846:	89 e5                	mov    %esp,%ebp
  801848:	57                   	push   %edi
  801849:	56                   	push   %esi
  80184a:	53                   	push   %ebx
  80184b:	83 ec 1c             	sub    $0x1c,%esp
  80184e:	89 c7                	mov    %eax,%edi
  801850:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801852:	a1 08 40 80 00       	mov    0x804008,%eax
  801857:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80185a:	83 ec 0c             	sub    $0xc,%esp
  80185d:	57                   	push   %edi
  80185e:	e8 38 05 00 00       	call   801d9b <pageref>
  801863:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801866:	89 34 24             	mov    %esi,(%esp)
  801869:	e8 2d 05 00 00       	call   801d9b <pageref>
		nn = thisenv->env_runs;
  80186e:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801874:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801877:	83 c4 10             	add    $0x10,%esp
  80187a:	39 cb                	cmp    %ecx,%ebx
  80187c:	74 1b                	je     801899 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  80187e:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801881:	75 cf                	jne    801852 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801883:	8b 42 58             	mov    0x58(%edx),%eax
  801886:	6a 01                	push   $0x1
  801888:	50                   	push   %eax
  801889:	53                   	push   %ebx
  80188a:	68 96 24 80 00       	push   $0x802496
  80188f:	e8 2a ea ff ff       	call   8002be <cprintf>
  801894:	83 c4 10             	add    $0x10,%esp
  801897:	eb b9                	jmp    801852 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801899:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80189c:	0f 94 c0             	sete   %al
  80189f:	0f b6 c0             	movzbl %al,%eax
}
  8018a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018a5:	5b                   	pop    %ebx
  8018a6:	5e                   	pop    %esi
  8018a7:	5f                   	pop    %edi
  8018a8:	5d                   	pop    %ebp
  8018a9:	c3                   	ret    

008018aa <devpipe_write>:
{
  8018aa:	55                   	push   %ebp
  8018ab:	89 e5                	mov    %esp,%ebp
  8018ad:	57                   	push   %edi
  8018ae:	56                   	push   %esi
  8018af:	53                   	push   %ebx
  8018b0:	83 ec 28             	sub    $0x28,%esp
  8018b3:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8018b6:	56                   	push   %esi
  8018b7:	e8 1b f6 ff ff       	call   800ed7 <fd2data>
  8018bc:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8018be:	83 c4 10             	add    $0x10,%esp
  8018c1:	bf 00 00 00 00       	mov    $0x0,%edi
  8018c6:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8018c9:	74 4f                	je     80191a <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8018cb:	8b 43 04             	mov    0x4(%ebx),%eax
  8018ce:	8b 0b                	mov    (%ebx),%ecx
  8018d0:	8d 51 20             	lea    0x20(%ecx),%edx
  8018d3:	39 d0                	cmp    %edx,%eax
  8018d5:	72 14                	jb     8018eb <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  8018d7:	89 da                	mov    %ebx,%edx
  8018d9:	89 f0                	mov    %esi,%eax
  8018db:	e8 65 ff ff ff       	call   801845 <_pipeisclosed>
  8018e0:	85 c0                	test   %eax,%eax
  8018e2:	75 3a                	jne    80191e <devpipe_write+0x74>
			sys_yield();
  8018e4:	e8 ce f3 ff ff       	call   800cb7 <sys_yield>
  8018e9:	eb e0                	jmp    8018cb <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8018eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018ee:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8018f2:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8018f5:	89 c2                	mov    %eax,%edx
  8018f7:	c1 fa 1f             	sar    $0x1f,%edx
  8018fa:	89 d1                	mov    %edx,%ecx
  8018fc:	c1 e9 1b             	shr    $0x1b,%ecx
  8018ff:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801902:	83 e2 1f             	and    $0x1f,%edx
  801905:	29 ca                	sub    %ecx,%edx
  801907:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80190b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80190f:	83 c0 01             	add    $0x1,%eax
  801912:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801915:	83 c7 01             	add    $0x1,%edi
  801918:	eb ac                	jmp    8018c6 <devpipe_write+0x1c>
	return i;
  80191a:	89 f8                	mov    %edi,%eax
  80191c:	eb 05                	jmp    801923 <devpipe_write+0x79>
				return 0;
  80191e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801923:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801926:	5b                   	pop    %ebx
  801927:	5e                   	pop    %esi
  801928:	5f                   	pop    %edi
  801929:	5d                   	pop    %ebp
  80192a:	c3                   	ret    

0080192b <devpipe_read>:
{
  80192b:	55                   	push   %ebp
  80192c:	89 e5                	mov    %esp,%ebp
  80192e:	57                   	push   %edi
  80192f:	56                   	push   %esi
  801930:	53                   	push   %ebx
  801931:	83 ec 18             	sub    $0x18,%esp
  801934:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801937:	57                   	push   %edi
  801938:	e8 9a f5 ff ff       	call   800ed7 <fd2data>
  80193d:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80193f:	83 c4 10             	add    $0x10,%esp
  801942:	be 00 00 00 00       	mov    $0x0,%esi
  801947:	3b 75 10             	cmp    0x10(%ebp),%esi
  80194a:	74 47                	je     801993 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  80194c:	8b 03                	mov    (%ebx),%eax
  80194e:	3b 43 04             	cmp    0x4(%ebx),%eax
  801951:	75 22                	jne    801975 <devpipe_read+0x4a>
			if (i > 0)
  801953:	85 f6                	test   %esi,%esi
  801955:	75 14                	jne    80196b <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801957:	89 da                	mov    %ebx,%edx
  801959:	89 f8                	mov    %edi,%eax
  80195b:	e8 e5 fe ff ff       	call   801845 <_pipeisclosed>
  801960:	85 c0                	test   %eax,%eax
  801962:	75 33                	jne    801997 <devpipe_read+0x6c>
			sys_yield();
  801964:	e8 4e f3 ff ff       	call   800cb7 <sys_yield>
  801969:	eb e1                	jmp    80194c <devpipe_read+0x21>
				return i;
  80196b:	89 f0                	mov    %esi,%eax
}
  80196d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801970:	5b                   	pop    %ebx
  801971:	5e                   	pop    %esi
  801972:	5f                   	pop    %edi
  801973:	5d                   	pop    %ebp
  801974:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801975:	99                   	cltd   
  801976:	c1 ea 1b             	shr    $0x1b,%edx
  801979:	01 d0                	add    %edx,%eax
  80197b:	83 e0 1f             	and    $0x1f,%eax
  80197e:	29 d0                	sub    %edx,%eax
  801980:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801985:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801988:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  80198b:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  80198e:	83 c6 01             	add    $0x1,%esi
  801991:	eb b4                	jmp    801947 <devpipe_read+0x1c>
	return i;
  801993:	89 f0                	mov    %esi,%eax
  801995:	eb d6                	jmp    80196d <devpipe_read+0x42>
				return 0;
  801997:	b8 00 00 00 00       	mov    $0x0,%eax
  80199c:	eb cf                	jmp    80196d <devpipe_read+0x42>

0080199e <pipe>:
{
  80199e:	55                   	push   %ebp
  80199f:	89 e5                	mov    %esp,%ebp
  8019a1:	56                   	push   %esi
  8019a2:	53                   	push   %ebx
  8019a3:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8019a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019a9:	50                   	push   %eax
  8019aa:	e8 3f f5 ff ff       	call   800eee <fd_alloc>
  8019af:	89 c3                	mov    %eax,%ebx
  8019b1:	83 c4 10             	add    $0x10,%esp
  8019b4:	85 c0                	test   %eax,%eax
  8019b6:	78 5b                	js     801a13 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019b8:	83 ec 04             	sub    $0x4,%esp
  8019bb:	68 07 04 00 00       	push   $0x407
  8019c0:	ff 75 f4             	pushl  -0xc(%ebp)
  8019c3:	6a 00                	push   $0x0
  8019c5:	e8 0c f3 ff ff       	call   800cd6 <sys_page_alloc>
  8019ca:	89 c3                	mov    %eax,%ebx
  8019cc:	83 c4 10             	add    $0x10,%esp
  8019cf:	85 c0                	test   %eax,%eax
  8019d1:	78 40                	js     801a13 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  8019d3:	83 ec 0c             	sub    $0xc,%esp
  8019d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019d9:	50                   	push   %eax
  8019da:	e8 0f f5 ff ff       	call   800eee <fd_alloc>
  8019df:	89 c3                	mov    %eax,%ebx
  8019e1:	83 c4 10             	add    $0x10,%esp
  8019e4:	85 c0                	test   %eax,%eax
  8019e6:	78 1b                	js     801a03 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019e8:	83 ec 04             	sub    $0x4,%esp
  8019eb:	68 07 04 00 00       	push   $0x407
  8019f0:	ff 75 f0             	pushl  -0x10(%ebp)
  8019f3:	6a 00                	push   $0x0
  8019f5:	e8 dc f2 ff ff       	call   800cd6 <sys_page_alloc>
  8019fa:	89 c3                	mov    %eax,%ebx
  8019fc:	83 c4 10             	add    $0x10,%esp
  8019ff:	85 c0                	test   %eax,%eax
  801a01:	79 19                	jns    801a1c <pipe+0x7e>
	sys_page_unmap(0, fd0);
  801a03:	83 ec 08             	sub    $0x8,%esp
  801a06:	ff 75 f4             	pushl  -0xc(%ebp)
  801a09:	6a 00                	push   $0x0
  801a0b:	e8 4b f3 ff ff       	call   800d5b <sys_page_unmap>
  801a10:	83 c4 10             	add    $0x10,%esp
}
  801a13:	89 d8                	mov    %ebx,%eax
  801a15:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a18:	5b                   	pop    %ebx
  801a19:	5e                   	pop    %esi
  801a1a:	5d                   	pop    %ebp
  801a1b:	c3                   	ret    
	va = fd2data(fd0);
  801a1c:	83 ec 0c             	sub    $0xc,%esp
  801a1f:	ff 75 f4             	pushl  -0xc(%ebp)
  801a22:	e8 b0 f4 ff ff       	call   800ed7 <fd2data>
  801a27:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a29:	83 c4 0c             	add    $0xc,%esp
  801a2c:	68 07 04 00 00       	push   $0x407
  801a31:	50                   	push   %eax
  801a32:	6a 00                	push   $0x0
  801a34:	e8 9d f2 ff ff       	call   800cd6 <sys_page_alloc>
  801a39:	89 c3                	mov    %eax,%ebx
  801a3b:	83 c4 10             	add    $0x10,%esp
  801a3e:	85 c0                	test   %eax,%eax
  801a40:	0f 88 8c 00 00 00    	js     801ad2 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a46:	83 ec 0c             	sub    $0xc,%esp
  801a49:	ff 75 f0             	pushl  -0x10(%ebp)
  801a4c:	e8 86 f4 ff ff       	call   800ed7 <fd2data>
  801a51:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801a58:	50                   	push   %eax
  801a59:	6a 00                	push   $0x0
  801a5b:	56                   	push   %esi
  801a5c:	6a 00                	push   $0x0
  801a5e:	e8 b6 f2 ff ff       	call   800d19 <sys_page_map>
  801a63:	89 c3                	mov    %eax,%ebx
  801a65:	83 c4 20             	add    $0x20,%esp
  801a68:	85 c0                	test   %eax,%eax
  801a6a:	78 58                	js     801ac4 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801a6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a6f:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801a75:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801a77:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a7a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801a81:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a84:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801a8a:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801a8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a8f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801a96:	83 ec 0c             	sub    $0xc,%esp
  801a99:	ff 75 f4             	pushl  -0xc(%ebp)
  801a9c:	e8 26 f4 ff ff       	call   800ec7 <fd2num>
  801aa1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801aa4:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801aa6:	83 c4 04             	add    $0x4,%esp
  801aa9:	ff 75 f0             	pushl  -0x10(%ebp)
  801aac:	e8 16 f4 ff ff       	call   800ec7 <fd2num>
  801ab1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ab4:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ab7:	83 c4 10             	add    $0x10,%esp
  801aba:	bb 00 00 00 00       	mov    $0x0,%ebx
  801abf:	e9 4f ff ff ff       	jmp    801a13 <pipe+0x75>
	sys_page_unmap(0, va);
  801ac4:	83 ec 08             	sub    $0x8,%esp
  801ac7:	56                   	push   %esi
  801ac8:	6a 00                	push   $0x0
  801aca:	e8 8c f2 ff ff       	call   800d5b <sys_page_unmap>
  801acf:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801ad2:	83 ec 08             	sub    $0x8,%esp
  801ad5:	ff 75 f0             	pushl  -0x10(%ebp)
  801ad8:	6a 00                	push   $0x0
  801ada:	e8 7c f2 ff ff       	call   800d5b <sys_page_unmap>
  801adf:	83 c4 10             	add    $0x10,%esp
  801ae2:	e9 1c ff ff ff       	jmp    801a03 <pipe+0x65>

00801ae7 <pipeisclosed>:
{
  801ae7:	55                   	push   %ebp
  801ae8:	89 e5                	mov    %esp,%ebp
  801aea:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801aed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801af0:	50                   	push   %eax
  801af1:	ff 75 08             	pushl  0x8(%ebp)
  801af4:	e8 44 f4 ff ff       	call   800f3d <fd_lookup>
  801af9:	83 c4 10             	add    $0x10,%esp
  801afc:	85 c0                	test   %eax,%eax
  801afe:	78 18                	js     801b18 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801b00:	83 ec 0c             	sub    $0xc,%esp
  801b03:	ff 75 f4             	pushl  -0xc(%ebp)
  801b06:	e8 cc f3 ff ff       	call   800ed7 <fd2data>
	return _pipeisclosed(fd, p);
  801b0b:	89 c2                	mov    %eax,%edx
  801b0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b10:	e8 30 fd ff ff       	call   801845 <_pipeisclosed>
  801b15:	83 c4 10             	add    $0x10,%esp
}
  801b18:	c9                   	leave  
  801b19:	c3                   	ret    

00801b1a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801b1a:	55                   	push   %ebp
  801b1b:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801b1d:	b8 00 00 00 00       	mov    $0x0,%eax
  801b22:	5d                   	pop    %ebp
  801b23:	c3                   	ret    

00801b24 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b24:	55                   	push   %ebp
  801b25:	89 e5                	mov    %esp,%ebp
  801b27:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801b2a:	68 ae 24 80 00       	push   $0x8024ae
  801b2f:	ff 75 0c             	pushl  0xc(%ebp)
  801b32:	e8 a6 ed ff ff       	call   8008dd <strcpy>
	return 0;
}
  801b37:	b8 00 00 00 00       	mov    $0x0,%eax
  801b3c:	c9                   	leave  
  801b3d:	c3                   	ret    

00801b3e <devcons_write>:
{
  801b3e:	55                   	push   %ebp
  801b3f:	89 e5                	mov    %esp,%ebp
  801b41:	57                   	push   %edi
  801b42:	56                   	push   %esi
  801b43:	53                   	push   %ebx
  801b44:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801b4a:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801b4f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801b55:	eb 2f                	jmp    801b86 <devcons_write+0x48>
		m = n - tot;
  801b57:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801b5a:	29 f3                	sub    %esi,%ebx
  801b5c:	83 fb 7f             	cmp    $0x7f,%ebx
  801b5f:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801b64:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801b67:	83 ec 04             	sub    $0x4,%esp
  801b6a:	53                   	push   %ebx
  801b6b:	89 f0                	mov    %esi,%eax
  801b6d:	03 45 0c             	add    0xc(%ebp),%eax
  801b70:	50                   	push   %eax
  801b71:	57                   	push   %edi
  801b72:	e8 f4 ee ff ff       	call   800a6b <memmove>
		sys_cputs(buf, m);
  801b77:	83 c4 08             	add    $0x8,%esp
  801b7a:	53                   	push   %ebx
  801b7b:	57                   	push   %edi
  801b7c:	e8 99 f0 ff ff       	call   800c1a <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801b81:	01 de                	add    %ebx,%esi
  801b83:	83 c4 10             	add    $0x10,%esp
  801b86:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b89:	72 cc                	jb     801b57 <devcons_write+0x19>
}
  801b8b:	89 f0                	mov    %esi,%eax
  801b8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b90:	5b                   	pop    %ebx
  801b91:	5e                   	pop    %esi
  801b92:	5f                   	pop    %edi
  801b93:	5d                   	pop    %ebp
  801b94:	c3                   	ret    

00801b95 <devcons_read>:
{
  801b95:	55                   	push   %ebp
  801b96:	89 e5                	mov    %esp,%ebp
  801b98:	83 ec 08             	sub    $0x8,%esp
  801b9b:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801ba0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ba4:	75 07                	jne    801bad <devcons_read+0x18>
}
  801ba6:	c9                   	leave  
  801ba7:	c3                   	ret    
		sys_yield();
  801ba8:	e8 0a f1 ff ff       	call   800cb7 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801bad:	e8 86 f0 ff ff       	call   800c38 <sys_cgetc>
  801bb2:	85 c0                	test   %eax,%eax
  801bb4:	74 f2                	je     801ba8 <devcons_read+0x13>
	if (c < 0)
  801bb6:	85 c0                	test   %eax,%eax
  801bb8:	78 ec                	js     801ba6 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  801bba:	83 f8 04             	cmp    $0x4,%eax
  801bbd:	74 0c                	je     801bcb <devcons_read+0x36>
	*(char*)vbuf = c;
  801bbf:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bc2:	88 02                	mov    %al,(%edx)
	return 1;
  801bc4:	b8 01 00 00 00       	mov    $0x1,%eax
  801bc9:	eb db                	jmp    801ba6 <devcons_read+0x11>
		return 0;
  801bcb:	b8 00 00 00 00       	mov    $0x0,%eax
  801bd0:	eb d4                	jmp    801ba6 <devcons_read+0x11>

00801bd2 <cputchar>:
{
  801bd2:	55                   	push   %ebp
  801bd3:	89 e5                	mov    %esp,%ebp
  801bd5:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801bd8:	8b 45 08             	mov    0x8(%ebp),%eax
  801bdb:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801bde:	6a 01                	push   $0x1
  801be0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801be3:	50                   	push   %eax
  801be4:	e8 31 f0 ff ff       	call   800c1a <sys_cputs>
}
  801be9:	83 c4 10             	add    $0x10,%esp
  801bec:	c9                   	leave  
  801bed:	c3                   	ret    

00801bee <getchar>:
{
  801bee:	55                   	push   %ebp
  801bef:	89 e5                	mov    %esp,%ebp
  801bf1:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801bf4:	6a 01                	push   $0x1
  801bf6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801bf9:	50                   	push   %eax
  801bfa:	6a 00                	push   $0x0
  801bfc:	e8 ad f5 ff ff       	call   8011ae <read>
	if (r < 0)
  801c01:	83 c4 10             	add    $0x10,%esp
  801c04:	85 c0                	test   %eax,%eax
  801c06:	78 08                	js     801c10 <getchar+0x22>
	if (r < 1)
  801c08:	85 c0                	test   %eax,%eax
  801c0a:	7e 06                	jle    801c12 <getchar+0x24>
	return c;
  801c0c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801c10:	c9                   	leave  
  801c11:	c3                   	ret    
		return -E_EOF;
  801c12:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801c17:	eb f7                	jmp    801c10 <getchar+0x22>

00801c19 <iscons>:
{
  801c19:	55                   	push   %ebp
  801c1a:	89 e5                	mov    %esp,%ebp
  801c1c:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c1f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c22:	50                   	push   %eax
  801c23:	ff 75 08             	pushl  0x8(%ebp)
  801c26:	e8 12 f3 ff ff       	call   800f3d <fd_lookup>
  801c2b:	83 c4 10             	add    $0x10,%esp
  801c2e:	85 c0                	test   %eax,%eax
  801c30:	78 11                	js     801c43 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801c32:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c35:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801c3b:	39 10                	cmp    %edx,(%eax)
  801c3d:	0f 94 c0             	sete   %al
  801c40:	0f b6 c0             	movzbl %al,%eax
}
  801c43:	c9                   	leave  
  801c44:	c3                   	ret    

00801c45 <opencons>:
{
  801c45:	55                   	push   %ebp
  801c46:	89 e5                	mov    %esp,%ebp
  801c48:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801c4b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c4e:	50                   	push   %eax
  801c4f:	e8 9a f2 ff ff       	call   800eee <fd_alloc>
  801c54:	83 c4 10             	add    $0x10,%esp
  801c57:	85 c0                	test   %eax,%eax
  801c59:	78 3a                	js     801c95 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c5b:	83 ec 04             	sub    $0x4,%esp
  801c5e:	68 07 04 00 00       	push   $0x407
  801c63:	ff 75 f4             	pushl  -0xc(%ebp)
  801c66:	6a 00                	push   $0x0
  801c68:	e8 69 f0 ff ff       	call   800cd6 <sys_page_alloc>
  801c6d:	83 c4 10             	add    $0x10,%esp
  801c70:	85 c0                	test   %eax,%eax
  801c72:	78 21                	js     801c95 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801c74:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c77:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801c7d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801c7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c82:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801c89:	83 ec 0c             	sub    $0xc,%esp
  801c8c:	50                   	push   %eax
  801c8d:	e8 35 f2 ff ff       	call   800ec7 <fd2num>
  801c92:	83 c4 10             	add    $0x10,%esp
}
  801c95:	c9                   	leave  
  801c96:	c3                   	ret    

00801c97 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c97:	55                   	push   %ebp
  801c98:	89 e5                	mov    %esp,%ebp
  801c9a:	56                   	push   %esi
  801c9b:	53                   	push   %ebx
  801c9c:	8b 75 08             	mov    0x8(%ebp),%esi
  801c9f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ca2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        //	panic("ipc_recv not implemented");
        int r;
       	if(pg!=NULL){
  801ca5:	85 c0                	test   %eax,%eax
  801ca7:	74 3b                	je     801ce4 <ipc_recv+0x4d>
	  r = sys_ipc_recv(pg);
  801ca9:	83 ec 0c             	sub    $0xc,%esp
  801cac:	50                   	push   %eax
  801cad:	e8 d4 f1 ff ff       	call   800e86 <sys_ipc_recv>
  801cb2:	83 c4 10             	add    $0x10,%esp
	}else
	  r = sys_ipc_recv((void *)UTOP);
	if(r<0){
  801cb5:	85 c0                	test   %eax,%eax
  801cb7:	78 3d                	js     801cf6 <ipc_recv+0x5f>
	if(perm_store!=NULL){
		*perm_store = 0;
            }
        	return r;
           }else{
	     if(from_env_store!=NULL)
  801cb9:	85 f6                	test   %esi,%esi
  801cbb:	74 0a                	je     801cc7 <ipc_recv+0x30>
		     *from_env_store = thisenv->env_ipc_from;
  801cbd:	a1 08 40 80 00       	mov    0x804008,%eax
  801cc2:	8b 40 74             	mov    0x74(%eax),%eax
  801cc5:	89 06                	mov    %eax,(%esi)
	     if(perm_store != NULL)
  801cc7:	85 db                	test   %ebx,%ebx
  801cc9:	74 0a                	je     801cd5 <ipc_recv+0x3e>
		     *perm_store = thisenv->env_ipc_perm;
  801ccb:	a1 08 40 80 00       	mov    0x804008,%eax
  801cd0:	8b 40 78             	mov    0x78(%eax),%eax
  801cd3:	89 03                	mov    %eax,(%ebx)
	     return thisenv->env_ipc_value;
  801cd5:	a1 08 40 80 00       	mov    0x804008,%eax
  801cda:	8b 40 70             	mov    0x70(%eax),%eax
	   }

}
  801cdd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ce0:	5b                   	pop    %ebx
  801ce1:	5e                   	pop    %esi
  801ce2:	5d                   	pop    %ebp
  801ce3:	c3                   	ret    
	  r = sys_ipc_recv((void *)UTOP);
  801ce4:	83 ec 0c             	sub    $0xc,%esp
  801ce7:	68 00 00 c0 ee       	push   $0xeec00000
  801cec:	e8 95 f1 ff ff       	call   800e86 <sys_ipc_recv>
  801cf1:	83 c4 10             	add    $0x10,%esp
  801cf4:	eb bf                	jmp    801cb5 <ipc_recv+0x1e>
	if(from_env_store!=NULL){
  801cf6:	85 f6                	test   %esi,%esi
  801cf8:	74 06                	je     801d00 <ipc_recv+0x69>
	  *from_env_store = 0;
  801cfa:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if(perm_store!=NULL){
  801d00:	85 db                	test   %ebx,%ebx
  801d02:	74 d9                	je     801cdd <ipc_recv+0x46>
		*perm_store = 0;
  801d04:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801d0a:	eb d1                	jmp    801cdd <ipc_recv+0x46>

00801d0c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801d0c:	55                   	push   %ebp
  801d0d:	89 e5                	mov    %esp,%ebp
  801d0f:	57                   	push   %edi
  801d10:	56                   	push   %esi
  801d11:	53                   	push   %ebx
  801d12:	83 ec 0c             	sub    $0xc,%esp
  801d15:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d18:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if(pg==NULL) pg = (void *)UTOP;
  801d1e:	85 db                	test   %ebx,%ebx
  801d20:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801d25:	0f 44 d8             	cmove  %eax,%ebx
	while((r=sys_ipc_try_send(to_env,val,pg,perm))<0){
  801d28:	ff 75 14             	pushl  0x14(%ebp)
  801d2b:	53                   	push   %ebx
  801d2c:	56                   	push   %esi
  801d2d:	57                   	push   %edi
  801d2e:	e8 30 f1 ff ff       	call   800e63 <sys_ipc_try_send>
  801d33:	83 c4 10             	add    $0x10,%esp
  801d36:	85 c0                	test   %eax,%eax
  801d38:	79 20                	jns    801d5a <ipc_send+0x4e>
	    if(r!=-E_IPC_NOT_RECV){
  801d3a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801d3d:	75 07                	jne    801d46 <ipc_send+0x3a>
		    panic("ipc_send:send message failed\n");
	    }
	    sys_yield();
  801d3f:	e8 73 ef ff ff       	call   800cb7 <sys_yield>
  801d44:	eb e2                	jmp    801d28 <ipc_send+0x1c>
		    panic("ipc_send:send message failed\n");
  801d46:	83 ec 04             	sub    $0x4,%esp
  801d49:	68 ba 24 80 00       	push   $0x8024ba
  801d4e:	6a 43                	push   $0x43
  801d50:	68 d8 24 80 00       	push   $0x8024d8
  801d55:	e8 89 e4 ff ff       	call   8001e3 <_panic>
	}

}
  801d5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d5d:	5b                   	pop    %ebx
  801d5e:	5e                   	pop    %esi
  801d5f:	5f                   	pop    %edi
  801d60:	5d                   	pop    %ebp
  801d61:	c3                   	ret    

00801d62 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d62:	55                   	push   %ebp
  801d63:	89 e5                	mov    %esp,%ebp
  801d65:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801d68:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801d6d:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801d70:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801d76:	8b 52 50             	mov    0x50(%edx),%edx
  801d79:	39 ca                	cmp    %ecx,%edx
  801d7b:	74 11                	je     801d8e <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801d7d:	83 c0 01             	add    $0x1,%eax
  801d80:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d85:	75 e6                	jne    801d6d <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801d87:	b8 00 00 00 00       	mov    $0x0,%eax
  801d8c:	eb 0b                	jmp    801d99 <ipc_find_env+0x37>
			return envs[i].env_id;
  801d8e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801d91:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801d96:	8b 40 48             	mov    0x48(%eax),%eax
}
  801d99:	5d                   	pop    %ebp
  801d9a:	c3                   	ret    

00801d9b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d9b:	55                   	push   %ebp
  801d9c:	89 e5                	mov    %esp,%ebp
  801d9e:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801da1:	89 d0                	mov    %edx,%eax
  801da3:	c1 e8 16             	shr    $0x16,%eax
  801da6:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801dad:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801db2:	f6 c1 01             	test   $0x1,%cl
  801db5:	74 1d                	je     801dd4 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801db7:	c1 ea 0c             	shr    $0xc,%edx
  801dba:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801dc1:	f6 c2 01             	test   $0x1,%dl
  801dc4:	74 0e                	je     801dd4 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801dc6:	c1 ea 0c             	shr    $0xc,%edx
  801dc9:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801dd0:	ef 
  801dd1:	0f b7 c0             	movzwl %ax,%eax
}
  801dd4:	5d                   	pop    %ebp
  801dd5:	c3                   	ret    
  801dd6:	66 90                	xchg   %ax,%ax
  801dd8:	66 90                	xchg   %ax,%ax
  801dda:	66 90                	xchg   %ax,%ax
  801ddc:	66 90                	xchg   %ax,%ax
  801dde:	66 90                	xchg   %ax,%ax

00801de0 <__udivdi3>:
  801de0:	55                   	push   %ebp
  801de1:	57                   	push   %edi
  801de2:	56                   	push   %esi
  801de3:	53                   	push   %ebx
  801de4:	83 ec 1c             	sub    $0x1c,%esp
  801de7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801deb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801def:	8b 74 24 34          	mov    0x34(%esp),%esi
  801df3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801df7:	85 d2                	test   %edx,%edx
  801df9:	75 35                	jne    801e30 <__udivdi3+0x50>
  801dfb:	39 f3                	cmp    %esi,%ebx
  801dfd:	0f 87 bd 00 00 00    	ja     801ec0 <__udivdi3+0xe0>
  801e03:	85 db                	test   %ebx,%ebx
  801e05:	89 d9                	mov    %ebx,%ecx
  801e07:	75 0b                	jne    801e14 <__udivdi3+0x34>
  801e09:	b8 01 00 00 00       	mov    $0x1,%eax
  801e0e:	31 d2                	xor    %edx,%edx
  801e10:	f7 f3                	div    %ebx
  801e12:	89 c1                	mov    %eax,%ecx
  801e14:	31 d2                	xor    %edx,%edx
  801e16:	89 f0                	mov    %esi,%eax
  801e18:	f7 f1                	div    %ecx
  801e1a:	89 c6                	mov    %eax,%esi
  801e1c:	89 e8                	mov    %ebp,%eax
  801e1e:	89 f7                	mov    %esi,%edi
  801e20:	f7 f1                	div    %ecx
  801e22:	89 fa                	mov    %edi,%edx
  801e24:	83 c4 1c             	add    $0x1c,%esp
  801e27:	5b                   	pop    %ebx
  801e28:	5e                   	pop    %esi
  801e29:	5f                   	pop    %edi
  801e2a:	5d                   	pop    %ebp
  801e2b:	c3                   	ret    
  801e2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e30:	39 f2                	cmp    %esi,%edx
  801e32:	77 7c                	ja     801eb0 <__udivdi3+0xd0>
  801e34:	0f bd fa             	bsr    %edx,%edi
  801e37:	83 f7 1f             	xor    $0x1f,%edi
  801e3a:	0f 84 98 00 00 00    	je     801ed8 <__udivdi3+0xf8>
  801e40:	89 f9                	mov    %edi,%ecx
  801e42:	b8 20 00 00 00       	mov    $0x20,%eax
  801e47:	29 f8                	sub    %edi,%eax
  801e49:	d3 e2                	shl    %cl,%edx
  801e4b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e4f:	89 c1                	mov    %eax,%ecx
  801e51:	89 da                	mov    %ebx,%edx
  801e53:	d3 ea                	shr    %cl,%edx
  801e55:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801e59:	09 d1                	or     %edx,%ecx
  801e5b:	89 f2                	mov    %esi,%edx
  801e5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e61:	89 f9                	mov    %edi,%ecx
  801e63:	d3 e3                	shl    %cl,%ebx
  801e65:	89 c1                	mov    %eax,%ecx
  801e67:	d3 ea                	shr    %cl,%edx
  801e69:	89 f9                	mov    %edi,%ecx
  801e6b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801e6f:	d3 e6                	shl    %cl,%esi
  801e71:	89 eb                	mov    %ebp,%ebx
  801e73:	89 c1                	mov    %eax,%ecx
  801e75:	d3 eb                	shr    %cl,%ebx
  801e77:	09 de                	or     %ebx,%esi
  801e79:	89 f0                	mov    %esi,%eax
  801e7b:	f7 74 24 08          	divl   0x8(%esp)
  801e7f:	89 d6                	mov    %edx,%esi
  801e81:	89 c3                	mov    %eax,%ebx
  801e83:	f7 64 24 0c          	mull   0xc(%esp)
  801e87:	39 d6                	cmp    %edx,%esi
  801e89:	72 0c                	jb     801e97 <__udivdi3+0xb7>
  801e8b:	89 f9                	mov    %edi,%ecx
  801e8d:	d3 e5                	shl    %cl,%ebp
  801e8f:	39 c5                	cmp    %eax,%ebp
  801e91:	73 5d                	jae    801ef0 <__udivdi3+0x110>
  801e93:	39 d6                	cmp    %edx,%esi
  801e95:	75 59                	jne    801ef0 <__udivdi3+0x110>
  801e97:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801e9a:	31 ff                	xor    %edi,%edi
  801e9c:	89 fa                	mov    %edi,%edx
  801e9e:	83 c4 1c             	add    $0x1c,%esp
  801ea1:	5b                   	pop    %ebx
  801ea2:	5e                   	pop    %esi
  801ea3:	5f                   	pop    %edi
  801ea4:	5d                   	pop    %ebp
  801ea5:	c3                   	ret    
  801ea6:	8d 76 00             	lea    0x0(%esi),%esi
  801ea9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801eb0:	31 ff                	xor    %edi,%edi
  801eb2:	31 c0                	xor    %eax,%eax
  801eb4:	89 fa                	mov    %edi,%edx
  801eb6:	83 c4 1c             	add    $0x1c,%esp
  801eb9:	5b                   	pop    %ebx
  801eba:	5e                   	pop    %esi
  801ebb:	5f                   	pop    %edi
  801ebc:	5d                   	pop    %ebp
  801ebd:	c3                   	ret    
  801ebe:	66 90                	xchg   %ax,%ax
  801ec0:	31 ff                	xor    %edi,%edi
  801ec2:	89 e8                	mov    %ebp,%eax
  801ec4:	89 f2                	mov    %esi,%edx
  801ec6:	f7 f3                	div    %ebx
  801ec8:	89 fa                	mov    %edi,%edx
  801eca:	83 c4 1c             	add    $0x1c,%esp
  801ecd:	5b                   	pop    %ebx
  801ece:	5e                   	pop    %esi
  801ecf:	5f                   	pop    %edi
  801ed0:	5d                   	pop    %ebp
  801ed1:	c3                   	ret    
  801ed2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ed8:	39 f2                	cmp    %esi,%edx
  801eda:	72 06                	jb     801ee2 <__udivdi3+0x102>
  801edc:	31 c0                	xor    %eax,%eax
  801ede:	39 eb                	cmp    %ebp,%ebx
  801ee0:	77 d2                	ja     801eb4 <__udivdi3+0xd4>
  801ee2:	b8 01 00 00 00       	mov    $0x1,%eax
  801ee7:	eb cb                	jmp    801eb4 <__udivdi3+0xd4>
  801ee9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ef0:	89 d8                	mov    %ebx,%eax
  801ef2:	31 ff                	xor    %edi,%edi
  801ef4:	eb be                	jmp    801eb4 <__udivdi3+0xd4>
  801ef6:	66 90                	xchg   %ax,%ax
  801ef8:	66 90                	xchg   %ax,%ax
  801efa:	66 90                	xchg   %ax,%ax
  801efc:	66 90                	xchg   %ax,%ax
  801efe:	66 90                	xchg   %ax,%ax

00801f00 <__umoddi3>:
  801f00:	55                   	push   %ebp
  801f01:	57                   	push   %edi
  801f02:	56                   	push   %esi
  801f03:	53                   	push   %ebx
  801f04:	83 ec 1c             	sub    $0x1c,%esp
  801f07:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801f0b:	8b 74 24 30          	mov    0x30(%esp),%esi
  801f0f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801f13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f17:	85 ed                	test   %ebp,%ebp
  801f19:	89 f0                	mov    %esi,%eax
  801f1b:	89 da                	mov    %ebx,%edx
  801f1d:	75 19                	jne    801f38 <__umoddi3+0x38>
  801f1f:	39 df                	cmp    %ebx,%edi
  801f21:	0f 86 b1 00 00 00    	jbe    801fd8 <__umoddi3+0xd8>
  801f27:	f7 f7                	div    %edi
  801f29:	89 d0                	mov    %edx,%eax
  801f2b:	31 d2                	xor    %edx,%edx
  801f2d:	83 c4 1c             	add    $0x1c,%esp
  801f30:	5b                   	pop    %ebx
  801f31:	5e                   	pop    %esi
  801f32:	5f                   	pop    %edi
  801f33:	5d                   	pop    %ebp
  801f34:	c3                   	ret    
  801f35:	8d 76 00             	lea    0x0(%esi),%esi
  801f38:	39 dd                	cmp    %ebx,%ebp
  801f3a:	77 f1                	ja     801f2d <__umoddi3+0x2d>
  801f3c:	0f bd cd             	bsr    %ebp,%ecx
  801f3f:	83 f1 1f             	xor    $0x1f,%ecx
  801f42:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801f46:	0f 84 b4 00 00 00    	je     802000 <__umoddi3+0x100>
  801f4c:	b8 20 00 00 00       	mov    $0x20,%eax
  801f51:	89 c2                	mov    %eax,%edx
  801f53:	8b 44 24 04          	mov    0x4(%esp),%eax
  801f57:	29 c2                	sub    %eax,%edx
  801f59:	89 c1                	mov    %eax,%ecx
  801f5b:	89 f8                	mov    %edi,%eax
  801f5d:	d3 e5                	shl    %cl,%ebp
  801f5f:	89 d1                	mov    %edx,%ecx
  801f61:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801f65:	d3 e8                	shr    %cl,%eax
  801f67:	09 c5                	or     %eax,%ebp
  801f69:	8b 44 24 04          	mov    0x4(%esp),%eax
  801f6d:	89 c1                	mov    %eax,%ecx
  801f6f:	d3 e7                	shl    %cl,%edi
  801f71:	89 d1                	mov    %edx,%ecx
  801f73:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801f77:	89 df                	mov    %ebx,%edi
  801f79:	d3 ef                	shr    %cl,%edi
  801f7b:	89 c1                	mov    %eax,%ecx
  801f7d:	89 f0                	mov    %esi,%eax
  801f7f:	d3 e3                	shl    %cl,%ebx
  801f81:	89 d1                	mov    %edx,%ecx
  801f83:	89 fa                	mov    %edi,%edx
  801f85:	d3 e8                	shr    %cl,%eax
  801f87:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801f8c:	09 d8                	or     %ebx,%eax
  801f8e:	f7 f5                	div    %ebp
  801f90:	d3 e6                	shl    %cl,%esi
  801f92:	89 d1                	mov    %edx,%ecx
  801f94:	f7 64 24 08          	mull   0x8(%esp)
  801f98:	39 d1                	cmp    %edx,%ecx
  801f9a:	89 c3                	mov    %eax,%ebx
  801f9c:	89 d7                	mov    %edx,%edi
  801f9e:	72 06                	jb     801fa6 <__umoddi3+0xa6>
  801fa0:	75 0e                	jne    801fb0 <__umoddi3+0xb0>
  801fa2:	39 c6                	cmp    %eax,%esi
  801fa4:	73 0a                	jae    801fb0 <__umoddi3+0xb0>
  801fa6:	2b 44 24 08          	sub    0x8(%esp),%eax
  801faa:	19 ea                	sbb    %ebp,%edx
  801fac:	89 d7                	mov    %edx,%edi
  801fae:	89 c3                	mov    %eax,%ebx
  801fb0:	89 ca                	mov    %ecx,%edx
  801fb2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801fb7:	29 de                	sub    %ebx,%esi
  801fb9:	19 fa                	sbb    %edi,%edx
  801fbb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  801fbf:	89 d0                	mov    %edx,%eax
  801fc1:	d3 e0                	shl    %cl,%eax
  801fc3:	89 d9                	mov    %ebx,%ecx
  801fc5:	d3 ee                	shr    %cl,%esi
  801fc7:	d3 ea                	shr    %cl,%edx
  801fc9:	09 f0                	or     %esi,%eax
  801fcb:	83 c4 1c             	add    $0x1c,%esp
  801fce:	5b                   	pop    %ebx
  801fcf:	5e                   	pop    %esi
  801fd0:	5f                   	pop    %edi
  801fd1:	5d                   	pop    %ebp
  801fd2:	c3                   	ret    
  801fd3:	90                   	nop
  801fd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fd8:	85 ff                	test   %edi,%edi
  801fda:	89 f9                	mov    %edi,%ecx
  801fdc:	75 0b                	jne    801fe9 <__umoddi3+0xe9>
  801fde:	b8 01 00 00 00       	mov    $0x1,%eax
  801fe3:	31 d2                	xor    %edx,%edx
  801fe5:	f7 f7                	div    %edi
  801fe7:	89 c1                	mov    %eax,%ecx
  801fe9:	89 d8                	mov    %ebx,%eax
  801feb:	31 d2                	xor    %edx,%edx
  801fed:	f7 f1                	div    %ecx
  801fef:	89 f0                	mov    %esi,%eax
  801ff1:	f7 f1                	div    %ecx
  801ff3:	e9 31 ff ff ff       	jmp    801f29 <__umoddi3+0x29>
  801ff8:	90                   	nop
  801ff9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802000:	39 dd                	cmp    %ebx,%ebp
  802002:	72 08                	jb     80200c <__umoddi3+0x10c>
  802004:	39 f7                	cmp    %esi,%edi
  802006:	0f 87 21 ff ff ff    	ja     801f2d <__umoddi3+0x2d>
  80200c:	89 da                	mov    %ebx,%edx
  80200e:	89 f0                	mov    %esi,%eax
  802010:	29 f8                	sub    %edi,%eax
  802012:	19 ea                	sbb    %ebp,%edx
  802014:	e9 14 ff ff ff       	jmp    801f2d <__umoddi3+0x2d>
