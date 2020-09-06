
obj/user/testpipe.debug:     file format elf32-i386


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
  80002c:	e8 a5 02 00 00       	call   8002d6 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char *msg = "Now is the time for all good men to come to the aid of their party.";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 7c             	sub    $0x7c,%esp
	char buf[100];
	int i, pid, p[2];

	binaryname = "pipereadeof";
  80003b:	c7 05 04 30 80 00 40 	movl   $0x802440,0x803004
  800042:	24 80 00 

	if ((i = pipe(p)) < 0)
  800045:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800048:	50                   	push   %eax
  800049:	e8 8f 1c 00 00       	call   801cdd <pipe>
  80004e:	89 c6                	mov    %eax,%esi
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	0f 88 1f 01 00 00    	js     80017a <umain+0x147>
		panic("pipe: %e", i);

	if ((pid = fork()) < 0)
  80005b:	e8 ae 10 00 00       	call   80110e <fork>
  800060:	89 c3                	mov    %eax,%ebx
  800062:	85 c0                	test   %eax,%eax
  800064:	0f 88 22 01 00 00    	js     80018c <umain+0x159>
		panic("fork: %e", i);

	if (pid == 0) {
  80006a:	85 c0                	test   %eax,%eax
  80006c:	0f 85 58 01 00 00    	jne    8001ca <umain+0x197>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[1]);
  800072:	a1 04 40 80 00       	mov    0x804004,%eax
  800077:	8b 40 48             	mov    0x48(%eax),%eax
  80007a:	83 ec 04             	sub    $0x4,%esp
  80007d:	ff 75 90             	pushl  -0x70(%ebp)
  800080:	50                   	push   %eax
  800081:	68 6e 24 80 00       	push   $0x80246e
  800086:	e8 86 03 00 00       	call   800411 <cprintf>
		close(p[1]);
  80008b:	83 c4 04             	add    $0x4,%esp
  80008e:	ff 75 90             	pushl  -0x70(%ebp)
  800091:	e8 30 14 00 00       	call   8014c6 <close>
		cprintf("[%08x] pipereadeof readn %d\n", thisenv->env_id, p[0]);
  800096:	a1 04 40 80 00       	mov    0x804004,%eax
  80009b:	8b 40 48             	mov    0x48(%eax),%eax
  80009e:	83 c4 0c             	add    $0xc,%esp
  8000a1:	ff 75 8c             	pushl  -0x74(%ebp)
  8000a4:	50                   	push   %eax
  8000a5:	68 8b 24 80 00       	push   $0x80248b
  8000aa:	e8 62 03 00 00       	call   800411 <cprintf>
		i = readn(p[0], buf, sizeof buf-1);
  8000af:	83 c4 0c             	add    $0xc,%esp
  8000b2:	6a 63                	push   $0x63
  8000b4:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000b7:	50                   	push   %eax
  8000b8:	ff 75 8c             	pushl  -0x74(%ebp)
  8000bb:	e8 c9 15 00 00       	call   801689 <readn>
  8000c0:	89 c6                	mov    %eax,%esi
		if (i < 0)
  8000c2:	83 c4 10             	add    $0x10,%esp
  8000c5:	85 c0                	test   %eax,%eax
  8000c7:	0f 88 d1 00 00 00    	js     80019e <umain+0x16b>
			panic("read: %e", i);
		buf[i] = 0;
  8000cd:	c6 44 05 94 00       	movb   $0x0,-0x6c(%ebp,%eax,1)
		if (strcmp(buf, msg) == 0)
  8000d2:	83 ec 08             	sub    $0x8,%esp
  8000d5:	ff 35 00 30 80 00    	pushl  0x803000
  8000db:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000de:	50                   	push   %eax
  8000df:	e8 f2 09 00 00       	call   800ad6 <strcmp>
  8000e4:	83 c4 10             	add    $0x10,%esp
  8000e7:	85 c0                	test   %eax,%eax
  8000e9:	0f 85 c1 00 00 00    	jne    8001b0 <umain+0x17d>
			cprintf("\npipe read closed properly\n");
  8000ef:	83 ec 0c             	sub    $0xc,%esp
  8000f2:	68 b1 24 80 00       	push   $0x8024b1
  8000f7:	e8 15 03 00 00       	call   800411 <cprintf>
  8000fc:	83 c4 10             	add    $0x10,%esp
		else
			cprintf("\ngot %d bytes: %s\n", i, buf);
		exit();
  8000ff:	e8 18 02 00 00       	call   80031c <exit>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
			panic("write: %e", i);
		close(p[1]);
	}
	wait(pid);
  800104:	83 ec 0c             	sub    $0xc,%esp
  800107:	53                   	push   %ebx
  800108:	e8 4c 1d 00 00       	call   801e59 <wait>

	binaryname = "pipewriteeof";
  80010d:	c7 05 04 30 80 00 07 	movl   $0x802507,0x803004
  800114:	25 80 00 
	if ((i = pipe(p)) < 0)
  800117:	8d 45 8c             	lea    -0x74(%ebp),%eax
  80011a:	89 04 24             	mov    %eax,(%esp)
  80011d:	e8 bb 1b 00 00       	call   801cdd <pipe>
  800122:	89 c6                	mov    %eax,%esi
  800124:	83 c4 10             	add    $0x10,%esp
  800127:	85 c0                	test   %eax,%eax
  800129:	0f 88 34 01 00 00    	js     800263 <umain+0x230>
		panic("pipe: %e", i);

	if ((pid = fork()) < 0)
  80012f:	e8 da 0f 00 00       	call   80110e <fork>
  800134:	89 c3                	mov    %eax,%ebx
  800136:	85 c0                	test   %eax,%eax
  800138:	0f 88 37 01 00 00    	js     800275 <umain+0x242>
		panic("fork: %e", i);

	if (pid == 0) {
  80013e:	85 c0                	test   %eax,%eax
  800140:	0f 84 41 01 00 00    	je     800287 <umain+0x254>
				break;
		}
		cprintf("\npipe write closed properly\n");
		exit();
	}
	close(p[0]);
  800146:	83 ec 0c             	sub    $0xc,%esp
  800149:	ff 75 8c             	pushl  -0x74(%ebp)
  80014c:	e8 75 13 00 00       	call   8014c6 <close>
	close(p[1]);
  800151:	83 c4 04             	add    $0x4,%esp
  800154:	ff 75 90             	pushl  -0x70(%ebp)
  800157:	e8 6a 13 00 00       	call   8014c6 <close>
	wait(pid);
  80015c:	89 1c 24             	mov    %ebx,(%esp)
  80015f:	e8 f5 1c 00 00       	call   801e59 <wait>

	cprintf("pipe tests passed\n");
  800164:	c7 04 24 35 25 80 00 	movl   $0x802535,(%esp)
  80016b:	e8 a1 02 00 00       	call   800411 <cprintf>
}
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800176:	5b                   	pop    %ebx
  800177:	5e                   	pop    %esi
  800178:	5d                   	pop    %ebp
  800179:	c3                   	ret    
		panic("pipe: %e", i);
  80017a:	50                   	push   %eax
  80017b:	68 4c 24 80 00       	push   $0x80244c
  800180:	6a 0e                	push   $0xe
  800182:	68 55 24 80 00       	push   $0x802455
  800187:	e8 aa 01 00 00       	call   800336 <_panic>
		panic("fork: %e", i);
  80018c:	56                   	push   %esi
  80018d:	68 65 24 80 00       	push   $0x802465
  800192:	6a 11                	push   $0x11
  800194:	68 55 24 80 00       	push   $0x802455
  800199:	e8 98 01 00 00       	call   800336 <_panic>
			panic("read: %e", i);
  80019e:	50                   	push   %eax
  80019f:	68 a8 24 80 00       	push   $0x8024a8
  8001a4:	6a 19                	push   $0x19
  8001a6:	68 55 24 80 00       	push   $0x802455
  8001ab:	e8 86 01 00 00       	call   800336 <_panic>
			cprintf("\ngot %d bytes: %s\n", i, buf);
  8001b0:	83 ec 04             	sub    $0x4,%esp
  8001b3:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8001b6:	50                   	push   %eax
  8001b7:	56                   	push   %esi
  8001b8:	68 cd 24 80 00       	push   $0x8024cd
  8001bd:	e8 4f 02 00 00       	call   800411 <cprintf>
  8001c2:	83 c4 10             	add    $0x10,%esp
  8001c5:	e9 35 ff ff ff       	jmp    8000ff <umain+0xcc>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[0]);
  8001ca:	a1 04 40 80 00       	mov    0x804004,%eax
  8001cf:	8b 40 48             	mov    0x48(%eax),%eax
  8001d2:	83 ec 04             	sub    $0x4,%esp
  8001d5:	ff 75 8c             	pushl  -0x74(%ebp)
  8001d8:	50                   	push   %eax
  8001d9:	68 6e 24 80 00       	push   $0x80246e
  8001de:	e8 2e 02 00 00       	call   800411 <cprintf>
		close(p[0]);
  8001e3:	83 c4 04             	add    $0x4,%esp
  8001e6:	ff 75 8c             	pushl  -0x74(%ebp)
  8001e9:	e8 d8 12 00 00       	call   8014c6 <close>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
  8001ee:	a1 04 40 80 00       	mov    0x804004,%eax
  8001f3:	8b 40 48             	mov    0x48(%eax),%eax
  8001f6:	83 c4 0c             	add    $0xc,%esp
  8001f9:	ff 75 90             	pushl  -0x70(%ebp)
  8001fc:	50                   	push   %eax
  8001fd:	68 e0 24 80 00       	push   $0x8024e0
  800202:	e8 0a 02 00 00       	call   800411 <cprintf>
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
  800207:	83 c4 04             	add    $0x4,%esp
  80020a:	ff 35 00 30 80 00    	pushl  0x803000
  800210:	e8 e4 07 00 00       	call   8009f9 <strlen>
  800215:	83 c4 0c             	add    $0xc,%esp
  800218:	50                   	push   %eax
  800219:	ff 35 00 30 80 00    	pushl  0x803000
  80021f:	ff 75 90             	pushl  -0x70(%ebp)
  800222:	e8 a9 14 00 00       	call   8016d0 <write>
  800227:	89 c6                	mov    %eax,%esi
  800229:	83 c4 04             	add    $0x4,%esp
  80022c:	ff 35 00 30 80 00    	pushl  0x803000
  800232:	e8 c2 07 00 00       	call   8009f9 <strlen>
  800237:	83 c4 10             	add    $0x10,%esp
  80023a:	39 f0                	cmp    %esi,%eax
  80023c:	75 13                	jne    800251 <umain+0x21e>
		close(p[1]);
  80023e:	83 ec 0c             	sub    $0xc,%esp
  800241:	ff 75 90             	pushl  -0x70(%ebp)
  800244:	e8 7d 12 00 00       	call   8014c6 <close>
  800249:	83 c4 10             	add    $0x10,%esp
  80024c:	e9 b3 fe ff ff       	jmp    800104 <umain+0xd1>
			panic("write: %e", i);
  800251:	56                   	push   %esi
  800252:	68 fd 24 80 00       	push   $0x8024fd
  800257:	6a 25                	push   $0x25
  800259:	68 55 24 80 00       	push   $0x802455
  80025e:	e8 d3 00 00 00       	call   800336 <_panic>
		panic("pipe: %e", i);
  800263:	50                   	push   %eax
  800264:	68 4c 24 80 00       	push   $0x80244c
  800269:	6a 2c                	push   $0x2c
  80026b:	68 55 24 80 00       	push   $0x802455
  800270:	e8 c1 00 00 00       	call   800336 <_panic>
		panic("fork: %e", i);
  800275:	56                   	push   %esi
  800276:	68 65 24 80 00       	push   $0x802465
  80027b:	6a 2f                	push   $0x2f
  80027d:	68 55 24 80 00       	push   $0x802455
  800282:	e8 af 00 00 00       	call   800336 <_panic>
		close(p[0]);
  800287:	83 ec 0c             	sub    $0xc,%esp
  80028a:	ff 75 8c             	pushl  -0x74(%ebp)
  80028d:	e8 34 12 00 00       	call   8014c6 <close>
  800292:	83 c4 10             	add    $0x10,%esp
			cprintf(".");
  800295:	83 ec 0c             	sub    $0xc,%esp
  800298:	68 14 25 80 00       	push   $0x802514
  80029d:	e8 6f 01 00 00       	call   800411 <cprintf>
			if (write(p[1], "x", 1) != 1)
  8002a2:	83 c4 0c             	add    $0xc,%esp
  8002a5:	6a 01                	push   $0x1
  8002a7:	68 16 25 80 00       	push   $0x802516
  8002ac:	ff 75 90             	pushl  -0x70(%ebp)
  8002af:	e8 1c 14 00 00       	call   8016d0 <write>
  8002b4:	83 c4 10             	add    $0x10,%esp
  8002b7:	83 f8 01             	cmp    $0x1,%eax
  8002ba:	74 d9                	je     800295 <umain+0x262>
		cprintf("\npipe write closed properly\n");
  8002bc:	83 ec 0c             	sub    $0xc,%esp
  8002bf:	68 18 25 80 00       	push   $0x802518
  8002c4:	e8 48 01 00 00       	call   800411 <cprintf>
		exit();
  8002c9:	e8 4e 00 00 00       	call   80031c <exit>
  8002ce:	83 c4 10             	add    $0x10,%esp
  8002d1:	e9 70 fe ff ff       	jmp    800146 <umain+0x113>

008002d6 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
  8002d9:	56                   	push   %esi
  8002da:	53                   	push   %ebx
  8002db:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002de:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8002e1:	e8 05 0b 00 00       	call   800deb <sys_getenvid>
  8002e6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002eb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8002ee:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002f3:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002f8:	85 db                	test   %ebx,%ebx
  8002fa:	7e 07                	jle    800303 <libmain+0x2d>
		binaryname = argv[0];
  8002fc:	8b 06                	mov    (%esi),%eax
  8002fe:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  800303:	83 ec 08             	sub    $0x8,%esp
  800306:	56                   	push   %esi
  800307:	53                   	push   %ebx
  800308:	e8 26 fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80030d:	e8 0a 00 00 00       	call   80031c <exit>
}
  800312:	83 c4 10             	add    $0x10,%esp
  800315:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800318:	5b                   	pop    %ebx
  800319:	5e                   	pop    %esi
  80031a:	5d                   	pop    %ebp
  80031b:	c3                   	ret    

0080031c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
  80031f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800322:	e8 ca 11 00 00       	call   8014f1 <close_all>
	sys_env_destroy(0);
  800327:	83 ec 0c             	sub    $0xc,%esp
  80032a:	6a 00                	push   $0x0
  80032c:	e8 79 0a 00 00       	call   800daa <sys_env_destroy>
}
  800331:	83 c4 10             	add    $0x10,%esp
  800334:	c9                   	leave  
  800335:	c3                   	ret    

00800336 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800336:	55                   	push   %ebp
  800337:	89 e5                	mov    %esp,%ebp
  800339:	56                   	push   %esi
  80033a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80033b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80033e:	8b 35 04 30 80 00    	mov    0x803004,%esi
  800344:	e8 a2 0a 00 00       	call   800deb <sys_getenvid>
  800349:	83 ec 0c             	sub    $0xc,%esp
  80034c:	ff 75 0c             	pushl  0xc(%ebp)
  80034f:	ff 75 08             	pushl  0x8(%ebp)
  800352:	56                   	push   %esi
  800353:	50                   	push   %eax
  800354:	68 98 25 80 00       	push   $0x802598
  800359:	e8 b3 00 00 00       	call   800411 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80035e:	83 c4 18             	add    $0x18,%esp
  800361:	53                   	push   %ebx
  800362:	ff 75 10             	pushl  0x10(%ebp)
  800365:	e8 56 00 00 00       	call   8003c0 <vcprintf>
	cprintf("\n");
  80036a:	c7 04 24 89 24 80 00 	movl   $0x802489,(%esp)
  800371:	e8 9b 00 00 00       	call   800411 <cprintf>
  800376:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800379:	cc                   	int3   
  80037a:	eb fd                	jmp    800379 <_panic+0x43>

0080037c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80037c:	55                   	push   %ebp
  80037d:	89 e5                	mov    %esp,%ebp
  80037f:	53                   	push   %ebx
  800380:	83 ec 04             	sub    $0x4,%esp
  800383:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800386:	8b 13                	mov    (%ebx),%edx
  800388:	8d 42 01             	lea    0x1(%edx),%eax
  80038b:	89 03                	mov    %eax,(%ebx)
  80038d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800390:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800394:	3d ff 00 00 00       	cmp    $0xff,%eax
  800399:	74 09                	je     8003a4 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80039b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80039f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003a2:	c9                   	leave  
  8003a3:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003a4:	83 ec 08             	sub    $0x8,%esp
  8003a7:	68 ff 00 00 00       	push   $0xff
  8003ac:	8d 43 08             	lea    0x8(%ebx),%eax
  8003af:	50                   	push   %eax
  8003b0:	e8 b8 09 00 00       	call   800d6d <sys_cputs>
		b->idx = 0;
  8003b5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003bb:	83 c4 10             	add    $0x10,%esp
  8003be:	eb db                	jmp    80039b <putch+0x1f>

008003c0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003c0:	55                   	push   %ebp
  8003c1:	89 e5                	mov    %esp,%ebp
  8003c3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003c9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003d0:	00 00 00 
	b.cnt = 0;
  8003d3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003da:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003dd:	ff 75 0c             	pushl  0xc(%ebp)
  8003e0:	ff 75 08             	pushl  0x8(%ebp)
  8003e3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003e9:	50                   	push   %eax
  8003ea:	68 7c 03 80 00       	push   $0x80037c
  8003ef:	e8 1a 01 00 00       	call   80050e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003f4:	83 c4 08             	add    $0x8,%esp
  8003f7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003fd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800403:	50                   	push   %eax
  800404:	e8 64 09 00 00       	call   800d6d <sys_cputs>

	return b.cnt;
}
  800409:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80040f:	c9                   	leave  
  800410:	c3                   	ret    

00800411 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800411:	55                   	push   %ebp
  800412:	89 e5                	mov    %esp,%ebp
  800414:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800417:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80041a:	50                   	push   %eax
  80041b:	ff 75 08             	pushl  0x8(%ebp)
  80041e:	e8 9d ff ff ff       	call   8003c0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800423:	c9                   	leave  
  800424:	c3                   	ret    

00800425 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800425:	55                   	push   %ebp
  800426:	89 e5                	mov    %esp,%ebp
  800428:	57                   	push   %edi
  800429:	56                   	push   %esi
  80042a:	53                   	push   %ebx
  80042b:	83 ec 1c             	sub    $0x1c,%esp
  80042e:	89 c7                	mov    %eax,%edi
  800430:	89 d6                	mov    %edx,%esi
  800432:	8b 45 08             	mov    0x8(%ebp),%eax
  800435:	8b 55 0c             	mov    0xc(%ebp),%edx
  800438:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80043b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80043e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800441:	bb 00 00 00 00       	mov    $0x0,%ebx
  800446:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800449:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80044c:	39 d3                	cmp    %edx,%ebx
  80044e:	72 05                	jb     800455 <printnum+0x30>
  800450:	39 45 10             	cmp    %eax,0x10(%ebp)
  800453:	77 7a                	ja     8004cf <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800455:	83 ec 0c             	sub    $0xc,%esp
  800458:	ff 75 18             	pushl  0x18(%ebp)
  80045b:	8b 45 14             	mov    0x14(%ebp),%eax
  80045e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800461:	53                   	push   %ebx
  800462:	ff 75 10             	pushl  0x10(%ebp)
  800465:	83 ec 08             	sub    $0x8,%esp
  800468:	ff 75 e4             	pushl  -0x1c(%ebp)
  80046b:	ff 75 e0             	pushl  -0x20(%ebp)
  80046e:	ff 75 dc             	pushl  -0x24(%ebp)
  800471:	ff 75 d8             	pushl  -0x28(%ebp)
  800474:	e8 77 1d 00 00       	call   8021f0 <__udivdi3>
  800479:	83 c4 18             	add    $0x18,%esp
  80047c:	52                   	push   %edx
  80047d:	50                   	push   %eax
  80047e:	89 f2                	mov    %esi,%edx
  800480:	89 f8                	mov    %edi,%eax
  800482:	e8 9e ff ff ff       	call   800425 <printnum>
  800487:	83 c4 20             	add    $0x20,%esp
  80048a:	eb 13                	jmp    80049f <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80048c:	83 ec 08             	sub    $0x8,%esp
  80048f:	56                   	push   %esi
  800490:	ff 75 18             	pushl  0x18(%ebp)
  800493:	ff d7                	call   *%edi
  800495:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800498:	83 eb 01             	sub    $0x1,%ebx
  80049b:	85 db                	test   %ebx,%ebx
  80049d:	7f ed                	jg     80048c <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80049f:	83 ec 08             	sub    $0x8,%esp
  8004a2:	56                   	push   %esi
  8004a3:	83 ec 04             	sub    $0x4,%esp
  8004a6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004a9:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ac:	ff 75 dc             	pushl  -0x24(%ebp)
  8004af:	ff 75 d8             	pushl  -0x28(%ebp)
  8004b2:	e8 59 1e 00 00       	call   802310 <__umoddi3>
  8004b7:	83 c4 14             	add    $0x14,%esp
  8004ba:	0f be 80 bb 25 80 00 	movsbl 0x8025bb(%eax),%eax
  8004c1:	50                   	push   %eax
  8004c2:	ff d7                	call   *%edi
}
  8004c4:	83 c4 10             	add    $0x10,%esp
  8004c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004ca:	5b                   	pop    %ebx
  8004cb:	5e                   	pop    %esi
  8004cc:	5f                   	pop    %edi
  8004cd:	5d                   	pop    %ebp
  8004ce:	c3                   	ret    
  8004cf:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004d2:	eb c4                	jmp    800498 <printnum+0x73>

008004d4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004d4:	55                   	push   %ebp
  8004d5:	89 e5                	mov    %esp,%ebp
  8004d7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004da:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004de:	8b 10                	mov    (%eax),%edx
  8004e0:	3b 50 04             	cmp    0x4(%eax),%edx
  8004e3:	73 0a                	jae    8004ef <sprintputch+0x1b>
		*b->buf++ = ch;
  8004e5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004e8:	89 08                	mov    %ecx,(%eax)
  8004ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ed:	88 02                	mov    %al,(%edx)
}
  8004ef:	5d                   	pop    %ebp
  8004f0:	c3                   	ret    

008004f1 <printfmt>:
{
  8004f1:	55                   	push   %ebp
  8004f2:	89 e5                	mov    %esp,%ebp
  8004f4:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004f7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004fa:	50                   	push   %eax
  8004fb:	ff 75 10             	pushl  0x10(%ebp)
  8004fe:	ff 75 0c             	pushl  0xc(%ebp)
  800501:	ff 75 08             	pushl  0x8(%ebp)
  800504:	e8 05 00 00 00       	call   80050e <vprintfmt>
}
  800509:	83 c4 10             	add    $0x10,%esp
  80050c:	c9                   	leave  
  80050d:	c3                   	ret    

0080050e <vprintfmt>:
{
  80050e:	55                   	push   %ebp
  80050f:	89 e5                	mov    %esp,%ebp
  800511:	57                   	push   %edi
  800512:	56                   	push   %esi
  800513:	53                   	push   %ebx
  800514:	83 ec 2c             	sub    $0x2c,%esp
  800517:	8b 75 08             	mov    0x8(%ebp),%esi
  80051a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80051d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800520:	e9 c1 03 00 00       	jmp    8008e6 <vprintfmt+0x3d8>
		padc = ' ';
  800525:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800529:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800530:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800537:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80053e:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800543:	8d 47 01             	lea    0x1(%edi),%eax
  800546:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800549:	0f b6 17             	movzbl (%edi),%edx
  80054c:	8d 42 dd             	lea    -0x23(%edx),%eax
  80054f:	3c 55                	cmp    $0x55,%al
  800551:	0f 87 12 04 00 00    	ja     800969 <vprintfmt+0x45b>
  800557:	0f b6 c0             	movzbl %al,%eax
  80055a:	ff 24 85 00 27 80 00 	jmp    *0x802700(,%eax,4)
  800561:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800564:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800568:	eb d9                	jmp    800543 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80056a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80056d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800571:	eb d0                	jmp    800543 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800573:	0f b6 d2             	movzbl %dl,%edx
  800576:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800579:	b8 00 00 00 00       	mov    $0x0,%eax
  80057e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800581:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800584:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800588:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80058b:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80058e:	83 f9 09             	cmp    $0x9,%ecx
  800591:	77 55                	ja     8005e8 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800593:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800596:	eb e9                	jmp    800581 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  800598:	8b 45 14             	mov    0x14(%ebp),%eax
  80059b:	8b 00                	mov    (%eax),%eax
  80059d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a3:	8d 40 04             	lea    0x4(%eax),%eax
  8005a6:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8005ac:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005b0:	79 91                	jns    800543 <vprintfmt+0x35>
				width = precision, precision = -1;
  8005b2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005b5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005b8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005bf:	eb 82                	jmp    800543 <vprintfmt+0x35>
  8005c1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005c4:	85 c0                	test   %eax,%eax
  8005c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8005cb:	0f 49 d0             	cmovns %eax,%edx
  8005ce:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005d4:	e9 6a ff ff ff       	jmp    800543 <vprintfmt+0x35>
  8005d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005dc:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005e3:	e9 5b ff ff ff       	jmp    800543 <vprintfmt+0x35>
  8005e8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005eb:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005ee:	eb bc                	jmp    8005ac <vprintfmt+0x9e>
			lflag++;
  8005f0:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8005f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005f6:	e9 48 ff ff ff       	jmp    800543 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8005fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fe:	8d 78 04             	lea    0x4(%eax),%edi
  800601:	83 ec 08             	sub    $0x8,%esp
  800604:	53                   	push   %ebx
  800605:	ff 30                	pushl  (%eax)
  800607:	ff d6                	call   *%esi
			break;
  800609:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80060c:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80060f:	e9 cf 02 00 00       	jmp    8008e3 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  800614:	8b 45 14             	mov    0x14(%ebp),%eax
  800617:	8d 78 04             	lea    0x4(%eax),%edi
  80061a:	8b 00                	mov    (%eax),%eax
  80061c:	99                   	cltd   
  80061d:	31 d0                	xor    %edx,%eax
  80061f:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800621:	83 f8 0f             	cmp    $0xf,%eax
  800624:	7f 23                	jg     800649 <vprintfmt+0x13b>
  800626:	8b 14 85 60 28 80 00 	mov    0x802860(,%eax,4),%edx
  80062d:	85 d2                	test   %edx,%edx
  80062f:	74 18                	je     800649 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800631:	52                   	push   %edx
  800632:	68 d5 2a 80 00       	push   $0x802ad5
  800637:	53                   	push   %ebx
  800638:	56                   	push   %esi
  800639:	e8 b3 fe ff ff       	call   8004f1 <printfmt>
  80063e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800641:	89 7d 14             	mov    %edi,0x14(%ebp)
  800644:	e9 9a 02 00 00       	jmp    8008e3 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  800649:	50                   	push   %eax
  80064a:	68 d3 25 80 00       	push   $0x8025d3
  80064f:	53                   	push   %ebx
  800650:	56                   	push   %esi
  800651:	e8 9b fe ff ff       	call   8004f1 <printfmt>
  800656:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800659:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80065c:	e9 82 02 00 00       	jmp    8008e3 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  800661:	8b 45 14             	mov    0x14(%ebp),%eax
  800664:	83 c0 04             	add    $0x4,%eax
  800667:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80066a:	8b 45 14             	mov    0x14(%ebp),%eax
  80066d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80066f:	85 ff                	test   %edi,%edi
  800671:	b8 cc 25 80 00       	mov    $0x8025cc,%eax
  800676:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800679:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80067d:	0f 8e bd 00 00 00    	jle    800740 <vprintfmt+0x232>
  800683:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800687:	75 0e                	jne    800697 <vprintfmt+0x189>
  800689:	89 75 08             	mov    %esi,0x8(%ebp)
  80068c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80068f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800692:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800695:	eb 6d                	jmp    800704 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  800697:	83 ec 08             	sub    $0x8,%esp
  80069a:	ff 75 d0             	pushl  -0x30(%ebp)
  80069d:	57                   	push   %edi
  80069e:	e8 6e 03 00 00       	call   800a11 <strnlen>
  8006a3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006a6:	29 c1                	sub    %eax,%ecx
  8006a8:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8006ab:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006ae:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006b2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006b5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006b8:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ba:	eb 0f                	jmp    8006cb <vprintfmt+0x1bd>
					putch(padc, putdat);
  8006bc:	83 ec 08             	sub    $0x8,%esp
  8006bf:	53                   	push   %ebx
  8006c0:	ff 75 e0             	pushl  -0x20(%ebp)
  8006c3:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c5:	83 ef 01             	sub    $0x1,%edi
  8006c8:	83 c4 10             	add    $0x10,%esp
  8006cb:	85 ff                	test   %edi,%edi
  8006cd:	7f ed                	jg     8006bc <vprintfmt+0x1ae>
  8006cf:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006d2:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006d5:	85 c9                	test   %ecx,%ecx
  8006d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8006dc:	0f 49 c1             	cmovns %ecx,%eax
  8006df:	29 c1                	sub    %eax,%ecx
  8006e1:	89 75 08             	mov    %esi,0x8(%ebp)
  8006e4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006e7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006ea:	89 cb                	mov    %ecx,%ebx
  8006ec:	eb 16                	jmp    800704 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8006ee:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006f2:	75 31                	jne    800725 <vprintfmt+0x217>
					putch(ch, putdat);
  8006f4:	83 ec 08             	sub    $0x8,%esp
  8006f7:	ff 75 0c             	pushl  0xc(%ebp)
  8006fa:	50                   	push   %eax
  8006fb:	ff 55 08             	call   *0x8(%ebp)
  8006fe:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800701:	83 eb 01             	sub    $0x1,%ebx
  800704:	83 c7 01             	add    $0x1,%edi
  800707:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  80070b:	0f be c2             	movsbl %dl,%eax
  80070e:	85 c0                	test   %eax,%eax
  800710:	74 59                	je     80076b <vprintfmt+0x25d>
  800712:	85 f6                	test   %esi,%esi
  800714:	78 d8                	js     8006ee <vprintfmt+0x1e0>
  800716:	83 ee 01             	sub    $0x1,%esi
  800719:	79 d3                	jns    8006ee <vprintfmt+0x1e0>
  80071b:	89 df                	mov    %ebx,%edi
  80071d:	8b 75 08             	mov    0x8(%ebp),%esi
  800720:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800723:	eb 37                	jmp    80075c <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  800725:	0f be d2             	movsbl %dl,%edx
  800728:	83 ea 20             	sub    $0x20,%edx
  80072b:	83 fa 5e             	cmp    $0x5e,%edx
  80072e:	76 c4                	jbe    8006f4 <vprintfmt+0x1e6>
					putch('?', putdat);
  800730:	83 ec 08             	sub    $0x8,%esp
  800733:	ff 75 0c             	pushl  0xc(%ebp)
  800736:	6a 3f                	push   $0x3f
  800738:	ff 55 08             	call   *0x8(%ebp)
  80073b:	83 c4 10             	add    $0x10,%esp
  80073e:	eb c1                	jmp    800701 <vprintfmt+0x1f3>
  800740:	89 75 08             	mov    %esi,0x8(%ebp)
  800743:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800746:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800749:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80074c:	eb b6                	jmp    800704 <vprintfmt+0x1f6>
				putch(' ', putdat);
  80074e:	83 ec 08             	sub    $0x8,%esp
  800751:	53                   	push   %ebx
  800752:	6a 20                	push   $0x20
  800754:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800756:	83 ef 01             	sub    $0x1,%edi
  800759:	83 c4 10             	add    $0x10,%esp
  80075c:	85 ff                	test   %edi,%edi
  80075e:	7f ee                	jg     80074e <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800760:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800763:	89 45 14             	mov    %eax,0x14(%ebp)
  800766:	e9 78 01 00 00       	jmp    8008e3 <vprintfmt+0x3d5>
  80076b:	89 df                	mov    %ebx,%edi
  80076d:	8b 75 08             	mov    0x8(%ebp),%esi
  800770:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800773:	eb e7                	jmp    80075c <vprintfmt+0x24e>
	if (lflag >= 2)
  800775:	83 f9 01             	cmp    $0x1,%ecx
  800778:	7e 3f                	jle    8007b9 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  80077a:	8b 45 14             	mov    0x14(%ebp),%eax
  80077d:	8b 50 04             	mov    0x4(%eax),%edx
  800780:	8b 00                	mov    (%eax),%eax
  800782:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800785:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800788:	8b 45 14             	mov    0x14(%ebp),%eax
  80078b:	8d 40 08             	lea    0x8(%eax),%eax
  80078e:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800791:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800795:	79 5c                	jns    8007f3 <vprintfmt+0x2e5>
				putch('-', putdat);
  800797:	83 ec 08             	sub    $0x8,%esp
  80079a:	53                   	push   %ebx
  80079b:	6a 2d                	push   $0x2d
  80079d:	ff d6                	call   *%esi
				num = -(long long) num;
  80079f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007a2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007a5:	f7 da                	neg    %edx
  8007a7:	83 d1 00             	adc    $0x0,%ecx
  8007aa:	f7 d9                	neg    %ecx
  8007ac:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007af:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007b4:	e9 10 01 00 00       	jmp    8008c9 <vprintfmt+0x3bb>
	else if (lflag)
  8007b9:	85 c9                	test   %ecx,%ecx
  8007bb:	75 1b                	jne    8007d8 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8007bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c0:	8b 00                	mov    (%eax),%eax
  8007c2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007c5:	89 c1                	mov    %eax,%ecx
  8007c7:	c1 f9 1f             	sar    $0x1f,%ecx
  8007ca:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d0:	8d 40 04             	lea    0x4(%eax),%eax
  8007d3:	89 45 14             	mov    %eax,0x14(%ebp)
  8007d6:	eb b9                	jmp    800791 <vprintfmt+0x283>
		return va_arg(*ap, long);
  8007d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007db:	8b 00                	mov    (%eax),%eax
  8007dd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007e0:	89 c1                	mov    %eax,%ecx
  8007e2:	c1 f9 1f             	sar    $0x1f,%ecx
  8007e5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007eb:	8d 40 04             	lea    0x4(%eax),%eax
  8007ee:	89 45 14             	mov    %eax,0x14(%ebp)
  8007f1:	eb 9e                	jmp    800791 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8007f3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007f6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007f9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007fe:	e9 c6 00 00 00       	jmp    8008c9 <vprintfmt+0x3bb>
	if (lflag >= 2)
  800803:	83 f9 01             	cmp    $0x1,%ecx
  800806:	7e 18                	jle    800820 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  800808:	8b 45 14             	mov    0x14(%ebp),%eax
  80080b:	8b 10                	mov    (%eax),%edx
  80080d:	8b 48 04             	mov    0x4(%eax),%ecx
  800810:	8d 40 08             	lea    0x8(%eax),%eax
  800813:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800816:	b8 0a 00 00 00       	mov    $0xa,%eax
  80081b:	e9 a9 00 00 00       	jmp    8008c9 <vprintfmt+0x3bb>
	else if (lflag)
  800820:	85 c9                	test   %ecx,%ecx
  800822:	75 1a                	jne    80083e <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  800824:	8b 45 14             	mov    0x14(%ebp),%eax
  800827:	8b 10                	mov    (%eax),%edx
  800829:	b9 00 00 00 00       	mov    $0x0,%ecx
  80082e:	8d 40 04             	lea    0x4(%eax),%eax
  800831:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800834:	b8 0a 00 00 00       	mov    $0xa,%eax
  800839:	e9 8b 00 00 00       	jmp    8008c9 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80083e:	8b 45 14             	mov    0x14(%ebp),%eax
  800841:	8b 10                	mov    (%eax),%edx
  800843:	b9 00 00 00 00       	mov    $0x0,%ecx
  800848:	8d 40 04             	lea    0x4(%eax),%eax
  80084b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80084e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800853:	eb 74                	jmp    8008c9 <vprintfmt+0x3bb>
	if (lflag >= 2)
  800855:	83 f9 01             	cmp    $0x1,%ecx
  800858:	7e 15                	jle    80086f <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  80085a:	8b 45 14             	mov    0x14(%ebp),%eax
  80085d:	8b 10                	mov    (%eax),%edx
  80085f:	8b 48 04             	mov    0x4(%eax),%ecx
  800862:	8d 40 08             	lea    0x8(%eax),%eax
  800865:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800868:	b8 08 00 00 00       	mov    $0x8,%eax
  80086d:	eb 5a                	jmp    8008c9 <vprintfmt+0x3bb>
	else if (lflag)
  80086f:	85 c9                	test   %ecx,%ecx
  800871:	75 17                	jne    80088a <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  800873:	8b 45 14             	mov    0x14(%ebp),%eax
  800876:	8b 10                	mov    (%eax),%edx
  800878:	b9 00 00 00 00       	mov    $0x0,%ecx
  80087d:	8d 40 04             	lea    0x4(%eax),%eax
  800880:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800883:	b8 08 00 00 00       	mov    $0x8,%eax
  800888:	eb 3f                	jmp    8008c9 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80088a:	8b 45 14             	mov    0x14(%ebp),%eax
  80088d:	8b 10                	mov    (%eax),%edx
  80088f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800894:	8d 40 04             	lea    0x4(%eax),%eax
  800897:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80089a:	b8 08 00 00 00       	mov    $0x8,%eax
  80089f:	eb 28                	jmp    8008c9 <vprintfmt+0x3bb>
			putch('0', putdat);
  8008a1:	83 ec 08             	sub    $0x8,%esp
  8008a4:	53                   	push   %ebx
  8008a5:	6a 30                	push   $0x30
  8008a7:	ff d6                	call   *%esi
			putch('x', putdat);
  8008a9:	83 c4 08             	add    $0x8,%esp
  8008ac:	53                   	push   %ebx
  8008ad:	6a 78                	push   $0x78
  8008af:	ff d6                	call   *%esi
			num = (unsigned long long)
  8008b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b4:	8b 10                	mov    (%eax),%edx
  8008b6:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8008bb:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8008be:	8d 40 04             	lea    0x4(%eax),%eax
  8008c1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008c4:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8008c9:	83 ec 0c             	sub    $0xc,%esp
  8008cc:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008d0:	57                   	push   %edi
  8008d1:	ff 75 e0             	pushl  -0x20(%ebp)
  8008d4:	50                   	push   %eax
  8008d5:	51                   	push   %ecx
  8008d6:	52                   	push   %edx
  8008d7:	89 da                	mov    %ebx,%edx
  8008d9:	89 f0                	mov    %esi,%eax
  8008db:	e8 45 fb ff ff       	call   800425 <printnum>
			break;
  8008e0:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8008e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008e6:	83 c7 01             	add    $0x1,%edi
  8008e9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008ed:	83 f8 25             	cmp    $0x25,%eax
  8008f0:	0f 84 2f fc ff ff    	je     800525 <vprintfmt+0x17>
			if (ch == '\0')
  8008f6:	85 c0                	test   %eax,%eax
  8008f8:	0f 84 8b 00 00 00    	je     800989 <vprintfmt+0x47b>
			putch(ch, putdat);
  8008fe:	83 ec 08             	sub    $0x8,%esp
  800901:	53                   	push   %ebx
  800902:	50                   	push   %eax
  800903:	ff d6                	call   *%esi
  800905:	83 c4 10             	add    $0x10,%esp
  800908:	eb dc                	jmp    8008e6 <vprintfmt+0x3d8>
	if (lflag >= 2)
  80090a:	83 f9 01             	cmp    $0x1,%ecx
  80090d:	7e 15                	jle    800924 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  80090f:	8b 45 14             	mov    0x14(%ebp),%eax
  800912:	8b 10                	mov    (%eax),%edx
  800914:	8b 48 04             	mov    0x4(%eax),%ecx
  800917:	8d 40 08             	lea    0x8(%eax),%eax
  80091a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80091d:	b8 10 00 00 00       	mov    $0x10,%eax
  800922:	eb a5                	jmp    8008c9 <vprintfmt+0x3bb>
	else if (lflag)
  800924:	85 c9                	test   %ecx,%ecx
  800926:	75 17                	jne    80093f <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  800928:	8b 45 14             	mov    0x14(%ebp),%eax
  80092b:	8b 10                	mov    (%eax),%edx
  80092d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800932:	8d 40 04             	lea    0x4(%eax),%eax
  800935:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800938:	b8 10 00 00 00       	mov    $0x10,%eax
  80093d:	eb 8a                	jmp    8008c9 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80093f:	8b 45 14             	mov    0x14(%ebp),%eax
  800942:	8b 10                	mov    (%eax),%edx
  800944:	b9 00 00 00 00       	mov    $0x0,%ecx
  800949:	8d 40 04             	lea    0x4(%eax),%eax
  80094c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80094f:	b8 10 00 00 00       	mov    $0x10,%eax
  800954:	e9 70 ff ff ff       	jmp    8008c9 <vprintfmt+0x3bb>
			putch(ch, putdat);
  800959:	83 ec 08             	sub    $0x8,%esp
  80095c:	53                   	push   %ebx
  80095d:	6a 25                	push   $0x25
  80095f:	ff d6                	call   *%esi
			break;
  800961:	83 c4 10             	add    $0x10,%esp
  800964:	e9 7a ff ff ff       	jmp    8008e3 <vprintfmt+0x3d5>
			putch('%', putdat);
  800969:	83 ec 08             	sub    $0x8,%esp
  80096c:	53                   	push   %ebx
  80096d:	6a 25                	push   $0x25
  80096f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800971:	83 c4 10             	add    $0x10,%esp
  800974:	89 f8                	mov    %edi,%eax
  800976:	eb 03                	jmp    80097b <vprintfmt+0x46d>
  800978:	83 e8 01             	sub    $0x1,%eax
  80097b:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80097f:	75 f7                	jne    800978 <vprintfmt+0x46a>
  800981:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800984:	e9 5a ff ff ff       	jmp    8008e3 <vprintfmt+0x3d5>
}
  800989:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80098c:	5b                   	pop    %ebx
  80098d:	5e                   	pop    %esi
  80098e:	5f                   	pop    %edi
  80098f:	5d                   	pop    %ebp
  800990:	c3                   	ret    

00800991 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
  800994:	83 ec 18             	sub    $0x18,%esp
  800997:	8b 45 08             	mov    0x8(%ebp),%eax
  80099a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80099d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009a0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009a4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009ae:	85 c0                	test   %eax,%eax
  8009b0:	74 26                	je     8009d8 <vsnprintf+0x47>
  8009b2:	85 d2                	test   %edx,%edx
  8009b4:	7e 22                	jle    8009d8 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009b6:	ff 75 14             	pushl  0x14(%ebp)
  8009b9:	ff 75 10             	pushl  0x10(%ebp)
  8009bc:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009bf:	50                   	push   %eax
  8009c0:	68 d4 04 80 00       	push   $0x8004d4
  8009c5:	e8 44 fb ff ff       	call   80050e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009cd:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009d3:	83 c4 10             	add    $0x10,%esp
}
  8009d6:	c9                   	leave  
  8009d7:	c3                   	ret    
		return -E_INVAL;
  8009d8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009dd:	eb f7                	jmp    8009d6 <vsnprintf+0x45>

008009df <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009e5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009e8:	50                   	push   %eax
  8009e9:	ff 75 10             	pushl  0x10(%ebp)
  8009ec:	ff 75 0c             	pushl  0xc(%ebp)
  8009ef:	ff 75 08             	pushl  0x8(%ebp)
  8009f2:	e8 9a ff ff ff       	call   800991 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009f7:	c9                   	leave  
  8009f8:	c3                   	ret    

008009f9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009f9:	55                   	push   %ebp
  8009fa:	89 e5                	mov    %esp,%ebp
  8009fc:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800a04:	eb 03                	jmp    800a09 <strlen+0x10>
		n++;
  800a06:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800a09:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a0d:	75 f7                	jne    800a06 <strlen+0xd>
	return n;
}
  800a0f:	5d                   	pop    %ebp
  800a10:	c3                   	ret    

00800a11 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a11:	55                   	push   %ebp
  800a12:	89 e5                	mov    %esp,%ebp
  800a14:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a17:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a1a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1f:	eb 03                	jmp    800a24 <strnlen+0x13>
		n++;
  800a21:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a24:	39 d0                	cmp    %edx,%eax
  800a26:	74 06                	je     800a2e <strnlen+0x1d>
  800a28:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a2c:	75 f3                	jne    800a21 <strnlen+0x10>
	return n;
}
  800a2e:	5d                   	pop    %ebp
  800a2f:	c3                   	ret    

00800a30 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	53                   	push   %ebx
  800a34:	8b 45 08             	mov    0x8(%ebp),%eax
  800a37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a3a:	89 c2                	mov    %eax,%edx
  800a3c:	83 c1 01             	add    $0x1,%ecx
  800a3f:	83 c2 01             	add    $0x1,%edx
  800a42:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a46:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a49:	84 db                	test   %bl,%bl
  800a4b:	75 ef                	jne    800a3c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a4d:	5b                   	pop    %ebx
  800a4e:	5d                   	pop    %ebp
  800a4f:	c3                   	ret    

00800a50 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	53                   	push   %ebx
  800a54:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a57:	53                   	push   %ebx
  800a58:	e8 9c ff ff ff       	call   8009f9 <strlen>
  800a5d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a60:	ff 75 0c             	pushl  0xc(%ebp)
  800a63:	01 d8                	add    %ebx,%eax
  800a65:	50                   	push   %eax
  800a66:	e8 c5 ff ff ff       	call   800a30 <strcpy>
	return dst;
}
  800a6b:	89 d8                	mov    %ebx,%eax
  800a6d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a70:	c9                   	leave  
  800a71:	c3                   	ret    

00800a72 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a72:	55                   	push   %ebp
  800a73:	89 e5                	mov    %esp,%ebp
  800a75:	56                   	push   %esi
  800a76:	53                   	push   %ebx
  800a77:	8b 75 08             	mov    0x8(%ebp),%esi
  800a7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a7d:	89 f3                	mov    %esi,%ebx
  800a7f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a82:	89 f2                	mov    %esi,%edx
  800a84:	eb 0f                	jmp    800a95 <strncpy+0x23>
		*dst++ = *src;
  800a86:	83 c2 01             	add    $0x1,%edx
  800a89:	0f b6 01             	movzbl (%ecx),%eax
  800a8c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a8f:	80 39 01             	cmpb   $0x1,(%ecx)
  800a92:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800a95:	39 da                	cmp    %ebx,%edx
  800a97:	75 ed                	jne    800a86 <strncpy+0x14>
	}
	return ret;
}
  800a99:	89 f0                	mov    %esi,%eax
  800a9b:	5b                   	pop    %ebx
  800a9c:	5e                   	pop    %esi
  800a9d:	5d                   	pop    %ebp
  800a9e:	c3                   	ret    

00800a9f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a9f:	55                   	push   %ebp
  800aa0:	89 e5                	mov    %esp,%ebp
  800aa2:	56                   	push   %esi
  800aa3:	53                   	push   %ebx
  800aa4:	8b 75 08             	mov    0x8(%ebp),%esi
  800aa7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aaa:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800aad:	89 f0                	mov    %esi,%eax
  800aaf:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ab3:	85 c9                	test   %ecx,%ecx
  800ab5:	75 0b                	jne    800ac2 <strlcpy+0x23>
  800ab7:	eb 17                	jmp    800ad0 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800ab9:	83 c2 01             	add    $0x1,%edx
  800abc:	83 c0 01             	add    $0x1,%eax
  800abf:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800ac2:	39 d8                	cmp    %ebx,%eax
  800ac4:	74 07                	je     800acd <strlcpy+0x2e>
  800ac6:	0f b6 0a             	movzbl (%edx),%ecx
  800ac9:	84 c9                	test   %cl,%cl
  800acb:	75 ec                	jne    800ab9 <strlcpy+0x1a>
		*dst = '\0';
  800acd:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800ad0:	29 f0                	sub    %esi,%eax
}
  800ad2:	5b                   	pop    %ebx
  800ad3:	5e                   	pop    %esi
  800ad4:	5d                   	pop    %ebp
  800ad5:	c3                   	ret    

00800ad6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ad6:	55                   	push   %ebp
  800ad7:	89 e5                	mov    %esp,%ebp
  800ad9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800adc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800adf:	eb 06                	jmp    800ae7 <strcmp+0x11>
		p++, q++;
  800ae1:	83 c1 01             	add    $0x1,%ecx
  800ae4:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800ae7:	0f b6 01             	movzbl (%ecx),%eax
  800aea:	84 c0                	test   %al,%al
  800aec:	74 04                	je     800af2 <strcmp+0x1c>
  800aee:	3a 02                	cmp    (%edx),%al
  800af0:	74 ef                	je     800ae1 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800af2:	0f b6 c0             	movzbl %al,%eax
  800af5:	0f b6 12             	movzbl (%edx),%edx
  800af8:	29 d0                	sub    %edx,%eax
}
  800afa:	5d                   	pop    %ebp
  800afb:	c3                   	ret    

00800afc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800afc:	55                   	push   %ebp
  800afd:	89 e5                	mov    %esp,%ebp
  800aff:	53                   	push   %ebx
  800b00:	8b 45 08             	mov    0x8(%ebp),%eax
  800b03:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b06:	89 c3                	mov    %eax,%ebx
  800b08:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b0b:	eb 06                	jmp    800b13 <strncmp+0x17>
		n--, p++, q++;
  800b0d:	83 c0 01             	add    $0x1,%eax
  800b10:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b13:	39 d8                	cmp    %ebx,%eax
  800b15:	74 16                	je     800b2d <strncmp+0x31>
  800b17:	0f b6 08             	movzbl (%eax),%ecx
  800b1a:	84 c9                	test   %cl,%cl
  800b1c:	74 04                	je     800b22 <strncmp+0x26>
  800b1e:	3a 0a                	cmp    (%edx),%cl
  800b20:	74 eb                	je     800b0d <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b22:	0f b6 00             	movzbl (%eax),%eax
  800b25:	0f b6 12             	movzbl (%edx),%edx
  800b28:	29 d0                	sub    %edx,%eax
}
  800b2a:	5b                   	pop    %ebx
  800b2b:	5d                   	pop    %ebp
  800b2c:	c3                   	ret    
		return 0;
  800b2d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b32:	eb f6                	jmp    800b2a <strncmp+0x2e>

00800b34 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b3e:	0f b6 10             	movzbl (%eax),%edx
  800b41:	84 d2                	test   %dl,%dl
  800b43:	74 09                	je     800b4e <strchr+0x1a>
		if (*s == c)
  800b45:	38 ca                	cmp    %cl,%dl
  800b47:	74 0a                	je     800b53 <strchr+0x1f>
	for (; *s; s++)
  800b49:	83 c0 01             	add    $0x1,%eax
  800b4c:	eb f0                	jmp    800b3e <strchr+0xa>
			return (char *) s;
	return 0;
  800b4e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b53:	5d                   	pop    %ebp
  800b54:	c3                   	ret    

00800b55 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b5f:	eb 03                	jmp    800b64 <strfind+0xf>
  800b61:	83 c0 01             	add    $0x1,%eax
  800b64:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b67:	38 ca                	cmp    %cl,%dl
  800b69:	74 04                	je     800b6f <strfind+0x1a>
  800b6b:	84 d2                	test   %dl,%dl
  800b6d:	75 f2                	jne    800b61 <strfind+0xc>
			break;
	return (char *) s;
}
  800b6f:	5d                   	pop    %ebp
  800b70:	c3                   	ret    

00800b71 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	57                   	push   %edi
  800b75:	56                   	push   %esi
  800b76:	53                   	push   %ebx
  800b77:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b7a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b7d:	85 c9                	test   %ecx,%ecx
  800b7f:	74 13                	je     800b94 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b81:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b87:	75 05                	jne    800b8e <memset+0x1d>
  800b89:	f6 c1 03             	test   $0x3,%cl
  800b8c:	74 0d                	je     800b9b <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b91:	fc                   	cld    
  800b92:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b94:	89 f8                	mov    %edi,%eax
  800b96:	5b                   	pop    %ebx
  800b97:	5e                   	pop    %esi
  800b98:	5f                   	pop    %edi
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    
		c &= 0xFF;
  800b9b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b9f:	89 d3                	mov    %edx,%ebx
  800ba1:	c1 e3 08             	shl    $0x8,%ebx
  800ba4:	89 d0                	mov    %edx,%eax
  800ba6:	c1 e0 18             	shl    $0x18,%eax
  800ba9:	89 d6                	mov    %edx,%esi
  800bab:	c1 e6 10             	shl    $0x10,%esi
  800bae:	09 f0                	or     %esi,%eax
  800bb0:	09 c2                	or     %eax,%edx
  800bb2:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800bb4:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800bb7:	89 d0                	mov    %edx,%eax
  800bb9:	fc                   	cld    
  800bba:	f3 ab                	rep stos %eax,%es:(%edi)
  800bbc:	eb d6                	jmp    800b94 <memset+0x23>

00800bbe <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	57                   	push   %edi
  800bc2:	56                   	push   %esi
  800bc3:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bc9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bcc:	39 c6                	cmp    %eax,%esi
  800bce:	73 35                	jae    800c05 <memmove+0x47>
  800bd0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bd3:	39 c2                	cmp    %eax,%edx
  800bd5:	76 2e                	jbe    800c05 <memmove+0x47>
		s += n;
		d += n;
  800bd7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bda:	89 d6                	mov    %edx,%esi
  800bdc:	09 fe                	or     %edi,%esi
  800bde:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800be4:	74 0c                	je     800bf2 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800be6:	83 ef 01             	sub    $0x1,%edi
  800be9:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800bec:	fd                   	std    
  800bed:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bef:	fc                   	cld    
  800bf0:	eb 21                	jmp    800c13 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bf2:	f6 c1 03             	test   $0x3,%cl
  800bf5:	75 ef                	jne    800be6 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bf7:	83 ef 04             	sub    $0x4,%edi
  800bfa:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bfd:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c00:	fd                   	std    
  800c01:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c03:	eb ea                	jmp    800bef <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c05:	89 f2                	mov    %esi,%edx
  800c07:	09 c2                	or     %eax,%edx
  800c09:	f6 c2 03             	test   $0x3,%dl
  800c0c:	74 09                	je     800c17 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c0e:	89 c7                	mov    %eax,%edi
  800c10:	fc                   	cld    
  800c11:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c13:	5e                   	pop    %esi
  800c14:	5f                   	pop    %edi
  800c15:	5d                   	pop    %ebp
  800c16:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c17:	f6 c1 03             	test   $0x3,%cl
  800c1a:	75 f2                	jne    800c0e <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c1c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c1f:	89 c7                	mov    %eax,%edi
  800c21:	fc                   	cld    
  800c22:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c24:	eb ed                	jmp    800c13 <memmove+0x55>

00800c26 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c29:	ff 75 10             	pushl  0x10(%ebp)
  800c2c:	ff 75 0c             	pushl  0xc(%ebp)
  800c2f:	ff 75 08             	pushl  0x8(%ebp)
  800c32:	e8 87 ff ff ff       	call   800bbe <memmove>
}
  800c37:	c9                   	leave  
  800c38:	c3                   	ret    

00800c39 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c39:	55                   	push   %ebp
  800c3a:	89 e5                	mov    %esp,%ebp
  800c3c:	56                   	push   %esi
  800c3d:	53                   	push   %ebx
  800c3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c41:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c44:	89 c6                	mov    %eax,%esi
  800c46:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c49:	39 f0                	cmp    %esi,%eax
  800c4b:	74 1c                	je     800c69 <memcmp+0x30>
		if (*s1 != *s2)
  800c4d:	0f b6 08             	movzbl (%eax),%ecx
  800c50:	0f b6 1a             	movzbl (%edx),%ebx
  800c53:	38 d9                	cmp    %bl,%cl
  800c55:	75 08                	jne    800c5f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800c57:	83 c0 01             	add    $0x1,%eax
  800c5a:	83 c2 01             	add    $0x1,%edx
  800c5d:	eb ea                	jmp    800c49 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800c5f:	0f b6 c1             	movzbl %cl,%eax
  800c62:	0f b6 db             	movzbl %bl,%ebx
  800c65:	29 d8                	sub    %ebx,%eax
  800c67:	eb 05                	jmp    800c6e <memcmp+0x35>
	}

	return 0;
  800c69:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c6e:	5b                   	pop    %ebx
  800c6f:	5e                   	pop    %esi
  800c70:	5d                   	pop    %ebp
  800c71:	c3                   	ret    

00800c72 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c72:	55                   	push   %ebp
  800c73:	89 e5                	mov    %esp,%ebp
  800c75:	8b 45 08             	mov    0x8(%ebp),%eax
  800c78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c7b:	89 c2                	mov    %eax,%edx
  800c7d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c80:	39 d0                	cmp    %edx,%eax
  800c82:	73 09                	jae    800c8d <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c84:	38 08                	cmp    %cl,(%eax)
  800c86:	74 05                	je     800c8d <memfind+0x1b>
	for (; s < ends; s++)
  800c88:	83 c0 01             	add    $0x1,%eax
  800c8b:	eb f3                	jmp    800c80 <memfind+0xe>
			break;
	return (void *) s;
}
  800c8d:	5d                   	pop    %ebp
  800c8e:	c3                   	ret    

00800c8f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c8f:	55                   	push   %ebp
  800c90:	89 e5                	mov    %esp,%ebp
  800c92:	57                   	push   %edi
  800c93:	56                   	push   %esi
  800c94:	53                   	push   %ebx
  800c95:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c98:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c9b:	eb 03                	jmp    800ca0 <strtol+0x11>
		s++;
  800c9d:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800ca0:	0f b6 01             	movzbl (%ecx),%eax
  800ca3:	3c 20                	cmp    $0x20,%al
  800ca5:	74 f6                	je     800c9d <strtol+0xe>
  800ca7:	3c 09                	cmp    $0x9,%al
  800ca9:	74 f2                	je     800c9d <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800cab:	3c 2b                	cmp    $0x2b,%al
  800cad:	74 2e                	je     800cdd <strtol+0x4e>
	int neg = 0;
  800caf:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800cb4:	3c 2d                	cmp    $0x2d,%al
  800cb6:	74 2f                	je     800ce7 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cb8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800cbe:	75 05                	jne    800cc5 <strtol+0x36>
  800cc0:	80 39 30             	cmpb   $0x30,(%ecx)
  800cc3:	74 2c                	je     800cf1 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cc5:	85 db                	test   %ebx,%ebx
  800cc7:	75 0a                	jne    800cd3 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cc9:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800cce:	80 39 30             	cmpb   $0x30,(%ecx)
  800cd1:	74 28                	je     800cfb <strtol+0x6c>
		base = 10;
  800cd3:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd8:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800cdb:	eb 50                	jmp    800d2d <strtol+0x9e>
		s++;
  800cdd:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800ce0:	bf 00 00 00 00       	mov    $0x0,%edi
  800ce5:	eb d1                	jmp    800cb8 <strtol+0x29>
		s++, neg = 1;
  800ce7:	83 c1 01             	add    $0x1,%ecx
  800cea:	bf 01 00 00 00       	mov    $0x1,%edi
  800cef:	eb c7                	jmp    800cb8 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cf1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800cf5:	74 0e                	je     800d05 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800cf7:	85 db                	test   %ebx,%ebx
  800cf9:	75 d8                	jne    800cd3 <strtol+0x44>
		s++, base = 8;
  800cfb:	83 c1 01             	add    $0x1,%ecx
  800cfe:	bb 08 00 00 00       	mov    $0x8,%ebx
  800d03:	eb ce                	jmp    800cd3 <strtol+0x44>
		s += 2, base = 16;
  800d05:	83 c1 02             	add    $0x2,%ecx
  800d08:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d0d:	eb c4                	jmp    800cd3 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800d0f:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d12:	89 f3                	mov    %esi,%ebx
  800d14:	80 fb 19             	cmp    $0x19,%bl
  800d17:	77 29                	ja     800d42 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800d19:	0f be d2             	movsbl %dl,%edx
  800d1c:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d1f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d22:	7d 30                	jge    800d54 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800d24:	83 c1 01             	add    $0x1,%ecx
  800d27:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d2b:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800d2d:	0f b6 11             	movzbl (%ecx),%edx
  800d30:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d33:	89 f3                	mov    %esi,%ebx
  800d35:	80 fb 09             	cmp    $0x9,%bl
  800d38:	77 d5                	ja     800d0f <strtol+0x80>
			dig = *s - '0';
  800d3a:	0f be d2             	movsbl %dl,%edx
  800d3d:	83 ea 30             	sub    $0x30,%edx
  800d40:	eb dd                	jmp    800d1f <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800d42:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d45:	89 f3                	mov    %esi,%ebx
  800d47:	80 fb 19             	cmp    $0x19,%bl
  800d4a:	77 08                	ja     800d54 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800d4c:	0f be d2             	movsbl %dl,%edx
  800d4f:	83 ea 37             	sub    $0x37,%edx
  800d52:	eb cb                	jmp    800d1f <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800d54:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d58:	74 05                	je     800d5f <strtol+0xd0>
		*endptr = (char *) s;
  800d5a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d5d:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800d5f:	89 c2                	mov    %eax,%edx
  800d61:	f7 da                	neg    %edx
  800d63:	85 ff                	test   %edi,%edi
  800d65:	0f 45 c2             	cmovne %edx,%eax
}
  800d68:	5b                   	pop    %ebx
  800d69:	5e                   	pop    %esi
  800d6a:	5f                   	pop    %edi
  800d6b:	5d                   	pop    %ebp
  800d6c:	c3                   	ret    

00800d6d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d6d:	55                   	push   %ebp
  800d6e:	89 e5                	mov    %esp,%ebp
  800d70:	57                   	push   %edi
  800d71:	56                   	push   %esi
  800d72:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d73:	b8 00 00 00 00       	mov    $0x0,%eax
  800d78:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7e:	89 c3                	mov    %eax,%ebx
  800d80:	89 c7                	mov    %eax,%edi
  800d82:	89 c6                	mov    %eax,%esi
  800d84:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d86:	5b                   	pop    %ebx
  800d87:	5e                   	pop    %esi
  800d88:	5f                   	pop    %edi
  800d89:	5d                   	pop    %ebp
  800d8a:	c3                   	ret    

00800d8b <sys_cgetc>:

int
sys_cgetc(void)
{
  800d8b:	55                   	push   %ebp
  800d8c:	89 e5                	mov    %esp,%ebp
  800d8e:	57                   	push   %edi
  800d8f:	56                   	push   %esi
  800d90:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d91:	ba 00 00 00 00       	mov    $0x0,%edx
  800d96:	b8 01 00 00 00       	mov    $0x1,%eax
  800d9b:	89 d1                	mov    %edx,%ecx
  800d9d:	89 d3                	mov    %edx,%ebx
  800d9f:	89 d7                	mov    %edx,%edi
  800da1:	89 d6                	mov    %edx,%esi
  800da3:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800da5:	5b                   	pop    %ebx
  800da6:	5e                   	pop    %esi
  800da7:	5f                   	pop    %edi
  800da8:	5d                   	pop    %ebp
  800da9:	c3                   	ret    

00800daa <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800daa:	55                   	push   %ebp
  800dab:	89 e5                	mov    %esp,%ebp
  800dad:	57                   	push   %edi
  800dae:	56                   	push   %esi
  800daf:	53                   	push   %ebx
  800db0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800db3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800db8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbb:	b8 03 00 00 00       	mov    $0x3,%eax
  800dc0:	89 cb                	mov    %ecx,%ebx
  800dc2:	89 cf                	mov    %ecx,%edi
  800dc4:	89 ce                	mov    %ecx,%esi
  800dc6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dc8:	85 c0                	test   %eax,%eax
  800dca:	7f 08                	jg     800dd4 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800dcc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dcf:	5b                   	pop    %ebx
  800dd0:	5e                   	pop    %esi
  800dd1:	5f                   	pop    %edi
  800dd2:	5d                   	pop    %ebp
  800dd3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd4:	83 ec 0c             	sub    $0xc,%esp
  800dd7:	50                   	push   %eax
  800dd8:	6a 03                	push   $0x3
  800dda:	68 bf 28 80 00       	push   $0x8028bf
  800ddf:	6a 23                	push   $0x23
  800de1:	68 dc 28 80 00       	push   $0x8028dc
  800de6:	e8 4b f5 ff ff       	call   800336 <_panic>

00800deb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800deb:	55                   	push   %ebp
  800dec:	89 e5                	mov    %esp,%ebp
  800dee:	57                   	push   %edi
  800def:	56                   	push   %esi
  800df0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800df1:	ba 00 00 00 00       	mov    $0x0,%edx
  800df6:	b8 02 00 00 00       	mov    $0x2,%eax
  800dfb:	89 d1                	mov    %edx,%ecx
  800dfd:	89 d3                	mov    %edx,%ebx
  800dff:	89 d7                	mov    %edx,%edi
  800e01:	89 d6                	mov    %edx,%esi
  800e03:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e05:	5b                   	pop    %ebx
  800e06:	5e                   	pop    %esi
  800e07:	5f                   	pop    %edi
  800e08:	5d                   	pop    %ebp
  800e09:	c3                   	ret    

00800e0a <sys_yield>:

void
sys_yield(void)
{
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	57                   	push   %edi
  800e0e:	56                   	push   %esi
  800e0f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e10:	ba 00 00 00 00       	mov    $0x0,%edx
  800e15:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e1a:	89 d1                	mov    %edx,%ecx
  800e1c:	89 d3                	mov    %edx,%ebx
  800e1e:	89 d7                	mov    %edx,%edi
  800e20:	89 d6                	mov    %edx,%esi
  800e22:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e24:	5b                   	pop    %ebx
  800e25:	5e                   	pop    %esi
  800e26:	5f                   	pop    %edi
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    

00800e29 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	57                   	push   %edi
  800e2d:	56                   	push   %esi
  800e2e:	53                   	push   %ebx
  800e2f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e32:	be 00 00 00 00       	mov    $0x0,%esi
  800e37:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3d:	b8 04 00 00 00       	mov    $0x4,%eax
  800e42:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e45:	89 f7                	mov    %esi,%edi
  800e47:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e49:	85 c0                	test   %eax,%eax
  800e4b:	7f 08                	jg     800e55 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e50:	5b                   	pop    %ebx
  800e51:	5e                   	pop    %esi
  800e52:	5f                   	pop    %edi
  800e53:	5d                   	pop    %ebp
  800e54:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e55:	83 ec 0c             	sub    $0xc,%esp
  800e58:	50                   	push   %eax
  800e59:	6a 04                	push   $0x4
  800e5b:	68 bf 28 80 00       	push   $0x8028bf
  800e60:	6a 23                	push   $0x23
  800e62:	68 dc 28 80 00       	push   $0x8028dc
  800e67:	e8 ca f4 ff ff       	call   800336 <_panic>

00800e6c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e6c:	55                   	push   %ebp
  800e6d:	89 e5                	mov    %esp,%ebp
  800e6f:	57                   	push   %edi
  800e70:	56                   	push   %esi
  800e71:	53                   	push   %ebx
  800e72:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e75:	8b 55 08             	mov    0x8(%ebp),%edx
  800e78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7b:	b8 05 00 00 00       	mov    $0x5,%eax
  800e80:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e83:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e86:	8b 75 18             	mov    0x18(%ebp),%esi
  800e89:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e8b:	85 c0                	test   %eax,%eax
  800e8d:	7f 08                	jg     800e97 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e92:	5b                   	pop    %ebx
  800e93:	5e                   	pop    %esi
  800e94:	5f                   	pop    %edi
  800e95:	5d                   	pop    %ebp
  800e96:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e97:	83 ec 0c             	sub    $0xc,%esp
  800e9a:	50                   	push   %eax
  800e9b:	6a 05                	push   $0x5
  800e9d:	68 bf 28 80 00       	push   $0x8028bf
  800ea2:	6a 23                	push   $0x23
  800ea4:	68 dc 28 80 00       	push   $0x8028dc
  800ea9:	e8 88 f4 ff ff       	call   800336 <_panic>

00800eae <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800eae:	55                   	push   %ebp
  800eaf:	89 e5                	mov    %esp,%ebp
  800eb1:	57                   	push   %edi
  800eb2:	56                   	push   %esi
  800eb3:	53                   	push   %ebx
  800eb4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800eb7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ebc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec2:	b8 06 00 00 00       	mov    $0x6,%eax
  800ec7:	89 df                	mov    %ebx,%edi
  800ec9:	89 de                	mov    %ebx,%esi
  800ecb:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ecd:	85 c0                	test   %eax,%eax
  800ecf:	7f 08                	jg     800ed9 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ed1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ed4:	5b                   	pop    %ebx
  800ed5:	5e                   	pop    %esi
  800ed6:	5f                   	pop    %edi
  800ed7:	5d                   	pop    %ebp
  800ed8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed9:	83 ec 0c             	sub    $0xc,%esp
  800edc:	50                   	push   %eax
  800edd:	6a 06                	push   $0x6
  800edf:	68 bf 28 80 00       	push   $0x8028bf
  800ee4:	6a 23                	push   $0x23
  800ee6:	68 dc 28 80 00       	push   $0x8028dc
  800eeb:	e8 46 f4 ff ff       	call   800336 <_panic>

00800ef0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ef0:	55                   	push   %ebp
  800ef1:	89 e5                	mov    %esp,%ebp
  800ef3:	57                   	push   %edi
  800ef4:	56                   	push   %esi
  800ef5:	53                   	push   %ebx
  800ef6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ef9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800efe:	8b 55 08             	mov    0x8(%ebp),%edx
  800f01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f04:	b8 08 00 00 00       	mov    $0x8,%eax
  800f09:	89 df                	mov    %ebx,%edi
  800f0b:	89 de                	mov    %ebx,%esi
  800f0d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f0f:	85 c0                	test   %eax,%eax
  800f11:	7f 08                	jg     800f1b <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f13:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f16:	5b                   	pop    %ebx
  800f17:	5e                   	pop    %esi
  800f18:	5f                   	pop    %edi
  800f19:	5d                   	pop    %ebp
  800f1a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f1b:	83 ec 0c             	sub    $0xc,%esp
  800f1e:	50                   	push   %eax
  800f1f:	6a 08                	push   $0x8
  800f21:	68 bf 28 80 00       	push   $0x8028bf
  800f26:	6a 23                	push   $0x23
  800f28:	68 dc 28 80 00       	push   $0x8028dc
  800f2d:	e8 04 f4 ff ff       	call   800336 <_panic>

00800f32 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f32:	55                   	push   %ebp
  800f33:	89 e5                	mov    %esp,%ebp
  800f35:	57                   	push   %edi
  800f36:	56                   	push   %esi
  800f37:	53                   	push   %ebx
  800f38:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f3b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f40:	8b 55 08             	mov    0x8(%ebp),%edx
  800f43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f46:	b8 09 00 00 00       	mov    $0x9,%eax
  800f4b:	89 df                	mov    %ebx,%edi
  800f4d:	89 de                	mov    %ebx,%esi
  800f4f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f51:	85 c0                	test   %eax,%eax
  800f53:	7f 08                	jg     800f5d <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f58:	5b                   	pop    %ebx
  800f59:	5e                   	pop    %esi
  800f5a:	5f                   	pop    %edi
  800f5b:	5d                   	pop    %ebp
  800f5c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f5d:	83 ec 0c             	sub    $0xc,%esp
  800f60:	50                   	push   %eax
  800f61:	6a 09                	push   $0x9
  800f63:	68 bf 28 80 00       	push   $0x8028bf
  800f68:	6a 23                	push   $0x23
  800f6a:	68 dc 28 80 00       	push   $0x8028dc
  800f6f:	e8 c2 f3 ff ff       	call   800336 <_panic>

00800f74 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f74:	55                   	push   %ebp
  800f75:	89 e5                	mov    %esp,%ebp
  800f77:	57                   	push   %edi
  800f78:	56                   	push   %esi
  800f79:	53                   	push   %ebx
  800f7a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f7d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f82:	8b 55 08             	mov    0x8(%ebp),%edx
  800f85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f88:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f8d:	89 df                	mov    %ebx,%edi
  800f8f:	89 de                	mov    %ebx,%esi
  800f91:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f93:	85 c0                	test   %eax,%eax
  800f95:	7f 08                	jg     800f9f <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f9a:	5b                   	pop    %ebx
  800f9b:	5e                   	pop    %esi
  800f9c:	5f                   	pop    %edi
  800f9d:	5d                   	pop    %ebp
  800f9e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f9f:	83 ec 0c             	sub    $0xc,%esp
  800fa2:	50                   	push   %eax
  800fa3:	6a 0a                	push   $0xa
  800fa5:	68 bf 28 80 00       	push   $0x8028bf
  800faa:	6a 23                	push   $0x23
  800fac:	68 dc 28 80 00       	push   $0x8028dc
  800fb1:	e8 80 f3 ff ff       	call   800336 <_panic>

00800fb6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fb6:	55                   	push   %ebp
  800fb7:	89 e5                	mov    %esp,%ebp
  800fb9:	57                   	push   %edi
  800fba:	56                   	push   %esi
  800fbb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800fbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800fbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc2:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fc7:	be 00 00 00 00       	mov    $0x0,%esi
  800fcc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fcf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fd2:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800fd4:	5b                   	pop    %ebx
  800fd5:	5e                   	pop    %esi
  800fd6:	5f                   	pop    %edi
  800fd7:	5d                   	pop    %ebp
  800fd8:	c3                   	ret    

00800fd9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800fd9:	55                   	push   %ebp
  800fda:	89 e5                	mov    %esp,%ebp
  800fdc:	57                   	push   %edi
  800fdd:	56                   	push   %esi
  800fde:	53                   	push   %ebx
  800fdf:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800fe2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fe7:	8b 55 08             	mov    0x8(%ebp),%edx
  800fea:	b8 0d 00 00 00       	mov    $0xd,%eax
  800fef:	89 cb                	mov    %ecx,%ebx
  800ff1:	89 cf                	mov    %ecx,%edi
  800ff3:	89 ce                	mov    %ecx,%esi
  800ff5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ff7:	85 c0                	test   %eax,%eax
  800ff9:	7f 08                	jg     801003 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ffb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ffe:	5b                   	pop    %ebx
  800fff:	5e                   	pop    %esi
  801000:	5f                   	pop    %edi
  801001:	5d                   	pop    %ebp
  801002:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801003:	83 ec 0c             	sub    $0xc,%esp
  801006:	50                   	push   %eax
  801007:	6a 0d                	push   $0xd
  801009:	68 bf 28 80 00       	push   $0x8028bf
  80100e:	6a 23                	push   $0x23
  801010:	68 dc 28 80 00       	push   $0x8028dc
  801015:	e8 1c f3 ff ff       	call   800336 <_panic>

0080101a <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80101a:	55                   	push   %ebp
  80101b:	89 e5                	mov    %esp,%ebp
  80101d:	56                   	push   %esi
  80101e:	53                   	push   %ebx
  80101f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801022:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if((err&FEC_WR)==0 || (uvpt[PGNUM(addr)]&(PTE_W|PTE_COW))==0){
  801024:	8b 40 04             	mov    0x4(%eax),%eax
  801027:	83 e0 02             	and    $0x2,%eax
  80102a:	0f 84 82 00 00 00    	je     8010b2 <pgfault+0x98>
  801030:	89 da                	mov    %ebx,%edx
  801032:	c1 ea 0c             	shr    $0xc,%edx
  801035:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80103c:	f7 c2 02 08 00 00    	test   $0x802,%edx
  801042:	74 6e                	je     8010b2 <pgfault+0x98>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        envid_t envid = sys_getenvid();
  801044:	e8 a2 fd ff ff       	call   800deb <sys_getenvid>
  801049:	89 c6                	mov    %eax,%esi
	r = sys_page_alloc(envid,(void *)PFTEMP,PTE_P|PTE_W|PTE_U);
  80104b:	83 ec 04             	sub    $0x4,%esp
  80104e:	6a 07                	push   $0x7
  801050:	68 00 f0 7f 00       	push   $0x7ff000
  801055:	50                   	push   %eax
  801056:	e8 ce fd ff ff       	call   800e29 <sys_page_alloc>
	if(r<0) panic("pgfault:page allocation failed %e",r);
  80105b:	83 c4 10             	add    $0x10,%esp
  80105e:	85 c0                	test   %eax,%eax
  801060:	78 72                	js     8010d4 <pgfault+0xba>

	addr = ROUNDDOWN(addr,PGSIZE);
  801062:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy((void *)PFTEMP,(const void *)addr,PGSIZE);
  801068:	83 ec 04             	sub    $0x4,%esp
  80106b:	68 00 10 00 00       	push   $0x1000
  801070:	53                   	push   %ebx
  801071:	68 00 f0 7f 00       	push   $0x7ff000
  801076:	e8 ab fb ff ff       	call   800c26 <memcpy>

	if(sys_page_map(envid,(void *)PFTEMP, envid,addr,PTE_P|PTE_W|PTE_U)<0)
  80107b:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801082:	53                   	push   %ebx
  801083:	56                   	push   %esi
  801084:	68 00 f0 7f 00       	push   $0x7ff000
  801089:	56                   	push   %esi
  80108a:	e8 dd fd ff ff       	call   800e6c <sys_page_map>
  80108f:	83 c4 20             	add    $0x20,%esp
  801092:	85 c0                	test   %eax,%eax
  801094:	78 50                	js     8010e6 <pgfault+0xcc>
		panic("pgfault:page map failed\n");
	if(sys_page_unmap(envid,(void *)PFTEMP)<0)
  801096:	83 ec 08             	sub    $0x8,%esp
  801099:	68 00 f0 7f 00       	push   $0x7ff000
  80109e:	56                   	push   %esi
  80109f:	e8 0a fe ff ff       	call   800eae <sys_page_unmap>
  8010a4:	83 c4 10             	add    $0x10,%esp
  8010a7:	85 c0                	test   %eax,%eax
  8010a9:	78 4f                	js     8010fa <pgfault+0xe0>
		panic("pgfault: page upmap failed\n");
       //	panic("pgfault not implemented");
}
  8010ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010ae:	5b                   	pop    %ebx
  8010af:	5e                   	pop    %esi
  8010b0:	5d                   	pop    %ebp
  8010b1:	c3                   	ret    
		cprintf("Where is the error %d\n",err&FEC_WR);
  8010b2:	83 ec 08             	sub    $0x8,%esp
  8010b5:	50                   	push   %eax
  8010b6:	68 ea 28 80 00       	push   $0x8028ea
  8010bb:	e8 51 f3 ff ff       	call   800411 <cprintf>
		panic("pgfault:invalid user trap");
  8010c0:	83 c4 0c             	add    $0xc,%esp
  8010c3:	68 01 29 80 00       	push   $0x802901
  8010c8:	6a 1e                	push   $0x1e
  8010ca:	68 1b 29 80 00       	push   $0x80291b
  8010cf:	e8 62 f2 ff ff       	call   800336 <_panic>
	if(r<0) panic("pgfault:page allocation failed %e",r);
  8010d4:	50                   	push   %eax
  8010d5:	68 08 2a 80 00       	push   $0x802a08
  8010da:	6a 29                	push   $0x29
  8010dc:	68 1b 29 80 00       	push   $0x80291b
  8010e1:	e8 50 f2 ff ff       	call   800336 <_panic>
		panic("pgfault:page map failed\n");
  8010e6:	83 ec 04             	sub    $0x4,%esp
  8010e9:	68 26 29 80 00       	push   $0x802926
  8010ee:	6a 2f                	push   $0x2f
  8010f0:	68 1b 29 80 00       	push   $0x80291b
  8010f5:	e8 3c f2 ff ff       	call   800336 <_panic>
		panic("pgfault: page upmap failed\n");
  8010fa:	83 ec 04             	sub    $0x4,%esp
  8010fd:	68 3f 29 80 00       	push   $0x80293f
  801102:	6a 31                	push   $0x31
  801104:	68 1b 29 80 00       	push   $0x80291b
  801109:	e8 28 f2 ff ff       	call   800336 <_panic>

0080110e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80110e:	55                   	push   %ebp
  80110f:	89 e5                	mov    %esp,%ebp
  801111:	57                   	push   %edi
  801112:	56                   	push   %esi
  801113:	53                   	push   %ebx
  801114:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	set_pgfault_handler(pgfault);
  801117:	68 1a 10 80 00       	push   $0x80101a
  80111c:	e8 04 0f 00 00       	call   802025 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801121:	b8 07 00 00 00       	mov    $0x7,%eax
  801126:	cd 30                	int    $0x30
  801128:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80112b:	89 45 e0             	mov    %eax,-0x20(%ebp)
       
	envid_t envid = sys_exofork();
	uintptr_t addr;
  
	if(envid<0) panic("sys_exofork failed\n");
  80112e:	83 c4 10             	add    $0x10,%esp
  801131:	85 c0                	test   %eax,%eax
  801133:	78 27                	js     80115c <fork+0x4e>
	if(envid==0){
	  thisenv = &envs[ENVX(sys_getenvid())];
	  return 0;
	}

	for(addr=(uintptr_t)UTEXT; addr<USTACKTOP;addr+=PGSIZE){
  801135:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if(envid==0){
  80113a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80113e:	75 5e                	jne    80119e <fork+0x90>
	  thisenv = &envs[ENVX(sys_getenvid())];
  801140:	e8 a6 fc ff ff       	call   800deb <sys_getenvid>
  801145:	25 ff 03 00 00       	and    $0x3ff,%eax
  80114a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80114d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801152:	a3 04 40 80 00       	mov    %eax,0x804004
	  return 0;
  801157:	e9 fc 00 00 00       	jmp    801258 <fork+0x14a>
	if(envid<0) panic("sys_exofork failed\n");
  80115c:	83 ec 04             	sub    $0x4,%esp
  80115f:	68 5b 29 80 00       	push   $0x80295b
  801164:	6a 77                	push   $0x77
  801166:	68 1b 29 80 00       	push   $0x80291b
  80116b:	e8 c6 f1 ff ff       	call   800336 <_panic>
          if((r=sys_page_map(parent_envid,va,envid,va,uvpt[pn]&PTE_SYSCALL))<0)
  801170:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801177:	83 ec 0c             	sub    $0xc,%esp
  80117a:	25 07 0e 00 00       	and    $0xe07,%eax
  80117f:	50                   	push   %eax
  801180:	57                   	push   %edi
  801181:	ff 75 e0             	pushl  -0x20(%ebp)
  801184:	57                   	push   %edi
  801185:	ff 75 e4             	pushl  -0x1c(%ebp)
  801188:	e8 df fc ff ff       	call   800e6c <sys_page_map>
  80118d:	83 c4 20             	add    $0x20,%esp
	for(addr=(uintptr_t)UTEXT; addr<USTACKTOP;addr+=PGSIZE){
  801190:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801196:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80119c:	74 76                	je     801214 <fork+0x106>
	   if((uvpd[PDX(addr)]&PTE_P) && uvpt[PGNUM(addr)] & PTE_P)
  80119e:	89 d8                	mov    %ebx,%eax
  8011a0:	c1 e8 16             	shr    $0x16,%eax
  8011a3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011aa:	a8 01                	test   $0x1,%al
  8011ac:	74 e2                	je     801190 <fork+0x82>
  8011ae:	89 de                	mov    %ebx,%esi
  8011b0:	c1 ee 0c             	shr    $0xc,%esi
  8011b3:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011ba:	a8 01                	test   $0x1,%al
  8011bc:	74 d2                	je     801190 <fork+0x82>
        envid_t parent_envid = sys_getenvid();
  8011be:	e8 28 fc ff ff       	call   800deb <sys_getenvid>
  8011c3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	void *va = (void *)(pn*PGSIZE);
  8011c6:	89 f7                	mov    %esi,%edi
  8011c8:	c1 e7 0c             	shl    $0xc,%edi
        if(uvpt[pn] & PTE_SHARE){
  8011cb:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011d2:	f6 c4 04             	test   $0x4,%ah
  8011d5:	75 99                	jne    801170 <fork+0x62>
	if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)){
  8011d7:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011de:	a8 02                	test   $0x2,%al
  8011e0:	0f 85 ed 00 00 00    	jne    8012d3 <fork+0x1c5>
  8011e6:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011ed:	f6 c4 08             	test   $0x8,%ah
  8011f0:	0f 85 dd 00 00 00    	jne    8012d3 <fork+0x1c5>
	 if((r=sys_page_map(parent_envid,va,envid,va,perm))<0)
  8011f6:	83 ec 0c             	sub    $0xc,%esp
  8011f9:	6a 05                	push   $0x5
  8011fb:	57                   	push   %edi
  8011fc:	ff 75 e0             	pushl  -0x20(%ebp)
  8011ff:	57                   	push   %edi
  801200:	ff 75 e4             	pushl  -0x1c(%ebp)
  801203:	e8 64 fc ff ff       	call   800e6c <sys_page_map>
  801208:	83 c4 20             	add    $0x20,%esp
  80120b:	85 c0                	test   %eax,%eax
  80120d:	79 81                	jns    801190 <fork+0x82>
  80120f:	e9 db 00 00 00       	jmp    8012ef <fork+0x1e1>
		   duppage(envid,PGNUM(addr));
	}
        
	int r;
	if((r=sys_page_alloc(envid,(void *)UXSTACKTOP-PGSIZE,PTE_U|PTE_P|PTE_W))<0)
  801214:	83 ec 04             	sub    $0x4,%esp
  801217:	6a 07                	push   $0x7
  801219:	68 00 f0 bf ee       	push   $0xeebff000
  80121e:	ff 75 dc             	pushl  -0x24(%ebp)
  801221:	e8 03 fc ff ff       	call   800e29 <sys_page_alloc>
  801226:	83 c4 10             	add    $0x10,%esp
  801229:	85 c0                	test   %eax,%eax
  80122b:	78 36                	js     801263 <fork+0x155>
		panic("fork:page alloc failed %e\n",r);

	extern void _pgfault_upcall();
	if((r = sys_env_set_pgfault_upcall(envid,_pgfault_upcall)))
  80122d:	83 ec 08             	sub    $0x8,%esp
  801230:	68 8a 20 80 00       	push   $0x80208a
  801235:	ff 75 dc             	pushl  -0x24(%ebp)
  801238:	e8 37 fd ff ff       	call   800f74 <sys_env_set_pgfault_upcall>
  80123d:	83 c4 10             	add    $0x10,%esp
  801240:	85 c0                	test   %eax,%eax
  801242:	75 34                	jne    801278 <fork+0x16a>
		panic("fork:set upcall failed %e\n",r);
	if((r = sys_env_set_status(envid,ENV_RUNNABLE))<0)
  801244:	83 ec 08             	sub    $0x8,%esp
  801247:	6a 02                	push   $0x2
  801249:	ff 75 dc             	pushl  -0x24(%ebp)
  80124c:	e8 9f fc ff ff       	call   800ef0 <sys_env_set_status>
  801251:	83 c4 10             	add    $0x10,%esp
  801254:	85 c0                	test   %eax,%eax
  801256:	78 35                	js     80128d <fork+0x17f>
		panic("fork:set status failed %e\n",r);
	//cprintf("forkid= %d\n", envid);
	return envid;
       	
}
  801258:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80125b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80125e:	5b                   	pop    %ebx
  80125f:	5e                   	pop    %esi
  801260:	5f                   	pop    %edi
  801261:	5d                   	pop    %ebp
  801262:	c3                   	ret    
		panic("fork:page alloc failed %e\n",r);
  801263:	50                   	push   %eax
  801264:	68 9f 29 80 00       	push   $0x80299f
  801269:	68 84 00 00 00       	push   $0x84
  80126e:	68 1b 29 80 00       	push   $0x80291b
  801273:	e8 be f0 ff ff       	call   800336 <_panic>
		panic("fork:set upcall failed %e\n",r);
  801278:	50                   	push   %eax
  801279:	68 ba 29 80 00       	push   $0x8029ba
  80127e:	68 88 00 00 00       	push   $0x88
  801283:	68 1b 29 80 00       	push   $0x80291b
  801288:	e8 a9 f0 ff ff       	call   800336 <_panic>
		panic("fork:set status failed %e\n",r);
  80128d:	50                   	push   %eax
  80128e:	68 d5 29 80 00       	push   $0x8029d5
  801293:	68 8a 00 00 00       	push   $0x8a
  801298:	68 1b 29 80 00       	push   $0x80291b
  80129d:	e8 94 f0 ff ff       	call   800336 <_panic>
		if( (r=sys_page_map(parent_envid,va,parent_envid,va,perm))<0){
  8012a2:	83 ec 0c             	sub    $0xc,%esp
  8012a5:	68 05 08 00 00       	push   $0x805
  8012aa:	57                   	push   %edi
  8012ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012ae:	50                   	push   %eax
  8012af:	57                   	push   %edi
  8012b0:	50                   	push   %eax
  8012b1:	e8 b6 fb ff ff       	call   800e6c <sys_page_map>
  8012b6:	83 c4 20             	add    $0x20,%esp
  8012b9:	85 c0                	test   %eax,%eax
  8012bb:	0f 89 cf fe ff ff    	jns    801190 <fork+0x82>
		 panic("duppage:map02 failed %e",r);
  8012c1:	50                   	push   %eax
  8012c2:	68 87 29 80 00       	push   $0x802987
  8012c7:	6a 56                	push   $0x56
  8012c9:	68 1b 29 80 00       	push   $0x80291b
  8012ce:	e8 63 f0 ff ff       	call   800336 <_panic>
	 if((r=sys_page_map(parent_envid,va,envid,va,perm))<0)
  8012d3:	83 ec 0c             	sub    $0xc,%esp
  8012d6:	68 05 08 00 00       	push   $0x805
  8012db:	57                   	push   %edi
  8012dc:	ff 75 e0             	pushl  -0x20(%ebp)
  8012df:	57                   	push   %edi
  8012e0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012e3:	e8 84 fb ff ff       	call   800e6c <sys_page_map>
  8012e8:	83 c4 20             	add    $0x20,%esp
  8012eb:	85 c0                	test   %eax,%eax
  8012ed:	79 b3                	jns    8012a2 <fork+0x194>
		 panic("duppage:map01 failed %e",r);
  8012ef:	50                   	push   %eax
  8012f0:	68 6f 29 80 00       	push   $0x80296f
  8012f5:	6a 53                	push   $0x53
  8012f7:	68 1b 29 80 00       	push   $0x80291b
  8012fc:	e8 35 f0 ff ff       	call   800336 <_panic>

00801301 <sfork>:

// Challenge!
int
sfork(void)
{
  801301:	55                   	push   %ebp
  801302:	89 e5                	mov    %esp,%ebp
  801304:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801307:	68 f0 29 80 00       	push   $0x8029f0
  80130c:	68 94 00 00 00       	push   $0x94
  801311:	68 1b 29 80 00       	push   $0x80291b
  801316:	e8 1b f0 ff ff       	call   800336 <_panic>

0080131b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80131b:	55                   	push   %ebp
  80131c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80131e:	8b 45 08             	mov    0x8(%ebp),%eax
  801321:	05 00 00 00 30       	add    $0x30000000,%eax
  801326:	c1 e8 0c             	shr    $0xc,%eax
}
  801329:	5d                   	pop    %ebp
  80132a:	c3                   	ret    

0080132b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80132b:	55                   	push   %ebp
  80132c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80132e:	8b 45 08             	mov    0x8(%ebp),%eax
  801331:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801336:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80133b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801340:	5d                   	pop    %ebp
  801341:	c3                   	ret    

00801342 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801342:	55                   	push   %ebp
  801343:	89 e5                	mov    %esp,%ebp
  801345:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801348:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80134d:	89 c2                	mov    %eax,%edx
  80134f:	c1 ea 16             	shr    $0x16,%edx
  801352:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801359:	f6 c2 01             	test   $0x1,%dl
  80135c:	74 2a                	je     801388 <fd_alloc+0x46>
  80135e:	89 c2                	mov    %eax,%edx
  801360:	c1 ea 0c             	shr    $0xc,%edx
  801363:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80136a:	f6 c2 01             	test   $0x1,%dl
  80136d:	74 19                	je     801388 <fd_alloc+0x46>
  80136f:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801374:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801379:	75 d2                	jne    80134d <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80137b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801381:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801386:	eb 07                	jmp    80138f <fd_alloc+0x4d>
			*fd_store = fd;
  801388:	89 01                	mov    %eax,(%ecx)
			return 0;
  80138a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80138f:	5d                   	pop    %ebp
  801390:	c3                   	ret    

00801391 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801391:	55                   	push   %ebp
  801392:	89 e5                	mov    %esp,%ebp
  801394:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801397:	83 f8 1f             	cmp    $0x1f,%eax
  80139a:	77 36                	ja     8013d2 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80139c:	c1 e0 0c             	shl    $0xc,%eax
  80139f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013a4:	89 c2                	mov    %eax,%edx
  8013a6:	c1 ea 16             	shr    $0x16,%edx
  8013a9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013b0:	f6 c2 01             	test   $0x1,%dl
  8013b3:	74 24                	je     8013d9 <fd_lookup+0x48>
  8013b5:	89 c2                	mov    %eax,%edx
  8013b7:	c1 ea 0c             	shr    $0xc,%edx
  8013ba:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013c1:	f6 c2 01             	test   $0x1,%dl
  8013c4:	74 1a                	je     8013e0 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013c9:	89 02                	mov    %eax,(%edx)
	return 0;
  8013cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013d0:	5d                   	pop    %ebp
  8013d1:	c3                   	ret    
		return -E_INVAL;
  8013d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013d7:	eb f7                	jmp    8013d0 <fd_lookup+0x3f>
		return -E_INVAL;
  8013d9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013de:	eb f0                	jmp    8013d0 <fd_lookup+0x3f>
  8013e0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013e5:	eb e9                	jmp    8013d0 <fd_lookup+0x3f>

008013e7 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013e7:	55                   	push   %ebp
  8013e8:	89 e5                	mov    %esp,%ebp
  8013ea:	83 ec 08             	sub    $0x8,%esp
  8013ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013f0:	ba ac 2a 80 00       	mov    $0x802aac,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8013f5:	b8 08 30 80 00       	mov    $0x803008,%eax
		if (devtab[i]->dev_id == dev_id) {
  8013fa:	39 08                	cmp    %ecx,(%eax)
  8013fc:	74 33                	je     801431 <dev_lookup+0x4a>
  8013fe:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  801401:	8b 02                	mov    (%edx),%eax
  801403:	85 c0                	test   %eax,%eax
  801405:	75 f3                	jne    8013fa <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801407:	a1 04 40 80 00       	mov    0x804004,%eax
  80140c:	8b 40 48             	mov    0x48(%eax),%eax
  80140f:	83 ec 04             	sub    $0x4,%esp
  801412:	51                   	push   %ecx
  801413:	50                   	push   %eax
  801414:	68 2c 2a 80 00       	push   $0x802a2c
  801419:	e8 f3 ef ff ff       	call   800411 <cprintf>
	*dev = 0;
  80141e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801421:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801427:	83 c4 10             	add    $0x10,%esp
  80142a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80142f:	c9                   	leave  
  801430:	c3                   	ret    
			*dev = devtab[i];
  801431:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801434:	89 01                	mov    %eax,(%ecx)
			return 0;
  801436:	b8 00 00 00 00       	mov    $0x0,%eax
  80143b:	eb f2                	jmp    80142f <dev_lookup+0x48>

0080143d <fd_close>:
{
  80143d:	55                   	push   %ebp
  80143e:	89 e5                	mov    %esp,%ebp
  801440:	57                   	push   %edi
  801441:	56                   	push   %esi
  801442:	53                   	push   %ebx
  801443:	83 ec 1c             	sub    $0x1c,%esp
  801446:	8b 75 08             	mov    0x8(%ebp),%esi
  801449:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80144c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80144f:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801450:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801456:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801459:	50                   	push   %eax
  80145a:	e8 32 ff ff ff       	call   801391 <fd_lookup>
  80145f:	89 c3                	mov    %eax,%ebx
  801461:	83 c4 08             	add    $0x8,%esp
  801464:	85 c0                	test   %eax,%eax
  801466:	78 05                	js     80146d <fd_close+0x30>
	    || fd != fd2)
  801468:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80146b:	74 16                	je     801483 <fd_close+0x46>
		return (must_exist ? r : 0);
  80146d:	89 f8                	mov    %edi,%eax
  80146f:	84 c0                	test   %al,%al
  801471:	b8 00 00 00 00       	mov    $0x0,%eax
  801476:	0f 44 d8             	cmove  %eax,%ebx
}
  801479:	89 d8                	mov    %ebx,%eax
  80147b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80147e:	5b                   	pop    %ebx
  80147f:	5e                   	pop    %esi
  801480:	5f                   	pop    %edi
  801481:	5d                   	pop    %ebp
  801482:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801483:	83 ec 08             	sub    $0x8,%esp
  801486:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801489:	50                   	push   %eax
  80148a:	ff 36                	pushl  (%esi)
  80148c:	e8 56 ff ff ff       	call   8013e7 <dev_lookup>
  801491:	89 c3                	mov    %eax,%ebx
  801493:	83 c4 10             	add    $0x10,%esp
  801496:	85 c0                	test   %eax,%eax
  801498:	78 15                	js     8014af <fd_close+0x72>
		if (dev->dev_close)
  80149a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80149d:	8b 40 10             	mov    0x10(%eax),%eax
  8014a0:	85 c0                	test   %eax,%eax
  8014a2:	74 1b                	je     8014bf <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  8014a4:	83 ec 0c             	sub    $0xc,%esp
  8014a7:	56                   	push   %esi
  8014a8:	ff d0                	call   *%eax
  8014aa:	89 c3                	mov    %eax,%ebx
  8014ac:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8014af:	83 ec 08             	sub    $0x8,%esp
  8014b2:	56                   	push   %esi
  8014b3:	6a 00                	push   $0x0
  8014b5:	e8 f4 f9 ff ff       	call   800eae <sys_page_unmap>
	return r;
  8014ba:	83 c4 10             	add    $0x10,%esp
  8014bd:	eb ba                	jmp    801479 <fd_close+0x3c>
			r = 0;
  8014bf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014c4:	eb e9                	jmp    8014af <fd_close+0x72>

008014c6 <close>:

int
close(int fdnum)
{
  8014c6:	55                   	push   %ebp
  8014c7:	89 e5                	mov    %esp,%ebp
  8014c9:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014cf:	50                   	push   %eax
  8014d0:	ff 75 08             	pushl  0x8(%ebp)
  8014d3:	e8 b9 fe ff ff       	call   801391 <fd_lookup>
  8014d8:	83 c4 08             	add    $0x8,%esp
  8014db:	85 c0                	test   %eax,%eax
  8014dd:	78 10                	js     8014ef <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8014df:	83 ec 08             	sub    $0x8,%esp
  8014e2:	6a 01                	push   $0x1
  8014e4:	ff 75 f4             	pushl  -0xc(%ebp)
  8014e7:	e8 51 ff ff ff       	call   80143d <fd_close>
  8014ec:	83 c4 10             	add    $0x10,%esp
}
  8014ef:	c9                   	leave  
  8014f0:	c3                   	ret    

008014f1 <close_all>:

void
close_all(void)
{
  8014f1:	55                   	push   %ebp
  8014f2:	89 e5                	mov    %esp,%ebp
  8014f4:	53                   	push   %ebx
  8014f5:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014f8:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014fd:	83 ec 0c             	sub    $0xc,%esp
  801500:	53                   	push   %ebx
  801501:	e8 c0 ff ff ff       	call   8014c6 <close>
	for (i = 0; i < MAXFD; i++)
  801506:	83 c3 01             	add    $0x1,%ebx
  801509:	83 c4 10             	add    $0x10,%esp
  80150c:	83 fb 20             	cmp    $0x20,%ebx
  80150f:	75 ec                	jne    8014fd <close_all+0xc>
}
  801511:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801514:	c9                   	leave  
  801515:	c3                   	ret    

00801516 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801516:	55                   	push   %ebp
  801517:	89 e5                	mov    %esp,%ebp
  801519:	57                   	push   %edi
  80151a:	56                   	push   %esi
  80151b:	53                   	push   %ebx
  80151c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80151f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801522:	50                   	push   %eax
  801523:	ff 75 08             	pushl  0x8(%ebp)
  801526:	e8 66 fe ff ff       	call   801391 <fd_lookup>
  80152b:	89 c3                	mov    %eax,%ebx
  80152d:	83 c4 08             	add    $0x8,%esp
  801530:	85 c0                	test   %eax,%eax
  801532:	0f 88 81 00 00 00    	js     8015b9 <dup+0xa3>
		return r;
	close(newfdnum);
  801538:	83 ec 0c             	sub    $0xc,%esp
  80153b:	ff 75 0c             	pushl  0xc(%ebp)
  80153e:	e8 83 ff ff ff       	call   8014c6 <close>

	newfd = INDEX2FD(newfdnum);
  801543:	8b 75 0c             	mov    0xc(%ebp),%esi
  801546:	c1 e6 0c             	shl    $0xc,%esi
  801549:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80154f:	83 c4 04             	add    $0x4,%esp
  801552:	ff 75 e4             	pushl  -0x1c(%ebp)
  801555:	e8 d1 fd ff ff       	call   80132b <fd2data>
  80155a:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80155c:	89 34 24             	mov    %esi,(%esp)
  80155f:	e8 c7 fd ff ff       	call   80132b <fd2data>
  801564:	83 c4 10             	add    $0x10,%esp
  801567:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801569:	89 d8                	mov    %ebx,%eax
  80156b:	c1 e8 16             	shr    $0x16,%eax
  80156e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801575:	a8 01                	test   $0x1,%al
  801577:	74 11                	je     80158a <dup+0x74>
  801579:	89 d8                	mov    %ebx,%eax
  80157b:	c1 e8 0c             	shr    $0xc,%eax
  80157e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801585:	f6 c2 01             	test   $0x1,%dl
  801588:	75 39                	jne    8015c3 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80158a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80158d:	89 d0                	mov    %edx,%eax
  80158f:	c1 e8 0c             	shr    $0xc,%eax
  801592:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801599:	83 ec 0c             	sub    $0xc,%esp
  80159c:	25 07 0e 00 00       	and    $0xe07,%eax
  8015a1:	50                   	push   %eax
  8015a2:	56                   	push   %esi
  8015a3:	6a 00                	push   $0x0
  8015a5:	52                   	push   %edx
  8015a6:	6a 00                	push   $0x0
  8015a8:	e8 bf f8 ff ff       	call   800e6c <sys_page_map>
  8015ad:	89 c3                	mov    %eax,%ebx
  8015af:	83 c4 20             	add    $0x20,%esp
  8015b2:	85 c0                	test   %eax,%eax
  8015b4:	78 31                	js     8015e7 <dup+0xd1>
		goto err;

	return newfdnum;
  8015b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8015b9:	89 d8                	mov    %ebx,%eax
  8015bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015be:	5b                   	pop    %ebx
  8015bf:	5e                   	pop    %esi
  8015c0:	5f                   	pop    %edi
  8015c1:	5d                   	pop    %ebp
  8015c2:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015c3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015ca:	83 ec 0c             	sub    $0xc,%esp
  8015cd:	25 07 0e 00 00       	and    $0xe07,%eax
  8015d2:	50                   	push   %eax
  8015d3:	57                   	push   %edi
  8015d4:	6a 00                	push   $0x0
  8015d6:	53                   	push   %ebx
  8015d7:	6a 00                	push   $0x0
  8015d9:	e8 8e f8 ff ff       	call   800e6c <sys_page_map>
  8015de:	89 c3                	mov    %eax,%ebx
  8015e0:	83 c4 20             	add    $0x20,%esp
  8015e3:	85 c0                	test   %eax,%eax
  8015e5:	79 a3                	jns    80158a <dup+0x74>
	sys_page_unmap(0, newfd);
  8015e7:	83 ec 08             	sub    $0x8,%esp
  8015ea:	56                   	push   %esi
  8015eb:	6a 00                	push   $0x0
  8015ed:	e8 bc f8 ff ff       	call   800eae <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015f2:	83 c4 08             	add    $0x8,%esp
  8015f5:	57                   	push   %edi
  8015f6:	6a 00                	push   $0x0
  8015f8:	e8 b1 f8 ff ff       	call   800eae <sys_page_unmap>
	return r;
  8015fd:	83 c4 10             	add    $0x10,%esp
  801600:	eb b7                	jmp    8015b9 <dup+0xa3>

00801602 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801602:	55                   	push   %ebp
  801603:	89 e5                	mov    %esp,%ebp
  801605:	53                   	push   %ebx
  801606:	83 ec 14             	sub    $0x14,%esp
  801609:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80160c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80160f:	50                   	push   %eax
  801610:	53                   	push   %ebx
  801611:	e8 7b fd ff ff       	call   801391 <fd_lookup>
  801616:	83 c4 08             	add    $0x8,%esp
  801619:	85 c0                	test   %eax,%eax
  80161b:	78 3f                	js     80165c <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80161d:	83 ec 08             	sub    $0x8,%esp
  801620:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801623:	50                   	push   %eax
  801624:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801627:	ff 30                	pushl  (%eax)
  801629:	e8 b9 fd ff ff       	call   8013e7 <dev_lookup>
  80162e:	83 c4 10             	add    $0x10,%esp
  801631:	85 c0                	test   %eax,%eax
  801633:	78 27                	js     80165c <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801635:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801638:	8b 42 08             	mov    0x8(%edx),%eax
  80163b:	83 e0 03             	and    $0x3,%eax
  80163e:	83 f8 01             	cmp    $0x1,%eax
  801641:	74 1e                	je     801661 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801643:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801646:	8b 40 08             	mov    0x8(%eax),%eax
  801649:	85 c0                	test   %eax,%eax
  80164b:	74 35                	je     801682 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80164d:	83 ec 04             	sub    $0x4,%esp
  801650:	ff 75 10             	pushl  0x10(%ebp)
  801653:	ff 75 0c             	pushl  0xc(%ebp)
  801656:	52                   	push   %edx
  801657:	ff d0                	call   *%eax
  801659:	83 c4 10             	add    $0x10,%esp
}
  80165c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80165f:	c9                   	leave  
  801660:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801661:	a1 04 40 80 00       	mov    0x804004,%eax
  801666:	8b 40 48             	mov    0x48(%eax),%eax
  801669:	83 ec 04             	sub    $0x4,%esp
  80166c:	53                   	push   %ebx
  80166d:	50                   	push   %eax
  80166e:	68 70 2a 80 00       	push   $0x802a70
  801673:	e8 99 ed ff ff       	call   800411 <cprintf>
		return -E_INVAL;
  801678:	83 c4 10             	add    $0x10,%esp
  80167b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801680:	eb da                	jmp    80165c <read+0x5a>
		return -E_NOT_SUPP;
  801682:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801687:	eb d3                	jmp    80165c <read+0x5a>

00801689 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801689:	55                   	push   %ebp
  80168a:	89 e5                	mov    %esp,%ebp
  80168c:	57                   	push   %edi
  80168d:	56                   	push   %esi
  80168e:	53                   	push   %ebx
  80168f:	83 ec 0c             	sub    $0xc,%esp
  801692:	8b 7d 08             	mov    0x8(%ebp),%edi
  801695:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801698:	bb 00 00 00 00       	mov    $0x0,%ebx
  80169d:	39 f3                	cmp    %esi,%ebx
  80169f:	73 25                	jae    8016c6 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016a1:	83 ec 04             	sub    $0x4,%esp
  8016a4:	89 f0                	mov    %esi,%eax
  8016a6:	29 d8                	sub    %ebx,%eax
  8016a8:	50                   	push   %eax
  8016a9:	89 d8                	mov    %ebx,%eax
  8016ab:	03 45 0c             	add    0xc(%ebp),%eax
  8016ae:	50                   	push   %eax
  8016af:	57                   	push   %edi
  8016b0:	e8 4d ff ff ff       	call   801602 <read>
		if (m < 0)
  8016b5:	83 c4 10             	add    $0x10,%esp
  8016b8:	85 c0                	test   %eax,%eax
  8016ba:	78 08                	js     8016c4 <readn+0x3b>
			return m;
		if (m == 0)
  8016bc:	85 c0                	test   %eax,%eax
  8016be:	74 06                	je     8016c6 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  8016c0:	01 c3                	add    %eax,%ebx
  8016c2:	eb d9                	jmp    80169d <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016c4:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8016c6:	89 d8                	mov    %ebx,%eax
  8016c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016cb:	5b                   	pop    %ebx
  8016cc:	5e                   	pop    %esi
  8016cd:	5f                   	pop    %edi
  8016ce:	5d                   	pop    %ebp
  8016cf:	c3                   	ret    

008016d0 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016d0:	55                   	push   %ebp
  8016d1:	89 e5                	mov    %esp,%ebp
  8016d3:	53                   	push   %ebx
  8016d4:	83 ec 14             	sub    $0x14,%esp
  8016d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016da:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016dd:	50                   	push   %eax
  8016de:	53                   	push   %ebx
  8016df:	e8 ad fc ff ff       	call   801391 <fd_lookup>
  8016e4:	83 c4 08             	add    $0x8,%esp
  8016e7:	85 c0                	test   %eax,%eax
  8016e9:	78 3a                	js     801725 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016eb:	83 ec 08             	sub    $0x8,%esp
  8016ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f1:	50                   	push   %eax
  8016f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f5:	ff 30                	pushl  (%eax)
  8016f7:	e8 eb fc ff ff       	call   8013e7 <dev_lookup>
  8016fc:	83 c4 10             	add    $0x10,%esp
  8016ff:	85 c0                	test   %eax,%eax
  801701:	78 22                	js     801725 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801703:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801706:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80170a:	74 1e                	je     80172a <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80170c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80170f:	8b 52 0c             	mov    0xc(%edx),%edx
  801712:	85 d2                	test   %edx,%edx
  801714:	74 35                	je     80174b <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801716:	83 ec 04             	sub    $0x4,%esp
  801719:	ff 75 10             	pushl  0x10(%ebp)
  80171c:	ff 75 0c             	pushl  0xc(%ebp)
  80171f:	50                   	push   %eax
  801720:	ff d2                	call   *%edx
  801722:	83 c4 10             	add    $0x10,%esp
}
  801725:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801728:	c9                   	leave  
  801729:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80172a:	a1 04 40 80 00       	mov    0x804004,%eax
  80172f:	8b 40 48             	mov    0x48(%eax),%eax
  801732:	83 ec 04             	sub    $0x4,%esp
  801735:	53                   	push   %ebx
  801736:	50                   	push   %eax
  801737:	68 8c 2a 80 00       	push   $0x802a8c
  80173c:	e8 d0 ec ff ff       	call   800411 <cprintf>
		return -E_INVAL;
  801741:	83 c4 10             	add    $0x10,%esp
  801744:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801749:	eb da                	jmp    801725 <write+0x55>
		return -E_NOT_SUPP;
  80174b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801750:	eb d3                	jmp    801725 <write+0x55>

00801752 <seek>:

int
seek(int fdnum, off_t offset)
{
  801752:	55                   	push   %ebp
  801753:	89 e5                	mov    %esp,%ebp
  801755:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801758:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80175b:	50                   	push   %eax
  80175c:	ff 75 08             	pushl  0x8(%ebp)
  80175f:	e8 2d fc ff ff       	call   801391 <fd_lookup>
  801764:	83 c4 08             	add    $0x8,%esp
  801767:	85 c0                	test   %eax,%eax
  801769:	78 0e                	js     801779 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80176b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80176e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801771:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801774:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801779:	c9                   	leave  
  80177a:	c3                   	ret    

0080177b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80177b:	55                   	push   %ebp
  80177c:	89 e5                	mov    %esp,%ebp
  80177e:	53                   	push   %ebx
  80177f:	83 ec 14             	sub    $0x14,%esp
  801782:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801785:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801788:	50                   	push   %eax
  801789:	53                   	push   %ebx
  80178a:	e8 02 fc ff ff       	call   801391 <fd_lookup>
  80178f:	83 c4 08             	add    $0x8,%esp
  801792:	85 c0                	test   %eax,%eax
  801794:	78 37                	js     8017cd <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801796:	83 ec 08             	sub    $0x8,%esp
  801799:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80179c:	50                   	push   %eax
  80179d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a0:	ff 30                	pushl  (%eax)
  8017a2:	e8 40 fc ff ff       	call   8013e7 <dev_lookup>
  8017a7:	83 c4 10             	add    $0x10,%esp
  8017aa:	85 c0                	test   %eax,%eax
  8017ac:	78 1f                	js     8017cd <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017b5:	74 1b                	je     8017d2 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8017b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017ba:	8b 52 18             	mov    0x18(%edx),%edx
  8017bd:	85 d2                	test   %edx,%edx
  8017bf:	74 32                	je     8017f3 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017c1:	83 ec 08             	sub    $0x8,%esp
  8017c4:	ff 75 0c             	pushl  0xc(%ebp)
  8017c7:	50                   	push   %eax
  8017c8:	ff d2                	call   *%edx
  8017ca:	83 c4 10             	add    $0x10,%esp
}
  8017cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017d0:	c9                   	leave  
  8017d1:	c3                   	ret    
			thisenv->env_id, fdnum);
  8017d2:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017d7:	8b 40 48             	mov    0x48(%eax),%eax
  8017da:	83 ec 04             	sub    $0x4,%esp
  8017dd:	53                   	push   %ebx
  8017de:	50                   	push   %eax
  8017df:	68 4c 2a 80 00       	push   $0x802a4c
  8017e4:	e8 28 ec ff ff       	call   800411 <cprintf>
		return -E_INVAL;
  8017e9:	83 c4 10             	add    $0x10,%esp
  8017ec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017f1:	eb da                	jmp    8017cd <ftruncate+0x52>
		return -E_NOT_SUPP;
  8017f3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017f8:	eb d3                	jmp    8017cd <ftruncate+0x52>

008017fa <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017fa:	55                   	push   %ebp
  8017fb:	89 e5                	mov    %esp,%ebp
  8017fd:	53                   	push   %ebx
  8017fe:	83 ec 14             	sub    $0x14,%esp
  801801:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801804:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801807:	50                   	push   %eax
  801808:	ff 75 08             	pushl  0x8(%ebp)
  80180b:	e8 81 fb ff ff       	call   801391 <fd_lookup>
  801810:	83 c4 08             	add    $0x8,%esp
  801813:	85 c0                	test   %eax,%eax
  801815:	78 4b                	js     801862 <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801817:	83 ec 08             	sub    $0x8,%esp
  80181a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80181d:	50                   	push   %eax
  80181e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801821:	ff 30                	pushl  (%eax)
  801823:	e8 bf fb ff ff       	call   8013e7 <dev_lookup>
  801828:	83 c4 10             	add    $0x10,%esp
  80182b:	85 c0                	test   %eax,%eax
  80182d:	78 33                	js     801862 <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  80182f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801832:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801836:	74 2f                	je     801867 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801838:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80183b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801842:	00 00 00 
	stat->st_isdir = 0;
  801845:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80184c:	00 00 00 
	stat->st_dev = dev;
  80184f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801855:	83 ec 08             	sub    $0x8,%esp
  801858:	53                   	push   %ebx
  801859:	ff 75 f0             	pushl  -0x10(%ebp)
  80185c:	ff 50 14             	call   *0x14(%eax)
  80185f:	83 c4 10             	add    $0x10,%esp
}
  801862:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801865:	c9                   	leave  
  801866:	c3                   	ret    
		return -E_NOT_SUPP;
  801867:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80186c:	eb f4                	jmp    801862 <fstat+0x68>

0080186e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80186e:	55                   	push   %ebp
  80186f:	89 e5                	mov    %esp,%ebp
  801871:	56                   	push   %esi
  801872:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801873:	83 ec 08             	sub    $0x8,%esp
  801876:	6a 00                	push   $0x0
  801878:	ff 75 08             	pushl  0x8(%ebp)
  80187b:	e8 e7 01 00 00       	call   801a67 <open>
  801880:	89 c3                	mov    %eax,%ebx
  801882:	83 c4 10             	add    $0x10,%esp
  801885:	85 c0                	test   %eax,%eax
  801887:	78 1b                	js     8018a4 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801889:	83 ec 08             	sub    $0x8,%esp
  80188c:	ff 75 0c             	pushl  0xc(%ebp)
  80188f:	50                   	push   %eax
  801890:	e8 65 ff ff ff       	call   8017fa <fstat>
  801895:	89 c6                	mov    %eax,%esi
	close(fd);
  801897:	89 1c 24             	mov    %ebx,(%esp)
  80189a:	e8 27 fc ff ff       	call   8014c6 <close>
	return r;
  80189f:	83 c4 10             	add    $0x10,%esp
  8018a2:	89 f3                	mov    %esi,%ebx
}
  8018a4:	89 d8                	mov    %ebx,%eax
  8018a6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018a9:	5b                   	pop    %ebx
  8018aa:	5e                   	pop    %esi
  8018ab:	5d                   	pop    %ebp
  8018ac:	c3                   	ret    

008018ad <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018ad:	55                   	push   %ebp
  8018ae:	89 e5                	mov    %esp,%ebp
  8018b0:	56                   	push   %esi
  8018b1:	53                   	push   %ebx
  8018b2:	89 c6                	mov    %eax,%esi
  8018b4:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8018b6:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8018bd:	74 27                	je     8018e6 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018bf:	6a 07                	push   $0x7
  8018c1:	68 00 50 80 00       	push   $0x805000
  8018c6:	56                   	push   %esi
  8018c7:	ff 35 00 40 80 00    	pushl  0x804000
  8018cd:	e8 54 08 00 00       	call   802126 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018d2:	83 c4 0c             	add    $0xc,%esp
  8018d5:	6a 00                	push   $0x0
  8018d7:	53                   	push   %ebx
  8018d8:	6a 00                	push   $0x0
  8018da:	e8 d2 07 00 00       	call   8020b1 <ipc_recv>
}
  8018df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018e2:	5b                   	pop    %ebx
  8018e3:	5e                   	pop    %esi
  8018e4:	5d                   	pop    %ebp
  8018e5:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018e6:	83 ec 0c             	sub    $0xc,%esp
  8018e9:	6a 01                	push   $0x1
  8018eb:	e8 8c 08 00 00       	call   80217c <ipc_find_env>
  8018f0:	a3 00 40 80 00       	mov    %eax,0x804000
  8018f5:	83 c4 10             	add    $0x10,%esp
  8018f8:	eb c5                	jmp    8018bf <fsipc+0x12>

008018fa <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018fa:	55                   	push   %ebp
  8018fb:	89 e5                	mov    %esp,%ebp
  8018fd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801900:	8b 45 08             	mov    0x8(%ebp),%eax
  801903:	8b 40 0c             	mov    0xc(%eax),%eax
  801906:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80190b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80190e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801913:	ba 00 00 00 00       	mov    $0x0,%edx
  801918:	b8 02 00 00 00       	mov    $0x2,%eax
  80191d:	e8 8b ff ff ff       	call   8018ad <fsipc>
}
  801922:	c9                   	leave  
  801923:	c3                   	ret    

00801924 <devfile_flush>:
{
  801924:	55                   	push   %ebp
  801925:	89 e5                	mov    %esp,%ebp
  801927:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80192a:	8b 45 08             	mov    0x8(%ebp),%eax
  80192d:	8b 40 0c             	mov    0xc(%eax),%eax
  801930:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801935:	ba 00 00 00 00       	mov    $0x0,%edx
  80193a:	b8 06 00 00 00       	mov    $0x6,%eax
  80193f:	e8 69 ff ff ff       	call   8018ad <fsipc>
}
  801944:	c9                   	leave  
  801945:	c3                   	ret    

00801946 <devfile_stat>:
{
  801946:	55                   	push   %ebp
  801947:	89 e5                	mov    %esp,%ebp
  801949:	53                   	push   %ebx
  80194a:	83 ec 04             	sub    $0x4,%esp
  80194d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801950:	8b 45 08             	mov    0x8(%ebp),%eax
  801953:	8b 40 0c             	mov    0xc(%eax),%eax
  801956:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80195b:	ba 00 00 00 00       	mov    $0x0,%edx
  801960:	b8 05 00 00 00       	mov    $0x5,%eax
  801965:	e8 43 ff ff ff       	call   8018ad <fsipc>
  80196a:	85 c0                	test   %eax,%eax
  80196c:	78 2c                	js     80199a <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80196e:	83 ec 08             	sub    $0x8,%esp
  801971:	68 00 50 80 00       	push   $0x805000
  801976:	53                   	push   %ebx
  801977:	e8 b4 f0 ff ff       	call   800a30 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80197c:	a1 80 50 80 00       	mov    0x805080,%eax
  801981:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801987:	a1 84 50 80 00       	mov    0x805084,%eax
  80198c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801992:	83 c4 10             	add    $0x10,%esp
  801995:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80199a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80199d:	c9                   	leave  
  80199e:	c3                   	ret    

0080199f <devfile_write>:
{
  80199f:	55                   	push   %ebp
  8019a0:	89 e5                	mov    %esp,%ebp
  8019a2:	83 ec 0c             	sub    $0xc,%esp
  8019a5:	8b 45 10             	mov    0x10(%ebp),%eax
  8019a8:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8019ad:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8019b2:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8019b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8019b8:	8b 52 0c             	mov    0xc(%edx),%edx
  8019bb:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8019c1:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf,buf,n);
  8019c6:	50                   	push   %eax
  8019c7:	ff 75 0c             	pushl  0xc(%ebp)
  8019ca:	68 08 50 80 00       	push   $0x805008
  8019cf:	e8 ea f1 ff ff       	call   800bbe <memmove>
	if((r = fsipc(FSREQ_WRITE,NULL))<0)
  8019d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8019d9:	b8 04 00 00 00       	mov    $0x4,%eax
  8019de:	e8 ca fe ff ff       	call   8018ad <fsipc>
}
  8019e3:	c9                   	leave  
  8019e4:	c3                   	ret    

008019e5 <devfile_read>:
{
  8019e5:	55                   	push   %ebp
  8019e6:	89 e5                	mov    %esp,%ebp
  8019e8:	56                   	push   %esi
  8019e9:	53                   	push   %ebx
  8019ea:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f0:	8b 40 0c             	mov    0xc(%eax),%eax
  8019f3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019f8:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019fe:	ba 00 00 00 00       	mov    $0x0,%edx
  801a03:	b8 03 00 00 00       	mov    $0x3,%eax
  801a08:	e8 a0 fe ff ff       	call   8018ad <fsipc>
  801a0d:	89 c3                	mov    %eax,%ebx
  801a0f:	85 c0                	test   %eax,%eax
  801a11:	78 1f                	js     801a32 <devfile_read+0x4d>
	assert(r <= n);
  801a13:	39 f0                	cmp    %esi,%eax
  801a15:	77 24                	ja     801a3b <devfile_read+0x56>
	assert(r <= PGSIZE);
  801a17:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a1c:	7f 33                	jg     801a51 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a1e:	83 ec 04             	sub    $0x4,%esp
  801a21:	50                   	push   %eax
  801a22:	68 00 50 80 00       	push   $0x805000
  801a27:	ff 75 0c             	pushl  0xc(%ebp)
  801a2a:	e8 8f f1 ff ff       	call   800bbe <memmove>
	return r;
  801a2f:	83 c4 10             	add    $0x10,%esp
}
  801a32:	89 d8                	mov    %ebx,%eax
  801a34:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a37:	5b                   	pop    %ebx
  801a38:	5e                   	pop    %esi
  801a39:	5d                   	pop    %ebp
  801a3a:	c3                   	ret    
	assert(r <= n);
  801a3b:	68 bc 2a 80 00       	push   $0x802abc
  801a40:	68 c3 2a 80 00       	push   $0x802ac3
  801a45:	6a 7c                	push   $0x7c
  801a47:	68 d8 2a 80 00       	push   $0x802ad8
  801a4c:	e8 e5 e8 ff ff       	call   800336 <_panic>
	assert(r <= PGSIZE);
  801a51:	68 e3 2a 80 00       	push   $0x802ae3
  801a56:	68 c3 2a 80 00       	push   $0x802ac3
  801a5b:	6a 7d                	push   $0x7d
  801a5d:	68 d8 2a 80 00       	push   $0x802ad8
  801a62:	e8 cf e8 ff ff       	call   800336 <_panic>

00801a67 <open>:
{
  801a67:	55                   	push   %ebp
  801a68:	89 e5                	mov    %esp,%ebp
  801a6a:	56                   	push   %esi
  801a6b:	53                   	push   %ebx
  801a6c:	83 ec 1c             	sub    $0x1c,%esp
  801a6f:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801a72:	56                   	push   %esi
  801a73:	e8 81 ef ff ff       	call   8009f9 <strlen>
  801a78:	83 c4 10             	add    $0x10,%esp
  801a7b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a80:	7f 6c                	jg     801aee <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801a82:	83 ec 0c             	sub    $0xc,%esp
  801a85:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a88:	50                   	push   %eax
  801a89:	e8 b4 f8 ff ff       	call   801342 <fd_alloc>
  801a8e:	89 c3                	mov    %eax,%ebx
  801a90:	83 c4 10             	add    $0x10,%esp
  801a93:	85 c0                	test   %eax,%eax
  801a95:	78 3c                	js     801ad3 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801a97:	83 ec 08             	sub    $0x8,%esp
  801a9a:	56                   	push   %esi
  801a9b:	68 00 50 80 00       	push   $0x805000
  801aa0:	e8 8b ef ff ff       	call   800a30 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801aa5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aa8:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801aad:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ab0:	b8 01 00 00 00       	mov    $0x1,%eax
  801ab5:	e8 f3 fd ff ff       	call   8018ad <fsipc>
  801aba:	89 c3                	mov    %eax,%ebx
  801abc:	83 c4 10             	add    $0x10,%esp
  801abf:	85 c0                	test   %eax,%eax
  801ac1:	78 19                	js     801adc <open+0x75>
	return fd2num(fd);
  801ac3:	83 ec 0c             	sub    $0xc,%esp
  801ac6:	ff 75 f4             	pushl  -0xc(%ebp)
  801ac9:	e8 4d f8 ff ff       	call   80131b <fd2num>
  801ace:	89 c3                	mov    %eax,%ebx
  801ad0:	83 c4 10             	add    $0x10,%esp
}
  801ad3:	89 d8                	mov    %ebx,%eax
  801ad5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ad8:	5b                   	pop    %ebx
  801ad9:	5e                   	pop    %esi
  801ada:	5d                   	pop    %ebp
  801adb:	c3                   	ret    
		fd_close(fd, 0);
  801adc:	83 ec 08             	sub    $0x8,%esp
  801adf:	6a 00                	push   $0x0
  801ae1:	ff 75 f4             	pushl  -0xc(%ebp)
  801ae4:	e8 54 f9 ff ff       	call   80143d <fd_close>
		return r;
  801ae9:	83 c4 10             	add    $0x10,%esp
  801aec:	eb e5                	jmp    801ad3 <open+0x6c>
		return -E_BAD_PATH;
  801aee:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801af3:	eb de                	jmp    801ad3 <open+0x6c>

00801af5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801af5:	55                   	push   %ebp
  801af6:	89 e5                	mov    %esp,%ebp
  801af8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801afb:	ba 00 00 00 00       	mov    $0x0,%edx
  801b00:	b8 08 00 00 00       	mov    $0x8,%eax
  801b05:	e8 a3 fd ff ff       	call   8018ad <fsipc>
}
  801b0a:	c9                   	leave  
  801b0b:	c3                   	ret    

00801b0c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b0c:	55                   	push   %ebp
  801b0d:	89 e5                	mov    %esp,%ebp
  801b0f:	56                   	push   %esi
  801b10:	53                   	push   %ebx
  801b11:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b14:	83 ec 0c             	sub    $0xc,%esp
  801b17:	ff 75 08             	pushl  0x8(%ebp)
  801b1a:	e8 0c f8 ff ff       	call   80132b <fd2data>
  801b1f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b21:	83 c4 08             	add    $0x8,%esp
  801b24:	68 ef 2a 80 00       	push   $0x802aef
  801b29:	53                   	push   %ebx
  801b2a:	e8 01 ef ff ff       	call   800a30 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b2f:	8b 46 04             	mov    0x4(%esi),%eax
  801b32:	2b 06                	sub    (%esi),%eax
  801b34:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b3a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b41:	00 00 00 
	stat->st_dev = &devpipe;
  801b44:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801b4b:	30 80 00 
	return 0;
}
  801b4e:	b8 00 00 00 00       	mov    $0x0,%eax
  801b53:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b56:	5b                   	pop    %ebx
  801b57:	5e                   	pop    %esi
  801b58:	5d                   	pop    %ebp
  801b59:	c3                   	ret    

00801b5a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b5a:	55                   	push   %ebp
  801b5b:	89 e5                	mov    %esp,%ebp
  801b5d:	53                   	push   %ebx
  801b5e:	83 ec 0c             	sub    $0xc,%esp
  801b61:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b64:	53                   	push   %ebx
  801b65:	6a 00                	push   $0x0
  801b67:	e8 42 f3 ff ff       	call   800eae <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b6c:	89 1c 24             	mov    %ebx,(%esp)
  801b6f:	e8 b7 f7 ff ff       	call   80132b <fd2data>
  801b74:	83 c4 08             	add    $0x8,%esp
  801b77:	50                   	push   %eax
  801b78:	6a 00                	push   $0x0
  801b7a:	e8 2f f3 ff ff       	call   800eae <sys_page_unmap>
}
  801b7f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b82:	c9                   	leave  
  801b83:	c3                   	ret    

00801b84 <_pipeisclosed>:
{
  801b84:	55                   	push   %ebp
  801b85:	89 e5                	mov    %esp,%ebp
  801b87:	57                   	push   %edi
  801b88:	56                   	push   %esi
  801b89:	53                   	push   %ebx
  801b8a:	83 ec 1c             	sub    $0x1c,%esp
  801b8d:	89 c7                	mov    %eax,%edi
  801b8f:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801b91:	a1 04 40 80 00       	mov    0x804004,%eax
  801b96:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801b99:	83 ec 0c             	sub    $0xc,%esp
  801b9c:	57                   	push   %edi
  801b9d:	e8 13 06 00 00       	call   8021b5 <pageref>
  801ba2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801ba5:	89 34 24             	mov    %esi,(%esp)
  801ba8:	e8 08 06 00 00       	call   8021b5 <pageref>
		nn = thisenv->env_runs;
  801bad:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801bb3:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801bb6:	83 c4 10             	add    $0x10,%esp
  801bb9:	39 cb                	cmp    %ecx,%ebx
  801bbb:	74 1b                	je     801bd8 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801bbd:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801bc0:	75 cf                	jne    801b91 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bc2:	8b 42 58             	mov    0x58(%edx),%eax
  801bc5:	6a 01                	push   $0x1
  801bc7:	50                   	push   %eax
  801bc8:	53                   	push   %ebx
  801bc9:	68 f6 2a 80 00       	push   $0x802af6
  801bce:	e8 3e e8 ff ff       	call   800411 <cprintf>
  801bd3:	83 c4 10             	add    $0x10,%esp
  801bd6:	eb b9                	jmp    801b91 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801bd8:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801bdb:	0f 94 c0             	sete   %al
  801bde:	0f b6 c0             	movzbl %al,%eax
}
  801be1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801be4:	5b                   	pop    %ebx
  801be5:	5e                   	pop    %esi
  801be6:	5f                   	pop    %edi
  801be7:	5d                   	pop    %ebp
  801be8:	c3                   	ret    

00801be9 <devpipe_write>:
{
  801be9:	55                   	push   %ebp
  801bea:	89 e5                	mov    %esp,%ebp
  801bec:	57                   	push   %edi
  801bed:	56                   	push   %esi
  801bee:	53                   	push   %ebx
  801bef:	83 ec 28             	sub    $0x28,%esp
  801bf2:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801bf5:	56                   	push   %esi
  801bf6:	e8 30 f7 ff ff       	call   80132b <fd2data>
  801bfb:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801bfd:	83 c4 10             	add    $0x10,%esp
  801c00:	bf 00 00 00 00       	mov    $0x0,%edi
  801c05:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c08:	74 4f                	je     801c59 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c0a:	8b 43 04             	mov    0x4(%ebx),%eax
  801c0d:	8b 0b                	mov    (%ebx),%ecx
  801c0f:	8d 51 20             	lea    0x20(%ecx),%edx
  801c12:	39 d0                	cmp    %edx,%eax
  801c14:	72 14                	jb     801c2a <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801c16:	89 da                	mov    %ebx,%edx
  801c18:	89 f0                	mov    %esi,%eax
  801c1a:	e8 65 ff ff ff       	call   801b84 <_pipeisclosed>
  801c1f:	85 c0                	test   %eax,%eax
  801c21:	75 3a                	jne    801c5d <devpipe_write+0x74>
			sys_yield();
  801c23:	e8 e2 f1 ff ff       	call   800e0a <sys_yield>
  801c28:	eb e0                	jmp    801c0a <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c2d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c31:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c34:	89 c2                	mov    %eax,%edx
  801c36:	c1 fa 1f             	sar    $0x1f,%edx
  801c39:	89 d1                	mov    %edx,%ecx
  801c3b:	c1 e9 1b             	shr    $0x1b,%ecx
  801c3e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c41:	83 e2 1f             	and    $0x1f,%edx
  801c44:	29 ca                	sub    %ecx,%edx
  801c46:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c4a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c4e:	83 c0 01             	add    $0x1,%eax
  801c51:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801c54:	83 c7 01             	add    $0x1,%edi
  801c57:	eb ac                	jmp    801c05 <devpipe_write+0x1c>
	return i;
  801c59:	89 f8                	mov    %edi,%eax
  801c5b:	eb 05                	jmp    801c62 <devpipe_write+0x79>
				return 0;
  801c5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c65:	5b                   	pop    %ebx
  801c66:	5e                   	pop    %esi
  801c67:	5f                   	pop    %edi
  801c68:	5d                   	pop    %ebp
  801c69:	c3                   	ret    

00801c6a <devpipe_read>:
{
  801c6a:	55                   	push   %ebp
  801c6b:	89 e5                	mov    %esp,%ebp
  801c6d:	57                   	push   %edi
  801c6e:	56                   	push   %esi
  801c6f:	53                   	push   %ebx
  801c70:	83 ec 18             	sub    $0x18,%esp
  801c73:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801c76:	57                   	push   %edi
  801c77:	e8 af f6 ff ff       	call   80132b <fd2data>
  801c7c:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c7e:	83 c4 10             	add    $0x10,%esp
  801c81:	be 00 00 00 00       	mov    $0x0,%esi
  801c86:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c89:	74 47                	je     801cd2 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  801c8b:	8b 03                	mov    (%ebx),%eax
  801c8d:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c90:	75 22                	jne    801cb4 <devpipe_read+0x4a>
			if (i > 0)
  801c92:	85 f6                	test   %esi,%esi
  801c94:	75 14                	jne    801caa <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801c96:	89 da                	mov    %ebx,%edx
  801c98:	89 f8                	mov    %edi,%eax
  801c9a:	e8 e5 fe ff ff       	call   801b84 <_pipeisclosed>
  801c9f:	85 c0                	test   %eax,%eax
  801ca1:	75 33                	jne    801cd6 <devpipe_read+0x6c>
			sys_yield();
  801ca3:	e8 62 f1 ff ff       	call   800e0a <sys_yield>
  801ca8:	eb e1                	jmp    801c8b <devpipe_read+0x21>
				return i;
  801caa:	89 f0                	mov    %esi,%eax
}
  801cac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801caf:	5b                   	pop    %ebx
  801cb0:	5e                   	pop    %esi
  801cb1:	5f                   	pop    %edi
  801cb2:	5d                   	pop    %ebp
  801cb3:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801cb4:	99                   	cltd   
  801cb5:	c1 ea 1b             	shr    $0x1b,%edx
  801cb8:	01 d0                	add    %edx,%eax
  801cba:	83 e0 1f             	and    $0x1f,%eax
  801cbd:	29 d0                	sub    %edx,%eax
  801cbf:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801cc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cc7:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801cca:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801ccd:	83 c6 01             	add    $0x1,%esi
  801cd0:	eb b4                	jmp    801c86 <devpipe_read+0x1c>
	return i;
  801cd2:	89 f0                	mov    %esi,%eax
  801cd4:	eb d6                	jmp    801cac <devpipe_read+0x42>
				return 0;
  801cd6:	b8 00 00 00 00       	mov    $0x0,%eax
  801cdb:	eb cf                	jmp    801cac <devpipe_read+0x42>

00801cdd <pipe>:
{
  801cdd:	55                   	push   %ebp
  801cde:	89 e5                	mov    %esp,%ebp
  801ce0:	56                   	push   %esi
  801ce1:	53                   	push   %ebx
  801ce2:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801ce5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ce8:	50                   	push   %eax
  801ce9:	e8 54 f6 ff ff       	call   801342 <fd_alloc>
  801cee:	89 c3                	mov    %eax,%ebx
  801cf0:	83 c4 10             	add    $0x10,%esp
  801cf3:	85 c0                	test   %eax,%eax
  801cf5:	78 5b                	js     801d52 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cf7:	83 ec 04             	sub    $0x4,%esp
  801cfa:	68 07 04 00 00       	push   $0x407
  801cff:	ff 75 f4             	pushl  -0xc(%ebp)
  801d02:	6a 00                	push   $0x0
  801d04:	e8 20 f1 ff ff       	call   800e29 <sys_page_alloc>
  801d09:	89 c3                	mov    %eax,%ebx
  801d0b:	83 c4 10             	add    $0x10,%esp
  801d0e:	85 c0                	test   %eax,%eax
  801d10:	78 40                	js     801d52 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  801d12:	83 ec 0c             	sub    $0xc,%esp
  801d15:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d18:	50                   	push   %eax
  801d19:	e8 24 f6 ff ff       	call   801342 <fd_alloc>
  801d1e:	89 c3                	mov    %eax,%ebx
  801d20:	83 c4 10             	add    $0x10,%esp
  801d23:	85 c0                	test   %eax,%eax
  801d25:	78 1b                	js     801d42 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d27:	83 ec 04             	sub    $0x4,%esp
  801d2a:	68 07 04 00 00       	push   $0x407
  801d2f:	ff 75 f0             	pushl  -0x10(%ebp)
  801d32:	6a 00                	push   $0x0
  801d34:	e8 f0 f0 ff ff       	call   800e29 <sys_page_alloc>
  801d39:	89 c3                	mov    %eax,%ebx
  801d3b:	83 c4 10             	add    $0x10,%esp
  801d3e:	85 c0                	test   %eax,%eax
  801d40:	79 19                	jns    801d5b <pipe+0x7e>
	sys_page_unmap(0, fd0);
  801d42:	83 ec 08             	sub    $0x8,%esp
  801d45:	ff 75 f4             	pushl  -0xc(%ebp)
  801d48:	6a 00                	push   $0x0
  801d4a:	e8 5f f1 ff ff       	call   800eae <sys_page_unmap>
  801d4f:	83 c4 10             	add    $0x10,%esp
}
  801d52:	89 d8                	mov    %ebx,%eax
  801d54:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d57:	5b                   	pop    %ebx
  801d58:	5e                   	pop    %esi
  801d59:	5d                   	pop    %ebp
  801d5a:	c3                   	ret    
	va = fd2data(fd0);
  801d5b:	83 ec 0c             	sub    $0xc,%esp
  801d5e:	ff 75 f4             	pushl  -0xc(%ebp)
  801d61:	e8 c5 f5 ff ff       	call   80132b <fd2data>
  801d66:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d68:	83 c4 0c             	add    $0xc,%esp
  801d6b:	68 07 04 00 00       	push   $0x407
  801d70:	50                   	push   %eax
  801d71:	6a 00                	push   $0x0
  801d73:	e8 b1 f0 ff ff       	call   800e29 <sys_page_alloc>
  801d78:	89 c3                	mov    %eax,%ebx
  801d7a:	83 c4 10             	add    $0x10,%esp
  801d7d:	85 c0                	test   %eax,%eax
  801d7f:	0f 88 8c 00 00 00    	js     801e11 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d85:	83 ec 0c             	sub    $0xc,%esp
  801d88:	ff 75 f0             	pushl  -0x10(%ebp)
  801d8b:	e8 9b f5 ff ff       	call   80132b <fd2data>
  801d90:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d97:	50                   	push   %eax
  801d98:	6a 00                	push   $0x0
  801d9a:	56                   	push   %esi
  801d9b:	6a 00                	push   $0x0
  801d9d:	e8 ca f0 ff ff       	call   800e6c <sys_page_map>
  801da2:	89 c3                	mov    %eax,%ebx
  801da4:	83 c4 20             	add    $0x20,%esp
  801da7:	85 c0                	test   %eax,%eax
  801da9:	78 58                	js     801e03 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801dab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dae:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801db4:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801db6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801db9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801dc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dc3:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801dc9:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801dcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dce:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801dd5:	83 ec 0c             	sub    $0xc,%esp
  801dd8:	ff 75 f4             	pushl  -0xc(%ebp)
  801ddb:	e8 3b f5 ff ff       	call   80131b <fd2num>
  801de0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801de3:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801de5:	83 c4 04             	add    $0x4,%esp
  801de8:	ff 75 f0             	pushl  -0x10(%ebp)
  801deb:	e8 2b f5 ff ff       	call   80131b <fd2num>
  801df0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801df3:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801df6:	83 c4 10             	add    $0x10,%esp
  801df9:	bb 00 00 00 00       	mov    $0x0,%ebx
  801dfe:	e9 4f ff ff ff       	jmp    801d52 <pipe+0x75>
	sys_page_unmap(0, va);
  801e03:	83 ec 08             	sub    $0x8,%esp
  801e06:	56                   	push   %esi
  801e07:	6a 00                	push   $0x0
  801e09:	e8 a0 f0 ff ff       	call   800eae <sys_page_unmap>
  801e0e:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801e11:	83 ec 08             	sub    $0x8,%esp
  801e14:	ff 75 f0             	pushl  -0x10(%ebp)
  801e17:	6a 00                	push   $0x0
  801e19:	e8 90 f0 ff ff       	call   800eae <sys_page_unmap>
  801e1e:	83 c4 10             	add    $0x10,%esp
  801e21:	e9 1c ff ff ff       	jmp    801d42 <pipe+0x65>

00801e26 <pipeisclosed>:
{
  801e26:	55                   	push   %ebp
  801e27:	89 e5                	mov    %esp,%ebp
  801e29:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e2c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e2f:	50                   	push   %eax
  801e30:	ff 75 08             	pushl  0x8(%ebp)
  801e33:	e8 59 f5 ff ff       	call   801391 <fd_lookup>
  801e38:	83 c4 10             	add    $0x10,%esp
  801e3b:	85 c0                	test   %eax,%eax
  801e3d:	78 18                	js     801e57 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801e3f:	83 ec 0c             	sub    $0xc,%esp
  801e42:	ff 75 f4             	pushl  -0xc(%ebp)
  801e45:	e8 e1 f4 ff ff       	call   80132b <fd2data>
	return _pipeisclosed(fd, p);
  801e4a:	89 c2                	mov    %eax,%edx
  801e4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e4f:	e8 30 fd ff ff       	call   801b84 <_pipeisclosed>
  801e54:	83 c4 10             	add    $0x10,%esp
}
  801e57:	c9                   	leave  
  801e58:	c3                   	ret    

00801e59 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801e59:	55                   	push   %ebp
  801e5a:	89 e5                	mov    %esp,%ebp
  801e5c:	56                   	push   %esi
  801e5d:	53                   	push   %ebx
  801e5e:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801e61:	85 f6                	test   %esi,%esi
  801e63:	74 13                	je     801e78 <wait+0x1f>
	e = &envs[ENVX(envid)];
  801e65:	89 f3                	mov    %esi,%ebx
  801e67:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801e6d:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  801e70:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  801e76:	eb 1b                	jmp    801e93 <wait+0x3a>
	assert(envid != 0);
  801e78:	68 0e 2b 80 00       	push   $0x802b0e
  801e7d:	68 c3 2a 80 00       	push   $0x802ac3
  801e82:	6a 09                	push   $0x9
  801e84:	68 19 2b 80 00       	push   $0x802b19
  801e89:	e8 a8 e4 ff ff       	call   800336 <_panic>
		sys_yield();
  801e8e:	e8 77 ef ff ff       	call   800e0a <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801e93:	8b 43 48             	mov    0x48(%ebx),%eax
  801e96:	39 f0                	cmp    %esi,%eax
  801e98:	75 07                	jne    801ea1 <wait+0x48>
  801e9a:	8b 43 54             	mov    0x54(%ebx),%eax
  801e9d:	85 c0                	test   %eax,%eax
  801e9f:	75 ed                	jne    801e8e <wait+0x35>
}
  801ea1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ea4:	5b                   	pop    %ebx
  801ea5:	5e                   	pop    %esi
  801ea6:	5d                   	pop    %ebp
  801ea7:	c3                   	ret    

00801ea8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ea8:	55                   	push   %ebp
  801ea9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801eab:	b8 00 00 00 00       	mov    $0x0,%eax
  801eb0:	5d                   	pop    %ebp
  801eb1:	c3                   	ret    

00801eb2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801eb2:	55                   	push   %ebp
  801eb3:	89 e5                	mov    %esp,%ebp
  801eb5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801eb8:	68 24 2b 80 00       	push   $0x802b24
  801ebd:	ff 75 0c             	pushl  0xc(%ebp)
  801ec0:	e8 6b eb ff ff       	call   800a30 <strcpy>
	return 0;
}
  801ec5:	b8 00 00 00 00       	mov    $0x0,%eax
  801eca:	c9                   	leave  
  801ecb:	c3                   	ret    

00801ecc <devcons_write>:
{
  801ecc:	55                   	push   %ebp
  801ecd:	89 e5                	mov    %esp,%ebp
  801ecf:	57                   	push   %edi
  801ed0:	56                   	push   %esi
  801ed1:	53                   	push   %ebx
  801ed2:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801ed8:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801edd:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801ee3:	eb 2f                	jmp    801f14 <devcons_write+0x48>
		m = n - tot;
  801ee5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ee8:	29 f3                	sub    %esi,%ebx
  801eea:	83 fb 7f             	cmp    $0x7f,%ebx
  801eed:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801ef2:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801ef5:	83 ec 04             	sub    $0x4,%esp
  801ef8:	53                   	push   %ebx
  801ef9:	89 f0                	mov    %esi,%eax
  801efb:	03 45 0c             	add    0xc(%ebp),%eax
  801efe:	50                   	push   %eax
  801eff:	57                   	push   %edi
  801f00:	e8 b9 ec ff ff       	call   800bbe <memmove>
		sys_cputs(buf, m);
  801f05:	83 c4 08             	add    $0x8,%esp
  801f08:	53                   	push   %ebx
  801f09:	57                   	push   %edi
  801f0a:	e8 5e ee ff ff       	call   800d6d <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801f0f:	01 de                	add    %ebx,%esi
  801f11:	83 c4 10             	add    $0x10,%esp
  801f14:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f17:	72 cc                	jb     801ee5 <devcons_write+0x19>
}
  801f19:	89 f0                	mov    %esi,%eax
  801f1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f1e:	5b                   	pop    %ebx
  801f1f:	5e                   	pop    %esi
  801f20:	5f                   	pop    %edi
  801f21:	5d                   	pop    %ebp
  801f22:	c3                   	ret    

00801f23 <devcons_read>:
{
  801f23:	55                   	push   %ebp
  801f24:	89 e5                	mov    %esp,%ebp
  801f26:	83 ec 08             	sub    $0x8,%esp
  801f29:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801f2e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f32:	75 07                	jne    801f3b <devcons_read+0x18>
}
  801f34:	c9                   	leave  
  801f35:	c3                   	ret    
		sys_yield();
  801f36:	e8 cf ee ff ff       	call   800e0a <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801f3b:	e8 4b ee ff ff       	call   800d8b <sys_cgetc>
  801f40:	85 c0                	test   %eax,%eax
  801f42:	74 f2                	je     801f36 <devcons_read+0x13>
	if (c < 0)
  801f44:	85 c0                	test   %eax,%eax
  801f46:	78 ec                	js     801f34 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  801f48:	83 f8 04             	cmp    $0x4,%eax
  801f4b:	74 0c                	je     801f59 <devcons_read+0x36>
	*(char*)vbuf = c;
  801f4d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f50:	88 02                	mov    %al,(%edx)
	return 1;
  801f52:	b8 01 00 00 00       	mov    $0x1,%eax
  801f57:	eb db                	jmp    801f34 <devcons_read+0x11>
		return 0;
  801f59:	b8 00 00 00 00       	mov    $0x0,%eax
  801f5e:	eb d4                	jmp    801f34 <devcons_read+0x11>

00801f60 <cputchar>:
{
  801f60:	55                   	push   %ebp
  801f61:	89 e5                	mov    %esp,%ebp
  801f63:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f66:	8b 45 08             	mov    0x8(%ebp),%eax
  801f69:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801f6c:	6a 01                	push   $0x1
  801f6e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f71:	50                   	push   %eax
  801f72:	e8 f6 ed ff ff       	call   800d6d <sys_cputs>
}
  801f77:	83 c4 10             	add    $0x10,%esp
  801f7a:	c9                   	leave  
  801f7b:	c3                   	ret    

00801f7c <getchar>:
{
  801f7c:	55                   	push   %ebp
  801f7d:	89 e5                	mov    %esp,%ebp
  801f7f:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801f82:	6a 01                	push   $0x1
  801f84:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f87:	50                   	push   %eax
  801f88:	6a 00                	push   $0x0
  801f8a:	e8 73 f6 ff ff       	call   801602 <read>
	if (r < 0)
  801f8f:	83 c4 10             	add    $0x10,%esp
  801f92:	85 c0                	test   %eax,%eax
  801f94:	78 08                	js     801f9e <getchar+0x22>
	if (r < 1)
  801f96:	85 c0                	test   %eax,%eax
  801f98:	7e 06                	jle    801fa0 <getchar+0x24>
	return c;
  801f9a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801f9e:	c9                   	leave  
  801f9f:	c3                   	ret    
		return -E_EOF;
  801fa0:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801fa5:	eb f7                	jmp    801f9e <getchar+0x22>

00801fa7 <iscons>:
{
  801fa7:	55                   	push   %ebp
  801fa8:	89 e5                	mov    %esp,%ebp
  801faa:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fb0:	50                   	push   %eax
  801fb1:	ff 75 08             	pushl  0x8(%ebp)
  801fb4:	e8 d8 f3 ff ff       	call   801391 <fd_lookup>
  801fb9:	83 c4 10             	add    $0x10,%esp
  801fbc:	85 c0                	test   %eax,%eax
  801fbe:	78 11                	js     801fd1 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801fc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fc3:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801fc9:	39 10                	cmp    %edx,(%eax)
  801fcb:	0f 94 c0             	sete   %al
  801fce:	0f b6 c0             	movzbl %al,%eax
}
  801fd1:	c9                   	leave  
  801fd2:	c3                   	ret    

00801fd3 <opencons>:
{
  801fd3:	55                   	push   %ebp
  801fd4:	89 e5                	mov    %esp,%ebp
  801fd6:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801fd9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fdc:	50                   	push   %eax
  801fdd:	e8 60 f3 ff ff       	call   801342 <fd_alloc>
  801fe2:	83 c4 10             	add    $0x10,%esp
  801fe5:	85 c0                	test   %eax,%eax
  801fe7:	78 3a                	js     802023 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fe9:	83 ec 04             	sub    $0x4,%esp
  801fec:	68 07 04 00 00       	push   $0x407
  801ff1:	ff 75 f4             	pushl  -0xc(%ebp)
  801ff4:	6a 00                	push   $0x0
  801ff6:	e8 2e ee ff ff       	call   800e29 <sys_page_alloc>
  801ffb:	83 c4 10             	add    $0x10,%esp
  801ffe:	85 c0                	test   %eax,%eax
  802000:	78 21                	js     802023 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  802002:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802005:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80200b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80200d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802010:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802017:	83 ec 0c             	sub    $0xc,%esp
  80201a:	50                   	push   %eax
  80201b:	e8 fb f2 ff ff       	call   80131b <fd2num>
  802020:	83 c4 10             	add    $0x10,%esp
}
  802023:	c9                   	leave  
  802024:	c3                   	ret    

00802025 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802025:	55                   	push   %ebp
  802026:	89 e5                	mov    %esp,%ebp
  802028:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80202b:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802032:	74 0a                	je     80203e <set_pgfault_handler+0x19>
			panic("set_pgfault_handler %e",r);
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
	}
       
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802034:	8b 45 08             	mov    0x8(%ebp),%eax
  802037:	a3 00 60 80 00       	mov    %eax,0x806000
}
  80203c:	c9                   	leave  
  80203d:	c3                   	ret    
		if((r=sys_page_alloc(thisenv->env_id,(void *)UXSTACKTOP-PGSIZE,PTE_P|PTE_W|PTE_U))<0)
  80203e:	a1 04 40 80 00       	mov    0x804004,%eax
  802043:	8b 40 48             	mov    0x48(%eax),%eax
  802046:	83 ec 04             	sub    $0x4,%esp
  802049:	6a 07                	push   $0x7
  80204b:	68 00 f0 bf ee       	push   $0xeebff000
  802050:	50                   	push   %eax
  802051:	e8 d3 ed ff ff       	call   800e29 <sys_page_alloc>
  802056:	83 c4 10             	add    $0x10,%esp
  802059:	85 c0                	test   %eax,%eax
  80205b:	78 1b                	js     802078 <set_pgfault_handler+0x53>
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
  80205d:	a1 04 40 80 00       	mov    0x804004,%eax
  802062:	8b 40 48             	mov    0x48(%eax),%eax
  802065:	83 ec 08             	sub    $0x8,%esp
  802068:	68 8a 20 80 00       	push   $0x80208a
  80206d:	50                   	push   %eax
  80206e:	e8 01 ef ff ff       	call   800f74 <sys_env_set_pgfault_upcall>
  802073:	83 c4 10             	add    $0x10,%esp
  802076:	eb bc                	jmp    802034 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler %e",r);
  802078:	50                   	push   %eax
  802079:	68 30 2b 80 00       	push   $0x802b30
  80207e:	6a 22                	push   $0x22
  802080:	68 47 2b 80 00       	push   $0x802b47
  802085:	e8 ac e2 ff ff       	call   800336 <_panic>

0080208a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80208a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80208b:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802090:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802092:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 48(%esp), %ebp
  802095:	8b 6c 24 30          	mov    0x30(%esp),%ebp
        subl $4, %ebp
  802099:	83 ed 04             	sub    $0x4,%ebp
        movl %ebp, 48(%esp)
  80209c:	89 6c 24 30          	mov    %ebp,0x30(%esp)
        movl 40(%esp), %eax
  8020a0:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl %eax, (%ebp)
  8020a4:	89 45 00             	mov    %eax,0x0(%ebp)
	// Restore the trap-time registers.  After you do this, you
 	// can no longer modify any general-purpose registers.
 	// LAB 4: Your code here.
        addl $8, %esp
  8020a7:	83 c4 08             	add    $0x8,%esp
        popal
  8020aa:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $4, %esp
  8020ab:	83 c4 04             	add    $0x4,%esp
        popfl
  8020ae:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  8020af:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  8020b0:	c3                   	ret    

008020b1 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020b1:	55                   	push   %ebp
  8020b2:	89 e5                	mov    %esp,%ebp
  8020b4:	56                   	push   %esi
  8020b5:	53                   	push   %ebx
  8020b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8020b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        //	panic("ipc_recv not implemented");
        int r;
       	if(pg!=NULL){
  8020bf:	85 c0                	test   %eax,%eax
  8020c1:	74 3b                	je     8020fe <ipc_recv+0x4d>
	  r = sys_ipc_recv(pg);
  8020c3:	83 ec 0c             	sub    $0xc,%esp
  8020c6:	50                   	push   %eax
  8020c7:	e8 0d ef ff ff       	call   800fd9 <sys_ipc_recv>
  8020cc:	83 c4 10             	add    $0x10,%esp
	}else
	  r = sys_ipc_recv((void *)UTOP);
	if(r<0){
  8020cf:	85 c0                	test   %eax,%eax
  8020d1:	78 3d                	js     802110 <ipc_recv+0x5f>
	if(perm_store!=NULL){
		*perm_store = 0;
            }
        	return r;
           }else{
	     if(from_env_store!=NULL)
  8020d3:	85 f6                	test   %esi,%esi
  8020d5:	74 0a                	je     8020e1 <ipc_recv+0x30>
		     *from_env_store = thisenv->env_ipc_from;
  8020d7:	a1 04 40 80 00       	mov    0x804004,%eax
  8020dc:	8b 40 74             	mov    0x74(%eax),%eax
  8020df:	89 06                	mov    %eax,(%esi)
	     if(perm_store != NULL)
  8020e1:	85 db                	test   %ebx,%ebx
  8020e3:	74 0a                	je     8020ef <ipc_recv+0x3e>
		     *perm_store = thisenv->env_ipc_perm;
  8020e5:	a1 04 40 80 00       	mov    0x804004,%eax
  8020ea:	8b 40 78             	mov    0x78(%eax),%eax
  8020ed:	89 03                	mov    %eax,(%ebx)
	     return thisenv->env_ipc_value;
  8020ef:	a1 04 40 80 00       	mov    0x804004,%eax
  8020f4:	8b 40 70             	mov    0x70(%eax),%eax
	   }

}
  8020f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020fa:	5b                   	pop    %ebx
  8020fb:	5e                   	pop    %esi
  8020fc:	5d                   	pop    %ebp
  8020fd:	c3                   	ret    
	  r = sys_ipc_recv((void *)UTOP);
  8020fe:	83 ec 0c             	sub    $0xc,%esp
  802101:	68 00 00 c0 ee       	push   $0xeec00000
  802106:	e8 ce ee ff ff       	call   800fd9 <sys_ipc_recv>
  80210b:	83 c4 10             	add    $0x10,%esp
  80210e:	eb bf                	jmp    8020cf <ipc_recv+0x1e>
	if(from_env_store!=NULL){
  802110:	85 f6                	test   %esi,%esi
  802112:	74 06                	je     80211a <ipc_recv+0x69>
	  *from_env_store = 0;
  802114:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if(perm_store!=NULL){
  80211a:	85 db                	test   %ebx,%ebx
  80211c:	74 d9                	je     8020f7 <ipc_recv+0x46>
		*perm_store = 0;
  80211e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802124:	eb d1                	jmp    8020f7 <ipc_recv+0x46>

00802126 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802126:	55                   	push   %ebp
  802127:	89 e5                	mov    %esp,%ebp
  802129:	57                   	push   %edi
  80212a:	56                   	push   %esi
  80212b:	53                   	push   %ebx
  80212c:	83 ec 0c             	sub    $0xc,%esp
  80212f:	8b 7d 08             	mov    0x8(%ebp),%edi
  802132:	8b 75 0c             	mov    0xc(%ebp),%esi
  802135:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if(pg==NULL) pg = (void *)UTOP;
  802138:	85 db                	test   %ebx,%ebx
  80213a:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80213f:	0f 44 d8             	cmove  %eax,%ebx
	while((r=sys_ipc_try_send(to_env,val,pg,perm))<0){
  802142:	ff 75 14             	pushl  0x14(%ebp)
  802145:	53                   	push   %ebx
  802146:	56                   	push   %esi
  802147:	57                   	push   %edi
  802148:	e8 69 ee ff ff       	call   800fb6 <sys_ipc_try_send>
  80214d:	83 c4 10             	add    $0x10,%esp
  802150:	85 c0                	test   %eax,%eax
  802152:	79 20                	jns    802174 <ipc_send+0x4e>
	    if(r!=-E_IPC_NOT_RECV){
  802154:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802157:	75 07                	jne    802160 <ipc_send+0x3a>
		    panic("ipc_send:send message failed\n");
	    }
	    sys_yield();
  802159:	e8 ac ec ff ff       	call   800e0a <sys_yield>
  80215e:	eb e2                	jmp    802142 <ipc_send+0x1c>
		    panic("ipc_send:send message failed\n");
  802160:	83 ec 04             	sub    $0x4,%esp
  802163:	68 55 2b 80 00       	push   $0x802b55
  802168:	6a 43                	push   $0x43
  80216a:	68 73 2b 80 00       	push   $0x802b73
  80216f:	e8 c2 e1 ff ff       	call   800336 <_panic>
	}

}
  802174:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802177:	5b                   	pop    %ebx
  802178:	5e                   	pop    %esi
  802179:	5f                   	pop    %edi
  80217a:	5d                   	pop    %ebp
  80217b:	c3                   	ret    

0080217c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80217c:	55                   	push   %ebp
  80217d:	89 e5                	mov    %esp,%ebp
  80217f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802182:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802187:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80218a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802190:	8b 52 50             	mov    0x50(%edx),%edx
  802193:	39 ca                	cmp    %ecx,%edx
  802195:	74 11                	je     8021a8 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  802197:	83 c0 01             	add    $0x1,%eax
  80219a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80219f:	75 e6                	jne    802187 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8021a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8021a6:	eb 0b                	jmp    8021b3 <ipc_find_env+0x37>
			return envs[i].env_id;
  8021a8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8021ab:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8021b0:	8b 40 48             	mov    0x48(%eax),%eax
}
  8021b3:	5d                   	pop    %ebp
  8021b4:	c3                   	ret    

008021b5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021b5:	55                   	push   %ebp
  8021b6:	89 e5                	mov    %esp,%ebp
  8021b8:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021bb:	89 d0                	mov    %edx,%eax
  8021bd:	c1 e8 16             	shr    $0x16,%eax
  8021c0:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021c7:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  8021cc:	f6 c1 01             	test   $0x1,%cl
  8021cf:	74 1d                	je     8021ee <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  8021d1:	c1 ea 0c             	shr    $0xc,%edx
  8021d4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8021db:	f6 c2 01             	test   $0x1,%dl
  8021de:	74 0e                	je     8021ee <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021e0:	c1 ea 0c             	shr    $0xc,%edx
  8021e3:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021ea:	ef 
  8021eb:	0f b7 c0             	movzwl %ax,%eax
}
  8021ee:	5d                   	pop    %ebp
  8021ef:	c3                   	ret    

008021f0 <__udivdi3>:
  8021f0:	55                   	push   %ebp
  8021f1:	57                   	push   %edi
  8021f2:	56                   	push   %esi
  8021f3:	53                   	push   %ebx
  8021f4:	83 ec 1c             	sub    $0x1c,%esp
  8021f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021fb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8021ff:	8b 74 24 34          	mov    0x34(%esp),%esi
  802203:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  802207:	85 d2                	test   %edx,%edx
  802209:	75 35                	jne    802240 <__udivdi3+0x50>
  80220b:	39 f3                	cmp    %esi,%ebx
  80220d:	0f 87 bd 00 00 00    	ja     8022d0 <__udivdi3+0xe0>
  802213:	85 db                	test   %ebx,%ebx
  802215:	89 d9                	mov    %ebx,%ecx
  802217:	75 0b                	jne    802224 <__udivdi3+0x34>
  802219:	b8 01 00 00 00       	mov    $0x1,%eax
  80221e:	31 d2                	xor    %edx,%edx
  802220:	f7 f3                	div    %ebx
  802222:	89 c1                	mov    %eax,%ecx
  802224:	31 d2                	xor    %edx,%edx
  802226:	89 f0                	mov    %esi,%eax
  802228:	f7 f1                	div    %ecx
  80222a:	89 c6                	mov    %eax,%esi
  80222c:	89 e8                	mov    %ebp,%eax
  80222e:	89 f7                	mov    %esi,%edi
  802230:	f7 f1                	div    %ecx
  802232:	89 fa                	mov    %edi,%edx
  802234:	83 c4 1c             	add    $0x1c,%esp
  802237:	5b                   	pop    %ebx
  802238:	5e                   	pop    %esi
  802239:	5f                   	pop    %edi
  80223a:	5d                   	pop    %ebp
  80223b:	c3                   	ret    
  80223c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802240:	39 f2                	cmp    %esi,%edx
  802242:	77 7c                	ja     8022c0 <__udivdi3+0xd0>
  802244:	0f bd fa             	bsr    %edx,%edi
  802247:	83 f7 1f             	xor    $0x1f,%edi
  80224a:	0f 84 98 00 00 00    	je     8022e8 <__udivdi3+0xf8>
  802250:	89 f9                	mov    %edi,%ecx
  802252:	b8 20 00 00 00       	mov    $0x20,%eax
  802257:	29 f8                	sub    %edi,%eax
  802259:	d3 e2                	shl    %cl,%edx
  80225b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80225f:	89 c1                	mov    %eax,%ecx
  802261:	89 da                	mov    %ebx,%edx
  802263:	d3 ea                	shr    %cl,%edx
  802265:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802269:	09 d1                	or     %edx,%ecx
  80226b:	89 f2                	mov    %esi,%edx
  80226d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802271:	89 f9                	mov    %edi,%ecx
  802273:	d3 e3                	shl    %cl,%ebx
  802275:	89 c1                	mov    %eax,%ecx
  802277:	d3 ea                	shr    %cl,%edx
  802279:	89 f9                	mov    %edi,%ecx
  80227b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80227f:	d3 e6                	shl    %cl,%esi
  802281:	89 eb                	mov    %ebp,%ebx
  802283:	89 c1                	mov    %eax,%ecx
  802285:	d3 eb                	shr    %cl,%ebx
  802287:	09 de                	or     %ebx,%esi
  802289:	89 f0                	mov    %esi,%eax
  80228b:	f7 74 24 08          	divl   0x8(%esp)
  80228f:	89 d6                	mov    %edx,%esi
  802291:	89 c3                	mov    %eax,%ebx
  802293:	f7 64 24 0c          	mull   0xc(%esp)
  802297:	39 d6                	cmp    %edx,%esi
  802299:	72 0c                	jb     8022a7 <__udivdi3+0xb7>
  80229b:	89 f9                	mov    %edi,%ecx
  80229d:	d3 e5                	shl    %cl,%ebp
  80229f:	39 c5                	cmp    %eax,%ebp
  8022a1:	73 5d                	jae    802300 <__udivdi3+0x110>
  8022a3:	39 d6                	cmp    %edx,%esi
  8022a5:	75 59                	jne    802300 <__udivdi3+0x110>
  8022a7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8022aa:	31 ff                	xor    %edi,%edi
  8022ac:	89 fa                	mov    %edi,%edx
  8022ae:	83 c4 1c             	add    $0x1c,%esp
  8022b1:	5b                   	pop    %ebx
  8022b2:	5e                   	pop    %esi
  8022b3:	5f                   	pop    %edi
  8022b4:	5d                   	pop    %ebp
  8022b5:	c3                   	ret    
  8022b6:	8d 76 00             	lea    0x0(%esi),%esi
  8022b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8022c0:	31 ff                	xor    %edi,%edi
  8022c2:	31 c0                	xor    %eax,%eax
  8022c4:	89 fa                	mov    %edi,%edx
  8022c6:	83 c4 1c             	add    $0x1c,%esp
  8022c9:	5b                   	pop    %ebx
  8022ca:	5e                   	pop    %esi
  8022cb:	5f                   	pop    %edi
  8022cc:	5d                   	pop    %ebp
  8022cd:	c3                   	ret    
  8022ce:	66 90                	xchg   %ax,%ax
  8022d0:	31 ff                	xor    %edi,%edi
  8022d2:	89 e8                	mov    %ebp,%eax
  8022d4:	89 f2                	mov    %esi,%edx
  8022d6:	f7 f3                	div    %ebx
  8022d8:	89 fa                	mov    %edi,%edx
  8022da:	83 c4 1c             	add    $0x1c,%esp
  8022dd:	5b                   	pop    %ebx
  8022de:	5e                   	pop    %esi
  8022df:	5f                   	pop    %edi
  8022e0:	5d                   	pop    %ebp
  8022e1:	c3                   	ret    
  8022e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022e8:	39 f2                	cmp    %esi,%edx
  8022ea:	72 06                	jb     8022f2 <__udivdi3+0x102>
  8022ec:	31 c0                	xor    %eax,%eax
  8022ee:	39 eb                	cmp    %ebp,%ebx
  8022f0:	77 d2                	ja     8022c4 <__udivdi3+0xd4>
  8022f2:	b8 01 00 00 00       	mov    $0x1,%eax
  8022f7:	eb cb                	jmp    8022c4 <__udivdi3+0xd4>
  8022f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802300:	89 d8                	mov    %ebx,%eax
  802302:	31 ff                	xor    %edi,%edi
  802304:	eb be                	jmp    8022c4 <__udivdi3+0xd4>
  802306:	66 90                	xchg   %ax,%ax
  802308:	66 90                	xchg   %ax,%ax
  80230a:	66 90                	xchg   %ax,%ax
  80230c:	66 90                	xchg   %ax,%ax
  80230e:	66 90                	xchg   %ax,%ax

00802310 <__umoddi3>:
  802310:	55                   	push   %ebp
  802311:	57                   	push   %edi
  802312:	56                   	push   %esi
  802313:	53                   	push   %ebx
  802314:	83 ec 1c             	sub    $0x1c,%esp
  802317:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80231b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80231f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802323:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802327:	85 ed                	test   %ebp,%ebp
  802329:	89 f0                	mov    %esi,%eax
  80232b:	89 da                	mov    %ebx,%edx
  80232d:	75 19                	jne    802348 <__umoddi3+0x38>
  80232f:	39 df                	cmp    %ebx,%edi
  802331:	0f 86 b1 00 00 00    	jbe    8023e8 <__umoddi3+0xd8>
  802337:	f7 f7                	div    %edi
  802339:	89 d0                	mov    %edx,%eax
  80233b:	31 d2                	xor    %edx,%edx
  80233d:	83 c4 1c             	add    $0x1c,%esp
  802340:	5b                   	pop    %ebx
  802341:	5e                   	pop    %esi
  802342:	5f                   	pop    %edi
  802343:	5d                   	pop    %ebp
  802344:	c3                   	ret    
  802345:	8d 76 00             	lea    0x0(%esi),%esi
  802348:	39 dd                	cmp    %ebx,%ebp
  80234a:	77 f1                	ja     80233d <__umoddi3+0x2d>
  80234c:	0f bd cd             	bsr    %ebp,%ecx
  80234f:	83 f1 1f             	xor    $0x1f,%ecx
  802352:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802356:	0f 84 b4 00 00 00    	je     802410 <__umoddi3+0x100>
  80235c:	b8 20 00 00 00       	mov    $0x20,%eax
  802361:	89 c2                	mov    %eax,%edx
  802363:	8b 44 24 04          	mov    0x4(%esp),%eax
  802367:	29 c2                	sub    %eax,%edx
  802369:	89 c1                	mov    %eax,%ecx
  80236b:	89 f8                	mov    %edi,%eax
  80236d:	d3 e5                	shl    %cl,%ebp
  80236f:	89 d1                	mov    %edx,%ecx
  802371:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802375:	d3 e8                	shr    %cl,%eax
  802377:	09 c5                	or     %eax,%ebp
  802379:	8b 44 24 04          	mov    0x4(%esp),%eax
  80237d:	89 c1                	mov    %eax,%ecx
  80237f:	d3 e7                	shl    %cl,%edi
  802381:	89 d1                	mov    %edx,%ecx
  802383:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802387:	89 df                	mov    %ebx,%edi
  802389:	d3 ef                	shr    %cl,%edi
  80238b:	89 c1                	mov    %eax,%ecx
  80238d:	89 f0                	mov    %esi,%eax
  80238f:	d3 e3                	shl    %cl,%ebx
  802391:	89 d1                	mov    %edx,%ecx
  802393:	89 fa                	mov    %edi,%edx
  802395:	d3 e8                	shr    %cl,%eax
  802397:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80239c:	09 d8                	or     %ebx,%eax
  80239e:	f7 f5                	div    %ebp
  8023a0:	d3 e6                	shl    %cl,%esi
  8023a2:	89 d1                	mov    %edx,%ecx
  8023a4:	f7 64 24 08          	mull   0x8(%esp)
  8023a8:	39 d1                	cmp    %edx,%ecx
  8023aa:	89 c3                	mov    %eax,%ebx
  8023ac:	89 d7                	mov    %edx,%edi
  8023ae:	72 06                	jb     8023b6 <__umoddi3+0xa6>
  8023b0:	75 0e                	jne    8023c0 <__umoddi3+0xb0>
  8023b2:	39 c6                	cmp    %eax,%esi
  8023b4:	73 0a                	jae    8023c0 <__umoddi3+0xb0>
  8023b6:	2b 44 24 08          	sub    0x8(%esp),%eax
  8023ba:	19 ea                	sbb    %ebp,%edx
  8023bc:	89 d7                	mov    %edx,%edi
  8023be:	89 c3                	mov    %eax,%ebx
  8023c0:	89 ca                	mov    %ecx,%edx
  8023c2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8023c7:	29 de                	sub    %ebx,%esi
  8023c9:	19 fa                	sbb    %edi,%edx
  8023cb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  8023cf:	89 d0                	mov    %edx,%eax
  8023d1:	d3 e0                	shl    %cl,%eax
  8023d3:	89 d9                	mov    %ebx,%ecx
  8023d5:	d3 ee                	shr    %cl,%esi
  8023d7:	d3 ea                	shr    %cl,%edx
  8023d9:	09 f0                	or     %esi,%eax
  8023db:	83 c4 1c             	add    $0x1c,%esp
  8023de:	5b                   	pop    %ebx
  8023df:	5e                   	pop    %esi
  8023e0:	5f                   	pop    %edi
  8023e1:	5d                   	pop    %ebp
  8023e2:	c3                   	ret    
  8023e3:	90                   	nop
  8023e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023e8:	85 ff                	test   %edi,%edi
  8023ea:	89 f9                	mov    %edi,%ecx
  8023ec:	75 0b                	jne    8023f9 <__umoddi3+0xe9>
  8023ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8023f3:	31 d2                	xor    %edx,%edx
  8023f5:	f7 f7                	div    %edi
  8023f7:	89 c1                	mov    %eax,%ecx
  8023f9:	89 d8                	mov    %ebx,%eax
  8023fb:	31 d2                	xor    %edx,%edx
  8023fd:	f7 f1                	div    %ecx
  8023ff:	89 f0                	mov    %esi,%eax
  802401:	f7 f1                	div    %ecx
  802403:	e9 31 ff ff ff       	jmp    802339 <__umoddi3+0x29>
  802408:	90                   	nop
  802409:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802410:	39 dd                	cmp    %ebx,%ebp
  802412:	72 08                	jb     80241c <__umoddi3+0x10c>
  802414:	39 f7                	cmp    %esi,%edi
  802416:	0f 87 21 ff ff ff    	ja     80233d <__umoddi3+0x2d>
  80241c:	89 da                	mov    %ebx,%edx
  80241e:	89 f0                	mov    %esi,%eax
  802420:	29 f8                	sub    %edi,%eax
  802422:	19 ea                	sbb    %ebp,%edx
  802424:	e9 14 ff ff ff       	jmp    80233d <__umoddi3+0x2d>
