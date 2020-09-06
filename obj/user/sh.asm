
obj/user/sh.debug:     file format elf32-i386


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
  80002c:	e8 e6 09 00 00       	call   800a17 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <_gettoken>:
#define WHITESPACE " \t\r\n"
#define SYMBOLS "<|>&;()"

int
_gettoken(char *s, char **p1, char **p2)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int t;

	if (s == 0) {
  80003b:	85 db                	test   %ebx,%ebx
  80003d:	74 1d                	je     80005c <_gettoken+0x29>
		if (debug > 1)
			cprintf("GETTOKEN NULL\n");
		return 0;
	}

	if (debug > 1)
  80003f:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800046:	7f 34                	jg     80007c <_gettoken+0x49>
		cprintf("GETTOKEN: %s\n", s);

	*p1 = 0;
  800048:	8b 45 0c             	mov    0xc(%ebp),%eax
  80004b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*p2 = 0;
  800051:	8b 45 10             	mov    0x10(%ebp),%eax
  800054:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	while (strchr(WHITESPACE, *s))
  80005a:	eb 3a                	jmp    800096 <_gettoken+0x63>
		return 0;
  80005c:	be 00 00 00 00       	mov    $0x0,%esi
		if (debug > 1)
  800061:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800068:	7e 59                	jle    8000c3 <_gettoken+0x90>
			cprintf("GETTOKEN NULL\n");
  80006a:	83 ec 0c             	sub    $0xc,%esp
  80006d:	68 60 33 80 00       	push   $0x803360
  800072:	e8 db 0a 00 00       	call   800b52 <cprintf>
  800077:	83 c4 10             	add    $0x10,%esp
  80007a:	eb 47                	jmp    8000c3 <_gettoken+0x90>
		cprintf("GETTOKEN: %s\n", s);
  80007c:	83 ec 08             	sub    $0x8,%esp
  80007f:	53                   	push   %ebx
  800080:	68 6f 33 80 00       	push   $0x80336f
  800085:	e8 c8 0a 00 00       	call   800b52 <cprintf>
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	eb b9                	jmp    800048 <_gettoken+0x15>
		*s++ = 0;
  80008f:	83 c3 01             	add    $0x1,%ebx
  800092:	c6 43 ff 00          	movb   $0x0,-0x1(%ebx)
	while (strchr(WHITESPACE, *s))
  800096:	83 ec 08             	sub    $0x8,%esp
  800099:	0f be 03             	movsbl (%ebx),%eax
  80009c:	50                   	push   %eax
  80009d:	68 7d 33 80 00       	push   $0x80337d
  8000a2:	e8 be 12 00 00       	call   801365 <strchr>
  8000a7:	83 c4 10             	add    $0x10,%esp
  8000aa:	85 c0                	test   %eax,%eax
  8000ac:	75 e1                	jne    80008f <_gettoken+0x5c>
	if (*s == 0) {
  8000ae:	0f b6 03             	movzbl (%ebx),%eax
  8000b1:	84 c0                	test   %al,%al
  8000b3:	75 29                	jne    8000de <_gettoken+0xab>
		if (debug > 1)
			cprintf("EOL\n");
		return 0;
  8000b5:	be 00 00 00 00       	mov    $0x0,%esi
		if (debug > 1)
  8000ba:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  8000c1:	7f 09                	jg     8000cc <_gettoken+0x99>
		**p2 = 0;
		cprintf("WORD: %s\n", *p1);
		**p2 = t;
	}
	return 'w';
}
  8000c3:	89 f0                	mov    %esi,%eax
  8000c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c8:	5b                   	pop    %ebx
  8000c9:	5e                   	pop    %esi
  8000ca:	5d                   	pop    %ebp
  8000cb:	c3                   	ret    
			cprintf("EOL\n");
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	68 82 33 80 00       	push   $0x803382
  8000d4:	e8 79 0a 00 00       	call   800b52 <cprintf>
  8000d9:	83 c4 10             	add    $0x10,%esp
  8000dc:	eb e5                	jmp    8000c3 <_gettoken+0x90>
	if (strchr(SYMBOLS, *s)) {
  8000de:	83 ec 08             	sub    $0x8,%esp
  8000e1:	0f be c0             	movsbl %al,%eax
  8000e4:	50                   	push   %eax
  8000e5:	68 93 33 80 00       	push   $0x803393
  8000ea:	e8 76 12 00 00       	call   801365 <strchr>
  8000ef:	83 c4 10             	add    $0x10,%esp
  8000f2:	85 c0                	test   %eax,%eax
  8000f4:	74 2f                	je     800125 <_gettoken+0xf2>
		t = *s;
  8000f6:	0f be 33             	movsbl (%ebx),%esi
		*p1 = s;
  8000f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000fc:	89 18                	mov    %ebx,(%eax)
		*s++ = 0;
  8000fe:	c6 03 00             	movb   $0x0,(%ebx)
  800101:	83 c3 01             	add    $0x1,%ebx
  800104:	8b 45 10             	mov    0x10(%ebp),%eax
  800107:	89 18                	mov    %ebx,(%eax)
		if (debug > 1)
  800109:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800110:	7e b1                	jle    8000c3 <_gettoken+0x90>
			cprintf("TOK %c\n", t);
  800112:	83 ec 08             	sub    $0x8,%esp
  800115:	56                   	push   %esi
  800116:	68 87 33 80 00       	push   $0x803387
  80011b:	e8 32 0a 00 00       	call   800b52 <cprintf>
  800120:	83 c4 10             	add    $0x10,%esp
  800123:	eb 9e                	jmp    8000c3 <_gettoken+0x90>
	*p1 = s;
  800125:	8b 45 0c             	mov    0xc(%ebp),%eax
  800128:	89 18                	mov    %ebx,(%eax)
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  80012a:	eb 03                	jmp    80012f <_gettoken+0xfc>
		s++;
  80012c:	83 c3 01             	add    $0x1,%ebx
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  80012f:	0f b6 03             	movzbl (%ebx),%eax
  800132:	84 c0                	test   %al,%al
  800134:	74 18                	je     80014e <_gettoken+0x11b>
  800136:	83 ec 08             	sub    $0x8,%esp
  800139:	0f be c0             	movsbl %al,%eax
  80013c:	50                   	push   %eax
  80013d:	68 8f 33 80 00       	push   $0x80338f
  800142:	e8 1e 12 00 00       	call   801365 <strchr>
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	85 c0                	test   %eax,%eax
  80014c:	74 de                	je     80012c <_gettoken+0xf9>
	*p2 = s;
  80014e:	8b 45 10             	mov    0x10(%ebp),%eax
  800151:	89 18                	mov    %ebx,(%eax)
	return 'w';
  800153:	be 77 00 00 00       	mov    $0x77,%esi
	if (debug > 1) {
  800158:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  80015f:	0f 8e 5e ff ff ff    	jle    8000c3 <_gettoken+0x90>
		t = **p2;
  800165:	0f b6 33             	movzbl (%ebx),%esi
		**p2 = 0;
  800168:	c6 03 00             	movb   $0x0,(%ebx)
		cprintf("WORD: %s\n", *p1);
  80016b:	83 ec 08             	sub    $0x8,%esp
  80016e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800171:	ff 30                	pushl  (%eax)
  800173:	68 9b 33 80 00       	push   $0x80339b
  800178:	e8 d5 09 00 00       	call   800b52 <cprintf>
		**p2 = t;
  80017d:	8b 45 10             	mov    0x10(%ebp),%eax
  800180:	8b 00                	mov    (%eax),%eax
  800182:	89 f2                	mov    %esi,%edx
  800184:	88 10                	mov    %dl,(%eax)
  800186:	83 c4 10             	add    $0x10,%esp
	return 'w';
  800189:	be 77 00 00 00       	mov    $0x77,%esi
  80018e:	e9 30 ff ff ff       	jmp    8000c3 <_gettoken+0x90>

00800193 <gettoken>:

int
gettoken(char *s, char **p1)
{
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	83 ec 08             	sub    $0x8,%esp
  800199:	8b 45 08             	mov    0x8(%ebp),%eax
	static int c, nc;
	static char* np1, *np2;

	if (s) {
  80019c:	85 c0                	test   %eax,%eax
  80019e:	74 22                	je     8001c2 <gettoken+0x2f>
		nc = _gettoken(s, &np1, &np2);
  8001a0:	83 ec 04             	sub    $0x4,%esp
  8001a3:	68 0c 50 80 00       	push   $0x80500c
  8001a8:	68 10 50 80 00       	push   $0x805010
  8001ad:	50                   	push   %eax
  8001ae:	e8 80 fe ff ff       	call   800033 <_gettoken>
  8001b3:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  8001b8:	83 c4 10             	add    $0x10,%esp
  8001bb:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	c = nc;
	*p1 = np1;
	nc = _gettoken(np2, &np1, &np2);
	return c;
}
  8001c0:	c9                   	leave  
  8001c1:	c3                   	ret    
	c = nc;
  8001c2:	a1 08 50 80 00       	mov    0x805008,%eax
  8001c7:	a3 04 50 80 00       	mov    %eax,0x805004
	*p1 = np1;
  8001cc:	8b 15 10 50 80 00    	mov    0x805010,%edx
  8001d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001d5:	89 10                	mov    %edx,(%eax)
	nc = _gettoken(np2, &np1, &np2);
  8001d7:	83 ec 04             	sub    $0x4,%esp
  8001da:	68 0c 50 80 00       	push   $0x80500c
  8001df:	68 10 50 80 00       	push   $0x805010
  8001e4:	ff 35 0c 50 80 00    	pushl  0x80500c
  8001ea:	e8 44 fe ff ff       	call   800033 <_gettoken>
  8001ef:	a3 08 50 80 00       	mov    %eax,0x805008
	return c;
  8001f4:	a1 04 50 80 00       	mov    0x805004,%eax
  8001f9:	83 c4 10             	add    $0x10,%esp
  8001fc:	eb c2                	jmp    8001c0 <gettoken+0x2d>

008001fe <runcmd>:
{
  8001fe:	55                   	push   %ebp
  8001ff:	89 e5                	mov    %esp,%ebp
  800201:	57                   	push   %edi
  800202:	56                   	push   %esi
  800203:	53                   	push   %ebx
  800204:	81 ec 64 04 00 00    	sub    $0x464,%esp
	gettoken(s, 0);
  80020a:	6a 00                	push   $0x0
  80020c:	ff 75 08             	pushl  0x8(%ebp)
  80020f:	e8 7f ff ff ff       	call   800193 <gettoken>
  800214:	83 c4 10             	add    $0x10,%esp
		switch ((c = gettoken(0, &t))) {
  800217:	8d 75 a4             	lea    -0x5c(%ebp),%esi
	argc = 0;
  80021a:	bf 00 00 00 00       	mov    $0x0,%edi
		switch ((c = gettoken(0, &t))) {
  80021f:	83 ec 08             	sub    $0x8,%esp
  800222:	56                   	push   %esi
  800223:	6a 00                	push   $0x0
  800225:	e8 69 ff ff ff       	call   800193 <gettoken>
  80022a:	89 c3                	mov    %eax,%ebx
  80022c:	83 c4 10             	add    $0x10,%esp
  80022f:	83 f8 3e             	cmp    $0x3e,%eax
  800232:	0f 84 35 01 00 00    	je     80036d <runcmd+0x16f>
  800238:	83 f8 3e             	cmp    $0x3e,%eax
  80023b:	7f 4b                	jg     800288 <runcmd+0x8a>
  80023d:	85 c0                	test   %eax,%eax
  80023f:	0f 84 18 02 00 00    	je     80045d <runcmd+0x25f>
  800245:	83 f8 3c             	cmp    $0x3c,%eax
  800248:	0f 85 74 02 00 00    	jne    8004c2 <runcmd+0x2c4>
			if (gettoken(0, &t) != 'w') {
  80024e:	83 ec 08             	sub    $0x8,%esp
  800251:	56                   	push   %esi
  800252:	6a 00                	push   $0x0
  800254:	e8 3a ff ff ff       	call   800193 <gettoken>
  800259:	83 c4 10             	add    $0x10,%esp
  80025c:	83 f8 77             	cmp    $0x77,%eax
  80025f:	0f 85 be 00 00 00    	jne    800323 <runcmd+0x125>
			if((fd=open(t,O_RDONLY))<0){
  800265:	83 ec 08             	sub    $0x8,%esp
  800268:	6a 00                	push   $0x0
  80026a:	ff 75 a4             	pushl  -0x5c(%ebp)
  80026d:	e8 7a 21 00 00       	call   8023ec <open>
  800272:	89 c3                	mov    %eax,%ebx
  800274:	83 c4 10             	add    $0x10,%esp
  800277:	85 c0                	test   %eax,%eax
  800279:	0f 88 be 00 00 00    	js     80033d <runcmd+0x13f>
			if(fd!=0){
  80027f:	85 c0                	test   %eax,%eax
  800281:	74 9c                	je     80021f <runcmd+0x21>
  800283:	e9 ca 00 00 00       	jmp    800352 <runcmd+0x154>
		switch ((c = gettoken(0, &t))) {
  800288:	83 f8 77             	cmp    $0x77,%eax
  80028b:	74 6b                	je     8002f8 <runcmd+0xfa>
  80028d:	83 f8 7c             	cmp    $0x7c,%eax
  800290:	0f 85 2c 02 00 00    	jne    8004c2 <runcmd+0x2c4>
			if ((r = pipe(p)) < 0) {
  800296:	83 ec 0c             	sub    $0xc,%esp
  800299:	8d 85 9c fb ff ff    	lea    -0x464(%ebp),%eax
  80029f:	50                   	push   %eax
  8002a0:	e8 d5 2a 00 00       	call   802d7a <pipe>
  8002a5:	83 c4 10             	add    $0x10,%esp
  8002a8:	85 c0                	test   %eax,%eax
  8002aa:	0f 88 3f 01 00 00    	js     8003ef <runcmd+0x1f1>
			if (debug)
  8002b0:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8002b7:	0f 85 4d 01 00 00    	jne    80040a <runcmd+0x20c>
			if ((r = fork()) < 0) {
  8002bd:	e8 7d 16 00 00       	call   80193f <fork>
  8002c2:	89 c3                	mov    %eax,%ebx
  8002c4:	85 c0                	test   %eax,%eax
  8002c6:	0f 88 5f 01 00 00    	js     80042b <runcmd+0x22d>
			if (r == 0) {
  8002cc:	85 c0                	test   %eax,%eax
  8002ce:	0f 85 6d 01 00 00    	jne    800441 <runcmd+0x243>
				if (p[0] != 0) {
  8002d4:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  8002da:	85 c0                	test   %eax,%eax
  8002dc:	0f 85 a1 01 00 00    	jne    800483 <runcmd+0x285>
				close(p[1]);
  8002e2:	83 ec 0c             	sub    $0xc,%esp
  8002e5:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  8002eb:	e8 5b 1b 00 00       	call   801e4b <close>
				goto again;
  8002f0:	83 c4 10             	add    $0x10,%esp
  8002f3:	e9 22 ff ff ff       	jmp    80021a <runcmd+0x1c>
			if (argc == MAXARGS) {
  8002f8:	83 ff 10             	cmp    $0x10,%edi
  8002fb:	74 0f                	je     80030c <runcmd+0x10e>
			argv[argc++] = t;
  8002fd:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  800300:	89 44 bd a8          	mov    %eax,-0x58(%ebp,%edi,4)
  800304:	8d 7f 01             	lea    0x1(%edi),%edi
			break;
  800307:	e9 13 ff ff ff       	jmp    80021f <runcmd+0x21>
				cprintf("too many arguments\n");
  80030c:	83 ec 0c             	sub    $0xc,%esp
  80030f:	68 a5 33 80 00       	push   $0x8033a5
  800314:	e8 39 08 00 00       	call   800b52 <cprintf>
				exit();
  800319:	e8 3f 07 00 00       	call   800a5d <exit>
  80031e:	83 c4 10             	add    $0x10,%esp
  800321:	eb da                	jmp    8002fd <runcmd+0xff>
				cprintf("syntax error: < not followed by word\n");
  800323:	83 ec 0c             	sub    $0xc,%esp
  800326:	68 f4 34 80 00       	push   $0x8034f4
  80032b:	e8 22 08 00 00       	call   800b52 <cprintf>
				exit();
  800330:	e8 28 07 00 00       	call   800a5d <exit>
  800335:	83 c4 10             	add    $0x10,%esp
  800338:	e9 28 ff ff ff       	jmp    800265 <runcmd+0x67>
			  cprintf("open file failed\n");
  80033d:	83 ec 0c             	sub    $0xc,%esp
  800340:	68 b9 33 80 00       	push   $0x8033b9
  800345:	e8 08 08 00 00       	call   800b52 <cprintf>
			  exit();
  80034a:	e8 0e 07 00 00       	call   800a5d <exit>
  80034f:	83 c4 10             	add    $0x10,%esp
			  dup(fd,0);
  800352:	83 ec 08             	sub    $0x8,%esp
  800355:	6a 00                	push   $0x0
  800357:	53                   	push   %ebx
  800358:	e8 3e 1b 00 00       	call   801e9b <dup>
			  close(fd);
  80035d:	89 1c 24             	mov    %ebx,(%esp)
  800360:	e8 e6 1a 00 00       	call   801e4b <close>
  800365:	83 c4 10             	add    $0x10,%esp
  800368:	e9 b2 fe ff ff       	jmp    80021f <runcmd+0x21>
			if (gettoken(0, &t) != 'w') {
  80036d:	83 ec 08             	sub    $0x8,%esp
  800370:	56                   	push   %esi
  800371:	6a 00                	push   $0x0
  800373:	e8 1b fe ff ff       	call   800193 <gettoken>
  800378:	83 c4 10             	add    $0x10,%esp
  80037b:	83 f8 77             	cmp    $0x77,%eax
  80037e:	75 3d                	jne    8003bd <runcmd+0x1bf>
			if ((fd = open(t, O_WRONLY|O_CREAT|O_TRUNC)) < 0) {
  800380:	83 ec 08             	sub    $0x8,%esp
  800383:	68 01 03 00 00       	push   $0x301
  800388:	ff 75 a4             	pushl  -0x5c(%ebp)
  80038b:	e8 5c 20 00 00       	call   8023ec <open>
  800390:	89 c3                	mov    %eax,%ebx
  800392:	83 c4 10             	add    $0x10,%esp
  800395:	85 c0                	test   %eax,%eax
  800397:	78 3b                	js     8003d4 <runcmd+0x1d6>
			if (fd != 1) {
  800399:	83 fb 01             	cmp    $0x1,%ebx
  80039c:	0f 84 7d fe ff ff    	je     80021f <runcmd+0x21>
				dup(fd, 1);
  8003a2:	83 ec 08             	sub    $0x8,%esp
  8003a5:	6a 01                	push   $0x1
  8003a7:	53                   	push   %ebx
  8003a8:	e8 ee 1a 00 00       	call   801e9b <dup>
				close(fd);
  8003ad:	89 1c 24             	mov    %ebx,(%esp)
  8003b0:	e8 96 1a 00 00       	call   801e4b <close>
  8003b5:	83 c4 10             	add    $0x10,%esp
  8003b8:	e9 62 fe ff ff       	jmp    80021f <runcmd+0x21>
				cprintf("syntax error: > not followed by word\n");
  8003bd:	83 ec 0c             	sub    $0xc,%esp
  8003c0:	68 1c 35 80 00       	push   $0x80351c
  8003c5:	e8 88 07 00 00       	call   800b52 <cprintf>
				exit();
  8003ca:	e8 8e 06 00 00       	call   800a5d <exit>
  8003cf:	83 c4 10             	add    $0x10,%esp
  8003d2:	eb ac                	jmp    800380 <runcmd+0x182>
				cprintf("open %s for write: %e", t, fd);
  8003d4:	83 ec 04             	sub    $0x4,%esp
  8003d7:	50                   	push   %eax
  8003d8:	ff 75 a4             	pushl  -0x5c(%ebp)
  8003db:	68 cb 33 80 00       	push   $0x8033cb
  8003e0:	e8 6d 07 00 00       	call   800b52 <cprintf>
				exit();
  8003e5:	e8 73 06 00 00       	call   800a5d <exit>
  8003ea:	83 c4 10             	add    $0x10,%esp
  8003ed:	eb aa                	jmp    800399 <runcmd+0x19b>
				cprintf("pipe: %e", r);
  8003ef:	83 ec 08             	sub    $0x8,%esp
  8003f2:	50                   	push   %eax
  8003f3:	68 e1 33 80 00       	push   $0x8033e1
  8003f8:	e8 55 07 00 00       	call   800b52 <cprintf>
				exit();
  8003fd:	e8 5b 06 00 00       	call   800a5d <exit>
  800402:	83 c4 10             	add    $0x10,%esp
  800405:	e9 a6 fe ff ff       	jmp    8002b0 <runcmd+0xb2>
				cprintf("PIPE: %d %d\n", p[0], p[1]);
  80040a:	83 ec 04             	sub    $0x4,%esp
  80040d:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  800413:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  800419:	68 ea 33 80 00       	push   $0x8033ea
  80041e:	e8 2f 07 00 00       	call   800b52 <cprintf>
  800423:	83 c4 10             	add    $0x10,%esp
  800426:	e9 92 fe ff ff       	jmp    8002bd <runcmd+0xbf>
				cprintf("fork: %e", r);
  80042b:	83 ec 08             	sub    $0x8,%esp
  80042e:	50                   	push   %eax
  80042f:	68 f7 33 80 00       	push   $0x8033f7
  800434:	e8 19 07 00 00       	call   800b52 <cprintf>
				exit();
  800439:	e8 1f 06 00 00       	call   800a5d <exit>
  80043e:	83 c4 10             	add    $0x10,%esp
				if (p[1] != 1) {
  800441:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  800447:	83 f8 01             	cmp    $0x1,%eax
  80044a:	75 58                	jne    8004a4 <runcmd+0x2a6>
				close(p[0]);
  80044c:	83 ec 0c             	sub    $0xc,%esp
  80044f:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  800455:	e8 f1 19 00 00       	call   801e4b <close>
				goto runit;
  80045a:	83 c4 10             	add    $0x10,%esp
	if(argc == 0) {
  80045d:	85 ff                	test   %edi,%edi
  80045f:	75 73                	jne    8004d4 <runcmd+0x2d6>
		if (debug)
  800461:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800468:	0f 84 f0 00 00 00    	je     80055e <runcmd+0x360>
			cprintf("EMPTY COMMAND\n");
  80046e:	83 ec 0c             	sub    $0xc,%esp
  800471:	68 26 34 80 00       	push   $0x803426
  800476:	e8 d7 06 00 00       	call   800b52 <cprintf>
  80047b:	83 c4 10             	add    $0x10,%esp
  80047e:	e9 db 00 00 00       	jmp    80055e <runcmd+0x360>
					dup(p[0], 0);
  800483:	83 ec 08             	sub    $0x8,%esp
  800486:	6a 00                	push   $0x0
  800488:	50                   	push   %eax
  800489:	e8 0d 1a 00 00       	call   801e9b <dup>
					close(p[0]);
  80048e:	83 c4 04             	add    $0x4,%esp
  800491:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  800497:	e8 af 19 00 00       	call   801e4b <close>
  80049c:	83 c4 10             	add    $0x10,%esp
  80049f:	e9 3e fe ff ff       	jmp    8002e2 <runcmd+0xe4>
					dup(p[1], 1);
  8004a4:	83 ec 08             	sub    $0x8,%esp
  8004a7:	6a 01                	push   $0x1
  8004a9:	50                   	push   %eax
  8004aa:	e8 ec 19 00 00       	call   801e9b <dup>
					close(p[1]);
  8004af:	83 c4 04             	add    $0x4,%esp
  8004b2:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  8004b8:	e8 8e 19 00 00       	call   801e4b <close>
  8004bd:	83 c4 10             	add    $0x10,%esp
  8004c0:	eb 8a                	jmp    80044c <runcmd+0x24e>
			panic("bad return %d from gettoken", c);
  8004c2:	53                   	push   %ebx
  8004c3:	68 00 34 80 00       	push   $0x803400
  8004c8:	6a 78                	push   $0x78
  8004ca:	68 1c 34 80 00       	push   $0x80341c
  8004cf:	e8 a3 05 00 00       	call   800a77 <_panic>
	if (argv[0][0] != '/') {
  8004d4:	8b 45 a8             	mov    -0x58(%ebp),%eax
  8004d7:	80 38 2f             	cmpb   $0x2f,(%eax)
  8004da:	0f 85 86 00 00 00    	jne    800566 <runcmd+0x368>
	argv[argc] = 0;
  8004e0:	c7 44 bd a8 00 00 00 	movl   $0x0,-0x58(%ebp,%edi,4)
  8004e7:	00 
	if (debug) {
  8004e8:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8004ef:	0f 85 99 00 00 00    	jne    80058e <runcmd+0x390>
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
  8004f5:	83 ec 08             	sub    $0x8,%esp
  8004f8:	8d 45 a8             	lea    -0x58(%ebp),%eax
  8004fb:	50                   	push   %eax
  8004fc:	ff 75 a8             	pushl  -0x58(%ebp)
  8004ff:	e8 a2 20 00 00       	call   8025a6 <spawn>
  800504:	89 c6                	mov    %eax,%esi
  800506:	83 c4 10             	add    $0x10,%esp
  800509:	85 c0                	test   %eax,%eax
  80050b:	0f 88 cb 00 00 00    	js     8005dc <runcmd+0x3de>
	close_all();
  800511:	e8 60 19 00 00       	call   801e76 <close_all>
		if (debug)
  800516:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80051d:	0f 85 06 01 00 00    	jne    800629 <runcmd+0x42b>
		wait(r);
  800523:	83 ec 0c             	sub    $0xc,%esp
  800526:	56                   	push   %esi
  800527:	e8 ca 29 00 00       	call   802ef6 <wait>
		if (debug)
  80052c:	83 c4 10             	add    $0x10,%esp
  80052f:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800536:	0f 85 0c 01 00 00    	jne    800648 <runcmd+0x44a>
	if (pipe_child) {
  80053c:	85 db                	test   %ebx,%ebx
  80053e:	74 19                	je     800559 <runcmd+0x35b>
		wait(pipe_child);
  800540:	83 ec 0c             	sub    $0xc,%esp
  800543:	53                   	push   %ebx
  800544:	e8 ad 29 00 00       	call   802ef6 <wait>
		if (debug)
  800549:	83 c4 10             	add    $0x10,%esp
  80054c:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800553:	0f 85 0a 01 00 00    	jne    800663 <runcmd+0x465>
	exit();
  800559:	e8 ff 04 00 00       	call   800a5d <exit>
}
  80055e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800561:	5b                   	pop    %ebx
  800562:	5e                   	pop    %esi
  800563:	5f                   	pop    %edi
  800564:	5d                   	pop    %ebp
  800565:	c3                   	ret    
		argv0buf[0] = '/';
  800566:	c6 85 a4 fb ff ff 2f 	movb   $0x2f,-0x45c(%ebp)
		strcpy(argv0buf + 1, argv[0]);
  80056d:	83 ec 08             	sub    $0x8,%esp
  800570:	50                   	push   %eax
  800571:	8d b5 a4 fb ff ff    	lea    -0x45c(%ebp),%esi
  800577:	8d 85 a5 fb ff ff    	lea    -0x45b(%ebp),%eax
  80057d:	50                   	push   %eax
  80057e:	e8 de 0c 00 00       	call   801261 <strcpy>
		argv[0] = argv0buf;
  800583:	89 75 a8             	mov    %esi,-0x58(%ebp)
  800586:	83 c4 10             	add    $0x10,%esp
  800589:	e9 52 ff ff ff       	jmp    8004e0 <runcmd+0x2e2>
		cprintf("[%08x] SPAWN:", thisenv->env_id);
  80058e:	a1 24 54 80 00       	mov    0x805424,%eax
  800593:	8b 40 48             	mov    0x48(%eax),%eax
  800596:	83 ec 08             	sub    $0x8,%esp
  800599:	50                   	push   %eax
  80059a:	68 35 34 80 00       	push   $0x803435
  80059f:	e8 ae 05 00 00       	call   800b52 <cprintf>
  8005a4:	8d 75 a8             	lea    -0x58(%ebp),%esi
		for (i = 0; argv[i]; i++)
  8005a7:	83 c4 10             	add    $0x10,%esp
  8005aa:	83 c6 04             	add    $0x4,%esi
  8005ad:	8b 46 fc             	mov    -0x4(%esi),%eax
  8005b0:	85 c0                	test   %eax,%eax
  8005b2:	74 13                	je     8005c7 <runcmd+0x3c9>
			cprintf(" %s", argv[i]);
  8005b4:	83 ec 08             	sub    $0x8,%esp
  8005b7:	50                   	push   %eax
  8005b8:	68 bd 34 80 00       	push   $0x8034bd
  8005bd:	e8 90 05 00 00       	call   800b52 <cprintf>
  8005c2:	83 c4 10             	add    $0x10,%esp
  8005c5:	eb e3                	jmp    8005aa <runcmd+0x3ac>
		cprintf("\n");
  8005c7:	83 ec 0c             	sub    $0xc,%esp
  8005ca:	68 80 33 80 00       	push   $0x803380
  8005cf:	e8 7e 05 00 00       	call   800b52 <cprintf>
  8005d4:	83 c4 10             	add    $0x10,%esp
  8005d7:	e9 19 ff ff ff       	jmp    8004f5 <runcmd+0x2f7>
		cprintf("spawn %s: %e\n", argv[0], r);
  8005dc:	83 ec 04             	sub    $0x4,%esp
  8005df:	50                   	push   %eax
  8005e0:	ff 75 a8             	pushl  -0x58(%ebp)
  8005e3:	68 43 34 80 00       	push   $0x803443
  8005e8:	e8 65 05 00 00       	call   800b52 <cprintf>
	close_all();
  8005ed:	e8 84 18 00 00       	call   801e76 <close_all>
  8005f2:	83 c4 10             	add    $0x10,%esp
	if (pipe_child) {
  8005f5:	85 db                	test   %ebx,%ebx
  8005f7:	0f 84 5c ff ff ff    	je     800559 <runcmd+0x35b>
		if (debug)
  8005fd:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800604:	0f 84 36 ff ff ff    	je     800540 <runcmd+0x342>
			cprintf("[%08x] WAIT pipe_child %08x\n", thisenv->env_id, pipe_child);
  80060a:	a1 24 54 80 00       	mov    0x805424,%eax
  80060f:	8b 40 48             	mov    0x48(%eax),%eax
  800612:	83 ec 04             	sub    $0x4,%esp
  800615:	53                   	push   %ebx
  800616:	50                   	push   %eax
  800617:	68 7c 34 80 00       	push   $0x80347c
  80061c:	e8 31 05 00 00       	call   800b52 <cprintf>
  800621:	83 c4 10             	add    $0x10,%esp
  800624:	e9 17 ff ff ff       	jmp    800540 <runcmd+0x342>
			cprintf("[%08x] WAIT %s %08x\n", thisenv->env_id, argv[0], r);
  800629:	a1 24 54 80 00       	mov    0x805424,%eax
  80062e:	8b 40 48             	mov    0x48(%eax),%eax
  800631:	56                   	push   %esi
  800632:	ff 75 a8             	pushl  -0x58(%ebp)
  800635:	50                   	push   %eax
  800636:	68 51 34 80 00       	push   $0x803451
  80063b:	e8 12 05 00 00       	call   800b52 <cprintf>
  800640:	83 c4 10             	add    $0x10,%esp
  800643:	e9 db fe ff ff       	jmp    800523 <runcmd+0x325>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  800648:	a1 24 54 80 00       	mov    0x805424,%eax
  80064d:	8b 40 48             	mov    0x48(%eax),%eax
  800650:	83 ec 08             	sub    $0x8,%esp
  800653:	50                   	push   %eax
  800654:	68 66 34 80 00       	push   $0x803466
  800659:	e8 f4 04 00 00       	call   800b52 <cprintf>
  80065e:	83 c4 10             	add    $0x10,%esp
  800661:	eb 92                	jmp    8005f5 <runcmd+0x3f7>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  800663:	a1 24 54 80 00       	mov    0x805424,%eax
  800668:	8b 40 48             	mov    0x48(%eax),%eax
  80066b:	83 ec 08             	sub    $0x8,%esp
  80066e:	50                   	push   %eax
  80066f:	68 66 34 80 00       	push   $0x803466
  800674:	e8 d9 04 00 00       	call   800b52 <cprintf>
  800679:	83 c4 10             	add    $0x10,%esp
  80067c:	e9 d8 fe ff ff       	jmp    800559 <runcmd+0x35b>

00800681 <usage>:


void
usage(void)
{
  800681:	55                   	push   %ebp
  800682:	89 e5                	mov    %esp,%ebp
  800684:	83 ec 14             	sub    $0x14,%esp
	cprintf("usage: sh [-dix] [command-file]\n");
  800687:	68 44 35 80 00       	push   $0x803544
  80068c:	e8 c1 04 00 00       	call   800b52 <cprintf>
	exit();
  800691:	e8 c7 03 00 00       	call   800a5d <exit>
}
  800696:	83 c4 10             	add    $0x10,%esp
  800699:	c9                   	leave  
  80069a:	c3                   	ret    

0080069b <umain>:

void
umain(int argc, char **argv)
{
  80069b:	55                   	push   %ebp
  80069c:	89 e5                	mov    %esp,%ebp
  80069e:	57                   	push   %edi
  80069f:	56                   	push   %esi
  8006a0:	53                   	push   %ebx
  8006a1:	83 ec 30             	sub    $0x30,%esp
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
  8006a4:	8d 45 d8             	lea    -0x28(%ebp),%eax
  8006a7:	50                   	push   %eax
  8006a8:	ff 75 0c             	pushl  0xc(%ebp)
  8006ab:	8d 45 08             	lea    0x8(%ebp),%eax
  8006ae:	50                   	push   %eax
  8006af:	e8 98 14 00 00       	call   801b4c <argstart>
	while ((r = argnext(&args)) >= 0)
  8006b4:	83 c4 10             	add    $0x10,%esp
	echocmds = 0;
  8006b7:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
	interactive = '?';
  8006be:	bf 3f 00 00 00       	mov    $0x3f,%edi
	while ((r = argnext(&args)) >= 0)
  8006c3:	8d 5d d8             	lea    -0x28(%ebp),%ebx
		switch (r) {
		case 'd':
			debug++;
			break;
		case 'i':
			interactive = 1;
  8006c6:	be 01 00 00 00       	mov    $0x1,%esi
	while ((r = argnext(&args)) >= 0)
  8006cb:	eb 03                	jmp    8006d0 <umain+0x35>
			break;
		case 'x':
			echocmds = 1;
  8006cd:	89 75 d4             	mov    %esi,-0x2c(%ebp)
	while ((r = argnext(&args)) >= 0)
  8006d0:	83 ec 0c             	sub    $0xc,%esp
  8006d3:	53                   	push   %ebx
  8006d4:	e8 a3 14 00 00       	call   801b7c <argnext>
  8006d9:	83 c4 10             	add    $0x10,%esp
  8006dc:	85 c0                	test   %eax,%eax
  8006de:	78 23                	js     800703 <umain+0x68>
		switch (r) {
  8006e0:	83 f8 69             	cmp    $0x69,%eax
  8006e3:	74 1a                	je     8006ff <umain+0x64>
  8006e5:	83 f8 78             	cmp    $0x78,%eax
  8006e8:	74 e3                	je     8006cd <umain+0x32>
  8006ea:	83 f8 64             	cmp    $0x64,%eax
  8006ed:	74 07                	je     8006f6 <umain+0x5b>
			break;
		default:
			usage();
  8006ef:	e8 8d ff ff ff       	call   800681 <usage>
  8006f4:	eb da                	jmp    8006d0 <umain+0x35>
			debug++;
  8006f6:	83 05 00 50 80 00 01 	addl   $0x1,0x805000
			break;
  8006fd:	eb d1                	jmp    8006d0 <umain+0x35>
			interactive = 1;
  8006ff:	89 f7                	mov    %esi,%edi
  800701:	eb cd                	jmp    8006d0 <umain+0x35>
		}

	if (argc > 2)
  800703:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  800707:	7f 1f                	jg     800728 <umain+0x8d>
		usage();
	if (argc == 2) {
  800709:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  80070d:	74 20                	je     80072f <umain+0x94>
		close(0);
		if ((r = open(argv[1], O_RDONLY)) < 0)
			panic("open %s: %e", argv[1], r);
		assert(r == 0);
	}
	if (interactive == '?')
  80070f:	83 ff 3f             	cmp    $0x3f,%edi
  800712:	74 77                	je     80078b <umain+0xf0>
  800714:	85 ff                	test   %edi,%edi
  800716:	bf c1 34 80 00       	mov    $0x8034c1,%edi
  80071b:	b8 00 00 00 00       	mov    $0x0,%eax
  800720:	0f 44 f8             	cmove  %eax,%edi
  800723:	e9 08 01 00 00       	jmp    800830 <umain+0x195>
		usage();
  800728:	e8 54 ff ff ff       	call   800681 <usage>
  80072d:	eb da                	jmp    800709 <umain+0x6e>
		close(0);
  80072f:	83 ec 0c             	sub    $0xc,%esp
  800732:	6a 00                	push   $0x0
  800734:	e8 12 17 00 00       	call   801e4b <close>
		if ((r = open(argv[1], O_RDONLY)) < 0)
  800739:	83 c4 08             	add    $0x8,%esp
  80073c:	6a 00                	push   $0x0
  80073e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800741:	ff 70 04             	pushl  0x4(%eax)
  800744:	e8 a3 1c 00 00       	call   8023ec <open>
  800749:	83 c4 10             	add    $0x10,%esp
  80074c:	85 c0                	test   %eax,%eax
  80074e:	78 1d                	js     80076d <umain+0xd2>
		assert(r == 0);
  800750:	85 c0                	test   %eax,%eax
  800752:	74 bb                	je     80070f <umain+0x74>
  800754:	68 a5 34 80 00       	push   $0x8034a5
  800759:	68 ac 34 80 00       	push   $0x8034ac
  80075e:	68 29 01 00 00       	push   $0x129
  800763:	68 1c 34 80 00       	push   $0x80341c
  800768:	e8 0a 03 00 00       	call   800a77 <_panic>
			panic("open %s: %e", argv[1], r);
  80076d:	83 ec 0c             	sub    $0xc,%esp
  800770:	50                   	push   %eax
  800771:	8b 45 0c             	mov    0xc(%ebp),%eax
  800774:	ff 70 04             	pushl  0x4(%eax)
  800777:	68 99 34 80 00       	push   $0x803499
  80077c:	68 28 01 00 00       	push   $0x128
  800781:	68 1c 34 80 00       	push   $0x80341c
  800786:	e8 ec 02 00 00       	call   800a77 <_panic>
		interactive = iscons(0);
  80078b:	83 ec 0c             	sub    $0xc,%esp
  80078e:	6a 00                	push   $0x0
  800790:	e8 04 02 00 00       	call   800999 <iscons>
  800795:	89 c7                	mov    %eax,%edi
  800797:	83 c4 10             	add    $0x10,%esp
  80079a:	e9 75 ff ff ff       	jmp    800714 <umain+0x79>
	while (1) {
		char *buf;

		buf = readline(interactive ? "$ " : NULL);
		if (buf == NULL) {
			if (debug)
  80079f:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007a6:	75 0a                	jne    8007b2 <umain+0x117>
				cprintf("EXITING\n");
			exit();	// end of file
  8007a8:	e8 b0 02 00 00       	call   800a5d <exit>
  8007ad:	e9 94 00 00 00       	jmp    800846 <umain+0x1ab>
				cprintf("EXITING\n");
  8007b2:	83 ec 0c             	sub    $0xc,%esp
  8007b5:	68 c4 34 80 00       	push   $0x8034c4
  8007ba:	e8 93 03 00 00       	call   800b52 <cprintf>
  8007bf:	83 c4 10             	add    $0x10,%esp
  8007c2:	eb e4                	jmp    8007a8 <umain+0x10d>
		}
		if (debug)
			cprintf("LINE: %s\n", buf);
  8007c4:	83 ec 08             	sub    $0x8,%esp
  8007c7:	53                   	push   %ebx
  8007c8:	68 cd 34 80 00       	push   $0x8034cd
  8007cd:	e8 80 03 00 00       	call   800b52 <cprintf>
  8007d2:	83 c4 10             	add    $0x10,%esp
  8007d5:	eb 7c                	jmp    800853 <umain+0x1b8>
		if (buf[0] == '#')
			continue;
		if (echocmds)
			printf("# %s\n", buf);
  8007d7:	83 ec 08             	sub    $0x8,%esp
  8007da:	53                   	push   %ebx
  8007db:	68 d7 34 80 00       	push   $0x8034d7
  8007e0:	e8 ab 1d 00 00       	call   802590 <printf>
  8007e5:	83 c4 10             	add    $0x10,%esp
  8007e8:	eb 78                	jmp    800862 <umain+0x1c7>
		if (debug)
			cprintf("BEFORE FORK\n");
  8007ea:	83 ec 0c             	sub    $0xc,%esp
  8007ed:	68 dd 34 80 00       	push   $0x8034dd
  8007f2:	e8 5b 03 00 00       	call   800b52 <cprintf>
  8007f7:	83 c4 10             	add    $0x10,%esp
  8007fa:	eb 73                	jmp    80086f <umain+0x1d4>
		if ((r = fork()) < 0)
			panic("fork: %e", r);
  8007fc:	50                   	push   %eax
  8007fd:	68 f7 33 80 00       	push   $0x8033f7
  800802:	68 40 01 00 00       	push   $0x140
  800807:	68 1c 34 80 00       	push   $0x80341c
  80080c:	e8 66 02 00 00       	call   800a77 <_panic>
		if (debug)
			cprintf("FORK: %d\n", r);
  800811:	83 ec 08             	sub    $0x8,%esp
  800814:	50                   	push   %eax
  800815:	68 ea 34 80 00       	push   $0x8034ea
  80081a:	e8 33 03 00 00       	call   800b52 <cprintf>
  80081f:	83 c4 10             	add    $0x10,%esp
  800822:	eb 5f                	jmp    800883 <umain+0x1e8>
		if (r == 0) {
			runcmd(buf);
			exit();
		} else
			wait(r);
  800824:	83 ec 0c             	sub    $0xc,%esp
  800827:	56                   	push   %esi
  800828:	e8 c9 26 00 00       	call   802ef6 <wait>
  80082d:	83 c4 10             	add    $0x10,%esp
		buf = readline(interactive ? "$ " : NULL);
  800830:	83 ec 0c             	sub    $0xc,%esp
  800833:	57                   	push   %edi
  800834:	e8 01 09 00 00       	call   80113a <readline>
  800839:	89 c3                	mov    %eax,%ebx
		if (buf == NULL) {
  80083b:	83 c4 10             	add    $0x10,%esp
  80083e:	85 c0                	test   %eax,%eax
  800840:	0f 84 59 ff ff ff    	je     80079f <umain+0x104>
		if (debug)
  800846:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80084d:	0f 85 71 ff ff ff    	jne    8007c4 <umain+0x129>
		if (buf[0] == '#')
  800853:	80 3b 23             	cmpb   $0x23,(%ebx)
  800856:	74 d8                	je     800830 <umain+0x195>
		if (echocmds)
  800858:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80085c:	0f 85 75 ff ff ff    	jne    8007d7 <umain+0x13c>
		if (debug)
  800862:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800869:	0f 85 7b ff ff ff    	jne    8007ea <umain+0x14f>
		if ((r = fork()) < 0)
  80086f:	e8 cb 10 00 00       	call   80193f <fork>
  800874:	89 c6                	mov    %eax,%esi
  800876:	85 c0                	test   %eax,%eax
  800878:	78 82                	js     8007fc <umain+0x161>
		if (debug)
  80087a:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800881:	75 8e                	jne    800811 <umain+0x176>
		if (r == 0) {
  800883:	85 f6                	test   %esi,%esi
  800885:	75 9d                	jne    800824 <umain+0x189>
			runcmd(buf);
  800887:	83 ec 0c             	sub    $0xc,%esp
  80088a:	53                   	push   %ebx
  80088b:	e8 6e f9 ff ff       	call   8001fe <runcmd>
			exit();
  800890:	e8 c8 01 00 00       	call   800a5d <exit>
  800895:	83 c4 10             	add    $0x10,%esp
  800898:	eb 96                	jmp    800830 <umain+0x195>

0080089a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80089d:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a2:	5d                   	pop    %ebp
  8008a3:	c3                   	ret    

008008a4 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
  8008a7:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8008aa:	68 65 35 80 00       	push   $0x803565
  8008af:	ff 75 0c             	pushl  0xc(%ebp)
  8008b2:	e8 aa 09 00 00       	call   801261 <strcpy>
	return 0;
}
  8008b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8008bc:	c9                   	leave  
  8008bd:	c3                   	ret    

008008be <devcons_write>:
{
  8008be:	55                   	push   %ebp
  8008bf:	89 e5                	mov    %esp,%ebp
  8008c1:	57                   	push   %edi
  8008c2:	56                   	push   %esi
  8008c3:	53                   	push   %ebx
  8008c4:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8008ca:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8008cf:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8008d5:	eb 2f                	jmp    800906 <devcons_write+0x48>
		m = n - tot;
  8008d7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8008da:	29 f3                	sub    %esi,%ebx
  8008dc:	83 fb 7f             	cmp    $0x7f,%ebx
  8008df:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8008e4:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8008e7:	83 ec 04             	sub    $0x4,%esp
  8008ea:	53                   	push   %ebx
  8008eb:	89 f0                	mov    %esi,%eax
  8008ed:	03 45 0c             	add    0xc(%ebp),%eax
  8008f0:	50                   	push   %eax
  8008f1:	57                   	push   %edi
  8008f2:	e8 f8 0a 00 00       	call   8013ef <memmove>
		sys_cputs(buf, m);
  8008f7:	83 c4 08             	add    $0x8,%esp
  8008fa:	53                   	push   %ebx
  8008fb:	57                   	push   %edi
  8008fc:	e8 9d 0c 00 00       	call   80159e <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800901:	01 de                	add    %ebx,%esi
  800903:	83 c4 10             	add    $0x10,%esp
  800906:	3b 75 10             	cmp    0x10(%ebp),%esi
  800909:	72 cc                	jb     8008d7 <devcons_write+0x19>
}
  80090b:	89 f0                	mov    %esi,%eax
  80090d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800910:	5b                   	pop    %ebx
  800911:	5e                   	pop    %esi
  800912:	5f                   	pop    %edi
  800913:	5d                   	pop    %ebp
  800914:	c3                   	ret    

00800915 <devcons_read>:
{
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	83 ec 08             	sub    $0x8,%esp
  80091b:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800920:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800924:	75 07                	jne    80092d <devcons_read+0x18>
}
  800926:	c9                   	leave  
  800927:	c3                   	ret    
		sys_yield();
  800928:	e8 0e 0d 00 00       	call   80163b <sys_yield>
	while ((c = sys_cgetc()) == 0)
  80092d:	e8 8a 0c 00 00       	call   8015bc <sys_cgetc>
  800932:	85 c0                	test   %eax,%eax
  800934:	74 f2                	je     800928 <devcons_read+0x13>
	if (c < 0)
  800936:	85 c0                	test   %eax,%eax
  800938:	78 ec                	js     800926 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  80093a:	83 f8 04             	cmp    $0x4,%eax
  80093d:	74 0c                	je     80094b <devcons_read+0x36>
	*(char*)vbuf = c;
  80093f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800942:	88 02                	mov    %al,(%edx)
	return 1;
  800944:	b8 01 00 00 00       	mov    $0x1,%eax
  800949:	eb db                	jmp    800926 <devcons_read+0x11>
		return 0;
  80094b:	b8 00 00 00 00       	mov    $0x0,%eax
  800950:	eb d4                	jmp    800926 <devcons_read+0x11>

00800952 <cputchar>:
{
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
  800955:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800958:	8b 45 08             	mov    0x8(%ebp),%eax
  80095b:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  80095e:	6a 01                	push   $0x1
  800960:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800963:	50                   	push   %eax
  800964:	e8 35 0c 00 00       	call   80159e <sys_cputs>
}
  800969:	83 c4 10             	add    $0x10,%esp
  80096c:	c9                   	leave  
  80096d:	c3                   	ret    

0080096e <getchar>:
{
  80096e:	55                   	push   %ebp
  80096f:	89 e5                	mov    %esp,%ebp
  800971:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800974:	6a 01                	push   $0x1
  800976:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800979:	50                   	push   %eax
  80097a:	6a 00                	push   $0x0
  80097c:	e8 06 16 00 00       	call   801f87 <read>
	if (r < 0)
  800981:	83 c4 10             	add    $0x10,%esp
  800984:	85 c0                	test   %eax,%eax
  800986:	78 08                	js     800990 <getchar+0x22>
	if (r < 1)
  800988:	85 c0                	test   %eax,%eax
  80098a:	7e 06                	jle    800992 <getchar+0x24>
	return c;
  80098c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800990:	c9                   	leave  
  800991:	c3                   	ret    
		return -E_EOF;
  800992:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800997:	eb f7                	jmp    800990 <getchar+0x22>

00800999 <iscons>:
{
  800999:	55                   	push   %ebp
  80099a:	89 e5                	mov    %esp,%ebp
  80099c:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80099f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009a2:	50                   	push   %eax
  8009a3:	ff 75 08             	pushl  0x8(%ebp)
  8009a6:	e8 6b 13 00 00       	call   801d16 <fd_lookup>
  8009ab:	83 c4 10             	add    $0x10,%esp
  8009ae:	85 c0                	test   %eax,%eax
  8009b0:	78 11                	js     8009c3 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  8009b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009b5:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8009bb:	39 10                	cmp    %edx,(%eax)
  8009bd:	0f 94 c0             	sete   %al
  8009c0:	0f b6 c0             	movzbl %al,%eax
}
  8009c3:	c9                   	leave  
  8009c4:	c3                   	ret    

008009c5 <opencons>:
{
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
  8009c8:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8009cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009ce:	50                   	push   %eax
  8009cf:	e8 f3 12 00 00       	call   801cc7 <fd_alloc>
  8009d4:	83 c4 10             	add    $0x10,%esp
  8009d7:	85 c0                	test   %eax,%eax
  8009d9:	78 3a                	js     800a15 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8009db:	83 ec 04             	sub    $0x4,%esp
  8009de:	68 07 04 00 00       	push   $0x407
  8009e3:	ff 75 f4             	pushl  -0xc(%ebp)
  8009e6:	6a 00                	push   $0x0
  8009e8:	e8 6d 0c 00 00       	call   80165a <sys_page_alloc>
  8009ed:	83 c4 10             	add    $0x10,%esp
  8009f0:	85 c0                	test   %eax,%eax
  8009f2:	78 21                	js     800a15 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8009f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009f7:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8009fd:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8009ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a02:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800a09:	83 ec 0c             	sub    $0xc,%esp
  800a0c:	50                   	push   %eax
  800a0d:	e8 8e 12 00 00       	call   801ca0 <fd2num>
  800a12:	83 c4 10             	add    $0x10,%esp
}
  800a15:	c9                   	leave  
  800a16:	c3                   	ret    

00800a17 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	56                   	push   %esi
  800a1b:	53                   	push   %ebx
  800a1c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a1f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800a22:	e8 f5 0b 00 00       	call   80161c <sys_getenvid>
  800a27:	25 ff 03 00 00       	and    $0x3ff,%eax
  800a2c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800a2f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800a34:	a3 24 54 80 00       	mov    %eax,0x805424
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800a39:	85 db                	test   %ebx,%ebx
  800a3b:	7e 07                	jle    800a44 <libmain+0x2d>
		binaryname = argv[0];
  800a3d:	8b 06                	mov    (%esi),%eax
  800a3f:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  800a44:	83 ec 08             	sub    $0x8,%esp
  800a47:	56                   	push   %esi
  800a48:	53                   	push   %ebx
  800a49:	e8 4d fc ff ff       	call   80069b <umain>

	// exit gracefully
	exit();
  800a4e:	e8 0a 00 00 00       	call   800a5d <exit>
}
  800a53:	83 c4 10             	add    $0x10,%esp
  800a56:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a59:	5b                   	pop    %ebx
  800a5a:	5e                   	pop    %esi
  800a5b:	5d                   	pop    %ebp
  800a5c:	c3                   	ret    

00800a5d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
  800a60:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800a63:	e8 0e 14 00 00       	call   801e76 <close_all>
	sys_env_destroy(0);
  800a68:	83 ec 0c             	sub    $0xc,%esp
  800a6b:	6a 00                	push   $0x0
  800a6d:	e8 69 0b 00 00       	call   8015db <sys_env_destroy>
}
  800a72:	83 c4 10             	add    $0x10,%esp
  800a75:	c9                   	leave  
  800a76:	c3                   	ret    

00800a77 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800a77:	55                   	push   %ebp
  800a78:	89 e5                	mov    %esp,%ebp
  800a7a:	56                   	push   %esi
  800a7b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800a7c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800a7f:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  800a85:	e8 92 0b 00 00       	call   80161c <sys_getenvid>
  800a8a:	83 ec 0c             	sub    $0xc,%esp
  800a8d:	ff 75 0c             	pushl  0xc(%ebp)
  800a90:	ff 75 08             	pushl  0x8(%ebp)
  800a93:	56                   	push   %esi
  800a94:	50                   	push   %eax
  800a95:	68 7c 35 80 00       	push   $0x80357c
  800a9a:	e8 b3 00 00 00       	call   800b52 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800a9f:	83 c4 18             	add    $0x18,%esp
  800aa2:	53                   	push   %ebx
  800aa3:	ff 75 10             	pushl  0x10(%ebp)
  800aa6:	e8 56 00 00 00       	call   800b01 <vcprintf>
	cprintf("\n");
  800aab:	c7 04 24 80 33 80 00 	movl   $0x803380,(%esp)
  800ab2:	e8 9b 00 00 00       	call   800b52 <cprintf>
  800ab7:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800aba:	cc                   	int3   
  800abb:	eb fd                	jmp    800aba <_panic+0x43>

00800abd <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800abd:	55                   	push   %ebp
  800abe:	89 e5                	mov    %esp,%ebp
  800ac0:	53                   	push   %ebx
  800ac1:	83 ec 04             	sub    $0x4,%esp
  800ac4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800ac7:	8b 13                	mov    (%ebx),%edx
  800ac9:	8d 42 01             	lea    0x1(%edx),%eax
  800acc:	89 03                	mov    %eax,(%ebx)
  800ace:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ad1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800ad5:	3d ff 00 00 00       	cmp    $0xff,%eax
  800ada:	74 09                	je     800ae5 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800adc:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800ae0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ae3:	c9                   	leave  
  800ae4:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800ae5:	83 ec 08             	sub    $0x8,%esp
  800ae8:	68 ff 00 00 00       	push   $0xff
  800aed:	8d 43 08             	lea    0x8(%ebx),%eax
  800af0:	50                   	push   %eax
  800af1:	e8 a8 0a 00 00       	call   80159e <sys_cputs>
		b->idx = 0;
  800af6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800afc:	83 c4 10             	add    $0x10,%esp
  800aff:	eb db                	jmp    800adc <putch+0x1f>

00800b01 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800b0a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800b11:	00 00 00 
	b.cnt = 0;
  800b14:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800b1b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800b1e:	ff 75 0c             	pushl  0xc(%ebp)
  800b21:	ff 75 08             	pushl  0x8(%ebp)
  800b24:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800b2a:	50                   	push   %eax
  800b2b:	68 bd 0a 80 00       	push   $0x800abd
  800b30:	e8 1a 01 00 00       	call   800c4f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800b35:	83 c4 08             	add    $0x8,%esp
  800b38:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800b3e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800b44:	50                   	push   %eax
  800b45:	e8 54 0a 00 00       	call   80159e <sys_cputs>

	return b.cnt;
}
  800b4a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800b50:	c9                   	leave  
  800b51:	c3                   	ret    

00800b52 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800b52:	55                   	push   %ebp
  800b53:	89 e5                	mov    %esp,%ebp
  800b55:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800b58:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800b5b:	50                   	push   %eax
  800b5c:	ff 75 08             	pushl  0x8(%ebp)
  800b5f:	e8 9d ff ff ff       	call   800b01 <vcprintf>
	va_end(ap);

	return cnt;
}
  800b64:	c9                   	leave  
  800b65:	c3                   	ret    

00800b66 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	57                   	push   %edi
  800b6a:	56                   	push   %esi
  800b6b:	53                   	push   %ebx
  800b6c:	83 ec 1c             	sub    $0x1c,%esp
  800b6f:	89 c7                	mov    %eax,%edi
  800b71:	89 d6                	mov    %edx,%esi
  800b73:	8b 45 08             	mov    0x8(%ebp),%eax
  800b76:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b79:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b7c:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800b7f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b82:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b87:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800b8a:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800b8d:	39 d3                	cmp    %edx,%ebx
  800b8f:	72 05                	jb     800b96 <printnum+0x30>
  800b91:	39 45 10             	cmp    %eax,0x10(%ebp)
  800b94:	77 7a                	ja     800c10 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800b96:	83 ec 0c             	sub    $0xc,%esp
  800b99:	ff 75 18             	pushl  0x18(%ebp)
  800b9c:	8b 45 14             	mov    0x14(%ebp),%eax
  800b9f:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800ba2:	53                   	push   %ebx
  800ba3:	ff 75 10             	pushl  0x10(%ebp)
  800ba6:	83 ec 08             	sub    $0x8,%esp
  800ba9:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bac:	ff 75 e0             	pushl  -0x20(%ebp)
  800baf:	ff 75 dc             	pushl  -0x24(%ebp)
  800bb2:	ff 75 d8             	pushl  -0x28(%ebp)
  800bb5:	e8 56 25 00 00       	call   803110 <__udivdi3>
  800bba:	83 c4 18             	add    $0x18,%esp
  800bbd:	52                   	push   %edx
  800bbe:	50                   	push   %eax
  800bbf:	89 f2                	mov    %esi,%edx
  800bc1:	89 f8                	mov    %edi,%eax
  800bc3:	e8 9e ff ff ff       	call   800b66 <printnum>
  800bc8:	83 c4 20             	add    $0x20,%esp
  800bcb:	eb 13                	jmp    800be0 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800bcd:	83 ec 08             	sub    $0x8,%esp
  800bd0:	56                   	push   %esi
  800bd1:	ff 75 18             	pushl  0x18(%ebp)
  800bd4:	ff d7                	call   *%edi
  800bd6:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800bd9:	83 eb 01             	sub    $0x1,%ebx
  800bdc:	85 db                	test   %ebx,%ebx
  800bde:	7f ed                	jg     800bcd <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800be0:	83 ec 08             	sub    $0x8,%esp
  800be3:	56                   	push   %esi
  800be4:	83 ec 04             	sub    $0x4,%esp
  800be7:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bea:	ff 75 e0             	pushl  -0x20(%ebp)
  800bed:	ff 75 dc             	pushl  -0x24(%ebp)
  800bf0:	ff 75 d8             	pushl  -0x28(%ebp)
  800bf3:	e8 38 26 00 00       	call   803230 <__umoddi3>
  800bf8:	83 c4 14             	add    $0x14,%esp
  800bfb:	0f be 80 9f 35 80 00 	movsbl 0x80359f(%eax),%eax
  800c02:	50                   	push   %eax
  800c03:	ff d7                	call   *%edi
}
  800c05:	83 c4 10             	add    $0x10,%esp
  800c08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c0b:	5b                   	pop    %ebx
  800c0c:	5e                   	pop    %esi
  800c0d:	5f                   	pop    %edi
  800c0e:	5d                   	pop    %ebp
  800c0f:	c3                   	ret    
  800c10:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800c13:	eb c4                	jmp    800bd9 <printnum+0x73>

00800c15 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800c15:	55                   	push   %ebp
  800c16:	89 e5                	mov    %esp,%ebp
  800c18:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800c1b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800c1f:	8b 10                	mov    (%eax),%edx
  800c21:	3b 50 04             	cmp    0x4(%eax),%edx
  800c24:	73 0a                	jae    800c30 <sprintputch+0x1b>
		*b->buf++ = ch;
  800c26:	8d 4a 01             	lea    0x1(%edx),%ecx
  800c29:	89 08                	mov    %ecx,(%eax)
  800c2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2e:	88 02                	mov    %al,(%edx)
}
  800c30:	5d                   	pop    %ebp
  800c31:	c3                   	ret    

00800c32 <printfmt>:
{
  800c32:	55                   	push   %ebp
  800c33:	89 e5                	mov    %esp,%ebp
  800c35:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800c38:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800c3b:	50                   	push   %eax
  800c3c:	ff 75 10             	pushl  0x10(%ebp)
  800c3f:	ff 75 0c             	pushl  0xc(%ebp)
  800c42:	ff 75 08             	pushl  0x8(%ebp)
  800c45:	e8 05 00 00 00       	call   800c4f <vprintfmt>
}
  800c4a:	83 c4 10             	add    $0x10,%esp
  800c4d:	c9                   	leave  
  800c4e:	c3                   	ret    

00800c4f <vprintfmt>:
{
  800c4f:	55                   	push   %ebp
  800c50:	89 e5                	mov    %esp,%ebp
  800c52:	57                   	push   %edi
  800c53:	56                   	push   %esi
  800c54:	53                   	push   %ebx
  800c55:	83 ec 2c             	sub    $0x2c,%esp
  800c58:	8b 75 08             	mov    0x8(%ebp),%esi
  800c5b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c5e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800c61:	e9 c1 03 00 00       	jmp    801027 <vprintfmt+0x3d8>
		padc = ' ';
  800c66:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800c6a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800c71:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800c78:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800c7f:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800c84:	8d 47 01             	lea    0x1(%edi),%eax
  800c87:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c8a:	0f b6 17             	movzbl (%edi),%edx
  800c8d:	8d 42 dd             	lea    -0x23(%edx),%eax
  800c90:	3c 55                	cmp    $0x55,%al
  800c92:	0f 87 12 04 00 00    	ja     8010aa <vprintfmt+0x45b>
  800c98:	0f b6 c0             	movzbl %al,%eax
  800c9b:	ff 24 85 e0 36 80 00 	jmp    *0x8036e0(,%eax,4)
  800ca2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800ca5:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800ca9:	eb d9                	jmp    800c84 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800cab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800cae:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800cb2:	eb d0                	jmp    800c84 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800cb4:	0f b6 d2             	movzbl %dl,%edx
  800cb7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800cba:	b8 00 00 00 00       	mov    $0x0,%eax
  800cbf:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800cc2:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800cc5:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800cc9:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800ccc:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800ccf:	83 f9 09             	cmp    $0x9,%ecx
  800cd2:	77 55                	ja     800d29 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800cd4:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800cd7:	eb e9                	jmp    800cc2 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  800cd9:	8b 45 14             	mov    0x14(%ebp),%eax
  800cdc:	8b 00                	mov    (%eax),%eax
  800cde:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800ce1:	8b 45 14             	mov    0x14(%ebp),%eax
  800ce4:	8d 40 04             	lea    0x4(%eax),%eax
  800ce7:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800cea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800ced:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800cf1:	79 91                	jns    800c84 <vprintfmt+0x35>
				width = precision, precision = -1;
  800cf3:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800cf6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800cf9:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800d00:	eb 82                	jmp    800c84 <vprintfmt+0x35>
  800d02:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800d05:	85 c0                	test   %eax,%eax
  800d07:	ba 00 00 00 00       	mov    $0x0,%edx
  800d0c:	0f 49 d0             	cmovns %eax,%edx
  800d0f:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800d12:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800d15:	e9 6a ff ff ff       	jmp    800c84 <vprintfmt+0x35>
  800d1a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800d1d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800d24:	e9 5b ff ff ff       	jmp    800c84 <vprintfmt+0x35>
  800d29:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800d2c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800d2f:	eb bc                	jmp    800ced <vprintfmt+0x9e>
			lflag++;
  800d31:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800d34:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800d37:	e9 48 ff ff ff       	jmp    800c84 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  800d3c:	8b 45 14             	mov    0x14(%ebp),%eax
  800d3f:	8d 78 04             	lea    0x4(%eax),%edi
  800d42:	83 ec 08             	sub    $0x8,%esp
  800d45:	53                   	push   %ebx
  800d46:	ff 30                	pushl  (%eax)
  800d48:	ff d6                	call   *%esi
			break;
  800d4a:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800d4d:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800d50:	e9 cf 02 00 00       	jmp    801024 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  800d55:	8b 45 14             	mov    0x14(%ebp),%eax
  800d58:	8d 78 04             	lea    0x4(%eax),%edi
  800d5b:	8b 00                	mov    (%eax),%eax
  800d5d:	99                   	cltd   
  800d5e:	31 d0                	xor    %edx,%eax
  800d60:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800d62:	83 f8 0f             	cmp    $0xf,%eax
  800d65:	7f 23                	jg     800d8a <vprintfmt+0x13b>
  800d67:	8b 14 85 40 38 80 00 	mov    0x803840(,%eax,4),%edx
  800d6e:	85 d2                	test   %edx,%edx
  800d70:	74 18                	je     800d8a <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800d72:	52                   	push   %edx
  800d73:	68 be 34 80 00       	push   $0x8034be
  800d78:	53                   	push   %ebx
  800d79:	56                   	push   %esi
  800d7a:	e8 b3 fe ff ff       	call   800c32 <printfmt>
  800d7f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800d82:	89 7d 14             	mov    %edi,0x14(%ebp)
  800d85:	e9 9a 02 00 00       	jmp    801024 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  800d8a:	50                   	push   %eax
  800d8b:	68 b7 35 80 00       	push   $0x8035b7
  800d90:	53                   	push   %ebx
  800d91:	56                   	push   %esi
  800d92:	e8 9b fe ff ff       	call   800c32 <printfmt>
  800d97:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800d9a:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800d9d:	e9 82 02 00 00       	jmp    801024 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  800da2:	8b 45 14             	mov    0x14(%ebp),%eax
  800da5:	83 c0 04             	add    $0x4,%eax
  800da8:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800dab:	8b 45 14             	mov    0x14(%ebp),%eax
  800dae:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800db0:	85 ff                	test   %edi,%edi
  800db2:	b8 b0 35 80 00       	mov    $0x8035b0,%eax
  800db7:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800dba:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800dbe:	0f 8e bd 00 00 00    	jle    800e81 <vprintfmt+0x232>
  800dc4:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800dc8:	75 0e                	jne    800dd8 <vprintfmt+0x189>
  800dca:	89 75 08             	mov    %esi,0x8(%ebp)
  800dcd:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800dd0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800dd3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800dd6:	eb 6d                	jmp    800e45 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  800dd8:	83 ec 08             	sub    $0x8,%esp
  800ddb:	ff 75 d0             	pushl  -0x30(%ebp)
  800dde:	57                   	push   %edi
  800ddf:	e8 5e 04 00 00       	call   801242 <strnlen>
  800de4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800de7:	29 c1                	sub    %eax,%ecx
  800de9:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800dec:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800def:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800df3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800df6:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800df9:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800dfb:	eb 0f                	jmp    800e0c <vprintfmt+0x1bd>
					putch(padc, putdat);
  800dfd:	83 ec 08             	sub    $0x8,%esp
  800e00:	53                   	push   %ebx
  800e01:	ff 75 e0             	pushl  -0x20(%ebp)
  800e04:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800e06:	83 ef 01             	sub    $0x1,%edi
  800e09:	83 c4 10             	add    $0x10,%esp
  800e0c:	85 ff                	test   %edi,%edi
  800e0e:	7f ed                	jg     800dfd <vprintfmt+0x1ae>
  800e10:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800e13:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800e16:	85 c9                	test   %ecx,%ecx
  800e18:	b8 00 00 00 00       	mov    $0x0,%eax
  800e1d:	0f 49 c1             	cmovns %ecx,%eax
  800e20:	29 c1                	sub    %eax,%ecx
  800e22:	89 75 08             	mov    %esi,0x8(%ebp)
  800e25:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e28:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e2b:	89 cb                	mov    %ecx,%ebx
  800e2d:	eb 16                	jmp    800e45 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  800e2f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800e33:	75 31                	jne    800e66 <vprintfmt+0x217>
					putch(ch, putdat);
  800e35:	83 ec 08             	sub    $0x8,%esp
  800e38:	ff 75 0c             	pushl  0xc(%ebp)
  800e3b:	50                   	push   %eax
  800e3c:	ff 55 08             	call   *0x8(%ebp)
  800e3f:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e42:	83 eb 01             	sub    $0x1,%ebx
  800e45:	83 c7 01             	add    $0x1,%edi
  800e48:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800e4c:	0f be c2             	movsbl %dl,%eax
  800e4f:	85 c0                	test   %eax,%eax
  800e51:	74 59                	je     800eac <vprintfmt+0x25d>
  800e53:	85 f6                	test   %esi,%esi
  800e55:	78 d8                	js     800e2f <vprintfmt+0x1e0>
  800e57:	83 ee 01             	sub    $0x1,%esi
  800e5a:	79 d3                	jns    800e2f <vprintfmt+0x1e0>
  800e5c:	89 df                	mov    %ebx,%edi
  800e5e:	8b 75 08             	mov    0x8(%ebp),%esi
  800e61:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e64:	eb 37                	jmp    800e9d <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  800e66:	0f be d2             	movsbl %dl,%edx
  800e69:	83 ea 20             	sub    $0x20,%edx
  800e6c:	83 fa 5e             	cmp    $0x5e,%edx
  800e6f:	76 c4                	jbe    800e35 <vprintfmt+0x1e6>
					putch('?', putdat);
  800e71:	83 ec 08             	sub    $0x8,%esp
  800e74:	ff 75 0c             	pushl  0xc(%ebp)
  800e77:	6a 3f                	push   $0x3f
  800e79:	ff 55 08             	call   *0x8(%ebp)
  800e7c:	83 c4 10             	add    $0x10,%esp
  800e7f:	eb c1                	jmp    800e42 <vprintfmt+0x1f3>
  800e81:	89 75 08             	mov    %esi,0x8(%ebp)
  800e84:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e87:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e8a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800e8d:	eb b6                	jmp    800e45 <vprintfmt+0x1f6>
				putch(' ', putdat);
  800e8f:	83 ec 08             	sub    $0x8,%esp
  800e92:	53                   	push   %ebx
  800e93:	6a 20                	push   $0x20
  800e95:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800e97:	83 ef 01             	sub    $0x1,%edi
  800e9a:	83 c4 10             	add    $0x10,%esp
  800e9d:	85 ff                	test   %edi,%edi
  800e9f:	7f ee                	jg     800e8f <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800ea1:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800ea4:	89 45 14             	mov    %eax,0x14(%ebp)
  800ea7:	e9 78 01 00 00       	jmp    801024 <vprintfmt+0x3d5>
  800eac:	89 df                	mov    %ebx,%edi
  800eae:	8b 75 08             	mov    0x8(%ebp),%esi
  800eb1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800eb4:	eb e7                	jmp    800e9d <vprintfmt+0x24e>
	if (lflag >= 2)
  800eb6:	83 f9 01             	cmp    $0x1,%ecx
  800eb9:	7e 3f                	jle    800efa <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800ebb:	8b 45 14             	mov    0x14(%ebp),%eax
  800ebe:	8b 50 04             	mov    0x4(%eax),%edx
  800ec1:	8b 00                	mov    (%eax),%eax
  800ec3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ec6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800ec9:	8b 45 14             	mov    0x14(%ebp),%eax
  800ecc:	8d 40 08             	lea    0x8(%eax),%eax
  800ecf:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800ed2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800ed6:	79 5c                	jns    800f34 <vprintfmt+0x2e5>
				putch('-', putdat);
  800ed8:	83 ec 08             	sub    $0x8,%esp
  800edb:	53                   	push   %ebx
  800edc:	6a 2d                	push   $0x2d
  800ede:	ff d6                	call   *%esi
				num = -(long long) num;
  800ee0:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800ee3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800ee6:	f7 da                	neg    %edx
  800ee8:	83 d1 00             	adc    $0x0,%ecx
  800eeb:	f7 d9                	neg    %ecx
  800eed:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800ef0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ef5:	e9 10 01 00 00       	jmp    80100a <vprintfmt+0x3bb>
	else if (lflag)
  800efa:	85 c9                	test   %ecx,%ecx
  800efc:	75 1b                	jne    800f19 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800efe:	8b 45 14             	mov    0x14(%ebp),%eax
  800f01:	8b 00                	mov    (%eax),%eax
  800f03:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800f06:	89 c1                	mov    %eax,%ecx
  800f08:	c1 f9 1f             	sar    $0x1f,%ecx
  800f0b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800f0e:	8b 45 14             	mov    0x14(%ebp),%eax
  800f11:	8d 40 04             	lea    0x4(%eax),%eax
  800f14:	89 45 14             	mov    %eax,0x14(%ebp)
  800f17:	eb b9                	jmp    800ed2 <vprintfmt+0x283>
		return va_arg(*ap, long);
  800f19:	8b 45 14             	mov    0x14(%ebp),%eax
  800f1c:	8b 00                	mov    (%eax),%eax
  800f1e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800f21:	89 c1                	mov    %eax,%ecx
  800f23:	c1 f9 1f             	sar    $0x1f,%ecx
  800f26:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800f29:	8b 45 14             	mov    0x14(%ebp),%eax
  800f2c:	8d 40 04             	lea    0x4(%eax),%eax
  800f2f:	89 45 14             	mov    %eax,0x14(%ebp)
  800f32:	eb 9e                	jmp    800ed2 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  800f34:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800f37:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800f3a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f3f:	e9 c6 00 00 00       	jmp    80100a <vprintfmt+0x3bb>
	if (lflag >= 2)
  800f44:	83 f9 01             	cmp    $0x1,%ecx
  800f47:	7e 18                	jle    800f61 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  800f49:	8b 45 14             	mov    0x14(%ebp),%eax
  800f4c:	8b 10                	mov    (%eax),%edx
  800f4e:	8b 48 04             	mov    0x4(%eax),%ecx
  800f51:	8d 40 08             	lea    0x8(%eax),%eax
  800f54:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800f57:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f5c:	e9 a9 00 00 00       	jmp    80100a <vprintfmt+0x3bb>
	else if (lflag)
  800f61:	85 c9                	test   %ecx,%ecx
  800f63:	75 1a                	jne    800f7f <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  800f65:	8b 45 14             	mov    0x14(%ebp),%eax
  800f68:	8b 10                	mov    (%eax),%edx
  800f6a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f6f:	8d 40 04             	lea    0x4(%eax),%eax
  800f72:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800f75:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f7a:	e9 8b 00 00 00       	jmp    80100a <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800f7f:	8b 45 14             	mov    0x14(%ebp),%eax
  800f82:	8b 10                	mov    (%eax),%edx
  800f84:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f89:	8d 40 04             	lea    0x4(%eax),%eax
  800f8c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800f8f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f94:	eb 74                	jmp    80100a <vprintfmt+0x3bb>
	if (lflag >= 2)
  800f96:	83 f9 01             	cmp    $0x1,%ecx
  800f99:	7e 15                	jle    800fb0 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  800f9b:	8b 45 14             	mov    0x14(%ebp),%eax
  800f9e:	8b 10                	mov    (%eax),%edx
  800fa0:	8b 48 04             	mov    0x4(%eax),%ecx
  800fa3:	8d 40 08             	lea    0x8(%eax),%eax
  800fa6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800fa9:	b8 08 00 00 00       	mov    $0x8,%eax
  800fae:	eb 5a                	jmp    80100a <vprintfmt+0x3bb>
	else if (lflag)
  800fb0:	85 c9                	test   %ecx,%ecx
  800fb2:	75 17                	jne    800fcb <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  800fb4:	8b 45 14             	mov    0x14(%ebp),%eax
  800fb7:	8b 10                	mov    (%eax),%edx
  800fb9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fbe:	8d 40 04             	lea    0x4(%eax),%eax
  800fc1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800fc4:	b8 08 00 00 00       	mov    $0x8,%eax
  800fc9:	eb 3f                	jmp    80100a <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800fcb:	8b 45 14             	mov    0x14(%ebp),%eax
  800fce:	8b 10                	mov    (%eax),%edx
  800fd0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fd5:	8d 40 04             	lea    0x4(%eax),%eax
  800fd8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800fdb:	b8 08 00 00 00       	mov    $0x8,%eax
  800fe0:	eb 28                	jmp    80100a <vprintfmt+0x3bb>
			putch('0', putdat);
  800fe2:	83 ec 08             	sub    $0x8,%esp
  800fe5:	53                   	push   %ebx
  800fe6:	6a 30                	push   $0x30
  800fe8:	ff d6                	call   *%esi
			putch('x', putdat);
  800fea:	83 c4 08             	add    $0x8,%esp
  800fed:	53                   	push   %ebx
  800fee:	6a 78                	push   $0x78
  800ff0:	ff d6                	call   *%esi
			num = (unsigned long long)
  800ff2:	8b 45 14             	mov    0x14(%ebp),%eax
  800ff5:	8b 10                	mov    (%eax),%edx
  800ff7:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800ffc:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800fff:	8d 40 04             	lea    0x4(%eax),%eax
  801002:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801005:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80100a:	83 ec 0c             	sub    $0xc,%esp
  80100d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801011:	57                   	push   %edi
  801012:	ff 75 e0             	pushl  -0x20(%ebp)
  801015:	50                   	push   %eax
  801016:	51                   	push   %ecx
  801017:	52                   	push   %edx
  801018:	89 da                	mov    %ebx,%edx
  80101a:	89 f0                	mov    %esi,%eax
  80101c:	e8 45 fb ff ff       	call   800b66 <printnum>
			break;
  801021:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  801024:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801027:	83 c7 01             	add    $0x1,%edi
  80102a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80102e:	83 f8 25             	cmp    $0x25,%eax
  801031:	0f 84 2f fc ff ff    	je     800c66 <vprintfmt+0x17>
			if (ch == '\0')
  801037:	85 c0                	test   %eax,%eax
  801039:	0f 84 8b 00 00 00    	je     8010ca <vprintfmt+0x47b>
			putch(ch, putdat);
  80103f:	83 ec 08             	sub    $0x8,%esp
  801042:	53                   	push   %ebx
  801043:	50                   	push   %eax
  801044:	ff d6                	call   *%esi
  801046:	83 c4 10             	add    $0x10,%esp
  801049:	eb dc                	jmp    801027 <vprintfmt+0x3d8>
	if (lflag >= 2)
  80104b:	83 f9 01             	cmp    $0x1,%ecx
  80104e:	7e 15                	jle    801065 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  801050:	8b 45 14             	mov    0x14(%ebp),%eax
  801053:	8b 10                	mov    (%eax),%edx
  801055:	8b 48 04             	mov    0x4(%eax),%ecx
  801058:	8d 40 08             	lea    0x8(%eax),%eax
  80105b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80105e:	b8 10 00 00 00       	mov    $0x10,%eax
  801063:	eb a5                	jmp    80100a <vprintfmt+0x3bb>
	else if (lflag)
  801065:	85 c9                	test   %ecx,%ecx
  801067:	75 17                	jne    801080 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  801069:	8b 45 14             	mov    0x14(%ebp),%eax
  80106c:	8b 10                	mov    (%eax),%edx
  80106e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801073:	8d 40 04             	lea    0x4(%eax),%eax
  801076:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801079:	b8 10 00 00 00       	mov    $0x10,%eax
  80107e:	eb 8a                	jmp    80100a <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  801080:	8b 45 14             	mov    0x14(%ebp),%eax
  801083:	8b 10                	mov    (%eax),%edx
  801085:	b9 00 00 00 00       	mov    $0x0,%ecx
  80108a:	8d 40 04             	lea    0x4(%eax),%eax
  80108d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801090:	b8 10 00 00 00       	mov    $0x10,%eax
  801095:	e9 70 ff ff ff       	jmp    80100a <vprintfmt+0x3bb>
			putch(ch, putdat);
  80109a:	83 ec 08             	sub    $0x8,%esp
  80109d:	53                   	push   %ebx
  80109e:	6a 25                	push   $0x25
  8010a0:	ff d6                	call   *%esi
			break;
  8010a2:	83 c4 10             	add    $0x10,%esp
  8010a5:	e9 7a ff ff ff       	jmp    801024 <vprintfmt+0x3d5>
			putch('%', putdat);
  8010aa:	83 ec 08             	sub    $0x8,%esp
  8010ad:	53                   	push   %ebx
  8010ae:	6a 25                	push   $0x25
  8010b0:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8010b2:	83 c4 10             	add    $0x10,%esp
  8010b5:	89 f8                	mov    %edi,%eax
  8010b7:	eb 03                	jmp    8010bc <vprintfmt+0x46d>
  8010b9:	83 e8 01             	sub    $0x1,%eax
  8010bc:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8010c0:	75 f7                	jne    8010b9 <vprintfmt+0x46a>
  8010c2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010c5:	e9 5a ff ff ff       	jmp    801024 <vprintfmt+0x3d5>
}
  8010ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010cd:	5b                   	pop    %ebx
  8010ce:	5e                   	pop    %esi
  8010cf:	5f                   	pop    %edi
  8010d0:	5d                   	pop    %ebp
  8010d1:	c3                   	ret    

008010d2 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8010d2:	55                   	push   %ebp
  8010d3:	89 e5                	mov    %esp,%ebp
  8010d5:	83 ec 18             	sub    $0x18,%esp
  8010d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8010db:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8010de:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8010e1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8010e5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8010e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8010ef:	85 c0                	test   %eax,%eax
  8010f1:	74 26                	je     801119 <vsnprintf+0x47>
  8010f3:	85 d2                	test   %edx,%edx
  8010f5:	7e 22                	jle    801119 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8010f7:	ff 75 14             	pushl  0x14(%ebp)
  8010fa:	ff 75 10             	pushl  0x10(%ebp)
  8010fd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801100:	50                   	push   %eax
  801101:	68 15 0c 80 00       	push   $0x800c15
  801106:	e8 44 fb ff ff       	call   800c4f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80110b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80110e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801111:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801114:	83 c4 10             	add    $0x10,%esp
}
  801117:	c9                   	leave  
  801118:	c3                   	ret    
		return -E_INVAL;
  801119:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80111e:	eb f7                	jmp    801117 <vsnprintf+0x45>

00801120 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801120:	55                   	push   %ebp
  801121:	89 e5                	mov    %esp,%ebp
  801123:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801126:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801129:	50                   	push   %eax
  80112a:	ff 75 10             	pushl  0x10(%ebp)
  80112d:	ff 75 0c             	pushl  0xc(%ebp)
  801130:	ff 75 08             	pushl  0x8(%ebp)
  801133:	e8 9a ff ff ff       	call   8010d2 <vsnprintf>
	va_end(ap);

	return rc;
}
  801138:	c9                   	leave  
  801139:	c3                   	ret    

0080113a <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  80113a:	55                   	push   %ebp
  80113b:	89 e5                	mov    %esp,%ebp
  80113d:	57                   	push   %edi
  80113e:	56                   	push   %esi
  80113f:	53                   	push   %ebx
  801140:	83 ec 0c             	sub    $0xc,%esp
  801143:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  801146:	85 c0                	test   %eax,%eax
  801148:	74 13                	je     80115d <readline+0x23>
		fprintf(1, "%s", prompt);
  80114a:	83 ec 04             	sub    $0x4,%esp
  80114d:	50                   	push   %eax
  80114e:	68 be 34 80 00       	push   $0x8034be
  801153:	6a 01                	push   $0x1
  801155:	e8 1f 14 00 00       	call   802579 <fprintf>
  80115a:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  80115d:	83 ec 0c             	sub    $0xc,%esp
  801160:	6a 00                	push   $0x0
  801162:	e8 32 f8 ff ff       	call   800999 <iscons>
  801167:	89 c7                	mov    %eax,%edi
  801169:	83 c4 10             	add    $0x10,%esp
	i = 0;
  80116c:	be 00 00 00 00       	mov    $0x0,%esi
  801171:	eb 4b                	jmp    8011be <readline+0x84>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  801173:	b8 00 00 00 00       	mov    $0x0,%eax
			if (c != -E_EOF)
  801178:	83 fb f8             	cmp    $0xfffffff8,%ebx
  80117b:	75 08                	jne    801185 <readline+0x4b>
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
  80117d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801180:	5b                   	pop    %ebx
  801181:	5e                   	pop    %esi
  801182:	5f                   	pop    %edi
  801183:	5d                   	pop    %ebp
  801184:	c3                   	ret    
				cprintf("read error: %e\n", c);
  801185:	83 ec 08             	sub    $0x8,%esp
  801188:	53                   	push   %ebx
  801189:	68 9f 38 80 00       	push   $0x80389f
  80118e:	e8 bf f9 ff ff       	call   800b52 <cprintf>
  801193:	83 c4 10             	add    $0x10,%esp
			return NULL;
  801196:	b8 00 00 00 00       	mov    $0x0,%eax
  80119b:	eb e0                	jmp    80117d <readline+0x43>
			if (echoing)
  80119d:	85 ff                	test   %edi,%edi
  80119f:	75 05                	jne    8011a6 <readline+0x6c>
			i--;
  8011a1:	83 ee 01             	sub    $0x1,%esi
  8011a4:	eb 18                	jmp    8011be <readline+0x84>
				cputchar('\b');
  8011a6:	83 ec 0c             	sub    $0xc,%esp
  8011a9:	6a 08                	push   $0x8
  8011ab:	e8 a2 f7 ff ff       	call   800952 <cputchar>
  8011b0:	83 c4 10             	add    $0x10,%esp
  8011b3:	eb ec                	jmp    8011a1 <readline+0x67>
			buf[i++] = c;
  8011b5:	88 9e 20 50 80 00    	mov    %bl,0x805020(%esi)
  8011bb:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
  8011be:	e8 ab f7 ff ff       	call   80096e <getchar>
  8011c3:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  8011c5:	85 c0                	test   %eax,%eax
  8011c7:	78 aa                	js     801173 <readline+0x39>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  8011c9:	83 f8 08             	cmp    $0x8,%eax
  8011cc:	0f 94 c2             	sete   %dl
  8011cf:	83 f8 7f             	cmp    $0x7f,%eax
  8011d2:	0f 94 c0             	sete   %al
  8011d5:	08 c2                	or     %al,%dl
  8011d7:	74 04                	je     8011dd <readline+0xa3>
  8011d9:	85 f6                	test   %esi,%esi
  8011db:	7f c0                	jg     80119d <readline+0x63>
		} else if (c >= ' ' && i < BUFLEN-1) {
  8011dd:	83 fb 1f             	cmp    $0x1f,%ebx
  8011e0:	7e 1a                	jle    8011fc <readline+0xc2>
  8011e2:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  8011e8:	7f 12                	jg     8011fc <readline+0xc2>
			if (echoing)
  8011ea:	85 ff                	test   %edi,%edi
  8011ec:	74 c7                	je     8011b5 <readline+0x7b>
				cputchar(c);
  8011ee:	83 ec 0c             	sub    $0xc,%esp
  8011f1:	53                   	push   %ebx
  8011f2:	e8 5b f7 ff ff       	call   800952 <cputchar>
  8011f7:	83 c4 10             	add    $0x10,%esp
  8011fa:	eb b9                	jmp    8011b5 <readline+0x7b>
		} else if (c == '\n' || c == '\r') {
  8011fc:	83 fb 0a             	cmp    $0xa,%ebx
  8011ff:	74 05                	je     801206 <readline+0xcc>
  801201:	83 fb 0d             	cmp    $0xd,%ebx
  801204:	75 b8                	jne    8011be <readline+0x84>
			if (echoing)
  801206:	85 ff                	test   %edi,%edi
  801208:	75 11                	jne    80121b <readline+0xe1>
			buf[i] = 0;
  80120a:	c6 86 20 50 80 00 00 	movb   $0x0,0x805020(%esi)
			return buf;
  801211:	b8 20 50 80 00       	mov    $0x805020,%eax
  801216:	e9 62 ff ff ff       	jmp    80117d <readline+0x43>
				cputchar('\n');
  80121b:	83 ec 0c             	sub    $0xc,%esp
  80121e:	6a 0a                	push   $0xa
  801220:	e8 2d f7 ff ff       	call   800952 <cputchar>
  801225:	83 c4 10             	add    $0x10,%esp
  801228:	eb e0                	jmp    80120a <readline+0xd0>

0080122a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80122a:	55                   	push   %ebp
  80122b:	89 e5                	mov    %esp,%ebp
  80122d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801230:	b8 00 00 00 00       	mov    $0x0,%eax
  801235:	eb 03                	jmp    80123a <strlen+0x10>
		n++;
  801237:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80123a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80123e:	75 f7                	jne    801237 <strlen+0xd>
	return n;
}
  801240:	5d                   	pop    %ebp
  801241:	c3                   	ret    

00801242 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801242:	55                   	push   %ebp
  801243:	89 e5                	mov    %esp,%ebp
  801245:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801248:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80124b:	b8 00 00 00 00       	mov    $0x0,%eax
  801250:	eb 03                	jmp    801255 <strnlen+0x13>
		n++;
  801252:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801255:	39 d0                	cmp    %edx,%eax
  801257:	74 06                	je     80125f <strnlen+0x1d>
  801259:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80125d:	75 f3                	jne    801252 <strnlen+0x10>
	return n;
}
  80125f:	5d                   	pop    %ebp
  801260:	c3                   	ret    

00801261 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801261:	55                   	push   %ebp
  801262:	89 e5                	mov    %esp,%ebp
  801264:	53                   	push   %ebx
  801265:	8b 45 08             	mov    0x8(%ebp),%eax
  801268:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80126b:	89 c2                	mov    %eax,%edx
  80126d:	83 c1 01             	add    $0x1,%ecx
  801270:	83 c2 01             	add    $0x1,%edx
  801273:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801277:	88 5a ff             	mov    %bl,-0x1(%edx)
  80127a:	84 db                	test   %bl,%bl
  80127c:	75 ef                	jne    80126d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80127e:	5b                   	pop    %ebx
  80127f:	5d                   	pop    %ebp
  801280:	c3                   	ret    

00801281 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801281:	55                   	push   %ebp
  801282:	89 e5                	mov    %esp,%ebp
  801284:	53                   	push   %ebx
  801285:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801288:	53                   	push   %ebx
  801289:	e8 9c ff ff ff       	call   80122a <strlen>
  80128e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801291:	ff 75 0c             	pushl  0xc(%ebp)
  801294:	01 d8                	add    %ebx,%eax
  801296:	50                   	push   %eax
  801297:	e8 c5 ff ff ff       	call   801261 <strcpy>
	return dst;
}
  80129c:	89 d8                	mov    %ebx,%eax
  80129e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012a1:	c9                   	leave  
  8012a2:	c3                   	ret    

008012a3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8012a3:	55                   	push   %ebp
  8012a4:	89 e5                	mov    %esp,%ebp
  8012a6:	56                   	push   %esi
  8012a7:	53                   	push   %ebx
  8012a8:	8b 75 08             	mov    0x8(%ebp),%esi
  8012ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012ae:	89 f3                	mov    %esi,%ebx
  8012b0:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8012b3:	89 f2                	mov    %esi,%edx
  8012b5:	eb 0f                	jmp    8012c6 <strncpy+0x23>
		*dst++ = *src;
  8012b7:	83 c2 01             	add    $0x1,%edx
  8012ba:	0f b6 01             	movzbl (%ecx),%eax
  8012bd:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8012c0:	80 39 01             	cmpb   $0x1,(%ecx)
  8012c3:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8012c6:	39 da                	cmp    %ebx,%edx
  8012c8:	75 ed                	jne    8012b7 <strncpy+0x14>
	}
	return ret;
}
  8012ca:	89 f0                	mov    %esi,%eax
  8012cc:	5b                   	pop    %ebx
  8012cd:	5e                   	pop    %esi
  8012ce:	5d                   	pop    %ebp
  8012cf:	c3                   	ret    

008012d0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8012d0:	55                   	push   %ebp
  8012d1:	89 e5                	mov    %esp,%ebp
  8012d3:	56                   	push   %esi
  8012d4:	53                   	push   %ebx
  8012d5:	8b 75 08             	mov    0x8(%ebp),%esi
  8012d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012db:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8012de:	89 f0                	mov    %esi,%eax
  8012e0:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8012e4:	85 c9                	test   %ecx,%ecx
  8012e6:	75 0b                	jne    8012f3 <strlcpy+0x23>
  8012e8:	eb 17                	jmp    801301 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8012ea:	83 c2 01             	add    $0x1,%edx
  8012ed:	83 c0 01             	add    $0x1,%eax
  8012f0:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8012f3:	39 d8                	cmp    %ebx,%eax
  8012f5:	74 07                	je     8012fe <strlcpy+0x2e>
  8012f7:	0f b6 0a             	movzbl (%edx),%ecx
  8012fa:	84 c9                	test   %cl,%cl
  8012fc:	75 ec                	jne    8012ea <strlcpy+0x1a>
		*dst = '\0';
  8012fe:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801301:	29 f0                	sub    %esi,%eax
}
  801303:	5b                   	pop    %ebx
  801304:	5e                   	pop    %esi
  801305:	5d                   	pop    %ebp
  801306:	c3                   	ret    

00801307 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801307:	55                   	push   %ebp
  801308:	89 e5                	mov    %esp,%ebp
  80130a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80130d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801310:	eb 06                	jmp    801318 <strcmp+0x11>
		p++, q++;
  801312:	83 c1 01             	add    $0x1,%ecx
  801315:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  801318:	0f b6 01             	movzbl (%ecx),%eax
  80131b:	84 c0                	test   %al,%al
  80131d:	74 04                	je     801323 <strcmp+0x1c>
  80131f:	3a 02                	cmp    (%edx),%al
  801321:	74 ef                	je     801312 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801323:	0f b6 c0             	movzbl %al,%eax
  801326:	0f b6 12             	movzbl (%edx),%edx
  801329:	29 d0                	sub    %edx,%eax
}
  80132b:	5d                   	pop    %ebp
  80132c:	c3                   	ret    

0080132d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80132d:	55                   	push   %ebp
  80132e:	89 e5                	mov    %esp,%ebp
  801330:	53                   	push   %ebx
  801331:	8b 45 08             	mov    0x8(%ebp),%eax
  801334:	8b 55 0c             	mov    0xc(%ebp),%edx
  801337:	89 c3                	mov    %eax,%ebx
  801339:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80133c:	eb 06                	jmp    801344 <strncmp+0x17>
		n--, p++, q++;
  80133e:	83 c0 01             	add    $0x1,%eax
  801341:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  801344:	39 d8                	cmp    %ebx,%eax
  801346:	74 16                	je     80135e <strncmp+0x31>
  801348:	0f b6 08             	movzbl (%eax),%ecx
  80134b:	84 c9                	test   %cl,%cl
  80134d:	74 04                	je     801353 <strncmp+0x26>
  80134f:	3a 0a                	cmp    (%edx),%cl
  801351:	74 eb                	je     80133e <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801353:	0f b6 00             	movzbl (%eax),%eax
  801356:	0f b6 12             	movzbl (%edx),%edx
  801359:	29 d0                	sub    %edx,%eax
}
  80135b:	5b                   	pop    %ebx
  80135c:	5d                   	pop    %ebp
  80135d:	c3                   	ret    
		return 0;
  80135e:	b8 00 00 00 00       	mov    $0x0,%eax
  801363:	eb f6                	jmp    80135b <strncmp+0x2e>

00801365 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801365:	55                   	push   %ebp
  801366:	89 e5                	mov    %esp,%ebp
  801368:	8b 45 08             	mov    0x8(%ebp),%eax
  80136b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80136f:	0f b6 10             	movzbl (%eax),%edx
  801372:	84 d2                	test   %dl,%dl
  801374:	74 09                	je     80137f <strchr+0x1a>
		if (*s == c)
  801376:	38 ca                	cmp    %cl,%dl
  801378:	74 0a                	je     801384 <strchr+0x1f>
	for (; *s; s++)
  80137a:	83 c0 01             	add    $0x1,%eax
  80137d:	eb f0                	jmp    80136f <strchr+0xa>
			return (char *) s;
	return 0;
  80137f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801384:	5d                   	pop    %ebp
  801385:	c3                   	ret    

00801386 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801386:	55                   	push   %ebp
  801387:	89 e5                	mov    %esp,%ebp
  801389:	8b 45 08             	mov    0x8(%ebp),%eax
  80138c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801390:	eb 03                	jmp    801395 <strfind+0xf>
  801392:	83 c0 01             	add    $0x1,%eax
  801395:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801398:	38 ca                	cmp    %cl,%dl
  80139a:	74 04                	je     8013a0 <strfind+0x1a>
  80139c:	84 d2                	test   %dl,%dl
  80139e:	75 f2                	jne    801392 <strfind+0xc>
			break;
	return (char *) s;
}
  8013a0:	5d                   	pop    %ebp
  8013a1:	c3                   	ret    

008013a2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8013a2:	55                   	push   %ebp
  8013a3:	89 e5                	mov    %esp,%ebp
  8013a5:	57                   	push   %edi
  8013a6:	56                   	push   %esi
  8013a7:	53                   	push   %ebx
  8013a8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013ab:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8013ae:	85 c9                	test   %ecx,%ecx
  8013b0:	74 13                	je     8013c5 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8013b2:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8013b8:	75 05                	jne    8013bf <memset+0x1d>
  8013ba:	f6 c1 03             	test   $0x3,%cl
  8013bd:	74 0d                	je     8013cc <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8013bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013c2:	fc                   	cld    
  8013c3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8013c5:	89 f8                	mov    %edi,%eax
  8013c7:	5b                   	pop    %ebx
  8013c8:	5e                   	pop    %esi
  8013c9:	5f                   	pop    %edi
  8013ca:	5d                   	pop    %ebp
  8013cb:	c3                   	ret    
		c &= 0xFF;
  8013cc:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8013d0:	89 d3                	mov    %edx,%ebx
  8013d2:	c1 e3 08             	shl    $0x8,%ebx
  8013d5:	89 d0                	mov    %edx,%eax
  8013d7:	c1 e0 18             	shl    $0x18,%eax
  8013da:	89 d6                	mov    %edx,%esi
  8013dc:	c1 e6 10             	shl    $0x10,%esi
  8013df:	09 f0                	or     %esi,%eax
  8013e1:	09 c2                	or     %eax,%edx
  8013e3:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  8013e5:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8013e8:	89 d0                	mov    %edx,%eax
  8013ea:	fc                   	cld    
  8013eb:	f3 ab                	rep stos %eax,%es:(%edi)
  8013ed:	eb d6                	jmp    8013c5 <memset+0x23>

008013ef <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8013ef:	55                   	push   %ebp
  8013f0:	89 e5                	mov    %esp,%ebp
  8013f2:	57                   	push   %edi
  8013f3:	56                   	push   %esi
  8013f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013fa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8013fd:	39 c6                	cmp    %eax,%esi
  8013ff:	73 35                	jae    801436 <memmove+0x47>
  801401:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801404:	39 c2                	cmp    %eax,%edx
  801406:	76 2e                	jbe    801436 <memmove+0x47>
		s += n;
		d += n;
  801408:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80140b:	89 d6                	mov    %edx,%esi
  80140d:	09 fe                	or     %edi,%esi
  80140f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801415:	74 0c                	je     801423 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801417:	83 ef 01             	sub    $0x1,%edi
  80141a:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80141d:	fd                   	std    
  80141e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801420:	fc                   	cld    
  801421:	eb 21                	jmp    801444 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801423:	f6 c1 03             	test   $0x3,%cl
  801426:	75 ef                	jne    801417 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801428:	83 ef 04             	sub    $0x4,%edi
  80142b:	8d 72 fc             	lea    -0x4(%edx),%esi
  80142e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801431:	fd                   	std    
  801432:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801434:	eb ea                	jmp    801420 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801436:	89 f2                	mov    %esi,%edx
  801438:	09 c2                	or     %eax,%edx
  80143a:	f6 c2 03             	test   $0x3,%dl
  80143d:	74 09                	je     801448 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80143f:	89 c7                	mov    %eax,%edi
  801441:	fc                   	cld    
  801442:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801444:	5e                   	pop    %esi
  801445:	5f                   	pop    %edi
  801446:	5d                   	pop    %ebp
  801447:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801448:	f6 c1 03             	test   $0x3,%cl
  80144b:	75 f2                	jne    80143f <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80144d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801450:	89 c7                	mov    %eax,%edi
  801452:	fc                   	cld    
  801453:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801455:	eb ed                	jmp    801444 <memmove+0x55>

00801457 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801457:	55                   	push   %ebp
  801458:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80145a:	ff 75 10             	pushl  0x10(%ebp)
  80145d:	ff 75 0c             	pushl  0xc(%ebp)
  801460:	ff 75 08             	pushl  0x8(%ebp)
  801463:	e8 87 ff ff ff       	call   8013ef <memmove>
}
  801468:	c9                   	leave  
  801469:	c3                   	ret    

0080146a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80146a:	55                   	push   %ebp
  80146b:	89 e5                	mov    %esp,%ebp
  80146d:	56                   	push   %esi
  80146e:	53                   	push   %ebx
  80146f:	8b 45 08             	mov    0x8(%ebp),%eax
  801472:	8b 55 0c             	mov    0xc(%ebp),%edx
  801475:	89 c6                	mov    %eax,%esi
  801477:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80147a:	39 f0                	cmp    %esi,%eax
  80147c:	74 1c                	je     80149a <memcmp+0x30>
		if (*s1 != *s2)
  80147e:	0f b6 08             	movzbl (%eax),%ecx
  801481:	0f b6 1a             	movzbl (%edx),%ebx
  801484:	38 d9                	cmp    %bl,%cl
  801486:	75 08                	jne    801490 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801488:	83 c0 01             	add    $0x1,%eax
  80148b:	83 c2 01             	add    $0x1,%edx
  80148e:	eb ea                	jmp    80147a <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  801490:	0f b6 c1             	movzbl %cl,%eax
  801493:	0f b6 db             	movzbl %bl,%ebx
  801496:	29 d8                	sub    %ebx,%eax
  801498:	eb 05                	jmp    80149f <memcmp+0x35>
	}

	return 0;
  80149a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80149f:	5b                   	pop    %ebx
  8014a0:	5e                   	pop    %esi
  8014a1:	5d                   	pop    %ebp
  8014a2:	c3                   	ret    

008014a3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8014a3:	55                   	push   %ebp
  8014a4:	89 e5                	mov    %esp,%ebp
  8014a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8014ac:	89 c2                	mov    %eax,%edx
  8014ae:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8014b1:	39 d0                	cmp    %edx,%eax
  8014b3:	73 09                	jae    8014be <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8014b5:	38 08                	cmp    %cl,(%eax)
  8014b7:	74 05                	je     8014be <memfind+0x1b>
	for (; s < ends; s++)
  8014b9:	83 c0 01             	add    $0x1,%eax
  8014bc:	eb f3                	jmp    8014b1 <memfind+0xe>
			break;
	return (void *) s;
}
  8014be:	5d                   	pop    %ebp
  8014bf:	c3                   	ret    

008014c0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8014c0:	55                   	push   %ebp
  8014c1:	89 e5                	mov    %esp,%ebp
  8014c3:	57                   	push   %edi
  8014c4:	56                   	push   %esi
  8014c5:	53                   	push   %ebx
  8014c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8014cc:	eb 03                	jmp    8014d1 <strtol+0x11>
		s++;
  8014ce:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  8014d1:	0f b6 01             	movzbl (%ecx),%eax
  8014d4:	3c 20                	cmp    $0x20,%al
  8014d6:	74 f6                	je     8014ce <strtol+0xe>
  8014d8:	3c 09                	cmp    $0x9,%al
  8014da:	74 f2                	je     8014ce <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8014dc:	3c 2b                	cmp    $0x2b,%al
  8014de:	74 2e                	je     80150e <strtol+0x4e>
	int neg = 0;
  8014e0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8014e5:	3c 2d                	cmp    $0x2d,%al
  8014e7:	74 2f                	je     801518 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8014e9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8014ef:	75 05                	jne    8014f6 <strtol+0x36>
  8014f1:	80 39 30             	cmpb   $0x30,(%ecx)
  8014f4:	74 2c                	je     801522 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8014f6:	85 db                	test   %ebx,%ebx
  8014f8:	75 0a                	jne    801504 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8014fa:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  8014ff:	80 39 30             	cmpb   $0x30,(%ecx)
  801502:	74 28                	je     80152c <strtol+0x6c>
		base = 10;
  801504:	b8 00 00 00 00       	mov    $0x0,%eax
  801509:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80150c:	eb 50                	jmp    80155e <strtol+0x9e>
		s++;
  80150e:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  801511:	bf 00 00 00 00       	mov    $0x0,%edi
  801516:	eb d1                	jmp    8014e9 <strtol+0x29>
		s++, neg = 1;
  801518:	83 c1 01             	add    $0x1,%ecx
  80151b:	bf 01 00 00 00       	mov    $0x1,%edi
  801520:	eb c7                	jmp    8014e9 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801522:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801526:	74 0e                	je     801536 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801528:	85 db                	test   %ebx,%ebx
  80152a:	75 d8                	jne    801504 <strtol+0x44>
		s++, base = 8;
  80152c:	83 c1 01             	add    $0x1,%ecx
  80152f:	bb 08 00 00 00       	mov    $0x8,%ebx
  801534:	eb ce                	jmp    801504 <strtol+0x44>
		s += 2, base = 16;
  801536:	83 c1 02             	add    $0x2,%ecx
  801539:	bb 10 00 00 00       	mov    $0x10,%ebx
  80153e:	eb c4                	jmp    801504 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  801540:	8d 72 9f             	lea    -0x61(%edx),%esi
  801543:	89 f3                	mov    %esi,%ebx
  801545:	80 fb 19             	cmp    $0x19,%bl
  801548:	77 29                	ja     801573 <strtol+0xb3>
			dig = *s - 'a' + 10;
  80154a:	0f be d2             	movsbl %dl,%edx
  80154d:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801550:	3b 55 10             	cmp    0x10(%ebp),%edx
  801553:	7d 30                	jge    801585 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801555:	83 c1 01             	add    $0x1,%ecx
  801558:	0f af 45 10          	imul   0x10(%ebp),%eax
  80155c:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  80155e:	0f b6 11             	movzbl (%ecx),%edx
  801561:	8d 72 d0             	lea    -0x30(%edx),%esi
  801564:	89 f3                	mov    %esi,%ebx
  801566:	80 fb 09             	cmp    $0x9,%bl
  801569:	77 d5                	ja     801540 <strtol+0x80>
			dig = *s - '0';
  80156b:	0f be d2             	movsbl %dl,%edx
  80156e:	83 ea 30             	sub    $0x30,%edx
  801571:	eb dd                	jmp    801550 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  801573:	8d 72 bf             	lea    -0x41(%edx),%esi
  801576:	89 f3                	mov    %esi,%ebx
  801578:	80 fb 19             	cmp    $0x19,%bl
  80157b:	77 08                	ja     801585 <strtol+0xc5>
			dig = *s - 'A' + 10;
  80157d:	0f be d2             	movsbl %dl,%edx
  801580:	83 ea 37             	sub    $0x37,%edx
  801583:	eb cb                	jmp    801550 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  801585:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801589:	74 05                	je     801590 <strtol+0xd0>
		*endptr = (char *) s;
  80158b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80158e:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801590:	89 c2                	mov    %eax,%edx
  801592:	f7 da                	neg    %edx
  801594:	85 ff                	test   %edi,%edi
  801596:	0f 45 c2             	cmovne %edx,%eax
}
  801599:	5b                   	pop    %ebx
  80159a:	5e                   	pop    %esi
  80159b:	5f                   	pop    %edi
  80159c:	5d                   	pop    %ebp
  80159d:	c3                   	ret    

0080159e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80159e:	55                   	push   %ebp
  80159f:	89 e5                	mov    %esp,%ebp
  8015a1:	57                   	push   %edi
  8015a2:	56                   	push   %esi
  8015a3:	53                   	push   %ebx
	asm volatile("int %1\n"
  8015a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8015a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8015ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015af:	89 c3                	mov    %eax,%ebx
  8015b1:	89 c7                	mov    %eax,%edi
  8015b3:	89 c6                	mov    %eax,%esi
  8015b5:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8015b7:	5b                   	pop    %ebx
  8015b8:	5e                   	pop    %esi
  8015b9:	5f                   	pop    %edi
  8015ba:	5d                   	pop    %ebp
  8015bb:	c3                   	ret    

008015bc <sys_cgetc>:

int
sys_cgetc(void)
{
  8015bc:	55                   	push   %ebp
  8015bd:	89 e5                	mov    %esp,%ebp
  8015bf:	57                   	push   %edi
  8015c0:	56                   	push   %esi
  8015c1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8015c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8015c7:	b8 01 00 00 00       	mov    $0x1,%eax
  8015cc:	89 d1                	mov    %edx,%ecx
  8015ce:	89 d3                	mov    %edx,%ebx
  8015d0:	89 d7                	mov    %edx,%edi
  8015d2:	89 d6                	mov    %edx,%esi
  8015d4:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8015d6:	5b                   	pop    %ebx
  8015d7:	5e                   	pop    %esi
  8015d8:	5f                   	pop    %edi
  8015d9:	5d                   	pop    %ebp
  8015da:	c3                   	ret    

008015db <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8015db:	55                   	push   %ebp
  8015dc:	89 e5                	mov    %esp,%ebp
  8015de:	57                   	push   %edi
  8015df:	56                   	push   %esi
  8015e0:	53                   	push   %ebx
  8015e1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8015e4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8015ec:	b8 03 00 00 00       	mov    $0x3,%eax
  8015f1:	89 cb                	mov    %ecx,%ebx
  8015f3:	89 cf                	mov    %ecx,%edi
  8015f5:	89 ce                	mov    %ecx,%esi
  8015f7:	cd 30                	int    $0x30
	if(check && ret > 0)
  8015f9:	85 c0                	test   %eax,%eax
  8015fb:	7f 08                	jg     801605 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8015fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801600:	5b                   	pop    %ebx
  801601:	5e                   	pop    %esi
  801602:	5f                   	pop    %edi
  801603:	5d                   	pop    %ebp
  801604:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801605:	83 ec 0c             	sub    $0xc,%esp
  801608:	50                   	push   %eax
  801609:	6a 03                	push   $0x3
  80160b:	68 af 38 80 00       	push   $0x8038af
  801610:	6a 23                	push   $0x23
  801612:	68 cc 38 80 00       	push   $0x8038cc
  801617:	e8 5b f4 ff ff       	call   800a77 <_panic>

0080161c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80161c:	55                   	push   %ebp
  80161d:	89 e5                	mov    %esp,%ebp
  80161f:	57                   	push   %edi
  801620:	56                   	push   %esi
  801621:	53                   	push   %ebx
	asm volatile("int %1\n"
  801622:	ba 00 00 00 00       	mov    $0x0,%edx
  801627:	b8 02 00 00 00       	mov    $0x2,%eax
  80162c:	89 d1                	mov    %edx,%ecx
  80162e:	89 d3                	mov    %edx,%ebx
  801630:	89 d7                	mov    %edx,%edi
  801632:	89 d6                	mov    %edx,%esi
  801634:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801636:	5b                   	pop    %ebx
  801637:	5e                   	pop    %esi
  801638:	5f                   	pop    %edi
  801639:	5d                   	pop    %ebp
  80163a:	c3                   	ret    

0080163b <sys_yield>:

void
sys_yield(void)
{
  80163b:	55                   	push   %ebp
  80163c:	89 e5                	mov    %esp,%ebp
  80163e:	57                   	push   %edi
  80163f:	56                   	push   %esi
  801640:	53                   	push   %ebx
	asm volatile("int %1\n"
  801641:	ba 00 00 00 00       	mov    $0x0,%edx
  801646:	b8 0b 00 00 00       	mov    $0xb,%eax
  80164b:	89 d1                	mov    %edx,%ecx
  80164d:	89 d3                	mov    %edx,%ebx
  80164f:	89 d7                	mov    %edx,%edi
  801651:	89 d6                	mov    %edx,%esi
  801653:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801655:	5b                   	pop    %ebx
  801656:	5e                   	pop    %esi
  801657:	5f                   	pop    %edi
  801658:	5d                   	pop    %ebp
  801659:	c3                   	ret    

0080165a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80165a:	55                   	push   %ebp
  80165b:	89 e5                	mov    %esp,%ebp
  80165d:	57                   	push   %edi
  80165e:	56                   	push   %esi
  80165f:	53                   	push   %ebx
  801660:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801663:	be 00 00 00 00       	mov    $0x0,%esi
  801668:	8b 55 08             	mov    0x8(%ebp),%edx
  80166b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80166e:	b8 04 00 00 00       	mov    $0x4,%eax
  801673:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801676:	89 f7                	mov    %esi,%edi
  801678:	cd 30                	int    $0x30
	if(check && ret > 0)
  80167a:	85 c0                	test   %eax,%eax
  80167c:	7f 08                	jg     801686 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80167e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801681:	5b                   	pop    %ebx
  801682:	5e                   	pop    %esi
  801683:	5f                   	pop    %edi
  801684:	5d                   	pop    %ebp
  801685:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801686:	83 ec 0c             	sub    $0xc,%esp
  801689:	50                   	push   %eax
  80168a:	6a 04                	push   $0x4
  80168c:	68 af 38 80 00       	push   $0x8038af
  801691:	6a 23                	push   $0x23
  801693:	68 cc 38 80 00       	push   $0x8038cc
  801698:	e8 da f3 ff ff       	call   800a77 <_panic>

0080169d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80169d:	55                   	push   %ebp
  80169e:	89 e5                	mov    %esp,%ebp
  8016a0:	57                   	push   %edi
  8016a1:	56                   	push   %esi
  8016a2:	53                   	push   %ebx
  8016a3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8016a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8016a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016ac:	b8 05 00 00 00       	mov    $0x5,%eax
  8016b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8016b4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8016b7:	8b 75 18             	mov    0x18(%ebp),%esi
  8016ba:	cd 30                	int    $0x30
	if(check && ret > 0)
  8016bc:	85 c0                	test   %eax,%eax
  8016be:	7f 08                	jg     8016c8 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8016c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016c3:	5b                   	pop    %ebx
  8016c4:	5e                   	pop    %esi
  8016c5:	5f                   	pop    %edi
  8016c6:	5d                   	pop    %ebp
  8016c7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8016c8:	83 ec 0c             	sub    $0xc,%esp
  8016cb:	50                   	push   %eax
  8016cc:	6a 05                	push   $0x5
  8016ce:	68 af 38 80 00       	push   $0x8038af
  8016d3:	6a 23                	push   $0x23
  8016d5:	68 cc 38 80 00       	push   $0x8038cc
  8016da:	e8 98 f3 ff ff       	call   800a77 <_panic>

008016df <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8016df:	55                   	push   %ebp
  8016e0:	89 e5                	mov    %esp,%ebp
  8016e2:	57                   	push   %edi
  8016e3:	56                   	push   %esi
  8016e4:	53                   	push   %ebx
  8016e5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8016e8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8016f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016f3:	b8 06 00 00 00       	mov    $0x6,%eax
  8016f8:	89 df                	mov    %ebx,%edi
  8016fa:	89 de                	mov    %ebx,%esi
  8016fc:	cd 30                	int    $0x30
	if(check && ret > 0)
  8016fe:	85 c0                	test   %eax,%eax
  801700:	7f 08                	jg     80170a <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801702:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801705:	5b                   	pop    %ebx
  801706:	5e                   	pop    %esi
  801707:	5f                   	pop    %edi
  801708:	5d                   	pop    %ebp
  801709:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80170a:	83 ec 0c             	sub    $0xc,%esp
  80170d:	50                   	push   %eax
  80170e:	6a 06                	push   $0x6
  801710:	68 af 38 80 00       	push   $0x8038af
  801715:	6a 23                	push   $0x23
  801717:	68 cc 38 80 00       	push   $0x8038cc
  80171c:	e8 56 f3 ff ff       	call   800a77 <_panic>

00801721 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801721:	55                   	push   %ebp
  801722:	89 e5                	mov    %esp,%ebp
  801724:	57                   	push   %edi
  801725:	56                   	push   %esi
  801726:	53                   	push   %ebx
  801727:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80172a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80172f:	8b 55 08             	mov    0x8(%ebp),%edx
  801732:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801735:	b8 08 00 00 00       	mov    $0x8,%eax
  80173a:	89 df                	mov    %ebx,%edi
  80173c:	89 de                	mov    %ebx,%esi
  80173e:	cd 30                	int    $0x30
	if(check && ret > 0)
  801740:	85 c0                	test   %eax,%eax
  801742:	7f 08                	jg     80174c <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801744:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801747:	5b                   	pop    %ebx
  801748:	5e                   	pop    %esi
  801749:	5f                   	pop    %edi
  80174a:	5d                   	pop    %ebp
  80174b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80174c:	83 ec 0c             	sub    $0xc,%esp
  80174f:	50                   	push   %eax
  801750:	6a 08                	push   $0x8
  801752:	68 af 38 80 00       	push   $0x8038af
  801757:	6a 23                	push   $0x23
  801759:	68 cc 38 80 00       	push   $0x8038cc
  80175e:	e8 14 f3 ff ff       	call   800a77 <_panic>

00801763 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801763:	55                   	push   %ebp
  801764:	89 e5                	mov    %esp,%ebp
  801766:	57                   	push   %edi
  801767:	56                   	push   %esi
  801768:	53                   	push   %ebx
  801769:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80176c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801771:	8b 55 08             	mov    0x8(%ebp),%edx
  801774:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801777:	b8 09 00 00 00       	mov    $0x9,%eax
  80177c:	89 df                	mov    %ebx,%edi
  80177e:	89 de                	mov    %ebx,%esi
  801780:	cd 30                	int    $0x30
	if(check && ret > 0)
  801782:	85 c0                	test   %eax,%eax
  801784:	7f 08                	jg     80178e <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801786:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801789:	5b                   	pop    %ebx
  80178a:	5e                   	pop    %esi
  80178b:	5f                   	pop    %edi
  80178c:	5d                   	pop    %ebp
  80178d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80178e:	83 ec 0c             	sub    $0xc,%esp
  801791:	50                   	push   %eax
  801792:	6a 09                	push   $0x9
  801794:	68 af 38 80 00       	push   $0x8038af
  801799:	6a 23                	push   $0x23
  80179b:	68 cc 38 80 00       	push   $0x8038cc
  8017a0:	e8 d2 f2 ff ff       	call   800a77 <_panic>

008017a5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8017a5:	55                   	push   %ebp
  8017a6:	89 e5                	mov    %esp,%ebp
  8017a8:	57                   	push   %edi
  8017a9:	56                   	push   %esi
  8017aa:	53                   	push   %ebx
  8017ab:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8017ae:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8017b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017b9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8017be:	89 df                	mov    %ebx,%edi
  8017c0:	89 de                	mov    %ebx,%esi
  8017c2:	cd 30                	int    $0x30
	if(check && ret > 0)
  8017c4:	85 c0                	test   %eax,%eax
  8017c6:	7f 08                	jg     8017d0 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8017c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017cb:	5b                   	pop    %ebx
  8017cc:	5e                   	pop    %esi
  8017cd:	5f                   	pop    %edi
  8017ce:	5d                   	pop    %ebp
  8017cf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8017d0:	83 ec 0c             	sub    $0xc,%esp
  8017d3:	50                   	push   %eax
  8017d4:	6a 0a                	push   $0xa
  8017d6:	68 af 38 80 00       	push   $0x8038af
  8017db:	6a 23                	push   $0x23
  8017dd:	68 cc 38 80 00       	push   $0x8038cc
  8017e2:	e8 90 f2 ff ff       	call   800a77 <_panic>

008017e7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8017e7:	55                   	push   %ebp
  8017e8:	89 e5                	mov    %esp,%ebp
  8017ea:	57                   	push   %edi
  8017eb:	56                   	push   %esi
  8017ec:	53                   	push   %ebx
	asm volatile("int %1\n"
  8017ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8017f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017f3:	b8 0c 00 00 00       	mov    $0xc,%eax
  8017f8:	be 00 00 00 00       	mov    $0x0,%esi
  8017fd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801800:	8b 7d 14             	mov    0x14(%ebp),%edi
  801803:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801805:	5b                   	pop    %ebx
  801806:	5e                   	pop    %esi
  801807:	5f                   	pop    %edi
  801808:	5d                   	pop    %ebp
  801809:	c3                   	ret    

0080180a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80180a:	55                   	push   %ebp
  80180b:	89 e5                	mov    %esp,%ebp
  80180d:	57                   	push   %edi
  80180e:	56                   	push   %esi
  80180f:	53                   	push   %ebx
  801810:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801813:	b9 00 00 00 00       	mov    $0x0,%ecx
  801818:	8b 55 08             	mov    0x8(%ebp),%edx
  80181b:	b8 0d 00 00 00       	mov    $0xd,%eax
  801820:	89 cb                	mov    %ecx,%ebx
  801822:	89 cf                	mov    %ecx,%edi
  801824:	89 ce                	mov    %ecx,%esi
  801826:	cd 30                	int    $0x30
	if(check && ret > 0)
  801828:	85 c0                	test   %eax,%eax
  80182a:	7f 08                	jg     801834 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80182c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80182f:	5b                   	pop    %ebx
  801830:	5e                   	pop    %esi
  801831:	5f                   	pop    %edi
  801832:	5d                   	pop    %ebp
  801833:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801834:	83 ec 0c             	sub    $0xc,%esp
  801837:	50                   	push   %eax
  801838:	6a 0d                	push   $0xd
  80183a:	68 af 38 80 00       	push   $0x8038af
  80183f:	6a 23                	push   $0x23
  801841:	68 cc 38 80 00       	push   $0x8038cc
  801846:	e8 2c f2 ff ff       	call   800a77 <_panic>

0080184b <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80184b:	55                   	push   %ebp
  80184c:	89 e5                	mov    %esp,%ebp
  80184e:	56                   	push   %esi
  80184f:	53                   	push   %ebx
  801850:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801853:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
        if((err&FEC_WR)==0 || (uvpt[PGNUM(addr)]&(PTE_W|PTE_COW))==0){
  801855:	8b 40 04             	mov    0x4(%eax),%eax
  801858:	83 e0 02             	and    $0x2,%eax
  80185b:	0f 84 82 00 00 00    	je     8018e3 <pgfault+0x98>
  801861:	89 da                	mov    %ebx,%edx
  801863:	c1 ea 0c             	shr    $0xc,%edx
  801866:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80186d:	f7 c2 02 08 00 00    	test   $0x802,%edx
  801873:	74 6e                	je     8018e3 <pgfault+0x98>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
        envid_t envid = sys_getenvid();
  801875:	e8 a2 fd ff ff       	call   80161c <sys_getenvid>
  80187a:	89 c6                	mov    %eax,%esi
	r = sys_page_alloc(envid,(void *)PFTEMP,PTE_P|PTE_W|PTE_U);
  80187c:	83 ec 04             	sub    $0x4,%esp
  80187f:	6a 07                	push   $0x7
  801881:	68 00 f0 7f 00       	push   $0x7ff000
  801886:	50                   	push   %eax
  801887:	e8 ce fd ff ff       	call   80165a <sys_page_alloc>
	if(r<0) panic("pgfault:page allocation failed %e",r);
  80188c:	83 c4 10             	add    $0x10,%esp
  80188f:	85 c0                	test   %eax,%eax
  801891:	78 72                	js     801905 <pgfault+0xba>

	addr = ROUNDDOWN(addr,PGSIZE);
  801893:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy((void *)PFTEMP,(const void *)addr,PGSIZE);
  801899:	83 ec 04             	sub    $0x4,%esp
  80189c:	68 00 10 00 00       	push   $0x1000
  8018a1:	53                   	push   %ebx
  8018a2:	68 00 f0 7f 00       	push   $0x7ff000
  8018a7:	e8 ab fb ff ff       	call   801457 <memcpy>

	if(sys_page_map(envid,(void *)PFTEMP, envid,addr,PTE_P|PTE_W|PTE_U)<0)
  8018ac:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8018b3:	53                   	push   %ebx
  8018b4:	56                   	push   %esi
  8018b5:	68 00 f0 7f 00       	push   $0x7ff000
  8018ba:	56                   	push   %esi
  8018bb:	e8 dd fd ff ff       	call   80169d <sys_page_map>
  8018c0:	83 c4 20             	add    $0x20,%esp
  8018c3:	85 c0                	test   %eax,%eax
  8018c5:	78 50                	js     801917 <pgfault+0xcc>
		panic("pgfault:page map failed\n");
	if(sys_page_unmap(envid,(void *)PFTEMP)<0)
  8018c7:	83 ec 08             	sub    $0x8,%esp
  8018ca:	68 00 f0 7f 00       	push   $0x7ff000
  8018cf:	56                   	push   %esi
  8018d0:	e8 0a fe ff ff       	call   8016df <sys_page_unmap>
  8018d5:	83 c4 10             	add    $0x10,%esp
  8018d8:	85 c0                	test   %eax,%eax
  8018da:	78 4f                	js     80192b <pgfault+0xe0>
		panic("pgfault: page upmap failed\n");
       //	panic("pgfault not implemented");
}
  8018dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018df:	5b                   	pop    %ebx
  8018e0:	5e                   	pop    %esi
  8018e1:	5d                   	pop    %ebp
  8018e2:	c3                   	ret    
		cprintf("Where is the error %d\n",err&FEC_WR);
  8018e3:	83 ec 08             	sub    $0x8,%esp
  8018e6:	50                   	push   %eax
  8018e7:	68 da 38 80 00       	push   $0x8038da
  8018ec:	e8 61 f2 ff ff       	call   800b52 <cprintf>
		panic("pgfault:invalid user trap");
  8018f1:	83 c4 0c             	add    $0xc,%esp
  8018f4:	68 f1 38 80 00       	push   $0x8038f1
  8018f9:	6a 1e                	push   $0x1e
  8018fb:	68 0b 39 80 00       	push   $0x80390b
  801900:	e8 72 f1 ff ff       	call   800a77 <_panic>
	if(r<0) panic("pgfault:page allocation failed %e",r);
  801905:	50                   	push   %eax
  801906:	68 f8 39 80 00       	push   $0x8039f8
  80190b:	6a 29                	push   $0x29
  80190d:	68 0b 39 80 00       	push   $0x80390b
  801912:	e8 60 f1 ff ff       	call   800a77 <_panic>
		panic("pgfault:page map failed\n");
  801917:	83 ec 04             	sub    $0x4,%esp
  80191a:	68 16 39 80 00       	push   $0x803916
  80191f:	6a 2f                	push   $0x2f
  801921:	68 0b 39 80 00       	push   $0x80390b
  801926:	e8 4c f1 ff ff       	call   800a77 <_panic>
		panic("pgfault: page upmap failed\n");
  80192b:	83 ec 04             	sub    $0x4,%esp
  80192e:	68 2f 39 80 00       	push   $0x80392f
  801933:	6a 31                	push   $0x31
  801935:	68 0b 39 80 00       	push   $0x80390b
  80193a:	e8 38 f1 ff ff       	call   800a77 <_panic>

0080193f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80193f:	55                   	push   %ebp
  801940:	89 e5                	mov    %esp,%ebp
  801942:	57                   	push   %edi
  801943:	56                   	push   %esi
  801944:	53                   	push   %ebx
  801945:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	set_pgfault_handler(pgfault);
  801948:	68 4b 18 80 00       	push   $0x80184b
  80194d:	e8 f3 15 00 00       	call   802f45 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801952:	b8 07 00 00 00       	mov    $0x7,%eax
  801957:	cd 30                	int    $0x30
  801959:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80195c:	89 45 e0             	mov    %eax,-0x20(%ebp)
       
	envid_t envid = sys_exofork();
	uintptr_t addr;
  
	if(envid<0) panic("sys_exofork failed\n");
  80195f:	83 c4 10             	add    $0x10,%esp
  801962:	85 c0                	test   %eax,%eax
  801964:	78 27                	js     80198d <fork+0x4e>
	if(envid==0){
	  thisenv = &envs[ENVX(sys_getenvid())];
	  return 0;
	}

	for(addr=(uintptr_t)UTEXT; addr<USTACKTOP;addr+=PGSIZE){
  801966:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if(envid==0){
  80196b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80196f:	75 5e                	jne    8019cf <fork+0x90>
	  thisenv = &envs[ENVX(sys_getenvid())];
  801971:	e8 a6 fc ff ff       	call   80161c <sys_getenvid>
  801976:	25 ff 03 00 00       	and    $0x3ff,%eax
  80197b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80197e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801983:	a3 24 54 80 00       	mov    %eax,0x805424
	  return 0;
  801988:	e9 fc 00 00 00       	jmp    801a89 <fork+0x14a>
	if(envid<0) panic("sys_exofork failed\n");
  80198d:	83 ec 04             	sub    $0x4,%esp
  801990:	68 4b 39 80 00       	push   $0x80394b
  801995:	6a 77                	push   $0x77
  801997:	68 0b 39 80 00       	push   $0x80390b
  80199c:	e8 d6 f0 ff ff       	call   800a77 <_panic>
          if((r=sys_page_map(parent_envid,va,envid,va,uvpt[pn]&PTE_SYSCALL))<0)
  8019a1:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8019a8:	83 ec 0c             	sub    $0xc,%esp
  8019ab:	25 07 0e 00 00       	and    $0xe07,%eax
  8019b0:	50                   	push   %eax
  8019b1:	57                   	push   %edi
  8019b2:	ff 75 e0             	pushl  -0x20(%ebp)
  8019b5:	57                   	push   %edi
  8019b6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019b9:	e8 df fc ff ff       	call   80169d <sys_page_map>
  8019be:	83 c4 20             	add    $0x20,%esp
	for(addr=(uintptr_t)UTEXT; addr<USTACKTOP;addr+=PGSIZE){
  8019c1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8019c7:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8019cd:	74 76                	je     801a45 <fork+0x106>
	   if((uvpd[PDX(addr)]&PTE_P) && uvpt[PGNUM(addr)] & PTE_P)
  8019cf:	89 d8                	mov    %ebx,%eax
  8019d1:	c1 e8 16             	shr    $0x16,%eax
  8019d4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8019db:	a8 01                	test   $0x1,%al
  8019dd:	74 e2                	je     8019c1 <fork+0x82>
  8019df:	89 de                	mov    %ebx,%esi
  8019e1:	c1 ee 0c             	shr    $0xc,%esi
  8019e4:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8019eb:	a8 01                	test   $0x1,%al
  8019ed:	74 d2                	je     8019c1 <fork+0x82>
        envid_t parent_envid = sys_getenvid();
  8019ef:	e8 28 fc ff ff       	call   80161c <sys_getenvid>
  8019f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	void *va = (void *)(pn*PGSIZE);
  8019f7:	89 f7                	mov    %esi,%edi
  8019f9:	c1 e7 0c             	shl    $0xc,%edi
        if(uvpt[pn] & PTE_SHARE){
  8019fc:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801a03:	f6 c4 04             	test   $0x4,%ah
  801a06:	75 99                	jne    8019a1 <fork+0x62>
	if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)){
  801a08:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801a0f:	a8 02                	test   $0x2,%al
  801a11:	0f 85 ed 00 00 00    	jne    801b04 <fork+0x1c5>
  801a17:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801a1e:	f6 c4 08             	test   $0x8,%ah
  801a21:	0f 85 dd 00 00 00    	jne    801b04 <fork+0x1c5>
	 if((r=sys_page_map(parent_envid,va,envid,va,perm))<0)
  801a27:	83 ec 0c             	sub    $0xc,%esp
  801a2a:	6a 05                	push   $0x5
  801a2c:	57                   	push   %edi
  801a2d:	ff 75 e0             	pushl  -0x20(%ebp)
  801a30:	57                   	push   %edi
  801a31:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a34:	e8 64 fc ff ff       	call   80169d <sys_page_map>
  801a39:	83 c4 20             	add    $0x20,%esp
  801a3c:	85 c0                	test   %eax,%eax
  801a3e:	79 81                	jns    8019c1 <fork+0x82>
  801a40:	e9 db 00 00 00       	jmp    801b20 <fork+0x1e1>
		   duppage(envid,PGNUM(addr));
	}
        
	int r;
	if((r=sys_page_alloc(envid,(void *)UXSTACKTOP-PGSIZE,PTE_U|PTE_P|PTE_W))<0)
  801a45:	83 ec 04             	sub    $0x4,%esp
  801a48:	6a 07                	push   $0x7
  801a4a:	68 00 f0 bf ee       	push   $0xeebff000
  801a4f:	ff 75 dc             	pushl  -0x24(%ebp)
  801a52:	e8 03 fc ff ff       	call   80165a <sys_page_alloc>
  801a57:	83 c4 10             	add    $0x10,%esp
  801a5a:	85 c0                	test   %eax,%eax
  801a5c:	78 36                	js     801a94 <fork+0x155>
		panic("fork:page alloc failed %e\n",r);

	extern void _pgfault_upcall();
	if((r = sys_env_set_pgfault_upcall(envid,_pgfault_upcall)))
  801a5e:	83 ec 08             	sub    $0x8,%esp
  801a61:	68 aa 2f 80 00       	push   $0x802faa
  801a66:	ff 75 dc             	pushl  -0x24(%ebp)
  801a69:	e8 37 fd ff ff       	call   8017a5 <sys_env_set_pgfault_upcall>
  801a6e:	83 c4 10             	add    $0x10,%esp
  801a71:	85 c0                	test   %eax,%eax
  801a73:	75 34                	jne    801aa9 <fork+0x16a>
		panic("fork:set upcall failed %e\n",r);
	if((r = sys_env_set_status(envid,ENV_RUNNABLE))<0)
  801a75:	83 ec 08             	sub    $0x8,%esp
  801a78:	6a 02                	push   $0x2
  801a7a:	ff 75 dc             	pushl  -0x24(%ebp)
  801a7d:	e8 9f fc ff ff       	call   801721 <sys_env_set_status>
  801a82:	83 c4 10             	add    $0x10,%esp
  801a85:	85 c0                	test   %eax,%eax
  801a87:	78 35                	js     801abe <fork+0x17f>
		panic("fork:set status failed %e\n",r);
	//cprintf("forkid= %d\n", envid);
	return envid;
       	
}
  801a89:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801a8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a8f:	5b                   	pop    %ebx
  801a90:	5e                   	pop    %esi
  801a91:	5f                   	pop    %edi
  801a92:	5d                   	pop    %ebp
  801a93:	c3                   	ret    
		panic("fork:page alloc failed %e\n",r);
  801a94:	50                   	push   %eax
  801a95:	68 8f 39 80 00       	push   $0x80398f
  801a9a:	68 84 00 00 00       	push   $0x84
  801a9f:	68 0b 39 80 00       	push   $0x80390b
  801aa4:	e8 ce ef ff ff       	call   800a77 <_panic>
		panic("fork:set upcall failed %e\n",r);
  801aa9:	50                   	push   %eax
  801aaa:	68 aa 39 80 00       	push   $0x8039aa
  801aaf:	68 88 00 00 00       	push   $0x88
  801ab4:	68 0b 39 80 00       	push   $0x80390b
  801ab9:	e8 b9 ef ff ff       	call   800a77 <_panic>
		panic("fork:set status failed %e\n",r);
  801abe:	50                   	push   %eax
  801abf:	68 c5 39 80 00       	push   $0x8039c5
  801ac4:	68 8a 00 00 00       	push   $0x8a
  801ac9:	68 0b 39 80 00       	push   $0x80390b
  801ace:	e8 a4 ef ff ff       	call   800a77 <_panic>
		if( (r=sys_page_map(parent_envid,va,parent_envid,va,perm))<0){
  801ad3:	83 ec 0c             	sub    $0xc,%esp
  801ad6:	68 05 08 00 00       	push   $0x805
  801adb:	57                   	push   %edi
  801adc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801adf:	50                   	push   %eax
  801ae0:	57                   	push   %edi
  801ae1:	50                   	push   %eax
  801ae2:	e8 b6 fb ff ff       	call   80169d <sys_page_map>
  801ae7:	83 c4 20             	add    $0x20,%esp
  801aea:	85 c0                	test   %eax,%eax
  801aec:	0f 89 cf fe ff ff    	jns    8019c1 <fork+0x82>
		 panic("duppage:map02 failed %e",r);
  801af2:	50                   	push   %eax
  801af3:	68 77 39 80 00       	push   $0x803977
  801af8:	6a 56                	push   $0x56
  801afa:	68 0b 39 80 00       	push   $0x80390b
  801aff:	e8 73 ef ff ff       	call   800a77 <_panic>
	 if((r=sys_page_map(parent_envid,va,envid,va,perm))<0)
  801b04:	83 ec 0c             	sub    $0xc,%esp
  801b07:	68 05 08 00 00       	push   $0x805
  801b0c:	57                   	push   %edi
  801b0d:	ff 75 e0             	pushl  -0x20(%ebp)
  801b10:	57                   	push   %edi
  801b11:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b14:	e8 84 fb ff ff       	call   80169d <sys_page_map>
  801b19:	83 c4 20             	add    $0x20,%esp
  801b1c:	85 c0                	test   %eax,%eax
  801b1e:	79 b3                	jns    801ad3 <fork+0x194>
		 panic("duppage:map01 failed %e",r);
  801b20:	50                   	push   %eax
  801b21:	68 5f 39 80 00       	push   $0x80395f
  801b26:	6a 53                	push   $0x53
  801b28:	68 0b 39 80 00       	push   $0x80390b
  801b2d:	e8 45 ef ff ff       	call   800a77 <_panic>

00801b32 <sfork>:

// Challenge!
int
sfork(void)
{
  801b32:	55                   	push   %ebp
  801b33:	89 e5                	mov    %esp,%ebp
  801b35:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801b38:	68 e0 39 80 00       	push   $0x8039e0
  801b3d:	68 94 00 00 00       	push   $0x94
  801b42:	68 0b 39 80 00       	push   $0x80390b
  801b47:	e8 2b ef ff ff       	call   800a77 <_panic>

00801b4c <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801b4c:	55                   	push   %ebp
  801b4d:	89 e5                	mov    %esp,%ebp
  801b4f:	8b 55 08             	mov    0x8(%ebp),%edx
  801b52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b55:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801b58:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801b5a:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801b5d:	83 3a 01             	cmpl   $0x1,(%edx)
  801b60:	7e 09                	jle    801b6b <argstart+0x1f>
  801b62:	ba 81 33 80 00       	mov    $0x803381,%edx
  801b67:	85 c9                	test   %ecx,%ecx
  801b69:	75 05                	jne    801b70 <argstart+0x24>
  801b6b:	ba 00 00 00 00       	mov    $0x0,%edx
  801b70:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801b73:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801b7a:	5d                   	pop    %ebp
  801b7b:	c3                   	ret    

00801b7c <argnext>:

int
argnext(struct Argstate *args)
{
  801b7c:	55                   	push   %ebp
  801b7d:	89 e5                	mov    %esp,%ebp
  801b7f:	53                   	push   %ebx
  801b80:	83 ec 04             	sub    $0x4,%esp
  801b83:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801b86:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801b8d:	8b 43 08             	mov    0x8(%ebx),%eax
  801b90:	85 c0                	test   %eax,%eax
  801b92:	74 72                	je     801c06 <argnext+0x8a>
		return -1;

	if (!*args->curarg) {
  801b94:	80 38 00             	cmpb   $0x0,(%eax)
  801b97:	75 48                	jne    801be1 <argnext+0x65>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801b99:	8b 0b                	mov    (%ebx),%ecx
  801b9b:	83 39 01             	cmpl   $0x1,(%ecx)
  801b9e:	74 58                	je     801bf8 <argnext+0x7c>
		    || args->argv[1][0] != '-'
  801ba0:	8b 53 04             	mov    0x4(%ebx),%edx
  801ba3:	8b 42 04             	mov    0x4(%edx),%eax
  801ba6:	80 38 2d             	cmpb   $0x2d,(%eax)
  801ba9:	75 4d                	jne    801bf8 <argnext+0x7c>
		    || args->argv[1][1] == '\0')
  801bab:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801baf:	74 47                	je     801bf8 <argnext+0x7c>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801bb1:	83 c0 01             	add    $0x1,%eax
  801bb4:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801bb7:	83 ec 04             	sub    $0x4,%esp
  801bba:	8b 01                	mov    (%ecx),%eax
  801bbc:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801bc3:	50                   	push   %eax
  801bc4:	8d 42 08             	lea    0x8(%edx),%eax
  801bc7:	50                   	push   %eax
  801bc8:	83 c2 04             	add    $0x4,%edx
  801bcb:	52                   	push   %edx
  801bcc:	e8 1e f8 ff ff       	call   8013ef <memmove>
		(*args->argc)--;
  801bd1:	8b 03                	mov    (%ebx),%eax
  801bd3:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801bd6:	8b 43 08             	mov    0x8(%ebx),%eax
  801bd9:	83 c4 10             	add    $0x10,%esp
  801bdc:	80 38 2d             	cmpb   $0x2d,(%eax)
  801bdf:	74 11                	je     801bf2 <argnext+0x76>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801be1:	8b 53 08             	mov    0x8(%ebx),%edx
  801be4:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801be7:	83 c2 01             	add    $0x1,%edx
  801bea:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801bed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bf0:	c9                   	leave  
  801bf1:	c3                   	ret    
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801bf2:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801bf6:	75 e9                	jne    801be1 <argnext+0x65>
	args->curarg = 0;
  801bf8:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801bff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801c04:	eb e7                	jmp    801bed <argnext+0x71>
		return -1;
  801c06:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801c0b:	eb e0                	jmp    801bed <argnext+0x71>

00801c0d <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801c0d:	55                   	push   %ebp
  801c0e:	89 e5                	mov    %esp,%ebp
  801c10:	53                   	push   %ebx
  801c11:	83 ec 04             	sub    $0x4,%esp
  801c14:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801c17:	8b 43 08             	mov    0x8(%ebx),%eax
  801c1a:	85 c0                	test   %eax,%eax
  801c1c:	74 5b                	je     801c79 <argnextvalue+0x6c>
		return 0;
	if (*args->curarg) {
  801c1e:	80 38 00             	cmpb   $0x0,(%eax)
  801c21:	74 12                	je     801c35 <argnextvalue+0x28>
		args->argvalue = args->curarg;
  801c23:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801c26:	c7 43 08 81 33 80 00 	movl   $0x803381,0x8(%ebx)
		(*args->argc)--;
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
  801c2d:	8b 43 0c             	mov    0xc(%ebx),%eax
}
  801c30:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c33:	c9                   	leave  
  801c34:	c3                   	ret    
	} else if (*args->argc > 1) {
  801c35:	8b 13                	mov    (%ebx),%edx
  801c37:	83 3a 01             	cmpl   $0x1,(%edx)
  801c3a:	7f 10                	jg     801c4c <argnextvalue+0x3f>
		args->argvalue = 0;
  801c3c:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801c43:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  801c4a:	eb e1                	jmp    801c2d <argnextvalue+0x20>
		args->argvalue = args->argv[1];
  801c4c:	8b 43 04             	mov    0x4(%ebx),%eax
  801c4f:	8b 48 04             	mov    0x4(%eax),%ecx
  801c52:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801c55:	83 ec 04             	sub    $0x4,%esp
  801c58:	8b 12                	mov    (%edx),%edx
  801c5a:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801c61:	52                   	push   %edx
  801c62:	8d 50 08             	lea    0x8(%eax),%edx
  801c65:	52                   	push   %edx
  801c66:	83 c0 04             	add    $0x4,%eax
  801c69:	50                   	push   %eax
  801c6a:	e8 80 f7 ff ff       	call   8013ef <memmove>
		(*args->argc)--;
  801c6f:	8b 03                	mov    (%ebx),%eax
  801c71:	83 28 01             	subl   $0x1,(%eax)
  801c74:	83 c4 10             	add    $0x10,%esp
  801c77:	eb b4                	jmp    801c2d <argnextvalue+0x20>
		return 0;
  801c79:	b8 00 00 00 00       	mov    $0x0,%eax
  801c7e:	eb b0                	jmp    801c30 <argnextvalue+0x23>

00801c80 <argvalue>:
{
  801c80:	55                   	push   %ebp
  801c81:	89 e5                	mov    %esp,%ebp
  801c83:	83 ec 08             	sub    $0x8,%esp
  801c86:	8b 55 08             	mov    0x8(%ebp),%edx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801c89:	8b 42 0c             	mov    0xc(%edx),%eax
  801c8c:	85 c0                	test   %eax,%eax
  801c8e:	74 02                	je     801c92 <argvalue+0x12>
}
  801c90:	c9                   	leave  
  801c91:	c3                   	ret    
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801c92:	83 ec 0c             	sub    $0xc,%esp
  801c95:	52                   	push   %edx
  801c96:	e8 72 ff ff ff       	call   801c0d <argnextvalue>
  801c9b:	83 c4 10             	add    $0x10,%esp
  801c9e:	eb f0                	jmp    801c90 <argvalue+0x10>

00801ca0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801ca0:	55                   	push   %ebp
  801ca1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801ca3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca6:	05 00 00 00 30       	add    $0x30000000,%eax
  801cab:	c1 e8 0c             	shr    $0xc,%eax
}
  801cae:	5d                   	pop    %ebp
  801caf:	c3                   	ret    

00801cb0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801cb0:	55                   	push   %ebp
  801cb1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801cb3:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb6:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801cbb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801cc0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801cc5:	5d                   	pop    %ebp
  801cc6:	c3                   	ret    

00801cc7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801cc7:	55                   	push   %ebp
  801cc8:	89 e5                	mov    %esp,%ebp
  801cca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ccd:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801cd2:	89 c2                	mov    %eax,%edx
  801cd4:	c1 ea 16             	shr    $0x16,%edx
  801cd7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801cde:	f6 c2 01             	test   $0x1,%dl
  801ce1:	74 2a                	je     801d0d <fd_alloc+0x46>
  801ce3:	89 c2                	mov    %eax,%edx
  801ce5:	c1 ea 0c             	shr    $0xc,%edx
  801ce8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801cef:	f6 c2 01             	test   $0x1,%dl
  801cf2:	74 19                	je     801d0d <fd_alloc+0x46>
  801cf4:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801cf9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801cfe:	75 d2                	jne    801cd2 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801d00:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801d06:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801d0b:	eb 07                	jmp    801d14 <fd_alloc+0x4d>
			*fd_store = fd;
  801d0d:	89 01                	mov    %eax,(%ecx)
			return 0;
  801d0f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d14:	5d                   	pop    %ebp
  801d15:	c3                   	ret    

00801d16 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801d16:	55                   	push   %ebp
  801d17:	89 e5                	mov    %esp,%ebp
  801d19:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801d1c:	83 f8 1f             	cmp    $0x1f,%eax
  801d1f:	77 36                	ja     801d57 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801d21:	c1 e0 0c             	shl    $0xc,%eax
  801d24:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801d29:	89 c2                	mov    %eax,%edx
  801d2b:	c1 ea 16             	shr    $0x16,%edx
  801d2e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801d35:	f6 c2 01             	test   $0x1,%dl
  801d38:	74 24                	je     801d5e <fd_lookup+0x48>
  801d3a:	89 c2                	mov    %eax,%edx
  801d3c:	c1 ea 0c             	shr    $0xc,%edx
  801d3f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801d46:	f6 c2 01             	test   $0x1,%dl
  801d49:	74 1a                	je     801d65 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801d4b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d4e:	89 02                	mov    %eax,(%edx)
	return 0;
  801d50:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d55:	5d                   	pop    %ebp
  801d56:	c3                   	ret    
		return -E_INVAL;
  801d57:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801d5c:	eb f7                	jmp    801d55 <fd_lookup+0x3f>
		return -E_INVAL;
  801d5e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801d63:	eb f0                	jmp    801d55 <fd_lookup+0x3f>
  801d65:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801d6a:	eb e9                	jmp    801d55 <fd_lookup+0x3f>

00801d6c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801d6c:	55                   	push   %ebp
  801d6d:	89 e5                	mov    %esp,%ebp
  801d6f:	83 ec 08             	sub    $0x8,%esp
  801d72:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d75:	ba 98 3a 80 00       	mov    $0x803a98,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801d7a:	b8 20 40 80 00       	mov    $0x804020,%eax
		if (devtab[i]->dev_id == dev_id) {
  801d7f:	39 08                	cmp    %ecx,(%eax)
  801d81:	74 33                	je     801db6 <dev_lookup+0x4a>
  801d83:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  801d86:	8b 02                	mov    (%edx),%eax
  801d88:	85 c0                	test   %eax,%eax
  801d8a:	75 f3                	jne    801d7f <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801d8c:	a1 24 54 80 00       	mov    0x805424,%eax
  801d91:	8b 40 48             	mov    0x48(%eax),%eax
  801d94:	83 ec 04             	sub    $0x4,%esp
  801d97:	51                   	push   %ecx
  801d98:	50                   	push   %eax
  801d99:	68 1c 3a 80 00       	push   $0x803a1c
  801d9e:	e8 af ed ff ff       	call   800b52 <cprintf>
	*dev = 0;
  801da3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801da6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801dac:	83 c4 10             	add    $0x10,%esp
  801daf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801db4:	c9                   	leave  
  801db5:	c3                   	ret    
			*dev = devtab[i];
  801db6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801db9:	89 01                	mov    %eax,(%ecx)
			return 0;
  801dbb:	b8 00 00 00 00       	mov    $0x0,%eax
  801dc0:	eb f2                	jmp    801db4 <dev_lookup+0x48>

00801dc2 <fd_close>:
{
  801dc2:	55                   	push   %ebp
  801dc3:	89 e5                	mov    %esp,%ebp
  801dc5:	57                   	push   %edi
  801dc6:	56                   	push   %esi
  801dc7:	53                   	push   %ebx
  801dc8:	83 ec 1c             	sub    $0x1c,%esp
  801dcb:	8b 75 08             	mov    0x8(%ebp),%esi
  801dce:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801dd1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801dd4:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801dd5:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801ddb:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801dde:	50                   	push   %eax
  801ddf:	e8 32 ff ff ff       	call   801d16 <fd_lookup>
  801de4:	89 c3                	mov    %eax,%ebx
  801de6:	83 c4 08             	add    $0x8,%esp
  801de9:	85 c0                	test   %eax,%eax
  801deb:	78 05                	js     801df2 <fd_close+0x30>
	    || fd != fd2)
  801ded:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801df0:	74 16                	je     801e08 <fd_close+0x46>
		return (must_exist ? r : 0);
  801df2:	89 f8                	mov    %edi,%eax
  801df4:	84 c0                	test   %al,%al
  801df6:	b8 00 00 00 00       	mov    $0x0,%eax
  801dfb:	0f 44 d8             	cmove  %eax,%ebx
}
  801dfe:	89 d8                	mov    %ebx,%eax
  801e00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e03:	5b                   	pop    %ebx
  801e04:	5e                   	pop    %esi
  801e05:	5f                   	pop    %edi
  801e06:	5d                   	pop    %ebp
  801e07:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801e08:	83 ec 08             	sub    $0x8,%esp
  801e0b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801e0e:	50                   	push   %eax
  801e0f:	ff 36                	pushl  (%esi)
  801e11:	e8 56 ff ff ff       	call   801d6c <dev_lookup>
  801e16:	89 c3                	mov    %eax,%ebx
  801e18:	83 c4 10             	add    $0x10,%esp
  801e1b:	85 c0                	test   %eax,%eax
  801e1d:	78 15                	js     801e34 <fd_close+0x72>
		if (dev->dev_close)
  801e1f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e22:	8b 40 10             	mov    0x10(%eax),%eax
  801e25:	85 c0                	test   %eax,%eax
  801e27:	74 1b                	je     801e44 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  801e29:	83 ec 0c             	sub    $0xc,%esp
  801e2c:	56                   	push   %esi
  801e2d:	ff d0                	call   *%eax
  801e2f:	89 c3                	mov    %eax,%ebx
  801e31:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801e34:	83 ec 08             	sub    $0x8,%esp
  801e37:	56                   	push   %esi
  801e38:	6a 00                	push   $0x0
  801e3a:	e8 a0 f8 ff ff       	call   8016df <sys_page_unmap>
	return r;
  801e3f:	83 c4 10             	add    $0x10,%esp
  801e42:	eb ba                	jmp    801dfe <fd_close+0x3c>
			r = 0;
  801e44:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e49:	eb e9                	jmp    801e34 <fd_close+0x72>

00801e4b <close>:

int
close(int fdnum)
{
  801e4b:	55                   	push   %ebp
  801e4c:	89 e5                	mov    %esp,%ebp
  801e4e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e51:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e54:	50                   	push   %eax
  801e55:	ff 75 08             	pushl  0x8(%ebp)
  801e58:	e8 b9 fe ff ff       	call   801d16 <fd_lookup>
  801e5d:	83 c4 08             	add    $0x8,%esp
  801e60:	85 c0                	test   %eax,%eax
  801e62:	78 10                	js     801e74 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801e64:	83 ec 08             	sub    $0x8,%esp
  801e67:	6a 01                	push   $0x1
  801e69:	ff 75 f4             	pushl  -0xc(%ebp)
  801e6c:	e8 51 ff ff ff       	call   801dc2 <fd_close>
  801e71:	83 c4 10             	add    $0x10,%esp
}
  801e74:	c9                   	leave  
  801e75:	c3                   	ret    

00801e76 <close_all>:

void
close_all(void)
{
  801e76:	55                   	push   %ebp
  801e77:	89 e5                	mov    %esp,%ebp
  801e79:	53                   	push   %ebx
  801e7a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801e7d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801e82:	83 ec 0c             	sub    $0xc,%esp
  801e85:	53                   	push   %ebx
  801e86:	e8 c0 ff ff ff       	call   801e4b <close>
	for (i = 0; i < MAXFD; i++)
  801e8b:	83 c3 01             	add    $0x1,%ebx
  801e8e:	83 c4 10             	add    $0x10,%esp
  801e91:	83 fb 20             	cmp    $0x20,%ebx
  801e94:	75 ec                	jne    801e82 <close_all+0xc>
}
  801e96:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e99:	c9                   	leave  
  801e9a:	c3                   	ret    

00801e9b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801e9b:	55                   	push   %ebp
  801e9c:	89 e5                	mov    %esp,%ebp
  801e9e:	57                   	push   %edi
  801e9f:	56                   	push   %esi
  801ea0:	53                   	push   %ebx
  801ea1:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801ea4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801ea7:	50                   	push   %eax
  801ea8:	ff 75 08             	pushl  0x8(%ebp)
  801eab:	e8 66 fe ff ff       	call   801d16 <fd_lookup>
  801eb0:	89 c3                	mov    %eax,%ebx
  801eb2:	83 c4 08             	add    $0x8,%esp
  801eb5:	85 c0                	test   %eax,%eax
  801eb7:	0f 88 81 00 00 00    	js     801f3e <dup+0xa3>
		return r;
	close(newfdnum);
  801ebd:	83 ec 0c             	sub    $0xc,%esp
  801ec0:	ff 75 0c             	pushl  0xc(%ebp)
  801ec3:	e8 83 ff ff ff       	call   801e4b <close>

	newfd = INDEX2FD(newfdnum);
  801ec8:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ecb:	c1 e6 0c             	shl    $0xc,%esi
  801ece:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801ed4:	83 c4 04             	add    $0x4,%esp
  801ed7:	ff 75 e4             	pushl  -0x1c(%ebp)
  801eda:	e8 d1 fd ff ff       	call   801cb0 <fd2data>
  801edf:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801ee1:	89 34 24             	mov    %esi,(%esp)
  801ee4:	e8 c7 fd ff ff       	call   801cb0 <fd2data>
  801ee9:	83 c4 10             	add    $0x10,%esp
  801eec:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801eee:	89 d8                	mov    %ebx,%eax
  801ef0:	c1 e8 16             	shr    $0x16,%eax
  801ef3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801efa:	a8 01                	test   $0x1,%al
  801efc:	74 11                	je     801f0f <dup+0x74>
  801efe:	89 d8                	mov    %ebx,%eax
  801f00:	c1 e8 0c             	shr    $0xc,%eax
  801f03:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801f0a:	f6 c2 01             	test   $0x1,%dl
  801f0d:	75 39                	jne    801f48 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801f0f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801f12:	89 d0                	mov    %edx,%eax
  801f14:	c1 e8 0c             	shr    $0xc,%eax
  801f17:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801f1e:	83 ec 0c             	sub    $0xc,%esp
  801f21:	25 07 0e 00 00       	and    $0xe07,%eax
  801f26:	50                   	push   %eax
  801f27:	56                   	push   %esi
  801f28:	6a 00                	push   $0x0
  801f2a:	52                   	push   %edx
  801f2b:	6a 00                	push   $0x0
  801f2d:	e8 6b f7 ff ff       	call   80169d <sys_page_map>
  801f32:	89 c3                	mov    %eax,%ebx
  801f34:	83 c4 20             	add    $0x20,%esp
  801f37:	85 c0                	test   %eax,%eax
  801f39:	78 31                	js     801f6c <dup+0xd1>
		goto err;

	return newfdnum;
  801f3b:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801f3e:	89 d8                	mov    %ebx,%eax
  801f40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f43:	5b                   	pop    %ebx
  801f44:	5e                   	pop    %esi
  801f45:	5f                   	pop    %edi
  801f46:	5d                   	pop    %ebp
  801f47:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801f48:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801f4f:	83 ec 0c             	sub    $0xc,%esp
  801f52:	25 07 0e 00 00       	and    $0xe07,%eax
  801f57:	50                   	push   %eax
  801f58:	57                   	push   %edi
  801f59:	6a 00                	push   $0x0
  801f5b:	53                   	push   %ebx
  801f5c:	6a 00                	push   $0x0
  801f5e:	e8 3a f7 ff ff       	call   80169d <sys_page_map>
  801f63:	89 c3                	mov    %eax,%ebx
  801f65:	83 c4 20             	add    $0x20,%esp
  801f68:	85 c0                	test   %eax,%eax
  801f6a:	79 a3                	jns    801f0f <dup+0x74>
	sys_page_unmap(0, newfd);
  801f6c:	83 ec 08             	sub    $0x8,%esp
  801f6f:	56                   	push   %esi
  801f70:	6a 00                	push   $0x0
  801f72:	e8 68 f7 ff ff       	call   8016df <sys_page_unmap>
	sys_page_unmap(0, nva);
  801f77:	83 c4 08             	add    $0x8,%esp
  801f7a:	57                   	push   %edi
  801f7b:	6a 00                	push   $0x0
  801f7d:	e8 5d f7 ff ff       	call   8016df <sys_page_unmap>
	return r;
  801f82:	83 c4 10             	add    $0x10,%esp
  801f85:	eb b7                	jmp    801f3e <dup+0xa3>

00801f87 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801f87:	55                   	push   %ebp
  801f88:	89 e5                	mov    %esp,%ebp
  801f8a:	53                   	push   %ebx
  801f8b:	83 ec 14             	sub    $0x14,%esp
  801f8e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801f91:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f94:	50                   	push   %eax
  801f95:	53                   	push   %ebx
  801f96:	e8 7b fd ff ff       	call   801d16 <fd_lookup>
  801f9b:	83 c4 08             	add    $0x8,%esp
  801f9e:	85 c0                	test   %eax,%eax
  801fa0:	78 3f                	js     801fe1 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801fa2:	83 ec 08             	sub    $0x8,%esp
  801fa5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fa8:	50                   	push   %eax
  801fa9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fac:	ff 30                	pushl  (%eax)
  801fae:	e8 b9 fd ff ff       	call   801d6c <dev_lookup>
  801fb3:	83 c4 10             	add    $0x10,%esp
  801fb6:	85 c0                	test   %eax,%eax
  801fb8:	78 27                	js     801fe1 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801fba:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801fbd:	8b 42 08             	mov    0x8(%edx),%eax
  801fc0:	83 e0 03             	and    $0x3,%eax
  801fc3:	83 f8 01             	cmp    $0x1,%eax
  801fc6:	74 1e                	je     801fe6 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801fc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fcb:	8b 40 08             	mov    0x8(%eax),%eax
  801fce:	85 c0                	test   %eax,%eax
  801fd0:	74 35                	je     802007 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801fd2:	83 ec 04             	sub    $0x4,%esp
  801fd5:	ff 75 10             	pushl  0x10(%ebp)
  801fd8:	ff 75 0c             	pushl  0xc(%ebp)
  801fdb:	52                   	push   %edx
  801fdc:	ff d0                	call   *%eax
  801fde:	83 c4 10             	add    $0x10,%esp
}
  801fe1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fe4:	c9                   	leave  
  801fe5:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801fe6:	a1 24 54 80 00       	mov    0x805424,%eax
  801feb:	8b 40 48             	mov    0x48(%eax),%eax
  801fee:	83 ec 04             	sub    $0x4,%esp
  801ff1:	53                   	push   %ebx
  801ff2:	50                   	push   %eax
  801ff3:	68 5d 3a 80 00       	push   $0x803a5d
  801ff8:	e8 55 eb ff ff       	call   800b52 <cprintf>
		return -E_INVAL;
  801ffd:	83 c4 10             	add    $0x10,%esp
  802000:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802005:	eb da                	jmp    801fe1 <read+0x5a>
		return -E_NOT_SUPP;
  802007:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80200c:	eb d3                	jmp    801fe1 <read+0x5a>

0080200e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80200e:	55                   	push   %ebp
  80200f:	89 e5                	mov    %esp,%ebp
  802011:	57                   	push   %edi
  802012:	56                   	push   %esi
  802013:	53                   	push   %ebx
  802014:	83 ec 0c             	sub    $0xc,%esp
  802017:	8b 7d 08             	mov    0x8(%ebp),%edi
  80201a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80201d:	bb 00 00 00 00       	mov    $0x0,%ebx
  802022:	39 f3                	cmp    %esi,%ebx
  802024:	73 25                	jae    80204b <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802026:	83 ec 04             	sub    $0x4,%esp
  802029:	89 f0                	mov    %esi,%eax
  80202b:	29 d8                	sub    %ebx,%eax
  80202d:	50                   	push   %eax
  80202e:	89 d8                	mov    %ebx,%eax
  802030:	03 45 0c             	add    0xc(%ebp),%eax
  802033:	50                   	push   %eax
  802034:	57                   	push   %edi
  802035:	e8 4d ff ff ff       	call   801f87 <read>
		if (m < 0)
  80203a:	83 c4 10             	add    $0x10,%esp
  80203d:	85 c0                	test   %eax,%eax
  80203f:	78 08                	js     802049 <readn+0x3b>
			return m;
		if (m == 0)
  802041:	85 c0                	test   %eax,%eax
  802043:	74 06                	je     80204b <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  802045:	01 c3                	add    %eax,%ebx
  802047:	eb d9                	jmp    802022 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802049:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80204b:	89 d8                	mov    %ebx,%eax
  80204d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802050:	5b                   	pop    %ebx
  802051:	5e                   	pop    %esi
  802052:	5f                   	pop    %edi
  802053:	5d                   	pop    %ebp
  802054:	c3                   	ret    

00802055 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802055:	55                   	push   %ebp
  802056:	89 e5                	mov    %esp,%ebp
  802058:	53                   	push   %ebx
  802059:	83 ec 14             	sub    $0x14,%esp
  80205c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80205f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802062:	50                   	push   %eax
  802063:	53                   	push   %ebx
  802064:	e8 ad fc ff ff       	call   801d16 <fd_lookup>
  802069:	83 c4 08             	add    $0x8,%esp
  80206c:	85 c0                	test   %eax,%eax
  80206e:	78 3a                	js     8020aa <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802070:	83 ec 08             	sub    $0x8,%esp
  802073:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802076:	50                   	push   %eax
  802077:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80207a:	ff 30                	pushl  (%eax)
  80207c:	e8 eb fc ff ff       	call   801d6c <dev_lookup>
  802081:	83 c4 10             	add    $0x10,%esp
  802084:	85 c0                	test   %eax,%eax
  802086:	78 22                	js     8020aa <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802088:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80208b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80208f:	74 1e                	je     8020af <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802091:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802094:	8b 52 0c             	mov    0xc(%edx),%edx
  802097:	85 d2                	test   %edx,%edx
  802099:	74 35                	je     8020d0 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80209b:	83 ec 04             	sub    $0x4,%esp
  80209e:	ff 75 10             	pushl  0x10(%ebp)
  8020a1:	ff 75 0c             	pushl  0xc(%ebp)
  8020a4:	50                   	push   %eax
  8020a5:	ff d2                	call   *%edx
  8020a7:	83 c4 10             	add    $0x10,%esp
}
  8020aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020ad:	c9                   	leave  
  8020ae:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8020af:	a1 24 54 80 00       	mov    0x805424,%eax
  8020b4:	8b 40 48             	mov    0x48(%eax),%eax
  8020b7:	83 ec 04             	sub    $0x4,%esp
  8020ba:	53                   	push   %ebx
  8020bb:	50                   	push   %eax
  8020bc:	68 79 3a 80 00       	push   $0x803a79
  8020c1:	e8 8c ea ff ff       	call   800b52 <cprintf>
		return -E_INVAL;
  8020c6:	83 c4 10             	add    $0x10,%esp
  8020c9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8020ce:	eb da                	jmp    8020aa <write+0x55>
		return -E_NOT_SUPP;
  8020d0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8020d5:	eb d3                	jmp    8020aa <write+0x55>

008020d7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8020d7:	55                   	push   %ebp
  8020d8:	89 e5                	mov    %esp,%ebp
  8020da:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020dd:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8020e0:	50                   	push   %eax
  8020e1:	ff 75 08             	pushl  0x8(%ebp)
  8020e4:	e8 2d fc ff ff       	call   801d16 <fd_lookup>
  8020e9:	83 c4 08             	add    $0x8,%esp
  8020ec:	85 c0                	test   %eax,%eax
  8020ee:	78 0e                	js     8020fe <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8020f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8020f6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8020f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020fe:	c9                   	leave  
  8020ff:	c3                   	ret    

00802100 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802100:	55                   	push   %ebp
  802101:	89 e5                	mov    %esp,%ebp
  802103:	53                   	push   %ebx
  802104:	83 ec 14             	sub    $0x14,%esp
  802107:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80210a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80210d:	50                   	push   %eax
  80210e:	53                   	push   %ebx
  80210f:	e8 02 fc ff ff       	call   801d16 <fd_lookup>
  802114:	83 c4 08             	add    $0x8,%esp
  802117:	85 c0                	test   %eax,%eax
  802119:	78 37                	js     802152 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80211b:	83 ec 08             	sub    $0x8,%esp
  80211e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802121:	50                   	push   %eax
  802122:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802125:	ff 30                	pushl  (%eax)
  802127:	e8 40 fc ff ff       	call   801d6c <dev_lookup>
  80212c:	83 c4 10             	add    $0x10,%esp
  80212f:	85 c0                	test   %eax,%eax
  802131:	78 1f                	js     802152 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802133:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802136:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80213a:	74 1b                	je     802157 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80213c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80213f:	8b 52 18             	mov    0x18(%edx),%edx
  802142:	85 d2                	test   %edx,%edx
  802144:	74 32                	je     802178 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802146:	83 ec 08             	sub    $0x8,%esp
  802149:	ff 75 0c             	pushl  0xc(%ebp)
  80214c:	50                   	push   %eax
  80214d:	ff d2                	call   *%edx
  80214f:	83 c4 10             	add    $0x10,%esp
}
  802152:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802155:	c9                   	leave  
  802156:	c3                   	ret    
			thisenv->env_id, fdnum);
  802157:	a1 24 54 80 00       	mov    0x805424,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80215c:	8b 40 48             	mov    0x48(%eax),%eax
  80215f:	83 ec 04             	sub    $0x4,%esp
  802162:	53                   	push   %ebx
  802163:	50                   	push   %eax
  802164:	68 3c 3a 80 00       	push   $0x803a3c
  802169:	e8 e4 e9 ff ff       	call   800b52 <cprintf>
		return -E_INVAL;
  80216e:	83 c4 10             	add    $0x10,%esp
  802171:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802176:	eb da                	jmp    802152 <ftruncate+0x52>
		return -E_NOT_SUPP;
  802178:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80217d:	eb d3                	jmp    802152 <ftruncate+0x52>

0080217f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80217f:	55                   	push   %ebp
  802180:	89 e5                	mov    %esp,%ebp
  802182:	53                   	push   %ebx
  802183:	83 ec 14             	sub    $0x14,%esp
  802186:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802189:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80218c:	50                   	push   %eax
  80218d:	ff 75 08             	pushl  0x8(%ebp)
  802190:	e8 81 fb ff ff       	call   801d16 <fd_lookup>
  802195:	83 c4 08             	add    $0x8,%esp
  802198:	85 c0                	test   %eax,%eax
  80219a:	78 4b                	js     8021e7 <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80219c:	83 ec 08             	sub    $0x8,%esp
  80219f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021a2:	50                   	push   %eax
  8021a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021a6:	ff 30                	pushl  (%eax)
  8021a8:	e8 bf fb ff ff       	call   801d6c <dev_lookup>
  8021ad:	83 c4 10             	add    $0x10,%esp
  8021b0:	85 c0                	test   %eax,%eax
  8021b2:	78 33                	js     8021e7 <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  8021b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021b7:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8021bb:	74 2f                	je     8021ec <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8021bd:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8021c0:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8021c7:	00 00 00 
	stat->st_isdir = 0;
  8021ca:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8021d1:	00 00 00 
	stat->st_dev = dev;
  8021d4:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8021da:	83 ec 08             	sub    $0x8,%esp
  8021dd:	53                   	push   %ebx
  8021de:	ff 75 f0             	pushl  -0x10(%ebp)
  8021e1:	ff 50 14             	call   *0x14(%eax)
  8021e4:	83 c4 10             	add    $0x10,%esp
}
  8021e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021ea:	c9                   	leave  
  8021eb:	c3                   	ret    
		return -E_NOT_SUPP;
  8021ec:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8021f1:	eb f4                	jmp    8021e7 <fstat+0x68>

008021f3 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8021f3:	55                   	push   %ebp
  8021f4:	89 e5                	mov    %esp,%ebp
  8021f6:	56                   	push   %esi
  8021f7:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8021f8:	83 ec 08             	sub    $0x8,%esp
  8021fb:	6a 00                	push   $0x0
  8021fd:	ff 75 08             	pushl  0x8(%ebp)
  802200:	e8 e7 01 00 00       	call   8023ec <open>
  802205:	89 c3                	mov    %eax,%ebx
  802207:	83 c4 10             	add    $0x10,%esp
  80220a:	85 c0                	test   %eax,%eax
  80220c:	78 1b                	js     802229 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80220e:	83 ec 08             	sub    $0x8,%esp
  802211:	ff 75 0c             	pushl  0xc(%ebp)
  802214:	50                   	push   %eax
  802215:	e8 65 ff ff ff       	call   80217f <fstat>
  80221a:	89 c6                	mov    %eax,%esi
	close(fd);
  80221c:	89 1c 24             	mov    %ebx,(%esp)
  80221f:	e8 27 fc ff ff       	call   801e4b <close>
	return r;
  802224:	83 c4 10             	add    $0x10,%esp
  802227:	89 f3                	mov    %esi,%ebx
}
  802229:	89 d8                	mov    %ebx,%eax
  80222b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80222e:	5b                   	pop    %ebx
  80222f:	5e                   	pop    %esi
  802230:	5d                   	pop    %ebp
  802231:	c3                   	ret    

00802232 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802232:	55                   	push   %ebp
  802233:	89 e5                	mov    %esp,%ebp
  802235:	56                   	push   %esi
  802236:	53                   	push   %ebx
  802237:	89 c6                	mov    %eax,%esi
  802239:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80223b:	83 3d 20 54 80 00 00 	cmpl   $0x0,0x805420
  802242:	74 27                	je     80226b <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802244:	6a 07                	push   $0x7
  802246:	68 00 60 80 00       	push   $0x806000
  80224b:	56                   	push   %esi
  80224c:	ff 35 20 54 80 00    	pushl  0x805420
  802252:	e8 ef 0d 00 00       	call   803046 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802257:	83 c4 0c             	add    $0xc,%esp
  80225a:	6a 00                	push   $0x0
  80225c:	53                   	push   %ebx
  80225d:	6a 00                	push   $0x0
  80225f:	e8 6d 0d 00 00       	call   802fd1 <ipc_recv>
}
  802264:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802267:	5b                   	pop    %ebx
  802268:	5e                   	pop    %esi
  802269:	5d                   	pop    %ebp
  80226a:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80226b:	83 ec 0c             	sub    $0xc,%esp
  80226e:	6a 01                	push   $0x1
  802270:	e8 27 0e 00 00       	call   80309c <ipc_find_env>
  802275:	a3 20 54 80 00       	mov    %eax,0x805420
  80227a:	83 c4 10             	add    $0x10,%esp
  80227d:	eb c5                	jmp    802244 <fsipc+0x12>

0080227f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80227f:	55                   	push   %ebp
  802280:	89 e5                	mov    %esp,%ebp
  802282:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802285:	8b 45 08             	mov    0x8(%ebp),%eax
  802288:	8b 40 0c             	mov    0xc(%eax),%eax
  80228b:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  802290:	8b 45 0c             	mov    0xc(%ebp),%eax
  802293:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802298:	ba 00 00 00 00       	mov    $0x0,%edx
  80229d:	b8 02 00 00 00       	mov    $0x2,%eax
  8022a2:	e8 8b ff ff ff       	call   802232 <fsipc>
}
  8022a7:	c9                   	leave  
  8022a8:	c3                   	ret    

008022a9 <devfile_flush>:
{
  8022a9:	55                   	push   %ebp
  8022aa:	89 e5                	mov    %esp,%ebp
  8022ac:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8022af:	8b 45 08             	mov    0x8(%ebp),%eax
  8022b2:	8b 40 0c             	mov    0xc(%eax),%eax
  8022b5:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  8022ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8022bf:	b8 06 00 00 00       	mov    $0x6,%eax
  8022c4:	e8 69 ff ff ff       	call   802232 <fsipc>
}
  8022c9:	c9                   	leave  
  8022ca:	c3                   	ret    

008022cb <devfile_stat>:
{
  8022cb:	55                   	push   %ebp
  8022cc:	89 e5                	mov    %esp,%ebp
  8022ce:	53                   	push   %ebx
  8022cf:	83 ec 04             	sub    $0x4,%esp
  8022d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8022d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8022d8:	8b 40 0c             	mov    0xc(%eax),%eax
  8022db:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8022e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8022e5:	b8 05 00 00 00       	mov    $0x5,%eax
  8022ea:	e8 43 ff ff ff       	call   802232 <fsipc>
  8022ef:	85 c0                	test   %eax,%eax
  8022f1:	78 2c                	js     80231f <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8022f3:	83 ec 08             	sub    $0x8,%esp
  8022f6:	68 00 60 80 00       	push   $0x806000
  8022fb:	53                   	push   %ebx
  8022fc:	e8 60 ef ff ff       	call   801261 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802301:	a1 80 60 80 00       	mov    0x806080,%eax
  802306:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80230c:	a1 84 60 80 00       	mov    0x806084,%eax
  802311:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802317:	83 c4 10             	add    $0x10,%esp
  80231a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80231f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802322:	c9                   	leave  
  802323:	c3                   	ret    

00802324 <devfile_write>:
{
  802324:	55                   	push   %ebp
  802325:	89 e5                	mov    %esp,%ebp
  802327:	83 ec 0c             	sub    $0xc,%esp
  80232a:	8b 45 10             	mov    0x10(%ebp),%eax
  80232d:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  802332:	ba f8 0f 00 00       	mov    $0xff8,%edx
  802337:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80233a:	8b 55 08             	mov    0x8(%ebp),%edx
  80233d:	8b 52 0c             	mov    0xc(%edx),%edx
  802340:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  802346:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf,buf,n);
  80234b:	50                   	push   %eax
  80234c:	ff 75 0c             	pushl  0xc(%ebp)
  80234f:	68 08 60 80 00       	push   $0x806008
  802354:	e8 96 f0 ff ff       	call   8013ef <memmove>
	if((r = fsipc(FSREQ_WRITE,NULL))<0)
  802359:	ba 00 00 00 00       	mov    $0x0,%edx
  80235e:	b8 04 00 00 00       	mov    $0x4,%eax
  802363:	e8 ca fe ff ff       	call   802232 <fsipc>
}
  802368:	c9                   	leave  
  802369:	c3                   	ret    

0080236a <devfile_read>:
{
  80236a:	55                   	push   %ebp
  80236b:	89 e5                	mov    %esp,%ebp
  80236d:	56                   	push   %esi
  80236e:	53                   	push   %ebx
  80236f:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802372:	8b 45 08             	mov    0x8(%ebp),%eax
  802375:	8b 40 0c             	mov    0xc(%eax),%eax
  802378:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  80237d:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802383:	ba 00 00 00 00       	mov    $0x0,%edx
  802388:	b8 03 00 00 00       	mov    $0x3,%eax
  80238d:	e8 a0 fe ff ff       	call   802232 <fsipc>
  802392:	89 c3                	mov    %eax,%ebx
  802394:	85 c0                	test   %eax,%eax
  802396:	78 1f                	js     8023b7 <devfile_read+0x4d>
	assert(r <= n);
  802398:	39 f0                	cmp    %esi,%eax
  80239a:	77 24                	ja     8023c0 <devfile_read+0x56>
	assert(r <= PGSIZE);
  80239c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8023a1:	7f 33                	jg     8023d6 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8023a3:	83 ec 04             	sub    $0x4,%esp
  8023a6:	50                   	push   %eax
  8023a7:	68 00 60 80 00       	push   $0x806000
  8023ac:	ff 75 0c             	pushl  0xc(%ebp)
  8023af:	e8 3b f0 ff ff       	call   8013ef <memmove>
	return r;
  8023b4:	83 c4 10             	add    $0x10,%esp
}
  8023b7:	89 d8                	mov    %ebx,%eax
  8023b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023bc:	5b                   	pop    %ebx
  8023bd:	5e                   	pop    %esi
  8023be:	5d                   	pop    %ebp
  8023bf:	c3                   	ret    
	assert(r <= n);
  8023c0:	68 a8 3a 80 00       	push   $0x803aa8
  8023c5:	68 ac 34 80 00       	push   $0x8034ac
  8023ca:	6a 7c                	push   $0x7c
  8023cc:	68 af 3a 80 00       	push   $0x803aaf
  8023d1:	e8 a1 e6 ff ff       	call   800a77 <_panic>
	assert(r <= PGSIZE);
  8023d6:	68 ba 3a 80 00       	push   $0x803aba
  8023db:	68 ac 34 80 00       	push   $0x8034ac
  8023e0:	6a 7d                	push   $0x7d
  8023e2:	68 af 3a 80 00       	push   $0x803aaf
  8023e7:	e8 8b e6 ff ff       	call   800a77 <_panic>

008023ec <open>:
{
  8023ec:	55                   	push   %ebp
  8023ed:	89 e5                	mov    %esp,%ebp
  8023ef:	56                   	push   %esi
  8023f0:	53                   	push   %ebx
  8023f1:	83 ec 1c             	sub    $0x1c,%esp
  8023f4:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8023f7:	56                   	push   %esi
  8023f8:	e8 2d ee ff ff       	call   80122a <strlen>
  8023fd:	83 c4 10             	add    $0x10,%esp
  802400:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802405:	7f 6c                	jg     802473 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  802407:	83 ec 0c             	sub    $0xc,%esp
  80240a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80240d:	50                   	push   %eax
  80240e:	e8 b4 f8 ff ff       	call   801cc7 <fd_alloc>
  802413:	89 c3                	mov    %eax,%ebx
  802415:	83 c4 10             	add    $0x10,%esp
  802418:	85 c0                	test   %eax,%eax
  80241a:	78 3c                	js     802458 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  80241c:	83 ec 08             	sub    $0x8,%esp
  80241f:	56                   	push   %esi
  802420:	68 00 60 80 00       	push   $0x806000
  802425:	e8 37 ee ff ff       	call   801261 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80242a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80242d:	a3 00 64 80 00       	mov    %eax,0x806400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  802432:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802435:	b8 01 00 00 00       	mov    $0x1,%eax
  80243a:	e8 f3 fd ff ff       	call   802232 <fsipc>
  80243f:	89 c3                	mov    %eax,%ebx
  802441:	83 c4 10             	add    $0x10,%esp
  802444:	85 c0                	test   %eax,%eax
  802446:	78 19                	js     802461 <open+0x75>
	return fd2num(fd);
  802448:	83 ec 0c             	sub    $0xc,%esp
  80244b:	ff 75 f4             	pushl  -0xc(%ebp)
  80244e:	e8 4d f8 ff ff       	call   801ca0 <fd2num>
  802453:	89 c3                	mov    %eax,%ebx
  802455:	83 c4 10             	add    $0x10,%esp
}
  802458:	89 d8                	mov    %ebx,%eax
  80245a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80245d:	5b                   	pop    %ebx
  80245e:	5e                   	pop    %esi
  80245f:	5d                   	pop    %ebp
  802460:	c3                   	ret    
		fd_close(fd, 0);
  802461:	83 ec 08             	sub    $0x8,%esp
  802464:	6a 00                	push   $0x0
  802466:	ff 75 f4             	pushl  -0xc(%ebp)
  802469:	e8 54 f9 ff ff       	call   801dc2 <fd_close>
		return r;
  80246e:	83 c4 10             	add    $0x10,%esp
  802471:	eb e5                	jmp    802458 <open+0x6c>
		return -E_BAD_PATH;
  802473:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  802478:	eb de                	jmp    802458 <open+0x6c>

0080247a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80247a:	55                   	push   %ebp
  80247b:	89 e5                	mov    %esp,%ebp
  80247d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  802480:	ba 00 00 00 00       	mov    $0x0,%edx
  802485:	b8 08 00 00 00       	mov    $0x8,%eax
  80248a:	e8 a3 fd ff ff       	call   802232 <fsipc>
}
  80248f:	c9                   	leave  
  802490:	c3                   	ret    

00802491 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  802491:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  802495:	7e 38                	jle    8024cf <writebuf+0x3e>
{
  802497:	55                   	push   %ebp
  802498:	89 e5                	mov    %esp,%ebp
  80249a:	53                   	push   %ebx
  80249b:	83 ec 08             	sub    $0x8,%esp
  80249e:	89 c3                	mov    %eax,%ebx
		ssize_t result = write(b->fd, b->buf, b->idx);
  8024a0:	ff 70 04             	pushl  0x4(%eax)
  8024a3:	8d 40 10             	lea    0x10(%eax),%eax
  8024a6:	50                   	push   %eax
  8024a7:	ff 33                	pushl  (%ebx)
  8024a9:	e8 a7 fb ff ff       	call   802055 <write>
		if (result > 0)
  8024ae:	83 c4 10             	add    $0x10,%esp
  8024b1:	85 c0                	test   %eax,%eax
  8024b3:	7e 03                	jle    8024b8 <writebuf+0x27>
			b->result += result;
  8024b5:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8024b8:	39 43 04             	cmp    %eax,0x4(%ebx)
  8024bb:	74 0d                	je     8024ca <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  8024bd:	85 c0                	test   %eax,%eax
  8024bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8024c4:	0f 4f c2             	cmovg  %edx,%eax
  8024c7:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8024ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8024cd:	c9                   	leave  
  8024ce:	c3                   	ret    
  8024cf:	f3 c3                	repz ret 

008024d1 <putch>:

static void
putch(int ch, void *thunk)
{
  8024d1:	55                   	push   %ebp
  8024d2:	89 e5                	mov    %esp,%ebp
  8024d4:	53                   	push   %ebx
  8024d5:	83 ec 04             	sub    $0x4,%esp
  8024d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8024db:	8b 53 04             	mov    0x4(%ebx),%edx
  8024de:	8d 42 01             	lea    0x1(%edx),%eax
  8024e1:	89 43 04             	mov    %eax,0x4(%ebx)
  8024e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8024e7:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8024eb:	3d 00 01 00 00       	cmp    $0x100,%eax
  8024f0:	74 06                	je     8024f8 <putch+0x27>
		writebuf(b);
		b->idx = 0;
	}
}
  8024f2:	83 c4 04             	add    $0x4,%esp
  8024f5:	5b                   	pop    %ebx
  8024f6:	5d                   	pop    %ebp
  8024f7:	c3                   	ret    
		writebuf(b);
  8024f8:	89 d8                	mov    %ebx,%eax
  8024fa:	e8 92 ff ff ff       	call   802491 <writebuf>
		b->idx = 0;
  8024ff:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
}
  802506:	eb ea                	jmp    8024f2 <putch+0x21>

00802508 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  802508:	55                   	push   %ebp
  802509:	89 e5                	mov    %esp,%ebp
  80250b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  802511:	8b 45 08             	mov    0x8(%ebp),%eax
  802514:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  80251a:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  802521:	00 00 00 
	b.result = 0;
  802524:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80252b:	00 00 00 
	b.error = 1;
  80252e:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  802535:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  802538:	ff 75 10             	pushl  0x10(%ebp)
  80253b:	ff 75 0c             	pushl  0xc(%ebp)
  80253e:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  802544:	50                   	push   %eax
  802545:	68 d1 24 80 00       	push   $0x8024d1
  80254a:	e8 00 e7 ff ff       	call   800c4f <vprintfmt>
	if (b.idx > 0)
  80254f:	83 c4 10             	add    $0x10,%esp
  802552:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  802559:	7f 11                	jg     80256c <vfprintf+0x64>
		writebuf(&b);

	return (b.result ? b.result : b.error);
  80255b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  802561:	85 c0                	test   %eax,%eax
  802563:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  80256a:	c9                   	leave  
  80256b:	c3                   	ret    
		writebuf(&b);
  80256c:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  802572:	e8 1a ff ff ff       	call   802491 <writebuf>
  802577:	eb e2                	jmp    80255b <vfprintf+0x53>

00802579 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  802579:	55                   	push   %ebp
  80257a:	89 e5                	mov    %esp,%ebp
  80257c:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80257f:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  802582:	50                   	push   %eax
  802583:	ff 75 0c             	pushl  0xc(%ebp)
  802586:	ff 75 08             	pushl  0x8(%ebp)
  802589:	e8 7a ff ff ff       	call   802508 <vfprintf>
	va_end(ap);

	return cnt;
}
  80258e:	c9                   	leave  
  80258f:	c3                   	ret    

00802590 <printf>:

int
printf(const char *fmt, ...)
{
  802590:	55                   	push   %ebp
  802591:	89 e5                	mov    %esp,%ebp
  802593:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  802596:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  802599:	50                   	push   %eax
  80259a:	ff 75 08             	pushl  0x8(%ebp)
  80259d:	6a 01                	push   $0x1
  80259f:	e8 64 ff ff ff       	call   802508 <vfprintf>
	va_end(ap);

	return cnt;
}
  8025a4:	c9                   	leave  
  8025a5:	c3                   	ret    

008025a6 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8025a6:	55                   	push   %ebp
  8025a7:	89 e5                	mov    %esp,%ebp
  8025a9:	57                   	push   %edi
  8025aa:	56                   	push   %esi
  8025ab:	53                   	push   %ebx
  8025ac:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8025b2:	6a 00                	push   $0x0
  8025b4:	ff 75 08             	pushl  0x8(%ebp)
  8025b7:	e8 30 fe ff ff       	call   8023ec <open>
  8025bc:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  8025c2:	83 c4 10             	add    $0x10,%esp
  8025c5:	85 c0                	test   %eax,%eax
  8025c7:	0f 88 40 03 00 00    	js     80290d <spawn+0x367>
  8025cd:	89 c2                	mov    %eax,%edx
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8025cf:	83 ec 04             	sub    $0x4,%esp
  8025d2:	68 00 02 00 00       	push   $0x200
  8025d7:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8025dd:	50                   	push   %eax
  8025de:	52                   	push   %edx
  8025df:	e8 2a fa ff ff       	call   80200e <readn>
  8025e4:	83 c4 10             	add    $0x10,%esp
  8025e7:	3d 00 02 00 00       	cmp    $0x200,%eax
  8025ec:	75 5d                	jne    80264b <spawn+0xa5>
	    || elf->e_magic != ELF_MAGIC) {
  8025ee:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8025f5:	45 4c 46 
  8025f8:	75 51                	jne    80264b <spawn+0xa5>
  8025fa:	b8 07 00 00 00       	mov    $0x7,%eax
  8025ff:	cd 30                	int    $0x30
  802601:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  802607:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  80260d:	85 c0                	test   %eax,%eax
  80260f:	0f 88 6e 04 00 00    	js     802a83 <spawn+0x4dd>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  802615:	25 ff 03 00 00       	and    $0x3ff,%eax
  80261a:	6b f0 7c             	imul   $0x7c,%eax,%esi
  80261d:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  802623:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  802629:	b9 11 00 00 00       	mov    $0x11,%ecx
  80262e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  802630:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  802636:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80263c:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  802641:	be 00 00 00 00       	mov    $0x0,%esi
  802646:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802649:	eb 4b                	jmp    802696 <spawn+0xf0>
		close(fd);
  80264b:	83 ec 0c             	sub    $0xc,%esp
  80264e:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  802654:	e8 f2 f7 ff ff       	call   801e4b <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  802659:	83 c4 0c             	add    $0xc,%esp
  80265c:	68 7f 45 4c 46       	push   $0x464c457f
  802661:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  802667:	68 c6 3a 80 00       	push   $0x803ac6
  80266c:	e8 e1 e4 ff ff       	call   800b52 <cprintf>
		return -E_NOT_EXEC;
  802671:	83 c4 10             	add    $0x10,%esp
  802674:	c7 85 90 fd ff ff f2 	movl   $0xfffffff2,-0x270(%ebp)
  80267b:	ff ff ff 
  80267e:	e9 8a 02 00 00       	jmp    80290d <spawn+0x367>
		string_size += strlen(argv[argc]) + 1;
  802683:	83 ec 0c             	sub    $0xc,%esp
  802686:	50                   	push   %eax
  802687:	e8 9e eb ff ff       	call   80122a <strlen>
  80268c:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  802690:	83 c3 01             	add    $0x1,%ebx
  802693:	83 c4 10             	add    $0x10,%esp
  802696:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  80269d:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8026a0:	85 c0                	test   %eax,%eax
  8026a2:	75 df                	jne    802683 <spawn+0xdd>
  8026a4:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  8026aa:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8026b0:	bf 00 10 40 00       	mov    $0x401000,%edi
  8026b5:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8026b7:	89 fa                	mov    %edi,%edx
  8026b9:	83 e2 fc             	and    $0xfffffffc,%edx
  8026bc:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8026c3:	29 c2                	sub    %eax,%edx
  8026c5:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8026cb:	8d 42 f8             	lea    -0x8(%edx),%eax
  8026ce:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8026d3:	0f 86 bb 03 00 00    	jbe    802a94 <spawn+0x4ee>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8026d9:	83 ec 04             	sub    $0x4,%esp
  8026dc:	6a 07                	push   $0x7
  8026de:	68 00 00 40 00       	push   $0x400000
  8026e3:	6a 00                	push   $0x0
  8026e5:	e8 70 ef ff ff       	call   80165a <sys_page_alloc>
  8026ea:	83 c4 10             	add    $0x10,%esp
  8026ed:	85 c0                	test   %eax,%eax
  8026ef:	0f 88 a4 03 00 00    	js     802a99 <spawn+0x4f3>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8026f5:	be 00 00 00 00       	mov    $0x0,%esi
  8026fa:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  802700:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802703:	eb 30                	jmp    802735 <spawn+0x18f>
		argv_store[i] = UTEMP2USTACK(string_store);
  802705:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  80270b:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  802711:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  802714:	83 ec 08             	sub    $0x8,%esp
  802717:	ff 34 b3             	pushl  (%ebx,%esi,4)
  80271a:	57                   	push   %edi
  80271b:	e8 41 eb ff ff       	call   801261 <strcpy>
		string_store += strlen(argv[i]) + 1;
  802720:	83 c4 04             	add    $0x4,%esp
  802723:	ff 34 b3             	pushl  (%ebx,%esi,4)
  802726:	e8 ff ea ff ff       	call   80122a <strlen>
  80272b:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  80272f:	83 c6 01             	add    $0x1,%esi
  802732:	83 c4 10             	add    $0x10,%esp
  802735:	39 b5 8c fd ff ff    	cmp    %esi,-0x274(%ebp)
  80273b:	7f c8                	jg     802705 <spawn+0x15f>
	}
	argv_store[argc] = 0;
  80273d:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802743:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  802749:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  802750:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  802756:	0f 85 8c 00 00 00    	jne    8027e8 <spawn+0x242>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  80275c:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  802762:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  802768:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  80276b:	89 f8                	mov    %edi,%eax
  80276d:	8b bd 88 fd ff ff    	mov    -0x278(%ebp),%edi
  802773:	89 78 f8             	mov    %edi,-0x8(%eax)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  802776:	2d 08 30 80 11       	sub    $0x11803008,%eax
  80277b:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  802781:	83 ec 0c             	sub    $0xc,%esp
  802784:	6a 07                	push   $0x7
  802786:	68 00 d0 bf ee       	push   $0xeebfd000
  80278b:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802791:	68 00 00 40 00       	push   $0x400000
  802796:	6a 00                	push   $0x0
  802798:	e8 00 ef ff ff       	call   80169d <sys_page_map>
  80279d:	89 c3                	mov    %eax,%ebx
  80279f:	83 c4 20             	add    $0x20,%esp
  8027a2:	85 c0                	test   %eax,%eax
  8027a4:	0f 88 65 03 00 00    	js     802b0f <spawn+0x569>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8027aa:	83 ec 08             	sub    $0x8,%esp
  8027ad:	68 00 00 40 00       	push   $0x400000
  8027b2:	6a 00                	push   $0x0
  8027b4:	e8 26 ef ff ff       	call   8016df <sys_page_unmap>
  8027b9:	89 c3                	mov    %eax,%ebx
  8027bb:	83 c4 10             	add    $0x10,%esp
  8027be:	85 c0                	test   %eax,%eax
  8027c0:	0f 88 49 03 00 00    	js     802b0f <spawn+0x569>
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8027c6:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  8027cc:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  8027d3:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8027d9:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  8027e0:	00 00 00 
  8027e3:	e9 56 01 00 00       	jmp    80293e <spawn+0x398>
	assert(string_store == (char*)UTEMP + PGSIZE);
  8027e8:	68 50 3b 80 00       	push   $0x803b50
  8027ed:	68 ac 34 80 00       	push   $0x8034ac
  8027f2:	68 f2 00 00 00       	push   $0xf2
  8027f7:	68 e0 3a 80 00       	push   $0x803ae0
  8027fc:	e8 76 e2 ff ff       	call   800a77 <_panic>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802801:	83 ec 04             	sub    $0x4,%esp
  802804:	6a 07                	push   $0x7
  802806:	68 00 00 40 00       	push   $0x400000
  80280b:	6a 00                	push   $0x0
  80280d:	e8 48 ee ff ff       	call   80165a <sys_page_alloc>
  802812:	83 c4 10             	add    $0x10,%esp
  802815:	85 c0                	test   %eax,%eax
  802817:	0f 88 87 02 00 00    	js     802aa4 <spawn+0x4fe>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  80281d:	83 ec 08             	sub    $0x8,%esp
  802820:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802826:	01 f0                	add    %esi,%eax
  802828:	50                   	push   %eax
  802829:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  80282f:	e8 a3 f8 ff ff       	call   8020d7 <seek>
  802834:	83 c4 10             	add    $0x10,%esp
  802837:	85 c0                	test   %eax,%eax
  802839:	0f 88 6c 02 00 00    	js     802aab <spawn+0x505>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  80283f:	83 ec 04             	sub    $0x4,%esp
  802842:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802848:	29 f0                	sub    %esi,%eax
  80284a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80284f:	b9 00 10 00 00       	mov    $0x1000,%ecx
  802854:	0f 47 c1             	cmova  %ecx,%eax
  802857:	50                   	push   %eax
  802858:	68 00 00 40 00       	push   $0x400000
  80285d:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  802863:	e8 a6 f7 ff ff       	call   80200e <readn>
  802868:	83 c4 10             	add    $0x10,%esp
  80286b:	85 c0                	test   %eax,%eax
  80286d:	0f 88 3f 02 00 00    	js     802ab2 <spawn+0x50c>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  802873:	83 ec 0c             	sub    $0xc,%esp
  802876:	57                   	push   %edi
  802877:	03 b5 88 fd ff ff    	add    -0x278(%ebp),%esi
  80287d:	56                   	push   %esi
  80287e:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  802884:	68 00 00 40 00       	push   $0x400000
  802889:	6a 00                	push   $0x0
  80288b:	e8 0d ee ff ff       	call   80169d <sys_page_map>
  802890:	83 c4 20             	add    $0x20,%esp
  802893:	85 c0                	test   %eax,%eax
  802895:	0f 88 80 00 00 00    	js     80291b <spawn+0x375>
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
  80289b:	83 ec 08             	sub    $0x8,%esp
  80289e:	68 00 00 40 00       	push   $0x400000
  8028a3:	6a 00                	push   $0x0
  8028a5:	e8 35 ee ff ff       	call   8016df <sys_page_unmap>
  8028aa:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < memsz; i += PGSIZE) {
  8028ad:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8028b3:	89 de                	mov    %ebx,%esi
  8028b5:	39 9d 8c fd ff ff    	cmp    %ebx,-0x274(%ebp)
  8028bb:	76 73                	jbe    802930 <spawn+0x38a>
		if (i >= filesz) {
  8028bd:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  8028c3:	0f 87 38 ff ff ff    	ja     802801 <spawn+0x25b>
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  8028c9:	83 ec 04             	sub    $0x4,%esp
  8028cc:	57                   	push   %edi
  8028cd:	03 b5 88 fd ff ff    	add    -0x278(%ebp),%esi
  8028d3:	56                   	push   %esi
  8028d4:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8028da:	e8 7b ed ff ff       	call   80165a <sys_page_alloc>
  8028df:	83 c4 10             	add    $0x10,%esp
  8028e2:	85 c0                	test   %eax,%eax
  8028e4:	79 c7                	jns    8028ad <spawn+0x307>
  8028e6:	89 c7                	mov    %eax,%edi
	sys_env_destroy(child);
  8028e8:	83 ec 0c             	sub    $0xc,%esp
  8028eb:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8028f1:	e8 e5 ec ff ff       	call   8015db <sys_env_destroy>
	close(fd);
  8028f6:	83 c4 04             	add    $0x4,%esp
  8028f9:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  8028ff:	e8 47 f5 ff ff       	call   801e4b <close>
	return r;
  802904:	83 c4 10             	add    $0x10,%esp
  802907:	89 bd 90 fd ff ff    	mov    %edi,-0x270(%ebp)
}
  80290d:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  802913:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802916:	5b                   	pop    %ebx
  802917:	5e                   	pop    %esi
  802918:	5f                   	pop    %edi
  802919:	5d                   	pop    %ebp
  80291a:	c3                   	ret    
				panic("spawn: sys_page_map data: %e", r);
  80291b:	50                   	push   %eax
  80291c:	68 ec 3a 80 00       	push   $0x803aec
  802921:	68 25 01 00 00       	push   $0x125
  802926:	68 e0 3a 80 00       	push   $0x803ae0
  80292b:	e8 47 e1 ff ff       	call   800a77 <_panic>
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802930:	83 85 7c fd ff ff 01 	addl   $0x1,-0x284(%ebp)
  802937:	83 85 78 fd ff ff 20 	addl   $0x20,-0x288(%ebp)
  80293e:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  802945:	3b 85 7c fd ff ff    	cmp    -0x284(%ebp),%eax
  80294b:	7e 71                	jle    8029be <spawn+0x418>
		if (ph->p_type != ELF_PROG_LOAD)
  80294d:	8b 8d 78 fd ff ff    	mov    -0x288(%ebp),%ecx
  802953:	83 39 01             	cmpl   $0x1,(%ecx)
  802956:	75 d8                	jne    802930 <spawn+0x38a>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  802958:	8b 41 18             	mov    0x18(%ecx),%eax
  80295b:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  80295e:	83 f8 01             	cmp    $0x1,%eax
  802961:	19 ff                	sbb    %edi,%edi
  802963:	83 e7 fe             	and    $0xfffffffe,%edi
  802966:	83 c7 07             	add    $0x7,%edi
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  802969:	8b 71 04             	mov    0x4(%ecx),%esi
  80296c:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  802972:	8b 59 10             	mov    0x10(%ecx),%ebx
  802975:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  80297b:	8b 41 14             	mov    0x14(%ecx),%eax
  80297e:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  802984:	8b 51 08             	mov    0x8(%ecx),%edx
  802987:	89 95 88 fd ff ff    	mov    %edx,-0x278(%ebp)
	if ((i = PGOFF(va))) {
  80298d:	89 d0                	mov    %edx,%eax
  80298f:	25 ff 0f 00 00       	and    $0xfff,%eax
  802994:	74 1e                	je     8029b4 <spawn+0x40e>
		va -= i;
  802996:	29 c2                	sub    %eax,%edx
  802998:	89 95 88 fd ff ff    	mov    %edx,-0x278(%ebp)
		memsz += i;
  80299e:	01 85 8c fd ff ff    	add    %eax,-0x274(%ebp)
		filesz += i;
  8029a4:	01 c3                	add    %eax,%ebx
  8029a6:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
		fileoffset -= i;
  8029ac:	29 c6                	sub    %eax,%esi
  8029ae:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
	for (i = 0; i < memsz; i += PGSIZE) {
  8029b4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8029b9:	e9 f5 fe ff ff       	jmp    8028b3 <spawn+0x30d>
	close(fd);
  8029be:	83 ec 0c             	sub    $0xc,%esp
  8029c1:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  8029c7:	e8 7f f4 ff ff       	call   801e4b <close>
  8029cc:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	uintptr_t addr;
	int r;

	for(addr=(uintptr_t)UTEXT; addr<USTACKTOP;addr+=PGSIZE){
  8029cf:	bb 00 00 80 00       	mov    $0x800000,%ebx
  8029d4:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
  8029da:	eb 12                	jmp    8029ee <spawn+0x448>
  8029dc:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8029e2:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8029e8:	0f 84 cb 00 00 00    	je     802ab9 <spawn+0x513>
	   if((uvpd[PDX(addr)]&PTE_P) && (uvpt[PGNUM(addr)]&PTE_P)){
  8029ee:	89 d8                	mov    %ebx,%eax
  8029f0:	c1 e8 16             	shr    $0x16,%eax
  8029f3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8029fa:	a8 01                	test   $0x1,%al
  8029fc:	74 de                	je     8029dc <spawn+0x436>
  8029fe:	89 d8                	mov    %ebx,%eax
  802a00:	c1 e8 0c             	shr    $0xc,%eax
  802a03:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802a0a:	f6 c2 01             	test   $0x1,%dl
  802a0d:	74 cd                	je     8029dc <spawn+0x436>
	      if(uvpt[PGNUM(addr)] & PTE_SHARE){
  802a0f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802a16:	f6 c6 04             	test   $0x4,%dh
  802a19:	74 c1                	je     8029dc <spawn+0x436>
	        if((r=sys_page_map(thisenv->env_id,(void *)addr,child,(void *)addr, uvpt[PGNUM(addr)]&PTE_SYSCALL))<0)
  802a1b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802a22:	8b 15 24 54 80 00    	mov    0x805424,%edx
  802a28:	8b 52 48             	mov    0x48(%edx),%edx
  802a2b:	83 ec 0c             	sub    $0xc,%esp
  802a2e:	25 07 0e 00 00       	and    $0xe07,%eax
  802a33:	50                   	push   %eax
  802a34:	53                   	push   %ebx
  802a35:	56                   	push   %esi
  802a36:	53                   	push   %ebx
  802a37:	52                   	push   %edx
  802a38:	e8 60 ec ff ff       	call   80169d <sys_page_map>
  802a3d:	83 c4 20             	add    $0x20,%esp
  802a40:	85 c0                	test   %eax,%eax
  802a42:	79 98                	jns    8029dc <spawn+0x436>
		panic("copy_shared_pages: %e", r);
  802a44:	50                   	push   %eax
  802a45:	68 3a 3b 80 00       	push   $0x803b3a
  802a4a:	68 82 00 00 00       	push   $0x82
  802a4f:	68 e0 3a 80 00       	push   $0x803ae0
  802a54:	e8 1e e0 ff ff       	call   800a77 <_panic>
		panic("sys_env_set_trapframe: %e", r);
  802a59:	50                   	push   %eax
  802a5a:	68 09 3b 80 00       	push   $0x803b09
  802a5f:	68 86 00 00 00       	push   $0x86
  802a64:	68 e0 3a 80 00       	push   $0x803ae0
  802a69:	e8 09 e0 ff ff       	call   800a77 <_panic>
		panic("sys_env_set_status: %e", r);
  802a6e:	50                   	push   %eax
  802a6f:	68 23 3b 80 00       	push   $0x803b23
  802a74:	68 89 00 00 00       	push   $0x89
  802a79:	68 e0 3a 80 00       	push   $0x803ae0
  802a7e:	e8 f4 df ff ff       	call   800a77 <_panic>
		return r;
  802a83:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802a89:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  802a8f:	e9 79 fe ff ff       	jmp    80290d <spawn+0x367>
		return -E_NO_MEM;
  802a94:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return r;
  802a99:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  802a9f:	e9 69 fe ff ff       	jmp    80290d <spawn+0x367>
  802aa4:	89 c7                	mov    %eax,%edi
  802aa6:	e9 3d fe ff ff       	jmp    8028e8 <spawn+0x342>
  802aab:	89 c7                	mov    %eax,%edi
  802aad:	e9 36 fe ff ff       	jmp    8028e8 <spawn+0x342>
  802ab2:	89 c7                	mov    %eax,%edi
  802ab4:	e9 2f fe ff ff       	jmp    8028e8 <spawn+0x342>
	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  802ab9:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  802ac0:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802ac3:	83 ec 08             	sub    $0x8,%esp
  802ac6:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802acc:	50                   	push   %eax
  802acd:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802ad3:	e8 8b ec ff ff       	call   801763 <sys_env_set_trapframe>
  802ad8:	83 c4 10             	add    $0x10,%esp
  802adb:	85 c0                	test   %eax,%eax
  802add:	0f 88 76 ff ff ff    	js     802a59 <spawn+0x4b3>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802ae3:	83 ec 08             	sub    $0x8,%esp
  802ae6:	6a 02                	push   $0x2
  802ae8:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802aee:	e8 2e ec ff ff       	call   801721 <sys_env_set_status>
  802af3:	83 c4 10             	add    $0x10,%esp
  802af6:	85 c0                	test   %eax,%eax
  802af8:	0f 88 70 ff ff ff    	js     802a6e <spawn+0x4c8>
	return child;
  802afe:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802b04:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  802b0a:	e9 fe fd ff ff       	jmp    80290d <spawn+0x367>
	sys_page_unmap(0, UTEMP);
  802b0f:	83 ec 08             	sub    $0x8,%esp
  802b12:	68 00 00 40 00       	push   $0x400000
  802b17:	6a 00                	push   $0x0
  802b19:	e8 c1 eb ff ff       	call   8016df <sys_page_unmap>
  802b1e:	83 c4 10             	add    $0x10,%esp
  802b21:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  802b27:	e9 e1 fd ff ff       	jmp    80290d <spawn+0x367>

00802b2c <spawnl>:
{
  802b2c:	55                   	push   %ebp
  802b2d:	89 e5                	mov    %esp,%ebp
  802b2f:	57                   	push   %edi
  802b30:	56                   	push   %esi
  802b31:	53                   	push   %ebx
  802b32:	83 ec 0c             	sub    $0xc,%esp
	va_start(vl, arg0);
  802b35:	8d 55 10             	lea    0x10(%ebp),%edx
	int argc=0;
  802b38:	b8 00 00 00 00       	mov    $0x0,%eax
	while(va_arg(vl, void *) != NULL)
  802b3d:	eb 05                	jmp    802b44 <spawnl+0x18>
		argc++;
  802b3f:	83 c0 01             	add    $0x1,%eax
	while(va_arg(vl, void *) != NULL)
  802b42:	89 ca                	mov    %ecx,%edx
  802b44:	8d 4a 04             	lea    0x4(%edx),%ecx
  802b47:	83 3a 00             	cmpl   $0x0,(%edx)
  802b4a:	75 f3                	jne    802b3f <spawnl+0x13>
	const char *argv[argc+2];
  802b4c:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  802b53:	83 e2 f0             	and    $0xfffffff0,%edx
  802b56:	29 d4                	sub    %edx,%esp
  802b58:	8d 54 24 03          	lea    0x3(%esp),%edx
  802b5c:	c1 ea 02             	shr    $0x2,%edx
  802b5f:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  802b66:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  802b68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802b6b:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  802b72:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  802b79:	00 
	va_start(vl, arg0);
  802b7a:	8d 4d 10             	lea    0x10(%ebp),%ecx
  802b7d:	89 c2                	mov    %eax,%edx
	for(i=0;i<argc;i++)
  802b7f:	b8 00 00 00 00       	mov    $0x0,%eax
  802b84:	eb 0b                	jmp    802b91 <spawnl+0x65>
		argv[i+1] = va_arg(vl, const char *);
  802b86:	83 c0 01             	add    $0x1,%eax
  802b89:	8b 39                	mov    (%ecx),%edi
  802b8b:	89 3c 83             	mov    %edi,(%ebx,%eax,4)
  802b8e:	8d 49 04             	lea    0x4(%ecx),%ecx
	for(i=0;i<argc;i++)
  802b91:	39 d0                	cmp    %edx,%eax
  802b93:	75 f1                	jne    802b86 <spawnl+0x5a>
	return spawn(prog, argv);
  802b95:	83 ec 08             	sub    $0x8,%esp
  802b98:	56                   	push   %esi
  802b99:	ff 75 08             	pushl  0x8(%ebp)
  802b9c:	e8 05 fa ff ff       	call   8025a6 <spawn>
}
  802ba1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802ba4:	5b                   	pop    %ebx
  802ba5:	5e                   	pop    %esi
  802ba6:	5f                   	pop    %edi
  802ba7:	5d                   	pop    %ebp
  802ba8:	c3                   	ret    

00802ba9 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802ba9:	55                   	push   %ebp
  802baa:	89 e5                	mov    %esp,%ebp
  802bac:	56                   	push   %esi
  802bad:	53                   	push   %ebx
  802bae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802bb1:	83 ec 0c             	sub    $0xc,%esp
  802bb4:	ff 75 08             	pushl  0x8(%ebp)
  802bb7:	e8 f4 f0 ff ff       	call   801cb0 <fd2data>
  802bbc:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802bbe:	83 c4 08             	add    $0x8,%esp
  802bc1:	68 78 3b 80 00       	push   $0x803b78
  802bc6:	53                   	push   %ebx
  802bc7:	e8 95 e6 ff ff       	call   801261 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802bcc:	8b 46 04             	mov    0x4(%esi),%eax
  802bcf:	2b 06                	sub    (%esi),%eax
  802bd1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802bd7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802bde:	00 00 00 
	stat->st_dev = &devpipe;
  802be1:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  802be8:	40 80 00 
	return 0;
}
  802beb:	b8 00 00 00 00       	mov    $0x0,%eax
  802bf0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802bf3:	5b                   	pop    %ebx
  802bf4:	5e                   	pop    %esi
  802bf5:	5d                   	pop    %ebp
  802bf6:	c3                   	ret    

00802bf7 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802bf7:	55                   	push   %ebp
  802bf8:	89 e5                	mov    %esp,%ebp
  802bfa:	53                   	push   %ebx
  802bfb:	83 ec 0c             	sub    $0xc,%esp
  802bfe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802c01:	53                   	push   %ebx
  802c02:	6a 00                	push   $0x0
  802c04:	e8 d6 ea ff ff       	call   8016df <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802c09:	89 1c 24             	mov    %ebx,(%esp)
  802c0c:	e8 9f f0 ff ff       	call   801cb0 <fd2data>
  802c11:	83 c4 08             	add    $0x8,%esp
  802c14:	50                   	push   %eax
  802c15:	6a 00                	push   $0x0
  802c17:	e8 c3 ea ff ff       	call   8016df <sys_page_unmap>
}
  802c1c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802c1f:	c9                   	leave  
  802c20:	c3                   	ret    

00802c21 <_pipeisclosed>:
{
  802c21:	55                   	push   %ebp
  802c22:	89 e5                	mov    %esp,%ebp
  802c24:	57                   	push   %edi
  802c25:	56                   	push   %esi
  802c26:	53                   	push   %ebx
  802c27:	83 ec 1c             	sub    $0x1c,%esp
  802c2a:	89 c7                	mov    %eax,%edi
  802c2c:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  802c2e:	a1 24 54 80 00       	mov    0x805424,%eax
  802c33:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802c36:	83 ec 0c             	sub    $0xc,%esp
  802c39:	57                   	push   %edi
  802c3a:	e8 96 04 00 00       	call   8030d5 <pageref>
  802c3f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  802c42:	89 34 24             	mov    %esi,(%esp)
  802c45:	e8 8b 04 00 00       	call   8030d5 <pageref>
		nn = thisenv->env_runs;
  802c4a:	8b 15 24 54 80 00    	mov    0x805424,%edx
  802c50:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802c53:	83 c4 10             	add    $0x10,%esp
  802c56:	39 cb                	cmp    %ecx,%ebx
  802c58:	74 1b                	je     802c75 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  802c5a:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802c5d:	75 cf                	jne    802c2e <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802c5f:	8b 42 58             	mov    0x58(%edx),%eax
  802c62:	6a 01                	push   $0x1
  802c64:	50                   	push   %eax
  802c65:	53                   	push   %ebx
  802c66:	68 7f 3b 80 00       	push   $0x803b7f
  802c6b:	e8 e2 de ff ff       	call   800b52 <cprintf>
  802c70:	83 c4 10             	add    $0x10,%esp
  802c73:	eb b9                	jmp    802c2e <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  802c75:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802c78:	0f 94 c0             	sete   %al
  802c7b:	0f b6 c0             	movzbl %al,%eax
}
  802c7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802c81:	5b                   	pop    %ebx
  802c82:	5e                   	pop    %esi
  802c83:	5f                   	pop    %edi
  802c84:	5d                   	pop    %ebp
  802c85:	c3                   	ret    

00802c86 <devpipe_write>:
{
  802c86:	55                   	push   %ebp
  802c87:	89 e5                	mov    %esp,%ebp
  802c89:	57                   	push   %edi
  802c8a:	56                   	push   %esi
  802c8b:	53                   	push   %ebx
  802c8c:	83 ec 28             	sub    $0x28,%esp
  802c8f:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  802c92:	56                   	push   %esi
  802c93:	e8 18 f0 ff ff       	call   801cb0 <fd2data>
  802c98:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802c9a:	83 c4 10             	add    $0x10,%esp
  802c9d:	bf 00 00 00 00       	mov    $0x0,%edi
  802ca2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802ca5:	74 4f                	je     802cf6 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802ca7:	8b 43 04             	mov    0x4(%ebx),%eax
  802caa:	8b 0b                	mov    (%ebx),%ecx
  802cac:	8d 51 20             	lea    0x20(%ecx),%edx
  802caf:	39 d0                	cmp    %edx,%eax
  802cb1:	72 14                	jb     802cc7 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  802cb3:	89 da                	mov    %ebx,%edx
  802cb5:	89 f0                	mov    %esi,%eax
  802cb7:	e8 65 ff ff ff       	call   802c21 <_pipeisclosed>
  802cbc:	85 c0                	test   %eax,%eax
  802cbe:	75 3a                	jne    802cfa <devpipe_write+0x74>
			sys_yield();
  802cc0:	e8 76 e9 ff ff       	call   80163b <sys_yield>
  802cc5:	eb e0                	jmp    802ca7 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802cc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802cca:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802cce:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802cd1:	89 c2                	mov    %eax,%edx
  802cd3:	c1 fa 1f             	sar    $0x1f,%edx
  802cd6:	89 d1                	mov    %edx,%ecx
  802cd8:	c1 e9 1b             	shr    $0x1b,%ecx
  802cdb:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802cde:	83 e2 1f             	and    $0x1f,%edx
  802ce1:	29 ca                	sub    %ecx,%edx
  802ce3:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802ce7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802ceb:	83 c0 01             	add    $0x1,%eax
  802cee:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  802cf1:	83 c7 01             	add    $0x1,%edi
  802cf4:	eb ac                	jmp    802ca2 <devpipe_write+0x1c>
	return i;
  802cf6:	89 f8                	mov    %edi,%eax
  802cf8:	eb 05                	jmp    802cff <devpipe_write+0x79>
				return 0;
  802cfa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802cff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802d02:	5b                   	pop    %ebx
  802d03:	5e                   	pop    %esi
  802d04:	5f                   	pop    %edi
  802d05:	5d                   	pop    %ebp
  802d06:	c3                   	ret    

00802d07 <devpipe_read>:
{
  802d07:	55                   	push   %ebp
  802d08:	89 e5                	mov    %esp,%ebp
  802d0a:	57                   	push   %edi
  802d0b:	56                   	push   %esi
  802d0c:	53                   	push   %ebx
  802d0d:	83 ec 18             	sub    $0x18,%esp
  802d10:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  802d13:	57                   	push   %edi
  802d14:	e8 97 ef ff ff       	call   801cb0 <fd2data>
  802d19:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802d1b:	83 c4 10             	add    $0x10,%esp
  802d1e:	be 00 00 00 00       	mov    $0x0,%esi
  802d23:	3b 75 10             	cmp    0x10(%ebp),%esi
  802d26:	74 47                	je     802d6f <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  802d28:	8b 03                	mov    (%ebx),%eax
  802d2a:	3b 43 04             	cmp    0x4(%ebx),%eax
  802d2d:	75 22                	jne    802d51 <devpipe_read+0x4a>
			if (i > 0)
  802d2f:	85 f6                	test   %esi,%esi
  802d31:	75 14                	jne    802d47 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  802d33:	89 da                	mov    %ebx,%edx
  802d35:	89 f8                	mov    %edi,%eax
  802d37:	e8 e5 fe ff ff       	call   802c21 <_pipeisclosed>
  802d3c:	85 c0                	test   %eax,%eax
  802d3e:	75 33                	jne    802d73 <devpipe_read+0x6c>
			sys_yield();
  802d40:	e8 f6 e8 ff ff       	call   80163b <sys_yield>
  802d45:	eb e1                	jmp    802d28 <devpipe_read+0x21>
				return i;
  802d47:	89 f0                	mov    %esi,%eax
}
  802d49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802d4c:	5b                   	pop    %ebx
  802d4d:	5e                   	pop    %esi
  802d4e:	5f                   	pop    %edi
  802d4f:	5d                   	pop    %ebp
  802d50:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802d51:	99                   	cltd   
  802d52:	c1 ea 1b             	shr    $0x1b,%edx
  802d55:	01 d0                	add    %edx,%eax
  802d57:	83 e0 1f             	and    $0x1f,%eax
  802d5a:	29 d0                	sub    %edx,%eax
  802d5c:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802d61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802d64:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  802d67:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  802d6a:	83 c6 01             	add    $0x1,%esi
  802d6d:	eb b4                	jmp    802d23 <devpipe_read+0x1c>
	return i;
  802d6f:	89 f0                	mov    %esi,%eax
  802d71:	eb d6                	jmp    802d49 <devpipe_read+0x42>
				return 0;
  802d73:	b8 00 00 00 00       	mov    $0x0,%eax
  802d78:	eb cf                	jmp    802d49 <devpipe_read+0x42>

00802d7a <pipe>:
{
  802d7a:	55                   	push   %ebp
  802d7b:	89 e5                	mov    %esp,%ebp
  802d7d:	56                   	push   %esi
  802d7e:	53                   	push   %ebx
  802d7f:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  802d82:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d85:	50                   	push   %eax
  802d86:	e8 3c ef ff ff       	call   801cc7 <fd_alloc>
  802d8b:	89 c3                	mov    %eax,%ebx
  802d8d:	83 c4 10             	add    $0x10,%esp
  802d90:	85 c0                	test   %eax,%eax
  802d92:	78 5b                	js     802def <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d94:	83 ec 04             	sub    $0x4,%esp
  802d97:	68 07 04 00 00       	push   $0x407
  802d9c:	ff 75 f4             	pushl  -0xc(%ebp)
  802d9f:	6a 00                	push   $0x0
  802da1:	e8 b4 e8 ff ff       	call   80165a <sys_page_alloc>
  802da6:	89 c3                	mov    %eax,%ebx
  802da8:	83 c4 10             	add    $0x10,%esp
  802dab:	85 c0                	test   %eax,%eax
  802dad:	78 40                	js     802def <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  802daf:	83 ec 0c             	sub    $0xc,%esp
  802db2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802db5:	50                   	push   %eax
  802db6:	e8 0c ef ff ff       	call   801cc7 <fd_alloc>
  802dbb:	89 c3                	mov    %eax,%ebx
  802dbd:	83 c4 10             	add    $0x10,%esp
  802dc0:	85 c0                	test   %eax,%eax
  802dc2:	78 1b                	js     802ddf <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802dc4:	83 ec 04             	sub    $0x4,%esp
  802dc7:	68 07 04 00 00       	push   $0x407
  802dcc:	ff 75 f0             	pushl  -0x10(%ebp)
  802dcf:	6a 00                	push   $0x0
  802dd1:	e8 84 e8 ff ff       	call   80165a <sys_page_alloc>
  802dd6:	89 c3                	mov    %eax,%ebx
  802dd8:	83 c4 10             	add    $0x10,%esp
  802ddb:	85 c0                	test   %eax,%eax
  802ddd:	79 19                	jns    802df8 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  802ddf:	83 ec 08             	sub    $0x8,%esp
  802de2:	ff 75 f4             	pushl  -0xc(%ebp)
  802de5:	6a 00                	push   $0x0
  802de7:	e8 f3 e8 ff ff       	call   8016df <sys_page_unmap>
  802dec:	83 c4 10             	add    $0x10,%esp
}
  802def:	89 d8                	mov    %ebx,%eax
  802df1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802df4:	5b                   	pop    %ebx
  802df5:	5e                   	pop    %esi
  802df6:	5d                   	pop    %ebp
  802df7:	c3                   	ret    
	va = fd2data(fd0);
  802df8:	83 ec 0c             	sub    $0xc,%esp
  802dfb:	ff 75 f4             	pushl  -0xc(%ebp)
  802dfe:	e8 ad ee ff ff       	call   801cb0 <fd2data>
  802e03:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802e05:	83 c4 0c             	add    $0xc,%esp
  802e08:	68 07 04 00 00       	push   $0x407
  802e0d:	50                   	push   %eax
  802e0e:	6a 00                	push   $0x0
  802e10:	e8 45 e8 ff ff       	call   80165a <sys_page_alloc>
  802e15:	89 c3                	mov    %eax,%ebx
  802e17:	83 c4 10             	add    $0x10,%esp
  802e1a:	85 c0                	test   %eax,%eax
  802e1c:	0f 88 8c 00 00 00    	js     802eae <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802e22:	83 ec 0c             	sub    $0xc,%esp
  802e25:	ff 75 f0             	pushl  -0x10(%ebp)
  802e28:	e8 83 ee ff ff       	call   801cb0 <fd2data>
  802e2d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802e34:	50                   	push   %eax
  802e35:	6a 00                	push   $0x0
  802e37:	56                   	push   %esi
  802e38:	6a 00                	push   $0x0
  802e3a:	e8 5e e8 ff ff       	call   80169d <sys_page_map>
  802e3f:	89 c3                	mov    %eax,%ebx
  802e41:	83 c4 20             	add    $0x20,%esp
  802e44:	85 c0                	test   %eax,%eax
  802e46:	78 58                	js     802ea0 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  802e48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e4b:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802e51:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802e53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e56:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  802e5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802e60:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802e66:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802e68:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802e6b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  802e72:	83 ec 0c             	sub    $0xc,%esp
  802e75:	ff 75 f4             	pushl  -0xc(%ebp)
  802e78:	e8 23 ee ff ff       	call   801ca0 <fd2num>
  802e7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802e80:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802e82:	83 c4 04             	add    $0x4,%esp
  802e85:	ff 75 f0             	pushl  -0x10(%ebp)
  802e88:	e8 13 ee ff ff       	call   801ca0 <fd2num>
  802e8d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802e90:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802e93:	83 c4 10             	add    $0x10,%esp
  802e96:	bb 00 00 00 00       	mov    $0x0,%ebx
  802e9b:	e9 4f ff ff ff       	jmp    802def <pipe+0x75>
	sys_page_unmap(0, va);
  802ea0:	83 ec 08             	sub    $0x8,%esp
  802ea3:	56                   	push   %esi
  802ea4:	6a 00                	push   $0x0
  802ea6:	e8 34 e8 ff ff       	call   8016df <sys_page_unmap>
  802eab:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  802eae:	83 ec 08             	sub    $0x8,%esp
  802eb1:	ff 75 f0             	pushl  -0x10(%ebp)
  802eb4:	6a 00                	push   $0x0
  802eb6:	e8 24 e8 ff ff       	call   8016df <sys_page_unmap>
  802ebb:	83 c4 10             	add    $0x10,%esp
  802ebe:	e9 1c ff ff ff       	jmp    802ddf <pipe+0x65>

00802ec3 <pipeisclosed>:
{
  802ec3:	55                   	push   %ebp
  802ec4:	89 e5                	mov    %esp,%ebp
  802ec6:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802ec9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802ecc:	50                   	push   %eax
  802ecd:	ff 75 08             	pushl  0x8(%ebp)
  802ed0:	e8 41 ee ff ff       	call   801d16 <fd_lookup>
  802ed5:	83 c4 10             	add    $0x10,%esp
  802ed8:	85 c0                	test   %eax,%eax
  802eda:	78 18                	js     802ef4 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  802edc:	83 ec 0c             	sub    $0xc,%esp
  802edf:	ff 75 f4             	pushl  -0xc(%ebp)
  802ee2:	e8 c9 ed ff ff       	call   801cb0 <fd2data>
	return _pipeisclosed(fd, p);
  802ee7:	89 c2                	mov    %eax,%edx
  802ee9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802eec:	e8 30 fd ff ff       	call   802c21 <_pipeisclosed>
  802ef1:	83 c4 10             	add    $0x10,%esp
}
  802ef4:	c9                   	leave  
  802ef5:	c3                   	ret    

00802ef6 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802ef6:	55                   	push   %ebp
  802ef7:	89 e5                	mov    %esp,%ebp
  802ef9:	56                   	push   %esi
  802efa:	53                   	push   %ebx
  802efb:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802efe:	85 f6                	test   %esi,%esi
  802f00:	74 13                	je     802f15 <wait+0x1f>
	e = &envs[ENVX(envid)];
  802f02:	89 f3                	mov    %esi,%ebx
  802f04:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802f0a:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802f0d:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802f13:	eb 1b                	jmp    802f30 <wait+0x3a>
	assert(envid != 0);
  802f15:	68 97 3b 80 00       	push   $0x803b97
  802f1a:	68 ac 34 80 00       	push   $0x8034ac
  802f1f:	6a 09                	push   $0x9
  802f21:	68 a2 3b 80 00       	push   $0x803ba2
  802f26:	e8 4c db ff ff       	call   800a77 <_panic>
		sys_yield();
  802f2b:	e8 0b e7 ff ff       	call   80163b <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802f30:	8b 43 48             	mov    0x48(%ebx),%eax
  802f33:	39 f0                	cmp    %esi,%eax
  802f35:	75 07                	jne    802f3e <wait+0x48>
  802f37:	8b 43 54             	mov    0x54(%ebx),%eax
  802f3a:	85 c0                	test   %eax,%eax
  802f3c:	75 ed                	jne    802f2b <wait+0x35>
}
  802f3e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802f41:	5b                   	pop    %ebx
  802f42:	5e                   	pop    %esi
  802f43:	5d                   	pop    %ebp
  802f44:	c3                   	ret    

00802f45 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802f45:	55                   	push   %ebp
  802f46:	89 e5                	mov    %esp,%ebp
  802f48:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802f4b:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802f52:	74 0a                	je     802f5e <set_pgfault_handler+0x19>
			panic("set_pgfault_handler %e",r);
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
	}
       
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802f54:	8b 45 08             	mov    0x8(%ebp),%eax
  802f57:	a3 00 70 80 00       	mov    %eax,0x807000
}
  802f5c:	c9                   	leave  
  802f5d:	c3                   	ret    
		if((r=sys_page_alloc(thisenv->env_id,(void *)UXSTACKTOP-PGSIZE,PTE_P|PTE_W|PTE_U))<0)
  802f5e:	a1 24 54 80 00       	mov    0x805424,%eax
  802f63:	8b 40 48             	mov    0x48(%eax),%eax
  802f66:	83 ec 04             	sub    $0x4,%esp
  802f69:	6a 07                	push   $0x7
  802f6b:	68 00 f0 bf ee       	push   $0xeebff000
  802f70:	50                   	push   %eax
  802f71:	e8 e4 e6 ff ff       	call   80165a <sys_page_alloc>
  802f76:	83 c4 10             	add    $0x10,%esp
  802f79:	85 c0                	test   %eax,%eax
  802f7b:	78 1b                	js     802f98 <set_pgfault_handler+0x53>
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
  802f7d:	a1 24 54 80 00       	mov    0x805424,%eax
  802f82:	8b 40 48             	mov    0x48(%eax),%eax
  802f85:	83 ec 08             	sub    $0x8,%esp
  802f88:	68 aa 2f 80 00       	push   $0x802faa
  802f8d:	50                   	push   %eax
  802f8e:	e8 12 e8 ff ff       	call   8017a5 <sys_env_set_pgfault_upcall>
  802f93:	83 c4 10             	add    $0x10,%esp
  802f96:	eb bc                	jmp    802f54 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler %e",r);
  802f98:	50                   	push   %eax
  802f99:	68 ad 3b 80 00       	push   $0x803bad
  802f9e:	6a 22                	push   $0x22
  802fa0:	68 c4 3b 80 00       	push   $0x803bc4
  802fa5:	e8 cd da ff ff       	call   800a77 <_panic>

00802faa <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802faa:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802fab:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802fb0:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802fb2:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
        movl 48(%esp), %ebp
  802fb5:	8b 6c 24 30          	mov    0x30(%esp),%ebp
        subl $4, %ebp
  802fb9:	83 ed 04             	sub    $0x4,%ebp
        movl %ebp, 48(%esp)
  802fbc:	89 6c 24 30          	mov    %ebp,0x30(%esp)
        movl 40(%esp), %eax
  802fc0:	8b 44 24 28          	mov    0x28(%esp),%eax
        movl %eax, (%ebp)
  802fc4:	89 45 00             	mov    %eax,0x0(%ebp)
	// Restore the trap-time registers.  After you do this, you
 	// can no longer modify any general-purpose registers.
 	// LAB 4: Your code here.
        addl $8, %esp
  802fc7:	83 c4 08             	add    $0x8,%esp
        popal
  802fca:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
        addl $4, %esp
  802fcb:	83 c4 04             	add    $0x4,%esp
        popfl
  802fce:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
        popl %esp
  802fcf:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
        ret
  802fd0:	c3                   	ret    

00802fd1 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802fd1:	55                   	push   %ebp
  802fd2:	89 e5                	mov    %esp,%ebp
  802fd4:	56                   	push   %esi
  802fd5:	53                   	push   %ebx
  802fd6:	8b 75 08             	mov    0x8(%ebp),%esi
  802fd9:	8b 45 0c             	mov    0xc(%ebp),%eax
  802fdc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
        //	panic("ipc_recv not implemented");
        int r;
       	if(pg!=NULL){
  802fdf:	85 c0                	test   %eax,%eax
  802fe1:	74 3b                	je     80301e <ipc_recv+0x4d>
	  r = sys_ipc_recv(pg);
  802fe3:	83 ec 0c             	sub    $0xc,%esp
  802fe6:	50                   	push   %eax
  802fe7:	e8 1e e8 ff ff       	call   80180a <sys_ipc_recv>
  802fec:	83 c4 10             	add    $0x10,%esp
	}else
	  r = sys_ipc_recv((void *)UTOP);
	if(r<0){
  802fef:	85 c0                	test   %eax,%eax
  802ff1:	78 3d                	js     803030 <ipc_recv+0x5f>
	if(perm_store!=NULL){
		*perm_store = 0;
            }
        	return r;
           }else{
	     if(from_env_store!=NULL)
  802ff3:	85 f6                	test   %esi,%esi
  802ff5:	74 0a                	je     803001 <ipc_recv+0x30>
		     *from_env_store = thisenv->env_ipc_from;
  802ff7:	a1 24 54 80 00       	mov    0x805424,%eax
  802ffc:	8b 40 74             	mov    0x74(%eax),%eax
  802fff:	89 06                	mov    %eax,(%esi)
	     if(perm_store != NULL)
  803001:	85 db                	test   %ebx,%ebx
  803003:	74 0a                	je     80300f <ipc_recv+0x3e>
		     *perm_store = thisenv->env_ipc_perm;
  803005:	a1 24 54 80 00       	mov    0x805424,%eax
  80300a:	8b 40 78             	mov    0x78(%eax),%eax
  80300d:	89 03                	mov    %eax,(%ebx)
	     return thisenv->env_ipc_value;
  80300f:	a1 24 54 80 00       	mov    0x805424,%eax
  803014:	8b 40 70             	mov    0x70(%eax),%eax
	   }

}
  803017:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80301a:	5b                   	pop    %ebx
  80301b:	5e                   	pop    %esi
  80301c:	5d                   	pop    %ebp
  80301d:	c3                   	ret    
	  r = sys_ipc_recv((void *)UTOP);
  80301e:	83 ec 0c             	sub    $0xc,%esp
  803021:	68 00 00 c0 ee       	push   $0xeec00000
  803026:	e8 df e7 ff ff       	call   80180a <sys_ipc_recv>
  80302b:	83 c4 10             	add    $0x10,%esp
  80302e:	eb bf                	jmp    802fef <ipc_recv+0x1e>
	if(from_env_store!=NULL){
  803030:	85 f6                	test   %esi,%esi
  803032:	74 06                	je     80303a <ipc_recv+0x69>
	  *from_env_store = 0;
  803034:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if(perm_store!=NULL){
  80303a:	85 db                	test   %ebx,%ebx
  80303c:	74 d9                	je     803017 <ipc_recv+0x46>
		*perm_store = 0;
  80303e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  803044:	eb d1                	jmp    803017 <ipc_recv+0x46>

00803046 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  803046:	55                   	push   %ebp
  803047:	89 e5                	mov    %esp,%ebp
  803049:	57                   	push   %edi
  80304a:	56                   	push   %esi
  80304b:	53                   	push   %ebx
  80304c:	83 ec 0c             	sub    $0xc,%esp
  80304f:	8b 7d 08             	mov    0x8(%ebp),%edi
  803052:	8b 75 0c             	mov    0xc(%ebp),%esi
  803055:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if(pg==NULL) pg = (void *)UTOP;
  803058:	85 db                	test   %ebx,%ebx
  80305a:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80305f:	0f 44 d8             	cmove  %eax,%ebx
	while((r=sys_ipc_try_send(to_env,val,pg,perm))<0){
  803062:	ff 75 14             	pushl  0x14(%ebp)
  803065:	53                   	push   %ebx
  803066:	56                   	push   %esi
  803067:	57                   	push   %edi
  803068:	e8 7a e7 ff ff       	call   8017e7 <sys_ipc_try_send>
  80306d:	83 c4 10             	add    $0x10,%esp
  803070:	85 c0                	test   %eax,%eax
  803072:	79 20                	jns    803094 <ipc_send+0x4e>
	    if(r!=-E_IPC_NOT_RECV){
  803074:	83 f8 f9             	cmp    $0xfffffff9,%eax
  803077:	75 07                	jne    803080 <ipc_send+0x3a>
		    panic("ipc_send:send message failed\n");
	    }
	    sys_yield();
  803079:	e8 bd e5 ff ff       	call   80163b <sys_yield>
  80307e:	eb e2                	jmp    803062 <ipc_send+0x1c>
		    panic("ipc_send:send message failed\n");
  803080:	83 ec 04             	sub    $0x4,%esp
  803083:	68 d2 3b 80 00       	push   $0x803bd2
  803088:	6a 43                	push   $0x43
  80308a:	68 f0 3b 80 00       	push   $0x803bf0
  80308f:	e8 e3 d9 ff ff       	call   800a77 <_panic>
	}

}
  803094:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803097:	5b                   	pop    %ebx
  803098:	5e                   	pop    %esi
  803099:	5f                   	pop    %edi
  80309a:	5d                   	pop    %ebp
  80309b:	c3                   	ret    

0080309c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80309c:	55                   	push   %ebp
  80309d:	89 e5                	mov    %esp,%ebp
  80309f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8030a2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8030a7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8030aa:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8030b0:	8b 52 50             	mov    0x50(%edx),%edx
  8030b3:	39 ca                	cmp    %ecx,%edx
  8030b5:	74 11                	je     8030c8 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  8030b7:	83 c0 01             	add    $0x1,%eax
  8030ba:	3d 00 04 00 00       	cmp    $0x400,%eax
  8030bf:	75 e6                	jne    8030a7 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8030c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8030c6:	eb 0b                	jmp    8030d3 <ipc_find_env+0x37>
			return envs[i].env_id;
  8030c8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8030cb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8030d0:	8b 40 48             	mov    0x48(%eax),%eax
}
  8030d3:	5d                   	pop    %ebp
  8030d4:	c3                   	ret    

008030d5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8030d5:	55                   	push   %ebp
  8030d6:	89 e5                	mov    %esp,%ebp
  8030d8:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8030db:	89 d0                	mov    %edx,%eax
  8030dd:	c1 e8 16             	shr    $0x16,%eax
  8030e0:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8030e7:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  8030ec:	f6 c1 01             	test   $0x1,%cl
  8030ef:	74 1d                	je     80310e <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  8030f1:	c1 ea 0c             	shr    $0xc,%edx
  8030f4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8030fb:	f6 c2 01             	test   $0x1,%dl
  8030fe:	74 0e                	je     80310e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  803100:	c1 ea 0c             	shr    $0xc,%edx
  803103:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80310a:	ef 
  80310b:	0f b7 c0             	movzwl %ax,%eax
}
  80310e:	5d                   	pop    %ebp
  80310f:	c3                   	ret    

00803110 <__udivdi3>:
  803110:	55                   	push   %ebp
  803111:	57                   	push   %edi
  803112:	56                   	push   %esi
  803113:	53                   	push   %ebx
  803114:	83 ec 1c             	sub    $0x1c,%esp
  803117:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80311b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  80311f:	8b 74 24 34          	mov    0x34(%esp),%esi
  803123:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  803127:	85 d2                	test   %edx,%edx
  803129:	75 35                	jne    803160 <__udivdi3+0x50>
  80312b:	39 f3                	cmp    %esi,%ebx
  80312d:	0f 87 bd 00 00 00    	ja     8031f0 <__udivdi3+0xe0>
  803133:	85 db                	test   %ebx,%ebx
  803135:	89 d9                	mov    %ebx,%ecx
  803137:	75 0b                	jne    803144 <__udivdi3+0x34>
  803139:	b8 01 00 00 00       	mov    $0x1,%eax
  80313e:	31 d2                	xor    %edx,%edx
  803140:	f7 f3                	div    %ebx
  803142:	89 c1                	mov    %eax,%ecx
  803144:	31 d2                	xor    %edx,%edx
  803146:	89 f0                	mov    %esi,%eax
  803148:	f7 f1                	div    %ecx
  80314a:	89 c6                	mov    %eax,%esi
  80314c:	89 e8                	mov    %ebp,%eax
  80314e:	89 f7                	mov    %esi,%edi
  803150:	f7 f1                	div    %ecx
  803152:	89 fa                	mov    %edi,%edx
  803154:	83 c4 1c             	add    $0x1c,%esp
  803157:	5b                   	pop    %ebx
  803158:	5e                   	pop    %esi
  803159:	5f                   	pop    %edi
  80315a:	5d                   	pop    %ebp
  80315b:	c3                   	ret    
  80315c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803160:	39 f2                	cmp    %esi,%edx
  803162:	77 7c                	ja     8031e0 <__udivdi3+0xd0>
  803164:	0f bd fa             	bsr    %edx,%edi
  803167:	83 f7 1f             	xor    $0x1f,%edi
  80316a:	0f 84 98 00 00 00    	je     803208 <__udivdi3+0xf8>
  803170:	89 f9                	mov    %edi,%ecx
  803172:	b8 20 00 00 00       	mov    $0x20,%eax
  803177:	29 f8                	sub    %edi,%eax
  803179:	d3 e2                	shl    %cl,%edx
  80317b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80317f:	89 c1                	mov    %eax,%ecx
  803181:	89 da                	mov    %ebx,%edx
  803183:	d3 ea                	shr    %cl,%edx
  803185:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  803189:	09 d1                	or     %edx,%ecx
  80318b:	89 f2                	mov    %esi,%edx
  80318d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803191:	89 f9                	mov    %edi,%ecx
  803193:	d3 e3                	shl    %cl,%ebx
  803195:	89 c1                	mov    %eax,%ecx
  803197:	d3 ea                	shr    %cl,%edx
  803199:	89 f9                	mov    %edi,%ecx
  80319b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80319f:	d3 e6                	shl    %cl,%esi
  8031a1:	89 eb                	mov    %ebp,%ebx
  8031a3:	89 c1                	mov    %eax,%ecx
  8031a5:	d3 eb                	shr    %cl,%ebx
  8031a7:	09 de                	or     %ebx,%esi
  8031a9:	89 f0                	mov    %esi,%eax
  8031ab:	f7 74 24 08          	divl   0x8(%esp)
  8031af:	89 d6                	mov    %edx,%esi
  8031b1:	89 c3                	mov    %eax,%ebx
  8031b3:	f7 64 24 0c          	mull   0xc(%esp)
  8031b7:	39 d6                	cmp    %edx,%esi
  8031b9:	72 0c                	jb     8031c7 <__udivdi3+0xb7>
  8031bb:	89 f9                	mov    %edi,%ecx
  8031bd:	d3 e5                	shl    %cl,%ebp
  8031bf:	39 c5                	cmp    %eax,%ebp
  8031c1:	73 5d                	jae    803220 <__udivdi3+0x110>
  8031c3:	39 d6                	cmp    %edx,%esi
  8031c5:	75 59                	jne    803220 <__udivdi3+0x110>
  8031c7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8031ca:	31 ff                	xor    %edi,%edi
  8031cc:	89 fa                	mov    %edi,%edx
  8031ce:	83 c4 1c             	add    $0x1c,%esp
  8031d1:	5b                   	pop    %ebx
  8031d2:	5e                   	pop    %esi
  8031d3:	5f                   	pop    %edi
  8031d4:	5d                   	pop    %ebp
  8031d5:	c3                   	ret    
  8031d6:	8d 76 00             	lea    0x0(%esi),%esi
  8031d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8031e0:	31 ff                	xor    %edi,%edi
  8031e2:	31 c0                	xor    %eax,%eax
  8031e4:	89 fa                	mov    %edi,%edx
  8031e6:	83 c4 1c             	add    $0x1c,%esp
  8031e9:	5b                   	pop    %ebx
  8031ea:	5e                   	pop    %esi
  8031eb:	5f                   	pop    %edi
  8031ec:	5d                   	pop    %ebp
  8031ed:	c3                   	ret    
  8031ee:	66 90                	xchg   %ax,%ax
  8031f0:	31 ff                	xor    %edi,%edi
  8031f2:	89 e8                	mov    %ebp,%eax
  8031f4:	89 f2                	mov    %esi,%edx
  8031f6:	f7 f3                	div    %ebx
  8031f8:	89 fa                	mov    %edi,%edx
  8031fa:	83 c4 1c             	add    $0x1c,%esp
  8031fd:	5b                   	pop    %ebx
  8031fe:	5e                   	pop    %esi
  8031ff:	5f                   	pop    %edi
  803200:	5d                   	pop    %ebp
  803201:	c3                   	ret    
  803202:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803208:	39 f2                	cmp    %esi,%edx
  80320a:	72 06                	jb     803212 <__udivdi3+0x102>
  80320c:	31 c0                	xor    %eax,%eax
  80320e:	39 eb                	cmp    %ebp,%ebx
  803210:	77 d2                	ja     8031e4 <__udivdi3+0xd4>
  803212:	b8 01 00 00 00       	mov    $0x1,%eax
  803217:	eb cb                	jmp    8031e4 <__udivdi3+0xd4>
  803219:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803220:	89 d8                	mov    %ebx,%eax
  803222:	31 ff                	xor    %edi,%edi
  803224:	eb be                	jmp    8031e4 <__udivdi3+0xd4>
  803226:	66 90                	xchg   %ax,%ax
  803228:	66 90                	xchg   %ax,%ax
  80322a:	66 90                	xchg   %ax,%ax
  80322c:	66 90                	xchg   %ax,%ax
  80322e:	66 90                	xchg   %ax,%ax

00803230 <__umoddi3>:
  803230:	55                   	push   %ebp
  803231:	57                   	push   %edi
  803232:	56                   	push   %esi
  803233:	53                   	push   %ebx
  803234:	83 ec 1c             	sub    $0x1c,%esp
  803237:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80323b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80323f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  803243:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803247:	85 ed                	test   %ebp,%ebp
  803249:	89 f0                	mov    %esi,%eax
  80324b:	89 da                	mov    %ebx,%edx
  80324d:	75 19                	jne    803268 <__umoddi3+0x38>
  80324f:	39 df                	cmp    %ebx,%edi
  803251:	0f 86 b1 00 00 00    	jbe    803308 <__umoddi3+0xd8>
  803257:	f7 f7                	div    %edi
  803259:	89 d0                	mov    %edx,%eax
  80325b:	31 d2                	xor    %edx,%edx
  80325d:	83 c4 1c             	add    $0x1c,%esp
  803260:	5b                   	pop    %ebx
  803261:	5e                   	pop    %esi
  803262:	5f                   	pop    %edi
  803263:	5d                   	pop    %ebp
  803264:	c3                   	ret    
  803265:	8d 76 00             	lea    0x0(%esi),%esi
  803268:	39 dd                	cmp    %ebx,%ebp
  80326a:	77 f1                	ja     80325d <__umoddi3+0x2d>
  80326c:	0f bd cd             	bsr    %ebp,%ecx
  80326f:	83 f1 1f             	xor    $0x1f,%ecx
  803272:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  803276:	0f 84 b4 00 00 00    	je     803330 <__umoddi3+0x100>
  80327c:	b8 20 00 00 00       	mov    $0x20,%eax
  803281:	89 c2                	mov    %eax,%edx
  803283:	8b 44 24 04          	mov    0x4(%esp),%eax
  803287:	29 c2                	sub    %eax,%edx
  803289:	89 c1                	mov    %eax,%ecx
  80328b:	89 f8                	mov    %edi,%eax
  80328d:	d3 e5                	shl    %cl,%ebp
  80328f:	89 d1                	mov    %edx,%ecx
  803291:	89 54 24 0c          	mov    %edx,0xc(%esp)
  803295:	d3 e8                	shr    %cl,%eax
  803297:	09 c5                	or     %eax,%ebp
  803299:	8b 44 24 04          	mov    0x4(%esp),%eax
  80329d:	89 c1                	mov    %eax,%ecx
  80329f:	d3 e7                	shl    %cl,%edi
  8032a1:	89 d1                	mov    %edx,%ecx
  8032a3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8032a7:	89 df                	mov    %ebx,%edi
  8032a9:	d3 ef                	shr    %cl,%edi
  8032ab:	89 c1                	mov    %eax,%ecx
  8032ad:	89 f0                	mov    %esi,%eax
  8032af:	d3 e3                	shl    %cl,%ebx
  8032b1:	89 d1                	mov    %edx,%ecx
  8032b3:	89 fa                	mov    %edi,%edx
  8032b5:	d3 e8                	shr    %cl,%eax
  8032b7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8032bc:	09 d8                	or     %ebx,%eax
  8032be:	f7 f5                	div    %ebp
  8032c0:	d3 e6                	shl    %cl,%esi
  8032c2:	89 d1                	mov    %edx,%ecx
  8032c4:	f7 64 24 08          	mull   0x8(%esp)
  8032c8:	39 d1                	cmp    %edx,%ecx
  8032ca:	89 c3                	mov    %eax,%ebx
  8032cc:	89 d7                	mov    %edx,%edi
  8032ce:	72 06                	jb     8032d6 <__umoddi3+0xa6>
  8032d0:	75 0e                	jne    8032e0 <__umoddi3+0xb0>
  8032d2:	39 c6                	cmp    %eax,%esi
  8032d4:	73 0a                	jae    8032e0 <__umoddi3+0xb0>
  8032d6:	2b 44 24 08          	sub    0x8(%esp),%eax
  8032da:	19 ea                	sbb    %ebp,%edx
  8032dc:	89 d7                	mov    %edx,%edi
  8032de:	89 c3                	mov    %eax,%ebx
  8032e0:	89 ca                	mov    %ecx,%edx
  8032e2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8032e7:	29 de                	sub    %ebx,%esi
  8032e9:	19 fa                	sbb    %edi,%edx
  8032eb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  8032ef:	89 d0                	mov    %edx,%eax
  8032f1:	d3 e0                	shl    %cl,%eax
  8032f3:	89 d9                	mov    %ebx,%ecx
  8032f5:	d3 ee                	shr    %cl,%esi
  8032f7:	d3 ea                	shr    %cl,%edx
  8032f9:	09 f0                	or     %esi,%eax
  8032fb:	83 c4 1c             	add    $0x1c,%esp
  8032fe:	5b                   	pop    %ebx
  8032ff:	5e                   	pop    %esi
  803300:	5f                   	pop    %edi
  803301:	5d                   	pop    %ebp
  803302:	c3                   	ret    
  803303:	90                   	nop
  803304:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803308:	85 ff                	test   %edi,%edi
  80330a:	89 f9                	mov    %edi,%ecx
  80330c:	75 0b                	jne    803319 <__umoddi3+0xe9>
  80330e:	b8 01 00 00 00       	mov    $0x1,%eax
  803313:	31 d2                	xor    %edx,%edx
  803315:	f7 f7                	div    %edi
  803317:	89 c1                	mov    %eax,%ecx
  803319:	89 d8                	mov    %ebx,%eax
  80331b:	31 d2                	xor    %edx,%edx
  80331d:	f7 f1                	div    %ecx
  80331f:	89 f0                	mov    %esi,%eax
  803321:	f7 f1                	div    %ecx
  803323:	e9 31 ff ff ff       	jmp    803259 <__umoddi3+0x29>
  803328:	90                   	nop
  803329:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803330:	39 dd                	cmp    %ebx,%ebp
  803332:	72 08                	jb     80333c <__umoddi3+0x10c>
  803334:	39 f7                	cmp    %esi,%edi
  803336:	0f 87 21 ff ff ff    	ja     80325d <__umoddi3+0x2d>
  80333c:	89 da                	mov    %ebx,%edx
  80333e:	89 f0                	mov    %esi,%eax
  803340:	29 f8                	sub    %edi,%eax
  803342:	19 ea                	sbb    %ebp,%edx
  803344:	e9 14 ff ff ff       	jmp    80325d <__umoddi3+0x2d>
