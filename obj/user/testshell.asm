
obj/user/testshell.debug:     file format elf32-i386


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
  80002c:	e8 5f 04 00 00       	call   800490 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <wrong>:
	breakpoint();
}

void
wrong(int rfd, int kfd, int off)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	81 ec 84 00 00 00    	sub    $0x84,%esp
  80003f:	8b 75 08             	mov    0x8(%ebp),%esi
  800042:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800045:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char buf[100];
	int n;

	seek(rfd, off);
  800048:	53                   	push   %ebx
  800049:	56                   	push   %esi
  80004a:	e8 bd 18 00 00       	call   80190c <seek>
	seek(kfd, off);
  80004f:	83 c4 08             	add    $0x8,%esp
  800052:	53                   	push   %ebx
  800053:	57                   	push   %edi
  800054:	e8 b3 18 00 00       	call   80190c <seek>

	cprintf("shell produced incorrect output.\n");
  800059:	c7 04 24 80 2a 80 00 	movl   $0x802a80,(%esp)
  800060:	e8 66 05 00 00       	call   8005cb <cprintf>
	cprintf("expected:\n===\n");
  800065:	c7 04 24 eb 2a 80 00 	movl   $0x802aeb,(%esp)
  80006c:	e8 5a 05 00 00       	call   8005cb <cprintf>
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800071:	83 c4 10             	add    $0x10,%esp
  800074:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  800077:	eb 0d                	jmp    800086 <wrong+0x53>
		sys_cputs(buf, n);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	e8 a4 0e 00 00       	call   800f27 <sys_cputs>
  800083:	83 c4 10             	add    $0x10,%esp
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800086:	83 ec 04             	sub    $0x4,%esp
  800089:	6a 63                	push   $0x63
  80008b:	53                   	push   %ebx
  80008c:	57                   	push   %edi
  80008d:	e8 2a 17 00 00       	call   8017bc <read>
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	85 c0                	test   %eax,%eax
  800097:	7f e0                	jg     800079 <wrong+0x46>
	cprintf("===\ngot:\n===\n");
  800099:	83 ec 0c             	sub    $0xc,%esp
  80009c:	68 fa 2a 80 00       	push   $0x802afa
  8000a1:	e8 25 05 00 00       	call   8005cb <cprintf>
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  8000ac:	eb 0d                	jmp    8000bb <wrong+0x88>
		sys_cputs(buf, n);
  8000ae:	83 ec 08             	sub    $0x8,%esp
  8000b1:	50                   	push   %eax
  8000b2:	53                   	push   %ebx
  8000b3:	e8 6f 0e 00 00       	call   800f27 <sys_cputs>
  8000b8:	83 c4 10             	add    $0x10,%esp
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000bb:	83 ec 04             	sub    $0x4,%esp
  8000be:	6a 63                	push   $0x63
  8000c0:	53                   	push   %ebx
  8000c1:	56                   	push   %esi
  8000c2:	e8 f5 16 00 00       	call   8017bc <read>
  8000c7:	83 c4 10             	add    $0x10,%esp
  8000ca:	85 c0                	test   %eax,%eax
  8000cc:	7f e0                	jg     8000ae <wrong+0x7b>
	cprintf("===\n");
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	68 f5 2a 80 00       	push   $0x802af5
  8000d6:	e8 f0 04 00 00       	call   8005cb <cprintf>
	exit();
  8000db:	e8 f6 03 00 00       	call   8004d6 <exit>
}
  8000e0:	83 c4 10             	add    $0x10,%esp
  8000e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <umain>:
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 38             	sub    $0x38,%esp
	close(0);
  8000f4:	6a 00                	push   $0x0
  8000f6:	e8 85 15 00 00       	call   801680 <close>
	close(1);
  8000fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800102:	e8 79 15 00 00       	call   801680 <close>
	opencons();
  800107:	e8 32 03 00 00       	call   80043e <opencons>
	opencons();
  80010c:	e8 2d 03 00 00       	call   80043e <opencons>
	if ((rfd = open("testshell.sh", O_RDONLY)) < 0)
  800111:	83 c4 08             	add    $0x8,%esp
  800114:	6a 00                	push   $0x0
  800116:	68 08 2b 80 00       	push   $0x802b08
  80011b:	e8 01 1b 00 00       	call   801c21 <open>
  800120:	89 c3                	mov    %eax,%ebx
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	0f 88 e9 00 00 00    	js     800216 <umain+0x12b>
	if ((wfd = pipe(pfds)) < 0)
  80012d:	83 ec 0c             	sub    $0xc,%esp
  800130:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800133:	50                   	push   %eax
  800134:	e8 61 23 00 00       	call   80249a <pipe>
  800139:	83 c4 10             	add    $0x10,%esp
  80013c:	85 c0                	test   %eax,%eax
  80013e:	0f 88 e4 00 00 00    	js     800228 <umain+0x13d>
	wfd = pfds[1];
  800144:	8b 75 e0             	mov    -0x20(%ebp),%esi
	cprintf("running sh -x < testshell.sh | cat\n");
  800147:	83 ec 0c             	sub    $0xc,%esp
  80014a:	68 a4 2a 80 00       	push   $0x802aa4
  80014f:	e8 77 04 00 00       	call   8005cb <cprintf>
	if ((r = fork()) < 0)
  800154:	e8 6f 11 00 00       	call   8012c8 <fork>
  800159:	83 c4 10             	add    $0x10,%esp
  80015c:	85 c0                	test   %eax,%eax
  80015e:	0f 88 d6 00 00 00    	js     80023a <umain+0x14f>
	if (r == 0) {
  800164:	85 c0                	test   %eax,%eax
  800166:	75 6f                	jne    8001d7 <umain+0xec>
		dup(rfd, 0);
  800168:	83 ec 08             	sub    $0x8,%esp
  80016b:	6a 00                	push   $0x0
  80016d:	53                   	push   %ebx
  80016e:	e8 5d 15 00 00       	call   8016d0 <dup>
		dup(wfd, 1);
  800173:	83 c4 08             	add    $0x8,%esp
  800176:	6a 01                	push   $0x1
  800178:	56                   	push   %esi
  800179:	e8 52 15 00 00       	call   8016d0 <dup>
		close(rfd);
  80017e:	89 1c 24             	mov    %ebx,(%esp)
  800181:	e8 fa 14 00 00       	call   801680 <close>
		close(wfd);
  800186:	89 34 24             	mov    %esi,(%esp)
  800189:	e8 f2 14 00 00       	call   801680 <close>
		if ((r = spawnl("/sh", "sh", "-x", 0)) < 0)
  80018e:	6a 00                	push   $0x0
  800190:	68 4e 2b 80 00       	push   $0x802b4e
  800195:	68 12 2b 80 00       	push   $0x802b12
  80019a:	68 51 2b 80 00       	push   $0x802b51
  80019f:	e8 a8 20 00 00       	call   80224c <spawnl>
  8001a4:	89 c7                	mov    %eax,%edi
  8001a6:	83 c4 20             	add    $0x20,%esp
  8001a9:	85 c0                	test   %eax,%eax
  8001ab:	0f 88 9b 00 00 00    	js     80024c <umain+0x161>
		close(0);
  8001b1:	83 ec 0c             	sub    $0xc,%esp
  8001b4:	6a 00                	push   $0x0
  8001b6:	e8 c5 14 00 00       	call   801680 <close>
		close(1);
  8001bb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001c2:	e8 b9 14 00 00       	call   801680 <close>
		wait(r);
  8001c7:	89 3c 24             	mov    %edi,(%esp)
  8001ca:	e8 47 24 00 00       	call   802616 <wait>
		exit();
  8001cf:	e8 02 03 00 00       	call   8004d6 <exit>
  8001d4:	83 c4 10             	add    $0x10,%esp
	close(rfd);
  8001d7:	83 ec 0c             	sub    $0xc,%esp
  8001da:	53                   	push   %ebx
  8001db:	e8 a0 14 00 00       	call   801680 <close>
	close(wfd);
  8001e0:	89 34 24             	mov    %esi,(%esp)
  8001e3:	e8 98 14 00 00       	call   801680 <close>
	rfd = pfds[0];
  8001e8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001eb:	89 45 d0             	mov    %eax,-0x30(%ebp)
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  8001ee:	83 c4 08             	add    $0x8,%esp
  8001f1:	6a 00                	push   $0x0
  8001f3:	68 5f 2b 80 00       	push   $0x802b5f
  8001f8:	e8 24 1a 00 00       	call   801c21 <open>
  8001fd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800200:	83 c4 10             	add    $0x10,%esp
  800203:	85 c0                	test   %eax,%eax
  800205:	78 57                	js     80025e <umain+0x173>
  800207:	be 01 00 00 00       	mov    $0x1,%esi
	nloff = 0;
  80020c:	bf 00 00 00 00       	mov    $0x0,%edi
  800211:	e9 9a 00 00 00       	jmp    8002b0 <umain+0x1c5>
		panic("open testshell.sh: %e", rfd);
  800216:	50                   	push   %eax
  800217:	68 15 2b 80 00       	push   $0x802b15
  80021c:	6a 13                	push   $0x13
  80021e:	68 2b 2b 80 00       	push   $0x802b2b
  800223:	e8 c8 02 00 00       	call   8004f0 <_panic>
		panic("pipe: %e", wfd);
  800228:	50                   	push   %eax
  800229:	68 3c 2b 80 00       	push   $0x802b3c
  80022e:	6a 15                	push   $0x15
  800230:	68 2b 2b 80 00       	push   $0x802b2b
  800235:	e8 b6 02 00 00       	call   8004f0 <_panic>
		panic("fork: %e", r);
  80023a:	50                   	push   %eax
  80023b:	68 45 2b 80 00       	push   $0x802b45
  800240:	6a 1a                	push   $0x1a
  800242:	68 2b 2b 80 00       	push   $0x802b2b
  800247:	e8 a4 02 00 00       	call   8004f0 <_panic>
			panic("spawn: %e", r);
  80024c:	50                   	push   %eax
  80024d:	68 55 2b 80 00       	push   $0x802b55
  800252:	6a 21                	push   $0x21
  800254:	68 2b 2b 80 00       	push   $0x802b2b
  800259:	e8 92 02 00 00       	call   8004f0 <_panic>
		panic("open testshell.key for reading: %e", kfd);
  80025e:	50                   	push   %eax
  80025f:	68 c8 2a 80 00       	push   $0x802ac8
  800264:	6a 2c                	push   $0x2c
  800266:	68 2b 2b 80 00       	push   $0x802b2b
  80026b:	e8 80 02 00 00       	call   8004f0 <_panic>
			panic("reading testshell.out: %e", n1);
  800270:	53                   	push   %ebx
  800271:	68 6d 2b 80 00       	push   $0x802b6d
  800276:	6a 33                	push   $0x33
  800278:	68 2b 2b 80 00       	push   $0x802b2b
  80027d:	e8 6e 02 00 00       	call   8004f0 <_panic>
			panic("reading testshell.key: %e", n2);
  800282:	50                   	push   %eax
  800283:	68 87 2b 80 00       	push   $0x802b87
  800288:	6a 35                	push   $0x35
  80028a:	68 2b 2b 80 00       	push   $0x802b2b
  80028f:	e8 5c 02 00 00       	call   8004f0 <_panic>
			wrong(rfd, kfd, nloff);
  800294:	83 ec 04             	sub    $0x4,%esp
  800297:	57                   	push   %edi
  800298:	ff 75 d4             	pushl  -0x2c(%ebp)
  80029b:	ff 75 d0             	pushl  -0x30(%ebp)
  80029e:	e8 90 fd ff ff       	call   800033 <wrong>
  8002a3:	83 c4 10             	add    $0x10,%esp
			nloff = off+1;
  8002a6:	80 7d e7 0a          	cmpb   $0xa,-0x19(%ebp)
  8002aa:	0f 44 fe             	cmove  %esi,%edi
  8002ad:	83 c6 01             	add    $0x1,%esi
		n1 = read(rfd, &c1, 1);
  8002b0:	83 ec 04             	sub    $0x4,%esp
  8002b3:	6a 01                	push   $0x1
  8002b5:	8d 45 e7             	lea    -0x19(%ebp),%eax
  8002b8:	50                   	push   %eax
  8002b9:	ff 75 d0             	pushl  -0x30(%ebp)
  8002bc:	e8 fb 14 00 00       	call   8017bc <read>
  8002c1:	89 c3                	mov    %eax,%ebx
		n2 = read(kfd, &c2, 1);
  8002c3:	83 c4 0c             	add    $0xc,%esp
  8002c6:	6a 01                	push   $0x1
  8002c8:	8d 45 e6             	lea    -0x1a(%ebp),%eax
  8002cb:	50                   	push   %eax
  8002cc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002cf:	e8 e8 14 00 00       	call   8017bc <read>
		if (n1 < 0)
  8002d4:	83 c4 10             	add    $0x10,%esp
  8002d7:	85 db                	test   %ebx,%ebx
  8002d9:	78 95                	js     800270 <umain+0x185>
		if (n2 < 0)
  8002db:	85 c0                	test   %eax,%eax
  8002dd:	78 a3                	js     800282 <umain+0x197>
		if (n1 == 0 && n2 == 0)
  8002df:	89 da                	mov    %ebx,%edx
  8002e1:	09 c2                	or     %eax,%edx
  8002e3:	74 15                	je     8002fa <umain+0x20f>
		if (n1 != 1 || n2 != 1 || c1 != c2)
  8002e5:	83 fb 01             	cmp    $0x1,%ebx
  8002e8:	75 aa                	jne    800294 <umain+0x1a9>
  8002ea:	83 f8 01             	cmp    $0x1,%eax
  8002ed:	75 a5                	jne    800294 <umain+0x1a9>
  8002ef:	0f b6 45 e6          	movzbl -0x1a(%ebp),%eax
  8002f3:	38 45 e7             	cmp    %al,-0x19(%ebp)
  8002f6:	75 9c                	jne    800294 <umain+0x1a9>
  8002f8:	eb ac                	jmp    8002a6 <umain+0x1bb>
	cprintf("shell ran correctly\n");
  8002fa:	83 ec 0c             	sub    $0xc,%esp
  8002fd:	68 a1 2b 80 00       	push   $0x802ba1
  800302:	e8 c4 02 00 00       	call   8005cb <cprintf>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  800307:	cc                   	int3   
}
  800308:	83 c4 10             	add    $0x10,%esp
  80030b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80030e:	5b                   	pop    %ebx
  80030f:	5e                   	pop    %esi
  800310:	5f                   	pop    %edi
  800311:	5d                   	pop    %ebp
  800312:	c3                   	ret    

00800313 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800316:	b8 00 00 00 00       	mov    $0x0,%eax
  80031b:	5d                   	pop    %ebp
  80031c:	c3                   	ret    

0080031d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80031d:	55                   	push   %ebp
  80031e:	89 e5                	mov    %esp,%ebp
  800320:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800323:	68 b6 2b 80 00       	push   $0x802bb6
  800328:	ff 75 0c             	pushl  0xc(%ebp)
  80032b:	e8 ba 08 00 00       	call   800bea <strcpy>
	return 0;
}
  800330:	b8 00 00 00 00       	mov    $0x0,%eax
  800335:	c9                   	leave  
  800336:	c3                   	ret    

00800337 <devcons_write>:
{
  800337:	55                   	push   %ebp
  800338:	89 e5                	mov    %esp,%ebp
  80033a:	57                   	push   %edi
  80033b:	56                   	push   %esi
  80033c:	53                   	push   %ebx
  80033d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800343:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800348:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  80034e:	eb 2f                	jmp    80037f <devcons_write+0x48>
		m = n - tot;
  800350:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800353:	29 f3                	sub    %esi,%ebx
  800355:	83 fb 7f             	cmp    $0x7f,%ebx
  800358:	b8 7f 00 00 00       	mov    $0x7f,%eax
  80035d:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800360:	83 ec 04             	sub    $0x4,%esp
  800363:	53                   	push   %ebx
  800364:	89 f0                	mov    %esi,%eax
  800366:	03 45 0c             	add    0xc(%ebp),%eax
  800369:	50                   	push   %eax
  80036a:	57                   	push   %edi
  80036b:	e8 08 0a 00 00       	call   800d78 <memmove>
		sys_cputs(buf, m);
  800370:	83 c4 08             	add    $0x8,%esp
  800373:	53                   	push   %ebx
  800374:	57                   	push   %edi
  800375:	e8 ad 0b 00 00       	call   800f27 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  80037a:	01 de                	add    %ebx,%esi
  80037c:	83 c4 10             	add    $0x10,%esp
  80037f:	3b 75 10             	cmp    0x10(%ebp),%esi
  800382:	72 cc                	jb     800350 <devcons_write+0x19>
}
  800384:	89 f0                	mov    %esi,%eax
  800386:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800389:	5b                   	pop    %ebx
  80038a:	5e                   	pop    %esi
  80038b:	5f                   	pop    %edi
  80038c:	5d                   	pop    %ebp
  80038d:	c3                   	ret    

0080038e <devcons_read>:
{
  80038e:	55                   	push   %ebp
  80038f:	89 e5                	mov    %esp,%ebp
  800391:	83 ec 08             	sub    $0x8,%esp
  800394:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800399:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80039d:	75 07                	jne    8003a6 <devcons_read+0x18>
}
  80039f:	c9                   	leave  
  8003a0:	c3                   	ret    
		sys_yield();
  8003a1:	e8 1e 0c 00 00       	call   800fc4 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8003a6:	e8 9a 0b 00 00       	call   800f45 <sys_cgetc>
  8003ab:	85 c0                	test   %eax,%eax
  8003ad:	74 f2                	je     8003a1 <devcons_read+0x13>
	if (c < 0)
  8003af:	85 c0                	test   %eax,%eax
  8003b1:	78 ec                	js     80039f <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  8003b3:	83 f8 04             	cmp    $0x4,%eax
  8003b6:	74 0c                	je     8003c4 <devcons_read+0x36>
	*(char*)vbuf = c;
  8003b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003bb:	88 02                	mov    %al,(%edx)
	return 1;
  8003bd:	b8 01 00 00 00       	mov    $0x1,%eax
  8003c2:	eb db                	jmp    80039f <devcons_read+0x11>
		return 0;
  8003c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c9:	eb d4                	jmp    80039f <devcons_read+0x11>

008003cb <cputchar>:
{
  8003cb:	55                   	push   %ebp
  8003cc:	89 e5                	mov    %esp,%ebp
  8003ce:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8003d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d4:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8003d7:	6a 01                	push   $0x1
  8003d9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8003dc:	50                   	push   %eax
  8003dd:	e8 45 0b 00 00       	call   800f27 <sys_cputs>
}
  8003e2:	83 c4 10             	add    $0x10,%esp
  8003e5:	c9                   	leave  
  8003e6:	c3                   	ret    

008003e7 <getchar>:
{
  8003e7:	55                   	push   %ebp
  8003e8:	89 e5                	mov    %esp,%ebp
  8003ea:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  8003ed:	6a 01                	push   $0x1
  8003ef:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8003f2:	50                   	push   %eax
  8003f3:	6a 00                	push   $0x0
  8003f5:	e8 c2 13 00 00       	call   8017bc <read>
	if (r < 0)
  8003fa:	83 c4 10             	add    $0x10,%esp
  8003fd:	85 c0                	test   %eax,%eax
  8003ff:	78 08                	js     800409 <getchar+0x22>
	if (r < 1)
  800401:	85 c0                	test   %eax,%eax
  800403:	7e 06                	jle    80040b <getchar+0x24>
	return c;
  800405:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800409:	c9                   	leave  
  80040a:	c3                   	ret    
		return -E_EOF;
  80040b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800410:	eb f7                	jmp    800409 <getchar+0x22>

00800412 <iscons>:
{
  800412:	55                   	push   %ebp
  800413:	89 e5                	mov    %esp,%ebp
  800415:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800418:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80041b:	50                   	push   %eax
  80041c:	ff 75 08             	pushl  0x8(%ebp)
  80041f:	e8 27 11 00 00       	call   80154b <fd_lookup>
  800424:	83 c4 10             	add    $0x10,%esp
  800427:	85 c0                	test   %eax,%eax
  800429:	78 11                	js     80043c <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  80042b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80042e:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800434:	39 10                	cmp    %edx,(%eax)
  800436:	0f 94 c0             	sete   %al
  800439:	0f b6 c0             	movzbl %al,%eax
}
  80043c:	c9                   	leave  
  80043d:	c3                   	ret    

0080043e <opencons>:
{
  80043e:	55                   	push   %ebp
  80043f:	89 e5                	mov    %esp,%ebp
  800441:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  800444:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800447:	50                   	push   %eax
  800448:	e8 af 10 00 00       	call   8014fc <fd_alloc>
  80044d:	83 c4 10             	add    $0x10,%esp
  800450:	85 c0                	test   %eax,%eax
  800452:	78 3a                	js     80048e <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800454:	83 ec 04             	sub    $0x4,%esp
  800457:	68 07 04 00 00       	push   $0x407
  80045c:	ff 75 f4             	pushl  -0xc(%ebp)
  80045f:	6a 00                	push   $0x0
  800461:	e8 7d 0b 00 00       	call   800fe3 <sys_page_alloc>
  800466:	83 c4 10             	add    $0x10,%esp
  800469:	85 c0                	test   %eax,%eax
  80046b:	78 21                	js     80048e <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  80046d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800470:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800476:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800478:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80047b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800482:	83 ec 0c             	sub    $0xc,%esp
  800485:	50                   	push   %eax
  800486:	e8 4a 10 00 00       	call   8014d5 <fd2num>
  80048b:	83 c4 10             	add    $0x10,%esp
}
  80048e:	c9                   	leave  
  80048f:	c3                   	ret    

00800490 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800490:	55                   	push   %ebp
  800491:	89 e5                	mov    %esp,%ebp
  800493:	56                   	push   %esi
  800494:	53                   	push   %ebx
  800495:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800498:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80049b:	e8 05 0b 00 00       	call   800fa5 <sys_getenvid>
  8004a0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8004a5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8004a8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8004ad:	a3 04 50 80 00       	mov    %eax,0x805004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8004b2:	85 db                	test   %ebx,%ebx
  8004b4:	7e 07                	jle    8004bd <libmain+0x2d>
		binaryname = argv[0];
  8004b6:	8b 06                	mov    (%esi),%eax
  8004b8:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  8004bd:	83 ec 08             	sub    $0x8,%esp
  8004c0:	56                   	push   %esi
  8004c1:	53                   	push   %ebx
  8004c2:	e8 24 fc ff ff       	call   8000eb <umain>

	// exit gracefully
	exit();
  8004c7:	e8 0a 00 00 00       	call   8004d6 <exit>
}
  8004cc:	83 c4 10             	add    $0x10,%esp
  8004cf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004d2:	5b                   	pop    %ebx
  8004d3:	5e                   	pop    %esi
  8004d4:	5d                   	pop    %ebp
  8004d5:	c3                   	ret    

008004d6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8004d6:	55                   	push   %ebp
  8004d7:	89 e5                	mov    %esp,%ebp
  8004d9:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8004dc:	e8 ca 11 00 00       	call   8016ab <close_all>
	sys_env_destroy(0);
  8004e1:	83 ec 0c             	sub    $0xc,%esp
  8004e4:	6a 00                	push   $0x0
  8004e6:	e8 79 0a 00 00       	call   800f64 <sys_env_destroy>
}
  8004eb:	83 c4 10             	add    $0x10,%esp
  8004ee:	c9                   	leave  
  8004ef:	c3                   	ret    

008004f0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8004f0:	55                   	push   %ebp
  8004f1:	89 e5                	mov    %esp,%ebp
  8004f3:	56                   	push   %esi
  8004f4:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8004f5:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8004f8:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  8004fe:	e8 a2 0a 00 00       	call   800fa5 <sys_getenvid>
  800503:	83 ec 0c             	sub    $0xc,%esp
  800506:	ff 75 0c             	pushl  0xc(%ebp)
  800509:	ff 75 08             	pushl  0x8(%ebp)
  80050c:	56                   	push   %esi
  80050d:	50                   	push   %eax
  80050e:	68 cc 2b 80 00       	push   $0x802bcc
  800513:	e8 b3 00 00 00       	call   8005cb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800518:	83 c4 18             	add    $0x18,%esp
  80051b:	53                   	push   %ebx
  80051c:	ff 75 10             	pushl  0x10(%ebp)
  80051f:	e8 56 00 00 00       	call   80057a <vcprintf>
	cprintf("\n");
  800524:	c7 04 24 f8 2a 80 00 	movl   $0x802af8,(%esp)
  80052b:	e8 9b 00 00 00       	call   8005cb <cprintf>
  800530:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800533:	cc                   	int3   
  800534:	eb fd                	jmp    800533 <_panic+0x43>

00800536 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800536:	55                   	push   %ebp
  800537:	89 e5                	mov    %esp,%ebp
  800539:	53                   	push   %ebx
  80053a:	83 ec 04             	sub    $0x4,%esp
  80053d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800540:	8b 13                	mov    (%ebx),%edx
  800542:	8d 42 01             	lea    0x1(%edx),%eax
  800545:	89 03                	mov    %eax,(%ebx)
  800547:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80054a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80054e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800553:	74 09                	je     80055e <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800555:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800559:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80055c:	c9                   	leave  
  80055d:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80055e:	83 ec 08             	sub    $0x8,%esp
  800561:	68 ff 00 00 00       	push   $0xff
  800566:	8d 43 08             	lea    0x8(%ebx),%eax
  800569:	50                   	push   %eax
  80056a:	e8 b8 09 00 00       	call   800f27 <sys_cputs>
		b->idx = 0;
  80056f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800575:	83 c4 10             	add    $0x10,%esp
  800578:	eb db                	jmp    800555 <putch+0x1f>

0080057a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80057a:	55                   	push   %ebp
  80057b:	89 e5                	mov    %esp,%ebp
  80057d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800583:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80058a:	00 00 00 
	b.cnt = 0;
  80058d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800594:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800597:	ff 75 0c             	pushl  0xc(%ebp)
  80059a:	ff 75 08             	pushl  0x8(%ebp)
  80059d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8005a3:	50                   	push   %eax
  8005a4:	68 36 05 80 00       	push   $0x800536
  8005a9:	e8 1a 01 00 00       	call   8006c8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005ae:	83 c4 08             	add    $0x8,%esp
  8005b1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8005b7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8005bd:	50                   	push   %eax
  8005be:	e8 64 09 00 00       	call   800f27 <sys_cputs>

	return b.cnt;
}
  8005c3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8005c9:	c9                   	leave  
  8005ca:	c3                   	ret    

008005cb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005cb:	55                   	push   %ebp
  8005cc:	89 e5                	mov    %esp,%ebp
  8005ce:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005d1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8005d4:	50                   	push   %eax
  8005d5:	ff 75 08             	pushl  0x8(%ebp)
  8005d8:	e8 9d ff ff ff       	call   80057a <vcprintf>
	va_end(ap);

	return cnt;
}
  8005dd:	c9                   	leave  
  8005de:	c3                   	ret    

008005df <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005df:	55                   	push   %ebp
  8005e0:	89 e5                	mov    %esp,%ebp
  8005e2:	57                   	push   %edi
  8005e3:	56                   	push   %esi
  8005e4:	53                   	push   %ebx
  8005e5:	83 ec 1c             	sub    $0x1c,%esp
  8005e8:	89 c7                	mov    %eax,%edi
  8005ea:	89 d6                	mov    %edx,%esi
  8005ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f5:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005f8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8005fb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800600:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800603:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800606:	39 d3                	cmp    %edx,%ebx
  800608:	72 05                	jb     80060f <printnum+0x30>
  80060a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80060d:	77 7a                	ja     800689 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80060f:	83 ec 0c             	sub    $0xc,%esp
  800612:	ff 75 18             	pushl  0x18(%ebp)
  800615:	8b 45 14             	mov    0x14(%ebp),%eax
  800618:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80061b:	53                   	push   %ebx
  80061c:	ff 75 10             	pushl  0x10(%ebp)
  80061f:	83 ec 08             	sub    $0x8,%esp
  800622:	ff 75 e4             	pushl  -0x1c(%ebp)
  800625:	ff 75 e0             	pushl  -0x20(%ebp)
  800628:	ff 75 dc             	pushl  -0x24(%ebp)
  80062b:	ff 75 d8             	pushl  -0x28(%ebp)
  80062e:	e8 fd 21 00 00       	call   802830 <__udivdi3>
  800633:	83 c4 18             	add    $0x18,%esp
  800636:	52                   	push   %edx
  800637:	50                   	push   %eax
  800638:	89 f2                	mov    %esi,%edx
  80063a:	89 f8                	mov    %edi,%eax
  80063c:	e8 9e ff ff ff       	call   8005df <printnum>
  800641:	83 c4 20             	add    $0x20,%esp
  800644:	eb 13                	jmp    800659 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800646:	83 ec 08             	sub    $0x8,%esp
  800649:	56                   	push   %esi
  80064a:	ff 75 18             	pushl  0x18(%ebp)
  80064d:	ff d7                	call   *%edi
  80064f:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800652:	83 eb 01             	sub    $0x1,%ebx
  800655:	85 db                	test   %ebx,%ebx
  800657:	7f ed                	jg     800646 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800659:	83 ec 08             	sub    $0x8,%esp
  80065c:	56                   	push   %esi
  80065d:	83 ec 04             	sub    $0x4,%esp
  800660:	ff 75 e4             	pushl  -0x1c(%ebp)
  800663:	ff 75 e0             	pushl  -0x20(%ebp)
  800666:	ff 75 dc             	pushl  -0x24(%ebp)
  800669:	ff 75 d8             	pushl  -0x28(%ebp)
  80066c:	e8 df 22 00 00       	call   802950 <__umoddi3>
  800671:	83 c4 14             	add    $0x14,%esp
  800674:	0f be 80 ef 2b 80 00 	movsbl 0x802bef(%eax),%eax
  80067b:	50                   	push   %eax
  80067c:	ff d7                	call   *%edi
}
  80067e:	83 c4 10             	add    $0x10,%esp
  800681:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800684:	5b                   	pop    %ebx
  800685:	5e                   	pop    %esi
  800686:	5f                   	pop    %edi
  800687:	5d                   	pop    %ebp
  800688:	c3                   	ret    
  800689:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80068c:	eb c4                	jmp    800652 <printnum+0x73>

0080068e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80068e:	55                   	push   %ebp
  80068f:	89 e5                	mov    %esp,%ebp
  800691:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800694:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800698:	8b 10                	mov    (%eax),%edx
  80069a:	3b 50 04             	cmp    0x4(%eax),%edx
  80069d:	73 0a                	jae    8006a9 <sprintputch+0x1b>
		*b->buf++ = ch;
  80069f:	8d 4a 01             	lea    0x1(%edx),%ecx
  8006a2:	89 08                	mov    %ecx,(%eax)
  8006a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a7:	88 02                	mov    %al,(%edx)
}
  8006a9:	5d                   	pop    %ebp
  8006aa:	c3                   	ret    

008006ab <printfmt>:
{
  8006ab:	55                   	push   %ebp
  8006ac:	89 e5                	mov    %esp,%ebp
  8006ae:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8006b1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006b4:	50                   	push   %eax
  8006b5:	ff 75 10             	pushl  0x10(%ebp)
  8006b8:	ff 75 0c             	pushl  0xc(%ebp)
  8006bb:	ff 75 08             	pushl  0x8(%ebp)
  8006be:	e8 05 00 00 00       	call   8006c8 <vprintfmt>
}
  8006c3:	83 c4 10             	add    $0x10,%esp
  8006c6:	c9                   	leave  
  8006c7:	c3                   	ret    

008006c8 <vprintfmt>:
{
  8006c8:	55                   	push   %ebp
  8006c9:	89 e5                	mov    %esp,%ebp
  8006cb:	57                   	push   %edi
  8006cc:	56                   	push   %esi
  8006cd:	53                   	push   %ebx
  8006ce:	83 ec 2c             	sub    $0x2c,%esp
  8006d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8006d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006d7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8006da:	e9 c1 03 00 00       	jmp    800aa0 <vprintfmt+0x3d8>
		padc = ' ';
  8006df:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8006e3:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8006ea:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8006f1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8006f8:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8006fd:	8d 47 01             	lea    0x1(%edi),%eax
  800700:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800703:	0f b6 17             	movzbl (%edi),%edx
  800706:	8d 42 dd             	lea    -0x23(%edx),%eax
  800709:	3c 55                	cmp    $0x55,%al
  80070b:	0f 87 12 04 00 00    	ja     800b23 <vprintfmt+0x45b>
  800711:	0f b6 c0             	movzbl %al,%eax
  800714:	ff 24 85 40 2d 80 00 	jmp    *0x802d40(,%eax,4)
  80071b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80071e:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800722:	eb d9                	jmp    8006fd <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800724:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800727:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80072b:	eb d0                	jmp    8006fd <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80072d:	0f b6 d2             	movzbl %dl,%edx
  800730:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800733:	b8 00 00 00 00       	mov    $0x0,%eax
  800738:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80073b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80073e:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800742:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800745:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800748:	83 f9 09             	cmp    $0x9,%ecx
  80074b:	77 55                	ja     8007a2 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  80074d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800750:	eb e9                	jmp    80073b <vprintfmt+0x73>
			precision = va_arg(ap, int);
  800752:	8b 45 14             	mov    0x14(%ebp),%eax
  800755:	8b 00                	mov    (%eax),%eax
  800757:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80075a:	8b 45 14             	mov    0x14(%ebp),%eax
  80075d:	8d 40 04             	lea    0x4(%eax),%eax
  800760:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800763:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800766:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80076a:	79 91                	jns    8006fd <vprintfmt+0x35>
				width = precision, precision = -1;
  80076c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80076f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800772:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800779:	eb 82                	jmp    8006fd <vprintfmt+0x35>
  80077b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80077e:	85 c0                	test   %eax,%eax
  800780:	ba 00 00 00 00       	mov    $0x0,%edx
  800785:	0f 49 d0             	cmovns %eax,%edx
  800788:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80078b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80078e:	e9 6a ff ff ff       	jmp    8006fd <vprintfmt+0x35>
  800793:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800796:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80079d:	e9 5b ff ff ff       	jmp    8006fd <vprintfmt+0x35>
  8007a2:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8007a5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8007a8:	eb bc                	jmp    800766 <vprintfmt+0x9e>
			lflag++;
  8007aa:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8007ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8007b0:	e9 48 ff ff ff       	jmp    8006fd <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8007b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b8:	8d 78 04             	lea    0x4(%eax),%edi
  8007bb:	83 ec 08             	sub    $0x8,%esp
  8007be:	53                   	push   %ebx
  8007bf:	ff 30                	pushl  (%eax)
  8007c1:	ff d6                	call   *%esi
			break;
  8007c3:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8007c6:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8007c9:	e9 cf 02 00 00       	jmp    800a9d <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  8007ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d1:	8d 78 04             	lea    0x4(%eax),%edi
  8007d4:	8b 00                	mov    (%eax),%eax
  8007d6:	99                   	cltd   
  8007d7:	31 d0                	xor    %edx,%eax
  8007d9:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8007db:	83 f8 0f             	cmp    $0xf,%eax
  8007de:	7f 23                	jg     800803 <vprintfmt+0x13b>
  8007e0:	8b 14 85 a0 2e 80 00 	mov    0x802ea0(,%eax,4),%edx
  8007e7:	85 d2                	test   %edx,%edx
  8007e9:	74 18                	je     800803 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8007eb:	52                   	push   %edx
  8007ec:	68 11 31 80 00       	push   $0x803111
  8007f1:	53                   	push   %ebx
  8007f2:	56                   	push   %esi
  8007f3:	e8 b3 fe ff ff       	call   8006ab <printfmt>
  8007f8:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8007fb:	89 7d 14             	mov    %edi,0x14(%ebp)
  8007fe:	e9 9a 02 00 00       	jmp    800a9d <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  800803:	50                   	push   %eax
  800804:	68 07 2c 80 00       	push   $0x802c07
  800809:	53                   	push   %ebx
  80080a:	56                   	push   %esi
  80080b:	e8 9b fe ff ff       	call   8006ab <printfmt>
  800810:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800813:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800816:	e9 82 02 00 00       	jmp    800a9d <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  80081b:	8b 45 14             	mov    0x14(%ebp),%eax
  80081e:	83 c0 04             	add    $0x4,%eax
  800821:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800824:	8b 45 14             	mov    0x14(%ebp),%eax
  800827:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800829:	85 ff                	test   %edi,%edi
  80082b:	b8 00 2c 80 00       	mov    $0x802c00,%eax
  800830:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800833:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800837:	0f 8e bd 00 00 00    	jle    8008fa <vprintfmt+0x232>
  80083d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800841:	75 0e                	jne    800851 <vprintfmt+0x189>
  800843:	89 75 08             	mov    %esi,0x8(%ebp)
  800846:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800849:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80084c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80084f:	eb 6d                	jmp    8008be <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  800851:	83 ec 08             	sub    $0x8,%esp
  800854:	ff 75 d0             	pushl  -0x30(%ebp)
  800857:	57                   	push   %edi
  800858:	e8 6e 03 00 00       	call   800bcb <strnlen>
  80085d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800860:	29 c1                	sub    %eax,%ecx
  800862:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800865:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800868:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80086c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80086f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800872:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800874:	eb 0f                	jmp    800885 <vprintfmt+0x1bd>
					putch(padc, putdat);
  800876:	83 ec 08             	sub    $0x8,%esp
  800879:	53                   	push   %ebx
  80087a:	ff 75 e0             	pushl  -0x20(%ebp)
  80087d:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80087f:	83 ef 01             	sub    $0x1,%edi
  800882:	83 c4 10             	add    $0x10,%esp
  800885:	85 ff                	test   %edi,%edi
  800887:	7f ed                	jg     800876 <vprintfmt+0x1ae>
  800889:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80088c:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80088f:	85 c9                	test   %ecx,%ecx
  800891:	b8 00 00 00 00       	mov    $0x0,%eax
  800896:	0f 49 c1             	cmovns %ecx,%eax
  800899:	29 c1                	sub    %eax,%ecx
  80089b:	89 75 08             	mov    %esi,0x8(%ebp)
  80089e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8008a1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8008a4:	89 cb                	mov    %ecx,%ebx
  8008a6:	eb 16                	jmp    8008be <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8008a8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8008ac:	75 31                	jne    8008df <vprintfmt+0x217>
					putch(ch, putdat);
  8008ae:	83 ec 08             	sub    $0x8,%esp
  8008b1:	ff 75 0c             	pushl  0xc(%ebp)
  8008b4:	50                   	push   %eax
  8008b5:	ff 55 08             	call   *0x8(%ebp)
  8008b8:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008bb:	83 eb 01             	sub    $0x1,%ebx
  8008be:	83 c7 01             	add    $0x1,%edi
  8008c1:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8008c5:	0f be c2             	movsbl %dl,%eax
  8008c8:	85 c0                	test   %eax,%eax
  8008ca:	74 59                	je     800925 <vprintfmt+0x25d>
  8008cc:	85 f6                	test   %esi,%esi
  8008ce:	78 d8                	js     8008a8 <vprintfmt+0x1e0>
  8008d0:	83 ee 01             	sub    $0x1,%esi
  8008d3:	79 d3                	jns    8008a8 <vprintfmt+0x1e0>
  8008d5:	89 df                	mov    %ebx,%edi
  8008d7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008dd:	eb 37                	jmp    800916 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8008df:	0f be d2             	movsbl %dl,%edx
  8008e2:	83 ea 20             	sub    $0x20,%edx
  8008e5:	83 fa 5e             	cmp    $0x5e,%edx
  8008e8:	76 c4                	jbe    8008ae <vprintfmt+0x1e6>
					putch('?', putdat);
  8008ea:	83 ec 08             	sub    $0x8,%esp
  8008ed:	ff 75 0c             	pushl  0xc(%ebp)
  8008f0:	6a 3f                	push   $0x3f
  8008f2:	ff 55 08             	call   *0x8(%ebp)
  8008f5:	83 c4 10             	add    $0x10,%esp
  8008f8:	eb c1                	jmp    8008bb <vprintfmt+0x1f3>
  8008fa:	89 75 08             	mov    %esi,0x8(%ebp)
  8008fd:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800900:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800903:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800906:	eb b6                	jmp    8008be <vprintfmt+0x1f6>
				putch(' ', putdat);
  800908:	83 ec 08             	sub    $0x8,%esp
  80090b:	53                   	push   %ebx
  80090c:	6a 20                	push   $0x20
  80090e:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800910:	83 ef 01             	sub    $0x1,%edi
  800913:	83 c4 10             	add    $0x10,%esp
  800916:	85 ff                	test   %edi,%edi
  800918:	7f ee                	jg     800908 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  80091a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80091d:	89 45 14             	mov    %eax,0x14(%ebp)
  800920:	e9 78 01 00 00       	jmp    800a9d <vprintfmt+0x3d5>
  800925:	89 df                	mov    %ebx,%edi
  800927:	8b 75 08             	mov    0x8(%ebp),%esi
  80092a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80092d:	eb e7                	jmp    800916 <vprintfmt+0x24e>
	if (lflag >= 2)
  80092f:	83 f9 01             	cmp    $0x1,%ecx
  800932:	7e 3f                	jle    800973 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800934:	8b 45 14             	mov    0x14(%ebp),%eax
  800937:	8b 50 04             	mov    0x4(%eax),%edx
  80093a:	8b 00                	mov    (%eax),%eax
  80093c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80093f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800942:	8b 45 14             	mov    0x14(%ebp),%eax
  800945:	8d 40 08             	lea    0x8(%eax),%eax
  800948:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80094b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80094f:	79 5c                	jns    8009ad <vprintfmt+0x2e5>
				putch('-', putdat);
  800951:	83 ec 08             	sub    $0x8,%esp
  800954:	53                   	push   %ebx
  800955:	6a 2d                	push   $0x2d
  800957:	ff d6                	call   *%esi
				num = -(long long) num;
  800959:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80095c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80095f:	f7 da                	neg    %edx
  800961:	83 d1 00             	adc    $0x0,%ecx
  800964:	f7 d9                	neg    %ecx
  800966:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800969:	b8 0a 00 00 00       	mov    $0xa,%eax
  80096e:	e9 10 01 00 00       	jmp    800a83 <vprintfmt+0x3bb>
	else if (lflag)
  800973:	85 c9                	test   %ecx,%ecx
  800975:	75 1b                	jne    800992 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800977:	8b 45 14             	mov    0x14(%ebp),%eax
  80097a:	8b 00                	mov    (%eax),%eax
  80097c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80097f:	89 c1                	mov    %eax,%ecx
  800981:	c1 f9 1f             	sar    $0x1f,%ecx
  800984:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800987:	8b 45 14             	mov    0x14(%ebp),%eax
  80098a:	8d 40 04             	lea    0x4(%eax),%eax
  80098d:	89 45 14             	mov    %eax,0x14(%ebp)
  800990:	eb b9                	jmp    80094b <vprintfmt+0x283>
		return va_arg(*ap, long);
  800992:	8b 45 14             	mov    0x14(%ebp),%eax
  800995:	8b 00                	mov    (%eax),%eax
  800997:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80099a:	89 c1                	mov    %eax,%ecx
  80099c:	c1 f9 1f             	sar    $0x1f,%ecx
  80099f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8009a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a5:	8d 40 04             	lea    0x4(%eax),%eax
  8009a8:	89 45 14             	mov    %eax,0x14(%ebp)
  8009ab:	eb 9e                	jmp    80094b <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8009ad:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8009b0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8009b3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009b8:	e9 c6 00 00 00       	jmp    800a83 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8009bd:	83 f9 01             	cmp    $0x1,%ecx
  8009c0:	7e 18                	jle    8009da <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8009c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8009c5:	8b 10                	mov    (%eax),%edx
  8009c7:	8b 48 04             	mov    0x4(%eax),%ecx
  8009ca:	8d 40 08             	lea    0x8(%eax),%eax
  8009cd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8009d0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009d5:	e9 a9 00 00 00       	jmp    800a83 <vprintfmt+0x3bb>
	else if (lflag)
  8009da:	85 c9                	test   %ecx,%ecx
  8009dc:	75 1a                	jne    8009f8 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  8009de:	8b 45 14             	mov    0x14(%ebp),%eax
  8009e1:	8b 10                	mov    (%eax),%edx
  8009e3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009e8:	8d 40 04             	lea    0x4(%eax),%eax
  8009eb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8009ee:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009f3:	e9 8b 00 00 00       	jmp    800a83 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8009f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8009fb:	8b 10                	mov    (%eax),%edx
  8009fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a02:	8d 40 04             	lea    0x4(%eax),%eax
  800a05:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800a08:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a0d:	eb 74                	jmp    800a83 <vprintfmt+0x3bb>
	if (lflag >= 2)
  800a0f:	83 f9 01             	cmp    $0x1,%ecx
  800a12:	7e 15                	jle    800a29 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  800a14:	8b 45 14             	mov    0x14(%ebp),%eax
  800a17:	8b 10                	mov    (%eax),%edx
  800a19:	8b 48 04             	mov    0x4(%eax),%ecx
  800a1c:	8d 40 08             	lea    0x8(%eax),%eax
  800a1f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800a22:	b8 08 00 00 00       	mov    $0x8,%eax
  800a27:	eb 5a                	jmp    800a83 <vprintfmt+0x3bb>
	else if (lflag)
  800a29:	85 c9                	test   %ecx,%ecx
  800a2b:	75 17                	jne    800a44 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  800a2d:	8b 45 14             	mov    0x14(%ebp),%eax
  800a30:	8b 10                	mov    (%eax),%edx
  800a32:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a37:	8d 40 04             	lea    0x4(%eax),%eax
  800a3a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800a3d:	b8 08 00 00 00       	mov    $0x8,%eax
  800a42:	eb 3f                	jmp    800a83 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800a44:	8b 45 14             	mov    0x14(%ebp),%eax
  800a47:	8b 10                	mov    (%eax),%edx
  800a49:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a4e:	8d 40 04             	lea    0x4(%eax),%eax
  800a51:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800a54:	b8 08 00 00 00       	mov    $0x8,%eax
  800a59:	eb 28                	jmp    800a83 <vprintfmt+0x3bb>
			putch('0', putdat);
  800a5b:	83 ec 08             	sub    $0x8,%esp
  800a5e:	53                   	push   %ebx
  800a5f:	6a 30                	push   $0x30
  800a61:	ff d6                	call   *%esi
			putch('x', putdat);
  800a63:	83 c4 08             	add    $0x8,%esp
  800a66:	53                   	push   %ebx
  800a67:	6a 78                	push   $0x78
  800a69:	ff d6                	call   *%esi
			num = (unsigned long long)
  800a6b:	8b 45 14             	mov    0x14(%ebp),%eax
  800a6e:	8b 10                	mov    (%eax),%edx
  800a70:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800a75:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800a78:	8d 40 04             	lea    0x4(%eax),%eax
  800a7b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800a7e:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800a83:	83 ec 0c             	sub    $0xc,%esp
  800a86:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800a8a:	57                   	push   %edi
  800a8b:	ff 75 e0             	pushl  -0x20(%ebp)
  800a8e:	50                   	push   %eax
  800a8f:	51                   	push   %ecx
  800a90:	52                   	push   %edx
  800a91:	89 da                	mov    %ebx,%edx
  800a93:	89 f0                	mov    %esi,%eax
  800a95:	e8 45 fb ff ff       	call   8005df <printnum>
			break;
  800a9a:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800a9d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800aa0:	83 c7 01             	add    $0x1,%edi
  800aa3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800aa7:	83 f8 25             	cmp    $0x25,%eax
  800aaa:	0f 84 2f fc ff ff    	je     8006df <vprintfmt+0x17>
			if (ch == '\0')
  800ab0:	85 c0                	test   %eax,%eax
  800ab2:	0f 84 8b 00 00 00    	je     800b43 <vprintfmt+0x47b>
			putch(ch, putdat);
  800ab8:	83 ec 08             	sub    $0x8,%esp
  800abb:	53                   	push   %ebx
  800abc:	50                   	push   %eax
  800abd:	ff d6                	call   *%esi
  800abf:	83 c4 10             	add    $0x10,%esp
  800ac2:	eb dc                	jmp    800aa0 <vprintfmt+0x3d8>
	if (lflag >= 2)
  800ac4:	83 f9 01             	cmp    $0x1,%ecx
  800ac7:	7e 15                	jle    800ade <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  800ac9:	8b 45 14             	mov    0x14(%ebp),%eax
  800acc:	8b 10                	mov    (%eax),%edx
  800ace:	8b 48 04             	mov    0x4(%eax),%ecx
  800ad1:	8d 40 08             	lea    0x8(%eax),%eax
  800ad4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800ad7:	b8 10 00 00 00       	mov    $0x10,%eax
  800adc:	eb a5                	jmp    800a83 <vprintfmt+0x3bb>
	else if (lflag)
  800ade:	85 c9                	test   %ecx,%ecx
  800ae0:	75 17                	jne    800af9 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  800ae2:	8b 45 14             	mov    0x14(%ebp),%eax
  800ae5:	8b 10                	mov    (%eax),%edx
  800ae7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aec:	8d 40 04             	lea    0x4(%eax),%eax
  800aef:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800af2:	b8 10 00 00 00       	mov    $0x10,%eax
  800af7:	eb 8a                	jmp    800a83 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800af9:	8b 45 14             	mov    0x14(%ebp),%eax
  800afc:	8b 10                	mov    (%eax),%edx
  800afe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b03:	8d 40 04             	lea    0x4(%eax),%eax
  800b06:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800b09:	b8 10 00 00 00       	mov    $0x10,%eax
  800b0e:	e9 70 ff ff ff       	jmp    800a83 <vprintfmt+0x3bb>
			putch(ch, putdat);
  800b13:	83 ec 08             	sub    $0x8,%esp
  800b16:	53                   	push   %ebx
  800b17:	6a 25                	push   $0x25
  800b19:	ff d6                	call   *%esi
			break;
  800b1b:	83 c4 10             	add    $0x10,%esp
  800b1e:	e9 7a ff ff ff       	jmp    800a9d <vprintfmt+0x3d5>
			putch('%', putdat);
  800b23:	83 ec 08             	sub    $0x8,%esp
  800b26:	53                   	push   %ebx
  800b27:	6a 25                	push   $0x25
  800b29:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b2b:	83 c4 10             	add    $0x10,%esp
  800b2e:	89 f8                	mov    %edi,%eax
  800b30:	eb 03                	jmp    800b35 <vprintfmt+0x46d>
  800b32:	83 e8 01             	sub    $0x1,%eax
  800b35:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800b39:	75 f7                	jne    800b32 <vprintfmt+0x46a>
  800b3b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b3e:	e9 5a ff ff ff       	jmp    800a9d <vprintfmt+0x3d5>
}
  800b43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b46:	5b                   	pop    %ebx
  800b47:	5e                   	pop    %esi
  800b48:	5f                   	pop    %edi
  800b49:	5d                   	pop    %ebp
  800b4a:	c3                   	ret    

00800b4b <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b4b:	55                   	push   %ebp
  800b4c:	89 e5                	mov    %esp,%ebp
  800b4e:	83 ec 18             	sub    $0x18,%esp
  800b51:	8b 45 08             	mov    0x8(%ebp),%eax
  800b54:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b57:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b5a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b5e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b61:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b68:	85 c0                	test   %eax,%eax
  800b6a:	74 26                	je     800b92 <vsnprintf+0x47>
  800b6c:	85 d2                	test   %edx,%edx
  800b6e:	7e 22                	jle    800b92 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b70:	ff 75 14             	pushl  0x14(%ebp)
  800b73:	ff 75 10             	pushl  0x10(%ebp)
  800b76:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b79:	50                   	push   %eax
  800b7a:	68 8e 06 80 00       	push   $0x80068e
  800b7f:	e8 44 fb ff ff       	call   8006c8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b84:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b87:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b8d:	83 c4 10             	add    $0x10,%esp
}
  800b90:	c9                   	leave  
  800b91:	c3                   	ret    
		return -E_INVAL;
  800b92:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b97:	eb f7                	jmp    800b90 <vsnprintf+0x45>

00800b99 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b99:	55                   	push   %ebp
  800b9a:	89 e5                	mov    %esp,%ebp
  800b9c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b9f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800ba2:	50                   	push   %eax
  800ba3:	ff 75 10             	pushl  0x10(%ebp)
  800ba6:	ff 75 0c             	pushl  0xc(%ebp)
  800ba9:	ff 75 08             	pushl  0x8(%ebp)
  800bac:	e8 9a ff ff ff       	call   800b4b <vsnprintf>
	va_end(ap);

	return rc;
}
  800bb1:	c9                   	leave  
  800bb2:	c3                   	ret    

00800bb3 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800bb9:	b8 00 00 00 00       	mov    $0x0,%eax
  800bbe:	eb 03                	jmp    800bc3 <strlen+0x10>
		n++;
  800bc0:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800bc3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800bc7:	75 f7                	jne    800bc0 <strlen+0xd>
	return n;
}
  800bc9:	5d                   	pop    %ebp
  800bca:	c3                   	ret    

00800bcb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bd1:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bd4:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd9:	eb 03                	jmp    800bde <strnlen+0x13>
		n++;
  800bdb:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bde:	39 d0                	cmp    %edx,%eax
  800be0:	74 06                	je     800be8 <strnlen+0x1d>
  800be2:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800be6:	75 f3                	jne    800bdb <strnlen+0x10>
	return n;
}
  800be8:	5d                   	pop    %ebp
  800be9:	c3                   	ret    

00800bea <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800bea:	55                   	push   %ebp
  800beb:	89 e5                	mov    %esp,%ebp
  800bed:	53                   	push   %ebx
  800bee:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800bf4:	89 c2                	mov    %eax,%edx
  800bf6:	83 c1 01             	add    $0x1,%ecx
  800bf9:	83 c2 01             	add    $0x1,%edx
  800bfc:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800c00:	88 5a ff             	mov    %bl,-0x1(%edx)
  800c03:	84 db                	test   %bl,%bl
  800c05:	75 ef                	jne    800bf6 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800c07:	5b                   	pop    %ebx
  800c08:	5d                   	pop    %ebp
  800c09:	c3                   	ret    

00800c0a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	53                   	push   %ebx
  800c0e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c11:	53                   	push   %ebx
  800c12:	e8 9c ff ff ff       	call   800bb3 <strlen>
  800c17:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800c1a:	ff 75 0c             	pushl  0xc(%ebp)
  800c1d:	01 d8                	add    %ebx,%eax
  800c1f:	50                   	push   %eax
  800c20:	e8 c5 ff ff ff       	call   800bea <strcpy>
	return dst;
}
  800c25:	89 d8                	mov    %ebx,%eax
  800c27:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c2a:	c9                   	leave  
  800c2b:	c3                   	ret    

00800c2c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
  800c2f:	56                   	push   %esi
  800c30:	53                   	push   %ebx
  800c31:	8b 75 08             	mov    0x8(%ebp),%esi
  800c34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c37:	89 f3                	mov    %esi,%ebx
  800c39:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c3c:	89 f2                	mov    %esi,%edx
  800c3e:	eb 0f                	jmp    800c4f <strncpy+0x23>
		*dst++ = *src;
  800c40:	83 c2 01             	add    $0x1,%edx
  800c43:	0f b6 01             	movzbl (%ecx),%eax
  800c46:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c49:	80 39 01             	cmpb   $0x1,(%ecx)
  800c4c:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800c4f:	39 da                	cmp    %ebx,%edx
  800c51:	75 ed                	jne    800c40 <strncpy+0x14>
	}
	return ret;
}
  800c53:	89 f0                	mov    %esi,%eax
  800c55:	5b                   	pop    %ebx
  800c56:	5e                   	pop    %esi
  800c57:	5d                   	pop    %ebp
  800c58:	c3                   	ret    

00800c59 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c59:	55                   	push   %ebp
  800c5a:	89 e5                	mov    %esp,%ebp
  800c5c:	56                   	push   %esi
  800c5d:	53                   	push   %ebx
  800c5e:	8b 75 08             	mov    0x8(%ebp),%esi
  800c61:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c64:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c67:	89 f0                	mov    %esi,%eax
  800c69:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c6d:	85 c9                	test   %ecx,%ecx
  800c6f:	75 0b                	jne    800c7c <strlcpy+0x23>
  800c71:	eb 17                	jmp    800c8a <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800c73:	83 c2 01             	add    $0x1,%edx
  800c76:	83 c0 01             	add    $0x1,%eax
  800c79:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800c7c:	39 d8                	cmp    %ebx,%eax
  800c7e:	74 07                	je     800c87 <strlcpy+0x2e>
  800c80:	0f b6 0a             	movzbl (%edx),%ecx
  800c83:	84 c9                	test   %cl,%cl
  800c85:	75 ec                	jne    800c73 <strlcpy+0x1a>
		*dst = '\0';
  800c87:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800c8a:	29 f0                	sub    %esi,%eax
}
  800c8c:	5b                   	pop    %ebx
  800c8d:	5e                   	pop    %esi
  800c8e:	5d                   	pop    %ebp
  800c8f:	c3                   	ret    

00800c90 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c90:	55                   	push   %ebp
  800c91:	89 e5                	mov    %esp,%ebp
  800c93:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c96:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c99:	eb 06                	jmp    800ca1 <strcmp+0x11>
		p++, q++;
  800c9b:	83 c1 01             	add    $0x1,%ecx
  800c9e:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800ca1:	0f b6 01             	movzbl (%ecx),%eax
  800ca4:	84 c0                	test   %al,%al
  800ca6:	74 04                	je     800cac <strcmp+0x1c>
  800ca8:	3a 02                	cmp    (%edx),%al
  800caa:	74 ef                	je     800c9b <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800cac:	0f b6 c0             	movzbl %al,%eax
  800caf:	0f b6 12             	movzbl (%edx),%edx
  800cb2:	29 d0                	sub    %edx,%eax
}
  800cb4:	5d                   	pop    %ebp
  800cb5:	c3                   	ret    

00800cb6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800cb6:	55                   	push   %ebp
  800cb7:	89 e5                	mov    %esp,%ebp
  800cb9:	53                   	push   %ebx
  800cba:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cc0:	89 c3                	mov    %eax,%ebx
  800cc2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800cc5:	eb 06                	jmp    800ccd <strncmp+0x17>
		n--, p++, q++;
  800cc7:	83 c0 01             	add    $0x1,%eax
  800cca:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800ccd:	39 d8                	cmp    %ebx,%eax
  800ccf:	74 16                	je     800ce7 <strncmp+0x31>
  800cd1:	0f b6 08             	movzbl (%eax),%ecx
  800cd4:	84 c9                	test   %cl,%cl
  800cd6:	74 04                	je     800cdc <strncmp+0x26>
  800cd8:	3a 0a                	cmp    (%edx),%cl
  800cda:	74 eb                	je     800cc7 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800cdc:	0f b6 00             	movzbl (%eax),%eax
  800cdf:	0f b6 12             	movzbl (%edx),%edx
  800ce2:	29 d0                	sub    %edx,%eax
}
  800ce4:	5b                   	pop    %ebx
  800ce5:	5d                   	pop    %ebp
  800ce6:	c3                   	ret    
		return 0;
  800ce7:	b8 00 00 00 00       	mov    $0x0,%eax
  800cec:	eb f6                	jmp    800ce4 <strncmp+0x2e>

00800cee <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800cee:	55                   	push   %ebp
  800cef:	89 e5                	mov    %esp,%ebp
  800cf1:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cf8:	0f b6 10             	movzbl (%eax),%edx
  800cfb:	84 d2                	test   %dl,%dl
  800cfd:	74 09                	je     800d08 <strchr+0x1a>
		if (*s == c)
  800cff:	38 ca                	cmp    %cl,%dl
  800d01:	74 0a                	je     800d0d <strchr+0x1f>
	for (; *s; s++)
  800d03:	83 c0 01             	add    $0x1,%eax
  800d06:	eb f0                	jmp    800cf8 <strchr+0xa>
			return (char *) s;
	return 0;
  800d08:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d0d:	5d                   	pop    %ebp
  800d0e:	c3                   	ret    

00800d0f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d0f:	55                   	push   %ebp
  800d10:	89 e5                	mov    %esp,%ebp
  800d12:	8b 45 08             	mov    0x8(%ebp),%eax
  800d15:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d19:	eb 03                	jmp    800d1e <strfind+0xf>
  800d1b:	83 c0 01             	add    $0x1,%eax
  800d1e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800d21:	38 ca                	cmp    %cl,%dl
  800d23:	74 04                	je     800d29 <strfind+0x1a>
  800d25:	84 d2                	test   %dl,%dl
  800d27:	75 f2                	jne    800d1b <strfind+0xc>
			break;
	return (char *) s;
}
  800d29:	5d                   	pop    %ebp
  800d2a:	c3                   	ret    

00800d2b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d2b:	55                   	push   %ebp
  800d2c:	89 e5                	mov    %esp,%ebp
  800d2e:	57                   	push   %edi
  800d2f:	56                   	push   %esi
  800d30:	53                   	push   %ebx
  800d31:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d34:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d37:	85 c9                	test   %ecx,%ecx
  800d39:	74 13                	je     800d4e <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d3b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d41:	75 05                	jne    800d48 <memset+0x1d>
  800d43:	f6 c1 03             	test   $0x3,%cl
  800d46:	74 0d                	je     800d55 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d48:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d4b:	fc                   	cld    
  800d4c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d4e:	89 f8                	mov    %edi,%eax
  800d50:	5b                   	pop    %ebx
  800d51:	5e                   	pop    %esi
  800d52:	5f                   	pop    %edi
  800d53:	5d                   	pop    %ebp
  800d54:	c3                   	ret    
		c &= 0xFF;
  800d55:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d59:	89 d3                	mov    %edx,%ebx
  800d5b:	c1 e3 08             	shl    $0x8,%ebx
  800d5e:	89 d0                	mov    %edx,%eax
  800d60:	c1 e0 18             	shl    $0x18,%eax
  800d63:	89 d6                	mov    %edx,%esi
  800d65:	c1 e6 10             	shl    $0x10,%esi
  800d68:	09 f0                	or     %esi,%eax
  800d6a:	09 c2                	or     %eax,%edx
  800d6c:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800d6e:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800d71:	89 d0                	mov    %edx,%eax
  800d73:	fc                   	cld    
  800d74:	f3 ab                	rep stos %eax,%es:(%edi)
  800d76:	eb d6                	jmp    800d4e <memset+0x23>

00800d78 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d78:	55                   	push   %ebp
  800d79:	89 e5                	mov    %esp,%ebp
  800d7b:	57                   	push   %edi
  800d7c:	56                   	push   %esi
  800d7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d80:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d83:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d86:	39 c6                	cmp    %eax,%esi
  800d88:	73 35                	jae    800dbf <memmove+0x47>
  800d8a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d8d:	39 c2                	cmp    %eax,%edx
  800d8f:	76 2e                	jbe    800dbf <memmove+0x47>
		s += n;
		d += n;
  800d91:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d94:	89 d6                	mov    %edx,%esi
  800d96:	09 fe                	or     %edi,%esi
  800d98:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d9e:	74 0c                	je     800dac <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800da0:	83 ef 01             	sub    $0x1,%edi
  800da3:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800da6:	fd                   	std    
  800da7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800da9:	fc                   	cld    
  800daa:	eb 21                	jmp    800dcd <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800dac:	f6 c1 03             	test   $0x3,%cl
  800daf:	75 ef                	jne    800da0 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800db1:	83 ef 04             	sub    $0x4,%edi
  800db4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800db7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800dba:	fd                   	std    
  800dbb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800dbd:	eb ea                	jmp    800da9 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800dbf:	89 f2                	mov    %esi,%edx
  800dc1:	09 c2                	or     %eax,%edx
  800dc3:	f6 c2 03             	test   $0x3,%dl
  800dc6:	74 09                	je     800dd1 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800dc8:	89 c7                	mov    %eax,%edi
  800dca:	fc                   	cld    
  800dcb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800dcd:	5e                   	pop    %esi
  800dce:	5f                   	pop    %edi
  800dcf:	5d                   	pop    %ebp
  800dd0:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800dd1:	f6 c1 03             	test   $0x3,%cl
  800dd4:	75 f2                	jne    800dc8 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800dd6:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800dd9:	89 c7                	mov    %eax,%edi
  800ddb:	fc                   	cld    
  800ddc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800dde:	eb ed                	jmp    800dcd <memmove+0x55>

00800de0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800de0:	55                   	push   %ebp
  800de1:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800de3:	ff 75 10             	pushl  0x10(%ebp)
  800de6:	ff 75 0c             	pushl  0xc(%ebp)
  800de9:	ff 75 08             	pushl  0x8(%ebp)
  800dec:	e8 87 ff ff ff       	call   800d78 <memmove>
}
  800df1:	c9                   	leave  
  800df2:	c3                   	ret    

00800df3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800df3:	55                   	push   %ebp
  800df4:	89 e5                	mov    %esp,%ebp
  800df6:	56                   	push   %esi
  800df7:	53                   	push   %ebx
  800df8:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dfe:	89 c6                	mov    %eax,%esi
  800e00:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e03:	39 f0                	cmp    %esi,%eax
  800e05:	74 1c                	je     800e23 <memcmp+0x30>
		if (*s1 != *s2)
  800e07:	0f b6 08             	movzbl (%eax),%ecx
  800e0a:	0f b6 1a             	movzbl (%edx),%ebx
  800e0d:	38 d9                	cmp    %bl,%cl
  800e0f:	75 08                	jne    800e19 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800e11:	83 c0 01             	add    $0x1,%eax
  800e14:	83 c2 01             	add    $0x1,%edx
  800e17:	eb ea                	jmp    800e03 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800e19:	0f b6 c1             	movzbl %cl,%eax
  800e1c:	0f b6 db             	movzbl %bl,%ebx
  800e1f:	29 d8                	sub    %ebx,%eax
  800e21:	eb 05                	jmp    800e28 <memcmp+0x35>
	}

	return 0;
  800e23:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e28:	5b                   	pop    %ebx
  800e29:	5e                   	pop    %esi
  800e2a:	5d                   	pop    %ebp
  800e2b:	c3                   	ret    

00800e2c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e2c:	55                   	push   %ebp
  800e2d:	89 e5                	mov    %esp,%ebp
  800e2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800e35:	89 c2                	mov    %eax,%edx
  800e37:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e3a:	39 d0                	cmp    %edx,%eax
  800e3c:	73 09                	jae    800e47 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e3e:	38 08                	cmp    %cl,(%eax)
  800e40:	74 05                	je     800e47 <memfind+0x1b>
	for (; s < ends; s++)
  800e42:	83 c0 01             	add    $0x1,%eax
  800e45:	eb f3                	jmp    800e3a <memfind+0xe>
			break;
	return (void *) s;
}
  800e47:	5d                   	pop    %ebp
  800e48:	c3                   	ret    

00800e49 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e49:	55                   	push   %ebp
  800e4a:	89 e5                	mov    %esp,%ebp
  800e4c:	57                   	push   %edi
  800e4d:	56                   	push   %esi
  800e4e:	53                   	push   %ebx
  800e4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e52:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e55:	eb 03                	jmp    800e5a <strtol+0x11>
		s++;
  800e57:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800e5a:	0f b6 01             	movzbl (%ecx),%eax
  800e5d:	3c 20                	cmp    $0x20,%al
  800e5f:	74 f6                	je     800e57 <strtol+0xe>
  800e61:	3c 09                	cmp    $0x9,%al
  800e63:	74 f2                	je     800e57 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800e65:	3c 2b                	cmp    $0x2b,%al
  800e67:	74 2e                	je     800e97 <strtol+0x4e>
	int neg = 0;
  800e69:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800e6e:	3c 2d                	cmp    $0x2d,%al
  800e70:	74 2f                	je     800ea1 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e72:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800e78:	75 05                	jne    800e7f <strtol+0x36>
  800e7a:	80 39 30             	cmpb   $0x30,(%ecx)
  800e7d:	74 2c                	je     800eab <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e7f:	85 db                	test   %ebx,%ebx
  800e81:	75 0a                	jne    800e8d <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e83:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800e88:	80 39 30             	cmpb   $0x30,(%ecx)
  800e8b:	74 28                	je     800eb5 <strtol+0x6c>
		base = 10;
  800e8d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e92:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800e95:	eb 50                	jmp    800ee7 <strtol+0x9e>
		s++;
  800e97:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800e9a:	bf 00 00 00 00       	mov    $0x0,%edi
  800e9f:	eb d1                	jmp    800e72 <strtol+0x29>
		s++, neg = 1;
  800ea1:	83 c1 01             	add    $0x1,%ecx
  800ea4:	bf 01 00 00 00       	mov    $0x1,%edi
  800ea9:	eb c7                	jmp    800e72 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800eab:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800eaf:	74 0e                	je     800ebf <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800eb1:	85 db                	test   %ebx,%ebx
  800eb3:	75 d8                	jne    800e8d <strtol+0x44>
		s++, base = 8;
  800eb5:	83 c1 01             	add    $0x1,%ecx
  800eb8:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ebd:	eb ce                	jmp    800e8d <strtol+0x44>
		s += 2, base = 16;
  800ebf:	83 c1 02             	add    $0x2,%ecx
  800ec2:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ec7:	eb c4                	jmp    800e8d <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800ec9:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ecc:	89 f3                	mov    %esi,%ebx
  800ece:	80 fb 19             	cmp    $0x19,%bl
  800ed1:	77 29                	ja     800efc <strtol+0xb3>
			dig = *s - 'a' + 10;
  800ed3:	0f be d2             	movsbl %dl,%edx
  800ed6:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ed9:	3b 55 10             	cmp    0x10(%ebp),%edx
  800edc:	7d 30                	jge    800f0e <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800ede:	83 c1 01             	add    $0x1,%ecx
  800ee1:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ee5:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ee7:	0f b6 11             	movzbl (%ecx),%edx
  800eea:	8d 72 d0             	lea    -0x30(%edx),%esi
  800eed:	89 f3                	mov    %esi,%ebx
  800eef:	80 fb 09             	cmp    $0x9,%bl
  800ef2:	77 d5                	ja     800ec9 <strtol+0x80>
			dig = *s - '0';
  800ef4:	0f be d2             	movsbl %dl,%edx
  800ef7:	83 ea 30             	sub    $0x30,%edx
  800efa:	eb dd                	jmp    800ed9 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800efc:	8d 72 bf             	lea    -0x41(%edx),%esi
  800eff:	89 f3                	mov    %esi,%ebx
  800f01:	80 fb 19             	cmp    $0x19,%bl
  800f04:	77 08                	ja     800f0e <strtol+0xc5>
			dig = *s - 'A' + 10;
  800f06:	0f be d2             	movsbl %dl,%edx
  800f09:	83 ea 37             	sub    $0x37,%edx
  800f0c:	eb cb                	jmp    800ed9 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800f0e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f12:	74 05                	je     800f19 <strtol+0xd0>
		*endptr = (char *) s;
  800f14:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f17:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800f19:	89 c2                	mov    %eax,%edx
  800f1b:	f7 da                	neg    %edx
  800f1d:	85 ff                	test   %edi,%edi
  800f1f:	0f 45 c2             	cmovne %edx,%eax
}
  800f22:	5b                   	pop    %ebx
  800f23:	5e                   	pop    %esi
  800f24:	5f                   	pop    %edi
  800f25:	5d                   	pop    %ebp
  800f26:	c3                   	ret    

00800f27 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800f27:	55                   	push   %ebp
  800f28:	89 e5                	mov    %esp,%ebp
  800f2a:	57                   	push   %edi
  800f2b:	56                   	push   %esi
  800f2c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f2d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f32:	8b 55 08             	mov    0x8(%ebp),%edx
  800f35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f38:	89 c3                	mov    %eax,%ebx
  800f3a:	89 c7                	mov    %eax,%edi
  800f3c:	89 c6                	mov    %eax,%esi
  800f3e:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800f40:	5b                   	pop    %ebx
  800f41:	5e                   	pop    %esi
  800f42:	5f                   	pop    %edi
  800f43:	5d                   	pop    %ebp
  800f44:	c3                   	ret    

00800f45 <sys_cgetc>:

int
sys_cgetc(void)
{
  800f45:	55                   	push   %ebp
  800f46:	89 e5                	mov    %esp,%ebp
  800f48:	57                   	push   %edi
  800f49:	56                   	push   %esi
  800f4a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800f50:	b8 01 00 00 00       	mov    $0x1,%eax
  800f55:	89 d1                	mov    %edx,%ecx
  800f57:	89 d3                	mov    %edx,%ebx
  800f59:	89 d7                	mov    %edx,%edi
  800f5b:	89 d6                	mov    %edx,%esi
  800f5d:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800f5f:	5b                   	pop    %ebx
  800f60:	5e                   	pop    %esi
  800f61:	5f                   	pop    %edi
  800f62:	5d                   	pop    %ebp
  800f63:	c3                   	ret    

00800f64 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800f64:	55                   	push   %ebp
  800f65:	89 e5                	mov    %esp,%ebp
  800f67:	57                   	push   %edi
  800f68:	56                   	push   %esi
  800f69:	53                   	push   %ebx
  800f6a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f6d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f72:	8b 55 08             	mov    0x8(%ebp),%edx
  800f75:	b8 03 00 00 00       	mov    $0x3,%eax
  800f7a:	89 cb                	mov    %ecx,%ebx
  800f7c:	89 cf                	mov    %ecx,%edi
  800f7e:	89 ce                	mov    %ecx,%esi
  800f80:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f82:	85 c0                	test   %eax,%eax
  800f84:	7f 08                	jg     800f8e <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f89:	5b                   	pop    %ebx
  800f8a:	5e                   	pop    %esi
  800f8b:	5f                   	pop    %edi
  800f8c:	5d                   	pop    %ebp
  800f8d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f8e:	83 ec 0c             	sub    $0xc,%esp
  800f91:	50                   	push   %eax
  800f92:	6a 03                	push   $0x3
  800f94:	68 ff 2e 80 00       	push   $0x802eff
  800f99:	6a 23                	push   $0x23
  800f9b:	68 1c 2f 80 00       	push   $0x802f1c
  800fa0:	e8 4b f5 ff ff       	call   8004f0 <_panic>

00800fa5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800fa5:	55                   	push   %ebp
  800fa6:	89 e5                	mov    %esp,%ebp
  800fa8:	57                   	push   %edi
  800fa9:	56                   	push   %esi
  800faa:	53                   	push   %ebx
	asm volatile("int %1\n"
  800fab:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb0:	b8 02 00 00 00       	mov    $0x2,%eax
  800fb5:	89 d1                	mov    %edx,%ecx
  800fb7:	89 d3                	mov    %edx,%ebx
  800fb9:	89 d7                	mov    %edx,%edi
  800fbb:	89 d6                	mov    %edx,%esi
  800fbd:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800fbf:	5b                   	pop    %ebx
  800fc0:	5e                   	pop    %esi
  800fc1:	5f                   	pop    %edi
  800fc2:	5d                   	pop    %ebp
  800fc3:	c3                   	ret    

00800fc4 <sys_yield>:

void
sys_yield(void)
{
  800fc4:	55                   	push   %ebp
  800fc5:	89 e5                	mov    %esp,%ebp
  800fc7:	57                   	push   %edi
  800fc8:	56                   	push   %esi
  800fc9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800fca:	ba 00 00 00 00       	mov    $0x0,%edx
  800fcf:	b8 0b 00 00 00       	mov    $0xb,%eax
  800fd4:	89 d1                	mov    %edx,%ecx
  800fd6:	89 d3                	mov    %edx,%ebx
  800fd8:	89 d7                	mov    %edx,%edi
  800fda:	89 d6                	mov    %edx,%esi
  800fdc:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800fde:	5b                   	pop    %ebx
  800fdf:	5e                   	pop    %esi
  800fe0:	5f                   	pop    %edi
  800fe1:	5d                   	pop    %ebp
  800fe2:	c3                   	ret    

00800fe3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800fe3:	55                   	push   %ebp
  800fe4:	89 e5                	mov    %esp,%ebp
  800fe6:	57                   	push   %edi
  800fe7:	56                   	push   %esi
  800fe8:	53                   	push   %ebx
  800fe9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800fec:	be 00 00 00 00       	mov    $0x0,%esi
  800ff1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ff7:	b8 04 00 00 00       	mov    $0x4,%eax
  800ffc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fff:	89 f7                	mov    %esi,%edi
  801001:	cd 30                	int    $0x30
	if(check && ret > 0)
  801003:	85 c0                	test   %eax,%eax
  801005:	7f 08                	jg     80100f <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801007:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80100a:	5b                   	pop    %ebx
  80100b:	5e                   	pop    %esi
  80100c:	5f                   	pop    %edi
  80100d:	5d                   	pop    %ebp
  80100e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80100f:	83 ec 0c             	sub    $0xc,%esp
  801012:	50                   	push   %eax
  801013:	6a 04                	push   $0x4
  801015:	68 ff 2e 80 00       	push   $0x802eff
  80101a:	6a 23                	push   $0x23
  80101c:	68 1c 2f 80 00       	push   $0x802f1c
  801021:	e8 ca f4 ff ff       	call   8004f0 <_panic>

00801026 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801026:	55                   	push   %ebp
  801027:	89 e5                	mov    %esp,%ebp
  801029:	57                   	push   %edi
  80102a:	56                   	push   %esi
  80102b:	53                   	push   %ebx
  80102c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80102f:	8b 55 08             	mov    0x8(%ebp),%edx
  801032:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801035:	b8 05 00 00 00       	mov    $0x5,%eax
  80103a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80103d:	8b 7d 14             	mov    0x14(%ebp),%edi
  801040:	8b 75 18             	mov    0x18(%ebp),%esi
  801043:	cd 30                	int    $0x30
	if(check && ret > 0)
  801045:	85 c0                	test   %eax,%eax
  801047:	7f 08                	jg     801051 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801049:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80104c:	5b                   	pop    %ebx
  80104d:	5e                   	pop    %esi
  80104e:	5f                   	pop    %edi
  80104f:	5d                   	pop    %ebp
  801050:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801051:	83 ec 0c             	sub    $0xc,%esp
  801054:	50                   	push   %eax
  801055:	6a 05                	push   $0x5
  801057:	68 ff 2e 80 00       	push   $0x802eff
  80105c:	6a 23                	push   $0x23
  80105e:	68 1c 2f 80 00       	push   $0x802f1c
  801063:	e8 88 f4 ff ff       	call   8004f0 <_panic>

00801068 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801068:	55                   	push   %ebp
  801069:	89 e5                	mov    %esp,%ebp
  80106b:	57                   	push   %edi
  80106c:	56                   	push   %esi
  80106d:	53                   	push   %ebx
  80106e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801071:	bb 00 00 00 00       	mov    $0x0,%ebx
  801076:	8b 55 08             	mov    0x8(%ebp),%edx
  801079:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80107c:	b8 06 00 00 00       	mov    $0x6,%eax
  801081:	89 df                	mov    %ebx,%edi
  801083:	89 de                	mov    %ebx,%esi
  801085:	cd 30                	int    $0x30
	if(check && ret > 0)
  801087:	85 c0                	test   %eax,%eax
  801089:	7f 08                	jg     801093 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80108b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80108e:	5b                   	pop    %ebx
  80108f:	5e                   	pop    %esi
  801090:	5f                   	pop    %edi
  801091:	5d                   	pop    %ebp
  801092:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801093:	83 ec 0c             	sub    $0xc,%esp
  801096:	50                   	push   %eax
  801097:	6a 06                	push   $0x6
  801099:	68 ff 2e 80 00       	push   $0x802eff
  80109e:	6a 23                	push   $0x23
  8010a0:	68 1c 2f 80 00       	push   $0x802f1c
  8010a5:	e8 46 f4 ff ff       	call   8004f0 <_panic>

008010aa <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8010aa:	55                   	push   %ebp
  8010ab:	89 e5                	mov    %esp,%ebp
  8010ad:	57                   	push   %edi
  8010ae:	56                   	push   %esi
  8010af:	53                   	push   %ebx
  8010b0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8010b3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8010bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010be:	b8 08 00 00 00       	mov    $0x8,%eax
  8010c3:	89 df                	mov    %ebx,%edi
  8010c5:	89 de                	mov    %ebx,%esi
  8010c7:	cd 30                	int    $0x30
	if(check && ret > 0)
  8010c9:	85 c0                	test   %eax,%eax
  8010cb:	7f 08                	jg     8010d5 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8010cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d0:	5b                   	pop    %ebx
  8010d1:	5e                   	pop    %esi
  8010d2:	5f                   	pop    %edi
  8010d3:	5d                   	pop    %ebp
  8010d4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8010d5:	83 ec 0c             	sub    $0xc,%esp
  8010d8:	50                   	push   %eax
  8010d9:	6a 08                	push   $0x8
  8010db:	68 ff 2e 80 00       	push   $0x802eff
  8010e0:	6a 23                	push   $0x23
  8010e2:	68 1c 2f 80 00       	push   $0x802f1c
  8010e7:	e8 04 f4 ff ff       	call   8004f0 <_panic>

008010ec <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8010ec:	55                   	push   %ebp
  8010ed:	89 e5                	mov    %esp,%ebp
  8010ef:	57                   	push   %edi
  8010f0:	56                   	push   %esi
  8010f1:	53                   	push   %ebx
  8010f2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8010f5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8010fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801100:	b8 09 00 00 00       	mov    $0x9,%eax
  801105:	89 df                	mov    %ebx,%edi
  801107:	89 de                	mov    %ebx,%esi
  801109:	cd 30                	int    $0x30
	if(check && ret > 0)
  80110b:	85 c0                	test   %eax,%eax
  80110d:	7f 08                	jg     801117 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80110f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801112:	5b                   	pop    %ebx
  801113:	5e                   	pop    %esi
  801114:	5f                   	pop    %edi
  801115:	5d                   	pop    %ebp
  801116:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801117:	83 ec 0c             	sub    $0xc,%esp
  80111a:	50                   	push   %eax
  80111b:	6a 09                	push   $0x9
  80111d:	68 ff 2e 80 00       	push   $0x802eff
  801122:	6a 23                	push   $0x23
  801124:	68 1c 2f 80 00       	push   $0x802f1c
  801129:	e8 c2 f3 ff ff       	call   8004f0 <_panic>

0080112e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80112e:	55                   	push   %ebp
  80112f:	89 e5                	mov    %esp,%ebp
  801131:	57                   	push   %edi
  801132:	56                   	push   %esi
  801133:	53                   	push   %ebx
  801134:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801137:	bb 00 00 00 00       	mov    $0x0,%ebx
  80113c:	8b 55 08             	mov    0x8(%ebp),%edx
  80113f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801142:	b8 0a 00 00 00       	mov    $0xa,%eax
  801147:	89 df                	mov    %ebx,%edi
  801149:	89 de                	mov    %ebx,%esi
  80114b:	cd 30                	int    $0x30
	if(check && ret > 0)
  80114d:	85 c0                	test   %eax,%eax
  80114f:	7f 08                	jg     801159 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801151:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801154:	5b                   	pop    %ebx
  801155:	5e                   	pop    %esi
  801156:	5f                   	pop    %edi
  801157:	5d                   	pop    %ebp
  801158:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801159:	83 ec 0c             	sub    $0xc,%esp
  80115c:	50                   	push   %eax
  80115d:	6a 0a                	push   $0xa
  80115f:	68 ff 2e 80 00       	push   $0x802eff
  801164:	6a 23                	push   $0x23
  801166:	68 1c 2f 80 00       	push   $0x802f1c
  80116b:	e8 80 f3 ff ff       	call   8004f0 <_panic>

00801170 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801170:	55                   	push   %ebp
  801171:	89 e5                	mov    %esp,%ebp
  801173:	57                   	push   %edi
  801174:	56                   	push   %esi
  801175:	53                   	push   %ebx
	asm volatile("int %1\n"
  801176:	8b 55 08             	mov    0x8(%ebp),%edx
  801179:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80117c:	b8 0c 00 00 00       	mov    $0xc,%eax
  801181:	be 00 00 00 00       	mov    $0x0,%esi
  801186:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801189:	8b 7d 14             	mov    0x14(%ebp),%edi
  80118c:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80118e:	5b                   	pop    %ebx
  80118f:	5e                   	pop    %esi
  801190:	5f                   	pop    %edi
  801191:	5d                   	pop    %ebp
  801192:	c3                   	ret    

00801193 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801193:	55                   	push   %ebp
  801194:	89 e5                	mov    %esp,%ebp
  801196:	57                   	push   %edi
  801197:	56                   	push   %esi
  801198:	53                   	push   %ebx
  801199:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80119c:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8011a4:	b8 0d 00 00 00       	mov    $0xd,%eax
  8011a9:	89 cb                	mov    %ecx,%ebx
  8011ab:	89 cf                	mov    %ecx,%edi
  8011ad:	89 ce                	mov    %ecx,%esi
  8011af:	cd 30                	int    $0x30
	if(check && ret > 0)
  8011b1:	85 c0                	test   %eax,%eax
  8011b3:	7f 08                	jg     8011bd <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8011b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b8:	5b                   	pop    %ebx
  8011b9:	5e                   	pop    %esi
  8011ba:	5f                   	pop    %edi
  8011bb:	5d                   	pop    %ebp
  8011bc:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8011bd:	83 ec 0c             	sub    $0xc,%esp
  8011c0:	50                   	push   %eax
  8011c1:	6a 0d                	push   $0xd
  8011c3:	68 ff 2e 80 00       	push   $0x802eff
  8011c8:	6a 23                	push   $0x23
  8011ca:	68 1c 2f 80 00       	push   $0x802f1c
  8011cf:	e8 1c f3 ff ff       	call   8004f0 <_panic>

008011d4 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8011d4:	55                   	push   %ebp
  8011d5:	89 e5                	mov    %esp,%ebp
  8011d7:	56                   	push   %esi
  8011d8:	53                   	push   %ebx
  8011d9:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8011dc:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if((err&FEC_WR)==0 || (uvpt[PGNUM(addr)]&(PTE_W|PTE_COW))==0){
  8011de:	8b 40 04             	mov    0x4(%eax),%eax
  8011e1:	83 e0 02             	and    $0x2,%eax
  8011e4:	0f 84 82 00 00 00    	je     80126c <pgfault+0x98>
  8011ea:	89 da                	mov    %ebx,%edx
  8011ec:	c1 ea 0c             	shr    $0xc,%edx
  8011ef:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011f6:	f7 c2 02 08 00 00    	test   $0x802,%edx
  8011fc:	74 6e                	je     80126c <pgfault+0x98>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        envid_t envid = sys_getenvid();
  8011fe:	e8 a2 fd ff ff       	call   800fa5 <sys_getenvid>
  801203:	89 c6                	mov    %eax,%esi
	r = sys_page_alloc(envid,(void *)PFTEMP,PTE_P|PTE_W|PTE_U);
  801205:	83 ec 04             	sub    $0x4,%esp
  801208:	6a 07                	push   $0x7
  80120a:	68 00 f0 7f 00       	push   $0x7ff000
  80120f:	50                   	push   %eax
  801210:	e8 ce fd ff ff       	call   800fe3 <sys_page_alloc>
	if(r<0) panic("pgfault:page allocation failed %e",r);
  801215:	83 c4 10             	add    $0x10,%esp
  801218:	85 c0                	test   %eax,%eax
  80121a:	78 72                	js     80128e <pgfault+0xba>

	addr = ROUNDDOWN(addr,PGSIZE);
  80121c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy((void *)PFTEMP,(const void *)addr,PGSIZE);
  801222:	83 ec 04             	sub    $0x4,%esp
  801225:	68 00 10 00 00       	push   $0x1000
  80122a:	53                   	push   %ebx
  80122b:	68 00 f0 7f 00       	push   $0x7ff000
  801230:	e8 ab fb ff ff       	call   800de0 <memcpy>

	if(sys_page_map(envid,(void *)PFTEMP, envid,addr,PTE_P|PTE_W|PTE_U)<0)
  801235:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80123c:	53                   	push   %ebx
  80123d:	56                   	push   %esi
  80123e:	68 00 f0 7f 00       	push   $0x7ff000
  801243:	56                   	push   %esi
  801244:	e8 dd fd ff ff       	call   801026 <sys_page_map>
  801249:	83 c4 20             	add    $0x20,%esp
  80124c:	85 c0                	test   %eax,%eax
  80124e:	78 50                	js     8012a0 <pgfault+0xcc>
		panic("pgfault:page map failed\n");
	if(sys_page_unmap(envid,(void *)PFTEMP)<0)
  801250:	83 ec 08             	sub    $0x8,%esp
  801253:	68 00 f0 7f 00       	push   $0x7ff000
  801258:	56                   	push   %esi
  801259:	e8 0a fe ff ff       	call   801068 <sys_page_unmap>
  80125e:	83 c4 10             	add    $0x10,%esp
  801261:	85 c0                	test   %eax,%eax
  801263:	78 4f                	js     8012b4 <pgfault+0xe0>
		panic("pgfault: page upmap failed\n");
       //	panic("pgfault not implemented");
}
  801265:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801268:	5b                   	pop    %ebx
  801269:	5e                   	pop    %esi
  80126a:	5d                   	pop    %ebp
  80126b:	c3                   	ret    
		cprintf("Where is the error %d\n",err&FEC_WR);
  80126c:	83 ec 08             	sub    $0x8,%esp
  80126f:	50                   	push   %eax
  801270:	68 2a 2f 80 00       	push   $0x802f2a
  801275:	e8 51 f3 ff ff       	call   8005cb <cprintf>
		panic("pgfault:invalid user trap");
  80127a:	83 c4 0c             	add    $0xc,%esp
  80127d:	68 41 2f 80 00       	push   $0x802f41
  801282:	6a 1e                	push   $0x1e
  801284:	68 5b 2f 80 00       	push   $0x802f5b
  801289:	e8 62 f2 ff ff       	call   8004f0 <_panic>
	if(r<0) panic("pgfault:page allocation failed %e",r);
  80128e:	50                   	push   %eax
  80128f:	68 48 30 80 00       	push   $0x803048
  801294:	6a 29                	push   $0x29
  801296:	68 5b 2f 80 00       	push   $0x802f5b
  80129b:	e8 50 f2 ff ff       	call   8004f0 <_panic>
		panic("pgfault:page map failed\n");
  8012a0:	83 ec 04             	sub    $0x4,%esp
  8012a3:	68 66 2f 80 00       	push   $0x802f66
  8012a8:	6a 2f                	push   $0x2f
  8012aa:	68 5b 2f 80 00       	push   $0x802f5b
  8012af:	e8 3c f2 ff ff       	call   8004f0 <_panic>
		panic("pgfault: page upmap failed\n");
  8012b4:	83 ec 04             	sub    $0x4,%esp
  8012b7:	68 7f 2f 80 00       	push   $0x802f7f
  8012bc:	6a 31                	push   $0x31
  8012be:	68 5b 2f 80 00       	push   $0x802f5b
  8012c3:	e8 28 f2 ff ff       	call   8004f0 <_panic>

008012c8 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8012c8:	55                   	push   %ebp
  8012c9:	89 e5                	mov    %esp,%ebp
  8012cb:	57                   	push   %edi
  8012cc:	56                   	push   %esi
  8012cd:	53                   	push   %ebx
  8012ce:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	set_pgfault_handler(pgfault);
  8012d1:	68 d4 11 80 00       	push   $0x8011d4
  8012d6:	e8 8a 13 00 00       	call   802665 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8012db:	b8 07 00 00 00       	mov    $0x7,%eax
  8012e0:	cd 30                	int    $0x30
  8012e2:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8012e5:	89 45 e0             	mov    %eax,-0x20(%ebp)
       
	envid_t envid = sys_exofork();
	uintptr_t addr;
  
	if(envid<0) panic("sys_exofork failed\n");
  8012e8:	83 c4 10             	add    $0x10,%esp
  8012eb:	85 c0                	test   %eax,%eax
  8012ed:	78 27                	js     801316 <fork+0x4e>
	if(envid==0){
	  thisenv = &envs[ENVX(sys_getenvid())];
	  return 0;
	}

	for(addr=(uintptr_t)UTEXT; addr<USTACKTOP;addr+=PGSIZE){
  8012ef:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if(envid==0){
  8012f4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8012f8:	75 5e                	jne    801358 <fork+0x90>
	  thisenv = &envs[ENVX(sys_getenvid())];
  8012fa:	e8 a6 fc ff ff       	call   800fa5 <sys_getenvid>
  8012ff:	25 ff 03 00 00       	and    $0x3ff,%eax
  801304:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801307:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80130c:	a3 04 50 80 00       	mov    %eax,0x805004
	  return 0;
  801311:	e9 fc 00 00 00       	jmp    801412 <fork+0x14a>
	if(envid<0) panic("sys_exofork failed\n");
  801316:	83 ec 04             	sub    $0x4,%esp
  801319:	68 9b 2f 80 00       	push   $0x802f9b
  80131e:	6a 77                	push   $0x77
  801320:	68 5b 2f 80 00       	push   $0x802f5b
  801325:	e8 c6 f1 ff ff       	call   8004f0 <_panic>
          if((r=sys_page_map(parent_envid,va,envid,va,uvpt[pn]&PTE_SYSCALL))<0)
  80132a:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801331:	83 ec 0c             	sub    $0xc,%esp
  801334:	25 07 0e 00 00       	and    $0xe07,%eax
  801339:	50                   	push   %eax
  80133a:	57                   	push   %edi
  80133b:	ff 75 e0             	pushl  -0x20(%ebp)
  80133e:	57                   	push   %edi
  80133f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801342:	e8 df fc ff ff       	call   801026 <sys_page_map>
  801347:	83 c4 20             	add    $0x20,%esp
	for(addr=(uintptr_t)UTEXT; addr<USTACKTOP;addr+=PGSIZE){
  80134a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801350:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801356:	74 76                	je     8013ce <fork+0x106>
	   if((uvpd[PDX(addr)]&PTE_P) && uvpt[PGNUM(addr)] & PTE_P)
  801358:	89 d8                	mov    %ebx,%eax
  80135a:	c1 e8 16             	shr    $0x16,%eax
  80135d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801364:	a8 01                	test   $0x1,%al
  801366:	74 e2                	je     80134a <fork+0x82>
  801368:	89 de                	mov    %ebx,%esi
  80136a:	c1 ee 0c             	shr    $0xc,%esi
  80136d:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801374:	a8 01                	test   $0x1,%al
  801376:	74 d2                	je     80134a <fork+0x82>
        envid_t parent_envid = sys_getenvid();
  801378:	e8 28 fc ff ff       	call   800fa5 <sys_getenvid>
  80137d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	void *va = (void *)(pn*PGSIZE);
  801380:	89 f7                	mov    %esi,%edi
  801382:	c1 e7 0c             	shl    $0xc,%edi
        if(uvpt[pn] & PTE_SHARE){
  801385:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80138c:	f6 c4 04             	test   $0x4,%ah
  80138f:	75 99                	jne    80132a <fork+0x62>
	if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)){
  801391:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801398:	a8 02                	test   $0x2,%al
  80139a:	0f 85 ed 00 00 00    	jne    80148d <fork+0x1c5>
  8013a0:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8013a7:	f6 c4 08             	test   $0x8,%ah
  8013aa:	0f 85 dd 00 00 00    	jne    80148d <fork+0x1c5>
	 if((r=sys_page_map(parent_envid,va,envid,va,perm))<0)
  8013b0:	83 ec 0c             	sub    $0xc,%esp
  8013b3:	6a 05                	push   $0x5
  8013b5:	57                   	push   %edi
  8013b6:	ff 75 e0             	pushl  -0x20(%ebp)
  8013b9:	57                   	push   %edi
  8013ba:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013bd:	e8 64 fc ff ff       	call   801026 <sys_page_map>
  8013c2:	83 c4 20             	add    $0x20,%esp
  8013c5:	85 c0                	test   %eax,%eax
  8013c7:	79 81                	jns    80134a <fork+0x82>
  8013c9:	e9 db 00 00 00       	jmp    8014a9 <fork+0x1e1>
		   duppage(envid,PGNUM(addr));
	}
        
	int r;
	if((r=sys_page_alloc(envid,(void *)UXSTACKTOP-PGSIZE,PTE_U|PTE_P|PTE_W))<0)
  8013ce:	83 ec 04             	sub    $0x4,%esp
  8013d1:	6a 07                	push   $0x7
  8013d3:	68 00 f0 bf ee       	push   $0xeebff000
  8013d8:	ff 75 dc             	pushl  -0x24(%ebp)
  8013db:	e8 03 fc ff ff       	call   800fe3 <sys_page_alloc>
  8013e0:	83 c4 10             	add    $0x10,%esp
  8013e3:	85 c0                	test   %eax,%eax
  8013e5:	78 36                	js     80141d <fork+0x155>
		panic("fork:page alloc failed %e\n",r);

	extern void _pgfault_upcall();
	if((r = sys_env_set_pgfault_upcall(envid,_pgfault_upcall)))
  8013e7:	83 ec 08             	sub    $0x8,%esp
  8013ea:	68 ca 26 80 00       	push   $0x8026ca
  8013ef:	ff 75 dc             	pushl  -0x24(%ebp)
  8013f2:	e8 37 fd ff ff       	call   80112e <sys_env_set_pgfault_upcall>
  8013f7:	83 c4 10             	add    $0x10,%esp
  8013fa:	85 c0                	test   %eax,%eax
  8013fc:	75 34                	jne    801432 <fork+0x16a>
		panic("fork:set upcall failed %e\n",r);
	if((r = sys_env_set_status(envid,ENV_RUNNABLE))<0)
  8013fe:	83 ec 08             	sub    $0x8,%esp
  801401:	6a 02                	push   $0x2
  801403:	ff 75 dc             	pushl  -0x24(%ebp)
  801406:	e8 9f fc ff ff       	call   8010aa <sys_env_set_status>
  80140b:	83 c4 10             	add    $0x10,%esp
  80140e:	85 c0                	test   %eax,%eax
  801410:	78 35                	js     801447 <fork+0x17f>
		panic("fork:set status failed %e\n",r);
	//cprintf("forkid= %d\n", envid);
	return envid;
       	
}
  801412:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801415:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801418:	5b                   	pop    %ebx
  801419:	5e                   	pop    %esi
  80141a:	5f                   	pop    %edi
  80141b:	5d                   	pop    %ebp
  80141c:	c3                   	ret    
		panic("fork:page alloc failed %e\n",r);
  80141d:	50                   	push   %eax
  80141e:	68 df 2f 80 00       	push   $0x802fdf
  801423:	68 84 00 00 00       	push   $0x84
  801428:	68 5b 2f 80 00       	push   $0x802f5b
  80142d:	e8 be f0 ff ff       	call   8004f0 <_panic>
		panic("fork:set upcall failed %e\n",r);
  801432:	50                   	push   %eax
  801433:	68 fa 2f 80 00       	push   $0x802ffa
  801438:	68 88 00 00 00       	push   $0x88
  80143d:	68 5b 2f 80 00       	push   $0x802f5b
  801442:	e8 a9 f0 ff ff       	call   8004f0 <_panic>
		panic("fork:set status failed %e\n",r);
  801447:	50                   	push   %eax
  801448:	68 15 30 80 00       	push   $0x803015
  80144d:	68 8a 00 00 00       	push   $0x8a
  801452:	68 5b 2f 80 00       	push   $0x802f5b
  801457:	e8 94 f0 ff ff       	call   8004f0 <_panic>
		if( (r=sys_page_map(parent_envid,va,parent_envid,va,perm))<0){
  80145c:	83 ec 0c             	sub    $0xc,%esp
  80145f:	68 05 08 00 00       	push   $0x805
  801464:	57                   	push   %edi
  801465:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801468:	50                   	push   %eax
  801469:	57                   	push   %edi
  80146a:	50                   	push   %eax
  80146b:	e8 b6 fb ff ff       	call   801026 <sys_page_map>
  801470:	83 c4 20             	add    $0x20,%esp
  801473:	85 c0                	test   %eax,%eax
  801475:	0f 89 cf fe ff ff    	jns    80134a <fork+0x82>
		 panic("duppage:map02 failed %e",r);
  80147b:	50                   	push   %eax
  80147c:	68 c7 2f 80 00       	push   $0x802fc7
  801481:	6a 56                	push   $0x56
  801483:	68 5b 2f 80 00       	push   $0x802f5b
  801488:	e8 63 f0 ff ff       	call   8004f0 <_panic>
	 if((r=sys_page_map(parent_envid,va,envid,va,perm))<0)
  80148d:	83 ec 0c             	sub    $0xc,%esp
  801490:	68 05 08 00 00       	push   $0x805
  801495:	57                   	push   %edi
  801496:	ff 75 e0             	pushl  -0x20(%ebp)
  801499:	57                   	push   %edi
  80149a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80149d:	e8 84 fb ff ff       	call   801026 <sys_page_map>
  8014a2:	83 c4 20             	add    $0x20,%esp
  8014a5:	85 c0                	test   %eax,%eax
  8014a7:	79 b3                	jns    80145c <fork+0x194>
		 panic("duppage:map01 failed %e",r);
  8014a9:	50                   	push   %eax
  8014aa:	68 af 2f 80 00       	push   $0x802faf
  8014af:	6a 53                	push   $0x53
  8014b1:	68 5b 2f 80 00       	push   $0x802f5b
  8014b6:	e8 35 f0 ff ff       	call   8004f0 <_panic>

008014bb <sfork>:

// Challenge!
int
sfork(void)
{
  8014bb:	55                   	push   %ebp
  8014bc:	89 e5                	mov    %esp,%ebp
  8014be:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8014c1:	68 30 30 80 00       	push   $0x803030
  8014c6:	68 94 00 00 00       	push   $0x94
  8014cb:	68 5b 2f 80 00       	push   $0x802f5b
  8014d0:	e8 1b f0 ff ff       	call   8004f0 <_panic>

008014d5 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8014d5:	55                   	push   %ebp
  8014d6:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8014db:	05 00 00 00 30       	add    $0x30000000,%eax
  8014e0:	c1 e8 0c             	shr    $0xc,%eax
}
  8014e3:	5d                   	pop    %ebp
  8014e4:	c3                   	ret    

008014e5 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8014e5:	55                   	push   %ebp
  8014e6:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8014eb:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8014f0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8014f5:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8014fa:	5d                   	pop    %ebp
  8014fb:	c3                   	ret    

008014fc <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8014fc:	55                   	push   %ebp
  8014fd:	89 e5                	mov    %esp,%ebp
  8014ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801502:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801507:	89 c2                	mov    %eax,%edx
  801509:	c1 ea 16             	shr    $0x16,%edx
  80150c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801513:	f6 c2 01             	test   $0x1,%dl
  801516:	74 2a                	je     801542 <fd_alloc+0x46>
  801518:	89 c2                	mov    %eax,%edx
  80151a:	c1 ea 0c             	shr    $0xc,%edx
  80151d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801524:	f6 c2 01             	test   $0x1,%dl
  801527:	74 19                	je     801542 <fd_alloc+0x46>
  801529:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  80152e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801533:	75 d2                	jne    801507 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801535:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80153b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801540:	eb 07                	jmp    801549 <fd_alloc+0x4d>
			*fd_store = fd;
  801542:	89 01                	mov    %eax,(%ecx)
			return 0;
  801544:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801549:	5d                   	pop    %ebp
  80154a:	c3                   	ret    

0080154b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80154b:	55                   	push   %ebp
  80154c:	89 e5                	mov    %esp,%ebp
  80154e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801551:	83 f8 1f             	cmp    $0x1f,%eax
  801554:	77 36                	ja     80158c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801556:	c1 e0 0c             	shl    $0xc,%eax
  801559:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80155e:	89 c2                	mov    %eax,%edx
  801560:	c1 ea 16             	shr    $0x16,%edx
  801563:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80156a:	f6 c2 01             	test   $0x1,%dl
  80156d:	74 24                	je     801593 <fd_lookup+0x48>
  80156f:	89 c2                	mov    %eax,%edx
  801571:	c1 ea 0c             	shr    $0xc,%edx
  801574:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80157b:	f6 c2 01             	test   $0x1,%dl
  80157e:	74 1a                	je     80159a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801580:	8b 55 0c             	mov    0xc(%ebp),%edx
  801583:	89 02                	mov    %eax,(%edx)
	return 0;
  801585:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80158a:	5d                   	pop    %ebp
  80158b:	c3                   	ret    
		return -E_INVAL;
  80158c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801591:	eb f7                	jmp    80158a <fd_lookup+0x3f>
		return -E_INVAL;
  801593:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801598:	eb f0                	jmp    80158a <fd_lookup+0x3f>
  80159a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80159f:	eb e9                	jmp    80158a <fd_lookup+0x3f>

008015a1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8015a1:	55                   	push   %ebp
  8015a2:	89 e5                	mov    %esp,%ebp
  8015a4:	83 ec 08             	sub    $0x8,%esp
  8015a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015aa:	ba e8 30 80 00       	mov    $0x8030e8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8015af:	b8 20 40 80 00       	mov    $0x804020,%eax
		if (devtab[i]->dev_id == dev_id) {
  8015b4:	39 08                	cmp    %ecx,(%eax)
  8015b6:	74 33                	je     8015eb <dev_lookup+0x4a>
  8015b8:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  8015bb:	8b 02                	mov    (%edx),%eax
  8015bd:	85 c0                	test   %eax,%eax
  8015bf:	75 f3                	jne    8015b4 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8015c1:	a1 04 50 80 00       	mov    0x805004,%eax
  8015c6:	8b 40 48             	mov    0x48(%eax),%eax
  8015c9:	83 ec 04             	sub    $0x4,%esp
  8015cc:	51                   	push   %ecx
  8015cd:	50                   	push   %eax
  8015ce:	68 6c 30 80 00       	push   $0x80306c
  8015d3:	e8 f3 ef ff ff       	call   8005cb <cprintf>
	*dev = 0;
  8015d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015db:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8015e1:	83 c4 10             	add    $0x10,%esp
  8015e4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8015e9:	c9                   	leave  
  8015ea:	c3                   	ret    
			*dev = devtab[i];
  8015eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015ee:	89 01                	mov    %eax,(%ecx)
			return 0;
  8015f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8015f5:	eb f2                	jmp    8015e9 <dev_lookup+0x48>

008015f7 <fd_close>:
{
  8015f7:	55                   	push   %ebp
  8015f8:	89 e5                	mov    %esp,%ebp
  8015fa:	57                   	push   %edi
  8015fb:	56                   	push   %esi
  8015fc:	53                   	push   %ebx
  8015fd:	83 ec 1c             	sub    $0x1c,%esp
  801600:	8b 75 08             	mov    0x8(%ebp),%esi
  801603:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801606:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801609:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80160a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801610:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801613:	50                   	push   %eax
  801614:	e8 32 ff ff ff       	call   80154b <fd_lookup>
  801619:	89 c3                	mov    %eax,%ebx
  80161b:	83 c4 08             	add    $0x8,%esp
  80161e:	85 c0                	test   %eax,%eax
  801620:	78 05                	js     801627 <fd_close+0x30>
	    || fd != fd2)
  801622:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801625:	74 16                	je     80163d <fd_close+0x46>
		return (must_exist ? r : 0);
  801627:	89 f8                	mov    %edi,%eax
  801629:	84 c0                	test   %al,%al
  80162b:	b8 00 00 00 00       	mov    $0x0,%eax
  801630:	0f 44 d8             	cmove  %eax,%ebx
}
  801633:	89 d8                	mov    %ebx,%eax
  801635:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801638:	5b                   	pop    %ebx
  801639:	5e                   	pop    %esi
  80163a:	5f                   	pop    %edi
  80163b:	5d                   	pop    %ebp
  80163c:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80163d:	83 ec 08             	sub    $0x8,%esp
  801640:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801643:	50                   	push   %eax
  801644:	ff 36                	pushl  (%esi)
  801646:	e8 56 ff ff ff       	call   8015a1 <dev_lookup>
  80164b:	89 c3                	mov    %eax,%ebx
  80164d:	83 c4 10             	add    $0x10,%esp
  801650:	85 c0                	test   %eax,%eax
  801652:	78 15                	js     801669 <fd_close+0x72>
		if (dev->dev_close)
  801654:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801657:	8b 40 10             	mov    0x10(%eax),%eax
  80165a:	85 c0                	test   %eax,%eax
  80165c:	74 1b                	je     801679 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  80165e:	83 ec 0c             	sub    $0xc,%esp
  801661:	56                   	push   %esi
  801662:	ff d0                	call   *%eax
  801664:	89 c3                	mov    %eax,%ebx
  801666:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801669:	83 ec 08             	sub    $0x8,%esp
  80166c:	56                   	push   %esi
  80166d:	6a 00                	push   $0x0
  80166f:	e8 f4 f9 ff ff       	call   801068 <sys_page_unmap>
	return r;
  801674:	83 c4 10             	add    $0x10,%esp
  801677:	eb ba                	jmp    801633 <fd_close+0x3c>
			r = 0;
  801679:	bb 00 00 00 00       	mov    $0x0,%ebx
  80167e:	eb e9                	jmp    801669 <fd_close+0x72>

00801680 <close>:

int
close(int fdnum)
{
  801680:	55                   	push   %ebp
  801681:	89 e5                	mov    %esp,%ebp
  801683:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801686:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801689:	50                   	push   %eax
  80168a:	ff 75 08             	pushl  0x8(%ebp)
  80168d:	e8 b9 fe ff ff       	call   80154b <fd_lookup>
  801692:	83 c4 08             	add    $0x8,%esp
  801695:	85 c0                	test   %eax,%eax
  801697:	78 10                	js     8016a9 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801699:	83 ec 08             	sub    $0x8,%esp
  80169c:	6a 01                	push   $0x1
  80169e:	ff 75 f4             	pushl  -0xc(%ebp)
  8016a1:	e8 51 ff ff ff       	call   8015f7 <fd_close>
  8016a6:	83 c4 10             	add    $0x10,%esp
}
  8016a9:	c9                   	leave  
  8016aa:	c3                   	ret    

008016ab <close_all>:

void
close_all(void)
{
  8016ab:	55                   	push   %ebp
  8016ac:	89 e5                	mov    %esp,%ebp
  8016ae:	53                   	push   %ebx
  8016af:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8016b2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8016b7:	83 ec 0c             	sub    $0xc,%esp
  8016ba:	53                   	push   %ebx
  8016bb:	e8 c0 ff ff ff       	call   801680 <close>
	for (i = 0; i < MAXFD; i++)
  8016c0:	83 c3 01             	add    $0x1,%ebx
  8016c3:	83 c4 10             	add    $0x10,%esp
  8016c6:	83 fb 20             	cmp    $0x20,%ebx
  8016c9:	75 ec                	jne    8016b7 <close_all+0xc>
}
  8016cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ce:	c9                   	leave  
  8016cf:	c3                   	ret    

008016d0 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8016d0:	55                   	push   %ebp
  8016d1:	89 e5                	mov    %esp,%ebp
  8016d3:	57                   	push   %edi
  8016d4:	56                   	push   %esi
  8016d5:	53                   	push   %ebx
  8016d6:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8016d9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016dc:	50                   	push   %eax
  8016dd:	ff 75 08             	pushl  0x8(%ebp)
  8016e0:	e8 66 fe ff ff       	call   80154b <fd_lookup>
  8016e5:	89 c3                	mov    %eax,%ebx
  8016e7:	83 c4 08             	add    $0x8,%esp
  8016ea:	85 c0                	test   %eax,%eax
  8016ec:	0f 88 81 00 00 00    	js     801773 <dup+0xa3>
		return r;
	close(newfdnum);
  8016f2:	83 ec 0c             	sub    $0xc,%esp
  8016f5:	ff 75 0c             	pushl  0xc(%ebp)
  8016f8:	e8 83 ff ff ff       	call   801680 <close>

	newfd = INDEX2FD(newfdnum);
  8016fd:	8b 75 0c             	mov    0xc(%ebp),%esi
  801700:	c1 e6 0c             	shl    $0xc,%esi
  801703:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801709:	83 c4 04             	add    $0x4,%esp
  80170c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80170f:	e8 d1 fd ff ff       	call   8014e5 <fd2data>
  801714:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801716:	89 34 24             	mov    %esi,(%esp)
  801719:	e8 c7 fd ff ff       	call   8014e5 <fd2data>
  80171e:	83 c4 10             	add    $0x10,%esp
  801721:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801723:	89 d8                	mov    %ebx,%eax
  801725:	c1 e8 16             	shr    $0x16,%eax
  801728:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80172f:	a8 01                	test   $0x1,%al
  801731:	74 11                	je     801744 <dup+0x74>
  801733:	89 d8                	mov    %ebx,%eax
  801735:	c1 e8 0c             	shr    $0xc,%eax
  801738:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80173f:	f6 c2 01             	test   $0x1,%dl
  801742:	75 39                	jne    80177d <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801744:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801747:	89 d0                	mov    %edx,%eax
  801749:	c1 e8 0c             	shr    $0xc,%eax
  80174c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801753:	83 ec 0c             	sub    $0xc,%esp
  801756:	25 07 0e 00 00       	and    $0xe07,%eax
  80175b:	50                   	push   %eax
  80175c:	56                   	push   %esi
  80175d:	6a 00                	push   $0x0
  80175f:	52                   	push   %edx
  801760:	6a 00                	push   $0x0
  801762:	e8 bf f8 ff ff       	call   801026 <sys_page_map>
  801767:	89 c3                	mov    %eax,%ebx
  801769:	83 c4 20             	add    $0x20,%esp
  80176c:	85 c0                	test   %eax,%eax
  80176e:	78 31                	js     8017a1 <dup+0xd1>
		goto err;

	return newfdnum;
  801770:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801773:	89 d8                	mov    %ebx,%eax
  801775:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801778:	5b                   	pop    %ebx
  801779:	5e                   	pop    %esi
  80177a:	5f                   	pop    %edi
  80177b:	5d                   	pop    %ebp
  80177c:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80177d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801784:	83 ec 0c             	sub    $0xc,%esp
  801787:	25 07 0e 00 00       	and    $0xe07,%eax
  80178c:	50                   	push   %eax
  80178d:	57                   	push   %edi
  80178e:	6a 00                	push   $0x0
  801790:	53                   	push   %ebx
  801791:	6a 00                	push   $0x0
  801793:	e8 8e f8 ff ff       	call   801026 <sys_page_map>
  801798:	89 c3                	mov    %eax,%ebx
  80179a:	83 c4 20             	add    $0x20,%esp
  80179d:	85 c0                	test   %eax,%eax
  80179f:	79 a3                	jns    801744 <dup+0x74>
	sys_page_unmap(0, newfd);
  8017a1:	83 ec 08             	sub    $0x8,%esp
  8017a4:	56                   	push   %esi
  8017a5:	6a 00                	push   $0x0
  8017a7:	e8 bc f8 ff ff       	call   801068 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8017ac:	83 c4 08             	add    $0x8,%esp
  8017af:	57                   	push   %edi
  8017b0:	6a 00                	push   $0x0
  8017b2:	e8 b1 f8 ff ff       	call   801068 <sys_page_unmap>
	return r;
  8017b7:	83 c4 10             	add    $0x10,%esp
  8017ba:	eb b7                	jmp    801773 <dup+0xa3>

008017bc <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8017bc:	55                   	push   %ebp
  8017bd:	89 e5                	mov    %esp,%ebp
  8017bf:	53                   	push   %ebx
  8017c0:	83 ec 14             	sub    $0x14,%esp
  8017c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017c9:	50                   	push   %eax
  8017ca:	53                   	push   %ebx
  8017cb:	e8 7b fd ff ff       	call   80154b <fd_lookup>
  8017d0:	83 c4 08             	add    $0x8,%esp
  8017d3:	85 c0                	test   %eax,%eax
  8017d5:	78 3f                	js     801816 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017d7:	83 ec 08             	sub    $0x8,%esp
  8017da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017dd:	50                   	push   %eax
  8017de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017e1:	ff 30                	pushl  (%eax)
  8017e3:	e8 b9 fd ff ff       	call   8015a1 <dev_lookup>
  8017e8:	83 c4 10             	add    $0x10,%esp
  8017eb:	85 c0                	test   %eax,%eax
  8017ed:	78 27                	js     801816 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8017ef:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017f2:	8b 42 08             	mov    0x8(%edx),%eax
  8017f5:	83 e0 03             	and    $0x3,%eax
  8017f8:	83 f8 01             	cmp    $0x1,%eax
  8017fb:	74 1e                	je     80181b <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8017fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801800:	8b 40 08             	mov    0x8(%eax),%eax
  801803:	85 c0                	test   %eax,%eax
  801805:	74 35                	je     80183c <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801807:	83 ec 04             	sub    $0x4,%esp
  80180a:	ff 75 10             	pushl  0x10(%ebp)
  80180d:	ff 75 0c             	pushl  0xc(%ebp)
  801810:	52                   	push   %edx
  801811:	ff d0                	call   *%eax
  801813:	83 c4 10             	add    $0x10,%esp
}
  801816:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801819:	c9                   	leave  
  80181a:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80181b:	a1 04 50 80 00       	mov    0x805004,%eax
  801820:	8b 40 48             	mov    0x48(%eax),%eax
  801823:	83 ec 04             	sub    $0x4,%esp
  801826:	53                   	push   %ebx
  801827:	50                   	push   %eax
  801828:	68 ad 30 80 00       	push   $0x8030ad
  80182d:	e8 99 ed ff ff       	call   8005cb <cprintf>
		return -E_INVAL;
  801832:	83 c4 10             	add    $0x10,%esp
  801835:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80183a:	eb da                	jmp    801816 <read+0x5a>
		return -E_NOT_SUPP;
  80183c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801841:	eb d3                	jmp    801816 <read+0x5a>

00801843 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801843:	55                   	push   %ebp
  801844:	89 e5                	mov    %esp,%ebp
  801846:	57                   	push   %edi
  801847:	56                   	push   %esi
  801848:	53                   	push   %ebx
  801849:	83 ec 0c             	sub    $0xc,%esp
  80184c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80184f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801852:	bb 00 00 00 00       	mov    $0x0,%ebx
  801857:	39 f3                	cmp    %esi,%ebx
  801859:	73 25                	jae    801880 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80185b:	83 ec 04             	sub    $0x4,%esp
  80185e:	89 f0                	mov    %esi,%eax
  801860:	29 d8                	sub    %ebx,%eax
  801862:	50                   	push   %eax
  801863:	89 d8                	mov    %ebx,%eax
  801865:	03 45 0c             	add    0xc(%ebp),%eax
  801868:	50                   	push   %eax
  801869:	57                   	push   %edi
  80186a:	e8 4d ff ff ff       	call   8017bc <read>
		if (m < 0)
  80186f:	83 c4 10             	add    $0x10,%esp
  801872:	85 c0                	test   %eax,%eax
  801874:	78 08                	js     80187e <readn+0x3b>
			return m;
		if (m == 0)
  801876:	85 c0                	test   %eax,%eax
  801878:	74 06                	je     801880 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  80187a:	01 c3                	add    %eax,%ebx
  80187c:	eb d9                	jmp    801857 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80187e:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801880:	89 d8                	mov    %ebx,%eax
  801882:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801885:	5b                   	pop    %ebx
  801886:	5e                   	pop    %esi
  801887:	5f                   	pop    %edi
  801888:	5d                   	pop    %ebp
  801889:	c3                   	ret    

0080188a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80188a:	55                   	push   %ebp
  80188b:	89 e5                	mov    %esp,%ebp
  80188d:	53                   	push   %ebx
  80188e:	83 ec 14             	sub    $0x14,%esp
  801891:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801894:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801897:	50                   	push   %eax
  801898:	53                   	push   %ebx
  801899:	e8 ad fc ff ff       	call   80154b <fd_lookup>
  80189e:	83 c4 08             	add    $0x8,%esp
  8018a1:	85 c0                	test   %eax,%eax
  8018a3:	78 3a                	js     8018df <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018a5:	83 ec 08             	sub    $0x8,%esp
  8018a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018ab:	50                   	push   %eax
  8018ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018af:	ff 30                	pushl  (%eax)
  8018b1:	e8 eb fc ff ff       	call   8015a1 <dev_lookup>
  8018b6:	83 c4 10             	add    $0x10,%esp
  8018b9:	85 c0                	test   %eax,%eax
  8018bb:	78 22                	js     8018df <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018c0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018c4:	74 1e                	je     8018e4 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8018c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018c9:	8b 52 0c             	mov    0xc(%edx),%edx
  8018cc:	85 d2                	test   %edx,%edx
  8018ce:	74 35                	je     801905 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8018d0:	83 ec 04             	sub    $0x4,%esp
  8018d3:	ff 75 10             	pushl  0x10(%ebp)
  8018d6:	ff 75 0c             	pushl  0xc(%ebp)
  8018d9:	50                   	push   %eax
  8018da:	ff d2                	call   *%edx
  8018dc:	83 c4 10             	add    $0x10,%esp
}
  8018df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018e2:	c9                   	leave  
  8018e3:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8018e4:	a1 04 50 80 00       	mov    0x805004,%eax
  8018e9:	8b 40 48             	mov    0x48(%eax),%eax
  8018ec:	83 ec 04             	sub    $0x4,%esp
  8018ef:	53                   	push   %ebx
  8018f0:	50                   	push   %eax
  8018f1:	68 c9 30 80 00       	push   $0x8030c9
  8018f6:	e8 d0 ec ff ff       	call   8005cb <cprintf>
		return -E_INVAL;
  8018fb:	83 c4 10             	add    $0x10,%esp
  8018fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801903:	eb da                	jmp    8018df <write+0x55>
		return -E_NOT_SUPP;
  801905:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80190a:	eb d3                	jmp    8018df <write+0x55>

0080190c <seek>:

int
seek(int fdnum, off_t offset)
{
  80190c:	55                   	push   %ebp
  80190d:	89 e5                	mov    %esp,%ebp
  80190f:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801912:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801915:	50                   	push   %eax
  801916:	ff 75 08             	pushl  0x8(%ebp)
  801919:	e8 2d fc ff ff       	call   80154b <fd_lookup>
  80191e:	83 c4 08             	add    $0x8,%esp
  801921:	85 c0                	test   %eax,%eax
  801923:	78 0e                	js     801933 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801925:	8b 55 0c             	mov    0xc(%ebp),%edx
  801928:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80192b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80192e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801933:	c9                   	leave  
  801934:	c3                   	ret    

00801935 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801935:	55                   	push   %ebp
  801936:	89 e5                	mov    %esp,%ebp
  801938:	53                   	push   %ebx
  801939:	83 ec 14             	sub    $0x14,%esp
  80193c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80193f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801942:	50                   	push   %eax
  801943:	53                   	push   %ebx
  801944:	e8 02 fc ff ff       	call   80154b <fd_lookup>
  801949:	83 c4 08             	add    $0x8,%esp
  80194c:	85 c0                	test   %eax,%eax
  80194e:	78 37                	js     801987 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801950:	83 ec 08             	sub    $0x8,%esp
  801953:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801956:	50                   	push   %eax
  801957:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80195a:	ff 30                	pushl  (%eax)
  80195c:	e8 40 fc ff ff       	call   8015a1 <dev_lookup>
  801961:	83 c4 10             	add    $0x10,%esp
  801964:	85 c0                	test   %eax,%eax
  801966:	78 1f                	js     801987 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801968:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80196b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80196f:	74 1b                	je     80198c <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801971:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801974:	8b 52 18             	mov    0x18(%edx),%edx
  801977:	85 d2                	test   %edx,%edx
  801979:	74 32                	je     8019ad <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80197b:	83 ec 08             	sub    $0x8,%esp
  80197e:	ff 75 0c             	pushl  0xc(%ebp)
  801981:	50                   	push   %eax
  801982:	ff d2                	call   *%edx
  801984:	83 c4 10             	add    $0x10,%esp
}
  801987:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80198a:	c9                   	leave  
  80198b:	c3                   	ret    
			thisenv->env_id, fdnum);
  80198c:	a1 04 50 80 00       	mov    0x805004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801991:	8b 40 48             	mov    0x48(%eax),%eax
  801994:	83 ec 04             	sub    $0x4,%esp
  801997:	53                   	push   %ebx
  801998:	50                   	push   %eax
  801999:	68 8c 30 80 00       	push   $0x80308c
  80199e:	e8 28 ec ff ff       	call   8005cb <cprintf>
		return -E_INVAL;
  8019a3:	83 c4 10             	add    $0x10,%esp
  8019a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019ab:	eb da                	jmp    801987 <ftruncate+0x52>
		return -E_NOT_SUPP;
  8019ad:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8019b2:	eb d3                	jmp    801987 <ftruncate+0x52>

008019b4 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8019b4:	55                   	push   %ebp
  8019b5:	89 e5                	mov    %esp,%ebp
  8019b7:	53                   	push   %ebx
  8019b8:	83 ec 14             	sub    $0x14,%esp
  8019bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019be:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019c1:	50                   	push   %eax
  8019c2:	ff 75 08             	pushl  0x8(%ebp)
  8019c5:	e8 81 fb ff ff       	call   80154b <fd_lookup>
  8019ca:	83 c4 08             	add    $0x8,%esp
  8019cd:	85 c0                	test   %eax,%eax
  8019cf:	78 4b                	js     801a1c <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019d1:	83 ec 08             	sub    $0x8,%esp
  8019d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019d7:	50                   	push   %eax
  8019d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019db:	ff 30                	pushl  (%eax)
  8019dd:	e8 bf fb ff ff       	call   8015a1 <dev_lookup>
  8019e2:	83 c4 10             	add    $0x10,%esp
  8019e5:	85 c0                	test   %eax,%eax
  8019e7:	78 33                	js     801a1c <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  8019e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ec:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8019f0:	74 2f                	je     801a21 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8019f2:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8019f5:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8019fc:	00 00 00 
	stat->st_isdir = 0;
  8019ff:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a06:	00 00 00 
	stat->st_dev = dev;
  801a09:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a0f:	83 ec 08             	sub    $0x8,%esp
  801a12:	53                   	push   %ebx
  801a13:	ff 75 f0             	pushl  -0x10(%ebp)
  801a16:	ff 50 14             	call   *0x14(%eax)
  801a19:	83 c4 10             	add    $0x10,%esp
}
  801a1c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a1f:	c9                   	leave  
  801a20:	c3                   	ret    
		return -E_NOT_SUPP;
  801a21:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a26:	eb f4                	jmp    801a1c <fstat+0x68>

00801a28 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a28:	55                   	push   %ebp
  801a29:	89 e5                	mov    %esp,%ebp
  801a2b:	56                   	push   %esi
  801a2c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a2d:	83 ec 08             	sub    $0x8,%esp
  801a30:	6a 00                	push   $0x0
  801a32:	ff 75 08             	pushl  0x8(%ebp)
  801a35:	e8 e7 01 00 00       	call   801c21 <open>
  801a3a:	89 c3                	mov    %eax,%ebx
  801a3c:	83 c4 10             	add    $0x10,%esp
  801a3f:	85 c0                	test   %eax,%eax
  801a41:	78 1b                	js     801a5e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801a43:	83 ec 08             	sub    $0x8,%esp
  801a46:	ff 75 0c             	pushl  0xc(%ebp)
  801a49:	50                   	push   %eax
  801a4a:	e8 65 ff ff ff       	call   8019b4 <fstat>
  801a4f:	89 c6                	mov    %eax,%esi
	close(fd);
  801a51:	89 1c 24             	mov    %ebx,(%esp)
  801a54:	e8 27 fc ff ff       	call   801680 <close>
	return r;
  801a59:	83 c4 10             	add    $0x10,%esp
  801a5c:	89 f3                	mov    %esi,%ebx
}
  801a5e:	89 d8                	mov    %ebx,%eax
  801a60:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a63:	5b                   	pop    %ebx
  801a64:	5e                   	pop    %esi
  801a65:	5d                   	pop    %ebp
  801a66:	c3                   	ret    

00801a67 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a67:	55                   	push   %ebp
  801a68:	89 e5                	mov    %esp,%ebp
  801a6a:	56                   	push   %esi
  801a6b:	53                   	push   %ebx
  801a6c:	89 c6                	mov    %eax,%esi
  801a6e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801a70:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801a77:	74 27                	je     801aa0 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a79:	6a 07                	push   $0x7
  801a7b:	68 00 60 80 00       	push   $0x806000
  801a80:	56                   	push   %esi
  801a81:	ff 35 00 50 80 00    	pushl  0x805000
  801a87:	e8 da 0c 00 00       	call   802766 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a8c:	83 c4 0c             	add    $0xc,%esp
  801a8f:	6a 00                	push   $0x0
  801a91:	53                   	push   %ebx
  801a92:	6a 00                	push   $0x0
  801a94:	e8 58 0c 00 00       	call   8026f1 <ipc_recv>
}
  801a99:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a9c:	5b                   	pop    %ebx
  801a9d:	5e                   	pop    %esi
  801a9e:	5d                   	pop    %ebp
  801a9f:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801aa0:	83 ec 0c             	sub    $0xc,%esp
  801aa3:	6a 01                	push   $0x1
  801aa5:	e8 12 0d 00 00       	call   8027bc <ipc_find_env>
  801aaa:	a3 00 50 80 00       	mov    %eax,0x805000
  801aaf:	83 c4 10             	add    $0x10,%esp
  801ab2:	eb c5                	jmp    801a79 <fsipc+0x12>

00801ab4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801ab4:	55                   	push   %ebp
  801ab5:	89 e5                	mov    %esp,%ebp
  801ab7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801aba:	8b 45 08             	mov    0x8(%ebp),%eax
  801abd:	8b 40 0c             	mov    0xc(%eax),%eax
  801ac0:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801ac5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ac8:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801acd:	ba 00 00 00 00       	mov    $0x0,%edx
  801ad2:	b8 02 00 00 00       	mov    $0x2,%eax
  801ad7:	e8 8b ff ff ff       	call   801a67 <fsipc>
}
  801adc:	c9                   	leave  
  801add:	c3                   	ret    

00801ade <devfile_flush>:
{
  801ade:	55                   	push   %ebp
  801adf:	89 e5                	mov    %esp,%ebp
  801ae1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801ae4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae7:	8b 40 0c             	mov    0xc(%eax),%eax
  801aea:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801aef:	ba 00 00 00 00       	mov    $0x0,%edx
  801af4:	b8 06 00 00 00       	mov    $0x6,%eax
  801af9:	e8 69 ff ff ff       	call   801a67 <fsipc>
}
  801afe:	c9                   	leave  
  801aff:	c3                   	ret    

00801b00 <devfile_stat>:
{
  801b00:	55                   	push   %ebp
  801b01:	89 e5                	mov    %esp,%ebp
  801b03:	53                   	push   %ebx
  801b04:	83 ec 04             	sub    $0x4,%esp
  801b07:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b0a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b0d:	8b 40 0c             	mov    0xc(%eax),%eax
  801b10:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b15:	ba 00 00 00 00       	mov    $0x0,%edx
  801b1a:	b8 05 00 00 00       	mov    $0x5,%eax
  801b1f:	e8 43 ff ff ff       	call   801a67 <fsipc>
  801b24:	85 c0                	test   %eax,%eax
  801b26:	78 2c                	js     801b54 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b28:	83 ec 08             	sub    $0x8,%esp
  801b2b:	68 00 60 80 00       	push   $0x806000
  801b30:	53                   	push   %ebx
  801b31:	e8 b4 f0 ff ff       	call   800bea <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b36:	a1 80 60 80 00       	mov    0x806080,%eax
  801b3b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b41:	a1 84 60 80 00       	mov    0x806084,%eax
  801b46:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b4c:	83 c4 10             	add    $0x10,%esp
  801b4f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b54:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b57:	c9                   	leave  
  801b58:	c3                   	ret    

00801b59 <devfile_write>:
{
  801b59:	55                   	push   %ebp
  801b5a:	89 e5                	mov    %esp,%ebp
  801b5c:	83 ec 0c             	sub    $0xc,%esp
  801b5f:	8b 45 10             	mov    0x10(%ebp),%eax
  801b62:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801b67:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801b6c:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801b6f:	8b 55 08             	mov    0x8(%ebp),%edx
  801b72:	8b 52 0c             	mov    0xc(%edx),%edx
  801b75:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801b7b:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf,buf,n);
  801b80:	50                   	push   %eax
  801b81:	ff 75 0c             	pushl  0xc(%ebp)
  801b84:	68 08 60 80 00       	push   $0x806008
  801b89:	e8 ea f1 ff ff       	call   800d78 <memmove>
	if((r = fsipc(FSREQ_WRITE,NULL))<0)
  801b8e:	ba 00 00 00 00       	mov    $0x0,%edx
  801b93:	b8 04 00 00 00       	mov    $0x4,%eax
  801b98:	e8 ca fe ff ff       	call   801a67 <fsipc>
}
  801b9d:	c9                   	leave  
  801b9e:	c3                   	ret    

00801b9f <devfile_read>:
{
  801b9f:	55                   	push   %ebp
  801ba0:	89 e5                	mov    %esp,%ebp
  801ba2:	56                   	push   %esi
  801ba3:	53                   	push   %ebx
  801ba4:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801ba7:	8b 45 08             	mov    0x8(%ebp),%eax
  801baa:	8b 40 0c             	mov    0xc(%eax),%eax
  801bad:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801bb2:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801bb8:	ba 00 00 00 00       	mov    $0x0,%edx
  801bbd:	b8 03 00 00 00       	mov    $0x3,%eax
  801bc2:	e8 a0 fe ff ff       	call   801a67 <fsipc>
  801bc7:	89 c3                	mov    %eax,%ebx
  801bc9:	85 c0                	test   %eax,%eax
  801bcb:	78 1f                	js     801bec <devfile_read+0x4d>
	assert(r <= n);
  801bcd:	39 f0                	cmp    %esi,%eax
  801bcf:	77 24                	ja     801bf5 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801bd1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801bd6:	7f 33                	jg     801c0b <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801bd8:	83 ec 04             	sub    $0x4,%esp
  801bdb:	50                   	push   %eax
  801bdc:	68 00 60 80 00       	push   $0x806000
  801be1:	ff 75 0c             	pushl  0xc(%ebp)
  801be4:	e8 8f f1 ff ff       	call   800d78 <memmove>
	return r;
  801be9:	83 c4 10             	add    $0x10,%esp
}
  801bec:	89 d8                	mov    %ebx,%eax
  801bee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bf1:	5b                   	pop    %ebx
  801bf2:	5e                   	pop    %esi
  801bf3:	5d                   	pop    %ebp
  801bf4:	c3                   	ret    
	assert(r <= n);
  801bf5:	68 f8 30 80 00       	push   $0x8030f8
  801bfa:	68 ff 30 80 00       	push   $0x8030ff
  801bff:	6a 7c                	push   $0x7c
  801c01:	68 14 31 80 00       	push   $0x803114
  801c06:	e8 e5 e8 ff ff       	call   8004f0 <_panic>
	assert(r <= PGSIZE);
  801c0b:	68 1f 31 80 00       	push   $0x80311f
  801c10:	68 ff 30 80 00       	push   $0x8030ff
  801c15:	6a 7d                	push   $0x7d
  801c17:	68 14 31 80 00       	push   $0x803114
  801c1c:	e8 cf e8 ff ff       	call   8004f0 <_panic>

00801c21 <open>:
{
  801c21:	55                   	push   %ebp
  801c22:	89 e5                	mov    %esp,%ebp
  801c24:	56                   	push   %esi
  801c25:	53                   	push   %ebx
  801c26:	83 ec 1c             	sub    $0x1c,%esp
  801c29:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801c2c:	56                   	push   %esi
  801c2d:	e8 81 ef ff ff       	call   800bb3 <strlen>
  801c32:	83 c4 10             	add    $0x10,%esp
  801c35:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c3a:	7f 6c                	jg     801ca8 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801c3c:	83 ec 0c             	sub    $0xc,%esp
  801c3f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c42:	50                   	push   %eax
  801c43:	e8 b4 f8 ff ff       	call   8014fc <fd_alloc>
  801c48:	89 c3                	mov    %eax,%ebx
  801c4a:	83 c4 10             	add    $0x10,%esp
  801c4d:	85 c0                	test   %eax,%eax
  801c4f:	78 3c                	js     801c8d <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801c51:	83 ec 08             	sub    $0x8,%esp
  801c54:	56                   	push   %esi
  801c55:	68 00 60 80 00       	push   $0x806000
  801c5a:	e8 8b ef ff ff       	call   800bea <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c62:	a3 00 64 80 00       	mov    %eax,0x806400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c67:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c6a:	b8 01 00 00 00       	mov    $0x1,%eax
  801c6f:	e8 f3 fd ff ff       	call   801a67 <fsipc>
  801c74:	89 c3                	mov    %eax,%ebx
  801c76:	83 c4 10             	add    $0x10,%esp
  801c79:	85 c0                	test   %eax,%eax
  801c7b:	78 19                	js     801c96 <open+0x75>
	return fd2num(fd);
  801c7d:	83 ec 0c             	sub    $0xc,%esp
  801c80:	ff 75 f4             	pushl  -0xc(%ebp)
  801c83:	e8 4d f8 ff ff       	call   8014d5 <fd2num>
  801c88:	89 c3                	mov    %eax,%ebx
  801c8a:	83 c4 10             	add    $0x10,%esp
}
  801c8d:	89 d8                	mov    %ebx,%eax
  801c8f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c92:	5b                   	pop    %ebx
  801c93:	5e                   	pop    %esi
  801c94:	5d                   	pop    %ebp
  801c95:	c3                   	ret    
		fd_close(fd, 0);
  801c96:	83 ec 08             	sub    $0x8,%esp
  801c99:	6a 00                	push   $0x0
  801c9b:	ff 75 f4             	pushl  -0xc(%ebp)
  801c9e:	e8 54 f9 ff ff       	call   8015f7 <fd_close>
		return r;
  801ca3:	83 c4 10             	add    $0x10,%esp
  801ca6:	eb e5                	jmp    801c8d <open+0x6c>
		return -E_BAD_PATH;
  801ca8:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801cad:	eb de                	jmp    801c8d <open+0x6c>

00801caf <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801caf:	55                   	push   %ebp
  801cb0:	89 e5                	mov    %esp,%ebp
  801cb2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801cb5:	ba 00 00 00 00       	mov    $0x0,%edx
  801cba:	b8 08 00 00 00       	mov    $0x8,%eax
  801cbf:	e8 a3 fd ff ff       	call   801a67 <fsipc>
}
  801cc4:	c9                   	leave  
  801cc5:	c3                   	ret    

00801cc6 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801cc6:	55                   	push   %ebp
  801cc7:	89 e5                	mov    %esp,%ebp
  801cc9:	57                   	push   %edi
  801cca:	56                   	push   %esi
  801ccb:	53                   	push   %ebx
  801ccc:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801cd2:	6a 00                	push   $0x0
  801cd4:	ff 75 08             	pushl  0x8(%ebp)
  801cd7:	e8 45 ff ff ff       	call   801c21 <open>
  801cdc:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  801ce2:	83 c4 10             	add    $0x10,%esp
  801ce5:	85 c0                	test   %eax,%eax
  801ce7:	0f 88 40 03 00 00    	js     80202d <spawn+0x367>
  801ced:	89 c2                	mov    %eax,%edx
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801cef:	83 ec 04             	sub    $0x4,%esp
  801cf2:	68 00 02 00 00       	push   $0x200
  801cf7:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801cfd:	50                   	push   %eax
  801cfe:	52                   	push   %edx
  801cff:	e8 3f fb ff ff       	call   801843 <readn>
  801d04:	83 c4 10             	add    $0x10,%esp
  801d07:	3d 00 02 00 00       	cmp    $0x200,%eax
  801d0c:	75 5d                	jne    801d6b <spawn+0xa5>
	    || elf->e_magic != ELF_MAGIC) {
  801d0e:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801d15:	45 4c 46 
  801d18:	75 51                	jne    801d6b <spawn+0xa5>
  801d1a:	b8 07 00 00 00       	mov    $0x7,%eax
  801d1f:	cd 30                	int    $0x30
  801d21:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801d27:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801d2d:	85 c0                	test   %eax,%eax
  801d2f:	0f 88 6e 04 00 00    	js     8021a3 <spawn+0x4dd>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801d35:	25 ff 03 00 00       	and    $0x3ff,%eax
  801d3a:	6b f0 7c             	imul   $0x7c,%eax,%esi
  801d3d:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801d43:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801d49:	b9 11 00 00 00       	mov    $0x11,%ecx
  801d4e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801d50:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801d56:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801d5c:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  801d61:	be 00 00 00 00       	mov    $0x0,%esi
  801d66:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801d69:	eb 4b                	jmp    801db6 <spawn+0xf0>
		close(fd);
  801d6b:	83 ec 0c             	sub    $0xc,%esp
  801d6e:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801d74:	e8 07 f9 ff ff       	call   801680 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801d79:	83 c4 0c             	add    $0xc,%esp
  801d7c:	68 7f 45 4c 46       	push   $0x464c457f
  801d81:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801d87:	68 2b 31 80 00       	push   $0x80312b
  801d8c:	e8 3a e8 ff ff       	call   8005cb <cprintf>
		return -E_NOT_EXEC;
  801d91:	83 c4 10             	add    $0x10,%esp
  801d94:	c7 85 90 fd ff ff f2 	movl   $0xfffffff2,-0x270(%ebp)
  801d9b:	ff ff ff 
  801d9e:	e9 8a 02 00 00       	jmp    80202d <spawn+0x367>
		string_size += strlen(argv[argc]) + 1;
  801da3:	83 ec 0c             	sub    $0xc,%esp
  801da6:	50                   	push   %eax
  801da7:	e8 07 ee ff ff       	call   800bb3 <strlen>
  801dac:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  801db0:	83 c3 01             	add    $0x1,%ebx
  801db3:	83 c4 10             	add    $0x10,%esp
  801db6:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801dbd:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801dc0:	85 c0                	test   %eax,%eax
  801dc2:	75 df                	jne    801da3 <spawn+0xdd>
  801dc4:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801dca:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801dd0:	bf 00 10 40 00       	mov    $0x401000,%edi
  801dd5:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801dd7:	89 fa                	mov    %edi,%edx
  801dd9:	83 e2 fc             	and    $0xfffffffc,%edx
  801ddc:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801de3:	29 c2                	sub    %eax,%edx
  801de5:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801deb:	8d 42 f8             	lea    -0x8(%edx),%eax
  801dee:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801df3:	0f 86 bb 03 00 00    	jbe    8021b4 <spawn+0x4ee>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801df9:	83 ec 04             	sub    $0x4,%esp
  801dfc:	6a 07                	push   $0x7
  801dfe:	68 00 00 40 00       	push   $0x400000
  801e03:	6a 00                	push   $0x0
  801e05:	e8 d9 f1 ff ff       	call   800fe3 <sys_page_alloc>
  801e0a:	83 c4 10             	add    $0x10,%esp
  801e0d:	85 c0                	test   %eax,%eax
  801e0f:	0f 88 a4 03 00 00    	js     8021b9 <spawn+0x4f3>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801e15:	be 00 00 00 00       	mov    $0x0,%esi
  801e1a:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  801e20:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801e23:	eb 30                	jmp    801e55 <spawn+0x18f>
		argv_store[i] = UTEMP2USTACK(string_store);
  801e25:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801e2b:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801e31:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  801e34:	83 ec 08             	sub    $0x8,%esp
  801e37:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801e3a:	57                   	push   %edi
  801e3b:	e8 aa ed ff ff       	call   800bea <strcpy>
		string_store += strlen(argv[i]) + 1;
  801e40:	83 c4 04             	add    $0x4,%esp
  801e43:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801e46:	e8 68 ed ff ff       	call   800bb3 <strlen>
  801e4b:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  801e4f:	83 c6 01             	add    $0x1,%esi
  801e52:	83 c4 10             	add    $0x10,%esp
  801e55:	39 b5 8c fd ff ff    	cmp    %esi,-0x274(%ebp)
  801e5b:	7f c8                	jg     801e25 <spawn+0x15f>
	}
	argv_store[argc] = 0;
  801e5d:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801e63:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801e69:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801e70:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801e76:	0f 85 8c 00 00 00    	jne    801f08 <spawn+0x242>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801e7c:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801e82:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801e88:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801e8b:	89 f8                	mov    %edi,%eax
  801e8d:	8b bd 88 fd ff ff    	mov    -0x278(%ebp),%edi
  801e93:	89 78 f8             	mov    %edi,-0x8(%eax)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801e96:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801e9b:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801ea1:	83 ec 0c             	sub    $0xc,%esp
  801ea4:	6a 07                	push   $0x7
  801ea6:	68 00 d0 bf ee       	push   $0xeebfd000
  801eab:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801eb1:	68 00 00 40 00       	push   $0x400000
  801eb6:	6a 00                	push   $0x0
  801eb8:	e8 69 f1 ff ff       	call   801026 <sys_page_map>
  801ebd:	89 c3                	mov    %eax,%ebx
  801ebf:	83 c4 20             	add    $0x20,%esp
  801ec2:	85 c0                	test   %eax,%eax
  801ec4:	0f 88 65 03 00 00    	js     80222f <spawn+0x569>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801eca:	83 ec 08             	sub    $0x8,%esp
  801ecd:	68 00 00 40 00       	push   $0x400000
  801ed2:	6a 00                	push   $0x0
  801ed4:	e8 8f f1 ff ff       	call   801068 <sys_page_unmap>
  801ed9:	89 c3                	mov    %eax,%ebx
  801edb:	83 c4 10             	add    $0x10,%esp
  801ede:	85 c0                	test   %eax,%eax
  801ee0:	0f 88 49 03 00 00    	js     80222f <spawn+0x569>
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801ee6:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801eec:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801ef3:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801ef9:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801f00:	00 00 00 
  801f03:	e9 56 01 00 00       	jmp    80205e <spawn+0x398>
	assert(string_store == (char*)UTEMP + PGSIZE);
  801f08:	68 b8 31 80 00       	push   $0x8031b8
  801f0d:	68 ff 30 80 00       	push   $0x8030ff
  801f12:	68 f2 00 00 00       	push   $0xf2
  801f17:	68 45 31 80 00       	push   $0x803145
  801f1c:	e8 cf e5 ff ff       	call   8004f0 <_panic>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801f21:	83 ec 04             	sub    $0x4,%esp
  801f24:	6a 07                	push   $0x7
  801f26:	68 00 00 40 00       	push   $0x400000
  801f2b:	6a 00                	push   $0x0
  801f2d:	e8 b1 f0 ff ff       	call   800fe3 <sys_page_alloc>
  801f32:	83 c4 10             	add    $0x10,%esp
  801f35:	85 c0                	test   %eax,%eax
  801f37:	0f 88 87 02 00 00    	js     8021c4 <spawn+0x4fe>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801f3d:	83 ec 08             	sub    $0x8,%esp
  801f40:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801f46:	01 f0                	add    %esi,%eax
  801f48:	50                   	push   %eax
  801f49:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801f4f:	e8 b8 f9 ff ff       	call   80190c <seek>
  801f54:	83 c4 10             	add    $0x10,%esp
  801f57:	85 c0                	test   %eax,%eax
  801f59:	0f 88 6c 02 00 00    	js     8021cb <spawn+0x505>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801f5f:	83 ec 04             	sub    $0x4,%esp
  801f62:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801f68:	29 f0                	sub    %esi,%eax
  801f6a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801f6f:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801f74:	0f 47 c1             	cmova  %ecx,%eax
  801f77:	50                   	push   %eax
  801f78:	68 00 00 40 00       	push   $0x400000
  801f7d:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801f83:	e8 bb f8 ff ff       	call   801843 <readn>
  801f88:	83 c4 10             	add    $0x10,%esp
  801f8b:	85 c0                	test   %eax,%eax
  801f8d:	0f 88 3f 02 00 00    	js     8021d2 <spawn+0x50c>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801f93:	83 ec 0c             	sub    $0xc,%esp
  801f96:	57                   	push   %edi
  801f97:	03 b5 88 fd ff ff    	add    -0x278(%ebp),%esi
  801f9d:	56                   	push   %esi
  801f9e:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801fa4:	68 00 00 40 00       	push   $0x400000
  801fa9:	6a 00                	push   $0x0
  801fab:	e8 76 f0 ff ff       	call   801026 <sys_page_map>
  801fb0:	83 c4 20             	add    $0x20,%esp
  801fb3:	85 c0                	test   %eax,%eax
  801fb5:	0f 88 80 00 00 00    	js     80203b <spawn+0x375>
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
  801fbb:	83 ec 08             	sub    $0x8,%esp
  801fbe:	68 00 00 40 00       	push   $0x400000
  801fc3:	6a 00                	push   $0x0
  801fc5:	e8 9e f0 ff ff       	call   801068 <sys_page_unmap>
  801fca:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < memsz; i += PGSIZE) {
  801fcd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801fd3:	89 de                	mov    %ebx,%esi
  801fd5:	39 9d 8c fd ff ff    	cmp    %ebx,-0x274(%ebp)
  801fdb:	76 73                	jbe    802050 <spawn+0x38a>
		if (i >= filesz) {
  801fdd:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  801fe3:	0f 87 38 ff ff ff    	ja     801f21 <spawn+0x25b>
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801fe9:	83 ec 04             	sub    $0x4,%esp
  801fec:	57                   	push   %edi
  801fed:	03 b5 88 fd ff ff    	add    -0x278(%ebp),%esi
  801ff3:	56                   	push   %esi
  801ff4:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801ffa:	e8 e4 ef ff ff       	call   800fe3 <sys_page_alloc>
  801fff:	83 c4 10             	add    $0x10,%esp
  802002:	85 c0                	test   %eax,%eax
  802004:	79 c7                	jns    801fcd <spawn+0x307>
  802006:	89 c7                	mov    %eax,%edi
	sys_env_destroy(child);
  802008:	83 ec 0c             	sub    $0xc,%esp
  80200b:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802011:	e8 4e ef ff ff       	call   800f64 <sys_env_destroy>
	close(fd);
  802016:	83 c4 04             	add    $0x4,%esp
  802019:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  80201f:	e8 5c f6 ff ff       	call   801680 <close>
	return r;
  802024:	83 c4 10             	add    $0x10,%esp
  802027:	89 bd 90 fd ff ff    	mov    %edi,-0x270(%ebp)
}
  80202d:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  802033:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802036:	5b                   	pop    %ebx
  802037:	5e                   	pop    %esi
  802038:	5f                   	pop    %edi
  802039:	5d                   	pop    %ebp
  80203a:	c3                   	ret    
				panic("spawn: sys_page_map data: %e", r);
  80203b:	50                   	push   %eax
  80203c:	68 51 31 80 00       	push   $0x803151
  802041:	68 25 01 00 00       	push   $0x125
  802046:	68 45 31 80 00       	push   $0x803145
  80204b:	e8 a0 e4 ff ff       	call   8004f0 <_panic>
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802050:	83 85 7c fd ff ff 01 	addl   $0x1,-0x284(%ebp)
  802057:	83 85 78 fd ff ff 20 	addl   $0x20,-0x288(%ebp)
  80205e:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  802065:	3b 85 7c fd ff ff    	cmp    -0x284(%ebp),%eax
  80206b:	7e 71                	jle    8020de <spawn+0x418>
		if (ph->p_type != ELF_PROG_LOAD)
  80206d:	8b 8d 78 fd ff ff    	mov    -0x288(%ebp),%ecx
  802073:	83 39 01             	cmpl   $0x1,(%ecx)
  802076:	75 d8                	jne    802050 <spawn+0x38a>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  802078:	8b 41 18             	mov    0x18(%ecx),%eax
  80207b:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  80207e:	83 f8 01             	cmp    $0x1,%eax
  802081:	19 ff                	sbb    %edi,%edi
  802083:	83 e7 fe             	and    $0xfffffffe,%edi
  802086:	83 c7 07             	add    $0x7,%edi
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  802089:	8b 71 04             	mov    0x4(%ecx),%esi
  80208c:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  802092:	8b 59 10             	mov    0x10(%ecx),%ebx
  802095:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  80209b:	8b 41 14             	mov    0x14(%ecx),%eax
  80209e:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8020a4:	8b 51 08             	mov    0x8(%ecx),%edx
  8020a7:	89 95 88 fd ff ff    	mov    %edx,-0x278(%ebp)
	if ((i = PGOFF(va))) {
  8020ad:	89 d0                	mov    %edx,%eax
  8020af:	25 ff 0f 00 00       	and    $0xfff,%eax
  8020b4:	74 1e                	je     8020d4 <spawn+0x40e>
		va -= i;
  8020b6:	29 c2                	sub    %eax,%edx
  8020b8:	89 95 88 fd ff ff    	mov    %edx,-0x278(%ebp)
		memsz += i;
  8020be:	01 85 8c fd ff ff    	add    %eax,-0x274(%ebp)
		filesz += i;
  8020c4:	01 c3                	add    %eax,%ebx
  8020c6:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
		fileoffset -= i;
  8020cc:	29 c6                	sub    %eax,%esi
  8020ce:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
	for (i = 0; i < memsz; i += PGSIZE) {
  8020d4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020d9:	e9 f5 fe ff ff       	jmp    801fd3 <spawn+0x30d>
	close(fd);
  8020de:	83 ec 0c             	sub    $0xc,%esp
  8020e1:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  8020e7:	e8 94 f5 ff ff       	call   801680 <close>
  8020ec:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	uintptr_t addr;
	int r;

	for(addr=(uintptr_t)UTEXT; addr<USTACKTOP;addr+=PGSIZE){
  8020ef:	bb 00 00 80 00       	mov    $0x800000,%ebx
  8020f4:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
  8020fa:	eb 12                	jmp    80210e <spawn+0x448>
  8020fc:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802102:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  802108:	0f 84 cb 00 00 00    	je     8021d9 <spawn+0x513>
	   if((uvpd[PDX(addr)]&PTE_P) && (uvpt[PGNUM(addr)]&PTE_P)){
  80210e:	89 d8                	mov    %ebx,%eax
  802110:	c1 e8 16             	shr    $0x16,%eax
  802113:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80211a:	a8 01                	test   $0x1,%al
  80211c:	74 de                	je     8020fc <spawn+0x436>
  80211e:	89 d8                	mov    %ebx,%eax
  802120:	c1 e8 0c             	shr    $0xc,%eax
  802123:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80212a:	f6 c2 01             	test   $0x1,%dl
  80212d:	74 cd                	je     8020fc <spawn+0x436>
	      if(uvpt[PGNUM(addr)] & PTE_SHARE){
  80212f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802136:	f6 c6 04             	test   $0x4,%dh
  802139:	74 c1                	je     8020fc <spawn+0x436>
	        if((r=sys_page_map(thisenv->env_id,(void *)addr,child,(void *)addr, uvpt[PGNUM(addr)]&PTE_SYSCALL))<0)
  80213b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802142:	8b 15 04 50 80 00    	mov    0x805004,%edx
  802148:	8b 52 48             	mov    0x48(%edx),%edx
  80214b:	83 ec 0c             	sub    $0xc,%esp
  80214e:	25 07 0e 00 00       	and    $0xe07,%eax
  802153:	50                   	push   %eax
  802154:	53                   	push   %ebx
  802155:	56                   	push   %esi
  802156:	53                   	push   %ebx
  802157:	52                   	push   %edx
  802158:	e8 c9 ee ff ff       	call   801026 <sys_page_map>
  80215d:	83 c4 20             	add    $0x20,%esp
  802160:	85 c0                	test   %eax,%eax
  802162:	79 98                	jns    8020fc <spawn+0x436>
		panic("copy_shared_pages: %e", r);
  802164:	50                   	push   %eax
  802165:	68 9f 31 80 00       	push   $0x80319f
  80216a:	68 82 00 00 00       	push   $0x82
  80216f:	68 45 31 80 00       	push   $0x803145
  802174:	e8 77 e3 ff ff       	call   8004f0 <_panic>
		panic("sys_env_set_trapframe: %e", r);
  802179:	50                   	push   %eax
  80217a:	68 6e 31 80 00       	push   $0x80316e
  80217f:	68 86 00 00 00       	push   $0x86
  802184:	68 45 31 80 00       	push   $0x803145
  802189:	e8 62 e3 ff ff       	call   8004f0 <_panic>
		panic("sys_env_set_status: %e", r);
  80218e:	50                   	push   %eax
  80218f:	68 88 31 80 00       	push   $0x803188
  802194:	68 89 00 00 00       	push   $0x89
  802199:	68 45 31 80 00       	push   $0x803145
  80219e:	e8 4d e3 ff ff       	call   8004f0 <_panic>
		return r;
  8021a3:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8021a9:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  8021af:	e9 79 fe ff ff       	jmp    80202d <spawn+0x367>
		return -E_NO_MEM;
  8021b4:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return r;
  8021b9:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  8021bf:	e9 69 fe ff ff       	jmp    80202d <spawn+0x367>
  8021c4:	89 c7                	mov    %eax,%edi
  8021c6:	e9 3d fe ff ff       	jmp    802008 <spawn+0x342>
  8021cb:	89 c7                	mov    %eax,%edi
  8021cd:	e9 36 fe ff ff       	jmp    802008 <spawn+0x342>
  8021d2:	89 c7                	mov    %eax,%edi
  8021d4:	e9 2f fe ff ff       	jmp    802008 <spawn+0x342>
	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  8021d9:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  8021e0:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  8021e3:	83 ec 08             	sub    $0x8,%esp
  8021e6:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  8021ec:	50                   	push   %eax
  8021ed:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8021f3:	e8 f4 ee ff ff       	call   8010ec <sys_env_set_trapframe>
  8021f8:	83 c4 10             	add    $0x10,%esp
  8021fb:	85 c0                	test   %eax,%eax
  8021fd:	0f 88 76 ff ff ff    	js     802179 <spawn+0x4b3>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802203:	83 ec 08             	sub    $0x8,%esp
  802206:	6a 02                	push   $0x2
  802208:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80220e:	e8 97 ee ff ff       	call   8010aa <sys_env_set_status>
  802213:	83 c4 10             	add    $0x10,%esp
  802216:	85 c0                	test   %eax,%eax
  802218:	0f 88 70 ff ff ff    	js     80218e <spawn+0x4c8>
	return child;
  80221e:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802224:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  80222a:	e9 fe fd ff ff       	jmp    80202d <spawn+0x367>
	sys_page_unmap(0, UTEMP);
  80222f:	83 ec 08             	sub    $0x8,%esp
  802232:	68 00 00 40 00       	push   $0x400000
  802237:	6a 00                	push   $0x0
  802239:	e8 2a ee ff ff       	call   801068 <sys_page_unmap>
  80223e:	83 c4 10             	add    $0x10,%esp
  802241:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  802247:	e9 e1 fd ff ff       	jmp    80202d <spawn+0x367>

0080224c <spawnl>:
{
  80224c:	55                   	push   %ebp
  80224d:	89 e5                	mov    %esp,%ebp
  80224f:	57                   	push   %edi
  802250:	56                   	push   %esi
  802251:	53                   	push   %ebx
  802252:	83 ec 0c             	sub    $0xc,%esp
	va_start(vl, arg0);
  802255:	8d 55 10             	lea    0x10(%ebp),%edx
	int argc=0;
  802258:	b8 00 00 00 00       	mov    $0x0,%eax
	while(va_arg(vl, void *) != NULL)
  80225d:	eb 05                	jmp    802264 <spawnl+0x18>
		argc++;
  80225f:	83 c0 01             	add    $0x1,%eax
	while(va_arg(vl, void *) != NULL)
  802262:	89 ca                	mov    %ecx,%edx
  802264:	8d 4a 04             	lea    0x4(%edx),%ecx
  802267:	83 3a 00             	cmpl   $0x0,(%edx)
  80226a:	75 f3                	jne    80225f <spawnl+0x13>
	const char *argv[argc+2];
  80226c:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  802273:	83 e2 f0             	and    $0xfffffff0,%edx
  802276:	29 d4                	sub    %edx,%esp
  802278:	8d 54 24 03          	lea    0x3(%esp),%edx
  80227c:	c1 ea 02             	shr    $0x2,%edx
  80227f:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  802286:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  802288:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80228b:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  802292:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  802299:	00 
	va_start(vl, arg0);
  80229a:	8d 4d 10             	lea    0x10(%ebp),%ecx
  80229d:	89 c2                	mov    %eax,%edx
	for(i=0;i<argc;i++)
  80229f:	b8 00 00 00 00       	mov    $0x0,%eax
  8022a4:	eb 0b                	jmp    8022b1 <spawnl+0x65>
		argv[i+1] = va_arg(vl, const char *);
  8022a6:	83 c0 01             	add    $0x1,%eax
  8022a9:	8b 39                	mov    (%ecx),%edi
  8022ab:	89 3c 83             	mov    %edi,(%ebx,%eax,4)
  8022ae:	8d 49 04             	lea    0x4(%ecx),%ecx
	for(i=0;i<argc;i++)
  8022b1:	39 d0                	cmp    %edx,%eax
  8022b3:	75 f1                	jne    8022a6 <spawnl+0x5a>
	return spawn(prog, argv);
  8022b5:	83 ec 08             	sub    $0x8,%esp
  8022b8:	56                   	push   %esi
  8022b9:	ff 75 08             	pushl  0x8(%ebp)
  8022bc:	e8 05 fa ff ff       	call   801cc6 <spawn>
}
  8022c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022c4:	5b                   	pop    %ebx
  8022c5:	5e                   	pop    %esi
  8022c6:	5f                   	pop    %edi
  8022c7:	5d                   	pop    %ebp
  8022c8:	c3                   	ret    

008022c9 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8022c9:	55                   	push   %ebp
  8022ca:	89 e5                	mov    %esp,%ebp
  8022cc:	56                   	push   %esi
  8022cd:	53                   	push   %ebx
  8022ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8022d1:	83 ec 0c             	sub    $0xc,%esp
  8022d4:	ff 75 08             	pushl  0x8(%ebp)
  8022d7:	e8 09 f2 ff ff       	call   8014e5 <fd2data>
  8022dc:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8022de:	83 c4 08             	add    $0x8,%esp
  8022e1:	68 e0 31 80 00       	push   $0x8031e0
  8022e6:	53                   	push   %ebx
  8022e7:	e8 fe e8 ff ff       	call   800bea <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8022ec:	8b 46 04             	mov    0x4(%esi),%eax
  8022ef:	2b 06                	sub    (%esi),%eax
  8022f1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8022f7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8022fe:	00 00 00 
	stat->st_dev = &devpipe;
  802301:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  802308:	40 80 00 
	return 0;
}
  80230b:	b8 00 00 00 00       	mov    $0x0,%eax
  802310:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802313:	5b                   	pop    %ebx
  802314:	5e                   	pop    %esi
  802315:	5d                   	pop    %ebp
  802316:	c3                   	ret    

00802317 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802317:	55                   	push   %ebp
  802318:	89 e5                	mov    %esp,%ebp
  80231a:	53                   	push   %ebx
  80231b:	83 ec 0c             	sub    $0xc,%esp
  80231e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802321:	53                   	push   %ebx
  802322:	6a 00                	push   $0x0
  802324:	e8 3f ed ff ff       	call   801068 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802329:	89 1c 24             	mov    %ebx,(%esp)
  80232c:	e8 b4 f1 ff ff       	call   8014e5 <fd2data>
  802331:	83 c4 08             	add    $0x8,%esp
  802334:	50                   	push   %eax
  802335:	6a 00                	push   $0x0
  802337:	e8 2c ed ff ff       	call   801068 <sys_page_unmap>
}
  80233c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80233f:	c9                   	leave  
  802340:	c3                   	ret    

00802341 <_pipeisclosed>:
{
  802341:	55                   	push   %ebp
  802342:	89 e5                	mov    %esp,%ebp
  802344:	57                   	push   %edi
  802345:	56                   	push   %esi
  802346:	53                   	push   %ebx
  802347:	83 ec 1c             	sub    $0x1c,%esp
  80234a:	89 c7                	mov    %eax,%edi
  80234c:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  80234e:	a1 04 50 80 00       	mov    0x805004,%eax
  802353:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802356:	83 ec 0c             	sub    $0xc,%esp
  802359:	57                   	push   %edi
  80235a:	e8 96 04 00 00       	call   8027f5 <pageref>
  80235f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  802362:	89 34 24             	mov    %esi,(%esp)
  802365:	e8 8b 04 00 00       	call   8027f5 <pageref>
		nn = thisenv->env_runs;
  80236a:	8b 15 04 50 80 00    	mov    0x805004,%edx
  802370:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802373:	83 c4 10             	add    $0x10,%esp
  802376:	39 cb                	cmp    %ecx,%ebx
  802378:	74 1b                	je     802395 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  80237a:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80237d:	75 cf                	jne    80234e <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80237f:	8b 42 58             	mov    0x58(%edx),%eax
  802382:	6a 01                	push   $0x1
  802384:	50                   	push   %eax
  802385:	53                   	push   %ebx
  802386:	68 e7 31 80 00       	push   $0x8031e7
  80238b:	e8 3b e2 ff ff       	call   8005cb <cprintf>
  802390:	83 c4 10             	add    $0x10,%esp
  802393:	eb b9                	jmp    80234e <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  802395:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802398:	0f 94 c0             	sete   %al
  80239b:	0f b6 c0             	movzbl %al,%eax
}
  80239e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023a1:	5b                   	pop    %ebx
  8023a2:	5e                   	pop    %esi
  8023a3:	5f                   	pop    %edi
  8023a4:	5d                   	pop    %ebp
  8023a5:	c3                   	ret    

008023a6 <devpipe_write>:
{
  8023a6:	55                   	push   %ebp
  8023a7:	89 e5                	mov    %esp,%ebp
  8023a9:	57                   	push   %edi
  8023aa:	56                   	push   %esi
  8023ab:	53                   	push   %ebx
  8023ac:	83 ec 28             	sub    $0x28,%esp
  8023af:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8023b2:	56                   	push   %esi
  8023b3:	e8 2d f1 ff ff       	call   8014e5 <fd2data>
  8023b8:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8023ba:	83 c4 10             	add    $0x10,%esp
  8023bd:	bf 00 00 00 00       	mov    $0x0,%edi
  8023c2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8023c5:	74 4f                	je     802416 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8023c7:	8b 43 04             	mov    0x4(%ebx),%eax
  8023ca:	8b 0b                	mov    (%ebx),%ecx
  8023cc:	8d 51 20             	lea    0x20(%ecx),%edx
  8023cf:	39 d0                	cmp    %edx,%eax
  8023d1:	72 14                	jb     8023e7 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  8023d3:	89 da                	mov    %ebx,%edx
  8023d5:	89 f0                	mov    %esi,%eax
  8023d7:	e8 65 ff ff ff       	call   802341 <_pipeisclosed>
  8023dc:	85 c0                	test   %eax,%eax
  8023de:	75 3a                	jne    80241a <devpipe_write+0x74>
			sys_yield();
  8023e0:	e8 df eb ff ff       	call   800fc4 <sys_yield>
  8023e5:	eb e0                	jmp    8023c7 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8023e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8023ea:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8023ee:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8023f1:	89 c2                	mov    %eax,%edx
  8023f3:	c1 fa 1f             	sar    $0x1f,%edx
  8023f6:	89 d1                	mov    %edx,%ecx
  8023f8:	c1 e9 1b             	shr    $0x1b,%ecx
  8023fb:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8023fe:	83 e2 1f             	and    $0x1f,%edx
  802401:	29 ca                	sub    %ecx,%edx
  802403:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802407:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80240b:	83 c0 01             	add    $0x1,%eax
  80240e:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  802411:	83 c7 01             	add    $0x1,%edi
  802414:	eb ac                	jmp    8023c2 <devpipe_write+0x1c>
	return i;
  802416:	89 f8                	mov    %edi,%eax
  802418:	eb 05                	jmp    80241f <devpipe_write+0x79>
				return 0;
  80241a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80241f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802422:	5b                   	pop    %ebx
  802423:	5e                   	pop    %esi
  802424:	5f                   	pop    %edi
  802425:	5d                   	pop    %ebp
  802426:	c3                   	ret    

00802427 <devpipe_read>:
{
  802427:	55                   	push   %ebp
  802428:	89 e5                	mov    %esp,%ebp
  80242a:	57                   	push   %edi
  80242b:	56                   	push   %esi
  80242c:	53                   	push   %ebx
  80242d:	83 ec 18             	sub    $0x18,%esp
  802430:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  802433:	57                   	push   %edi
  802434:	e8 ac f0 ff ff       	call   8014e5 <fd2data>
  802439:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80243b:	83 c4 10             	add    $0x10,%esp
  80243e:	be 00 00 00 00       	mov    $0x0,%esi
  802443:	3b 75 10             	cmp    0x10(%ebp),%esi
  802446:	74 47                	je     80248f <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  802448:	8b 03                	mov    (%ebx),%eax
  80244a:	3b 43 04             	cmp    0x4(%ebx),%eax
  80244d:	75 22                	jne    802471 <devpipe_read+0x4a>
			if (i > 0)
  80244f:	85 f6                	test   %esi,%esi
  802451:	75 14                	jne    802467 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  802453:	89 da                	mov    %ebx,%edx
  802455:	89 f8                	mov    %edi,%eax
  802457:	e8 e5 fe ff ff       	call   802341 <_pipeisclosed>
  80245c:	85 c0                	test   %eax,%eax
  80245e:	75 33                	jne    802493 <devpipe_read+0x6c>
			sys_yield();
  802460:	e8 5f eb ff ff       	call   800fc4 <sys_yield>
  802465:	eb e1                	jmp    802448 <devpipe_read+0x21>
				return i;
  802467:	89 f0                	mov    %esi,%eax
}
  802469:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80246c:	5b                   	pop    %ebx
  80246d:	5e                   	pop    %esi
  80246e:	5f                   	pop    %edi
  80246f:	5d                   	pop    %ebp
  802470:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802471:	99                   	cltd   
  802472:	c1 ea 1b             	shr    $0x1b,%edx
  802475:	01 d0                	add    %edx,%eax
  802477:	83 e0 1f             	and    $0x1f,%eax
  80247a:	29 d0                	sub    %edx,%eax
  80247c:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802481:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802484:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  802487:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  80248a:	83 c6 01             	add    $0x1,%esi
  80248d:	eb b4                	jmp    802443 <devpipe_read+0x1c>
	return i;
  80248f:	89 f0                	mov    %esi,%eax
  802491:	eb d6                	jmp    802469 <devpipe_read+0x42>
				return 0;
  802493:	b8 00 00 00 00       	mov    $0x0,%eax
  802498:	eb cf                	jmp    802469 <devpipe_read+0x42>

0080249a <pipe>:
{
  80249a:	55                   	push   %ebp
  80249b:	89 e5                	mov    %esp,%ebp
  80249d:	56                   	push   %esi
  80249e:	53                   	push   %ebx
  80249f:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8024a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024a5:	50                   	push   %eax
  8024a6:	e8 51 f0 ff ff       	call   8014fc <fd_alloc>
  8024ab:	89 c3                	mov    %eax,%ebx
  8024ad:	83 c4 10             	add    $0x10,%esp
  8024b0:	85 c0                	test   %eax,%eax
  8024b2:	78 5b                	js     80250f <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8024b4:	83 ec 04             	sub    $0x4,%esp
  8024b7:	68 07 04 00 00       	push   $0x407
  8024bc:	ff 75 f4             	pushl  -0xc(%ebp)
  8024bf:	6a 00                	push   $0x0
  8024c1:	e8 1d eb ff ff       	call   800fe3 <sys_page_alloc>
  8024c6:	89 c3                	mov    %eax,%ebx
  8024c8:	83 c4 10             	add    $0x10,%esp
  8024cb:	85 c0                	test   %eax,%eax
  8024cd:	78 40                	js     80250f <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  8024cf:	83 ec 0c             	sub    $0xc,%esp
  8024d2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8024d5:	50                   	push   %eax
  8024d6:	e8 21 f0 ff ff       	call   8014fc <fd_alloc>
  8024db:	89 c3                	mov    %eax,%ebx
  8024dd:	83 c4 10             	add    $0x10,%esp
  8024e0:	85 c0                	test   %eax,%eax
  8024e2:	78 1b                	js     8024ff <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8024e4:	83 ec 04             	sub    $0x4,%esp
  8024e7:	68 07 04 00 00       	push   $0x407
  8024ec:	ff 75 f0             	pushl  -0x10(%ebp)
  8024ef:	6a 00                	push   $0x0
  8024f1:	e8 ed ea ff ff       	call   800fe3 <sys_page_alloc>
  8024f6:	89 c3                	mov    %eax,%ebx
  8024f8:	83 c4 10             	add    $0x10,%esp
  8024fb:	85 c0                	test   %eax,%eax
  8024fd:	79 19                	jns    802518 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  8024ff:	83 ec 08             	sub    $0x8,%esp
  802502:	ff 75 f4             	pushl  -0xc(%ebp)
  802505:	6a 00                	push   $0x0
  802507:	e8 5c eb ff ff       	call   801068 <sys_page_unmap>
  80250c:	83 c4 10             	add    $0x10,%esp
}
  80250f:	89 d8                	mov    %ebx,%eax
  802511:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802514:	5b                   	pop    %ebx
  802515:	5e                   	pop    %esi
  802516:	5d                   	pop    %ebp
  802517:	c3                   	ret    
	va = fd2data(fd0);
  802518:	83 ec 0c             	sub    $0xc,%esp
  80251b:	ff 75 f4             	pushl  -0xc(%ebp)
  80251e:	e8 c2 ef ff ff       	call   8014e5 <fd2data>
  802523:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802525:	83 c4 0c             	add    $0xc,%esp
  802528:	68 07 04 00 00       	push   $0x407
  80252d:	50                   	push   %eax
  80252e:	6a 00                	push   $0x0
  802530:	e8 ae ea ff ff       	call   800fe3 <sys_page_alloc>
  802535:	89 c3                	mov    %eax,%ebx
  802537:	83 c4 10             	add    $0x10,%esp
  80253a:	85 c0                	test   %eax,%eax
  80253c:	0f 88 8c 00 00 00    	js     8025ce <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802542:	83 ec 0c             	sub    $0xc,%esp
  802545:	ff 75 f0             	pushl  -0x10(%ebp)
  802548:	e8 98 ef ff ff       	call   8014e5 <fd2data>
  80254d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802554:	50                   	push   %eax
  802555:	6a 00                	push   $0x0
  802557:	56                   	push   %esi
  802558:	6a 00                	push   $0x0
  80255a:	e8 c7 ea ff ff       	call   801026 <sys_page_map>
  80255f:	89 c3                	mov    %eax,%ebx
  802561:	83 c4 20             	add    $0x20,%esp
  802564:	85 c0                	test   %eax,%eax
  802566:	78 58                	js     8025c0 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  802568:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80256b:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802571:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802573:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802576:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  80257d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802580:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802586:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802588:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80258b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  802592:	83 ec 0c             	sub    $0xc,%esp
  802595:	ff 75 f4             	pushl  -0xc(%ebp)
  802598:	e8 38 ef ff ff       	call   8014d5 <fd2num>
  80259d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8025a0:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8025a2:	83 c4 04             	add    $0x4,%esp
  8025a5:	ff 75 f0             	pushl  -0x10(%ebp)
  8025a8:	e8 28 ef ff ff       	call   8014d5 <fd2num>
  8025ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8025b0:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8025b3:	83 c4 10             	add    $0x10,%esp
  8025b6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8025bb:	e9 4f ff ff ff       	jmp    80250f <pipe+0x75>
	sys_page_unmap(0, va);
  8025c0:	83 ec 08             	sub    $0x8,%esp
  8025c3:	56                   	push   %esi
  8025c4:	6a 00                	push   $0x0
  8025c6:	e8 9d ea ff ff       	call   801068 <sys_page_unmap>
  8025cb:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8025ce:	83 ec 08             	sub    $0x8,%esp
  8025d1:	ff 75 f0             	pushl  -0x10(%ebp)
  8025d4:	6a 00                	push   $0x0
  8025d6:	e8 8d ea ff ff       	call   801068 <sys_page_unmap>
  8025db:	83 c4 10             	add    $0x10,%esp
  8025de:	e9 1c ff ff ff       	jmp    8024ff <pipe+0x65>

008025e3 <pipeisclosed>:
{
  8025e3:	55                   	push   %ebp
  8025e4:	89 e5                	mov    %esp,%ebp
  8025e6:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8025e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025ec:	50                   	push   %eax
  8025ed:	ff 75 08             	pushl  0x8(%ebp)
  8025f0:	e8 56 ef ff ff       	call   80154b <fd_lookup>
  8025f5:	83 c4 10             	add    $0x10,%esp
  8025f8:	85 c0                	test   %eax,%eax
  8025fa:	78 18                	js     802614 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  8025fc:	83 ec 0c             	sub    $0xc,%esp
  8025ff:	ff 75 f4             	pushl  -0xc(%ebp)
  802602:	e8 de ee ff ff       	call   8014e5 <fd2data>
	return _pipeisclosed(fd, p);
  802607:	89 c2                	mov    %eax,%edx
  802609:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80260c:	e8 30 fd ff ff       	call   802341 <_pipeisclosed>
  802611:	83 c4 10             	add    $0x10,%esp
}
  802614:	c9                   	leave  
  802615:	c3                   	ret    

00802616 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802616:	55                   	push   %ebp
  802617:	89 e5                	mov    %esp,%ebp
  802619:	56                   	push   %esi
  80261a:	53                   	push   %ebx
  80261b:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  80261e:	85 f6                	test   %esi,%esi
  802620:	74 13                	je     802635 <wait+0x1f>
	e = &envs[ENVX(envid)];
  802622:	89 f3                	mov    %esi,%ebx
  802624:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80262a:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  80262d:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802633:	eb 1b                	jmp    802650 <wait+0x3a>
	assert(envid != 0);
  802635:	68 ff 31 80 00       	push   $0x8031ff
  80263a:	68 ff 30 80 00       	push   $0x8030ff
  80263f:	6a 09                	push   $0x9
  802641:	68 0a 32 80 00       	push   $0x80320a
  802646:	e8 a5 de ff ff       	call   8004f0 <_panic>
		sys_yield();
  80264b:	e8 74 e9 ff ff       	call   800fc4 <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802650:	8b 43 48             	mov    0x48(%ebx),%eax
  802653:	39 f0                	cmp    %esi,%eax
  802655:	75 07                	jne    80265e <wait+0x48>
  802657:	8b 43 54             	mov    0x54(%ebx),%eax
  80265a:	85 c0                	test   %eax,%eax
  80265c:	75 ed                	jne    80264b <wait+0x35>
}
  80265e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802661:	5b                   	pop    %ebx
  802662:	5e                   	pop    %esi
  802663:	5d                   	pop    %ebp
  802664:	c3                   	ret    

00802665 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802665:	55                   	push   %ebp
  802666:	89 e5                	mov    %esp,%ebp
  802668:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80266b:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802672:	74 0a                	je     80267e <set_pgfault_handler+0x19>
			panic("set_pgfault_handler %e",r);
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
	}
       
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802674:	8b 45 08             	mov    0x8(%ebp),%eax
  802677:	a3 00 70 80 00       	mov    %eax,0x807000
}
  80267c:	c9                   	leave  
  80267d:	c3                   	ret    
		if((r=sys_page_alloc(thisenv->env_id,(void *)UXSTACKTOP-PGSIZE,PTE_P|PTE_W|PTE_U))<0)
  80267e:	a1 04 50 80 00       	mov    0x805004,%eax
  802683:	8b 40 48             	mov    0x48(%eax),%eax
  802686:	83 ec 04             	sub    $0x4,%esp
  802689:	6a 07                	push   $0x7
  80268b:	68 00 f0 bf ee       	push   $0xeebff000
  802690:	50                   	push   %eax
  802691:	e8 4d e9 ff ff       	call   800fe3 <sys_page_alloc>
  802696:	83 c4 10             	add    $0x10,%esp
  802699:	85 c0                	test   %eax,%eax
  80269b:	78 1b                	js     8026b8 <set_pgfault_handler+0x53>
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
  80269d:	a1 04 50 80 00       	mov    0x805004,%eax
  8026a2:	8b 40 48             	mov    0x48(%eax),%eax
  8026a5:	83 ec 08             	sub    $0x8,%esp
  8026a8:	68 ca 26 80 00       	push   $0x8026ca
  8026ad:	50                   	push   %eax
  8026ae:	e8 7b ea ff ff       	call   80112e <sys_env_set_pgfault_upcall>
  8026b3:	83 c4 10             	add    $0x10,%esp
  8026b6:	eb bc                	jmp    802674 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler %e",r);
  8026b8:	50                   	push   %eax
  8026b9:	68 15 32 80 00       	push   $0x803215
  8026be:	6a 22                	push   $0x22
  8026c0:	68 2c 32 80 00       	push   $0x80322c
  8026c5:	e8 26 de ff ff       	call   8004f0 <_panic>

008026ca <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8026ca:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8026cb:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8026d0:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8026d2:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 48(%esp), %ebp
  8026d5:	8b 6c 24 30          	mov    0x30(%esp),%ebp
        subl $4, %ebp
  8026d9:	83 ed 04             	sub    $0x4,%ebp
        movl %ebp, 48(%esp)
  8026dc:	89 6c 24 30          	mov    %ebp,0x30(%esp)
        movl 40(%esp), %eax
  8026e0:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl %eax, (%ebp)
  8026e4:	89 45 00             	mov    %eax,0x0(%ebp)
	// Restore the trap-time registers.  After you do this, you
 	// can no longer modify any general-purpose registers.
 	// LAB 4: Your code here.
        addl $8, %esp
  8026e7:	83 c4 08             	add    $0x8,%esp
        popal
  8026ea:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $4, %esp
  8026eb:	83 c4 04             	add    $0x4,%esp
        popfl
  8026ee:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  8026ef:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  8026f0:	c3                   	ret    

008026f1 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8026f1:	55                   	push   %ebp
  8026f2:	89 e5                	mov    %esp,%ebp
  8026f4:	56                   	push   %esi
  8026f5:	53                   	push   %ebx
  8026f6:	8b 75 08             	mov    0x8(%ebp),%esi
  8026f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026fc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        //	panic("ipc_recv not implemented");
        int r;
       	if(pg!=NULL){
  8026ff:	85 c0                	test   %eax,%eax
  802701:	74 3b                	je     80273e <ipc_recv+0x4d>
	  r = sys_ipc_recv(pg);
  802703:	83 ec 0c             	sub    $0xc,%esp
  802706:	50                   	push   %eax
  802707:	e8 87 ea ff ff       	call   801193 <sys_ipc_recv>
  80270c:	83 c4 10             	add    $0x10,%esp
	}else
	  r = sys_ipc_recv((void *)UTOP);
	if(r<0){
  80270f:	85 c0                	test   %eax,%eax
  802711:	78 3d                	js     802750 <ipc_recv+0x5f>
	if(perm_store!=NULL){
		*perm_store = 0;
            }
        	return r;
           }else{
	     if(from_env_store!=NULL)
  802713:	85 f6                	test   %esi,%esi
  802715:	74 0a                	je     802721 <ipc_recv+0x30>
		     *from_env_store = thisenv->env_ipc_from;
  802717:	a1 04 50 80 00       	mov    0x805004,%eax
  80271c:	8b 40 74             	mov    0x74(%eax),%eax
  80271f:	89 06                	mov    %eax,(%esi)
	     if(perm_store != NULL)
  802721:	85 db                	test   %ebx,%ebx
  802723:	74 0a                	je     80272f <ipc_recv+0x3e>
		     *perm_store = thisenv->env_ipc_perm;
  802725:	a1 04 50 80 00       	mov    0x805004,%eax
  80272a:	8b 40 78             	mov    0x78(%eax),%eax
  80272d:	89 03                	mov    %eax,(%ebx)
	     return thisenv->env_ipc_value;
  80272f:	a1 04 50 80 00       	mov    0x805004,%eax
  802734:	8b 40 70             	mov    0x70(%eax),%eax
	   }

}
  802737:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80273a:	5b                   	pop    %ebx
  80273b:	5e                   	pop    %esi
  80273c:	5d                   	pop    %ebp
  80273d:	c3                   	ret    
	  r = sys_ipc_recv((void *)UTOP);
  80273e:	83 ec 0c             	sub    $0xc,%esp
  802741:	68 00 00 c0 ee       	push   $0xeec00000
  802746:	e8 48 ea ff ff       	call   801193 <sys_ipc_recv>
  80274b:	83 c4 10             	add    $0x10,%esp
  80274e:	eb bf                	jmp    80270f <ipc_recv+0x1e>
	if(from_env_store!=NULL){
  802750:	85 f6                	test   %esi,%esi
  802752:	74 06                	je     80275a <ipc_recv+0x69>
	  *from_env_store = 0;
  802754:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if(perm_store!=NULL){
  80275a:	85 db                	test   %ebx,%ebx
  80275c:	74 d9                	je     802737 <ipc_recv+0x46>
		*perm_store = 0;
  80275e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802764:	eb d1                	jmp    802737 <ipc_recv+0x46>

00802766 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802766:	55                   	push   %ebp
  802767:	89 e5                	mov    %esp,%ebp
  802769:	57                   	push   %edi
  80276a:	56                   	push   %esi
  80276b:	53                   	push   %ebx
  80276c:	83 ec 0c             	sub    $0xc,%esp
  80276f:	8b 7d 08             	mov    0x8(%ebp),%edi
  802772:	8b 75 0c             	mov    0xc(%ebp),%esi
  802775:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if(pg==NULL) pg = (void *)UTOP;
  802778:	85 db                	test   %ebx,%ebx
  80277a:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80277f:	0f 44 d8             	cmove  %eax,%ebx
	while((r=sys_ipc_try_send(to_env,val,pg,perm))<0){
  802782:	ff 75 14             	pushl  0x14(%ebp)
  802785:	53                   	push   %ebx
  802786:	56                   	push   %esi
  802787:	57                   	push   %edi
  802788:	e8 e3 e9 ff ff       	call   801170 <sys_ipc_try_send>
  80278d:	83 c4 10             	add    $0x10,%esp
  802790:	85 c0                	test   %eax,%eax
  802792:	79 20                	jns    8027b4 <ipc_send+0x4e>
	    if(r!=-E_IPC_NOT_RECV){
  802794:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802797:	75 07                	jne    8027a0 <ipc_send+0x3a>
		    panic("ipc_send:send message failed\n");
	    }
	    sys_yield();
  802799:	e8 26 e8 ff ff       	call   800fc4 <sys_yield>
  80279e:	eb e2                	jmp    802782 <ipc_send+0x1c>
		    panic("ipc_send:send message failed\n");
  8027a0:	83 ec 04             	sub    $0x4,%esp
  8027a3:	68 3a 32 80 00       	push   $0x80323a
  8027a8:	6a 43                	push   $0x43
  8027aa:	68 58 32 80 00       	push   $0x803258
  8027af:	e8 3c dd ff ff       	call   8004f0 <_panic>
	}

}
  8027b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8027b7:	5b                   	pop    %ebx
  8027b8:	5e                   	pop    %esi
  8027b9:	5f                   	pop    %edi
  8027ba:	5d                   	pop    %ebp
  8027bb:	c3                   	ret    

008027bc <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8027bc:	55                   	push   %ebp
  8027bd:	89 e5                	mov    %esp,%ebp
  8027bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8027c2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8027c7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8027ca:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8027d0:	8b 52 50             	mov    0x50(%edx),%edx
  8027d3:	39 ca                	cmp    %ecx,%edx
  8027d5:	74 11                	je     8027e8 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  8027d7:	83 c0 01             	add    $0x1,%eax
  8027da:	3d 00 04 00 00       	cmp    $0x400,%eax
  8027df:	75 e6                	jne    8027c7 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8027e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8027e6:	eb 0b                	jmp    8027f3 <ipc_find_env+0x37>
			return envs[i].env_id;
  8027e8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8027eb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8027f0:	8b 40 48             	mov    0x48(%eax),%eax
}
  8027f3:	5d                   	pop    %ebp
  8027f4:	c3                   	ret    

008027f5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8027f5:	55                   	push   %ebp
  8027f6:	89 e5                	mov    %esp,%ebp
  8027f8:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8027fb:	89 d0                	mov    %edx,%eax
  8027fd:	c1 e8 16             	shr    $0x16,%eax
  802800:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802807:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  80280c:	f6 c1 01             	test   $0x1,%cl
  80280f:	74 1d                	je     80282e <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  802811:	c1 ea 0c             	shr    $0xc,%edx
  802814:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80281b:	f6 c2 01             	test   $0x1,%dl
  80281e:	74 0e                	je     80282e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802820:	c1 ea 0c             	shr    $0xc,%edx
  802823:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80282a:	ef 
  80282b:	0f b7 c0             	movzwl %ax,%eax
}
  80282e:	5d                   	pop    %ebp
  80282f:	c3                   	ret    

00802830 <__udivdi3>:
  802830:	55                   	push   %ebp
  802831:	57                   	push   %edi
  802832:	56                   	push   %esi
  802833:	53                   	push   %ebx
  802834:	83 ec 1c             	sub    $0x1c,%esp
  802837:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80283b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  80283f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802843:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  802847:	85 d2                	test   %edx,%edx
  802849:	75 35                	jne    802880 <__udivdi3+0x50>
  80284b:	39 f3                	cmp    %esi,%ebx
  80284d:	0f 87 bd 00 00 00    	ja     802910 <__udivdi3+0xe0>
  802853:	85 db                	test   %ebx,%ebx
  802855:	89 d9                	mov    %ebx,%ecx
  802857:	75 0b                	jne    802864 <__udivdi3+0x34>
  802859:	b8 01 00 00 00       	mov    $0x1,%eax
  80285e:	31 d2                	xor    %edx,%edx
  802860:	f7 f3                	div    %ebx
  802862:	89 c1                	mov    %eax,%ecx
  802864:	31 d2                	xor    %edx,%edx
  802866:	89 f0                	mov    %esi,%eax
  802868:	f7 f1                	div    %ecx
  80286a:	89 c6                	mov    %eax,%esi
  80286c:	89 e8                	mov    %ebp,%eax
  80286e:	89 f7                	mov    %esi,%edi
  802870:	f7 f1                	div    %ecx
  802872:	89 fa                	mov    %edi,%edx
  802874:	83 c4 1c             	add    $0x1c,%esp
  802877:	5b                   	pop    %ebx
  802878:	5e                   	pop    %esi
  802879:	5f                   	pop    %edi
  80287a:	5d                   	pop    %ebp
  80287b:	c3                   	ret    
  80287c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802880:	39 f2                	cmp    %esi,%edx
  802882:	77 7c                	ja     802900 <__udivdi3+0xd0>
  802884:	0f bd fa             	bsr    %edx,%edi
  802887:	83 f7 1f             	xor    $0x1f,%edi
  80288a:	0f 84 98 00 00 00    	je     802928 <__udivdi3+0xf8>
  802890:	89 f9                	mov    %edi,%ecx
  802892:	b8 20 00 00 00       	mov    $0x20,%eax
  802897:	29 f8                	sub    %edi,%eax
  802899:	d3 e2                	shl    %cl,%edx
  80289b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80289f:	89 c1                	mov    %eax,%ecx
  8028a1:	89 da                	mov    %ebx,%edx
  8028a3:	d3 ea                	shr    %cl,%edx
  8028a5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8028a9:	09 d1                	or     %edx,%ecx
  8028ab:	89 f2                	mov    %esi,%edx
  8028ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8028b1:	89 f9                	mov    %edi,%ecx
  8028b3:	d3 e3                	shl    %cl,%ebx
  8028b5:	89 c1                	mov    %eax,%ecx
  8028b7:	d3 ea                	shr    %cl,%edx
  8028b9:	89 f9                	mov    %edi,%ecx
  8028bb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8028bf:	d3 e6                	shl    %cl,%esi
  8028c1:	89 eb                	mov    %ebp,%ebx
  8028c3:	89 c1                	mov    %eax,%ecx
  8028c5:	d3 eb                	shr    %cl,%ebx
  8028c7:	09 de                	or     %ebx,%esi
  8028c9:	89 f0                	mov    %esi,%eax
  8028cb:	f7 74 24 08          	divl   0x8(%esp)
  8028cf:	89 d6                	mov    %edx,%esi
  8028d1:	89 c3                	mov    %eax,%ebx
  8028d3:	f7 64 24 0c          	mull   0xc(%esp)
  8028d7:	39 d6                	cmp    %edx,%esi
  8028d9:	72 0c                	jb     8028e7 <__udivdi3+0xb7>
  8028db:	89 f9                	mov    %edi,%ecx
  8028dd:	d3 e5                	shl    %cl,%ebp
  8028df:	39 c5                	cmp    %eax,%ebp
  8028e1:	73 5d                	jae    802940 <__udivdi3+0x110>
  8028e3:	39 d6                	cmp    %edx,%esi
  8028e5:	75 59                	jne    802940 <__udivdi3+0x110>
  8028e7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8028ea:	31 ff                	xor    %edi,%edi
  8028ec:	89 fa                	mov    %edi,%edx
  8028ee:	83 c4 1c             	add    $0x1c,%esp
  8028f1:	5b                   	pop    %ebx
  8028f2:	5e                   	pop    %esi
  8028f3:	5f                   	pop    %edi
  8028f4:	5d                   	pop    %ebp
  8028f5:	c3                   	ret    
  8028f6:	8d 76 00             	lea    0x0(%esi),%esi
  8028f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802900:	31 ff                	xor    %edi,%edi
  802902:	31 c0                	xor    %eax,%eax
  802904:	89 fa                	mov    %edi,%edx
  802906:	83 c4 1c             	add    $0x1c,%esp
  802909:	5b                   	pop    %ebx
  80290a:	5e                   	pop    %esi
  80290b:	5f                   	pop    %edi
  80290c:	5d                   	pop    %ebp
  80290d:	c3                   	ret    
  80290e:	66 90                	xchg   %ax,%ax
  802910:	31 ff                	xor    %edi,%edi
  802912:	89 e8                	mov    %ebp,%eax
  802914:	89 f2                	mov    %esi,%edx
  802916:	f7 f3                	div    %ebx
  802918:	89 fa                	mov    %edi,%edx
  80291a:	83 c4 1c             	add    $0x1c,%esp
  80291d:	5b                   	pop    %ebx
  80291e:	5e                   	pop    %esi
  80291f:	5f                   	pop    %edi
  802920:	5d                   	pop    %ebp
  802921:	c3                   	ret    
  802922:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802928:	39 f2                	cmp    %esi,%edx
  80292a:	72 06                	jb     802932 <__udivdi3+0x102>
  80292c:	31 c0                	xor    %eax,%eax
  80292e:	39 eb                	cmp    %ebp,%ebx
  802930:	77 d2                	ja     802904 <__udivdi3+0xd4>
  802932:	b8 01 00 00 00       	mov    $0x1,%eax
  802937:	eb cb                	jmp    802904 <__udivdi3+0xd4>
  802939:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802940:	89 d8                	mov    %ebx,%eax
  802942:	31 ff                	xor    %edi,%edi
  802944:	eb be                	jmp    802904 <__udivdi3+0xd4>
  802946:	66 90                	xchg   %ax,%ax
  802948:	66 90                	xchg   %ax,%ax
  80294a:	66 90                	xchg   %ax,%ax
  80294c:	66 90                	xchg   %ax,%ax
  80294e:	66 90                	xchg   %ax,%ax

00802950 <__umoddi3>:
  802950:	55                   	push   %ebp
  802951:	57                   	push   %edi
  802952:	56                   	push   %esi
  802953:	53                   	push   %ebx
  802954:	83 ec 1c             	sub    $0x1c,%esp
  802957:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80295b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80295f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802963:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802967:	85 ed                	test   %ebp,%ebp
  802969:	89 f0                	mov    %esi,%eax
  80296b:	89 da                	mov    %ebx,%edx
  80296d:	75 19                	jne    802988 <__umoddi3+0x38>
  80296f:	39 df                	cmp    %ebx,%edi
  802971:	0f 86 b1 00 00 00    	jbe    802a28 <__umoddi3+0xd8>
  802977:	f7 f7                	div    %edi
  802979:	89 d0                	mov    %edx,%eax
  80297b:	31 d2                	xor    %edx,%edx
  80297d:	83 c4 1c             	add    $0x1c,%esp
  802980:	5b                   	pop    %ebx
  802981:	5e                   	pop    %esi
  802982:	5f                   	pop    %edi
  802983:	5d                   	pop    %ebp
  802984:	c3                   	ret    
  802985:	8d 76 00             	lea    0x0(%esi),%esi
  802988:	39 dd                	cmp    %ebx,%ebp
  80298a:	77 f1                	ja     80297d <__umoddi3+0x2d>
  80298c:	0f bd cd             	bsr    %ebp,%ecx
  80298f:	83 f1 1f             	xor    $0x1f,%ecx
  802992:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802996:	0f 84 b4 00 00 00    	je     802a50 <__umoddi3+0x100>
  80299c:	b8 20 00 00 00       	mov    $0x20,%eax
  8029a1:	89 c2                	mov    %eax,%edx
  8029a3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8029a7:	29 c2                	sub    %eax,%edx
  8029a9:	89 c1                	mov    %eax,%ecx
  8029ab:	89 f8                	mov    %edi,%eax
  8029ad:	d3 e5                	shl    %cl,%ebp
  8029af:	89 d1                	mov    %edx,%ecx
  8029b1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8029b5:	d3 e8                	shr    %cl,%eax
  8029b7:	09 c5                	or     %eax,%ebp
  8029b9:	8b 44 24 04          	mov    0x4(%esp),%eax
  8029bd:	89 c1                	mov    %eax,%ecx
  8029bf:	d3 e7                	shl    %cl,%edi
  8029c1:	89 d1                	mov    %edx,%ecx
  8029c3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8029c7:	89 df                	mov    %ebx,%edi
  8029c9:	d3 ef                	shr    %cl,%edi
  8029cb:	89 c1                	mov    %eax,%ecx
  8029cd:	89 f0                	mov    %esi,%eax
  8029cf:	d3 e3                	shl    %cl,%ebx
  8029d1:	89 d1                	mov    %edx,%ecx
  8029d3:	89 fa                	mov    %edi,%edx
  8029d5:	d3 e8                	shr    %cl,%eax
  8029d7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8029dc:	09 d8                	or     %ebx,%eax
  8029de:	f7 f5                	div    %ebp
  8029e0:	d3 e6                	shl    %cl,%esi
  8029e2:	89 d1                	mov    %edx,%ecx
  8029e4:	f7 64 24 08          	mull   0x8(%esp)
  8029e8:	39 d1                	cmp    %edx,%ecx
  8029ea:	89 c3                	mov    %eax,%ebx
  8029ec:	89 d7                	mov    %edx,%edi
  8029ee:	72 06                	jb     8029f6 <__umoddi3+0xa6>
  8029f0:	75 0e                	jne    802a00 <__umoddi3+0xb0>
  8029f2:	39 c6                	cmp    %eax,%esi
  8029f4:	73 0a                	jae    802a00 <__umoddi3+0xb0>
  8029f6:	2b 44 24 08          	sub    0x8(%esp),%eax
  8029fa:	19 ea                	sbb    %ebp,%edx
  8029fc:	89 d7                	mov    %edx,%edi
  8029fe:	89 c3                	mov    %eax,%ebx
  802a00:	89 ca                	mov    %ecx,%edx
  802a02:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  802a07:	29 de                	sub    %ebx,%esi
  802a09:	19 fa                	sbb    %edi,%edx
  802a0b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  802a0f:	89 d0                	mov    %edx,%eax
  802a11:	d3 e0                	shl    %cl,%eax
  802a13:	89 d9                	mov    %ebx,%ecx
  802a15:	d3 ee                	shr    %cl,%esi
  802a17:	d3 ea                	shr    %cl,%edx
  802a19:	09 f0                	or     %esi,%eax
  802a1b:	83 c4 1c             	add    $0x1c,%esp
  802a1e:	5b                   	pop    %ebx
  802a1f:	5e                   	pop    %esi
  802a20:	5f                   	pop    %edi
  802a21:	5d                   	pop    %ebp
  802a22:	c3                   	ret    
  802a23:	90                   	nop
  802a24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802a28:	85 ff                	test   %edi,%edi
  802a2a:	89 f9                	mov    %edi,%ecx
  802a2c:	75 0b                	jne    802a39 <__umoddi3+0xe9>
  802a2e:	b8 01 00 00 00       	mov    $0x1,%eax
  802a33:	31 d2                	xor    %edx,%edx
  802a35:	f7 f7                	div    %edi
  802a37:	89 c1                	mov    %eax,%ecx
  802a39:	89 d8                	mov    %ebx,%eax
  802a3b:	31 d2                	xor    %edx,%edx
  802a3d:	f7 f1                	div    %ecx
  802a3f:	89 f0                	mov    %esi,%eax
  802a41:	f7 f1                	div    %ecx
  802a43:	e9 31 ff ff ff       	jmp    802979 <__umoddi3+0x29>
  802a48:	90                   	nop
  802a49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802a50:	39 dd                	cmp    %ebx,%ebp
  802a52:	72 08                	jb     802a5c <__umoddi3+0x10c>
  802a54:	39 f7                	cmp    %esi,%edi
  802a56:	0f 87 21 ff ff ff    	ja     80297d <__umoddi3+0x2d>
  802a5c:	89 da                	mov    %ebx,%edx
  802a5e:	89 f0                	mov    %esi,%eax
  802a60:	29 f8                	sub    %edi,%eax
  802a62:	19 ea                	sbb    %ebp,%edx
  802a64:	e9 14 ff ff ff       	jmp    80297d <__umoddi3+0x2d>
