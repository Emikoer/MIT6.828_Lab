
obj/user/testkbd.debug:     file format elf32-i386


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
  80002c:	e8 33 02 00 00       	call   800264 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
  80003a:	bb 0a 00 00 00       	mov    $0xa,%ebx
	int i, r;

	// Spin for a bit to let the console quiet
	for (i = 0; i < 10; ++i)
		sys_yield();
  80003f:	e8 44 0e 00 00       	call   800e88 <sys_yield>
	for (i = 0; i < 10; ++i)
  800044:	83 eb 01             	sub    $0x1,%ebx
  800047:	75 f6                	jne    80003f <umain+0xc>

	close(0);
  800049:	83 ec 0c             	sub    $0xc,%esp
  80004c:	6a 00                	push   $0x0
  80004e:	e8 f0 11 00 00       	call   801243 <close>
	if ((r = opencons()) < 0)
  800053:	e8 ba 01 00 00       	call   800212 <opencons>
  800058:	83 c4 10             	add    $0x10,%esp
  80005b:	85 c0                	test   %eax,%eax
  80005d:	78 16                	js     800075 <umain+0x42>
		panic("opencons: %e", r);
	if (r != 0)
  80005f:	85 c0                	test   %eax,%eax
  800061:	74 24                	je     800087 <umain+0x54>
		panic("first opencons used fd %d", r);
  800063:	50                   	push   %eax
  800064:	68 9c 20 80 00       	push   $0x80209c
  800069:	6a 11                	push   $0x11
  80006b:	68 8d 20 80 00       	push   $0x80208d
  800070:	e8 4f 02 00 00       	call   8002c4 <_panic>
		panic("opencons: %e", r);
  800075:	50                   	push   %eax
  800076:	68 80 20 80 00       	push   $0x802080
  80007b:	6a 0f                	push   $0xf
  80007d:	68 8d 20 80 00       	push   $0x80208d
  800082:	e8 3d 02 00 00       	call   8002c4 <_panic>
	if ((r = dup(0, 1)) < 0)
  800087:	83 ec 08             	sub    $0x8,%esp
  80008a:	6a 01                	push   $0x1
  80008c:	6a 00                	push   $0x0
  80008e:	e8 00 12 00 00       	call   801293 <dup>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	79 24                	jns    8000be <umain+0x8b>
		panic("dup: %e", r);
  80009a:	50                   	push   %eax
  80009b:	68 b6 20 80 00       	push   $0x8020b6
  8000a0:	6a 13                	push   $0x13
  8000a2:	68 8d 20 80 00       	push   $0x80208d
  8000a7:	e8 18 02 00 00       	call   8002c4 <_panic>

		buf = readline("Type a line: ");
		if (buf != NULL)
			fprintf(1, "%s\n", buf);
		else
			fprintf(1, "(end of file received)\n");
  8000ac:	83 ec 08             	sub    $0x8,%esp
  8000af:	68 d0 20 80 00       	push   $0x8020d0
  8000b4:	6a 01                	push   $0x1
  8000b6:	e8 b6 18 00 00       	call   801971 <fprintf>
  8000bb:	83 c4 10             	add    $0x10,%esp
		buf = readline("Type a line: ");
  8000be:	83 ec 0c             	sub    $0xc,%esp
  8000c1:	68 be 20 80 00       	push   $0x8020be
  8000c6:	e8 bc 08 00 00       	call   800987 <readline>
		if (buf != NULL)
  8000cb:	83 c4 10             	add    $0x10,%esp
  8000ce:	85 c0                	test   %eax,%eax
  8000d0:	74 da                	je     8000ac <umain+0x79>
			fprintf(1, "%s\n", buf);
  8000d2:	83 ec 04             	sub    $0x4,%esp
  8000d5:	50                   	push   %eax
  8000d6:	68 cc 20 80 00       	push   $0x8020cc
  8000db:	6a 01                	push   $0x1
  8000dd:	e8 8f 18 00 00       	call   801971 <fprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
  8000e5:	eb d7                	jmp    8000be <umain+0x8b>

008000e7 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8000ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ef:	5d                   	pop    %ebp
  8000f0:	c3                   	ret    

008000f1 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8000f1:	55                   	push   %ebp
  8000f2:	89 e5                	mov    %esp,%ebp
  8000f4:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8000f7:	68 e8 20 80 00       	push   $0x8020e8
  8000fc:	ff 75 0c             	pushl  0xc(%ebp)
  8000ff:	e8 aa 09 00 00       	call   800aae <strcpy>
	return 0;
}
  800104:	b8 00 00 00 00       	mov    $0x0,%eax
  800109:	c9                   	leave  
  80010a:	c3                   	ret    

0080010b <devcons_write>:
{
  80010b:	55                   	push   %ebp
  80010c:	89 e5                	mov    %esp,%ebp
  80010e:	57                   	push   %edi
  80010f:	56                   	push   %esi
  800110:	53                   	push   %ebx
  800111:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800117:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80011c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800122:	eb 2f                	jmp    800153 <devcons_write+0x48>
		m = n - tot;
  800124:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800127:	29 f3                	sub    %esi,%ebx
  800129:	83 fb 7f             	cmp    $0x7f,%ebx
  80012c:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800131:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800134:	83 ec 04             	sub    $0x4,%esp
  800137:	53                   	push   %ebx
  800138:	89 f0                	mov    %esi,%eax
  80013a:	03 45 0c             	add    0xc(%ebp),%eax
  80013d:	50                   	push   %eax
  80013e:	57                   	push   %edi
  80013f:	e8 f8 0a 00 00       	call   800c3c <memmove>
		sys_cputs(buf, m);
  800144:	83 c4 08             	add    $0x8,%esp
  800147:	53                   	push   %ebx
  800148:	57                   	push   %edi
  800149:	e8 9d 0c 00 00       	call   800deb <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  80014e:	01 de                	add    %ebx,%esi
  800150:	83 c4 10             	add    $0x10,%esp
  800153:	3b 75 10             	cmp    0x10(%ebp),%esi
  800156:	72 cc                	jb     800124 <devcons_write+0x19>
}
  800158:	89 f0                	mov    %esi,%eax
  80015a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <devcons_read>:
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	83 ec 08             	sub    $0x8,%esp
  800168:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  80016d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800171:	75 07                	jne    80017a <devcons_read+0x18>
}
  800173:	c9                   	leave  
  800174:	c3                   	ret    
		sys_yield();
  800175:	e8 0e 0d 00 00       	call   800e88 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  80017a:	e8 8a 0c 00 00       	call   800e09 <sys_cgetc>
  80017f:	85 c0                	test   %eax,%eax
  800181:	74 f2                	je     800175 <devcons_read+0x13>
	if (c < 0)
  800183:	85 c0                	test   %eax,%eax
  800185:	78 ec                	js     800173 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  800187:	83 f8 04             	cmp    $0x4,%eax
  80018a:	74 0c                	je     800198 <devcons_read+0x36>
	*(char*)vbuf = c;
  80018c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80018f:	88 02                	mov    %al,(%edx)
	return 1;
  800191:	b8 01 00 00 00       	mov    $0x1,%eax
  800196:	eb db                	jmp    800173 <devcons_read+0x11>
		return 0;
  800198:	b8 00 00 00 00       	mov    $0x0,%eax
  80019d:	eb d4                	jmp    800173 <devcons_read+0x11>

0080019f <cputchar>:
{
  80019f:	55                   	push   %ebp
  8001a0:	89 e5                	mov    %esp,%ebp
  8001a2:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8001a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a8:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8001ab:	6a 01                	push   $0x1
  8001ad:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8001b0:	50                   	push   %eax
  8001b1:	e8 35 0c 00 00       	call   800deb <sys_cputs>
}
  8001b6:	83 c4 10             	add    $0x10,%esp
  8001b9:	c9                   	leave  
  8001ba:	c3                   	ret    

008001bb <getchar>:
{
  8001bb:	55                   	push   %ebp
  8001bc:	89 e5                	mov    %esp,%ebp
  8001be:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  8001c1:	6a 01                	push   $0x1
  8001c3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8001c6:	50                   	push   %eax
  8001c7:	6a 00                	push   $0x0
  8001c9:	e8 b1 11 00 00       	call   80137f <read>
	if (r < 0)
  8001ce:	83 c4 10             	add    $0x10,%esp
  8001d1:	85 c0                	test   %eax,%eax
  8001d3:	78 08                	js     8001dd <getchar+0x22>
	if (r < 1)
  8001d5:	85 c0                	test   %eax,%eax
  8001d7:	7e 06                	jle    8001df <getchar+0x24>
	return c;
  8001d9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  8001dd:	c9                   	leave  
  8001de:	c3                   	ret    
		return -E_EOF;
  8001df:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  8001e4:	eb f7                	jmp    8001dd <getchar+0x22>

008001e6 <iscons>:
{
  8001e6:	55                   	push   %ebp
  8001e7:	89 e5                	mov    %esp,%ebp
  8001e9:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8001ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8001ef:	50                   	push   %eax
  8001f0:	ff 75 08             	pushl  0x8(%ebp)
  8001f3:	e8 16 0f 00 00       	call   80110e <fd_lookup>
  8001f8:	83 c4 10             	add    $0x10,%esp
  8001fb:	85 c0                	test   %eax,%eax
  8001fd:	78 11                	js     800210 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  8001ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800202:	8b 15 00 30 80 00    	mov    0x803000,%edx
  800208:	39 10                	cmp    %edx,(%eax)
  80020a:	0f 94 c0             	sete   %al
  80020d:	0f b6 c0             	movzbl %al,%eax
}
  800210:	c9                   	leave  
  800211:	c3                   	ret    

00800212 <opencons>:
{
  800212:	55                   	push   %ebp
  800213:	89 e5                	mov    %esp,%ebp
  800215:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  800218:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80021b:	50                   	push   %eax
  80021c:	e8 9e 0e 00 00       	call   8010bf <fd_alloc>
  800221:	83 c4 10             	add    $0x10,%esp
  800224:	85 c0                	test   %eax,%eax
  800226:	78 3a                	js     800262 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800228:	83 ec 04             	sub    $0x4,%esp
  80022b:	68 07 04 00 00       	push   $0x407
  800230:	ff 75 f4             	pushl  -0xc(%ebp)
  800233:	6a 00                	push   $0x0
  800235:	e8 6d 0c 00 00       	call   800ea7 <sys_page_alloc>
  80023a:	83 c4 10             	add    $0x10,%esp
  80023d:	85 c0                	test   %eax,%eax
  80023f:	78 21                	js     800262 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  800241:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800244:	8b 15 00 30 80 00    	mov    0x803000,%edx
  80024a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80024c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80024f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800256:	83 ec 0c             	sub    $0xc,%esp
  800259:	50                   	push   %eax
  80025a:	e8 39 0e 00 00       	call   801098 <fd2num>
  80025f:	83 c4 10             	add    $0x10,%esp
}
  800262:	c9                   	leave  
  800263:	c3                   	ret    

00800264 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800264:	55                   	push   %ebp
  800265:	89 e5                	mov    %esp,%ebp
  800267:	56                   	push   %esi
  800268:	53                   	push   %ebx
  800269:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80026c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80026f:	e8 f5 0b 00 00       	call   800e69 <sys_getenvid>
  800274:	25 ff 03 00 00       	and    $0x3ff,%eax
  800279:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80027c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800281:	a3 04 44 80 00       	mov    %eax,0x804404
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800286:	85 db                	test   %ebx,%ebx
  800288:	7e 07                	jle    800291 <libmain+0x2d>
		binaryname = argv[0];
  80028a:	8b 06                	mov    (%esi),%eax
  80028c:	a3 1c 30 80 00       	mov    %eax,0x80301c

	// call user main routine
	umain(argc, argv);
  800291:	83 ec 08             	sub    $0x8,%esp
  800294:	56                   	push   %esi
  800295:	53                   	push   %ebx
  800296:	e8 98 fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80029b:	e8 0a 00 00 00       	call   8002aa <exit>
}
  8002a0:	83 c4 10             	add    $0x10,%esp
  8002a3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002a6:	5b                   	pop    %ebx
  8002a7:	5e                   	pop    %esi
  8002a8:	5d                   	pop    %ebp
  8002a9:	c3                   	ret    

008002aa <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002aa:	55                   	push   %ebp
  8002ab:	89 e5                	mov    %esp,%ebp
  8002ad:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8002b0:	e8 b9 0f 00 00       	call   80126e <close_all>
	sys_env_destroy(0);
  8002b5:	83 ec 0c             	sub    $0xc,%esp
  8002b8:	6a 00                	push   $0x0
  8002ba:	e8 69 0b 00 00       	call   800e28 <sys_env_destroy>
}
  8002bf:	83 c4 10             	add    $0x10,%esp
  8002c2:	c9                   	leave  
  8002c3:	c3                   	ret    

008002c4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	56                   	push   %esi
  8002c8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002c9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002cc:	8b 35 1c 30 80 00    	mov    0x80301c,%esi
  8002d2:	e8 92 0b 00 00       	call   800e69 <sys_getenvid>
  8002d7:	83 ec 0c             	sub    $0xc,%esp
  8002da:	ff 75 0c             	pushl  0xc(%ebp)
  8002dd:	ff 75 08             	pushl  0x8(%ebp)
  8002e0:	56                   	push   %esi
  8002e1:	50                   	push   %eax
  8002e2:	68 00 21 80 00       	push   $0x802100
  8002e7:	e8 b3 00 00 00       	call   80039f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002ec:	83 c4 18             	add    $0x18,%esp
  8002ef:	53                   	push   %ebx
  8002f0:	ff 75 10             	pushl  0x10(%ebp)
  8002f3:	e8 56 00 00 00       	call   80034e <vcprintf>
	cprintf("\n");
  8002f8:	c7 04 24 e6 20 80 00 	movl   $0x8020e6,(%esp)
  8002ff:	e8 9b 00 00 00       	call   80039f <cprintf>
  800304:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800307:	cc                   	int3   
  800308:	eb fd                	jmp    800307 <_panic+0x43>

0080030a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	53                   	push   %ebx
  80030e:	83 ec 04             	sub    $0x4,%esp
  800311:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800314:	8b 13                	mov    (%ebx),%edx
  800316:	8d 42 01             	lea    0x1(%edx),%eax
  800319:	89 03                	mov    %eax,(%ebx)
  80031b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80031e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800322:	3d ff 00 00 00       	cmp    $0xff,%eax
  800327:	74 09                	je     800332 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800329:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80032d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800330:	c9                   	leave  
  800331:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800332:	83 ec 08             	sub    $0x8,%esp
  800335:	68 ff 00 00 00       	push   $0xff
  80033a:	8d 43 08             	lea    0x8(%ebx),%eax
  80033d:	50                   	push   %eax
  80033e:	e8 a8 0a 00 00       	call   800deb <sys_cputs>
		b->idx = 0;
  800343:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800349:	83 c4 10             	add    $0x10,%esp
  80034c:	eb db                	jmp    800329 <putch+0x1f>

0080034e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80034e:	55                   	push   %ebp
  80034f:	89 e5                	mov    %esp,%ebp
  800351:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800357:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80035e:	00 00 00 
	b.cnt = 0;
  800361:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800368:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80036b:	ff 75 0c             	pushl  0xc(%ebp)
  80036e:	ff 75 08             	pushl  0x8(%ebp)
  800371:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800377:	50                   	push   %eax
  800378:	68 0a 03 80 00       	push   $0x80030a
  80037d:	e8 1a 01 00 00       	call   80049c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800382:	83 c4 08             	add    $0x8,%esp
  800385:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80038b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800391:	50                   	push   %eax
  800392:	e8 54 0a 00 00       	call   800deb <sys_cputs>

	return b.cnt;
}
  800397:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80039d:	c9                   	leave  
  80039e:	c3                   	ret    

0080039f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80039f:	55                   	push   %ebp
  8003a0:	89 e5                	mov    %esp,%ebp
  8003a2:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003a5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003a8:	50                   	push   %eax
  8003a9:	ff 75 08             	pushl  0x8(%ebp)
  8003ac:	e8 9d ff ff ff       	call   80034e <vcprintf>
	va_end(ap);

	return cnt;
}
  8003b1:	c9                   	leave  
  8003b2:	c3                   	ret    

008003b3 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003b3:	55                   	push   %ebp
  8003b4:	89 e5                	mov    %esp,%ebp
  8003b6:	57                   	push   %edi
  8003b7:	56                   	push   %esi
  8003b8:	53                   	push   %ebx
  8003b9:	83 ec 1c             	sub    $0x1c,%esp
  8003bc:	89 c7                	mov    %eax,%edi
  8003be:	89 d6                	mov    %edx,%esi
  8003c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003c9:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003cc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8003cf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003d4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003d7:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8003da:	39 d3                	cmp    %edx,%ebx
  8003dc:	72 05                	jb     8003e3 <printnum+0x30>
  8003de:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003e1:	77 7a                	ja     80045d <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003e3:	83 ec 0c             	sub    $0xc,%esp
  8003e6:	ff 75 18             	pushl  0x18(%ebp)
  8003e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ec:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8003ef:	53                   	push   %ebx
  8003f0:	ff 75 10             	pushl  0x10(%ebp)
  8003f3:	83 ec 08             	sub    $0x8,%esp
  8003f6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003f9:	ff 75 e0             	pushl  -0x20(%ebp)
  8003fc:	ff 75 dc             	pushl  -0x24(%ebp)
  8003ff:	ff 75 d8             	pushl  -0x28(%ebp)
  800402:	e8 29 1a 00 00       	call   801e30 <__udivdi3>
  800407:	83 c4 18             	add    $0x18,%esp
  80040a:	52                   	push   %edx
  80040b:	50                   	push   %eax
  80040c:	89 f2                	mov    %esi,%edx
  80040e:	89 f8                	mov    %edi,%eax
  800410:	e8 9e ff ff ff       	call   8003b3 <printnum>
  800415:	83 c4 20             	add    $0x20,%esp
  800418:	eb 13                	jmp    80042d <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80041a:	83 ec 08             	sub    $0x8,%esp
  80041d:	56                   	push   %esi
  80041e:	ff 75 18             	pushl  0x18(%ebp)
  800421:	ff d7                	call   *%edi
  800423:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800426:	83 eb 01             	sub    $0x1,%ebx
  800429:	85 db                	test   %ebx,%ebx
  80042b:	7f ed                	jg     80041a <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80042d:	83 ec 08             	sub    $0x8,%esp
  800430:	56                   	push   %esi
  800431:	83 ec 04             	sub    $0x4,%esp
  800434:	ff 75 e4             	pushl  -0x1c(%ebp)
  800437:	ff 75 e0             	pushl  -0x20(%ebp)
  80043a:	ff 75 dc             	pushl  -0x24(%ebp)
  80043d:	ff 75 d8             	pushl  -0x28(%ebp)
  800440:	e8 0b 1b 00 00       	call   801f50 <__umoddi3>
  800445:	83 c4 14             	add    $0x14,%esp
  800448:	0f be 80 23 21 80 00 	movsbl 0x802123(%eax),%eax
  80044f:	50                   	push   %eax
  800450:	ff d7                	call   *%edi
}
  800452:	83 c4 10             	add    $0x10,%esp
  800455:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800458:	5b                   	pop    %ebx
  800459:	5e                   	pop    %esi
  80045a:	5f                   	pop    %edi
  80045b:	5d                   	pop    %ebp
  80045c:	c3                   	ret    
  80045d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800460:	eb c4                	jmp    800426 <printnum+0x73>

00800462 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800462:	55                   	push   %ebp
  800463:	89 e5                	mov    %esp,%ebp
  800465:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800468:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80046c:	8b 10                	mov    (%eax),%edx
  80046e:	3b 50 04             	cmp    0x4(%eax),%edx
  800471:	73 0a                	jae    80047d <sprintputch+0x1b>
		*b->buf++ = ch;
  800473:	8d 4a 01             	lea    0x1(%edx),%ecx
  800476:	89 08                	mov    %ecx,(%eax)
  800478:	8b 45 08             	mov    0x8(%ebp),%eax
  80047b:	88 02                	mov    %al,(%edx)
}
  80047d:	5d                   	pop    %ebp
  80047e:	c3                   	ret    

0080047f <printfmt>:
{
  80047f:	55                   	push   %ebp
  800480:	89 e5                	mov    %esp,%ebp
  800482:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800485:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800488:	50                   	push   %eax
  800489:	ff 75 10             	pushl  0x10(%ebp)
  80048c:	ff 75 0c             	pushl  0xc(%ebp)
  80048f:	ff 75 08             	pushl  0x8(%ebp)
  800492:	e8 05 00 00 00       	call   80049c <vprintfmt>
}
  800497:	83 c4 10             	add    $0x10,%esp
  80049a:	c9                   	leave  
  80049b:	c3                   	ret    

0080049c <vprintfmt>:
{
  80049c:	55                   	push   %ebp
  80049d:	89 e5                	mov    %esp,%ebp
  80049f:	57                   	push   %edi
  8004a0:	56                   	push   %esi
  8004a1:	53                   	push   %ebx
  8004a2:	83 ec 2c             	sub    $0x2c,%esp
  8004a5:	8b 75 08             	mov    0x8(%ebp),%esi
  8004a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004ab:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004ae:	e9 c1 03 00 00       	jmp    800874 <vprintfmt+0x3d8>
		padc = ' ';
  8004b3:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8004b7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8004be:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8004c5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8004cc:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8004d1:	8d 47 01             	lea    0x1(%edi),%eax
  8004d4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004d7:	0f b6 17             	movzbl (%edi),%edx
  8004da:	8d 42 dd             	lea    -0x23(%edx),%eax
  8004dd:	3c 55                	cmp    $0x55,%al
  8004df:	0f 87 12 04 00 00    	ja     8008f7 <vprintfmt+0x45b>
  8004e5:	0f b6 c0             	movzbl %al,%eax
  8004e8:	ff 24 85 60 22 80 00 	jmp    *0x802260(,%eax,4)
  8004ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8004f2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8004f6:	eb d9                	jmp    8004d1 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8004f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  8004fb:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004ff:	eb d0                	jmp    8004d1 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800501:	0f b6 d2             	movzbl %dl,%edx
  800504:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800507:	b8 00 00 00 00       	mov    $0x0,%eax
  80050c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80050f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800512:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800516:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800519:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80051c:	83 f9 09             	cmp    $0x9,%ecx
  80051f:	77 55                	ja     800576 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800521:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800524:	eb e9                	jmp    80050f <vprintfmt+0x73>
			precision = va_arg(ap, int);
  800526:	8b 45 14             	mov    0x14(%ebp),%eax
  800529:	8b 00                	mov    (%eax),%eax
  80052b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80052e:	8b 45 14             	mov    0x14(%ebp),%eax
  800531:	8d 40 04             	lea    0x4(%eax),%eax
  800534:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800537:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80053a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80053e:	79 91                	jns    8004d1 <vprintfmt+0x35>
				width = precision, precision = -1;
  800540:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800543:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800546:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80054d:	eb 82                	jmp    8004d1 <vprintfmt+0x35>
  80054f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800552:	85 c0                	test   %eax,%eax
  800554:	ba 00 00 00 00       	mov    $0x0,%edx
  800559:	0f 49 d0             	cmovns %eax,%edx
  80055c:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80055f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800562:	e9 6a ff ff ff       	jmp    8004d1 <vprintfmt+0x35>
  800567:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80056a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800571:	e9 5b ff ff ff       	jmp    8004d1 <vprintfmt+0x35>
  800576:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800579:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80057c:	eb bc                	jmp    80053a <vprintfmt+0x9e>
			lflag++;
  80057e:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800581:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800584:	e9 48 ff ff ff       	jmp    8004d1 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  800589:	8b 45 14             	mov    0x14(%ebp),%eax
  80058c:	8d 78 04             	lea    0x4(%eax),%edi
  80058f:	83 ec 08             	sub    $0x8,%esp
  800592:	53                   	push   %ebx
  800593:	ff 30                	pushl  (%eax)
  800595:	ff d6                	call   *%esi
			break;
  800597:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80059a:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80059d:	e9 cf 02 00 00       	jmp    800871 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  8005a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a5:	8d 78 04             	lea    0x4(%eax),%edi
  8005a8:	8b 00                	mov    (%eax),%eax
  8005aa:	99                   	cltd   
  8005ab:	31 d0                	xor    %edx,%eax
  8005ad:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005af:	83 f8 0f             	cmp    $0xf,%eax
  8005b2:	7f 23                	jg     8005d7 <vprintfmt+0x13b>
  8005b4:	8b 14 85 c0 23 80 00 	mov    0x8023c0(,%eax,4),%edx
  8005bb:	85 d2                	test   %edx,%edx
  8005bd:	74 18                	je     8005d7 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8005bf:	52                   	push   %edx
  8005c0:	68 05 25 80 00       	push   $0x802505
  8005c5:	53                   	push   %ebx
  8005c6:	56                   	push   %esi
  8005c7:	e8 b3 fe ff ff       	call   80047f <printfmt>
  8005cc:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8005cf:	89 7d 14             	mov    %edi,0x14(%ebp)
  8005d2:	e9 9a 02 00 00       	jmp    800871 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  8005d7:	50                   	push   %eax
  8005d8:	68 3b 21 80 00       	push   $0x80213b
  8005dd:	53                   	push   %ebx
  8005de:	56                   	push   %esi
  8005df:	e8 9b fe ff ff       	call   80047f <printfmt>
  8005e4:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8005e7:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8005ea:	e9 82 02 00 00       	jmp    800871 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  8005ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f2:	83 c0 04             	add    $0x4,%eax
  8005f5:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8005f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fb:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005fd:	85 ff                	test   %edi,%edi
  8005ff:	b8 34 21 80 00       	mov    $0x802134,%eax
  800604:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800607:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80060b:	0f 8e bd 00 00 00    	jle    8006ce <vprintfmt+0x232>
  800611:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800615:	75 0e                	jne    800625 <vprintfmt+0x189>
  800617:	89 75 08             	mov    %esi,0x8(%ebp)
  80061a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80061d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800620:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800623:	eb 6d                	jmp    800692 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  800625:	83 ec 08             	sub    $0x8,%esp
  800628:	ff 75 d0             	pushl  -0x30(%ebp)
  80062b:	57                   	push   %edi
  80062c:	e8 5e 04 00 00       	call   800a8f <strnlen>
  800631:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800634:	29 c1                	sub    %eax,%ecx
  800636:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800639:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80063c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800640:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800643:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800646:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800648:	eb 0f                	jmp    800659 <vprintfmt+0x1bd>
					putch(padc, putdat);
  80064a:	83 ec 08             	sub    $0x8,%esp
  80064d:	53                   	push   %ebx
  80064e:	ff 75 e0             	pushl  -0x20(%ebp)
  800651:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800653:	83 ef 01             	sub    $0x1,%edi
  800656:	83 c4 10             	add    $0x10,%esp
  800659:	85 ff                	test   %edi,%edi
  80065b:	7f ed                	jg     80064a <vprintfmt+0x1ae>
  80065d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800660:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800663:	85 c9                	test   %ecx,%ecx
  800665:	b8 00 00 00 00       	mov    $0x0,%eax
  80066a:	0f 49 c1             	cmovns %ecx,%eax
  80066d:	29 c1                	sub    %eax,%ecx
  80066f:	89 75 08             	mov    %esi,0x8(%ebp)
  800672:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800675:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800678:	89 cb                	mov    %ecx,%ebx
  80067a:	eb 16                	jmp    800692 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  80067c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800680:	75 31                	jne    8006b3 <vprintfmt+0x217>
					putch(ch, putdat);
  800682:	83 ec 08             	sub    $0x8,%esp
  800685:	ff 75 0c             	pushl  0xc(%ebp)
  800688:	50                   	push   %eax
  800689:	ff 55 08             	call   *0x8(%ebp)
  80068c:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80068f:	83 eb 01             	sub    $0x1,%ebx
  800692:	83 c7 01             	add    $0x1,%edi
  800695:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800699:	0f be c2             	movsbl %dl,%eax
  80069c:	85 c0                	test   %eax,%eax
  80069e:	74 59                	je     8006f9 <vprintfmt+0x25d>
  8006a0:	85 f6                	test   %esi,%esi
  8006a2:	78 d8                	js     80067c <vprintfmt+0x1e0>
  8006a4:	83 ee 01             	sub    $0x1,%esi
  8006a7:	79 d3                	jns    80067c <vprintfmt+0x1e0>
  8006a9:	89 df                	mov    %ebx,%edi
  8006ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8006ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006b1:	eb 37                	jmp    8006ea <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8006b3:	0f be d2             	movsbl %dl,%edx
  8006b6:	83 ea 20             	sub    $0x20,%edx
  8006b9:	83 fa 5e             	cmp    $0x5e,%edx
  8006bc:	76 c4                	jbe    800682 <vprintfmt+0x1e6>
					putch('?', putdat);
  8006be:	83 ec 08             	sub    $0x8,%esp
  8006c1:	ff 75 0c             	pushl  0xc(%ebp)
  8006c4:	6a 3f                	push   $0x3f
  8006c6:	ff 55 08             	call   *0x8(%ebp)
  8006c9:	83 c4 10             	add    $0x10,%esp
  8006cc:	eb c1                	jmp    80068f <vprintfmt+0x1f3>
  8006ce:	89 75 08             	mov    %esi,0x8(%ebp)
  8006d1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006d4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006d7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006da:	eb b6                	jmp    800692 <vprintfmt+0x1f6>
				putch(' ', putdat);
  8006dc:	83 ec 08             	sub    $0x8,%esp
  8006df:	53                   	push   %ebx
  8006e0:	6a 20                	push   $0x20
  8006e2:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8006e4:	83 ef 01             	sub    $0x1,%edi
  8006e7:	83 c4 10             	add    $0x10,%esp
  8006ea:	85 ff                	test   %edi,%edi
  8006ec:	7f ee                	jg     8006dc <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  8006ee:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006f1:	89 45 14             	mov    %eax,0x14(%ebp)
  8006f4:	e9 78 01 00 00       	jmp    800871 <vprintfmt+0x3d5>
  8006f9:	89 df                	mov    %ebx,%edi
  8006fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8006fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800701:	eb e7                	jmp    8006ea <vprintfmt+0x24e>
	if (lflag >= 2)
  800703:	83 f9 01             	cmp    $0x1,%ecx
  800706:	7e 3f                	jle    800747 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800708:	8b 45 14             	mov    0x14(%ebp),%eax
  80070b:	8b 50 04             	mov    0x4(%eax),%edx
  80070e:	8b 00                	mov    (%eax),%eax
  800710:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800713:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800716:	8b 45 14             	mov    0x14(%ebp),%eax
  800719:	8d 40 08             	lea    0x8(%eax),%eax
  80071c:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80071f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800723:	79 5c                	jns    800781 <vprintfmt+0x2e5>
				putch('-', putdat);
  800725:	83 ec 08             	sub    $0x8,%esp
  800728:	53                   	push   %ebx
  800729:	6a 2d                	push   $0x2d
  80072b:	ff d6                	call   *%esi
				num = -(long long) num;
  80072d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800730:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800733:	f7 da                	neg    %edx
  800735:	83 d1 00             	adc    $0x0,%ecx
  800738:	f7 d9                	neg    %ecx
  80073a:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80073d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800742:	e9 10 01 00 00       	jmp    800857 <vprintfmt+0x3bb>
	else if (lflag)
  800747:	85 c9                	test   %ecx,%ecx
  800749:	75 1b                	jne    800766 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  80074b:	8b 45 14             	mov    0x14(%ebp),%eax
  80074e:	8b 00                	mov    (%eax),%eax
  800750:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800753:	89 c1                	mov    %eax,%ecx
  800755:	c1 f9 1f             	sar    $0x1f,%ecx
  800758:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80075b:	8b 45 14             	mov    0x14(%ebp),%eax
  80075e:	8d 40 04             	lea    0x4(%eax),%eax
  800761:	89 45 14             	mov    %eax,0x14(%ebp)
  800764:	eb b9                	jmp    80071f <vprintfmt+0x283>
		return va_arg(*ap, long);
  800766:	8b 45 14             	mov    0x14(%ebp),%eax
  800769:	8b 00                	mov    (%eax),%eax
  80076b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80076e:	89 c1                	mov    %eax,%ecx
  800770:	c1 f9 1f             	sar    $0x1f,%ecx
  800773:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800776:	8b 45 14             	mov    0x14(%ebp),%eax
  800779:	8d 40 04             	lea    0x4(%eax),%eax
  80077c:	89 45 14             	mov    %eax,0x14(%ebp)
  80077f:	eb 9e                	jmp    80071f <vprintfmt+0x283>
			num = getint(&ap, lflag);
  800781:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800784:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800787:	b8 0a 00 00 00       	mov    $0xa,%eax
  80078c:	e9 c6 00 00 00       	jmp    800857 <vprintfmt+0x3bb>
	if (lflag >= 2)
  800791:	83 f9 01             	cmp    $0x1,%ecx
  800794:	7e 18                	jle    8007ae <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  800796:	8b 45 14             	mov    0x14(%ebp),%eax
  800799:	8b 10                	mov    (%eax),%edx
  80079b:	8b 48 04             	mov    0x4(%eax),%ecx
  80079e:	8d 40 08             	lea    0x8(%eax),%eax
  8007a1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007a4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007a9:	e9 a9 00 00 00       	jmp    800857 <vprintfmt+0x3bb>
	else if (lflag)
  8007ae:	85 c9                	test   %ecx,%ecx
  8007b0:	75 1a                	jne    8007cc <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  8007b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b5:	8b 10                	mov    (%eax),%edx
  8007b7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007bc:	8d 40 04             	lea    0x4(%eax),%eax
  8007bf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007c2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007c7:	e9 8b 00 00 00       	jmp    800857 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8007cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cf:	8b 10                	mov    (%eax),%edx
  8007d1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007d6:	8d 40 04             	lea    0x4(%eax),%eax
  8007d9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007dc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007e1:	eb 74                	jmp    800857 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8007e3:	83 f9 01             	cmp    $0x1,%ecx
  8007e6:	7e 15                	jle    8007fd <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  8007e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007eb:	8b 10                	mov    (%eax),%edx
  8007ed:	8b 48 04             	mov    0x4(%eax),%ecx
  8007f0:	8d 40 08             	lea    0x8(%eax),%eax
  8007f3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8007f6:	b8 08 00 00 00       	mov    $0x8,%eax
  8007fb:	eb 5a                	jmp    800857 <vprintfmt+0x3bb>
	else if (lflag)
  8007fd:	85 c9                	test   %ecx,%ecx
  8007ff:	75 17                	jne    800818 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  800801:	8b 45 14             	mov    0x14(%ebp),%eax
  800804:	8b 10                	mov    (%eax),%edx
  800806:	b9 00 00 00 00       	mov    $0x0,%ecx
  80080b:	8d 40 04             	lea    0x4(%eax),%eax
  80080e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800811:	b8 08 00 00 00       	mov    $0x8,%eax
  800816:	eb 3f                	jmp    800857 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800818:	8b 45 14             	mov    0x14(%ebp),%eax
  80081b:	8b 10                	mov    (%eax),%edx
  80081d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800822:	8d 40 04             	lea    0x4(%eax),%eax
  800825:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800828:	b8 08 00 00 00       	mov    $0x8,%eax
  80082d:	eb 28                	jmp    800857 <vprintfmt+0x3bb>
			putch('0', putdat);
  80082f:	83 ec 08             	sub    $0x8,%esp
  800832:	53                   	push   %ebx
  800833:	6a 30                	push   $0x30
  800835:	ff d6                	call   *%esi
			putch('x', putdat);
  800837:	83 c4 08             	add    $0x8,%esp
  80083a:	53                   	push   %ebx
  80083b:	6a 78                	push   $0x78
  80083d:	ff d6                	call   *%esi
			num = (unsigned long long)
  80083f:	8b 45 14             	mov    0x14(%ebp),%eax
  800842:	8b 10                	mov    (%eax),%edx
  800844:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800849:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80084c:	8d 40 04             	lea    0x4(%eax),%eax
  80084f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800852:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800857:	83 ec 0c             	sub    $0xc,%esp
  80085a:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80085e:	57                   	push   %edi
  80085f:	ff 75 e0             	pushl  -0x20(%ebp)
  800862:	50                   	push   %eax
  800863:	51                   	push   %ecx
  800864:	52                   	push   %edx
  800865:	89 da                	mov    %ebx,%edx
  800867:	89 f0                	mov    %esi,%eax
  800869:	e8 45 fb ff ff       	call   8003b3 <printnum>
			break;
  80086e:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800871:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800874:	83 c7 01             	add    $0x1,%edi
  800877:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80087b:	83 f8 25             	cmp    $0x25,%eax
  80087e:	0f 84 2f fc ff ff    	je     8004b3 <vprintfmt+0x17>
			if (ch == '\0')
  800884:	85 c0                	test   %eax,%eax
  800886:	0f 84 8b 00 00 00    	je     800917 <vprintfmt+0x47b>
			putch(ch, putdat);
  80088c:	83 ec 08             	sub    $0x8,%esp
  80088f:	53                   	push   %ebx
  800890:	50                   	push   %eax
  800891:	ff d6                	call   *%esi
  800893:	83 c4 10             	add    $0x10,%esp
  800896:	eb dc                	jmp    800874 <vprintfmt+0x3d8>
	if (lflag >= 2)
  800898:	83 f9 01             	cmp    $0x1,%ecx
  80089b:	7e 15                	jle    8008b2 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  80089d:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a0:	8b 10                	mov    (%eax),%edx
  8008a2:	8b 48 04             	mov    0x4(%eax),%ecx
  8008a5:	8d 40 08             	lea    0x8(%eax),%eax
  8008a8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008ab:	b8 10 00 00 00       	mov    $0x10,%eax
  8008b0:	eb a5                	jmp    800857 <vprintfmt+0x3bb>
	else if (lflag)
  8008b2:	85 c9                	test   %ecx,%ecx
  8008b4:	75 17                	jne    8008cd <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  8008b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b9:	8b 10                	mov    (%eax),%edx
  8008bb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008c0:	8d 40 04             	lea    0x4(%eax),%eax
  8008c3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008c6:	b8 10 00 00 00       	mov    $0x10,%eax
  8008cb:	eb 8a                	jmp    800857 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8008cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d0:	8b 10                	mov    (%eax),%edx
  8008d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008d7:	8d 40 04             	lea    0x4(%eax),%eax
  8008da:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008dd:	b8 10 00 00 00       	mov    $0x10,%eax
  8008e2:	e9 70 ff ff ff       	jmp    800857 <vprintfmt+0x3bb>
			putch(ch, putdat);
  8008e7:	83 ec 08             	sub    $0x8,%esp
  8008ea:	53                   	push   %ebx
  8008eb:	6a 25                	push   $0x25
  8008ed:	ff d6                	call   *%esi
			break;
  8008ef:	83 c4 10             	add    $0x10,%esp
  8008f2:	e9 7a ff ff ff       	jmp    800871 <vprintfmt+0x3d5>
			putch('%', putdat);
  8008f7:	83 ec 08             	sub    $0x8,%esp
  8008fa:	53                   	push   %ebx
  8008fb:	6a 25                	push   $0x25
  8008fd:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008ff:	83 c4 10             	add    $0x10,%esp
  800902:	89 f8                	mov    %edi,%eax
  800904:	eb 03                	jmp    800909 <vprintfmt+0x46d>
  800906:	83 e8 01             	sub    $0x1,%eax
  800909:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80090d:	75 f7                	jne    800906 <vprintfmt+0x46a>
  80090f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800912:	e9 5a ff ff ff       	jmp    800871 <vprintfmt+0x3d5>
}
  800917:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80091a:	5b                   	pop    %ebx
  80091b:	5e                   	pop    %esi
  80091c:	5f                   	pop    %edi
  80091d:	5d                   	pop    %ebp
  80091e:	c3                   	ret    

0080091f <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	83 ec 18             	sub    $0x18,%esp
  800925:	8b 45 08             	mov    0x8(%ebp),%eax
  800928:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80092b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80092e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800932:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800935:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80093c:	85 c0                	test   %eax,%eax
  80093e:	74 26                	je     800966 <vsnprintf+0x47>
  800940:	85 d2                	test   %edx,%edx
  800942:	7e 22                	jle    800966 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800944:	ff 75 14             	pushl  0x14(%ebp)
  800947:	ff 75 10             	pushl  0x10(%ebp)
  80094a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80094d:	50                   	push   %eax
  80094e:	68 62 04 80 00       	push   $0x800462
  800953:	e8 44 fb ff ff       	call   80049c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800958:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80095b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80095e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800961:	83 c4 10             	add    $0x10,%esp
}
  800964:	c9                   	leave  
  800965:	c3                   	ret    
		return -E_INVAL;
  800966:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80096b:	eb f7                	jmp    800964 <vsnprintf+0x45>

0080096d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80096d:	55                   	push   %ebp
  80096e:	89 e5                	mov    %esp,%ebp
  800970:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800973:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800976:	50                   	push   %eax
  800977:	ff 75 10             	pushl  0x10(%ebp)
  80097a:	ff 75 0c             	pushl  0xc(%ebp)
  80097d:	ff 75 08             	pushl  0x8(%ebp)
  800980:	e8 9a ff ff ff       	call   80091f <vsnprintf>
	va_end(ap);

	return rc;
}
  800985:	c9                   	leave  
  800986:	c3                   	ret    

00800987 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	57                   	push   %edi
  80098b:	56                   	push   %esi
  80098c:	53                   	push   %ebx
  80098d:	83 ec 0c             	sub    $0xc,%esp
  800990:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  800993:	85 c0                	test   %eax,%eax
  800995:	74 13                	je     8009aa <readline+0x23>
		fprintf(1, "%s", prompt);
  800997:	83 ec 04             	sub    $0x4,%esp
  80099a:	50                   	push   %eax
  80099b:	68 05 25 80 00       	push   $0x802505
  8009a0:	6a 01                	push   $0x1
  8009a2:	e8 ca 0f 00 00       	call   801971 <fprintf>
  8009a7:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  8009aa:	83 ec 0c             	sub    $0xc,%esp
  8009ad:	6a 00                	push   $0x0
  8009af:	e8 32 f8 ff ff       	call   8001e6 <iscons>
  8009b4:	89 c7                	mov    %eax,%edi
  8009b6:	83 c4 10             	add    $0x10,%esp
	i = 0;
  8009b9:	be 00 00 00 00       	mov    $0x0,%esi
  8009be:	eb 4b                	jmp    800a0b <readline+0x84>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  8009c0:	b8 00 00 00 00       	mov    $0x0,%eax
			if (c != -E_EOF)
  8009c5:	83 fb f8             	cmp    $0xfffffff8,%ebx
  8009c8:	75 08                	jne    8009d2 <readline+0x4b>
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
  8009ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009cd:	5b                   	pop    %ebx
  8009ce:	5e                   	pop    %esi
  8009cf:	5f                   	pop    %edi
  8009d0:	5d                   	pop    %ebp
  8009d1:	c3                   	ret    
				cprintf("read error: %e\n", c);
  8009d2:	83 ec 08             	sub    $0x8,%esp
  8009d5:	53                   	push   %ebx
  8009d6:	68 1f 24 80 00       	push   $0x80241f
  8009db:	e8 bf f9 ff ff       	call   80039f <cprintf>
  8009e0:	83 c4 10             	add    $0x10,%esp
			return NULL;
  8009e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e8:	eb e0                	jmp    8009ca <readline+0x43>
			if (echoing)
  8009ea:	85 ff                	test   %edi,%edi
  8009ec:	75 05                	jne    8009f3 <readline+0x6c>
			i--;
  8009ee:	83 ee 01             	sub    $0x1,%esi
  8009f1:	eb 18                	jmp    800a0b <readline+0x84>
				cputchar('\b');
  8009f3:	83 ec 0c             	sub    $0xc,%esp
  8009f6:	6a 08                	push   $0x8
  8009f8:	e8 a2 f7 ff ff       	call   80019f <cputchar>
  8009fd:	83 c4 10             	add    $0x10,%esp
  800a00:	eb ec                	jmp    8009ee <readline+0x67>
			buf[i++] = c;
  800a02:	88 9e 00 40 80 00    	mov    %bl,0x804000(%esi)
  800a08:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
  800a0b:	e8 ab f7 ff ff       	call   8001bb <getchar>
  800a10:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  800a12:	85 c0                	test   %eax,%eax
  800a14:	78 aa                	js     8009c0 <readline+0x39>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  800a16:	83 f8 08             	cmp    $0x8,%eax
  800a19:	0f 94 c2             	sete   %dl
  800a1c:	83 f8 7f             	cmp    $0x7f,%eax
  800a1f:	0f 94 c0             	sete   %al
  800a22:	08 c2                	or     %al,%dl
  800a24:	74 04                	je     800a2a <readline+0xa3>
  800a26:	85 f6                	test   %esi,%esi
  800a28:	7f c0                	jg     8009ea <readline+0x63>
		} else if (c >= ' ' && i < BUFLEN-1) {
  800a2a:	83 fb 1f             	cmp    $0x1f,%ebx
  800a2d:	7e 1a                	jle    800a49 <readline+0xc2>
  800a2f:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  800a35:	7f 12                	jg     800a49 <readline+0xc2>
			if (echoing)
  800a37:	85 ff                	test   %edi,%edi
  800a39:	74 c7                	je     800a02 <readline+0x7b>
				cputchar(c);
  800a3b:	83 ec 0c             	sub    $0xc,%esp
  800a3e:	53                   	push   %ebx
  800a3f:	e8 5b f7 ff ff       	call   80019f <cputchar>
  800a44:	83 c4 10             	add    $0x10,%esp
  800a47:	eb b9                	jmp    800a02 <readline+0x7b>
		} else if (c == '\n' || c == '\r') {
  800a49:	83 fb 0a             	cmp    $0xa,%ebx
  800a4c:	74 05                	je     800a53 <readline+0xcc>
  800a4e:	83 fb 0d             	cmp    $0xd,%ebx
  800a51:	75 b8                	jne    800a0b <readline+0x84>
			if (echoing)
  800a53:	85 ff                	test   %edi,%edi
  800a55:	75 11                	jne    800a68 <readline+0xe1>
			buf[i] = 0;
  800a57:	c6 86 00 40 80 00 00 	movb   $0x0,0x804000(%esi)
			return buf;
  800a5e:	b8 00 40 80 00       	mov    $0x804000,%eax
  800a63:	e9 62 ff ff ff       	jmp    8009ca <readline+0x43>
				cputchar('\n');
  800a68:	83 ec 0c             	sub    $0xc,%esp
  800a6b:	6a 0a                	push   $0xa
  800a6d:	e8 2d f7 ff ff       	call   80019f <cputchar>
  800a72:	83 c4 10             	add    $0x10,%esp
  800a75:	eb e0                	jmp    800a57 <readline+0xd0>

00800a77 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a77:	55                   	push   %ebp
  800a78:	89 e5                	mov    %esp,%ebp
  800a7a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a7d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a82:	eb 03                	jmp    800a87 <strlen+0x10>
		n++;
  800a84:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800a87:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a8b:	75 f7                	jne    800a84 <strlen+0xd>
	return n;
}
  800a8d:	5d                   	pop    %ebp
  800a8e:	c3                   	ret    

00800a8f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a8f:	55                   	push   %ebp
  800a90:	89 e5                	mov    %esp,%ebp
  800a92:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a95:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a98:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9d:	eb 03                	jmp    800aa2 <strnlen+0x13>
		n++;
  800a9f:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800aa2:	39 d0                	cmp    %edx,%eax
  800aa4:	74 06                	je     800aac <strnlen+0x1d>
  800aa6:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800aaa:	75 f3                	jne    800a9f <strnlen+0x10>
	return n;
}
  800aac:	5d                   	pop    %ebp
  800aad:	c3                   	ret    

00800aae <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800aae:	55                   	push   %ebp
  800aaf:	89 e5                	mov    %esp,%ebp
  800ab1:	53                   	push   %ebx
  800ab2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ab8:	89 c2                	mov    %eax,%edx
  800aba:	83 c1 01             	add    $0x1,%ecx
  800abd:	83 c2 01             	add    $0x1,%edx
  800ac0:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800ac4:	88 5a ff             	mov    %bl,-0x1(%edx)
  800ac7:	84 db                	test   %bl,%bl
  800ac9:	75 ef                	jne    800aba <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800acb:	5b                   	pop    %ebx
  800acc:	5d                   	pop    %ebp
  800acd:	c3                   	ret    

00800ace <strcat>:

char *
strcat(char *dst, const char *src)
{
  800ace:	55                   	push   %ebp
  800acf:	89 e5                	mov    %esp,%ebp
  800ad1:	53                   	push   %ebx
  800ad2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ad5:	53                   	push   %ebx
  800ad6:	e8 9c ff ff ff       	call   800a77 <strlen>
  800adb:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800ade:	ff 75 0c             	pushl  0xc(%ebp)
  800ae1:	01 d8                	add    %ebx,%eax
  800ae3:	50                   	push   %eax
  800ae4:	e8 c5 ff ff ff       	call   800aae <strcpy>
	return dst;
}
  800ae9:	89 d8                	mov    %ebx,%eax
  800aeb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800aee:	c9                   	leave  
  800aef:	c3                   	ret    

00800af0 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800af0:	55                   	push   %ebp
  800af1:	89 e5                	mov    %esp,%ebp
  800af3:	56                   	push   %esi
  800af4:	53                   	push   %ebx
  800af5:	8b 75 08             	mov    0x8(%ebp),%esi
  800af8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800afb:	89 f3                	mov    %esi,%ebx
  800afd:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b00:	89 f2                	mov    %esi,%edx
  800b02:	eb 0f                	jmp    800b13 <strncpy+0x23>
		*dst++ = *src;
  800b04:	83 c2 01             	add    $0x1,%edx
  800b07:	0f b6 01             	movzbl (%ecx),%eax
  800b0a:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b0d:	80 39 01             	cmpb   $0x1,(%ecx)
  800b10:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800b13:	39 da                	cmp    %ebx,%edx
  800b15:	75 ed                	jne    800b04 <strncpy+0x14>
	}
	return ret;
}
  800b17:	89 f0                	mov    %esi,%eax
  800b19:	5b                   	pop    %ebx
  800b1a:	5e                   	pop    %esi
  800b1b:	5d                   	pop    %ebp
  800b1c:	c3                   	ret    

00800b1d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b1d:	55                   	push   %ebp
  800b1e:	89 e5                	mov    %esp,%ebp
  800b20:	56                   	push   %esi
  800b21:	53                   	push   %ebx
  800b22:	8b 75 08             	mov    0x8(%ebp),%esi
  800b25:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b28:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b2b:	89 f0                	mov    %esi,%eax
  800b2d:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b31:	85 c9                	test   %ecx,%ecx
  800b33:	75 0b                	jne    800b40 <strlcpy+0x23>
  800b35:	eb 17                	jmp    800b4e <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b37:	83 c2 01             	add    $0x1,%edx
  800b3a:	83 c0 01             	add    $0x1,%eax
  800b3d:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800b40:	39 d8                	cmp    %ebx,%eax
  800b42:	74 07                	je     800b4b <strlcpy+0x2e>
  800b44:	0f b6 0a             	movzbl (%edx),%ecx
  800b47:	84 c9                	test   %cl,%cl
  800b49:	75 ec                	jne    800b37 <strlcpy+0x1a>
		*dst = '\0';
  800b4b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b4e:	29 f0                	sub    %esi,%eax
}
  800b50:	5b                   	pop    %ebx
  800b51:	5e                   	pop    %esi
  800b52:	5d                   	pop    %ebp
  800b53:	c3                   	ret    

00800b54 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b54:	55                   	push   %ebp
  800b55:	89 e5                	mov    %esp,%ebp
  800b57:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b5a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b5d:	eb 06                	jmp    800b65 <strcmp+0x11>
		p++, q++;
  800b5f:	83 c1 01             	add    $0x1,%ecx
  800b62:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800b65:	0f b6 01             	movzbl (%ecx),%eax
  800b68:	84 c0                	test   %al,%al
  800b6a:	74 04                	je     800b70 <strcmp+0x1c>
  800b6c:	3a 02                	cmp    (%edx),%al
  800b6e:	74 ef                	je     800b5f <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b70:	0f b6 c0             	movzbl %al,%eax
  800b73:	0f b6 12             	movzbl (%edx),%edx
  800b76:	29 d0                	sub    %edx,%eax
}
  800b78:	5d                   	pop    %ebp
  800b79:	c3                   	ret    

00800b7a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	53                   	push   %ebx
  800b7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b81:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b84:	89 c3                	mov    %eax,%ebx
  800b86:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b89:	eb 06                	jmp    800b91 <strncmp+0x17>
		n--, p++, q++;
  800b8b:	83 c0 01             	add    $0x1,%eax
  800b8e:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b91:	39 d8                	cmp    %ebx,%eax
  800b93:	74 16                	je     800bab <strncmp+0x31>
  800b95:	0f b6 08             	movzbl (%eax),%ecx
  800b98:	84 c9                	test   %cl,%cl
  800b9a:	74 04                	je     800ba0 <strncmp+0x26>
  800b9c:	3a 0a                	cmp    (%edx),%cl
  800b9e:	74 eb                	je     800b8b <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ba0:	0f b6 00             	movzbl (%eax),%eax
  800ba3:	0f b6 12             	movzbl (%edx),%edx
  800ba6:	29 d0                	sub    %edx,%eax
}
  800ba8:	5b                   	pop    %ebx
  800ba9:	5d                   	pop    %ebp
  800baa:	c3                   	ret    
		return 0;
  800bab:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb0:	eb f6                	jmp    800ba8 <strncmp+0x2e>

00800bb2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bb2:	55                   	push   %ebp
  800bb3:	89 e5                	mov    %esp,%ebp
  800bb5:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bbc:	0f b6 10             	movzbl (%eax),%edx
  800bbf:	84 d2                	test   %dl,%dl
  800bc1:	74 09                	je     800bcc <strchr+0x1a>
		if (*s == c)
  800bc3:	38 ca                	cmp    %cl,%dl
  800bc5:	74 0a                	je     800bd1 <strchr+0x1f>
	for (; *s; s++)
  800bc7:	83 c0 01             	add    $0x1,%eax
  800bca:	eb f0                	jmp    800bbc <strchr+0xa>
			return (char *) s;
	return 0;
  800bcc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bd1:	5d                   	pop    %ebp
  800bd2:	c3                   	ret    

00800bd3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bd3:	55                   	push   %ebp
  800bd4:	89 e5                	mov    %esp,%ebp
  800bd6:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bdd:	eb 03                	jmp    800be2 <strfind+0xf>
  800bdf:	83 c0 01             	add    $0x1,%eax
  800be2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800be5:	38 ca                	cmp    %cl,%dl
  800be7:	74 04                	je     800bed <strfind+0x1a>
  800be9:	84 d2                	test   %dl,%dl
  800beb:	75 f2                	jne    800bdf <strfind+0xc>
			break;
	return (char *) s;
}
  800bed:	5d                   	pop    %ebp
  800bee:	c3                   	ret    

00800bef <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bef:	55                   	push   %ebp
  800bf0:	89 e5                	mov    %esp,%ebp
  800bf2:	57                   	push   %edi
  800bf3:	56                   	push   %esi
  800bf4:	53                   	push   %ebx
  800bf5:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bf8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bfb:	85 c9                	test   %ecx,%ecx
  800bfd:	74 13                	je     800c12 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bff:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c05:	75 05                	jne    800c0c <memset+0x1d>
  800c07:	f6 c1 03             	test   $0x3,%cl
  800c0a:	74 0d                	je     800c19 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c0c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c0f:	fc                   	cld    
  800c10:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c12:	89 f8                	mov    %edi,%eax
  800c14:	5b                   	pop    %ebx
  800c15:	5e                   	pop    %esi
  800c16:	5f                   	pop    %edi
  800c17:	5d                   	pop    %ebp
  800c18:	c3                   	ret    
		c &= 0xFF;
  800c19:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c1d:	89 d3                	mov    %edx,%ebx
  800c1f:	c1 e3 08             	shl    $0x8,%ebx
  800c22:	89 d0                	mov    %edx,%eax
  800c24:	c1 e0 18             	shl    $0x18,%eax
  800c27:	89 d6                	mov    %edx,%esi
  800c29:	c1 e6 10             	shl    $0x10,%esi
  800c2c:	09 f0                	or     %esi,%eax
  800c2e:	09 c2                	or     %eax,%edx
  800c30:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800c32:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800c35:	89 d0                	mov    %edx,%eax
  800c37:	fc                   	cld    
  800c38:	f3 ab                	rep stos %eax,%es:(%edi)
  800c3a:	eb d6                	jmp    800c12 <memset+0x23>

00800c3c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c3c:	55                   	push   %ebp
  800c3d:	89 e5                	mov    %esp,%ebp
  800c3f:	57                   	push   %edi
  800c40:	56                   	push   %esi
  800c41:	8b 45 08             	mov    0x8(%ebp),%eax
  800c44:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c47:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c4a:	39 c6                	cmp    %eax,%esi
  800c4c:	73 35                	jae    800c83 <memmove+0x47>
  800c4e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c51:	39 c2                	cmp    %eax,%edx
  800c53:	76 2e                	jbe    800c83 <memmove+0x47>
		s += n;
		d += n;
  800c55:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c58:	89 d6                	mov    %edx,%esi
  800c5a:	09 fe                	or     %edi,%esi
  800c5c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c62:	74 0c                	je     800c70 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c64:	83 ef 01             	sub    $0x1,%edi
  800c67:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c6a:	fd                   	std    
  800c6b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c6d:	fc                   	cld    
  800c6e:	eb 21                	jmp    800c91 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c70:	f6 c1 03             	test   $0x3,%cl
  800c73:	75 ef                	jne    800c64 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c75:	83 ef 04             	sub    $0x4,%edi
  800c78:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c7b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c7e:	fd                   	std    
  800c7f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c81:	eb ea                	jmp    800c6d <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c83:	89 f2                	mov    %esi,%edx
  800c85:	09 c2                	or     %eax,%edx
  800c87:	f6 c2 03             	test   $0x3,%dl
  800c8a:	74 09                	je     800c95 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c8c:	89 c7                	mov    %eax,%edi
  800c8e:	fc                   	cld    
  800c8f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c91:	5e                   	pop    %esi
  800c92:	5f                   	pop    %edi
  800c93:	5d                   	pop    %ebp
  800c94:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c95:	f6 c1 03             	test   $0x3,%cl
  800c98:	75 f2                	jne    800c8c <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c9a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c9d:	89 c7                	mov    %eax,%edi
  800c9f:	fc                   	cld    
  800ca0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ca2:	eb ed                	jmp    800c91 <memmove+0x55>

00800ca4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ca7:	ff 75 10             	pushl  0x10(%ebp)
  800caa:	ff 75 0c             	pushl  0xc(%ebp)
  800cad:	ff 75 08             	pushl  0x8(%ebp)
  800cb0:	e8 87 ff ff ff       	call   800c3c <memmove>
}
  800cb5:	c9                   	leave  
  800cb6:	c3                   	ret    

00800cb7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
  800cba:	56                   	push   %esi
  800cbb:	53                   	push   %ebx
  800cbc:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cc2:	89 c6                	mov    %eax,%esi
  800cc4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cc7:	39 f0                	cmp    %esi,%eax
  800cc9:	74 1c                	je     800ce7 <memcmp+0x30>
		if (*s1 != *s2)
  800ccb:	0f b6 08             	movzbl (%eax),%ecx
  800cce:	0f b6 1a             	movzbl (%edx),%ebx
  800cd1:	38 d9                	cmp    %bl,%cl
  800cd3:	75 08                	jne    800cdd <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800cd5:	83 c0 01             	add    $0x1,%eax
  800cd8:	83 c2 01             	add    $0x1,%edx
  800cdb:	eb ea                	jmp    800cc7 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800cdd:	0f b6 c1             	movzbl %cl,%eax
  800ce0:	0f b6 db             	movzbl %bl,%ebx
  800ce3:	29 d8                	sub    %ebx,%eax
  800ce5:	eb 05                	jmp    800cec <memcmp+0x35>
	}

	return 0;
  800ce7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cec:	5b                   	pop    %ebx
  800ced:	5e                   	pop    %esi
  800cee:	5d                   	pop    %ebp
  800cef:	c3                   	ret    

00800cf0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cf0:	55                   	push   %ebp
  800cf1:	89 e5                	mov    %esp,%ebp
  800cf3:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cf9:	89 c2                	mov    %eax,%edx
  800cfb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cfe:	39 d0                	cmp    %edx,%eax
  800d00:	73 09                	jae    800d0b <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d02:	38 08                	cmp    %cl,(%eax)
  800d04:	74 05                	je     800d0b <memfind+0x1b>
	for (; s < ends; s++)
  800d06:	83 c0 01             	add    $0x1,%eax
  800d09:	eb f3                	jmp    800cfe <memfind+0xe>
			break;
	return (void *) s;
}
  800d0b:	5d                   	pop    %ebp
  800d0c:	c3                   	ret    

00800d0d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	57                   	push   %edi
  800d11:	56                   	push   %esi
  800d12:	53                   	push   %ebx
  800d13:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d16:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d19:	eb 03                	jmp    800d1e <strtol+0x11>
		s++;
  800d1b:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800d1e:	0f b6 01             	movzbl (%ecx),%eax
  800d21:	3c 20                	cmp    $0x20,%al
  800d23:	74 f6                	je     800d1b <strtol+0xe>
  800d25:	3c 09                	cmp    $0x9,%al
  800d27:	74 f2                	je     800d1b <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800d29:	3c 2b                	cmp    $0x2b,%al
  800d2b:	74 2e                	je     800d5b <strtol+0x4e>
	int neg = 0;
  800d2d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800d32:	3c 2d                	cmp    $0x2d,%al
  800d34:	74 2f                	je     800d65 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d36:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d3c:	75 05                	jne    800d43 <strtol+0x36>
  800d3e:	80 39 30             	cmpb   $0x30,(%ecx)
  800d41:	74 2c                	je     800d6f <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d43:	85 db                	test   %ebx,%ebx
  800d45:	75 0a                	jne    800d51 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d47:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800d4c:	80 39 30             	cmpb   $0x30,(%ecx)
  800d4f:	74 28                	je     800d79 <strtol+0x6c>
		base = 10;
  800d51:	b8 00 00 00 00       	mov    $0x0,%eax
  800d56:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d59:	eb 50                	jmp    800dab <strtol+0x9e>
		s++;
  800d5b:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800d5e:	bf 00 00 00 00       	mov    $0x0,%edi
  800d63:	eb d1                	jmp    800d36 <strtol+0x29>
		s++, neg = 1;
  800d65:	83 c1 01             	add    $0x1,%ecx
  800d68:	bf 01 00 00 00       	mov    $0x1,%edi
  800d6d:	eb c7                	jmp    800d36 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d6f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d73:	74 0e                	je     800d83 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800d75:	85 db                	test   %ebx,%ebx
  800d77:	75 d8                	jne    800d51 <strtol+0x44>
		s++, base = 8;
  800d79:	83 c1 01             	add    $0x1,%ecx
  800d7c:	bb 08 00 00 00       	mov    $0x8,%ebx
  800d81:	eb ce                	jmp    800d51 <strtol+0x44>
		s += 2, base = 16;
  800d83:	83 c1 02             	add    $0x2,%ecx
  800d86:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d8b:	eb c4                	jmp    800d51 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800d8d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d90:	89 f3                	mov    %esi,%ebx
  800d92:	80 fb 19             	cmp    $0x19,%bl
  800d95:	77 29                	ja     800dc0 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800d97:	0f be d2             	movsbl %dl,%edx
  800d9a:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d9d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800da0:	7d 30                	jge    800dd2 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800da2:	83 c1 01             	add    $0x1,%ecx
  800da5:	0f af 45 10          	imul   0x10(%ebp),%eax
  800da9:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800dab:	0f b6 11             	movzbl (%ecx),%edx
  800dae:	8d 72 d0             	lea    -0x30(%edx),%esi
  800db1:	89 f3                	mov    %esi,%ebx
  800db3:	80 fb 09             	cmp    $0x9,%bl
  800db6:	77 d5                	ja     800d8d <strtol+0x80>
			dig = *s - '0';
  800db8:	0f be d2             	movsbl %dl,%edx
  800dbb:	83 ea 30             	sub    $0x30,%edx
  800dbe:	eb dd                	jmp    800d9d <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800dc0:	8d 72 bf             	lea    -0x41(%edx),%esi
  800dc3:	89 f3                	mov    %esi,%ebx
  800dc5:	80 fb 19             	cmp    $0x19,%bl
  800dc8:	77 08                	ja     800dd2 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800dca:	0f be d2             	movsbl %dl,%edx
  800dcd:	83 ea 37             	sub    $0x37,%edx
  800dd0:	eb cb                	jmp    800d9d <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800dd2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dd6:	74 05                	je     800ddd <strtol+0xd0>
		*endptr = (char *) s;
  800dd8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ddb:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ddd:	89 c2                	mov    %eax,%edx
  800ddf:	f7 da                	neg    %edx
  800de1:	85 ff                	test   %edi,%edi
  800de3:	0f 45 c2             	cmovne %edx,%eax
}
  800de6:	5b                   	pop    %ebx
  800de7:	5e                   	pop    %esi
  800de8:	5f                   	pop    %edi
  800de9:	5d                   	pop    %ebp
  800dea:	c3                   	ret    

00800deb <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800deb:	55                   	push   %ebp
  800dec:	89 e5                	mov    %esp,%ebp
  800dee:	57                   	push   %edi
  800def:	56                   	push   %esi
  800df0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800df1:	b8 00 00 00 00       	mov    $0x0,%eax
  800df6:	8b 55 08             	mov    0x8(%ebp),%edx
  800df9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfc:	89 c3                	mov    %eax,%ebx
  800dfe:	89 c7                	mov    %eax,%edi
  800e00:	89 c6                	mov    %eax,%esi
  800e02:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e04:	5b                   	pop    %ebx
  800e05:	5e                   	pop    %esi
  800e06:	5f                   	pop    %edi
  800e07:	5d                   	pop    %ebp
  800e08:	c3                   	ret    

00800e09 <sys_cgetc>:

int
sys_cgetc(void)
{
  800e09:	55                   	push   %ebp
  800e0a:	89 e5                	mov    %esp,%ebp
  800e0c:	57                   	push   %edi
  800e0d:	56                   	push   %esi
  800e0e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e0f:	ba 00 00 00 00       	mov    $0x0,%edx
  800e14:	b8 01 00 00 00       	mov    $0x1,%eax
  800e19:	89 d1                	mov    %edx,%ecx
  800e1b:	89 d3                	mov    %edx,%ebx
  800e1d:	89 d7                	mov    %edx,%edi
  800e1f:	89 d6                	mov    %edx,%esi
  800e21:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e23:	5b                   	pop    %ebx
  800e24:	5e                   	pop    %esi
  800e25:	5f                   	pop    %edi
  800e26:	5d                   	pop    %ebp
  800e27:	c3                   	ret    

00800e28 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e28:	55                   	push   %ebp
  800e29:	89 e5                	mov    %esp,%ebp
  800e2b:	57                   	push   %edi
  800e2c:	56                   	push   %esi
  800e2d:	53                   	push   %ebx
  800e2e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e31:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e36:	8b 55 08             	mov    0x8(%ebp),%edx
  800e39:	b8 03 00 00 00       	mov    $0x3,%eax
  800e3e:	89 cb                	mov    %ecx,%ebx
  800e40:	89 cf                	mov    %ecx,%edi
  800e42:	89 ce                	mov    %ecx,%esi
  800e44:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e46:	85 c0                	test   %eax,%eax
  800e48:	7f 08                	jg     800e52 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e4d:	5b                   	pop    %ebx
  800e4e:	5e                   	pop    %esi
  800e4f:	5f                   	pop    %edi
  800e50:	5d                   	pop    %ebp
  800e51:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e52:	83 ec 0c             	sub    $0xc,%esp
  800e55:	50                   	push   %eax
  800e56:	6a 03                	push   $0x3
  800e58:	68 2f 24 80 00       	push   $0x80242f
  800e5d:	6a 23                	push   $0x23
  800e5f:	68 4c 24 80 00       	push   $0x80244c
  800e64:	e8 5b f4 ff ff       	call   8002c4 <_panic>

00800e69 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e69:	55                   	push   %ebp
  800e6a:	89 e5                	mov    %esp,%ebp
  800e6c:	57                   	push   %edi
  800e6d:	56                   	push   %esi
  800e6e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e6f:	ba 00 00 00 00       	mov    $0x0,%edx
  800e74:	b8 02 00 00 00       	mov    $0x2,%eax
  800e79:	89 d1                	mov    %edx,%ecx
  800e7b:	89 d3                	mov    %edx,%ebx
  800e7d:	89 d7                	mov    %edx,%edi
  800e7f:	89 d6                	mov    %edx,%esi
  800e81:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e83:	5b                   	pop    %ebx
  800e84:	5e                   	pop    %esi
  800e85:	5f                   	pop    %edi
  800e86:	5d                   	pop    %ebp
  800e87:	c3                   	ret    

00800e88 <sys_yield>:

void
sys_yield(void)
{
  800e88:	55                   	push   %ebp
  800e89:	89 e5                	mov    %esp,%ebp
  800e8b:	57                   	push   %edi
  800e8c:	56                   	push   %esi
  800e8d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e8e:	ba 00 00 00 00       	mov    $0x0,%edx
  800e93:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e98:	89 d1                	mov    %edx,%ecx
  800e9a:	89 d3                	mov    %edx,%ebx
  800e9c:	89 d7                	mov    %edx,%edi
  800e9e:	89 d6                	mov    %edx,%esi
  800ea0:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ea2:	5b                   	pop    %ebx
  800ea3:	5e                   	pop    %esi
  800ea4:	5f                   	pop    %edi
  800ea5:	5d                   	pop    %ebp
  800ea6:	c3                   	ret    

00800ea7 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ea7:	55                   	push   %ebp
  800ea8:	89 e5                	mov    %esp,%ebp
  800eaa:	57                   	push   %edi
  800eab:	56                   	push   %esi
  800eac:	53                   	push   %ebx
  800ead:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800eb0:	be 00 00 00 00       	mov    $0x0,%esi
  800eb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ebb:	b8 04 00 00 00       	mov    $0x4,%eax
  800ec0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ec3:	89 f7                	mov    %esi,%edi
  800ec5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ec7:	85 c0                	test   %eax,%eax
  800ec9:	7f 08                	jg     800ed3 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ecb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ece:	5b                   	pop    %ebx
  800ecf:	5e                   	pop    %esi
  800ed0:	5f                   	pop    %edi
  800ed1:	5d                   	pop    %ebp
  800ed2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed3:	83 ec 0c             	sub    $0xc,%esp
  800ed6:	50                   	push   %eax
  800ed7:	6a 04                	push   $0x4
  800ed9:	68 2f 24 80 00       	push   $0x80242f
  800ede:	6a 23                	push   $0x23
  800ee0:	68 4c 24 80 00       	push   $0x80244c
  800ee5:	e8 da f3 ff ff       	call   8002c4 <_panic>

00800eea <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800eea:	55                   	push   %ebp
  800eeb:	89 e5                	mov    %esp,%ebp
  800eed:	57                   	push   %edi
  800eee:	56                   	push   %esi
  800eef:	53                   	push   %ebx
  800ef0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ef3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef9:	b8 05 00 00 00       	mov    $0x5,%eax
  800efe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f01:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f04:	8b 75 18             	mov    0x18(%ebp),%esi
  800f07:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f09:	85 c0                	test   %eax,%eax
  800f0b:	7f 08                	jg     800f15 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f10:	5b                   	pop    %ebx
  800f11:	5e                   	pop    %esi
  800f12:	5f                   	pop    %edi
  800f13:	5d                   	pop    %ebp
  800f14:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f15:	83 ec 0c             	sub    $0xc,%esp
  800f18:	50                   	push   %eax
  800f19:	6a 05                	push   $0x5
  800f1b:	68 2f 24 80 00       	push   $0x80242f
  800f20:	6a 23                	push   $0x23
  800f22:	68 4c 24 80 00       	push   $0x80244c
  800f27:	e8 98 f3 ff ff       	call   8002c4 <_panic>

00800f2c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f2c:	55                   	push   %ebp
  800f2d:	89 e5                	mov    %esp,%ebp
  800f2f:	57                   	push   %edi
  800f30:	56                   	push   %esi
  800f31:	53                   	push   %ebx
  800f32:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f35:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800f3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f40:	b8 06 00 00 00       	mov    $0x6,%eax
  800f45:	89 df                	mov    %ebx,%edi
  800f47:	89 de                	mov    %ebx,%esi
  800f49:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f4b:	85 c0                	test   %eax,%eax
  800f4d:	7f 08                	jg     800f57 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f52:	5b                   	pop    %ebx
  800f53:	5e                   	pop    %esi
  800f54:	5f                   	pop    %edi
  800f55:	5d                   	pop    %ebp
  800f56:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f57:	83 ec 0c             	sub    $0xc,%esp
  800f5a:	50                   	push   %eax
  800f5b:	6a 06                	push   $0x6
  800f5d:	68 2f 24 80 00       	push   $0x80242f
  800f62:	6a 23                	push   $0x23
  800f64:	68 4c 24 80 00       	push   $0x80244c
  800f69:	e8 56 f3 ff ff       	call   8002c4 <_panic>

00800f6e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f6e:	55                   	push   %ebp
  800f6f:	89 e5                	mov    %esp,%ebp
  800f71:	57                   	push   %edi
  800f72:	56                   	push   %esi
  800f73:	53                   	push   %ebx
  800f74:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f77:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f82:	b8 08 00 00 00       	mov    $0x8,%eax
  800f87:	89 df                	mov    %ebx,%edi
  800f89:	89 de                	mov    %ebx,%esi
  800f8b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f8d:	85 c0                	test   %eax,%eax
  800f8f:	7f 08                	jg     800f99 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f94:	5b                   	pop    %ebx
  800f95:	5e                   	pop    %esi
  800f96:	5f                   	pop    %edi
  800f97:	5d                   	pop    %ebp
  800f98:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f99:	83 ec 0c             	sub    $0xc,%esp
  800f9c:	50                   	push   %eax
  800f9d:	6a 08                	push   $0x8
  800f9f:	68 2f 24 80 00       	push   $0x80242f
  800fa4:	6a 23                	push   $0x23
  800fa6:	68 4c 24 80 00       	push   $0x80244c
  800fab:	e8 14 f3 ff ff       	call   8002c4 <_panic>

00800fb0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800fb0:	55                   	push   %ebp
  800fb1:	89 e5                	mov    %esp,%ebp
  800fb3:	57                   	push   %edi
  800fb4:	56                   	push   %esi
  800fb5:	53                   	push   %ebx
  800fb6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800fb9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc4:	b8 09 00 00 00       	mov    $0x9,%eax
  800fc9:	89 df                	mov    %ebx,%edi
  800fcb:	89 de                	mov    %ebx,%esi
  800fcd:	cd 30                	int    $0x30
	if(check && ret > 0)
  800fcf:	85 c0                	test   %eax,%eax
  800fd1:	7f 08                	jg     800fdb <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800fd3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fd6:	5b                   	pop    %ebx
  800fd7:	5e                   	pop    %esi
  800fd8:	5f                   	pop    %edi
  800fd9:	5d                   	pop    %ebp
  800fda:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800fdb:	83 ec 0c             	sub    $0xc,%esp
  800fde:	50                   	push   %eax
  800fdf:	6a 09                	push   $0x9
  800fe1:	68 2f 24 80 00       	push   $0x80242f
  800fe6:	6a 23                	push   $0x23
  800fe8:	68 4c 24 80 00       	push   $0x80244c
  800fed:	e8 d2 f2 ff ff       	call   8002c4 <_panic>

00800ff2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ff2:	55                   	push   %ebp
  800ff3:	89 e5                	mov    %esp,%ebp
  800ff5:	57                   	push   %edi
  800ff6:	56                   	push   %esi
  800ff7:	53                   	push   %ebx
  800ff8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ffb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801000:	8b 55 08             	mov    0x8(%ebp),%edx
  801003:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801006:	b8 0a 00 00 00       	mov    $0xa,%eax
  80100b:	89 df                	mov    %ebx,%edi
  80100d:	89 de                	mov    %ebx,%esi
  80100f:	cd 30                	int    $0x30
	if(check && ret > 0)
  801011:	85 c0                	test   %eax,%eax
  801013:	7f 08                	jg     80101d <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801015:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801018:	5b                   	pop    %ebx
  801019:	5e                   	pop    %esi
  80101a:	5f                   	pop    %edi
  80101b:	5d                   	pop    %ebp
  80101c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80101d:	83 ec 0c             	sub    $0xc,%esp
  801020:	50                   	push   %eax
  801021:	6a 0a                	push   $0xa
  801023:	68 2f 24 80 00       	push   $0x80242f
  801028:	6a 23                	push   $0x23
  80102a:	68 4c 24 80 00       	push   $0x80244c
  80102f:	e8 90 f2 ff ff       	call   8002c4 <_panic>

00801034 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801034:	55                   	push   %ebp
  801035:	89 e5                	mov    %esp,%ebp
  801037:	57                   	push   %edi
  801038:	56                   	push   %esi
  801039:	53                   	push   %ebx
	asm volatile("int %1\n"
  80103a:	8b 55 08             	mov    0x8(%ebp),%edx
  80103d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801040:	b8 0c 00 00 00       	mov    $0xc,%eax
  801045:	be 00 00 00 00       	mov    $0x0,%esi
  80104a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80104d:	8b 7d 14             	mov    0x14(%ebp),%edi
  801050:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801052:	5b                   	pop    %ebx
  801053:	5e                   	pop    %esi
  801054:	5f                   	pop    %edi
  801055:	5d                   	pop    %ebp
  801056:	c3                   	ret    

00801057 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801057:	55                   	push   %ebp
  801058:	89 e5                	mov    %esp,%ebp
  80105a:	57                   	push   %edi
  80105b:	56                   	push   %esi
  80105c:	53                   	push   %ebx
  80105d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801060:	b9 00 00 00 00       	mov    $0x0,%ecx
  801065:	8b 55 08             	mov    0x8(%ebp),%edx
  801068:	b8 0d 00 00 00       	mov    $0xd,%eax
  80106d:	89 cb                	mov    %ecx,%ebx
  80106f:	89 cf                	mov    %ecx,%edi
  801071:	89 ce                	mov    %ecx,%esi
  801073:	cd 30                	int    $0x30
	if(check && ret > 0)
  801075:	85 c0                	test   %eax,%eax
  801077:	7f 08                	jg     801081 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801079:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80107c:	5b                   	pop    %ebx
  80107d:	5e                   	pop    %esi
  80107e:	5f                   	pop    %edi
  80107f:	5d                   	pop    %ebp
  801080:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801081:	83 ec 0c             	sub    $0xc,%esp
  801084:	50                   	push   %eax
  801085:	6a 0d                	push   $0xd
  801087:	68 2f 24 80 00       	push   $0x80242f
  80108c:	6a 23                	push   $0x23
  80108e:	68 4c 24 80 00       	push   $0x80244c
  801093:	e8 2c f2 ff ff       	call   8002c4 <_panic>

00801098 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801098:	55                   	push   %ebp
  801099:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80109b:	8b 45 08             	mov    0x8(%ebp),%eax
  80109e:	05 00 00 00 30       	add    $0x30000000,%eax
  8010a3:	c1 e8 0c             	shr    $0xc,%eax
}
  8010a6:	5d                   	pop    %ebp
  8010a7:	c3                   	ret    

008010a8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010a8:	55                   	push   %ebp
  8010a9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ae:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8010b3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010b8:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010bd:	5d                   	pop    %ebp
  8010be:	c3                   	ret    

008010bf <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010bf:	55                   	push   %ebp
  8010c0:	89 e5                	mov    %esp,%ebp
  8010c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010c5:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010ca:	89 c2                	mov    %eax,%edx
  8010cc:	c1 ea 16             	shr    $0x16,%edx
  8010cf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010d6:	f6 c2 01             	test   $0x1,%dl
  8010d9:	74 2a                	je     801105 <fd_alloc+0x46>
  8010db:	89 c2                	mov    %eax,%edx
  8010dd:	c1 ea 0c             	shr    $0xc,%edx
  8010e0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010e7:	f6 c2 01             	test   $0x1,%dl
  8010ea:	74 19                	je     801105 <fd_alloc+0x46>
  8010ec:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8010f1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010f6:	75 d2                	jne    8010ca <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010f8:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010fe:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801103:	eb 07                	jmp    80110c <fd_alloc+0x4d>
			*fd_store = fd;
  801105:	89 01                	mov    %eax,(%ecx)
			return 0;
  801107:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80110c:	5d                   	pop    %ebp
  80110d:	c3                   	ret    

0080110e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80110e:	55                   	push   %ebp
  80110f:	89 e5                	mov    %esp,%ebp
  801111:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801114:	83 f8 1f             	cmp    $0x1f,%eax
  801117:	77 36                	ja     80114f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801119:	c1 e0 0c             	shl    $0xc,%eax
  80111c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801121:	89 c2                	mov    %eax,%edx
  801123:	c1 ea 16             	shr    $0x16,%edx
  801126:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80112d:	f6 c2 01             	test   $0x1,%dl
  801130:	74 24                	je     801156 <fd_lookup+0x48>
  801132:	89 c2                	mov    %eax,%edx
  801134:	c1 ea 0c             	shr    $0xc,%edx
  801137:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80113e:	f6 c2 01             	test   $0x1,%dl
  801141:	74 1a                	je     80115d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801143:	8b 55 0c             	mov    0xc(%ebp),%edx
  801146:	89 02                	mov    %eax,(%edx)
	return 0;
  801148:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80114d:	5d                   	pop    %ebp
  80114e:	c3                   	ret    
		return -E_INVAL;
  80114f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801154:	eb f7                	jmp    80114d <fd_lookup+0x3f>
		return -E_INVAL;
  801156:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80115b:	eb f0                	jmp    80114d <fd_lookup+0x3f>
  80115d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801162:	eb e9                	jmp    80114d <fd_lookup+0x3f>

00801164 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801164:	55                   	push   %ebp
  801165:	89 e5                	mov    %esp,%ebp
  801167:	83 ec 08             	sub    $0x8,%esp
  80116a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80116d:	ba dc 24 80 00       	mov    $0x8024dc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801172:	b8 20 30 80 00       	mov    $0x803020,%eax
		if (devtab[i]->dev_id == dev_id) {
  801177:	39 08                	cmp    %ecx,(%eax)
  801179:	74 33                	je     8011ae <dev_lookup+0x4a>
  80117b:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  80117e:	8b 02                	mov    (%edx),%eax
  801180:	85 c0                	test   %eax,%eax
  801182:	75 f3                	jne    801177 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801184:	a1 04 44 80 00       	mov    0x804404,%eax
  801189:	8b 40 48             	mov    0x48(%eax),%eax
  80118c:	83 ec 04             	sub    $0x4,%esp
  80118f:	51                   	push   %ecx
  801190:	50                   	push   %eax
  801191:	68 5c 24 80 00       	push   $0x80245c
  801196:	e8 04 f2 ff ff       	call   80039f <cprintf>
	*dev = 0;
  80119b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80119e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011a4:	83 c4 10             	add    $0x10,%esp
  8011a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011ac:	c9                   	leave  
  8011ad:	c3                   	ret    
			*dev = devtab[i];
  8011ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b1:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b8:	eb f2                	jmp    8011ac <dev_lookup+0x48>

008011ba <fd_close>:
{
  8011ba:	55                   	push   %ebp
  8011bb:	89 e5                	mov    %esp,%ebp
  8011bd:	57                   	push   %edi
  8011be:	56                   	push   %esi
  8011bf:	53                   	push   %ebx
  8011c0:	83 ec 1c             	sub    $0x1c,%esp
  8011c3:	8b 75 08             	mov    0x8(%ebp),%esi
  8011c6:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011c9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8011cc:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011cd:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011d3:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011d6:	50                   	push   %eax
  8011d7:	e8 32 ff ff ff       	call   80110e <fd_lookup>
  8011dc:	89 c3                	mov    %eax,%ebx
  8011de:	83 c4 08             	add    $0x8,%esp
  8011e1:	85 c0                	test   %eax,%eax
  8011e3:	78 05                	js     8011ea <fd_close+0x30>
	    || fd != fd2)
  8011e5:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8011e8:	74 16                	je     801200 <fd_close+0x46>
		return (must_exist ? r : 0);
  8011ea:	89 f8                	mov    %edi,%eax
  8011ec:	84 c0                	test   %al,%al
  8011ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8011f3:	0f 44 d8             	cmove  %eax,%ebx
}
  8011f6:	89 d8                	mov    %ebx,%eax
  8011f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011fb:	5b                   	pop    %ebx
  8011fc:	5e                   	pop    %esi
  8011fd:	5f                   	pop    %edi
  8011fe:	5d                   	pop    %ebp
  8011ff:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801200:	83 ec 08             	sub    $0x8,%esp
  801203:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801206:	50                   	push   %eax
  801207:	ff 36                	pushl  (%esi)
  801209:	e8 56 ff ff ff       	call   801164 <dev_lookup>
  80120e:	89 c3                	mov    %eax,%ebx
  801210:	83 c4 10             	add    $0x10,%esp
  801213:	85 c0                	test   %eax,%eax
  801215:	78 15                	js     80122c <fd_close+0x72>
		if (dev->dev_close)
  801217:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80121a:	8b 40 10             	mov    0x10(%eax),%eax
  80121d:	85 c0                	test   %eax,%eax
  80121f:	74 1b                	je     80123c <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  801221:	83 ec 0c             	sub    $0xc,%esp
  801224:	56                   	push   %esi
  801225:	ff d0                	call   *%eax
  801227:	89 c3                	mov    %eax,%ebx
  801229:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80122c:	83 ec 08             	sub    $0x8,%esp
  80122f:	56                   	push   %esi
  801230:	6a 00                	push   $0x0
  801232:	e8 f5 fc ff ff       	call   800f2c <sys_page_unmap>
	return r;
  801237:	83 c4 10             	add    $0x10,%esp
  80123a:	eb ba                	jmp    8011f6 <fd_close+0x3c>
			r = 0;
  80123c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801241:	eb e9                	jmp    80122c <fd_close+0x72>

00801243 <close>:

int
close(int fdnum)
{
  801243:	55                   	push   %ebp
  801244:	89 e5                	mov    %esp,%ebp
  801246:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801249:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80124c:	50                   	push   %eax
  80124d:	ff 75 08             	pushl  0x8(%ebp)
  801250:	e8 b9 fe ff ff       	call   80110e <fd_lookup>
  801255:	83 c4 08             	add    $0x8,%esp
  801258:	85 c0                	test   %eax,%eax
  80125a:	78 10                	js     80126c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80125c:	83 ec 08             	sub    $0x8,%esp
  80125f:	6a 01                	push   $0x1
  801261:	ff 75 f4             	pushl  -0xc(%ebp)
  801264:	e8 51 ff ff ff       	call   8011ba <fd_close>
  801269:	83 c4 10             	add    $0x10,%esp
}
  80126c:	c9                   	leave  
  80126d:	c3                   	ret    

0080126e <close_all>:

void
close_all(void)
{
  80126e:	55                   	push   %ebp
  80126f:	89 e5                	mov    %esp,%ebp
  801271:	53                   	push   %ebx
  801272:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801275:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80127a:	83 ec 0c             	sub    $0xc,%esp
  80127d:	53                   	push   %ebx
  80127e:	e8 c0 ff ff ff       	call   801243 <close>
	for (i = 0; i < MAXFD; i++)
  801283:	83 c3 01             	add    $0x1,%ebx
  801286:	83 c4 10             	add    $0x10,%esp
  801289:	83 fb 20             	cmp    $0x20,%ebx
  80128c:	75 ec                	jne    80127a <close_all+0xc>
}
  80128e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801291:	c9                   	leave  
  801292:	c3                   	ret    

00801293 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801293:	55                   	push   %ebp
  801294:	89 e5                	mov    %esp,%ebp
  801296:	57                   	push   %edi
  801297:	56                   	push   %esi
  801298:	53                   	push   %ebx
  801299:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80129c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80129f:	50                   	push   %eax
  8012a0:	ff 75 08             	pushl  0x8(%ebp)
  8012a3:	e8 66 fe ff ff       	call   80110e <fd_lookup>
  8012a8:	89 c3                	mov    %eax,%ebx
  8012aa:	83 c4 08             	add    $0x8,%esp
  8012ad:	85 c0                	test   %eax,%eax
  8012af:	0f 88 81 00 00 00    	js     801336 <dup+0xa3>
		return r;
	close(newfdnum);
  8012b5:	83 ec 0c             	sub    $0xc,%esp
  8012b8:	ff 75 0c             	pushl  0xc(%ebp)
  8012bb:	e8 83 ff ff ff       	call   801243 <close>

	newfd = INDEX2FD(newfdnum);
  8012c0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012c3:	c1 e6 0c             	shl    $0xc,%esi
  8012c6:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8012cc:	83 c4 04             	add    $0x4,%esp
  8012cf:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012d2:	e8 d1 fd ff ff       	call   8010a8 <fd2data>
  8012d7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8012d9:	89 34 24             	mov    %esi,(%esp)
  8012dc:	e8 c7 fd ff ff       	call   8010a8 <fd2data>
  8012e1:	83 c4 10             	add    $0x10,%esp
  8012e4:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012e6:	89 d8                	mov    %ebx,%eax
  8012e8:	c1 e8 16             	shr    $0x16,%eax
  8012eb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012f2:	a8 01                	test   $0x1,%al
  8012f4:	74 11                	je     801307 <dup+0x74>
  8012f6:	89 d8                	mov    %ebx,%eax
  8012f8:	c1 e8 0c             	shr    $0xc,%eax
  8012fb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801302:	f6 c2 01             	test   $0x1,%dl
  801305:	75 39                	jne    801340 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801307:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80130a:	89 d0                	mov    %edx,%eax
  80130c:	c1 e8 0c             	shr    $0xc,%eax
  80130f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801316:	83 ec 0c             	sub    $0xc,%esp
  801319:	25 07 0e 00 00       	and    $0xe07,%eax
  80131e:	50                   	push   %eax
  80131f:	56                   	push   %esi
  801320:	6a 00                	push   $0x0
  801322:	52                   	push   %edx
  801323:	6a 00                	push   $0x0
  801325:	e8 c0 fb ff ff       	call   800eea <sys_page_map>
  80132a:	89 c3                	mov    %eax,%ebx
  80132c:	83 c4 20             	add    $0x20,%esp
  80132f:	85 c0                	test   %eax,%eax
  801331:	78 31                	js     801364 <dup+0xd1>
		goto err;

	return newfdnum;
  801333:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801336:	89 d8                	mov    %ebx,%eax
  801338:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80133b:	5b                   	pop    %ebx
  80133c:	5e                   	pop    %esi
  80133d:	5f                   	pop    %edi
  80133e:	5d                   	pop    %ebp
  80133f:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801340:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801347:	83 ec 0c             	sub    $0xc,%esp
  80134a:	25 07 0e 00 00       	and    $0xe07,%eax
  80134f:	50                   	push   %eax
  801350:	57                   	push   %edi
  801351:	6a 00                	push   $0x0
  801353:	53                   	push   %ebx
  801354:	6a 00                	push   $0x0
  801356:	e8 8f fb ff ff       	call   800eea <sys_page_map>
  80135b:	89 c3                	mov    %eax,%ebx
  80135d:	83 c4 20             	add    $0x20,%esp
  801360:	85 c0                	test   %eax,%eax
  801362:	79 a3                	jns    801307 <dup+0x74>
	sys_page_unmap(0, newfd);
  801364:	83 ec 08             	sub    $0x8,%esp
  801367:	56                   	push   %esi
  801368:	6a 00                	push   $0x0
  80136a:	e8 bd fb ff ff       	call   800f2c <sys_page_unmap>
	sys_page_unmap(0, nva);
  80136f:	83 c4 08             	add    $0x8,%esp
  801372:	57                   	push   %edi
  801373:	6a 00                	push   $0x0
  801375:	e8 b2 fb ff ff       	call   800f2c <sys_page_unmap>
	return r;
  80137a:	83 c4 10             	add    $0x10,%esp
  80137d:	eb b7                	jmp    801336 <dup+0xa3>

0080137f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80137f:	55                   	push   %ebp
  801380:	89 e5                	mov    %esp,%ebp
  801382:	53                   	push   %ebx
  801383:	83 ec 14             	sub    $0x14,%esp
  801386:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801389:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80138c:	50                   	push   %eax
  80138d:	53                   	push   %ebx
  80138e:	e8 7b fd ff ff       	call   80110e <fd_lookup>
  801393:	83 c4 08             	add    $0x8,%esp
  801396:	85 c0                	test   %eax,%eax
  801398:	78 3f                	js     8013d9 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80139a:	83 ec 08             	sub    $0x8,%esp
  80139d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a0:	50                   	push   %eax
  8013a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a4:	ff 30                	pushl  (%eax)
  8013a6:	e8 b9 fd ff ff       	call   801164 <dev_lookup>
  8013ab:	83 c4 10             	add    $0x10,%esp
  8013ae:	85 c0                	test   %eax,%eax
  8013b0:	78 27                	js     8013d9 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013b2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013b5:	8b 42 08             	mov    0x8(%edx),%eax
  8013b8:	83 e0 03             	and    $0x3,%eax
  8013bb:	83 f8 01             	cmp    $0x1,%eax
  8013be:	74 1e                	je     8013de <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8013c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013c3:	8b 40 08             	mov    0x8(%eax),%eax
  8013c6:	85 c0                	test   %eax,%eax
  8013c8:	74 35                	je     8013ff <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013ca:	83 ec 04             	sub    $0x4,%esp
  8013cd:	ff 75 10             	pushl  0x10(%ebp)
  8013d0:	ff 75 0c             	pushl  0xc(%ebp)
  8013d3:	52                   	push   %edx
  8013d4:	ff d0                	call   *%eax
  8013d6:	83 c4 10             	add    $0x10,%esp
}
  8013d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013dc:	c9                   	leave  
  8013dd:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013de:	a1 04 44 80 00       	mov    0x804404,%eax
  8013e3:	8b 40 48             	mov    0x48(%eax),%eax
  8013e6:	83 ec 04             	sub    $0x4,%esp
  8013e9:	53                   	push   %ebx
  8013ea:	50                   	push   %eax
  8013eb:	68 a0 24 80 00       	push   $0x8024a0
  8013f0:	e8 aa ef ff ff       	call   80039f <cprintf>
		return -E_INVAL;
  8013f5:	83 c4 10             	add    $0x10,%esp
  8013f8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013fd:	eb da                	jmp    8013d9 <read+0x5a>
		return -E_NOT_SUPP;
  8013ff:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801404:	eb d3                	jmp    8013d9 <read+0x5a>

00801406 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801406:	55                   	push   %ebp
  801407:	89 e5                	mov    %esp,%ebp
  801409:	57                   	push   %edi
  80140a:	56                   	push   %esi
  80140b:	53                   	push   %ebx
  80140c:	83 ec 0c             	sub    $0xc,%esp
  80140f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801412:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801415:	bb 00 00 00 00       	mov    $0x0,%ebx
  80141a:	39 f3                	cmp    %esi,%ebx
  80141c:	73 25                	jae    801443 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80141e:	83 ec 04             	sub    $0x4,%esp
  801421:	89 f0                	mov    %esi,%eax
  801423:	29 d8                	sub    %ebx,%eax
  801425:	50                   	push   %eax
  801426:	89 d8                	mov    %ebx,%eax
  801428:	03 45 0c             	add    0xc(%ebp),%eax
  80142b:	50                   	push   %eax
  80142c:	57                   	push   %edi
  80142d:	e8 4d ff ff ff       	call   80137f <read>
		if (m < 0)
  801432:	83 c4 10             	add    $0x10,%esp
  801435:	85 c0                	test   %eax,%eax
  801437:	78 08                	js     801441 <readn+0x3b>
			return m;
		if (m == 0)
  801439:	85 c0                	test   %eax,%eax
  80143b:	74 06                	je     801443 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  80143d:	01 c3                	add    %eax,%ebx
  80143f:	eb d9                	jmp    80141a <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801441:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801443:	89 d8                	mov    %ebx,%eax
  801445:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801448:	5b                   	pop    %ebx
  801449:	5e                   	pop    %esi
  80144a:	5f                   	pop    %edi
  80144b:	5d                   	pop    %ebp
  80144c:	c3                   	ret    

0080144d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80144d:	55                   	push   %ebp
  80144e:	89 e5                	mov    %esp,%ebp
  801450:	53                   	push   %ebx
  801451:	83 ec 14             	sub    $0x14,%esp
  801454:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801457:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80145a:	50                   	push   %eax
  80145b:	53                   	push   %ebx
  80145c:	e8 ad fc ff ff       	call   80110e <fd_lookup>
  801461:	83 c4 08             	add    $0x8,%esp
  801464:	85 c0                	test   %eax,%eax
  801466:	78 3a                	js     8014a2 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801468:	83 ec 08             	sub    $0x8,%esp
  80146b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80146e:	50                   	push   %eax
  80146f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801472:	ff 30                	pushl  (%eax)
  801474:	e8 eb fc ff ff       	call   801164 <dev_lookup>
  801479:	83 c4 10             	add    $0x10,%esp
  80147c:	85 c0                	test   %eax,%eax
  80147e:	78 22                	js     8014a2 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801480:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801483:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801487:	74 1e                	je     8014a7 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801489:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80148c:	8b 52 0c             	mov    0xc(%edx),%edx
  80148f:	85 d2                	test   %edx,%edx
  801491:	74 35                	je     8014c8 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801493:	83 ec 04             	sub    $0x4,%esp
  801496:	ff 75 10             	pushl  0x10(%ebp)
  801499:	ff 75 0c             	pushl  0xc(%ebp)
  80149c:	50                   	push   %eax
  80149d:	ff d2                	call   *%edx
  80149f:	83 c4 10             	add    $0x10,%esp
}
  8014a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a5:	c9                   	leave  
  8014a6:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014a7:	a1 04 44 80 00       	mov    0x804404,%eax
  8014ac:	8b 40 48             	mov    0x48(%eax),%eax
  8014af:	83 ec 04             	sub    $0x4,%esp
  8014b2:	53                   	push   %ebx
  8014b3:	50                   	push   %eax
  8014b4:	68 bc 24 80 00       	push   $0x8024bc
  8014b9:	e8 e1 ee ff ff       	call   80039f <cprintf>
		return -E_INVAL;
  8014be:	83 c4 10             	add    $0x10,%esp
  8014c1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014c6:	eb da                	jmp    8014a2 <write+0x55>
		return -E_NOT_SUPP;
  8014c8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014cd:	eb d3                	jmp    8014a2 <write+0x55>

008014cf <seek>:

int
seek(int fdnum, off_t offset)
{
  8014cf:	55                   	push   %ebp
  8014d0:	89 e5                	mov    %esp,%ebp
  8014d2:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014d5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014d8:	50                   	push   %eax
  8014d9:	ff 75 08             	pushl  0x8(%ebp)
  8014dc:	e8 2d fc ff ff       	call   80110e <fd_lookup>
  8014e1:	83 c4 08             	add    $0x8,%esp
  8014e4:	85 c0                	test   %eax,%eax
  8014e6:	78 0e                	js     8014f6 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014ee:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014f6:	c9                   	leave  
  8014f7:	c3                   	ret    

008014f8 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
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
  801507:	e8 02 fc ff ff       	call   80110e <fd_lookup>
  80150c:	83 c4 08             	add    $0x8,%esp
  80150f:	85 c0                	test   %eax,%eax
  801511:	78 37                	js     80154a <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801513:	83 ec 08             	sub    $0x8,%esp
  801516:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801519:	50                   	push   %eax
  80151a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80151d:	ff 30                	pushl  (%eax)
  80151f:	e8 40 fc ff ff       	call   801164 <dev_lookup>
  801524:	83 c4 10             	add    $0x10,%esp
  801527:	85 c0                	test   %eax,%eax
  801529:	78 1f                	js     80154a <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80152b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80152e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801532:	74 1b                	je     80154f <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801534:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801537:	8b 52 18             	mov    0x18(%edx),%edx
  80153a:	85 d2                	test   %edx,%edx
  80153c:	74 32                	je     801570 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80153e:	83 ec 08             	sub    $0x8,%esp
  801541:	ff 75 0c             	pushl  0xc(%ebp)
  801544:	50                   	push   %eax
  801545:	ff d2                	call   *%edx
  801547:	83 c4 10             	add    $0x10,%esp
}
  80154a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80154d:	c9                   	leave  
  80154e:	c3                   	ret    
			thisenv->env_id, fdnum);
  80154f:	a1 04 44 80 00       	mov    0x804404,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801554:	8b 40 48             	mov    0x48(%eax),%eax
  801557:	83 ec 04             	sub    $0x4,%esp
  80155a:	53                   	push   %ebx
  80155b:	50                   	push   %eax
  80155c:	68 7c 24 80 00       	push   $0x80247c
  801561:	e8 39 ee ff ff       	call   80039f <cprintf>
		return -E_INVAL;
  801566:	83 c4 10             	add    $0x10,%esp
  801569:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80156e:	eb da                	jmp    80154a <ftruncate+0x52>
		return -E_NOT_SUPP;
  801570:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801575:	eb d3                	jmp    80154a <ftruncate+0x52>

00801577 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801577:	55                   	push   %ebp
  801578:	89 e5                	mov    %esp,%ebp
  80157a:	53                   	push   %ebx
  80157b:	83 ec 14             	sub    $0x14,%esp
  80157e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801581:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801584:	50                   	push   %eax
  801585:	ff 75 08             	pushl  0x8(%ebp)
  801588:	e8 81 fb ff ff       	call   80110e <fd_lookup>
  80158d:	83 c4 08             	add    $0x8,%esp
  801590:	85 c0                	test   %eax,%eax
  801592:	78 4b                	js     8015df <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801594:	83 ec 08             	sub    $0x8,%esp
  801597:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80159a:	50                   	push   %eax
  80159b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80159e:	ff 30                	pushl  (%eax)
  8015a0:	e8 bf fb ff ff       	call   801164 <dev_lookup>
  8015a5:	83 c4 10             	add    $0x10,%esp
  8015a8:	85 c0                	test   %eax,%eax
  8015aa:	78 33                	js     8015df <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  8015ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015af:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015b3:	74 2f                	je     8015e4 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015b5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015b8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015bf:	00 00 00 
	stat->st_isdir = 0;
  8015c2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015c9:	00 00 00 
	stat->st_dev = dev;
  8015cc:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015d2:	83 ec 08             	sub    $0x8,%esp
  8015d5:	53                   	push   %ebx
  8015d6:	ff 75 f0             	pushl  -0x10(%ebp)
  8015d9:	ff 50 14             	call   *0x14(%eax)
  8015dc:	83 c4 10             	add    $0x10,%esp
}
  8015df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015e2:	c9                   	leave  
  8015e3:	c3                   	ret    
		return -E_NOT_SUPP;
  8015e4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015e9:	eb f4                	jmp    8015df <fstat+0x68>

008015eb <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015eb:	55                   	push   %ebp
  8015ec:	89 e5                	mov    %esp,%ebp
  8015ee:	56                   	push   %esi
  8015ef:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015f0:	83 ec 08             	sub    $0x8,%esp
  8015f3:	6a 00                	push   $0x0
  8015f5:	ff 75 08             	pushl  0x8(%ebp)
  8015f8:	e8 e7 01 00 00       	call   8017e4 <open>
  8015fd:	89 c3                	mov    %eax,%ebx
  8015ff:	83 c4 10             	add    $0x10,%esp
  801602:	85 c0                	test   %eax,%eax
  801604:	78 1b                	js     801621 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801606:	83 ec 08             	sub    $0x8,%esp
  801609:	ff 75 0c             	pushl  0xc(%ebp)
  80160c:	50                   	push   %eax
  80160d:	e8 65 ff ff ff       	call   801577 <fstat>
  801612:	89 c6                	mov    %eax,%esi
	close(fd);
  801614:	89 1c 24             	mov    %ebx,(%esp)
  801617:	e8 27 fc ff ff       	call   801243 <close>
	return r;
  80161c:	83 c4 10             	add    $0x10,%esp
  80161f:	89 f3                	mov    %esi,%ebx
}
  801621:	89 d8                	mov    %ebx,%eax
  801623:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801626:	5b                   	pop    %ebx
  801627:	5e                   	pop    %esi
  801628:	5d                   	pop    %ebp
  801629:	c3                   	ret    

0080162a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80162a:	55                   	push   %ebp
  80162b:	89 e5                	mov    %esp,%ebp
  80162d:	56                   	push   %esi
  80162e:	53                   	push   %ebx
  80162f:	89 c6                	mov    %eax,%esi
  801631:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801633:	83 3d 00 44 80 00 00 	cmpl   $0x0,0x804400
  80163a:	74 27                	je     801663 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80163c:	6a 07                	push   $0x7
  80163e:	68 00 50 80 00       	push   $0x805000
  801643:	56                   	push   %esi
  801644:	ff 35 00 44 80 00    	pushl  0x804400
  80164a:	e8 11 07 00 00       	call   801d60 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80164f:	83 c4 0c             	add    $0xc,%esp
  801652:	6a 00                	push   $0x0
  801654:	53                   	push   %ebx
  801655:	6a 00                	push   $0x0
  801657:	e8 8f 06 00 00       	call   801ceb <ipc_recv>
}
  80165c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80165f:	5b                   	pop    %ebx
  801660:	5e                   	pop    %esi
  801661:	5d                   	pop    %ebp
  801662:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801663:	83 ec 0c             	sub    $0xc,%esp
  801666:	6a 01                	push   $0x1
  801668:	e8 49 07 00 00       	call   801db6 <ipc_find_env>
  80166d:	a3 00 44 80 00       	mov    %eax,0x804400
  801672:	83 c4 10             	add    $0x10,%esp
  801675:	eb c5                	jmp    80163c <fsipc+0x12>

00801677 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801677:	55                   	push   %ebp
  801678:	89 e5                	mov    %esp,%ebp
  80167a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80167d:	8b 45 08             	mov    0x8(%ebp),%eax
  801680:	8b 40 0c             	mov    0xc(%eax),%eax
  801683:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801688:	8b 45 0c             	mov    0xc(%ebp),%eax
  80168b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801690:	ba 00 00 00 00       	mov    $0x0,%edx
  801695:	b8 02 00 00 00       	mov    $0x2,%eax
  80169a:	e8 8b ff ff ff       	call   80162a <fsipc>
}
  80169f:	c9                   	leave  
  8016a0:	c3                   	ret    

008016a1 <devfile_flush>:
{
  8016a1:	55                   	push   %ebp
  8016a2:	89 e5                	mov    %esp,%ebp
  8016a4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8016aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8016ad:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b7:	b8 06 00 00 00       	mov    $0x6,%eax
  8016bc:	e8 69 ff ff ff       	call   80162a <fsipc>
}
  8016c1:	c9                   	leave  
  8016c2:	c3                   	ret    

008016c3 <devfile_stat>:
{
  8016c3:	55                   	push   %ebp
  8016c4:	89 e5                	mov    %esp,%ebp
  8016c6:	53                   	push   %ebx
  8016c7:	83 ec 04             	sub    $0x4,%esp
  8016ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d0:	8b 40 0c             	mov    0xc(%eax),%eax
  8016d3:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8016dd:	b8 05 00 00 00       	mov    $0x5,%eax
  8016e2:	e8 43 ff ff ff       	call   80162a <fsipc>
  8016e7:	85 c0                	test   %eax,%eax
  8016e9:	78 2c                	js     801717 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016eb:	83 ec 08             	sub    $0x8,%esp
  8016ee:	68 00 50 80 00       	push   $0x805000
  8016f3:	53                   	push   %ebx
  8016f4:	e8 b5 f3 ff ff       	call   800aae <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016f9:	a1 80 50 80 00       	mov    0x805080,%eax
  8016fe:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801704:	a1 84 50 80 00       	mov    0x805084,%eax
  801709:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80170f:	83 c4 10             	add    $0x10,%esp
  801712:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801717:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80171a:	c9                   	leave  
  80171b:	c3                   	ret    

0080171c <devfile_write>:
{
  80171c:	55                   	push   %ebp
  80171d:	89 e5                	mov    %esp,%ebp
  80171f:	83 ec 0c             	sub    $0xc,%esp
  801722:	8b 45 10             	mov    0x10(%ebp),%eax
  801725:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80172a:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80172f:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801732:	8b 55 08             	mov    0x8(%ebp),%edx
  801735:	8b 52 0c             	mov    0xc(%edx),%edx
  801738:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80173e:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf,buf,n);
  801743:	50                   	push   %eax
  801744:	ff 75 0c             	pushl  0xc(%ebp)
  801747:	68 08 50 80 00       	push   $0x805008
  80174c:	e8 eb f4 ff ff       	call   800c3c <memmove>
	if((r = fsipc(FSREQ_WRITE,NULL))<0)
  801751:	ba 00 00 00 00       	mov    $0x0,%edx
  801756:	b8 04 00 00 00       	mov    $0x4,%eax
  80175b:	e8 ca fe ff ff       	call   80162a <fsipc>
}
  801760:	c9                   	leave  
  801761:	c3                   	ret    

00801762 <devfile_read>:
{
  801762:	55                   	push   %ebp
  801763:	89 e5                	mov    %esp,%ebp
  801765:	56                   	push   %esi
  801766:	53                   	push   %ebx
  801767:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80176a:	8b 45 08             	mov    0x8(%ebp),%eax
  80176d:	8b 40 0c             	mov    0xc(%eax),%eax
  801770:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801775:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80177b:	ba 00 00 00 00       	mov    $0x0,%edx
  801780:	b8 03 00 00 00       	mov    $0x3,%eax
  801785:	e8 a0 fe ff ff       	call   80162a <fsipc>
  80178a:	89 c3                	mov    %eax,%ebx
  80178c:	85 c0                	test   %eax,%eax
  80178e:	78 1f                	js     8017af <devfile_read+0x4d>
	assert(r <= n);
  801790:	39 f0                	cmp    %esi,%eax
  801792:	77 24                	ja     8017b8 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801794:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801799:	7f 33                	jg     8017ce <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80179b:	83 ec 04             	sub    $0x4,%esp
  80179e:	50                   	push   %eax
  80179f:	68 00 50 80 00       	push   $0x805000
  8017a4:	ff 75 0c             	pushl  0xc(%ebp)
  8017a7:	e8 90 f4 ff ff       	call   800c3c <memmove>
	return r;
  8017ac:	83 c4 10             	add    $0x10,%esp
}
  8017af:	89 d8                	mov    %ebx,%eax
  8017b1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017b4:	5b                   	pop    %ebx
  8017b5:	5e                   	pop    %esi
  8017b6:	5d                   	pop    %ebp
  8017b7:	c3                   	ret    
	assert(r <= n);
  8017b8:	68 ec 24 80 00       	push   $0x8024ec
  8017bd:	68 f3 24 80 00       	push   $0x8024f3
  8017c2:	6a 7c                	push   $0x7c
  8017c4:	68 08 25 80 00       	push   $0x802508
  8017c9:	e8 f6 ea ff ff       	call   8002c4 <_panic>
	assert(r <= PGSIZE);
  8017ce:	68 13 25 80 00       	push   $0x802513
  8017d3:	68 f3 24 80 00       	push   $0x8024f3
  8017d8:	6a 7d                	push   $0x7d
  8017da:	68 08 25 80 00       	push   $0x802508
  8017df:	e8 e0 ea ff ff       	call   8002c4 <_panic>

008017e4 <open>:
{
  8017e4:	55                   	push   %ebp
  8017e5:	89 e5                	mov    %esp,%ebp
  8017e7:	56                   	push   %esi
  8017e8:	53                   	push   %ebx
  8017e9:	83 ec 1c             	sub    $0x1c,%esp
  8017ec:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8017ef:	56                   	push   %esi
  8017f0:	e8 82 f2 ff ff       	call   800a77 <strlen>
  8017f5:	83 c4 10             	add    $0x10,%esp
  8017f8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017fd:	7f 6c                	jg     80186b <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8017ff:	83 ec 0c             	sub    $0xc,%esp
  801802:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801805:	50                   	push   %eax
  801806:	e8 b4 f8 ff ff       	call   8010bf <fd_alloc>
  80180b:	89 c3                	mov    %eax,%ebx
  80180d:	83 c4 10             	add    $0x10,%esp
  801810:	85 c0                	test   %eax,%eax
  801812:	78 3c                	js     801850 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801814:	83 ec 08             	sub    $0x8,%esp
  801817:	56                   	push   %esi
  801818:	68 00 50 80 00       	push   $0x805000
  80181d:	e8 8c f2 ff ff       	call   800aae <strcpy>
	fsipcbuf.open.req_omode = mode;
  801822:	8b 45 0c             	mov    0xc(%ebp),%eax
  801825:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80182a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80182d:	b8 01 00 00 00       	mov    $0x1,%eax
  801832:	e8 f3 fd ff ff       	call   80162a <fsipc>
  801837:	89 c3                	mov    %eax,%ebx
  801839:	83 c4 10             	add    $0x10,%esp
  80183c:	85 c0                	test   %eax,%eax
  80183e:	78 19                	js     801859 <open+0x75>
	return fd2num(fd);
  801840:	83 ec 0c             	sub    $0xc,%esp
  801843:	ff 75 f4             	pushl  -0xc(%ebp)
  801846:	e8 4d f8 ff ff       	call   801098 <fd2num>
  80184b:	89 c3                	mov    %eax,%ebx
  80184d:	83 c4 10             	add    $0x10,%esp
}
  801850:	89 d8                	mov    %ebx,%eax
  801852:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801855:	5b                   	pop    %ebx
  801856:	5e                   	pop    %esi
  801857:	5d                   	pop    %ebp
  801858:	c3                   	ret    
		fd_close(fd, 0);
  801859:	83 ec 08             	sub    $0x8,%esp
  80185c:	6a 00                	push   $0x0
  80185e:	ff 75 f4             	pushl  -0xc(%ebp)
  801861:	e8 54 f9 ff ff       	call   8011ba <fd_close>
		return r;
  801866:	83 c4 10             	add    $0x10,%esp
  801869:	eb e5                	jmp    801850 <open+0x6c>
		return -E_BAD_PATH;
  80186b:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801870:	eb de                	jmp    801850 <open+0x6c>

00801872 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801872:	55                   	push   %ebp
  801873:	89 e5                	mov    %esp,%ebp
  801875:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801878:	ba 00 00 00 00       	mov    $0x0,%edx
  80187d:	b8 08 00 00 00       	mov    $0x8,%eax
  801882:	e8 a3 fd ff ff       	call   80162a <fsipc>
}
  801887:	c9                   	leave  
  801888:	c3                   	ret    

00801889 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801889:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80188d:	7e 38                	jle    8018c7 <writebuf+0x3e>
{
  80188f:	55                   	push   %ebp
  801890:	89 e5                	mov    %esp,%ebp
  801892:	53                   	push   %ebx
  801893:	83 ec 08             	sub    $0x8,%esp
  801896:	89 c3                	mov    %eax,%ebx
		ssize_t result = write(b->fd, b->buf, b->idx);
  801898:	ff 70 04             	pushl  0x4(%eax)
  80189b:	8d 40 10             	lea    0x10(%eax),%eax
  80189e:	50                   	push   %eax
  80189f:	ff 33                	pushl  (%ebx)
  8018a1:	e8 a7 fb ff ff       	call   80144d <write>
		if (result > 0)
  8018a6:	83 c4 10             	add    $0x10,%esp
  8018a9:	85 c0                	test   %eax,%eax
  8018ab:	7e 03                	jle    8018b0 <writebuf+0x27>
			b->result += result;
  8018ad:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8018b0:	39 43 04             	cmp    %eax,0x4(%ebx)
  8018b3:	74 0d                	je     8018c2 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  8018b5:	85 c0                	test   %eax,%eax
  8018b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8018bc:	0f 4f c2             	cmovg  %edx,%eax
  8018bf:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8018c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018c5:	c9                   	leave  
  8018c6:	c3                   	ret    
  8018c7:	f3 c3                	repz ret 

008018c9 <putch>:

static void
putch(int ch, void *thunk)
{
  8018c9:	55                   	push   %ebp
  8018ca:	89 e5                	mov    %esp,%ebp
  8018cc:	53                   	push   %ebx
  8018cd:	83 ec 04             	sub    $0x4,%esp
  8018d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8018d3:	8b 53 04             	mov    0x4(%ebx),%edx
  8018d6:	8d 42 01             	lea    0x1(%edx),%eax
  8018d9:	89 43 04             	mov    %eax,0x4(%ebx)
  8018dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018df:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8018e3:	3d 00 01 00 00       	cmp    $0x100,%eax
  8018e8:	74 06                	je     8018f0 <putch+0x27>
		writebuf(b);
		b->idx = 0;
	}
}
  8018ea:	83 c4 04             	add    $0x4,%esp
  8018ed:	5b                   	pop    %ebx
  8018ee:	5d                   	pop    %ebp
  8018ef:	c3                   	ret    
		writebuf(b);
  8018f0:	89 d8                	mov    %ebx,%eax
  8018f2:	e8 92 ff ff ff       	call   801889 <writebuf>
		b->idx = 0;
  8018f7:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
}
  8018fe:	eb ea                	jmp    8018ea <putch+0x21>

00801900 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801900:	55                   	push   %ebp
  801901:	89 e5                	mov    %esp,%ebp
  801903:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801909:	8b 45 08             	mov    0x8(%ebp),%eax
  80190c:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801912:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801919:	00 00 00 
	b.result = 0;
  80191c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801923:	00 00 00 
	b.error = 1;
  801926:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  80192d:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801930:	ff 75 10             	pushl  0x10(%ebp)
  801933:	ff 75 0c             	pushl  0xc(%ebp)
  801936:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80193c:	50                   	push   %eax
  80193d:	68 c9 18 80 00       	push   $0x8018c9
  801942:	e8 55 eb ff ff       	call   80049c <vprintfmt>
	if (b.idx > 0)
  801947:	83 c4 10             	add    $0x10,%esp
  80194a:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801951:	7f 11                	jg     801964 <vfprintf+0x64>
		writebuf(&b);

	return (b.result ? b.result : b.error);
  801953:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801959:	85 c0                	test   %eax,%eax
  80195b:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801962:	c9                   	leave  
  801963:	c3                   	ret    
		writebuf(&b);
  801964:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80196a:	e8 1a ff ff ff       	call   801889 <writebuf>
  80196f:	eb e2                	jmp    801953 <vfprintf+0x53>

00801971 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801971:	55                   	push   %ebp
  801972:	89 e5                	mov    %esp,%ebp
  801974:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801977:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  80197a:	50                   	push   %eax
  80197b:	ff 75 0c             	pushl  0xc(%ebp)
  80197e:	ff 75 08             	pushl  0x8(%ebp)
  801981:	e8 7a ff ff ff       	call   801900 <vfprintf>
	va_end(ap);

	return cnt;
}
  801986:	c9                   	leave  
  801987:	c3                   	ret    

00801988 <printf>:

int
printf(const char *fmt, ...)
{
  801988:	55                   	push   %ebp
  801989:	89 e5                	mov    %esp,%ebp
  80198b:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80198e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801991:	50                   	push   %eax
  801992:	ff 75 08             	pushl  0x8(%ebp)
  801995:	6a 01                	push   $0x1
  801997:	e8 64 ff ff ff       	call   801900 <vfprintf>
	va_end(ap);

	return cnt;
}
  80199c:	c9                   	leave  
  80199d:	c3                   	ret    

0080199e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80199e:	55                   	push   %ebp
  80199f:	89 e5                	mov    %esp,%ebp
  8019a1:	56                   	push   %esi
  8019a2:	53                   	push   %ebx
  8019a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019a6:	83 ec 0c             	sub    $0xc,%esp
  8019a9:	ff 75 08             	pushl  0x8(%ebp)
  8019ac:	e8 f7 f6 ff ff       	call   8010a8 <fd2data>
  8019b1:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019b3:	83 c4 08             	add    $0x8,%esp
  8019b6:	68 1f 25 80 00       	push   $0x80251f
  8019bb:	53                   	push   %ebx
  8019bc:	e8 ed f0 ff ff       	call   800aae <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019c1:	8b 46 04             	mov    0x4(%esi),%eax
  8019c4:	2b 06                	sub    (%esi),%eax
  8019c6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019cc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019d3:	00 00 00 
	stat->st_dev = &devpipe;
  8019d6:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  8019dd:	30 80 00 
	return 0;
}
  8019e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8019e5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019e8:	5b                   	pop    %ebx
  8019e9:	5e                   	pop    %esi
  8019ea:	5d                   	pop    %ebp
  8019eb:	c3                   	ret    

008019ec <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019ec:	55                   	push   %ebp
  8019ed:	89 e5                	mov    %esp,%ebp
  8019ef:	53                   	push   %ebx
  8019f0:	83 ec 0c             	sub    $0xc,%esp
  8019f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019f6:	53                   	push   %ebx
  8019f7:	6a 00                	push   $0x0
  8019f9:	e8 2e f5 ff ff       	call   800f2c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019fe:	89 1c 24             	mov    %ebx,(%esp)
  801a01:	e8 a2 f6 ff ff       	call   8010a8 <fd2data>
  801a06:	83 c4 08             	add    $0x8,%esp
  801a09:	50                   	push   %eax
  801a0a:	6a 00                	push   $0x0
  801a0c:	e8 1b f5 ff ff       	call   800f2c <sys_page_unmap>
}
  801a11:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a14:	c9                   	leave  
  801a15:	c3                   	ret    

00801a16 <_pipeisclosed>:
{
  801a16:	55                   	push   %ebp
  801a17:	89 e5                	mov    %esp,%ebp
  801a19:	57                   	push   %edi
  801a1a:	56                   	push   %esi
  801a1b:	53                   	push   %ebx
  801a1c:	83 ec 1c             	sub    $0x1c,%esp
  801a1f:	89 c7                	mov    %eax,%edi
  801a21:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801a23:	a1 04 44 80 00       	mov    0x804404,%eax
  801a28:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a2b:	83 ec 0c             	sub    $0xc,%esp
  801a2e:	57                   	push   %edi
  801a2f:	e8 bb 03 00 00       	call   801def <pageref>
  801a34:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801a37:	89 34 24             	mov    %esi,(%esp)
  801a3a:	e8 b0 03 00 00       	call   801def <pageref>
		nn = thisenv->env_runs;
  801a3f:	8b 15 04 44 80 00    	mov    0x804404,%edx
  801a45:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a48:	83 c4 10             	add    $0x10,%esp
  801a4b:	39 cb                	cmp    %ecx,%ebx
  801a4d:	74 1b                	je     801a6a <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801a4f:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801a52:	75 cf                	jne    801a23 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a54:	8b 42 58             	mov    0x58(%edx),%eax
  801a57:	6a 01                	push   $0x1
  801a59:	50                   	push   %eax
  801a5a:	53                   	push   %ebx
  801a5b:	68 26 25 80 00       	push   $0x802526
  801a60:	e8 3a e9 ff ff       	call   80039f <cprintf>
  801a65:	83 c4 10             	add    $0x10,%esp
  801a68:	eb b9                	jmp    801a23 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801a6a:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801a6d:	0f 94 c0             	sete   %al
  801a70:	0f b6 c0             	movzbl %al,%eax
}
  801a73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a76:	5b                   	pop    %ebx
  801a77:	5e                   	pop    %esi
  801a78:	5f                   	pop    %edi
  801a79:	5d                   	pop    %ebp
  801a7a:	c3                   	ret    

00801a7b <devpipe_write>:
{
  801a7b:	55                   	push   %ebp
  801a7c:	89 e5                	mov    %esp,%ebp
  801a7e:	57                   	push   %edi
  801a7f:	56                   	push   %esi
  801a80:	53                   	push   %ebx
  801a81:	83 ec 28             	sub    $0x28,%esp
  801a84:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801a87:	56                   	push   %esi
  801a88:	e8 1b f6 ff ff       	call   8010a8 <fd2data>
  801a8d:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801a8f:	83 c4 10             	add    $0x10,%esp
  801a92:	bf 00 00 00 00       	mov    $0x0,%edi
  801a97:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a9a:	74 4f                	je     801aeb <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a9c:	8b 43 04             	mov    0x4(%ebx),%eax
  801a9f:	8b 0b                	mov    (%ebx),%ecx
  801aa1:	8d 51 20             	lea    0x20(%ecx),%edx
  801aa4:	39 d0                	cmp    %edx,%eax
  801aa6:	72 14                	jb     801abc <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801aa8:	89 da                	mov    %ebx,%edx
  801aaa:	89 f0                	mov    %esi,%eax
  801aac:	e8 65 ff ff ff       	call   801a16 <_pipeisclosed>
  801ab1:	85 c0                	test   %eax,%eax
  801ab3:	75 3a                	jne    801aef <devpipe_write+0x74>
			sys_yield();
  801ab5:	e8 ce f3 ff ff       	call   800e88 <sys_yield>
  801aba:	eb e0                	jmp    801a9c <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801abc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801abf:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ac3:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ac6:	89 c2                	mov    %eax,%edx
  801ac8:	c1 fa 1f             	sar    $0x1f,%edx
  801acb:	89 d1                	mov    %edx,%ecx
  801acd:	c1 e9 1b             	shr    $0x1b,%ecx
  801ad0:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ad3:	83 e2 1f             	and    $0x1f,%edx
  801ad6:	29 ca                	sub    %ecx,%edx
  801ad8:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801adc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ae0:	83 c0 01             	add    $0x1,%eax
  801ae3:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801ae6:	83 c7 01             	add    $0x1,%edi
  801ae9:	eb ac                	jmp    801a97 <devpipe_write+0x1c>
	return i;
  801aeb:	89 f8                	mov    %edi,%eax
  801aed:	eb 05                	jmp    801af4 <devpipe_write+0x79>
				return 0;
  801aef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801af4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801af7:	5b                   	pop    %ebx
  801af8:	5e                   	pop    %esi
  801af9:	5f                   	pop    %edi
  801afa:	5d                   	pop    %ebp
  801afb:	c3                   	ret    

00801afc <devpipe_read>:
{
  801afc:	55                   	push   %ebp
  801afd:	89 e5                	mov    %esp,%ebp
  801aff:	57                   	push   %edi
  801b00:	56                   	push   %esi
  801b01:	53                   	push   %ebx
  801b02:	83 ec 18             	sub    $0x18,%esp
  801b05:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801b08:	57                   	push   %edi
  801b09:	e8 9a f5 ff ff       	call   8010a8 <fd2data>
  801b0e:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b10:	83 c4 10             	add    $0x10,%esp
  801b13:	be 00 00 00 00       	mov    $0x0,%esi
  801b18:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b1b:	74 47                	je     801b64 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  801b1d:	8b 03                	mov    (%ebx),%eax
  801b1f:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b22:	75 22                	jne    801b46 <devpipe_read+0x4a>
			if (i > 0)
  801b24:	85 f6                	test   %esi,%esi
  801b26:	75 14                	jne    801b3c <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801b28:	89 da                	mov    %ebx,%edx
  801b2a:	89 f8                	mov    %edi,%eax
  801b2c:	e8 e5 fe ff ff       	call   801a16 <_pipeisclosed>
  801b31:	85 c0                	test   %eax,%eax
  801b33:	75 33                	jne    801b68 <devpipe_read+0x6c>
			sys_yield();
  801b35:	e8 4e f3 ff ff       	call   800e88 <sys_yield>
  801b3a:	eb e1                	jmp    801b1d <devpipe_read+0x21>
				return i;
  801b3c:	89 f0                	mov    %esi,%eax
}
  801b3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b41:	5b                   	pop    %ebx
  801b42:	5e                   	pop    %esi
  801b43:	5f                   	pop    %edi
  801b44:	5d                   	pop    %ebp
  801b45:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b46:	99                   	cltd   
  801b47:	c1 ea 1b             	shr    $0x1b,%edx
  801b4a:	01 d0                	add    %edx,%eax
  801b4c:	83 e0 1f             	and    $0x1f,%eax
  801b4f:	29 d0                	sub    %edx,%eax
  801b51:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801b56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b59:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801b5c:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801b5f:	83 c6 01             	add    $0x1,%esi
  801b62:	eb b4                	jmp    801b18 <devpipe_read+0x1c>
	return i;
  801b64:	89 f0                	mov    %esi,%eax
  801b66:	eb d6                	jmp    801b3e <devpipe_read+0x42>
				return 0;
  801b68:	b8 00 00 00 00       	mov    $0x0,%eax
  801b6d:	eb cf                	jmp    801b3e <devpipe_read+0x42>

00801b6f <pipe>:
{
  801b6f:	55                   	push   %ebp
  801b70:	89 e5                	mov    %esp,%ebp
  801b72:	56                   	push   %esi
  801b73:	53                   	push   %ebx
  801b74:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801b77:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b7a:	50                   	push   %eax
  801b7b:	e8 3f f5 ff ff       	call   8010bf <fd_alloc>
  801b80:	89 c3                	mov    %eax,%ebx
  801b82:	83 c4 10             	add    $0x10,%esp
  801b85:	85 c0                	test   %eax,%eax
  801b87:	78 5b                	js     801be4 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b89:	83 ec 04             	sub    $0x4,%esp
  801b8c:	68 07 04 00 00       	push   $0x407
  801b91:	ff 75 f4             	pushl  -0xc(%ebp)
  801b94:	6a 00                	push   $0x0
  801b96:	e8 0c f3 ff ff       	call   800ea7 <sys_page_alloc>
  801b9b:	89 c3                	mov    %eax,%ebx
  801b9d:	83 c4 10             	add    $0x10,%esp
  801ba0:	85 c0                	test   %eax,%eax
  801ba2:	78 40                	js     801be4 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  801ba4:	83 ec 0c             	sub    $0xc,%esp
  801ba7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801baa:	50                   	push   %eax
  801bab:	e8 0f f5 ff ff       	call   8010bf <fd_alloc>
  801bb0:	89 c3                	mov    %eax,%ebx
  801bb2:	83 c4 10             	add    $0x10,%esp
  801bb5:	85 c0                	test   %eax,%eax
  801bb7:	78 1b                	js     801bd4 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bb9:	83 ec 04             	sub    $0x4,%esp
  801bbc:	68 07 04 00 00       	push   $0x407
  801bc1:	ff 75 f0             	pushl  -0x10(%ebp)
  801bc4:	6a 00                	push   $0x0
  801bc6:	e8 dc f2 ff ff       	call   800ea7 <sys_page_alloc>
  801bcb:	89 c3                	mov    %eax,%ebx
  801bcd:	83 c4 10             	add    $0x10,%esp
  801bd0:	85 c0                	test   %eax,%eax
  801bd2:	79 19                	jns    801bed <pipe+0x7e>
	sys_page_unmap(0, fd0);
  801bd4:	83 ec 08             	sub    $0x8,%esp
  801bd7:	ff 75 f4             	pushl  -0xc(%ebp)
  801bda:	6a 00                	push   $0x0
  801bdc:	e8 4b f3 ff ff       	call   800f2c <sys_page_unmap>
  801be1:	83 c4 10             	add    $0x10,%esp
}
  801be4:	89 d8                	mov    %ebx,%eax
  801be6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801be9:	5b                   	pop    %ebx
  801bea:	5e                   	pop    %esi
  801beb:	5d                   	pop    %ebp
  801bec:	c3                   	ret    
	va = fd2data(fd0);
  801bed:	83 ec 0c             	sub    $0xc,%esp
  801bf0:	ff 75 f4             	pushl  -0xc(%ebp)
  801bf3:	e8 b0 f4 ff ff       	call   8010a8 <fd2data>
  801bf8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bfa:	83 c4 0c             	add    $0xc,%esp
  801bfd:	68 07 04 00 00       	push   $0x407
  801c02:	50                   	push   %eax
  801c03:	6a 00                	push   $0x0
  801c05:	e8 9d f2 ff ff       	call   800ea7 <sys_page_alloc>
  801c0a:	89 c3                	mov    %eax,%ebx
  801c0c:	83 c4 10             	add    $0x10,%esp
  801c0f:	85 c0                	test   %eax,%eax
  801c11:	0f 88 8c 00 00 00    	js     801ca3 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c17:	83 ec 0c             	sub    $0xc,%esp
  801c1a:	ff 75 f0             	pushl  -0x10(%ebp)
  801c1d:	e8 86 f4 ff ff       	call   8010a8 <fd2data>
  801c22:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c29:	50                   	push   %eax
  801c2a:	6a 00                	push   $0x0
  801c2c:	56                   	push   %esi
  801c2d:	6a 00                	push   $0x0
  801c2f:	e8 b6 f2 ff ff       	call   800eea <sys_page_map>
  801c34:	89 c3                	mov    %eax,%ebx
  801c36:	83 c4 20             	add    $0x20,%esp
  801c39:	85 c0                	test   %eax,%eax
  801c3b:	78 58                	js     801c95 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801c3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c40:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c46:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c4b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801c52:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c55:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c5b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c60:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801c67:	83 ec 0c             	sub    $0xc,%esp
  801c6a:	ff 75 f4             	pushl  -0xc(%ebp)
  801c6d:	e8 26 f4 ff ff       	call   801098 <fd2num>
  801c72:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c75:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c77:	83 c4 04             	add    $0x4,%esp
  801c7a:	ff 75 f0             	pushl  -0x10(%ebp)
  801c7d:	e8 16 f4 ff ff       	call   801098 <fd2num>
  801c82:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c85:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c88:	83 c4 10             	add    $0x10,%esp
  801c8b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c90:	e9 4f ff ff ff       	jmp    801be4 <pipe+0x75>
	sys_page_unmap(0, va);
  801c95:	83 ec 08             	sub    $0x8,%esp
  801c98:	56                   	push   %esi
  801c99:	6a 00                	push   $0x0
  801c9b:	e8 8c f2 ff ff       	call   800f2c <sys_page_unmap>
  801ca0:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801ca3:	83 ec 08             	sub    $0x8,%esp
  801ca6:	ff 75 f0             	pushl  -0x10(%ebp)
  801ca9:	6a 00                	push   $0x0
  801cab:	e8 7c f2 ff ff       	call   800f2c <sys_page_unmap>
  801cb0:	83 c4 10             	add    $0x10,%esp
  801cb3:	e9 1c ff ff ff       	jmp    801bd4 <pipe+0x65>

00801cb8 <pipeisclosed>:
{
  801cb8:	55                   	push   %ebp
  801cb9:	89 e5                	mov    %esp,%ebp
  801cbb:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cbe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cc1:	50                   	push   %eax
  801cc2:	ff 75 08             	pushl  0x8(%ebp)
  801cc5:	e8 44 f4 ff ff       	call   80110e <fd_lookup>
  801cca:	83 c4 10             	add    $0x10,%esp
  801ccd:	85 c0                	test   %eax,%eax
  801ccf:	78 18                	js     801ce9 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801cd1:	83 ec 0c             	sub    $0xc,%esp
  801cd4:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd7:	e8 cc f3 ff ff       	call   8010a8 <fd2data>
	return _pipeisclosed(fd, p);
  801cdc:	89 c2                	mov    %eax,%edx
  801cde:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ce1:	e8 30 fd ff ff       	call   801a16 <_pipeisclosed>
  801ce6:	83 c4 10             	add    $0x10,%esp
}
  801ce9:	c9                   	leave  
  801cea:	c3                   	ret    

00801ceb <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ceb:	55                   	push   %ebp
  801cec:	89 e5                	mov    %esp,%ebp
  801cee:	56                   	push   %esi
  801cef:	53                   	push   %ebx
  801cf0:	8b 75 08             	mov    0x8(%ebp),%esi
  801cf3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cf6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        //	panic("ipc_recv not implemented");
        int r;
       	if(pg!=NULL){
  801cf9:	85 c0                	test   %eax,%eax
  801cfb:	74 3b                	je     801d38 <ipc_recv+0x4d>
	  r = sys_ipc_recv(pg);
  801cfd:	83 ec 0c             	sub    $0xc,%esp
  801d00:	50                   	push   %eax
  801d01:	e8 51 f3 ff ff       	call   801057 <sys_ipc_recv>
  801d06:	83 c4 10             	add    $0x10,%esp
	}else
	  r = sys_ipc_recv((void *)UTOP);
	if(r<0){
  801d09:	85 c0                	test   %eax,%eax
  801d0b:	78 3d                	js     801d4a <ipc_recv+0x5f>
	if(perm_store!=NULL){
		*perm_store = 0;
            }
        	return r;
           }else{
	     if(from_env_store!=NULL)
  801d0d:	85 f6                	test   %esi,%esi
  801d0f:	74 0a                	je     801d1b <ipc_recv+0x30>
		     *from_env_store = thisenv->env_ipc_from;
  801d11:	a1 04 44 80 00       	mov    0x804404,%eax
  801d16:	8b 40 74             	mov    0x74(%eax),%eax
  801d19:	89 06                	mov    %eax,(%esi)
	     if(perm_store != NULL)
  801d1b:	85 db                	test   %ebx,%ebx
  801d1d:	74 0a                	je     801d29 <ipc_recv+0x3e>
		     *perm_store = thisenv->env_ipc_perm;
  801d1f:	a1 04 44 80 00       	mov    0x804404,%eax
  801d24:	8b 40 78             	mov    0x78(%eax),%eax
  801d27:	89 03                	mov    %eax,(%ebx)
	     return thisenv->env_ipc_value;
  801d29:	a1 04 44 80 00       	mov    0x804404,%eax
  801d2e:	8b 40 70             	mov    0x70(%eax),%eax
	   }

}
  801d31:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d34:	5b                   	pop    %ebx
  801d35:	5e                   	pop    %esi
  801d36:	5d                   	pop    %ebp
  801d37:	c3                   	ret    
	  r = sys_ipc_recv((void *)UTOP);
  801d38:	83 ec 0c             	sub    $0xc,%esp
  801d3b:	68 00 00 c0 ee       	push   $0xeec00000
  801d40:	e8 12 f3 ff ff       	call   801057 <sys_ipc_recv>
  801d45:	83 c4 10             	add    $0x10,%esp
  801d48:	eb bf                	jmp    801d09 <ipc_recv+0x1e>
	if(from_env_store!=NULL){
  801d4a:	85 f6                	test   %esi,%esi
  801d4c:	74 06                	je     801d54 <ipc_recv+0x69>
	  *from_env_store = 0;
  801d4e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if(perm_store!=NULL){
  801d54:	85 db                	test   %ebx,%ebx
  801d56:	74 d9                	je     801d31 <ipc_recv+0x46>
		*perm_store = 0;
  801d58:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801d5e:	eb d1                	jmp    801d31 <ipc_recv+0x46>

00801d60 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801d60:	55                   	push   %ebp
  801d61:	89 e5                	mov    %esp,%ebp
  801d63:	57                   	push   %edi
  801d64:	56                   	push   %esi
  801d65:	53                   	push   %ebx
  801d66:	83 ec 0c             	sub    $0xc,%esp
  801d69:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d6c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d6f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if(pg==NULL) pg = (void *)UTOP;
  801d72:	85 db                	test   %ebx,%ebx
  801d74:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801d79:	0f 44 d8             	cmove  %eax,%ebx
	while((r=sys_ipc_try_send(to_env,val,pg,perm))<0){
  801d7c:	ff 75 14             	pushl  0x14(%ebp)
  801d7f:	53                   	push   %ebx
  801d80:	56                   	push   %esi
  801d81:	57                   	push   %edi
  801d82:	e8 ad f2 ff ff       	call   801034 <sys_ipc_try_send>
  801d87:	83 c4 10             	add    $0x10,%esp
  801d8a:	85 c0                	test   %eax,%eax
  801d8c:	79 20                	jns    801dae <ipc_send+0x4e>
	    if(r!=-E_IPC_NOT_RECV){
  801d8e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801d91:	75 07                	jne    801d9a <ipc_send+0x3a>
		    panic("ipc_send:send message failed\n");
	    }
	    sys_yield();
  801d93:	e8 f0 f0 ff ff       	call   800e88 <sys_yield>
  801d98:	eb e2                	jmp    801d7c <ipc_send+0x1c>
		    panic("ipc_send:send message failed\n");
  801d9a:	83 ec 04             	sub    $0x4,%esp
  801d9d:	68 3e 25 80 00       	push   $0x80253e
  801da2:	6a 43                	push   $0x43
  801da4:	68 5c 25 80 00       	push   $0x80255c
  801da9:	e8 16 e5 ff ff       	call   8002c4 <_panic>
	}

}
  801dae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801db1:	5b                   	pop    %ebx
  801db2:	5e                   	pop    %esi
  801db3:	5f                   	pop    %edi
  801db4:	5d                   	pop    %ebp
  801db5:	c3                   	ret    

00801db6 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801db6:	55                   	push   %ebp
  801db7:	89 e5                	mov    %esp,%ebp
  801db9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801dbc:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801dc1:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801dc4:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801dca:	8b 52 50             	mov    0x50(%edx),%edx
  801dcd:	39 ca                	cmp    %ecx,%edx
  801dcf:	74 11                	je     801de2 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801dd1:	83 c0 01             	add    $0x1,%eax
  801dd4:	3d 00 04 00 00       	cmp    $0x400,%eax
  801dd9:	75 e6                	jne    801dc1 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801ddb:	b8 00 00 00 00       	mov    $0x0,%eax
  801de0:	eb 0b                	jmp    801ded <ipc_find_env+0x37>
			return envs[i].env_id;
  801de2:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801de5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801dea:	8b 40 48             	mov    0x48(%eax),%eax
}
  801ded:	5d                   	pop    %ebp
  801dee:	c3                   	ret    

00801def <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801def:	55                   	push   %ebp
  801df0:	89 e5                	mov    %esp,%ebp
  801df2:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801df5:	89 d0                	mov    %edx,%eax
  801df7:	c1 e8 16             	shr    $0x16,%eax
  801dfa:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801e01:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801e06:	f6 c1 01             	test   $0x1,%cl
  801e09:	74 1d                	je     801e28 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801e0b:	c1 ea 0c             	shr    $0xc,%edx
  801e0e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801e15:	f6 c2 01             	test   $0x1,%dl
  801e18:	74 0e                	je     801e28 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801e1a:	c1 ea 0c             	shr    $0xc,%edx
  801e1d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801e24:	ef 
  801e25:	0f b7 c0             	movzwl %ax,%eax
}
  801e28:	5d                   	pop    %ebp
  801e29:	c3                   	ret    
  801e2a:	66 90                	xchg   %ax,%ax
  801e2c:	66 90                	xchg   %ax,%ax
  801e2e:	66 90                	xchg   %ax,%ax

00801e30 <__udivdi3>:
  801e30:	55                   	push   %ebp
  801e31:	57                   	push   %edi
  801e32:	56                   	push   %esi
  801e33:	53                   	push   %ebx
  801e34:	83 ec 1c             	sub    $0x1c,%esp
  801e37:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801e3b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801e3f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801e43:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801e47:	85 d2                	test   %edx,%edx
  801e49:	75 35                	jne    801e80 <__udivdi3+0x50>
  801e4b:	39 f3                	cmp    %esi,%ebx
  801e4d:	0f 87 bd 00 00 00    	ja     801f10 <__udivdi3+0xe0>
  801e53:	85 db                	test   %ebx,%ebx
  801e55:	89 d9                	mov    %ebx,%ecx
  801e57:	75 0b                	jne    801e64 <__udivdi3+0x34>
  801e59:	b8 01 00 00 00       	mov    $0x1,%eax
  801e5e:	31 d2                	xor    %edx,%edx
  801e60:	f7 f3                	div    %ebx
  801e62:	89 c1                	mov    %eax,%ecx
  801e64:	31 d2                	xor    %edx,%edx
  801e66:	89 f0                	mov    %esi,%eax
  801e68:	f7 f1                	div    %ecx
  801e6a:	89 c6                	mov    %eax,%esi
  801e6c:	89 e8                	mov    %ebp,%eax
  801e6e:	89 f7                	mov    %esi,%edi
  801e70:	f7 f1                	div    %ecx
  801e72:	89 fa                	mov    %edi,%edx
  801e74:	83 c4 1c             	add    $0x1c,%esp
  801e77:	5b                   	pop    %ebx
  801e78:	5e                   	pop    %esi
  801e79:	5f                   	pop    %edi
  801e7a:	5d                   	pop    %ebp
  801e7b:	c3                   	ret    
  801e7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e80:	39 f2                	cmp    %esi,%edx
  801e82:	77 7c                	ja     801f00 <__udivdi3+0xd0>
  801e84:	0f bd fa             	bsr    %edx,%edi
  801e87:	83 f7 1f             	xor    $0x1f,%edi
  801e8a:	0f 84 98 00 00 00    	je     801f28 <__udivdi3+0xf8>
  801e90:	89 f9                	mov    %edi,%ecx
  801e92:	b8 20 00 00 00       	mov    $0x20,%eax
  801e97:	29 f8                	sub    %edi,%eax
  801e99:	d3 e2                	shl    %cl,%edx
  801e9b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e9f:	89 c1                	mov    %eax,%ecx
  801ea1:	89 da                	mov    %ebx,%edx
  801ea3:	d3 ea                	shr    %cl,%edx
  801ea5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801ea9:	09 d1                	or     %edx,%ecx
  801eab:	89 f2                	mov    %esi,%edx
  801ead:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801eb1:	89 f9                	mov    %edi,%ecx
  801eb3:	d3 e3                	shl    %cl,%ebx
  801eb5:	89 c1                	mov    %eax,%ecx
  801eb7:	d3 ea                	shr    %cl,%edx
  801eb9:	89 f9                	mov    %edi,%ecx
  801ebb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801ebf:	d3 e6                	shl    %cl,%esi
  801ec1:	89 eb                	mov    %ebp,%ebx
  801ec3:	89 c1                	mov    %eax,%ecx
  801ec5:	d3 eb                	shr    %cl,%ebx
  801ec7:	09 de                	or     %ebx,%esi
  801ec9:	89 f0                	mov    %esi,%eax
  801ecb:	f7 74 24 08          	divl   0x8(%esp)
  801ecf:	89 d6                	mov    %edx,%esi
  801ed1:	89 c3                	mov    %eax,%ebx
  801ed3:	f7 64 24 0c          	mull   0xc(%esp)
  801ed7:	39 d6                	cmp    %edx,%esi
  801ed9:	72 0c                	jb     801ee7 <__udivdi3+0xb7>
  801edb:	89 f9                	mov    %edi,%ecx
  801edd:	d3 e5                	shl    %cl,%ebp
  801edf:	39 c5                	cmp    %eax,%ebp
  801ee1:	73 5d                	jae    801f40 <__udivdi3+0x110>
  801ee3:	39 d6                	cmp    %edx,%esi
  801ee5:	75 59                	jne    801f40 <__udivdi3+0x110>
  801ee7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801eea:	31 ff                	xor    %edi,%edi
  801eec:	89 fa                	mov    %edi,%edx
  801eee:	83 c4 1c             	add    $0x1c,%esp
  801ef1:	5b                   	pop    %ebx
  801ef2:	5e                   	pop    %esi
  801ef3:	5f                   	pop    %edi
  801ef4:	5d                   	pop    %ebp
  801ef5:	c3                   	ret    
  801ef6:	8d 76 00             	lea    0x0(%esi),%esi
  801ef9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801f00:	31 ff                	xor    %edi,%edi
  801f02:	31 c0                	xor    %eax,%eax
  801f04:	89 fa                	mov    %edi,%edx
  801f06:	83 c4 1c             	add    $0x1c,%esp
  801f09:	5b                   	pop    %ebx
  801f0a:	5e                   	pop    %esi
  801f0b:	5f                   	pop    %edi
  801f0c:	5d                   	pop    %ebp
  801f0d:	c3                   	ret    
  801f0e:	66 90                	xchg   %ax,%ax
  801f10:	31 ff                	xor    %edi,%edi
  801f12:	89 e8                	mov    %ebp,%eax
  801f14:	89 f2                	mov    %esi,%edx
  801f16:	f7 f3                	div    %ebx
  801f18:	89 fa                	mov    %edi,%edx
  801f1a:	83 c4 1c             	add    $0x1c,%esp
  801f1d:	5b                   	pop    %ebx
  801f1e:	5e                   	pop    %esi
  801f1f:	5f                   	pop    %edi
  801f20:	5d                   	pop    %ebp
  801f21:	c3                   	ret    
  801f22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f28:	39 f2                	cmp    %esi,%edx
  801f2a:	72 06                	jb     801f32 <__udivdi3+0x102>
  801f2c:	31 c0                	xor    %eax,%eax
  801f2e:	39 eb                	cmp    %ebp,%ebx
  801f30:	77 d2                	ja     801f04 <__udivdi3+0xd4>
  801f32:	b8 01 00 00 00       	mov    $0x1,%eax
  801f37:	eb cb                	jmp    801f04 <__udivdi3+0xd4>
  801f39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f40:	89 d8                	mov    %ebx,%eax
  801f42:	31 ff                	xor    %edi,%edi
  801f44:	eb be                	jmp    801f04 <__udivdi3+0xd4>
  801f46:	66 90                	xchg   %ax,%ax
  801f48:	66 90                	xchg   %ax,%ax
  801f4a:	66 90                	xchg   %ax,%ax
  801f4c:	66 90                	xchg   %ax,%ax
  801f4e:	66 90                	xchg   %ax,%ax

00801f50 <__umoddi3>:
  801f50:	55                   	push   %ebp
  801f51:	57                   	push   %edi
  801f52:	56                   	push   %esi
  801f53:	53                   	push   %ebx
  801f54:	83 ec 1c             	sub    $0x1c,%esp
  801f57:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801f5b:	8b 74 24 30          	mov    0x30(%esp),%esi
  801f5f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801f63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f67:	85 ed                	test   %ebp,%ebp
  801f69:	89 f0                	mov    %esi,%eax
  801f6b:	89 da                	mov    %ebx,%edx
  801f6d:	75 19                	jne    801f88 <__umoddi3+0x38>
  801f6f:	39 df                	cmp    %ebx,%edi
  801f71:	0f 86 b1 00 00 00    	jbe    802028 <__umoddi3+0xd8>
  801f77:	f7 f7                	div    %edi
  801f79:	89 d0                	mov    %edx,%eax
  801f7b:	31 d2                	xor    %edx,%edx
  801f7d:	83 c4 1c             	add    $0x1c,%esp
  801f80:	5b                   	pop    %ebx
  801f81:	5e                   	pop    %esi
  801f82:	5f                   	pop    %edi
  801f83:	5d                   	pop    %ebp
  801f84:	c3                   	ret    
  801f85:	8d 76 00             	lea    0x0(%esi),%esi
  801f88:	39 dd                	cmp    %ebx,%ebp
  801f8a:	77 f1                	ja     801f7d <__umoddi3+0x2d>
  801f8c:	0f bd cd             	bsr    %ebp,%ecx
  801f8f:	83 f1 1f             	xor    $0x1f,%ecx
  801f92:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801f96:	0f 84 b4 00 00 00    	je     802050 <__umoddi3+0x100>
  801f9c:	b8 20 00 00 00       	mov    $0x20,%eax
  801fa1:	89 c2                	mov    %eax,%edx
  801fa3:	8b 44 24 04          	mov    0x4(%esp),%eax
  801fa7:	29 c2                	sub    %eax,%edx
  801fa9:	89 c1                	mov    %eax,%ecx
  801fab:	89 f8                	mov    %edi,%eax
  801fad:	d3 e5                	shl    %cl,%ebp
  801faf:	89 d1                	mov    %edx,%ecx
  801fb1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801fb5:	d3 e8                	shr    %cl,%eax
  801fb7:	09 c5                	or     %eax,%ebp
  801fb9:	8b 44 24 04          	mov    0x4(%esp),%eax
  801fbd:	89 c1                	mov    %eax,%ecx
  801fbf:	d3 e7                	shl    %cl,%edi
  801fc1:	89 d1                	mov    %edx,%ecx
  801fc3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801fc7:	89 df                	mov    %ebx,%edi
  801fc9:	d3 ef                	shr    %cl,%edi
  801fcb:	89 c1                	mov    %eax,%ecx
  801fcd:	89 f0                	mov    %esi,%eax
  801fcf:	d3 e3                	shl    %cl,%ebx
  801fd1:	89 d1                	mov    %edx,%ecx
  801fd3:	89 fa                	mov    %edi,%edx
  801fd5:	d3 e8                	shr    %cl,%eax
  801fd7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801fdc:	09 d8                	or     %ebx,%eax
  801fde:	f7 f5                	div    %ebp
  801fe0:	d3 e6                	shl    %cl,%esi
  801fe2:	89 d1                	mov    %edx,%ecx
  801fe4:	f7 64 24 08          	mull   0x8(%esp)
  801fe8:	39 d1                	cmp    %edx,%ecx
  801fea:	89 c3                	mov    %eax,%ebx
  801fec:	89 d7                	mov    %edx,%edi
  801fee:	72 06                	jb     801ff6 <__umoddi3+0xa6>
  801ff0:	75 0e                	jne    802000 <__umoddi3+0xb0>
  801ff2:	39 c6                	cmp    %eax,%esi
  801ff4:	73 0a                	jae    802000 <__umoddi3+0xb0>
  801ff6:	2b 44 24 08          	sub    0x8(%esp),%eax
  801ffa:	19 ea                	sbb    %ebp,%edx
  801ffc:	89 d7                	mov    %edx,%edi
  801ffe:	89 c3                	mov    %eax,%ebx
  802000:	89 ca                	mov    %ecx,%edx
  802002:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  802007:	29 de                	sub    %ebx,%esi
  802009:	19 fa                	sbb    %edi,%edx
  80200b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80200f:	89 d0                	mov    %edx,%eax
  802011:	d3 e0                	shl    %cl,%eax
  802013:	89 d9                	mov    %ebx,%ecx
  802015:	d3 ee                	shr    %cl,%esi
  802017:	d3 ea                	shr    %cl,%edx
  802019:	09 f0                	or     %esi,%eax
  80201b:	83 c4 1c             	add    $0x1c,%esp
  80201e:	5b                   	pop    %ebx
  80201f:	5e                   	pop    %esi
  802020:	5f                   	pop    %edi
  802021:	5d                   	pop    %ebp
  802022:	c3                   	ret    
  802023:	90                   	nop
  802024:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802028:	85 ff                	test   %edi,%edi
  80202a:	89 f9                	mov    %edi,%ecx
  80202c:	75 0b                	jne    802039 <__umoddi3+0xe9>
  80202e:	b8 01 00 00 00       	mov    $0x1,%eax
  802033:	31 d2                	xor    %edx,%edx
  802035:	f7 f7                	div    %edi
  802037:	89 c1                	mov    %eax,%ecx
  802039:	89 d8                	mov    %ebx,%eax
  80203b:	31 d2                	xor    %edx,%edx
  80203d:	f7 f1                	div    %ecx
  80203f:	89 f0                	mov    %esi,%eax
  802041:	f7 f1                	div    %ecx
  802043:	e9 31 ff ff ff       	jmp    801f79 <__umoddi3+0x29>
  802048:	90                   	nop
  802049:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802050:	39 dd                	cmp    %ebx,%ebp
  802052:	72 08                	jb     80205c <__umoddi3+0x10c>
  802054:	39 f7                	cmp    %esi,%edi
  802056:	0f 87 21 ff ff ff    	ja     801f7d <__umoddi3+0x2d>
  80205c:	89 da                	mov    %ebx,%edx
  80205e:	89 f0                	mov    %esi,%eax
  802060:	29 f8                	sub    %edi,%eax
  802062:	19 ea                	sbb    %ebp,%edx
  802064:	e9 14 ff ff ff       	jmp    801f7d <__umoddi3+0x2d>
