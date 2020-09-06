
obj/user/primespipe.debug:     file format elf32-i386


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
  80002c:	e8 04 02 00 00       	call   800235 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(int fd)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
  80003c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  80003f:	8d 75 e0             	lea    -0x20(%ebp),%esi
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);

	cprintf("%d\n", p);

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800042:	8d 7d d8             	lea    -0x28(%ebp),%edi
	if ((r = readn(fd, &p, 4)) != 4)
  800045:	83 ec 04             	sub    $0x4,%esp
  800048:	6a 04                	push   $0x4
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	e8 97 15 00 00       	call   8015e8 <readn>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	83 f8 04             	cmp    $0x4,%eax
  800057:	75 4b                	jne    8000a4 <primeproc+0x71>
	cprintf("%d\n", p);
  800059:	83 ec 08             	sub    $0x8,%esp
  80005c:	ff 75 e0             	pushl  -0x20(%ebp)
  80005f:	68 5d 27 80 00       	push   $0x80275d
  800064:	e8 07 03 00 00       	call   800370 <cprintf>
	if ((i=pipe(pfd)) < 0)
  800069:	89 3c 24             	mov    %edi,(%esp)
  80006c:	e8 cb 1b 00 00       	call   801c3c <pipe>
  800071:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800074:	83 c4 10             	add    $0x10,%esp
  800077:	85 c0                	test   %eax,%eax
  800079:	78 49                	js     8000c4 <primeproc+0x91>
		panic("pipe: %e", i);
	if ((id = fork()) < 0)
  80007b:	e8 ed 0f 00 00       	call   80106d <fork>
  800080:	85 c0                	test   %eax,%eax
  800082:	78 52                	js     8000d6 <primeproc+0xa3>
		panic("fork: %e", id);
	if (id == 0) {
  800084:	85 c0                	test   %eax,%eax
  800086:	75 60                	jne    8000e8 <primeproc+0xb5>
		close(fd);
  800088:	83 ec 0c             	sub    $0xc,%esp
  80008b:	53                   	push   %ebx
  80008c:	e8 94 13 00 00       	call   801425 <close>
		close(pfd[1]);
  800091:	83 c4 04             	add    $0x4,%esp
  800094:	ff 75 dc             	pushl  -0x24(%ebp)
  800097:	e8 89 13 00 00       	call   801425 <close>
		fd = pfd[0];
  80009c:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		goto top;
  80009f:	83 c4 10             	add    $0x10,%esp
  8000a2:	eb a1                	jmp    800045 <primeproc+0x12>
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);
  8000a4:	83 ec 0c             	sub    $0xc,%esp
  8000a7:	85 c0                	test   %eax,%eax
  8000a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ae:	0f 4e d0             	cmovle %eax,%edx
  8000b1:	52                   	push   %edx
  8000b2:	50                   	push   %eax
  8000b3:	68 40 23 80 00       	push   $0x802340
  8000b8:	6a 15                	push   $0x15
  8000ba:	68 6f 23 80 00       	push   $0x80236f
  8000bf:	e8 d1 01 00 00       	call   800295 <_panic>
		panic("pipe: %e", i);
  8000c4:	50                   	push   %eax
  8000c5:	68 81 23 80 00       	push   $0x802381
  8000ca:	6a 1b                	push   $0x1b
  8000cc:	68 6f 23 80 00       	push   $0x80236f
  8000d1:	e8 bf 01 00 00       	call   800295 <_panic>
		panic("fork: %e", id);
  8000d6:	50                   	push   %eax
  8000d7:	68 8a 23 80 00       	push   $0x80238a
  8000dc:	6a 1d                	push   $0x1d
  8000de:	68 6f 23 80 00       	push   $0x80236f
  8000e3:	e8 ad 01 00 00       	call   800295 <_panic>
	}

	close(pfd[0]);
  8000e8:	83 ec 0c             	sub    $0xc,%esp
  8000eb:	ff 75 d8             	pushl  -0x28(%ebp)
  8000ee:	e8 32 13 00 00       	call   801425 <close>
	wfd = pfd[1];
  8000f3:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8000f6:	83 c4 10             	add    $0x10,%esp

	// filter out multiples of our prime
	for (;;) {
		if ((r=readn(fd, &i, 4)) != 4)
  8000f9:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8000fc:	83 ec 04             	sub    $0x4,%esp
  8000ff:	6a 04                	push   $0x4
  800101:	56                   	push   %esi
  800102:	53                   	push   %ebx
  800103:	e8 e0 14 00 00       	call   8015e8 <readn>
  800108:	83 c4 10             	add    $0x10,%esp
  80010b:	83 f8 04             	cmp    $0x4,%eax
  80010e:	75 42                	jne    800152 <primeproc+0x11f>
			panic("primeproc %d readn %d %d %e", p, fd, r, r >= 0 ? 0 : r);
		if (i%p)
  800110:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800113:	99                   	cltd   
  800114:	f7 7d e0             	idivl  -0x20(%ebp)
  800117:	85 d2                	test   %edx,%edx
  800119:	74 e1                	je     8000fc <primeproc+0xc9>
			if ((r=write(wfd, &i, 4)) != 4)
  80011b:	83 ec 04             	sub    $0x4,%esp
  80011e:	6a 04                	push   $0x4
  800120:	56                   	push   %esi
  800121:	57                   	push   %edi
  800122:	e8 08 15 00 00       	call   80162f <write>
  800127:	83 c4 10             	add    $0x10,%esp
  80012a:	83 f8 04             	cmp    $0x4,%eax
  80012d:	74 cd                	je     8000fc <primeproc+0xc9>
				panic("primeproc %d write: %d %e", p, r, r >= 0 ? 0 : r);
  80012f:	83 ec 08             	sub    $0x8,%esp
  800132:	85 c0                	test   %eax,%eax
  800134:	ba 00 00 00 00       	mov    $0x0,%edx
  800139:	0f 4e d0             	cmovle %eax,%edx
  80013c:	52                   	push   %edx
  80013d:	50                   	push   %eax
  80013e:	ff 75 e0             	pushl  -0x20(%ebp)
  800141:	68 af 23 80 00       	push   $0x8023af
  800146:	6a 2e                	push   $0x2e
  800148:	68 6f 23 80 00       	push   $0x80236f
  80014d:	e8 43 01 00 00       	call   800295 <_panic>
			panic("primeproc %d readn %d %d %e", p, fd, r, r >= 0 ? 0 : r);
  800152:	83 ec 04             	sub    $0x4,%esp
  800155:	85 c0                	test   %eax,%eax
  800157:	ba 00 00 00 00       	mov    $0x0,%edx
  80015c:	0f 4e d0             	cmovle %eax,%edx
  80015f:	52                   	push   %edx
  800160:	50                   	push   %eax
  800161:	53                   	push   %ebx
  800162:	ff 75 e0             	pushl  -0x20(%ebp)
  800165:	68 93 23 80 00       	push   $0x802393
  80016a:	6a 2b                	push   $0x2b
  80016c:	68 6f 23 80 00       	push   $0x80236f
  800171:	e8 1f 01 00 00       	call   800295 <_panic>

00800176 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  800176:	55                   	push   %ebp
  800177:	89 e5                	mov    %esp,%ebp
  800179:	53                   	push   %ebx
  80017a:	83 ec 20             	sub    $0x20,%esp
	int i, id, p[2], r;

	binaryname = "primespipe";
  80017d:	c7 05 00 30 80 00 c9 	movl   $0x8023c9,0x803000
  800184:	23 80 00 

	if ((i=pipe(p)) < 0)
  800187:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80018a:	50                   	push   %eax
  80018b:	e8 ac 1a 00 00       	call   801c3c <pipe>
  800190:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800193:	83 c4 10             	add    $0x10,%esp
  800196:	85 c0                	test   %eax,%eax
  800198:	78 23                	js     8001bd <umain+0x47>
		panic("pipe: %e", i);

	// fork the first prime process in the chain
	if ((id=fork()) < 0)
  80019a:	e8 ce 0e 00 00       	call   80106d <fork>
  80019f:	85 c0                	test   %eax,%eax
  8001a1:	78 2c                	js     8001cf <umain+0x59>
		panic("fork: %e", id);

	if (id == 0) {
  8001a3:	85 c0                	test   %eax,%eax
  8001a5:	75 3a                	jne    8001e1 <umain+0x6b>
		close(p[1]);
  8001a7:	83 ec 0c             	sub    $0xc,%esp
  8001aa:	ff 75 f0             	pushl  -0x10(%ebp)
  8001ad:	e8 73 12 00 00       	call   801425 <close>
		primeproc(p[0]);
  8001b2:	83 c4 04             	add    $0x4,%esp
  8001b5:	ff 75 ec             	pushl  -0x14(%ebp)
  8001b8:	e8 76 fe ff ff       	call   800033 <primeproc>
		panic("pipe: %e", i);
  8001bd:	50                   	push   %eax
  8001be:	68 81 23 80 00       	push   $0x802381
  8001c3:	6a 3a                	push   $0x3a
  8001c5:	68 6f 23 80 00       	push   $0x80236f
  8001ca:	e8 c6 00 00 00       	call   800295 <_panic>
		panic("fork: %e", id);
  8001cf:	50                   	push   %eax
  8001d0:	68 8a 23 80 00       	push   $0x80238a
  8001d5:	6a 3e                	push   $0x3e
  8001d7:	68 6f 23 80 00       	push   $0x80236f
  8001dc:	e8 b4 00 00 00       	call   800295 <_panic>
	}

	close(p[0]);
  8001e1:	83 ec 0c             	sub    $0xc,%esp
  8001e4:	ff 75 ec             	pushl  -0x14(%ebp)
  8001e7:	e8 39 12 00 00       	call   801425 <close>

	// feed all the integers through
	for (i=2;; i++)
  8001ec:	c7 45 f4 02 00 00 00 	movl   $0x2,-0xc(%ebp)
  8001f3:	83 c4 10             	add    $0x10,%esp
		if ((r=write(p[1], &i, 4)) != 4)
  8001f6:	8d 5d f4             	lea    -0xc(%ebp),%ebx
  8001f9:	83 ec 04             	sub    $0x4,%esp
  8001fc:	6a 04                	push   $0x4
  8001fe:	53                   	push   %ebx
  8001ff:	ff 75 f0             	pushl  -0x10(%ebp)
  800202:	e8 28 14 00 00       	call   80162f <write>
  800207:	83 c4 10             	add    $0x10,%esp
  80020a:	83 f8 04             	cmp    $0x4,%eax
  80020d:	75 06                	jne    800215 <umain+0x9f>
	for (i=2;; i++)
  80020f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
		if ((r=write(p[1], &i, 4)) != 4)
  800213:	eb e4                	jmp    8001f9 <umain+0x83>
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
  800215:	83 ec 0c             	sub    $0xc,%esp
  800218:	85 c0                	test   %eax,%eax
  80021a:	ba 00 00 00 00       	mov    $0x0,%edx
  80021f:	0f 4e d0             	cmovle %eax,%edx
  800222:	52                   	push   %edx
  800223:	50                   	push   %eax
  800224:	68 d4 23 80 00       	push   $0x8023d4
  800229:	6a 4a                	push   $0x4a
  80022b:	68 6f 23 80 00       	push   $0x80236f
  800230:	e8 60 00 00 00       	call   800295 <_panic>

00800235 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800235:	55                   	push   %ebp
  800236:	89 e5                	mov    %esp,%ebp
  800238:	56                   	push   %esi
  800239:	53                   	push   %ebx
  80023a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80023d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800240:	e8 05 0b 00 00       	call   800d4a <sys_getenvid>
  800245:	25 ff 03 00 00       	and    $0x3ff,%eax
  80024a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80024d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800252:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800257:	85 db                	test   %ebx,%ebx
  800259:	7e 07                	jle    800262 <libmain+0x2d>
		binaryname = argv[0];
  80025b:	8b 06                	mov    (%esi),%eax
  80025d:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800262:	83 ec 08             	sub    $0x8,%esp
  800265:	56                   	push   %esi
  800266:	53                   	push   %ebx
  800267:	e8 0a ff ff ff       	call   800176 <umain>

	// exit gracefully
	exit();
  80026c:	e8 0a 00 00 00       	call   80027b <exit>
}
  800271:	83 c4 10             	add    $0x10,%esp
  800274:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800277:	5b                   	pop    %ebx
  800278:	5e                   	pop    %esi
  800279:	5d                   	pop    %ebp
  80027a:	c3                   	ret    

0080027b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80027b:	55                   	push   %ebp
  80027c:	89 e5                	mov    %esp,%ebp
  80027e:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800281:	e8 ca 11 00 00       	call   801450 <close_all>
	sys_env_destroy(0);
  800286:	83 ec 0c             	sub    $0xc,%esp
  800289:	6a 00                	push   $0x0
  80028b:	e8 79 0a 00 00       	call   800d09 <sys_env_destroy>
}
  800290:	83 c4 10             	add    $0x10,%esp
  800293:	c9                   	leave  
  800294:	c3                   	ret    

00800295 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800295:	55                   	push   %ebp
  800296:	89 e5                	mov    %esp,%ebp
  800298:	56                   	push   %esi
  800299:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80029a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80029d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8002a3:	e8 a2 0a 00 00       	call   800d4a <sys_getenvid>
  8002a8:	83 ec 0c             	sub    $0xc,%esp
  8002ab:	ff 75 0c             	pushl  0xc(%ebp)
  8002ae:	ff 75 08             	pushl  0x8(%ebp)
  8002b1:	56                   	push   %esi
  8002b2:	50                   	push   %eax
  8002b3:	68 f8 23 80 00       	push   $0x8023f8
  8002b8:	e8 b3 00 00 00       	call   800370 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002bd:	83 c4 18             	add    $0x18,%esp
  8002c0:	53                   	push   %ebx
  8002c1:	ff 75 10             	pushl  0x10(%ebp)
  8002c4:	e8 56 00 00 00       	call   80031f <vcprintf>
	cprintf("\n");
  8002c9:	c7 04 24 5f 27 80 00 	movl   $0x80275f,(%esp)
  8002d0:	e8 9b 00 00 00       	call   800370 <cprintf>
  8002d5:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002d8:	cc                   	int3   
  8002d9:	eb fd                	jmp    8002d8 <_panic+0x43>

008002db <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002db:	55                   	push   %ebp
  8002dc:	89 e5                	mov    %esp,%ebp
  8002de:	53                   	push   %ebx
  8002df:	83 ec 04             	sub    $0x4,%esp
  8002e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002e5:	8b 13                	mov    (%ebx),%edx
  8002e7:	8d 42 01             	lea    0x1(%edx),%eax
  8002ea:	89 03                	mov    %eax,(%ebx)
  8002ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002ef:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002f3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002f8:	74 09                	je     800303 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8002fa:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800301:	c9                   	leave  
  800302:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800303:	83 ec 08             	sub    $0x8,%esp
  800306:	68 ff 00 00 00       	push   $0xff
  80030b:	8d 43 08             	lea    0x8(%ebx),%eax
  80030e:	50                   	push   %eax
  80030f:	e8 b8 09 00 00       	call   800ccc <sys_cputs>
		b->idx = 0;
  800314:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80031a:	83 c4 10             	add    $0x10,%esp
  80031d:	eb db                	jmp    8002fa <putch+0x1f>

0080031f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80031f:	55                   	push   %ebp
  800320:	89 e5                	mov    %esp,%ebp
  800322:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800328:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80032f:	00 00 00 
	b.cnt = 0;
  800332:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800339:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80033c:	ff 75 0c             	pushl  0xc(%ebp)
  80033f:	ff 75 08             	pushl  0x8(%ebp)
  800342:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800348:	50                   	push   %eax
  800349:	68 db 02 80 00       	push   $0x8002db
  80034e:	e8 1a 01 00 00       	call   80046d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800353:	83 c4 08             	add    $0x8,%esp
  800356:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80035c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800362:	50                   	push   %eax
  800363:	e8 64 09 00 00       	call   800ccc <sys_cputs>

	return b.cnt;
}
  800368:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80036e:	c9                   	leave  
  80036f:	c3                   	ret    

00800370 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800370:	55                   	push   %ebp
  800371:	89 e5                	mov    %esp,%ebp
  800373:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800376:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800379:	50                   	push   %eax
  80037a:	ff 75 08             	pushl  0x8(%ebp)
  80037d:	e8 9d ff ff ff       	call   80031f <vcprintf>
	va_end(ap);

	return cnt;
}
  800382:	c9                   	leave  
  800383:	c3                   	ret    

00800384 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	57                   	push   %edi
  800388:	56                   	push   %esi
  800389:	53                   	push   %ebx
  80038a:	83 ec 1c             	sub    $0x1c,%esp
  80038d:	89 c7                	mov    %eax,%edi
  80038f:	89 d6                	mov    %edx,%esi
  800391:	8b 45 08             	mov    0x8(%ebp),%eax
  800394:	8b 55 0c             	mov    0xc(%ebp),%edx
  800397:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80039a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80039d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8003a0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003a5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003a8:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8003ab:	39 d3                	cmp    %edx,%ebx
  8003ad:	72 05                	jb     8003b4 <printnum+0x30>
  8003af:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003b2:	77 7a                	ja     80042e <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003b4:	83 ec 0c             	sub    $0xc,%esp
  8003b7:	ff 75 18             	pushl  0x18(%ebp)
  8003ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bd:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8003c0:	53                   	push   %ebx
  8003c1:	ff 75 10             	pushl  0x10(%ebp)
  8003c4:	83 ec 08             	sub    $0x8,%esp
  8003c7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ca:	ff 75 e0             	pushl  -0x20(%ebp)
  8003cd:	ff 75 dc             	pushl  -0x24(%ebp)
  8003d0:	ff 75 d8             	pushl  -0x28(%ebp)
  8003d3:	e8 28 1d 00 00       	call   802100 <__udivdi3>
  8003d8:	83 c4 18             	add    $0x18,%esp
  8003db:	52                   	push   %edx
  8003dc:	50                   	push   %eax
  8003dd:	89 f2                	mov    %esi,%edx
  8003df:	89 f8                	mov    %edi,%eax
  8003e1:	e8 9e ff ff ff       	call   800384 <printnum>
  8003e6:	83 c4 20             	add    $0x20,%esp
  8003e9:	eb 13                	jmp    8003fe <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003eb:	83 ec 08             	sub    $0x8,%esp
  8003ee:	56                   	push   %esi
  8003ef:	ff 75 18             	pushl  0x18(%ebp)
  8003f2:	ff d7                	call   *%edi
  8003f4:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8003f7:	83 eb 01             	sub    $0x1,%ebx
  8003fa:	85 db                	test   %ebx,%ebx
  8003fc:	7f ed                	jg     8003eb <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003fe:	83 ec 08             	sub    $0x8,%esp
  800401:	56                   	push   %esi
  800402:	83 ec 04             	sub    $0x4,%esp
  800405:	ff 75 e4             	pushl  -0x1c(%ebp)
  800408:	ff 75 e0             	pushl  -0x20(%ebp)
  80040b:	ff 75 dc             	pushl  -0x24(%ebp)
  80040e:	ff 75 d8             	pushl  -0x28(%ebp)
  800411:	e8 0a 1e 00 00       	call   802220 <__umoddi3>
  800416:	83 c4 14             	add    $0x14,%esp
  800419:	0f be 80 1b 24 80 00 	movsbl 0x80241b(%eax),%eax
  800420:	50                   	push   %eax
  800421:	ff d7                	call   *%edi
}
  800423:	83 c4 10             	add    $0x10,%esp
  800426:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800429:	5b                   	pop    %ebx
  80042a:	5e                   	pop    %esi
  80042b:	5f                   	pop    %edi
  80042c:	5d                   	pop    %ebp
  80042d:	c3                   	ret    
  80042e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800431:	eb c4                	jmp    8003f7 <printnum+0x73>

00800433 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800433:	55                   	push   %ebp
  800434:	89 e5                	mov    %esp,%ebp
  800436:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800439:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80043d:	8b 10                	mov    (%eax),%edx
  80043f:	3b 50 04             	cmp    0x4(%eax),%edx
  800442:	73 0a                	jae    80044e <sprintputch+0x1b>
		*b->buf++ = ch;
  800444:	8d 4a 01             	lea    0x1(%edx),%ecx
  800447:	89 08                	mov    %ecx,(%eax)
  800449:	8b 45 08             	mov    0x8(%ebp),%eax
  80044c:	88 02                	mov    %al,(%edx)
}
  80044e:	5d                   	pop    %ebp
  80044f:	c3                   	ret    

00800450 <printfmt>:
{
  800450:	55                   	push   %ebp
  800451:	89 e5                	mov    %esp,%ebp
  800453:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800456:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800459:	50                   	push   %eax
  80045a:	ff 75 10             	pushl  0x10(%ebp)
  80045d:	ff 75 0c             	pushl  0xc(%ebp)
  800460:	ff 75 08             	pushl  0x8(%ebp)
  800463:	e8 05 00 00 00       	call   80046d <vprintfmt>
}
  800468:	83 c4 10             	add    $0x10,%esp
  80046b:	c9                   	leave  
  80046c:	c3                   	ret    

0080046d <vprintfmt>:
{
  80046d:	55                   	push   %ebp
  80046e:	89 e5                	mov    %esp,%ebp
  800470:	57                   	push   %edi
  800471:	56                   	push   %esi
  800472:	53                   	push   %ebx
  800473:	83 ec 2c             	sub    $0x2c,%esp
  800476:	8b 75 08             	mov    0x8(%ebp),%esi
  800479:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80047c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80047f:	e9 c1 03 00 00       	jmp    800845 <vprintfmt+0x3d8>
		padc = ' ';
  800484:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800488:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  80048f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800496:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80049d:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8004a2:	8d 47 01             	lea    0x1(%edi),%eax
  8004a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004a8:	0f b6 17             	movzbl (%edi),%edx
  8004ab:	8d 42 dd             	lea    -0x23(%edx),%eax
  8004ae:	3c 55                	cmp    $0x55,%al
  8004b0:	0f 87 12 04 00 00    	ja     8008c8 <vprintfmt+0x45b>
  8004b6:	0f b6 c0             	movzbl %al,%eax
  8004b9:	ff 24 85 60 25 80 00 	jmp    *0x802560(,%eax,4)
  8004c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8004c3:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8004c7:	eb d9                	jmp    8004a2 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8004c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  8004cc:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004d0:	eb d0                	jmp    8004a2 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8004d2:	0f b6 d2             	movzbl %dl,%edx
  8004d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8004d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004dd:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8004e0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004e3:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8004e7:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8004ea:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8004ed:	83 f9 09             	cmp    $0x9,%ecx
  8004f0:	77 55                	ja     800547 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  8004f2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8004f5:	eb e9                	jmp    8004e0 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  8004f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fa:	8b 00                	mov    (%eax),%eax
  8004fc:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800502:	8d 40 04             	lea    0x4(%eax),%eax
  800505:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800508:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80050b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80050f:	79 91                	jns    8004a2 <vprintfmt+0x35>
				width = precision, precision = -1;
  800511:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800514:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800517:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80051e:	eb 82                	jmp    8004a2 <vprintfmt+0x35>
  800520:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800523:	85 c0                	test   %eax,%eax
  800525:	ba 00 00 00 00       	mov    $0x0,%edx
  80052a:	0f 49 d0             	cmovns %eax,%edx
  80052d:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800530:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800533:	e9 6a ff ff ff       	jmp    8004a2 <vprintfmt+0x35>
  800538:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80053b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800542:	e9 5b ff ff ff       	jmp    8004a2 <vprintfmt+0x35>
  800547:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80054a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80054d:	eb bc                	jmp    80050b <vprintfmt+0x9e>
			lflag++;
  80054f:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800552:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800555:	e9 48 ff ff ff       	jmp    8004a2 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  80055a:	8b 45 14             	mov    0x14(%ebp),%eax
  80055d:	8d 78 04             	lea    0x4(%eax),%edi
  800560:	83 ec 08             	sub    $0x8,%esp
  800563:	53                   	push   %ebx
  800564:	ff 30                	pushl  (%eax)
  800566:	ff d6                	call   *%esi
			break;
  800568:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80056b:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80056e:	e9 cf 02 00 00       	jmp    800842 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  800573:	8b 45 14             	mov    0x14(%ebp),%eax
  800576:	8d 78 04             	lea    0x4(%eax),%edi
  800579:	8b 00                	mov    (%eax),%eax
  80057b:	99                   	cltd   
  80057c:	31 d0                	xor    %edx,%eax
  80057e:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800580:	83 f8 0f             	cmp    $0xf,%eax
  800583:	7f 23                	jg     8005a8 <vprintfmt+0x13b>
  800585:	8b 14 85 c0 26 80 00 	mov    0x8026c0(,%eax,4),%edx
  80058c:	85 d2                	test   %edx,%edx
  80058e:	74 18                	je     8005a8 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800590:	52                   	push   %edx
  800591:	68 35 29 80 00       	push   $0x802935
  800596:	53                   	push   %ebx
  800597:	56                   	push   %esi
  800598:	e8 b3 fe ff ff       	call   800450 <printfmt>
  80059d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8005a0:	89 7d 14             	mov    %edi,0x14(%ebp)
  8005a3:	e9 9a 02 00 00       	jmp    800842 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  8005a8:	50                   	push   %eax
  8005a9:	68 33 24 80 00       	push   $0x802433
  8005ae:	53                   	push   %ebx
  8005af:	56                   	push   %esi
  8005b0:	e8 9b fe ff ff       	call   800450 <printfmt>
  8005b5:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8005b8:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8005bb:	e9 82 02 00 00       	jmp    800842 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  8005c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c3:	83 c0 04             	add    $0x4,%eax
  8005c6:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8005c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cc:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005ce:	85 ff                	test   %edi,%edi
  8005d0:	b8 2c 24 80 00       	mov    $0x80242c,%eax
  8005d5:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005d8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005dc:	0f 8e bd 00 00 00    	jle    80069f <vprintfmt+0x232>
  8005e2:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005e6:	75 0e                	jne    8005f6 <vprintfmt+0x189>
  8005e8:	89 75 08             	mov    %esi,0x8(%ebp)
  8005eb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005ee:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005f1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005f4:	eb 6d                	jmp    800663 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f6:	83 ec 08             	sub    $0x8,%esp
  8005f9:	ff 75 d0             	pushl  -0x30(%ebp)
  8005fc:	57                   	push   %edi
  8005fd:	e8 6e 03 00 00       	call   800970 <strnlen>
  800602:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800605:	29 c1                	sub    %eax,%ecx
  800607:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80060a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80060d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800611:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800614:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800617:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800619:	eb 0f                	jmp    80062a <vprintfmt+0x1bd>
					putch(padc, putdat);
  80061b:	83 ec 08             	sub    $0x8,%esp
  80061e:	53                   	push   %ebx
  80061f:	ff 75 e0             	pushl  -0x20(%ebp)
  800622:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800624:	83 ef 01             	sub    $0x1,%edi
  800627:	83 c4 10             	add    $0x10,%esp
  80062a:	85 ff                	test   %edi,%edi
  80062c:	7f ed                	jg     80061b <vprintfmt+0x1ae>
  80062e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800631:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800634:	85 c9                	test   %ecx,%ecx
  800636:	b8 00 00 00 00       	mov    $0x0,%eax
  80063b:	0f 49 c1             	cmovns %ecx,%eax
  80063e:	29 c1                	sub    %eax,%ecx
  800640:	89 75 08             	mov    %esi,0x8(%ebp)
  800643:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800646:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800649:	89 cb                	mov    %ecx,%ebx
  80064b:	eb 16                	jmp    800663 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  80064d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800651:	75 31                	jne    800684 <vprintfmt+0x217>
					putch(ch, putdat);
  800653:	83 ec 08             	sub    $0x8,%esp
  800656:	ff 75 0c             	pushl  0xc(%ebp)
  800659:	50                   	push   %eax
  80065a:	ff 55 08             	call   *0x8(%ebp)
  80065d:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800660:	83 eb 01             	sub    $0x1,%ebx
  800663:	83 c7 01             	add    $0x1,%edi
  800666:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  80066a:	0f be c2             	movsbl %dl,%eax
  80066d:	85 c0                	test   %eax,%eax
  80066f:	74 59                	je     8006ca <vprintfmt+0x25d>
  800671:	85 f6                	test   %esi,%esi
  800673:	78 d8                	js     80064d <vprintfmt+0x1e0>
  800675:	83 ee 01             	sub    $0x1,%esi
  800678:	79 d3                	jns    80064d <vprintfmt+0x1e0>
  80067a:	89 df                	mov    %ebx,%edi
  80067c:	8b 75 08             	mov    0x8(%ebp),%esi
  80067f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800682:	eb 37                	jmp    8006bb <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  800684:	0f be d2             	movsbl %dl,%edx
  800687:	83 ea 20             	sub    $0x20,%edx
  80068a:	83 fa 5e             	cmp    $0x5e,%edx
  80068d:	76 c4                	jbe    800653 <vprintfmt+0x1e6>
					putch('?', putdat);
  80068f:	83 ec 08             	sub    $0x8,%esp
  800692:	ff 75 0c             	pushl  0xc(%ebp)
  800695:	6a 3f                	push   $0x3f
  800697:	ff 55 08             	call   *0x8(%ebp)
  80069a:	83 c4 10             	add    $0x10,%esp
  80069d:	eb c1                	jmp    800660 <vprintfmt+0x1f3>
  80069f:	89 75 08             	mov    %esi,0x8(%ebp)
  8006a2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006a5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006a8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006ab:	eb b6                	jmp    800663 <vprintfmt+0x1f6>
				putch(' ', putdat);
  8006ad:	83 ec 08             	sub    $0x8,%esp
  8006b0:	53                   	push   %ebx
  8006b1:	6a 20                	push   $0x20
  8006b3:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8006b5:	83 ef 01             	sub    $0x1,%edi
  8006b8:	83 c4 10             	add    $0x10,%esp
  8006bb:	85 ff                	test   %edi,%edi
  8006bd:	7f ee                	jg     8006ad <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  8006bf:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006c2:	89 45 14             	mov    %eax,0x14(%ebp)
  8006c5:	e9 78 01 00 00       	jmp    800842 <vprintfmt+0x3d5>
  8006ca:	89 df                	mov    %ebx,%edi
  8006cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8006cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006d2:	eb e7                	jmp    8006bb <vprintfmt+0x24e>
	if (lflag >= 2)
  8006d4:	83 f9 01             	cmp    $0x1,%ecx
  8006d7:	7e 3f                	jle    800718 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  8006d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006dc:	8b 50 04             	mov    0x4(%eax),%edx
  8006df:	8b 00                	mov    (%eax),%eax
  8006e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ea:	8d 40 08             	lea    0x8(%eax),%eax
  8006ed:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8006f0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006f4:	79 5c                	jns    800752 <vprintfmt+0x2e5>
				putch('-', putdat);
  8006f6:	83 ec 08             	sub    $0x8,%esp
  8006f9:	53                   	push   %ebx
  8006fa:	6a 2d                	push   $0x2d
  8006fc:	ff d6                	call   *%esi
				num = -(long long) num;
  8006fe:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800701:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800704:	f7 da                	neg    %edx
  800706:	83 d1 00             	adc    $0x0,%ecx
  800709:	f7 d9                	neg    %ecx
  80070b:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80070e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800713:	e9 10 01 00 00       	jmp    800828 <vprintfmt+0x3bb>
	else if (lflag)
  800718:	85 c9                	test   %ecx,%ecx
  80071a:	75 1b                	jne    800737 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  80071c:	8b 45 14             	mov    0x14(%ebp),%eax
  80071f:	8b 00                	mov    (%eax),%eax
  800721:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800724:	89 c1                	mov    %eax,%ecx
  800726:	c1 f9 1f             	sar    $0x1f,%ecx
  800729:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80072c:	8b 45 14             	mov    0x14(%ebp),%eax
  80072f:	8d 40 04             	lea    0x4(%eax),%eax
  800732:	89 45 14             	mov    %eax,0x14(%ebp)
  800735:	eb b9                	jmp    8006f0 <vprintfmt+0x283>
		return va_arg(*ap, long);
  800737:	8b 45 14             	mov    0x14(%ebp),%eax
  80073a:	8b 00                	mov    (%eax),%eax
  80073c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80073f:	89 c1                	mov    %eax,%ecx
  800741:	c1 f9 1f             	sar    $0x1f,%ecx
  800744:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800747:	8b 45 14             	mov    0x14(%ebp),%eax
  80074a:	8d 40 04             	lea    0x4(%eax),%eax
  80074d:	89 45 14             	mov    %eax,0x14(%ebp)
  800750:	eb 9e                	jmp    8006f0 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  800752:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800755:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800758:	b8 0a 00 00 00       	mov    $0xa,%eax
  80075d:	e9 c6 00 00 00       	jmp    800828 <vprintfmt+0x3bb>
	if (lflag >= 2)
  800762:	83 f9 01             	cmp    $0x1,%ecx
  800765:	7e 18                	jle    80077f <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  800767:	8b 45 14             	mov    0x14(%ebp),%eax
  80076a:	8b 10                	mov    (%eax),%edx
  80076c:	8b 48 04             	mov    0x4(%eax),%ecx
  80076f:	8d 40 08             	lea    0x8(%eax),%eax
  800772:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800775:	b8 0a 00 00 00       	mov    $0xa,%eax
  80077a:	e9 a9 00 00 00       	jmp    800828 <vprintfmt+0x3bb>
	else if (lflag)
  80077f:	85 c9                	test   %ecx,%ecx
  800781:	75 1a                	jne    80079d <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  800783:	8b 45 14             	mov    0x14(%ebp),%eax
  800786:	8b 10                	mov    (%eax),%edx
  800788:	b9 00 00 00 00       	mov    $0x0,%ecx
  80078d:	8d 40 04             	lea    0x4(%eax),%eax
  800790:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800793:	b8 0a 00 00 00       	mov    $0xa,%eax
  800798:	e9 8b 00 00 00       	jmp    800828 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80079d:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a0:	8b 10                	mov    (%eax),%edx
  8007a2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007a7:	8d 40 04             	lea    0x4(%eax),%eax
  8007aa:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007ad:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007b2:	eb 74                	jmp    800828 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8007b4:	83 f9 01             	cmp    $0x1,%ecx
  8007b7:	7e 15                	jle    8007ce <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  8007b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bc:	8b 10                	mov    (%eax),%edx
  8007be:	8b 48 04             	mov    0x4(%eax),%ecx
  8007c1:	8d 40 08             	lea    0x8(%eax),%eax
  8007c4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8007c7:	b8 08 00 00 00       	mov    $0x8,%eax
  8007cc:	eb 5a                	jmp    800828 <vprintfmt+0x3bb>
	else if (lflag)
  8007ce:	85 c9                	test   %ecx,%ecx
  8007d0:	75 17                	jne    8007e9 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  8007d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d5:	8b 10                	mov    (%eax),%edx
  8007d7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007dc:	8d 40 04             	lea    0x4(%eax),%eax
  8007df:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8007e2:	b8 08 00 00 00       	mov    $0x8,%eax
  8007e7:	eb 3f                	jmp    800828 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8007e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ec:	8b 10                	mov    (%eax),%edx
  8007ee:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007f3:	8d 40 04             	lea    0x4(%eax),%eax
  8007f6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8007f9:	b8 08 00 00 00       	mov    $0x8,%eax
  8007fe:	eb 28                	jmp    800828 <vprintfmt+0x3bb>
			putch('0', putdat);
  800800:	83 ec 08             	sub    $0x8,%esp
  800803:	53                   	push   %ebx
  800804:	6a 30                	push   $0x30
  800806:	ff d6                	call   *%esi
			putch('x', putdat);
  800808:	83 c4 08             	add    $0x8,%esp
  80080b:	53                   	push   %ebx
  80080c:	6a 78                	push   $0x78
  80080e:	ff d6                	call   *%esi
			num = (unsigned long long)
  800810:	8b 45 14             	mov    0x14(%ebp),%eax
  800813:	8b 10                	mov    (%eax),%edx
  800815:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80081a:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80081d:	8d 40 04             	lea    0x4(%eax),%eax
  800820:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800823:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800828:	83 ec 0c             	sub    $0xc,%esp
  80082b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80082f:	57                   	push   %edi
  800830:	ff 75 e0             	pushl  -0x20(%ebp)
  800833:	50                   	push   %eax
  800834:	51                   	push   %ecx
  800835:	52                   	push   %edx
  800836:	89 da                	mov    %ebx,%edx
  800838:	89 f0                	mov    %esi,%eax
  80083a:	e8 45 fb ff ff       	call   800384 <printnum>
			break;
  80083f:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800842:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800845:	83 c7 01             	add    $0x1,%edi
  800848:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80084c:	83 f8 25             	cmp    $0x25,%eax
  80084f:	0f 84 2f fc ff ff    	je     800484 <vprintfmt+0x17>
			if (ch == '\0')
  800855:	85 c0                	test   %eax,%eax
  800857:	0f 84 8b 00 00 00    	je     8008e8 <vprintfmt+0x47b>
			putch(ch, putdat);
  80085d:	83 ec 08             	sub    $0x8,%esp
  800860:	53                   	push   %ebx
  800861:	50                   	push   %eax
  800862:	ff d6                	call   *%esi
  800864:	83 c4 10             	add    $0x10,%esp
  800867:	eb dc                	jmp    800845 <vprintfmt+0x3d8>
	if (lflag >= 2)
  800869:	83 f9 01             	cmp    $0x1,%ecx
  80086c:	7e 15                	jle    800883 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  80086e:	8b 45 14             	mov    0x14(%ebp),%eax
  800871:	8b 10                	mov    (%eax),%edx
  800873:	8b 48 04             	mov    0x4(%eax),%ecx
  800876:	8d 40 08             	lea    0x8(%eax),%eax
  800879:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80087c:	b8 10 00 00 00       	mov    $0x10,%eax
  800881:	eb a5                	jmp    800828 <vprintfmt+0x3bb>
	else if (lflag)
  800883:	85 c9                	test   %ecx,%ecx
  800885:	75 17                	jne    80089e <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  800887:	8b 45 14             	mov    0x14(%ebp),%eax
  80088a:	8b 10                	mov    (%eax),%edx
  80088c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800891:	8d 40 04             	lea    0x4(%eax),%eax
  800894:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800897:	b8 10 00 00 00       	mov    $0x10,%eax
  80089c:	eb 8a                	jmp    800828 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80089e:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a1:	8b 10                	mov    (%eax),%edx
  8008a3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008a8:	8d 40 04             	lea    0x4(%eax),%eax
  8008ab:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008ae:	b8 10 00 00 00       	mov    $0x10,%eax
  8008b3:	e9 70 ff ff ff       	jmp    800828 <vprintfmt+0x3bb>
			putch(ch, putdat);
  8008b8:	83 ec 08             	sub    $0x8,%esp
  8008bb:	53                   	push   %ebx
  8008bc:	6a 25                	push   $0x25
  8008be:	ff d6                	call   *%esi
			break;
  8008c0:	83 c4 10             	add    $0x10,%esp
  8008c3:	e9 7a ff ff ff       	jmp    800842 <vprintfmt+0x3d5>
			putch('%', putdat);
  8008c8:	83 ec 08             	sub    $0x8,%esp
  8008cb:	53                   	push   %ebx
  8008cc:	6a 25                	push   $0x25
  8008ce:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008d0:	83 c4 10             	add    $0x10,%esp
  8008d3:	89 f8                	mov    %edi,%eax
  8008d5:	eb 03                	jmp    8008da <vprintfmt+0x46d>
  8008d7:	83 e8 01             	sub    $0x1,%eax
  8008da:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8008de:	75 f7                	jne    8008d7 <vprintfmt+0x46a>
  8008e0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008e3:	e9 5a ff ff ff       	jmp    800842 <vprintfmt+0x3d5>
}
  8008e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008eb:	5b                   	pop    %ebx
  8008ec:	5e                   	pop    %esi
  8008ed:	5f                   	pop    %edi
  8008ee:	5d                   	pop    %ebp
  8008ef:	c3                   	ret    

008008f0 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
  8008f3:	83 ec 18             	sub    $0x18,%esp
  8008f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008fc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008ff:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800903:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800906:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80090d:	85 c0                	test   %eax,%eax
  80090f:	74 26                	je     800937 <vsnprintf+0x47>
  800911:	85 d2                	test   %edx,%edx
  800913:	7e 22                	jle    800937 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800915:	ff 75 14             	pushl  0x14(%ebp)
  800918:	ff 75 10             	pushl  0x10(%ebp)
  80091b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80091e:	50                   	push   %eax
  80091f:	68 33 04 80 00       	push   $0x800433
  800924:	e8 44 fb ff ff       	call   80046d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800929:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80092c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80092f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800932:	83 c4 10             	add    $0x10,%esp
}
  800935:	c9                   	leave  
  800936:	c3                   	ret    
		return -E_INVAL;
  800937:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80093c:	eb f7                	jmp    800935 <vsnprintf+0x45>

0080093e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800944:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800947:	50                   	push   %eax
  800948:	ff 75 10             	pushl  0x10(%ebp)
  80094b:	ff 75 0c             	pushl  0xc(%ebp)
  80094e:	ff 75 08             	pushl  0x8(%ebp)
  800951:	e8 9a ff ff ff       	call   8008f0 <vsnprintf>
	va_end(ap);

	return rc;
}
  800956:	c9                   	leave  
  800957:	c3                   	ret    

00800958 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80095e:	b8 00 00 00 00       	mov    $0x0,%eax
  800963:	eb 03                	jmp    800968 <strlen+0x10>
		n++;
  800965:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800968:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80096c:	75 f7                	jne    800965 <strlen+0xd>
	return n;
}
  80096e:	5d                   	pop    %ebp
  80096f:	c3                   	ret    

00800970 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800976:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800979:	b8 00 00 00 00       	mov    $0x0,%eax
  80097e:	eb 03                	jmp    800983 <strnlen+0x13>
		n++;
  800980:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800983:	39 d0                	cmp    %edx,%eax
  800985:	74 06                	je     80098d <strnlen+0x1d>
  800987:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80098b:	75 f3                	jne    800980 <strnlen+0x10>
	return n;
}
  80098d:	5d                   	pop    %ebp
  80098e:	c3                   	ret    

0080098f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80098f:	55                   	push   %ebp
  800990:	89 e5                	mov    %esp,%ebp
  800992:	53                   	push   %ebx
  800993:	8b 45 08             	mov    0x8(%ebp),%eax
  800996:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800999:	89 c2                	mov    %eax,%edx
  80099b:	83 c1 01             	add    $0x1,%ecx
  80099e:	83 c2 01             	add    $0x1,%edx
  8009a1:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009a5:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009a8:	84 db                	test   %bl,%bl
  8009aa:	75 ef                	jne    80099b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009ac:	5b                   	pop    %ebx
  8009ad:	5d                   	pop    %ebp
  8009ae:	c3                   	ret    

008009af <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009af:	55                   	push   %ebp
  8009b0:	89 e5                	mov    %esp,%ebp
  8009b2:	53                   	push   %ebx
  8009b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009b6:	53                   	push   %ebx
  8009b7:	e8 9c ff ff ff       	call   800958 <strlen>
  8009bc:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009bf:	ff 75 0c             	pushl  0xc(%ebp)
  8009c2:	01 d8                	add    %ebx,%eax
  8009c4:	50                   	push   %eax
  8009c5:	e8 c5 ff ff ff       	call   80098f <strcpy>
	return dst;
}
  8009ca:	89 d8                	mov    %ebx,%eax
  8009cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009cf:	c9                   	leave  
  8009d0:	c3                   	ret    

008009d1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009d1:	55                   	push   %ebp
  8009d2:	89 e5                	mov    %esp,%ebp
  8009d4:	56                   	push   %esi
  8009d5:	53                   	push   %ebx
  8009d6:	8b 75 08             	mov    0x8(%ebp),%esi
  8009d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009dc:	89 f3                	mov    %esi,%ebx
  8009de:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009e1:	89 f2                	mov    %esi,%edx
  8009e3:	eb 0f                	jmp    8009f4 <strncpy+0x23>
		*dst++ = *src;
  8009e5:	83 c2 01             	add    $0x1,%edx
  8009e8:	0f b6 01             	movzbl (%ecx),%eax
  8009eb:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009ee:	80 39 01             	cmpb   $0x1,(%ecx)
  8009f1:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8009f4:	39 da                	cmp    %ebx,%edx
  8009f6:	75 ed                	jne    8009e5 <strncpy+0x14>
	}
	return ret;
}
  8009f8:	89 f0                	mov    %esi,%eax
  8009fa:	5b                   	pop    %ebx
  8009fb:	5e                   	pop    %esi
  8009fc:	5d                   	pop    %ebp
  8009fd:	c3                   	ret    

008009fe <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
  800a01:	56                   	push   %esi
  800a02:	53                   	push   %ebx
  800a03:	8b 75 08             	mov    0x8(%ebp),%esi
  800a06:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a09:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800a0c:	89 f0                	mov    %esi,%eax
  800a0e:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a12:	85 c9                	test   %ecx,%ecx
  800a14:	75 0b                	jne    800a21 <strlcpy+0x23>
  800a16:	eb 17                	jmp    800a2f <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a18:	83 c2 01             	add    $0x1,%edx
  800a1b:	83 c0 01             	add    $0x1,%eax
  800a1e:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800a21:	39 d8                	cmp    %ebx,%eax
  800a23:	74 07                	je     800a2c <strlcpy+0x2e>
  800a25:	0f b6 0a             	movzbl (%edx),%ecx
  800a28:	84 c9                	test   %cl,%cl
  800a2a:	75 ec                	jne    800a18 <strlcpy+0x1a>
		*dst = '\0';
  800a2c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a2f:	29 f0                	sub    %esi,%eax
}
  800a31:	5b                   	pop    %ebx
  800a32:	5e                   	pop    %esi
  800a33:	5d                   	pop    %ebp
  800a34:	c3                   	ret    

00800a35 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a35:	55                   	push   %ebp
  800a36:	89 e5                	mov    %esp,%ebp
  800a38:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a3b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a3e:	eb 06                	jmp    800a46 <strcmp+0x11>
		p++, q++;
  800a40:	83 c1 01             	add    $0x1,%ecx
  800a43:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800a46:	0f b6 01             	movzbl (%ecx),%eax
  800a49:	84 c0                	test   %al,%al
  800a4b:	74 04                	je     800a51 <strcmp+0x1c>
  800a4d:	3a 02                	cmp    (%edx),%al
  800a4f:	74 ef                	je     800a40 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a51:	0f b6 c0             	movzbl %al,%eax
  800a54:	0f b6 12             	movzbl (%edx),%edx
  800a57:	29 d0                	sub    %edx,%eax
}
  800a59:	5d                   	pop    %ebp
  800a5a:	c3                   	ret    

00800a5b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	53                   	push   %ebx
  800a5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a62:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a65:	89 c3                	mov    %eax,%ebx
  800a67:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a6a:	eb 06                	jmp    800a72 <strncmp+0x17>
		n--, p++, q++;
  800a6c:	83 c0 01             	add    $0x1,%eax
  800a6f:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a72:	39 d8                	cmp    %ebx,%eax
  800a74:	74 16                	je     800a8c <strncmp+0x31>
  800a76:	0f b6 08             	movzbl (%eax),%ecx
  800a79:	84 c9                	test   %cl,%cl
  800a7b:	74 04                	je     800a81 <strncmp+0x26>
  800a7d:	3a 0a                	cmp    (%edx),%cl
  800a7f:	74 eb                	je     800a6c <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a81:	0f b6 00             	movzbl (%eax),%eax
  800a84:	0f b6 12             	movzbl (%edx),%edx
  800a87:	29 d0                	sub    %edx,%eax
}
  800a89:	5b                   	pop    %ebx
  800a8a:	5d                   	pop    %ebp
  800a8b:	c3                   	ret    
		return 0;
  800a8c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a91:	eb f6                	jmp    800a89 <strncmp+0x2e>

00800a93 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a93:	55                   	push   %ebp
  800a94:	89 e5                	mov    %esp,%ebp
  800a96:	8b 45 08             	mov    0x8(%ebp),%eax
  800a99:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a9d:	0f b6 10             	movzbl (%eax),%edx
  800aa0:	84 d2                	test   %dl,%dl
  800aa2:	74 09                	je     800aad <strchr+0x1a>
		if (*s == c)
  800aa4:	38 ca                	cmp    %cl,%dl
  800aa6:	74 0a                	je     800ab2 <strchr+0x1f>
	for (; *s; s++)
  800aa8:	83 c0 01             	add    $0x1,%eax
  800aab:	eb f0                	jmp    800a9d <strchr+0xa>
			return (char *) s;
	return 0;
  800aad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab2:	5d                   	pop    %ebp
  800ab3:	c3                   	ret    

00800ab4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ab4:	55                   	push   %ebp
  800ab5:	89 e5                	mov    %esp,%ebp
  800ab7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aba:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800abe:	eb 03                	jmp    800ac3 <strfind+0xf>
  800ac0:	83 c0 01             	add    $0x1,%eax
  800ac3:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ac6:	38 ca                	cmp    %cl,%dl
  800ac8:	74 04                	je     800ace <strfind+0x1a>
  800aca:	84 d2                	test   %dl,%dl
  800acc:	75 f2                	jne    800ac0 <strfind+0xc>
			break;
	return (char *) s;
}
  800ace:	5d                   	pop    %ebp
  800acf:	c3                   	ret    

00800ad0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ad0:	55                   	push   %ebp
  800ad1:	89 e5                	mov    %esp,%ebp
  800ad3:	57                   	push   %edi
  800ad4:	56                   	push   %esi
  800ad5:	53                   	push   %ebx
  800ad6:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ad9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800adc:	85 c9                	test   %ecx,%ecx
  800ade:	74 13                	je     800af3 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ae0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ae6:	75 05                	jne    800aed <memset+0x1d>
  800ae8:	f6 c1 03             	test   $0x3,%cl
  800aeb:	74 0d                	je     800afa <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800aed:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af0:	fc                   	cld    
  800af1:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800af3:	89 f8                	mov    %edi,%eax
  800af5:	5b                   	pop    %ebx
  800af6:	5e                   	pop    %esi
  800af7:	5f                   	pop    %edi
  800af8:	5d                   	pop    %ebp
  800af9:	c3                   	ret    
		c &= 0xFF;
  800afa:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800afe:	89 d3                	mov    %edx,%ebx
  800b00:	c1 e3 08             	shl    $0x8,%ebx
  800b03:	89 d0                	mov    %edx,%eax
  800b05:	c1 e0 18             	shl    $0x18,%eax
  800b08:	89 d6                	mov    %edx,%esi
  800b0a:	c1 e6 10             	shl    $0x10,%esi
  800b0d:	09 f0                	or     %esi,%eax
  800b0f:	09 c2                	or     %eax,%edx
  800b11:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800b13:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800b16:	89 d0                	mov    %edx,%eax
  800b18:	fc                   	cld    
  800b19:	f3 ab                	rep stos %eax,%es:(%edi)
  800b1b:	eb d6                	jmp    800af3 <memset+0x23>

00800b1d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b1d:	55                   	push   %ebp
  800b1e:	89 e5                	mov    %esp,%ebp
  800b20:	57                   	push   %edi
  800b21:	56                   	push   %esi
  800b22:	8b 45 08             	mov    0x8(%ebp),%eax
  800b25:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b28:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b2b:	39 c6                	cmp    %eax,%esi
  800b2d:	73 35                	jae    800b64 <memmove+0x47>
  800b2f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b32:	39 c2                	cmp    %eax,%edx
  800b34:	76 2e                	jbe    800b64 <memmove+0x47>
		s += n;
		d += n;
  800b36:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b39:	89 d6                	mov    %edx,%esi
  800b3b:	09 fe                	or     %edi,%esi
  800b3d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b43:	74 0c                	je     800b51 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b45:	83 ef 01             	sub    $0x1,%edi
  800b48:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b4b:	fd                   	std    
  800b4c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b4e:	fc                   	cld    
  800b4f:	eb 21                	jmp    800b72 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b51:	f6 c1 03             	test   $0x3,%cl
  800b54:	75 ef                	jne    800b45 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b56:	83 ef 04             	sub    $0x4,%edi
  800b59:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b5c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b5f:	fd                   	std    
  800b60:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b62:	eb ea                	jmp    800b4e <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b64:	89 f2                	mov    %esi,%edx
  800b66:	09 c2                	or     %eax,%edx
  800b68:	f6 c2 03             	test   $0x3,%dl
  800b6b:	74 09                	je     800b76 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b6d:	89 c7                	mov    %eax,%edi
  800b6f:	fc                   	cld    
  800b70:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b72:	5e                   	pop    %esi
  800b73:	5f                   	pop    %edi
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b76:	f6 c1 03             	test   $0x3,%cl
  800b79:	75 f2                	jne    800b6d <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b7b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b7e:	89 c7                	mov    %eax,%edi
  800b80:	fc                   	cld    
  800b81:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b83:	eb ed                	jmp    800b72 <memmove+0x55>

00800b85 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b88:	ff 75 10             	pushl  0x10(%ebp)
  800b8b:	ff 75 0c             	pushl  0xc(%ebp)
  800b8e:	ff 75 08             	pushl  0x8(%ebp)
  800b91:	e8 87 ff ff ff       	call   800b1d <memmove>
}
  800b96:	c9                   	leave  
  800b97:	c3                   	ret    

00800b98 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b98:	55                   	push   %ebp
  800b99:	89 e5                	mov    %esp,%ebp
  800b9b:	56                   	push   %esi
  800b9c:	53                   	push   %ebx
  800b9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ba3:	89 c6                	mov    %eax,%esi
  800ba5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ba8:	39 f0                	cmp    %esi,%eax
  800baa:	74 1c                	je     800bc8 <memcmp+0x30>
		if (*s1 != *s2)
  800bac:	0f b6 08             	movzbl (%eax),%ecx
  800baf:	0f b6 1a             	movzbl (%edx),%ebx
  800bb2:	38 d9                	cmp    %bl,%cl
  800bb4:	75 08                	jne    800bbe <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800bb6:	83 c0 01             	add    $0x1,%eax
  800bb9:	83 c2 01             	add    $0x1,%edx
  800bbc:	eb ea                	jmp    800ba8 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800bbe:	0f b6 c1             	movzbl %cl,%eax
  800bc1:	0f b6 db             	movzbl %bl,%ebx
  800bc4:	29 d8                	sub    %ebx,%eax
  800bc6:	eb 05                	jmp    800bcd <memcmp+0x35>
	}

	return 0;
  800bc8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bcd:	5b                   	pop    %ebx
  800bce:	5e                   	pop    %esi
  800bcf:	5d                   	pop    %ebp
  800bd0:	c3                   	ret    

00800bd1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800bda:	89 c2                	mov    %eax,%edx
  800bdc:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bdf:	39 d0                	cmp    %edx,%eax
  800be1:	73 09                	jae    800bec <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800be3:	38 08                	cmp    %cl,(%eax)
  800be5:	74 05                	je     800bec <memfind+0x1b>
	for (; s < ends; s++)
  800be7:	83 c0 01             	add    $0x1,%eax
  800bea:	eb f3                	jmp    800bdf <memfind+0xe>
			break;
	return (void *) s;
}
  800bec:	5d                   	pop    %ebp
  800bed:	c3                   	ret    

00800bee <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bee:	55                   	push   %ebp
  800bef:	89 e5                	mov    %esp,%ebp
  800bf1:	57                   	push   %edi
  800bf2:	56                   	push   %esi
  800bf3:	53                   	push   %ebx
  800bf4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bf7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bfa:	eb 03                	jmp    800bff <strtol+0x11>
		s++;
  800bfc:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800bff:	0f b6 01             	movzbl (%ecx),%eax
  800c02:	3c 20                	cmp    $0x20,%al
  800c04:	74 f6                	je     800bfc <strtol+0xe>
  800c06:	3c 09                	cmp    $0x9,%al
  800c08:	74 f2                	je     800bfc <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800c0a:	3c 2b                	cmp    $0x2b,%al
  800c0c:	74 2e                	je     800c3c <strtol+0x4e>
	int neg = 0;
  800c0e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800c13:	3c 2d                	cmp    $0x2d,%al
  800c15:	74 2f                	je     800c46 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c17:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c1d:	75 05                	jne    800c24 <strtol+0x36>
  800c1f:	80 39 30             	cmpb   $0x30,(%ecx)
  800c22:	74 2c                	je     800c50 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c24:	85 db                	test   %ebx,%ebx
  800c26:	75 0a                	jne    800c32 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c28:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800c2d:	80 39 30             	cmpb   $0x30,(%ecx)
  800c30:	74 28                	je     800c5a <strtol+0x6c>
		base = 10;
  800c32:	b8 00 00 00 00       	mov    $0x0,%eax
  800c37:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800c3a:	eb 50                	jmp    800c8c <strtol+0x9e>
		s++;
  800c3c:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800c3f:	bf 00 00 00 00       	mov    $0x0,%edi
  800c44:	eb d1                	jmp    800c17 <strtol+0x29>
		s++, neg = 1;
  800c46:	83 c1 01             	add    $0x1,%ecx
  800c49:	bf 01 00 00 00       	mov    $0x1,%edi
  800c4e:	eb c7                	jmp    800c17 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c50:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c54:	74 0e                	je     800c64 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800c56:	85 db                	test   %ebx,%ebx
  800c58:	75 d8                	jne    800c32 <strtol+0x44>
		s++, base = 8;
  800c5a:	83 c1 01             	add    $0x1,%ecx
  800c5d:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c62:	eb ce                	jmp    800c32 <strtol+0x44>
		s += 2, base = 16;
  800c64:	83 c1 02             	add    $0x2,%ecx
  800c67:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c6c:	eb c4                	jmp    800c32 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800c6e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c71:	89 f3                	mov    %esi,%ebx
  800c73:	80 fb 19             	cmp    $0x19,%bl
  800c76:	77 29                	ja     800ca1 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800c78:	0f be d2             	movsbl %dl,%edx
  800c7b:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c7e:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c81:	7d 30                	jge    800cb3 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800c83:	83 c1 01             	add    $0x1,%ecx
  800c86:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c8a:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c8c:	0f b6 11             	movzbl (%ecx),%edx
  800c8f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c92:	89 f3                	mov    %esi,%ebx
  800c94:	80 fb 09             	cmp    $0x9,%bl
  800c97:	77 d5                	ja     800c6e <strtol+0x80>
			dig = *s - '0';
  800c99:	0f be d2             	movsbl %dl,%edx
  800c9c:	83 ea 30             	sub    $0x30,%edx
  800c9f:	eb dd                	jmp    800c7e <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800ca1:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ca4:	89 f3                	mov    %esi,%ebx
  800ca6:	80 fb 19             	cmp    $0x19,%bl
  800ca9:	77 08                	ja     800cb3 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800cab:	0f be d2             	movsbl %dl,%edx
  800cae:	83 ea 37             	sub    $0x37,%edx
  800cb1:	eb cb                	jmp    800c7e <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800cb3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cb7:	74 05                	je     800cbe <strtol+0xd0>
		*endptr = (char *) s;
  800cb9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cbc:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800cbe:	89 c2                	mov    %eax,%edx
  800cc0:	f7 da                	neg    %edx
  800cc2:	85 ff                	test   %edi,%edi
  800cc4:	0f 45 c2             	cmovne %edx,%eax
}
  800cc7:	5b                   	pop    %ebx
  800cc8:	5e                   	pop    %esi
  800cc9:	5f                   	pop    %edi
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    

00800ccc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	57                   	push   %edi
  800cd0:	56                   	push   %esi
  800cd1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cd2:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdd:	89 c3                	mov    %eax,%ebx
  800cdf:	89 c7                	mov    %eax,%edi
  800ce1:	89 c6                	mov    %eax,%esi
  800ce3:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ce5:	5b                   	pop    %ebx
  800ce6:	5e                   	pop    %esi
  800ce7:	5f                   	pop    %edi
  800ce8:	5d                   	pop    %ebp
  800ce9:	c3                   	ret    

00800cea <sys_cgetc>:

int
sys_cgetc(void)
{
  800cea:	55                   	push   %ebp
  800ceb:	89 e5                	mov    %esp,%ebp
  800ced:	57                   	push   %edi
  800cee:	56                   	push   %esi
  800cef:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cf0:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf5:	b8 01 00 00 00       	mov    $0x1,%eax
  800cfa:	89 d1                	mov    %edx,%ecx
  800cfc:	89 d3                	mov    %edx,%ebx
  800cfe:	89 d7                	mov    %edx,%edi
  800d00:	89 d6                	mov    %edx,%esi
  800d02:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d04:	5b                   	pop    %ebx
  800d05:	5e                   	pop    %esi
  800d06:	5f                   	pop    %edi
  800d07:	5d                   	pop    %ebp
  800d08:	c3                   	ret    

00800d09 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d09:	55                   	push   %ebp
  800d0a:	89 e5                	mov    %esp,%ebp
  800d0c:	57                   	push   %edi
  800d0d:	56                   	push   %esi
  800d0e:	53                   	push   %ebx
  800d0f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d12:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d17:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1a:	b8 03 00 00 00       	mov    $0x3,%eax
  800d1f:	89 cb                	mov    %ecx,%ebx
  800d21:	89 cf                	mov    %ecx,%edi
  800d23:	89 ce                	mov    %ecx,%esi
  800d25:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d27:	85 c0                	test   %eax,%eax
  800d29:	7f 08                	jg     800d33 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2e:	5b                   	pop    %ebx
  800d2f:	5e                   	pop    %esi
  800d30:	5f                   	pop    %edi
  800d31:	5d                   	pop    %ebp
  800d32:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d33:	83 ec 0c             	sub    $0xc,%esp
  800d36:	50                   	push   %eax
  800d37:	6a 03                	push   $0x3
  800d39:	68 1f 27 80 00       	push   $0x80271f
  800d3e:	6a 23                	push   $0x23
  800d40:	68 3c 27 80 00       	push   $0x80273c
  800d45:	e8 4b f5 ff ff       	call   800295 <_panic>

00800d4a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d4a:	55                   	push   %ebp
  800d4b:	89 e5                	mov    %esp,%ebp
  800d4d:	57                   	push   %edi
  800d4e:	56                   	push   %esi
  800d4f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d50:	ba 00 00 00 00       	mov    $0x0,%edx
  800d55:	b8 02 00 00 00       	mov    $0x2,%eax
  800d5a:	89 d1                	mov    %edx,%ecx
  800d5c:	89 d3                	mov    %edx,%ebx
  800d5e:	89 d7                	mov    %edx,%edi
  800d60:	89 d6                	mov    %edx,%esi
  800d62:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d64:	5b                   	pop    %ebx
  800d65:	5e                   	pop    %esi
  800d66:	5f                   	pop    %edi
  800d67:	5d                   	pop    %ebp
  800d68:	c3                   	ret    

00800d69 <sys_yield>:

void
sys_yield(void)
{
  800d69:	55                   	push   %ebp
  800d6a:	89 e5                	mov    %esp,%ebp
  800d6c:	57                   	push   %edi
  800d6d:	56                   	push   %esi
  800d6e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d6f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d74:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d79:	89 d1                	mov    %edx,%ecx
  800d7b:	89 d3                	mov    %edx,%ebx
  800d7d:	89 d7                	mov    %edx,%edi
  800d7f:	89 d6                	mov    %edx,%esi
  800d81:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d83:	5b                   	pop    %ebx
  800d84:	5e                   	pop    %esi
  800d85:	5f                   	pop    %edi
  800d86:	5d                   	pop    %ebp
  800d87:	c3                   	ret    

00800d88 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	57                   	push   %edi
  800d8c:	56                   	push   %esi
  800d8d:	53                   	push   %ebx
  800d8e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d91:	be 00 00 00 00       	mov    $0x0,%esi
  800d96:	8b 55 08             	mov    0x8(%ebp),%edx
  800d99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9c:	b8 04 00 00 00       	mov    $0x4,%eax
  800da1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800da4:	89 f7                	mov    %esi,%edi
  800da6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800da8:	85 c0                	test   %eax,%eax
  800daa:	7f 08                	jg     800db4 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800daf:	5b                   	pop    %ebx
  800db0:	5e                   	pop    %esi
  800db1:	5f                   	pop    %edi
  800db2:	5d                   	pop    %ebp
  800db3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800db4:	83 ec 0c             	sub    $0xc,%esp
  800db7:	50                   	push   %eax
  800db8:	6a 04                	push   $0x4
  800dba:	68 1f 27 80 00       	push   $0x80271f
  800dbf:	6a 23                	push   $0x23
  800dc1:	68 3c 27 80 00       	push   $0x80273c
  800dc6:	e8 ca f4 ff ff       	call   800295 <_panic>

00800dcb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800dcb:	55                   	push   %ebp
  800dcc:	89 e5                	mov    %esp,%ebp
  800dce:	57                   	push   %edi
  800dcf:	56                   	push   %esi
  800dd0:	53                   	push   %ebx
  800dd1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dda:	b8 05 00 00 00       	mov    $0x5,%eax
  800ddf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800de2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800de5:	8b 75 18             	mov    0x18(%ebp),%esi
  800de8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dea:	85 c0                	test   %eax,%eax
  800dec:	7f 08                	jg     800df6 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800dee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df1:	5b                   	pop    %ebx
  800df2:	5e                   	pop    %esi
  800df3:	5f                   	pop    %edi
  800df4:	5d                   	pop    %ebp
  800df5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800df6:	83 ec 0c             	sub    $0xc,%esp
  800df9:	50                   	push   %eax
  800dfa:	6a 05                	push   $0x5
  800dfc:	68 1f 27 80 00       	push   $0x80271f
  800e01:	6a 23                	push   $0x23
  800e03:	68 3c 27 80 00       	push   $0x80273c
  800e08:	e8 88 f4 ff ff       	call   800295 <_panic>

00800e0d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e0d:	55                   	push   %ebp
  800e0e:	89 e5                	mov    %esp,%ebp
  800e10:	57                   	push   %edi
  800e11:	56                   	push   %esi
  800e12:	53                   	push   %ebx
  800e13:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e16:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e21:	b8 06 00 00 00       	mov    $0x6,%eax
  800e26:	89 df                	mov    %ebx,%edi
  800e28:	89 de                	mov    %ebx,%esi
  800e2a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e2c:	85 c0                	test   %eax,%eax
  800e2e:	7f 08                	jg     800e38 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e33:	5b                   	pop    %ebx
  800e34:	5e                   	pop    %esi
  800e35:	5f                   	pop    %edi
  800e36:	5d                   	pop    %ebp
  800e37:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e38:	83 ec 0c             	sub    $0xc,%esp
  800e3b:	50                   	push   %eax
  800e3c:	6a 06                	push   $0x6
  800e3e:	68 1f 27 80 00       	push   $0x80271f
  800e43:	6a 23                	push   $0x23
  800e45:	68 3c 27 80 00       	push   $0x80273c
  800e4a:	e8 46 f4 ff ff       	call   800295 <_panic>

00800e4f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e4f:	55                   	push   %ebp
  800e50:	89 e5                	mov    %esp,%ebp
  800e52:	57                   	push   %edi
  800e53:	56                   	push   %esi
  800e54:	53                   	push   %ebx
  800e55:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e58:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e63:	b8 08 00 00 00       	mov    $0x8,%eax
  800e68:	89 df                	mov    %ebx,%edi
  800e6a:	89 de                	mov    %ebx,%esi
  800e6c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e6e:	85 c0                	test   %eax,%eax
  800e70:	7f 08                	jg     800e7a <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e72:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e75:	5b                   	pop    %ebx
  800e76:	5e                   	pop    %esi
  800e77:	5f                   	pop    %edi
  800e78:	5d                   	pop    %ebp
  800e79:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e7a:	83 ec 0c             	sub    $0xc,%esp
  800e7d:	50                   	push   %eax
  800e7e:	6a 08                	push   $0x8
  800e80:	68 1f 27 80 00       	push   $0x80271f
  800e85:	6a 23                	push   $0x23
  800e87:	68 3c 27 80 00       	push   $0x80273c
  800e8c:	e8 04 f4 ff ff       	call   800295 <_panic>

00800e91 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e91:	55                   	push   %ebp
  800e92:	89 e5                	mov    %esp,%ebp
  800e94:	57                   	push   %edi
  800e95:	56                   	push   %esi
  800e96:	53                   	push   %ebx
  800e97:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e9a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea5:	b8 09 00 00 00       	mov    $0x9,%eax
  800eaa:	89 df                	mov    %ebx,%edi
  800eac:	89 de                	mov    %ebx,%esi
  800eae:	cd 30                	int    $0x30
	if(check && ret > 0)
  800eb0:	85 c0                	test   %eax,%eax
  800eb2:	7f 08                	jg     800ebc <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800eb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eb7:	5b                   	pop    %ebx
  800eb8:	5e                   	pop    %esi
  800eb9:	5f                   	pop    %edi
  800eba:	5d                   	pop    %ebp
  800ebb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ebc:	83 ec 0c             	sub    $0xc,%esp
  800ebf:	50                   	push   %eax
  800ec0:	6a 09                	push   $0x9
  800ec2:	68 1f 27 80 00       	push   $0x80271f
  800ec7:	6a 23                	push   $0x23
  800ec9:	68 3c 27 80 00       	push   $0x80273c
  800ece:	e8 c2 f3 ff ff       	call   800295 <_panic>

00800ed3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ed3:	55                   	push   %ebp
  800ed4:	89 e5                	mov    %esp,%ebp
  800ed6:	57                   	push   %edi
  800ed7:	56                   	push   %esi
  800ed8:	53                   	push   %ebx
  800ed9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800edc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ee1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800eec:	89 df                	mov    %ebx,%edi
  800eee:	89 de                	mov    %ebx,%esi
  800ef0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ef2:	85 c0                	test   %eax,%eax
  800ef4:	7f 08                	jg     800efe <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ef6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ef9:	5b                   	pop    %ebx
  800efa:	5e                   	pop    %esi
  800efb:	5f                   	pop    %edi
  800efc:	5d                   	pop    %ebp
  800efd:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800efe:	83 ec 0c             	sub    $0xc,%esp
  800f01:	50                   	push   %eax
  800f02:	6a 0a                	push   $0xa
  800f04:	68 1f 27 80 00       	push   $0x80271f
  800f09:	6a 23                	push   $0x23
  800f0b:	68 3c 27 80 00       	push   $0x80273c
  800f10:	e8 80 f3 ff ff       	call   800295 <_panic>

00800f15 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f15:	55                   	push   %ebp
  800f16:	89 e5                	mov    %esp,%ebp
  800f18:	57                   	push   %edi
  800f19:	56                   	push   %esi
  800f1a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f21:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f26:	be 00 00 00 00       	mov    $0x0,%esi
  800f2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f2e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f31:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f33:	5b                   	pop    %ebx
  800f34:	5e                   	pop    %esi
  800f35:	5f                   	pop    %edi
  800f36:	5d                   	pop    %ebp
  800f37:	c3                   	ret    

00800f38 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f38:	55                   	push   %ebp
  800f39:	89 e5                	mov    %esp,%ebp
  800f3b:	57                   	push   %edi
  800f3c:	56                   	push   %esi
  800f3d:	53                   	push   %ebx
  800f3e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f41:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f46:	8b 55 08             	mov    0x8(%ebp),%edx
  800f49:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f4e:	89 cb                	mov    %ecx,%ebx
  800f50:	89 cf                	mov    %ecx,%edi
  800f52:	89 ce                	mov    %ecx,%esi
  800f54:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f56:	85 c0                	test   %eax,%eax
  800f58:	7f 08                	jg     800f62 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f5d:	5b                   	pop    %ebx
  800f5e:	5e                   	pop    %esi
  800f5f:	5f                   	pop    %edi
  800f60:	5d                   	pop    %ebp
  800f61:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f62:	83 ec 0c             	sub    $0xc,%esp
  800f65:	50                   	push   %eax
  800f66:	6a 0d                	push   $0xd
  800f68:	68 1f 27 80 00       	push   $0x80271f
  800f6d:	6a 23                	push   $0x23
  800f6f:	68 3c 27 80 00       	push   $0x80273c
  800f74:	e8 1c f3 ff ff       	call   800295 <_panic>

00800f79 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f79:	55                   	push   %ebp
  800f7a:	89 e5                	mov    %esp,%ebp
  800f7c:	56                   	push   %esi
  800f7d:	53                   	push   %ebx
  800f7e:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f81:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if((err&FEC_WR)==0 || (uvpt[PGNUM(addr)]&(PTE_W|PTE_COW))==0){
  800f83:	8b 40 04             	mov    0x4(%eax),%eax
  800f86:	83 e0 02             	and    $0x2,%eax
  800f89:	0f 84 82 00 00 00    	je     801011 <pgfault+0x98>
  800f8f:	89 da                	mov    %ebx,%edx
  800f91:	c1 ea 0c             	shr    $0xc,%edx
  800f94:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f9b:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800fa1:	74 6e                	je     801011 <pgfault+0x98>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        envid_t envid = sys_getenvid();
  800fa3:	e8 a2 fd ff ff       	call   800d4a <sys_getenvid>
  800fa8:	89 c6                	mov    %eax,%esi
	r = sys_page_alloc(envid,(void *)PFTEMP,PTE_P|PTE_W|PTE_U);
  800faa:	83 ec 04             	sub    $0x4,%esp
  800fad:	6a 07                	push   $0x7
  800faf:	68 00 f0 7f 00       	push   $0x7ff000
  800fb4:	50                   	push   %eax
  800fb5:	e8 ce fd ff ff       	call   800d88 <sys_page_alloc>
	if(r<0) panic("pgfault:page allocation failed %e",r);
  800fba:	83 c4 10             	add    $0x10,%esp
  800fbd:	85 c0                	test   %eax,%eax
  800fbf:	78 72                	js     801033 <pgfault+0xba>

	addr = ROUNDDOWN(addr,PGSIZE);
  800fc1:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy((void *)PFTEMP,(const void *)addr,PGSIZE);
  800fc7:	83 ec 04             	sub    $0x4,%esp
  800fca:	68 00 10 00 00       	push   $0x1000
  800fcf:	53                   	push   %ebx
  800fd0:	68 00 f0 7f 00       	push   $0x7ff000
  800fd5:	e8 ab fb ff ff       	call   800b85 <memcpy>

	if(sys_page_map(envid,(void *)PFTEMP, envid,addr,PTE_P|PTE_W|PTE_U)<0)
  800fda:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800fe1:	53                   	push   %ebx
  800fe2:	56                   	push   %esi
  800fe3:	68 00 f0 7f 00       	push   $0x7ff000
  800fe8:	56                   	push   %esi
  800fe9:	e8 dd fd ff ff       	call   800dcb <sys_page_map>
  800fee:	83 c4 20             	add    $0x20,%esp
  800ff1:	85 c0                	test   %eax,%eax
  800ff3:	78 50                	js     801045 <pgfault+0xcc>
		panic("pgfault:page map failed\n");
	if(sys_page_unmap(envid,(void *)PFTEMP)<0)
  800ff5:	83 ec 08             	sub    $0x8,%esp
  800ff8:	68 00 f0 7f 00       	push   $0x7ff000
  800ffd:	56                   	push   %esi
  800ffe:	e8 0a fe ff ff       	call   800e0d <sys_page_unmap>
  801003:	83 c4 10             	add    $0x10,%esp
  801006:	85 c0                	test   %eax,%eax
  801008:	78 4f                	js     801059 <pgfault+0xe0>
		panic("pgfault: page upmap failed\n");
       //	panic("pgfault not implemented");
}
  80100a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80100d:	5b                   	pop    %ebx
  80100e:	5e                   	pop    %esi
  80100f:	5d                   	pop    %ebp
  801010:	c3                   	ret    
		cprintf("Where is the error %d\n",err&FEC_WR);
  801011:	83 ec 08             	sub    $0x8,%esp
  801014:	50                   	push   %eax
  801015:	68 4a 27 80 00       	push   $0x80274a
  80101a:	e8 51 f3 ff ff       	call   800370 <cprintf>
		panic("pgfault:invalid user trap");
  80101f:	83 c4 0c             	add    $0xc,%esp
  801022:	68 61 27 80 00       	push   $0x802761
  801027:	6a 1e                	push   $0x1e
  801029:	68 7b 27 80 00       	push   $0x80277b
  80102e:	e8 62 f2 ff ff       	call   800295 <_panic>
	if(r<0) panic("pgfault:page allocation failed %e",r);
  801033:	50                   	push   %eax
  801034:	68 68 28 80 00       	push   $0x802868
  801039:	6a 29                	push   $0x29
  80103b:	68 7b 27 80 00       	push   $0x80277b
  801040:	e8 50 f2 ff ff       	call   800295 <_panic>
		panic("pgfault:page map failed\n");
  801045:	83 ec 04             	sub    $0x4,%esp
  801048:	68 86 27 80 00       	push   $0x802786
  80104d:	6a 2f                	push   $0x2f
  80104f:	68 7b 27 80 00       	push   $0x80277b
  801054:	e8 3c f2 ff ff       	call   800295 <_panic>
		panic("pgfault: page upmap failed\n");
  801059:	83 ec 04             	sub    $0x4,%esp
  80105c:	68 9f 27 80 00       	push   $0x80279f
  801061:	6a 31                	push   $0x31
  801063:	68 7b 27 80 00       	push   $0x80277b
  801068:	e8 28 f2 ff ff       	call   800295 <_panic>

0080106d <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80106d:	55                   	push   %ebp
  80106e:	89 e5                	mov    %esp,%ebp
  801070:	57                   	push   %edi
  801071:	56                   	push   %esi
  801072:	53                   	push   %ebx
  801073:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	set_pgfault_handler(pgfault);
  801076:	68 79 0f 80 00       	push   $0x800f79
  80107b:	e8 b5 0e 00 00       	call   801f35 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801080:	b8 07 00 00 00       	mov    $0x7,%eax
  801085:	cd 30                	int    $0x30
  801087:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80108a:	89 45 e0             	mov    %eax,-0x20(%ebp)
       
	envid_t envid = sys_exofork();
	uintptr_t addr;
  
	if(envid<0) panic("sys_exofork failed\n");
  80108d:	83 c4 10             	add    $0x10,%esp
  801090:	85 c0                	test   %eax,%eax
  801092:	78 27                	js     8010bb <fork+0x4e>
	if(envid==0){
	  thisenv = &envs[ENVX(sys_getenvid())];
	  return 0;
	}

	for(addr=(uintptr_t)UTEXT; addr<USTACKTOP;addr+=PGSIZE){
  801094:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if(envid==0){
  801099:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80109d:	75 5e                	jne    8010fd <fork+0x90>
	  thisenv = &envs[ENVX(sys_getenvid())];
  80109f:	e8 a6 fc ff ff       	call   800d4a <sys_getenvid>
  8010a4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010a9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010ac:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010b1:	a3 04 40 80 00       	mov    %eax,0x804004
	  return 0;
  8010b6:	e9 fc 00 00 00       	jmp    8011b7 <fork+0x14a>
	if(envid<0) panic("sys_exofork failed\n");
  8010bb:	83 ec 04             	sub    $0x4,%esp
  8010be:	68 bb 27 80 00       	push   $0x8027bb
  8010c3:	6a 77                	push   $0x77
  8010c5:	68 7b 27 80 00       	push   $0x80277b
  8010ca:	e8 c6 f1 ff ff       	call   800295 <_panic>
          if((r=sys_page_map(parent_envid,va,envid,va,uvpt[pn]&PTE_SYSCALL))<0)
  8010cf:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010d6:	83 ec 0c             	sub    $0xc,%esp
  8010d9:	25 07 0e 00 00       	and    $0xe07,%eax
  8010de:	50                   	push   %eax
  8010df:	57                   	push   %edi
  8010e0:	ff 75 e0             	pushl  -0x20(%ebp)
  8010e3:	57                   	push   %edi
  8010e4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010e7:	e8 df fc ff ff       	call   800dcb <sys_page_map>
  8010ec:	83 c4 20             	add    $0x20,%esp
	for(addr=(uintptr_t)UTEXT; addr<USTACKTOP;addr+=PGSIZE){
  8010ef:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010f5:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8010fb:	74 76                	je     801173 <fork+0x106>
	   if((uvpd[PDX(addr)]&PTE_P) && uvpt[PGNUM(addr)] & PTE_P)
  8010fd:	89 d8                	mov    %ebx,%eax
  8010ff:	c1 e8 16             	shr    $0x16,%eax
  801102:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801109:	a8 01                	test   $0x1,%al
  80110b:	74 e2                	je     8010ef <fork+0x82>
  80110d:	89 de                	mov    %ebx,%esi
  80110f:	c1 ee 0c             	shr    $0xc,%esi
  801112:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801119:	a8 01                	test   $0x1,%al
  80111b:	74 d2                	je     8010ef <fork+0x82>
        envid_t parent_envid = sys_getenvid();
  80111d:	e8 28 fc ff ff       	call   800d4a <sys_getenvid>
  801122:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	void *va = (void *)(pn*PGSIZE);
  801125:	89 f7                	mov    %esi,%edi
  801127:	c1 e7 0c             	shl    $0xc,%edi
        if(uvpt[pn] & PTE_SHARE){
  80112a:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801131:	f6 c4 04             	test   $0x4,%ah
  801134:	75 99                	jne    8010cf <fork+0x62>
	if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)){
  801136:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80113d:	a8 02                	test   $0x2,%al
  80113f:	0f 85 ed 00 00 00    	jne    801232 <fork+0x1c5>
  801145:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80114c:	f6 c4 08             	test   $0x8,%ah
  80114f:	0f 85 dd 00 00 00    	jne    801232 <fork+0x1c5>
	 if((r=sys_page_map(parent_envid,va,envid,va,perm))<0)
  801155:	83 ec 0c             	sub    $0xc,%esp
  801158:	6a 05                	push   $0x5
  80115a:	57                   	push   %edi
  80115b:	ff 75 e0             	pushl  -0x20(%ebp)
  80115e:	57                   	push   %edi
  80115f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801162:	e8 64 fc ff ff       	call   800dcb <sys_page_map>
  801167:	83 c4 20             	add    $0x20,%esp
  80116a:	85 c0                	test   %eax,%eax
  80116c:	79 81                	jns    8010ef <fork+0x82>
  80116e:	e9 db 00 00 00       	jmp    80124e <fork+0x1e1>
		   duppage(envid,PGNUM(addr));
	}
        
	int r;
	if((r=sys_page_alloc(envid,(void *)UXSTACKTOP-PGSIZE,PTE_U|PTE_P|PTE_W))<0)
  801173:	83 ec 04             	sub    $0x4,%esp
  801176:	6a 07                	push   $0x7
  801178:	68 00 f0 bf ee       	push   $0xeebff000
  80117d:	ff 75 dc             	pushl  -0x24(%ebp)
  801180:	e8 03 fc ff ff       	call   800d88 <sys_page_alloc>
  801185:	83 c4 10             	add    $0x10,%esp
  801188:	85 c0                	test   %eax,%eax
  80118a:	78 36                	js     8011c2 <fork+0x155>
		panic("fork:page alloc failed %e\n",r);

	extern void _pgfault_upcall();
	if((r = sys_env_set_pgfault_upcall(envid,_pgfault_upcall)))
  80118c:	83 ec 08             	sub    $0x8,%esp
  80118f:	68 9a 1f 80 00       	push   $0x801f9a
  801194:	ff 75 dc             	pushl  -0x24(%ebp)
  801197:	e8 37 fd ff ff       	call   800ed3 <sys_env_set_pgfault_upcall>
  80119c:	83 c4 10             	add    $0x10,%esp
  80119f:	85 c0                	test   %eax,%eax
  8011a1:	75 34                	jne    8011d7 <fork+0x16a>
		panic("fork:set upcall failed %e\n",r);
	if((r = sys_env_set_status(envid,ENV_RUNNABLE))<0)
  8011a3:	83 ec 08             	sub    $0x8,%esp
  8011a6:	6a 02                	push   $0x2
  8011a8:	ff 75 dc             	pushl  -0x24(%ebp)
  8011ab:	e8 9f fc ff ff       	call   800e4f <sys_env_set_status>
  8011b0:	83 c4 10             	add    $0x10,%esp
  8011b3:	85 c0                	test   %eax,%eax
  8011b5:	78 35                	js     8011ec <fork+0x17f>
		panic("fork:set status failed %e\n",r);
	//cprintf("forkid= %d\n", envid);
	return envid;
       	
}
  8011b7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011bd:	5b                   	pop    %ebx
  8011be:	5e                   	pop    %esi
  8011bf:	5f                   	pop    %edi
  8011c0:	5d                   	pop    %ebp
  8011c1:	c3                   	ret    
		panic("fork:page alloc failed %e\n",r);
  8011c2:	50                   	push   %eax
  8011c3:	68 ff 27 80 00       	push   $0x8027ff
  8011c8:	68 84 00 00 00       	push   $0x84
  8011cd:	68 7b 27 80 00       	push   $0x80277b
  8011d2:	e8 be f0 ff ff       	call   800295 <_panic>
		panic("fork:set upcall failed %e\n",r);
  8011d7:	50                   	push   %eax
  8011d8:	68 1a 28 80 00       	push   $0x80281a
  8011dd:	68 88 00 00 00       	push   $0x88
  8011e2:	68 7b 27 80 00       	push   $0x80277b
  8011e7:	e8 a9 f0 ff ff       	call   800295 <_panic>
		panic("fork:set status failed %e\n",r);
  8011ec:	50                   	push   %eax
  8011ed:	68 35 28 80 00       	push   $0x802835
  8011f2:	68 8a 00 00 00       	push   $0x8a
  8011f7:	68 7b 27 80 00       	push   $0x80277b
  8011fc:	e8 94 f0 ff ff       	call   800295 <_panic>
		if( (r=sys_page_map(parent_envid,va,parent_envid,va,perm))<0){
  801201:	83 ec 0c             	sub    $0xc,%esp
  801204:	68 05 08 00 00       	push   $0x805
  801209:	57                   	push   %edi
  80120a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80120d:	50                   	push   %eax
  80120e:	57                   	push   %edi
  80120f:	50                   	push   %eax
  801210:	e8 b6 fb ff ff       	call   800dcb <sys_page_map>
  801215:	83 c4 20             	add    $0x20,%esp
  801218:	85 c0                	test   %eax,%eax
  80121a:	0f 89 cf fe ff ff    	jns    8010ef <fork+0x82>
		 panic("duppage:map02 failed %e",r);
  801220:	50                   	push   %eax
  801221:	68 e7 27 80 00       	push   $0x8027e7
  801226:	6a 56                	push   $0x56
  801228:	68 7b 27 80 00       	push   $0x80277b
  80122d:	e8 63 f0 ff ff       	call   800295 <_panic>
	 if((r=sys_page_map(parent_envid,va,envid,va,perm))<0)
  801232:	83 ec 0c             	sub    $0xc,%esp
  801235:	68 05 08 00 00       	push   $0x805
  80123a:	57                   	push   %edi
  80123b:	ff 75 e0             	pushl  -0x20(%ebp)
  80123e:	57                   	push   %edi
  80123f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801242:	e8 84 fb ff ff       	call   800dcb <sys_page_map>
  801247:	83 c4 20             	add    $0x20,%esp
  80124a:	85 c0                	test   %eax,%eax
  80124c:	79 b3                	jns    801201 <fork+0x194>
		 panic("duppage:map01 failed %e",r);
  80124e:	50                   	push   %eax
  80124f:	68 cf 27 80 00       	push   $0x8027cf
  801254:	6a 53                	push   $0x53
  801256:	68 7b 27 80 00       	push   $0x80277b
  80125b:	e8 35 f0 ff ff       	call   800295 <_panic>

00801260 <sfork>:

// Challenge!
int
sfork(void)
{
  801260:	55                   	push   %ebp
  801261:	89 e5                	mov    %esp,%ebp
  801263:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801266:	68 50 28 80 00       	push   $0x802850
  80126b:	68 94 00 00 00       	push   $0x94
  801270:	68 7b 27 80 00       	push   $0x80277b
  801275:	e8 1b f0 ff ff       	call   800295 <_panic>

0080127a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80127a:	55                   	push   %ebp
  80127b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80127d:	8b 45 08             	mov    0x8(%ebp),%eax
  801280:	05 00 00 00 30       	add    $0x30000000,%eax
  801285:	c1 e8 0c             	shr    $0xc,%eax
}
  801288:	5d                   	pop    %ebp
  801289:	c3                   	ret    

0080128a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80128a:	55                   	push   %ebp
  80128b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80128d:	8b 45 08             	mov    0x8(%ebp),%eax
  801290:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801295:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80129a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80129f:	5d                   	pop    %ebp
  8012a0:	c3                   	ret    

008012a1 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012a1:	55                   	push   %ebp
  8012a2:	89 e5                	mov    %esp,%ebp
  8012a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012a7:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012ac:	89 c2                	mov    %eax,%edx
  8012ae:	c1 ea 16             	shr    $0x16,%edx
  8012b1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012b8:	f6 c2 01             	test   $0x1,%dl
  8012bb:	74 2a                	je     8012e7 <fd_alloc+0x46>
  8012bd:	89 c2                	mov    %eax,%edx
  8012bf:	c1 ea 0c             	shr    $0xc,%edx
  8012c2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012c9:	f6 c2 01             	test   $0x1,%dl
  8012cc:	74 19                	je     8012e7 <fd_alloc+0x46>
  8012ce:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8012d3:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012d8:	75 d2                	jne    8012ac <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012da:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012e0:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8012e5:	eb 07                	jmp    8012ee <fd_alloc+0x4d>
			*fd_store = fd;
  8012e7:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012ee:	5d                   	pop    %ebp
  8012ef:	c3                   	ret    

008012f0 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012f0:	55                   	push   %ebp
  8012f1:	89 e5                	mov    %esp,%ebp
  8012f3:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012f6:	83 f8 1f             	cmp    $0x1f,%eax
  8012f9:	77 36                	ja     801331 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012fb:	c1 e0 0c             	shl    $0xc,%eax
  8012fe:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801303:	89 c2                	mov    %eax,%edx
  801305:	c1 ea 16             	shr    $0x16,%edx
  801308:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80130f:	f6 c2 01             	test   $0x1,%dl
  801312:	74 24                	je     801338 <fd_lookup+0x48>
  801314:	89 c2                	mov    %eax,%edx
  801316:	c1 ea 0c             	shr    $0xc,%edx
  801319:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801320:	f6 c2 01             	test   $0x1,%dl
  801323:	74 1a                	je     80133f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801325:	8b 55 0c             	mov    0xc(%ebp),%edx
  801328:	89 02                	mov    %eax,(%edx)
	return 0;
  80132a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80132f:	5d                   	pop    %ebp
  801330:	c3                   	ret    
		return -E_INVAL;
  801331:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801336:	eb f7                	jmp    80132f <fd_lookup+0x3f>
		return -E_INVAL;
  801338:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80133d:	eb f0                	jmp    80132f <fd_lookup+0x3f>
  80133f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801344:	eb e9                	jmp    80132f <fd_lookup+0x3f>

00801346 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801346:	55                   	push   %ebp
  801347:	89 e5                	mov    %esp,%ebp
  801349:	83 ec 08             	sub    $0x8,%esp
  80134c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80134f:	ba 0c 29 80 00       	mov    $0x80290c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801354:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  801359:	39 08                	cmp    %ecx,(%eax)
  80135b:	74 33                	je     801390 <dev_lookup+0x4a>
  80135d:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  801360:	8b 02                	mov    (%edx),%eax
  801362:	85 c0                	test   %eax,%eax
  801364:	75 f3                	jne    801359 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801366:	a1 04 40 80 00       	mov    0x804004,%eax
  80136b:	8b 40 48             	mov    0x48(%eax),%eax
  80136e:	83 ec 04             	sub    $0x4,%esp
  801371:	51                   	push   %ecx
  801372:	50                   	push   %eax
  801373:	68 8c 28 80 00       	push   $0x80288c
  801378:	e8 f3 ef ff ff       	call   800370 <cprintf>
	*dev = 0;
  80137d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801380:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801386:	83 c4 10             	add    $0x10,%esp
  801389:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80138e:	c9                   	leave  
  80138f:	c3                   	ret    
			*dev = devtab[i];
  801390:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801393:	89 01                	mov    %eax,(%ecx)
			return 0;
  801395:	b8 00 00 00 00       	mov    $0x0,%eax
  80139a:	eb f2                	jmp    80138e <dev_lookup+0x48>

0080139c <fd_close>:
{
  80139c:	55                   	push   %ebp
  80139d:	89 e5                	mov    %esp,%ebp
  80139f:	57                   	push   %edi
  8013a0:	56                   	push   %esi
  8013a1:	53                   	push   %ebx
  8013a2:	83 ec 1c             	sub    $0x1c,%esp
  8013a5:	8b 75 08             	mov    0x8(%ebp),%esi
  8013a8:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013ab:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013ae:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013af:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013b5:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013b8:	50                   	push   %eax
  8013b9:	e8 32 ff ff ff       	call   8012f0 <fd_lookup>
  8013be:	89 c3                	mov    %eax,%ebx
  8013c0:	83 c4 08             	add    $0x8,%esp
  8013c3:	85 c0                	test   %eax,%eax
  8013c5:	78 05                	js     8013cc <fd_close+0x30>
	    || fd != fd2)
  8013c7:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8013ca:	74 16                	je     8013e2 <fd_close+0x46>
		return (must_exist ? r : 0);
  8013cc:	89 f8                	mov    %edi,%eax
  8013ce:	84 c0                	test   %al,%al
  8013d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8013d5:	0f 44 d8             	cmove  %eax,%ebx
}
  8013d8:	89 d8                	mov    %ebx,%eax
  8013da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013dd:	5b                   	pop    %ebx
  8013de:	5e                   	pop    %esi
  8013df:	5f                   	pop    %edi
  8013e0:	5d                   	pop    %ebp
  8013e1:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013e2:	83 ec 08             	sub    $0x8,%esp
  8013e5:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8013e8:	50                   	push   %eax
  8013e9:	ff 36                	pushl  (%esi)
  8013eb:	e8 56 ff ff ff       	call   801346 <dev_lookup>
  8013f0:	89 c3                	mov    %eax,%ebx
  8013f2:	83 c4 10             	add    $0x10,%esp
  8013f5:	85 c0                	test   %eax,%eax
  8013f7:	78 15                	js     80140e <fd_close+0x72>
		if (dev->dev_close)
  8013f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013fc:	8b 40 10             	mov    0x10(%eax),%eax
  8013ff:	85 c0                	test   %eax,%eax
  801401:	74 1b                	je     80141e <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  801403:	83 ec 0c             	sub    $0xc,%esp
  801406:	56                   	push   %esi
  801407:	ff d0                	call   *%eax
  801409:	89 c3                	mov    %eax,%ebx
  80140b:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80140e:	83 ec 08             	sub    $0x8,%esp
  801411:	56                   	push   %esi
  801412:	6a 00                	push   $0x0
  801414:	e8 f4 f9 ff ff       	call   800e0d <sys_page_unmap>
	return r;
  801419:	83 c4 10             	add    $0x10,%esp
  80141c:	eb ba                	jmp    8013d8 <fd_close+0x3c>
			r = 0;
  80141e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801423:	eb e9                	jmp    80140e <fd_close+0x72>

00801425 <close>:

int
close(int fdnum)
{
  801425:	55                   	push   %ebp
  801426:	89 e5                	mov    %esp,%ebp
  801428:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80142b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80142e:	50                   	push   %eax
  80142f:	ff 75 08             	pushl  0x8(%ebp)
  801432:	e8 b9 fe ff ff       	call   8012f0 <fd_lookup>
  801437:	83 c4 08             	add    $0x8,%esp
  80143a:	85 c0                	test   %eax,%eax
  80143c:	78 10                	js     80144e <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80143e:	83 ec 08             	sub    $0x8,%esp
  801441:	6a 01                	push   $0x1
  801443:	ff 75 f4             	pushl  -0xc(%ebp)
  801446:	e8 51 ff ff ff       	call   80139c <fd_close>
  80144b:	83 c4 10             	add    $0x10,%esp
}
  80144e:	c9                   	leave  
  80144f:	c3                   	ret    

00801450 <close_all>:

void
close_all(void)
{
  801450:	55                   	push   %ebp
  801451:	89 e5                	mov    %esp,%ebp
  801453:	53                   	push   %ebx
  801454:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801457:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80145c:	83 ec 0c             	sub    $0xc,%esp
  80145f:	53                   	push   %ebx
  801460:	e8 c0 ff ff ff       	call   801425 <close>
	for (i = 0; i < MAXFD; i++)
  801465:	83 c3 01             	add    $0x1,%ebx
  801468:	83 c4 10             	add    $0x10,%esp
  80146b:	83 fb 20             	cmp    $0x20,%ebx
  80146e:	75 ec                	jne    80145c <close_all+0xc>
}
  801470:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801473:	c9                   	leave  
  801474:	c3                   	ret    

00801475 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801475:	55                   	push   %ebp
  801476:	89 e5                	mov    %esp,%ebp
  801478:	57                   	push   %edi
  801479:	56                   	push   %esi
  80147a:	53                   	push   %ebx
  80147b:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80147e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801481:	50                   	push   %eax
  801482:	ff 75 08             	pushl  0x8(%ebp)
  801485:	e8 66 fe ff ff       	call   8012f0 <fd_lookup>
  80148a:	89 c3                	mov    %eax,%ebx
  80148c:	83 c4 08             	add    $0x8,%esp
  80148f:	85 c0                	test   %eax,%eax
  801491:	0f 88 81 00 00 00    	js     801518 <dup+0xa3>
		return r;
	close(newfdnum);
  801497:	83 ec 0c             	sub    $0xc,%esp
  80149a:	ff 75 0c             	pushl  0xc(%ebp)
  80149d:	e8 83 ff ff ff       	call   801425 <close>

	newfd = INDEX2FD(newfdnum);
  8014a2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8014a5:	c1 e6 0c             	shl    $0xc,%esi
  8014a8:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8014ae:	83 c4 04             	add    $0x4,%esp
  8014b1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014b4:	e8 d1 fd ff ff       	call   80128a <fd2data>
  8014b9:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8014bb:	89 34 24             	mov    %esi,(%esp)
  8014be:	e8 c7 fd ff ff       	call   80128a <fd2data>
  8014c3:	83 c4 10             	add    $0x10,%esp
  8014c6:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014c8:	89 d8                	mov    %ebx,%eax
  8014ca:	c1 e8 16             	shr    $0x16,%eax
  8014cd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014d4:	a8 01                	test   $0x1,%al
  8014d6:	74 11                	je     8014e9 <dup+0x74>
  8014d8:	89 d8                	mov    %ebx,%eax
  8014da:	c1 e8 0c             	shr    $0xc,%eax
  8014dd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014e4:	f6 c2 01             	test   $0x1,%dl
  8014e7:	75 39                	jne    801522 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014e9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014ec:	89 d0                	mov    %edx,%eax
  8014ee:	c1 e8 0c             	shr    $0xc,%eax
  8014f1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014f8:	83 ec 0c             	sub    $0xc,%esp
  8014fb:	25 07 0e 00 00       	and    $0xe07,%eax
  801500:	50                   	push   %eax
  801501:	56                   	push   %esi
  801502:	6a 00                	push   $0x0
  801504:	52                   	push   %edx
  801505:	6a 00                	push   $0x0
  801507:	e8 bf f8 ff ff       	call   800dcb <sys_page_map>
  80150c:	89 c3                	mov    %eax,%ebx
  80150e:	83 c4 20             	add    $0x20,%esp
  801511:	85 c0                	test   %eax,%eax
  801513:	78 31                	js     801546 <dup+0xd1>
		goto err;

	return newfdnum;
  801515:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801518:	89 d8                	mov    %ebx,%eax
  80151a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80151d:	5b                   	pop    %ebx
  80151e:	5e                   	pop    %esi
  80151f:	5f                   	pop    %edi
  801520:	5d                   	pop    %ebp
  801521:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801522:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801529:	83 ec 0c             	sub    $0xc,%esp
  80152c:	25 07 0e 00 00       	and    $0xe07,%eax
  801531:	50                   	push   %eax
  801532:	57                   	push   %edi
  801533:	6a 00                	push   $0x0
  801535:	53                   	push   %ebx
  801536:	6a 00                	push   $0x0
  801538:	e8 8e f8 ff ff       	call   800dcb <sys_page_map>
  80153d:	89 c3                	mov    %eax,%ebx
  80153f:	83 c4 20             	add    $0x20,%esp
  801542:	85 c0                	test   %eax,%eax
  801544:	79 a3                	jns    8014e9 <dup+0x74>
	sys_page_unmap(0, newfd);
  801546:	83 ec 08             	sub    $0x8,%esp
  801549:	56                   	push   %esi
  80154a:	6a 00                	push   $0x0
  80154c:	e8 bc f8 ff ff       	call   800e0d <sys_page_unmap>
	sys_page_unmap(0, nva);
  801551:	83 c4 08             	add    $0x8,%esp
  801554:	57                   	push   %edi
  801555:	6a 00                	push   $0x0
  801557:	e8 b1 f8 ff ff       	call   800e0d <sys_page_unmap>
	return r;
  80155c:	83 c4 10             	add    $0x10,%esp
  80155f:	eb b7                	jmp    801518 <dup+0xa3>

00801561 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801561:	55                   	push   %ebp
  801562:	89 e5                	mov    %esp,%ebp
  801564:	53                   	push   %ebx
  801565:	83 ec 14             	sub    $0x14,%esp
  801568:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80156b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80156e:	50                   	push   %eax
  80156f:	53                   	push   %ebx
  801570:	e8 7b fd ff ff       	call   8012f0 <fd_lookup>
  801575:	83 c4 08             	add    $0x8,%esp
  801578:	85 c0                	test   %eax,%eax
  80157a:	78 3f                	js     8015bb <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80157c:	83 ec 08             	sub    $0x8,%esp
  80157f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801582:	50                   	push   %eax
  801583:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801586:	ff 30                	pushl  (%eax)
  801588:	e8 b9 fd ff ff       	call   801346 <dev_lookup>
  80158d:	83 c4 10             	add    $0x10,%esp
  801590:	85 c0                	test   %eax,%eax
  801592:	78 27                	js     8015bb <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801594:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801597:	8b 42 08             	mov    0x8(%edx),%eax
  80159a:	83 e0 03             	and    $0x3,%eax
  80159d:	83 f8 01             	cmp    $0x1,%eax
  8015a0:	74 1e                	je     8015c0 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8015a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015a5:	8b 40 08             	mov    0x8(%eax),%eax
  8015a8:	85 c0                	test   %eax,%eax
  8015aa:	74 35                	je     8015e1 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015ac:	83 ec 04             	sub    $0x4,%esp
  8015af:	ff 75 10             	pushl  0x10(%ebp)
  8015b2:	ff 75 0c             	pushl  0xc(%ebp)
  8015b5:	52                   	push   %edx
  8015b6:	ff d0                	call   *%eax
  8015b8:	83 c4 10             	add    $0x10,%esp
}
  8015bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015be:	c9                   	leave  
  8015bf:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015c0:	a1 04 40 80 00       	mov    0x804004,%eax
  8015c5:	8b 40 48             	mov    0x48(%eax),%eax
  8015c8:	83 ec 04             	sub    $0x4,%esp
  8015cb:	53                   	push   %ebx
  8015cc:	50                   	push   %eax
  8015cd:	68 d0 28 80 00       	push   $0x8028d0
  8015d2:	e8 99 ed ff ff       	call   800370 <cprintf>
		return -E_INVAL;
  8015d7:	83 c4 10             	add    $0x10,%esp
  8015da:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015df:	eb da                	jmp    8015bb <read+0x5a>
		return -E_NOT_SUPP;
  8015e1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015e6:	eb d3                	jmp    8015bb <read+0x5a>

008015e8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015e8:	55                   	push   %ebp
  8015e9:	89 e5                	mov    %esp,%ebp
  8015eb:	57                   	push   %edi
  8015ec:	56                   	push   %esi
  8015ed:	53                   	push   %ebx
  8015ee:	83 ec 0c             	sub    $0xc,%esp
  8015f1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015f4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015f7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015fc:	39 f3                	cmp    %esi,%ebx
  8015fe:	73 25                	jae    801625 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801600:	83 ec 04             	sub    $0x4,%esp
  801603:	89 f0                	mov    %esi,%eax
  801605:	29 d8                	sub    %ebx,%eax
  801607:	50                   	push   %eax
  801608:	89 d8                	mov    %ebx,%eax
  80160a:	03 45 0c             	add    0xc(%ebp),%eax
  80160d:	50                   	push   %eax
  80160e:	57                   	push   %edi
  80160f:	e8 4d ff ff ff       	call   801561 <read>
		if (m < 0)
  801614:	83 c4 10             	add    $0x10,%esp
  801617:	85 c0                	test   %eax,%eax
  801619:	78 08                	js     801623 <readn+0x3b>
			return m;
		if (m == 0)
  80161b:	85 c0                	test   %eax,%eax
  80161d:	74 06                	je     801625 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  80161f:	01 c3                	add    %eax,%ebx
  801621:	eb d9                	jmp    8015fc <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801623:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801625:	89 d8                	mov    %ebx,%eax
  801627:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80162a:	5b                   	pop    %ebx
  80162b:	5e                   	pop    %esi
  80162c:	5f                   	pop    %edi
  80162d:	5d                   	pop    %ebp
  80162e:	c3                   	ret    

0080162f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80162f:	55                   	push   %ebp
  801630:	89 e5                	mov    %esp,%ebp
  801632:	53                   	push   %ebx
  801633:	83 ec 14             	sub    $0x14,%esp
  801636:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801639:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80163c:	50                   	push   %eax
  80163d:	53                   	push   %ebx
  80163e:	e8 ad fc ff ff       	call   8012f0 <fd_lookup>
  801643:	83 c4 08             	add    $0x8,%esp
  801646:	85 c0                	test   %eax,%eax
  801648:	78 3a                	js     801684 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80164a:	83 ec 08             	sub    $0x8,%esp
  80164d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801650:	50                   	push   %eax
  801651:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801654:	ff 30                	pushl  (%eax)
  801656:	e8 eb fc ff ff       	call   801346 <dev_lookup>
  80165b:	83 c4 10             	add    $0x10,%esp
  80165e:	85 c0                	test   %eax,%eax
  801660:	78 22                	js     801684 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801662:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801665:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801669:	74 1e                	je     801689 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80166b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80166e:	8b 52 0c             	mov    0xc(%edx),%edx
  801671:	85 d2                	test   %edx,%edx
  801673:	74 35                	je     8016aa <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801675:	83 ec 04             	sub    $0x4,%esp
  801678:	ff 75 10             	pushl  0x10(%ebp)
  80167b:	ff 75 0c             	pushl  0xc(%ebp)
  80167e:	50                   	push   %eax
  80167f:	ff d2                	call   *%edx
  801681:	83 c4 10             	add    $0x10,%esp
}
  801684:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801687:	c9                   	leave  
  801688:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801689:	a1 04 40 80 00       	mov    0x804004,%eax
  80168e:	8b 40 48             	mov    0x48(%eax),%eax
  801691:	83 ec 04             	sub    $0x4,%esp
  801694:	53                   	push   %ebx
  801695:	50                   	push   %eax
  801696:	68 ec 28 80 00       	push   $0x8028ec
  80169b:	e8 d0 ec ff ff       	call   800370 <cprintf>
		return -E_INVAL;
  8016a0:	83 c4 10             	add    $0x10,%esp
  8016a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016a8:	eb da                	jmp    801684 <write+0x55>
		return -E_NOT_SUPP;
  8016aa:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016af:	eb d3                	jmp    801684 <write+0x55>

008016b1 <seek>:

int
seek(int fdnum, off_t offset)
{
  8016b1:	55                   	push   %ebp
  8016b2:	89 e5                	mov    %esp,%ebp
  8016b4:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016b7:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016ba:	50                   	push   %eax
  8016bb:	ff 75 08             	pushl  0x8(%ebp)
  8016be:	e8 2d fc ff ff       	call   8012f0 <fd_lookup>
  8016c3:	83 c4 08             	add    $0x8,%esp
  8016c6:	85 c0                	test   %eax,%eax
  8016c8:	78 0e                	js     8016d8 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016d0:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016d8:	c9                   	leave  
  8016d9:	c3                   	ret    

008016da <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016da:	55                   	push   %ebp
  8016db:	89 e5                	mov    %esp,%ebp
  8016dd:	53                   	push   %ebx
  8016de:	83 ec 14             	sub    $0x14,%esp
  8016e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016e7:	50                   	push   %eax
  8016e8:	53                   	push   %ebx
  8016e9:	e8 02 fc ff ff       	call   8012f0 <fd_lookup>
  8016ee:	83 c4 08             	add    $0x8,%esp
  8016f1:	85 c0                	test   %eax,%eax
  8016f3:	78 37                	js     80172c <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016f5:	83 ec 08             	sub    $0x8,%esp
  8016f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016fb:	50                   	push   %eax
  8016fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ff:	ff 30                	pushl  (%eax)
  801701:	e8 40 fc ff ff       	call   801346 <dev_lookup>
  801706:	83 c4 10             	add    $0x10,%esp
  801709:	85 c0                	test   %eax,%eax
  80170b:	78 1f                	js     80172c <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80170d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801710:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801714:	74 1b                	je     801731 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801716:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801719:	8b 52 18             	mov    0x18(%edx),%edx
  80171c:	85 d2                	test   %edx,%edx
  80171e:	74 32                	je     801752 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801720:	83 ec 08             	sub    $0x8,%esp
  801723:	ff 75 0c             	pushl  0xc(%ebp)
  801726:	50                   	push   %eax
  801727:	ff d2                	call   *%edx
  801729:	83 c4 10             	add    $0x10,%esp
}
  80172c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80172f:	c9                   	leave  
  801730:	c3                   	ret    
			thisenv->env_id, fdnum);
  801731:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801736:	8b 40 48             	mov    0x48(%eax),%eax
  801739:	83 ec 04             	sub    $0x4,%esp
  80173c:	53                   	push   %ebx
  80173d:	50                   	push   %eax
  80173e:	68 ac 28 80 00       	push   $0x8028ac
  801743:	e8 28 ec ff ff       	call   800370 <cprintf>
		return -E_INVAL;
  801748:	83 c4 10             	add    $0x10,%esp
  80174b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801750:	eb da                	jmp    80172c <ftruncate+0x52>
		return -E_NOT_SUPP;
  801752:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801757:	eb d3                	jmp    80172c <ftruncate+0x52>

00801759 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801759:	55                   	push   %ebp
  80175a:	89 e5                	mov    %esp,%ebp
  80175c:	53                   	push   %ebx
  80175d:	83 ec 14             	sub    $0x14,%esp
  801760:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801763:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801766:	50                   	push   %eax
  801767:	ff 75 08             	pushl  0x8(%ebp)
  80176a:	e8 81 fb ff ff       	call   8012f0 <fd_lookup>
  80176f:	83 c4 08             	add    $0x8,%esp
  801772:	85 c0                	test   %eax,%eax
  801774:	78 4b                	js     8017c1 <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801776:	83 ec 08             	sub    $0x8,%esp
  801779:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80177c:	50                   	push   %eax
  80177d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801780:	ff 30                	pushl  (%eax)
  801782:	e8 bf fb ff ff       	call   801346 <dev_lookup>
  801787:	83 c4 10             	add    $0x10,%esp
  80178a:	85 c0                	test   %eax,%eax
  80178c:	78 33                	js     8017c1 <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  80178e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801791:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801795:	74 2f                	je     8017c6 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801797:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80179a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017a1:	00 00 00 
	stat->st_isdir = 0;
  8017a4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017ab:	00 00 00 
	stat->st_dev = dev;
  8017ae:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017b4:	83 ec 08             	sub    $0x8,%esp
  8017b7:	53                   	push   %ebx
  8017b8:	ff 75 f0             	pushl  -0x10(%ebp)
  8017bb:	ff 50 14             	call   *0x14(%eax)
  8017be:	83 c4 10             	add    $0x10,%esp
}
  8017c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017c4:	c9                   	leave  
  8017c5:	c3                   	ret    
		return -E_NOT_SUPP;
  8017c6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017cb:	eb f4                	jmp    8017c1 <fstat+0x68>

008017cd <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017cd:	55                   	push   %ebp
  8017ce:	89 e5                	mov    %esp,%ebp
  8017d0:	56                   	push   %esi
  8017d1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017d2:	83 ec 08             	sub    $0x8,%esp
  8017d5:	6a 00                	push   $0x0
  8017d7:	ff 75 08             	pushl  0x8(%ebp)
  8017da:	e8 e7 01 00 00       	call   8019c6 <open>
  8017df:	89 c3                	mov    %eax,%ebx
  8017e1:	83 c4 10             	add    $0x10,%esp
  8017e4:	85 c0                	test   %eax,%eax
  8017e6:	78 1b                	js     801803 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017e8:	83 ec 08             	sub    $0x8,%esp
  8017eb:	ff 75 0c             	pushl  0xc(%ebp)
  8017ee:	50                   	push   %eax
  8017ef:	e8 65 ff ff ff       	call   801759 <fstat>
  8017f4:	89 c6                	mov    %eax,%esi
	close(fd);
  8017f6:	89 1c 24             	mov    %ebx,(%esp)
  8017f9:	e8 27 fc ff ff       	call   801425 <close>
	return r;
  8017fe:	83 c4 10             	add    $0x10,%esp
  801801:	89 f3                	mov    %esi,%ebx
}
  801803:	89 d8                	mov    %ebx,%eax
  801805:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801808:	5b                   	pop    %ebx
  801809:	5e                   	pop    %esi
  80180a:	5d                   	pop    %ebp
  80180b:	c3                   	ret    

0080180c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80180c:	55                   	push   %ebp
  80180d:	89 e5                	mov    %esp,%ebp
  80180f:	56                   	push   %esi
  801810:	53                   	push   %ebx
  801811:	89 c6                	mov    %eax,%esi
  801813:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801815:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80181c:	74 27                	je     801845 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80181e:	6a 07                	push   $0x7
  801820:	68 00 50 80 00       	push   $0x805000
  801825:	56                   	push   %esi
  801826:	ff 35 00 40 80 00    	pushl  0x804000
  80182c:	e8 05 08 00 00       	call   802036 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801831:	83 c4 0c             	add    $0xc,%esp
  801834:	6a 00                	push   $0x0
  801836:	53                   	push   %ebx
  801837:	6a 00                	push   $0x0
  801839:	e8 83 07 00 00       	call   801fc1 <ipc_recv>
}
  80183e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801841:	5b                   	pop    %ebx
  801842:	5e                   	pop    %esi
  801843:	5d                   	pop    %ebp
  801844:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801845:	83 ec 0c             	sub    $0xc,%esp
  801848:	6a 01                	push   $0x1
  80184a:	e8 3d 08 00 00       	call   80208c <ipc_find_env>
  80184f:	a3 00 40 80 00       	mov    %eax,0x804000
  801854:	83 c4 10             	add    $0x10,%esp
  801857:	eb c5                	jmp    80181e <fsipc+0x12>

00801859 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801859:	55                   	push   %ebp
  80185a:	89 e5                	mov    %esp,%ebp
  80185c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80185f:	8b 45 08             	mov    0x8(%ebp),%eax
  801862:	8b 40 0c             	mov    0xc(%eax),%eax
  801865:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80186a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80186d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801872:	ba 00 00 00 00       	mov    $0x0,%edx
  801877:	b8 02 00 00 00       	mov    $0x2,%eax
  80187c:	e8 8b ff ff ff       	call   80180c <fsipc>
}
  801881:	c9                   	leave  
  801882:	c3                   	ret    

00801883 <devfile_flush>:
{
  801883:	55                   	push   %ebp
  801884:	89 e5                	mov    %esp,%ebp
  801886:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801889:	8b 45 08             	mov    0x8(%ebp),%eax
  80188c:	8b 40 0c             	mov    0xc(%eax),%eax
  80188f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801894:	ba 00 00 00 00       	mov    $0x0,%edx
  801899:	b8 06 00 00 00       	mov    $0x6,%eax
  80189e:	e8 69 ff ff ff       	call   80180c <fsipc>
}
  8018a3:	c9                   	leave  
  8018a4:	c3                   	ret    

008018a5 <devfile_stat>:
{
  8018a5:	55                   	push   %ebp
  8018a6:	89 e5                	mov    %esp,%ebp
  8018a8:	53                   	push   %ebx
  8018a9:	83 ec 04             	sub    $0x4,%esp
  8018ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018af:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b2:	8b 40 0c             	mov    0xc(%eax),%eax
  8018b5:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8018bf:	b8 05 00 00 00       	mov    $0x5,%eax
  8018c4:	e8 43 ff ff ff       	call   80180c <fsipc>
  8018c9:	85 c0                	test   %eax,%eax
  8018cb:	78 2c                	js     8018f9 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018cd:	83 ec 08             	sub    $0x8,%esp
  8018d0:	68 00 50 80 00       	push   $0x805000
  8018d5:	53                   	push   %ebx
  8018d6:	e8 b4 f0 ff ff       	call   80098f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018db:	a1 80 50 80 00       	mov    0x805080,%eax
  8018e0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018e6:	a1 84 50 80 00       	mov    0x805084,%eax
  8018eb:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018f1:	83 c4 10             	add    $0x10,%esp
  8018f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018fc:	c9                   	leave  
  8018fd:	c3                   	ret    

008018fe <devfile_write>:
{
  8018fe:	55                   	push   %ebp
  8018ff:	89 e5                	mov    %esp,%ebp
  801901:	83 ec 0c             	sub    $0xc,%esp
  801904:	8b 45 10             	mov    0x10(%ebp),%eax
  801907:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80190c:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801911:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801914:	8b 55 08             	mov    0x8(%ebp),%edx
  801917:	8b 52 0c             	mov    0xc(%edx),%edx
  80191a:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801920:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf,buf,n);
  801925:	50                   	push   %eax
  801926:	ff 75 0c             	pushl  0xc(%ebp)
  801929:	68 08 50 80 00       	push   $0x805008
  80192e:	e8 ea f1 ff ff       	call   800b1d <memmove>
	if((r = fsipc(FSREQ_WRITE,NULL))<0)
  801933:	ba 00 00 00 00       	mov    $0x0,%edx
  801938:	b8 04 00 00 00       	mov    $0x4,%eax
  80193d:	e8 ca fe ff ff       	call   80180c <fsipc>
}
  801942:	c9                   	leave  
  801943:	c3                   	ret    

00801944 <devfile_read>:
{
  801944:	55                   	push   %ebp
  801945:	89 e5                	mov    %esp,%ebp
  801947:	56                   	push   %esi
  801948:	53                   	push   %ebx
  801949:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80194c:	8b 45 08             	mov    0x8(%ebp),%eax
  80194f:	8b 40 0c             	mov    0xc(%eax),%eax
  801952:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801957:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80195d:	ba 00 00 00 00       	mov    $0x0,%edx
  801962:	b8 03 00 00 00       	mov    $0x3,%eax
  801967:	e8 a0 fe ff ff       	call   80180c <fsipc>
  80196c:	89 c3                	mov    %eax,%ebx
  80196e:	85 c0                	test   %eax,%eax
  801970:	78 1f                	js     801991 <devfile_read+0x4d>
	assert(r <= n);
  801972:	39 f0                	cmp    %esi,%eax
  801974:	77 24                	ja     80199a <devfile_read+0x56>
	assert(r <= PGSIZE);
  801976:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80197b:	7f 33                	jg     8019b0 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80197d:	83 ec 04             	sub    $0x4,%esp
  801980:	50                   	push   %eax
  801981:	68 00 50 80 00       	push   $0x805000
  801986:	ff 75 0c             	pushl  0xc(%ebp)
  801989:	e8 8f f1 ff ff       	call   800b1d <memmove>
	return r;
  80198e:	83 c4 10             	add    $0x10,%esp
}
  801991:	89 d8                	mov    %ebx,%eax
  801993:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801996:	5b                   	pop    %ebx
  801997:	5e                   	pop    %esi
  801998:	5d                   	pop    %ebp
  801999:	c3                   	ret    
	assert(r <= n);
  80199a:	68 1c 29 80 00       	push   $0x80291c
  80199f:	68 23 29 80 00       	push   $0x802923
  8019a4:	6a 7c                	push   $0x7c
  8019a6:	68 38 29 80 00       	push   $0x802938
  8019ab:	e8 e5 e8 ff ff       	call   800295 <_panic>
	assert(r <= PGSIZE);
  8019b0:	68 43 29 80 00       	push   $0x802943
  8019b5:	68 23 29 80 00       	push   $0x802923
  8019ba:	6a 7d                	push   $0x7d
  8019bc:	68 38 29 80 00       	push   $0x802938
  8019c1:	e8 cf e8 ff ff       	call   800295 <_panic>

008019c6 <open>:
{
  8019c6:	55                   	push   %ebp
  8019c7:	89 e5                	mov    %esp,%ebp
  8019c9:	56                   	push   %esi
  8019ca:	53                   	push   %ebx
  8019cb:	83 ec 1c             	sub    $0x1c,%esp
  8019ce:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8019d1:	56                   	push   %esi
  8019d2:	e8 81 ef ff ff       	call   800958 <strlen>
  8019d7:	83 c4 10             	add    $0x10,%esp
  8019da:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019df:	7f 6c                	jg     801a4d <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8019e1:	83 ec 0c             	sub    $0xc,%esp
  8019e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019e7:	50                   	push   %eax
  8019e8:	e8 b4 f8 ff ff       	call   8012a1 <fd_alloc>
  8019ed:	89 c3                	mov    %eax,%ebx
  8019ef:	83 c4 10             	add    $0x10,%esp
  8019f2:	85 c0                	test   %eax,%eax
  8019f4:	78 3c                	js     801a32 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8019f6:	83 ec 08             	sub    $0x8,%esp
  8019f9:	56                   	push   %esi
  8019fa:	68 00 50 80 00       	push   $0x805000
  8019ff:	e8 8b ef ff ff       	call   80098f <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a04:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a07:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a0c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a0f:	b8 01 00 00 00       	mov    $0x1,%eax
  801a14:	e8 f3 fd ff ff       	call   80180c <fsipc>
  801a19:	89 c3                	mov    %eax,%ebx
  801a1b:	83 c4 10             	add    $0x10,%esp
  801a1e:	85 c0                	test   %eax,%eax
  801a20:	78 19                	js     801a3b <open+0x75>
	return fd2num(fd);
  801a22:	83 ec 0c             	sub    $0xc,%esp
  801a25:	ff 75 f4             	pushl  -0xc(%ebp)
  801a28:	e8 4d f8 ff ff       	call   80127a <fd2num>
  801a2d:	89 c3                	mov    %eax,%ebx
  801a2f:	83 c4 10             	add    $0x10,%esp
}
  801a32:	89 d8                	mov    %ebx,%eax
  801a34:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a37:	5b                   	pop    %ebx
  801a38:	5e                   	pop    %esi
  801a39:	5d                   	pop    %ebp
  801a3a:	c3                   	ret    
		fd_close(fd, 0);
  801a3b:	83 ec 08             	sub    $0x8,%esp
  801a3e:	6a 00                	push   $0x0
  801a40:	ff 75 f4             	pushl  -0xc(%ebp)
  801a43:	e8 54 f9 ff ff       	call   80139c <fd_close>
		return r;
  801a48:	83 c4 10             	add    $0x10,%esp
  801a4b:	eb e5                	jmp    801a32 <open+0x6c>
		return -E_BAD_PATH;
  801a4d:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801a52:	eb de                	jmp    801a32 <open+0x6c>

00801a54 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a54:	55                   	push   %ebp
  801a55:	89 e5                	mov    %esp,%ebp
  801a57:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a5a:	ba 00 00 00 00       	mov    $0x0,%edx
  801a5f:	b8 08 00 00 00       	mov    $0x8,%eax
  801a64:	e8 a3 fd ff ff       	call   80180c <fsipc>
}
  801a69:	c9                   	leave  
  801a6a:	c3                   	ret    

00801a6b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a6b:	55                   	push   %ebp
  801a6c:	89 e5                	mov    %esp,%ebp
  801a6e:	56                   	push   %esi
  801a6f:	53                   	push   %ebx
  801a70:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a73:	83 ec 0c             	sub    $0xc,%esp
  801a76:	ff 75 08             	pushl  0x8(%ebp)
  801a79:	e8 0c f8 ff ff       	call   80128a <fd2data>
  801a7e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a80:	83 c4 08             	add    $0x8,%esp
  801a83:	68 4f 29 80 00       	push   $0x80294f
  801a88:	53                   	push   %ebx
  801a89:	e8 01 ef ff ff       	call   80098f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a8e:	8b 46 04             	mov    0x4(%esi),%eax
  801a91:	2b 06                	sub    (%esi),%eax
  801a93:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a99:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801aa0:	00 00 00 
	stat->st_dev = &devpipe;
  801aa3:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801aaa:	30 80 00 
	return 0;
}
  801aad:	b8 00 00 00 00       	mov    $0x0,%eax
  801ab2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ab5:	5b                   	pop    %ebx
  801ab6:	5e                   	pop    %esi
  801ab7:	5d                   	pop    %ebp
  801ab8:	c3                   	ret    

00801ab9 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ab9:	55                   	push   %ebp
  801aba:	89 e5                	mov    %esp,%ebp
  801abc:	53                   	push   %ebx
  801abd:	83 ec 0c             	sub    $0xc,%esp
  801ac0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ac3:	53                   	push   %ebx
  801ac4:	6a 00                	push   $0x0
  801ac6:	e8 42 f3 ff ff       	call   800e0d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801acb:	89 1c 24             	mov    %ebx,(%esp)
  801ace:	e8 b7 f7 ff ff       	call   80128a <fd2data>
  801ad3:	83 c4 08             	add    $0x8,%esp
  801ad6:	50                   	push   %eax
  801ad7:	6a 00                	push   $0x0
  801ad9:	e8 2f f3 ff ff       	call   800e0d <sys_page_unmap>
}
  801ade:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ae1:	c9                   	leave  
  801ae2:	c3                   	ret    

00801ae3 <_pipeisclosed>:
{
  801ae3:	55                   	push   %ebp
  801ae4:	89 e5                	mov    %esp,%ebp
  801ae6:	57                   	push   %edi
  801ae7:	56                   	push   %esi
  801ae8:	53                   	push   %ebx
  801ae9:	83 ec 1c             	sub    $0x1c,%esp
  801aec:	89 c7                	mov    %eax,%edi
  801aee:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801af0:	a1 04 40 80 00       	mov    0x804004,%eax
  801af5:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801af8:	83 ec 0c             	sub    $0xc,%esp
  801afb:	57                   	push   %edi
  801afc:	e8 c4 05 00 00       	call   8020c5 <pageref>
  801b01:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801b04:	89 34 24             	mov    %esi,(%esp)
  801b07:	e8 b9 05 00 00       	call   8020c5 <pageref>
		nn = thisenv->env_runs;
  801b0c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b12:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b15:	83 c4 10             	add    $0x10,%esp
  801b18:	39 cb                	cmp    %ecx,%ebx
  801b1a:	74 1b                	je     801b37 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801b1c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b1f:	75 cf                	jne    801af0 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b21:	8b 42 58             	mov    0x58(%edx),%eax
  801b24:	6a 01                	push   $0x1
  801b26:	50                   	push   %eax
  801b27:	53                   	push   %ebx
  801b28:	68 56 29 80 00       	push   $0x802956
  801b2d:	e8 3e e8 ff ff       	call   800370 <cprintf>
  801b32:	83 c4 10             	add    $0x10,%esp
  801b35:	eb b9                	jmp    801af0 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801b37:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b3a:	0f 94 c0             	sete   %al
  801b3d:	0f b6 c0             	movzbl %al,%eax
}
  801b40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b43:	5b                   	pop    %ebx
  801b44:	5e                   	pop    %esi
  801b45:	5f                   	pop    %edi
  801b46:	5d                   	pop    %ebp
  801b47:	c3                   	ret    

00801b48 <devpipe_write>:
{
  801b48:	55                   	push   %ebp
  801b49:	89 e5                	mov    %esp,%ebp
  801b4b:	57                   	push   %edi
  801b4c:	56                   	push   %esi
  801b4d:	53                   	push   %ebx
  801b4e:	83 ec 28             	sub    $0x28,%esp
  801b51:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801b54:	56                   	push   %esi
  801b55:	e8 30 f7 ff ff       	call   80128a <fd2data>
  801b5a:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b5c:	83 c4 10             	add    $0x10,%esp
  801b5f:	bf 00 00 00 00       	mov    $0x0,%edi
  801b64:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b67:	74 4f                	je     801bb8 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b69:	8b 43 04             	mov    0x4(%ebx),%eax
  801b6c:	8b 0b                	mov    (%ebx),%ecx
  801b6e:	8d 51 20             	lea    0x20(%ecx),%edx
  801b71:	39 d0                	cmp    %edx,%eax
  801b73:	72 14                	jb     801b89 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801b75:	89 da                	mov    %ebx,%edx
  801b77:	89 f0                	mov    %esi,%eax
  801b79:	e8 65 ff ff ff       	call   801ae3 <_pipeisclosed>
  801b7e:	85 c0                	test   %eax,%eax
  801b80:	75 3a                	jne    801bbc <devpipe_write+0x74>
			sys_yield();
  801b82:	e8 e2 f1 ff ff       	call   800d69 <sys_yield>
  801b87:	eb e0                	jmp    801b69 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b8c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b90:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b93:	89 c2                	mov    %eax,%edx
  801b95:	c1 fa 1f             	sar    $0x1f,%edx
  801b98:	89 d1                	mov    %edx,%ecx
  801b9a:	c1 e9 1b             	shr    $0x1b,%ecx
  801b9d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ba0:	83 e2 1f             	and    $0x1f,%edx
  801ba3:	29 ca                	sub    %ecx,%edx
  801ba5:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ba9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bad:	83 c0 01             	add    $0x1,%eax
  801bb0:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801bb3:	83 c7 01             	add    $0x1,%edi
  801bb6:	eb ac                	jmp    801b64 <devpipe_write+0x1c>
	return i;
  801bb8:	89 f8                	mov    %edi,%eax
  801bba:	eb 05                	jmp    801bc1 <devpipe_write+0x79>
				return 0;
  801bbc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bc4:	5b                   	pop    %ebx
  801bc5:	5e                   	pop    %esi
  801bc6:	5f                   	pop    %edi
  801bc7:	5d                   	pop    %ebp
  801bc8:	c3                   	ret    

00801bc9 <devpipe_read>:
{
  801bc9:	55                   	push   %ebp
  801bca:	89 e5                	mov    %esp,%ebp
  801bcc:	57                   	push   %edi
  801bcd:	56                   	push   %esi
  801bce:	53                   	push   %ebx
  801bcf:	83 ec 18             	sub    $0x18,%esp
  801bd2:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801bd5:	57                   	push   %edi
  801bd6:	e8 af f6 ff ff       	call   80128a <fd2data>
  801bdb:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801bdd:	83 c4 10             	add    $0x10,%esp
  801be0:	be 00 00 00 00       	mov    $0x0,%esi
  801be5:	3b 75 10             	cmp    0x10(%ebp),%esi
  801be8:	74 47                	je     801c31 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  801bea:	8b 03                	mov    (%ebx),%eax
  801bec:	3b 43 04             	cmp    0x4(%ebx),%eax
  801bef:	75 22                	jne    801c13 <devpipe_read+0x4a>
			if (i > 0)
  801bf1:	85 f6                	test   %esi,%esi
  801bf3:	75 14                	jne    801c09 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801bf5:	89 da                	mov    %ebx,%edx
  801bf7:	89 f8                	mov    %edi,%eax
  801bf9:	e8 e5 fe ff ff       	call   801ae3 <_pipeisclosed>
  801bfe:	85 c0                	test   %eax,%eax
  801c00:	75 33                	jne    801c35 <devpipe_read+0x6c>
			sys_yield();
  801c02:	e8 62 f1 ff ff       	call   800d69 <sys_yield>
  801c07:	eb e1                	jmp    801bea <devpipe_read+0x21>
				return i;
  801c09:	89 f0                	mov    %esi,%eax
}
  801c0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c0e:	5b                   	pop    %ebx
  801c0f:	5e                   	pop    %esi
  801c10:	5f                   	pop    %edi
  801c11:	5d                   	pop    %ebp
  801c12:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c13:	99                   	cltd   
  801c14:	c1 ea 1b             	shr    $0x1b,%edx
  801c17:	01 d0                	add    %edx,%eax
  801c19:	83 e0 1f             	and    $0x1f,%eax
  801c1c:	29 d0                	sub    %edx,%eax
  801c1e:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801c23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c26:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801c29:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801c2c:	83 c6 01             	add    $0x1,%esi
  801c2f:	eb b4                	jmp    801be5 <devpipe_read+0x1c>
	return i;
  801c31:	89 f0                	mov    %esi,%eax
  801c33:	eb d6                	jmp    801c0b <devpipe_read+0x42>
				return 0;
  801c35:	b8 00 00 00 00       	mov    $0x0,%eax
  801c3a:	eb cf                	jmp    801c0b <devpipe_read+0x42>

00801c3c <pipe>:
{
  801c3c:	55                   	push   %ebp
  801c3d:	89 e5                	mov    %esp,%ebp
  801c3f:	56                   	push   %esi
  801c40:	53                   	push   %ebx
  801c41:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801c44:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c47:	50                   	push   %eax
  801c48:	e8 54 f6 ff ff       	call   8012a1 <fd_alloc>
  801c4d:	89 c3                	mov    %eax,%ebx
  801c4f:	83 c4 10             	add    $0x10,%esp
  801c52:	85 c0                	test   %eax,%eax
  801c54:	78 5b                	js     801cb1 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c56:	83 ec 04             	sub    $0x4,%esp
  801c59:	68 07 04 00 00       	push   $0x407
  801c5e:	ff 75 f4             	pushl  -0xc(%ebp)
  801c61:	6a 00                	push   $0x0
  801c63:	e8 20 f1 ff ff       	call   800d88 <sys_page_alloc>
  801c68:	89 c3                	mov    %eax,%ebx
  801c6a:	83 c4 10             	add    $0x10,%esp
  801c6d:	85 c0                	test   %eax,%eax
  801c6f:	78 40                	js     801cb1 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  801c71:	83 ec 0c             	sub    $0xc,%esp
  801c74:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c77:	50                   	push   %eax
  801c78:	e8 24 f6 ff ff       	call   8012a1 <fd_alloc>
  801c7d:	89 c3                	mov    %eax,%ebx
  801c7f:	83 c4 10             	add    $0x10,%esp
  801c82:	85 c0                	test   %eax,%eax
  801c84:	78 1b                	js     801ca1 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c86:	83 ec 04             	sub    $0x4,%esp
  801c89:	68 07 04 00 00       	push   $0x407
  801c8e:	ff 75 f0             	pushl  -0x10(%ebp)
  801c91:	6a 00                	push   $0x0
  801c93:	e8 f0 f0 ff ff       	call   800d88 <sys_page_alloc>
  801c98:	89 c3                	mov    %eax,%ebx
  801c9a:	83 c4 10             	add    $0x10,%esp
  801c9d:	85 c0                	test   %eax,%eax
  801c9f:	79 19                	jns    801cba <pipe+0x7e>
	sys_page_unmap(0, fd0);
  801ca1:	83 ec 08             	sub    $0x8,%esp
  801ca4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ca7:	6a 00                	push   $0x0
  801ca9:	e8 5f f1 ff ff       	call   800e0d <sys_page_unmap>
  801cae:	83 c4 10             	add    $0x10,%esp
}
  801cb1:	89 d8                	mov    %ebx,%eax
  801cb3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cb6:	5b                   	pop    %ebx
  801cb7:	5e                   	pop    %esi
  801cb8:	5d                   	pop    %ebp
  801cb9:	c3                   	ret    
	va = fd2data(fd0);
  801cba:	83 ec 0c             	sub    $0xc,%esp
  801cbd:	ff 75 f4             	pushl  -0xc(%ebp)
  801cc0:	e8 c5 f5 ff ff       	call   80128a <fd2data>
  801cc5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cc7:	83 c4 0c             	add    $0xc,%esp
  801cca:	68 07 04 00 00       	push   $0x407
  801ccf:	50                   	push   %eax
  801cd0:	6a 00                	push   $0x0
  801cd2:	e8 b1 f0 ff ff       	call   800d88 <sys_page_alloc>
  801cd7:	89 c3                	mov    %eax,%ebx
  801cd9:	83 c4 10             	add    $0x10,%esp
  801cdc:	85 c0                	test   %eax,%eax
  801cde:	0f 88 8c 00 00 00    	js     801d70 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ce4:	83 ec 0c             	sub    $0xc,%esp
  801ce7:	ff 75 f0             	pushl  -0x10(%ebp)
  801cea:	e8 9b f5 ff ff       	call   80128a <fd2data>
  801cef:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cf6:	50                   	push   %eax
  801cf7:	6a 00                	push   $0x0
  801cf9:	56                   	push   %esi
  801cfa:	6a 00                	push   $0x0
  801cfc:	e8 ca f0 ff ff       	call   800dcb <sys_page_map>
  801d01:	89 c3                	mov    %eax,%ebx
  801d03:	83 c4 20             	add    $0x20,%esp
  801d06:	85 c0                	test   %eax,%eax
  801d08:	78 58                	js     801d62 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801d0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d0d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d13:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d15:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d18:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801d1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d22:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d28:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d2d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801d34:	83 ec 0c             	sub    $0xc,%esp
  801d37:	ff 75 f4             	pushl  -0xc(%ebp)
  801d3a:	e8 3b f5 ff ff       	call   80127a <fd2num>
  801d3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d42:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d44:	83 c4 04             	add    $0x4,%esp
  801d47:	ff 75 f0             	pushl  -0x10(%ebp)
  801d4a:	e8 2b f5 ff ff       	call   80127a <fd2num>
  801d4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d52:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d55:	83 c4 10             	add    $0x10,%esp
  801d58:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d5d:	e9 4f ff ff ff       	jmp    801cb1 <pipe+0x75>
	sys_page_unmap(0, va);
  801d62:	83 ec 08             	sub    $0x8,%esp
  801d65:	56                   	push   %esi
  801d66:	6a 00                	push   $0x0
  801d68:	e8 a0 f0 ff ff       	call   800e0d <sys_page_unmap>
  801d6d:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801d70:	83 ec 08             	sub    $0x8,%esp
  801d73:	ff 75 f0             	pushl  -0x10(%ebp)
  801d76:	6a 00                	push   $0x0
  801d78:	e8 90 f0 ff ff       	call   800e0d <sys_page_unmap>
  801d7d:	83 c4 10             	add    $0x10,%esp
  801d80:	e9 1c ff ff ff       	jmp    801ca1 <pipe+0x65>

00801d85 <pipeisclosed>:
{
  801d85:	55                   	push   %ebp
  801d86:	89 e5                	mov    %esp,%ebp
  801d88:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d8b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d8e:	50                   	push   %eax
  801d8f:	ff 75 08             	pushl  0x8(%ebp)
  801d92:	e8 59 f5 ff ff       	call   8012f0 <fd_lookup>
  801d97:	83 c4 10             	add    $0x10,%esp
  801d9a:	85 c0                	test   %eax,%eax
  801d9c:	78 18                	js     801db6 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801d9e:	83 ec 0c             	sub    $0xc,%esp
  801da1:	ff 75 f4             	pushl  -0xc(%ebp)
  801da4:	e8 e1 f4 ff ff       	call   80128a <fd2data>
	return _pipeisclosed(fd, p);
  801da9:	89 c2                	mov    %eax,%edx
  801dab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dae:	e8 30 fd ff ff       	call   801ae3 <_pipeisclosed>
  801db3:	83 c4 10             	add    $0x10,%esp
}
  801db6:	c9                   	leave  
  801db7:	c3                   	ret    

00801db8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801db8:	55                   	push   %ebp
  801db9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801dbb:	b8 00 00 00 00       	mov    $0x0,%eax
  801dc0:	5d                   	pop    %ebp
  801dc1:	c3                   	ret    

00801dc2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801dc2:	55                   	push   %ebp
  801dc3:	89 e5                	mov    %esp,%ebp
  801dc5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801dc8:	68 69 29 80 00       	push   $0x802969
  801dcd:	ff 75 0c             	pushl  0xc(%ebp)
  801dd0:	e8 ba eb ff ff       	call   80098f <strcpy>
	return 0;
}
  801dd5:	b8 00 00 00 00       	mov    $0x0,%eax
  801dda:	c9                   	leave  
  801ddb:	c3                   	ret    

00801ddc <devcons_write>:
{
  801ddc:	55                   	push   %ebp
  801ddd:	89 e5                	mov    %esp,%ebp
  801ddf:	57                   	push   %edi
  801de0:	56                   	push   %esi
  801de1:	53                   	push   %ebx
  801de2:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801de8:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801ded:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801df3:	eb 2f                	jmp    801e24 <devcons_write+0x48>
		m = n - tot;
  801df5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801df8:	29 f3                	sub    %esi,%ebx
  801dfa:	83 fb 7f             	cmp    $0x7f,%ebx
  801dfd:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801e02:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801e05:	83 ec 04             	sub    $0x4,%esp
  801e08:	53                   	push   %ebx
  801e09:	89 f0                	mov    %esi,%eax
  801e0b:	03 45 0c             	add    0xc(%ebp),%eax
  801e0e:	50                   	push   %eax
  801e0f:	57                   	push   %edi
  801e10:	e8 08 ed ff ff       	call   800b1d <memmove>
		sys_cputs(buf, m);
  801e15:	83 c4 08             	add    $0x8,%esp
  801e18:	53                   	push   %ebx
  801e19:	57                   	push   %edi
  801e1a:	e8 ad ee ff ff       	call   800ccc <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801e1f:	01 de                	add    %ebx,%esi
  801e21:	83 c4 10             	add    $0x10,%esp
  801e24:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e27:	72 cc                	jb     801df5 <devcons_write+0x19>
}
  801e29:	89 f0                	mov    %esi,%eax
  801e2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e2e:	5b                   	pop    %ebx
  801e2f:	5e                   	pop    %esi
  801e30:	5f                   	pop    %edi
  801e31:	5d                   	pop    %ebp
  801e32:	c3                   	ret    

00801e33 <devcons_read>:
{
  801e33:	55                   	push   %ebp
  801e34:	89 e5                	mov    %esp,%ebp
  801e36:	83 ec 08             	sub    $0x8,%esp
  801e39:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801e3e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e42:	75 07                	jne    801e4b <devcons_read+0x18>
}
  801e44:	c9                   	leave  
  801e45:	c3                   	ret    
		sys_yield();
  801e46:	e8 1e ef ff ff       	call   800d69 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801e4b:	e8 9a ee ff ff       	call   800cea <sys_cgetc>
  801e50:	85 c0                	test   %eax,%eax
  801e52:	74 f2                	je     801e46 <devcons_read+0x13>
	if (c < 0)
  801e54:	85 c0                	test   %eax,%eax
  801e56:	78 ec                	js     801e44 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  801e58:	83 f8 04             	cmp    $0x4,%eax
  801e5b:	74 0c                	je     801e69 <devcons_read+0x36>
	*(char*)vbuf = c;
  801e5d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e60:	88 02                	mov    %al,(%edx)
	return 1;
  801e62:	b8 01 00 00 00       	mov    $0x1,%eax
  801e67:	eb db                	jmp    801e44 <devcons_read+0x11>
		return 0;
  801e69:	b8 00 00 00 00       	mov    $0x0,%eax
  801e6e:	eb d4                	jmp    801e44 <devcons_read+0x11>

00801e70 <cputchar>:
{
  801e70:	55                   	push   %ebp
  801e71:	89 e5                	mov    %esp,%ebp
  801e73:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e76:	8b 45 08             	mov    0x8(%ebp),%eax
  801e79:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801e7c:	6a 01                	push   $0x1
  801e7e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e81:	50                   	push   %eax
  801e82:	e8 45 ee ff ff       	call   800ccc <sys_cputs>
}
  801e87:	83 c4 10             	add    $0x10,%esp
  801e8a:	c9                   	leave  
  801e8b:	c3                   	ret    

00801e8c <getchar>:
{
  801e8c:	55                   	push   %ebp
  801e8d:	89 e5                	mov    %esp,%ebp
  801e8f:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801e92:	6a 01                	push   $0x1
  801e94:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e97:	50                   	push   %eax
  801e98:	6a 00                	push   $0x0
  801e9a:	e8 c2 f6 ff ff       	call   801561 <read>
	if (r < 0)
  801e9f:	83 c4 10             	add    $0x10,%esp
  801ea2:	85 c0                	test   %eax,%eax
  801ea4:	78 08                	js     801eae <getchar+0x22>
	if (r < 1)
  801ea6:	85 c0                	test   %eax,%eax
  801ea8:	7e 06                	jle    801eb0 <getchar+0x24>
	return c;
  801eaa:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801eae:	c9                   	leave  
  801eaf:	c3                   	ret    
		return -E_EOF;
  801eb0:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801eb5:	eb f7                	jmp    801eae <getchar+0x22>

00801eb7 <iscons>:
{
  801eb7:	55                   	push   %ebp
  801eb8:	89 e5                	mov    %esp,%ebp
  801eba:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ebd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ec0:	50                   	push   %eax
  801ec1:	ff 75 08             	pushl  0x8(%ebp)
  801ec4:	e8 27 f4 ff ff       	call   8012f0 <fd_lookup>
  801ec9:	83 c4 10             	add    $0x10,%esp
  801ecc:	85 c0                	test   %eax,%eax
  801ece:	78 11                	js     801ee1 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801ed0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ed3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ed9:	39 10                	cmp    %edx,(%eax)
  801edb:	0f 94 c0             	sete   %al
  801ede:	0f b6 c0             	movzbl %al,%eax
}
  801ee1:	c9                   	leave  
  801ee2:	c3                   	ret    

00801ee3 <opencons>:
{
  801ee3:	55                   	push   %ebp
  801ee4:	89 e5                	mov    %esp,%ebp
  801ee6:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801ee9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eec:	50                   	push   %eax
  801eed:	e8 af f3 ff ff       	call   8012a1 <fd_alloc>
  801ef2:	83 c4 10             	add    $0x10,%esp
  801ef5:	85 c0                	test   %eax,%eax
  801ef7:	78 3a                	js     801f33 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ef9:	83 ec 04             	sub    $0x4,%esp
  801efc:	68 07 04 00 00       	push   $0x407
  801f01:	ff 75 f4             	pushl  -0xc(%ebp)
  801f04:	6a 00                	push   $0x0
  801f06:	e8 7d ee ff ff       	call   800d88 <sys_page_alloc>
  801f0b:	83 c4 10             	add    $0x10,%esp
  801f0e:	85 c0                	test   %eax,%eax
  801f10:	78 21                	js     801f33 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801f12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f15:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f1b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f20:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f27:	83 ec 0c             	sub    $0xc,%esp
  801f2a:	50                   	push   %eax
  801f2b:	e8 4a f3 ff ff       	call   80127a <fd2num>
  801f30:	83 c4 10             	add    $0x10,%esp
}
  801f33:	c9                   	leave  
  801f34:	c3                   	ret    

00801f35 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f35:	55                   	push   %ebp
  801f36:	89 e5                	mov    %esp,%ebp
  801f38:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f3b:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f42:	74 0a                	je     801f4e <set_pgfault_handler+0x19>
			panic("set_pgfault_handler %e",r);
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
	}
       
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f44:	8b 45 08             	mov    0x8(%ebp),%eax
  801f47:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f4c:	c9                   	leave  
  801f4d:	c3                   	ret    
		if((r=sys_page_alloc(thisenv->env_id,(void *)UXSTACKTOP-PGSIZE,PTE_P|PTE_W|PTE_U))<0)
  801f4e:	a1 04 40 80 00       	mov    0x804004,%eax
  801f53:	8b 40 48             	mov    0x48(%eax),%eax
  801f56:	83 ec 04             	sub    $0x4,%esp
  801f59:	6a 07                	push   $0x7
  801f5b:	68 00 f0 bf ee       	push   $0xeebff000
  801f60:	50                   	push   %eax
  801f61:	e8 22 ee ff ff       	call   800d88 <sys_page_alloc>
  801f66:	83 c4 10             	add    $0x10,%esp
  801f69:	85 c0                	test   %eax,%eax
  801f6b:	78 1b                	js     801f88 <set_pgfault_handler+0x53>
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
  801f6d:	a1 04 40 80 00       	mov    0x804004,%eax
  801f72:	8b 40 48             	mov    0x48(%eax),%eax
  801f75:	83 ec 08             	sub    $0x8,%esp
  801f78:	68 9a 1f 80 00       	push   $0x801f9a
  801f7d:	50                   	push   %eax
  801f7e:	e8 50 ef ff ff       	call   800ed3 <sys_env_set_pgfault_upcall>
  801f83:	83 c4 10             	add    $0x10,%esp
  801f86:	eb bc                	jmp    801f44 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler %e",r);
  801f88:	50                   	push   %eax
  801f89:	68 75 29 80 00       	push   $0x802975
  801f8e:	6a 22                	push   $0x22
  801f90:	68 8c 29 80 00       	push   $0x80298c
  801f95:	e8 fb e2 ff ff       	call   800295 <_panic>

00801f9a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f9a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f9b:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801fa0:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801fa2:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 48(%esp), %ebp
  801fa5:	8b 6c 24 30          	mov    0x30(%esp),%ebp
        subl $4, %ebp
  801fa9:	83 ed 04             	sub    $0x4,%ebp
        movl %ebp, 48(%esp)
  801fac:	89 6c 24 30          	mov    %ebp,0x30(%esp)
        movl 40(%esp), %eax
  801fb0:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl %eax, (%ebp)
  801fb4:	89 45 00             	mov    %eax,0x0(%ebp)
	// Restore the trap-time registers.  After you do this, you
 	// can no longer modify any general-purpose registers.
 	// LAB 4: Your code here.
        addl $8, %esp
  801fb7:	83 c4 08             	add    $0x8,%esp
        popal
  801fba:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $4, %esp
  801fbb:	83 c4 04             	add    $0x4,%esp
        popfl
  801fbe:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  801fbf:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  801fc0:	c3                   	ret    

00801fc1 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fc1:	55                   	push   %ebp
  801fc2:	89 e5                	mov    %esp,%ebp
  801fc4:	56                   	push   %esi
  801fc5:	53                   	push   %ebx
  801fc6:	8b 75 08             	mov    0x8(%ebp),%esi
  801fc9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fcc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        //	panic("ipc_recv not implemented");
        int r;
       	if(pg!=NULL){
  801fcf:	85 c0                	test   %eax,%eax
  801fd1:	74 3b                	je     80200e <ipc_recv+0x4d>
	  r = sys_ipc_recv(pg);
  801fd3:	83 ec 0c             	sub    $0xc,%esp
  801fd6:	50                   	push   %eax
  801fd7:	e8 5c ef ff ff       	call   800f38 <sys_ipc_recv>
  801fdc:	83 c4 10             	add    $0x10,%esp
	}else
	  r = sys_ipc_recv((void *)UTOP);
	if(r<0){
  801fdf:	85 c0                	test   %eax,%eax
  801fe1:	78 3d                	js     802020 <ipc_recv+0x5f>
	if(perm_store!=NULL){
		*perm_store = 0;
            }
        	return r;
           }else{
	     if(from_env_store!=NULL)
  801fe3:	85 f6                	test   %esi,%esi
  801fe5:	74 0a                	je     801ff1 <ipc_recv+0x30>
		     *from_env_store = thisenv->env_ipc_from;
  801fe7:	a1 04 40 80 00       	mov    0x804004,%eax
  801fec:	8b 40 74             	mov    0x74(%eax),%eax
  801fef:	89 06                	mov    %eax,(%esi)
	     if(perm_store != NULL)
  801ff1:	85 db                	test   %ebx,%ebx
  801ff3:	74 0a                	je     801fff <ipc_recv+0x3e>
		     *perm_store = thisenv->env_ipc_perm;
  801ff5:	a1 04 40 80 00       	mov    0x804004,%eax
  801ffa:	8b 40 78             	mov    0x78(%eax),%eax
  801ffd:	89 03                	mov    %eax,(%ebx)
	     return thisenv->env_ipc_value;
  801fff:	a1 04 40 80 00       	mov    0x804004,%eax
  802004:	8b 40 70             	mov    0x70(%eax),%eax
	   }

}
  802007:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80200a:	5b                   	pop    %ebx
  80200b:	5e                   	pop    %esi
  80200c:	5d                   	pop    %ebp
  80200d:	c3                   	ret    
	  r = sys_ipc_recv((void *)UTOP);
  80200e:	83 ec 0c             	sub    $0xc,%esp
  802011:	68 00 00 c0 ee       	push   $0xeec00000
  802016:	e8 1d ef ff ff       	call   800f38 <sys_ipc_recv>
  80201b:	83 c4 10             	add    $0x10,%esp
  80201e:	eb bf                	jmp    801fdf <ipc_recv+0x1e>
	if(from_env_store!=NULL){
  802020:	85 f6                	test   %esi,%esi
  802022:	74 06                	je     80202a <ipc_recv+0x69>
	  *from_env_store = 0;
  802024:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if(perm_store!=NULL){
  80202a:	85 db                	test   %ebx,%ebx
  80202c:	74 d9                	je     802007 <ipc_recv+0x46>
		*perm_store = 0;
  80202e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802034:	eb d1                	jmp    802007 <ipc_recv+0x46>

00802036 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802036:	55                   	push   %ebp
  802037:	89 e5                	mov    %esp,%ebp
  802039:	57                   	push   %edi
  80203a:	56                   	push   %esi
  80203b:	53                   	push   %ebx
  80203c:	83 ec 0c             	sub    $0xc,%esp
  80203f:	8b 7d 08             	mov    0x8(%ebp),%edi
  802042:	8b 75 0c             	mov    0xc(%ebp),%esi
  802045:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if(pg==NULL) pg = (void *)UTOP;
  802048:	85 db                	test   %ebx,%ebx
  80204a:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80204f:	0f 44 d8             	cmove  %eax,%ebx
	while((r=sys_ipc_try_send(to_env,val,pg,perm))<0){
  802052:	ff 75 14             	pushl  0x14(%ebp)
  802055:	53                   	push   %ebx
  802056:	56                   	push   %esi
  802057:	57                   	push   %edi
  802058:	e8 b8 ee ff ff       	call   800f15 <sys_ipc_try_send>
  80205d:	83 c4 10             	add    $0x10,%esp
  802060:	85 c0                	test   %eax,%eax
  802062:	79 20                	jns    802084 <ipc_send+0x4e>
	    if(r!=-E_IPC_NOT_RECV){
  802064:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802067:	75 07                	jne    802070 <ipc_send+0x3a>
		    panic("ipc_send:send message failed\n");
	    }
	    sys_yield();
  802069:	e8 fb ec ff ff       	call   800d69 <sys_yield>
  80206e:	eb e2                	jmp    802052 <ipc_send+0x1c>
		    panic("ipc_send:send message failed\n");
  802070:	83 ec 04             	sub    $0x4,%esp
  802073:	68 9a 29 80 00       	push   $0x80299a
  802078:	6a 43                	push   $0x43
  80207a:	68 b8 29 80 00       	push   $0x8029b8
  80207f:	e8 11 e2 ff ff       	call   800295 <_panic>
	}

}
  802084:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802087:	5b                   	pop    %ebx
  802088:	5e                   	pop    %esi
  802089:	5f                   	pop    %edi
  80208a:	5d                   	pop    %ebp
  80208b:	c3                   	ret    

0080208c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80208c:	55                   	push   %ebp
  80208d:	89 e5                	mov    %esp,%ebp
  80208f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802092:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802097:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80209a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020a0:	8b 52 50             	mov    0x50(%edx),%edx
  8020a3:	39 ca                	cmp    %ecx,%edx
  8020a5:	74 11                	je     8020b8 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  8020a7:	83 c0 01             	add    $0x1,%eax
  8020aa:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020af:	75 e6                	jne    802097 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8020b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8020b6:	eb 0b                	jmp    8020c3 <ipc_find_env+0x37>
			return envs[i].env_id;
  8020b8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020bb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020c0:	8b 40 48             	mov    0x48(%eax),%eax
}
  8020c3:	5d                   	pop    %ebp
  8020c4:	c3                   	ret    

008020c5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020c5:	55                   	push   %ebp
  8020c6:	89 e5                	mov    %esp,%ebp
  8020c8:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020cb:	89 d0                	mov    %edx,%eax
  8020cd:	c1 e8 16             	shr    $0x16,%eax
  8020d0:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020d7:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  8020dc:	f6 c1 01             	test   $0x1,%cl
  8020df:	74 1d                	je     8020fe <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  8020e1:	c1 ea 0c             	shr    $0xc,%edx
  8020e4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020eb:	f6 c2 01             	test   $0x1,%dl
  8020ee:	74 0e                	je     8020fe <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020f0:	c1 ea 0c             	shr    $0xc,%edx
  8020f3:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020fa:	ef 
  8020fb:	0f b7 c0             	movzwl %ax,%eax
}
  8020fe:	5d                   	pop    %ebp
  8020ff:	c3                   	ret    

00802100 <__udivdi3>:
  802100:	55                   	push   %ebp
  802101:	57                   	push   %edi
  802102:	56                   	push   %esi
  802103:	53                   	push   %ebx
  802104:	83 ec 1c             	sub    $0x1c,%esp
  802107:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80210b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  80210f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802113:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  802117:	85 d2                	test   %edx,%edx
  802119:	75 35                	jne    802150 <__udivdi3+0x50>
  80211b:	39 f3                	cmp    %esi,%ebx
  80211d:	0f 87 bd 00 00 00    	ja     8021e0 <__udivdi3+0xe0>
  802123:	85 db                	test   %ebx,%ebx
  802125:	89 d9                	mov    %ebx,%ecx
  802127:	75 0b                	jne    802134 <__udivdi3+0x34>
  802129:	b8 01 00 00 00       	mov    $0x1,%eax
  80212e:	31 d2                	xor    %edx,%edx
  802130:	f7 f3                	div    %ebx
  802132:	89 c1                	mov    %eax,%ecx
  802134:	31 d2                	xor    %edx,%edx
  802136:	89 f0                	mov    %esi,%eax
  802138:	f7 f1                	div    %ecx
  80213a:	89 c6                	mov    %eax,%esi
  80213c:	89 e8                	mov    %ebp,%eax
  80213e:	89 f7                	mov    %esi,%edi
  802140:	f7 f1                	div    %ecx
  802142:	89 fa                	mov    %edi,%edx
  802144:	83 c4 1c             	add    $0x1c,%esp
  802147:	5b                   	pop    %ebx
  802148:	5e                   	pop    %esi
  802149:	5f                   	pop    %edi
  80214a:	5d                   	pop    %ebp
  80214b:	c3                   	ret    
  80214c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802150:	39 f2                	cmp    %esi,%edx
  802152:	77 7c                	ja     8021d0 <__udivdi3+0xd0>
  802154:	0f bd fa             	bsr    %edx,%edi
  802157:	83 f7 1f             	xor    $0x1f,%edi
  80215a:	0f 84 98 00 00 00    	je     8021f8 <__udivdi3+0xf8>
  802160:	89 f9                	mov    %edi,%ecx
  802162:	b8 20 00 00 00       	mov    $0x20,%eax
  802167:	29 f8                	sub    %edi,%eax
  802169:	d3 e2                	shl    %cl,%edx
  80216b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80216f:	89 c1                	mov    %eax,%ecx
  802171:	89 da                	mov    %ebx,%edx
  802173:	d3 ea                	shr    %cl,%edx
  802175:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802179:	09 d1                	or     %edx,%ecx
  80217b:	89 f2                	mov    %esi,%edx
  80217d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802181:	89 f9                	mov    %edi,%ecx
  802183:	d3 e3                	shl    %cl,%ebx
  802185:	89 c1                	mov    %eax,%ecx
  802187:	d3 ea                	shr    %cl,%edx
  802189:	89 f9                	mov    %edi,%ecx
  80218b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80218f:	d3 e6                	shl    %cl,%esi
  802191:	89 eb                	mov    %ebp,%ebx
  802193:	89 c1                	mov    %eax,%ecx
  802195:	d3 eb                	shr    %cl,%ebx
  802197:	09 de                	or     %ebx,%esi
  802199:	89 f0                	mov    %esi,%eax
  80219b:	f7 74 24 08          	divl   0x8(%esp)
  80219f:	89 d6                	mov    %edx,%esi
  8021a1:	89 c3                	mov    %eax,%ebx
  8021a3:	f7 64 24 0c          	mull   0xc(%esp)
  8021a7:	39 d6                	cmp    %edx,%esi
  8021a9:	72 0c                	jb     8021b7 <__udivdi3+0xb7>
  8021ab:	89 f9                	mov    %edi,%ecx
  8021ad:	d3 e5                	shl    %cl,%ebp
  8021af:	39 c5                	cmp    %eax,%ebp
  8021b1:	73 5d                	jae    802210 <__udivdi3+0x110>
  8021b3:	39 d6                	cmp    %edx,%esi
  8021b5:	75 59                	jne    802210 <__udivdi3+0x110>
  8021b7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8021ba:	31 ff                	xor    %edi,%edi
  8021bc:	89 fa                	mov    %edi,%edx
  8021be:	83 c4 1c             	add    $0x1c,%esp
  8021c1:	5b                   	pop    %ebx
  8021c2:	5e                   	pop    %esi
  8021c3:	5f                   	pop    %edi
  8021c4:	5d                   	pop    %ebp
  8021c5:	c3                   	ret    
  8021c6:	8d 76 00             	lea    0x0(%esi),%esi
  8021c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8021d0:	31 ff                	xor    %edi,%edi
  8021d2:	31 c0                	xor    %eax,%eax
  8021d4:	89 fa                	mov    %edi,%edx
  8021d6:	83 c4 1c             	add    $0x1c,%esp
  8021d9:	5b                   	pop    %ebx
  8021da:	5e                   	pop    %esi
  8021db:	5f                   	pop    %edi
  8021dc:	5d                   	pop    %ebp
  8021dd:	c3                   	ret    
  8021de:	66 90                	xchg   %ax,%ax
  8021e0:	31 ff                	xor    %edi,%edi
  8021e2:	89 e8                	mov    %ebp,%eax
  8021e4:	89 f2                	mov    %esi,%edx
  8021e6:	f7 f3                	div    %ebx
  8021e8:	89 fa                	mov    %edi,%edx
  8021ea:	83 c4 1c             	add    $0x1c,%esp
  8021ed:	5b                   	pop    %ebx
  8021ee:	5e                   	pop    %esi
  8021ef:	5f                   	pop    %edi
  8021f0:	5d                   	pop    %ebp
  8021f1:	c3                   	ret    
  8021f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021f8:	39 f2                	cmp    %esi,%edx
  8021fa:	72 06                	jb     802202 <__udivdi3+0x102>
  8021fc:	31 c0                	xor    %eax,%eax
  8021fe:	39 eb                	cmp    %ebp,%ebx
  802200:	77 d2                	ja     8021d4 <__udivdi3+0xd4>
  802202:	b8 01 00 00 00       	mov    $0x1,%eax
  802207:	eb cb                	jmp    8021d4 <__udivdi3+0xd4>
  802209:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802210:	89 d8                	mov    %ebx,%eax
  802212:	31 ff                	xor    %edi,%edi
  802214:	eb be                	jmp    8021d4 <__udivdi3+0xd4>
  802216:	66 90                	xchg   %ax,%ax
  802218:	66 90                	xchg   %ax,%ax
  80221a:	66 90                	xchg   %ax,%ax
  80221c:	66 90                	xchg   %ax,%ax
  80221e:	66 90                	xchg   %ax,%ax

00802220 <__umoddi3>:
  802220:	55                   	push   %ebp
  802221:	57                   	push   %edi
  802222:	56                   	push   %esi
  802223:	53                   	push   %ebx
  802224:	83 ec 1c             	sub    $0x1c,%esp
  802227:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80222b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80222f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802233:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802237:	85 ed                	test   %ebp,%ebp
  802239:	89 f0                	mov    %esi,%eax
  80223b:	89 da                	mov    %ebx,%edx
  80223d:	75 19                	jne    802258 <__umoddi3+0x38>
  80223f:	39 df                	cmp    %ebx,%edi
  802241:	0f 86 b1 00 00 00    	jbe    8022f8 <__umoddi3+0xd8>
  802247:	f7 f7                	div    %edi
  802249:	89 d0                	mov    %edx,%eax
  80224b:	31 d2                	xor    %edx,%edx
  80224d:	83 c4 1c             	add    $0x1c,%esp
  802250:	5b                   	pop    %ebx
  802251:	5e                   	pop    %esi
  802252:	5f                   	pop    %edi
  802253:	5d                   	pop    %ebp
  802254:	c3                   	ret    
  802255:	8d 76 00             	lea    0x0(%esi),%esi
  802258:	39 dd                	cmp    %ebx,%ebp
  80225a:	77 f1                	ja     80224d <__umoddi3+0x2d>
  80225c:	0f bd cd             	bsr    %ebp,%ecx
  80225f:	83 f1 1f             	xor    $0x1f,%ecx
  802262:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802266:	0f 84 b4 00 00 00    	je     802320 <__umoddi3+0x100>
  80226c:	b8 20 00 00 00       	mov    $0x20,%eax
  802271:	89 c2                	mov    %eax,%edx
  802273:	8b 44 24 04          	mov    0x4(%esp),%eax
  802277:	29 c2                	sub    %eax,%edx
  802279:	89 c1                	mov    %eax,%ecx
  80227b:	89 f8                	mov    %edi,%eax
  80227d:	d3 e5                	shl    %cl,%ebp
  80227f:	89 d1                	mov    %edx,%ecx
  802281:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802285:	d3 e8                	shr    %cl,%eax
  802287:	09 c5                	or     %eax,%ebp
  802289:	8b 44 24 04          	mov    0x4(%esp),%eax
  80228d:	89 c1                	mov    %eax,%ecx
  80228f:	d3 e7                	shl    %cl,%edi
  802291:	89 d1                	mov    %edx,%ecx
  802293:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802297:	89 df                	mov    %ebx,%edi
  802299:	d3 ef                	shr    %cl,%edi
  80229b:	89 c1                	mov    %eax,%ecx
  80229d:	89 f0                	mov    %esi,%eax
  80229f:	d3 e3                	shl    %cl,%ebx
  8022a1:	89 d1                	mov    %edx,%ecx
  8022a3:	89 fa                	mov    %edi,%edx
  8022a5:	d3 e8                	shr    %cl,%eax
  8022a7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8022ac:	09 d8                	or     %ebx,%eax
  8022ae:	f7 f5                	div    %ebp
  8022b0:	d3 e6                	shl    %cl,%esi
  8022b2:	89 d1                	mov    %edx,%ecx
  8022b4:	f7 64 24 08          	mull   0x8(%esp)
  8022b8:	39 d1                	cmp    %edx,%ecx
  8022ba:	89 c3                	mov    %eax,%ebx
  8022bc:	89 d7                	mov    %edx,%edi
  8022be:	72 06                	jb     8022c6 <__umoddi3+0xa6>
  8022c0:	75 0e                	jne    8022d0 <__umoddi3+0xb0>
  8022c2:	39 c6                	cmp    %eax,%esi
  8022c4:	73 0a                	jae    8022d0 <__umoddi3+0xb0>
  8022c6:	2b 44 24 08          	sub    0x8(%esp),%eax
  8022ca:	19 ea                	sbb    %ebp,%edx
  8022cc:	89 d7                	mov    %edx,%edi
  8022ce:	89 c3                	mov    %eax,%ebx
  8022d0:	89 ca                	mov    %ecx,%edx
  8022d2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8022d7:	29 de                	sub    %ebx,%esi
  8022d9:	19 fa                	sbb    %edi,%edx
  8022db:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  8022df:	89 d0                	mov    %edx,%eax
  8022e1:	d3 e0                	shl    %cl,%eax
  8022e3:	89 d9                	mov    %ebx,%ecx
  8022e5:	d3 ee                	shr    %cl,%esi
  8022e7:	d3 ea                	shr    %cl,%edx
  8022e9:	09 f0                	or     %esi,%eax
  8022eb:	83 c4 1c             	add    $0x1c,%esp
  8022ee:	5b                   	pop    %ebx
  8022ef:	5e                   	pop    %esi
  8022f0:	5f                   	pop    %edi
  8022f1:	5d                   	pop    %ebp
  8022f2:	c3                   	ret    
  8022f3:	90                   	nop
  8022f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022f8:	85 ff                	test   %edi,%edi
  8022fa:	89 f9                	mov    %edi,%ecx
  8022fc:	75 0b                	jne    802309 <__umoddi3+0xe9>
  8022fe:	b8 01 00 00 00       	mov    $0x1,%eax
  802303:	31 d2                	xor    %edx,%edx
  802305:	f7 f7                	div    %edi
  802307:	89 c1                	mov    %eax,%ecx
  802309:	89 d8                	mov    %ebx,%eax
  80230b:	31 d2                	xor    %edx,%edx
  80230d:	f7 f1                	div    %ecx
  80230f:	89 f0                	mov    %esi,%eax
  802311:	f7 f1                	div    %ecx
  802313:	e9 31 ff ff ff       	jmp    802249 <__umoddi3+0x29>
  802318:	90                   	nop
  802319:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802320:	39 dd                	cmp    %ebx,%ebp
  802322:	72 08                	jb     80232c <__umoddi3+0x10c>
  802324:	39 f7                	cmp    %esi,%edi
  802326:	0f 87 21 ff ff ff    	ja     80224d <__umoddi3+0x2d>
  80232c:	89 da                	mov    %ebx,%edx
  80232e:	89 f0                	mov    %esi,%eax
  802330:	29 f8                	sub    %edi,%eax
  802332:	19 ea                	sbb    %ebp,%edx
  802334:	e9 14 ff ff ff       	jmp    80224d <__umoddi3+0x2d>
