
obj/user/faultallocbad.debug:     file format elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
  80003d:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  80003f:	53                   	push   %ebx
  800040:	68 c0 1e 80 00       	push   $0x801ec0
  800045:	e8 a6 01 00 00       	call   8001f0 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 aa 0b 00 00       	call   800c08 <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	78 16                	js     80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800065:	53                   	push   %ebx
  800066:	68 0c 1f 80 00       	push   $0x801f0c
  80006b:	6a 64                	push   $0x64
  80006d:	53                   	push   %ebx
  80006e:	e8 4b 07 00 00       	call   8007be <snprintf>
}
  800073:	83 c4 10             	add    $0x10,%esp
  800076:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800079:	c9                   	leave  
  80007a:	c3                   	ret    
		panic("allocating at %x in page fault handler: %e", addr, r);
  80007b:	83 ec 0c             	sub    $0xc,%esp
  80007e:	50                   	push   %eax
  80007f:	53                   	push   %ebx
  800080:	68 e0 1e 80 00       	push   $0x801ee0
  800085:	6a 0f                	push   $0xf
  800087:	68 ca 1e 80 00       	push   $0x801eca
  80008c:	e8 84 00 00 00       	call   800115 <_panic>

00800091 <umain>:

void
umain(int argc, char **argv)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800097:	68 33 00 80 00       	push   $0x800033
  80009c:	e8 58 0d 00 00       	call   800df9 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	6a 04                	push   $0x4
  8000a6:	68 ef be ad de       	push   $0xdeadbeef
  8000ab:	e8 9c 0a 00 00       	call   800b4c <sys_cputs>
}
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000c0:	e8 05 0b 00 00       	call   800bca <sys_getenvid>
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d2:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d7:	85 db                	test   %ebx,%ebx
  8000d9:	7e 07                	jle    8000e2 <libmain+0x2d>
		binaryname = argv[0];
  8000db:	8b 06                	mov    (%esi),%eax
  8000dd:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000e2:	83 ec 08             	sub    $0x8,%esp
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	e8 a5 ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  8000ec:	e8 0a 00 00 00       	call   8000fb <exit>
}
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5e                   	pop    %esi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800101:	e8 55 0f 00 00       	call   80105b <close_all>
	sys_env_destroy(0);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	6a 00                	push   $0x0
  80010b:	e8 79 0a 00 00       	call   800b89 <sys_env_destroy>
}
  800110:	83 c4 10             	add    $0x10,%esp
  800113:	c9                   	leave  
  800114:	c3                   	ret    

00800115 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800115:	55                   	push   %ebp
  800116:	89 e5                	mov    %esp,%ebp
  800118:	56                   	push   %esi
  800119:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80011a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80011d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800123:	e8 a2 0a 00 00       	call   800bca <sys_getenvid>
  800128:	83 ec 0c             	sub    $0xc,%esp
  80012b:	ff 75 0c             	pushl  0xc(%ebp)
  80012e:	ff 75 08             	pushl  0x8(%ebp)
  800131:	56                   	push   %esi
  800132:	50                   	push   %eax
  800133:	68 38 1f 80 00       	push   $0x801f38
  800138:	e8 b3 00 00 00       	call   8001f0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80013d:	83 c4 18             	add    $0x18,%esp
  800140:	53                   	push   %ebx
  800141:	ff 75 10             	pushl  0x10(%ebp)
  800144:	e8 56 00 00 00       	call   80019f <vcprintf>
	cprintf("\n");
  800149:	c7 04 24 8b 23 80 00 	movl   $0x80238b,(%esp)
  800150:	e8 9b 00 00 00       	call   8001f0 <cprintf>
  800155:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800158:	cc                   	int3   
  800159:	eb fd                	jmp    800158 <_panic+0x43>

0080015b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	53                   	push   %ebx
  80015f:	83 ec 04             	sub    $0x4,%esp
  800162:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800165:	8b 13                	mov    (%ebx),%edx
  800167:	8d 42 01             	lea    0x1(%edx),%eax
  80016a:	89 03                	mov    %eax,(%ebx)
  80016c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80016f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800173:	3d ff 00 00 00       	cmp    $0xff,%eax
  800178:	74 09                	je     800183 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80017a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80017e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800181:	c9                   	leave  
  800182:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800183:	83 ec 08             	sub    $0x8,%esp
  800186:	68 ff 00 00 00       	push   $0xff
  80018b:	8d 43 08             	lea    0x8(%ebx),%eax
  80018e:	50                   	push   %eax
  80018f:	e8 b8 09 00 00       	call   800b4c <sys_cputs>
		b->idx = 0;
  800194:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80019a:	83 c4 10             	add    $0x10,%esp
  80019d:	eb db                	jmp    80017a <putch+0x1f>

0080019f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80019f:	55                   	push   %ebp
  8001a0:	89 e5                	mov    %esp,%ebp
  8001a2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001af:	00 00 00 
	b.cnt = 0;
  8001b2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001bc:	ff 75 0c             	pushl  0xc(%ebp)
  8001bf:	ff 75 08             	pushl  0x8(%ebp)
  8001c2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c8:	50                   	push   %eax
  8001c9:	68 5b 01 80 00       	push   $0x80015b
  8001ce:	e8 1a 01 00 00       	call   8002ed <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d3:	83 c4 08             	add    $0x8,%esp
  8001d6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001dc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e2:	50                   	push   %eax
  8001e3:	e8 64 09 00 00       	call   800b4c <sys_cputs>

	return b.cnt;
}
  8001e8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ee:	c9                   	leave  
  8001ef:	c3                   	ret    

008001f0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001f9:	50                   	push   %eax
  8001fa:	ff 75 08             	pushl  0x8(%ebp)
  8001fd:	e8 9d ff ff ff       	call   80019f <vcprintf>
	va_end(ap);

	return cnt;
}
  800202:	c9                   	leave  
  800203:	c3                   	ret    

00800204 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800204:	55                   	push   %ebp
  800205:	89 e5                	mov    %esp,%ebp
  800207:	57                   	push   %edi
  800208:	56                   	push   %esi
  800209:	53                   	push   %ebx
  80020a:	83 ec 1c             	sub    $0x1c,%esp
  80020d:	89 c7                	mov    %eax,%edi
  80020f:	89 d6                	mov    %edx,%esi
  800211:	8b 45 08             	mov    0x8(%ebp),%eax
  800214:	8b 55 0c             	mov    0xc(%ebp),%edx
  800217:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80021a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80021d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800220:	bb 00 00 00 00       	mov    $0x0,%ebx
  800225:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800228:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80022b:	39 d3                	cmp    %edx,%ebx
  80022d:	72 05                	jb     800234 <printnum+0x30>
  80022f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800232:	77 7a                	ja     8002ae <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800234:	83 ec 0c             	sub    $0xc,%esp
  800237:	ff 75 18             	pushl  0x18(%ebp)
  80023a:	8b 45 14             	mov    0x14(%ebp),%eax
  80023d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800240:	53                   	push   %ebx
  800241:	ff 75 10             	pushl  0x10(%ebp)
  800244:	83 ec 08             	sub    $0x8,%esp
  800247:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024a:	ff 75 e0             	pushl  -0x20(%ebp)
  80024d:	ff 75 dc             	pushl  -0x24(%ebp)
  800250:	ff 75 d8             	pushl  -0x28(%ebp)
  800253:	e8 28 1a 00 00       	call   801c80 <__udivdi3>
  800258:	83 c4 18             	add    $0x18,%esp
  80025b:	52                   	push   %edx
  80025c:	50                   	push   %eax
  80025d:	89 f2                	mov    %esi,%edx
  80025f:	89 f8                	mov    %edi,%eax
  800261:	e8 9e ff ff ff       	call   800204 <printnum>
  800266:	83 c4 20             	add    $0x20,%esp
  800269:	eb 13                	jmp    80027e <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80026b:	83 ec 08             	sub    $0x8,%esp
  80026e:	56                   	push   %esi
  80026f:	ff 75 18             	pushl  0x18(%ebp)
  800272:	ff d7                	call   *%edi
  800274:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800277:	83 eb 01             	sub    $0x1,%ebx
  80027a:	85 db                	test   %ebx,%ebx
  80027c:	7f ed                	jg     80026b <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80027e:	83 ec 08             	sub    $0x8,%esp
  800281:	56                   	push   %esi
  800282:	83 ec 04             	sub    $0x4,%esp
  800285:	ff 75 e4             	pushl  -0x1c(%ebp)
  800288:	ff 75 e0             	pushl  -0x20(%ebp)
  80028b:	ff 75 dc             	pushl  -0x24(%ebp)
  80028e:	ff 75 d8             	pushl  -0x28(%ebp)
  800291:	e8 0a 1b 00 00       	call   801da0 <__umoddi3>
  800296:	83 c4 14             	add    $0x14,%esp
  800299:	0f be 80 5b 1f 80 00 	movsbl 0x801f5b(%eax),%eax
  8002a0:	50                   	push   %eax
  8002a1:	ff d7                	call   *%edi
}
  8002a3:	83 c4 10             	add    $0x10,%esp
  8002a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a9:	5b                   	pop    %ebx
  8002aa:	5e                   	pop    %esi
  8002ab:	5f                   	pop    %edi
  8002ac:	5d                   	pop    %ebp
  8002ad:	c3                   	ret    
  8002ae:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002b1:	eb c4                	jmp    800277 <printnum+0x73>

008002b3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b3:	55                   	push   %ebp
  8002b4:	89 e5                	mov    %esp,%ebp
  8002b6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002bd:	8b 10                	mov    (%eax),%edx
  8002bf:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c2:	73 0a                	jae    8002ce <sprintputch+0x1b>
		*b->buf++ = ch;
  8002c4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c7:	89 08                	mov    %ecx,(%eax)
  8002c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002cc:	88 02                	mov    %al,(%edx)
}
  8002ce:	5d                   	pop    %ebp
  8002cf:	c3                   	ret    

008002d0 <printfmt>:
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002d6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d9:	50                   	push   %eax
  8002da:	ff 75 10             	pushl  0x10(%ebp)
  8002dd:	ff 75 0c             	pushl  0xc(%ebp)
  8002e0:	ff 75 08             	pushl  0x8(%ebp)
  8002e3:	e8 05 00 00 00       	call   8002ed <vprintfmt>
}
  8002e8:	83 c4 10             	add    $0x10,%esp
  8002eb:	c9                   	leave  
  8002ec:	c3                   	ret    

008002ed <vprintfmt>:
{
  8002ed:	55                   	push   %ebp
  8002ee:	89 e5                	mov    %esp,%ebp
  8002f0:	57                   	push   %edi
  8002f1:	56                   	push   %esi
  8002f2:	53                   	push   %ebx
  8002f3:	83 ec 2c             	sub    $0x2c,%esp
  8002f6:	8b 75 08             	mov    0x8(%ebp),%esi
  8002f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002fc:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002ff:	e9 c1 03 00 00       	jmp    8006c5 <vprintfmt+0x3d8>
		padc = ' ';
  800304:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800308:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  80030f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800316:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80031d:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800322:	8d 47 01             	lea    0x1(%edi),%eax
  800325:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800328:	0f b6 17             	movzbl (%edi),%edx
  80032b:	8d 42 dd             	lea    -0x23(%edx),%eax
  80032e:	3c 55                	cmp    $0x55,%al
  800330:	0f 87 12 04 00 00    	ja     800748 <vprintfmt+0x45b>
  800336:	0f b6 c0             	movzbl %al,%eax
  800339:	ff 24 85 a0 20 80 00 	jmp    *0x8020a0(,%eax,4)
  800340:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800343:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800347:	eb d9                	jmp    800322 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800349:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80034c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800350:	eb d0                	jmp    800322 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800352:	0f b6 d2             	movzbl %dl,%edx
  800355:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800358:	b8 00 00 00 00       	mov    $0x0,%eax
  80035d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800360:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800363:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800367:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80036a:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80036d:	83 f9 09             	cmp    $0x9,%ecx
  800370:	77 55                	ja     8003c7 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800372:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800375:	eb e9                	jmp    800360 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  800377:	8b 45 14             	mov    0x14(%ebp),%eax
  80037a:	8b 00                	mov    (%eax),%eax
  80037c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80037f:	8b 45 14             	mov    0x14(%ebp),%eax
  800382:	8d 40 04             	lea    0x4(%eax),%eax
  800385:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800388:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80038b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80038f:	79 91                	jns    800322 <vprintfmt+0x35>
				width = precision, precision = -1;
  800391:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800394:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800397:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80039e:	eb 82                	jmp    800322 <vprintfmt+0x35>
  8003a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003a3:	85 c0                	test   %eax,%eax
  8003a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8003aa:	0f 49 d0             	cmovns %eax,%edx
  8003ad:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b3:	e9 6a ff ff ff       	jmp    800322 <vprintfmt+0x35>
  8003b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003bb:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003c2:	e9 5b ff ff ff       	jmp    800322 <vprintfmt+0x35>
  8003c7:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003ca:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003cd:	eb bc                	jmp    80038b <vprintfmt+0x9e>
			lflag++;
  8003cf:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003d5:	e9 48 ff ff ff       	jmp    800322 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8003da:	8b 45 14             	mov    0x14(%ebp),%eax
  8003dd:	8d 78 04             	lea    0x4(%eax),%edi
  8003e0:	83 ec 08             	sub    $0x8,%esp
  8003e3:	53                   	push   %ebx
  8003e4:	ff 30                	pushl  (%eax)
  8003e6:	ff d6                	call   *%esi
			break;
  8003e8:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003eb:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003ee:	e9 cf 02 00 00       	jmp    8006c2 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  8003f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f6:	8d 78 04             	lea    0x4(%eax),%edi
  8003f9:	8b 00                	mov    (%eax),%eax
  8003fb:	99                   	cltd   
  8003fc:	31 d0                	xor    %edx,%eax
  8003fe:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800400:	83 f8 0f             	cmp    $0xf,%eax
  800403:	7f 23                	jg     800428 <vprintfmt+0x13b>
  800405:	8b 14 85 00 22 80 00 	mov    0x802200(,%eax,4),%edx
  80040c:	85 d2                	test   %edx,%edx
  80040e:	74 18                	je     800428 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800410:	52                   	push   %edx
  800411:	68 59 23 80 00       	push   $0x802359
  800416:	53                   	push   %ebx
  800417:	56                   	push   %esi
  800418:	e8 b3 fe ff ff       	call   8002d0 <printfmt>
  80041d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800420:	89 7d 14             	mov    %edi,0x14(%ebp)
  800423:	e9 9a 02 00 00       	jmp    8006c2 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  800428:	50                   	push   %eax
  800429:	68 73 1f 80 00       	push   $0x801f73
  80042e:	53                   	push   %ebx
  80042f:	56                   	push   %esi
  800430:	e8 9b fe ff ff       	call   8002d0 <printfmt>
  800435:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800438:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80043b:	e9 82 02 00 00       	jmp    8006c2 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  800440:	8b 45 14             	mov    0x14(%ebp),%eax
  800443:	83 c0 04             	add    $0x4,%eax
  800446:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800449:	8b 45 14             	mov    0x14(%ebp),%eax
  80044c:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80044e:	85 ff                	test   %edi,%edi
  800450:	b8 6c 1f 80 00       	mov    $0x801f6c,%eax
  800455:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800458:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80045c:	0f 8e bd 00 00 00    	jle    80051f <vprintfmt+0x232>
  800462:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800466:	75 0e                	jne    800476 <vprintfmt+0x189>
  800468:	89 75 08             	mov    %esi,0x8(%ebp)
  80046b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80046e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800471:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800474:	eb 6d                	jmp    8004e3 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  800476:	83 ec 08             	sub    $0x8,%esp
  800479:	ff 75 d0             	pushl  -0x30(%ebp)
  80047c:	57                   	push   %edi
  80047d:	e8 6e 03 00 00       	call   8007f0 <strnlen>
  800482:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800485:	29 c1                	sub    %eax,%ecx
  800487:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80048a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80048d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800491:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800494:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800497:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800499:	eb 0f                	jmp    8004aa <vprintfmt+0x1bd>
					putch(padc, putdat);
  80049b:	83 ec 08             	sub    $0x8,%esp
  80049e:	53                   	push   %ebx
  80049f:	ff 75 e0             	pushl  -0x20(%ebp)
  8004a2:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a4:	83 ef 01             	sub    $0x1,%edi
  8004a7:	83 c4 10             	add    $0x10,%esp
  8004aa:	85 ff                	test   %edi,%edi
  8004ac:	7f ed                	jg     80049b <vprintfmt+0x1ae>
  8004ae:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004b1:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004b4:	85 c9                	test   %ecx,%ecx
  8004b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004bb:	0f 49 c1             	cmovns %ecx,%eax
  8004be:	29 c1                	sub    %eax,%ecx
  8004c0:	89 75 08             	mov    %esi,0x8(%ebp)
  8004c3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004c6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004c9:	89 cb                	mov    %ecx,%ebx
  8004cb:	eb 16                	jmp    8004e3 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8004cd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004d1:	75 31                	jne    800504 <vprintfmt+0x217>
					putch(ch, putdat);
  8004d3:	83 ec 08             	sub    $0x8,%esp
  8004d6:	ff 75 0c             	pushl  0xc(%ebp)
  8004d9:	50                   	push   %eax
  8004da:	ff 55 08             	call   *0x8(%ebp)
  8004dd:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e0:	83 eb 01             	sub    $0x1,%ebx
  8004e3:	83 c7 01             	add    $0x1,%edi
  8004e6:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8004ea:	0f be c2             	movsbl %dl,%eax
  8004ed:	85 c0                	test   %eax,%eax
  8004ef:	74 59                	je     80054a <vprintfmt+0x25d>
  8004f1:	85 f6                	test   %esi,%esi
  8004f3:	78 d8                	js     8004cd <vprintfmt+0x1e0>
  8004f5:	83 ee 01             	sub    $0x1,%esi
  8004f8:	79 d3                	jns    8004cd <vprintfmt+0x1e0>
  8004fa:	89 df                	mov    %ebx,%edi
  8004fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800502:	eb 37                	jmp    80053b <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  800504:	0f be d2             	movsbl %dl,%edx
  800507:	83 ea 20             	sub    $0x20,%edx
  80050a:	83 fa 5e             	cmp    $0x5e,%edx
  80050d:	76 c4                	jbe    8004d3 <vprintfmt+0x1e6>
					putch('?', putdat);
  80050f:	83 ec 08             	sub    $0x8,%esp
  800512:	ff 75 0c             	pushl  0xc(%ebp)
  800515:	6a 3f                	push   $0x3f
  800517:	ff 55 08             	call   *0x8(%ebp)
  80051a:	83 c4 10             	add    $0x10,%esp
  80051d:	eb c1                	jmp    8004e0 <vprintfmt+0x1f3>
  80051f:	89 75 08             	mov    %esi,0x8(%ebp)
  800522:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800525:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800528:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80052b:	eb b6                	jmp    8004e3 <vprintfmt+0x1f6>
				putch(' ', putdat);
  80052d:	83 ec 08             	sub    $0x8,%esp
  800530:	53                   	push   %ebx
  800531:	6a 20                	push   $0x20
  800533:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800535:	83 ef 01             	sub    $0x1,%edi
  800538:	83 c4 10             	add    $0x10,%esp
  80053b:	85 ff                	test   %edi,%edi
  80053d:	7f ee                	jg     80052d <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  80053f:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800542:	89 45 14             	mov    %eax,0x14(%ebp)
  800545:	e9 78 01 00 00       	jmp    8006c2 <vprintfmt+0x3d5>
  80054a:	89 df                	mov    %ebx,%edi
  80054c:	8b 75 08             	mov    0x8(%ebp),%esi
  80054f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800552:	eb e7                	jmp    80053b <vprintfmt+0x24e>
	if (lflag >= 2)
  800554:	83 f9 01             	cmp    $0x1,%ecx
  800557:	7e 3f                	jle    800598 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800559:	8b 45 14             	mov    0x14(%ebp),%eax
  80055c:	8b 50 04             	mov    0x4(%eax),%edx
  80055f:	8b 00                	mov    (%eax),%eax
  800561:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800564:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800567:	8b 45 14             	mov    0x14(%ebp),%eax
  80056a:	8d 40 08             	lea    0x8(%eax),%eax
  80056d:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800570:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800574:	79 5c                	jns    8005d2 <vprintfmt+0x2e5>
				putch('-', putdat);
  800576:	83 ec 08             	sub    $0x8,%esp
  800579:	53                   	push   %ebx
  80057a:	6a 2d                	push   $0x2d
  80057c:	ff d6                	call   *%esi
				num = -(long long) num;
  80057e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800581:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800584:	f7 da                	neg    %edx
  800586:	83 d1 00             	adc    $0x0,%ecx
  800589:	f7 d9                	neg    %ecx
  80058b:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80058e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800593:	e9 10 01 00 00       	jmp    8006a8 <vprintfmt+0x3bb>
	else if (lflag)
  800598:	85 c9                	test   %ecx,%ecx
  80059a:	75 1b                	jne    8005b7 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  80059c:	8b 45 14             	mov    0x14(%ebp),%eax
  80059f:	8b 00                	mov    (%eax),%eax
  8005a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a4:	89 c1                	mov    %eax,%ecx
  8005a6:	c1 f9 1f             	sar    $0x1f,%ecx
  8005a9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8005af:	8d 40 04             	lea    0x4(%eax),%eax
  8005b2:	89 45 14             	mov    %eax,0x14(%ebp)
  8005b5:	eb b9                	jmp    800570 <vprintfmt+0x283>
		return va_arg(*ap, long);
  8005b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ba:	8b 00                	mov    (%eax),%eax
  8005bc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005bf:	89 c1                	mov    %eax,%ecx
  8005c1:	c1 f9 1f             	sar    $0x1f,%ecx
  8005c4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ca:	8d 40 04             	lea    0x4(%eax),%eax
  8005cd:	89 45 14             	mov    %eax,0x14(%ebp)
  8005d0:	eb 9e                	jmp    800570 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8005d2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005d5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005d8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005dd:	e9 c6 00 00 00       	jmp    8006a8 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8005e2:	83 f9 01             	cmp    $0x1,%ecx
  8005e5:	7e 18                	jle    8005ff <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8005e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ea:	8b 10                	mov    (%eax),%edx
  8005ec:	8b 48 04             	mov    0x4(%eax),%ecx
  8005ef:	8d 40 08             	lea    0x8(%eax),%eax
  8005f2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005f5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005fa:	e9 a9 00 00 00       	jmp    8006a8 <vprintfmt+0x3bb>
	else if (lflag)
  8005ff:	85 c9                	test   %ecx,%ecx
  800601:	75 1a                	jne    80061d <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  800603:	8b 45 14             	mov    0x14(%ebp),%eax
  800606:	8b 10                	mov    (%eax),%edx
  800608:	b9 00 00 00 00       	mov    $0x0,%ecx
  80060d:	8d 40 04             	lea    0x4(%eax),%eax
  800610:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800613:	b8 0a 00 00 00       	mov    $0xa,%eax
  800618:	e9 8b 00 00 00       	jmp    8006a8 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80061d:	8b 45 14             	mov    0x14(%ebp),%eax
  800620:	8b 10                	mov    (%eax),%edx
  800622:	b9 00 00 00 00       	mov    $0x0,%ecx
  800627:	8d 40 04             	lea    0x4(%eax),%eax
  80062a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80062d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800632:	eb 74                	jmp    8006a8 <vprintfmt+0x3bb>
	if (lflag >= 2)
  800634:	83 f9 01             	cmp    $0x1,%ecx
  800637:	7e 15                	jle    80064e <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  800639:	8b 45 14             	mov    0x14(%ebp),%eax
  80063c:	8b 10                	mov    (%eax),%edx
  80063e:	8b 48 04             	mov    0x4(%eax),%ecx
  800641:	8d 40 08             	lea    0x8(%eax),%eax
  800644:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800647:	b8 08 00 00 00       	mov    $0x8,%eax
  80064c:	eb 5a                	jmp    8006a8 <vprintfmt+0x3bb>
	else if (lflag)
  80064e:	85 c9                	test   %ecx,%ecx
  800650:	75 17                	jne    800669 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  800652:	8b 45 14             	mov    0x14(%ebp),%eax
  800655:	8b 10                	mov    (%eax),%edx
  800657:	b9 00 00 00 00       	mov    $0x0,%ecx
  80065c:	8d 40 04             	lea    0x4(%eax),%eax
  80065f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800662:	b8 08 00 00 00       	mov    $0x8,%eax
  800667:	eb 3f                	jmp    8006a8 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800669:	8b 45 14             	mov    0x14(%ebp),%eax
  80066c:	8b 10                	mov    (%eax),%edx
  80066e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800673:	8d 40 04             	lea    0x4(%eax),%eax
  800676:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800679:	b8 08 00 00 00       	mov    $0x8,%eax
  80067e:	eb 28                	jmp    8006a8 <vprintfmt+0x3bb>
			putch('0', putdat);
  800680:	83 ec 08             	sub    $0x8,%esp
  800683:	53                   	push   %ebx
  800684:	6a 30                	push   $0x30
  800686:	ff d6                	call   *%esi
			putch('x', putdat);
  800688:	83 c4 08             	add    $0x8,%esp
  80068b:	53                   	push   %ebx
  80068c:	6a 78                	push   $0x78
  80068e:	ff d6                	call   *%esi
			num = (unsigned long long)
  800690:	8b 45 14             	mov    0x14(%ebp),%eax
  800693:	8b 10                	mov    (%eax),%edx
  800695:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80069a:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80069d:	8d 40 04             	lea    0x4(%eax),%eax
  8006a0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006a3:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006a8:	83 ec 0c             	sub    $0xc,%esp
  8006ab:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006af:	57                   	push   %edi
  8006b0:	ff 75 e0             	pushl  -0x20(%ebp)
  8006b3:	50                   	push   %eax
  8006b4:	51                   	push   %ecx
  8006b5:	52                   	push   %edx
  8006b6:	89 da                	mov    %ebx,%edx
  8006b8:	89 f0                	mov    %esi,%eax
  8006ba:	e8 45 fb ff ff       	call   800204 <printnum>
			break;
  8006bf:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8006c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006c5:	83 c7 01             	add    $0x1,%edi
  8006c8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006cc:	83 f8 25             	cmp    $0x25,%eax
  8006cf:	0f 84 2f fc ff ff    	je     800304 <vprintfmt+0x17>
			if (ch == '\0')
  8006d5:	85 c0                	test   %eax,%eax
  8006d7:	0f 84 8b 00 00 00    	je     800768 <vprintfmt+0x47b>
			putch(ch, putdat);
  8006dd:	83 ec 08             	sub    $0x8,%esp
  8006e0:	53                   	push   %ebx
  8006e1:	50                   	push   %eax
  8006e2:	ff d6                	call   *%esi
  8006e4:	83 c4 10             	add    $0x10,%esp
  8006e7:	eb dc                	jmp    8006c5 <vprintfmt+0x3d8>
	if (lflag >= 2)
  8006e9:	83 f9 01             	cmp    $0x1,%ecx
  8006ec:	7e 15                	jle    800703 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  8006ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f1:	8b 10                	mov    (%eax),%edx
  8006f3:	8b 48 04             	mov    0x4(%eax),%ecx
  8006f6:	8d 40 08             	lea    0x8(%eax),%eax
  8006f9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006fc:	b8 10 00 00 00       	mov    $0x10,%eax
  800701:	eb a5                	jmp    8006a8 <vprintfmt+0x3bb>
	else if (lflag)
  800703:	85 c9                	test   %ecx,%ecx
  800705:	75 17                	jne    80071e <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  800707:	8b 45 14             	mov    0x14(%ebp),%eax
  80070a:	8b 10                	mov    (%eax),%edx
  80070c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800711:	8d 40 04             	lea    0x4(%eax),%eax
  800714:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800717:	b8 10 00 00 00       	mov    $0x10,%eax
  80071c:	eb 8a                	jmp    8006a8 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80071e:	8b 45 14             	mov    0x14(%ebp),%eax
  800721:	8b 10                	mov    (%eax),%edx
  800723:	b9 00 00 00 00       	mov    $0x0,%ecx
  800728:	8d 40 04             	lea    0x4(%eax),%eax
  80072b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80072e:	b8 10 00 00 00       	mov    $0x10,%eax
  800733:	e9 70 ff ff ff       	jmp    8006a8 <vprintfmt+0x3bb>
			putch(ch, putdat);
  800738:	83 ec 08             	sub    $0x8,%esp
  80073b:	53                   	push   %ebx
  80073c:	6a 25                	push   $0x25
  80073e:	ff d6                	call   *%esi
			break;
  800740:	83 c4 10             	add    $0x10,%esp
  800743:	e9 7a ff ff ff       	jmp    8006c2 <vprintfmt+0x3d5>
			putch('%', putdat);
  800748:	83 ec 08             	sub    $0x8,%esp
  80074b:	53                   	push   %ebx
  80074c:	6a 25                	push   $0x25
  80074e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800750:	83 c4 10             	add    $0x10,%esp
  800753:	89 f8                	mov    %edi,%eax
  800755:	eb 03                	jmp    80075a <vprintfmt+0x46d>
  800757:	83 e8 01             	sub    $0x1,%eax
  80075a:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80075e:	75 f7                	jne    800757 <vprintfmt+0x46a>
  800760:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800763:	e9 5a ff ff ff       	jmp    8006c2 <vprintfmt+0x3d5>
}
  800768:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80076b:	5b                   	pop    %ebx
  80076c:	5e                   	pop    %esi
  80076d:	5f                   	pop    %edi
  80076e:	5d                   	pop    %ebp
  80076f:	c3                   	ret    

00800770 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	83 ec 18             	sub    $0x18,%esp
  800776:	8b 45 08             	mov    0x8(%ebp),%eax
  800779:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80077c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80077f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800783:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800786:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80078d:	85 c0                	test   %eax,%eax
  80078f:	74 26                	je     8007b7 <vsnprintf+0x47>
  800791:	85 d2                	test   %edx,%edx
  800793:	7e 22                	jle    8007b7 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800795:	ff 75 14             	pushl  0x14(%ebp)
  800798:	ff 75 10             	pushl  0x10(%ebp)
  80079b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80079e:	50                   	push   %eax
  80079f:	68 b3 02 80 00       	push   $0x8002b3
  8007a4:	e8 44 fb ff ff       	call   8002ed <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007ac:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007b2:	83 c4 10             	add    $0x10,%esp
}
  8007b5:	c9                   	leave  
  8007b6:	c3                   	ret    
		return -E_INVAL;
  8007b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007bc:	eb f7                	jmp    8007b5 <vsnprintf+0x45>

008007be <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007be:	55                   	push   %ebp
  8007bf:	89 e5                	mov    %esp,%ebp
  8007c1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007c4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007c7:	50                   	push   %eax
  8007c8:	ff 75 10             	pushl  0x10(%ebp)
  8007cb:	ff 75 0c             	pushl  0xc(%ebp)
  8007ce:	ff 75 08             	pushl  0x8(%ebp)
  8007d1:	e8 9a ff ff ff       	call   800770 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007d6:	c9                   	leave  
  8007d7:	c3                   	ret    

008007d8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007de:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e3:	eb 03                	jmp    8007e8 <strlen+0x10>
		n++;
  8007e5:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007e8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ec:	75 f7                	jne    8007e5 <strlen+0xd>
	return n;
}
  8007ee:	5d                   	pop    %ebp
  8007ef:	c3                   	ret    

008007f0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8007fe:	eb 03                	jmp    800803 <strnlen+0x13>
		n++;
  800800:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800803:	39 d0                	cmp    %edx,%eax
  800805:	74 06                	je     80080d <strnlen+0x1d>
  800807:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80080b:	75 f3                	jne    800800 <strnlen+0x10>
	return n;
}
  80080d:	5d                   	pop    %ebp
  80080e:	c3                   	ret    

0080080f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80080f:	55                   	push   %ebp
  800810:	89 e5                	mov    %esp,%ebp
  800812:	53                   	push   %ebx
  800813:	8b 45 08             	mov    0x8(%ebp),%eax
  800816:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800819:	89 c2                	mov    %eax,%edx
  80081b:	83 c1 01             	add    $0x1,%ecx
  80081e:	83 c2 01             	add    $0x1,%edx
  800821:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800825:	88 5a ff             	mov    %bl,-0x1(%edx)
  800828:	84 db                	test   %bl,%bl
  80082a:	75 ef                	jne    80081b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80082c:	5b                   	pop    %ebx
  80082d:	5d                   	pop    %ebp
  80082e:	c3                   	ret    

0080082f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80082f:	55                   	push   %ebp
  800830:	89 e5                	mov    %esp,%ebp
  800832:	53                   	push   %ebx
  800833:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800836:	53                   	push   %ebx
  800837:	e8 9c ff ff ff       	call   8007d8 <strlen>
  80083c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80083f:	ff 75 0c             	pushl  0xc(%ebp)
  800842:	01 d8                	add    %ebx,%eax
  800844:	50                   	push   %eax
  800845:	e8 c5 ff ff ff       	call   80080f <strcpy>
	return dst;
}
  80084a:	89 d8                	mov    %ebx,%eax
  80084c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80084f:	c9                   	leave  
  800850:	c3                   	ret    

00800851 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	56                   	push   %esi
  800855:	53                   	push   %ebx
  800856:	8b 75 08             	mov    0x8(%ebp),%esi
  800859:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80085c:	89 f3                	mov    %esi,%ebx
  80085e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800861:	89 f2                	mov    %esi,%edx
  800863:	eb 0f                	jmp    800874 <strncpy+0x23>
		*dst++ = *src;
  800865:	83 c2 01             	add    $0x1,%edx
  800868:	0f b6 01             	movzbl (%ecx),%eax
  80086b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80086e:	80 39 01             	cmpb   $0x1,(%ecx)
  800871:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800874:	39 da                	cmp    %ebx,%edx
  800876:	75 ed                	jne    800865 <strncpy+0x14>
	}
	return ret;
}
  800878:	89 f0                	mov    %esi,%eax
  80087a:	5b                   	pop    %ebx
  80087b:	5e                   	pop    %esi
  80087c:	5d                   	pop    %ebp
  80087d:	c3                   	ret    

0080087e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
  800881:	56                   	push   %esi
  800882:	53                   	push   %ebx
  800883:	8b 75 08             	mov    0x8(%ebp),%esi
  800886:	8b 55 0c             	mov    0xc(%ebp),%edx
  800889:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80088c:	89 f0                	mov    %esi,%eax
  80088e:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800892:	85 c9                	test   %ecx,%ecx
  800894:	75 0b                	jne    8008a1 <strlcpy+0x23>
  800896:	eb 17                	jmp    8008af <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800898:	83 c2 01             	add    $0x1,%edx
  80089b:	83 c0 01             	add    $0x1,%eax
  80089e:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8008a1:	39 d8                	cmp    %ebx,%eax
  8008a3:	74 07                	je     8008ac <strlcpy+0x2e>
  8008a5:	0f b6 0a             	movzbl (%edx),%ecx
  8008a8:	84 c9                	test   %cl,%cl
  8008aa:	75 ec                	jne    800898 <strlcpy+0x1a>
		*dst = '\0';
  8008ac:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008af:	29 f0                	sub    %esi,%eax
}
  8008b1:	5b                   	pop    %ebx
  8008b2:	5e                   	pop    %esi
  8008b3:	5d                   	pop    %ebp
  8008b4:	c3                   	ret    

008008b5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008b5:	55                   	push   %ebp
  8008b6:	89 e5                	mov    %esp,%ebp
  8008b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008bb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008be:	eb 06                	jmp    8008c6 <strcmp+0x11>
		p++, q++;
  8008c0:	83 c1 01             	add    $0x1,%ecx
  8008c3:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008c6:	0f b6 01             	movzbl (%ecx),%eax
  8008c9:	84 c0                	test   %al,%al
  8008cb:	74 04                	je     8008d1 <strcmp+0x1c>
  8008cd:	3a 02                	cmp    (%edx),%al
  8008cf:	74 ef                	je     8008c0 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d1:	0f b6 c0             	movzbl %al,%eax
  8008d4:	0f b6 12             	movzbl (%edx),%edx
  8008d7:	29 d0                	sub    %edx,%eax
}
  8008d9:	5d                   	pop    %ebp
  8008da:	c3                   	ret    

008008db <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	53                   	push   %ebx
  8008df:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e5:	89 c3                	mov    %eax,%ebx
  8008e7:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008ea:	eb 06                	jmp    8008f2 <strncmp+0x17>
		n--, p++, q++;
  8008ec:	83 c0 01             	add    $0x1,%eax
  8008ef:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008f2:	39 d8                	cmp    %ebx,%eax
  8008f4:	74 16                	je     80090c <strncmp+0x31>
  8008f6:	0f b6 08             	movzbl (%eax),%ecx
  8008f9:	84 c9                	test   %cl,%cl
  8008fb:	74 04                	je     800901 <strncmp+0x26>
  8008fd:	3a 0a                	cmp    (%edx),%cl
  8008ff:	74 eb                	je     8008ec <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800901:	0f b6 00             	movzbl (%eax),%eax
  800904:	0f b6 12             	movzbl (%edx),%edx
  800907:	29 d0                	sub    %edx,%eax
}
  800909:	5b                   	pop    %ebx
  80090a:	5d                   	pop    %ebp
  80090b:	c3                   	ret    
		return 0;
  80090c:	b8 00 00 00 00       	mov    $0x0,%eax
  800911:	eb f6                	jmp    800909 <strncmp+0x2e>

00800913 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800913:	55                   	push   %ebp
  800914:	89 e5                	mov    %esp,%ebp
  800916:	8b 45 08             	mov    0x8(%ebp),%eax
  800919:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80091d:	0f b6 10             	movzbl (%eax),%edx
  800920:	84 d2                	test   %dl,%dl
  800922:	74 09                	je     80092d <strchr+0x1a>
		if (*s == c)
  800924:	38 ca                	cmp    %cl,%dl
  800926:	74 0a                	je     800932 <strchr+0x1f>
	for (; *s; s++)
  800928:	83 c0 01             	add    $0x1,%eax
  80092b:	eb f0                	jmp    80091d <strchr+0xa>
			return (char *) s;
	return 0;
  80092d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800932:	5d                   	pop    %ebp
  800933:	c3                   	ret    

00800934 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	8b 45 08             	mov    0x8(%ebp),%eax
  80093a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80093e:	eb 03                	jmp    800943 <strfind+0xf>
  800940:	83 c0 01             	add    $0x1,%eax
  800943:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800946:	38 ca                	cmp    %cl,%dl
  800948:	74 04                	je     80094e <strfind+0x1a>
  80094a:	84 d2                	test   %dl,%dl
  80094c:	75 f2                	jne    800940 <strfind+0xc>
			break;
	return (char *) s;
}
  80094e:	5d                   	pop    %ebp
  80094f:	c3                   	ret    

00800950 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800950:	55                   	push   %ebp
  800951:	89 e5                	mov    %esp,%ebp
  800953:	57                   	push   %edi
  800954:	56                   	push   %esi
  800955:	53                   	push   %ebx
  800956:	8b 7d 08             	mov    0x8(%ebp),%edi
  800959:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80095c:	85 c9                	test   %ecx,%ecx
  80095e:	74 13                	je     800973 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800960:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800966:	75 05                	jne    80096d <memset+0x1d>
  800968:	f6 c1 03             	test   $0x3,%cl
  80096b:	74 0d                	je     80097a <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80096d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800970:	fc                   	cld    
  800971:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800973:	89 f8                	mov    %edi,%eax
  800975:	5b                   	pop    %ebx
  800976:	5e                   	pop    %esi
  800977:	5f                   	pop    %edi
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    
		c &= 0xFF;
  80097a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80097e:	89 d3                	mov    %edx,%ebx
  800980:	c1 e3 08             	shl    $0x8,%ebx
  800983:	89 d0                	mov    %edx,%eax
  800985:	c1 e0 18             	shl    $0x18,%eax
  800988:	89 d6                	mov    %edx,%esi
  80098a:	c1 e6 10             	shl    $0x10,%esi
  80098d:	09 f0                	or     %esi,%eax
  80098f:	09 c2                	or     %eax,%edx
  800991:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800993:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800996:	89 d0                	mov    %edx,%eax
  800998:	fc                   	cld    
  800999:	f3 ab                	rep stos %eax,%es:(%edi)
  80099b:	eb d6                	jmp    800973 <memset+0x23>

0080099d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80099d:	55                   	push   %ebp
  80099e:	89 e5                	mov    %esp,%ebp
  8009a0:	57                   	push   %edi
  8009a1:	56                   	push   %esi
  8009a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009a8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009ab:	39 c6                	cmp    %eax,%esi
  8009ad:	73 35                	jae    8009e4 <memmove+0x47>
  8009af:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009b2:	39 c2                	cmp    %eax,%edx
  8009b4:	76 2e                	jbe    8009e4 <memmove+0x47>
		s += n;
		d += n;
  8009b6:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b9:	89 d6                	mov    %edx,%esi
  8009bb:	09 fe                	or     %edi,%esi
  8009bd:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009c3:	74 0c                	je     8009d1 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009c5:	83 ef 01             	sub    $0x1,%edi
  8009c8:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009cb:	fd                   	std    
  8009cc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ce:	fc                   	cld    
  8009cf:	eb 21                	jmp    8009f2 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d1:	f6 c1 03             	test   $0x3,%cl
  8009d4:	75 ef                	jne    8009c5 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009d6:	83 ef 04             	sub    $0x4,%edi
  8009d9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009dc:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009df:	fd                   	std    
  8009e0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e2:	eb ea                	jmp    8009ce <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e4:	89 f2                	mov    %esi,%edx
  8009e6:	09 c2                	or     %eax,%edx
  8009e8:	f6 c2 03             	test   $0x3,%dl
  8009eb:	74 09                	je     8009f6 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009ed:	89 c7                	mov    %eax,%edi
  8009ef:	fc                   	cld    
  8009f0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009f2:	5e                   	pop    %esi
  8009f3:	5f                   	pop    %edi
  8009f4:	5d                   	pop    %ebp
  8009f5:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f6:	f6 c1 03             	test   $0x3,%cl
  8009f9:	75 f2                	jne    8009ed <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009fb:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009fe:	89 c7                	mov    %eax,%edi
  800a00:	fc                   	cld    
  800a01:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a03:	eb ed                	jmp    8009f2 <memmove+0x55>

00800a05 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a05:	55                   	push   %ebp
  800a06:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a08:	ff 75 10             	pushl  0x10(%ebp)
  800a0b:	ff 75 0c             	pushl  0xc(%ebp)
  800a0e:	ff 75 08             	pushl  0x8(%ebp)
  800a11:	e8 87 ff ff ff       	call   80099d <memmove>
}
  800a16:	c9                   	leave  
  800a17:	c3                   	ret    

00800a18 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a18:	55                   	push   %ebp
  800a19:	89 e5                	mov    %esp,%ebp
  800a1b:	56                   	push   %esi
  800a1c:	53                   	push   %ebx
  800a1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a20:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a23:	89 c6                	mov    %eax,%esi
  800a25:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a28:	39 f0                	cmp    %esi,%eax
  800a2a:	74 1c                	je     800a48 <memcmp+0x30>
		if (*s1 != *s2)
  800a2c:	0f b6 08             	movzbl (%eax),%ecx
  800a2f:	0f b6 1a             	movzbl (%edx),%ebx
  800a32:	38 d9                	cmp    %bl,%cl
  800a34:	75 08                	jne    800a3e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a36:	83 c0 01             	add    $0x1,%eax
  800a39:	83 c2 01             	add    $0x1,%edx
  800a3c:	eb ea                	jmp    800a28 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a3e:	0f b6 c1             	movzbl %cl,%eax
  800a41:	0f b6 db             	movzbl %bl,%ebx
  800a44:	29 d8                	sub    %ebx,%eax
  800a46:	eb 05                	jmp    800a4d <memcmp+0x35>
	}

	return 0;
  800a48:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a4d:	5b                   	pop    %ebx
  800a4e:	5e                   	pop    %esi
  800a4f:	5d                   	pop    %ebp
  800a50:	c3                   	ret    

00800a51 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a51:	55                   	push   %ebp
  800a52:	89 e5                	mov    %esp,%ebp
  800a54:	8b 45 08             	mov    0x8(%ebp),%eax
  800a57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a5a:	89 c2                	mov    %eax,%edx
  800a5c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a5f:	39 d0                	cmp    %edx,%eax
  800a61:	73 09                	jae    800a6c <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a63:	38 08                	cmp    %cl,(%eax)
  800a65:	74 05                	je     800a6c <memfind+0x1b>
	for (; s < ends; s++)
  800a67:	83 c0 01             	add    $0x1,%eax
  800a6a:	eb f3                	jmp    800a5f <memfind+0xe>
			break;
	return (void *) s;
}
  800a6c:	5d                   	pop    %ebp
  800a6d:	c3                   	ret    

00800a6e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a6e:	55                   	push   %ebp
  800a6f:	89 e5                	mov    %esp,%ebp
  800a71:	57                   	push   %edi
  800a72:	56                   	push   %esi
  800a73:	53                   	push   %ebx
  800a74:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a77:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a7a:	eb 03                	jmp    800a7f <strtol+0x11>
		s++;
  800a7c:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a7f:	0f b6 01             	movzbl (%ecx),%eax
  800a82:	3c 20                	cmp    $0x20,%al
  800a84:	74 f6                	je     800a7c <strtol+0xe>
  800a86:	3c 09                	cmp    $0x9,%al
  800a88:	74 f2                	je     800a7c <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a8a:	3c 2b                	cmp    $0x2b,%al
  800a8c:	74 2e                	je     800abc <strtol+0x4e>
	int neg = 0;
  800a8e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a93:	3c 2d                	cmp    $0x2d,%al
  800a95:	74 2f                	je     800ac6 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a97:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a9d:	75 05                	jne    800aa4 <strtol+0x36>
  800a9f:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa2:	74 2c                	je     800ad0 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aa4:	85 db                	test   %ebx,%ebx
  800aa6:	75 0a                	jne    800ab2 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aa8:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800aad:	80 39 30             	cmpb   $0x30,(%ecx)
  800ab0:	74 28                	je     800ada <strtol+0x6c>
		base = 10;
  800ab2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab7:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800aba:	eb 50                	jmp    800b0c <strtol+0x9e>
		s++;
  800abc:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800abf:	bf 00 00 00 00       	mov    $0x0,%edi
  800ac4:	eb d1                	jmp    800a97 <strtol+0x29>
		s++, neg = 1;
  800ac6:	83 c1 01             	add    $0x1,%ecx
  800ac9:	bf 01 00 00 00       	mov    $0x1,%edi
  800ace:	eb c7                	jmp    800a97 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ad0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ad4:	74 0e                	je     800ae4 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800ad6:	85 db                	test   %ebx,%ebx
  800ad8:	75 d8                	jne    800ab2 <strtol+0x44>
		s++, base = 8;
  800ada:	83 c1 01             	add    $0x1,%ecx
  800add:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ae2:	eb ce                	jmp    800ab2 <strtol+0x44>
		s += 2, base = 16;
  800ae4:	83 c1 02             	add    $0x2,%ecx
  800ae7:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aec:	eb c4                	jmp    800ab2 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800aee:	8d 72 9f             	lea    -0x61(%edx),%esi
  800af1:	89 f3                	mov    %esi,%ebx
  800af3:	80 fb 19             	cmp    $0x19,%bl
  800af6:	77 29                	ja     800b21 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800af8:	0f be d2             	movsbl %dl,%edx
  800afb:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800afe:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b01:	7d 30                	jge    800b33 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b03:	83 c1 01             	add    $0x1,%ecx
  800b06:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b0a:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b0c:	0f b6 11             	movzbl (%ecx),%edx
  800b0f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b12:	89 f3                	mov    %esi,%ebx
  800b14:	80 fb 09             	cmp    $0x9,%bl
  800b17:	77 d5                	ja     800aee <strtol+0x80>
			dig = *s - '0';
  800b19:	0f be d2             	movsbl %dl,%edx
  800b1c:	83 ea 30             	sub    $0x30,%edx
  800b1f:	eb dd                	jmp    800afe <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800b21:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b24:	89 f3                	mov    %esi,%ebx
  800b26:	80 fb 19             	cmp    $0x19,%bl
  800b29:	77 08                	ja     800b33 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b2b:	0f be d2             	movsbl %dl,%edx
  800b2e:	83 ea 37             	sub    $0x37,%edx
  800b31:	eb cb                	jmp    800afe <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b33:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b37:	74 05                	je     800b3e <strtol+0xd0>
		*endptr = (char *) s;
  800b39:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b3c:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b3e:	89 c2                	mov    %eax,%edx
  800b40:	f7 da                	neg    %edx
  800b42:	85 ff                	test   %edi,%edi
  800b44:	0f 45 c2             	cmovne %edx,%eax
}
  800b47:	5b                   	pop    %ebx
  800b48:	5e                   	pop    %esi
  800b49:	5f                   	pop    %edi
  800b4a:	5d                   	pop    %ebp
  800b4b:	c3                   	ret    

00800b4c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b4c:	55                   	push   %ebp
  800b4d:	89 e5                	mov    %esp,%ebp
  800b4f:	57                   	push   %edi
  800b50:	56                   	push   %esi
  800b51:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b52:	b8 00 00 00 00       	mov    $0x0,%eax
  800b57:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b5d:	89 c3                	mov    %eax,%ebx
  800b5f:	89 c7                	mov    %eax,%edi
  800b61:	89 c6                	mov    %eax,%esi
  800b63:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b65:	5b                   	pop    %ebx
  800b66:	5e                   	pop    %esi
  800b67:	5f                   	pop    %edi
  800b68:	5d                   	pop    %ebp
  800b69:	c3                   	ret    

00800b6a <sys_cgetc>:

int
sys_cgetc(void)
{
  800b6a:	55                   	push   %ebp
  800b6b:	89 e5                	mov    %esp,%ebp
  800b6d:	57                   	push   %edi
  800b6e:	56                   	push   %esi
  800b6f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b70:	ba 00 00 00 00       	mov    $0x0,%edx
  800b75:	b8 01 00 00 00       	mov    $0x1,%eax
  800b7a:	89 d1                	mov    %edx,%ecx
  800b7c:	89 d3                	mov    %edx,%ebx
  800b7e:	89 d7                	mov    %edx,%edi
  800b80:	89 d6                	mov    %edx,%esi
  800b82:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b84:	5b                   	pop    %ebx
  800b85:	5e                   	pop    %esi
  800b86:	5f                   	pop    %edi
  800b87:	5d                   	pop    %ebp
  800b88:	c3                   	ret    

00800b89 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b89:	55                   	push   %ebp
  800b8a:	89 e5                	mov    %esp,%ebp
  800b8c:	57                   	push   %edi
  800b8d:	56                   	push   %esi
  800b8e:	53                   	push   %ebx
  800b8f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b92:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b97:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9a:	b8 03 00 00 00       	mov    $0x3,%eax
  800b9f:	89 cb                	mov    %ecx,%ebx
  800ba1:	89 cf                	mov    %ecx,%edi
  800ba3:	89 ce                	mov    %ecx,%esi
  800ba5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ba7:	85 c0                	test   %eax,%eax
  800ba9:	7f 08                	jg     800bb3 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bae:	5b                   	pop    %ebx
  800baf:	5e                   	pop    %esi
  800bb0:	5f                   	pop    %edi
  800bb1:	5d                   	pop    %ebp
  800bb2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb3:	83 ec 0c             	sub    $0xc,%esp
  800bb6:	50                   	push   %eax
  800bb7:	6a 03                	push   $0x3
  800bb9:	68 5f 22 80 00       	push   $0x80225f
  800bbe:	6a 23                	push   $0x23
  800bc0:	68 7c 22 80 00       	push   $0x80227c
  800bc5:	e8 4b f5 ff ff       	call   800115 <_panic>

00800bca <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bca:	55                   	push   %ebp
  800bcb:	89 e5                	mov    %esp,%ebp
  800bcd:	57                   	push   %edi
  800bce:	56                   	push   %esi
  800bcf:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bd0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd5:	b8 02 00 00 00       	mov    $0x2,%eax
  800bda:	89 d1                	mov    %edx,%ecx
  800bdc:	89 d3                	mov    %edx,%ebx
  800bde:	89 d7                	mov    %edx,%edi
  800be0:	89 d6                	mov    %edx,%esi
  800be2:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800be4:	5b                   	pop    %ebx
  800be5:	5e                   	pop    %esi
  800be6:	5f                   	pop    %edi
  800be7:	5d                   	pop    %ebp
  800be8:	c3                   	ret    

00800be9 <sys_yield>:

void
sys_yield(void)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	57                   	push   %edi
  800bed:	56                   	push   %esi
  800bee:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bef:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf4:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bf9:	89 d1                	mov    %edx,%ecx
  800bfb:	89 d3                	mov    %edx,%ebx
  800bfd:	89 d7                	mov    %edx,%edi
  800bff:	89 d6                	mov    %edx,%esi
  800c01:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c03:	5b                   	pop    %ebx
  800c04:	5e                   	pop    %esi
  800c05:	5f                   	pop    %edi
  800c06:	5d                   	pop    %ebp
  800c07:	c3                   	ret    

00800c08 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	57                   	push   %edi
  800c0c:	56                   	push   %esi
  800c0d:	53                   	push   %ebx
  800c0e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c11:	be 00 00 00 00       	mov    $0x0,%esi
  800c16:	8b 55 08             	mov    0x8(%ebp),%edx
  800c19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1c:	b8 04 00 00 00       	mov    $0x4,%eax
  800c21:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c24:	89 f7                	mov    %esi,%edi
  800c26:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c28:	85 c0                	test   %eax,%eax
  800c2a:	7f 08                	jg     800c34 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2f:	5b                   	pop    %ebx
  800c30:	5e                   	pop    %esi
  800c31:	5f                   	pop    %edi
  800c32:	5d                   	pop    %ebp
  800c33:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c34:	83 ec 0c             	sub    $0xc,%esp
  800c37:	50                   	push   %eax
  800c38:	6a 04                	push   $0x4
  800c3a:	68 5f 22 80 00       	push   $0x80225f
  800c3f:	6a 23                	push   $0x23
  800c41:	68 7c 22 80 00       	push   $0x80227c
  800c46:	e8 ca f4 ff ff       	call   800115 <_panic>

00800c4b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	57                   	push   %edi
  800c4f:	56                   	push   %esi
  800c50:	53                   	push   %ebx
  800c51:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c54:	8b 55 08             	mov    0x8(%ebp),%edx
  800c57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5a:	b8 05 00 00 00       	mov    $0x5,%eax
  800c5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c62:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c65:	8b 75 18             	mov    0x18(%ebp),%esi
  800c68:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c6a:	85 c0                	test   %eax,%eax
  800c6c:	7f 08                	jg     800c76 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c71:	5b                   	pop    %ebx
  800c72:	5e                   	pop    %esi
  800c73:	5f                   	pop    %edi
  800c74:	5d                   	pop    %ebp
  800c75:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c76:	83 ec 0c             	sub    $0xc,%esp
  800c79:	50                   	push   %eax
  800c7a:	6a 05                	push   $0x5
  800c7c:	68 5f 22 80 00       	push   $0x80225f
  800c81:	6a 23                	push   $0x23
  800c83:	68 7c 22 80 00       	push   $0x80227c
  800c88:	e8 88 f4 ff ff       	call   800115 <_panic>

00800c8d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c8d:	55                   	push   %ebp
  800c8e:	89 e5                	mov    %esp,%ebp
  800c90:	57                   	push   %edi
  800c91:	56                   	push   %esi
  800c92:	53                   	push   %ebx
  800c93:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c96:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca1:	b8 06 00 00 00       	mov    $0x6,%eax
  800ca6:	89 df                	mov    %ebx,%edi
  800ca8:	89 de                	mov    %ebx,%esi
  800caa:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cac:	85 c0                	test   %eax,%eax
  800cae:	7f 08                	jg     800cb8 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cb0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb3:	5b                   	pop    %ebx
  800cb4:	5e                   	pop    %esi
  800cb5:	5f                   	pop    %edi
  800cb6:	5d                   	pop    %ebp
  800cb7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb8:	83 ec 0c             	sub    $0xc,%esp
  800cbb:	50                   	push   %eax
  800cbc:	6a 06                	push   $0x6
  800cbe:	68 5f 22 80 00       	push   $0x80225f
  800cc3:	6a 23                	push   $0x23
  800cc5:	68 7c 22 80 00       	push   $0x80227c
  800cca:	e8 46 f4 ff ff       	call   800115 <_panic>

00800ccf <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ccf:	55                   	push   %ebp
  800cd0:	89 e5                	mov    %esp,%ebp
  800cd2:	57                   	push   %edi
  800cd3:	56                   	push   %esi
  800cd4:	53                   	push   %ebx
  800cd5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cd8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cdd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce3:	b8 08 00 00 00       	mov    $0x8,%eax
  800ce8:	89 df                	mov    %ebx,%edi
  800cea:	89 de                	mov    %ebx,%esi
  800cec:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cee:	85 c0                	test   %eax,%eax
  800cf0:	7f 08                	jg     800cfa <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cf2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf5:	5b                   	pop    %ebx
  800cf6:	5e                   	pop    %esi
  800cf7:	5f                   	pop    %edi
  800cf8:	5d                   	pop    %ebp
  800cf9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfa:	83 ec 0c             	sub    $0xc,%esp
  800cfd:	50                   	push   %eax
  800cfe:	6a 08                	push   $0x8
  800d00:	68 5f 22 80 00       	push   $0x80225f
  800d05:	6a 23                	push   $0x23
  800d07:	68 7c 22 80 00       	push   $0x80227c
  800d0c:	e8 04 f4 ff ff       	call   800115 <_panic>

00800d11 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d11:	55                   	push   %ebp
  800d12:	89 e5                	mov    %esp,%ebp
  800d14:	57                   	push   %edi
  800d15:	56                   	push   %esi
  800d16:	53                   	push   %ebx
  800d17:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d1a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d25:	b8 09 00 00 00       	mov    $0x9,%eax
  800d2a:	89 df                	mov    %ebx,%edi
  800d2c:	89 de                	mov    %ebx,%esi
  800d2e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d30:	85 c0                	test   %eax,%eax
  800d32:	7f 08                	jg     800d3c <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d37:	5b                   	pop    %ebx
  800d38:	5e                   	pop    %esi
  800d39:	5f                   	pop    %edi
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3c:	83 ec 0c             	sub    $0xc,%esp
  800d3f:	50                   	push   %eax
  800d40:	6a 09                	push   $0x9
  800d42:	68 5f 22 80 00       	push   $0x80225f
  800d47:	6a 23                	push   $0x23
  800d49:	68 7c 22 80 00       	push   $0x80227c
  800d4e:	e8 c2 f3 ff ff       	call   800115 <_panic>

00800d53 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d53:	55                   	push   %ebp
  800d54:	89 e5                	mov    %esp,%ebp
  800d56:	57                   	push   %edi
  800d57:	56                   	push   %esi
  800d58:	53                   	push   %ebx
  800d59:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d5c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d61:	8b 55 08             	mov    0x8(%ebp),%edx
  800d64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d67:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d6c:	89 df                	mov    %ebx,%edi
  800d6e:	89 de                	mov    %ebx,%esi
  800d70:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d72:	85 c0                	test   %eax,%eax
  800d74:	7f 08                	jg     800d7e <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d79:	5b                   	pop    %ebx
  800d7a:	5e                   	pop    %esi
  800d7b:	5f                   	pop    %edi
  800d7c:	5d                   	pop    %ebp
  800d7d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7e:	83 ec 0c             	sub    $0xc,%esp
  800d81:	50                   	push   %eax
  800d82:	6a 0a                	push   $0xa
  800d84:	68 5f 22 80 00       	push   $0x80225f
  800d89:	6a 23                	push   $0x23
  800d8b:	68 7c 22 80 00       	push   $0x80227c
  800d90:	e8 80 f3 ff ff       	call   800115 <_panic>

00800d95 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d95:	55                   	push   %ebp
  800d96:	89 e5                	mov    %esp,%ebp
  800d98:	57                   	push   %edi
  800d99:	56                   	push   %esi
  800d9a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800da6:	be 00 00 00 00       	mov    $0x0,%esi
  800dab:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dae:	8b 7d 14             	mov    0x14(%ebp),%edi
  800db1:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800db3:	5b                   	pop    %ebx
  800db4:	5e                   	pop    %esi
  800db5:	5f                   	pop    %edi
  800db6:	5d                   	pop    %ebp
  800db7:	c3                   	ret    

00800db8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800db8:	55                   	push   %ebp
  800db9:	89 e5                	mov    %esp,%ebp
  800dbb:	57                   	push   %edi
  800dbc:	56                   	push   %esi
  800dbd:	53                   	push   %ebx
  800dbe:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dc1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc9:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dce:	89 cb                	mov    %ecx,%ebx
  800dd0:	89 cf                	mov    %ecx,%edi
  800dd2:	89 ce                	mov    %ecx,%esi
  800dd4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dd6:	85 c0                	test   %eax,%eax
  800dd8:	7f 08                	jg     800de2 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ddd:	5b                   	pop    %ebx
  800dde:	5e                   	pop    %esi
  800ddf:	5f                   	pop    %edi
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800de2:	83 ec 0c             	sub    $0xc,%esp
  800de5:	50                   	push   %eax
  800de6:	6a 0d                	push   $0xd
  800de8:	68 5f 22 80 00       	push   $0x80225f
  800ded:	6a 23                	push   $0x23
  800def:	68 7c 22 80 00       	push   $0x80227c
  800df4:	e8 1c f3 ff ff       	call   800115 <_panic>

00800df9 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800df9:	55                   	push   %ebp
  800dfa:	89 e5                	mov    %esp,%ebp
  800dfc:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800dff:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800e06:	74 0a                	je     800e12 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler %e",r);
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
	}
       
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e08:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0b:	a3 08 40 80 00       	mov    %eax,0x804008
}
  800e10:	c9                   	leave  
  800e11:	c3                   	ret    
		if((r=sys_page_alloc(thisenv->env_id,(void *)UXSTACKTOP-PGSIZE,PTE_P|PTE_W|PTE_U))<0)
  800e12:	a1 04 40 80 00       	mov    0x804004,%eax
  800e17:	8b 40 48             	mov    0x48(%eax),%eax
  800e1a:	83 ec 04             	sub    $0x4,%esp
  800e1d:	6a 07                	push   $0x7
  800e1f:	68 00 f0 bf ee       	push   $0xeebff000
  800e24:	50                   	push   %eax
  800e25:	e8 de fd ff ff       	call   800c08 <sys_page_alloc>
  800e2a:	83 c4 10             	add    $0x10,%esp
  800e2d:	85 c0                	test   %eax,%eax
  800e2f:	78 1b                	js     800e4c <set_pgfault_handler+0x53>
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
  800e31:	a1 04 40 80 00       	mov    0x804004,%eax
  800e36:	8b 40 48             	mov    0x48(%eax),%eax
  800e39:	83 ec 08             	sub    $0x8,%esp
  800e3c:	68 5e 0e 80 00       	push   $0x800e5e
  800e41:	50                   	push   %eax
  800e42:	e8 0c ff ff ff       	call   800d53 <sys_env_set_pgfault_upcall>
  800e47:	83 c4 10             	add    $0x10,%esp
  800e4a:	eb bc                	jmp    800e08 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler %e",r);
  800e4c:	50                   	push   %eax
  800e4d:	68 8a 22 80 00       	push   $0x80228a
  800e52:	6a 22                	push   $0x22
  800e54:	68 a1 22 80 00       	push   $0x8022a1
  800e59:	e8 b7 f2 ff ff       	call   800115 <_panic>

00800e5e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e5e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e5f:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800e64:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e66:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 48(%esp), %ebp
  800e69:	8b 6c 24 30          	mov    0x30(%esp),%ebp
        subl $4, %ebp
  800e6d:	83 ed 04             	sub    $0x4,%ebp
        movl %ebp, 48(%esp)
  800e70:	89 6c 24 30          	mov    %ebp,0x30(%esp)
        movl 40(%esp), %eax
  800e74:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl %eax, (%ebp)
  800e78:	89 45 00             	mov    %eax,0x0(%ebp)
	// Restore the trap-time registers.  After you do this, you
 	// can no longer modify any general-purpose registers.
 	// LAB 4: Your code here.
        addl $8, %esp
  800e7b:	83 c4 08             	add    $0x8,%esp
        popal
  800e7e:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $4, %esp
  800e7f:	83 c4 04             	add    $0x4,%esp
        popfl
  800e82:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  800e83:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  800e84:	c3                   	ret    

00800e85 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e85:	55                   	push   %ebp
  800e86:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e88:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8b:	05 00 00 00 30       	add    $0x30000000,%eax
  800e90:	c1 e8 0c             	shr    $0xc,%eax
}
  800e93:	5d                   	pop    %ebp
  800e94:	c3                   	ret    

00800e95 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e95:	55                   	push   %ebp
  800e96:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e98:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9b:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800ea0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ea5:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800eaa:	5d                   	pop    %ebp
  800eab:	c3                   	ret    

00800eac <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eb2:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800eb7:	89 c2                	mov    %eax,%edx
  800eb9:	c1 ea 16             	shr    $0x16,%edx
  800ebc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ec3:	f6 c2 01             	test   $0x1,%dl
  800ec6:	74 2a                	je     800ef2 <fd_alloc+0x46>
  800ec8:	89 c2                	mov    %eax,%edx
  800eca:	c1 ea 0c             	shr    $0xc,%edx
  800ecd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ed4:	f6 c2 01             	test   $0x1,%dl
  800ed7:	74 19                	je     800ef2 <fd_alloc+0x46>
  800ed9:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800ede:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ee3:	75 d2                	jne    800eb7 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ee5:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800eeb:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800ef0:	eb 07                	jmp    800ef9 <fd_alloc+0x4d>
			*fd_store = fd;
  800ef2:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ef4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ef9:	5d                   	pop    %ebp
  800efa:	c3                   	ret    

00800efb <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
  800efe:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f01:	83 f8 1f             	cmp    $0x1f,%eax
  800f04:	77 36                	ja     800f3c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f06:	c1 e0 0c             	shl    $0xc,%eax
  800f09:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f0e:	89 c2                	mov    %eax,%edx
  800f10:	c1 ea 16             	shr    $0x16,%edx
  800f13:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f1a:	f6 c2 01             	test   $0x1,%dl
  800f1d:	74 24                	je     800f43 <fd_lookup+0x48>
  800f1f:	89 c2                	mov    %eax,%edx
  800f21:	c1 ea 0c             	shr    $0xc,%edx
  800f24:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f2b:	f6 c2 01             	test   $0x1,%dl
  800f2e:	74 1a                	je     800f4a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f30:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f33:	89 02                	mov    %eax,(%edx)
	return 0;
  800f35:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f3a:	5d                   	pop    %ebp
  800f3b:	c3                   	ret    
		return -E_INVAL;
  800f3c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f41:	eb f7                	jmp    800f3a <fd_lookup+0x3f>
		return -E_INVAL;
  800f43:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f48:	eb f0                	jmp    800f3a <fd_lookup+0x3f>
  800f4a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f4f:	eb e9                	jmp    800f3a <fd_lookup+0x3f>

00800f51 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f51:	55                   	push   %ebp
  800f52:	89 e5                	mov    %esp,%ebp
  800f54:	83 ec 08             	sub    $0x8,%esp
  800f57:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f5a:	ba 30 23 80 00       	mov    $0x802330,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f5f:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800f64:	39 08                	cmp    %ecx,(%eax)
  800f66:	74 33                	je     800f9b <dev_lookup+0x4a>
  800f68:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800f6b:	8b 02                	mov    (%edx),%eax
  800f6d:	85 c0                	test   %eax,%eax
  800f6f:	75 f3                	jne    800f64 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f71:	a1 04 40 80 00       	mov    0x804004,%eax
  800f76:	8b 40 48             	mov    0x48(%eax),%eax
  800f79:	83 ec 04             	sub    $0x4,%esp
  800f7c:	51                   	push   %ecx
  800f7d:	50                   	push   %eax
  800f7e:	68 b0 22 80 00       	push   $0x8022b0
  800f83:	e8 68 f2 ff ff       	call   8001f0 <cprintf>
	*dev = 0;
  800f88:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f8b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f91:	83 c4 10             	add    $0x10,%esp
  800f94:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f99:	c9                   	leave  
  800f9a:	c3                   	ret    
			*dev = devtab[i];
  800f9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f9e:	89 01                	mov    %eax,(%ecx)
			return 0;
  800fa0:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa5:	eb f2                	jmp    800f99 <dev_lookup+0x48>

00800fa7 <fd_close>:
{
  800fa7:	55                   	push   %ebp
  800fa8:	89 e5                	mov    %esp,%ebp
  800faa:	57                   	push   %edi
  800fab:	56                   	push   %esi
  800fac:	53                   	push   %ebx
  800fad:	83 ec 1c             	sub    $0x1c,%esp
  800fb0:	8b 75 08             	mov    0x8(%ebp),%esi
  800fb3:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fb6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fb9:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fba:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fc0:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fc3:	50                   	push   %eax
  800fc4:	e8 32 ff ff ff       	call   800efb <fd_lookup>
  800fc9:	89 c3                	mov    %eax,%ebx
  800fcb:	83 c4 08             	add    $0x8,%esp
  800fce:	85 c0                	test   %eax,%eax
  800fd0:	78 05                	js     800fd7 <fd_close+0x30>
	    || fd != fd2)
  800fd2:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800fd5:	74 16                	je     800fed <fd_close+0x46>
		return (must_exist ? r : 0);
  800fd7:	89 f8                	mov    %edi,%eax
  800fd9:	84 c0                	test   %al,%al
  800fdb:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe0:	0f 44 d8             	cmove  %eax,%ebx
}
  800fe3:	89 d8                	mov    %ebx,%eax
  800fe5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fe8:	5b                   	pop    %ebx
  800fe9:	5e                   	pop    %esi
  800fea:	5f                   	pop    %edi
  800feb:	5d                   	pop    %ebp
  800fec:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fed:	83 ec 08             	sub    $0x8,%esp
  800ff0:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800ff3:	50                   	push   %eax
  800ff4:	ff 36                	pushl  (%esi)
  800ff6:	e8 56 ff ff ff       	call   800f51 <dev_lookup>
  800ffb:	89 c3                	mov    %eax,%ebx
  800ffd:	83 c4 10             	add    $0x10,%esp
  801000:	85 c0                	test   %eax,%eax
  801002:	78 15                	js     801019 <fd_close+0x72>
		if (dev->dev_close)
  801004:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801007:	8b 40 10             	mov    0x10(%eax),%eax
  80100a:	85 c0                	test   %eax,%eax
  80100c:	74 1b                	je     801029 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  80100e:	83 ec 0c             	sub    $0xc,%esp
  801011:	56                   	push   %esi
  801012:	ff d0                	call   *%eax
  801014:	89 c3                	mov    %eax,%ebx
  801016:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801019:	83 ec 08             	sub    $0x8,%esp
  80101c:	56                   	push   %esi
  80101d:	6a 00                	push   $0x0
  80101f:	e8 69 fc ff ff       	call   800c8d <sys_page_unmap>
	return r;
  801024:	83 c4 10             	add    $0x10,%esp
  801027:	eb ba                	jmp    800fe3 <fd_close+0x3c>
			r = 0;
  801029:	bb 00 00 00 00       	mov    $0x0,%ebx
  80102e:	eb e9                	jmp    801019 <fd_close+0x72>

00801030 <close>:

int
close(int fdnum)
{
  801030:	55                   	push   %ebp
  801031:	89 e5                	mov    %esp,%ebp
  801033:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801036:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801039:	50                   	push   %eax
  80103a:	ff 75 08             	pushl  0x8(%ebp)
  80103d:	e8 b9 fe ff ff       	call   800efb <fd_lookup>
  801042:	83 c4 08             	add    $0x8,%esp
  801045:	85 c0                	test   %eax,%eax
  801047:	78 10                	js     801059 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801049:	83 ec 08             	sub    $0x8,%esp
  80104c:	6a 01                	push   $0x1
  80104e:	ff 75 f4             	pushl  -0xc(%ebp)
  801051:	e8 51 ff ff ff       	call   800fa7 <fd_close>
  801056:	83 c4 10             	add    $0x10,%esp
}
  801059:	c9                   	leave  
  80105a:	c3                   	ret    

0080105b <close_all>:

void
close_all(void)
{
  80105b:	55                   	push   %ebp
  80105c:	89 e5                	mov    %esp,%ebp
  80105e:	53                   	push   %ebx
  80105f:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801062:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801067:	83 ec 0c             	sub    $0xc,%esp
  80106a:	53                   	push   %ebx
  80106b:	e8 c0 ff ff ff       	call   801030 <close>
	for (i = 0; i < MAXFD; i++)
  801070:	83 c3 01             	add    $0x1,%ebx
  801073:	83 c4 10             	add    $0x10,%esp
  801076:	83 fb 20             	cmp    $0x20,%ebx
  801079:	75 ec                	jne    801067 <close_all+0xc>
}
  80107b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80107e:	c9                   	leave  
  80107f:	c3                   	ret    

00801080 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801080:	55                   	push   %ebp
  801081:	89 e5                	mov    %esp,%ebp
  801083:	57                   	push   %edi
  801084:	56                   	push   %esi
  801085:	53                   	push   %ebx
  801086:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801089:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80108c:	50                   	push   %eax
  80108d:	ff 75 08             	pushl  0x8(%ebp)
  801090:	e8 66 fe ff ff       	call   800efb <fd_lookup>
  801095:	89 c3                	mov    %eax,%ebx
  801097:	83 c4 08             	add    $0x8,%esp
  80109a:	85 c0                	test   %eax,%eax
  80109c:	0f 88 81 00 00 00    	js     801123 <dup+0xa3>
		return r;
	close(newfdnum);
  8010a2:	83 ec 0c             	sub    $0xc,%esp
  8010a5:	ff 75 0c             	pushl  0xc(%ebp)
  8010a8:	e8 83 ff ff ff       	call   801030 <close>

	newfd = INDEX2FD(newfdnum);
  8010ad:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010b0:	c1 e6 0c             	shl    $0xc,%esi
  8010b3:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8010b9:	83 c4 04             	add    $0x4,%esp
  8010bc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010bf:	e8 d1 fd ff ff       	call   800e95 <fd2data>
  8010c4:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8010c6:	89 34 24             	mov    %esi,(%esp)
  8010c9:	e8 c7 fd ff ff       	call   800e95 <fd2data>
  8010ce:	83 c4 10             	add    $0x10,%esp
  8010d1:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010d3:	89 d8                	mov    %ebx,%eax
  8010d5:	c1 e8 16             	shr    $0x16,%eax
  8010d8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010df:	a8 01                	test   $0x1,%al
  8010e1:	74 11                	je     8010f4 <dup+0x74>
  8010e3:	89 d8                	mov    %ebx,%eax
  8010e5:	c1 e8 0c             	shr    $0xc,%eax
  8010e8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010ef:	f6 c2 01             	test   $0x1,%dl
  8010f2:	75 39                	jne    80112d <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010f4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010f7:	89 d0                	mov    %edx,%eax
  8010f9:	c1 e8 0c             	shr    $0xc,%eax
  8010fc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801103:	83 ec 0c             	sub    $0xc,%esp
  801106:	25 07 0e 00 00       	and    $0xe07,%eax
  80110b:	50                   	push   %eax
  80110c:	56                   	push   %esi
  80110d:	6a 00                	push   $0x0
  80110f:	52                   	push   %edx
  801110:	6a 00                	push   $0x0
  801112:	e8 34 fb ff ff       	call   800c4b <sys_page_map>
  801117:	89 c3                	mov    %eax,%ebx
  801119:	83 c4 20             	add    $0x20,%esp
  80111c:	85 c0                	test   %eax,%eax
  80111e:	78 31                	js     801151 <dup+0xd1>
		goto err;

	return newfdnum;
  801120:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801123:	89 d8                	mov    %ebx,%eax
  801125:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801128:	5b                   	pop    %ebx
  801129:	5e                   	pop    %esi
  80112a:	5f                   	pop    %edi
  80112b:	5d                   	pop    %ebp
  80112c:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80112d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801134:	83 ec 0c             	sub    $0xc,%esp
  801137:	25 07 0e 00 00       	and    $0xe07,%eax
  80113c:	50                   	push   %eax
  80113d:	57                   	push   %edi
  80113e:	6a 00                	push   $0x0
  801140:	53                   	push   %ebx
  801141:	6a 00                	push   $0x0
  801143:	e8 03 fb ff ff       	call   800c4b <sys_page_map>
  801148:	89 c3                	mov    %eax,%ebx
  80114a:	83 c4 20             	add    $0x20,%esp
  80114d:	85 c0                	test   %eax,%eax
  80114f:	79 a3                	jns    8010f4 <dup+0x74>
	sys_page_unmap(0, newfd);
  801151:	83 ec 08             	sub    $0x8,%esp
  801154:	56                   	push   %esi
  801155:	6a 00                	push   $0x0
  801157:	e8 31 fb ff ff       	call   800c8d <sys_page_unmap>
	sys_page_unmap(0, nva);
  80115c:	83 c4 08             	add    $0x8,%esp
  80115f:	57                   	push   %edi
  801160:	6a 00                	push   $0x0
  801162:	e8 26 fb ff ff       	call   800c8d <sys_page_unmap>
	return r;
  801167:	83 c4 10             	add    $0x10,%esp
  80116a:	eb b7                	jmp    801123 <dup+0xa3>

0080116c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80116c:	55                   	push   %ebp
  80116d:	89 e5                	mov    %esp,%ebp
  80116f:	53                   	push   %ebx
  801170:	83 ec 14             	sub    $0x14,%esp
  801173:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801176:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801179:	50                   	push   %eax
  80117a:	53                   	push   %ebx
  80117b:	e8 7b fd ff ff       	call   800efb <fd_lookup>
  801180:	83 c4 08             	add    $0x8,%esp
  801183:	85 c0                	test   %eax,%eax
  801185:	78 3f                	js     8011c6 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801187:	83 ec 08             	sub    $0x8,%esp
  80118a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80118d:	50                   	push   %eax
  80118e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801191:	ff 30                	pushl  (%eax)
  801193:	e8 b9 fd ff ff       	call   800f51 <dev_lookup>
  801198:	83 c4 10             	add    $0x10,%esp
  80119b:	85 c0                	test   %eax,%eax
  80119d:	78 27                	js     8011c6 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80119f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011a2:	8b 42 08             	mov    0x8(%edx),%eax
  8011a5:	83 e0 03             	and    $0x3,%eax
  8011a8:	83 f8 01             	cmp    $0x1,%eax
  8011ab:	74 1e                	je     8011cb <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8011ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011b0:	8b 40 08             	mov    0x8(%eax),%eax
  8011b3:	85 c0                	test   %eax,%eax
  8011b5:	74 35                	je     8011ec <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011b7:	83 ec 04             	sub    $0x4,%esp
  8011ba:	ff 75 10             	pushl  0x10(%ebp)
  8011bd:	ff 75 0c             	pushl  0xc(%ebp)
  8011c0:	52                   	push   %edx
  8011c1:	ff d0                	call   *%eax
  8011c3:	83 c4 10             	add    $0x10,%esp
}
  8011c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011c9:	c9                   	leave  
  8011ca:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011cb:	a1 04 40 80 00       	mov    0x804004,%eax
  8011d0:	8b 40 48             	mov    0x48(%eax),%eax
  8011d3:	83 ec 04             	sub    $0x4,%esp
  8011d6:	53                   	push   %ebx
  8011d7:	50                   	push   %eax
  8011d8:	68 f4 22 80 00       	push   $0x8022f4
  8011dd:	e8 0e f0 ff ff       	call   8001f0 <cprintf>
		return -E_INVAL;
  8011e2:	83 c4 10             	add    $0x10,%esp
  8011e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011ea:	eb da                	jmp    8011c6 <read+0x5a>
		return -E_NOT_SUPP;
  8011ec:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011f1:	eb d3                	jmp    8011c6 <read+0x5a>

008011f3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011f3:	55                   	push   %ebp
  8011f4:	89 e5                	mov    %esp,%ebp
  8011f6:	57                   	push   %edi
  8011f7:	56                   	push   %esi
  8011f8:	53                   	push   %ebx
  8011f9:	83 ec 0c             	sub    $0xc,%esp
  8011fc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011ff:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801202:	bb 00 00 00 00       	mov    $0x0,%ebx
  801207:	39 f3                	cmp    %esi,%ebx
  801209:	73 25                	jae    801230 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80120b:	83 ec 04             	sub    $0x4,%esp
  80120e:	89 f0                	mov    %esi,%eax
  801210:	29 d8                	sub    %ebx,%eax
  801212:	50                   	push   %eax
  801213:	89 d8                	mov    %ebx,%eax
  801215:	03 45 0c             	add    0xc(%ebp),%eax
  801218:	50                   	push   %eax
  801219:	57                   	push   %edi
  80121a:	e8 4d ff ff ff       	call   80116c <read>
		if (m < 0)
  80121f:	83 c4 10             	add    $0x10,%esp
  801222:	85 c0                	test   %eax,%eax
  801224:	78 08                	js     80122e <readn+0x3b>
			return m;
		if (m == 0)
  801226:	85 c0                	test   %eax,%eax
  801228:	74 06                	je     801230 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  80122a:	01 c3                	add    %eax,%ebx
  80122c:	eb d9                	jmp    801207 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80122e:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801230:	89 d8                	mov    %ebx,%eax
  801232:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801235:	5b                   	pop    %ebx
  801236:	5e                   	pop    %esi
  801237:	5f                   	pop    %edi
  801238:	5d                   	pop    %ebp
  801239:	c3                   	ret    

0080123a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80123a:	55                   	push   %ebp
  80123b:	89 e5                	mov    %esp,%ebp
  80123d:	53                   	push   %ebx
  80123e:	83 ec 14             	sub    $0x14,%esp
  801241:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801244:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801247:	50                   	push   %eax
  801248:	53                   	push   %ebx
  801249:	e8 ad fc ff ff       	call   800efb <fd_lookup>
  80124e:	83 c4 08             	add    $0x8,%esp
  801251:	85 c0                	test   %eax,%eax
  801253:	78 3a                	js     80128f <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801255:	83 ec 08             	sub    $0x8,%esp
  801258:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80125b:	50                   	push   %eax
  80125c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80125f:	ff 30                	pushl  (%eax)
  801261:	e8 eb fc ff ff       	call   800f51 <dev_lookup>
  801266:	83 c4 10             	add    $0x10,%esp
  801269:	85 c0                	test   %eax,%eax
  80126b:	78 22                	js     80128f <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80126d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801270:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801274:	74 1e                	je     801294 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801276:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801279:	8b 52 0c             	mov    0xc(%edx),%edx
  80127c:	85 d2                	test   %edx,%edx
  80127e:	74 35                	je     8012b5 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801280:	83 ec 04             	sub    $0x4,%esp
  801283:	ff 75 10             	pushl  0x10(%ebp)
  801286:	ff 75 0c             	pushl  0xc(%ebp)
  801289:	50                   	push   %eax
  80128a:	ff d2                	call   *%edx
  80128c:	83 c4 10             	add    $0x10,%esp
}
  80128f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801292:	c9                   	leave  
  801293:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801294:	a1 04 40 80 00       	mov    0x804004,%eax
  801299:	8b 40 48             	mov    0x48(%eax),%eax
  80129c:	83 ec 04             	sub    $0x4,%esp
  80129f:	53                   	push   %ebx
  8012a0:	50                   	push   %eax
  8012a1:	68 10 23 80 00       	push   $0x802310
  8012a6:	e8 45 ef ff ff       	call   8001f0 <cprintf>
		return -E_INVAL;
  8012ab:	83 c4 10             	add    $0x10,%esp
  8012ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012b3:	eb da                	jmp    80128f <write+0x55>
		return -E_NOT_SUPP;
  8012b5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012ba:	eb d3                	jmp    80128f <write+0x55>

008012bc <seek>:

int
seek(int fdnum, off_t offset)
{
  8012bc:	55                   	push   %ebp
  8012bd:	89 e5                	mov    %esp,%ebp
  8012bf:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012c2:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012c5:	50                   	push   %eax
  8012c6:	ff 75 08             	pushl  0x8(%ebp)
  8012c9:	e8 2d fc ff ff       	call   800efb <fd_lookup>
  8012ce:	83 c4 08             	add    $0x8,%esp
  8012d1:	85 c0                	test   %eax,%eax
  8012d3:	78 0e                	js     8012e3 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012db:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012de:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012e3:	c9                   	leave  
  8012e4:	c3                   	ret    

008012e5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012e5:	55                   	push   %ebp
  8012e6:	89 e5                	mov    %esp,%ebp
  8012e8:	53                   	push   %ebx
  8012e9:	83 ec 14             	sub    $0x14,%esp
  8012ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012f2:	50                   	push   %eax
  8012f3:	53                   	push   %ebx
  8012f4:	e8 02 fc ff ff       	call   800efb <fd_lookup>
  8012f9:	83 c4 08             	add    $0x8,%esp
  8012fc:	85 c0                	test   %eax,%eax
  8012fe:	78 37                	js     801337 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801300:	83 ec 08             	sub    $0x8,%esp
  801303:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801306:	50                   	push   %eax
  801307:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80130a:	ff 30                	pushl  (%eax)
  80130c:	e8 40 fc ff ff       	call   800f51 <dev_lookup>
  801311:	83 c4 10             	add    $0x10,%esp
  801314:	85 c0                	test   %eax,%eax
  801316:	78 1f                	js     801337 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801318:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80131b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80131f:	74 1b                	je     80133c <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801321:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801324:	8b 52 18             	mov    0x18(%edx),%edx
  801327:	85 d2                	test   %edx,%edx
  801329:	74 32                	je     80135d <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80132b:	83 ec 08             	sub    $0x8,%esp
  80132e:	ff 75 0c             	pushl  0xc(%ebp)
  801331:	50                   	push   %eax
  801332:	ff d2                	call   *%edx
  801334:	83 c4 10             	add    $0x10,%esp
}
  801337:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80133a:	c9                   	leave  
  80133b:	c3                   	ret    
			thisenv->env_id, fdnum);
  80133c:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801341:	8b 40 48             	mov    0x48(%eax),%eax
  801344:	83 ec 04             	sub    $0x4,%esp
  801347:	53                   	push   %ebx
  801348:	50                   	push   %eax
  801349:	68 d0 22 80 00       	push   $0x8022d0
  80134e:	e8 9d ee ff ff       	call   8001f0 <cprintf>
		return -E_INVAL;
  801353:	83 c4 10             	add    $0x10,%esp
  801356:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80135b:	eb da                	jmp    801337 <ftruncate+0x52>
		return -E_NOT_SUPP;
  80135d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801362:	eb d3                	jmp    801337 <ftruncate+0x52>

00801364 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801364:	55                   	push   %ebp
  801365:	89 e5                	mov    %esp,%ebp
  801367:	53                   	push   %ebx
  801368:	83 ec 14             	sub    $0x14,%esp
  80136b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80136e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801371:	50                   	push   %eax
  801372:	ff 75 08             	pushl  0x8(%ebp)
  801375:	e8 81 fb ff ff       	call   800efb <fd_lookup>
  80137a:	83 c4 08             	add    $0x8,%esp
  80137d:	85 c0                	test   %eax,%eax
  80137f:	78 4b                	js     8013cc <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801381:	83 ec 08             	sub    $0x8,%esp
  801384:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801387:	50                   	push   %eax
  801388:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80138b:	ff 30                	pushl  (%eax)
  80138d:	e8 bf fb ff ff       	call   800f51 <dev_lookup>
  801392:	83 c4 10             	add    $0x10,%esp
  801395:	85 c0                	test   %eax,%eax
  801397:	78 33                	js     8013cc <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  801399:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80139c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013a0:	74 2f                	je     8013d1 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013a2:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013a5:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013ac:	00 00 00 
	stat->st_isdir = 0;
  8013af:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013b6:	00 00 00 
	stat->st_dev = dev;
  8013b9:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013bf:	83 ec 08             	sub    $0x8,%esp
  8013c2:	53                   	push   %ebx
  8013c3:	ff 75 f0             	pushl  -0x10(%ebp)
  8013c6:	ff 50 14             	call   *0x14(%eax)
  8013c9:	83 c4 10             	add    $0x10,%esp
}
  8013cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013cf:	c9                   	leave  
  8013d0:	c3                   	ret    
		return -E_NOT_SUPP;
  8013d1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013d6:	eb f4                	jmp    8013cc <fstat+0x68>

008013d8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013d8:	55                   	push   %ebp
  8013d9:	89 e5                	mov    %esp,%ebp
  8013db:	56                   	push   %esi
  8013dc:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013dd:	83 ec 08             	sub    $0x8,%esp
  8013e0:	6a 00                	push   $0x0
  8013e2:	ff 75 08             	pushl  0x8(%ebp)
  8013e5:	e8 e7 01 00 00       	call   8015d1 <open>
  8013ea:	89 c3                	mov    %eax,%ebx
  8013ec:	83 c4 10             	add    $0x10,%esp
  8013ef:	85 c0                	test   %eax,%eax
  8013f1:	78 1b                	js     80140e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013f3:	83 ec 08             	sub    $0x8,%esp
  8013f6:	ff 75 0c             	pushl  0xc(%ebp)
  8013f9:	50                   	push   %eax
  8013fa:	e8 65 ff ff ff       	call   801364 <fstat>
  8013ff:	89 c6                	mov    %eax,%esi
	close(fd);
  801401:	89 1c 24             	mov    %ebx,(%esp)
  801404:	e8 27 fc ff ff       	call   801030 <close>
	return r;
  801409:	83 c4 10             	add    $0x10,%esp
  80140c:	89 f3                	mov    %esi,%ebx
}
  80140e:	89 d8                	mov    %ebx,%eax
  801410:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801413:	5b                   	pop    %ebx
  801414:	5e                   	pop    %esi
  801415:	5d                   	pop    %ebp
  801416:	c3                   	ret    

00801417 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801417:	55                   	push   %ebp
  801418:	89 e5                	mov    %esp,%ebp
  80141a:	56                   	push   %esi
  80141b:	53                   	push   %ebx
  80141c:	89 c6                	mov    %eax,%esi
  80141e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801420:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801427:	74 27                	je     801450 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801429:	6a 07                	push   $0x7
  80142b:	68 00 50 80 00       	push   $0x805000
  801430:	56                   	push   %esi
  801431:	ff 35 00 40 80 00    	pushl  0x804000
  801437:	e8 79 07 00 00       	call   801bb5 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80143c:	83 c4 0c             	add    $0xc,%esp
  80143f:	6a 00                	push   $0x0
  801441:	53                   	push   %ebx
  801442:	6a 00                	push   $0x0
  801444:	e8 f7 06 00 00       	call   801b40 <ipc_recv>
}
  801449:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80144c:	5b                   	pop    %ebx
  80144d:	5e                   	pop    %esi
  80144e:	5d                   	pop    %ebp
  80144f:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801450:	83 ec 0c             	sub    $0xc,%esp
  801453:	6a 01                	push   $0x1
  801455:	e8 b1 07 00 00       	call   801c0b <ipc_find_env>
  80145a:	a3 00 40 80 00       	mov    %eax,0x804000
  80145f:	83 c4 10             	add    $0x10,%esp
  801462:	eb c5                	jmp    801429 <fsipc+0x12>

00801464 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801464:	55                   	push   %ebp
  801465:	89 e5                	mov    %esp,%ebp
  801467:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80146a:	8b 45 08             	mov    0x8(%ebp),%eax
  80146d:	8b 40 0c             	mov    0xc(%eax),%eax
  801470:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801475:	8b 45 0c             	mov    0xc(%ebp),%eax
  801478:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80147d:	ba 00 00 00 00       	mov    $0x0,%edx
  801482:	b8 02 00 00 00       	mov    $0x2,%eax
  801487:	e8 8b ff ff ff       	call   801417 <fsipc>
}
  80148c:	c9                   	leave  
  80148d:	c3                   	ret    

0080148e <devfile_flush>:
{
  80148e:	55                   	push   %ebp
  80148f:	89 e5                	mov    %esp,%ebp
  801491:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801494:	8b 45 08             	mov    0x8(%ebp),%eax
  801497:	8b 40 0c             	mov    0xc(%eax),%eax
  80149a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80149f:	ba 00 00 00 00       	mov    $0x0,%edx
  8014a4:	b8 06 00 00 00       	mov    $0x6,%eax
  8014a9:	e8 69 ff ff ff       	call   801417 <fsipc>
}
  8014ae:	c9                   	leave  
  8014af:	c3                   	ret    

008014b0 <devfile_stat>:
{
  8014b0:	55                   	push   %ebp
  8014b1:	89 e5                	mov    %esp,%ebp
  8014b3:	53                   	push   %ebx
  8014b4:	83 ec 04             	sub    $0x4,%esp
  8014b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8014bd:	8b 40 0c             	mov    0xc(%eax),%eax
  8014c0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ca:	b8 05 00 00 00       	mov    $0x5,%eax
  8014cf:	e8 43 ff ff ff       	call   801417 <fsipc>
  8014d4:	85 c0                	test   %eax,%eax
  8014d6:	78 2c                	js     801504 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014d8:	83 ec 08             	sub    $0x8,%esp
  8014db:	68 00 50 80 00       	push   $0x805000
  8014e0:	53                   	push   %ebx
  8014e1:	e8 29 f3 ff ff       	call   80080f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014e6:	a1 80 50 80 00       	mov    0x805080,%eax
  8014eb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014f1:	a1 84 50 80 00       	mov    0x805084,%eax
  8014f6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014fc:	83 c4 10             	add    $0x10,%esp
  8014ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801504:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801507:	c9                   	leave  
  801508:	c3                   	ret    

00801509 <devfile_write>:
{
  801509:	55                   	push   %ebp
  80150a:	89 e5                	mov    %esp,%ebp
  80150c:	83 ec 0c             	sub    $0xc,%esp
  80150f:	8b 45 10             	mov    0x10(%ebp),%eax
  801512:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801517:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80151c:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80151f:	8b 55 08             	mov    0x8(%ebp),%edx
  801522:	8b 52 0c             	mov    0xc(%edx),%edx
  801525:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80152b:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf,buf,n);
  801530:	50                   	push   %eax
  801531:	ff 75 0c             	pushl  0xc(%ebp)
  801534:	68 08 50 80 00       	push   $0x805008
  801539:	e8 5f f4 ff ff       	call   80099d <memmove>
	if((r = fsipc(FSREQ_WRITE,NULL))<0)
  80153e:	ba 00 00 00 00       	mov    $0x0,%edx
  801543:	b8 04 00 00 00       	mov    $0x4,%eax
  801548:	e8 ca fe ff ff       	call   801417 <fsipc>
}
  80154d:	c9                   	leave  
  80154e:	c3                   	ret    

0080154f <devfile_read>:
{
  80154f:	55                   	push   %ebp
  801550:	89 e5                	mov    %esp,%ebp
  801552:	56                   	push   %esi
  801553:	53                   	push   %ebx
  801554:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801557:	8b 45 08             	mov    0x8(%ebp),%eax
  80155a:	8b 40 0c             	mov    0xc(%eax),%eax
  80155d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801562:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801568:	ba 00 00 00 00       	mov    $0x0,%edx
  80156d:	b8 03 00 00 00       	mov    $0x3,%eax
  801572:	e8 a0 fe ff ff       	call   801417 <fsipc>
  801577:	89 c3                	mov    %eax,%ebx
  801579:	85 c0                	test   %eax,%eax
  80157b:	78 1f                	js     80159c <devfile_read+0x4d>
	assert(r <= n);
  80157d:	39 f0                	cmp    %esi,%eax
  80157f:	77 24                	ja     8015a5 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801581:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801586:	7f 33                	jg     8015bb <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801588:	83 ec 04             	sub    $0x4,%esp
  80158b:	50                   	push   %eax
  80158c:	68 00 50 80 00       	push   $0x805000
  801591:	ff 75 0c             	pushl  0xc(%ebp)
  801594:	e8 04 f4 ff ff       	call   80099d <memmove>
	return r;
  801599:	83 c4 10             	add    $0x10,%esp
}
  80159c:	89 d8                	mov    %ebx,%eax
  80159e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015a1:	5b                   	pop    %ebx
  8015a2:	5e                   	pop    %esi
  8015a3:	5d                   	pop    %ebp
  8015a4:	c3                   	ret    
	assert(r <= n);
  8015a5:	68 40 23 80 00       	push   $0x802340
  8015aa:	68 47 23 80 00       	push   $0x802347
  8015af:	6a 7c                	push   $0x7c
  8015b1:	68 5c 23 80 00       	push   $0x80235c
  8015b6:	e8 5a eb ff ff       	call   800115 <_panic>
	assert(r <= PGSIZE);
  8015bb:	68 67 23 80 00       	push   $0x802367
  8015c0:	68 47 23 80 00       	push   $0x802347
  8015c5:	6a 7d                	push   $0x7d
  8015c7:	68 5c 23 80 00       	push   $0x80235c
  8015cc:	e8 44 eb ff ff       	call   800115 <_panic>

008015d1 <open>:
{
  8015d1:	55                   	push   %ebp
  8015d2:	89 e5                	mov    %esp,%ebp
  8015d4:	56                   	push   %esi
  8015d5:	53                   	push   %ebx
  8015d6:	83 ec 1c             	sub    $0x1c,%esp
  8015d9:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8015dc:	56                   	push   %esi
  8015dd:	e8 f6 f1 ff ff       	call   8007d8 <strlen>
  8015e2:	83 c4 10             	add    $0x10,%esp
  8015e5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015ea:	7f 6c                	jg     801658 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8015ec:	83 ec 0c             	sub    $0xc,%esp
  8015ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f2:	50                   	push   %eax
  8015f3:	e8 b4 f8 ff ff       	call   800eac <fd_alloc>
  8015f8:	89 c3                	mov    %eax,%ebx
  8015fa:	83 c4 10             	add    $0x10,%esp
  8015fd:	85 c0                	test   %eax,%eax
  8015ff:	78 3c                	js     80163d <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801601:	83 ec 08             	sub    $0x8,%esp
  801604:	56                   	push   %esi
  801605:	68 00 50 80 00       	push   $0x805000
  80160a:	e8 00 f2 ff ff       	call   80080f <strcpy>
	fsipcbuf.open.req_omode = mode;
  80160f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801612:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801617:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80161a:	b8 01 00 00 00       	mov    $0x1,%eax
  80161f:	e8 f3 fd ff ff       	call   801417 <fsipc>
  801624:	89 c3                	mov    %eax,%ebx
  801626:	83 c4 10             	add    $0x10,%esp
  801629:	85 c0                	test   %eax,%eax
  80162b:	78 19                	js     801646 <open+0x75>
	return fd2num(fd);
  80162d:	83 ec 0c             	sub    $0xc,%esp
  801630:	ff 75 f4             	pushl  -0xc(%ebp)
  801633:	e8 4d f8 ff ff       	call   800e85 <fd2num>
  801638:	89 c3                	mov    %eax,%ebx
  80163a:	83 c4 10             	add    $0x10,%esp
}
  80163d:	89 d8                	mov    %ebx,%eax
  80163f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801642:	5b                   	pop    %ebx
  801643:	5e                   	pop    %esi
  801644:	5d                   	pop    %ebp
  801645:	c3                   	ret    
		fd_close(fd, 0);
  801646:	83 ec 08             	sub    $0x8,%esp
  801649:	6a 00                	push   $0x0
  80164b:	ff 75 f4             	pushl  -0xc(%ebp)
  80164e:	e8 54 f9 ff ff       	call   800fa7 <fd_close>
		return r;
  801653:	83 c4 10             	add    $0x10,%esp
  801656:	eb e5                	jmp    80163d <open+0x6c>
		return -E_BAD_PATH;
  801658:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80165d:	eb de                	jmp    80163d <open+0x6c>

0080165f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80165f:	55                   	push   %ebp
  801660:	89 e5                	mov    %esp,%ebp
  801662:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801665:	ba 00 00 00 00       	mov    $0x0,%edx
  80166a:	b8 08 00 00 00       	mov    $0x8,%eax
  80166f:	e8 a3 fd ff ff       	call   801417 <fsipc>
}
  801674:	c9                   	leave  
  801675:	c3                   	ret    

00801676 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801676:	55                   	push   %ebp
  801677:	89 e5                	mov    %esp,%ebp
  801679:	56                   	push   %esi
  80167a:	53                   	push   %ebx
  80167b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80167e:	83 ec 0c             	sub    $0xc,%esp
  801681:	ff 75 08             	pushl  0x8(%ebp)
  801684:	e8 0c f8 ff ff       	call   800e95 <fd2data>
  801689:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80168b:	83 c4 08             	add    $0x8,%esp
  80168e:	68 73 23 80 00       	push   $0x802373
  801693:	53                   	push   %ebx
  801694:	e8 76 f1 ff ff       	call   80080f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801699:	8b 46 04             	mov    0x4(%esi),%eax
  80169c:	2b 06                	sub    (%esi),%eax
  80169e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8016a4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016ab:	00 00 00 
	stat->st_dev = &devpipe;
  8016ae:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8016b5:	30 80 00 
	return 0;
}
  8016b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8016bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016c0:	5b                   	pop    %ebx
  8016c1:	5e                   	pop    %esi
  8016c2:	5d                   	pop    %ebp
  8016c3:	c3                   	ret    

008016c4 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8016c4:	55                   	push   %ebp
  8016c5:	89 e5                	mov    %esp,%ebp
  8016c7:	53                   	push   %ebx
  8016c8:	83 ec 0c             	sub    $0xc,%esp
  8016cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8016ce:	53                   	push   %ebx
  8016cf:	6a 00                	push   $0x0
  8016d1:	e8 b7 f5 ff ff       	call   800c8d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8016d6:	89 1c 24             	mov    %ebx,(%esp)
  8016d9:	e8 b7 f7 ff ff       	call   800e95 <fd2data>
  8016de:	83 c4 08             	add    $0x8,%esp
  8016e1:	50                   	push   %eax
  8016e2:	6a 00                	push   $0x0
  8016e4:	e8 a4 f5 ff ff       	call   800c8d <sys_page_unmap>
}
  8016e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ec:	c9                   	leave  
  8016ed:	c3                   	ret    

008016ee <_pipeisclosed>:
{
  8016ee:	55                   	push   %ebp
  8016ef:	89 e5                	mov    %esp,%ebp
  8016f1:	57                   	push   %edi
  8016f2:	56                   	push   %esi
  8016f3:	53                   	push   %ebx
  8016f4:	83 ec 1c             	sub    $0x1c,%esp
  8016f7:	89 c7                	mov    %eax,%edi
  8016f9:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8016fb:	a1 04 40 80 00       	mov    0x804004,%eax
  801700:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801703:	83 ec 0c             	sub    $0xc,%esp
  801706:	57                   	push   %edi
  801707:	e8 38 05 00 00       	call   801c44 <pageref>
  80170c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80170f:	89 34 24             	mov    %esi,(%esp)
  801712:	e8 2d 05 00 00       	call   801c44 <pageref>
		nn = thisenv->env_runs;
  801717:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80171d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801720:	83 c4 10             	add    $0x10,%esp
  801723:	39 cb                	cmp    %ecx,%ebx
  801725:	74 1b                	je     801742 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801727:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80172a:	75 cf                	jne    8016fb <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80172c:	8b 42 58             	mov    0x58(%edx),%eax
  80172f:	6a 01                	push   $0x1
  801731:	50                   	push   %eax
  801732:	53                   	push   %ebx
  801733:	68 7a 23 80 00       	push   $0x80237a
  801738:	e8 b3 ea ff ff       	call   8001f0 <cprintf>
  80173d:	83 c4 10             	add    $0x10,%esp
  801740:	eb b9                	jmp    8016fb <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801742:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801745:	0f 94 c0             	sete   %al
  801748:	0f b6 c0             	movzbl %al,%eax
}
  80174b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80174e:	5b                   	pop    %ebx
  80174f:	5e                   	pop    %esi
  801750:	5f                   	pop    %edi
  801751:	5d                   	pop    %ebp
  801752:	c3                   	ret    

00801753 <devpipe_write>:
{
  801753:	55                   	push   %ebp
  801754:	89 e5                	mov    %esp,%ebp
  801756:	57                   	push   %edi
  801757:	56                   	push   %esi
  801758:	53                   	push   %ebx
  801759:	83 ec 28             	sub    $0x28,%esp
  80175c:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  80175f:	56                   	push   %esi
  801760:	e8 30 f7 ff ff       	call   800e95 <fd2data>
  801765:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801767:	83 c4 10             	add    $0x10,%esp
  80176a:	bf 00 00 00 00       	mov    $0x0,%edi
  80176f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801772:	74 4f                	je     8017c3 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801774:	8b 43 04             	mov    0x4(%ebx),%eax
  801777:	8b 0b                	mov    (%ebx),%ecx
  801779:	8d 51 20             	lea    0x20(%ecx),%edx
  80177c:	39 d0                	cmp    %edx,%eax
  80177e:	72 14                	jb     801794 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801780:	89 da                	mov    %ebx,%edx
  801782:	89 f0                	mov    %esi,%eax
  801784:	e8 65 ff ff ff       	call   8016ee <_pipeisclosed>
  801789:	85 c0                	test   %eax,%eax
  80178b:	75 3a                	jne    8017c7 <devpipe_write+0x74>
			sys_yield();
  80178d:	e8 57 f4 ff ff       	call   800be9 <sys_yield>
  801792:	eb e0                	jmp    801774 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801794:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801797:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80179b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80179e:	89 c2                	mov    %eax,%edx
  8017a0:	c1 fa 1f             	sar    $0x1f,%edx
  8017a3:	89 d1                	mov    %edx,%ecx
  8017a5:	c1 e9 1b             	shr    $0x1b,%ecx
  8017a8:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8017ab:	83 e2 1f             	and    $0x1f,%edx
  8017ae:	29 ca                	sub    %ecx,%edx
  8017b0:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8017b4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8017b8:	83 c0 01             	add    $0x1,%eax
  8017bb:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  8017be:	83 c7 01             	add    $0x1,%edi
  8017c1:	eb ac                	jmp    80176f <devpipe_write+0x1c>
	return i;
  8017c3:	89 f8                	mov    %edi,%eax
  8017c5:	eb 05                	jmp    8017cc <devpipe_write+0x79>
				return 0;
  8017c7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017cf:	5b                   	pop    %ebx
  8017d0:	5e                   	pop    %esi
  8017d1:	5f                   	pop    %edi
  8017d2:	5d                   	pop    %ebp
  8017d3:	c3                   	ret    

008017d4 <devpipe_read>:
{
  8017d4:	55                   	push   %ebp
  8017d5:	89 e5                	mov    %esp,%ebp
  8017d7:	57                   	push   %edi
  8017d8:	56                   	push   %esi
  8017d9:	53                   	push   %ebx
  8017da:	83 ec 18             	sub    $0x18,%esp
  8017dd:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8017e0:	57                   	push   %edi
  8017e1:	e8 af f6 ff ff       	call   800e95 <fd2data>
  8017e6:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8017e8:	83 c4 10             	add    $0x10,%esp
  8017eb:	be 00 00 00 00       	mov    $0x0,%esi
  8017f0:	3b 75 10             	cmp    0x10(%ebp),%esi
  8017f3:	74 47                	je     80183c <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  8017f5:	8b 03                	mov    (%ebx),%eax
  8017f7:	3b 43 04             	cmp    0x4(%ebx),%eax
  8017fa:	75 22                	jne    80181e <devpipe_read+0x4a>
			if (i > 0)
  8017fc:	85 f6                	test   %esi,%esi
  8017fe:	75 14                	jne    801814 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801800:	89 da                	mov    %ebx,%edx
  801802:	89 f8                	mov    %edi,%eax
  801804:	e8 e5 fe ff ff       	call   8016ee <_pipeisclosed>
  801809:	85 c0                	test   %eax,%eax
  80180b:	75 33                	jne    801840 <devpipe_read+0x6c>
			sys_yield();
  80180d:	e8 d7 f3 ff ff       	call   800be9 <sys_yield>
  801812:	eb e1                	jmp    8017f5 <devpipe_read+0x21>
				return i;
  801814:	89 f0                	mov    %esi,%eax
}
  801816:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801819:	5b                   	pop    %ebx
  80181a:	5e                   	pop    %esi
  80181b:	5f                   	pop    %edi
  80181c:	5d                   	pop    %ebp
  80181d:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80181e:	99                   	cltd   
  80181f:	c1 ea 1b             	shr    $0x1b,%edx
  801822:	01 d0                	add    %edx,%eax
  801824:	83 e0 1f             	and    $0x1f,%eax
  801827:	29 d0                	sub    %edx,%eax
  801829:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  80182e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801831:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801834:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801837:	83 c6 01             	add    $0x1,%esi
  80183a:	eb b4                	jmp    8017f0 <devpipe_read+0x1c>
	return i;
  80183c:	89 f0                	mov    %esi,%eax
  80183e:	eb d6                	jmp    801816 <devpipe_read+0x42>
				return 0;
  801840:	b8 00 00 00 00       	mov    $0x0,%eax
  801845:	eb cf                	jmp    801816 <devpipe_read+0x42>

00801847 <pipe>:
{
  801847:	55                   	push   %ebp
  801848:	89 e5                	mov    %esp,%ebp
  80184a:	56                   	push   %esi
  80184b:	53                   	push   %ebx
  80184c:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  80184f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801852:	50                   	push   %eax
  801853:	e8 54 f6 ff ff       	call   800eac <fd_alloc>
  801858:	89 c3                	mov    %eax,%ebx
  80185a:	83 c4 10             	add    $0x10,%esp
  80185d:	85 c0                	test   %eax,%eax
  80185f:	78 5b                	js     8018bc <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801861:	83 ec 04             	sub    $0x4,%esp
  801864:	68 07 04 00 00       	push   $0x407
  801869:	ff 75 f4             	pushl  -0xc(%ebp)
  80186c:	6a 00                	push   $0x0
  80186e:	e8 95 f3 ff ff       	call   800c08 <sys_page_alloc>
  801873:	89 c3                	mov    %eax,%ebx
  801875:	83 c4 10             	add    $0x10,%esp
  801878:	85 c0                	test   %eax,%eax
  80187a:	78 40                	js     8018bc <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  80187c:	83 ec 0c             	sub    $0xc,%esp
  80187f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801882:	50                   	push   %eax
  801883:	e8 24 f6 ff ff       	call   800eac <fd_alloc>
  801888:	89 c3                	mov    %eax,%ebx
  80188a:	83 c4 10             	add    $0x10,%esp
  80188d:	85 c0                	test   %eax,%eax
  80188f:	78 1b                	js     8018ac <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801891:	83 ec 04             	sub    $0x4,%esp
  801894:	68 07 04 00 00       	push   $0x407
  801899:	ff 75 f0             	pushl  -0x10(%ebp)
  80189c:	6a 00                	push   $0x0
  80189e:	e8 65 f3 ff ff       	call   800c08 <sys_page_alloc>
  8018a3:	89 c3                	mov    %eax,%ebx
  8018a5:	83 c4 10             	add    $0x10,%esp
  8018a8:	85 c0                	test   %eax,%eax
  8018aa:	79 19                	jns    8018c5 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  8018ac:	83 ec 08             	sub    $0x8,%esp
  8018af:	ff 75 f4             	pushl  -0xc(%ebp)
  8018b2:	6a 00                	push   $0x0
  8018b4:	e8 d4 f3 ff ff       	call   800c8d <sys_page_unmap>
  8018b9:	83 c4 10             	add    $0x10,%esp
}
  8018bc:	89 d8                	mov    %ebx,%eax
  8018be:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018c1:	5b                   	pop    %ebx
  8018c2:	5e                   	pop    %esi
  8018c3:	5d                   	pop    %ebp
  8018c4:	c3                   	ret    
	va = fd2data(fd0);
  8018c5:	83 ec 0c             	sub    $0xc,%esp
  8018c8:	ff 75 f4             	pushl  -0xc(%ebp)
  8018cb:	e8 c5 f5 ff ff       	call   800e95 <fd2data>
  8018d0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018d2:	83 c4 0c             	add    $0xc,%esp
  8018d5:	68 07 04 00 00       	push   $0x407
  8018da:	50                   	push   %eax
  8018db:	6a 00                	push   $0x0
  8018dd:	e8 26 f3 ff ff       	call   800c08 <sys_page_alloc>
  8018e2:	89 c3                	mov    %eax,%ebx
  8018e4:	83 c4 10             	add    $0x10,%esp
  8018e7:	85 c0                	test   %eax,%eax
  8018e9:	0f 88 8c 00 00 00    	js     80197b <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018ef:	83 ec 0c             	sub    $0xc,%esp
  8018f2:	ff 75 f0             	pushl  -0x10(%ebp)
  8018f5:	e8 9b f5 ff ff       	call   800e95 <fd2data>
  8018fa:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801901:	50                   	push   %eax
  801902:	6a 00                	push   $0x0
  801904:	56                   	push   %esi
  801905:	6a 00                	push   $0x0
  801907:	e8 3f f3 ff ff       	call   800c4b <sys_page_map>
  80190c:	89 c3                	mov    %eax,%ebx
  80190e:	83 c4 20             	add    $0x20,%esp
  801911:	85 c0                	test   %eax,%eax
  801913:	78 58                	js     80196d <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801915:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801918:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80191e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801920:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801923:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  80192a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80192d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801933:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801935:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801938:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  80193f:	83 ec 0c             	sub    $0xc,%esp
  801942:	ff 75 f4             	pushl  -0xc(%ebp)
  801945:	e8 3b f5 ff ff       	call   800e85 <fd2num>
  80194a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80194d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80194f:	83 c4 04             	add    $0x4,%esp
  801952:	ff 75 f0             	pushl  -0x10(%ebp)
  801955:	e8 2b f5 ff ff       	call   800e85 <fd2num>
  80195a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80195d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801960:	83 c4 10             	add    $0x10,%esp
  801963:	bb 00 00 00 00       	mov    $0x0,%ebx
  801968:	e9 4f ff ff ff       	jmp    8018bc <pipe+0x75>
	sys_page_unmap(0, va);
  80196d:	83 ec 08             	sub    $0x8,%esp
  801970:	56                   	push   %esi
  801971:	6a 00                	push   $0x0
  801973:	e8 15 f3 ff ff       	call   800c8d <sys_page_unmap>
  801978:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  80197b:	83 ec 08             	sub    $0x8,%esp
  80197e:	ff 75 f0             	pushl  -0x10(%ebp)
  801981:	6a 00                	push   $0x0
  801983:	e8 05 f3 ff ff       	call   800c8d <sys_page_unmap>
  801988:	83 c4 10             	add    $0x10,%esp
  80198b:	e9 1c ff ff ff       	jmp    8018ac <pipe+0x65>

00801990 <pipeisclosed>:
{
  801990:	55                   	push   %ebp
  801991:	89 e5                	mov    %esp,%ebp
  801993:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801996:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801999:	50                   	push   %eax
  80199a:	ff 75 08             	pushl  0x8(%ebp)
  80199d:	e8 59 f5 ff ff       	call   800efb <fd_lookup>
  8019a2:	83 c4 10             	add    $0x10,%esp
  8019a5:	85 c0                	test   %eax,%eax
  8019a7:	78 18                	js     8019c1 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  8019a9:	83 ec 0c             	sub    $0xc,%esp
  8019ac:	ff 75 f4             	pushl  -0xc(%ebp)
  8019af:	e8 e1 f4 ff ff       	call   800e95 <fd2data>
	return _pipeisclosed(fd, p);
  8019b4:	89 c2                	mov    %eax,%edx
  8019b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019b9:	e8 30 fd ff ff       	call   8016ee <_pipeisclosed>
  8019be:	83 c4 10             	add    $0x10,%esp
}
  8019c1:	c9                   	leave  
  8019c2:	c3                   	ret    

008019c3 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8019c3:	55                   	push   %ebp
  8019c4:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8019c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8019cb:	5d                   	pop    %ebp
  8019cc:	c3                   	ret    

008019cd <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8019cd:	55                   	push   %ebp
  8019ce:	89 e5                	mov    %esp,%ebp
  8019d0:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8019d3:	68 92 23 80 00       	push   $0x802392
  8019d8:	ff 75 0c             	pushl  0xc(%ebp)
  8019db:	e8 2f ee ff ff       	call   80080f <strcpy>
	return 0;
}
  8019e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8019e5:	c9                   	leave  
  8019e6:	c3                   	ret    

008019e7 <devcons_write>:
{
  8019e7:	55                   	push   %ebp
  8019e8:	89 e5                	mov    %esp,%ebp
  8019ea:	57                   	push   %edi
  8019eb:	56                   	push   %esi
  8019ec:	53                   	push   %ebx
  8019ed:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8019f3:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8019f8:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8019fe:	eb 2f                	jmp    801a2f <devcons_write+0x48>
		m = n - tot;
  801a00:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a03:	29 f3                	sub    %esi,%ebx
  801a05:	83 fb 7f             	cmp    $0x7f,%ebx
  801a08:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801a0d:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801a10:	83 ec 04             	sub    $0x4,%esp
  801a13:	53                   	push   %ebx
  801a14:	89 f0                	mov    %esi,%eax
  801a16:	03 45 0c             	add    0xc(%ebp),%eax
  801a19:	50                   	push   %eax
  801a1a:	57                   	push   %edi
  801a1b:	e8 7d ef ff ff       	call   80099d <memmove>
		sys_cputs(buf, m);
  801a20:	83 c4 08             	add    $0x8,%esp
  801a23:	53                   	push   %ebx
  801a24:	57                   	push   %edi
  801a25:	e8 22 f1 ff ff       	call   800b4c <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801a2a:	01 de                	add    %ebx,%esi
  801a2c:	83 c4 10             	add    $0x10,%esp
  801a2f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a32:	72 cc                	jb     801a00 <devcons_write+0x19>
}
  801a34:	89 f0                	mov    %esi,%eax
  801a36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a39:	5b                   	pop    %ebx
  801a3a:	5e                   	pop    %esi
  801a3b:	5f                   	pop    %edi
  801a3c:	5d                   	pop    %ebp
  801a3d:	c3                   	ret    

00801a3e <devcons_read>:
{
  801a3e:	55                   	push   %ebp
  801a3f:	89 e5                	mov    %esp,%ebp
  801a41:	83 ec 08             	sub    $0x8,%esp
  801a44:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801a49:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a4d:	75 07                	jne    801a56 <devcons_read+0x18>
}
  801a4f:	c9                   	leave  
  801a50:	c3                   	ret    
		sys_yield();
  801a51:	e8 93 f1 ff ff       	call   800be9 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801a56:	e8 0f f1 ff ff       	call   800b6a <sys_cgetc>
  801a5b:	85 c0                	test   %eax,%eax
  801a5d:	74 f2                	je     801a51 <devcons_read+0x13>
	if (c < 0)
  801a5f:	85 c0                	test   %eax,%eax
  801a61:	78 ec                	js     801a4f <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  801a63:	83 f8 04             	cmp    $0x4,%eax
  801a66:	74 0c                	je     801a74 <devcons_read+0x36>
	*(char*)vbuf = c;
  801a68:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a6b:	88 02                	mov    %al,(%edx)
	return 1;
  801a6d:	b8 01 00 00 00       	mov    $0x1,%eax
  801a72:	eb db                	jmp    801a4f <devcons_read+0x11>
		return 0;
  801a74:	b8 00 00 00 00       	mov    $0x0,%eax
  801a79:	eb d4                	jmp    801a4f <devcons_read+0x11>

00801a7b <cputchar>:
{
  801a7b:	55                   	push   %ebp
  801a7c:	89 e5                	mov    %esp,%ebp
  801a7e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a81:	8b 45 08             	mov    0x8(%ebp),%eax
  801a84:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801a87:	6a 01                	push   $0x1
  801a89:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a8c:	50                   	push   %eax
  801a8d:	e8 ba f0 ff ff       	call   800b4c <sys_cputs>
}
  801a92:	83 c4 10             	add    $0x10,%esp
  801a95:	c9                   	leave  
  801a96:	c3                   	ret    

00801a97 <getchar>:
{
  801a97:	55                   	push   %ebp
  801a98:	89 e5                	mov    %esp,%ebp
  801a9a:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801a9d:	6a 01                	push   $0x1
  801a9f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801aa2:	50                   	push   %eax
  801aa3:	6a 00                	push   $0x0
  801aa5:	e8 c2 f6 ff ff       	call   80116c <read>
	if (r < 0)
  801aaa:	83 c4 10             	add    $0x10,%esp
  801aad:	85 c0                	test   %eax,%eax
  801aaf:	78 08                	js     801ab9 <getchar+0x22>
	if (r < 1)
  801ab1:	85 c0                	test   %eax,%eax
  801ab3:	7e 06                	jle    801abb <getchar+0x24>
	return c;
  801ab5:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801ab9:	c9                   	leave  
  801aba:	c3                   	ret    
		return -E_EOF;
  801abb:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801ac0:	eb f7                	jmp    801ab9 <getchar+0x22>

00801ac2 <iscons>:
{
  801ac2:	55                   	push   %ebp
  801ac3:	89 e5                	mov    %esp,%ebp
  801ac5:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ac8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801acb:	50                   	push   %eax
  801acc:	ff 75 08             	pushl  0x8(%ebp)
  801acf:	e8 27 f4 ff ff       	call   800efb <fd_lookup>
  801ad4:	83 c4 10             	add    $0x10,%esp
  801ad7:	85 c0                	test   %eax,%eax
  801ad9:	78 11                	js     801aec <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801adb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ade:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ae4:	39 10                	cmp    %edx,(%eax)
  801ae6:	0f 94 c0             	sete   %al
  801ae9:	0f b6 c0             	movzbl %al,%eax
}
  801aec:	c9                   	leave  
  801aed:	c3                   	ret    

00801aee <opencons>:
{
  801aee:	55                   	push   %ebp
  801aef:	89 e5                	mov    %esp,%ebp
  801af1:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801af4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801af7:	50                   	push   %eax
  801af8:	e8 af f3 ff ff       	call   800eac <fd_alloc>
  801afd:	83 c4 10             	add    $0x10,%esp
  801b00:	85 c0                	test   %eax,%eax
  801b02:	78 3a                	js     801b3e <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b04:	83 ec 04             	sub    $0x4,%esp
  801b07:	68 07 04 00 00       	push   $0x407
  801b0c:	ff 75 f4             	pushl  -0xc(%ebp)
  801b0f:	6a 00                	push   $0x0
  801b11:	e8 f2 f0 ff ff       	call   800c08 <sys_page_alloc>
  801b16:	83 c4 10             	add    $0x10,%esp
  801b19:	85 c0                	test   %eax,%eax
  801b1b:	78 21                	js     801b3e <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801b1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b20:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b26:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b2b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b32:	83 ec 0c             	sub    $0xc,%esp
  801b35:	50                   	push   %eax
  801b36:	e8 4a f3 ff ff       	call   800e85 <fd2num>
  801b3b:	83 c4 10             	add    $0x10,%esp
}
  801b3e:	c9                   	leave  
  801b3f:	c3                   	ret    

00801b40 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b40:	55                   	push   %ebp
  801b41:	89 e5                	mov    %esp,%ebp
  801b43:	56                   	push   %esi
  801b44:	53                   	push   %ebx
  801b45:	8b 75 08             	mov    0x8(%ebp),%esi
  801b48:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        //	panic("ipc_recv not implemented");
        int r;
       	if(pg!=NULL){
  801b4e:	85 c0                	test   %eax,%eax
  801b50:	74 3b                	je     801b8d <ipc_recv+0x4d>
	  r = sys_ipc_recv(pg);
  801b52:	83 ec 0c             	sub    $0xc,%esp
  801b55:	50                   	push   %eax
  801b56:	e8 5d f2 ff ff       	call   800db8 <sys_ipc_recv>
  801b5b:	83 c4 10             	add    $0x10,%esp
	}else
	  r = sys_ipc_recv((void *)UTOP);
	if(r<0){
  801b5e:	85 c0                	test   %eax,%eax
  801b60:	78 3d                	js     801b9f <ipc_recv+0x5f>
	if(perm_store!=NULL){
		*perm_store = 0;
            }
        	return r;
           }else{
	     if(from_env_store!=NULL)
  801b62:	85 f6                	test   %esi,%esi
  801b64:	74 0a                	je     801b70 <ipc_recv+0x30>
		     *from_env_store = thisenv->env_ipc_from;
  801b66:	a1 04 40 80 00       	mov    0x804004,%eax
  801b6b:	8b 40 74             	mov    0x74(%eax),%eax
  801b6e:	89 06                	mov    %eax,(%esi)
	     if(perm_store != NULL)
  801b70:	85 db                	test   %ebx,%ebx
  801b72:	74 0a                	je     801b7e <ipc_recv+0x3e>
		     *perm_store = thisenv->env_ipc_perm;
  801b74:	a1 04 40 80 00       	mov    0x804004,%eax
  801b79:	8b 40 78             	mov    0x78(%eax),%eax
  801b7c:	89 03                	mov    %eax,(%ebx)
	     return thisenv->env_ipc_value;
  801b7e:	a1 04 40 80 00       	mov    0x804004,%eax
  801b83:	8b 40 70             	mov    0x70(%eax),%eax
	   }

}
  801b86:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b89:	5b                   	pop    %ebx
  801b8a:	5e                   	pop    %esi
  801b8b:	5d                   	pop    %ebp
  801b8c:	c3                   	ret    
	  r = sys_ipc_recv((void *)UTOP);
  801b8d:	83 ec 0c             	sub    $0xc,%esp
  801b90:	68 00 00 c0 ee       	push   $0xeec00000
  801b95:	e8 1e f2 ff ff       	call   800db8 <sys_ipc_recv>
  801b9a:	83 c4 10             	add    $0x10,%esp
  801b9d:	eb bf                	jmp    801b5e <ipc_recv+0x1e>
	if(from_env_store!=NULL){
  801b9f:	85 f6                	test   %esi,%esi
  801ba1:	74 06                	je     801ba9 <ipc_recv+0x69>
	  *from_env_store = 0;
  801ba3:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if(perm_store!=NULL){
  801ba9:	85 db                	test   %ebx,%ebx
  801bab:	74 d9                	je     801b86 <ipc_recv+0x46>
		*perm_store = 0;
  801bad:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801bb3:	eb d1                	jmp    801b86 <ipc_recv+0x46>

00801bb5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bb5:	55                   	push   %ebp
  801bb6:	89 e5                	mov    %esp,%ebp
  801bb8:	57                   	push   %edi
  801bb9:	56                   	push   %esi
  801bba:	53                   	push   %ebx
  801bbb:	83 ec 0c             	sub    $0xc,%esp
  801bbe:	8b 7d 08             	mov    0x8(%ebp),%edi
  801bc1:	8b 75 0c             	mov    0xc(%ebp),%esi
  801bc4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if(pg==NULL) pg = (void *)UTOP;
  801bc7:	85 db                	test   %ebx,%ebx
  801bc9:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801bce:	0f 44 d8             	cmove  %eax,%ebx
	while((r=sys_ipc_try_send(to_env,val,pg,perm))<0){
  801bd1:	ff 75 14             	pushl  0x14(%ebp)
  801bd4:	53                   	push   %ebx
  801bd5:	56                   	push   %esi
  801bd6:	57                   	push   %edi
  801bd7:	e8 b9 f1 ff ff       	call   800d95 <sys_ipc_try_send>
  801bdc:	83 c4 10             	add    $0x10,%esp
  801bdf:	85 c0                	test   %eax,%eax
  801be1:	79 20                	jns    801c03 <ipc_send+0x4e>
	    if(r!=-E_IPC_NOT_RECV){
  801be3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801be6:	75 07                	jne    801bef <ipc_send+0x3a>
		    panic("ipc_send:send message failed\n");
	    }
	    sys_yield();
  801be8:	e8 fc ef ff ff       	call   800be9 <sys_yield>
  801bed:	eb e2                	jmp    801bd1 <ipc_send+0x1c>
		    panic("ipc_send:send message failed\n");
  801bef:	83 ec 04             	sub    $0x4,%esp
  801bf2:	68 9e 23 80 00       	push   $0x80239e
  801bf7:	6a 43                	push   $0x43
  801bf9:	68 bc 23 80 00       	push   $0x8023bc
  801bfe:	e8 12 e5 ff ff       	call   800115 <_panic>
	}

}
  801c03:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c06:	5b                   	pop    %ebx
  801c07:	5e                   	pop    %esi
  801c08:	5f                   	pop    %edi
  801c09:	5d                   	pop    %ebp
  801c0a:	c3                   	ret    

00801c0b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c0b:	55                   	push   %ebp
  801c0c:	89 e5                	mov    %esp,%ebp
  801c0e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c11:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c16:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c19:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c1f:	8b 52 50             	mov    0x50(%edx),%edx
  801c22:	39 ca                	cmp    %ecx,%edx
  801c24:	74 11                	je     801c37 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801c26:	83 c0 01             	add    $0x1,%eax
  801c29:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c2e:	75 e6                	jne    801c16 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801c30:	b8 00 00 00 00       	mov    $0x0,%eax
  801c35:	eb 0b                	jmp    801c42 <ipc_find_env+0x37>
			return envs[i].env_id;
  801c37:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c3a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c3f:	8b 40 48             	mov    0x48(%eax),%eax
}
  801c42:	5d                   	pop    %ebp
  801c43:	c3                   	ret    

00801c44 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c44:	55                   	push   %ebp
  801c45:	89 e5                	mov    %esp,%ebp
  801c47:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c4a:	89 d0                	mov    %edx,%eax
  801c4c:	c1 e8 16             	shr    $0x16,%eax
  801c4f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c56:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801c5b:	f6 c1 01             	test   $0x1,%cl
  801c5e:	74 1d                	je     801c7d <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801c60:	c1 ea 0c             	shr    $0xc,%edx
  801c63:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c6a:	f6 c2 01             	test   $0x1,%dl
  801c6d:	74 0e                	je     801c7d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c6f:	c1 ea 0c             	shr    $0xc,%edx
  801c72:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c79:	ef 
  801c7a:	0f b7 c0             	movzwl %ax,%eax
}
  801c7d:	5d                   	pop    %ebp
  801c7e:	c3                   	ret    
  801c7f:	90                   	nop

00801c80 <__udivdi3>:
  801c80:	55                   	push   %ebp
  801c81:	57                   	push   %edi
  801c82:	56                   	push   %esi
  801c83:	53                   	push   %ebx
  801c84:	83 ec 1c             	sub    $0x1c,%esp
  801c87:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c8b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801c8f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c93:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801c97:	85 d2                	test   %edx,%edx
  801c99:	75 35                	jne    801cd0 <__udivdi3+0x50>
  801c9b:	39 f3                	cmp    %esi,%ebx
  801c9d:	0f 87 bd 00 00 00    	ja     801d60 <__udivdi3+0xe0>
  801ca3:	85 db                	test   %ebx,%ebx
  801ca5:	89 d9                	mov    %ebx,%ecx
  801ca7:	75 0b                	jne    801cb4 <__udivdi3+0x34>
  801ca9:	b8 01 00 00 00       	mov    $0x1,%eax
  801cae:	31 d2                	xor    %edx,%edx
  801cb0:	f7 f3                	div    %ebx
  801cb2:	89 c1                	mov    %eax,%ecx
  801cb4:	31 d2                	xor    %edx,%edx
  801cb6:	89 f0                	mov    %esi,%eax
  801cb8:	f7 f1                	div    %ecx
  801cba:	89 c6                	mov    %eax,%esi
  801cbc:	89 e8                	mov    %ebp,%eax
  801cbe:	89 f7                	mov    %esi,%edi
  801cc0:	f7 f1                	div    %ecx
  801cc2:	89 fa                	mov    %edi,%edx
  801cc4:	83 c4 1c             	add    $0x1c,%esp
  801cc7:	5b                   	pop    %ebx
  801cc8:	5e                   	pop    %esi
  801cc9:	5f                   	pop    %edi
  801cca:	5d                   	pop    %ebp
  801ccb:	c3                   	ret    
  801ccc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cd0:	39 f2                	cmp    %esi,%edx
  801cd2:	77 7c                	ja     801d50 <__udivdi3+0xd0>
  801cd4:	0f bd fa             	bsr    %edx,%edi
  801cd7:	83 f7 1f             	xor    $0x1f,%edi
  801cda:	0f 84 98 00 00 00    	je     801d78 <__udivdi3+0xf8>
  801ce0:	89 f9                	mov    %edi,%ecx
  801ce2:	b8 20 00 00 00       	mov    $0x20,%eax
  801ce7:	29 f8                	sub    %edi,%eax
  801ce9:	d3 e2                	shl    %cl,%edx
  801ceb:	89 54 24 08          	mov    %edx,0x8(%esp)
  801cef:	89 c1                	mov    %eax,%ecx
  801cf1:	89 da                	mov    %ebx,%edx
  801cf3:	d3 ea                	shr    %cl,%edx
  801cf5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801cf9:	09 d1                	or     %edx,%ecx
  801cfb:	89 f2                	mov    %esi,%edx
  801cfd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d01:	89 f9                	mov    %edi,%ecx
  801d03:	d3 e3                	shl    %cl,%ebx
  801d05:	89 c1                	mov    %eax,%ecx
  801d07:	d3 ea                	shr    %cl,%edx
  801d09:	89 f9                	mov    %edi,%ecx
  801d0b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801d0f:	d3 e6                	shl    %cl,%esi
  801d11:	89 eb                	mov    %ebp,%ebx
  801d13:	89 c1                	mov    %eax,%ecx
  801d15:	d3 eb                	shr    %cl,%ebx
  801d17:	09 de                	or     %ebx,%esi
  801d19:	89 f0                	mov    %esi,%eax
  801d1b:	f7 74 24 08          	divl   0x8(%esp)
  801d1f:	89 d6                	mov    %edx,%esi
  801d21:	89 c3                	mov    %eax,%ebx
  801d23:	f7 64 24 0c          	mull   0xc(%esp)
  801d27:	39 d6                	cmp    %edx,%esi
  801d29:	72 0c                	jb     801d37 <__udivdi3+0xb7>
  801d2b:	89 f9                	mov    %edi,%ecx
  801d2d:	d3 e5                	shl    %cl,%ebp
  801d2f:	39 c5                	cmp    %eax,%ebp
  801d31:	73 5d                	jae    801d90 <__udivdi3+0x110>
  801d33:	39 d6                	cmp    %edx,%esi
  801d35:	75 59                	jne    801d90 <__udivdi3+0x110>
  801d37:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801d3a:	31 ff                	xor    %edi,%edi
  801d3c:	89 fa                	mov    %edi,%edx
  801d3e:	83 c4 1c             	add    $0x1c,%esp
  801d41:	5b                   	pop    %ebx
  801d42:	5e                   	pop    %esi
  801d43:	5f                   	pop    %edi
  801d44:	5d                   	pop    %ebp
  801d45:	c3                   	ret    
  801d46:	8d 76 00             	lea    0x0(%esi),%esi
  801d49:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801d50:	31 ff                	xor    %edi,%edi
  801d52:	31 c0                	xor    %eax,%eax
  801d54:	89 fa                	mov    %edi,%edx
  801d56:	83 c4 1c             	add    $0x1c,%esp
  801d59:	5b                   	pop    %ebx
  801d5a:	5e                   	pop    %esi
  801d5b:	5f                   	pop    %edi
  801d5c:	5d                   	pop    %ebp
  801d5d:	c3                   	ret    
  801d5e:	66 90                	xchg   %ax,%ax
  801d60:	31 ff                	xor    %edi,%edi
  801d62:	89 e8                	mov    %ebp,%eax
  801d64:	89 f2                	mov    %esi,%edx
  801d66:	f7 f3                	div    %ebx
  801d68:	89 fa                	mov    %edi,%edx
  801d6a:	83 c4 1c             	add    $0x1c,%esp
  801d6d:	5b                   	pop    %ebx
  801d6e:	5e                   	pop    %esi
  801d6f:	5f                   	pop    %edi
  801d70:	5d                   	pop    %ebp
  801d71:	c3                   	ret    
  801d72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d78:	39 f2                	cmp    %esi,%edx
  801d7a:	72 06                	jb     801d82 <__udivdi3+0x102>
  801d7c:	31 c0                	xor    %eax,%eax
  801d7e:	39 eb                	cmp    %ebp,%ebx
  801d80:	77 d2                	ja     801d54 <__udivdi3+0xd4>
  801d82:	b8 01 00 00 00       	mov    $0x1,%eax
  801d87:	eb cb                	jmp    801d54 <__udivdi3+0xd4>
  801d89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d90:	89 d8                	mov    %ebx,%eax
  801d92:	31 ff                	xor    %edi,%edi
  801d94:	eb be                	jmp    801d54 <__udivdi3+0xd4>
  801d96:	66 90                	xchg   %ax,%ax
  801d98:	66 90                	xchg   %ax,%ax
  801d9a:	66 90                	xchg   %ax,%ax
  801d9c:	66 90                	xchg   %ax,%ax
  801d9e:	66 90                	xchg   %ax,%ax

00801da0 <__umoddi3>:
  801da0:	55                   	push   %ebp
  801da1:	57                   	push   %edi
  801da2:	56                   	push   %esi
  801da3:	53                   	push   %ebx
  801da4:	83 ec 1c             	sub    $0x1c,%esp
  801da7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801dab:	8b 74 24 30          	mov    0x30(%esp),%esi
  801daf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801db3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801db7:	85 ed                	test   %ebp,%ebp
  801db9:	89 f0                	mov    %esi,%eax
  801dbb:	89 da                	mov    %ebx,%edx
  801dbd:	75 19                	jne    801dd8 <__umoddi3+0x38>
  801dbf:	39 df                	cmp    %ebx,%edi
  801dc1:	0f 86 b1 00 00 00    	jbe    801e78 <__umoddi3+0xd8>
  801dc7:	f7 f7                	div    %edi
  801dc9:	89 d0                	mov    %edx,%eax
  801dcb:	31 d2                	xor    %edx,%edx
  801dcd:	83 c4 1c             	add    $0x1c,%esp
  801dd0:	5b                   	pop    %ebx
  801dd1:	5e                   	pop    %esi
  801dd2:	5f                   	pop    %edi
  801dd3:	5d                   	pop    %ebp
  801dd4:	c3                   	ret    
  801dd5:	8d 76 00             	lea    0x0(%esi),%esi
  801dd8:	39 dd                	cmp    %ebx,%ebp
  801dda:	77 f1                	ja     801dcd <__umoddi3+0x2d>
  801ddc:	0f bd cd             	bsr    %ebp,%ecx
  801ddf:	83 f1 1f             	xor    $0x1f,%ecx
  801de2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801de6:	0f 84 b4 00 00 00    	je     801ea0 <__umoddi3+0x100>
  801dec:	b8 20 00 00 00       	mov    $0x20,%eax
  801df1:	89 c2                	mov    %eax,%edx
  801df3:	8b 44 24 04          	mov    0x4(%esp),%eax
  801df7:	29 c2                	sub    %eax,%edx
  801df9:	89 c1                	mov    %eax,%ecx
  801dfb:	89 f8                	mov    %edi,%eax
  801dfd:	d3 e5                	shl    %cl,%ebp
  801dff:	89 d1                	mov    %edx,%ecx
  801e01:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801e05:	d3 e8                	shr    %cl,%eax
  801e07:	09 c5                	or     %eax,%ebp
  801e09:	8b 44 24 04          	mov    0x4(%esp),%eax
  801e0d:	89 c1                	mov    %eax,%ecx
  801e0f:	d3 e7                	shl    %cl,%edi
  801e11:	89 d1                	mov    %edx,%ecx
  801e13:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801e17:	89 df                	mov    %ebx,%edi
  801e19:	d3 ef                	shr    %cl,%edi
  801e1b:	89 c1                	mov    %eax,%ecx
  801e1d:	89 f0                	mov    %esi,%eax
  801e1f:	d3 e3                	shl    %cl,%ebx
  801e21:	89 d1                	mov    %edx,%ecx
  801e23:	89 fa                	mov    %edi,%edx
  801e25:	d3 e8                	shr    %cl,%eax
  801e27:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801e2c:	09 d8                	or     %ebx,%eax
  801e2e:	f7 f5                	div    %ebp
  801e30:	d3 e6                	shl    %cl,%esi
  801e32:	89 d1                	mov    %edx,%ecx
  801e34:	f7 64 24 08          	mull   0x8(%esp)
  801e38:	39 d1                	cmp    %edx,%ecx
  801e3a:	89 c3                	mov    %eax,%ebx
  801e3c:	89 d7                	mov    %edx,%edi
  801e3e:	72 06                	jb     801e46 <__umoddi3+0xa6>
  801e40:	75 0e                	jne    801e50 <__umoddi3+0xb0>
  801e42:	39 c6                	cmp    %eax,%esi
  801e44:	73 0a                	jae    801e50 <__umoddi3+0xb0>
  801e46:	2b 44 24 08          	sub    0x8(%esp),%eax
  801e4a:	19 ea                	sbb    %ebp,%edx
  801e4c:	89 d7                	mov    %edx,%edi
  801e4e:	89 c3                	mov    %eax,%ebx
  801e50:	89 ca                	mov    %ecx,%edx
  801e52:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801e57:	29 de                	sub    %ebx,%esi
  801e59:	19 fa                	sbb    %edi,%edx
  801e5b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  801e5f:	89 d0                	mov    %edx,%eax
  801e61:	d3 e0                	shl    %cl,%eax
  801e63:	89 d9                	mov    %ebx,%ecx
  801e65:	d3 ee                	shr    %cl,%esi
  801e67:	d3 ea                	shr    %cl,%edx
  801e69:	09 f0                	or     %esi,%eax
  801e6b:	83 c4 1c             	add    $0x1c,%esp
  801e6e:	5b                   	pop    %ebx
  801e6f:	5e                   	pop    %esi
  801e70:	5f                   	pop    %edi
  801e71:	5d                   	pop    %ebp
  801e72:	c3                   	ret    
  801e73:	90                   	nop
  801e74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e78:	85 ff                	test   %edi,%edi
  801e7a:	89 f9                	mov    %edi,%ecx
  801e7c:	75 0b                	jne    801e89 <__umoddi3+0xe9>
  801e7e:	b8 01 00 00 00       	mov    $0x1,%eax
  801e83:	31 d2                	xor    %edx,%edx
  801e85:	f7 f7                	div    %edi
  801e87:	89 c1                	mov    %eax,%ecx
  801e89:	89 d8                	mov    %ebx,%eax
  801e8b:	31 d2                	xor    %edx,%edx
  801e8d:	f7 f1                	div    %ecx
  801e8f:	89 f0                	mov    %esi,%eax
  801e91:	f7 f1                	div    %ecx
  801e93:	e9 31 ff ff ff       	jmp    801dc9 <__umoddi3+0x29>
  801e98:	90                   	nop
  801e99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ea0:	39 dd                	cmp    %ebx,%ebp
  801ea2:	72 08                	jb     801eac <__umoddi3+0x10c>
  801ea4:	39 f7                	cmp    %esi,%edi
  801ea6:	0f 87 21 ff ff ff    	ja     801dcd <__umoddi3+0x2d>
  801eac:	89 da                	mov    %ebx,%edx
  801eae:	89 f0                	mov    %esi,%eax
  801eb0:	29 f8                	sub    %edi,%eax
  801eb2:	19 ea                	sbb    %ebp,%edx
  801eb4:	e9 14 ff ff ff       	jmp    801dcd <__umoddi3+0x2d>
