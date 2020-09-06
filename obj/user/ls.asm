
obj/user/ls.debug:     file format elf32-i386


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
  80002c:	e8 97 02 00 00       	call   8002c8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <ls1>:
		panic("error reading directory %s: %e", path, n);
}

void
ls1(const char *prefix, bool isdir, off_t size, const char *name)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003b:	8b 75 0c             	mov    0xc(%ebp),%esi
	const char *sep;

	if(flag['l'])
  80003e:	83 3d d0 41 80 00 00 	cmpl   $0x0,0x8041d0
  800045:	74 20                	je     800067 <ls1+0x34>
		printf("%11d %c ", size, isdir ? 'd' : '-');
  800047:	89 f0                	mov    %esi,%eax
  800049:	3c 01                	cmp    $0x1,%al
  80004b:	19 c0                	sbb    %eax,%eax
  80004d:	83 e0 c9             	and    $0xffffffc9,%eax
  800050:	83 c0 64             	add    $0x64,%eax
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	50                   	push   %eax
  800057:	ff 75 10             	pushl  0x10(%ebp)
  80005a:	68 c2 22 80 00       	push   $0x8022c2
  80005f:	e8 ec 19 00 00       	call   801a50 <printf>
  800064:	83 c4 10             	add    $0x10,%esp
	if(prefix) {
  800067:	85 db                	test   %ebx,%ebx
  800069:	74 1c                	je     800087 <ls1+0x54>
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
			sep = "/";
		else
			sep = "";
  80006b:	b8 28 23 80 00       	mov    $0x802328,%eax
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
  800070:	80 3b 00             	cmpb   $0x0,(%ebx)
  800073:	75 4b                	jne    8000c0 <ls1+0x8d>
		printf("%s%s", prefix, sep);
  800075:	83 ec 04             	sub    $0x4,%esp
  800078:	50                   	push   %eax
  800079:	53                   	push   %ebx
  80007a:	68 cb 22 80 00       	push   $0x8022cb
  80007f:	e8 cc 19 00 00       	call   801a50 <printf>
  800084:	83 c4 10             	add    $0x10,%esp
	}
	printf("%s", name);
  800087:	83 ec 08             	sub    $0x8,%esp
  80008a:	ff 75 14             	pushl  0x14(%ebp)
  80008d:	68 55 27 80 00       	push   $0x802755
  800092:	e8 b9 19 00 00       	call   801a50 <printf>
	if(flag['F'] && isdir)
  800097:	83 c4 10             	add    $0x10,%esp
  80009a:	83 3d 38 41 80 00 00 	cmpl   $0x0,0x804138
  8000a1:	74 06                	je     8000a9 <ls1+0x76>
  8000a3:	89 f0                	mov    %esi,%eax
  8000a5:	84 c0                	test   %al,%al
  8000a7:	75 37                	jne    8000e0 <ls1+0xad>
		printf("/");
	printf("\n");
  8000a9:	83 ec 0c             	sub    $0xc,%esp
  8000ac:	68 27 23 80 00       	push   $0x802327
  8000b1:	e8 9a 19 00 00       	call   801a50 <printf>
}
  8000b6:	83 c4 10             	add    $0x10,%esp
  8000b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000bc:	5b                   	pop    %ebx
  8000bd:	5e                   	pop    %esi
  8000be:	5d                   	pop    %ebp
  8000bf:	c3                   	ret    
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
  8000c0:	83 ec 0c             	sub    $0xc,%esp
  8000c3:	53                   	push   %ebx
  8000c4:	e8 22 09 00 00       	call   8009eb <strlen>
  8000c9:	83 c4 10             	add    $0x10,%esp
			sep = "";
  8000cc:	80 7c 03 ff 2f       	cmpb   $0x2f,-0x1(%ebx,%eax,1)
  8000d1:	b8 c0 22 80 00       	mov    $0x8022c0,%eax
  8000d6:	ba 28 23 80 00       	mov    $0x802328,%edx
  8000db:	0f 44 c2             	cmove  %edx,%eax
  8000de:	eb 95                	jmp    800075 <ls1+0x42>
		printf("/");
  8000e0:	83 ec 0c             	sub    $0xc,%esp
  8000e3:	68 c0 22 80 00       	push   $0x8022c0
  8000e8:	e8 63 19 00 00       	call   801a50 <printf>
  8000ed:	83 c4 10             	add    $0x10,%esp
  8000f0:	eb b7                	jmp    8000a9 <ls1+0x76>

008000f2 <lsdir>:
{
  8000f2:	55                   	push   %ebp
  8000f3:	89 e5                	mov    %esp,%ebp
  8000f5:	57                   	push   %edi
  8000f6:	56                   	push   %esi
  8000f7:	53                   	push   %ebx
  8000f8:	81 ec 14 01 00 00    	sub    $0x114,%esp
  8000fe:	8b 7d 08             	mov    0x8(%ebp),%edi
	if ((fd = open(path, O_RDONLY)) < 0)
  800101:	6a 00                	push   $0x0
  800103:	57                   	push   %edi
  800104:	e8 a3 17 00 00       	call   8018ac <open>
  800109:	89 c3                	mov    %eax,%ebx
  80010b:	83 c4 10             	add    $0x10,%esp
  80010e:	85 c0                	test   %eax,%eax
  800110:	78 4a                	js     80015c <lsdir+0x6a>
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
  800112:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
  800118:	83 ec 04             	sub    $0x4,%esp
  80011b:	68 00 01 00 00       	push   $0x100
  800120:	56                   	push   %esi
  800121:	53                   	push   %ebx
  800122:	e8 a7 13 00 00       	call   8014ce <readn>
  800127:	83 c4 10             	add    $0x10,%esp
  80012a:	3d 00 01 00 00       	cmp    $0x100,%eax
  80012f:	75 41                	jne    800172 <lsdir+0x80>
		if (f.f_name[0])
  800131:	80 bd e8 fe ff ff 00 	cmpb   $0x0,-0x118(%ebp)
  800138:	74 de                	je     800118 <lsdir+0x26>
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
  80013a:	56                   	push   %esi
  80013b:	ff b5 68 ff ff ff    	pushl  -0x98(%ebp)
  800141:	83 bd 6c ff ff ff 01 	cmpl   $0x1,-0x94(%ebp)
  800148:	0f 94 c0             	sete   %al
  80014b:	0f b6 c0             	movzbl %al,%eax
  80014e:	50                   	push   %eax
  80014f:	ff 75 0c             	pushl  0xc(%ebp)
  800152:	e8 dc fe ff ff       	call   800033 <ls1>
  800157:	83 c4 10             	add    $0x10,%esp
  80015a:	eb bc                	jmp    800118 <lsdir+0x26>
		panic("open %s: %e", path, fd);
  80015c:	83 ec 0c             	sub    $0xc,%esp
  80015f:	50                   	push   %eax
  800160:	57                   	push   %edi
  800161:	68 d0 22 80 00       	push   $0x8022d0
  800166:	6a 1d                	push   $0x1d
  800168:	68 dc 22 80 00       	push   $0x8022dc
  80016d:	e8 b6 01 00 00       	call   800328 <_panic>
	if (n > 0)
  800172:	85 c0                	test   %eax,%eax
  800174:	7f 0c                	jg     800182 <lsdir+0x90>
	if (n < 0)
  800176:	85 c0                	test   %eax,%eax
  800178:	78 1a                	js     800194 <lsdir+0xa2>
}
  80017a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80017d:	5b                   	pop    %ebx
  80017e:	5e                   	pop    %esi
  80017f:	5f                   	pop    %edi
  800180:	5d                   	pop    %ebp
  800181:	c3                   	ret    
		panic("short read in directory %s", path);
  800182:	57                   	push   %edi
  800183:	68 e6 22 80 00       	push   $0x8022e6
  800188:	6a 22                	push   $0x22
  80018a:	68 dc 22 80 00       	push   $0x8022dc
  80018f:	e8 94 01 00 00       	call   800328 <_panic>
		panic("error reading directory %s: %e", path, n);
  800194:	83 ec 0c             	sub    $0xc,%esp
  800197:	50                   	push   %eax
  800198:	57                   	push   %edi
  800199:	68 2c 23 80 00       	push   $0x80232c
  80019e:	6a 24                	push   $0x24
  8001a0:	68 dc 22 80 00       	push   $0x8022dc
  8001a5:	e8 7e 01 00 00       	call   800328 <_panic>

008001aa <ls>:
{
  8001aa:	55                   	push   %ebp
  8001ab:	89 e5                	mov    %esp,%ebp
  8001ad:	53                   	push   %ebx
  8001ae:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  8001b4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = stat(path, &st)) < 0)
  8001b7:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
  8001bd:	50                   	push   %eax
  8001be:	53                   	push   %ebx
  8001bf:	e8 ef 14 00 00       	call   8016b3 <stat>
  8001c4:	83 c4 10             	add    $0x10,%esp
  8001c7:	85 c0                	test   %eax,%eax
  8001c9:	78 2c                	js     8001f7 <ls+0x4d>
	if (st.st_isdir && !flag['d'])
  8001cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8001ce:	85 c0                	test   %eax,%eax
  8001d0:	74 09                	je     8001db <ls+0x31>
  8001d2:	83 3d b0 41 80 00 00 	cmpl   $0x0,0x8041b0
  8001d9:	74 32                	je     80020d <ls+0x63>
		ls1(0, st.st_isdir, st.st_size, path);
  8001db:	53                   	push   %ebx
  8001dc:	ff 75 ec             	pushl  -0x14(%ebp)
  8001df:	85 c0                	test   %eax,%eax
  8001e1:	0f 95 c0             	setne  %al
  8001e4:	0f b6 c0             	movzbl %al,%eax
  8001e7:	50                   	push   %eax
  8001e8:	6a 00                	push   $0x0
  8001ea:	e8 44 fe ff ff       	call   800033 <ls1>
  8001ef:	83 c4 10             	add    $0x10,%esp
}
  8001f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001f5:	c9                   	leave  
  8001f6:	c3                   	ret    
		panic("stat %s: %e", path, r);
  8001f7:	83 ec 0c             	sub    $0xc,%esp
  8001fa:	50                   	push   %eax
  8001fb:	53                   	push   %ebx
  8001fc:	68 01 23 80 00       	push   $0x802301
  800201:	6a 0f                	push   $0xf
  800203:	68 dc 22 80 00       	push   $0x8022dc
  800208:	e8 1b 01 00 00       	call   800328 <_panic>
		lsdir(path, prefix);
  80020d:	83 ec 08             	sub    $0x8,%esp
  800210:	ff 75 0c             	pushl  0xc(%ebp)
  800213:	53                   	push   %ebx
  800214:	e8 d9 fe ff ff       	call   8000f2 <lsdir>
  800219:	83 c4 10             	add    $0x10,%esp
  80021c:	eb d4                	jmp    8001f2 <ls+0x48>

0080021e <usage>:

void
usage(void)
{
  80021e:	55                   	push   %ebp
  80021f:	89 e5                	mov    %esp,%ebp
  800221:	83 ec 14             	sub    $0x14,%esp
	printf("usage: ls [-dFl] [file...]\n");
  800224:	68 0d 23 80 00       	push   $0x80230d
  800229:	e8 22 18 00 00       	call   801a50 <printf>
	exit();
  80022e:	e8 db 00 00 00       	call   80030e <exit>
}
  800233:	83 c4 10             	add    $0x10,%esp
  800236:	c9                   	leave  
  800237:	c3                   	ret    

00800238 <umain>:

void
umain(int argc, char **argv)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	56                   	push   %esi
  80023c:	53                   	push   %ebx
  80023d:	83 ec 14             	sub    $0x14,%esp
  800240:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
  800243:	8d 45 e8             	lea    -0x18(%ebp),%eax
  800246:	50                   	push   %eax
  800247:	56                   	push   %esi
  800248:	8d 45 08             	lea    0x8(%ebp),%eax
  80024b:	50                   	push   %eax
  80024c:	e8 bb 0d 00 00       	call   80100c <argstart>
	while ((i = argnext(&args)) >= 0)
  800251:	83 c4 10             	add    $0x10,%esp
  800254:	8d 5d e8             	lea    -0x18(%ebp),%ebx
  800257:	eb 08                	jmp    800261 <umain+0x29>
		switch (i) {
		case 'd':
		case 'F':
		case 'l':
			flag[i]++;
  800259:	83 04 85 20 40 80 00 	addl   $0x1,0x804020(,%eax,4)
  800260:	01 
	while ((i = argnext(&args)) >= 0)
  800261:	83 ec 0c             	sub    $0xc,%esp
  800264:	53                   	push   %ebx
  800265:	e8 d2 0d 00 00       	call   80103c <argnext>
  80026a:	83 c4 10             	add    $0x10,%esp
  80026d:	85 c0                	test   %eax,%eax
  80026f:	78 16                	js     800287 <umain+0x4f>
		switch (i) {
  800271:	83 f8 64             	cmp    $0x64,%eax
  800274:	74 e3                	je     800259 <umain+0x21>
  800276:	83 f8 6c             	cmp    $0x6c,%eax
  800279:	74 de                	je     800259 <umain+0x21>
  80027b:	83 f8 46             	cmp    $0x46,%eax
  80027e:	74 d9                	je     800259 <umain+0x21>
			break;
		default:
			usage();
  800280:	e8 99 ff ff ff       	call   80021e <usage>
  800285:	eb da                	jmp    800261 <umain+0x29>
		}

	if (argc == 1)
		ls("/", "");
	else {
		for (i = 1; i < argc; i++)
  800287:	bb 01 00 00 00       	mov    $0x1,%ebx
	if (argc == 1)
  80028c:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  800290:	75 2a                	jne    8002bc <umain+0x84>
		ls("/", "");
  800292:	83 ec 08             	sub    $0x8,%esp
  800295:	68 28 23 80 00       	push   $0x802328
  80029a:	68 c0 22 80 00       	push   $0x8022c0
  80029f:	e8 06 ff ff ff       	call   8001aa <ls>
  8002a4:	83 c4 10             	add    $0x10,%esp
  8002a7:	eb 18                	jmp    8002c1 <umain+0x89>
			ls(argv[i], argv[i]);
  8002a9:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8002ac:	83 ec 08             	sub    $0x8,%esp
  8002af:	50                   	push   %eax
  8002b0:	50                   	push   %eax
  8002b1:	e8 f4 fe ff ff       	call   8001aa <ls>
		for (i = 1; i < argc; i++)
  8002b6:	83 c3 01             	add    $0x1,%ebx
  8002b9:	83 c4 10             	add    $0x10,%esp
  8002bc:	39 5d 08             	cmp    %ebx,0x8(%ebp)
  8002bf:	7f e8                	jg     8002a9 <umain+0x71>
	}
}
  8002c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002c4:	5b                   	pop    %ebx
  8002c5:	5e                   	pop    %esi
  8002c6:	5d                   	pop    %ebp
  8002c7:	c3                   	ret    

008002c8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002c8:	55                   	push   %ebp
  8002c9:	89 e5                	mov    %esp,%ebp
  8002cb:	56                   	push   %esi
  8002cc:	53                   	push   %ebx
  8002cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002d0:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8002d3:	e8 05 0b 00 00       	call   800ddd <sys_getenvid>
  8002d8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002dd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8002e0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002e5:	a3 20 44 80 00       	mov    %eax,0x804420
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002ea:	85 db                	test   %ebx,%ebx
  8002ec:	7e 07                	jle    8002f5 <libmain+0x2d>
		binaryname = argv[0];
  8002ee:	8b 06                	mov    (%esi),%eax
  8002f0:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8002f5:	83 ec 08             	sub    $0x8,%esp
  8002f8:	56                   	push   %esi
  8002f9:	53                   	push   %ebx
  8002fa:	e8 39 ff ff ff       	call   800238 <umain>

	// exit gracefully
	exit();
  8002ff:	e8 0a 00 00 00       	call   80030e <exit>
}
  800304:	83 c4 10             	add    $0x10,%esp
  800307:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80030a:	5b                   	pop    %ebx
  80030b:	5e                   	pop    %esi
  80030c:	5d                   	pop    %ebp
  80030d:	c3                   	ret    

0080030e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800314:	e8 1d 10 00 00       	call   801336 <close_all>
	sys_env_destroy(0);
  800319:	83 ec 0c             	sub    $0xc,%esp
  80031c:	6a 00                	push   $0x0
  80031e:	e8 79 0a 00 00       	call   800d9c <sys_env_destroy>
}
  800323:	83 c4 10             	add    $0x10,%esp
  800326:	c9                   	leave  
  800327:	c3                   	ret    

00800328 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	56                   	push   %esi
  80032c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80032d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800330:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800336:	e8 a2 0a 00 00       	call   800ddd <sys_getenvid>
  80033b:	83 ec 0c             	sub    $0xc,%esp
  80033e:	ff 75 0c             	pushl  0xc(%ebp)
  800341:	ff 75 08             	pushl  0x8(%ebp)
  800344:	56                   	push   %esi
  800345:	50                   	push   %eax
  800346:	68 58 23 80 00       	push   $0x802358
  80034b:	e8 b3 00 00 00       	call   800403 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800350:	83 c4 18             	add    $0x18,%esp
  800353:	53                   	push   %ebx
  800354:	ff 75 10             	pushl  0x10(%ebp)
  800357:	e8 56 00 00 00       	call   8003b2 <vcprintf>
	cprintf("\n");
  80035c:	c7 04 24 27 23 80 00 	movl   $0x802327,(%esp)
  800363:	e8 9b 00 00 00       	call   800403 <cprintf>
  800368:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80036b:	cc                   	int3   
  80036c:	eb fd                	jmp    80036b <_panic+0x43>

0080036e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80036e:	55                   	push   %ebp
  80036f:	89 e5                	mov    %esp,%ebp
  800371:	53                   	push   %ebx
  800372:	83 ec 04             	sub    $0x4,%esp
  800375:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800378:	8b 13                	mov    (%ebx),%edx
  80037a:	8d 42 01             	lea    0x1(%edx),%eax
  80037d:	89 03                	mov    %eax,(%ebx)
  80037f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800382:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800386:	3d ff 00 00 00       	cmp    $0xff,%eax
  80038b:	74 09                	je     800396 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80038d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800391:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800394:	c9                   	leave  
  800395:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800396:	83 ec 08             	sub    $0x8,%esp
  800399:	68 ff 00 00 00       	push   $0xff
  80039e:	8d 43 08             	lea    0x8(%ebx),%eax
  8003a1:	50                   	push   %eax
  8003a2:	e8 b8 09 00 00       	call   800d5f <sys_cputs>
		b->idx = 0;
  8003a7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003ad:	83 c4 10             	add    $0x10,%esp
  8003b0:	eb db                	jmp    80038d <putch+0x1f>

008003b2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003b2:	55                   	push   %ebp
  8003b3:	89 e5                	mov    %esp,%ebp
  8003b5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003bb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003c2:	00 00 00 
	b.cnt = 0;
  8003c5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003cc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003cf:	ff 75 0c             	pushl  0xc(%ebp)
  8003d2:	ff 75 08             	pushl  0x8(%ebp)
  8003d5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003db:	50                   	push   %eax
  8003dc:	68 6e 03 80 00       	push   $0x80036e
  8003e1:	e8 1a 01 00 00       	call   800500 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003e6:	83 c4 08             	add    $0x8,%esp
  8003e9:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003ef:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003f5:	50                   	push   %eax
  8003f6:	e8 64 09 00 00       	call   800d5f <sys_cputs>

	return b.cnt;
}
  8003fb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800401:	c9                   	leave  
  800402:	c3                   	ret    

00800403 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800403:	55                   	push   %ebp
  800404:	89 e5                	mov    %esp,%ebp
  800406:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800409:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80040c:	50                   	push   %eax
  80040d:	ff 75 08             	pushl  0x8(%ebp)
  800410:	e8 9d ff ff ff       	call   8003b2 <vcprintf>
	va_end(ap);

	return cnt;
}
  800415:	c9                   	leave  
  800416:	c3                   	ret    

00800417 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800417:	55                   	push   %ebp
  800418:	89 e5                	mov    %esp,%ebp
  80041a:	57                   	push   %edi
  80041b:	56                   	push   %esi
  80041c:	53                   	push   %ebx
  80041d:	83 ec 1c             	sub    $0x1c,%esp
  800420:	89 c7                	mov    %eax,%edi
  800422:	89 d6                	mov    %edx,%esi
  800424:	8b 45 08             	mov    0x8(%ebp),%eax
  800427:	8b 55 0c             	mov    0xc(%ebp),%edx
  80042a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80042d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800430:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800433:	bb 00 00 00 00       	mov    $0x0,%ebx
  800438:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80043b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80043e:	39 d3                	cmp    %edx,%ebx
  800440:	72 05                	jb     800447 <printnum+0x30>
  800442:	39 45 10             	cmp    %eax,0x10(%ebp)
  800445:	77 7a                	ja     8004c1 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800447:	83 ec 0c             	sub    $0xc,%esp
  80044a:	ff 75 18             	pushl  0x18(%ebp)
  80044d:	8b 45 14             	mov    0x14(%ebp),%eax
  800450:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800453:	53                   	push   %ebx
  800454:	ff 75 10             	pushl  0x10(%ebp)
  800457:	83 ec 08             	sub    $0x8,%esp
  80045a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80045d:	ff 75 e0             	pushl  -0x20(%ebp)
  800460:	ff 75 dc             	pushl  -0x24(%ebp)
  800463:	ff 75 d8             	pushl  -0x28(%ebp)
  800466:	e8 05 1c 00 00       	call   802070 <__udivdi3>
  80046b:	83 c4 18             	add    $0x18,%esp
  80046e:	52                   	push   %edx
  80046f:	50                   	push   %eax
  800470:	89 f2                	mov    %esi,%edx
  800472:	89 f8                	mov    %edi,%eax
  800474:	e8 9e ff ff ff       	call   800417 <printnum>
  800479:	83 c4 20             	add    $0x20,%esp
  80047c:	eb 13                	jmp    800491 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80047e:	83 ec 08             	sub    $0x8,%esp
  800481:	56                   	push   %esi
  800482:	ff 75 18             	pushl  0x18(%ebp)
  800485:	ff d7                	call   *%edi
  800487:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80048a:	83 eb 01             	sub    $0x1,%ebx
  80048d:	85 db                	test   %ebx,%ebx
  80048f:	7f ed                	jg     80047e <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800491:	83 ec 08             	sub    $0x8,%esp
  800494:	56                   	push   %esi
  800495:	83 ec 04             	sub    $0x4,%esp
  800498:	ff 75 e4             	pushl  -0x1c(%ebp)
  80049b:	ff 75 e0             	pushl  -0x20(%ebp)
  80049e:	ff 75 dc             	pushl  -0x24(%ebp)
  8004a1:	ff 75 d8             	pushl  -0x28(%ebp)
  8004a4:	e8 e7 1c 00 00       	call   802190 <__umoddi3>
  8004a9:	83 c4 14             	add    $0x14,%esp
  8004ac:	0f be 80 7b 23 80 00 	movsbl 0x80237b(%eax),%eax
  8004b3:	50                   	push   %eax
  8004b4:	ff d7                	call   *%edi
}
  8004b6:	83 c4 10             	add    $0x10,%esp
  8004b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004bc:	5b                   	pop    %ebx
  8004bd:	5e                   	pop    %esi
  8004be:	5f                   	pop    %edi
  8004bf:	5d                   	pop    %ebp
  8004c0:	c3                   	ret    
  8004c1:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004c4:	eb c4                	jmp    80048a <printnum+0x73>

008004c6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004c6:	55                   	push   %ebp
  8004c7:	89 e5                	mov    %esp,%ebp
  8004c9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004cc:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004d0:	8b 10                	mov    (%eax),%edx
  8004d2:	3b 50 04             	cmp    0x4(%eax),%edx
  8004d5:	73 0a                	jae    8004e1 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004d7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004da:	89 08                	mov    %ecx,(%eax)
  8004dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8004df:	88 02                	mov    %al,(%edx)
}
  8004e1:	5d                   	pop    %ebp
  8004e2:	c3                   	ret    

008004e3 <printfmt>:
{
  8004e3:	55                   	push   %ebp
  8004e4:	89 e5                	mov    %esp,%ebp
  8004e6:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004e9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004ec:	50                   	push   %eax
  8004ed:	ff 75 10             	pushl  0x10(%ebp)
  8004f0:	ff 75 0c             	pushl  0xc(%ebp)
  8004f3:	ff 75 08             	pushl  0x8(%ebp)
  8004f6:	e8 05 00 00 00       	call   800500 <vprintfmt>
}
  8004fb:	83 c4 10             	add    $0x10,%esp
  8004fe:	c9                   	leave  
  8004ff:	c3                   	ret    

00800500 <vprintfmt>:
{
  800500:	55                   	push   %ebp
  800501:	89 e5                	mov    %esp,%ebp
  800503:	57                   	push   %edi
  800504:	56                   	push   %esi
  800505:	53                   	push   %ebx
  800506:	83 ec 2c             	sub    $0x2c,%esp
  800509:	8b 75 08             	mov    0x8(%ebp),%esi
  80050c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80050f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800512:	e9 c1 03 00 00       	jmp    8008d8 <vprintfmt+0x3d8>
		padc = ' ';
  800517:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  80051b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800522:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800529:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800530:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800535:	8d 47 01             	lea    0x1(%edi),%eax
  800538:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80053b:	0f b6 17             	movzbl (%edi),%edx
  80053e:	8d 42 dd             	lea    -0x23(%edx),%eax
  800541:	3c 55                	cmp    $0x55,%al
  800543:	0f 87 12 04 00 00    	ja     80095b <vprintfmt+0x45b>
  800549:	0f b6 c0             	movzbl %al,%eax
  80054c:	ff 24 85 c0 24 80 00 	jmp    *0x8024c0(,%eax,4)
  800553:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800556:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80055a:	eb d9                	jmp    800535 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80055c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80055f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800563:	eb d0                	jmp    800535 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800565:	0f b6 d2             	movzbl %dl,%edx
  800568:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80056b:	b8 00 00 00 00       	mov    $0x0,%eax
  800570:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800573:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800576:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80057a:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80057d:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800580:	83 f9 09             	cmp    $0x9,%ecx
  800583:	77 55                	ja     8005da <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800585:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800588:	eb e9                	jmp    800573 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  80058a:	8b 45 14             	mov    0x14(%ebp),%eax
  80058d:	8b 00                	mov    (%eax),%eax
  80058f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800592:	8b 45 14             	mov    0x14(%ebp),%eax
  800595:	8d 40 04             	lea    0x4(%eax),%eax
  800598:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80059b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80059e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005a2:	79 91                	jns    800535 <vprintfmt+0x35>
				width = precision, precision = -1;
  8005a4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005a7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005aa:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005b1:	eb 82                	jmp    800535 <vprintfmt+0x35>
  8005b3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005b6:	85 c0                	test   %eax,%eax
  8005b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8005bd:	0f 49 d0             	cmovns %eax,%edx
  8005c0:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005c6:	e9 6a ff ff ff       	jmp    800535 <vprintfmt+0x35>
  8005cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005ce:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005d5:	e9 5b ff ff ff       	jmp    800535 <vprintfmt+0x35>
  8005da:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005dd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005e0:	eb bc                	jmp    80059e <vprintfmt+0x9e>
			lflag++;
  8005e2:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8005e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005e8:	e9 48 ff ff ff       	jmp    800535 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8005ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f0:	8d 78 04             	lea    0x4(%eax),%edi
  8005f3:	83 ec 08             	sub    $0x8,%esp
  8005f6:	53                   	push   %ebx
  8005f7:	ff 30                	pushl  (%eax)
  8005f9:	ff d6                	call   *%esi
			break;
  8005fb:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8005fe:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800601:	e9 cf 02 00 00       	jmp    8008d5 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  800606:	8b 45 14             	mov    0x14(%ebp),%eax
  800609:	8d 78 04             	lea    0x4(%eax),%edi
  80060c:	8b 00                	mov    (%eax),%eax
  80060e:	99                   	cltd   
  80060f:	31 d0                	xor    %edx,%eax
  800611:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800613:	83 f8 0f             	cmp    $0xf,%eax
  800616:	7f 23                	jg     80063b <vprintfmt+0x13b>
  800618:	8b 14 85 20 26 80 00 	mov    0x802620(,%eax,4),%edx
  80061f:	85 d2                	test   %edx,%edx
  800621:	74 18                	je     80063b <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800623:	52                   	push   %edx
  800624:	68 55 27 80 00       	push   $0x802755
  800629:	53                   	push   %ebx
  80062a:	56                   	push   %esi
  80062b:	e8 b3 fe ff ff       	call   8004e3 <printfmt>
  800630:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800633:	89 7d 14             	mov    %edi,0x14(%ebp)
  800636:	e9 9a 02 00 00       	jmp    8008d5 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  80063b:	50                   	push   %eax
  80063c:	68 93 23 80 00       	push   $0x802393
  800641:	53                   	push   %ebx
  800642:	56                   	push   %esi
  800643:	e8 9b fe ff ff       	call   8004e3 <printfmt>
  800648:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80064b:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80064e:	e9 82 02 00 00       	jmp    8008d5 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  800653:	8b 45 14             	mov    0x14(%ebp),%eax
  800656:	83 c0 04             	add    $0x4,%eax
  800659:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80065c:	8b 45 14             	mov    0x14(%ebp),%eax
  80065f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800661:	85 ff                	test   %edi,%edi
  800663:	b8 8c 23 80 00       	mov    $0x80238c,%eax
  800668:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80066b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80066f:	0f 8e bd 00 00 00    	jle    800732 <vprintfmt+0x232>
  800675:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800679:	75 0e                	jne    800689 <vprintfmt+0x189>
  80067b:	89 75 08             	mov    %esi,0x8(%ebp)
  80067e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800681:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800684:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800687:	eb 6d                	jmp    8006f6 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  800689:	83 ec 08             	sub    $0x8,%esp
  80068c:	ff 75 d0             	pushl  -0x30(%ebp)
  80068f:	57                   	push   %edi
  800690:	e8 6e 03 00 00       	call   800a03 <strnlen>
  800695:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800698:	29 c1                	sub    %eax,%ecx
  80069a:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80069d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006a0:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006a4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006a7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006aa:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ac:	eb 0f                	jmp    8006bd <vprintfmt+0x1bd>
					putch(padc, putdat);
  8006ae:	83 ec 08             	sub    $0x8,%esp
  8006b1:	53                   	push   %ebx
  8006b2:	ff 75 e0             	pushl  -0x20(%ebp)
  8006b5:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b7:	83 ef 01             	sub    $0x1,%edi
  8006ba:	83 c4 10             	add    $0x10,%esp
  8006bd:	85 ff                	test   %edi,%edi
  8006bf:	7f ed                	jg     8006ae <vprintfmt+0x1ae>
  8006c1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006c4:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006c7:	85 c9                	test   %ecx,%ecx
  8006c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ce:	0f 49 c1             	cmovns %ecx,%eax
  8006d1:	29 c1                	sub    %eax,%ecx
  8006d3:	89 75 08             	mov    %esi,0x8(%ebp)
  8006d6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006d9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006dc:	89 cb                	mov    %ecx,%ebx
  8006de:	eb 16                	jmp    8006f6 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8006e0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006e4:	75 31                	jne    800717 <vprintfmt+0x217>
					putch(ch, putdat);
  8006e6:	83 ec 08             	sub    $0x8,%esp
  8006e9:	ff 75 0c             	pushl  0xc(%ebp)
  8006ec:	50                   	push   %eax
  8006ed:	ff 55 08             	call   *0x8(%ebp)
  8006f0:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006f3:	83 eb 01             	sub    $0x1,%ebx
  8006f6:	83 c7 01             	add    $0x1,%edi
  8006f9:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8006fd:	0f be c2             	movsbl %dl,%eax
  800700:	85 c0                	test   %eax,%eax
  800702:	74 59                	je     80075d <vprintfmt+0x25d>
  800704:	85 f6                	test   %esi,%esi
  800706:	78 d8                	js     8006e0 <vprintfmt+0x1e0>
  800708:	83 ee 01             	sub    $0x1,%esi
  80070b:	79 d3                	jns    8006e0 <vprintfmt+0x1e0>
  80070d:	89 df                	mov    %ebx,%edi
  80070f:	8b 75 08             	mov    0x8(%ebp),%esi
  800712:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800715:	eb 37                	jmp    80074e <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  800717:	0f be d2             	movsbl %dl,%edx
  80071a:	83 ea 20             	sub    $0x20,%edx
  80071d:	83 fa 5e             	cmp    $0x5e,%edx
  800720:	76 c4                	jbe    8006e6 <vprintfmt+0x1e6>
					putch('?', putdat);
  800722:	83 ec 08             	sub    $0x8,%esp
  800725:	ff 75 0c             	pushl  0xc(%ebp)
  800728:	6a 3f                	push   $0x3f
  80072a:	ff 55 08             	call   *0x8(%ebp)
  80072d:	83 c4 10             	add    $0x10,%esp
  800730:	eb c1                	jmp    8006f3 <vprintfmt+0x1f3>
  800732:	89 75 08             	mov    %esi,0x8(%ebp)
  800735:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800738:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80073b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80073e:	eb b6                	jmp    8006f6 <vprintfmt+0x1f6>
				putch(' ', putdat);
  800740:	83 ec 08             	sub    $0x8,%esp
  800743:	53                   	push   %ebx
  800744:	6a 20                	push   $0x20
  800746:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800748:	83 ef 01             	sub    $0x1,%edi
  80074b:	83 c4 10             	add    $0x10,%esp
  80074e:	85 ff                	test   %edi,%edi
  800750:	7f ee                	jg     800740 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800752:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800755:	89 45 14             	mov    %eax,0x14(%ebp)
  800758:	e9 78 01 00 00       	jmp    8008d5 <vprintfmt+0x3d5>
  80075d:	89 df                	mov    %ebx,%edi
  80075f:	8b 75 08             	mov    0x8(%ebp),%esi
  800762:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800765:	eb e7                	jmp    80074e <vprintfmt+0x24e>
	if (lflag >= 2)
  800767:	83 f9 01             	cmp    $0x1,%ecx
  80076a:	7e 3f                	jle    8007ab <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  80076c:	8b 45 14             	mov    0x14(%ebp),%eax
  80076f:	8b 50 04             	mov    0x4(%eax),%edx
  800772:	8b 00                	mov    (%eax),%eax
  800774:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800777:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80077a:	8b 45 14             	mov    0x14(%ebp),%eax
  80077d:	8d 40 08             	lea    0x8(%eax),%eax
  800780:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800783:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800787:	79 5c                	jns    8007e5 <vprintfmt+0x2e5>
				putch('-', putdat);
  800789:	83 ec 08             	sub    $0x8,%esp
  80078c:	53                   	push   %ebx
  80078d:	6a 2d                	push   $0x2d
  80078f:	ff d6                	call   *%esi
				num = -(long long) num;
  800791:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800794:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800797:	f7 da                	neg    %edx
  800799:	83 d1 00             	adc    $0x0,%ecx
  80079c:	f7 d9                	neg    %ecx
  80079e:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007a1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007a6:	e9 10 01 00 00       	jmp    8008bb <vprintfmt+0x3bb>
	else if (lflag)
  8007ab:	85 c9                	test   %ecx,%ecx
  8007ad:	75 1b                	jne    8007ca <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8007af:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b2:	8b 00                	mov    (%eax),%eax
  8007b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007b7:	89 c1                	mov    %eax,%ecx
  8007b9:	c1 f9 1f             	sar    $0x1f,%ecx
  8007bc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c2:	8d 40 04             	lea    0x4(%eax),%eax
  8007c5:	89 45 14             	mov    %eax,0x14(%ebp)
  8007c8:	eb b9                	jmp    800783 <vprintfmt+0x283>
		return va_arg(*ap, long);
  8007ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cd:	8b 00                	mov    (%eax),%eax
  8007cf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d2:	89 c1                	mov    %eax,%ecx
  8007d4:	c1 f9 1f             	sar    $0x1f,%ecx
  8007d7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007da:	8b 45 14             	mov    0x14(%ebp),%eax
  8007dd:	8d 40 04             	lea    0x4(%eax),%eax
  8007e0:	89 45 14             	mov    %eax,0x14(%ebp)
  8007e3:	eb 9e                	jmp    800783 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8007e5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007e8:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007eb:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007f0:	e9 c6 00 00 00       	jmp    8008bb <vprintfmt+0x3bb>
	if (lflag >= 2)
  8007f5:	83 f9 01             	cmp    $0x1,%ecx
  8007f8:	7e 18                	jle    800812 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8007fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fd:	8b 10                	mov    (%eax),%edx
  8007ff:	8b 48 04             	mov    0x4(%eax),%ecx
  800802:	8d 40 08             	lea    0x8(%eax),%eax
  800805:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800808:	b8 0a 00 00 00       	mov    $0xa,%eax
  80080d:	e9 a9 00 00 00       	jmp    8008bb <vprintfmt+0x3bb>
	else if (lflag)
  800812:	85 c9                	test   %ecx,%ecx
  800814:	75 1a                	jne    800830 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  800816:	8b 45 14             	mov    0x14(%ebp),%eax
  800819:	8b 10                	mov    (%eax),%edx
  80081b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800820:	8d 40 04             	lea    0x4(%eax),%eax
  800823:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800826:	b8 0a 00 00 00       	mov    $0xa,%eax
  80082b:	e9 8b 00 00 00       	jmp    8008bb <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800830:	8b 45 14             	mov    0x14(%ebp),%eax
  800833:	8b 10                	mov    (%eax),%edx
  800835:	b9 00 00 00 00       	mov    $0x0,%ecx
  80083a:	8d 40 04             	lea    0x4(%eax),%eax
  80083d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800840:	b8 0a 00 00 00       	mov    $0xa,%eax
  800845:	eb 74                	jmp    8008bb <vprintfmt+0x3bb>
	if (lflag >= 2)
  800847:	83 f9 01             	cmp    $0x1,%ecx
  80084a:	7e 15                	jle    800861 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  80084c:	8b 45 14             	mov    0x14(%ebp),%eax
  80084f:	8b 10                	mov    (%eax),%edx
  800851:	8b 48 04             	mov    0x4(%eax),%ecx
  800854:	8d 40 08             	lea    0x8(%eax),%eax
  800857:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80085a:	b8 08 00 00 00       	mov    $0x8,%eax
  80085f:	eb 5a                	jmp    8008bb <vprintfmt+0x3bb>
	else if (lflag)
  800861:	85 c9                	test   %ecx,%ecx
  800863:	75 17                	jne    80087c <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  800865:	8b 45 14             	mov    0x14(%ebp),%eax
  800868:	8b 10                	mov    (%eax),%edx
  80086a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80086f:	8d 40 04             	lea    0x4(%eax),%eax
  800872:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800875:	b8 08 00 00 00       	mov    $0x8,%eax
  80087a:	eb 3f                	jmp    8008bb <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80087c:	8b 45 14             	mov    0x14(%ebp),%eax
  80087f:	8b 10                	mov    (%eax),%edx
  800881:	b9 00 00 00 00       	mov    $0x0,%ecx
  800886:	8d 40 04             	lea    0x4(%eax),%eax
  800889:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80088c:	b8 08 00 00 00       	mov    $0x8,%eax
  800891:	eb 28                	jmp    8008bb <vprintfmt+0x3bb>
			putch('0', putdat);
  800893:	83 ec 08             	sub    $0x8,%esp
  800896:	53                   	push   %ebx
  800897:	6a 30                	push   $0x30
  800899:	ff d6                	call   *%esi
			putch('x', putdat);
  80089b:	83 c4 08             	add    $0x8,%esp
  80089e:	53                   	push   %ebx
  80089f:	6a 78                	push   $0x78
  8008a1:	ff d6                	call   *%esi
			num = (unsigned long long)
  8008a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a6:	8b 10                	mov    (%eax),%edx
  8008a8:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8008ad:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8008b0:	8d 40 04             	lea    0x4(%eax),%eax
  8008b3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008b6:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8008bb:	83 ec 0c             	sub    $0xc,%esp
  8008be:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008c2:	57                   	push   %edi
  8008c3:	ff 75 e0             	pushl  -0x20(%ebp)
  8008c6:	50                   	push   %eax
  8008c7:	51                   	push   %ecx
  8008c8:	52                   	push   %edx
  8008c9:	89 da                	mov    %ebx,%edx
  8008cb:	89 f0                	mov    %esi,%eax
  8008cd:	e8 45 fb ff ff       	call   800417 <printnum>
			break;
  8008d2:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8008d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008d8:	83 c7 01             	add    $0x1,%edi
  8008db:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008df:	83 f8 25             	cmp    $0x25,%eax
  8008e2:	0f 84 2f fc ff ff    	je     800517 <vprintfmt+0x17>
			if (ch == '\0')
  8008e8:	85 c0                	test   %eax,%eax
  8008ea:	0f 84 8b 00 00 00    	je     80097b <vprintfmt+0x47b>
			putch(ch, putdat);
  8008f0:	83 ec 08             	sub    $0x8,%esp
  8008f3:	53                   	push   %ebx
  8008f4:	50                   	push   %eax
  8008f5:	ff d6                	call   *%esi
  8008f7:	83 c4 10             	add    $0x10,%esp
  8008fa:	eb dc                	jmp    8008d8 <vprintfmt+0x3d8>
	if (lflag >= 2)
  8008fc:	83 f9 01             	cmp    $0x1,%ecx
  8008ff:	7e 15                	jle    800916 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  800901:	8b 45 14             	mov    0x14(%ebp),%eax
  800904:	8b 10                	mov    (%eax),%edx
  800906:	8b 48 04             	mov    0x4(%eax),%ecx
  800909:	8d 40 08             	lea    0x8(%eax),%eax
  80090c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80090f:	b8 10 00 00 00       	mov    $0x10,%eax
  800914:	eb a5                	jmp    8008bb <vprintfmt+0x3bb>
	else if (lflag)
  800916:	85 c9                	test   %ecx,%ecx
  800918:	75 17                	jne    800931 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  80091a:	8b 45 14             	mov    0x14(%ebp),%eax
  80091d:	8b 10                	mov    (%eax),%edx
  80091f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800924:	8d 40 04             	lea    0x4(%eax),%eax
  800927:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80092a:	b8 10 00 00 00       	mov    $0x10,%eax
  80092f:	eb 8a                	jmp    8008bb <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800931:	8b 45 14             	mov    0x14(%ebp),%eax
  800934:	8b 10                	mov    (%eax),%edx
  800936:	b9 00 00 00 00       	mov    $0x0,%ecx
  80093b:	8d 40 04             	lea    0x4(%eax),%eax
  80093e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800941:	b8 10 00 00 00       	mov    $0x10,%eax
  800946:	e9 70 ff ff ff       	jmp    8008bb <vprintfmt+0x3bb>
			putch(ch, putdat);
  80094b:	83 ec 08             	sub    $0x8,%esp
  80094e:	53                   	push   %ebx
  80094f:	6a 25                	push   $0x25
  800951:	ff d6                	call   *%esi
			break;
  800953:	83 c4 10             	add    $0x10,%esp
  800956:	e9 7a ff ff ff       	jmp    8008d5 <vprintfmt+0x3d5>
			putch('%', putdat);
  80095b:	83 ec 08             	sub    $0x8,%esp
  80095e:	53                   	push   %ebx
  80095f:	6a 25                	push   $0x25
  800961:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800963:	83 c4 10             	add    $0x10,%esp
  800966:	89 f8                	mov    %edi,%eax
  800968:	eb 03                	jmp    80096d <vprintfmt+0x46d>
  80096a:	83 e8 01             	sub    $0x1,%eax
  80096d:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800971:	75 f7                	jne    80096a <vprintfmt+0x46a>
  800973:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800976:	e9 5a ff ff ff       	jmp    8008d5 <vprintfmt+0x3d5>
}
  80097b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80097e:	5b                   	pop    %ebx
  80097f:	5e                   	pop    %esi
  800980:	5f                   	pop    %edi
  800981:	5d                   	pop    %ebp
  800982:	c3                   	ret    

00800983 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	83 ec 18             	sub    $0x18,%esp
  800989:	8b 45 08             	mov    0x8(%ebp),%eax
  80098c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80098f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800992:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800996:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800999:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009a0:	85 c0                	test   %eax,%eax
  8009a2:	74 26                	je     8009ca <vsnprintf+0x47>
  8009a4:	85 d2                	test   %edx,%edx
  8009a6:	7e 22                	jle    8009ca <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009a8:	ff 75 14             	pushl  0x14(%ebp)
  8009ab:	ff 75 10             	pushl  0x10(%ebp)
  8009ae:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009b1:	50                   	push   %eax
  8009b2:	68 c6 04 80 00       	push   $0x8004c6
  8009b7:	e8 44 fb ff ff       	call   800500 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009bf:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009c5:	83 c4 10             	add    $0x10,%esp
}
  8009c8:	c9                   	leave  
  8009c9:	c3                   	ret    
		return -E_INVAL;
  8009ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009cf:	eb f7                	jmp    8009c8 <vsnprintf+0x45>

008009d1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009d1:	55                   	push   %ebp
  8009d2:	89 e5                	mov    %esp,%ebp
  8009d4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009d7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009da:	50                   	push   %eax
  8009db:	ff 75 10             	pushl  0x10(%ebp)
  8009de:	ff 75 0c             	pushl  0xc(%ebp)
  8009e1:	ff 75 08             	pushl  0x8(%ebp)
  8009e4:	e8 9a ff ff ff       	call   800983 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009e9:	c9                   	leave  
  8009ea:	c3                   	ret    

008009eb <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009eb:	55                   	push   %ebp
  8009ec:	89 e5                	mov    %esp,%ebp
  8009ee:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f6:	eb 03                	jmp    8009fb <strlen+0x10>
		n++;
  8009f8:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8009fb:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009ff:	75 f7                	jne    8009f8 <strlen+0xd>
	return n;
}
  800a01:	5d                   	pop    %ebp
  800a02:	c3                   	ret    

00800a03 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a03:	55                   	push   %ebp
  800a04:	89 e5                	mov    %esp,%ebp
  800a06:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a09:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a0c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a11:	eb 03                	jmp    800a16 <strnlen+0x13>
		n++;
  800a13:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a16:	39 d0                	cmp    %edx,%eax
  800a18:	74 06                	je     800a20 <strnlen+0x1d>
  800a1a:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a1e:	75 f3                	jne    800a13 <strnlen+0x10>
	return n;
}
  800a20:	5d                   	pop    %ebp
  800a21:	c3                   	ret    

00800a22 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a22:	55                   	push   %ebp
  800a23:	89 e5                	mov    %esp,%ebp
  800a25:	53                   	push   %ebx
  800a26:	8b 45 08             	mov    0x8(%ebp),%eax
  800a29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a2c:	89 c2                	mov    %eax,%edx
  800a2e:	83 c1 01             	add    $0x1,%ecx
  800a31:	83 c2 01             	add    $0x1,%edx
  800a34:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a38:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a3b:	84 db                	test   %bl,%bl
  800a3d:	75 ef                	jne    800a2e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a3f:	5b                   	pop    %ebx
  800a40:	5d                   	pop    %ebp
  800a41:	c3                   	ret    

00800a42 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a42:	55                   	push   %ebp
  800a43:	89 e5                	mov    %esp,%ebp
  800a45:	53                   	push   %ebx
  800a46:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a49:	53                   	push   %ebx
  800a4a:	e8 9c ff ff ff       	call   8009eb <strlen>
  800a4f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a52:	ff 75 0c             	pushl  0xc(%ebp)
  800a55:	01 d8                	add    %ebx,%eax
  800a57:	50                   	push   %eax
  800a58:	e8 c5 ff ff ff       	call   800a22 <strcpy>
	return dst;
}
  800a5d:	89 d8                	mov    %ebx,%eax
  800a5f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a62:	c9                   	leave  
  800a63:	c3                   	ret    

00800a64 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a64:	55                   	push   %ebp
  800a65:	89 e5                	mov    %esp,%ebp
  800a67:	56                   	push   %esi
  800a68:	53                   	push   %ebx
  800a69:	8b 75 08             	mov    0x8(%ebp),%esi
  800a6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a6f:	89 f3                	mov    %esi,%ebx
  800a71:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a74:	89 f2                	mov    %esi,%edx
  800a76:	eb 0f                	jmp    800a87 <strncpy+0x23>
		*dst++ = *src;
  800a78:	83 c2 01             	add    $0x1,%edx
  800a7b:	0f b6 01             	movzbl (%ecx),%eax
  800a7e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a81:	80 39 01             	cmpb   $0x1,(%ecx)
  800a84:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800a87:	39 da                	cmp    %ebx,%edx
  800a89:	75 ed                	jne    800a78 <strncpy+0x14>
	}
	return ret;
}
  800a8b:	89 f0                	mov    %esi,%eax
  800a8d:	5b                   	pop    %ebx
  800a8e:	5e                   	pop    %esi
  800a8f:	5d                   	pop    %ebp
  800a90:	c3                   	ret    

00800a91 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a91:	55                   	push   %ebp
  800a92:	89 e5                	mov    %esp,%ebp
  800a94:	56                   	push   %esi
  800a95:	53                   	push   %ebx
  800a96:	8b 75 08             	mov    0x8(%ebp),%esi
  800a99:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a9c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800a9f:	89 f0                	mov    %esi,%eax
  800aa1:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800aa5:	85 c9                	test   %ecx,%ecx
  800aa7:	75 0b                	jne    800ab4 <strlcpy+0x23>
  800aa9:	eb 17                	jmp    800ac2 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800aab:	83 c2 01             	add    $0x1,%edx
  800aae:	83 c0 01             	add    $0x1,%eax
  800ab1:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800ab4:	39 d8                	cmp    %ebx,%eax
  800ab6:	74 07                	je     800abf <strlcpy+0x2e>
  800ab8:	0f b6 0a             	movzbl (%edx),%ecx
  800abb:	84 c9                	test   %cl,%cl
  800abd:	75 ec                	jne    800aab <strlcpy+0x1a>
		*dst = '\0';
  800abf:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800ac2:	29 f0                	sub    %esi,%eax
}
  800ac4:	5b                   	pop    %ebx
  800ac5:	5e                   	pop    %esi
  800ac6:	5d                   	pop    %ebp
  800ac7:	c3                   	ret    

00800ac8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ac8:	55                   	push   %ebp
  800ac9:	89 e5                	mov    %esp,%ebp
  800acb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ace:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ad1:	eb 06                	jmp    800ad9 <strcmp+0x11>
		p++, q++;
  800ad3:	83 c1 01             	add    $0x1,%ecx
  800ad6:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800ad9:	0f b6 01             	movzbl (%ecx),%eax
  800adc:	84 c0                	test   %al,%al
  800ade:	74 04                	je     800ae4 <strcmp+0x1c>
  800ae0:	3a 02                	cmp    (%edx),%al
  800ae2:	74 ef                	je     800ad3 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ae4:	0f b6 c0             	movzbl %al,%eax
  800ae7:	0f b6 12             	movzbl (%edx),%edx
  800aea:	29 d0                	sub    %edx,%eax
}
  800aec:	5d                   	pop    %ebp
  800aed:	c3                   	ret    

00800aee <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	53                   	push   %ebx
  800af2:	8b 45 08             	mov    0x8(%ebp),%eax
  800af5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800af8:	89 c3                	mov    %eax,%ebx
  800afa:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800afd:	eb 06                	jmp    800b05 <strncmp+0x17>
		n--, p++, q++;
  800aff:	83 c0 01             	add    $0x1,%eax
  800b02:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b05:	39 d8                	cmp    %ebx,%eax
  800b07:	74 16                	je     800b1f <strncmp+0x31>
  800b09:	0f b6 08             	movzbl (%eax),%ecx
  800b0c:	84 c9                	test   %cl,%cl
  800b0e:	74 04                	je     800b14 <strncmp+0x26>
  800b10:	3a 0a                	cmp    (%edx),%cl
  800b12:	74 eb                	je     800aff <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b14:	0f b6 00             	movzbl (%eax),%eax
  800b17:	0f b6 12             	movzbl (%edx),%edx
  800b1a:	29 d0                	sub    %edx,%eax
}
  800b1c:	5b                   	pop    %ebx
  800b1d:	5d                   	pop    %ebp
  800b1e:	c3                   	ret    
		return 0;
  800b1f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b24:	eb f6                	jmp    800b1c <strncmp+0x2e>

00800b26 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b26:	55                   	push   %ebp
  800b27:	89 e5                	mov    %esp,%ebp
  800b29:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b30:	0f b6 10             	movzbl (%eax),%edx
  800b33:	84 d2                	test   %dl,%dl
  800b35:	74 09                	je     800b40 <strchr+0x1a>
		if (*s == c)
  800b37:	38 ca                	cmp    %cl,%dl
  800b39:	74 0a                	je     800b45 <strchr+0x1f>
	for (; *s; s++)
  800b3b:	83 c0 01             	add    $0x1,%eax
  800b3e:	eb f0                	jmp    800b30 <strchr+0xa>
			return (char *) s;
	return 0;
  800b40:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b45:	5d                   	pop    %ebp
  800b46:	c3                   	ret    

00800b47 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b47:	55                   	push   %ebp
  800b48:	89 e5                	mov    %esp,%ebp
  800b4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b51:	eb 03                	jmp    800b56 <strfind+0xf>
  800b53:	83 c0 01             	add    $0x1,%eax
  800b56:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b59:	38 ca                	cmp    %cl,%dl
  800b5b:	74 04                	je     800b61 <strfind+0x1a>
  800b5d:	84 d2                	test   %dl,%dl
  800b5f:	75 f2                	jne    800b53 <strfind+0xc>
			break;
	return (char *) s;
}
  800b61:	5d                   	pop    %ebp
  800b62:	c3                   	ret    

00800b63 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b63:	55                   	push   %ebp
  800b64:	89 e5                	mov    %esp,%ebp
  800b66:	57                   	push   %edi
  800b67:	56                   	push   %esi
  800b68:	53                   	push   %ebx
  800b69:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b6c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b6f:	85 c9                	test   %ecx,%ecx
  800b71:	74 13                	je     800b86 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b73:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b79:	75 05                	jne    800b80 <memset+0x1d>
  800b7b:	f6 c1 03             	test   $0x3,%cl
  800b7e:	74 0d                	je     800b8d <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b80:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b83:	fc                   	cld    
  800b84:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b86:	89 f8                	mov    %edi,%eax
  800b88:	5b                   	pop    %ebx
  800b89:	5e                   	pop    %esi
  800b8a:	5f                   	pop    %edi
  800b8b:	5d                   	pop    %ebp
  800b8c:	c3                   	ret    
		c &= 0xFF;
  800b8d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b91:	89 d3                	mov    %edx,%ebx
  800b93:	c1 e3 08             	shl    $0x8,%ebx
  800b96:	89 d0                	mov    %edx,%eax
  800b98:	c1 e0 18             	shl    $0x18,%eax
  800b9b:	89 d6                	mov    %edx,%esi
  800b9d:	c1 e6 10             	shl    $0x10,%esi
  800ba0:	09 f0                	or     %esi,%eax
  800ba2:	09 c2                	or     %eax,%edx
  800ba4:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800ba6:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800ba9:	89 d0                	mov    %edx,%eax
  800bab:	fc                   	cld    
  800bac:	f3 ab                	rep stos %eax,%es:(%edi)
  800bae:	eb d6                	jmp    800b86 <memset+0x23>

00800bb0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bb0:	55                   	push   %ebp
  800bb1:	89 e5                	mov    %esp,%ebp
  800bb3:	57                   	push   %edi
  800bb4:	56                   	push   %esi
  800bb5:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bbb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bbe:	39 c6                	cmp    %eax,%esi
  800bc0:	73 35                	jae    800bf7 <memmove+0x47>
  800bc2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bc5:	39 c2                	cmp    %eax,%edx
  800bc7:	76 2e                	jbe    800bf7 <memmove+0x47>
		s += n;
		d += n;
  800bc9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bcc:	89 d6                	mov    %edx,%esi
  800bce:	09 fe                	or     %edi,%esi
  800bd0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bd6:	74 0c                	je     800be4 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bd8:	83 ef 01             	sub    $0x1,%edi
  800bdb:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800bde:	fd                   	std    
  800bdf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800be1:	fc                   	cld    
  800be2:	eb 21                	jmp    800c05 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800be4:	f6 c1 03             	test   $0x3,%cl
  800be7:	75 ef                	jne    800bd8 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800be9:	83 ef 04             	sub    $0x4,%edi
  800bec:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bef:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800bf2:	fd                   	std    
  800bf3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bf5:	eb ea                	jmp    800be1 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bf7:	89 f2                	mov    %esi,%edx
  800bf9:	09 c2                	or     %eax,%edx
  800bfb:	f6 c2 03             	test   $0x3,%dl
  800bfe:	74 09                	je     800c09 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c00:	89 c7                	mov    %eax,%edi
  800c02:	fc                   	cld    
  800c03:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c05:	5e                   	pop    %esi
  800c06:	5f                   	pop    %edi
  800c07:	5d                   	pop    %ebp
  800c08:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c09:	f6 c1 03             	test   $0x3,%cl
  800c0c:	75 f2                	jne    800c00 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c0e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c11:	89 c7                	mov    %eax,%edi
  800c13:	fc                   	cld    
  800c14:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c16:	eb ed                	jmp    800c05 <memmove+0x55>

00800c18 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c18:	55                   	push   %ebp
  800c19:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c1b:	ff 75 10             	pushl  0x10(%ebp)
  800c1e:	ff 75 0c             	pushl  0xc(%ebp)
  800c21:	ff 75 08             	pushl  0x8(%ebp)
  800c24:	e8 87 ff ff ff       	call   800bb0 <memmove>
}
  800c29:	c9                   	leave  
  800c2a:	c3                   	ret    

00800c2b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	56                   	push   %esi
  800c2f:	53                   	push   %ebx
  800c30:	8b 45 08             	mov    0x8(%ebp),%eax
  800c33:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c36:	89 c6                	mov    %eax,%esi
  800c38:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c3b:	39 f0                	cmp    %esi,%eax
  800c3d:	74 1c                	je     800c5b <memcmp+0x30>
		if (*s1 != *s2)
  800c3f:	0f b6 08             	movzbl (%eax),%ecx
  800c42:	0f b6 1a             	movzbl (%edx),%ebx
  800c45:	38 d9                	cmp    %bl,%cl
  800c47:	75 08                	jne    800c51 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800c49:	83 c0 01             	add    $0x1,%eax
  800c4c:	83 c2 01             	add    $0x1,%edx
  800c4f:	eb ea                	jmp    800c3b <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800c51:	0f b6 c1             	movzbl %cl,%eax
  800c54:	0f b6 db             	movzbl %bl,%ebx
  800c57:	29 d8                	sub    %ebx,%eax
  800c59:	eb 05                	jmp    800c60 <memcmp+0x35>
	}

	return 0;
  800c5b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c60:	5b                   	pop    %ebx
  800c61:	5e                   	pop    %esi
  800c62:	5d                   	pop    %ebp
  800c63:	c3                   	ret    

00800c64 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c6d:	89 c2                	mov    %eax,%edx
  800c6f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c72:	39 d0                	cmp    %edx,%eax
  800c74:	73 09                	jae    800c7f <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c76:	38 08                	cmp    %cl,(%eax)
  800c78:	74 05                	je     800c7f <memfind+0x1b>
	for (; s < ends; s++)
  800c7a:	83 c0 01             	add    $0x1,%eax
  800c7d:	eb f3                	jmp    800c72 <memfind+0xe>
			break;
	return (void *) s;
}
  800c7f:	5d                   	pop    %ebp
  800c80:	c3                   	ret    

00800c81 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c81:	55                   	push   %ebp
  800c82:	89 e5                	mov    %esp,%ebp
  800c84:	57                   	push   %edi
  800c85:	56                   	push   %esi
  800c86:	53                   	push   %ebx
  800c87:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c8a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c8d:	eb 03                	jmp    800c92 <strtol+0x11>
		s++;
  800c8f:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800c92:	0f b6 01             	movzbl (%ecx),%eax
  800c95:	3c 20                	cmp    $0x20,%al
  800c97:	74 f6                	je     800c8f <strtol+0xe>
  800c99:	3c 09                	cmp    $0x9,%al
  800c9b:	74 f2                	je     800c8f <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800c9d:	3c 2b                	cmp    $0x2b,%al
  800c9f:	74 2e                	je     800ccf <strtol+0x4e>
	int neg = 0;
  800ca1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800ca6:	3c 2d                	cmp    $0x2d,%al
  800ca8:	74 2f                	je     800cd9 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800caa:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800cb0:	75 05                	jne    800cb7 <strtol+0x36>
  800cb2:	80 39 30             	cmpb   $0x30,(%ecx)
  800cb5:	74 2c                	je     800ce3 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cb7:	85 db                	test   %ebx,%ebx
  800cb9:	75 0a                	jne    800cc5 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cbb:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800cc0:	80 39 30             	cmpb   $0x30,(%ecx)
  800cc3:	74 28                	je     800ced <strtol+0x6c>
		base = 10;
  800cc5:	b8 00 00 00 00       	mov    $0x0,%eax
  800cca:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ccd:	eb 50                	jmp    800d1f <strtol+0x9e>
		s++;
  800ccf:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800cd2:	bf 00 00 00 00       	mov    $0x0,%edi
  800cd7:	eb d1                	jmp    800caa <strtol+0x29>
		s++, neg = 1;
  800cd9:	83 c1 01             	add    $0x1,%ecx
  800cdc:	bf 01 00 00 00       	mov    $0x1,%edi
  800ce1:	eb c7                	jmp    800caa <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ce3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ce7:	74 0e                	je     800cf7 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800ce9:	85 db                	test   %ebx,%ebx
  800ceb:	75 d8                	jne    800cc5 <strtol+0x44>
		s++, base = 8;
  800ced:	83 c1 01             	add    $0x1,%ecx
  800cf0:	bb 08 00 00 00       	mov    $0x8,%ebx
  800cf5:	eb ce                	jmp    800cc5 <strtol+0x44>
		s += 2, base = 16;
  800cf7:	83 c1 02             	add    $0x2,%ecx
  800cfa:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cff:	eb c4                	jmp    800cc5 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800d01:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d04:	89 f3                	mov    %esi,%ebx
  800d06:	80 fb 19             	cmp    $0x19,%bl
  800d09:	77 29                	ja     800d34 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800d0b:	0f be d2             	movsbl %dl,%edx
  800d0e:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d11:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d14:	7d 30                	jge    800d46 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800d16:	83 c1 01             	add    $0x1,%ecx
  800d19:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d1d:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800d1f:	0f b6 11             	movzbl (%ecx),%edx
  800d22:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d25:	89 f3                	mov    %esi,%ebx
  800d27:	80 fb 09             	cmp    $0x9,%bl
  800d2a:	77 d5                	ja     800d01 <strtol+0x80>
			dig = *s - '0';
  800d2c:	0f be d2             	movsbl %dl,%edx
  800d2f:	83 ea 30             	sub    $0x30,%edx
  800d32:	eb dd                	jmp    800d11 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800d34:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d37:	89 f3                	mov    %esi,%ebx
  800d39:	80 fb 19             	cmp    $0x19,%bl
  800d3c:	77 08                	ja     800d46 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800d3e:	0f be d2             	movsbl %dl,%edx
  800d41:	83 ea 37             	sub    $0x37,%edx
  800d44:	eb cb                	jmp    800d11 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800d46:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d4a:	74 05                	je     800d51 <strtol+0xd0>
		*endptr = (char *) s;
  800d4c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d4f:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800d51:	89 c2                	mov    %eax,%edx
  800d53:	f7 da                	neg    %edx
  800d55:	85 ff                	test   %edi,%edi
  800d57:	0f 45 c2             	cmovne %edx,%eax
}
  800d5a:	5b                   	pop    %ebx
  800d5b:	5e                   	pop    %esi
  800d5c:	5f                   	pop    %edi
  800d5d:	5d                   	pop    %ebp
  800d5e:	c3                   	ret    

00800d5f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d5f:	55                   	push   %ebp
  800d60:	89 e5                	mov    %esp,%ebp
  800d62:	57                   	push   %edi
  800d63:	56                   	push   %esi
  800d64:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d65:	b8 00 00 00 00       	mov    $0x0,%eax
  800d6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d70:	89 c3                	mov    %eax,%ebx
  800d72:	89 c7                	mov    %eax,%edi
  800d74:	89 c6                	mov    %eax,%esi
  800d76:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d78:	5b                   	pop    %ebx
  800d79:	5e                   	pop    %esi
  800d7a:	5f                   	pop    %edi
  800d7b:	5d                   	pop    %ebp
  800d7c:	c3                   	ret    

00800d7d <sys_cgetc>:

int
sys_cgetc(void)
{
  800d7d:	55                   	push   %ebp
  800d7e:	89 e5                	mov    %esp,%ebp
  800d80:	57                   	push   %edi
  800d81:	56                   	push   %esi
  800d82:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d83:	ba 00 00 00 00       	mov    $0x0,%edx
  800d88:	b8 01 00 00 00       	mov    $0x1,%eax
  800d8d:	89 d1                	mov    %edx,%ecx
  800d8f:	89 d3                	mov    %edx,%ebx
  800d91:	89 d7                	mov    %edx,%edi
  800d93:	89 d6                	mov    %edx,%esi
  800d95:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d97:	5b                   	pop    %ebx
  800d98:	5e                   	pop    %esi
  800d99:	5f                   	pop    %edi
  800d9a:	5d                   	pop    %ebp
  800d9b:	c3                   	ret    

00800d9c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d9c:	55                   	push   %ebp
  800d9d:	89 e5                	mov    %esp,%ebp
  800d9f:	57                   	push   %edi
  800da0:	56                   	push   %esi
  800da1:	53                   	push   %ebx
  800da2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800da5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800daa:	8b 55 08             	mov    0x8(%ebp),%edx
  800dad:	b8 03 00 00 00       	mov    $0x3,%eax
  800db2:	89 cb                	mov    %ecx,%ebx
  800db4:	89 cf                	mov    %ecx,%edi
  800db6:	89 ce                	mov    %ecx,%esi
  800db8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dba:	85 c0                	test   %eax,%eax
  800dbc:	7f 08                	jg     800dc6 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800dbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc1:	5b                   	pop    %ebx
  800dc2:	5e                   	pop    %esi
  800dc3:	5f                   	pop    %edi
  800dc4:	5d                   	pop    %ebp
  800dc5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc6:	83 ec 0c             	sub    $0xc,%esp
  800dc9:	50                   	push   %eax
  800dca:	6a 03                	push   $0x3
  800dcc:	68 7f 26 80 00       	push   $0x80267f
  800dd1:	6a 23                	push   $0x23
  800dd3:	68 9c 26 80 00       	push   $0x80269c
  800dd8:	e8 4b f5 ff ff       	call   800328 <_panic>

00800ddd <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ddd:	55                   	push   %ebp
  800dde:	89 e5                	mov    %esp,%ebp
  800de0:	57                   	push   %edi
  800de1:	56                   	push   %esi
  800de2:	53                   	push   %ebx
	asm volatile("int %1\n"
  800de3:	ba 00 00 00 00       	mov    $0x0,%edx
  800de8:	b8 02 00 00 00       	mov    $0x2,%eax
  800ded:	89 d1                	mov    %edx,%ecx
  800def:	89 d3                	mov    %edx,%ebx
  800df1:	89 d7                	mov    %edx,%edi
  800df3:	89 d6                	mov    %edx,%esi
  800df5:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800df7:	5b                   	pop    %ebx
  800df8:	5e                   	pop    %esi
  800df9:	5f                   	pop    %edi
  800dfa:	5d                   	pop    %ebp
  800dfb:	c3                   	ret    

00800dfc <sys_yield>:

void
sys_yield(void)
{
  800dfc:	55                   	push   %ebp
  800dfd:	89 e5                	mov    %esp,%ebp
  800dff:	57                   	push   %edi
  800e00:	56                   	push   %esi
  800e01:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e02:	ba 00 00 00 00       	mov    $0x0,%edx
  800e07:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e0c:	89 d1                	mov    %edx,%ecx
  800e0e:	89 d3                	mov    %edx,%ebx
  800e10:	89 d7                	mov    %edx,%edi
  800e12:	89 d6                	mov    %edx,%esi
  800e14:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e16:	5b                   	pop    %ebx
  800e17:	5e                   	pop    %esi
  800e18:	5f                   	pop    %edi
  800e19:	5d                   	pop    %ebp
  800e1a:	c3                   	ret    

00800e1b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e1b:	55                   	push   %ebp
  800e1c:	89 e5                	mov    %esp,%ebp
  800e1e:	57                   	push   %edi
  800e1f:	56                   	push   %esi
  800e20:	53                   	push   %ebx
  800e21:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e24:	be 00 00 00 00       	mov    $0x0,%esi
  800e29:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2f:	b8 04 00 00 00       	mov    $0x4,%eax
  800e34:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e37:	89 f7                	mov    %esi,%edi
  800e39:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e3b:	85 c0                	test   %eax,%eax
  800e3d:	7f 08                	jg     800e47 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e42:	5b                   	pop    %ebx
  800e43:	5e                   	pop    %esi
  800e44:	5f                   	pop    %edi
  800e45:	5d                   	pop    %ebp
  800e46:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e47:	83 ec 0c             	sub    $0xc,%esp
  800e4a:	50                   	push   %eax
  800e4b:	6a 04                	push   $0x4
  800e4d:	68 7f 26 80 00       	push   $0x80267f
  800e52:	6a 23                	push   $0x23
  800e54:	68 9c 26 80 00       	push   $0x80269c
  800e59:	e8 ca f4 ff ff       	call   800328 <_panic>

00800e5e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e5e:	55                   	push   %ebp
  800e5f:	89 e5                	mov    %esp,%ebp
  800e61:	57                   	push   %edi
  800e62:	56                   	push   %esi
  800e63:	53                   	push   %ebx
  800e64:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e67:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e6d:	b8 05 00 00 00       	mov    $0x5,%eax
  800e72:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e75:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e78:	8b 75 18             	mov    0x18(%ebp),%esi
  800e7b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e7d:	85 c0                	test   %eax,%eax
  800e7f:	7f 08                	jg     800e89 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e84:	5b                   	pop    %ebx
  800e85:	5e                   	pop    %esi
  800e86:	5f                   	pop    %edi
  800e87:	5d                   	pop    %ebp
  800e88:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e89:	83 ec 0c             	sub    $0xc,%esp
  800e8c:	50                   	push   %eax
  800e8d:	6a 05                	push   $0x5
  800e8f:	68 7f 26 80 00       	push   $0x80267f
  800e94:	6a 23                	push   $0x23
  800e96:	68 9c 26 80 00       	push   $0x80269c
  800e9b:	e8 88 f4 ff ff       	call   800328 <_panic>

00800ea0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ea0:	55                   	push   %ebp
  800ea1:	89 e5                	mov    %esp,%ebp
  800ea3:	57                   	push   %edi
  800ea4:	56                   	push   %esi
  800ea5:	53                   	push   %ebx
  800ea6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ea9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eae:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb4:	b8 06 00 00 00       	mov    $0x6,%eax
  800eb9:	89 df                	mov    %ebx,%edi
  800ebb:	89 de                	mov    %ebx,%esi
  800ebd:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ebf:	85 c0                	test   %eax,%eax
  800ec1:	7f 08                	jg     800ecb <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ec3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ec6:	5b                   	pop    %ebx
  800ec7:	5e                   	pop    %esi
  800ec8:	5f                   	pop    %edi
  800ec9:	5d                   	pop    %ebp
  800eca:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ecb:	83 ec 0c             	sub    $0xc,%esp
  800ece:	50                   	push   %eax
  800ecf:	6a 06                	push   $0x6
  800ed1:	68 7f 26 80 00       	push   $0x80267f
  800ed6:	6a 23                	push   $0x23
  800ed8:	68 9c 26 80 00       	push   $0x80269c
  800edd:	e8 46 f4 ff ff       	call   800328 <_panic>

00800ee2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ee2:	55                   	push   %ebp
  800ee3:	89 e5                	mov    %esp,%ebp
  800ee5:	57                   	push   %edi
  800ee6:	56                   	push   %esi
  800ee7:	53                   	push   %ebx
  800ee8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800eeb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ef0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef6:	b8 08 00 00 00       	mov    $0x8,%eax
  800efb:	89 df                	mov    %ebx,%edi
  800efd:	89 de                	mov    %ebx,%esi
  800eff:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f01:	85 c0                	test   %eax,%eax
  800f03:	7f 08                	jg     800f0d <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f08:	5b                   	pop    %ebx
  800f09:	5e                   	pop    %esi
  800f0a:	5f                   	pop    %edi
  800f0b:	5d                   	pop    %ebp
  800f0c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f0d:	83 ec 0c             	sub    $0xc,%esp
  800f10:	50                   	push   %eax
  800f11:	6a 08                	push   $0x8
  800f13:	68 7f 26 80 00       	push   $0x80267f
  800f18:	6a 23                	push   $0x23
  800f1a:	68 9c 26 80 00       	push   $0x80269c
  800f1f:	e8 04 f4 ff ff       	call   800328 <_panic>

00800f24 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f24:	55                   	push   %ebp
  800f25:	89 e5                	mov    %esp,%ebp
  800f27:	57                   	push   %edi
  800f28:	56                   	push   %esi
  800f29:	53                   	push   %ebx
  800f2a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f2d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f32:	8b 55 08             	mov    0x8(%ebp),%edx
  800f35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f38:	b8 09 00 00 00       	mov    $0x9,%eax
  800f3d:	89 df                	mov    %ebx,%edi
  800f3f:	89 de                	mov    %ebx,%esi
  800f41:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f43:	85 c0                	test   %eax,%eax
  800f45:	7f 08                	jg     800f4f <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f4a:	5b                   	pop    %ebx
  800f4b:	5e                   	pop    %esi
  800f4c:	5f                   	pop    %edi
  800f4d:	5d                   	pop    %ebp
  800f4e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f4f:	83 ec 0c             	sub    $0xc,%esp
  800f52:	50                   	push   %eax
  800f53:	6a 09                	push   $0x9
  800f55:	68 7f 26 80 00       	push   $0x80267f
  800f5a:	6a 23                	push   $0x23
  800f5c:	68 9c 26 80 00       	push   $0x80269c
  800f61:	e8 c2 f3 ff ff       	call   800328 <_panic>

00800f66 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f66:	55                   	push   %ebp
  800f67:	89 e5                	mov    %esp,%ebp
  800f69:	57                   	push   %edi
  800f6a:	56                   	push   %esi
  800f6b:	53                   	push   %ebx
  800f6c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f6f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f74:	8b 55 08             	mov    0x8(%ebp),%edx
  800f77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f7a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f7f:	89 df                	mov    %ebx,%edi
  800f81:	89 de                	mov    %ebx,%esi
  800f83:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f85:	85 c0                	test   %eax,%eax
  800f87:	7f 08                	jg     800f91 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f8c:	5b                   	pop    %ebx
  800f8d:	5e                   	pop    %esi
  800f8e:	5f                   	pop    %edi
  800f8f:	5d                   	pop    %ebp
  800f90:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f91:	83 ec 0c             	sub    $0xc,%esp
  800f94:	50                   	push   %eax
  800f95:	6a 0a                	push   $0xa
  800f97:	68 7f 26 80 00       	push   $0x80267f
  800f9c:	6a 23                	push   $0x23
  800f9e:	68 9c 26 80 00       	push   $0x80269c
  800fa3:	e8 80 f3 ff ff       	call   800328 <_panic>

00800fa8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fa8:	55                   	push   %ebp
  800fa9:	89 e5                	mov    %esp,%ebp
  800fab:	57                   	push   %edi
  800fac:	56                   	push   %esi
  800fad:	53                   	push   %ebx
	asm volatile("int %1\n"
  800fae:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fb9:	be 00 00 00 00       	mov    $0x0,%esi
  800fbe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fc1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fc4:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800fc6:	5b                   	pop    %ebx
  800fc7:	5e                   	pop    %esi
  800fc8:	5f                   	pop    %edi
  800fc9:	5d                   	pop    %ebp
  800fca:	c3                   	ret    

00800fcb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800fcb:	55                   	push   %ebp
  800fcc:	89 e5                	mov    %esp,%ebp
  800fce:	57                   	push   %edi
  800fcf:	56                   	push   %esi
  800fd0:	53                   	push   %ebx
  800fd1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800fd4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800fdc:	b8 0d 00 00 00       	mov    $0xd,%eax
  800fe1:	89 cb                	mov    %ecx,%ebx
  800fe3:	89 cf                	mov    %ecx,%edi
  800fe5:	89 ce                	mov    %ecx,%esi
  800fe7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800fe9:	85 c0                	test   %eax,%eax
  800feb:	7f 08                	jg     800ff5 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ff0:	5b                   	pop    %ebx
  800ff1:	5e                   	pop    %esi
  800ff2:	5f                   	pop    %edi
  800ff3:	5d                   	pop    %ebp
  800ff4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ff5:	83 ec 0c             	sub    $0xc,%esp
  800ff8:	50                   	push   %eax
  800ff9:	6a 0d                	push   $0xd
  800ffb:	68 7f 26 80 00       	push   $0x80267f
  801000:	6a 23                	push   $0x23
  801002:	68 9c 26 80 00       	push   $0x80269c
  801007:	e8 1c f3 ff ff       	call   800328 <_panic>

0080100c <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  80100c:	55                   	push   %ebp
  80100d:	89 e5                	mov    %esp,%ebp
  80100f:	8b 55 08             	mov    0x8(%ebp),%edx
  801012:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801015:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801018:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  80101a:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  80101d:	83 3a 01             	cmpl   $0x1,(%edx)
  801020:	7e 09                	jle    80102b <argstart+0x1f>
  801022:	ba 28 23 80 00       	mov    $0x802328,%edx
  801027:	85 c9                	test   %ecx,%ecx
  801029:	75 05                	jne    801030 <argstart+0x24>
  80102b:	ba 00 00 00 00       	mov    $0x0,%edx
  801030:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801033:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  80103a:	5d                   	pop    %ebp
  80103b:	c3                   	ret    

0080103c <argnext>:

int
argnext(struct Argstate *args)
{
  80103c:	55                   	push   %ebp
  80103d:	89 e5                	mov    %esp,%ebp
  80103f:	53                   	push   %ebx
  801040:	83 ec 04             	sub    $0x4,%esp
  801043:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801046:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  80104d:	8b 43 08             	mov    0x8(%ebx),%eax
  801050:	85 c0                	test   %eax,%eax
  801052:	74 72                	je     8010c6 <argnext+0x8a>
		return -1;

	if (!*args->curarg) {
  801054:	80 38 00             	cmpb   $0x0,(%eax)
  801057:	75 48                	jne    8010a1 <argnext+0x65>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801059:	8b 0b                	mov    (%ebx),%ecx
  80105b:	83 39 01             	cmpl   $0x1,(%ecx)
  80105e:	74 58                	je     8010b8 <argnext+0x7c>
		    || args->argv[1][0] != '-'
  801060:	8b 53 04             	mov    0x4(%ebx),%edx
  801063:	8b 42 04             	mov    0x4(%edx),%eax
  801066:	80 38 2d             	cmpb   $0x2d,(%eax)
  801069:	75 4d                	jne    8010b8 <argnext+0x7c>
		    || args->argv[1][1] == '\0')
  80106b:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  80106f:	74 47                	je     8010b8 <argnext+0x7c>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801071:	83 c0 01             	add    $0x1,%eax
  801074:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801077:	83 ec 04             	sub    $0x4,%esp
  80107a:	8b 01                	mov    (%ecx),%eax
  80107c:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801083:	50                   	push   %eax
  801084:	8d 42 08             	lea    0x8(%edx),%eax
  801087:	50                   	push   %eax
  801088:	83 c2 04             	add    $0x4,%edx
  80108b:	52                   	push   %edx
  80108c:	e8 1f fb ff ff       	call   800bb0 <memmove>
		(*args->argc)--;
  801091:	8b 03                	mov    (%ebx),%eax
  801093:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801096:	8b 43 08             	mov    0x8(%ebx),%eax
  801099:	83 c4 10             	add    $0x10,%esp
  80109c:	80 38 2d             	cmpb   $0x2d,(%eax)
  80109f:	74 11                	je     8010b2 <argnext+0x76>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  8010a1:	8b 53 08             	mov    0x8(%ebx),%edx
  8010a4:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  8010a7:	83 c2 01             	add    $0x1,%edx
  8010aa:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  8010ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010b0:	c9                   	leave  
  8010b1:	c3                   	ret    
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  8010b2:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  8010b6:	75 e9                	jne    8010a1 <argnext+0x65>
	args->curarg = 0;
  8010b8:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  8010bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8010c4:	eb e7                	jmp    8010ad <argnext+0x71>
		return -1;
  8010c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8010cb:	eb e0                	jmp    8010ad <argnext+0x71>

008010cd <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  8010cd:	55                   	push   %ebp
  8010ce:	89 e5                	mov    %esp,%ebp
  8010d0:	53                   	push   %ebx
  8010d1:	83 ec 04             	sub    $0x4,%esp
  8010d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  8010d7:	8b 43 08             	mov    0x8(%ebx),%eax
  8010da:	85 c0                	test   %eax,%eax
  8010dc:	74 5b                	je     801139 <argnextvalue+0x6c>
		return 0;
	if (*args->curarg) {
  8010de:	80 38 00             	cmpb   $0x0,(%eax)
  8010e1:	74 12                	je     8010f5 <argnextvalue+0x28>
		args->argvalue = args->curarg;
  8010e3:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  8010e6:	c7 43 08 28 23 80 00 	movl   $0x802328,0x8(%ebx)
		(*args->argc)--;
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
  8010ed:	8b 43 0c             	mov    0xc(%ebx),%eax
}
  8010f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010f3:	c9                   	leave  
  8010f4:	c3                   	ret    
	} else if (*args->argc > 1) {
  8010f5:	8b 13                	mov    (%ebx),%edx
  8010f7:	83 3a 01             	cmpl   $0x1,(%edx)
  8010fa:	7f 10                	jg     80110c <argnextvalue+0x3f>
		args->argvalue = 0;
  8010fc:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801103:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  80110a:	eb e1                	jmp    8010ed <argnextvalue+0x20>
		args->argvalue = args->argv[1];
  80110c:	8b 43 04             	mov    0x4(%ebx),%eax
  80110f:	8b 48 04             	mov    0x4(%eax),%ecx
  801112:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801115:	83 ec 04             	sub    $0x4,%esp
  801118:	8b 12                	mov    (%edx),%edx
  80111a:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801121:	52                   	push   %edx
  801122:	8d 50 08             	lea    0x8(%eax),%edx
  801125:	52                   	push   %edx
  801126:	83 c0 04             	add    $0x4,%eax
  801129:	50                   	push   %eax
  80112a:	e8 81 fa ff ff       	call   800bb0 <memmove>
		(*args->argc)--;
  80112f:	8b 03                	mov    (%ebx),%eax
  801131:	83 28 01             	subl   $0x1,(%eax)
  801134:	83 c4 10             	add    $0x10,%esp
  801137:	eb b4                	jmp    8010ed <argnextvalue+0x20>
		return 0;
  801139:	b8 00 00 00 00       	mov    $0x0,%eax
  80113e:	eb b0                	jmp    8010f0 <argnextvalue+0x23>

00801140 <argvalue>:
{
  801140:	55                   	push   %ebp
  801141:	89 e5                	mov    %esp,%ebp
  801143:	83 ec 08             	sub    $0x8,%esp
  801146:	8b 55 08             	mov    0x8(%ebp),%edx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801149:	8b 42 0c             	mov    0xc(%edx),%eax
  80114c:	85 c0                	test   %eax,%eax
  80114e:	74 02                	je     801152 <argvalue+0x12>
}
  801150:	c9                   	leave  
  801151:	c3                   	ret    
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801152:	83 ec 0c             	sub    $0xc,%esp
  801155:	52                   	push   %edx
  801156:	e8 72 ff ff ff       	call   8010cd <argnextvalue>
  80115b:	83 c4 10             	add    $0x10,%esp
  80115e:	eb f0                	jmp    801150 <argvalue+0x10>

00801160 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801160:	55                   	push   %ebp
  801161:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801163:	8b 45 08             	mov    0x8(%ebp),%eax
  801166:	05 00 00 00 30       	add    $0x30000000,%eax
  80116b:	c1 e8 0c             	shr    $0xc,%eax
}
  80116e:	5d                   	pop    %ebp
  80116f:	c3                   	ret    

00801170 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801170:	55                   	push   %ebp
  801171:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801173:	8b 45 08             	mov    0x8(%ebp),%eax
  801176:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80117b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801180:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801185:	5d                   	pop    %ebp
  801186:	c3                   	ret    

00801187 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801187:	55                   	push   %ebp
  801188:	89 e5                	mov    %esp,%ebp
  80118a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80118d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801192:	89 c2                	mov    %eax,%edx
  801194:	c1 ea 16             	shr    $0x16,%edx
  801197:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80119e:	f6 c2 01             	test   $0x1,%dl
  8011a1:	74 2a                	je     8011cd <fd_alloc+0x46>
  8011a3:	89 c2                	mov    %eax,%edx
  8011a5:	c1 ea 0c             	shr    $0xc,%edx
  8011a8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011af:	f6 c2 01             	test   $0x1,%dl
  8011b2:	74 19                	je     8011cd <fd_alloc+0x46>
  8011b4:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8011b9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011be:	75 d2                	jne    801192 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011c0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011c6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8011cb:	eb 07                	jmp    8011d4 <fd_alloc+0x4d>
			*fd_store = fd;
  8011cd:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011d4:	5d                   	pop    %ebp
  8011d5:	c3                   	ret    

008011d6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011d6:	55                   	push   %ebp
  8011d7:	89 e5                	mov    %esp,%ebp
  8011d9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011dc:	83 f8 1f             	cmp    $0x1f,%eax
  8011df:	77 36                	ja     801217 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011e1:	c1 e0 0c             	shl    $0xc,%eax
  8011e4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011e9:	89 c2                	mov    %eax,%edx
  8011eb:	c1 ea 16             	shr    $0x16,%edx
  8011ee:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011f5:	f6 c2 01             	test   $0x1,%dl
  8011f8:	74 24                	je     80121e <fd_lookup+0x48>
  8011fa:	89 c2                	mov    %eax,%edx
  8011fc:	c1 ea 0c             	shr    $0xc,%edx
  8011ff:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801206:	f6 c2 01             	test   $0x1,%dl
  801209:	74 1a                	je     801225 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80120b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80120e:	89 02                	mov    %eax,(%edx)
	return 0;
  801210:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801215:	5d                   	pop    %ebp
  801216:	c3                   	ret    
		return -E_INVAL;
  801217:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80121c:	eb f7                	jmp    801215 <fd_lookup+0x3f>
		return -E_INVAL;
  80121e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801223:	eb f0                	jmp    801215 <fd_lookup+0x3f>
  801225:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80122a:	eb e9                	jmp    801215 <fd_lookup+0x3f>

0080122c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80122c:	55                   	push   %ebp
  80122d:	89 e5                	mov    %esp,%ebp
  80122f:	83 ec 08             	sub    $0x8,%esp
  801232:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801235:	ba 2c 27 80 00       	mov    $0x80272c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80123a:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  80123f:	39 08                	cmp    %ecx,(%eax)
  801241:	74 33                	je     801276 <dev_lookup+0x4a>
  801243:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  801246:	8b 02                	mov    (%edx),%eax
  801248:	85 c0                	test   %eax,%eax
  80124a:	75 f3                	jne    80123f <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80124c:	a1 20 44 80 00       	mov    0x804420,%eax
  801251:	8b 40 48             	mov    0x48(%eax),%eax
  801254:	83 ec 04             	sub    $0x4,%esp
  801257:	51                   	push   %ecx
  801258:	50                   	push   %eax
  801259:	68 ac 26 80 00       	push   $0x8026ac
  80125e:	e8 a0 f1 ff ff       	call   800403 <cprintf>
	*dev = 0;
  801263:	8b 45 0c             	mov    0xc(%ebp),%eax
  801266:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80126c:	83 c4 10             	add    $0x10,%esp
  80126f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801274:	c9                   	leave  
  801275:	c3                   	ret    
			*dev = devtab[i];
  801276:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801279:	89 01                	mov    %eax,(%ecx)
			return 0;
  80127b:	b8 00 00 00 00       	mov    $0x0,%eax
  801280:	eb f2                	jmp    801274 <dev_lookup+0x48>

00801282 <fd_close>:
{
  801282:	55                   	push   %ebp
  801283:	89 e5                	mov    %esp,%ebp
  801285:	57                   	push   %edi
  801286:	56                   	push   %esi
  801287:	53                   	push   %ebx
  801288:	83 ec 1c             	sub    $0x1c,%esp
  80128b:	8b 75 08             	mov    0x8(%ebp),%esi
  80128e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801291:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801294:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801295:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80129b:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80129e:	50                   	push   %eax
  80129f:	e8 32 ff ff ff       	call   8011d6 <fd_lookup>
  8012a4:	89 c3                	mov    %eax,%ebx
  8012a6:	83 c4 08             	add    $0x8,%esp
  8012a9:	85 c0                	test   %eax,%eax
  8012ab:	78 05                	js     8012b2 <fd_close+0x30>
	    || fd != fd2)
  8012ad:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8012b0:	74 16                	je     8012c8 <fd_close+0x46>
		return (must_exist ? r : 0);
  8012b2:	89 f8                	mov    %edi,%eax
  8012b4:	84 c0                	test   %al,%al
  8012b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8012bb:	0f 44 d8             	cmove  %eax,%ebx
}
  8012be:	89 d8                	mov    %ebx,%eax
  8012c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012c3:	5b                   	pop    %ebx
  8012c4:	5e                   	pop    %esi
  8012c5:	5f                   	pop    %edi
  8012c6:	5d                   	pop    %ebp
  8012c7:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012c8:	83 ec 08             	sub    $0x8,%esp
  8012cb:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8012ce:	50                   	push   %eax
  8012cf:	ff 36                	pushl  (%esi)
  8012d1:	e8 56 ff ff ff       	call   80122c <dev_lookup>
  8012d6:	89 c3                	mov    %eax,%ebx
  8012d8:	83 c4 10             	add    $0x10,%esp
  8012db:	85 c0                	test   %eax,%eax
  8012dd:	78 15                	js     8012f4 <fd_close+0x72>
		if (dev->dev_close)
  8012df:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012e2:	8b 40 10             	mov    0x10(%eax),%eax
  8012e5:	85 c0                	test   %eax,%eax
  8012e7:	74 1b                	je     801304 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  8012e9:	83 ec 0c             	sub    $0xc,%esp
  8012ec:	56                   	push   %esi
  8012ed:	ff d0                	call   *%eax
  8012ef:	89 c3                	mov    %eax,%ebx
  8012f1:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8012f4:	83 ec 08             	sub    $0x8,%esp
  8012f7:	56                   	push   %esi
  8012f8:	6a 00                	push   $0x0
  8012fa:	e8 a1 fb ff ff       	call   800ea0 <sys_page_unmap>
	return r;
  8012ff:	83 c4 10             	add    $0x10,%esp
  801302:	eb ba                	jmp    8012be <fd_close+0x3c>
			r = 0;
  801304:	bb 00 00 00 00       	mov    $0x0,%ebx
  801309:	eb e9                	jmp    8012f4 <fd_close+0x72>

0080130b <close>:

int
close(int fdnum)
{
  80130b:	55                   	push   %ebp
  80130c:	89 e5                	mov    %esp,%ebp
  80130e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801311:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801314:	50                   	push   %eax
  801315:	ff 75 08             	pushl  0x8(%ebp)
  801318:	e8 b9 fe ff ff       	call   8011d6 <fd_lookup>
  80131d:	83 c4 08             	add    $0x8,%esp
  801320:	85 c0                	test   %eax,%eax
  801322:	78 10                	js     801334 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801324:	83 ec 08             	sub    $0x8,%esp
  801327:	6a 01                	push   $0x1
  801329:	ff 75 f4             	pushl  -0xc(%ebp)
  80132c:	e8 51 ff ff ff       	call   801282 <fd_close>
  801331:	83 c4 10             	add    $0x10,%esp
}
  801334:	c9                   	leave  
  801335:	c3                   	ret    

00801336 <close_all>:

void
close_all(void)
{
  801336:	55                   	push   %ebp
  801337:	89 e5                	mov    %esp,%ebp
  801339:	53                   	push   %ebx
  80133a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80133d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801342:	83 ec 0c             	sub    $0xc,%esp
  801345:	53                   	push   %ebx
  801346:	e8 c0 ff ff ff       	call   80130b <close>
	for (i = 0; i < MAXFD; i++)
  80134b:	83 c3 01             	add    $0x1,%ebx
  80134e:	83 c4 10             	add    $0x10,%esp
  801351:	83 fb 20             	cmp    $0x20,%ebx
  801354:	75 ec                	jne    801342 <close_all+0xc>
}
  801356:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801359:	c9                   	leave  
  80135a:	c3                   	ret    

0080135b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80135b:	55                   	push   %ebp
  80135c:	89 e5                	mov    %esp,%ebp
  80135e:	57                   	push   %edi
  80135f:	56                   	push   %esi
  801360:	53                   	push   %ebx
  801361:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801364:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801367:	50                   	push   %eax
  801368:	ff 75 08             	pushl  0x8(%ebp)
  80136b:	e8 66 fe ff ff       	call   8011d6 <fd_lookup>
  801370:	89 c3                	mov    %eax,%ebx
  801372:	83 c4 08             	add    $0x8,%esp
  801375:	85 c0                	test   %eax,%eax
  801377:	0f 88 81 00 00 00    	js     8013fe <dup+0xa3>
		return r;
	close(newfdnum);
  80137d:	83 ec 0c             	sub    $0xc,%esp
  801380:	ff 75 0c             	pushl  0xc(%ebp)
  801383:	e8 83 ff ff ff       	call   80130b <close>

	newfd = INDEX2FD(newfdnum);
  801388:	8b 75 0c             	mov    0xc(%ebp),%esi
  80138b:	c1 e6 0c             	shl    $0xc,%esi
  80138e:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801394:	83 c4 04             	add    $0x4,%esp
  801397:	ff 75 e4             	pushl  -0x1c(%ebp)
  80139a:	e8 d1 fd ff ff       	call   801170 <fd2data>
  80139f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8013a1:	89 34 24             	mov    %esi,(%esp)
  8013a4:	e8 c7 fd ff ff       	call   801170 <fd2data>
  8013a9:	83 c4 10             	add    $0x10,%esp
  8013ac:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013ae:	89 d8                	mov    %ebx,%eax
  8013b0:	c1 e8 16             	shr    $0x16,%eax
  8013b3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013ba:	a8 01                	test   $0x1,%al
  8013bc:	74 11                	je     8013cf <dup+0x74>
  8013be:	89 d8                	mov    %ebx,%eax
  8013c0:	c1 e8 0c             	shr    $0xc,%eax
  8013c3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013ca:	f6 c2 01             	test   $0x1,%dl
  8013cd:	75 39                	jne    801408 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013cf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013d2:	89 d0                	mov    %edx,%eax
  8013d4:	c1 e8 0c             	shr    $0xc,%eax
  8013d7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013de:	83 ec 0c             	sub    $0xc,%esp
  8013e1:	25 07 0e 00 00       	and    $0xe07,%eax
  8013e6:	50                   	push   %eax
  8013e7:	56                   	push   %esi
  8013e8:	6a 00                	push   $0x0
  8013ea:	52                   	push   %edx
  8013eb:	6a 00                	push   $0x0
  8013ed:	e8 6c fa ff ff       	call   800e5e <sys_page_map>
  8013f2:	89 c3                	mov    %eax,%ebx
  8013f4:	83 c4 20             	add    $0x20,%esp
  8013f7:	85 c0                	test   %eax,%eax
  8013f9:	78 31                	js     80142c <dup+0xd1>
		goto err;

	return newfdnum;
  8013fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8013fe:	89 d8                	mov    %ebx,%eax
  801400:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801403:	5b                   	pop    %ebx
  801404:	5e                   	pop    %esi
  801405:	5f                   	pop    %edi
  801406:	5d                   	pop    %ebp
  801407:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801408:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80140f:	83 ec 0c             	sub    $0xc,%esp
  801412:	25 07 0e 00 00       	and    $0xe07,%eax
  801417:	50                   	push   %eax
  801418:	57                   	push   %edi
  801419:	6a 00                	push   $0x0
  80141b:	53                   	push   %ebx
  80141c:	6a 00                	push   $0x0
  80141e:	e8 3b fa ff ff       	call   800e5e <sys_page_map>
  801423:	89 c3                	mov    %eax,%ebx
  801425:	83 c4 20             	add    $0x20,%esp
  801428:	85 c0                	test   %eax,%eax
  80142a:	79 a3                	jns    8013cf <dup+0x74>
	sys_page_unmap(0, newfd);
  80142c:	83 ec 08             	sub    $0x8,%esp
  80142f:	56                   	push   %esi
  801430:	6a 00                	push   $0x0
  801432:	e8 69 fa ff ff       	call   800ea0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801437:	83 c4 08             	add    $0x8,%esp
  80143a:	57                   	push   %edi
  80143b:	6a 00                	push   $0x0
  80143d:	e8 5e fa ff ff       	call   800ea0 <sys_page_unmap>
	return r;
  801442:	83 c4 10             	add    $0x10,%esp
  801445:	eb b7                	jmp    8013fe <dup+0xa3>

00801447 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801447:	55                   	push   %ebp
  801448:	89 e5                	mov    %esp,%ebp
  80144a:	53                   	push   %ebx
  80144b:	83 ec 14             	sub    $0x14,%esp
  80144e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801451:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801454:	50                   	push   %eax
  801455:	53                   	push   %ebx
  801456:	e8 7b fd ff ff       	call   8011d6 <fd_lookup>
  80145b:	83 c4 08             	add    $0x8,%esp
  80145e:	85 c0                	test   %eax,%eax
  801460:	78 3f                	js     8014a1 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801462:	83 ec 08             	sub    $0x8,%esp
  801465:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801468:	50                   	push   %eax
  801469:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80146c:	ff 30                	pushl  (%eax)
  80146e:	e8 b9 fd ff ff       	call   80122c <dev_lookup>
  801473:	83 c4 10             	add    $0x10,%esp
  801476:	85 c0                	test   %eax,%eax
  801478:	78 27                	js     8014a1 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80147a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80147d:	8b 42 08             	mov    0x8(%edx),%eax
  801480:	83 e0 03             	and    $0x3,%eax
  801483:	83 f8 01             	cmp    $0x1,%eax
  801486:	74 1e                	je     8014a6 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801488:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80148b:	8b 40 08             	mov    0x8(%eax),%eax
  80148e:	85 c0                	test   %eax,%eax
  801490:	74 35                	je     8014c7 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801492:	83 ec 04             	sub    $0x4,%esp
  801495:	ff 75 10             	pushl  0x10(%ebp)
  801498:	ff 75 0c             	pushl  0xc(%ebp)
  80149b:	52                   	push   %edx
  80149c:	ff d0                	call   *%eax
  80149e:	83 c4 10             	add    $0x10,%esp
}
  8014a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a4:	c9                   	leave  
  8014a5:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014a6:	a1 20 44 80 00       	mov    0x804420,%eax
  8014ab:	8b 40 48             	mov    0x48(%eax),%eax
  8014ae:	83 ec 04             	sub    $0x4,%esp
  8014b1:	53                   	push   %ebx
  8014b2:	50                   	push   %eax
  8014b3:	68 f0 26 80 00       	push   $0x8026f0
  8014b8:	e8 46 ef ff ff       	call   800403 <cprintf>
		return -E_INVAL;
  8014bd:	83 c4 10             	add    $0x10,%esp
  8014c0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014c5:	eb da                	jmp    8014a1 <read+0x5a>
		return -E_NOT_SUPP;
  8014c7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014cc:	eb d3                	jmp    8014a1 <read+0x5a>

008014ce <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014ce:	55                   	push   %ebp
  8014cf:	89 e5                	mov    %esp,%ebp
  8014d1:	57                   	push   %edi
  8014d2:	56                   	push   %esi
  8014d3:	53                   	push   %ebx
  8014d4:	83 ec 0c             	sub    $0xc,%esp
  8014d7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014da:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014dd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014e2:	39 f3                	cmp    %esi,%ebx
  8014e4:	73 25                	jae    80150b <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014e6:	83 ec 04             	sub    $0x4,%esp
  8014e9:	89 f0                	mov    %esi,%eax
  8014eb:	29 d8                	sub    %ebx,%eax
  8014ed:	50                   	push   %eax
  8014ee:	89 d8                	mov    %ebx,%eax
  8014f0:	03 45 0c             	add    0xc(%ebp),%eax
  8014f3:	50                   	push   %eax
  8014f4:	57                   	push   %edi
  8014f5:	e8 4d ff ff ff       	call   801447 <read>
		if (m < 0)
  8014fa:	83 c4 10             	add    $0x10,%esp
  8014fd:	85 c0                	test   %eax,%eax
  8014ff:	78 08                	js     801509 <readn+0x3b>
			return m;
		if (m == 0)
  801501:	85 c0                	test   %eax,%eax
  801503:	74 06                	je     80150b <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  801505:	01 c3                	add    %eax,%ebx
  801507:	eb d9                	jmp    8014e2 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801509:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80150b:	89 d8                	mov    %ebx,%eax
  80150d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801510:	5b                   	pop    %ebx
  801511:	5e                   	pop    %esi
  801512:	5f                   	pop    %edi
  801513:	5d                   	pop    %ebp
  801514:	c3                   	ret    

00801515 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801515:	55                   	push   %ebp
  801516:	89 e5                	mov    %esp,%ebp
  801518:	53                   	push   %ebx
  801519:	83 ec 14             	sub    $0x14,%esp
  80151c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80151f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801522:	50                   	push   %eax
  801523:	53                   	push   %ebx
  801524:	e8 ad fc ff ff       	call   8011d6 <fd_lookup>
  801529:	83 c4 08             	add    $0x8,%esp
  80152c:	85 c0                	test   %eax,%eax
  80152e:	78 3a                	js     80156a <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801530:	83 ec 08             	sub    $0x8,%esp
  801533:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801536:	50                   	push   %eax
  801537:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153a:	ff 30                	pushl  (%eax)
  80153c:	e8 eb fc ff ff       	call   80122c <dev_lookup>
  801541:	83 c4 10             	add    $0x10,%esp
  801544:	85 c0                	test   %eax,%eax
  801546:	78 22                	js     80156a <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801548:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80154b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80154f:	74 1e                	je     80156f <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801551:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801554:	8b 52 0c             	mov    0xc(%edx),%edx
  801557:	85 d2                	test   %edx,%edx
  801559:	74 35                	je     801590 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80155b:	83 ec 04             	sub    $0x4,%esp
  80155e:	ff 75 10             	pushl  0x10(%ebp)
  801561:	ff 75 0c             	pushl  0xc(%ebp)
  801564:	50                   	push   %eax
  801565:	ff d2                	call   *%edx
  801567:	83 c4 10             	add    $0x10,%esp
}
  80156a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80156d:	c9                   	leave  
  80156e:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80156f:	a1 20 44 80 00       	mov    0x804420,%eax
  801574:	8b 40 48             	mov    0x48(%eax),%eax
  801577:	83 ec 04             	sub    $0x4,%esp
  80157a:	53                   	push   %ebx
  80157b:	50                   	push   %eax
  80157c:	68 0c 27 80 00       	push   $0x80270c
  801581:	e8 7d ee ff ff       	call   800403 <cprintf>
		return -E_INVAL;
  801586:	83 c4 10             	add    $0x10,%esp
  801589:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80158e:	eb da                	jmp    80156a <write+0x55>
		return -E_NOT_SUPP;
  801590:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801595:	eb d3                	jmp    80156a <write+0x55>

00801597 <seek>:

int
seek(int fdnum, off_t offset)
{
  801597:	55                   	push   %ebp
  801598:	89 e5                	mov    %esp,%ebp
  80159a:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80159d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015a0:	50                   	push   %eax
  8015a1:	ff 75 08             	pushl  0x8(%ebp)
  8015a4:	e8 2d fc ff ff       	call   8011d6 <fd_lookup>
  8015a9:	83 c4 08             	add    $0x8,%esp
  8015ac:	85 c0                	test   %eax,%eax
  8015ae:	78 0e                	js     8015be <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015b6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015be:	c9                   	leave  
  8015bf:	c3                   	ret    

008015c0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015c0:	55                   	push   %ebp
  8015c1:	89 e5                	mov    %esp,%ebp
  8015c3:	53                   	push   %ebx
  8015c4:	83 ec 14             	sub    $0x14,%esp
  8015c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015ca:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015cd:	50                   	push   %eax
  8015ce:	53                   	push   %ebx
  8015cf:	e8 02 fc ff ff       	call   8011d6 <fd_lookup>
  8015d4:	83 c4 08             	add    $0x8,%esp
  8015d7:	85 c0                	test   %eax,%eax
  8015d9:	78 37                	js     801612 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015db:	83 ec 08             	sub    $0x8,%esp
  8015de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e1:	50                   	push   %eax
  8015e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e5:	ff 30                	pushl  (%eax)
  8015e7:	e8 40 fc ff ff       	call   80122c <dev_lookup>
  8015ec:	83 c4 10             	add    $0x10,%esp
  8015ef:	85 c0                	test   %eax,%eax
  8015f1:	78 1f                	js     801612 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015fa:	74 1b                	je     801617 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8015fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015ff:	8b 52 18             	mov    0x18(%edx),%edx
  801602:	85 d2                	test   %edx,%edx
  801604:	74 32                	je     801638 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801606:	83 ec 08             	sub    $0x8,%esp
  801609:	ff 75 0c             	pushl  0xc(%ebp)
  80160c:	50                   	push   %eax
  80160d:	ff d2                	call   *%edx
  80160f:	83 c4 10             	add    $0x10,%esp
}
  801612:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801615:	c9                   	leave  
  801616:	c3                   	ret    
			thisenv->env_id, fdnum);
  801617:	a1 20 44 80 00       	mov    0x804420,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80161c:	8b 40 48             	mov    0x48(%eax),%eax
  80161f:	83 ec 04             	sub    $0x4,%esp
  801622:	53                   	push   %ebx
  801623:	50                   	push   %eax
  801624:	68 cc 26 80 00       	push   $0x8026cc
  801629:	e8 d5 ed ff ff       	call   800403 <cprintf>
		return -E_INVAL;
  80162e:	83 c4 10             	add    $0x10,%esp
  801631:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801636:	eb da                	jmp    801612 <ftruncate+0x52>
		return -E_NOT_SUPP;
  801638:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80163d:	eb d3                	jmp    801612 <ftruncate+0x52>

0080163f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80163f:	55                   	push   %ebp
  801640:	89 e5                	mov    %esp,%ebp
  801642:	53                   	push   %ebx
  801643:	83 ec 14             	sub    $0x14,%esp
  801646:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801649:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80164c:	50                   	push   %eax
  80164d:	ff 75 08             	pushl  0x8(%ebp)
  801650:	e8 81 fb ff ff       	call   8011d6 <fd_lookup>
  801655:	83 c4 08             	add    $0x8,%esp
  801658:	85 c0                	test   %eax,%eax
  80165a:	78 4b                	js     8016a7 <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165c:	83 ec 08             	sub    $0x8,%esp
  80165f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801662:	50                   	push   %eax
  801663:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801666:	ff 30                	pushl  (%eax)
  801668:	e8 bf fb ff ff       	call   80122c <dev_lookup>
  80166d:	83 c4 10             	add    $0x10,%esp
  801670:	85 c0                	test   %eax,%eax
  801672:	78 33                	js     8016a7 <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  801674:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801677:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80167b:	74 2f                	je     8016ac <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80167d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801680:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801687:	00 00 00 
	stat->st_isdir = 0;
  80168a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801691:	00 00 00 
	stat->st_dev = dev;
  801694:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80169a:	83 ec 08             	sub    $0x8,%esp
  80169d:	53                   	push   %ebx
  80169e:	ff 75 f0             	pushl  -0x10(%ebp)
  8016a1:	ff 50 14             	call   *0x14(%eax)
  8016a4:	83 c4 10             	add    $0x10,%esp
}
  8016a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016aa:	c9                   	leave  
  8016ab:	c3                   	ret    
		return -E_NOT_SUPP;
  8016ac:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016b1:	eb f4                	jmp    8016a7 <fstat+0x68>

008016b3 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016b3:	55                   	push   %ebp
  8016b4:	89 e5                	mov    %esp,%ebp
  8016b6:	56                   	push   %esi
  8016b7:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016b8:	83 ec 08             	sub    $0x8,%esp
  8016bb:	6a 00                	push   $0x0
  8016bd:	ff 75 08             	pushl  0x8(%ebp)
  8016c0:	e8 e7 01 00 00       	call   8018ac <open>
  8016c5:	89 c3                	mov    %eax,%ebx
  8016c7:	83 c4 10             	add    $0x10,%esp
  8016ca:	85 c0                	test   %eax,%eax
  8016cc:	78 1b                	js     8016e9 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016ce:	83 ec 08             	sub    $0x8,%esp
  8016d1:	ff 75 0c             	pushl  0xc(%ebp)
  8016d4:	50                   	push   %eax
  8016d5:	e8 65 ff ff ff       	call   80163f <fstat>
  8016da:	89 c6                	mov    %eax,%esi
	close(fd);
  8016dc:	89 1c 24             	mov    %ebx,(%esp)
  8016df:	e8 27 fc ff ff       	call   80130b <close>
	return r;
  8016e4:	83 c4 10             	add    $0x10,%esp
  8016e7:	89 f3                	mov    %esi,%ebx
}
  8016e9:	89 d8                	mov    %ebx,%eax
  8016eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016ee:	5b                   	pop    %ebx
  8016ef:	5e                   	pop    %esi
  8016f0:	5d                   	pop    %ebp
  8016f1:	c3                   	ret    

008016f2 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016f2:	55                   	push   %ebp
  8016f3:	89 e5                	mov    %esp,%ebp
  8016f5:	56                   	push   %esi
  8016f6:	53                   	push   %ebx
  8016f7:	89 c6                	mov    %eax,%esi
  8016f9:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016fb:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801702:	74 27                	je     80172b <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801704:	6a 07                	push   $0x7
  801706:	68 00 50 80 00       	push   $0x805000
  80170b:	56                   	push   %esi
  80170c:	ff 35 00 40 80 00    	pushl  0x804000
  801712:	e8 8e 08 00 00       	call   801fa5 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801717:	83 c4 0c             	add    $0xc,%esp
  80171a:	6a 00                	push   $0x0
  80171c:	53                   	push   %ebx
  80171d:	6a 00                	push   $0x0
  80171f:	e8 0c 08 00 00       	call   801f30 <ipc_recv>
}
  801724:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801727:	5b                   	pop    %ebx
  801728:	5e                   	pop    %esi
  801729:	5d                   	pop    %ebp
  80172a:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80172b:	83 ec 0c             	sub    $0xc,%esp
  80172e:	6a 01                	push   $0x1
  801730:	e8 c6 08 00 00       	call   801ffb <ipc_find_env>
  801735:	a3 00 40 80 00       	mov    %eax,0x804000
  80173a:	83 c4 10             	add    $0x10,%esp
  80173d:	eb c5                	jmp    801704 <fsipc+0x12>

0080173f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80173f:	55                   	push   %ebp
  801740:	89 e5                	mov    %esp,%ebp
  801742:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801745:	8b 45 08             	mov    0x8(%ebp),%eax
  801748:	8b 40 0c             	mov    0xc(%eax),%eax
  80174b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801750:	8b 45 0c             	mov    0xc(%ebp),%eax
  801753:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801758:	ba 00 00 00 00       	mov    $0x0,%edx
  80175d:	b8 02 00 00 00       	mov    $0x2,%eax
  801762:	e8 8b ff ff ff       	call   8016f2 <fsipc>
}
  801767:	c9                   	leave  
  801768:	c3                   	ret    

00801769 <devfile_flush>:
{
  801769:	55                   	push   %ebp
  80176a:	89 e5                	mov    %esp,%ebp
  80176c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80176f:	8b 45 08             	mov    0x8(%ebp),%eax
  801772:	8b 40 0c             	mov    0xc(%eax),%eax
  801775:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80177a:	ba 00 00 00 00       	mov    $0x0,%edx
  80177f:	b8 06 00 00 00       	mov    $0x6,%eax
  801784:	e8 69 ff ff ff       	call   8016f2 <fsipc>
}
  801789:	c9                   	leave  
  80178a:	c3                   	ret    

0080178b <devfile_stat>:
{
  80178b:	55                   	push   %ebp
  80178c:	89 e5                	mov    %esp,%ebp
  80178e:	53                   	push   %ebx
  80178f:	83 ec 04             	sub    $0x4,%esp
  801792:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801795:	8b 45 08             	mov    0x8(%ebp),%eax
  801798:	8b 40 0c             	mov    0xc(%eax),%eax
  80179b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a5:	b8 05 00 00 00       	mov    $0x5,%eax
  8017aa:	e8 43 ff ff ff       	call   8016f2 <fsipc>
  8017af:	85 c0                	test   %eax,%eax
  8017b1:	78 2c                	js     8017df <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017b3:	83 ec 08             	sub    $0x8,%esp
  8017b6:	68 00 50 80 00       	push   $0x805000
  8017bb:	53                   	push   %ebx
  8017bc:	e8 61 f2 ff ff       	call   800a22 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017c1:	a1 80 50 80 00       	mov    0x805080,%eax
  8017c6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017cc:	a1 84 50 80 00       	mov    0x805084,%eax
  8017d1:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017d7:	83 c4 10             	add    $0x10,%esp
  8017da:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017e2:	c9                   	leave  
  8017e3:	c3                   	ret    

008017e4 <devfile_write>:
{
  8017e4:	55                   	push   %ebp
  8017e5:	89 e5                	mov    %esp,%ebp
  8017e7:	83 ec 0c             	sub    $0xc,%esp
  8017ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8017ed:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8017f2:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8017f7:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8017fd:	8b 52 0c             	mov    0xc(%edx),%edx
  801800:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801806:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf,buf,n);
  80180b:	50                   	push   %eax
  80180c:	ff 75 0c             	pushl  0xc(%ebp)
  80180f:	68 08 50 80 00       	push   $0x805008
  801814:	e8 97 f3 ff ff       	call   800bb0 <memmove>
	if((r = fsipc(FSREQ_WRITE,NULL))<0)
  801819:	ba 00 00 00 00       	mov    $0x0,%edx
  80181e:	b8 04 00 00 00       	mov    $0x4,%eax
  801823:	e8 ca fe ff ff       	call   8016f2 <fsipc>
}
  801828:	c9                   	leave  
  801829:	c3                   	ret    

0080182a <devfile_read>:
{
  80182a:	55                   	push   %ebp
  80182b:	89 e5                	mov    %esp,%ebp
  80182d:	56                   	push   %esi
  80182e:	53                   	push   %ebx
  80182f:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801832:	8b 45 08             	mov    0x8(%ebp),%eax
  801835:	8b 40 0c             	mov    0xc(%eax),%eax
  801838:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80183d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801843:	ba 00 00 00 00       	mov    $0x0,%edx
  801848:	b8 03 00 00 00       	mov    $0x3,%eax
  80184d:	e8 a0 fe ff ff       	call   8016f2 <fsipc>
  801852:	89 c3                	mov    %eax,%ebx
  801854:	85 c0                	test   %eax,%eax
  801856:	78 1f                	js     801877 <devfile_read+0x4d>
	assert(r <= n);
  801858:	39 f0                	cmp    %esi,%eax
  80185a:	77 24                	ja     801880 <devfile_read+0x56>
	assert(r <= PGSIZE);
  80185c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801861:	7f 33                	jg     801896 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801863:	83 ec 04             	sub    $0x4,%esp
  801866:	50                   	push   %eax
  801867:	68 00 50 80 00       	push   $0x805000
  80186c:	ff 75 0c             	pushl  0xc(%ebp)
  80186f:	e8 3c f3 ff ff       	call   800bb0 <memmove>
	return r;
  801874:	83 c4 10             	add    $0x10,%esp
}
  801877:	89 d8                	mov    %ebx,%eax
  801879:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80187c:	5b                   	pop    %ebx
  80187d:	5e                   	pop    %esi
  80187e:	5d                   	pop    %ebp
  80187f:	c3                   	ret    
	assert(r <= n);
  801880:	68 3c 27 80 00       	push   $0x80273c
  801885:	68 43 27 80 00       	push   $0x802743
  80188a:	6a 7c                	push   $0x7c
  80188c:	68 58 27 80 00       	push   $0x802758
  801891:	e8 92 ea ff ff       	call   800328 <_panic>
	assert(r <= PGSIZE);
  801896:	68 63 27 80 00       	push   $0x802763
  80189b:	68 43 27 80 00       	push   $0x802743
  8018a0:	6a 7d                	push   $0x7d
  8018a2:	68 58 27 80 00       	push   $0x802758
  8018a7:	e8 7c ea ff ff       	call   800328 <_panic>

008018ac <open>:
{
  8018ac:	55                   	push   %ebp
  8018ad:	89 e5                	mov    %esp,%ebp
  8018af:	56                   	push   %esi
  8018b0:	53                   	push   %ebx
  8018b1:	83 ec 1c             	sub    $0x1c,%esp
  8018b4:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8018b7:	56                   	push   %esi
  8018b8:	e8 2e f1 ff ff       	call   8009eb <strlen>
  8018bd:	83 c4 10             	add    $0x10,%esp
  8018c0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018c5:	7f 6c                	jg     801933 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8018c7:	83 ec 0c             	sub    $0xc,%esp
  8018ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018cd:	50                   	push   %eax
  8018ce:	e8 b4 f8 ff ff       	call   801187 <fd_alloc>
  8018d3:	89 c3                	mov    %eax,%ebx
  8018d5:	83 c4 10             	add    $0x10,%esp
  8018d8:	85 c0                	test   %eax,%eax
  8018da:	78 3c                	js     801918 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8018dc:	83 ec 08             	sub    $0x8,%esp
  8018df:	56                   	push   %esi
  8018e0:	68 00 50 80 00       	push   $0x805000
  8018e5:	e8 38 f1 ff ff       	call   800a22 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018ed:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018f5:	b8 01 00 00 00       	mov    $0x1,%eax
  8018fa:	e8 f3 fd ff ff       	call   8016f2 <fsipc>
  8018ff:	89 c3                	mov    %eax,%ebx
  801901:	83 c4 10             	add    $0x10,%esp
  801904:	85 c0                	test   %eax,%eax
  801906:	78 19                	js     801921 <open+0x75>
	return fd2num(fd);
  801908:	83 ec 0c             	sub    $0xc,%esp
  80190b:	ff 75 f4             	pushl  -0xc(%ebp)
  80190e:	e8 4d f8 ff ff       	call   801160 <fd2num>
  801913:	89 c3                	mov    %eax,%ebx
  801915:	83 c4 10             	add    $0x10,%esp
}
  801918:	89 d8                	mov    %ebx,%eax
  80191a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80191d:	5b                   	pop    %ebx
  80191e:	5e                   	pop    %esi
  80191f:	5d                   	pop    %ebp
  801920:	c3                   	ret    
		fd_close(fd, 0);
  801921:	83 ec 08             	sub    $0x8,%esp
  801924:	6a 00                	push   $0x0
  801926:	ff 75 f4             	pushl  -0xc(%ebp)
  801929:	e8 54 f9 ff ff       	call   801282 <fd_close>
		return r;
  80192e:	83 c4 10             	add    $0x10,%esp
  801931:	eb e5                	jmp    801918 <open+0x6c>
		return -E_BAD_PATH;
  801933:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801938:	eb de                	jmp    801918 <open+0x6c>

0080193a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80193a:	55                   	push   %ebp
  80193b:	89 e5                	mov    %esp,%ebp
  80193d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801940:	ba 00 00 00 00       	mov    $0x0,%edx
  801945:	b8 08 00 00 00       	mov    $0x8,%eax
  80194a:	e8 a3 fd ff ff       	call   8016f2 <fsipc>
}
  80194f:	c9                   	leave  
  801950:	c3                   	ret    

00801951 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801951:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801955:	7e 38                	jle    80198f <writebuf+0x3e>
{
  801957:	55                   	push   %ebp
  801958:	89 e5                	mov    %esp,%ebp
  80195a:	53                   	push   %ebx
  80195b:	83 ec 08             	sub    $0x8,%esp
  80195e:	89 c3                	mov    %eax,%ebx
		ssize_t result = write(b->fd, b->buf, b->idx);
  801960:	ff 70 04             	pushl  0x4(%eax)
  801963:	8d 40 10             	lea    0x10(%eax),%eax
  801966:	50                   	push   %eax
  801967:	ff 33                	pushl  (%ebx)
  801969:	e8 a7 fb ff ff       	call   801515 <write>
		if (result > 0)
  80196e:	83 c4 10             	add    $0x10,%esp
  801971:	85 c0                	test   %eax,%eax
  801973:	7e 03                	jle    801978 <writebuf+0x27>
			b->result += result;
  801975:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801978:	39 43 04             	cmp    %eax,0x4(%ebx)
  80197b:	74 0d                	je     80198a <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  80197d:	85 c0                	test   %eax,%eax
  80197f:	ba 00 00 00 00       	mov    $0x0,%edx
  801984:	0f 4f c2             	cmovg  %edx,%eax
  801987:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  80198a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80198d:	c9                   	leave  
  80198e:	c3                   	ret    
  80198f:	f3 c3                	repz ret 

00801991 <putch>:

static void
putch(int ch, void *thunk)
{
  801991:	55                   	push   %ebp
  801992:	89 e5                	mov    %esp,%ebp
  801994:	53                   	push   %ebx
  801995:	83 ec 04             	sub    $0x4,%esp
  801998:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  80199b:	8b 53 04             	mov    0x4(%ebx),%edx
  80199e:	8d 42 01             	lea    0x1(%edx),%eax
  8019a1:	89 43 04             	mov    %eax,0x4(%ebx)
  8019a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019a7:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8019ab:	3d 00 01 00 00       	cmp    $0x100,%eax
  8019b0:	74 06                	je     8019b8 <putch+0x27>
		writebuf(b);
		b->idx = 0;
	}
}
  8019b2:	83 c4 04             	add    $0x4,%esp
  8019b5:	5b                   	pop    %ebx
  8019b6:	5d                   	pop    %ebp
  8019b7:	c3                   	ret    
		writebuf(b);
  8019b8:	89 d8                	mov    %ebx,%eax
  8019ba:	e8 92 ff ff ff       	call   801951 <writebuf>
		b->idx = 0;
  8019bf:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
}
  8019c6:	eb ea                	jmp    8019b2 <putch+0x21>

008019c8 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8019c8:	55                   	push   %ebp
  8019c9:	89 e5                	mov    %esp,%ebp
  8019cb:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8019d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d4:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8019da:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8019e1:	00 00 00 
	b.result = 0;
  8019e4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8019eb:	00 00 00 
	b.error = 1;
  8019ee:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8019f5:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8019f8:	ff 75 10             	pushl  0x10(%ebp)
  8019fb:	ff 75 0c             	pushl  0xc(%ebp)
  8019fe:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801a04:	50                   	push   %eax
  801a05:	68 91 19 80 00       	push   $0x801991
  801a0a:	e8 f1 ea ff ff       	call   800500 <vprintfmt>
	if (b.idx > 0)
  801a0f:	83 c4 10             	add    $0x10,%esp
  801a12:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801a19:	7f 11                	jg     801a2c <vfprintf+0x64>
		writebuf(&b);

	return (b.result ? b.result : b.error);
  801a1b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801a21:	85 c0                	test   %eax,%eax
  801a23:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801a2a:	c9                   	leave  
  801a2b:	c3                   	ret    
		writebuf(&b);
  801a2c:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801a32:	e8 1a ff ff ff       	call   801951 <writebuf>
  801a37:	eb e2                	jmp    801a1b <vfprintf+0x53>

00801a39 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801a39:	55                   	push   %ebp
  801a3a:	89 e5                	mov    %esp,%ebp
  801a3c:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a3f:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801a42:	50                   	push   %eax
  801a43:	ff 75 0c             	pushl  0xc(%ebp)
  801a46:	ff 75 08             	pushl  0x8(%ebp)
  801a49:	e8 7a ff ff ff       	call   8019c8 <vfprintf>
	va_end(ap);

	return cnt;
}
  801a4e:	c9                   	leave  
  801a4f:	c3                   	ret    

00801a50 <printf>:

int
printf(const char *fmt, ...)
{
  801a50:	55                   	push   %ebp
  801a51:	89 e5                	mov    %esp,%ebp
  801a53:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a56:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801a59:	50                   	push   %eax
  801a5a:	ff 75 08             	pushl  0x8(%ebp)
  801a5d:	6a 01                	push   $0x1
  801a5f:	e8 64 ff ff ff       	call   8019c8 <vfprintf>
	va_end(ap);

	return cnt;
}
  801a64:	c9                   	leave  
  801a65:	c3                   	ret    

00801a66 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a66:	55                   	push   %ebp
  801a67:	89 e5                	mov    %esp,%ebp
  801a69:	56                   	push   %esi
  801a6a:	53                   	push   %ebx
  801a6b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a6e:	83 ec 0c             	sub    $0xc,%esp
  801a71:	ff 75 08             	pushl  0x8(%ebp)
  801a74:	e8 f7 f6 ff ff       	call   801170 <fd2data>
  801a79:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a7b:	83 c4 08             	add    $0x8,%esp
  801a7e:	68 6f 27 80 00       	push   $0x80276f
  801a83:	53                   	push   %ebx
  801a84:	e8 99 ef ff ff       	call   800a22 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a89:	8b 46 04             	mov    0x4(%esi),%eax
  801a8c:	2b 06                	sub    (%esi),%eax
  801a8e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a94:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a9b:	00 00 00 
	stat->st_dev = &devpipe;
  801a9e:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801aa5:	30 80 00 
	return 0;
}
  801aa8:	b8 00 00 00 00       	mov    $0x0,%eax
  801aad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ab0:	5b                   	pop    %ebx
  801ab1:	5e                   	pop    %esi
  801ab2:	5d                   	pop    %ebp
  801ab3:	c3                   	ret    

00801ab4 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ab4:	55                   	push   %ebp
  801ab5:	89 e5                	mov    %esp,%ebp
  801ab7:	53                   	push   %ebx
  801ab8:	83 ec 0c             	sub    $0xc,%esp
  801abb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801abe:	53                   	push   %ebx
  801abf:	6a 00                	push   $0x0
  801ac1:	e8 da f3 ff ff       	call   800ea0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ac6:	89 1c 24             	mov    %ebx,(%esp)
  801ac9:	e8 a2 f6 ff ff       	call   801170 <fd2data>
  801ace:	83 c4 08             	add    $0x8,%esp
  801ad1:	50                   	push   %eax
  801ad2:	6a 00                	push   $0x0
  801ad4:	e8 c7 f3 ff ff       	call   800ea0 <sys_page_unmap>
}
  801ad9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801adc:	c9                   	leave  
  801add:	c3                   	ret    

00801ade <_pipeisclosed>:
{
  801ade:	55                   	push   %ebp
  801adf:	89 e5                	mov    %esp,%ebp
  801ae1:	57                   	push   %edi
  801ae2:	56                   	push   %esi
  801ae3:	53                   	push   %ebx
  801ae4:	83 ec 1c             	sub    $0x1c,%esp
  801ae7:	89 c7                	mov    %eax,%edi
  801ae9:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801aeb:	a1 20 44 80 00       	mov    0x804420,%eax
  801af0:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801af3:	83 ec 0c             	sub    $0xc,%esp
  801af6:	57                   	push   %edi
  801af7:	e8 38 05 00 00       	call   802034 <pageref>
  801afc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801aff:	89 34 24             	mov    %esi,(%esp)
  801b02:	e8 2d 05 00 00       	call   802034 <pageref>
		nn = thisenv->env_runs;
  801b07:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801b0d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b10:	83 c4 10             	add    $0x10,%esp
  801b13:	39 cb                	cmp    %ecx,%ebx
  801b15:	74 1b                	je     801b32 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801b17:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b1a:	75 cf                	jne    801aeb <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b1c:	8b 42 58             	mov    0x58(%edx),%eax
  801b1f:	6a 01                	push   $0x1
  801b21:	50                   	push   %eax
  801b22:	53                   	push   %ebx
  801b23:	68 76 27 80 00       	push   $0x802776
  801b28:	e8 d6 e8 ff ff       	call   800403 <cprintf>
  801b2d:	83 c4 10             	add    $0x10,%esp
  801b30:	eb b9                	jmp    801aeb <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801b32:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b35:	0f 94 c0             	sete   %al
  801b38:	0f b6 c0             	movzbl %al,%eax
}
  801b3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b3e:	5b                   	pop    %ebx
  801b3f:	5e                   	pop    %esi
  801b40:	5f                   	pop    %edi
  801b41:	5d                   	pop    %ebp
  801b42:	c3                   	ret    

00801b43 <devpipe_write>:
{
  801b43:	55                   	push   %ebp
  801b44:	89 e5                	mov    %esp,%ebp
  801b46:	57                   	push   %edi
  801b47:	56                   	push   %esi
  801b48:	53                   	push   %ebx
  801b49:	83 ec 28             	sub    $0x28,%esp
  801b4c:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801b4f:	56                   	push   %esi
  801b50:	e8 1b f6 ff ff       	call   801170 <fd2data>
  801b55:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b57:	83 c4 10             	add    $0x10,%esp
  801b5a:	bf 00 00 00 00       	mov    $0x0,%edi
  801b5f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b62:	74 4f                	je     801bb3 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b64:	8b 43 04             	mov    0x4(%ebx),%eax
  801b67:	8b 0b                	mov    (%ebx),%ecx
  801b69:	8d 51 20             	lea    0x20(%ecx),%edx
  801b6c:	39 d0                	cmp    %edx,%eax
  801b6e:	72 14                	jb     801b84 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801b70:	89 da                	mov    %ebx,%edx
  801b72:	89 f0                	mov    %esi,%eax
  801b74:	e8 65 ff ff ff       	call   801ade <_pipeisclosed>
  801b79:	85 c0                	test   %eax,%eax
  801b7b:	75 3a                	jne    801bb7 <devpipe_write+0x74>
			sys_yield();
  801b7d:	e8 7a f2 ff ff       	call   800dfc <sys_yield>
  801b82:	eb e0                	jmp    801b64 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b87:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b8b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b8e:	89 c2                	mov    %eax,%edx
  801b90:	c1 fa 1f             	sar    $0x1f,%edx
  801b93:	89 d1                	mov    %edx,%ecx
  801b95:	c1 e9 1b             	shr    $0x1b,%ecx
  801b98:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b9b:	83 e2 1f             	and    $0x1f,%edx
  801b9e:	29 ca                	sub    %ecx,%edx
  801ba0:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ba4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ba8:	83 c0 01             	add    $0x1,%eax
  801bab:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801bae:	83 c7 01             	add    $0x1,%edi
  801bb1:	eb ac                	jmp    801b5f <devpipe_write+0x1c>
	return i;
  801bb3:	89 f8                	mov    %edi,%eax
  801bb5:	eb 05                	jmp    801bbc <devpipe_write+0x79>
				return 0;
  801bb7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bbf:	5b                   	pop    %ebx
  801bc0:	5e                   	pop    %esi
  801bc1:	5f                   	pop    %edi
  801bc2:	5d                   	pop    %ebp
  801bc3:	c3                   	ret    

00801bc4 <devpipe_read>:
{
  801bc4:	55                   	push   %ebp
  801bc5:	89 e5                	mov    %esp,%ebp
  801bc7:	57                   	push   %edi
  801bc8:	56                   	push   %esi
  801bc9:	53                   	push   %ebx
  801bca:	83 ec 18             	sub    $0x18,%esp
  801bcd:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801bd0:	57                   	push   %edi
  801bd1:	e8 9a f5 ff ff       	call   801170 <fd2data>
  801bd6:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801bd8:	83 c4 10             	add    $0x10,%esp
  801bdb:	be 00 00 00 00       	mov    $0x0,%esi
  801be0:	3b 75 10             	cmp    0x10(%ebp),%esi
  801be3:	74 47                	je     801c2c <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  801be5:	8b 03                	mov    (%ebx),%eax
  801be7:	3b 43 04             	cmp    0x4(%ebx),%eax
  801bea:	75 22                	jne    801c0e <devpipe_read+0x4a>
			if (i > 0)
  801bec:	85 f6                	test   %esi,%esi
  801bee:	75 14                	jne    801c04 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801bf0:	89 da                	mov    %ebx,%edx
  801bf2:	89 f8                	mov    %edi,%eax
  801bf4:	e8 e5 fe ff ff       	call   801ade <_pipeisclosed>
  801bf9:	85 c0                	test   %eax,%eax
  801bfb:	75 33                	jne    801c30 <devpipe_read+0x6c>
			sys_yield();
  801bfd:	e8 fa f1 ff ff       	call   800dfc <sys_yield>
  801c02:	eb e1                	jmp    801be5 <devpipe_read+0x21>
				return i;
  801c04:	89 f0                	mov    %esi,%eax
}
  801c06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c09:	5b                   	pop    %ebx
  801c0a:	5e                   	pop    %esi
  801c0b:	5f                   	pop    %edi
  801c0c:	5d                   	pop    %ebp
  801c0d:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c0e:	99                   	cltd   
  801c0f:	c1 ea 1b             	shr    $0x1b,%edx
  801c12:	01 d0                	add    %edx,%eax
  801c14:	83 e0 1f             	and    $0x1f,%eax
  801c17:	29 d0                	sub    %edx,%eax
  801c19:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801c1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c21:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801c24:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801c27:	83 c6 01             	add    $0x1,%esi
  801c2a:	eb b4                	jmp    801be0 <devpipe_read+0x1c>
	return i;
  801c2c:	89 f0                	mov    %esi,%eax
  801c2e:	eb d6                	jmp    801c06 <devpipe_read+0x42>
				return 0;
  801c30:	b8 00 00 00 00       	mov    $0x0,%eax
  801c35:	eb cf                	jmp    801c06 <devpipe_read+0x42>

00801c37 <pipe>:
{
  801c37:	55                   	push   %ebp
  801c38:	89 e5                	mov    %esp,%ebp
  801c3a:	56                   	push   %esi
  801c3b:	53                   	push   %ebx
  801c3c:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801c3f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c42:	50                   	push   %eax
  801c43:	e8 3f f5 ff ff       	call   801187 <fd_alloc>
  801c48:	89 c3                	mov    %eax,%ebx
  801c4a:	83 c4 10             	add    $0x10,%esp
  801c4d:	85 c0                	test   %eax,%eax
  801c4f:	78 5b                	js     801cac <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c51:	83 ec 04             	sub    $0x4,%esp
  801c54:	68 07 04 00 00       	push   $0x407
  801c59:	ff 75 f4             	pushl  -0xc(%ebp)
  801c5c:	6a 00                	push   $0x0
  801c5e:	e8 b8 f1 ff ff       	call   800e1b <sys_page_alloc>
  801c63:	89 c3                	mov    %eax,%ebx
  801c65:	83 c4 10             	add    $0x10,%esp
  801c68:	85 c0                	test   %eax,%eax
  801c6a:	78 40                	js     801cac <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  801c6c:	83 ec 0c             	sub    $0xc,%esp
  801c6f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c72:	50                   	push   %eax
  801c73:	e8 0f f5 ff ff       	call   801187 <fd_alloc>
  801c78:	89 c3                	mov    %eax,%ebx
  801c7a:	83 c4 10             	add    $0x10,%esp
  801c7d:	85 c0                	test   %eax,%eax
  801c7f:	78 1b                	js     801c9c <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c81:	83 ec 04             	sub    $0x4,%esp
  801c84:	68 07 04 00 00       	push   $0x407
  801c89:	ff 75 f0             	pushl  -0x10(%ebp)
  801c8c:	6a 00                	push   $0x0
  801c8e:	e8 88 f1 ff ff       	call   800e1b <sys_page_alloc>
  801c93:	89 c3                	mov    %eax,%ebx
  801c95:	83 c4 10             	add    $0x10,%esp
  801c98:	85 c0                	test   %eax,%eax
  801c9a:	79 19                	jns    801cb5 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  801c9c:	83 ec 08             	sub    $0x8,%esp
  801c9f:	ff 75 f4             	pushl  -0xc(%ebp)
  801ca2:	6a 00                	push   $0x0
  801ca4:	e8 f7 f1 ff ff       	call   800ea0 <sys_page_unmap>
  801ca9:	83 c4 10             	add    $0x10,%esp
}
  801cac:	89 d8                	mov    %ebx,%eax
  801cae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cb1:	5b                   	pop    %ebx
  801cb2:	5e                   	pop    %esi
  801cb3:	5d                   	pop    %ebp
  801cb4:	c3                   	ret    
	va = fd2data(fd0);
  801cb5:	83 ec 0c             	sub    $0xc,%esp
  801cb8:	ff 75 f4             	pushl  -0xc(%ebp)
  801cbb:	e8 b0 f4 ff ff       	call   801170 <fd2data>
  801cc0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cc2:	83 c4 0c             	add    $0xc,%esp
  801cc5:	68 07 04 00 00       	push   $0x407
  801cca:	50                   	push   %eax
  801ccb:	6a 00                	push   $0x0
  801ccd:	e8 49 f1 ff ff       	call   800e1b <sys_page_alloc>
  801cd2:	89 c3                	mov    %eax,%ebx
  801cd4:	83 c4 10             	add    $0x10,%esp
  801cd7:	85 c0                	test   %eax,%eax
  801cd9:	0f 88 8c 00 00 00    	js     801d6b <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cdf:	83 ec 0c             	sub    $0xc,%esp
  801ce2:	ff 75 f0             	pushl  -0x10(%ebp)
  801ce5:	e8 86 f4 ff ff       	call   801170 <fd2data>
  801cea:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cf1:	50                   	push   %eax
  801cf2:	6a 00                	push   $0x0
  801cf4:	56                   	push   %esi
  801cf5:	6a 00                	push   $0x0
  801cf7:	e8 62 f1 ff ff       	call   800e5e <sys_page_map>
  801cfc:	89 c3                	mov    %eax,%ebx
  801cfe:	83 c4 20             	add    $0x20,%esp
  801d01:	85 c0                	test   %eax,%eax
  801d03:	78 58                	js     801d5d <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801d05:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d08:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d0e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d10:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d13:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801d1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d1d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d23:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d25:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d28:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801d2f:	83 ec 0c             	sub    $0xc,%esp
  801d32:	ff 75 f4             	pushl  -0xc(%ebp)
  801d35:	e8 26 f4 ff ff       	call   801160 <fd2num>
  801d3a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d3d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d3f:	83 c4 04             	add    $0x4,%esp
  801d42:	ff 75 f0             	pushl  -0x10(%ebp)
  801d45:	e8 16 f4 ff ff       	call   801160 <fd2num>
  801d4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d4d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d50:	83 c4 10             	add    $0x10,%esp
  801d53:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d58:	e9 4f ff ff ff       	jmp    801cac <pipe+0x75>
	sys_page_unmap(0, va);
  801d5d:	83 ec 08             	sub    $0x8,%esp
  801d60:	56                   	push   %esi
  801d61:	6a 00                	push   $0x0
  801d63:	e8 38 f1 ff ff       	call   800ea0 <sys_page_unmap>
  801d68:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801d6b:	83 ec 08             	sub    $0x8,%esp
  801d6e:	ff 75 f0             	pushl  -0x10(%ebp)
  801d71:	6a 00                	push   $0x0
  801d73:	e8 28 f1 ff ff       	call   800ea0 <sys_page_unmap>
  801d78:	83 c4 10             	add    $0x10,%esp
  801d7b:	e9 1c ff ff ff       	jmp    801c9c <pipe+0x65>

00801d80 <pipeisclosed>:
{
  801d80:	55                   	push   %ebp
  801d81:	89 e5                	mov    %esp,%ebp
  801d83:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d86:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d89:	50                   	push   %eax
  801d8a:	ff 75 08             	pushl  0x8(%ebp)
  801d8d:	e8 44 f4 ff ff       	call   8011d6 <fd_lookup>
  801d92:	83 c4 10             	add    $0x10,%esp
  801d95:	85 c0                	test   %eax,%eax
  801d97:	78 18                	js     801db1 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801d99:	83 ec 0c             	sub    $0xc,%esp
  801d9c:	ff 75 f4             	pushl  -0xc(%ebp)
  801d9f:	e8 cc f3 ff ff       	call   801170 <fd2data>
	return _pipeisclosed(fd, p);
  801da4:	89 c2                	mov    %eax,%edx
  801da6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801da9:	e8 30 fd ff ff       	call   801ade <_pipeisclosed>
  801dae:	83 c4 10             	add    $0x10,%esp
}
  801db1:	c9                   	leave  
  801db2:	c3                   	ret    

00801db3 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801db3:	55                   	push   %ebp
  801db4:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801db6:	b8 00 00 00 00       	mov    $0x0,%eax
  801dbb:	5d                   	pop    %ebp
  801dbc:	c3                   	ret    

00801dbd <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801dbd:	55                   	push   %ebp
  801dbe:	89 e5                	mov    %esp,%ebp
  801dc0:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801dc3:	68 8e 27 80 00       	push   $0x80278e
  801dc8:	ff 75 0c             	pushl  0xc(%ebp)
  801dcb:	e8 52 ec ff ff       	call   800a22 <strcpy>
	return 0;
}
  801dd0:	b8 00 00 00 00       	mov    $0x0,%eax
  801dd5:	c9                   	leave  
  801dd6:	c3                   	ret    

00801dd7 <devcons_write>:
{
  801dd7:	55                   	push   %ebp
  801dd8:	89 e5                	mov    %esp,%ebp
  801dda:	57                   	push   %edi
  801ddb:	56                   	push   %esi
  801ddc:	53                   	push   %ebx
  801ddd:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801de3:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801de8:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801dee:	eb 2f                	jmp    801e1f <devcons_write+0x48>
		m = n - tot;
  801df0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801df3:	29 f3                	sub    %esi,%ebx
  801df5:	83 fb 7f             	cmp    $0x7f,%ebx
  801df8:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801dfd:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801e00:	83 ec 04             	sub    $0x4,%esp
  801e03:	53                   	push   %ebx
  801e04:	89 f0                	mov    %esi,%eax
  801e06:	03 45 0c             	add    0xc(%ebp),%eax
  801e09:	50                   	push   %eax
  801e0a:	57                   	push   %edi
  801e0b:	e8 a0 ed ff ff       	call   800bb0 <memmove>
		sys_cputs(buf, m);
  801e10:	83 c4 08             	add    $0x8,%esp
  801e13:	53                   	push   %ebx
  801e14:	57                   	push   %edi
  801e15:	e8 45 ef ff ff       	call   800d5f <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801e1a:	01 de                	add    %ebx,%esi
  801e1c:	83 c4 10             	add    $0x10,%esp
  801e1f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e22:	72 cc                	jb     801df0 <devcons_write+0x19>
}
  801e24:	89 f0                	mov    %esi,%eax
  801e26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e29:	5b                   	pop    %ebx
  801e2a:	5e                   	pop    %esi
  801e2b:	5f                   	pop    %edi
  801e2c:	5d                   	pop    %ebp
  801e2d:	c3                   	ret    

00801e2e <devcons_read>:
{
  801e2e:	55                   	push   %ebp
  801e2f:	89 e5                	mov    %esp,%ebp
  801e31:	83 ec 08             	sub    $0x8,%esp
  801e34:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801e39:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e3d:	75 07                	jne    801e46 <devcons_read+0x18>
}
  801e3f:	c9                   	leave  
  801e40:	c3                   	ret    
		sys_yield();
  801e41:	e8 b6 ef ff ff       	call   800dfc <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801e46:	e8 32 ef ff ff       	call   800d7d <sys_cgetc>
  801e4b:	85 c0                	test   %eax,%eax
  801e4d:	74 f2                	je     801e41 <devcons_read+0x13>
	if (c < 0)
  801e4f:	85 c0                	test   %eax,%eax
  801e51:	78 ec                	js     801e3f <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  801e53:	83 f8 04             	cmp    $0x4,%eax
  801e56:	74 0c                	je     801e64 <devcons_read+0x36>
	*(char*)vbuf = c;
  801e58:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e5b:	88 02                	mov    %al,(%edx)
	return 1;
  801e5d:	b8 01 00 00 00       	mov    $0x1,%eax
  801e62:	eb db                	jmp    801e3f <devcons_read+0x11>
		return 0;
  801e64:	b8 00 00 00 00       	mov    $0x0,%eax
  801e69:	eb d4                	jmp    801e3f <devcons_read+0x11>

00801e6b <cputchar>:
{
  801e6b:	55                   	push   %ebp
  801e6c:	89 e5                	mov    %esp,%ebp
  801e6e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e71:	8b 45 08             	mov    0x8(%ebp),%eax
  801e74:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801e77:	6a 01                	push   $0x1
  801e79:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e7c:	50                   	push   %eax
  801e7d:	e8 dd ee ff ff       	call   800d5f <sys_cputs>
}
  801e82:	83 c4 10             	add    $0x10,%esp
  801e85:	c9                   	leave  
  801e86:	c3                   	ret    

00801e87 <getchar>:
{
  801e87:	55                   	push   %ebp
  801e88:	89 e5                	mov    %esp,%ebp
  801e8a:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801e8d:	6a 01                	push   $0x1
  801e8f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e92:	50                   	push   %eax
  801e93:	6a 00                	push   $0x0
  801e95:	e8 ad f5 ff ff       	call   801447 <read>
	if (r < 0)
  801e9a:	83 c4 10             	add    $0x10,%esp
  801e9d:	85 c0                	test   %eax,%eax
  801e9f:	78 08                	js     801ea9 <getchar+0x22>
	if (r < 1)
  801ea1:	85 c0                	test   %eax,%eax
  801ea3:	7e 06                	jle    801eab <getchar+0x24>
	return c;
  801ea5:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801ea9:	c9                   	leave  
  801eaa:	c3                   	ret    
		return -E_EOF;
  801eab:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801eb0:	eb f7                	jmp    801ea9 <getchar+0x22>

00801eb2 <iscons>:
{
  801eb2:	55                   	push   %ebp
  801eb3:	89 e5                	mov    %esp,%ebp
  801eb5:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801eb8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ebb:	50                   	push   %eax
  801ebc:	ff 75 08             	pushl  0x8(%ebp)
  801ebf:	e8 12 f3 ff ff       	call   8011d6 <fd_lookup>
  801ec4:	83 c4 10             	add    $0x10,%esp
  801ec7:	85 c0                	test   %eax,%eax
  801ec9:	78 11                	js     801edc <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801ecb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ece:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ed4:	39 10                	cmp    %edx,(%eax)
  801ed6:	0f 94 c0             	sete   %al
  801ed9:	0f b6 c0             	movzbl %al,%eax
}
  801edc:	c9                   	leave  
  801edd:	c3                   	ret    

00801ede <opencons>:
{
  801ede:	55                   	push   %ebp
  801edf:	89 e5                	mov    %esp,%ebp
  801ee1:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801ee4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ee7:	50                   	push   %eax
  801ee8:	e8 9a f2 ff ff       	call   801187 <fd_alloc>
  801eed:	83 c4 10             	add    $0x10,%esp
  801ef0:	85 c0                	test   %eax,%eax
  801ef2:	78 3a                	js     801f2e <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ef4:	83 ec 04             	sub    $0x4,%esp
  801ef7:	68 07 04 00 00       	push   $0x407
  801efc:	ff 75 f4             	pushl  -0xc(%ebp)
  801eff:	6a 00                	push   $0x0
  801f01:	e8 15 ef ff ff       	call   800e1b <sys_page_alloc>
  801f06:	83 c4 10             	add    $0x10,%esp
  801f09:	85 c0                	test   %eax,%eax
  801f0b:	78 21                	js     801f2e <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801f0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f10:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f16:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f1b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f22:	83 ec 0c             	sub    $0xc,%esp
  801f25:	50                   	push   %eax
  801f26:	e8 35 f2 ff ff       	call   801160 <fd2num>
  801f2b:	83 c4 10             	add    $0x10,%esp
}
  801f2e:	c9                   	leave  
  801f2f:	c3                   	ret    

00801f30 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f30:	55                   	push   %ebp
  801f31:	89 e5                	mov    %esp,%ebp
  801f33:	56                   	push   %esi
  801f34:	53                   	push   %ebx
  801f35:	8b 75 08             	mov    0x8(%ebp),%esi
  801f38:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f3b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        //	panic("ipc_recv not implemented");
        int r;
       	if(pg!=NULL){
  801f3e:	85 c0                	test   %eax,%eax
  801f40:	74 3b                	je     801f7d <ipc_recv+0x4d>
	  r = sys_ipc_recv(pg);
  801f42:	83 ec 0c             	sub    $0xc,%esp
  801f45:	50                   	push   %eax
  801f46:	e8 80 f0 ff ff       	call   800fcb <sys_ipc_recv>
  801f4b:	83 c4 10             	add    $0x10,%esp
	}else
	  r = sys_ipc_recv((void *)UTOP);
	if(r<0){
  801f4e:	85 c0                	test   %eax,%eax
  801f50:	78 3d                	js     801f8f <ipc_recv+0x5f>
	if(perm_store!=NULL){
		*perm_store = 0;
            }
        	return r;
           }else{
	     if(from_env_store!=NULL)
  801f52:	85 f6                	test   %esi,%esi
  801f54:	74 0a                	je     801f60 <ipc_recv+0x30>
		     *from_env_store = thisenv->env_ipc_from;
  801f56:	a1 20 44 80 00       	mov    0x804420,%eax
  801f5b:	8b 40 74             	mov    0x74(%eax),%eax
  801f5e:	89 06                	mov    %eax,(%esi)
	     if(perm_store != NULL)
  801f60:	85 db                	test   %ebx,%ebx
  801f62:	74 0a                	je     801f6e <ipc_recv+0x3e>
		     *perm_store = thisenv->env_ipc_perm;
  801f64:	a1 20 44 80 00       	mov    0x804420,%eax
  801f69:	8b 40 78             	mov    0x78(%eax),%eax
  801f6c:	89 03                	mov    %eax,(%ebx)
	     return thisenv->env_ipc_value;
  801f6e:	a1 20 44 80 00       	mov    0x804420,%eax
  801f73:	8b 40 70             	mov    0x70(%eax),%eax
	   }

}
  801f76:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f79:	5b                   	pop    %ebx
  801f7a:	5e                   	pop    %esi
  801f7b:	5d                   	pop    %ebp
  801f7c:	c3                   	ret    
	  r = sys_ipc_recv((void *)UTOP);
  801f7d:	83 ec 0c             	sub    $0xc,%esp
  801f80:	68 00 00 c0 ee       	push   $0xeec00000
  801f85:	e8 41 f0 ff ff       	call   800fcb <sys_ipc_recv>
  801f8a:	83 c4 10             	add    $0x10,%esp
  801f8d:	eb bf                	jmp    801f4e <ipc_recv+0x1e>
	if(from_env_store!=NULL){
  801f8f:	85 f6                	test   %esi,%esi
  801f91:	74 06                	je     801f99 <ipc_recv+0x69>
	  *from_env_store = 0;
  801f93:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if(perm_store!=NULL){
  801f99:	85 db                	test   %ebx,%ebx
  801f9b:	74 d9                	je     801f76 <ipc_recv+0x46>
		*perm_store = 0;
  801f9d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801fa3:	eb d1                	jmp    801f76 <ipc_recv+0x46>

00801fa5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fa5:	55                   	push   %ebp
  801fa6:	89 e5                	mov    %esp,%ebp
  801fa8:	57                   	push   %edi
  801fa9:	56                   	push   %esi
  801faa:	53                   	push   %ebx
  801fab:	83 ec 0c             	sub    $0xc,%esp
  801fae:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fb1:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fb4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if(pg==NULL) pg = (void *)UTOP;
  801fb7:	85 db                	test   %ebx,%ebx
  801fb9:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801fbe:	0f 44 d8             	cmove  %eax,%ebx
	while((r=sys_ipc_try_send(to_env,val,pg,perm))<0){
  801fc1:	ff 75 14             	pushl  0x14(%ebp)
  801fc4:	53                   	push   %ebx
  801fc5:	56                   	push   %esi
  801fc6:	57                   	push   %edi
  801fc7:	e8 dc ef ff ff       	call   800fa8 <sys_ipc_try_send>
  801fcc:	83 c4 10             	add    $0x10,%esp
  801fcf:	85 c0                	test   %eax,%eax
  801fd1:	79 20                	jns    801ff3 <ipc_send+0x4e>
	    if(r!=-E_IPC_NOT_RECV){
  801fd3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fd6:	75 07                	jne    801fdf <ipc_send+0x3a>
		    panic("ipc_send:send message failed\n");
	    }
	    sys_yield();
  801fd8:	e8 1f ee ff ff       	call   800dfc <sys_yield>
  801fdd:	eb e2                	jmp    801fc1 <ipc_send+0x1c>
		    panic("ipc_send:send message failed\n");
  801fdf:	83 ec 04             	sub    $0x4,%esp
  801fe2:	68 9a 27 80 00       	push   $0x80279a
  801fe7:	6a 43                	push   $0x43
  801fe9:	68 b8 27 80 00       	push   $0x8027b8
  801fee:	e8 35 e3 ff ff       	call   800328 <_panic>
	}

}
  801ff3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ff6:	5b                   	pop    %ebx
  801ff7:	5e                   	pop    %esi
  801ff8:	5f                   	pop    %edi
  801ff9:	5d                   	pop    %ebp
  801ffa:	c3                   	ret    

00801ffb <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ffb:	55                   	push   %ebp
  801ffc:	89 e5                	mov    %esp,%ebp
  801ffe:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802001:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802006:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802009:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80200f:	8b 52 50             	mov    0x50(%edx),%edx
  802012:	39 ca                	cmp    %ecx,%edx
  802014:	74 11                	je     802027 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  802016:	83 c0 01             	add    $0x1,%eax
  802019:	3d 00 04 00 00       	cmp    $0x400,%eax
  80201e:	75 e6                	jne    802006 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  802020:	b8 00 00 00 00       	mov    $0x0,%eax
  802025:	eb 0b                	jmp    802032 <ipc_find_env+0x37>
			return envs[i].env_id;
  802027:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80202a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80202f:	8b 40 48             	mov    0x48(%eax),%eax
}
  802032:	5d                   	pop    %ebp
  802033:	c3                   	ret    

00802034 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802034:	55                   	push   %ebp
  802035:	89 e5                	mov    %esp,%ebp
  802037:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80203a:	89 d0                	mov    %edx,%eax
  80203c:	c1 e8 16             	shr    $0x16,%eax
  80203f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802046:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  80204b:	f6 c1 01             	test   $0x1,%cl
  80204e:	74 1d                	je     80206d <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  802050:	c1 ea 0c             	shr    $0xc,%edx
  802053:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80205a:	f6 c2 01             	test   $0x1,%dl
  80205d:	74 0e                	je     80206d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80205f:	c1 ea 0c             	shr    $0xc,%edx
  802062:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802069:	ef 
  80206a:	0f b7 c0             	movzwl %ax,%eax
}
  80206d:	5d                   	pop    %ebp
  80206e:	c3                   	ret    
  80206f:	90                   	nop

00802070 <__udivdi3>:
  802070:	55                   	push   %ebp
  802071:	57                   	push   %edi
  802072:	56                   	push   %esi
  802073:	53                   	push   %ebx
  802074:	83 ec 1c             	sub    $0x1c,%esp
  802077:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80207b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  80207f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802083:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  802087:	85 d2                	test   %edx,%edx
  802089:	75 35                	jne    8020c0 <__udivdi3+0x50>
  80208b:	39 f3                	cmp    %esi,%ebx
  80208d:	0f 87 bd 00 00 00    	ja     802150 <__udivdi3+0xe0>
  802093:	85 db                	test   %ebx,%ebx
  802095:	89 d9                	mov    %ebx,%ecx
  802097:	75 0b                	jne    8020a4 <__udivdi3+0x34>
  802099:	b8 01 00 00 00       	mov    $0x1,%eax
  80209e:	31 d2                	xor    %edx,%edx
  8020a0:	f7 f3                	div    %ebx
  8020a2:	89 c1                	mov    %eax,%ecx
  8020a4:	31 d2                	xor    %edx,%edx
  8020a6:	89 f0                	mov    %esi,%eax
  8020a8:	f7 f1                	div    %ecx
  8020aa:	89 c6                	mov    %eax,%esi
  8020ac:	89 e8                	mov    %ebp,%eax
  8020ae:	89 f7                	mov    %esi,%edi
  8020b0:	f7 f1                	div    %ecx
  8020b2:	89 fa                	mov    %edi,%edx
  8020b4:	83 c4 1c             	add    $0x1c,%esp
  8020b7:	5b                   	pop    %ebx
  8020b8:	5e                   	pop    %esi
  8020b9:	5f                   	pop    %edi
  8020ba:	5d                   	pop    %ebp
  8020bb:	c3                   	ret    
  8020bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020c0:	39 f2                	cmp    %esi,%edx
  8020c2:	77 7c                	ja     802140 <__udivdi3+0xd0>
  8020c4:	0f bd fa             	bsr    %edx,%edi
  8020c7:	83 f7 1f             	xor    $0x1f,%edi
  8020ca:	0f 84 98 00 00 00    	je     802168 <__udivdi3+0xf8>
  8020d0:	89 f9                	mov    %edi,%ecx
  8020d2:	b8 20 00 00 00       	mov    $0x20,%eax
  8020d7:	29 f8                	sub    %edi,%eax
  8020d9:	d3 e2                	shl    %cl,%edx
  8020db:	89 54 24 08          	mov    %edx,0x8(%esp)
  8020df:	89 c1                	mov    %eax,%ecx
  8020e1:	89 da                	mov    %ebx,%edx
  8020e3:	d3 ea                	shr    %cl,%edx
  8020e5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8020e9:	09 d1                	or     %edx,%ecx
  8020eb:	89 f2                	mov    %esi,%edx
  8020ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020f1:	89 f9                	mov    %edi,%ecx
  8020f3:	d3 e3                	shl    %cl,%ebx
  8020f5:	89 c1                	mov    %eax,%ecx
  8020f7:	d3 ea                	shr    %cl,%edx
  8020f9:	89 f9                	mov    %edi,%ecx
  8020fb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8020ff:	d3 e6                	shl    %cl,%esi
  802101:	89 eb                	mov    %ebp,%ebx
  802103:	89 c1                	mov    %eax,%ecx
  802105:	d3 eb                	shr    %cl,%ebx
  802107:	09 de                	or     %ebx,%esi
  802109:	89 f0                	mov    %esi,%eax
  80210b:	f7 74 24 08          	divl   0x8(%esp)
  80210f:	89 d6                	mov    %edx,%esi
  802111:	89 c3                	mov    %eax,%ebx
  802113:	f7 64 24 0c          	mull   0xc(%esp)
  802117:	39 d6                	cmp    %edx,%esi
  802119:	72 0c                	jb     802127 <__udivdi3+0xb7>
  80211b:	89 f9                	mov    %edi,%ecx
  80211d:	d3 e5                	shl    %cl,%ebp
  80211f:	39 c5                	cmp    %eax,%ebp
  802121:	73 5d                	jae    802180 <__udivdi3+0x110>
  802123:	39 d6                	cmp    %edx,%esi
  802125:	75 59                	jne    802180 <__udivdi3+0x110>
  802127:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80212a:	31 ff                	xor    %edi,%edi
  80212c:	89 fa                	mov    %edi,%edx
  80212e:	83 c4 1c             	add    $0x1c,%esp
  802131:	5b                   	pop    %ebx
  802132:	5e                   	pop    %esi
  802133:	5f                   	pop    %edi
  802134:	5d                   	pop    %ebp
  802135:	c3                   	ret    
  802136:	8d 76 00             	lea    0x0(%esi),%esi
  802139:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802140:	31 ff                	xor    %edi,%edi
  802142:	31 c0                	xor    %eax,%eax
  802144:	89 fa                	mov    %edi,%edx
  802146:	83 c4 1c             	add    $0x1c,%esp
  802149:	5b                   	pop    %ebx
  80214a:	5e                   	pop    %esi
  80214b:	5f                   	pop    %edi
  80214c:	5d                   	pop    %ebp
  80214d:	c3                   	ret    
  80214e:	66 90                	xchg   %ax,%ax
  802150:	31 ff                	xor    %edi,%edi
  802152:	89 e8                	mov    %ebp,%eax
  802154:	89 f2                	mov    %esi,%edx
  802156:	f7 f3                	div    %ebx
  802158:	89 fa                	mov    %edi,%edx
  80215a:	83 c4 1c             	add    $0x1c,%esp
  80215d:	5b                   	pop    %ebx
  80215e:	5e                   	pop    %esi
  80215f:	5f                   	pop    %edi
  802160:	5d                   	pop    %ebp
  802161:	c3                   	ret    
  802162:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802168:	39 f2                	cmp    %esi,%edx
  80216a:	72 06                	jb     802172 <__udivdi3+0x102>
  80216c:	31 c0                	xor    %eax,%eax
  80216e:	39 eb                	cmp    %ebp,%ebx
  802170:	77 d2                	ja     802144 <__udivdi3+0xd4>
  802172:	b8 01 00 00 00       	mov    $0x1,%eax
  802177:	eb cb                	jmp    802144 <__udivdi3+0xd4>
  802179:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802180:	89 d8                	mov    %ebx,%eax
  802182:	31 ff                	xor    %edi,%edi
  802184:	eb be                	jmp    802144 <__udivdi3+0xd4>
  802186:	66 90                	xchg   %ax,%ax
  802188:	66 90                	xchg   %ax,%ax
  80218a:	66 90                	xchg   %ax,%ax
  80218c:	66 90                	xchg   %ax,%ax
  80218e:	66 90                	xchg   %ax,%ax

00802190 <__umoddi3>:
  802190:	55                   	push   %ebp
  802191:	57                   	push   %edi
  802192:	56                   	push   %esi
  802193:	53                   	push   %ebx
  802194:	83 ec 1c             	sub    $0x1c,%esp
  802197:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80219b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80219f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8021a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021a7:	85 ed                	test   %ebp,%ebp
  8021a9:	89 f0                	mov    %esi,%eax
  8021ab:	89 da                	mov    %ebx,%edx
  8021ad:	75 19                	jne    8021c8 <__umoddi3+0x38>
  8021af:	39 df                	cmp    %ebx,%edi
  8021b1:	0f 86 b1 00 00 00    	jbe    802268 <__umoddi3+0xd8>
  8021b7:	f7 f7                	div    %edi
  8021b9:	89 d0                	mov    %edx,%eax
  8021bb:	31 d2                	xor    %edx,%edx
  8021bd:	83 c4 1c             	add    $0x1c,%esp
  8021c0:	5b                   	pop    %ebx
  8021c1:	5e                   	pop    %esi
  8021c2:	5f                   	pop    %edi
  8021c3:	5d                   	pop    %ebp
  8021c4:	c3                   	ret    
  8021c5:	8d 76 00             	lea    0x0(%esi),%esi
  8021c8:	39 dd                	cmp    %ebx,%ebp
  8021ca:	77 f1                	ja     8021bd <__umoddi3+0x2d>
  8021cc:	0f bd cd             	bsr    %ebp,%ecx
  8021cf:	83 f1 1f             	xor    $0x1f,%ecx
  8021d2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8021d6:	0f 84 b4 00 00 00    	je     802290 <__umoddi3+0x100>
  8021dc:	b8 20 00 00 00       	mov    $0x20,%eax
  8021e1:	89 c2                	mov    %eax,%edx
  8021e3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8021e7:	29 c2                	sub    %eax,%edx
  8021e9:	89 c1                	mov    %eax,%ecx
  8021eb:	89 f8                	mov    %edi,%eax
  8021ed:	d3 e5                	shl    %cl,%ebp
  8021ef:	89 d1                	mov    %edx,%ecx
  8021f1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8021f5:	d3 e8                	shr    %cl,%eax
  8021f7:	09 c5                	or     %eax,%ebp
  8021f9:	8b 44 24 04          	mov    0x4(%esp),%eax
  8021fd:	89 c1                	mov    %eax,%ecx
  8021ff:	d3 e7                	shl    %cl,%edi
  802201:	89 d1                	mov    %edx,%ecx
  802203:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802207:	89 df                	mov    %ebx,%edi
  802209:	d3 ef                	shr    %cl,%edi
  80220b:	89 c1                	mov    %eax,%ecx
  80220d:	89 f0                	mov    %esi,%eax
  80220f:	d3 e3                	shl    %cl,%ebx
  802211:	89 d1                	mov    %edx,%ecx
  802213:	89 fa                	mov    %edi,%edx
  802215:	d3 e8                	shr    %cl,%eax
  802217:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80221c:	09 d8                	or     %ebx,%eax
  80221e:	f7 f5                	div    %ebp
  802220:	d3 e6                	shl    %cl,%esi
  802222:	89 d1                	mov    %edx,%ecx
  802224:	f7 64 24 08          	mull   0x8(%esp)
  802228:	39 d1                	cmp    %edx,%ecx
  80222a:	89 c3                	mov    %eax,%ebx
  80222c:	89 d7                	mov    %edx,%edi
  80222e:	72 06                	jb     802236 <__umoddi3+0xa6>
  802230:	75 0e                	jne    802240 <__umoddi3+0xb0>
  802232:	39 c6                	cmp    %eax,%esi
  802234:	73 0a                	jae    802240 <__umoddi3+0xb0>
  802236:	2b 44 24 08          	sub    0x8(%esp),%eax
  80223a:	19 ea                	sbb    %ebp,%edx
  80223c:	89 d7                	mov    %edx,%edi
  80223e:	89 c3                	mov    %eax,%ebx
  802240:	89 ca                	mov    %ecx,%edx
  802242:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  802247:	29 de                	sub    %ebx,%esi
  802249:	19 fa                	sbb    %edi,%edx
  80224b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80224f:	89 d0                	mov    %edx,%eax
  802251:	d3 e0                	shl    %cl,%eax
  802253:	89 d9                	mov    %ebx,%ecx
  802255:	d3 ee                	shr    %cl,%esi
  802257:	d3 ea                	shr    %cl,%edx
  802259:	09 f0                	or     %esi,%eax
  80225b:	83 c4 1c             	add    $0x1c,%esp
  80225e:	5b                   	pop    %ebx
  80225f:	5e                   	pop    %esi
  802260:	5f                   	pop    %edi
  802261:	5d                   	pop    %ebp
  802262:	c3                   	ret    
  802263:	90                   	nop
  802264:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802268:	85 ff                	test   %edi,%edi
  80226a:	89 f9                	mov    %edi,%ecx
  80226c:	75 0b                	jne    802279 <__umoddi3+0xe9>
  80226e:	b8 01 00 00 00       	mov    $0x1,%eax
  802273:	31 d2                	xor    %edx,%edx
  802275:	f7 f7                	div    %edi
  802277:	89 c1                	mov    %eax,%ecx
  802279:	89 d8                	mov    %ebx,%eax
  80227b:	31 d2                	xor    %edx,%edx
  80227d:	f7 f1                	div    %ecx
  80227f:	89 f0                	mov    %esi,%eax
  802281:	f7 f1                	div    %ecx
  802283:	e9 31 ff ff ff       	jmp    8021b9 <__umoddi3+0x29>
  802288:	90                   	nop
  802289:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802290:	39 dd                	cmp    %ebx,%ebp
  802292:	72 08                	jb     80229c <__umoddi3+0x10c>
  802294:	39 f7                	cmp    %esi,%edi
  802296:	0f 87 21 ff ff ff    	ja     8021bd <__umoddi3+0x2d>
  80229c:	89 da                	mov    %ebx,%edx
  80229e:	89 f0                	mov    %esi,%eax
  8022a0:	29 f8                	sub    %edi,%eax
  8022a2:	19 ea                	sbb    %ebp,%edx
  8022a4:	e9 14 ff ff ff       	jmp    8021bd <__umoddi3+0x2d>
